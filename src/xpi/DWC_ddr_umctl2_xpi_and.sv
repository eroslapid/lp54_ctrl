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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_and.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            AND gate 2 to 1 with single bit input
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_and
#(
   parameter WIDTH = 32
)
(
   input [WIDTH-1:0]    in0,
   input                in1,
   output [WIDTH-1:0]   out0
);

   wire [WIDTH-1:0] in1_int;
   // expand in1 input
   assign in1_int = {WIDTH{in1}};
   // AND gate
   assign out0    = in0 & in1_int;

endmodule
