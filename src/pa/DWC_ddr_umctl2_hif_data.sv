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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_hif_data.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               Host Interface (HIF) data path
//               Implements the write data multiplexer,
//               read data demultiplexer and associated control logic
//               to interface between XPIs and DDRC HIF
//               This block is only required for multi-port configurations
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_hif_data
  #( 
     parameter NPORTS               = 1,
     parameter MEMC_WDATA_PTR_BITS  = 8,
     parameter A_DW                 = 10,
     parameter ADDR_ERR_EN          = 0,
     parameter AXI_IDW              = 8,
     parameter AXI_USERW            = 1,
     parameter MEMC_TAGBITS         = 16,
     parameter A_STRBW              = 32,
     parameter A_PARW               = 160,
     parameter NAB                  = 2,
     parameter M_DW                 = 16,
     parameter A_NPORTS_LG2         = 1,
     parameter WDATA_PTR_QD         = 32,
     parameter EXA_ACC_SUPPORT      = 0,
     parameter DCH_INTERLEAVE       = 0,
     parameter M_USE_RMW            = 0,
     parameter OCPAR_EN             = 0,
     parameter OCCAP_EN             = 0,
     parameter OCCAP_PIPELINE_EN    = 0,
     parameter WDATA_RETIME         = 1
     )
   (
    input                           clk,
    input                           rst_n,

    // HIF Write Data Pointer Return
    input [MEMC_WDATA_PTR_BITS-1:0] hif_wdata_ptr,
    input                           hif_wdata_ptr_valid,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
    input                           hif_wr_addr_err,
//spyglass enable_block W240

    // HIF Read Data Channel (Common Response)
    input                           hif_rdata_valid,
    input                           hif_rdata_end,
    input [MEMC_TAGBITS-1:0]        hif_rdata_token,
    input [A_DW-1:0]                hif_rdata,
    input [A_STRBW-1:0]             hif_rdata_parity,
    input                           hif_rdata_uncorr_ecc_err,
    input                           hif_rdata_crc_err,
    input                           hif_rdata_uncorr_linkecc_err,
    input                           hif_rdata_eapar_err,

    input                           hif_rd_addr_err,
    // HIF Write Data Channel
    input                           hif_wdata_stall,
    output                          hif_wdata_valid,
    output                          hif_wdata_end,
    output [A_DW-1:0]               hif_wdata,
    output [A_STRBW-1:0]            hif_wdata_mask,

    output [A_PARW-1:0]             hif_wdata_parity,


    // XPI Write Data Channel
    input [NPORTS-1:0]           e_wvalid,
    output [NPORTS-1:0]          e_wready,
    input [NPORTS*A_DW-1:0]      e_wdata,
    input [NPORTS*A_STRBW-1:0]   e_wstrb,
    input [NPORTS*A_PARW-1:0]    e_wparity,
    input [NPORTS-1:0]           e_wlast,
    input [NPORTS*A_STRBW-1:0]   e_wpar_err,
    input [NPORTS-1:0]           e_wlast_pkt,
    //spyglass disable_block W240
    //SMD: Input declared but not read
    //SJ: Used in generate block  
    input [NPORTS-1:0]           e_snf_mode,
    //spyglass enable_block W240
    


    // ocpar slverr gate
    input                              reg_ddrc_par_addr_slverr_en,
    input                              reg_ddrc_par_wdata_slverr_en,
    
    input                              reg_ddrc_ocecc_wdata_slverr_en,

    input                     reg_ddrc_wr_poison_slverr_en,
    input                     reg_ddrc_wr_poison_intr_en,
    input                     reg_ddrc_wr_poison_intr_clr,
    input  [1:0]              reg_ddrc_data_bus_width,
    input                     reg_ddrc_occap_en,
    output                    occap_hif_data_par_err,

    output [NPORTS-1:0]       wr_poison_intr,

    // XPI Read Data Channel
         // input [NPORTS-1:0] e_rready,  // not required by design
    output [NPORTS-1:0]                e_rvalid,
    output [NPORTS*A_DW-1:0]           e_rdata,
    output [NPORTS*A_STRBW-1:0]        e_rdata_parity,
    output [NPORTS-1:0]                e_rlast_pkt,
    output [NPORTS*MEMC_TAGBITS-1:0]   e_resp_token, // hif_rdata_token going to the XPIs: e_rlast,e_rid, e_rinfo, rtoken
    output [NPORTS-1:0]                e_rerror,
   
    // XPI Write Response Channel
    output [NPORTS-1:0]          e_bvalid,
    input [NPORTS-1:0]           e_bready,    
    output [NPORTS-1:0]          e_aw_slverr,
    output [NPORTS*AXI_IDW-1:0]  e_bid,
    output [NPORTS-1:0]          e_bresp,
    output [NPORTS*AXI_USERW-1:0]  e_buser
    );
    
   localparam OCECC_EN = WDATA_RETIME;

   localparam WDATA_PTR_QW = (ADDR_ERR_EN == 1 ? 1 : 0 ) + MEMC_WDATA_PTR_BITS;
   localparam WDATA_PTR_QD_LG2 = `UMCTL_LOG2(WDATA_PTR_QD);

   localparam WDATA_RETIME_WIDTH = A_DW + 1 + A_PARW + A_STRBW;

   // Exclusive OKAY Response
   localparam EXOKAY = 1'b1;

   localparam PAR_VEC_NEX   = NPORTS*2;
   localparam PAR_VEC_WIDTH = PAR_VEC_NEX+(EXA_ACC_SUPPORT>0 ? 2 : 0);
   localparam M_DW_HBW      = (M_DW > 8)  ? M_DW/2 : M_DW;
   localparam M_DW_QBW      = (M_DW > 16) ? M_DW/4 : M_DW;
   localparam ERRMASK_M_HBW = {{(M_DW_HBW/8){1'b1}},{(M_DW_HBW/8){1'b0}} };
   localparam ERRMASK_A_HBW  = {2**NAB {ERRMASK_M_HBW}};
   localparam ERRMASK_M_QBW = {{((M_DW_QBW/8)*3){1'b1}},{(M_DW_QBW/8){1'b0}} };
   localparam ERRMASK_A_QBW  = {2**NAB {ERRMASK_M_QBW}};
   localparam FBW            = 2'b00;
   localparam HBW            = 2'b01;
   localparam QBW            = 2'b10;

   wire [PAR_VEC_NEX-1:0] par_vec_nex_i, par_vec_nex_r;
   wire [PAR_VEC_WIDTH-1:0] par_vec_i, par_vec_r;

   wire wdatar_par_err;

   reg wdata_valid, wdata_end;
   reg wdata_last, wdata_ready;
   reg [A_DW-1:0] wdata;
   reg [A_STRBW-1:0] wdata_mask;
   reg [A_PARW-1:0] wparity;
   reg [A_STRBW-1:0] wpar_err;

   wire wdata_end_i, wdata_valid_i;
   wire [A_DW-1:0] wdata_i;
   wire [A_STRBW-1:0] wdata_mask_i;
   wire [A_PARW-1:0] wparity_i;

   wire [A_STRBW-1:0] wdata_mask_masked;

   wire wdata_stall_i;

   // Write address error
   wire wptr_q_wr_addr_err;

   //last HIF WCMD
   wire wptr_q_awlast;

   // inline ECC
   wire wptr_q_awvalid_iecc_unused;
   wire wptr_q_awlast_iecc_unused;

   // Accumulated SLVERR for burst
   wire  [NPORTS-1:0] slverr_burst_r;
   reg  [NPORTS-1:0] slverr_burst_w;
   wire slverr_burst;

   wire [A_NPORTS_LG2-1:0] wport_num, rport_num;
   wire [NPORTS-1:0] wport_num_oh, rport_num_oh;

   wire [WDATA_PTR_QD_LG2:0] wptrq_wcount_unused; // not used
   wire [WDATA_PTR_QW-1:0] wptrq_d, wptrq_q;
   wire wptrq_wr, wptrq_rd, wptrq_full, wptrq_empty;

   // XPI Write Response Channel
   wire [AXI_IDW-1:0] wptrq_q_bid;
   wire [AXI_USERW-1:0] wptrq_q_user;
   wire wptrq_q_bresp;
   wire wexa_strb;
   wire   port_snf_status;

   wire [NPORTS-1:0] bresp_wlast;

   wire wptrq_q_poison, wptrq_q_poison_i;
   wire [NPORTS-1:0] wr_poison_intr_r, wr_poison_intr_nxt;
   wire wptrq_q_ocpar_err, wptrq_q_ocpar_err_i;

   
   wire err_valid, err_rst;
   wire slverr_set;

   wire wptrq_slverr;
   
   // Decode XPI Write Reponse
   wire e_wrb_wexa_acc, e_wrb_wexa_acc_lock;   // Exclusive Write Transaction
   wire e_wrb_wexa_resp;  // Exclusive Write Response

   wire rerror;

   wire wptrq_par_err;
   wire par_vec_parity_err;

   // assign output occap error
   assign occap_hif_data_par_err = wptrq_par_err | par_vec_parity_err | wdatar_par_err;

   assign par_vec_nex_i = {slverr_burst_w,wr_poison_intr_nxt};
   assign {slverr_burst_r,wr_poison_intr_r} = par_vec_nex_r;


   assign err_valid        = wdata_valid & wdata_ready;
   
   generate
      if (DCH_INTERLEAVE==1) begin: Channel_inerleave
         assign bresp_wlast   = e_wlast_pkt;
         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in different generate blocks
         assign err_rst       = err_valid & wdata_end;
         //spyglass enable_block W528
      end
      else begin: Single_DCH
       if(M_USE_RMW==0 && OCPAR_EN==1) begin:bvalid_wlast
         assign bresp_wlast  =  e_wlast;
       end else begin :early_bvalid
           reg  wdata_first;
           always @(posedge clk or negedge rst_n) begin : wdata_first_PROC
              if (rst_n==1'b0) 
                 wdata_first <= 1'b1;
              else if (wptrq_rd)
                 wdata_first <= 1'b1;
              else if (|(e_wvalid & e_wready & wport_num_oh))
                 wdata_first <= 1'b0;
           end 
           
           if (OCPAR_EN==0 && OCECC_EN==0) begin : alws_early_bvalid
              //If there is no parity then no need of waiting till last beat 
              assign bresp_wlast = ({NPORTS{(wptr_q_awlast & wdata_first & (~wptrq_empty))}} & wport_num_oh);
           end else begin : snf_early_bvalid
             //If there is parity then wait on last beat based on port's SNF status  
              assign bresp_wlast  =  (port_snf_status ) ? ({NPORTS{(wptr_q_awlast & wdata_first & (~wptrq_empty))}} & wport_num_oh) 
                                                      : e_wlast;
           end
        end
         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in different generate blocks
         assign err_rst       = err_valid & wdata_last;
         //spyglass enable_block W528
      end
   endgenerate

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (PAR_VEC_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .SL_W    (8)
   )
   U_par_vec
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (par_vec_i),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (par_vec_r),
      .parity_err (par_vec_parity_err)
   );


  generate 
   if ((DCH_INTERLEAVE==1) || (M_USE_RMW==0)) begin : NO_RMW
      assign slverr_set  = (((|wpar_err & (reg_ddrc_par_wdata_slverr_en | reg_ddrc_ocecc_wdata_slverr_en)) | wptr_q_wr_addr_err) & err_valid);
      assign slverr_burst  = slverr_set | (|(slverr_burst_r & wport_num_oh));
      always @(*) begin: write_error_COMB_PROC
         integer sel;
         for (sel=0; sel<NPORTS; sel=sel+1)
            slverr_burst_w[sel] = (wport_num_oh[sel]==1'b0 ? slverr_burst_r[sel] : 
                                   err_rst==1'b1           ? 1'b0                : 
                                   slverr_burst);
      end
   end else begin : USES_RMW
      wire   slverr_iecc_set;
      wire   slverr_iecc_burst;
      assign port_snf_status = |(wport_num_oh & e_snf_mode);
      assign slverr_set  = (((|wpar_err & (reg_ddrc_par_wdata_slverr_en | reg_ddrc_ocecc_wdata_slverr_en))) & err_valid);
      assign slverr_iecc_set  = (( wptr_q_wr_addr_err) & err_valid) | ( ~port_snf_status & slverr_set );
      assign slverr_iecc_burst  = slverr_iecc_set | (|(slverr_burst_r & wport_num_oh));
      always @(*) begin: write_error_COMB_PROC
         integer sel;
         for (sel=0; sel<NPORTS; sel=sel+1)
            slverr_burst_w[sel] = (wport_num_oh[sel]==1'b0 ? slverr_burst_r[sel] : 
                                   err_rst==1'b1           ? 1'b0                : 
                                   slverr_iecc_burst);
      end
      assign slverr_burst  = slverr_set | slverr_iecc_burst;
   end
   endgenerate


   // -----------------------------------
   // Write data pointer return queue (wptrq)
   // -----------------------------------
   assign wptrq_wr = hif_wdata_ptr_valid;

   assign wptrq_rd = wdata_valid & ~wdata_stall_i & wdata_end;

    DWC_ddr_umctl2_gfifo
    
     #(
       .WIDTH           (WDATA_PTR_QW),
       .DEPTH           (WDATA_PTR_QD),
       .ADDR_WIDTH      (WDATA_PTR_QD_LG2),
       .COUNT_WIDTH     (WDATA_PTR_QD_LG2 + 1),
       .OCCAP_EN        (OCCAP_EN),
       .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)       
       ) 
   U_wptrq (
            .clk             (clk),
            .rst_n           (rst_n),
            .wr              (wptrq_wr),  
            .d               (wptrq_d),
            .rd              (wptrq_rd),  
            .par_en          (reg_ddrc_occap_en),
            .init_n          (1'b1),
            //spyglass disable_block W528
            //SMD: A signal or variable is set but never read
            //SJ: Used in RTL assertion
            .ff              (wptrq_full),
            //spyglass enable_block W528
            .wcount          (wptrq_wcount_unused), 
            .q               (wptrq_q),
            .fe              (wptrq_empty),            
            .par_err         (wptrq_par_err)
            `ifdef SNPS_ASSERT_ON
            `ifndef SYNTHESIS
            ,.disable_sva_fifo_checker_rd (1'b0)
            ,.disable_sva_fifo_checker_wr (1'b0)
            `endif // SYNTHESIS
            `endif // SNPS_ASSERT_ON
            );
            
   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read - e_wrb_wexa_acc_lock
   //SJ: Used in RTL assertion
   generate 
   if (ADDR_ERR_EN == 1) begin: GEN_wr_addr_err
      // Pass write address error along with wdata_ptr, through FIFO
      assign wptrq_d = {hif_wr_addr_err,hif_wdata_ptr};         
      // Decode the write data pointer queue.
      assign { wptr_q_wr_addr_err,wptr_q_awlast,wptr_q_awvalid_iecc_unused,wptr_q_awlast_iecc_unused,e_wrb_wexa_resp,e_wrb_wexa_acc,e_wrb_wexa_acc_lock,wptrq_q_bid,wptrq_q_user,wptrq_q_poison,wptrq_q_ocpar_err,wport_num} = wptrq_q;
   end 
   else begin: GEN_no_wr_addr_err
      assign wptrq_d = {hif_wdata_ptr};   
      // Decode the write data pointer queue.
      assign { wptr_q_awlast,wptr_q_awvalid_iecc_unused,wptr_q_awlast_iecc_unused,e_wrb_wexa_resp,e_wrb_wexa_acc,e_wrb_wexa_acc_lock,wptrq_q_bid,wptrq_q_user,wptrq_q_poison,wptrq_q_ocpar_err,wport_num} = wptrq_q;
      assign wptr_q_wr_addr_err = 1'b0;
   end 
   endgenerate
   //spyglass enable_block W528

   generate 
   if (NPORTS == 1) begin: GEN_wport_single_port
      assign wport_num_oh = 1'b1 << wport_num; // one-hot encode
   end
   else begin: GEN_wport_multiple_ports
      assign wport_num_oh = {{(NPORTS-1){1'b0}}, 1'b1} << wport_num; // one-hot encode
   end 
   endgenerate

//spyglass disable_block W415a
//SMD: Signals assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((sel * A_DW) + width)' found in module 'DWC_ddr_umctl2_hif_data'
//SJ: This coding style is acceptable and there is no plan to change it

   // -----------------------------------
   // Write data mux
   // -----------------------------------
   always @*
   begin: write_data_mux_COMB_PROC
      integer width, sel;

      wdata_last = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        wdata_last = wdata_last | (e_wlast[sel] & wport_num_oh[sel]);

      wdata_ready = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        wdata_ready = wdata_ready | (e_wready[sel] & wport_num_oh[sel]);


      wdata_valid = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        wdata_valid = wdata_valid | (e_wvalid[sel] & (e_bready[sel] |~bresp_wlast[sel]) & wport_num_oh[sel] & ~wptrq_empty);

      wdata_end = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        wdata_end = wdata_end | (e_wlast_pkt[sel] & wport_num_oh[sel]);

      wdata = {A_DW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<A_DW; width=width+1)
          wdata[width] = wdata[width] | (e_wdata[sel*A_DW + width] & wport_num_oh[sel]);

      wdata_mask = {A_STRBW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<A_STRBW; width=width+1)
          wdata_mask[width] = wdata_mask[width] | (e_wstrb[sel*A_STRBW + width] & wport_num_oh[sel]);

      wparity = {A_PARW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<A_PARW; width=width+1)
          wparity[width] = wparity[width] | (e_wparity[sel*A_PARW + width] & wport_num_oh[sel]);

      wpar_err = {A_STRBW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<A_STRBW; width=width+1)
          wpar_err[width] = wpar_err[width] | (e_wpar_err[sel*A_STRBW + width] & wport_num_oh[sel]);

   end
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W415a


   assign wdata_mask_masked = (wexa_strb | wptrq_q_poison | wptrq_q_ocpar_err) ? 
                            //`ifdef DDRCTL_UMCTL5
                                       (reg_ddrc_data_bus_width == HBW) ? ERRMASK_A_HBW : 
                                       (reg_ddrc_data_bus_width == QBW) ? ERRMASK_A_QBW :
                            //`endif           
                                                                                {A_STRBW{1'b0}} 
                                                                                : wdata_mask;

   generate
      if (WDATA_RETIME==1) begin: WDATA_pipeline


         wire [WDATA_RETIME_WIDTH-1:0] wdatar_d, wdatar_q;
         wire wdatar_rd, wdatar_wr, wdatar_empty, wdatar_full;

         assign wdatar_d = {wdata,wdata_mask_masked,wparity,wdata_end};

         assign wdatar_wr = wdata_valid;

         DWC_ddr_umctl2_retime
         
         #(
            .SIZE     (WDATA_RETIME_WIDTH),
            .OCCAP_EN (OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
          ) 
         U_wdata_retime
         (
            .clk         (clk),    
            .rst_n       (rst_n),    
            .d           (wdatar_d),
            .wr          (wdatar_wr),
            .rd          (wdatar_rd),
            .par_en      (reg_ddrc_occap_en),
            .q           (wdatar_q),
            .fe          (wdatar_empty),
            .ff          (wdatar_full),
            .par_err     (wdatar_par_err)
         );

         assign wdatar_rd = ~hif_wdata_stall & wdata_valid_i;
         assign {wdata_i,wdata_mask_i,wparity_i,wdata_end_i} = wdatar_q;

         assign wdata_valid_i = ~wdatar_empty;

         assign wdata_stall_i = wdatar_full;


      end
      else begin: WDATA_comb

         assign wdatar_par_err= 1'b0;
         assign wdata_valid_i = wdata_valid;
         assign wdata_end_i   = wdata_end;
         assign wdata_i       = wdata;
         assign wdata_mask_i  = wdata_mask_masked;
         assign wparity_i     = wparity;
         assign wdata_stall_i = hif_wdata_stall;

      end
   endgenerate

   assign hif_wdata_valid  = wdata_valid_i;
   assign hif_wdata_end    = wdata_end_i;
   assign hif_wdata        = wdata_i;
   assign hif_wdata_mask   = wdata_mask_i;
   assign hif_wdata_parity = wparity_i;




   // -----------------------------------
   // Write data demux
   // -----------------------------------
   // Accept write data only the following 3 conditions are met:
   // * DDRC is not applying pressure hif_wdata_stall
   // * Write pointer queue is not empty
   // * XPI write response queue is not full when accepting the last write beat
   assign e_wready = {(NPORTS){~wdata_stall_i & ~wptrq_empty}} & (e_bready|~bresp_wlast) & wport_num_oh;

   // ----------------------------------------------------------------------------------------------
   // XPI Write response
   //
   // All DDRC transactions that are part of an AXI Exclusive Write transactions are sent to the 
   // DDRC in sequence. This is a requirment to prevent a write from another port accessing the 
   // monitored address range. 
   //
   // The exclusive monitor returns and EXOKAY for the first DDRC exclusive transaction and OKAY 
   // for the remaining transactions. Hence the EXOKAY response type must be held until the last 
   // data beat is detected for the exclusive write transaction. 
   // ----------------------------------------------------------------------------------------------
   generate 
   if (EXA_ACC_SUPPORT==1) begin: EX

      wire exa_bresp_r;
      wire wexa_strb_r; 
      reg exa_bresp_nxt;
      reg wexa_strb_nxt;

      always @(*) begin: wexa_COMB_PROC
         exa_bresp_nxt = exa_bresp_r;
         wexa_strb_nxt = wexa_strb_r;
         if (wdata_valid & wdata_last & wdata_ready) begin
            exa_bresp_nxt = 1'b0;
            wexa_strb_nxt = 1'b0;
         end else if (wdata_valid & ~wdata_last & wdata_ready & e_wrb_wexa_acc) begin
            exa_bresp_nxt = wptrq_q_bresp;
            wexa_strb_nxt = ~wptrq_q_bresp;
         end
      end

      assign par_vec_i = {par_vec_nex_i,exa_bresp_nxt,wexa_strb_nxt};
      assign {par_vec_nex_r,exa_bresp_r,wexa_strb_r} = par_vec_r;

      // Generate XPI Write Response - always OKAY unless exclusive write transaction returns EXOKAY
      assign wptrq_q_bresp = (e_wrb_wexa_resp & e_wrb_wexa_acc & ~wptrq_empty);
      // Generate EXOKAY response for passing exclusive transactions otherwise OKAY.
      // If First DDRC transaction of an AXI Exclusive transaction returns EXOKAY then return EXOKAY to XPI
      assign e_bresp   = ((e_wrb_wexa_resp & e_wrb_wexa_acc)  | exa_bresp_r)? {(NPORTS){EXOKAY}} :  {(NPORTS){wptrq_q_bresp}};
      // Generate Write data Strobing - If Exclusive write does not return EXOKAY
      // If First DDRC transaction of an AXI Exclusive transaction returns OKAY then strobe all data beats pretaining to this 
      // Exclusive write transaction.
      assign wexa_strb = ((~e_wrb_wexa_resp & e_wrb_wexa_acc) | wexa_strb_r);

 `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
         reg [A_NPORTS_LG2-1:0] prev_port_granted;
         wire excl_not_last_granted;
         reg excl_not_last_granted_r;

         assign excl_not_last_granted = e_wrb_wexa_acc_lock & ~wdata_last & wdata_valid;

         always @(posedge clk or negedge rst_n) begin
            if (~rst_n) begin
               prev_port_granted <= {A_NPORTS_LG2{1'b0}};
               excl_not_last_granted_r <= 1'b0;
            end
            else begin
               if (wdata_valid) begin
                  prev_port_granted <= wport_num;
                  excl_not_last_granted_r <= excl_not_last_granted;
               end
            end
         end

         
          property p_wstrb_excl_wr;
         @(posedge clk) disable iff(!rst_n) 
            (wexa_strb && wdata_valid) |-> (e_wrb_wexa_acc_lock);
         endproperty

         a_wstrb_excl_wr : assert property (p_wstrb_excl_wr) else 
         $display("-> %0t ERROR: [hif_data] Data strobed for normal write", $realtime);

         property p_wgrant_switch_when_excl;
         @(posedge clk) disable iff(!rst_n)
            (excl_not_last_granted_r && wdata_valid) |-> (wport_num==prev_port_granted);
         endproperty

         a_wgrant_switch_when_excl : assert property (p_wgrant_switch_when_excl) else
         $display("-> %0t ERROR: [hif_data] Grant switched from exclusive to normal before last exclusive burst sent",$realtime);


    `endif
  `endif

   end // EX
   else begin: EXA_nen

      assign par_vec_i     = par_vec_nex_i;
      assign par_vec_nex_r = par_vec_r;
      assign wexa_strb     = 1'b0;
      // always OKAY in non EXA configs
      assign wptrq_q_bresp = 1'b0;
      assign e_bresp       = {(NPORTS){wptrq_q_bresp}};

   end // EXA_nen
   endgenerate
   
   // Generate valid write response to XPI when last data beat detected. 
   assign e_bvalid   = e_wvalid & bresp_wlast & e_wready;
   assign e_bid      = {(NPORTS){wptrq_q_bid}};
   assign e_buser    = {(NPORTS){wptrq_q_user}};

   // on-chip parity XPI error
   assign wptrq_q_ocpar_err_i = wptrq_q_ocpar_err & reg_ddrc_par_addr_slverr_en; // address error
   // AXI poison error and intr
   assign wr_poison_intr_nxt =                     (reg_ddrc_wr_poison_intr_clr) ? {NPORTS{1'b0}} :
                       (wptrq_q_poison & err_valid & reg_ddrc_wr_poison_intr_en) ? wport_num_oh | wr_poison_intr : wr_poison_intr_r;

   assign wr_poison_intr = wr_poison_intr_r;

   assign wptrq_q_poison_i    = wptrq_q_poison & reg_ddrc_wr_poison_slverr_en;
   // poison, ocpar and wr_addr error cause slverr response
   assign wptrq_slverr = wptrq_q_poison_i | wptrq_q_ocpar_err_i | slverr_burst;

   assign e_aw_slverr = {(NPORTS){wptrq_slverr}};

   // -----------------------------------
   // Read data demux
   // -----------------------------------
   // First extract the read data port number from read data response
   assign rport_num = hif_rdata_token[A_NPORTS_LG2-1:0];

   generate 
      if (NPORTS == 1) begin: GEN_rport_single_port
         assign rport_num_oh = 1'b1 << rport_num; // one-hot encode
      end 
      else begin: GEN_rport_multiple_ports
         assign rport_num_oh = {{(NPORTS-1){1'b0}}, 1'b1} << rport_num; // one-hot encode
      end 
   endgenerate

      
   assign e_rvalid         = {(NPORTS){hif_rdata_valid}} & rport_num_oh;
   assign e_rdata          = {(NPORTS){hif_rdata}};
   assign e_rdata_parity   = {(NPORTS){hif_rdata_parity}};
   assign e_rlast_pkt      = {(NPORTS){hif_rdata_end}};
   assign e_resp_token     = {(NPORTS){hif_rdata_token}};
   assign rerror           = hif_rdata_uncorr_ecc_err | hif_rd_addr_err | hif_rdata_crc_err | hif_rdata_eapar_err | hif_rdata_uncorr_linkecc_err;
   assign e_rerror         = {(NPORTS){rerror}};

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  
  genvar j;
  generate
  for (j=0; j<NPORTS; j=j+1) begin: POISON_INTR_check
   poison_intr_cleared: assert property (@(posedge clk) disable iff (!rst_n) (wr_poison_intr[j]==1'b1 && reg_ddrc_wr_poison_intr_clr==1'b0 |-> ##1 wr_poison_intr[j]==1'b1)) else $display("[%0t] ERROR: Poison interrupt has been cleared but clear register not set",$time);
   poison_intr_not_asserted: assert property (@(posedge clk) disable iff (!rst_n) (reg_ddrc_wr_poison_intr_en==1'b1 && reg_ddrc_wr_poison_intr_clr==1'b0 && wptrq_q_poison==1'b1 && err_valid==1'b1 && wport_num==j |-> ##1  wr_poison_intr[j]==1'b1)) else $display("[%0t] ERROR: Poison interrupt has to be asserted after error pulse is received",$time);   
  end
  endgenerate
   
   
  // WPTRQ must be not full when a pointer is pushed 
  property p_wptrq_push_full;
    @(posedge clk) disable iff(!rst_n) 
      (wptrq_wr) |-> (~wptrq_full);
  endproperty 
  a_wptrq_push_full : assert property (p_wptrq_push_full) else 
    $display("-> %0t ERROR: [hif_data] Write data pointer return queue (U_wptrq) overflow", $realtime);

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule // DWC_ddr_umctl2_hif_data
