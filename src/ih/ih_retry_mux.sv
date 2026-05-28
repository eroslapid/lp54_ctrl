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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_retry_mux.sv#1 $
// -------------------------------------------------------------------------
// Description:
//     Mux between RetryCtrl and IH
//     only write interface is MUXed
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ih_retry_mux #(
    //------------------------------ PARAMETERS ------------------------------------
     parameter RMW_TYPE_BITS     = 2                             // 2 bits for RMW type
    ,parameter RETRY_TIMES_WIDTH = 3
    ,parameter CMD_LEN_BITS      = 1
    ,parameter IH_TAG_WIDTH      = 1
    ,parameter RD_LATENCY_BITS   = `UMCTL2_XPI_RQOS_TW 
    ,parameter WR_LATENCY_BITS   = `UMCTL2_XPI_WQOS_TW 
    )
    (
    //-------------------------- INPUTS AND OUTPUTS --------------------------------  
   //data out of pipeline
   output                        ih_te_rd_valid
  ,output                        ih_te_wr_valid
  ,output                        ih_wu_wr_valid
  ,output [RMW_TYPE_BITS-1:0]    ih_te_rmwtype
  ,output                        ih_te_wr_valid_addr_err
  ,output                        ih_te_rd_valid_addr_err
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
  ,output [`MEMC_WRCMD_ENTRY_BITS-1:0] ih_te_wr_entry_rmw        // WR entry number, does not include WRECC entry
  ,output [CMD_LEN_BITS-1:0]     ih_te_rd_length 
  ,output [IH_TAG_WIDTH-1:0]     ih_te_rd_tag 

   //data in from IH
  ,input                         i_ih_te_rd_valid
  ,input                         i_ih_te_wr_valid
  ,input                         i_ih_wu_wr_valid
  ,input [RMW_TYPE_BITS-1:0]     i_ih_te_rmwtype
  ,input                         i_ih_te_wr_valid_addr_err
  ,input                         i_ih_te_rd_valid_addr_err
  ,input [1:0]                   i_ih_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  ,input [1:0]                   i_ih_te_hi_pri_int       
  ,input                         i_ih_te_autopre          // auto precharge enable flag
  ,input  [`MEMC_BG_BITS-1:0]    i_ih_te_bankgroup_num
  ,input  [`MEMC_BG_BANK_BITS -1:0]  i_ih_te_bg_bank_num
  ,input  [`MEMC_BANK_BITS -1:0] i_ih_te_bank_num
  ,input  [`MEMC_PAGE_BITS -1:0] i_ih_te_page_num
  ,input  [`MEMC_BLK_BITS -1:0]  i_ih_te_block_num
  ,input  [`MEMC_WORD_BITS-1:0]  i_ih_te_critical_dword      // for reads only, critical word within a block - not currently supported
  ,input  [`MEMC_WORD_BITS-1:0]  i_ih_wu_critical_dword      // for reads only, critical word within a block - not currently supported
  ,input  [`MEMC_WRCMD_ENTRY_BITS-1:0] i_ih_te_wr_entry        // WR entry number, does not include WRECC entry
  ,input  [CMD_LEN_BITS-1:0]     i_ih_te_rd_length 
  ,input  [IH_TAG_WIDTH-1:0]     i_ih_te_rd_tag 

);

localparam MUX_DATA_BITS = 
  1      //,input                         ih_te_rd_valid
  +1     //,input                         ih_te_wr_valid
  +1     //,input                         ih_wu_wr_valid
  +RMW_TYPE_BITS //,input [RMW_TYPE_BITS-1:0]     ih_te_rmwtype
  +1     //,input                         ih_te_wr_valid_addr_err
  +1     //,input                         ih_te_rd_valid_addr_err
  +2     //,input [1:0]                   ih_te_hi_pri           // priority that is affected by the force_low_pri_n signal
  +2     //,input [1:0]                   ih_te_hi_pri_int
  +1     //,input                         ih_te_autopre          // auto precharge enable flag
  +`MEMC_BG_BITS  //,input  [`MEMC_BG_BITS-1:0]    ih_te_bankgroup_num
  +`MEMC_BG_BANK_BITS   //,input  [`MEMC_BG_BANK_BITS -1:0]  ih_te_bg_bank_num
  +`MEMC_BANK_BITS      //,input  [`MEMC_BANK_BITS -1:0] ih_te_bank_num
  +`MEMC_PAGE_BITS      //,input  [`MEMC_PAGE_BITS -1:0] ih_te_page_num
  +`MEMC_BLK_BITS       //,input  [`MEMC_BLK_BITS -1:0]  ih_te_block_num
  +`MEMC_WORD_BITS      //,input  [`MEMC_WORD_BITS-1:0]  ih_te_critical_dword      // for reads only, critical word within a block - not currently supported
  +`MEMC_WORD_BITS      //,input  [`MEMC_WORD_BITS-1:0]  ih_wu_critical_dword      // for reads only, critical word within a block - not currently supported
  + `MEMC_WRCMD_ENTRY_BITS
  + CMD_LEN_BITS
  + IH_TAG_WIDTH

;
wire [MUX_DATA_BITS-1:0] mux_ih_in;
wire [MUX_DATA_BITS-1:0] mux_out;


assign mux_ih_in = {
   i_ih_te_rd_valid
  ,i_ih_te_wr_valid
  ,i_ih_wu_wr_valid
  ,i_ih_te_rmwtype
  ,i_ih_te_wr_valid_addr_err
  ,i_ih_te_rd_valid_addr_err
  ,i_ih_te_hi_pri           
  ,i_ih_te_hi_pri_int           
  ,i_ih_te_autopre          // auto precharge enable flag
  ,i_ih_te_bankgroup_num
  ,i_ih_te_bg_bank_num
  ,i_ih_te_bank_num
  ,i_ih_te_page_num
  ,i_ih_te_block_num
  ,i_ih_te_critical_dword 
  ,i_ih_wu_critical_dword
  ,i_ih_te_wr_entry
  ,i_ih_te_rd_length
  ,i_ih_te_rd_tag

   };



assign {
   ih_te_rd_valid
  ,ih_te_wr_valid
  ,ih_wu_wr_valid
  ,ih_te_rmwtype
  ,ih_te_wr_valid_addr_err
  ,ih_te_rd_valid_addr_err
  ,ih_te_hi_pri           
  ,ih_te_hi_pri_int           
  ,ih_te_autopre          // auto precharge enable flag
  ,ih_te_bankgroup_num
  ,ih_te_bg_bank_num
  ,ih_te_bank_num
  ,ih_te_page_num
  ,ih_te_block_num
  ,ih_te_critical_dword      
  ,ih_wu_critical_dword      
  ,ih_te_wr_entry_rmw
  ,ih_te_rd_length
  ,ih_te_rd_tag
   } = mux_out;
//============ MUX  =======//

assign mux_out = mux_ih_in;


`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON

`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule
