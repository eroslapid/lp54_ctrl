
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
// Description : DWC_ddrctl_bcm25.v Verilog module for DWC_ddrctl
//
// DesignWare IP ID: fea9b7fc
//
////////////////////////////////////////////////////////////////////////////////
module DWC_ddrctl_bcm25 (
             clk_s,
             rst_s_n,
             send_s,
             data_s,
             empty_s,
             full_s,
             done_s,

             clk_d,
             rst_d_n,
             data_avail_d,
             data_d
           );

 parameter integer WIDTH       = 8;  // RANGE 1 to 1024
 parameter integer PEND_MODE   = 1;  // RANGE 0 to 1
 parameter integer ACK_DELAY   = 1;  // RANGE 0 to 1
 parameter integer F_SYNC_TYPE = 2;  // RANGE 0 to 4
 parameter integer R_SYNC_TYPE = 2;  // RANGE 0 to 4
 parameter integer VERIF_EN    = 1;  // RANGE 0 to 4
 parameter integer SEND_MODE   = 0;  // RANGE 0 to 1
 parameter integer SVA_TYPE    = 0;
 parameter integer RST_VAL     = 0;  // RANGE -1 to 2147483647

 localparam F_SYNC_TYPE_P8 = F_SYNC_TYPE + 8;
 localparam R_SYNC_TYPE_P8 = R_SYNC_TYPE + 8;
 localparam [WIDTH-1:0] RESET_VALUE = (RST_VAL== 0) ? {WIDTH{1'b0}}
                                    : (RST_VAL==-1) ? {WIDTH{1'b1}}
                                    :                 RST_VAL;
`ifndef SYNTHESIS
`ifdef DWC_BCM_MSG_VERBOSITY
  localparam BCM_MSG_VERBOSITY = `DWC_BCM_MSG_VERBOSITY;
`else
  localparam BCM_MSG_VERBOSITY_DEF = 32'hfffffff1;

  `ifndef DWC_DISABLE_CDC_METHOD_REPORTING
    localparam BCM_MSG_VERBOSITY_TMP2 = 32'h00000004;
  `else
    localparam BCM_MSG_VERBOSITY_TMP2 = 32'h0;
  `endif

  localparam BCM_MSG_VERBOSITY = BCM_MSG_VERBOSITY_DEF |
               BCM_MSG_VERBOSITY_TMP2;
`endif
`endif

 input             clk_s;    //Source clock
 input             rst_s_n;  //Source domain asynch.reset (active low)
 input             send_s;   //Source domain send request input
 input [WIDTH-1:0] data_s;   //Source domain send data input
 output             empty_s;  //Source domain transaction regs empty
 output             full_s;   //Source domain transaction regs full
 output             done_s;   //Source domain transaction done output

 input             clk_d;    //Destination clock
 input             rst_d_n;  //Destination domain asynch. reset (active low)
 output             data_avail_d; //Destination domain data update output
 output [WIDTH-1:0] data_d;   // WIDTH Destination domain data output

  reg  [WIDTH-1:0] data_s_reg;
  reg  [WIDTH-1:0] data_d_reg;
  wire [WIDTH-1:0] data_s_mux;


  reg  busy_pnr;
  wire busy_s_pnd;

  wire busy_s_pas;
  reg  busy_int;
  wire ack_s_pas;
  wire event_d_pas;
  wire data_s_ren;

  wire send_in;
  wire send_en;
  reg  dr_bsy;
  wire dr_bsy_nxt;


  wire done_s_nxt;
  wire busy_s_nxt;

  reg  data_avail_reg;
  wire data_d_nxt;



`ifndef SYNTHESIS
  initial begin
    if (((F_SYNC_TYPE > 0)&&(F_SYNC_TYPE < 8))&&(BCM_MSG_VERBOSITY[2]==1'b1))
       $display("Information: *** Instance %m module is using the <Data Bus Synchronizer With Acknowledge (5)> Clock Domain Crossing Method ***");
  end

`endif

  DWC_ddrctl_bcm23
   #(0, 0, ACK_DELAY, F_SYNC_TYPE_P8, R_SYNC_TYPE_P8, VERIF_EN, 0, SVA_TYPE)
    U1 (
        .clk_s(clk_s),
        .rst_s_n(rst_s_n),
        .event_s(send_en),
        .clk_d(clk_d),
        .rst_d_n(rst_d_n),
        .busy_s(busy_s_pas),
        .ack_s(ack_s_pas),
        .event_d(event_d_pas)
        );


  always @ (posedge clk_s or negedge rst_s_n) begin : src_pos_reg_PROC
    if  (rst_s_n == 1'b0)  begin
      data_s_reg <= {WIDTH{1'b0}};
      busy_int   <= 1'b0;
      busy_pnr   <= 1'b0;
      dr_bsy     <= 1'b0;
    end else begin
        if(data_s_ren == 1'b1)
          data_s_reg <= data_s_mux;
          busy_int   <= busy_s_nxt;
          busy_pnr   <= busy_s_pnd;
          dr_bsy     <= dr_bsy_nxt;
    end
  end

  always @ (posedge clk_d or negedge rst_d_n) begin : dest_pos_reg_PROC
    if (rst_d_n == 1'b0 ) begin
       data_d_reg     <= RESET_VALUE;
       data_avail_reg <= 1'b0;
    end else  begin
        if(data_d_nxt == 1'b1)
          data_d_reg   <= data_s_reg;
        data_avail_reg <= data_d_nxt;
    end
  end


generate
  if (PEND_MODE == 1) begin : GEN_PM1
    reg  [WIDTH-1:0] data_s_pnd;
    reg  pr_bsy;
    wire pr_bsy_nxt;
    wire data_s_pen;

    assign data_s_pen = busy_s_nxt & send_in;

    always @ (posedge clk_s or negedge rst_s_n) begin : src_pend_reg_PROC
      if  (rst_s_n == 1'b0)  begin
        data_s_pnd <= {WIDTH{1'b0}};
        pr_bsy     <= 1'b0;
      end else begin
          if(data_s_pen == 1'b1)
            data_s_pnd <= data_s;
          pr_bsy     <= pr_bsy_nxt;
      end
    end

    assign pr_bsy_nxt   = (send_in & (~ pr_bsy) & dr_bsy)
                        | (pr_bsy & (~ ack_s_pas) & dr_bsy)
                        | (send_in & ack_s_pas & dr_bsy);

    assign busy_s_pnd   = (dr_bsy & pr_bsy_nxt) & (~ack_s_pas);
    assign busy_s_nxt   = (send_in | send_en) | (~ack_s_pas & busy_int) | (ack_s_pas & pr_bsy);
    assign data_s_ren   = (send_in & (~ dr_bsy) & (~busy_int)) | (ack_s_pas & pr_bsy) | (~ dr_bsy & pr_bsy & (~ ack_s_pas));
    assign send_en      = (send_in & (~ dr_bsy)) | (dr_bsy & (~ busy_s_pas));
    assign data_s_mux   = (pr_bsy == 1'b1) ? data_s_pnd : data_s;
    assign dr_bsy_nxt   = (send_en & (~ busy_s_pas)) | (dr_bsy & (~ ack_s_pas)) | (ack_s_pas & pr_bsy) | (pr_bsy & (~ dr_bsy));
  end else begin : GEN_PM0
    assign busy_s_pnd   = send_in | dr_bsy_nxt;
    assign busy_s_nxt   = send_in | dr_bsy_nxt;
    assign data_s_ren   = send_in & (~ busy_s_pas);
    assign send_en      = send_in;
    assign data_s_mux   = data_s;
    assign dr_bsy_nxt   = (send_en & (~ busy_s_pas)) | (dr_bsy & (~ ack_s_pas));
  end
endgenerate

generate
  if (SEND_MODE == 0) begin : GEN_SEND_IN_SM0
    assign send_in = send_s;
  end
  if (SEND_MODE == 1) begin : GEN_SEND_IN_SM1
    reg  send_reg;
    always @ (posedge clk_s or negedge rst_s_n) begin : send_reg_PROC
      if  (rst_s_n == 1'b0)  begin
        send_reg   <= 1'b0;
      end else begin
          send_reg   <= send_s;
      end
    end

    assign send_in = send_s && !send_reg;
  end
  if (SEND_MODE == 2) begin : GEN_SEND_IN_SM2
    reg  send_reg;
    always @ (posedge clk_s or negedge rst_s_n) begin : send_reg_PROC
      if  (rst_s_n == 1'b0)  begin
        send_reg   <= 1'b0;
      end else begin
          send_reg   <= send_s;
      end
    end

    assign send_in = !send_s && send_reg;
  end
  if (SEND_MODE > 2) begin : GEN_SEND_IN_SM_GT_2
    reg  send_reg;
    always @ (posedge clk_s or negedge rst_s_n) begin : send_reg_PROC
      if  (rst_s_n == 1'b0)  begin
        send_reg   <= 1'b0;
      end else begin
          send_reg   <= send_s;
      end
    end

    assign send_in = send_s ^ send_reg;
  end
endgenerate

  assign done_s_nxt = ack_s_pas;
  assign data_d_nxt = event_d_pas;

  assign data_avail_d = data_avail_reg;
  assign data_d       = data_d_reg;
  assign done_s       = done_s_nxt;
  assign empty_s      = busy_int;
  assign full_s       = busy_pnr;


`ifdef DWC_BCM_SNPS_ASSERT_ON
`ifndef SYNTHESIS

  DWC_ddrctl_sva04 #(SEND_MODE) P_DATA_SYNC_HS (.*);

  generate if ((F_SYNC_TYPE==0) || (R_SYNC_TYPE==0)) begin : GEN_SINGLE_CLOCK_CANDIDATE
    DWC_ddrctl_sva07 #(F_SYNC_TYPE, R_SYNC_TYPE) P_CDC_CLKCOH (.*);
  end endgenerate
  localparam SVA_TYPE_BIT2 = SVA_TYPE&4'b0100;
  generate
    if (SVA_TYPE_BIT2 == 0) begin : GEN_SVATP_BIT2_EQ_0
      DWC_ddrctl_sva08 #(WIDTH, RST_VAL) P_SYNC_EQ_RST (
        .rst_d_n       (rst_d_n      ),
        .data_s        (data_s       ),
        .data_d        (data_d       )
      );
    end
  endgenerate

`endif // SYNTHESIS
`endif // DWC_BCM_SNPS_ASSERT_ON

endmodule
