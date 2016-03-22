#ifndef __MIMO_CODER_H__
#define __MIMO_CODER_H__

#define SMART_CONFIG_LENGTH_BASE 	500
#define SMART_CONFIG_SHIFT			2
#define SMART_CONFIG_BLOCK_BYTES	8
#define SMART_CONFIG_BLOCK_FRAMES	SMART_CONFIG_BLOCK_BYTES*2 // one frame 4 bits
#define SMART_CONFIG_BLOCK_NUMS		13
#define SMART_CONFIG_LENGTH_MASK	0xff03	// SC info is only in bit[7:2]

#define SC_CONTROL_DATA		0x10 // BIT(4)
#define SC_EVEN_ODD			0x20 // BIT(5)

#define SC_CTL_SSID_BLOCK_0		0x00
#define SC_CTL_SSID_BLOCK_1		0x01
#define SC_CTL_SSID_BLOCK_2		0x02
#define SC_CTL_SSID_BLOCK_3		0x03
#define SC_CTL_SSID_BLOCK_4		0x04
#define SC_CTL_SSID_BLOCK_5		0x05
#define SC_CTL_SSID_BLOCK_6		0x06
#define SC_CTL_SSID_BLOCK_7		0x07
#define SC_CTL_SSID_BLOCK_8		0x08
#define SC_CTL_SSID_BLOCK_9		0x09
#define SC_CTL_SSID_BLOCK_10	0x0A
#define SC_CTL_SSID_BLOCK_11	0x0B
#define SC_CTL_SSID_BLOCK_12	0x0C


struct sc_block_entry {
	unsigned char current_rx_count;
	unsigned char value[SMART_CONFIG_BLOCK_FRAMES];
};

struct sc_rx_block {
	unsigned int block_map;
	unsigned char block_counter[SMART_CONFIG_BLOCK_NUMS];
	struct sc_block_entry block[SMART_CONFIG_BLOCK_NUMS];

	unsigned char rx_even[32];
	unsigned char rx_even_count;
	unsigned char current_rx_block;
	unsigned char pending_rx_data;
};

unsigned int* sc_encoder(unsigned char *data, int data_len);
unsigned char* sc_decoder(unsigned int data, struct sc_rx_block *blocks);

#endif