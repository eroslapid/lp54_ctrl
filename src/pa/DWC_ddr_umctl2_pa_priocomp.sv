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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa_priocomp.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               PA priority selection network block (based on aging counter values)
//               Lower the port_priority input, higher is the actual priority.
//               Highest priority ports are set to 1, and the remaining
//               masked by 0.
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa_priocomp
  #(
    parameter NPORTS = 1,
    parameter PRIORITYW = 5
    )
   (
    input [NPORTS*PRIORITYW-1:0] port_priority,
    input [NPORTS-1:0] req,
    output [NPORTS-1:0] port_mask
    );

   wire [PRIORITYW-1:0] in_w [NPORTS-1:0];
   
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation.
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((PRIORITYW * (gv + 1)) - 1)' found in module 'DWC_ddr_umctl2_pa_priocomp'
//SJ: This coding style is acceptable and there is no plan to change it.

   //-------------------------------------------------------
   // Remove ports with no active requests from comparison
   // Set counter value on these ports to max i.e 5'b11111
   //-------------------------------------------------------
   genvar gv;
   generate
      for (gv=0; gv<NPORTS; gv=gv+1)
      begin: GEN_in_w                                 
         assign in_w[gv] = req[gv] ? port_priority[PRIORITYW*(gv+1)-1 -: PRIORITYW] : {PRIORITYW{1'b1}};
      end
   endgenerate
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W528

   
//spyglass disable_block W528
//SMD: A signal or variable is set but never read - sel_in_1_0/sel_in_2_0
//SJ: Used in configs with more than 4/8 ports, but signal required when number of port greater than 2/4


//spyglass enable_block W528
 
//-------------------------------
// Final outout
//-------------------------------

   assign port_mask = 1'b1;

endmodule // DWC_ddr_umctl2_pa_priocomp
