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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi.sv#2 $
// -------------------------------------------------------------------------
// Description:
/******************************************************************************
 *                                                                            *
 * DESCRIPTION: DDR Controller Host Port AXI Interface                        *
 *              Interfaces the AXI bus to the Synopsys DDR Controller generic *
 *              host Interface                                                *
 *                                                                            *
 *****************************************************************************/
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi
import DWC_ddrctl_reg_pkg::*;
  #(
    parameter M_DW                        = 32, // MEMORY data width
    parameter M_DW_INT                    = M_DW*2, // MEMORY data width, double if dual channel
    parameter A_DW                        = 32, // Application data width
    parameter A_STRBW                     = 32, // Application strobe width
    parameter A_PARW                      = 32, // Application parity width
    parameter A_DW_INT                    = A_DW*2, // Application data width (internal to XPI)
    parameter A_STRBW_INT                 = A_STRBW*2, // Application strobe width (internal to XPI)
    parameter A_PARW_INT                  = A_PARW*2, // Application parity width (internal to XPI)
    parameter M_ADDRW                     = 32, // MEMORY address width
    parameter NAB                         = 2,
    parameter M_BLW                       = 3,  // Memory burst length width (3->BL8;4->BL16)
    parameter M_ECC                       = 0,
    parameter M_SIDEBAND_ECC              = 0,
    parameter M_INLINE_ECC                = 0,
    parameter NBEATS                      = 4,
    parameter M_LPDDR3                    = 0,
    parameter M_DDR5                      = 0,
    parameter M_USE_RMW                   = 0,
    parameter AXI_ADDRW                   = 32, // AXI address width
    parameter integer AXI_DATAW           = 128,// AXI *data width
    parameter AXI_STRBW                   = 16, // AXI wstrb width
    parameter AXI_IDW                     = 8,  // AXI ID width
    parameter AXI_LENW                    = 6,  // AXI a*len width
    parameter AXI_SIZEW                   = 3,  // AXI a*size width
    parameter AXI_BURSTW                  = 2,  // AXI a*burst width
    parameter AXI_LOCKW                   = 2,  // AXI a*lock width
    parameter AXI_LOCKW_FIX               = 2,  // AXI lock width fixed internally
    parameter AXI_USERW                   = 1,
    parameter AXI_CACHEW                  = 4,  // AXI a*cache width
    parameter AXI_PROTW                   = 3,  // AXI a*prot width
    parameter AXI_QOSW                    = 4,  // AXI a*qos width
    parameter AXI_RESPW                   = 2,  // AXI *resp width  
    parameter AXI_WAQD                    = 4,
    parameter AXI_WAQD_LG2                = 2,
    parameter AXI_WDQD                    = 8,
    parameter AXI_RAQD                    = 4,
    parameter AXI_RAQD_LG2                = 2,   
    parameter AXI_RDQD                    = 8,
    parameter AXI_WRQD                    = 8,
    parameter XPI_RMW_WDQD                = 8,
    parameter AXI_SYNC                    = 1,
    parameter XPI_SQD                     = 34,
    parameter RINFOW                      = 10,
    parameter RINFOW_NSA                  = 10,
    parameter WINFOW                      = 10,
    parameter RPINFOW                     = 6,
    parameter LOWPWR_NOPX_CNT             = 0,
    parameter OUTS_WRW                    = 6,
    parameter OUTS_RDW                    = 7,   
    parameter MEMC_NO_OF_ENTRY            = 32,
    parameter MEMC_TAGBITS                = 16,
    parameter MEMC_BURST_LENGTH           = 8,
    parameter MEMC_WDATA_PTR_BITS         = 8,
    parameter USE_WAR                     = 0,
    parameter USE_RAR                     = 0,
    parameter USE_INPUT_RAR               = 0,
    parameter USE_RDR                     = 0,
    parameter RMW_WARD                    = 2,
    parameter WARD                        = 2,
    parameter RARD                        = 2,
    parameter BRW                         = 4,
    parameter DBW                         = 2,
    parameter AMCOLW                      = 4,
    parameter AMCOLW_C3                   = 5,
    parameter AMCSW                       = 5,
    parameter DDRCTL_LUT_ADDRMAP_EN       = 0,    
    parameter UMCTL2_HET_RANK_EN          = 0,
    parameter ASYNC_FIFO_N_SYNC           = 2,  // Number of synchronizers for async FIFOs
    parameter ASYNC_FIFO_EARLY_PUSH_STAT  = 0,
    parameter ASYNC_FIFO_EARLY_POP_STAT   = 1,  // Only applies to read data queue and write response queue
    parameter A_NPORTS_LG2                = 1,
    parameter A_PORT_NUM                  = 0,  // static instantiation port number
    parameter RQOS_MLW                    = 4,
    parameter RQOS_RW                     = 2,
    parameter RQOS_TW                     = 11,
    parameter USE2RAQ                     = 0,
    parameter VPR_EN                      = 0,
    parameter WQOS_MLW                    = 4,
    parameter WQOS_RW                     = 2,
    parameter WQOS_TW                     = 11,
    parameter VPW_EN                      = 0,
    parameter AP_ASYNC                    = 0, 
    parameter OCPAR_EN                    = 0,
    parameter OCPAR_SLICE_WIDTH           = 8,
    parameter OCPAR_NUM_BYTES             = 32,
    parameter OCPAR_NUM_BYTES_LG2         = 5,
    parameter OCPAR_ADDR_PAR_WIDTH        = 8,
    parameter DUAL_CHANNEL                = 0,
    parameter DATA_CHANNEL_INTERLEAVE     = 0,
    parameter DATA_CHANNEL_INTERLEAVE_NS  = 0,
    parameter DDRCTL_HET_INTERLEAVE       = 0,
    parameter SBR_EN                      = 0,
    parameter MEMC_HIF_ADDR_WIDTH_MAX     = 0,
    parameter PA_OPT_TYPE                 = 1,
    parameter CMD_LEN_BITS                = 1,
    parameter BEAT_INFOW                  = 32,
    parameter USE_RPR                     = 0,
    parameter ECC_RM_WIDTH                = 7,
    parameter ECC_RMG_WIDTH               = 2,
    parameter ECC_H3_WIDTH                = 6,
    parameter OCCAP_EN                    = 0,
    parameter OCCAP_PIPELINE_EN           = 0,
    parameter OCECC_EN                    = 0,
    parameter OCECC_XPI_WR_IN_GRANU       = 64,
    parameter OCECC_XPI_RD_GRANU          = 64,
    parameter OCECC_MR_RD_GRANU           = 8,
    parameter OCECC_MR_BNUM_WIDTH         = 5,
    parameter WDATA_PTR_QD                = 32,
    // Exclusive access Support.
    parameter EXA_ACC_SUPPORT             = 0, 
    parameter EXA_PYLD_W                  = 32,
    parameter EXA_MAX_LENW                = 12, // Worst Case Dowsnsizing is 256/8 with a AXI_LENW of 6
    parameter EXA_MAX_SIZEW               = 3,  // Maximum AXI Size is 3 bits
    parameter EXA_MAX_ADDRW               = 12, // 12 bits for 4K Boundary
    parameter NUM_VIR_CH                  = 1,
    parameter STATIC_VIR_CH               = 1,
    parameter ID_MAPW                     = 8,
    parameter AXI_SAR_BW                  = 32,
    parameter AXI_SAR_SW                  = 8,
    parameter USE_SAR                     = 0,
    parameter NSAR                        = 0,
    parameter SAR_MIN_ADDRW               = 26,
    parameter RRB_EXTRAM                  = 0,
    parameter RRB_EXTRAM_REG              = 0,
    parameter RRB_EXTRAM_RETIME           = 0,
    parameter XPI_SMALL_SIZED_PORT        = 0,
    parameter RDATARAM_DW                 = 16,
    parameter RDATARAM_AW                 = 5,
    parameter RDATARAM_DEPTH              = 0,
    parameter DATARAM_PAR_DW              = 4,
    parameter AXI_ADDR_BOUNDARY           = 12,  // Defines AXI address no crossing boundary ( default is 4k)
    parameter RDWR_ORDERED                = 0,   // Instantiate read/write pre/post-arbiters
    parameter READ_DATA_INTERLEAVE_EN     = 0,   // Enables read data interleaving
    parameter UMCTL2_PARTIAL_WR_EN        = 0,   // PARTIAL_WR supported
    parameter MEMC_DDR4_EN                = 0,
    parameter BCM_VERIF_EN                = 2,
    parameter HWFFC_EN                    = 0,
    parameter RRB_THRESHOLD_EN            = 0,
    parameter RRB_THRESHOLD_PPL           = 0,
    parameter RRB_LOCK_THRESHOLD_WIDTH    = 0,
    parameter IH_TE_PIPELINE              = 0,
    parameter XPI_USE_RMWR_EN             = 1
    )
  (
   // interface to AXI global signals (clock, reset, low-power)
   input                            aclk, // AXI clock
   input                            aresetn, // AXI asynchronous reset
   input                            csysreq, // AXI low-power request
   output                           csysack, // AXI low-power request acknol'g
   output                           cactive, // AXI clock active
   output                           cactive_out, // Internal busy status, to drive uPCTL cactive_in 
   output                           rd_port_busy, // XPI read channel is busy
   output                           wr_port_busy, // XPI write channel is busy
   input [BRW-1:0]                  reg_ddrc_burst_rdwr,
   input [DBW-1:0]                  reg_ddrc_data_bus_width,
   input [DBW-1:0]                  reg_arba_data_bus_width,
   input                            reg_ddrc_burstchop,
   input                            reg_ddrc_wr_crc_enable,

   input                            reg_ddrc_col_addr_shift,
   input [`MEMC_NUM_RANKS-1:0]      reg_ddrc_active_ranks,
   input                            reg_ddrc_alt_addrmap_en,                           
   input [AMCSW-1:0]                reg_ddrc_addrmap_cs_bit0,
   input [AMCSW-1:0]                reg_ddrc_addrmap_cs_bit1,
   input [AMCOLW-1:0]               reg_ddrc_addrmap_col_b2_alt,
   input [AMCOLW_C3-1:0]            reg_ddrc_addrmap_col_b3_alt,
   input [AMCOLW-1:0]               reg_ddrc_addrmap_col_b2,
   input [AMCOLW_C3-1:0]            reg_ddrc_addrmap_col_b3,
   input                            reg_arb_bl_exp_mode,
   input                            reg_arb_port_en,
   input [1:0]                      reg_arb_dch_density_ratio,
   input                            reg_xpi_snf_mode,
  
   // interface to AXI write address channel
   input [AXI_IDW-1:0]              awid, // AXI write address ID
   input [AXI_ADDRW-1:0]            awaddr, // AXI write address
   input [AXI_LENW-1:0]             awlen, // AXI write burst length
   input [AXI_SIZEW-1:0]            awsize, // AXI write burst size
   input [AXI_BURSTW-1:0]           awburst, // AXI write burst type
   input [AXI_LOCKW-1:0]            awlock, // AXI write lock type
   input [AXI_CACHEW-1:0]           awcache, // AXI write cache type
   input [AXI_PROTW-1:0]            awprot, // AXI write protection type
   input [AXI_USERW-1:0]            awuser,
   input [AXI_QOSW-1:0]             awqos, // AXI write Quality of Service
   input                            awurgent, // AXI write urgent transactions
   input                            awvalid, // AXI write address valid
   input                            awpoison, // AXI write poison
   input [OCPAR_ADDR_PAR_WIDTH-1:0] awparity,
   input                            awautopre, // AXI write auto precharge signal 
   output                           awready, // AXI write address ready
  
   // interface to AXI write data channel
   input [AXI_IDW-1:0]              wid, // AXI write ID
   input [AXI_DATAW-1:0]            wdata, // AXI write data
   input [AXI_STRBW-1:0]            wparity, // AXI write data parity
   input [AXI_STRBW-1:0]            wstrb, // AXI write strobes
   input                            wlast, // AXI write last
   input                            wvalid, // AXI write valid
   output                           wready, // AXI write ready
   input [AXI_USERW-1:0]            wuser,
  
   // interface to AXI write response channel
   output [AXI_IDW-1:0]             bid, // AXI write response ID
   output [AXI_RESPW-1:0]           bresp, // AXI write response
   output [AXI_USERW-1:0]           buser,
   output                           bvalid, // AXI write response valid
   input                            bready, // AXI write response ready
  
   // interface to AXI read address channel
   input [AXI_IDW-1:0]              arid, // AXI read address ID
   input [AXI_ADDRW-1:0]            araddr, // AXI read address
   input [AXI_LENW-1:0]             arlen, // AXI read burst length
   input [AXI_SIZEW-1:0]            arsize, // AXI read burst size
   input [AXI_BURSTW-1:0]           arburst, // AXI read burst type
   input [AXI_LOCKW-1:0]            arlock, // AXI read lock type
   input [AXI_CACHEW-1:0]           arcache, // AXI read cache type
   input [AXI_PROTW-1:0]            arprot, // AXI read protection type
   input [AXI_USERW-1:0]            aruser,
   input [AXI_QOSW-1:0]             arqos, // AXI read Quality of Service
   input                            arurgentb, // AXI read urgent transactions
   input                            arurgentr, // AXI read urgent transactions
   input                            arvalid, // AXI read address valid
   input                            arpoison, // AXI read poison
   input [OCPAR_ADDR_PAR_WIDTH-1:0] arparity,
   input                            arautopre,// AXI read auto precharge signal
   output                           arready, // AXI read address ready
  
   // interface to AXI read data channel
   output [AXI_IDW-1:0]             rid, // AXI read ID
   output [AXI_DATAW-1:0]           rdata, // AXI read data
   output [AXI_STRBW-1:0]           rparity, // read data parity
   output [AXI_RESPW-1:0]           rresp, // AXI read response
   output [AXI_USERW-1:0]           ruser,
   output                           rlast, // AXI read last
   output                           rvalid, // AXI read valid
   input                            rready, // AXI read ready
  
   // Extended Native Interface:
   input                            e_clk, // ENIF clock
   input                            e_rst_n, // ENIF asynchronous reset
  
   // ENIF Write Address channel
   output [M_ADDRW-1:0]             xpi_awaddr, // XPI write address 
   output                           xpi_awrmw, // XPI write read modify write 
   output [AXI_QOSW-1:0]            xpi_awqos, // XPI write address qos
   output                           xpi_awpagematch, // XPI write page match 
   output                           xpi_awautopre, // XPI write address channel auto precharge
   output                           xpi_exa_awlast, // XPI last valid address
   output                           xpi_exa_short_burst, // short wrap burst
   output [M_ADDRW-1:0]             xpi_awaddr_dcb, // XPI write address 
   output                           xpi_awrmw_dcb, // XPI write read modify write 
   output [AXI_QOSW-1:0]            xpi_awqos_dcb, // XPI write address qos
   output                           xpi_awpagematch_dcb, // XPI write page match 
   output                           xpi_awautopre_dcb, // XPI write address channel auto precharge
   output                           xpi_exa_awlast_dcb, // XPI last valid address
   output                           xpi_exa_short_burst_dcb, // short wrap burst
   output [NBEATS-1:0]              xpi_wdata_mask_full,
   output [NBEATS-1:0]              xpi_wdata_mask_full_dcb,
   output [CMD_LEN_BITS-1:0]        xpi_rxcmd_wlength,
   output [CMD_LEN_BITS-1:0]        xpi_rxcmd_wlength_dcb,
   // first channel
   output                           xpi_awvalid_dca, // XPI write address valid
   input                            hif_awready_dca, // HIF write address ready
    // second channel
   output                           xpi_awvalid_dcb, // XPI write address valid
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            hif_awready_dcb, // HIF write address ready
//spyglass enable_block W240

   output [WQOS_RW-1:0]             xpi_wqos_priority,
   output [WQOS_TW-1:0]             xpi_wqos_timeout,
   output                           xpi_vpw_expired,
   output [WQOS_RW-1:0]             xpi_wqos_priority_dcb,
   output [WQOS_TW-1:0]             xpi_wqos_timeout_dcb,
   output                           xpi_vpw_expired_dcb,

   // ENIF Read Address channel
   // channel 0
   output [M_ADDRW-1:0]             xpi_araddr_blue, // XPI read address 
   output [AXI_QOSW-1:0]            xpi_arqos_blue, // XPI read address qos
   output [RQOS_RW-1:0]             xpi_rqos_priority_blue,
   output [RQOS_TW-1:0]             xpi_rqos_timeout_blue,
   output                           xpi_vpr_expired_blue,
   output                           xpi_arpagematch_blue, // XPI write page match
   output                           xpi_arautopre_blue, // XPI read address channel auto precharge

   // channel 1
   output [M_ADDRW-1:0]             xpi_araddr_blue_dcb, // XPI read address 
   output [AXI_QOSW-1:0]            xpi_arqos_blue_dcb, // XPI read address qos
   output [RQOS_RW-1:0]             xpi_rqos_priority_blue_dcb,
   output [RQOS_TW-1:0]             xpi_rqos_timeout_blue_dcb,
   output                           xpi_vpr_expired_blue_dcb,
   output                           xpi_arpagematch_blue_dcb, // XPI write page match
   output                           xpi_arautopre_blue_dcb, // XPI read address channel auto precharge
   // first channel
   output                           xpi_arvalid_blue_dca, // XPI read address valid
   input                            hif_arready_blue_dca, // XPI read address ready
   input                            hif_arready_red_dca, // XPI read address ready
    // second channel
   output                           xpi_arvalid_blue_dcb, // XPI read address valid
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            hif_arready_blue_dcb, // XPI read address ready
   input                            hif_arready_red_dcb, // XPI read address ready
//spyglass enable_block W240
  
   // ENIF Write Data Channel
   // channel 0
   output [A_DW-1:0]                xpi_wdata, // XPI write data
   output [A_STRBW-1:0]             xpi_wstrb, // XPI write data strobe
   output                           xpi_wlast, // XPI write data last
   output                           xpi_wlast_pkt, // XPI write last beat of the packet
//spyglass disable_block W241
//SMD: Output 'xpi_snf_mode' is never set.
//SJ: Output set in generate block so must always exist. Not set in DUAL_CHANNEL with DATA_CHANNEL_INTERLEAVE_NS==1 configs.
   output                           xpi_snf_mode,     // XPI Port store and forward status indication
//spyglass enable_block W241
   output [A_STRBW-1:0]             xpi_wpar_err, // write data parity error
   output [A_PARW-1:0]              xpi_wparity, // write data parity
   // channel 1
   output [A_DW-1:0]                xpi_wdata_dcb, // XPI write data
   output [A_STRBW-1:0]             xpi_wstrb_dcb, // XPI write data strobe
   output                           xpi_wlast_dcb, // XPI write data last
   output                           xpi_wlast_pkt_dcb, // XPI write last beat of the packet
//spyglass disable_block W241
//SMD: Output 'xpi_snf_mode_dcb' is never set.
//SJ: Output set in generate block so must always exist. Not set in DUAL_CHANNEL with DATA_CHANNEL_INTERLEAVE_NS==1 configs.
   output                           xpi_snf_mode_dcb,     // XPI Port store and forward status indication
//spyglass enable_block W241
   output [A_STRBW-1:0]             xpi_wpar_err_dcb, // write data parity error
   output [A_PARW-1:0]              xpi_wparity_dcb, // write data parity
    // first channel
   output                           xpi_wvalid_dca, // XPI write data valid
   input                            hif_wready_dca, // HIF write data ready
    // second channel
   output                           xpi_wvalid_dcb, // XPI write data valid
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            hif_wready_dcb, // HIF write data ready
//spyglass enable_block W240
  
   // ENIF Read Data Channel
    // first channel
   input [A_DW-1:0]                 hif_hif_rdata_dca, // ENIF read data
   input [A_STRBW-1:0]              hif_hif_rdata_parity_dca,
   input                            hif_rerror_dca, // ENIF read data error
   input                            hif_rlast_pkt_dca, // ENIF read paket data last   
   input                            hif_rvalid_dca, // ENIF read data valid
    // second channel
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [A_DW-1:0]                 hif_hif_rdata_dcb, // ENIF read data
   input [A_STRBW-1:0]              hif_hif_rdata_parity_dcb,   
   input                            hif_rerror_dcb, // ENIF read data error   
   input                            hif_rlast_pkt_dcb, // ENIF read paket data last   
//spyglass enable_block W240   
   input                            hif_rvalid_dcb, // ENIF read data valid
  
   // ENIF Write Response Channel
   output                           xpi_bready_dca, // ENIF Write Response ready
   output                           xpi_bready_dcb, // ENIF Write Response ready
    // first channel
   input                            hif_bvalid_dca, // ENIF Write Response valid 
   input [AXI_IDW-1:0]              xpi_bid_dca, // ENIF Write Response ID
   input                            e_exa_bresp_dca, // ENIF Exclusive Access Response
   input                            e_aw_slverr_dca, // ENIF error response
   input [AXI_USERW-1:0]            xpi_buser_dca,
    // second channel
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            hif_bvalid_dcb, // ENIF Write Response valid 
//spyglass enable_block W240
   input [AXI_IDW-1:0]              xpi_bid_dcb, // ENIF Write Response ID
   input                            e_exa_bresp_dcb, // ENIF Exclusive Access Response
   input                            e_aw_slverr_dcb, // ENIF error response
   input [AXI_USERW-1:0]            xpi_buser_dcb,

    // first channel
   input [MEMC_TAGBITS-1:0]         e_resp_token_dca,
    // second channel
   input [MEMC_TAGBITS-1:0]         e_resp_token_dcb,

   output [MEMC_TAGBITS-1:0]        xpi_rxcmd_token_blue,
   output [MEMC_TAGBITS-1:0]        xpi_rxcmd_token_blue_dcb,
   output [MEMC_WDATA_PTR_BITS-1:0] xpi_rxcmd_wdata_ptr,
   output [MEMC_WDATA_PTR_BITS-1:0] xpi_rxcmd_wdata_ptr_dcb,
   output [CMD_LEN_BITS-1:0]        xpi_rxcmd_rlength_blue,
   output [CMD_LEN_BITS-1:0]        xpi_rxcmd_rlength_red,
  
   output [EXA_PYLD_W-1:0]          xpi_wexa_pyld, // Exclusive Write Payload
   output [EXA_PYLD_W-1:0]          xpi_wexa_pyld_dcb, // Exclusive Write Payload
   output [EXA_PYLD_W-1:0]          xpi_rexa_pyld_blue, // Exclusive Read Payload
   output [EXA_PYLD_W-1:0]          xpi_rexa_pyld_blue_dcb, // Exclusive Read Payload
   input                            reg_ddrc_ddr4, // device is ddr4
   input                            reg_ddrc_ddr5, // device is ddr5
   input                            reg_ddrc_lpddr4, // device is lpddr4
   input                            reg_ddrc_lpddr5, // device is lpddr5
   input                            reg_ddrc_dm_enb, // data mask enable
   input                            reg_arb_bypass_reorder, // enable bypass reorder 
   input [NUM_VIR_CH*ID_MAPW-1:0]   reg_arb_id_mask, // Virtual channels id mask 
   input [NUM_VIR_CH*ID_MAPW-1:0]   reg_arb_id_value,       // Virtual channels id value 

   // RRB SBAM enhancement
   input [RRB_LOCK_THRESHOLD_WIDTH-1:0] reg_arb_rrb_lock_threshold,

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
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
//spyglass enable_block W240
   // oc parity config
   input                            reg_arb_oc_parity_en, // @aclk enable on-chip parity
   input                            reg_arb_oc_parity_type, // @aclk select parity type: 0 even, 1 odd
   input                            reg_ddrc_oc_parity_type, // @core_clock
   input                            reg_arb_address_parity_mode, // enable address parity check
   input                            reg_arb_par_addr_slverr_en, // enable slverr response when address parity error

   input                            reg_arb_write_data_parity_mode, // enable write data parity check
   input                            reg_arb_read_data_parity_mode, // enable read data parity check
   input                            reg_arb_par_rdata_slverr_en, // enable slverr for read data parity errors

   // occap configuration
   input                            reg_ddrc_occap_en,
   input                            reg_arb_occap_arb_cmp_poison_seq,
   input                            reg_arb_occap_arb_cmp_poison_parallel,
   input                            reg_arb_occap_arb_cmp_poison_err_inj,
   input                            reg_ddrc_occap_arb_cmp_poison_seq,
   input                            reg_ddrc_occap_arb_cmp_poison_parallel,
   input                            reg_ddrc_occap_arb_cmp_poison_err_inj,
   input                            reg_arb_occap_arb_raq_poison_en, 

   // ocecc
   input                            ocecc_en,
   input                            ocecc_poison_egen_mr_rd_0,
   input [OCECC_MR_BNUM_WIDTH-1:0]  ocecc_poison_egen_mr_rd_0_byte_num,
   input                            ocecc_poison_egen_xpi_rd_out,
   input                            ocecc_poison_single,
   input                            ocecc_wdata_slverr_en,
   input                            ocecc_rdata_slverr_en,

   // axi transaction poison config
   input                            reg_ddrc_rd_poison_slverr_en,
   input                            reg_ddrc_rd_poison_intr_en,
   input                            reg_ddrc_rd_poison_intr_clr,
   output                           rd_poison_intr,
   // ocpar poison config
   input                            rd_poison_en,
   input                            wr_poison_en,

   input [OCPAR_NUM_BYTES_LG2-1:0]  reg_ddrc_par_poison_byte_num,

   input                            par_wdata_err_intr_clr,
   input                            par_rdata_err_intr_clr,

   input                            par_wdata_axi_check_bypass_en,

   // parity outputs
   output                           par_waddr_err_pulse,
   output                           par_raddr_err_pulse,
   output                           par_rdata_err_pulse,

   output                           par_wdata_in_err_pulse,

   output [AXI_ADDRW-1:0]           par_raddr_log, // last read failing address
   output [AXI_ADDRW-1:0]           par_waddr_log, // last write failing address
   output [OCPAR_NUM_BYTES-1:0]     par_rdata_byte_log, // last failing byte

   // ocecc output
   output                           ocecc_xpi_write_uncorr_err,
   output                           ocecc_xpi_read_uncorr_err,
   output                           ocecc_xpi_write_corr_err,
   output                           ocecc_xpi_read_corr_err,

   // occap output
   output                           aa_parity_err,
   output                           cc_parity_err,
   output                           ac_cmp_err,
   output                           ac_cmp_err_full,
   output                           ac_cmp_err_seq,
   output                           cc_cmp_err,
   output                           cc_cmp_err_full,
   output                           cc_cmp_err_seq,
   output                           ac_cmp_poison_complete,
   output                           cc_cmp_poison_complete,

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.

   // inline ecc
   input [ECC_RM_WIDTH-1:0]         reg_ddrc_ecc_region_map,
   input [ECC_RMG_WIDTH-1:0]        reg_ddrc_ecc_region_map_granu,
   input                            reg_ddrc_ecc_region_map_other,

   // External read data RAM interface
   input [RDATARAM_DW-1:0]          rdataram_dout,
   input [DATARAM_PAR_DW-1:0]       rdataram_dout_par,
   input [RDATARAM_DW-1:0]          rdataram_dout_dcb,
   input [DATARAM_PAR_DW-1:0]       rdataram_dout_par_dcb,     
//spyglass enable_block W240
   output [RDATARAM_DW-1:0]         rdataram_din,
   output                           rdataram_wr,
   output                           rdataram_re,
   output [RDATARAM_AW-1:0]         rdataram_raddr,
   output [RDATARAM_AW-1:0]         rdataram_waddr,
   output [DATARAM_PAR_DW-1:0]      rdataram_din_par,
   output [RDATARAM_DW-1:0]         rdataram_din_dcb,
   output                           rdataram_wr_dcb,
   output                           rdataram_re_dcb,
   output [RDATARAM_AW-1:0]         rdataram_raddr_dcb,
   output [RDATARAM_AW-1:0]         rdataram_waddr_dcb,
   output [DATARAM_PAR_DW-1:0]      rdataram_din_par_dcb,

   // QOS configuration
   input [RQOS_MLW-1:0]             rqos_map_level1,
   input [RQOS_MLW-1:0]             rqos_map_level2,
   input [RQOS_RW-1:0]              rqos_map_region0,
   input [RQOS_RW-1:0]              rqos_map_region1,
   input [RQOS_RW-1:0]              rqos_map_region2,
   input [RQOS_TW-1:0]              rqos_map_timeoutb,
   input [RQOS_TW-1:0]              rqos_map_timeoutr,
   input [WQOS_MLW-1:0]             wqos_map_level1,
   input [WQOS_MLW-1:0]             wqos_map_level2,
   input [WQOS_RW-1:0]              wqos_map_region0,
   input [WQOS_RW-1:0]              wqos_map_region1,
   input [WQOS_RW-1:0]              wqos_map_region2,
   input [WQOS_TW-1:0]              wqos_map_timeout1,
   input [WQOS_TW-1:0]              wqos_map_timeout2,
   // Page match mask
   input [M_ADDRW-1:0]              pagematch_addrmap_mask,
   input                            reg_arb_rd_port_pagematch_en,
   input                            reg_arb_wr_port_pagematch_en,
   // data channel mask
   input [M_ADDRW-1:0]              data_channel_addrmap_mask,
   // bankgroup mask
   input [M_ADDRW-1:0]              bg_or_bank_addrmap_mask,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            reg_arb_rdwr_ordered_en,
   input                            reg_arba_rdwr_ordered_en,
   input                            reg_arb_port_data_channel,
   // column mask
   input [ECC_H3_WIDTH-1:0]         h3_iecc_col_mask,   
//spyglass enable_block W240
   
   input [5:0]                      e_addr_max_loc,
   input [5:0]                      e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]              e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]              e_addr_max_m1_loc_addrmap_mask,
   input [5:0]                      dch_bit,

   // Urgent signals
   output                           rurgent_blue,
   output                           wurgent_blue,
   output                           rurgent_red,
   output                           wurgent_red,
   // Red read queue outputs
   output [MEMC_TAGBITS-1:0]        xpi_rxcmd_token_red,
   output [EXA_PYLD_W-1:0]          xpi_rexa_pyld_red, // Exclusive Read Payload
   output [M_ADDRW-1:0]             xpi_araddr_red, // XPI read address
   output [AXI_QOSW-1:0]            xpi_arqos_red, // XPI read address qos
   output [RQOS_RW-1:0]             xpi_rqos_priority_red,
   output [RQOS_TW-1:0]             xpi_rqos_timeout_red,
   output                           xpi_vpr_expired_red,
   output                           xpi_arpagematch_red, // XPI write page match
   output                           xpi_arautopre_red, // XPI read auto precharge
    // dummy wires for channel 1, not supported with dual queue
   output [MEMC_TAGBITS-1:0]        xpi_rxcmd_token_red_dcb,
   output [EXA_PYLD_W-1:0]          xpi_rexa_pyld_red_dcb, // Exclusive Read Payload
   output [M_ADDRW-1:0]             xpi_araddr_red_dcb, // XPI read address
   output [AXI_QOSW-1:0]            xpi_arqos_red_dcb, // XPI read address qos
   output [RQOS_RW-1:0]             xpi_rqos_priority_red_dcb,
   output [RQOS_TW-1:0]             xpi_rqos_timeout_red_dcb,
   output                           xpi_vpr_expired_red_dcb,
   output                           xpi_arpagematch_red_dcb, // XPI write page match
   output                           xpi_arautopre_red_dcb, // XPI read auto precharge
   // first channel
   output                           xpi_arvalid_red_dca, // XPI read address valid
   // second channel
   output                           xpi_arvalid_red_dcb, // XPI read address valid
   // read/write queue debug signals
   output [AXI_RAQD_LG2:0]          raqb_wcount,
   output                           raqb_pop,
   output                           raqb_push,
   output [AXI_RAQD_LG2:0]          raqr_wcount,
   output                           raqr_pop,
   output                           raqr_push,
   output                           raq_split,
   output [AXI_WAQD_LG2:0]          waq_wcount,
   output                           waq_pop,
   output                           waq_push,
   output                           waq_split,
  
   // For HWFFC
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            ddrc_xpi_port_disable_req, // port disable request from DDRC
//spyglass enable_block W240
   input                            ddrc_xpi_clock_required,   // port clock request from DDRC
   output                           xpi_ddrc_port_disable_ack, // port disable acknowledge to DDRC
   output                           xpi_ddrc_wch_locked        // WR channel locked to DDRC

   );

// VCS UNR CONSTRAINT declarations
`SNPS_UNR_CONSTRAINT("In dual RAQ configs, qos priority values of Blue queue will be always less than that of Red queue", (USE2RAQ==1), e_clk, (xpi_arqos_red > xpi_arqos_blue))

// VCS UNR CONSTANT declarations
`SNPS_UNR_CONSTANT("If AXI_USER_WIDTH is 0 in config, dummy signal is used internally", 1, buser[0], 1'b0)
`SNPS_UNR_CONSTANT("If AXI_USER_WIDTH is 0 in config, dummy signal is used internally", 1, ruser[0], 1'b0)

`SNPS_UNR_CONSTANT("If exclusive access is not supported, EXOKAY response is not driven out", 1, rresp[0], 1'b0)
`SNPS_UNR_CONSTANT("If exclusive access is not supported, EXOKAY response is not driven out", 1, bresp[0], 1'b0)
  
  //---------------------------------------------------------------------------
  // Local Parameters 
  //---------------------------------------------------------------------------  

      //+-------+-------------------------------------------------------------------+
      //|       |                    Programmable DRAM Bus Width                    |
      //+ Case  +-------------------------------------------------------------------+
      //|       |         FBW       |           HBW         |           QBW         |
      //+-------+-------------------+-----------------------+-----------------------+
      //|       |                   |                       |                       |
      //| Case1 |        Native     |     Downsize-by-2^N   |   Downsize-by-2^(N+1) |
      //|       |                   |                       |                       |
      //+-------+-------------------+-----------------------+-----------------------+
      //|       |                   |                       |                       |
      //| Case2 |    Upsize-by-2^N  |          Native       |     Downsize-by-2^N   |
      //|       |                   |                       |                       |
      //+-------+-------------------+-----------------------+-----------------------+
      //|       |                   |                       |                       |
      //| Case3 |    Upsize-by-2^N  |    Upsize-by-2^(N-1)  |          Native       |
      //|       |                   |                       |                       |
      //+-------+-------------------+-----------------------+-----------------------+
      //|       |                   |                       |                       |
      //| Case4 |    Upsize-by-2^N  |    Upsize-by-2^(N-1)  |    Upsize-by-2^(N-2)  |
      //|       |                   |                       |                       |
      //+-------+-------------------+-----------------------+-----------------------+
      //|       |                   |                       |                       |
      //| Case5 |   Downsize-by-2^N |   Downsize-by-2^(N+1) |   Downsize-by-2^(N+2) |
      //|       |                   |                       |                       |
      //+-------+-------------------+-----------------------+-----------------------+                                   
    localparam  PDBW_CASE = (AXI_DATAW==A_DW_INT)     ? 1  : //Case1 
                            (AXI_DATAW==(A_DW_INT/2)) ? 2  : //Case2 
                            (AXI_DATAW==(A_DW_INT/4)) ? 3  : //Case3   
                            (AXI_DATAW <(A_DW_INT/4)) ? 4  : //Case4
                            (AXI_DATAW > A_DW_INT )   ? 5    //Case5
                            : 0  ; //Default


    localparam integer M_DW_HBW =  (M_DW > 8)  ? M_DW/2  : M_DW;
    localparam integer M_DW_QBW =  (M_DW > 16) ? M_DW/4  : M_DW_HBW;

    localparam integer MIN_M_DW =  M_DW_QBW;
                                        
    localparam integer MIN_M_BL = (`MEMC_DDR4_EN == 1) ? 8 : 16 ;
    localparam integer MIN_DRAM_XSIZE = (MIN_M_DW * MIN_M_BL);
    //localparam integer DRAM_XSIZE_FBW = (M_DW * MIN_M_BL);
    //localparam integer DRAM_XSIZE_HBW = (M_DW_HBW * MIN_M_BL);
    //localparam integer DRAM_XSIZE_QBW = (M_DW_QBW * MIN_M_BL);
    localparam integer M_NB_LG2 = $clog2(M_DW/8); 
    //localparam integer M_DW_HBW = (M_DW > 8) ? M_DW/2 : M_DW ;
    //localparam integer M_DW_QBW = (M_DW > 16) ? M_DW/4 : M_DW_HBW;
   // BAM support is needed when HIF burst size is smaller than AXI RDATA beat size 
    localparam USE_BAM  = (READ_DATA_INTERLEAVE_EN==1) && (XPI_SMALL_SIZED_PORT==1) && ((NUM_VIR_CH>1) || (USE2RAQ==1)) ? 1 : 0;

  //localparam UP_SIZE       = (AXI_DATAW<A_DW) ? 1 :0; //TBD-HRE : remove if redundant
  //localparam DOWN_SIZE     = (AXI_DATAW>A_DW) ? 1 :0; //TBD-HRE : remove if redundant 
  localparam UPSIZE_IN_FBW = (AXI_DATAW<A_DW_INT) ? 1 : 0;
  localparam DWSIZE_IN_QBW = ( (AXI_DATAW > (A_DW_INT/4)) &&
                              !(PDBW_CASE==2 && M_DW<32)      // In Case2 there is no need of downsizer if M_DW doesnt support QBW
                             ) ? 1 : 0; // IN QBW effective A_DW is A_DW/4
  
    localparam UP_SIZE_INT   = UPSIZE_IN_FBW; 
    localparam DOWN_SIZE_INT = DWSIZE_IN_QBW;


  localparam AXI_MAXSIZE   = `UMCTL_LOG2(AXI_STRBW);     // AXI Maximum size
  localparam AXI_SIZEW_LOC = (`UMCTL_LOG2(AXI_MAXSIZE+1)==0) ? 1 : `UMCTL_LOG2(AXI_MAXSIZE+1);

  localparam DUAL_CHANNEL_INTERLEAVE      = (DUAL_CHANNEL==1 && DATA_CHANNEL_INTERLEAVE==1) ? 1 : 0;
  localparam DUAL_CHANNEL_INTERLEAVE_HP   = (DUAL_CHANNEL_INTERLEAVE==1 && DATA_CHANNEL_INTERLEAVE_NS==1) ? 1 : 0;
  localparam DUAL_CHANNEL_INTERLEAVE_LP   = (DUAL_CHANNEL_INTERLEAVE==1 && DATA_CHANNEL_INTERLEAVE_NS==0) ? 1 : 0;

  localparam ACC_INFOW     = (DUAL_CHANNEL_INTERLEAVE_HP==1) ? AXI_MAXSIZE : 1;
  
  localparam ENIF_MAXSIZE_INT = `UMCTL_LOG2(A_STRBW_INT);     // NIF Maximum size
  localparam ENIF_SIZEW_INT   = `UMCTL_LOG2(ENIF_MAXSIZE_INT+1); 
  localparam ENIF_MAXSIZE = `UMCTL_LOG2(A_STRBW);     // NIF Maximum size
  localparam ENIF_SIZEW   = `UMCTL_LOG2(ENIF_MAXSIZE+1);
  
  localparam MAXSIZE = (UP_SIZE_INT==1) ? ENIF_MAXSIZE_INT : AXI_MAXSIZE; 

  localparam LOWPWR_NOPX_CNT_W = (LOWPWR_NOPX_CNT==0) ? 1 : (`UMCTL_LOG2(LOWPWR_NOPX_CNT + 1)); // Extra bit if necessary to load LOWPWR_NOPX_CNT into internal counter
  
  localparam MEMC_NO_OF_ENTRY_LG2 = `UMCTL_LOG2(MEMC_NO_OF_ENTRY);
  localparam NBEATS_LG2 = `UMCTL_LOG2(NBEATS);
  localparam INTLVMODEW = BEAT_INFOW-NBEATS_LG2*2;

  localparam RRBIW = BEAT_INFOW+1+1+1+1+1+RINFOW+AXI_IDW+AXI_USERW; // beat_info+Exclusive Access+poison+ocpar_err+queue type+rlast+info+id+user
  localparam NUM_VIR_CH_LG2 = (`UMCTL_LOG2(NUM_VIR_CH)==0) ? 1:`UMCTL_LOG2(NUM_VIR_CH);
  // Total number of channels is number of virtual channels + 1 bypass channel
  localparam NUM_CH = NUM_VIR_CH +STATIC_VIR_CH;
  localparam NUM_CH_LG2 = (`UMCTL_LOG2(NUM_CH)==0) ? 1: `UMCTL_LOG2(NUM_CH);
  
  // RRB Retime info width 
  localparam RRBRIW = (DUAL_CHANNEL_INTERLEAVE==1) ? NUM_CH_LG2+1+1+1+1+1+RINFOW+AXI_IDW+AXI_USERW+MEMC_NO_OF_ENTRY_LG2+1 : NUM_CH_LG2+1+1+1+1+1+RINFOW+AXI_IDW+AXI_USERW+1; // Exclusive Access+queue+poison+ocpar_err+info+id+user+rerror
  
  localparam A_BLW = M_BLW-NAB+1;

  // Maximum number of AXI transactions that XPI can buffer in WAQ, WAR, RAQ, RAR, and RMW
  localparam ORDER_TOKEN_NUM = AXI_WAQD+
                               AXI_RAQD+
                               ((USE2RAQ==1) ? AXI_RAQD : 0) + // RAQ depth
                               ((USE_RAR==1) ? RARD : 0) +    // output RAR depth
                               ((USE_INPUT_RAR==1) ? RARD : 0) +    // input RAR depth
                               ((USE_WAR==1) ? WARD : 0) +    // WAR depth
                               ((M_USE_RMW==1) ? RMW_WARD : 0) ;  // RMW block WAR depth

  localparam ORDER_TOKENW = (RDWR_ORDERED==1) ? `UMCTL_LOG2(ORDER_TOKEN_NUM) : 1;
  localparam POSTED_WRBW = 16;

  localparam BLUE_QUEUE   = 1'b0;
  localparam RED_QUEUE    = 1'b1;

  localparam VPRW_PUSH_SYNC_DEPTH = 10; // depth for the push synchronizer in case of vpr/vpw

  localparam VPRW         = 2'b01;

  localparam QBW           = 2'b10;
  localparam HBW           = 2'b01;
  localparam FBW           = 2'b00;
  localparam BL2           = 4'b0001;
  localparam BL4          = 4'b0010;
  localparam BL8           = 4'b0100;
  localparam BL16          = 4'b1000;

  localparam RDATARAM_DW_INT  = (RRB_EXTRAM==1) ? RDATARAM_DW : (OCPAR_EN==1 || OCECC_EN==1) ? RDATARAM_DW+DATARAM_PAR_DW : RDATARAM_DW;

  localparam DCM_NTOKENS      = (DUAL_CHANNEL_INTERLEAVE==1) ? MEMC_NO_OF_ENTRY*2 : MEMC_NO_OF_ENTRY;
  localparam DCM_NTOKENS_LG2  = `UMCTL_LOG2(DCM_NTOKENS);

  localparam DCR_NTOKENS      = MEMC_NO_OF_ENTRY*3; // twice the cam depth not enough
  localparam DCR_NTOKENS_LG2  = `UMCTL_LOG2(DCR_NTOKENS);

  localparam NUM_DATA_CHANNELS = DUAL_CHANNEL==1 ? 2 : 1;

  localparam RDRW             = AXI_IDW+1+NUM_CH_LG2+1+1+1+1+RINFOW+AXI_USERW; // rrb_rid + rrb_rd_last + rrb_ch_num + rrb_queue + rrb_rexa_acc_instr + rrb_rpoison + rrb_ocpar_err + rrb_rinfo + rrb_ruser
  localparam RDRDW            = A_DW_INT+A_STRBW_INT+NUM_DATA_CHANNELS; //rrb_rdata + rrb_rdata_parity + rrb_rerror 
  localparam RRBDPW           = RDRW+RDRDW;
  localparam RRBRTDPW         = RRBDPW+MEMC_NO_OF_ENTRY_LG2; // +token

  localparam DCH_RD_INFOW     = (SBR_EN==1&&M_INLINE_ECC==0) ? M_ADDRW+AXI_QOSW+RQOS_RW+1+(MEMC_TAGBITS-MEMC_HIF_ADDR_WIDTH_MAX)+EXA_PYLD_W+1 : M_ADDRW+AXI_QOSW+RQOS_RW+1+MEMC_TAGBITS+EXA_PYLD_W+1;

  localparam DCH_WR_INFOW     = M_ADDRW+AXI_QOSW+1+1+1+1+1+AXI_IDW+4+WQOS_RW+EXA_PYLD_W+AXI_USERW;

  localparam DEACC_INFOW      = AXI_MAXSIZE>0 ? AXI_MAXSIZE : 1;

  localparam DEACC_RT_W       = NBEATS/2;
  localparam DEACC_RT_W_LG2   = `UMCTL_LOG2(DEACC_RT_W);
  localparam DEACC_DW         = A_DW_INT+2*A_STRBW_INT+A_PARW_INT+1+1+DEACC_INFOW;

  localparam OCCAP_CMP_CC     = 1; // core clock comparators: rp/wp
  localparam OCCAP_CMP_AC     = 2; // aclk comparators: ws, au
  localparam OCCAP_CMP_IF     = 2; // xpi read/write

  localparam A_CMP_P          = OCCAP_CMP_AC*OCCAP_CMP_IF; // total number of aclk comparators, collect complete bit in a vector
  localparam C_CMP_P          = OCCAP_CMP_CC*OCCAP_CMP_IF; // total number of core clk comparators, collect complete bit in a vector

  localparam BUSY_REGS_W      = 3+OUTS_WRW+OUTS_RDW+POSTED_WRBW;

  localparam WRQW             = AXI_IDW + 1 + 1 + AXI_USERW;  // ID + Exclusive Write Response + slverr + user

  localparam AXI_PRE_WRQD     = 4;

  localparam AXI_PRE_WRQD_LG2 = `UMCTL_LOG2(AXI_PRE_WRQD);

  localparam AXI_WPTRQD       = 2*WDATA_PTR_QD+4+2*AXI_PRE_WRQD+((IH_TE_PIPELINE==1) ? 4 : 0);

  localparam AXI_WPTRQD_LG2   = `UMCTL_LOG2(AXI_WPTRQD);

  localparam AXI_WPTRQW       = 1+1;

  localparam BAM_OFFSW        = `UMCTL_LOG2(AXI_DATAW/MIN_DRAM_XSIZE);

  // internal bcm07 parameters
  localparam PUSH_AE_LVL      =  2; 
  localparam PUSH_AF_LVL      =  2;
  localparam POP_AE_LVL       =  2;
  localparam POP_AF_LVL       =  2;
  localparam ERR_MODE         =  0;
  

  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------

  wire                              i_reg_arb_port_en;

  wire                              awvalid_l;
  wire                              awready_l;
  wire                              arready_l;
  wire                              arvalid_l;
  wire                              wvalid_l;
  wire                              wready_l;
  
  wire                              ready_lp;
  wire                              rd_port_busy_next, wr_port_busy_next;
  wire [OUTS_WRW-1:0]               outstanding_writes, outstanding_writes_next;
  wire [OUTS_RDW-1:0]               outstanding_reads, outstanding_reads_next;
  wire                              active_writes;
  wire                              active_reads;
  wire                              active_trans;
  //wire                             cactive;      // AXI clock active
  wire                              cactive_reg_next;    // Registred cactive in aclk
  reg                               cactive_reg;    // Registred cactive in aclk
  wire                              siu_bl2;
  wire                              siu_bl4;
  wire                              siu_bl8;
  wire                              siu_bl16;
  wire                              ddrc_bl4, ddrc_bl8, ddrc_bl16;
  wire                              ddrc_qbw, ddrc_hbw, ddrc_fbw;
  wire [A_BLW-1:0]                  a_bl; // Application burst length (m_bl/(NAB*2))
  wire                              wdq_empty_aclk;
  

  wire                              rrb_wr_dca, rrb_rd, rrb_rd_i_dca, rrb_full_dca, rrb_empty_dca;
  wire                              rrb_rvalid, dcr_rvalid_dca, dcr_rvalid_dcb, rrb_rvalid_i;
  wire                              rrb_rvalid_up, rrb_rvalid_dca, rrb_rvalid_dcb;
  wire [RDATARAM_DW_INT-1:0]        rrb_d_dca,rrb_q_dca, rrb_q_int_dca;
  wire [DATARAM_PAR_DW-1:0]         rrb_par_d_dca, rrb_par_q_int_dca;
  wire [RRBIW-1:0]                  rrb_infod_dca,rrb_infoq_dca;
  wire [NUM_DATA_CHANNELS-1:0]      rrb_rerror;
  wire                              rrb_rerror_r_dca, rrb_rerror_r_dcb;
  wire                              rrb_rerror_i_dca, rrb_rerror_i_dcb;
  wire [A_DW-1:0]                   rrb_rdata_dca, rrb_rdata_dcb;
  wire [A_DW_INT-1:0]               rrb_rdata_up;
  wire [A_STRBW_INT-1:0]            rrb_rdata_parity_up;
  wire [A_STRBW-1:0]                rrb_rdata_parity_dca, rrb_rdata_parity_dcb;
  wire                              rrb_rpoison_r_dca;
  wire                              rrb_rpoison, rrb_rpoison_dca, rrb_rpoison_dcb, rrb_rpoison_i_dca, rrb_rpoison_i_dcb;
  wire                              rrb_ocpar_err_r_dca;
  wire                              rrb_ocpar_err, rrb_ocpar_err_dca, rrb_ocpar_err_dcb, rrb_ocpar_err_i_dca, rrb_ocpar_err_i_dcb;
  wire                              rrb_rexa_acc_instr, rrb_rexa_acc_instr_dca, rrb_rexa_acc_instr_dcb, rrb_rexa_acc_instr_i_dca, rrb_rexa_acc_instr_i_dcb;
  wire                              rrb_rexa_acc_instr_r_dca;
  wire                              rrb_queue_r_dca;
  wire                              rrb_queue, rrb_queue_dca, rrb_queue_dcb, rrb_queue_i_dca, rrb_queue_i_dcb;
  wire [RINFOW-1:0]                 rrb_rinfo, rrb_rinfo_dca, rrb_rinfo_dcb, rrb_rinfo_i_dca, rrb_rinfo_i_dcb;
  wire [RINFOW-1:0]                 rrb_rinfo_r_dca;
  wire [AXI_IDW-1:0]                rrb_rid, rrb_rid_dca, rrb_rid_dcb, rrb_rid_i_dca, rrb_rid_i_dcb;
  wire [AXI_IDW-1:0]                rrb_rid_r_dca;
  wire [AXI_USERW-1:0]              rrb_ruser, rrb_ruser_dca, rrb_ruser_dcb, rrb_ruser_i_dca, rrb_ruser_i_dcb;
  wire [AXI_USERW-1:0]              rrb_ruser_r_dca;
  wire [MEMC_NO_OF_ENTRY_LG2-1:0]   rtoken_dca;  

  wire                              rrb_rd_dca;
  wire                              dcr_rrb_rd_dca, dcr_rrb_rd_dcb;
  wire                              rrb_wr_dcb, rrb_rd_dcb, rrb_rd_i_dcb, rrb_full_dcb, rrb_empty_dcb;
  wire [RDATARAM_DW_INT-1:0]        rrb_d_dcb,rrb_q_dcb_unused, rrb_q_int_dcb, rrb_q_retime_dcb;
  wire [DATARAM_PAR_DW-1:0]         rrb_par_d_dcb, rrb_par_q_int_dcb;
  wire [RRBIW-1:0]                  rrb_infod_dcb,rrb_infoq_dcb;
  wire                              rrb_rpoison_r_dcb;
  wire                              rrb_ocpar_err_r_dcb;
  wire                              rrb_rexa_acc_instr_r_dcb;
  wire                              rrb_queue_r_dcb;
  wire [RINFOW-1:0]                 rrb_rinfo_r_dcb;
  wire [AXI_IDW-1:0]                rrb_rid_r_dcb;
  wire [AXI_USERW-1:0]              rrb_ruser_r_dcb;
  wire [MEMC_NO_OF_ENTRY_LG2-1:0]   rtoken_dcb;

  wire [NUM_DATA_CHANNELS-1:0]      rrb_dch_sel;
  wire                              dcr_rd;

  

  wire [MEMC_NO_OF_ENTRY_LG2-1:0]   atoken, atoken_tmp, atoken_dca, atoken_dcb;
  wire [DCM_NTOKENS_LG2-1:0]        atoken_dcm, atoken_dcb_pn;
  wire [DCM_NTOKENS_LG2-1:0]        dcm_token;

  
  wire [MEMC_NO_OF_ENTRY_LG2-1:0]   rrb_rtoken_dca, rrb_rtoken_dcb, tm_rtoken_dca, tm_rtoken_dcb;
  wire [MEMC_NO_OF_ENTRY_LG2-1:0]   rrb_token_dca, rrb_token_dcb, rrb_token_i_dca, rrb_token_i_dcb, dcr_rtoken_dca, dcr_rtoken_dcb, dcr_token_dca, dcr_token_dcb;
  wire [DCM_NTOKENS_LG2-1:0]        rrb_rtoken_dcm, rrb_rtoken_dca_pn, rrb_rtoken_dcb_pn;
  wire                              hif_rlast_dca, hif_rlast_dcb; // ENIF read data last
  wire                              hif_queue_dca, hif_queue_dcb; // queue type (red or blue)
  wire [AXI_IDW-1:0]                hif_rid_dca, hif_rid_dcb; // ENIF read data ID   
  wire [RINFOW-1:0]                 hif_rinfo_dca, hif_rinfo_dcb; // ENIF read data info
  wire                              hif_arready_l_blue, hif_arready_l_blue_dca, hif_arready_l_blue_dcb;
  wire                              hif_arready_l_red, hif_arready_l_red_dca, hif_arready_l_red_dcb;
  wire                              xpi_arvalid_l_blue, xpi_arvalid_l_blue_dca, xpi_arvalid_l_blue_dcb;
  wire                              xpi_arvalid_iecc_blue_i;
  wire                              xpi_arlast_iecc_blue_i;
  wire                              xpi_arvalid_l_red, xpi_arvalid_l_red_dca, xpi_arvalid_l_red_dcb;
  wire                              xpi_arvalid_iecc_red_i;
  wire                              xpi_arlast_iecc_red_i;
  wire                              gen_token, gen_token_dca, gen_token_dcb;
  wire                              gen_token_blue, gen_token_blue_dca, gen_token_blue_dcb, gen_token_blue_dca_i;
  wire                              gen_token_red, gen_token_red_dca, gen_token_red_dcb, gen_token_red_dca_i;
  wire                              rrb_release_token, rrb_release_token_dca, rrb_release_token_dcb_unused, tm_release_token_dca, tm_release_token_dcb;
  wire                              dcr_release_token_dca, dcr_release_token_dcb;
  wire                              tm_empty_blue_dca, tm_empty_blue_dcb;
  wire                              tm_empty_red_dca, tm_empty_red_dcb;
  wire [RINFOW-1:0]                 xpi_rd_arinfo_blue, xpi_rd_arinfo_blue_dcb, xpi_rd_arinfo_blue_i; // ENIF read address info
  wire [RINFOW-1:0]                 xpi_rd_arinfo_red, xpi_rd_arinfo_red_dcb, xpi_rd_arinfo_red_i; // ENIF read address info
  
  wire [AXI_IDW-1:0]                xpi_rd_arid_blue, xpi_rd_arid_blue_dcb, xpi_rd_arid_blue_i; // ENIF read address ID
  wire [AXI_IDW-1:0]                xpi_rd_arid_red, xpi_rd_arid_red_dcb, xpi_rd_arid_red_i; // ENIF read address ID
  wire [AXI_IDW-1:0]                xpi_rd_arid;
  wire                              xpi_rd_arlast_blue, xpi_rd_arlast_blue_dcb, xpi_rd_arlast_blue_i; // ENIF read address last
  wire                              xpi_rd_arlast_red, xpi_rd_arlast_red_dcb, xpi_rd_arlast_red_i; // ENIF read address last
  wire [A_NPORTS_LG2-1:0]           port_num;
  wire [A_NPORTS_LG2-1:0]           rport_num_dca_unused, rport_num_dcb_unused; // The value is not used in here and dumped

  // RRB enhancement using SBAM (Simplified BAM)
  wire                              sbam_lead_burst, sbam_second_burst;
  wire                              sbam_lead_burst_blue, sbam_second_burst_blue;
  wire                              sbam_lead_burst_red, sbam_second_burst_red;
  wire [MEMC_NO_OF_ENTRY_LG2:0]     sbam_tokens_allocated, sbam_tokens_allocated_blue, sbam_tokens_allocated_red;

  wire                              dcm_sbam_lead_burst, dcm_sbam_second_burst;
  wire                              dcm_sbam_lead_burst_blue, dcm_sbam_second_burst_blue;
  wire [MEMC_NO_OF_ENTRY_LG2:0]     dcm_sbam_tokens_allocated, dcm_sbam_tokens_allocated_blue;


  wire                              bam_lead_burst,bam_lead_burst_blue,dcm_bam_lead_burst;
  wire                              bam_lead_burst_red;
  wire                              bam_arlast,dcm_bam_arlast;
  wire                              split_dcm;
  wire                              dcm_bam_red_token;
  wire [AXI_MAXSIZE-1:0]            bam_addr_offset,bam_addr_offset_blue ; 
  wire [AXI_MAXSIZE-1:0]            bam_addr_offset_red_i, bam_addr_offset_red,dcm_bam_addr_offset;


  // Exclusive Access 
  wire                              e_rexa_acc_blue, e_rexa_acc_blue_dcb, e_rexa_acc_blue_i; // Exclusie Read Access, first packet   
  wire                              e_rexa_acc_red, e_rexa_acc_red_dcb, e_rexa_acc_red_i; // Exclusie Read Access, first packet
  wire                              e_rexa_acc_instr_blue, e_rexa_acc_instr_blue_dcb, e_rexa_acc_instr_blue_i; // Exclusive Read Access, all the packets
  wire                              e_rexa_acc_instr_red, e_rexa_acc_instr_red_dcb, e_rexa_acc_instr_red_i; // Exclusive Read Access, all the packets
  wire                              e_rpoison_blue, e_rpoison_blue_dcb, e_rpoison_blue_i; // Read blue transaction poisoned
  wire                              e_rpoison_red, e_rpoison_red_dcb, e_rpoison_red_i; // Read red transaction poisoned
  wire                              e_ocpar_err_blue, e_ocpar_err_blue_dcb, e_ocpar_err_blue_i; // address parity error
  wire [AXI_USERW-1:0]              e_user_blue, e_user_blue_dcb, e_user_blue_i, e_user_red, e_user_red_dcb, e_user_red_i;
  wire                              e_ocpar_err_red, e_ocpar_err_red_dcb, e_ocpar_err_red_i; // address parity error
  wire                              e_resp_rexa_acc_dca_unused, e_resp_rexa_acc_dcb_unused; // Exclusive Access Read Response
  wire                              e_resp_rexa_acc_instr_dca, e_resp_rexa_acc_instr_dcb;
  wire                              e_resp_rpoison_dca, e_resp_rpoison_dcb;
  wire                              e_resp_ocpar_err_dca, e_resp_ocpar_err_dcb;
  wire [AXI_USERW-1:0]              e_resp_ruser_dca, e_resp_ruser_dcb;
  wire                              xpi_wr_exa_acc, xpi_wr_exa_acc_lock; // Exclusie Write Access 
  wire [EXA_PYLD_W-1:0]             xpi_wr_exa_pyld; // Exclusive Write Payload
  wire                              xpi_wexa_acc, xpi_wexa_acc_dca, xpi_wexa_acc_dcb, xpi_wexa_acc_lock, xpi_wexa_acc_lock_dca, xpi_wexa_acc_lock_dcb; // Exclusie Write Access 
  wire                              xpi_wexa_resp_dca, xpi_wexa_resp_dcb; // Exclusive Write Response - dummy placeholder - generated by Exclusive Monitor
  wire                              xpi_rmw_split;
  wire                              xpi_wpoison, xpi_wpoison_dca, xpi_wpoison_dcb;
  wire                              xpi_ocpar_err, xpi_ocpar_err_dca, xpi_ocpar_err_dcb;
  

  wire                              xpi_wr_split, xpi_rd_split_blue, xpi_rd_split_red; 
  wire                              xpi_wr_short_burst, xpi_rmw_short_burst;
  wire [WQOS_TW-1:0]                xpi_wr_wqos_timeout;
  wire [WQOS_RW-1:0]                xpi_wr_wqos_priority;
  wire                              xpi_wr_vpw_expired;
  wire [M_ADDRW-1:0]                xpi_wr_awaddr; // XPI write address 
  wire                              xpi_wr_awdata_channel;
  wire                              xpi_wr_awlast; // XPI write address last
  wire                              xpi_awlast; // XPI write address last signal used by testbench
  wire [AXI_IDW-1:0]                xpi_wr_awid;
  wire [AXI_QOSW-1:0]               xpi_wr_awqos; // XPI write address qos
  wire [AXI_USERW-1:0]              xpi_wr_awuser;
  wire                              xpi_wr_wpoison; // XPI write transaction poisoned
  wire                              xpi_wr_ocpar_err;
  wire                              xpi_wr_awpagematch;
  wire                              xpi_wr_awautopre; // XPI write address auto precharge
  wire                              xpi_wr_awvalid; // XPI write address valid
  wire [A_DW_INT-1:0]               xpi_wr_wdata; // XPI write data
  wire                              xpi_wr_wdata_channel;
  wire [DEACC_INFOW-1:0]            xpi_wr_deacc_info;
  wire [A_STRBW_INT-1:0]            xpi_wr_wstrb; // XPI write data strobe
  wire                              xpi_wr_wlast; // XPI write data last
  wire                              xpi_wr_wlast_pkt; // XPI write last beat of the packet
  wire                              xpi_wr_wvalid; // XPI write data valid
  wire [NBEATS_LG2-1:0]             xpi_wr_beat_count;
  wire                              rmw_awready;
  wire                              rmw_wready;
  wire [AXI_IDW-1:0]                xpi_awid, xpi_awid_dca, xpi_awid_dcb; // XPI write address ID      
  wire [AXI_USERW-1:0]              xpi_awuser_dca, xpi_awuser_dcb;
  wire [BRW-1:0]                    reg_xpi_burst_rdwr; 
  wire [BRW-1:0]                    burst_rdwr_bus_width;
  wire                              xpi_rready;
  wire                              xpi_rready_dcb;
  wire [RDATARAM_AW-1:0]            rrb_rdataram_raddr_dca;
  wire [RDATARAM_AW-1:0]            rrb_rdataram_waddr_dca;
  wire [RDATARAM_AW-1:0]            rrb_rdataram_raddr_dcb;
  wire [RDATARAM_AW-1:0]            rrb_rdataram_waddr_dcb;
  wire [A_STRBW_INT-1:0]            xpi_wr_wpar_err;
  wire [A_PARW_INT-1:0]             xpi_wr_wparity;
  
  wire [NUM_VIR_CH_LG2-1:0]         xpi_read_ch_num;
  wire [NUM_VIR_CH_LG2-1:0]         xpi_read_ch_num_blue;
  wire [NUM_VIR_CH_LG2-1:0]         xpi_read_ch_num_red;
  wire                              xpi_read_bypass_reorder;
  wire                              xpi_read_bypass_reorder_blue, xpi_read_bypass_reorder_blue_dcb, xpi_read_bypass_reorder_blue_i;
  wire                              xpi_read_bypass_reorder_red, xpi_read_bypass_reorder_red_dcb, xpi_read_bypass_reorder_red_i;
  wire                              hif_bypass_reorder_dca;
  wire                              hif_bypass_reorder_dcb;

  wire                              hif_arvalid_iecc_dca_unused, hif_arvalid_iecc_dcb_unused;
  wire                              hif_arlast_iecc_dca_unused, hif_arlast_iecc_dcb_unused;

  wire [NUM_VIR_CH-1:0]             vtq_empty, vtq_empty_dca, vtq_empty_dcb;
  
  wire                              reg_xpi_short_write_dis; // disable short_write functionality is possible
  wire                              reg_xpi_short_write_dis_bl8_nab1; // disable short_write functionality is possible always if memc_burst_length=8 and 1:1
  wire                              reg_xpi_short_write_dis_bl8_nab1_1or3beats; // FIXME_SS was reg_xpi_short_write_dis_bl8_nab1_3beats
  wire                              reg_xpi_short_write_dis_bl16_nab1;
  wire                              reg_xpi_short_write_dis_bl16_nab2;  
  wire                              reg_xpi_short_write_dis_mbl16_bl8_nab2;
  wire                              reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2;
  wire                              reg_xpi_short_write_dis_mbl16_bl4_nab2;
  wire                              reg_xpi_short_write_dis_bl16_qbw_nab1;
  wire                              reg_xpi_short_write_dis_bl16_hbw;
  wire                              reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1;
  wire                              reg_xpi_short_write_dis_bl16_fbw_nab1;
  wire                              reg_xpi_short_write_dis_mbl16_bl4_nab1;
  wire                              reg_xpi_short_write_dis_mbl16_bl8_bc_fbw;
  wire                              reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1;
  wire                              reg_mbl16_bl8_bc_crc_dis_nab3;
  wire                              reg_xpi_dm_dis;   // DM disabled
  wire                              reg_xpi_rmw_mode_ie; // RMW mode enable - Inline ECC
  wire                              reg_xpi_rmw_mode_nonie; // RMW mode enable - Non Inline ECC
  wire                              reg_xpi_ecc_mode_ie; // Software enable/disable ecc mode in xpi_rmw - Inline ECC
  wire                              reg_xpi_ecc_mode_nonie; // Software enable/disable ecc mode in xpi_rmw - Non Inline ECC
  wire                              xpi_short_write;  // Short write infomation
  wire                              xpi_exa_arlast_blue;
  wire                              xpi_exa_arlast_red;
  wire [BEAT_INFOW-1:0]             abeat_info_blue, abeat_info_blue_dcb, abeat_info_blue_i;
  wire [BEAT_INFOW-1:0]             abeat_info_red, abeat_info_red_dcb, abeat_info_red_i;
  wire [BEAT_INFOW-1:0]             rbeat_info_dca, rbeat_info_dcb;

  wire                              rrb_rd_last_i_dca;
  wire                              rrb_rd_last, rrb_rd_last_dca, rrb_rd_last_dcb, dcr_rd_last_dca, dcr_rd_last_dcb;
  wire [NUM_CH_LG2-1:0]             rrb_ch_num_i_dca;
  wire [NUM_CH_LG2-1:0]             rrb_ch_num, rrb_ch_num_dca, rrb_ch_num_dcb, dcr_ch_num_dca, dcr_ch_num_dcb;
  wire                              rrb_rd_last_i_dcb;
  wire [NUM_CH_LG2-1:0]             rrb_ch_num_i_dcb;

  wire                              oc_addr_parity_en; // enable address parity check on both read and write path
  wire                              oc_rdata_parity_en; // enable read data parity check
  wire                              oc_wdata_parity_en; // enable read data parity check

  wire                              arurgentb_out;
  wire                              arurgentr_out;
  wire                              awurgent_out;
  wire                              arurgentb_r;
  wire                              arurgentr_r;
  wire                              awurgent_r;

  reg                               write_data_ch_en;
  reg                               write_addr_ch_en;
  
  wire                              posted_write_data_exist;
  wire                              posted_write_addr_exist_unused;
  wire [POSTED_WRBW-1:0]            posted_write_beats_reg;
  reg  [POSTED_WRBW-1:0]            posted_write_beats_next;
  reg                               block_posted_writes;

  // SAR mirror regs
  wire [AXI_SAR_BW-1:0]             reg_base_addr_0;
  wire [AXI_SAR_SW-1:0]             reg_nblocks_0;
  wire [AXI_SAR_BW-1:0]             reg_base_addr_1;
  wire [AXI_SAR_SW-1:0]             reg_nblocks_1;  
  wire [AXI_SAR_BW-1:0]             reg_base_addr_2;
  wire [AXI_SAR_SW-1:0]             reg_nblocks_2;    
  wire [AXI_SAR_BW-1:0]             reg_base_addr_3;
  // end SAR
  wire                              gen_token_rrb;
  wire [NUM_VIR_CH_LG2-1:0]         ch_num_rrb_dca, ch_num_rrb_dcb, ch_num_rrb_dcr;
  wire                              abypass_reorder_rrb_dca, abypass_reorder_rrb_dcb;
  wire [MEMC_NO_OF_ENTRY_LG2-1:0]   atoken_rrb_dca, atoken_rrb_dcb;
  wire [DCM_NTOKENS_LG2-1:0]        atoken_rrb_dcb_dcm;
  wire                              dcm_dch_sel, dch_sel_dcm;
  wire                              gen_token_rrb_dca,gen_token_rrb_dcb;

  // When port_en is set to 0 and the write address channel locking is on progress wait_addr_ch_lock is used to set wr_port_busy to 1.
  reg                               wait_addr_ch_lock;  
  // When port_en is set to 0 and the write data channel locking is on progress wait_data_ch_lock is used to set wr_port_busy to 1.
  reg                               wait_data_ch_lock;

  wire                               e_rst_dly, a_rst_dly; // synch pulses when reset are deasserted

  // dual channel common signals
  wire                           xpi_awvalid; // XPI write address valid (out)

  wire                           hif_awready; // HIF write address ready (in)
  wire                           xpi_wvalid; // XPI write data valid (out)
  wire                           hif_wready; // HIF write data ready (in)

  wire                           data_channel_rd_blue, data_channel_rd_red; // decoded data channel
  wire                           xpi_wdata_channel, xpi_awdata_channel;

  wire [DEACC_INFOW-1:0]         xpi_deacc_info;

  wire                           dcr_empty_unused;
  wire [NUM_DATA_CHANNELS-1:0]   dch_sel;

  wire [NUM_VIR_CH-1:0]          valid_dcr_dca, valid_dcr_dcb;

  wire [RRBRIW-1:0]              rrb_sync_d_dca, rrb_sync_q_dca, rrb_sync_d_dcb, rrb_sync_q_dcb;


  reg                            rdataram_re_d1;
  reg                            rdataram_re_dcb_d1;
  reg [RRBRIW-1:0]               rrb_sync_d_retime_dca;
  reg [RRBRIW-1:0]               rrb_sync_d_retime_dcb;

  wire [EXA_PYLD_W-1:0]          xpi_rexa_pyld_blue_i, xpi_rexa_pyld_red_i;
  wire [M_ADDRW-1:0]             xpi_araddr_blue_i, xpi_araddr_red_i;
  wire [AXI_QOSW-1:0]            xpi_arqos_blue_i, xpi_arqos_red_i;
  wire [RQOS_RW-1:0]             xpi_rqos_priority_blue_i, xpi_rqos_priority_red_i;
  wire [RQOS_TW-1:0]             xpi_rqos_timeout_blue_i, xpi_rqos_timeout_red_i;
  wire [RQOS_TW-1:0]             xpi_rqos_timeout_blue_dca_int, xpi_rqos_timeout_blue_dcb_int;
  wire                           xpi_vpr_expired_blue_i, xpi_vpr_expired_red_i;
  wire                           xpi_vpr_expired_blue_dca_int, xpi_vpr_expired_blue_dcb_int;
  wire                           xpi_arpagematch_blue_i, xpi_arpagematch_red_i;
  wire                           xpi_arautopre_blue_i, xpi_arautopre_red_i;

  wire [A_DW_INT-1:0]            xpi_wdata_i; // XPI write data
  wire [A_STRBW_INT-1:0]         xpi_wstrb_i; // XPI write data strobe
  wire                           xpi_wlast_i; // XPI write data last
  wire                           xpi_wlast_pkt_i; // XPI write last beat of the packet
  wire [A_STRBW_INT-1:0]         xpi_wpar_err_i; // write data parity error
  wire [A_PARW_INT-1:0]          xpi_wparity_i; // write data parity

  wire [M_ADDRW-1:0]             xpi_awaddr_i; 
  wire                           xpi_awrmw_i;
  wire                           xpi_snf_mode_i;
  wire [NBEATS-1:0]              xpi_wdata_mask_full_i;
  wire [AXI_QOSW-1:0]            xpi_awqos_i;
  wire [AXI_USERW-1:0]           xpi_awuser_i;
  wire                           xpi_awpagematch_i; 
  wire                           xpi_awautopre_i;
  wire                           xpi_exa_awlast_i;
  wire                           xpi_exa_short_burst_i;
  wire [WQOS_RW-1:0]             xpi_wqos_priority_i;
  wire [WQOS_TW-1:0]             xpi_wqos_timeout_i;
  wire [WQOS_TW-1:0]             xpi_wqos_timeout_dca_int, xpi_wqos_timeout_dcb_int;
  wire                           xpi_vpw_expired_i;
  wire                           xpi_vpw_expired_dca_int, xpi_vpw_expired_dcb_int;
  wire                           push_vpr_en_dca, push_vpr_en_dcb, pop_vpr_en_dca, pop_vpr_en_dcb;
  wire                           push_vpw_en_dca, push_vpw_en_dcb, pop_vpw_en_dca, pop_vpw_en_dcb;

  wire                           xpi_awvalid_iecc_i;
  wire                           xpi_awlast_iecc_i;

  wire [EXA_PYLD_W-1:0]          xpi_wexa_pyld_i;

  wire [A_DW-1:0]                 hif_hif_rdata_dca_i;
  wire [A_DW-1:0]                 cnvg_hif_rdata_dca;
  wire [A_DW-1:0]                 cnvg_hif_rdata_dcb;
  wire [A_STRBW-1:0]              hif_hif_rdata_parity_dca_i;
  wire [A_STRBW-1:0]              cnvg_hif_rdata_parity_dca;
  wire [A_STRBW-1:0]              cnvg_hif_rdata_parity_dcb;
  wire                            hif_rerror_dca_i;
  wire                            hif_rlast_pkt_dca_i_unused;
  wire                            hif_rvalid_dca_i;
  wire [MEMC_TAGBITS-1:0]         e_resp_token_dca_i;

  wire                            ddrc_xpi_port_disable_req_sync;

  wire                            xpi_wr_iecc_blk_valid;
  wire                            xpi_wr_iecc_blk_end;
  wire                            xpi_rd_iecc_blk_valid_blue;
  wire                            xpi_rd_iecc_blk_end_blue;
  wire                            xpi_rd_iecc_blk_valid_red;
  wire                            xpi_rd_iecc_blk_end_red;

  wire [WRQW-1:0]                 xpi_bresp_dca, xpi_bresp_dcb, xpi_bresp;
  wire                            xpi_bready, hif_bvalid;

  // inline ECC outputs
   wire                           xpi_awvalid_iecc;
   wire                           xpi_awlast_iecc;
   wire                           xpi_awvalid_iecc_dcb;
   wire                           xpi_awlast_iecc_dcb;
   wire                           xpi_arvalid_iecc_blue;
   wire                           xpi_arlast_iecc_blue;
   wire                           xpi_arvalid_iecc_blue_dcb;
   wire                           xpi_arlast_iecc_blue_dcb;
   wire                           xpi_arvalid_iecc_red;
   wire                           xpi_arlast_iecc_red;
   wire                           xpi_arvalid_iecc_red_dcb;
   wire                           xpi_arlast_iecc_red_dcb;

   // ocecc
   /*wire                           ocecc_xpi_write_uncorr_err;
   wire                           ocecc_xpi_write_corr_err;
   wire                           ocecc_xpi_read_uncorr_err;
   wire                           ocecc_xpi_read_corr_err;*/

   // occap
      // rrb parity error pulses
   wire occap_xpi_rrb_par_err, occap_xpi_rrb_par_err_dca, occap_xpi_rrb_par_err_dcb, occap_xpi_dcr_par_err;
      // read parity errors
   wire occap_xpi_read_c_par_err, occap_xpi_read_a_par_err;
      // fifo top errors
   wire occap_dch_par_err, occap_dca_rd_par_err, occap_dcb_rd_par_err, occap_dca_wr_par_err, occap_dcb_wr_par_err;
      // dch arb errors
   wire occap_xpi_dch_rd_rar_err, occap_xpi_dch_wr_rar_err;
      // rmw error
   wire occap_xpi_rmw_par_err;
      // top parity
   wire occap_urgent_par_err, occap_busy_par_err;
      // xpi read/write comparators
   wire occap_xpi_write_a_cmp_err, occap_xpi_write_c_cmp_err;
   wire [OCCAP_CMP_AC-1:0] occap_xpi_write_a_cmp_err_full, occap_xpi_write_a_cmp_err_seq;
   wire [OCCAP_CMP_CC-1:0] occap_xpi_write_c_cmp_err_full, occap_xpi_write_c_cmp_err_seq;
   wire occap_xpi_read_a_cmp_err, occap_xpi_read_c_cmp_err;
   wire [OCCAP_CMP_AC-1:0] occap_xpi_read_a_cmp_err_full, occap_xpi_read_a_cmp_err_seq;
   wire [OCCAP_CMP_CC-1:0] occap_xpi_read_c_cmp_err_full, occap_xpi_read_c_cmp_err_seq;
   wire [OCCAP_CMP_AC-1:0] occap_xpi_read_a_cmp_poison_complete, occap_xpi_write_a_cmp_poison_complete;
   wire [OCCAP_CMP_CC-1:0] occap_xpi_read_c_cmp_poison_complete, occap_xpi_write_c_cmp_poison_complete;
      // xpi write parity
   wire occap_xpi_write_c_par_err, occap_xpi_write_a_par_err;
     // extram info
  wire occap_xpi_sync_info_par_err, occap_xpi_sync_info_dcb_par_err;
   // dual channel rdr
  wire occap_xpi_rdr_data_par_err, occap_xpi_rdr_info_par_err;
   // dcm parity error
  wire occap_xpi_dcm_par_err;
   // tm error
  wire occap_xpi_tm_par_err, occap_xpi_tm_dca_par_err, occap_xpi_tm_dcb_par_err;
   // pre_arb error
  wire occap_xpi_rdwr_pre_arb_par_err;
   // post_arb error
  wire occap_xpi_rdwr_post_arb_par_err;
   // dual channel bresp
  wire occap_xpi_wptrq_err, occap_xpi_wrq0_err, occap_xpi_wrq1_err;
   // lpfsm error
  wire occap_xpi_lpfsm_par_err;

  wire  bam_is_active;

  wire [MEMC_HIF_ADDR_WIDTH_MAX-1:0]             hif_cmd_addr_unused_dca;
  wire [MEMC_HIF_ADDR_WIDTH_MAX-1:0]             hif_cmd_addr_unused_dcb;
  wire [MEMC_HIF_ADDR_WIDTH_MAX-1:0]             xpi_araddr_blue_max_width;
  wire [MEMC_HIF_ADDR_WIDTH_MAX-1:0]             xpi_araddr_blue_dcb_max_width;
  wire [MEMC_HIF_ADDR_WIDTH_MAX-1:0]             xpi_araddr_red_max_width;
  wire [MEMC_HIF_ADDR_WIDTH_MAX-1:0]             xpi_araddr_red_dcb_max_width;


  localparam ENIF_LENW_INT    = (PDBW_CASE==0) ? AXI_LENW + `UMCTL_LOG2(AXI_DATAW/A_DW_INT)
                                               : AXI_LENW + `UMCTL_LOG2(AXI_DATAW/(A_DW_INT/4)); //HRE : Should consider for A_DW_QBW
  localparam ENIF_LENW    =  (PDBW_CASE==0) ? AXI_LENW + `UMCTL_LOG2(AXI_DATAW/A_DW)
                                            : AXI_LENW + `UMCTL_LOG2(AXI_DATAW/(A_DW/4)); // NIF a*len width   //HRE : Should consider for A_DW_QBW
  localparam RINFO_ADROFFST_LSB = ENIF_LENW_INT+ENIF_SIZEW_INT+AXI_IDW;

   generate
      if (DUAL_CHANNEL==1) begin: DUAL_dch__1
         // Logic for DUAL CHANNEL
         if (DATA_CHANNEL_INTERLEAVE==0) begin: DUAL_dch_lite
            // STATIC data channel mapping, 1 port can request only to a single channel
            // No data Interleaving, simply MUX/DEMUX at the output based on sw programming (reg_arb_port_data_channel)
            assign xpi_arvalid_l_blue_dca    = (reg_arb_port_data_channel) ? 1'b0 : xpi_arvalid_l_blue;
            assign xpi_arvalid_l_blue_dcb    = (reg_arb_port_data_channel) ? xpi_arvalid_l_blue : 1'b0;
            assign xpi_arvalid_l_red_dca     = (reg_arb_port_data_channel) ? 1'b0 : xpi_arvalid_l_red;
            assign xpi_arvalid_l_red_dcb     = (reg_arb_port_data_channel) ? xpi_arvalid_l_red : 1'b0;
            assign gen_token_dca             = gen_token_blue_dca | gen_token_red_dca;
            assign gen_token_dcb             = gen_token_blue_dcb | gen_token_red_dcb;

            assign gen_token_blue_dca        = xpi_arvalid_blue_dca & hif_arready_l_blue_dca;
            assign gen_token_red_dca         = xpi_arvalid_red_dca & hif_arready_l_red_dca;
            assign gen_token_blue_dcb        = xpi_arvalid_blue_dcb & hif_arready_l_blue_dcb;
            assign gen_token_red_dcb         = xpi_arvalid_red_dcb & hif_arready_l_red_dcb;

            assign gen_token_blue_dca_i      = (reg_arb_port_data_channel) ? gen_token_blue_dcb : gen_token_blue_dca;
            assign gen_token_red_dca_i       = (reg_arb_port_data_channel) ? gen_token_red_dcb : gen_token_red_dca;

            assign hif_arready_l_blue_dca    = hif_arready_blue_dca & ~tm_empty_blue_dca;
            assign hif_arready_l_red_dca     = hif_arready_red_dca & ~tm_empty_red_dca;
            assign xpi_arvalid_blue_dca      = xpi_arvalid_l_blue_dca & ~tm_empty_blue_dca;
            assign xpi_arvalid_red_dca       = xpi_arvalid_l_red_dca & ~tm_empty_red_dca; 

            assign hif_arready_l_blue_dcb    = hif_arready_blue_dcb & ~tm_empty_blue_dcb;
            assign hif_arready_l_red_dcb     = hif_arready_red_dcb & ~tm_empty_red_dcb;
            assign xpi_arvalid_blue_dcb      = xpi_arvalid_l_blue_dcb & ~tm_empty_blue_dcb;
            assign xpi_arvalid_red_dcb       = xpi_arvalid_l_red_dcb & ~tm_empty_red_dcb;

            assign dch_sel_dcm               = reg_arb_port_data_channel;

            assign hif_arready_l_blue        = (reg_arb_port_data_channel) ? hif_arready_l_blue_dcb : hif_arready_l_blue_dca;
            assign hif_arready_l_red         = (reg_arb_port_data_channel)  ? hif_arready_l_red_dcb  : hif_arready_l_red_dca;
            assign xpi_araddr_blue           = xpi_araddr_blue_i;
            assign xpi_arqos_blue            = xpi_arqos_blue_i;
            assign xpi_rqos_priority_blue    = xpi_rqos_priority_blue_i;
            assign xpi_rqos_timeout_blue     = xpi_rqos_timeout_blue_i;
            assign xpi_vpr_expired_blue      = xpi_vpr_expired_blue_i;
            assign xpi_arpagematch_blue      = xpi_arpagematch_blue_i;
            assign xpi_arautopre_blue        = xpi_arautopre_blue_i;
            assign xpi_araddr_blue_dcb       = xpi_araddr_blue_i;
            assign xpi_arqos_blue_dcb        = xpi_arqos_blue_i;
            assign xpi_rqos_priority_blue_dcb= xpi_rqos_priority_blue_i;
            assign xpi_rqos_timeout_blue_dcb = xpi_rqos_timeout_blue_i;
            assign xpi_vpr_expired_blue_dcb  = xpi_vpr_expired_blue_i;
            assign xpi_arpagematch_blue_dcb  = xpi_arpagematch_blue_i;
            assign xpi_arautopre_blue_dcb    = xpi_arautopre_blue_i;

            assign xpi_read_bypass_reorder_blue       = xpi_read_bypass_reorder_blue_i;
            assign xpi_rd_arinfo_blue                 = xpi_rd_arinfo_blue_i;
            assign abeat_info_blue                    = abeat_info_blue_i;
            assign e_rexa_acc_blue                    = e_rexa_acc_blue_i;
            assign e_rexa_acc_instr_blue              = e_rexa_acc_instr_blue_i;
            assign e_rpoison_blue                     = e_rpoison_blue_i;
            assign e_ocpar_err_blue                   = e_ocpar_err_blue_i;
            assign xpi_rd_arlast_blue                 = xpi_rd_arlast_blue_i;
            assign xpi_rd_arid_blue                   = xpi_rd_arid_blue_i;
            assign xpi_read_bypass_reorder_blue_dcb   = xpi_read_bypass_reorder_blue_i;
            assign xpi_rd_arinfo_blue_dcb             = xpi_rd_arinfo_blue_i;
            assign abeat_info_blue_dcb                = abeat_info_blue_i;
            assign e_rexa_acc_blue_dcb                = e_rexa_acc_blue_i;
            assign e_rexa_acc_instr_blue_dcb          = e_rexa_acc_instr_blue_i;
            assign e_rpoison_blue_dcb                 = e_rpoison_blue_i;
            assign e_ocpar_err_blue_dcb               = e_ocpar_err_blue_i;
            assign xpi_rd_arlast_blue_dcb             = xpi_rd_arlast_blue_i;
            assign xpi_rd_arid_blue_dcb               = xpi_rd_arid_blue_i;
            assign e_user_blue                        = e_user_blue_i;
            assign e_user_blue_dcb                    = e_user_blue_i;

            assign hif_hif_rdata_dca_i          = (reg_arb_port_data_channel) ? hif_hif_rdata_dcb : hif_hif_rdata_dca;
            //spyglass disable_block W528
            //SMD: Variable set but not read
            //SJ: Used in generate block branch only if OCPAR or OCECC is enabled
            assign hif_hif_rdata_parity_dca_i   = (reg_arb_port_data_channel) ? hif_hif_rdata_parity_dcb : hif_hif_rdata_parity_dca;
            //spyglass enable_block W528
            assign hif_rerror_dca_i             = (reg_arb_port_data_channel) ? hif_rerror_dcb : hif_rerror_dca;
            assign hif_rlast_pkt_dca_i_unused   = (reg_arb_port_data_channel) ? hif_rlast_pkt_dcb : hif_rlast_pkt_dca;
            assign hif_rvalid_dca_i             = (reg_arb_port_data_channel) ? hif_rvalid_dcb : hif_rvalid_dca;
            assign e_resp_token_dca_i           = (reg_arb_port_data_channel) ? e_resp_token_dcb : e_resp_token_dca;

            // inline ECC related signals
            assign xpi_awvalid_iecc             = 1'b0;
            assign xpi_awlast_iecc              = 1'b0;
            assign xpi_awvalid_iecc_dcb         = 1'b0;
            assign xpi_awlast_iecc_dcb          = 1'b0;
            assign xpi_arvalid_iecc_blue        = 1'b0;
            assign xpi_arlast_iecc_blue         = 1'b0;
            assign xpi_arvalid_iecc_blue_dcb    = 1'b0;
            assign xpi_arlast_iecc_blue_dcb     = 1'b0;
            assign xpi_arvalid_iecc_red         = 1'b0;
            assign xpi_arlast_iecc_red          = 1'b0;
            assign xpi_arvalid_iecc_red_dcb     = 1'b0;
            assign xpi_arlast_iecc_red_dcb      = 1'b0;


            // output demux
            assign xpi_awvalid_dca        = (reg_arb_port_data_channel) ? 1'b0    : xpi_awvalid;
            assign xpi_wvalid_dca         = (reg_arb_port_data_channel) ? 1'b0     : xpi_wvalid;
            assign xpi_awvalid_dcb        = (reg_arb_port_data_channel) ? xpi_awvalid         : 1'b0;   
            assign xpi_wvalid_dcb         = (reg_arb_port_data_channel) ? xpi_wvalid           : 1'b0;
            // input mux
            // write address valid
            assign hif_awready            = (reg_arb_port_data_channel) ? hif_awready_dcb  : hif_awready_dca;
            // write data ready
            assign hif_wready             = (reg_arb_port_data_channel) ? hif_wready_dcb    : hif_wready_dca;
            // write data
            assign xpi_wdata              = xpi_wdata_i[A_DW-1:0];
            assign xpi_wstrb              = xpi_wstrb_i[A_STRBW-1:0];
            assign xpi_wlast              = xpi_wlast_i;
            assign xpi_wlast_pkt          = xpi_wlast_pkt_i;
            assign xpi_snf_mode           = xpi_snf_mode_i;
            assign xpi_wpar_err           = xpi_wpar_err_i[A_STRBW-1:0];
            assign xpi_wparity            = xpi_wparity_i[A_PARW-1:0];
            assign xpi_wdata_dcb          = xpi_wdata_i[A_DW-1:0];
            assign xpi_wstrb_dcb          = xpi_wstrb_i[A_STRBW-1:0];
            assign xpi_wlast_dcb          = xpi_wlast_i;
            assign xpi_wlast_pkt_dcb      = xpi_wlast_pkt_i;
            assign xpi_snf_mode_dcb       = xpi_snf_mode_i;
            assign xpi_wpar_err_dcb       = xpi_wpar_err_i[A_STRBW-1:0];
            assign xpi_wparity_dcb        = xpi_wparity_i[A_PARW-1:0];

            assign xpi_wexa_acc_dca       = xpi_wexa_acc;
            assign xpi_wexa_acc_dcb       = xpi_wexa_acc;
            assign xpi_wexa_acc_lock_dca  = xpi_wexa_acc_lock;
            assign xpi_wexa_acc_lock_dcb  = xpi_wexa_acc_lock;
            assign xpi_awid_dca           = xpi_awid;
            assign xpi_awid_dcb           = xpi_awid;
            assign xpi_wpoison_dca        = xpi_wpoison;
            assign xpi_wpoison_dcb        = xpi_wpoison;
            assign xpi_ocpar_err_dca      = xpi_ocpar_err;
            assign xpi_ocpar_err_dcb      = xpi_ocpar_err;
            assign xpi_awuser_dca         = xpi_awuser_i;
            assign xpi_awuser_dcb         = xpi_awuser_i;

            assign xpi_awaddr                = xpi_awaddr_i; 
            assign xpi_awrmw                 = xpi_awrmw_i; 
            assign xpi_awqos                 = xpi_awqos_i;
            assign xpi_awpagematch           = xpi_awpagematch_i; 
            assign xpi_awautopre             = xpi_awautopre_i;
            assign xpi_exa_awlast            = xpi_exa_awlast_i;
            assign xpi_exa_short_burst       = xpi_exa_short_burst_i;
            assign xpi_wqos_priority         = xpi_wqos_priority_i;
            assign xpi_wqos_timeout          = xpi_wqos_timeout_i;
            assign xpi_vpw_expired           = xpi_vpw_expired_i;
            assign xpi_awaddr_dcb            = xpi_awaddr_i; 
            assign xpi_awrmw_dcb             = xpi_awrmw_i; 
            assign xpi_awqos_dcb             = xpi_awqos_i;
            assign xpi_awpagematch_dcb       = xpi_awpagematch_i; 
            assign xpi_awautopre_dcb         = xpi_awautopre_i;
            assign xpi_exa_awlast_dcb        = xpi_exa_awlast_i;
            assign xpi_exa_short_burst_dcb   = xpi_exa_short_burst_i;
            assign xpi_wqos_priority_dcb     = xpi_wqos_priority_i;
            assign xpi_wqos_timeout_dcb      = xpi_wqos_timeout_i;
            assign xpi_vpw_expired_dcb       = xpi_vpw_expired_i;
            assign xpi_wdata_mask_full       = xpi_wdata_mask_full_i;
            assign xpi_wdata_mask_full_dcb   = xpi_wdata_mask_full_i;

            assign xpi_araddr_red                  = xpi_araddr_red_i;
            assign xpi_arqos_red                   = xpi_arqos_red_i;
            assign xpi_rqos_priority_red           = xpi_rqos_priority_red_i;
            assign xpi_rqos_timeout_red            = xpi_rqos_timeout_red_i;
            assign xpi_vpr_expired_red             = xpi_vpr_expired_red_i;
            assign xpi_arpagematch_red             = xpi_arpagematch_red_i;
            assign xpi_arautopre_red               = xpi_arautopre_red_i;
            assign xpi_read_bypass_reorder_red     = xpi_read_bypass_reorder_red_i;
            assign xpi_rd_arinfo_red               = xpi_rd_arinfo_red_i;
            assign abeat_info_red                  = abeat_info_red_i;
            assign e_rexa_acc_red                  = e_rexa_acc_red_i;
            assign e_rexa_acc_instr_red            = e_rexa_acc_instr_red_i;
            assign e_rpoison_red                   = e_rpoison_red_i;
            assign e_ocpar_err_red                 = e_ocpar_err_red_i;
            assign xpi_rd_arlast_red               = xpi_rd_arlast_red_i;
            assign xpi_rd_arid_red                 = xpi_rd_arid_red_i;
            assign xpi_read_bypass_reorder_red_dcb = xpi_read_bypass_reorder_red_i;
            assign xpi_rd_arinfo_red_dcb           = xpi_rd_arinfo_red_i;
            assign abeat_info_red_dcb              = abeat_info_red_i;
            assign e_rexa_acc_red_dcb              = e_rexa_acc_red_i;
            assign e_rexa_acc_instr_red_dcb        = e_rexa_acc_instr_red_i;
            assign e_rpoison_red_dcb               = e_rpoison_red_i;
            assign e_ocpar_err_red_dcb             = e_ocpar_err_red_i;
            assign xpi_rd_arlast_red_dcb           = xpi_rd_arlast_red_i;
            assign xpi_rd_arid_red_dcb             = xpi_rd_arid_red_i;
            assign xpi_araddr_red_dcb              = xpi_araddr_red_i;
            assign xpi_arqos_red_dcb               = xpi_arqos_red_i;
            assign xpi_rqos_priority_red_dcb       = xpi_rqos_priority_red_i;
            assign xpi_rqos_timeout_red_dcb        = xpi_rqos_timeout_red_i;
            assign xpi_vpr_expired_red_dcb         = xpi_vpr_expired_red_i;
            assign xpi_arpagematch_red_dcb         = xpi_arpagematch_red_i;
            assign xpi_arautopre_red_dcb           = xpi_arautopre_red_i;
            assign e_user_red                      = e_user_red_i;
            assign e_user_red_dcb                  = e_user_red_i;
//spyglass disable_block W528
//SMD: Variable 'bam_addr_offset_red[5:0]' set but not read
//SJ: Used in generate block. Variable is read only if USE2RAQ==1
            assign bam_addr_offset_red             = bam_addr_offset_red_i;
//spyglass enable_block W528
            assign xpi_rexa_pyld_blue           = xpi_rexa_pyld_blue_i;
            assign xpi_rexa_pyld_red            = xpi_rexa_pyld_red_i;
            assign xpi_rexa_pyld_blue_dcb       = xpi_rexa_pyld_blue_i;
            assign xpi_rexa_pyld_red_dcb        = xpi_rexa_pyld_red_i;
            assign xpi_wexa_pyld                = xpi_wexa_pyld_i;
            assign xpi_wexa_pyld_dcb            = xpi_wexa_pyld_i;

            // write response
            assign xpi_bresp                    = hif_bvalid_dcb ? xpi_bresp_dcb : xpi_bresp_dca;
            assign hif_bvalid                   = hif_bvalid_dca | hif_bvalid_dcb;
            assign xpi_bready_dca               = xpi_bready;
            assign xpi_bready_dcb               = xpi_bready;


            assign occap_dca_wr_par_err = 1'b0;
            assign occap_dcb_wr_par_err = 1'b0;

            assign occap_xpi_dch_rd_rar_err     = 1'b0;
            assign occap_xpi_dch_wr_rar_err     = 1'b0;

            assign occap_xpi_wptrq_err = 1'b0;
            assign occap_xpi_wrq0_err  = 1'b0;
            assign occap_xpi_wrq1_err  = 1'b0;

         end // if (DATA_CHANNEL_INTERLEAVE==0)
         else begin: DUAL_dch_interleave


            // Logic for DUAL DATA CHANNEL interleaving
            // XPI can switch dynamically between channel 0 and channel 1 based on the address
            // XPI splits an AXI burst in different HIF bursts, each of them is then sent to different channels based on the address mapping (dch_bit0)

            //write pointer queue signals
            wire wptrq_wr, wptrq_rd;

            wire wcmd_dca_out, wcmd_dcb_out;

            wire [AXI_WPTRQW-1:0] wptrq_d, wptrq_q;
            wire [AXI_WPTRQD_LG2:0] wptrq_wcount_unused;
            wire wptrq_full, wptrq_empty_unused;

            wire wptrq_channel, wptrq_awlast;

            // write response queues signals

            wire wrq0_wr, wrq0_rd, wrq1_wr, wrq1_rd;
            wire [WRQW-1:0] wrq0_d, wrq0_q, wrq1_d, wrq1_q;
            wire [AXI_PRE_WRQD_LG2:0] wrq0_wcount_unused, wrq1_wcount_unused;
            wire wrq0_full, wrq0_empty, wrq1_full, wrq1_empty;

            wire [1:0] wrq_sel;

            wire [WRQW-1:0] wptrq_bresp;

            wire wptrq_slverr, wptrq_exa_bresp;
            wire [AXI_IDW-1:0] wptrq_bid;
            wire [AXI_USERW-1:0] wptrq_buser;
            wire slverr_burst, slverr_valid;
            reg slverr_burst_r; // SNPS_TMR
            
            if (DUAL_CHANNEL_INTERLEAVE_HP==1) begin: INTLV_native_size_1
               if (PA_OPT_TYPE==2) begin: PA_comb
                  // Combinatorial PA, grant immediate, no need to arbitrate the requests, so forward to PA directly as they are
                  assign xpi_arvalid_l_blue_dca  = (data_channel_rd_blue) ? 1'b0 : xpi_arvalid_l_blue;
                  assign xpi_arvalid_l_blue_dcb  = (data_channel_rd_blue) ? xpi_arvalid_l_blue : 1'b0;
                  assign xpi_arvalid_l_red_dca   = (data_channel_rd_red) ? 1'b0 : xpi_arvalid_l_red;
                  assign xpi_arvalid_l_red_dcb   = (data_channel_rd_red) ? xpi_arvalid_l_red : 1'b0;

                  assign gen_token_dca        = gen_token_blue_dca | gen_token_red_dca;
                  assign gen_token_dcb        = gen_token_blue_dcb | gen_token_red_dcb;

                  assign gen_token_blue_dca   = xpi_arvalid_blue_dca & hif_arready_l_blue_dca;
                  assign gen_token_red_dca    = xpi_arvalid_red_dca & hif_arready_l_red_dca;
                  assign gen_token_blue_dcb   = xpi_arvalid_blue_dcb & hif_arready_l_blue_dcb;
                  assign gen_token_red_dcb    = xpi_arvalid_red_dcb & hif_arready_l_red_dcb;

                  assign gen_token_blue_dca_i = gen_token_blue_dca;
                  assign gen_token_red_dca_i  = gen_token_red_dca;

                  assign hif_arready_l_blue_dca  = hif_arready_blue_dca & ~tm_empty_blue_dca;
                  assign hif_arready_l_red_dca   = hif_arready_red_dca & ~tm_empty_red_dca;
                  assign xpi_arvalid_blue_dca    = xpi_arvalid_l_blue_dca & ~tm_empty_blue_dca;
                  assign xpi_arvalid_red_dca     = xpi_arvalid_l_red_dca & ~tm_empty_red_dca;

                  assign hif_arready_l_blue_dcb  = hif_arready_blue_dcb & ~tm_empty_blue_dcb;
                  assign hif_arready_l_red_dcb   = hif_arready_red_dcb & ~tm_empty_red_dcb;
                  assign xpi_arvalid_blue_dcb    = xpi_arvalid_l_blue_dcb & ~tm_empty_blue_dcb;
                  assign xpi_arvalid_red_dcb     = xpi_arvalid_l_red_dcb & ~tm_empty_red_dcb;

                  assign hif_arready_l_blue     = (data_channel_rd_blue) ? hif_arready_l_blue_dcb : hif_arready_l_blue_dca;
                  assign hif_arready_l_red      = (data_channel_rd_red)  ? hif_arready_l_red_dcb  : hif_arready_l_red_dca;

                  assign xpi_awvalid_dca        = (xpi_awdata_channel) ? 1'b0    : xpi_awvalid;
                  assign xpi_awvalid_dcb        = (xpi_awdata_channel) ? xpi_awvalid         : 1'b0;   
                  assign hif_awready            = (xpi_awdata_channel) ? hif_awready_dcb  : hif_awready_dca;

                  // inline ECC related signals
                  assign xpi_awvalid_iecc             = 1'b0;
                  assign xpi_awlast_iecc              = 1'b0;
                  assign xpi_awvalid_iecc_dcb         = 1'b0;
                  assign xpi_awlast_iecc_dcb          = 1'b0;
                  assign xpi_arvalid_iecc_blue        = 1'b0;
                  assign xpi_arlast_iecc_blue         = 1'b0;
                  assign xpi_arvalid_iecc_blue_dcb    = 1'b0;
                  assign xpi_arlast_iecc_blue_dcb     = 1'b0;
                  assign xpi_arvalid_iecc_red         = 1'b0;
                  assign xpi_arlast_iecc_red          = 1'b0;
                  assign xpi_arvalid_iecc_red_dcb     = 1'b0;
                  assign xpi_arlast_iecc_red_dcb      = 1'b0;

                  assign xpi_awaddr                = xpi_awaddr_i; 
                  assign xpi_awrmw                 = xpi_awrmw_i; 
                  assign xpi_awqos                 = xpi_awqos_i;
                  assign xpi_awpagematch           = xpi_awpagematch_i; 
                  assign xpi_awautopre             = xpi_awautopre_i;
                  assign xpi_awaddr_dcb            = xpi_awaddr_i; 
                  assign xpi_awrmw_dcb             = xpi_awrmw_i; 
                  assign xpi_awqos_dcb             = xpi_awqos_i;
                  assign xpi_awpagematch_dcb       = xpi_awpagematch_i;
                  assign xpi_awautopre_dcb         = xpi_awautopre_i;
                  assign xpi_wqos_priority         = xpi_wqos_priority_i;
                  assign xpi_wqos_timeout          = xpi_wqos_timeout_i;
                  assign xpi_vpw_expired           = xpi_vpw_expired_i;
                  assign xpi_wqos_priority_dcb     = xpi_wqos_priority_i;
                  assign xpi_wqos_timeout_dcb      = xpi_wqos_timeout_i;
                  assign xpi_vpw_expired_dcb       = xpi_vpw_expired_i;
                  assign xpi_wdata_mask_full       = xpi_wdata_mask_full_i;
                  assign xpi_wdata_mask_full_dcb   = xpi_wdata_mask_full_i;

                  assign xpi_exa_awlast            = xpi_exa_awlast_i;
                  assign xpi_exa_short_burst       = xpi_exa_short_burst_i;
                  assign xpi_exa_awlast_dcb        = xpi_exa_awlast_i;
                  assign xpi_exa_short_burst_dcb   = xpi_exa_short_burst_i;
               
                  assign xpi_wexa_acc_dca       = xpi_wexa_acc;
                  assign xpi_wexa_acc_dcb       = xpi_wexa_acc;
                  assign xpi_wexa_acc_lock_dca  = xpi_wexa_acc_lock;
                  assign xpi_wexa_acc_lock_dcb  = xpi_wexa_acc_lock;
                  assign xpi_awid_dca           = xpi_awid;
                  assign xpi_awid_dcb           = xpi_awid;
                  assign xpi_wpoison_dca        = xpi_wpoison;
                  assign xpi_wpoison_dcb        = xpi_wpoison;
                  assign xpi_ocpar_err_dca      = xpi_ocpar_err;
                  assign xpi_ocpar_err_dcb      = xpi_ocpar_err;
                  assign xpi_awuser_dca         = xpi_awuser_i;
                  assign xpi_awuser_dcb         = xpi_awuser_i;

                  assign xpi_araddr_blue              = xpi_araddr_blue_i;
                  assign xpi_arqos_blue               = xpi_arqos_blue_i;
                  assign xpi_rqos_priority_blue       = xpi_rqos_priority_blue_i;
                  assign xpi_rqos_timeout_blue        = xpi_rqos_timeout_blue_i;
                  assign xpi_vpr_expired_blue         = xpi_vpr_expired_blue_i;
                  assign xpi_arpagematch_blue         = xpi_arpagematch_blue_i;
                  assign xpi_arautopre_blue           = xpi_arautopre_blue_i;
                  assign xpi_araddr_blue_dcb          = xpi_araddr_blue_i;
                  assign xpi_arqos_blue_dcb           = xpi_arqos_blue_i;
                  assign xpi_rqos_priority_blue_dcb   = xpi_rqos_priority_blue_i;
                  assign xpi_rqos_timeout_blue_dcb    = xpi_rqos_timeout_blue_i;
                  assign xpi_vpr_expired_blue_dcb     = xpi_vpr_expired_blue_i;
                  assign xpi_arpagematch_blue_dcb     = xpi_arpagematch_blue_i;
                  assign xpi_arautopre_blue_dcb       = xpi_arautopre_blue_i;

                  assign xpi_read_bypass_reorder_blue = xpi_read_bypass_reorder_blue_i;
                  assign xpi_rd_arinfo_blue           = xpi_rd_arinfo_blue_i;
                  assign abeat_info_blue              = abeat_info_blue_i;
                  assign e_rexa_acc_blue              = e_rexa_acc_blue_i;
                  assign e_rexa_acc_instr_blue        = e_rexa_acc_instr_blue_i;
                  assign e_rpoison_blue               = e_rpoison_blue_i;
                  assign e_ocpar_err_blue             = e_ocpar_err_blue_i;
                  assign xpi_rd_arlast_blue           = xpi_rd_arlast_blue_i;
                  assign xpi_rd_arid_blue             = xpi_rd_arid_blue_i;
                  assign xpi_read_bypass_reorder_blue_dcb = xpi_read_bypass_reorder_blue_i;
                  assign xpi_rd_arinfo_blue_dcb           = xpi_rd_arinfo_blue_i;
                  assign abeat_info_blue_dcb              = abeat_info_blue_i;
                  assign e_rexa_acc_blue_dcb              = e_rexa_acc_blue_i;
                  assign e_rexa_acc_instr_blue_dcb        = e_rexa_acc_instr_blue_i;
                  assign e_rpoison_blue_dcb               = e_rpoison_blue_i;
                  assign e_ocpar_err_blue_dcb             = e_ocpar_err_blue_i;
                  assign xpi_rd_arlast_blue_dcb           = xpi_rd_arlast_blue_i;
                  assign xpi_rd_arid_blue_dcb             = xpi_rd_arid_blue_i;
                  assign e_user_blue                        = e_user_blue_i;
                  assign e_user_blue_dcb                    = e_user_blue_i;

                  assign xpi_rexa_pyld_blue           = xpi_rexa_pyld_blue_i;                  
                  assign xpi_rexa_pyld_blue_dcb       = xpi_rexa_pyld_blue_i;
                  assign xpi_wexa_pyld                = xpi_wexa_pyld_i;
                  assign xpi_wexa_pyld_dcb            = xpi_wexa_pyld_i;

                  assign occap_xpi_dch_rd_rar_err     = 1'b0;
                  assign occap_xpi_dch_wr_rar_err     = 1'b0;

               end // if (PA_OPT_TYPE==2)
               else begin: PA_seq
                  // When sequential PA, dch_arb block needed to achieve 100% utilization
                  // This is beacause the PA introduces a delay in the grant, this means that if switching alternatively, XPI is going to send 1 command evey 4 cycles to each channel (1 every 2 cycles in total), and this can't sustain streaming.
                  // arbiter is needed to switch to the next channel just after requesting grant to the PA
                  wire [DCH_RD_INFOW-1:0] dch_rd_info_dca, dch_rd_info_dcb, rd_info_dch_dca, rd_info_dch_dcb;
                  wire [DCH_WR_INFOW-1:0] dch_wr_info_dca, dch_wr_info_dcb, wr_info_dch_dca, wr_info_dch_dcb;
                  wire [MEMC_NO_OF_ENTRY_LG2-1:0]  atoken_tmp_dca_unused, atoken_tmp_dcb_unused;
                  wire [A_NPORTS_LG2-1:0]          port_num_tmp_unused, port_num_tmp_dcb_unused;
                  wire                             queue_tmp_unused, queue_tmp_dcb_unused;
                  wire awvalid_dca_i, awvalid_dcb_i, awready_dca_i, awready_dcb_i;
                  wire hif_awready_dca_out, hif_awready_dcb_out;

                  wire wr_dch_arb_red_in_unused;
                  wire avalid_red_dca_out_unused, avalid_red_dcb_out_unused, aready_red_dca_out_unused, aready_red_dcb_out_unused;

                  wire xpi_arvalid_blue_dca_out, xpi_arvalid_blue_dcb_out, xpi_arvalid_red_dca_out, xpi_arvalid_red_dcb_out, hif_arready_blue_dca_out, hif_arready_blue_dcb_out, hif_arready_red_dca_out, hif_arready_red_dcb_out;
      
                  assign dch_rd_info_dca  = {xpi_rd_iecc_blk_valid_blue,xpi_rd_iecc_blk_end_blue,xpi_araddr_blue_i,xpi_arqos_blue_i,xpi_rqos_priority_blue_i,xpi_arpagematch_blue_i,xpi_read_bypass_reorder_blue_i,xpi_rd_arinfo_blue_i,atoken_tmp,abeat_info_blue_i,e_rexa_acc_blue_i,e_rexa_acc_instr_blue_i,e_rpoison_blue_i,e_ocpar_err_blue_i,e_user_blue_i,BLUE_QUEUE,xpi_rd_arlast_blue_i,xpi_rd_arid_blue_i,xpi_rexa_pyld_blue_i,port_num,xpi_arautopre_blue_i};
                  assign dch_rd_info_dcb  = dch_rd_info_dca;
                  assign push_vpr_en_dca = (xpi_rqos_priority_blue_i == VPRW)?1'b1:1'b0;
                  assign push_vpr_en_dcb = (xpi_rqos_priority_blue_i == VPRW)?1'b1:1'b0;
                  
                  assign {xpi_arvalid_iecc_blue,xpi_arlast_iecc_blue,xpi_araddr_blue,xpi_arqos_blue,xpi_rqos_priority_blue,xpi_arpagematch_blue,xpi_read_bypass_reorder_blue,xpi_rd_arinfo_blue,atoken_tmp_dca_unused,abeat_info_blue,e_rexa_acc_blue,e_rexa_acc_instr_blue,e_rpoison_blue,e_ocpar_err_blue,e_user_blue,queue_tmp_unused,xpi_rd_arlast_blue,xpi_rd_arid_blue,xpi_rexa_pyld_blue,port_num_tmp_unused,xpi_arautopre_blue} = rd_info_dch_dca;
                  assign xpi_rqos_timeout_blue = xpi_rqos_timeout_blue_dca_int;
                  assign xpi_vpr_expired_blue  = xpi_vpr_expired_blue_dca_int;
                  assign pop_vpr_en_dca = (xpi_rqos_priority_blue == VPRW)?1'b1:1'b0;

                  assign {xpi_arvalid_iecc_blue_dcb,xpi_arlast_iecc_blue_dcb,xpi_araddr_blue_dcb,xpi_arqos_blue_dcb,xpi_rqos_priority_blue_dcb,xpi_arpagematch_blue_dcb,xpi_read_bypass_reorder_blue_dcb,xpi_rd_arinfo_blue_dcb,atoken_tmp_dcb_unused,abeat_info_blue_dcb,e_rexa_acc_blue_dcb,e_rexa_acc_instr_blue_dcb,e_rpoison_blue_dcb,e_ocpar_err_blue_dcb,e_user_blue_dcb,queue_tmp_dcb_unused,xpi_rd_arlast_blue_dcb,xpi_rd_arid_blue_dcb,xpi_rexa_pyld_blue_dcb,port_num_tmp_dcb_unused,xpi_arautopre_blue_dcb} = rd_info_dch_dcb;
                  assign xpi_rqos_timeout_blue_dcb = xpi_rqos_timeout_blue_dcb_int;
                  assign xpi_vpr_expired_blue_dcb  = xpi_vpr_expired_blue_dcb_int;
                  assign pop_vpr_en_dcb = (xpi_rqos_priority_blue_dcb == VPRW)?1'b1:1'b0;
               

                  assign dch_wr_info_dca  = {xpi_awaddr_i,xpi_awrmw_i,xpi_awqos_i,xpi_awpagematch_i,xpi_awautopre_i,xpi_exa_awlast_i,xpi_exa_short_burst_i,xpi_wexa_acc,xpi_wexa_acc_lock,xpi_awid,xpi_awuser_i,xpi_wpoison,xpi_ocpar_err,xpi_wqos_priority_i,xpi_wexa_pyld_i};
                  assign dch_wr_info_dcb  = dch_wr_info_dca;
                  assign push_vpw_en_dca = (xpi_wqos_priority_i == VPRW)?1'b1:1'b0;
                  assign push_vpw_en_dcb = (xpi_wqos_priority_i == VPRW)?1'b1:1'b0;
    
                  assign {xpi_awaddr,xpi_awrmw,xpi_awqos,xpi_awpagematch,xpi_awautopre,xpi_exa_awlast,xpi_exa_short_burst,xpi_wexa_acc_dca,xpi_wexa_acc_lock_dca,xpi_awid_dca,xpi_awuser_dca,xpi_wpoison_dca,xpi_ocpar_err_dca,xpi_wqos_priority,xpi_wexa_pyld} = wr_info_dch_dca;
                  assign xpi_wqos_timeout = xpi_wqos_timeout_dca_int;
                  assign xpi_vpw_expired = xpi_vpw_expired_dca_int;
                  assign pop_vpw_en_dca = (xpi_wqos_priority == VPRW)?1'b1:1'b0;

                  assign {xpi_awaddr_dcb,xpi_awrmw_dcb,xpi_awqos_dcb,xpi_awpagematch_dcb,xpi_awautopre_dcb,xpi_exa_awlast_dcb,xpi_exa_short_burst_dcb,xpi_wexa_acc_dcb,xpi_wexa_acc_lock_dcb,xpi_awid_dcb,xpi_awuser_dcb,xpi_wpoison_dcb,xpi_ocpar_err_dcb,xpi_wqos_priority_dcb,xpi_wexa_pyld_dcb} = wr_info_dch_dcb;
                  assign xpi_wqos_timeout_dcb = xpi_wqos_timeout_dcb_int;
                  assign xpi_vpw_expired_dcb = xpi_vpw_expired_dcb_int;
                  assign pop_vpw_en_dcb = (xpi_wqos_priority_dcb == VPRW)?1'b1:1'b0;

                  assign xpi_wdata_mask_full       = {NBEATS{1'b0}}; // inline ECC mask full, not supported
                  assign xpi_wdata_mask_full_dcb   = {NBEATS{1'b0}}; // inline ECC mask full, not supported

                  assign awvalid_dca_i        = (xpi_awdata_channel) ? 1'b0    : xpi_awvalid;
                  assign awvalid_dcb_i        = (xpi_awdata_channel) ? xpi_awvalid         : 1'b0;
                  assign hif_awready          = (xpi_awdata_channel) ? hif_awready_dcb_out  : hif_awready_dca_out;

                  assign wr_dch_arb_red_in_unused = 1'b0;

               // READ channel arbiter
               DWC_ddr_umctl2_xpi_dch_arb
               
               #(
                  .NUM_CHANNELS  (2),
                  .INFOW         (DCH_RD_INFOW),
                  .OCCAP_EN      (OCCAP_EN),
                  .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
                  .QOS_TW        (RQOS_TW),
                  .VPT_EN        (VPR_EN))
               U_xpi_rd_dch_arb
               (  // inputs
                  .clk                 (e_clk),
                  .rst_n               (e_rst_n),
                  .reg_ddrc_occap_en   (reg_ddrc_occap_en),
                  .avalid_blue_dca_in  (xpi_arvalid_l_blue_dca),
                  .avalid_blue_dcb_in  (xpi_arvalid_l_blue_dcb),
                  .avalid_red_dca_in   (xpi_arvalid_l_red_dca), // not used
                  .avalid_red_dcb_in   (xpi_arvalid_l_red_dcb), // not used
                  .aready_blue_dca_in  (hif_arready_l_blue_dca),
                  .aready_blue_dcb_in  (hif_arready_l_blue_dcb),
                  .aready_red_dca_in   (hif_arready_l_red_dca), // not used
                  .aready_red_dcb_in   (hif_arready_l_red_dcb), // not used
                  .data_channel_blue   (data_channel_rd_blue),
                  .data_channel_red    (data_channel_rd_red), // not used
                  .info_dca_in         (dch_rd_info_dca),
                  .info_dcb_in         (dch_rd_info_dcb),
                  .qos_timeout_dca_in  (xpi_rqos_timeout_blue_i),
                  .qos_timeout_dcb_in  (xpi_rqos_timeout_blue_i),
                  .vpt_expired_dca_in  (xpi_vpr_expired_blue_i),
                  .vpt_expired_dcb_in  (xpi_vpr_expired_blue_i),
                  .push_vpt_en_dca_in  (push_vpr_en_dca),
                  .push_vpt_en_dcb_in  (push_vpr_en_dcb),
                  .pop_vpt_en_dca_in   (pop_vpr_en_dca),
                  .pop_vpt_en_dcb_in   (pop_vpr_en_dcb),
                  // outputs
                  .occap_xpi_dch_rar_err (occap_xpi_dch_rd_rar_err),
                  .avalid_blue_dca_out (xpi_arvalid_blue_dca_out),
                  .avalid_blue_dcb_out (xpi_arvalid_blue_dcb_out),
                  .avalid_red_dca_out  (xpi_arvalid_red_dca_out), // not used
                  .avalid_red_dcb_out  (xpi_arvalid_red_dcb_out), // not used
                  .aready_blue_dca_out (hif_arready_blue_dca_out),
                  .aready_blue_dcb_out (hif_arready_blue_dcb_out),
                  .aready_red_dca_out  (hif_arready_red_dca_out), // not used
                  .aready_red_dcb_out  (hif_arready_red_dcb_out), // not used
                  .info_dca_out        (rd_info_dch_dca),
                  .info_dcb_out        (rd_info_dch_dcb),
                  .qos_timeout_dca_out (xpi_rqos_timeout_blue_dca_int),
                  .qos_timeout_dcb_out (xpi_rqos_timeout_blue_dcb_int),
                  .vpt_expired_dca_out (xpi_vpr_expired_blue_dca_int),
                  .vpt_expired_dcb_out (xpi_vpr_expired_blue_dcb_int));

               // WRITE channel arbiter
               DWC_ddr_umctl2_xpi_dch_arb
               
               #(
                  .NUM_CHANNELS  (2),
                  .INFOW         (DCH_WR_INFOW),
                  .OCCAP_EN      (OCCAP_EN),
                  .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
                  .QOS_TW        (WQOS_TW),
                  .VPT_EN        (VPW_EN))
               U_xpi_wr_dch_arb
               (  // inputs
                  .clk                 (e_clk),
                  .rst_n               (e_rst_n),
                  .reg_ddrc_occap_en   (reg_ddrc_occap_en),
                  .avalid_blue_dca_in  (awvalid_dca_i),
                  .avalid_blue_dcb_in  (awvalid_dcb_i),
                  .avalid_red_dca_in   (wr_dch_arb_red_in_unused), // not used
                  .avalid_red_dcb_in   (wr_dch_arb_red_in_unused), // not used
                  .aready_blue_dca_in  (hif_awready_dca),
                  .aready_blue_dcb_in  (hif_awready_dcb),
                  .aready_red_dca_in   (wr_dch_arb_red_in_unused), // not used
                  .aready_red_dcb_in   (wr_dch_arb_red_in_unused), // not used
                  .data_channel_blue   (xpi_awdata_channel),
                  .data_channel_red    (wr_dch_arb_red_in_unused), // not used
                  .info_dca_in         (dch_wr_info_dca),
                  .info_dcb_in         (dch_wr_info_dcb),
                  .qos_timeout_dca_in  (xpi_wqos_timeout_i),
                  .qos_timeout_dcb_in  (xpi_wqos_timeout_i),
                  .vpt_expired_dca_in  (xpi_vpw_expired_i),
                  .vpt_expired_dcb_in  (xpi_vpw_expired_i),
                  .push_vpt_en_dca_in  (push_vpw_en_dca),
                  .push_vpt_en_dcb_in  (push_vpw_en_dcb),
                  .pop_vpt_en_dca_in   (pop_vpw_en_dca),
                  .pop_vpt_en_dcb_in   (pop_vpw_en_dcb),
                  // outputs
                  .occap_xpi_dch_rar_err (occap_xpi_dch_wr_rar_err),
                  .avalid_blue_dca_out (xpi_awvalid_dca),
                  .avalid_blue_dcb_out (xpi_awvalid_dcb),
                  .avalid_red_dca_out  (avalid_red_dca_out_unused), // not used
                  .avalid_red_dcb_out  (avalid_red_dcb_out_unused), // not used
                  .aready_blue_dca_out (hif_awready_dca_out),
                  .aready_blue_dcb_out (hif_awready_dcb_out),
                  .aready_red_dca_out  (aready_red_dca_out_unused), // not used
                  .aready_red_dcb_out  (aready_red_dcb_out_unused), // not used
                  .info_dca_out        (wr_info_dch_dca),
                  .info_dcb_out        (wr_info_dch_dcb),
                  .qos_timeout_dca_out (xpi_wqos_timeout_dca_int),
                  .qos_timeout_dcb_out (xpi_wqos_timeout_dcb_int),
                  .vpt_expired_dca_out (xpi_vpw_expired_dca_int),
                  .vpt_expired_dcb_out (xpi_vpw_expired_dcb_int));
                  
                  //spyglass disable_block W528
                  //SMD: Variable set but not read
                  //SJ: Used in generate block 
                  
                  assign xpi_arvalid_l_blue_dca  = (data_channel_rd_blue) ? 1'b0 : xpi_arvalid_l_blue;
                  assign xpi_arvalid_l_red_dca   = (data_channel_rd_red) ? 1'b0 : xpi_arvalid_l_red;  
                                 
                  assign xpi_arvalid_l_blue_dcb  = (data_channel_rd_blue) ? xpi_arvalid_l_blue : 1'b0;
                  assign xpi_arvalid_l_red_dcb   = (data_channel_rd_red) ? xpi_arvalid_l_red : 1'b0;

                  assign gen_token_dca        = gen_token_blue_dca | gen_token_red_dca;
                  assign gen_token_dcb        = gen_token_blue_dcb | gen_token_red_dcb;

                  assign gen_token_blue_dca   = xpi_arvalid_blue_dca & hif_arready_l_blue_dca;
                  assign gen_token_blue_dca_i = gen_token_blue_dca;
                  assign gen_token_red_dca_i  = gen_token_red_dca;
                  assign gen_token_red_dca    = xpi_arvalid_red_dca & hif_arready_l_red_dca;
                  assign gen_token_blue_dcb   = xpi_arvalid_blue_dcb & hif_arready_l_blue_dcb;
                  assign gen_token_red_dcb    = xpi_arvalid_red_dcb & hif_arready_l_red_dcb;

                  assign hif_arready_l_blue_dca  = hif_arready_blue_dca & ~tm_empty_blue_dca;
                  assign hif_arready_l_red_dca   = hif_arready_red_dca & ~tm_empty_red_dca;
                  assign xpi_arvalid_blue_dca    = xpi_arvalid_blue_dca_out & ~tm_empty_blue_dca;
                  assign xpi_arvalid_red_dca     = xpi_arvalid_red_dca_out & ~tm_empty_red_dca;
 
                  assign hif_arready_l_blue_dcb  = hif_arready_blue_dcb & ~tm_empty_blue_dcb;
                  assign hif_arready_l_red_dcb   = hif_arready_red_dcb & ~tm_empty_red_dcb;
                  
                  assign xpi_arvalid_blue_dcb    = xpi_arvalid_blue_dcb_out & ~tm_empty_blue_dcb;
                  assign xpi_arvalid_red_dcb     = xpi_arvalid_red_dcb_out & ~tm_empty_red_dcb;
                  //spyglass enable_block W528
                  
                  // read address ready
                  assign hif_arready_l_blue     = (data_channel_rd_blue) ? hif_arready_blue_dcb_out : hif_arready_blue_dca_out;
                  assign hif_arready_l_red      = (data_channel_rd_red)  ? hif_arready_red_dcb_out  : hif_arready_red_dca_out;

                  // inline ECC related signals
                  assign xpi_awvalid_iecc             = 1'b0;
                  assign xpi_awlast_iecc              = 1'b0;
                  assign xpi_awvalid_iecc_dcb         = 1'b0;
                  assign xpi_awlast_iecc_dcb          = 1'b0;
                  //assign xpi_arvalid_iecc_blue        = 1'b0;
                  //assign xpi_arlast_iecc_blue         = 1'b0;
                  //assign xpi_arvalid_iecc_blue_dcb    = 1'b0;
                  //assign xpi_arlast_iecc_blue_dcb     = 1'b0;
                  assign xpi_arvalid_iecc_red         = 1'b0;
                  assign xpi_arlast_iecc_red          = 1'b0;
                  assign xpi_arvalid_iecc_red_dcb     = 1'b0;
                  assign xpi_arlast_iecc_red_dcb      = 1'b0;

               end // !if (PA_OPT_TYPE==2)

               assign hif_hif_rdata_dca_i          = hif_hif_rdata_dca;
               //spyglass disable_block W528
               //SMD: Variable set but not read
               //SJ: Used in generate block branch only if OCPAR or OCECC is enabled
               assign hif_hif_rdata_parity_dca_i   = hif_hif_rdata_parity_dca;
               //spyglass enable_block W528
               assign hif_rerror_dca_i             = hif_rerror_dca;
               assign hif_rlast_pkt_dca_i_unused   = hif_rlast_pkt_dca;
               assign hif_rvalid_dca_i             = hif_rvalid_dca;
               assign e_resp_token_dca_i           = e_resp_token_dca;


               // write data
               // write data ready
               wire deacc_dca_wr, deacc_dca_rd, deacc_dcb_wr, deacc_dcb_rd;
               wire deacc_dca_full, deacc_dcb_full, deacc_dca_empty, deacc_dcb_empty;

               wire [DEACC_DW-1:0] dca_d, dca_q; 
               wire [DEACC_DW-1:0] dcb_d, dcb_q;

               wire [A_DW_INT-1:0] xpi_wdata_r0, xpi_wdata_r1;
               wire [A_STRBW_INT-1:0] xpi_wstrb_r0, xpi_wparity_r0, xpi_wpar_err_r0, xpi_wstrb_r1, xpi_wparity_r1, xpi_wpar_err_r1;
               wire xpi_wlast_pkt_r0, xpi_wlast_r0, xpi_wlast_pkt_r1, xpi_wlast_r1;
               wire [DEACC_INFOW-1:0] xpi_deacc_info_r0, xpi_deacc_info_r1;


               assign dca_d = {xpi_wdata_i,xpi_wstrb_i,xpi_wparity_i,xpi_wpar_err_i,xpi_wlast_i,xpi_wlast_pkt_i,xpi_deacc_info};
               assign {xpi_wdata_r0,xpi_wstrb_r0,xpi_wparity_r0,xpi_wpar_err_r0,xpi_wlast_r0,xpi_wlast_pkt_r0,xpi_deacc_info_r0} = dca_q;
               assign dcb_d = {xpi_wdata_i,xpi_wstrb_i,xpi_wparity_i,xpi_wpar_err_i,xpi_wlast_i,xpi_wlast_pkt_i,xpi_deacc_info};
               assign {xpi_wdata_r1,xpi_wstrb_r1,xpi_wparity_r1,xpi_wpar_err_r1,xpi_wlast_r1,xpi_wlast_pkt_r1,xpi_deacc_info_r1} = dcb_q;
            
               assign xpi_wvalid_dca         = ~deacc_dca_empty;
               assign xpi_wvalid_dcb         = ~deacc_dcb_empty;
               assign deacc_dca_rd           = hif_wready_dca;
               assign deacc_dcb_rd           = hif_wready_dcb;

               if (DEACC_RT_W>1) begin: DCH_wr_fifo
                  // retime output data when required number of beats at the HIF is more than 2 (this is to allow streaming of data at the HIF)
                  // retime buffers beats between the MUX and the deacc (unpacking)

/*

   *********** MUX *******************


  xpi_wdata_channel -------> (mux select)


        (FIFO accepted the data, send back acknowledge)

                            /|
                           | |<------ !dca_full
         hif_wready <------| |
                           | |<------ !dcb_full
                            \|



         (xpi_wdata_i is valid, write to the correct FIFO)

                            /|
                           | |-------> dca_wr
         xpi_wvalid ------>| |
                           | |-------> dcb_wr
                            \|


   *********** DATA UNPACKING ****************

      NO buffering inside xpi_deacc, it doesn't introduce further delay (except 1 dead cycle needed to send the 2nd beat)

                                                          
            xpi_wdata_i ------>|            |
               dca_full <------| ch0 retime |------->| ch0 deacc |-------> xpi_wdata
                 dca_wr ------>|            |

                                                          
            xpi_wdata_i ------>|            |
               dcb_full <------| ch1 retime |------->| ch1 deacc |-------> xpi_wdata_dcb
                 dcb_wr ------>|            |


*/

                  wire dca_wr, dca_rd, dca_empty, dca_full;
                  wire dcb_wr, dcb_rd, dcb_empty, dcb_full;
                  wire [DEACC_RT_W_LG2+1-1:0] dca_wcount_unused, dcb_wcount_unused;


                  DWC_ddr_umctl2_gfifo
                          
                  #(
                     .WIDTH           (DEACC_DW),
                     .DEPTH           (DEACC_RT_W),
                     .ADDR_WIDTH      (DEACC_RT_W_LG2),
                     .COUNT_WIDTH     (DEACC_RT_W_LG2+1),
                     .OCCAP_EN        (OCCAP_EN),
                     .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
                  ) 
                  U_dca_wr_fifo (
                     .clk             (e_clk),
                     .rst_n           (e_rst_n),
                     .wr              (dca_wr),
                     .d               (dca_d),
                     .rd              (dca_rd),
                     .par_en          (reg_ddrc_occap_en),
                     .init_n          (1'b1),
                     .ff              (dca_full),
                     .wcount          (dca_wcount_unused),
                     .q               (dca_q),
                     .fe              (dca_empty),       
                     .par_err         (occap_dca_wr_par_err)
                    `ifdef SNPS_ASSERT_ON
                    `ifndef SYNTHESIS
                    ,.disable_sva_fifo_checker_rd (1'b0)
                    ,.disable_sva_fifo_checker_wr (1'b0)
                    `endif // SYNTHESIS
                    `endif // SNPS_ASSERT_ON
                  );

                  DWC_ddr_umctl2_gfifo
                          
                  #(
                     .WIDTH           (DEACC_DW),
                     .DEPTH           (DEACC_RT_W),
                     .ADDR_WIDTH      (DEACC_RT_W_LG2),
                     .COUNT_WIDTH     (DEACC_RT_W_LG2+1),
                     .OCCAP_EN        (OCCAP_EN),
                     .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)                    
                  ) 
                  U_dcb_wr_fifo (
                     .clk             (e_clk),
                     .rst_n           (e_rst_n),
                     .wr              (dcb_wr),
                     .d               (dcb_d),
                     .rd              (dcb_rd),
                     .par_en          (reg_ddrc_occap_en),
                     .init_n          (1'b1),
                     .ff              (dcb_full),
                     .wcount          (dcb_wcount_unused),
                     .q               (dcb_q),
                     .fe              (dcb_empty),
                     .par_err         (occap_dcb_wr_par_err)
                    `ifdef SNPS_ASSERT_ON
                    `ifndef SYNTHESIS
                    ,.disable_sva_fifo_checker_rd (1'b0)
                    ,.disable_sva_fifo_checker_wr (1'b0)
                    `endif // SYNTHESIS
                    `endif // SNPS_ASSERT_ON
                  );

                  assign dca_wr = (xpi_wdata_channel) ? 1'b0     : xpi_wvalid & ~dca_full;
                  assign dca_rd = ~deacc_dca_full & ~dca_empty;
                  assign dcb_wr = (xpi_wdata_channel) ? xpi_wvalid & ~dcb_full : 1'b0;
                  assign dcb_rd = ~deacc_dcb_full & ~dcb_empty;

                  assign deacc_dca_wr  = ~dca_empty;
                  assign deacc_dcb_wr  = ~dcb_empty;

                  assign hif_wready = (xpi_wdata_channel) ? ~dcb_full    : ~dca_full;

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  cp_dca_wr_fifo_full :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       dca_full==1'b1 && xpi_wvalid==1'b1 && xpi_wdata_channel==1'b0
    );

   cp_dcb_wr_fifo_full :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       dcb_full==1'b1 && xpi_wvalid==1'b1 && xpi_wdata_channel==1'b1
    );

    cp_dca_dcb_wr_fifo_full :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       dca_full==1'b1 && dcb_full==1'b1 && xpi_wvalid==1'b1
    );

    cp_dca_wr_fifo_empty :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       deacc_dca_full==1'b1 && dca_empty==1'b0
    );

    cp_dcb_wr_fifo_empty :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       deacc_dcb_full==1'b1 && dcb_empty==1'b0
    );

    assert_never #(0, 0, "Write to Channel 0 write FIFO when full", 5) a_xpi_dca_wr_fifo_full (e_clk, e_rst_n, (dca_full && dca_wr));
    assert_never #(0, 0, "Write to Channel 1 write FIFO when full", 5) a_xpi_dcb_wr_fifo_full (e_clk, e_rst_n, (dcb_full && dcb_wr));

`endif
`endif

               end // if (DEACC_RT_W>1)
               else begin: DCH_wr_nfifo

                  // when number of beats at the HIF is 2 or less, no buffering after the MUX, write directly to the deacc

                  assign dca_q = dca_d;
                  assign dcb_q = dcb_d;

                  assign hif_wready    = (xpi_wdata_channel) ? ~deacc_dcb_full    : ~deacc_dca_full;
                  assign deacc_dca_wr  = (xpi_wdata_channel) ? 1'b0     : xpi_wvalid;
                  assign deacc_dcb_wr  = (xpi_wdata_channel) ? xpi_wvalid           : 1'b0;

                  assign occap_dca_wr_par_err = 1'b0;
                  assign occap_dcb_wr_par_err = 1'b0;

               end // !if (DEACC_RT_W>1)

               // DATA UNPACKING
               // data downsizers for channel interleaving
               // channel 0
               DWC_ddr_umctl2_xpi_deacc
               
               #( .DW_IN            (A_DW_INT),
                  .DW_OUT           (A_DW),
                  .SW_IN            (A_STRBW_INT),
                  .SW_OUT           (A_STRBW),
                  .WRDATA_CYCLES    (NBEATS),
                  .INFOW            (DEACC_INFOW),
                  .OUT_MAXSIZE      (ENIF_MAXSIZE),
                  .IN_MAXSIZE       (AXI_MAXSIZE),
                  .OUT_LENW         (ENIF_LENW))
               U_deacc_dca
               (  .clk              (e_clk),
                  .rst_n            (e_rst_n),
                  .data_in          (xpi_wdata_r0),
                  .strobe_in        (xpi_wstrb_r0),
                  .parity_in        (xpi_wparity_r0),
                  .parity_err_in    (xpi_wpar_err_r0),
                  .wr               (deacc_dca_wr),
                  .rd               (deacc_dca_rd),
                  .last             (xpi_wlast_r0),
                  .last_pkt         (xpi_wlast_pkt_r0),
                  .info             (xpi_deacc_info_r0),
                  .data_out         (xpi_wdata),
                  .strobe_out       (xpi_wstrb),
                  .parity_out       (xpi_wparity),
                  .parity_err_out   (xpi_wpar_err),
                  .last_out         (xpi_wlast),
                  .last_pkt_out     (xpi_wlast_pkt),
                  .full             (deacc_dca_full),
                  .empty            (deacc_dca_empty));
            
               // channel 1
               DWC_ddr_umctl2_xpi_deacc
               
               #( .DW_IN            (A_DW_INT),
                  .DW_OUT           (A_DW),
                  .SW_IN            (A_STRBW_INT),
                  .SW_OUT           (A_STRBW),
                  .WRDATA_CYCLES    (NBEATS),
                  .INFOW            (DEACC_INFOW),
                  .OUT_MAXSIZE      (ENIF_MAXSIZE),
                  .IN_MAXSIZE       (AXI_MAXSIZE),
                  .OUT_LENW         (ENIF_LENW))
               U_deacc_dcb
               (  .clk              (e_clk),
                  .rst_n            (e_rst_n),
                  .data_in          (xpi_wdata_r1),
                  .strobe_in        (xpi_wstrb_r1),
                  .parity_in        (xpi_wparity_r1),
                  .parity_err_in    (xpi_wpar_err_r1),
                  .wr               (deacc_dcb_wr),
                  .rd               (deacc_dcb_rd),
                  .last             (xpi_wlast_r1),
                  .last_pkt         (xpi_wlast_pkt_r1),
                  .info             (xpi_deacc_info_r1),
                  .data_out         (xpi_wdata_dcb),
                  .strobe_out       (xpi_wstrb_dcb),
                  .parity_out       (xpi_wparity_dcb),
                  .parity_err_out   (xpi_wpar_err_dcb),
                  .last_out         (xpi_wlast_dcb),
                  .last_pkt_out     (xpi_wlast_pkt_dcb),
                  .full             (deacc_dcb_full),
                  .empty            (deacc_dcb_empty));

            end // DUAL_CHANNEL_INTERLEAVE_HP==1
            else begin: INTLV_up_size

               // output demux
               assign xpi_arvalid_l_blue_dca  = (data_channel_rd_blue) ? 1'b0 : xpi_arvalid_l_blue;
               assign xpi_arvalid_l_blue_dcb  = (data_channel_rd_blue) ? xpi_arvalid_l_blue : 1'b0;
               assign xpi_arvalid_l_red_dca   = (data_channel_rd_red) ? 1'b0 : xpi_arvalid_l_red;
               assign xpi_arvalid_l_red_dcb   = (data_channel_rd_red) ? xpi_arvalid_l_red : 1'b0;

               assign gen_token_dca        = gen_token_blue_dca | gen_token_red_dca;
               assign gen_token_dcb        = gen_token_blue_dcb | gen_token_red_dcb;

               assign gen_token_blue_dca   = xpi_arvalid_blue_dca & hif_arready_l_blue_dca;
               assign gen_token_red_dca    = xpi_arvalid_red_dca & hif_arready_l_red_dca;
               assign gen_token_blue_dcb   = xpi_arvalid_blue_dcb & hif_arready_l_blue_dcb;
               assign gen_token_red_dcb    = xpi_arvalid_red_dcb & hif_arready_l_red_dcb;

               assign gen_token_blue_dca_i = gen_token_blue_dca;
               assign gen_token_red_dca_i  = gen_token_red_dca;

               assign hif_arready_l_blue_dca  = hif_arready_blue_dca & ~tm_empty_blue_dca;
               assign hif_arready_l_red_dca   = hif_arready_red_dca & ~tm_empty_red_dca;
               assign xpi_arvalid_blue_dca    = xpi_arvalid_l_blue_dca & ~tm_empty_blue_dca;
               assign xpi_arvalid_red_dca     = xpi_arvalid_l_red_dca & ~tm_empty_red_dca;

               assign hif_arready_l_blue_dcb  = hif_arready_blue_dcb & ~tm_empty_blue_dcb;
               assign hif_arready_l_red_dcb   = hif_arready_red_dcb & ~tm_empty_red_dcb;
               assign xpi_arvalid_blue_dcb    = xpi_arvalid_l_blue_dcb & ~tm_empty_blue_dcb;
               assign xpi_arvalid_red_dcb     = xpi_arvalid_l_red_dcb & ~tm_empty_red_dcb;

               assign hif_arready_l_blue     = (data_channel_rd_blue) ? hif_arready_l_blue_dcb : hif_arready_l_blue_dca;
               assign hif_arready_l_red      = (data_channel_rd_red)  ? hif_arready_l_red_dcb  : hif_arready_l_red_dca;

               assign hif_hif_rdata_dca_i          = hif_hif_rdata_dca;
               //spyglass disable_block W528
               //SMD: Variable set but not read
               //SJ: Used in generate block branch only if OCPAR or OCECC is enabled
               assign hif_hif_rdata_parity_dca_i   = hif_hif_rdata_parity_dca;
               //spyglass enable_block W528
               assign hif_rerror_dca_i             = hif_rerror_dca;
               assign hif_rlast_pkt_dca_i_unused   = hif_rlast_pkt_dca;
               assign hif_rvalid_dca_i             = hif_rvalid_dca;
               assign e_resp_token_dca_i           = e_resp_token_dca;

               // inline ECC related signals
               assign xpi_awvalid_iecc             = 1'b0;
               assign xpi_awlast_iecc              = 1'b0;
               assign xpi_awvalid_iecc_dcb         = 1'b0;
               assign xpi_awlast_iecc_dcb          = 1'b0;
               assign xpi_arvalid_iecc_blue        = 1'b0;
               assign xpi_arlast_iecc_blue         = 1'b0;
               assign xpi_arvalid_iecc_blue_dcb    = 1'b0;
               assign xpi_arlast_iecc_blue_dcb     = 1'b0;
               assign xpi_arvalid_iecc_red         = 1'b0;
               assign xpi_arlast_iecc_red          = 1'b0;
               assign xpi_arvalid_iecc_red_dcb     = 1'b0;
               assign xpi_arlast_iecc_red_dcb      = 1'b0;

               assign xpi_awvalid_dca        = (xpi_awdata_channel) ? 1'b0    : xpi_awvalid;
               assign xpi_wvalid_dca         = (xpi_wdata_channel) ? 1'b0     : xpi_wvalid;
               assign xpi_awvalid_dcb        = (xpi_awdata_channel) ? xpi_awvalid         : 1'b0;   
               assign xpi_wvalid_dcb         = (xpi_wdata_channel) ? xpi_wvalid           : 1'b0;
               // input mux
               // write address valid
               assign hif_awready            = (xpi_awdata_channel) ? hif_awready_dcb  : hif_awready_dca;
               // write data ready
               assign hif_wready             = (xpi_wdata_channel) ? hif_wready_dcb    : hif_wready_dca;
               // write data
               assign xpi_wdata              = xpi_wdata_i;
               assign xpi_wstrb              = xpi_wstrb_i;
               assign xpi_wlast              = xpi_wlast_i;
               assign xpi_wlast_pkt          = xpi_wlast_pkt_i;
               assign xpi_snf_mode           = xpi_snf_mode_i;
               assign xpi_wpar_err           = xpi_wpar_err_i;
               assign xpi_wparity            = xpi_wparity_i;
               assign xpi_wdata_dcb          = xpi_wdata_i;
               assign xpi_wstrb_dcb          = xpi_wstrb_i;
               assign xpi_wlast_dcb          = xpi_wlast_i;
               assign xpi_wlast_pkt_dcb      = xpi_wlast_pkt_i;
               assign xpi_snf_mode_dcb           = xpi_snf_mode_i;
               assign xpi_wpar_err_dcb       = xpi_wpar_err_i;
               assign xpi_wparity_dcb        = xpi_wparity_i;

               assign xpi_wexa_acc_dca       = xpi_wexa_acc;
               assign xpi_wexa_acc_dcb       = xpi_wexa_acc;
               assign xpi_wexa_acc_lock_dca  = xpi_wexa_acc_lock;
               assign xpi_wexa_acc_lock_dcb  = xpi_wexa_acc_lock;
               assign xpi_awid_dca           = xpi_awid;
               assign xpi_awid_dcb           = xpi_awid;
               assign xpi_wpoison_dca        = xpi_wpoison;
               assign xpi_wpoison_dcb        = xpi_wpoison;
               assign xpi_ocpar_err_dca      = xpi_ocpar_err;
               assign xpi_ocpar_err_dcb      = xpi_ocpar_err;
               assign xpi_awuser_dca         = xpi_awuser_i;
               assign xpi_awuser_dcb         = xpi_awuser_i;

               assign xpi_awaddr                = xpi_awaddr_i; 
               assign xpi_awrmw                 = xpi_awrmw_i; 
               assign xpi_awqos                 = xpi_awqos_i;
               assign xpi_awpagematch           = xpi_awpagematch_i; 
               assign xpi_awautopre             = xpi_awautopre_i;
               assign xpi_exa_awlast            = xpi_exa_awlast_i;
               assign xpi_exa_short_burst       = xpi_exa_short_burst_i;
               assign xpi_wqos_priority         = xpi_wqos_priority_i;
               assign xpi_wqos_timeout          = xpi_wqos_timeout_i;
               assign xpi_vpw_expired           = xpi_vpw_expired_i;
               assign xpi_awaddr_dcb            = xpi_awaddr_i; 
               assign xpi_awrmw_dcb             = xpi_awrmw_i; 
               assign xpi_awqos_dcb             = xpi_awqos_i;
               assign xpi_awpagematch_dcb       = xpi_awpagematch_i; 
               assign xpi_awautopre_dcb         = xpi_awautopre_i;
               assign xpi_exa_awlast_dcb        = xpi_exa_awlast_i;
               assign xpi_exa_short_burst_dcb   = xpi_exa_short_burst_i;
               assign xpi_wqos_priority_dcb     = xpi_wqos_priority_i;
               assign xpi_wqos_timeout_dcb      = xpi_wqos_timeout_i;
               assign xpi_vpw_expired_dcb       = xpi_vpw_expired_i;
               assign xpi_wdata_mask_full       = xpi_wdata_mask_full_i;
               assign xpi_wdata_mask_full_dcb   = xpi_wdata_mask_full_i;

               assign xpi_araddr_blue              = xpi_araddr_blue_i;
               assign xpi_arqos_blue               = xpi_arqos_blue_i;
               assign xpi_rqos_priority_blue       = xpi_rqos_priority_blue_i;
               assign xpi_rqos_timeout_blue        = xpi_rqos_timeout_blue_i;
               assign xpi_vpr_expired_blue         = xpi_vpr_expired_blue_i;
               assign xpi_arpagematch_blue         = xpi_arpagematch_blue_i;
               assign xpi_arautopre_blue           = xpi_arautopre_blue_i;
               assign xpi_araddr_blue_dcb          = xpi_araddr_blue_i;
               assign xpi_arqos_blue_dcb           = xpi_arqos_blue_i;
               assign xpi_rqos_priority_blue_dcb   = xpi_rqos_priority_blue_i;
               assign xpi_rqos_timeout_blue_dcb    = xpi_rqos_timeout_blue_i;
               assign xpi_vpr_expired_blue_dcb     = xpi_vpr_expired_blue_i;
               assign xpi_arpagematch_blue_dcb     = xpi_arpagematch_blue_i;
               assign xpi_arautopre_blue_dcb       = xpi_arautopre_blue_i;

               assign xpi_read_bypass_reorder_blue = xpi_read_bypass_reorder_blue_i;
               assign xpi_rd_arinfo_blue           = xpi_rd_arinfo_blue_i;
               assign abeat_info_blue              = abeat_info_blue_i;
               assign e_rexa_acc_blue              = e_rexa_acc_blue_i;
               assign e_rexa_acc_instr_blue        = e_rexa_acc_instr_blue_i;
               assign e_rpoison_blue               = e_rpoison_blue_i;
               assign e_ocpar_err_blue             = e_ocpar_err_blue_i;
               assign xpi_rd_arlast_blue           = xpi_rd_arlast_blue_i;
               assign xpi_rd_arid_blue             = xpi_rd_arid_blue_i;
               assign xpi_read_bypass_reorder_blue_dcb = xpi_read_bypass_reorder_blue_i;
               assign xpi_rd_arinfo_blue_dcb           = xpi_rd_arinfo_blue_i;
               assign abeat_info_blue_dcb              = abeat_info_blue_i;
               assign e_rexa_acc_blue_dcb              = e_rexa_acc_blue_i;
               assign e_rexa_acc_instr_blue_dcb        = e_rexa_acc_instr_blue_i;
               assign e_rpoison_blue_dcb               = e_rpoison_blue_i;
               assign e_ocpar_err_blue_dcb             = e_ocpar_err_blue_i;
               assign xpi_rd_arlast_blue_dcb           = xpi_rd_arlast_blue_i;
               assign xpi_rd_arid_blue_dcb             = xpi_rd_arid_blue_i;
               assign e_user_blue                        = e_user_blue_i;
               assign e_user_blue_dcb                    = e_user_blue_i;

               assign xpi_rexa_pyld_blue           = xpi_rexa_pyld_blue_i;
               assign xpi_rexa_pyld_blue_dcb       = xpi_rexa_pyld_blue_i;
               assign xpi_wexa_pyld                = xpi_wexa_pyld_i;
               assign xpi_wexa_pyld_dcb            = xpi_wexa_pyld_i;

               assign occap_dca_wr_par_err               = 1'b0;
               assign occap_dcb_wr_par_err               = 1'b0;

               assign occap_xpi_dch_rd_rar_err     = 1'b0;
               assign occap_xpi_dch_wr_rar_err     = 1'b0;

            end // !DUAL_CHANNEL_INTERLEAVE_HP==1

            // red queue not supported with dual channel
            assign xpi_rexa_pyld_red            = {EXA_PYLD_W{1'b0}};
            assign xpi_rexa_pyld_red_dcb        = {EXA_PYLD_W{1'b0}};
            assign xpi_araddr_red               = {M_ADDRW{1'b0}};
            assign xpi_arqos_red                = {AXI_QOSW{1'b0}};
            assign xpi_rqos_priority_red        = {RQOS_RW{1'b0}};
            assign xpi_rqos_timeout_red         = {RQOS_TW{1'b0}};
            assign xpi_vpr_expired_red          = 1'b0;
            assign xpi_arpagematch_red          = 1'b0;
            assign xpi_arautopre_red            = 1'b0;
            assign xpi_read_bypass_reorder_red  = 1'b0;
            assign xpi_rd_arinfo_red            = {RINFOW{1'b0}};
            assign abeat_info_red               = {BEAT_INFOW{1'b0}};
            assign e_rexa_acc_red               = 1'b0;
            assign e_rexa_acc_instr_red         = 1'b0;
            assign e_rpoison_red                = 1'b0;
            assign e_ocpar_err_red              = 1'b0;
            assign xpi_rd_arlast_red            = 1'b0;
            assign xpi_rd_arid_red              = {AXI_IDW{1'b0}};
            assign e_user_red                   = {AXI_USERW{1'b0}};
//spyglass disable_block W528
//SMD: Variable 'bam_addr_offset_red[5:0]' set but not read
//SJ: Used in generate block. Variable is read only if USE2RAQ==1
            assign bam_addr_offset_red          = {MAXSIZE{1'b0}};
//spyglass enable_block W528
            assign xpi_read_bypass_reorder_red_dcb = 1'b0;
            assign xpi_rd_arinfo_red_dcb        = {RINFOW{1'b0}};
            assign abeat_info_red_dcb           = {BEAT_INFOW{1'b0}};
            assign e_rexa_acc_red_dcb           = 1'b0;
            assign e_rexa_acc_instr_red_dcb     = 1'b0;
            assign e_rpoison_red_dcb            = 1'b0;
            assign e_ocpar_err_red_dcb          = 1'b0;
            assign xpi_rd_arlast_red_dcb        = 1'b0;
            assign xpi_rd_arid_red_dcb          = {AXI_IDW{1'b0}};
            assign xpi_araddr_red_dcb           = {M_ADDRW{1'b0}};
            assign xpi_arqos_red_dcb            = {AXI_QOSW{1'b0}};
            assign xpi_rqos_priority_red_dcb    = {RQOS_RW{1'b0}};
            assign xpi_rqos_timeout_red_dcb     = {RQOS_TW{1'b0}};
            assign xpi_vpr_expired_red_dcb      = 1'b0;
            assign xpi_arpagematch_red_dcb      = 1'b0;
            assign xpi_arautopre_red_dcb        = 1'b0;
            assign e_user_red_dcb               = {AXI_USERW{1'b0}};

            assign dch_sel_dcm = (gen_token_blue) ? (gen_token_blue_dcb ? 1'b1 : 1'b0) :
                                                    (gen_token_red_dcb ? 1'b1 : 1'b0);


            assign wcmd_dca_out = xpi_awvalid_dca & hif_awready_dca;
            assign wcmd_dcb_out = xpi_awvalid_dcb & hif_awready_dcb;

            assign wptrq_wr = wcmd_dca_out | wcmd_dcb_out;

            assign wptrq_d = wcmd_dcb_out ? {xpi_exa_awlast_dcb,1'b1} : {xpi_exa_awlast,1'b0};

            assign wptrq_rd = wrq0_rd | wrq1_rd;
            
            DWC_ddr_umctl2_gfifo
             
            #(
               .WIDTH           (AXI_WPTRQW),
               .DEPTH           (AXI_WPTRQD),
               .ADDR_WIDTH      (AXI_WPTRQD_LG2),
               .COUNT_WIDTH     (AXI_WPTRQD_LG2+1),
               .OCCAP_EN        (OCCAP_EN),
               .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
            ) 
            wptrq 
            (
               .clk             (e_clk),
               .rst_n           (e_rst_n),
               .wr              (wptrq_wr),
               .d               (wptrq_d),
               .rd              (wptrq_rd),
               .par_en          (reg_ddrc_occap_en),
               .init_n          (1'b1),
               //spyglass disable_block W528
               //SMD: A signal or variable is set but never read
               //SJ: Used in RTL assertion
               .ff              (wptrq_full),
               //spyglass enable_block W528
               .wcount          (wptrq_wcount_unused),    
               .q               (wptrq_q),
               .fe              (wptrq_empty_unused),
               .par_err         (occap_xpi_wptrq_err)
              `ifdef SNPS_ASSERT_ON
              `ifndef SYNTHESIS
              ,.disable_sva_fifo_checker_rd (1'b0)
              ,.disable_sva_fifo_checker_wr (1'b0)
              `endif // SYNTHESIS
              `endif // SNPS_ASSERT_ON
            );

            assign {wptrq_awlast,wptrq_channel} = wptrq_q;

            // write response queues

            assign wrq0_rd = (xpi_bready | ~wptrq_awlast) & wrq_sel[0];

            assign wrq0_wr = hif_bvalid_dca;

            assign wrq0_d = xpi_bresp_dca;
            

            DWC_ddr_umctl2_gfifo
             
            #(
               .WIDTH           (WRQW),
               .DEPTH           (AXI_PRE_WRQD),
               .ADDR_WIDTH      (AXI_PRE_WRQD_LG2),
               .COUNT_WIDTH     (AXI_PRE_WRQD_LG2+1),
               .OCCAP_EN        (OCCAP_EN),
               .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)               
            ) 
            wrq_0
            (
               .clk             (e_clk),
               .rst_n           (e_rst_n),
               .wr              (wrq0_wr),
               .d               (wrq0_d),
               .rd              (wrq0_rd),
               .par_en          (reg_ddrc_occap_en),
               .init_n          (1'b1),
               .ff              (wrq0_full),
               .wcount          (wrq0_wcount_unused),    
               .q               (wrq0_q),
               .fe              (wrq0_empty),
               .par_err         (occap_xpi_wrq0_err)
              `ifdef SNPS_ASSERT_ON
              `ifndef SYNTHESIS
              ,.disable_sva_fifo_checker_rd (1'b0)
              ,.disable_sva_fifo_checker_wr (1'b0)
              `endif // SYNTHESIS
              `endif // SNPS_ASSERT_ON
            );

            assign wrq1_rd = (xpi_bready | ~wptrq_awlast) & wrq_sel[1];

            assign wrq1_wr = hif_bvalid_dcb;

            assign wrq1_d = xpi_bresp_dcb;

            DWC_ddr_umctl2_gfifo
             
            #(
               .WIDTH           (WRQW),
               .DEPTH           (AXI_PRE_WRQD),
               .ADDR_WIDTH      (AXI_PRE_WRQD_LG2),
               .COUNT_WIDTH     (AXI_PRE_WRQD_LG2+1),
               .OCCAP_EN        (OCCAP_EN),
               .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)               
            ) 
            wrq_1
            (
               .clk             (e_clk),
               .rst_n           (e_rst_n),
               .wr              (wrq1_wr),
               .d               (wrq1_d),
               .rd              (wrq1_rd),
               .par_en          (reg_ddrc_occap_en),
               .init_n          (1'b1),
               .ff              (wrq1_full),
               .wcount          (wrq1_wcount_unused),    
               .q               (wrq1_q),
               .fe              (wrq1_empty),
               .par_err         (occap_xpi_wrq1_err)
              `ifdef SNPS_ASSERT_ON
              `ifndef SYNTHESIS
              ,.disable_sva_fifo_checker_rd (1'b0)
              ,.disable_sva_fifo_checker_wr (1'b0)
              `endif // SYNTHESIS
              `endif // SNPS_ASSERT_ON
            );


            assign wrq_sel          = ~wrq0_empty & ~wptrq_channel ? 2'b01 :
                                      ~wrq1_empty & wptrq_channel  ? 2'b10 : 2'b00;


            assign wptrq_bresp      = wrq_sel[1] ? wrq1_q : wrq0_q;
            assign hif_bvalid       = |wrq_sel & wptrq_awlast;

            assign xpi_bready_dca   = ~wrq0_full;
            assign xpi_bready_dcb   = ~wrq1_full;

            assign {wptrq_bid,wptrq_exa_bresp,wptrq_slverr,wptrq_buser} = wptrq_bresp;

            assign xpi_bresp = {wptrq_bid,wptrq_exa_bresp,slverr_burst,wptrq_buser};

            assign slverr_valid = wptrq_slverr & wptrq_rd;
            assign slverr_burst = slverr_valid | slverr_burst_r;

            always @(posedge e_clk or negedge e_rst_n) begin
               if (~e_rst_n) begin
                  slverr_burst_r <= 1'b0;
               end
               else begin
                  if (wptrq_rd & wptrq_awlast) slverr_burst_r <= 1'b0;
                  else slverr_burst_r <= slverr_burst;
               end
            end


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  // Cover points to observe WPTRQ FIFO full conditions
  cp_wptrq_fifo_full_reached :
    cover property ( @(posedge e_clk) disable iff(!e_rst_n)
       (wptrq_wcount_unused==AXI_WPTRQD)
    );
  cp_wptrq_wr_when_fifo_full_minus_1:
    cover property ( @(posedge e_clk) disable iff(!e_rst_n)
       (wptrq_wcount_unused==AXI_WPTRQD-1) && wptrq_wr
    );
  cp_wptrq_wr_when_fifo_full_minus_2:
    cover property ( @(posedge e_clk) disable iff(!e_rst_n)
       (wptrq_wcount_unused==AXI_WPTRQD-2) && wptrq_wr
    );
  cp_wptrq_wr_when_fifo_full_minus_3:
    cover property ( @(posedge e_clk) disable iff(!e_rst_n)
       (wptrq_wcount_unused==AXI_WPTRQD-3) && wptrq_wr
    );
  cp_wptrq_wr_when_fifo_full_minus_4:
    cover property ( @(posedge e_clk) disable iff(!e_rst_n)
       (wptrq_wcount_unused==AXI_WPTRQD-4) && wptrq_wr
    );
  //Write to WPTRQ when FIFO pointer is reached 2*(CAM depth+2+IH_TE_PIPELINE)
  cp_wptrq_wr_when_fifo_full_minus_2x_wrqdepth:
    cover property ( @(posedge e_clk) disable iff(!e_rst_n)
       (wptrq_wcount_unused==AXI_WPTRQD-(2*AXI_PRE_WRQD)) && wptrq_wr
    );
  
  assert_never #(0, 0, "WPTRQ written when full", 5) a_xpi_wptrq_wr_when_full (aclk, aresetn, (wptrq_wr && wptrq_full));
  assert_never #(0, 0, "WPTRQ both valid high at the same time", 5) a_xpi_wptrq_wr_both_high (aclk, aresetn, (wcmd_dca_out && wcmd_dcb_out));
  assert_never #(0, 0, "WRQ0 written when full", 5) a_xpi_wrq0_wr_when_full (aclk, aresetn, (wrq0_wr && wrq0_full));
  assert_never #(0, 0, "WRQ1 written when full", 5) a_xpi_wrq1_wr_when_full (aclk, aresetn, (wrq1_wr && wrq1_full));
  assert_never #(0, 0, "Both WRQ read at the same time", 5) a_xpi_wrq_read_both (aclk, aresetn, (wrq0_rd && wrq1_rd));
  assert_never #(0, 0, "Both Arbiters granted write request", 5) a_xpi_awready_both_high (aclk, aresetn, (hif_awready_dcb && hif_awready_dca));
  assert_never #(0, 0, "Both Arbiters granted blue read queue", 5) a_xpi_arready_blue_both_high (aclk, aresetn, (hif_arready_blue_dcb && hif_arready_blue_dca));
  assert_never #(0, 0, "Both Arbiters granted red read queue", 5) a_xpi_arready_red_both_high (aclk, aresetn, (hif_arready_red_dcb && hif_arready_red_dca));

`endif
`endif
         end // !if (DATA_CHANNEL_INTERLEAVE==0)
      end // if (DUAL_CHANNEL==1)
      else begin: SINGLE_dch
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block 
            
            // Single channel, tie dcb outputs to 0
            assign xpi_arvalid_l_blue_dca  = xpi_arvalid_l_blue;
            assign xpi_arvalid_l_red_dca   = xpi_arvalid_l_red;
           
            assign xpi_arvalid_l_blue_dcb  = 1'b0;
            assign xpi_arvalid_l_red_dcb   = 1'b0;

            assign gen_token_dca        = gen_token_blue_dca | gen_token_red_dca;
            assign gen_token_dcb        = 1'b0;
            assign gen_token_blue_dca   = xpi_arvalid_blue_dca & hif_arready_l_blue_dca;
            assign gen_token_blue_dca_i = gen_token_blue_dca;
            assign gen_token_red_dca_i  = gen_token_red_dca;
            assign gen_token_red_dca    = xpi_arvalid_red_dca & hif_arready_l_red_dca;
            assign gen_token_blue_dcb   = 1'b0;
            assign gen_token_red_dcb    = 1'b0;

            assign hif_arready_l_blue_dca  = hif_arready_blue_dca & ~tm_empty_blue_dca;
            assign hif_arready_l_red_dca   = hif_arready_red_dca & ~tm_empty_red_dca;
            assign xpi_arvalid_blue_dca    = xpi_arvalid_l_blue_dca & ~tm_empty_blue_dca;
            assign xpi_arvalid_red_dca     = xpi_arvalid_l_red_dca & ~tm_empty_red_dca;

            assign xpi_araddr_blue        = xpi_araddr_blue_i;
            assign xpi_rexa_pyld_blue     = xpi_rexa_pyld_blue_i;
            assign xpi_arqos_blue         = xpi_arqos_blue_i;
            assign xpi_rqos_priority_blue = xpi_rqos_priority_blue_i;
            assign xpi_rqos_timeout_blue  = xpi_rqos_timeout_blue_i;
            assign xpi_vpr_expired_blue   = xpi_vpr_expired_blue_i;
            assign xpi_arpagematch_blue   = xpi_arpagematch_blue_i;
            assign xpi_arautopre_blue     = xpi_arautopre_blue_i;
            assign xpi_araddr_red         = xpi_araddr_red_i;
            assign xpi_rexa_pyld_red      = xpi_rexa_pyld_red_i;
            assign xpi_arqos_red          = xpi_arqos_red_i;
            assign xpi_rqos_priority_red  = xpi_rqos_priority_red_i;
            assign xpi_rqos_timeout_red   = xpi_rqos_timeout_red_i;
            assign xpi_vpr_expired_red    = xpi_vpr_expired_red_i;
            assign xpi_arpagematch_red    = xpi_arpagematch_red_i;
            assign xpi_arautopre_red      = xpi_arautopre_red_i;

            assign xpi_read_bypass_reorder_blue = xpi_read_bypass_reorder_blue_i;
            assign xpi_rd_arinfo_blue           = xpi_rd_arinfo_blue_i;
            assign abeat_info_blue              = abeat_info_blue_i;
            assign e_rexa_acc_blue              = e_rexa_acc_blue_i;
            assign e_rexa_acc_instr_blue        = e_rexa_acc_instr_blue_i;
            assign e_rpoison_blue               = e_rpoison_blue_i;
            assign e_ocpar_err_blue             = e_ocpar_err_blue_i;
            assign xpi_rd_arlast_blue           = xpi_rd_arlast_blue_i;
            assign xpi_rd_arid_blue             = xpi_rd_arid_blue_i;
            assign xpi_read_bypass_reorder_red  = xpi_read_bypass_reorder_red_i;
            assign xpi_rd_arinfo_red            = xpi_rd_arinfo_red_i;
            assign abeat_info_red               = abeat_info_red_i;
            assign e_rexa_acc_red               = e_rexa_acc_red_i;
            assign e_rexa_acc_instr_red         = e_rexa_acc_instr_red_i;
            assign e_rpoison_red                = e_rpoison_red_i;
            assign e_ocpar_err_red              = e_ocpar_err_red_i;
            assign xpi_rd_arlast_red            = xpi_rd_arlast_red_i;
            assign xpi_rd_arid_red              = xpi_rd_arid_red_i;
            assign e_user_blue                  = e_user_blue_i;
            assign e_user_red                   = e_user_red_i;
            assign bam_addr_offset_red          = bam_addr_offset_red_i;
            assign hif_hif_rdata_dca_i          = hif_hif_rdata_dca;
            assign hif_hif_rdata_parity_dca_i   = hif_hif_rdata_parity_dca;
            assign hif_rerror_dca_i             = hif_rerror_dca;
            assign hif_rlast_pkt_dca_i_unused   = hif_rlast_pkt_dca;
            assign hif_rvalid_dca_i             = hif_rvalid_dca;
            assign e_resp_token_dca_i           = e_resp_token_dca;

            // inline ECC related signals
            assign xpi_awvalid_iecc             = xpi_awvalid_iecc_i;
            assign xpi_awlast_iecc              = xpi_awlast_iecc_i;
            assign xpi_awvalid_iecc_dcb         = 1'b0;
            assign xpi_awlast_iecc_dcb          = 1'b0;
            assign xpi_arvalid_iecc_blue        = xpi_rd_iecc_blk_valid_blue;
            assign xpi_arlast_iecc_blue         = xpi_rd_iecc_blk_end_blue;
            assign xpi_arvalid_iecc_blue_dcb    = 1'b0;
            assign xpi_arlast_iecc_blue_dcb     = 1'b0;
            assign xpi_arvalid_iecc_red         = xpi_rd_iecc_blk_valid_red;
            assign xpi_arlast_iecc_red          = xpi_rd_iecc_blk_end_red;
            assign xpi_arvalid_iecc_red_dcb     = 1'b0;
            assign xpi_arlast_iecc_red_dcb      = 1'b0;

            assign hif_arready_l_blue_dcb  = 1'b0;
            assign hif_arready_l_red_dcb   = 1'b0;
//spyglass enable_block W528
            assign xpi_arvalid_blue_dcb    = 1'b0;
            assign xpi_arvalid_red_dcb     = 1'b0;

            assign xpi_araddr_blue_dcb          = {M_ADDRW{1'b0}};
            assign xpi_arqos_blue_dcb           = {AXI_QOSW{1'b0}};
            assign xpi_rqos_priority_blue_dcb   = {RQOS_RW{1'b0}};
            assign xpi_rqos_timeout_blue_dcb    = {RQOS_TW{1'b0}};
            assign xpi_vpr_expired_blue_dcb     = 1'b0;
            assign xpi_arpagematch_blue_dcb     = 1'b0;
            assign xpi_arautopre_blue_dcb       = 1'b0;
            assign xpi_rexa_pyld_blue_dcb       = {EXA_PYLD_W{1'b0}};

            assign xpi_read_bypass_reorder_blue_dcb   = 1'b0;
            assign xpi_rd_arinfo_blue_dcb             = {RINFOW{1'b0}};
            assign abeat_info_blue_dcb                = {BEAT_INFOW{1'b0}};
            assign e_rexa_acc_blue_dcb                = 1'b0;
            assign e_rexa_acc_instr_blue_dcb          = 1'b0;
            assign e_rpoison_blue_dcb                 = 1'b0;
            assign e_ocpar_err_blue_dcb               = 1'b0;
            assign xpi_rd_arlast_blue_dcb             = 1'b0;
            assign xpi_rd_arid_blue_dcb               = {AXI_IDW{1'b0}};
            assign xpi_read_bypass_reorder_red_dcb = 1'b0;
            assign xpi_rd_arinfo_red_dcb        = {RINFOW{1'b0}};
            assign abeat_info_red_dcb           = {BEAT_INFOW{1'b0}};
            assign xpi_rexa_pyld_red_dcb        = {EXA_PYLD_W{1'b0}};
            assign e_rexa_acc_red_dcb           = 1'b0;
            assign e_rexa_acc_instr_red_dcb     = 1'b0;
            assign e_rpoison_red_dcb            = 1'b0;
            assign e_ocpar_err_red_dcb          = 1'b0;
            assign xpi_rd_arlast_red_dcb        = 1'b0;
            assign xpi_rd_arid_red_dcb          = {AXI_IDW{1'b0}};
            assign xpi_araddr_red_dcb           = {M_ADDRW{1'b0}};
            assign xpi_arqos_red_dcb            = {AXI_QOSW{1'b0}};
            assign xpi_rqos_priority_red_dcb    = {RQOS_RW{1'b0}};
            assign xpi_rqos_timeout_red_dcb     = {RQOS_TW{1'b0}};
            assign xpi_vpr_expired_red_dcb      = 1'b0;
            assign xpi_arpagematch_red_dcb      = 1'b0;
            assign xpi_arautopre_red_dcb        = 1'b0;
            assign e_user_blue_dcb              = {AXI_USERW{1'b0}};
            assign e_user_red_dcb               = {AXI_USERW{1'b0}};

            assign xpi_awvalid_dca              = xpi_awvalid;
            assign xpi_wvalid_dca               = xpi_wvalid;

            assign xpi_bresp                    = xpi_bresp_dca;
            assign hif_bvalid                   = hif_bvalid_dca;
            assign xpi_bready_dca               = xpi_bready;

            // second channel tied to 0
            assign xpi_wvalid_dcb         = 1'b0;
            assign xpi_awvalid_dcb        = 1'b0;

            assign hif_awready            = hif_awready_dca;
            assign hif_arready_l_blue     = hif_arready_l_blue_dca;
            assign hif_arready_l_red      = hif_arready_l_red_dca;
            assign hif_wready             = hif_wready_dca;

            assign xpi_wdata              = xpi_wdata_i[A_DW-1:0];
            assign xpi_wstrb              = xpi_wstrb_i[A_STRBW-1:0];
            assign xpi_wlast              = xpi_wlast_i;
            assign xpi_wlast_pkt          = xpi_wlast_pkt_i;
            assign xpi_snf_mode           = xpi_snf_mode_i;
            assign xpi_wpar_err           = xpi_wpar_err_i[A_STRBW-1:0];
            assign xpi_wparity            = xpi_wparity_i[A_PARW-1:0];
            assign xpi_wdata_dcb          = {A_DW{1'b0}};
            assign xpi_wstrb_dcb          = {A_STRBW{1'b0}};
            assign xpi_wlast_dcb          = 1'b0;
            assign xpi_wlast_pkt_dcb      = 1'b0;
            assign xpi_snf_mode_dcb       = 1'b0;
            assign xpi_wpar_err_dcb       = {A_STRBW{1'b0}};
            assign xpi_wparity_dcb        = {A_STRBW{1'b0}};

            assign xpi_wexa_acc_dca       = xpi_wexa_acc;
            assign xpi_wexa_acc_dcb       = 1'b0;
            assign xpi_wexa_acc_lock_dca  = xpi_wexa_acc_lock;
            assign xpi_wexa_acc_lock_dcb  = 1'b0;
            assign xpi_awid_dca           = xpi_awid;
            assign xpi_awid_dcb           = {AXI_IDW{1'b0}};
            assign xpi_wpoison_dca        = xpi_wpoison;
            assign xpi_wpoison_dcb        = 1'b0;
            assign xpi_ocpar_err_dca      = xpi_ocpar_err;
            assign xpi_ocpar_err_dcb      = 1'b0;
            assign xpi_wexa_pyld          = xpi_wexa_pyld_i;
            assign xpi_wexa_pyld_dcb      = {EXA_PYLD_W{1'b0}};
            assign xpi_awuser_dca         = xpi_awuser_i;
            assign xpi_awuser_dcb         = {AXI_USERW{1'b0}};

            assign xpi_awaddr                = xpi_awaddr_i; 
            assign xpi_awrmw                 = xpi_awrmw_i; 
            assign xpi_awqos                 = xpi_awqos_i;
            assign xpi_awpagematch           = xpi_awpagematch_i; 
            assign xpi_awautopre             = xpi_awautopre_i;
            assign xpi_exa_awlast            = xpi_exa_awlast_i;
            assign xpi_exa_short_burst       = xpi_exa_short_burst_i;
            assign xpi_wqos_priority         = xpi_wqos_priority_i;
            assign xpi_wqos_timeout          = xpi_wqos_timeout_i;
            assign xpi_vpw_expired           = xpi_vpw_expired_i;
            assign xpi_awaddr_dcb            = {M_ADDRW{1'b0}}; 
            assign xpi_awrmw_dcb             = 1'b0; 
            assign xpi_awqos_dcb             = {AXI_QOSW{1'b0}};
            assign xpi_awpagematch_dcb       = 1'b0; 
            assign xpi_awautopre_dcb         = 1'b0;
            assign xpi_exa_awlast_dcb        = 1'b0;
            assign xpi_exa_short_burst_dcb   = 1'b0;
            assign xpi_wqos_priority_dcb     = {WQOS_RW{1'b0}};
            assign xpi_wqos_timeout_dcb      = {WQOS_TW{1'b0}};
            assign xpi_vpw_expired_dcb       = 1'b0;
            assign xpi_wdata_mask_full       = xpi_wdata_mask_full_i;
            assign xpi_wdata_mask_full_dcb   = {NBEATS{1'b0}};

            assign xpi_bready_dcb            = 1'b0;

            assign dch_sel_dcm               = 1'b0;

            assign occap_dca_wr_par_err = 1'b0;
            assign occap_dcb_wr_par_err = 1'b0;
            assign occap_xpi_dch_rd_rar_err     = 1'b0;
            assign occap_xpi_dch_wr_rar_err     = 1'b0;

            assign occap_xpi_wptrq_err = 1'b0;
            assign occap_xpi_wrq0_err  = 1'b0;
            assign occap_xpi_wrq1_err  = 1'b0;


      end // !if (DUAL_CHANNEL==1)
   endgenerate

  // write response packing
  assign xpi_bresp_dca = {xpi_bid_dca,e_exa_bresp_dca,e_aw_slverr_dca,xpi_buser_dca};
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
  assign xpi_bresp_dcb = {xpi_bid_dcb,e_exa_bresp_dcb,e_aw_slverr_dcb,xpi_buser_dcb};
//spyglass enable_block W528

  // occap outputs assign
  assign occap_xpi_rrb_par_err   = occap_xpi_rrb_par_err_dca | occap_xpi_rrb_par_err_dcb | occap_xpi_dcr_par_err;
  assign occap_dch_par_err       = occap_dca_rd_par_err | occap_dcb_rd_par_err | occap_dca_wr_par_err | occap_dcb_wr_par_err | occap_xpi_dch_rd_rar_err | occap_xpi_dch_wr_rar_err;
  assign occap_xpi_tm_par_err    = occap_xpi_tm_dca_par_err | occap_xpi_tm_dcb_par_err;
   // core clock parity error
  assign cc_parity_err           = occap_xpi_rrb_par_err | occap_xpi_read_c_par_err | occap_dch_par_err | occap_xpi_rmw_par_err | occap_xpi_write_c_par_err | occap_xpi_sync_info_par_err | occap_xpi_sync_info_dcb_par_err | occap_xpi_rdr_data_par_err | occap_xpi_rdr_info_par_err | occap_xpi_dcm_par_err | occap_xpi_tm_par_err | occap_xpi_rdwr_post_arb_par_err | occap_xpi_wptrq_err | occap_xpi_wrq0_err | occap_xpi_wrq1_err;
  assign aa_parity_err           = occap_xpi_read_a_par_err | occap_xpi_write_a_par_err | occap_urgent_par_err | occap_busy_par_err |  occap_xpi_rdwr_pre_arb_par_err | occap_xpi_lpfsm_par_err;
   // aclk comparator error
  assign ac_cmp_err              = occap_xpi_write_a_cmp_err | occap_xpi_read_a_cmp_err;
   // core clock comparator error
  assign cc_cmp_err              = occap_xpi_write_c_cmp_err | occap_xpi_read_c_cmp_err;

  // ocecc output assign
  //assign ocecc_uncorr_err        = ocecc_xpi_write_uncorr_err | ocecc_xpi_read_uncorr_err;
  //assign ocecc_corr_err          = ocecc_xpi_write_corr_err | ocecc_xpi_read_corr_err;
  


  generate
   if (OCCAP_EN==1) begin: POISON_complete_gen

      genvar n;

      reg [C_CMP_P-1:0] c_cmp_poison_complete, c_cmp_poison_seq, c_cmp_poison_full;
      reg [A_CMP_P-1:0] a_cmp_poison_complete, a_cmp_poison_seq, a_cmp_poison_full;
      wire [C_CMP_P-1:0] c_cmp_poison_complete_w, c_cmp_poison_seq_w, c_cmp_poison_full_w;
      wire [A_CMP_P-1:0] a_cmp_poison_complete_w, a_cmp_poison_seq_w, a_cmp_poison_full_w;
      wire c_cmp_poison, a_cmp_poison;
      reg c_cmp_poison_r, a_cmp_poison_r;
      wire c_cmp_pulse, a_cmp_pulse;

      assign c_cmp_poison = &c_cmp_poison_complete; // all core clock comparators finished
      assign a_cmp_poison = &a_cmp_poison_complete; // all aclk comparators finished

      assign c_cmp_poison_complete_w   = {occap_xpi_write_c_cmp_poison_complete,occap_xpi_read_c_cmp_poison_complete}; // collect core clock comparators in a vector, this is a collection of pulses
      assign c_cmp_poison_full_w       = {occap_xpi_write_c_cmp_err_full,occap_xpi_read_c_cmp_err_full};
      assign c_cmp_poison_seq_w        = {occap_xpi_write_c_cmp_err_seq,occap_xpi_read_c_cmp_err_seq};

      assign a_cmp_poison_complete_w   = {occap_xpi_write_a_cmp_poison_complete,occap_xpi_read_a_cmp_poison_complete}; // collect aclk comparators in a vector, this is a collection of pulses
      assign a_cmp_poison_full_w       = {occap_xpi_write_a_cmp_err_full,occap_xpi_read_a_cmp_err_full};
      assign a_cmp_poison_seq_w        = {occap_xpi_write_a_cmp_err_seq,occap_xpi_read_a_cmp_err_seq};

      for (n=0; n<A_CMP_P; n=n+1) begin: A_complete
         
// spyglass disable_block FlopEConst
// SMD: Enable pin EN on Flop DWC_ddrctl.U_xpi_$.\POISON_complete_gen.a_cmp_poison_complete [n] (master RTL_FDCE) is  always enabled (tied high)(connected to DWC_ddrctl.U_xpi_$.\POISON_complete_gen.a_cmp_poison_complete_w [n])
// SJ: if `UMCTL2_XPI_USE2RAQ_$ is 0, the red queue signal is always 1, if not upsize, au signal is always 1        
         always @(posedge aclk or negedge aresetn) begin: ACLK_cmp
            if (~aresetn) begin
               a_cmp_poison_complete[n]   <= 1'b0;
               a_cmp_poison_full[n]       <= 1'b0;
               a_cmp_poison_seq[n]        <= 1'b0;
            end
            else begin
               if (a_cmp_pulse) begin
                  a_cmp_poison_complete[n]   <= 1'b0; // clear all bits when all of them are 1 -> all FSM finished the poison loop
                  a_cmp_poison_full[n]       <= 1'b0;
                  a_cmp_poison_seq[n]        <= 1'b0;
               end
               else if (a_cmp_poison_complete_w[n]) begin
                  a_cmp_poison_complete[n]   <= 1'b1; // hold the bit when pulse is received
                  a_cmp_poison_full[n]       <= a_cmp_poison_full_w[n];
                  a_cmp_poison_seq[n]        <= a_cmp_poison_seq_w[n];
               end
            end
         end
// spyglass enable_block FlopEConst
      end

      always @(posedge aclk or negedge aresetn) begin
         if (~aresetn) begin
            a_cmp_poison_r <= 1'b0;
         end
         else begin
            a_cmp_poison_r <= a_cmp_poison;
         end
      end

      assign a_cmp_pulse = a_cmp_poison & ~a_cmp_poison_r; // generate aclk pulse
      

      for (n=0; n<C_CMP_P; n=n+1) begin: C_complete
// spyglass disable_block FlopEConst
// SMD: Enable pin EN on Flop DWC_ddrctl.U_xpi_$.\POISON_complete_gen.c_cmp_poison_complete [n] (master RTL_FDCE) is  always enabled (tied high)(connected to DWC_ddrctl.U_xpi_$.\POISON_complete_gen.c_cmp_poison_complete_w [n])
// SJ: if `UMCTL2_XPI_USE2RAQ_$ is 0, the red queue signal is always 1, if not upsize, au signal is always 1
         always @(posedge e_clk or negedge e_rst_n) begin: CCLK_cmp
            if (~e_rst_n) begin
               c_cmp_poison_complete[n]   <= 1'b0;
               c_cmp_poison_full[n]       <= 1'b0;
               c_cmp_poison_seq[n]        <= 1'b0;
            end
            else begin
               if (c_cmp_pulse) begin
                  c_cmp_poison_complete[n]   <= 1'b0; // clear all bits when all of them are 1 -> all FSM finished the poison loop
                  c_cmp_poison_full[n]       <= 1'b0;
                  c_cmp_poison_seq[n]        <= 1'b0;
               end
               else if (c_cmp_poison_complete_w[n]) begin
                  c_cmp_poison_complete[n]   <= 1'b1; // hold the bit when pulse is received
                  c_cmp_poison_full[n]       <= c_cmp_poison_full_w[n];
                  c_cmp_poison_seq[n]        <= c_cmp_poison_seq_w[n];
               end
            end
         end
// spyglass enable_block FlopEConst
      end

      always @(posedge e_clk or negedge e_rst_n) begin
         if (~e_rst_n) begin
            c_cmp_poison_r <= 1'b0;
         end
         else begin
            c_cmp_poison_r <= c_cmp_poison;
         end
      end

      assign c_cmp_pulse = c_cmp_poison & ~c_cmp_poison_r; // generate core clock pulse


      assign ac_cmp_poison_complete = a_cmp_pulse; // send a pulse when all comparators have finished
      assign cc_cmp_poison_complete = c_cmp_pulse; // send a pulse when all comparators have finished

      assign cc_cmp_err_full         = |c_cmp_poison_full;
      assign cc_cmp_err_seq          = |c_cmp_poison_seq;
      assign ac_cmp_err_full         = |a_cmp_poison_full;
      assign ac_cmp_err_seq          = |a_cmp_poison_seq;

   end
   else begin: OCCAP_dis
      assign ac_cmp_poison_complete    = 1'b0; 
      assign cc_cmp_poison_complete    = 1'b0;
      assign cc_cmp_err_full           = 1'b0;
      assign cc_cmp_err_seq            = 1'b0;
      assign ac_cmp_err_full           = 1'b0;
      assign ac_cmp_err_seq            = 1'b0;
   end
  endgenerate

  // XPI software ecc mode enable, driven from reg_ddrc_ecc_mode.
  // xpi_rmw is passthrough if xpi_ecc_mode=1'b0
  generate
    if (M_ECC>0) begin: ecc_mode_enabled
      assign reg_xpi_ecc_mode_ie    = (reg_ddrc_ecc_mode==3'b100 || reg_ddrc_ecc_mode==3'b101) ?  reg_ddrc_ecc_type : 1'b0;
      assign reg_xpi_ecc_mode_nonie = (reg_ddrc_ecc_mode==3'b100 || reg_ddrc_ecc_mode==3'b101) ? ~reg_ddrc_ecc_type : 1'b0;
    end
    else begin: ecc_mode_disabled
      assign reg_xpi_ecc_mode_ie    = 1'b0;      
      assign reg_xpi_ecc_mode_nonie = 1'b0;      
    end
  endgenerate
  
  // RMW mode enable, xpi_rmw is passthrough if xpi_rmw_mode=1'b0

  assign reg_xpi_dm_dis   = (reg_ddrc_ddr5 | reg_ddrc_ddr4 | reg_ddrc_lpddr4 | reg_ddrc_lpddr5) & ~reg_ddrc_dm_enb;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
  assign reg_xpi_rmw_mode_ie    = reg_xpi_ecc_mode_ie    | ( reg_ddrc_ecc_type & reg_xpi_dm_dis);
  assign reg_xpi_rmw_mode_nonie = reg_xpi_ecc_mode_nonie | (~reg_ddrc_ecc_type & reg_xpi_dm_dis);
//spyglass enable_block W528
  
  // Port number of this XPI instantiation

  assign port_num            = A_PORT_NUM;
 
   // short_write used to generate RMW if dm_dis=1
   generate
    if (MEMC_BURST_LENGTH==16) begin: memc_bl16
      wire siu_bl8or4; // internal XPI burst length is 8 or 4

      assign siu_bl8or4 = siu_bl8 | siu_bl4;

      // short write logic always enabled if
      // MEMC_BL=16 | FBW | BL16
      assign reg_xpi_short_write_dis            = (ddrc_bl16 & (~reg_ddrc_burstchop)) ? 1'b0 : 1'b1;

      // in all the other cases
      // FR1
      // MEMC_BL=16 | QBW | BL8
      // MEMC_BL=16 | HBW | BL4
      // MEMC_BL=16 | QBW | BL4
      assign reg_xpi_short_write_dis_bl16_nab1  = (ddrc_qbw & (ddrc_bl8 | ddrc_bl4))   ? 1'b1 : 
                                                  (ddrc_hbw & ddrc_bl4)                ? 1'b1 :
                                                                                         1'b0;

      // MEMC_BL=16 | QBW | BL16
      assign reg_xpi_short_write_dis_bl16_qbw_nab1 = (ddrc_qbw & ddrc_bl16) ? 1'b1 : 1'b0;
      
      // MEMC_BL=16 | HBW | BL8
      assign reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1 = (ddrc_hbw & ddrc_bl8) ? 1'b1 : 1'b0;

      // MEMC_BL=16 | HBW | BL16
      assign reg_xpi_short_write_dis_bl16_hbw = (ddrc_hbw & ddrc_bl16) ? 1'b1 : 1'b0;

      // MEMC_BL=16 | FBW | BL8
      // MEMC_BL=16 | FBW | BL4
      assign reg_xpi_short_write_dis_bl16_fbw_nab1 = (ddrc_fbw & (ddrc_bl8 | ddrc_bl4)) ? 1'b1 : 1'b0;

      // MEMC_BL=16 | FBW | BL4
      assign reg_xpi_short_write_dis_mbl16_bl4_nab1 = (ddrc_fbw & ddrc_bl4) ? 1'b1 : 1'b0;

      // MEMC_BL=16 | FBW | BL8 | BC_wr enabled
      assign reg_xpi_short_write_dis_mbl16_bl8_bc_fbw  = (ddrc_fbw & ddrc_bl8 & (reg_ddrc_burstchop & ~reg_ddrc_wr_crc_enable)) ? 1'b1 : 1'b0;
      
      // MEMC_BL=16 | HBW | BL8 | BC_wr enabled
      assign reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1  = (ddrc_hbw & ddrc_bl8 & (reg_ddrc_burstchop & ~reg_ddrc_wr_crc_enable)) ? 1'b1 : 1'b0;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block (Only if USE_RMW=1)
      assign reg_mbl16_bl8_bc_crc_dis_nab3 = ddrc_bl8 & (reg_ddrc_burstchop & ~reg_ddrc_wr_crc_enable) & (NAB==3);
//spyglass enable_block W528

      // FR2
      // disable short write logic if
      // MEMC_BL=16 | QBW | BL16
      assign reg_xpi_short_write_dis_bl16_nab2  = (ddrc_qbw & ddrc_bl16) ? 1'b1 : 1'b0;

      // disable short write logic if
      // MEMC_BL=16 | FBW | BL8
      assign reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2  = (ddrc_fbw & ddrc_bl8) ? 1'b1 : 1'b0; 

      // disable short write logic if
      // MEMC_BL=16 | HBW | BL8
      // MEMC_BL=16 | QBW | BL8
      assign reg_xpi_short_write_dis_mbl16_bl8_nab2   = (ddrc_hbw & ddrc_bl8) ? 1'b1 :
                                                        (ddrc_qbw & ddrc_bl8) ? 1'b1 : 1'b0;

      // disable short write logic if
      // MEMC_BL=16 | XXX | BL4
      assign reg_xpi_short_write_dis_mbl16_bl4_nab2   = ddrc_bl4;

      assign reg_xpi_short_write_dis_bl8_nab1_1or3beats  = 1'b0;
      assign reg_xpi_short_write_dis_bl8_nab1            = 1'b0;

      // If reg_arb_bl_exp_mode is set, burst length depends also on data_bus_width
      assign burst_rdwr_bus_width = (~reg_arb_bl_exp_mode | ddrc_fbw | (PDBW_CASE !=0)) ? reg_ddrc_burst_rdwr : 
                                                            ddrc_bl16 ? BL8 : BL4;

      // if BL16 controller, maximum value for burst_rdwr is BL16, no need for checks
      assign reg_xpi_burst_rdwr = burst_rdwr_bus_width;

      // partial read bit if programmed BL is less than MEMC_BURST_LENGTH
      assign xpi_rxcmd_rlength_blue    = {siu_bl8or4,siu_bl4};

      assign xpi_rxcmd_rlength_red     = {siu_bl8or4,siu_bl4};

    end else if (MEMC_BURST_LENGTH==8)  begin: memc_bl8
      // short_write logic is disabled always except for following:
      // MEMC_BL=8 | FBW | BL8  | BC_wr disabled
      // MEMC_BL=8 | HBW | BL16 | x
      //
      assign reg_xpi_short_write_dis   = (ddrc_fbw & ddrc_bl8 & (~reg_ddrc_burstchop | reg_ddrc_wr_crc_enable))   ? 1'b0 : 
                                         (ddrc_hbw & ddrc_bl16)                                                ? 1'b0 :               
                                                                                                                 1'b1 ;
      // short_write logic specific for MEMC_BURST_LENGTH=8 and DFI 1:1
      // (NAB=1) is disabled only for following:
      // MEMC_BL=8 | FBW | BL2 - this is not supported by XPI
      // MEMC_BL=8 | HBW | BL4
      // MEMC_BL=8 | QBW | BL8
      assign reg_xpi_short_write_dis_bl8_nab1 = (ddrc_hbw & ddrc_bl4) ? 1'b1 :
                                                (ddrc_qbw & ddrc_bl8) ? 1'b1 : 1'b0;

      //short_write logic specific for MEMC_BURST_LENGTH=8 and DFI 1:1 if
      //3 beats counted
      // (NAB=1) is disabled only for following:
      // MEMC_BL=8 | HBW | BL8 | BC_wr enabled
      assign reg_xpi_short_write_dis_bl8_nab1_1or3beats = (ddrc_hbw & ddrc_bl8 & (reg_ddrc_burstchop & ~reg_ddrc_wr_crc_enable)) ? 1'b1 : 1'b0;

      // always 0 for  MEMC_BURST_LENGTH=8
      assign reg_xpi_short_write_dis_bl16_nab1                    = 1'b0;
      assign reg_xpi_short_write_dis_bl16_nab2                    = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_nab2               = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2   = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl4_nab2               = 1'b0;
      assign reg_xpi_short_write_dis_bl16_qbw_nab1                = 1'b0;
      assign reg_xpi_short_write_dis_bl16_hbw                     = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1           = 1'b0;
      assign reg_xpi_short_write_dis_bl16_fbw_nab1                = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl4_nab1               = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_bc_fbw             = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1        = 1'b0;
      assign reg_mbl16_bl8_bc_crc_dis_nab3                        = 1'b0;

      // If reg_arb_bl_exp_mode is set, burst length depends also on data_bus_width
      assign burst_rdwr_bus_width = (~reg_arb_bl_exp_mode | ddrc_fbw) ? reg_ddrc_burst_rdwr : BL4;

      // if BL8 controller and burst_rdwr is greater than BL8 set burst_rdwr to BL8
      assign reg_xpi_burst_rdwr = (burst_rdwr_bus_width==BL16) ? BL8 : burst_rdwr_bus_width;

      // partial read bit if programmed BL is less than MEMC_BURST_LENGTH
      assign xpi_rxcmd_rlength_blue    = siu_bl4;

      assign xpi_rxcmd_rlength_red     = siu_bl4;

    end else if (MEMC_BURST_LENGTH==4)  begin: memc_bl4
      // short_write logic is disabled always except for following:
      // MEMC_BL=4 | FBW | BL4  | x
      // MEMC_BL=4 | HBW | BL8  | BC_wr disabled
      // MEMC_BL=4 | HBW | BL16 | x
      assign reg_xpi_short_write_dis   = (ddrc_fbw & ddrc_bl4) ? 1'b0 : 
                                         (ddrc_hbw & ddrc_bl8 & (~reg_ddrc_burstchop | reg_ddrc_wr_crc_enable)) ? 1'b0 :                                  
                                         (ddrc_qbw & ddrc_bl16) ? 1'b0 :               
                                                                  1'b1 ;

      // always 0 for  MEMC_BURST_LENGTH=4                                                                                                       
      assign reg_xpi_short_write_dis_bl8_nab1                     = 1'b0;
      assign reg_xpi_short_write_dis_bl8_nab1_1or3beats           = 1'b0;
      assign reg_xpi_short_write_dis_bl16_nab1                    = 1'b0;
      assign reg_xpi_short_write_dis_bl16_nab2                    = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_nab2               = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2   = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl4_nab2               = 1'b0;
      assign reg_xpi_short_write_dis_bl16_qbw_nab1                = 1'b0;
      assign reg_xpi_short_write_dis_bl16_hbw                     = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1           = 1'b0;
      assign reg_xpi_short_write_dis_bl16_fbw_nab1                = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl4_nab1               = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_bc_fbw             = 1'b0;
      assign reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1        = 1'b0;
      assign reg_mbl16_bl8_bc_crc_dis_nab3                        = 1'b0;

      // If reg_arb_bl_exp_mode is set, burst length depends also on data_bus_width
      assign burst_rdwr_bus_width = (~reg_arb_bl_exp_mode | ddrc_fbw) ? reg_ddrc_burst_rdwr : BL2;

      // if BL4 controller and burst_rdwr is greater than BL4 set burst_rdwr to BL4
      assign reg_xpi_burst_rdwr = (burst_rdwr_bus_width==BL8||burst_rdwr_bus_width==BL16) ? BL4 : burst_rdwr_bus_width;

      // partial read bit if programmed BL is less than MEMC_BURST_LENGTH
      assign xpi_rxcmd_rlength_blue    = siu_bl2;

      assign xpi_rxcmd_rlength_red     = siu_bl2;

    end

    if (M_INLINE_ECC==1) begin: IECC_wlen_en
      assign xpi_rxcmd_wlength      = (reg_ddrc_ecc_type) ? xpi_rxcmd_rlength_blue : 0;      
      assign xpi_rxcmd_wlength_dcb  = xpi_rxcmd_wlength;
   end
   else begin: IECC_wlen_dis
      assign xpi_rxcmd_wlength      = 0;      
      assign xpi_rxcmd_wlength_dcb  = xpi_rxcmd_wlength;
   end

  endgenerate
    
  
  assign siu_bl16    = reg_xpi_burst_rdwr == BL16;
  assign siu_bl8     = reg_xpi_burst_rdwr == BL8;
  assign siu_bl4     = reg_xpi_burst_rdwr == BL4;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
  assign siu_bl2     = reg_xpi_burst_rdwr == BL2;
  assign atoken_tmp  = {MEMC_NO_OF_ENTRY_LG2{1'b0}}; // dummy placeholder
//spyglass enable_block W528

  assign ddrc_bl4    = reg_ddrc_burst_rdwr == BL4;
  assign ddrc_bl8    = reg_ddrc_burst_rdwr == BL8;
  assign ddrc_bl16   = reg_ddrc_burst_rdwr == BL16;

  assign ddrc_qbw    = reg_ddrc_data_bus_width == QBW;
  assign ddrc_hbw    = reg_ddrc_data_bus_width == HBW;
  assign ddrc_fbw    = reg_ddrc_data_bus_width == FBW;

  generate
    if (NAB==3)  begin: x8_bl
      assign a_bl = reg_xpi_burst_rdwr[BRW-1:2];
    end
    if (NAB==2)  begin: x4_bl
      assign a_bl = reg_xpi_burst_rdwr[BRW-1:1];
    end
    if (NAB==1)  begin: x2_bl
      assign a_bl = reg_xpi_burst_rdwr[BRW-1:0];
    end
  endgenerate

 
// Fixed Fields are placed at the right of the Token, dynamic fields placed at the left.
  assign xpi_rxcmd_token_blue       = {xpi_read_bypass_reorder_blue,xpi_rd_arinfo_blue,atoken_dca,abeat_info_blue,e_rexa_acc_blue,e_rexa_acc_instr_blue,e_rpoison_blue,e_ocpar_err_blue,e_user_blue,BLUE_QUEUE,xpi_arvalid_iecc_blue,xpi_arlast_iecc_blue,xpi_rd_arlast_blue,xpi_rd_arid_blue,port_num}; // xpi_arvalid_iecc_blue and xpi_arlast_iecc_blue are required to be at the MSB. If changing this, update assignement in hif_cmd accordingly
  assign xpi_rxcmd_token_blue_dcb   = {xpi_read_bypass_reorder_blue_dcb,xpi_rd_arinfo_blue_dcb,atoken_dcb,abeat_info_blue_dcb,e_rexa_acc_blue_dcb,e_rexa_acc_instr_blue_dcb,e_rpoison_blue_dcb,e_ocpar_err_blue_dcb,e_user_blue_dcb,BLUE_QUEUE,xpi_arvalid_iecc_blue_dcb,xpi_arlast_iecc_blue_dcb,xpi_rd_arlast_blue_dcb,xpi_rd_arid_blue_dcb,port_num}; // same as above
  assign xpi_rxcmd_token_red        = {xpi_read_bypass_reorder_red,xpi_rd_arinfo_red,atoken,abeat_info_red,e_rexa_acc_red,e_rexa_acc_instr_red,e_rpoison_red,e_ocpar_err_red,e_user_red,RED_QUEUE,xpi_arvalid_iecc_red,xpi_arlast_iecc_red,xpi_rd_arlast_red,xpi_rd_arid_red,port_num}; // same as above
  assign xpi_rxcmd_token_red_dcb    = {xpi_read_bypass_reorder_red_dcb,xpi_rd_arinfo_red_dcb,atoken_dcb,abeat_info_red_dcb,e_rexa_acc_red_dcb,e_rexa_acc_instr_red_dcb,e_rpoison_red_dcb,e_ocpar_err_red_dcb,e_user_red_dcb,RED_QUEUE,xpi_arvalid_iecc_red_dcb,xpi_arlast_iecc_red_dcb,xpi_rd_arlast_red_dcb,xpi_rd_arid_red_dcb,port_num}; // same as above

`SNPS_UNR_CONSTANT("If AXI_USER_WIDTH is 0 in config, dummy signal is used internally", 1, e_resp_ruser_dca[0], 1'b0)
`SNPS_UNR_CONSTANT("If AXI_USER_WIDTH is 0 in config, dummy signal is used internally", 1, xpi_awuser_dca[0], 1'b0)

//spyglass disable_block W528
//SMD: Variable hif_bypass_reorder_dc* set but not read
//SJ: Used in generate block
  assign {hif_bypass_reorder_dca,hif_rinfo_dca,rtoken_dca,rbeat_info_dca,e_resp_rexa_acc_dca_unused,e_resp_rexa_acc_instr_dca,e_resp_rpoison_dca,e_resp_ocpar_err_dca,e_resp_ruser_dca,hif_queue_dca,hif_arvalid_iecc_dca_unused,hif_arlast_iecc_dca_unused,hif_rlast_dca,hif_rid_dca,rport_num_dca_unused} = e_resp_token_dca_i;
  assign {hif_bypass_reorder_dcb,hif_rinfo_dcb,rtoken_dcb,rbeat_info_dcb,e_resp_rexa_acc_dcb_unused,e_resp_rexa_acc_instr_dcb,e_resp_rpoison_dcb,e_resp_ocpar_err_dcb,e_resp_ruser_dcb,hif_queue_dcb,hif_arvalid_iecc_dcb_unused,hif_arlast_iecc_dcb_unused,hif_rlast_dcb,hif_rid_dcb,rport_num_dcb_unused} = e_resp_token_dcb;
//spyglass enable_block W528  


  assign xpi_wexa_resp_dca = 1'b0; // dummy placeholder; real value is replaced by the EXA monitor
  assign xpi_wexa_resp_dcb = 1'b0;
  assign xpi_rxcmd_wdata_ptr = { xpi_exa_awlast_i,xpi_awvalid_iecc,xpi_awlast_iecc,xpi_wexa_resp_dca,xpi_wexa_acc_dca,xpi_wexa_acc_lock_dca,xpi_awid_dca,xpi_awuser_dca,xpi_wpoison_dca,xpi_ocpar_err_dca,port_num}; // xpi_awvalid_iecc and xpi_awlast_iecc are required to be at the MSB. If changing this, update assignement in hif_cmd accordingly
  assign xpi_rxcmd_wdata_ptr_dcb = { xpi_exa_awlast_i,xpi_awvalid_iecc_dcb,xpi_awlast_iecc_dcb,xpi_wexa_resp_dcb,xpi_wexa_acc_dcb,xpi_wexa_acc_lock_dcb,xpi_awid_dcb,xpi_awuser_dcb,xpi_wpoison_dcb,xpi_ocpar_err_dcb,port_num}; // same as above
  
  // sending the last valid address flag to the exa, this is required during a wrap burst to check for the violation when the second incremental burst is sent
  assign xpi_exa_awlast_i    = xpi_awlast & ~xpi_rmw_split;
  
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
  assign xpi_exa_arlast_blue = xpi_rd_arlast_blue_i & ~xpi_rd_split_blue;
  assign xpi_exa_arlast_red  = xpi_rd_arlast_red_i & ~xpi_rd_split_red;
//spyglass enable_block W528

  // need to send short_burst information to the exclusive monitors so that it can align the address by itself 
  assign xpi_exa_short_burst_i       = xpi_rmw_short_burst;
  
  // address parity enable bit
  // reg_arb_oc_parity_en : global ocpar enable bit
  // reg_arb_address_parity_mode : enable address parity for read and write

  assign oc_addr_parity_en    = reg_arb_oc_parity_en & reg_arb_address_parity_mode;

  assign oc_rdata_parity_en   = reg_arb_oc_parity_en & reg_arb_read_data_parity_mode;

  assign oc_wdata_parity_en   = reg_arb_oc_parity_en & reg_arb_write_data_parity_mode;
  
  //-------------------------------------
  // TOKEN Manager 
  //-------------------------------------
  
  
  assign gen_token            = gen_token_dca | gen_token_dcb;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
  assign gen_token_red        = gen_token_red_dca | gen_token_red_dcb;
  assign gen_token_blue       = gen_token_blue_dca | gen_token_blue_dcb;
//spyglass enable_block W528  
  wire rrb_tm_locked_ch_raq_red,rrb_tm_locked_ch_raq_red_dcb;
  wire rrb_is_locked, rrb_is_locked_dcb;
  wire [NUM_CH_LG2-1:0] locked_ch,locked_ch_dcb;
  wire [NUM_VIR_CH-1:0] ch_arlast_received;
  
  DWC_ddr_umctl2_xpi_tm
  
    #(.USE2RAQ     (USE2RAQ),
      .NTOKENS     (MEMC_NO_OF_ENTRY),  
      .NTOKENS_LG2 (MEMC_NO_OF_ENTRY_LG2),
      .READ_DATA_INTERLEAVE_EN (READ_DATA_INTERLEAVE_EN),
      .NUM_CH_LG2  (NUM_CH_LG2),
      .NUM_VIR_CH  (NUM_VIR_CH),
      .RDWR_ORDERED(RDWR_ORDERED),
      .OCCAP_EN    (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN))
  U_xpi_tm
    (
     // Outputs
     .token            (atoken_dca),
     .empty_blue       (tm_empty_blue_dca),
     .empty_red        (tm_empty_red_dca),
     .occap_xpi_tm_par_err  (occap_xpi_tm_dca_par_err),
     // Inputs      
     .clk               (e_clk),          // clock
     .rst_n             (e_rst_n),        // asynchronous reset
     .gen_token_blue    (gen_token_blue_dca_i),  // generate a new token
     .gen_token_red     (gen_token_red_dca_i),
     .release_token     (tm_release_token_dca),
     .rtoken            (tm_rtoken_dca),
     .locked_ch_raq_red (rrb_tm_locked_ch_raq_red),
     .arvalid_blue      (xpi_arvalid_l_blue_dca),
     .arvalid_red       (xpi_arvalid_l_red_dca),
     .rrb_is_locked     (rrb_is_locked),
     .locked_ch         (locked_ch),
     .ch_arlast_received(ch_arlast_received),
     .reg_rdwr_ordered_en(reg_arb_rdwr_ordered_en),
     .reg_ddrc_occap_en (reg_ddrc_occap_en));

//spyglass disable_block W528
//SMD: Variable atoken_dcb_pn/tm_empty_blue_dcb/tm_empty_red_dcb and others set but not read
//SJ: Used in generate block
   generate
      if (DUAL_CHANNEL_INTERLEAVE==1) begin: Dual_TM
         assign atoken_dcb_pn = atoken_dcb + MEMC_NO_OF_ENTRY;
            DWC_ddr_umctl2_xpi_tm
            
            #( .USE2RAQ     (USE2RAQ),
               .NTOKENS     (MEMC_NO_OF_ENTRY),  
               .NTOKENS_LG2 (MEMC_NO_OF_ENTRY_LG2),
               .READ_DATA_INTERLEAVE_EN (READ_DATA_INTERLEAVE_EN),
               .NUM_CH_LG2  (NUM_CH_LG2),
               .NUM_VIR_CH  (NUM_VIR_CH),
               .RDWR_ORDERED(RDWR_ORDERED),
               .OCCAP_EN    (OCCAP_EN),
               .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN))
            U_xpi_tm
            (
            // Outputs
            .token            (atoken_dcb),
            .empty_blue       (tm_empty_blue_dcb),
            .empty_red        (tm_empty_red_dcb),
            .occap_xpi_tm_par_err   (occap_xpi_tm_dcb_par_err),
            // Inputs      
            .clk              (e_clk),          // clock
            .rst_n            (e_rst_n),        // asynchronous reset
            .gen_token_blue   (gen_token_blue_dcb),  // generate a new token
            .gen_token_red    (gen_token_red_dcb),
            .release_token    (tm_release_token_dcb),
            .rtoken           (tm_rtoken_dcb),
            .locked_ch_raq_red (rrb_tm_locked_ch_raq_red_dcb),
            .arvalid_blue      (xpi_arvalid_l_blue_dcb),
            .arvalid_red       (xpi_arvalid_l_red_dcb),
            .rrb_is_locked     (rrb_is_locked_dcb),
            .locked_ch         (locked_ch_dcb),
            .ch_arlast_received(ch_arlast_received),
            .reg_rdwr_ordered_en(reg_arb_rdwr_ordered_en),
            .reg_ddrc_occap_en (reg_ddrc_occap_en));


      end
      else if (DUAL_CHANNEL==1) begin: Single_TM
         assign tm_empty_blue_dcb   = tm_empty_blue_dca;
         assign tm_empty_red_dcb    = tm_empty_red_dca;
         assign atoken_dcb          = atoken_dca;
         assign atoken_dcb_pn       = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
         assign occap_xpi_tm_dcb_par_err = 1'b0;

      end
      else begin: Single_dch
         // second data channel not used
         assign tm_empty_blue_dcb   = 1'b0;
         assign tm_empty_red_dcb    = 1'b0;
         assign atoken_dcb          = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
         assign atoken_dcb_pn       = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
         assign occap_xpi_tm_dcb_par_err = 1'b0;
      end
   endgenerate

  //-------------------------------------
  // Dynamic Channel Mapper
  //-------------------------------------

  generate
    if (STATIC_VIR_CH==0) begin: dynamic_channel_map

      if (NUM_VIR_CH>1) begin: dynamic_channel_map_multi_ch

        wire [NUM_VIR_CH_LG2-1:0] dcm_channel;
        wire                      dcm_empty;

        DWC_ddr_umctl2_xpi_dcm
        
          #(.NTOKENS     (DCM_NTOKENS),
            .NTOKENS_LG2 (DCM_NTOKENS_LG2),
            .RRB_THRESHOLD_EN    (RRB_THRESHOLD_EN),
            .NTOKENS_SBAM    (MEMC_NO_OF_ENTRY),
            .NTOKENS_LG2_SBAM(MEMC_NO_OF_ENTRY_LG2),
            .AXI_MAXSIZE (AXI_MAXSIZE),
            .USE_BAM     (USE_BAM),
            .AXI_IDW     (AXI_IDW),
            .NUM_VIR_CH  (NUM_VIR_CH),
            .NUM_VIR_CH_LG2          (NUM_VIR_CH_LG2),
            .READ_DATA_INTERLEAVE_EN (READ_DATA_INTERLEAVE_EN),
            .USE2RAQ                 (USE2RAQ),
            .NBEATS                  (NBEATS),
            .OCCAP_EN                (OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
            )
        U_xpi_dcm
          (
           // Outputs
           .channel       (dcm_channel),
           .dcm_token     (dcm_token),
           .dcm_dch       (dcm_dch_sel),
           .empty         (dcm_empty),
           .ch_arlast_received (ch_arlast_received),
           .occap_xpi_dcm_par_err   (occap_xpi_dcm_par_err),
           .dcm_sbam_lead_burst         (dcm_sbam_lead_burst),
           .dcm_sbam_second_burst       (dcm_sbam_second_burst),
           .dcm_sbam_tokens_allocated   (dcm_sbam_tokens_allocated),
           .dcm_bam_addr_offset (dcm_bam_addr_offset),
           .dcm_bam_lead_burst  (dcm_bam_lead_burst ),
           .dcm_bam_arlast  (dcm_bam_arlast ),
           .dcm_bam_red_token   (dcm_bam_red_token),
           .dch           (dch_sel_dcm),
           // Inputs
           .red_queue     (gen_token_red), // (dual queue + dual channel support)
           .clk           (e_clk),             // clock
           .rst_n         (e_rst_n),           // asynchronous reset
           .wr            (gen_token),         // generate a new token
           .token         (atoken_dcm),
           .sbam_lead_burst         (sbam_lead_burst),
           .sbam_second_burst       (sbam_second_burst),
           .sbam_tokens_allocated   (sbam_tokens_allocated),
           .bam_addr_offset (bam_addr_offset),
           .bam_lead_burst  (bam_lead_burst),
           .bam_arlast    (bam_arlast ),
           .split         (split_dcm),
           .release_token (rrb_release_token), // token is released by RRB
           .rtoken        (rrb_rtoken_dcm),        // the released token
           .arid          (xpi_rd_arid),        // AXI Address Read ID
           .vtq_empty     (vtq_empty),
           .reg_ddrc_occap_en (reg_ddrc_occap_en)
           );
        
        assign gen_token_rrb        = ~dcm_empty;
        assign atoken_rrb_dca       = dcm_token[MEMC_NO_OF_ENTRY_LG2-1:0];
        assign atoken_rrb_dcb       = atoken_rrb_dcb_dcm[MEMC_NO_OF_ENTRY_LG2-1:0]; 
        assign ch_num_rrb_dca       = dcm_channel;
        assign ch_num_rrb_dcb       = dcm_channel;
        assign ch_num_rrb_dcr       = dcm_channel;
        assign abypass_reorder_rrb_dca = 1'b0;
        assign abypass_reorder_rrb_dcb = 1'b0;

      end // block: dynamic_channel_map_multi_ch
      
      else begin: dynamic_channel_map_single_ch
        assign gen_token_rrb        = gen_token;
        assign atoken_rrb_dca       = atoken_dca; // no need for muxing, atoken_dcb has same value as atoken_dca
        assign atoken_rrb_dcb       = atoken_dcb;
        assign dcm_dch_sel          = dch_sel_dcm; // TODO       
        assign dcm_token            = {DCM_NTOKENS_LG2{1'b0}};
        assign ch_num_rrb_dca       = 1'b0;
        assign ch_num_rrb_dcb       = 1'b0;
        assign ch_num_rrb_dcr       = 1'b0;
        assign abypass_reorder_rrb_dca = 1'b0;
        assign abypass_reorder_rrb_dcb = 1'b0;
        assign occap_xpi_dcm_par_err = 1'b0;
        assign dcm_bam_addr_offset = bam_addr_offset;
        assign dcm_bam_lead_burst = bam_lead_burst;
        assign dcm_bam_arlast = bam_arlast;
        assign dcm_bam_red_token = gen_token_red;
        assign ch_arlast_received = 1'b0; // This bit is unused.

        assign dcm_sbam_lead_burst          = sbam_lead_burst;
        assign dcm_sbam_second_burst        = sbam_second_burst;
        assign dcm_sbam_tokens_allocated    = sbam_tokens_allocated;

      end
    end // block: dynamic_channel_map
    
    else begin: static_channel_map
      assign gen_token_rrb       = gen_token;
      assign atoken_rrb_dca       = atoken_dca; // no need for muxing, atoken_dcb has same value as atoken_dca
      assign atoken_rrb_dcb       = atoken_dcb;
      assign dcm_dch_sel         = dch_sel_dcm; // TODO      
      assign dcm_token           = {DCM_NTOKENS_LG2{1'b0}};
      assign ch_num_rrb_dca      = xpi_read_ch_num;
      assign ch_num_rrb_dcb      = xpi_read_ch_num;
      assign ch_num_rrb_dcr      = xpi_read_ch_num;
      assign abypass_reorder_rrb_dca = xpi_read_bypass_reorder;
      assign abypass_reorder_rrb_dcb = xpi_read_bypass_reorder;
      assign occap_xpi_dcm_par_err = 1'b0;
      assign dcm_bam_addr_offset = bam_addr_offset;
      assign dcm_bam_lead_burst = bam_lead_burst;
      assign dcm_bam_arlast = bam_arlast;
      assign dcm_bam_red_token = gen_token_red;
      assign ch_arlast_received = 1'b0; // This bit is unused.

      assign dcm_sbam_lead_burst          = sbam_lead_burst;
      assign dcm_sbam_second_burst        = sbam_second_burst;
      assign dcm_sbam_tokens_allocated    = sbam_tokens_allocated;

    end //static_channel_map
    
  endgenerate
//spyglass enable_block W528
  reg ctrl_in_reset;  //disable the valid/ready signals at reset
  
  always @ (posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
      ctrl_in_reset  <= 1'b1;
    end
    else  begin
      ctrl_in_reset  <= 1'b0;
    end
  end 
  
  assign i_reg_arb_port_en = reg_arb_port_en & ~ddrc_xpi_port_disable_req_sync;
  
  // Gate the input valid and output ready signals in low power
  assign awvalid_l = awvalid & ready_lp & write_addr_ch_en & ~ctrl_in_reset;
  assign awready = awready_l & ready_lp & write_addr_ch_en & ~ctrl_in_reset;
  assign arvalid_l = arvalid & ready_lp & i_reg_arb_port_en & ~ctrl_in_reset;
  assign arready = arready_l & ready_lp & i_reg_arb_port_en & ~ctrl_in_reset;
  assign wvalid_l = wvalid & ready_lp & write_data_ch_en & ~block_posted_writes & ~ctrl_in_reset; 
  assign wready = wready_l & ready_lp & write_data_ch_en & ~block_posted_writes & ~ctrl_in_reset;
  
  //---------------------------------------------------------------------------
  // Lock Write Data channel FSM 
  //---------------------------------------------------------------------------
  // Write data state machine encodings
  localparam WRITE_DATA_STATE_WIDTH  = 1;
  localparam IDLE_WR_DATA        = 1'b0;  
  localparam LOCK_WRITE_DATA_CH  = 1'b1;

  reg [WRITE_DATA_STATE_WIDTH-1:0]         write_data_state_next;
  reg [WRITE_DATA_STATE_WIDTH-1:0]         write_data_state_reg;  
  // Wait until all data beats of current write burst are accepted
  // and lock the write data channel if reg_arb_port_en goes low 
  always @(*) begin
    write_data_state_next = write_data_state_reg;
    write_data_ch_en = 1'b1;
    wait_data_ch_lock = 1'b0;    
    case (write_data_state_reg)
      IDLE_WR_DATA: begin
        if (~i_reg_arb_port_en) begin 
          if (posted_write_beats_next==0)
            write_data_state_next = LOCK_WRITE_DATA_CH;
          else
            wait_data_ch_lock = 1'b1;    
        end

      end              
      default/*LOCK_WRITE_DATA_CH*/: begin
        write_data_ch_en=1'b0;
        if (i_reg_arb_port_en)
          write_data_state_next = IDLE_WR_DATA;
      end
      
    endcase // case(write_data_state_reg)
  end // always @ (*)

  always @ (posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
      write_data_state_reg  <= LOCK_WRITE_DATA_CH;
    end
    else  begin
      write_data_state_reg  <= write_data_state_next;
    end
  end
  
  //---------------------------------------------------------------------------
  // Lock Write Address Channel FSM 
  //---------------------------------------------------------------------------
  // Write data state machine encodings
  localparam WRITE_ADDR_STATE_WIDTH  = 2;
  localparam IDLE_WR_ADDR        = 2'b00;  
  localparam WAIT_POSTED_DATA    = 2'b01;
  localparam LOCK_WRITE_ADDR_CH  = 2'b10;

  reg [WRITE_ADDR_STATE_WIDTH-1:0]         write_addr_state_next;
  reg [WRITE_ADDR_STATE_WIDTH-1:0]         write_addr_state_reg;  
  // Wait until write address is received for all posted write data beats then 
  // lock the write address channel if reg_arb_port_en goes low 
  
  always @(*) begin
    write_addr_state_next = write_addr_state_reg;
    write_addr_ch_en = 1'b1;
    block_posted_writes = 1'b0;
    wait_addr_ch_lock = 1'b0;
    case (write_addr_state_reg)
      IDLE_WR_ADDR: begin
        if (~i_reg_arb_port_en) begin 
          if (posted_write_data_exist)
            write_addr_state_next = WAIT_POSTED_DATA;
          else 
            write_addr_state_next = LOCK_WRITE_ADDR_CH;
        end
      end              
      LOCK_WRITE_ADDR_CH: begin
        write_addr_ch_en=1'b0;
        if (i_reg_arb_port_en)
          write_addr_state_next = IDLE_WR_ADDR;
      end
      
      default: begin
        block_posted_writes = 1'b1;
        wait_addr_ch_lock = 1'b1;
        if (~posted_write_data_exist)
          write_addr_state_next = LOCK_WRITE_ADDR_CH;
      end
    endcase // case(write_addr_state_reg)
  end // always @ (*)

  always @ (posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
      write_addr_state_reg  <= IDLE_WR_ADDR;
    end
    else  begin
      write_addr_state_reg  <= write_addr_state_next;
    end
  end

  generate
   if (OCPAR_EN==1 || OCECC_EN==1) begin: OC_par_en_1

      // sync reset for correct parity assign
      reg e_rst_dly_0, e_rst_dly_1, a_rst_dly_0, a_rst_dly_1;
      // aclk
      always @(posedge aclk or negedge aresetn) begin: SYNC_arst
         if (~aresetn) begin
            a_rst_dly_0   <= 1'b0;
            a_rst_dly_1   <= 1'b0;
         end
         else begin
            a_rst_dly_0   <= 1'b1;
            a_rst_dly_1   <= a_rst_dly_0;
         end
      end
      // core clock
      always @(posedge e_clk or negedge e_rst_n) begin: SYNC_erst
         if (~e_rst_n) begin
            e_rst_dly_0   <= 1'b0;
            e_rst_dly_1   <= 1'b0;
         end
         else begin
            e_rst_dly_0   <= 1'b1;
            e_rst_dly_1   <= e_rst_dly_0;
         end
      end
      // generate a pulse just after reset is released, this is because parity has to be reset to the correct value to avoid false errors based on what is programmed on parity_type register
      assign a_rst_dly = a_rst_dly_0 & ~(a_rst_dly_1);
      assign e_rst_dly = e_rst_dly_0 & ~(e_rst_dly_1);


   end
   else begin: OC_par_nen
      assign a_rst_dly  = 1'b0;
      assign e_rst_dly  = 1'b0;
   end
  endgenerate

  generate
    if (USE_SAR==1) begin: sar_en
      //---------------------------------------------------------------------------
      // Sample SAR regs in aclk domain
      //---------------------------------------------------------------------------

      assign reg_base_addr_0   = reg_arb_base_addr_0;
      assign reg_nblocks_0     = reg_arb_nblocks_0;
      assign reg_base_addr_1   = reg_arb_base_addr_1;
      assign reg_nblocks_1     = reg_arb_nblocks_1;
      assign reg_base_addr_2   = reg_arb_base_addr_2;
      assign reg_nblocks_2     = reg_arb_nblocks_2;
      assign reg_base_addr_3   = reg_arb_base_addr_3;

    end else begin: sar_nen

      assign reg_base_addr_0   = {AXI_SAR_BW{1'b0}};
      assign reg_nblocks_0     = {AXI_SAR_SW{1'b0}};
      assign reg_base_addr_1   = {AXI_SAR_BW{1'b0}};
      assign reg_nblocks_1     = {AXI_SAR_SW{1'b0}};
      assign reg_base_addr_2   = {AXI_SAR_BW{1'b0}};
      assign reg_nblocks_2     = {AXI_SAR_SW{1'b0}};
      assign reg_base_addr_3   = {AXI_SAR_BW{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // XPI read write pre and post arbiter  
  //---------------------------------------------------------------------------
  wire                                  pre_arb_arvalid;
  wire                                  pre_arb_awvalid;
  wire                                  pre_arb_arready;
  wire                                  pre_arb_awready;
  wire [ORDER_TOKENW-1:0]               pre_arb_read_order_token;
  wire [ORDER_TOKENW-1:0]               pre_arb_write_order_token;
  
  wire [ORDER_TOKENW-1:0]               xpi_write_order_token, rmw_write_order_token;
  wire [ORDER_TOKENW-1:0]               xpi_read_order_token_blue;
  wire [ORDER_TOKENW-1:0]               xpi_read_order_token_red;
  
  
  wire                                  rmw_awvalid;
  wire                                  xpi_read_avalid_blue;
  wire                                  xpi_read_avalid_red;
  wire                                  post_arb_arready_blue;
  wire                                  post_arb_arready_red;
  wire                                  post_arb_awready;      

  generate
    if (RDWR_ORDERED==1)  begin: GEN_rdwr_arb
      //--------------------------------------------------------------------
      // XPI read write pre arbiter  
      //--------------------------------------------------------------------
      
      DWC_ddr_umctl2_xpi_rdwr_pre_arb
      
        #(.ORDER_TOKENW(ORDER_TOKENW),
          .OCCAP_EN(OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
        )          
      U_xpi_rdwr_pre_arb 
        (
         // Outputs
         .arready                       (arready_l),
         .xpi_arvalid                   (pre_arb_arvalid),
         .awready                       (awready_l),
         .xpi_awvalid                   (pre_arb_awvalid),
         .xpi_read_order_token          (pre_arb_read_order_token[ORDER_TOKENW-1:0]),
         .xpi_write_order_token         (pre_arb_write_order_token[ORDER_TOKENW-1:0]),
         .occap_xpi_rdwr_pre_arb_par_err (occap_xpi_rdwr_pre_arb_par_err),

         // Inputs
         .aclk                          (aclk),
         .aresetn                       (aresetn),
         .rdwr_ordered                  (reg_arba_rdwr_ordered_en),
         .arvalid                       (arvalid_l),
         .xpi_arready                   (pre_arb_arready),
         .awvalid                       (awvalid_l),
         .xpi_awready                   (pre_arb_awready),
         .reg_ddrc_occap_en             (reg_ddrc_occap_en)                
       );
      
      //---------------------------------------------------------------------
      // XPI read write post  arbiter  
      //---------------------------------------------------------------------
      
      DWC_ddr_umctl2_xpi_rdwr_post_arb
      
        #(.ORDER_TOKENW(ORDER_TOKENW),
          .OCCAP_EN(OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
        )
      U_xpi_rdwr_post_arb 
        (
         // Outputs
         .post_arb_arready_blue         (post_arb_arready_blue), 
         .post_arb_arready_red          (post_arb_arready_red),
         .post_arb_awready              (post_arb_awready),
         .post_arb_awvalid              (xpi_awvalid),
         .post_arb_arvalid_blue         (xpi_arvalid_l_blue),
         .post_arb_arvalid_red          (xpi_arvalid_l_red),
         .occap_xpi_rdwr_post_arb_par_err (occap_xpi_rdwr_post_arb_par_err),
         // Inputs
         .clk                           (e_clk),
         .rst_n                         (e_rst_n),
         .rdwr_ordered                  (reg_arb_rdwr_ordered_en),
         .xpi_read_avalid_blue          (xpi_read_avalid_blue), 
         .xpi_read_avalid_red           (xpi_read_avalid_red),
         .xpi_read_alast_blue           (xpi_exa_arlast_blue),
         .xpi_read_alast_red            (xpi_exa_arlast_red),
         .xpi_read_order_token_blue     (xpi_read_order_token_blue[ORDER_TOKENW-1:0]),
         .xpi_read_order_token_red      (xpi_read_order_token_red[ORDER_TOKENW-1:0]),
         .xpi_write_avalid              (rmw_awvalid), 
         .xpi_write_alast               (xpi_exa_awlast_i),  
         .xpi_write_order_token         (rmw_write_order_token[ORDER_TOKENW-1:0]),
         .e_awready                     (hif_awready),
         .e_arready_blue                (hif_arready_l_blue),
         .e_arready_red                 (hif_arready_l_red),
         .reg_ddrc_occap_en             (reg_ddrc_occap_en)         
       );
      
    end // block: GEN_rdwr_arb
    else begin: GEN_no_rdwr_arb
      assign pre_arb_arvalid        = arvalid_l;
      assign pre_arb_awvalid        = awvalid_l;
      
      assign arready_l              = pre_arb_arready;
      assign awready_l              = pre_arb_awready;
      
      assign xpi_awvalid            = rmw_awvalid;
      assign xpi_arvalid_l_blue     = xpi_read_avalid_blue;
      assign xpi_arvalid_l_red      = xpi_read_avalid_red;
      assign post_arb_arready_blue  = hif_arready_l_blue; 
      assign post_arb_arready_red   = hif_arready_l_red;
      assign post_arb_awready       = hif_awready;
      assign pre_arb_read_order_token    = {ORDER_TOKENW{1'b0}};
      assign pre_arb_write_order_token  = {ORDER_TOKENW{1'b0}};

      assign occap_xpi_rdwr_pre_arb_par_err  = 1'b0;
      assign occap_xpi_rdwr_post_arb_par_err = 1'b0;
    end // block: GEN_no_rdwr_arb
  endgenerate


  //---------------------------------------------------------------------------
  // XPI Write 
  //---------------------------------------------------------------------------
  DWC_ddr_umctl2_xpi_write
  
    #(
      .M_DW                      (M_DW),
      .M_DW_INT                  (M_DW_INT),
      .M_ADDRW                   (M_ADDRW),
      .NAB                       (NAB),
      .MEMC_BURST_LENGTH         (MEMC_BURST_LENGTH),
      .NBEATS_LG2                (NBEATS_LG2),            
      .M_USE_RMW                 (M_USE_RMW),
      .UP_SIZE                   (UP_SIZE_INT),
      .DOWN_SIZE                 (DOWN_SIZE_INT),
      .AXI_ADDRW                 (AXI_ADDRW),
      .AXI_DATAW                 (AXI_DATAW),
      .AXI_STRBW                 (AXI_STRBW),
      .AXI_IDW                   (AXI_IDW),
      .AXI_LENW                  (AXI_LENW),
      .AXI_SIZEW                 (AXI_SIZEW_LOC),
      .AXI_MAXSIZE               (AXI_MAXSIZE),
      .AXI_BURSTW                (AXI_BURSTW),
      .AXI_LOCKW                 (AXI_LOCKW),
      .AXI_USERW                 (AXI_USERW),
      .AXI_CACHEW                (AXI_CACHEW),
      .AXI_PROTW                 (AXI_PROTW),
      .AXI_QOSW                  (AXI_QOSW),
      .AXI_RESPW                 (AXI_RESPW),
      .AXI_WAQD                  (AXI_WAQD),
      .AXI_WAQD_LG2              (AXI_WAQD_LG2),
      .AXI_WDQD                  (AXI_WDQD),
      .AXI_WRQD                  (AXI_WRQD),
      .PDBW_CASE                 (PDBW_CASE),
      .DBW                       (DBW), 
      .WRQW                      (WRQW),
      .SQD                       (XPI_SQD),
      .AXI_SYNC                  (AXI_SYNC),
      .ENIF_DATAW                (A_DW_INT),
      .ENIF_STRBW                (A_STRBW_INT), 
      .ENIF_PARW                 (A_PARW_INT),     
      .ENIF_MAXSIZE              (ENIF_MAXSIZE_INT),
      .ENIF_SIZEW                (ENIF_SIZEW_INT),
      .ENIF_LENW                 (ENIF_LENW_INT),
      .ENIF_HDATAW               (A_DW),
      .ENIF_HSTRBW               (A_STRBW),      
      .ENIF_HMAXSIZE             (ENIF_MAXSIZE),
      .ENIF_HSIZEW               (ENIF_SIZEW),
      .ENIF_HLENW                (ENIF_LENW),
      .INFOW                     (WINFOW),
      .USE_WAR                   (USE_WAR),
      .AXI_SAR_BW                (AXI_SAR_BW),
      .AXI_SAR_SW                (AXI_SAR_SW),
      .USE_SAR                   (USE_SAR),
      .NSAR                      (NSAR),
      .SAR_MIN_ADDRW             (SAR_MIN_ADDRW),
      .VPW_EN                    (VPW_EN),
      .VPRW_PUSH_SYNC_DEPTH      (VPRW_PUSH_SYNC_DEPTH),
      .VPRW                      (VPRW),
      .M_INLINE_ECC              (M_INLINE_ECC),
      .WQOS_MLW                  (WQOS_MLW),
      .WQOS_RW                   (WQOS_RW),
      .WQOS_TW                   (WQOS_TW),
      .WAR_DEPTH                 (WARD),
      .RMW_WARD                  (RMW_WARD),
      .OCPAR_EN                  (OCPAR_EN),
      .OCPAR_SLICE_WIDTH         (OCPAR_SLICE_WIDTH),
      .OCCAP_EN                  (OCCAP_EN),
      .OCCAP_PIPELINE_EN         (OCCAP_PIPELINE_EN),
      .OCECC_EN                  (OCECC_EN),
      .OCECC_XPI_WR_IN_GRANU     (OCECC_XPI_WR_IN_GRANU),
      .OCECC_MR_RD_GRANU         (OCECC_MR_RD_GRANU),
      .OCECC_MR_BNUM_WIDTH       (OCECC_MR_BNUM_WIDTH),
      .OCCAP_CMP_AC              (OCCAP_CMP_AC),
      .OCCAP_CMP_CC              (OCCAP_CMP_CC),
      .OCPAR_ADDR_PAR_WIDTH      (OCPAR_ADDR_PAR_WIDTH),
      .DUAL_CHANNEL              (DUAL_CHANNEL),
      .DUAL_CHANNEL_INTERLEAVE   (DUAL_CHANNEL_INTERLEAVE_HP),
      .DUAL_CHANNEL_INTERLEAVE_LP(DUAL_CHANNEL_INTERLEAVE_LP),
      .DDRCTL_HET_INTERLEAVE     (DDRCTL_HET_INTERLEAVE),
      .DDRCTL_LUT_ADDRMAP_EN     (DDRCTL_LUT_ADDRMAP_EN),
      .PA_OPT_TYPE               (PA_OPT_TYPE),
      .ASYNC_FIFO_N_SYNC         (ASYNC_FIFO_N_SYNC),
      .ASYNC_FIFO_EARLY_PUSH_STAT(ASYNC_FIFO_EARLY_PUSH_STAT),
      .ASYNC_FIFO_EARLY_POP_STAT (ASYNC_FIFO_EARLY_POP_STAT),  
      .EXA_ACC_SUPPORT           (EXA_ACC_SUPPORT),
      .EXA_PYLD_W                (EXA_PYLD_W),
      .EXA_MAX_LENW              (EXA_MAX_LENW),
      .EXA_MAX_SIZEW             (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW             (EXA_MAX_ADDRW),
      .MEMC_NO_OF_ENTRY          (MEMC_NO_OF_ENTRY),
      .AXI_ADDR_BOUNDARY         (AXI_ADDR_BOUNDARY),
      .ORDER_TOKENW              (ORDER_TOKENW),
      .DEACC_INFOW               (DEACC_INFOW),
      .XPI_BRW                   (BRW),
      .UMCTL2_PARTIAL_WR_EN      (UMCTL2_PARTIAL_WR_EN),
      .UMCTL2_HET_RANK_EN        (UMCTL2_HET_RANK_EN),
      .AMCSW                     (AMCSW),
      .AMCOLW                    (AMCOLW),
      .AMCOLW_C3                 (AMCOLW_C3),
      .MEMC_DDR4_EN              (MEMC_DDR4_EN),
      .BCM_VERIF_EN              (BCM_VERIF_EN),
      .PUSH_AE_LVL               (PUSH_AE_LVL),
      .PUSH_AF_LVL               (PUSH_AF_LVL),
      .POP_AE_LVL                (POP_AE_LVL),
      .POP_AF_LVL                (POP_AF_LVL),
      .ERR_MODE                  (ERR_MODE),
      .OUTS_WRW                  (OUTS_WRW),
      .IH_TE_PIPELINE            (IH_TE_PIPELINE)
      )
  
  U_xpi_write
    (
     // Outputs
     .awready                            (pre_arb_awready),
     .wready                             (wready_l),
     .bid                                (bid),
     .bresp                              (bresp),
     .buser                              (buser),
     .bvalid                             (bvalid),
     .e_awaddr                           (xpi_wr_awaddr),
     .e_awdata_channel                   (xpi_wr_awdata_channel),
     .e_awlast                           (xpi_wr_awlast),
     .e_awid                             (xpi_wr_awid),
     .e_awqos                            (xpi_wr_awqos),
     .e_awuser                           (xpi_wr_awuser),
     .e_awpagematch                      (xpi_wr_awpagematch),
     .e_awautopre                        (xpi_wr_awautopre),
     .e_awvalid                          (xpi_wr_awvalid),
     .e_wdata                            (xpi_wr_wdata),
     .e_wdata_channel                    (xpi_wr_wdata_channel),
     .e_deacc_info                       (xpi_wr_deacc_info),
     .e_wstrb                            (xpi_wr_wstrb),
     .e_wlast                            (xpi_wr_wlast),
     .e_wvalid                           (xpi_wr_wvalid),
     .e_wpar_err                         (xpi_wr_wpar_err),
     .e_wparity                          (xpi_wr_wparity),
     .e_wlast_pkt                        (xpi_wr_wlast_pkt),
     .wdq_empty_aclk                     (wdq_empty_aclk),
     .e_wqos_priority                    (xpi_wr_wqos_priority),
     .e_poison                           (xpi_wr_wpoison),
     .e_ocpar_err                        (xpi_wr_ocpar_err),
     .e_exa_acc                          (xpi_wr_exa_acc),
     .e_exa_pyld                         (xpi_wr_exa_pyld),
     .e_exa_acc_lock                     (xpi_wr_exa_acc_lock),
     .e_bready                           (xpi_bready),
     .e_split                            (xpi_wr_split),
     .e_short_burst                      (xpi_wr_short_burst),
     .e_wqos_timeout                     (xpi_wr_wqos_timeout),
     .e_vpw_expired                      (xpi_wr_vpw_expired),
     .waq_wcount                         (waq_wcount),
     .waq_pop                            (waq_pop),
     .waq_push                           (waq_push),
     .waq_split                          (waq_split),
     .par_waddr_err_pulse                (par_waddr_err_pulse),
     .par_wdata_in_err_pulse             (par_wdata_in_err_pulse),
     .par_waddr_log                      (par_waddr_log),
     .ocecc_uncorr_err                   (ocecc_xpi_write_uncorr_err),
     .ocecc_corr_err                     (ocecc_xpi_write_corr_err),

     .xpi_write_order_token              (xpi_write_order_token),
     .occap_xpi_write_c_par_err          (occap_xpi_write_c_par_err),
     .occap_xpi_write_a_par_err          (occap_xpi_write_a_par_err),
     .occap_aclk_cmp_err                 (occap_xpi_write_a_cmp_err),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .e_beat_count                       (xpi_wr_beat_count),
     .short_write                        (xpi_short_write),
     .occap_aclk_cmp_err_full            (occap_xpi_write_a_cmp_err_full),
     .occap_aclk_cmp_err_seq             (occap_xpi_write_a_cmp_err_seq),
     .occap_aclk_cmp_poison_complete     (occap_xpi_write_a_cmp_poison_complete),
     .occap_cclk_cmp_err                 (occap_xpi_write_c_cmp_err),
     .occap_cclk_cmp_err_full            (occap_xpi_write_c_cmp_err_full),
     .occap_cclk_cmp_err_seq             (occap_xpi_write_c_cmp_err_seq),
     .occap_cclk_cmp_poison_complete     (occap_xpi_write_c_cmp_poison_complete),

//spyglass enable_block W528

     // Inputs
     .aclk                               (aclk),
     .aresetn                            (aresetn),
     .a_rst_dly                          (a_rst_dly),
     .siu_bl4                            (siu_bl4),
     .siu_bl8                            (siu_bl8),
     .siu_bl16                           (siu_bl16),
     .reg_burst_rdwr                     (reg_xpi_burst_rdwr),
     .awid                               (awid),
     .awaddr                             (awaddr),
     .awlen                              (awlen),
     .awsize                             (awsize[AXI_SIZEW_LOC-1:0]),
     .awburst                            (awburst),
     .awlock                             (awlock),
     .awcache                            (awcache),
     .awprot                             (awprot),
     .awuser                             (awuser),
     .awqos                              (awqos),
     .awpoison                           (awpoison),
     .awvalid                            (pre_arb_awvalid),
     .awparity                           (awparity),
     .awautopre                          (awautopre),
     .wid                                (wid),
     .wdata                              (wdata),
     .wparity                            (wparity),
     .wstrb                              (wstrb),
     .wuser                              (wuser),
     .wlast                              (wlast),
     .wvalid                             (wvalid_l),
     .bready                             (bready),
     .e_clk                              (e_clk),
     .e_rst_n                            (e_rst_n),
     .e_rst_dly                          (e_rst_dly),
     .e_awready                          (rmw_awready),
     .e_wready                           (rmw_wready),
     .e_bvalid                           (hif_bvalid),
     .e_bresp                            (xpi_bresp),
     .reg_ddrc_data_bus_width            (reg_ddrc_data_bus_width),
     .reg_arba_data_bus_width            (reg_arba_data_bus_width),
     .reg_arb_base_addr_0                (reg_base_addr_0),
     .reg_arb_nblocks_0                  (reg_nblocks_0),
     .reg_arb_base_addr_1                (reg_base_addr_1),
     .reg_arb_nblocks_1                  (reg_nblocks_1),
     .reg_arb_base_addr_2                (reg_base_addr_2),
     .reg_arb_nblocks_2                  (reg_nblocks_2),
     .reg_arb_base_addr_3                (reg_base_addr_3),
     .reg_arb_oc_parity_type             (reg_arb_oc_parity_type),
     .reg_ddrc_oc_parity_type            (reg_ddrc_oc_parity_type),
     .oc_addr_parity_en                  (oc_addr_parity_en),
     .oc_data_parity_en                  (oc_wdata_parity_en),
     .reg_ddrc_occap_en                  (reg_ddrc_occap_en),
     .reg_arb_occap_arb_cmp_poison_seq       (reg_arb_occap_arb_cmp_poison_seq),
     .reg_arb_occap_arb_cmp_poison_parallel  (reg_arb_occap_arb_cmp_poison_parallel),
     .reg_arb_occap_arb_cmp_poison_err_inj   (reg_arb_occap_arb_cmp_poison_err_inj),
     .reg_ddrc_occap_arb_cmp_poison_seq       (reg_ddrc_occap_arb_cmp_poison_seq),
     .reg_ddrc_occap_arb_cmp_poison_parallel  (reg_ddrc_occap_arb_cmp_poison_parallel),
     .reg_ddrc_occap_arb_cmp_poison_err_inj   (reg_ddrc_occap_arb_cmp_poison_err_inj),
     .ocecc_en                           (ocecc_en),
     .ocecc_poison_en                    (ocecc_poison_egen_mr_rd_0),
     .ocecc_poison_bnum                  (ocecc_poison_egen_mr_rd_0_byte_num),
     .ocecc_poison_single                (ocecc_poison_single),
     .ocecc_wdata_slverr_en              (ocecc_wdata_slverr_en),
     .wr_poison_en                       (wr_poison_en),
     .par_wdata_err_intr_clr             (par_wdata_err_intr_clr),
     .par_wdata_axi_check_bypass_en      (par_wdata_axi_check_bypass_en),
     .wqos_map_level1                    (wqos_map_level1),
     .wqos_map_level2                    (wqos_map_level2),
     .wqos_map_region0                   (wqos_map_region0),
     .wqos_map_region1                   (wqos_map_region1),
     .wqos_map_region2                   (wqos_map_region2),
     .wqos_map_timeout1                  (wqos_map_timeout1),
     .wqos_map_timeout2                  (wqos_map_timeout2),
     .pagematch_addrmap_mask             (pagematch_addrmap_mask),
     .pagematch_en                       (reg_arb_wr_port_pagematch_en),
     .data_channel_addrmap_mask          (data_channel_addrmap_mask),
     .bg_or_bank_addrmap_mask            (bg_or_bank_addrmap_mask),
     .reg_arb_dch_density_ratio          (reg_arb_dch_density_ratio),
     .e_addr_max_loc                     (e_addr_max_loc),
     .e_addr_max_m1_loc                  (e_addr_max_m1_loc),  
     .e_addr_max_loc_addrmap_mask        (e_addr_max_loc_addrmap_mask),
     .e_addr_max_m1_loc_addrmap_mask     (e_addr_max_m1_loc_addrmap_mask),
     .dch_bit                            (dch_bit),
     .pre_arb_order_token                (pre_arb_write_order_token),
     // short write related signals
     .reg_xpi_short_write_dis                            (reg_xpi_short_write_dis),
     .reg_xpi_short_write_dis_bl8_nab1                   (reg_xpi_short_write_dis_bl8_nab1),
     .reg_xpi_short_write_dis_bl8_nab1_1or3beats         (reg_xpi_short_write_dis_bl8_nab1_1or3beats),
     .reg_ddrc_col_addr_shift                            (reg_ddrc_col_addr_shift),
     .reg_ddrc_addrmap_col_b2                            (reg_ddrc_addrmap_col_b2),
     .reg_ddrc_addrmap_col_b3                            (reg_ddrc_addrmap_col_b3),
     .reg_ddrc_active_ranks                              (reg_ddrc_active_ranks),
     .reg_ddrc_alt_addrmap_en                            (reg_ddrc_alt_addrmap_en),
     .reg_ddrc_addrmap_cs_bit0                           (reg_ddrc_addrmap_cs_bit0),
     .reg_ddrc_addrmap_cs_bit1                           (reg_ddrc_addrmap_cs_bit1),        
     .reg_ddrc_addrmap_col_b2_alt                        (reg_ddrc_addrmap_col_b2_alt),
     .reg_ddrc_addrmap_col_b3_alt                        (reg_ddrc_addrmap_col_b3_alt),
     .reg_xpi_short_write_dis_bl16_nab1                  (reg_xpi_short_write_dis_bl16_nab1),
     .reg_xpi_short_write_dis_bl16_nab2                  (reg_xpi_short_write_dis_bl16_nab2),
     .reg_xpi_short_write_dis_mbl16_bl8_nab2             (reg_xpi_short_write_dis_mbl16_bl8_nab2),
     .reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2 (reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2),
     .reg_xpi_short_write_dis_mbl16_bl4_nab2             (reg_xpi_short_write_dis_mbl16_bl4_nab2),
     .reg_xpi_short_write_dis_bl16_qbw_nab1              (reg_xpi_short_write_dis_bl16_qbw_nab1),
     .reg_xpi_short_write_dis_bl16_hbw                   (reg_xpi_short_write_dis_bl16_hbw),
     .reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1         (reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1),
     .reg_xpi_short_write_dis_bl16_fbw_nab1              (reg_xpi_short_write_dis_bl16_fbw_nab1),
     .reg_xpi_short_write_dis_mbl16_bl4_nab1             (reg_xpi_short_write_dis_mbl16_bl4_nab1),
     .reg_xpi_short_write_dis_mbl16_bl8_bc_fbw           (reg_xpi_short_write_dis_mbl16_bl8_bc_fbw),
     .reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1      (reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1)
     );
  
  //---------------------------------------------------------------------------
  // XPI Read 
  //---------------------------------------------------------------------------
  DWC_ddr_umctl2_xpi_read
  
    #(
      .M_DW                        (M_DW),
      .M_DW_INT                    (M_DW_INT),
      .M_ADDRW                     (M_ADDRW),
      .NAB                         (NAB),
      .PDBW_CASE                   (PDBW_CASE),
      .MEMC_BURST_LENGTH           (MEMC_BURST_LENGTH),
      .NBEATS                      (NBEATS),
      .NBEATS_LG2                  (NBEATS_LG2),
      .NTOKENS                     (MEMC_NO_OF_ENTRY),  
      .NTOKENS_LG2                 (MEMC_NO_OF_ENTRY_LG2),
      .BEAT_INFOW                  (BEAT_INFOW),
      .M_BLW                       (M_BLW),
      .XPI_BRW                     (BRW),
      .M_ECC                       (M_ECC),
      .M_SIDEBAND_ECC              (M_SIDEBAND_ECC),
      .M_INLINE_ECC                (M_INLINE_ECC),
      .M_LPDDR3                    (M_LPDDR3),
      .M_DDR5                      (M_DDR5),
      .UP_SIZE                     (UP_SIZE_INT),
      .DOWN_SIZE                   (DOWN_SIZE_INT), 
      .AXI_ADDRW                   (AXI_ADDRW),
      .AXI_DATAW                   (AXI_DATAW),
      .AXI_STRBW                   (AXI_STRBW),
      .AXI_IDW                     (AXI_IDW),
      .AXI_LENW                    (AXI_LENW),
      .AXI_SIZEW                   (AXI_SIZEW_LOC),
      .AXI_MAXSIZE                 (AXI_MAXSIZE),
      .AXI_BURSTW                  (AXI_BURSTW),
      .AXI_LOCKW                   (AXI_LOCKW),
      .AXI_USERW                   (AXI_USERW),
      .AXI_CACHEW                  (AXI_CACHEW),
      .AXI_PROTW                   (AXI_PROTW),
      .AXI_QOSW                    (AXI_QOSW),
      .AXI_RESPW                   (AXI_RESPW),
      .AXI_RAQD                    (AXI_RAQD),
      .AXI_RAQD_LG2                (AXI_RAQD_LG2),
      .AXI_RDQD                    (AXI_RDQD),
      .AXI_SYNC                    (AXI_SYNC),
      .ACC_INFOW                   (ACC_INFOW),
      .NUM_DATA_CHANNELS           (NUM_DATA_CHANNELS),
      .ENIF_DATAW                  (A_DW_INT),
      .ENIF_STRBW                  (A_STRBW_INT),      
      .ENIF_MAXSIZE                (ENIF_MAXSIZE_INT),
      .ENIF_SIZEW                  (ENIF_SIZEW_INT),
      .ENIF_LENW                   (ENIF_LENW_INT),
      .ENIF_HDATAW                 (A_DW),
      .ENIF_HSTRBW                 (A_STRBW),      
      .ENIF_HMAXSIZE               (ENIF_MAXSIZE),
      .ENIF_HSIZEW                 (ENIF_SIZEW),
      .ENIF_HLENW                  (ENIF_LENW),
      .ARINFOW                     (RINFOW),
      .RINFOW                      (RINFOW),     
      .RINFOW_NSA                  (RINFOW_NSA),
      .RPINFOW                     (RPINFOW),
      .USE_RAR                     (USE_RAR),
      .USE_INPUT_RAR               (USE_INPUT_RAR),
      .AXI_SAR_BW                  (AXI_SAR_BW),
      .AXI_SAR_SW                  (AXI_SAR_SW),
      .USE_SAR                     (USE_SAR),
      .NSAR                        (NSAR),
      .SAR_MIN_ADDRW               (SAR_MIN_ADDRW),
      .USE2RAQ                     (USE2RAQ),
      .RQOS_MLW                    (RQOS_MLW),
      .RQOS_RW                     (RQOS_RW),
      .RQOS_TW                     (RQOS_TW),
      .VPR_EN                      (VPR_EN),
      .VPRW_PUSH_SYNC_DEPTH        (VPRW_PUSH_SYNC_DEPTH),
      .VPRW                        (VPRW),
      .RAR_DEPTH                   (RARD),
      .OCPAR_EN                    (OCPAR_EN),
      .OCCAP_EN                    (OCCAP_EN),
      .OCCAP_PIPELINE_EN           (OCCAP_PIPELINE_EN),
      .OCECC_EN                    (OCECC_EN),
      .OCECC_GRANU                 (OCECC_XPI_RD_GRANU),
      .OCCAP_CMP_AC                (OCCAP_CMP_AC),
      .OCCAP_CMP_CC                (OCCAP_CMP_CC),
      .OCPAR_ADDR_PAR_WIDTH        (OCPAR_ADDR_PAR_WIDTH),
      .USE_RPR                     (USE_RPR),
      .DUAL_CHANNEL_INTERLEAVE     (DUAL_CHANNEL_INTERLEAVE_HP),
      .DUAL_CHANNEL_INTERLEAVE_LP  (DUAL_CHANNEL_INTERLEAVE_LP),
      .DDRCTL_HET_INTERLEAVE       (DDRCTL_HET_INTERLEAVE),
      .DDRCTL_LUT_ADDRMAP_EN       (DDRCTL_LUT_ADDRMAP_EN),
      .OCPAR_SLICE_WIDTH           (OCPAR_SLICE_WIDTH),
      .OCPAR_NUM_BYTES             (OCPAR_NUM_BYTES),
      .OCPAR_NUM_BYTES_LG2         (OCPAR_NUM_BYTES_LG2),
      .ASYNC_FIFO_N_SYNC           (ASYNC_FIFO_N_SYNC),
      .ASYNC_FIFO_EARLY_PUSH_STAT  (ASYNC_FIFO_EARLY_PUSH_STAT),
      .ASYNC_FIFO_EARLY_POP_STAT   (ASYNC_FIFO_EARLY_POP_STAT),
      .EXA_ACC_SUPPORT             (EXA_ACC_SUPPORT),
      .EXA_PYLD_W                  (EXA_PYLD_W),
      .EXA_MAX_LENW                (EXA_MAX_LENW),
      .EXA_MAX_SIZEW               (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW               (EXA_MAX_ADDRW),
      .NUM_VIR_CH                  (NUM_VIR_CH),
      .NUM_VIR_CH_LG2              (NUM_VIR_CH_LG2),
      .NUM_CH                      (NUM_CH),
      .NUM_CH_LG2                  (NUM_CH_LG2),
      .STATIC_VIR_CH               (STATIC_VIR_CH),
      .INTLVMODEW                  (INTLVMODEW),
      .ID_MAPW                     (ID_MAPW),
      .AXI_ADDR_BOUNDARY           (AXI_ADDR_BOUNDARY),
      .ORDER_TOKENW                (ORDER_TOKENW),
      .READ_DATA_INTERLEAVE_EN     (READ_DATA_INTERLEAVE_EN),
      .BCM_VERIF_EN                (BCM_VERIF_EN),
      .PUSH_AE_LVL                 (PUSH_AE_LVL),
      .PUSH_AF_LVL                 (PUSH_AF_LVL),
      .POP_AE_LVL                  (POP_AE_LVL),
      .POP_AF_LVL                  (POP_AF_LVL),
      .RRB_THRESHOLD_EN                (RRB_THRESHOLD_EN),
      .RRB_LOCK_THRESHOLD_WIDTH    (RRB_LOCK_THRESHOLD_WIDTH),
      .ERR_MODE                    (ERR_MODE)
      )
  U_xpi_read 
    (
     // Outputs
     .arready                             (pre_arb_arready),
     .rid                                 (rid[AXI_IDW-1:0]),
     .rdata                               (rdata[AXI_DATAW-1:0]),
     .rparity                             (rparity[AXI_STRBW-1:0]),
     .rresp                               (rresp[AXI_RESPW-1:0]),
     .ruser                               (ruser),
     .rlast                               (rlast),
     .rvalid                              (rvalid),
     .e_araddr_blue                       (xpi_araddr_blue_i[M_ADDRW-1:0]),
     .e_arid_blue                         (xpi_rd_arid_blue_i[AXI_IDW-1:0]),
     .e_arqos_blue                        (xpi_arqos_blue_i),
     .e_rqos_priority_blue                (xpi_rqos_priority_blue_i),
     .e_rqos_timeout_blue                 (xpi_rqos_timeout_blue_i),
     .e_vpr_expired_blue                  (xpi_vpr_expired_blue_i),
     .e_arpagematch_blue                  (xpi_arpagematch_blue_i),
     .e_arlast_blue                       (xpi_rd_arlast_blue_i),
     .e_arinfo_blue                       (xpi_rd_arinfo_blue_i[RINFOW-1:0]),
     .e_arvalid_blue                      (xpi_read_avalid_blue),
     .e_split_blue                        (xpi_rd_split_blue),
     .e_rready                            (rrb_rd),
     .e_exa_acc_blue                      (e_rexa_acc_blue_i),
     .e_exa_acc_instr_blue                (e_rexa_acc_instr_blue_i),
     .e_poison_blue                       (e_rpoison_blue_i),
     .e_ocpar_err_blue                    (e_ocpar_err_blue_i),
     .e_user_blue                         (e_user_blue_i),
     .e_autopre_blue                      (xpi_arautopre_blue_i),
     .e_exa_pyld_blue                     (xpi_rexa_pyld_blue_i),
     .xpi_read_ch_num_blue                (xpi_read_ch_num_blue[NUM_VIR_CH_LG2-1:0]),
     .xpi_read_bypass_reorder_blue        (xpi_read_bypass_reorder_blue_i),   
     .beat_info_blue                      (abeat_info_blue_i),
     .e_split_red                         (xpi_rd_split_red),
     .e_arlast_red                        (xpi_rd_arlast_red_i),
     .e_arvalid_red                       (xpi_read_avalid_red),
     .par_raddr_err_pulse                 (par_raddr_err_pulse),
     .par_rdata_err_pulse                 (par_rdata_err_pulse),
     .par_raddr_log                       (par_raddr_log),
     .par_rdata_byte_log                  (par_rdata_byte_log),
     .ocecc_uncorr_err                    (ocecc_xpi_read_uncorr_err),
     .ocecc_corr_err                      (ocecc_xpi_read_corr_err),
     .occap_xpi_read_a_par_err            (occap_xpi_read_a_par_err),
     .occap_xpi_read_c_par_err            (occap_xpi_read_c_par_err),
     .occap_aclk_cmp_err                  (occap_xpi_read_a_cmp_err),
     .sbam_lead_burst_blue                (sbam_lead_burst_blue),
     .sbam_second_burst_blue              (sbam_second_burst_blue),
     .sbam_tokens_allocated_blue          (sbam_tokens_allocated_blue),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .sbam_lead_burst_red                 (sbam_lead_burst_red),
     .sbam_second_burst_red               (sbam_second_burst_red),
     .sbam_tokens_allocated_red           (sbam_tokens_allocated_red),
     .bam_lead_burst_blue                 (bam_lead_burst_blue),
     .bam_addr_offset_blue                (bam_addr_offset_blue),
     .bam_lead_burst_red                  (bam_lead_burst_red),
     .bam_addr_offset_red                 (bam_addr_offset_red_i),    
     .e_dch_blue                          (data_channel_rd_blue),
     .e_dch_red                           (data_channel_rd_red),
     .xpi_read_order_token_blue           (xpi_read_order_token_blue[ORDER_TOKENW-1:0]),
     .beat_info_red                       (abeat_info_red_i),
     .xpi_read_order_token_red            (xpi_read_order_token_red),
     .xpi_read_ch_num_red                 (xpi_read_ch_num_red),
     .xpi_read_bypass_reorder_red         (xpi_read_bypass_reorder_red_i),
     .e_exa_acc_red                       (e_rexa_acc_red_i),
     .e_exa_acc_instr_red                 (e_rexa_acc_instr_red_i),
     .e_poison_red                        (e_rpoison_red_i),
     .e_ocpar_err_red                     (e_ocpar_err_red_i),
     .e_user_red                          (e_user_red_i),
     .e_autopre_red                       (xpi_arautopre_red_i),
     .e_exa_pyld_red                      (xpi_rexa_pyld_red_i),
     .e_araddr_red                        (xpi_araddr_red_i[M_ADDRW-1:0]),
     .e_arid_red                          (xpi_rd_arid_red_i[AXI_IDW-1:0]),
     .e_arqos_red                         (xpi_arqos_red_i),
     .e_rqos_priority_red                 (xpi_rqos_priority_red_i),
     .e_rqos_timeout_red                  (xpi_rqos_timeout_red_i),
     .e_vpr_expired_red                   (xpi_vpr_expired_red_i),
     .e_arpagematch_red                   (xpi_arpagematch_red_i),
     .e_arinfo_red                        (xpi_rd_arinfo_red_i[RINFOW-1:0]),
     .occap_aclk_cmp_err_full             (occap_xpi_read_a_cmp_err_full),
     .occap_aclk_cmp_err_seq              (occap_xpi_read_a_cmp_err_seq),
     .occap_aclk_cmp_poison_complete      (occap_xpi_read_a_cmp_poison_complete),
     .occap_cclk_cmp_err                  (occap_xpi_read_c_cmp_err),
     .occap_cclk_cmp_err_full             (occap_xpi_read_c_cmp_err_full),
     .occap_cclk_cmp_err_seq              (occap_xpi_read_c_cmp_err_seq),
     .occap_cclk_cmp_poison_complete      (occap_xpi_read_c_cmp_poison_complete),
//spyglass enable_block W528
     .raqb_wcount                         (raqb_wcount),
     .raqb_pop                            (raqb_pop),
     .raqb_push                           (raqb_push),
     .raqr_wcount                         (raqr_wcount),
     .raqr_pop                            (raqr_pop),
     .raqr_push                           (raqr_push),
     .raq_split                           (raq_split),
     .rd_poison_intr                      (rd_poison_intr),
     // Inputs
     .aclk                                (aclk),
     .aresetn                             (aresetn),
     .siu_bl4                             (siu_bl4),
     .siu_bl8                             (siu_bl8),
     .siu_bl16                            (siu_bl16),
     .reg_burst_rdwr                      (reg_xpi_burst_rdwr), 
     .reg_ddrc_data_bus_width             (reg_ddrc_data_bus_width),
     .reg_arba_data_bus_width            (reg_arba_data_bus_width),
     .arid                                (arid),
     .araddr                              (araddr),
     .arlen                               (arlen),
     .arsize                              (arsize[AXI_SIZEW_LOC-1:0]),
     .arburst                             (arburst),
     .arlock                              (arlock),
     .arcache                             (arcache),
     .arprot                              (arprot),
     .aruser                              (aruser),
     .arqos                               (arqos),
     .arpoison                            (arpoison),
     .arparity                            (arparity),
     .arautopre                           (arautopre),
     .arvalid                             (pre_arb_arvalid),
     .rready                              (rready),
     .e_clk                               (e_clk),
     .e_rst_n                             (e_rst_n),
     .e_rst_dly                           (e_rst_dly),
     .e_arready_blue                      (post_arb_arready_blue),
     .e_arready_red                       (post_arb_arready_red),
     .e_rdata                             (rrb_rdata_up),
     .e_rdata_parity                      (rrb_rdata_parity_up),
     .e_rerror                            (rrb_rerror),
     .e_rid                               (rrb_rid[AXI_IDW-1:0]),
     .e_ruser                             (rrb_ruser),
     .rrb_rd_last                         (rrb_rd_last),
     .rrb_ch_num                          (rrb_ch_num),
     .rrb_queue_type                      (rrb_queue),
     .e_rinfo                             (rrb_rinfo[RINFOW-1:0]),
     .e_rrb_rexa_acc_instr                (rrb_rexa_acc_instr),
     .e_rrb_rpoison                       (rrb_rpoison),
     .e_rrb_ocpar_err                     (rrb_ocpar_err),
     .e_rvalid                            (rrb_rvalid_up),
     .rqos_map_level1                     (rqos_map_level1),
     .rqos_map_level2                     (rqos_map_level2),
     .rqos_map_region0                    (rqos_map_region0),
     .rqos_map_region1                    (rqos_map_region1),
     .rqos_map_region2                    (rqos_map_region2),
     .rqos_map_timeoutb                   (rqos_map_timeoutb),
     .rqos_map_timeoutr                   (rqos_map_timeoutr),
     .reg_arb_base_addr_0                 (reg_base_addr_0),
     .reg_arb_nblocks_0                   (reg_nblocks_0),
     .reg_arb_base_addr_1                 (reg_base_addr_1),
     .reg_arb_nblocks_1                   (reg_nblocks_1),
     .reg_arb_base_addr_2                 (reg_base_addr_2),
     .reg_arb_nblocks_2                   (reg_nblocks_2),
     .reg_arb_base_addr_3                 (reg_base_addr_3),
     .reg_arb_oc_parity_type              (reg_arb_oc_parity_type),
     .reg_ddrc_oc_parity_type             (reg_ddrc_oc_parity_type),
     .par_addr_slverr_en                  (reg_arb_par_addr_slverr_en),
     .par_rdata_slverr_en                 (reg_arb_par_rdata_slverr_en),
     .oc_addr_parity_en                   (oc_addr_parity_en),
     .oc_data_parity_en                   (oc_rdata_parity_en),
     .reg_ddrc_par_poison_byte_num        (reg_ddrc_par_poison_byte_num),
     .reg_ddrc_ecc_type                   (reg_ddrc_ecc_type),     
     .reg_ddrc_occap_en                   (reg_ddrc_occap_en),
     .reg_arb_occap_arb_raq_poison_en    (reg_arb_occap_arb_raq_poison_en),
     .reg_arb_occap_arb_cmp_poison_seq       (reg_arb_occap_arb_cmp_poison_seq),
     .reg_arb_occap_arb_cmp_poison_parallel  (reg_arb_occap_arb_cmp_poison_parallel),
     .reg_arb_occap_arb_cmp_poison_err_inj   (reg_arb_occap_arb_cmp_poison_err_inj),
     .reg_ddrc_occap_arb_cmp_poison_seq       (reg_ddrc_occap_arb_cmp_poison_seq),
     .reg_ddrc_occap_arb_cmp_poison_parallel  (reg_ddrc_occap_arb_cmp_poison_parallel),
     .reg_ddrc_occap_arb_cmp_poison_err_inj   (reg_ddrc_occap_arb_cmp_poison_err_inj),
     .ocecc_en                            (ocecc_en),
     .ocecc_poison_en                     (ocecc_poison_egen_xpi_rd_out),
     .ocecc_poison_single                 (ocecc_poison_single),
     .ocecc_rdata_slverr_en               (ocecc_rdata_slverr_en),
     .rd_poison_en                        (rd_poison_en),
     .par_rdata_err_intr_clr              (par_rdata_err_intr_clr),
     .reg_ddrc_rd_poison_slverr_en        (reg_ddrc_rd_poison_slverr_en),
     .reg_ddrc_rd_poison_intr_en          (reg_ddrc_rd_poison_intr_en),
     .reg_ddrc_rd_poison_intr_clr         (reg_ddrc_rd_poison_intr_clr),
     .reg_arb_bypass_reorder              (reg_arb_bypass_reorder),
     .reg_arb_rrb_lock_threshold          (reg_arb_rrb_lock_threshold),
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((NUM_VIR_CH * ID_MAPW) - 1)' found in module 'DWC_ddr_umctl2_xpi'
//SJ: This coding style is acceptable and there is no plan to change it.
     .reg_arb_id_mask                     (reg_arb_id_mask[NUM_VIR_CH*ID_MAPW-1:0]),
     .reg_arb_id_value                    (reg_arb_id_value[NUM_VIR_CH*ID_MAPW-1:0]),
//spyglass enable_block SelfDeterminedExpr-ML
     .pagematch_addrmap_mask              (pagematch_addrmap_mask),
     .pagematch_en                        (reg_arb_rd_port_pagematch_en),
     .data_channel_addrmap_mask           (data_channel_addrmap_mask),
     .bg_or_bank_addrmap_mask             (bg_or_bank_addrmap_mask),
     .reg_arb_dch_density_ratio           (reg_arb_dch_density_ratio),
     .e_addr_max_loc                      (e_addr_max_loc),
     .e_addr_max_m1_loc                   (e_addr_max_m1_loc),  
     .e_addr_max_loc_addrmap_mask         (e_addr_max_loc_addrmap_mask),
     .e_addr_max_m1_loc_addrmap_mask      (e_addr_max_m1_loc_addrmap_mask),
     .dch_bit                             (dch_bit),
     .pre_arb_order_token                 (pre_arb_read_order_token[ORDER_TOKENW-1:0])
     );

  //--------------------------------------------------------------------------------
  //  Inline ECC info generation 
  //--------------------------------------------------------------------------------

   generate
   if (M_INLINE_ECC==1) begin: InlineECC_info_gen
      
      
      DWC_ddr_umctl2_xpi_iecc_info
      
      #(
         .M_ADDRW       (M_ADDRW),
         .REG_ID_WIDTH  (3),
         .BRW           (BRW),
         .ECC_H3_WIDTH  (ECC_H3_WIDTH),
         .ECC_RM_WIDTH  (ECC_RM_WIDTH),
         .ECC_RMG_WIDTH (ECC_RMG_WIDTH)
      )
      U_iecc_info_rd_blue
      (
         .addr_in             (xpi_araddr_blue_i),
         .ecc_region_map      (reg_ddrc_ecc_region_map),
         .ecc_region_map_granu(reg_ddrc_ecc_region_map_granu),
         .ecc_region_map_other(reg_ddrc_ecc_region_map_other),
         .reg_xpi_burst_rdwr  (reg_xpi_burst_rdwr),
         .h3_iecc_col_mask    (h3_iecc_col_mask),
         .ecc_en              (reg_xpi_ecc_mode_ie),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
         .ecc_blk_valid       (xpi_rd_iecc_blk_valid_blue),
         .ecc_blk_end         (xpi_rd_iecc_blk_end_blue) 
//spyglass enable_block W528
      );


      if (USE2RAQ==1) begin: araddr_red

         DWC_ddr_umctl2_xpi_iecc_info
         
         #(
            .M_ADDRW       (M_ADDRW),
            .REG_ID_WIDTH  (3),
            .BRW           (BRW),
            .ECC_H3_WIDTH  (ECC_H3_WIDTH),
            .ECC_RM_WIDTH  (ECC_RM_WIDTH),
            .ECC_RMG_WIDTH (ECC_RMG_WIDTH)
         )
         U_iecc_info_rd_red
         (
            .addr_in             (xpi_araddr_red_i),
            .ecc_region_map      (reg_ddrc_ecc_region_map),
            .ecc_region_map_granu(reg_ddrc_ecc_region_map_granu),
            .ecc_region_map_other(reg_ddrc_ecc_region_map_other),
            .reg_xpi_burst_rdwr  (reg_xpi_burst_rdwr),
            .h3_iecc_col_mask    (h3_iecc_col_mask),
            .ecc_en              (reg_xpi_ecc_mode_ie),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
            .ecc_blk_valid       (xpi_rd_iecc_blk_valid_red),
            .ecc_blk_end         (xpi_rd_iecc_blk_end_red)
//spyglass enable_block W528
         );

      end
      else begin: araddr_nred
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
         assign xpi_rd_iecc_blk_valid_red = 1'b0;
         assign xpi_rd_iecc_blk_end_red   = 1'b0;
//spyglass enable_block W528
      end


      DWC_ddr_umctl2_xpi_iecc_info
      
      #(
         .M_ADDRW       (M_ADDRW),
         .REG_ID_WIDTH  (3),
         .BRW           (BRW),
         .ECC_H3_WIDTH  (ECC_H3_WIDTH),
         .ECC_RM_WIDTH  (ECC_RM_WIDTH),
         .ECC_RMG_WIDTH (ECC_RMG_WIDTH)
      )
      U_iecc_info_wr
      (
         .addr_in             (xpi_wr_awaddr),
         .ecc_region_map      (reg_ddrc_ecc_region_map),
         .ecc_region_map_granu(reg_ddrc_ecc_region_map_granu),
         .ecc_region_map_other(reg_ddrc_ecc_region_map_other),
         .reg_xpi_burst_rdwr  (reg_xpi_burst_rdwr),
         .h3_iecc_col_mask    (h3_iecc_col_mask),
         .ecc_en              (reg_xpi_ecc_mode_ie),
         .ecc_blk_valid       (xpi_wr_iecc_blk_valid),
         .ecc_blk_end         (xpi_wr_iecc_blk_end) // not used
      );

   end
   else begin: nInline_ECC
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      assign xpi_rd_iecc_blk_valid_blue   = 1'b0;
      assign xpi_rd_iecc_blk_end_blue     = 1'b0;
      assign xpi_rd_iecc_blk_valid_red    = 1'b0;
      assign xpi_rd_iecc_blk_end_red      = 1'b0;
//spyglass enable_block W528
      assign xpi_wr_iecc_blk_valid        = 1'b0;
      assign xpi_wr_iecc_blk_end          = 1'b0;

   end
   endgenerate


  //--------------------------------------------------------------------------------
  //  AXI Read Reorder Buffer  
  //--------------------------------------------------------------------------------
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
  generate
   if (RRB_EXTRAM==1) begin: EXT_ram_inout

      assign rrb_d_dca   = cnvg_hif_rdata_dca;
      assign rrb_par_d_dca   = cnvg_hif_rdata_parity_dca;
      assign rrb_rdata_dca  = rrb_q_int_dca;
      assign rrb_rdata_parity_dca        = rrb_par_q_int_dca;

      if (DUAL_CHANNEL_INTERLEAVE==1) begin: Dual_DCH_1

         assign rrb_d_dcb       = cnvg_hif_rdata_dcb;
         assign rrb_par_d_dcb   = cnvg_hif_rdata_parity_dcb;

         assign rrb_rdata_dcb  = rrb_q_int_dcb;
         assign rrb_rdata_parity_dcb        = rrb_par_q_int_dcb;

      end
      else begin: Single_DCH

         assign rrb_d_dcb              = {RDATARAM_DW_INT{1'b0}};
         assign rrb_par_d_dcb          = {DATARAM_PAR_DW{1'b0}};

         assign rrb_rerror_r_dcb       = 1'b0;
         assign rrb_rerror_i_dcb       = 1'b0;
         assign rrb_rdata_dcb          = {A_DW{1'b0}};
         assign rrb_rdata_parity_dcb   = {A_STRBW{1'b0}};

      end
   end
   else begin: INT_ram_inout
   
      assign rrb_par_d_dca    = {DATARAM_PAR_DW{1'b0}};
      assign rrb_rerror_r_dcb = 1'b0;
      assign rrb_rerror_i_dcb = 1'b0;
      assign rrb_rdata_dcb    = {A_DW{1'b0}};
      assign rrb_rdata_parity_dcb   = {A_STRBW{1'b0}};
      assign rrb_d_dcb              = {RDATARAM_DW_INT{1'b0}};
      assign rrb_par_d_dcb          = {DATARAM_PAR_DW{1'b0}};

      if (OCPAR_EN==1 || OCECC_EN==1) begin: OC_par_en_2
         // when internal ram, pack the parity together with the data
         assign rrb_d_dca           = {cnvg_hif_rdata_parity_dca,cnvg_hif_rdata_dca};
         assign {rrb_rdata_parity_dca,rrb_rdata_dca}  = rrb_q_int_dca;
      end
      else begin: OC_par_nen
         assign rrb_d_dca   = cnvg_hif_rdata_dca;
         assign rrb_rdata_dca  = rrb_q_int_dca;
         assign rrb_rdata_parity_dca = {A_STRBW{1'b0}};
      end
   end
  endgenerate
//spyglass enable_block W528

  generate
    if (RRB_EXTRAM==1 && RRB_EXTRAM_REG==1) begin: GEN_re_gistered_ext_ram //_re_gistered to prevent getting into collection *_reg* in DC scripts 

      wire rrb_sync_empty_dca, rrb_sync_full_dca;
      wire rrb_sync_empty_dca_unused, rrb_sync_full_dca_unused;
      wire [RDATARAM_DW_INT-1:0]        rrb_q_retime;
      wire [DATARAM_PAR_DW-1:0]         rrb_par_q_retime_dca;

      assign rrb_q_int_dca       = rrb_q_retime;
      assign rrb_par_q_int_dca   = rrb_par_q_retime_dca;
      assign rdataram_din        = rrb_d_dca;
      assign rdataram_din_par    = rrb_par_d_dca;
      assign rdataram_wr         = rrb_wr_dca;
      assign rdataram_re         = ~rrb_empty_dca & ~rrb_sync_full_dca;
      assign rdataram_raddr      = rrb_rdataram_raddr_dca;
      assign rdataram_waddr      = rrb_rdataram_waddr_dca;

      if (OCPAR_EN==1 || OCECC_EN==1) begin: OC_par_en_3
      
          wire par_rrb_sync_full_dca_unused, par_rrb_sync_empty_dca_unused;
 
         if (RRB_EXTRAM_RETIME==1) begin : GEN_retimed_outputs_1
             DWC_ddr_umctl2_retime_b
              #(DATARAM_PAR_DW)
                 U_xpi_rrb_sync_parity (
                     // Outputs
                     .q              (rrb_par_q_retime_dca[DATARAM_PAR_DW-1:0]),
                     .fe             (par_rrb_sync_empty_dca_unused),
                     .ff             (par_rrb_sync_full_dca_unused),
                     // Inputs
                     .clk            (e_clk),
                     .rst_n          (e_rst_n),
                     .d              (rdataram_dout_par[DATARAM_PAR_DW-1:0]),
                     .wr             (rdataram_re_d1),
                     .rd             (rrb_rd_dca)); 

         end else begin : GEN_retimed_outputs_nen_1
             DWC_ddr_umctl2_retime_a
              #(DATARAM_PAR_DW)
             U_xpi_rrb_sync_parity (
                                  // Outputs
                                  .q              (rrb_par_q_retime_dca[DATARAM_PAR_DW-1:0]),
                                  .fe             (par_rrb_sync_empty_dca_unused),
                                  .ff             (par_rrb_sync_full_dca_unused),
                                  // Inputs
                                  .clk            (e_clk),
                                  .rst_n          (e_rst_n),
                                  .d              (rdataram_dout_par[DATARAM_PAR_DW-1:0]),
                                  .wr             (rdataram_re),
                                  .rd             (rrb_rd_dca));
         end //GEN_retimed_outputs_nen

      end // OC_par_en
      else begin: OC_par_nen
         assign rrb_par_q_retime_dca = {DATARAM_PAR_DW{1'b0}};
      end // OC_par_nen

      
      wire  [RRBRIW-1:0]   rrb_sync_info_d_dca;
      wire                 rrb_sync_info_wr;
      if (RRB_EXTRAM_RETIME==1) begin : GEN_retimed_outputs_2

          //retime to account for sync SRAM output
          always @(posedge e_clk or negedge e_rst_n) begin: rdataram_re_d1_PROC
              if (e_rst_n == 1'b0) begin 
                  rdataram_re_d1 <= 1'b0;
                  rrb_sync_d_retime_dca <= {RRBRIW{1'h0}};
              end else begin
                  rdataram_re_d1 <= rdataram_re;
                  rrb_sync_d_retime_dca <= rrb_sync_d_dca;
              end  
          end          
          assign rrb_sync_info_d_dca = rrb_sync_d_retime_dca; 
          assign rrb_sync_info_wr = rdataram_re_d1;
          
          DWC_ddr_umctl2_retime_b
           #(RDATARAM_DW)
              U_xpi_rrb_sync_data (
                  // Outputs
                  .q              (rrb_q_retime[RDATARAM_DW-1:0]),
                  .fe             (rrb_sync_empty_dca),
                  .ff             (rrb_sync_full_dca),
                  // Inputs
                  .clk            (e_clk),
                  .rst_n          (e_rst_n),
                  .d              (rdataram_dout[RDATARAM_DW-1:0]),
                  .wr             (rdataram_re_d1),
                  .rd             (rrb_rd_dca));    
          
      end else begin :   GEN_retimed_outputs_nen_2
          DWC_ddr_umctl2_retime_a
           #(RDATARAM_DW)
          U_xpi_rrb_sync_data (
                               // Outputs
                               .q              (rrb_q_retime[RDATARAM_DW-1:0]),
                               .fe             (rrb_sync_empty_dca),
                               .ff             (rrb_sync_full_dca),
                               // Inputs
                               .clk            (e_clk),
                               .rst_n          (e_rst_n),
                               .d              (rdataram_dout[RDATARAM_DW-1:0]),
                               .wr             (rdataram_re),
                               .rd             (rrb_rd_dca));
          assign rrb_sync_info_d_dca = rrb_sync_d_dca; 
          assign rrb_sync_info_wr = rdataram_re;
     end //   GEN_retimed_outputs_nen_2
      
      DWC_ddr_umctl2_retime
      
      #(
         .SIZE    (RRBRIW),
         .OCCAP_EN(OCCAP_EN),
         .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
       )
      U_xpi_rrb_sync_info (
                           // Outputs
                           .q              (rrb_sync_q_dca),
                           .fe             (rrb_sync_empty_dca_unused),
                           .ff             (rrb_sync_full_dca_unused),
                           .par_err        (occap_xpi_sync_info_par_err),
                           // Inputs
                           .clk            (e_clk),
                           .rst_n          (e_rst_n),
                           .d              (rrb_sync_info_d_dca),                           
                           .wr             (rrb_sync_info_wr),
                           .rd             (rrb_rd_dca),
                           .par_en         (reg_ddrc_occap_en));

      assign rrb_rd_i_dca           = ~rrb_sync_full_dca;
      assign rrb_rid_dca            = rrb_rid_r_dca;
      assign rrb_rinfo_dca          = rrb_rinfo_r_dca;
      assign rrb_ruser_dca          = rrb_ruser_r_dca;
      assign rrb_queue_dca          = rrb_queue_r_dca;
      assign rrb_rpoison_dca        = rrb_rpoison_r_dca;
      assign rrb_ocpar_err_dca      = rrb_ocpar_err_r_dca;
      assign rrb_rexa_acc_instr_dca = rrb_rexa_acc_instr_r_dca;

      if (DUAL_CHANNEL_INTERLEAVE==1) begin: Dual_DCH_2
         // DATA CHANNEL INTERLEAVING enabled
         wire rrb_sync_empty_dcb, rrb_sync_full_dcb;
         wire rrb_sync_empty_dcb_unused, rrb_sync_full_dcb_unused;
         wire [DATARAM_PAR_DW-1:0] rrb_par_q_retime_dcb;
         wire acc_empty_dca, acc_empty_dcb;
         wire acc_full_dca, acc_full_dcb;
         wire acc_rd_dca, acc_rd_dcb;
         wire rrb_rd_i, rrb_rready_dca, rrb_rready_dcb;
         wire acc_wr_dca, acc_wr_dcb;
         wire acc_last_dca, acc_last_dcb;

         wire [RDRDW-1:0]        rdata_err_rdr, rdr_rdata_err;
         wire [RDRW-1:0]         rinfo_rdr, rdr_rinfo;
         wire [NUM_DATA_CHANNELS-1:0]                  rdr_rrb_rerror;
         wire [AXI_IDW-1:0]      rdr_rrb_rid;
         wire                    rdr_rrb_rd_last;
         wire [AXI_USERW-1:0]    rdr_rrb_ruser;
         wire [NUM_CH_LG2-1:0]   rdr_rrb_ch_num;
         wire                    rdr_rrb_queue;
         wire                    rdr_rrb_rexa_acc_instr;
         wire                    rdr_rrb_rpoison;
         wire                    rdr_rrb_ocpar_err;
         wire [RINFOW-1:0]       rdr_rrb_rinfo;
         wire [A_DW_INT-1:0]     rdr_rrb_rdata;
         wire [A_STRBW_INT-1:0]  rdr_rrb_rdata_parity;
         wire [RRBDPW-1:0]       rrb_data_pack_dca, rrb_data_pack_dcb, rrb_data_pack_mux, rrb_data_pack_mux_dca, rrb_data_pack_mux_dcb;

         // data flow
         // extRAM retime -> accumulators -> channel FIFO (only if HIF beats > 2) -> mux (arbitration done by xpi_dcr) -> rdr retime (optional)

         // dataram 2nd channel control signals
         assign rrb_q_int_dcb        = rrb_q_retime_dcb;
         assign rrb_par_q_int_dcb    = rrb_par_q_retime_dcb;
         assign rdataram_din_dcb     = rrb_d_dcb;
         assign rdataram_din_par_dcb = rrb_par_d_dcb;
         assign rdataram_wr_dcb      = rrb_wr_dcb;
         assign rdataram_re_dcb      = ~rrb_empty_dcb & ~rrb_sync_full_dcb;
         assign rdataram_raddr_dcb   = rrb_rdataram_raddr_dcb;
         assign rdataram_waddr_dcb   = rrb_rdataram_waddr_dcb;

         // retime for ocpar (not supported)
         if (OCPAR_EN==1) begin: OC_par_en_4
              wire par_rrb_sync_full_dcb_unused, par_rrb_sync_empty_dcb_unused;

            if (RRB_EXTRAM_RETIME==1) begin : GEN_retimed_outputs_3
                DWC_ddr_umctl2_retime_b
                 #(DATARAM_PAR_DW)
                    U_xpi_rrb_sync_parity (
                        // Outputs
                        .q              (rrb_par_q_retime_dcb[DATARAM_PAR_DW-1:0]),
                        .fe             (par_rrb_sync_empty_dcb_unused),
                        .ff             (par_rrb_sync_full_dcb_unused),
                        // Inputs
                        .clk            (e_clk),
                        .rst_n          (e_rst_n),
                        .d              (rdataram_dout_par_dcb[DATARAM_PAR_DW-1:0]),
                        .wr             (rdataram_re_dcb_d1),
                        .rd             (rrb_rd_dcb));                
            end else begin : GEN_retimed_outputs_nen    
              DWC_ddr_umctl2_retime_a
               #(DATARAM_PAR_DW)
              U_xpi_rrb_sync_parity (
                                   // Outputs
                                   .q              (rrb_par_q_retime_dcb[DATARAM_PAR_DW-1:0]),
                                   .fe             (par_rrb_sync_empty_dcb_unused),
                                   .ff             (par_rrb_sync_full_dcb_unused),
                                   // Inputs
                                   .clk            (e_clk),
                                   .rst_n          (e_rst_n),
                                   .d              (rdataram_dout_par_dcb[DATARAM_PAR_DW-1:0]),
                                   .wr             (rdataram_re_dcb),
                                   .rd             (rrb_rd_dcb));

            end // GEN_retimed_outputs_nen

         end // OC_par_en
         else begin: OC_par_nen
            assign rrb_par_q_retime_dcb = {DATARAM_PAR_DW{1'b0}};
         end // OC_par_nen
         // retime for channel 1
         // data
        wire  [RRBRIW-1:0]   rrb_sync_info_d_dcb;
        wire                 rrb_sync_info_wr_dcb;
         if (RRB_EXTRAM_RETIME==1) begin : GEN_retimed_outputs_4
             //retime to account for sync SRAM output
             always @(posedge e_clk or negedge e_rst_n) begin: rdataram_re_dcb_d1_PROC
                 if (e_rst_n == 1'b0) begin
                     rdataram_re_dcb_d1 <= 1'b0;
                     rrb_sync_d_retime_dcb <= {RRBRIW{1'h0}};
                 end else begin
                     rdataram_re_dcb_d1 <= rdataram_re_dcb;
                     rrb_sync_d_retime_dcb <= rrb_sync_d_dcb;
                 end
             end
             
             assign rrb_sync_info_d_dcb = rrb_sync_d_retime_dcb; 
             assign rrb_sync_info_wr_dcb = rdataram_re_dcb_d1;
             
             DWC_ddr_umctl2_retime_b
              #(RDATARAM_DW)
                 U_xpi_rrb_sync_data (
                     // Outputs
                     .q              (rrb_q_retime_dcb[RDATARAM_DW-1:0]),
                     .fe             (rrb_sync_empty_dcb),
                     .ff             (rrb_sync_full_dcb),
                     // Inputs
                     .clk            (e_clk),
                     .rst_n          (e_rst_n),
                     .d              (rdataram_dout_dcb[RDATARAM_DW-1:0]),
                     .wr             (rdataram_re_dcb_d1),
                     .rd             (rrb_rd_dcb));
             
         end else begin :    GEN_retimed_outputs_nen_4
           
             DWC_ddr_umctl2_retime_a
              #(RDATARAM_DW)
              U_xpi_rrb_sync_data (
                                   // Outputs
                                   .q              (rrb_q_retime_dcb[RDATARAM_DW-1:0]),
                                   .fe             (rrb_sync_empty_dcb),
                                   .ff             (rrb_sync_full_dcb),
                                   // Inputs
                                   .clk            (e_clk),
                                   .rst_n          (e_rst_n),
                                   .d              (rdataram_dout_dcb[RDATARAM_DW-1:0]),
                                   .wr             (rdataram_re_dcb),
                                   .rd             (rrb_rd_dcb));
             
             assign rrb_sync_info_d_dcb = rrb_sync_d_dcb; 
             assign rrb_sync_info_wr_dcb = rdataram_re_dcb;
         end //   GEN_retimed_outputs_nen_4
          // info
          DWC_ddr_umctl2_retime
           
          #(
            .SIZE    (RRBRIW),
            .OCCAP_EN(OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
          )
          U_xpi_rrb_sync_info (
                               // Outputs
                               .q              (rrb_sync_q_dcb),
                               .fe             (rrb_sync_empty_dcb_unused),
                               .ff             (rrb_sync_full_dcb_unused),
                               .par_err        (occap_xpi_sync_info_dcb_par_err),
                               // Inputs
                               .clk            (e_clk),
                               .rst_n          (e_rst_n),
                               .d              (rrb_sync_info_d_dcb),                           
                               .wr             (rrb_sync_info_wr_dcb),
                               .rd             (rrb_rd_dcb),
                               .par_en         (reg_ddrc_occap_en));

            
            assign rrb_rd_i_dcb            = ~rrb_sync_full_dcb;
            assign rrb_rid_dcb             = rrb_rid_r_dcb;
            assign rrb_rinfo_dcb           = rrb_rinfo_r_dcb;
            assign rrb_ruser_dcb           = rrb_ruser_r_dcb;
            assign rrb_queue_dcb           = rrb_queue_r_dcb;
            assign rrb_rpoison_dcb         = rrb_rpoison_r_dcb;
            assign rrb_ocpar_err_dcb       = rrb_ocpar_err_r_dcb;
            assign rrb_rexa_acc_instr_dcb  = rrb_rexa_acc_instr_r_dcb;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
            // retime in
            assign rrb_sync_d_dcb   = {rrb_ch_num_i_dcb,rrb_rd_last_i_dcb,rrb_rexa_acc_instr_i_dcb,rrb_rpoison_i_dcb,rrb_ocpar_err_i_dcb,rrb_ruser_i_dcb,rrb_queue_i_dcb,rrb_rinfo_i_dcb,rrb_rid_i_dcb,rrb_token_dcb,rrb_rerror_i_dcb};
            assign rrb_sync_d_dca   = {rrb_ch_num_i_dca,rrb_rd_last_i_dca,rrb_rexa_acc_instr_i_dca,rrb_rpoison_i_dca,rrb_ocpar_err_i_dca,rrb_ruser_i_dca,rrb_queue_i_dca,rrb_rinfo_i_dca,rrb_rid_i_dca,rrb_token_dca,rrb_rerror_i_dca};
            // retime out
            assign {rrb_ch_num_dcb,rrb_rd_last_dcb,rrb_rexa_acc_instr_r_dcb,rrb_rpoison_r_dcb,rrb_ocpar_err_r_dcb,rrb_ruser_r_dcb,rrb_queue_r_dcb,rrb_rinfo_r_dcb,rrb_rid_r_dcb,rrb_token_i_dcb,rrb_rerror_r_dcb} = rrb_sync_q_dcb;
            assign {rrb_ch_num_dca,rrb_rd_last_dca,rrb_rexa_acc_instr_r_dca,rrb_rpoison_r_dca,rrb_ocpar_err_r_dca,rrb_ruser_r_dca,rrb_queue_r_dca,rrb_rinfo_r_dca,rrb_rid_r_dca,rrb_token_i_dca,rrb_rerror_r_dca} = rrb_sync_q_dca;
//spyglass enable_block W528

            if (DUAL_CHANNEL_INTERLEAVE_HP==1) begin: INTLV_native_size_2

               wire [A_DW-1:0]         acc_data_in_dca, acc_data_in_dcb;
               wire [A_STRBW-1:0]      acc_parity_in_dca, acc_parity_in_dcb;
               wire [A_DW_INT-1:0]     acc_data_out_dca, acc_data_out_dcb;
               wire [A_STRBW_INT-1:0]  acc_parity_out_dca, acc_parity_out_dcb;
               wire [ACC_INFOW-1:0]    acc_info_dca, acc_info_dcb;
               wire                    acc_rerror_in_dca, acc_rerror_in_dcb; 
               wire [NUM_DATA_CHANNELS-1:0] acc_rerror_out_dca, acc_rerror_out_dcb;
               wire                    acc_rexa_acc_in_dca, acc_rexa_acc_in_dcb, acc_rexa_acc_out_dca, acc_rexa_acc_out_dcb;
               wire                    acc_poison_in_dca, acc_poison_in_dcb, acc_poison_out_dca, acc_poison_out_dcb;
               wire                    acc_ocpar_err_in_dca, acc_ocpar_err_in_dcb, acc_ocpar_err_out_dca, acc_ocpar_err_out_dcb;

               wire [A_DW_INT-1:0]     rrb_rdata_up_dca, rrb_rdata_up_dcb;
               wire [A_STRBW_INT-1:0]  rrb_rdata_parity_up_dca, rrb_rdata_parity_up_dcb;
               wire [NUM_DATA_CHANNELS-1:0] rrb_rerror_up_dca, rrb_rerror_up_dcb;
               wire rrb_rpoison_up_dca, rrb_rpoison_up_dcb;
               wire rrb_ocpar_err_up_dca, rrb_ocpar_err_up_dcb;
               wire rrb_rexa_acc_instr_up_dca, rrb_rexa_acc_instr_up_dcb;

               // data accumulators after extRAM retime
               // accumulator info
               assign acc_info_dca        = rrb_rinfo_dca[RINFOW-1:RINFOW_NSA];
               assign acc_info_dcb        = rrb_rinfo_dcb[RINFOW-1:RINFOW_NSA];
               // accumulator data
               assign acc_data_in_dca     = rrb_rdata_dca;
               assign acc_data_in_dcb     = rrb_rdata_dcb;
               assign acc_rerror_in_dca   = rrb_rerror_r_dca;
               assign acc_rerror_in_dcb   = rrb_rerror_r_dcb;
               assign acc_poison_in_dca   = rrb_rpoison_dca;
               assign acc_poison_in_dcb   = rrb_rpoison_dcb; 
               assign acc_ocpar_err_in_dca= rrb_ocpar_err_dca;
               assign acc_ocpar_err_in_dcb= rrb_ocpar_err_dcb;
               assign acc_parity_in_dca   = rrb_rdata_parity_dca;
               assign acc_parity_in_dcb   = rrb_rdata_parity_dcb;
               assign acc_rexa_acc_in_dca = rrb_rexa_acc_instr_dca;
               assign acc_rexa_acc_in_dcb = rrb_rexa_acc_instr_dcb;
               // accumulator control signals (push)
               assign acc_wr_dca          = ~rrb_sync_empty_dca;
               assign acc_wr_dcb          = ~rrb_sync_empty_dcb;
               assign acc_last_dca        = rrb_rd_last_dca;
               assign acc_last_dcb        = rrb_rd_last_dcb;
               // back pressure from accumulator
               assign rrb_rd_dca          = ~acc_full_dca;
               assign rrb_rd_dcb          = ~acc_full_dcb;
               // channel 0 accumulator (data upsizer)
               DWC_ddr_umctl2_xpi_acc
               
               #( .DW_IN         (A_DW),
                  .PW_IN         (A_STRBW),
                  .DW_OUT        (A_DW_INT),
                  .PW_OUT        (A_STRBW_INT),
                  .INFOW         (ACC_INFOW),
                  .AXI_MAXSIZE   (AXI_MAXSIZE),
                  .OUT_MAXSIZE   (ENIF_MAXSIZE_INT),
                  .OUT_SIZEW     (ENIF_SIZEW_INT),
                  .IN_MAXSIZE    (ENIF_MAXSIZE),
                  .IN_SIZEW      (ENIF_SIZEW))
               U_xpi_rrb_data_acc_dca
               (
                  .clk           (e_clk),
                  .rst_n         (e_rst_n),
                  .rst_dly       (e_rst_dly),
                  .parity_type   (reg_ddrc_oc_parity_type),
                  .data_in       (acc_data_in_dca),
                  .parity_in     (acc_parity_in_dca),
                  .rerror_in     (acc_rerror_in_dca),
                  .rexa_acc_in   (acc_rexa_acc_in_dca),
                  .poison_in     (acc_poison_in_dca),
                  .ocpar_err_in  (acc_ocpar_err_in_dca),
                  .wr            (acc_wr_dca),
                  .rd            (acc_rd_dca),
                  .last          (acc_last_dca),
                  .info          (acc_info_dca),
                  // outputs
                  .empty         (acc_empty_dca),
                  .full          (acc_full_dca),
                  .data_out      (acc_data_out_dca),
                  .parity_out    (acc_parity_out_dca),
                  .rerror_out    (acc_rerror_out_dca),
                  .rexa_acc_out  (acc_rexa_acc_out_dca),
                  .poison_out    (acc_poison_out_dca),
                  .ocpar_err_out (acc_ocpar_err_out_dca)
               );
               // channel 1 accumulator (data upsizer)
               DWC_ddr_umctl2_xpi_acc
               
               #( .DW_IN         (A_DW),
                  .PW_IN         (A_STRBW),
                  .DW_OUT        (A_DW_INT),
                  .PW_OUT        (A_STRBW_INT),
                  .INFOW         (ACC_INFOW),
                  .AXI_MAXSIZE   (AXI_MAXSIZE),
                  .OUT_MAXSIZE   (ENIF_MAXSIZE_INT),
                  .OUT_SIZEW     (ENIF_SIZEW_INT),
                  .IN_MAXSIZE    (ENIF_MAXSIZE),
                  .IN_SIZEW      (ENIF_SIZEW))
               U_xpi_rrb_data_acc_dcb
               (
                  .clk           (e_clk),
                  .rst_n         (e_rst_n),
                  .parity_type   (reg_ddrc_oc_parity_type),
                  .rst_dly       (e_rst_dly),
                  .data_in       (acc_data_in_dcb),
                  .parity_in     (acc_parity_in_dcb),
                  .rerror_in     (acc_rerror_in_dcb),
                  .rexa_acc_in   (acc_rexa_acc_in_dcb),
                  .poison_in     (acc_poison_in_dcb),
                  .ocpar_err_in  (acc_ocpar_err_in_dcb),
                  .wr            (acc_wr_dcb),
                  .rd            (acc_rd_dcb),
                  .last          (acc_last_dcb),
                  .info          (acc_info_dcb),
                  // outputs
                  .empty         (acc_empty_dcb),
                  .full          (acc_full_dcb),
                  .data_out      (acc_data_out_dcb),
                  .parity_out    (acc_parity_out_dcb),
                  .rerror_out    (acc_rerror_out_dcb),
                  .rexa_acc_out  (acc_rexa_acc_out_dcb),
                  .poison_out    (acc_poison_out_dcb),
                  .ocpar_err_out (acc_ocpar_err_out_dcb)
               );

               // accumulator data upsized
               assign rrb_rdata_up_dca          = acc_data_out_dca;
               assign rrb_rdata_up_dcb          = acc_data_out_dcb;
               assign rrb_rdata_parity_up_dca   = acc_parity_out_dca;
               assign rrb_rdata_parity_up_dcb   = acc_parity_out_dcb;
               assign rrb_rerror_up_dca         = acc_rerror_out_dca;
               assign rrb_rerror_up_dcb         = acc_rerror_out_dcb;
               assign rrb_rpoison_up_dca        = acc_poison_out_dca; 
               assign rrb_rpoison_up_dcb        = acc_poison_out_dcb;
               assign rrb_ocpar_err_up_dca      = acc_ocpar_err_out_dca;
               assign rrb_ocpar_err_up_dcb      = acc_ocpar_err_out_dcb;
               assign rrb_rexa_acc_instr_up_dca = acc_rexa_acc_out_dca;
               assign rrb_rexa_acc_instr_up_dcb = acc_rexa_acc_out_dcb;


               // data + info channel 0 and 1
               assign rrb_data_pack_dca   = {rrb_rdata_up_dca,rrb_rerror_up_dca,rrb_rdata_parity_up_dca,rrb_rid_dca,rrb_rd_last_dca,rrb_ch_num_dca,rrb_ruser_dca,rrb_queue_dca,rrb_rinfo_dca,rrb_rexa_acc_instr_up_dca,rrb_rpoison_up_dca,rrb_ocpar_err_up_dca};
               assign rrb_data_pack_dcb   = {rrb_rdata_up_dcb,rrb_rerror_up_dcb,rrb_rdata_parity_up_dcb,rrb_rid_dcb,rrb_rd_last_dcb,rrb_ch_num_dcb,rrb_ruser_dcb,rrb_queue_dcb,rrb_rinfo_dcb,rrb_rexa_acc_instr_up_dcb,rrb_rpoison_up_dcb,rrb_ocpar_err_up_dcb};

               if (DEACC_RT_W>1) begin: DCH_rd_fifo
                  // Instantiate FIFOs after the accumulators if number of beats at the HIF is greater than 2
                  // This is to buffer the upsized data and achieve 100% utilization even when the channels can't switch every 2 beats (no ping-pong)
                  wire dca_wr, dca_rd, dca_full, dca_empty;
                  wire dcb_wr, dcb_rd, dcb_full, dcb_empty;
                  wire [DEACC_RT_W_LG2+1-1:0] dca_wcount_unused, dcb_wcount_unused;

                  wire [RRBRTDPW-1:0] dca_d, dca_q, dcb_d, dcb_q;

                  // placeholders, not used
                  wire [A_DW_INT-1:0]              rrb_rdata_mux_dca, rrb_rdata_mux_dcb;
                  wire [A_STRBW_INT-1:0]           rrb_rdata_parity_mux_dca, rrb_rdata_parity_mux_dcb;
                  wire [NUM_DATA_CHANNELS-1:0]     rrb_rerror_mux_dca, rrb_rerror_mux_dcb;                
                  wire                             rrb_rexa_acc_instr_mux_dca, rrb_rexa_acc_instr_mux_dcb;
                  wire                             rrb_rpoison_mux_dca, rrb_rpoison_mux_dcb;
                  wire                             rrb_ocpar_err_mux_dca, rrb_ocpar_err_mux_dcb;
                  wire                             rrb_queue_mux_dca, rrb_queue_mux_dcb;
                  wire [RINFOW-1:0]                rrb_rinfo_mux_dca, rrb_rinfo_mux_dcb;
                  wire [AXI_IDW-1:0]               rrb_rid_mux_dca, rrb_rid_mux_dcb;
                  wire [AXI_USERW-1:0]             rrb_ruser_mux_dca, rrb_ruser_mux_dcb;

                  // token to dcr
                  wire [MEMC_NO_OF_ENTRY_LG2-1:0]  rrb_token_mux_dca, rrb_token_mux_dcb;

                  // extracted information from rrb_data_pack_mux
                  wire [NUM_CH_LG2-1:0]            rrb_ch_num_mux_dca, rrb_ch_num_mux_dcb;
                  wire                             rrb_rd_last_mux_dca, rrb_rd_last_mux_dcb;


                  assign dca_d                  = {rrb_data_pack_dca,rrb_token_i_dca};
                  assign dcb_d                  = {rrb_data_pack_dcb,rrb_token_i_dcb};
                  assign dca_wr                 = ~acc_empty_dca & ~dca_full;
                  assign dcb_wr                 = ~acc_empty_dcb & ~dcb_full;
                  assign dca_rd                 = rrb_rready_dca;
                  assign dcb_rd                 = rrb_rready_dcb;

                  assign {rrb_data_pack_mux_dca,rrb_token_mux_dca}  = dca_q;
                  assign {rrb_data_pack_mux_dcb,rrb_token_mux_dcb}  = dcb_q;

                  //spyglass disable_block W528
                  //SMD: Variable set but not read
                  //SJ: Used in generate block or unused but kept to decode rrb_data_pack_mux_dca/rrb_data_pack_mux_dcb
                                    
                  // unpack rrb_data_pack_mux_dcx to get ch_num and last info, all other fields are not used
                  assign {rrb_rdata_mux_dca,rrb_rerror_mux_dca,rrb_rdata_parity_mux_dca,rrb_rid_mux_dca,rrb_rd_last_mux_dca,rrb_ch_num_mux_dca,rrb_ruser_mux_dca,rrb_queue_mux_dca,rrb_rinfo_mux_dca,rrb_rexa_acc_instr_mux_dca,rrb_rpoison_mux_dca,rrb_ocpar_err_mux_dca} = rrb_data_pack_mux_dca;
                  assign {rrb_rdata_mux_dcb,rrb_rerror_mux_dcb,rrb_rdata_parity_mux_dcb,rrb_rid_mux_dcb,rrb_rd_last_mux_dcb,rrb_ch_num_mux_dcb,rrb_ruser_mux_dcb,rrb_queue_mux_dcb,rrb_rinfo_mux_dcb,rrb_rexa_acc_instr_mux_dcb,rrb_rpoison_mux_dcb,rrb_ocpar_err_mux_dcb} = rrb_data_pack_mux_dcb;
                  //spyglass enable_block W528
                  
                  // Channel 0 read FIFO
                  DWC_ddr_umctl2_gfifo
                          
                  #(
                     .WIDTH           (RRBRTDPW),
                     .DEPTH           (DEACC_RT_W),
                     .ADDR_WIDTH      (DEACC_RT_W_LG2),
                     .COUNT_WIDTH     (DEACC_RT_W_LG2+1),
                     .OCCAP_EN        (OCCAP_EN),
                     .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
                  ) 
                  U_dca_rd_fifo (
                     .clk             (e_clk),
                     .rst_n           (e_rst_n),
                     .wr              (dca_wr),
                     .d               (dca_d),
                     .rd              (dca_rd),
                     .par_en          (reg_ddrc_occap_en),
                     .init_n          (1'b1),
                     .ff              (dca_full),
                     .wcount          (dca_wcount_unused),
                     .q               (dca_q),
                     .fe              (dca_empty),
                     .par_err         (occap_dca_rd_par_err)
                    `ifdef SNPS_ASSERT_ON
                    `ifndef SYNTHESIS
                    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~dca_empty
                    ,.disable_sva_fifo_checker_wr (1'b0)
                    `endif // SYNTHESIS
                    `endif // SNPS_ASSERT_ON
                  );

                  // Channel 1 read FIFO
                  DWC_ddr_umctl2_gfifo
                          
                  #(
                     .WIDTH           (RRBRTDPW),
                     .DEPTH           (DEACC_RT_W),
                     .ADDR_WIDTH      (DEACC_RT_W_LG2),
                     .COUNT_WIDTH     (DEACC_RT_W_LG2+1),
                     .OCCAP_EN        (OCCAP_EN),
                     .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
                  ) 
                  U_dcb_rd_fifo (
                     .clk             (e_clk),
                     .rst_n           (e_rst_n),
                     .wr              (dcb_wr),
                     .d               (dcb_d),
                     .rd              (dcb_rd),
                     .par_en          (reg_ddrc_occap_en),
                     .init_n          (1'b1),
                     .ff              (dcb_full),
                     .wcount          (dcb_wcount_unused),
                     .q               (dcb_q),
                     .fe              (dcb_empty),
                     .par_err         (occap_dcb_rd_par_err)
                    `ifdef SNPS_ASSERT_ON
                    `ifndef SYNTHESIS
                    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~dcb_empty
                    ,.disable_sva_fifo_checker_wr (1'b0)
                    `endif // SYNTHESIS
                    `endif // SNPS_ASSERT_ON
                  );


                  // accumulator control signals (pop)
                  assign acc_rd_dca          = ~dca_full;
                  assign acc_rd_dcb          = ~dcb_full;
                  // channel output valid
                  assign rrb_rvalid_dca      = ~dca_empty;
                  assign rrb_rvalid_dcb      = ~dcb_empty;
                  // dcr inputs
                  assign dcr_rd_last_dca     = rrb_rd_last_mux_dca;
                  assign dcr_rd_last_dcb     = rrb_rd_last_mux_dcb;
                  assign dcr_ch_num_dca      = rrb_ch_num_mux_dca;
                  assign dcr_ch_num_dcb      = rrb_ch_num_mux_dcb;
                  assign dcr_token_dca       = rrb_token_mux_dca;
                  assign dcr_token_dcb       = rrb_token_mux_dcb;
                  // DCR control (output side)
                  assign dcr_rvalid_dca      = rrb_rvalid_dca;
                  assign dcr_rvalid_dcb      = rrb_rvalid_dcb;
                  assign dcr_rd              = rrb_rd_i;


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  cp_dca_rd_fifo_full :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       dca_full==1'b1 && ~acc_empty_dca
    );

   cp_dcb_rd_fifo_full :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       dcb_full==1'b1 && ~acc_empty_dcb
    );

    cp_dca_dcb_rd_fifo_full :
    cover property (
       @(posedge e_clk) disable iff(!e_rst_n)
       dca_full==1'b1 && dcb_full==1'b1 && (~acc_empty_dca || ~acc_empty_dcb)
    );

    assert_never #(0, 0, "Write to Channel 0 read FIFO when full", 5) a_xpi_dca_rd_fifo_full (e_clk, e_rst_n, (dca_full && dca_wr));
    assert_never #(0, 0, "Write to Channel 1 read FIFO when full", 5) a_xpi_dcb_rd_fifo_full (e_clk, e_rst_n, (dcb_full && dcb_wr));

`endif
`endif

               end // if (DEACC_RT_W>1)
               else begin: DCH_rd_nfifo
                  // 2 beats or less at the HIF, no need for buffering
                  // Forward accumulator data directly to xpi_df

                  // accumulator control signals (pop)
                  assign acc_rd_dca          = rrb_rready_dca;
                  assign acc_rd_dcb          = rrb_rready_dcb;
                  // channel output valid
                  assign rrb_rvalid_dca      = ~acc_empty_dca;
                  assign rrb_rvalid_dcb      = ~acc_empty_dcb;
                  // dcr inputs
                  assign dcr_rd_last_dca     = rrb_rd_last_dca;
                  assign dcr_rd_last_dcb     = rrb_rd_last_dcb;
                  assign dcr_ch_num_dca      = rrb_ch_num_dca;
                  assign dcr_ch_num_dcb      = rrb_ch_num_dcb;
                  assign dcr_token_dca       = rrb_token_i_dca;
                  assign dcr_token_dcb       = rrb_token_i_dcb;
                  // DCR control (output side)
                  assign dcr_rvalid_dca      = ~rrb_sync_empty_dca;
                  assign dcr_rvalid_dcb      = ~rrb_sync_empty_dcb;
                  // mux between the 2 read coming from the accumulator (read when accumulators are not full so they can accept data)
                  assign dcr_rd              = (rrb_dch_sel[1]) ? rrb_rd_dcb : 
                                                                  rrb_rd_dca;

                  assign rrb_data_pack_mux_dca  = rrb_data_pack_dca;
                  assign rrb_data_pack_mux_dcb  = rrb_data_pack_dcb;

                  assign occap_dca_rd_par_err = 1'b0;
                  assign occap_dcb_rd_par_err = 1'b0; 

               end

            end // DUAL_CHANNEL_INTERLEAVE_HP==1
            else begin: INTLV_up_szie

               // data + info channel 0 and 1
               assign rrb_data_pack_mux_dca   = {rrb_rdata_dca,{NUM_DATA_CHANNELS{rrb_rerror_r_dca}},rrb_rdata_parity_dca,rrb_rid_dca,rrb_rd_last_dca,rrb_ch_num_dca,rrb_ruser_dca,rrb_queue_dca,rrb_rinfo_dca,rrb_rexa_acc_instr_dca,rrb_rpoison_dca,rrb_ocpar_err_dca};
               assign rrb_data_pack_mux_dcb   = {rrb_rdata_dcb,{NUM_DATA_CHANNELS{rrb_rerror_r_dcb}},rrb_rdata_parity_dcb,rrb_rid_dcb,rrb_rd_last_dcb,rrb_ch_num_dcb,rrb_ruser_dcb,rrb_queue_dcb,rrb_rinfo_dcb,rrb_rexa_acc_instr_dcb,rrb_rpoison_dcb,rrb_ocpar_err_dcb};

               assign rrb_rvalid_dca      = ~rrb_sync_empty_dca;
               assign rrb_rvalid_dcb      = ~rrb_sync_empty_dcb;
               assign rrb_rd_dca          = rrb_rready_dca;
               assign rrb_rd_dcb          = rrb_rready_dcb;


               // dcr inputs
               assign dcr_rd_last_dca     = rrb_rd_last_dca;
               assign dcr_rd_last_dcb     = rrb_rd_last_dcb;
               assign dcr_ch_num_dca      = rrb_ch_num_dca;
               assign dcr_ch_num_dcb      = rrb_ch_num_dcb;
               assign dcr_token_dca       = rrb_token_i_dca;
               assign dcr_token_dcb       = rrb_token_i_dcb;
               // DCR control (output side)
               assign dcr_rvalid_dca      = ~rrb_sync_empty_dca;
               assign dcr_rvalid_dcb      = ~rrb_sync_empty_dcb;

               assign dcr_rd              = rrb_rd_i; 

               assign occap_dca_rd_par_err = 1'b0;
               assign occap_dcb_rd_par_err = 1'b0; 

            end // !DUAL_CHANNEL_INTERLEAVE_HP==1
                        
            assign dcr_rrb_rd_dca      = rrb_rready_dca & rrb_rvalid_dca & dcr_rd_last_dca; // pop dcr FIFOs when last data is sent to xpi_df
            assign dcr_rrb_rd_dcb      = rrb_rready_dcb & rrb_rvalid_dcb & dcr_rd_last_dcb; // pop dcr FIFOs when last data is sent to xpi_df
                        

            // Data Channel MUX
/*******************************************************
            

   rrb_dch_sel (channel select for the MUX from xpi_dcr)


  rrb_rready_dca <---|\
                     | |
                     | |<----- rrb_rd_i (rd from xpi_df)
  rrb_rready_dcb <---| |   
                     |/

  rrb_rvalid_dca ---->|\
                      | |
                      | |----> rrb_rvalid (wr to xpi_df)
                      | |
  rrb_rvalid_dcb ---->|/


*********************************************************/
            // channel mux select
            assign rrb_dch_sel   = dch_sel;
            // mux valid signal
            // output valid
            assign rrb_rvalid          = (rrb_dch_sel[1]) ? rrb_rvalid_dcb : // channel 1
                                         (rrb_dch_sel[0]) ? rrb_rvalid_dca : // channel 0
                                                            1'b0;            // no channel
            // demux read for different channels
            assign rrb_rready_dca      = (rrb_dch_sel[0]) ? rrb_rd_i : 1'b0;
            assign rrb_rready_dcb      = (rrb_dch_sel[1]) ? rrb_rd_i : 1'b0;
            // data + info mux output
            assign rrb_data_pack_mux   = (rrb_dch_sel[1]) ? rrb_data_pack_mux_dcb : rrb_data_pack_mux_dca;
            // unpack muxed data + info
            assign {rdr_rrb_rdata,rdr_rrb_rerror,rdr_rrb_rdata_parity,rdr_rrb_rid,rdr_rrb_rd_last,rdr_rrb_ch_num,rdr_rrb_ruser,rdr_rrb_queue,rdr_rrb_rinfo,rdr_rrb_rexa_acc_instr,rdr_rrb_rpoison,rdr_rrb_ocpar_err} = rrb_data_pack_mux;

            // input to optional retime after the channel MUX
            assign rdr_rinfo = {rdr_rrb_rid,rdr_rrb_rd_last,rdr_rrb_ch_num,rdr_rrb_ruser,rdr_rrb_queue,rdr_rrb_rinfo,rdr_rrb_rexa_acc_instr,rdr_rrb_rpoison,rdr_rrb_ocpar_err};
            assign rdr_rdata_err = {rdr_rrb_rdata_parity,rdr_rrb_rerror,rdr_rrb_rdata};

            if (USE_RDR==1) begin: RDR_en
            // optional retime after the channel mux, cut the path for timing issues (path xpi_dcr -> xpi_df)
               wire rdr_data_full, rdr_data_empty, rdr_data_wr, rdr_data_rd;
               wire rdr_info_full_unused, rdr_info_empty_unused, rdr_info_wr, rdr_info_rd;

               assign rrb_rvalid_up = ~rdr_data_empty;
               assign rrb_rd_i      = ~rdr_data_full;
               assign rdr_data_wr   = rrb_rvalid;
               assign rdr_data_rd   = rrb_rd;

               assign rdr_info_wr = rdr_data_wr;
               assign rdr_info_rd = rdr_data_rd;

               DWC_ddr_umctl2_retime
                    
               #(
               .SIZE       (RDRDW),
               .OCCAP_EN   (OCCAP_EN),
               .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
               ) U_rdr_data
               (
               .clk         (e_clk),    
               .rst_n       (e_rst_n),    
               .d           (rdr_rdata_err),
               .wr          (rdr_data_wr),
               .rd          (rdr_data_rd),
               .par_en      (reg_ddrc_occap_en),
               .q           (rdata_err_rdr),
               .fe          (rdr_data_empty),
               .ff          (rdr_data_full),
               .par_err     (occap_xpi_rdr_data_par_err)
               );

               DWC_ddr_umctl2_retime
                    
               #(
               .SIZE       (RDRW),
               .OCCAP_EN   (OCCAP_EN),
               .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
               ) U_rdr_info
               (
               .clk         (e_clk),    
               .rst_n       (e_rst_n),    
               .d           (rdr_rinfo),
               .wr          (rdr_info_wr),
               .rd          (rdr_info_rd),
               .par_en      (reg_ddrc_occap_en),
               .q           (rinfo_rdr),
               .fe          (rdr_info_empty_unused),
               .ff          (rdr_info_full_unused),
               .par_err     (occap_xpi_rdr_info_par_err)
               );

            end // if (USE_RDR==1)
            else begin: RDR_nen
               // pass through with no retime
               assign rdata_err_rdr = rdr_rdata_err;
               assign rinfo_rdr     = rdr_rinfo;
               assign rrb_rd_i      = rrb_rd;
               assign rrb_rvalid_up = rrb_rvalid;
               assign occap_xpi_rdr_data_par_err = 1'b0;
               assign occap_xpi_rdr_info_par_err = 1'b0;

            end // !if (USE_RDR==1)

            // data+info output to xpi_read
            assign {rrb_rid,rrb_rd_last,rrb_ch_num,rrb_ruser,rrb_queue,rrb_rinfo,rrb_rexa_acc_instr,rrb_rpoison,rrb_ocpar_err} = rinfo_rdr;
            assign {rrb_rdata_parity_up,rrb_rerror,rrb_rdata_up} = rdata_err_rdr;

      end // if (DUAL_CHANNEL_INTERLEAVE==1)
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Signals either unused in some configs or used in generate blocks or in RTL assertions
      else begin: Single_DCH
         // No channel interleaving
         // unused signals
         assign rrb_rd_dcb                = 1'b0;
         assign dcr_rd                    = 1'b0;
         assign rrb_q_retime_dcb          = {RDATARAM_DW_INT{1'b0}};
         assign dcr_ch_num_dcb            = {NUM_CH_LG2{1'b0}};
         assign rrb_ch_num_dcb            = {NUM_CH_LG2{1'b0}};
         assign dcr_rd_last_dcb           = 1'b0;
         assign rrb_rd_last_dcb           = 1'b0;
         assign rrb_rexa_acc_instr_r_dcb  = 1'b0;
         assign rrb_rpoison_r_dcb         = 1'b0;
         assign rrb_ocpar_err_r_dcb       = 1'b0;
         assign rrb_queue_r_dcb           = 1'b0;
         assign rrb_rinfo_r_dcb           = {RINFOW{1'b0}};
         assign rrb_rid_r_dcb             = {AXI_IDW{1'b0}};
         assign rrb_rd_i_dcb              = 1'b0;
         assign rrb_rid_dcb               = {AXI_IDW{1'b0}};
         assign rrb_rinfo_dcb             = {RINFOW{1'b0}};
         assign rrb_ruser_r_dcb           = {AXI_USERW{1'b0}};
         assign rrb_ruser_dcb             = {AXI_USERW{1'b0}};
         assign rrb_queue_dcb             = 1'b0;
         assign rrb_rpoison_dcb           = 1'b0;
         assign rrb_ocpar_err_dcb         = 1'b0;
         assign rrb_rexa_acc_instr_dcb    = 1'b0;
         assign dcr_rvalid_dcb            = 1'b0;
         //assign rrb_dch_sel               = 2'b01;
         assign dcr_rrb_rd_dca            = 1'b0;
         assign dcr_rrb_rd_dcb            = 1'b0;
         assign dcr_rd_last_dca           = 1'b0;
         assign dcr_ch_num_dca            = {NUM_CH_LG2{1'b0}};
         assign rrb_q_int_dcb             = {RDATARAM_DW_INT{1'b0}};
         assign rrb_par_q_int_dcb         = {DATARAM_PAR_DW{1'b0}};
         assign rdataram_din_dcb          = {RDATARAM_DW{1'b0}};
         assign rdataram_din_par_dcb      = {DATARAM_PAR_DW{1'b0}};
         assign rdataram_wr_dcb           = 1'b0;
         assign rdataram_re_dcb           = 1'b0;
         assign rdataram_raddr_dcb        = {RDATARAM_AW{1'b0}};
         assign rdataram_waddr_dcb        = {RDATARAM_AW{1'b0}};
         assign rrb_token_i_dca           = {MEMC_NO_OF_ENTRY_LG2{1'b0}}; 
         assign rrb_token_i_dcb           = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
         assign dcr_token_dca             = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
         assign dcr_token_dcb             = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
         assign rrb_sync_d_dcb            = {RRBRIW{1'b0}};
         assign rrb_sync_q_dcb            = {RRBRIW{1'b0}};
         assign rrb_rvalid_dca            = 1'b0;
         assign rrb_rvalid_dcb            = 1'b0;
         assign dcr_rvalid_dca            = 1'b0;
         assign rrb_rvalid                = 1'b0;

         // external RAM retimed and single channel
         assign rrb_rdata_up           = rrb_rdata_dca;
         assign rrb_rdata_parity_up    = rrb_rdata_parity_dca;
         assign rrb_rerror             = {NUM_DATA_CHANNELS{rrb_rerror_r_dca}};
         assign rrb_rid                = rrb_rid_dca;
         assign rrb_ruser              = rrb_ruser_dca;
         assign rrb_rd_last            = rrb_rd_last_dca;
         assign rrb_ch_num             = rrb_ch_num_dca;
         assign rrb_queue              = rrb_queue_dca;
         assign rrb_rinfo              = rrb_rinfo_dca;
         assign rrb_rexa_acc_instr     = rrb_rexa_acc_instr_dca;
         assign rrb_rpoison            = rrb_rpoison_dca;
         assign rrb_ocpar_err          = rrb_ocpar_err_dca;
         assign rrb_rvalid_up          = ~rrb_sync_empty_dca;

         assign rrb_rd_dca             = rrb_rd;

         assign occap_dca_rd_par_err = 1'b0;
         assign occap_dcb_rd_par_err = 1'b0;

         assign occap_xpi_sync_info_dcb_par_err = 1'b0;
         assign occap_xpi_rdr_data_par_err      = 1'b0;
         assign occap_xpi_rdr_info_par_err      = 1'b0;

         // retime input
         assign rrb_sync_d_dca   = {rrb_ch_num_i_dca,rrb_rd_last_i_dca,rrb_rexa_acc_instr_i_dca,rrb_rpoison_i_dca,rrb_ocpar_err_i_dca,rrb_ruser_i_dca,rrb_queue_i_dca,rrb_rinfo_i_dca,rrb_rid_i_dca,rrb_rerror_i_dca};
         // retime output
         assign {rrb_ch_num_dca,rrb_rd_last_dca,rrb_rexa_acc_instr_r_dca,rrb_rpoison_r_dca,rrb_ocpar_err_r_dca,rrb_ruser_r_dca,rrb_queue_r_dca,rrb_rinfo_r_dca,rrb_rid_r_dca,rrb_rerror_r_dca} = rrb_sync_q_dca;

      end // !if (DUAL_CHANNEL_INTERLEAVE==1)

      

    end else if (RRB_EXTRAM==1 && RRB_EXTRAM_REG==0) begin: GEN_unregistered_ext_ram
    // external unregistered RAM
      assign rrb_q_int_dca          = rdataram_dout;
      assign rrb_par_q_int_dca      = rdataram_dout_par;
      assign rdataram_din           = rrb_d_dca;
      assign rdataram_din_par       = rrb_par_d_dca;
      assign rdataram_wr            = rrb_wr_dca;
      assign rdataram_re            = ~rrb_empty_dca;
      assign rdataram_raddr         = rrb_rdataram_raddr_dca;
      assign rdataram_waddr         = rrb_rdataram_waddr_dca;
      assign rrb_rd_i_dca           = rrb_rd;
      assign rrb_rid_dca            = rrb_rid_i_dca;
      assign rrb_ruser_dca          = rrb_ruser_i_dca;
      assign rrb_rd_last            = rrb_rd_last_i_dca;
      assign rrb_rinfo_dca          = rrb_rinfo_i_dca;
      assign rrb_queue_dca          = rrb_queue_i_dca;
      assign rrb_rpoison_dca        = rrb_rpoison_i_dca;
      assign rrb_ocpar_err_dca      = rrb_ocpar_err_i_dca;
      assign rrb_rexa_acc_instr_dca = rrb_rexa_acc_instr_i_dca;           
      assign rrb_rdata_up           = rrb_rdata_dca;
      assign rrb_rdata_parity_up    = rrb_rdata_parity_dca;
      assign rrb_rerror             = {NUM_DATA_CHANNELS{rrb_rerror_r_dca}};
      assign rrb_rid                = rrb_rid_dca;
      assign rrb_ruser              = rrb_ruser_dca;
      assign rrb_ch_num             = rrb_ch_num_i_dca;
      assign rrb_queue              = rrb_queue_dca;
      assign rrb_rinfo              = rrb_rinfo_dca;
      assign rrb_rexa_acc_instr     = rrb_rexa_acc_instr_dca;
      assign rrb_rpoison            = rrb_rpoison_dca;
      assign rrb_ocpar_err          = rrb_ocpar_err_dca;
      assign rrb_rvalid_up          = rrb_rvalid_i;
      assign rrb_rerror_r_dca       = rrb_rerror_i_dca;
      // tied to 0
      assign rrb_rvalid                = 1'b0;
      assign dcr_rd                    = 1'b0;
      assign dcr_ch_num_dca            = {NUM_CH_LG2{1'b0}};
      assign rrb_ch_num_dca            = {NUM_CH_LG2{1'b0}};
      assign dcr_rvalid_dca            = 1'b0;
      assign dcr_rd_last_dca           = 1'b0;
      assign rrb_rd_last_dca           = 1'b0;
      //assign rrb_dch_sel               = 2'b01; // dual channel not suppoted for this config
      assign rrb_rerror_r_dcb          = 1'b0;
      assign rrb_rerror_i_dcb          = 1'b0;
      assign rrb_q_int_dcb             = {RDATARAM_DW_INT{1'b0}};
      assign rrb_par_q_int_dcb         = {DATARAM_PAR_DW{1'b0}};
      assign rdataram_din_dcb          = {RDATARAM_DW{1'b0}};
      assign rdataram_din_par_dcb      = {DATARAM_PAR_DW{1'b0}};
      assign rdataram_wr_dcb           = 1'b0;
      assign rdataram_re_dcb           = 1'b0;
      assign rdataram_raddr_dcb        = {RDATARAM_AW{1'b0}};
      assign rdataram_waddr_dcb        = {RDATARAM_AW{1'b0}};
      assign dcr_rvalid_dcb            = 1'b0;
      assign rrb_rpoison_r_dca         = 1'b0;
      assign rrb_rpoison_dcb           = 1'b0;
      assign rrb_ocpar_err_r_dca       = 1'b0;
      assign rrb_ocpar_err_dcb         = 1'b0;
      assign rrb_rexa_acc_instr_dcb    = 1'b0;
      assign rrb_rexa_acc_instr_r_dca  = 1'b0;
      assign rrb_queue_r_dca           = 1'b0;
      assign rrb_queue_dcb             = 1'b0;
      assign rrb_rinfo_dcb             = {RINFOW{1'b0}};
      assign rrb_rinfo_r_dca           = {RINFOW{1'b0}};
      assign rrb_rid_dcb               = {AXI_IDW{1'b0}};
      assign rrb_rid_r_dca             = {AXI_IDW{1'b0}};
      assign rrb_ruser_dca             = {AXI_USERW{1'b0}};
      assign rrb_ruser_r_dca           = {AXI_USERW{1'b0}};
      assign rrb_rd_dca                = 1'b0;
      assign rrb_rd_dcb                = 1'b0;
      assign rrb_rd_i_dcb              = 1'b0;
      assign rrb_q_retime_dcb          = {RDATARAM_DW_INT{1'b0}};
      assign rrb_rexa_acc_instr_r_dcb  = 1'b0;
      assign rrb_rpoison_r_dcb         = 1'b0;
      assign rrb_ocpar_err_r_dcb       = 1'b0;
      assign rrb_queue_r_dcb           = 1'b0;
      assign rrb_rinfo_r_dcb           = {RINFOW{1'b0}};
      assign rrb_rid_r_dcb             = {AXI_IDW{1'b0}};
      assign rrb_ruser_r_dcb           = {AXI_USERW{1'b0}};
      assign rrb_token_i_dca           = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign rrb_token_i_dcb           = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_token_dca             = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_token_dcb             = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_rd_last_dcb           = 1'b0;
      assign rrb_rd_last_dcb           = 1'b0;
      assign dcr_ch_num_dcb            = {NUM_CH_LG2{1'b0}};
      assign rrb_ch_num_dcb            = {NUM_CH_LG2{1'b0}};
      assign rrb_sync_d_dca            = {RRBRIW{1'b0}};
      assign rrb_sync_d_dca            = {RRBRIW{1'b0}};
      assign rrb_sync_q_dca            = {RRBRIW{1'b0}};
      assign rrb_sync_q_dcb            = {RRBRIW{1'b0}};
      assign rrb_rvalid_dca            = 1'b0;
      assign rrb_rvalid_dcb            = 1'b0;
      assign dcr_rrb_rd_dca            = 1'b0;
      assign dcr_rrb_rd_dcb            = 1'b0;
      assign occap_dca_rd_par_err            = 1'b0;
      assign occap_dcb_rd_par_err            = 1'b0;
      assign occap_xpi_sync_info_par_err     = 1'b0;
      assign occap_xpi_sync_info_dcb_par_err = 1'b0;
      assign occap_xpi_rdr_data_par_err      = 1'b0;
      assign occap_xpi_rdr_info_par_err      = 1'b0;
    end // if (RRB_EXTRAM==1 && RRB_EXTRAM_REG==0)
    else begin: GEN_no_ext_ram
    // internal data SRAM
      assign rrb_q_int_dca          = rrb_q_dca;
      assign rrb_rd_i_dca           = rrb_rd;
      assign rrb_rid_dca            = rrb_rid_i_dca;
      assign rrb_ruser_dca          = rrb_ruser_i_dca;
      assign rrb_rd_last            = rrb_rd_last_i_dca;            
      assign rrb_rinfo_dca          = rrb_rinfo_i_dca;
      assign rrb_queue_dca          = rrb_queue_i_dca;
      assign rrb_rpoison_dca        = rrb_rpoison_i_dca;
      assign rrb_ocpar_err_dca      = rrb_ocpar_err_i_dca;
      assign rrb_rexa_acc_instr_dca = rrb_rexa_acc_instr_i_dca;     
      assign rrb_rdata_up           = rrb_rdata_dca;
      assign rrb_rdata_parity_up    = rrb_rdata_parity_dca;
      assign rrb_rerror             = {NUM_DATA_CHANNELS{rrb_rerror_r_dca}};
      assign rrb_rid                = rrb_rid_dca;
      assign rrb_ruser              = rrb_ruser_dca;
      assign rrb_ch_num             = rrb_ch_num_i_dca;
      assign rrb_queue              = rrb_queue_dca;
      assign rrb_rinfo              = rrb_rinfo_dca;
      assign rrb_rexa_acc_instr     = rrb_rexa_acc_instr_dca;
      assign rrb_rpoison            = rrb_rpoison_dca;
      assign rrb_ocpar_err          = rrb_ocpar_err_dca;
      assign rrb_rvalid_up          = rrb_rvalid_i;
      assign rrb_rerror_r_dca       = rrb_rerror_i_dca;
      // tied to 0
      assign rrb_rvalid                = 1'b0;
      assign dcr_rd                    = 1'b0;
      assign rrb_par_q_int_dca         = {DATARAM_PAR_DW{1'b0}};
      assign rdataram_din_par          = {DATARAM_PAR_DW{1'b0}};
      assign rdataram_din              = {RDATARAM_DW{1'b0}};
      assign rdataram_wr               = 1'b0;
      assign rdataram_re               = 1'b0;
      assign rdataram_raddr            = {RDATARAM_AW{1'b0}};
      assign rdataram_waddr            = {RDATARAM_AW{1'b0}}; 
      assign dcr_rvalid_dca            = 1'b0;
      assign dcr_rd_last_dca           = 1'b0;
      assign rrb_rd_last_dca           = 1'b0;
      assign dcr_ch_num_dca            = {NUM_CH_LG2{1'b0}};
      assign rrb_ch_num_dca            = {NUM_CH_LG2{1'b0}};
      //assign rrb_dch_sel               = 2'b01; // dual channel not suppoted for this config
      assign rrb_q_int_dcb             = {RDATARAM_DW_INT{1'b0}};
      assign rrb_par_q_int_dcb         = {DATARAM_PAR_DW{1'b0}};
      assign rdataram_din_dcb          = {RDATARAM_DW{1'b0}};
      assign rdataram_din_par_dcb      = {DATARAM_PAR_DW{1'b0}};
      assign rdataram_wr_dcb           = 1'b0;
      assign rdataram_re_dcb           = 1'b0;
      assign rdataram_raddr_dcb        = {RDATARAM_AW{1'b0}};
      assign rdataram_waddr_dcb        = {RDATARAM_AW{1'b0}};
      assign dcr_rvalid_dcb            = 1'b0;
      assign rrb_rpoison_r_dca         = 1'b0;
      assign rrb_rpoison_dcb           = 1'b0;
      assign rrb_ocpar_err_r_dca       = 1'b0;
      assign rrb_ocpar_err_dcb         = 1'b0;
      assign rrb_rexa_acc_instr_dcb    = 1'b0;
      assign rrb_rexa_acc_instr_r_dca  = 1'b0;
      assign rrb_queue_r_dca           = 1'b0;
      assign rrb_queue_dcb             = 1'b0;
      assign rrb_rinfo_dcb             = {RINFOW{1'b0}};
      assign rrb_rinfo_r_dca           = {RINFOW{1'b0}};
      assign rrb_rid_dcb               = {AXI_IDW{1'b0}};
      assign rrb_rid_r_dca             = {AXI_IDW{1'b0}};
      assign rrb_ruser_dcb             = {AXI_USERW{1'b0}};
      assign rrb_ruser_r_dca           = {AXI_USERW{1'b0}};
      assign rrb_rd_dca                = 1'b0;
      assign rrb_rd_dcb                = 1'b0;
      assign rrb_rd_i_dcb              = 1'b0;
      assign rrb_q_retime_dcb          = {RDATARAM_DW_INT{1'b0}};
      assign rrb_rexa_acc_instr_r_dcb  = 1'b0;
      assign rrb_rpoison_r_dcb         = 1'b0;
      assign rrb_ocpar_err_r_dcb       = 1'b0;
      assign rrb_queue_r_dcb           = 1'b0;
      assign rrb_rinfo_r_dcb           = {RINFOW{1'b0}};
      assign rrb_rid_r_dcb             = {AXI_IDW{1'b0}};
      assign rrb_ruser_r_dcb           = {AXI_USERW{1'b0}};
      assign rrb_token_i_dca           = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign rrb_token_i_dcb           = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_token_dca             = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_token_dcb             = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_rd_last_dcb           = 1'b0;
      assign rrb_rd_last_dcb           = 1'b0;
      assign dcr_ch_num_dcb            = {NUM_CH_LG2{1'b0}};
      assign rrb_ch_num_dcb            = {NUM_CH_LG2{1'b0}};
      assign rrb_sync_d_dca            = {RRBRIW{1'b0}};
      assign rrb_sync_d_dcb            = {RRBRIW{1'b0}};
      assign rrb_sync_q_dca            = {RRBRIW{1'b0}};
      assign rrb_sync_q_dcb            = {RRBRIW{1'b0}};
      assign rrb_rvalid_dca            = 1'b0;
      assign rrb_rvalid_dcb            = 1'b0;
      assign dcr_rrb_rd_dca            = 1'b0;
      assign dcr_rrb_rd_dcb            = 1'b0;
      assign occap_dca_rd_par_err            = 1'b0;
      assign occap_dcb_rd_par_err            = 1'b0;
      assign occap_xpi_sync_info_par_err     = 1'b0;
      assign occap_xpi_sync_info_dcb_par_err = 1'b0;
      assign occap_xpi_rdr_data_par_err      = 1'b0;
      assign occap_xpi_rdr_info_par_err      = 1'b0;
    end // !if (RRB_EXTRAM==1)
  endgenerate

  wire [BEAT_INFOW-1:0] rrb_beat_info_unused_dca, rrb_beat_info_unused_dcb;
  wire                  rrb_rlast_unused_dca, rrb_rlast_unused_dcb;

  assign rrb_infod_dca  = {rbeat_info_dca,hif_rlast_dca,e_resp_rexa_acc_instr_dca, e_resp_rpoison_dca, e_resp_ocpar_err_dca, e_resp_ruser_dca, hif_queue_dca, hif_rinfo_dca, hif_rid_dca};
  assign rrb_infod_dcb  = {rbeat_info_dcb,hif_rlast_dcb,e_resp_rexa_acc_instr_dcb, e_resp_rpoison_dcb, e_resp_ocpar_err_dcb, e_resp_ruser_dcb, hif_queue_dcb, hif_rinfo_dcb, hif_rid_dcb};

  assign {rrb_beat_info_unused_dca,rrb_rlast_unused_dca,rrb_rexa_acc_instr_i_dca, rrb_rpoison_i_dca, rrb_ocpar_err_i_dca, rrb_ruser_i_dca, rrb_queue_i_dca, rrb_rinfo_i_dca, rrb_rid_i_dca} = rrb_infoq_dca;
  assign {rrb_beat_info_unused_dcb,rrb_rlast_unused_dcb,rrb_rexa_acc_instr_i_dcb, rrb_rpoison_i_dcb, rrb_ocpar_err_i_dcb, rrb_ruser_i_dcb, rrb_queue_i_dcb, rrb_rinfo_i_dcb, rrb_rid_i_dcb} = rrb_infoq_dcb;
   
  assign rrb_wr_dca     = hif_rvalid_dca_i;
  assign rrb_wr_dcb     = hif_rvalid_dcb;

  assign xpi_rready     = ~rrb_full_dca;
  assign xpi_rready_dcb = ~rrb_full_dcb;

  assign rrb_rvalid_i   = ~rrb_empty_dca;
  generate
    if (USE2RAQ==1) begin: dual_ch
      assign xpi_read_ch_num           = (gen_token_red)       ? xpi_read_ch_num_red         : xpi_read_ch_num_blue; // TODO (to be reviewed)
      assign xpi_read_bypass_reorder   = (gen_token_red)       ? xpi_read_bypass_reorder_red : xpi_read_bypass_reorder_blue; // TODO
      assign bam_addr_offset           = gen_token_red ? bam_addr_offset_red :bam_addr_offset_blue ;
      assign bam_lead_burst            = gen_token_red ? bam_lead_burst_red  :bam_lead_burst_blue ;
      assign bam_arlast                = gen_token_red ? xpi_rd_arlast_red_i :xpi_rd_arlast_blue_i ;

      assign sbam_lead_burst           = gen_token_red? sbam_lead_burst_red       : sbam_lead_burst_blue;
      assign sbam_second_burst         = gen_token_red? sbam_second_burst_red     : sbam_second_burst_blue;
      assign sbam_tokens_allocated     = gen_token_red? sbam_tokens_allocated_red : sbam_tokens_allocated_blue;

      assign split_dcm                 = gen_token_red ? xpi_rd_split_red :xpi_rd_split_blue ;
    end else begin: single_ch
      assign xpi_read_ch_num           = xpi_read_ch_num_blue;
      assign xpi_read_bypass_reorder   = xpi_read_bypass_reorder_blue;
      assign bam_addr_offset           = bam_addr_offset_blue ;
      assign bam_lead_burst            = bam_lead_burst_blue ;
      assign bam_arlast                = xpi_rd_arlast_blue_i ;

      assign sbam_lead_burst           = sbam_lead_burst_blue;
      assign sbam_second_burst         = sbam_second_burst_blue;
      assign sbam_tokens_allocated     = sbam_tokens_allocated_blue;

      assign split_dcm                 = xpi_rd_split_blue ;
    end
  endgenerate
//spyglass enable_block W528 
   // If the current DRAM XFER (in Bytes) size is smaller that AXI_DATAW(in Bytes) then BAM is acive
   //  - In certain configs BAM's necessity arises due to progrramable settings hence we need this signal
   // In configs that dont need BAM this is set to 0
   assign bam_is_active =  (USE_BAM==1) && (AXI_STRBW > ((reg_ddrc_burst_rdwr <<(M_NB_LG2+1)) >> reg_ddrc_data_bus_width));


  DWC_ddr_umctl2_xpi_rrb
  
    #(.RDATARAM_DW   (RDATARAM_DW_INT),
      .INFOW         (RRBIW),  
      .RINFO_ADROFFST_LSB  (RINFO_ADROFFST_LSB),
      .NTOKENS       (MEMC_NO_OF_ENTRY),
      .NBEATS        (NBEATS),
      .NBEATS_LG2    (NBEATS_LG2),
      .BEAT_INFOW    (BEAT_INFOW),
      .NTOKENS_LG2   (MEMC_NO_OF_ENTRY_LG2),
      .RRB_EXTRAM    (RRB_EXTRAM),
      .RDATARAM_AW   (RDATARAM_AW),
      .A_BLW         (A_BLW),
      .OCCAP_EN      (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
      .NUM_VIR_CH    (NUM_VIR_CH),
      .NUM_VIR_CH_LG2(NUM_VIR_CH_LG2),
      .NUM_CH        (NUM_CH),
      .NUM_CH_LG2    (NUM_CH_LG2),
      .USE2RAQ       (USE2RAQ),
      .READ_DATA_INTERLEAVE_EN (READ_DATA_INTERLEAVE_EN),
      .RRB_THRESHOLD_EN       (RRB_THRESHOLD_EN),
      .RRB_THRESHOLD_PPL      (RRB_THRESHOLD_PPL),
      .STATIC_VIR_CH  (STATIC_VIR_CH),
      .IDW            (AXI_IDW),
      .RPINFOW        (RPINFOW),
      .INTLVMODEW       (INTLVMODEW),
      .BAM_OFFSW        (BAM_OFFSW),
      .MAXSIZE          (MAXSIZE),
      .AXI_MAXSIZE      (AXI_MAXSIZE),
      .M_DW             (M_DW),    
      .USE_BAM          (USE_BAM),
      .PDBW_CASE        (PDBW_CASE),
      .RDATARAM_DEPTH   (RDATARAM_DEPTH),
      .MIN_M_BL         (MIN_M_BL),
      .BRW              (BRW)
      )
  U_xpi_rrb
    (
     // Outputs
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(RRBIW - 1)' found in module 'DWC_ddr_umctl2_xpi'
//SJ: This coding style is acceptable and there is no plan to change it.
     .infoq                               (rrb_infoq_dca[RRBIW-1:0]),
//spyglass enable_block SelfDeterminedExpr-ML
     .rd_last                             (rrb_rd_last_i_dca),
     .q_ch_num                            (rrb_ch_num_i_dca),
     .empty                               (rrb_empty_dca),
     .full                                (rrb_full_dca),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
     .q                                   (rrb_q_dca[RDATARAM_DW_INT-1:0]),
     .release_token                       (rrb_release_token_dca),
     .xpi_rrb_parity_err                  (occap_xpi_rrb_par_err_dca),
     .rtoken                              (rrb_rtoken_dca[MEMC_NO_OF_ENTRY_LG2-1:0]),
     .dcr_token                           (rrb_token_dca),
     .rdataram_raddr                      (rrb_rdataram_raddr_dca[RDATARAM_AW-1:0]),
     .rdataram_waddr                      (rrb_rdataram_waddr_dca[RDATARAM_AW-1:0]),   
     .rerror_q                            (rrb_rerror_i_dca),
     .bam_is_active                       (bam_is_active), 
     .reg_ddrc_data_bus_width             (reg_ddrc_data_bus_width),
     .rrb_is_locked                       (rrb_is_locked),
     .locked_ch                           (locked_ch),
//spyglass enable_block W528   
     // Inputs
     .clk                                 (e_clk),
     .rst_n                               (e_rst_n),
     .wr                                  (rrb_wr_dca),
     .rd                                  (rrb_rd_i_dca),
     .d                                   (rrb_d_dca[RDATARAM_DW_INT-1:0]),
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(RRBIW - 1)' found in module 'DWC_ddr_umctl2_xpi'
//SJ: This coding style is acceptable and there is no plan to change it.
     .infod                               (rrb_infod_dca[RRBIW-1:0]),
//spyglass enable_block SelfDeterminedExpr-ML
     .wr_addr                             (rtoken_dca[MEMC_NO_OF_ENTRY_LG2-1:0]),
     .gen_token                           (gen_token_rrb_dca),
     .atoken                              (atoken_rrb_dca),
     .bam_addr_offset                     (dcm_bam_addr_offset),
     .bam_lead_burst                      (dcm_bam_lead_burst),
     .bam_arlast                          (dcm_bam_arlast),
     .bam_red_token                       (dcm_bam_red_token),
     .sbam_lead_burst                     (dcm_sbam_lead_burst),
     .sbam_second_burst                   (dcm_sbam_second_burst),
     .sbam_tokens_allocated               (dcm_sbam_tokens_allocated),
     .abypass_reorder                     (abypass_reorder_rrb_dca),
     .reg_ddrc_occap_en                   (reg_ddrc_occap_en),
     .ch_num                              (ch_num_rrb_dca),
     .valid_dcr                           (valid_dcr_dca),
     .vtq_empty                           (vtq_empty_dca),
     .rbypass_reorder                     (hif_bypass_reorder_dca),
     .a_bl                                (a_bl[A_BLW-1:0]),
     .rerror_d                            (hif_rerror_dca_i),
     .reg_ddrc_burst_rdwr                 (reg_ddrc_burst_rdwr),
     .locked_ch_raq_red                   (rrb_tm_locked_ch_raq_red)
     );

   generate
   if (DUAL_CHANNEL_INTERLEAVE==1) begin: Dual_DCH_RRB

      wire [DCM_NTOKENS_LG2-1:0]       atoken_dca_pn;
      wire [MEMC_NO_OF_ENTRY_LG2-1:0]  rrb_rtoken_unused;

      assign atoken_dca_pn             = {1'b0,atoken_dca};
      
      assign atoken                    = (dch_sel_dcm) ? atoken_dcb : atoken_dca;
      assign gen_token_rrb_dca         = (dcm_dch_sel) ? 1'b0 : gen_token_rrb;
      assign gen_token_rrb_dcb         = (dcm_dch_sel) ? gen_token_rrb : 1'b0;

      assign rrb_rtoken_unused         = (dch_sel[1]) ? dcr_rtoken_dcb : dcr_rtoken_dca;
      
      assign rrb_rtoken_dca_pn         = {1'b0,dcr_rtoken_dca};
      assign rrb_rtoken_dcb_pn         = dcr_rtoken_dcb + MEMC_NO_OF_ENTRY; // shift token generated for channel 1, this is because only 1 token is sent to the common DCM
      
      //spyglass disable_block W528
      //SMD: A signal or variable is set but never read
      //SJ: Used in generate block
      assign atoken_dcm                = (dch_sel_dcm) ? atoken_dcb_pn : atoken_dca_pn;
      assign xpi_rd_arid               = (gen_token_blue) ? (dch_sel_dcm ? xpi_rd_arid_blue_dcb : xpi_rd_arid_blue) : xpi_rd_arid_red; // TODO (dual queue + dual channel support)
      assign rrb_release_token         = (dch_sel[1]) ? dcr_release_token_dcb : dcr_release_token_dca;
      assign rrb_rtoken_dcm            = (dch_sel[1]) ? rrb_rtoken_dcb_pn : rrb_rtoken_dca_pn;
      assign vtq_empty                 = vtq_empty_dcb & vtq_empty_dca;            
      //spyglass disable_block TA_09
      //SMD: Net 'DWC_ddrctl.U_xpi_3.dcm_token[6]' [in 'DWC_ddr_umctl2_xpi'] is not observable[affected by other input(s)].
      //SJ: Functionally correct. dcm_token[6] is used to represent which channel is used (single/dual-channel configs).
      assign atoken_rrb_dcb_dcm        = dcm_token - MEMC_NO_OF_ENTRY; // shift channel 1 token back to original value
      //spyglass enable_block TA_09
      //spyglass enable_block W528
      
      assign tm_release_token_dca      = dcr_release_token_dca;
      assign tm_rtoken_dca             = dcr_rtoken_dca;
      assign tm_release_token_dcb      = dcr_release_token_dcb;
      assign tm_rtoken_dcb             = dcr_rtoken_dcb;


      // This block keeps the order between the 2 data channels
      // Each RRB guarantees the order within a single data channel
      // DCR keeps then the channel order based on the original command order and arbitrates the RRB requests

      DWC_ddr_umctl2_xpi_dcr
      
      #(
         .NUM_CHANNELS     (NUM_DATA_CHANNELS),
         .NTOKENS          (DCR_NTOKENS),
         .NTOKENS_LG2      (DCR_NTOKENS_LG2),
         .RRB_NTOKENS      (MEMC_NO_OF_ENTRY),
         .RRB_NTOKENS_LG2  (MEMC_NO_OF_ENTRY_LG2),
         .NUM_VIR_CH       (NUM_VIR_CH),
         .NUM_VIR_CH_LG2   (NUM_VIR_CH_LG2),
         .NUM_CH           (NUM_CH),
         .NUM_CH_LG2       (NUM_CH_LG2),
         .STATIC_VIR_CH    (STATIC_VIR_CH),
         .OCCAP_EN         (OCCAP_EN),
         .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
      )
      U_xpi_dcr
      (  // inputs
         .clk                       (e_clk),
         .rst_n                     (e_rst_n),
         // load (push) signals
         .gen_token                 (gen_token_rrb),
         .atoken                    (dcm_dch_sel),
         .ch_num                    (ch_num_rrb_dcr),
         // rrb pop (pre-arbitration)
         .rrb_rd_dca                (rdataram_re),
         .rrb_last_dca              (rrb_rd_last_i_dca),
         .rrb_ch_num_dca            (rrb_ch_num_i_dca),
         .rrb_rd_dcb                (rdataram_re_dcb),
         .rrb_last_dcb              (rrb_rd_last_i_dcb),
         .rrb_ch_num_dcb            (rrb_ch_num_i_dcb),
         // retime pop (final arbitration)
         .rd                        (dcr_rd),
         .rrb_vdcq_rd_dca           (dcr_rrb_rd_dca),
         .rrb_vdcq_rd_dcb           (dcr_rrb_rd_dcb),
         .rrb_rvalid_dca            (dcr_rvalid_dca),
         .rrb_rd_last_dca           (dcr_rd_last_dca),
         .rrb_rt_ch_num_dca         (dcr_ch_num_dca),
         .rrb_rvalid_dcb            (dcr_rvalid_dcb),
         .rrb_rd_last_dcb           (dcr_rd_last_dcb),
         .rrb_rt_ch_num_dcb         (dcr_ch_num_dcb),
         .rrb_rtoken_dcb            (dcr_token_dcb),
         .reg_ddrc_occap_en         (reg_ddrc_occap_en),
         // outputs
         .valid_dca                 (valid_dcr_dca),
         .valid_dcb                 (valid_dcr_dcb),
         .release_token_dca         (dcr_release_token_dca),
         .rtoken_dca                (dcr_rtoken_dca),
         .release_token_dcb         (dcr_release_token_dcb),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
         .rrb_rtoken_dca            (dcr_token_dca),
         .rtoken_dcb                (dcr_rtoken_dcb),
//spyglass enable_block W528
         .empty                     (dcr_empty_unused),
         .dch_sel                   (dch_sel), // channel mux select
         .occap_xpi_dcr_par_err     (occap_xpi_dcr_par_err)
      );

      // Spyglass purpose, for RRB_THRESHOLD_EN == 0 && DATA_CHANNEL_INTERLEAVE == 1 config.
      wire                              dcm_sbam_lead_burst_dcb_unused;
      wire                              dcm_sbam_second_burst_dcb_unused;
      wire [MEMC_NO_OF_ENTRY_LG2:0]     dcm_sbam_tokens_allocated_dcb_unused;

      assign dcm_sbam_lead_burst_dcb_unused = 1'b0;
      assign dcm_sbam_second_burst_dcb_unused = 1'b0;
      assign dcm_sbam_tokens_allocated_dcb_unused = {(MEMC_NO_OF_ENTRY_LG2+1){1'b0}};

      // RRB for channel 1
      DWC_ddr_umctl2_xpi_rrb
      
        #(.RDATARAM_DW   (RDATARAM_DW_INT),
          .INFOW         (RRBIW), 
          .RINFO_ADROFFST_LSB  (RINFO_ADROFFST_LSB),
          .PDBW_CASE        (PDBW_CASE),

          .NTOKENS       (MEMC_NO_OF_ENTRY),
          .NBEATS        (NBEATS),
          .NBEATS_LG2    (NBEATS_LG2),
          .BEAT_INFOW    (BEAT_INFOW),
          .NTOKENS_LG2   (MEMC_NO_OF_ENTRY_LG2),
          .RRB_EXTRAM    (RRB_EXTRAM),
          .RDATARAM_AW   (RDATARAM_AW),
          .A_BLW         (A_BLW),
          .OCCAP_EN      (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
          .NUM_VIR_CH    (NUM_VIR_CH),
          .NUM_VIR_CH_LG2(NUM_VIR_CH_LG2),
          .NUM_CH        (NUM_CH),
          .NUM_CH_LG2    (NUM_CH_LG2),
          .USE2RAQ       (USE2RAQ),
          .READ_DATA_INTERLEAVE_EN (READ_DATA_INTERLEAVE_EN),
          .RRB_THRESHOLD_EN  (RRB_THRESHOLD_EN),
          .RRB_THRESHOLD_PPL (RRB_THRESHOLD_PPL),
          .STATIC_VIR_CH  (STATIC_VIR_CH),
          .IDW            (AXI_IDW),
          .RPINFOW        (RPINFOW),
          .INTLVMODEW     (INTLVMODEW),
          .BAM_OFFSW      (BAM_OFFSW),   //for consistency
          .MAXSIZE        (MAXSIZE), //for consistency
          .AXI_MAXSIZE    (AXI_MAXSIZE),
          .M_DW           (M_DW),
          .USE_BAM        (USE_BAM),
          .RDATARAM_DEPTH (RDATARAM_DEPTH),
          .MIN_M_BL       (MIN_M_BL),
          .BRW            (BRW)
          )
      U_xpi_rrb
        (
         // Outputs
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
         .q                                   (rrb_q_dcb_unused[RDATARAM_DW_INT-1:0]),
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(RRBIW - 1)' found in module 'DWC_ddr_umctl2_xpi'
//SJ: This coding style is acceptable and there is no plan to change it.
         .infoq                               (rrb_infoq_dcb[RRBIW-1:0]),
//spyglass enable_block SelfDeterminedExpr-ML
         .rd_last                             (rrb_rd_last_i_dcb),
         .q_ch_num                            (rrb_ch_num_i_dcb),
         .empty                               (rrb_empty_dcb),
         .full                                (rrb_full_dcb),
         .release_token                       (rrb_release_token_dcb_unused),
         .xpi_rrb_parity_err                  (occap_xpi_rrb_par_err_dcb),
         .rtoken                              (rrb_rtoken_dcb[MEMC_NO_OF_ENTRY_LG2-1:0]),
         .dcr_token                           (rrb_token_dcb),
         .rdataram_raddr                      (rrb_rdataram_raddr_dcb[RDATARAM_AW-1:0]),
         .rdataram_waddr                      (rrb_rdataram_waddr_dcb[RDATARAM_AW-1:0]), 
         .rerror_q                            (rrb_rerror_i_dcb),
         .bam_is_active                       (bam_is_active), 
         .reg_ddrc_data_bus_width             (reg_ddrc_data_bus_width),
         .rrb_is_locked                       (rrb_is_locked_dcb),
         .locked_ch                           (locked_ch_dcb),
//spyglass enable_block W528     
         // Inputs
         .clk                                 (e_clk),
         .rst_n                               (e_rst_n),
         .wr                                  (rrb_wr_dcb),
         .rd                                  (rrb_rd_i_dcb),
         .d                                   (rrb_d_dcb[RDATARAM_DW_INT-1:0]),
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(RRBIW - 1)' found in module 'DWC_ddr_umctl2_xpi'
//SJ: This coding style is acceptable and there is no plan to change it.
         .infod                               (rrb_infod_dcb[RRBIW-1:0]),
//spyglass enable_block SelfDeterminedExpr-ML
         .wr_addr                             (rtoken_dcb[MEMC_NO_OF_ENTRY_LG2-1:0]),
         .gen_token                           (gen_token_rrb_dcb),
         .atoken                              (atoken_rrb_dcb),
         .bam_addr_offset                     (bam_addr_offset),
         .bam_lead_burst                      (1'b0), //BAM support unavaliable of dch
         .bam_arlast                          (1'b1), //BAM support unavaliable for dch
         .bam_red_token                       (1'b0), //BAM support unavaliable for dch
         .abypass_reorder                     (abypass_reorder_rrb_dcb),
         .reg_ddrc_occap_en                   (reg_ddrc_occap_en),
         .ch_num                              (ch_num_rrb_dcb),
         .valid_dcr                           (valid_dcr_dcb),
         .vtq_empty                           (vtq_empty_dcb),
         .rbypass_reorder                     (hif_bypass_reorder_dcb),
         .a_bl                                (a_bl[A_BLW-1:0]), // common
         .rerror_d                            (hif_rerror_dcb),
         .sbam_lead_burst                     (dcm_sbam_lead_burst_dcb_unused),
         .sbam_second_burst                   (dcm_sbam_second_burst_dcb_unused),
         .sbam_tokens_allocated               (dcm_sbam_tokens_allocated_dcb_unused),
         .reg_ddrc_burst_rdwr                 (reg_ddrc_burst_rdwr),
         .locked_ch_raq_red                   (rrb_tm_locked_ch_raq_red_dcb)
         );

   end
   else begin: Single_DCH_RRB
      // Single channel, no arbitration after RRB
      //assign dch_sel                = 2'b01;
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      assign rrb_q_dcb_unused       = {RDATARAM_DW_INT{1'b0}};
      assign rrb_infoq_dcb          = {RRBIW{1'b0}};
      assign rrb_rd_last_i_dcb      = 1'b0;
      assign rrb_ch_num_i_dcb       = {NUM_CH_LG2{1'b0}};
      assign rrb_empty_dcb          = 1'b0;
      assign rrb_full_dcb           = 1'b0;
      assign rrb_release_token_dcb_unused  = 1'b0;
      assign rrb_rtoken_dcb         = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign atoken_rrb_dcb_dcm     = {DCM_NTOKENS_LG2{1'b0}};  
      assign vtq_empty              = vtq_empty_dca;  
      assign rrb_rtoken_dcm         = rrb_rtoken_dca;    
      assign rrb_release_token      = rrb_release_token_dca;  
      assign xpi_rd_arid            = gen_token_blue? xpi_rd_arid_blue:xpi_rd_arid_red; // TODO (dual queue + dual channel support)                   
      assign atoken_dcm             = atoken;     
      assign rrb_rdataram_raddr_dcb = {RDATARAM_AW{1'b0}};
      assign rrb_rdataram_waddr_dcb = {RDATARAM_AW{1'b0}};
      assign gen_token_rrb_dca      = gen_token_rrb;
      assign gen_token_rrb_dcb      = 1'b0;
      assign atoken                 = atoken_dca; // no need for muxing when shared-ac and no interleaving, atoken_dca is copied to atoken_dcb
      assign dcr_empty_unused       = 1'b0;
      assign valid_dcr_dca          = {NUM_VIR_CH{1'b1}};
      assign valid_dcr_dcb          = {NUM_VIR_CH{1'b1}};
      assign tm_rtoken_dcb          = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign tm_release_token_dca   = rrb_release_token_dca;
      assign tm_rtoken_dca          = rrb_rtoken_dca;
      assign dcr_rtoken_dca         = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign dcr_rtoken_dcb         = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign rrb_token_dcb          = {MEMC_NO_OF_ENTRY_LG2{1'b0}};
      assign rrb_rtoken_dca_pn      = {DCM_NTOKENS_LG2{1'b0}};
      assign rrb_rtoken_dcb_pn      = {DCM_NTOKENS_LG2{1'b0}};
      assign tm_release_token_dcb   = 1'b0;
      assign dcr_release_token_dca  = 1'b0;
      assign dcr_release_token_dcb  = 1'b0;
      assign vtq_empty_dcb          = {NUM_VIR_CH{1'b0}};
      assign occap_xpi_rrb_par_err_dcb = 1'b0;
      assign occap_xpi_dcr_par_err        = 1'b0;
//spyglass enable_block W528
   end
   endgenerate
  
  //--------------------------------------------------------------------------------
  //  Read Modify Write generator
  //--------------------------------------------------------------------------------
  generate
    if (M_USE_RMW==1) begin: GEN_rmw_inst

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      assign xpi_snf_mode_i = reg_xpi_rmw_mode_ie | reg_xpi_rmw_mode_nonie | reg_xpi_snf_mode;
//spyglass enable_block W528
      
      DWC_ddr_umctl2_xpi_rmw
       
        #(.ADDRW                               (M_ADDRW),
          .IDW                                 (AXI_IDW),
          .NAB                                 (NAB),
          .M_ECC                               (M_ECC),
          .M_SIDEBAND_ECC                      (M_SIDEBAND_ECC),
          .M_INLINE_ECC                        (M_INLINE_ECC),
          .QOSW                                (AXI_QOSW),
          .DATAW                               (A_DW_INT),
          .STRBW                               (A_STRBW_INT),
          .PARW                                (A_PARW_INT),
          .AXI_USERW                           (AXI_USERW),
          .WDQD                                (XPI_RMW_WDQD),
          .EXA_PYLD_W                          (EXA_PYLD_W),
          .ORDER_TOKENW                        (ORDER_TOKENW),
          .WARD                                (RMW_WARD),
          .NBEATS                              (NBEATS),
          .NBEATS_LG2                          (NBEATS_LG2),
          .CMD_LEN_BITS                        (CMD_LEN_BITS),
          .OCCAP_EN                            (OCCAP_EN),
          .OCCAP_PIPELINE_EN                   (OCCAP_PIPELINE_EN),
          .MEMC_BURST_LENGTH                   (MEMC_BURST_LENGTH),
          .VPW_EN                              (VPW_EN),
          .VPRW                                (VPRW),
          .WQOS_RW                             (WQOS_RW),
          .WQOS_TW                             (WQOS_TW),
          .OCPAR_EN                            (OCPAR_EN),   
          .OCECC_EN                            (OCECC_EN),   
          .DUAL_CHANNEL_INTERLEAVE             (DUAL_CHANNEL_INTERLEAVE),
          .DATA_CHANNEL_INTERLEAVE_NS          (DATA_CHANNEL_INTERLEAVE_NS),
          .DEACC_INFOW                         (DEACC_INFOW),
          .DBW                                 (DBW),
          .XPI_USE_RMWR_EN                     (XPI_USE_RMWR_EN))
      U_xpi_rmw     
        (
         // Outputs
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
         .rmw_awready                         (rmw_awready),
         .rmw_wready                          (rmw_wready),
         .rmw_awaddr                          (xpi_awaddr_i),
         .rmw_awdata_channel                  (xpi_awdata_channel),
         .rmw_awlast                          (xpi_awlast),
         .rmw_split                           (xpi_rmw_split),
         .rmw_short_burst                     (xpi_rmw_short_burst),
         .rmw_awrmw                           (xpi_awrmw_i),
         .rmw_wdata_mask_full                 (xpi_wdata_mask_full_i),
         .rmw_awid                            (xpi_awid),
         .rmw_awqos                           (xpi_awqos_i),
         .rmw_awuser                          (xpi_awuser_i),
         .rmw_wpoison                         (xpi_wpoison),
         .rmw_ocpar_err                       (xpi_ocpar_err),
         .rmw_awpagematch                     (xpi_awpagematch_i),
         .rmw_awautopre                       (xpi_awautopre_i),
         .rmw_awvalid                         (rmw_awvalid),
         .rmw_wdata                           (xpi_wdata_i),
         .rmw_wdata_channel                   (xpi_wdata_channel),
         .rmw_wstrb                           (xpi_wstrb_i),
         .rmw_wlast                           (xpi_wlast_i),
         .rmw_wvalid                          (xpi_wvalid),
         .rmw_wpar_err                        (xpi_wpar_err_i),
         .rmw_wparity                         (xpi_wparity_i),
         .rmw_wlast_pkt                       (xpi_wlast_pkt_i),
         .rmw_wexa_acc                        (xpi_wexa_acc),
         .rmw_wexa_pyld                       (xpi_wexa_pyld_i),
         .rmw_wexa_acc_lock                   (xpi_wexa_acc_lock),
         .rmw_wqos_priority                   (xpi_wqos_priority_i),
         .rmw_wqos_timeout                    (xpi_wqos_timeout_i),
         .rmw_vpw_expired                     (xpi_vpw_expired_i),
         .rmw_write_order_token               (rmw_write_order_token),
         .rmw_deacc_info                      (xpi_deacc_info),
         .rmw_awvalid_iecc                    (xpi_awvalid_iecc_i),
         .rmw_awlast_iecc                     (xpi_awlast_iecc_i),
         .rmw_occap_par_err                   (occap_xpi_rmw_par_err),
//spyglass enable_block W528
         // Inputs
         .clk                                 (e_clk),
         .rst_n                               (e_rst_n),
         .wperq_rd                            ((hif_bvalid_dca & xpi_bready_dca) | ((hif_bvalid_dcb & xpi_bready_dcb))), 
         .reg_xpi_dm_dis                      (reg_xpi_dm_dis),
         .reg_xpi_rmw_mode_ie                 (reg_xpi_rmw_mode_ie),
         .reg_xpi_rmw_mode_nonie              (reg_xpi_rmw_mode_nonie),
         .reg_ddrc_ecc_type                   (reg_ddrc_ecc_type),
         .reg_ddrc_ecc_mode                   (reg_ddrc_ecc_mode),
         .reg_ddrc_multi_beat_ecc             (reg_ddrc_multi_beat_ecc),
         .reg_ddrc_occap_en                   (reg_ddrc_occap_en),
         .reg_ddrc_data_bus_width             (reg_ddrc_data_bus_width),
         .reg_mbl16_bl8_bc_crc_dis_nab3       (reg_mbl16_bl8_bc_crc_dis_nab3),
         .reg_xpi_snf_mode                    (reg_xpi_snf_mode),
         .xpi_wr_awaddr                       (xpi_wr_awaddr),
         .xpi_wr_awdata_channel               (xpi_wr_awdata_channel),
         .xpi_wr_awlast                       (xpi_wr_awlast),
         .xpi_wr_split                        (xpi_wr_split),
         .xpi_wr_short_burst                  (xpi_wr_short_burst),
         .xpi_wr_awid                         (xpi_wr_awid),
         .xpi_wr_awqos                        (xpi_wr_awqos),
         .xpi_wr_awuser                       (xpi_wr_awuser),
         .xpi_wr_wpoison                      (xpi_wr_wpoison),
         .xpi_wr_ocpar_err                    (xpi_wr_ocpar_err),
         .xpi_wr_awpagematch                  (xpi_wr_awpagematch),
         .xpi_wr_awautopre                    (xpi_wr_awautopre),
         .xpi_wr_awvalid                      (xpi_wr_awvalid),
         .xpi_wr_write_order_token            (xpi_write_order_token),
         .xpi_wr_wdata                        (xpi_wr_wdata),
         .xpi_wr_wdata_channel                (xpi_wr_wdata_channel),
         .xpi_wr_deacc_info                   (xpi_wr_deacc_info),
         .xpi_wr_wstrb                        (xpi_wr_wstrb),
         .xpi_wr_wlast                        (xpi_wr_wlast),
         .xpi_wr_wvalid                       (xpi_wr_wvalid),
         .xpi_wr_wpar_err                     (xpi_wr_wpar_err),
         .xpi_wr_wparity                      (xpi_wr_wparity),
         .xpi_wr_wlast_pkt                    (xpi_wr_wlast_pkt),
         .xpi_short_write                     (xpi_short_write),
         .xpi_wr_beat_count                   (xpi_wr_beat_count),
         .hif_awready                         (post_arb_awready),
         .hif_wready                          (hif_wready),
         .xpi_wr_exa_acc                      (xpi_wr_exa_acc),
         .xpi_wr_exa_pyld                     (xpi_wr_exa_pyld),
         .xpi_wr_exa_acc_lock                 (xpi_wr_exa_acc_lock),
         .xpi_wr_wqos_timeout                 (xpi_wr_wqos_timeout),
         .xpi_wr_vpw_expired                  (xpi_wr_vpw_expired),
         .xpi_wr_wqos_priority                (xpi_wr_wqos_priority),
         .xpi_wr_awvalid_iecc                 (xpi_wr_iecc_blk_valid),
         .xpi_wr_awlast_iecc                  (xpi_wr_iecc_blk_end)
         );
    end
    
    if (M_USE_RMW==0) begin: rmw_bypass
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      assign xpi_awrmw_i            = 1'b0;
      assign xpi_wdata_mask_full_i  = {NBEATS{1'b0}};
      assign occap_xpi_rmw_par_err  = 1'b0;
      assign xpi_wqos_timeout_i     = xpi_wr_wqos_timeout;
      assign xpi_wqos_priority_i    = xpi_wr_wqos_priority;
      assign xpi_vpw_expired_i      = xpi_wr_vpw_expired;
      assign xpi_awaddr_i           = xpi_wr_awaddr; 
      assign xpi_awdata_channel     = xpi_wr_awdata_channel;
      assign xpi_awlast             = xpi_wr_awlast;
      assign xpi_rmw_split          = xpi_wr_split;
      assign xpi_rmw_short_burst    = xpi_wr_short_burst;
      assign xpi_awid               = xpi_wr_awid;
      assign xpi_awqos_i            = xpi_wr_awqos;
      assign xpi_awuser_i           = xpi_wr_awuser;
      assign xpi_wpoison            = xpi_wr_wpoison;
      assign xpi_ocpar_err          = xpi_wr_ocpar_err;
      assign xpi_awpagematch_i      = xpi_wr_awpagematch;
      assign xpi_awautopre_i        = xpi_wr_awautopre;
      assign rmw_awvalid            = xpi_wr_awvalid;
      assign xpi_wdata_i            = xpi_wr_wdata;
      assign xpi_wdata_channel      = xpi_wr_wdata_channel;
      assign xpi_wlast_i            = xpi_wr_wlast;
      assign xpi_wlast_pkt_i        = xpi_wr_wlast_pkt;
      assign xpi_wstrb_i            = xpi_wr_wstrb;
      assign xpi_wvalid             = xpi_wr_wvalid;
      assign xpi_wpar_err_i         = xpi_wr_wpar_err;
      assign xpi_wparity_i          = xpi_wr_wparity;
      assign rmw_awready            = post_arb_awready;
      assign rmw_wready             = hif_wready;     
      assign xpi_wexa_acc           = xpi_wr_exa_acc;
      assign xpi_wexa_pyld_i        = xpi_wr_exa_pyld;
      assign xpi_wexa_acc_lock      = xpi_wr_exa_acc_lock;
      assign rmw_write_order_token  = xpi_write_order_token;
      assign xpi_deacc_info         = xpi_wr_deacc_info;
      assign xpi_awvalid_iecc_i     = xpi_wr_iecc_blk_valid;
      assign xpi_awlast_iecc_i      = xpi_wr_iecc_blk_end;
      assign xpi_snf_mode_i         = 1'b0;
//spyglass enable_block W528
    end
  endgenerate


  localparam NUM_URGENT = 3;

  wire [NUM_URGENT-1:0] urgent_in, urgent_out;

  assign urgent_in = {awurgent,arurgentr,arurgentb};
  //spyglass disable_block W528
  //SMD: Variable arurgentr_r is set but never read
  //SJ: Used in generate block
  assign {awurgent_r,arurgentr_r,arurgentb_r} = urgent_out;
  //spyglass enable_block W528

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (NUM_URGENT),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
   )
   U_urgent
   (
      .clk        (aclk),
      .rst_n      (aresetn),
      .data_in    (urgent_in),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (urgent_out),
      .parity_err (occap_urgent_par_err)
   );

  generate
    if (AXI_SYNC==0) begin: urgent_asynch

      //--------------------------------------------------------------------------------
      //  Urgent Synchronizer
      //--------------------------------------------------------------------------------

      DWC_ddr_umctl2_bitsync
      
      #( .BCM_SYNC_TYPE   (ASYNC_FIFO_N_SYNC),
         .BCM_VERIF_EN    (BCM_VERIF_EN))
      U_rurgent_sync
      (  .clk_d          (e_clk),
         .rst_d_n        (e_rst_n),
         .data_s         (arurgentb_r),
         .data_d         (arurgentb_out));

      DWC_ddr_umctl2_bitsync
      
      #( .BCM_SYNC_TYPE   (ASYNC_FIFO_N_SYNC),
         .BCM_VERIF_EN    (BCM_VERIF_EN))
      U_wurgent_sync
      (  .clk_d          (e_clk),
         .rst_d_n        (e_rst_n),
         .data_s         (awurgent_r),
         .data_d         (awurgent_out));


      if (USE2RAQ==1) begin: red_urgent_async

         DWC_ddr_umctl2_bitsync
         
         #( .BCM_SYNC_TYPE   (ASYNC_FIFO_N_SYNC),
            .BCM_VERIF_EN    (BCM_VERIF_EN))
         U_rurgent_sync
         (  .clk_d          (e_clk),
            .rst_d_n        (e_rst_n),
            .data_s         (arurgentr_r),
            .data_d         (arurgentr_out));


      end else begin: red_urgent_zero

        assign arurgentr_out = 1'b0;

      end

    end else begin: urgent_synch

      assign arurgentr_out = arurgentr_r;
      assign arurgentb_out = arurgentb_r;
      assign awurgent_out  = awurgent_r;
    end
  endgenerate


  assign rurgent_blue    = arurgentb_out;
  assign rurgent_red     = arurgentr_out;
  assign wurgent_blue    = awurgent_out;
  assign wurgent_red     = 1'b0; // not used

  
  //--------------------------------------------------------------------------------
  //  AXI Low Power Interface
  //--------------------------------------------------------------------------------
  wire i_cactive;
  wire i_cactive_reg_unused;

  DWC_ddr_umctl2_xpi_lpfsm
  
    #(.LOWPWR_NOPX_CNT     (LOWPWR_NOPX_CNT),
      .LOWPWR_NOPX_CNT_W   (LOWPWR_NOPX_CNT_W),
      .OCCAP_EN            (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN)
    )
  U_xpi_lpfsm
    (
     // Inputs 
     .aclk          (aclk),
     .aresetn       (aresetn),
     .active_trans  (active_trans),
     .csysreq       (csysreq),
     .reg_ddrc_occap_en (reg_ddrc_occap_en), 
     // Output
     .cactive       (i_cactive),
     .csysack       (csysack),
     .ready         (ready_lp),
     .occap_xpi_lpfsm_par_err (occap_xpi_lpfsm_par_err)
     );

  assign cactive = i_cactive | ddrc_xpi_clock_required;
  
  // Generate active_trans signal for lpfsm to know when it is
  // safe to enter low power mode.
  assign active_writes =  (outstanding_writes == 0) ? 1'b0 : 1'b1;
  assign active_reads  =  (outstanding_reads == 0) ? 1'b0 : 1'b1;
  assign active_trans  = active_writes | ~wdq_empty_aclk | active_reads | awvalid | arvalid | wvalid;
  assign cactive_out   = cactive_reg; // in a_clk domain 
  // Count the number of outstanding AXI write/read transactions 

   wire [BUSY_REGS_W-1:0] busy_r_in, busy_r_out;

   // continue to use i_cactive in busy occap protection but output i_cactive_reg_unused is unused
   assign busy_r_in = {i_cactive, rd_port_busy_next,wr_port_busy_next,outstanding_writes_next,outstanding_reads_next,posted_write_beats_next};
   assign {i_cactive_reg_unused, rd_port_busy,wr_port_busy,outstanding_writes,outstanding_reads,posted_write_beats_reg} = busy_r_out;

   always @(posedge aclk or negedge aresetn) begin
     if (aresetn == 1'b0) begin
       cactive_reg <= 1'b0;
     end else begin
       cactive_reg <= cactive_reg_next;
     end
   end


   assign rd_port_busy_next         = active_reads;
   assign wr_port_busy_next         = active_writes | ~wdq_empty_aclk | wait_data_ch_lock | wait_addr_ch_lock;
   assign cactive_reg_next          = cactive;
   assign outstanding_writes_next   = (awvalid & awready & ~(bvalid & bready)) ? outstanding_writes + 1 :
                                      (~(awvalid & awready) & bvalid & bready) ? outstanding_writes - 1 : outstanding_writes;
   assign outstanding_reads_next    = (arvalid & arready & ~(rvalid & rready & rlast)) ? outstanding_reads + 1 :
                                      (~(arvalid & arready) & rvalid & rready & rlast) ? outstanding_reads - 1 : outstanding_reads;
//spyglass disable_block W164a
//SMD: LHS: 'posted_write_beats_next' width 16 is less than RHS: '(posted_write_beats_reg + awlen)' width 17 in assignment 
//SJ: Overflow/underflow is not expected. We have an assertion, a_posted_writes_overflow, to check unexpected behavior. See bug5632, comment #19.
   always @(*)begin
      if ((awvalid & awready) & ~(wvalid & wready))
         posted_write_beats_next =  posted_write_beats_reg + awlen+1;
      else if  ((awvalid & awready) & (wvalid & wready))
         posted_write_beats_next =  posted_write_beats_reg + awlen;
      else if  (~(awvalid & awready) & (wvalid & wready))
         posted_write_beats_next =  posted_write_beats_reg -1;
      else
         posted_write_beats_next = posted_write_beats_reg;
   end
//spyglass enable_block W164a
               
   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (BUSY_REGS_W),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
   )
   U_busy
   (
      .clk        (aclk),
      .rst_n      (aresetn),
      .data_in    (busy_r_in),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (busy_r_out),
      .parity_err (occap_busy_par_err)
   );

  assign posted_write_data_exist = posted_write_beats_next[POSTED_WRBW-1];
  assign posted_write_addr_exist_unused = ~posted_write_beats_next[POSTED_WRBW-1] & |posted_write_beats_next[POSTED_WRBW-2:0];

generate 
if(PDBW_CASE!=0) begin : pdbwcase

//Instantiate Converger for rdata
  DWC_ddr_umctl2_xpi_cnvg
   
  #(
    .ENIF_DATAW (A_DW ),
    .NAB        (NAB        ),
    .XBW_CHK    (M_DW       ),
    .M_DW       (M_DW       )
  )
  u_xpi_cnvg(
    .in_data   (hif_hif_rdata_dca_i   ),
    .bus_width (reg_ddrc_data_bus_width ),
    .out_data  (cnvg_hif_rdata_dca  )
  );

//Instantiate Converger for rdata parity
  DWC_ddr_umctl2_xpi_cnvg
   
  #(
    .ENIF_DATAW (A_STRBW ),
    .NAB        (NAB     ),
    .XBW_CHK    (M_DW       ),
    .M_DW       (M_DW/8  )
  )
  u_xpi_cnvg_par(
    .in_data   (hif_hif_rdata_parity_dca_i ),
    .bus_width (reg_ddrc_data_bus_width ),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
    .out_data  (cnvg_hif_rdata_parity_dca  )
//spyglass enable_block W528
  );

 if (DUAL_CHANNEL_INTERLEAVE==1) begin: DualDch 
  //Instantiate Converger for second channel
   DWC_ddr_umctl2_xpi_cnvg
    
   #(
     .ENIF_DATAW (A_DW ),
     .NAB        (NAB        ),
     .XBW_CHK    (M_DW       ),
     .M_DW       (M_DW       )
   )
   u_xpi_cnvg_ch1(
    .in_data   (hif_hif_rdata_dcb  ),
    .bus_width (reg_ddrc_data_bus_width ),
    .out_data  (cnvg_hif_rdata_dcb  )
   );

  //Instantiate Converger for rdata parity
   DWC_ddr_umctl2_xpi_cnvg
    
   #(
     .ENIF_DATAW (A_STRBW ),
     .NAB        (NAB     ),
     .XBW_CHK    (M_DW       ),
     .M_DW       (M_DW/8  )
   )
   u_xpi_cnvg_par_ch1(
     .in_data   (hif_hif_rdata_parity_dcb ),
     .bus_width (reg_ddrc_data_bus_width ),
     .out_data  (cnvg_hif_rdata_parity_dcb  )
   );
   
 end
end else begin : No_PDBW
  assign cnvg_hif_rdata_dca = hif_hif_rdata_dca_i;
  assign cnvg_hif_rdata_dcb = hif_hif_rdata_dcb;
  assign cnvg_hif_rdata_parity_dca = hif_hif_rdata_parity_dca_i;
  assign cnvg_hif_rdata_parity_dcb = hif_hif_rdata_parity_dcb;
end
endgenerate

  generate
    if (HWFFC_EN==1) begin: HWFFC_en
      if (AXI_SYNC==0) begin: hwffc_asynch

        //--------------------------------------------------------------------------------
        //  Synchronizer
        //--------------------------------------------------------------------------------

        DWC_ddr_umctl2_bitsync
        
        #( .BCM_SYNC_TYPE   (ASYNC_FIFO_N_SYNC),
           .BCM_VERIF_EN    (BCM_VERIF_EN))
        U_port_disable_req
        (  .clk_d          (aclk),
           .rst_d_n        (aresetn),
           .data_s         (ddrc_xpi_port_disable_req),
           .data_d         (ddrc_xpi_port_disable_req_sync));

      end else begin: hwffc_synch
        reg     port_disable_req_sync;

        always @(posedge aclk or negedge aresetn) begin
          if (aresetn == 1'b0) begin
            port_disable_req_sync <= 1'b0;
          end else begin
            port_disable_req_sync <= ddrc_xpi_port_disable_req;
          end
        end

        assign ddrc_xpi_port_disable_req_sync = port_disable_req_sync;
      end

      reg   port_disable_req_sync_r;
      reg   port_disable_ack;
      reg   wch_locked;

      always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0) begin
          port_disable_req_sync_r <= 1'b0;
        end
        else begin
          port_disable_req_sync_r <= ddrc_xpi_port_disable_req_sync;
        end
      end

      always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0) begin
          port_disable_ack <= 1'b0;
        end
        else if (ddrc_xpi_port_disable_req_sync == 1'b0) begin
          port_disable_ack <= 1'b0;
        end
        else if (port_disable_req_sync_r & ~(rd_port_busy | wr_port_busy)) begin
          port_disable_ack <= 1'b1;
        end
      end

      always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0) begin
          wch_locked <= 1'b0;
        end
        else if (ddrc_xpi_port_disable_req_sync == 1'b0) begin
          wch_locked <= 1'b0;
        end
        else if (port_disable_req_sync_r & ~write_data_ch_en) begin
          wch_locked <= 1'b1;
        end
      end

      assign xpi_ddrc_port_disable_ack = port_disable_ack;
      assign xpi_ddrc_wch_locked = wch_locked;

    end
  else begin: HWFFC_dis // HWFFC_EN!=1

      assign ddrc_xpi_port_disable_req_sync = 1'b0;
      assign xpi_ddrc_port_disable_ack = 1'b0;
      assign xpi_ddrc_wch_locked = 1'b0;

    end
  endgenerate


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
 
  // Outstanding writes counter overflow during increment
  property p_outstanding_writes_overflow;
  @(posedge aclk) disable iff(!aresetn) 
    (awvalid & awready & ~(bvalid & bready)) |-> (outstanding_writes<2**OUTS_WRW-1);
  endproperty  
  a_outstanding_writes_overflow : assert property (p_outstanding_writes_overflow) else 
    $display("-> %0t ERROR: XPI outstanding writes counter overflow!!!", $realtime);
  
  // Outstanding writes counter underflow during decrement
  property p_outstanding_writes_underflow;
    @(posedge aclk) disable iff(!aresetn) 
      (~(awvalid & awready) & bvalid & bready) |-> (outstanding_writes>0);
  endproperty  

  a_outstanding_writes_underflow : assert property (p_outstanding_writes_underflow) else 
    $display("-> %0t ERROR: XPI outstanding writes counter underflow !!!", $realtime);   

  // Outstanding reads counter overflow during increment
  property p_outstanding_reads_overflow;
    @(posedge aclk) disable iff(!aresetn) 
      (arvalid & arready & ~(rvalid & rready & rlast)) |-> (outstanding_reads<2**OUTS_RDW-1);
  endproperty  
  a_outstanding_reads_overflow : assert property (p_outstanding_reads_overflow) else 
    $display("-> %0t ERROR: XPI outstanding reads counter overflow!!!", $realtime);
  
  // Outstanding reads counter underflow during decrement
  property p_outstanding_reads_underflow;
    @(posedge aclk) disable iff(!aresetn) 
      (~(arvalid & arready) & rvalid & rready & rlast) |-> (outstanding_reads>0);
  endproperty  

  a_outstanding_reads_underflow : assert property (p_outstanding_reads_underflow) else 
    $display("-> %0t ERROR: XPI outstanding reads counter underflow !!!", $realtime);   

   localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time 
    

  //
  // AXI interface assertions  
  //
  //FMC Bind VCS checker library assertions to XPI in testbench
  // Check that the AXI burst type is not set to FIXED. Only INCR and WRAP types are supported.
  assert_never #(0, 0, "AXI write burst type FIXED not supported", CATEGORY) a_xpi_awburst_invalid
    (aclk, aresetn, (awvalid && awready && awburst==2'b00));

  assert_never #(0, 0,"Both gen_token for channel A high at the same time", CATEGORY) a_xpi_gen_token_dca_invalid
    (aclk, aresetn, (gen_token_blue_dca && gen_token_red_dca));

  assert_never #(0, 0,"Both gen_token for channel B high at the same time", CATEGORY) a_xpi_gen_token_dcb_invalid
    (aclk, aresetn, (gen_token_blue_dcb && gen_token_red_dcb));

  assert_never #(0, 0,"Both gen_token (A and B) high at the same time", CATEGORY) a_xpi_gen_token_invalid
    (aclk, aresetn, (gen_token_dca && gen_token_dcb)); // TODO (to be done for dual queue)

  assert_never #(0, 0, "AXI read burst type FIXED not supported", CATEGORY) a_xpi_arburst_invalid
    (aclk, aresetn, (arvalid && arready && arburst==2'b00));  

  // Coverge point for AXI write and read address signals asserted at the same time 
  cp_xpi_wr_rd_addr_valid :
    cover property (@(posedge aclk) awvalid && arvalid
                    );

  // Read data must be accepted by XPI RRB when DDRC push it (hif_rvalid)
  property p_hif_rvalid_e_rready;
    @(posedge e_clk) disable iff(!e_rst_n) 
      (hif_rvalid_dca) |-> (xpi_rready);
  endproperty 

  a_hif_rvalid_e_rready : assert property (p_hif_rvalid_e_rready) else 
      $display("-> %0t ERROR: hif_rvalid asserted when xpi_rready is low", $realtime);

  property p_hif_rvalid_e_rready_dcb;
    @(posedge e_clk) disable iff(!e_rst_n) 
      (hif_rvalid_dcb) |-> (xpi_rready_dcb);
  endproperty 

  a_hif_rvalid_e_rready_dcb : assert property (p_hif_rvalid_e_rready_dcb) else 
      $display("-> %0t ERROR: hif_rvalid asserted when xpi_rready is low", $realtime);
  //
  // Port enable functional coverage
  //
  wire posted_write_data;
  reg reg_arb_port_en_old;
  wire reg_arb_port_en_toggle_low;
  wire reg_arb_port_en_toggle_high;
    
  always @ (posedge aclk )
    reg_arb_port_en_old <= i_reg_arb_port_en;

  assign reg_arb_port_en_toggle_low = (i_reg_arb_port_en==0 && reg_arb_port_en_old==1) ? 1'b1:1'b0;
  assign reg_arb_port_en_toggle_high = (i_reg_arb_port_en==1 && reg_arb_port_en_old==0) ? 1'b1:1'b0;    
    
  assign posted_write_data= posted_write_beats_reg[POSTED_WRBW-1];
    
  // Posted writes counter overflow during increment
  property p_posted_writes_overflow;
    @(posedge aclk) disable iff(!aresetn) 
      (awvalid & awready &~posted_write_data) |-> (posted_write_beats_reg<2**(POSTED_WRBW-1)-1);
  endproperty  
  
  a_posted_writes_overflow : assert property (p_posted_writes_overflow) else 
      $display("-> %0t ERROR: XPI posted writes counter overflow!!!", $realtime);

  // Port disabled while posted write data
  cp_xpi_port_en_toggle_low_posted_wdata :
    cover property (
       @(posedge aclk) disable iff(!aresetn)
       reg_arb_port_en_toggle_low && posted_write_data
    );

  // Port enabled while posted write data is not cleared
  cp_xpi_port_en_toggle_high_posted_wdata :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
          reg_arb_port_en_toggle_high && posted_write_data
        );
        
  // Port enable toggle and AWVALID high while AWREADY low
  // This will cause AWVALID to be retracted to the XPI logic  
  cp_xpi_port_en_toggle_low_awvalid_high :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && awvalid==1 && awready==0
        );

  // Port enable toggle and ARVALID high while ARREADY low
  // This will cause ARVALID to be retracted to the XPI logic  
  cp_xpi_port_en_toggle_low_arvalid_high :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && arvalid==1 && arready==0
        );
  // Port enable toggle and AWVALID high while AWREADY low
  // This will cause AWVALID to be retracted to the XPI logic  
  cp_xpi_port_en_toggle_high_awvalid_high :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
         reg_arb_port_en_toggle_high && awvalid==1 && awready==0
    );
  // Port enable toggle and ARVALID high while ARREADY low
  // This will cause ARVALID to be retracted to the XPI logic  
  cp_xpi_port_en_toggle_high_arvalid_high :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_high && arvalid==1 && arready==0
    );
                
  // Port enable toggle_low no posted write data
  cp_xpi_port_en_toggle_low_no_posted_write_data :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && posted_write_beats_reg==0
    );

  // Port enable toggle_low one posted write data beat 
  cp_xpi_port_en_toggle_low_one_posted_write_data :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && posted_write_beats_reg==({POSTED_WRBW{1'b1}}-1)
    );

  // Port enable toggle_low outstanding writes
  cp_xpi_port_en_toggle_low_outstanding_writes :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && active_writes==1
    );
  // Port enable toggle_low no outstanding writes
  cp_xpi_port_en_toggle_low_no_outstanding_writes :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && active_writes==0
   );

  // Port enable toggle_low outstanding reads
  cp_xpi_port_en_toggle_low_outstanding_reads :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && active_reads==1
  );
  // Port enable toggle_low no outstanding reads
  cp_xpi_port_en_toggle_low_no_outstanding_reads :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_low && active_reads==0
  );

  // Port enable toggle_high outstanding writes
  cp_xpi_port_en_toggle_high_outstanding_writes :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_high && active_writes==1
  );
  // Port enable toggle_high no outstanding writes
  cp_xpi_port_en_toggle_high_no_outstanding_writes :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_high && active_writes==0
  );

  // Port enable toggle_high outstanding reads
  cp_xpi_port_en_toggle_high_outstanding_reads :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_high && active_reads==1
  );
  // Port enable toggle_high no outstanding reads
  cp_xpi_port_en_toggle_high_no_outstanding_reads :
    cover property (
        @(posedge aclk) disable iff(!aresetn)
        reg_arb_port_en_toggle_high && active_reads==0
  );

  wire read_data_int_check_en;
     assign read_data_int_check_en=  (READ_DATA_INTERLEAVE_EN==0) ? 1:0;
     

     reg  first_beat;
     
     reg [AXI_IDW-1:0] curr_rid; // previous sent ID
     always @ (posedge aclk or negedge aresetn) begin
        if (aresetn == 1'b0) begin
           curr_rid   <= 0;
           first_beat <= 1;
        end
        else  begin
           if (rvalid &&rready)
             first_beat  <=rlast;
           if (rvalid &&rready&&first_beat)
             curr_rid  <= rid;
           
        end
     end
     
     generate
      // Check read data interleaving is not occuring when READ_DATA_INTERLEAVE_EN is unset
      if (READ_DATA_INTERLEAVE_EN==0) begin: Read_data_interleaving_en_0
        property p_no_interleaving;
           @(posedge e_clk) disable iff(!e_rst_n) 
             (rvalid&rready&~first_beat) |-> (curr_rid==rid);
        endproperty 

        // Assertion to check if read data interleaving is not occuring 
        a_no_interleaving : assert property (p_no_interleaving) else 
          $display("-> %0t ERROR: AXI read data interleaving, received RID %0d in the middle of current RID %0d", $realtime,rid,curr_rid );
      end //(READ_DATA_INTERLEAVE_EN==0)
     endgenerate
    
     // Check read data interleaving at interface for ports with READ_DATA_INTERLEAVE_EN set
     generate
      if (READ_DATA_INTERLEAVE_EN==1) begin: Read_data_interleaving_en_1
        // Coverpoint to check if read data interleaving is occuring 
        property p_read_data_interleaving;
           @(posedge e_clk) disable iff(!e_rst_n) 
             (rvalid&rready&~first_beat) |-> (curr_rid!=rid);
        endproperty 

        cp_read_data_interleaving : cover property (p_read_data_interleaving);
      end //(READ_DATA_INTERLEAVE_EN==1)
     endgenerate


`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON    

endmodule // DWC_ddr_umctl2_xpi
