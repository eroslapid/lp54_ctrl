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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa_preproc.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               PA preprocessor for the port requests.
//               It includes:
//               * priority comparator
//               * implements all the arbitration policies on incoming
//                 requests, including read-write arbitration
//               * filters all pending requests and passes on the next
//                 request to be granted (based on arbitration policies)
//                 to the round-robin arbiter stage
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa_preproc
  #(
    parameter NPORTS                   = 1,
    parameter PORT_PRIORITYW           = 5,
    parameter EXT_PORTPRIO             = 0,
    parameter DUAL_PA                  = 0,
    parameter PAGEMATCH_EN             = 1,
    parameter DATA_CHANNEL_INTERLEAVE  = 0,
    parameter MEMC_INLINE_ECC          = 0,
    parameter HIF_CREDIT_BITS          = 1,
    parameter PA_OPT_TYPE              = 1,
    parameter OCCAP_EN                 = 0,
    parameter OCCAP_PIPELINE_EN        = 0,
    parameter CRDT_CNT_WIDTH           = 7
    )
   (
    input                              clk,
    input                              rst_n,

    // Register interface
    input                              reg_pagematch_limit,
    input                              lpr_num_entries_changed,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block. 
    input                              ie_ecc_enabled,

    // HIF Command Flow Control Interface
    input [HIF_CREDIT_BITS-1:0]        hif_hpr_credit,
    input [HIF_CREDIT_BITS-1:0]        hif_lpr_credit,
    input                              hif_wr_credit,  
    input [1:0]                        hif_wrecc_credit,
  
    // Write ports
    input                              wswitch_states_en,
    
    input [NPORTS-1:0]                 wgrant_nxt,
    input [NPORTS-1:0]                 wreq,
    input [NPORTS-1:0]                 wreq_last,
    input [NPORTS-1:0]                 wreq_exa_lock,

    input [NPORTS-1:0]                 wreq_iecc_lock,

    input [NPORTS-1:0]                 wpagematch,
    input [NPORTS-1:0]                 wpriority0,
    input [NPORTS*PORT_PRIORITYW-1:0]  wport_priority,
    input [NPORTS-1:0]                 rmw_dynamic,    
    output reg [NPORTS-1:0]            wreq_pp,
    output [NPORTS-1:0]                wgrant_hold,
    output                             wreq_locked,
    // Read ports
    input                              rswitch_states_en,
    input [NPORTS-1:0]                 rgrant,
    input [NPORTS-1:0]                 rgrant_nxt,
    input                              rgrant_en,
    input [NPORTS-1:0]                 rreq,
    input [NPORTS-1:0]                 rpagematch,
    input [NPORTS-1:0]                 xa_rpri,
    input [NPORTS-1:0]                 rpriority0,
    input [NPORTS*PORT_PRIORITYW-1:0]  rport_priority,
    input [NPORTS-1:0]                 rreq_iecc_lock,
//spyglass enable_block W240
    output reg [NPORTS-1:0]            rreq_pp,
    output [NPORTS-1:0]                rgrant_hold,
    output                             rreq_locked,

    input                              reg_ddrc_occap_en,
    output                             pa_preproc_parity_err,
    
    // Performance monitor interface
    output                             perf_hpr_req_with_nocredit,
    output                             perf_lpr_req_with_nocredit,
    
     // Credit Counters
    output [CRDT_CNT_WIDTH-1:0]        lpr_credit_cnt, 
    output [CRDT_CNT_WIDTH-1:0]        hpr_credit_cnt, 
    output [CRDT_CNT_WIDTH-1:0]        wr_credit_cnt,
    output [CRDT_CNT_WIDTH-1:0]        wrecc_credit_cnt);

   localparam WPMTCH_CNT_W = 3;
   localparam [WPMTCH_CNT_W-1:0] FOUR_LIMIT = 3;
   

   
   // Read/write FSM parameters and variables
   localparam ST_RW_SIZE   = 2;
   localparam [ST_RW_SIZE-1:0] ST_RW_R      = 2'b01;  // Read
   localparam [ST_RW_SIZE-1:0] ST_RW_W      = 2'b10;  // Write
                                 // This third state is added for single port configurations only,
                                 // in order to support reduced latency asynchronous BCM FIFOs
   localparam  IDLE     = 0,
               ACTIVE   = 1;
  // State bitfields
   localparam STBF_RW_R = 0;
   localparam STBF_RW_W = 1;

   // exa lock
   localparam ST_WLOCK_SIZE = 2;  

   localparam [ST_WLOCK_SIZE-1:0] ST_WLOCK_UL  = 2'b01;   // unlocked request
   localparam [ST_WLOCK_SIZE-1:0] ST_WLOCK_L   = 2'b10;   // locked request
   

  // Bitfields of the FSM that are useful
   localparam STBF_WLOCK_UL  = 0;
   localparam STBF_WLOCK_L   = 1;

   // write pm lock
   localparam ST_WRPMLOCK_SIZE = 2;   // Write Page Match Lock
   
   localparam [ST_WRPMLOCK_SIZE-1:0] ST_WRPMLOCK_UL  = 2'b01;   // unlocked request
   localparam [ST_WRPMLOCK_SIZE-1:0] ST_WRPMLOCK_L   = 2'b10;   // locked request

  // Bitfields of the FSM that are useful
   localparam STBF_WRPMLOCK_UL  = 0;
   localparam STBF_WRPMLOCK_L   = 1;

   // read pm lock
   localparam ST_RDPMLOCK_SIZE = 2;   // Read Page Match Lock
   
   localparam [ST_RDPMLOCK_SIZE-1:0] ST_RDPMLOCK_UL  = 2'b01;   // unlocked request
   localparam [ST_RDPMLOCK_SIZE-1:0] ST_RDPMLOCK_L   = 2'b10;   // locked request

  // Bitfields of the FSM that are useful
   localparam STBF_RDPMLOCK_UL  = 0;
   localparam STBF_RDPMLOCK_L   = 1;

   localparam PA_CRDT_VEC_WIDTH = CRDT_CNT_WIDTH*3;

   localparam PA_PAR_VEC_W_NDP      = 1+1+NPORTS*5+WPMTCH_CNT_W*2+1+1+ST_WLOCK_SIZE+ST_WRPMLOCK_SIZE+ST_RDPMLOCK_SIZE;
   localparam PA_PAR_VEC_NDP_RESVAL = {{(PA_PAR_VEC_W_NDP-ST_WLOCK_SIZE-ST_WRPMLOCK_SIZE-ST_RDPMLOCK_SIZE-WPMTCH_CNT_W*2){1'b0}},FOUR_LIMIT,FOUR_LIMIT,ST_WLOCK_UL,ST_WRPMLOCK_UL,ST_RDPMLOCK_UL};
   localparam PA_PAR_VEC_WIDTH      = PA_PAR_VEC_W_NDP+(DUAL_PA==0 ? ST_RW_SIZE : 0);
   localparam PA_PAR_VEC_RESVAL     = (DUAL_PA==0) ? {PA_PAR_VEC_NDP_RESVAL,ST_RW_R} : PA_PAR_VEC_NDP_RESVAL;
   
   wire [NPORTS-1:0] wr_credit_decr_v, lpr_credit_decr_v, lpr_rd_credit_decr_v, lpr_rmw_credit_decr_v, hpr_credit_decr_v;
   wire              wr_credit_decr, lpr_credit_decr, lpr_rd_credit_decr, lpr_rmw_credit_decr, hpr_credit_decr, hpr_credit_cnt_gt_1, hpr_credit_cnt_gt_0;
   wire              wr_credit_avail, lpr_credit_avail, lpr_rmw_credit_avail, hpr_credit_avail, rd_credit_avail, lpr_credit_cnt_gt_1, lpr_credit_cnt_gt_0;
   wire              wr_credit_avail_simplified, wr_credit_cnt_gt_0;
   wire              lpr_credit_gt_min, hpr_credit_gt_min, wr_credit_gt_min;
   reg [NPORTS-1:0]  rd_pri_credit_avail, wr_rmw_credit_avail;
   wire [NPORTS-1:0] rreq_pri0_withcredit, rreq_pri0_withcredit_pm, rreq_withcredit, wreq_pri0_withcredit, wreq_pri0_withcredit_pm, wreq_withcredit;
   wire              rreq_pri0_withcredit_any, rreq_pri0_withcredit_pm_any, rreq_withcredit_any, wreq_pri0_withcredit_any, wreq_pri0_withcredit_pm_any, wreq_withcredit_any;
   wire [NPORTS-1:0] rreq_hpr, rreq_hpr_pm, rreq_lpr, rreq_lpr_pm ;
   wire              rreq_hpr_any, rreq_hpr_pm_any, rreq_any, rreq_lpr_any, rreq_lpr_pm_any;
   wire [NPORTS-1:0] rport_lpr_mask, rport_hpr_mask, wport_mask;
   wire [NPORTS-1:0] rreq_mask_lpr, rreq_mask_hpr, wreq_mask;
   wire              read_en, write_en;
   wire              perf_hpr_req_with_nocredit_i, perf_lpr_req_with_nocredit_i;
   
   wire [NPORTS-1:0]  wgrant_nxt_saved_nxt, wgrant_nxt_saved_nxt2;
   reg [NPORTS-1:0]  wreq_hold_nxt;
   wire [NPORTS-1:0]  wgrant_nxt_saved, wreq_hold;
   wire [NPORTS-1:0] wreq_same_withlock, wreq_withlockfilter, wreq_granted_withlock, wreq_sameholded_withlock;
   wire              wreq_sameholded_withlock_any, wreq_granted_withlock_any;

   wire              any_lock_on_writes;

   wire [NPORTS-1:0] wreq_granted_withpmatch, wreq_sameholded_withpmatch, wreq_same_withpmatch;
   wire [NPORTS-1:0] wreq_withpmatchfilter, wreq_withpmatch;
   wire [NPORTS-1:0]  wreq_withpmatch_r;
   wire              wreq_granted_withpmatch_any, wreq_sameholded_withpmatch_any;
   wire [WPMTCH_CNT_W-1:0] wpmatch_cnt;
   reg [WPMTCH_CNT_W-1:0] wpmatch_cnt_nxt;
   wire [NPORTS-1:0] wreq_pri0_nf;
   wire              wreq_pri0_nf_any;
   wire              wpmatch_limit,wpmatch_limit_nxt;
   wire              wpmatch_limit_r;

   wire [NPORTS-1:0]  rgrant_nxt_saved_nxt, rgrant_nxt_saved_nxt2;
   wire [NPORTS-1:0]  rgrant_nxt_saved;
   wire [NPORTS-1:0] rreq_granted_withpmatch;
   wire [NPORTS-1:0] rreq_withpmatch, rreq_withpmatchfilter;
   wire [NPORTS-1:0]  rreq_withpmatch_r;
   wire              rreq_granted_withpmatch_any;
   wire [WPMTCH_CNT_W-1:0] rpmatch_cnt;
   reg [WPMTCH_CNT_W-1:0] rpmatch_cnt_nxt;
   wire [NPORTS-1:0] rreq_pri0_nf;
   wire              rreq_pri0_nf_any;
   wire              rpmatch_limit,rpmatch_limit_nxt;
   wire              rpmatch_limit_r;
   wire              adtl_credit_for_wr, adtl_credit_for_hpr, adtl_credit_for_lpr;

   wire [ST_WLOCK_SIZE-1:0] st_wlock;
   reg [ST_WLOCK_SIZE-1:0] st_wlock_nxt;

   wire [ST_WRPMLOCK_SIZE-1:0] st_wrpmlock;
   reg [ST_WRPMLOCK_SIZE-1:0] st_wrpmlock_nxt;   
   wire  st_wrpmlock_nxt_enabled;

   wire [ST_RDPMLOCK_SIZE-1:0] st_rdpmlock;
   reg [ST_RDPMLOCK_SIZE-1:0] st_rdpmlock_nxt;   
   wire  st_rdpmlock_nxt_enabled;

   wire              rst_credit_cnt;

   wire              credit_vec_parity_err, par_vec_parity_err;

   wire              wrecc_credit_parity_err_unused; // TODO connect (OR) to pa_preproc_parity_err

   wire [PA_CRDT_VEC_WIDTH-1:0] credit_vec_i, credit_vec_r;

   wire [PA_PAR_VEC_W_NDP-1:0] pa_par_vec_ndp_i, pa_par_vec_ndp_r;
   wire [PA_PAR_VEC_WIDTH-1:0] pa_par_vec_i, pa_par_vec_r;

   assign pa_preproc_parity_err = credit_vec_parity_err | par_vec_parity_err;

   // credit counters
   wire [CRDT_CNT_WIDTH-1:0] lpr_credit_cnt_r, hpr_credit_cnt_r, wr_credit_cnt_r;
   reg [CRDT_CNT_WIDTH-1:0] lpr_credit_cnt_nxt, hpr_credit_cnt_nxt, wr_credit_cnt_nxt;   

   // credit vector
   assign credit_vec_i = {lpr_credit_cnt_nxt,hpr_credit_cnt_nxt,wr_credit_cnt_nxt};
   assign {lpr_credit_cnt_r,hpr_credit_cnt_r,wr_credit_cnt_r} = credit_vec_r;

   // parity vector (other registers)
   assign pa_par_vec_ndp_i = {perf_hpr_req_with_nocredit_i,perf_lpr_req_with_nocredit_i,wgrant_nxt_saved_nxt,wreq_hold_nxt,wreq_withpmatch,rreq_withpmatch,wpmatch_limit_nxt,rpmatch_limit_nxt,rgrant_nxt_saved_nxt
            ,rpmatch_cnt_nxt,wpmatch_cnt_nxt,st_wlock_nxt,st_wrpmlock_nxt,st_rdpmlock_nxt}; // leave non-zero reset fields at the LSB
   assign {perf_hpr_req_with_nocredit,perf_lpr_req_with_nocredit,wgrant_nxt_saved,wreq_hold,wreq_withpmatch_r,rreq_withpmatch_r,wpmatch_limit_r,rpmatch_limit_r,rgrant_nxt_saved
           ,rpmatch_cnt,wpmatch_cnt,st_wlock,st_wrpmlock,st_rdpmlock} = pa_par_vec_ndp_r; // leave non-zero reset fields at the LSB

   integer i; // for loop index


   
   assign lpr_credit_cnt   = lpr_credit_cnt_r;
   assign hpr_credit_cnt   = hpr_credit_cnt_r;
   assign wr_credit_cnt    = wr_credit_cnt_r;

   assign rreq_locked      = 1'b0;
   // reset the credit counter when lpr_num_entries is changed (needs to be in synch with ih block)
   assign rst_credit_cnt = lpr_num_entries_changed;

   // credit counters support signals
   
   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read
   //SJ: Used in generate statement and therefore must always exist.
   assign lpr_credit_cnt_gt_1       = (lpr_credit_cnt_r>1) ? 1'b1 : 1'b0;
   assign hpr_credit_cnt_gt_1       = (hpr_credit_cnt_r>1) ? 1'b1 : 1'b0;
   //spyglass enable_block W528
   assign lpr_credit_cnt_gt_0       = |(lpr_credit_cnt_r);
   assign hpr_credit_cnt_gt_0       = |(hpr_credit_cnt_r);
   assign wr_credit_cnt_gt_0        = (|wr_credit_cnt_r);
   
   
   // ----------------------------------------------
   // Write credit counter
   // Decrement credit cnt per write grants sent out
   // ----------------------------------------------
   assign wr_credit_decr_v = wgrant_nxt;
   assign wr_credit_decr   = |wr_credit_decr_v;
   
   // For RMW the write command is issued after checking
   // the availability of read and write credits
   assign wr_credit_avail = (|(rmw_dynamic & wreq_withpmatchfilter)) ? (wr_credit_gt_min & lpr_rmw_credit_avail) : (wr_credit_gt_min & adtl_credit_for_wr);
   assign wr_credit_avail_simplified = wr_credit_gt_min;
                                     
   // Selective write credit availability based on RMW
   always @*
   begin: wr_rmw_credit_avail_COMB_PROC
      for (i=0; i<NPORTS; i=i+1)
        wr_rmw_credit_avail[i] = (rmw_dynamic[i]) ? (wr_credit_gt_min & lpr_rmw_credit_avail) : (wr_credit_gt_min & adtl_credit_for_wr);
   end
  
   // ----------------------------------------------
   // Read credit counters
   // Decrement credit cnt per read grants sent out
   // ----------------------------------------------
   assign lpr_rd_credit_decr_v   = (rgrant_nxt & ~xa_rpri);
   assign lpr_rd_credit_decr     = |lpr_rd_credit_decr_v;
   assign lpr_rmw_credit_decr_v  = (rmw_dynamic & wgrant_nxt);
   assign lpr_rmw_credit_decr    = |lpr_rmw_credit_decr_v;
   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read
   //SJ: Used in generate statement and therefore must always exist.
   assign lpr_credit_decr        = lpr_rd_credit_decr | lpr_rmw_credit_decr;
   assign hpr_credit_decr        = |hpr_credit_decr_v;   
   //spyglass enable_block W528
   assign hpr_credit_decr_v      = (rgrant_nxt & xa_rpri);

   // credit counters registers
   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (PA_CRDT_VEC_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .SL_W    (8))
   U_pa_credit_vec_r
   (  .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (credit_vec_i),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (credit_vec_r),
      .parity_err (credit_vec_parity_err));

   // wr_credit_cnt next value
   always @(*) begin: wr_credit_cnt_COMB_PROC
      wr_credit_cnt_nxt = wr_credit_cnt_r;
      if (rst_credit_cnt)
         wr_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
      else if(hif_wr_credit & ~wr_credit_decr)
         wr_credit_cnt_nxt = wr_credit_cnt_r + 1'b1;
      else if(~hif_wr_credit & wr_credit_decr)
         wr_credit_cnt_nxt = wr_credit_cnt_r - 1'b1;
   end
   
   generate
   if (MEMC_INLINE_ECC==1) begin: IECC_en

      wire [CRDT_CNT_WIDTH-1:0] wrecc_credit_cnt_r;
      reg [CRDT_CNT_WIDTH-1:0] wrecc_credit_cnt_nxt;

      wire wrecc_credit_cnt_gt_0;
      wire [NPORTS-1:0] hpr_credit_decr_ie_v, wr_credit_decr_ie_v;
      wire  wr_credit_decr_ie, hpr_credit_decr_ie;

      assign hpr_credit_decr_ie_v   = hpr_credit_decr_v & rreq_iecc_lock;
      assign wr_credit_decr_ie_v    = wr_credit_decr_v & wreq_iecc_lock;

      assign hpr_credit_decr_ie     = |hpr_credit_decr_ie_v;
      assign wr_credit_decr_ie      = |wr_credit_decr_ie_v;

      assign wrecc_credit_cnt_gt_0  = (|wrecc_credit_cnt_r);

      always @(*) begin: hpr_credit_cnt_COMB_PROC
         hpr_credit_cnt_nxt = hpr_credit_cnt_r;
         casez ({rst_credit_cnt,hif_hpr_credit,hpr_credit_decr_ie,hpr_credit_decr})
            5'b1????:  hpr_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
            5'b0001?:  hpr_credit_cnt_nxt = hpr_credit_cnt_r - 2;
            5'b0011?:  hpr_credit_cnt_nxt = hpr_credit_cnt_r - 1;
            5'b0101?:  hpr_credit_cnt_nxt = hpr_credit_cnt_r - 1;
            5'b00001:  hpr_credit_cnt_nxt = hpr_credit_cnt_r - 1;
            5'b01101:  hpr_credit_cnt_nxt = hpr_credit_cnt_r + 1;
            5'b00100:  hpr_credit_cnt_nxt = hpr_credit_cnt_r + 1;
            5'b01000:  hpr_credit_cnt_nxt = hpr_credit_cnt_r + 1;
            5'b01100:  hpr_credit_cnt_nxt = hpr_credit_cnt_r + 2;
            default:  hpr_credit_cnt_nxt = hpr_credit_cnt_r;
         endcase
      end

      // wrecc credit counter
      DWC_ddr_umctl2_par_reg
      
      #(
         .DW      (CRDT_CNT_WIDTH),
         .OCCAP   (OCCAP_EN),
         .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
         .REG_EN  (0),
         .SL_W    (CRDT_CNT_WIDTH))
      U_pa_wrecc_credit_r // TODO add this to pgen/pcheck list in tb
      (  .clk        (clk),
         .rst_n      (rst_n),
         .data_in    (wrecc_credit_cnt_nxt),
         .reg_set    (1'b0),
         .parity_en  (reg_ddrc_occap_en),
         .poison_en  (1'b0),
         .data_out   (wrecc_credit_cnt_r),
         .parity_err (wrecc_credit_parity_err_unused));


      always @(*) begin: wrrecc_credit_cnt_COMB_PROC
         wrecc_credit_cnt_nxt = wrecc_credit_cnt_r;
         casez ({rst_credit_cnt,hif_wrecc_credit,wr_credit_decr_ie})
            4'b1???:  wrecc_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
            4'b0001:  wrecc_credit_cnt_nxt = wrecc_credit_cnt_r - 1;
            4'b0010:  wrecc_credit_cnt_nxt = wrecc_credit_cnt_r + 1;
            4'b0100:  wrecc_credit_cnt_nxt = wrecc_credit_cnt_r + 1;
            4'b0110:  wrecc_credit_cnt_nxt = wrecc_credit_cnt_r + 2;
            4'b0111:  wrecc_credit_cnt_nxt = wrecc_credit_cnt_r + 1;
            default:  wrecc_credit_cnt_nxt = wrecc_credit_cnt_r;
         endcase
      end
     
      assign wrecc_credit_cnt    = wrecc_credit_cnt_r;
      assign hpr_credit_gt_min   = ie_ecc_enabled ? hpr_credit_cnt_gt_1 : hpr_credit_cnt_gt_0;
      assign wr_credit_gt_min    = ie_ecc_enabled ? (wr_credit_cnt_gt_0 & wrecc_credit_cnt_gt_0) : wr_credit_cnt_gt_0;
      assign adtl_credit_for_wr  = 1'b1;
      assign adtl_credit_for_lpr = 1'b1;
      assign adtl_credit_for_hpr = 1'b1;

   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

         localparam CATEGORY = 5;
         assert_never #(0, 0, "WR credit overflow", CATEGORY) a_pa_wr_credit_overflow
         (clk, rst_n, (wr_credit_cnt_r==7'b1111111 && (wr_credit_decr==0 && hif_wr_credit==1)));

         assert_never #(0, 0, "WR ECC credit overflow", CATEGORY) a_pa_wrecc_credit_overflow
         (clk, rst_n, (wrecc_credit_cnt_r==7'b1111111 && (hif_wrecc_credit==2'b11 || (wr_credit_decr_ie==0 && hif_wrecc_credit!=0))));


   `endif
   `endif

   end
   else begin: IECC_dis

      // high priority read credit count
      always @(*) begin: hpr_credit_cnt_COMB_PROC
         hpr_credit_cnt_nxt = hpr_credit_cnt_r;
         if (rst_credit_cnt)
            hpr_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
         else if(hif_hpr_credit & ~hpr_credit_decr)
            hpr_credit_cnt_nxt = hpr_credit_cnt_r + 1'b1;
         else if(~hif_hpr_credit & hpr_credit_decr)
            hpr_credit_cnt_nxt = hpr_credit_cnt_r - 1'b1;
      end

      assign hpr_credit_gt_min         = hpr_credit_cnt_gt_0;
      assign wr_credit_gt_min          = wr_credit_cnt_gt_0;
      assign adtl_credit_for_wr        = 1'b1;
      assign adtl_credit_for_lpr       = 1'b1;
      assign adtl_credit_for_hpr       = 1'b1;
      assign wrecc_credit_cnt          = {CRDT_CNT_WIDTH{1'b0}};
      assign wrecc_credit_parity_err_unused = 1'b0;

   end
   endgenerate

   // Read credits are available
   assign lpr_credit_avail          = lpr_credit_gt_min & adtl_credit_for_lpr;
   assign hpr_credit_avail          = hpr_credit_gt_min & adtl_credit_for_hpr;
   assign rd_credit_avail           = lpr_credit_avail | hpr_credit_avail;

   // Selective read credit availability based on the read priority
   always @*
   begin: rd_pri_credit_avail_COMB_PROC
      for (i=0; i<NPORTS; i=i+1)
        rd_pri_credit_avail[i]   = (xa_rpri[i]) ? hpr_credit_avail : lpr_credit_avail;
   end

   assign rreq_pri0_withcredit      = rpriority0 & rreq & rd_pri_credit_avail;
   assign rreq_pri0_withcredit_any  = |rreq_pri0_withcredit;

   assign rreq_pri0_withcredit_pm     = rpriority0 & rreq_withpmatchfilter & rd_pri_credit_avail;
   assign rreq_pri0_withcredit_pm_any = |rreq_pri0_withcredit_pm;

   assign rreq_withcredit           = rreq_withpmatchfilter & rd_pri_credit_avail;
   
   assign rreq_hpr                  = rreq & xa_rpri;
   assign rreq_hpr_any              = |rreq_hpr;

   assign rreq_hpr_pm               = rreq_withpmatchfilter & xa_rpri;
   assign rreq_hpr_pm_any           = |rreq_hpr_pm;

   assign rreq_lpr_pm               = rreq_withpmatchfilter & ~xa_rpri;
   assign rreq_lpr_pm_any           = |rreq_lpr_pm;

   assign rreq_lpr                  = rreq & ~xa_rpri;
   
   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read
   //SJ: Used in generate statement and therefore must always exist.
   assign rreq_lpr_any              = |rreq_lpr;
   assign rreq_withcredit_any       = |rreq_withcredit;
   assign rreq_any                  = |rreq_withpmatchfilter;
   assign wreq_withcredit_any       = |wreq_withcredit;
   //spyglass enable_block W528
   
   assign wreq_pri0_withcredit      = wpriority0 & wreq_withlockfilter & wr_rmw_credit_avail;
   assign wreq_pri0_withcredit_any  = |wreq_pri0_withcredit;
   
   assign wreq_pri0_withcredit_pm     = wpriority0 & wreq_withpmatchfilter & wr_rmw_credit_avail;
   assign wreq_pri0_withcredit_pm_any = |wreq_pri0_withcredit_pm;

   assign wreq_withcredit           = wreq_withpmatchfilter & wr_rmw_credit_avail;
   
   generate
      if (DUAL_PA == 1) begin: RDWR_FSM_disabled 
         // Low priority read counter
         always @(*) begin: lpr_credit_cnt_COMB_PROC
            lpr_credit_cnt_nxt = lpr_credit_cnt_r;
            casez ({rst_credit_cnt,hif_lpr_credit,lpr_rd_credit_decr,lpr_rmw_credit_decr})
               4'b1???:  lpr_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
               4'b0001:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
               4'b0010:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
               4'b0011:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 2;
               4'b0100:  lpr_credit_cnt_nxt = lpr_credit_cnt_r + 1;
               4'b0111:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
               default:  lpr_credit_cnt_nxt = lpr_credit_cnt_r;
            endcase
         end

         assign lpr_credit_gt_min      = (|rmw_dynamic & rreq_lpr_any) ? lpr_credit_cnt_gt_1 : lpr_credit_cnt_gt_0;
         assign lpr_rmw_credit_avail   = lpr_credit_gt_min;

         // with the dual HIF read and write can be granted at the same time
         assign write_en           = ACTIVE;
         assign read_en            = ACTIVE;

         assign pa_par_vec_i = pa_par_vec_ndp_i;
         assign pa_par_vec_ndp_r = pa_par_vec_r;

      end else begin: RDWR_FSM_enabled
         wire [ST_RW_SIZE-1:0] st_rw;
         reg [ST_RW_SIZE-1:0] st_rw_nxt;
         // ----------------------------------------------
         // Read/Write arbiter state machine
         // ----------------------------------------------
         always @(*) begin: st_rw_nxt_COMB_PROC
          st_rw_nxt = ST_RW_R;
          case (st_rw)
            ST_RW_R: begin
               if (rd_credit_avail) begin
                  if (rreq_pri0_withcredit_pm_any)
                    st_rw_nxt = ST_RW_R;
                  else if (wreq_pri0_withcredit_any & rswitch_states_en)
                    st_rw_nxt = ST_RW_W;
                  else if (rreq_withcredit_any)
                    st_rw_nxt = ST_RW_R;
                  else if (wreq_withcredit_any & rswitch_states_en)
                    st_rw_nxt = ST_RW_W;
                  else
                    st_rw_nxt = ST_RW_R;
               end else if (wreq_withcredit_any & rswitch_states_en)
                 st_rw_nxt = ST_RW_W;
               else
                 st_rw_nxt = ST_RW_R;
            end
            
            default: begin
               if (any_lock_on_writes)
                 st_rw_nxt = ST_RW_W;
               else if (wr_credit_avail) begin
                  if (wreq_pri0_withcredit_pm_any)
                    st_rw_nxt = ST_RW_W;
                  else if (rreq_pri0_withcredit_any & wswitch_states_en)
                    st_rw_nxt = ST_RW_R;
                  else if (rreq_hpr_any & hpr_credit_avail & wswitch_states_en)
                    st_rw_nxt = ST_RW_R;
                  else if (wreq_withcredit_any)
                    st_rw_nxt = ST_RW_W;
                  else if (rreq_any & lpr_credit_avail & wswitch_states_en)
                    st_rw_nxt = ST_RW_R;
                  else
                    st_rw_nxt = ST_RW_W;
               end else if (rreq_withcredit_any & wswitch_states_en)
                 st_rw_nxt = ST_RW_R;
               else
                 st_rw_nxt = ST_RW_W;
            end
            
          endcase
         end

         assign pa_par_vec_i = {pa_par_vec_ndp_i,st_rw_nxt};
         assign {pa_par_vec_ndp_r,st_rw} = pa_par_vec_r;

         // Low priority read counter
         if (MEMC_INLINE_ECC==1) begin: IECC_en_RDWR_FSM_enabled

            wire [NPORTS-1:0] lpr_rd_credit_decr_ie_v, lpr_rmw_credit_decr_ie_v;
            wire lpr_credit_decr_ie, lpr_rd_credit_decr_ie, lpr_rmw_credit_decr_ie;

         
            assign lpr_rd_credit_decr_ie_v   = lpr_rd_credit_decr_v & rreq_iecc_lock;
            assign lpr_rmw_credit_decr_ie_v  = lpr_rmw_credit_decr_v & wreq_iecc_lock;

            assign lpr_rd_credit_decr_ie  = |lpr_rd_credit_decr_ie_v;
            assign lpr_rmw_credit_decr_ie = |lpr_rmw_credit_decr_ie_v;
            assign lpr_credit_decr_ie     = lpr_rd_credit_decr_ie | lpr_rmw_credit_decr_ie;


            always @(*) begin: lpr_credit_cnt_COMB_PROC
               lpr_credit_cnt_nxt = lpr_credit_cnt_r;
               casez ({rst_credit_cnt,hif_lpr_credit,lpr_credit_decr_ie,lpr_credit_decr})
                  5'b1????:  lpr_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
                  5'b0001?:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 2;
                  5'b0011?:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
                  5'b0101?:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
                  5'b00001:  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
                  5'b01101:  lpr_credit_cnt_nxt = lpr_credit_cnt_r + 1;
                  5'b00100:  lpr_credit_cnt_nxt = lpr_credit_cnt_r + 1;
                  5'b01000:  lpr_credit_cnt_nxt = lpr_credit_cnt_r + 1;
                  5'b01100:  lpr_credit_cnt_nxt = lpr_credit_cnt_r + 2;
                  default:  lpr_credit_cnt_nxt = lpr_credit_cnt_r;
               endcase
            end

            assign lpr_credit_gt_min   = ie_ecc_enabled ? lpr_credit_cnt_gt_1 : lpr_credit_cnt_gt_0;

         end
         else begin: IECC_dis
         
            always @(*) begin: lpr_credit_cnt_COMB_PROC
               lpr_credit_cnt_nxt = lpr_credit_cnt_r;
               if (rst_credit_cnt)
                  lpr_credit_cnt_nxt = {CRDT_CNT_WIDTH{1'b0}};
               else if(hif_lpr_credit & ~lpr_credit_decr)
                  lpr_credit_cnt_nxt = lpr_credit_cnt_r + 1;
               else if(~hif_lpr_credit & lpr_credit_decr)
                  lpr_credit_cnt_nxt = lpr_credit_cnt_r - 1;
            end

            assign lpr_credit_gt_min   = lpr_credit_cnt_gt_0;

         end
         // read and write can't be granted at the same time, so no precedence between read and rmw
         assign lpr_rmw_credit_avail = lpr_credit_avail;

         // FSM outputs
         assign write_en  = st_rw_nxt[STBF_RW_W];
         assign read_en   = st_rw_nxt[STBF_RW_R];
      end
   endgenerate
   
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((NPORTS * PORT_PRIORITYW) - 1)' found in module 'DWC_ddr_umctl2_pa_preproc'
//SJ: This coding style is acceptable and there is no plan to change it.

   // Generate masks based on port priorities
   generate
      if((EXT_PORTPRIO == 1)) begin: GEN_priocomphi
         DWC_ddr_umctl2_pa_priocomphi
           #(.NPORTS(NPORTS), .PRIORITYW(PORT_PRIORITYW))
         U_priocomp_wr 
           (
            // Outputs
            .port_mask            (wport_mask[NPORTS-1:0]),
            // Inputs
            .port_priority        (wport_priority[NPORTS*PORT_PRIORITYW-1:0]),
            .req                  (wreq_withpmatchfilter[NPORTS-1:0]));
         
         DWC_ddr_umctl2_pa_priocomphi
           #(.NPORTS(NPORTS), .PRIORITYW(PORT_PRIORITYW))
         U_priocomp_rd_lpr 
           (
            // Outputs
            .port_mask            (rport_lpr_mask[NPORTS-1:0]),
            // Inputs
            .port_priority        (rport_priority[NPORTS*PORT_PRIORITYW-1:0]),
            .req                  (rreq_lpr_pm[NPORTS-1:0]));
         
         DWC_ddr_umctl2_pa_priocomphi
           #(.NPORTS(NPORTS), .PRIORITYW(PORT_PRIORITYW))
         U_priocomp_rd_hpr
           (
            // Outputs
            .port_mask            (rport_hpr_mask[NPORTS-1:0]),
            // Inputs
            .port_priority        (rport_priority[NPORTS*PORT_PRIORITYW-1:0]),
            .req                  (rreq_hpr_pm[NPORTS-1:0]));
      end else begin: GEN_priocomplo
         DWC_ddr_umctl2_pa_priocomp
           #(.NPORTS(NPORTS), .PRIORITYW(PORT_PRIORITYW))
         U_priocomp_wr 
           (
            // Outputs
            .port_mask            (wport_mask[NPORTS-1:0]),
            // Inputs
            .port_priority        (wport_priority[NPORTS*PORT_PRIORITYW-1:0]),
            .req                  (wreq_withpmatchfilter[NPORTS-1:0]));
         
         DWC_ddr_umctl2_pa_priocomp
           #(.NPORTS(NPORTS), .PRIORITYW(PORT_PRIORITYW))
         U_priocomp_rd_lpr 
           (
            // Outputs
            .port_mask            (rport_lpr_mask[NPORTS-1:0]),
            // Inputs
            .port_priority        (rport_priority[NPORTS*PORT_PRIORITYW-1:0]),
            .req                  (rreq_lpr_pm[NPORTS-1:0]));
         
         DWC_ddr_umctl2_pa_priocomp
           #(.NPORTS(NPORTS), .PRIORITYW(PORT_PRIORITYW))
         U_priocomp_rd_hpr
           (
            // Outputs
            .port_mask            (rport_hpr_mask[NPORTS-1:0]),
            // Inputs
            .port_priority        (rport_priority[NPORTS*PORT_PRIORITYW-1:0]),
            .req                  (rreq_hpr_pm[NPORTS-1:0]));
      end
   endgenerate
//spyglass enable_block SelfDeterminedExpr-ML
         
   assign wreq_mask     = wport_mask & wreq_withpmatchfilter;
   assign rreq_mask_lpr = rport_lpr_mask & rreq_lpr_pm;
   assign rreq_mask_hpr = rport_hpr_mask & rreq_hpr_pm;
     
   // Priority select for writes
   always @*
   begin: wreq_pp_COMB_PROC
      if (write_en && wreq_pri0_withcredit_pm_any)
        wreq_pp = wreq_pri0_withcredit_pm;
      else if (write_en & wr_credit_avail & ~wreq_pri0_withcredit_pm_any)
        wreq_pp = wreq_mask;
      else
        wreq_pp = {NPORTS{1'b0}};
   end

   
   // Priority select for reads
   always @*
   begin: rreq_pp_COMB_PROC
      if (read_en & rreq_pri0_withcredit_pm_any)
        rreq_pp = rreq_pri0_withcredit_pm;
      else if (read_en & hpr_credit_avail & rreq_hpr_pm_any & ~rreq_pri0_withcredit_pm_any)
        rreq_pp = rreq_mask_hpr;
      else if (read_en & lpr_credit_avail & ~rreq_pri0_withcredit_pm_any)
        rreq_pp = rreq_mask_lpr;
      else
        rreq_pp = {NPORTS{1'b0}};
   end
   
   // ----------------------------------------------
   // Performance monitor interface
   // ----------------------------------------------
   // Event: Total cycles on High Priority reads credit
   // Description of counted event: Count cycles for not serving high priority reads due to none available credit.
   assign  perf_hpr_req_with_nocredit_i = rreq_hpr_pm_any & ~hpr_credit_avail & ~(|rgrant) & rgrant_en;
   
   // Event: Total cycles on Low Priority reads credit
   // Description of counted event: Count cycles for not serving low priority reads due to none available credit
   assign  perf_lpr_req_with_nocredit_i = rreq_lpr_pm_any & ~lpr_credit_avail & ~|(rgrant & xa_rpri) & rgrant_en;
   
   // ----------------------------------------------
   // Exclusive access write lock
   // ----------------------------------------------
   always @(*) begin: st_wlock_nxt_COMB_PROC
      st_wlock_nxt = ST_WLOCK_UL;
      case (st_wlock)
        ST_WLOCK_UL: begin
           if (wreq_granted_withlock_any)
             st_wlock_nxt = ST_WLOCK_L;
           else
             st_wlock_nxt = ST_WLOCK_UL;
        end

        default: begin
           if (~wreq_sameholded_withlock_any)
             st_wlock_nxt = ST_WLOCK_UL;
           else
             st_wlock_nxt = ST_WLOCK_L;
        end

      endcase
   end
   
   //spyglass disable_block W415a
   //SMD: Signal  is being assigned multiple times in same always block. 
   //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
   always @(*) begin: wgrant_nxt_saved_COMB_PROC       
      wreq_hold_nxt          = wreq_hold;
      for (i=0; i<NPORTS; i=i+1) begin
         if (wreq[i] & ~wreq_last[i])
            wreq_hold_nxt[i] = 1'b1;
         else if (wreq[i] & wreq_last[i])
            wreq_hold_nxt[i] = 1'b0;
      end
   end
   //spyglass enable_block W415a

   assign wgrant_nxt_saved_nxt2 = (|wgrant_nxt) ? wgrant_nxt : wgrant_nxt_saved;
   
   // Mask off all the requesters except the one being locked
   assign wreq_sameholded_withlock     = (wreq|wreq_hold) & wreq_exa_lock & wgrant_nxt_saved;
   assign wreq_sameholded_withlock_any = |wreq_sameholded_withlock;

   assign wreq_granted_withlock     = wreq & wreq_exa_lock & wgrant_nxt;
   assign wreq_granted_withlock_any = |wreq_granted_withlock;
   
   assign wreq_same_withlock  = wreq & wreq_exa_lock & wgrant_nxt_saved;
   assign wreq_withlockfilter = (st_wlock[STBF_WLOCK_L]) ? wreq_same_withlock : wreq; 

   // Write lock to be used for port throttle control
   assign wreq_locked   = st_wlock_nxt[STBF_WLOCK_L];
   
   // ----------------------------------------------
   // Page match lock - for writes
   // ----------------------------------------------
   always @(*) begin: st_wrpmlock_nxt_COMB_PROC
      st_wrpmlock_nxt = ST_WRPMLOCK_UL;
      case (st_wrpmlock)
        ST_WRPMLOCK_UL: begin
           if (wreq_granted_withpmatch_any & ~rreq_pri0_withcredit_any & ~(rreq_hpr_any & hpr_credit_avail) & ~wreq_pri0_nf_any & ~wpmatch_limit_r)
             st_wrpmlock_nxt = ST_WRPMLOCK_L;
           else
             st_wrpmlock_nxt = ST_WRPMLOCK_UL;
        end

        default: begin
           if (~wreq_sameholded_withpmatch_any | wpmatch_limit | wreq_pri0_nf_any 
               | rreq_pri0_withcredit_any | (rreq_hpr_any & hpr_credit_avail))
             st_wrpmlock_nxt = ST_WRPMLOCK_UL;
           else
             st_wrpmlock_nxt = ST_WRPMLOCK_L;
        end
      endcase
   end
   
   // Start the pagematch lock if the granted port is requesting with a pagematch lock:
   assign wreq_granted_withpmatch      = wreq_withlockfilter & wpagematch & wgrant_nxt_saved;
   assign wreq_granted_withpmatch_any  = |wreq_granted_withpmatch;

   assign wreq_sameholded_withpmatch_any  = |wreq_sameholded_withpmatch;

   // Mask every requester except from the one that is being locked to during pagematch lock:
   assign wreq_same_withpmatch   = wreq & wpagematch & wgrant_nxt_saved;

   assign wreq_withpmatchfilter  = (st_wrpmlock_nxt_enabled) ? wreq_same_withpmatch : wreq_withlockfilter;

   // If there is a timed-out (priority0) write port requesting that is different than the one being locked to
   // due to pagematch, then exit the lock
   assign wreq_pri0_nf                 = wpriority0 & wreq & ~wreq_sameholded_withpmatch;
   assign wreq_pri0_nf_any             = |wreq_pri0_nf;


   // Request lock for one cycle only if pagematch (to make sure we can lock on to back-to-back transactions)
   assign wreq_withpmatch = wreq_withlockfilter & wpagematch & ~rreq_pri0_withcredit_pm & ~(rreq_hpr_pm & {NPORTS{hpr_credit_avail}});

   // This is used to generate one cycle of hold signal in order to lock on the second transaction of a
   // back-to-back requesting port which is a pagematch (the first transaction comes as no pagematch).
   assign wgrant_hold   = wreq_withpmatch & ~wreq_withpmatch_r & wr_rmw_credit_avail & {NPORTS{write_en}};

   // In order to limit back-to-back grants due to pagematch
   always @(*) begin: wpmatch_cnt_COMB_PROC
      wpmatch_cnt_nxt = wpmatch_cnt;
      if (~(|reg_pagematch_limit) | wreq_locked) begin // if there is an exclusive lock, should not count as it will interfere
         wpmatch_cnt_nxt = FOUR_LIMIT;
      end
      else if (st_wrpmlock_nxt[STBF_WRPMLOCK_L] & (|wpmatch_cnt)) begin
         if (|wgrant_nxt) begin
            wpmatch_cnt_nxt = wpmatch_cnt - 1;
         end
      end 
      else if (st_wrpmlock_nxt[STBF_WRPMLOCK_UL]) begin
         wpmatch_cnt_nxt = FOUR_LIMIT;
      end
   end

   // Limit must be asserted when credit is available otherwise it will be ignored and FSM will re-lock to the same port
   // We use the simplified version not to create a combinatorial loop
   assign wpmatch_limit = (wpmatch_cnt==0) & ((PA_OPT_TYPE==1) | wr_credit_avail_simplified);

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement and therefore must always exist.
   // When there is a port lock of any sorts, prevent switching direction
   assign any_lock_on_writes  = st_wlock[STBF_WLOCK_L];
//spyglass enable_block W528

   // ----------------------------------------------
   // Page match lock - for reads
   // ----------------------------------------------
   always @(*) begin: st_rdpmlock_nxt_COMB_PROC
      st_rdpmlock_nxt = ST_RDPMLOCK_UL;
      case (st_rdpmlock)
        ST_RDPMLOCK_UL: begin
           if (rreq_granted_withpmatch_any & ~wreq_pri0_withcredit_any & ~rreq_pri0_nf_any & ~rpmatch_limit_r)
             st_rdpmlock_nxt = ST_RDPMLOCK_L;
           else
             st_rdpmlock_nxt = ST_RDPMLOCK_UL;
        end

        default: begin
           if (~rreq_granted_withpmatch_any | rpmatch_limit | rreq_pri0_nf_any 
               | wreq_pri0_withcredit_any)
             st_rdpmlock_nxt = ST_RDPMLOCK_UL;
           else
             st_rdpmlock_nxt = ST_RDPMLOCK_L;
        end
      endcase
   end

   assign rgrant_nxt_saved_nxt2 = (|rgrant_nxt) ? rgrant_nxt : rgrant_nxt_saved;
   
   // Start the pagematch lock if the granted port is requesting with a pagematch lock:
   assign rreq_granted_withpmatch      = rreq & rpagematch & rgrant_nxt_saved;
   assign rreq_granted_withpmatch_any  = |rreq_granted_withpmatch;

   assign rreq_withpmatchfilter     = (st_rdpmlock_nxt_enabled) ? rreq_granted_withpmatch : rreq;

   // If there is a timed-out (priority0) read port requesting that is different than the one being locked to
   // due to pagematch, then exit the lock
   assign rreq_pri0_nf           = rpriority0 & rreq & ~rreq_granted_withpmatch;
   assign rreq_pri0_nf_any       = |rreq_pri0_nf;
   

   // Request lock for one cycle only if pagematch (to make sure we can lock on to back-to-back transactions)
   assign rreq_withpmatch  = rreq & rpagematch & ~wreq_pri0_withcredit_pm;

   // This is used to generate one cycle of hold signal in order to lock on the second transaction of a
   // back-to-back requesting port which is a pagematch (the first transaction comes as no pagematch).
   assign rgrant_hold   = rreq_withpmatch & ~rreq_withpmatch_r & rd_pri_credit_avail & {NPORTS{read_en}};

   // In order to limit back-to-back grants due to pagematch
   always @(*) begin: rpmatch_cnt_COMB_PROC
      rpmatch_cnt_nxt = rpmatch_cnt;
      if (~|reg_pagematch_limit) begin
         rpmatch_cnt_nxt = FOUR_LIMIT;
      end
      else if (st_rdpmlock_nxt[STBF_RDPMLOCK_L] & (|rpmatch_cnt)) begin
         if (|rgrant_nxt) begin
            rpmatch_cnt_nxt = rpmatch_cnt - 1;
         end
      end 
      else if (st_rdpmlock_nxt[STBF_RDPMLOCK_UL]) begin
         rpmatch_cnt_nxt = FOUR_LIMIT;
      end
   end

   // Limit must be asserted when credit is available otherwise it will be ignored and FSM will re-lock to the same port
   assign rpmatch_limit = (rpmatch_cnt==0) & ((PA_OPT_TYPE==1) | rd_credit_avail);

   generate
      if (PA_OPT_TYPE==1) begin: SEQ_pa
         assign wpmatch_limit_nxt      = wpmatch_limit;
         assign rpmatch_limit_nxt      = rpmatch_limit;
         assign rgrant_nxt_saved_nxt   = (rpmatch_limit) ? {NPORTS{1'b0}} : rgrant_nxt_saved_nxt2;
         assign wgrant_nxt_saved_nxt   = (wpmatch_limit) ? {NPORTS{1'b0}} : wgrant_nxt_saved_nxt2;
                                         
      end
      else begin: COMB_pa
         assign wpmatch_limit_nxt      = 1'b0;
         assign rpmatch_limit_nxt      = 1'b0;
         assign rgrant_nxt_saved_nxt   = rgrant_nxt_saved_nxt2;
         assign wgrant_nxt_saved_nxt   = wgrant_nxt_saved_nxt2;
      end

      if (PAGEMATCH_EN==1) begin: PMATCH_en
         assign st_rdpmlock_nxt_enabled   = st_rdpmlock_nxt[STBF_RDPMLOCK_L];
         assign st_wrpmlock_nxt_enabled   = (st_wrpmlock_nxt[STBF_WRPMLOCK_L] & st_wlock[STBF_WLOCK_UL]);
      end
      else begin: PMATCH_dis
         assign st_rdpmlock_nxt_enabled   = 1'b0;
         assign st_wrpmlock_nxt_enabled   = 1'b0;
      end

      if (DATA_CHANNEL_INTERLEAVE==0) begin: SINGLE_dch
         // Continue the lock as long as the port is requesting with a pagematch
         assign wreq_sameholded_withpmatch      = (wreq|wreq_hold) & wpagematch & wgrant_nxt_saved;
      end 
      else begin: DCH_intlv
         // when dual channel with interleaving support is enabled, lock can't be supported. This is because the last beat may not come to this channel, causing the PA to lock on the same port forever
         assign wreq_sameholded_withpmatch      = wreq & wpagematch & wgrant_nxt_saved;
      end
   endgenerate

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (PA_PAR_VEC_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .SL_W    (8),
      .RESVAL  (PA_PAR_VEC_RESVAL))
   U_pa_par_vec_r
   (  .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (pa_par_vec_i),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (pa_par_vec_r),
      .parity_err (par_vec_parity_err));
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS



   `endif
   `endif
   
endmodule // DWC_ddr_umctl2_pa_preproc
