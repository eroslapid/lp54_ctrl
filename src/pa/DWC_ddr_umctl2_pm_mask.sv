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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pm_mask.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            Generates page match mask from the address map registers
//               
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pm_mask
  #(
    parameter SBR_EN          = 0,
    parameter LPDDR3_EN       = 0,
    parameter LPDDR4_EN       = 0,
    parameter INLINE_ECC      = 0,
    parameter OCCAP_EN        = 0,
    parameter OCCAP_PIPELINE_EN = 0,
    parameter DDRCTL_HET_INTERLEAVE = 0,
    parameter MBL             = 8,
    parameter ECC_H3_WIDTH    = 6,
    parameter AMCOLW_L        = 4,
    parameter AMCOLW_H        = 4,
    parameter AMCOLW_C3       = 5,
    parameter AMDCHW          = 6,
    parameter AMCSW           = 6,
    parameter AMCIDW          = 6,
    parameter AMBANKW         = 6,
    parameter AMBGW           = 6,
    parameter AMROWW          = 5,
    parameter HIF_ADDR_WIDTH  = 35
    )
   (
    input clk,
    input rst_n,

    // Register Interface
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
    input [2:0] reg_ddrc_nonbinary_device_density,
    input       reg_ddrc_lpddr3_6gb_12gb,
    input [1:0] reg_ddrc_lpddr45_6gb_12gb_24gb,
//spyglass enable_block W240
    input       reg_ddrc_occap_en,
    input [AMBANKW-1:0] reg_ddrc_addrmap_bank_b0,
    input [AMBANKW-1:0] reg_ddrc_addrmap_bank_b1,
    input [AMBANKW-1:0] reg_ddrc_addrmap_bank_b2,
    input [AMCOLW_L-1:0] reg_ddrc_addrmap_col_b2,
    input [AMCOLW_C3-1:0] reg_ddrc_addrmap_col_b3,
    input [AMCOLW_L-1:0] reg_ddrc_addrmap_col_b4,
    input [AMCOLW_L-1:0] reg_ddrc_addrmap_col_b5,
    input [AMCOLW_L-1:0] reg_ddrc_addrmap_col_b6,
    input [AMCOLW_H-1:0] reg_ddrc_addrmap_col_b7,
    input [AMCOLW_H-1:0] reg_ddrc_addrmap_col_b8,
    input [AMCOLW_H-1:0] reg_ddrc_addrmap_col_b9,
    input [AMCOLW_H-1:0] reg_ddrc_addrmap_col_b10,
    input [AMCOLW_H-1:0] reg_ddrc_addrmap_col_b11,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b0,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b1,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b2,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b3,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b4,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b5,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b6,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b7,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b8,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b9,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b10,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b2_10,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b11,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b12,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b13,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b14,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b15,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b16,
    input [AMROWW-1:0] reg_ddrc_addrmap_row_b17,
    
    output                      pm_mask_parity_err,
    output [HIF_ADDR_WIDTH-1:0] pagematch_addrmap_mask,
    output [HIF_ADDR_WIDTH-1:0] bg_or_bank_addrmap_mask,
    output [HIF_ADDR_WIDTH-1:0] data_channel_addrmap_mask,
    output [HIF_ADDR_WIDTH-1:0] lpddr34_6gb_12gb_mask,
    output [HIF_ADDR_WIDTH-1:0] sbr_address_range,
    output [HIF_ADDR_WIDTH-1:0] l3_iecc_col_mask,
    output [ECC_H3_WIDTH-1:0]   h3_iecc_col_mask
    );
   
   localparam COL_BIT_DIS = {AMCOLW_H{1'b1}};
   localparam OUT_REG_WIDTH = HIF_ADDR_WIDTH*6+ECC_H3_WIDTH;
   wire [HIF_ADDR_WIDTH-1:0] mask_row_bank;
   wire [HIF_ADDR_WIDTH-1:0] mask_data_channel;
   wire [HIF_ADDR_WIDTH-1:0] address_range_all, row_invalid_mask;
   wire [ECC_H3_WIDTH-1:0]   highest_column_mask;
   wire [HIF_ADDR_WIDTH-1:0] lowest_column_mask;


   wire [HIF_ADDR_WIDTH-1:0] mask_dch;
   wire [HIF_ADDR_WIDTH-1:0] mask_cs;   

   wire [HIF_ADDR_WIDTH-1:0] mask_bg;
   wire [HIF_ADDR_WIDTH-1:0] mask_bg_or_bank;

   wire [HIF_ADDR_WIDTH-1:0] mask_bank;
   reg [HIF_ADDR_WIDTH-1:0]  mask_bank_b0, mask_bank_b1, mask_bank_b2;
   wire [HIF_ADDR_WIDTH-1:0] mask_row;
   reg [HIF_ADDR_WIDTH-1:0]  mask_row_b0, mask_row_b1, mask_row_b2, mask_row_b3,
                             mask_row_b4, mask_row_b5, mask_row_b6, mask_row_b7,
                             mask_row_b8, mask_row_b9, mask_row_b10, mask_row_b2_10, 
                             mask_row_b11, mask_row_b12, mask_row_b13, mask_row_b14,
                             mask_row_b15, mask_row_b16, mask_row_b17;

   wire [HIF_ADDR_WIDTH-1:0] mask_col;
   reg [HIF_ADDR_WIDTH-1:0]  mask_col_b2, mask_col_b3,
                                  mask_col_b4, mask_col_b5, mask_col_b6, mask_col_b7,
                                  mask_col_b8, mask_col_b9, mask_col_b10, mask_col_b11;



   wire [1:0] am_column_base_shift;
   assign am_column_base_shift = 2'd0;

 
   assign mask_dch   = {HIF_ADDR_WIDTH{1'b0}};

   
   assign mask_cs = {HIF_ADDR_WIDTH{1'b0}};





  
         assign mask_bg = {HIF_ADDR_WIDTH{1'b0}};
   
   // Bank mask
   always @(*)
   begin: mask_bank_COMB_PROC
      mask_bank_b0 = {HIF_ADDR_WIDTH{1'b0}};
      mask_bank_b1 = {HIF_ADDR_WIDTH{1'b0}};
      mask_bank_b2 = {HIF_ADDR_WIDTH{1'b0}};

      case(reg_ddrc_addrmap_bank_b0)
        // ccx_line_begin: ; It is not possible to exercise all combinations of address map register values
        {$bits(reg_ddrc_addrmap_bank_b0){1'b0}}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-1){1'b0}},1'b1}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-2){1'b0}},2'b10}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-2){1'b0}},2'b11}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-3){1'b0}},3'b100}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+4]  = 1'b1; 
        {{($bits(reg_ddrc_addrmap_bank_b0)-3){1'b0}},3'b101}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-3){1'b0}},3'b110}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-3){1'b0}},3'b111}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1000}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1001}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1010}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1011}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1100}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1101}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1110}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-4){1'b0}},4'b1111}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+15] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10000}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+16] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10001}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+17] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10010}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+18] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10011}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+19] = 1'b1; 
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10100}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+20] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10101}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+21] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10110}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+22] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b10111}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+23] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b11000}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+24] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b11001}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+25] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b11010}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+26] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b11011}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+27] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b0)-5){1'b0}},5'b11100}   : mask_bank_b0[`UMCTL2_AM_BANK_BASE +0+28] = 1'b1;
       default : mask_bank_b0[`MEMC_HIF_ADDR_WIDTH-1] = 1'b1;
       // ccx_line_end
      endcase

      case(reg_ddrc_addrmap_bank_b1)
        // ccx_line_begin: ; It is not possible to exercise all combinations of address map register values
        {$bits(reg_ddrc_addrmap_bank_b1){1'b0}}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-1){1'b0}},1'b1}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-2){1'b0}},2'b10}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-2){1'b0}},2'b11}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-3){1'b0}},3'b100}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+4]  = 1'b1; 
        {{($bits(reg_ddrc_addrmap_bank_b1)-3){1'b0}},3'b101}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-3){1'b0}},3'b110}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-3){1'b0}},3'b111}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1000}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1001}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1010}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1011}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1100}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1101}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1110}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-4){1'b0}},4'b1111}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+15] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10000}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+16] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10001}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+17] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10010}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+18] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10011}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+19] = 1'b1; 
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10100}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+20] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10101}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+21] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10110}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+22] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b10111}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+23] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b11000}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+24] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b11001}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+25] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b11010}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+26] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b1)-5){1'b0}},5'b11011}   : mask_bank_b1[`UMCTL2_AM_BANK_BASE +1+27] = 1'b1;
        default : mask_bank_b1[`MEMC_HIF_ADDR_WIDTH-1] = 1'b1; // higher values illegal
        // ccx_line_end
      endcase
      
      case(reg_ddrc_addrmap_bank_b2)
        // ccx_line_begin: ; It is not possible to exercise all combinations of address map register values
        {$bits(reg_ddrc_addrmap_bank_b2){1'b0}}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-1){1'b0}},1'b1}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-2){1'b0}},2'b10}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-2){1'b0}},2'b11}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-3){1'b0}},3'b100}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+4]  = 1'b1; 
        {{($bits(reg_ddrc_addrmap_bank_b2)-3){1'b0}},3'b101}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-3){1'b0}},3'b110}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-3){1'b0}},3'b111}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1000}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1001}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1010}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1011}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1100}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1101}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1110}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-4){1'b0}},4'b1111}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+15] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10000}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+16] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10001}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+17] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10010}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+18] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10011}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+19] = 1'b1; 
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10100}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+20] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10101}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+21] = 1'b1;
        {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10110}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+22] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b10111}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+23] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b11000}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+24] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b11001}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+25] = 1'b1;
          {{($bits(reg_ddrc_addrmap_bank_b2)-5){1'b0}},5'b11010}   : mask_bank_b2[`UMCTL2_AM_BANK_BASE +2+26] = 1'b1;
        default : mask_bank_b2 = {HIF_ADDR_WIDTH{1'b0}};
        // ccx_line_end
      endcase
   end // block: mask_bank_COMB_PROC
   assign mask_bank = mask_bank_b0 | mask_bank_b1 | mask_bank_b2;

//spyglass disable_block W415a
//SMD: Signal is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches

   // Row mask
   always @(*)
   begin: mask_row_COMB_PROC
      integer i;
      mask_row_b0 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b1 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b2 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b3 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b4 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b5 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b6 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b7 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b8 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b9 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b10 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b2_10 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b11 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b12 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b13 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b14 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b15 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b16 = {HIF_ADDR_WIDTH{1'b0}};
      mask_row_b17 = {HIF_ADDR_WIDTH{1'b0}};
      case(reg_ddrc_addrmap_row_b0)
        {$bits(reg_ddrc_addrmap_row_b0){1'b0}}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-1){1'b0}},1'b1}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-2){1'b0}},2'b10}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-2){1'b0}},2'b11}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-3){1'b0}},3'b100}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b0)-3){1'b0}},3'b101}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-3){1'b0}},3'b110}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-3){1'b0}},3'b111}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1000}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1001}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1010}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1011}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1100}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1101}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1110}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b0)-4){1'b0}},4'b1111}   : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+15] = 1'b1;
        default : mask_row_b0[`UMCTL2_AM_ROW_BASE +0+16] = 1'b1; // =5'd16 - higher values illegal
      endcase

      case(reg_ddrc_addrmap_row_b1)
        {$bits(reg_ddrc_addrmap_row_b1){1'b0}}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-1){1'b0}},1'b1}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-2){1'b0}},2'b10}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-2){1'b0}},2'b11}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-3){1'b0}},3'b100}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b1)-3){1'b0}},3'b101}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-3){1'b0}},3'b110}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-3){1'b0}},3'b111}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1000}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1001}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1010}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1011}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1100}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1101}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1110}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b1)-4){1'b0}},4'b1111}   : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+15] = 1'b1;
        default : mask_row_b1[`UMCTL2_AM_ROW_BASE +1+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b2)
        {$bits(reg_ddrc_addrmap_row_b2){1'b0}}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-1){1'b0}},1'b1}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-2){1'b0}},2'b10}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-2){1'b0}},2'b11}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-3){1'b0}},3'b100}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b2)-3){1'b0}},3'b101}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-3){1'b0}},3'b110}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-3){1'b0}},3'b111}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1000}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1001}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1010}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1011}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1100}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1101}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1110}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2)-4){1'b0}},4'b1111}   : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+15] = 1'b1;
        default : mask_row_b2[`UMCTL2_AM_ROW_BASE +2+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b3)
        {$bits(reg_ddrc_addrmap_row_b3){1'b0}}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-1){1'b0}},1'b1}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-2){1'b0}},2'b10}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-2){1'b0}},2'b11}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-3){1'b0}},3'b100}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b3)-3){1'b0}},3'b101}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-3){1'b0}},3'b110}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-3){1'b0}},3'b111}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1000}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1001}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1010}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1011}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1100}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1101}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1110}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b3)-4){1'b0}},4'b1111}   : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+15] = 1'b1;
        default : mask_row_b3[`UMCTL2_AM_ROW_BASE +3+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b4)
        {$bits(reg_ddrc_addrmap_row_b4){1'b0}}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-1){1'b0}},1'b1}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-2){1'b0}},2'b10}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-2){1'b0}},2'b11}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-3){1'b0}},3'b100}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b4)-3){1'b0}},3'b101}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-3){1'b0}},3'b110}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-3){1'b0}},3'b111}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1000}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1001}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1010}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1011}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1100}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1101}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1110}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b4)-4){1'b0}},4'b1111}   : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+15] = 1'b1;
        default : mask_row_b4[`UMCTL2_AM_ROW_BASE +4+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b5)
        {$bits(reg_ddrc_addrmap_row_b5){1'b0}}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-1){1'b0}},1'b1}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-2){1'b0}},2'b10}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-2){1'b0}},2'b11}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-3){1'b0}},3'b100}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b5)-3){1'b0}},3'b101}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-3){1'b0}},3'b110}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-3){1'b0}},3'b111}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1000}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1001}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1010}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1011}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1100}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1101}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1110}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b5)-4){1'b0}},4'b1111}   : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+15] = 1'b1;
        default : mask_row_b5[`UMCTL2_AM_ROW_BASE +5+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b6)
        {$bits(reg_ddrc_addrmap_row_b6){1'b0}}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-1){1'b0}},1'b1}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-2){1'b0}},2'b10}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-2){1'b0}},2'b11}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-3){1'b0}},3'b100}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b6)-3){1'b0}},3'b101}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-3){1'b0}},3'b110}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-3){1'b0}},3'b111}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1000}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1001}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1010}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1011}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1100}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1101}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1110}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b6)-4){1'b0}},4'b1111}   : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+15] = 1'b1;
        default : mask_row_b6[`UMCTL2_AM_ROW_BASE +6+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b7)
        {$bits(reg_ddrc_addrmap_row_b7){1'b0}}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-1){1'b0}},1'b1}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-2){1'b0}},2'b10}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-2){1'b0}},2'b11}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-3){1'b0}},3'b100}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b7)-3){1'b0}},3'b101}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-3){1'b0}},3'b110}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-3){1'b0}},3'b111}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1000}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1001}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1010}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1011}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1100}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1101}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1110}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b7)-4){1'b0}},4'b1111}   : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+15] = 1'b1;
        default : mask_row_b7[`UMCTL2_AM_ROW_BASE +7+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b8)
        {$bits(reg_ddrc_addrmap_row_b8){1'b0}}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-1){1'b0}},1'b1}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-2){1'b0}},2'b10}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-2){1'b0}},2'b11}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-3){1'b0}},3'b100}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b8)-3){1'b0}},3'b101}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-3){1'b0}},3'b110}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-3){1'b0}},3'b111}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1000}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1001}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1010}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1011}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1100}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1101}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1110}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b8)-4){1'b0}},4'b1111}   : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+15] = 1'b1;
        default : mask_row_b8[`UMCTL2_AM_ROW_BASE +8+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b9)
        {$bits(reg_ddrc_addrmap_row_b9){1'b0}}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-1){1'b0}},1'b1}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-2){1'b0}},2'b10}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-2){1'b0}},2'b11}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-3){1'b0}},3'b100}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b9)-3){1'b0}},3'b101}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-3){1'b0}},3'b110}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-3){1'b0}},3'b111}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1000}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1001}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1010}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1011}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1100}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1101}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1110}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b9)-4){1'b0}},4'b1111}   : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+15] = 1'b1;
        default : mask_row_b9[`UMCTL2_AM_ROW_BASE +9+16] = 1'b1; // =5'd16 - higher values illegal
      endcase
      
      case(reg_ddrc_addrmap_row_b10)
        {$bits(reg_ddrc_addrmap_row_b10){1'b0}}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-1){1'b0}},1'b1}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-2){1'b0}},2'b10}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-2){1'b0}},2'b11}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-3){1'b0}},3'b100}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b10)-3){1'b0}},3'b101}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-3){1'b0}},3'b110}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-3){1'b0}},3'b111}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1000}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1001}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1010}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1011}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1100}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1101}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1110}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+14] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b10)-4){1'b0}},4'b1111}   : mask_row_b10[`UMCTL2_AM_ROW_BASE +10+15] = 1'b1;
        default : mask_row_b10 = {HIF_ADDR_WIDTH{1'b0}}; // =5'd16 - higher values illegal
      endcase

      for (i=2; i<=10; i=i+1)
      begin
         case(reg_ddrc_addrmap_row_b2_10)
        {$bits(reg_ddrc_addrmap_row_b2_10){1'b0}}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-1){1'b0}},1'b1}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-2){1'b0}},2'b10}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-2){1'b0}},2'b11}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-3){1'b0}},3'b100}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b2_10)-3){1'b0}},3'b101}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-3){1'b0}},3'b110}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-3){1'b0}},3'b111}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-4){1'b0}},4'b1000}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-4){1'b0}},4'b1001}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b2_10)-4){1'b0}},4'b1010}   : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+10] = 1'b1;
           default : mask_row_b2_10[`UMCTL2_AM_ROW_BASE +i+11] = 1'b1; // =4'd11 - higher values illegal
         endcase
      end
      
      case(reg_ddrc_addrmap_row_b11)
        {$bits(reg_ddrc_addrmap_row_b11){1'b0}}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-1){1'b0}},1'b1}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-2){1'b0}},2'b10}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-2){1'b0}},2'b11}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-3){1'b0}},3'b100}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b11)-3){1'b0}},3'b101}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-3){1'b0}},3'b110}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-3){1'b0}},3'b111}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1000}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1001}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1010}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1011}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1100}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1101}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+13] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b11)-4){1'b0}},4'b1110}   : mask_row_b11[`UMCTL2_AM_ROW_BASE +11+14] = 1'b1;
        default : mask_row_b11 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_row_b12)
        {$bits(reg_ddrc_addrmap_row_b12){1'b0}}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-1){1'b0}},1'b1}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-2){1'b0}},2'b10}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-2){1'b0}},2'b11}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-3){1'b0}},3'b100}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b12)-3){1'b0}},3'b101}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-3){1'b0}},3'b110}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-3){1'b0}},3'b111}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-4){1'b0}},4'b1000}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-4){1'b0}},4'b1001}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-4){1'b0}},4'b1010}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-4){1'b0}},4'b1011}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-4){1'b0}},4'b1100}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+12] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b12)-4){1'b0}},4'b1101}   : mask_row_b12[`UMCTL2_AM_ROW_BASE +12+13] = 1'b1;
        default : mask_row_b12 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_row_b13)
        {$bits(reg_ddrc_addrmap_row_b13){1'b0}}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-1){1'b0}},1'b1}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-2){1'b0}},2'b10}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-2){1'b0}},2'b11}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-3){1'b0}},3'b100}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b13)-3){1'b0}},3'b101}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-3){1'b0}},3'b110}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-3){1'b0}},3'b111}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-4){1'b0}},4'b1000}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-4){1'b0}},4'b1001}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-4){1'b0}},4'b1010}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-4){1'b0}},4'b1011}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+11] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b13)-4){1'b0}},4'b1100}   : mask_row_b13[`UMCTL2_AM_ROW_BASE +13+12] = 1'b1;
        default : mask_row_b13 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_row_b14)
        {$bits(reg_ddrc_addrmap_row_b14){1'b0}}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-1){1'b0}},1'b1}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-2){1'b0}},2'b10}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-2){1'b0}},2'b11}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-3){1'b0}},3'b100}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b14)-3){1'b0}},3'b101}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-3){1'b0}},3'b110}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-3){1'b0}},3'b111}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-4){1'b0}},4'b1000}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-4){1'b0}},4'b1001}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-4){1'b0}},4'b1010}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+10] = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b14)-4){1'b0}},4'b1011}   : mask_row_b14[`UMCTL2_AM_ROW_BASE +14+11] = 1'b1;
        default : mask_row_b14 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_row_b15)
        {$bits(reg_ddrc_addrmap_row_b15){1'b0}}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-1){1'b0}},1'b1}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-2){1'b0}},2'b10}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-2){1'b0}},2'b11}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-3){1'b0}},3'b100}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b15)-3){1'b0}},3'b101}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-3){1'b0}},3'b110}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-3){1'b0}},3'b111}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-4){1'b0}},4'b1000}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-4){1'b0}},4'b1001}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+9]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b15)-4){1'b0}},4'b1010}   : mask_row_b15[`UMCTL2_AM_ROW_BASE +15+10] = 1'b1;
        default : mask_row_b15 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_row_b16)
        {$bits(reg_ddrc_addrmap_row_b16){1'b0}}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-1){1'b0}},1'b1}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-2){1'b0}},2'b10}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-2){1'b0}},2'b11}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-3){1'b0}},3'b100}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b16)-3){1'b0}},3'b101}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-3){1'b0}},3'b110}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-3){1'b0}},3'b111}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-4){1'b0}},4'b1000}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+8]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b16)-4){1'b0}},4'b1001}   : mask_row_b16[`UMCTL2_AM_ROW_BASE +16+9]  = 1'b1;
        default : mask_row_b16 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_row_b17)
        {$bits(reg_ddrc_addrmap_row_b17){1'b0}}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17]    = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-1){1'b0}},1'b1}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+1]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-2){1'b0}},2'b10}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+2]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-2){1'b0}},2'b11}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+3]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-3){1'b0}},3'b100}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+4]  = 1'b1;    
        {{($bits(reg_ddrc_addrmap_row_b17)-3){1'b0}},3'b101}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+5]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-3){1'b0}},3'b110}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+6]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-3){1'b0}},3'b111}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+7]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_row_b17)-4){1'b0}},4'b1000}   : mask_row_b17[`UMCTL2_AM_ROW_BASE +17+8]  = 1'b1;
        default : mask_row_b17 = {HIF_ADDR_WIDTH{1'b0}};
      endcase
   end // block: mask_row_COMB_PROC
//spyglass enable_block W415a

   assign mask_row = ((reg_ddrc_addrmap_row_b2_10=={{($bits(reg_ddrc_addrmap_row_b2_10)-4){1'b0}},4'hF}) ? (mask_row_b2 | mask_row_b3 | mask_row_b4 | 
                        mask_row_b5 | mask_row_b6 | mask_row_b7 | mask_row_b8 | mask_row_b9 | mask_row_b10) : (mask_row_b2_10)) | 
                        mask_row_b0 | mask_row_b1 | mask_row_b11 | mask_row_b12 | mask_row_b13 | mask_row_b14 | mask_row_b15 |
                        mask_row_b16 | mask_row_b17;
   // Col mask
   always @(*)
   begin: mask_col_COMB_PROC

      integer i;
      mask_col_b2 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b3 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b4 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b5 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b6 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b7 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b8 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b9 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b10 = {HIF_ADDR_WIDTH{1'b0}};
      mask_col_b11 = {HIF_ADDR_WIDTH{1'b0}};

     case(reg_ddrc_addrmap_col_b2)
        {$bits(reg_ddrc_addrmap_col_b2){1'b0}}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-1){1'b0}},1'b1}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-2){1'b0}},2'b10}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-2){1'b0}},2'b11}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-3){1'b0}},3'b100}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-3){1'b0}},3'b101}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-3){1'b0}},3'b110}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b2)-3){1'b0}},3'b111}    : mask_col_b2[`UMCTL2_AM_COLUMN_BASE+2+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b2 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b3)
        {$bits(reg_ddrc_addrmap_col_b3){1'b0}}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-1){1'b0}},1'b1}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-2){1'b0}},2'b10}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-2){1'b0}},2'b11}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-3){1'b0}},3'b100}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-3){1'b0}},3'b101}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-3){1'b0}},3'b110}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b3)-3){1'b0}},3'b111}    : mask_col_b3[`UMCTL2_AM_COLUMN_BASE+3+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b3 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b4)
        {$bits(reg_ddrc_addrmap_col_b4){1'b0}}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-1){1'b0}},1'b1}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-2){1'b0}},2'b10}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-2){1'b0}},2'b11}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-3){1'b0}},3'b100}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-3){1'b0}},3'b101}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-3){1'b0}},3'b110}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b4)-3){1'b0}},3'b111}    : mask_col_b4[`UMCTL2_AM_COLUMN_BASE+4+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b4 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b5)
        {$bits(reg_ddrc_addrmap_col_b5){1'b0}}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-1){1'b0}},1'b1}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-2){1'b0}},2'b10}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-2){1'b0}},2'b11}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-3){1'b0}},3'b100}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-3){1'b0}},3'b101}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-3){1'b0}},3'b110}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b5)-3){1'b0}},3'b111}    : mask_col_b5[`UMCTL2_AM_COLUMN_BASE+5+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b5 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b6)
        {$bits(reg_ddrc_addrmap_col_b6){1'b0}}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-1){1'b0}},1'b1}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-2){1'b0}},2'b10}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-2){1'b0}},2'b11}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-3){1'b0}},3'b100}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-3){1'b0}},3'b101}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-3){1'b0}},3'b110}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b6)-3){1'b0}},3'b111}    : mask_col_b6[`UMCTL2_AM_COLUMN_BASE+6+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b6 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b7)
        {$bits(reg_ddrc_addrmap_col_b7){1'b0}}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-1){1'b0}},1'b1}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-2){1'b0}},2'b10}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-2){1'b0}},2'b11}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-3){1'b0}},3'b100}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-3){1'b0}},3'b101}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-3){1'b0}},3'b110}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b7)-3){1'b0}},3'b111}    : mask_col_b7[`UMCTL2_AM_COLUMN_BASE+7+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b7 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b8)
        {$bits(reg_ddrc_addrmap_col_b8){1'b0}}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-1){1'b0}},1'b1}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-2){1'b0}},2'b10}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-2){1'b0}},2'b11}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-3){1'b0}},3'b100}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-3){1'b0}},3'b101}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-3){1'b0}},3'b110}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b8)-3){1'b0}},3'b111}    : mask_col_b8[`UMCTL2_AM_COLUMN_BASE+8+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b8 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b9)
        {$bits(reg_ddrc_addrmap_col_b9){1'b0}}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-1){1'b0}},1'b1}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-2){1'b0}},2'b10}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-2){1'b0}},2'b11}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-3){1'b0}},3'b100}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-3){1'b0}},3'b101}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-3){1'b0}},3'b110}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b9)-3){1'b0}},3'b111}    : mask_col_b9[`UMCTL2_AM_COLUMN_BASE+9+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b9 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b10)
        {$bits(reg_ddrc_addrmap_col_b10){1'b0}}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-1){1'b0}},1'b1}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-2){1'b0}},2'b10}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-2){1'b0}},2'b11}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-3){1'b0}},3'b100}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-3){1'b0}},3'b101}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-3){1'b0}},3'b110}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b10)-3){1'b0}},3'b111}    : mask_col_b10[`UMCTL2_AM_COLUMN_BASE+10+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b10 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

      case(reg_ddrc_addrmap_col_b11)
        {$bits(reg_ddrc_addrmap_col_b11){1'b0}}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11  -am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-1){1'b0}},1'b1}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+1-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-2){1'b0}},2'b10}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+2-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-2){1'b0}},2'b11}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+3-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-3){1'b0}},3'b100}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+4-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-3){1'b0}},3'b101}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+5-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-3){1'b0}},3'b110}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+6-am_column_base_shift]  = 1'b1;
        {{($bits(reg_ddrc_addrmap_col_b11)-3){1'b0}},3'b111}    : mask_col_b11[`UMCTL2_AM_COLUMN_BASE+11+7-am_column_base_shift]  = 1'b1;
        default : mask_col_b11 = {HIF_ADDR_WIDTH{1'b0}};
      endcase

   end // mask_col_COMB_PROC
   
   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read 
   //SJ: Used in generate statement and therefore must always exist.
   assign mask_col = (mask_col_b2 | mask_col_b3 | mask_col_b4 | mask_col_b5 | mask_col_b6 | mask_col_b7 | mask_col_b8 | mask_col_b9 | mask_col_b10 | mask_col_b11);
   //spyglass enable_block W528

   // The full mask
   assign mask_row_bank = (mask_row | mask_bank | mask_cs);

   // (data channel encoding)
   assign mask_data_channel = mask_dch;

   // Scrubber mask
   generate
      if (SBR_EN==1) begin: GEN_mask_sbr_enabled
         wire [HIF_ADDR_WIDTH-1:0] mask_row_bank_bg, granted_range;
         wire [HIF_ADDR_WIDTH-1:0] unmask_higher_pri_reqs;
         reg  [HIF_ADDR_WIDTH-1:0]  address_range_msb, inv_mask_row_bank_bg;
      
         assign mask_row_bank_bg = mask_col | mask_row | mask_bank | mask_cs | mask_dch 
                                   ;

         // The goal is to find MSB of mask_roq_bank_bg
         // Then from that, we can create a vector (or a new mask) to tell us the range
         // of the full adress space programmed.

         //spyglass disable_block SelfDeterminedExpr-ML
         //SMD: Self determined expression '((HIF_ADDR_WIDTH - 1) - i)' found in module 'DWC_ddr_umctl2_pm_mask'
         //SJ: This coding style is acceptable and there is no plan to change it.

         // 1) Inverse the mask
         always @(*) begin: inverseMask_COMB_PROC
            integer i;
            for (i=0; i<HIF_ADDR_WIDTH; i=i+1)
              inv_mask_row_bank_bg[i] = mask_row_bank_bg[HIF_ADDR_WIDTH-1-i];
         end

         // 2) Using a fixed-priority arbiter find the lowest significant bit set to 1
         assign unmask_higher_pri_reqs[HIF_ADDR_WIDTH-1:1] = unmask_higher_pri_reqs[HIF_ADDR_WIDTH-2:0] | inv_mask_row_bank_bg[HIF_ADDR_WIDTH-2:0];
         assign unmask_higher_pri_reqs[0] = 1'b0;
         assign granted_range = inv_mask_row_bank_bg & ~unmask_higher_pri_reqs;  

         // 3) Inverse the mask again
         always @(*) begin: inverseRange_COMB_PROC
            integer i;
            for (i=0; i<HIF_ADDR_WIDTH; i=i+1)
              address_range_msb[i] = granted_range[HIF_ADDR_WIDTH-1-i];
         end
         //spyglass enable_block SelfDeterminedExpr-ML

         // 4) Calculate the full address range
         // This will never overflow as address_range_msb is always 2^n
         // Say 1000, the resultant range is 1000 + 0111 
         assign address_range_all = address_range_msb + (address_range_msb-1);
      end // block: GEN_mask_sbr_enabled
      else begin: GEN_mask_sbr_disabled
         assign address_range_all = {HIF_ADDR_WIDTH{1'b0}};
      end

      assign row_invalid_mask = (reg_ddrc_nonbinary_device_density==3'b001) ? (mask_row_b12 | mask_row_b13) :
                                (reg_ddrc_nonbinary_device_density==3'b010) ? (mask_row_b13 | mask_row_b14) :
                                (reg_ddrc_nonbinary_device_density==3'b011) ? (mask_row_b14 | mask_row_b15) :
                                (reg_ddrc_nonbinary_device_density==3'b100) ? (mask_row_b15 | mask_row_b16) :
                                (reg_ddrc_nonbinary_device_density==3'b101) ? (mask_row_b16 | mask_row_b17) :
                                                                         {HIF_ADDR_WIDTH{1'b0}};

      if (INLINE_ECC==1) begin: IECC_en
         assign highest_column_mask = reg_ddrc_addrmap_col_b11!=COL_BIT_DIS ? `UMCTL2_AM_COLUMN_BASE+11+reg_ddrc_addrmap_col_b11 -am_column_base_shift:
                                      reg_ddrc_addrmap_col_b10!=COL_BIT_DIS ? `UMCTL2_AM_COLUMN_BASE+10+reg_ddrc_addrmap_col_b10 -am_column_base_shift: 
                                      reg_ddrc_addrmap_col_b9 !=COL_BIT_DIS ? `UMCTL2_AM_COLUMN_BASE+9+reg_ddrc_addrmap_col_b9   -am_column_base_shift: 
                                                                              `UMCTL2_AM_COLUMN_BASE+8+reg_ddrc_addrmap_col_b8   -am_column_base_shift;

         if (MBL==16) begin: MBL16

            assign lowest_column_mask  = mask_col_b4 | mask_col_b5 | mask_col_b6;

         end
         else begin: MBL8

            assign lowest_column_mask  = mask_col_b3 | mask_col_b4 | mask_col_b5;

         end

      end
      else begin: IECC_dis
         assign highest_column_mask = {ECC_H3_WIDTH{1'b0}};
         assign lowest_column_mask  = {HIF_ADDR_WIDTH{1'b0}};
      end
   endgenerate

  assign mask_bg_or_bank = mask_bg; // TODO Need to be updated when AXI sideband autopre feature will be supported LPDDR4 config.

   wire occap_par_poison_en;
   assign occap_par_poison_en = 1'b0; // poison always disabled for these registers

   wire [OUT_REG_WIDTH-1:0] out_reg_d, out_reg_q;

   assign out_reg_d = {mask_row_bank,mask_data_channel,mask_bg_or_bank,address_range_all,row_invalid_mask,highest_column_mask,lowest_column_mask};
   assign {pagematch_addrmap_mask,data_channel_addrmap_mask,bg_or_bank_addrmap_mask,sbr_address_range,lpddr34_6gb_12gb_mask,h3_iecc_col_mask,l3_iecc_col_mask} = out_reg_q;


   
   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (OUT_REG_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .SL_W    (8)
   )
   U_addr_mask
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (out_reg_d),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (occap_par_poison_en),
      .data_out   (out_reg_q),
      .parity_err (pm_mask_parity_err)
   );


endmodule // DWC_ddr_umctl2_pm_mask
