
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
// Description : DWC_ddrctl_bcm36_nhs.v Verilog module for DWC_ddrctl
//
// DesignWare IP ID: 35d96926
//
////////////////////////////////////////////////////////////////////////////////



module DWC_ddrctl_bcm36_nhs (
`ifndef SYNTHESIS
    clk_d,
    rst_d_n,
`endif
    data_s,
    data_d
    );

parameter integer WIDTH        = 1;  // RANGE 1 to 1024
// spyglass disable_block W175
// SMD: A parameter is declared but not used
// SJ: The following parameter(s) are not used in certain GCCM or GSCM configurations.
parameter integer DATA_DELAY   = 0;  // RANGE 0 to 3
// spyglass enable_block W175
// spyglass disable_block W175
// SMD: A parameter is declared but not used
// SJ: The following parameter(s) are not used in certain GCCM or GSCM configurations.
parameter integer SVA_TYPE     = 1;
// spyglass enable_block W175

`ifndef SYNTHESIS
`ifdef DW_MODEL_MISSAMPLES
localparam VERIF_EN_LCL = ((DATA_DELAY == 0) ? 0 : (DATA_DELAY == 1) ? 4 : (DATA_DELAY == 2) ? 1 : 2);
`endif
`endif

`ifdef DW_MODEL_MISSAMPLES
`ifndef SYNTHESIS
`ifdef DWC_BCM_MSG_VERBOSITY
  localparam BCM_MSG_VERBOSITY = `DWC_BCM_MSG_VERBOSITY;
`else
  localparam BCM_MSG_VERBOSITY_DEF = 32'hfffffff1;


  localparam BCM_MSG_VERBOSITY = BCM_MSG_VERBOSITY_DEF;
`endif
`endif
`endif


`ifndef SYNTHESIS
input                   clk_d;      // clock input from destination domain
input                   rst_d_n;    // active low asynchronous reset from destination domain
`endif
input  [WIDTH-1:0]      data_s;     // data to be synchronized from source domain
output [WIDTH-1:0]      data_d;     // data synchronized to destination domain


wire   [WIDTH-1:0]      data_s_int;
wire   [WIDTH-1:0]      data_d_int;

`ifndef SYNTHESIS
    `ifdef DW_MODEL_MISSAMPLES
wire                    clk_d_stopped;
wire   [63:0]           clk_d_period;
    `endif
`endif



`ifdef SYNTHESIS
  assign data_s_int = data_s;
`else
  `ifdef DW_MODEL_MISSAMPLES
  initial begin
  if (BCM_MSG_VERBOSITY[0] == 1'b1)
    $display("Information: %m: *** Running with DW_MODEL_MISSAMPLES defined, VERIF_EN_LCL is: %0d ***",
                        VERIF_EN_LCL);
  end

reg  [WIDTH-1:0]        last_data_dyn, data_s_delta_t;
reg  [WIDTH-1:0]        last_data_s, last_data_s_q, last_data_s_qq;
reg  [WIDTH-1:0]        data_select; initial data_select = 0;
wire [WIDTH-1:0]        data_s_sel_tmp;




  generate if ((VERIF_EN_LCL % 2) == 1) begin : GEN_HO_VE_ODD
      always @ (posedge clk_d or data_s or rst_d_n) begin : PROC_catch_last_data_VE_EVEN
        data_s_delta_t <= data_s & {WIDTH{rst_d_n}};
        last_data_dyn <= ((clk_d_stopped==1'b1) ? data_s : data_s_delta_t) & {WIDTH{rst_d_n}};
      end // PROC_catch_last_data

      always @ (posedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_odd_VE_EVEN
        if (rst_d_n == 1'b0) begin
          last_data_s <= {WIDTH{1'b0}};
          last_data_s_qq  <= {WIDTH{1'b0}};
        end else begin
          last_data_s <= data_s;
          if (clk_d_stopped == 1'b1)
            last_data_s_qq <= data_s;
          else
            last_data_s_qq <= last_data_s_q;
        end
      end
  end else begin : GEN_HO_VE_EVEN
      always @ (negedge clk_d or data_s or rst_d_n) begin : PROC_catch_last_data_VE_ODD
        data_s_delta_t <= data_s & {WIDTH{rst_d_n}};
        last_data_dyn <= ((clk_d_stopped==1'b1) ? data_s : data_s_delta_t) & {WIDTH{rst_d_n}};
      end // PROC_catch_last_data

      always @ (negedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_odd_VE_ODD
        if (rst_d_n == 1'b0) begin
          last_data_s <= {WIDTH{1'b0}};
          last_data_s_qq  <= {WIDTH{1'b0}};
        end else begin
          last_data_s <= data_s;
          if (clk_d_stopped == 1'b1)
            last_data_s_qq <= data_s;
          else
            last_data_s_qq <= last_data_s_q;
        end
      end
  end endgenerate

    always @ (posedge clk_d or negedge rst_d_n) begin : PROC_missample_hist_even
      if (rst_d_n == 1'b0) begin
        last_data_s_q  <= {WIDTH{1'b0}};
      end else begin
        if (clk_d_stopped == 1'b1)
          last_data_s_q <= data_s;
        else
          last_data_s_q <= last_data_s;
      end
    end // PROC_missample_hist_even


  generate if (VERIF_EN_LCL == 0) begin : GEN_DSI_VE_EQ_0

    assign data_s_int = data_s;

  end else if ((VERIF_EN_LCL == 2) || (VERIF_EN_LCL == 3)) begin : GEN_DSI_VE_EQ_2_OR_3

    reg  [WIDTH-1:0] data_select_2; initial data_select_2 = 0;
    wire [WIDTH-1:0] data_s_sel_0, data_s_sel_1;
    if (WIDTH <= 32) begin : GEN_D_SEL_W_LTE_32
      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s) begin
  `ifdef DWC_BCM_SV
          data_select = $urandom;
          data_select_2 = $urandom;
  `else
          data_select = $random;
          data_select_2 = $random;
  `endif
        end
      end  // PROC_mk_next_data_select
    end else begin : GEN_D_SEL_W_GT_32
  function automatic [WIDTH-1:0] wide_random;
    input [31:0]        in_width;   // should match "WIDTH" parameter -- need one input to satisfy Verilog function requirement

    reg   [WIDTH-1:0]   temp_result;
    reg   [31:0]        rand_slice;
    integer             i, j, base;


    begin
`ifdef DWC_BCM_SV
      temp_result = $urandom;
`else
      temp_result = $random;
`endif
      if (((WIDTH / 32) + 1) > 1) begin
        for (i=1 ; i < ((WIDTH / 32) + 1) ; i=i+1) begin
          base = i << 5;
`ifdef DWC_BCM_SV
          rand_slice = $urandom;
`else
          rand_slice = $random;
`endif
          for (j=0 ; ((j < 32) && (base+j < in_width)) ; j=j+1) begin
            temp_result[base+j] = rand_slice[j];
          end
        end
      end

      wide_random = temp_result;
    end
  endfunction  // wide_random

  initial begin : seed_random_PROC
    integer seed, init_rand;
    `ifdef DW_MISSAMPLE_SEED
      if (`DW_MISSAMPLE_SEED != 0)
        seed = `DW_MISSAMPLE_SEED;
      else
        seed = 32'h0badbeef;
    `else
      seed = 32'h0badbeef;
    `endif

`ifdef DWC_BCM_SV
    init_rand = $urandom(seed);
`else
    init_rand = $random(seed);
`endif
  end // seed_random_PROC

      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s) begin
          data_select = wide_random(WIDTH);
          data_select_2 = wide_random(WIDTH);
        end
      end  // PROC_mk_next_data_select
    end
    assign data_s_sel_tmp = (data_s & ~data_select) | (last_data_dyn & data_select);
    assign data_s_sel_0 = (clk_d_stopped==1'b1) ? data_s : data_s_sel_tmp;
    assign data_s_sel_1 = (clk_d_stopped==1'b1) ? data_s : ((last_data_s_q & ~data_select) | (last_data_s_qq & data_select));

    assign data_s_int = ((data_s_sel_0 & ~data_select_2) | (data_s_sel_1 & data_select_2));

  end else begin : GEN_DSI_VE_EQ_1_OR_4_OR_5

    if (WIDTH <= 32) begin : GEN_D_SEL_W_LTE_32
      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s)
  `ifdef DWC_BCM_SV
          data_select = $urandom;
  `else
          data_select = $random;
  `endif
      end  // PROC_mk_next_data_select
    end else begin : GEN_D_SEL_W_GT_32
  function automatic [WIDTH-1:0] wide_random;
    input [31:0]        in_width;   // should match "WIDTH" parameter -- need one input to satisfy Verilog function requirement

    reg   [WIDTH-1:0]   temp_result;
    reg   [31:0]        rand_slice;
    integer             i, j, base;


    begin
`ifdef DWC_BCM_SV
      temp_result = $urandom;
`else
      temp_result = $random;
`endif
      if (((WIDTH / 32) + 1) > 1) begin
        for (i=1 ; i < ((WIDTH / 32) + 1) ; i=i+1) begin
          base = i << 5;
`ifdef DWC_BCM_SV
          rand_slice = $urandom;
`else
          rand_slice = $random;
`endif
          for (j=0 ; ((j < 32) && (base+j < in_width)) ; j=j+1) begin
            temp_result[base+j] = rand_slice[j];
          end
        end
      end

      wide_random = temp_result;
    end
  endfunction  // wide_random

  initial begin : seed_random_PROC
    integer seed, init_rand;
    `ifdef DW_MISSAMPLE_SEED
      if (`DW_MISSAMPLE_SEED != 0)
        seed = `DW_MISSAMPLE_SEED;
      else
        seed = 32'h0badbeef;
    `else
      seed = 32'h0badbeef;
    `endif

`ifdef DWC_BCM_SV
    init_rand = $urandom(seed);
`else
    init_rand = $random(seed);
`endif
  end // seed_random_PROC

      always @ (data_s or last_data_s) begin : PROC_mk_next_data_select
        if (data_s != last_data_s)
          data_select = wide_random(WIDTH);
      end  // PROC_mk_next_data_select
    end
    assign data_s_sel_tmp = (data_s & ~data_select) | (last_data_dyn & data_select);
    assign data_s_int = (clk_d_stopped==1'b1) ? data_s : data_s_sel_tmp;

  end endgenerate


  `else
  assign data_s_int = data_s;
  `endif
`endif


// spyglass disable_block Ac_conv04
// SMD: Checks all the control-bus clock domain crossings which do not follow gray encoding
// SJ: The clock domain crossing bus is between the register file and the read-mux of a RAM, which do not need a gray encoding.
  assign data_d_int = data_s_int;

assign data_d = data_d_int;


// spyglass enable_block Ac_conv04

`ifndef SYNTHESIS

  `ifdef DW_MODEL_MISSAMPLES
  DWC_ddrctl_bvm02
   U_CLK_DET (
    .clk         (clk_d        ),
    .rst_n       (rst_d_n      ),
    .clk_stopped (clk_d_stopped),
    .clk_period  (clk_d_period )
  );
  `endif

  `ifdef DWC_BCM_SNPS_ASSERT_ON
  localparam SVA_TYPE_BIT3 = SVA_TYPE&4'b1000;
  generate
  if (SVA_TYPE_BIT3 == 0) begin : GEN_SVATP_BIT3_EQ_0
  DWC_ddrctl_sva09 #(WIDTH) P_SYNC_NO_CHG (.*);
  end
  endgenerate
  `endif
`endif


endmodule
