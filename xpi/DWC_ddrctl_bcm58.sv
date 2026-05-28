
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
// Description : DWC_ddrctl_bcm58.v Verilog module for DWC_ddrctl
//
// DesignWare IP ID: b765317c
//
////////////////////////////////////////////////////////////////////////////////





 
module DWC_ddrctl_bcm58 (
        clk_w,          // Write clock input
        rst_w_n,        // write domain active low asynch. reset
        en_w_n,         // acive low write enable
        addr_w,         // Write address input
        data_w,         // Write data input

        clk_r,          // Read clock input
        rst_r_n,        // read domain active low asynch. reset
        en_r_n,         // acive low read enable
        addr_r,         // Read address input
        data_r_a,       // Read data arrival status output
        data_r          // Read data output
);
 
parameter integer WIDTH = 8;    // RANGE 1 to 2048
parameter integer DEPTH = 4;    // RANGE 2 to 1024
parameter integer ADDR_WIDTH = 2; // RANGE 1 to 10
parameter integer MEM_MODE = 1; // RANGE 0 to 7
parameter integer RST_MODE = 0; // RANGE 0 to 1
 
localparam [0:0] DPTH_PWR2 = ( DEPTH == (1 << ADDR_WIDTH) );
localparam ARRAY_WIDTH      = WIDTH * DEPTH;
localparam ARRAY_WIDTH_4_RD = (DPTH_PWR2 == 1'b1) ? ARRAY_WIDTH
                            :                       WIDTH * (1 << ADDR_WIDTH)
                            ;
 
 input                          clk_w;
// spyglass disable_block W240
// SMD: An input port is never read in the module
// SJ: The following port(s) are not used in certain configurations.
 input                          rst_w_n;
// spyglass enable_block W240
 input                          en_w_n;
 input [ADDR_WIDTH-1 : 0]       addr_w;
 input [WIDTH-1 : 0]            data_w;

// spyglass disable_block W240
// SMD: An input port is never read in the module
// SJ: The following port(s) are not used in certain configurations.
 input                          clk_r;
 input                          rst_r_n;
// spyglass enable_block W240
 input                          en_r_n;
 input [ADDR_WIDTH-1 : 0]       addr_r;
output                          data_r_a;
output [WIDTH-1 : 0]            data_r;
 
 
 
 reg [ARRAY_WIDTH-1:0]  mem_array;
wire [ARRAY_WIDTH_4_RD-1 : 0] mem_array_4_rd;
wire [ADDR_WIDTH-1 : 0] addr_w_array;
wire                    en_w_array;
wire [WIDTH-1 : 0]      data_w_array;
wire [ADDR_WIDTH-1 : 0] addr_r_array;
wire [WIDTH-1 : 0]      rd_data_array;
 
 

generate
  if (RST_MODE == 0) begin : GEN_RM0W
    always @ (posedge clk_w or negedge rst_w_n) begin : clk_regs_PROC
      integer i,j;
      if (rst_w_n == 1'b0) begin
        mem_array <= {ARRAY_WIDTH{1'b0}};
      end else begin
        if (en_w_array == 1'b1) begin
          for (i=0 ; i<DEPTH ; i=i+1) begin
            if ($unsigned(i) == addr_w_array) begin
              for (j=0 ; j<WIDTH ; j=j+1) begin
  // spyglass disable_block STARC-2.3.4.3
// SMD: A flip-flop should have an asynchronous set or an asynchronous reset
// SJ: This module can be specifically configured/implemented with only a synchronous reset or no resets at all.
                mem_array[i*WIDTH+j] <= data_w_array[j];
  // spyglass enable_block STARC-2.3.4.3
              end
            end
          end
        end
      end
    end
  end else begin : GEN_RM1W
    always @ (posedge clk_w) begin : clk_regs_PROC
      integer i,j;
      if (en_w_array == 1'b1) begin
        for (i=0 ; i<DEPTH ; i=i+1) begin
          if ($unsigned(i) == addr_w_array) begin
            for (j=0 ; j<WIDTH ; j=j+1) begin
  // spyglass disable_block STARC-2.3.4.3
// SMD: A flip-flop should have an asynchronous set or an asynchronous reset
// SJ: This module can be specifically configured/implemented with only a synchronous reset or no resets at all.
              mem_array[i*WIDTH+j] <= data_w_array[j];
  // spyglass enable_block STARC-2.3.4.3
            end
          end
        end
      end
    end
  end
endgenerate


generate
  if ((MEM_MODE & 4) == 4) begin : GEN_MMBT2_1
    reg [ADDR_WIDTH-1 : 0] addr_w_retimed;
    reg [WIDTH-1 : 0] data_w_retimed;
    reg en_w_retimed;

    always @ (posedge clk_w or negedge rst_w_n) begin : mmbt2_1_PROC
      if (rst_w_n == 1'b0) begin
        addr_w_retimed <= {ADDR_WIDTH{1'b0}};
        data_w_retimed <= {WIDTH{1'b0}};
        en_w_retimed <= 1'b0;
      end else begin
        if (en_w_n == 1'b0) begin
          addr_w_retimed <= addr_w;
          data_w_retimed <= data_w;
        end
        en_w_retimed <= ~en_w_n;
      end
    end

    assign addr_w_array = addr_w_retimed;
    assign en_w_array = en_w_retimed;
    assign data_w_array = data_w_retimed;
  end else begin : GEN_MMBT2_0
    assign addr_w_array = addr_w;
    assign en_w_array = ~en_w_n;
    assign data_w_array = data_w;
  end
endgenerate

 

  generate
    if (DPTH_PWR2 == 1'b0) begin : GEN_NONPWR2_DPTH
      assign mem_array_4_rd = {{WIDTH*((1<<ADDR_WIDTH)-DEPTH){1'b0}},mem_array};
    end else begin : GEN_PWR2_DPTH
      assign mem_array_4_rd = mem_array;
    end
  endgenerate
 
  DWC_ddrctl_bcm02
   #(ARRAY_WIDTH_4_RD, ADDR_WIDTH, WIDTH) U_MUX (
    .a   (mem_array_4_rd),
    .sel (addr_r_array       ),
    .mux (rd_data_array       )
  );
 
 
 

generate
  if ( (MEM_MODE&3) == 0 ) begin : GEN_MM_0 // no retiming regs
    assign addr_r_array = addr_r;
    assign data_r = rd_data_array;
    assign data_r_a = ~en_r_n;
  end

  if ( (MEM_MODE&3) == 1) begin : GEN_MM_1 // data out retiming reg
    reg en_r_n_retimed;
    reg [WIDTH-1:0] rd_data_retimed;
    wire en_r_array;

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_n_q_PROC
      if (rst_r_n == 1'b0)
        en_r_n_retimed <= 1'b0;
      else
        en_r_n_retimed <= ~en_r_n;
    end

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_data_q_PROC
      if (rst_r_n == 1'b0) begin
        rd_data_retimed <= {WIDTH{1'b0}};
      end else begin
        if (en_r_array == 1'b1)
          rd_data_retimed <= rd_data_array;
      end
    end

    assign addr_r_array = addr_r;
    assign en_r_array = ~en_r_n;
    assign data_r = rd_data_retimed;
    assign data_r_a = en_r_n_retimed;
  end

  if ( (MEM_MODE&3) == 2) begin : GEN_MM_2 // addr in retiming reg
    reg [ADDR_WIDTH-1:0] addr_r_retimed;
    reg en_r_n_retimed;

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_addr_q_PROC
      if (rst_r_n == 1'b0)
        addr_r_retimed <= {ADDR_WIDTH{1'b0}};
      else if (en_r_n == 1'b0)
        addr_r_retimed <= addr_r;
    end

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_n_q_PROC
      if (rst_r_n == 1'b0)
        en_r_n_retimed <= 1'b0;
      else
        en_r_n_retimed <= ~en_r_n;
    end

    assign addr_r_array = addr_r_retimed;
    assign data_r = rd_data_array;
    assign data_r_a = en_r_n_retimed;
  end

  if ( (MEM_MODE&3) == 3) begin : GEN_MM_3 // both retiming regs
    reg [ADDR_WIDTH-1:0] addr_r_retimed;
    reg en_r_n_retimed;
    reg en_r_n_retimed2;
    reg [WIDTH-1:0] rd_data_retimed;
    wire en_r_array;

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_addr_q_PROC
      if (rst_r_n == 1'b0)
        addr_r_retimed <= {ADDR_WIDTH{1'b0}};
      else if (en_r_n == 1'b0)
        addr_r_retimed <= addr_r;
    end

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_n_q_PROC
      if (rst_r_n == 1'b0) begin
        en_r_n_retimed <= 1'b0;
        en_r_n_retimed2  <= 1'b0;
      end else begin
        en_r_n_retimed <= ~en_r_n;
        en_r_n_retimed2 <= en_r_n_retimed;
      end
    end

    always @ (posedge clk_r or negedge rst_r_n) begin : rd_data_q_PROC
      if (rst_r_n == 1'b0) begin
        rd_data_retimed <= {WIDTH{1'b0}};
      end else begin
        if (en_r_array == 1'b1)
          rd_data_retimed <= rd_data_array;
      end
    end

    assign addr_r_array = addr_r_retimed;
    assign en_r_array = en_r_n_retimed;
    assign data_r = rd_data_retimed;
    assign data_r_a = en_r_n_retimed2;
  end

endgenerate


endmodule
