#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "coder.h"

unsigned int* append_even_odd(unsigned int *stream, unsigned char data)
{
	*stream = (data << SMART_CONFIG_SHIFT) + SMART_CONFIG_LENGTH_BASE;
	*(++stream) = ((data | SC_EVEN_ODD) << SMART_CONFIG_SHIFT) + SMART_CONFIG_LENGTH_BASE;

	return stream;
}

unsigned int* sc_encoder(unsigned char *data, int data_len)
{
	int i;
	unsigned char block_count=0, tmp=0;
	unsigned char *data_end = data + data_len;
	unsigned int *stream, *ptr;
	int stream_len;

	stream_len = (data_len*2 + (data_len / SMART_CONFIG_BLOCK_BYTES))*2;
	if((stream = (unsigned int *)malloc(stream_len*sizeof(unsigned int))) == NULL)
		return NULL;

	ptr = stream;

	while(data < data_end)
	{
		ptr = append_even_odd(ptr, (SC_CTL_SSID_BLOCK_0 + block_count++));
		for(i=0; i<8; i++)
		{
			tmp = ((*data & 0xf0) >> 4) | SC_CONTROL_DATA;
			ptr = append_even_odd(++ptr, tmp);
			tmp = (*data & 0x0f) | SC_CONTROL_DATA;
			ptr = append_even_odd(++ptr, tmp);
			if(++data == data_end)
				break;
		}
		ptr++;
	}

	return stream;
}

unsigned char* sc_decoder(unsigned int data, struct sc_rx_block *blocks)
{
	struct sc_block_entry *entry;
	unsigned char *ret=NULL, *ptr=NULL;
	int block_num=0;
	int i, tmp, total_group = 0;

	if((blocks->pending_rx_data) && (data & SC_CONTROL_DATA)) // pass this data info rx
	{
		//printf("%s(): pending rx data\n", __FUNCTION__);
		return NULL;
	}

	if((data & SC_EVEN_ODD) == 0)	// even
	{
		if(blocks->rx_even_count < 32)
		{
			blocks->rx_even[blocks->rx_even_count++] = data;
		}
		else
		{
			blocks->rx_even[0] = data;
			blocks->rx_even_count = 1;
		}
	}
	else	// odd
	{
		for(i=0; i < blocks->rx_even_count; i++)
		{
			if((blocks->rx_even[i] | SC_EVEN_ODD) == data)	// find the matched pair
			{
				entry = &blocks->block[blocks->current_rx_block];
				if(data & SC_CONTROL_DATA)	// data
				{
					//if(blocks->pending_rx_data == 0)
					{
						if(blocks->current_rx_block < SMART_CONFIG_BLOCK_NUMS)
						{
							if(entry->current_rx_count < SMART_CONFIG_BLOCK_FRAMES)
								entry->value[entry->current_rx_count] = (data & 0xf);
							entry->current_rx_count++;
						}
					}
#if 0
					printf("%s(): data=%x, current_rx_block=%d, current_rx_count=%d\n",
							__FUNCTION__, blocks->rx_even[i], blocks->current_rx_block, 
							entry->current_rx_count);
#endif
				}
				else	// control
				{
					block_num = (blocks->rx_even[i] - SC_CTL_SSID_BLOCK_0);
					if(block_num < SMART_CONFIG_BLOCK_NUMS)
					{
#if 0
						printf("find the group %d, pending_rx_data=%d, current_rx_count=%d\n", 
								block_num, blocks->pending_rx_data, entry->current_rx_count);
#endif
						if(blocks->pending_rx_data)
							blocks->pending_rx_data = 0;
						else if((entry->current_rx_count == SMART_CONFIG_BLOCK_FRAMES) &&
							((block_num == (blocks->current_rx_block + 1)) || (block_num == 0)))
						{
							blocks->block_map |= (1 << blocks->current_rx_block);
						}

						if(blocks->block_map & (1 << block_num))
							blocks->pending_rx_data = 1;
						else
						{
							entry = &blocks->block[block_num];
							entry->current_rx_count = 0;
						}
						
						blocks->current_rx_block = block_num;

						if(blocks->block_counter[block_num] < 255)
							blocks->block_counter[block_num]++;
						if((block_num == 0) && blocks->block_map)
						{
							for(i=(SMART_CONFIG_BLOCK_NUMS-1); i>=0; i--)
							{
								if(blocks->block_counter[i] == 0)
									continue;
								/* we expect that the rx group id conters should be closed */
								if((blocks->block_counter[0] - blocks->block_counter[i]) > 10)
									continue;
								tmp = (1 << (i+1)) - 1;
								if((tmp & blocks->block_map) == tmp)
								{
									total_group = i+1;
									ret = (unsigned char *)malloc(
													SMART_CONFIG_BLOCK_BYTES * total_group);
								}
								break;
							}
						}
					}
					else
					{
						/* do other control action */
					}
				}

				// reset the rx info
				blocks->rx_even_count = 0;
			}
		}
	}

	if(ret)	// complete all blocks
	{
		ptr = ret;

		for(i=0; i < total_group; i++)
		{
			entry = &blocks->block[i];
			for(tmp=0; tmp < SMART_CONFIG_BLOCK_FRAMES; tmp += 2)
			{
				*ptr = (entry->value[tmp] << 4) | entry->value[tmp+1];
				ptr++;
			}
		}
	}

	return ret;
}

