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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddr_umctl2_wr_en_sync.sv#1 $
// -------------------------------------------------------------------------
// Description:
//      Write enable generation
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_wr_en_sync
  #(
    parameter BCM_F_SYNC_TYPE = 2,
    parameter BCM_VERIF_EN = 0
  )
   (input  s_rstn,            // active low input reset pin , async assertion, sync de-assertion
    input  s_clk,             //
    input  d_rstn,
    input  d_clk,
    output wr_en);

   localparam WIDTH           = 1'b1;

   wire    data_s;
   wire    s_wr_en; // write enable in the source clock domain


   assign data_s           = 1'b1;
   
   DWC_ddrctl_bcm21
   
     #(.WIDTH       (WIDTH),
       .F_SYNC_TYPE (BCM_F_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN))
   U_source_wr_en
     (.clk_d    (s_clk),
      .rst_d_n  (s_rstn),
      .data_s   (data_s),
      .data_d   (s_wr_en)
      );

   DWC_ddrctl_bcm21
   
     #(.WIDTH       (WIDTH),
       .F_SYNC_TYPE (BCM_F_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN))
   U_dest_wr_en
     (.clk_d    (d_clk),
      .rst_d_n  (d_rstn),
      .data_s   (s_wr_en),
      .data_d   (wr_en)
      );   

   
endmodule
