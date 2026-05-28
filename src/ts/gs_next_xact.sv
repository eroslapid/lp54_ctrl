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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_next_xact.sv#4 $
// -------------------------------------------------------------------------
// Description:
//      This module decides which operation will be issued next.
//      From here, the transaction is flopped in PI and issued by
//      PI to the Phy.
//      This block does not issue bypass commands or commands for
//      cases where a second read or write is required to complete
//      the transfer for a given CAM entry; for both of these
//      this block receives indications fro blocks outside of this
//      this block only prevents commands from being issued in the
//      same cycle.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_next_xact 
import DWC_ddrctl_reg_pkg::*;
#(
  //----------------------------------- PARAMETERS -------------------------------
     parameter    BANK_BITS             = `MEMC_BANK_BITS               // banks in each rank
    ,parameter    NUM_TOTAL_BANKS       = `DDRCTL_DDRC_NUM_TOTAL_BANKS         // total number of banks
    ,parameter    BG_BITS               = `MEMC_BG_BITS
    ,parameter    BG_BANK_BITS          = `MEMC_BG_BANK_BITS
    ,parameter    RANK_BITS             = `MEMC_RANK_BITS               // bits required to address all pysical ranks
    ,parameter    LRANK_BITS            = `DDRCTL_DDRC_LRANK_BITS            // bits required to address all logical ranks
    ,parameter    CID_WIDTH             = `DDRCTL_DDRC_CID_WIDTH             // number of bits for CID
    ,parameter    NUM_RANKS             = `MEMC_NUM_RANKS               // number of physical ranks
    ,parameter    NUM_LRANKS            = `DDRCTL_DDRC_NUM_LRANKS_TOTAL      // number of logical ranks
    ,parameter    NUM_BANKS             = 1 << BANK_BITS                // number of banks
    ,parameter    RANKBANK_BITS         = `DDRCTL_DDRC_RANKBANK_BITS           // bits required to address all ranks
    ,parameter    BSM_BITS              = `UMCTL2_BSM_BITS              // bits required to address all BSM
    ,parameter    NUM_TOTAL_BSMS        = `UMCTL2_NUM_BSM
    ,parameter    MAX_CMD_NUM           = 2

  )
  (
  //------------------------- INPUTS AND OUTPUTS ---------------------------------
     input                                                  co_yy_clk                         // clock
    ,input                                                  core_ddrc_rstn                    // async falling-edge reset

    ,input                                                  dh_gs_2t_mode                     // 1 = 2T mode, 0 = regular mode
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current implementation.
    ,input                                                  dh_gs_frequency_ratio             // 1 = 1:1 mode, 0 = 1:2 mode
//spyglass enable_block W240
    ,input                                                  dh_gs_sw_init_int
    ,input                                                  gs_sw_init_int_possible

    //// Various inputs for scheduling, from DH, IH, TE, PI, and RA ////
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in RTL assertions
    ,input                                                  ih_gs_xact_valid                  // New transaction from IH to TE/TS (rd or wr)
//spyglass enable_block W240
    ,input                                                  pi_gs_noxact                      // PI is re-issuing a command for 2T
    ,input                                                  pi_gs_stop_clk_early              // PI is stopping clocks
    ,input      [1:0]                                       pi_gs_stop_clk_type
    ,output                                                 clock_stop_exited                 // Signal to FSM that clock stop has exited
    ,input      [DFI_T_CTRL_DELAY_WIDTH-1:0]                                       reg_ddrc_dfi_t_ctrl_delay
    ,input      [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_enable
    ,input      [T_CKSRX_WIDTH-1:0]                         reg_ddrc_t_cksrx
    ,input      [T_CKCSX_WIDTH-1:0]                         reg_ddrc_t_ckcsx

    //// OS Inputs: valid & rank/bank # for each transaction type ////
    ,input                                                  os_gs_act_hi_vld                  // high priority activate pending
    ,input      [BSM_BITS-1:0]                              os_gs_act_hi_bsm                  // BSM number of the chosen hi priority activate
    ,input                                                  os_gs_rdwr_hi_vld                 // high priority read pending (no hp writes)
    ,input      [BSM_BITS-1:0]                              os_gs_rdwr_hi_bsm                 // BSM number of the chosen hi priority read/write
    ,input                                                  reverse_priority                  // reverse priority to allow low priority
    // reads to complete (for starvation prevention)
    ,input                                                  os_gs_act_lo_vld                  // high priority activate pending
    ,input      [BSM_BITS-1:0]                              os_gs_act_lo_bsm                  // BSM number of the chosen lo priority activate
    ,input                                                  os_gs_rdwr_lo_vld                 // low priority read/write pending
    ,input      [BSM_BITS-1:0]                              os_gs_rdwr_lo_bsm                 // BSM number of the chosen lo priority read/write
    ,input                                                  os_gs_pre_crit_vld                // critical precharge pending
    ,input      [BSM_BITS-1:0]                              os_gs_pre_crit_bsm                // BSM number of the chosen critical precharge
    ,input                                                  os_gs_pre_req_vld                 // requested precharge pending
    ,input      [BSM_BITS-1:0]                              os_gs_pre_req_bsm                 // BSM number of the chosen requested precharge
    ,input                                                  os_gs_act_wr_vld                  // activate for write pending
    ,input      [BSM_BITS-1:0]                              os_gs_act_wr_bsm                  // BSM number of the chosen activate write
    ,input                                                  gs_act_pre_rd_priority                  // indicate rdwr for ativate/precharge
    ,input      [NUM_RANKS-1:0]                             os_gs_rank_closed                 // '1' for each rank with all banks closed
                                                                                              // (for DDR4 3DS configuration, all banks within physical rank are closed)
    ,input      [NUM_RANKS-1:0]                             os_gs_rank_closed_for_ref         // '1' for each rank with all banks closed for Refresh
                                                                                              // (for DDR4 3DS configuration, all banks within a logical rank indicated by rank_refresh_cid are closed)
    ,input      [NUM_RANKS*8-1:0]                           os_gs_bank_closed

    //// Intra-GS inputs ////
    ,input                                                  wr_mode                           // write mode: performing writes
    ,input                                                  normal_operating_mode             // controller has 4 modes: normal,
    ,input                                                  init_operating_mode               // initialization
    ,input      [NUM_RANKS-1:0]                             os_gs_no_2ck_cmds_after_pre       // blocks 2-cycles commands after PRE or commands w/AP
    ,input                                                  sr_mrrw_en                        // MRR/MRW enable during Self refresh for LPDDR4
    ,input                                                  block_zqlat
    ,input      [NUM_RANKS-1:0]                             rank_block_pre                    // block precharge command per rank
    ,input      [NUM_RANKS-1:0]                             rank_refresh_required             // critical refresh required
    ,input      [NUM_RANKS-1:0]                             rank_speculative_ref              // refresh timer expired at least once
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in coverpoint and under different `ifdefs
    ,input      [NUM_RANKS-1:0]                             rank_nop_after_refresh            // NOP required after a refresh
//spyglass enable_block W240
    ,input      [NUM_RANKS-1:0]                             rank_no_refresh_after_refresh     // delay between 2 refresh commands (Include 16REF/2*tREFI logic)
    ,input      [NUM_RANKS-1:0]                             rank_no_load_mr_after_refresh     // no load MR required after a refresh (include DDR4 MPR RD/WR)
    ,input      [NUM_RANKS-1:0]                             rank_no_refpb_after_act           // delay between ACT and REFpb = tRRD
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
    ,input                                                  global_block_rd                   // no read allowed this cycle (for bus turnaround)
//spyglass enable_block W240

    ,input      [NUM_RANKS-1:0]                             rank_nop_after_zqcs               // NOP required after a ZQ Calib Short
    ,input                                                  zqcl_due_to_sr_exit_ext           // ZQCL request is due to self-refresh exit
                                                                                              // this command to be given preference over critical refresh
//  `ifdef MEMC_LPDDR4
//    ,input                                                  load_mr_mrs_a_norm_zq_lpddr2
//  `endif // MEMC_LPDDR4

    ,input      [NUM_RANKS-1:0]                             load_mr_norm_required             // load MR request
    ,input      [NUM_RANKS-1:0]                             rank_nop_after_load_mr_norm       // NOP required after MR load
    ,output                                                 load_mr_norm                      // load MR issued - used in GS
    ,output                                                 gs_pi_op_is_load_mr_norm          // load MR issed - going to PI
    ,input                                                  gs_pi_mrr                         // MRR due to internal derating operation
    ,input                                                  gs_pi_mrr_ext                     // MRR due to external MRR request

    //// Bypass Outputs ////

    ,input      [NUM_RANKS-1:0]                             dh_gs_rank0_wr_odt                // ODT settings for each rank
  //// Exit self-refresh to next commands control ////
    ,input                                                  block_t_xs                        // block during tXS period
    ,input                                                  block_t_xs_dll                    // block during tXSDLL period


    //// Operation Indicators to BE, BS, OS, TE, PI, and MR ////
    ,output                                                 gs_op_is_rd                       // read command issued to DRAM
    ,output                                                 gs_op_is_rd_hi                    // read command issued to DRAM
    ,output                                                 gs_op_is_rd_lo                    // read command issued to DRAM
    ,output                                                 gs_op_is_wr                       // write command issued to DRAM
    ,output                                                 gs_op_is_act                      // activate command issued to DRAM
    ,output                                                 gs_op_is_pre                      // precharge command issued to DRAM
    ,output                                                 gsnx_op_is_ref                    // refresh command (used within GS)
    ,output                                                 gs_op_is_cas_ws_off               // CAS-WS_OFF command


    ,output     [BSM_BITS-1:0]                              gs_rdwr_bsm_num                   // BSM # for read & write commands
    ,output     [BSM_BITS-1:0]                              gs_act_bsm_num                    // BSM # for activate
    ,output     [BSM_BITS-1:0]                              gs_pre_bsm_num                    // BSM # for precharge
    ,output     [RANKBANK_BITS-1:0]                         gs_pre_rankbank_num               // the bank used in the CAM search
    ,output     [RANKBANK_BITS-1:0]                         gs_rdwr_rankbank_num              // the bank used in the CAM search
    ,output     [RANKBANK_BITS-1:0]                         gs_act_rankbank_num               // the bank used in the CAM search


    ,input      [NUM_RANKS*BANK_BITS-1:0]                   gs_refpb_bank                     // bank number of REFpb operations for each rank
    ,input      [NUM_RANKS-1:0]                             gs_lpddr54_refpb                   // input from rank_constraints
    ,output     [BANK_BITS-1:0]                             gs_pi_refpb_bank
    ,output                                                 gs_cas_ws_req
    ,input      [NUM_RANKS-1:0]                             wck_sync_st
    ,input      [NUM_RANKS-1:0]                             cas_ws_off_req
    ,input                                                  gs_op_is_enter_powerdown
    ,input                                                  gs_op_is_enter_selfref
    ,input                                                  gs_op_is_enter_dsm
    ,input                                                  gs_cas_cmd_disable
    ,input                                                  pi_lp5_noxact
    ,input                                                  pi_lp5_preref_ok
    ,input                                                  pi_rdwr_ok
    ,input                                                  pi_col_b3
                                                                                              // - indicate when REFpb is performed for LPDDR4



    ,input                                                  dh_gs_per_bank_refresh
    ,input                                                  refab_forced
    ,input                                                  rdwr2mrw_satisfied
    ,input                                                  mrri_satisfied
    ,input      [NUM_LRANKS-1:0]                            block_mrr2mrw
    ,input                                                  init_refresh
    ,input                                                  dh_gs_lpddr4
    ,input                                                  reg_ddrc_lpddr5
    ,input                                                  no_sr_mrrw_due_to_phymstr
    ,input                                                  reg_ddrc_dis_opt_ntt_by_act  
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
    ,input      [REFRESH_TO_X1_X32_WIDTH-1:0]               dh_gs_refresh_to_x1_x32
    ,input      [NUM_LRANKS-1:0]                            lrank_speculative_ref             // refresh timer expired at least once
    ,input      [NUM_RANKS-1:0]                             rank_ref_idle_timeout
    ,input      [NUM_LRANKS*NUM_BANKS-1:0]                  bank_speculative_ref
    ,input      [NUM_LRANKS-1:0]                            os_gs_lrank_closed                // Rank closed signal for logical ranks

    ,output     [NUM_RANKS-1:0]                             rank_next_ref_bank_closed_sva
  `endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
   ,input  [NUM_TOTAL_BSMS-1:0]                             sel_act_wr       
   ,input                                                  te_gs_block_wr
  );

//---------------------------- LOCAL PARAMETERS --------------------------------
localparam  BANKS_PER_RANK      = NUM_TOTAL_BANKS / NUM_LRANKS; // banks in each rank

localparam  BSM_BANK_BITS       = BSM_BITS
                                  ;

//--------------------------------- WIRES --------------------------------------

   // Intermediate indicators for making operation selection
   wire                               no_ops_allowed;        // GS not allowed to schedule this cycle
   wire                               critical_cmd;          // critical pre or ref this cycle
   wire                               no_critical_cmd;       // no critical pre or ref this cycle
   wire                               critical_global_cmd;   // critical pre or ref this cycle
   wire                               no_critical_global_cmd;// no critical pre or ref this cycle
   wire                               no_rdwr_cmd;           // no read or write command possible
   wire  [NUM_RANKS-1:0]              critical_ref_possible_wo_trrd; // critical refresh pending to a closed rank
   wire  [NUM_RANKS-1:0]              critical_ref_possible; // critical refresh pending to a closed rank
   wire  [NUM_RANKS-1:0]              speculative_ref_possible; // requested refresh pending to a closed rank

   wire                               no_sr_mrrw_allowed;    // MRR/MRW enable during Self refresh for LPDDR4

   wire  [NUM_RANKS-1:0]              load_mr_norm_possible; // load_mr pending to a closed rank

   wire                               rd_is_hi;              // if a read is chosen, it will be hi pri
   wire                               rd_is_hi_nobypass;     // if a read is chosen, it will be hi pri


//// Bank selection (using operations chosen above)
   wire  [BSM_BANK_BITS-1:0]          bsm_chosen_rdwr;      // the bank that will be used if a read or write transaction is performed
   wire  [BSM_BANK_BITS-1:0]          bsm_chosen_pre;       // bank selected for next/current pre command
   wire  [BSM_BANK_BITS-1:0]          bsm_chosen_act;       // the bank that will be used if an activate is performed
   wire  [NUM_RANKS-1:0]              gs_pre_cs_n;
   wire     sync_odt_wr; // Synchronous ODT for write pending
   //// Final operation selection
   wire                               choose_ref_crit;        // choose critical refresh
   wire                               choose_ref_req;         // choose a requested refresh
   wire                               choose_act;             // choose activate command
   wire                               choose_rd;              // choose read command
   wire                               choose_wr;              // choose write command
   wire                               choose_pre;             // choose precharge command
   wire                               choose_pre_req;         // choose requested precharge
   wire                               choose_pre_crit;        // choose critical precharge
   wire                               choose_load_mr_norm;    // choose load mr during normal operation of controller
   wire                               choose_rdwr;

   wire                               no_simul_cmd_pre;       // no simultaneous command with PRE
   wire                               no_simul_cmd_ref;       // no simultaneous command with REF

   reg  [1:0]                         r_rd;                   // last cycle was a read

   // early flopped indications that bypass must be turned off


  wire [BSM_BANK_BITS-1:0]            act_hi_bsm_bank;
  wire [BSM_BANK_BITS-1:0]            rdwr_hi_bsm_bank;
  wire [BSM_BANK_BITS-1:0]            act_lo_bsm_bank;
  wire [BSM_BANK_BITS-1:0]            rdwr_lo_bsm_bank;
  wire [BSM_BANK_BITS-1:0]            pre_crit_bsm_bank;
  wire [BSM_BANK_BITS-1:0]            pre_req_bsm_bank;
  wire [BSM_BANK_BITS-1:0]            act_wr_bsm_bank;

  assign act_hi_bsm_bank   = {os_gs_act_hi_bsm };
  assign rdwr_hi_bsm_bank  = {os_gs_rdwr_hi_bsm };
  assign act_lo_bsm_bank   = {os_gs_act_lo_bsm };
  assign rdwr_lo_bsm_bank  = {os_gs_rdwr_lo_bsm };
  assign pre_crit_bsm_bank = {os_gs_pre_crit_bsm };
  assign pre_req_bsm_bank  = {os_gs_pre_req_bsm };
  assign act_wr_bsm_bank   = {os_gs_act_wr_bsm };


wire rdwr_pol_sel;
assign rdwr_pol_sel = 
               1'b1; 

//-----------------------------------------------------------
// postpone_pda_cnt is used only when PDA mode
//-----------------------------------------------------------

//-----------------------------------------------------------
// Register load_mr_norm to prevent command in following cycle for RDIMMs
//-----------------------------------------------------------


//--------------------------------------------------------------------
  // LOGIC TO PREVENT WR in next cycle of ACT for Read
  reg block_wr_this_cycle;
  reg block_rd_this_cycle;
  always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
      block_wr_this_cycle  <= 1'b0;
      block_rd_this_cycle  <= 1'b0;
    end
    else begin
      block_wr_this_cycle <= (reg_ddrc_dis_opt_ntt_by_act )? 1'b0 : // Feature disabled
                              (gs_op_is_act &
                               ( rdwr_pol_sel ? ~sel_act_wr[gs_act_bsm_num] : ~wr_mode))
                           ;
      block_rd_this_cycle <= (reg_ddrc_dis_opt_ntt_by_act )? 1'b0 : // Feature disabled
                              (gs_op_is_act &
                               ( rdwr_pol_sel ? sel_act_wr[gs_act_bsm_num] : wr_mode));
    end
  end
//--------------------------------------------------------------------

   //============================ combinatorial logic ============================/

   // determine if GS is allowed to schedule something this cycle
   assign no_ops_allowed   = (~normal_operating_mode
                                & ~(dh_gs_sw_init_int & gs_sw_init_int_possible)
                             )
                             | (!clock_stop_exited)
                             // | pi_gs_noxact
                             ;

   assign no_sr_mrrw_allowed = (~sr_mrrw_en
                                & ~(dh_gs_sw_init_int & gs_sw_init_int_possible)
                               )
                               | (!clock_stop_exited)
                               | pi_gs_noxact
                               | no_sr_mrrw_due_to_phymstr;

    //------------------------------- bypass stuff -------------------------------//


   //----------------------------- end bypass stuff -----------------------------//

   //---------------- intermediate logic for operation selection ----------------//


    // determine if we can issue refreshes.  1 bit per rank.
    // (requested refresh gets upgraded to critical when DFI controller update is due)
    // refresh_request AND ranks are closed AND not waiting for tRFC(min) AND not of activate requests
    wire [NUM_RANKS-1:0] load_mr_norm_req_rank;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((8 * gen_ranks) + gs_refpb_bank[(gen_ranks * BANK_BITS) +:BANK_BITS] )' found in module 'gs_next_xact'
//SJ: This coding style is acceptable and there is no plan to change it.

    // determine if the next bank to be refreshed in each rank is closed
    wire [NUM_RANKS-1:0] rank_next_ref_bank_closed;
//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index '((8 * gen_ranks) + gs_refpb_bank[(gen_ranks * BANK_BITS) +:BANK_BITS] )' of width '4' is larger than the width '3' required for the max value '7' of the signal 'os_gs_bank_closed'
//SJ: SpyGlass sees the index as a self-determined expression and considers the carry bit. Overflow cannot occur in these cases.
    genvar  gen_ranks;
    generate
        for (gen_ranks=0; gen_ranks<NUM_RANKS; gen_ranks=gen_ranks+1) begin : ref_bank_closed
            assign rank_next_ref_bank_closed[gen_ranks] = os_gs_bank_closed[8*gen_ranks+gs_refpb_bank[gen_ranks*BANK_BITS+:BANK_BITS]];
        end
    endgenerate
//spyglass enable_block ImproperRangeIndex-ML
//spyglass enable_block SelfDeterminedExpr-ML


    // ---------------------------------------------
    //  internal refresh requests
    // ---------------------------------------------
    wire [NUM_RANKS-1:0] i_rank_refresh_required;
    wire [NUM_RANKS-1:0] spec_ref_req;
    wire [NUM_RANKS-1:0] crit_ref_req_wo_no_2ck_cmds;
    wire [NUM_RANKS-1:0] crit_ref_req;

    // TODO: This should be replaced with crit_ref_req (Enhancement)
    assign i_rank_refresh_required      = rank_refresh_required
                                        & (~rank_no_refresh_after_refresh)
                                        ;
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in MEMC_LPDDR4 and DDRCTL_DDRC_CID_EN configs and in RTL assertion. Keeping these always defined for debug purposes.
    assign spec_ref_req                 = rank_speculative_ref
                                        & (~rank_nop_after_zqcs)
                                        & (~rank_nop_after_load_mr_norm)
                                        & (~rank_no_refresh_after_refresh)
                                        & (~os_gs_no_2ck_cmds_after_pre)
                                        & (refab_forced ? (~rank_nop_after_refresh) : {NUM_RANKS{1'b1}})
                                        & (dh_gs_per_bank_refresh ?
                                           rank_next_ref_bank_closed : os_gs_rank_closed_for_ref)
                                        ;

    assign crit_ref_req_wo_no_2ck_cmds  = rank_refresh_required
                                        & (~rank_nop_after_zqcs)
                                        & (~rank_nop_after_load_mr_norm)
                                        & (~rank_no_refresh_after_refresh)
                                        & (refab_forced ? (~rank_nop_after_refresh) : {NUM_RANKS{1'b1}})
                                        & (dh_gs_per_bank_refresh ?
                                           rank_next_ref_bank_closed : os_gs_rank_closed_for_ref)
                                        ;

    assign crit_ref_req                 = crit_ref_req_wo_no_2ck_cmds
                                        & (~os_gs_no_2ck_cmds_after_pre)
                                        ;
//spyglass enable_block W528

    // ---------------------------------------------
    //  LPDDR4 per-bank refresh
    // ---------------------------------------------
    // In case of LPDDR4, if REFpb is requested to multiple ranks,
    // only one rank is allowed because a command contains bank address
    wire [NUM_RANKS-1:0] spec_lpddr4_ref_possible;
    wire [NUM_RANKS-1:0] crit_lpddr4_ref_possible;

    assign spec_lpddr4_ref_possible     = 
                                        spec_ref_req ;
    assign crit_lpddr4_ref_possible     = 
                                         crit_ref_req_wo_no_2ck_cmds ;



   assign speculative_ref_possible[NUM_RANKS-1:0] =
                                                        spec_lpddr4_ref_possible &
                                                        rank_speculative_ref &
                                                        (dh_gs_per_bank_refresh ? (rank_next_ref_bank_closed & (~rank_no_refpb_after_act)) : os_gs_rank_closed_for_ref) &
                                                        (~rank_nop_after_zqcs) &
                                                        (~rank_no_refresh_after_refresh) &
                                                        (~rank_nop_after_load_mr_norm) &
                                                        (((~{NUM_RANKS{os_gs_act_lo_vld}}) & (~{NUM_RANKS{os_gs_act_hi_vld}}))
                                                         | {NUM_RANKS{reg_ddrc_lpddr5 & pi_lp5_preref_ok}}
                                                        )
                                                      & (~{NUM_RANKS{os_gs_act_wr_vld}})
;

    assign critical_ref_possible_wo_trrd[NUM_RANKS-1:0]   =
                                                        // DRAM does not need refresh command while uMCTL2 issues MRR/MRW during self refresh
                                                        {NUM_RANKS{!sr_mrrw_en}} &
                                                        crit_lpddr4_ref_possible &
                                                        i_rank_refresh_required &
                                                         (dh_gs_per_bank_refresh ? rank_next_ref_bank_closed : os_gs_rank_closed_for_ref) &
                                                        (~rank_nop_after_zqcs) &
                                                        (~rank_nop_after_load_mr_norm);

    assign critical_ref_possible[NUM_RANKS-1:0]   =
                                                        (dh_gs_per_bank_refresh ? (~rank_no_refpb_after_act) : {NUM_RANKS{1'b1}}) &
                                                        (~os_gs_no_2ck_cmds_after_pre) &
                                                        critical_ref_possible_wo_trrd;


    assign load_mr_norm_req_rank    = load_mr_norm_required & os_gs_rank_closed
                                    & (~rank_nop_after_zqcs)
                                    & (~rank_nop_after_load_mr_norm)
                                    & (~rank_no_load_mr_after_refresh)
                                    ;

    assign load_mr_norm_possible[NUM_RANKS-1:0] =  (load_mr_norm_req_rank == load_mr_norm_required) ? load_mr_norm_required
                                                & {NUM_RANKS{rdwr2mrw_satisfied}} & {NUM_RANKS{mrri_satisfied}}
                                                : {NUM_RANKS{1'b0}};

   // determine if there is a critical command to service
   assign critical_cmd  = os_gs_pre_crit_vld           |  // critical precharge
        (  zqcl_due_to_sr_exit_ext ) |
        (|(critical_ref_possible)  ) |  // critical refresh possible
        (|(load_mr_norm_possible))      // load_mr_norm possible
       ;

   assign critical_global_cmd  = 
        (  zqcl_due_to_sr_exit_ext ) |
        (|(load_mr_norm_possible))      // load_mr_norm possible
       ;

   assign no_critical_cmd  = ~critical_cmd;
   assign no_critical_global_cmd  = ~critical_global_cmd;

   // high-priority read.
   assign rd_is_hi      = os_gs_rdwr_hi_vld & (~reverse_priority | (~os_gs_rdwr_lo_vld));
   // Assumption: hi pri requests won't be asserted during writes
   assign no_rdwr_cmd   = wr_mode ? (~(os_gs_rdwr_lo_vld)) :
                                    ~(os_gs_rdwr_hi_vld | os_gs_rdwr_lo_vld);

   //------------------- end normal mode operation selection --------------------//

   //------------------------ final command selection ---------------------------//
    // choose critical precharge any time one is pending when GS can schedule
    // (critical precharge is the highest priority operation)
    assign choose_pre_crit  = os_gs_pre_crit_vld & (~block_t_xs)
                            & (~no_ops_allowed)
                            & ((~pi_gs_noxact)
                               | (reg_ddrc_lpddr5 & pi_lp5_preref_ok)
                              )
                            & (~zqcl_due_to_sr_exit_ext)
                            // In LPDDR4, blocks an extra cycles after ACT/RD/WR/MWR/REF to different bank of same rank
                            & ~(|(~gs_pre_cs_n & rank_block_pre))
                            ;

    // choose to issue critical refresh if all of the following are true:
    //   * no critical precharge pending
    //   * a rank has critical refresh pending, and rank constraints don't prevent it (=critical_ref_possible)
    //   * ZQCL pending due to Self-refresh exit - this request should be given preference over refresh
    assign choose_ref_crit  = (~block_t_xs) & (|critical_ref_possible) &
                              // In LPDDR4 SW1:4 mode, both REF and PRE can be issued at same time.
                              ((~os_gs_pre_crit_vld) | (dh_gs_lpddr4 & dh_gs_frequency_ratio)) &
                              (~zqcl_due_to_sr_exit_ext
                              )
                            ;


    // choose to issue ZQ CS if all of the following are true:
    //   * no critical precharge pending
    //   * no critical refresh pending, except when a ZQCL due to self-refresh is pending
    //   * when ZQCL due to self-refresh is there, then ZQCL gets preference over refresh
    //   * a rank has ZQ CS pending, and rank constraints don't prevent it (=zq_calib_short_possible)
    //   * if a rank is not active, no need to check for zq_calib_short_possible
    //   * ZQ is issued for all ranks together, hence the &

  reg  [3:0] i_mrr_block_cnt;
  wire [3:0] i_mrr_block_cnt_val;
  wire       i_mrr_block;

  // MRR is on upper lane if FR2
  // RD is on lower lane in  FR2
  // LPDDR4/5, BL16 for MRR and change the start point of measure regarding timing parameter
    assign i_mrr_block_cnt_val = (4'b0110 >> dh_gs_frequency_ratio);
//    assign i_mrr_block_cnt_val = 1;

  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_mrr_block_cnt <= 4'b0000;
  end else begin
    if (choose_load_mr_norm) begin
      i_mrr_block_cnt <= i_mrr_block_cnt_val;
    end else if (i_mrr_block_cnt>0) begin
      i_mrr_block_cnt <= i_mrr_block_cnt - 1;
    end
  end
end

  assign i_mrr_block = (i_mrr_block_cnt>0) ? 1'b1 : 1'b0;






   // choose to issue load MR Norm if all of the following are true:
   //   * no critical precharge pending
   //   * no critical refresh pending, except when a ZQCL due to self-refresh is pending
   //   * when ZQCL due to self-refresh is there, then ZQCL gets preference over refresh
   //   * in LPDDR4 mode, ZQCL request comes as a load mode request, hence that has to be given preference over refresh
   //   * no ZQCS pending
   //   * for MRRs, reads are not blocked
   //   * load_mr_norm is possible
   //
   //-----------------------------------------------------------------------
   //  Two consecutive MRS commands should be issued automatically
   //  once it enters into in PDA mode even if there are any other requests
   //  NOTE: Any request does not prevent issuing MRS in PDA mode
   //-----------------------------------------------------------------------

   assign choose_load_mr_norm = ~os_gs_pre_crit_vld &
                              (~((|critical_ref_possible)
                                )
                               || (zqcl_due_to_sr_exit_ext & (dh_gs_lpddr4)) // ZQ done via MRW in LPDDR4
                              ) &
                                (~(global_block_rd & (gs_pi_mrr | gs_pi_mrr_ext))) &
                                (~i_mrr_block)  &
                                (~(|(block_mrr2mrw[NUM_RANKS-1:0] & load_mr_norm_possible) & ~(gs_pi_mrr | gs_pi_mrr_ext))) &
                                (~gs_cas_cmd_disable) &
                                // do not overlap with ZQ command, to any rank
                                // take into account whether it's MRR
                                // if MRR, wait for tZQCS/tZQCL in all ranks to complete
                                ((gs_pi_mrr || gs_pi_mrr_ext) ? (~(|rank_nop_after_zqcs)) : 1'b1) &
                                // ---- Block for a delay after SRX ----
                                (~block_t_xs) &
                                // do not generate MPC(ZQ Latch) in LPDDR4 until DQ-ODT turn off
                                (~block_zqlat) &
                                (|load_mr_norm_possible);

    // Selecting reads and writes
    // Bypass doesn't count as a read here
    // NOTE: Don't schedule a read at the same time as bypass can happen, even
    //       if retry prevents the bypass from actually occurring.  This "even if"
    //       clause is required for timing - factoring retry takes too long.
    //       (This also requires that bypass_disable be asserted when the
    //        flopped retry is asserted to avoid a lock-up when a bypass-able
    //        read collides with an RMW that requires a read flush.)
    // in 2T mode, in half-speed, read is scheduled only if there are no pending critical commands
    // In LPDDR2/LPDDR3, for MRR, block MRR for BL4/BL8 to ensure data from prev MRR is complete via i_mrr_block
    //
    assign choose_rd    = (os_gs_rdwr_hi_vld | os_gs_rdwr_lo_vld)
                        & (~(block_rd_this_cycle)) // to prevent RD in next cycle of ACT for WR
                        & (~wr_mode)
                        & (no_critical_global_cmd)
                        & (~block_t_xs_dll)
                        & (~no_ops_allowed)
                        & ((~pi_gs_noxact)
                           | (pi_rdwr_ok & reg_ddrc_lpddr5)
                          )
                        & (no_critical_cmd)
                        & (~i_mrr_block)
                        & (~gs_cas_cmd_disable)
                        // do not overlap with ZQ command, to any rank
                        & (~(|rank_nop_after_zqcs))
                        ;

    // Synchronous ODT for write pending
    assign sync_odt_wr = (
                         dh_gs_rank0_wr_odt[0]
                        )
                        ;



    // in 2T mode, in half-speed, write is scheduled only if there are no pending critical commands
    assign choose_wr    = (os_gs_rdwr_lo_vld) & wr_mode 
                        & (no_critical_global_cmd) 
                        & (~(block_wr_this_cycle)) // to prevent RD in next cycle of ACT for WR
                        & (~(te_gs_block_wr)) // Write combine and ACT are scheduled at the same cycle to the same bank. replace logic is used in this cucle again hence block write
                        & (~(block_t_xs | (block_t_xs_dll & (sync_odt_wr
                        ))))
                        & (~no_ops_allowed)
                        & ((~pi_gs_noxact)
                           | (pi_rdwr_ok & reg_ddrc_lpddr5)
                          )
                        & (no_critical_cmd)
                        & (~gs_cas_cmd_disable)
                    // do not overlap with ZQ command, to any rank
                        & (~(|rank_nop_after_zqcs))
                        ;


    // 1:2 config, running in 1T mode: RWA are scheduled in odd cycle and Pre in even cycle
    //   So PRE can be executed even when there are pending Rd/Wr/Act
    //   There is one exception to this. It is possible to get a PRE and a Bypass Read request to the same bank/page in the same cycle (bug 1798)
    //   In this case, the PRE should be blocked from going out as otherwise it will result in tRTP violation
    //   One limitation with this fix is that, PRE is going to be blocked for every bypass read command and no bank/page check is done here.
    // 1:2 config, running in 2T mode: RWA and PRE are scheduled just like in 1:1 config, and hence the same rules as 1:1 mode apply
    assign no_simul_cmd_pre =
                                    ( // when DFI command is scheduled across odd and even cycles
                                        ((~choose_rdwr) |
                                         (reg_ddrc_lpddr5 && !gs_cas_ws_req && (wr_mode || !pi_col_b3)))  // RD/WR without CAS_WS
                                        & (~((reverse_priority ? (os_gs_act_lo_vld & gs_act_pre_rd_priority) : ((os_gs_act_hi_vld & gs_act_pre_rd_priority))) | (os_gs_act_wr_vld & ~gs_act_pre_rd_priority)))
                                    );

    assign no_simul_cmd_ref = no_simul_cmd_pre;

   // te_gs_retry->no_rdwr_cmd is the critical input here.  using parenthesis
   //  to try to optimize this path
   // NOTE: Precharge bypass does not count as a precharge here
   // NOTE: This is lower priority than refresh
    assign choose_pre_req   = os_gs_pre_req_vld
                            & (no_critical_cmd | (dh_gs_frequency_ratio & dh_gs_lpddr4 & no_critical_global_cmd & ~os_gs_pre_crit_vld)) 
                            //In LPDDR4 frequency ration 1:4 mode, REF and PRE command can be issued same time.
                            & ((dh_gs_frequency_ratio & dh_gs_lpddr4) | ((~(|speculative_ref_possible)) & (~(|critical_ref_possible))))
                            & (~block_t_xs)
                            & (~no_ops_allowed)
                            & ((~pi_gs_noxact)
                               | (reg_ddrc_lpddr5 & pi_lp5_preref_ok)
                              )
                            & no_simul_cmd_pre
                            // In LPDDR4, blocks an extra cycles after ACT/RD/WR/MWR/REF to different bank of same rank
                            & ~(|(~gs_pre_cs_n & rank_block_pre))
                            ;

   // Choose activate if:
   //  * no read/write command AND          <-- this is the critical path when bypass is used
   //  * [(any activate req w/o pre req) OR (high pri act, where "hi" depends on reverse_priority)] AND
   //  * no critical command AND
   //  * GS can schedule this cycle
    assign choose_act   = (no_rdwr_cmd
                           | (reg_ddrc_lpddr5 && !gs_cas_ws_req && (wr_mode || !pi_col_b3) && !pi_lp5_preref_ok)    // RD/WR without CAS
                           )
                        & (no_critical_global_cmd)
                        & (~block_t_xs)
                        & (~no_ops_allowed)
                        & (~pi_gs_noxact)
                        & (~dh_gs_2t_mode || (dh_gs_2t_mode && no_critical_cmd))
                        & (~(|(critical_ref_possible_wo_trrd
                              )))
                        & (no_critical_cmd)
                        & (
                           (~choose_ref_req &
                            (((reverse_priority ? (os_gs_act_lo_vld & gs_act_pre_rd_priority) : (os_gs_act_hi_vld & gs_act_pre_rd_priority)) | (os_gs_act_wr_vld & ~gs_act_pre_rd_priority))                   |   // HP act
                            ((os_gs_act_hi_vld | os_gs_act_lo_vld | os_gs_act_wr_vld) & ~os_gs_pre_req_vld)                    // LP act
                            )
                           )
                          )

                        // do not overlap with ZQ command, to any rank
                        & (~(|rank_nop_after_zqcs))
                        ;

    assign choose_ref_req   = (no_critical_cmd
                            | (dh_gs_frequency_ratio & dh_gs_lpddr4 & no_critical_global_cmd)
                            )

                            &
                              (~zqcl_due_to_sr_exit_ext)
                            & (|speculative_ref_possible)
                            & (~block_t_xs)
                            & (~no_ops_allowed)
                            & ((~pi_gs_noxact)
                               | (reg_ddrc_lpddr5 & pi_lp5_preref_ok)
                              )
                            & no_simul_cmd_ref
                            ;

   // allow precharge in normal or powerdown mode IF ((not stalled) OR (cmd is critical))
   assign choose_pre  = choose_pre_crit | choose_pre_req;
   //---------------------- end final command selection -------------------------//

   //----------------------------- bank selection -------------------------------//

   // Select bank for reads & writes; ignore bypass, since GS bank # is don't-care for bypass
   assign rd_is_hi_nobypass     = os_gs_rdwr_hi_vld & (~reverse_priority | (~os_gs_rdwr_lo_vld));
   assign bsm_chosen_rdwr      = ((wr_mode) | ( (~rd_is_hi_nobypass))) ? rdwr_lo_bsm_bank : rdwr_hi_bsm_bank;

   // Selecting the precharge bank - For Group 1 signals - only precharge requires bank
   // selfrefresh or refresh doesn't require bank
   assign bsm_chosen_pre        = os_gs_pre_crit_vld ? pre_crit_bsm_bank : pre_req_bsm_bank;

   // Selecting the activate bank
wire [BSM_BANK_BITS-1:0] bsm_chosen_act_wr;
wire [BSM_BANK_BITS-1:0] bsm_chosen_act_rd;
   assign bsm_chosen_act_rd       = ((reverse_priority & os_gs_act_lo_vld) | (~reverse_priority & ~os_gs_act_hi_vld)) ? act_lo_bsm_bank : act_hi_bsm_bank;
                                                                            
   assign bsm_chosen_act_wr       =
                                        act_wr_bsm_bank;

   assign bsm_chosen_act =         ((gs_act_pre_rd_priority & (os_gs_act_lo_vld | os_gs_act_hi_vld)) | (~gs_act_pre_rd_priority & (~os_gs_act_wr_vld))) ? bsm_chosen_act_rd : bsm_chosen_act_wr;

   // slightly-simplified versions of bank chosen specifically for reads/writes
   //  and for acts/precharges.  these separate versions help us avoid
   //  creating false paths as well as reduce the paths themselves for BE,
   //  which uses these 2 banks differently

   assign gs_rdwr_bsm_num      = bsm_chosen_rdwr;
   assign gs_act_bsm_num       = bsm_chosen_act;
   assign gs_pre_bsm_num       = bsm_chosen_pre;

   assign gs_pre_rankbank_num  = bsm_chosen_pre [0+:RANKBANK_BITS];
   assign gs_act_rankbank_num  = bsm_chosen_act [0+:RANKBANK_BITS];
   assign gs_rdwr_rankbank_num = bsm_chosen_rdwr[0+:RANKBANK_BITS];


   //--------------------------- end bank selection -----------------------------//

   assign choose_rdwr     = choose_rd | choose_wr;

   // assorted outputs
   assign gs_op_is_act    = choose_act;
   assign gs_op_is_pre    = choose_pre;
   assign gs_op_is_rd     = choose_rd;
   assign gs_op_is_wr     = choose_wr;
   assign gs_op_is_rd_hi  = choose_rd &   rd_is_hi;
   assign gs_op_is_rd_lo  = choose_rd & (~rd_is_hi);
   assign gs_pi_op_is_load_mr_norm = load_mr_norm;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(((3 + 1) * BANK_BITS) - 1)' found in module 'gs_next_xact'
//SJ: This coding style is acceptable and there is no plan to change it.

// Bank number to PI

   // mux between refpb_bank indications from rank_constraints
   assign gs_pi_refpb_bank =
                          // In normal operating mode, the bank address is selected based on REFpb indication  from gs_rank_constraints (it is always one-hot)
                          (gs_lpddr54_refpb[0] & ~init_refresh & gsnx_op_is_ref) ? gs_refpb_bank[(0+1)*BANK_BITS-1:0*BANK_BITS] :
                          // In initial operating mode, the bank addresses for each rank are same
                          gs_refpb_bank[BANK_BITS-1:0];
//spyglass enable_block SelfDeterminedExpr-ML



   // refeshes can occur to multiple ranks at once;
   // entering self-refresh should always be done to ALL ranks; and
   // other transactions always access a single rank
   // (note that enter_selfref, choose_ref_crit, and choose_ref_req
   //  will all assert only in normal_operating_mode)
   // CS signals are all active low
   /*  Alternate implementation:
    assign cs_n    = normal_operating_mode ? (choose_ref_crit ? ~critical_ref_possible  :
    choose_ref_req  ? ~speculative_ref_possible :
    nonref_cs_n               ):
    enter_selfref ?                            NUM_RANKS'b0              :
    {NUM_RANKS{1'b1}}          ;
    */

// For SRE, need to stagger even/odd cs_n here if stagger_cs_n is asserted



//------------------------------------
// CAS WCK Sync logic
//------------------------------------

   assign gs_cas_ws_req = ~wck_sync_st;

//------------------------------------
// CAS WCK Sync off logic
//------------------------------------

   logic [NUM_RANKS-1:0] cas_ws_off_vld;

   assign   cas_ws_off_vld = cas_ws_off_req
                             ;


    assign gs_op_is_cas_ws_off =
                                 cas_ws_off_vld
                                 & reg_ddrc_lpddr5
                                 & (~(|rank_nop_after_zqcs))
                                 & (~(|rank_nop_after_load_mr_norm))
                                 & ~gs_op_is_enter_powerdown
                                 & ~gs_op_is_enter_selfref
                                 & ~gs_op_is_enter_dsm
                                 & ((((normal_operating_mode
                                       & clock_stop_exited
                                       & no_critical_cmd
                                       & ~choose_ref_crit
                                       & ~choose_ref_req
                                       & ~choose_act
                                       & ~choose_rdwr
                                       & ~choose_pre
                                       & ~(|load_mr_norm_required)
                                      ) |
                                      (sr_mrrw_en
                                       & ~(|load_mr_norm_required)
                                      )
                                     )
                                     & (~pi_gs_noxact | pi_lp5_preref_ok)
                                    ) |
                                    (pi_gs_noxact & ~pi_lp5_noxact)
                                   );

//------------------------------------
// cs_n assignment logic
//------------------------------------

   wire   i_no_sr_mrrw_allowed;
   assign i_no_sr_mrrw_allowed = no_sr_mrrw_allowed;

   assign gs_pre_cs_n     = 1'b0;


//--------------------------------
// End cs_n assignment logic
//--------------------------------

   assign gsnx_op_is_ref = (choose_ref_crit | choose_ref_req) & (~init_operating_mode) &
                           (~no_ops_allowed) & ((~pi_gs_noxact)
                                                | (reg_ddrc_lpddr5 & pi_lp5_preref_ok)
                                               );


   assign load_mr_norm   = choose_load_mr_norm & (~(no_ops_allowed | pi_gs_noxact) | ~i_no_sr_mrrw_allowed) &
                           (~init_operating_mode | dh_gs_sw_init_int
                             );

   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     if (~core_ddrc_rstn) begin
  r_rd    <= 2'b0;
     end
     else begin
  r_rd    <= (choose_rd) ? 2'b01:
             (|r_rd)     ? (r_rd - 2'h1)  :
         2'h0            ;
     end // else: not in reset

//------------------------------------------------------------------------------
// Clock Stop logic
//------------------------------------------------------------------------------
// width is based on fact all inputs are 4 bits wide
reg [5:0] i_stop_clk_exit_cnt; 

wire [$bits(reg_ddrc_t_cksrx)-1:0] i_stop_clk_exit_cnt_val_sel;
assign i_stop_clk_exit_cnt_val_sel = (pi_gs_stop_clk_type==2'b01) ? {{($bits(i_stop_clk_exit_cnt_val_sel)-$bits(reg_ddrc_t_cksrx)){1'b0}},reg_ddrc_t_cksrx}  :
                                     (pi_gs_stop_clk_type==2'b11) ? {{($bits(i_stop_clk_exit_cnt_val_sel)-$bits(reg_ddrc_t_ckcsx)){1'b0}},reg_ddrc_t_ckcsx}  :
                                                                    {{($bits(i_stop_clk_exit_cnt_val_sel)-$bits(reg_ddrc_t_cksrx)){1'b0}},reg_ddrc_t_cksrx};

wire [$bits(i_stop_clk_exit_cnt_val_sel):0] i_stop_clk_exit_cnt_val_add;
wire [$bits(reg_ddrc_dfi_t_dram_clk_enable)-1:0] i_stop_clk_exit_cnt_val_min;
wire [$bits(reg_ddrc_dfi_t_dram_clk_enable):0] i_stop_clk_exit_cnt_val_aux1_wider;
wire [$bits(reg_ddrc_dfi_t_dram_clk_enable):0] i_stop_clk_exit_cnt_val_aux1;
wire [$bits(i_stop_clk_exit_cnt_val_add)-1:0] i_stop_clk_exit_cnt_val_aux2_wider;
wire [$bits(i_stop_clk_exit_cnt_val_add)-2:0] i_stop_clk_exit_cnt_val_aux2;
wire [$bits(i_stop_clk_exit_cnt_val_aux2)-1:0] i_stop_clk_exit_cnt_val;

assign i_stop_clk_exit_cnt_val_add = {{($bits(i_stop_clk_exit_cnt_val_add)-$bits(reg_ddrc_dfi_t_dram_clk_enable)){1'b0}},reg_ddrc_dfi_t_dram_clk_enable} + {{($bits(i_stop_clk_exit_cnt_val_add)-$bits(i_stop_clk_exit_cnt_val_sel)){1'b0}}, i_stop_clk_exit_cnt_val_sel};
// min of 1 to avoid not a NOP/DES when Clock Stop Exit occurs
assign i_stop_clk_exit_cnt_val_min = (pi_gs_stop_clk_type==2'b11) ? {{($bits(i_stop_clk_exit_cnt_val_min)-1){1'b0}},1'b1} : {$bits(i_stop_clk_exit_cnt_val_min){1'b0}};

assign i_stop_clk_exit_cnt_val_aux1_wider = reg_ddrc_dfi_t_ctrl_delay + i_stop_clk_exit_cnt_val_min;
assign i_stop_clk_exit_cnt_val_aux1 = i_stop_clk_exit_cnt_val_aux1_wider[$bits(i_stop_clk_exit_cnt_val_aux1)-1:0];
assign i_stop_clk_exit_cnt_val_aux2_wider = {{($bits(i_stop_clk_exit_cnt_val_aux2_wider)-$bits(i_stop_clk_exit_cnt_val_add)){1'b0}},i_stop_clk_exit_cnt_val_add} - {{($bits(i_stop_clk_exit_cnt_val_aux2_wider)-$bits(reg_ddrc_dfi_t_ctrl_delay)){1'b0}},reg_ddrc_dfi_t_ctrl_delay};
assign i_stop_clk_exit_cnt_val_aux2 = i_stop_clk_exit_cnt_val_aux2_wider[$bits(i_stop_clk_exit_cnt_val_aux2)-1:0];

assign i_stop_clk_exit_cnt_val = (i_stop_clk_exit_cnt_val_add > {1'b0,i_stop_clk_exit_cnt_val_aux1}) ? i_stop_clk_exit_cnt_val_aux2 :
                                                                                                       {{($bits(i_stop_clk_exit_cnt_val)-$bits(i_stop_clk_exit_cnt_val_min)){1'b0}},i_stop_clk_exit_cnt_val_min};

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_stop_clk_exit_cnt <= 6'h0;
  end else begin
    // don't overwrite to a lower value as type may have changed
    if ((pi_gs_stop_clk_early) && (i_stop_clk_exit_cnt_val>=i_stop_clk_exit_cnt)) begin
      i_stop_clk_exit_cnt <= i_stop_clk_exit_cnt_val;
    end else if (i_stop_clk_exit_cnt>0) begin
      i_stop_clk_exit_cnt <= i_stop_clk_exit_cnt - 1;
    end
  end
end

wire i_stop_clk_exit_cnt_zero = (i_stop_clk_exit_cnt==0) ? 1'b1 : 1'b0;


assign clock_stop_exited = !pi_gs_stop_clk_early & i_stop_clk_exit_cnt_zero
                        ;



   //------------------------------------------------------------------------------
   // Assertions
   //------------------------------------------------------------------------------
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
 wire ddr4_3DS;
    assign ddr4_3DS = 1'b0;

   onlyOneOpScheduled: //----------------------------------------------------------
    assert property ( @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
          ((gs_op_is_rd                                                +
                              gs_op_is_wr                                                +
                              gs_op_is_act                                               +
                              gs_op_is_pre                                               +
                              gs_pi_op_is_load_mr_norm      +
                              gsnx_op_is_ref                                                        ) <= MAX_CMD_NUM) )
    else $error("[%t][%m] ERROR: More than MAX_CMD_NUM transaction scheduled this cycle", $time);



//--------------------------------
// Only one operation -  bypass, or refresh or ZQ or precharge - scheduled in any cycle
//--------------------------------
onlyOneOpScheduled_non_rdwr_act:
    assert property ( @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
          ((gs_op_is_pre                                       +
            gs_pi_op_is_load_mr_norm                           +
            (
             //refresh is issued phase 2&3 in FR 1:4
             !(dh_gs_lpddr4 & dh_gs_frequency_ratio) &
             gsnx_op_is_ref)                                   ) <= 1) )
    else $error("[%t][%m] ERROR: Group 1 - More than one transaction scheduled this cycle.", $time);


//--------------------------------
// Only one operation -  refresh or precharge - scheduled in any cycle
//--------------------------------
onlyOneOpScheduled_rdwr_act:
    assert property ( @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
          ((gs_op_is_rd                                                    +
            gs_op_is_wr                                                    +
            (
             !reg_ddrc_lpddr5 &
            gs_op_is_act)                                                  ) <= 1) )
    else $error("[%t][%m] ERROR: Group 2 - More than one transaction scheduled this cycle.", $time);

     // Logic for generating a pulse one clock after reset de-asserts
     reg  reset_ff;
     wire  first_clk_after_reset;

     // flop the reset
     always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
    if (~core_ddrc_rstn)
    reset_ff  <= 1'b0;
    else
    reset_ff  <= core_ddrc_rstn;

   // pulse first clk after reset
   assign first_clk_after_reset = core_ddrc_rstn & !reset_ff;


   // rdwr_*_vld shouldn't come for banks belonging to rank 0 when rank 0 is closed
   property p_no_rdwr_vld_with_rank_closed;
     @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
    (os_gs_rdwr_lo_vld || os_gs_rdwr_hi_vld) |-> !os_gs_lrank_closed;
  endproperty





  // No speculative REF request when rdwr or act valids are present
  // Speculative REF command can be issued only when rank/bank status is IDLE.
  // Observe 1-cycle after because the IDLE status from the CAM are flopped.
  // When refresh_to_x1_x32 == 0, refresh request can be immediately asserted. So any valid can
  // be present with the refresh request.
  property p_no_spec_refresh_when_any_vld;
    integer act_lo_lrank, act_hi_lrank, rdwr_lo_lrank, rdwr_hi_lrank;
    integer act_lo_bank, act_hi_bank, rdwr_lo_bank, rdwr_hi_bank;
    @ (posedge co_yy_clk) disable iff (!core_ddrc_rstn || (dh_gs_refresh_to_x1_x32 == {$bits(dh_gs_refresh_to_x1_x32){1'b0}}))
    (
      (os_gs_act_lo_vld || os_gs_act_hi_vld || os_gs_rdwr_lo_vld || os_gs_rdwr_hi_vld),
        // sample rank/bank addresses for each valid
        act_lo_lrank  = 0,
        act_hi_lrank  = 0,
        rdwr_lo_lrank = 0,
        rdwr_hi_lrank = 0,
        act_lo_bank   = (dh_gs_lpddr4) ? act_lo_bsm_bank[BANK_BITS-1:0]  :  {act_lo_bsm_bank[0],act_lo_bsm_bank[3:2]},
        act_hi_bank   = (dh_gs_lpddr4) ? act_hi_bsm_bank[BANK_BITS-1:0]  :  {act_hi_bsm_bank[0],act_hi_bsm_bank[3:2]},
        rdwr_lo_bank  = (dh_gs_lpddr4) ? rdwr_lo_bsm_bank[BANK_BITS-1:0] :  {rdwr_lo_bsm_bank[0],rdwr_lo_bsm_bank[3:2]},
        rdwr_hi_bank  = (dh_gs_lpddr4) ? rdwr_hi_bsm_bank[BANK_BITS-1:0] :  {rdwr_hi_bsm_bank[0],rdwr_hi_bsm_bank[3:2]}
    ) |=>
      (dh_gs_per_bank_refresh  || $past(dh_gs_per_bank_refresh)) ?
      (
        !($past(os_gs_act_lo_vld) && bank_speculative_ref[act_lo_lrank*NUM_BANKS+act_lo_bank]) &&
        !($past(os_gs_act_hi_vld) && bank_speculative_ref[act_hi_lrank*NUM_BANKS+act_hi_bank]) &&
        !($past(os_gs_rdwr_lo_vld) && bank_speculative_ref[rdwr_lo_lrank*NUM_BANKS+rdwr_lo_bank]) &&
        !($past(os_gs_rdwr_hi_vld) && bank_speculative_ref[rdwr_hi_lrank*NUM_BANKS+rdwr_hi_bank])
      ) :
      (
        !($past(os_gs_act_lo_vld) && lrank_speculative_ref[act_lo_lrank]) &&
        !($past(os_gs_act_hi_vld) && lrank_speculative_ref[act_hi_lrank]) &&
        !($past(os_gs_rdwr_lo_vld) && lrank_speculative_ref[rdwr_lo_lrank]) &&
        !($past(os_gs_rdwr_hi_vld) && lrank_speculative_ref[rdwr_hi_lrank])
      );
  endproperty : p_no_spec_refresh_when_any_vld

   // r_act_bypass_dis_next gets the register value one clock after reset
   // so in effect bypass disable is not active until one clock after reset
   // this property prevents commands from coming in the first clk
   property p_no_vld_in_first_clk_after_reset;
     @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
    ((os_gs_rdwr_lo_vld || os_gs_rdwr_hi_vld ||
            os_gs_act_lo_vld  || os_gs_act_hi_vld  ||
        (rank_speculative_ref != 2'b00)        ||
        (rank_refresh_required != 2'b00)         ) |-> ~first_clk_after_reset);
      endproperty

      reg       core_ddrc_rstn_r;

      always @ (posedge co_yy_clk)
            core_ddrc_rstn_r <= core_ddrc_rstn;


      //bypass_match implies valid from IH





      // Assume statements for formal tool


      assert_no_rdwr_vld_with_rank_closed      : assert property (p_no_rdwr_vld_with_rank_closed)
      else $error("%m %t Rd/WR Valid came for a bank, when rank was NOT open", $time);






      assert_no_spec_refresh_when_any_vld : assert property (p_no_spec_refresh_when_any_vld)
      else $error("%m %t Speculative refresh request came when valid rank was present", $time);

      assert_no_vld_in_first_clk_after_reset    : assert property (p_no_vld_in_first_clk_after_reset)
      else $error("%m %t Valid came in first clk after reset", $time);









   localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

   // i_stop_clk_exit_cnt_val_aux1 overflow
   assert_never #(0, 0, "i_stop_clk_exit_cnt_val_aux1 overflow", CATEGORY) a_i_stop_clk_exit_cnt_val_aux1_overflow
     (co_yy_clk, core_ddrc_rstn, (i_stop_clk_exit_cnt_val_aux1_wider[5]==1'b1));

//   // i_stop_clk_exit_cnt_val_aux2 underflow
//    assert_never #(0, 0, "i_stop_clk_exit_cnt_val_aux2 underflow", CATEGORY) a_i_stop_clk_exit_cnt_val_aux2_underflow
//      (co_yy_clk, core_ddrc_rstn, (i_stop_clk_exit_cnt_val_aux2_wider[6]==1'b1));

   assign rank_next_ref_bank_closed_sva   = rank_next_ref_bank_closed;

   covergroup cg_lpddr4_sw14_cmd_schedule @(posedge co_yy_clk);
      cp_lp4_sw14_cmd_comb_ref_and_pre : coverpoint ({(dh_gs_lpddr4 & dh_gs_frequency_ratio), choose_ref_crit, choose_ref_req, choose_pre_crit, choose_pre_req })
      iff (core_ddrc_rstn) {
                 bins crit_ref_and_crit_pre = {5'b1_10_10};  
                 bins crit_ref_and_norm_pre = {5'b1_10_01};  
                 bins norm_ref_and_crit_pre = {5'b1_01_10};  
                 bins norm_ref_and_norm_pre = {5'b1_01_01};  
      }
   endgroup
 
   cg_lpddr4_sw14_cmd_schedule cg_lpddr4_sw14_cmd_schedule_inst = new;


`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
      //------------------------------------------------------------------------------

endmodule  // gs_next_xact (global scheduler next transaction selection)
