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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/common/DWC_ddrctl_vqueue.sv#1 $
// -------------------------------------------------------------------------
// Description:
//    Implements logical queuss using linked-lists.
//    Used as Vrtual channel Token Queue(VTQ) in RRB.
//    This implementation is suitable only for VTQ like structures.
//    A token_in can be repeated only if same token is not present/already
//    read out.
`include "DWC_ddrctl_all_defs.svh"

module DWC_ddrctl_vqueue

#(
  parameter NUM_LISTS = 3,  // Number of logical lists
  parameter NUM_LISTS_LG2 = 2,  // = (NUM_LISTS==1) ? 1 : $clog2 (NUM_LISTS);
  parameter NTOKENS = 64 ,  // Max number of payload elements that can be stored
  parameter DATAW = 1,      // Width of Data to be stored along with tokens
  parameter OCCAP_EN = `UMCTL2_OCCAP_EN,
  parameter OCCAP_PIPELINE_EN = `UMCTL2_OCCAP_PIPELINE_EN
 )
(

input                                  core_clk          , // DDRC core clock.
input                                  core_resetn       , // DDRC reset. Asynchronously assertedf with a synchronous de-assertion relatuve to core_clk.
input                                  wr                , // signals the write
input   [NUM_LISTS_LG2-1:0]            list_indx         , // index of the list where write is performed.
input   [$clog2(NTOKENS)-1:0]          token_in          , // Token to be stored
input   [DATAW-1:0]                    data_in           , // Data to be stored
input   [NUM_LISTS-1:0]                rd                , // Signals read. Each bit corresponds to individual lists.
input                                  reg_ddrc_occap_en ,
output  logic [NUM_LISTS-1:0]          empty             , // Indicates empty status of lists.
output  logic                          full              , // Dummy full signal. Full is tied to 0 internally.
output  logic [$clog2(NTOKENS)-1:0]    token_out[NUM_LISTS-1:0], // Token output of lists
output  logic [DATAW-1:0]              data_out[NUM_LISTS-1:0] , // Data output of lists
output  logic                          vqueue_par_err            // parity error
);

localparam NTOKENS_LG2 = $clog2(NTOKENS);

typedef struct packed {
  logic[NTOKENS_LG2-1:0] nxt_token;
  logic[DATAW-1:0]       data;
} vqueue_pyld_type;

vqueue_pyld_type vtq_mem [NTOKENS-1:0];
vqueue_pyld_type vtq_mem_nxt [NTOKENS-1:0];

logic [NTOKENS_LG2-1:0] rd_ptr [NUM_LISTS-1:0];
logic [NTOKENS_LG2-1:0] rd_ptr_nxt [NUM_LISTS-1:0];
logic [NTOKENS_LG2-1:0] wr_ptr [NUM_LISTS-1:0];
logic [NTOKENS_LG2-1:0] wr_ptr_nxt [NUM_LISTS-1:0];
logic [NUM_LISTS-1:0]   empty_nxt;
logic [NUM_LISTS-1:0]   vtq_list_reg_par_err;
logic [NTOKENS-1:0]     vtq_mem_reg_par_err;

// Full is dummy. The nature of generated tokens in XPI ensures that full never gets asserted.
assign full = 1'b0;
assign vqueue_par_err = (|vtq_list_reg_par_err) | (|vtq_mem_reg_par_err);

generate
for (genvar t = 0; t<NUM_LISTS; t=t+1 ) begin : multi_q_gen
  // empty generation.
  always_comb begin : vtq_empty_proc
    empty_nxt[t] = empty[t];
    if ((rd_ptr[t] == wr_ptr[t]) && wr && (list_indx == t)) begin
      empty_nxt[t] = 1'b0;
    end else if ((rd_ptr[t] == wr_ptr[t]) && rd[t]) begin
      empty_nxt[t] = 1'b1;
    end
  end
  // wr_ptr points to the next write location
  // The written token becomes the next wr_ptr
  always_comb begin : vtq_wr_ptr_proc
    wr_ptr_nxt[t] = wr_ptr[t];
    if (wr && (list_indx == t)) begin
      wr_ptr_nxt[t] = token_in;
    end
  end
  // rd_ptr points to the next read location.
  always_comb begin : vtq_rd_ptr_proc
    rd_ptr_nxt[t] = rd_ptr[t];
    if (empty[t] && wr && (list_indx == t)) begin
      rd_ptr_nxt[t] = token_in;
    // when there is only 1 element, and a read and write happens simultaneously.
    end else if (rd[t] && wr && (list_indx == t) && (rd_ptr[t] == wr_ptr[t])) begin
      rd_ptr_nxt[t] = token_in;
    // when normal read happens, the token being read out becomes the next read pointer.
    end else if (rd[t]) begin
      rd_ptr_nxt[t] = vtq_mem[rd_ptr[t]].nxt_token;
    end
  end

  assign data_out[t] = vtq_mem[rd_ptr[t]].data; //TODO Can be optimized by using rd_ptr_nxt as mux select and registering.

   DWC_ddr_umctl2_par_reg
   
     #(
      .DW      (1+NTOKENS_LG2+NTOKENS_LG2),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .RESVAL  ({1'b1, {NTOKENS_LG2{1'b0}}, {NTOKENS_LG2{1'b0}}}),
      .SL_W    (8))
   U_vtq_list_reg
     (.clk        (core_clk),
      .rst_n      (core_resetn),
      .data_in    ({empty_nxt[t],wr_ptr_nxt[t],rd_ptr_nxt[t]}),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en), //SW controlled enable/disable
      .poison_en  (1'b0),
      .data_out   ({empty[t],wr_ptr[t],rd_ptr[t]}),
      .parity_err (vtq_list_reg_par_err[t]));

end //multi_q_gen

for (genvar g = 0; g<NTOKENS; g=g+1 ) begin : vtq_mem_gen

  always_comb begin : vtq_mem_nxt_token_proc
    vtq_mem_nxt[g].nxt_token =  vtq_mem[g].nxt_token;
    if (wr && (token_in==g)) begin
      // When the last entry in a list is read, rd_ptr and wr_ptr should point to same location.
      // This assignment is needed for that.
      // This assignement will get overwritten when the next entry is written to same list.
      vtq_mem_nxt[g].nxt_token = token_in;
    end else if (wr && ~empty[list_indx] && (wr_ptr[list_indx]==g)) begin
      // when a write happens, the token_in also gets written to wr_ptr location.
      vtq_mem_nxt[g].nxt_token = token_in;
    end
  end

  always_comb begin : vtq_mem_data_proc
    vtq_mem_nxt[g].data = vtq_mem[g].data;
    // for storing data, token is used as address
    if (wr && (token_in==g)) begin
      vtq_mem_nxt[g].data = data_in;
    end
  end

   DWC_ddr_umctl2_par_reg
   
     #(
      .DW      (NTOKENS_LG2+DATAW),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .RESVAL  ({{NTOKENS_LG2{1'b0}},{DATAW{1'b0}}}),
      .SL_W    (8))
   U_vtq_mem_par_reg
     (.clk        (core_clk),
      .rst_n      (core_resetn),
      .data_in    ({vtq_mem_nxt[g].nxt_token,vtq_mem_nxt[g].data}),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en), //SW controlled enable/disable
      .poison_en  (1'b0),
      .data_out   ({vtq_mem[g].nxt_token,vtq_mem[g].data}),
      .parity_err (vtq_mem_reg_par_err[g]));

end //vtq_mem_gen
endgenerate
// rd_ptr is the token_out
assign token_out = rd_ptr;


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  logic [NUM_LISTS-1:0] fifo_model_empty;
  logic [NUM_LISTS-1:0] fifo_model_pop;
  int list_count[NUM_LISTS];
  int list_count_sum;
  logic [NUM_LISTS-1:0] push;
  logic [NUM_LISTS-1:0] pop;

  //de-mux wr and generate list specific push
  generate
    for (genvar i = 0;i<NUM_LISTS ; i=i+1 ) begin : PUSH_PROC
      assign push[i] = (i==list_indx) ?  wr : 1'b0;
    end
  endgenerate

  assign pop = rd;

  assign fifo_model_pop = pop & ~fifo_model_empty;

  //Ensure index is withing range
  // For NUM_LISTS, valid range is 0 to NUM_LISTS-1
  property p_indx_in_range;
     @(posedge core_clk) disable iff (!core_resetn)
        (wr) |-> (list_indx < NUM_LISTS);
 endproperty

 asum_list_indx_in_range : assume property (p_indx_in_range)
    else $error ("list_indx input out of range. valid range is 0 to %d",(NUM_LISTS-1));

 property p_count_zero_when_empty(empty,int count);
     @(posedge core_clk) disable iff (!core_resetn)
        (empty==1) |-> (count==0);
 endproperty

  property p_nonempty_when_count_nonzero(empty,int count);
     @(posedge core_clk) disable iff (!core_resetn)
       (empty==0) |->  (count!=0) ;
 endproperty

 //Counter that is used to predict empty generation of the list 
 // this is to aid assertion, consider this as a TB component. 
  always_ff @(posedge core_clk or negedge core_resetn) begin : proc_list_count
    if(~core_resetn) begin
      foreach (list_count[i]) list_count[i] <= 0;
    end else begin
      for (int n = 0; n < NUM_LISTS; n++) begin
        if(push[n] && !fifo_model_pop[n])
          list_count[n] <= list_count[n]+1;
        else if (!push[n] && fifo_model_pop[n])
          list_count[n] <= list_count[n]-1;
      end //for
    end
  end

  always_comb begin
    list_count_sum = 0;
    for (int i=0; i<NUM_LISTS; i++) begin
      list_count_sum = list_count_sum + list_count[i];
    end
  end

  covr_list_count_sum_eq_ntokens: cover property ( @(posedge core_clk) disable iff (!core_resetn) wr |=> (list_count_sum==NTOKENS));

  asrt_list_count_sum_lteq_ntokens: assert property( @(posedge core_clk) disable iff (!core_resetn) wr |=> (list_count_sum<=NTOKENS)) 
      else $error("Sum of entries in all the lists should be less than NTOKEN");
  
  logic [NTOKENS-1:0] token_present_nxt;
  logic [NTOKENS-1:0] token_present;

  generate
  for(genvar m=0 ; m<NTOKENS;m++) begin: CHECK_TOKEN

    always_comb begin
      token_present_nxt[m] = token_present[m];
      if (wr & token_in==m) begin
        token_present_nxt[m] = 1'b1;
      end else begin
        for (int i=0; i<NUM_LISTS; i++) begin
          if (rd[i]==1'b1 && token_out[i]==m) begin
            token_present_nxt[m] = 1'b0;
          end
        end
      end
    end //always_comb
  end //CHECK_TOKEN
  endgenerate

  always_ff @(posedge core_clk or negedge core_resetn) begin
    if (~core_resetn) begin
      token_present <= {NTOKENS{1'b0}};
    end else begin
      token_present <= token_present_nxt;
    end
  end

  asum_token_rd_aftr_wr: assume property ( @(posedge core_clk) disable iff (!core_resetn) token_present[token_in] |-> !wr )
  else $error ("Token already present in one of the VTQ");
 
  localparam QSZ = NTOKENS_LG2+DATAW;

  generate
  for(genvar l=0 ; l<NUM_LISTS;l++) begin: CHECK_LIST

    logic [QSZ-1 :0] list_item_write;
    logic [QSZ-1 :0] list_item_read;
    logic [QSZ-1 :0] que_item;

    assign list_item_write = {token_in, data_in};
    assign list_item_read = {token_out[l],data_out[l]};

    //Dont pop from list when its empty
    asum_pop_when_req_valid: assume property ( @(posedge core_clk) disable iff (!core_resetn) empty[l] |-> !rd[l] );

    asrt_check_list_empty_zero: assert property (p_count_zero_when_empty(empty[l],list_count[l]))
         else $error("Empty is not correctly generated for list %d",l);
    asrt_check_list_empty_nonzero: assert property (p_nonempty_when_count_nonzero(empty[l],list_count[l]))
         else $error("Empty is not correctly generated for list %d",l);

    DWC_ddr_umctl2_gfifo
    
    #( .WIDTH       ( QSZ),
       .DEPTH       (NTOKENS),
       .ADDR_WIDTH  ($clog2(NTOKENS)),
       .COUNT_WIDTH ($clog2(NTOKENS)+1)
    )
    fifo_model (
    
      .clk     ( core_clk          ),        // clk input
      .rst_n   ( core_resetn       ),        // active low async reset
      .wr      ( push[l]           ),        // Push domain active low push reqest ??
      .d       ( list_item_write   ),        // Push domain data input
      .rd      ( fifo_model_pop[l] ),        // Pop domain active high pop request
      .init_n  ( 1'b1              ),        // active low sync. reset (FIFO flush) 
      .par_en  ( 1'b0              ), 
      .ff      (                   ),      // Push domain Full status flag
      .q       (que_item           ),      // Pop domain data input
      .fe      (fifo_model_empty[l]),      // Pop domain Empty status flag
      .disable_sva_fifo_checker_rd(1'b0),
      .disable_sva_fifo_checker_wr(1'b0),
      .wcount  ( ),      // word count
      .par_err ( )
    );

      property p_queue_function;
          @(negedge core_clk) disable iff (!core_resetn)
             fifo_model_pop[l] |->  list_item_read==que_item;
      endproperty
     
       asrt_check_list_queue_func: assert property (p_queue_function)
            else $fatal("Queue function for list %0d failed exp: %0h  :: got %0h",l,que_item,list_item_read);

  end
  endgenerate

`endif//SYNTHESIS
`endif//SNPS_ASSERT_ON

endmodule
