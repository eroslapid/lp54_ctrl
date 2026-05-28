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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            Port Arbiter top level
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa
  #(
    parameter NPORTS             = 1,
    parameter PORT_PRIORITYW     = 1,
    parameter QOSW               = 1,
    parameter REG_PORT_PRIORITYW = 1,
    parameter PA_OPT_TYPE        = 1,
    parameter MEMC_ECC_SUPPORT   = 0,
    parameter MEMC_INLINE_ECC    = 0,
    parameter WDATA_PTR_BITS     = 12,
    parameter MEMC_TAGBITS       = 1,
    parameter AXI_IDW            = 8,
    parameter AXI_USERW          = 1,
    parameter A_NPORTS_LG2       = 1,
    parameter EXT_PORTPRIO       = 0,
    parameter QOS_RW             = 2,
    parameter RDWR               = 0,
    parameter OCCAP_EN           = 0,
    parameter OCCAP_PIPELINE_EN  = 0
    )
   (
    input                                 clk,
    input                                 rst_n,

    // HIF Command Flow Control Interface
    input                                 hif_cmd_stall,
    
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
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block. 
    input                                 ie_ecc_enabled,
//spyglass enable_block W240
    input [NPORTS*REG_PORT_PRIORITYW-1:0] reg_port_priority,
    input [NPORTS-1:0]                    reg_port_aging_en,
    input [NPORTS-1:0]                    reg_port_urgent_en,
    input [NPORTS*QOS_RW-1:0]             xa_qos_priority,

    // Miscellenous
    input                                 any_other_stall_condition,

    // Port
    input [NPORTS*QOSW-1:0]               xa_qos,
    input [NPORTS-1:0]                    xa_urgent,
    input [NPORTS-1:0]                    xa_req_masked,
    input [NPORTS-1:0]                    xa_mask_r,
    input [NPORTS-1:0]                    xa_vpt_expired,
    input [NPORTS-1:0]                    grant_hold,
    input [NPORTS-1:0]                    req_pp,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block. 
    input [NPORTS*WDATA_PTR_BITS-1:0]     xa_wdata_ptr,
    input [NPORTS-1:0]                    rmw_dynamic,          
    input [NPORTS*MEMC_TAGBITS-1:0]       xa_rtoken,
//spyglass enable_block W240
    output [NPORTS-1:0]                   grant,
    output [NPORTS-1:0]                   grant_nxt,
    output [NPORTS*QOS_RW-1:0]            pa_pri,
    output [NPORTS-1:0]                   xa_pri,
    output [NPORTS-1:0]                   priority0,
    output [NPORTS*PORT_PRIORITYW-1:0]    port_priority,
    output [NPORTS-1:0]                   xa_exacclock,
    output [NPORTS-1:0]                   xa_alast,
    output [NPORTS-1:0]                   xa_iecclock,
    output [NPORTS-1:0]                   xa_iecclock_end,
    output                                switch_states_en,
    output                                grant_en,

    input                                 reg_ddrc_occap_en,

    output                                pa_parity_err,

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block. 

    // Credit Counters
    input [6:0] lpr_credit_cnt,
    input [6:0] hpr_credit_cnt,
    input [6:0] wr_credit_cnt,
    input [6:0] wrecc_credit_cnt
//spyglass enable_block W240    

    );

   localparam HPR     = 2'b10;
   localparam RD_RTOKEN_REM = MEMC_TAGBITS-A_NPORTS_LG2-AXI_IDW-3;

   genvar gv;

   wire pa_arb_parity_err;
   wire [NPORTS-1:0] pa_port_parity_err;

   assign pa_parity_err = pa_arb_parity_err | (|pa_port_parity_err);

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((PORT_PRIORITYW * (gv + 1)) - 1)' found in module 'DWC_ddr_umctl2_pa'
//SJ: This coding style is acceptable and there is no plan to change it.
   // --------------------------
   // request ports
   // --------------------------
   generate
      for (gv=0; gv<NPORTS; gv=gv+1)
      begin: GEN_U_port
         DWC_ddr_umctl2_pa_port
          #(
               .QOSW                (QOSW), 
               .REG_PORT_PRIORITYW  (REG_PORT_PRIORITYW),
               .PORT_PRIORITYW      (PORT_PRIORITYW), 
               .EXT_PORTPRIO        (EXT_PORTPRIO),
               .PA_OPT_TYPE         (PA_OPT_TYPE), 
               .QOS_RW              (QOS_RW),
               .OCCAP_EN            (OCCAP_EN),
               .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN)             
             )
         U_port (
                  // Outputs
                  .priority0           (priority0[gv]),
                  .port_priority       (port_priority[PORT_PRIORITYW*(gv+1)-1 -: PORT_PRIORITYW]),
                  .pa_pri              (pa_pri[QOS_RW*(gv+1)-1 -: QOS_RW]),
                  .xa_pri              (xa_pri[gv]),
                  .pa_port_parity_err  (pa_port_parity_err[gv]),
                  // Inputs
                  .clk                 (clk),
                  .rst_n               (rst_n),
                  .hif_cmd_stall       (hif_cmd_stall),
                  .req                 (xa_req_masked[gv]),
                  .grant_nxt           (grant_nxt[gv]),
                  .qos                 (xa_qos[QOSW*(gv+1)-1 -: QOSW]),
                  .reg_port_priority   (reg_port_priority[REG_PORT_PRIORITYW*(gv+1)-1 -: REG_PORT_PRIORITYW]),
                  .qos_priority        (xa_qos_priority[QOS_RW*(gv+1)-1 -: QOS_RW]),
                  .urgent              (xa_urgent[gv]),
                  .vpt_expired         (xa_vpt_expired[gv]),
                  .reg_urgent_en       (reg_port_urgent_en[gv]),
                  .reg_aging_en        (reg_port_aging_en[gv]),
                  .reg_ddrc_occap_en   (reg_ddrc_occap_en));
      end // block: GEN_U_port
   endgenerate

   
   // --------------------------
   // arbiter - final stage
   // --------------------------         

   DWC_ddr_umctl2_pa_arb
    #(
         .NPORTS        (NPORTS), 
         .OCCAP_EN      (OCCAP_EN),
         .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
         .PA_OPT_TYPE   (PA_OPT_TYPE))
   U_arb (
           // Outputs 
           .switch_states_en                 (switch_states_en),
           .grant                            (grant[NPORTS-1:0]),
           .grant_nxt                        (grant_nxt[NPORTS-1:0]),
           .grant_en                         (grant_en),
           .pa_arb_parity_err                (pa_arb_parity_err),
           // Inputs
           .clk                        (clk),
           .rst_n                      (rst_n),
           .hif_cmd_stall              (hif_cmd_stall),
           .any_other_stall_condition  (any_other_stall_condition),
           .stall_due_to_mask          (xa_mask_r[NPORTS-1:0]),
           .grant_hold                 (grant_hold[NPORTS-1:0]),
           .req                        (req_pp[NPORTS-1:0]),
           .reg_ddrc_occap_en          (reg_ddrc_occap_en));

   // go2critical signals. If enabled, forces the DDRC to change R/W direction when any of the
   // ports issue urgent signal or an expired vpt requests grant and no credits are available

   generate
      if (RDWR == 1) begin: RD_logic

         // --------------------------
         // go2critical logic
         // --------------------------

         wire              go2critical_rd, go2critical_hpr, go2critical_lpr;
         wire [NPORTS-1:0] xa_rurgent_valid;
         wire [NPORTS-1:0] hpr_blocking_vpr, hpr_hol, lpr_blocking_vpr;
         wire [NPORTS-1:0] rurgent_hpr;
         wire              go2critical_hlpr;

         assign xa_rurgent_valid       = xa_urgent & reg_port_urgent_en;

         // hpr blocking an expired-vpr
         assign hpr_blocking_vpr       = hpr_hol & xa_vpt_expired;
         // lpr blocking an expired-vpr or expired-vpr at the head of the queue
         assign lpr_blocking_vpr       = ~hpr_hol & xa_vpt_expired;
         // rurgent asserted from AXI input and urgent enabled by register
         assign go2critical_rd         =  (reg_go2critical_en) ? |xa_rurgent_valid : 1'b0; 
         // vpr expired inside the FIFO, hpr blocking and no hpr credit
         assign go2critical_hpr        = ~|hpr_credit_cnt & |hpr_blocking_vpr;
         // vpr expired inside the FIFO and lpr blocking and no lpr credit, or vpr expired at the head of the FIFO and no lpr credits
         assign go2critical_lpr        = ~|lpr_credit_cnt & |lpr_blocking_vpr;


         for (gv=0; gv<NPORTS; gv=gv+1) begin: HPR_hol_vpr
            // hpr at the head of the queue
            assign hpr_hol[gv]         = (xa_qos_priority[QOS_RW*(gv+1)-1 -: QOS_RW] == HPR) ? 1'b1 : 1'b0;
         end

         // based on which type of transaction raises the urgent (hpr or lpr/vpr) raise the correct go2critical (priority given to hpr)
         assign rurgent_hpr            = hpr_hol & xa_rurgent_valid;
         assign go2critical_hlpr       = (reg_go2critical_en) ? |rurgent_hpr : 1'b0;

         // assert go2critical_lpr if no hpr port/queue is urgent OR exp-vpr case
         assign hif_go2critical_lpr  = (go2critical_rd & ~go2critical_hlpr) | go2critical_lpr;
         // assert go2critical_hpr if at least 1 hpr port/queue is urgent OR exp-vpr case
         assign hif_go2critical_hpr  = go2critical_hlpr | go2critical_hpr;

         // assert hif_go2critical_l1_lpr if port is urgent but not hpr
         assign hif_go2critical_l1_lpr = (go2critical_rd & ~go2critical_hlpr);
         // assert hif_go2critical_l2_lpr if port is blocking exp-vpr
         assign hif_go2critical_l2_lpr =  go2critical_lpr;

         // assert go2critical_l1_hpr if hpr port/queue is urgent
         assign hif_go2critical_l1_hpr = go2critical_hlpr;
         assign hif_go2critical_l2_hpr = go2critical_hpr;
         // --------------------------
         // Decode Read Token
         // --------------------------
         wire [NPORTS-1:0] xpi_arvalid_iecc, xpi_arlast_iecc, xpi_arlast;
         wire [AXI_IDW-1:0] xpi_arid_unused [NPORTS-1:0];
         wire [RD_RTOKEN_REM-1:0] xpi_rtoken_remain_unused [NPORTS-1:0];
         wire [A_NPORTS_LG2-1:0] port_num_unused [NPORTS-1:0];

         for (gv=0; gv<NPORTS; gv=gv+1)
         begin: GEN_rtoken_decode
            assign {xpi_rtoken_remain_unused[gv],xpi_arvalid_iecc[gv],xpi_arlast_iecc[gv],xpi_arlast[gv],xpi_arid_unused[gv],port_num_unused[gv]} = xa_rtoken[MEMC_TAGBITS*(gv+1)-1 -: MEMC_TAGBITS];
   
            assign xa_iecclock[gv]     = xpi_arvalid_iecc[gv];
            assign xa_iecclock_end[gv] = xpi_arlast_iecc[gv];
            assign xa_alast[gv]        = xpi_arlast[gv];
         end

         assign hif_go2critical_wr  = 1'b0;
         assign xa_exacclock        = 0;
         
         assign hif_go2critical_l1_wr  = 1'b0;
         assign hif_go2critical_l2_wr  = 1'b0;

      end else begin: WR_logic

         // --------------------------
         // Decode Write Data Pointer
         // --------------------------

         wire [NPORTS-1:0] xpi_awvalid_iecc, xpi_awlast_iecc, xpi_wexa_resp_unused, xpi_wexa_acc_unused, xpi_wexa_acc_lock, xpi_wpoison_unused, xpi_w_ocpar_err_unused, vpt_rmw_expired;
         wire [AXI_USERW-1:0] xpi_awuser_unused [NPORTS-1:0];
         wire [AXI_IDW-1:0] xpi_awid_unused [NPORTS-1:0];
         wire [A_NPORTS_LG2-1:0] port_num_unused [NPORTS-1:0];

         for (gv=0; gv<NPORTS; gv=gv+1)
         begin: GEN_wdata_ptr_decode

            //spyglass disable_block W164a
            //SMD: LHS: '{xpi_awvalid_iecc[gv] ,xpi_awlast_iecc[gv] ,xpi_wexa_resp_unused[gv] ,xpi_wexa_acc_unused[gv] ,xpi_wexa_acc_lock[gv] ,xpi_awid_unused[gv] ,xpi_awuser_unused[gv] ,xpi_wpoison_unused[gv] ,xpi_w_ocpar_err_unused[gv] ,port_num_unused[gv]}' width 18 is less than RHS: 'xa_wdata_ptr[((WDATA_PTR_BITS * (gv + 1)) - 1) -:WDATA_PTR_BITS] ' width 19 in assignment
            //SJ: MSB of xa_wdata_ptr (corresponding to xpi_exa_awlast_i) is intentionally ignored
            assign {xpi_awvalid_iecc[gv],xpi_awlast_iecc[gv],xpi_wexa_resp_unused[gv],xpi_wexa_acc_unused[gv],xpi_wexa_acc_lock[gv],xpi_awid_unused[gv],xpi_awuser_unused[gv],xpi_wpoison_unused[gv],xpi_w_ocpar_err_unused[gv],port_num_unused[gv]} = xa_wdata_ptr[WDATA_PTR_BITS*(gv+1)-1 -: WDATA_PTR_BITS];
            //spyglass enable_block W164a

            assign xa_exacclock[gv]    = xpi_wexa_acc_lock[gv];
            assign xa_iecclock[gv]     = xpi_awvalid_iecc[gv];
            assign xa_iecclock_end[gv] = xpi_awlast_iecc[gv];
         end

         // --------------------------
         // go2critical logic
         // --------------------------

         wire              go2critical_wr, go2critical_lpw, go2critical_lpw_ie, go2critical_rmw;
         wire [NPORTS-1:0] xa_wurgent_valid;

         assign xa_wurgent_valid       = xa_urgent & reg_port_urgent_en;
         assign vpt_rmw_expired        = xa_vpt_expired & rmw_dynamic;

         // wurgent asserted from AXI input and urgent enabled by register
         assign go2critical_wr         =  (reg_go2critical_en) ? |xa_wurgent_valid : 1'b0;
         // vpw expired inside the FIFO and no wr credit
         assign go2critical_lpw        = ~|wr_credit_cnt & |xa_vpt_expired;

         if (MEMC_INLINE_ECC==1) begin: IE_en
            assign go2critical_lpw_ie     = ~|wrecc_credit_cnt & |xa_vpt_expired & ie_ecc_enabled;
         end
         else begin: IE_dis
            assign go2critical_lpw_ie     = 1'b0; 
         end

         // rmw expired and no lpr credits
         assign go2critical_rmw        = ~|lpr_credit_cnt & |vpt_rmw_expired;

         assign hif_go2critical_wr   = go2critical_wr | go2critical_lpw | go2critical_lpw_ie;
         assign hif_go2critical_lpr  = go2critical_rmw;
         assign hif_go2critical_hpr  = 1'b0;

         assign xa_alast             = 0;

         assign hif_go2critical_l1_wr  = go2critical_wr;
         assign hif_go2critical_l2_wr  = go2critical_lpw | go2critical_lpw_ie;

         assign hif_go2critical_l1_lpr = 1'b0;
         assign hif_go2critical_l2_lpr = go2critical_rmw;
         assign hif_go2critical_l1_hpr = 1'b0;
         assign hif_go2critical_l2_hpr = 1'b0;
      end
   endgenerate
//spyglass enable_block SelfDeterminedExpr-ML
 
endmodule // DWC_ddr_umctl2_pa
