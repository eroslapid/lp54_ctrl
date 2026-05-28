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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_df.sv#1 $
// -------------------------------------------------------------------------
// Description:
//           uMCTL XPI ENIF Dummy Filter
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_df
  #(
    parameter INFOW                    = 4,
    parameter ENIF_LENW                = 3,
    parameter ENIF_SIZEW               = 3,
    parameter ENIF_MAXSIZE             = 3,
    parameter PDBW_CASE                = 0, //Programmabe Data bus width Case
    parameter MAXSIZE                  = 2,
    parameter DOWN_SIZE                = 0,
    parameter UP_SIZE                  = 0,
    parameter NUM_CH                   = 2,
    parameter NUM_CH_LG2               = 1,
    parameter READ_DATA_INTERLEAVE_EN  = 0,
    parameter USE2RAQ                  = 0,
    parameter AXI_IDW                  = 8,
    parameter NUM_DCH                  = 1,
    parameter DCH_INTERLEAVE           = 0,
    parameter OCCAP_EN                 = 0,
    parameter OCCAP_PIPELINE_EN        = 0

    )
  
                              (
   input                  clk,          // clock
   input                  rst_n,        // asynchronous reset
   input [INFOW-1:0]      info,         // info  
   input                  wr,           // write
   input                  rd,           // read
   input                  rrb_rd_last,
   input [1:0]            reg_ddrc_data_bus_width,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input [NUM_CH_LG2-1:0] rrb_ch_num, //virtual channel number
//spyglass enable_block W240
   input                  reg_ddrc_occap_en,
   input [NUM_DCH-1:0]    rerror_in,
   output                 df_last,
   output                 df_last_pkt,
   output reg             empty,        // DF empty 
   output reg             full,         // DF full
   output [MAXSIZE-1:0]   addr_offset,
   output                 split,
   output                 rerror_out,
   output                 occap_xpi_df_par_err
   );
 
  localparam FSM_SEQ_W = ENIF_MAXSIZE+ENIF_LENW+1;
  localparam ENIF_MAXSIZE_B = (1<<ENIF_MAXSIZE);
  localparam ENIF_HALFSIZE_B = (1<<(ENIF_MAXSIZE-1));

  localparam FBW              = 2'b00;
  localparam HBW              = 2'b01;
  localparam QBW              = 2'b10;
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [ENIF_MAXSIZE-1:0]                addr_offset_align;
  wire [ENIF_LENW-1:0]                  alen;         // AXI first INCR burst length
  wire [ENIF_SIZEW-1:0]                 asize;         // AXI burst size
  
  wire [ENIF_MAXSIZE-1:0]               addr_offset_reg;
  wire [ENIF_MAXSIZE-1:0]               addr_offset_next;  
  wire [ENIF_MAXSIZE-1:0]               addr_offset_interleaving;

  wire [ENIF_MAXSIZE-1:0]               add_offset_cur;
  wire [ENIF_MAXSIZE-1:0]               add_offset_upd;
    
  wire [ENIF_MAXSIZE-1:0]               size_byte;
  wire                                  last_index;
  wire                                  half_addr_beat, last_addr_beat;
  wire                                  last_beat_axi;
  wire                                  first_beat_axi;
  wire [ENIF_LENW-1:0]                  axi_beat_count_reg;
  reg [ENIF_LENW-1:0]                   axi_beat_count_next;
  wire [ENIF_LENW-1:0]                  axi_beat_count_interleaving;  

  wire                                  occap_xpi_df_assomem_err, occap_packet_fsm_par_err;
  
  // Packet state machine encodings
  localparam PACKET_STATE_WIDTH  = 1;
  localparam IDLE                = 1'b0;  
  localparam WAIT_RRB_LAST       = 1'b1;
  reg [PACKET_STATE_WIDTH-1:0]  packet_state_next;
  wire [PACKET_STATE_WIDTH-1:0] packet_state_reg; 

  localparam ASSOMEMW = ENIF_MAXSIZE+ENIF_LENW;

  wire                                 fbw_mode,hbw_mode,qbw_mode;
  wire                                 up_size_act, dw_size_act;
 
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
  assign hbw_mode = (reg_ddrc_data_bus_width==HBW) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW) ? 1'b1: 1'b0;
//spyglass enable_block W528  

 //Upsizers are active
  assign up_size_act = PDBW_CASE==0 ? (UP_SIZE==1) :
                       PDBW_CASE==2 ? fbw_mode     :
                       PDBW_CASE==3 ? (fbw_mode|hbw_mode) :
                       PDBW_CASE==4 ? 1'b1 
                                    : 1'b0; //case 5

//downsizers are active
  assign dw_size_act = PDBW_CASE==0 ? (DOWN_SIZE==1) :
                       PDBW_CASE==1 ? (hbw_mode|qbw_mode) :
                       PDBW_CASE==2 ? qbw_mode :
                       PDBW_CASE==5 ? 1'b1 
                                    : 1'b0; //case 4

  generate
  if ((NUM_CH>1) && (READ_DATA_INTERLEAVE_EN==1)) begin: RD_INTERLEAVE

    wire [ASSOMEMW-1:0]                  assomem_q;
    wire [ASSOMEMW-1:0]                  assomem_d;      
    wire                                 assomem_wr;
    wire                                 assomem_rd;
    wire                                 assomem_full_unused;
    wire                                 assomem_empty_unused; 
    wire [ENIF_LENW-1:0]                 assomem_axi_beat_count;
    wire [ENIF_MAXSIZE-1:0]              assomem_addr_offset;

    wire                                 first_beat, first_beat_next;    
    wire                                 first_beat_r; 
    
    assign assomem_wr   = wr & ~empty & rrb_rd_last & ~df_last;
    assign assomem_rd   = rd & wr & df_last;
    assign {assomem_addr_offset,assomem_axi_beat_count} = assomem_q;
    assign assomem_d = {addr_offset_next,axi_beat_count_next};    

    assign first_beat = first_beat_r;    

    assign axi_beat_count_interleaving = first_beat ? assomem_axi_beat_count : axi_beat_count_reg;
    assign addr_offset_interleaving = first_beat ? assomem_addr_offset : addr_offset_reg;
    
    DWC_ddr_umctl2_assomem
    
      #(
        .DATAW           (ASSOMEMW),
        .IDW             (NUM_CH_LG2),
        .NUMID           (NUM_CH),
        .OCCAP_EN        (OCCAP_EN),
        .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
        ) 
    assomem 
      (
       .clk             (clk),
       .rst_n           (rst_n),
       .wr              (assomem_wr),         
       .d               (assomem_d),
       .rd              (assomem_rd),
       .par_en          (reg_ddrc_occap_en),
       .full            (assomem_full_unused),
       .empty           (assomem_empty_unused),
       .q               (assomem_q),
       .par_err         (occap_xpi_df_assomem_err),
       .wr_id           (rrb_ch_num[NUM_CH_LG2-1:0]),
       .rd_id           (rrb_ch_num[NUM_CH_LG2-1:0])
     );

   assign first_beat_next = ~wr&first_beat_r | wr&~full&rrb_rd_last;


   // first_beat_r is replaced by TMR if OCCAP_EN=1
   DWC_ddrctl_bcm95_i
    #(
                             .TMR    (OCCAP_EN), // use of TMR is dependent on OCCAP_EN
                             .WIDTH  (1),
                             .RSTVAL (1)      // rst to 1
                           )
    U_tmr_first_beat_r (
                 .clk     (clk),
                 .rst_n   (rst_n),
                 .init_n  (1'b1), // do not use INIT_N
                 .d_in    (first_beat_next),
                 .d_out   (first_beat_r)
                 );


    assign df_last_pkt =  last_index & rrb_rd_last;
  end // block: RD_INTERLEAVE
  else begin: NO_RD_INTERLEAVE 
    assign axi_beat_count_interleaving =  axi_beat_count_reg;
    assign addr_offset_interleaving    =  addr_offset_reg;
    assign occap_xpi_df_assomem_err    = 1'b0;
    assign df_last_pkt =  1'b0;
  end

  if (DCH_INTERLEAVE==1) begin: DCH_intlv_en
   wire subsized_trn = (size_byte == (1'b1<<ENIF_MAXSIZE)) ? 1'b0 : 1'b1;
   wire rerror_sel   = (half_addr_beat & ~last_addr_beat) ? rerror_in[0] : rerror_in[1]; // separate error, pick first half for addresses falling in the first half
   assign rerror_out = subsized_trn ? rerror_sel : |rerror_in; // pick the selected rerror in case of subsized transfer, otherwise need to combine the error in a single bit
  end
  else begin: DCH_intlv_dis
   assign rerror_out = |rerror_in;
  end

  endgenerate 

  assign occap_xpi_df_par_err = occap_xpi_df_assomem_err | occap_packet_fsm_par_err;
  
  assign {split,addr_offset,alen,asize} = info; 
  assign df_last = (dw_size_act==1||up_size_act==1) ? last_beat_axi:last_beat_axi&~split;
  
  always @(*) begin: COMB_align_addr_to_size
    integer i;
    for (i=0; i<ENIF_MAXSIZE;i=i+1) begin
      if (i<asize)
        addr_offset_align[i]= 1'b0;
      else 
        addr_offset_align[i]= addr_offset[i];
      
    end
  end

  assign size_byte         = 1'b1 << asize;
  assign add_offset_cur    = first_beat_axi ? addr_offset_align : addr_offset_interleaving;

  //spyglass disable_block W164a
  //SMD: LHS: 'add_offset_upd' width 5 is less than RHS: '(add_offset_cur + size_byte)' width 6 in assignment
  //SJ: Overflow expected. See bug5632, comment #19.
  assign add_offset_upd    = add_offset_cur + size_byte;
  //spyglass enable_block W164a
  
  assign addr_offset_next  = (rd&~empty) ? add_offset_upd : addr_offset_interleaving;
 
  //spyglass disable_block W528
  //SMD: Variable set but not read
  //SJ: Used in generate block
  assign half_addr_beat    = (add_offset_upd <= ENIF_HALFSIZE_B) ? 1'b1 : 1'b0;
  //spyglass enable_block W528

  generate
  if(PDBW_CASE==0) begin : no_pgdbw
     assign last_addr_beat =  (add_offset_upd == (1'b1<<ENIF_MAXSIZE)) ? 1'b1 : 1'b0;
  end else begin : prgdbw
     //ENIF_MAXSIZE in HBW =  ENIF_MAXSIZE-1 
     //ENIF_MAXSIZE in QBW =  ENIF_MAXSIZE-2 
     assign last_addr_beat   =  ( (hbw_mode && (add_offset_upd[ENIF_MAXSIZE-2:0] == (1'b1<<(ENIF_MAXSIZE-1))) ) ||
                                  (qbw_mode && (add_offset_upd[ENIF_MAXSIZE-3:0] == (1'b1<<(ENIF_MAXSIZE-2))) ) ||
                                  (add_offset_upd == (1'b1<<ENIF_MAXSIZE))
                                )  ? 1'b1 : 1'b0;
  end 
  endgenerate

  assign last_index        = last_addr_beat ? 1'b1 : last_beat_axi;
  assign last_beat_axi     = (axi_beat_count_interleaving== alen) ? 1'b1 : 1'b0;
  assign first_beat_axi    = (axi_beat_count_interleaving== {(ENIF_LENW){1'b0}}) ? 1'b1 : 1'b0;

  always @ (*) begin
    axi_beat_count_next = axi_beat_count_interleaving;
    if (rd&~empty) begin 
      if (last_beat_axi)
        axi_beat_count_next = {(ENIF_LENW){1'b0}};
      else 
        axi_beat_count_next = axi_beat_count_interleaving+1;
    end
  
  end // always @ begin
  
  wire [FSM_SEQ_W-1:0] packet_fsm_in, packet_fsm_out;

  assign packet_fsm_in = {addr_offset_next,axi_beat_count_next,packet_state_next};
  assign {addr_offset_reg,axi_beat_count_reg,packet_state_reg} = packet_fsm_out;

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (FSM_SEQ_W),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)      
   )
   U_packet_fsm_r
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (packet_fsm_in),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (packet_fsm_out),
      .parity_err (occap_packet_fsm_par_err)
    );


  always @(*) begin
    packet_state_next = packet_state_reg;
    empty = 1'b1;   
    full = 1'b1;   
    case (packet_state_reg)
      IDLE: begin
        empty = ~wr;
        full  = ~(rd&last_index);
        if (rd&wr&last_beat_axi&~rrb_rd_last) begin
          packet_state_next = WAIT_RRB_LAST;
        end
                     
      end
      default: begin
        empty = 1'b1;
        full  = 1'b0;
        if (wr&rrb_rd_last) begin
          packet_state_next = IDLE;
        end
      end
    endcase // case(packet_state_reg)
  end // always @ (*)

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  
  `assert_x_value(ERROR_XPI_DF_INFO_SIGNAL_VALUE_X,wr,info);
   
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON


  
endmodule // DWC_ddr_umctl2_xpi_df
