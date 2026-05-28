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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_te_pipeline.sv#1 $
// -------------------------------------------------------------------------
// Description:
//     This is the top level of IH module.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ih_te_pipeline #(
    //------------------------------ PARAMETERS ------------------------------------
     parameter IH_TAG_WIDTH      = `MEMC_TAGBITS                 // width of token/tag field from core
    ,parameter CMD_LEN_BITS      = 1                             // bits for command length, when used
    ,parameter RMW_TYPE_BITS     = 2                             // 2 bits for RMW type
    ,parameter WDATA_PTR_BITS    = `MEMC_WDATA_PTR_BITS 
    )
    (
    //-------------------------- INPUTS AND OUTPUTS --------------------------------  
   input                         te_ih_retry

   //control signal of pipeline
  ,output [WDATA_PTR_BITS-1:0]   rxcmd_wdata_ptr
  ,output                        te_ppl_ih_stall


   //data out of pipeline
  ,output                        ih_te_rd_valid
  ,output                        ih_te_wr_valid
  ,output                        ih_wu_wr_valid
  ,output                        ih_te_rd_valid_addr_err 
  ,output                        ih_te_wr_valid_addr_err
  ,output [CMD_LEN_BITS-1:0]     ih_te_rd_length 
  ,output [IH_TAG_WIDTH-1:0]     ih_te_rd_tag 
  ,output [RMW_TYPE_BITS-1:0]    ih_te_rmwtype 
  ,output [1:0]                  ih_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  ,output [1:0]                  ih_te_hi_pri_int 


  ,output                        ih_te_autopre          // auto precharge enable flag
  ,output [`MEMC_BG_BITS-1:0]    ih_te_bankgroup_num
  ,output [`MEMC_BG_BANK_BITS -1:0]  ih_te_bg_bank_num
  ,output [`MEMC_BANK_BITS -1:0] ih_te_bank_num
  ,output [`MEMC_PAGE_BITS -1:0] ih_te_page_num
  ,output [`MEMC_BLK_BITS -1:0]  ih_te_block_num
  ,output [`MEMC_WORD_BITS-1:0]  ih_te_critical_dword      // for reads only, critical word within a block - not currently supported
  ,output [`MEMC_WORD_BITS-1:0]  ih_wu_critical_dword      // for reads only, critical word within a block - not currently supported

   //data in of pipeline
  ,input  [WDATA_PTR_BITS-1:0]   ppl_rxcmd_wdata_ptr
  ,input                         ih_ppl_te_rd_valid
  ,input                         ih_ppl_te_wr_valid
  ,input                         ih_ppl_wu_wr_valid
  ,input                         ih_ppl_te_rd_valid_addr_err 
  ,input                         ih_ppl_te_wr_valid_addr_err
  ,input  [CMD_LEN_BITS-1:0]     ih_ppl_te_rd_length 
  ,input  [IH_TAG_WIDTH-1:0]     ih_ppl_te_rd_tag 
  ,input  [RMW_TYPE_BITS-1:0]    ih_ppl_te_rmwtype 
  ,input  [1:0]                  ih_ppl_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  ,input  [1:0]                  ih_ppl_te_hi_pri_int 


  ,input                         ih_ppl_te_autopre          // auto precharge enable flag
  ,input  [`MEMC_BG_BITS-1:0]    ih_ppl_te_bankgroup_num
  ,input  [`MEMC_BG_BANK_BITS -1:0]  ih_ppl_te_bg_bank_num
  ,input  [`MEMC_BANK_BITS -1:0] ih_ppl_te_bank_num
  ,input  [`MEMC_PAGE_BITS -1:0] ih_ppl_te_page_num
  ,input  [`MEMC_BLK_BITS -1:0]  ih_ppl_te_block_num
  ,input  [`MEMC_WORD_BITS-1:0]  ih_ppl_te_critical_dword      // for reads only, critical word within a block - not currently supported
  ,input  [`MEMC_WORD_BITS-1:0]  ih_ppl_wu_critical_dword      // for reads only, critical word within a block - not currently supported
);

localparam FIFO_DATA_BITS = 
  WDATA_PTR_BITS  //,input  [WDATA_PTR_BITS-1:0]   ppl_rxcmd_wdata_ptr
  +1      //,input                         ih_ppl_te_rd_valid
  +1     //,input                         ih_ppl_te_wr_valid
  +1     //,input                         ih_ppl_wu_wr_valid
  +1     //,input                         ih_ppl_te_rd_valid_addr_err 
  +1     //,input                         ih_ppl_te_wr_valid_addr_err
  +CMD_LEN_BITS   //,input  [CMD_LEN_BITS-1:0]     ih_ppl_te_rd_length 
  +IH_TAG_WIDTH   //,input  [IH_TAG_WIDTH-1:0]     ih_ppl_te_rd_tag 
  +RMW_TYPE_BITS  //,input  [RMW_TYPE_BITS-1:0]    ih_ppl_te_rmwtype 
  +2              //,input  [1:0]                  ih_ppl_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  +2              //,input  [1:0]                  ih_ppl_te_hi_pri_int 
  +1     //,input                         ih_ppl_te_autopre          // auto precharge enable flag
  +`MEMC_BG_BITS  //,input  [`MEMC_BG_BITS-1:0]    ih_ppl_te_bankgroup_num
  +`MEMC_BG_BANK_BITS   //,input  [`MEMC_BG_BANK_BITS -1:0]  ih_ppl_te_bg_bank_num
  +`MEMC_BANK_BITS      //,input  [`MEMC_BANK_BITS -1:0] ih_ppl_te_bank_num
  +`MEMC_PAGE_BITS      //,input  [`MEMC_PAGE_BITS -1:0] ih_ppl_te_page_num
  +`MEMC_BLK_BITS       //,input  [`MEMC_BLK_BITS -1:0]  ih_ppl_te_block_num
  +`MEMC_WORD_BITS      //,input  [`MEMC_WORD_BITS-1:0]  ih_ppl_te_critical_dword      // for reads only, critical word within a block - not currently supported
  +`MEMC_WORD_BITS      //,input  [`MEMC_WORD_BITS-1:0]  ih_ppl_wu_critical_dword      // for reads only, critical word within a block - not currently supported
;
// 2-bit read priority encoding
localparam CMD_PRI_LPR       = `MEMC_CMD_PRI_LPR;
localparam CMD_PRI_VPR       = `MEMC_CMD_PRI_VPR;
localparam CMD_PRI_HPR       = `MEMC_CMD_PRI_HPR;
localparam CMD_PRI_XVPR      = `MEMC_CMD_PRI_XVPR;

// 2-bit write priority encoding
localparam CMD_PRI_NPW       = `MEMC_CMD_PRI_NPW;
localparam CMD_PRI_VPW       = `MEMC_CMD_PRI_VPW;
localparam CMD_PRI_RSVD      = `MEMC_CMD_PRI_RSVD;
localparam CMD_PRI_XVPW      = `MEMC_CMD_PRI_XVPW;

wire [FIFO_DATA_BITS-1:0] ih_te_fifo_in;
wire [FIFO_DATA_BITS-1:0] ih_te_fifo_out;
wire [FIFO_DATA_BITS-1:0] ih_te_fifo_out_ie;

wire  ih_te_rd_valid_orig;
wire  ih_te_wr_valid_orig;
wire  ih_wu_wr_valid_orig;

wire  ih_te_rd_valid_addr_err_orig;
wire  ih_te_wr_valid_addr_err_orig;

assign ih_te_fifo_in = {
   ppl_rxcmd_wdata_ptr
  ,ih_ppl_te_rd_valid
  ,ih_ppl_te_wr_valid
  ,ih_ppl_wu_wr_valid
  ,ih_ppl_te_rd_valid_addr_err 
  ,ih_ppl_te_wr_valid_addr_err
  ,ih_ppl_te_rd_length 
  ,ih_ppl_te_rd_tag 
  ,ih_ppl_te_rmwtype 
  ,ih_ppl_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  ,ih_ppl_te_hi_pri_int 

  ,ih_ppl_te_autopre          // auto precharge enable flag
  ,ih_ppl_te_bankgroup_num
  ,ih_ppl_te_bg_bank_num
  ,ih_ppl_te_bank_num
  ,ih_ppl_te_page_num
  ,ih_ppl_te_block_num
  ,ih_ppl_te_critical_dword      // for reads only, critical word within a block - not currently supported
  ,ih_ppl_wu_critical_dword      // for reads only, critical word within a block - not currently supported
   };

assign {
   rxcmd_wdata_ptr
  ,ih_te_rd_valid_orig
  ,ih_te_wr_valid_orig
  ,ih_wu_wr_valid_orig
  ,ih_te_rd_valid_addr_err_orig 
  ,ih_te_wr_valid_addr_err_orig
  ,ih_te_rd_length 
  ,ih_te_rd_tag 
  ,ih_te_rmwtype 
  ,ih_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  ,ih_te_hi_pri_int 

  ,ih_te_autopre          // auto precharge enable flag
  ,ih_te_bankgroup_num
  ,ih_te_bg_bank_num
  ,ih_te_bank_num
  ,ih_te_page_num
  ,ih_te_block_num
  ,ih_te_critical_dword      // for reads only, critical word within a block - not currently supported
  ,ih_wu_critical_dword      // for reads only, critical word within a block - not currently supported
   } = ih_te_fifo_out;

  assign ih_te_fifo_out = ih_te_fifo_in;
  assign te_ppl_ih_stall = te_ih_retry;

  //output valid is same as input.
  assign ih_te_rd_valid = ih_te_rd_valid_orig;
  assign ih_te_wr_valid = ih_te_wr_valid_orig;
  assign ih_wu_wr_valid = ih_wu_wr_valid_orig;
  assign ih_te_rd_valid_addr_err = ih_te_rd_valid_addr_err_orig;
  assign ih_te_wr_valid_addr_err = ih_te_wr_valid_addr_err_orig;

  //output latency is same as input.


`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON



`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule
