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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa_dual.sv#1 $
// -------------------------------------------------------------------------
// Description:
//           Port Arbiter top level
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa_dual
  #(
    parameter NPORTS                   = 1,
    parameter PORT_PRIORITYW           = 1,
    parameter QOSW                     = 1,
    parameter REG_PORT_PRIORITYW       = 1,
    parameter PA_OPT_TYPE              = 1,
    parameter PAGEMATCH_EN             = 1,
    parameter MEMC_ECC_SUPPORT         = 0,
    parameter MEMC_INLINE_ECC          = 0,
    parameter WDATA_PTR_BITS           = 12,
    parameter MEMC_TAGBITS             = 1,
    parameter AXI_IDW                  = 8,
    parameter AXI_USERW                = 1,
    parameter A_NPORTS_LG2             = 1,
    parameter EXT_PORTPRIO             = 0,
    parameter RQOS_RW                  = 2,
    parameter WQOS_RW                  = 2,
    parameter HIF_CREDIT_BITS          = 1,
    parameter DUAL_PA                  = 0,
    parameter DATA_CHANNEL_INTERLEAVE  = 0,
    parameter CRDT_CNT_WIDTH           = 7,
    parameter OCCAP_EN                 = 0,
    parameter OCCAP_PIPELINE_EN        = 0
    )
   (
    input                                 clk,
    input                                 rst_n,

    // HIF Command Flow Control Interface
    input                                 hif_rcmd_stall,
    input                                 hif_wcmd_stall,
    input [HIF_CREDIT_BITS-1:0]           hif_hpr_credit,
    input [HIF_CREDIT_BITS-1:0]           hif_lpr_credit,
    input                                 hif_wr_credit,   
    input [1:0]                           hif_wrecc_credit,
    
    // HIF Scheduler Interface
    output                                hif_go2critical_wr,
    output                                hif_go2critical_lpr,
    output                                hif_go2critical_hpr,
    // HIF Scheduler interface when MEMC_ENH_RDWR_SWITCH is enabled
    output                                hif_go2critical_l1_wr,
    output                                hif_go2critical_l2_wr,
    output                                hif_go2critical_l1_lpr,
    output                                hif_go2critical_l2_lpr,
    output                                hif_go2critical_l1_hpr,
    output                                hif_go2critical_l2_hpr,
   
    // Register Interface
    input                                 reg_go2critical_en,
    input                                 reg_pagematch_limit,
    input [NPORTS*REG_PORT_PRIORITYW-1:0] reg_wr_port_priority,
    input [NPORTS-1:0]                    reg_wr_port_aging_en,
    input [NPORTS-1:0]                    reg_wr_port_urgent_en,
    input [NPORTS*REG_PORT_PRIORITYW-1:0] reg_rd_port_priority,
    input [NPORTS-1:0]                    reg_rd_port_aging_en,
    input [NPORTS-1:0]                    reg_rd_port_urgent_en,
    input [NPORTS*RQOS_RW-1:0]            xa_rqos_priority,
    input [NPORTS*WQOS_RW-1:0]            xa_wqos_priority,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
    input                                 reg_ddrc_ecc_type,
    input [2:0]                           reg_ddrc_ecc_mode,
//spyglass enable_block W240
    input                                 reg_ddrc_occap_en,
    // Miscellenous
    input                                 any_other_stall_condition,
    input                                 lpr_num_entries_changed,

    // Write Ports
    input [NPORTS-1:0]                    xa_rmw_dynamic,    
    input [NPORTS*QOSW-1:0]               xa_wqos,
    input [NPORTS-1:0]                    xa_wurgent,
    input [NPORTS-1:0]                    xa_wpagematch,
    input [NPORTS*WDATA_PTR_BITS-1:0]     xa_wdata_ptr,
    input [NPORTS-1:0]                    xa_wreq,
    input [NPORTS-1:0]                    xa_wmask,
    input [NPORTS-1:0]                    xa_wlast,
    input [NPORTS-1:0]                    xa_vpw_expired,
    output [NPORTS-1:0]                   pa_wgrant,
    output [NPORTS*WQOS_RW-1:0]           pa_wpri,
    
    // Read Ports
    input [NPORTS*QOSW-1:0]               xa_rqos,
    input [NPORTS-1:0]                    xa_rurgent,
    input [NPORTS-1:0]                    xa_rpagematch,
    input [NPORTS-1:0]                    xa_vpr_expired,
    input [NPORTS-1:0]                    xa_rmask,
    input [NPORTS-1:0]                    xa_rreq,
    input [NPORTS*MEMC_TAGBITS-1:0]       xa_rtoken,
    output [NPORTS-1:0]                   pa_rgrant,
    output [NPORTS*RQOS_RW-1:0]           pa_rpri,

    // Performance Monitor Interface
    output                                perf_hpr_req_with_nocredit,
    output                                perf_lpr_req_with_nocredit,
    
    // Credit Counters
    output [CRDT_CNT_WIDTH-1:0]           lpr_credit_cnt,
    output [CRDT_CNT_WIDTH-1:0]           hpr_credit_cnt,
    output [CRDT_CNT_WIDTH-1:0]           wr_credit_cnt,
    output [CRDT_CNT_WIDTH-1:0]           wrecc_credit_cnt,

    output                                occap_pa_parity_err
    
    );

    localparam MASK_R_WIDTH = NPORTS*2;

   genvar gv;
   wire [NPORTS-1:0]                xa_wexacclock, xa_arlast, xa_awlast_unused;
   wire [NPORTS-1:0]                xa_wiecclock, xa_wiecclock_end;
   wire [NPORTS-1:0]                rpriority0, wpriority0;
   wire [NPORTS*PORT_PRIORITYW-1:0] rport_priority, wport_priority;
   wire [NPORTS-1:0]                xa_rpri;
   wire [NPORTS-1:0]                rgrant, wgrant, rgrant_nxt, wgrant_nxt;
   wire [NPORTS-1:0]                rreq_pp, wreq_pp, wgrant_hold, rgrant_hold;
   wire                             wswitch_states_en, rswitch_states_en;
   wire                             rgrant_en, wgrant_en_unused;
   wire [NPORTS-1:0]                xa_rmw_static;
   wire [NPORTS-1:0]                xa_rreq_masked, xa_wreq_masked;
   wire [NPORTS-1:0]                xa_wmask_r, xa_wmask_next, xa_rmask_r, xa_rmask_next;
   wire                             wreq_locked, rreq_locked;
   wire                             hif_go2critical_lpr_wr, hif_go2critical_lpr_rd;
   wire                             hif_go2critical_l2_lpr_wr, hif_go2critical_l2_lpr_rd;
   wire                             hif_rcmd_stall_l;
   wire                             hif_wcmd_stall_l;

   wire                             ie_ecc_enabled;

   wire                             occap_mask_par_err;
   wire                             pa_preproc_parity_err;

   wire                             rd_pa_parity_err, wr_pa_parity_err;

   // unused signals
   wire [NPORTS-1:0]                xa_wpri_unused;
   wire                             hif_go2critical_wr_unused, hif_go2critical_hpr_unused;
   wire [NPORTS-1:0]                xa_rexacclock_unused;
   wire [NPORTS-1:0]                xa_riecclock_end;

   wire                             hif_go2critical_l1_wr_unused;
   wire                             hif_go2critical_l2_wr_unused;
   wire                             hif_go2critical_l1_lpr_unused;
   wire                             hif_go2critical_l1_hpr_unused;
   wire                             hif_go2critical_l2_hpr_unused;
   // end
   //
   wire [NPORTS-1:0]                xa_riecclock;

   assign occap_pa_parity_err = occap_mask_par_err | rd_pa_parity_err | wr_pa_parity_err | pa_preproc_parity_err;

   //spyglass disable_block W528
   //SMD: A signal or variable is set but never read - "xa_rmw_static"
   //SJ: Used in TB (sva_pa.sv)
   generate 
      if (MEMC_ECC_SUPPORT>0) begin: ECC_en
         assign ie_ecc_enabled = (reg_ddrc_ecc_mode==3'b100 || reg_ddrc_ecc_mode==3'b101) ? reg_ddrc_ecc_type : 1'b0;
         assign xa_rmw_static  = {NPORTS{ie_ecc_enabled}};
      end
      else begin: ECC_dis
         assign ie_ecc_enabled = 1'b0;
         assign xa_rmw_static  = {NPORTS{1'b0}};
      end
   endgenerate
   //spyglass enable_block W528

   assign hif_rcmd_stall_l = hif_rcmd_stall;
   assign hif_wcmd_stall_l = hif_wcmd_stall;

   // --------------------------
   // Register the mask inputs
   // --------------------------

   assign xa_rmask_next = (~rreq_locked) ? xa_rmask : {NPORTS{1'b0}};
   assign xa_wmask_next = (~wreq_locked) ? xa_wmask : {NPORTS{1'b0}};

   wire [MASK_R_WIDTH-1:0] mask_r_in, mask_r_out;

   assign mask_r_in = {xa_rmask_next,xa_wmask_next};
   assign {xa_rmask_r,xa_wmask_r} = mask_r_out;

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (MASK_R_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
   )
   U_mask_r
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (mask_r_in),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (mask_r_out),
      .parity_err (occap_mask_par_err)
   );

   assign xa_rreq_masked = (xa_rreq ^ xa_rmask_r) & xa_rreq;
   assign xa_wreq_masked = (xa_wreq ^ xa_wmask_r) & xa_wreq;

   // --------------------------
   // write arbiter
   // --------------------------
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(NPORTS * WQOS_RW)' found in module 'DWC_ddr_umctl2_pa_dual'
//SJ: This coding style is acceptable and there is no plan to change it.
   DWC_ddr_umctl2_pa
    #(
      .NPORTS              (NPORTS), 
      .PORT_PRIORITYW      (PORT_PRIORITYW), 
      .QOSW                (QOSW),
      .REG_PORT_PRIORITYW  (REG_PORT_PRIORITYW), 
      .PA_OPT_TYPE         (PA_OPT_TYPE), 
      .MEMC_ECC_SUPPORT    (MEMC_ECC_SUPPORT),
      .MEMC_INLINE_ECC     (MEMC_INLINE_ECC),
      .WDATA_PTR_BITS      (WDATA_PTR_BITS), 
      .MEMC_TAGBITS        (MEMC_TAGBITS),
      .AXI_IDW             (AXI_IDW),
      .AXI_USERW           (AXI_USERW),
      .A_NPORTS_LG2        (A_NPORTS_LG2), 
      .EXT_PORTPRIO        (EXT_PORTPRIO), 
      .QOS_RW              (WQOS_RW),
      .OCCAP_EN            (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .RDWR                (0))
   U_wr_pa (
         // Outputs
         .hif_go2critical_wr         (hif_go2critical_wr),         
         .hif_go2critical_lpr        (hif_go2critical_lpr_wr),     
         .hif_go2critical_hpr        (hif_go2critical_hpr_unused), 
         // HIF Scheduler interface when MEMC_ENH_RDWR_SWITCH is enabled
         .hif_go2critical_l1_wr      (hif_go2critical_l1_wr ),
         .hif_go2critical_l2_wr      (hif_go2critical_l2_wr ),
         .hif_go2critical_l1_lpr     (hif_go2critical_l1_lpr_unused),
         .hif_go2critical_l2_lpr     (hif_go2critical_l2_lpr_wr),
         .hif_go2critical_l1_hpr     (hif_go2critical_l1_hpr_unused),
         .hif_go2critical_l2_hpr     (hif_go2critical_l2_hpr_unused),
         .grant                      (wgrant[NPORTS-1:0]),
         .grant_nxt                  (wgrant_nxt[NPORTS-1:0]),
         .pa_pri                     (pa_wpri[NPORTS*WQOS_RW-1:0]),
         .xa_pri                     (xa_wpri_unused[NPORTS-1:0]),
         .priority0                  (wpriority0),
         .port_priority              (wport_priority),
         .xa_exacclock               (xa_wexacclock[NPORTS-1:0]),
         .xa_alast                   (xa_awlast_unused),
         .xa_iecclock                (xa_wiecclock),
         //spyglass disable_block W528
         //SMD: A signal or variable is set but never read
         //SJ: Used in sva_pa.sv module
         .xa_iecclock_end            (xa_wiecclock_end),
         //spyglass enable_block W528
         .switch_states_en           (wswitch_states_en),
         .grant_en                   (wgrant_en_unused),
         .pa_parity_err              (wr_pa_parity_err),

         // Inputs
         .clk                        (clk),
         .rst_n                      (rst_n),
         .hif_cmd_stall              (hif_wcmd_stall_l),
         .reg_go2critical_en         (reg_go2critical_en),
         .ie_ecc_enabled             (ie_ecc_enabled),
         .reg_port_priority          (reg_wr_port_priority[NPORTS*REG_PORT_PRIORITYW-1:0]),
         .reg_port_aging_en          (reg_wr_port_aging_en[NPORTS-1:0]),
         .reg_port_urgent_en         (reg_wr_port_urgent_en[NPORTS-1:0]),
         .xa_qos_priority            (xa_wqos_priority),
         .any_other_stall_condition  (any_other_stall_condition),
         .xa_qos                     (xa_wqos[NPORTS*QOSW-1:0]),
         .xa_urgent                  (xa_wurgent[NPORTS-1:0]),
         .rmw_dynamic                (xa_rmw_dynamic[NPORTS-1:0]),
         .xa_wdata_ptr               (xa_wdata_ptr[NPORTS*WDATA_PTR_BITS-1:0]),
         .xa_req_masked              (xa_wreq_masked[NPORTS-1:0]),
         .xa_mask_r                  (xa_wmask_r[NPORTS-1:0]),
         .xa_rtoken                  (xa_rtoken),
         .xa_vpt_expired             (xa_vpw_expired[NPORTS-1:0]),
         .grant_hold                 (wgrant_hold),
         .req_pp                     (wreq_pp),
         .reg_ddrc_occap_en          (reg_ddrc_occap_en),
         .lpr_credit_cnt             (lpr_credit_cnt),
         .hpr_credit_cnt             (hpr_credit_cnt),
         .wr_credit_cnt              (wr_credit_cnt),
         .wrecc_credit_cnt           (wrecc_credit_cnt));

   assign pa_wgrant  = wgrant;


   // --------------------------
   // read arbiter
   // --------------------------
   DWC_ddr_umctl2_pa
    #(
      .NPORTS              (NPORTS), 
      .PORT_PRIORITYW      (PORT_PRIORITYW), 
      .QOSW                (QOSW),
      .REG_PORT_PRIORITYW  (REG_PORT_PRIORITYW), 
      .PA_OPT_TYPE         (PA_OPT_TYPE), 
      .MEMC_ECC_SUPPORT    (MEMC_ECC_SUPPORT),
      .MEMC_INLINE_ECC     (MEMC_INLINE_ECC),
      .WDATA_PTR_BITS      (WDATA_PTR_BITS), 
      .MEMC_TAGBITS        (MEMC_TAGBITS),
      .AXI_IDW             (AXI_IDW),
      .AXI_USERW           (AXI_USERW),
      .A_NPORTS_LG2        (A_NPORTS_LG2), 
      .EXT_PORTPRIO        (EXT_PORTPRIO), 
      .QOS_RW              (RQOS_RW),
      .OCCAP_EN            (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .RDWR                (1))
   U_rd_pa (
         // Outputs
         .hif_go2critical_wr         (hif_go2critical_wr_unused),
         .hif_go2critical_lpr        (hif_go2critical_lpr_rd),
         .hif_go2critical_hpr        (hif_go2critical_hpr),
         // HIF Scheduler interface when MEMC_ENH_RDWR_SWITCH is enabled
         .hif_go2critical_l1_wr      (hif_go2critical_l1_wr_unused),
         .hif_go2critical_l2_wr      (hif_go2critical_l2_wr_unused),
         .hif_go2critical_l1_lpr     (hif_go2critical_l1_lpr),
         .hif_go2critical_l2_lpr     (hif_go2critical_l2_lpr_rd),
         .hif_go2critical_l1_hpr     (hif_go2critical_l1_hpr),
         .hif_go2critical_l2_hpr     (hif_go2critical_l2_hpr),
         .grant                      (rgrant[NPORTS-1:0]),
         .grant_nxt                  (rgrant_nxt[NPORTS-1:0]),
         .pa_pri                     (pa_rpri[NPORTS*RQOS_RW-1:0]),
         .xa_pri                     (xa_rpri[NPORTS-1:0]),
         .priority0                  (rpriority0),
         .port_priority              (rport_priority),
         .xa_exacclock               (xa_rexacclock_unused),
         //spyglass disable_block W528
         //SMD: A signal or variable is set but never read
         //SJ: Used in sva_pa.sv module
         .xa_alast                   (xa_arlast),
         .xa_iecclock_end            (xa_riecclock_end),         
         //spyglass enable_block W528
         .xa_iecclock                (xa_riecclock),
         .switch_states_en           (rswitch_states_en),
         .grant_en                   (rgrant_en),
         .pa_parity_err              (rd_pa_parity_err),

         // Inputs
         .clk                        (clk),
         .rst_n                      (rst_n),
         .hif_cmd_stall              (hif_rcmd_stall_l),
         .reg_go2critical_en         (reg_go2critical_en),
         .ie_ecc_enabled             (ie_ecc_enabled),
         .reg_port_priority          (reg_rd_port_priority[NPORTS*REG_PORT_PRIORITYW-1:0]),
         .reg_port_aging_en          (reg_rd_port_aging_en[NPORTS-1:0]),
         .reg_port_urgent_en         (reg_rd_port_urgent_en[NPORTS-1:0]),
         .xa_qos_priority            (xa_rqos_priority),
         .any_other_stall_condition  (any_other_stall_condition),
         .xa_qos                     (xa_rqos[NPORTS*QOSW-1:0]),
         .xa_urgent                  (xa_rurgent[NPORTS-1:0]),
         .rmw_dynamic                (xa_rmw_dynamic[NPORTS-1:0]),
         .xa_wdata_ptr               (xa_wdata_ptr[NPORTS*WDATA_PTR_BITS-1:0]),
         .xa_req_masked              (xa_rreq_masked[NPORTS-1:0]),
         .xa_mask_r                  (xa_rmask_r[NPORTS-1:0]),
         .xa_rtoken                  (xa_rtoken),
         .xa_vpt_expired             (xa_vpr_expired[NPORTS-1:0]),
         .grant_hold                 (rgrant_hold),
         .req_pp                     (rreq_pp),
         .reg_ddrc_occap_en          (reg_ddrc_occap_en),
         .lpr_credit_cnt             (lpr_credit_cnt),
         .hpr_credit_cnt             (hpr_credit_cnt),
         .wr_credit_cnt              (wr_credit_cnt),
         .wrecc_credit_cnt           (wrecc_credit_cnt));

   assign pa_rgrant  = rgrant;

   // --------------------------
   // Request preprocessor and read/write arbiter
   // --------------------------         
   DWC_ddr_umctl2_pa_preproc
    #(
      .NPORTS                    (NPORTS), 
      .PORT_PRIORITYW            (PORT_PRIORITYW), 
      .EXT_PORTPRIO              (EXT_PORTPRIO), 
      .DUAL_PA                   (DUAL_PA),
      .PAGEMATCH_EN              (PAGEMATCH_EN),
      .DATA_CHANNEL_INTERLEAVE   (DATA_CHANNEL_INTERLEAVE),
      .MEMC_INLINE_ECC           (MEMC_INLINE_ECC),
      .HIF_CREDIT_BITS           (HIF_CREDIT_BITS),
      .PA_OPT_TYPE               (PA_OPT_TYPE),
      .OCCAP_EN                  (OCCAP_EN),
      .OCCAP_PIPELINE_EN         (OCCAP_PIPELINE_EN),
      .CRDT_CNT_WIDTH            (CRDT_CNT_WIDTH))
   U_preproc (
              // Outputs
              .wreq_pp                    (wreq_pp[NPORTS-1:0]),
              .wgrant_hold                (wgrant_hold[NPORTS-1:0]),
              .wreq_locked                (wreq_locked),
              .rreq_pp                    (rreq_pp[NPORTS-1:0]),
              .rgrant_hold                (rgrant_hold[NPORTS-1:0]),        
              .rreq_locked                (rreq_locked),
              .perf_hpr_req_with_nocredit (perf_hpr_req_with_nocredit),
              .perf_lpr_req_with_nocredit (perf_lpr_req_with_nocredit),
              .lpr_credit_cnt             (lpr_credit_cnt),
              .hpr_credit_cnt             (hpr_credit_cnt),
              .wr_credit_cnt              (wr_credit_cnt),
              .wrecc_credit_cnt           (wrecc_credit_cnt),
              .pa_preproc_parity_err      (pa_preproc_parity_err),
              // Inputs
              .clk                        (clk),
              .rst_n                      (rst_n),
              .reg_pagematch_limit        (reg_pagematch_limit),
              .ie_ecc_enabled             (ie_ecc_enabled),
              .lpr_num_entries_changed    (lpr_num_entries_changed),
              .hif_hpr_credit             (hif_hpr_credit),
              .hif_lpr_credit             (hif_lpr_credit),
              .hif_wr_credit              (hif_wr_credit),
              .hif_wrecc_credit           (hif_wrecc_credit),
              .wswitch_states_en          (wswitch_states_en),
              .wgrant_nxt                 (wgrant_nxt[NPORTS-1:0]),
              .wreq                       (xa_wreq_masked[NPORTS-1:0]),
              .wreq_last                  (xa_wlast[NPORTS-1:0]),
              .wreq_exa_lock              (xa_wexacclock[NPORTS-1:0]),
              .wreq_iecc_lock             (xa_wiecclock),
              .wpagematch                 (xa_wpagematch[NPORTS-1:0]),
              .wpriority0                 (wpriority0[NPORTS-1:0]),
              .wport_priority             (wport_priority[NPORTS*PORT_PRIORITYW-1:0]),
              .rmw_dynamic                (xa_rmw_dynamic[NPORTS-1:0]),
              .rswitch_states_en          (rswitch_states_en),
              .rgrant                     (rgrant[NPORTS-1:0]),
              .rgrant_nxt                 (rgrant_nxt[NPORTS-1:0]),
              .rgrant_en                  (rgrant_en),
              .rreq                       (xa_rreq_masked[NPORTS-1:0]),
              .rreq_iecc_lock             (xa_riecclock),
              .rpagematch                 (xa_rpagematch[NPORTS-1:0]),
              .xa_rpri                    (xa_rpri[NPORTS-1:0]),
              .rpriority0                 (rpriority0[NPORTS-1:0]),
              .rport_priority             (rport_priority[NPORTS*PORT_PRIORITYW-1:0]),
              .reg_ddrc_occap_en          (reg_ddrc_occap_en));
//spyglass enable_block SelfDeterminedExpr-ML

   assign hif_go2critical_lpr = hif_go2critical_lpr_wr | hif_go2critical_lpr_rd;

   assign hif_go2critical_l2_lpr = hif_go2critical_l2_lpr_wr | hif_go2critical_l2_lpr_rd;



endmodule // DWC_ddr_umctl2_pa_dual
