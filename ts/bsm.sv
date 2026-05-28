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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/bsm.sv#3 $
// -------------------------------------------------------------------------
// Description:
//
// BSM: Bank State Machine 
// This is the Bank State Machine module.  TS will instantiate one of these
// per bank in the design.
// Each of these track the state of one DRAM bank.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module bsm 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS -----------------------------------
     parameter    THIS_BANK_NUMBER    = 0 // number of this bank
    ,parameter    RANK_BITS           = `MEMC_RANK_BITS
    ,parameter    BANK_BITS           = `MEMC_BANK_BITS
    ,parameter    BG_BITS             = `MEMC_BG_BITS
    ,parameter    BG_BANK_BITS        = `MEMC_BG_BANK_BITS
    ,parameter    LRANK_BITS          = `DDRCTL_DDRC_LRANK_BITS
    ,parameter    RANKBANK_BITS       = LRANK_BITS + BG_BANK_BITS
    ,parameter    NUM_RANKS           = `MEMC_NUM_RANKS
    ,parameter    NUM_LRANKS          = `DDRCTL_DDRC_NUM_LRANKS_TOTAL
    ,parameter    NUM_BANKS           = (1 << BANK_BITS)
    ,parameter    NUM_BG_BANKS        = 1 << BG_BANK_BITS
    ,parameter    NUM_TOTAL_BANKS     = `DDRCTL_DDRC_NUM_TOTAL_BANKS
    ,parameter    NUM_TOTAL_BGS       = (1 << BG_BITS) * NUM_LRANKS
    ,parameter    CID_WIDTH           = `DDRCTL_DDRC_CID_WIDTH
    ,parameter    AUTOPRE_BITS        = 1 
    ,parameter    DYN_NUM_LRANKS      = 1
    ,parameter    DYN_NUM_RANKS       = 1
    ,parameter    DYN_NUM_TOTAL_BANKS = 1
    ,parameter    DYN_NUM_TOTAL_BGS   = 1
    ,parameter    DYN_BLK_ACT_TRFC    = 1
    ,parameter    DYN_BLK_ACT_TRFM    = 1
    ,parameter    DYN_BLK_ACT_RAAC    = 1

  )
  (
  //------------------------- INPUTS AND OUTPUTS ---------------------------------
     input                                              co_yy_clk                         // non-gated clock
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used only from assertion for now
    ,input                                              bsm_clk_en                        // BSM clock enabled
//spyglass enable_block W240
    ,input                                              bsm_clk                           // LPDDR: BSM clock which may be gated according to bsm_clk_en
                                                                                          // DDR:   BSM clock but equivalent to co_yy_clk
    ,input                                              core_ddrc_rstn                    // async falling-edge reset

    //// Register Configs ////
    ,input      [T_RAS_MIN_WIDTH-1:0]                   dh_bs_t_ras_min                   // tRAS(MIN):   ACT to PRE command min
    ,input      [T_RAS_MAX_WIDTH-1:0]                   dh_bs_t_ras_max                   // tRAS(MAX):   ACT to PRE command max x32
                                                                                          // (refresh_margin will be used to
                                                                                          //  account for max delay in issuing
                                                                                          //  the critical PRE command)
    ,input      [REFRESH_MARGIN_WIDTH-1:0]              gs_bs_refresh_margin              // # cycles (x32) early to start attempting refresh
    ,input      [T_RC_WIDTH-1:0]                        dh_bs_t_rc                        // tRC:         ACT to ACT min (bank)
    ,input      [T_RCD_WIDTH-1:0]                       dh_bs_t_rcd                       // tRCD:        ACT to read/write delay
    ,input      [T_RP_WIDTH-1:0]                        dh_bs_t_rp                        // tRP:         PRE command period
    ,input      [RD2PRE_WIDTH-1:0]                      dh_bs_rd2pre                      // read to PRE command min delay
    ,input      [WR2PRE_WIDTH-1:0]                      dh_bs_wr2pre                      // write to PRE command min delay
    ,input      [RDA2PRE_WIDTH-1:0]                     reg_ddrc_rda2pre                  // read AP to PRE command min delay
    ,input      [WRA2PRE_WIDTH-1:0]                     reg_ddrc_wra2pre                  // write AP to PRE command min delay
    ,input                                              dh_bs_pageclose                   // close pages as soon as possible
    ,input      [7:0]                                   dh_bs_pageclose_timer
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: currently LPDDR4 only supports 1:4 mode
    ,input                                              dh_bs_frequency_ratio             // 0 - 1:2 mode, 1 - 1:4 mode
//spyglass enable_block W240
    ,input                                              gsfsm_dis_dq                      // disable dequeue: no reads/writes/activates will be scheduled

    //// Next Transaction to this bank (rd + wr) ////
    ,input                                              te_rd_autopre                     // 1=read scheuduled this cycle will be
                                                                                          //   issued with auto-precharge (A10=1)
                                                                                          // 0=no auto-precharge this cycle
                                                                                          // (NOTE: used later in the cycle
                                                                                          //        than other te_bs_* signals)
    ,input                                              te_wr_autopre                     // 1=read scheuduled this cycle will be
                                                                                          //   issued with auto-precharge (A10=1)
                                                                                          // 0=no auto-precharge this cycle
                                                                                          // (NOTE: used later in the cycle
                                                                                          //        than other te_bs_* signals)
    ,input                                              te_bs_rd_hi                       // pending read is high priority
    ,input                                              te_bs_wrecc_btt                   // pending read is high priority
    ,input                                              te_bs_rd_page_hit                 // read pending to open page
    ,input                                              te_bs_rd_valid                    // read pending
    ,input                                              te_bs_wr_page_hit                 // write pending to open page
    ,input                                              te_bs_wr_valid                    // write pending
    ,input                                              te_bs_rd_bank_page_hit
    ,input                                              te_bs_wr_bank_page_hit

    //// Cycles scheduled by PI ////
    //// Inputs from GS: read/write mode, rank constraints, global constraints
    ,input                                              gs_bs_wr_mode_early               // 0=read, not write, can be performed
    ,input                                              gs_bs_wr_mode
    ,input                                              gs_bs_close_pages                 // global scheduler requesting all pages be closed
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_bs_rank_refresh_required       // tRFC(max): refresh required
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_bs_rank_refresh_required_early
    ,input      [DYN_NUM_TOTAL_BANKS-1:0]               gs_bs_bank_speculative_ref        // speculative refresh may be issued
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_rank_block_cas_b3_nxt
    ,input      [DYN_NUM_TOTAL_BGS-1:0]                 gs_bs_rank_act2_invalid_tmg_nxt
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_bs_rank_block_act_nxt          // prevent activate next cycle
    ,input      [DYN_BLK_ACT_TRFC-1:0]                  gs_bs_rank_block_act_trfc_bk_nxt  // prevent activate next cycle
    ,input      [DYN_NUM_TOTAL_BGS-1:0]                 gs_bs_rank_block_act_trrd_bg_nxt  // prevent activate next cycle
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_bs_rank_block_act_ref_req      // prevent activate next cycle
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_bs_rank_block_rd_nxt           // prevent read this cycle 
    ,input      [DYN_NUM_LRANKS-1:0]                    gs_bs_rank_block_wr_nxt           // prevent write this cycle 
    ,input      [DYN_NUM_TOTAL_BGS-1:0]                 gs_bs_blk_ccd_timer               // prevent read or write this cycle 
    ,input      [DYN_NUM_TOTAL_BGS-1:0]                 gs_bs_blk_wr2rd_timer             // prevent read this cycle
    ,input      [DYN_NUM_TOTAL_BGS-1:0]                 gs_bs_blk_rd2wr_timer             // prevent read this cycle
    ,input      [NUM_RANKS-1:0]                         gs_bs_zq_calib_short_required     // zq_calib_short required
    ,input      [NUM_RANKS-1:0]                         gs_bs_load_mr_norm_required       // load_mr_norm required
    ,input                                              gs_bs_phymstr_sre_req             // SRE request due to PHY Master request
    ,input                                              gs_bs_sre_stall                   // upon SRE we are expecting ih_busy=0 (CAMs and all FIFOs empty)
    ,input                                              gs_bs_sre_hw_sw                   // SRE caused by SW or HW entry trigger
    ,input                                              gs_bs_dis_cam_drain_selfref       // PWRCTL.dis_cam_drain_selfref


    //// More from GS: Secheduled operations ////
    ,input                                              gs_op_is_act                      // activate command selected by GS
    ,input                                              gs_op_is_rd                       // read command selected by GS
    ,input                                              gs_op_is_wr                       // write command selected by GS
    ,input                                              gs_op_is_pre                      // precharge command selected by GS
    ,input      [RANKBANK_BITS-1:0]                     gs_pre_rankbank_num                // bank number performing operation
    ,input      [RANKBANK_BITS-1:0]                     gs_act_rankbank_num                // bank number performing operation
    ,input      [RANKBANK_BITS-1:0]                     gs_rdwr_rankbank_num               // bank number performing operation

    //// Bypass ////

    //// Which valid requests this BSM is making ////
    ,output                                             bs_os_act_hi_vlds                 // high priority activate requested
    ,output                                             bs_os_rdwr_hi_vlds                // high priority read requested
    ,output                                             bs_os_act_lo_vlds                 // low priority activate requested
    ,output                                             bs_os_rdwr_lo_vlds                // low priority read or write requested
                                                                                          // (read when wr_mode=0
                                                                                          //  write when wr_mode=1)
    ,output reg                                         bs_os_pre_crit_vlds               // critical precharge requested
    ,output                                             bs_os_pre_req_vlds                // precharge for read/write requested
    ,output                                             bs_os_act_wr_vlds                 // activate for wr requested
    ,output                                             bs_os_pre_req_wr_vlds             // precharge for write requested
    //// No open page - used by refresh logic ////
    ,output                                             bs_os_bank_closed                 // OK to perform a refresh to this rank

    ,output                                             bs_gs_stop_clk_ok                 // OK to stop the clock

    ,input      [DYN_NUM_LRANKS*BANK_BITS-1:0]          gs_bs_refpb_bank                  //refresh to this bank
    ,input                                              dh_gs_per_bank_refresh            //per bank refresh selected
    ,input                                              dh_gs_lpddr4                      // LPDDR4 mode
    ,input                                              reg_ddrc_lpddr5                   // LPDDR5 mode
    ,input      [BANK_ORG_WIDTH-1:0]                    reg_ddrc_bank_org                 // bank organization (00:BG, 01:8B, 10:16B)
    ,input      [T_CCD_MW_WIDTH-1:0]                    dh_bs_t_ccd_mw                    // tCCDMW: CAS-to-CAS min delay masked write
    ,input                                              te_bs_mwr                         // banks with masked writes pending
    ,input                                              lpddr4_blk_act_nxt                // Extra block for ACT, related to lpddr4_opt_act_timing 
    ,input                                              pi_lp5_act2_cmd
    ,input                                              te_b3_bit                         // burst bit(column bit)[3]
    ,input      [AUTOPRE_BITS-1:0]                      te_os_rd_cmd_autopre_table
    ,input                                              te_os_rd_pageclose_autopre
    ,output reg [DYN_NUM_RANKS-1:0]                     bs_os_no_2ck_cmds_after_pre       // blocks 2-cycles commands after PRE or commands w/AP
    ,output reg                                         act2_invalid_tmg
    ,input [7:0]                                        reg_ddrc_wr_page_exp_cycles
    ,input [7:0]                                        reg_ddrc_rd_page_exp_cycles
    ,input [7:0]                                        reg_ddrc_wr_act_idle_gap
    ,input [7:0]                                        reg_ddrc_rd_act_idle_gap

    ,output                                             bank_activated_early
    ,output                                             sel_act_wr
    ,input                                              rd_more_crit 
    ,input                                              wr_more_crit
    ,input                                              te_rws_wr_col_bank               // entry of colliding bank (1bit for 1bank)
    ,input                                              te_rws_rd_col_bank               // entry of colliding bank (1bit for 1bank)
//    ,input  [5:0]        dh_gs_rd2wr
//    ,input                                              wr_cam_up_highth 
//    ,input                                              wr_cam_up_lowth
    ,input                                              delay_switch_write_state
    ,input                                              gs_act_pre_rd_priority
    ,input                                              reg_ddrc_dis_speculative_act
    ,input [NUM_RANKS-1:0]                              dqsosc_block_other_cmd                
  );

//---------------------------- LOCAL PARAMETERS --------------------------------
// BSM states
localparam  BSM_STATE_IDLE              = 2'b00;
localparam  BSM_STATE_ROW_ACTIVATING    = 2'b01;
localparam  BSM_STATE_ROW_ACTIVE        = 2'b10;
localparam  BSM_STATE_PRECHARGING       = 2'b11;


localparam  RANK_BITS_L       = (RANK_BITS>0) ? RANK_BITS : 1;
localparam  BG_BITS_L         = (BG_BITS  >0) ? BG_BITS   : 1;

//--------------------------------- WIRES --------------------------------------

wire                                        lrank_enable;               // This logical rank enable

wire    [$bits(dh_bs_t_ras_min)-1:0]        dh_bs_t_ras_min_i;          // tRAS(MIN):   ACT to PRE command min
wire    [$bits(dh_bs_t_rp)-1:0]             dh_bs_t_rp_i;               // tRP:         PRE command period
wire    [$bits(dh_bs_t_rc)-1:0]             dh_bs_t_rc_i;               // tRC:         ACT to ACT min (bank)
wire    [$bits(dh_bs_t_rcd)-1:0]            dh_bs_t_rcd_i;              // tRCD:        ACT to read/write delay

wire    [1:0]                               next_state;                 // BSM next state

wire                                        precharge_ok_next;          // OK to issue precharge next cycle
wire                                        wr_ok_next;                 // OK to issue write next cycle

wire                                        bg_b16_addr_mode;
wire     [BANK_BITS-1:0]                    this_bank_wo_bg;
wire     [BANK_BITS-1:0]                    this_bank_w_bg_ref;
wire     [BANK_BITS-1:0]                    this_ref_bank;

localparam                                  this_physical_rank = 0; // For one rank configuration.

wire                                        this_bank_gs_rdwr;          // this bank is being addressed
wire                                        this_bank_gs_act;           // this bank is being addressed
wire                                        this_bank_gs_pre;           // this bank is being addressed




wire                                        this_bank_rd;               // read to this bank
wire                                        this_bank_wr;               // write to this bank
wire                                        this_bank_act;              // activate to this bank
wire                                        this_bank_rd_autopre;       // read with auto-precharge to this bank
wire                                        this_bank_wr_autopre;       // read with auto-precharge to this bank
reg                                         this_bank_rd_autopre_reg;   // read with auto-precharge to this bank registered
reg                                         this_bank_wr_autopre_reg;   // write with auto-precharge to this bank registered

wire                                        this_bank_pre;              // precharge to this bank

wire                                        block_rdwr_cmds;
wire                                        block_rd_cmds;
wire                                        block_wr_cmds;

wire                                        sel_zq_calib_short_required;
wire                                        sel_load_mr_norm_required;
wire                                        sel_dqsosc_block_other_cmd;


wire                                        sel_lrank_enable;               // This logical rank enable
wire                                        sel_rank_refresh_required;      // tRFC(max): refresh required
wire                                        sel_rank_refresh_required_early;
wire                                        sel_speculative_ref;            // speculative refresh may be issued
wire                                        sel_rank_block_act_nxt;         // prevent activate next cycle
wire                                        sel_rank_block_act_trfc_bk_nxt; // prevent activate next cycle
wire                                        sel_rank_block_act_trrd_bg_nxt; // prevent activate next cycle
wire                                        sel_rank_block_act_ref_req;     // prevent activate next cycle
wire                                        sel_rank_block_rd_nxt;          // prevent read this cycle 
wire                                        sel_rank_block_wr_nxt;          // prevent write this cycle 
wire                                        sel_blk_ccd_timer;              // prevent read or write this cycle 
wire                                        sel_blk_wr2rd_timer;            // prevent read this cycle
wire                                        sel_blk_rd2wr_timer;            // prevent read this cycle
wire                                        sel_rank_block_cas_b3_nxt;
wire                                        sel_rank_act2_invalid_tmg_nxt;
wire        [BANK_BITS-1:0]                 sel_refpb_bank;                 //refresh to this bank
wire                                        bsm_alloc;
wire                                        cs_eq_idle;


wire                                        mask_wr_en;
assign  mask_wr_en = dh_gs_lpddr4 | reg_ddrc_lpddr5;

// ccx_cond:;;10; Redundant for now. 8B mode is not supported.
assign bg_b16_addr_mode = reg_ddrc_lpddr5 && (reg_ddrc_bank_org != {{($bits(reg_ddrc_bank_org)-1){1'b0}},1'b1});


//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep the current implementation.
    assign  bsm_alloc = 1'b1;
//spyglass enable_block W528

// request a PRE command and block other commands when we have a dfi_phymstr_req, but only if
// gs_global_fsm_sr_hw_lp is not in SR_ST_SRE_HW_SW_STALL state; in this case we need to allow
// rd/wr transactions to empty CAMs
// send critical PRE after SR_ST_SRE_HW_SW_STALL state exited
wire pre_required_due_to_phymstr = gs_bs_phymstr_sre_req & ~gs_bs_sre_stall;
wire pre_required_due_to_ppt2    = 1'b0;

// close the bank if SR is requested to enter without draining the CAMs and the bank is opened
wire pre_req_dis_cam_drain = gs_bs_sre_hw_sw & gs_bs_dis_cam_drain_selfref & ~cs_eq_idle;

wire rdwr_pol_sel;
assign rdwr_pol_sel = 1'b1; 

//------------------------------- REGISTERS ------------------------------------
reg     [1:0]                               current_state;              // current state of bank state machine
reg     [$bits(dh_bs_rd2pre)-1:0]           no_pre_after_rd_timer;      // down-counting timer
reg     [$bits(dh_bs_t_ras_max):0]          no_pre_after_act_timer_wider;//signal used to check that overflow does not occur
wire    [$bits(dh_bs_t_ras_max)-1:0]        no_pre_after_act_timer;     // down-counting timer
reg     [$bits(dh_bs_t_rc)-1:0]             no_act_after_act_timer;     // down-counting timer
reg     [$bits(dh_bs_t_rcd)-1:0]            activating_timer;           // down-counting timer
reg     [$bits(dh_bs_wr2pre)-1:0]           no_pre_after_wr_timer;      // down-counting timer
reg     [$bits(dh_bs_wr2pre):0]             precharging_timer;          // down-counting timer
//   NOTE: The following timer was intended to be x32 or x1024, but has been
//         implemented as a more-accurate single-cycle timer.  Not changing  it
//         now simply to avoid unnecessary changes to the RTL late in the
//         project. 
reg     [($bits(dh_bs_t_ras_max)+10):0]     pre_critical_timer_wider;   // signal used to check that overflow does not occur
wire    [($bits(dh_bs_t_ras_max)+10)-1:0]   pre_critical_timer;         // down-counting timer
reg     [$bits(dh_bs_t_ccd_mw)-1:0]         t_ccd_mw_timer;             // timer for CAS to CAS delay masked write
wire                                        no_2ck_cmds_after_pre;      // blocks 2-cycles commands after PRE or commands w/AP
reg                                         precharge_ok;               // OK to precharge 
reg                                         activate_ok;                // OK to activate
wire                                        sel_act_rd;
wire                                        bs_os_pre_req_vlds_enh;
reg                                         rd_activate_ok;             // OK to activage for a read
reg                                         wr_activate_ok;             // OK to activage for a write
reg                                         rd_ok;                      // OK to do a read 
reg                                         wr_ok;                      // OK to do a write
reg                                         mwr_ok;                     // OK to do a masked write
reg                                         lp5_issue_act1_r;
wire                                        lp5_wait_act2;
reg      [$bits(dh_bs_wr2pre)-1:0]          wr2rda_timer;
wire                                        rd_autopre;
wire                                        rda_ok;
reg                                         r_close_pages;              // attempt to close all pages next cycle
                                                                        // (lower priority than read or write)

//================================ main code ===============================================================



//======================== Just assign to "_i" signal =======================
assign  dh_bs_t_ras_min_i   = {{($bits(dh_bs_t_ras_min_i)-$bits(dh_bs_t_ras_min)){1'b0}},dh_bs_t_ras_min};
assign  dh_bs_t_rc_i        = {{($bits(dh_bs_t_rc_i)-$bits(dh_bs_t_rc)){1'b0}},dh_bs_t_rc};
assign  dh_bs_t_rcd_i       = {{($bits(dh_bs_t_rcd_i)-$bits(dh_bs_t_rcd)){1'b0}},dh_bs_t_rcd};
assign  dh_bs_t_rp_i        = {{($bits(dh_bs_t_rp_i)-$bits(dh_bs_t_rp)){1'b0}},dh_bs_t_rp};


//======================== Stop Clock logic ======================================================


// After a pre-charge or a read/write with auto-precharge, the bank has to be closed before stopping the clock
// This stop clock Ok from all the BSM's are AND'ed together and fed to the gs_global_fsm clk_stop_ok logic
// Clk stop ok has to go low when critical precharge happens too.
// When dh_bs_pageclose register is high, precharge is be detected early for clock stop

wire    precharge_possible;
wire    early_pre_critical;
reg     r_early_pre_critical;

// simplified version of precharge_ok_next
// (precharge_ok_next is bad for timing)
// this one is easier on timing - no feedback from GS
// but this one may also assert right after a read or write, when a
//  precharge is actually impossible
assign precharge_possible = (current_state == BSM_STATE_ROW_ACTIVE) &
                          (~(|no_pre_after_rd_timer[5:1] ))         &
                          (~(|no_pre_after_wr_timer[6:1] ))         &
                          (~(|no_pre_after_act_timer[$bits(no_pre_after_act_timer)-1:1]))         ;

assign          bs_gs_stop_clk_ok       = ((current_state == BSM_STATE_IDLE) || (current_state == BSM_STATE_ROW_ACTIVE)) &&
                                          (~r_early_pre_critical) &&
                                          (~no_2ck_cmds_after_pre) &&
                                          (no_pre_after_wr_timer == 7'h0) && (no_pre_after_rd_timer == 6'h0) &&
                                          (~(dh_bs_pageclose && (precharge_possible || bs_os_pre_req_vlds)));

assign          early_pre_critical      = (pre_critical_timer[16:2] == 15'h0) && (current_state == BSM_STATE_ROW_ACTIVE);
                                                // [14:2] puposefully used instead of [14:1]

always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
     r_early_pre_critical       <= 1'b0;
  end
  else begin
     r_early_pre_critical       <= early_pre_critical;
  end
end

// Set the rank & bank number 
// WARNING: Static assumption on the number of banks here!


//------------------------
// Rank assignment
//------------------------

//------------------------
// rank_constraints assignment
//------------------------

//------------------------
// Bank and Bank Group assignment
//------------------------
    // when there is no BG, bank number is always 3-bits, hence the logic below
    assign this_bank_wo_bg =      {{($bits(this_bank_wo_bg)-3){1'b0}},THIS_BANK_NUMBER[2:0]};


    assign this_bank_w_bg_ref =   {THIS_BANK_NUMBER[0],THIS_BANK_NUMBER[3:2]};
    assign this_ref_bank = bg_b16_addr_mode ? this_bank_w_bg_ref : this_bank_wo_bg;


//------------------------------------------------------------------------------
//--------------------- select applicable signal ------------------------
//------------------------------------------------------------------------------
    assign  lrank_enable = 1'b1;

assign  sel_zq_calib_short_required = gs_bs_zq_calib_short_required[this_physical_rank];
assign  sel_load_mr_norm_required   = gs_bs_load_mr_norm_required  [this_physical_rank];

assign  sel_dqsosc_block_other_cmd  = dqsosc_block_other_cmd[this_physical_rank];


//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block/ RTL assertions and under different `ifdefs
    assign  sel_lrank_enable                = lrank_enable;
//spyglass enable_block W528
    assign  sel_rank_refresh_required       = gs_bs_rank_refresh_required;
    assign  sel_rank_refresh_required_early = gs_bs_rank_refresh_required_early & ~sel_rank_refresh_required;
    assign  sel_speculative_ref             = gs_bs_bank_speculative_ref;
    assign  sel_rank_block_cas_b3_nxt       = gs_rank_block_cas_b3_nxt;
    assign  sel_rank_act2_invalid_tmg_nxt   = gs_bs_rank_act2_invalid_tmg_nxt;
    assign  sel_rank_block_act_nxt          = gs_bs_rank_block_act_nxt;
    assign  sel_rank_block_act_trfc_bk_nxt  = gs_bs_rank_block_act_trfc_bk_nxt;
    assign  sel_rank_block_act_trrd_bg_nxt  = gs_bs_rank_block_act_trrd_bg_nxt;
    assign  sel_rank_block_act_ref_req      = gs_bs_rank_block_act_ref_req;
    assign  sel_rank_block_rd_nxt           = gs_bs_rank_block_rd_nxt;
    assign  sel_rank_block_wr_nxt           = gs_bs_rank_block_wr_nxt;
    assign  sel_blk_ccd_timer               = gs_bs_blk_ccd_timer;
    assign  sel_blk_wr2rd_timer             = gs_bs_blk_wr2rd_timer;
    assign  sel_blk_rd2wr_timer             = gs_bs_blk_rd2wr_timer;
    assign  sel_refpb_bank                  = gs_bs_refpb_bank;

//------------------------------------------------------------------------------
//--------------------- Operations Issued to This Banks ------------------------
//------------------------------------------------------------------------------

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((2 * RANKBANK_BITS) - 1)' found in module 'bsm'
//SJ: This coding style is acceptable and there is no plan to change it.

//---------------
// Extracting from gs_bs_bank signal - which contains rank, bg and bank info
//---------------
    assign this_bank_gs_pre  = (gs_pre_rankbank_num  == $unsigned(THIS_BANK_NUMBER));
    assign this_bank_gs_act  = (gs_act_rankbank_num  == $unsigned(THIS_BANK_NUMBER));
    assign this_bank_gs_rdwr = (gs_rdwr_rankbank_num == $unsigned(THIS_BANK_NUMBER));
//spyglass enable_block SelfDeterminedExpr-ML

//----------------------------
// Extracting info from ih_bs_rank_num and ih_bs_bg_bank_num signals
//----------------------------

// same bank_bypass indicator for any type of bypass path



//------------------------------
// Generating the this rank,bg,bank rd/wr/act/pre signals based on the above signals
//------------------------------


//------------
// Read Case
//------------
assign this_bank_rd          = (this_bank_gs_rdwr & gs_op_is_rd);



//------------
// Write Case
//------------
assign this_bank_wr          = (this_bank_gs_rdwr & gs_op_is_wr);

//------------
// Read AutoPre Case
//------------
// TBD: auto-precharge for read bypass
// NOTE: when a read requires multiple commands to DRAM, the auto-precharge will be seen
//       by this logic on both the first read/write and the last read/write
assign this_bank_rd_autopre  = (this_bank_gs_rdwr & gs_op_is_rd      & te_rd_autopre);

//------------
// Write AutoPre Case
//------------
assign this_bank_wr_autopre     = (this_bank_gs_rdwr & gs_op_is_wr      & te_wr_autopre);

always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    this_bank_wr_autopre_reg <= 1'b0;
    this_bank_rd_autopre_reg <= 1'b0;
  end else begin
    this_bank_wr_autopre_reg <= this_bank_wr_autopre;
    this_bank_rd_autopre_reg <= this_bank_rd_autopre;
  end
end

//------------
// Activate case
//------------
assign this_bank_act    = this_bank_gs_act & gs_op_is_act;


always_ff @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      lp5_issue_act1_r <= 1'b0;
   end
   // ccx_cond:"bsm_gen\[8\].bsm,bsm_gen\[9\].bsm,bsm_gen\[10\].bsm,bsm_gen\[11\].bsm,bsm_gen\[12\].bsm,bsm_gen\[13\].bsm,bsm_gen\[14\].bsm,bsm_gen\[15\].bsm";   ;01;Not use this BSM in LPDDR4 mode
   // ccx_cond:"bsm_gen\[24\].bsm,bsm_gen\[25\].bsm,bsm_gen\[26\].bsm,bsm_gen\[27\].bsm,bsm_gen\[28\].bsm,bsm_gen\[29\].bsm,bsm_gen\[30\].bsm,bsm_gen\[31\].bsm"; ;01;Not use this BSM in LPDDR4 mode
   else if (reg_ddrc_lpddr5 && this_bank_act) begin
      lp5_issue_act1_r <= 1'b1;
   end
   else if (pi_lp5_act2_cmd) begin
      lp5_issue_act1_r <= 1'b0;
   end
end

assign lp5_wait_act2 = (lp5_issue_act1_r && !pi_lp5_act2_cmd);


//------------
// Precharge case
//------------
assign this_bank_pre    = this_bank_gs_pre & gs_op_is_pre;

//---------------------
//---------------------



//---------------------- Bypass Allowed to This Bank ---------------------------
// precharging timer is less or equal to 1
wire precharging_timer_le_one = ~(|precharging_timer[$bits(precharging_timer)-1:1]);
// intialization of precharging_timer is delayed by one cyle, moving to state BSM_STATE_PRECHARGING one cycle before precharging_timer is loaded.  
wire precharging_done = precharging_timer_le_one&~this_bank_rd_autopre_reg&~this_bank_wr_autopre_reg;

//-------------------------- Bank State Machine --------------------------------
assign next_state =
        (current_state==BSM_STATE_IDLE) ?
                ((this_bank_act)                 ? BSM_STATE_ROW_ACTIVATING :BSM_STATE_IDLE)          :
        (current_state==BSM_STATE_ROW_ACTIVATING) ?
                ((~(|activating_timer[$bits(activating_timer)-1:1])
                   & (!lp5_wait_act2)
                                                ) ? BSM_STATE_ROW_ACTIVE     :BSM_STATE_ROW_ACTIVATING):
        (current_state==BSM_STATE_ROW_ACTIVE) ?
                ((this_bank_pre        |
                  this_bank_rd_autopre |
                  this_bank_wr_autopre  )        ? BSM_STATE_PRECHARGING    :BSM_STATE_ROW_ACTIVE)    :
        // (current_state==BSM_STATE_PRECHARGING) ?
        // precharging_timer checks for t_rp and t_ras(min)
        // no_act_after_act_timer checks for t_rc (newly added check) - fix for bug 3250
                ((precharging_done && (~(|no_act_after_act_timer[$bits(no_act_after_act_timer)-1:1]))) ? BSM_STATE_IDLE : BSM_STATE_PRECHARGING) ;

always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn)
    current_state <= BSM_STATE_IDLE;
  else
    current_state <= next_state;
end // always: synchronous process for FSM

//--------------------------- Constraint Timers --------------------------------
wire [$bits(dh_bs_t_ccd_mw)-1:0] dh_bs_t_ccd_mw_int;
assign dh_bs_t_ccd_mw_int = (dh_bs_t_ccd_mw > {{($bits(dh_bs_t_ccd_mw)-1){1'b0}},1'b1}) ? dh_bs_t_ccd_mw : {{($bits(dh_bs_t_ccd_mw)-2){1'b0}},2'b10};

reg  [$bits(dh_bs_rd2pre)-1:0] dh_bs_rd2pre_m1;    // read to PRE command min delay minus 1 
reg  [$bits(dh_bs_wr2pre)-1:0] dh_bs_wr2pre_m1;    // write to PRE command min delay minus 1
reg  [$bits(dh_bs_t_rp_i)-1:0]  dh_bs_t_rp_m1;      // tRP minus 1 
reg  [$bits(reg_ddrc_rda2pre)-1:0] reg_ddrc_rda2pre_m1;   // read AP to PRE command min delay minus 1 
reg  [$bits(reg_ddrc_wra2pre)-1:0] reg_ddrc_wra2pre_m1;   // write AP to PRE command min delay minus 1

always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    dh_bs_rd2pre_m1             <= {$bits(dh_bs_rd2pre_m1){1'b0}};
    dh_bs_wr2pre_m1             <= {$bits(dh_bs_wr2pre_m1){1'b0}};
    dh_bs_t_rp_m1               <= {$bits(dh_bs_t_rp_m1){1'b0}};
    reg_ddrc_rda2pre_m1         <= {$bits(reg_ddrc_rda2pre_m1){1'b0}};
    reg_ddrc_wra2pre_m1         <= {$bits(reg_ddrc_wra2pre_m1){1'b0}};
  end // if: in reset
  else begin
    if (dh_bs_rd2pre>{$bits(dh_bs_rd2pre_m1){1'b0}})
      dh_bs_rd2pre_m1         <= dh_bs_rd2pre-{{($bits(dh_bs_rd2pre_m1)-1){1'b0}},1'b1};
    if (dh_bs_wr2pre>{$bits(dh_bs_wr2pre_m1){1'b0}})     
      dh_bs_wr2pre_m1         <= dh_bs_wr2pre-{{($bits(dh_bs_wr2pre_m1)-1){1'b0}},1'b1};
    if (dh_bs_t_rp_i>{$bits(dh_bs_t_rp_i){1'b0}})     
      dh_bs_t_rp_m1           <= dh_bs_t_rp_i-{{($bits(dh_bs_t_rp_i)-1){1'b0}},1'b1};
    if (|reg_ddrc_rda2pre)
      reg_ddrc_rda2pre_m1     <= reg_ddrc_rda2pre-{{($bits(reg_ddrc_rda2pre)-1){1'b0}},1'b1};
    if (|reg_ddrc_wra2pre)     
      reg_ddrc_wra2pre_m1     <= reg_ddrc_wra2pre-{{($bits(reg_ddrc_wra2pre)-1){1'b0}},1'b1};
                                           // <---------- 1 ---------->
  end
end

wire  [$bits(reg_ddrc_rda2pre)-1:0] reg_ddrc_rda2pre_fr;
assign reg_ddrc_rda2pre_fr = reg_ddrc_lpddr5     ? reg_ddrc_rda2pre_m1 :
                                                   reg_ddrc_rda2pre_m1;

wire  [$bits(reg_ddrc_wra2pre)-1:0] reg_ddrc_wra2pre_fr;
assign reg_ddrc_wra2pre_fr = reg_ddrc_lpddr5     ? reg_ddrc_wra2pre_m1 :
                                                   reg_ddrc_wra2pre_m1;

//spyglass disable_block STARC05-2.11.3.1
//SMD: Combinational and sequential parts of an FSM described in same always block
//SJ: Reported for pre_critical_timer_wider, precharging_timer, no_pre_after_rd_timer and no_pre_after_wr_timer. Coding style used to prevent underflow. No re-coding required.
always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    activating_timer            <= {$bits(activating_timer){1'b0}};
    precharging_timer           <= {$bits(precharging_timer){1'b0}};
    no_pre_after_rd_timer       <= {$bits(no_pre_after_rd_timer){1'b0}};
    no_pre_after_wr_timer       <= {$bits(no_pre_after_wr_timer){1'b0}};
    no_pre_after_act_timer_wider <= {$bits(no_pre_after_act_timer_wider){1'b0}};
    no_act_after_act_timer      <= {$bits(no_act_after_act_timer){1'b0}};
    t_ccd_mw_timer              <= {$bits(t_ccd_mw_timer){1'b0}};

    // it's ok to not reset this; it will be initialized with the first activate;
    //  it is only used (and is only meaningful) when a page is open (ie, after an activate)
    pre_critical_timer_wider    <= {$bits(pre_critical_timer_wider){1'b0}};
  end // if: in reset
  else begin

    // ACT command to this bank
    if (this_bank_act) begin
      activating_timer          <= (dh_bs_t_rcd_i - (reg_ddrc_lpddr5 ? {{($bits(dh_bs_t_rcd_i)-2){1'b0}},2'b10} : {{($bits(dh_bs_t_rcd_i)-1){1'b0}},1'b1})); // dh_bs_t_rcd_i - 1

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(dh_bs_t_ras_min_i - {{($bits(dh_bs_t_ras_min_i)-1){1'b0}},1'b1})' found in module 'bsm'
//SJ: No suitable (better) re-coding found
                                                                       // <----------- 1 ---------->
      // In case of LPDDR4, PRE is 2-cycles wide, and ACT is 4-cycles wide on the DRAM bus.
      // This is equvalent to 1-cycle of PRE and 2-cycles of ACT (ACT1 & ACT2) inside the Controller
      // tRAS(min) is measured from ACT2 to PRE
      // In LP4 1:2 mode : ACT1 & ACT2 are scehduled next to each other. But the timer measures from ACT1, and hence timer
      //                   needs to be loaded with tRAS(min) value - which is actually 1 more than required value in the load cycle.
      // In LP4 1:4 mode : Both ACT1 & ACT2 are issued in same cycle, and hence the timer needs to be loaded with tRAS(min)-1
      // In LP5 mode     : ACT1 & ACT2 can have gap in between, and the timer doesn't downcount until ACT2 is issued, and hence
      //                   the timer needs to be loaded with tRAS(min)-1 
      // Summary: Use dh_bs_t_ras_min_i in LPDDR4 1:2 mode and (dh_bs_t_ras_min_i-1) in LPDDR4 1:4 mode & LPDDR5 mode
      no_pre_after_act_timer_wider    <= (dh_gs_lpddr4 & ~dh_bs_frequency_ratio) ? dh_bs_t_ras_min_i : 
                                           {{($bits(no_pre_after_act_timer_wider)-$bits(dh_bs_t_ras_min_i)){1'b0}},(dh_bs_t_ras_min_i - {{($bits(dh_bs_t_ras_min_i)-1){1'b0}},1'b1})};
//spyglass enable_block SelfDeterminedExpr-ML

      pre_critical_timer_wider  <= ({{($bits(pre_critical_timer_wider)-$bits(dh_bs_t_ras_max)-1){1'b0}}, dh_bs_t_ras_max} << 10) - ({{($bits(pre_critical_timer_wider)-$bits(gs_bs_refresh_margin)-1){1'b0}},gs_bs_refresh_margin} << 5);
      no_act_after_act_timer    <= dh_bs_t_rc_i - {{($bits(dh_bs_t_rc_i)-1){1'b0}},1'b1};
                                               // <---------- 1 ---------->
    end // if this bank is being precharged
    else begin
      if (|activating_timer)
        activating_timer          <= 
                                     (lp5_wait_act2)                                       ? activating_timer :
                                                                                             (activating_timer - {{($bits(activating_timer)-1){1'b0}},1'b1}); // -1
                                                                                                                 // <----------------- 1 ---------------->
      if (|no_pre_after_act_timer_wider)
        no_pre_after_act_timer_wider <= 
                                        (lp5_wait_act2)                                    ? no_pre_after_act_timer_wider :
                                                                                             (no_pre_after_act_timer_wider - {{($bits(no_pre_after_act_timer_wider)-1){1'b0}},1'b1});

      if (|pre_critical_timer_wider)
        pre_critical_timer_wider  <= 
                                     (lp5_wait_act2)                                       ? pre_critical_timer_wider :
                                                                                             (pre_critical_timer_wider - {{($bits(pre_critical_timer_wider)-1){1'b0}},1'b1});

      if (|no_act_after_act_timer)
        no_act_after_act_timer    <= 
                                     (lp5_wait_act2)                                       ? no_act_after_act_timer:
                                                                                             (no_act_after_act_timer - {{($bits(no_act_after_act_timer)-1){1'b0}},1'b1});
                                                                                                                       // <-------------------- 1 -------------------->
    end // else: not activate command


    // PRE command to this bank
    if (this_bank_pre) begin
      // tRP, minus 1 for the cycle lost when assigning it in the first place
      precharging_timer[$bits(precharging_timer)-1:$bits(dh_bs_t_rp_m1)]    <= {($bits(precharging_timer)-$bits(dh_bs_t_rp_m1)){1'b0}};
      // In case of LPDDR4, PRE is 2-cycles wide, and also REF is 2-cycles wide, but ACT is 4-cycles wide. Because of the difference
      // of command lengths, -1 adjustment is needed in 1:2 mode (it is 0 in 1:4 mode), so that ACT can be sent after RU(tRP/tCK).
      // LPDDR5 mode: will be same as LPDDR4 1:2 mode  i ie. -1 adjustment needed. ACT1 & ACT2 are issued in separate cycles and PRE to ACT2 is the tRP value
//spyglass disable_block W484
//SMD: Possible assignment overflow: lhs width 5 (Expr: 'precharging_timer[(RP_WDT - 1):0] ') should be greater than rhs width 5 (Expr: '(dh_bs_t_rp_m1 - {{ (RP_WDT - 1){ 1'b0} }  ,(~dh_bs_frequency_ratio)})') to accommodate carry/borrow bit
//SJ: Overflow not possible (dh_bs_t_rp_m1 is always smaller than precharging_timer)
      // ccx_cond_begin:"bsm_gen\[8\].bsm,bsm_gen\[9\].bsm,bsm_gen\[10\].bsm,bsm_gen\[11\].bsm,bsm_gen\[12\].bsm,bsm_gen\[13\].bsm,bsm_gen\[14\].bsm,bsm_gen\[15\].bsm";   ; ;Not use this BSM in LPDDR4 mode
      // ccx_cond_begin:"bsm_gen\[24\].bsm,bsm_gen\[25\].bsm,bsm_gen\[26\].bsm,bsm_gen\[27\].bsm,bsm_gen\[28\].bsm,bsm_gen\[29\].bsm,bsm_gen\[30\].bsm,bsm_gen\[31\].bsm"; ; ;Not use this BSM in LPDDR4 mode
      precharging_timer[$bits(dh_bs_t_rp_m1)-1:0]    <= dh_gs_lpddr4 ?
                                         ((dh_bs_t_rp_m1 <= ({{($bits(dh_bs_t_rp_m1)-1){1'b0}},~dh_bs_frequency_ratio})) ? {($bits(dh_bs_t_rp_m1)){1'b0}} : (dh_bs_t_rp_m1 - ({{($bits(dh_bs_t_rp_m1)-1){1'b0}},~dh_bs_frequency_ratio})))
                                       :  (|dh_bs_t_rp_m1) ? dh_bs_t_rp_m1 - 1 : 0;
      // ccx_cond_end
//spyglass enable_block W484
    // NOTE: odd behavior: in the case of auto-precharge in a multi-burst setting
    //       (for example half-bus-width in BL=4 mode), the autopre will appear to
    //       be set on each read or write here, resetting the precharging timer each
    //       time.  In actuality, PI will only set the auto-precharge on the last
    //       read/write in the burst.
    // Wait t_rp + X where X is:
    // For Rp:
    // X is greater of (rd2pre-1) OR (no_pre_after_act_timer_dec)
    // For Wp:
    // X is greater of (wr2pre-1) OR (no_pre_after_act_timer_dec)
    // No explict -1 used with no_pre_after_act_timer_dec as "-1" is in it already
    
    // For HS mode, -1 should not be used, possibly because of rounding in definition of rd2pre?
    end else if (this_bank_rd_autopre_reg) begin
        if ({{($bits(no_pre_after_act_timer_wider)-$bits(reg_ddrc_rda2pre_fr)-1){1'b0}},reg_ddrc_rda2pre_fr}>no_pre_after_act_timer_wider[$bits(no_pre_after_act_timer_wider)-2:0])
            precharging_timer           <= {{($bits(precharging_timer)-$bits(dh_bs_t_rp_m1)){1'b0}},dh_bs_t_rp_m1} + {{($bits(precharging_timer)-$bits(reg_ddrc_rda2pre_fr)){1'b0}},reg_ddrc_rda2pre_fr};
        else 
            precharging_timer           <= {{($bits(precharging_timer)-$bits(dh_bs_t_rp_m1)){1'b0}},dh_bs_t_rp_m1} + {{($bits(precharging_timer)-($bits(no_pre_after_act_timer_wider)-1)){1'b0}},no_pre_after_act_timer_wider[($bits(no_pre_after_act_timer_wider)-1)-1:0]}; 
    end else if (this_bank_wr_autopre_reg) begin
        if ({{($bits(no_pre_after_act_timer_wider)-$bits(reg_ddrc_rda2pre_fr)-1){1'b0}},reg_ddrc_wra2pre_fr}>no_pre_after_act_timer_wider[($bits(no_pre_after_act_timer_wider)-2):0]) // Expanded width (+1 bit) for MRAM (both right/left sides)
            precharging_timer           <= {{($bits(precharging_timer)-$bits(dh_bs_t_rp_m1)){1'b0}},dh_bs_t_rp_m1} + {{($bits(precharging_timer)-$bits(reg_ddrc_wra2pre_fr)){1'b0}},reg_ddrc_wra2pre_fr};
        else 
            precharging_timer           <= {{($bits(precharging_timer)-$bits(dh_bs_t_rp_m1)){1'b0}},dh_bs_t_rp_m1} + {{($bits(precharging_timer)-($bits(no_pre_after_act_timer_wider)-1)){1'b0}},no_pre_after_act_timer_wider[($bits(no_pre_after_act_timer_wider)-1)-1:0]}; 
    end else if (|precharging_timer) begin
      precharging_timer         <= (precharging_timer - {{($bits(precharging_timer)-1){1'b0}},1'b1}) ;
    end
                                                                  

    // READ command to this bank
    if (this_bank_rd) begin
      // In case of LPDDR4, RD is 4-cycles wide, and PRE is 2-cycles wide. 
      // in LPDDR4 1:2 mode, the 4-cycle RD command is issued over two DDRC cycles and because of the difference
      // of command lengths, always +1 adjustment is needed.
      // In LPDDR4 1:4 mode: the 4-cycle RD command is issued over single DDRC cycle and no adjustment is needed (hence
      // the dh_bs_rd2pre_m1 version is used)
      no_pre_after_rd_timer     <= (dh_gs_lpddr4 & dh_bs_frequency_ratio) ? dh_bs_rd2pre_m1 : dh_bs_rd2pre;
    end else if (|no_pre_after_rd_timer) begin
      no_pre_after_rd_timer     <= (no_pre_after_rd_timer - {{($bits(no_pre_after_rd_timer)-1){1'b0}},1'b1});
    end

    // WRITE command to this bank
    if (this_bank_wr) begin
      // timer set to burst length (in 1x clocks) plus write recovery time
      // In case of LPDDR4, WR/MWR is 4-cycles wide, and PRE is 2-cycles wide. Because of the difference
      // of command lengths, +1 adjustment is needed .
      // (NOTE: The following 2 lines are applied properly in CodeCoverage eXclusion process, but it doesn't work with 3 or more lines)
      // ccx_cond_begin:"bsm_gen\[8\].bsm,bsm_gen\[9\].bsm,bsm_gen\[10\].bsm,bsm_gen\[11\].bsm,bsm_gen\[12\].bsm,bsm_gen\[13\].bsm,bsm_gen\[14\].bsm,bsm_gen\[15\].bsm";   ; ;Not use this BSM in LPDDR4 mode
      // ccx_cond_begin:"bsm_gen\[24\].bsm,bsm_gen\[25\].bsm,bsm_gen\[26\].bsm,bsm_gen\[27\].bsm,bsm_gen\[28\].bsm,bsm_gen\[29\].bsm,bsm_gen\[30\].bsm,bsm_gen\[31\].bsm"; ; ;Not use this BSM in LPDDR4 mode
      no_pre_after_wr_timer     <= (dh_gs_lpddr4 && dh_bs_frequency_ratio) ? {{($bits(no_pre_after_wr_timer)-$bits(dh_bs_wr2pre_m1)){1'b0}},dh_bs_wr2pre_m1} :
                                       {{($bits(no_pre_after_wr_timer)-$bits(dh_bs_wr2pre)){1'b0}},dh_bs_wr2pre};
      // ccx_cond_end
    end else if (|no_pre_after_wr_timer) begin
      no_pre_after_wr_timer     <= (no_pre_after_wr_timer - {{($bits(no_pre_after_wr_timer)-1){1'b0}},1'b1}) ;
    end

     // t_ccd_mw_timer implementation - the latency from write or masked write to masked write for same bank is t_ccd_mw
     // Note, in the case of write with BL=32, t_ccd_mw must be (tCCDMW + 8) same as JEDEC specification
     // ccx_cond:;;01; Redundant for LPDDR controller
    if (mask_wr_en && this_bank_wr)
      t_ccd_mw_timer <= (dh_bs_t_ccd_mw_int - {{($bits(dh_bs_t_ccd_mw_int)-2){1'b0}},2'b10});
    else if (|t_ccd_mw_timer)
      t_ccd_mw_timer <= t_ccd_mw_timer - {{($bits(t_ccd_mw_timer)-1){1'b0}},1'b1};

  end // else: not in reset
end // always: synchronous process for timers
//spyglass enable_block STARC05-2.11.3.1

assign no_pre_after_act_timer = no_pre_after_act_timer_wider[$bits(no_pre_after_act_timer)-1:0];
assign pre_critical_timer = pre_critical_timer_wider[$bits(pre_critical_timer)-1:0];

assign block_rdwr_cmds = sel_blk_ccd_timer;
assign block_rd_cmds   = sel_blk_wr2rd_timer || gs_op_is_wr;
assign block_wr_cmds   = sel_blk_rd2wr_timer || gs_op_is_rd;

    // Block signal for 2-cycles wide commands after PRE, RDw/AP, WRw/AP, MWRw/AP.
    // The period is 2-cycles in 1:1 mode, and 1-cycle in 1:2 mode after precharging is done.

    wire                        state_precharge_to_idle;        // BSM state transitions from PRECHARGING to IDLE
    reg    [DYN_NUM_RANKS-1:0]  state_precharge_to_idle_rank;

    assign state_precharge_to_idle  = ((current_state == BSM_STATE_PRECHARGING) && (next_state == BSM_STATE_IDLE));

    //spyglass disable_block W415a
    //SMD: Signal state_precharge_to_idle_rank is being assigned multiple times in same always block. 
    //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
    always @(*) begin
        state_precharge_to_idle_rank                     = state_precharge_to_idle;
    end
    //spyglass enable_block W415a

    always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
            bs_os_no_2ck_cmds_after_pre <= {DYN_NUM_RANKS{1'b0}};
        end else begin
            bs_os_no_2ck_cmds_after_pre <= state_precharge_to_idle_rank;
        end
    end

    assign  no_2ck_cmds_after_pre =  bs_os_no_2ck_cmds_after_pre;


   // WR to RDA timer
   // use this when tWR > tWTR + nRTP
   always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         wr2rda_timer <= {$bits(wr2rda_timer){1'b0}};
      end
     // ccx_cond:;;10; Redundant for safty. wr2pre is always larger than rda2pre
      else if (this_bank_wr && (dh_bs_wr2pre >= reg_ddrc_rda2pre_m1)) begin
      //spyglass disable_block W164a
      //SMD: LHS: 'wr2rda_timer' width 8 is less than RHS: '(dh_bs_wr2pre - reg_ddrc_rda2pre_m1)' width 9 in assignment
      //SJ: Underflow not possible
         wr2rda_timer <= dh_bs_wr2pre - reg_ddrc_rda2pre_m1;
      //spyglass enable_block W164a
      end
      else if (|wr2rda_timer) begin
         wr2rda_timer <= wr2rda_timer - {{($bits(wr2rda_timer)-1){1'b0}},1'b1};
      end
   end

   // Auto-PRE flag for RD
   assign rd_autopre = (te_os_rd_cmd_autopre_table[0] | (te_os_rd_pageclose_autopre
                                                         & (~te_os_rd_cmd_autopre_table[1])
                                                        ));

   // RDA
   assign rda_ok = ~(|wr2rda_timer) | dh_gs_lpddr4;


//-------------/------------- dh_bs_close_page_timer 

reg pageclose_timer_set_x_r;
// only set timer if:
// - next command for this bank in CAM is a page hit for this bank, RD
// - next command for this bank in CAM is a page hit for this bank, WR
// - AND, precharge is possible, current_state==BSM_STATE_ROW_ACTIVE
wire pageclose_timer_set_x =  this_bank_wr | this_bank_rd | te_bs_rd_bank_page_hit | te_bs_wr_bank_page_hit;
wire pageclose_timer_set_y = (current_state==BSM_STATE_ROW_ACTIVE) ? 1'b1 : 1'b0;
wire pageclose_timer_set_z = pageclose_timer_set_x_r & pageclose_timer_set_y;

// only set counter if pageclose is eanbeld in software
wire pageclose_timer_set = dh_bs_pageclose & pageclose_timer_set_z ;

localparam PAGECLOSE_TIMER_CNT_W = 8;
localparam PAGECLOSE_TIMER_CNT_W_ONE = {{(PAGECLOSE_TIMER_CNT_W-1){1'b0}},{1'b1}};
localparam PAGECLOSE_TIMER_CNT_W_ZERO = {(PAGECLOSE_TIMER_CNT_W){1'b0}};
wire pageclose_timer_cnt_zero;              
reg [PAGECLOSE_TIMER_CNT_W-1:0] pageclose_timer_cnt;
reg                             dh_bs_pageclose_timer_zero;
   
always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    pageclose_timer_set_x_r <= 1'b0;
    dh_bs_pageclose_timer_zero <= 1'b0;
    pageclose_timer_cnt <= PAGECLOSE_TIMER_CNT_W_ZERO;     
  end else begin
    pageclose_timer_set_x_r <= pageclose_timer_set_x;
    dh_bs_pageclose_timer_zero <= ~|dh_bs_pageclose_timer;
    if (pageclose_timer_set) begin
      pageclose_timer_cnt <= dh_bs_pageclose_timer- PAGECLOSE_TIMER_CNT_W_ONE;
    end else if (!pageclose_timer_cnt_zero) begin
      pageclose_timer_cnt <= pageclose_timer_cnt - PAGECLOSE_TIMER_CNT_W_ONE;
    end
  end
end

// flags that timer has reached zero
assign pageclose_timer_cnt_zero = ~|pageclose_timer_cnt;

// pageclose can generate explcit PRE
   wire pageclose_timer_exp = (pageclose_timer_cnt_zero | dh_bs_pageclose_timer_zero) & ~pageclose_timer_set_z & dh_bs_pageclose;


//-------------------------- Pre-Computed Flags --------------------------------

wire rank_refresh_required;
assign rank_refresh_required =  sel_rank_refresh_required
                                & ((this_ref_bank == sel_refpb_bank) || (~dh_gs_per_bank_refresh))
                                ;

wire rank_block_act_ref_req;
assign rank_block_act_ref_req = sel_rank_block_act_ref_req
                                & ((this_ref_bank == sel_refpb_bank) || (~dh_gs_per_bank_refresh))
                                ;


assign precharge_ok_next= (next_state == BSM_STATE_ROW_ACTIVE) &
                          (~(|no_pre_after_rd_timer[$bits(no_pre_after_rd_timer)-1:1] ))    &
                          (~this_bank_rd)                      &
                          (~(|no_pre_after_wr_timer[$bits(no_pre_after_wr_timer)-1:1] ))    &
                          (~this_bank_wr)                      &
                          (~(|no_pre_after_act_timer[$bits(no_pre_after_act_timer)-1:1]))    ;

assign wr_ok_next       = (~gsfsm_dis_dq)                      &
                           gs_bs_wr_mode_early                 &
                          (next_state == BSM_STATE_ROW_ACTIVE) &
                          (|pre_critical_timer[16:1])          &
                          (~sel_rank_block_wr_nxt)             &
                          (~block_rdwr_cmds)                   &
                          (~rank_refresh_required)             &
                          (~sel_load_mr_norm_required)         &
                          (~pre_required_due_to_phymstr)
                          & (~pre_required_due_to_ppt2)
                          & (~sel_zq_calib_short_required)
                          & (~block_wr_cmds)
                          ;


always @ (posedge bsm_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    rd_activate_ok      <= 1'b0;
    wr_activate_ok      <= 1'b0;
    precharge_ok        <= 1'b0;
    activate_ok         <= 1'b0;
    rd_ok               <= 1'b0;
    wr_ok               <= 1'b0;
    mwr_ok              <= 1'b0;
    act2_invalid_tmg    <= 1'b0;
    bs_os_pre_crit_vlds <= 1'b0;
    r_close_pages       <= 1'b0;
  end
  else begin
    precharge_ok        <=  precharge_ok_next;
 
    // critical precharge: tRAS(max) timer expired or tRFC(max) timer expired
    bs_os_pre_crit_vlds <= (~(|pre_critical_timer[16:1]) | rank_refresh_required | sel_load_mr_norm_required | pre_required_due_to_phymstr | pre_required_due_to_ppt2 | pre_req_dis_cam_drain
                            | sel_zq_calib_short_required
                           ) & precharge_ok_next;

      // for activate, precharge, and read/write:
      //   (applicable timers <= 1) and (correct state) and (not blocked)

      rd_activate_ok    <=  (~gsfsm_dis_dq)                   &
                            (~gs_bs_wr_mode_early)            &
                            (next_state == BSM_STATE_IDLE)    &
                            (~(|no_act_after_act_timer[$bits(no_act_after_act_timer)-1:1])) &
                            (~rank_refresh_required)          &
                            (~sel_rank_refresh_required_early) & 
                            (~sel_load_mr_norm_required)      &
                            (~pre_required_due_to_phymstr)    &
                            (~pre_required_due_to_ppt2)       &
                            (~sel_zq_calib_short_required)    &
                            (~lpddr4_blk_act_nxt)             &
                            (~sel_dqsosc_block_other_cmd)     &
                            (~sel_rank_block_act_nxt)         &
                            (~sel_rank_block_act_trfc_bk_nxt) &
                            (~sel_rank_block_act_trrd_bg_nxt) &
                            (~rank_block_act_ref_req)           ;

      wr_activate_ok    <=  (~gsfsm_dis_dq)                   &
                             gs_bs_wr_mode_early              &
                            (next_state == BSM_STATE_IDLE)    &
                            (~(|no_act_after_act_timer[$bits(no_act_after_act_timer)-1:1])) &
                            (~rank_refresh_required)          &
                            (~sel_rank_refresh_required_early) & 
                            (~sel_load_mr_norm_required)      &
                            (~pre_required_due_to_phymstr)    &
                            (~pre_required_due_to_ppt2)       &
                            (~sel_zq_calib_short_required)    &
                            (~lpddr4_blk_act_nxt)             &
                            (~sel_dqsosc_block_other_cmd)     &
                            (~sel_rank_block_act_nxt)         &
                            (~sel_rank_block_act_trfc_bk_nxt) &
                            (~sel_rank_block_act_trrd_bg_nxt) &
                            (~rank_block_act_ref_req)           ;
      activate_ok    <=  (~gsfsm_dis_dq)                   &
                            (next_state == BSM_STATE_IDLE)    &
                            (~(|no_act_after_act_timer[$bits(no_act_after_act_timer)-1:1])) &
                            (~rank_refresh_required)          &
                            (~sel_rank_refresh_required_early) & 
                            (~sel_load_mr_norm_required)      &
                            (~pre_required_due_to_phymstr)    &
                            (~pre_required_due_to_ppt2)       &
                            (~sel_zq_calib_short_required)    &
                            (~lpddr4_blk_act_nxt)             &
                            (~sel_dqsosc_block_other_cmd)     &
                            (~sel_rank_block_act_nxt)         &
                            (~sel_rank_block_act_trfc_bk_nxt) &
                            (~sel_rank_block_act_trrd_bg_nxt) &
                            (~rank_block_act_ref_req)           ;

      rd_ok             <= (~gsfsm_dis_dq)                      &
                           (~gs_bs_wr_mode_early)               &
                           (next_state == BSM_STATE_ROW_ACTIVE) &
                           (|pre_critical_timer[16:1])          &
                           (~rank_refresh_required)             &
                           (~sel_load_mr_norm_required)         &
                           (~pre_required_due_to_phymstr)       &
                           (~pre_required_due_to_ppt2)          &
                           (~sel_zq_calib_short_required)       &
                           (~sel_rank_block_rd_nxt)             &
                           (~reg_ddrc_lpddr5 |
                            ~te_b3_bit       |
                            ~sel_rank_block_cas_b3_nxt)         &
                           (~block_rdwr_cmds)                   &
                           (~block_rd_cmds)                     ;
           
      wr_ok             <= wr_ok_next;
      mwr_ok            <= wr_ok_next & ~(|t_ccd_mw_timer);
      act2_invalid_tmg  <= sel_rank_act2_invalid_tmg_nxt;

    r_close_pages       <= sel_speculative_ref | pageclose_timer_exp | gs_bs_close_pages
                        ;

// Sets a flag when a page is opened and controller is in read mode (rd_page_open)
// After that, write commands will be blocked if this flag is set; read commands are blocked if this command is not set.
// When (wr_mode is high and if rd_page_open is high) OR (if wr_mode is low and rd_page_open is low), then wrong_page_open is set
// If wrong_page_open and 16-ranks in use is high, then the BSM issues a critical precharge to immediately close any open page

  end // else: not in reset
end // always: pre-computed flags

//-------------------- Operation Requests to OS ------------------------------- 
//--------------high priority activate----------------------//
// high priority activate: only reads have high priority transactions
assign bs_os_act_hi_vlds        = ((rdwr_pol_sel ? (activate_ok & sel_act_rd & (gs_act_pre_rd_priority | ~reg_ddrc_dis_speculative_act)) : (rd_activate_ok & te_bs_rd_valid)) & 
                                     te_bs_rd_hi) 
                                 ;
//--------------high priority read/write----------------------//
// high priority reads: only reads have high priority transactions
//  this applies to ROW_ACTIVE state only - the only time page_hit may be '1'
assign bs_os_rdwr_hi_vlds       = (rd_ok & te_bs_rd_valid & te_bs_rd_page_hit & te_bs_rd_hi
                                   & (rda_ok | ~rd_autopre)
                                   & ~(sel_act_wr)
                                  ) 
                                  | (wr_ok & te_bs_wr_valid & te_bs_wr_page_hit & te_bs_wrecc_btt
                                   & (~te_bs_mwr | mwr_ok) // for LPDDR4 MWR command
                                   & ~(sel_act_rd)
                                  );

//--------------low priority activate----------------------//
// low priority activate: for low priority reads and all writes
assign bs_os_act_lo_vlds       = ((rdwr_pol_sel ? (activate_ok & sel_act_rd & (gs_act_pre_rd_priority | ~reg_ddrc_dis_speculative_act)) : (rd_activate_ok & te_bs_rd_valid)) & 
                                   (~te_bs_rd_hi))
                                 ;
assign bs_os_act_wr_vlds       = ((rdwr_pol_sel ? (activate_ok & sel_act_wr & (~gs_act_pre_rd_priority | ~reg_ddrc_dis_speculative_act)) : (wr_activate_ok & te_bs_wr_valid)) & 
                                   (~te_bs_wrecc_btt)) 
                                 ;
//--------------low priority read/write----------------------//
// low priority read/write: for low priority reads and all writes
//  this applies to ROW_ACTIVE state only - the only time page_hit may be '1'
assign bs_os_rdwr_lo_vlds       = (wr_ok & te_bs_wr_valid & te_bs_wr_page_hit & (~te_bs_wrecc_btt)
                                   & (~te_bs_mwr | mwr_ok) // for LPDDR4 MWR command
                                   & ~(sel_act_rd)
                                  ) |
                                  (rd_ok & te_bs_rd_valid & te_bs_rd_page_hit & (~te_bs_rd_hi)
                                   & (rda_ok | ~rd_autopre)
                                   & ~(sel_act_wr)
                                  ) ;

//--------------Precharge----------------------//
// precharge requested for a page miss

assign bs_os_pre_req_vlds_enh   = (precharge_ok & sel_act_rd ) |   //req precharge in write mode inculde 1) act for write or 2) act for read and no pagehit in write (because write command could be issued at same cycle as this precharge(different phase), if the write pagehit command issued, the wr_precharge_ok will become low become tWTP)
                                       (precharge_ok & r_close_pages & (~te_bs_wr_valid & ~te_bs_rd_valid) & ~gs_bs_wr_mode); 

wire bs_os_pre_req_wr_vlds_enh;
assign bs_os_pre_req_wr_vlds_enh   = (precharge_ok &  sel_act_wr )  |   //req precharge in write mode inculde 1) act for write or 2) act for read and no pagehit in write (because write command could be issued at same cycle as this precharge(different phase), if the write pagehit command issued, the wr_precharge_ok will become low become tWTP)
                                       (precharge_ok & r_close_pages & (~te_bs_wr_valid & ~te_bs_rd_valid) & gs_bs_wr_mode); 

assign bs_os_pre_req_vlds      = bs_os_pre_req_vlds_enh;
assign bs_os_pre_req_wr_vlds      = bs_os_pre_req_wr_vlds_enh;



assign cs_eq_idle    = (current_state == BSM_STATE_IDLE);

    // all pages in this bank have been closed
    assign bs_os_bank_closed    = cs_eq_idle;


assign bank_activated_early       = ~(|activating_timer[$bits(activating_timer)-1:1])
                                    & (!lp5_wait_act2)
                                    ;

//add a sub-module to select pre-activate command for read or write requests

// BSM index is consist of {rank,bank[1:0],bg[2:0]} to support DDR5 (4 bank/8 bg).
// However, in DDR4, bg[2] is not used at all, hence exclude coverage items of bg[2]==1.
localparam  IS_INACTIVE_BSM = 0
                              ;
bsm_pre_act
 #(
  //------------------------------- PARAMETERS -----------------------------------
     .IS_INACTIVE_BSM                  (IS_INACTIVE_BSM)
) bsm_pre_act (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     .co_yy_clk                        (co_yy_clk)                  // non-gated clock
    ,.core_ddrc_rstn                   (core_ddrc_rstn)             // async falling-edge reset

    ,.reg_ddrc_wr_page_exp_cycles      (reg_ddrc_wr_page_exp_cycles)
    ,.reg_ddrc_rd_page_exp_cycles      (reg_ddrc_rd_page_exp_cycles)
    ,.reg_ddrc_wr_act_idle_gap         (reg_ddrc_wr_act_idle_gap)
    ,.reg_ddrc_rd_act_idle_gap         (reg_ddrc_rd_act_idle_gap)

    ,.te_bs_rd_page_hit                (te_bs_rd_page_hit)         // banks with reads pending to open pages
    ,.te_bs_rd_valid                   (te_bs_rd_valid   )         // banks with reads pending
    ,.te_bs_wr_page_hit                (te_bs_wr_page_hit)         // banks with writes pending to open pages
    ,.te_bs_wr_valid                   (te_bs_wr_valid   )         // banks with writes pending

    ,.rd_more_crit                     (rd_more_crit)
    ,.wr_more_crit                     (wr_more_crit)
    ,.delay_switch_write_state         (delay_switch_write_state)

    ,.te_rws_wr_col_bank               (te_rws_wr_col_bank)
    ,.te_rws_rd_col_bank               (te_rws_rd_col_bank)

//    ,.wr_mode_early                    (gs_bs_wr_mode_early)       // write mode indication, 1 cycle early
    ,.wr_mode                          (gs_bs_wr_mode)             // write mode indication, 1 cycle early

    ,.sel_act_wr                       (sel_act_wr)             // select write request to activate
    ,.sel_act_rd                       (sel_act_rd)             // select read request to activate

    `ifndef SYNTHESIS
    `ifdef SNPS_ASSERT_ON
    ,.activate_ok                      (activate_ok)
    `endif // SNPS_ASSERT_ON
    `endif // SYNTHESIS
  );

//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON

// INPUT CHECKS:
property PghitTEactiveBSM;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
                ((te_bs_rd_page_hit & te_bs_rd_valid) & (te_bs_wr_page_hit & te_bs_wr_valid))  |-> (($past(current_state)==BSM_STATE_ROW_ACTIVATING) ||
                                                          ($past(current_state)==BSM_STATE_ROW_ACTIVE) ||
                                                          (current_state == BSM_STATE_ROW_ACTIVATING)     );
endproperty
// only an idle bank can be activated
property activateBankIdle;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
                this_bank_act |-> (current_state==BSM_STATE_IDLE);
endproperty
// only active banks may be precharged
property prechargeBankActive;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
                this_bank_pre |-> (current_state==BSM_STATE_ROW_ACTIVE);
endproperty

// precharging_timer should equal 0 in BSM_STATE_IDLE or BSM_STATE_ROW_ACTIVE states
property precharging_timer_xero_check;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
                ((current_state == BSM_STATE_IDLE) || (current_state == BSM_STATE_ROW_ACTIVE)) |-> (precharging_timer == {$bits(precharging_timer){1'b0}});
endproperty

// assertions associated with above properties
a_PghitTEactiveBSM : assert property (PghitTEactiveBSM)
        else $error("[%t][%m] ERROR: TE indicates page hit (read or write) when BSM state is not ACTIVE or ACTIVATING", $time);
a_activateBankIdle : assert property (activateBankIdle)
        else $error("[%t][%m] ERROR: Activate issued to a bank that is not idle.", $time);
a_prechargeBankActive : assert property (prechargeBankActive)
        else $error("[%t][%m] ERROR: Precharge issued to a bank that is not active.", $time);

// BSM checks:
// no such thing as a high priority write (except inline ECC, WRECC with BTT==1)
property writeMustBeLowPri;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
               ($past(gs_bs_wr_mode_early) & (~te_bs_wrecc_btt)) |-> !bs_os_rdwr_hi_vlds;
endproperty
a_writeMustBeLowPri : assert property (writeMustBeLowPri)
        else $error("[%t][%m] ERROR: BSM asserting high priority read/write request in write mode, but no such thing as a high priority write.", $time);

// check for rp timer for precharge duration
reg[4:0]   precharge_cnt;   // precharge duration

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
                precharge_cnt <= 5'b0;
        else if ((next_state == BSM_STATE_PRECHARGING) & ~(current_state == BSM_STATE_PRECHARGING))
                precharge_cnt <= 5'b1;
        else if (precharge_cnt == 5'b11111)
                precharge_cnt <= precharge_cnt;
        else
                precharge_cnt <= precharge_cnt + 1'b1;
end

property precharge_t_check;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) ((current_state == BSM_STATE_PRECHARGING) & ~(next_state == BSM_STATE_PRECHARGING)) |->
                (precharge_cnt >= |dh_bs_t_rp_i);
endproperty

a_precharge_t_check: assert property (precharge_t_check)
        else $error("[%t][%m] ERROR: BSM precharge is not long enough", $time);

// t_rp greater than 0
property p_t_rp_gt_zero;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
      (this_bank_rd_autopre|this_bank_wr_autopre) |-> (dh_bs_t_rp_i>{$bits(dh_bs_t_rp_i){1'b0}});
endproperty 

a_t_rp_gt_zero : assert property (p_t_rp_gt_zero)
    else $error("[%t][%m] ERROR: BSM t_rp expected to be always greater than 0", $time);    

// t_rp greather than length of Precharge command (2 cyc/1:1 mode, 1 cyc/1:2 mode)
property p_t_rp_gt_pre_length;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !dh_gs_lpddr4)
      (this_bank_pre) |-> (dh_bs_t_rp_i>{{($bits(dh_bs_t_rp)-1){1'b0}},~dh_bs_frequency_ratio});
endproperty

a_t_rp_gt_pre_length : assert property (p_t_rp_gt_pre_length)
    else $error("[%t][%m] ERROR: BSM t_rp expected to be always greater than %d in LPDDR4", $time, ({4'h0,~dh_bs_frequency_ratio}));

// rd2pre greater than 0
property p_t_rd2pre_gt_zero;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
      (this_bank_rd_autopre) |-> (dh_bs_rd2pre>0);
endproperty 

a_t_rd2pre_gt_zero : assert property (p_t_rd2pre_gt_zero) 
    else $error("[%t][%m] ERROR: BSM rd2pre expected to be always greater than 0", $time);    

// wr2pre greater than 0
property p_t_wr2pre_gt_zero;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
      (this_bank_wr_autopre) |-> (dh_bs_wr2pre>{$bits(dh_bs_wr2pre){1'b0}});
endproperty 

a_t_wr2pre_gt_zero : assert property (p_t_wr2pre_gt_zero) 
    else $error("[%t][%m] ERROR: BSM wr2pre expected to be always greater than 0", $time);    

// t_rp + rd2pre  greater than 1
property p_t_rp_plus_rd2pre_gt_one;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
      (this_bank_rd_autopre) |-> ((dh_bs_t_rp_i+dh_bs_rd2pre)>1);
endproperty 

a_t_rp_plus_rd2pre_gt_one : assert property (p_t_rp_plus_rd2pre_gt_one)
    else $error("[%t][%m] ERROR: BSM t_rp+rd2pre expected to be always greater than 1", $time);    
   
// t_rp + wr2pre  greater than 1
property p_t_rp_plus_wr2pre_gt_one;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
      (this_bank_wr_autopre) |-> ((dh_bs_t_rp_i+dh_bs_wr2pre)>1);
endproperty 

a_t_rp_plus_wr2pre_gt_one : assert property (p_t_rp_plus_wr2pre_gt_one)
    else $error("[%t][%m] ERROR: BSM t_rp+wr2pre expected to be always greater than 1", $time);    


localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time
  // no_pre_after_act_timer overflow
  assert_never #(0, 0, "no_pre_after_act_timer overflow", CATEGORY) a_no_pre_after_act_timer_overflow
    (co_yy_clk, core_ddrc_rstn, (no_pre_after_act_timer_wider[$bits(no_pre_after_act_timer_wider)-1]==1'b1));  

  // pre_critical_timer underflow
  assert_never #(0, 0, "pre_critical_timer underflow", CATEGORY) a_pre_critical_timer_underflow
    (co_yy_clk, core_ddrc_rstn, (pre_critical_timer_wider[$bits(pre_critical_timer_wider)-1]==1'b1));

  // forbid_pre_and_rw_req
  // In MEMC_FREQ_RATIO=1, bs_os_pre_req_vlds can be issued with RDWR, but it will be ignored by gs_next_xact
  property p_forbid_pre_and_rw;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn)
        ~((bs_os_rdwr_hi_vlds | bs_os_rdwr_lo_vlds) & (bs_os_pre_crit_vlds ));
  endproperty

  a_forbid_pre_and_rw: assert property (p_forbid_pre_and_rw)
    else $error("BSM requests RD/WR + PRE at the same cycle [%t][%m]", $time);

  // Check if pre_req_dis_cam_drain is one, gsfsm_dis_dq is one or no request as well
  property p_gsfsm_dis_dq_check_for_pre_req_dis_cam_drain;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn)
       (pre_req_dis_cam_drain) |-> (gsfsm_dis_dq | (~te_bs_rd_valid & ~te_bs_wr_valid));
  endproperty

  a_gsfsm_dis_dq_check_for_pre_req_dis_cam_drain: assert property (p_gsfsm_dis_dq_check_for_pre_req_dis_cam_drain)
    else $error("logic assumes gsfsm_dis_dq=1 when pre_req_dis_cam_drain=1 to prevent to request critical PRE + RW [%t][%m]", $time);


// BSM must be idle and stable while bsm_clk_en is deasserted, which occurs when sdram is in power saving mode.
// Because 'active power-down' is not supported, power saving mode always starts with all bank closed.
property p_lp_st_idle_stable;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn)
      !bsm_clk_en -> (current_state==BSM_STATE_IDLE && next_state==BSM_STATE_IDLE);
endproperty

a_lp_st_idle_stable : assert property (p_lp_st_idle_stable)
    else $error("[%t][%m] ERROR: BSM must be idle and stable while bsm_clk is disabled", $time);

covergroup cg_bsm_clk @(posedge co_yy_clk);
    cp_bsm_clk_en: coverpoint (bsm_clk_en) iff(core_ddrc_rstn);
endgroup: cg_bsm_clk
cg_bsm_clk cg_bsm_clk_en_inst = new;

property p_act_pre_forbid_chk;
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn)
        activate_ok |-> ~precharge_ok;
endproperty

a_act_pre_forbid_chk: assert property (p_act_pre_forbid_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

covergroup cg_rws_bank_status @(posedge co_yy_clk);

    cp_rws_bank_status: coverpoint ({ te_rws_rd_col_bank, te_rws_wr_col_bank, rd_more_crit, wr_more_crit, te_bs_rd_page_hit, te_bs_wr_page_hit, te_bs_rd_valid, te_bs_wr_valid }) iff(core_ddrc_rstn && rdwr_pol_sel) {
       
        wildcard illegal_bins rd_wr_more_crit = {8'b??11????} ;

       
        wildcard bins rd_col_pghit = {8'b1???1?1?} ;
        wildcard bins wr_col_pghit = {8'b?1???1?1} ;
       
        wildcard bins rd_crit_pghit = {8'b0?1?1?1?} ;
        wildcard bins wr_crit_pghit = {8'b?0?1?1?1} ;

        wildcard bins rd_pghit = {8'b0?0?1?1?} ;
        wildcard bins wr_pghit = {8'b?0?0?1?1} ;

        wildcard bins rd_valid = {8'b0?0?0?1?} ;
        wildcard bins wr_valid = {8'b?0?0?0?1} ;

        wildcard bins no_rd = {8'b0?0?0?0?} ;
        wildcard bins no_wr = {8'b?0?0?0?0} ;

    }
endgroup: cg_rws_bank_status

// Coverage group instantiation
cg_rws_bank_status cg_rws_bank_status_inst = new;




`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
//------------------------------------------------------------------------------

endmodule  // bsm (Bank State Machine)
