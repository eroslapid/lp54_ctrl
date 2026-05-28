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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/select_nets/select_node_lite.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This is the node in the selection network tree.  This chooses between an even
// input and an odd input.  If there are n inputs to the selection network,
// there must be log2(n) levels.
//
// The default is to prefer input 0 over input 1.  The "Wall" indicates
// which is the highest priority in the network. 
`include "DWC_ddrctl_all_defs.svh"
module select_node_lite (clk, resetb, ddrc_cg_en,
         vld0, id0,tag0, vld1, id1,tag1,
         wall_next,
         vld_out, id_out,id_out_msb,tag_out);

   parameter TAG_BITS = 1;   
   parameter ID_IN_BITS = 1;
   parameter CG_EN = 1;

   localparam ID_IN_BITS_L = (ID_IN_BITS>0) ? ID_IN_BITS : 1;
   localparam TAG_BITS_L = (TAG_BITS>0) ? TAG_BITS : 1;   
   
   input                     clk;         // clock
   input                     resetb;      // asynchronous falling-edge reset
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block
   input                     ddrc_cg_en;  // clock gate enable
   input [ID_IN_BITS_L-1:0]  id0;         // ID bits of input selected earlier in network;
   input [TAG_BITS_L-1:0]    tag0;        // Tag bits of input selected earlier in network; 
   input [ID_IN_BITS_L-1:0]  id1;         // ID bits of input selected earlier in network;
   input [TAG_BITS_L-1:0]    tag1;        // Tag bits of input selected earlier in network;
//spyglass enable_block W240
   input                     vld0;        // valid request from input 0
   input                     vld1;        // valid request from input 1
   input                     wall_next;   // wall_next
   output                    vld_out;     // one of the inputs is valid
   output [ID_IN_BITS_L-1:0] id_out;      // ID bits of selected input
   output                    id_out_msb;  // ID bits of selected input   
   output [TAG_BITS_L-1:0]   tag_out;     // ID bits of selected input   
   reg                       wall;        // wall reg
   wire                      choose1;     // choose the ID from input 1, not 0

   generate
   if (CG_EN == 1) begin: cg_en_eq_1
      always @ (posedge clk or negedge resetb) begin
         if (~resetb) begin 
            wall <= 1'b0; 
         end        
         else begin 
            wall <= wall_next; 
         end // else
      end // always
   end //if (CG_EN == 1)
   else begin : cg_en_eq_0
      always @ (posedge clk or negedge resetb) begin
         if (~resetb) begin 
            wall <= 1'b0; 
         end
         else if(ddrc_cg_en) begin 
            wall <= wall_next; 
         end // else
      end // always
   end // else
   endgenerate

   // combinational logic for selection
   assign vld_out    = vld0 | vld1;
   assign choose1               = vld1 &(wall|~vld0);
   assign id_out_msb            = choose1;

   generate 
      if (ID_IN_BITS>0) begin: id_out_l2plus   
   assign id_out[ID_IN_BITS-1:0] = choose1 ? id1 : id0;
      end 
      else begin: id_out_dummy
   assign id_out[0] = 1'b0;
      end
   endgenerate

   generate 
      if (TAG_BITS>0) begin: tag_used   
   assign tag_out[TAG_BITS-1:0] = choose1 ? tag1 : tag0;   
      end 
      else begin: tag_unused
   assign tag_out[0] = 1'b0;
      end
   endgenerate
   
endmodule  // select_block_l2plus
