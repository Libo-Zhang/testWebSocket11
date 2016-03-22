#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include "channel_lock.h"
#include "coder.h"

#if 0
unsigned int current_timestamp() {
    struct timeval te; 
    gettimeofday(&te, NULL); // get current time
    unsigned int milliseconds = te.tv_sec*1000LL + te.tv_usec/1000; // caculate milliseconds
    return milliseconds;
}
#else
unsigned int current_timestamp() {
	static unsigned int milliseconds = 400;
	
	milliseconds++;

    return milliseconds;
}
#endif

unsigned int* lock_stream_gen(unsigned int *stream, unsigned int base, unsigned int spec_char, unsigned int interval)
{
		stream[0] = base + spec_char;
		stream[1] = stream[0] + interval;
		stream[2] = stream[1] + interval;
		stream[3] = stream[2] + interval;

	return stream;
}

void gen_bit_mask(unsigned int start, unsigned int end, unsigned int *mask)
{
	int block_start, block_end;
	int low, high, i;
	unsigned int reverse_mask=0;

	if(start > end)
	{
		low = end;
		high = start;
	}
	else
	{
		low = start;
		high = end;
	}
	
	for(i=0; i < SC_LOCK_PHASE_BIT_MAP_NUMS; i++)
	{
		block_start = 32*i;
		block_end = 32*(i + 1);
		mask[i] = 0;

		if(start == end)
			continue;
		else
		{
			if((low < block_end) && (high > block_start))
			{
				if(low < block_end)
				{
					if(low <= block_start)
						mask[i] = (unsigned int)-1;
					else
						mask[i] = (unsigned int)(0 - (1 << (low - block_start)));
				}
				if(high < block_end)
				{
					reverse_mask = (1 << (high - block_start)) - 1;
					mask[i] = mask[i] & reverse_mask;
				}
			}
		}
	}
}

struct lock_phase_ta* insert_lock_data(unsigned int data, char *addr, struct try_lock_data *lock_data)
{
	int current_pos=0;
	int i, x, y;
	struct lock_phase_ta *ta=NULL, *find=NULL, *pre=NULL;
	int observe_window = (SC_FRAME_TIME_INTERVAL + 10) * 4;
	unsigned int current_time = current_timestamp();
	unsigned int bit_mask[SC_LOCK_PHASE_BIT_MAP_NUMS];

	/* pass too old entries */
	while(lock_data->start_pos != lock_data->next_pos) // "==" : no entry
	{
#if 0
		printf("current_time=%d, timestamp[%d]=%d, diff=%d, observe_window=%d\n",
				current_time, lock_data->start_pos, lock_data->timestamp[lock_data->start_pos],
				((int)current_time - (int)lock_data->timestamp[lock_data->start_pos]), observe_window);
#endif
		if(((int)current_time - (int)lock_data->timestamp[lock_data->start_pos]) > observe_window)
		{
			if(++lock_data->start_pos >= SC_LOCK_PHASE_DATA_NUMS)
				lock_data->start_pos = 0;
		}
		else
			break;
	}

	/* insert data */
	lock_data->frames[lock_data->next_pos] = data;
	lock_data->timestamp[lock_data->next_pos] = current_time;
	current_pos = lock_data->next_pos;

	/* lock_data->next_pos causes the valid data num = (SC_LOCK_PHASE_DATA_NUMS - 1).
	   It is acceptable. 																*/
	if((++lock_data->next_pos) >= SC_LOCK_PHASE_DATA_NUMS)
		lock_data->next_pos = 0;
	if(lock_data->next_pos == lock_data->start_pos)
	{
		if(++lock_data->start_pos >= SC_LOCK_PHASE_DATA_NUMS)
			lock_data->start_pos = 0;
	}

#if 0
	printf("%s(): next = %d, start=%d\n", __FUNCTION__, lock_data->next_pos, lock_data->start_pos);
#endif

	gen_bit_mask(lock_data->start_pos, lock_data->next_pos, bit_mask);
#if 0
	printf("mask = ");
	for(i=0; i<SC_LOCK_PHASE_BIT_MAP_NUMS; i++)
		printf("0x%08x:", bit_mask[i]);
	printf("\n");
#endif
	ta = lock_data->ta_list;
	while(ta)
	{
		if((find == NULL) && (memcmp(ta->addr, addr, 6) == 0))
			find = ta;

		/* rebuild the bit_map */
		for(i=0; i<SC_LOCK_PHASE_BIT_MAP_NUMS; i++)
			ta->bit_map[i] &= bit_mask[i];

		pre = ta;
		ta = ta->next;
	}

	if(find == NULL)
	{
		find = (struct lock_phase_ta *)malloc(sizeof(struct lock_phase_ta));
		if(find == NULL)
			return NULL;
		memset(find, 0, sizeof(struct lock_phase_ta));
		memcpy(find->addr, addr, 6);
		if(pre)
			pre->next = find;
		else
			lock_data->ta_list = find;
	}

	x = (current_pos)/(32);
	y = (current_pos)%(32);
	find->bit_map[x] |= (1 << y);

#if 0
	printf("%s(): x=%d, y=%d, current_pos=%d, find->bit_map[x]=0x%08x\n",
			__FUNCTION__, x, y, current_pos, find->bit_map[x]);
#endif

	return find;
}

int lock_match(struct lock_phase_ta *ta, struct try_lock_data *lock_data)
{
	int ptr = lock_data->start_pos;
	int match_arr[32][3];
	int i, j;
	int x, y;
	int header_len=0;
	unsigned int comp_val=0;


	memset(match_arr, 0, sizeof(match_arr));

	while(ptr != lock_data->next_pos)
	{
		x = (ptr)/32;
		y = (ptr)%32;
		
		if(ta->bit_map[x] & (1 << y))
		{
			comp_val = lock_data->frames[ptr] - SC_LOCK_INTERVAL_LEN;

			for(i=0; i<32; i++)
			{
				if(match_arr[i][0] == 0)
				{
					match_arr[i][0] = lock_data->frames[ptr];
					break;
				}
				else
				{
					for(j=2; j>=0; j--)
					{
						if((match_arr[i][j] != 0) && (match_arr[i][j] == comp_val))
						{
							if(j == 2)
							{
								header_len = match_arr[i][0] - SC_LOCK_SPEC_CHAR - SC_LOCK_LENGTH_BASE;
								printf("find the match value header_len=%d (0)\n", header_len);
								return header_len; 
							}
							else
							{
								match_arr[i][j+1] = lock_data->frames[ptr];
							}
						}
					}
				}
			}
		}

		if(++ptr >= SC_LOCK_PHASE_DATA_NUMS)
			ptr = 0;
	}

#if 0
	for(i =0; i<32; i++)
	{
		printf("ta=%02x:%02x:%02x:%02x:%02x:%02x:, comp_val=%x, match_arr[%d] = %04x:%04x:%04x\n", 
				ta->addr[0], ta->addr[1], ta->addr[2], 
				ta->addr[3], ta->addr[4], ta->addr[5], comp_val,
				i, match_arr[i][0], match_arr[i][1], match_arr[i][2]);
	}
#endif
	return 0;
}

int try_lock_channel(unsigned int data, char *addr, struct try_lock_data *lock_data)
{
	int header_len=0;
//	unsigned int lock_stream[4];
//	int observe_window = (SC_FRAME_TIME_INTERVAL + 10) * 4;
	struct lock_phase_ta *ta;
	
	ta = insert_lock_data(data, addr, lock_data);
	if(ta)
		header_len = lock_match(ta, lock_data);

	return header_len;	
}

int free_lock_data(struct try_lock_data *lock_data)
{
	struct lock_phase_ta *ta, *next;

	ta = lock_data->ta_list;

	while(ta)
	{
		next = ta->next;
		free(ta);
		ta = next;
	}
    return 0;
}
