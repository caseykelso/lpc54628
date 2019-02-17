#include <unistd.h>
/* Image header */
#define IMAGE_ENH_BLOCK_MARKER 0xFEEDA5A5 //0x0FFEB6B6
#define IMG_NO_CRC             0x1
#define IMG_CRC                0x0

typedef struct
{	
    uint32_t marker;
    uint32_t image_type;
    uint32_t reserved;
    uint32_t image_length;
    uint32_t crc_value;
    uint32_t version;
}imageheader_t;

const imageheader_t imageHeader = {
      IMAGE_ENH_BLOCK_MARKER,
      IMG_NO_CRC,
      0x0,   //reserved
      127388,   //crc32length
      0xdb25f78d,   //crc32value
      SOFTWARE_VERSION    //version
};

void imageheader_tostring(uint32_t address, char *string, uint32_t string_length)
{
	imageheader_t *image;
	image = (imageheader_t*)(address+0x28);

	if (0 != address && 0 != string && string_length > 200 )
	{
		sprintf(string, "marker       : 0x%08X\nimage_type   : 0x%08X\nimage_length : 0x%08X\ncrc_value    : 0x%08X\nversion      : 0x%08X\n", (unsigned int)image->marker, (unsigned int)image->image_type, (unsigned int)image->image_length, (unsigned int)image->crc_value, (unsigned int)image->version);
	}

}

void print_imageheader(uint32_t *address)
{
//	address = address + 0x28;
	imageheader_t *image = (imageheader_t*)(*address);

	printf("address of pointer to pointer for imageheader: 0x%08X\r\n", (unsigned int)address);
	printf("address of imageheader: 0x%08X\r\n", (unsigned int)*address);

	if (0 != address)
	{
		printf("marker       : 0x%08X\n", (unsigned int)image->marker);
		printf("image_type   : 0x%08X\n", (unsigned int)image->image_type);
		printf("image_length : 0x%08X\n", (unsigned int)image->image_length);
		printf("crc_value    : 0x%08X\n", (unsigned int)image->crc_value);
		printf("version      : 0x%08X\n", (unsigned int)image->version);
	}

}
