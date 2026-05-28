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

// -------------------------------------------------------------------------
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/arb_top/DWC_ddr_arb_top.sv#4 $
// -------------------------------------------------------------------------
// Description:
//        Arb_top top file. Conatins all AXI arbitration related modules.
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_arb_top
import DWC_ddrctl_reg_pkg::*;
 #( 
//-----------------------------------------------------
//       xpi PORT PARAMETERS
//-----------------------------------------------------       
    parameter M_DW                              = 16,                      // MEMORY data width
    parameter M_DW_INT                          = 16,                      // M_DW*2, MEMORY data width, double if dual channel
    parameter A_DW                              = 32,                      // Application data width
    parameter A_STRBW                           = 4,                       // Application strobe width
    parameter A_PARW                            = 4,                       // Parity width                    New!!!
    parameter M_ADDRW                           = 32,                      // MEMORY address width
    parameter NAB                               = 1,
    parameter M_BLW                             = 4,                       // Memory burst length width (3->BL8;4->BL16)
    parameter M_ECC                             = 0,
    parameter M_SIDEBAND_ECC                    = 0,
    parameter M_INLINE_ECC                      = 0,
    parameter NBEATS                            = 4,
    parameter M_LPDDR3                          = 0,
    parameter M_DDR5                            = 0,
    parameter M_USE_RMW                         = 1,
    parameter AXI_ADDRW                         = 34,                      // AXI address width
    parameter AXI_IDW                           = 8,                       // AXI ID width
    parameter AXI_LENW                          = 4,                       // AXI a*len width
    parameter AXI_SIZEW                         = 3,                       // AXI a*size width
    parameter AXI_BURSTW                        = 2,                       // AXI a*burst width
    parameter AXI_LOCKW_FIX                     = 2,                       // AXI lock width fixed internally
    parameter AXI_USERW                         = 1,
    parameter AXI_CACHEW                        = 4,                       // AXI a*cache width
    parameter AXI_PROTW                         = 3,                       // AXI a*prot width
    parameter AXI_QOSW                          = 4,                       // AXI a*qos width
    parameter AXI_RESPW                         = 2,                       // AXI *resp width
    parameter XPI_RMW_WDQD                      = 8,
    parameter XPI_SQD                           = 34,
    parameter LOWPWR_NOPX_CNT                   = 0,
    parameter OUTS_WRW                          = 10,
    parameter OUTS_RDW                          = 12,   
    parameter MEMC_NO_OF_ENTRY                  = 32,
    parameter MEMC_BURST_LENGTH                 = 8,
    parameter MEMC_WDATA_PTR_BITS               = 8,
    parameter USE_WAR                           = 0,
    parameter USE_RAR                           = 0,
    parameter USE_RDR                           = 0,
    parameter USE_RPR                           = 0,   
    parameter USE_INPUT_RAR                     = 0,
    parameter RMW_WARD                          = 2,
    parameter RARD                              = 2,
    parameter WARD                              = 2,
    parameter BRW                               = 4,   //no coonected from up layer and tied internally !!! 
    parameter DBW                               = 2,   //no coonected from up layer and tied internally !!! 
    parameter AMCOLW_L                          = 4,
    parameter AMCOLW_H                          = 5,
    parameter AMCOLW_C3                         = 5,
    parameter AMDCHW                            = 6,
    parameter AMCSW                             = 6,
    parameter AMCIDW                            = 6,
    parameter AMBANKW                           = 6,
    parameter AMBGW                             = 6,
    parameter AMROWW                            = 5,
    parameter DDRCTL_LUT_ADDRMAP_EN             = 0,     
    parameter UMCTL2_HET_RANK_EN                = 0,
    parameter OCPAR_EN                          = 0,
    parameter OCPAR_SLICE_WIDTH                 = 8,
    parameter OCPAR_NUM_BYTES                   = 4,
    parameter OCPAR_NUM_BYTES_LG2               = 2,
    parameter OCPAR_ADDR_PAR_WIDTH              = 1,
    parameter DUAL_CHANNEL                      = 0,
    parameter DATA_CHANNEL_INTERLEAVE           = 0,
    parameter DDRCTL_HET_INTERLEAVE             = 0,
    parameter ECC_RM_WIDTH                      = 1,
    parameter ECC_RMG_WIDTH                     = 1,
    parameter ECC_H3_WIDTH                      = 6,
    parameter OCCAP_EN                          = 0,
    parameter OCCAP_PIPELINE_EN                 = 0,

    //newly added ocecc parameters
    parameter OCECC_EN                          = 0,
    parameter OCECC_XPI_WR_IN_GRANU             = 0, 
    parameter OCECC_XPI_RD_GRANU                = 0, 
    parameter OCECC_MR_RD_GRANU                 = 0, 
    parameter OCECC_MR_BNUM_WIDTH               = 0,
    
    parameter PA_OPT_TYPE                       = 1,
    parameter A_NPORTS_LG2                      = 1,
    parameter WDATA_PTR_QD                      = 32,
    parameter RQOS_MLW                          = 4,
    parameter RQOS_RW                           = 2,
    parameter RQOS_TW                           = 1,
    parameter WQOS_MLW                          = 4,
    parameter WQOS_RW                           = 2,
    parameter WQOS_TW                           = 1,
    parameter EXA_ACC_SUPPORT                   = 0,                       // Exclusive access Support.
    parameter EXA_MAX_LENW                      = 9,                       // Worst Case Dowsnsizing is 256/8 with a AXI_LENW of 6
    parameter EXA_MAX_SIZEW                     = 3,                       // Maximum AXI Size is 3 bits
    parameter EXA_MAX_ADDRW                     = 34,                      // 12 bits for 4K Boundary
    parameter EXA_PYLD_W                        = 1,
    parameter ID_MAPW                           = 8,
    parameter CMD_LEN_BITS                      = 1,
    parameter BEAT_INFOW                        = 6,
    parameter AXI_SAR_BW                        = 1,
    parameter AXI_SAR_SW                        = 1,
    parameter USE_SAR                           = 0,
    parameter NSAR                              = 0,
    parameter SAR_MIN_ADDRW                     = 28,
    parameter RDATARAM_DW                       = 33,
    parameter RDATARAM_AW                       = 7,
    parameter RDATARAM_DEPTH                    = 128,
    parameter DATARAM_PAR_DW                    = 4,
    parameter AXI_ADDR_BOUNDARY                 = 12,                      // Defines AXI address no crossing boundary ( default is 4k)
    parameter UMCTL2_PARTIAL_WR_EN              = 1,                       // PARTIAL_WR supported
    parameter MEMC_DDR4_EN                      = 1,
    parameter BCM_VERIF_EN                      = 1,
    parameter HWFFC_EN                          = 0,
    parameter IH_TE_PIPELINE                    = 0,

    parameter  ARB_ID_NB                        = 20,
    parameter  ARB_ID_PRA_TABLE                 ='d0, 
    parameter  ARB_TOTAL_ID                     ='d0,   
    parameter  ARB_ID_BUS_TABLE                 ='d0,
    
    // unique parameters for every xpi port
    parameter A_PORT_NUM_TABLE                      = {4'd3, 4'd1, 4'd0},   
    parameter MAX_A_PORT_NUM_NB                     = 4, 
    parameter A_DW_INT_TABLE                        = {11'd32, 11'd32},         // Application data width (internal to XPI)
    parameter MAX_A_DW_INT_NB                       = 11,                       // Application data width (internal to XPI)
    parameter A_STRBW_INT_TABLE                     = {8'd4, 8'd4},             // Application strobe width (internal to XPI)
    parameter MAX_A_STRBW_INT_NB                    = 8,                        // Application strobe width (internal to XPI)
    parameter A_PARW_INT_TABLE                      = {8'd4, 8'd4},             // Application strobe width (internal to XPI)
    parameter MAX_A_PARW_INT_NB                     = 8,                        // Application strobe width (internal to XPI)
  
    parameter  AXI_DW_NB                            = 'd0,
    parameter  AXI_DATAW_PRA_TABLE                  = 'd0,
    parameter  AXI_TOTAL_DW                         = 'd0,
    parameter  AXI_DATAW_BUS_TABLE                  = 'd0,

    parameter  AXI_STRBW_NB                         = 'd0,
    parameter  AXI_STRBW_PRA_TABLE                  = 'd0,
    parameter  AXI_TOTAL_STRBW                      = 'd0,
    parameter  AXI_STRBW_BUS_TABLE                  = 'd0,

    parameter  AXI_LOCKW_NB                         = 'd0,
    parameter  AXI_LOCKW_PRA_TABLE                  = 'd0,
    parameter  AXI_TOTAL_LOCKW                      = 'd0,
    parameter  AXI_LOCKW_BUS_TABLE                  = 'd0,
    
    
    parameter AXI_WAQD_TABLE                        = {4'd2, 4'd2},
    parameter MAX_AXI_WAQD_NB                       = 4,

    parameter AXI_WAQD_LG2_NB                       = 'd0,     
    parameter AXI_WAQD_LG2_PRA_TABLE                = 'd0,
    parameter AXI_TOTAL_WAQD_LG2                    = 'd0,
    parameter AXI_WAQD_LG2_BUS_TABLE                = 'd0,
    
    parameter AXI_WDQD_TABLE                        = {7'd10, 7'd10},
    parameter MAX_AXI_WDQD_NB                       = 7,
    parameter AXI_RAQD_TABLE                        = {4'd2, 4'd2},
    parameter MAX_AXI_RAQD_NB                       = 4,

    parameter AXI_RAQD_LG2_NB                       = 'd0,     
    parameter AXI_RAQD_LG2_PRA_TABLE                = 'd0,
    parameter AXI_TOTAL_RAQD_LG2                    = 'd0,
    parameter AXI_RAQD_LG2_BUS_TABLE                = 'd0,
    
    parameter AXI_RDQD_TABLE                        = {7'd10, 7'd10},
    parameter MAX_AXI_RDQD_NB                       = 7,
    parameter AXI_WRQD_TABLE                        = {7'd10, 7'd10},
    parameter MAX_AXI_WRQD_NB                       = 7,
    parameter AXI_SYNC_TABLE                        = {1'd1, 1'd0},
    parameter MAX_AXI_SYNC_NB                       = 1,
    parameter RINFOW_TABLE                          = {7'd9, 7'd9},
    parameter MAX_RINFOW_NB                         = 7,
    parameter RINFOW_NSA_TABLE                      = {7'd9, 7'd9},
    parameter MAX_RINFOW_NSA_NB                     = 7,
    parameter WINFOW_TABLE                          = {7'd15, 7'd15},
    parameter MAX_WINFOW_NB                         = 7,
    parameter RPINFOW_TABLE                         = {7'd9, 7'd9},
    parameter MAX_RPINFOW_NB                        = 7,
  
    parameter AXI_TAGBITS_NB                        = 'd0,                   // for internal signals!!!
    parameter AXI_TAGBITS_PRA_TABLE                 = 'd0,
    parameter AXI_TAGBITS_TOTAL_ID                  = 'd0,
    parameter AXI_TAGBITS_BUS_TABLE                 = 'd0,
  
    parameter ASYNC_FIFO_N_SYNC_TABLE               = {3'd2, 3'd2},          // Number of synchronizers for async FIFOs
    parameter MAX_ASYNC_FIFO_N_SYNC_NB              = 3,                     // Number of synchronizers for async FIFOs
    parameter ASYNC_FIFO_EARLY_PUSH_STAT_TABLE      = {2'd0, 2'd0},
    parameter MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB     = 2,
    parameter ASYNC_FIFO_EARLY_POP_STAT_TABLE       = {2'd0, 2'd0},          // Only applies to read data queue and write response queue
    parameter MAX_ASYNC_FIFO_EARLY_POP_STAT_NB      = 2,                     // Only applies to read data queue and write response queue
    parameter AP_ASYNC_TABLE                        = {3'd1, 3'd1},
    parameter MAX_AP_ASYNC_NB                       = 3,
    parameter DATA_CHANNEL_INTERLEAVE_NS_TABLE      = {2'd0, 2'd0},
    parameter MAX_DATA_CHANNEL_INTERLEAVE_NS_NB     = 2,
    parameter VPR_EN_TABLE                          = {2'd0, 2'd0},
    parameter MAX_VPR_EN_NB                         = 2,
    parameter VPW_EN_TABLE                          = {2'd0, 2'd0},
    parameter MAX_VPW_EN_NB                         = 2,
    parameter USE2RAQ_TABLE                         = {2'd0, 2'd0},
    parameter MAX_USE2RAQ_NB                        = 2,
    parameter NUM_VIR_CH_TABLE                      = {3'd1, 3'd1},
    parameter MAX_NUM_VIR_CH_NB                     = 3,
    parameter STATIC_VIR_CH_TABLE                   = {2'd0, 2'd0},
    parameter MAX_STATIC_VIR_CH_NB                  = 2,
    parameter RRB_EXTRAM_TABLE                      = {2'd0, 2'd0},
    parameter MAX_RRB_EXTRAM_NB                     = 2,
    parameter XPI_SMALL_SIZED_PORT_TABLE            = {2'd0, 2'd0},
    parameter MAX_SMALL_SIZED_PORT_NB               = 1,
    parameter RRB_EXTRAM_REG_TABLE                  = {2'd1, 2'd1}, 
    parameter RRB_EXTRAM_RETIME_TABLE               = {2'd1, 2'd1}, 
    parameter MAX_RRB_EXTRAM_REG_NB                 = 2, 
    parameter MAX_RRB_EXTRAM_RETIME_NB                 = 2, 
    parameter RDWR_ORDERED_TABLE                    = {2'd0, 2'd0},          // Instantiate read/write pre/post-arbiters
    parameter MAX_RDWR_ORDERED_NB                   = 2,                     // Instantiate read/write pre/post-arbiters
    parameter RRB_THRESHOLD_EN_TABLE                    = {2'd0, 2'd0},
    parameter RRB_THRESHOLD_PPL_TABLE                   = {2'd0, 2'd0},
    parameter MAX_RRB_THRESHOLD_EN_NB                   = 1,
    parameter RRB_LOCK_THRESHOLD_WIDTH               = 0,
    parameter READ_DATA_INTERLEAVE_EN_TABLE         = 16,                    // Enables read data interleaving
    parameter MAX_READ_DATA_INTERLEAVE_EN_NB        = 1,                     // Enables read data interleaving

//-----------------------------------------------------
//          a2x_core PORT PARAMETERS
//-----------------------------------------------------

//********** internal tie these A2X parameters **********************
    parameter  A2X_LOWPWR_IF                    = 0,
    parameter  A2X_LOWPWR_NOPX_CNT              = 2,
    parameter  A2X_LOWPWR_RST_CNT               = 2,
    parameter  A2X_HCBUF_MODE                   = 1, 
    parameter  A2X_HCSNF_WLEN                   = 1, 
    parameter  A2X_HCSNF_RLEN                   = 1, 
    parameter  A2X_WBUF_MODE                    = 0, 
    parameter  A2X_RBUF_MODE                    = 0, 
    parameter  A2X_SNF_AWLEN_DFLT               = 4, 
    parameter  A2X_SNF_ARLEN_DFLT               = 4, 
    parameter  A2X_HINCR_WBCNT_MAX              = 3,      //8
    parameter  A2X_HINCR_RBCNT_MAX              = 3,      //8
    parameter  A2X_HINCR_HCBCNT                 = 1, 
    parameter  A2X_SINGLE_RBCNT                 = 0,
    parameter  A2X_SINGLE_WBCNT                 = 0,
    parameter  A2X_PP_MODE                      = 0,      // 0 = AHB 1 = AXI
    parameter  A2X_UPSIZE                       = 0,      // 0 = Not Upsized 1 = Upsized
    parameter  A2X_DOWNSIZE                     = 0,      // 0 = Not Downsized 1 Downsized
    parameter  A2X_LOCKED                       = 0,      // A2X Supports Locked Transactions
    parameter  A2X_AHB_WBF_SPLIT                = 1,
    parameter  A2X_RS_RATIO                     = 0, 
    parameter  A2X_RS_RATIO_LOG2                = 0,
    parameter  A2X_BRESP_ORDER                  = 0,
    parameter  A2X_READ_ORDER                   = 0, 
    parameter  A2X_READ_INTLEV                  = 0, 
    parameter  A2X_PP_OSAW_LIMIT                = 3,
    parameter  A2X_PP_OSAW_LIMIT_LOG2           = 2,
    parameter  A2X_B_OSW_LIMIT                  = 3,
    parameter  A2X_B_OSW_LIMIT_LOG2             = 2,
    parameter  A2X_SP_OSAW_LIMIT                = 3,
    parameter  A2X_SP_OSAW_LIMIT_LOG2           = 2,
    parameter  A2X_OSR_LIMIT                    = 3,
    parameter  A2X_OSR_LIMIT_LOG2               = 2,

    //from original `define  
    parameter A2X_IDW                           = 4,
    parameter A2X_HBLW                          = 3,
    parameter A2X_BSW                           = 3,
    parameter A2X_HPTW                          = 4,
    parameter A2X_HRESPW                        = 2,
    parameter A2X_INT_AWSBW                     = 0,
 //*************************************************************/
    parameter  BOUNDARY_W                       = 12,
    parameter  A2X_AW                           = 32,  // Address Width
    parameter  A2X_SP_AW                        = 32,  // Address Width
    parameter  A2X_BLW                          = 4,   // Burst Length Width
    parameter  A2X_SP_BLW                       = 4,   // Burst Length Width
//************* internal tie these A2X parameters *************  
    parameter  A2X_HASBW                        = 1,   // Address Sideband Width
    parameter  A2X_AWSBW                        = 1,   // Address Sideband Width
    parameter  A2X_ARSBW                        = 1,   // Address sideband width
    parameter  A2X_WSBW                         = 1,  
    parameter  A2X_RSBW                         = 1,  
    parameter  A2X_BSBW                         = 1,  
    parameter  A2X_CLK_MODE                     = 0,
    parameter  A2X_PP_SYNC_DEPTH                = 2,
    parameter  A2X_SP_SYNC_DEPTH                = 2,
// *************************************************************/
    parameter  A2X_AW_FIFO_DEPTH                = 2,
    parameter  A2X_AW_FIFO_DEPTH_LOG2           = 1,
    parameter  A2X_AR_FIFO_DEPTH                = 2,
    parameter  A2X_AR_FIFO_DEPTH_LOG2           = 1,
    parameter  A2X_WD_FIFO_DEPTH                = 2,
    parameter  A2X_WD_FIFO_DEPTH_LOG2           = 1,
    parameter  A2X_RD_FIFO_DEPTH                = 2,
    parameter  A2X_RD_FIFO_DEPTH_LOG2           = 1,
    parameter  A2X_LK_RD_FIFO_DEPTH             = 2,
    parameter  A2X_LK_RD_FIFO_DEPTH_LOG2        = 1,
    parameter  A2X_BRESP_FIFO_DEPTH             = 2,
    parameter  A2X_BRESP_FIFO_DEPTH_LOG2        = 1,
    
//************* internal tie these A2X parameters **************
  // AHB/AXI Endian Convert
    parameter  A2X_SP_ENDIAN                    = 0, 
  // Register Slice Parameters
  // 0 - pass through mode
  // 1 - forward timing mode
  // 2 - full timing mode
  // 3 - backward timing mode
    parameter A2X_RS_AW_TMO                     = 0,
    parameter A2X_RS_AR_TMO                     = 0,
    parameter A2X_RS_W_TMO                      = 0,
    parameter A2X_RS_B_TMO                      = 0,
    parameter A2X_RS_R_TMO                      = 0,
 //*************************************************************/
   
    // unique parameter for every a2x_core port
    parameter  A2X_NUM_AHBM_TABLE                   = {4'd8,4'd8},   
    parameter  MAX_A2X_NUM_AHBM_NB                  = 4,   
    parameter  A2X_BRESP_MODE_TABLE                 = {2'd1,2'd1},   
    parameter  MAX_A2X_BRESP_MODE_NB                = 1,   
    parameter  A2X_AHB_LITE_MODE_TABLE              = {1'd0,1'd0,1'd0},   
    parameter  MAX_A2X_AHB_LITE_MODE_NB             = 1,   
    parameter  A2X_SPLIT_MODE_TABLE                 = {2'd1, 2'd1},
    parameter  MAX_A2X_SPLIT_MODE_NB                = 2,
    parameter  A2X_HREADY_LOW_PERIOD_TABLE          = {8'd100, 8'd100}, 
    parameter  MAX_A2X_HREADY_LOW_PERIOD_NB         = 8, 
    parameter  A2X_NUM_UWID_TABLE                   = {4'd8, 4'd8},
    parameter  MAX_A2X_NUM_UWID_NB                  = 4,
    parameter  A2X_NUM_URID_TABLE                   = {4'd8, 4'd8}, 
    parameter  MAX_A2X_NUM_URID_NB                  = 4, 

    parameter  A2X_PP_MAX_SIZE_TABLE                = {2'd2, 2'd2},
    parameter  MAX_A2X_PP_MAX_SIZE_NB               = 2,
    parameter  A2X_PP_NUM_BYTES_LOG2_TABLE          = {2'd2, 2'd2},
    parameter  MAX_A2X_PP_NUM_BYTES_LOG2_NB         = 2,
    parameter  A2X_SP_DW_TABLE                      = {11'd32, 11'd32, 11'd32},
    parameter  MAX_A2X_SP_DW_NB                     = 11,
    parameter  A2X_SP_MAX_SIZE_TABLE                = {4'd2, 4'd2},
    parameter  MAX_A2X_SP_MAX_SIZE_NB               = 4,

    parameter  A2X_SP_NUM_BYTES_LOG2_TABLE          = {4'd4, 4'd4},
    parameter  MAX_A2X_SP_NUM_BYTES_LOG2_NB         = 4,

//`ifdef UMCTL2_INCL_ARB
//-----------------------------------------------------
//          pa_dual module PARAMETERS
//----------------------------------------------------- 
    //parameter NPORTS                            = 1,  //it is the INT_NPORTS, for pa_dual
    parameter PORT_PRIORITYW                    = 1,
    parameter REG_PORT_PRIORITYW                = 1,
    parameter PAGEMATCH_EN                      = 1,
    parameter MEMC_ECC_SUPPORT                  = 0,
    parameter MEMC_INLINE_ECC                   = 0,
    parameter WDATA_PTR_BITS                    = 12,
    parameter MEMC_TAGBITS                      = 1,  //this is from `UMCTL2_TAGBITS

    parameter EXT_PORTPRIO                      = 0,

    parameter HIF_CREDIT_BITS                   = 1,
    parameter DUAL_PA                           = 0,
 
    parameter CRDT_CNT_WIDTH                    = 7, // not been mapped in up layer and using default

   
//-----------------------------------------------------
//          hif_cmd module PARAMETERS
//----------------------------------------------------- 
    parameter HIF_ADDR_WIDTH                    = 1,
    parameter WRDATA_CYCLES                     = 4,

//-----------------------------------------------------
//          hif_data module PARAMETERS
//----------------------------------------------------- 
    parameter NPORTS_DATA                       = 1,
    parameter ADDR_ERR_EN                       = 0,
    parameter DCH_INTERLEAVE                    = 0,  // same with DATA_CHANNEL_INTERLEAVE
 //-----------------------------------------------------
//      sbr module PARAMETERS
//-----------------------------------------------------
    parameter MEMC_HIF_ADDR_WIDTH_MAX           = 1,

    parameter SELFREF_TYPE_WIDTH                = 1,
    parameter SELFREF_SW_WIDTH                  = 1,
  
//-----------------------------------------------------
//      exa_top module PARAMETERS
//-----------------------------------------------------
//-----------------------------------------------------
//  pm_mask module PARAMETERS
//-----------------------------------------------------
    parameter SBR_EN                            = 0,
    parameter LPDDR3_EN                         = 0,
    parameter LPDDR4_EN                         = 0,
    parameter INLINE_ECC                        = 0,
    parameter MBL                               = 8,
//-----------------------------------------------------------------
// possible other parametes later on will be put below 
//-----------------------------------------------------------------
//`endif //  `ifdef UMCTL2_INCL_ARB
    parameter RAQ_TABLE_TABLE                   = 32,
    parameter MAX_RAQ_TABLE_TABLE_NB            = 2,
    parameter UMCTL2_MAX_AXI_TAGBITS            = 8,
    parameter RAQ_TABLE                         = 0,
    parameter MEMC_NUM_RANKS                    = 1,
    parameter A_NPORTS                          = 2,       // Includes logic to implement 1 to 16 host ports 
    parameter INT_NPORTS_DATA                   = 10,      // Internal seen number of ports, (use2req? nports*2 : nports for hif_data block  
    parameter INT_NPORTS                        = 10,      // Internal seen number of ports, (use2req? nports*2 : nports
    parameter XPI_USE_RMWR_EN                   = 1
   )
   (
    //----------------------------------------------- 
    // AXI Interface 
    //-----------------------------------------------
    // reg IF to all the xpi ports
    input                            reg_ddrc_ddr4,       // device is ddr4
    input                            reg_ddrc_ddr5,       // device is ddr5
    input                            reg_ddrc_lpddr4,     // device is lpddr4
    input                            reg_ddrc_lpddr5,     // device is lpddr5
    input                            reg_ddrc_dm_en,      // data mask enable
    input                            reg_ddrc_ecc_type,
    input [2:0]                      reg_ddrc_ecc_mode,
    input                            reg_ddrc_multi_beat_ecc,

    // System Address Regions registers
    input [AXI_SAR_BW-1:0]           reg_arb_base_addr_0,
    input [AXI_SAR_SW-1:0]           reg_arb_nblocks_0,
    input [AXI_SAR_BW-1:0]           reg_arb_base_addr_1,
    input [AXI_SAR_SW-1:0]           reg_arb_nblocks_1,  
    input [AXI_SAR_BW-1:0]           reg_arb_base_addr_2,
    input [AXI_SAR_SW-1:0]           reg_arb_nblocks_2,    
    input [AXI_SAR_BW-1:0]           reg_arb_base_addr_3,
    input [AXI_SAR_SW-1:0]           reg_arb_nblocks_3,

    // oc parity config
    input [OCPAR_NUM_BYTES_LG2-1:0]  reg_ddrc_par_poison_byte_num,
    
    //reg_ddrc_occap
    input                            reg_ddrc_occap_en,  
    input                            reg_ddrc_occap_arb_cmp_poison_seq,
    input                            reg_ddrc_occap_arb_cmp_poison_parallel,
    input                            reg_ddrc_occap_arb_cmp_poison_err_inj,
    
    // axi transaction poison config
    input                            reg_ddrc_rd_poison_slverr_en,
    input                            reg_ddrc_rd_poison_intr_en,
    input                            reg_ddrc_rd_poison_intr_clr,
    output wire [INT_NPORTS_DATA-1:0]       rd_poison_intr,           // correct from every xpi port 
    
    // parity outputs
    output wire [A_NPORTS-1:0]       par_waddr_err_pulse,             // need to have some modify in up level !!!
    output wire [A_NPORTS-1:0]       par_raddr_err_pulse,             // need to have some modify in up level !!!
    output wire [A_NPORTS-1:0]       par_rdata_err_pulse,
    output wire [A_NPORTS-1:0]       par_wdata_in_err_pulse,
    
    // occap output
    output wire [A_NPORTS-1:0]       xpi_a_parity_err,
    output wire [A_NPORTS-1:0]       xpi_parity_err,
    output wire [A_NPORTS-1:0]       xpi_aclk_cmp_err,
    output wire [A_NPORTS-1:0]       xpi_aclk_cmp_err_full,
    output wire [A_NPORTS-1:0]       xpi_aclk_cmp_err_seq,
    output wire [A_NPORTS-1:0]       xpi_cclk_cmp_err,
    output wire [A_NPORTS-1:0]       xpi_cclk_cmp_err_full,
    output wire [A_NPORTS-1:0]       xpi_cclk_cmp_err_seq,
    output wire [A_NPORTS-1:0]       xpi_aclk_cmp_poison_complete,
    output wire [A_NPORTS-1:0]       xpi_cclk_cmp_poison_complete, 
    
    // inline ecc
    input [ECC_RM_WIDTH-1:0]         reg_ddrc_ecc_region_map,               // same reg goes to every xpi port  
    input [ECC_RMG_WIDTH-1:0]        reg_ddrc_ecc_region_map_granu,         // same reg goes to every xpi port
    input                            reg_ddrc_ecc_region_map_other,         // same reg goes to every xpi port

    // For HWFFC
    input                            ddrc_xpi_port_disable_req,             // same req goes to every xpi port, port disable request from DDRC
    input                            ddrc_xpi_clock_required,               // same req goes to every xpi port, port clock request from DDRC

    output wire [INT_NPORTS_DATA-1:0]       xpi_ddrc_port_disable_ack,      // port disable acknowledge to DDRC
    output wire [A_NPORTS-1:0]              xpi_ddrc_wch_locked,
    
   //----------------------------------------------- 
   // AXI  IF 
   //-----------------------------------------------   
    // interface to AXI global signals (clock, reset, low-power)
    input [15:0]                     aclk_vector,                    // AXI clock, connect with aclk in up level 
    input [15:0]                     csysreq_xpi_vector,             // AXI low-power request
    output wire [A_NPORTS-1:0]       csysack_xpi_vector,             // AXI low-power request acknol'g
    output wire [A_NPORTS-1:0]       cactive_xpi_vector,             // AXI clock active
    output wire [A_NPORTS-1:0]       cactive_out_vector,             // Internal busy status, to drive uPCTL cactive_in 
    output wire [A_NPORTS-1:0]       rd_port_busy_vector,            // XPI read channel is busy
    output wire [A_NPORTS-1:0]       wr_port_busy_vector,            // XPI write channel is busy
//spyglass disable_block W240
//SMD: Input 'reg_ddrc_burst_rdwr[3:0]' declared but not read 
//SJ: In DDRCTL_LPDDR mode burst length is always BL16. Input value is not used and internally hard coded to BL16.
    input [BRW-1:0]                  reg_ddrc_burst_rdwr,
//spyglass enable_block W240
    input [DBW-1:0]                  reg_ddrc_data_bus_width,
    input [31:0]                     reg_arba_data_bus_width_vector,
    input                            reg_ddrc_burstchop,
    input                            reg_ddrc_wr_crc_enable,
    input                            reg_ddrc_col_addr_shift,
    input [A_NPORTS-1:0]             reg_xpi_snf_mode_vector,


    input [AMCOLW_L-1:0]             reg_ddrc_addrmap_col_b2,
    input [AMCOLW_C3-1:0]            reg_ddrc_addrmap_col_b3,
    input                            oc_parity_type_core_clock,  
    input                            reg_arb_bl_exp_mode,  
    input [15:0]                     reg_arb_port_en_vector,

    input [15:0]                     reg_arb_bypass_reorder_vector, // enable bypass reorder 
    input [ARB_TOTAL_ID-1:0]         reg_arb_id_mask_vector,        // Virtual channels id mask [NUM_VIR_CH_$*ID_MAPW-1:0]!!!
    input [ARB_TOTAL_ID-1:0]         reg_arb_id_value_vector,       // Virtual channels id value 

    input [15:0]                     reg_arb_occap_arb_cmp_poison_seq_vector,  
    input [15:0]                     reg_arb_occap_arb_cmp_poison_parallel_vector,
    input [15:0]                     reg_arb_occap_arb_cmp_poison_err_inj_vector,
    input [15:0]                     reg_arb_occap_arb_raq_poison_en_vector,

// newly added ocecc related input
    input [15:0]                        ocecc_en_aclk_vector,                        // (ocecc_en_aclk_$),
    input [15:0]                        ocecc_poison_egen_mr_rd_0_vector,            // (ocecc_poison_egen_mr_rd_0_$),
    input [OCECC_MR_BNUM_WIDTH*16-1:0]  ocecc_poison_egen_mr_rd_0_byte_num_vector,   // (ocecc_poison_egen_mr_rd_0_byte_num_$),
    input [15:0]                        ocecc_poison_egen_xpi_rd_out_vector,         // ???       (ocecc_poison_egen_xpi_rd_out_$),
    input [15:0]                        ocecc_poison_single_vector,                  // (ocecc_poison_single_$),
    input [15:0]                        ocecc_wdata_slverr_en_vector,                // (ocecc_wdata_slverr_en_$),
    input [15:0]                        ocecc_rdata_slverr_en_vector,                // (ocecc_rdata_slverr_en_$),
   
    // new changed name!!!
    input [15:0]                     oc_parity_en_aclk_vector,                   // @aclk enable on-chip parity
    input [15:0]                     oc_parity_type_aclk_vector,                 // @aclk select parity type: 0 even, 1 odd
    input [15:0]                     par_addr_slverr_en_aclk_vector,             // enable slverr response when address parity error
    input [15:0]                     par_rdata_slverr_en_vector,           
   // ocpar poison config  
    input [15:0]                     rd_poison_en_vector,
    input [15:0]                     wr_poison_en_vector,
    input [15:0]                     par_wdata_err_intr_clr_vector,
    input [15:0]                     par_rdata_err_intr_clr_vector,
 
    input                            par_wdata_axi_check_bypass_en,

    // interface to AXI write address channel
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Unused signal. Keeping it as it is part of the standard set of AXI signals.
//spyglass disable_block W241
//SMD: Output is never set.
//SJ: Part of the output remains unset depending on value of UMCTL2_A_NPORTS/UMCTL2_A_TYPE_$

    input [AXI_IDW*16-1:0]              awid_vector,       // AXI write address ID
    input [AXI_ADDRW*16-1:0]            awaddr_vector,     // AXI write address
    input [AXI_LENW*16-1:0]             awlen_vector,      // AXI write burst length
    input [AXI_SIZEW*16-1:0]            awsize_vector,     // AXI write burst size
    input [AXI_BURSTW*16-1:0]           awburst_vector,    // AXI write burst type
    input [AXI_TOTAL_LOCKW-1:0]         awlock_vector,     // AXI write lock type [AXI_LOCKW_$-1:0]!!!
    input [AXI_CACHEW*16-1:0]           awcache_vector,    // AXI write cache type
    input [AXI_PROTW*16-1:0]            awprot_vector,     // AXI write protection type
    input [AXI_USERW*16-1:0]            awuser_vector,
    input [AXI_QOSW*16-1:0]             awqos_vector,      // AXI write Quality of Service
    input [15:0]                        awurgent_vector,   // AXI write urgent transactions
    input [15:0]                        awvalid_vector,    // AXI write address valid
    input [15:0]                        awpoison_vector,   // AXI write poison
    input [15:0]                        awautopre_vector,  // AXI write auto precharge
    input [OCPAR_ADDR_PAR_WIDTH*16-1:0] awparity_vector,
    output wire [A_NPORTS-1:0]          awready_vector,    // AXI write address ready
    

    // interface to AXI write data channel
    input [AXI_IDW*16-1:0]              wid_vector,        // AXI write ID
    input [AXI_TOTAL_DW-1:0]            wdata_vector,      // AXI write data        
    input [AXI_TOTAL_STRBW-1:0]         wparity_vector,    // AXI write data parity 
    input [AXI_TOTAL_STRBW-1:0]         wstrb_vector,      // AXI write strobes     
    input [15:0]                        wlast_vector,      // AXI write last
    input [15:0]                        wvalid_vector,     // AXI write valid
    output wire [A_NPORTS-1:0]          wready_vector,     // AXI write ready
    input [AXI_USERW*16-1:0]            wuser_vector,
    
    // interface to AXI write response channel
    output wire [AXI_IDW*A_NPORTS-1:0]   bid_vector,        // AXI write response ID
    output wire [AXI_RESPW*A_NPORTS-1:0] bresp_vector,      // AXI write response
    output wire [AXI_USERW*A_NPORTS-1:0] buser_vector,
    output wire [A_NPORTS-1:0]           bvalid_vector,     // AXI write response valid
    input [15:0]                         bready_vector,     // AXI write response ready
    
    // interface to AXI read address channel
    input [AXI_IDW*16-1:0]              arid_vector,       // AXI read address ID
    input [AXI_ADDRW*16-1:0]            araddr_vector,     // AXI read address
    input [AXI_LENW*16-1:0]             arlen_vector,      // AXI read burst length
    input [AXI_SIZEW*16-1:0]            arsize_vector,     // AXI read burst size
    input [AXI_BURSTW*16-1:0]           arburst_vector,    // AXI read burst type
    input [AXI_TOTAL_LOCKW-1:0]         arlock_vector,     // AXI read lock type 
    input [AXI_CACHEW*16-1:0]           arcache_vector,    // AXI read cache type
    input [AXI_PROTW*16-1:0]            arprot_vector,     // AXI read protection type
    input [AXI_USERW*16-1:0]            aruser_vector,
    input [AXI_QOSW*16-1:0]             arqos_vector,      // AXI read Quality of Service
    input [15:0]                        arurgentb_vector,  // AXI read urgent transactions
    input [15:0]                        arurgentr_vector,  // AXI read urgent transactions
    input [15:0]                        arvalid_vector,    // AXI read address valid
    input [15:0]                        arpoison_vector,   // AXI read poison
    input [15:0]                        arautopre_vector,  // AXI read auto precharge
    input [OCPAR_ADDR_PAR_WIDTH*16-1:0] arparity_vector,
    output wire [A_NPORTS-1:0]          arready_vector,    // AXI read address ready
    
    // interface to AXI read data channel
    output wire [AXI_IDW*A_NPORTS-1:0]    rid_vector,        // AXI read ID
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    output wire [AXI_TOTAL_DW-1:0]        rdata_vector,      // AXI read data    
    output wire [AXI_TOTAL_STRBW-1:0]     rparity_vector,    // read data parity 
//spyglass enable_block W497
    output wire [AXI_RESPW*A_NPORTS-1:0]  rresp_vector,      // AXI read response
    output wire [AXI_USERW*A_NPORTS-1:0]  ruser_vector,
    output wire [A_NPORTS-1:0]            rlast_vector,      // AXI read last
    output wire [A_NPORTS-1:0]            rvalid_vector,     // AXI read valid
    input [15:0]                          rready_vector,     // AXI read ready
//spyglass enable_block W241
//spyglass enable_block W240

    // output from parity outputs
    output wire [AXI_ADDRW*A_NPORTS-1:0]       par_raddr_log_vector, // last read failing address
    output wire [AXI_ADDRW*A_NPORTS-1:0]       par_waddr_log_vector, // last write failing address
    output wire [OCPAR_NUM_BYTES*A_NPORTS-1:0] par_rdata_byte_log_vector, // last failing byte 

    // newly added ocecc output
    output wire [A_NPORTS-1:0]                 ocecc_xpi_write_uncorr_err_vector,
    output wire [A_NPORTS-1:0]                 ocecc_xpi_read_uncorr_err_vector,
    output wire [A_NPORTS-1:0]                 ocecc_xpi_write_corr_err_vector,
    output wire [A_NPORTS-1:0]                 ocecc_xpi_read_corr_err_vector,
    
    // External read data RAM interface
    input  [RDATARAM_DW*16-1:0]                rdataram_dout_vector,
    output wire [RDATARAM_DW*A_NPORTS-1:0]     rdataram_din_vector,
    output wire [A_NPORTS-1:0]                 rdataram_wr_vector,
    output wire [A_NPORTS-1:0]                 rdataram_re_vector,
    output wire [RDATARAM_AW*A_NPORTS-1:0]     rdataram_raddr_vector,
    output wire [RDATARAM_AW*A_NPORTS-1:0]     rdataram_waddr_vector,
    input [DATARAM_PAR_DW*16-1:0]              rdataram_dout_par_vector,
    output wire [DATARAM_PAR_DW*A_NPORTS-1:0]  rdataram_din_par_vector,
    
    input [RDATARAM_DW*16-1:0]                 rdataram_dout_dch1_vector,
    output wire [RDATARAM_DW*A_NPORTS-1:0]     rdataram_din_dch1_vector,
    output wire [A_NPORTS-1:0]                 rdataram_wr_dch1_vector,
    output wire [A_NPORTS-1:0]                 rdataram_re_dch1_vector,
    output wire [RDATARAM_AW*A_NPORTS-1:0]     rdataram_raddr_dch1_vector,
    output wire [RDATARAM_AW*A_NPORTS-1:0]     rdataram_waddr_dch1_vector,
    input [DATARAM_PAR_DW*16-1:0]              rdataram_dout_par_dch1_vector,
    output wire [DATARAM_PAR_DW*A_NPORTS-1:0]  rdataram_din_par_dch1_vector,
    
    // QOS configuration
    input [RQOS_MLW*16-1:0]             reg_arba_rqos_map_level1_vector,
    input [RQOS_MLW*16-1:0]             reg_arba_rqos_map_level2_vector,
    input [RQOS_RW*16-1:0]              reg_arba_rqos_map_region0_vector,
    input [RQOS_RW*16-1:0]              reg_arba_rqos_map_region1_vector,
    input [RQOS_RW*16-1:0]              reg_arba_rqos_map_region2_vector,
    input [RQOS_TW*16-1:0]              reg_arb_rqos_map_timeoutb_vector,
    input [RQOS_TW*16-1:0]              reg_arb_rqos_map_timeoutr_vector,    
    input [WQOS_MLW*16-1:0]             reg_arba_wqos_map_level1_vector,
    input [WQOS_MLW*16-1:0]             reg_arba_wqos_map_level2_vector,
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[1]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[3]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[5]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[7]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[9]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[11]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[13]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[15]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[17]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[19]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[21]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[23]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[25]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[27]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[29]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region0_vector[31]; ; Writes can have only NPW or HPW (00/01)
    input [WQOS_RW*16-1:0]              reg_arba_wqos_map_region0_vector,
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[1]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[3]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[5]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[7]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[9]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[11]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[13]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[15]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[17]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[19]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[21]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[23]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[25]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[27]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[29]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region1_vector[31]; ; Writes can have only NPW or HPW (00/01)
    input [WQOS_RW*16-1:0]              reg_arba_wqos_map_region1_vector,
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[1]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[3]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[5]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[7]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[9]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[11]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[13]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[15]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[17]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[19]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[21]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[23]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[25]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[27]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[29]; ; Writes can have only NPW or HPW (00/01)
    // ccx_tgl: ; reg_arba_wqos_map_region2_vector[31]; ; Writes can have only NPW or HPW (00/01)
    input [WQOS_RW*16-1:0]              reg_arba_wqos_map_region2_vector,
    input [WQOS_TW*16-1:0]              reg_arb_wqos_map_timeout1_vector,
    input [WQOS_TW*16-1:0]              reg_arb_wqos_map_timeout2_vector,
 
    // Page match mask from pm_mask ???
    input [15:0]                        reg_arb_rd_port_pagematch_en_vector,  
    input [15:0]                        reg_arb_wr_port_pagematch_en_vector,  
    input [15:0]                        reg_arb_rdwr_ordered_en_vector,       
    input [15:0]                        reg_arba_rdwr_ordered_en_vector,     
    input [15:0]                        reg_arb_port_data_channel_vector,     

    input [RRB_LOCK_THRESHOLD_WIDTH*16-1:0]      reg_arb_rrb_lock_threshold_vector,
   
    // read/write queue debug signals
//spyglass disable_block W241
//SMD: Output is never set.
//SJ: Part of the output remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, output is fully set.
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    output wire [AXI_TOTAL_RAQD_LG2-1:0]        raqb_wcount_vector, //[AXI_RAQD_LG2_$:0]  
    output wire [AXI_TOTAL_RAQD_LG2-1:0]        raqr_wcount_vector, //[AXI_RAQD_LG2_$:0] 
    output wire [AXI_TOTAL_WAQD_LG2-1:0]        waq_wcount_vector, //[AXI_WAQD_LG2_$:0]
//spyglass enable_block W497
//spyglass enable_block W241
    output wire [A_NPORTS-1:0]                  raqb_pop_vector,
    output wire [A_NPORTS-1:0]                  raqb_push_vector,
    output wire [A_NPORTS-1:0]                  raqr_pop_vector,
    output wire [A_NPORTS-1:0]                  raqr_push_vector,
    output wire [A_NPORTS-1:0]                  raq_split_vector,
    output wire [A_NPORTS-1:0]                  waq_pop_vector,
    output wire [A_NPORTS-1:0]                  waq_push_vector,
    output wire [A_NPORTS-1:0]                  waq_split_vector,
   
  //*************************************************************************************
  // AHB Port I/O Decelaration
  //*************************************************************************************
 
//`ifdef UMCTL2_INCL_ARB  
//*************************************************************************************
// pa_dual vs. ddrc  pa IF
//*************************************************************************************
 
    input [HIF_CREDIT_BITS-1:0]               hif_lpr_credit,
    input                                     hif_cmd_stall,             
    // from ddrc
    input                                     hif_wr_credit,   
    input [HIF_CREDIT_BITS-1:0]               hif_hpr_credit,
    input [1:0]                               hif_wrecc_credit,
    
    // go to ddrc 
    output wire                               pa_ddrc_go2critical_wr,
    output wire                               pa_ddrc_go2critical_lpr,
    output wire                               pa_ddrc_go2critical_hpr,
    output wire                               pa_hif_go2critical_l1_wr,
    output wire                               pa_hif_go2critical_l2_wr,
    output wire                               pa_hif_go2critical_l1_lpr,
    output wire                               pa_hif_go2critical_l2_lpr,
    output wire                               pa_hif_go2critical_l1_hpr,
    output wire                               pa_hif_go2critical_l2_hpr,
    
    input                                     any_other_stall_condition,
    input                                     lpr_num_entries_changed,

    // Performance Monitor Interface
    output wire                               perf_hpr_req_with_nocredit_dch0,
    output wire                               perf_lpr_req_with_nocredit_dch0,
    // Credit Counters
    output wire [CRDT_CNT_WIDTH-1:0]          lpr_credit_cnt,
    output wire [CRDT_CNT_WIDTH-1:0]          hpr_credit_cnt,
    output wire [CRDT_CNT_WIDTH-1:0]          wr_credit_cnt,
    output wire [CRDT_CNT_WIDTH-1:0]          wrecc_credit_cnt,
    output wire                               pa_parity_err_dch0,            
    output wire                               pa_parity_err_dch1,              
    //reg if
    input                                     reg_arb_go2critical_en,
    input                                     reg_arb_pagematch_limit,

    input [INT_NPORTS*REG_PORT_PRIORITYW-1:0]     reg_wr_port_priority_vector,    
    input [INT_NPORTS*REG_PORT_PRIORITYW-1:0]     reg_rd_port_priority_vector,
    input [INT_NPORTS-1:0]                        reg_rd_port_aging_en_vector,
    input [INT_NPORTS-1:0]                        reg_wr_port_aging_en_vector,
    input [INT_NPORTS-1:0]                        reg_wr_port_urgent_en_vector,
    input [INT_NPORTS-1:0]                        reg_rd_port_urgent_en_vector,

 
    
 
    
//*************************************************************************************
// hif_cmd vs. ddrc  HIF CMD IF
//*************************************************************************************

    //----------------------------------------------------------------------
    //   clock and reset to both hif_cmd, hif_data and other internal blocks
    //---------------------------------------------------------------------
    input                               core_ddrc_core_clk,
    input                               core_ddrc_rstn,

//**************************************************************************
// Base hif_cmd module
//**************************************************************************

    output wire [RQOS_TW-1:0]                hif_hif_cmd_latency,        // to ddrc
    output wire                              hif_hif_cmd_valid,          // to ddrc
    output wire [1:0]                        hif_hif_cmd_type,           // to ddrc
    output wire [HIF_ADDR_WIDTH-1:0]         hif_hif_cmd_addr,           // to ddrc
    output wire [RQOS_RW-1:0]                hif_hif_cmd_pri,            // to ddrc
    output wire [MEMC_TAGBITS-1:0]           hif_hif_cmd_token,          // to ddrc
    // ccx_tgl: ; hif_hif_cmd_length; ; In LPDDR54 controller, BL register is always programmed to BL16. So only full read/write is supported
    output wire [CMD_LEN_BITS-1:0]           hif_hif_cmd_length,         // to ddrc
    output wire [WDATA_PTR_BITS-1:0]         hif_hif_cmd_wdata_ptr,      // to ddrc
    output wire                              hif_hif_cmd_autopre,        // to ddrc
    output wire                              hif_hif_cmd_ecc_region,     // to ddrc
    output wire [WRDATA_CYCLES-1:0]          hif_hif_cmd_wdata_mask_full_ie, // to ddrc
   
    output wire                              hif_hif_cmd_awlast,            // from hif_cmd just goes to exa_top!!!
    output wire                              hif_hif_cmd_short_burst,       // from hif_cmd just goes to exa_top!!!

//**************************************************************************
// Channel 1 hif_cmd module  HIF CMD DCH1 IF
//**************************************************************************
    

//*************************************************************************************
// hif_data vs. ddrc    HIF DATA IF
//*************************************************************************************
    // HIF Write Data Pointer Return
    input [MEMC_WDATA_PTR_BITS-1:0] hif_wdata_ptr,
    input                           hif_wdata_ptr_valid,
    input                           hif_wr_addr_err,
   
    // HIF Read Data Channel (Common Response)
    input                           hif_rdata_valid,           // from ddrc
    input                           hif_rdata_end,             // from ddrc
    input [MEMC_TAGBITS-1:0]        hif_rdata_token,           // from ddrc
    input [A_DW-1:0]                hif_rdata,                 // from ddrc
    input [A_STRBW-1:0]             hif_rdata_parity,          // from ddrc
    input                           hif_rdata_uncorr_ecc_err,  // from ddrc
    input                           hif_rdata_crc_err,         // from ddrc
    input                           hif_rdata_addr_err,        // from ddrc
    input                           hif_rdata_eapar_err,
    input                           hif_rdata_uncorr_linkecc_err,     // from ddrc
    // HIF Write Data Channel
    input                           hif_wdata_stall,           // write data stall signal from ddrc
    output wire                     hif_wdata_valid,           // write data valid signal from hif_data to ddrc
    output wire                     hif_wdata_end,             // write data end signal from hif_data to ddrc
    output wire [A_DW-1:0]          hif_wdata,                 // write data from hif_data to ddrc
    output wire [A_STRBW-1:0]       hif_wdata_mask,            // write data mask signal from hif_data to ddrc
    output wire [A_PARW-1:0]        hif_wdata_parity,          // write data mask signal from hif_data to ddrc 

    // ocpar slverr gate
    input                           reg_ddrc_par_addr_slverr_en,   // common for both channel!!! 
    input                           reg_ddrc_par_wdata_slverr_en,  // common for both channel!!!
    input                           reg_ddrc_wr_poison_slverr_en,  // common for both channel!!!
    input                           reg_ddrc_wr_poison_intr_en,    // common for both channel!!!
    input                           reg_ddrc_wr_poison_intr_clr,   // common for both channel!!!
    input                           reg_ddrc_ocecc_wdata_slverr_en, // common for both channel!!!  new !!!
    
    output wire                     occap_hif_data_par_err_dch0,
    output wire [INT_NPORTS_DATA-1:0]   wr_poison_intr_dch0,

    // ocpar slverr gate for dch1
    output wire                     occap_hif_data_par_err_dch1,
    output wire [INT_NPORTS_DATA-1:0]      wr_poison_intr_dch1,




    


//*************************************************************************************
// hif_data vs. ddrc    HIF DATA DCH1 IF
//*************************************************************************************    


//*************************************************************************************
// exa_top's output :  its inputs are mainly from hif_cmd and output go to debug pins 
//*************************************************************************************
    

    output wire                              exa_parity_err,                  // goes to output of xpi_top          
    output wire                              exa_parity_err_dch1, 
    
    //*************************************************************************************
    // sbr  I/O Decelaration
    //*************************************************************************************
    output wire                       occap_sbr_par_err_dch0,
    output wire                       occap_sbr_par_err_dch1,
  //*************************************************************************************
  // pm_mask  I/O Decelaration
  //*************************************************************************************
    // Register Interface
      //ccx_tgl : ; pa_rmask[1]; ; One bit of pa_rmask is not toggled out of 4 bits. Lack of stimulus. Task to cover this item is captured at https://jira.internal.synopsys.com/browse/P80001562-170174
    input [2*A_NPORTS-1:0]             pa_rmask,
    input [A_NPORTS-1:0]               pa_wmask,
    
    input                              reg_ddrc_lpddr3_6gb_12gb,
    input [1:0]                        reg_ddrc_lpddr45_6gb_12gb_24gb,

    input [2:0]                        reg_ddrc_nonbinary_device_density,




    input [AMBANKW-1:0]                 reg_ddrc_addrmap_bank_b0,
    input [AMBANKW-1:0]                 reg_ddrc_addrmap_bank_b1,
    input [AMBANKW-1:0]                 reg_ddrc_addrmap_bank_b2,
    input [AMCOLW_L-1:0]                reg_ddrc_addrmap_col_b4,   
    input [AMCOLW_L-1:0]                reg_ddrc_addrmap_col_b5,
    input [AMCOLW_L-1:0]                reg_ddrc_addrmap_col_b6,
    input [AMCOLW_H-1:0]                reg_ddrc_addrmap_col_b7,
    input [AMCOLW_H-1:0]                reg_ddrc_addrmap_col_b8,
    input [AMCOLW_H-1:0]                reg_ddrc_addrmap_col_b9,
    input [AMCOLW_H-1:0]                reg_ddrc_addrmap_col_b10,
    input [AMCOLW_H-1:0]                reg_ddrc_addrmap_col_b11,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b0,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b1,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b2,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b3,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b4,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b5,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b6,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b7,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b8,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b9,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b10,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b2_10,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b11,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b12,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b13,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b14,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b15,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b16,
    input [AMROWW-1:0]                  reg_ddrc_addrmap_row_b17,

 

 
    output wire                         pm_mask_parity_err,
//`endif //  `ifdef UMCTL2_INCL_ARB


    input [15:0]                        aresetn_vector);                // AXI asynchronous reset 
               
//UNR constant to constrain the coverage reporting for reg_ddrc_data_bus_width related code
`SNPS_UNR_CONSTANT("In LPDDR54 controller if INLINE_ECC is enabled and DRAM data width is 32, HBW& QBW can't be exercised", (M_INLINE_ECC==1 && M_DW==32), reg_ddrc_data_bus_width[1:0], 2'b0)
// If NAB==3, lower 3 hif address bits are always 0
`SNPS_UNR_CONSTANT("If NAB==3, lower 3 hif address bits are always 0", (NAB==3) , hif_hif_cmd_addr[2:0], 3'b0)

`SNPS_UNR_CONSTANT("If CAM depth is less than or equal to 64", (MEMC_NO_OF_ENTRY<=64) , wrecc_credit_cnt[6], 1'b0)
`SNPS_UNR_CONSTANT("If CAM depth is less than or equal to 64", (MEMC_NO_OF_ENTRY<=64) , hpr_credit_cnt[6], 1'b0)

   //--------------------------
   // UMCTL2_A_USE2RAQ define 
   //--------------------------
 `define USE2RAQ0   1'b0  

 `define USE2RAQ1   1'b0  
 `define USE2RAQ2   1'b0  

 `define USE2RAQ3   1'b0  
 `define USE2RAQ4   1'b0  

 `define USE2RAQ5   1'b0  
 `define USE2RAQ6   1'b0  

 `define USE2RAQ7   1'b0  
 `define USE2RAQ8   1'b0  
 `define USE2RAQ9   1'b0  
 `define USE2RAQ10   1'b0  
 `define USE2RAQ11   1'b0  
 `define USE2RAQ12   1'b0  
 `define USE2RAQ13   1'b0  
 `define USE2RAQ14   1'b0  
 `define USE2RAQ15   1'b0  

 localparam [15:0] UMCTL2_A_USE2RAQ = {`USE2RAQ15, `USE2RAQ14, `USE2RAQ13, `USE2RAQ12,
                     `USE2RAQ11, `USE2RAQ10, `USE2RAQ9 , `USE2RAQ8 ,
                     `USE2RAQ7 , `USE2RAQ6 , `USE2RAQ5 , `USE2RAQ4 ,
                     `USE2RAQ3 , `USE2RAQ2 , `USE2RAQ1 , `USE2RAQ0  };  
   
   
   //----------------------------------------------- 
    // internal wire vector between A2X and XPI 
    //-----------------------------------------------
 `define AXI4_0  1'b1 

 `define AXI4_1  1'b0  

 `define AXI4_2  1'b0  

 `define AXI4_3  1'b0  

 `define AXI4_4  1'b0  

 `define AXI4_5  1'b0  

 `define AXI4_6  1'b0  

 `define AXI4_7  1'b0  

 `define AXI4_8  1'b0  

 `define AXI4_9  1'b0  

 `define AXI4_10  1'b0  

 `define AXI4_11  1'b0  

 `define AXI4_12  1'b0  
    
 `define AXI4_13  1'b0  

 `define AXI4_14  1'b0  

 `define AXI4_15  1'b0  
    localparam [15:0] AXI4 = {`AXI4_15,`AXI4_14,`AXI4_13,`AXI4_12,`AXI4_11,`AXI4_10,`AXI4_9,`AXI4_8,    
                              `AXI4_7, `AXI4_6, `AXI4_5, `AXI4_4, `AXI4_3, `AXI4_2, `AXI4_1,`AXI4_0 };
    
 `define AHB_0  1'b0  

 `define AHB_1  1'b0  

 `define AHB_2  1'b0  

 `define AHB_3  1'b0  

 `define AHB_4  1'b0  

 `define AHB_5  1'b0  

 `define AHB_6  1'b0  

 `define AHB_7  1'b0  

 `define AHB_8  1'b0  

 `define AHB_9  1'b0  

 `define AHB_10  1'b0  

 `define AHB_11  1'b0  

 `define AHB_12  1'b0  
    
 `define AHB_13  1'b0  

 `define AHB_14  1'b0  

 `define AHB_15  1'b0  
    
    //used for generate for loop to decide if there is a AHB port or not!!!   
    localparam [15:0] AHB = {`AHB_15,`AHB_14,`AHB_13,`AHB_12,`AHB_11,`AHB_10,`AHB_9,`AHB_8,    
                             `AHB_7, `AHB_6, `AHB_5, `AHB_4, `AHB_3, `AHB_2, `AHB_1,`AHB_0 };

//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    // AXI AW Channel Internale Vector 
    wire [15:0]                        awvalid_vector_int;    // AXI write address valid
    wire [AXI_IDW*16-1:0]              awid_vector_int;       // AXI write address ID
    wire [AXI_ADDRW*16-1:0]            awaddr_vector_int;     // AXI write address
    wire [AXI_LENW*16-1:0]             awlen_vector_int;      // AXI write burst length
    wire [AXI_SIZEW*16-1:0]            awsize_vector_int;     // AXI write burst size
    wire [AXI_BURSTW*16-1:0]           awburst_vector_int;    // AXI write burst type
    wire [AXI_TOTAL_LOCKW-1:0]         awlock_vector_int;     // AXI write lock type [AXI_LOCKW_$-1:0]!!!
    wire [AXI_CACHEW*16-1:0]           awcache_vector_int;    // AXI write cache type
    wire [AXI_PROTW*16-1:0]            awprot_vector_int;     // AXI write protection type
//spyglass enable_block W497
    wire [A_NPORTS-1:0]                awready_vector_int;    // AXI write address ready
     
    // AHB Secondary Port AW Channel Interface
    wire [15:0]                        ahb2axi_awvalid_vector;
    wire [A_NPORTS-1:0]                ahb2axi_awready_vector;
    wire [AXI_IDW*16-1:0]              ahb2axi_awid_vector;
    wire [AXI_ADDRW*16-1:0]            ahb2axi_awaddr_vector;
    wire [AXI_LENW*16-1:0]             ahb2axi_awlen_vector;
    wire [AXI_SIZEW*16-1:0]            ahb2axi_awsize_vector;
    wire [AXI_BURSTW*16-1:0]           ahb2axi_awburst_vector;
    wire [AXI_TOTAL_LOCKW-1:0]         ahb2axi_awlock_vector;   
    wire [AXI_CACHEW*16-1:0]           ahb2axi_awcache_vector;
    wire [AXI_PROTW*16-1:0]            ahb2axi_awprot_vector;
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    // AXI W Channel Internale Vector 
    wire [AXI_IDW*16-1:0]              wid_vector_int;        // AXI write ID
    wire [AXI_TOTAL_DW-1:0]            wdata_vector_int;      // AXI write data        !!!
    wire [AXI_TOTAL_STRBW-1:0]         wstrb_vector_int;      // AXI write strobes     !!!
    wire [15:0]                        wlast_vector_int;      // AXI write last
    wire [15:0]                        wvalid_vector_int;     // AXI write valid
//spyglass enable_block W497
    wire [A_NPORTS-1:0]                wready_vector_int;     // AXI write ready
 
    // AHB Secondary Port W Channel Interface
    wire [AXI_IDW*16-1:0]              ahb2axi_wid_vector;    // AXI write ID
    wire [AXI_TOTAL_DW-1:0]            ahb2axi_wdata_vector;  // AXI write data        !!!
    wire [AXI_TOTAL_STRBW-1:0]         ahb2axi_wstrb_vector;  // AXI write strobes     !!!
    wire [15:0]                        ahb2axi_wlast_vector;  // AXI write last
    wire [15:0]                        ahb2axi_wvalid_vector; // AXI write valid
    wire [A_NPORTS-1:0]                ahb2axi_wready_vector; // AXI write ready

   // AXI B Channel Internale Vector
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    wire [AXI_IDW*A_NPORTS-1:0]        bid_vector_int;        // AXI write response ID
    wire [AXI_RESPW*A_NPORTS-1:0]      bresp_vector_int;      // AXI write response
    wire [AXI_USERW*A_NPORTS-1:0]      buser_vector_int;      // Not in ahb side 
    wire [15:0]                        bready_vector_int;     // AXI write response ready 
//spyglass enable_block W497
    wire [A_NPORTS-1:0]                bvalid_vector_int;     // AXI write response valid
 
    // AHB Secondary Port B Channel Interface
    wire [AXI_IDW*A_NPORTS-1:0]        ahb2axi_bid_vector;        // AXI write response ID
    wire [AXI_RESPW*A_NPORTS-1:0]      ahb2axi_bresp_vector;      // AXI write response
    wire [A_NPORTS-1:0]                ahb2axi_bvalid_vector;     // AXI write response valid
    wire [15:0]                        ahb2axi_bready_vector;     // AXI write response ready 
    //wire [AXI_USERW*A_NPORTS-1:0]      ahb2axi_buser_vector_int;      // Not in ahb side  
   
    //AXI AR Channel Internale Vector
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    wire [AXI_IDW*16-1:0]              arid_vector_int;       // AXI read address ID
    wire [AXI_ADDRW*16-1:0]            araddr_vector_int;     // AXI read address
    wire [AXI_LENW*16-1:0]             arlen_vector_int;      // AXI read burst length
    wire [AXI_SIZEW*16-1:0]            arsize_vector_int;     // AXI read burst size
    wire [AXI_BURSTW*16-1:0]           arburst_vector_int;    // AXI read burst type
    wire [AXI_TOTAL_LOCKW-1:0]         arlock_vector_int;     // AXI read lock type !!!
    wire [AXI_CACHEW*16-1:0]           arcache_vector_int;    // AXI read cache type
    wire [AXI_PROTW*16-1:0]            arprot_vector_int;     // AXI read protection type
    wire [15:0]                        arvalid_vector_int;    // AXI read address valid
//spyglass enable_block W497
    wire [A_NPORTS-1:0]                arready_vector_int;    // AXI read address ready
    wire [A_NPORTS-1:0]                aw_fifo_push_empty; 

    // AHB Secondary Port AR Channel Interface
    wire [15:0]                       ahb2axi_arvalid_vector;
    wire [A_NPORTS-1:0]               ahb2axi_arready_vector;
    wire [AXI_IDW*16-1:0]             ahb2axi_arid_vector;
    wire [AXI_ADDRW*16-1:0]           ahb2axi_araddr_vector;  
    wire [AXI_LENW*16-1:0]            ahb2axi_arlen_vector;
    wire [AXI_SIZEW*16-1:0]           ahb2axi_arsize_vector;
    wire [AXI_BURSTW*16-1:0]          ahb2axi_arburst_vector;
    wire [AXI_TOTAL_LOCKW-1:0]        ahb2axi_arlock_vector; 
    wire [AXI_CACHEW*16-1:0]          ahb2axi_arcache_vector;      
    wire [AXI_PROTW*16-1:0]           ahb2axi_arprot_vector;
   
   // AXI R Channel Internale Vector     
    wire [AXI_IDW*A_NPORTS-1:0]       rid_vector_int;        // AXI read ID
    wire [AXI_RESPW*A_NPORTS-1:0]     rresp_vector_int;      // AXI read response
    wire [A_NPORTS-1:0]               rlast_vector_int;      // AXI read last, not in ahb side 
    wire [A_NPORTS-1:0]               rvalid_vector_int;     // AXI read valid
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Part of the bus remains unset depending on value of UMCTL2_A_NPORTS. When UMCTL2_A_NPORTS is 16, bus bits is fully set.
    wire [AXI_TOTAL_DW-1:0]           rdata_vector_int;      // AXI read data    
    wire [15:0]                       rready_vector_int;     // AXI read ready
//spyglass enable_block W497
 
    // AHB Secondary Port R Channel Interface
    wire [A_NPORTS-1:0]               ahb2axi_rvalid_vector;     // AXI read valid
    wire [15:0]                       ahb2axi_rready_vector;     // AXI read ready
    wire [A_NPORTS-1:0]               ahb2axi_rlast_vector;      // AXI read last
    wire [AXI_IDW*A_NPORTS-1:0]       ahb2axi_rid_vector;        // AXI read ID
    wire [AXI_TOTAL_DW-1:0]           ahb2axi_rdata_vector;      // AXI read data    
    wire [AXI_RESPW*A_NPORTS-1:0]     ahb2axi_rresp_vector;      // AXI read response      
 
   
   // Burst length register decoding
  localparam BL8           = {4'b0100};
  localparam BL16          = {4'b1000};
  // Internal burst_rdwr signal generation
  wire [BRW-1:0] reg_ddrc_burst_rdwr_int;
        assign reg_ddrc_burst_rdwr_int = BL16;  //For LPDDR4/5 controller programmed BL is 16 always.


//spyglass disable_block W528
//SMD: A signal or variable is set but never read  
//SJ:  Decided to keep all "unused" variables. Some are used in TB, the others are kept for debugging purposes. All internal modules have inline waivers for each reported variable 
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((AXI_LOCKW_NB * (i + 2)) - 1)' found in module 'DWC_ddr_arb_top'
//SJ: This coding style is acceptable and there is no plan to change it.
   genvar  i;
   generate 
     for (i=0; i< A_NPORTS; i=i+1) begin : mapping_ahb2axi_wires
  if(AHB[i]) begin: AHB_Bridge //With AHB Bridge !!!
           // AW Channel
           assign awvalid_vector_int[i]                                    = ahb2axi_awvalid_vector[i];
           assign ahb2axi_awready_vector[i]                                = awready_vector_int[i];
     //if (AXI_IDW>A2X_IDW) begin   
     if (AXI_IDW>A2X_IDW) begin   
              assign awid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]               = {{(AXI_IDW-A2X_IDW){1'b0}},ahb2axi_awid_vector[A2X_IDW*(i+1)-1:A2X_IDW*i]};
     end else begin 
              assign awid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]               = ahb2axi_awid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i];
     end
     if(AXI_ADDRW > `UMCTL2_A_ADDRW) begin 
              assign awaddr_vector_int[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i]         = {{(AXI_ADDRW-`UMCTL2_A_ADDRW){1'b0}}, ahb2axi_awaddr_vector[`UMCTL2_A_ADDRW*(i+1)-1:`UMCTL2_A_ADDRW*i]};
     end else begin
        assign awaddr_vector_int[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i]         = ahb2axi_awaddr_vector[`UMCTL2_A_ADDRW*(i+1)-1:`UMCTL2_A_ADDRW*i];
     end  
           assign awlen_vector_int[AXI_LENW*(i+1)-1:AXI_LENW*i]            = ahb2axi_awlen_vector[AXI_LENW*(i+1)-1:AXI_LENW*i];
           assign awsize_vector_int[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i]         = ahb2axi_awsize_vector[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i];   
           assign awburst_vector_int[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i]      = ahb2axi_awburst_vector[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i];
           assign awlock_vector_int[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]]  = ahb2axi_awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]];  
           assign awcache_vector_int[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i]      = ahb2axi_awcache_vector[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i];
           assign awprot_vector_int[AXI_PROTW*(i+1)-1:AXI_PROTW*i]         = ahb2axi_awprot_vector[AXI_PROTW*(i+1)-1:AXI_PROTW*i]; 
           // W Channel
   
     if(!AXI4[i]) begin
       //if (AXI_IDW>A2X_IDW && !AXI4[i]) begin      
       if (AXI_IDW>A2X_IDW && !AXI4[i]) begin      
    assign wid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]                = {{(AXI_IDW-A2X_IDW){1'b0}}, ahb2axi_wid_vector[A2X_IDW*(i+1)-1:A2X_IDW*i]};
       end else begin
    assign wid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]                = ahb2axi_wid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i];      
       end
     end else begin
     assign wid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]                = {AXI_IDW{1'b0}};
     end
           assign wdata_vector_int[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]] = ahb2axi_wdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1 : AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]]; 
           assign wstrb_vector_int[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+2)-1:AXI_STRBW_NB*(i+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+1)-1:AXI_STRBW_NB*i]] = ahb2axi_wstrb_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+2)-1:AXI_STRBW_NB*(i+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+1)-1:AXI_STRBW_NB*i]];
           assign wlast_vector_int[i]                                      = ahb2axi_wlast_vector[i]; 
           assign wvalid_vector_int[i]                                     = ahb2axi_wvalid_vector[i];
           assign ahb2axi_wready_vector[i]                                 = wready_vector_int[i];
           // B channel 
           assign ahb2axi_bvalid_vector[i]                                 = bvalid_vector_int[i];
           assign bready_vector_int[i]                                     = ahb2axi_bready_vector[i];
           assign ahb2axi_bresp_vector[AXI_RESPW*(i+1)-1:AXI_RESPW*i]      = bresp_vector_int[AXI_RESPW*(i+1)-1:AXI_RESPW*i];
           assign ahb2axi_bid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i]            = bid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i];
           // AR channel
           assign arvalid_vector_int[i]                                    = ahb2axi_arvalid_vector[i];
           assign ahb2axi_arready_vector[i]                                = arready_vector_int[i];

     if (AXI_IDW>A2X_IDW) begin
              assign arid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]            = {{(AXI_IDW-A2X_IDW){1'b0}}, ahb2axi_arid_vector[A2X_IDW*(i+1)-1:A2X_IDW*i]};
     end else begin
              assign arid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]            = ahb2axi_arid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i];
     end
     if(AXI_ADDRW > `UMCTL2_A_ADDRW) begin 
           assign araddr_vector_int[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i]         = {{(AXI_ADDRW-`UMCTL2_A_ADDRW){1'b0}}, ahb2axi_araddr_vector[`UMCTL2_A_ADDRW*(i+1)-1:`UMCTL2_A_ADDRW*i]};
     end else begin
      assign araddr_vector_int[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i]         = ahb2axi_araddr_vector[`UMCTL2_A_ADDRW*(i+1)-1:`UMCTL2_A_ADDRW*i];
     end  
           assign arlen_vector_int[AXI_LENW*(i+1)-1:AXI_LENW*i]            = ahb2axi_arlen_vector[AXI_LENW*(i+1)-1:AXI_LENW*i];
           assign arsize_vector_int[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i]         = ahb2axi_arsize_vector[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i];
           assign arburst_vector_int[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i]      = ahb2axi_arburst_vector[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i];
           assign arlock_vector_int[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]]  = ahb2axi_arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]];  
           assign arcache_vector_int[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i]      = ahb2axi_arcache_vector[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i];
           assign arprot_vector_int[AXI_PROTW*(i+1)-1:AXI_PROTW*i]         = ahb2axi_arprot_vector[AXI_PROTW*(i+1)-1:AXI_PROTW*i];
     // R Channel
           assign ahb2axi_rvalid_vector[i]                                 = rvalid_vector_int[i];
     assign rready_vector_int[i]                                     = ahb2axi_rready_vector[i];     
           assign ahb2axi_rdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1 : AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]] = rdata_vector_int[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]];
     assign ahb2axi_rlast_vector[i]                                  = rlast_vector_int[i];
     assign ahb2axi_rid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i]            = rid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i];
           assign ahb2axi_rresp_vector[AXI_RESPW*(i+1)-1:AXI_RESPW*i]      = rresp_vector_int[AXI_RESPW*(i+1)-1:AXI_RESPW*i];
  end else begin: nAHB_Bridge //No AHB bridge!!!
           // AW Channel
           assign awvalid_vector_int[i]                                    = awvalid_vector[i];
           assign awready_vector[i]                                        = awready_vector_int[i];
           assign awid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]               = awid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i];
           assign awaddr_vector_int[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i]         = awaddr_vector[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i];
           assign awlen_vector_int[AXI_LENW*(i+1)-1:AXI_LENW*i]            = awlen_vector[AXI_LENW*(i+1)-1:AXI_LENW*i];
           assign awsize_vector_int[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i]         = awsize_vector[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i];   
           assign awburst_vector_int[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i]      = awburst_vector[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i];
           assign awlock_vector_int[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]] = 
                  awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]];  
           assign awcache_vector_int[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i]      = awcache_vector[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i];
           assign awprot_vector_int[AXI_PROTW*(i+1)-1:AXI_PROTW*i]         = awprot_vector[AXI_PROTW*(i+1)-1:AXI_PROTW*i];  
          // W Channel     
           assign wid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]                = wid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i];
           assign wdata_vector_int[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]]  = 
                  wdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]]; 
           assign wstrb_vector_int[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+2)-1:AXI_STRBW_NB*(i+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+1)-1:AXI_STRBW_NB*i]]  = 
                  wstrb_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+2)-1:AXI_STRBW_NB*(i+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(i+1)-1:AXI_STRBW_NB*i]]; 
           assign wlast_vector_int[i]                                      = wlast_vector[i]; 
           assign wvalid_vector_int[i]                                     = wvalid_vector[i];
           assign wready_vector[i]                                         = wready_vector_int[i];
           // B channel 
           assign bvalid_vector[i]                                         = bvalid_vector_int[i];
           assign bready_vector_int[i]                                     = bready_vector[i];
           assign bresp_vector[AXI_RESPW*(i+1)-1:AXI_RESPW*i]              = bresp_vector_int[AXI_RESPW*(i+1)-1:AXI_RESPW*i];
           assign bid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i]                    = bid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i];
           // AR channel
           assign arvalid_vector_int[i]                                    = arvalid_vector[i];
           assign arready_vector[i]                                        = arready_vector_int[i];
           assign arid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i]               = arid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i];
           assign araddr_vector_int[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i]         = araddr_vector[AXI_ADDRW*(i+1)-1:AXI_ADDRW*i];
           assign arlen_vector_int[AXI_LENW*(i+1)-1:AXI_LENW*i]            = arlen_vector[AXI_LENW*(i+1)-1:AXI_LENW*i];
           assign arsize_vector_int[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i]         = arsize_vector[AXI_SIZEW*(i+1)-1:AXI_SIZEW*i];
           assign arburst_vector_int[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i]      = arburst_vector[AXI_BURSTW*(i+1)-1:AXI_BURSTW*i];
           assign arlock_vector_int[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]] = 
                  arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+2)-1:AXI_LOCKW_NB*(i+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(i+1)-1:AXI_LOCKW_NB*i]]; 
           assign arcache_vector_int[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i]      = arcache_vector[AXI_CACHEW*(i+1)-1:AXI_CACHEW*i];
           assign arprot_vector_int[AXI_PROTW*(i+1)-1:AXI_PROTW*i]         = arprot_vector[AXI_PROTW*(i+1)-1:AXI_PROTW*i];
     // R channel no AHB bridge!!!
           assign rvalid_vector[i]                                         = rvalid_vector_int[i];
           assign rready_vector_int[i]                                     = rready_vector[i];
           assign rid_vector[AXI_IDW*(i+1)-1:AXI_IDW*i]                    = rid_vector_int[AXI_IDW*(i+1)-1:AXI_IDW*i];
           assign rdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]] = 
                  rdata_vector_int[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+2)-1:AXI_DW_NB*(i+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(i+1)-1:AXI_DW_NB*i]];
           assign rresp_vector[AXI_RESPW*(i+1)-1:AXI_RESPW*i]              = rresp_vector_int[AXI_RESPW*(i+1)-1:AXI_RESPW*i];
           assign rlast_vector[i]                                          = rlast_vector_int[i];
       end // else: !if(AHB[i])
     end // for (i=0; i< A_NPORTS; i=i+1)
   endgenerate
 
//-------------------------   
// pm_mask wires
//--------------------------
   wire                                           pm_mask_parity_err_w;
   wire [HIF_ADDR_WIDTH-1:0]                      pagematch_addrmap_mask;
   wire [HIF_ADDR_WIDTH-1:0]                      data_channel_addrmap_mask;
   wire [HIF_ADDR_WIDTH-1:0]                      bg_or_bank_addrmap_mask;

   wire [HIF_ADDR_WIDTH-1:0]                      lpddr34_6gb_12gb_mask_unused;

   wire [HIF_ADDR_WIDTH-1:0]                      sbr_address_range;
   wire [HIF_ADDR_WIDTH-1:0]                      l3_iecc_col_mask;
   wire [ECC_H3_WIDTH-1:0]                        h3_iecc_col_mask;  


//--------------------------   
// hif_cmd vs. exa_top
//--------------------------
   wire [EXA_PYLD_W-1:0]                          hif_co_ih_exa_pyld_wr;         // from hif_cmd just goes to exa_top!!!
   wire [EXA_PYLD_W-1:0]                          hif_co_ih_exa_pyld_rd;         // from hif_cmd just goes to exa_top!!!
  
   wire [EXA_PYLD_W-1:0]                          hif_co_ih_exa_pyld_wr_dch1;    // from hif_cmd just goes to exa_top!!!
   wire [EXA_PYLD_W-1:0]                          hif_co_ih_exa_pyld_rd_dch1;    // from hif_cmd just goes to exa_top!!!

//-------------------------------------------------------------------------------------------
// hif_data vs. xpi internal wires
//---------------------------------

   // XPI Write Data Channel
   wire [INT_NPORTS_DATA-1:0]                     xpi_wvalid;
   wire [INT_NPORTS_DATA*A_DW-1:0]                xpi_wdata;
   wire [INT_NPORTS_DATA*A_STRBW-1:0]             xpi_wstrb;
   wire [INT_NPORTS_DATA*A_PARW-1:0]              xpi_wparity;
   wire [INT_NPORTS_DATA-1:0]                     xpi_wlast;
   wire [INT_NPORTS_DATA*A_STRBW-1:0]             xpi_wpar_err;
   wire [INT_NPORTS_DATA-1:0]                     xpi_wlast_pkt;
   wire [INT_NPORTS_DATA-1:0]                     xpi_snf_mode;

    wire [A_NPORTS*2*RQOS_TW-1:0]                 xpi_rqos_timeout, xpi_rqos_timeout_dch1;
    wire [A_NPORTS*2-1:0]                         xpi_arvalid, xpi_arvalid_dch1;
    wire [A_NPORTS*2-1:0]                         xpi_vpr_expired, xpi_vpr_expired_dch1;
    wire [A_NPORTS*2*HIF_ADDR_WIDTH-1:0]          xpi_araddr,  xpi_araddr_dch1;


    reg [A_NPORTS*2*MEMC_TAGBITS-1:0]              xa_rtoken;
    reg [A_NPORTS*2*MEMC_TAGBITS-1:0]              xa_rtoken_dch1;
//spyglass disable_block W497
//SMD: Not all bits of bus are set.
//SJ: Max AXI_TAGBITS are considered here. Some of the bits will not be used depending on configuration.
    wire [A_NPORTS*2*UMCTL2_MAX_AXI_TAGBITS-1:0]   xa_rtoken_x;
    wire [A_NPORTS*2*UMCTL2_MAX_AXI_TAGBITS-1:0]   xa_rtoken_x_dch1;
//spyglass enable_block W497

    wire [A_NPORTS-1:0]                           xpi_awvalid, xpi_awvalid_dch1;
    wire [A_NPORTS*HIF_ADDR_WIDTH-1:0]            xpi_awaddr, xpi_awaddr_dch1;

    wire [A_NPORTS*2*AXI_QOSW-1:0]                xpi_arqos, xpi_arqos_dch1;
    wire [A_NPORTS*2*RQOS_RW-1:0]                 xpi_rqos_priority, xpi_rqos_priority_dch1;

    wire [A_NPORTS*AXI_QOSW-1:0]                  xpi_awqos, xpi_awqos_dch1;
    wire [A_NPORTS*WQOS_TW-1:0]                   xpi_wqos_timeout, xpi_wqos_timeout_dch1;
    wire [A_NPORTS-1:0]                           xpi_awrmw, xpi_awrmw_dch1;

    wire [A_NPORTS*2-1:0]                         xpi_wurgent, xpi_rurgent;
    wire [A_NPORTS-1:0]                           xa_wpagematch, xa_rpagematch;  
    wire [A_NPORTS-1:0]                           xpi_vpw_expired, xpi_vpw_expired_dch1;
 
    wire [A_NPORTS*MEMC_WDATA_PTR_BITS-1:0]       xa_wdata_ptr, xa_wdata_ptr_dch1;
 
    wire [A_NPORTS*WRDATA_CYCLES-1:0]             xpi_wdata_mask_full, xpi_wdata_mask_full_dch1;  
 
    wire [A_NPORTS*AXI_QOSW-1:0]                  xpi_awqos_unused, xpi_awqos_dch1_unused;

   wire [MEMC_WDATA_PTR_BITS-1:0]                 hif_wdata_ptr_w, hif_wdata_ptr_w_dch1;
   
 

   // XPI Read Data Channel
   wire [INT_NPORTS_DATA-1:0]                     hif_rvalid;
   wire [INT_NPORTS_DATA*A_DW-1:0]                hif_hif_rdata;
   wire [INT_NPORTS_DATA*A_STRBW-1:0]             hif_hif_rdata_parity;
   wire [INT_NPORTS_DATA-1:0]                     hif_rlast_pkt;
   wire [INT_NPORTS_DATA*MEMC_TAGBITS-1:0]        e_resp_token;     
   wire [INT_NPORTS_DATA-1:0]                     hif_rerror;

   // XPI Write Response Channel
   wire [INT_NPORTS_DATA-1:0]                     hif_bvalid;
   wire [INT_NPORTS_DATA-1:0]                     xpi_bready;
   wire [INT_NPORTS_DATA-1:0]                     e_aw_slverr;
   wire [INT_NPORTS_DATA*AXI_IDW-1:0]             xpi_bid;
   wire [INT_NPORTS_DATA-1:0]                     e_bresp;
   wire [INT_NPORTS_DATA*AXI_USERW-1:0]           xpi_buser;
   wire [INT_NPORTS_DATA-1:0]                     hif_wready;
   
//`ifdef UMCTL2_DUAL_CHANNEL 
   // XPI Write Data Channel  
   wire [INT_NPORTS_DATA-1:0]                     xpi_wvalid_dch1;
   wire [INT_NPORTS_DATA-1:0]                     hif_wready_dch1;
   wire [INT_NPORTS_DATA*A_DW-1:0]                xpi_wdata_dch1;
   wire [INT_NPORTS_DATA*A_STRBW-1:0]             xpi_wstrb_dch1;
   wire [INT_NPORTS_DATA*A_PARW-1:0]              xpi_wparity_dch1;
   wire [INT_NPORTS_DATA-1:0]                     xpi_wlast_dch1;
   wire [INT_NPORTS_DATA*A_STRBW-1:0]             xpi_wpar_err_dch1;
   wire [INT_NPORTS_DATA-1:0]                     xpi_wlast_pkt_dch1;
   wire [INT_NPORTS_DATA-1:0]                     xpi_snf_mode_dch1;
   
   // XPI Read Data Channel
   wire [INT_NPORTS_DATA-1:0]                     hif_rvalid_dch1;
   wire [INT_NPORTS_DATA*A_DW-1:0]                hif_hif_rdata_dch1;
   wire [INT_NPORTS_DATA*A_STRBW-1:0]             hif_hif_rdata_parity_dch1;
   wire [INT_NPORTS_DATA-1:0]                     hif_rlast_pkt_dch1;
   wire [INT_NPORTS_DATA*MEMC_TAGBITS-1:0]        e_resp_token_dch1;
   wire [INT_NPORTS_DATA-1:0]                     hif_rerror_dch1;
   
   // XPI Write Response Channel
   wire [INT_NPORTS_DATA-1:0]                     hif_bvalid_dch1;
   wire [INT_NPORTS_DATA-1:0]                     xpi_bready_dch1;
   wire [INT_NPORTS_DATA-1:0]                     e_aw_slverr_dch1;
   wire [INT_NPORTS_DATA*AXI_IDW-1:0]             xpi_bid_dch1;
   wire [INT_NPORTS_DATA-1:0]                     e_bresp_dch1;
   wire [INT_NPORTS_DATA*AXI_USERW-1:0]           xpi_buser_dch1;   
//`endif //  `ifdef UMCTL2_DUAL_CHANNEL
   
//----------------------------------------------------------------------------------   
// pa_dual vs. hif_cmd and so on  internal wires
//----------------------------------------------------------------------------------

   wire [INT_NPORTS-1:0]                          pa_arvalid;
   wire [INT_NPORTS-1:0]                          pa_awvalid;
   wire [INT_NPORTS-1:0]                          pa_awrmw;
   wire [INT_NPORTS*HIF_ADDR_WIDTH-1:0]           pa_araddr; 
   wire [INT_NPORTS*HIF_ADDR_WIDTH-1:0]           pa_awaddr;
   wire [INT_NPORTS*AXI_QOSW-1:0]                 pa_awqos;
   wire [INT_NPORTS*AXI_QOSW-1:0]                 pa_arqos;
   wire [INT_NPORTS-1:0]                          pa_arpagematch;
      
   wire [INT_NPORTS-1:0]                          pa_wgrant;
   wire [INT_NPORTS-1:0]                          pa_rgrant;
   wire [INT_NPORTS-1:0]                          pa_rautopre;
   wire [INT_NPORTS-1:0]                          pa_wautopre;
   wire [INT_NPORTS*RQOS_TW-1:0]                  pa_rqos_timeout;
   wire [INT_NPORTS*RQOS_TW-1:0]                  pa_wqos_timeout;

   wire [INT_NPORTS*MEMC_TAGBITS-1:0]             pa_rtoken;
   wire [INT_NPORTS-1:0]                          pa_rurgent;
   wire [INT_NPORTS-1:0]                          pa_wurgent;
   wire [INT_NPORTS-1:0]                          pa_wpagematch;
   wire [INT_NPORTS*MEMC_WDATA_PTR_BITS-1:0]      pa_wdata_ptr;
   wire [INT_NPORTS-1:0]                          pa_vpr_expired;
   wire [INT_NPORTS-1:0]                          pa_vpw_expired;
   reg [INT_NPORTS-1:0]                           pa_rmask_int, pa_wmask_int;
   //wire                                        hif_rcmd_stall, hif_wcmd_stall;
   wire [INT_NPORTS*WRDATA_CYCLES-1:0]            pa_wdata_mask_full;
   wire [INT_NPORTS*EXA_PYLD_W-1:0]               pa_wexa_pyld;
   wire [INT_NPORTS*EXA_PYLD_W-1:0]               pa_rexa_pyld;  

   wire [INT_NPORTS*RQOS_RW-1:0]                  pa_rqos_priority;
   wire [INT_NPORTS*WQOS_RW-1:0]                  pa_wqos_priority;
 
   
   wire [A_NPORTS*2-1:0]                          hif_arready;
   wire [A_NPORTS-1:0]                            hif_awready;

   wire [INT_NPORTS-1:0]                          pa_exa_awlast; 
   wire [INT_NPORTS-1:0]                          pa_exa_short_burst;
   
   wire [INT_NPORTS*RQOS_RW-1:0]                  pa_rpri;
   wire [INT_NPORTS*WQOS_RW-1:0]                  pa_wpri;  

   wire [A_NPORTS*2-1:0]                          xpi_arpagematch;   
   wire [A_NPORTS-1:0]                            xpi_awpagematch;
   wire [A_NPORTS*2-1:0]                          xpi_arautopre;
   wire [A_NPORTS-1:0]                            xpi_awautopre;
   wire [A_NPORTS-1:0]                            xpi_exa_awlast;  
   wire [A_NPORTS-1:0]                            xpi_exa_short_burst;
   wire [A_NPORTS*CMD_LEN_BITS-1:0]               xpi_wlength;
   wire [A_NPORTS*2*CMD_LEN_BITS-1:0]             xpi_rlength;
   
   wire [INT_NPORTS*CMD_LEN_BITS-1:0]             xa_rlength;
   wire [INT_NPORTS*CMD_LEN_BITS-1:0]             xa_wlength;
   wire [A_NPORTS*2*EXA_PYLD_W-1:0]               xa_rexa_pyld;  
   wire [A_NPORTS*EXA_PYLD_W-1:0]                 xa_wexa_pyld;  
 
//`ifdef UMCTL2_DUAL_CHANNEL
   wire [INT_NPORTS-1:0]                          pa_arvalid_dch1; 
   wire [INT_NPORTS-1:0]                          pa_awvalid_dch1;
   wire [INT_NPORTS-1:0]                          pa_awrmw_dch1; 
   wire [INT_NPORTS*HIF_ADDR_WIDTH-1:0]           pa_araddr_dch1;
   wire [INT_NPORTS*HIF_ADDR_WIDTH-1:0]           pa_awaddr_dch1;
   wire [INT_NPORTS*AXI_QOSW-1:0]                 pa_awqos_dch1;
   wire [INT_NPORTS*AXI_QOSW-1:0]                 pa_arqos_dch1;
   wire [INT_NPORTS-1:0]                          pa_arpagematch_dch1;   
   
   wire [INT_NPORTS-1:0]                          pa_wgrant_dch1;
   wire [INT_NPORTS-1:0]                          pa_rgrant_dch1;
   wire [INT_NPORTS-1:0]                          pa_rautopre_dch1;
   wire [INT_NPORTS-1:0]                          pa_wautopre_dch1;  
   wire [INT_NPORTS*RQOS_TW-1:0]                  pa_rqos_timeout_dch1;
   wire [INT_NPORTS*RQOS_TW-1:0]                  pa_wqos_timeout_dch1;
   wire [INT_NPORTS*MEMC_TAGBITS-1:0]             pa_rtoken_dch1;
   wire [INT_NPORTS-1:0]                          pa_rurgent_dch1;
   wire [INT_NPORTS-1:0]                          pa_wurgent_dch1;
   wire [INT_NPORTS-1:0]                          pa_wpagematch_dch1;
   wire [INT_NPORTS*MEMC_WDATA_PTR_BITS-1:0]      pa_wdata_ptr_dch1;
   wire [INT_NPORTS-1:0]                          pa_vpr_expired_dch1;
   wire [INT_NPORTS-1:0]                          pa_vpw_expired_dch1; 
   reg [INT_NPORTS-1:0]                           pa_rmask_int_dch1, pa_wmask_int_dch1;
   //wire                                        hif_rcmd_stall_dch1, hif_wcmd_stall_dch1;
   wire [INT_NPORTS*WRDATA_CYCLES-1:0]            pa_wdata_mask_full_dch1;
   wire [INT_NPORTS*EXA_PYLD_W-1:0]               pa_wexa_pyld_dch1;
   wire [INT_NPORTS*EXA_PYLD_W-1:0]               pa_rexa_pyld_dch1;   

   wire [INT_NPORTS*RQOS_RW-1:0]                  pa_rqos_priority_dch1; 
   wire [INT_NPORTS*WQOS_RW-1:0]                  pa_wqos_priority_dch1; 

   
   wire [A_NPORTS*2-1:0]                          hif_arready_dch1;
   wire [A_NPORTS-1:0]                            hif_awready_dch1;

   wire [INT_NPORTS-1:0]                          pa_exa_awlast_dch1;
   wire [INT_NPORTS-1:0]                          pa_exa_short_burst_dch1;
   
   wire [INT_NPORTS*RQOS_RW-1:0]                  pa_rpri_dch1;
   wire [INT_NPORTS*WQOS_RW-1:0]                  pa_wpri_dch1;   

   wire [A_NPORTS*2-1:0]                          xpi_arpagematch_dch1;   
   wire [A_NPORTS*2-1:0]                          xpi_arautopre_dch1;
   wire [A_NPORTS-1:0]                            xpi_awpagematch_dch1;
   wire [A_NPORTS-1:0]                            xpi_awautopre_dch1;
   wire [A_NPORTS-1:0]                            xpi_exa_awlast_dch1;
   wire [A_NPORTS-1:0]                            xpi_exa_short_burst_dch1; 
   wire [A_NPORTS*CMD_LEN_BITS-1:0]               xpi_wlength_dch1;

   wire [INT_NPORTS*CMD_LEN_BITS-1:0]             xa_rlength_dch1;
   wire [INT_NPORTS*CMD_LEN_BITS-1:0]             xa_wlength_dch1;    
   wire [A_NPORTS*2*EXA_PYLD_W-1:0]               xa_rexa_pyld_dch1;
   wire [A_NPORTS*EXA_PYLD_W-1:0]                 xa_wexa_pyld_dch1;

   wire [A_NPORTS*WQOS_RW-1:0]                    xpi_wqos_priority, xpi_wqos_priority_dch1;
   wire [A_NPORTS*WQOS_RW-1:0]                    xpi_wqos_priority_unused, xpi_wqos_priority_dch1_unused;

    
   wire [INT_NPORTS*REG_PORT_PRIORITYW-1:0]       reg_wr_port_priority_pa;
   wire [INT_NPORTS-1:0]                          reg_wr_port_aging_en_pa;
   wire [INT_NPORTS-1:0]                          reg_wr_port_urgent_en_pa;
   wire [INT_NPORTS*REG_PORT_PRIORITYW-1:0]       reg_rd_port_priority_pa;
   wire [INT_NPORTS-1:0]                          reg_rd_port_aging_en_pa;
   wire [INT_NPORTS-1:0]                          reg_rd_port_urgent_en_pa;
   wire [HIF_ADDR_WIDTH-1:0] addr_mask_cs_b0,addr_mask_cs_b0_alt_unused;
   wire [HIF_ADDR_WIDTH-1:0] addr_mask_cs_b1,addr_mask_cs_b1_alt_unused;

   localparam LUT_SEL_NUM = (3*A_NPORTS)+`UMCTL2_SBR_EN+((`UMCTL2_SBR_EN==1)? `UMCTL2_DUAL_CHANNEL_EN : 0);

   logic [LUT_SEL_NUM-1:0]                                        addrmap_lut_valid;
   logic [LUT_SEL_NUM-1:0] [`DDRCTL_LUT_ADDRMAP_CS_WIN_BITS-1:0]  addrmap_lut_addr;
   logic [LUT_SEL_NUM-1:0] [1:0]                                  addrmap_lut_cs;

   logic [LUT_SEL_NUM-1:0] [`DDRCTL_LUT_ADDRMAP_CS_WIN_BITS-1:0]  lut_sel;

  
//`endif //  `ifdef UMCTL2_DUAL_CHANNEL

   //genvar j;
   generate
      for (genvar j=0; j< A_NPORTS; j=j+1) begin : arb_port


   DWC_ddr_umctl2_xpi
    
     #(.M_DW                        (M_DW),
       .M_DW_INT                    (M_DW_INT),
       .A_DW                        (A_DW),
       .A_STRBW                     (A_STRBW),
       .A_PARW                      (A_PARW),
       .M_ADDRW                     (M_ADDRW),
       .NAB                         (NAB),
       .M_BLW                       (M_BLW), 
       .M_ECC                       (M_ECC),
       .M_SIDEBAND_ECC              (M_SIDEBAND_ECC),
       .M_INLINE_ECC                (M_INLINE_ECC),
       .SBR_EN                      (SBR_EN),
       .MEMC_HIF_ADDR_WIDTH_MAX     (MEMC_HIF_ADDR_WIDTH_MAX),
       .NBEATS                      (NBEATS),
       .M_LPDDR3                    (M_LPDDR3),
       .M_DDR5                      (M_DDR5),
       .M_USE_RMW                   (M_USE_RMW),     
       .AXI_ADDRW                   (AXI_ADDRW),   
       .AXI_IDW                     (AXI_IDW),
       .AXI_LENW                    (AXI_LENW),
       .AXI_SIZEW                   (AXI_SIZEW),
       .AXI_BURSTW                  (AXI_BURSTW),
       .AXI_LOCKW_FIX               (AXI_LOCKW_FIX),
       .AXI_USERW                   (AXI_USERW),
       .AXI_CACHEW                  (AXI_CACHEW),
       .AXI_PROTW                   (AXI_PROTW),
       .AXI_QOSW                    (AXI_QOSW),
       .AXI_RESPW                   (AXI_RESPW),
       .XPI_RMW_WDQD                (XPI_RMW_WDQD),
       .XPI_SQD                     (XPI_SQD),
       .LOWPWR_NOPX_CNT             (LOWPWR_NOPX_CNT),
       .OUTS_WRW                    (OUTS_WRW),
       .OUTS_RDW                    (OUTS_RDW),
       .MEMC_NO_OF_ENTRY            (MEMC_NO_OF_ENTRY),
       .MEMC_BURST_LENGTH           (MEMC_BURST_LENGTH),
       .MEMC_WDATA_PTR_BITS         (MEMC_WDATA_PTR_BITS),
       .USE_WAR                     (USE_WAR),
       .USE_RAR                     (USE_RAR),
       .USE_RDR                     (USE_RDR),
       .USE_RPR                     (USE_RPR),
       .RMW_WARD                    (RMW_WARD),
       .RARD                        (RARD),
       .WARD                        (WARD),
       .USE_INPUT_RAR               (USE_INPUT_RAR),
       .BRW                         (BRW),
       .DBW                         (DBW),
       .AMCOLW                      (AMCOLW_L),
       .AMCOLW_C3                   (AMCOLW_C3),
       .AMCSW                       (AMCSW),
       .DDRCTL_LUT_ADDRMAP_EN       (DDRCTL_LUT_ADDRMAP_EN),
       .UMCTL2_HET_RANK_EN          (UMCTL2_HET_RANK_EN),
       .OCPAR_EN                    (OCPAR_EN),
       .OCPAR_SLICE_WIDTH           (OCPAR_SLICE_WIDTH),
       .OCPAR_NUM_BYTES             (OCPAR_NUM_BYTES),
       .OCPAR_NUM_BYTES_LG2         (OCPAR_NUM_BYTES_LG2),
       .OCPAR_ADDR_PAR_WIDTH        (OCPAR_ADDR_PAR_WIDTH),
       .DUAL_CHANNEL                (DUAL_CHANNEL),
       .DATA_CHANNEL_INTERLEAVE     (DATA_CHANNEL_INTERLEAVE),
       .DDRCTL_HET_INTERLEAVE       (DDRCTL_HET_INTERLEAVE),
       .ECC_RM_WIDTH                (ECC_RM_WIDTH),
       .ECC_RMG_WIDTH               (ECC_RMG_WIDTH),
       .ECC_H3_WIDTH                (ECC_H3_WIDTH),
       .OCCAP_EN                    (OCCAP_EN),
       .OCCAP_PIPELINE_EN           (OCCAP_PIPELINE_EN),
       .OCECC_EN                    (OCECC_EN),
       .OCECC_XPI_WR_IN_GRANU       (OCECC_XPI_WR_IN_GRANU),
       .OCECC_XPI_RD_GRANU          (OCECC_XPI_RD_GRANU),
       .OCECC_MR_RD_GRANU           (OCECC_MR_RD_GRANU),
       .OCECC_MR_BNUM_WIDTH         (OCECC_MR_BNUM_WIDTH),       
       .PA_OPT_TYPE                 (PA_OPT_TYPE),
       .A_NPORTS_LG2                (A_NPORTS_LG2),
       .WDATA_PTR_QD                (WDATA_PTR_QD),
       .RQOS_MLW                    (RQOS_MLW),
       .RQOS_RW                     (RQOS_RW),
       .RQOS_TW                     (RQOS_TW),
       .WQOS_MLW                    (WQOS_MLW),
       .WQOS_RW                     (WQOS_RW),
       .WQOS_TW                     (WQOS_TW),
       .EXA_ACC_SUPPORT             (EXA_ACC_SUPPORT),
       .EXA_PYLD_W                  (EXA_PYLD_W),
       .EXA_MAX_LENW                (EXA_MAX_LENW),
       .EXA_MAX_SIZEW               (EXA_MAX_SIZEW),
       .EXA_MAX_ADDRW               (EXA_MAX_ADDRW),
       .ID_MAPW                     (ID_MAPW),
       .CMD_LEN_BITS                (CMD_LEN_BITS),
       .BEAT_INFOW                  (BEAT_INFOW),
       .AXI_SAR_BW                  (AXI_SAR_BW),
       .AXI_SAR_SW                  (AXI_SAR_SW),
       .USE_SAR                     (USE_SAR),
       .NSAR                        (NSAR),
       .SAR_MIN_ADDRW               (SAR_MIN_ADDRW),
       .RDATARAM_DW                 (RDATARAM_DW),
       .RDATARAM_AW                 (RDATARAM_AW),
       .RDATARAM_DEPTH              (RDATARAM_DEPTH),
       .DATARAM_PAR_DW              (DATARAM_PAR_DW),
       .AXI_ADDR_BOUNDARY           (AXI_ADDR_BOUNDARY),
       .UMCTL2_PARTIAL_WR_EN        (UMCTL2_PARTIAL_WR_EN),
       .MEMC_DDR4_EN                (MEMC_DDR4_EN),
       .BCM_VERIF_EN                (BCM_VERIF_EN),
       .HWFFC_EN                    (HWFFC_EN),
       .IH_TE_PIPELINE              (IH_TE_PIPELINE),
       .XPI_USE_RMWR_EN             (XPI_USE_RMWR_EN),
       // from here are unique parameter for every axi port!!!
       .A_DW_INT                    (A_DW_INT_TABLE[MAX_A_DW_INT_NB*(j+1)-1:MAX_A_DW_INT_NB*j]),
       .A_STRBW_INT                 (A_STRBW_INT_TABLE[MAX_A_STRBW_INT_NB*(j+1)-1:MAX_A_STRBW_INT_NB*j]),
       .A_PARW_INT                  (A_PARW_INT_TABLE[MAX_A_PARW_INT_NB*(j+1)-1:MAX_A_PARW_INT_NB*j]),
       .AXI_DATAW                   (AXI_DATAW_PRA_TABLE[AXI_DW_NB*(j+1)-1:AXI_DW_NB*j]),      //new
       .AXI_STRBW                   (AXI_STRBW_PRA_TABLE[AXI_STRBW_NB*(j+1)-1:AXI_STRBW_NB*j]),//new
       .AXI_LOCKW                   (AXI_LOCKW_PRA_TABLE[AXI_LOCKW_NB*(j+1)-1:AXI_LOCKW_NB*j]),//new
       .AXI_WAQD                    (AXI_WAQD_TABLE[MAX_AXI_WAQD_NB*(j+1)-1:MAX_AXI_WAQD_NB*j]),
       .AXI_WAQD_LG2                (AXI_WAQD_LG2_PRA_TABLE[AXI_WAQD_LG2_NB*(j+1)-1:AXI_WAQD_LG2_NB*j]),//new
       .AXI_WDQD                    (AXI_WDQD_TABLE[MAX_AXI_WDQD_NB*(j+1)-1:MAX_AXI_WDQD_NB*j]),     
       .AXI_RAQD                    (AXI_RAQD_TABLE[MAX_AXI_RAQD_NB*(j+1)-1:MAX_AXI_RAQD_NB*j]),
       .AXI_RAQD_LG2                (AXI_RAQD_LG2_PRA_TABLE[AXI_RAQD_LG2_NB*(j+1)-1:AXI_RAQD_LG2_NB*j]), //new
       .AXI_RDQD                    (AXI_RDQD_TABLE[MAX_AXI_RDQD_NB*(j+1)-1:MAX_AXI_RDQD_NB*j]),
       .AXI_WRQD                    (AXI_WRQD_TABLE[MAX_AXI_WRQD_NB*(j+1)-1:MAX_AXI_WRQD_NB*j]),            
       .AXI_SYNC                    (AXI_SYNC_TABLE[MAX_AXI_SYNC_NB*(j+1)-1:MAX_AXI_SYNC_NB*j]),       
       .RINFOW                      (RINFOW_TABLE[MAX_RINFOW_NB*(j+1)-1:MAX_RINFOW_NB*j]),     
       .RINFOW_NSA                  (RINFOW_NSA_TABLE[MAX_RINFOW_NSA_NB*(j+1)-1:MAX_RINFOW_NSA_NB*j]),
       .WINFOW                      (WINFOW_TABLE[MAX_WINFOW_NB*(j+1)-1:MAX_WINFOW_NB*j]),     
       .RPINFOW                     (RPINFOW_TABLE[MAX_RPINFOW_NB*(j+1)-1:MAX_RPINFOW_NB*j]),     
       .MEMC_TAGBITS                (AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]),
       .ASYNC_FIFO_N_SYNC           (ASYNC_FIFO_N_SYNC_TABLE[MAX_ASYNC_FIFO_N_SYNC_NB*(j+1)-1:MAX_ASYNC_FIFO_N_SYNC_NB*j]),
       .ASYNC_FIFO_EARLY_PUSH_STAT  (ASYNC_FIFO_EARLY_PUSH_STAT_TABLE[MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB*(j+1)-1:MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB*j]),
       .ASYNC_FIFO_EARLY_POP_STAT   (ASYNC_FIFO_EARLY_POP_STAT_TABLE[MAX_ASYNC_FIFO_EARLY_POP_STAT_NB*(j+1)-1:MAX_ASYNC_FIFO_EARLY_POP_STAT_NB*j]),
       .AP_ASYNC                    (AP_ASYNC_TABLE[MAX_AP_ASYNC_NB*(j+1)-1:MAX_AP_ASYNC_NB*j]),
       .DATA_CHANNEL_INTERLEAVE_NS  (DATA_CHANNEL_INTERLEAVE_NS_TABLE[MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*(j+1)-1:MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*j]),       
       .A_PORT_NUM                  (A_PORT_NUM_TABLE[MAX_A_PORT_NUM_NB*(j+1)-1:MAX_A_PORT_NUM_NB*j]),
       .VPR_EN                      (VPR_EN_TABLE[MAX_VPR_EN_NB*(j+1)-1:MAX_VPR_EN_NB*j]),
       .VPW_EN                      (VPW_EN_TABLE[MAX_VPW_EN_NB*(j+1)-1:MAX_VPW_EN_NB*j]),
       .USE2RAQ                     (USE2RAQ_TABLE[MAX_USE2RAQ_NB*(j+1)-1:MAX_USE2RAQ_NB*j]),
       .NUM_VIR_CH                  (NUM_VIR_CH_TABLE[MAX_NUM_VIR_CH_NB*(j+1)-1:MAX_NUM_VIR_CH_NB*j]),
       .STATIC_VIR_CH               (STATIC_VIR_CH_TABLE[MAX_STATIC_VIR_CH_NB*(j+1)-1:MAX_STATIC_VIR_CH_NB*j]),       
       .RRB_EXTRAM                  (RRB_EXTRAM_TABLE[MAX_RRB_EXTRAM_NB*(j+1)-1:MAX_RRB_EXTRAM_NB*j]),
       .XPI_SMALL_SIZED_PORT        (XPI_SMALL_SIZED_PORT_TABLE[MAX_RRB_EXTRAM_NB*(j+1)-1:MAX_SMALL_SIZED_PORT_NB*j]),
       .RRB_EXTRAM_REG              (RRB_EXTRAM_REG_TABLE[MAX_RRB_EXTRAM_REG_NB*(j+1)-1:MAX_RRB_EXTRAM_REG_NB*j]),
       .RRB_EXTRAM_RETIME           (RRB_EXTRAM_RETIME_TABLE[MAX_RRB_EXTRAM_RETIME_NB*(j+1)-1:MAX_RRB_EXTRAM_RETIME_NB*j]),
       .RDWR_ORDERED                (RDWR_ORDERED_TABLE[MAX_RDWR_ORDERED_NB*(j+1)-1:MAX_RDWR_ORDERED_NB*j]),
       .RRB_THRESHOLD_EN            (RRB_THRESHOLD_EN_TABLE[MAX_RRB_THRESHOLD_EN_NB*(j+1)-1:MAX_RRB_THRESHOLD_EN_NB*j]),
       .RRB_THRESHOLD_PPL           (RRB_THRESHOLD_PPL_TABLE[MAX_RRB_THRESHOLD_EN_NB*(j+1)-1:MAX_RRB_THRESHOLD_EN_NB*j]),
       .RRB_LOCK_THRESHOLD_WIDTH    (RRB_LOCK_THRESHOLD_WIDTH),
       .READ_DATA_INTERLEAVE_EN     (READ_DATA_INTERLEAVE_EN_TABLE[MAX_READ_DATA_INTERLEAVE_EN_NB*(j+1)-1:MAX_READ_DATA_INTERLEAVE_EN_NB*j]))
    
   U_xpi  (
      .aclk                         (aclk_vector[j]),            // AXI clock
      .aresetn                      (aresetn_vector[j]),         // AXI asynchronous reset
      //.sync_aresetn                 (sync_aresetn_vector[j]),    // synchronous presetn to aclk (if async), otherwise copy of aresetn, newly removed !!!
            .csysreq                      (csysreq_xpi_vector[j]),     // AXI low-power request
            .csysack                      (csysack_xpi_vector[j]),     // AXI low-power request acknol'g
            .cactive                      (cactive_xpi_vector[j]),     // AXI clock active
            .cactive_out                  (cactive_out_vector[j]),     // Internal busy status, to drive uPCTL cactive_in 
            .rd_port_busy                 (rd_port_busy_vector[j]),    // XPI read channel is busy
            .wr_port_busy                 (wr_port_busy_vector[j]),    // XPI write channel is busy

            .reg_ddrc_burst_rdwr          (reg_ddrc_burst_rdwr_int),
            .reg_ddrc_data_bus_width      (reg_ddrc_data_bus_width),
            .reg_arba_data_bus_width      (reg_arba_data_bus_width_vector[(j*DBW) +: DBW]),
            .reg_ddrc_burstchop           (reg_ddrc_burstchop),
            .reg_ddrc_wr_crc_enable       (reg_ddrc_wr_crc_enable),
            .reg_ddrc_col_addr_shift      (reg_ddrc_col_addr_shift),
            .reg_xpi_snf_mode             (reg_xpi_snf_mode_vector[j]),
            .reg_ddrc_active_ranks        ({MEMC_NUM_RANKS{1'b0}}),
            .reg_ddrc_alt_addrmap_en      (1'b0),
            .reg_ddrc_addrmap_cs_bit0     ({AMCSW{1'b0}}),
            .reg_ddrc_addrmap_cs_bit1     ({AMCSW{1'b0}}),
            .reg_ddrc_addrmap_col_b2_alt  ({AMCOLW_L{1'b0}}),
            .reg_ddrc_addrmap_col_b3_alt  ({AMCOLW_C3{1'b0}}),   
            .reg_arb_dch_density_ratio    (2'b00),
            .reg_ddrc_addrmap_col_b2      (reg_ddrc_addrmap_col_b2),
            .reg_ddrc_addrmap_col_b3      (reg_ddrc_addrmap_col_b3),
     
            .reg_arb_bl_exp_mode          (reg_arb_bl_exp_mode),
            .reg_arb_port_en              (reg_arb_port_en_vector[j]),
            .reg_arb_bypass_reorder       (reg_arb_bypass_reorder_vector[j]),                          // enable bypass reorder 
            .reg_arb_id_mask              (reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(j+2)-1:ARB_ID_NB*(j+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(j+1)-1:ARB_ID_NB*j]]),                                        // Virtual channels id mask !!!!!
            .reg_arb_id_value             (reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(j+2)-1:ARB_ID_NB*(j+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(j+1)-1:ARB_ID_NB*j]]),                                       // Virtual channels id value  !!!!   
   
             // occap configuration    
            .reg_arb_occap_arb_cmp_poison_seq       (reg_arb_occap_arb_cmp_poison_seq_vector[j]),      // IO input from DWC_ddr_umctl2_occap_reg_arb,   
            .reg_arb_occap_arb_cmp_poison_parallel  (reg_arb_occap_arb_cmp_poison_parallel_vector[j]), // IO input from DWC_ddr_umctl2_occap_reg_arb,
            .reg_arb_occap_arb_cmp_poison_err_inj   (reg_arb_occap_arb_cmp_poison_err_inj_vector[j]),  // IO input from DWC_ddr_umctl2_occap_reg_arb,
            .reg_arb_occap_arb_raq_poison_en        (reg_arb_occap_arb_raq_poison_en_vector[j]),       // IO input from DWC_ddr_umctl2_occap_reg_arb,

            //newly added ocecc IF inputs
            .ocecc_en                           (ocecc_en_aclk_vector[j]),
            .ocecc_poison_egen_mr_rd_0          (ocecc_poison_egen_mr_rd_0_vector[j]),
            .ocecc_poison_egen_mr_rd_0_byte_num (ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(j+1)-1 -: OCECC_MR_BNUM_WIDTH]),
            .ocecc_poison_egen_xpi_rd_out       (ocecc_poison_egen_xpi_rd_out_vector[j]),
            .ocecc_poison_single                (ocecc_poison_single_vector[j]),
            .ocecc_wdata_slverr_en              (ocecc_wdata_slverr_en_vector[j]),
            .ocecc_rdata_slverr_en              (ocecc_rdata_slverr_en_vector[j]),
   

            .reg_arb_oc_parity_en               (oc_parity_en_aclk_vector[j]),       //define this input from 0 ~ 15 from DWC_ddr_umctl2_ocpar_reg_arb
            .reg_arb_oc_parity_type             (oc_parity_type_aclk_vector[j]),     //define this input from 0 ~ 15 from DWC_ddr_umctl2_ocpar_reg_arb 
            .reg_arb_par_addr_slverr_en         (par_addr_slverr_en_aclk_vector[j]), //define this input from 0 ~ 15 from DWC_ddr_umctl2_ocpar_reg_ar            
            .reg_arb_par_rdata_slverr_en        (par_rdata_slverr_en_vector[j]),     //define this input from 0 ~ 15 from DWC_ddr_umctl2_ocpar_reg_ar
 
            .rd_poison_en                       (rd_poison_en_vector[j]),                        // IO
            .wr_poison_en                       (wr_poison_en_vector[j]),                        // IO
            .par_wdata_err_intr_clr             (par_wdata_err_intr_clr_vector[j]),              // IO
            .par_rdata_err_intr_clr             (par_rdata_err_intr_clr_vector[j]),              // IO

            .par_wdata_axi_check_bypass_en      (par_wdata_axi_check_bypass_en),
    
            // interface to AXI write address channel
            .awid                         (awid_vector_int[AXI_IDW*(j+1)-1:AXI_IDW*j]),          // AXI write address ID
            .awaddr                       (awaddr_vector_int[AXI_ADDRW*(j+1)-1:AXI_ADDRW*j]),    // AXI write address
            .awlen                        (awlen_vector_int[AXI_LENW*(j+1)-1:AXI_LENW*j]),       // AXI write burst length
            .awsize                       (awsize_vector_int[AXI_SIZEW*(j+1)-1:AXI_SIZEW*j]),    // AXI write burst size
            .awburst                      (awburst_vector_int[AXI_BURSTW*(j+1)-1:AXI_BURSTW*j]),  // AXI write burst type
            .awlock                       (awlock_vector_int[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(j+2)-1:AXI_LOCKW_NB*(j+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(j+1)-1:AXI_LOCKW_NB*j]]),                                            // AXI write lock type ????!!!
            .awcache                      (awcache_vector_int[AXI_CACHEW*(j+1)-1:AXI_CACHEW*j]),  // AXI write cache type
            .awprot                       (awprot_vector_int[AXI_PROTW*(j+1)-1:AXI_PROTW*j]),     // AXI write protection type
            .awuser                       (awuser_vector[AXI_USERW*(j+1)-1:AXI_USERW*j]),
            .awqos                        (awqos_vector[AXI_QOSW*(j+1)-1:AXI_QOSW*j]),              // AXI write Quality of Service
            .awurgent                     (awurgent_vector[j]), // AXI write urgent transactions
            .awvalid                      (awvalid_vector_int[j]),  // AXI write address valid
            .awpoison                     (awpoison_vector[j]), // AXI write poison
            .awautopre                    (awautopre_vector[j]), // AXI write auto precharge
            .awparity                     (awparity_vector[OCPAR_ADDR_PAR_WIDTH*(j+1)-1:OCPAR_ADDR_PAR_WIDTH*j]),
            .awready                      (awready_vector_int[j]),  // AXI write address ready

            // interface to AXI write data channel
            .wid                          (wid_vector_int[AXI_IDW*(j+1)-1:AXI_IDW*j]),      // AXI write ID
            .wdata                        (wdata_vector_int[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(j+2)-1:AXI_DW_NB*(j+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(j+1)-1:AXI_DW_NB*j]]),         // AXI write data           //!!!!
            .wparity                      (wparity_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(j+2)-1:AXI_STRBW_NB*(j+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(j+1)-1:AXI_STRBW_NB*j]]),           // AXI write data parity    //!!!!
            .wstrb                        (wstrb_vector_int[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(j+2)-1:AXI_STRBW_NB*(j+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(j+1)-1:AXI_STRBW_NB*j]]),         // AXI write strobes        //!!!!
            .wlast                        (wlast_vector_int[j]),    // AXI write last
            .wvalid                       (wvalid_vector_int[j]),   // AXI write valid
            .wready                       (wready_vector_int[j]),   // AXI write ready
            .wuser                        (wuser_vector[AXI_USERW*(j+1)-1:AXI_USERW*j]),
    
            // interface to AXI write response channel
            .bid                          (bid_vector_int[AXI_IDW*(j+1)-1:AXI_IDW*j]),       // AXI write response ID
            .bresp                        (bresp_vector_int[AXI_RESPW*(j+1)-1:AXI_RESPW*j]),     // AXI write response
            .buser                        (buser_vector[AXI_USERW*(j+1)-1:AXI_USERW*j]),
            .bvalid                       (bvalid_vector_int[j]),    // AXI write response valid
            .bready                       (bready_vector_int[j]),    // AXI write response ready

            // interface to AXI read address channel
            .arid                         (arid_vector_int[AXI_IDW*(j+1)-1:AXI_IDW*j]),            // AXI read address ID
            .araddr                       (araddr_vector_int[AXI_ADDRW*(j+1)-1:AXI_ADDRW*j]),      // AXI read address
            .arlen                        (arlen_vector_int[AXI_LENW*(j+1)-1:AXI_LENW*j]),         // AXI read burst length
            .arsize                       (arsize_vector_int[AXI_SIZEW*(j+1)-1:AXI_SIZEW*j]),      // AXI read burst size
            .arburst                      (arburst_vector_int[AXI_BURSTW*(j+1)-1:AXI_BURSTW*j]),    // AXI read burst type
            .arlock                       (arlock_vector_int[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(j+2)-1:AXI_LOCKW_NB*(j+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(j+1)-1:AXI_LOCKW_NB*j]]),                                              // AXI read lock type !!!
            .arcache                      (arcache_vector_int[AXI_CACHEW*(j+1)-1:AXI_CACHEW*j]),     // AXI read cache type
            .arprot                       (arprot_vector_int[AXI_PROTW*(j+1)-1:AXI_PROTW*j]),       // AXI read protection type
            .aruser                       (aruser_vector[AXI_USERW*(j+1)-1:AXI_USERW*j]),
            .arqos                        (arqos_vector[AXI_QOSW*(j+1)-1:AXI_QOSW*j]),              // AXI read Quality of Servicer
            .arurgentb                    (arurgentb_vector[j]),                                    // AXI read urgent transactions
            .arurgentr                    (arurgentr_vector[j]),                                    // AXI read urgent transactions
            .arvalid                      (arvalid_vector_int[j]),                                  // AXI read address valid
            .arpoison                     (arpoison_vector[j]),                                     // AXI read poison
            .arautopre                    (arautopre_vector[j]),                                    // AXI read auto precharge
            .arparity                     (arparity_vector[OCPAR_ADDR_PAR_WIDTH*(j+1)-1:OCPAR_ADDR_PAR_WIDTH*j]),
            .arready                      (arready_vector_int[j]),                                  // AXI read address ready

            // interface to AXI read data channel
            .rid                          (rid_vector_int[AXI_IDW*(j+1)-1:AXI_IDW*j]),      // AXI read ID
            .rdata                        (rdata_vector_int[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(j+2)-1:AXI_DW_NB*(j+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(j+1)-1:AXI_DW_NB*j]]),                                        // AXI read data !!!!
            .rparity                      (rparity_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(j+2)-1:AXI_STRBW_NB*(j+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(j+1)-1:AXI_STRBW_NB*j]]),                                      // read data parity !!!
            .rresp                        (rresp_vector_int[AXI_RESPW*(j+1)-1:AXI_RESPW*j]),    // AXI read response
            .ruser                        (ruser_vector[AXI_USERW*(j+1)-1:AXI_USERW*j]),
            .rlast                        (rlast_vector_int[j]),    // AXI read last
            .rvalid                       (rvalid_vector_int[j]),   // AXI read valid
            .rready                       (rready_vector_int[j]),   // AXI read ready    

            // Extended Native Interface:
            .e_clk                        (core_ddrc_core_clk), // ENIF clock
            .e_rst_n                      (core_ddrc_rstn),     // ENIF asynchronous reset
    
            // ENIF Write Address channel 0
            .xpi_awaddr                   (xpi_awaddr[HIF_ADDR_WIDTH*(j+1)-1 -: HIF_ADDR_WIDTH]), // XPI write address 
            .xpi_awrmw                    (xpi_awrmw[j]),                                         // XPI write read modify write
            .xpi_awqos                    (xpi_awqos[AXI_QOSW*(j+1)-1 -: AXI_QOSW]),              // XPI write address qos
            .xpi_awpagematch              (xpi_awpagematch[j]),                                   // XPI write page match 
            .xpi_awautopre                (xpi_awautopre[j]),                                     // XPI write auto precharge
            .xpi_exa_awlast               (xpi_exa_awlast[j]),                                    // XPI last valid address
            .xpi_exa_short_burst          (xpi_exa_short_burst[j]),                               // short wrap burst
    
            // ENIF Write Address channel 1
            .xpi_awaddr_dcb                (xpi_awaddr_dch1[HIF_ADDR_WIDTH*(j+1)-1 -: HIF_ADDR_WIDTH]), // XPI write address 
            .xpi_awrmw_dcb                 (xpi_awrmw_dch1[j]),                                         // XPI write read modify write
            .xpi_awqos_dcb                 (xpi_awqos_dch1[AXI_QOSW*(j+1)-1 -: AXI_QOSW]),              // XPI write address qos
            .xpi_awpagematch_dcb           (xpi_awpagematch_dch1[j]),                                   // XPI write page match 
            .xpi_awautopre_dcb             (xpi_awautopre_dch1[j]),
            .xpi_exa_awlast_dcb            (xpi_exa_awlast_dch1[j]),                                    // XPI last valid address
            .xpi_exa_short_burst_dcb       (xpi_exa_short_burst_dch1[j]),                               // short wrap burst
    
            .xpi_wdata_mask_full           (xpi_wdata_mask_full[WRDATA_CYCLES*(j+1)-1 -: WRDATA_CYCLES]),
            .xpi_wdata_mask_full_dcb       (xpi_wdata_mask_full_dch1[WRDATA_CYCLES*(j+1)-1 -: WRDATA_CYCLES]),
            .xpi_rxcmd_wlength             (xpi_wlength[CMD_LEN_BITS*(j+1)-1 -: CMD_LEN_BITS]),
            .xpi_rxcmd_wlength_dcb         (xpi_wlength_dch1[CMD_LEN_BITS*(j+1)-1 -: CMD_LEN_BITS]),
            // first channel
            .xpi_awvalid_dca               (xpi_awvalid[j]),                                            // XPI write address valid
            .hif_awready_dca               (hif_awready[j]),                                            // HIF write address ready
            // second channel
            .xpi_awvalid_dcb               (xpi_awvalid_dch1[j]),                                       // XPI write address valid
            .hif_awready_dcb               (hif_awready_dch1[j]),                                       // HIF write address ready
            .xpi_wqos_priority             (xpi_wqos_priority[WQOS_RW*(j+1)-1: WQOS_RW*j]),
            .xpi_wqos_timeout              (xpi_wqos_timeout[WQOS_TW*(j+1)-1: WQOS_TW*j]),
            .xpi_vpw_expired               (xpi_vpw_expired[j]),

            .xpi_wqos_priority_dcb         (xpi_wqos_priority_dch1[WQOS_RW*(j+1)-1: WQOS_RW*j]),
            .xpi_wqos_timeout_dcb          (xpi_wqos_timeout_dch1[WQOS_TW*(j+1)-1: WQOS_TW*j]),
            .xpi_vpw_expired_dcb           (xpi_vpw_expired_dch1[j]),

            // ENIF Read Address channel
            // channel 0
            .xpi_araddr_blue               (xpi_araddr[HIF_ADDR_WIDTH*(j*2) +: HIF_ADDR_WIDTH]),               // XPI read address
            .xpi_arqos_blue                (xpi_arqos[AXI_QOSW*(j*2) +: AXI_QOSW]),                     // XPI read address qos
            .xpi_rqos_priority_blue        (xpi_rqos_priority[RQOS_RW*(j*2) +: RQOS_RW]),
            .xpi_rqos_timeout_blue         (xpi_rqos_timeout[RQOS_TW*(j*2) +: RQOS_TW]),    
            .xpi_vpr_expired_blue          (xpi_vpr_expired[j*2]),
            .xpi_arpagematch_blue          (xpi_arpagematch[j*2]),                                            // XPI write page match
            .xpi_arautopre_blue            (xpi_arautopre[j*2]),                                              // XPI write auto precharge

            // channel 1
            .xpi_araddr_blue_dcb           (xpi_araddr_dch1[HIF_ADDR_WIDTH*(j*2) +: HIF_ADDR_WIDTH]),         // XPI read address
            .xpi_arqos_blue_dcb            (xpi_arqos_dch1[AXI_QOSW*(j*2) +: AXI_QOSW]),                    // XPI read address qos
            .xpi_rqos_priority_blue_dcb    (xpi_rqos_priority_dch1[RQOS_RW*(j*2) +: RQOS_RW]),
            .xpi_rqos_timeout_blue_dcb     (xpi_rqos_timeout_dch1[RQOS_TW*(j*2) +: RQOS_TW]),
            .xpi_vpr_expired_blue_dcb      (xpi_vpr_expired_dch1[j*2]),
            .xpi_arpagematch_blue_dcb      (xpi_arpagematch_dch1[j*2]),                                            // XPI write page match
            .xpi_arautopre_blue_dcb        (xpi_arautopre_dch1[j*2]),
            // first channel
            .xpi_arvalid_blue_dca          (xpi_arvalid[j*2]),                                                     // XPI read address valid
            .hif_arready_blue_dca          (hif_arready[2*j]),                                                     // XPI read address ready
            .hif_arready_red_dca           (hif_arready[2*j+1]),                                                   // XPI read address ready
            // second channel
            .xpi_arvalid_blue_dcb          (xpi_arvalid_dch1[j*2]),                                                // XPI read address valid
            .hif_arready_blue_dcb          (hif_arready_dch1[2*j]),                                                // XPI read address ready
            .hif_arready_red_dcb           (hif_arready_dch1[2*j+1]),                                              // XPI read address ready
  
            // ENIF Write Data Channel
            // channel 0
            .xpi_wdata                     (xpi_wdata[A_DW*(j+1)-1 -: A_DW]),                                      // XPI write data
            .xpi_wstrb                     (xpi_wstrb[A_STRBW*(j+1)-1 -: A_STRBW]),                                // XPI write data strobe
            .xpi_wlast                     (xpi_wlast[j]),                                                         // XPI write data last
            .xpi_wlast_pkt                 (xpi_wlast_pkt[j]),                                                     // XPI write last beat of the packet
            .xpi_snf_mode                  (xpi_snf_mode[j]),                                                      // indicates if Store-And-Forward is enabled for the port    
            .xpi_wpar_err                  (xpi_wpar_err[A_STRBW*(j+1)-1 -: A_STRBW]),                             // write data parity error
            .xpi_wparity                   (xpi_wparity[A_PARW*(j+1)-1 -: A_PARW]),                              // write data parity
            // channel 1
            .xpi_wdata_dcb                 (xpi_wdata_dch1[A_DW*(j+1)-1 -: A_DW]),                                 // XPI write data
            .xpi_wstrb_dcb                 (xpi_wstrb_dch1[A_STRBW*(j+1)-1 -: A_STRBW]),                           // XPI write data strobe
            .xpi_wlast_dcb                 (xpi_wlast_dch1[j]),                                                    // XPI write data last
            .xpi_wlast_pkt_dcb             (xpi_wlast_pkt_dch1[j]),                                                // XPI write last beat of the packet
            .xpi_snf_mode_dcb              (xpi_snf_mode_dch1[j]),                                                      // indicates if Store-And-Forward is enabled for the port    
            .xpi_wpar_err_dcb              (xpi_wpar_err_dch1[A_STRBW*(j+1)-1 -: A_STRBW]),                        // write data parity error
            .xpi_wparity_dcb               (xpi_wparity_dch1[A_PARW*(j+1)-1 -: A_PARW]),                         // write data parity

            // first channel
            .xpi_wvalid_dca                (xpi_wvalid[j]),                                                         // XPI write data valid
            .hif_wready_dca                (hif_wready[j]),                                                         // HIF write data ready
            // second channel
            .xpi_wvalid_dcb                (xpi_wvalid_dch1[j]),                                                    // XPI write data valid
            .hif_wready_dcb                (hif_wready_dch1[j]),                                                    // HIF write data ready
 
            // ENIF Read Data Channel
            // first channel
            .hif_hif_rdata_dca             (hif_hif_rdata[A_DW*(j+1)-1 -: A_DW]),                                   // ENIF read data
            .hif_hif_rdata_parity_dca      (hif_hif_rdata_parity[A_STRBW*(j+1)-1 -: A_STRBW]),
            .hif_rerror_dca                (hif_rerror[j]),                                                         // ENIF read data error
            .hif_rlast_pkt_dca             (hif_rlast_pkt[j]),                                                      // ENIF read paket data last   
            .hif_rvalid_dca                (hif_rvalid[j]),                                                         // ENIF read data valid
            // second channel
            .hif_hif_rdata_dcb             (hif_hif_rdata_dch1[A_DW*(j+1)-1 -: A_DW]),                              // ENIF read data
            .hif_hif_rdata_parity_dcb      (hif_hif_rdata_parity_dch1[A_STRBW*(j+1)-1 -: A_STRBW]),
            .hif_rerror_dcb                (hif_rerror_dch1[j]),                                                     // ENIF read data error
            .hif_rlast_pkt_dcb             (hif_rlast_pkt_dch1[j]),                                                  // ENIF read paket data last   
            .hif_rvalid_dcb                (hif_rvalid_dch1[j]),                                                     // ENIF read data valid

            // ENIF Write Response Channel
            .xpi_bready_dca                (xpi_bready[j]),                                                           // ENIF Write Response ready
            .xpi_bready_dcb                (xpi_bready_dch1[j]),                                                      // ENIF Write Response ready

            // first channel
            .hif_bvalid_dca                (hif_bvalid[j]),                                                           // ENIF Write Response valid 
            .xpi_bid_dca                   (xpi_bid[AXI_IDW*(j+1)-1 -: AXI_IDW]),                                     // ENIF Write Response ID
            .e_exa_bresp_dca               (e_bresp[j]),                                                              // ENIF Exclusive Access Response
            .e_aw_slverr_dca               (e_aw_slverr[j]),                                                          // ENIF error response
            .xpi_buser_dca                 (xpi_buser[AXI_USERW*(j+1)-1 -: AXI_USERW]),
            //  channel
            .hif_bvalid_dcb                (hif_bvalid_dch1[j]),                                                      // ENIF Write Response valid 
            .xpi_bid_dcb                   (xpi_bid_dch1[AXI_IDW*(j+1)-1 -: AXI_IDW]),                                // ENIF Write Response ID
            .e_exa_bresp_dcb               (e_bresp_dch1[j]),                                                         // ENIF Exclusive Access Response
            .e_aw_slverr_dcb               (e_aw_slverr_dch1[j]),                                                     // ENIF error response
            .xpi_buser_dcb                 (xpi_buser_dch1[AXI_USERW*(j+1)-1 -: AXI_USERW]),

            // first channel
            .e_resp_token_dca              (e_resp_token[MEMC_TAGBITS*j+AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]-1 -: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]]),
            // second channel
            .e_resp_token_dcb              (e_resp_token_dch1[MEMC_TAGBITS*j+AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]-1 -: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]]),

            .xpi_rxcmd_token_blue          (xa_rtoken_x[UMCTL2_MAX_AXI_TAGBITS*(j*2) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]]),
            .xpi_rxcmd_token_blue_dcb      (xa_rtoken_x_dch1[UMCTL2_MAX_AXI_TAGBITS*(j*2) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]]),
            .xpi_rxcmd_wdata_ptr           (xa_wdata_ptr[MEMC_WDATA_PTR_BITS*(j+1)-1 -: MEMC_WDATA_PTR_BITS]),
            .xpi_rxcmd_wdata_ptr_dcb       (xa_wdata_ptr_dch1[MEMC_WDATA_PTR_BITS*(j+1)-1 -: MEMC_WDATA_PTR_BITS]),
            .xpi_rxcmd_rlength_blue        (xpi_rlength[(2*j)*CMD_LEN_BITS +: CMD_LEN_BITS]),
            .xpi_rxcmd_rlength_red         (xpi_rlength[(2*j+1)*CMD_LEN_BITS +: CMD_LEN_BITS]),

            .xpi_wexa_pyld                 (xa_wexa_pyld[EXA_PYLD_W*(j+1)-1 -: EXA_PYLD_W]),                           // Exclusive Write Payload
            .xpi_wexa_pyld_dcb             (xa_wexa_pyld_dch1[EXA_PYLD_W*(j+1)-1 -: EXA_PYLD_W]),                      // Exclusive Write Payload
            .xpi_rexa_pyld_blue            (xa_rexa_pyld[EXA_PYLD_W*(j*2) +: EXA_PYLD_W]),                             // Exclusive Read Payload
            .xpi_rexa_pyld_blue_dcb        (xa_rexa_pyld_dch1[EXA_PYLD_W*(j*2) +: EXA_PYLD_W]),                        // Exclusive Read Payload
            .reg_ddrc_ddr4                 (reg_ddrc_ddr4),
            .reg_ddrc_ddr5                 (reg_ddrc_ddr5),
            .reg_ddrc_lpddr4               (reg_ddrc_lpddr4),
            .reg_ddrc_lpddr5               (reg_ddrc_lpddr5),
            .reg_ddrc_dm_enb               (reg_ddrc_dm_en),
            .reg_ddrc_ecc_type             (reg_ddrc_ecc_type), 
            .reg_ddrc_ecc_mode             (reg_ddrc_ecc_mode),
            .reg_ddrc_multi_beat_ecc       (reg_ddrc_multi_beat_ecc),
    
            // System Address Regions registers
            .reg_arb_base_addr_0           (reg_arb_base_addr_0[AXI_SAR_BW-1:0]),
            .reg_arb_nblocks_0             (reg_arb_nblocks_0[AXI_SAR_SW-1:0]),
            .reg_arb_base_addr_1           (reg_arb_base_addr_1[AXI_SAR_BW-1:0]),
            .reg_arb_nblocks_1             (reg_arb_nblocks_1[AXI_SAR_SW-1:0]),
            .reg_arb_base_addr_2           (reg_arb_base_addr_2[AXI_SAR_BW-1:0]),
            .reg_arb_nblocks_2             (reg_arb_nblocks_2[AXI_SAR_SW-1:0]),
            .reg_arb_base_addr_3           (reg_arb_base_addr_3[AXI_SAR_BW-1:0]),
            .reg_arb_nblocks_3             (reg_arb_nblocks_3[AXI_SAR_SW-1:0]),

            // oc parity config
            .reg_ddrc_oc_parity_type            (oc_parity_type_core_clock), //  IO from DWC_ddr_umctl2_ocpar_reg_arb
            .reg_arb_address_parity_mode        (1'b1), // TODO remove
            .reg_arb_write_data_parity_mode     (1'b1), // TODO remove
            .reg_arb_read_data_parity_mode      (1'b1), // TODO remove
            .reg_ddrc_occap_en                  (reg_ddrc_occap_en),                        // IO           
            .reg_ddrc_occap_arb_cmp_poison_err_inj  (reg_ddrc_occap_arb_cmp_poison_err_inj),    // IO  
            .reg_ddrc_occap_arb_cmp_poison_parallel (reg_ddrc_occap_arb_cmp_poison_parallel),   // IO
            .reg_ddrc_occap_arb_cmp_poison_seq      (reg_ddrc_occap_arb_cmp_poison_seq),        // IO

            // axi transaction poison config
            .reg_ddrc_rd_poison_slverr_en       (reg_ddrc_rd_poison_slverr_en),
            .reg_ddrc_rd_poison_intr_en         (reg_ddrc_rd_poison_intr_en),
            .reg_ddrc_rd_poison_intr_clr        (reg_ddrc_rd_poison_intr_clr),
            .rd_poison_intr                     (rd_poison_intr[j]),                           // IO correct from every xpi!!!

            // ocpar poison config
            .reg_ddrc_par_poison_byte_num       (reg_ddrc_par_poison_byte_num),                // IO

            // parity outputs
            .par_waddr_err_pulse                (par_waddr_err_pulse[j]),                       // IO  
            .par_raddr_err_pulse                (par_raddr_err_pulse[j]),                       // IO
            .par_rdata_err_pulse                (par_rdata_err_pulse[j]),                       // IO
            .par_wdata_in_err_pulse             (par_wdata_in_err_pulse[j]),                    // IO
            .par_raddr_log                      (par_raddr_log_vector[AXI_ADDRW*(j+1)-1:AXI_ADDRW*j]),                     // IO
            .par_waddr_log                      (par_waddr_log_vector[AXI_ADDRW*(j+1)-1:AXI_ADDRW*j]),                     // IO
            .par_rdata_byte_log                 (par_rdata_byte_log_vector[OCPAR_NUM_BYTES*(j+1)-1:OCPAR_NUM_BYTES*j]),    // IO

            // new added ocecc error outputs 
            .ocecc_xpi_write_uncorr_err         (ocecc_xpi_write_uncorr_err_vector[j]),
            .ocecc_xpi_read_uncorr_err          (ocecc_xpi_read_uncorr_err_vector[j]),
            .ocecc_xpi_write_corr_err           (ocecc_xpi_write_corr_err_vector[j]),
            .ocecc_xpi_read_corr_err            (ocecc_xpi_read_corr_err_vector[j]),

            // occap output
            .aa_parity_err                      (xpi_a_parity_err[j]),
            .cc_parity_err                      (xpi_parity_err[j]),
            .ac_cmp_err                         (xpi_aclk_cmp_err[j]),
            .ac_cmp_err_full                    (xpi_aclk_cmp_err_full[j]),
            .ac_cmp_err_seq                     (xpi_aclk_cmp_err_seq[j]),
            .cc_cmp_err                         (xpi_cclk_cmp_err[j]),
            .cc_cmp_err_full                    (xpi_cclk_cmp_err_full[j]),
            .cc_cmp_err_seq                     (xpi_cclk_cmp_err_seq[j]),
            .ac_cmp_poison_complete             (xpi_aclk_cmp_poison_complete[j]),
            .cc_cmp_poison_complete             (xpi_cclk_cmp_poison_complete[j]),    

            // inline ecc
            .reg_ddrc_ecc_region_map            (reg_ddrc_ecc_region_map),
            .reg_ddrc_ecc_region_map_granu      (reg_ddrc_ecc_region_map_granu),
            .reg_ddrc_ecc_region_map_other      (reg_ddrc_ecc_region_map_other),

            // External read data RAM interface
            .rdataram_dout                      (rdataram_dout_vector[RDATARAM_DW*(j+1)-1:RDATARAM_DW*j]),    
            .rdataram_din                       (rdataram_din_vector[RDATARAM_DW*(j+1)-1:RDATARAM_DW*j]),
            .rdataram_wr                        (rdataram_wr_vector[j]),
            .rdataram_re                        (rdataram_re_vector[j]),
            .rdataram_raddr                     (rdataram_raddr_vector[RDATARAM_AW*(j+1)-1:RDATARAM_AW*j]),
            .rdataram_waddr                     (rdataram_waddr_vector[RDATARAM_AW*(j+1)-1:RDATARAM_AW*j]),    
            .rdataram_dout_par                  (rdataram_dout_par_vector[DATARAM_PAR_DW*(j+1)-1:DATARAM_PAR_DW*j]),    
            .rdataram_din_par                   (rdataram_din_par_vector[DATARAM_PAR_DW*(j+1)-1:DATARAM_PAR_DW*j]),

            .rdataram_dout_dcb                  (rdataram_dout_dch1_vector[RDATARAM_DW*(j+1)-1:RDATARAM_DW*j]),     
            .rdataram_din_dcb                   (rdataram_din_dch1_vector[RDATARAM_DW*(j+1)-1:RDATARAM_DW*j]),
            .rdataram_wr_dcb                    (rdataram_wr_dch1_vector[j]),
            .rdataram_re_dcb                    (rdataram_re_dch1_vector[j]),
            .rdataram_raddr_dcb                 (rdataram_raddr_dch1_vector[RDATARAM_AW*(j+1)-1:RDATARAM_AW*j]),
            .rdataram_waddr_dcb                 (rdataram_waddr_dch1_vector[RDATARAM_AW*(j+1)-1:RDATARAM_AW*j]),    
            .rdataram_dout_par_dcb              (rdataram_dout_par_dch1_vector[DATARAM_PAR_DW*(j+1)-1:DATARAM_PAR_DW*j]),    
            .rdataram_din_par_dcb               (rdataram_din_par_dch1_vector[DATARAM_PAR_DW*(j+1)-1:DATARAM_PAR_DW*j]),    

            // QOS configuration
            .rqos_map_level1                    (reg_arba_rqos_map_level1_vector[RQOS_MLW*(j+1)-1:RQOS_MLW*j]),
            .rqos_map_level2                    (reg_arba_rqos_map_level2_vector[RQOS_MLW*(j+1)-1:RQOS_MLW*j]),
            .rqos_map_region0                   (reg_arba_rqos_map_region0_vector[RQOS_RW*(j+1)-1:RQOS_RW*j]),
            .rqos_map_region1                   (reg_arba_rqos_map_region1_vector[RQOS_RW*(j+1)-1:RQOS_RW*j]),
            .rqos_map_region2                   (reg_arba_rqos_map_region2_vector[RQOS_RW*(j+1)-1:RQOS_RW*j]),
            .rqos_map_timeoutb                  (reg_arb_rqos_map_timeoutb_vector[RQOS_TW*(j+1)-1:RQOS_TW*j]),
            .rqos_map_timeoutr                  (reg_arb_rqos_map_timeoutr_vector[RQOS_TW*(j+1)-1:RQOS_TW*j]),
            .wqos_map_level1                    (reg_arba_wqos_map_level1_vector[WQOS_MLW*(j+1)-1:WQOS_MLW*j]),
            .wqos_map_level2                    (reg_arba_wqos_map_level2_vector[WQOS_MLW*(j+1)-1:WQOS_MLW*j]),
            .wqos_map_region0                   (reg_arba_wqos_map_region0_vector[WQOS_RW*(j+1)-1:WQOS_RW*j]),
            .wqos_map_region1                   (reg_arba_wqos_map_region1_vector[WQOS_RW*(j+1)-1:WQOS_RW*j]),
            .wqos_map_region2                   (reg_arba_wqos_map_region2_vector[WQOS_RW*(j+1)-1:WQOS_RW*j]),
            .wqos_map_timeout1                  (reg_arb_wqos_map_timeout1_vector[WQOS_TW*(j+1)-1:WQOS_TW*j]),
            .wqos_map_timeout2                  (reg_arb_wqos_map_timeout2_vector[WQOS_TW*(j+1)-1:WQOS_TW*j]),

            // Page match mask from pm_mask    
            .pagematch_addrmap_mask             (pagematch_addrmap_mask),
            .reg_arb_rd_port_pagematch_en       (reg_arb_rd_port_pagematch_en_vector[j]),
            .reg_arb_wr_port_pagematch_en       (reg_arb_wr_port_pagematch_en_vector[j]),
            .reg_arb_rdwr_ordered_en            (reg_arb_rdwr_ordered_en_vector[j]),       // do condition assignment at up layer!!! 
            .reg_arba_rdwr_ordered_en           (reg_arba_rdwr_ordered_en_vector[j]),      // do condition assignment at up layer!!! 
     
            // RRB SBAM enhancement
            .reg_arb_rrb_lock_threshold         (reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(j+1)-1:RRB_LOCK_THRESHOLD_WIDTH*j]),

            // data channel mask from pm_mask 
            .data_channel_addrmap_mask          (data_channel_addrmap_mask),
            .bg_or_bank_addrmap_mask            (bg_or_bank_addrmap_mask),
            .h3_iecc_col_mask                   (h3_iecc_col_mask),
            // column mask  mask from pm_mask    
            .reg_arb_port_data_channel          (reg_arb_port_data_channel_vector[j]),
            .e_addr_max_loc                     ({6{1'b0}}),
            .e_addr_max_m1_loc                  ({6{1'b0}}),  
            .e_addr_max_loc_addrmap_mask        ({HIF_ADDR_WIDTH{1'b0}}),
            .e_addr_max_m1_loc_addrmap_mask     ({HIF_ADDR_WIDTH{1'b0}}),
            .dch_bit                            ({6{1'b0}}),
            // Urgent signals output to pa_dual
            .rurgent_blue                       (xpi_rurgent[j*2]),              
            .wurgent_blue                       (xpi_wurgent[j*2]),               
            .rurgent_red                        (xpi_rurgent[j*2+1]),             
            .wurgent_red                        (xpi_wurgent[j*2+1]),             

            // Red read queue outputs indirectly go to pa_dual !!!
            .xpi_rxcmd_token_red                (xa_rtoken_x[UMCTL2_MAX_AXI_TAGBITS*(j*2+1) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]]),
            .xpi_rexa_pyld_red                  (xa_rexa_pyld[EXA_PYLD_W*(j*2+1) +: EXA_PYLD_W]),
            .xpi_araddr_red                     (xpi_araddr[HIF_ADDR_WIDTH*(j*2+1) +: HIF_ADDR_WIDTH]),
            .xpi_arqos_red                      (xpi_arqos[AXI_QOSW*(j*2+1) +: AXI_QOSW]),
            .xpi_rqos_priority_red              (xpi_rqos_priority[RQOS_RW*(j*2+1) +: RQOS_RW]),
            .xpi_rqos_timeout_red               (xpi_rqos_timeout[RQOS_TW*(j*2+1) +: RQOS_TW]),
            .xpi_vpr_expired_red                (xpi_vpr_expired[j*2+1]),
            .xpi_arpagematch_red                (xpi_arpagematch[j*2+1]),
            .xpi_arautopre_red                  (xpi_arautopre[j*2+1]),
            // dummy wires for channel 1, not supported with dual queue  go to pa_dual !!! 
            .xpi_rxcmd_token_red_dcb            (xa_rtoken_x_dch1[UMCTL2_MAX_AXI_TAGBITS*(j*2+1) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(j+1)-1:AXI_TAGBITS_NB*j]]),
            .xpi_rexa_pyld_red_dcb              (xa_rexa_pyld_dch1[EXA_PYLD_W*(j*2+1) +: EXA_PYLD_W]),
            .xpi_araddr_red_dcb                 (xpi_araddr_dch1[HIF_ADDR_WIDTH*(j*2+1) +: HIF_ADDR_WIDTH]),
            .xpi_arqos_red_dcb                  (xpi_arqos_dch1[AXI_QOSW*(j*2+1) +: AXI_QOSW]),
            .xpi_rqos_priority_red_dcb          (xpi_rqos_priority_dch1[RQOS_RW*(j*2+1) +: RQOS_RW]),
            .xpi_rqos_timeout_red_dcb           (xpi_rqos_timeout_dch1[RQOS_TW*(j*2+1) +: RQOS_TW]),
            .xpi_vpr_expired_red_dcb            (xpi_vpr_expired_dch1[j*2+1]),
            .xpi_arpagematch_red_dcb            (xpi_arpagematch_dch1[j*2+1]),
            .xpi_arautopre_red_dcb              (xpi_arautopre_dch1[j*2+1]),
            // first channel
            .xpi_arvalid_red_dca                (xpi_arvalid[j*2+1]),
            // second channel
            .xpi_arvalid_red_dcb                (xpi_arvalid_dch1[j*2+1]),    

            // read/write queue debug signals
            .raqb_wcount                        (raqb_wcount_vector[AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(j+2)-1:AXI_RAQD_LG2_NB*(j+1)]-1:AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(j+1)-1:AXI_RAQD_LG2_NB*j]]),
            .raqb_pop                           (raqb_pop_vector[j]),
            .raqb_push                          (raqb_push_vector[j]),
            .raq_split                          (raq_split_vector[j]),   
            .raqr_wcount                        (raqr_wcount_vector[AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(j+2)-1:AXI_RAQD_LG2_NB*(j+1)]-1:AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(j+1)-1:AXI_RAQD_LG2_NB*j]]),
            .raqr_pop                           (raqr_pop_vector[j]),
            .raqr_push                          (raqr_push_vector[j]),
            .waq_wcount                         (waq_wcount_vector[AXI_WAQD_LG2_BUS_TABLE[AXI_WAQD_LG2_NB*(j+2)-1:AXI_WAQD_LG2_NB*(j+1)]-1:AXI_WAQD_LG2_BUS_TABLE[AXI_WAQD_LG2_NB*(j+1)-1:AXI_WAQD_LG2_NB*j]]),
            .waq_pop                            (waq_pop_vector[j]),
            .waq_push                           (waq_push_vector[j]),
            .waq_split                          (waq_split_vector[j]),

            // For HWFFC (HardWare Fast Frequency Changing)
            .ddrc_xpi_port_disable_req          (ddrc_xpi_port_disable_req),
            .ddrc_xpi_clock_required            (ddrc_xpi_clock_required),
            .xpi_ddrc_port_disable_ack          (xpi_ddrc_port_disable_ack[j]),
            .xpi_ddrc_wch_locked                (xpi_ddrc_wch_locked[j])

      );
      end // block: Port

   endgenerate

   genvar     m;
   generate
     for (m=0; m<A_NPORTS; m=m+1) begin : xa_assignment 
  assign xa_wpagematch[m] = xpi_awpagematch[m];
  assign xa_rpagematch[m] = xpi_arpagematch[m];
     end
   endgenerate   

   genvar  k;
   generate
      
     for (k=0; k< A_NPORTS; k=k+1) begin : pa_mapping 

//spyglass disable_block W415a
//SMD: W415a signal may be multiply assigned (beside initialization) in the same scope 
//SJ: as shown in following always block, xa_rtoken/xa_rtoken_dch1 bus are assigned twice, (1) initialized with 0s, (2) assign corresponding xpi port's output through xa_rtoken_x/xa_rtoken_x_dch1. For more detail, please refer ARB_TOP integration summary doc.  
  always @* begin : xa_rtoken_mapping
     xa_rtoken[MEMC_TAGBITS*(k+1)*2-1 : MEMC_TAGBITS*k*2]      = {2*MEMC_TAGBITS{1'b0}};
     xa_rtoken_dch1[MEMC_TAGBITS*(k+1)*2-1 : MEMC_TAGBITS*k*2] = {2*MEMC_TAGBITS{1'b0}};
     xa_rtoken[MEMC_TAGBITS*(k*2) +:AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k] ]            =  xa_rtoken_x[UMCTL2_MAX_AXI_TAGBITS*(k*2) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k]];
     xa_rtoken[MEMC_TAGBITS*(k*2+1) +:AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k] ]          =  xa_rtoken_x[UMCTL2_MAX_AXI_TAGBITS*(k*2+1) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k]];
     xa_rtoken_dch1[MEMC_TAGBITS*(k*2) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k]]       =  xa_rtoken_x_dch1[UMCTL2_MAX_AXI_TAGBITS*(k*2) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k]];
     xa_rtoken_dch1[MEMC_TAGBITS*(k*2+1) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k]]     =  xa_rtoken_x_dch1[UMCTL2_MAX_AXI_TAGBITS*(k*2+1) +: AXI_TAGBITS_PRA_TABLE[AXI_TAGBITS_NB*(k+1)-1:AXI_TAGBITS_NB*k]];
  end   
//spyglass enable_block W415a
 
   assign hif_arready[2*k]                                                  = pa_rgrant[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]];
   assign hif_awready[k]                                                    = pa_wgrant[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]];
   assign pa_rtoken[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*MEMC_TAGBITS +: MEMC_TAGBITS]        = xa_rtoken[2*k*MEMC_TAGBITS +: MEMC_TAGBITS];
   assign pa_arpagematch[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                  = xpi_arpagematch[2*k];
   assign pa_arqos[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*AXI_QOSW +: AXI_QOSW]                 = xpi_arqos[2*k*AXI_QOSW +: AXI_QOSW];
   assign pa_rqos_priority[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*RQOS_RW +: RQOS_RW]           = xpi_rqos_priority[2*k*RQOS_RW +: RQOS_RW];
   assign pa_rqos_timeout[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*RQOS_TW +: RQOS_TW]            = xpi_rqos_timeout[2*k*RQOS_TW +: RQOS_TW];
   assign pa_arvalid[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                      = xpi_arvalid[2*k];
   assign pa_rautopre[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                     = xpi_arautopre[2*k];
   assign pa_rurgent[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                      = xpi_rurgent[2*k];
   assign pa_wurgent[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                      = xpi_wurgent[2*k];
   assign pa_vpr_expired[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                  = xpi_vpr_expired[2*k];
   assign pa_araddr[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH]    = xpi_araddr[2*k*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH];
   assign pa_rexa_pyld[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*EXA_PYLD_W +: EXA_PYLD_W]         = xa_rexa_pyld[2*k*EXA_PYLD_W +: EXA_PYLD_W];
   assign xa_rlength[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*CMD_LEN_BITS +: CMD_LEN_BITS]       = xpi_rlength[2*k*CMD_LEN_BITS +: CMD_LEN_BITS];

   assign reg_wr_port_priority_pa[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW]   = reg_wr_port_priority_vector[k*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW];
   assign reg_rd_port_priority_pa[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW]   = reg_rd_port_priority_vector[k*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW];
   assign reg_rd_port_aging_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                         = reg_rd_port_aging_en_vector[k];
   assign reg_wr_port_aging_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                         = reg_wr_port_aging_en_vector[k];
   assign reg_wr_port_urgent_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                        = reg_wr_port_urgent_en_vector[k];
   assign reg_rd_port_urgent_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                        = reg_rd_port_urgent_en_vector[k];

   assign pa_awrmw[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                        = xpi_awrmw[k];
   assign pa_awvalid[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                      = xpi_awvalid[k];
   assign pa_wautopre[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                     = xpi_awautopre[k];
   assign pa_awqos[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*AXI_QOSW +: AXI_QOSW]                 = xpi_awqos[k*AXI_QOSW +: AXI_QOSW];
   assign pa_wpagematch[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                   = xa_wpagematch[k];  
   assign pa_wdata_ptr[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*MEMC_WDATA_PTR_BITS +: MEMC_WDATA_PTR_BITS]  = xa_wdata_ptr[k*MEMC_WDATA_PTR_BITS +: MEMC_WDATA_PTR_BITS];
   assign pa_wexa_pyld[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*EXA_PYLD_W +: EXA_PYLD_W]                    = xa_wexa_pyld[k*EXA_PYLD_W +: EXA_PYLD_W];
   assign pa_exa_awlast[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                              = xpi_exa_awlast[k];
   assign pa_exa_short_burst[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                         = xpi_exa_short_burst[k];
   assign pa_awaddr[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH]               = xpi_awaddr[k*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH];
   assign pa_wqos_priority[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*WQOS_RW +: WQOS_RW]                      = xpi_wqos_priority[k*WQOS_RW +: WQOS_RW];
   assign pa_wqos_timeout[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*WQOS_TW +: WQOS_TW]                       = xpi_wqos_timeout[k*WQOS_TW +: WQOS_TW];
   assign pa_vpw_expired[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]]                                             = xpi_vpw_expired[k];
   assign pa_wdata_mask_full[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*WRDATA_CYCLES +: WRDATA_CYCLES]        = xpi_wdata_mask_full[k*WRDATA_CYCLES +: WRDATA_CYCLES];
   assign xa_wlength[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k])*CMD_LEN_BITS +: CMD_LEN_BITS]                  = xpi_wlength[k*CMD_LEN_BITS +: CMD_LEN_BITS];
 
  if(UMCTL2_A_USE2RAQ[k]) begin: DUAL_RAQ   // single adress Q or dual address Q for given AXI port
   assign hif_arready[2*k+1]                                                = pa_rgrant[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1];
   assign pa_rtoken[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*MEMC_TAGBITS +: MEMC_TAGBITS]      = xa_rtoken[(2*k+1)*MEMC_TAGBITS +: MEMC_TAGBITS];
   assign pa_arpagematch[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                = xpi_arpagematch[2*k+1];
   assign pa_arqos[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*AXI_QOSW +: AXI_QOSW]               = xpi_arqos[(2*k+1)*AXI_QOSW +: AXI_QOSW];
   assign pa_rqos_priority[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*RQOS_RW +: RQOS_RW] = xpi_rqos_priority[(2*k+1)*RQOS_RW +: RQOS_RW];
   assign pa_rqos_timeout[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*RQOS_TW +: RQOS_TW]  = xpi_rqos_timeout[(2*k+1)*RQOS_TW +: RQOS_TW]; 
   assign pa_arvalid[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                    = xpi_arvalid[2*k+1];
   assign pa_rautopre[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                   = xpi_arautopre[2*k+1];
   assign pa_rurgent[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                    = xpi_rurgent[2*k+1];
   assign pa_wurgent[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                    = xpi_wurgent[2*k+1];
   assign pa_vpr_expired[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                = xpi_vpr_expired[2*k+1];
   assign pa_araddr[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH]  = xpi_araddr[(2*k+1)*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH];
   assign pa_rexa_pyld[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*EXA_PYLD_W +: EXA_PYLD_W]       = xa_rexa_pyld[(2*k+1)*EXA_PYLD_W +: EXA_PYLD_W];
   assign xa_rlength[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*CMD_LEN_BITS +: CMD_LEN_BITS]     = xpi_rlength[(2*k+1)*CMD_LEN_BITS +: CMD_LEN_BITS];

      // for the other signals, pad zeros in the dummy port
   assign reg_wr_port_priority_pa[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW]    = {(REG_PORT_PRIORITYW){1'b0}};
   assign reg_rd_port_priority_pa[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW]    = reg_rd_port_priority_vector[k*REG_PORT_PRIORITYW +: REG_PORT_PRIORITYW]; 
   assign reg_rd_port_aging_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                               = reg_rd_port_aging_en_vector[k];
   assign reg_wr_port_aging_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                               = 1'b0;
   assign reg_wr_port_urgent_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                              = 1'b0;
   assign reg_rd_port_urgent_en_pa[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                              = reg_rd_port_urgent_en_vector[k];
 
   assign pa_awrmw[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                      = 1'b0;
   assign pa_awvalid[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                    = 1'b0;
   assign pa_wautopre[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                   = 1'b0;
   assign pa_awqos[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*AXI_QOSW +: AXI_QOSW]               = {(AXI_QOSW){1'b0}}; 
   assign pa_wpagematch[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                 = 1'b0;
   assign pa_wdata_ptr[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*MEMC_WDATA_PTR_BITS +: MEMC_WDATA_PTR_BITS]             = {(MEMC_WDATA_PTR_BITS){1'b0}};

   assign pa_wexa_pyld[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*EXA_PYLD_W +: EXA_PYLD_W]                               = {(EXA_PYLD_W){1'b0}};
   assign pa_exa_awlast[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                                         = 1'b0;
   assign pa_exa_short_burst[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                                    = 1'b0;
   assign pa_awaddr[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*HIF_ADDR_WIDTH +: HIF_ADDR_WIDTH]                          = {(HIF_ADDR_WIDTH){1'b0}};

   assign pa_wqos_priority[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*WQOS_RW +: WQOS_RW]                         = {(WQOS_RW){1'b0}};
   assign pa_wqos_timeout[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*RQOS_TW +: RQOS_TW]                          = {(WQOS_TW){1'b0}};
   assign pa_vpw_expired[k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1]                                                        = 1'b0;   
   assign pa_wdata_mask_full[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*WRDATA_CYCLES +: WRDATA_CYCLES]                   = {WRDATA_CYCLES{1'b0}};
   assign xa_wlength[(k+RAQ_TABLE_TABLE[MAX_RAQ_TABLE_TABLE_NB*(k+1)-1:MAX_RAQ_TABLE_TABLE_NB*k]+1)*CMD_LEN_BITS +: CMD_LEN_BITS]               = {CMD_LEN_BITS{1'b0}};
  end else begin: nDUAL_RAQ // UMCTL2_A_USE2RAQ 
     assign hif_arready[2*k+1]  = 1'b0;   
  end // else: !if(UMCTL2_A_USE2RAQ[k])

   assign hif_awready_dch1[k] = 1'b0;
   assign hif_arready_dch1[2*k]  = 1'b0;                                                                        
   assign hif_arready_dch1[2*k+1] = 1'b0;  
   
     end // for (k=0; k< A_NPORTS; k=k+1)
   endgenerate
    
//spyglass disable_block W415a
//SMD: Signal pa_rmask_int/pa_wmask_int_dch1 is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches

   // note disabling xprop for this process as xprop incorrectly handles
   // arrays    
   always  (* xprop_off *) @*
     begin: pa_mask_COMB_PROC
  integer p, j;
  j=0;
  for (p=0; p<A_NPORTS; p=p+1) begin
           if (RAQ_TABLE[p] == 1'b1 && RAQ_TABLE != 0) begin  // Dual RAQ for this port
              pa_rmask_int[j+p]    = pa_rmask[2*p];
              pa_rmask_int[j+p+1]  = pa_rmask[2*p+1];
              pa_wmask_int[j+p]    = pa_wmask[p];
              pa_wmask_int[j+p+1]  = 1'b0;
              j=j+1;
           end else begin
              pa_rmask_int[j+p] = pa_rmask[2*p];
              pa_wmask_int[j+p] = pa_wmask[p];
           end
  end
  
    end // block: pa_mask_COMB_PROC
//spyglass enable_block W415a   

   wire hif_rcmd_stall, hif_wcmd_stall;
   
   assign hif_rcmd_stall = hif_cmd_stall; // same input
   assign hif_wcmd_stall = hif_cmd_stall;


  DWC_ddr_umctl2_pa_dual
   #(
      .NPORTS                    (INT_NPORTS), 
      .PORT_PRIORITYW            (PORT_PRIORITYW), 
      .QOSW                      (AXI_QOSW),
      .REG_PORT_PRIORITYW        (REG_PORT_PRIORITYW), 
      .PA_OPT_TYPE               (PA_OPT_TYPE), 
      .PAGEMATCH_EN              (PAGEMATCH_EN),
      .MEMC_ECC_SUPPORT          (MEMC_ECC_SUPPORT),
      .MEMC_INLINE_ECC           (MEMC_INLINE_ECC),
      .WDATA_PTR_BITS            (MEMC_WDATA_PTR_BITS), 
      .MEMC_TAGBITS              (MEMC_TAGBITS),
      .AXI_IDW                   (AXI_IDW),
      .AXI_USERW                 (AXI_USERW),
      .A_NPORTS_LG2              (A_NPORTS_LG2), 
      .EXT_PORTPRIO              (EXT_PORTPRIO), 
      .RQOS_RW                   (RQOS_RW), 
      .WQOS_RW                   (WQOS_RW),
      .HIF_CREDIT_BITS           (HIF_CREDIT_BITS),
      .DUAL_PA                   (DUAL_PA),
      .DATA_CHANNEL_INTERLEAVE   (DATA_CHANNEL_INTERLEAVE),
      .OCCAP_EN                  (OCCAP_EN),
      .OCCAP_PIPELINE_EN         (OCCAP_PIPELINE_EN)   
    )

   U_pa (
         // generatl inputs
         .clk                        (core_ddrc_core_clk),
         .rst_n                      (core_ddrc_rstn),

         // input: HIF Command Flow Control Interface
         .hif_rcmd_stall             (hif_rcmd_stall),
         .hif_wcmd_stall             (hif_wcmd_stall),
         .hif_hpr_credit             (hif_hpr_credit),
         .hif_lpr_credit             (hif_lpr_credit),
         .hif_wr_credit              (hif_wr_credit),
         .hif_wrecc_credit           (hif_wrecc_credit),

         // Outputs: HIF Scheduler Interface
         .hif_go2critical_wr         (pa_ddrc_go2critical_wr),
         .hif_go2critical_lpr        (pa_ddrc_go2critical_lpr),
         .hif_go2critical_hpr        (pa_ddrc_go2critical_hpr),
         .hif_go2critical_l1_wr      (pa_hif_go2critical_l1_wr ),
         .hif_go2critical_l2_wr      (pa_hif_go2critical_l2_wr ),
         .hif_go2critical_l1_lpr     (pa_hif_go2critical_l1_lpr),
         .hif_go2critical_l2_lpr     (pa_hif_go2critical_l2_lpr),
         .hif_go2critical_l1_hpr     (pa_hif_go2critical_l1_hpr),
         .hif_go2critical_l2_hpr     (pa_hif_go2critical_l2_hpr),

         // Input: Register Interface 
         .reg_go2critical_en         (reg_arb_go2critical_en),
         .reg_pagematch_limit        (reg_arb_pagematch_limit),
         .reg_wr_port_priority       (reg_wr_port_priority_pa[INT_NPORTS*REG_PORT_PRIORITYW-1:0]),
         .reg_wr_port_aging_en       (reg_wr_port_aging_en_pa[INT_NPORTS-1:0]),
         .reg_wr_port_urgent_en      (reg_wr_port_urgent_en_pa[INT_NPORTS-1:0]),
         .reg_rd_port_priority       (reg_rd_port_priority_pa[INT_NPORTS*REG_PORT_PRIORITYW-1:0]),
         .reg_rd_port_aging_en       (reg_rd_port_aging_en_pa[INT_NPORTS-1:0]),
         .reg_rd_port_urgent_en      (reg_rd_port_urgent_en_pa[INT_NPORTS-1:0]),
         .xa_rqos_priority           (pa_rqos_priority),
         .xa_wqos_priority           (pa_wqos_priority),
         .reg_ddrc_ecc_type          (reg_ddrc_ecc_type), 
         .reg_ddrc_ecc_mode          (reg_ddrc_ecc_mode[2:0]), 
         .reg_ddrc_occap_en          (reg_ddrc_occap_en),

         // input: Miscellenous
         .any_other_stall_condition  (any_other_stall_condition),
         .lpr_num_entries_changed    (lpr_num_entries_changed),

         // Write Ports
         // inputs of write ports
         .xa_rmw_dynamic             (pa_awrmw[INT_NPORTS-1:0]),       
         .xa_wqos                    (pa_awqos[INT_NPORTS*AXI_QOSW-1:0]),
         .xa_wurgent                 (pa_wurgent[INT_NPORTS-1:0]),
         .xa_wpagematch              (pa_wpagematch[INT_NPORTS-1:0]),
         .xa_wdata_ptr               (pa_wdata_ptr[INT_NPORTS*MEMC_WDATA_PTR_BITS-1:0]),
         .xa_wreq                    (pa_awvalid[INT_NPORTS-1:0]),
         .xa_wmask                   (pa_wmask_int[INT_NPORTS-1:0]),
         .xa_wlast                   (pa_exa_awlast[INT_NPORTS-1:0]),
         .xa_vpw_expired             (pa_vpw_expired[INT_NPORTS-1:0]),
         // outputs of write ports 
         .pa_wgrant                  (pa_wgrant[INT_NPORTS-1:0]),
         .pa_rgrant                  (pa_rgrant[INT_NPORTS-1:0]),

         // read ports
         // inputs of read ports
         .xa_rqos                    (pa_arqos[INT_NPORTS*AXI_QOSW-1:0]),
         .xa_rurgent                 (pa_rurgent[INT_NPORTS-1:0]),
         .xa_rpagematch              (pa_arpagematch[INT_NPORTS-1:0]),
         .xa_vpr_expired             (pa_vpr_expired[INT_NPORTS-1:0]),
         .xa_rmask                   (pa_rmask_int[INT_NPORTS-1:0]),
         .xa_rreq                    (pa_arvalid[INT_NPORTS-1:0]),
         .xa_rtoken                  (pa_rtoken),
         // output of read posts 
         .pa_rpri                    (pa_rpri[INT_NPORTS*RQOS_RW-1:0]),
         .pa_wpri                    (pa_wpri[INT_NPORTS*WQOS_RW-1:0]),

         // Output for Credit Counters
         .perf_hpr_req_with_nocredit (perf_hpr_req_with_nocredit_dch0),
         .perf_lpr_req_with_nocredit (perf_lpr_req_with_nocredit_dch0),

         // Output for Credit Counters
         .lpr_credit_cnt             (lpr_credit_cnt),
         .hpr_credit_cnt             (hpr_credit_cnt),
         .wr_credit_cnt              (wr_credit_cnt),
         .wrecc_credit_cnt           (wrecc_credit_cnt),
         .occap_pa_parity_err        (pa_parity_err_dch0));


   
   DWC_ddr_umctl2_hif_cmd
    #(
      .NPORTS           (INT_NPORTS), 
      .HIF_ADDR_WIDTH   (HIF_ADDR_WIDTH), 
      .EXA_PYLD_W       (EXA_PYLD_W), 
      .AXI_LOCKW        (AXI_LOCKW_FIX),     // it is same AXI_LOCKW_FIX 
      .MEMC_TAGBITS     (MEMC_TAGBITS), 
      .WDATA_PTR_BITS   (MEMC_WDATA_PTR_BITS), 
      .RQOS_TW          (RQOS_TW), 
      .RQOS_RW          (RQOS_RW), 
      .WQOS_TW          (WQOS_TW), 
      .WQOS_RW          (WQOS_RW),
      .CMD_LEN_BITS     (CMD_LEN_BITS),
      .WRDATA_CYCLES    (WRDATA_CYCLES),
      .AXI_IDW          (AXI_IDW),
      .A_NPORTS_LG2     (A_NPORTS_LG2),
      .DUAL_PA          (DUAL_PA))
    U_hif_cmd(
              //.clk                        (core_ddrc_core_clk),
              //.rst_n                      (core_ddrc_rstn),
      
             // Outputs
              .hif_hif_cmd_valid       (hif_hif_cmd_valid),                               // output to DDRC also goes to exa_top
              .hif_hif_cmd_type        (hif_hif_cmd_type[1:0]),                           // output to DDRC also goes to exa_top
              .hif_hif_cmd_addr        (hif_hif_cmd_addr[HIF_ADDR_WIDTH-1:0]),            // output to DDRC also goes to exa_top
              .hif_hif_cmd_pri         (hif_hif_cmd_pri),
              .hif_hif_cmd_latency     (hif_hif_cmd_latency),
              .hif_hif_cmd_token       (hif_hif_cmd_token[MEMC_TAGBITS-1:0]),             // output to DDRC also goes to exa_top
              .hif_hif_cmd_length      (hif_hif_cmd_length),
              .hif_hif_cmd_wdata_ptr   (hif_hif_cmd_wdata_ptr[MEMC_WDATA_PTR_BITS-1:0]),  // output to DDRC also goes to exa_top
              .hif_hif_cmd_autopre     (hif_hif_cmd_autopre),
              .hif_hif_cmd_ecc_region  (hif_hif_cmd_ecc_region),
              .hif_hif_cmd_wdata_mask_full_ie  (hif_hif_cmd_wdata_mask_full_ie),
               // goes to rxa_top
              .hif_co_ih_exa_pyld_wr      (hif_co_ih_exa_pyld_wr), 
              .hif_co_ih_exa_pyld_rd      (hif_co_ih_exa_pyld_rd),
              .hif_hif_cmd_awlast         (hif_hif_cmd_awlast),
              .hif_hif_cmd_short_burst    (hif_hif_cmd_short_burst),
      
              // Inputs
              .pa_wgrant                  (pa_wgrant[INT_NPORTS-1:0]),   // from PA
              .pa_rgrant                  (pa_rgrant[INT_NPORTS-1:0]),   // from PA
              .e_arvalid                  (pa_arvalid[INT_NPORTS-1:0]),
              .e_araddr                   (pa_araddr[INT_NPORTS*HIF_ADDR_WIDTH-1:0]),
              .pa_rpri                    (pa_rpri[INT_NPORTS*RQOS_RW-1:0]),
              .pa_wpri                    (pa_wpri[INT_NPORTS*WQOS_RW-1:0]),
              .pa_r_timeout               (pa_rqos_timeout),
              .pa_w_timeout               (pa_wqos_timeout),
              .xa_rlength                 (xa_rlength[INT_NPORTS*CMD_LEN_BITS-1:0]),
              .xa_rtoken                  (pa_rtoken[INT_NPORTS*MEMC_TAGBITS-1:0]),
              .xa_rautopre                (pa_rautopre[INT_NPORTS-1:0]),
              .e_awvalid                  (pa_awvalid[INT_NPORTS-1:0]),
              .e_awaddr                   (pa_awaddr[INT_NPORTS*HIF_ADDR_WIDTH-1:0]),

              .xpi_awlast                 (pa_exa_awlast[INT_NPORTS-1:0]),
              .xpi_short_burst            (pa_exa_short_burst[INT_NPORTS-1:0]),
              .xa_wdata_ptr               (pa_wdata_ptr[INT_NPORTS*MEMC_WDATA_PTR_BITS-1:0]),
              .xa_rmw_dynamic             (pa_awrmw[INT_NPORTS-1:0]),
              .xa_wautopre                (pa_wautopre[INT_NPORTS-1:0]),
              .xa_wdata_mask_full         (pa_wdata_mask_full),
              .xa_wlength                 (xa_wlength),
              .e_wexa_pyld                (pa_wexa_pyld[INT_NPORTS*EXA_PYLD_W-1:0]),
              .e_rexa_pyld                (pa_rexa_pyld[INT_NPORTS*EXA_PYLD_W-1:0]));


      DWC_ddr_umctl2_hif_data
       
    #(.NPORTS              (NPORTS_DATA),
      .MEMC_WDATA_PTR_BITS (MEMC_WDATA_PTR_BITS), 
      .ADDR_ERR_EN         (ADDR_ERR_EN),
      .A_DW                (A_DW), 
      .AXI_IDW             (AXI_IDW),
      .AXI_USERW           (AXI_USERW),
      .MEMC_TAGBITS        (MEMC_TAGBITS), 
      .A_STRBW             (A_STRBW), 
      .A_PARW              (A_PARW), 
      .M_DW                (M_DW),
      .NAB                 (NAB),
      .A_NPORTS_LG2        (A_NPORTS_LG2),
      .WDATA_PTR_QD        (WDATA_PTR_QD), 
      .EXA_ACC_SUPPORT     (EXA_ACC_SUPPORT),
      .DCH_INTERLEAVE      (DCH_INTERLEAVE),
      .M_USE_RMW           (M_USE_RMW),     
      .OCPAR_EN            (OCPAR_EN),
      .OCCAP_EN            (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .WDATA_RETIME        (OCECC_EN))

   U_hif_data (
               .clk                        (core_ddrc_core_clk),
               .rst_n                      (core_ddrc_rstn),

               // inputs of writer pointer return
               .hif_wdata_ptr              (hif_wdata_ptr_w[MEMC_WDATA_PTR_BITS-1:0]),  // from exa_top or ddrc
               .hif_wdata_ptr_valid        (hif_wdata_ptr_valid),                       // from ddrc
               .hif_wr_addr_err            (hif_wr_addr_err),                    // from ddrc
               //.hif_wr_addr_err            (hif_wdata_ptr_addr_err),                    // from ddrc

               // inputs of Hif Read Data Channel (Common Response)
               .hif_rdata_valid            (hif_rdata_valid),                   // from ddrc                   
               .hif_rdata_end              (hif_rdata_end),                     // from ddrc
               .hif_rdata_token            (hif_rdata_token[MEMC_TAGBITS-1:0]), // from ddrc
               .hif_rdata                  (hif_rdata[A_DW-1:0]),               // from ddrc
               .hif_rdata_parity           (hif_rdata_parity[A_STRBW-1:0]),     // from ddrc
               .hif_rdata_uncorr_ecc_err   (hif_rdata_uncorr_ecc_err),          // from ddrc       
               .hif_rdata_crc_err          (hif_rdata_crc_err),                 // from ddrc       
               .hif_rdata_uncorr_linkecc_err(hif_rdata_uncorr_linkecc_err),     // from ddrc
               .hif_rdata_eapar_err        (hif_rdata_eapar_err),
               .hif_rd_addr_err            (hif_rdata_addr_err),                // from ddrc 
               // Hif write data
               .hif_wdata_stall            (hif_wdata_stall),                   // from ddrc       
               .hif_wdata_valid            (hif_wdata_valid),               // goes to ddrc
               .hif_wdata_end              (hif_wdata_end),                 // goes to ddrc
               .hif_wdata                  (hif_wdata[A_DW-1:0]),           // goes to ddrc
               .hif_wdata_mask             (hif_wdata_mask[A_STRBW-1:0]),   // goes to ddrc
               .hif_wdata_parity           (hif_wdata_parity[A_PARW-1:0]), // goes to ddrc

               // XPI write data channel

               .e_wready                   (hif_wready[INT_NPORTS_DATA-1:0]),
               .e_rvalid                   (hif_rvalid[INT_NPORTS_DATA-1:0]),

               .e_rdata                    (hif_hif_rdata[INT_NPORTS_DATA*A_DW-1:0]),
               .e_rdata_parity             (hif_hif_rdata_parity[INT_NPORTS_DATA*A_STRBW-1:0]),
               .e_rlast_pkt                (hif_rlast_pkt[INT_NPORTS_DATA-1:0]),
               .e_resp_token               (e_resp_token[INT_NPORTS_DATA*MEMC_TAGBITS-1:0]),
               .e_rerror                   (hif_rerror[INT_NPORTS_DATA-1:0]),
               .e_bvalid                   (hif_bvalid[INT_NPORTS_DATA-1:0]),
               .e_bid                      (xpi_bid[INT_NPORTS_DATA*AXI_IDW-1:0]),
               .e_bresp                    (e_bresp[INT_NPORTS_DATA-1:0]),
               .e_aw_slverr                (e_aw_slverr[INT_NPORTS_DATA-1:0]),
               .e_buser                    (xpi_buser),

               .wr_poison_intr             (wr_poison_intr_dch0),

               .occap_hif_data_par_err    (occap_hif_data_par_err_dch0),

               // Inputs
               .reg_ddrc_wr_poison_slverr_en   (reg_ddrc_wr_poison_slverr_en),
               .reg_ddrc_wr_poison_intr_en     (reg_ddrc_wr_poison_intr_en),
               .reg_ddrc_wr_poison_intr_clr    (reg_ddrc_wr_poison_intr_clr),
 
               .reg_ddrc_par_addr_slverr_en    (reg_ddrc_par_addr_slverr_en),
               .reg_ddrc_par_wdata_slverr_en   (reg_ddrc_par_wdata_slverr_en),
               .reg_ddrc_ocecc_wdata_slverr_en (reg_ddrc_ocecc_wdata_slverr_en),   //new !!!
               .reg_ddrc_occap_en              (reg_ddrc_occap_en),
               .reg_ddrc_data_bus_width        (reg_ddrc_data_bus_width),

               .e_wvalid                   (xpi_wvalid[INT_NPORTS_DATA-1:0]),
               .e_wdata                    (xpi_wdata[INT_NPORTS_DATA*A_DW-1:0]),
               .e_wstrb                    (xpi_wstrb[INT_NPORTS_DATA*A_STRBW-1:0]),
               .e_wlast                    (xpi_wlast[INT_NPORTS_DATA-1:0]),
               .e_wpar_err                 (xpi_wpar_err[INT_NPORTS_DATA*A_STRBW-1:0]),
               .e_wparity                  (xpi_wparity[INT_NPORTS_DATA*A_PARW-1:0]),
               .e_wlast_pkt                (xpi_wlast_pkt[INT_NPORTS_DATA-1:0]),
               .e_snf_mode                 (xpi_snf_mode[INT_NPORTS_DATA-1:0]),
               .e_bready                   (xpi_bready[INT_NPORTS_DATA-1:0]));


   assign hif_wdata_ptr_w          = hif_wdata_ptr;
   assign exa_parity_err           = 1'b0;


//--------------------------------------------------------------------------------------------
//   all dual channel modules are from here
//---------------------------------------------------------------------------------------------   

   

   assign perf_lpr_req_with_nocredit_dch1 = 1'b0;
   assign perf_hpr_req_with_nocredit_dch1 = 1'b0;
   assign hif_wready_dch1                 = {(INT_NPORTS_DATA){1'b0}};
   assign hif_hif_rdata_dch1              = {(INT_NPORTS_DATA*A_DW){1'b0}};
   assign hif_hif_rdata_parity_dch1       = {(INT_NPORTS_DATA*A_STRBW){1'b0}};
   assign hif_rerror_dch1                 = {(INT_NPORTS_DATA){1'b0}};
   assign hif_rlast_pkt_dch1              = {(INT_NPORTS_DATA){1'b0}};
   assign hif_rvalid_dch1                 = {(INT_NPORTS_DATA){1'b0}};
   assign hif_bvalid_dch1                 = {(INT_NPORTS_DATA){1'b0}};
   assign xpi_bid_dch1                    = {(INT_NPORTS_DATA*AXI_IDW){1'b0}};
   assign e_bresp_dch1                    = {(INT_NPORTS_DATA){1'b0}};
   assign xpi_buser_dch1                  = {(INT_NPORTS_DATA*AXI_USERW){1'b0}};
   assign e_aw_slverr_dch1                = {(INT_NPORTS_DATA){1'b0}};
   assign e_resp_token_dch1               = {(INT_NPORTS_DATA*MEMC_TAGBITS){1'b0}};
   assign wr_poison_intr_dch1             = {(INT_NPORTS_DATA){1'b0}};
   assign exa_parity_err_dch1             = 1'b0;
   assign occap_hif_data_par_err_dch1     = 1'b0;
   assign pa_parity_err_dch1              = 1'b0;
 

   wire reg_arb_scrub_en;
   assign reg_arb_scrub_en = 1'b0;
   assign sbr_cactive_out_dch0 = 1'b0;
   assign occap_sbr_par_err_dch0 = 1'b0;
   assign occap_sbr_par_err_dch1 = 1'b0;

 


   DWC_ddr_umctl2_pm_mask
    #(
      .SBR_EN           (SBR_EN), 
      .OCCAP_EN         (OCCAP_EN),
      .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN),
      .LPDDR3_EN        (LPDDR3_EN),
      .LPDDR4_EN        (LPDDR4_EN),
      .INLINE_ECC       (INLINE_ECC),
      .DDRCTL_HET_INTERLEAVE       (DDRCTL_HET_INTERLEAVE),
      .MBL              (MBL),
      .ECC_H3_WIDTH     (ECC_H3_WIDTH),
      .AMCOLW_H         (AMCOLW_H),
      .AMCOLW_L         (AMCOLW_L),
      .AMCOLW_C3        (AMCOLW_C3),
      .AMCSW            (AMCSW),
      .AMDCHW           (AMDCHW),
      .AMCIDW           (AMCIDW),
      .AMBANKW          (AMBANKW),
      .AMBGW            (AMBGW),
      .AMROWW           (AMROWW),
      .HIF_ADDR_WIDTH   (HIF_ADDR_WIDTH))
   U_pm_mask 
     (
      // Outputs
      .pm_mask_parity_err         (pm_mask_parity_err_w),
      .pagematch_addrmap_mask     (pagematch_addrmap_mask),
      .data_channel_addrmap_mask  (data_channel_addrmap_mask),
      .bg_or_bank_addrmap_mask    (bg_or_bank_addrmap_mask[HIF_ADDR_WIDTH-1:0]),
      .lpddr34_6gb_12gb_mask      (lpddr34_6gb_12gb_mask_unused),
      .h3_iecc_col_mask           (h3_iecc_col_mask),
      .l3_iecc_col_mask           (l3_iecc_col_mask),
      .sbr_address_range          (sbr_address_range[HIF_ADDR_WIDTH-1:0]),
      // Inputs
      .clk                        (core_ddrc_core_clk),
      .rst_n                      (core_ddrc_rstn),

      .reg_ddrc_lpddr3_6gb_12gb        (reg_ddrc_lpddr3_6gb_12gb),
      .reg_ddrc_lpddr45_6gb_12gb_24gb  (reg_ddrc_lpddr45_6gb_12gb_24gb),
      .reg_ddrc_nonbinary_device_density (reg_ddrc_nonbinary_device_density),
      .reg_ddrc_occap_en               (reg_ddrc_occap_en),

      .reg_ddrc_addrmap_bank_b0   (reg_ddrc_addrmap_bank_b0),
      .reg_ddrc_addrmap_bank_b1   (reg_ddrc_addrmap_bank_b1),
      .reg_ddrc_addrmap_bank_b2   (reg_ddrc_addrmap_bank_b2),
      .reg_ddrc_addrmap_col_b2    (reg_ddrc_addrmap_col_b2),
      .reg_ddrc_addrmap_col_b3    (reg_ddrc_addrmap_col_b3),
      .reg_ddrc_addrmap_col_b4    (reg_ddrc_addrmap_col_b4),
      .reg_ddrc_addrmap_col_b5    (reg_ddrc_addrmap_col_b5),
      .reg_ddrc_addrmap_col_b6    (reg_ddrc_addrmap_col_b6),
      .reg_ddrc_addrmap_col_b7    (reg_ddrc_addrmap_col_b7),
      .reg_ddrc_addrmap_col_b8    (reg_ddrc_addrmap_col_b8),
      .reg_ddrc_addrmap_col_b9    (reg_ddrc_addrmap_col_b9),
      .reg_ddrc_addrmap_col_b10   (reg_ddrc_addrmap_col_b10),
      .reg_ddrc_addrmap_col_b11   (reg_ddrc_addrmap_col_b11),
      .reg_ddrc_addrmap_row_b0    (reg_ddrc_addrmap_row_b0),
      .reg_ddrc_addrmap_row_b1    (reg_ddrc_addrmap_row_b1),
      .reg_ddrc_addrmap_row_b2    (reg_ddrc_addrmap_row_b2),
      .reg_ddrc_addrmap_row_b3    (reg_ddrc_addrmap_row_b3),
      .reg_ddrc_addrmap_row_b4    (reg_ddrc_addrmap_row_b4),
      .reg_ddrc_addrmap_row_b5    (reg_ddrc_addrmap_row_b5),
      .reg_ddrc_addrmap_row_b6    (reg_ddrc_addrmap_row_b6),
      .reg_ddrc_addrmap_row_b7    (reg_ddrc_addrmap_row_b7),
      .reg_ddrc_addrmap_row_b8    (reg_ddrc_addrmap_row_b8),
      .reg_ddrc_addrmap_row_b9    (reg_ddrc_addrmap_row_b9),
      .reg_ddrc_addrmap_row_b10   (reg_ddrc_addrmap_row_b10),
      .reg_ddrc_addrmap_row_b2_10 (reg_ddrc_addrmap_row_b2_10),
      .reg_ddrc_addrmap_row_b11   (reg_ddrc_addrmap_row_b11),
      .reg_ddrc_addrmap_row_b12   (reg_ddrc_addrmap_row_b12),
      .reg_ddrc_addrmap_row_b13   (reg_ddrc_addrmap_row_b13),
      .reg_ddrc_addrmap_row_b14   (reg_ddrc_addrmap_row_b14),
      .reg_ddrc_addrmap_row_b15   (reg_ddrc_addrmap_row_b15),
      .reg_ddrc_addrmap_row_b16   (reg_ddrc_addrmap_row_b16),
      .reg_ddrc_addrmap_row_b17   (reg_ddrc_addrmap_row_b17)
    );
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W528
   wire pm_mask_parity_err_alt;
   assign pm_mask_parity_err = pm_mask_parity_err_w | pm_mask_parity_err_alt;

   assign pm_mask_parity_err_alt = 1'b0;

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON

// Collect QoS info for assertion using.    
reg [A_NPORTS-1:0] xpi_rurgent_red;
reg [A_NPORTS-1:0] xpi_rurgent_blue;
reg [A_NPORTS-1:0] xpi_wurgent_red;
reg [A_NPORTS-1:0] xpi_wurgent_blue;
reg [A_NPORTS-1:0] xpi_rqos_hpr;
reg [A_NPORTS-1:0] xpi_rqos_lpr;
reg [A_NPORTS-1:0] xpi_rqos_vpr;
reg [A_NPORTS-1:0] xpi_rqos_hpr_dch1;
reg [A_NPORTS-1:0] xpi_rqos_lpr_dch1;
reg [A_NPORTS-1:0] xpi_rqos_vpr_dch1;
//genvar j;
generate
    for (genvar j=0; j < A_NPORTS; j = j +  1) begin
        assign xpi_rurgent_red[j] = xpi_rurgent[j*2+1];
        assign xpi_rurgent_blue[j] = xpi_rurgent[j*2];
        assign xpi_wurgent_red[j] = xpi_wurgent[j*2+1];
        assign xpi_wurgent_blue[j] = xpi_wurgent[j*2];
        assign xpi_rqos_lpr[j] = xpi_rqos_priority[(j*2+1)*RQOS_RW-1:j*2*RQOS_RW]==2'b00;
        assign xpi_rqos_vpr[j] = (xpi_rqos_priority[(j*2+1)*RQOS_RW-1:j*2*RQOS_RW]==2'b01) || (xpi_rqos_priority[(j*2+2)*RQOS_RW-1:(j*2+1)*RQOS_RW]==2'b01);
        assign xpi_rqos_hpr[j] = UMCTL2_A_USE2RAQ[j] ? (xpi_rqos_priority[(j*2+2)*RQOS_RW-1:(j*2+1)*RQOS_RW]==2'b10) : xpi_rqos_priority[(j*2+1)*RQOS_RW-1:j*2*RQOS_RW]==2'b10;
        assign xpi_rqos_lpr_dch1[j] = xpi_rqos_priority_dch1[(j*2+1)*RQOS_RW-1:j*2*RQOS_RW]==2'b00;
        assign xpi_rqos_vpr_dch1[j] = (xpi_rqos_priority_dch1[(j*2+1)*RQOS_RW-1:j*2*RQOS_RW]==2'b01) || (xpi_rqos_priority_dch1[(j*2+2)*RQOS_RW-1:(j*2+1)*RQOS_RW]==2'b01);
        assign xpi_rqos_hpr_dch1[j] = UMCTL2_A_USE2RAQ[j] ? (xpi_rqos_priority_dch1[(j*2+2)*RQOS_RW-1:(j*2+1)*RQOS_RW]==2'b10) : xpi_rqos_priority_dch1[(j*2+1)*RQOS_RW-1:j*2*RQOS_RW]==2'b10;
    end
endgenerate    

//genvar j;
generate
    for (genvar j = 0; j < A_NPORTS; j = j + 1) begin : assertion_port

        // hif_go2critical_l1_wr will be triggered by wurgent only.
        property p_hif_go2critical_l1_wr_chk;
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                reg_arb_go2critical_en && reg_wr_port_urgent_en_vector[j] && xpi_wurgent_blue[j]
                && ~(DUAL_CHANNEL && (DATA_CHANNEL_INTERLEAVE_NS_TABLE[MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*(j+1)-1:MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*j]) && PA_OPT_TYPE==1) |->
                pa_hif_go2critical_l1_wr && pa_ddrc_go2critical_wr
                ;
        endproperty

        a_hif_go2critical_l1_wr_chk: assert property(p_hif_go2critical_l1_wr_chk)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        if(UMCTL2_A_USE2RAQ[j]) begin
        // hif_go2critical_l1_hpr will be triggered by rurgent_r/b and qos==hpr.
        property p_hif_go2critical_l1_red_hpr_chk;
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                reg_arb_go2critical_en && reg_rd_port_urgent_en_vector[j] && xpi_rurgent_red[j] && xpi_rqos_hpr[j]
                && ~(DUAL_CHANNEL && (DATA_CHANNEL_INTERLEAVE_NS_TABLE[MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*(j+1)-1:MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*j]) && PA_OPT_TYPE==1) |->
                pa_hif_go2critical_l1_hpr && pa_ddrc_go2critical_hpr
                ;
        endproperty

        a_hif_go2critical_l1_red_hpr_chk: assert property(p_hif_go2critical_l1_red_hpr_chk)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_hif_go2critical_l1_red_vpr_chk;
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                reg_arb_go2critical_en && reg_rd_port_urgent_en_vector[j] && xpi_rurgent_red[j] && xpi_rqos_vpr[j] && ~|xpi_rqos_hpr |->
                pa_hif_go2critical_l1_lpr && pa_ddrc_go2critical_lpr
                ;
        endproperty

        a_hif_go2critical_l1_red_vpr_chk: assert property(p_hif_go2critical_l1_red_vpr_chk)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        
        end // UMCTL2_A_USE2RAQ[j]

        property p_hif_go2critical_l1_blue_vpr_chk;
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                reg_arb_go2critical_en && reg_rd_port_urgent_en_vector[j] && xpi_rurgent_blue[j] && xpi_rqos_vpr[j] && ~|xpi_rqos_hpr |->
                pa_hif_go2critical_l1_lpr && pa_ddrc_go2critical_lpr
                ;
        endproperty

        a_hif_go2critical_l1_blue_vpr_chk: assert property(p_hif_go2critical_l1_blue_vpr_chk)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        
        property p_hif_go2critical_l1_blue_lpr_chk;
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                reg_arb_go2critical_en && reg_rd_port_urgent_en_vector[j] && xpi_rurgent_blue[j] && xpi_rqos_lpr[j] && ~|xpi_rqos_hpr |->
                pa_hif_go2critical_l1_lpr && pa_ddrc_go2critical_lpr
                ;
        endproperty

        a_hif_go2critical_l1_blue_lpr_chk: assert property(p_hif_go2critical_l1_blue_lpr_chk)
            else $error("Inline SVA [%t][%m] FAILED", $time);


        // hif_go2critical_l2_wr will be triggered by
        // 1, exVPW && no wr_credit_cnt   OR
        // 2, exVPR && no wrecc_credit_cnt
        property p_hif_go2critical_l2_wr_chk;
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                xpi_vpw_expired[j] &&
                (
                  (~|wr_credit_cnt)
                )
                |-> pa_hif_go2critical_l2_wr;
        endproperty

        a_hif_go2critical_l2_wr_chk: assert property (p_hif_go2critical_l2_wr_chk)
            else $error("Inline SVA [%t][%m] FAILED", $time);


        // if(UMCTL2_A_USE2RAQ[j]) begin
            // hif_go2critical_l2_hpr will be triggered by exVPR and no hpr_credit_cnt and head queue is HPR
            property p_hif_go2critical_l2_hpr_chk;
                @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                    xpi_vpr_expired[j] && (xpi_rqos_priority[(j+1)*2-1:j*2]==2'b10) && ~|hpr_credit_cnt |-> pa_hif_go2critical_l2_hpr;
            endproperty

            a_hif_go2critical_l2_hpr_chk: assert property (p_hif_go2critical_l2_hpr_chk)
                else $error("Inline SVA [%t][%m] FAILED", $time);

        // end // UMCTL2_A_USE2RAQ[j]



        c_hif_go2critical_l2_lpr_dch1_chk: cover property (
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                (xpi_vpr_expired_dch1[j] && xpi_rqos_priority_dch1[(j+1)*2-1:j*2]==2'b00 && ~|lpr_credit_cnt));
        
        c_hif_go2critical_l2_vpr_dch1_chk: cover property (
            @(posedge core_ddrc_core_clk) disable iff(~core_ddrc_rstn)
                (xpi_vpr_expired_dch1[j] && xpi_rqos_priority_dch1[(j+1)*2-1:j*2]==2'b01 && ~|lpr_credit_cnt));
    end
endgenerate


`endif //SNPS_ASSERT_ON
`endif //SYNTHESIS
 
endmodule // DWC_ddr_arb_top
