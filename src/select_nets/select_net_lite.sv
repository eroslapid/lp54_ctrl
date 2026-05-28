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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/select_nets/select_net_lite.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This implements a lite selection network.
// In this selection network, the wall input is the highest priorit.y
// By moving the wall, it is possible to implement round-robin selection.
// (wall_direction_next is the input that dictates the location of this wall in
//  the selection network. This should be set one clock in advance of the
//  cycle in which it will be used.)
//
// Date:   Mars 1, 2014 
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module select_net_lite (clk, resetb, tags, vlds, wall_next,
                        selected, tag_selected, selected_vld);

   //----------------------- P A R A M E T E R S ----------------------------------

   parameter TAG_BITS   = 0; // When TAG_BITS is set to 0 tags input is unused. It must be tied to {NUM_INPUTS{1'b0}}. 
   parameter NUM_INPUTS = 8; // Number of vld requests.

   localparam NUM_INPUTS_DIV2  = (NUM_INPUTS/2);
   localparam NUM_INPUTS_DIV4  = (NUM_INPUTS>2) ? (NUM_INPUTS/4):1;
   localparam NUM_INPUTS_DIV8  = (NUM_INPUTS>4) ? (NUM_INPUTS/8):1;
   localparam NUM_INPUTS_DIV16 = (NUM_INPUTS>8) ? (NUM_INPUTS/16):1;
   localparam NUM_INPUTS_DIV32 = (NUM_INPUTS>16)? (NUM_INPUTS/32):1;
   localparam NUM_INPUTS_DIV64 = (NUM_INPUTS>32)? (NUM_INPUTS/64):1;
   localparam NUM_INPUTS_DIV128 = (NUM_INPUTS>64)? (NUM_INPUTS/128):1;

   localparam TAG_BITS_L       = (TAG_BITS>0) ? TAG_BITS : 1;
   localparam TOTAL_TAG_BITS_L = NUM_INPUTS*TAG_BITS_L;   
   

   //------------------------ INPUTS AND OUTPUTS ----------------------------------

   input                                clk;            // clock
   input                                resetb;         // asynchronous falling-edge resetb
   input [TOTAL_TAG_BITS_L-1:0]         tags;           // tag bits to be passed through selection network
   input [NUM_INPUTS-1:0]               vlds;           // which entries are valid for this selection
   input [`UMCTL_LOG2(NUM_INPUTS)-1:0]  wall_next;      // index of the lowest-priority input

   output [`UMCTL_LOG2(NUM_INPUTS)-1:0] selected;       // index of the selected node
   output [TAG_BITS_L-1:0]              tag_selected;   // tag of the chosen input
   output                               selected_vld;   // indicates the index is valid
   // (ie, there is a valid input)

   //------------------------- WIRES AND REGS -------------------------------------

   wire              dummy_input;
   
   wire [NUM_INPUTS_DIV2-1:0]                l1_vlds;  // valid bits from the 1st level of selection
   wire [NUM_INPUTS_DIV2-1:0]                l1_ids_b0;
   wire [NUM_INPUTS_DIV2-1:0]                l1_ids_b0_unused; // unused signal
   wire [NUM_INPUTS_DIV2*TAG_BITS_L-1:0]     l1_tags;  // tags after 1 level of selection

   wire [NUM_INPUTS_DIV4-1:0]                l2_vlds;  // valid bits from the 2nd level of selection
   wire [NUM_INPUTS_DIV4-1:0]                l2_ids_b0;// IDs from the first level of selection
   wire [NUM_INPUTS_DIV4-1:0]                l2_ids_b1;// IDs from the first level of selection
   wire [NUM_INPUTS_DIV4*TAG_BITS_L-1:0]     l2_tags;  // tags after 2 levels of selection

   wire [NUM_INPUTS_DIV8-1:0]                l3_vlds;   // valid bits from the first level of selection
   wire [NUM_INPUTS_DIV8-1:0]                l3_ids_b0; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV8-1:0]                l3_ids_b1; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV8-1:0]                l3_ids_b2; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV8*TAG_BITS_L-1:0]     l3_tags;   // tags after 3 levels of selection

   wire [NUM_INPUTS_DIV16-1:0]               l4_vlds;   // valid bits from the first level of selection
   wire [NUM_INPUTS_DIV16-1:0]               l4_ids_b0; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV16-1:0]               l4_ids_b1; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV16-1:0]               l4_ids_b2; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV16-1:0]               l4_ids_b3; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV16*TAG_BITS_L-1:0]    l4_tags;   // tags after 4 levels of selection

   wire [NUM_INPUTS_DIV32-1:0]               l5_vlds;   // valid bits from the first level of selection
   wire [NUM_INPUTS_DIV32-1:0]               l5_ids_b0; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV32-1:0]               l5_ids_b1; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV32-1:0]               l5_ids_b2; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV32-1:0]               l5_ids_b3; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV32-1:0]               l5_ids_b4; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV32*TAG_BITS_L-1:0]    l5_tags;   // tags after 5 levels of selection

   wire [NUM_INPUTS_DIV64-1:0]               l6_vlds;   // valid bits from the first level of selection
   wire [NUM_INPUTS_DIV64-1:0]               l6_ids_b0; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV64-1:0]               l6_ids_b1; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV64-1:0]               l6_ids_b2; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV64-1:0]               l6_ids_b3; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV64-1:0]               l6_ids_b4; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV64-1:0]               l6_ids_b5; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV64*TAG_BITS_L-1:0]    l6_tags;   // tags after 5 levels of selection
   
   wire [NUM_INPUTS_DIV128-1:0]              l7_vlds;   // valid bits from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b0; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b1; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b2; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b3; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b4; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b5; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128-1:0]              l7_ids_b6; // IDs from the first level of selection
   wire [NUM_INPUTS_DIV128*TAG_BITS_L-1:0]   l7_tags;   // tags after 5 levels of selection

   // Dummy input is tied to constant 0 
   assign      dummy_input = 1'b0;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(j1 * 2)' found in module 'select_net_lite'
//SJ: This coding style is acceptable and there is no plan to change it.



   // level 1
   genvar j1;
   generate
      for (j1=0; j1<NUM_INPUTS_DIV2; j1=j1+1)
  begin : u0

     select_node_lite
      
      #(.TAG_BITS(TAG_BITS),.ID_IN_BITS(0),.CG_EN(1))
     select_node_l1
       (
        .clk            (clk),
        .resetb         (resetb),
        .ddrc_cg_en     (1'b1),
        .vld0           (vlds[j1*2]),
        .id0            (dummy_input), // no ID input for first level
        .tag0           (tags[j1*2*TAG_BITS_L+:TAG_BITS_L]),
        .vld1           (vlds[j1*2+1]),
        .id1            (dummy_input), // no ID input for first level
        .tag1           (tags[(j1*2+1)*TAG_BITS_L+:TAG_BITS_L]),
        .wall_next      (wall_next[0]),
        .vld_out        (l1_vlds[j1]),
        .id_out         (l1_ids_b0_unused[j1]), // not used; single bit ID output for first level
        .id_out_msb     (l1_ids_b0[j1]),
        .tag_out        (l1_tags[j1*TAG_BITS_L+:TAG_BITS_L]) );   
  end
   endgenerate

   // level 2
   genvar j2;
   
   generate
      if (NUM_INPUTS==2) begin :TOTAL_BANKS_EQ_2
   assign selected  = {l1_ids_b0[0]};
   assign tag_selected    = l1_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l1_vlds[0];
      end
      else begin :TOTAL_BANKS_GT_2// > 2 total banks
      for (j2=0; j2<NUM_INPUTS_DIV4; j2=j2+1)
  begin : u1
     select_node_lite
      #(TAG_BITS,1) 
     select_node_l2
             (
        .clk            (clk),
        .resetb         (resetb),
        .ddrc_cg_en     (1'b1),
        .vld0           (l1_vlds[j2*2]),
        .id0            (l1_ids_b0[j2*2]),
        .tag0           (l1_tags[j2*2*TAG_BITS_L+:TAG_BITS_L]),
        .vld1           (l1_vlds[j2*2+1]),
        .id1            (l1_ids_b0[j2*2+1]),
        .tag1           (l1_tags[(j2*2+1)*TAG_BITS_L+:TAG_BITS_L]),
        .wall_next      (wall_next[1]),
        .vld_out        (l2_vlds[j2]),
        .id_out         (l2_ids_b0[j2]),
        .id_out_msb     (l2_ids_b1[j2]),
        .tag_out        (l2_tags[j2*TAG_BITS_L+:TAG_BITS_L]));
  end // block: u1
      end // block: TOTAL_BANKS_GT_2...
   endgenerate

   // level 3
   genvar j3;   
   generate
      if (NUM_INPUTS==4) begin :TOTAL_BANKS_EQ_4
   assign selected  = {l2_ids_b1[0], l2_ids_b0[0]};
   assign tag_selected    = l2_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l2_vlds[0];
      end
      if (NUM_INPUTS>4) begin : TOTAL_BANKS_GT_4// > 4 total banks
   for (j3=0; j3<NUM_INPUTS_DIV8; j3=j3+1)
     begin : u2
        select_node_lite
         #(TAG_BITS,2) 
        select_node_l3 
    (
     .clk            (clk),
     .resetb         (resetb),
     .ddrc_cg_en     (1'b1),
     .vld0           (l2_vlds[j3*2]),
     .id0            ({l2_ids_b1[j3*2],
                       l2_ids_b0[j3*2]}),
     .tag0           (l2_tags[j3*2*TAG_BITS_L+:TAG_BITS_L]),
     .vld1           (l2_vlds[j3*2+1]),
     .id1            ({l2_ids_b1[j3*2+1],
                       l2_ids_b0[j3*2+1]}),
     .tag1           (l2_tags[(j3*2+1)*TAG_BITS_L+:TAG_BITS_L]),
     .wall_next      (wall_next[2]),
     .vld_out        (l3_vlds[j3]),
     .id_out         ({l3_ids_b1[j3],
                      l3_ids_b0[j3]}),
     .id_out_msb     (l3_ids_b2[j3]),
     .tag_out        (l3_tags[j3*TAG_BITS_L+:TAG_BITS_L]) 
     );
     end // block: u2
      end // block: TOTAL_BANKS_GT_4...
   endgenerate

   // level 4
   genvar j4;
   generate
      if (NUM_INPUTS==8) begin :TOTAL_BANKS_EQ_8
   assign selected      = {l3_ids_b2[0], l3_ids_b1[0], l3_ids_b0[0]};
   assign tag_selected  = l3_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l3_vlds[0];
      end
      if (NUM_INPUTS>8) begin :TOTAL_BANKS_GT_8// > 8 total banks
   for (j4=0; j4<(NUM_INPUTS_DIV16); j4=j4+1)
     begin : u3
        select_node_lite
         #(TAG_BITS,3) 
        select_node_l4
    (
     .clk            (clk),
     .resetb         (resetb),
     .ddrc_cg_en     (1'b1),
     .vld0           (l3_vlds[j4*2]),
     .id0            ({l3_ids_b2[j4*2],
                       l3_ids_b1[j4*2],
                       l3_ids_b0[j4*2]}),
     .tag0           (l3_tags[j4*2*TAG_BITS_L+:TAG_BITS_L]),
     .vld1           (l3_vlds[j4*2+1]),
     .id1            ({l3_ids_b2[j4*2+1],
                       l3_ids_b1[j4*2+1],
                       l3_ids_b0[j4*2+1]}),
     .tag1           (l3_tags[(j4*2+1)*TAG_BITS_L+:TAG_BITS_L]),
     .wall_next      (wall_next[3]),
     .vld_out        (l4_vlds[j4]),
     .id_out         ({l4_ids_b2[j4],
                       l4_ids_b1[j4],
                       l4_ids_b0[j4]}),
     .id_out_msb     (l4_ids_b3[j4]),
     .tag_out        (l4_tags[j4*TAG_BITS_L+:TAG_BITS_L]));
        
     end // block: u3
      end // block: TOTAL_BANKS_GT_8...
      
   endgenerate

   // level 5
   genvar j5;
   generate
      if (NUM_INPUTS==16) begin :TOTAL_BANKS_EQ_16
   assign selected  = {l4_ids_b3[0], l4_ids_b2[0], l4_ids_b1[0], l4_ids_b0[0]};
   assign tag_selected    = l4_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l4_vlds[0];
      end
      if (NUM_INPUTS>16) begin :TOTAL_BANKS_GT_16// > 16 total banks
   for (j5=0; j5<(NUM_INPUTS_DIV32); j5=j5+1)
     begin : u4
        select_node_lite
         #(TAG_BITS,4) 
        select_node_l5
    (
     .clk            (clk),
     .resetb         (resetb),
     .ddrc_cg_en     (1'b1),
     .vld0           (l4_vlds[j5*2]),
     .id0            ({l4_ids_b3[j5*2],
                       l4_ids_b2[j5*2],
                       l4_ids_b1[j5*2],
                       l4_ids_b0[j5*2]}),
     .tag0           (l4_tags[j5*2*TAG_BITS_L+:TAG_BITS_L]),
     .vld1           (l4_vlds[j5*2+1]),
     .id1            ({l4_ids_b3[j5*2+1],
                       l4_ids_b2[j5*2+1],
                       l4_ids_b1[j5*2+1],
                       l4_ids_b0[j5*2+1]}),
     .tag1           (l4_tags[(j5*2+1)*TAG_BITS_L+:TAG_BITS_L]),
     .wall_next      (wall_next[4]),
     .vld_out        (l5_vlds[j5]),
     .id_out         ({l5_ids_b3[j5],
                       l5_ids_b2[j5],
                       l5_ids_b1[j5],
                       l5_ids_b0[j5]}),
     .id_out_msb     (l5_ids_b4[j5]),               
     .tag_out        (l5_tags[j5*TAG_BITS_L+:TAG_BITS_L])); 
     end // block: u4
      end // block: TOTAL_BANKS_GT_16...
   endgenerate


   // level 6
   genvar j6;
   generate
      if (NUM_INPUTS==32) begin :TOTAL_BANKS_EQ_32
   assign selected  = {l5_ids_b4[0], l5_ids_b3[0], l5_ids_b2[0], l5_ids_b1[0], l5_ids_b0[0]};
   assign tag_selected    = l5_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l5_vlds[0];
      end
      if (NUM_INPUTS>32) begin :TOTAL_BANKS_GT_32// > 32 total banks
   for (j6=0; j6<(NUM_INPUTS_DIV64); j6=j6+1)
     begin : u5
        select_node_lite
         #(TAG_BITS,5) 
        select_node_l6
    (
     .clk            (clk),
     .resetb         (resetb),
     .ddrc_cg_en     (1'b1),
     .vld0           (l5_vlds[j6*2]),
     .id0            ({l5_ids_b4[j6*2],
                       l5_ids_b3[j6*2],
                       l5_ids_b2[j6*2],
                       l5_ids_b1[j6*2],
                       l5_ids_b0[j6*2]}),
     .tag0           (l5_tags[j6*2*TAG_BITS_L+:TAG_BITS_L]),
     .vld1           (l5_vlds[j6*2+1]),
     .id1            ({l5_ids_b4[j6*2+1],
                       l5_ids_b3[j6*2+1],
                       l5_ids_b2[j6*2+1],
                       l5_ids_b1[j6*2+1],
                       l5_ids_b0[j6*2+1]}),
     .tag1           (l5_tags[(j6*2+1)*TAG_BITS_L+:TAG_BITS_L]),
     .wall_next      (wall_next[5]),
     .vld_out        (l6_vlds[j6]),
     .id_out         ({l6_ids_b4[j6],
                       l6_ids_b3[j6],
                       l6_ids_b2[j6],
                       l6_ids_b1[j6],
                       l6_ids_b0[j6]}),
     .id_out_msb     (l6_ids_b5[j6]),               
     .tag_out        (l6_tags[j6*TAG_BITS_L+:TAG_BITS_L])); 
     end // block: u5
      end // block: TOTAL_BANKS_GT_32...
   endgenerate

      // level 7
   genvar j7;
   generate
      if (NUM_INPUTS==64) begin :TOTAL_BANKS_EQ_64
   assign selected  = {l6_ids_b5[0], l6_ids_b4[0], l6_ids_b3[0], l6_ids_b2[0], l6_ids_b1[0], l6_ids_b0[0]};
   assign tag_selected  = l6_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l6_vlds[0];
      end
      if (NUM_INPUTS>64) begin :TOTAL_BANKS_GT_64// > 64 total banks
   for (j7=0; j7<(NUM_INPUTS_DIV128); j7=j7+1)
     begin : u6
        select_node_lite
         #(TAG_BITS,6) 
        select_node_l7
    (
     .clk            (clk),
     .resetb         (resetb),
     .ddrc_cg_en     (1'b1),
     .vld0           (l6_vlds[j7*2]),
     .id0            ({l6_ids_b5[j7*2],
                       l6_ids_b4[j7*2],
                       l6_ids_b3[j7*2],
                       l6_ids_b2[j7*2],
                       l6_ids_b1[j7*2],
                       l6_ids_b0[j7*2]}),
     .tag0           (l6_tags[j7*2*TAG_BITS_L+:TAG_BITS_L]),
     .vld1           (l6_vlds[j7*2+1]),
     .id1            ({l6_ids_b5[j7*2+1],
                       l6_ids_b4[j7*2+1],
                       l6_ids_b3[j7*2+1],
                       l6_ids_b2[j7*2+1],
                       l6_ids_b1[j7*2+1],
                       l6_ids_b0[j7*2+1]}),
     .tag1           (l6_tags[(j7*2+1)*TAG_BITS_L+:TAG_BITS_L]),
     .wall_next      (wall_next[6]),
     .vld_out        (l7_vlds[j7]),
     .id_out         ({l7_ids_b5[j7],
                       l7_ids_b4[j7],
                       l7_ids_b3[j7],
                       l7_ids_b2[j7],
                       l7_ids_b1[j7],
                       l7_ids_b0[j7]}),
     .id_out_msb     (l7_ids_b6[j7]),               
     .tag_out        (l7_tags[j7*TAG_BITS_L+:TAG_BITS_L])); 
     end // block: u6
      end // block: TOTAL_BANKS_GT_64...
   endgenerate

//spyglass enable_block SelfDeterminedExpr-ML


   generate
      if (NUM_INPUTS==128) begin :TOTAL_BANKS_EQ_128
   assign selected  = {l7_ids_b6[0], l7_ids_b5[0], l7_ids_b4[0], l7_ids_b3[0], l7_ids_b2[0], l7_ids_b1[0], l7_ids_b0[0]};
   assign tag_selected  = l7_tags[TAG_BITS_L-1:0];
   assign selected_vld  = l7_vlds[0];

      end
      if (NUM_INPUTS>128) begin :TOTAL_BANKS_GT_128// > 128 total banks
   // level 6 (Top)
   select_node_lite
    #(TAG_BITS,7) 
   select_node_l8
     (
      .clk            (clk),
      .resetb         (resetb),
      .ddrc_cg_en     (1'b1),
      .vld0           (l7_vlds[0]),
      .id0            ({l7_ids_b6[0],
                        l7_ids_b5[0],
                        l7_ids_b4[0],
                        l7_ids_b3[0],
                        l7_ids_b2[0],
                        l7_ids_b1[0],
                        l7_ids_b0[0]}),
      .tag0           (l7_tags[TAG_BITS_L-1:0]),             
      .vld1           (l7_vlds[1]),
      .id1            ({l7_ids_b6[1],
                        l7_ids_b5[1],
                        l7_ids_b4[1],
                        l7_ids_b3[1],
                        l7_ids_b2[1],
                        l7_ids_b1[1],
                        l7_ids_b0[1]}),
      .tag1           (l7_tags[TAG_BITS_L+:TAG_BITS_L]),             
      .wall_next      (wall_next[7]),
      .vld_out        (selected_vld),
      .id_out         (selected[6:0]),
      .id_out_msb     (selected[7]),                              
      .tag_out        (tag_selected[TAG_BITS_L-1:0]) );
      end // block: TOTAL_BANKS_GT_32...
   endgenerate
endmodule  //os_select_net_tags
