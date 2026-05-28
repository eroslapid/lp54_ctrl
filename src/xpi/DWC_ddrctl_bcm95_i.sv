
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

//
// Description : DWC_ddrctl_bcm95_i.v Verilog module for DWC_ddrctl
//
// DesignWare IP ID: 08a97f61
//
////////////////////////////////////////////////////////////////////////////////

module DWC_ddrctl_bcm95_i (
  clk,
  rst_n,
  init_n,
  d_in,
  d_out
);

parameter integer TMR = 0;
parameter integer WIDTH = 1;
parameter integer RSTVAL = 0;
parameter integer INITVAL = -1;

localparam WIDTH_DOUT = (TMR == 2) ? WIDTH*3 : WIDTH;

input                   clk;
input                   rst_n;
input                   init_n;
input  [WIDTH-1:0]      d_in;
output [WIDTH_DOUT-1:0] d_out;

localparam [WIDTH-1:0] RESET_VALUE = (RSTVAL==0)?  {WIDTH{1'b0}} :
                                     (RSTVAL==-1)? {WIDTH{1'b1}} : 
                                      RSTVAL;

localparam [WIDTH-1:0] INIT_VALUE = (INITVAL==0)?  {WIDTH{1'b0}} :
                                    (INITVAL==-1)? RESET_VALUE :
                                     INITVAL;

generate

  if (TMR == 0) begin : GEN_TMR_EQ_0
    reg [WIDTH-1:0] ff_q;

    always @ (posedge clk or negedge rst_n) begin : NON_TMR_PROC
      if (rst_n == 1'b0) begin
        ff_q <= RESET_VALUE;
      end else if (init_n == 1'b0) begin
        ff_q <= INIT_VALUE;
      end else begin
// spyglass disable_block Reset_sync04 
// SMD: Asynchronous resets that are synchronized more than once in the same clock domain
// SJ: Spyglass recognizes every multi-flop synchronizer as a reset synchronizer, hence any design with a reset that feeds more than one synchronizer gets reported as violating this rule. This rule is waivered temporarily.
        ff_q <= d_in;
// spyglass enable_block Reset_sync04
      end
    end

    assign d_out = ff_q;

  end else begin : GEN_TMR_NE_0

    reg [WIDTH-1:0] dw_so_reg1;
    reg [WIDTH-1:0] dw_so_reg2;
    reg [WIDTH-1:0] dw_so_reg3;

    always @ (posedge clk or negedge rst_n) begin : TMR_PROC
      if (rst_n == 1'b0) begin
        dw_so_reg1 <= RESET_VALUE;
        dw_so_reg2 <= RESET_VALUE;
        dw_so_reg3 <= RESET_VALUE;
      end else if (init_n == 1'b0) begin
        dw_so_reg1 <= INIT_VALUE;
        dw_so_reg2 <= INIT_VALUE;
        dw_so_reg3 <= INIT_VALUE;
      end else begin
        dw_so_reg1 <= d_in;
        dw_so_reg2 <= d_in;
        dw_so_reg3 <= d_in;
      end
    end

    if (TMR == 1) begin : GEN_TMR_EQ_1
      DWC_ddrctl_bcm00_maj
       #(WIDTH) U_MAJ_VT (
                                       .a(dw_so_reg1),
                                       .b(dw_so_reg2),
                                       .c(dw_so_reg3),
                                       .z(d_out) );
    end else begin : GEN_TMR_EQ_2
      assign d_out = {dw_so_reg3, dw_so_reg2, dw_so_reg1};
    end

  end

endgenerate

endmodule
