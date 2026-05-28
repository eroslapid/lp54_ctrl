//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/async_fifo_checker.sv#1 $
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

//----------------------------------------------------------------------
// Filename    : async_fifo_checker.v
// Description : checker module
//----------------------------------------------------------------------

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

// SVA module
 
  //
  // checker module
  //

`include "DWC_ddrctl_all_defs.svh"
module async_fifo_checker (
  input wire                          wrst_n, // reset
  input wire                          wclk,   // clock
  input wire                          wr,    // FIFO write
  //input wire   [DATA_WIDTH-1:0]     d,     // data input
  input wire                          ff,    // FIFO full flag
  input wire                          rrst_n, // reset
  input wire                          rclk,   // clock
  input wire                          rd,    // FIFO read
  //input wire   [DATA_WIDTH-1:0]     q,     // data output
  input wire                          fe,     // FIFO empty flag
  input wire                          disable_sva_fifo_checker_rd,
  input wire                          disable_sva_fifo_checker_wr
   );

  // NB: "d" and "q" of the fifo were not checked and hence they are not
  //     binded to the checker
  property e_wr_when_fifo_full;
    @(posedge wclk) disable iff (~wrst_n | disable_sva_fifo_checker_wr) (ff) |-> (!wr | rd);
  endproperty  

  property e_rd_when_fifo_empty;
    @(posedge rclk) disable iff (~rrst_n | disable_sva_fifo_checker_rd) (fe) |-> (wr | !rd);
  endproperty 

//    a_wr_when_fifo_full : assert property (e_wr_when_fifo_full)   else ddr_tb.assertion_misc.assertion_err_msg;
//    a_rd_when_fifo_empty: assert property (e_rd_when_fifo_empty)  else ddr_tb.assertion_misc.assertion_err_msg;
    a_wr_when_fifo_full : assert property (e_wr_when_fifo_full)   else $display("-> %0t ERROR: Writing when async fifo full", $realtime);
    a_rd_when_fifo_empty: assert property (e_rd_when_fifo_empty)  else $display("-> %0t ERROR: Reading when async fifo empty", $realtime);
    
endmodule

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

