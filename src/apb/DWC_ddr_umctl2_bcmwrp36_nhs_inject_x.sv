//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddr_umctl2_bcmwrp36_nhs_inject_x.sv#1 $
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

`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
  #(parameter WIDTH       = 1,
    parameter DATA_DELAY  = 0,
    parameter INJECT_X    = 0
    )
   (
  `ifndef SYNTHESIS
    input               clk_d,
    input               rst_d_n,
  `endif
    input   [WIDTH-1:0] data_s,
    output  [WIDTH-1:0] data_d
    );

wire [WIDTH-1:0] data_d_bcm36_nhs;

DWC_ddrctl_bcm36_nhs

  #(.WIDTH      (WIDTH),
    .DATA_DELAY (DATA_DELAY))
U_bcm36_nhs
   (
  `ifndef SYNTHESIS
    .clk_d    (clk_d),
    .rst_d_n  (rst_d_n),
  `endif
    .data_s   (data_s),
    .data_d   (data_d_bcm36_nhs));

`ifdef SYNTHESIS
assign data_d = data_d_bcm36_nhs;
`else
generate if (INJECT_X == 1) begin : GEN_INJECT_X
//spyglass disable_block NoAssignX-ML
//SMD: RHS of the assignment contains 'X'
//SJ: This block injects 'X' on static and quasi-dynamic registers to simulate metastability
assign data_d = (data_s != data_d_bcm36_nhs) ? {WIDTH{1'bx}} : data_s;
//spyglass enable_block NoAssignX-ML
end else begin : GEN_NO_X
assign data_d = data_d_bcm36_nhs;
end endgenerate
`endif // SYNTHESIS

endmodule
