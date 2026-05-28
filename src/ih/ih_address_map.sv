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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_address_map.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This module generates row address, column number, rank number and bank number
// from the HIF address to access the memory.
//
// component starting bit position within the input address = base + offset.
// rest of the bits are contiguous.
//
// Author : Meghana Sardesai 
// Date: September 01, 2004
// v3
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ih_address_map #(
     parameter       AM_DCH_WIDTH     = 6
    ,parameter       AM_CS_WIDTH      = 6
    ,parameter       AM_CID_WIDTH     = 6
    ,parameter       AM_BANK_WIDTH    = 6
    ,parameter       AM_BG_WIDTH      = 6
    ,parameter       AM_ROW_WIDTH     = 5
    ,parameter       AM_COL_WIDTH_H   = 5
    ,parameter       AM_COL_WIDTH_L   = 4
                      ) (am_block, am_critical_dword, am_row, am_bg_bank, am_cpu_address,

                bg_b16_addr_mode,


                am_bg_offset_bit0, am_bg_offset_bit1,
                am_bs_offset_bit0, am_bs_offset_bit1,
                am_bs_offset_bit2,
                am_column_offset_bit3, am_column_offset_bit4,
                am_column_offset_bit5, am_column_offset_bit6, am_column_offset_bit7,
                am_column_offset_bit8, am_column_offset_bit9, am_column_offset_bit10,
                am_row_offset_bit0, am_row_offset_bit1, am_row_offset_bit2, am_row_offset_bit3,
                am_row_offset_bit4, am_row_offset_bit5, am_row_offset_bit6, am_row_offset_bit7,
                am_row_offset_bit8, am_row_offset_bit9, am_row_offset_bit10,
                am_row_offset_bit11, am_row_offset_bit12, am_row_offset_bit13, am_row_offset_bit14, am_row_offset_bit15
                ,am_row_offset_bit16
                ,am_row_offset_bit17
                );


        localparam  COL_BITS = `MEMC_BLK_BITS + `MEMC_WORD_BITS;
        localparam  CID_WIDTH = `UMCTL2_CID_WIDTH; 

  // IO DECLARATION
  input                       bg_b16_addr_mode;

  output [`MEMC_BLK_BITS-1:0] am_block;
  output [`MEMC_WORD_BITS-1:0] am_critical_dword;
  output [`MEMC_PAGE_BITS-1:0] am_row;
  output [`MEMC_BG_BANK_BITS-1:0] am_bg_bank;


  input  [`MEMC_HIF_ADDR_WIDTH-1:0] am_cpu_address;


  input  [AM_BG_WIDTH-1:0]  am_bg_offset_bit0;
  input  [AM_BG_WIDTH-1:0]  am_bg_offset_bit1;

  input  [AM_BANK_WIDTH-1:0]  am_bs_offset_bit0;
  input  [AM_BANK_WIDTH-1:0]  am_bs_offset_bit1;
  input  [AM_BANK_WIDTH-1:0]  am_bs_offset_bit2;

  input  [AM_COL_WIDTH_L-1:0]  am_column_offset_bit3;
  input  [AM_COL_WIDTH_L-1:0]  am_column_offset_bit4;
  input  [AM_COL_WIDTH_L-1:0]  am_column_offset_bit5;
  input  [AM_COL_WIDTH_L-1:0]  am_column_offset_bit6;
  input  [AM_COL_WIDTH_H-1:0]  am_column_offset_bit7;
  input  [AM_COL_WIDTH_H-1:0]  am_column_offset_bit8;
  input  [AM_COL_WIDTH_H-1:0]  am_column_offset_bit9;
  input  [AM_COL_WIDTH_H-1:0]  am_column_offset_bit10;

  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit0;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit1;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit2;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit3;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit4;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit5;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit6;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit7;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit8;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit9;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit10;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit11;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit12;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit13;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit14;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit15;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit16;
  input  [AM_ROW_WIDTH-1:0]  am_row_offset_bit17;

  reg [COL_BITS-1:0] am_column;

  wire   [`MEMC_BLK_BITS-1:0] am_block;
  assign am_block = am_column [COL_BITS-1:`MEMC_WORD_BITS];

  wire   [`MEMC_WORD_BITS-1:0] am_critical_dword;
  assign am_critical_dword = am_column [`MEMC_WORD_BITS-1:0];

  reg  [`MEMC_PAGE_BITS-1:0] am_row;
  wire [`MEMC_BANK_BITS-1:0] am_bank;
  wire [`MEMC_BG_BANK_BITS-1:0] am_bg_bank;


  wire [`MEMC_BG_BITS-1:0] am_bankgroup;

  wire  [`MEMC_HIF_ADDR_WIDTH-1:0] am_cpu_address;


  wire   [AM_BG_WIDTH-1:0]  am_bg_offset_bit0;
  wire   [AM_BG_WIDTH-1:0]  am_bg_offset_bit1;

  wire   [AM_BANK_WIDTH-1:0]  am_bs_offset_bit0;
  wire   [AM_BANK_WIDTH-1:0]  am_bs_offset_bit1;
  wire   [AM_BANK_WIDTH-1:0]  am_bs_offset_bit2;

  wire   [AM_COL_WIDTH_L-1:0]  am_column_offset_bit3;
  wire   [AM_COL_WIDTH_L-1:0]  am_column_offset_bit4;
  wire   [AM_COL_WIDTH_L-1:0]  am_column_offset_bit5;
  wire   [AM_COL_WIDTH_L-1:0]  am_column_offset_bit6;
  wire   [AM_COL_WIDTH_H-1:0]  am_column_offset_bit7;
  wire   [AM_COL_WIDTH_H-1:0]  am_column_offset_bit8;
  wire   [AM_COL_WIDTH_H-1:0]  am_column_offset_bit9;
  wire   [AM_COL_WIDTH_H-1:0]  am_column_offset_bit10;

  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit0;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit1;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit2;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit3;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit4;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit5;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit6;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit7;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit8;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit9;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit10;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit11;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit12;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit13;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit14;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit15;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit16;
  wire   [AM_ROW_WIDTH-1:0]  am_row_offset_bit17;


  // EXTRACT THE COMPONENTS BASED UPON THE STARTING ADDRESS
  // WITHIN THE GIVEN CPU_ADDRESS

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(6 + 2)' found in module 'ih_address_map'
//SJ: This coding style (such as "am_rank[0] = am_cpu_address[`UMCTL2_AM_RANK_BASE +1];") is acceptable and there is no plan to change it.


reg  [`MEMC_BG_BITS-1:0]   am_bg_int;
reg  [`MEMC_BANK_BITS-1:0] am_bank_int;


//-----------------
// am_bg_bank is used to carry both the bankgroup and bank information
//  - this signal is 3-bits for all designs in which MEMC_DDR4 is not defined
//  - if MEMC_DDR4 is defined, this signal is 4-bits
//       - in DDR4 mode, LSB 2 bits carry bank group info and MSB 2 bits carry bank info
//       - in non-DDR4 mode, LSB 3-bits carry bank info, MSB 1-bit is set to 0
//  - if MEMC_DDR4 is not defined, this signal is 3-bits
//       - LSB 3-bits carry bank info
//-----------------
assign am_bg_bank[1:0]  =                          bg_b16_addr_mode ?  am_bg_int[1:0] :
                                              am_bank_int[1:0];

assign am_bg_bank[2]    =                          bg_b16_addr_mode ?  am_bank_int[0] :
                                              am_bank_int[2];

assign am_bg_bank[3] = bg_b16_addr_mode ? am_bank_int[1] : 1'b0;


//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used for debug purposes

//--------------
// Generating these 2 signals for debug purpose only
//--------------
assign am_bankgroup = am_bg_bank[`MEMC_BG_BITS-1:0];

assign am_bank =                     bg_b16_addr_mode ? am_bg_bank[`MEMC_BG_BANK_BITS-1:`MEMC_BG_BITS] :
                                        am_bg_bank[`MEMC_BANK_BITS-1:0];

//spyglass enable_block W528

//----------------------------
   wire [1:0] am_column_base_shift;
   assign am_column_base_shift = 2'd0;

  always @(*)
  begin



        // EXTRACT BANK GROUP NUMBER

  case(am_bg_offset_bit0)
    {$bits(am_bg_offset_bit0){1'b0}} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0];
    {{($bits(am_bg_offset_bit0)-1){1'b0}},1'b1} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+1];
    {{($bits(am_bg_offset_bit0)-2){1'b0}},2'b10} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+2];
    {{($bits(am_bg_offset_bit0)-2){1'b0}},2'b11} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+3];
    {{($bits(am_bg_offset_bit0)-3){1'b0}},3'b100} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+4];  
    {{($bits(am_bg_offset_bit0)-3){1'b0}},3'b101} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+5];
    {{($bits(am_bg_offset_bit0)-3){1'b0}},3'b110} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+6];
    {{($bits(am_bg_offset_bit0)-3){1'b0}},3'b111} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+7];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1000} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+8];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1001} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+9];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1010} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+10];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1011} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+11];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1100} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+12];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1101} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+13];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1110} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+14];
    {{($bits(am_bg_offset_bit0)-4){1'b0}},4'b1111} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+15];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10000} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+16];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10001} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+17];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10010} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+18];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10011} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+19];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10100} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+20];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10101} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+21];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10110} : am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+22];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b10111}: am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+23];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b11000}: am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+24];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b11001}: am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+25];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b11010}: am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+26];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b11011}: am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+27];
    {{($bits(am_bg_offset_bit0)-5){1'b0}},5'b11100}: am_bg_int[0] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +0+28];

    default : am_bg_int[0] = 1'b0; // higher values illegal
  endcase

  case(am_bg_offset_bit1)
    {$bits(am_bg_offset_bit1){1'b0}} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1];
    {{($bits(am_bg_offset_bit1)-1){1'b0}},1'b1} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+1];
    {{($bits(am_bg_offset_bit1)-2){1'b0}},2'b10} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+2];
    {{($bits(am_bg_offset_bit1)-2){1'b0}},2'b11} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+3];
    {{($bits(am_bg_offset_bit1)-3){1'b0}},3'b100} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+4];  
    {{($bits(am_bg_offset_bit1)-3){1'b0}},3'b101} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+5];
    {{($bits(am_bg_offset_bit1)-3){1'b0}},3'b110} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+6];
    {{($bits(am_bg_offset_bit1)-3){1'b0}},3'b111} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+7];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1000} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+8];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1001} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+9];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1010} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+10];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1011} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+11];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1100} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+12];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1101} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+13];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1110} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+14];
    {{($bits(am_bg_offset_bit1)-4){1'b0}},4'b1111} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+15];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10000} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+16];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10001} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+17];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10010} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+18];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10011} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+19];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10100} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+20];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10101} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+21];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10110} : am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+22];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b10111}: am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+23];
    {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b11000}: am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+24];
              {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b11001}: am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+25];
              {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b11010}: am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+26];
              {{($bits(am_bg_offset_bit1)-5){1'b0}},5'b11011}: am_bg_int[1] = am_cpu_address[`UMCTL2_AM_BANKGROUP_BASE +1+27];

        default : am_bg_int[1] = 1'b0;
  endcase




  // EXTRACT BANK NUMBER

  case(am_bs_offset_bit0)
    {$bits(am_bs_offset_bit0){1'b0}} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0];
    {{($bits(am_bs_offset_bit0)-1){1'b0}},1'b1} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+1];
    {{($bits(am_bs_offset_bit0)-2){1'b0}},2'b10} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+2];
    {{($bits(am_bs_offset_bit0)-2){1'b0}},2'b11} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+3];
    {{($bits(am_bs_offset_bit0)-3){1'b0}},3'b100} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+4];  
    {{($bits(am_bs_offset_bit0)-3){1'b0}},3'b101} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+5];
    {{($bits(am_bs_offset_bit0)-3){1'b0}},3'b110} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+6];
    {{($bits(am_bs_offset_bit0)-3){1'b0}},3'b111} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+7];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1000} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+8];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1001} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+9];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1010} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+10];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1011} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+11];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1100} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+12];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1101} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+13];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1110} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+14];
    {{($bits(am_bs_offset_bit0)-4){1'b0}},4'b1111} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+15];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10000} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+16];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10001} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+17];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10010} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+18];  
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10011} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+19];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10100} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+20];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10101} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+21];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10110} : am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+22];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b10111}: am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+23];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b11000}: am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+24];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b11001}: am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+25];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b11010}: am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+26];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b11011}: am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+27];
    {{($bits(am_bs_offset_bit0)-5){1'b0}},5'b11100}: am_bank_int[0] = am_cpu_address[`UMCTL2_AM_BANK_BASE +0+28];

    default : am_bank_int[0] = 1'b0; // higher values illegal

  endcase

  case(am_bs_offset_bit1)
    {$bits(am_bs_offset_bit1){1'b0}} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1];
    {{($bits(am_bs_offset_bit1)-1){1'b0}},1'b1} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+1];
    {{($bits(am_bs_offset_bit1)-2){1'b0}},2'b10} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+2];
    {{($bits(am_bs_offset_bit1)-2){1'b0}},2'b11} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+3];
    {{($bits(am_bs_offset_bit1)-3){1'b0}},3'b100} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+4];  
    {{($bits(am_bs_offset_bit1)-3){1'b0}},3'b101} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+5];
    {{($bits(am_bs_offset_bit1)-3){1'b0}},3'b110} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+6];
    {{($bits(am_bs_offset_bit1)-3){1'b0}},3'b111} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+7];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1000} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+8];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1001} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+9];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1010} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+10];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1011} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+11];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1100} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+12];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1101} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+13];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1110} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+14];
    {{($bits(am_bs_offset_bit1)-4){1'b0}},4'b1111} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+15];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10000} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+16];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10001} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+17];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10010} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+18];  
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10011} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+19];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10100} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+20];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10101} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+21];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10110} : am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+22];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b10111}: am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+23];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b11000}: am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+24];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b11001}: am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+25];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b11010}: am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+26];
    {{($bits(am_bs_offset_bit1)-5){1'b0}},5'b11011}: am_bank_int[1] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+27];

    default : am_bank_int[1] = 1'b0;  
  endcase

  case(am_bs_offset_bit2)
    {$bits(am_bs_offset_bit2){1'b0}} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +2];
    {{($bits(am_bs_offset_bit2)-1){1'b0}},1'b1} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +1+2];
    {{($bits(am_bs_offset_bit2)-2){1'b0}},2'b10} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +2+2];
    {{($bits(am_bs_offset_bit2)-2){1'b0}},2'b11} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +3+2];
    {{($bits(am_bs_offset_bit2)-3){1'b0}},3'b100} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +4+2];  
    {{($bits(am_bs_offset_bit2)-3){1'b0}},3'b101} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +5+2];
    {{($bits(am_bs_offset_bit2)-3){1'b0}},3'b110} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +6+2];
    {{($bits(am_bs_offset_bit2)-3){1'b0}},3'b111} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +7+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1000} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +8+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1001} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +9+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1010} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +10+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1011} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +11+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1100} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +12+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1101} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +13+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1110} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +14+2];
    {{($bits(am_bs_offset_bit2)-4){1'b0}},4'b1111} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +15+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10000} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +16+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10001} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +17+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10010} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +18+2];  
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10011} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +19+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10100} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +20+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10101} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +21+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10110} : am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +22+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b10111}: am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +23+2];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b11000}: am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +2+24];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b11001}: am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +2+25];
    {{($bits(am_bs_offset_bit2)-5){1'b0}},5'b11010}: am_bank_int[2] = am_cpu_address[`UMCTL2_AM_BANK_BASE +2+26];

    default : am_bank_int[2] = 1'b0;  
  endcase


  // EXTRACT ROW ADDRESS

  case(am_row_offset_bit0)
    {$bits(am_row_offset_bit0){1'b0}}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE ];
    {{($bits(am_row_offset_bit0)-1){1'b0}},1'b1}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1];
    {{($bits(am_row_offset_bit0)-2){1'b0}},2'b10}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2];
    {{($bits(am_row_offset_bit0)-2){1'b0}},2'b11}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3];
    {{($bits(am_row_offset_bit0)-3){1'b0}},3'b100}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4];  
    {{($bits(am_row_offset_bit0)-3){1'b0}},3'b101}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5];
    {{($bits(am_row_offset_bit0)-3){1'b0}},3'b110}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6];
    {{($bits(am_row_offset_bit0)-3){1'b0}},3'b111}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1000}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1001}  : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1010} : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1011} : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1100} : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +12];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1101} : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +13];
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1110} : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +14];  
    {{($bits(am_row_offset_bit0)-4){1'b0}},4'b1111} : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +15];
    default : am_row[0] = am_cpu_address[`UMCTL2_AM_ROW_BASE +16]; // =4'd16 - higher values illegal
  endcase

  case(am_row_offset_bit1)
    {$bits(am_row_offset_bit1){1'b0}}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1];
    {{($bits(am_row_offset_bit1)-1){1'b0}},1'b1}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+1];
    {{($bits(am_row_offset_bit1)-2){1'b0}},2'b10}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+1];
    {{($bits(am_row_offset_bit1)-2){1'b0}},2'b11}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+1];
    {{($bits(am_row_offset_bit1)-3){1'b0}},3'b100}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+1];  
    {{($bits(am_row_offset_bit1)-3){1'b0}},3'b101}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+1];
    {{($bits(am_row_offset_bit1)-3){1'b0}},3'b110}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+1];
    {{($bits(am_row_offset_bit1)-3){1'b0}},3'b111}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1000}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1001}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1010} : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1011}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1100}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +12+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1101}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +13+1];
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1110}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +14+1];  
    {{($bits(am_row_offset_bit1)-4){1'b0}},4'b1111}  : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +15+1];
    default : am_row[1] = am_cpu_address[`UMCTL2_AM_ROW_BASE +16+1]; // =4'd16 - higher values illegal
  endcase
  
//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index '((6 + 4) + ((am_row_offset_bit4<={{ ($bits(am_row_offset_bit4) - 4){ 1'b0} } ,4'b1111}) ? am_row_offset_bit4 : 16))' of width '6' is larger than the width '5' required for the max value '31' of the signal 'am_cpu_address'
//SJ: The extra 1 bit width of index is due to the carry of arithmetic operation. Overflow will not happen.
  am_row[2] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 2 + ((am_row_offset_bit2 <= {{($bits(am_row_offset_bit2)-4){1'b0}},4'b1111}) ? am_row_offset_bit2 : 16)];
  
  am_row[3] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 3 + ((am_row_offset_bit3 <= {{($bits(am_row_offset_bit3)-4){1'b0}},4'b1111}) ? am_row_offset_bit3 : 16)]; 

  am_row[4] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 4 + ((am_row_offset_bit4 <= {{($bits(am_row_offset_bit4)-4){1'b0}},4'b1111}) ? am_row_offset_bit4 : 16)]; 
                  
  am_row[5] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 5 + ((am_row_offset_bit5 <= {{($bits(am_row_offset_bit5)-4){1'b0}},4'b1111}) ? am_row_offset_bit5 : 16)]; 
                  
  am_row[6] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 6 + ((am_row_offset_bit6 <= {{($bits(am_row_offset_bit6)-4){1'b0}},4'b1111}) ? am_row_offset_bit6 : 16)];
                  
  am_row[7] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 7 + ((am_row_offset_bit7 <= {{($bits(am_row_offset_bit7)-4){1'b0}},4'b1111}) ? am_row_offset_bit7 : 16)]; 
                  
  am_row[8] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 8 + ((am_row_offset_bit8 <= {{($bits(am_row_offset_bit8)-4){1'b0}},4'b1111}) ? am_row_offset_bit8 : 16)]; 
                  
  am_row[9] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 9 + ((am_row_offset_bit9 <= {{($bits(am_row_offset_bit9)-4){1'b0}},4'b1111}) ? am_row_offset_bit9 : 16)]; 
           
  am_row[10] = am_cpu_address[`UMCTL2_AM_ROW_BASE + 10 + ((am_row_offset_bit10 <= {{($bits(am_row_offset_bit10)-4){1'b0}},4'b1111}) ? am_row_offset_bit10 : 16)];
//spyglass enable_block ImproperRangeIndex-ML
                  
  case(am_row_offset_bit11)
    {$bits(am_row_offset_bit11){1'b0}}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11];
    {{($bits(am_row_offset_bit11)-1){1'b0}},1'b1}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+11];
    {{($bits(am_row_offset_bit11)-2){1'b0}},2'b10}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+11];
    {{($bits(am_row_offset_bit11)-2){1'b0}},2'b11}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+11];
    {{($bits(am_row_offset_bit11)-3){1'b0}},3'b100}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+11];  
    {{($bits(am_row_offset_bit11)-3){1'b0}},3'b101}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+11];
    {{($bits(am_row_offset_bit11)-3){1'b0}},3'b110}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+11];
    {{($bits(am_row_offset_bit11)-3){1'b0}},3'b111}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1000}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1001}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1010} : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1011} : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1100}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +12+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1101}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +13+11];
    {{($bits(am_row_offset_bit11)-4){1'b0}},4'b1110}  : am_row[11] = am_cpu_address[`UMCTL2_AM_ROW_BASE +14+11];  
    // Maximum supported value of am_row_offset_bit11 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit11 has a base of 17, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 17 - 1.
                // This is subject to a maximum of 11 for row addresses.
    default : am_row[11] = 1'b0;
  endcase

  case(am_row_offset_bit12)
    {$bits(am_row_offset_bit12){1'b0}}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +12];
    {{($bits(am_row_offset_bit12)-1){1'b0}},1'b1}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+12];
    {{($bits(am_row_offset_bit12)-2){1'b0}},2'b10}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+12];
    {{($bits(am_row_offset_bit12)-2){1'b0}},2'b11}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+12];
    {{($bits(am_row_offset_bit12)-3){1'b0}},3'b100}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+12];  
    {{($bits(am_row_offset_bit12)-3){1'b0}},3'b101}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+12];
    {{($bits(am_row_offset_bit12)-3){1'b0}},3'b110}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+12];
    {{($bits(am_row_offset_bit12)-3){1'b0}},3'b111}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+12];
    {{($bits(am_row_offset_bit12)-4){1'b0}},4'b1000}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+12];
    {{($bits(am_row_offset_bit12)-4){1'b0}},4'b1001}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+12];
    {{($bits(am_row_offset_bit12)-4){1'b0}},4'b1010} : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10+12];
    {{($bits(am_row_offset_bit12)-4){1'b0}},4'b1011} : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11+12];
    {{($bits(am_row_offset_bit12)-4){1'b0}},4'b1100}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +12+12];
    {{($bits(am_row_offset_bit12)-4){1'b0}},4'b1101}  : am_row[12] = am_cpu_address[`UMCTL2_AM_ROW_BASE +13+12];
    // Maximum supported value of am_row_offset_bit12 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit12 has a base of 18, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 18 - 1.
                // This is subject to a maximum of 11 for row addresses.
    default : am_row[12] = 1'b0;
  endcase

  case(am_row_offset_bit13)
    {$bits(am_row_offset_bit13){1'b0}}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +13];
    {{($bits(am_row_offset_bit13)-1){1'b0}},1'b1}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+13];
    {{($bits(am_row_offset_bit13)-2){1'b0}},2'b10}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+13];
    {{($bits(am_row_offset_bit13)-2){1'b0}},2'b11}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+13];
    {{($bits(am_row_offset_bit13)-3){1'b0}},3'b100}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+13];  
    {{($bits(am_row_offset_bit13)-3){1'b0}},3'b101}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+13];
    {{($bits(am_row_offset_bit13)-3){1'b0}},3'b110}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+13];
    {{($bits(am_row_offset_bit13)-3){1'b0}},3'b111}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+13];
    {{($bits(am_row_offset_bit13)-4){1'b0}},4'b1000}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+13];
    {{($bits(am_row_offset_bit13)-4){1'b0}},4'b1001}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+13];
    {{($bits(am_row_offset_bit13)-4){1'b0}},4'b1010} : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10+13];
    {{($bits(am_row_offset_bit13)-4){1'b0}},4'b1011} : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11+13];
    {{($bits(am_row_offset_bit13)-4){1'b0}},4'b1100}  : am_row[13] = am_cpu_address[`UMCTL2_AM_ROW_BASE +12+13];
    // Maximum supported value of am_row_offset_bit13 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit13 has a base of 19, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 19 - 1.
                // This is subject to a maximum of 11 for row addresses.
    default : am_row[13] = 1'b0;
  endcase

  case(am_row_offset_bit14)
    {$bits(am_row_offset_bit14){1'b0}}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +14];
    {{($bits(am_row_offset_bit14)-1){1'b0}},1'b1}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+14];
    {{($bits(am_row_offset_bit14)-2){1'b0}},2'b10}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+14];
    {{($bits(am_row_offset_bit14)-2){1'b0}},2'b11}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+14];
    {{($bits(am_row_offset_bit14)-3){1'b0}},3'b100}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+14];  
    {{($bits(am_row_offset_bit14)-3){1'b0}},3'b101}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+14];
    {{($bits(am_row_offset_bit14)-3){1'b0}},3'b110}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+14];
    {{($bits(am_row_offset_bit14)-3){1'b0}},3'b111}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+14];
    {{($bits(am_row_offset_bit14)-4){1'b0}},4'b1000}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+14];
    {{($bits(am_row_offset_bit14)-4){1'b0}},4'b1001}  : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+14];
    {{($bits(am_row_offset_bit14)-4){1'b0}},4'b1010} : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10+14];
    {{($bits(am_row_offset_bit14)-4){1'b0}},4'b1011} : am_row[14] = am_cpu_address[`UMCTL2_AM_ROW_BASE +11+14];
    // Maximum supported value of am_row_offset_bit14 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit14 has a base of 20, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 20 - 1.
    default : am_row[14] = 1'b0;
  endcase

  case(am_row_offset_bit15)
    {$bits(am_row_offset_bit15){1'b0}}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +15];
    {{($bits(am_row_offset_bit15)-1){1'b0}},1'b1}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+15];
    {{($bits(am_row_offset_bit15)-2){1'b0}},2'b10}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+15];
    {{($bits(am_row_offset_bit15)-2){1'b0}},2'b11}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+15];
    {{($bits(am_row_offset_bit15)-3){1'b0}},3'b100}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+15];  
    {{($bits(am_row_offset_bit15)-3){1'b0}},3'b101}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+15];
    {{($bits(am_row_offset_bit15)-3){1'b0}},3'b110}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+15];
    {{($bits(am_row_offset_bit15)-3){1'b0}},3'b111}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+15];
    {{($bits(am_row_offset_bit15)-4){1'b0}},4'b1000}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+15];
    {{($bits(am_row_offset_bit15)-4){1'b0}},4'b1001}  : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+15];
    {{($bits(am_row_offset_bit15)-4){1'b0}},4'b1010} : am_row[15] = am_cpu_address[`UMCTL2_AM_ROW_BASE +10+15];
    // Maximum supported value of am_row_offset_bit15 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit15 has a base of 21, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 21 - 1.
    default : am_row[15] = 1'b0;
  endcase

  case(am_row_offset_bit16)
      {$bits(am_row_offset_bit16){1'b0}}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +16];
      {{($bits(am_row_offset_bit16)-1){1'b0}},1'b1}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+16];
      {{($bits(am_row_offset_bit16)-2){1'b0}},2'b10}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+16];
      {{($bits(am_row_offset_bit16)-2){1'b0}},2'b11}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+16];
      {{($bits(am_row_offset_bit16)-3){1'b0}},3'b100}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+16];       
      {{($bits(am_row_offset_bit16)-3){1'b0}},3'b101}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+16];
      {{($bits(am_row_offset_bit16)-3){1'b0}},3'b110}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+16];
      {{($bits(am_row_offset_bit16)-3){1'b0}},3'b111}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+16];
      {{($bits(am_row_offset_bit16)-4){1'b0}},4'b1000}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+16];
      {{($bits(am_row_offset_bit16)-4){1'b0}},4'b1001}    : am_row[16] = am_cpu_address[`UMCTL2_AM_ROW_BASE +9+16];
      // Maximum supported value of am_row_offset_bit16 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit16 has a base of 21, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 21 - 1.
      default : am_row[16] = 1'b0;
  endcase


  case(am_row_offset_bit17)
      {$bits(am_row_offset_bit17){1'b0}}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +17];
      {{($bits(am_row_offset_bit17)-1){1'b0}},1'b1}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +1+17];
      {{($bits(am_row_offset_bit17)-2){1'b0}},2'b10}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +2+17];
      {{($bits(am_row_offset_bit17)-2){1'b0}},2'b11}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +3+17];
      {{($bits(am_row_offset_bit17)-3){1'b0}},3'b100}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +4+17];       
      {{($bits(am_row_offset_bit17)-3){1'b0}},3'b101}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +5+17];
      {{($bits(am_row_offset_bit17)-3){1'b0}},3'b110}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +6+17];
      {{($bits(am_row_offset_bit17)-3){1'b0}},3'b111}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +7+17];
      {{($bits(am_row_offset_bit17)-4){1'b0}},4'b1000}    : am_row[17] = am_cpu_address[`UMCTL2_AM_ROW_BASE +8+17];
      // Maximum supported value of am_row_offset_bit17 depends on MEMC_HIF_ADDR_WIDTH parameter
                // This is the maximum supported number of host interface address bits, which in turn depends on
                // the MEMC_BURST_LENGTH, MEMC_DDR3, MEMC_LPDDR2 and MEMC_RANK_BITS parameters.
                // See DWC_ddr_cc_constants.v for details of MEMC_HIF_ADDR_WIDTH.
                // Since am_row_offset_bit17 has a base of 21, its maximum supported value if MEMC_HIF_ADDR_WIDTH - 21 - 1.
      default : am_row[17] = 1'b0;
  endcase


  // EXTRACT COLUMN
  //
  // max column support is:
  // DDR2   | 10
  // DDR3   | 12
  // DDR4   | 10
  // mDDR   | 11
  // LPDDR2 | 12
  // LPDDR3 | 12

  // each am_column corresponds to following depending on FBW/HBW/QBW
  // col_offset_bit | FBW | HBW | QBW
  //       2        |  2  |  3  |  4
  //       3        |  3  |  4  |  5
  //       4        |  4  |  5  |  6
  //       5        |  5  |  6  |  7
  //       6        |  6  |  7  |  8
  //       7        |  7  |  8  |  9
  //       8        |  8  |  9  | 10
  //       9        |  9  | 10  | 11
  //      10        | 10  | 11  | 12
  //      11        | 11  | 12  | 13
  //
  //
  am_column[2:0] = am_cpu_address[2:0];

//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index '(((0 + 3) + am_column_offset_bit3) - am_column_base_shift)' of width '6' is larger than the width '5' required for the max value '30' of the signal 'am_cpu_address'
//SJ: SpyGlass sees the index as a self-determined expression and considers the carry bit. However, overflow cannot occur here.


  am_column[3] =  (~|am_column_offset_bit3[3+:($bits(am_column_offset_bit3) - 3)]) ?  am_cpu_address[`UMCTL2_AM_COLUMN_BASE+3+am_column_offset_bit3-am_column_base_shift] :
                                                                                     am_cpu_address[`UMCTL2_AM_COLUMN_BASE+3+7-am_column_base_shift]; // =4'd7.  higher values illegal
  //casez(am_column_offset_bit3)        
  //  5'b00??? : am_column[3] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+3+am_column_offset_bit3-am_column_base_shift];
  //   default : am_column[3] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+3+7-am_column_base_shift]; // =4'd7.  higher values illegal
  //endcase

  am_column[4] =  (~|am_column_offset_bit4[3+:($bits(am_column_offset_bit4) - 3)]) ?  am_cpu_address[`UMCTL2_AM_COLUMN_BASE+4+am_column_offset_bit4-am_column_base_shift] :
                                                                                     1'b0; // =4'd7.  higher values illegal
  //casez(am_column_offset_bit4)        
  //  4'b0??? : am_column[4] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+4+am_column_offset_bit4-am_column_base_shift];
  //  default : am_column[4] = 1'b0;
  //endcase

  am_column[5] =  (~|am_column_offset_bit5[3+:($bits(am_column_offset_bit5) - 3)]) ?  am_cpu_address[`UMCTL2_AM_COLUMN_BASE+5+am_column_offset_bit5-am_column_base_shift] :
                                                                                     1'b0; // =4'd7.  higher values illegal
  //casez(am_column_offset_bit5)
  //  4'b0??? : am_column[5] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+5+am_column_offset_bit5-am_column_base_shift];
  //  default : am_column[5] = 1'b0;        
  //endcase

  am_column[6] =  (~|am_column_offset_bit6[3+:($bits(am_column_offset_bit6) - 3)]) ?  am_cpu_address[`UMCTL2_AM_COLUMN_BASE+6+am_column_offset_bit6-am_column_base_shift] :
                                                                                     1'b0; 
  //casez(am_column_offset_bit6)
  //  5'b00??? : am_column[6] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+6+am_column_offset_bit6-am_column_base_shift];
  //  default : am_column[6] = 1'b0;           
  //endcase

  //ccx_cond: ; ; 1; It's not likely to disable column bit 7 as DDR54 and LPDDR54 have at least 10 bit column address width.
  am_column[7] =  (&am_column_offset_bit7) ?  1'b0 :
                                             am_cpu_address[`UMCTL2_AM_COLUMN_BASE+7+am_column_offset_bit7-am_column_base_shift] ;
  //casez(am_column_offset_bit7)
  //  5'b11111 : am_column[7] = 1'b0;
  //  default  : am_column[7] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+7+am_column_offset_bit7-am_column_base_shift];
  //endcase

  //ccx_cond: ; ; 1; It's not likely to disable column bit 8 as DDR54 and LPDDR54 have at least 10 bit column address width.
  am_column[8] =  (&am_column_offset_bit8) ?  1'b0 :
                                             am_cpu_address[`UMCTL2_AM_COLUMN_BASE+8+am_column_offset_bit8-am_column_base_shift] ;

  //casez(am_column_offset_bit8)
  //  5'b11111 : am_column[8] = 1'b0;
  //  default  : am_column[8] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+8+am_column_offset_bit8-am_column_base_shift];
  //endcase


  //ccx_cond: ; ; 1; It's not likely to disable column bit 9 as DDR54 and LPDDR54 have at least 10 bit column address width.
  am_column[9] =  (&am_column_offset_bit9) ?  1'b0 :
                                             am_cpu_address[`UMCTL2_AM_COLUMN_BASE+9+am_column_offset_bit9-am_column_base_shift] ;
  //casez(am_column_offset_bit9)
  //  5'b11111 : am_column[9] = 1'b0;
  //  default  : am_column[9] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+9+am_column_offset_bit9-am_column_base_shift];
  //endcase

  am_column[10] =  (&am_column_offset_bit10) ?  1'b0 :
                                               am_cpu_address[`UMCTL2_AM_COLUMN_BASE+10+am_column_offset_bit10-am_column_base_shift] ;

  //casez(am_column_offset_bit10)
  //  5'b11111 : am_column[10] = 1'b0;
  //  default  : am_column[10] = am_cpu_address[`UMCTL2_AM_COLUMN_BASE+10+am_column_offset_bit10-am_column_base_shift];
  //endcase
    
//spyglass enable_block ImproperRangeIndex-ML
end










//spyglass enable_block SelfDeterminedExpr-ML

endmodule // ih_address_map
