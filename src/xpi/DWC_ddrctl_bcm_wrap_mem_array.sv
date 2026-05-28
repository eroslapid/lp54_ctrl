
// Filename    : DWC_ddrctl_bcm_wrap_mem_array.v
// Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddrctl_bcm_wrap_mem_array.sv#1 $
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

/******************************************************************************************************************************************
 *                                                                                                                                        *
 * DESCRIPTION: Dual port DFF based RAM with parameter driven retiming register insertion - reconstruction from BCM50 and BCM56 blocks    *
 *                                                                                                                                        *
 ******************************************************************************************************************************************/

// ABSTRACT:  Dual port (1 write port, 1 read port) DFF based RAM
//            with parameter driven retiming register insertion
//            - reconstruction from BCM50 and BCM56 blocks
//
//              Parameters:     Valid Values
//              ==========      ============
//     DATA_WIDTH  [ 1 to 256 ]
//     DEPTH       [ 2 to 256 ]
//     MEM_MODE    [ 0 to 3 ] (0 = no pre or post retiming
//                             1 = data_out (post) retiming
//                             2 = data_in, wr_addr, rd_addr,
//                                                wr_n (pre) retiming
//                                          3 = both pre and post retiming)
//     ADDR_WIDTH  [ 1 to 8 ]
//              
//              Input Ports     Size    Description
//              ============    ====    ===========
//          clk             1 bit   Positive-edge Clock
//          rst_n           1 bit  Active Low asynchronous Reset
//          init_n          1 bit  Active Low synchronous Reset
//          wr_n            1 bit  Active Low Write Control
//          data_in         W bits  Input Data (for writes)
//              wr_addr         N bits  Write Address
//              rd_addr         N bits  Read Address
//
//              Output Port     Size    Description
//              ============    ====    ===========
//          data_out  W bits  Output Data (from reads)
//
//                Note: N is defined as ADDR_WIDTH - a parameter which should
//                      be set (by the parent design) to ceil( log2( DEPTH ) )
//
//                      W is defined as the DATA_WIDTH parameter
//

// spyglass disable_block W156
// SMD: Bus net '<name>' connected in reverse.
// SJ: Opened CASE 8000863703 and Atrenta ticket #114623; recognized as bug in Spyglass tool and assigned to Atrenta R&D

module DWC_ddrctl_bcm_wrap_mem_array (
  clk,
  rst_n,
  init_n,
  wr_n,
  data_in,
  wr_addr,
  rd_addr,
  par_en,
  data_out,
  par_err
  );

   parameter DATA_WIDTH = 4;  // RANGE 1 to 256
   parameter DEPTH = 8;       // RANGE 2 to 256
   parameter MEM_MODE = 0;    // RANGE 0 to 3
   parameter ADDR_WIDTH = 3;  // RANGE 1 to 8

   parameter OCCAP_EN = 0;
   parameter OCCAP_PIPELINE_EN = 0;

   localparam SL_W         = DATA_WIDTH<8 ? DATA_WIDTH : 8;
   localparam PARW         = (OCCAP_EN==1) ? ((DATA_WIDTH%SL_W>0) ? DATA_WIDTH/SL_W+1 : DATA_WIDTH/SL_W) : 0;

   localparam integer DATA_WIDTH_INT = DATA_WIDTH+PARW;

   input      clk;      // clock input
   input      rst_n;    // active low async. reset
   input      init_n;   // active low sync. reset
   input      wr_n;     // active low RAM write enable
   input [DATA_WIDTH-1:0] data_in;  // RAM write data input bus
   input [ADDR_WIDTH-1:0] wr_addr;  // RAM write address bus
   input [ADDR_WIDTH-1:0] rd_addr;  // RAM read address bus

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input    par_en;
//spyglass enable_block W240

   output [DATA_WIDTH-1:0]  data_out; // RAM read data output bus

   output par_err;

   wire [DATA_WIDTH_INT-1:0] data_in_int, data_out_int;

   wire [DATA_WIDTH_INT*DEPTH-1:0]  mem;

  DWC_ddrctl_bcm56
   #(
    DATA_WIDTH_INT, DEPTH, ADDR_WIDTH, MEM_MODE) U1 (
    .clk           (clk),            // Read clock input
    .rst_n         (rst_n),          // read domain active low asynch. reset
    .init_n        (init_n),         // read domain active low synch. reset
    .wr_n          (wr_n),           // active low write enable
    .wr_addr       (wr_addr),        // Write address input
    .wr_data       (data_in_int),        // Write data input
    .mem_out       (mem)             // Memory array output
    );

  wire     data_avail_unused;
  wire     rd_n;
  assign   rd_n = 1'b0;

  DWC_ddrctl_bcm50
   #(
    DATA_WIDTH_INT, DEPTH, ADDR_WIDTH, MEM_MODE) U2 (
    .clk           (clk),            // Read clock input
    .rst_n         (rst_n),          // read domain active low asynch. reset
    .init_n        (init_n),         // read domain active low synch. reset
    .rd_n          (rd_n),           // active low read enable
    .rd_addr       (rd_addr),        // Read address input
    .mem_in        (mem),            // Memory array input
    .data_avail    (data_avail_unused),     // Read data arrival status output
    .rd_data       (data_out_int)        // Read data output
    );

   generate
   if (OCCAP_EN==1) begin: PAR_check

      wire [PARW-1:0] parity_dummy, mask_in;

      wire [PARW-1:0] par_in, par_out, parity_err;
      wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;
      
      wire pgen_en, pcheck_en;

      wire poison_en = 1'b0;

      assign parity_dummy  = {PARW{1'b1}};
      assign mask_in       = {PARW{1'b1}};

      assign pgen_en    = ~wr_n;
      assign pcheck_en  = par_en & ~rd_n;


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (DATA_WIDTH),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (data_in),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (par_in), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (DATA_WIDTH),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (data_out),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (par_out), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );

      assign data_in_int = {data_in,par_in};
      assign {data_out,par_out} = data_out_int;

         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg par_err_r;
           always @ (posedge clk or negedge rst_n) begin : par_err_r_PROC
             if (~rst_n) begin
               par_err_r <= 1'b0;
             end else begin
               par_err_r <= |parity_err;
             end
           end

           assign par_err = par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign par_err = |parity_err;

         end

    end // PAR_check
    else begin: OCCAP_dis
   
      assign par_err = 1'b0;
      assign data_in_int   = data_in;
      assign data_out      = data_out_int;

    end // OCCAP_dis
    endgenerate

endmodule
// spyglass enable_block W156
