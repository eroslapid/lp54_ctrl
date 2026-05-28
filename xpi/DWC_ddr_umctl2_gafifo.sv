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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_gafifo.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            Generic size Asynchronous FIFO (n words x M bits)
//----------------------------------------------------------------------
/******************************************************************************
 * Generic size Asynchronous FIFO (n words x M bits)                                *
 *****************************************************************************/
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_gafifo (
    wclk,
    wrst_n,
    wr,
    d,
    rclk,
    rrst_n,
    rd,
    par_en,
    ff,
    push_wcount,
    pop_wcount,
    q,
    push_fe,
    pop_fe,
    par_err
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,disable_sva_fifo_checker_rd
    ,disable_sva_fifo_checker_wr
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
);
  parameter WIDTH            =  32;  // RANGE 1 to 16777216
  parameter DEPTH            =  8;   // RANGE 4 to 16777216
  parameter ADDR_WIDTH       =  3;   // RANGE 2 to 24
  parameter COUNT_WIDTH      =  4;   // RANGE 3 to 25
  parameter PUSH_SYNC        =  2;   // RANGE 1 to 4
  parameter POP_SYNC         =  2;   // RANGE 1 to 4
  parameter EARLY_PUSH_STAT  =  0;   // Range 0 to 15
  parameter EARLY_POP_STAT   =  0;   // Range 0 to 15 
  parameter MEM_MODE         =  0;   // RANGE 0 to 3
  parameter VERIF_EN         =  1;   // RANGE 0 to 5 

  parameter OCCAP_EN      =  0;
  parameter OCCAP_PIPELINE_EN =  0;
   
  localparam PUSH_AE_LVL   =  2;   // RANGE 1 to DEPTH-1
  localparam PUSH_AF_LVL   =  2;   // RANGE 1 to DEPTH-1
  localparam POP_AE_LVL    =  2;   // RANGE 1 to DEPTH-1
  localparam POP_AF_LVL    =  2;   // RANGE 1 to DEPTH-1
  localparam ERR_MODE      =  0;   // RANGE 0 to 1

  localparam SL_W         = WIDTH<8 ? WIDTH : 8;
  localparam PARW         = (OCCAP_EN==1) ? ((WIDTH%SL_W>0) ? WIDTH/SL_W+1 : WIDTH/SL_W) : 0;

  localparam WIDTH_INT    = WIDTH+PARW;

  // I/O declarations
  input                       wclk;           // Push domain clk input
  input                       wrst_n;         // Push domain active low async reset
  input                       wr;             // Push domain active low push reqest
  input   [WIDTH-1:0]         d;              // Push domain data input
  input                       rclk;           // Pop domain clk input
  input                       rrst_n;         // Pop domain active low async reset
  input                       rd;             // Pop domain active high pop request

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
  input                       par_en;
//spyglass enable_block W240

  output                      ff;             // Push domain Full status flag
  output  [COUNT_WIDTH-1:0]   push_wcount;    // Push domain word count
  output  [COUNT_WIDTH-1:0]   pop_wcount;     // Pop domain word count   
  output  [WIDTH-1:0]         q;              // Pop domain data input
  output                      push_fe;        // Push domain Empty status flag
  output                      pop_fe;         // Pop domain Empty status flag

  output                      par_err;

  `ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
  input                       disable_sva_fifo_checker_rd;
  input                       disable_sva_fifo_checker_wr;
  `endif // SYNTHESIS
  `endif // SNPS_ASSERT_ON
  
// Internal wires
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used sometimes
  wire                        we_n;
  wire    [ADDR_WIDTH -1:0]   wr_addr;
//spyglass enable_block W528
  wire    [ADDR_WIDTH -1:0]   rd_addr;
  wire                        push_req_n;
  wire                        pop_req_n;
  wire                        push_full;
  wire                        push_empty;
  wire                        pop_empty, pop_empty_neg;
  wire   [WIDTH-1:0]          data_out;
// Unused bcm07 pins 
  wire                        push_ae_unused;
  wire                        push_hf_unused;
  wire                        push_af_unused;
  wire                        push_error_unused;
  wire                        pop_ae_unused;
  wire                        pop_hf_unused;
  wire                        pop_af_unused;
  wire                        pop_full_unused;
  wire                        pop_error_unused;

  wire                        bcm_wrap_mem_array_par_err_unused;

  wire [WIDTH_INT-1:0]        d_in, q_out;
 
`ifdef SNPS_ASSERT_ON
  
  //---------------------------------------------------------------------------
  //  Assertion fifo checker instance
  //---------------------------------------------------------------------------

`ifndef SYNTHESIS
  async_fifo_checker
   U_async_fifo_checker 
  (
  .wrst_n(wrst_n),
  .wclk(wclk),  
  .wr(wr),
  .ff(ff),
  .rrst_n(rrst_n),
  .rclk(rclk),  
  .rd(rd),
  .fe(pop_fe),
  .disable_sva_fifo_checker_rd(disable_sva_fifo_checker_rd),
  .disable_sva_fifo_checker_wr(disable_sva_fifo_checker_wr)
   );
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

  assign                   push_req_n = ~wr;
  assign                   pop_req_n  = ~rd;
  assign                   ff         = push_full;
  assign                   push_fe    = push_empty;
  assign                   pop_fe     = pop_empty;

      generate
        if (OCCAP_EN==1) begin: BCM66_ATV
          DWC_ddrctl_bcm66_wae_atv
           #(
            .WIDTH           (WIDTH_INT),
            .DEPTH           (DEPTH), 
            .ADDR_WIDTH      (ADDR_WIDTH), 
            .COUNT_WIDTH     (COUNT_WIDTH), 
            .PUSH_AE_LVL     (PUSH_AE_LVL),
            .PUSH_AF_LVL     (PUSH_AF_LVL), 
            .POP_AE_LVL      (POP_AE_LVL), 
            .POP_AF_LVL      (POP_AF_LVL), 
            .ERR_MODE        (ERR_MODE),
            .PUSH_SYNC       (PUSH_SYNC), 
            .POP_SYNC        (POP_SYNC),
            .MEM_MODE        (MEM_MODE),
            .VERIF_EN        (VERIF_EN),
            .TMR_CDC         (OCCAP_EN)
          ) 
          U_bcm66_wae_atv (
            .clk_push           (wclk),
            .rst_push_n         (wrst_n),
            .init_push_n        (1'b1),
            .push_req_n         (push_req_n),
            .data_in            (d_in),
            .clk_pop            (rclk),
            .rst_pop_n          (rrst_n),
            .init_pop_n         (1'b1),
            .pop_req_n          (pop_req_n),
            .data_out           (q_out),
             
            .push_empty         (push_empty),
            .push_ae            (push_ae_unused),
            .push_hf            (push_hf_unused),
            .push_af            (push_af_unused),
            .push_full          (push_full),
            .push_error         (push_error_unused),
            .push_word_count    (push_wcount),
     //spyglass disable_block W528
     //SMD: A signal or variable is set but never read
     //SJ: Keeping as it was, needed in other instances
            .we_n               (we_n),
            .wr_addr            (wr_addr),
     //spyglass enable_block W528

            .pop_empty          (pop_empty),
            .pop_ae             (pop_ae_unused),
            .pop_hf             (pop_hf_unused), 
            .pop_af             (pop_af_unused),
            .pop_full           (pop_full_unused),
            .pop_error          (pop_error_unused),
            .pop_word_count     (pop_wcount)
          );

       end else begin: BCM66
         
         DWC_ddrctl_bcm66_wae
          #(
            .WIDTH           (WIDTH_INT),
            .DEPTH           (DEPTH), 
            .ADDR_WIDTH      (ADDR_WIDTH), 
            .COUNT_WIDTH     (COUNT_WIDTH), 
            .PUSH_AE_LVL     (PUSH_AE_LVL),
            .PUSH_AF_LVL     (PUSH_AF_LVL), 
            .POP_AE_LVL      (POP_AE_LVL), 
            .POP_AF_LVL      (POP_AF_LVL), 
            .ERR_MODE        (ERR_MODE),
            .PUSH_SYNC       (PUSH_SYNC), 
            .POP_SYNC        (POP_SYNC),
            .MEM_MODE        (MEM_MODE),
            .VERIF_EN        (VERIF_EN)
          ) 
          U_bcm66_wae (
            .clk_push           (wclk),
            .rst_push_n         (wrst_n),
            .init_push_n        (1'b1),
            .push_req_n         (push_req_n),
            .data_in            (d_in),
            .clk_pop            (rclk),
            .rst_pop_n          (rrst_n),
            .init_pop_n         (1'b1),
            .pop_req_n          (pop_req_n),
            .data_out           (q_out),
         
            .push_empty         (push_empty),
            .push_ae            (push_ae_unused),
            .push_hf            (push_hf_unused),
            .push_af            (push_af_unused),
            .push_full          (push_full),
            .push_error         (push_error_unused),
            .push_word_count    (push_wcount),
     //spyglass disable_block W528
     //SMD: A signal or variable is set but never read
     //SJ: Keeping as it was, needed in other instances
            .we_n               (we_n),
            .wr_addr            (wr_addr),
     //spyglass enable_block W528
            .pop_empty          (pop_empty),
            .pop_ae             (pop_ae_unused),
            .pop_hf             (pop_hf_unused), 
            .pop_af             (pop_af_unused),
            .pop_full           (pop_full_unused),
            .pop_error          (pop_error_unused),
            .pop_word_count     (pop_wcount)
          );

        end
      endgenerate

   generate
    if (OCCAP_EN==1) begin: PAR_check

      wire [PARW-1:0] parity_dummy, mask_in, par_out;

      wire [PARW-1:0] d_par, q_par, parity_err;
      wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;

      wire pgen_en, pcheck_en;

      assign parity_dummy  = {PARW{1'b1}};
      assign mask_in       = {PARW{1'b1}};

      wire poison_en       = 1'b0;

      assign pgen_en    = wr;
      assign pcheck_en  = par_en & rd & pop_empty_neg;


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (WIDTH),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (d),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (d_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) //not used
         );

         DWC_ddr_umctl2_xpi_and
          #(
            .WIDTH   (PARW)
         )
         U_AND_2TO1_SIN
         (
            .in0  (q_par),
            .in1  (pop_empty_neg),
            .out0 (par_out)
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (WIDTH),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (q),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (par_out), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );

      assign d_in = {d,d_par};
      assign {data_out,q_par} = q_out;

         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg par_err_r;
           always @ (posedge rclk or negedge rrst_n) begin : par_err_r_PROC
             if (~rrst_n) begin
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
      assign d_in    = d;
      assign data_out= q_out;

    end // OCCAP_dis
   endgenerate

   assign pop_empty_neg = ~pop_empty;

   DWC_ddr_umctl2_xpi_and
    #(
      .WIDTH   (WIDTH)
   )
   U_AND_2TO1_SIN
   (
      .in0  (data_out),
      .in1  (pop_empty_neg),
      .out0 (q)
   );


endmodule //DWC_ddr_umctl2_gafifo
