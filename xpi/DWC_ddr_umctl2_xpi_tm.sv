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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_tm.sv#1 $
// -------------------------------------------------------------------------
// Description:
//              Token manager
//              Generates tokens for DDRC read commands
//              Releasing tokens when data is poped from read reorder buffer
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_tm
#(parameter USE2RAQ       = 0,
  parameter NTOKENS       = 32,
  parameter NTOKENS_LG2   = `UMCTL_LOG2(NTOKENS),
  parameter READ_DATA_INTERLEAVE_EN = 1,
  parameter OCCAP_EN      = 0,
  parameter OCCAP_PIPELINE_EN = 0,
  parameter NUM_CH_LG2    = 6,
  parameter NUM_VIR_CH    = 64,
  parameter RDWR_ORDERED  = 0,
  parameter SBR           = 0)
(
  input                                clk,          // clock
  input                                rst_n,        // asynchronous reset
  input                                gen_token_blue, // generate a new token
  input                                gen_token_red, // generate a new token
  input                                release_token,
  input  [NTOKENS_LG2-1:0]             rtoken ,
//spyglass disable_block W240
//SMD: Input 'locked_ch_raq_red' declared but not read
//SJ: Used in generate block
  input                                locked_ch_raq_red,
  input                                rrb_is_locked,
  input                                arvalid_blue,
  input                                arvalid_red,
  input [NUM_CH_LG2-1:0]               locked_ch,
  input [NUM_VIR_CH-1:0]               ch_arlast_received,
  input                                reg_rdwr_ordered_en,
//spyglass enable_block W240
  input                                reg_ddrc_occap_en,
  output [NTOKENS_LG2-1:0]             token,
  output                               empty_blue,
  output                               empty_red,
  output                               occap_xpi_tm_par_err
);


   localparam BOTH_ON   = 2'b00;
   localparam RED_OFF   = 2'b10;
   localparam BLUE_OFF  = 2'b01;
   localparam BOTH_OFF  = 2'b11;

   localparam OCCAP_CTRLW = 
                            2 +             // gate_cs 
                            NTOKENS_LG2+1 + // token_count
                            NTOKENS +       // valid
                            NTOKENS_LG2;    // token_r

   localparam SL_W = 8;
   localparam PARW = ((OCCAP_CTRLW%SL_W>0) ? OCCAP_CTRLW/SL_W+1 : OCCAP_CTRLW/SL_W);


  reg [NTOKENS -1 :0]                  valid; 
  reg [NTOKENS -1 :0]                  valid_nxt; 
  reg [NTOKENS_LG2-1:0]                token_l;
  reg [NTOKENS_LG2:0]                  token_count; 
  reg [NTOKENS_LG2:0]                  token_count_nxt; 
  wire                                 tr_full;
  wire                                 tr_wr;
  wire                                 gen_token;
  wire                                 empty;
  wire                                 almost_empty;
  wire                                 zero_token, full_token, two_token, one_token;

  wire [NTOKENS_LG2-1:0]               tm_ctrl_token_r, tm_ctrl_token_next;

  wire                                 occap_xpi_tm_retime_par_err;
  wire                                 occap_xpi_tm_ctrl_par_err;

  integer i; // for loop index

  assign occap_xpi_tm_par_err = occap_xpi_tm_retime_par_err | occap_xpi_tm_ctrl_par_err;

  always @ (*) begin : PROC_valid_nxt
      for (i=0 ; i < NTOKENS ; i=i+1) begin
         if (release_token && rtoken==i)
           valid_nxt [i] = 1'b0;
         else if (~tr_full && token_l==i)
           valid_nxt [i] = 1'b1;
         else
           valid_nxt [i] = valid [i];
      end
  end

  always @ (posedge clk or negedge rst_n) begin : PROC_valid
    if (rst_n == 1'b0) begin
      valid <= {NTOKENS{1'b0}};
    end else begin   
      valid <= valid_nxt;
    end     
  end


  always @ (*) begin : PROC_token_counter_nxt
      if (gen_token & ~release_token & ~zero_token) begin
         token_count_nxt = token_count - 1;
      end else if (~gen_token & release_token & ~full_token) begin
         token_count_nxt = token_count + 1;
      end else begin
         token_count_nxt = token_count;
      end
  end

    always @ (posedge clk or negedge rst_n) begin : PROC_token_counter
    if (rst_n == 1'b0) begin
      token_count <= {1'b1,{NTOKENS_LG2{1'b0}}};
    end else begin   
      token_count <= token_count_nxt;
    end     
  end
  
  assign gen_token      = gen_token_blue | gen_token_red;
  assign zero_token     = (token_count == {(NTOKENS_LG2+1){1'b0}}) ? 1'b1 : 1'b0;
//spyglass disable_block W528
//SMD: Variable 'two_token' set but not read
//SJ: Used in generate block
  assign two_token      = (token_count == {{(NTOKENS_LG2-1){1'b0}},2'b10}) ? 1'b1 : 1'b0;
  assign one_token      = (token_count == {{(NTOKENS_LG2){1'b0}},1'b1}) ? 1'b1 : 1'b0;
//spyglass enable_block W528
  assign full_token     = (token_count[NTOKENS_LG2] == 1'b1) ? 1'b1 : 1'b0;

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

      localparam CATEGORY = 5;

      assert_never #(0, 0, "Token count should not be greater than NTOKENS", CATEGORY) a_xpi_tm_token_count_check(clk,rst_n,(token_count[NTOKENS_LG2] & |token_count[NTOKENS_LG2-1:0]));
`endif
`endif

  DWC_ddr_umctl2_retime
  
  
  #(
   .SIZE    (NTOKENS_LG2),
   .OCCAP_EN(OCCAP_EN),
   .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
 ) 
  U_token_retime
  (
  .clk         (clk),    
  .rst_n       (rst_n),    
  .d           (token_l),
  .wr          (tr_wr),
  .rd          (gen_token),
  .par_en      (reg_ddrc_occap_en),
  .q           (token),
  .fe          (empty),
  .ff          (tr_full),
  .par_err     (occap_xpi_tm_retime_par_err)
  );

   wire [1:0] tm_ctrl_gate_cs;
   wire [1:0] tm_ctrl_gate_ns;

   generate
   if (SBR==0) begin: XPI_tm

      assign tr_wr = ~&valid;
      
      //spyglass disable_block W415a
      //SMD: Signal token_l is being assigned multiple times in same always block. 
      //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
      always @(*) begin : PROC_wr_addr 
      token_l= {NTOKENS_LG2{1'b0}};
      for (i=0; i <NTOKENS ; i=i+1) begin
         if (valid[i]==1'b0)
            token_l = i;
         end
      end
      //spyglass enable_block W415a

      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in generate block
      assign tm_ctrl_token_r     = {NTOKENS_LG2{1'b0}};
      assign tm_ctrl_token_next  = {NTOKENS_LG2{1'b0}};
      //spyglass enable_block W528

   end
   else begin: SBR_tm

      reg [NTOKENS_LG2-1:0] token_r;
      wire [NTOKENS_LG2-1:0] token_next;

      always @(posedge clk or negedge rst_n) begin
         if (~rst_n) begin
            token_r <= {NTOKENS_LG2{1'b0}};
         end
         else begin
            token_r <= token_next;
         end
      end

      assign token_next = (tr_wr & ~tr_full) ? token_l+1 : token_l;
      assign tr_wr = ~valid[token_l];

      always @(*) begin : PROC_wr_addr 
         token_l= token_r;
      end

      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in generate block
      assign tm_ctrl_token_r     = token_r;
      assign tm_ctrl_token_next  = token_next;
      //spyglass enable_block W528

   end

   if (USE2RAQ==0) begin: single_ch
      assign empty_blue = empty;
      assign empty_red = 1'b1;

      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in generate block
      assign tm_ctrl_gate_cs = 2'b00;
      assign tm_ctrl_gate_ns = 2'b00;
      //spyglass enable_block W528
   end else begin: dual_ch

      reg         gate_blue, gate_red;
      reg [1:0]   gate_cs; 
      reg [1:0]   gate_ns;

      always @ (posedge clk or negedge rst_n) begin : PROC_upd_state
         if (rst_n == 1'b0) begin
            gate_cs  <= BOTH_ON;
         end else begin
            gate_cs  <= gate_ns;
         end
      end
      if (READ_DATA_INTERLEAVE_EN==1) begin : RDI_enabled
        assign almost_empty   = (token_count < 3) ? 1'b1 : 1'b0;

        always @(*) begin: PROC_upd_gate
           gate_ns     = BOTH_ON;
           gate_blue   = 1'b0;
           gate_red    = 1'b0;
           case (gate_cs)
              BOTH_ON: begin
                          if (gen_token_blue & almost_empty) begin
                             gate_ns = BLUE_OFF;
                          end else if (gen_token_red & almost_empty) begin
                             gate_ns = RED_OFF;
                          end else begin
                             gate_ns = BOTH_ON;
                          end
                          gate_blue   = 1'b0;
                          gate_red    = 1'b0;
                       end
              BLUE_OFF:begin
                          if (~almost_empty) begin
                             gate_ns = BOTH_ON;
                          end else if (gen_token_red) begin
                             gate_ns = RED_OFF;
                          end else begin
                             gate_ns = BLUE_OFF;
                          end
                          gate_blue   = 1'b1;
                          gate_red    = 1'b0;
                       end
              default: begin
                          if (~almost_empty) begin
                             gate_ns = BOTH_ON;
                          end else if (gen_token_blue) begin
                             gate_ns = BLUE_OFF;
                          end else begin
                             gate_ns = RED_OFF;
                          end
                          gate_blue   = 1'b0;
                          gate_red    = 1'b1;
                       end
           endcase
        end
      end else begin : RDI_disabled
        assign almost_empty   = (token_count < 4) ? 1'b1 : 1'b0;
        logic locked_ch_raq_red_partial, locked_ch_raq_blue_partial;
        // This signal indicates that the currently locked RRB VC has a partial Red AXI transaction (tokens) mapped to it.
        // If rdwr_ordering is enabled PA will not switch from Red to Blue or vice-versa without completing an AXI transaction
        assign locked_ch_raq_red_partial = locked_ch_raq_red & rrb_is_locked & ~ch_arlast_received[locked_ch] & (RDWR_ORDERED==1 ? ~reg_rdwr_ordered_en : 1'b1);
        // This signal indicates that the currently locked RRB VC has a partial Blue AXI transaction (tokens) mapped to it.
        // If rdwr_ordering is enabled PA will not switch from Red to Blue or vice-versa without completing an AXI transaction
        assign locked_ch_raq_blue_partial = ~locked_ch_raq_red & rrb_is_locked & ~ch_arlast_received[locked_ch] & (RDWR_ORDERED==1 ? ~reg_rdwr_ordered_en : 1'b1);
        always @(*) begin: PROC_upd_gate
           gate_ns     = BOTH_ON;
           gate_blue   = 1'b0;
           gate_red    = 1'b0;
           case (gate_cs)
              BOTH_ON: begin
                          // If 3 tokens and gen_token and no release_token, then gate the RAQ which is granted
                          if (gen_token_blue & ~release_token & almost_empty) begin
                             gate_ns = BLUE_OFF;
                          end else if (gen_token_red & ~release_token & almost_empty) begin
                             gate_ns = RED_OFF;
                          end else begin
                             gate_ns = BOTH_ON;
                          end
                          gate_blue   = 1'b0;
                          gate_red    = 1'b0;
                       end
             BLUE_OFF: begin
                          // If we have 3 tokens, can go to BOTH_ON state
                          if (release_token & ~gen_token_red & two_token) begin
                             gate_ns = BOTH_ON;
                          // BLUE_OFF to RED_OFF transition is possible only if a Red token is generated or if there is no request from Red Q.
                          // If empty, then no need to wait for the above condition for transaition.
                          // Switch to RED_OFF only if RRB is not locked to a channel with incomplete Red transaction and if there is request from Blue Q.
                          end else if (((gen_token_red|~arvalid_red) & ~locked_ch_raq_red_partial & ~empty & arvalid_blue) | (empty & locked_ch_raq_blue_partial)) begin
                             gate_ns = RED_OFF;
                          end else begin
                             gate_ns = BLUE_OFF;
                          end
                          gate_blue   = 1'b1;
                          gate_red    = 1'b0;
                       end
              default: begin //RED_OFF
                          // If we have 3 tokens, can go to BOTH_ON state
                          if (release_token & ~gen_token_blue & two_token) begin
                             gate_ns = BOTH_ON;
                          // RED_OFF to BLUE_OFF transition is possible only if a Blue token is generated or if there is no request from Blue Q.
                          // If empty, then no need to wait for the above condition for transaition.
                          // Switch to BLUE_OFF only if RRB is not locked to a channel with incomplete Blue transaction and if there is request from Red Q.
                          end else if (((gen_token_blue|~arvalid_blue) & ~locked_ch_raq_blue_partial & ~empty & arvalid_red) | (empty & locked_ch_raq_red_partial)) begin
                             gate_ns = BLUE_OFF;
                          end else begin
                             gate_ns = RED_OFF;
                          end
                          gate_blue   = 1'b0;
                          gate_red    = 1'b1;
                       end
           endcase
        end //PROC_upd_gate
      end //RDI_disabled
      assign empty_blue    = empty | gate_blue;
      assign empty_red     = empty | gate_red;

      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in generate block
      assign tm_ctrl_gate_cs = gate_cs;
      assign tm_ctrl_gate_ns = gate_ns;
      //spyglass enable_block W528

   end
   endgenerate


  //---------------------------------------------------------------------------
  // OCCAP_EN process
  // for control related registers on clk
  //---------------------------------------------------------------------------


  generate
   if (OCCAP_EN==1) begin: OCCAP_en

     
     wire [OCCAP_CTRLW-1:0] pgen_in;  
     wire [OCCAP_CTRLW-1:0] pcheck_in;  

     // 
     // wiring of pgen_in/pcheck_in
     //


     assign pgen_in    = {tm_ctrl_gate_ns,
                          token_count_nxt,
                          valid_nxt,
                          tm_ctrl_token_next};

     assign pcheck_in  = {tm_ctrl_gate_cs,
                          token_count,
                          valid,
                          tm_ctrl_token_r};


     wire [PARW-1:0]        pgen_in_par;     
     reg  [PARW-1:0]        pgen_in_par_r;     
     wire [PARW-1:0]        pcheck_par_err;  
     wire [PARW-1:0]        pgen_parity_corr_unused, pcheck_parity_corr_unused;   
     
     wire                   parity_en;
     reg                    pcheck_en;
     wire [PARW-1:0]        parity_dummy,  mask_in;
     wire                   poison_en;

     assign parity_dummy  = {PARW{1'b1}};
     assign mask_in       = {PARW{1'b1}};
     assign poison_en     = 1'b0;

     assign parity_en = reg_ddrc_occap_en;
     always @(posedge clk or negedge rst_n) begin
           if (~rst_n) begin
              pcheck_en <= 0;
           end
           else begin
              pcheck_en <= parity_en;
           end
        end

           
     // 
     // parity checking logic itself
     //
         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_CTRLW), 
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (pgen_in),
            .parity_en     (parity_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (pgen_in_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         always @ (posedge clk or negedge rst_n)
           if (~rst_n) begin
             pgen_in_par_r <= {PARW{1'b0}};
           end
           else begin
             pgen_in_par_r <= pgen_in_par;
           end


         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_CTRLW),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (pcheck_in),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (pgen_in_par_r), // parity in
            .mask_in       (mask_in),
            .parity_out    (pcheck_par_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );     
      

         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg pcheck_par_err_r;
           always @ (posedge clk or negedge rst_n) begin : pcheck_par_err_r_PROC
             if (~rst_n) begin
               pcheck_par_err_r <= 1'b0;
             end else begin
               pcheck_par_err_r <= |pcheck_par_err;
             end
           end

           assign occap_xpi_tm_ctrl_par_err = pcheck_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign occap_xpi_tm_ctrl_par_err = |pcheck_par_err;

         end 

         
   end else begin: OCCAP_ne
      assign occap_xpi_tm_ctrl_par_err = 1'b0;
  end
  endgenerate

   
endmodule // DWC_ddr_umctl2_tm
