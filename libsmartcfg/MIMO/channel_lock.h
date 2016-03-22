#ifndef __MIMO_CHANNEL_LOCK_H__
#define __MIMO_CHANNEL_LOCK_H__

#define SC_LOCK_SPEC_CHAR			0x14
#define SC_LOCK_INTERVAL_LEN		0x10
#define SC_LOCK_LENGTH_BASE			400 // SMART_CONFIG_LENGTH_BASE - 100
#define SC_FRAME_TIME_INTERVAL		18	// unit: ms

#define SC_LOCK_PHASE_DATA_NUMS		256
#define SC_LOCK_PHASE_BIT_MAP_NUMS	SC_LOCK_PHASE_DATA_NUMS/32

struct lock_phase_ta {
	unsigned char addr[6];
	unsigned int bit_map[SC_LOCK_PHASE_BIT_MAP_NUMS];

	struct lock_phase_ta *next;
};

struct try_lock_data {
	unsigned int frames[SC_LOCK_PHASE_DATA_NUMS];
	unsigned int timestamp[SC_LOCK_PHASE_DATA_NUMS];
	unsigned int start_pos;
	unsigned int next_pos;
	
	struct lock_phase_ta *ta_list;
};

unsigned int* lock_stream_gen(unsigned int *stream, unsigned int base, unsigned int spec_char, unsigned int interval);
int try_lock_channel(unsigned int data, char *addr, struct try_lock_data *lock_data);
int free_lock_data(struct try_lock_data *lock_data);

#endif