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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/select_nets/select_net_oh.sv#1 $
// -------------------------------------------------------------------------
// Description:
//           Mux using one hot input
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module select_net_oh 
  #(
    parameter NUM_INPUTS = 1,
    parameter DATAW=8
    )
   (
    input   [DATAW*NUM_INPUTS -1:0]      din,
    input   [NUM_INPUTS-1:0]             sel_oh,
    output  [DATAW-1:0]                  dout
    );
   

  wire [DATAW*NUM_INPUTS -1:0] sel_oh_ext;
  // e.g.) sel_oh = 0010, DATAW=5
  // extended_sel_oh = 00000_00000_11111_00000
  wire [DATAW*NUM_INPUTS -1:0] din_masked;
  // sel_oh_ext & din. unselected din is masked to 0
    
  wire [DATAW*NUM_INPUTS -1:0] din_masked_tr;
  // convert data
  // 01101_00000_00000_00000 -->  0000_1000_1000_0000_1000 

  assign din_masked = din & sel_oh_ext; // Mask unselected bits

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(data_idx * NUM_INPUTS)' found in module 'select_net_oh'
//SJ: This coding style is acceptable and there is no plan to change it.

  generate           
    genvar sel_idx, data_idx;

    for (data_idx=0;data_idx<DATAW;data_idx=data_idx+1) begin : data_idx_loop
      for (sel_idx=0;sel_idx<NUM_INPUTS;sel_idx=sel_idx+1) begin : sel_idx_loop
        assign sel_oh_ext[sel_idx*DATAW+data_idx] = sel_oh[sel_idx];
        // expand sel_oh

        assign din_masked_tr[data_idx*NUM_INPUTS+sel_idx] = din_masked[sel_idx*DATAW+data_idx];
      end 
      assign dout[data_idx] = (|din_masked_tr[data_idx*NUM_INPUTS+:NUM_INPUTS]); 
      // OR'd each bits
    end

  endgenerate
//spyglass enable_block SelfDeterminedExpr-ML

endmodule
