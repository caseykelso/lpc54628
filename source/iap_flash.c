/*
 * Copyright (c) 2016, Freescale Semiconductor, Inc.
 * Copyright 2016-2018 NXP
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "fsl_debug_console.h"
#include "board.h"
#include "fsl_iap.h"
#include "fsl_common.h"
#include "pin_mux.h"
#define SOFTWARE_VERSION 0x1
#include <stdio.h>
#include <stdlib.h>
#include "imageheader.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/


/*******************************************************************************
 * Prototypes
 ******************************************************************************/

/*******************************************************************************
 * Variables
 ******************************************************************************/

static uint32_t s_PageBuf[FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES / sizeof(uint32_t)];

/*******************************************************************************
 * Code
 ******************************************************************************/

/*!
* @brief Main function
*/
int main(void)
{
    uint32_t i;
    uint32_t status;
    uint32_t flashSignature[4];

    /* Board pin, clock, debug console init */
    /* attach 12 MHz clock to FLEXCOMM0 (debug console) */
    CLOCK_AttachClk(BOARD_DEBUG_UART_CLK_ATTACH);

    BOARD_InitPins_Core0();
    BOARD_BootClockPLL220M();
    BOARD_InitDebugConsole();

    PRINTF("\f\r\nIAP Flash example\r\n");
    PRINTF("\r\nWriting flash sector 1\r\n");
    /* Erase sector before writing */
    IAP_PrepareSectorForWrite(1, 1);
    IAP_EraseSector(1, 1, SystemCoreClock);
    /* Generate data to be written to flash */
    for (i = 0; i < FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES; i++)
    {
        *(((uint8_t *)(&s_PageBuf[0])) + i) = i;
    }
    /* Program sector */
    for (i = 0; i < (FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES / FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES); i++)
    {
        IAP_PrepareSectorForWrite(1, 1);
        IAP_CopyRamToFlash(FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES + (i * FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES),
                           &s_PageBuf[0], FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES, SystemCoreClock);
    }
    /* Verify sector contents */
    for (i = 0; i < (FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES / FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES); i++)
    {
        status =
            IAP_Compare(FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES + (i * FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES),
                        &s_PageBuf[0], FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES);

        if (status != kStatus_IAP_Success)
        {
            PRINTF("\r\nSector verify failed\r\n");
            break;
        }
    }

    PRINTF("\r\nErasing flash sector 1\r\n");
    IAP_PrepareSectorForWrite(1, 1);
    IAP_EraseSector(1, 1, SystemCoreClock);
    status = IAP_BlankCheckSector(1, 1);
    if (status != kStatus_IAP_Success)
    {
        PRINTF("\r\nSector erase failed\r\n");
    }

    PRINTF("\r\nErasing page 1 in flash sector 1\r\n");
    /* First write a page */
    IAP_PrepareSectorForWrite(1, 1);
    IAP_CopyRamToFlash(FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES, &s_PageBuf[0],
                       FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES, SystemCoreClock);
    /* Erase page */
    IAP_PrepareSectorForWrite(1, 1);
    IAP_ErasePage(FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES / FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES,
                  FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES / FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES,
                  SystemCoreClock);

    /* Fill page buffer with erased state value */
    for (i = 0; i < FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES; i++)
    {
        *(((uint8_t *)(&s_PageBuf[0])) + i) = 0xFF;
    }
    /* Verify Erase */
    status = IAP_Compare(FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES, (uint32_t *)(&s_PageBuf[0]),
                         FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES);
    if (status != kStatus_IAP_Success)
    {
        PRINTF("\r\nPage erase failed\r\n");
    }

#if defined(FSL_FEATURE_IAP_HAS_FLASH_EXTENDED_SIGNATURE_READ) && FSL_FEATURE_IAP_HAS_FLASH_EXTENDED_SIGNATURE_READ
    /* Read Extended Flash Signature */
    status = IAP_ExtendedFlashSignatureRead(1, 1, 0, flashSignature);
    if (status != kStatus_IAP_Success)
    {
        PRINTF("\r\nExtended read signature failed\r\n");
    }
    else
    {
        PRINTF("\r\nFlash signature value of page 1\r\n");
        PRINTF("\r\n");
        for (i = 0; i < 4; i++)
        {
            PRINTF("%X", flashSignature[i]);
        }
        PRINTF("\r\n");
    }
#endif /* FSL_FEATURE_IAP_HAS_FLASH_EXTENDED_SIGNATURE_READ */

#if defined(FSL_FEATURE_IAP_HAS_FLASH_SIGNATURE_READ) && FSL_FEATURE_IAP_HAS_FLASH_SIGNATURE_READ
    /* Read signature of the entire flash memory */
    status = IAP_ReadFlashSignature(flashSignature);
    if (status != kStatus_IAP_Success)
    {
        PRINTF("\r\nRead signature failed\r\n");
    }
    else
    {
        PRINTF("\r\nEntire flash signature\r\n");
        PRINTF("\r\n%X\r\n", flashSignature[0]);
    }
#endif /* FSL_FEATURE_IAP_HAS_FLASH_SIGNATURE_READ */

    PRINTF("\r\nEnd of IAP Flash Example\r\n");
    while (1)
    {
    }
}
