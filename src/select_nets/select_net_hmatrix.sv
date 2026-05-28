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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/select_nets/select_net_hmatrix.sv#1 $
// -------------------------------------------------------------------------
// Description:
// This logic replaces select_net in replace logic when History Matrix is used
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module select_net_hmatrix (
 tags
,vlds
,mask 
,selected_in_oh
,selected
,tag_selected
`ifndef SYNTHESIS
 `ifdef SNPS_ASSERT_ON
,clk
,resetb 
,selected_vld
 `endif
`endif
);

   //----------------------- P A R A M E T E R S ----------------------------------

   parameter TAG_BITS   = 0; // When TAG_BITS is set to 0 tags input is unused. It must be tied to {NUM_INPUTS{1'b0}}. 
   parameter NUM_INPUTS = 8; // Number of vld requests.
   localparam REG_VLDS_EN = 1;     // Register vld inputs.   

   localparam NUM_INPUTS_DIV2  = (NUM_INPUTS/2);
   localparam NUM_INPUTS_DIV4  = (NUM_INPUTS>2) ? (NUM_INPUTS/4):1;
   localparam NUM_INPUTS_DIV8  = (NUM_INPUTS>4) ? (NUM_INPUTS/8):1;
   localparam NUM_INPUTS_DIV16 = (NUM_INPUTS>8) ? (NUM_INPUTS/16):1;
   localparam NUM_INPUTS_DIV32 = (NUM_INPUTS>16)? (NUM_INPUTS/32):1;

   localparam TAG_BITS_L = (TAG_BITS>0) ? TAG_BITS : 1;
   localparam TOTAL_TAG_BITS_L = NUM_INPUTS*TAG_BITS_L;   
   localparam NUM_INPUTS_LOG = `UMCTL_LOG2(NUM_INPUTS);
   

   //------------------------ INPUTS AND OUTPUTS ----------------------------------

   input [TOTAL_TAG_BITS_L-1:0]  tags;           // tag bits to be passed through selection network
   input [NUM_INPUTS-1:0]        vlds;           // whichyyntries are valid for this selection
   output [NUM_INPUTS-1:0]       mask;           // whichyyntries are valid for this selection
   input  [NUM_INPUTS-1:0]       selected_in_oh;
   output [NUM_INPUTS_LOG-1:0]   selected;       // index of the selected node
   output [TAG_BITS_L-1:0]       tag_selected;   // tag of the chosen input
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
   input                         clk;            // clock
   input                         resetb;         // asynchronous falling-edge resetb
   output                        selected_vld;   // indicates the index is valid
   // (ie, there is a valid input)

   reg selected_vld;
  `endif
`endif
   assign mask = vlds;
   assign selected = oh2bin(selected_in_oh);
//   assign tag_selected = tags[selected*TAG_BITS_L+:TAG_BITS_L];

   select_net_oh
    
   #(
     .NUM_INPUTS (NUM_INPUTS),
     .DATAW (TAG_BITS_L)
    )
   select_net_oh
   (
   .din     (tags),
   .sel_oh  (selected_in_oh),
   .dout    (tag_selected)
   );


// One hot to Binaly encoder. 
function automatic [NUM_INPUTS_LOG-1:0] oh2bin (input [NUM_INPUTS-1:0] oh);
integer k,l;
    begin
        oh2bin = 0;
        for (k=0;k<NUM_INPUTS_LOG;k=k+1) begin
            for (l=0;l<NUM_INPUTS;l=l+1) begin
                if (|(l & (1 << k))) begin
                    oh2bin[k] = oh2bin[k] | oh[l];
                    // An example of CAM_ADDR_BITS=4, CAM_ENTRIES=16
                    // oh2bin [0] = oh[ 1]  | oh[ 3] | oh[ 5] | oh[ 7] | oh[ 9] | oh[11] | oh[13] | oh[15]
                    // oh2bin [1] = oh[ 2]  | oh[ 3] | oh[ 6] | oh[ 7] | oh[10] | oh[11] | oh[14] | oh[15]
                    // oh2bin [2] = oh[ 4]  | oh[ 5] | oh[ 6] | oh[ 7] | oh[12] | oh[13] | oh[14] | oh[15]
                    // oh2bin [3] = oh[ 8]  | oh[ 9] | oh[10] | oh[11] | oh[12] | oh[13] | oh[14] | oh[15]
                end
            end 
        end
    end
endfunction


`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON

always @(posedge clk or negedge resetb) begin
    if (~resetb) begin
        selected_vld <= 1'b0;
    end
    else begin
        selected_vld <= |vlds;
    end
end

property p_cam_enh_select_net_hmatrix_tag_check;
  @ (posedge clk) disable iff (~resetb)
  ((tag_selected == tags[selected*TAG_BITS_L+:TAG_BITS_L]) || (~|selected_in_oh));
endproperty

// Check that tag_selected is correct whenever the selected_in_oh is one hot
a_cam_enh_select_net_hmatrix_tag_check : assert property (p_cam_enh_select_net_hmatrix_tag_check)
else $error("%m %t tag_selected is incorrect.", $time);

property p_cam_enh_selected_hmatrix_onehot_check;
  @ (posedge clk) disable iff (~resetb)
  $onehot0(selected_in_oh);
endproperty

// Check that selected_in_oh is one hot or 0
a_cam_enh_selected_hmatrix_onehot_check : assert property (p_cam_enh_selected_hmatrix_onehot_check)
else $error("%m %t selected_in is NOT one hot.", $time);
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule
