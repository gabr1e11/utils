
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int base64decode(const char *base64, uint8_t **buffer)
{
	static const char dict[256] = {
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
				52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
				-1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
				15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
				 0, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
				41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
				-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	};
	int i, j;
	uint32_t in_len  = strlen(base64);

	/* Check padding */
	if (base64[in_len-1] == '=') --in_len;
	if (base64[in_len-1] == '=') --in_len;

	uint32_t out_len = in_len*3/4;
	*buffer = malloc(out_len);
	if (!*buffer) {
		return -1;
	}

	for (i=0, j=0; i<in_len; ++i) {
		char byte = dict[base64[i]];
		if (byte == -1) {
			free(*buffer);
			return -1;
		}
		switch(i%4) {
			case 0:
				(*buffer)[j] = (byte<<2)&0xFC;
				break;
			case 1:
				(*buffer)[j]   |= (byte>>4)&0x03;
				(*buffer)[j+1] |= (byte<<4)&0xF0;
				break;
			case 2:
				(*buffer)[j+1] |= (byte>>2)&0x0F;
				(*buffer)[j+2] |= (byte<<6)&0xC0;
				break;
			case 3:
				(*buffer)[j+2] |= byte;
				j+=3;
				break;
		}

	}

	return out_len;
}

int main(int argc, char**argv)
{
	uint8_t *buffer;
	int i;

	if (argc < 2) {
		fprintf(stderr, "Usage:\n\tbase64decode <string>\n");
		exit(1);
	}
	int length = base64decode(argv[1], &buffer);
	if (length < 0) {
		fprintf(stderr, "Error decoding string %s\n", argv[1]);
		exit(1);
	}

	for (i=0; i<length; ++i) {
		printf("%02X, ", buffer[i]);
	}
	printf("\n");
	exit(0);
}
