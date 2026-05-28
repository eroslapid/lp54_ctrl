//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/DWC_ddrctl_ram_cc_constants.svh#1 $
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

`ifndef __GUARD__DWC_DDRCTL_RAM_CC_CONSTANTS__SVH__
`define __GUARD__DWC_DDRCTL_RAM_CC_CONSTANTS__SVH__


//======================================================================================================
//
//Add some parameter to ddrctl_cc_constants.svh 
////======================================================================================================

//****
//in wdataRAM
//****


// Name:         MEMC_WDATARAM0_EXISTS
// Default:      1 (UMCTL2_WDATA_EXTRAM)
// Values:       0, 1
// 
// wdataRAM0
`define MEMC_WDATARAM0_EXISTS 1




// Name:         MEMC_WDATARAM1_EXISTS
// Default:      0 (UMCTL2_WDATA_EXTRAM && UMCTL2_DUAL_CHANNEL)
// Values:       0, 1
// 
// wdataRAM1
`define MEMC_WDATARAM1_EXISTS 0


`define MEMC_WDATARAM_PAR_WIDTH 32


`define MEMC_WDATARAM_PAR_WIDTH_EXT 32


`define MEMC_WDATARAM_OCECC 0


`define MEMC_WDATARAM_OCSAP 0


`define MEMC_WDATARAM_DEPTH 64



`define MEMC_WDATARAM_KBD_SBECC_EN 0


`define MEMC_WDATARAM_NUM_BITS_PER_KBD 0



//********
//retry_wdata_RAM
//********



// Name:         MEMC_RETRY_WDATARAM0_EXISTS
// Default:      0 (DDRCTL_RETRY_WDATA_EXTRAM)
// Values:       0, 1
// 
// retry_wdata_RAM0
`define MEMC_RETRY_WDATARAM0_EXISTS 0



// Name:         MEMC_RETRY_WDATARAM1_EXISTS
// Default:      0 (DDRCTL_RETRY_WDATA_EXTRAM && DDRCTL_DDR_DUAL_CHANNEL)
// Values:       0, 1
// 
// retry_wdata_RAM1
`define MEMC_RETRY_WDATARAM1_EXISTS 0



`define MEMC_RETRY_WDATARAM_USE_PAR 0


`define MEMC_RETRY_WDATARAM_PAR_WIDTH 32


`define MEMC_RETRY_WDATARAM_PAR_WIDTH_EXT 32

//****
//in ddrctl_chb_wrb_sram_00/01/10/11
//****



// Name:         MEMC_DDRCTL_CHB_WRB_RAM00_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_WRB_EXTRAM)
// Values:       0, 1
// 
// ddrctl_chb_wrb_sram_00
`define MEMC_DDRCTL_CHB_WRB_RAM00_EXISTS 0



// Name:         MEMC_DDRCTL_CHB_WRB_RAM01_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_WRB_EXTRAM && 
//               UMCTL2_DUAL_DATA_CHANNEL)
// Values:       0, 1
// 
// ddrctl_chb_wrb_sram_01
`define MEMC_DDRCTL_CHB_WRB_RAM01_EXISTS 0




// Name:         MEMC_DDRCTL_CHB_WRB_RAM10_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_WRB_EXTRAM && 
//               DDRCTL_CHB_NUM_WRB_RAM_2)
// Values:       0, 1
// 
// ddrctl_chb_wrb_sram_10
`define MEMC_DDRCTL_CHB_WRB_RAM10_EXISTS 0




// Name:         MEMC_DDRCTL_CHB_WRB_RAM11_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_WRB_EXTRAM && 
//               UMCTL2_DUAL_DATA_CHANNEL && DDRCTL_CHB_NUM_WRB_RAM_2)
// Values:       0, 1
// 
// ddrctl_chb_wrb_sram_11
`define MEMC_DDRCTL_CHB_WRB_RAM11_EXISTS 0



`define MEMC_DDRCTL_CHB_WRB_RAM_WIDTH 288



`define MEMC_DDRCTL_CHB_WRB_RAM_PAR_WIDTH 0



//****
//in ddrctl_chb_rdb_sram_0/1
//****



// Name:         MEMC_DDRCTL_CHB_RDB_RAM0_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_RDB_EXTRAM)
// Values:       0, 1
// 
// ddrctl_chb_rdb_sram_0
`define MEMC_DDRCTL_CHB_RDB_RAM0_EXISTS 0





// Name:         MEMC_DDRCTL_CHB_RDB_RAM1_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_RDB_EXTRAM && 
//               UMCTL2_DUAL_DATA_CHANNEL)
// Values:       0, 1
// 
// ddrctl_chb_rdb_sram_1
`define MEMC_DDRCTL_CHB_RDB_RAM1_EXISTS 0



`define MEMC_DDRCTL_CHB_RDB_PROT_BITS 0




`define MEMC_DDRCTL_CHB_RDB_PROT_POIS_BITS 8


`define MEMC_DDRCTL_CHB_RDB_RAM_WIDTH 264



`define MEMC_DDRCTL_CHB_RDB_PROT_POIS_BEW 1



`define MEMC_DDRCTL_CHB_RDB_POIS_DATA_BEW 32



`define MEMC_DDRCTL_CHB_RDB_RAM_PAR_WIDTH 0



//****
//in ddrctl_chb_rtlst_sram_0/1
//****



// Name:         MEMC_DDRCTL_CHB_RTLST_RAM0_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_RTLST_EXTRAM)
// Values:       0, 1
// 
// ddrctl_chb_rtlst_sram_0
`define MEMC_DDRCTL_CHB_RTLST_RAM0_EXISTS 0




// Name:         MEMC_DDRCTL_CHB_RTLST_RAM1_EXISTS
// Default:      0 (DDRCTL_INCL_CHB && DDRCTL_CHB_RTLST_EXTRAM && UMCTL2_A_NPORTS_1)
// Values:       0, 1
// 
// ddrctl_chb_rtlst_sram_1
`define MEMC_DDRCTL_CHB_RTLST_RAM1_EXISTS 0


`define MEMC_DDRCTL_CHB_RTMEMW 19


`define MEMC_DDRCTL_CHB_RTLST_RAM_WIDTH 24



//****
//in rdataRAM/1
//****


`define MEMC_RDATARAM_RAM_ENABLE 0


// Name:         MEMC_RDATARAM_RAM_0_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_0)
// Values:       0, 1
// 
// rdataRAM_0
`define MEMC_RDATARAM_RAM_0_EXISTS 0



// Name:         MEMC_RDATARAM_RAM_1_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_1)
// Values:       0, 1
// 
// rdataRAM_1
`define MEMC_RDATARAM_RAM_1_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_2_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_2)
// Values:       0, 1
// 
// rdataRAM_2
`define MEMC_RDATARAM_RAM_2_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_3_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_3)
// Values:       0, 1
// 
// rdataRAM_3
`define MEMC_RDATARAM_RAM_3_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_4_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_4)
// Values:       0, 1
// 
// rdataRAM_4
`define MEMC_RDATARAM_RAM_4_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_5_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_5)
// Values:       0, 1
// 
// rdataRAM_5
`define MEMC_RDATARAM_RAM_5_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_6_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_6)
// Values:       0, 1
// 
// rdataRAM_6
`define MEMC_RDATARAM_RAM_6_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_7_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_7)
// Values:       0, 1
// 
// rdataRAM_7
`define MEMC_RDATARAM_RAM_7_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_8_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_8)
// Values:       0, 1
// 
// rdataRAM_8
`define MEMC_RDATARAM_RAM_8_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_9_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_9)
// Values:       0, 1
// 
// rdataRAM_9
`define MEMC_RDATARAM_RAM_9_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_10_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_10)
// Values:       0, 1
// 
// rdataRAM_10
`define MEMC_RDATARAM_RAM_10_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_11_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_11)
// Values:       0, 1
// 
// rdataRAM_11
`define MEMC_RDATARAM_RAM_11_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_12_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_12)
// Values:       0, 1
// 
// rdataRAM_12
`define MEMC_RDATARAM_RAM_12_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_13_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_13)
// Values:       0, 1
// 
// rdataRAM_13
`define MEMC_RDATARAM_RAM_13_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_14_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_14)
// Values:       0, 1
// 
// rdataRAM_14
`define MEMC_RDATARAM_RAM_14_EXISTS 0


// Name:         MEMC_RDATARAM_RAM_15_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_15)
// Values:       0, 1
// 
// rdataRAM_15
`define MEMC_RDATARAM_RAM_15_EXISTS 0



// Name:         MEMC_RDATARAM_RAM1_0_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_0 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_0
`define MEMC_RDATARAM_RAM1_0_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_1_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_1 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_1
`define MEMC_RDATARAM_RAM1_1_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_2_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_2 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_2
`define MEMC_RDATARAM_RAM1_2_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_3_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_3 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_3
`define MEMC_RDATARAM_RAM1_3_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_4_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_4 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_4
`define MEMC_RDATARAM_RAM1_4_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_5_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_5 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_5
`define MEMC_RDATARAM_RAM1_5_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_6_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_6 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_6
`define MEMC_RDATARAM_RAM1_6_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_7_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_7 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_7
`define MEMC_RDATARAM_RAM1_7_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_8_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_8 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_8
`define MEMC_RDATARAM_RAM1_8_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_9_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_9 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_9
`define MEMC_RDATARAM_RAM1_9_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_10_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_10 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_10
`define MEMC_RDATARAM_RAM1_10_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_11_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_11 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_11
`define MEMC_RDATARAM_RAM1_11_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_12_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_12 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_12
`define MEMC_RDATARAM_RAM1_12_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_13_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_13 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_13
`define MEMC_RDATARAM_RAM1_13_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_14_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_14 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_14
`define MEMC_RDATARAM_RAM1_14_EXISTS 0


// Name:         MEMC_RDATARAM_RAM1_15_EXISTS
// Default:      0 (UMCTL2_RRB_EXTRAM_15 && UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1)
// Values:       0, 1
// 
// rdataRAM1_15
`define MEMC_RDATARAM_RAM1_15_EXISTS 0




`define MEMC_RDATARAM_OCECC 1


`define MEMC_RDATARAM_DEPTH 64

`endif // __GUARD__DWC_DDRCTL_RAM_CC_CONSTANTS__SVH__
