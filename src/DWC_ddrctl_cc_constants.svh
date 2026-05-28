//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/DWC_ddrctl_cc_constants.svh#5 $
// ------------------------------------------------------------------------------
// 
// Copyright 2021 Synopsys, INC.
// 
// This Synopsys IP and all associated documentation are proprietary to
// Synopsys, Inc. and may only be used pursuant to the terms and conditions of a
// written license agreement with Synopsys, Inc. All other use, reproduction,
// modification, or distribution of the Synopsys IP or the associated
// documentation is strictly prohibited.
// 
// Component Name   : DWC_ddrctl_lpddr54
// Component Version: 1.10a-lca00
// Release Type     : LCA
// Build ID         : 139.61.96.38.TreMctl_2713
// ------------------------------------------------------------------------------


`ifndef __GUARD__DWC_DDRCTL_CC_CONSTANTS__SVH__
`define __GUARD__DWC_DDRCTL_CC_CONSTANTS__SVH__


//--------------------------------------------------------------------------
//  !!!!!!!!!!!!!
//  !  WARNING  !
//  !!!!!!!!!!!!!
// This file is auto-generated and MUST NOT be manually modified.
//--------------------------------------------------------------------------

// Name:         DDRCTL_PRODUCT_NAME
// Default:      DWC_LPDDR54_CONTROLLER (<DWC-LPDDR54-CONTROLLER feature authorize> 
//               ? 0 : ( <DWC-DDR54-CONTROLLER feature authorize> ? 1 : ( 
//               <DWC-AP-LPDDR54-CONTROLLER feature authorize> ? 2 : ( <DWC-AP-DDR54-CONTROLLER 
//               feature authorize> ? 3 : ( <DWC-LPDDR54-CONTROLLER-AFP feature 
//               authorize> ? 4 : ( <DWC-DDR54-CONTROLLER-AFP feature authorize> ? 5 :  
//               (<DWC-DDR54-CONTROLLER-CHI feature authorize> ? 6 : 
//               (<DWC-DDR54-CONTROLLER-AFP-CHI feature authorize> ? 7 :(<DWC-DDR54-LL-CONTROLLER-AFP feature 
//               authorize> ? 8 :0)))    ) ) ) ) ))
// Values:       DWC_LPDDR54_CONTROLLER (0), DWC_DDR54_CONTROLLER (1), 
//               DWC_AP_LPDDR54_CONTROLLER (2), DWC_AP_DDR54_CONTROLLER (3), 
//               DWC_LPDDR54_CONTROLLER_AFP (4), DWC_DDR54_CONTROLLER_AFP (5), DWC_DDR54_CONTROLLER_CHI (6), 
//               DWC_DDR54_CONTROLLER_AFP_CHI (7), DWC_DDR5_LL_CONTROLLER_AFP (8)
// Enabled:      (<DWC-LPDDR54-CONTROLLER feature authorize> || 
//               <DWC-DDR54-CONTROLLER feature authorize> || <DWC-AP-LPDDR54-CONTROLLER feature authorize> 
//               || <DWC-AP-DDR54-CONTROLLER feature authorize> || 
//               <DWC-LPDDR54-CONTROLLER-AFP feature authorize> || <DWC-DDR54-CONTROLLER-AFP feature 
//               authorize> || <DWC-DDR54-CONTROLLER-CHI feature authorize> || 
//               <DWC-DDR54-CONTROLLER-AFP-CHI feature authorize> || 
//               <DWC-DDR54-LL-CONTROLLER-AFP feature authorize> ) == 1
// 
// This parameter specifies the type of DDR memory controller. 
// For each product, a license is required as specified: 
//  - DWC LPDDR5/4/4X Controller              (LPDDR54)         requires DWC-LPDDR54-CONTROLLER       license. 
//  - DWC DDR5/4 Controller                   (DDR54)           requires DWC-DDR54-CONTROLLER         license. 
//  - DWC AP LPDDR5/4/4X Controller           (AP_LPDDR54)      requires DWC-AP-LPDDR54-CONTROLLER    license. 
//  - DWC AP DDR5/4 Controller                (AP_DDR54)        requires DWC-AP-DDR54-CONTROLLER      license. 
//  - DWC LPDDR5/4/4X Controller AFP          (AFP_LPDDR54)     requires DWC-LPDDR54-CONTROLLER-AFP   license. 
//  - DWC DDR5/4 Controller AFP               (AFP_DDR54)       requires DWC-DDR54-CONTROLLER-AFP     license. 
//  - DWC DDR5/4 Controller with CHI          (   TBD   )       requires DWC-DDR54-CONTROLLER-CHI     license. 
//  - DWC DDR5/4 Controller AFP with CHI      (   TBD   )       requires DWC-DDR54-CONTROLLER-AFP-CHI license. 
//  - DWC DDR5   Low Latency Controller AFP   (AFP_DDR5_LLC)    requires DWC-DDR54-LL-CONTROLLER-AFP  license.
`define DDRCTL_PRODUCT_NAME 0


`define DDRCTL_UMCTL5


// Name:         DDRCTL_ENABLE_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// Enabled:      Always
// 
// Enable internal testing cC constants.
`define DDRCTL_ENABLE_INTERNAL_TESTING 0


// Name:         MEMC_DRAM_DATA_WIDTH
// Default:      32
// Values:       8 16 24 32 40 48 56 64 72
// 
// This parameter specifies the memory data width of the DQ signal to SDRAM in bits. For HIF configurations, this can be 
// any multiple of 8, with a maximum of 72. For AXI configurations, it must be a power of 2 (8, 16, 32, 64). 
//  - If ECC is enabled, this parameter must be set to 16, 32 or 64, and the ECC byte is additional to the width specified 
//  here. 
//  - If ECC is disabled, a non-power-of-2 configuration allows you to inject your own ECC at the HIF interface if 
//  required. 
// Note that this parameter must be set to 16 or 32 in LPDDR5/4/4X Controller (Other memory data width is not supported).
`define MEMC_DRAM_DATA_WIDTH 32


// `define DDRCTL_LLC


`define DDRCTL_LLC_EN 0



// Name:         MEMC_FREQ_RATIO
// Default:      DFI 1:4 frequency ratio (DDRCTL_LLC==1 ? 2 : 4)
// Values:       DFI 1:2 frequency ratio (2), DFI 1:4 frequency ratio (4)
// Enabled:      DDRCTL_DDR==1 && DDRCTL_LLC==0
// 
// This parameter defines the DFI frequency ratio between the controller clock and the SDRAM clock.
`define MEMC_FREQ_RATIO 4


// Name:         MEMC_PROG_FREQ_RATIO
// Default:      Software Programmable Frequency Ratio
// Values:       Not Software Programmable Frequency Ratio (0), Software 
//               Programmable Frequency Ratio (1)
// Enabled:      DDRCTL_ENABLE_INTERNAL_TESTING==1
// 
// MEMC_PROG_FREQ_RATIO 
// Defines whether the frequency ratio is programmable through software. 
// If Software Programmable Frequency Ratio option is selected, you can select the frequency ratio only through software, 
// by using the TMGCFG.frequency_ratio register. 
// It needs be enabled when 1:4 frequency ratio is selected but still want to support 1:2 frequency ratio.
`define MEMC_PROG_FREQ_RATIO 1


// Name:         UMCTL2_A_DW
// Default:      256 (MEMC_FREQ_RATIO == 4) ? (8*MEMC_DRAM_DATA_WIDTH) : 
//               ((MEMC_FREQ_RATIO == 2) ? (4*MEMC_DRAM_DATA_WIDTH) : (2*MEMC_DRAM_DATA_WIDTH))
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Application Data Width
`define UMCTL2_A_DW 256


// Name:         MEMC_BURST_LENGTH
// Default:      BL16 - HIF transaction size corresponds to SDRAM burst length 16
// Values:       BL8 - HIF transaction size corresponds to SDRAM burst length 8 (8), 
//               BL16 - HIF transaction size corresponds to SDRAM burst length 16 
//               (16)
// Enabled:      DDRCTL_ENABLE_INTERNAL_TESTING==1
// 
// Defines the supported burst length. This parameter specifies the size of a transaction on the host interface (HIF). 
// This can be equivalent to a SDRAM burst length of either 8 or 16. 
// The actual SDRAM burst length to be used can be set separately, using the register MSTR0.burst_rdwr. 
// Note the following restrictions: 
//  - BL16 controller is required only for full bus width and LPDDR4 (as these support SDRAM BL=16).
`define MEMC_BURST_LENGTH 16


// Name:         DDRCTL_SYS_INTF
// Default:      Arbiter (AXI) ((MEMC_DRAM_DATA_WIDTH == 8 || MEMC_DRAM_DATA_WIDTH 
//               == 16 || MEMC_DRAM_DATA_WIDTH == 32 || MEMC_DRAM_DATA_WIDTH == 64) ? 1 
//               : 0)
// Values:       HIF (0), Arbiter (AXI) (1), CHI (2)
// 
// Select the System Interface for DDRC. 
//  - HIF : Uses DDRC's HIF IF as system Interface 
//  - Arbiter (AXI) : Uses Multi-Port AXI as the System Interface 
//  - CHI : Uses CHI as the System Interface
`define DDRCTL_SYS_INTF 1


// Name:         UMCTL2_INCL_ARB
// Default:      1 (DDRCTL_SYS_INTF == 1)
// Values:       0, 1
// Enabled:      0
// 
// This parameter adds multiport support to DWC_ddrctl. You can select this option only if the DRAM data width 
// (MEMC_DRAM_DATA_WIDTH) is a power of 2 (8, 16, 32, or 64).
`define UMCTL2_INCL_ARB


// Name:         DDRCTL_INCL_CHB
// Default:      0 (DDRCTL_SYS_INTF == 2)
// Values:       0, 1
// Enabled:      0
// 
// Adds CHI Bridge support
// `define DDRCTL_INCL_CHB


// Name:         UMCTL2_INCL_ARB_OR_CHB
// Default:      1 (DDRCTL_SYS_INTF != 0)
// Values:       0, 1
// Enabled:      0
// 
// Indicates either ARB or CHB is enabled
`define UMCTL2_INCL_ARB_OR_CHB


// Name:         DDRCTL_CHB_VERSION
// Default:      CHI-D
// Values:       CHI-C (2), CHI-D (3), CHI-E (4)
// 
// CHI Issue compliance 
// Flit attributes like TxnID width depend on this.
`define DDRCTL_CHB_VERSION 3


// Name:         DDRCTL_CHB_CHIE_EN
// Default:      0 (DDRCTL_CHB_VERSION == 4) && (DDRCTL_INCL_CHB==1)
// Values:       0, 1
// 
// CHI-E compliance
// `define DDRCTL_CHB_CHIE_EN


// Name:         DDRCTL_CHB_WRZERO_EN
// Default:      0 (DDRCTL_CHB_CHIE_EN == 1)
// Values:       0, 1
// 
// DDRCTL_CHB_CHIE_EN: 
// CHI-E write zero feature compliance
// `define DDRCTL_CHB_WRZERO_EN


// Name:         DDRCTL_CHB_TZ_EN
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB==1
// 
// Trustzone for CHI
// `define DDRCTL_CHB_TZ_EN



// Name:         DDRCTL_CHB_TSZ_SUBREG_EN
// Default:      1
// Values:       0, 1
// Enabled:      DDRCTL_CHB_TZ_EN
// 
// Trustzone controller for CHB enable subregion support
`define DDRCTL_CHB_TSZ_SUBREG_EN


// Name:         DDRCTL_CHB_TSZ_SUBREG_NUM
// Default:      4 ((DDRCTL_CHB_TSZ_SUBREG_EN==1) ? 4 : 0)
// Values:       -2147483648, ..., 8
// Enabled:      DDRCTL_CHB_TSZ_SUBREG_EN
// 
// Trustzone controller for CHB number of subregions supported
`define DDRCTL_CHB_TSZ_SUBREG_NUM 4


// Name:         DDRCTL_CHB_TSZ_REG_NUM
// Default:      4
// Values:       4 8
// Enabled:      DDRCTL_CHB_TZ_EN
// 
// Configures the number of trustzone address regions supported
`define DDRCTL_CHB_TSZ_REG_NUM 4


`define DDRCTL_CHB_TSZ_REG_0

`define DDRCTL_CHB_TSZ_REG_1

`define DDRCTL_CHB_TSZ_REG_2

`define DDRCTL_CHB_TSZ_REG_3

// `define DDRCTL_CHB_TSZ_REG_4

// `define DDRCTL_CHB_TSZ_REG_5

// `define DDRCTL_CHB_TSZ_REG_6

// `define DDRCTL_CHB_TSZ_REG_7


// Name:         DDRCTL_CHB_ADRW
// Default:      44
// Values:       44, ..., 52
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// CHB Req Flit Address Width.
`define DDRCTL_CHB_ADRW 44


// Name:         DDRCTL_CHB_CHID_EN
// Default:      0 (DDRCTL_CHB_VERSION == 3) && (DDRCTL_INCL_CHB==1)
// Values:       0, 1
// 
// CHI-D compliance
// `define DDRCTL_CHB_CHID_EN


// Name:         DDRCTL_CHB_XFRSZ
// Default:      64
// Values:       64 128
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// CHI request flit's max transfer size. 
// Set to 64B for standard CHI compliance
`define DDRCTL_CHB_XFRSZ 64


`define DDRCTL_CHB_XFRSZ_LOG2 7


// `define DDRCTL_CHB_XFRSZ_128B_EN


// Name:         DDRCTL_CHB_TXIDW
// Default:      8 ((DDRCTL_CHB_CHIE_EN==1)?12 : (DDRCTL_CHB_CHID_EN==1)? 10 : 8)
// Values:       8 10 12
// 
// TX ID Width.
`define DDRCTL_CHB_TXIDW 8


// Name:         DDRCTL_CHB_DW
// Default:      256
// Values:       128 256 512
// Enabled:      0
// 
// TxDAT and RxDAT Data Width.
`define DDRCTL_CHB_DW 256


`define DDRCTL_CHB_DW_256


// `define DDRCTL_CHB_DW_512


// Name:         DDRCTL_CHB_CHI_DW_GT_HIF_DW
// Default:      0 (DDRCTL_CHB_DW > UMCTL2_A_DW)
// Values:       0, 1
// 
// CHI data width greater than the HIF data width.
// `define DDRCTL_CHB_CHI_DW_GT_HIF_DW


`define DDRCTL_CHB_CHI_DW_GT_HIF_DW_VAL 0


// Name:         DDRCTL_CHB_CHI_DW_LT_HIF_DW
// Default:      0 (DDRCTL_CHB_DW < UMCTL2_A_DW)
// Values:       0, 1
// 
// CHI data width less than the HIF data width.
// `define DDRCTL_CHB_CHI_DW_LT_HIF_DW


`define DDRCTL_CHB_CHI_DW_LT_HIF_DW_VAL 0


// Name:         DDRCTL_CHB_HIF_TO_CHI_DW_RATIO
// Default:      1 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? UMCTL2_A_DW/DDRCTL_CHB_DW : 1)
// Values:       -2147483648, ..., 2147483647
// 
// HIF to CHI Data Width Ratio
`define DDRCTL_CHB_HIF_TO_CHI_DW_RATIO 1


// Name:         DDRCTL_CHB_CHI_TO_HIF_DW_RATIO
// Default:      1 (DDRCTL_CHB_CHI_DW_GT_HIF_DW ? DDRCTL_CHB_DW/UMCTL2_A_DW : 1)
// Values:       -2147483648, ..., 2147483647
// 
// CHI to HIF Data Width Ratio
`define DDRCTL_CHB_CHI_TO_HIF_DW_RATIO 1


// Name:         DDRCTL_CHB_DDR4F5HBW_AREA_OPT
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// Optimise the RDB RAM footprint if the DDR54 controller operates in DDR4 in FBW only and  DDR5 in HBW only.
// `define DDRCTL_CHB_DDR4F5HBW_AREA_OPT


// Name:         DDRCTL_CHB_NUM_BEATS_BL32
// Default:      4 (32/(MEMC_FREQ_RATIO*2))
// Values:       -2147483648, ..., 2147483647
// 
// Number of HIF beats per BL32.
`define DDRCTL_CHB_NUM_BEATS_BL32 4


// Name:         DDRCTL_CHB_NUM_BEATS_BL16
// Default:      2 (16/(MEMC_FREQ_RATIO*2))
// Values:       -2147483648, ..., 2147483647
// 
// Number of HIF beats per BL16.
`define DDRCTL_CHB_NUM_BEATS_BL16 2


// Name:         DDRCTL_CHB_NUM_BEATS_BL8
// Default:      1 (8/(MEMC_FREQ_RATIO*2))
// Values:       -2147483648, ..., 2147483647
// 
// Number of HIF beats per BL8.
`define DDRCTL_CHB_NUM_BEATS_BL8 1


// Name:         DDRCTL_CHB_NUM_BEATS_BL
// Default:      2 (MEMC_BURST_LENGTH==32 ? DDRCTL_CHB_NUM_BEATS_BL32 : 
//               (MEMC_BURST_LENGTH==16 ? DDRCTL_CHB_NUM_BEATS_BL16 : DDRCTL_CHB_NUM_BEATS_BL8))
// Values:       -2147483648, ..., 2147483647
// 
// Number of HIF data beats.
`define DDRCTL_CHB_NUM_BEATS_BL 2


`define DDRCTL_CHB_HIF_NUM_BEATS_1_VAL 0


`define DDRCTL_CHB_HIF_NUM_BEATS_2_VAL 1


`define DDRCTL_CHB_HIF_NUM_BEATS_4_VAL 0


`define DDRCTL_CHB_HIF_NUM_BEATS_8_VAL 0


// Name:         DDRCTL_CHB_NUM_BEATS_BL_LOG2
// Default:      1 ([ <functionof> (MEMC_BURST_LENGTH==32 ? 
//               DDRCTL_CHB_NUM_BEATS_BL32 : (MEMC_BURST_LENGTH==16 ? DDRCTL_CHB_NUM_BEATS_BL16 : 
//               DDRCTL_CHB_NUM_BEATS_BL8)) ])
// Values:       -2147483648, ..., 2147483647
// 
// Log2(DDRCTL_CHB_NUM_BEATS_BL) 
// Defines the width of the HIF read token field "ChunkNum".
`define DDRCTL_CHB_NUM_BEATS_BL_LOG2 1


// Name:         DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT
// Default:      4
// Values:       -2147483648, ..., 2147483647
// 
// Maximum number of HIF chunks per HIF beat. Occurs in QBW mode, max number of 
// chunks is 4. 
// Parameter determines the width of the HIF read command token field "ChunkStrb".
`define DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT 4


// Name:         DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT_CLOG2
// Default:      2 ([ <functionof> (4) ])
// Values:       -2147483648, ..., 2147483647
// 
// Log2(DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT)
`define DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT_CLOG2 2


// Name:         DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS
// Default:      8 (DDRCTL_CHB_NUM_BEATS_BL*DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT)
// Values:       -2147483648, ..., 2147483647
// 
// Maximum number of HIF chunks per HIF burst. Occurs in QBW mode, max number of 
// chunks is 4 times the number of beats per burst. 
// Parameter determines the width of the HIF read command token field "NumChunks".
`define DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS 8


// Name:         DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS_CLOG2
// Default:      3 ([ <functionof> 
//               (DDRCTL_CHB_NUM_BEATS_BL*DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT) ])
// Values:       -2147483648, ..., 2147483647
// 
// Log2(DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS)
`define DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS_CLOG2 3


// Name:         DDRCTL_CHB_NUM_CHI_BEATS_BL32
// Default:      4 
//               
//               (DDRCTL_CHB_CHI_DW_GT_HIF_DW?((DDRCTL_CHB_DW>=(32*MEMC_DRAM_DATA_WIDTH))?1:((32*MEMC_DRAM_DATA_WIDTH)/DDRCTL_CHB_DW)):((32*MEMC_DRAM_DATA_WIDTH)/DDRCTL_CHB_DW))
// Values:       -2147483648, ..., 2147483647
// 
// Number of CHI beats per BL32. 
// If CHI data width greather than or equal to HIF burst then number of CHI 
// beats per burst is 1. If CHI data width less than HIF burst then number of 
// CHI beats per burst is HIF burst size divided by the CHI data width.
`define DDRCTL_CHB_NUM_CHI_BEATS_BL32 4


// Name:         DDRCTL_CHB_NUM_CHI_BEATS_BL16
// Default:      2 
//               
//               (DDRCTL_CHB_CHI_DW_GT_HIF_DW?((DDRCTL_CHB_DW>=(16*MEMC_DRAM_DATA_WIDTH))?1:((16*MEMC_DRAM_DATA_WIDTH)/DDRCTL_CHB_DW)):((16*MEMC_DRAM_DATA_WIDTH)/DDRCTL_CHB_DW))
// Values:       -2147483648, ..., 2147483647
// 
// Number of CHI beats per BL16. 
// If CHI data width greather than or equal to HIF burst then number of CHI 
// beats per burst is 1. If CHI data width less than HIF burst then number of 
// CHI beats per burst is HIF burst size divided by the CHI data width.
`define DDRCTL_CHB_NUM_CHI_BEATS_BL16 2


// Name:         DDRCTL_CHB_NUM_CHI_BEATS_BL8
// Default:      1 (DDRCTL_CHB_CHI_DW_GT_HIF_DW ? (DDRCTL_CHB_DW >= 
//               (8*MEMC_DRAM_DATA_WIDTH)) ? 1 : ((8*MEMC_DRAM_DATA_WIDTH)/DDRCTL_CHB_DW) : 
//               ((8*MEMC_DRAM_DATA_WIDTH)/DDRCTL_CHB_DW))
// Values:       -2147483648, ..., 2147483647
// 
// Number of CHI beats per BL8. 
// If CHI data width greather than or equal to HIF burst then number of CHI 
// beats per burst is 1. If CHI data width less than HIF burst then number of 
// CHI beats per burst is HIF burst size divided by the CHI data width.
`define DDRCTL_CHB_NUM_CHI_BEATS_BL8 1


// Name:         DDRCTL_CHB_DIDW
// Default:      2 (((DDRCTL_CHB_XFRSZ == 128)==1) ? 3 : 2)
// Values:       -2147483648, ..., 2147483647
// 
// DataID Width.
`define DDRCTL_CHB_DIDW 2


// Name:         DDRCTL_CHB_WDPTR_BL32_DIDMW
// Default:      4 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 
//               DDRCTL_CHB_HIF_TO_CHI_DW_RATIO*DDRCTL_CHB_NUM_BEATS_BL32 : DDRCTL_CHB_CHI_DW_GT_HIF_DW ? 
//               DDRCTL_CHB_CHI_TO_HIF_DW_RATIO*DDRCTL_CHB_NUM_CHI_BEATS_BL32 : 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL32)
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the maximum number of write CHI flits per BL32.
`define DDRCTL_CHB_WDPTR_BL32_DIDMW 4


// Name:         DDRCTL_CHB_WDPTR_BL16_DIDMW
// Default:      2 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 
//               DDRCTL_CHB_HIF_TO_CHI_DW_RATIO*DDRCTL_CHB_NUM_BEATS_BL16 : DDRCTL_CHB_CHI_DW_GT_HIF_DW ? 
//               DDRCTL_CHB_CHI_TO_HIF_DW_RATIO*DDRCTL_CHB_NUM_CHI_BEATS_BL16 : 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL16)
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the maximum number of write CHI flits per BL16.
`define DDRCTL_CHB_WDPTR_BL16_DIDMW 2


// Name:         DDRCTL_CHB_WDPTR_BL8_DIDMW
// Default:      1 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 
//               DDRCTL_CHB_HIF_TO_CHI_DW_RATIO*DDRCTL_CHB_NUM_BEATS_BL8 : DDRCTL_CHB_CHI_DW_GT_HIF_DW ? 
//               DDRCTL_CHB_CHI_TO_HIF_DW_RATIO*DDRCTL_CHB_NUM_CHI_BEATS_BL8 : 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL8)
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the maximum number of write CHI flits per BL8.
`define DDRCTL_CHB_WDPTR_BL8_DIDMW 1


// Name:         DDRCTL_CHB_WDPTR_DIDMW
// Default:      2 (MEMC_BURST_LENGTH==32 ? DDRCTL_CHB_WDPTR_BL32_DIDMW : 
//               MEMC_BURST_LENGTH==16 ? DDRCTL_CHB_WDPTR_BL16_DIDMW : 
//               DDRCTL_CHB_WDPTR_BL8_DIDMW)
// Values:       -2147483648, ..., 2147483647
// 
// CHB Write Data Pointer "DataIDMask" field width. 
// Specifies the maximum number of write CHI flits per configured HIF Buffer size.
`define DDRCTL_CHB_WDPTR_DIDMW 2


// Name:         DDRCTL_CHB_RD_BL32_DIDMW
// Default:      4 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 
//               DDRCTL_CHB_HIF_TO_CHI_DW_RATIO*DDRCTL_CHB_NUM_BEATS_BL32 : DDRCTL_CHB_CHI_DW_GT_HIF_DW ? 
//               DDRCTL_CHB_CHI_TO_HIF_DW_RATIO*DDRCTL_CHB_NUM_CHI_BEATS_BL32 : 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL32)
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the maximum number of read CHI flits per BL32.
`define DDRCTL_CHB_RD_BL32_DIDMW 4


// Name:         DDRCTL_CHB_RD_BL16_DIDMW
// Default:      2 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 
//               DDRCTL_CHB_HIF_TO_CHI_DW_RATIO*DDRCTL_CHB_NUM_BEATS_BL16 : DDRCTL_CHB_CHI_DW_GT_HIF_DW ? 
//               DDRCTL_CHB_CHI_TO_HIF_DW_RATIO*DDRCTL_CHB_NUM_CHI_BEATS_BL16 : 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL16)
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the maximum number of read CHI flits per BL16.
`define DDRCTL_CHB_RD_BL16_DIDMW 2


// Name:         DDRCTL_CHB_RD_BL8_DIDMW
// Default:      1 (DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 
//               DDRCTL_CHB_HIF_TO_CHI_DW_RATIO*DDRCTL_CHB_NUM_BEATS_BL8 : DDRCTL_CHB_CHI_DW_GT_HIF_DW ? 
//               DDRCTL_CHB_CHI_TO_HIF_DW_RATIO*DDRCTL_CHB_NUM_CHI_BEATS_BL8 : 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL8)
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the maximum number of read CHI flits per BL8.
`define DDRCTL_CHB_RD_BL8_DIDMW 1


// Name:         DDRCTL_CHB_RD_DIDMW
// Default:      2 (DDRCTL_CHB_WDPTR_DIDMW)
// Values:       -2147483648, ..., 2147483647
// 
// CHB Read Request Info "DataIDMask" field width. 
// Specifies the maximum number of read CHI DAT flits per configured HIF Buffer size.
`define DDRCTL_CHB_RD_DIDMW 2


// Name:         DDRCTL_CHB_NUM_CHI_BEATS_BL32W
// Default:      3 (DDRCTL_CHB_NUM_CHI_BEATS_BL32 > 1 ? 1 + [ <functionof> 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL32 ] : 1)
// Values:       -2147483648, ..., 2147483647
// 
// "NumDataID" field width, HIF burst = BL32
`define DDRCTL_CHB_NUM_CHI_BEATS_BL32W 3


// Name:         DDRCTL_CHB_NUM_CHI_BEATS_BL16W
// Default:      2 (DDRCTL_CHB_NUM_CHI_BEATS_BL16 > 1 ? 1 + [ <functionof> 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL16 ] : 1)
// Values:       -2147483648, ..., 2147483647
// 
// "NumDataID" field width, HIF burst = BL16
`define DDRCTL_CHB_NUM_CHI_BEATS_BL16W 2


// Name:         DDRCTL_CHB_NUM_CHI_BEATS_BL8W
// Default:      1 (DDRCTL_CHB_NUM_CHI_BEATS_BL8 > 1 ? 1 + [ <functionof> 
//               DDRCTL_CHB_NUM_CHI_BEATS_BL8 ] : 1)
// Values:       -2147483648, ..., 2147483647
// 
// "NumDataID" field width, HIF burst = BL8
`define DDRCTL_CHB_NUM_CHI_BEATS_BL8W 1


// Name:         DDRCTL_CHB_WDPTR_NDIDW
// Default:      1 
//               
//               ((MEMC_BURST_LENGTH==32)?(DDRCTL_CHB_NUM_CHI_BEATS_BL32W?(MEMC_BURST_LENGTH==16):DDRCTL_CHB_NUM_CHI_BEATS_BL16W):DDRCTL_CHB_NUM_CHI_BEATS_BL8W)
// Values:       -2147483648, ..., 2147483647
// 
// CHB Write Data Pointer "NumDataID" field width.
`define DDRCTL_CHB_WDPTR_NDIDW 1


// Name:         DDRCTL_CHB_WDPTR_DIDAW
// Default:      2 (DDRCTL_CHB_DIDW)
// Values:       -2147483648, ..., 2147483647
// 
// CHB Write Data Pointer "DataIDAlgn" field width. 
// This is the Data ID value aligned to the HIF burst boundary.
`define DDRCTL_CHB_WDPTR_DIDAW 2


// Name:         DDRCTL_CHB_UPSZ_RT
// Default:      1 ((DDRCTL_CHB_HIF_TO_CHI_DW_RATIO== 2)? 2 : 
//               (DDRCTL_CHB_HIF_TO_CHI_DW_RATIO== 4)? 4 : 1)
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// DDRCTL_CHB_UPSZ_RT 
// DDRCTL CHB CHI to HIF DW RATIO 
// reuse-pragma attr IncludeInBatchScript nonDefault
`define DDRCTL_CHB_UPSZ_RT 1


// Name:         DDRCTL_CHB_CHI_HIF_RATIO_GT_2
// Default:      0 ((DDRCTL_CHB_UPSZ_RT > 2)? 1 : 0)
// Values:       0, 1
// Enabled:      DDRCTL_CHB_CHI_DW_LT_HIF_DW ? 1 : 0
// 
// DDRCTL_CHB_CHI_HIF_RATIO_GT_2 
// DDRCTL CHB CHI to HIF RATION GREATER Then 2 (4:1)
// `define DDRCTL_CHB_CHI_HIF_RATIO_GT_2


// Name:         DDRCTL_CHB_WRB_EXTRAM
// Default:      1
// Values:       0, 1
// 
// CHB Write-Reorder RAM External
`define DDRCTL_CHB_WRB_EXTRAM


// Name:         DDRCTL_CHB_NUM_WRB_RAM
// Default:      1 (DDRCTL_CHB_UPSZ_RT)
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Specifies the Number of CHB Write Buffer RAMs.
`define DDRCTL_CHB_NUM_WRB_RAM 1


// `define DDRCTL_CHB_NUM_WRB_RAM_2


// `define DDRCTL_CHB_NUM_RDB_RAM_2


// Name:         DDRCTL_CHB_RTLST_EXTRAM
// Default:      1
// Values:       0, 1
// 
// CHB Retry-List RAM is External
`define DDRCTL_CHB_RTLST_EXTRAM


// Name:         DDRCTL_CHB_RTLST_EXTRAM_TRUE
// Default:      1 ((1)==1 ? 1 : 0)
// Values:       -2147483648, ..., 2147483647
// 
// CHB Retry-List RAM is External True
`define DDRCTL_CHB_RTLST_EXTRAM_TRUE 1


// Name:         DDRCTL_CHB_RDB_EXTRAM
// Default:      1
// Values:       0, 1
// 
// CHB Read-Reorder RAM External
`define DDRCTL_CHB_RDB_EXTRAM


// Name:         DDRCTL_CHB_RD_PROTQ_SIZE
// Default:      64
// Values:       32 64 128
// 
// Protocol queues are CHB's outstanding request buffers. 
// This parameter determines the Size/Depth of the read outstanding queue in CHB
`define DDRCTL_CHB_RD_PROTQ_SIZE 64


// Name:         DDRCTL_CHB_WR_PROTQ_SIZE
// Default:      64
// Values:       32 64 128
// 
// Protocol queues are CHB's outstanding request buffers. 
// This parameter determines the Size/Depth of the write outstanding queue in CHB 
// NOTE: The setting here impacts the size of wrb sram
`define DDRCTL_CHB_WR_PROTQ_SIZE 64



// Name:         DDRCTL_CHB_SYNC_MODE
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// When selected CHI clock and CORE clock are considered synchronous.  
// DDRCTL removes synchronizers between chi_clk and core_ddrc_core_clk domains 
// Configuration applies to all CHI ports.
`define DDRCTL_CHB_SYNC_MODE 0


// `define DDRCTL_CHB_SYNC_MODE_1


// Name:         DDRCTL_CHB_RTLST_NUM_LISTS
// Default:      5
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Number of list partitions in retry-list
`define DDRCTL_CHB_RTLST_NUM_LISTS 5



// Name:         UPCTL2_EN
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Enables in-order controller. In this mode reads and writes are scheduled in order.
`define UPCTL2_EN 0


// `define UPCTL2_EN_1


// Name:         UMCTL_A_HIF
// Default:      0 ((UMCTL2_INCL_ARB_OR_CHB == 0) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// In single port mode if the multiport is not enabled 
// the application port reduces to HIF interface.
`define UMCTL_A_HIF 0


// `define UMCTL_A_HIF_1


// Name:         UMCTL2_DUAL_HIF
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_OPT_TIMING ==1 && UMCTL2_INCL_ARB == 0
// 
// Enables the support for Dual HIF command feature. 
//  - This feature converts HIF single command channel into separate HIF command channels for Read and Write commands. 
// RMW commands are performed on the Write HIF command channel. 
//  - Read/Write arbitration performed by the PA does not occur as there are 
// separate Read and Write channels for the PA to drive. 
// This feature can only be enabled if the logic to optimize timing over scheduling efficiency is enabled 
// (MEMC_OPT_TIMING==1). 
// Enabling this logic improves the SDRAM utilization, depending on your traffic profile. 
// However, it increases the overall area due to additional logic.
`define UMCTL2_DUAL_HIF 0


// `define UMCTL2_DUAL_HIF_1


// Name:         DDRCTL_DDR
// Default:      0 ((DDRCTL_PRODUCT_NAME == 1 || DDRCTL_PRODUCT_NAME == 3 || 
//               DDRCTL_PRODUCT_NAME == 5 || DDRCTL_PRODUCT_NAME == 6 || DDRCTL_PRODUCT_NAME 
//               == 7 || DDRCTL_PRODUCT_NAME == 8) ? 1 :0)
// Values:       0, 1
// Enabled:      0
// 
// Enables DDR Controller
// `define DDRCTL_DDR


`define DDRCTL_DDR_EN 0


// `define MEMC_DDR4


`define MEMC_DDR4_EN 0


// Name:         MEMC_DDR2
// Default:      1
// Values:       0, 1
// Enabled:      0
// 
// Enables DDR2 mode. 
// The value of this parameter is set to 1 for all configurations, and is shown here for completeness.
`define MEMC_DDR2


// Name:         MEMC_DDR3
// Default:      0 (DDRCTL_DDR)
// Values:       0, 1
// Enabled:      0
// 
// Enables DDR3 mode.
// `define MEMC_DDR3


`define MEMC_DDR3_EN 0


// Name:         MEMC_MOBILE
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Enables mobile DDR (mDDR, LPDDR) mode.
// `define MEMC_MOBILE


`define MEMC_MOBILE_EN 0


// Name:         DDRCTL_LPDDR
// Default:      1 ((DDRCTL_PRODUCT_NAME == 0 || DDRCTL_PRODUCT_NAME == 2 || 
//               DDRCTL_PRODUCT_NAME == 4) ? 1 :0)
// Values:       0, 1
// Enabled:      0
// 
// Enables LPDDR Controller
`define DDRCTL_LPDDR


`define DDRCTL_LPDDR_EN 1


`define MEMC_LPDDR4


`define MEMC_LPDDR4_EN 1


`define MEMC_LPDDR5


`define MEMC_LPDDR5_EN 1


// Name:         MEMC_LPDDR2
// Default:      1 (DDRCTL_LPDDR)
// Values:       0, 1
// Enabled:      0
// 
// Enables LPDDR2 mode.
`define MEMC_LPDDR2


`define MEMC_LPDDR2_EN 1


// Name:         MEMC_LPDDR3
// Default:      1 (DDRCTL_LPDDR)
// Values:       0, 1
// Enabled:      0
// 
// Enables LPDDR3 mode.
`define MEMC_LPDDR3


`define MEMC_LPDDR3_EN 1


// Name:         MEMC_NUM_RANKS
// Default:      1 ((DDRCTL_DDR == 1) ? 2 : 1)
// Values:       1 2 4
// 
// This parameter specifies the maximum number of ranks supported by DWC_ddrctl (that is, the maximum number of 
// independently-controllable chip selects).
`define MEMC_NUM_RANKS 1


// Name:         DDRCTL_MIN_M_BL
// Default:      16 ((DDRCTL_LPDDR==1) ? 16 : 8)
// Values:       4 8 16 32
// 
// Smallest legal BL value for the configuration
`define DDRCTL_MIN_M_BL 16


// Name:         DDRCTL_PBW_MODE_SUPPORT
// Default:      Full, Half & Quarter Bus Width
// Values:       Full, Half & Quarter Bus Width (0), Only Full & Half Bus Width (1), 
//               Only Full Bus Width (2)
// Enabled:      Always
// 
// Selects the supported Bus Width Mode options. 
//   0- Full, Half & Quarter bus width mode 
//   1- Only Full & Half bus width modes 
//   2- Only Full bus width mode
`define DDRCTL_PBW_MODE_SUPPORT 0


// Name:         DDRCTL_MIN_DRAM_DW
// Default:      8 ((MEMC_DRAM_DATA_WIDTH>16)&&(DDRCTL_PBW_MODE_SUPPORT==0)) ? 
//               MEMC_DRAM_DATA_WIDTH/4 : ( 
//               ((MEMC_DRAM_DATA_WIDTH>8)&&(DDRCTL_PBW_MODE_SUPPORT!=2)) ? MEMC_DRAM_DATA_WIDTH/2 : MEMC_DRAM_DATA_WIDTH)
// Values:       -2147483648, ..., 2147483647
// 
// Smallest legal programmed DRAM Data width
`define DDRCTL_MIN_DRAM_DW 8


// Name:         DDRCTL_MIN_DRAM_XSIZE
// Default:      128 (DDRCTL_MIN_DRAM_DW * DDRCTL_MIN_M_BL)
// Values:       -2147483648, ..., 2147483647
// Enabled:      THEREIS_AXI_PORT == 1
// 
// Smallest DRAM Transfer size in bits
`define DDRCTL_MIN_DRAM_XSIZE 128


// Name:         MEMC_ECC_SUPPORT
// Default:      No ECC
// Values:       No ECC (0), SECDED ECC (1), SECDED ECC + Advanced ECC X4 (3)
// Enabled:      MEMC_DRAM_DATA_WIDTH == 16 || MEMC_DRAM_DATA_WIDTH == 32 || 
//               MEMC_DRAM_DATA_WIDTH == 64
// 
// This parameter enables ECC support. 
//  
// This feature is available only when the DRAM bus width is 16, 32, or 64 bits. The following are the supported ECC 
// types: 
//  - SECDED ECC 
//  - Advanced ECC 
// ECC is available in the following modes: 
//  - Full Bus Width (FBW) 
//  - Half Bus Width (HBW) 
//  - Quarter Bus Width (QBW) 
// The following ECC codes apply for Single-beat SECDED ECC: 
//  - 64-bit SDRAM data width: SDRAM data + ECC width is 64+8 (FBW), 32+7 (HBW) and 16+6 (QBW) 
//  - 32-bit SDRAM data width: SDRAM data + ECC width is 32+7 (FBW), 16+6 (HBW) and 8+5 (QBW) 
//  - 16-bit SDRAM data width: SDRAM data + ECC width is 16+6 (FBW) and 8+5 (HBW) 
// The following ECC codes apply for Multi-beat SECDED ECC: 
//  - 64-bit SDRAM data width: SDRAM data + ECC width is 32+4 (HBW) 
//  - 32-bit SDRAM data width: SDRAM data + ECC width is 32+4 (FBW) 
// For Advanced ECC: 
//  - The ECC code always is 256+32 for Advanced ECC X4. 
//  - When the SDRAM data width is less than 64, unused bytes in the data word are padded with 0 so that ECC is calculated 
//  more than 128 data bits. 
//  - It is applicable when sideband ECC is enabled for DDR4/DDR5 RDIMM devices 
// The advanced ECC feature is under access control. For more information, contact Synopsys.
`define MEMC_ECC_SUPPORT 0


// Name:         MEMC_SIDEBAND_ECC
// Default:      0 (MEMC_ECC_SUPPORT>0)
// Values:       0, 1
// Enabled:      MEMC_ECC_SUPPORT>0
// 
// This parameter enables Sideband ECC. 
//  
// When enabled, an additional data bus for ECC is used; therefore, the actual DRAM data width is greater than 
// MEMC_DRAM_DATA_WIDTH.
// `define MEMC_SIDEBAND_ECC


`define MEMC_SIDEBAND_ECC_EN 0


// Name:         UMCTL2_ECC_TEST_MODE_EN
// Default:      0 ((UMCTL2_INCL_ARB_OR_CHB == 0 && MEMC_SIDEBAND_ECC_EN==1) ? 1 : 
//               0)
// Values:       0, 1
// Enabled:      (UMCTL2_INCL_ARB_OR_CHB == 0 && MEMC_SIDEBAND_ECC_EN==1) ? 1 : 0
// 
// UMCTL2_ECC_TEST_MODE_EN 
// Enables the ECC test_mode. Only enabled for HIF ECC configurations
// `define UMCTL2_ECC_TEST_MODE_EN


// Name:         UMCTL2_HIF_INLINE_ECC_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_ENABLE_INTERNAL_TESTING==1
// 
// Enables the support for Inline ECC feature in non-Arbiter configurations. 
// Only for Internal Testing within Synopsys.
`define UMCTL2_HIF_INLINE_ECC_INTERNAL_TESTING 0


// Name:         MEMC_INLINE_ECC
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_ECC_SUPPORT==1 && DDRCTL_LPDDR &&  UMCTL2_PARTIAL_WR==1 && 
//               UMCTL2_DUAL_HIF==0 && MEMC_BYPASS==0 && UMCTL2_DDR4_MRAM_EN==0 && 
//               MEMC_OPT_TIMING==1
// 
// This parameter enables Inline ECC. 
//  
// When enabled, an additional data bus for ECC is not required, therefore, the actual DRAM data width is equal to 
// MEMC_DRAM_DATA_WIDTH. 
//  
// ECC parity is stored with the data without using a dedicated sideband memory device. 
// This feature is under access control. For more information, contact Synopsys.
// `define MEMC_INLINE_ECC


`define MEMC_INLINE_ECC_EN 0


`define MEMC_SIDEBAND_ECC_0_OR_INLINE_ECC_1


// Name:         MEMC_LINK_ECC
// Default:      0
// Values:       0, 1
// Enabled:      ((DDRCTL_LPDDR==1) && (MEMC_FREQ_RATIO==4)) && 
//               (DDRCTL_PRODUCT_NAME==2 || DDRCTL_PRODUCT_NAME==4)
// 
// This parameter enables the support for the link ECC feature. 
// 
// `define MEMC_LINK_ECC


`define MEMC_LINK_ECC_EN 0


// Name:         MEMC_IH_TE_PIPELINE
// Default:      0 (MEMC_INLINE_ECC)
// Values:       0, 1
// Enabled:      MEMC_INLINE_ECC==1
// 
// Adds pipeline between IH and TE to optimizate timing, it can be enabled when Inline ECC is enabled.
// `define MEMC_IH_TE_PIPELINE


`define MEMC_IH_TE_PIPELINE_EN 0


// Name:         MEMC_ECCAP
// Default:      0 (MEMC_INLINE_ECC == 1 ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Enables address parity checking within Inline ECC.
// `define MEMC_ECCAP


`define MEMC_ECCAP_EN 0


// Name:         MEMC_QBUS_SUPPORT
// Default:      1 (((MEMC_DRAM_DATA_WIDTH%32==0) ||(MEMC_DRAM_DATA_WIDTH==40) 
//               ||(MEMC_DRAM_DATA_WIDTH==72)) && (DDRCTL_PBW_MODE_SUPPORT==0))
// Values:       0, 1
// Enabled:      0
// 
// Enables support for quarter-bus mode. 
// You can select this option only when the memory data width is a multiple of 32 bits.
`define MEMC_QBUS_SUPPORT


// Name:         MEMC_USE_RMW
// Default:      1
// Values:       0, 1
// Enabled:      DDRCTL_SYS_INTF !=1
// 
// This parameter enables read-modify-write commands. 
//  
// By default, this parameter is set for ECC configurations and unset for non-ECC configurations. 
// If read-modify-write commands are disabled, sub-sized write accesses of sizes less than the full memory width are not 
// allowed. 
//  - For LPDDR4 HIF configurations, if MEMC_USE_RMW is disabled, only full BL16/BL8/BC4 bursts are allowed if data masks 
//  are disabled (DBICTL.dm_en = 0). 
//  - For LPDDR4 AXI configurations, MEMC_USE_RMW must be enabled if data masks are disabled (DBICTL.dm_en = 0).
`define MEMC_USE_RMW


`define MEMC_USE_RMW_EN 1


// `define DDRCTL_XPI_PROG_SNF


`define MEMC_USE_RMW_OR_MEMC_INLINE_ECC


`define MEMC_USE_RMW_IN_1_TO_4_OR_MEMC_BURST_LENGTH_16


// Name:         UMCTL2_SBR_EN
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB_OR_CHB==1 && MEMC_ECC_SUPPORT>0 && MEMC_USE_RMW==1
// 
// This parameter enables the ECC scrubber block. 
//  
// When set, this parameter instantiates the ECC scrubber block (SBR) that executes periodic background read commands to 
// the DDRC. If enabled, 
// SBR consumes one of the ports of the Port Arbiter (PA). Internally, SBR is always the last port. ECC support must be 
// enabled to use this feature.
`define UMCTL2_SBR_EN 0


// `define UMCTL2_SBR_EN_1



// `define DDRCTL_SBECC_AND_SBR_EN


// Name:         UMCTL2_REG_SCRUB_INTERVALW
// Default:      13
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the width of the SBRCTL.scrub_interval register
`define UMCTL2_REG_SCRUB_INTERVALW 13


// Name:         DDRCTL_SBR_RMW_FIFO_DEPTH
// Default:      4
// Values:       4, ..., 32
// Enabled:       
//               MCTL2_INCL_ARB==1&&MEMC_ECC_SUPPORT>0&&MEMC_SIDEBAND_ECC==1&&UMCTL2_SBR_EN==1&&DDRCTL_UMCTL5==1
// 
// In Sideband ECC Configurations, the RMW FIFO is instantiated in the Scrubber to 
// hold the addresses of the correctable error responses.
`define DDRCTL_SBR_RMW_FIFO_DEPTH 4


// Name:         MEMC_NUM_CLKS
// Default:      1 (DDRCTL_DDR == 1 ? 4 : 1)
// Values:       1 2 3 4
// Enabled:      0
// 
// Specifies the maximum number of clocks supported by DWC_ddrctl.
`define MEMC_NUM_CLKS 1


// Name:         UMCTL2_DFI_RDDATA_PER_BYTE
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Enables support for dfi_rddata/dfi_rddata_valid data slice independence 
// per byte lane. 
// This is a new feature introduced in DFI 3.0, which also applies to DFI 3.1. 
//  
// Enable this feature only if your PHY supports it.
// `define UMCTL2_DFI_RDDATA_PER_BYTE


// Name:         UMCTL2_DFI_MASK_PER_NIBBLE
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Specifies the width of dfi_wrdata_mask per nibble 
// By default, the width of this signal is one bit per byte of DFI data. However, for PHYs supporting x4 devices, it may 
// be necessary to have a bit per nibble of DFI data.
// `define UMCTL2_DFI_MASK_PER_NIBBLE


// Name:         UMCTL2_RESET_WIDTH
// Default:      1
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the width of dfi_reset_n required for LPDDR4, and DDR4.
`define UMCTL2_RESET_WIDTH 1


// Name:         UMCTL2_PARTIAL_WR
// Default:      1 ((MEMC_BURST_LENGTH==8 && MEMC_FREQ_RATIO==4) ? 0 : 1)
// Values:       0, 1
// Enabled:      (UMCTL2_INCL_ARB==1 && MEMC_BURST_LENGTH==16 && DDRCTL_DDR==1) ? 0 
//               : 1
// 
// Enables support for partial writes. 
// A partial write is where the number of HIF write data beats is less than the number 
// required for a normal (full) write for the MEMC_BURST_LENGTH. 
//  - When UMCTL2_PARTIAL_WR = 0, the DDRC issues the number of SDRAM bursts on the DDR interface that it would for a 
//  normal (full) write, but masks the unused data phases. 
//  - When UMCTL2_PARTIAL_WR = 1, the DDRC issues the minimum number of SDRAM bursts on the DDR interface required, 
//  dependent on the number of HIF write data beats and the HIF address alignment with respect to the SDRAM Column address - as 
//  SDRAM Writes must be sent BL-aligned. 
// This additional logic impacts the achievable synthesis timing, and increases the area.
`define UMCTL2_PARTIAL_WR


`define UMCTL2_PARTIAL_WR_EN 1



// Name:         UPCTL2_POSTED_WRITE_EN
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Enables posted writes support. 
//  
// In this mode write commands are scheduled without waiting for the HIF write data to be received. 
// Data beats must be presented at the HIF before the maximum allowed delay to ensure that DDR latencies are respected. 
// The Controller is always going to assert output hif_wdata_required one clock cycle before the maximum allowed delay. 
//  
// Feature requires partial write to be enabled (UMCTL2_PARTIAL_WR = 1). 
//  
// Feature is available only in designs where arbiter is not used (UMCTL2_INCL_ARB = 0).
`define UPCTL2_POSTED_WRITE_EN 0


// `define UPCTL2_POSTED_WRITE_EN_1


// Name:         MEMC_NO_OF_ENTRY
// Default:      32
// Values:       16 32 64
// 
// This parameter specifies the depth (number of entries) of each CAM (read CAM and write CAM).
`define MEMC_NO_OF_ENTRY 32


// Name:         MEMC_NO_OF_BLK_CHANNEL
// Default:      4
// Values:       4 8 16 32
// Enabled:      (MEMC_INLINE_ECC_EN == 1) ? 1 : 0
// 
// This parameter indicates the number of blocks that can be interleaved at DDRC input (HIF).<br. 
// This parameter is enabled in Inline ECC mode.
`define MEMC_NO_OF_BLK_CHANNEL 4


`define MEMC_NO_OF_BLK_TOKEN 36


`define MEMC_BLK_TOKEN_BITS 6


`define MEMC_NO_OF_BRT 20


`define MEMC_NO_OF_BWT 20


// Name:         MEMC_BYPASS
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Enables bypass for activate and read commands.
// `define MEMC_BYPASS


// Name:         UMCTL2_VPRW_EN
// Default:      0
// Values:       0, 1
// Enabled:      (((UMCTL2_INCL_ARB==1) && (THEREIS_AXI_PORT==1)) || 
//               (UMCTL2_INCL_ARB==0))
// 
// This parameter enables Variable Priority Read (VPR) and Variable Priority Write (VPW) features. 
//  
// On the read side, this feature allows the use of VPR in addition to Low Priority Read (LPR) and High Priority Read 
// (HPR) priority classes. 
// These three priority classes are intended to be mapped to three traffic classes as follows: 
//  - HPR (High Priority Read): Low Latency 
//  - VPR (Variable Priority Read): High Bandwidth 
//  - LPR (Low Priority Read): Best Effort 
// The VPR commands start out behaving like LPR traffic. But, VPR commands have down-counting latency timers 
// associated with them. When the timer reaches 0, the commands marked with VPR are given higher priority over HPR and LPR 
// traffic. 
//  
// On the write side, this feature allows the use of two priority classes in the controller: 
//  - VPW 
//  - NPW 
// These two priority classes are intended to be mapped to two traffic classes as follows: 
//  - VPW (Variable Priority Write) High Bandwidth 
//  - NPW (Normal Priority Write): Best Effort 
// The VPW traffic class commands start out behaving like NPW traffic. But, VPW commands have down-counting latency timers 
// 
// associated with them. When the timer reaches 0, the commands marked with VPW are given higher priority over NPW traffic.
// `define UMCTL2_VPRW_EN


// Name:         UMCTL2_VPR_EN
// Default:      0 (UMCTL2_VPRW_EN == 1 ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_VPR_EN 
// Enables Variable Priority Read (VPR) 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1). 
// This feature allows the use of VPR in addition to Low Priority Read (LPR) and High Priority Read (HPR) priority 
// classes. 
// These 3 priority classes are intended to be mapped to three traffic classes as follows: 
//  - HPR (High Priority Read) - Low Latency 
//  - VPR (Variable Priority Read) - High Bandwidth 
//  - LPR (Low Priority Read) - Best Effort 
// The VPR commands start out behaving like LPR traffic. But VPR commands have down-counting latency timers 
// associated with them. When the timer reaches 0, the commands marked with VPR are given higher priority over HPR and LPR 
// traffic.
// `define UMCTL2_VPR_EN


`define UMCTL2_VPR_EN_VAL 0


// Name:         UMCTL2_VPW_EN
// Default:      0 (UMCTL2_VPRW_EN == 1 ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_VPW_EN 
// Enables Variable Priority Write (VPW). 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1). 
// This feature allows the use of two write priority classes in Controller: VPW and NPW. 
// These 2 priority classes are intended to be mapped to two traffic classes as follows: 
//  - VPW (Variable Priority Write) - High Bandwidth 
//  - NPW (Normal Priority Write) - Best Effort 
// The VPW traffic class commands start out behaving like NPW traffic. But VPW commands have down-counting latency timers 
// associated with them. When the timer reaches 0, the commands marked with VPW are given higher priority over NPW traffic.
// `define UMCTL2_VPW_EN


`define UMCTL2_VPW_EN_VAL 0


// Name:         UMCTL2_DUAL_CHANNEL
// Default:      0
// Values:       0, 1
// Enabled:      ((DDRCTL_DDR==1) || ((DDRCTL_LPDDR==1) && (MEMC_ECC_SUPPORT==0) && 
//               (UMCTL2_SBR_EN==0) && (UMCTL2_DUAL_HIF==0) && 
//               (UMCTL2_NUM_LRANKS_TOTAL<8)))
// 
// This parameter enables Dual Channel support. 
// This feature is under access control. For more information, contact Synopsys.
// `define UMCTL2_DUAL_CHANNEL


`define UMCTL2_DUAL_CHANNEL_EN 0


`define UMCTL2_NUM_DATA_CHANNEL 1


`define UMCTL2_NUM_DATA_CHANNEL_GT_0

// `define UMCTL2_NUM_DATA_CHANNEL_GT_1


// `define UMCTL2_DUAL_DATA_CHANNEL
//----------------------------------------------------------------------------

// Name:         UMCTL2_A_NPORTS
// Default:      1 (DDRCTL_INCL_CHB==1 && UMCTL2_DUAL_DATA_CHANNEL==1 ? 2 : 1)
// Values:       1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
// Enabled:       UMCTL2_INCL_ARB == 1 
// 
// When specified, this parameter includes logic to implement 1 to 16 host 
// ports. Host port 0 is always included.
`define UMCTL2_A_NPORTS 1


// Name:         UMCTL2_SHARED_AC
// Default:      0
// Values:       0, 1
// Enabled:      ( (DDRCTL_PRODUCT_NAME == 5 || DDRCTL_PRODUCT_NAME == 7) && 
//               (MEMC_CMD_RTN2IDLE==0) && (MEMC_DRAM_DATA_WIDTH <= 32) && (DDRCTL_DDR==1) && 
//               ((UMCTL2_DUAL_CHANNEL==1 && DDRCTL_DDR_DCH_HBW==0) || 
//               DDRCTL_SINGLE_INST_DUALCH==1) && UMCTL2_DUAL_HIF==0 && DDRCTL_CAPAR_RETRY==0 && 
//               UMCTL2_OCPAR_EN==0)
// 
// This parameter enables the Dual Data Channel support with Shared-AC. 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1).
// `define UMCTL2_SHARED_AC


`define UMCTL2_SHARED_AC_EN 0


`define DDRCTL_1DDRC_2DFI


`define DDRCTL_1DDRC_2DFI_EN 1


// Name:         UMCTL2_A_NPORTS_0
// Default:      1 ((UMCTL2_A_NPORTS == (0+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
`define UMCTL2_A_NPORTS_0

// Name:         UMCTL2_A_NPORTS_1
// Default:      0 ((UMCTL2_A_NPORTS == (1+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_1

// Name:         UMCTL2_A_NPORTS_2
// Default:      0 ((UMCTL2_A_NPORTS == (2+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_2

// Name:         UMCTL2_A_NPORTS_3
// Default:      0 ((UMCTL2_A_NPORTS == (3+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_3

// Name:         UMCTL2_A_NPORTS_4
// Default:      0 ((UMCTL2_A_NPORTS == (4+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_4

// Name:         UMCTL2_A_NPORTS_5
// Default:      0 ((UMCTL2_A_NPORTS == (5+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_5

// Name:         UMCTL2_A_NPORTS_6
// Default:      0 ((UMCTL2_A_NPORTS == (6+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_6

// Name:         UMCTL2_A_NPORTS_7
// Default:      0 ((UMCTL2_A_NPORTS == (7+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_7

// Name:         UMCTL2_A_NPORTS_8
// Default:      0 ((UMCTL2_A_NPORTS == (8+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_8

// Name:         UMCTL2_A_NPORTS_9
// Default:      0 ((UMCTL2_A_NPORTS == (9+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_9

// Name:         UMCTL2_A_NPORTS_10
// Default:      0 ((UMCTL2_A_NPORTS == (10+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_10

// Name:         UMCTL2_A_NPORTS_11
// Default:      0 ((UMCTL2_A_NPORTS == (11+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_11

// Name:         UMCTL2_A_NPORTS_12
// Default:      0 ((UMCTL2_A_NPORTS == (12+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_12

// Name:         UMCTL2_A_NPORTS_13
// Default:      0 ((UMCTL2_A_NPORTS == (13+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_13

// Name:         UMCTL2_A_NPORTS_14
// Default:      0 ((UMCTL2_A_NPORTS == (14+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_14

// Name:         UMCTL2_A_NPORTS_15
// Default:      0 ((UMCTL2_A_NPORTS == (15+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_n: 
// Specifies the maximum port number.
// `define UMCTL2_A_NPORTS_15


// Name:         UMCTL2_PORT_0
// Default:      1 ((UMCTL2_A_NPORTS >= (0+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
`define UMCTL2_PORT_0

// Name:         UMCTL2_PORT_1
// Default:      0 ((UMCTL2_A_NPORTS >= (1+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_1

// Name:         UMCTL2_PORT_2
// Default:      0 ((UMCTL2_A_NPORTS >= (2+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_2

// Name:         UMCTL2_PORT_3
// Default:      0 ((UMCTL2_A_NPORTS >= (3+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_3

// Name:         UMCTL2_PORT_4
// Default:      0 ((UMCTL2_A_NPORTS >= (4+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_4

// Name:         UMCTL2_PORT_5
// Default:      0 ((UMCTL2_A_NPORTS >= (5+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_5

// Name:         UMCTL2_PORT_6
// Default:      0 ((UMCTL2_A_NPORTS >= (6+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_6

// Name:         UMCTL2_PORT_7
// Default:      0 ((UMCTL2_A_NPORTS >= (7+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_7

// Name:         UMCTL2_PORT_8
// Default:      0 ((UMCTL2_A_NPORTS >= (8+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_8

// Name:         UMCTL2_PORT_9
// Default:      0 ((UMCTL2_A_NPORTS >= (9+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_9

// Name:         UMCTL2_PORT_10
// Default:      0 ((UMCTL2_A_NPORTS >= (10+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_10

// Name:         UMCTL2_PORT_11
// Default:      0 ((UMCTL2_A_NPORTS >= (11+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_11

// Name:         UMCTL2_PORT_12
// Default:      0 ((UMCTL2_A_NPORTS >= (12+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_12

// Name:         UMCTL2_PORT_13
// Default:      0 ((UMCTL2_A_NPORTS >= (13+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_13

// Name:         UMCTL2_PORT_14
// Default:      0 ((UMCTL2_A_NPORTS >= (14+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_14

// Name:         UMCTL2_PORT_15
// Default:      0 ((UMCTL2_A_NPORTS >= (15+1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_PORT_n: 
// Defined if port n is enabled regardless of port TYPE
// `define UMCTL2_PORT_15


// Name:         UMCTL2_A_NPORTS_GT_0
// Default:      1 ((UMCTL2_A_NPORTS > 0) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
`define UMCTL2_A_NPORTS_GT_0

// Name:         UMCTL2_A_NPORTS_GT_1
// Default:      0 ((UMCTL2_A_NPORTS > 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_1

// Name:         UMCTL2_A_NPORTS_GT_2
// Default:      0 ((UMCTL2_A_NPORTS > 2) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_2

// Name:         UMCTL2_A_NPORTS_GT_3
// Default:      0 ((UMCTL2_A_NPORTS > 3) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_3

// Name:         UMCTL2_A_NPORTS_GT_4
// Default:      0 ((UMCTL2_A_NPORTS > 4) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_4

// Name:         UMCTL2_A_NPORTS_GT_5
// Default:      0 ((UMCTL2_A_NPORTS > 5) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_5

// Name:         UMCTL2_A_NPORTS_GT_6
// Default:      0 ((UMCTL2_A_NPORTS > 6) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_6

// Name:         UMCTL2_A_NPORTS_GT_7
// Default:      0 ((UMCTL2_A_NPORTS > 7) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_7

// Name:         UMCTL2_A_NPORTS_GT_8
// Default:      0 ((UMCTL2_A_NPORTS > 8) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_8

// Name:         UMCTL2_A_NPORTS_GT_9
// Default:      0 ((UMCTL2_A_NPORTS > 9) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_9

// Name:         UMCTL2_A_NPORTS_GT_10
// Default:      0 ((UMCTL2_A_NPORTS > 10) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_10

// Name:         UMCTL2_A_NPORTS_GT_11
// Default:      0 ((UMCTL2_A_NPORTS > 11) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_11

// Name:         UMCTL2_A_NPORTS_GT_12
// Default:      0 ((UMCTL2_A_NPORTS > 12) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_12

// Name:         UMCTL2_A_NPORTS_GT_13
// Default:      0 ((UMCTL2_A_NPORTS > 13) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_13

// Name:         UMCTL2_A_NPORTS_GT_14
// Default:      0 ((UMCTL2_A_NPORTS > 14) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_14

// Name:         UMCTL2_A_NPORTS_GT_15
// Default:      0 ((UMCTL2_A_NPORTS > 15) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// UMCTL2_A_NPORTS_GT_n: 
// Specify if the number of ports is greater than n
// `define UMCTL2_A_NPORTS_GT_15

 
// Name:         UMCTL2_A_TYPE_0
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_0 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_0 3
 
// Name:         UMCTL2_A_TYPE_1
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_1 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_1 3
 
// Name:         UMCTL2_A_TYPE_2
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_2 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_2 3
 
// Name:         UMCTL2_A_TYPE_3
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_3 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_3 3
 
// Name:         UMCTL2_A_TYPE_4
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_4 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_4 3
 
// Name:         UMCTL2_A_TYPE_5
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_5 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_5 3
 
// Name:         UMCTL2_A_TYPE_6
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_6 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_6 3
 
// Name:         UMCTL2_A_TYPE_7
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_7 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_7 3
 
// Name:         UMCTL2_A_TYPE_8
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_8 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_8 3
 
// Name:         UMCTL2_A_TYPE_9
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_9 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_9 3
 
// Name:         UMCTL2_A_TYPE_10
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_10 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_10 3
 
// Name:         UMCTL2_A_TYPE_11
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_11 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_11 3
 
// Name:         UMCTL2_A_TYPE_12
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_12 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_12 3
 
// Name:         UMCTL2_A_TYPE_13
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_13 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_13 3
 
// Name:         UMCTL2_A_TYPE_14
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_14 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_14 3
 
// Name:         UMCTL2_A_TYPE_15
// Default:      AXI4
// Values:       AXI4 (3)
// Enabled:      UMCTL2_PORT_15 == 1 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the interface type for the controller; 
// application port n.
`define UMCTL2_A_TYPE_15 3


`define THEREIS_AXI_PORT 1


`define THEREIS_AXI4_PORT 1


`define THEREIS_AHB_PORT 0

//----------------------------------------------------------------------------

// Name:         UMCTL2_NUM_DFI
// Default:      2 (((DDRCTL_1DDRC_2DFI == 1) || (UMCTL2_DUAL_CHANNEL == 1)) ? 2 : 
//               1)
// Values:       1, 2
// Enabled:      0
// 
// It is an internal parameter provided in the GUI for information purposes. 
// For DWC DDR5/4 Controller 
//    This parameter specifies the number of DFI interfaces depending on UMCTL2_DUAL_CHANNEL. 
//    1: Single channel configuration 
//    2: Dual channel or Shared-AC configuration 
//  
// For DWC LPDDR5/4/4X Controller 
// This parameter specifies the number of DFI interfaces depending on UMCTL2_DUAL_CHANNEL and MEMC_DRAM_DATA_WIDTH. 
//    1: Single DDRC Single DFI configuration (MEMC_DRAM_DATA_WIDTH==16 and UMCTL2_DUAL_CHANNEL==0) 
//    2: Single DDRC Dual   DFI configuration (MEMC_DRAM_DATA_WIDTH==32 or  UMCTL2_DUAL_CHANNEL==1) 
//    Note that Dual DDRC Dual DFI configuration (i.e.Dual Channel configuration) is not supported.
`define UMCTL2_NUM_DFI 2


`define UMCTL2_DFI_0

`define UMCTL2_DFI_1


`define UMCTL2_DUAL_DFI


`define UMCTL2_PHY_0


// `define UMCTL2_PHY_1


// `define UMCTL2_LPDDR4_DUAL_CHANNEL


// Name:         UMCTL2_DATA_CHANNEL_INTERLEAVE_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_DUAL_DATA_CHANNEL==1 || UMCTL2_SHARED_AC==1) && 
//               (UMCTL2_INCL_ARB == 1))
// 
// Enables the Data Channel interleaving in XPI: 
//  - When enabled, each port drives dynamically both data channels based on the address. 
//  - When disabled, each port statically drives only one data channel based on software settings. 
// This feature is available only in designs where Shared-AC, DDR4 or LPDDR4 Dual Channel is used.
`define UMCTL2_DATA_CHANNEL_INTERLEAVE_EN 0


// `define UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1


// Name:         UMCTL2_OCPAR_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_INCL_ARB==1) && (UMCTL2_WDATA_EXTRAM==1))
// 
// This parameter enables the On-Chip Parity feature. 
//  
// When enabled, the controller instantiates the necessary logic to enable on-chip parity protection: address and data 
// paths. 
//  
// This feature is available only in designs where the arbiter is used (UMCTL2_INCL_ARB=1) and external WDATA RAM is used 
// (UMCTL2_WDATA_EXTRAM=1).
`define UMCTL2_OCPAR_EN 0


// `define UMCTL2_OCPAR_EN_1



// Name:         UMCTL2_OCECC_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((UMCTL2_INCL_ARB==1) && (THEREIS_PORT_DSIZE==0) && 
//               (THEREIS_PORT_USIZE==0) && (UMCTL2_DUAL_CHANNEL==0) && (DDRCTL_PRODUCT_NAME==2) && 
//               (UMCTL2_OCPAR_EN==0) && (MEMC_INLINE_ECC==1) && 
//               (UMCTL2_WDATA_EXTRAM==1))
// 
// This parameter enables the On-Chip ECC feature. 
//  
// When enabled, the controller instantiates necessary logic to enable on-chip ECC protection. 
//  
// This feature is available only in designs where the Arbiter is used (UMCTL2_INCL_ARB=1); there are no upsized or 
// downsized ports, Inline-ECC (MEMC_INLINE_ECC=1) and external WDATA RAM (UMCTL2_WDATA_EXTRAM=1) are used. 
//  
// This feature is not supported if the following conditions are true: 
//  - OCPAR is enabled. 
//  - Dual Channel is enabled. 
// This feature is under access control. For more information, contact Synopsys.
`define UMCTL2_OCECC_EN 0


// `define UMCTL2_OCECC_EN_1


// Name:         DDRCTL_OCSAP_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((DDRCTL_PRODUCT_NAME==2) && ((UMCTL2_OCPAR_EN==1) || 
//               (UMCTL2_OCECC_EN==1)) && (MEMC_INLINE_ECC==1))
// 
// This parameter enables the On-Chip SRAM Address Protection . 
//  
// When enabled, the controller instantiates necessary logic to enable external On-Chip external SRAM Address Protection. 
//  
// This feature is reserved only for the automotive product with either support for OCECC (UMCTL2_OCECC_EN=1) or OCPAR 
// (UMCTL2_OCPAR_EN=1).
`define DDRCTL_OCSAP_EN 0


// `define DDRCTL_OCSAP_EN_1


// `define UMCTL2_OCECC_FEC_EN


// `define UMCTL2_OCPAR_OR_OCECC_EN_1


// Name:         UMCTL2_REGPAR_EN
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_LPDDR==1 && DDRCTL_PRODUCT_NAME==2
// 
// This parameter enables the Register Parity feature. 
//  
// When enabled, the controller instantiates the necessary logic to enable register parity protection. 
// This feature is under access control. For more information, contact Synopsys.
`define UMCTL2_REGPAR_EN 0


// `define UMCTL2_REGPAR_EN_1


// Name:         UMCTL2_REGPAR_TYPE
// Default:      1 bit parity, calculated for all 32 bits
// Values:       1 bit parity, calculated for all 32 bits (0), 4 bit parity, one 
//               parity bit for each byte (1)
// Enabled:      UMCTL2_REGPAR_EN==1
// 
// This parameter is the Register Parity type: 
//  - 0: 1 bit parity, calculated for all 32 bits 
//  - 1: 4 bit parity, one parity bit for each byte
`define UMCTL2_REGPAR_TYPE 0


`define UMCTL2_REGPAR_TYPE_0


// Name:         UMCTL2_OCCAP_DDRC_INTERNAL_TESTING
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_ENABLE_INTERNAL_TESTING==1
// 
// UMCTL2_DDRC_OCCAP_INTERNAL_TESTING: 
// Enables the support for OCCAP in non-Arbiter configs. 
// Only for Internal Testing within Synopsys.
`define UMCTL2_OCCAP_DDRC_INTERNAL_TESTING 0


// Name:         UMCTL2_OCCAP_EN
// Default:      0
// Values:       0, 1
// Enabled:      (((UMCTL2_INCL_ARB==1 && UMCTL2_DUAL_CHANNEL==0) || 
//               UMCTL2_OCCAP_DDRC_INTERNAL_TESTING==1) && DDRCTL_PRODUCT_NAME==2)
// 
// This parameter enables the On-Chip Command/Address Path Protection feature. 
//  
// When enabled, the controller instantiates necessary logic to enable on-chip command and address protection. 
// This feature is under access control. For more information, contact Synopsys.
`define UMCTL2_OCCAP_EN 0


// `define UMCTL2_OCCAP_EN_1


// Name:         UMCTL2_OCCAP_PIPELINE
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_OCCAP_EN==1 && DDRCTL_INCL_CHB==0
// 
// Enable Pipelining for checkers of On-Chip Command/Address Protection feature 
//  
// Also includes an additional pipeline for parity checker in rd_ie_rdata_ctl module when OCPAR/OCECC is enabled with 
// Inline ECC. 
// 
// `define UMCTL2_OCCAP_PIPELINE


`define UMCTL2_OCCAP_PIPELINE_EN 0


// Name:         MEMC_CMD_RTN2IDLE
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_DDR==1
// 
// Setting this parameter ensures that NOPs are sent on the DFI bus for all cycles where no other valid command is being 
// sent. 
//  
// In other cases, it is recommended to disable this parameter to avoid unnecessary toggling of pads and therefore reduce 
// power. 
//  
// Notes: 
//  - This parameter is only applicable for designs supporting DDR4 SDRAM memories (This parameter does not apply to DDR5 
//  and regardless of the parameter value, DDR5 CA interface always returns to idle. Because DDR5 CA is VDDQ terminated, the 
//  idle state is HIGH). 
//  - If this parameter is enabled, 2T mode is not supported.
// `define MEMC_CMD_RTN2IDLE


`define MEMC_CMD_RTN2IDLE_EN 0


// Name:         MEMC_OPT_TIMING
// Default:      1
// Values:       0, 1
// Enabled:      Always
// 
// Instantiates logic to optimize timing over scheduling efficiency. 
//  
// When enabled, this parameter has the following effects on the design: 
//    - Write enable signals are flopped in the Write Unit (WU), adding one cycle of latency from write data arriving to 
//    the write being eligible for service. 
//    - The Input Handler (IH) FIFO has flopped outputs, with the address mapping logic located before the FIFO, directly 
//    on the HIF address input (hif_cmd_addr). This has the effect of easing the internal timing paths, but increases the 
//    combinational logic on the HIF address bus input (for HIF configurations) or between the XPI/PA and the HIF address bus (for AXI 
//    configurations). 
//    - The address registers at the output of the IH FIFO are duplicated to reduce the loading.
`define MEMC_OPT_TIMING


`define MEMC_OPT_TIMING_EN 1


// Name:         DDRCTL_DDR_DUAL_CHANNEL
// Default:      0 ((DDRCTL_DDR==1) && (UMCTL2_DUAL_CHANNEL==1))
// Values:       0, 1
// Enabled:      0
// 
// DDRCTL_DDR_DUAL_CHANNEL 
// Enables DUAL CHANNEL feature in DDR5.
// `define DDRCTL_DDR_DUAL_CHANNEL


// Name:         DDRCTL_DDR_DCH_HBW
// Default:      0 ((DDRCTL_DDR_DUAL_CHANNEL == 1) ? 1 : 0)
// Values:       0 1
// Enabled:      DDRCTL_DDR_DUAL_CHANNEL == 1
// 
// Enables half bus width operation for DFI data signals in DDR dual channel configurations 
//  - When this is 0, output full bus width signals from both channels to DFI data interface 
//  - When this is 1, output half bus width signals from both channels to DFI data interface
`define DDRCTL_DDR_DCH_HBW 0


// Name:         MEMC_OPT_WDATARAM
// Default:      0 (DDRCTL_DDR_DCH_HBW == 1 ? 1 : 0)
// Values:       0, 1
// Enabled:      DDRCTL_DDR_DCH_HBW == 1
// 
// This parameter enable optimization of Write Data SRAM size. 
//  
// When the following conditions are ture, this feature can be enabled. 
//  - DDR dual channel configuration 
//  - When DDR4 mode, select programmable single channel mode with full bus width mode 
//  - When DDR5 mode, select programmable dual channel mode with half bus width mode
// `define MEMC_OPT_WDATARAM


// Name:         MEMC_REG_DFI_OUT
// Default:      1
// Values:       0, 1
// Enabled:      MEMC_ECC_SUPPORT == 0
// 
// This parameter enables registering of all DFI output signals. 
//  
// By default, all the DFI output signals are registered to ensure that timing on the DFI interface is easily met. 
// However, by setting this parameter to 0, it is possible to remove this registering stage, which improves the latency through the 
// controller by one cycle. Set this parameter to 0 only if it can be guaranteed that the synthesis timing of the DFI output 
// signals between controller and PHY can be met in a single cycle. 
//  
// If ECC support is desired (MEMC_ECC_SUPPORT > 0), the DFI outputs are required to be registered (MEMC_REG_DFI_OUT = 1). 
// 
//  
// It is possible to exclude DFI Write data signals from the registering stage by setting MEMC_REG_DFI_OUT_WR_DATA to 0. 
// For more information, see the "Latency Analysis" section in Appendix B, "Controller Performance Details".
`define MEMC_REG_DFI_OUT


// Name:         MEMC_REG_DFI_OUT_WR_DATA
// Default:      1 (MEMC_REG_DFI_OUT==1 ? 1 : 0)
// Values:       0, 1
// Enabled:      MEMC_REG_DFI_OUT == 1
// 
// This parameter enables registering of DFI write data outputs. 
//  
// By default, all the DFI outputs are registered to ensure that timing on the DFI interface is easily met. However, by 
// setting this parameter to 0, it is possible to remove the registering stage of the DFI Write data signals (dfi_wrdata_en, 
// dfi_wrdata and dfi_wrdata_mask), while maintaining the registering stage of all the other DFI output signals. Set this 
// parameter to 0 only if DFI Write Data signals can meet the single cycle synthesis timing requirement between the controller and 
// the PHY. This parameter has a meaning only when MEMC_REG_DFI_OUT is set to 1.
`define MEMC_REG_DFI_OUT_WR_DATA


`define MEMC_REG_DFI_OUT_VAL 1


`define MEMC_REG_DFI_OUT_WR_DATA_VAL 1


`define MEMC_REG_DFI_OUT_WR_DATA_VAL_EQ_1


`define MEMC_REG_DFI_OUT_OR_DDRCTL_DDR


// Name:         UMCTL2_WDATA_EXTRAM
// Default:      1
// Values:       0, 1
// 
// This parameter specifies the controller to use external or internal SRAM for write data.
`define UMCTL2_WDATA_EXTRAM


// Name:         DDRCTL_WDATARAM_WR_LATENCY
// Default:      0
// Values:       0 1
// Enabled:      ((UMCTL2_WDATA_EXTRAM == 1) && (DDRCTL_DDR == 1))
// 
// This parameter specifies the number of clock cycles for external Write Data SRAM write that can be delayed before 
// actually written to
`define DDRCTL_WDATARAM_WR_LATENCY 0


// Name:         DDRCTL_WDATARAM_RD_LATENCY
// Default:      1
// Values:       1 2
// Enabled:      ((UMCTL2_WDATA_EXTRAM == 1) && (DDRCTL_DDR == 1))
// 
// This parameter specifies the number of clock cycles from external Write Data SRAM read address to read data at DDRCTL 
// I/F
`define DDRCTL_WDATARAM_RD_LATENCY 1


// `define DDRCTL_WDATARAM_RD_LATENCY_2


`define UMCTL2_MAX_CMD_DELAY 3


`define UMCTL2_CMD_DELAY_BITS 2


// `define MEMC_DRAM_DATA_WIDTH_72_OR_MEMC_SIDEBAND_ECC


// `define MEMC_DRAM_DATA_WIDTH_40_OR_72_OR_MEMC_SIDEBAND_ECC


// `define MEMC_DRAM_DATA_WIDTH_40_OR_72


// Name:         UMCTL2_DQ_MAPPING
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// This parameter enables DQ mapping for CRC.
// `define UMCTL2_DQ_MAPPING



// Name:         UMCTL2_DDR4_MRAM_EN
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_ENABLE_INTERNAL_TESTING==1
// 
// Enables DDR4 support for Spin Torque MRAM (ST-MRAM). 
// This feature is under access control. For more information, contact Synopsys.
// `define UMCTL2_DDR4_MRAM_EN


// Name:         DDRCTL_LUT_ADDRMAP_CS_WIN_BITS
// Default:      5
// Values:       3 4 5
// Enabled:      DDRCTL_LUT_ADDRMAP_EN == 1
// 
// Provide number of bits used for het rank cs map
`define DDRCTL_LUT_ADDRMAP_CS_WIN_BITS 5


// Name:         DDRCTL_LUT_ADDRMAP
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR5 == 1 && MEMC_NUM_RANKS_GT_1 == 1
// 
// Determine whether het rank cs mapping is enabled
// `define DDRCTL_LUT_ADDRMAP


`define DDRCTL_LUT_ADDRMAP_EN 0


// Name:         UMCTL2_HET_RANK
// Default:      0 (((UMCTL2_DDR4_MRAM_EN && (MEMC_NUM_RANKS > 1)) || 
//               (DDRCTL_LUT_ADDRMAP_EN == 1)) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Provides heterogeneous density ranks support.
// `define UMCTL2_HET_RANK


`define UMCTL2_HET_RANK_EN 0


//x// previous Enabled  condition (@UMCTL2_SHARED_AC==0 && @UMCTL2_DUAL_CHANNEL==0 && @DDRCTL_DDR==1 && @UMCTL2_DDR4_MRAM_EN==0 && @UMCTL2_CID_WIDTH==0 && (@MEMC_NUM_RANKS>1) && @MEMC_INLINE_ECC==0 && @UPCTL2_EN == 0)

// Name:         UMCTL2_HET_RANK_DDR34
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// Provides heterogeneous density ranks support for DDR4 protocls in limited usage case.
// `define UMCTL2_HET_RANK_DDR34




// `define UMCTL2_HET_RANK_RFC


// `define UMCTL2_DDR4_MRAM_EN_OR_HET_RANK_RFC


`define DDRCTL_NUM_ADDR_MAP 1


`define DDRCTL_DFI_CID_WIDTH 3


// Name:         UMCTL2_CID_WIDTH
// Default:      [CID width=0] No DDR5/4 3DS support
// Values:       [CID width=0] No DDR5/4 3DS support (0), [CID width=1] - DDR5/4 3DS 
//               support up to 2H (1), [CID width=2] - DDR5/4 3DS support up to 4H 
//               (2), [CID width=3] - DDR5 3DS support up to 8H/DDR4 3DS support up to 
//               4H (3), [CID width=4] - DDR5 3DS support up to 16H/DDR4 3DS support up 
//               4H (4)
// Enabled:      DDRCTL_DDR==1
// 
// This parameter specifies the width of Chip ID (dfi_cid) for DDR54 3DS support. Set this to 0 if DDR54 3DS is not used. 
//  
// This feature is under access control. For more information, contact Synopsys.
`define UMCTL2_CID_WIDTH 0


// `define UMCTL2_CID_EN


`define UMCTL2_MAX_NUM_STACKS 1


// Name:         UMCTL2_NUM_LRANKS_TOTAL
// Default:      1 ((MEMC_NUM_RANKS < UMCTL2_MAX_NUM_STACKS) ? UMCTL2_MAX_NUM_STACKS 
//               : MEMC_NUM_RANKS)
// Values:       1 2 4 8 16 32 64
// Enabled:      UMCTL2_CID_WIDTH>0
// 
// This parameter specifies the maximum number of logical ranks supported by the controller. The minimum value is equal to 
// MEMC_NUM_RANKS.
`define UMCTL2_NUM_LRANKS_TOTAL 1


// Name:         UMCTL2_CG_EN
// Default:      1
// Values:       0, 1
// Enabled:      0
// 
// This parameter enables clock gating. 
//  
// Set this parameter to 1 if clock gating is enabled during synthesis. When set to 1, this parameter increases the 
// proportion of registers that have clock gating implemented. When set to 1, some gates are added in front of some registers in 
// the design as data enables. 
// These data enables are added to facilitate the insertion of clock gating by the synthesis tool. 
// Set this parameter to 0 if clock gating 
// is not enabled during synthesis. Setting this parameter to 1 and not enabling clock gating during synthesis causes a 
// small negative impact on timing and area.
`define UMCTL2_CG_EN 1


`define UMCTL2_CG_EN_1


// Name:         UMCTL2_RTL_ASSERTIONS_ALL_EN
// Default:      1
// Values:       0, 1
// 
// This parameter enables all user executable RTL SystemVerilog assertions. 
// This 
// parameter is enabled by default; it is recommended to keep it enabled, especially in your testbenches. 
// These assertions are helpful to identify unexpected input stimulus, wrong register values and bad 
// programming sequences that can commonly occur in your environments. 
//  
// You can disable this parameter, if the RTL fails when running gate-level simulations or when using 
// unsupported simulators.
`define UMCTL2_RTL_ASSERTIONS_ALL_EN

//x//reuse-pragma attr EnumValues 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15

// Name:         UMCTL2_FREQUENCY_NUM
// Default:      1
// Values:       1 2 3 4
// Enabled:      Always
// 
// This parameter specifies the number of operational frequencies.
`define UMCTL2_FREQUENCY_NUM 1


// Name:         UMCTL2_FAST_FREQUENCY_CHANGE
// Default:      0 ((UMCTL2_FREQUENCY_NUM > 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Provides optional hardware to enable fast frequency change.
// `define UMCTL2_FAST_FREQUENCY_CHANGE


`define UMCTL2_FAST_FREQUENCY_CHANGE_EN 0


// Name:         UMCTL2_HWFFC_EN
// Default:      0
// Values:       0, 1
// Enabled:      (DDRCTL_LPDDR==1) && (DDRCTL_PRODUCT_NAME==4) && 
//               (UMCTL2_FREQUENCY_NUM>1)
// 
// This parameter provides optional hardware to enable Hardware Fast Frequency Change.
// `define UMCTL2_HWFFC_EN


`define UMCTL2_HWFFC_EN_VAL 0


// `define UMCTL2_AUTO_LOAD_MR


// Name:         UMCTL2_DFI_PHYUPD_WAIT_IDLE
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_SHARED_AC == 0 && UMCTL2_DUAL_CHANNEL == 0 && DDRCTL_DDR == 
//               1 && UMCTL2_HWFFC_EN == 0 && UMCTL2_DDR4_MRAM_EN==0 && 
//               DDRCTL_CAPAR_RETRY==0
// 
// When selected, provides optional hardware to wait for all banks of all ranks to be Idle prior to handshaking of 
// dfi_phyupd_req/dfi_phyupd_ack.
// `define UMCTL2_DFI_PHYUPD_WAIT_IDLE

`ifndef SYNTHESIS
 `define ASSERT_MSG_LABELED(label) `"ERROR: Assertion 'label' failed`"
// Assertion with message reporting, to be used inside a module.
// Add trailing ; where the macro is used


  // Concurrent assertion synchronous to core clock:
  `define assert_coreclk(label,when) \
          label : assert property (@(core_ddrc_core_clk) disable iff (!core_ddrc_rstn || (core_ddrc_rstn === 1'bx)) when) else \
          $display(`ASSERT_MSG_LABELED(label))

  `define assert_yyclk(label,when) \
          label : assert property (@(co_yy_clk) disable iff (!core_ddrc_rstn || (core_ddrc_rstn === 1'bx)) when) else \
          $display(`ASSERT_MSG_LABELED(label))

  `define assert_rise_coreclk(label,when) \
          label : assert property (@(posedge core_ddrc_core_clk) disable iff (!core_ddrc_rstn) when) else \
          $display(`ASSERT_MSG_LABELED(label))

   // Concurrent assertion to check Xs:
  `define assert_x_value(label,data_valid,data) \
          label : assert property ( @(posedge clk) disable iff (!rst_n || (rst_n === 1'bx)) ((data_valid==1'b1) |-> (^data !== 1'bx)) ) else \
          $display(`ASSERT_MSG_LABELED(label))

  // more templates can be added here
  `define SNPS_SVA_MSG(_severity, _msg)\
    begin \
      $display($sformatf("%t %m SNPS SVA checker: %0s %0s", $time, _severity, _msg)); \
    end


`endif //  `ifndef SYNTHESIS


// ----------------------------------------------------------------------------
// HIDDEN MACROS:


// Name:         MEMC_DEBUG_PINS
// Default:      0
// Values:       0, 1
// 
// MEMC_DEBUG_PINS 
// Include debug pins
// `define MEMC_DEBUG_PINS


// Name:         MEMC_PERF_LOG_ON
// Default:      0
// Values:       0, 1
// 
// Enables performance logging interface. 
//  
// When enabled, the performance logging signals are added to the list of output ports of the IIP.
// `define MEMC_PERF_LOG_ON


// Name:         MEMC_USE_XVP
// Default:      0
// Values:       0, 1
// 
// Use eXecutable Verification Plan flow
`define MEMC_USE_XVP 0


// Name:         MEMC_A2X_HW_LP_PINS
// Default:      0
// Values:       0, 1
// 
// MEMC_A2X_HW_LP_PINS 
// Include debug pins
// `define MEMC_A2X_HW_LP_PINS


// Name:         UMCTL2_REF_RDWR_SWITCH
// Default:      0 ((MEMC_NUM_RANKS > 1) ? 1 : 0)
// Values:       0, 1
// 
// UMCTL2_REF_RDWR_SWITCH_EN: 
// Enables switch to change RD/WR direction if there are no valid commands to a rank different from the one being 
// refreshed.
// `define UMCTL2_REF_RDWR_SWITCH


// Name:         UMCTL2_REF_RDWR_SWITCH_EN
// Default:      0 ((UMCTL2_REF_RDWR_SWITCH==1) ? 1 : 0)
// Values:       0 1
// 
// UMCTL2_REF_RDWR_SWITCH: 
// Enables switch to change RD/WR direction if there are no valid commands to a rank different from the one being 
// refreshed.
`define UMCTL2_REF_RDWR_SWITCH_EN 0


// Name:         PIPELINE_REF_RDWR_SWITCH
// Default:      1
// Values:       0, 1
// 
// Enables pipelining of the path related to UMCTL2_REF_RDWR_SWITCH.
`define PIPELINE_REF_RDWR_SWITCH


// Name:         PIPELINE_REF_RDWR_SWITCH_EN
// Default:      1 ((PIPELINE_REF_RDWR_SWITCH==1) ? 1 : 0)
// Values:       0 1
// 
// Enables pipelining of the path related to UMCTL2_REF_RDWR_SWITCH.
`define PIPELINE_REF_RDWR_SWITCH_EN 1

// ----------------------------------------------------------------------------
// DERIVED MACROS:
// ----------------------------------------------------------------------------


// `define MEMC_DRAM_DATA_WIDTH_72


// `define MEMC_DRAM_DATA_WIDTH_40


// `define MEMC_DRAM_DATA_WIDTH_64


// `define MEMC_DRAM_DATA_WIDTH_GT_63


// `define MEMC_DRAM_DATA_WIDTH_GT_55


// `define MEMC_DRAM_DATA_WIDTH_GT_47


// `define MEMC_DRAM_DATA_WIDTH_GT_39


`define MEMC_DRAM_DATA_WIDTH_GT_31


`define MEMC_DRAM_DATA_WIDTH_GT_23


`define MEMC_DRAM_DATA_WIDTH_GT_15


// `define MEMC_DDR3_OR_4


`define MEMC_DDR3_OR_4_OR_LPDDR2


`define MEMC_LPDDR2_OR_DDR4


`define MEMC_MOBILE_OR_LPDDR2_EN 1


`define MEMC_MOBILE_OR_LPDDR2


`define MEMC_MOBILE_OR_LPDDR2_OR_DDR4_EN 1


`define MEMC_MOBILE_OR_LPDDR2_OR_DDR4


`define MEMC_DDR4_OR_LPDDR4


`define MEMC_DDR3_OR_4_OR_LPDDR4


`define MEMC_LPDDR2_OR_UMCTL2_CID_EN


`define MEMC_LPDDR4_OR_UMCTL2_CID_EN


`define MEMC_LPDDR4_OR_UMCTL2_PARTIAL_WR


// `define UPCTL2_POSTED_WRITE_EN_OR_MEMC_INLINE_ECC

// Used in internal modules

`define MEMC_DFI_ADDR_WIDTH 14

// Used for interface port width

`define MEMC_DFI_ADDR_WIDTH_P0 14


`define MEMC_DFI_ADDR_WIDTH_P1 6


`define MEMC_DFI_ADDR_WIDTH_P2 6


`define MEMC_DFI_ADDR_WIDTH_P3 6


`define MEMC_HBUS_SUPPORT


`define MEMC_HBUS_SUPPORT_OR_MEMC_BURST_LENGTH_16


`define MEMC_BG_EN


`define MEMC_ROW17_EN


// Name:         MEMC_DDR4_BG_BITS2_INTERNAL_TESTING
// Default:      0 ((DDRCTL_DDR == 1 && MEMC_BURST_LENGTH == 8) ? 1 : 0)
// Values:       0, 1
// Enabled:      DDRCTL_ENABLE_INTERNAL_TESTING==1
// 
// MEMC_DDR4_BG_BITS2_INTERNAL_TESTING 
// Enables the DDR5/4 controller with MEMC_BG_BITS=2 for DDR4 compatibility 
// Only for Internal Testing within Synopsys.
`define MEMC_DDR4_BG_BITS2_INTERNAL_TESTING 0


`define DDRCTL_DFI_BG_WIDTH 2


// Name:         MEMC_BG_BITS
// Default:      2 (DDRCTL_LPDDR == 1 || MEMC_DDR4_BG_BITS2_INTERNAL_TESTING == 1 ? 
//               2 : 3)
// Values:       2 3
// Enabled:      0
// 
// Specifies the number of bits required to address all bank groups in each rank 
// Must be set to 3 in DDR5/4 systems and set to 2 in LPDDR5/4 systems
`define MEMC_BG_BITS 2


// `define MEMC_BG2_EN


// Name:         MEMC_BG_BANK_BITS
// Default:      4 (DDRCTL_LPDDR == 1 || MEMC_DDR4_BG_BITS2_INTERNAL_TESTING == 1 ? 
//               4 : 5)
// Values:       4 5
// Enabled:      0
// 
// Specifies the maximum number of bits required to address all banks and bank groups in each rank 
//  - For DDR5/4, this should be set to 5 and for LPDDR5/4 should be set to 4 
//  - For DDR4, this carries 2-bits for bank group address and 2-bits for bank address 
//  - For LPDDR4, all 3-bits are for bank address
`define MEMC_BG_BANK_BITS 4


// Name:         MEMC_BANK_BITS
// Default:      3 (DDRCTL_DDR == 1 ? 2 : 3)
// Values:       2 3
// 
// Specifies the maximum number of bits required to address all banks in each rank 
// For DDR4/5, this must be set to 2 
// For LPDDR4/5, this must be set to 3
`define MEMC_BANK_BITS 3

/****************************/
/* Begin ECC Related Macros */
/****************************/


`define MEMC_DRAM_ECC_WIDTH 0


// `define MEMC_ADVECC_X4


// `define MEMC_ECC


// `define MEMC_ECC_SUPPORT_GT_0


// `define MEMC_ECC_SUPPORT_2_OR_3


// `define MEMC_ECC_SUPPORT_3


`define MEMC_DCERRBITS 8


`define MEMC_ECC_BITS_ON_DQ_BUS 0

//TODO the below three invisible HW paramameter should be change to MEMC_ECC_SUPPORT==1
//TODO current is a workaround to avoid lots of testbench issue ifndef them


// `define UMCTL2_ECC_MODE_64P8


// `define UMCTL2_ECC_MODE_32P7


// `define UMCTL2_ECC_MODE_16P6


`define MEMC_NO_ECC


// `define MEMC_SECDED_ECC


// `define MEMC_ADV_ECC


// `define MEMC_SECDED_SIDEBAND_ECC


// `define MEMC_ADV_SIDEBAND_ECC


// `define MEMC_SECDED_ADV_SIDEBAND_ECC


// `define MEMC_SECDED_INLINE_ECC


// `define MEMC_ADV_INLINE_ECC

/****************************/
/*  End ECC Related Macros  */
/****************************/




/***********************************/
/* Begin Data width derived macros */
/***********************************/


// Name:         MEMC_DRAM_TOTAL_DATA_WIDTH
// Default:      32 (MEMC_DRAM_DATA_WIDTH + MEMC_DRAM_ECC_WIDTH+0)
// Values:       8 16 24 32 40 48 56 64 72 80
// Enabled:      0
// 
// Memory data width with ECC (bits).
`define MEMC_DRAM_TOTAL_DATA_WIDTH 32


`define MEMC_DRAM_TOTAL_BYTE_NUM 4


`define MEMC_DRAM_TOTAL_BYTE_NUM_GT_0

`define MEMC_DRAM_TOTAL_BYTE_NUM_GT_1

`define MEMC_DRAM_TOTAL_BYTE_NUM_GT_2

`define MEMC_DRAM_TOTAL_BYTE_NUM_GT_3

// `define MEMC_DRAM_TOTAL_BYTE_NUM_GT_4

// `define MEMC_DRAM_TOTAL_BYTE_NUM_GT_5

// `define MEMC_DRAM_TOTAL_BYTE_NUM_GT_6

// `define MEMC_DRAM_TOTAL_BYTE_NUM_GT_7

// `define MEMC_DRAM_TOTAL_BYTE_NUM_GT_8

// `define MEMC_DRAM_TOTAL_BYTE_NUM_GT_9


`define MEMC_DRAM_TOTAL_MASK_WIDTH 4


`define MEMC_DFI_DATA_WIDTH 256


`define MEMC_DFI_MASK_WIDTH 32


`define MEMC_DFI_ECC_WIDTH 0


// Name:         MEMC_DFI_TOTAL_DATA_WIDTH
// Default:      256 (MEMC_FREQ_RATIO * (MEMC_DRAM_DATA_WIDTH + MEMC_DRAM_ECC_WIDTH) 
//               * 2)
// Values:       16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 192, 224, 256, 288, 
//               320, 512, 576
// Enabled:      0
// 
// This parameter specifies the width of DFI data bus including ECC (if any). It is an internal parameter provided in the 
// GUI for information purposes.
`define MEMC_DFI_TOTAL_DATA_WIDTH 256


`define PHY_DFI_TOTAL_DATA_WIDTH 256


// Name:         MEMC_DFI_TOTAL_DATAEN_WIDTH
// Default:      16 (MEMC_DFI_TOTAL_DATA_WIDTH / 16)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the width of dfi_wrdata_en, dfi_rddata_en, and dfi_rddata_valid. 
// It is an internal parameter provided in the GUI for information purposes.
`define MEMC_DFI_TOTAL_DATAEN_WIDTH 16


`define PHY_DFI_TOTAL_DATAEN_WIDTH 16


// Name:         MEMC_DFI_TOTAL_MASK_WIDTH
// Default:      32 (UMCTL2_DFI_MASK_PER_NIBBLE ? (MEMC_DFI_DATA_WIDTH + 
//               MEMC_DFI_ECC_WIDTH)/4 : (MEMC_DFI_DATA_WIDTH + MEMC_DFI_ECC_WIDTH)/8)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the width of dfi_wrdata_mask. 
// It is an internal parameter provided in the GUI for information purposes.
`define MEMC_DFI_TOTAL_MASK_WIDTH 32


`define PHY_DFI_TOTAL_MASK_WIDTH 32


`define MEMC_CORE_DATA_WIDTH_GTEQ_64


`define MEMC_CORE_DATA_WIDTH_GTEQ_128


// `define MEMC_CORE_DATA_WIDTH_LT_64


`define MEMC_CORE_DATA_WIDTH_GTE_256


`define MEMC_BYTE1


`define MEMC_BYTE2


`define MEMC_BYTE3


// `define MEMC_BYTE4


// `define MEMC_BYTE5


// `define MEMC_BYTE6


// `define MEMC_BYTE7


// `define MEMC_BYTE8


// `define MEMC_BYTE9


// `define MEMC_BYTE10


// `define MEMC_BYTE11


// `define MEMC_BYTE12


// `define MEMC_BYTE13


// `define MEMC_BYTE14


// `define MEMC_BYTE15


`define MEMC_MRR_DATA_TOTAL_DATA_WIDTH 32

/***********************************/
/*  End Data width derived macros  */
/***********************************/


`define DDRCTL_DFI0_CS_WIDTH 1


`define DDRCTL_DFI1_CS_WIDTH 1


`define MEMC_NUM_RANKS_1_OR_2


`define MEMC_NUM_RANKS_1


// `define MEMC_NUM_RANKS_2


// `define MEMC_NUM_RANKS_4


// `define MEMC_NUM_RANKS_GT_1


// `define MEMC_NUM_RANKS_GT_2


// `define MEMC_NUM_RANKS_GT_3


// `define UMCTL2_RANKS_GT_1_OR_DCH_INTL_1


`define UMCTL2_NUM_LRANKS_TOTAL_GT_0

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_1

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_2

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_3

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_4

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_5

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_6

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_7

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_8

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_9

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_10

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_11

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_12

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_13

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_14

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_15

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_16

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_17

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_18

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_19

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_20

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_21

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_22

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_23

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_24

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_25

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_26

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_27

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_28

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_29

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_30

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_31

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_32

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_33

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_34

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_35

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_36

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_37

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_38

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_39

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_40

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_41

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_42

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_43

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_44

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_45

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_46

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_47

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_48

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_49

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_50

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_51

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_52

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_53

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_54

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_55

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_56

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_57

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_58

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_59

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_60

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_61

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_62

// `define UMCTL2_NUM_LRANKS_TOTAL_GT_63


// `define UMCTL2_NUM_LRANKS_TOTAL_0

`define UMCTL2_NUM_LRANKS_TOTAL_1

// `define UMCTL2_NUM_LRANKS_TOTAL_2

// `define UMCTL2_NUM_LRANKS_TOTAL_3

// `define UMCTL2_NUM_LRANKS_TOTAL_4

// `define UMCTL2_NUM_LRANKS_TOTAL_5

// `define UMCTL2_NUM_LRANKS_TOTAL_6

// `define UMCTL2_NUM_LRANKS_TOTAL_7

// `define UMCTL2_NUM_LRANKS_TOTAL_8

// `define UMCTL2_NUM_LRANKS_TOTAL_9

// `define UMCTL2_NUM_LRANKS_TOTAL_10

// `define UMCTL2_NUM_LRANKS_TOTAL_11

// `define UMCTL2_NUM_LRANKS_TOTAL_12

// `define UMCTL2_NUM_LRANKS_TOTAL_13

// `define UMCTL2_NUM_LRANKS_TOTAL_14

// `define UMCTL2_NUM_LRANKS_TOTAL_15

// `define UMCTL2_NUM_LRANKS_TOTAL_16

// `define UMCTL2_NUM_LRANKS_TOTAL_17

// `define UMCTL2_NUM_LRANKS_TOTAL_18

// `define UMCTL2_NUM_LRANKS_TOTAL_19

// `define UMCTL2_NUM_LRANKS_TOTAL_20

// `define UMCTL2_NUM_LRANKS_TOTAL_21

// `define UMCTL2_NUM_LRANKS_TOTAL_22

// `define UMCTL2_NUM_LRANKS_TOTAL_23

// `define UMCTL2_NUM_LRANKS_TOTAL_24

// `define UMCTL2_NUM_LRANKS_TOTAL_25

// `define UMCTL2_NUM_LRANKS_TOTAL_26

// `define UMCTL2_NUM_LRANKS_TOTAL_27

// `define UMCTL2_NUM_LRANKS_TOTAL_28

// `define UMCTL2_NUM_LRANKS_TOTAL_29

// `define UMCTL2_NUM_LRANKS_TOTAL_30

// `define UMCTL2_NUM_LRANKS_TOTAL_31

// `define UMCTL2_NUM_LRANKS_TOTAL_32

// `define UMCTL2_NUM_LRANKS_TOTAL_33

// `define UMCTL2_NUM_LRANKS_TOTAL_34

// `define UMCTL2_NUM_LRANKS_TOTAL_35

// `define UMCTL2_NUM_LRANKS_TOTAL_36

// `define UMCTL2_NUM_LRANKS_TOTAL_37

// `define UMCTL2_NUM_LRANKS_TOTAL_38

// `define UMCTL2_NUM_LRANKS_TOTAL_39

// `define UMCTL2_NUM_LRANKS_TOTAL_40

// `define UMCTL2_NUM_LRANKS_TOTAL_41

// `define UMCTL2_NUM_LRANKS_TOTAL_42

// `define UMCTL2_NUM_LRANKS_TOTAL_43

// `define UMCTL2_NUM_LRANKS_TOTAL_44

// `define UMCTL2_NUM_LRANKS_TOTAL_45

// `define UMCTL2_NUM_LRANKS_TOTAL_46

// `define UMCTL2_NUM_LRANKS_TOTAL_47

// `define UMCTL2_NUM_LRANKS_TOTAL_48

// `define UMCTL2_NUM_LRANKS_TOTAL_49

// `define UMCTL2_NUM_LRANKS_TOTAL_50

// `define UMCTL2_NUM_LRANKS_TOTAL_51

// `define UMCTL2_NUM_LRANKS_TOTAL_52

// `define UMCTL2_NUM_LRANKS_TOTAL_53

// `define UMCTL2_NUM_LRANKS_TOTAL_54

// `define UMCTL2_NUM_LRANKS_TOTAL_55

// `define UMCTL2_NUM_LRANKS_TOTAL_56

// `define UMCTL2_NUM_LRANKS_TOTAL_57

// `define UMCTL2_NUM_LRANKS_TOTAL_58

// `define UMCTL2_NUM_LRANKS_TOTAL_59

// `define UMCTL2_NUM_LRANKS_TOTAL_60

// `define UMCTL2_NUM_LRANKS_TOTAL_61

// `define UMCTL2_NUM_LRANKS_TOTAL_62

// `define UMCTL2_NUM_LRANKS_TOTAL_63

// `define UMCTL2_NUM_LRANKS_TOTAL_64


// `define UMCTL2_CID_WIDTH_GT_0

// `define UMCTL2_CID_WIDTH_GT_1

// `define UMCTL2_CID_WIDTH_GT_2

// `define UMCTL2_CID_WIDTH_GT_3


`define UMCTL2_CID_WIDTH_0

// `define UMCTL2_CID_WIDTH_1

// `define UMCTL2_CID_WIDTH_2

// `define UMCTL2_CID_WIDTH_3

// `define UMCTL2_CID_WIDTH_4


// `define MEMC_NUM_RANKS_GT_1_OR_UMCTL2_CID_WIDTH_GT_0



`define log2(n) (((n)>512) ? 10 : (((n)>256) ? 9 : (((n)>128) ? 8 : (((n)>64) ? 7 : (((n)>32) ? 6 : (((n)>16) ? 5 : (((n)>8) ? 4 : (((n)>4) ? 3 : (((n)>2) ? 2 : (((n)>1) ? 1 : 0))))))))))


`define DDRCTL_FREQUENCY_BITS 1


`define MEMC_RANK_BITS 0


`define UMCTL2_LRANK_BITS 0


`define MEMC_RANKBANK_BITS 4


// Name:         MEMC_NUM_TOTAL_BANKS
// Default:      0x10 (1<<MEMC_RANKBANK_BITS)
// Values:       0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x800
// Enabled:      0
// 
// This parameter specifies the maximum number of banks supported with a given hardware configuration.
`define MEMC_NUM_TOTAL_BANKS 32'h10



`define MEMC_HIF_MIN_ADDR_WIDTH 32


`define MEMC_HIF_ADDR_WIDTH_MAX 40


`define MEMC_HIF_ADDR_WIDTH_MAX_TB 40


// Name:         MEMC_HIF_ADDR_WIDTH
// Default:      32 (UMCTL2_LRANK_BITS + UMCTL2_DATA_CHANNEL_INTERLEAVE_EN + 
//               (MEMC_DDR4_BG_BITS2_INTERNAL_TESTING == 1 ? 33 : (DDRCTL_DDR == 1) ? 34 : 
//               (DDRCTL_LPDDR == 1) ? 32 : MEMC_HIF_MIN_ADDR_WIDTH) )
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// MEMC_HIF_ADDR_WIDTH 
// Maximum number of HIF address bits supported. For any device, the number of HIF address bits depends on 
// RAW+CAW+BAW+BGW. 
// This is a maximum of 32 for DDR4 and 31 for LPDDR4. 
// The number of rank bits is then added to this.
`define MEMC_HIF_ADDR_WIDTH 32


`define MEMC_HIF_ADDR_WIDTH_GT_28


`define MEMC_HIF_ADDR_WIDTH_GT_29


`define MEMC_HIF_ADDR_WIDTH_GT_30


`define MEMC_HIF_ADDR_WIDTH_GT_31


// `define MEMC_HIF_ADDR_WIDTH_GT_32


// `define MEMC_HIF_ADDR_WIDTH_GT_33


// `define MEMC_HIF_ADDR_WIDTH_GT_34


// `define MEMC_HIF_ADDR_WIDTH_GT_35


// `define MEMC_HIF_ADDR_WIDTH_GT_36


// `define MEMC_HIF_ADDR_WIDTH_GT_37


// `define MEMC_HIF_ADDR_WIDTH_GT_38


// `define MEMC_HIF_ADDR_WIDTH_GT_39


// `define MEMC_NUM_TOTAL_BANKS_4


// `define MEMC_NUM_TOTAL_BANKS_8


`define MEMC_NUM_TOTAL_BANKS_16


// `define MEMC_NUM_TOTAL_BANKS_32


// `define MEMC_NUM_TOTAL_BANKS_64


// `define MEMC_NUM_TOTAL_BANKS_128


// `define MEMC_NUM_TOTAL_BANKS_256


// `define MEMC_FREQ_RATIO_2


`define MEMC_FREQ_RATIO_4


`define MEMC_PROG_FREQ_RATIO_EN


// `define MEMC_BURST_LENGTH_4


// `define MEMC_BURST_LENGTH_8


`define MEMC_BURST_LENGTH_8_VAL 0


`define MEMC_BURST_LENGTH_16


`define MEMC_BURST_LENGTH_16_VAL 1


`define MEMC_BURST_LENGTH_8_OR_16


// `define MEMC_BURST_LENGTH_32


`define MEMC_BURST_LENGTH_32_VAL 0


`define MEMC_WRDATA_CYCLES 2


// `define MEMC_WRDATA_4_CYCLES


// `define MEMC_WRDATA_8_CYCLES


// `define MEMC_BURST_LENGTH_4_OR_ARB_0


// `define MEMC_BURST_LENGTH_4_OR_8_OR_ARB_0


`define UMCTL2_SDRAM_BL16_SUPPORTED


`define UMCTL2_CMD_LEN_BITS 2


`define MEMC_BURST_LENGTH_16_AND_ARB_1


// `define MEMC_DDR4_AND_BURST_LENGTH_16


// `define MEMC_DDR4_OR_INLINE_ECC


`define UMCTL2_PARTIAL_WR_BITS 2


// `define MEMC_NO_OF_ENTRY_16


`define MEMC_NO_OF_ENTRY_GT16


`define MEMC_NO_OF_ENTRY_32


// `define MEMC_NO_OF_ENTRY_GT32


// `define MEMC_NO_OF_ENTRY_64


`define MEMC_WRCMD_ENTRY_BITS 5


`define MEMC_RDCMD_ENTRY_BITS 5


// `define MEMC_ACT_BYPASS


// `define MEMC_RD_BYPASS


// `define MEMC_ANY_BYPASS


`define UMCTL2_FATL_BITS 3

/**********************************************/
/* Begin Fast Frequency Change derived macros */
/**********************************************/

`define UMCTL2_FREQUENCY_NUM_GT_0

// `define UMCTL2_FREQUENCY_NUM_GT_1

// `define UMCTL2_FREQUENCY_NUM_GT_2

// `define UMCTL2_FREQUENCY_NUM_GT_3

// `define UMCTL2_FREQUENCY_NUM_GT_4

// `define UMCTL2_FREQUENCY_NUM_GT_5

// `define UMCTL2_FREQUENCY_NUM_GT_6

// `define UMCTL2_FREQUENCY_NUM_GT_7

// `define UMCTL2_FREQUENCY_NUM_GT_8

// `define UMCTL2_FREQUENCY_NUM_GT_9

// `define UMCTL2_FREQUENCY_NUM_GT_10

// `define UMCTL2_FREQUENCY_NUM_GT_11

// `define UMCTL2_FREQUENCY_NUM_GT_12

// `define UMCTL2_FREQUENCY_NUM_GT_13

// `define UMCTL2_FREQUENCY_NUM_GT_14

/********************************************/
/* End Fast Frequency Change derived macros */
/********************************************/

/********************************************/
/* Begin INLINE ECC derived macros */
/********************************************/

`define MEMC_ECC_RAM_DEPTH 40


`define MEMC_DRAM_DATA_WIDTH_64_OR_MEMC_INLINE_ECC


// `define MEMC_INLINE_ECC_OR_UMCTL2_VPR_EN


`define UMCTL2_OCPAR_WDATA_OUT_ERR_WIDTH 1


`define MEMC_HIF_CREDIT_BITS 1


// `define MEMC_HIF_CMD_WDATA_MASK_FULL_EN


`define MEMC_MAX_INLINE_ECC_PER_BURST 8



`define MEMC_MAX_INLINE_ECC_PER_BURST_BITS 3

/********************************************/
/* End INLINE ECC derived macros */
/********************************************/

// ----------------------------------------------------------------------------
// Dynamic BSM parameters
// ----------------------------------------------------------------------------


// Name:         DDRCTL_DYN_BSM_MODE
// Default:      0 ( ((MEMC_NUM_TOTAL_BANKS > 256) && (MEMC_OPT_TIMING==1) && 
//               (MEMC_BYPASS==0) && (UMCTL2_HWFFC_EN==0) && (MEMC_INLINE_ECC==0) && 
//               (DDRCTL_DDR==1)) ? 2 : 0)
// Values:       0 1 2
// Enabled:      ((MEMC_NUM_TOTAL_BANKS>16) && (MEMC_OPT_TIMING==1) && 
//               (MEMC_BYPASS==0) && (UMCTL2_HWFFC_EN==0) && (MEMC_INLINE_ECC==0) && 
//               (DDRCTL_DDR==1))
// 
// This parameter selects the Dynamic BSM modes. 
//  --0: Dynamic BSM is disabled. 
//  --1: Dynamic BSM in fixed mode, the DDRCTL supports fixed BSM mapping only. 
//  --2: Dynamic BSM in dynamic mode, the DDRCTL supports BSM allocation/deallocation. 
// This feature is under access control. For more information, contact Synopsys.
`define DDRCTL_DYN_BSM_MODE 0


// Name:         UMCTL2_DYN_BSM
// Default:      0 ((DDRCTL_DYN_BSM_MODE==1 || DDRCTL_DYN_BSM_MODE==2) ? 1 : 0)
// Values:       0 1
// Enabled:      0
// 
// This parameter enables the Dynamic BSM feature.
// `define UMCTL2_DYN_BSM


`define UMCTL2_DYN_BSM_EN 0


// Name:         MEMC_OPT_TIMING_DYN_BSM
// Default:      0 (UMCTL2_DYN_BSM)
// Values:       0, 1
// Enabled:      UMCTL2_DYN_BSM == 1
// 
// Optimize timing for Dynamic-BSM
// `define MEMC_OPT_TIMING_DYN_BSM


`define MEMC_OPT_TIMING_DYN_BSM_EN 0


// Name:         UMCTL2_DYN_BSM_FIXED
// Default:      0 ((DDRCTL_DYN_BSM_MODE==1) ? 1 : 0)
// Values:       0 1
// Enabled:      0
// 
// Enables fixed BSM mapping only in Dynamic BSM configurations. 
// If this is set to 1, the DDRCTL supports fixed BSM mapping only.
// `define UMCTL2_DYN_BSM_FIXED


// Name:         UMCTL2_DYN_BSM_SMALL
// Default:      0
// Values:       0 1
// Enabled:      Always
// 
// Bypasses one of the CheckExpr of the UMCTL2_NUM_BSM parameter. 
// If this is set to 1, UMCTL2_NUM_BSM is allowed to be less than MEMC_NO_OF_ENTRY*2.
// `define UMCTL2_DYN_BSM_SMALL


// Name:         UMCTL2_NUM_BSM
// Default:      16 ((DDRCTL_DYN_BSM_MODE == 0) ? MEMC_NUM_TOTAL_BANKS : 
//               ((DDRCTL_DYN_BSM_MODE == 1) ? (MEMC_NUM_TOTAL_BANKS/2) : 
//               ((MEMC_NUM_TOTAL_BANKS/2 > 128) ? 128 : (MEMC_NUM_TOTAL_BANKS/2))))
// Values:       8 16 32 64 128 256
// Enabled:      DDRCTL_DYN_BSM_MODE == 2
// 
// This parameter specifies the number of BSM modules required.
`define UMCTL2_NUM_BSM 16


`define UMCTL2_BSM_BITS 4


// `define DDRCTL_NUM_BSM_LT_TOTAL_BANKS

// ----------------------------------------------------------------------------
// MACROS used during the development of APB interface and memory map
// ----------------------------------------------------------------------------



// Name:         UMCTL2_APB_DW
// Default:      32
// Values:       8 16 32
// Enabled:      0
// 
// Defines the width of the APB Data Bus. 
// This must be set to 32.
`define UMCTL2_APB_DW 32


// Name:         UMCTL2_APB_AW
// Default:      24
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// APB Address Width.
`define UMCTL2_APB_AW 24


// Name:         UMCTL2_RSTN_SYNC_AND_ASYNC
// Default:      0
// Values:       0, 1
// 
// UMCTL2_RSTN_SYNC_AND_ASYNC 
// Reset synchronisers are used to drive reset networks of FFs belonging 
// to programming interface but clocked by clocks different from APB clock. 
// When the parameter is set to 1 the reset signals (one for each clock 
// domain asynchronous to APB clock domain) are gated with APB reset signal: 
//  - Generated reset signals are set high synchronously, set low asynchronously. 
//  - FFs whose reset pin is driven by such reset signal are reset independenty on APB clock. 
// When the parameter is set to 0 the and gate is not instantiated. 
// Default value is 0.
// `define UMCTL2_RSTN_SYNC_AND_ASYNC


// Name:         UMCTL2_P_ASYNC_EN
// Default:      Asynchronous
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      Always
// 
// This parameter defines the pclk clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk signal. 
//  
// When enabled (asynchronous), the area of the controller is increased for additional 
// instantiation of CDC components. 
//  
// Note: The core_ddrc_core_clk frequency has to be 
// greater or equal to pclk frequency.
`define UMCTL2_P_ASYNC_EN 1


`define UMCTL2_P_ASYNC


// Name:         UMCTL2_P_SYNC_RATIO
// Default:      1:1
// Values:       1:1 (1), 2:1 (2), 3:1 (3), 4:1 (4)
// Enabled:      UMCTL2_P_ASYNC_EN == 0
// 
// Ratio between core_ddrc_core_clk and pclk frequency when the two clock domains are in phase. 
// This parameter has no effect on the RTL or verification but only on synthesis. 
// The parameter is enabled within the synthesis constraint when UMCTL2_P_ASYNC_EN=0.
`define UMCTL2_P_SYNC_RATIO 1


`define UMCTL2_BCM_REG_OUTPUTS_C2P 1


`define UMCTL2_BCM_REG_OUTPUTS_P2C 1


// Name:         DWC_BCM_SV
// Default:      0
// Values:       0, 1
// 
// Supports the use of $urandom in the BCM blocks (for missample modeling).
// `define DWC_BCM_SV


`define UMCTL2_DUAL_PA 0


// `define UMCTL2_DUAL_PA_1

// ----------------------------------------------------------------------------
// Exclusive Access Monitor Parameters
// ----------------------------------------------------------------------------

// Name:         UMCTL2_EXCL_ACCESS
// Default:      0
// Values:       0, ..., 16
// Enabled:      ((UMCTL2_INCL_ARB==1) && (THEREIS_AXI_PORT==1))
// 
// This parameter specifies the number of AXI Exclusive Access Monitors. 
//  - 0: Exclusive Access Monitoring is not supported. 
//  - 1-16: Exclusive Access Monitoring is supported with the selected number of monitors.
`define UMCTL2_EXCL_ACCESS 0


`define UMCTL2_EXCL_ACCESS_0

// ----------------------------------------------------------------------------
// External Port Priorities
// ----------------------------------------------------------------------------

// Name:         UMCTL2_EXT_PORTPRIO
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB==1 && UMCTL2_A_NPORTS > 1
// 
// This parameter enables dynamic setting of port priorities externally through the AXI QoS signals (awqos_n 
// and arqos_n).
`define UMCTL2_EXT_PORTPRIO 0


// ----------------------------------------------------------------------------
//                                Multiport
// ----------------------------------------------------------------------------


`define UMCTL2_A_AXI_0

// `define UMCTL2_A_AXI_1

// `define UMCTL2_A_AXI_2

// `define UMCTL2_A_AXI_3

// `define UMCTL2_A_AXI_4

// `define UMCTL2_A_AXI_5

// `define UMCTL2_A_AXI_6

// `define UMCTL2_A_AXI_7

// `define UMCTL2_A_AXI_8

// `define UMCTL2_A_AXI_9

// `define UMCTL2_A_AXI_10

// `define UMCTL2_A_AXI_11

// `define UMCTL2_A_AXI_12

// `define UMCTL2_A_AXI_13

// `define UMCTL2_A_AXI_14

// `define UMCTL2_A_AXI_15


// `define DDRCTL_A_CHI_0

// `define DDRCTL_A_CHI_1

// `define DDRCTL_A_CHI_2

// `define DDRCTL_A_CHI_3

// `define DDRCTL_A_CHI_4

// `define DDRCTL_A_CHI_5

// `define DDRCTL_A_CHI_6

// `define DDRCTL_A_CHI_7

// `define DDRCTL_A_CHI_8

// `define DDRCTL_A_CHI_9

// `define DDRCTL_A_CHI_10

// `define DDRCTL_A_CHI_11

// `define DDRCTL_A_CHI_12

// `define DDRCTL_A_CHI_13

// `define DDRCTL_A_CHI_14

// `define DDRCTL_A_CHI_15


`define UMCTL2_A_AXI4_0

// `define UMCTL2_A_AXI4_1

// `define UMCTL2_A_AXI4_2

// `define UMCTL2_A_AXI4_3

// `define UMCTL2_A_AXI4_4

// `define UMCTL2_A_AXI4_5

// `define UMCTL2_A_AXI4_6

// `define UMCTL2_A_AXI4_7

// `define UMCTL2_A_AXI4_8

// `define UMCTL2_A_AXI4_9

// `define UMCTL2_A_AXI4_10

// `define UMCTL2_A_AXI4_11

// `define UMCTL2_A_AXI4_12

// `define UMCTL2_A_AXI4_13

// `define UMCTL2_A_AXI4_14

// `define UMCTL2_A_AXI4_15


`define UMCTL2_A_AXI_OR_AHB_0

// `define UMCTL2_A_AXI_OR_AHB_1

// `define UMCTL2_A_AXI_OR_AHB_2

// `define UMCTL2_A_AXI_OR_AHB_3

// `define UMCTL2_A_AXI_OR_AHB_4

// `define UMCTL2_A_AXI_OR_AHB_5

// `define UMCTL2_A_AXI_OR_AHB_6

// `define UMCTL2_A_AXI_OR_AHB_7

// `define UMCTL2_A_AXI_OR_AHB_8

// `define UMCTL2_A_AXI_OR_AHB_9

// `define UMCTL2_A_AXI_OR_AHB_10

// `define UMCTL2_A_AXI_OR_AHB_11

// `define UMCTL2_A_AXI_OR_AHB_12

// `define UMCTL2_A_AXI_OR_AHB_13

// `define UMCTL2_A_AXI_OR_AHB_14

// `define UMCTL2_A_AXI_OR_AHB_15


`define UMCTL2_A_AXI_OR_AHB_OR_CHB_0

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_1

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_2

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_3

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_4

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_5

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_6

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_7

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_8

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_9

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_10

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_11

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_12

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_13

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_14

// `define UMCTL2_A_AXI_OR_AHB_OR_CHB_15


`define UMCTL2_A_AXI_OR_CHB_0

// `define UMCTL2_A_AXI_OR_CHB_1

// `define UMCTL2_A_AXI_OR_CHB_2

// `define UMCTL2_A_AXI_OR_CHB_3

// `define UMCTL2_A_AXI_OR_CHB_4

// `define UMCTL2_A_AXI_OR_CHB_5

// `define UMCTL2_A_AXI_OR_CHB_6

// `define UMCTL2_A_AXI_OR_CHB_7

// `define UMCTL2_A_AXI_OR_CHB_8

// `define UMCTL2_A_AXI_OR_CHB_9

// `define UMCTL2_A_AXI_OR_CHB_10

// `define UMCTL2_A_AXI_OR_CHB_11

// `define UMCTL2_A_AXI_OR_CHB_12

// `define UMCTL2_A_AXI_OR_CHB_13

// `define UMCTL2_A_AXI_OR_CHB_14

// `define UMCTL2_A_AXI_OR_CHB_15



// Name:         UMCTL2_PORT_DW_0
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_0!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_0 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0 0


`define UMCTL2_A_DW_INT_0 256


// Name:         UMCTL2_XPI_USE2RAQ_0
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_0 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_0 0


// `define UMCTL2_A_USE2RAQ_0


`define UMCTL2_PORT_DSIZE_0 1


`define UMCTL2_PORT_USIZE_0 0


// Name:         UMCTL2_PORT_DW_1
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_1!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_1 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1 0


`define UMCTL2_A_DW_INT_1 256


// Name:         UMCTL2_XPI_USE2RAQ_1
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_1 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_1 0


// `define UMCTL2_A_USE2RAQ_1


`define UMCTL2_PORT_DSIZE_1 1


`define UMCTL2_PORT_USIZE_1 0


// Name:         UMCTL2_PORT_DW_2
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_2!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_2 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2 0


`define UMCTL2_A_DW_INT_2 256


// Name:         UMCTL2_XPI_USE2RAQ_2
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_2 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_2 0


// `define UMCTL2_A_USE2RAQ_2


`define UMCTL2_PORT_DSIZE_2 1


`define UMCTL2_PORT_USIZE_2 0


// Name:         UMCTL2_PORT_DW_3
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_3!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_3 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3 0


`define UMCTL2_A_DW_INT_3 256


// Name:         UMCTL2_XPI_USE2RAQ_3
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_3 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_3 0


// `define UMCTL2_A_USE2RAQ_3


`define UMCTL2_PORT_DSIZE_3 1


`define UMCTL2_PORT_USIZE_3 0


// Name:         UMCTL2_PORT_DW_4
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_4!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_4 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4 0


`define UMCTL2_A_DW_INT_4 256


// Name:         UMCTL2_XPI_USE2RAQ_4
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_4 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_4 0


// `define UMCTL2_A_USE2RAQ_4


`define UMCTL2_PORT_DSIZE_4 1


`define UMCTL2_PORT_USIZE_4 0


// Name:         UMCTL2_PORT_DW_5
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_5!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_5 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5 0


`define UMCTL2_A_DW_INT_5 256


// Name:         UMCTL2_XPI_USE2RAQ_5
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_5 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_5 0


// `define UMCTL2_A_USE2RAQ_5


`define UMCTL2_PORT_DSIZE_5 1


`define UMCTL2_PORT_USIZE_5 0


// Name:         UMCTL2_PORT_DW_6
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_6!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_6 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6 0


`define UMCTL2_A_DW_INT_6 256


// Name:         UMCTL2_XPI_USE2RAQ_6
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_6 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_6 0


// `define UMCTL2_A_USE2RAQ_6


`define UMCTL2_PORT_DSIZE_6 1


`define UMCTL2_PORT_USIZE_6 0


// Name:         UMCTL2_PORT_DW_7
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_7!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_7 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7 0


`define UMCTL2_A_DW_INT_7 256


// Name:         UMCTL2_XPI_USE2RAQ_7
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_7 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_7 0


// `define UMCTL2_A_USE2RAQ_7


`define UMCTL2_PORT_DSIZE_7 1


`define UMCTL2_PORT_USIZE_7 0


// Name:         UMCTL2_PORT_DW_8
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_8!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_8 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8 0


`define UMCTL2_A_DW_INT_8 256


// Name:         UMCTL2_XPI_USE2RAQ_8
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_8 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_8 0


// `define UMCTL2_A_USE2RAQ_8


`define UMCTL2_PORT_DSIZE_8 1


`define UMCTL2_PORT_USIZE_8 0


// Name:         UMCTL2_PORT_DW_9
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_9!=0 ? MEMC_DFI_DATA_WIDTH 
//               : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 
//               != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_9 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9 0


`define UMCTL2_A_DW_INT_9 256


// Name:         UMCTL2_XPI_USE2RAQ_9
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_9 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_9 0


// `define UMCTL2_A_USE2RAQ_9


`define UMCTL2_PORT_DSIZE_9 1


`define UMCTL2_PORT_USIZE_9 0


// Name:         UMCTL2_PORT_DW_10
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_10!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (10+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_10 != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_10 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10 0


`define UMCTL2_A_DW_INT_10 256


// Name:         UMCTL2_XPI_USE2RAQ_10
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_10 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_10 0


// `define UMCTL2_A_USE2RAQ_10


`define UMCTL2_PORT_DSIZE_10 1


`define UMCTL2_PORT_USIZE_10 0


// Name:         UMCTL2_PORT_DW_11
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_11!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (11+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_11 != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_11 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11 0


`define UMCTL2_A_DW_INT_11 256


// Name:         UMCTL2_XPI_USE2RAQ_11
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_11 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_11 0


// `define UMCTL2_A_USE2RAQ_11


`define UMCTL2_PORT_DSIZE_11 1


`define UMCTL2_PORT_USIZE_11 0


// Name:         UMCTL2_PORT_DW_12
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_12!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (12+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_12 != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_12 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12 0


`define UMCTL2_A_DW_INT_12 256


// Name:         UMCTL2_XPI_USE2RAQ_12
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_12 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_12 0


// `define UMCTL2_A_USE2RAQ_12


`define UMCTL2_PORT_DSIZE_12 1


`define UMCTL2_PORT_USIZE_12 0


// Name:         UMCTL2_PORT_DW_13
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_13!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (13+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_13 != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_13 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13 0


`define UMCTL2_A_DW_INT_13 256


// Name:         UMCTL2_XPI_USE2RAQ_13
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_13 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_13 0


// `define UMCTL2_A_USE2RAQ_13


`define UMCTL2_PORT_DSIZE_13 1


`define UMCTL2_PORT_USIZE_13 0


// Name:         UMCTL2_PORT_DW_14
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_14!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (14+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_14 != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_14 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14 0


`define UMCTL2_A_DW_INT_14 256


// Name:         UMCTL2_XPI_USE2RAQ_14
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_14 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_14 0


// `define UMCTL2_A_USE2RAQ_14


`define UMCTL2_PORT_DSIZE_14 1


`define UMCTL2_PORT_USIZE_14 0


// Name:         UMCTL2_PORT_DW_15
// Default:      256 (UMCTL2_INCL_ARB==1 && UMCTL2_A_TYPE_15!=0 ? 
//               MEMC_DFI_DATA_WIDTH : 32)
// Values:       8 16 32 64 128 256 512
// Enabled:      UMCTL2_A_NPORTS >= (15+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_15 != 0
// 
// This parameter defines the data width of the controller application port n. 
// Valid ranges for AXI4 are 32 to 512.
`define UMCTL2_PORT_DW_15 256


`define UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15 0


`define UMCTL2_A_DW_INT_15 256


// Name:         UMCTL2_XPI_USE2RAQ_15
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_A_AXI_15 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN== 0
// 
// This parameter enables the dual read address queue for the controller application port n. 
// Each dual address queue XPI consumes two consecutive PA ports.
`define UMCTL2_XPI_USE2RAQ_15 0


// `define UMCTL2_A_USE2RAQ_15


`define UMCTL2_PORT_DSIZE_15 1


`define UMCTL2_PORT_USIZE_15 0



`define UMCTL2_TOT_INTERLEAVE_NS 0


`define THEREIS_INTLV_NS 0


`define UMCTL2_TOT_USE2RAQ 0


// `define THEREIS_USE2RAQ

`define UMCTL2_RAQ_TABLE_0 0
`define UMCTL2_RAQ_TABLE_1 `UMCTL2_RAQ_TABLE_0 + `UMCTL2_XPI_USE2RAQ_0
`define UMCTL2_RAQ_TABLE_2 `UMCTL2_RAQ_TABLE_1 + `UMCTL2_XPI_USE2RAQ_1
`define UMCTL2_RAQ_TABLE_3 `UMCTL2_RAQ_TABLE_2 + `UMCTL2_XPI_USE2RAQ_2
`define UMCTL2_RAQ_TABLE_4 `UMCTL2_RAQ_TABLE_3 + `UMCTL2_XPI_USE2RAQ_3
`define UMCTL2_RAQ_TABLE_5 `UMCTL2_RAQ_TABLE_4 + `UMCTL2_XPI_USE2RAQ_4
`define UMCTL2_RAQ_TABLE_6 `UMCTL2_RAQ_TABLE_5 + `UMCTL2_XPI_USE2RAQ_5
`define UMCTL2_RAQ_TABLE_7 `UMCTL2_RAQ_TABLE_6 + `UMCTL2_XPI_USE2RAQ_6
`define UMCTL2_RAQ_TABLE_8 `UMCTL2_RAQ_TABLE_7 + `UMCTL2_XPI_USE2RAQ_7
`define UMCTL2_RAQ_TABLE_9 `UMCTL2_RAQ_TABLE_8 + `UMCTL2_XPI_USE2RAQ_8
`define UMCTL2_RAQ_TABLE_10 `UMCTL2_RAQ_TABLE_9 + `UMCTL2_XPI_USE2RAQ_9
`define UMCTL2_RAQ_TABLE_11 `UMCTL2_RAQ_TABLE_10 + `UMCTL2_XPI_USE2RAQ_10
`define UMCTL2_RAQ_TABLE_12 `UMCTL2_RAQ_TABLE_11 + `UMCTL2_XPI_USE2RAQ_11
`define UMCTL2_RAQ_TABLE_13 `UMCTL2_RAQ_TABLE_12 + `UMCTL2_XPI_USE2RAQ_12
`define UMCTL2_RAQ_TABLE_14 `UMCTL2_RAQ_TABLE_13 + `UMCTL2_XPI_USE2RAQ_13
`define UMCTL2_RAQ_TABLE_15 `UMCTL2_RAQ_TABLE_14 + `UMCTL2_XPI_USE2RAQ_14


// Name:         UMCTL2_RAQ_TABLE
// Default:      0 ((UMCTL2_XPI_USE2RAQ_15<<15) + (UMCTL2_XPI_USE2RAQ_14<<14) + 
//               (UMCTL2_XPI_USE2RAQ_13<<13) + (UMCTL2_XPI_USE2RAQ_12<<12) + 
//               (UMCTL2_XPI_USE2RAQ_11<<11) + (UMCTL2_XPI_USE2RAQ_10<<10) + 
//               (UMCTL2_XPI_USE2RAQ_9<<9) + (UMCTL2_XPI_USE2RAQ_8<<8) + (UMCTL2_XPI_USE2RAQ_7<<7) + 
//               (UMCTL2_XPI_USE2RAQ_6<<6) + (UMCTL2_XPI_USE2RAQ_5<<5) + 
//               (UMCTL2_XPI_USE2RAQ_4<<4) + (UMCTL2_XPI_USE2RAQ_3<<3) + (UMCTL2_XPI_USE2RAQ_2<<2) + 
//               (UMCTL2_XPI_USE2RAQ_1<<1) + UMCTL2_XPI_USE2RAQ_0)
// Values:       -2147483648, ..., 65535
// 
// Table built from the list of UMCTL2_XPI_USE2RAQ_<n>
`define UMCTL2_RAQ_TABLE 0


`define UMCTL2_XPI_RQOS_MLW 4


`define UMCTL2_XPI_RQOS_RW 2


`define UMCTL2_XPI_VPR_EN 0


`define UMCTL2_XPI_VPW_EN 0


`define UMCTL2_XPI_VPT_EN 0


`define UMCTL2_XPI_WQOS_MLW 4


`define UMCTL2_XPI_WQOS_RW 2


`define UMCTL2_XPI_RQOS_TW 1


`define UMCTL2_XPI_WQOS_TW 1


// `define DDRCTL_CHB_VPT_EN


`define DDRCTL_CHB_RQOS_TW 11


`define DDRCTL_CHB_WQOS_TW 11


`define UMCTL2_XPI_VPR_EN_0 0


// `define UMCTL2_XPI_VPR_0

`define UMCTL2_XPI_VPR_EN_1 0


// `define UMCTL2_XPI_VPR_1

`define UMCTL2_XPI_VPR_EN_2 0


// `define UMCTL2_XPI_VPR_2

`define UMCTL2_XPI_VPR_EN_3 0


// `define UMCTL2_XPI_VPR_3

`define UMCTL2_XPI_VPR_EN_4 0


// `define UMCTL2_XPI_VPR_4

`define UMCTL2_XPI_VPR_EN_5 0


// `define UMCTL2_XPI_VPR_5

`define UMCTL2_XPI_VPR_EN_6 0


// `define UMCTL2_XPI_VPR_6

`define UMCTL2_XPI_VPR_EN_7 0


// `define UMCTL2_XPI_VPR_7

`define UMCTL2_XPI_VPR_EN_8 0


// `define UMCTL2_XPI_VPR_8

`define UMCTL2_XPI_VPR_EN_9 0


// `define UMCTL2_XPI_VPR_9

`define UMCTL2_XPI_VPR_EN_10 0


// `define UMCTL2_XPI_VPR_10

`define UMCTL2_XPI_VPR_EN_11 0


// `define UMCTL2_XPI_VPR_11

`define UMCTL2_XPI_VPR_EN_12 0


// `define UMCTL2_XPI_VPR_12

`define UMCTL2_XPI_VPR_EN_13 0


// `define UMCTL2_XPI_VPR_13

`define UMCTL2_XPI_VPR_EN_14 0


// `define UMCTL2_XPI_VPR_14

`define UMCTL2_XPI_VPR_EN_15 0


// `define UMCTL2_XPI_VPR_15


`define UMCTL2_XPI_VPW_EN_0 0


// `define UMCTL2_XPI_VPW_0

`define UMCTL2_XPI_VPW_EN_1 0


// `define UMCTL2_XPI_VPW_1

`define UMCTL2_XPI_VPW_EN_2 0


// `define UMCTL2_XPI_VPW_2

`define UMCTL2_XPI_VPW_EN_3 0


// `define UMCTL2_XPI_VPW_3

`define UMCTL2_XPI_VPW_EN_4 0


// `define UMCTL2_XPI_VPW_4

`define UMCTL2_XPI_VPW_EN_5 0


// `define UMCTL2_XPI_VPW_5

`define UMCTL2_XPI_VPW_EN_6 0


// `define UMCTL2_XPI_VPW_6

`define UMCTL2_XPI_VPW_EN_7 0


// `define UMCTL2_XPI_VPW_7

`define UMCTL2_XPI_VPW_EN_8 0


// `define UMCTL2_XPI_VPW_8

`define UMCTL2_XPI_VPW_EN_9 0


// `define UMCTL2_XPI_VPW_9

`define UMCTL2_XPI_VPW_EN_10 0


// `define UMCTL2_XPI_VPW_10

`define UMCTL2_XPI_VPW_EN_11 0


// `define UMCTL2_XPI_VPW_11

`define UMCTL2_XPI_VPW_EN_12 0


// `define UMCTL2_XPI_VPW_12

`define UMCTL2_XPI_VPW_EN_13 0


// `define UMCTL2_XPI_VPW_13

`define UMCTL2_XPI_VPW_EN_14 0


// `define UMCTL2_XPI_VPW_14

`define UMCTL2_XPI_VPW_EN_15 0


// `define UMCTL2_XPI_VPW_15


// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_0
// Default:      Yes ((UMCTL2_A_AXI_0==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_0==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_0 1

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_1
// Default:      No ((UMCTL2_A_AXI_1==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_1==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_1 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_2
// Default:      No ((UMCTL2_A_AXI_2==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_2==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_2 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_3
// Default:      No ((UMCTL2_A_AXI_3==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_3==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_3 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_4
// Default:      No ((UMCTL2_A_AXI_4==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_4==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_4 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_5
// Default:      No ((UMCTL2_A_AXI_5==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_5==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_5 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_6
// Default:      No ((UMCTL2_A_AXI_6==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_6==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_6 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_7
// Default:      No ((UMCTL2_A_AXI_7==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_7==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_7 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_8
// Default:      No ((UMCTL2_A_AXI_8==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_8==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_8 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_9
// Default:      No ((UMCTL2_A_AXI_9==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_9==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 0 
//               : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_9 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_10
// Default:      No ((UMCTL2_A_AXI_10==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_10==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 
//               0 : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_10 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_11
// Default:      No ((UMCTL2_A_AXI_11==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_11==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 
//               0 : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_11 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_12
// Default:      No ((UMCTL2_A_AXI_12==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_12==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 
//               0 : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_12 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_13
// Default:      No ((UMCTL2_A_AXI_13==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_13==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 
//               0 : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_13 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_14
// Default:      No ((UMCTL2_A_AXI_14==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_14==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 
//               0 : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_14 0

// Name:         UMCTL2_READ_DATA_INTERLEAVE_EN_15
// Default:      No ((UMCTL2_A_AXI_15==0) ? 0 : 1)
// Values:       No (0), Yes (1)
// Enabled:      ((UMCTL2_A_AXI_15==0) || (UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==1)) ? 
//               0 : 1
// 
// This parameter enables the interleaving of the read data of transactions with different ARID fields. 
//  
//  - Read data interleaving may occur at memory burst boundaries. 
//  - Read data interleaving can be disabled if this parameter is set to 0. 
// If read data interleaving is disabled, read data reordering in Read Reorder Buffer may introduce further latency. 
// For example, a short AXI burst stays in the RRB buffer and does not interrupt a longer burst that has started earlier. 
//  - It is recommended to enable read data interleaving for improved read data latency.
`define UMCTL2_READ_DATA_INTERLEAVE_EN_15 0


// Name:         UMCTL2_INT_NPORTS
// Default:      1 (UMCTL2_A_NPORTS + UMCTL2_TOT_USE2RAQ + UMCTL2_SBR_EN)
// Values:       0, ..., 16
// Enabled:      0
// 
// Specifies the total number of ports as seen internally by the PA. It is an internal parameter provided in the GUI for 
// information purpose. A port is seen internally 
// as two ports if UMCTL2_XPI_USE2RAQ_n is set for that port. The ECC scrubber , 
// if enabled, is also seen as a port. 
// Thus, 
// UMCTL2_INT_NPORTS = UMCTL2_A_NPORTS + UMCTL2_TOT_USE2RAQ + UMCTL2_SBR_EN 
// where UMCTL2_TOT_USE2RAQ is sum of UMCTL2_XPI_USE2RAQ_n for all configured 
// ports.
`define UMCTL2_INT_NPORTS 1


// Name:         UMCTL2_INT_NPORTS_DATA
// Default:      1 (UMCTL2_A_NPORTS + UMCTL2_SBR_EN)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Total number of ports (Internal ports seen by the PA - data path)
`define UMCTL2_INT_NPORTS_DATA 1



`define UMCTL2_INT_NPORTS_0

// `define UMCTL2_INT_NPORTS_1

// `define UMCTL2_INT_NPORTS_2

// `define UMCTL2_INT_NPORTS_3

// `define UMCTL2_INT_NPORTS_4

// `define UMCTL2_INT_NPORTS_5

// `define UMCTL2_INT_NPORTS_6

// `define UMCTL2_INT_NPORTS_7

// `define UMCTL2_INT_NPORTS_8

// `define UMCTL2_INT_NPORTS_9

// `define UMCTL2_INT_NPORTS_10

// `define UMCTL2_INT_NPORTS_11

// `define UMCTL2_INT_NPORTS_12

// `define UMCTL2_INT_NPORTS_13

// `define UMCTL2_INT_NPORTS_14

// `define UMCTL2_INT_NPORTS_15


`define UMCTL2_XPI_USE_RMW 1


// Name:         UMCTL2_MAX_XPI_PORT_DW
// Default:      256 ([<functionof> UMCTL2_A_NPORTS])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determine maximum UMCTL2_A_PORT_DW_$ width of all ports.
`define UMCTL2_MAX_XPI_PORT_DW 256


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_16


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_32


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_64


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_128


`define UMCTL2_MAX_XPI_PORT_DW_GTEQ_256


// `define UMCTL2_MAX_XPI_PORT_DW_GTEQ_512


// Name:         UMCTL2_PORT_NBYTES_0
// Default:      32 (UMCTL2_PORT_DW_0/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_0 32

// Name:         UMCTL2_PORT_NBYTES_1
// Default:      32 (UMCTL2_PORT_DW_1/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_1 32

// Name:         UMCTL2_PORT_NBYTES_2
// Default:      32 (UMCTL2_PORT_DW_2/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_2 32

// Name:         UMCTL2_PORT_NBYTES_3
// Default:      32 (UMCTL2_PORT_DW_3/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_3 32

// Name:         UMCTL2_PORT_NBYTES_4
// Default:      32 (UMCTL2_PORT_DW_4/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_4 32

// Name:         UMCTL2_PORT_NBYTES_5
// Default:      32 (UMCTL2_PORT_DW_5/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_5 32

// Name:         UMCTL2_PORT_NBYTES_6
// Default:      32 (UMCTL2_PORT_DW_6/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_6 32

// Name:         UMCTL2_PORT_NBYTES_7
// Default:      32 (UMCTL2_PORT_DW_7/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_7 32

// Name:         UMCTL2_PORT_NBYTES_8
// Default:      32 (UMCTL2_PORT_DW_8/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_8 32

// Name:         UMCTL2_PORT_NBYTES_9
// Default:      32 (UMCTL2_PORT_DW_9/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_9 32

// Name:         UMCTL2_PORT_NBYTES_10
// Default:      32 (UMCTL2_PORT_DW_10/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_10 32

// Name:         UMCTL2_PORT_NBYTES_11
// Default:      32 (UMCTL2_PORT_DW_11/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_11 32

// Name:         UMCTL2_PORT_NBYTES_12
// Default:      32 (UMCTL2_PORT_DW_12/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_12 32

// Name:         UMCTL2_PORT_NBYTES_13
// Default:      32 (UMCTL2_PORT_DW_13/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_13 32

// Name:         UMCTL2_PORT_NBYTES_14
// Default:      32 (UMCTL2_PORT_DW_14/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_14 32

// Name:         UMCTL2_PORT_NBYTES_15
// Default:      32 (UMCTL2_PORT_DW_15/8)
// Values:       1 2 4 8 16 32 64
// Enabled:      0
// 
// UMCTL2_PORT_NBYTES_n: 
// Number of bytes in the DDRCTL application port n.
`define UMCTL2_PORT_NBYTES_15 32


`define UMCTL2_PORT_NBYTES_MAX 64


`define UMCTL2_A_AXI


`define UMCTL2_A_AXI4


// `define UMCTL2_A_AHB


`define UMCTL2_A_AXI_OR_AHB


`define UMCTL2_A_AXI_OR_AHB_EN 1


`define UMCTL2_A_AXI_OR_AHB_OR_CHB


`define UMCTL2_A_AXI_OR_CHB


`define THEREIS_PORT_DSIZE 1


`define THEREIS_PORT_USIZE 0



// Name:         UMCTL2_M_BLW
// Default:      4
// Values:       -2147483648, ..., 2147483647
// 
// Specifies the Memory burst length support. 
// (3 -> BL8; 4 -> BL16)
`define UMCTL2_M_BLW 4


// Name:         UMCTL2_A_LENW
// Default:      8 ((THEREIS_AXI4_PORT == 1) ? 8 : 4)
// Values:       4 5 6 7 8
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application burst length.
`define UMCTL2_A_LENW 8


`define UMCTL2_AXI_LOCK_WIDTH_0 1

`define UMCTL2_AXI_LOCK_WIDTH_1 1

`define UMCTL2_AXI_LOCK_WIDTH_2 1

`define UMCTL2_AXI_LOCK_WIDTH_3 1

`define UMCTL2_AXI_LOCK_WIDTH_4 1

`define UMCTL2_AXI_LOCK_WIDTH_5 1

`define UMCTL2_AXI_LOCK_WIDTH_6 1

`define UMCTL2_AXI_LOCK_WIDTH_7 1

`define UMCTL2_AXI_LOCK_WIDTH_8 1

`define UMCTL2_AXI_LOCK_WIDTH_9 1

`define UMCTL2_AXI_LOCK_WIDTH_10 1

`define UMCTL2_AXI_LOCK_WIDTH_11 1

`define UMCTL2_AXI_LOCK_WIDTH_12 1

`define UMCTL2_AXI_LOCK_WIDTH_13 1

`define UMCTL2_AXI_LOCK_WIDTH_14 1

`define UMCTL2_AXI_LOCK_WIDTH_15 1


// Name:         UMCTL2_AXI_USER_WIDTH
// Default:      0
// Values:       0, ..., 8
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// This parameter specifies the width of the application user signals.
`define UMCTL2_AXI_USER_WIDTH 0


// `define UMCTL2_AXI_USER_WIDTH_GT0


`define UMCTL2_AXI_USER_WIDTH_INT 1


`define UMCTL2_AXI_LOCK_WIDTH 2


`define UMCTL2_AXI_REGION_WIDTH 4


`define UMCTL2_XPI_NBEATS 2


`define UMCTL2_XPI_NBEATS_LG2 1


// Name:         UMCTL2_XPI_RP_INFOW_0
// Default:      19 ([<functionof> UMCTL2_PORT_DW_0 UMCTL2_A_DW_INT_0 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_0 19


`define UMCTL2_XPI_RP_HINFOW_0 23



`define UMCTL2_XPI_RD_INFOW_NSA_0 22


// Name:         UMCTL2_XPI_RD_INFOW_0
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_0 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0 UMCTL2_PORT_DW_0])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 0
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_0 22


// Name:         UMCTL2_XPI_WR_INFOW_0
// Default:      24 (UMCTL2_XPI_RP_HINFOW_0+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 0
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_0 24


// Name:         UMCTL2_XPI_RP_INFOW_1
// Default:      19 ([<functionof> UMCTL2_PORT_DW_1 UMCTL2_A_DW_INT_1 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_1 19


`define UMCTL2_XPI_RP_HINFOW_1 23



`define UMCTL2_XPI_RD_INFOW_NSA_1 22


// Name:         UMCTL2_XPI_RD_INFOW_1
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_1 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1 UMCTL2_PORT_DW_1])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 1
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_1 22


// Name:         UMCTL2_XPI_WR_INFOW_1
// Default:      24 (UMCTL2_XPI_RP_HINFOW_1+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 1
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_1 24


// Name:         UMCTL2_XPI_RP_INFOW_2
// Default:      19 ([<functionof> UMCTL2_PORT_DW_2 UMCTL2_A_DW_INT_2 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_2 19


`define UMCTL2_XPI_RP_HINFOW_2 23



`define UMCTL2_XPI_RD_INFOW_NSA_2 22


// Name:         UMCTL2_XPI_RD_INFOW_2
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_2 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2 UMCTL2_PORT_DW_2])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 2
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_2 22


// Name:         UMCTL2_XPI_WR_INFOW_2
// Default:      24 (UMCTL2_XPI_RP_HINFOW_2+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 2
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_2 24


// Name:         UMCTL2_XPI_RP_INFOW_3
// Default:      19 ([<functionof> UMCTL2_PORT_DW_3 UMCTL2_A_DW_INT_3 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_3 19


`define UMCTL2_XPI_RP_HINFOW_3 23



`define UMCTL2_XPI_RD_INFOW_NSA_3 22


// Name:         UMCTL2_XPI_RD_INFOW_3
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_3 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3 UMCTL2_PORT_DW_3])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 3
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_3 22


// Name:         UMCTL2_XPI_WR_INFOW_3
// Default:      24 (UMCTL2_XPI_RP_HINFOW_3+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 3
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_3 24


// Name:         UMCTL2_XPI_RP_INFOW_4
// Default:      19 ([<functionof> UMCTL2_PORT_DW_4 UMCTL2_A_DW_INT_4 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_4 19


`define UMCTL2_XPI_RP_HINFOW_4 23



`define UMCTL2_XPI_RD_INFOW_NSA_4 22


// Name:         UMCTL2_XPI_RD_INFOW_4
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_4 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4 UMCTL2_PORT_DW_4])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 4
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_4 22


// Name:         UMCTL2_XPI_WR_INFOW_4
// Default:      24 (UMCTL2_XPI_RP_HINFOW_4+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 4
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_4 24


// Name:         UMCTL2_XPI_RP_INFOW_5
// Default:      19 ([<functionof> UMCTL2_PORT_DW_5 UMCTL2_A_DW_INT_5 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_5 19


`define UMCTL2_XPI_RP_HINFOW_5 23



`define UMCTL2_XPI_RD_INFOW_NSA_5 22


// Name:         UMCTL2_XPI_RD_INFOW_5
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_5 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5 UMCTL2_PORT_DW_5])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 5
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_5 22


// Name:         UMCTL2_XPI_WR_INFOW_5
// Default:      24 (UMCTL2_XPI_RP_HINFOW_5+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 5
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_5 24


// Name:         UMCTL2_XPI_RP_INFOW_6
// Default:      19 ([<functionof> UMCTL2_PORT_DW_6 UMCTL2_A_DW_INT_6 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_6 19


`define UMCTL2_XPI_RP_HINFOW_6 23



`define UMCTL2_XPI_RD_INFOW_NSA_6 22


// Name:         UMCTL2_XPI_RD_INFOW_6
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_6 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6 UMCTL2_PORT_DW_6])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 6
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_6 22


// Name:         UMCTL2_XPI_WR_INFOW_6
// Default:      24 (UMCTL2_XPI_RP_HINFOW_6+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 6
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_6 24


// Name:         UMCTL2_XPI_RP_INFOW_7
// Default:      19 ([<functionof> UMCTL2_PORT_DW_7 UMCTL2_A_DW_INT_7 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_7 19


`define UMCTL2_XPI_RP_HINFOW_7 23



`define UMCTL2_XPI_RD_INFOW_NSA_7 22


// Name:         UMCTL2_XPI_RD_INFOW_7
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_7 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7 UMCTL2_PORT_DW_7])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 7
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_7 22


// Name:         UMCTL2_XPI_WR_INFOW_7
// Default:      24 (UMCTL2_XPI_RP_HINFOW_7+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 7
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_7 24


// Name:         UMCTL2_XPI_RP_INFOW_8
// Default:      19 ([<functionof> UMCTL2_PORT_DW_8 UMCTL2_A_DW_INT_8 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_8 19


`define UMCTL2_XPI_RP_HINFOW_8 23



`define UMCTL2_XPI_RD_INFOW_NSA_8 22


// Name:         UMCTL2_XPI_RD_INFOW_8
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_8 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8 UMCTL2_PORT_DW_8])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 8
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_8 22


// Name:         UMCTL2_XPI_WR_INFOW_8
// Default:      24 (UMCTL2_XPI_RP_HINFOW_8+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 8
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_8 24


// Name:         UMCTL2_XPI_RP_INFOW_9
// Default:      19 ([<functionof> UMCTL2_PORT_DW_9 UMCTL2_A_DW_INT_9 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_9 19


`define UMCTL2_XPI_RP_HINFOW_9 23



`define UMCTL2_XPI_RD_INFOW_NSA_9 22


// Name:         UMCTL2_XPI_RD_INFOW_9
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_9 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9 UMCTL2_PORT_DW_9])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 9
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_9 22


// Name:         UMCTL2_XPI_WR_INFOW_9
// Default:      24 (UMCTL2_XPI_RP_HINFOW_9+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 9
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_9 24


// Name:         UMCTL2_XPI_RP_INFOW_10
// Default:      19 ([<functionof> UMCTL2_PORT_DW_10 UMCTL2_A_DW_INT_10 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_10 19


`define UMCTL2_XPI_RP_HINFOW_10 23



`define UMCTL2_XPI_RD_INFOW_NSA_10 22


// Name:         UMCTL2_XPI_RD_INFOW_10
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_10 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10 UMCTL2_PORT_DW_10])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 10
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_10 22


// Name:         UMCTL2_XPI_WR_INFOW_10
// Default:      24 (UMCTL2_XPI_RP_HINFOW_10+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 10
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_10 24


// Name:         UMCTL2_XPI_RP_INFOW_11
// Default:      19 ([<functionof> UMCTL2_PORT_DW_11 UMCTL2_A_DW_INT_11 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_11 19


`define UMCTL2_XPI_RP_HINFOW_11 23



`define UMCTL2_XPI_RD_INFOW_NSA_11 22


// Name:         UMCTL2_XPI_RD_INFOW_11
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_11 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11 UMCTL2_PORT_DW_11])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 11
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_11 22


// Name:         UMCTL2_XPI_WR_INFOW_11
// Default:      24 (UMCTL2_XPI_RP_HINFOW_11+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 11
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_11 24


// Name:         UMCTL2_XPI_RP_INFOW_12
// Default:      19 ([<functionof> UMCTL2_PORT_DW_12 UMCTL2_A_DW_INT_12 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_12 19


`define UMCTL2_XPI_RP_HINFOW_12 23



`define UMCTL2_XPI_RD_INFOW_NSA_12 22


// Name:         UMCTL2_XPI_RD_INFOW_12
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_12 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12 UMCTL2_PORT_DW_12])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 12
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_12 22


// Name:         UMCTL2_XPI_WR_INFOW_12
// Default:      24 (UMCTL2_XPI_RP_HINFOW_12+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 12
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_12 24


// Name:         UMCTL2_XPI_RP_INFOW_13
// Default:      19 ([<functionof> UMCTL2_PORT_DW_13 UMCTL2_A_DW_INT_13 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_13 19


`define UMCTL2_XPI_RP_HINFOW_13 23



`define UMCTL2_XPI_RD_INFOW_NSA_13 22


// Name:         UMCTL2_XPI_RD_INFOW_13
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_13 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13 UMCTL2_PORT_DW_13])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 13
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_13 22


// Name:         UMCTL2_XPI_WR_INFOW_13
// Default:      24 (UMCTL2_XPI_RP_HINFOW_13+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 13
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_13 24


// Name:         UMCTL2_XPI_RP_INFOW_14
// Default:      19 ([<functionof> UMCTL2_PORT_DW_14 UMCTL2_A_DW_INT_14 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_14 19


`define UMCTL2_XPI_RP_HINFOW_14 23



`define UMCTL2_XPI_RD_INFOW_NSA_14 22


// Name:         UMCTL2_XPI_RD_INFOW_14
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_14 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14 UMCTL2_PORT_DW_14])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 14
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_14 22


// Name:         UMCTL2_XPI_WR_INFOW_14
// Default:      24 (UMCTL2_XPI_RP_HINFOW_14+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 14
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_14 24


// Name:         UMCTL2_XPI_RP_INFOW_15
// Default:      19 ([<functionof> UMCTL2_PORT_DW_15 UMCTL2_A_DW_INT_15 
//               UMCTL2_A_LENW])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// UMCTL2_XPI_RP_INFOW_n: 
// Defines XPI's e_arinfo and e_rinfo packet information width.
`define UMCTL2_XPI_RP_INFOW_15 19


`define UMCTL2_XPI_RP_HINFOW_15 23



`define UMCTL2_XPI_RD_INFOW_NSA_15 22


// Name:         UMCTL2_XPI_RD_INFOW_15
// Default:      22 ([<functionof> UMCTL2_XPI_RD_INFOW_NSA_15 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15 UMCTL2_PORT_DW_15])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 15
// 
// UMCTL2_XPI_RD_INFOW_n: 
// Defines XPI e_arinfo,e_rinfo width for port n.
`define UMCTL2_XPI_RD_INFOW_15 22


// Name:         UMCTL2_XPI_WR_INFOW_15
// Default:      24 (UMCTL2_XPI_RP_HINFOW_15+UMCTL2_XPI_NBEATS_LG2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_A_NPORTS > 15
// 
// UMCTL2_XPI_WR_INFOW_n: 
// Defines XPI e_awinfo,e_winfo width for port n.
`define UMCTL2_XPI_WR_INFOW_15 24




`define UMCTL2_TOKENW 5


// Name:         UMCTL2_AXI_ADDR_BOUNDARY
// Default:      12
// Values:       12, ..., 32
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the AXI address boundary restriction. 
// AXI transactions must not cross 2**AXI_ADDR_BOUNDARY bytes. 
// The default value of 12 matches the AXI specification of 4K boundary.
`define UMCTL2_AXI_ADDR_BOUNDARY 12


// Name:         UMCTL2_A_IDW
// Default:      8
// Values:       1, ..., 32
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application ID.
`define UMCTL2_A_IDW 8


`define UMCTL2_A_ID_MAPW 8

//This is the log2 of (UMCTL2_INT_NPORTS_DATA)

`define UMCTL2_A_NPORTS_LG2 1


`define UMCTL2_EXCL_ACC_FLAG 1

//This is beat info used in rrb to identify start,end beats number and interleave mode

`define UMCTL2_XPI_RD_BEAT_INFOW 4

//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_0 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_1 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_2 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_3 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_4 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_5 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_6 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_7 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_8 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_9 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_10 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_11 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_12 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_13 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_14 50
//fields in hif_cmd_token: bypass reorder(1 bit), rd info, xpi token , beat info, exclusive acc flags, poison (1 bit), ocp error (1 bit), read queue (1 bit), last(1 bit), ID, port number

`define UMCTL2_AXI_TAGBITS_15 50


// Name:         UMCTL2_MAX_AXI_TAGBITS
// Default:      50 ([<functionof> UMCTL2_A_NPORTS])
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determines the maximum UMCTL2_AXI_TAGBITS_$ width of all the ports.
`define UMCTL2_MAX_AXI_TAGBITS 50


// Name:         MEMC_HIF_TAGBITS
// Default:      5 (MEMC_NO_OF_ENTRY == 16 ? 4 : (MEMC_NO_OF_ENTRY == 32 ? 5 : 6))
// Values:       UMCTL2_TOKENW, ..., 128
// Enabled:      UMCTL2_INCL_ARB_OR_CHB == 0
// 
// Specifies the width of token bus. 
// By default, the CAM depth determines the width of the token bus. If an arbiter is present, you can increase the width 
// of the token bus to accommodate port and AXI IDs.
`define MEMC_HIF_TAGBITS 5


// Name:         DDRCTL_CHB_PREFETCH_EN
// Default:      0 ((DDRCTL_INCL_CHB==1)?1:0)
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// Enable Prefetch support
// `define DDRCTL_CHB_PREFETCH_EN


// Name:         DDRCTL_CHB_MAX_PRC_LINES
// Default:      8
// Values:       4 8 16 32
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// Number of prefetch entries
`define DDRCTL_CHB_MAX_PRC_LINES 8


// Name:         DDRCTL_CHB_DRBIDW
// Default:      5 ([ <functionof> MEMC_NO_OF_ENTRY ])
// Values:       -2147483648, ..., 2147483647
// 
// HIF Demand Read Buffer ID Width
`define DDRCTL_CHB_DRBIDW 5


// Name:         DDRCTL_CHB_MAX_NUM_HIF_BUF_PER_CLN
// Default:      2 
//               ((DDRCTL_CHB_XFRSZ*8)/(MEMC_DFI_DATA_WIDTH*DDRCTL_CHB_NUM_BEATS_BL8))
// Values:       -2147483648, ..., 2147483647
// 
// Max Number of HIF Buffers per CHI Cache Line 
// CHI cache line size selectable, 64B or 128B. 
// Min SDRAM Burst Size is a BL8.
`define DDRCTL_CHB_MAX_NUM_HIF_BUF_PER_CLN 2


// Name:         DDRCTL_CHB_PRBIDW
// Default:      4 ([ <functionof> [<functionof> 
//               DDRCTL_CHB_MAX_PRC_LINES*DDRCTL_CHB_MAX_NUM_HIF_BUF_PER_CLN] ])
// Values:       -2147483648, ..., 2147483647
// 
// Prefetch Buffer ID Width
`define DDRCTL_CHB_PRBIDW 4


// Name:         DDRCTL_CHB_BIDW
// Default:      6 ((DDRCTL_CHB_DRBIDW > DDRCTL_CHB_PRBIDW ? DDRCTL_CHB_DRBIDW : 
//               DDRCTL_CHB_PRBIDW)+1)
// Values:       -2147483648, ..., 2147483647
// 
// HIF Read Command Token Buffer ID Width 
// If Prefetch is enabled then the MSB, if set, indicates the Buffer ID is associated with a read to a prefetch HIF Buffer.
`define DDRCTL_CHB_BIDW 6


// Name:         UMCTL2_CHB_TAGBITS
// Default:      15 (1 + DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS_CLOG2+1 + 
//               DDRCTL_CHB_NUM_BEATS_BL_LOG2 + DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT_CLOG2 + 
//               DDRCTL_CHB_BIDW + 1 + ( DDRCTL_CHB_TZ_EN ? 1 : 0 ))
// Values:       -2147483648, ..., 2147483647
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// Determines the width of token bus. 
// {sbr_hif_addr, readprefetchreq, numchunks, chunknum,  chunkstrb, buffer_id, readdatasource}
`define UMCTL2_CHB_TAGBITS 15


// Name:         MEMC_TAGBITS
// Default:      50 ((UMCTL2_INCL_ARB_OR_CHB == 0) ? MEMC_HIF_TAGBITS : 
//               (DDRCTL_INCL_CHB == 1) ? UMCTL2_CHB_TAGBITS : UMCTL2_MAX_AXI_TAGBITS)
// Values:       UMCTL2_TOKENW, ..., 128
// 
// Tag width at ddrc interface
`define MEMC_TAGBITS 50


// Name:         MEMC_HIF_WDATA_PTR_BITS
// Default:      1
// Values:       1, ..., 128
// Enabled:      UMCTL2_INCL_ARB_OR_CHB == 0
// 
// Specifies the number of bits provided for write pointers (sent to the controller with write commands, and later returned 
// to the interface to enable data fetches). 
// If an arbiter is present, you can override the width of the write pointer to accommodate port and AXI IDs.
`define MEMC_HIF_WDATA_PTR_BITS 1


`define UMCTL2_SEQ_BURST_MODE 1


// Name:         UMCTL2_AXI_LOWPWR_NOPX_CNT
// Default:      0
// Values:       0, ..., 1048576
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// This parameter specifies the number of cycles after the 
// last active transaction to de-assertion of the cactive signal.
`define UMCTL2_AXI_LOWPWR_NOPX_CNT 0

//UMCTL2_A_QOSW:
//Specifies the width of the Application QOS.
`define UMCTL2_A_QOSW 4


// Name:         UMCTL2_PORT_DW_TABLE
// Default:      0x20040080100200400801002004008010020040080100 
//               ((UMCTL2_PORT_DW_15<<165) + (UMCTL2_PORT_DW_14<<154) + (UMCTL2_PORT_DW_13<<143) + 
//               (UMCTL2_PORT_DW_12<<132) + (UMCTL2_PORT_DW_11<<121) + 
//               (UMCTL2_PORT_DW_10<<110) + (UMCTL2_PORT_DW_9<<99) + (UMCTL2_PORT_DW_8<<88) + 
//               (UMCTL2_PORT_DW_7<<77) + (UMCTL2_PORT_DW_6<<66) + (UMCTL2_PORT_DW_5<<55) + 
//               (UMCTL2_PORT_DW_4<<44) + (UMCTL2_PORT_DW_3<<33) + (UMCTL2_PORT_DW_2<<22) + 
//               (UMCTL2_PORT_DW_1<<11) + UMCTL2_PORT_DW_0)
// Values:       0x0, ..., 0xffffffffffffffffffffffffffffffffffffffffffff
// 
// Datawidth table built from each hosts datawidth
`define UMCTL2_PORT_DW_TABLE 176'h20040080100200400801002004008010020040080100


// Name:         UMCTL2_A_SYNC_0
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>0 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_0 0

// Name:         UMCTL2_A_SYNC_1
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>1 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_1 0

// Name:         UMCTL2_A_SYNC_2
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>2 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_2 0

// Name:         UMCTL2_A_SYNC_3
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>3 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_3 0

// Name:         UMCTL2_A_SYNC_4
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>4 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_4 0

// Name:         UMCTL2_A_SYNC_5
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>5 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_5 0

// Name:         UMCTL2_A_SYNC_6
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>6 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_6 0

// Name:         UMCTL2_A_SYNC_7
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>7 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_7 0

// Name:         UMCTL2_A_SYNC_8
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>8 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_8 0

// Name:         UMCTL2_A_SYNC_9
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>9 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_9 0

// Name:         UMCTL2_A_SYNC_10
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>10 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_10 0

// Name:         UMCTL2_A_SYNC_11
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>11 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_11 0

// Name:         UMCTL2_A_SYNC_12
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>12 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_12 0

// Name:         UMCTL2_A_SYNC_13
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>13 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_13 0

// Name:         UMCTL2_A_SYNC_14
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>14 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_14 0

// Name:         UMCTL2_A_SYNC_15
// Default:      Asynchronous (UMCTL2_INCL_ARB==1) ? 0 : (DDRCTL_CHB_SYNC_MODE)
// Values:       Asynchronous (0), Synchronous (1)
// Enabled:      UMCTL2_A_NPORTS>15 && UMCTL2_INCL_ARB==1
// 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk. If specified to be asynchronous, clock domain crossing 
// logic is included in the design, which increases the latency and area. 
// A port's clock (aclk_n or hclk_n) is considered synchronous when: 
//  - It is phase aligned and 
//  - Equal frequency to the controller core_ddrc_core_clk
`define UMCTL2_A_SYNC_15 0


// Name:         UMCTL2_AP_ASYNC_0
// Default:      Asynchronous (((UMCTL2_A_SYNC_0==0 && UMCTL2_A_AXI_0!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_0 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_0


`define UMCTL2_AP_ASYNC_A_0 1

// Name:         UMCTL2_AP_ASYNC_1
// Default:      Asynchronous (((UMCTL2_A_SYNC_1==0 && UMCTL2_A_AXI_1!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_1 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_1


`define UMCTL2_AP_ASYNC_A_1 1

// Name:         UMCTL2_AP_ASYNC_2
// Default:      Asynchronous (((UMCTL2_A_SYNC_2==0 && UMCTL2_A_AXI_2!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_2 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_2


`define UMCTL2_AP_ASYNC_A_2 1

// Name:         UMCTL2_AP_ASYNC_3
// Default:      Asynchronous (((UMCTL2_A_SYNC_3==0 && UMCTL2_A_AXI_3!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_3 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_3


`define UMCTL2_AP_ASYNC_A_3 1

// Name:         UMCTL2_AP_ASYNC_4
// Default:      Asynchronous (((UMCTL2_A_SYNC_4==0 && UMCTL2_A_AXI_4!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_4 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_4


`define UMCTL2_AP_ASYNC_A_4 1

// Name:         UMCTL2_AP_ASYNC_5
// Default:      Asynchronous (((UMCTL2_A_SYNC_5==0 && UMCTL2_A_AXI_5!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_5 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_5


`define UMCTL2_AP_ASYNC_A_5 1

// Name:         UMCTL2_AP_ASYNC_6
// Default:      Asynchronous (((UMCTL2_A_SYNC_6==0 && UMCTL2_A_AXI_6!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_6 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_6


`define UMCTL2_AP_ASYNC_A_6 1

// Name:         UMCTL2_AP_ASYNC_7
// Default:      Asynchronous (((UMCTL2_A_SYNC_7==0 && UMCTL2_A_AXI_7!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_7 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_7


`define UMCTL2_AP_ASYNC_A_7 1

// Name:         UMCTL2_AP_ASYNC_8
// Default:      Asynchronous (((UMCTL2_A_SYNC_8==0 && UMCTL2_A_AXI_8!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_8 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_8


`define UMCTL2_AP_ASYNC_A_8 1

// Name:         UMCTL2_AP_ASYNC_9
// Default:      Asynchronous (((UMCTL2_A_SYNC_9==0 && UMCTL2_A_AXI_9!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_9 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_9


`define UMCTL2_AP_ASYNC_A_9 1

// Name:         UMCTL2_AP_ASYNC_10
// Default:      Asynchronous (((UMCTL2_A_SYNC_10==0 && UMCTL2_A_AXI_10!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_10 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_10


`define UMCTL2_AP_ASYNC_A_10 1

// Name:         UMCTL2_AP_ASYNC_11
// Default:      Asynchronous (((UMCTL2_A_SYNC_11==0 && UMCTL2_A_AXI_11!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_11 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_11


`define UMCTL2_AP_ASYNC_A_11 1

// Name:         UMCTL2_AP_ASYNC_12
// Default:      Asynchronous (((UMCTL2_A_SYNC_12==0 && UMCTL2_A_AXI_12!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_12 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_12


`define UMCTL2_AP_ASYNC_A_12 1

// Name:         UMCTL2_AP_ASYNC_13
// Default:      Asynchronous (((UMCTL2_A_SYNC_13==0 && UMCTL2_A_AXI_13!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_13 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_13


`define UMCTL2_AP_ASYNC_A_13 1

// Name:         UMCTL2_AP_ASYNC_14
// Default:      Asynchronous (((UMCTL2_A_SYNC_14==0 && UMCTL2_A_AXI_14!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_14 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_14


`define UMCTL2_AP_ASYNC_A_14 1

// Name:         UMCTL2_AP_ASYNC_15
// Default:      Asynchronous (((UMCTL2_A_SYNC_15==0 && UMCTL2_A_AXI_15!=0) || 
//               UMCTL2_P_ASYNC_EN==1) ? 1 : 0)
// Values:       Synchronous (0), Asynchronous (1)
// Enabled:      UMCTL2_A_AXI_15 != 0
// 
// UMCTL2_AP_ASYNC_n: 
// Defines the port n clock to be synchronous or asynchronous with respect to 
// the controller core_ddrc_core_clk and pclk. 
// It is a derived parameter (from UMCTL2_A_SYNC_n and UMCTL2_P_ASYNC_EN). 
// UMCTL2_A_SYNC_n   defines the synchronism of port clock to core clock 
// UMCTL2_P_ASYNC_EN defines the synchronism of APB  clock to core clock 
// Port clock is asynchronous to APB clock and core clock 
// when port clock is async to core clock or APB clock is async to core clock.
`define UMCTL2_AP_ASYNC_15


`define UMCTL2_AP_ASYNC_A_15 1


// Name:         UMCTL2_USE_SCANMODE
// Default:      1 ([<functionof> UMCTL2_A_NPORTS UMCTL2_P_ASYNC_EN])
// Values:       0, 1
// 
// Scan mode port is used when any AXI clock is asynchronous to core clock 
// or APB clock is asynchronous to core clock.
`define UMCTL2_USE_SCANMODE


`define UMCTL2_AP_ANY_ASYNC 1


// Name:         UMCTL2_ASYNC_REG_N_SYNC
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_AP_ANY_ASYNC == 1
// 
// This parameter defines the number of synchronization stages for APB synchronizers. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_REG_N_SYNC 2


// Name:         UMCTL2_ASYNC_DDRC_N_SYNC
// Default:      2
// Values:       2 3 4
// Enabled:      Always
// 
// This parameter specifies the number of synchronization stages for DDRC synchronizers (for asynchronous inputs directly 
// to DDRC). 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_DDRC_N_SYNC 2


// Name:         UMCTL2_ASYNC_LP4DCI_N_SYNC
// Default:      2
// Values:       2 3 4
// Enabled:      DDRCTL_LPDDR==1 && UMCTL2_LPDDR4_DUAL_CHANNEL==0
// 
// This parameter specifies the number of synchronization stages for LPDDR4 Initialization Handshake Interface 
// synchronizers. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_LP4DCI_N_SYNC 2


`define RM_BCM25 0


`define RM_BCM23 0


`define RM_BCM36_NHS 0


`define UMCTL2_BCM36_NHS_DELAY 3


`define UMCTL2_BCM36_NHS_INJECT_X 0


// Name:         DWC_NO_TST_MODE
// Default:      1
// Values:       0, 1
// 
// Spcifies that test input for bcms is not required.
`define DWC_NO_TST_MODE



// Name:         UMCTL2_A_SYNC_TABLE
// Default:      0x0 ( (UMCTL2_A_SYNC_15<<15) + (UMCTL2_A_SYNC_14<<14) + 
//               (UMCTL2_A_SYNC_13<<13) + (UMCTL2_A_SYNC_12<<12) + (UMCTL2_A_SYNC_11<<11) + 
//               (UMCTL2_A_SYNC_10<<10) + (UMCTL2_A_SYNC_9<<9) + (UMCTL2_A_SYNC_8<<8) + 
//               (UMCTL2_A_SYNC_7<<7) + (UMCTL2_A_SYNC_6<<6) + (UMCTL2_A_SYNC_5<<5) + 
//               (UMCTL2_A_SYNC_4<<4) + (UMCTL2_A_SYNC_3<<3) + (UMCTL2_A_SYNC_2<<2) + 
//               (UMCTL2_A_SYNC_1<<1) + UMCTL2_A_SYNC_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_A_SYNC_<n>
`define UMCTL2_A_SYNC_TABLE 16'h0


// Name:         UMCTL2_AP_ASYNC_TABLE
// Default:      0xffff ( (UMCTL2_AP_ASYNC_A_15<<15) + (UMCTL2_AP_ASYNC_A_14<<14) + 
//               (UMCTL2_AP_ASYNC_A_13<<13) + (UMCTL2_AP_ASYNC_A_12<<12) + 
//               (UMCTL2_AP_ASYNC_A_11<<11) + (UMCTL2_AP_ASYNC_A_10<<10) + 
//               (UMCTL2_AP_ASYNC_A_9<<9) + (UMCTL2_AP_ASYNC_A_8<<8) + (UMCTL2_AP_ASYNC_A_7<<7) + 
//               (UMCTL2_AP_ASYNC_A_6<<6) + (UMCTL2_AP_ASYNC_A_5<<5) + (UMCTL2_AP_ASYNC_A_4<<4) 
//               + (UMCTL2_AP_ASYNC_A_3<<3) + (UMCTL2_AP_ASYNC_A_2<<2) + 
//               (UMCTL2_AP_ASYNC_A_1<<1) + UMCTL2_AP_ASYNC_A_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_AP_ASYNC_A_<n>
`define UMCTL2_AP_ASYNC_TABLE 16'hffff


// Name:         UMCTL2_A_DIR_0
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_0 0

// Name:         UMCTL2_A_DIR_1
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_1 0

// Name:         UMCTL2_A_DIR_2
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_2 0

// Name:         UMCTL2_A_DIR_3
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_3 0

// Name:         UMCTL2_A_DIR_4
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_4 0

// Name:         UMCTL2_A_DIR_5
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_5 0

// Name:         UMCTL2_A_DIR_6
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_6 0

// Name:         UMCTL2_A_DIR_7
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_7 0

// Name:         UMCTL2_A_DIR_8
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_8 0

// Name:         UMCTL2_A_DIR_9
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_9 0

// Name:         UMCTL2_A_DIR_10
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_10 0

// Name:         UMCTL2_A_DIR_11
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_11 0

// Name:         UMCTL2_A_DIR_12
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_12 0

// Name:         UMCTL2_A_DIR_13
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_13 0

// Name:         UMCTL2_A_DIR_14
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_14 0

// Name:         UMCTL2_A_DIR_15
// Default:      Read-Write
// Values:       Read-Write (0), Read-only (1), Write-only (2)
// Enabled:      0
// 
// UMCTL2_A_DIR_n: 
// Defines the direction of the DDRCTL application port n. 
// If read-only or write-only is selected, the amount of logic instantiated is reduced.
`define UMCTL2_A_DIR_15 0


// Name:         UMCTL2_STATIC_VIR_CH_0
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>0 && (UMCTL2_A_TYPE_0 == 1 || UMCTL2_A_TYPE_0 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_0 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_0 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_0 0

// Name:         UMCTL2_STATIC_VIR_CH_1
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>1 && (UMCTL2_A_TYPE_1 == 1 || UMCTL2_A_TYPE_1 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_1 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_1 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_1 0

// Name:         UMCTL2_STATIC_VIR_CH_2
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>2 && (UMCTL2_A_TYPE_2 == 1 || UMCTL2_A_TYPE_2 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_2 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_2 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_2 0

// Name:         UMCTL2_STATIC_VIR_CH_3
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>3 && (UMCTL2_A_TYPE_3 == 1 || UMCTL2_A_TYPE_3 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_3 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_3 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_3 0

// Name:         UMCTL2_STATIC_VIR_CH_4
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>4 && (UMCTL2_A_TYPE_4 == 1 || UMCTL2_A_TYPE_4 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_4 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_4 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_4 0

// Name:         UMCTL2_STATIC_VIR_CH_5
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>5 && (UMCTL2_A_TYPE_5 == 1 || UMCTL2_A_TYPE_5 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_5 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_5 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_5 0

// Name:         UMCTL2_STATIC_VIR_CH_6
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>6 && (UMCTL2_A_TYPE_6 == 1 || UMCTL2_A_TYPE_6 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_6 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_6 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_6 0

// Name:         UMCTL2_STATIC_VIR_CH_7
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>7 && (UMCTL2_A_TYPE_7 == 1 || UMCTL2_A_TYPE_7 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_7 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_7 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_7 0

// Name:         UMCTL2_STATIC_VIR_CH_8
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>8 && (UMCTL2_A_TYPE_8 == 1 || UMCTL2_A_TYPE_8 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_8 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_8 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_8 0

// Name:         UMCTL2_STATIC_VIR_CH_9
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>9 && (UMCTL2_A_TYPE_9 == 1 || UMCTL2_A_TYPE_9 == 3) 
//               && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 && 
//               (UMCTL2_XPI_USE2RAQ_9 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_9 == 1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_9 0

// Name:         UMCTL2_STATIC_VIR_CH_10
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>10 && (UMCTL2_A_TYPE_10 == 1 || UMCTL2_A_TYPE_10 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 
//               && (UMCTL2_XPI_USE2RAQ_10 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_10 == 
//               1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_10 0

// Name:         UMCTL2_STATIC_VIR_CH_11
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>11 && (UMCTL2_A_TYPE_11 == 1 || UMCTL2_A_TYPE_11 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 
//               && (UMCTL2_XPI_USE2RAQ_11 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_11 == 
//               1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_11 0

// Name:         UMCTL2_STATIC_VIR_CH_12
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>12 && (UMCTL2_A_TYPE_12 == 1 || UMCTL2_A_TYPE_12 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 
//               && (UMCTL2_XPI_USE2RAQ_12 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_12 == 
//               1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_12 0

// Name:         UMCTL2_STATIC_VIR_CH_13
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>13 && (UMCTL2_A_TYPE_13 == 1 || UMCTL2_A_TYPE_13 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 
//               && (UMCTL2_XPI_USE2RAQ_13 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_13 == 
//               1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_13 0

// Name:         UMCTL2_STATIC_VIR_CH_14
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>14 && (UMCTL2_A_TYPE_14 == 1 || UMCTL2_A_TYPE_14 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 
//               && (UMCTL2_XPI_USE2RAQ_14 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_14 == 
//               1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_14 0

// Name:         UMCTL2_STATIC_VIR_CH_15
// Default:      No
// Values:       No (0), Yes (1)
// Enabled:      UMCTL2_A_NPORTS>15 && (UMCTL2_A_TYPE_15 == 1 || UMCTL2_A_TYPE_15 == 
//               3) && UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0 
//               && (UMCTL2_XPI_USE2RAQ_15 == 0 || UMCTL2_READ_DATA_INTERLEAVE_EN_15 == 
//               1)
// 
// This parameter enables static virtual channels mapping for port n.
`define UMCTL2_STATIC_VIR_CH_15 0


// Name:         UMCTL2_STATIC_VIR_CH_TABLE
// Default:      0x0 ((UMCTL2_STATIC_VIR_CH_15<<15) + (UMCTL2_STATIC_VIR_CH_14<<14) 
//               + (UMCTL2_STATIC_VIR_CH_13<<13) + (UMCTL2_STATIC_VIR_CH_12<<12) + 
//               (UMCTL2_STATIC_VIR_CH_11<<11) + (UMCTL2_STATIC_VIR_CH_10<<10) + 
//               (UMCTL2_STATIC_VIR_CH_9<<9) + (UMCTL2_STATIC_VIR_CH_8<<8) + 
//               (UMCTL2_STATIC_VIR_CH_7<<7) + (UMCTL2_STATIC_VIR_CH_6<<6) + 
//               (UMCTL2_STATIC_VIR_CH_5<<5) + (UMCTL2_STATIC_VIR_CH_4<<4) + (UMCTL2_STATIC_VIR_CH_3<<3) + 
//               (UMCTL2_STATIC_VIR_CH_2<<2) + (UMCTL2_STATIC_VIR_CH_1<<1) + 
//               UMCTL2_STATIC_VIR_CH_0)
// Values:       0x0, ..., 0xffff
// 
// Table built from static virtual channels mapping for port $
`define UMCTL2_STATIC_VIR_CH_TABLE 16'h0


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_0
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_0 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_0 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_1
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_1 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_1 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_2
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_2 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_2 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_3
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_3 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_3 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_4
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_4 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_4 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_5
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_5 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_5 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_6
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_6 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_6 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_7
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_7 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_7 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_8
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_8 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_8 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_9
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_9 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_9 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_10
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_10 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_10 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_11
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_11 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_11 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_12
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_12 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_12 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_13
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_13 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_13 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_14
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_14 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_14 1


// Name:         UMCTL2_XPI_SMALL_SIZED_PORT_15
// Default:      1 ((DDRCTL_MIN_DRAM_XSIZE < UMCTL2_PORT_DW_15 ) ? 1 : 0)
// Values:       0, 1
// 
// Indicates if there can be a small-sized burst for the port .
`define UMCTL2_XPI_SMALL_SIZED_PORT_15 1




// Name:         UMCTL2_NUM_VIR_CH_0
// Default:      32 ((UMCTL2_XPI_USE2RAQ_0 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_0 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_0==1 && 
//               UMCTL2_XPI_USE2RAQ_0 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>0 && (UMCTL2_A_TYPE_0 == 1 || UMCTL2_A_TYPE_0 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_0 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_0 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_0 32

// Name:         UMCTL2_NUM_VIR_CH_1
// Default:      32 ((UMCTL2_XPI_USE2RAQ_1 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_1 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_1==1 && 
//               UMCTL2_XPI_USE2RAQ_1 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>1 && (UMCTL2_A_TYPE_1 == 1 || UMCTL2_A_TYPE_1 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_1 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_1 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_1 32

// Name:         UMCTL2_NUM_VIR_CH_2
// Default:      32 ((UMCTL2_XPI_USE2RAQ_2 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_2 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_2==1 && 
//               UMCTL2_XPI_USE2RAQ_2 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>2 && (UMCTL2_A_TYPE_2 == 1 || UMCTL2_A_TYPE_2 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_2 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_2 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_2 32

// Name:         UMCTL2_NUM_VIR_CH_3
// Default:      32 ((UMCTL2_XPI_USE2RAQ_3 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_3 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_3==1 && 
//               UMCTL2_XPI_USE2RAQ_3 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>3 && (UMCTL2_A_TYPE_3 == 1 || UMCTL2_A_TYPE_3 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_3 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_3 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_3 32

// Name:         UMCTL2_NUM_VIR_CH_4
// Default:      32 ((UMCTL2_XPI_USE2RAQ_4 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_4 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_4==1 && 
//               UMCTL2_XPI_USE2RAQ_4 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>4 && (UMCTL2_A_TYPE_4 == 1 || UMCTL2_A_TYPE_4 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_4 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_4 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_4 32

// Name:         UMCTL2_NUM_VIR_CH_5
// Default:      32 ((UMCTL2_XPI_USE2RAQ_5 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_5 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_5==1 && 
//               UMCTL2_XPI_USE2RAQ_5 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>5 && (UMCTL2_A_TYPE_5 == 1 || UMCTL2_A_TYPE_5 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_5 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_5 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_5 32

// Name:         UMCTL2_NUM_VIR_CH_6
// Default:      32 ((UMCTL2_XPI_USE2RAQ_6 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_6 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_6==1 && 
//               UMCTL2_XPI_USE2RAQ_6 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>6 && (UMCTL2_A_TYPE_6 == 1 || UMCTL2_A_TYPE_6 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_6 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_6 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_6 32

// Name:         UMCTL2_NUM_VIR_CH_7
// Default:      32 ((UMCTL2_XPI_USE2RAQ_7 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_7 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_7==1 && 
//               UMCTL2_XPI_USE2RAQ_7 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>7 && (UMCTL2_A_TYPE_7 == 1 || UMCTL2_A_TYPE_7 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_7 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_7 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_7 32

// Name:         UMCTL2_NUM_VIR_CH_8
// Default:      32 ((UMCTL2_XPI_USE2RAQ_8 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_8 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_8==1 && 
//               UMCTL2_XPI_USE2RAQ_8 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>8 && (UMCTL2_A_TYPE_8 == 1 || UMCTL2_A_TYPE_8 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_8 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_8 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_8 32

// Name:         UMCTL2_NUM_VIR_CH_9
// Default:      32 ((UMCTL2_XPI_USE2RAQ_9 == 1 && UMCTL2_READ_DATA_INTERLEAVE_EN_9 
//               == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_9==1 && 
//               UMCTL2_XPI_USE2RAQ_9 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>9 && (UMCTL2_A_TYPE_9 == 1 || UMCTL2_A_TYPE_9 == 3) 
//               && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_9 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_9 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_9 32

// Name:         UMCTL2_NUM_VIR_CH_10
// Default:      32 ((UMCTL2_XPI_USE2RAQ_10 == 1 && 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_10 == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_10==1 && 
//               UMCTL2_XPI_USE2RAQ_10 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>10 && (UMCTL2_A_TYPE_10 == 1 || UMCTL2_A_TYPE_10 == 
//               3) && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_10 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_10 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_10 32

// Name:         UMCTL2_NUM_VIR_CH_11
// Default:      32 ((UMCTL2_XPI_USE2RAQ_11 == 1 && 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_11 == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_11==1 && 
//               UMCTL2_XPI_USE2RAQ_11 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>11 && (UMCTL2_A_TYPE_11 == 1 || UMCTL2_A_TYPE_11 == 
//               3) && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_11 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_11 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_11 32

// Name:         UMCTL2_NUM_VIR_CH_12
// Default:      32 ((UMCTL2_XPI_USE2RAQ_12 == 1 && 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_12 == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_12==1 && 
//               UMCTL2_XPI_USE2RAQ_12 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>12 && (UMCTL2_A_TYPE_12 == 1 || UMCTL2_A_TYPE_12 == 
//               3) && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_12 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_12 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_12 32

// Name:         UMCTL2_NUM_VIR_CH_13
// Default:      32 ((UMCTL2_XPI_USE2RAQ_13 == 1 && 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_13 == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_13==1 && 
//               UMCTL2_XPI_USE2RAQ_13 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>13 && (UMCTL2_A_TYPE_13 == 1 || UMCTL2_A_TYPE_13 == 
//               3) && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_13 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_13 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_13 32

// Name:         UMCTL2_NUM_VIR_CH_14
// Default:      32 ((UMCTL2_XPI_USE2RAQ_14 == 1 && 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_14 == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_14==1 && 
//               UMCTL2_XPI_USE2RAQ_14 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>14 && (UMCTL2_A_TYPE_14 == 1 || UMCTL2_A_TYPE_14 == 
//               3) && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_14 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_14 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_14 32

// Name:         UMCTL2_NUM_VIR_CH_15
// Default:      32 ((UMCTL2_XPI_USE2RAQ_15 == 1 && 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_15 == 0) ? MEMC_NO_OF_ENTRY : (UMCTL2_XPI_SMALL_SIZED_PORT_15==1 && 
//               UMCTL2_XPI_USE2RAQ_15 ==1) ? MEMC_NO_OF_ENTRY/2 : 32)
// Values:       1, ..., 64
// Enabled:      UMCTL2_A_NPORTS>15 && (UMCTL2_A_TYPE_15 == 1 || UMCTL2_A_TYPE_15 == 
//               3) && UMCTL2_INCL_ARB == 1 && (UMCTL2_XPI_USE2RAQ_15 == 0 || 
//               UMCTL2_READ_DATA_INTERLEAVE_EN_15 == 1)
// 
// This parameter defines the number of virtual channels for port n.
`define UMCTL2_NUM_VIR_CH_15 32


// Name:         UMCTL2_NUM_VIR_CH_TABLE
// Default:      0x4081020408102040810204081020 ((UMCTL2_NUM_VIR_CH_15<<105) + 
//               (UMCTL2_NUM_VIR_CH_14<<98) + (UMCTL2_NUM_VIR_CH_13<<91) + 
//               (UMCTL2_NUM_VIR_CH_12<<84) + (UMCTL2_NUM_VIR_CH_11<<77) + (UMCTL2_NUM_VIR_CH_10<<70) 
//               + (UMCTL2_NUM_VIR_CH_9<<63) + (UMCTL2_NUM_VIR_CH_8<<56) + 
//               (UMCTL2_NUM_VIR_CH_7<<49) + (UMCTL2_NUM_VIR_CH_6<<42) + 
//               (UMCTL2_NUM_VIR_CH_5<<35) + (UMCTL2_NUM_VIR_CH_4<<28) + (UMCTL2_NUM_VIR_CH_3<<21) + 
//               (UMCTL2_NUM_VIR_CH_2<<14) + (UMCTL2_NUM_VIR_CH_1<<7) + UMCTL2_NUM_VIR_CH_0)
// Values:       0x0, ..., 0xffffffffffffffffffffffffffff
// 
// UMCTL2_PORT_DW_TABLE: 
// Datawidth table built from each hosts datawidth
`define UMCTL2_NUM_VIR_CH_TABLE 112'h4081020408102040810204081020


// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_0
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>0 && UMCTL2_A_SYNC_0==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_0 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_1
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>1 && UMCTL2_A_SYNC_1==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_1 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_2
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>2 && UMCTL2_A_SYNC_2==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_2 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_3
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>3 && UMCTL2_A_SYNC_3==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_3 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_4
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>4 && UMCTL2_A_SYNC_4==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_4 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_5
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>5 && UMCTL2_A_SYNC_5==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_5 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_6
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>6 && UMCTL2_A_SYNC_6==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_6 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_7
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>7 && UMCTL2_A_SYNC_7==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_7 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_8
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>8 && UMCTL2_A_SYNC_8==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_8 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_9
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>9 && UMCTL2_A_SYNC_9==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_9 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_10
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>10 && UMCTL2_A_SYNC_10==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_10 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_11
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>11 && UMCTL2_A_SYNC_11==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_11 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_12
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>12 && UMCTL2_A_SYNC_12==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_12 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_13
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>13 && UMCTL2_A_SYNC_13==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_13 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_14
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>14 && UMCTL2_A_SYNC_14==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_14 2

// Name:         UMCTL2_ASYNC_FIFO_N_SYNC_15
// Default:      2
// Values:       2 3 4
// Enabled:      UMCTL2_A_NPORTS>15 && UMCTL2_A_SYNC_15==0 && UMCTL2_INCL_ARB == 1
// 
// This parameter defines the number of synchronization stages for the 
// asynchronous FIFOs of port n. Applies to both the pop side and 
// the push side. 
//  - 2: Double synchronized 
//  - 3: Triple synchronized 
//  - 4: Quadruple synchronized
`define UMCTL2_ASYNC_FIFO_N_SYNC_15 2


// Name:         UMCTL2_RRB_THRESHOLD_EN_0
// Default:      Disable ((UMCTL2_A_NPORTS >= (0+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_0 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_0 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_0 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_0 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_0


`define UMCTL2_RRB_THRESHOLD_PPL_0 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_1
// Default:      Disable ((UMCTL2_A_NPORTS >= (1+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_1 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_1 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_1 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_1 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_1


`define UMCTL2_RRB_THRESHOLD_PPL_1 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_2
// Default:      Disable ((UMCTL2_A_NPORTS >= (2+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_2 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_2 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_2 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_2 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_2


`define UMCTL2_RRB_THRESHOLD_PPL_2 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_3
// Default:      Disable ((UMCTL2_A_NPORTS >= (3+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_3 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_3 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_3 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_3 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_3


`define UMCTL2_RRB_THRESHOLD_PPL_3 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_4
// Default:      Disable ((UMCTL2_A_NPORTS >= (4+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_4 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_4 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_4 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_4 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_4


`define UMCTL2_RRB_THRESHOLD_PPL_4 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_5
// Default:      Disable ((UMCTL2_A_NPORTS >= (5+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_5 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_5 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_5 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_5 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_5


`define UMCTL2_RRB_THRESHOLD_PPL_5 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_6
// Default:      Disable ((UMCTL2_A_NPORTS >= (6+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_6 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_6 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_6 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_6 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_6


`define UMCTL2_RRB_THRESHOLD_PPL_6 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_7
// Default:      Disable ((UMCTL2_A_NPORTS >= (7+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_7 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_7 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_7 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_7 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_7


`define UMCTL2_RRB_THRESHOLD_PPL_7 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_8
// Default:      Disable ((UMCTL2_A_NPORTS >= (8+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_8 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_8 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_8 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_8 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_8


`define UMCTL2_RRB_THRESHOLD_PPL_8 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_9
// Default:      Disable ((UMCTL2_A_NPORTS >= (9+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_9 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_9 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 
//               != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_9 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_9 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_9


`define UMCTL2_RRB_THRESHOLD_PPL_9 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_10
// Default:      Disable ((UMCTL2_A_NPORTS >= (10+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_10 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_10 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (10+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_10 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_10 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_10 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_10


`define UMCTL2_RRB_THRESHOLD_PPL_10 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_11
// Default:      Disable ((UMCTL2_A_NPORTS >= (11+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_11 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_11 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (11+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_11 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_11 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_11 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_11


`define UMCTL2_RRB_THRESHOLD_PPL_11 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_12
// Default:      Disable ((UMCTL2_A_NPORTS >= (12+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_12 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_12 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (12+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_12 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_12 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_12 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_12


`define UMCTL2_RRB_THRESHOLD_PPL_12 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_13
// Default:      Disable ((UMCTL2_A_NPORTS >= (13+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_13 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_13 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (13+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_13 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_13 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_13 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_13


`define UMCTL2_RRB_THRESHOLD_PPL_13 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_14
// Default:      Disable ((UMCTL2_A_NPORTS >= (14+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_14 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_14 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (14+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_14 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_14 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_14 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_14


`define UMCTL2_RRB_THRESHOLD_PPL_14 1

// Name:         UMCTL2_RRB_THRESHOLD_EN_15
// Default:      Disable ((UMCTL2_A_NPORTS >= (15+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_15 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_15 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (15+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_15 != 0 && UMCTL2_READ_DATA_INTERLEAVE_EN_15 == 0 && 
//               UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// Enables threshold based VC selection for Read Reorder Buffer (RRB) of port n in configurations that disable read data 
// interleaving. 
// RRB considers a VC for selection only when the number of HIF bursts received from DDRC exceeds the value specified in 
// PCFGR_n.rrb_lock_threshold, or all corresponding HIF bursts for the AXI transaction are returned by DDRC. 
// This feature provides better performance when one AXI burst is translated to multiple DDR bursts but requires more area 
// and might impact on synthesis timing depending process and so on. The size of extra area depends on number of CAM 
// entries. 
// UMCTL2_NUM_VIR_CH_n > 1 is required to get benefit of the feature.
`define UMCTL2_RRB_THRESHOLD_EN_15 0


// `define UMCTL2_A_RRB_THRESHOLD_EN_15


`define UMCTL2_RRB_THRESHOLD_PPL_15 1


// Name:         UMCTL2_RRB_EXTRAM_0
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (0+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_0 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_0 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_0

// Name:         UMCTL2_RRB_EXTRAM_1
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (1+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_1 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_1 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_1

// Name:         UMCTL2_RRB_EXTRAM_2
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (2+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_2 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_2 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_2

// Name:         UMCTL2_RRB_EXTRAM_3
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (3+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_3 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_3 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_3

// Name:         UMCTL2_RRB_EXTRAM_4
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (4+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_4 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_4 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_4

// Name:         UMCTL2_RRB_EXTRAM_5
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (5+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_5 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_5 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_5

// Name:         UMCTL2_RRB_EXTRAM_6
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (6+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_6 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_6 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_6

// Name:         UMCTL2_RRB_EXTRAM_7
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (7+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_7 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_7 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_7

// Name:         UMCTL2_RRB_EXTRAM_8
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (8+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_8 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_8 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_8

// Name:         UMCTL2_RRB_EXTRAM_9
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (9+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_9 
//               != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_9 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_9

// Name:         UMCTL2_RRB_EXTRAM_10
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (10+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_10 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (10+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_10 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_10 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_10

// Name:         UMCTL2_RRB_EXTRAM_11
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (11+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_11 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (11+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_11 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_11 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_11

// Name:         UMCTL2_RRB_EXTRAM_12
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (12+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_12 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (12+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_12 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_12 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_12

// Name:         UMCTL2_RRB_EXTRAM_13
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (13+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_13 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (13+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_13 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_13 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_13

// Name:         UMCTL2_RRB_EXTRAM_14
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (14+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_14 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (14+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_14 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_14 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_14

// Name:         UMCTL2_RRB_EXTRAM_15
// Default:      Disable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1 && UMCTL2_A_NPORTS 
//               >= (15+1) && UMCTL2_INCL_ARB == 1 && UMCTL2_A_TYPE_15 != 0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      UMCTL2_A_NPORTS >= (15+1) && UMCTL2_INCL_ARB == 1 && 
//               UMCTL2_A_TYPE_15 != 0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// This parameter enables the external RAM for Read Reorder Buffer (RRB) of port n.
`define UMCTL2_RRB_EXTRAM_15 0


// `define UMCTL2_RRB_EXTRAM_ENABLED_15


// Name:         UMCTL2_RRB_EXTRAM_REG_0
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_0 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_0 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_0

// Name:         UMCTL2_RRB_EXTRAM_REG_1
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_1 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_1 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_1

// Name:         UMCTL2_RRB_EXTRAM_REG_2
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_2 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_2 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_2

// Name:         UMCTL2_RRB_EXTRAM_REG_3
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_3 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_3 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_3

// Name:         UMCTL2_RRB_EXTRAM_REG_4
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_4 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_4 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_4

// Name:         UMCTL2_RRB_EXTRAM_REG_5
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_5 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_5 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_5

// Name:         UMCTL2_RRB_EXTRAM_REG_6
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_6 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_6 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_6

// Name:         UMCTL2_RRB_EXTRAM_REG_7
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_7 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_7 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_7

// Name:         UMCTL2_RRB_EXTRAM_REG_8
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_8 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_8 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_8

// Name:         UMCTL2_RRB_EXTRAM_REG_9
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_9 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_9 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_9

// Name:         UMCTL2_RRB_EXTRAM_REG_10
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_10 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_10 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_10

// Name:         UMCTL2_RRB_EXTRAM_REG_11
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_11 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_11 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_11

// Name:         UMCTL2_RRB_EXTRAM_REG_12
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_12 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_12 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_12

// Name:         UMCTL2_RRB_EXTRAM_REG_13
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_13 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_13 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_13

// Name:         UMCTL2_RRB_EXTRAM_REG_14
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_14 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_14 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_14

// Name:         UMCTL2_RRB_EXTRAM_REG_15
// Default:      Registered
// Values:       Unregistered (0), Registered (1)
// Enabled:      UMCTL2_RRB_EXTRAM_15 == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 0
// 
// The timing mode of outputs for External RRB RAM port n 
//  
// When using registered outputs, the SRAM device outputs the read data one clock 
// cycle after the read address. 
// If enabled, read data latency increases by one clock cycle.
`define UMCTL2_RRB_EXTRAM_REG_15 1


`define UMCTL2_RRB_EXTRAM_REG_ENABLED_15



// Name:         UMCTL2_RRB_EXTRAM_RETIME_0
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_0 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_0 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_1
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_1 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_1 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_2
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_2 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_2 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_3
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_3 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_3 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_4
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_4 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_4 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_5
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_5 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_5 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_6
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_6 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_6 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_7
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_7 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_7 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_8
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_8 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_8 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_9
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_9 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_9 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_10
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_10 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_10 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_11
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_11 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_11 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_12
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_12 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_12 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_13
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_13 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_13 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_14
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_14 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_14 0


// Name:         UMCTL2_RRB_EXTRAM_RETIME_15
// Default:      Disabled
// Values:       Disabled (0), Enabled (1)
// Enabled:      UMCTL2_RRB_EXTRAM_15 == 1
// 
// When selected, Retime registers are implemented to register the RRB RAM data outputs before being used elsewhere in the 
// design.
`define UMCTL2_RRB_EXTRAM_RETIME_15 0




// Name:         UMCTL2_RRB_EXTRAM_TABLE
// Default:      0 ((UMCTL2_RRB_EXTRAM_15<<15) + (UMCTL2_RRB_EXTRAM_14<<14) + 
//               (UMCTL2_RRB_EXTRAM_13<<13) + (UMCTL2_RRB_EXTRAM_12<<12) + 
//               (UMCTL2_RRB_EXTRAM_11<<11) + (UMCTL2_RRB_EXTRAM_10<<10) + (UMCTL2_RRB_EXTRAM_9<<9) + 
//               (UMCTL2_RRB_EXTRAM_8<<8) + (UMCTL2_RRB_EXTRAM_7<<7) + 
//               (UMCTL2_RRB_EXTRAM_6<<6) + (UMCTL2_RRB_EXTRAM_5<<5) + (UMCTL2_RRB_EXTRAM_4<<4) + 
//               (UMCTL2_RRB_EXTRAM_3<<3) + (UMCTL2_RRB_EXTRAM_2<<2) + 
//               (UMCTL2_RRB_EXTRAM_1<<1) + UMCTL2_RRB_EXTRAM_0)
// Values:       -2147483648, ..., 65535
// 
// Table built from the list of UMCTL2_RRB_EXTRAM_<n>
`define UMCTL2_RRB_EXTRAM_TABLE 0


// Name:         UMCTL2_RRB_EXTRAM_REG_TABLE
// Default:      65535 ((UMCTL2_RRB_EXTRAM_REG_15<<15) + 
//               (UMCTL2_RRB_EXTRAM_REG_14<<14) + (UMCTL2_RRB_EXTRAM_REG_13<<13) + (UMCTL2_RRB_EXTRAM_REG_12<<12) 
//               + (UMCTL2_RRB_EXTRAM_REG_11<<11) + (UMCTL2_RRB_EXTRAM_REG_10<<10) + 
//               (UMCTL2_RRB_EXTRAM_REG_9<<9) + (UMCTL2_RRB_EXTRAM_REG_8<<8) + 
//               (UMCTL2_RRB_EXTRAM_REG_7<<7) + (UMCTL2_RRB_EXTRAM_REG_6<<6) + 
//               (UMCTL2_RRB_EXTRAM_REG_5<<5) + (UMCTL2_RRB_EXTRAM_REG_4<<4) + 
//               (UMCTL2_RRB_EXTRAM_REG_3<<3) + (UMCTL2_RRB_EXTRAM_REG_2<<2) + (UMCTL2_RRB_EXTRAM_REG_1<<1) 
//               + UMCTL2_RRB_EXTRAM_REG_0)
// Values:       -2147483648, ..., 65535
// 
// Table built from the list of UMCTL2_RRB_EXTRAM_REG_<n>
`define UMCTL2_RRB_EXTRAM_REG_TABLE 65535


// Name:         UMCTL2_A_NSAR
// Default:      0
// Values:       0, ..., 4
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN==0
// 
// Specifies the number of System Address Regions. 
//  
// Specifies how many distinct address regions to be decoded in the application system address space. 
//  - Minimum value 0 
//  - Maximum value 4 
//  - Default value 0 
// If set to 0, no regions are specified and addresses are assumed from the address 0.
`define UMCTL2_A_NSAR 0


`define THEREIS_SAR 0


// Name:         UMCTL2_SARMINSIZE
// Default:      256MB
// Values:       256MB (1), 512MB (2), 1GB (3), 2GB (4), 4GB (5), 8GB (6), 16GB (7), 
//               32GB (8)
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_A_NSAR > 0
// 
// Specifies the minimum block size for system address regions, ranging from 256 MB to 32GB. 
// Determines the number of most significant system address bits that are used to decode address regions. Base addresses 
// for each region must be aligned to this minimum block size.
`define UMCTL2_SARMINSIZE 1


// `define UMCTL2_A_SAR_0

// `define UMCTL2_A_SAR_1

// `define UMCTL2_A_SAR_2

// `define UMCTL2_A_SAR_3


// Maximum number of blocks that can be set to SAR region
`define UMCTL2_SAR_MAXNBLOCKS ((32'b1 << (`UMCTL2_A_ADDRW-27-`UMCTL2_SARMINSIZE)) - 1)

// Minimum SAR block size in bytes (2^27 shifted by the parameter)
`define UMCTL2_SAR_MINBLOCKSIZEBYTES ((128*1024*1024) << `UMCTL2_SARMINSIZE)

// ----------------------------------------------------------------------------
// XPI parameters
// ----------------------------------------------------------------------------


// Name:         UMCTL2_XPI_USE_WAR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_XPI_USE_RMW == 0
// 
// This parameter enables the XPI write address retime (that is, pipelines XPI write address output to PA). 
//  
// This parameter introduces extra cycle of latency on the write address channel. 
// It can be used for multi-port configurations to improve timing. 
//  
// A retime is automatically instantiated in the xpi RMW generator. Therefore, when RMW is used, this parameter is 
// disabled.
`define UMCTL2_XPI_USE_WAR 0


// Name:         UMCTL2_XPI_USE_RAR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1 && THEREIS_USE2RAQ == 0
// 
// This parameter enables the XPI read address output retime (that is, pipelines XPI write address output to PA). 
//  
// This parameter introduces an extra cycle of latency on the read address channel. 
// It can be used for multi-port configurations to improve timing.
`define UMCTL2_XPI_USE_RAR 0


// Name:         UMCTL2_XPI_USE_INPUT_RAR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// This parameter enables the XPI read address input retime (that is, pipelines XPI write address input before the QoS 
// mapper). 
//  
// This parameter introduces an extra cycle of latency on the read address channel. 
// It can be used to improve timing.
`define UMCTL2_XPI_USE_INPUT_RAR 0


// Name:         UMCTL2_XPI_USE_RDR
// Default:      0
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB == 1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN == 1
// 
// This parameter enables the XPI RRB data retime (that is, pipelines XPI at the output of RRB). 
//  
// This parameter introduces an extra cycle of latency on the read data channel. 
// It can be used in dual data channel configurations to improve timing.
`define UMCTL2_XPI_USE_RDR 0


// Name:         UMCTL2_XPI_USE_RPR
// Default:      0
// Values:       0, 1
// Enabled:      (UMCTL2_INCL_ARB == 1 && (UMCTL2_OCPAR_EN == 1 || UMCTL2_OCECC_EN 
//               == 1))
// 
// This parameter enables the XPI read data/parity retime (that is, pipelines XPI data and parity at the AXI interface). 
//  
// This parameter introduces an extra cycle of latency on the read data channel. 
// It can be used in on-chip parity configurations to improve timing.
`define UMCTL2_XPI_USE_RPR 0


//-----------------------------------------------
// Read-only but visible GUI derived parameters for interface signals
//-----------------------------------------------


// Name:         UMCTL2_WDATARAM_DW
// Default:      256 (UMCTL2_INCL_ARB_OR_CHB == 0 && MEMC_SIDEBAND_ECC_EN==1 && 
//               UMCTL2_ECC_TEST_MODE_EN==1) ? (MEMC_OPT_WDATARAM == 1)? 
//               (MEMC_DRAM_DATA_WIDTH*MEMC_FREQ_RATIO*2+MEMC_DFI_ECC_WIDTH*2) : 
//               (MEMC_DRAM_DATA_WIDTH*MEMC_FREQ_RATIO*2+MEMC_DFI_ECC_WIDTH) : (MEMC_OPT_WDATARAM == 1 && 
//               MEMC_DRAM_DATA_WIDTH == 72)? 
//               ((MEMC_DRAM_DATA_WIDTH+8)*MEMC_FREQ_RATIO*2) : (MEMC_DRAM_DATA_WIDTH*MEMC_FREQ_RATIO*2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the data width of the external write data SRAM. It is an internal parameter provided in the GUI 
// for information purposes and is derived from MEMC_DRAM_DATA_WIDTH, MEMC_FREQ_RATIO, and MEMC_ECC_SUPPORT.
`define UMCTL2_WDATARAM_DW 256


// Name:         UMCTL2_WDATARAM_AW
// Default:      6 (MEMC_OPT_WDATARAM == 1)? ((MEMC_WRDATA_8_CYCLES == 1) ? 
//               (MEMC_WRCMD_ENTRY_BITS + 2) : (MEMC_WRDATA_4_CYCLES == 1) ? 
//               (MEMC_WRCMD_ENTRY_BITS + 1) : (MEMC_WRCMD_ENTRY_BITS)) : ((MEMC_WRDATA_8_CYCLES == 1) 
//               ? (MEMC_WRCMD_ENTRY_BITS + 3) : (MEMC_WRDATA_4_CYCLES == 1) ? 
//               (MEMC_WRCMD_ENTRY_BITS + 2) : (MEMC_WRCMD_ENTRY_BITS + 1))
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the address width of the external write data SRAM. It is an internal parameter provided in the 
// GUI for information purposes and is derived from the CAM size (MEMC_NO_OF_ENTRY), MEMC_BURST_LENGTH, and MEMC_FREQ_RATIO.
`define UMCTL2_WDATARAM_AW 6


// Name:         UMCTL2_WDATARAM_DEPTH
// Default:      64 (1<< UMCTL2_WDATARAM_AW)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the depth of the external write data SRAM. It is an internal parameter provided in the GUI for 
// information purposes and is derived from the address width of the external write data SRAM (UMCTL2_WDATARAM_AW).
`define UMCTL2_WDATARAM_DEPTH 64


// Name:         UMCTL2_RDATARAM_DW
// Default:      256 (MEMC_DRAM_DATA_WIDTH * MEMC_FREQ_RATIO * 2)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the Read Reorder Buffer (RRB) External Data RAM Interface Data Width. 
// It is an internal parameter provided in the GUI for information purposes.
`define UMCTL2_RDATARAM_DW 256


// Name:         UMCTL2_RDATARAM_DEPTH
// Default:      64 (MEMC_NO_OF_ENTRY * (MEMC_BURST_LENGTH/(MEMC_FREQ_RATIO*2)))
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the Read Reorder Buffer (RRB) External Data RAM Interface Depth. 
// It is an internal parameter provided in the GUI for information purposes.
`define UMCTL2_RDATARAM_DEPTH 64


// Name:         UMCTL2_RDATARAM_AW
// Default:      6 ([<functionof> MEMC_NO_OF_ENTRY MEMC_BURST_LENGTH 
//               MEMC_FREQ_RATIO])
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// This parameter specifies the Read Reorder Buffer (RRB) External Data RAM Interface Address Width. 
// It is an internal parameter provided in the GUI for information purposes.
`define UMCTL2_RDATARAM_AW 6


`define UMCTL2_DATARAM_PAR_DW 32


`define UMCTL2_WDATARAM_PAR_DW 32


// Name:         UMCTL2_DATARAM_PAR_DW_GUI
// Default:      0 ((UMCTL2_OCPAR_EN == 1 || UMCTL2_OCECC_EN == 1) ? 
//               UMCTL2_DATARAM_PAR_DW : 0)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the Read Reorder Buffer (RRB) External Data RAM Interface Parity Width. 
// It is an internal parameter provided in the GUI for information purpose.
`define UMCTL2_DATARAM_PAR_DW_GUI 0


// Name:         UMCTL2_WDATARAM_PAR_DW_GUI
// Default:      0 ((UMCTL2_OCPAR_EN == 1 || UMCTL2_OCECC_EN == 1) ? 
//               UMCTL2_WDATARAM_PAR_DW : 0)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Specifies the parity length of the external write data SRAM. It is an internal parameter provided in the GUI for 
// information purpose.
`define UMCTL2_WDATARAM_PAR_DW_GUI 0


`define UMCTL2_WDATARAM_PAR_DW_EXT 32


`define UMCTL2_DATARAM_PAR_DW_LG2 5

//-----------------------------------------------
// DDRC Static Parameters
//-----------------------------------------------


`define MEMC_PAGE_BITS 18


`define MEMC_BLK_BITS 7

`define MEMC_WORD_BITS 4


// Name:         DDRCTL_HIF_DRAM_ADDR_WIDTH
// Default:      34 (MEMC_BANK_BITS + MEMC_BG_BITS + UMCTL2_LRANK_BITS + 
//               MEMC_PAGE_BITS + MEMC_WORD_BITS + MEMC_BLK_BITS)
// Values:       -2147483648, ..., 2147483647
// Enabled:      MEMC_SIDEBAND_ECC==1&&UMCTL2_SBR_EN==1&&DDRCTL_UMCTL5==1
// 
// Address Width to propagate the value of DRAM address to HIF
`define DDRCTL_HIF_DRAM_ADDR_WIDTH 34

// 2-bit command type encodings
`define MEMC_CMD_TYPE_BLK_WR        2'b00  // block write command
`define MEMC_CMD_TYPE_BLK_RD        2'b01  // read command
`define MEMC_CMD_TYPE_RMW           2'b10  // read-modify-write command
`define MEMC_CMD_TYPE_RESERVED      2'b11  // reserved

// 2-bit read priority encoding
`define MEMC_CMD_PRI_LPR            2'b00  // LP Read
`define MEMC_CMD_PRI_VPR            2'b01  // VP Read
`define MEMC_CMD_PRI_HPR            2'b10  // HP Read
`define MEMC_CMD_PRI_XVPR           2'b11  // Exp-VP Read - this value is reserved on the HIF bus, but used inside DDRC

// 2-bit write priority encoding
`define MEMC_CMD_PRI_NPW            2'b00  // NP Write - Normal Priority Write
`define MEMC_CMD_PRI_VPW            2'b01  // VP Write
`define MEMC_CMD_PRI_RSVD           2'b10  // Reserved
`define MEMC_CMD_PRI_XVPW           2'b11  // Exp-VP Write - this value is reserved on the HIF bus, but used inside DDRC

// 2-bit RMW type encodings
`define MEMC_RMW_TYPE_PARTIAL_NBW   2'b00  // indicates partial write
`define MEMC_RMW_TYPE_RMW_CMD       2'b01  // indicates a AIR (auto-increment)
`define MEMC_RMW_TYPE_SCRUB         2'b10  // indicates a scrub
`define MEMC_RMW_TYPE_NO_RMW        2'b11  //no RMW

// LPDDR4 write data pattern for DM/DBI
`define UMCTL2_LPDDR4_DQ_WHEN_MASKED 8'hF8  // To save power consumption this is used instead of 8'hFF when LPDDR4 write DQ is masked with enabling DBI

// DDR54 PHY needs a specially encoded "IDLE" command over the DFI bus to make the Command/Address Hi-Z
// In 2T mode (or geardown), the PHY tristates the relevant pins when:
// DDR4 : All ranks DESelected (all CS_L==1) AND {ACT_n,RAS_n,CAS_n,WE_n,BA0} = {1,1,1,1,0}
`define UMCTL2_PHY_SPECIAL_IDLE     5'b11110


// Name:         MEMC_ADDR_WIDTH_BITS
// Default:      17 ((DDRCTL_DDR_EN == 1) ? 18 : (DDRCTL_LPDDR_EN == 1) ? 17 : 16)
// Values:       -2147483648, ..., 2147483647
// 
// Used in Testbench only - not in RTL
`define MEMC_ADDR_WIDTH_BITS 17

//-----------------------------------------------
// AXI Static Parameters
//-----------------------------------------------

`define UMCTL2_AXI_BURST_WIDTH  2
`define UMCTL2_AXI_SIZE_WIDTH   3
`define UMCTL2_AXI_CACHE_WIDTH  4
`define UMCTL2_AXI_PROT_WIDTH   3
`define UMCTL2_AXI_RESP_WIDTH   2


`define UMCTL2_XPI_RARD 2


`define UMCTL2_XPI_WARD 2


`define MEMC_DRAM_NBYTES 4


`define MEMC_DRAM_NBYTES_LG2 2


`define UMCTL2_OCPAR_ADDR_LOG_LOW_WIDTH 32


`define UMCTL2_OCPAR_SLICE_WIDTH 8


`define UMCTL2_OCPAR_POISON_DW 32

//-----------------------------------------------------------------------------
// AXI Dynamic Parameters
//-----------------------------------------------------------------------------


`define UMCTL2_MIN_ADDRW 34


// Name:         UMCTL2_A_ADDRW
// Default:      34 (UMCTL2_MIN_ADDRW)
// Values:       MEMC_HIF_MIN_ADDR_WIDTH, ..., 60
// Enabled:      UMCTL2_INCL_ARB == 1
// 
// Specifies the width of the application address. 
// A minimum value equal to UMCTL2_MIN_ADDRW is required to be able to address the maximum supported memory size. 
// If a value higher than UMCTL2_MIN_ADDRW is set and system address regions are not enabled, the exceeding MSBs are 
// ignored.
`define UMCTL2_A_ADDRW 34


`define UMCTL2_AXI_ADDRW 34


// Name:         UMCTL2_OCPAR_ADDR_PARITY_WIDTH
// Default:      Single bit
// Values:       Single bit (0), One bit per byte (1)
// Enabled:      UMCTL2_OCPAR_OR_OCECC_EN_1==1
// 
// This parameter specifies the address parity width at AXI. 
// The options are: 
//  - Single parity bit 
//  - One bit per byte of address
`define UMCTL2_OCPAR_ADDR_PARITY_WIDTH 0


// Name:         UMCTL2_OCPAR_ADDR_PARITY_W
// Default:      1 ((UMCTL2_OCPAR_ADDR_PARITY_WIDTH == 0) ? 1 : [<functionof>])
// Values:       -2147483648, ..., 2147483647
// Enabled:      UMCTL2_OCPAR_OR_OCECC_EN_1==1
// 
// On-Chip Parity Address Width Internal. 
// The value of this parameter depends on the value of UMCTL2_OCPAR_ADDR_PARITY_WIDTH and UMCTL2_A_ADDRW
`define UMCTL2_OCPAR_ADDR_PARITY_W 1



// Name:         UMCTL2_MAX_PL
// Default:      16 ((MEMC_FREQ_RATIO==2) ?  8 : 16)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Maximum packet lenght. 
// In x1 mode maximum burst supported BL16 => atomic packet len is 16 
// In x2 mode maximum burst supported BL16 => atomic packet len is 8
`define UMCTL2_MAX_PL 16



// Name:         UMCTL2_AXI_RAQD_0
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_0 4


// Name:         UMCTL2_AXI_WAQD_0
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_0 4


// Name:         UMCTL2_AXI_RDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_0 10


// Name:         UMCTL2_AXI_WDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_0 10


// Name:         UMCTL2_AXI_WRQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_0 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_0 10



// Name:         UMCTL2_AXI_RAQD_1
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_1 4


// Name:         UMCTL2_AXI_WAQD_1
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_1 4


// Name:         UMCTL2_AXI_RDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_1 10


// Name:         UMCTL2_AXI_WDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_1 10


// Name:         UMCTL2_AXI_WRQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_1 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_1 10



// Name:         UMCTL2_AXI_RAQD_2
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_2 4


// Name:         UMCTL2_AXI_WAQD_2
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_2 4


// Name:         UMCTL2_AXI_RDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_2 10


// Name:         UMCTL2_AXI_WDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_2 10


// Name:         UMCTL2_AXI_WRQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_2 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_2 10



// Name:         UMCTL2_AXI_RAQD_3
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_3 4


// Name:         UMCTL2_AXI_WAQD_3
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_3 4


// Name:         UMCTL2_AXI_RDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_3 10


// Name:         UMCTL2_AXI_WDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_3 10


// Name:         UMCTL2_AXI_WRQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_3 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_3 10



// Name:         UMCTL2_AXI_RAQD_4
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_4 4


// Name:         UMCTL2_AXI_WAQD_4
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_4 4


// Name:         UMCTL2_AXI_RDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_4 10


// Name:         UMCTL2_AXI_WDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_4 10


// Name:         UMCTL2_AXI_WRQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_4 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_4 10



// Name:         UMCTL2_AXI_RAQD_5
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_5 4


// Name:         UMCTL2_AXI_WAQD_5
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_5 4


// Name:         UMCTL2_AXI_RDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_5 10


// Name:         UMCTL2_AXI_WDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_5 10


// Name:         UMCTL2_AXI_WRQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_5 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_5 10



// Name:         UMCTL2_AXI_RAQD_6
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_6 4


// Name:         UMCTL2_AXI_WAQD_6
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_6 4


// Name:         UMCTL2_AXI_RDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_6 10


// Name:         UMCTL2_AXI_WDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_6 10


// Name:         UMCTL2_AXI_WRQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_6 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_6 10



// Name:         UMCTL2_AXI_RAQD_7
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_7 4


// Name:         UMCTL2_AXI_WAQD_7
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_7 4


// Name:         UMCTL2_AXI_RDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_7 10


// Name:         UMCTL2_AXI_WDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_7 10


// Name:         UMCTL2_AXI_WRQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_7 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_7 10



// Name:         UMCTL2_AXI_RAQD_8
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_8 4


// Name:         UMCTL2_AXI_WAQD_8
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_8 4


// Name:         UMCTL2_AXI_RDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_8 10


// Name:         UMCTL2_AXI_WDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_8 10


// Name:         UMCTL2_AXI_WRQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_8 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_8 10



// Name:         UMCTL2_AXI_RAQD_9
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_9 4


// Name:         UMCTL2_AXI_WAQD_9
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_9 4


// Name:         UMCTL2_AXI_RDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_9 10


// Name:         UMCTL2_AXI_WDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_9 10


// Name:         UMCTL2_AXI_WRQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_9 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_9 10



// Name:         UMCTL2_AXI_RAQD_10
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_10 4


// Name:         UMCTL2_AXI_WAQD_10
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_10 4


// Name:         UMCTL2_AXI_RDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_10 10


// Name:         UMCTL2_AXI_WDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_10 10


// Name:         UMCTL2_AXI_WRQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_10 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_10 10



// Name:         UMCTL2_AXI_RAQD_11
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_11 4


// Name:         UMCTL2_AXI_WAQD_11
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_11 4


// Name:         UMCTL2_AXI_RDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_11 10


// Name:         UMCTL2_AXI_WDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_11 10


// Name:         UMCTL2_AXI_WRQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_11 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_11 10



// Name:         UMCTL2_AXI_RAQD_12
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_12 4


// Name:         UMCTL2_AXI_WAQD_12
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_12 4


// Name:         UMCTL2_AXI_RDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_12 10


// Name:         UMCTL2_AXI_WDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_12 10


// Name:         UMCTL2_AXI_WRQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_12 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_12 10



// Name:         UMCTL2_AXI_RAQD_13
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_13 4


// Name:         UMCTL2_AXI_WAQD_13
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_13 4


// Name:         UMCTL2_AXI_RDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_13 10


// Name:         UMCTL2_AXI_WDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_13 10


// Name:         UMCTL2_AXI_WRQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_13 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_13 10



// Name:         UMCTL2_AXI_RAQD_14
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_14 4


// Name:         UMCTL2_AXI_WAQD_14
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_14 4


// Name:         UMCTL2_AXI_RDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_14 10


// Name:         UMCTL2_AXI_WDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_14 10


// Name:         UMCTL2_AXI_WRQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_14 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_14 10



// Name:         UMCTL2_AXI_RAQD_15
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI addresses can be stored in the read address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_RAQD_15 4


// Name:         UMCTL2_AXI_WAQD_15
// Default:      4
// Values:       2, ..., 32
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI addresses can be stored in the write address buffer 
// of Port n. Each address represents an AXI burst transaction.
`define UMCTL2_AXI_WAQD_15 4


// Name:         UMCTL2_AXI_RDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI burst beats can be stored in the read data buffer of Port n. 
//  
// Set the read data buffer to an appropriate depth to allow continuous streaming of read data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of read commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value may 
// be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  A higher value might be required depending on the AXI to core clock ratio, as well as your application.
`define UMCTL2_AXI_RDQD_15 10


// Name:         UMCTL2_AXI_WDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1)? 2 : 10)
// Values:       2, ..., 128
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// Determines how many AXI burst beats can be stored in the write data buffer of Port n. 
//  
// Set the write data buffer to an appropriate depth to allow continuous streaming of write data in the end application. 
// If set too small, the interface will be functional, but performance might be impacted as the buffer might not have 
// sufficient storage to permit a continuous stream of write commands. 
//  
// For configurations where UMCTL2_A_SYNC_n = 1, the minimum value to permit continuous streaming is 2. A higher value 
// might be required depending on your application. 
//  
// For configurations where UMCTL2_A_SYNC_n = 0, the minimum value to permit continuous streaming is 10. 
//  
// Increase by at least one if AXI master issues AWVALID and corresponding WVALID on the same cycle. 
//  
// Increase by at least one when UMCTL2_XPI_USE_WAR=1 
//  A higher value might be required depending on the AXI to core clock ratio as well as your application.
`define UMCTL2_AXI_WDQD_15 10


// Name:         UMCTL2_AXI_WRQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1)? 2 : 10)
// Values:       2, ..., 64
// Enabled:      UMCTL2_A_AXI_15 == 1
// 
// UMCTL2_AXI_WRQD_n: 
// Determines how many AXI write responses can be stored in the write response buffer of Port n. 
// Each entry represents a response to an AXI write burst transaction. Set the write response buffer to: 
//  -  2 for configurations where UMCTL2_A_SYNC_n = 1. 
//  -  10 for configurations where UMCTL_A_SYNC_n = 0. 
// This allows the controller to store enough write responses in the write response buffer so that the controller 
// does not stall a continuous stream of short write transactions (with awlen = 0) to wait for free storage space in the 
// write response buffer. 
// May be increased if additional write response buffering in the controller is required. 
//  
// If set to value less than 10, the interface will be functional, but performance might be impacted as the buffer might 
// not have sufficient storage 
// to permit a continuous stream of write transactions. 
// Note: the performance impact may be hidden if awlen is greater than 0.
`define UMCTL2_AXI_WRQD_15 10



// Name:         UMCTL2_XPI_SQD
// Default:      34
// Values:       4, ..., 64
// Enabled:      Always
// 
// Determines how many transactions can be stored in the size queue in xpi write.
`define UMCTL2_XPI_SQD 34


// Name:         UMCTL2_XPI_OUTS_WRW
// Default:      10
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determines how many outstanding write transactions can be accepted by xpi.
`define UMCTL2_XPI_OUTS_WRW 10


// Name:         UMCTL2_XPI_OUTS_RDW
// Default:      12
// Values:       -2147483648, ..., 2147483647
// Enabled:      Always
// 
// Determines how many outstanding read transactions can be accepted by xpi.
`define UMCTL2_XPI_OUTS_RDW 12


// Name:         UMCTL2_XPI_WDATA_PTR_QD
// Default:      32 (MEMC_NO_OF_ENTRY)
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Determines how many write data pointer can be stored in the write data pointer queue in xpi write.
`define UMCTL2_XPI_WDATA_PTR_QD 32


// Name:         UMCTL2_PA_OPT_TYPE
// Default:      Combinatorial ((UMCTL2_INT_NPORTS < 5) ? 2 : 1)
// Values:       Two cycle (1), Combinatorial (2)
// Enabled:      Always
// 
// Specifies the type of optimization required for the Port Arbiter block 
// The options are: 
//  1) two-cycle arbitration (1 cycle of idle latency) 
//  2) combinatorial (0 cycle of idle latency) 
//  Selecting a value of 2 for this parameter in multi-port configurations can 
//  have a significant impact on timing closure.
`define UMCTL2_PA_OPT_TYPE 2


// `define UMCTL2_PA_OPT_TYPE_TWOCYCLE


`define UMCTL2_PA_OPT_TYPE_COMB


// Name:         UMCTL2_PAGEMATCH_EN
// Default:      1
// Values:       0, 1
// Enabled:      UMCTL2_INCL_ARB==1
// 
// This parameter enables the Port Arbiter (PA) pagematch feature in the hardware. 
// This feature is not recommended if there is a timing closure challenge due to PA. 
// For instance, when there are many ports, the pagematch feature can be disabled to improve 
// synthesis timing.
`define UMCTL2_PAGEMATCH_EN 1


// Name:         UMCTL2_XPI_RMW_WDQD
// Default:      6 ((UMCTL2_PA_OPT_TYPE==1) ? MEMC_BURST_LENGTH : 
//               ((MEMC_BURST_LENGTH/MEMC_FREQ_RATIO)+2))
// Values:       2, ..., 18
// Enabled:      0
// 
// Determines the depth of the store and forward queue in xpi RMW generator.
`define UMCTL2_XPI_RMW_WDQD 6


// Name:         UMCTL2_XPI_RMW_WARD
// Default:      2 ((UMCTL2_PA_OPT_TYPE==1) ? 4 : 2)
// Values:       2, ..., 4
// Enabled:      0
// 
// Determines the depth of the retime in xpi RMW generator.
`define UMCTL2_XPI_RMW_WARD 2


// Name:         MEMC_DDR2_DIS_TB
// Default:      0
// Values:       0, 1
// 
// Disables certain FSM transitions from FSM coverage collection that are DDR2 specific 
// Set this to 1 only for coverage regressions with PHYs that do not support DDR2
`define MEMC_DDR2_DIS_TB 0


// Name:         UMCTL2_RDIMM_DIS_TB
// Default:      0
// Values:       0, 1
// 
// Disables certain FSM transitions from FSM coverage collection that are RDIMM specific 
// Set this to 1 only for coverage regressions with PHYs that do not support RDIMM (i.e. PhyType 6 and 8)
`define UMCTL2_RDIMM_DIS_TB 0


// Name:         UMCTL2_GEARDOWN_DIS_TB
// Default:      0
// Values:       0, 1
// 
// Disables certain FSM transitions from FSM coverage collection that are specific to Geardown mechanism 
// Set this to 1 only for coverage regressions with PHYs that do not support Geardown (i.e. PhyType>5 and ANIBS!=12)
`define UMCTL2_GEARDOWN_DIS_TB 0


// Name:         MEMC_DFI_PHYUPD_NONCOMPLIANT_DIS_TB
// Default:      0
// Values:       0, 1
// 
// Disables certain FSM transitions from gs_phyupd FSM coverage collection that handle behavior outside the DFI 
// specification.
`define MEMC_DFI_PHYUPD_NONCOMPLIANT_DIS_TB 0

//----------------------------------------
// Derived parameters
//----------------------------------------

`define UMCTL2_SINGLE_PORT_1


`define UMCTL2_SINGLE_PORT 1


`define UMCTL2_OCPAR_ADDR_LOG_USE_MSB


`define UMCTL2_OCPAR_ADDR_LOG_HIGH_WIDTH 2


//UMCTL2_PORT_CH0_0:

// `define UMCTL2_PORT_CH0_0

//UMCTL2_PORT_CH1_0:

// `define UMCTL2_PORT_CH1_0

//UMCTL2_PORT_CH2_0:

// `define UMCTL2_PORT_CH2_0

//UMCTL2_PORT_CH3_0:

// `define UMCTL2_PORT_CH3_0

//UMCTL2_PORT_CH4_0:

// `define UMCTL2_PORT_CH4_0

//UMCTL2_PORT_CH5_0:

// `define UMCTL2_PORT_CH5_0

//UMCTL2_PORT_CH6_0:

// `define UMCTL2_PORT_CH6_0

//UMCTL2_PORT_CH7_0:

// `define UMCTL2_PORT_CH7_0

//UMCTL2_PORT_CH8_0:

// `define UMCTL2_PORT_CH8_0

//UMCTL2_PORT_CH9_0:

// `define UMCTL2_PORT_CH9_0

//UMCTL2_PORT_CH10_0:

// `define UMCTL2_PORT_CH10_0

//UMCTL2_PORT_CH11_0:

// `define UMCTL2_PORT_CH11_0

//UMCTL2_PORT_CH12_0:

// `define UMCTL2_PORT_CH12_0

//UMCTL2_PORT_CH13_0:

// `define UMCTL2_PORT_CH13_0

//UMCTL2_PORT_CH14_0:

// `define UMCTL2_PORT_CH14_0

//UMCTL2_PORT_CH15_0:

// `define UMCTL2_PORT_CH15_0


//UMCTL2_PORT_CH0_1:

// `define UMCTL2_PORT_CH0_1

//UMCTL2_PORT_CH1_1:

// `define UMCTL2_PORT_CH1_1

//UMCTL2_PORT_CH2_1:

// `define UMCTL2_PORT_CH2_1

//UMCTL2_PORT_CH3_1:

// `define UMCTL2_PORT_CH3_1

//UMCTL2_PORT_CH4_1:

// `define UMCTL2_PORT_CH4_1

//UMCTL2_PORT_CH5_1:

// `define UMCTL2_PORT_CH5_1

//UMCTL2_PORT_CH6_1:

// `define UMCTL2_PORT_CH6_1

//UMCTL2_PORT_CH7_1:

// `define UMCTL2_PORT_CH7_1

//UMCTL2_PORT_CH8_1:

// `define UMCTL2_PORT_CH8_1

//UMCTL2_PORT_CH9_1:

// `define UMCTL2_PORT_CH9_1

//UMCTL2_PORT_CH10_1:

// `define UMCTL2_PORT_CH10_1

//UMCTL2_PORT_CH11_1:

// `define UMCTL2_PORT_CH11_1

//UMCTL2_PORT_CH12_1:

// `define UMCTL2_PORT_CH12_1

//UMCTL2_PORT_CH13_1:

// `define UMCTL2_PORT_CH13_1

//UMCTL2_PORT_CH14_1:

// `define UMCTL2_PORT_CH14_1

//UMCTL2_PORT_CH15_1:

// `define UMCTL2_PORT_CH15_1


//UMCTL2_PORT_CH0_2:

// `define UMCTL2_PORT_CH0_2

//UMCTL2_PORT_CH1_2:

// `define UMCTL2_PORT_CH1_2

//UMCTL2_PORT_CH2_2:

// `define UMCTL2_PORT_CH2_2

//UMCTL2_PORT_CH3_2:

// `define UMCTL2_PORT_CH3_2

//UMCTL2_PORT_CH4_2:

// `define UMCTL2_PORT_CH4_2

//UMCTL2_PORT_CH5_2:

// `define UMCTL2_PORT_CH5_2

//UMCTL2_PORT_CH6_2:

// `define UMCTL2_PORT_CH6_2

//UMCTL2_PORT_CH7_2:

// `define UMCTL2_PORT_CH7_2

//UMCTL2_PORT_CH8_2:

// `define UMCTL2_PORT_CH8_2

//UMCTL2_PORT_CH9_2:

// `define UMCTL2_PORT_CH9_2

//UMCTL2_PORT_CH10_2:

// `define UMCTL2_PORT_CH10_2

//UMCTL2_PORT_CH11_2:

// `define UMCTL2_PORT_CH11_2

//UMCTL2_PORT_CH12_2:

// `define UMCTL2_PORT_CH12_2

//UMCTL2_PORT_CH13_2:

// `define UMCTL2_PORT_CH13_2

//UMCTL2_PORT_CH14_2:

// `define UMCTL2_PORT_CH14_2

//UMCTL2_PORT_CH15_2:

// `define UMCTL2_PORT_CH15_2


//UMCTL2_PORT_CH0_3:

// `define UMCTL2_PORT_CH0_3

//UMCTL2_PORT_CH1_3:

// `define UMCTL2_PORT_CH1_3

//UMCTL2_PORT_CH2_3:

// `define UMCTL2_PORT_CH2_3

//UMCTL2_PORT_CH3_3:

// `define UMCTL2_PORT_CH3_3

//UMCTL2_PORT_CH4_3:

// `define UMCTL2_PORT_CH4_3

//UMCTL2_PORT_CH5_3:

// `define UMCTL2_PORT_CH5_3

//UMCTL2_PORT_CH6_3:

// `define UMCTL2_PORT_CH6_3

//UMCTL2_PORT_CH7_3:

// `define UMCTL2_PORT_CH7_3

//UMCTL2_PORT_CH8_3:

// `define UMCTL2_PORT_CH8_3

//UMCTL2_PORT_CH9_3:

// `define UMCTL2_PORT_CH9_3

//UMCTL2_PORT_CH10_3:

// `define UMCTL2_PORT_CH10_3

//UMCTL2_PORT_CH11_3:

// `define UMCTL2_PORT_CH11_3

//UMCTL2_PORT_CH12_3:

// `define UMCTL2_PORT_CH12_3

//UMCTL2_PORT_CH13_3:

// `define UMCTL2_PORT_CH13_3

//UMCTL2_PORT_CH14_3:

// `define UMCTL2_PORT_CH14_3

//UMCTL2_PORT_CH15_3:

// `define UMCTL2_PORT_CH15_3


//UMCTL2_PORT_CH0_4:

// `define UMCTL2_PORT_CH0_4

//UMCTL2_PORT_CH1_4:

// `define UMCTL2_PORT_CH1_4

//UMCTL2_PORT_CH2_4:

// `define UMCTL2_PORT_CH2_4

//UMCTL2_PORT_CH3_4:

// `define UMCTL2_PORT_CH3_4

//UMCTL2_PORT_CH4_4:

// `define UMCTL2_PORT_CH4_4

//UMCTL2_PORT_CH5_4:

// `define UMCTL2_PORT_CH5_4

//UMCTL2_PORT_CH6_4:

// `define UMCTL2_PORT_CH6_4

//UMCTL2_PORT_CH7_4:

// `define UMCTL2_PORT_CH7_4

//UMCTL2_PORT_CH8_4:

// `define UMCTL2_PORT_CH8_4

//UMCTL2_PORT_CH9_4:

// `define UMCTL2_PORT_CH9_4

//UMCTL2_PORT_CH10_4:

// `define UMCTL2_PORT_CH10_4

//UMCTL2_PORT_CH11_4:

// `define UMCTL2_PORT_CH11_4

//UMCTL2_PORT_CH12_4:

// `define UMCTL2_PORT_CH12_4

//UMCTL2_PORT_CH13_4:

// `define UMCTL2_PORT_CH13_4

//UMCTL2_PORT_CH14_4:

// `define UMCTL2_PORT_CH14_4

//UMCTL2_PORT_CH15_4:

// `define UMCTL2_PORT_CH15_4


//UMCTL2_PORT_CH0_5:

// `define UMCTL2_PORT_CH0_5

//UMCTL2_PORT_CH1_5:

// `define UMCTL2_PORT_CH1_5

//UMCTL2_PORT_CH2_5:

// `define UMCTL2_PORT_CH2_5

//UMCTL2_PORT_CH3_5:

// `define UMCTL2_PORT_CH3_5

//UMCTL2_PORT_CH4_5:

// `define UMCTL2_PORT_CH4_5

//UMCTL2_PORT_CH5_5:

// `define UMCTL2_PORT_CH5_5

//UMCTL2_PORT_CH6_5:

// `define UMCTL2_PORT_CH6_5

//UMCTL2_PORT_CH7_5:

// `define UMCTL2_PORT_CH7_5

//UMCTL2_PORT_CH8_5:

// `define UMCTL2_PORT_CH8_5

//UMCTL2_PORT_CH9_5:

// `define UMCTL2_PORT_CH9_5

//UMCTL2_PORT_CH10_5:

// `define UMCTL2_PORT_CH10_5

//UMCTL2_PORT_CH11_5:

// `define UMCTL2_PORT_CH11_5

//UMCTL2_PORT_CH12_5:

// `define UMCTL2_PORT_CH12_5

//UMCTL2_PORT_CH13_5:

// `define UMCTL2_PORT_CH13_5

//UMCTL2_PORT_CH14_5:

// `define UMCTL2_PORT_CH14_5

//UMCTL2_PORT_CH15_5:

// `define UMCTL2_PORT_CH15_5


//UMCTL2_PORT_CH0_6:

// `define UMCTL2_PORT_CH0_6

//UMCTL2_PORT_CH1_6:

// `define UMCTL2_PORT_CH1_6

//UMCTL2_PORT_CH2_6:

// `define UMCTL2_PORT_CH2_6

//UMCTL2_PORT_CH3_6:

// `define UMCTL2_PORT_CH3_6

//UMCTL2_PORT_CH4_6:

// `define UMCTL2_PORT_CH4_6

//UMCTL2_PORT_CH5_6:

// `define UMCTL2_PORT_CH5_6

//UMCTL2_PORT_CH6_6:

// `define UMCTL2_PORT_CH6_6

//UMCTL2_PORT_CH7_6:

// `define UMCTL2_PORT_CH7_6

//UMCTL2_PORT_CH8_6:

// `define UMCTL2_PORT_CH8_6

//UMCTL2_PORT_CH9_6:

// `define UMCTL2_PORT_CH9_6

//UMCTL2_PORT_CH10_6:

// `define UMCTL2_PORT_CH10_6

//UMCTL2_PORT_CH11_6:

// `define UMCTL2_PORT_CH11_6

//UMCTL2_PORT_CH12_6:

// `define UMCTL2_PORT_CH12_6

//UMCTL2_PORT_CH13_6:

// `define UMCTL2_PORT_CH13_6

//UMCTL2_PORT_CH14_6:

// `define UMCTL2_PORT_CH14_6

//UMCTL2_PORT_CH15_6:

// `define UMCTL2_PORT_CH15_6


//UMCTL2_PORT_CH0_7:

// `define UMCTL2_PORT_CH0_7

//UMCTL2_PORT_CH1_7:

// `define UMCTL2_PORT_CH1_7

//UMCTL2_PORT_CH2_7:

// `define UMCTL2_PORT_CH2_7

//UMCTL2_PORT_CH3_7:

// `define UMCTL2_PORT_CH3_7

//UMCTL2_PORT_CH4_7:

// `define UMCTL2_PORT_CH4_7

//UMCTL2_PORT_CH5_7:

// `define UMCTL2_PORT_CH5_7

//UMCTL2_PORT_CH6_7:

// `define UMCTL2_PORT_CH6_7

//UMCTL2_PORT_CH7_7:

// `define UMCTL2_PORT_CH7_7

//UMCTL2_PORT_CH8_7:

// `define UMCTL2_PORT_CH8_7

//UMCTL2_PORT_CH9_7:

// `define UMCTL2_PORT_CH9_7

//UMCTL2_PORT_CH10_7:

// `define UMCTL2_PORT_CH10_7

//UMCTL2_PORT_CH11_7:

// `define UMCTL2_PORT_CH11_7

//UMCTL2_PORT_CH12_7:

// `define UMCTL2_PORT_CH12_7

//UMCTL2_PORT_CH13_7:

// `define UMCTL2_PORT_CH13_7

//UMCTL2_PORT_CH14_7:

// `define UMCTL2_PORT_CH14_7

//UMCTL2_PORT_CH15_7:

// `define UMCTL2_PORT_CH15_7


//UMCTL2_PORT_CH0_8:

// `define UMCTL2_PORT_CH0_8

//UMCTL2_PORT_CH1_8:

// `define UMCTL2_PORT_CH1_8

//UMCTL2_PORT_CH2_8:

// `define UMCTL2_PORT_CH2_8

//UMCTL2_PORT_CH3_8:

// `define UMCTL2_PORT_CH3_8

//UMCTL2_PORT_CH4_8:

// `define UMCTL2_PORT_CH4_8

//UMCTL2_PORT_CH5_8:

// `define UMCTL2_PORT_CH5_8

//UMCTL2_PORT_CH6_8:

// `define UMCTL2_PORT_CH6_8

//UMCTL2_PORT_CH7_8:

// `define UMCTL2_PORT_CH7_8

//UMCTL2_PORT_CH8_8:

// `define UMCTL2_PORT_CH8_8

//UMCTL2_PORT_CH9_8:

// `define UMCTL2_PORT_CH9_8

//UMCTL2_PORT_CH10_8:

// `define UMCTL2_PORT_CH10_8

//UMCTL2_PORT_CH11_8:

// `define UMCTL2_PORT_CH11_8

//UMCTL2_PORT_CH12_8:

// `define UMCTL2_PORT_CH12_8

//UMCTL2_PORT_CH13_8:

// `define UMCTL2_PORT_CH13_8

//UMCTL2_PORT_CH14_8:

// `define UMCTL2_PORT_CH14_8

//UMCTL2_PORT_CH15_8:

// `define UMCTL2_PORT_CH15_8


//UMCTL2_PORT_CH0_9:

// `define UMCTL2_PORT_CH0_9

//UMCTL2_PORT_CH1_9:

// `define UMCTL2_PORT_CH1_9

//UMCTL2_PORT_CH2_9:

// `define UMCTL2_PORT_CH2_9

//UMCTL2_PORT_CH3_9:

// `define UMCTL2_PORT_CH3_9

//UMCTL2_PORT_CH4_9:

// `define UMCTL2_PORT_CH4_9

//UMCTL2_PORT_CH5_9:

// `define UMCTL2_PORT_CH5_9

//UMCTL2_PORT_CH6_9:

// `define UMCTL2_PORT_CH6_9

//UMCTL2_PORT_CH7_9:

// `define UMCTL2_PORT_CH7_9

//UMCTL2_PORT_CH8_9:

// `define UMCTL2_PORT_CH8_9

//UMCTL2_PORT_CH9_9:

// `define UMCTL2_PORT_CH9_9

//UMCTL2_PORT_CH10_9:

// `define UMCTL2_PORT_CH10_9

//UMCTL2_PORT_CH11_9:

// `define UMCTL2_PORT_CH11_9

//UMCTL2_PORT_CH12_9:

// `define UMCTL2_PORT_CH12_9

//UMCTL2_PORT_CH13_9:

// `define UMCTL2_PORT_CH13_9

//UMCTL2_PORT_CH14_9:

// `define UMCTL2_PORT_CH14_9

//UMCTL2_PORT_CH15_9:

// `define UMCTL2_PORT_CH15_9


//UMCTL2_PORT_CH0_10:

// `define UMCTL2_PORT_CH0_10

//UMCTL2_PORT_CH1_10:

// `define UMCTL2_PORT_CH1_10

//UMCTL2_PORT_CH2_10:

// `define UMCTL2_PORT_CH2_10

//UMCTL2_PORT_CH3_10:

// `define UMCTL2_PORT_CH3_10

//UMCTL2_PORT_CH4_10:

// `define UMCTL2_PORT_CH4_10

//UMCTL2_PORT_CH5_10:

// `define UMCTL2_PORT_CH5_10

//UMCTL2_PORT_CH6_10:

// `define UMCTL2_PORT_CH6_10

//UMCTL2_PORT_CH7_10:

// `define UMCTL2_PORT_CH7_10

//UMCTL2_PORT_CH8_10:

// `define UMCTL2_PORT_CH8_10

//UMCTL2_PORT_CH9_10:

// `define UMCTL2_PORT_CH9_10

//UMCTL2_PORT_CH10_10:

// `define UMCTL2_PORT_CH10_10

//UMCTL2_PORT_CH11_10:

// `define UMCTL2_PORT_CH11_10

//UMCTL2_PORT_CH12_10:

// `define UMCTL2_PORT_CH12_10

//UMCTL2_PORT_CH13_10:

// `define UMCTL2_PORT_CH13_10

//UMCTL2_PORT_CH14_10:

// `define UMCTL2_PORT_CH14_10

//UMCTL2_PORT_CH15_10:

// `define UMCTL2_PORT_CH15_10


//UMCTL2_PORT_CH0_11:

// `define UMCTL2_PORT_CH0_11

//UMCTL2_PORT_CH1_11:

// `define UMCTL2_PORT_CH1_11

//UMCTL2_PORT_CH2_11:

// `define UMCTL2_PORT_CH2_11

//UMCTL2_PORT_CH3_11:

// `define UMCTL2_PORT_CH3_11

//UMCTL2_PORT_CH4_11:

// `define UMCTL2_PORT_CH4_11

//UMCTL2_PORT_CH5_11:

// `define UMCTL2_PORT_CH5_11

//UMCTL2_PORT_CH6_11:

// `define UMCTL2_PORT_CH6_11

//UMCTL2_PORT_CH7_11:

// `define UMCTL2_PORT_CH7_11

//UMCTL2_PORT_CH8_11:

// `define UMCTL2_PORT_CH8_11

//UMCTL2_PORT_CH9_11:

// `define UMCTL2_PORT_CH9_11

//UMCTL2_PORT_CH10_11:

// `define UMCTL2_PORT_CH10_11

//UMCTL2_PORT_CH11_11:

// `define UMCTL2_PORT_CH11_11

//UMCTL2_PORT_CH12_11:

// `define UMCTL2_PORT_CH12_11

//UMCTL2_PORT_CH13_11:

// `define UMCTL2_PORT_CH13_11

//UMCTL2_PORT_CH14_11:

// `define UMCTL2_PORT_CH14_11

//UMCTL2_PORT_CH15_11:

// `define UMCTL2_PORT_CH15_11


//UMCTL2_PORT_CH0_12:

// `define UMCTL2_PORT_CH0_12

//UMCTL2_PORT_CH1_12:

// `define UMCTL2_PORT_CH1_12

//UMCTL2_PORT_CH2_12:

// `define UMCTL2_PORT_CH2_12

//UMCTL2_PORT_CH3_12:

// `define UMCTL2_PORT_CH3_12

//UMCTL2_PORT_CH4_12:

// `define UMCTL2_PORT_CH4_12

//UMCTL2_PORT_CH5_12:

// `define UMCTL2_PORT_CH5_12

//UMCTL2_PORT_CH6_12:

// `define UMCTL2_PORT_CH6_12

//UMCTL2_PORT_CH7_12:

// `define UMCTL2_PORT_CH7_12

//UMCTL2_PORT_CH8_12:

// `define UMCTL2_PORT_CH8_12

//UMCTL2_PORT_CH9_12:

// `define UMCTL2_PORT_CH9_12

//UMCTL2_PORT_CH10_12:

// `define UMCTL2_PORT_CH10_12

//UMCTL2_PORT_CH11_12:

// `define UMCTL2_PORT_CH11_12

//UMCTL2_PORT_CH12_12:

// `define UMCTL2_PORT_CH12_12

//UMCTL2_PORT_CH13_12:

// `define UMCTL2_PORT_CH13_12

//UMCTL2_PORT_CH14_12:

// `define UMCTL2_PORT_CH14_12

//UMCTL2_PORT_CH15_12:

// `define UMCTL2_PORT_CH15_12


//UMCTL2_PORT_CH0_13:

// `define UMCTL2_PORT_CH0_13

//UMCTL2_PORT_CH1_13:

// `define UMCTL2_PORT_CH1_13

//UMCTL2_PORT_CH2_13:

// `define UMCTL2_PORT_CH2_13

//UMCTL2_PORT_CH3_13:

// `define UMCTL2_PORT_CH3_13

//UMCTL2_PORT_CH4_13:

// `define UMCTL2_PORT_CH4_13

//UMCTL2_PORT_CH5_13:

// `define UMCTL2_PORT_CH5_13

//UMCTL2_PORT_CH6_13:

// `define UMCTL2_PORT_CH6_13

//UMCTL2_PORT_CH7_13:

// `define UMCTL2_PORT_CH7_13

//UMCTL2_PORT_CH8_13:

// `define UMCTL2_PORT_CH8_13

//UMCTL2_PORT_CH9_13:

// `define UMCTL2_PORT_CH9_13

//UMCTL2_PORT_CH10_13:

// `define UMCTL2_PORT_CH10_13

//UMCTL2_PORT_CH11_13:

// `define UMCTL2_PORT_CH11_13

//UMCTL2_PORT_CH12_13:

// `define UMCTL2_PORT_CH12_13

//UMCTL2_PORT_CH13_13:

// `define UMCTL2_PORT_CH13_13

//UMCTL2_PORT_CH14_13:

// `define UMCTL2_PORT_CH14_13

//UMCTL2_PORT_CH15_13:

// `define UMCTL2_PORT_CH15_13


//UMCTL2_PORT_CH0_14:

// `define UMCTL2_PORT_CH0_14

//UMCTL2_PORT_CH1_14:

// `define UMCTL2_PORT_CH1_14

//UMCTL2_PORT_CH2_14:

// `define UMCTL2_PORT_CH2_14

//UMCTL2_PORT_CH3_14:

// `define UMCTL2_PORT_CH3_14

//UMCTL2_PORT_CH4_14:

// `define UMCTL2_PORT_CH4_14

//UMCTL2_PORT_CH5_14:

// `define UMCTL2_PORT_CH5_14

//UMCTL2_PORT_CH6_14:

// `define UMCTL2_PORT_CH6_14

//UMCTL2_PORT_CH7_14:

// `define UMCTL2_PORT_CH7_14

//UMCTL2_PORT_CH8_14:

// `define UMCTL2_PORT_CH8_14

//UMCTL2_PORT_CH9_14:

// `define UMCTL2_PORT_CH9_14

//UMCTL2_PORT_CH10_14:

// `define UMCTL2_PORT_CH10_14

//UMCTL2_PORT_CH11_14:

// `define UMCTL2_PORT_CH11_14

//UMCTL2_PORT_CH12_14:

// `define UMCTL2_PORT_CH12_14

//UMCTL2_PORT_CH13_14:

// `define UMCTL2_PORT_CH13_14

//UMCTL2_PORT_CH14_14:

// `define UMCTL2_PORT_CH14_14

//UMCTL2_PORT_CH15_14:

// `define UMCTL2_PORT_CH15_14


//UMCTL2_PORT_CH0_15:

// `define UMCTL2_PORT_CH0_15

//UMCTL2_PORT_CH1_15:

// `define UMCTL2_PORT_CH1_15

//UMCTL2_PORT_CH2_15:

// `define UMCTL2_PORT_CH2_15

//UMCTL2_PORT_CH3_15:

// `define UMCTL2_PORT_CH3_15

//UMCTL2_PORT_CH4_15:

// `define UMCTL2_PORT_CH4_15

//UMCTL2_PORT_CH5_15:

// `define UMCTL2_PORT_CH5_15

//UMCTL2_PORT_CH6_15:

// `define UMCTL2_PORT_CH6_15

//UMCTL2_PORT_CH7_15:

// `define UMCTL2_PORT_CH7_15

//UMCTL2_PORT_CH8_15:

// `define UMCTL2_PORT_CH8_15

//UMCTL2_PORT_CH9_15:

// `define UMCTL2_PORT_CH9_15

//UMCTL2_PORT_CH10_15:

// `define UMCTL2_PORT_CH10_15

//UMCTL2_PORT_CH11_15:

// `define UMCTL2_PORT_CH11_15

//UMCTL2_PORT_CH12_15:

// `define UMCTL2_PORT_CH12_15

//UMCTL2_PORT_CH13_15:

// `define UMCTL2_PORT_CH13_15

//UMCTL2_PORT_CH14_15:

// `define UMCTL2_PORT_CH14_15

//UMCTL2_PORT_CH15_15:

// `define UMCTL2_PORT_CH15_15



`define UMCTL2_SAR_MIN_ADDRW 28


`define UMCTL2_AXI_SAR_BW 1


`define UMCTL2_AXI_SAR_REG_BW 2


`define UMCTL2_AXI_SAR_SW 1


//-----------------------------------------------------------------------------
// AHB PORT
//-----------------------------------------------------------------------------


// Name:         UMCTL2_AHB_LITE_MODE_0
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_0 0

// Name:         UMCTL2_AHB_LITE_MODE_1
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_1 0

// Name:         UMCTL2_AHB_LITE_MODE_2
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_2 0

// Name:         UMCTL2_AHB_LITE_MODE_3
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_3 0

// Name:         UMCTL2_AHB_LITE_MODE_4
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_4 0

// Name:         UMCTL2_AHB_LITE_MODE_5
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_5 0

// Name:         UMCTL2_AHB_LITE_MODE_6
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_6 0

// Name:         UMCTL2_AHB_LITE_MODE_7
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_7 0

// Name:         UMCTL2_AHB_LITE_MODE_8
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_8 0

// Name:         UMCTL2_AHB_LITE_MODE_9
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_9 0

// Name:         UMCTL2_AHB_LITE_MODE_10
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_10 0

// Name:         UMCTL2_AHB_LITE_MODE_11
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_11 0

// Name:         UMCTL2_AHB_LITE_MODE_12
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_12 0

// Name:         UMCTL2_AHB_LITE_MODE_13
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_13 0

// Name:         UMCTL2_AHB_LITE_MODE_14
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_14 0

// Name:         UMCTL2_AHB_LITE_MODE_15
// Default:      Disable
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for lite mode. 
//  - AHB split responses are not supported. 
//  - Port n only supports 1 AHB Master in lite mode. 
//  - Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_LITE_MODE_15 0


// Name:         UMCTL2_AHB_LITE_MODE_TABLE
// Default:      0x0 ( (UMCTL2_AHB_LITE_MODE_15<<15) + (UMCTL2_AHB_LITE_MODE_14<<14) 
//               + (UMCTL2_AHB_LITE_MODE_13<<13) + (UMCTL2_AHB_LITE_MODE_12<<12) + 
//               (UMCTL2_AHB_LITE_MODE_11<<11) + (UMCTL2_AHB_LITE_MODE_10<<10) + 
//               (UMCTL2_AHB_LITE_MODE_9<<9) + (UMCTL2_AHB_LITE_MODE_8<<8) + 
//               (UMCTL2_AHB_LITE_MODE_7<<7) + (UMCTL2_AHB_LITE_MODE_6<<6) + 
//               (UMCTL2_AHB_LITE_MODE_5<<5) + (UMCTL2_AHB_LITE_MODE_4<<4) + (UMCTL2_AHB_LITE_MODE_3<<3) + 
//               (UMCTL2_AHB_LITE_MODE_2<<2) + (UMCTL2_AHB_LITE_MODE_1<<1) + 
//               UMCTL2_AHB_LITE_MODE_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_AHB_LITE_MODE_<n>
`define UMCTL2_AHB_LITE_MODE_TABLE 16'h0


// Name:         UMCTL2_AHB_SPLIT_MODE_0
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_0==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_0 1

// Name:         UMCTL2_AHB_SPLIT_MODE_1
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_1==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_1 1

// Name:         UMCTL2_AHB_SPLIT_MODE_2
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_2==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_2 1

// Name:         UMCTL2_AHB_SPLIT_MODE_3
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_3==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_3 1

// Name:         UMCTL2_AHB_SPLIT_MODE_4
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_4==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_4 1

// Name:         UMCTL2_AHB_SPLIT_MODE_5
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_5==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_5 1

// Name:         UMCTL2_AHB_SPLIT_MODE_6
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_6==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_6 1

// Name:         UMCTL2_AHB_SPLIT_MODE_7
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_7==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_7 1

// Name:         UMCTL2_AHB_SPLIT_MODE_8
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_8==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_8 1

// Name:         UMCTL2_AHB_SPLIT_MODE_9
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_9==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_9 1

// Name:         UMCTL2_AHB_SPLIT_MODE_10
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_10==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_10 1

// Name:         UMCTL2_AHB_SPLIT_MODE_11
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_11==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_11 1

// Name:         UMCTL2_AHB_SPLIT_MODE_12
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_12==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_12 1

// Name:         UMCTL2_AHB_SPLIT_MODE_13
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_13==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_13 1

// Name:         UMCTL2_AHB_SPLIT_MODE_14
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_14==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_14 1

// Name:         UMCTL2_AHB_SPLIT_MODE_15
// Default:      Enable ((UMCTL2_AHB_LITE_MODE_15==0) ? 1 : 0)
// Values:       Disable (0), Enable (1)
// Enabled:      0
// 
// Configures Port n for split mode . 
//  - 1: Port n responds to AHB Read and non-bufferable writes with split response. 
//  - 0: Port n responds to AHB Read and non-bufferable writes by driving hready_resp_n low.
`define UMCTL2_AHB_SPLIT_MODE_15 1


// Name:         UMCTL2_AHB_SPLIT_MODE_TABLE
// Default:      0xffff ( (UMCTL2_AHB_SPLIT_MODE_15<<15) + 
//               (UMCTL2_AHB_SPLIT_MODE_14<<14) + (UMCTL2_AHB_SPLIT_MODE_13<<13) + 
//               (UMCTL2_AHB_SPLIT_MODE_12<<12) + (UMCTL2_AHB_SPLIT_MODE_11<<11) + (UMCTL2_AHB_SPLIT_MODE_10<<10) 
//               + (UMCTL2_AHB_SPLIT_MODE_9<<9) + (UMCTL2_AHB_SPLIT_MODE_8<<8) + 
//               (UMCTL2_AHB_SPLIT_MODE_7<<7) + (UMCTL2_AHB_SPLIT_MODE_6<<6) + 
//               (UMCTL2_AHB_SPLIT_MODE_5<<5) + (UMCTL2_AHB_SPLIT_MODE_4<<4) + 
//               (UMCTL2_AHB_SPLIT_MODE_3<<3) + (UMCTL2_AHB_SPLIT_MODE_2<<2) + 
//               (UMCTL2_AHB_SPLIT_MODE_1<<1) + UMCTL2_AHB_SPLIT_MODE_0)
// Values:       0x0, ..., 0xffff
// 
// TABLE of UMCTL2_AHB_SPLIT_MODE_<n>
`define UMCTL2_AHB_SPLIT_MODE_TABLE 16'hffff


// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_0
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_0 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_1
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_1 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_2
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_2 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_3
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_3 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_4
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_4 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_5
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_5 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_6
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_6 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_7
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_7 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_8
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_8 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_9
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_9 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_10
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_10 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_11
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_11 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_12
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_12 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_13
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_13 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_14
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_14 100

// Name:         UMCTL2_AHB_HREADY_LOW_PERIOD_15
// Default:      100
// Values:       10, ..., 200
// Enabled:      0
// 
// Defines the number of clock cycles for which the controller drives hready low 
// before issuing a split response to a write transaction. The controller drives 
// hready low when it cannot accept a write transaction due to a Buffer Full condition. 
//  
// This parameter has no effect on read transactions.
`define UMCTL2_AHB_HREADY_LOW_PERIOD_15 100


// Name:         UMCTL2_AHB_NUM_MST_0
// Default:      8 ((UMCTL2_AHB_LITE_MODE_0==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_0 8

// Name:         UMCTL2_AHB_NUM_MST_1
// Default:      8 ((UMCTL2_AHB_LITE_MODE_1==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_1 8

// Name:         UMCTL2_AHB_NUM_MST_2
// Default:      8 ((UMCTL2_AHB_LITE_MODE_2==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_2 8

// Name:         UMCTL2_AHB_NUM_MST_3
// Default:      8 ((UMCTL2_AHB_LITE_MODE_3==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_3 8

// Name:         UMCTL2_AHB_NUM_MST_4
// Default:      8 ((UMCTL2_AHB_LITE_MODE_4==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_4 8

// Name:         UMCTL2_AHB_NUM_MST_5
// Default:      8 ((UMCTL2_AHB_LITE_MODE_5==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_5 8

// Name:         UMCTL2_AHB_NUM_MST_6
// Default:      8 ((UMCTL2_AHB_LITE_MODE_6==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_6 8

// Name:         UMCTL2_AHB_NUM_MST_7
// Default:      8 ((UMCTL2_AHB_LITE_MODE_7==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_7 8

// Name:         UMCTL2_AHB_NUM_MST_8
// Default:      8 ((UMCTL2_AHB_LITE_MODE_8==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_8 8

// Name:         UMCTL2_AHB_NUM_MST_9
// Default:      8 ((UMCTL2_AHB_LITE_MODE_9==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_9 8

// Name:         UMCTL2_AHB_NUM_MST_10
// Default:      8 ((UMCTL2_AHB_LITE_MODE_10==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_10 8

// Name:         UMCTL2_AHB_NUM_MST_11
// Default:      8 ((UMCTL2_AHB_LITE_MODE_11==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_11 8

// Name:         UMCTL2_AHB_NUM_MST_12
// Default:      8 ((UMCTL2_AHB_LITE_MODE_12==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_12 8

// Name:         UMCTL2_AHB_NUM_MST_13
// Default:      8 ((UMCTL2_AHB_LITE_MODE_13==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_13 8

// Name:         UMCTL2_AHB_NUM_MST_14
// Default:      8 ((UMCTL2_AHB_LITE_MODE_14==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_14 8

// Name:         UMCTL2_AHB_NUM_MST_15
// Default:      8 ((UMCTL2_AHB_LITE_MODE_15==1) ? 1 : 8)
// Values:       1, ..., 15
// Enabled:      0
// 
// Defines the number of active AHB Masters on Port n. 
// The number of AHB Master specified here is not to include the AHB dummy master. 
// Available masters are from HMASTER 1 to HMASTER 16. HMASTER 0 cannot be used, this position is reserved to the dummy 
// master.
`define UMCTL2_AHB_NUM_MST_15 8


// Name:         UMCTL2_AHB_WRITE_RESP_MODE_0
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_0 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_1
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_1 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_2
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_2 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_3
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_3 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_4
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_4 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_5
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_5 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_6
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_6 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_7
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_7 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_8
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_8 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_9
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_9 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_10
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_10 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_11
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_11 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_12
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_12 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_13
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_13 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_14
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_14 0

// Name:         UMCTL2_AHB_WRITE_RESP_MODE_15
// Default:      Bufferable ((UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15==0) ? 0 : 1)
// Values:       Bufferable (0), Non-Bufferable Only (1), Dynamic (2)
// Enabled:      0
// 
// Selects the AHB Write Response mode for Port n. 
//  - Bufferable mode removes the write response logic and returns an OKAY response for each AHB write data beat without 
//  delay. 
//  - Non-Bufferable mode returns an OKAY response on the last AHB write data beat once that beat has entered the DDRC. 
//  - Dynamic mode allows the write transaction to be bufferable or non-bufferable depending on the value of hprot_n for 
//  the transaction. 
// When data channel interleave is enabled in a multport configuration, only non-bufferable mode is selectable if port is 
// native-size.
`define UMCTL2_AHB_WRITE_RESP_MODE_15 0


// Name:         UMCTL2_AHB_WAQD_0
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_0 2

// Name:         UMCTL2_AHB_WAQD_1
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_1 2

// Name:         UMCTL2_AHB_WAQD_2
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_2 2

// Name:         UMCTL2_AHB_WAQD_3
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_3 2

// Name:         UMCTL2_AHB_WAQD_4
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_4 2

// Name:         UMCTL2_AHB_WAQD_5
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_5 2

// Name:         UMCTL2_AHB_WAQD_6
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_6 2

// Name:         UMCTL2_AHB_WAQD_7
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_7 2

// Name:         UMCTL2_AHB_WAQD_8
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_8 2

// Name:         UMCTL2_AHB_WAQD_9
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_9 2

// Name:         UMCTL2_AHB_WAQD_10
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_10 2

// Name:         UMCTL2_AHB_WAQD_11
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_11 2

// Name:         UMCTL2_AHB_WAQD_12
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_12 2

// Name:         UMCTL2_AHB_WAQD_13
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_13 2

// Name:         UMCTL2_AHB_WAQD_14
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_14 2

// Name:         UMCTL2_AHB_WAQD_15
// Default:      2
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the write address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_WAQD_15 2


// Name:         UMCTL2_AHB_WDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_0 10

// Name:         UMCTL2_AHB_WDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_1 10

// Name:         UMCTL2_AHB_WDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_2 10

// Name:         UMCTL2_AHB_WDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_3 10

// Name:         UMCTL2_AHB_WDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_4 10

// Name:         UMCTL2_AHB_WDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_5 10

// Name:         UMCTL2_AHB_WDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_6 10

// Name:         UMCTL2_AHB_WDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_7 10

// Name:         UMCTL2_AHB_WDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_8 10

// Name:         UMCTL2_AHB_WDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_9 10

// Name:         UMCTL2_AHB_WDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_10 10

// Name:         UMCTL2_AHB_WDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_11 10

// Name:         UMCTL2_AHB_WDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_12 10

// Name:         UMCTL2_AHB_WDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_13 10

// Name:         UMCTL2_AHB_WDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_14 10

// Name:         UMCTL2_AHB_WDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB burst beats can be stored in the XPI write data buffer of Port n.
`define UMCTL2_AHB_WDQD_15 10


// Name:         UMCTL2_AHB_RAQD_0
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_0 4

// Name:         UMCTL2_AHB_RAQD_1
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_1 4

// Name:         UMCTL2_AHB_RAQD_2
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_2 4

// Name:         UMCTL2_AHB_RAQD_3
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_3 4

// Name:         UMCTL2_AHB_RAQD_4
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_4 4

// Name:         UMCTL2_AHB_RAQD_5
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_5 4

// Name:         UMCTL2_AHB_RAQD_6
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_6 4

// Name:         UMCTL2_AHB_RAQD_7
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_7 4

// Name:         UMCTL2_AHB_RAQD_8
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_8 4

// Name:         UMCTL2_AHB_RAQD_9
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_9 4

// Name:         UMCTL2_AHB_RAQD_10
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_10 4

// Name:         UMCTL2_AHB_RAQD_11
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_11 4

// Name:         UMCTL2_AHB_RAQD_12
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_12 4

// Name:         UMCTL2_AHB_RAQD_13
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_13 4

// Name:         UMCTL2_AHB_RAQD_14
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_14 4

// Name:         UMCTL2_AHB_RAQD_15
// Default:      4
// Values:       2, ..., 16
// Enabled:      0
// 
// Defines how many AHB addresses can be stored in the read address buffer of Port n. 
// Each address represents an AHB burst transaction.
`define UMCTL2_AHB_RAQD_15 4


// Name:         UMCTL2_AHB_RDQD_0
// Default:      10 ((UMCTL2_A_SYNC_0 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_0 10

// Name:         UMCTL2_AHB_RDQD_1
// Default:      10 ((UMCTL2_A_SYNC_1 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_1 10

// Name:         UMCTL2_AHB_RDQD_2
// Default:      10 ((UMCTL2_A_SYNC_2 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_2 10

// Name:         UMCTL2_AHB_RDQD_3
// Default:      10 ((UMCTL2_A_SYNC_3 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_3 10

// Name:         UMCTL2_AHB_RDQD_4
// Default:      10 ((UMCTL2_A_SYNC_4 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_4 10

// Name:         UMCTL2_AHB_RDQD_5
// Default:      10 ((UMCTL2_A_SYNC_5 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_5 10

// Name:         UMCTL2_AHB_RDQD_6
// Default:      10 ((UMCTL2_A_SYNC_6 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_6 10

// Name:         UMCTL2_AHB_RDQD_7
// Default:      10 ((UMCTL2_A_SYNC_7 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_7 10

// Name:         UMCTL2_AHB_RDQD_8
// Default:      10 ((UMCTL2_A_SYNC_8 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_8 10

// Name:         UMCTL2_AHB_RDQD_9
// Default:      10 ((UMCTL2_A_SYNC_9 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_9 10

// Name:         UMCTL2_AHB_RDQD_10
// Default:      10 ((UMCTL2_A_SYNC_10 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_10 10

// Name:         UMCTL2_AHB_RDQD_11
// Default:      10 ((UMCTL2_A_SYNC_11 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_11 10

// Name:         UMCTL2_AHB_RDQD_12
// Default:      10 ((UMCTL2_A_SYNC_12 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_12 10

// Name:         UMCTL2_AHB_RDQD_13
// Default:      10 ((UMCTL2_A_SYNC_13 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_13 10

// Name:         UMCTL2_AHB_RDQD_14
// Default:      10 ((UMCTL2_A_SYNC_14 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_14 10

// Name:         UMCTL2_AHB_RDQD_15
// Default:      10 ((UMCTL2_A_SYNC_15 == 1) ? 2 : 10)
// Values:       2, ..., 64
// Enabled:      0
// 
// Defines how many AHB data beats that can be stored in the XPI read data buffer of Port n.
`define UMCTL2_AHB_RDQD_15 10

//-----------------------------------------------
// AHB Static Parameters
//-----------------------------------------------

`define A2X_IDW        4
`define A2X_SP_IDW     4
`define A2X_PP_AW  32
`define A2X_SP_AW  32
`define A2X_AW  32
`define A2X_BLW 4
`define A2X_SP_BLW 4
`define A2X_PP_BLW 4

`define A2X_HBLW      3    // AHB Burst Width
`define A2X_BSW       3    // Burst Size Width
`define A2X_HPTW      4    // AHB Protection Type Width
`define A2X_HRESPW    2    // AHB Response Width
//-----------------------------------------------
// XPI parameter
//-----------------------------------------------


// Name:         UMCTL2_RDWR_ORDERED_0
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>0 && (UMCTL2_A_TYPE_0 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_0 0


// `define UMCTL2_A_RDWR_ORDERED_0

// Name:         UMCTL2_RDWR_ORDERED_1
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>1 && (UMCTL2_A_TYPE_1 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_1 0


// `define UMCTL2_A_RDWR_ORDERED_1

// Name:         UMCTL2_RDWR_ORDERED_2
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>2 && (UMCTL2_A_TYPE_2 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_2 0


// `define UMCTL2_A_RDWR_ORDERED_2

// Name:         UMCTL2_RDWR_ORDERED_3
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>3 && (UMCTL2_A_TYPE_3 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_3 0


// `define UMCTL2_A_RDWR_ORDERED_3

// Name:         UMCTL2_RDWR_ORDERED_4
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>4 && (UMCTL2_A_TYPE_4 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_4 0


// `define UMCTL2_A_RDWR_ORDERED_4

// Name:         UMCTL2_RDWR_ORDERED_5
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>5 && (UMCTL2_A_TYPE_5 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_5 0


// `define UMCTL2_A_RDWR_ORDERED_5

// Name:         UMCTL2_RDWR_ORDERED_6
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>6 && (UMCTL2_A_TYPE_6 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_6 0


// `define UMCTL2_A_RDWR_ORDERED_6

// Name:         UMCTL2_RDWR_ORDERED_7
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>7 && (UMCTL2_A_TYPE_7 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_7 0


// `define UMCTL2_A_RDWR_ORDERED_7

// Name:         UMCTL2_RDWR_ORDERED_8
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>8 && (UMCTL2_A_TYPE_8 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_8 0


// `define UMCTL2_A_RDWR_ORDERED_8

// Name:         UMCTL2_RDWR_ORDERED_9
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>9 && (UMCTL2_A_TYPE_9 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_9 0


// `define UMCTL2_A_RDWR_ORDERED_9

// Name:         UMCTL2_RDWR_ORDERED_10
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>10 && (UMCTL2_A_TYPE_10 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_10 0


// `define UMCTL2_A_RDWR_ORDERED_10

// Name:         UMCTL2_RDWR_ORDERED_11
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>11 && (UMCTL2_A_TYPE_11 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_11 0


// `define UMCTL2_A_RDWR_ORDERED_11

// Name:         UMCTL2_RDWR_ORDERED_12
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>12 && (UMCTL2_A_TYPE_12 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_12 0


// `define UMCTL2_A_RDWR_ORDERED_12

// Name:         UMCTL2_RDWR_ORDERED_13
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>13 && (UMCTL2_A_TYPE_13 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_13 0


// `define UMCTL2_A_RDWR_ORDERED_13

// Name:         UMCTL2_RDWR_ORDERED_14
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>14 && (UMCTL2_A_TYPE_14 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_14 0


// `define UMCTL2_A_RDWR_ORDERED_14

// Name:         UMCTL2_RDWR_ORDERED_15
// Default:      0
// Values:       0 1
// Enabled:      (UMCTL2_A_NPORTS>15 && (UMCTL2_A_TYPE_15 == 3) && 
//               (UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15==0))
// 
// If set, this parameter preserves the ordering between a read transaction and a write transaction on Port n. 
// Additional logic is instantiated in the XPI to transport all read and write commands from 
// the application port interface to the HIF interface in the order of acceptance.
`define UMCTL2_RDWR_ORDERED_15 0


// `define UMCTL2_A_RDWR_ORDERED_15


// Name:         UMCTL2_RDWR_ORDERED_TABLE
// Default:      0x0 ( (UMCTL2_RDWR_ORDERED_15<<15) + (UMCTL2_RDWR_ORDERED_14<<14) + 
//               (UMCTL2_RDWR_ORDERED_13<<13) + (UMCTL2_RDWR_ORDERED_12<<12) + 
//               (UMCTL2_RDWR_ORDERED_11<<11) + (UMCTL2_RDWR_ORDERED_10<<10) + 
//               (UMCTL2_RDWR_ORDERED_9<<9) + (UMCTL2_RDWR_ORDERED_8<<8) + 
//               (UMCTL2_RDWR_ORDERED_7<<7) + (UMCTL2_RDWR_ORDERED_6<<6) + (UMCTL2_RDWR_ORDERED_5<<5) + 
//               (UMCTL2_RDWR_ORDERED_4<<4) + (UMCTL2_RDWR_ORDERED_3<<3) + 
//               (UMCTL2_RDWR_ORDERED_2<<2) + (UMCTL2_RDWR_ORDERED_1<<1) + UMCTL2_RDWR_ORDERED_0)
// Values:       0x0, ..., 0xffff
// 
// Table of UMCTL2_RDWR_ORDERED_<n>
`define UMCTL2_RDWR_ORDERED_TABLE 16'h0

//----------------------------------------
// Required to include BCMs
//----------------------------------------


`define RM_BCM02 0


`define RM_BCM05 0


`define RM_BCM05_ATV 1


`define RM_BCM01 1


`define RM_BCM53 1


`define RM_BCM51


`define RM_BCM46_A 1


`define RM_BCM46_B 1


`define RM_BCM46_C 1


`define RM_BCM46_D 1


`define RM_BCM46_E 1


`define RM_BCM57_CHB 1


`define RM_BCM64 1


`define RM_BCM86 1


`define RM_BCM55 1


`define RM_BCM06 0


`define RM_BCM06_ATV 1


`define RM_BCM07 0


`define RM_BCM07_ATV 1


`define RM_BCM21 0


`define RM_SVA01 0


`define RM_SVA02 0


`define RM_SVA03 0


`define RM_SVA04 0


`define RM_SVA05 0


`define RM_SVA06 0


`define RM_SVA07 0


`define RM_SVA08 0


`define RM_SVA09 0


`define RM_SVA12_B 0


`define RM_SVA12_C 0


`define RM_SVA99 0


`define RM_BVM02 0


`define RM_BCM00_MAJ 1



`define RM_BCM21_ATV 1


`define RM_BCM50 0


`define RM_BCM56 0

//BCM57 is used in CHB,ARb,DDRC

`define RM_BCM57 0


`define RM_BCM58 0


`define RM_BCM65 0


`define RM_BCM65_ATV 1


`define RM_BCM95_I 0


`define RM_BCM95_IE 1


`define RM_BCM66_WAE 0


`define RM_BCM66_WAE_ATV 1

//UMCTL_LOG2(x) calculates ceiling(log2(x)), 0<=x<=1048576 
`define UMCTL_LOG2(x) ((x<=1)?0:(x<=2)?1:(x<=4)?2:(x<=8)?3:(x<=16)?4:(x<=32)?5:(x<=64)?6:(x<=128)?7:(x<=256)?8:(x<=512)?9:(x<=1024)?10:(x<=2048)?11:(x<=4096)?12:(x<=1024*8)?13:(x<=1024*16)?14:(x<=1024*32)?15:(x<=1024*64)?16:(x<=1024*128)?17:(x<=1024*256)?18:(x<=1024*512)?19:(x<=1024*1024)?20:21)

//----------------------------------------
// testbench
//----------------------------------------

// Name:         UMCTL2_MAX_AXI_DATAW
// Default:      512
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// UMCTL2_MAX_DATAW: AXI maximum r/w datawidth. The value 
// corresponds to the maximum value of UMCTL2_PORT_DW_x
`define UMCTL2_MAX_AXI_DATAW 512


// Name:         UMCTL2_MAX_AXI_ADDRW
// Default:      64
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// Maximum width of AXI address
`define UMCTL2_MAX_AXI_ADDRW 64


// Name:         UMCTL2_USE_SPLIT
// Default:      0
// Values:       0, 1
// 
// Check if any AHB port is split capable.
// `define UMCTL2_USE_SPLIT


// Name:         UMCTL2_A2X_COH_BUFMODE
// Default:      1
// Values:       0 1
// Enabled:      0
// 
// Internal regression only. Enables AHB A2X cohenercy in case of  Write Resp equal to Bufferable mode.
`define UMCTL2_A2X_COH_BUFMODE


// Name:         UMCTL2_PORT_EN_RESET_VALUE
// Default:      0
// Values:       0 1
// 
// Internal core Assembler regression only. Currently there is no mean to write a register for the ping test. 
// port_en reset value is 0. This paramter is set to 1 in the core Assembler to changes the reset value of port_en to 1 
// and allow the ping test complete.
`define UMCTL2_PORT_EN_RESET_VALUE 0


// Name:         UMCTL2_REF_ZQ_IO
// Default:      0
// Values:       0, 1
// Enabled:      Always
// 
// Provide optional hardware access to trigger refresh and ZQCS commands, instead of APB access.
// `define UMCTL2_REF_ZQ_IO


// Name:         MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// (DDRC Scrub functionality Enabled)
// `define MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW


// Name:         MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW_IE0
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// (DDRC Scrub functionality Enabled and INLNIE_ECC=0)
// `define MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW_IE0


// Name:         MEMC_ENH_CAM_PTR
// Default:      1
// Values:       0, 1
// Enabled:      Always
// 
// This parameter enables enhanced the CAM pointer mechanism. 
//  - When enabled, the CAM supports out-of-order pushing and out-of-order popping (scheduling). 
//  - When disabled, the CAM supports out-of-order popping (scheduling), but the CAM does not support out-of-order pushing 
//  (in-order pushing only) 
// This feature requires more area and might impact synthesis timing depending on the process and so on. The size of the 
// extra area depends on hardware configuration, such as number of CAM entries, number of BSMs, VPRW feature, and so on. 
//  
// This feature must be enabled unless Synopsys suggests.
`define MEMC_ENH_CAM_PTR


`define UMCTL2_DYN_BSM_OR_MEMC_ENH_CAM_PTR


// `define MEMC_INLINE_ECC_OR_UMCTL2_DYN_BSM


// `define UMCTL2_DYN_BSM_AND_NOT_MEMC_ENH_CAM_PTR


// Name:         MEMC_ENH_RDWR_SWITCH
// Default:      1 (MEMC_ENH_CAM_PTR+0)
// Values:       0, 1
// Enabled:      MEMC_ENH_CAM_PTR == 1
// 
// This parameter enables enhanced Read/Write switching mechanism. 
// This contains the following features: 
//   - Issues ACT command for the other direction command in advance as preparation. 
//   - RD/WR switching based on page status. 
//   - Schedule write commands if WR CAM is a certain fill level. 
// Notes: 
// This feature must be enabled unless Synopsys suggests.
`define MEMC_ENH_RDWR_SWITCH


// Name:         MEMC_RDWR_SWITCH_POL_SEL
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_ENH_RDWR_SWITCH==1
// 
// This parameter enables the read-write switching policy to be selected through a register. 
//  - 1: Implement two read-write switching policies in the configuration, using a register to select which policy is 
//  used. 
//  - 0: Read-write switching policy decided by MEMC_ENH_RDWR_SWITCH.
// `define MEMC_RDWR_SWITCH_POL_SEL


// `define MEMC_ORIG_RDWR_SWITCH_EXIST


// `define MEMC_ENH_DYN_BSM


`define UMCTL2_DYN_BSM_OR_MEMC_ENH_RDWR_SWITCH


// Name:         MEMC_NTT_UPD_ACT
// Default:      1 ((MEMC_ENH_CAM_PTR == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Enables to update NTT by ACT for the other direction.
`define MEMC_NTT_UPD_ACT


// Name:         MEMC_ADD_REPLACE_ACT
// Default:      0 ((MEMC_NTT_UPD_ACT == 1 && MEMC_ENH_RDWR_SWITCH == 1 && 
//               UMCTL2_NUM_BSM > 32) ? 1 : 0)
// Values:       0, 1
// Enabled:      MEMC_NTT_UPD_ACT == 1
// 
// MEMC_ADD_REPLACE_ACT 
// Add dedicated replace logic for ACT
// `define MEMC_ADD_REPLACE_ACT


// Name:         MEMC_NTT_UPD_PRE
// Default:      1 ((MEMC_ENH_CAM_PTR == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Enables to update NTT by PRE.
`define MEMC_NTT_UPD_PRE


// Name:         MEMC_ADD_REPLACE_PRE
// Default:      1 ((MEMC_NTT_UPD_PRE == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// MEMC_ADD_REPLACE_PRE 
// Add dedicated replace logic for PRE
`define MEMC_ADD_REPLACE_PRE


// Name:         MEMC_OPT_MULTI_COL
// Default:      0
// Values:       0, 1
// 
// Enables optimization for multi collided entries
// `define MEMC_OPT_MULTI_COL


// `define MEMC_OPT_MULTI_COL_OR_MEMC_INLINE_ECC



// Name:         DDRCTL_HET_INTERLEAVE
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// DDRCTL_HET_INTERLEAVE 
// Enable Heterogeneous Data Channel Interleaving Support 
// In DDR4 Dual Channel shared-AC configurations, this parameter enables Data Channel Interleaving support for 
// heterogeneous DRAM densities on either channel. 
// When enabled, the controller supports interleaving between the two data channels  while they are connected to two 
// different density DRAM memories. The ratio of the densities is defined through register programming. 
// When disabled, the DRAM memory densities should be equal. 
// This feature is under access control. Contact Synopsys for more information.
`define DDRCTL_HET_INTERLEAVE 0


// `define DDRCTL_HET_INTERLEAVE_EN_1


// `define MEMC_DDR5


// `define MEMC_DDR5_ONLY


// `define MEMC_DDR5_1_TO_4


`define MEMC_DDR5_EN 0


`define MEMC_DDR5_ONLY_EN 0


`define DDRCTL_DDR_OR_MEMC_LPDDR4


// `define MEMC_DDR5_OR_INLINE_ECC


// `define MEMC_DDR5_OR_MEMC_ECC


// `define DDRCTL_LLC_SDTC


// Name:         DDRCTL_LLC_4CYCSCH
// Default:      0 ((MEMC_ENH_CAM_PTR==1 && DDRCTL_LLC_SDTC==1) ? 1 : 0)
// Values:       0, 1
// Enabled:      MEMC_ENH_CAM_PTR == 1
// 
// Enable 4 cycle scheduler support
// `define DDRCTL_LLC_4CYCSCH


// Name:         DDRCTL_LLC_NO_WC
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_LLC == 1
// 
// Disable Write-combine feature
// `define DDRCTL_LLC_NO_WC


`define DDRCTL_LLC_4CYCSCH_EN 0


`define MEMC_ENH_CAM_PTR_AND_NO_DDRCTL_LLC_4CYCSCH


// `define NO_MEMC_ENH_CAM_PTR_OR_DDRCTL_LLC_4CYCSCH


// `define DDRCTL_LLC_SDTC_AND_NO_DDRCTL_LLC_4CYCSCH


// `define DDRCTL_LLC_SDTC_OR_DDRCTL_LLC_4CYCSCH


// Name:         DDRCTL_LLC_OPT_TIMING_CPF
// Default:      0 ((DDRCTL_LLC) ? 1 : 0)
// Values:       0, 1
// Enabled:      DDRCTL_LLC == 1
// 
// Optimize timing for DDR54 LLC CPF
// `define DDRCTL_LLC_OPT_TIMING_CPF


// Name:         DDRCTL_VER_NUMBER_VAL
// Default:      0x3131302a
// Values:       0x0, ..., 0xffffffff
// Enabled:      0
// 
// DDRCTL_VER_NUMBER_VAL 
// Specifies the DDRCTL_VER_NUMBER read-only register value
`define DDRCTL_VER_NUMBER_VAL 32'h3131302a
//`define DDRCTL_VER_NUMBER_VAL 32'h30313130


// Name:         DDRCTL_VER_TYPE_VAL
// Default:      0x6c633030
// Values:       0x0, ..., 0xffffffff
// Enabled:      0
// 
// DDRCTL_VER_TYPE_VAL 
// Specifies the DDRCTL_VER_TYPE read-only register value
`define DDRCTL_VER_TYPE_VAL 32'h6c633030
//`define DDRCTL_VER_TYPE_VAL 32'h6C633030


// Name:         MAX_UMCTL2_A_ID_MAPW
// Default:      32
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_A_ID_MAPW 
// (Maximum Value of UMCTL2_A_ID_MAPW)
`define MAX_UMCTL2_A_ID_MAPW 32


// Name:         MAX_UMCTL2_NUM_VIR_CH
// Default:      32
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_NUM_VIR_CH 
// (Maximum Value of Virture Channel)
`define MAX_UMCTL2_NUM_VIR_CH 32


// Name:         MAX_UMCTL2_A_NPORTS
// Default:      16
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_A_NPORTS 
// (Maximum Value of Host Port)
`define MAX_UMCTL2_A_NPORTS 16


// Name:         MAX_A_DW_INT_NB
// Default:      11
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A_DW_INT_NB 
// (Maximum number of bits for UMCTL2_A_DW_INT_n)
`define MAX_A_DW_INT_NB 11


// Name:         MAX_AXI_WAQD_NB
// Default:      6
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_WAQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_WAQD_n)
`define MAX_AXI_WAQD_NB 6


// Name:         MAX_AXI_WDQD_NB
// Default:      8
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_WDQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_WDQD_n)
`define MAX_AXI_WDQD_NB 8


// Name:         MAX_AXI_RAQD_NB
// Default:      6
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_RAQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_RAQD_n)
`define MAX_AXI_RAQD_NB 6


// Name:         MAX_AXI_RDQD_NB
// Default:      8
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_RDQD_NB 
// (Maximum number of bits for Maximum UMCTL2_AXI_RDQD_n)
`define MAX_AXI_RDQD_NB 8


// Name:         MAX_AXI_WRQD_NB
// Default:      7
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_WRQD_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_WRQD_n)
`define MAX_AXI_WRQD_NB 7


// Name:         MAX_AXI_SYNC_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_SYNC_NB 
// (Maximum number of Bits for Maximum UMCTL2_AXI_SYNC_n)
`define MAX_AXI_SYNC_NB 1


// Name:         MAX_ASYNC_FIFO_N_SYNC_NB
// Default:      3
// Values:       -2147483648, ..., 2147483647
// 
// MAX_DATA_CHANNEL_INTERLEAVE_NS_NB 
// (Maximum number of Bits for Maximum UMCTL2_ASYNC_FIFO_N_SYNC_SYNC_n)
`define MAX_ASYNC_FIFO_N_SYNC_NB 3


// Name:         MAX_DATA_CHANNEL_INTERLEAVE_NS_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_DATA_CHANNEL_INTERLEAVE_NS_NB 
// (Maximum number of Bits for Maximum UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_n)
`define MAX_DATA_CHANNEL_INTERLEAVE_NS_NB 1


// Name:         MAX_VPR_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_VPR_EN_NB 
// (Maximum number of Bits for Maximum UMCTL_MAX_VPR_EN)
`define MAX_VPR_EN_NB 1


// Name:         MAX_VPW_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_VPW_EN_NB 
// (Maximum number of Bits for Maximum UMCTL2_MAX_VPW_EN)
`define MAX_VPW_EN_NB 1


// Name:         MAX_USE2RAQ_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_USE2RAQ_NB 
// (Maximum number of Bits for Maximum UMCTL2_XPI_USE2RAQ_n)
`define MAX_USE2RAQ_NB 1


// Name:         MAX_NUM_VIR_CH_NB
// Default:      7
// Values:       -2147483648, ..., 2147483647
// 
// MAX_NUM_VIR_CH_NB 
// (Maximum number of Bits for Maximum UMCTL2_NUM_VIR_CH_n)
`define MAX_NUM_VIR_CH_NB 7


// Name:         MAX_STATIC_VIR_CH_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// MAX_STATIC_VIR_CH_NB 
// (Maximum number of Bits for Maximum UMCTL2_STATIC_VIR_CH_n)
`define MAX_STATIC_VIR_CH_NB 1


// Name:         MAX_RRB_EXTRAM_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RRB_RXTRAM_NB 
// (Maximum number of Bits for Maximum UMCTL2_RRB_EXTRAM_n)
`define MAX_RRB_EXTRAM_NB 1


// Name:         MAX_SMALL_SIZED_PORT_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX bits to represent Small sized port per XPI port 
// (Maximum number of Bits for Maximum UMCTL2_RRB_EXTRAM_n)
`define MAX_SMALL_SIZED_PORT_NB 1


// Name:         MAX_RRB_EXTRAM_REG_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RRB_RXTRAM_REG_NB 
// (Maximum number of Bits for Maximum UMCTL2_RRB_EXTRAM_REG_n)
`define MAX_RRB_EXTRAM_REG_NB 1


// Name:         MAX_RDWR_ORDERED_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RDWR_ORDERED_NB 
// (Maximum number of Bits for Maximum UMCTL2_RDWR_ORDERED_n)
`define MAX_RDWR_ORDERED_NB 1


// Name:         MAX_RRB_THRESHOLD_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RRB_THRESHOLD_EN_NB 
// (Maximum number of Bits for Maximum UMCTL2_RRB_THRESHOLD_EN_n)
`define MAX_RRB_THRESHOLD_EN_NB 1


// Name:         MAX_READ_DATA_INTERLEAVE_EN_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_READ_DATA_INTERLEAVE_EN_NB 
// (Maximum number of Bits for Maximum UMCTL2_READ_DATA_INTERLEAVE_EN_n)
`define MAX_READ_DATA_INTERLEAVE_EN_NB 1


// Name:         MAX_AXI_LOCKW
// Default:      2
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AXI_LOCKW 
// (Maximum Value of UMCTL2_AXI_LOCK_WIDTH_n)
`define MAX_AXI_LOCKW 2


// Name:         MAX_AP_ASYNC_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AP_ASYNC_NB 
// (Maximum number of Bit for UMCTL2_AP_ASYNC_A_n)
`define MAX_AP_ASYNC_NB 1


// Name:         MAX_A2X_NUM_AHBM_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_NUM_AHBM_NB 
// (Maximum Number of Bit for UMCTL2_AHB_NUM_MST_n)
`define MAX_A2X_NUM_AHBM_NB 5


// Name:         MAX_A2X_BRESP_MODE_NB
// Default:      2
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_BRESP_MODE_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_WRITE_RESP_MODE_n)
`define MAX_A2X_BRESP_MODE_NB 2


// Name:         MAX_A2X_AHB_LITE_MODE_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_AHB_LITE_MODE_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_LITE_MODE_n)
`define MAX_A2X_AHB_LITE_MODE_NB 1


// Name:         MAX_A2X_SPLIT_MODE_NB
// Default:      1
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_SPLIT_MODE_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_SPLIT_MODE_n)
`define MAX_A2X_SPLIT_MODE_NB 1


// Name:         MAX_A2X_HREADY_LOW_PERIOD_NB
// Default:      8
// Values:       -2147483648, ..., 2147483647
// 
// MAX_A2X_HREADY_LOW_PERIOD_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_HREADY_LOW_PERIOD_n)
`define MAX_A2X_HREADY_LOW_PERIOD_NB 8


// Name:         MAX_AHB_NUM_MST_NB
// Default:      4
// Values:       -2147483648, ..., 2147483647
// 
// MAX_AHB_NUM_MST_NB 
// (Maximum Number of Bit for Maximum value for UMCTL2_AHB_NUM_MST_n)
`define MAX_AHB_NUM_MST_NB 4


// Name:         MAX_PORT_NBYTES
// Default:      64
// Values:       -2147483648, ..., 2147483647
// 
// MAX_PORT_NBYTES 
// (Maximum Number of Bytes for UMCTL2_PORT_NBYTES_n)
`define MAX_PORT_NBYTES 64


// Name:         MAX_RINFOW_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RINFOW_NB 
// (Maximum Number of bits for UMCTL2_RD_INFOW_n)
`define MAX_RINFOW_NB 5


// Name:         MAX_RINFOW_NSA_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RINFOW_NSA_NB 
// (Maximum Number of bits for UMCTL2_RD_INFOW_NSA_n)
`define MAX_RINFOW_NSA_NB 5


// Name:         MAX_WINFOW_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_WINFOW_NB 
// (Maximum Number of bits for UMCTL2_WR_INFOW_n)
`define MAX_WINFOW_NB 5


// Name:         MAX_RPINFOW_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RPINFOW_NB 
// (Maximum Number of bits for UMCTL2_RP_INFOW_n)
`define MAX_RPINFOW_NB 5


// Name:         MAX_UMCTL2_AXI_TAGBITS
// Default:      128
// Values:       -2147483648, ..., 2147483647
// 
// MAX_UMCTL2_AXI_TAGBITS 
// (Maximum Value of UMCTL2_AXI_TAGBITS_n)
`define MAX_UMCTL2_AXI_TAGBITS 128


// Name:         MAX_MEMC_TAGBITS_NB
// Default:      7
// Values:       -2147483648, ..., 2147483647
// 
// MAX_MEMC_TAGBITS_NB 
// (Maximum Num of bits for MEMC_TAGBITS_n)
`define MAX_MEMC_TAGBITS_NB 7


// Name:         MAX_RAQ_TABLE_TABLE_NB
// Default:      5
// Values:       -2147483648, ..., 2147483647
// 
// MAX_RAQ_TABLE_TABLE_NB 
// (Maximum Num of bits for RAQ_TABLE_n)
`define MAX_RAQ_TABLE_TABLE_NB 5


`define UMCTL2_P_AP_ASYNC_ANY


`define LPDDR45_DQSOSC 1


`define LPDDR45_DQSOSC_EN


`define LPDDR54_DQOSC_EN_OR_MEMC_DDR5


// Name:         DDRCTL_PPT2
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_LPDDR==1
// 
// This parameter provides optional hardware to utilize Periodic Phase Training 2 (PPT2) which is the LPDDR54 PHY 
// retraining feature.
// `define DDRCTL_PPT2


// `define MEMC_CPF_PREA


// Name:         DDRCTL_TWO_DEV_CFG_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_DDR5 == 1) && (DDRCTL_LUT_ADDRMAP_EN == 1))
// 
// DDRCTL_TWO_DEV_CFG_EN 
// Enables two device configuration support for heterogeneous ranks/devices
// `define DDRCTL_TWO_DEV_CFG_EN


// `define DDRCTL_TWO_DEV_CFG_OR_DDR4_MRAM_EN


// Name:         DDRCTL_TWO_TIMING_SETS_EN
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_TWO_TIMING_SETS_EN 
// Enables two sets of timing support for heterogeneous ranks/devices 
// The value of this parameter is set to 0 for disable it to get better timing, and is shown here for completeness.
// `define DDRCTL_TWO_TIMING_SETS_EN


// Name:         DDRCTL_TWO_PRE_EN
// Default:      0
// Values:       0 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_TWO_PRE_EN 
// Enables two sets of PRE function in PAS_CPE 
// The value of this parameter is set to 0 for disable it to get better timing, and is shown here for completeness.
// `define DDRCTL_TWO_PRE_EN


// Name:         DDRCTL_PRESB_EN
// Default:      0 (MEMC_DDR5 == 1)
// Values:       0 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_PRESB_EN 
// Enables DDR5 PRESB function for performance
// `define DDRCTL_PRESB_EN


// `define MEMC_CPF_PRESB


// `define MEMC_CPF_PREA_OR_PRESB


// Name:         DDRCTL_PERRANK_LP
// Default:      1
// Values:       0 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_PERRANK_LP 
// Enables DDR5 per rank low power contrl function for auto powerdown mode and auto selfref mode 
// The value of this parameter is set to 1 for saving design and verification efforts for later releases, and is shown 
// here for completeness.
`define DDRCTL_PERRANK_LP


`define DDRCTL_PERRANK_LP_EN 1


// Name:         DDRCTL_RW_ACT_SAME_CYC_EN
// Default:      1
// Values:       0 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_RW_ACT_SAME_CYC_EN 
// Enables DDR5 RW/ACT command combination in the same clock cycle for performance
`define DDRCTL_RW_ACT_SAME_CYC_EN


// Name:         DDRCTL_THREE_CMD_COMB_EN
// Default:      1
// Values:       0 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_THREE_CMD_COMB_EN 
// Enables DDR5 three commands combination in one clock cycle for performance
`define DDRCTL_THREE_CMD_COMB_EN


// Name:         DDRCTL_GAP_CTRL
// Default:      0
// Values:       0 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_GAP_CTRL 
// Enables DDR5 control of the phase gap between continous WR/RD command to avoid interamble.
// `define DDRCTL_GAP_CTRL


// Name:         DDRCTL_PAS_NON_DYN_GS
// Default:      0
// Values:       0 1
// Enabled:      ((MEMC_DDR5==1) & (MEMC_FREQ_RATIO==4))
// 
// DDRCTL_PAS_NON_DYN_GS 
// Enables non-dynamic PAS global scheduler in DDR5.
// `define DDRCTL_PAS_NON_DYN_GS


// Name:         DDRCTL_DDR5_PHYUPD
// Default:      0
// Values:       0 1
// Enabled:      MEMC_DDR5==1
// 
// DDRCTL_DDR5_PHYUPD 
// Enables Support DDR5 PHY update feature
// `define DDRCTL_DDR5_PHYUPD


// Name:         DDRCTL_SW_RDWR_EN
// Default:      0
// Values:       0 1
// Enabled:      MEMC_DDR5==1
// 
// DDRCTL_SW_RDWR_EN 
// Enables Manual Read/Write through SW Command Interface.
// `define DDRCTL_SW_RDWR_EN


// Name:         UMCTL2_ECC_TEST_MODE_EN_OR_MEMC_DDR5
// Default:      0 ((UMCTL2_ECC_TEST_MODE_EN==1) || (MEMC_DDR5==1))
// Values:       0 1
// Enabled:      ((DDRCTL_ENABLE_INTERNAL_TESTING==1) || (MEMC_DDR5==1))
// 
// UMCTL2_ECC_TEST_MODE_EN_OR_MEMC_DDR5
// `define UMCTL2_ECC_TEST_MODE_EN_OR_MEMC_DDR5


// Name:         DDRCTL_SW_RFM_CTRL
// Default:      0
// Values:       0 1
// Enabled:      MEMC_DDR5==1
// 
// DDRCTL_SW_RFM_CTRL 
// Enables Manual Refresh Management control through SW Command Interface.
// `define DDRCTL_SW_RFM_CTRL


// Name:         DDRCTL_HW_RFM_CTRL
// Default:      0 ((MEMC_DDR5 == 1) ? 1 : 0)
// Values:       0 1
// Enabled:      ((DDRCTL_LPDDR==1) || (MEMC_DDR5==1))
// 
// DDRCTL_HW_RFM_CTRL 
// Enables internal Refresh Management control in DDRCTL.
// `define DDRCTL_HW_RFM_CTRL


// `define DDRCTL_LPDDR_RFM


// Name:         DDRCTL_LPDDR_RFMSBC
// Default:      0
// Values:       0 1
// Enabled:      ((DDRCTL_LPDDR==1) && (DDRCTL_HW_RFM_CTRL==1))
// 
// DDRCTL_LPDDR_RFMSBC 
// Enables LPDDR5 Refresh Management Single-Bank Counters
// `define DDRCTL_LPDDR_RFMSBC


`define DDRCTL_LPDDR_RFMSBC_EN 0


// Name:         DDRCTL_SW_PREPB_PRESB_REFSB
// Default:      0
// Values:       0 1
// Enabled:      MEMC_DDR5==1
// 
// DDRCTL_SW_PREPB_PRESB_REFSB 
// Enables PREpb/PREsb/REFsb support for SW Command Interface.
// `define DDRCTL_SW_PREPB_PRESB_REFSB


// Name:         DDRCTL_DFI_CTRLMSG
// Default:      1 (DDRCTL_LPDDR==1)
// Values:       0, 1
// Enabled:      ((DDRCTL_LPDDR==1) || (MEMC_DDR5==1))
// 
// DDRCTL_DFI_CTRLMSG 
// Enables DFI Control message feature
`define DDRCTL_DFI_CTRLMSG


// Name:         DDRCTL_ENHANCED_WCK
// Default:      0 ((DDRCTL_LPDDR==1) && (MEMC_NUM_RANKS>1))
// Values:       0, 1
// Enabled:      ((DDRCTL_LPDDR==1) && (MEMC_NUM_RANKS>1))
// 
// DDRCTL_ENHANCED_WCK 
// Enables Enhanced WCK Always On Mode
// `define DDRCTL_ENHANCED_WCK


// Name:         DDRCTL_DFI_HIF_CMD_ADDR_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_DDR5 == 1)&&(MEMC_FREQ_RATIO==4))
// 
// This parameter includes the DFI Sideband output - dbg_dfi_hif_cmd_addr. 
//  
// The DRAM to HIF address translator is included in the DDRCTL.
// `define DDRCTL_DFI_HIF_CMD_ADDR_EN


`define DDRCTL_DFI_HIF_CMD_ADDR_EN_1 0


// Name:         DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_DDR5 == 1)&&(MEMC_FREQ_RATIO==4))
// 
// The new output dbg_dfi_hif_cmd_wdata_ptr will be included by enabling this parameter. 
// It will enable the propagation of bits from hif_cmd_wdata_ptr to the dbg_dfi_hif_cmd_wdata_ptr.
// `define DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN


`define DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN_1 0


// Name:         DDRCTL_DFI_HIF_CMD_WDATA_PTR_RANGE
// Default:      1 ((UMCTL2_INCL_ARB_OR_CHB==1) ? 1 : MEMC_HIF_WDATA_PTR_BITS)
// Values:       1, ..., (UMCTL2_INCL_ARB_OR_CHB==1) ? 1 : MEMC_HIF_WDATA_PTR_BITS
// Enabled:      DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN==1
// 
// This parameter is the number of bits from the input hif_cmd_wdata_ptr which will be propagated to the output 
// dbg_dfi_hif_cmd_wdata_ptr. 
// This parameter is the width of the dbg_dfiX_hif_cmd_wdata_ptr_Pp 
// outputs(X=0...1), (P=0...1). 
//  It is valid only when DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN = 1. 
//  Valid Values: 
//   In HIF only configurations,this parameter is controllable. The valid value is 1 to MEMC_HIF_WDATA_PTR_BITS. 
//   In ARB configurations, this parameter is fixed to 1.
`define DDRCTL_DFI_HIF_CMD_WDATA_PTR_RANGE 1


// `define DDRCTL_CHB_PER_SCRUB_EN



// `define DDRCTL_ONE_PER_RMW_OUTSTANDING


// Name:         DDRCTL_CHB_WDATA_PTR_BITS
// Default:      23 ((DDRCTL_CHB_PER_SCRUB_EN==1) ? 
//               DDRCTL_DFI_HIF_CMD_WDATA_PTR_RANGE : 0) + DDRCTL_CHB_TXIDW + DDRCTL_CHB_WDPTR_DIDAW + 
//               DDRCTL_CHB_WDPTR_DIDMW + DDRCTL_CHB_WDPTR_NDIDW + 1 + 1 + 1 + 
//               DDRCTL_CHB_HIF_BS_MAX_NUM_CHUNKS_CLOG2+1 +DDRCTL_CHB_HIF_MAX_NUM_CHUNKS_PER_BEAT_CLOG2 + 1 
//               + ((DDRCTL_CHB_WRZERO_EN==1) ? 1 : 0) + ((DDRCTL_CHB_TZ_EN==1) ? 1 : 
//               0)
// Values:       -2147483648, ..., 2147483647
// 
// DBID, DataIDAlgn, DataIDMask, NumDataID, PartialWr, Last, LastPkt, NumChunks, ChunkStrb, DataSource
`define DDRCTL_CHB_WDATA_PTR_BITS 23


`define UMCTL2_AXI_WDATA_PTR_BITS 18


`define MEMC_WDATA_PTR_BITS 18


// Name:         DDRCTL_DFI_HIF_CMD_WDATA_PTR_START
// Default:      17 (UMCTL2_INCL_ARB_OR_CHB==1 ? (MEMC_WDATA_PTR_BITS-1):0)
// Values:       0, ..., UMCTL2_INCL_ARB_OR_CHB==1 ? (MEMC_WDATA_PTR_BITS-1):0
// Enabled:      DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN==1
// 
// This parameter indicates the starting bit position in input hif_cmd_wdata_ptr from which 
// DDRCTL_DFI_HIF_CMD_WDATA_PTR_RANGE number of bits will be propagated as dbg_dfi_hif_cmd_wdata_ptr output. 
//  It is valid only when DDRCTL_DFI_HIF_CMD_WDATA_PTR_EN = 1. 
//  Valid Values: 
// In HIF only configurations, this parameter is controllable. The valid values are 0 to (MEMC_HIF_WDATA_PTR_BITS-1). 
// In ARB configurations, this parameter is fixed to (MEMC_WDATA_PTR_BITS-1).
`define DDRCTL_DFI_HIF_CMD_WDATA_PTR_START 17


// Name:         DDRCTL_DDR_DUAL_CHANNEL_EN
// Default:      0 (DDRCTL_DDR_DUAL_CHANNEL==1)
// Values:       0 1
// Enabled:      0
// 
// DDRCTL_DDR_DUAL_CHANNEL_EN 
// Enables DUAL CHANNEL feature in DDR5 (expressed as a parameter).
`define DDRCTL_DDR_DUAL_CHANNEL_EN 0


// Name:         DDRCTL_LPDDR_DUAL_CHANNEL
// Default:      0 ((DDRCTL_LPDDR==1) && (UMCTL2_DUAL_CHANNEL==1))
// Values:       0, 1
// Enabled:      0
// 
// DDRCTL_LPDDR_DUAL_CHANNEL 
// Enables DUAL CHANNEL feature in LPDDR.
// `define DDRCTL_LPDDR_DUAL_CHANNEL


// Name:         DDRCTL_LPDDR_DUAL_CHANNEL_EN
// Default:      0 (DDRCTL_LPDDR_DUAL_CHANNEL==1)
// Values:       0 1
// Enabled:      0
// 
// DDRCTL_LPDDR_DUAL_CHANNEL_EN 
// Enables DUAL CHANNEL feature in LPDDR (expressed as a parameter).
`define DDRCTL_LPDDR_DUAL_CHANNEL_EN 0


// Name:         DDRCTL_SINGLE_INST_DUALCH
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_DDR==1
// 
// This parameter enables Single Instance Dual Channel support
// `define DDRCTL_SINGLE_INST_DUALCH


// `define DDRCTL_DDR_DUAL_CHANNEL__OR__SINGLE_INST_DUALCH


// Name:         DDRCTL_SYMMETRIC_DDRC_DUALCH
// Default:      0
// Values:       0, 1
// Enabled:      ((DDRCTL_DDR_DUAL_CHANNEL==1) && (UMCTL2_SHARED_AC==0) && 
//               (DDRCTL_SINGLE_INST_DUALCH==0))
// 
// This parameter enables Symmetric DDRC on Dual Channel support
// `define DDRCTL_SYMMETRIC_DDRC_DUALCH


// `define DDRCTL_SINGLE_INST_DUALCH__OR__SYMMETRIC_DDRC_DUALCH


// `define DDRCTL_DUAL_DDRC_CPE


`define DDRCTL_DUAL_DDRC_CPE_EN 0


`define DDRCTL_NUM_DDRC_CPE 1


// `define DDRCTL_SINGLE_DDRC_CPE_IN_DUAL_CHANNEL


// Name:         DDRCTL_DDR_SINGLE_CHANNEL
// Default:      0 ((DDRCTL_DDR==1) && (UMCTL2_DUAL_CHANNEL==0))
// Values:       0, 1
// Enabled:      0
// 
// DDRCTL_DDR_SINGLE_CHANNEL 
// Enables DUAL CHANNEL feature in DDR5.
// `define DDRCTL_DDR_SINGLE_CHANNEL


// `define DDRCTL_DDR_DCH_HBW_1


`define DDRCTL_DDR_DRAM_DATA_WIDTH 32


`define DDRCTL_DDR_DRAM_ECC_WIDTH 0


// `define DDRCTL_DDR_DRAM_ECC_WIDTH_GT_0


`define DDRCTL_DFI_DATA_WIDTH 32


`define DDRCTL_DFI_MASK_WIDTH 4


`define DDRCTL_DFI_DATAEN_WIDTH 2


// Name:         DDRCTL_DDR_DCH_STAGGER_MAX
// Default:      15
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// DDRCTL_DDR_DCH_STAGGER_MAX 
// Define the maximum number of stagger delay based on DFI clock cycle.
`define DDRCTL_DDR_DCH_STAGGER_MAX 15


// Name:         DDRCTL_DDR_DCH_STAGGER_BITS
// Default:      4 ([ <functionof> DDRCTL_DDR_DCH_STAGGER_MAX ])
// Values:       -2147483648, ..., 2147483647
// Enabled:      0
// 
// DDRCTL_DDR_DCH_STAGGER_BITS 
// Define the enough bit width to cover DDRCTL_DDR_DCH_STAGGER_MAX value.
`define DDRCTL_DDR_DCH_STAGGER_BITS 4


`define DDRCTL_MAX_XPI_PORT_DW_GTEQ_512 0


// Name:         DDRCTL_DDR_BWL_EN
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR5 == 1
// 
// DDRCTL_DDR_BWL_EN 
// Enables DDR5 bandwidth limiter control feature.
// `define DDRCTL_DDR_BWL_EN


// Name:         DDRCTL_MCP_INCLUDE
// Default:      Enable
// Values:       Disable (0), Enable (1)
// Enabled:      Always
// 
// DDRCTL_MCP_INCLUDE 
// Enables multicycle paths in synthesis. 
// It is suggested to disable them whenever there are only single cycle paths. For example in LBIST applications
`define DDRCTL_MCP_INCLUDE 1


// Name:         DDRCTL_DDRC_CID_WIDTH
// Default:      0 (UMCTL2_CID_WIDTH > 2 ? 2 : UMCTL2_CID_WIDTH)
// Values:       0 1 2
// Enabled:      DDRCTL_DDR==1
// 
// This parameter specifies the width of Chip ID (dfi_cid) for DDR4 3DS support.
`define DDRCTL_DDRC_CID_WIDTH 0


// `define DDRCTL_DDRC_CID_EN


// `define DDRCTL_DDRC_CID_WIDTH_GT_0

// `define DDRCTL_DDRC_CID_WIDTH_GT_1


`define DDRCTL_DDRC_CID_WIDTH_0

// `define DDRCTL_DDRC_CID_WIDTH_1

// `define DDRCTL_DDRC_CID_WIDTH_2


`define DDRCTL_DDRC_MAX_NUM_STACKS 1


// `define MEMC_NUM_RANKS_GT_1_OR_DDRCTL_DDRC_CID_WIDTH_GT_0


`define MEMC_LPDDR4_OR_DDRCTL_DDRC_CID_EN


// Name:         DDRCTL_DDRC_NUM_LRANKS_TOTAL
// Default:      1 ((UMCTL2_NUM_LRANKS_TOTAL > 
//               (MEMC_NUM_RANKS*DDRCTL_DDRC_MAX_NUM_STACKS)) ? (MEMC_NUM_RANKS*DDRCTL_DDRC_MAX_NUM_STACKS) : 
//               UMCTL2_NUM_LRANKS_TOTAL)
// Values:       1 2 4 8 16
// Enabled:      DDRCTL_DDRC_CID_WIDTH>0
// 
// This parameter specifies the maximum number of logical ranks supported by the controller for DDR4. The minimum value is 
// equal to MEMC_NUM_RANKS.
`define DDRCTL_DDRC_NUM_LRANKS_TOTAL 1


`define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_0

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_1

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_2

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_3

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_4

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_5

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_6

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_7

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_8

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_9

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_10

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_11

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_12

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_13

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_14

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_GT_15


// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_0

`define DDRCTL_DDRC_NUM_LRANKS_TOTAL_1

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_2

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_3

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_4

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_5

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_6

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_7

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_8

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_9

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_10

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_11

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_12

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_13

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_14

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_15

// `define DDRCTL_DDRC_NUM_LRANKS_TOTAL_16


`define DDRCTL_DDRC_LRANK_BITS 0


`define DDRCTL_DDRC_RANKBANK_BITS 4


// Name:         DDRCTL_DDRC_NUM_TOTAL_BANKS
// Default:      0x10 (1<<DDRCTL_DDRC_RANKBANK_BITS)
// Values:       0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200
// Enabled:      0
// 
// This parameter specifies the maximum number of banks supported with a given hardware configuration in DDR4.
`define DDRCTL_DDRC_NUM_TOTAL_BANKS 32'h10


`define DDRCTL_DDRC_NUM_PR_CONSTRAINTS 0


// `define DDRCTL_DDRC_NUM_PR_CONSTRAINTS_GT_1


// Name:         DDRCTL_PAS_CID_WIDTH
// Default:      0 (UMCTL2_CID_WIDTH)
// Values:       0 1 2 3 4
// Enabled:      DDRCTL_DDR==1
// 
// This parameter specifies the width of Chip ID (dfi_cid) for DDR5 3DS support.
`define DDRCTL_PAS_CID_WIDTH 0


// `define DDRCTL_PAS_CID_EN


// `define DDRCTL_PAS_CID_WIDTH_GT_0

// `define DDRCTL_PAS_CID_WIDTH_GT_1

// `define DDRCTL_PAS_CID_WIDTH_GT_2

// `define DDRCTL_PAS_CID_WIDTH_GT_3


`define DDRCTL_PAS_CID_WIDTH_0

// `define DDRCTL_PAS_CID_WIDTH_1

// `define DDRCTL_PAS_CID_WIDTH_2

// `define DDRCTL_PAS_CID_WIDTH_3

// `define DDRCTL_PAS_CID_WIDTH_4


`define DDRCTL_PAS_MAX_NUM_STACKS 1


// Name:         DDRCTL_PAS_NUM_LRANKS_TOTAL
// Default:      1 (UMCTL2_NUM_LRANKS_TOTAL)
// Values:       1 2 4 8 16 32 64
// Enabled:      DDRCTL_PAS_CID_WIDTH>0
// 
// This parameter specifies the maximum number of logical ranks supported by the controller for DDR5. The minimum value is 
// equal to MEMC_NUM_RANKS.
`define DDRCTL_PAS_NUM_LRANKS_TOTAL 1


`define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_0

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_1

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_2

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_3

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_4

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_5

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_6

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_7

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_8

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_9

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_10

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_11

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_12

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_13

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_14

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_15

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_16

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_17

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_18

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_19

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_20

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_21

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_22

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_23

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_24

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_25

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_26

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_27

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_28

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_29

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_30

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_31

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_32

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_33

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_34

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_35

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_36

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_37

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_38

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_39

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_40

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_41

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_42

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_43

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_44

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_45

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_46

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_47

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_48

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_49

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_50

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_51

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_52

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_53

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_54

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_55

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_56

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_57

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_58

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_59

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_60

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_61

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_62

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_GT_63


// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_0

`define DDRCTL_PAS_NUM_LRANKS_TOTAL_1

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_2

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_3

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_4

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_5

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_6

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_7

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_8

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_9

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_10

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_11

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_12

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_13

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_14

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_15

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_16

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_17

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_18

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_19

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_20

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_21

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_22

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_23

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_24

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_25

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_26

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_27

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_28

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_29

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_30

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_31

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_32

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_33

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_34

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_35

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_36

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_37

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_38

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_39

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_40

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_41

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_42

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_43

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_44

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_45

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_46

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_47

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_48

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_49

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_50

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_51

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_52

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_53

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_54

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_55

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_56

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_57

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_58

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_59

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_60

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_61

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_62

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_63

// `define DDRCTL_PAS_NUM_LRANKS_TOTAL_64


`define DDRCTL_PAS_LRANK_BITS 0


`define DDRCTL_PAS_RANKBANK_BITS 4


// Name:         DDRCTL_PAS_NUM_TOTAL_BANKS
// Default:      0x10 (1<<DDRCTL_PAS_RANKBANK_BITS)
// Values:       0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x800
// Enabled:      0
// 
// This parameter specifies the maximum number of banks supported with a given hardware configuration in DDR5.
`define DDRCTL_PAS_NUM_TOTAL_BANKS 32'h10


// Name:         DDRCTL_KBD_ECC_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_ECC_SUPPORT>0) && (MEMC_SIDEBAND_ECC_EN==1) && 
//               (UMCTL2_OCPAR_EN==0) && (UMCTL2_OCECC_EN==0) && (UMCTL2_WDATA_EXTRAM==1) && 
//               (DDRCTL_DDR==1))
// 
// Enables the controller to detect data errors, mark data as Known Bad Data (KBD) and track the known bad data for as long 
// as it exists in the data path. 
// SDRAM Sideband ECC is enabled. 
// TXDAT and RXDAT channels protected by ECC (DataCheck flit field). Data can be marked as Known Bad Data (Poison flit 
// field).
`define DDRCTL_KBD_ECC_EN 0


// Name:         DDRCTL_KBD_ECC_BYP_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_ECC_SUPPORT==1) && (MEMC_SIDEBAND_ECC_EN==1) && 
//               (UMCTL2_OCPAR_EN==0) && (UMCTL2_OCECC_EN==0) && (UMCTL2_WDATA_EXTRAM==1) && 
//               (DDRCTL_DDR==1) && (DDRCTL_KBD_ECC_EN==0))
// 
// Enables the controller to detect data errors, mark data as Known Bad Data (KBD) and track the known bad data for as long 
// as it exists in the data path. 
// Internal SDRAM Sideband ECC can be bypassed if ECC generation and checking are performed externally. 
// The controller provides information signals to facilitate external SDRAM sideband ECC generation and error injection on 
// the write path, error status signals to facilitate error reporting in the read path. 
// TXDAT and RXDAT channels protected by ECC (DataCheck flit field). Data can be marked as Known Bad Data (Poison flit 
// field).
`define DDRCTL_KBD_ECC_BYP_EN 0


// Name:         DDRCTL_CHB_KBD_ECC_EN
// Default:      0 ((DDRCTL_KBD_ECC_EN==1) || (DDRCTL_KBD_ECC_BYP_EN==1))
// Values:       0, 1
// Enabled:      Always
// 
// Enables end to end data error tracking, DRAM sideband ECC enabled or disabled. 
// Parameter used by the CHI Bridge to propagate ECC/Poison bits through the 
// write and read data paths. 
// Parameter can be overwritten to facilitate standalone verification of the CHB Bridge.
// `define DDRCTL_CHB_KBD_ECC_EN


// Name:         DDRCTL_CHB_DATA_POIS_EN
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB==1
// 
// If set data poisoning is supported at the RXDAT and TXDAT interfaces, as per the CHI specification.
// `define DDRCTL_CHB_DATA_POIS_EN


// Name:         DDRCTL_NUM_BITS_PER_KBD
// Default:      128 ((DDRCTL_CHB_DATA_POIS_EN==0) ? 128 : 64)
// Values:       64 128
// Enabled:      DDRCTL_CHB_KBD_ECC_EN
// 
// Defines Posion and DataCheck granularity at CHI interface 
//  Set to 64  : For CHI Spec defined DataCheck and Poison width 
//  Set to 128 : For custom 128/9/1 Data/ECC/Posion encoding scheme 
//  When set to 128, DataCheck field width reduces to [(DDRCTL_CHB_DW/128)*9bits] wide
`define DDRCTL_NUM_BITS_PER_KBD 128


`define DDRCTL_HIF_KBD_WIDTH 2


// Name:         DDRCTL_CHB_CHI_ECCW
// Default:      18 (DDRCTL_NUM_BITS_PER_KBD==128) ? (DDRCTL_CHB_DW/128)*9 : 
//               (DDRCTL_CHB_DW/8)
// Values:       1, ..., 64
// Enabled:      0
// 
// The number of ECC bits per RXDAT/TXDAT flit or CHI data beat. 
//  ECC encoding scheme depends on DDRCTL_NUM_BITS_PER_KBD
`define DDRCTL_CHB_CHI_ECCW 18


// Name:         DDRCTL_CHB_DATA_CHECK_EN
// Default:      0
// Values:       0, 1
// Enabled:      0
// 
// If set odd byte parity is supported at the RXDAT and TXDAT interfaces, as per the CHI specification.
// `define DDRCTL_CHB_DATA_CHECK_EN


// Name:         DDRCTL_CHB_DCHK_EN
// Default:      0 ((DDRCTL_CHB_DATA_CHECK_EN || DDRCTL_CHB_KBD_ECC_EN) && 
//               DDRCTL_INCL_CHB)
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB==1
// 
// Enable Data Check Flit field, i.e. DataCheck field exists in the DAT flit.
// `define DDRCTL_CHB_DCHK_EN


// Name:         DDRCTL_CHB_POIS_EN
// Default:      0 ((DDRCTL_CHB_DATA_POIS_EN || DDRCTL_CHB_KBD_ECC_EN) && 
//               DDRCTL_INCL_CHB)
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB==1
// 
// Enables Poison flit field, i.e. Poison flit field exists in the DAT flit.
// `define DDRCTL_CHB_POIS_EN


`define DDRCTL_CHB_POIS_EN_VAL 0


`define MEMC_ADDR_ERR 1


`define MEMC_ADDR_ERR_EN


`define MEMC_ADDR_ERR_EN_VAL 1


// Name:         DDRCTL_CHB_DERR_EN
// Default:      0 ((MEMC_ECC == 1 || MEMC_DDR5 == 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      0
// 
// Sources of DERR are crc error and UE. DERR is present when either of these are present.
// `define DDRCTL_CHB_DERR_EN


// Name:         DDRCTL_CHB_MPAM_EN
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_CHB_VERSION > 2 && DDRCTL_INCL_CHB==1
// 
// Enable MPAM Support in DDRCTL 
// - 0 : MPAM Feature no supported by controller 
//         Controller expects MPAMID field to be absent 
// - 1 : MPAM Feature supported by controller
// `define DDRCTL_CHB_MPAM_EN


// Name:         DDRCTL_CHB_HIF_CRDT_CNT_WIDTH
// Default:      7
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// HIF Credit Counter Width
`define DDRCTL_CHB_HIF_CRDT_CNT_WIDTH 7


// Name:         DDRCTL_CHB_CAM_BUSY_THR_HPR
// Default:      2
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// CBUSY - CAM BUSY THRESHOLD - HPR
`define DDRCTL_CHB_CAM_BUSY_THR_HPR 2


// Name:         DDRCTL_CHB_CAM_MIDDLE_THR_HPR
// Default:      5
// Values:       1, ..., 10
// Enabled:      DDRCTL_CHB_MPAM_EN==1
// 
// CBUSY - CAM MIDDLE THRESHOLD - HPR
`define DDRCTL_CHB_CAM_MIDDLE_THR_HPR 5


// Name:         DDRCTL_CHB_CAM_FREE_THR_HPR
// Default:      7
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// CBUSY - CAM FREE THRESHOLD - HPR
`define DDRCTL_CHB_CAM_FREE_THR_HPR 7


// Name:         DDRCTL_CHB_CAM_BUSY_THR_LPR
// Default:      2
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// CBUSY - CAM BUSY THRESHOLD - LPR
`define DDRCTL_CHB_CAM_BUSY_THR_LPR 2


// Name:         DDRCTL_CHB_CAM_MIDDLE_THR_LPR
// Default:      5
// Values:       1, ..., 10
// Enabled:      DDRCTL_CHB_MPAM_EN==1
// 
// CBUSY - CAM MIDDLE THRESHOLD - LPR
`define DDRCTL_CHB_CAM_MIDDLE_THR_LPR 5


// Name:         DDRCTL_CHB_CAM_FREE_THR_LPR
// Default:      7
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// DDRCTL_CHB_CAM_FREE_THR_HPR: 
// CBUSY - CAM FREE THRESHOLD - HPR
`define DDRCTL_CHB_CAM_FREE_THR_LPR 7


// Name:         DDRCTL_CHB_CAM_BUSY_THR_WR
// Default:      2
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// CBUSY - CAM BUSY THRESHOLD - WR
`define DDRCTL_CHB_CAM_BUSY_THR_WR 2


// Name:         DDRCTL_CHB_CAM_MIDDLE_THR_WR
// Default:      5
// Values:       1, ..., 10
// Enabled:      DDRCTL_CHB_MPAM_EN==1
// 
// CBUSY - CAM MIDDLE THRESHOLD - WR
`define DDRCTL_CHB_CAM_MIDDLE_THR_WR 5


// Name:         DDRCTL_CHB_CAM_FREE_THR_WR
// Default:      7
// Values:       1, ..., 10
// Enabled:      DDRCTL_INCL_CHB==1
// 
// CBUSY - CAM FREE THRESHOLD - WR
`define DDRCTL_CHB_CAM_FREE_THR_WR 7



// Name:         DDRCTL_CHB_MPAM_NONSEC_PARTS
// Default:      128
// Values:       1, ..., 256
// 
// Number of Non-Secure partitions.
`define DDRCTL_CHB_MPAM_NONSEC_PARTS 128


// Name:         DDRCTL_CHB_MPAM_SEC_PARTS
// Default:      128
// Values:       1, ..., 256
// 
// Number of Non-Secure partitions.
`define DDRCTL_CHB_MPAM_SEC_PARTS 128


// Name:         DDRCTL_CHB_MPAM_HAS_MAXLIMIT
// Default:      1
// Values:       0, 1
// 
// MPAM has max limit (2 regions: normal and deferred)
`define DDRCTL_CHB_MPAM_HAS_MAXLIMIT


// Name:         DDRCTL_CHB_MPAM_HAS_MINLIMIT
// Default:      1
// Values:       0, 1
// 
// MPAM has min limit (2 regions: normal and preferred)
`define DDRCTL_CHB_MPAM_HAS_MINLIMIT


// Name:         DDRCTL_MPAMF_MBW_IDR_BWA_WD
// Default:      0x8
// Values:       0x4, ..., 0x10
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Number of implemented bits in the bandwidth allocation fields
`define DDRCTL_MPAMF_MBW_IDR_BWA_WD 6'h8


// Name:         DDRCTL_MPAMCFG_MBW_MIN
// Default:      0xf
// Values:       0x0, ..., 0xfff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Memory minimum bandwidth
`define DDRCTL_MPAMCFG_MBW_MIN 8'hf


// Name:         DDRCTL_MPAMCFG_MBW_MAX
// Default:      0x20
// Values:       0x0, ..., 0xfff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Memory maximum bandwidth
`define DDRCTL_MPAMCFG_MBW_MAX 8'h20


// Name:         DDRCTL_MPAMF_MBW_IDR_BWPBM_WD
// Default:      0x8
// Values:       0x1, ..., 0x1fff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Number of bits indicating portions in MPAMCFG_MBW_PBM
`define DDRCTL_MPAMF_MBW_IDR_BWPBM_WD 13'h8


// Name:         DDRCTL_NS_MBWUMON_NUM_MON
// Default:      0x0
// Values:       0x0, ..., 0xff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Number of MBWU monitoring Non-Secure counters
`define DDRCTL_NS_MBWUMON_NUM_MON 16'h0


// Name:         DDRCTL_S_MBWUMON_NUM_MON
// Default:      0x0
// Values:       0x0, ..., 0xff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Number of MBWU monitoring Secure counters
`define DDRCTL_S_MBWUMON_NUM_MON 16'h0


// Name:         DDRCTL_MBWUMON_MON_EN
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Number of MBWU monitoring Enable
// `define DDRCTL_MBWUMON_MON_EN


// Name:         DDRCTL_MBW_WINWD_CYC_CNT
// Default:      0xff
// Values:       0x0, ..., 0xffffff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// Specifies the width of window in terms of core_clk cycle count
`define DDRCTL_MBW_WINWD_CYC_CNT 24'hff


// Name:         MPAMF_IMPL_IDR_VALUE
// Default:      0xa00
// Values:       0x0, ..., 0xffff
// Enabled:      DDRCTL_CHB_MPAM_EN == 1
// 
// MPAMF implementation-specfic partition feature.
`define MPAMF_IMPL_IDR_VALUE 32'ha00


// Name:         DDRCTL_APB4_EN
// Default:      0 (DDRCTL_CHB_MPAM_EN == 1 || DDRCTL_CHB_TZ_EN == 1)
// Values:       0, 1
// Enabled:      0
// 
// Enable APB4 compliant subordinate interface 
// when 1 : Adds PSTRB and PPROT interfaces 
// PSTRB is not supported even in APB4 mode, SW should always do full word access 
// PPROT support to limited to MPAM region, other regions ignore PPROT value
// `define DDRCTL_APB4_EN


`define DDRCTL_CHB_PREFETCH_EN_VAL 0


// Name:         DDRCTL_CHB_RRB_CBGINFO_EN
// Default:      1 (DDRCTL_CHB_PREFETCH_EN || MEMC_ADDR_ERR_EN || MEMC_DDR5)
// Values:       0, 1
// Enabled:      0
// 
// Prefetch or derr or nderr error reporting enabled.
`define DDRCTL_CHB_RRB_CBGINFO_EN


`define DDRCTL_KBD_SBECC_EN 0


`define DDRCTL_EXT_SBECC_EN 0



// `define DDRCTL_KBD_SBECC_EN_1


`define DDRCTL_DFI_KBD_WIDTH 8


// `define DDRCTL_EXT_SBECC_EN_1


// `define DDRCTL_EXT_SBECC_KBD_EN_1


`define DBG_DFI_ECC_CTRL_PP_WIDTH 2


// Name:         DDRCTL_CAPAR_RETRY
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_DDR==1
// 
// This parameter enables the support for CAPAR retry feature. 
// 
// `define DDRCTL_CAPAR_RETRY


// `define DDRCTL_DDR_DUAL_CHANNEL__OR__SINGLE_INST_DUALCH_OR_CAPAR_RETRY


// Name:         DDRCTL_CA_PARITY
// Default:      0 ((DDRCTL_DDR_DUAL_CHANNEL==1) || (DDRCTL_CAPAR_RETRY == 1))
// Values:       0, 1
// Enabled:      ((MEMC_DDR5 == 1) && (DDRCTL_SINGLE_INST_DUALCH==0) && 
//               (DDRCTL_CAPAR_RETRY == 0))
// 
// DDRCTL_CA_PARITY 
// Enables CA Parity Generation and Poisoning feature in DDR4 and DDR5 RCD.
// `define DDRCTL_CA_PARITY


// Name:         DDRCTL_WR_CRC_RETRY
// Default:      0 (DDRCTL_CAPAR_RETRY)
// Values:       0, 1
// Enabled:      ((DDRCTL_DDR==1) && (DDRCTL_CAPAR_RETRY==0))
// 
// This parameter enables the support for write CRC retry feature. 
// 
// `define DDRCTL_WR_CRC_RETRY


// Name:         DDRCTL_RD_CRC_RETRY
// Default:      0 (DDRCTL_CAPAR_RETRY)
// Values:       0, 1
// Enabled:      ((DDRCTL_DDR==1) && (DDRCTL_CAPAR_RETRY==0))
// 
// This parameter enables the support for RD CRC retry feature.  
//  
// Also, when Sideband ECC is enabled, this parameter enables Uncorrectable ECC retry feature as well.  
// 
// `define DDRCTL_RD_CRC_RETRY


// Name:         DDRCTL_RD_UE_RETRY
// Default:      0 (DDRCTL_RD_CRC_RETRY==1 && MEMC_SIDEBAND_ECC==1)
// Values:       0, 1
// Enabled:      0
// 
// This parameter is automatically enabled when both DDRCTL_RD_CRC_RETRY and MEMC_SIDEBAND_ECC are enabled  
// 
// `define DDRCTL_RD_UE_RETRY


// `define DDRCTL_WR_CRC_RETRY_AND_DDRCTL_RD_CRC_RETRY


// `define DDRCTL_ANY_RETRY


// Name:         DDRCTL_RETRY_FIFO_DEPTH
// Default:      40 ((DDRCTL_CAPAR_RETRY==1) ? 44 : 40)
// Values:       16 24 32 40 44 48
// Enabled:      DDRCTL_WR_CRC_RETRY== 1
// 
// This parameter specifies the depth of retry FIFO (number of retry entries).
`define DDRCTL_RETRY_FIFO_DEPTH 40


// Name:         DDRCTL_RETRY_WDATA_EXTRAM
// Default:      0 ((DDRCTL_WR_CRC_RETRY== 1) ? 1 : 0)
// Values:       0, 1
// Enabled:      DDRCTL_WR_CRC_RETRY==1
// 
// This parameter specifies the controller to use external or internal SRAM for retry write data.
// `define DDRCTL_RETRY_WDATA_EXTRAM


`define DDRCTL_RETRY_FIFO_DEPTH_BITS 6


`define DDRCTL_RETRY_WDATARAM_AW 7


`define DDRCTL_RETRY_WDATARAM_DEPTH 80


// Name:         DDRCTL_RETRY_WDATARAM_WR_LATENCY
// Default:      0
// Values:       0 1
// Enabled:      DDRCTL_RETRY_WDATA_EXTRAM == 1
// 
// This parameter specifies the number of clock cycles for external retry Write Data SRAM write that can be delayed before 
// actually written to
`define DDRCTL_RETRY_WDATARAM_WR_LATENCY 0


// Name:         DDRCTL_RETRY_WDATARAM_RD_LATENCY
// Default:      1
// Values:       1 2
// Enabled:      DDRCTL_RETRY_WDATA_EXTRAM == 1
// 
// This parameter specifies the number of clock cycles from external retry Write Data SRAM read address to read data at 
// DDRCTL I/F
`define DDRCTL_RETRY_WDATARAM_RD_LATENCY 1


// `define DDRCTL_RETRY_WDATARAM_RD_LATENCY_2


// Name:         DDRCTL_RETRY_MAX_ADD_RD_LAT
// Default:      0 ((DDRCTL_CAPAR_RETRY==1) ? 24 : 0)
// Values:       0 4 6 8 10 12 14 16 18 20 22 24
// Enabled:      DDRCTL_CAPAR_RETRY==1
// 
// This parameter specifies the maximum additional latency on dfi_rddata path for retry logic. 
//   
// When specified, this parameter defines a maximum number of pipeline stages to dfi_rddata_valid, dfi_rddata, and 
// dfi_rddata_dbi  
// before the rest of internal DDRCTL logic observes it. 
//  
// This parameter is required to compensate for a potential longer delay in the PHY and PCB for the dfi_alert_n 
// signal compared to the read data signal. 
// For calculating the recommended settings (in terms of core_ddrc_core_clk), refer to your PHY and PCB behavior:  
// (Maximum Alert delay through PHY and PCB) - (Minimum Read data delay through PHY and PCB) + (PHY's max granularity of 
// dfi_rddata beats that can be corrupted before an erroneous read).
`define DDRCTL_RETRY_MAX_ADD_RD_LAT 0


// `define DDRCTL_RETRY_MAX_ADD_RD_LAT_EN


`define DDRCTL_RETRY_MAX_ADD_RD_LAT_LG2 1


// Name:         MEMC_RT_FIFO_DEPTH
// Default:      32 ((DDRCTL_RETRY_MAX_ADD_RD_LAT>0) ? 44 : 32)
// Values:       32 36 40 44 48
// 
// Specifies the Response Tracker FIFO depth, which needs to contain entries for all read commands which are currently in 
// progress (command has been sent, but data has not all been received). 
//  
// Maximum required FIFO depth can be calculated by looking at round-trip read latency 
//  - pi_rt_rd_vld -> dfi_rd command =           1 cycle 
//  - dfi_rd command -> DFI read data =          trddata_en + tphy_rdlat cycles (please see PHY PUB databook for their 
//  values) 
//  - DFI read data -> load_ptr =                1 cycle  
//  - RDIMM/LRDIMM delay =                       3 cycles 
//  - Up to 16 more cycles of latency are required in case of unaligned read data  
//  - Up to MEMC_FREQ_RATIO*UMCTL2_RETRY_ADD_RD_LAT more cycles of latency are required if UMCTL2_RETRY_ADD_RD_LAT>0  
// Example 1:LPDDR2 
//  
// Considering LPDDR2 connected to a DDRgen2 mPHY in DFI 1:1 mode, we have: 
//  - trddata_en = RL-4 cycles (RL means Read Latency) 
//  - tphy_rdlat = 29.5 cycles 
//  - RL = 8 (value taken from LPDDR2 JEDEC specifications) 
// Therefore, the maximum round-trip read latency = trddata_en + tphy_rdlat + 2 cycles (pi_rt_rd_vld -> dfi_rd command + 
// DFI read data -> load_ptr) = 35.5 cycles. 
//  
// For LPDDR2,we have BL4, which is one command every 2 cycles, which mean that we need a FIFO depth greater than 18 (we 
// divide the maximum round trip latency by 2 and round up). 
//  
// Up to 16 more cycles of latency are required in case of unaligned read data (in this case the FIFO depth also needs to 
// be increased). 
//  
//  
// Example 2:DDR4 
//  
// Considering DDR4 connected to a DDR4 mPHY in DFI 1:1 mode, we have: 
//  - trddata_en = RL-4 cycles (RL means Read Latency) 
//  - tphy_rdlat = 42 cycles (maximum value according to PUB databook) 
//  - RL = 40 (value taken from DDR4 JEDEC specifications for DDR4-2400) 
// Therefore, the maximum round-trip read latency = trddata_en + tphy_rdlat + 2 cycles (pi_rt_rd_vld -> dfi_rd command + 
// DFI read data -> load_ptr) + 3 cycles (RDIMM/LRDIMM delay) = 83 cycles 
//  
// For DDR4,we have BL8, which is one command every 4 cycles, which mean that we need a FIFO depth greater than 21 (we 
// divide the maximum round trip latency by 4 and round up). 
//  
// Up to 16 more cycles of latency are required in case of unaligned read data (in this case the FIFO depth also needs to 
// be increased). 
//  
//  Up to MEMC_FREQ_RATIO*UMCTL2_RETRY_ADD_RD_LAT more cycles of latency are required if UMCTL2_RETRY_ADD_RD_LAT>0 (in 
//  this case the FIFO depth also needs to be increased). 
//  
// Note: the above calculation example is for Synopsys PHYs. If any other PHY type is used, please check the corresponding 
// databook.
`define MEMC_RT_FIFO_DEPTH 32


// Name:         DWC_NO_CDC_INIT
// Default:      1
// Values:       0, 1
// 
// Spcifies that synchronous reset input for bcms related to CDC  is not required.
`define DWC_NO_CDC_INIT


// `define DDRCTL_WDATARAM_RD_LATENCY_2_OR_DDRCTL_RETRY_WDATARAM_WR_LATENCY_1


// `define DDRCTL_WDATARAM_RD_LATENCY_2_AND_DDRCTL_RETRY_WDATARAM_WR_LATENCY_1


// `define MEMC_FREQ_RATIO_4_AND_MEMC_OPT_WDATARAM


// `define DDRCTL_WR_CRC_RETRY_OR_UMCTL2_DUAL_HIF_AND_DDRCTL_RD_CRC_RETRY


// `define DDRCTL_RD_CRC_RETRY_OR_UMCTL2_DUAL_HIF_AND_DDRCTL_WR_CRC_RETRY


// `define DDRCTL_WR_CRC_RETRY_AND_MEMC_DDR5_AND_MEMC_OPT_WDATARAM


// `define MEMC_INLINE_ECC_OR_DDRCTL_RD_CRC_RETRY


// `define UMCTL2_DUAL_HIF_1_OR_DDRCTL_RD_CRC_RETRY


// `define MEMC_DDR5_OR_DDRCTL_RD_CRC_RETRY


// `define MEMC_DDR5_1_TO_4_OR_MEMC_SIDEBAND_ECC


// Name:         DDRCTL_CAPAR_CMDFIFO_DEPTH
// Default:      128
// Values:       32 64 128 256
// Enabled:      0
// 
// This parameter specifies the depth of Command FIFO for CA parity retry (number of entries).
`define DDRCTL_CAPAR_CMDFIFO_DEPTH 128


`define DDRCTL_CAPAR_CMDFIFO_ADDR_BITS 7


// Name:         DDRCTL_CHB_CBUSY_EN
// Default:      0 (DDRCTL_CHB_CHIE_EN || DDRCTL_CHB_CHID_EN || DDRCTL_CHB_MPAM_EN) 
//               && (DDRCTL_INCL_CHB==1)
// Values:       0, 1
// Enabled:      DDRCTL_INCL_CHB == 1
// 
// DDRCTL_CHB_CBUSY_EN 
// When true, The Cbusy field is enable.
// `define DDRCTL_CHB_CBUSY_EN


// Name:         DDRCTL_RSD_PIPELINE
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_ECC_SUPPORT==2) || (MEMC_ECC_SUPPORT==3))
// 
// Instantiates logic to break the timing for ADVECC RSD decoder by adding 1 pipeline stage. 
//  
// When enabled, it introduced one more level of pipeline register for the decoded read data, thereby, increasing the read 
// latency by 1 more clock cycle
// `define DDRCTL_RSD_PIPELINE


`define DDRCTL_RSD_PIPELINE_EN 0


// `define DDRCTL_RSD_PIPELINE_EN_1


// Name:         DDRCTL_RSD_PIPE_OPTION
// Default:      0
// Values:       0, 1
// Enabled:      DDRCTL_RSD_PIPELINE == 1
// 
// When 0, pipeline stage is inserted after EPS 
// When 1, pipeline stage is inserted after ELP
// `define DDRCTL_RSD_PIPE_OPTION


`define DDRCTL_RSD_PIPE_AT_ELP 0


// Name:         DDRCTL_ENH_ECC_REPORT_EN
// Default:      0
// Values:       0, 1
// Enabled:      (MEMC_ECC_SUPPORT>0)&&(MEMC_SIDEBAND_ECC_EN==1)&&(DDRCTL_DDR==1)
// 
// This parameter will enable the following: 
//  - Per rank CE counters 
//  - Programmable CE threshold 
//  - Threshold based CE interrupt  
//  - Leaky bucket algorithm for CE counters.
// `define DDRCTL_ENH_ECC_REPORT_EN


`define DDRCTL_ENH_ECC_REPORT_EN_1 0


`define DDRCTL_1BIT_REG_FIELD_SIZE 1


// Name:         DDRCTL_EAPAR_EN
// Default:      0
// Values:       0, 1
// Enabled:      ((MEMC_ECC_SUPPORT>0) && (MEMC_SIDEBAND_ECC_EN==1) && 
//               (DDRCTL_KBD_SBECC_EN==0) && (MEMC_DDR5==1))
// 
// Enables the controller to protect DDR5 address using encoded address parity within sideband ECC
`define DDRCTL_EAPAR_EN 0


// Name:         DDRCTL_EAPAR_SIZE
// Default:      1-bit address parity ((DDRCTL_EAPAR_EN==1)? 2 : 1)
// Values:       1-bit address parity (1), 2-bit address parity (2)
// Enabled:      0
// 
// Address Parity Size to be encoded within the sideband ECC 
//   1- 1-bit address parity 
//   2- 2-bit address parity
`define DDRCTL_EAPAR_SIZE 1


// `define DDRCTL_EAPAR_EN_1


// `define DDRCTL_EAPAR_SIZE_2


`define DDRCTL_CHB_SRC_WIDTH 1


`define DDRCTL_CHB_SBR_PORTP1 2


`define DDRCTL_SRC_WIDTH 1


`define MEMC_ECC_SYNDROME_WIDTH 40


// Name:         DDRCTL_P80001562_91319
// Default:      0
// Values:       0 1
// Enabled:      MEMC_ENH_RDWR_SWITCH==1
// 
// This parameter enables additional mode to control run_length feature for WR. Additional mode has run_length counter is 
// counted down whenever WR is scheduled regardless of WR CAM threshold. There is chicken bit register to switch mode when 
// this parameter is set to 1. This is effective only LPDDR5/4 and DDR4.
// `define DDRCTL_P80001562_91319


// Name:         DDRCTL_DDR4_PPR
// Default:      0
// Values:       0, 1
// Enabled:      MEMC_DDR4==1
// 
// Enable DDR4 Post Package Repair (PPR) feature
// `define DDRCTL_DDR4_PPR


`define MEMC_LPDDR4_OR_DDRCTL_DDR4_PPR


// Name:         DDRCTL_XPI_USE_RMWR
// Default:      1 (((UMCTL2_PA_OPT_TYPE==1) && (UMCTL2_INT_NPORTS<3)) ? 0 : 1)
// Values:       0, 1
// Enabled:      DDRCTL_SYS_INTF==1
// 
// This parameter is used to enable/disable the bypass path for command and data in XPI RMW module. 
//  
//  1: The bypass path in XPI RMW is disabled. XPI RMW module introduces 1 cycle additional latency for write commands and 
//  data. 
//  
//  0: The Bypass path is included in XPI RMW parallel to the Store and Forward logic. Bypass path will be active if ECC 
//  is disabled, Data Mask (DM) is enabled and Programmable SnF is disabled. 
// The bypass path is active/inactive depending on the register configuration.
`define DDRCTL_XPI_USE_RMWR


`define DDRCTL_XPI_USE_RMWR_EN 1

`endif // __GUARD__DWC_DDRCTL_CC_CONSTANTS__SVH__
