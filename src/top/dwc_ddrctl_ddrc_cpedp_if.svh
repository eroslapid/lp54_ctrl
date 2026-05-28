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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/top/dwc_ddrctl_ddrc_cpedp_if.svh#1 $
// -------------------------------------------------------------------------
// Description:
//     SV interface between CPE and DP

`ifndef __GUARD__DWC_DDRCTL_DDRC_CPEDP_IF__SVH__
`define __GUARD__DWC_DDRCTL_DDRC_CPEDP_IF__SVH__

`include "DWC_ddrctl_all_defs.svh"

interface dwc_ddrctl_ddrc_cpedp_if #(
   parameter      CMD_LEN_BITS                 = 1,                            // command length bit width

   parameter      WR_CAM_ADDR_WIDTH            = `MEMC_WRCMD_ENTRY_BITS,       // bits to address into write CAM
   parameter      RMW_TYPE_BITS                = 2,                            // 2-bit RMW type
   parameter      CMD_RMW_BITS                 = 1,                            // unused, but '0' breaks things still...

   parameter      CORE_TAG_WIDTH               = `MEMC_TAGBITS,                // width of tag


   parameter     PARTIAL_WR_BITS              = `UMCTL2_PARTIAL_WR_BITS,          
   parameter     PARTIAL_WR_BITS_LOG2         = $clog2(PARTIAL_WR_BITS),
   parameter     PW_NUM_DB                    = PARTIAL_WR_BITS,     
   parameter     PW_FACTOR_HBW                = 2*`MEMC_FREQ_RATIO,               
   parameter     PW_WORD_VALID_WD_HBW         = PW_NUM_DB*PW_FACTOR_HBW,          
   parameter     PW_WORD_VALID_WD_MAX         = PW_WORD_VALID_WD_HBW,             
   parameter     PW_WORD_CNT_WD_MAX           = $clog2(PW_WORD_VALID_WD_MAX),


   parameter      LRANK_BITS                   = `UMCTL2_LRANK_BITS,
   parameter      BG_BITS                      = `MEMC_BG_BITS,
   parameter      BANK_BITS                    = `MEMC_BANK_BITS,
   parameter      RANKBANK_BITS_FULL           = LRANK_BITS + BG_BITS + BANK_BITS,
   parameter      PAGE_BITS                    = `MEMC_PAGE_BITS,
   parameter      BLK_BITS                     = `MEMC_BLK_BITS,               // 2 column bits are critical word
   parameter      WORD_BITS                    = `MEMC_WORD_BITS               // address a word within a burst
   );
   logic [1:0]                                                wu_gs_enable_wr;

   logic                                                      mr_gs_empty;

   logic  [PARTIAL_WR_BITS_LOG2-1:0]                          gs_pi_rdwr_ram_raddr_lsb_first;
   logic  [PW_WORD_CNT_WD_MAX-1:0]                            gs_pi_rdwr_pw_num_beats_m1;

   logic                                                      gs_mr_write;

   logic                                                      pi_ph_dfi_rddata_en;
   logic [`MEMC_FREQ_RATIO-1:0]                               pi_ph_dfi_wrdata_en;

   logic                                                      pi_rt_rd_vld;
   logic [CMD_LEN_BITS-1:0]                                   pi_rt_rd_partial;
   logic [WR_CAM_ADDR_WIDTH-1:0]                              pi_rt_wr_ram_addr;
   logic [RMW_TYPE_BITS-1:0]                                  pi_rt_rmwtype;
   logic [CMD_RMW_BITS-1:0]                                   pi_rt_rmwcmd;         // atomic RMW command instruction;
   logic                                                      pi_rt_rd_mrr_ext;
   logic                                                      pi_rt_rd_mrr;
   logic [CORE_TAG_WIDTH-1:0]                                 pi_rt_rd_tag;
   logic                                                      pi_rt_rd_addr_err;
   logic [RANKBANK_BITS_FULL-1:0]                             pi_rt_rankbank_num;
   logic [PAGE_BITS-1:0]                                      pi_rt_page_num;
   logic [BLK_BITS-1:0]                                       pi_rt_block_num;
   logic [WORD_BITS-1:0]                                      pi_rt_critical_word;


   logic                                                     pi_rt_rd_mrr_snoop;
   logic [3:0]                                               pi_ph_snoop_en;

//interface on dp side;
modport o_wu_mp (
    output                                                    wu_gs_enable_wr
   );
 

 modport o_mr_mp (
    output                                                    mr_gs_empty
   );

modport i_gs_mr_mp (
    input                                                     gs_mr_write
    ,input                                                    gs_pi_rdwr_ram_raddr_lsb_first
    ,input                                                    gs_pi_rdwr_pw_num_beats_m1
   );

//modport o_dfid_mp();

modport i_pi_dfid_mp (
    input                                                     pi_ph_dfi_rddata_en
   ,input                                                     pi_ph_dfi_wrdata_en
   ,input                                                     pi_ph_snoop_en
   );

//modport o_rt_mp();

modport i_pi_rt_mp (
    input                                                     pi_rt_rd_vld
   ,input                                                     pi_rt_rd_partial
   ,input                                                     pi_rt_wr_ram_addr
   ,input                                                     pi_rt_rmwtype
   ,input                                                     pi_rt_rmwcmd          // atomic RMW command instruction
   ,input                                                     pi_rt_rd_mrr_ext
   ,input                                                     pi_rt_rd_mrr
   ,input                                                     pi_rt_rd_tag
   ,input                                                     pi_rt_rd_addr_err
   ,input                                                     pi_rt_rankbank_num
   ,input                                                     pi_rt_page_num
   ,input                                                     pi_rt_block_num
   ,input                                                     pi_rt_critical_word
   ,input                                                     pi_rt_rd_mrr_snoop
   );

//interface on cpe side
modport i_wu_gs_mp (
    input                                                     wu_gs_enable_wr
   );

modport i_mr_gs_mp (
    input                                                     mr_gs_empty
   );

modport o_gs_mp (
    output                                                    gs_mr_write
    ,output                                                   gs_pi_rdwr_ram_raddr_lsb_first
    ,output                                                   gs_pi_rdwr_pw_num_beats_m1
   );

//modport i_dfid_pi_mp();

modport o_pi_mp (
    output                                                    pi_ph_dfi_rddata_en
   ,output                                                    pi_ph_dfi_wrdata_en

   ,output                                                    pi_rt_rd_vld
   ,output                                                    pi_rt_rd_partial
   ,output                                                    pi_rt_wr_ram_addr
   ,output                                                    pi_rt_rmwtype
   ,output                                                    pi_rt_rmwcmd          // atomic RMW command instruction
   ,output                                                    pi_rt_rd_mrr_ext
   ,output                                                    pi_rt_rd_mrr
   ,output                                                    pi_rt_rd_tag
   ,output                                                    pi_rt_rd_addr_err
   ,output                                                    pi_rt_rankbank_num
   ,output                                                    pi_rt_page_num
   ,output                                                    pi_rt_block_num
   ,output                                                    pi_rt_critical_word
   ,output                                                    pi_rt_rd_mrr_snoop
   ,output                                                    pi_ph_snoop_en
   );

//modport i_rt_pi_mp();

endinterface : dwc_ddrctl_ddrc_cpedp_if

`endif // __GUARD__DWC_DDRCTL_DDRC_CPEDP_IF__SVH__
