
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
// Description : DWC_ddrctl_bcm50.v Verilog module for DWC_ddrctl
//
// DesignWare IP ID: f13fe868
//
////////////////////////////////////////////////////////////////////////////////






module DWC_ddrctl_bcm50 (
  clk,            // Read clock input
  rst_n,          // read domain active low asynch. reset
  init_n,         // read domain active low synch. reset
  rd_n,           // acive low read enable
  rd_addr,        // Read address input
  mem_in,         // Memory array input
  data_avail,     // Read data arrival status output
  rd_data         // Read data output
);

parameter  integer WIDTH = 8;      // RANGE 1 to 2048
parameter  integer DEPTH = 4;      // RANGE 2 to 2048
parameter  integer ADDR_WIDTH = 2; // RANGE 1 to 10
parameter  integer MEM_MODE = 1;   // RANGE 0 to 7

localparam WIDTH_TIMES_DEPTH = WIDTH * DEPTH;

// spyglass disable_block W240
// SMD: An input port is never read in the module
// SJ: The following port(s) are not used in certain configurations.
input                       clk;
input                       rst_n;
input                       init_n;
// spyglass enable_block W240
input                       rd_n;
input  [ADDR_WIDTH-1 : 0]   rd_addr;
input  [WIDTH*DEPTH-1 : 0]  mem_in;
output                      data_avail;
output [WIDTH-1 : 0]        rd_data;

wire [ADDR_WIDTH-1 : 0]     rd_addr_array;
wire [WIDTH-1 : 0]          rd_data_array;
  

DWC_ddrctl_bcm02
 #(WIDTH_TIMES_DEPTH, ADDR_WIDTH, WIDTH) U1 (
  .a   (mem_in       ),
  .sel (rd_addr_array),
  .mux (rd_data_array)
);

// spyglass disable_block STARC-2.3.4.3
// SMD: A flip-flop should have an asynchronous set or an asynchronous reset
// SJ: This module can be specifically configured/implemented with only a synchronous reset or no resets at all.

generate
  if ( (MEM_MODE&3) == 0 ) begin : GEN_MM_0 // no retiming regs
    assign rd_addr_array = rd_addr;
    assign rd_data = rd_data_array;
    assign data_avail = ~rd_n;
  end

  if ( (MEM_MODE&3) == 1) begin : GEN_MM_1 // data out retiming reg
    reg rd_n_retimed;
    reg [WIDTH-1:0] rd_data_retimed;
    wire mem_rd;

    always @ (posedge clk or negedge rst_n) begin : rd_n_q_PROC
      if (rst_n == 1'b0)
        rd_n_retimed <= 1'b0;
      else if (init_n == 1'b0)
        rd_n_retimed <= 1'b0;
      else
        rd_n_retimed <= ~rd_n;
    end

    always @ (posedge clk or negedge rst_n) begin : rd_data_q_PROC
      if (rst_n == 1'b0) begin
        rd_data_retimed <= {WIDTH{1'b0}};
      end else if (init_n == 1'b0) begin
        rd_data_retimed <= {WIDTH{1'b0}};
      end else begin
        if (mem_rd == 1'b1)
          rd_data_retimed <= rd_data_array;
      end
    end

    assign rd_addr_array = rd_addr;
    assign mem_rd = ~rd_n;
    assign rd_data = rd_data_retimed;
    assign data_avail = rd_n_retimed;
  end

  if ( (MEM_MODE&3) == 2) begin : GEN_MM_2 // addr in retiming reg
    reg [ADDR_WIDTH-1:0] rd_addr_retimed;
    reg rd_n_retimed;

    always @ (posedge clk or negedge rst_n) begin : rd_addr_q_PROC
      if (rst_n == 1'b0)
        rd_addr_retimed <= {ADDR_WIDTH{1'b0}};
      else if (init_n == 1'b0)
        rd_addr_retimed <= {ADDR_WIDTH{1'b0}};
      else if (rd_n == 1'b0)
        rd_addr_retimed <= rd_addr;
    end

    always @ (posedge clk or negedge rst_n) begin : rd_n_q_PROC
      if (rst_n == 1'b0)
        rd_n_retimed <= 1'b0;
      else if (init_n == 1'b0)
        rd_n_retimed <= 1'b0;
      else
        rd_n_retimed <= ~rd_n;
    end

    assign rd_addr_array = rd_addr_retimed;
    assign rd_data = rd_data_array;
    assign data_avail = rd_n_retimed;
  end

  if ( (MEM_MODE&3) == 3) begin : GEN_MM_3 // both retiming regs
    reg [ADDR_WIDTH-1:0] rd_addr_retimed;
    reg rd_n_retimed;
    reg rd_n_retimed2;
    reg [WIDTH-1:0] rd_data_retimed;
    wire mem_rd;

    always @ (posedge clk or negedge rst_n) begin : rd_addr_q_PROC
      if (rst_n == 1'b0)
        rd_addr_retimed <= {ADDR_WIDTH{1'b0}};
      else if (init_n == 1'b0)
        rd_addr_retimed <= {ADDR_WIDTH{1'b0}};
      else if (rd_n == 1'b0)
        rd_addr_retimed <= rd_addr;
    end

    always @ (posedge clk or negedge rst_n) begin : rd_n_q_PROC
      if (rst_n == 1'b0) begin
        rd_n_retimed <= 1'b0;
        rd_n_retimed2  <= 1'b0;
      end else if (init_n == 1'b0) begin
        rd_n_retimed <= 1'b0;
        rd_n_retimed2  <= 1'b0;
      end else begin
        rd_n_retimed <= ~rd_n;
        rd_n_retimed2 <= rd_n_retimed;
      end
    end

    always @ (posedge clk or negedge rst_n) begin : rd_data_q_PROC
      if (rst_n == 1'b0) begin
        rd_data_retimed <= {WIDTH{1'b0}};
      end else if (init_n == 1'b0) begin
        rd_data_retimed <= {WIDTH{1'b0}};
      end else begin
        if (mem_rd == 1'b1)
          rd_data_retimed <= rd_data_array;
      end
    end

    assign rd_addr_array = rd_addr_retimed;
    assign mem_rd = rd_n_retimed;
    assign rd_data = rd_data_retimed;
    assign data_avail = rd_n_retimed2;
  end

endgenerate
// spyglass enable_block STARC-2.3.4.3

endmodule
