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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa_roundrobincore.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               PA round-robin core arbiter logic.
//               It generates a grant vector based on the pointer
//               and incoming request vector in a round-robin manner.
//               The pointer update is handled outside
//----------------------------------------------------------------------

`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa_roundrobincore
  #(
    parameter NPORTS = 1
    )
   (
    input [NPORTS-1:0]   req,
    input [NPORTS-1:0]   rr_pointer,
    
    output               req_masked_on,
    output [NPORTS-1:0]  grant,
    output [NPORTS-1:0]  mask_higher_pri_reqs,
    output [NPORTS-1:0]  unmask_higher_pri_reqs
    );

   localparam NPORTS_P1 = NPORTS + 1;  // Extended in order to handle single port configuration
   
   wire [NPORTS_P1-1:0] mask_higher_pri_reqs_p1, unmask_higher_pri_reqs_p1, req_masked_p1, grant_masked_p1,
                        req_p1, grant_unmasked_p1;
   wire [NPORTS-1:0] req_masked, grant_masked, grant_unmasked;

   // Simple priority arbitration for masked portion
   assign req_masked = req & rr_pointer;
   assign req_masked_p1 = {1'b0, req_masked}; // Left padded with zero which will have no effect
   
   assign req_masked_on = |req_masked;

   assign mask_higher_pri_reqs_p1[NPORTS_P1-1:1] = mask_higher_pri_reqs[NPORTS_P1-2:0] | req_masked_p1[NPORTS_P1-2:0];
   assign mask_higher_pri_reqs_p1[0] = 1'b0;
   assign grant_masked_p1 = req_masked_p1 & ~mask_higher_pri_reqs_p1;

   // Grant and masks are stripped back to their original lengths
   assign mask_higher_pri_reqs = mask_higher_pri_reqs_p1[NPORTS-1:0];
   assign grant_masked = grant_masked_p1[NPORTS-1:0];
   
   // Simple priority arbitration for unmasked portion
   assign req_p1 = {1'b0, req}; // Left padded with zero which will have no effect
   
   assign unmask_higher_pri_reqs_p1[NPORTS_P1-1:1] = unmask_higher_pri_reqs_p1[NPORTS_P1-2:0] | req_p1[NPORTS_P1-2:0];
   assign unmask_higher_pri_reqs_p1[0] = 1'b0;
   assign grant_unmasked_p1 = req_p1 & ~unmask_higher_pri_reqs_p1;

   // Grant and masks stripped back to their original lengths
   assign unmask_higher_pri_reqs = unmask_higher_pri_reqs_p1[NPORTS-1:0];
   assign grant_unmasked = grant_unmasked_p1[NPORTS-1:0];
   
   // Use grant_masked if any, else use grant_unmasked
   assign grant = (|req_masked) ? grant_masked : grant_unmasked;
   
endmodule // DWC_ddr_umctl2_pa_roundrobincore
