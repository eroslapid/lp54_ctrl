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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_rank_constraints.sv#4 $
// -------------------------------------------------------------------------
// Description:
//                This block is responsible for implementing the
//                timers, etc. required to enforce rank constraints, with the
//                exception of the same-rank activate-following-activate
//                command delay, which is enforced by the BSMs.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_rank_constraints 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS -----------------------------------
     parameter    THIS_RANK_NUMBER      = 0   // rank number this block applies to
    ,parameter    RANK_BITS             = `MEMC_RANK_BITS
    ,parameter    LRANK_BITS            = `DDRCTL_DDRC_LRANK_BITS
    ,parameter    BG_BITS               = `MEMC_BG_BITS
    ,parameter    BANK_BITS             = `MEMC_BANK_BITS
    ,parameter    BG_BANK_BITS          = `MEMC_BG_BANK_BITS
    ,parameter    RANKBANK_BITS         = LRANK_BITS + BG_BANK_BITS
    ,parameter    CID_WIDTH             = `DDRCTL_DDRC_CID_WIDTH
    ,parameter    NUM_RANKS             = 1 << RANK_BITS
    ,parameter    NUM_LRANKS            = 1 << LRANK_BITS
    ,parameter    NUM_BANKS             = 1 << BANK_BITS
    ,parameter    NUM_BG_BANKS          = 1 << BG_BANK_BITS
    ,parameter    BLK_ACT_TRFC_WDT      = (`MEMC_LPDDR4_EN == 1) ? NUM_BANKS : 1
    ,parameter    BLK_ACT_TRRD_WDT      = 1 << BG_BITS
    ,parameter    BLK_ACT_TRFM_WDT      = NUM_BANKS
    ,parameter    BLK_ACT_RAAC_WDT      = (`DDRCTL_LPDDR_RFMSBC_EN == 1) ? NUM_BG_BANKS : NUM_BG_BANKS/2
    ,parameter    NUM_BG_PER_RANK       = 1 << BG_BITS
  )
  (
  //------------------------- INPUTS AND OUTPUTS ---------------------------------
     input                                  co_yy_clk
    ,input                                  core_ddrc_rstn
    ,input      [NUM_RANKS-1:0]             dh_gs_active_ranks                      // Active ranks
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
//spyglass enable_block W240
    ,input      [RD2WR_WIDTH-1:0]           dh_gs_rd2wr                             // cycle gap between read to write same ranks
    ,input      [3:0]                       dh_gs_burst_rdwr                        // 4'h0010=burst of 4 data read/write
                                                                                    // 4'h0100=burst of 8 data read/write
                                                                                    // 4'h1000=burst of 16 data read/write
    ,input                                  dh_gs_frequency_ratio                   // 0 - 1:2 freq ratio, 1 - 1:1 freq ratio


    ,input      [REFRESH_TO_X1_X32_WIDTH-1:0]                       dh_gs_refresh_to_x1_x32                 // timeout (x1/x32) before issuing a requested
    ,input      [5:0]                       dh_gs_refresh_burst                     // 0 = refresh after each nominal refresh period
                                                                                    // 1 = send 2 consecutive refreshes after 2 nominal refresh periods
                                                                                    // ...
                                                                                    // 7 = send 8 consecutive refreshes after 8 nominal refresh periods
    ,input      [T_FAW_WIDTH-1:0]           dh_gs_t_faw                             // sliding window size in which 4 ACTs to a rank are allowed
    ,input      [T_RFC_MIN_WIDTH-1:0]       dh_gs_t_rfc_min                         // min cycles between refreshes per rank
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
    ,input      [T_PBR2PBR_WIDTH-1:0]       dh_gs_t_pbr2pbr                         // minimum time between LPDDR4 per-bank refresh refreshes different bank
    ,input      [T_PBR2ACT_WIDTH-1:0]       dh_gs_t_pbr2act                         // minimum time between LPDDR5 per-bank refresh act different bank
//spyglass enable_block W240
    ,input      [T_REFI_X1_X32_WIDTH+4:0]   t_refi                                  // average periodic refresh interval
    ,input                                  dh_gs_t_refi_x1_sel                     // specifies whether reg_ddrc_t_refi_x1_x32 reg is x1 or x32
    ,input      [T_RRD_WIDTH-1:0]           dh_gs_t_rrd                             // tRRD:  ACT to ACT min (rank)
    ,input      [T_RRD_S_WIDTH-1:0]         dh_gs_t_rrd_s                           // tRRD_S: ACT to ACT min to different BG (rank)
    ,input                                  dh_gs_refresh_update_pulse              // this signal pulses everytime the register 'refresh_update_level' is toggled
                                                                                    // used for updating the value of the refresh registers
    ,input                                  gs_pi_ctrlupd_req                       // ctrlupd request when not is use
    ,input                                  gs_pi_phyupd_pause_req                  // request to pause system due to PHY update
    //,input                                  gs_pi_stop_clk_ok
    ,input                                  gs_op_is_enter_powerdown                // send command to enter power-down
    ,input                                  gs_op_is_enter_dsm                      // enter deep sleep mode
    ,input                                  gs_op_is_cas_ws_off
    ,input                                  reg_ddrc_wck_on
    ,input      [MAX_RD_SYNC_WIDTH-1:0]     reg_ddrc_max_rd_sync                    // Max time from RD to RD/WR w/o CAS
    ,input      [MAX_WR_SYNC_WIDTH-1:0]     reg_ddrc_max_wr_sync                    // Max time from WR to WR w/o CAS
    ,input                                  gs_dram_st_sr
    ,input                                  derate_refresh_update_pulse
    ,input      [T_REFI_X1_X32_WIDTH+4:0]   derated_t_refi
    ,input      [T_REFI_X1_X32_WIDTH+4:0]   derated_t_refie
    ,input                                  dh_gs_derate_enable
    ,input                                  refab_forced
    ,input      [5:0]                       max_postponed_ref_cmd
    ,input      [4:0]                       max_ref_cmd_within_2trefi
    ,input                                  enter_selfref_related_state
    ,input                                  te_gs_rank_wr_pending                   // WR command pending to this rank in the CAM
    ,input                                  te_gs_rank_rd_pending                   // RD command pending to this rank in the CAM
    ,input  [NUM_BANKS-1:0]                 te_gs_bank_wr_pending                   // WR command pending to this rank in the CAM (per bank)
    ,input  [NUM_BANKS-1:0]                 te_gs_bank_rd_pending                   // RD command pending to this rank in the CAM (per bank)

    ,input                                  dh_gs_rank_refresh                      // cmd from the core to issue refresh
    ,input                                  dh_gs_dis_auto_refresh                  // disable auto_refresh from the controller
    ,input                                  dh_gs_phymstr_en                        // PHY Master interface enable
    ,input  [7:0]                           dh_gs_phymstr_blk_ref_x32               // Number of 32 DFI cycles that is delayed to block refresh when there is PHY Master
    ,input                                  gs_phymstr_sre_req                      // Self Refresh request due to PHY Master

    ,input                                  gs_pi_op_is_load_mr_norm                // MRS/MRR command is being issued to pi
    ,input                                  gs_pi_mrr                               // Current MR command is an internally-generated MRR
    ,input                                  gs_pi_mrr_ext                           // Current MR command is an externally-generated MRR
    ,input                                  dh_gs_2t_mode                           // 2T timing mode
    ,input                                  timer_pulse_x32                         // pulse every 32 clocks used for timers
    ,input                                  start_refresh_timer                     // 1st refresh starting refresh timer
    ,input      [T_REFI_X1_X32_WIDTH*NUM_RANKS-1:0]ref_timer_start_value_x32               // refresh timer initialization value
                                                                                    //  (used to stagger timer expirations among ranks)
    ,input      [REFRESH_MARGIN_WIDTH-1:0]  dh_gs_refresh_margin                    // start refresh this many (x32) clocks early 
    ,input                                  dh_gs_per_bank_refresh
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block and/or in RTL assertions.
    ,input                                  init_refresh
    ,input                                  load_mrw_reset_norm
    ,input      [NUM_BANKS-1:0]             os_gs_bank_closed                       // bank closed to this rank
//spyglass enable_block W240
    ,output                                 gs_bs_refpb                             // per-bank refresh indication
    ,output     [BANK_BITS-1:0]             gs_bs_refpb_bank                        // bank number for which per-bank refresh will be issued
    ,output                                 gs_lpddr54_refpb                         // For LPDDR54, bank address of REFpb has to be outputted to PI block because the command contains bank address
    ,input                                  dh_gs_lpddr4
    ,input                                  reg_ddrc_lpddr5
    ,input                                  reg_ddrc_lpddr5_opt_act_timing
    ,input      [BANK_ORG_WIDTH-1:0]        reg_ddrc_bank_org                       // bank organization (00:BG, 01:8B, 10:16B)
    ,input      [LPDDR4_DIFF_BANK_RWA2PRE_WIDTH-1:0] dh_gs_lpddr4_diff_bank_rwa2pre
    ,input      [T_PPD_WIDTH-1:0]           dh_gs_t_ppd                             // tPPD: PRE(A)-to-PRE(A) min delay
    ,input                                  pi_gs_noxact                            // no transaction allowed
    ,input                                  pi_lp5_act2_cmd
    ,input                                  gs_op_is_exit_sr_lpddr                  // LPDDR4 self-refresh exit operation
    ,output reg [BLK_ACT_TRRD_WDT-1:0]      gs_bs_rank_act2_invalid_tmg_nxt
    ,output reg                             rank_block_pre                          // block precharge command for this rank
    ,input      [2:0]                       gs_dh_operating_mode                    // 00 = uninitialized
                                                                                    // 01 = normal
                                                                                    // 02 = powerdown
                                                                                    // 03 = self-refresh
    ,input                                  init_operating_mode

    ,output                                 gs_dh_rank_refresh_busy                 // If 1: Previous dh_gs_rank_refresh has not been stored

    ,output reg                             gs_bs_rank_refresh_required             // refresh is required for this rank.  Used to trigger PRE and avoid RD/WR/ACT in bsm.v
    ,output                                 gs_bs_rank_refresh_required_early       // to block ACT in cycle of critical REF
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input                                  gsfsm_sr_entry_req                      // self-refresh entry request
//spyglass enable_block W240
    ,output                                 rank_refresh_pending                    // pending refresh to this rank (including speculative refresh)
                                                                                    // (earlier indication than _required, which is used for scheduling)
                                                                                    // This signal is used to prevent clock stop, PDE and SRE in gs_global_fsm.v
    ,output reg                             rank_refresh_required                   // refresh is required for this rank. Used in gs_next_xact.v to trigger critical refresh;
                                                                                    // used in gs_global_fsm to trigger powerdown exit.
    ,output reg                             rank_speculative_ref                    // Speculative refresh is requested for this rank.  Used in BSM to close pages
                                                                                    // Used in gs_next_xact to trigger the speculative refresh
    ,output reg [NUM_BANKS-1:0]             bank_speculative_ref                    // Speculative refresh is requested (per bank). Used in BSM to close pages
    ,output                                 wck_sync_st
    ,output                                 cas_ws_off_req
    ,output                                 gs_rank_block_cas_b3_nxt
    ,output                                 block_mrr2mrw                           // block mrw to same rank - used for MRR-MRW timing
    ,output                                 gs_bs_rank_block_act_nxt                // block activate command in next cycle
    ,output reg [BLK_ACT_TRFC_WDT-1:0]      gs_bs_rank_block_act_trfc_bk_nxt        // block activate command in next cycle for each bank
    ,output reg [BLK_ACT_TRRD_WDT-1:0]      gs_bs_rank_block_act_trrd_bg_nxt        // block activate command in next cycle for each bank group
    ,output                                 rank_block_act_ref_req                  // block activate command for this rank if a refresh is requested
    ,output                                 gs_bs_rank_block_rd_nxt                 // block read for tCCD and turn-around
    ,output                                 gs_bs_rank_block_wr_nxt                 // block write for tCCD and turn-around
    ,output reg                             rank_nop_after_refresh                  // nop/deselect required after a refresh
    ,output reg                             rank_no_refresh_after_refresh           // delay between 2 refresh commands (Include 16REF/2*tREFI logic)
    ,output reg                             rank_no_load_mr_after_refresh           // no load MR required after a refresh (include DDR4 MPR RD/WR)
    ,output reg                             rank_no_refpb_after_act                 // delay between ACT and REFpb = tRRD
    ,output                                 gs_ts_lrank_enable
    ,input      [NUM_RANKS-1:0]             rank_nop_after_load_mr_norm
    ,input      [NUM_RANKS-1:0]             rank_nop_after_zqcs                     // 
    ,output                                 refresh_required_early                  // Indication to clock stop logic in gs_global_fsm that refresh might happen in the next clock.
                                                                                    // This is unflopped version.  Clock has to be started one clock before the actual refresh.

    ,output reg                             rank_selfref_wait_ref
    ,output                                 t_rfc_min_timer_bitor
    ,input      [T_CCD_WIDTH-1:0]           dh_bs_t_ccd
    ,input      [WR2RD_WIDTH-1:0]           dh_bs_wr2rd
    ,input      [T_CCD_S_WIDTH-1:0]         dh_bs_t_ccd_s                     // short version for DDR4, the no '_' version is used as Long in DDR4 mode
    ,input      [WR2RD_S_WIDTH-1:0]         dh_bs_wr2rd_s                     // short version for DDR4, the no '_' version is used as Long in DDR4 mode
    ,input      [RD2WR_WIDTH-1:0]           reg_ddrc_rd2wr_s
    ,input      [MRR2RD_WIDTH-1:0]          reg_ddrc_mrr2rd
    ,input      [MRR2WR_WIDTH-1:0]          reg_ddrc_mrr2wr
    ,input      [MRR2MRW_WIDTH-1:0]         reg_ddrc_mrr2mrw
    ,input                                  gs_op_is_act                         // activate command selected by GS
    ,input                                  gs_op_is_rd                          // read command selected by GS
    ,input                                  gs_op_is_wr                          // write command selected by GS
    ,input                                  gs_op_is_ref                     // Refresh command is being issued to pi
    ,input                                  gsnx_op_is_ref                                 // refresh command issued, qualified by chip select [below]
    ,input                                  gs_op_is_enter_selfref               // self-refresh entry operation
    ,input                                  gs_op_is_exit_selfref                // self-refresh exit operation
    ,input                                  gsnx_op_is_zqcs                                    // ZQ comp short issued this cycle

    ,input      [NUM_RANKS-1:0]             gs_ref_cs_n
    ,input      [RANKBANK_BITS-1:0]         gs_rdwr_rankbank_num                // bank number to read/write the DRAM address for
    ,input      [RANKBANK_BITS-1:0]         gs_act_rankbank_num                 // bank number to activate the DRAM address for
    ,input                                  gs_op_is_pre                            // PREpb command is being issued to PI
    ,output     [NUM_BG_PER_RANK-1:0]       gs_bs_blk_ccd_timer
    ,output     [NUM_BG_PER_RANK-1:0]       gs_bs_blk_wr2rd_timer
    ,output     [NUM_BG_PER_RANK-1:0]       gs_bs_blk_rd2wr_timer

`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
    ,input                                  dfi_phyupd_ack
    ,input                                  dfi_ctrlupd_req
    ,input                                  zqcl_due_to_sr_exit_ext
    ,input                                  os_gs_rank_closed
    ,input                                  block_t_xs
    ,input                                  os_gs_no_2ck_cmds_after_pre
    ,input                                  rank_next_ref_bank_closed
    ,output                                 rank_ref_idle_timeout
  `endif // SNPS_ASSERT_ON
`endif // ~SYNTHESIS
  );

//---------------------------- LOCAL PARAMETERS --------------------------------
localparam  p_ref1_saturate_cnt     = 9;
localparam  p_ref2_saturate_cnt     = 17;
localparam  p_ref4_saturate_cnt     = 33;
localparam  p_ref8_saturate_cnt     = 65;
localparam  UNUSED_FOR_NON_3DS      = (THIS_RANK_NUMBER >= NUM_RANKS*1) ? 1'b1 : 1'b0;
localparam  UNUSED_FOR_2H           = (THIS_RANK_NUMBER >= NUM_RANKS*2) ? 1'b1 : 1'b0;
localparam  UNUSED_FOR_4H           = (THIS_RANK_NUMBER >= NUM_RANKS*4) ? 1'b1 : 1'b0;
localparam  UNUSED_FOR_8H           = (THIS_RANK_NUMBER >= NUM_RANKS*8) ? 1'b1 : 1'b0;
// For HW configurations which support DDR4 3DS may have gs_rank_constraints which are used only for 3DS
// (THIS_RANK_NUMBER >= NUM_RANKS) indicates the gs_rank_constrains.

// The number of refresh-idle timers to be instantiated
localparam  UNUSED_FOR_REFPB        = ((`MEMC_LPDDR4_EN == 0) || (UNUSED_FOR_NON_3DS == 1)) ? 1 : 0;
localparam  NUM_IDLE_TIMERS         = UNUSED_FOR_REFPB ? 1 : NUM_BANKS;
// The number of t_rfc_min_timer to be instantiated
// In MEMC_LPDDR4, it is the number of banks for coexistence with tpbR2pbR requirement
// except for the case where this block is only for 3DS logical ranks.
localparam  NUM_TRFC_TIMERS         = ((UNUSED_FOR_REFPB == 1) || (`MEMC_LPDDR4_EN == 0)) ? 1 : NUM_BANKS;

//-------------------------------- WIRES ---------------------------------------

wire    [$bits(dh_gs_t_faw)-1:0]   dh_gs_t_faw_i;              // sliding window size in which 4 ACTs
wire    [$bits(dh_gs_t_rrd)-1:0]   dh_gs_t_rrd_i;              // tRRD:        ACT to ACT min (rank)
wire    [$bits(dh_gs_t_rrd)-1:0]   dh_gs_t_rrd_int;            // tRRD:        ACT to ACT min (rank)
wire    [$bits(dh_gs_t_rrd_s)-1:0] dh_gs_t_rrd_s_i;            // tRRD_S:      ACT to ACT min to different BG (rank)
wire    [$bits(dh_gs_t_rrd_s)-1:0] dh_gs_t_rrd_s_int;          // tRRD_S:      ACT to ACT min to different BG (rank)



wire                            inc_refresh_cnt;            // increment the pending refresh counter
wire                            dec_refresh_cnt;            // decrement the pending refresh counter
wire                            ignore_diff_dfi_phase;      // ignore phase differences between any DFI commands
wire                            nop_after_refresh_nxt;      // NOP required after a refresh, pre-calculated
wire                            no_refresh_after_refresh;   // delay between 2 refresh commands (Include 16REF/2*tREFI logic)
wire                            no_refpb_after_act;         // delay between ACT and REFpb = tRRD
wire                            no_load_mr_after_refresh;   // block loadMR after refresh
wire                            block_act_for_t_faw_nxt;    // block act for tFAW, pre-calculated
wire    [8:0]                   rd_data_cycles;             // number of cycle a read occupies the data bus
wire    [8:0]                   wr_data_cycles;             // number of cycle a write occupies the data bus
wire                            any_act;                    // bypass or "regular" activate
wire                            any_act_this_rank;          // bypass or "regular" activate to this (logical) rank
wire                            any_act_this_physical_rank; // bypass or "regular" activate to this physical rank
wire    [BG_BITS-1:0]           any_act_bg_num;             // BG number of any ACT
wire                            pre_this_rank;              // precharge to this rank
reg                             any_act_this_rank_r;
reg                             lp5_issue_act1_r;
wire                            lp5_wait_act2;
wire                            any_rd;                     // bypass or "regular" read
wire                            any_wr;                     // write
wire                            any_rd_this_rank;           // bypass or "regular" read to this logical rank
wire                            any_rd_this_physical_rank;  // bypass or "regular" read to this physical rank
wire                            any_wr_this_rank;           // write to this logical rank
wire                            any_wr_this_physical_rank;  // write to this physical rank
wire                            any_mrr;                    // MRR
wire                            any_mrr_this_rank;

wire   [T_REFI_X1_X32_WIDTH+2:0]       i_ref_timer_start_value_x32;// internal refresh timer start value   

wire    [BANK_BITS-1:0]         curr_refpb_bank_w;          // bank address being refreshed by REFpb
wire    [NUM_BANKS-1:0]         bank_ref_done_w;            // per-bank flag indicating banks being refreshed
wire    [BANK_BITS-1:0]         gs_bs_refpb_bank_early;     // 1-cycle early gs_bs_refpb_bank
wire                            no_refpb_for_tpbr2pbr;



reg     [$bits(reg_ddrc_mrr2rd)-1:0]               t_mrr2rd_timer;
reg     [$bits(reg_ddrc_mrr2wr)-1:0]               t_mrr2wr_timer;
reg     [$bits(reg_ddrc_mrr2mrw)-1:0]              t_mrr2mrw_timer;


localparam                      this_physical_rank = 0; // For configuration with MEMC_NUM_RANKS=1

//spyglass disable_block TA_09
//SMD: Net 'DWC_ddrctl.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ts.gs.\rank_constraints[3].gs_rank_constraints0 .this_logical_rank_refresh_timer_offset[12]' [in 'gs_rank_constraints'] is not observable[affected by other input(s)].
//SJ: Functionally correct. In some configs, this_logical_rank_refresh_timer_offset[12] might never have value 1'b1
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(12 * this_physical_rank)' found in module 'gs_rank_constraints'
//SJ: This coding style is acceptable and there is no plan to change it.

// internal ref_timer_start_value
assign i_ref_timer_start_value_x32 = {{($bits(i_ref_timer_start_value_x32)-T_REFI_X1_X32_WIDTH){1'b0}},ref_timer_start_value_x32[(T_REFI_X1_X32_WIDTH*this_physical_rank)+:T_REFI_X1_X32_WIDTH]} // 15 bit
                                     ;
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block TA_09



wire                            act_cid_match;
wire                            ref_cid_match;
wire                            pre_cid_match;
// CID matching logic
assign                          act_cid_match       = 1'b1;
assign                          ref_cid_match       = 1'b1;
assign                          pre_cid_match       = 1'b1;

wire                            refresh_this_rank;          // a refresh occuring to this rank
wire                            rank_refresh_requested;     // at least 1 refresh timer expiration has occurred
                                                            //  for which no refresh has been issued.

wire                            rank_speculative_ref_w;
reg  [NUM_BANKS-1:0]            bank_speculative_ref_w;
wire                            refresh_required_predict_w;
wire                            gs_bs_rank_refresh_required_w;
wire                            rank_refresh_required_w;
wire                            speculative_refresh_early;

wire                            w2trefi_satisfied;
wire                            rank_block_pre_set;         // set rank_block_pre
wire                            rank_block_pre_hold;        // hold rank_block_pre

wire                            i_dh_gs_active_ranks;      // This logical rank is requied to be refreshed. 

wire                            bg_timing_mode;
wire                            lpddr_dev;
assign lpddr_dev        = dh_gs_lpddr4 | reg_ddrc_lpddr5;

assign bg_timing_mode   = reg_ddrc_lpddr5 && (reg_ddrc_bank_org == {$bits(reg_ddrc_bank_org){1'b0}});

//----------------------------- REGISTERS --------------------------------------
reg [3:0]                       r_same_rank_rd_delay;
reg [3:0]                       r_same_rank_wr_delay;
reg                             refresh_required_predict;       // several-cycle early indication of an upcoming refresh
reg [$bits(t_refi)-1:0]      r_t_refie;                    // synchronized nominal refresh period
reg [$bits(t_refi)-1:0]      r_t_refi;                    // synchronized nominal refresh period
reg [$bits(t_refi)-1:0]      r_t_refie_1d;

// internal flops

                                                                // blocks activate after activate to same rank (different bank)
reg [$bits(dh_gs_t_rrd):0]      t_rrd_timer [BLK_ACT_TRRD_WDT-1:0]; // down-counting timer, stops at 0
reg [$bits(dh_gs_t_faw)-1:0]    t_faw_timer_0;                  // down-counting timer, stops at 0
reg [$bits(dh_gs_t_faw)-1:0]    t_faw_timer_1;                  // down-counting timer, stops at 0
reg [$bits(dh_gs_t_faw)-1:0]    t_faw_timer_2;                  // down-counting timer, stops at 0
reg [$bits(dh_gs_t_faw)-1:0]    t_faw_timer_3;                  // down-counting timer, stops at 0
reg [1:0]                       acts_in_t_faw_0;                // counts the # of ACTs in window 0
reg [1:0]                       acts_in_t_faw_1;                // counts the # of ACTs in window 1
reg [1:0]                       acts_in_t_faw_2;                // counts the # of ACTs in window 2
reg [1:0]                       acts_in_t_faw_3;                // counts the # of ACTs in window 3

reg     [$bits(dh_gs_t_rfc_min)-1:0]                   bank_t_rfc_min_timer [NUM_TRFC_TIMERS-1:0]; // time to block a refresh after a previous one
wire    [$bits(dh_gs_t_rfc_min)-1:0]                   t_rfc_min_timer; // time to block a refresh after a previous one
wire    [$bits(dh_gs_t_rrd):0]  t_rrd_for_ref_selected;        // select t_rrd timer for LPDDR5 BG mode
reg     [NUM_BANKS-1:0]         bank_no_lp4_refpb_sb;          // no LPDDR4 REFpb allowed if same bank
reg     [$bits(dh_bs_wr2rd)-1:0]block_cas_b3_timer;            // timer for CAS_B3 blocking
reg     [MAX_RD_SYNC_WIDTH-1:0] cnt_wck_sync_period_r;
reg                             cas_ws_off_req_r;
reg                             wck_sync_st_r;

reg [8:0]                       block_rd_timer;                 // timer for read blocking data bus for next read
reg [8:0]                       block_wr_timer;                 // timer for write blocking data bus for next write


wire [$bits(t_refi)-1:0]     refresh_timer;              // timer for issuing refreshes
                                                            //  (0=no refresh)
reg [$bits(t_refi):0]        refresh_timer_wider;        // signal used to check that overflow does not occur
wire                            w_op_is_exit_selfref;       // self-refresh exit operation
reg [6:0]                       refresh_request_cnt;        // number of refreshes pending, based on
                                                            //  the original x32 timer 
                                                            //  (for blocking activates)
wire [6:0]                      refresh_request_cnt_w;      // Early timing is required to prevent unnecessary PRE from issuing(3961)

reg [6:0]                       core_refresh_request_cnt;   // number of core-requested refreshes pending
reg                             r_gs_dh_rank_refresh_busy;  // used to change the behavior of rank_refresh_busy signal (CRM_9000709911)         

reg                             rank_rdwr_pending;          // RDWR pending to this rank in the CAM
reg  [NUM_BANKS-1:0]            bank_rdwr_pending;          // RDWR pending to this rank for each bank in the CAM
reg  [$bits(dh_gs_refresh_to_x1_x32)-1:0] ref_idle_timer [NUM_IDLE_TIMERS-1:0];   // idle time cycles for speculative refresh
wire [NUM_IDLE_TIMERS-1:0]      clr_ref_idle_timer;         // clear idle time cycles
wire [NUM_IDLE_TIMERS-1:0]      ref_idle_timeout;           // idle time cycles expired

reg                             refresh_timer_started;      // refresh timer has been started
wire                            set_bursting_refresh;       // signale to set bursting_refresh
wire                            w_set_bursting_refresh;
reg [`MEMC_GS_REF_DLY-2:0]      set_bursting_refresh_r;     // 
reg                             set_bursting_refresh_dly;   // delayed set_bursting_refresh
reg                             bursting_refresh;           // performing burst-of-8 refresh
reg                             bursting_refresh_dly;       // performing burst-of-8 refresh
reg [6:0]                       refreshes_to_burst;         // add one to register value to determine
                                                            // how many refreshes to perform consecutively
wire [5:0]                      refresh_burst_w;
reg                             bursting_refresh_due_to_core_cmd; // performing burst-of-8 refresh due to refresh cmd from core
reg                             r_dh_gs_rank_refresh;       // flop of the incoming refresh command from the core
reg                             r_dh_gs_dis_auto_refresh;   // flop of incoming register signal
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
reg                             r_dh_gs_dis_auto_refresh_r; // flop of incoming register signal
  `endif
`endif
wire                            auto_refresh_disable_pulse; // pulse when disable goes high
wire                            w_dh_gs_dis_auto_refresh;

wire [6:0]                      w_ref_saturate_cnt;
wire [6:0]                      w_core_ref_saturate_cnt;
wire                            w_refresh_request_cnt_max;
wire                            w_core_refresh_request_cnt_max;
reg                             trrd_adj_lpddr54;            // tRRD adjustment btw ACT and REFpb for LPDDR54
reg [$bits(dh_gs_t_ppd)-1:0]    t_ppd_timer;                // tPPD down counter

reg                             refresh_update_pulse_1d;
reg                             refresh_update_pulse_2d;
reg                             derate_refresh_update_pulse_1d;

 // MRR command
 assign any_mrr = gs_pi_op_is_load_mr_norm & (gs_pi_mrr | gs_pi_mrr_ext);


assign gs_ts_lrank_enable =
       dh_gs_active_ranks[this_physical_rank]            // This physical rank is active
;
//======================== Just assign to "_i" signal =======================
assign  dh_gs_t_faw_i   = dh_gs_t_faw;
assign  dh_gs_t_rrd_i   = dh_gs_t_rrd;
assign  dh_gs_t_rrd_s_i = {{($bits(dh_gs_t_rrd_s_i)-$bits(dh_gs_t_rrd_s)){1'b0}}, dh_gs_t_rrd_s};

// "-1 -1" i.e. "-2" operation performed later on t_rrd/trrd_s/t_rrd_dlr to set t_rrd_timer
// Ensure no rounding issues occur by setting to a min of 2
wire    [$bits(dh_gs_t_rrd)-1:0]   t_rrd_int;
wire    [$bits(dh_gs_t_rrd_s)-1:0] t_rrd_s_int;

assign  t_rrd_int     = (dh_gs_t_rrd_i>{{($bits(dh_gs_t_rrd_i)-1){1'b0}},1'b1})      ? {{($bits(t_rrd_int)-$bits(dh_gs_t_rrd_i)){1'b0}},dh_gs_t_rrd_i}       : {{($bits(t_rrd_int)-2){1'b0}},2'b10};
assign  t_rrd_s_int   = (dh_gs_t_rrd_s_i>{{($bits(dh_gs_t_rrd_s_i)-1){1'b0}},1'b1})  ? {{($bits(t_rrd_s_int)-$bits(dh_gs_t_rrd_s_i)){1'b0}},dh_gs_t_rrd_s_i} : {{($bits(t_rrd_s_int)-2){1'b0}},2'b10};

assign  dh_gs_t_rrd_int     = (reg_ddrc_lpddr5 & reg_ddrc_lpddr5_opt_act_timing) ? (t_rrd_int   - {{($bits(dh_gs_t_rrd_int)-1){1'b0}}, 1'b1})   : t_rrd_int;
assign  dh_gs_t_rrd_s_int   = (reg_ddrc_lpddr5 & reg_ddrc_lpddr5_opt_act_timing) ? (t_rrd_s_int - {{($bits(dh_gs_t_rrd_s_int)-1){1'b0}}, 1'b1}) : t_rrd_s_int;


assign t_rfc_min_timer_bitor = |t_rfc_min_timer;

//-------------------- Pre-Calculated Constraint Outputs -----------------------
// block act next cycle if
//   (t_faw_timer > 1) & (4 acts_in_faw | (3 acts_in_t_faw & any_act)))

  // if LPDDR2/3, include REFpb to this rank in block_act_for_t_faw_nxt
// generation as max of 4 (ACT or REFpb) within TFAW window
assign block_act_for_t_faw_nxt  =
        ((|t_faw_timer_0[($bits(t_faw_timer_0)-1):1]) & acts_in_t_faw_0[1] & (acts_in_t_faw_0[0] | any_act_this_rank | (dh_gs_per_bank_refresh & refresh_this_rank))) |
        ((|t_faw_timer_1[($bits(t_faw_timer_1)-1):1]) & acts_in_t_faw_1[1] & (acts_in_t_faw_1[0] | any_act_this_rank | (dh_gs_per_bank_refresh & refresh_this_rank))) |
        ((|t_faw_timer_2[($bits(t_faw_timer_2)-1):1]) & acts_in_t_faw_2[1] & (acts_in_t_faw_2[0] | any_act_this_rank | (dh_gs_per_bank_refresh & refresh_this_rank))) |
        ((|t_faw_timer_3[($bits(t_faw_timer_3)-1):1]) & acts_in_t_faw_3[1] & (acts_in_t_faw_3[0] | any_act_this_rank | (dh_gs_per_bank_refresh & refresh_this_rank)))  ;


    // In the following cases, do not need to take account of a difference of DFI phase
    // - 2T timing mode
    // - (Shared AC mode, being programmed to 2T timing mode)
    // - DDR4 geardown mode
    // - LPDDR4
    assign ignore_diff_dfi_phase    = 
                                    | dh_gs_2t_mode
                                    | dh_gs_lpddr4
                                    | reg_ddrc_lpddr5
                                    ;

    assign nop_after_refresh_nxt    = (|t_rfc_min_timer[$bits(t_rfc_min_timer)-1:1]) || gsnx_op_is_ref;
    assign no_refresh_after_refresh = gsnx_op_is_ref
                                    | (
                                        // LPDDR4/5 REFpb can be issued after tpbR2pbR if bank address is different from previous one
                                        (dh_gs_per_bank_refresh) ? (no_refpb_for_tpbr2pbr | bank_no_lp4_refpb_sb[gs_bs_refpb_bank_early]) :
                                        (|t_rfc_min_timer[$bits(t_rfc_min_timer)-1:1])
                                    )
                                    | (dh_gs_per_bank_refresh & block_act_for_t_faw_nxt)
                                    | (!w2trefi_satisfied) 
                                    ;
 

    assign t_rrd_for_ref_selected = (bg_timing_mode) ? ((gs_bs_refpb_bank<4) ? (t_rrd_timer[0] | t_rrd_timer[2])  : // Even BG performed REFpb
                                                                               (t_rrd_timer[1] | t_rrd_timer[3])) : // Odd  BG performed REFpb
                                                        t_rrd_timer[0]; // All timer is same value.

    // For LPDDR4, +2 DRAM clock cycles adjustment is required because ACT is 4-cycles and REF is 2-cycles
    // When the FR4 mode, FRE command is always issued on phase 2 and 3. Therefore addtional cycles are not needed.
    // For LPDDR5, +2 DRAM clock cycles adjustment is required because tRRD is defined between ACT2 and REFpb.
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
            trrd_adj_lpddr54 <= 1'b0;
        end else begin
 if(gs_ts_lrank_enable) begin
            if (((dh_gs_lpddr4 && !dh_gs_frequency_ratio) || reg_ddrc_lpddr5) && any_act_this_rank) begin
                trrd_adj_lpddr54 <= 1'b1;
            end else if (!lp5_wait_act2 & (!(|t_rrd_for_ref_selected[$bits(t_rrd_for_ref_selected)-1:1]) &
                                           !(reg_ddrc_lpddr5 & reg_ddrc_lpddr5_opt_act_timing & t_rrd_for_ref_selected[0]))) begin    // +1 in FR2 begin
                trrd_adj_lpddr54 <= 1'b0;
            end
 end
        end
    end

    assign no_refpb_after_act   = any_act_this_rank | (|t_rrd_for_ref_selected[$bits(t_rrd_for_ref_selected)-1:1]) | lp5_wait_act2 | trrd_adj_lpddr54 |
                                  (reg_ddrc_lpddr5 & reg_ddrc_lpddr5_opt_act_timing & t_rrd_for_ref_selected[0]);


    assign no_load_mr_after_refresh = gsnx_op_is_ref; // +1 cycle

// Activate constraints:
//   * t_faw,
//   * ZQCS and NOP-after-ZQCS
//   * LoadMR and NOP-after-LoadMR
//   * Also, don't activate a new page if we're trying to do a refresh
assign gs_bs_rank_block_act_nxt = block_act_for_t_faw_nxt
                                | gs_pi_op_is_load_mr_norm
                                | rank_nop_after_load_mr_norm[this_physical_rank]
                                | gsnx_op_is_zqcs
                                | rank_nop_after_zqcs[this_physical_rank]
                                ;

assign gs_bs_rank_refresh_required_early = rank_refresh_required_w; // To prevent ACT in this cycle

generate
  if (UNUSED_FOR_REFPB == 0) begin : UNUSED_FOR_REFPB_0_gen
    // Activate constraints:
    //  * tRFCmin after REF
    always @(*) begin : block_act_trfc_bk_PROC0
        integer i;
        for (i=0; i<BLK_ACT_TRFC_WDT; i=i+1) begin
            if (dh_gs_per_bank_refresh) begin
                gs_bs_rank_block_act_trfc_bk_nxt[i] = ignore_diff_dfi_phase ? (refresh_this_rank | (|bank_t_rfc_min_timer[i][$bits(bank_t_rfc_min_timer[i])-1:1]))
                                                                            : (refresh_this_rank | (|bank_t_rfc_min_timer[i][$bits(bank_t_rfc_min_timer[i])-1:0]));
            end else
            begin
                gs_bs_rank_block_act_trfc_bk_nxt[i] = ignore_diff_dfi_phase ? (refresh_this_rank | (|t_rfc_min_timer[$bits(t_rfc_min_timer)-1:1]))
                                                                            : (refresh_this_rank | (|t_rfc_min_timer[$bits(t_rfc_min_timer)-1:0]));
            end
        end // for loop
    end
  end
  else begin : UNUSED_FOR_REFPB_1_gen
    always @(*) begin : block_act_trfc_bk_PROC1
        integer i;
        for (i=0; i<BLK_ACT_TRFC_WDT; i=i+1) begin
            begin
                gs_bs_rank_block_act_trfc_bk_nxt[i] = ignore_diff_dfi_phase ? (refresh_this_rank | (|t_rfc_min_timer[$bits(t_rfc_min_timer)-1:1]))
                                                                            : (refresh_this_rank | (|t_rfc_min_timer[$bits(t_rfc_min_timer)-1:0]));
            end
        end // for loop
    end
  end
endgenerate



// Activate constraints:
//  * tRRD after ACT (including tRRD_s and tRRD_dlr)
//  * tRRD after REFpb
always @(*) begin : block_act_trrd_bg_PROC
    integer i;
    for (i=0; i<BLK_ACT_TRRD_WDT; i=i+1) begin
        gs_bs_rank_block_act_trrd_bg_nxt[i] = any_act_this_physical_rank
                                            | (dh_gs_per_bank_refresh & refresh_this_rank)
                                            | lp5_wait_act2
                                            | (|t_rrd_timer[i][$bits(t_rrd_timer[i])-1:1]);
    end
end

   always @(*) begin : block_act2_invalid_tmg_PROC
      integer i;
      for (i=0; i<BLK_ACT_TRRD_WDT; i=i+1) begin
         gs_bs_rank_act2_invalid_tmg_nxt[i] = reg_ddrc_lpddr5 & reg_ddrc_lpddr5_opt_act_timing &
                                              (t_rrd_timer[i][0] | 
                                               (t_faw_timer_0[0] & (acts_in_t_faw_0 == 2'b11)) |
                                               (t_faw_timer_1[0] & (acts_in_t_faw_1 == 2'b11)) |
                                               (t_faw_timer_2[0] & (acts_in_t_faw_2 == 2'b11)) |
                                               (t_faw_timer_3[0] & (acts_in_t_faw_3 == 2'b11)));
      end
   end

assign w_dh_gs_dis_auto_refresh = dh_gs_dis_auto_refresh ;

assign rank_block_act_ref_req = (refresh_required_predict
                                );

// CAS(B3) constraitns
assign gs_rank_block_cas_b3_nxt = (|block_cas_b3_timer[$bits(block_cas_b3_timer)-1:1]);

// Read constraints
//  (don't need to look at tRFC=NOP-after-refresh because it blocks ACTs,
//  making rd/wr impossible) 

assign gs_bs_rank_block_rd_nxt= 
                                  ((cnt_wck_sync_period_r == {{($bits(cnt_wck_sync_period_r)-1){1'b0}},1'b1}) && !reg_ddrc_wck_on) |     // WCK sync off
                                  (reg_ddrc_wck_on & !wck_sync_st_r & rank_nop_after_load_mr_norm[this_physical_rank]) |      // block CAS-WS_FS
                                  (|t_mrr2rd_timer) |
                                  any_rd | any_wr |
                                  (|block_rd_timer[$bits(block_rd_timer)-1:1]);

// Write constraints
//  (don't need to look at tRFC=NOP-after-refresh because it blocks ACTs,
//  making rd/wr impossible) 
assign gs_bs_rank_block_wr_nxt= 
                                  ((cnt_wck_sync_period_r == {{($bits(cnt_wck_sync_period_r)-1){1'b0}},1'b1}) && !reg_ddrc_wck_on) |     // WCK sync off
                                  (reg_ddrc_wck_on & !wck_sync_st_r & rank_nop_after_load_mr_norm[this_physical_rank]) |      // block CAS-WS_FS
                                  (|t_mrr2wr_timer) |
                                  any_rd | any_wr |
                                  (|block_wr_timer[$bits(block_wr_timer)-1:1]) ;

//===================== Logic related to PHY Master ===========================

// block automatic REF (critical) if PHY Master is required
// This blocks ongoing critical refresh too e.g. 64 REFpb in worse case
// refresh_burst setting 

wire block_auto_ref_due_to_phymstr_w; 
reg  block_auto_ref_due_to_phymstr;

assign block_auto_ref_due_to_phymstr_w = gs_phymstr_sre_req & dh_gs_phymstr_en;

// count specified DFI cycles before block refresh when there is PHY Master
wire phymstr_blk_ref_cnt_dec_pulse;             // pulse signal used to trigger the counter's self-decrement
wire [12:0] time_dly_b4_phymstr_blk_ref_ini;
wire [12:0] time_dly_b4_phymstr_blk_ref_dec;
wire [12:0] phymstr_blk_ref_cnt_pre;
reg  [12:0] phymstr_blk_ref_cnt;

assign phymstr_blk_ref_cnt_dec_pulse = block_auto_ref_due_to_phymstr_w & ~block_auto_ref_due_to_phymstr;
assign time_dly_b4_phymstr_blk_ref_ini = dh_gs_phymstr_en ? {dh_gs_phymstr_blk_ref_x32, 5'b00000} : {13{1'b0}};
assign time_dly_b4_phymstr_blk_ref_dec = (dh_gs_phymstr_en & (|phymstr_blk_ref_cnt) & block_auto_ref_due_to_phymstr_w) ? (phymstr_blk_ref_cnt - 13'h1) : {13{1'b0}};
assign phymstr_blk_ref_cnt_pre = phymstr_blk_ref_cnt_dec_pulse ? time_dly_b4_phymstr_blk_ref_ini : time_dly_b4_phymstr_blk_ref_dec;

//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop DWC_ddr_umctl2.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ts.gs.\rank_constraints[0].gs_rank_constraints0 .phymstr_blk_ref_cnt[0] (master RTL_FDCE) is  always enabled (tied high)
//SJ: gs_ts_lrank_enable is always 1 in single-rank configs
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
      phymstr_blk_ref_cnt         <= {13{1'b0}};
   end else if(gs_ts_lrank_enable)
   begin
      phymstr_blk_ref_cnt         <= phymstr_blk_ref_cnt_pre;
   end
//spyglass enable_block FlopEConst

//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop DWC_ddr_umctl2.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ts.gs.\rank_constraints[0].gs_rank_constraints0 .block_auto_ref_due_to_phymstr (master RTL_FDCE) is  always enabled (tied high)
//SJ: gs_ts_lrank_enable is always 1 in single-rank configs

// flop
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
      block_auto_ref_due_to_phymstr <= 1'b0;
   end else if(gs_ts_lrank_enable)
   begin
      block_auto_ref_due_to_phymstr <= block_auto_ref_due_to_phymstr_w;
   end
//spyglass enable_block FlopEConst


// conditions for issuing burst of refreshes due to PHY Master:
// - Only for Auto Refresh
// - PHY Master is enabled && there is a PHY Master request to enter SRE (block_auto_ref_due_to_phymstr) 
// - SRE is blocked becasue for SRX to SRE we need a REF before SRE is allowed
// - no split RD/WR command ongoing
wire ref_due_to_phymstr;
assign ref_due_to_phymstr = 
                            (~dh_gs_dis_auto_refresh)
                            & block_auto_ref_due_to_phymstr 
                            & rank_selfref_wait_ref
                              ;
  


//===================== END Logic related to PHY Master ========================

//------------------------- Refresh-Related Outputs ----------------------------

// Assert gs_dh_rank_refresh_busy for one clock cycle, in order to deassert APB register reg_ddrc_rank_refres 
// This is regardless of r_dh_gs_dis_auto_refresh, as reg_ddrc_rank_refresh should be deasserted in any case. 
// Note that gs_dh_rank_refresh_busy is not required to stay high for more clock cycles as core_refresh_request_cnt stores pending requests.
assign gs_dh_rank_refresh_busy          = r_gs_dh_rank_refresh_busy; 

//rank_refresh_busy logic - used to change the behavior of rank_refresh_busy signal (CRM_9000709911)
// Note! Clock gating does not apply for this flop as refreshes may be sent by SW for non-active ranks
// and rank_refresh_busy must be activated/deactivated for these requests as well
//--------------------------------------------------------------------------------------------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if(!core_ddrc_rstn) begin
        r_gs_dh_rank_refresh_busy <= 1'b0;
    end
    else
    begin
        if ( dh_gs_rank_refresh )
            r_gs_dh_rank_refresh_busy <= 1'b1;
        else if (
            // Do not clear if core_refresh_request_cnt is saturated
            // Example for non-DDR4 configurations, or DDR4 with fixed 1x FGR (Fine Granularity Refresh):
            // If core_refresh_request_cnt = 8, we know it is about to increment to 9 (saturated)
            // If core_refresh_request_cnt = 9, and a refresh is being sent, it will no longer be saturated, so we can clear the busy signal
            // For DDR4 configurations with 2x FGR, the saturate value is 17, and for 4x FGR, saturate value is 33
            (dh_gs_per_bank_refresh &&
                ((core_refresh_request_cnt < (p_ref8_saturate_cnt[6:0]-1)) || ((core_refresh_request_cnt == p_ref8_saturate_cnt[6:0]) && (refresh_this_rank == 1'b1)))
            ) ||
            ((core_refresh_request_cnt < (p_ref1_saturate_cnt[6:0]-1)) || ((core_refresh_request_cnt == p_ref1_saturate_cnt[6:0]) && (refresh_this_rank == 1'b1)))
        ) // if
            r_gs_dh_rank_refresh_busy <= 1'b0;
    end
end
//--------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------
// tRFCmin timer
//---------------------------------------------------------------------------
genvar gt;
generate
    for (gt=0; gt<NUM_TRFC_TIMERS; gt=gt+1) begin : bank_t_rfc_min_timer_gen
        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (!core_ddrc_rstn) begin
                bank_t_rfc_min_timer[gt] <= {$bits(bank_t_rfc_min_timer[gt]){1'b0}};
            end else if(gs_ts_lrank_enable)
            begin
                if (refresh_this_rank) // refresh command to this rank
                begin
                    if(reg_ddrc_lpddr5 && dh_gs_per_bank_refresh && (gs_bs_refpb_bank != $unsigned(gt))) begin
                    //LPDDR5 REFpb-to-ACT diff bank 
                      if(bank_t_rfc_min_timer[gt] < {{{$bits(bank_t_rfc_min_timer[gt]) - $bits(dh_gs_t_pbr2act)}{1'b0}},dh_gs_t_pbr2act}) begin //tpbr2act is always smaller than trfc. This if statement is to avoid overriding a trfc value.
                         bank_t_rfc_min_timer[gt] <= (dh_gs_t_pbr2act - {{($bits(bank_t_rfc_min_timer[gt])-1){1'b0}},1'b1});
                      end else begin
                      // This else statement can be reached only when bank_t_rfc_min_timer[gt] is grather than dh_gs_t_pbr2act. 
                         bank_t_rfc_min_timer[gt] <= bank_t_rfc_min_timer[gt] - {{($bits(bank_t_rfc_min_timer[gt])-1){1'b0}},1'b1};
                      end
                    end
                    // In LPDDR4 per-bank refresh mode, initialize timer of bank to be refreshed
                    // In other cases, all timers are initialized
                    else if (!dh_gs_per_bank_refresh || (gs_bs_refpb_bank == $unsigned(gt))) begin
                      bank_t_rfc_min_timer[gt] <= (dh_gs_t_rfc_min - {{($bits(bank_t_rfc_min_timer[gt])-1){1'b0}},1'b1});
                    end
                end else if (|bank_t_rfc_min_timer[gt]) begin
                    bank_t_rfc_min_timer[gt] <= bank_t_rfc_min_timer[gt] - {{($bits(bank_t_rfc_min_timer[gt])-1){1'b0}},1'b1};
                end
            end
        end
    end // for

    if (NUM_TRFC_TIMERS == 1) begin : num_trfc_timer_eq1
        assign t_rfc_min_timer  = bank_t_rfc_min_timer[0];
    end else begin : num_trfc_timer_ne1
        // tRFCmin of most-recently-issued refresh because this is not used for per-bank operations
        assign t_rfc_min_timer  =
                                    (dh_gs_per_bank_refresh || refab_forced) ? bank_t_rfc_min_timer[curr_refpb_bank_w] :
                                    bank_t_rfc_min_timer[0];
    end
endgenerate


//---------------------------------------------------------------------------
// Refresh idle timer for speculative refresh
//---------------------------------------------------------------------------
// RDWR pending to this rank in the CAM
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (!core_ddrc_rstn) begin
        rank_rdwr_pending   <= 1'b0;
        bank_rdwr_pending   <= {$bits(bank_rdwr_pending){1'b0}};
    end else if(gs_ts_lrank_enable)
    begin
        rank_rdwr_pending   <= te_gs_rank_wr_pending | te_gs_rank_rd_pending;
        bank_rdwr_pending   <= te_gs_bank_wr_pending | te_gs_bank_rd_pending;
    end
end

genvar gi;
generate
    for (gi=0; gi<NUM_IDLE_TIMERS; gi=gi+1) begin : ref_idle_timer_gen
        // signal to clear ref_idle_timer
        // - In LPDDR4 per-bank refresh mode, assert when there is pending WR/RD to corresponding bank address of this rank in the CAMs
        // - In non-LPDDR4 or all-bank refresh mode, assert when there is pending WR/RD to this rank in the CAMs
        assign clr_ref_idle_timer[gi]   = rank_rdwr_pending
                                        & (!dh_gs_per_bank_refresh || bank_rdwr_pending[gi])
                                        ;

        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (!core_ddrc_rstn) begin
                // logic requires a non-zero reset value
                // asyn flops require a static value
                // (can't use dh_gs_refresh_to_x1_x32 directly)
                ref_idle_timer[gi] <= {$bits(ref_idle_timer[gi]){1'b1}};
            end else if(gs_ts_lrank_enable)
            begin
                if (init_operating_mode || clr_ref_idle_timer[gi]) begin
                    ref_idle_timer[gi] <= {{($bits(ref_idle_timer[gi])-$bits(dh_gs_refresh_to_x1_x32)){1'b0}},dh_gs_refresh_to_x1_x32};
                end else if (|ref_idle_timer[gi]) begin
                    if (timer_pulse_x32
                        || (dh_gs_t_refi_x1_sel && dh_gs_per_bank_refresh)
                    ) begin
                        ref_idle_timer[gi] <= ref_idle_timer[gi] - {{($bits(ref_idle_timer[gi])-1){1'b0}},1'b1};
                    end
                end
            end
        end

        assign ref_idle_timeout[gi] = ~(|ref_idle_timer[gi]) & ~clr_ref_idle_timer[gi];
    end
endgenerate

`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
assign rank_ref_idle_timeout = (|ref_idle_timeout);
  `endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

//spyglass disable_block W528
//SMD: A signal or variable is set but never read - bank_ref_done_w
//SJ: Used in RTL assertions and therefore must always exist.

// block speculative refresh
wire rank_refresh_requested_msk;
assign rank_refresh_requested_msk = (~(|phymstr_blk_ref_cnt) & block_auto_ref_due_to_phymstr) ? 1'b0 : rank_refresh_requested;


reg refab_forced_1d;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn)
    refab_forced_1d <= 1'b0;
  else
    refab_forced_1d <= refab_forced;
end

// Per-bank-refresh related logic tracking the banks that are getting refresh
//---------------------------------------------------------------------------
        reg     [T_PBR2PBR_WIDTH-1:0]   t_pbr2pbr_timer; // down-counting timer for tpbR2pbR requirement
        wire    [NUM_BANKS-1:0]         bank_idle_close_nonref; // idle & closed & non-refreshed banks
        wire    [NUM_BANKS-1:0]         bank_idle_open_nonref; // idle & opened & non-refreshed banks
        wire    [NUM_BANKS-1:0]         bank_active_close_nonref; // active & closed & non-refreshed banks
        reg     [NUM_BANKS-1:0]         next_bank_ref_done;
        reg     [NUM_BANKS-1:0]         bank_ref_done;
        reg     [BANK_BITS-1:0]         next_refpb_bank_early;
        reg     [BANK_BITS-1:0]         next_refpb_bank;
        reg     [BANK_BITS-1:0]         curr_refpb_bank;

        // per-bank refresh indication
        assign gs_bs_refpb = ~init_refresh & gsnx_op_is_ref & dh_gs_per_bank_refresh & ~gs_ref_cs_n[this_physical_rank];

        // For LPDDR4, bank address of REFpb has to be outputted to PI block because the command contains bank address.
        // Outputting bank address to PI is done by gs_next_xact so we need to pass REFpb bank number to gs_next_xact; this is
        // done with the gs_bs_refpb_bank output; gs_lpddr54_refpb is used to indicate when bank number needs to be sent to PI
        // In normal operating mode (refresh), the bank address is outputted only when rank is selected, so we validate BANK with
        //    gs_lpddr54_refpb signal only when cs_n active
        // In initial operating mode (init_refresh), the bank addresses for each rank are the same and cs_n is not active, so
        //    we validate BANK even when cs_n not active
        assign gs_lpddr54_refpb = dh_gs_per_bank_refresh & (init_refresh | (gsnx_op_is_ref & ~gs_ref_cs_n[this_physical_rank]));

        //spyglass disable_block STARC05-2.11.3.1
        //SMD: Combinational and sequential parts of an FSM described in same always block
        //SJ: Reported for t_pbr2pbr_timer. Coding style used to prevent underflow. No re-coding required.

        // tpbR2pbR: Per-bank refresh to per-bank refresh different bank
        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (!core_ddrc_rstn) begin
                t_pbr2pbr_timer <= {($bits(t_pbr2pbr_timer)){1'b0}};
            end else if(gs_ts_lrank_enable)
            begin
                if (gs_lpddr54_refpb) begin
                    t_pbr2pbr_timer <= dh_gs_t_pbr2pbr - {{($bits(t_pbr2pbr_timer)-1){1'b0}},1'b1};
                end else if (|t_pbr2pbr_timer) begin
                    t_pbr2pbr_timer <= t_pbr2pbr_timer - {{($bits(t_pbr2pbr_timer)-1){1'b0}},1'b1};
                end
            end
        end
        //spyglass enable_block STARC05-2.11.3.1

        assign no_refpb_for_tpbr2pbr = (|t_pbr2pbr_timer[$bits(t_pbr2pbr_timer)-1:1]);
        
        reg auto_refab_occurred;
        always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
          if (~core_ddrc_rstn)
            auto_refab_occurred <= 1'b0;
          else if (~refab_forced)
            auto_refab_occurred <= 1'b0;
          else if (refresh_this_rank)
            auto_refab_occurred <= 1'b1;
        end

        // per-bank flag storing which bank is refreshed in current order
        always @ (*) begin
            // reset bank status if in Self Refresh or if MRW Reset is ocurring
            // Note, for MRW Reset, assume all ranks are reset at same time even for SW driven MRW
            if (w_op_is_exit_selfref || load_mrw_reset_norm || (&bank_ref_done)) begin
                next_bank_ref_done = {NUM_BANKS{1'b0}};
            end else if (~refab_forced && refab_forced_1d && auto_refab_occurred) begin
                next_bank_ref_done = gs_bs_refpb ? ({{(NUM_BANKS-1){1'b0}}, 1'b1} << gs_bs_refpb_bank) : {NUM_BANKS{1'b0}};
            // For LPDDR4, bank status also have to be updated by REFpb in initial operating mode.
            // In this case, REFpb is issued to all ranks at same time, and bank order is sequencial round-robin.
            end else if (init_operating_mode && gs_lpddr54_refpb) begin
                next_bank_ref_done = {bank_ref_done[NUM_BANKS-2:0], 1'b1};
            end else if (gs_bs_refpb) begin
                next_bank_ref_done = bank_ref_done | ({{(NUM_BANKS-1){1'b0}}, 1'b1} << gs_bs_refpb_bank);
            end else begin
                next_bank_ref_done = bank_ref_done;
            end
        end

  // spyglass disable_block FlopEConst
  // SMD: Enable pin EN on Flop DWC_ddr_umctl2.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ts.gs.\rank_constraints[0].gs_rank_constraints0 .\USED_FOR_REFPB_GEN.bank_ref_done [0] (master RTL_FDCE) is  always enabled (tied high)
  // SJ: bank_ref_done[0] is always enabled for single rank configs

        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if(!core_ddrc_rstn) begin
                bank_ref_done <= {$bits(bank_ref_done){1'b0}};
            end else if(gs_ts_lrank_enable)
            begin
                bank_ref_done <= next_bank_ref_done;
            end
        end
  // spyglass enable_block FlopEConst

        // next bank address of per-bank refresh
        always @(*) begin : BANK_NO_LP4_REFPB_SB_PROC
            integer i;
            for (i=0; i<NUM_BANKS; i=i+1) begin
                bank_no_lp4_refpb_sb[i] = |bank_t_rfc_min_timer[i][$bits(bank_t_rfc_min_timer[i])-1:1];
            end
        end

        assign bank_idle_close_nonref   =  ref_idle_timeout &  os_gs_bank_closed & ~bank_ref_done & ~bank_no_lp4_refpb_sb;
        assign bank_idle_open_nonref    =  ref_idle_timeout & ~os_gs_bank_closed & ~bank_ref_done & ~bank_no_lp4_refpb_sb;
        assign bank_active_close_nonref = ~ref_idle_timeout &  os_gs_bank_closed & ~bank_ref_done & ~bank_no_lp4_refpb_sb;

        //spyglass disable_block W415a
        //SMD: Signal next_refpb_bank_early is being assigned multiple times in same always block. 
        //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
        always @ (*) begin : next_refpb_bank_early_PROC
            integer i;

            next_refpb_bank_early = {BANK_BITS{1'b0}};
            for (i=(NUM_BANKS-1); i>=0; i=i-1) begin // search minimum bank address not being refreshed
                if (dh_gs_per_bank_refresh | refab_forced) begin
                    // search bank address with the following priority
                    //  1st: idle & closed bank
                    //  2nd: active & closed bank (critical refresh only)
                    //  3rd: idle & opened bank
                    //  4th: active & opened bank (critical refresh only)
                    if (|bank_idle_close_nonref) begin
                        if (bank_idle_close_nonref[i])      next_refpb_bank_early = $unsigned(i);
                    end else if ((|bank_active_close_nonref) & refresh_required_early) begin
                        if (bank_active_close_nonref[i])    next_refpb_bank_early = $unsigned(i);
                    end else if (|bank_idle_open_nonref) begin
                        if (bank_idle_open_nonref[i])       next_refpb_bank_early = $unsigned(i);
                    end else begin
                        if (!bank_ref_done[i])              next_refpb_bank_early = $unsigned(i);
                    end
                end else
                begin
                    if (!bank_ref_done[i]) begin
                        next_refpb_bank_early = $unsigned(i);
                    end
                end
            end
        end
        //spyglass enable_block W415a

        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (!core_ddrc_rstn) begin
                next_refpb_bank <= {$bits(next_refpb_bank){1'b0}};
            end else if(gs_ts_lrank_enable)
            begin
        //spyglass disable_block FlopEConst
        //SMD: Enable pin SEL on Flop U_ddrc/U_ddrc_cp.../next_refpb_bank[1] (master gs_rank_constraints) is always enabled (tied high)
        //SJ: For single rank configuration, rank0 is always enabled.
                next_refpb_bank <= next_refpb_bank_early;
        //spyglass enable_block FlopEConst
            end
        end

        // current bank address of per-bank refresh
        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (!core_ddrc_rstn) begin
                curr_refpb_bank <= {$bits(curr_refpb_bank){1'b0}};
            end else
 if(gs_ts_lrank_enable) begin
                if (gs_bs_refpb || (init_operating_mode && dh_gs_lpddr4 && gs_lpddr54_refpb)) begin
                  curr_refpb_bank <= next_refpb_bank;
                end
 end
        end

        assign gs_bs_refpb_bank_early   = next_refpb_bank_early;
        assign gs_bs_refpb_bank         = next_refpb_bank;
        assign curr_refpb_bank_w        = curr_refpb_bank;
        assign bank_ref_done_w          = bank_ref_done;

        always @(*) begin : BANK_SPECULATIVE_REFPB_PROC
            integer i;
            for (i=0; i<NUM_BANKS; i=i+1) begin
                if (dh_gs_per_bank_refresh) begin  // per-bank refresh mode 
                    bank_speculative_ref_w[i]   = rank_refresh_requested_msk & ref_idle_timeout[i] & ~bank_ref_done[i];
                end
                else begin // all-bank refresh mode
                    bank_speculative_ref_w[i]   = rank_refresh_requested_msk & ref_idle_timeout[i];
                end
            end
        end
//spyglass enable_block W528

// Assert to start Speculative Refresh when there are refresh requests, and refresh idle timer is timed out.
// Not assert when w_dh_gs_dis_auto_refresh=1, i.e. external refresh mode.
// Not assert when the controller is in MPSM mode, so that REF will not be issued during MPSM Entry state where some MRS can be issued.
// Not assert when bursting refresh to enter self-refresh in FGR 2x/4x mode (DDR4).
assign rank_refresh_requested           = i_dh_gs_active_ranks & (
                                        refab_forced ? (|refresh_request_cnt[6:3]) :
                                        (|refresh_request_cnt))
                                        & (~w_dh_gs_dis_auto_refresh)
                                        & ~gs_dh_operating_mode[2] // MPSM 
                                        ;
assign rank_speculative_ref_w       = rank_refresh_requested_msk & (|ref_idle_timeout)
                                    & (|bank_speculative_ref_w)
                                    ;

// block auto refresg:
// - bursting_refresh
// - bursting_refresh_dly
// If PHY Master entry is required
wire bursting_refresh_msk = (~(|phymstr_blk_ref_cnt) & block_auto_ref_due_to_phymstr) ? 1'b0 : bursting_refresh;                                   
wire bursting_refresh_dly_msk = (~(|phymstr_blk_ref_cnt) & block_auto_ref_due_to_phymstr) ? 1'b0 : bursting_refresh_dly; 
wire bursting_refresh_due_to_core_cmd_msk = bursting_refresh_due_to_core_cmd;


assign refresh_required_predict_w       = i_dh_gs_active_ranks &
                                          w2trefi_satisfied & 
                                          (bursting_refresh_msk | bursting_refresh_dly_msk | bursting_refresh_due_to_core_cmd_msk | ref_due_to_phymstr);
assign rank_refresh_pending         = i_dh_gs_active_ranks & (bursting_refresh_msk | bursting_refresh_dly_msk | bursting_refresh_due_to_core_cmd_msk | ref_due_to_phymstr | speculative_refresh_early)
                                    ;
assign rank_refresh_required_w      = i_dh_gs_active_ranks & (bursting_refresh_dly_msk | bursting_refresh_due_to_core_cmd_msk | ref_due_to_phymstr)
                                      & w2trefi_satisfied
                                      ;

// -------------------------------------------------
//  signal to set bursting_refresh
// -------------------------------------------------
// In case that FGR mode is 2x/4x mode and self-refresh request is asserted,
//   1) If current state to enter self-refresh is IMPOSSIBLE, bursting_refresh will be asserted when next inc_refresh_cnt_1d will come.
//   2) If current state to enter self-refresh is POSSIBLE, bursting_refresh will be asserted when refresh requests will be Max(7'b000_1000, refreshes_to_burst).
//      (7'b000_1000 means that even number of REF2 or multiple-of-four number of REF4x commands can be issued consecutively.)
// In other case, bursting_refresh will be asserted when refresh requests will be refreshes_to_burst.
//
// Note: use of ">= refreshes_to_burst" instead of "==" to avoid tRFC violations due to refresh_request_cnt
// saturation for when refreshes_to_burst gets updated from a high to low value
// Not assert when the controller is in MPSM mode, so that REF will not be issued during MPSM Entry state where some MRS can be issued.
assign w_set_bursting_refresh = 
                              ~w_dh_gs_dis_auto_refresh
                              & ~gs_dh_operating_mode[2] // MPSM 
                            & (
                                                                              (refresh_request_cnt >= refreshes_to_burst)
                              )
                              ;

assign set_bursting_refresh = w_set_bursting_refresh;


assign refresh_burst_w              = (dh_gs_refresh_burst > max_postponed_ref_cmd) ? max_postponed_ref_cmd :
                                                                                      dh_gs_refresh_burst;
// saturated refresh request counters
assign w_ref_saturate_cnt           =
                                        dh_gs_per_bank_refresh  ?   p_ref8_saturate_cnt[6:0] :
                                                                    {p_ref1_saturate_cnt[3:0], 3'd0};

assign w_core_ref_saturate_cnt      =
                                        dh_gs_per_bank_refresh  ?   p_ref8_saturate_cnt[6:0] :
                                                                    {3'd0, p_ref1_saturate_cnt[3:0]};

assign w_refresh_request_cnt_max        = (refresh_request_cnt < w_ref_saturate_cnt) ? 1'b0 : 1'b1;
assign w_core_refresh_request_cnt_max   = (core_refresh_request_cnt < w_core_ref_saturate_cnt) ? 1'b0 : 1'b1;

assign gs_bs_rank_refresh_required_w    = 
                                            w2trefi_satisfied &
                                            i_dh_gs_active_ranks & (bursting_refresh_dly_msk | bursting_refresh_due_to_core_cmd_msk | ref_due_to_phymstr); // to BSMs


// OR of the 2 refresh requests going to the gs_global_fsm module - one clock early than the actual refresh request
assign  refresh_required_early          = rank_refresh_required_w;
assign  speculative_refresh_early       = rank_speculative_ref_w ;

//---------------------- Intermediate signals from Inputs ----------------------
assign any_act                      = gs_op_is_act;
assign any_act_this_rank            = any_act & act_cid_match;
assign any_act_this_physical_rank   = any_act;

assign any_act_bg_num   = gs_act_rankbank_num[BG_BITS-1:0];

always_ff @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      any_act_this_rank_r <= 1'b0;
   end
   else begin
      any_act_this_rank_r <= any_act_this_rank;
   end
end

always_ff @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      lp5_issue_act1_r <= 1'b0;
   end
   else if (reg_ddrc_lpddr5 && any_act_this_rank_r) begin
      lp5_issue_act1_r <= 1'b1;
   end
   else if (pi_lp5_act2_cmd) begin
      lp5_issue_act1_r <= 1'b0;
   end
end

assign lp5_wait_act2 = (lp5_issue_act1_r && !pi_lp5_act2_cmd);

assign pre_this_rank    = gs_op_is_pre & pre_cid_match;

assign any_rd           = gs_op_is_rd
                            | (any_mrr)
    ;

//spyglass disable_block W528
//SMD: Variable any_rd_this_physical_rank is set but never read
//SJ: Used in RTL assertion/coverpoint and therefore must always exist
    assign any_rd_this_rank          = any_rd;
    assign any_rd_this_physical_rank = any_rd_this_rank;
//spyglass enable_block W528


assign any_wr           = gs_op_is_wr;
assign refresh_this_rank= gsnx_op_is_ref & (~gs_ref_cs_n[this_physical_rank]) & ref_cid_match & i_dh_gs_active_ranks;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
assign any_wr_this_rank= any_wr;
assign any_wr_this_physical_rank = any_wr_this_rank;
//spyglass enable_block W528

// Pulse when auto_refresh is disabled
assign auto_refresh_disable_pulse = w_dh_gs_dis_auto_refresh && (!r_dh_gs_dis_auto_refresh) && (gs_dh_operating_mode != 0);

// i_dh_gs_active_ranks
assign i_dh_gs_active_ranks = 
       gs_ts_lrank_enable
;

//------------------------------------------------------------------------------
//  Block Precharge command for this rank
//------------------------------------------------------------------------------
// o  Precharge to Precharge Delay (tPPD)
//
//                clk _|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|_|^|
//      pre_this_rank _____/^^^\______________________________________________
//   t_ppd_timer[2:0] ____0____X_3_X_2_X_1_X___0______________________________
//  |t_ppd_timer[2:1] _________/^^^^^^^\______________________________________
//     rank_block_pre _________/^^^^^^^^^^^\__________________________________
//

//spyglass disable_block STARC05-2.11.3.1
//SMD: Combinational and sequential parts of an FSM described in same always block
//SJ: Reported for t_ppd_timer. Coding style used to prevent underflow. No re-coding required.
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (!core_ddrc_rstn) begin
        t_ppd_timer <= {$bits(t_ppd_timer){1'b0}};
    end else if(gs_ts_lrank_enable)
    begin
        if (lpddr_dev && pre_this_rank) begin
            t_ppd_timer <= (dh_gs_t_ppd > {$bits(dh_gs_t_ppd){1'b0}}) ? (dh_gs_t_ppd - {{($bits(t_ppd_timer)-1){1'b0}},1'b1}) : {$bits(t_ppd_timer){1'b0}};
        end else if (|t_ppd_timer) begin
            t_ppd_timer <= (t_ppd_timer - {{($bits(t_ppd_timer)-1){1'b0}},1'b1});
        end
    end
end
//spyglass enable_block STARC05-2.11.3.1

assign rank_block_pre_set   = ((any_rd_this_rank | any_wr_this_rank | any_act_this_rank) & dh_gs_lpddr4 & (dh_gs_lpddr4_diff_bank_rwa2pre == 3'b100)) | (pre_this_rank & (dh_gs_t_ppd>{{($bits(dh_gs_t_ppd)-1){1'b0}},1'b1}));
assign rank_block_pre_hold  = pi_gs_noxact | (|t_ppd_timer[$bits(t_ppd_timer)-1:1]);

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (!core_ddrc_rstn) begin
        rank_block_pre <= 1'b0;
    end else
 if(gs_ts_lrank_enable) begin
    if (rank_block_pre_set) begin
        rank_block_pre <= 1'b1;
    end else if (!rank_block_pre_hold) begin
        rank_block_pre <= 1'b0;
    end
 end
end

//----------------- Non-Resetable Flops: NOPs-After-Refresh Timer --------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    rank_nop_after_refresh <= 1'b0;
    rank_no_refresh_after_refresh <= 1'b0;
    rank_no_load_mr_after_refresh <= 1'b0;
    rank_no_refpb_after_act <= 1'b0;
  end else if(gs_ts_lrank_enable)
  begin
    rank_nop_after_refresh <= nop_after_refresh_nxt;
    rank_no_refresh_after_refresh <= no_refresh_after_refresh;
    rank_no_load_mr_after_refresh <= no_load_mr_after_refresh;
    rank_no_refpb_after_act <= no_refpb_after_act;
  // just worry about the rank constraints here;
  //  override and wr_mode will be factored in only where required
end // always: pre-calculated constraints

//== Counters & Timers ==//

wire [$bits(dh_gs_refresh_margin)-1:0] refresh_margin_x32;
assign refresh_margin_x32 = dh_gs_refresh_margin;
wire [($bits(dh_gs_refresh_margin)+5)-1:0] refresh_margin;
assign refresh_margin = {dh_gs_refresh_margin, 5'b00000};

// Refresh Constraints
//  increment refresh count for the following 2 cases:
//   1) refresh timer has counted down to refresh_margin and auto refreshes are enabled
//   2) refresh timer is being started and the initial value is < refresh_margin 
assign inc_refresh_cnt      = refresh_timer_started ?
                                ((refresh_timer == {{($bits(refresh_timer)-$bits(refresh_margin)){1'b0}}, refresh_margin}) & (!r_dh_gs_dis_auto_refresh))
                                 || refab_forced & (!refab_forced_1d)
                                :
                                ((i_ref_timer_start_value_x32[T_REFI_X1_X32_WIDTH-1:0] <  {{($bits(i_ref_timer_start_value_x32[T_REFI_X1_X32_WIDTH-1:0])-$bits(refresh_margin_x32)){1'b0}},refresh_margin_x32}) & (start_refresh_timer)) ;

assign dec_refresh_cnt      = refresh_this_rank;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in RTL assertion

// creating internal signal to make the assignment below cleaner without ifdef's
wire pi_gs_burst_chop_rd_int;
assign pi_gs_burst_chop_rd_int =                                     1'b0;

wire pi_gs_burst_chop_wr_int;
assign pi_gs_burst_chop_wr_int =                                     1'b0;
//spyglass enable_block W528

// cycles to wait after a read and write
//  (extra cycles for read to other rank or afer max number of consecutive reads to this rank. extra cycles determind by r_diff_rank_rd_delay_int)



// Load diff_rank_rd_delay     when: Read not this rank and it is not burst_chop OR when max_rank_rd_cnt has reached (max_rank_rd feature)
// Load (diff_rank_rd_delay-1) when: Read not this rank and it is burst chop (max_rank_rd feature)
// Load (reg_ddrc_t_ccd_dlr-1) when: Read not this logical rank OR when max_rank_rd_cnt has reached (max_logical_rank_rd feature for 3DS)
// Load same_rank_rd_delay     when: Read is to the same rank
// Switch the block read command gap from diff_rank_gap + tCCD to tCCDdlr
assign rd_data_cycles              = 
                                                                                                                                               {{($bits(rd_data_cycles) - $bits(r_same_rank_rd_delay)){1'b0}},r_same_rank_rd_delay};
// Load diff_rank_wr_delay    when: weite is to other rank and it is NOT burst chop
// Load diff_rank_wr_delay-1) when: write is to other rank and it is burst chop
// Load same_rank_wr_delay    when: otherwise    
assign wr_data_cycles   = 
                    {{($bits(wr_data_cycles) - $bits(r_same_rank_wr_delay)){1'b0}},r_same_rank_wr_delay};


wire [$bits(dh_gs_t_faw_i)-1:0] t_faw_timerx_val;
assign t_faw_timerx_val = (dh_gs_per_bank_refresh && refresh_this_rank)      ? dh_gs_t_faw_i :
                          (reg_ddrc_lpddr5 & reg_ddrc_lpddr5_opt_act_timing) ? dh_gs_t_faw_i - {{($bits(dh_gs_t_faw_i)-2){1'b0}},2'b10} :
                                                                               dh_gs_t_faw_i - {{($bits(dh_gs_t_faw_i)-1){1'b0}},1'b1};


assign  refresh_request_cnt_w =
                                    (~i_dh_gs_active_ranks)                                             ? 7'b0000_000: // hold if this gs_rank_constraints is not used for REF
                                    // Operate bursting refreshes to adjust internal counters between all ranks.
                                    // In this case, DDRC sends unnecessary refreshes, but there is no DDR protocol violation.
                                    refresh_update_pulse_2d                                             ? refreshes_to_burst :
                                    (gs_dh_operating_mode[2] == 1'b1)                                   ? 7'b0000_000 : // reset if in deep-powerdown mode only
                                    // If entering self-refesh, add an extra REF which will be executed on SRX.
                                    // In LPDDR5 and JESD209-4B spec, Extra REF command is required obviously after exitng self-refresh state.
                                    (enter_selfref_related_state && (!w_refresh_request_cnt_max))       ?  refresh_request_cnt + 7'b0001_000 : // add an extra REF1
                                    (gs_dh_operating_mode == 3'b011) && (!rank_selfref_wait_ref)        ? refresh_request_cnt :

                                    inc_refresh_cnt && (!dec_refresh_cnt) &&
                                    (!w_refresh_request_cnt_max )                                       ?
                                        dh_gs_per_bank_refresh                                          ? refresh_request_cnt + 7'b0000_001 : // +1/8
                                                                                                          refresh_request_cnt + 7'b0001_000 : // +1

                                    dec_refresh_cnt && (!inc_refresh_cnt) &&
                                    (|refresh_request_cnt)                                              ?
                                        dh_gs_per_bank_refresh                                          ? refresh_request_cnt - 7'b0000_001 : // -1/8
                                        refab_forced && (~(|refresh_request_cnt[6:3]))                  ? refresh_request_cnt               :

                                                                                                          refresh_request_cnt - 7'b0001_000 : // -1
                                                                                                          refresh_request_cnt;

//-----------------
// Number of auto-refreshes remaining to be sent - to be used at dis_auto_refresh rising edge
wire [6:0] pending_auto_refreshes;

assign pending_auto_refreshes   = (((gs_dh_operating_mode == 3'b001 || gs_dh_operating_mode == 3'b010 || gs_dh_operating_mode == 3'b011) && (|refresh_request_cnt)) ?
                                (
                                    dh_gs_per_bank_refresh  ?   refresh_request_cnt[6:0] :
                                                                {3'd0, refresh_request_cnt[6:3]}
                                ) :                             7'd1
                                ) - (refresh_this_rank ? 7'd1 : 7'd0);

//------------------------------------------------

//spyglass disable_block STARC05-2.11.3.1
//SMD: Combinational and sequential parts of an FSM described in same always block
//SJ: Reported for block_rd_timer, block_wr_timer, block_rd_timer_other_rank, block_mrr_timer_this_rank and rd_to_refresh_timer. Coding style used to prevent underflow. No re-coding required.
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    r_same_rank_rd_delay        <= 4'b0000;
    r_same_rank_wr_delay        <= 4'b0000;
    rank_speculative_ref        <= 1'b0;
    bank_speculative_ref        <= {$bits(bank_speculative_ref){1'b0}};
    refresh_required_predict    <= 1'b0;
    rank_refresh_required       <= 1'b0;
    gs_bs_rank_refresh_required <= 1'b0;
    r_t_refie                <= {$bits(r_t_refie){1'b0}};
    r_t_refi                 <= {$bits(r_t_refi){1'b0}};
    r_t_refie_1d              <= {$bits(r_t_refie_1d){1'b0}};
    for (integer trrd_idx=0; trrd_idx<BLK_ACT_TRRD_WDT; trrd_idx++) begin
      t_rrd_timer[trrd_idx] <= {$bits(t_rrd_timer[trrd_idx]){1'b0}};
    end
    set_bursting_refresh_dly    <= 1'b0;
    set_bursting_refresh_r      <= {$bits(set_bursting_refresh_r){1'b0}};
    refresh_timer_wider         <= {{($bits(refresh_timer_wider)-13){1'b0}},13'h1FFF};    // set to {ref_timer_start_value_x32,5'd0} once out of reset
                                                                         // (async reset must reset to a static value here)
    r_dh_gs_rank_refresh            <= 1'b0;
    r_dh_gs_dis_auto_refresh      <= 1'b0;
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
    r_dh_gs_dis_auto_refresh_r    <= 1'b0;
  `endif
`endif
    refresh_timer_started       <= 1'b0;
    refresh_request_cnt         <= 7'b000_0000;
    core_refresh_request_cnt    <= 7'b000_0000;
    acts_in_t_faw_0             <= 2'b00;
    acts_in_t_faw_1             <= 2'b00;
    acts_in_t_faw_2             <= 2'b00;
    acts_in_t_faw_3             <= 2'b00;
    t_faw_timer_0               <= {$bits(t_faw_timer_0){1'b0}};
    t_faw_timer_1               <= {$bits(t_faw_timer_1){1'b0}};
    t_faw_timer_2               <= {$bits(t_faw_timer_2){1'b0}};
    t_faw_timer_3               <= {$bits(t_faw_timer_3){1'b0}};
    bursting_refresh            <= 1'b0;
    bursting_refresh_dly        <= 1'b0;
    block_rd_timer              <= {$bits(block_rd_timer){1'b0}};
    block_wr_timer              <= {$bits(block_wr_timer){1'b0}};
    refreshes_to_burst          <= 7'b1111_111;
    bursting_refresh_due_to_core_cmd    <= 1'b0;
    refresh_update_pulse_1d     <= 1'b0;
    refresh_update_pulse_2d     <= 1'b0;
    derate_refresh_update_pulse_1d <= 1'b0;
  end else if(gs_ts_lrank_enable)
  begin

    refresh_update_pulse_1d     <= dh_gs_refresh_update_pulse;
    refresh_update_pulse_2d     <= refresh_update_pulse_1d;
    derate_refresh_update_pulse_1d <= derate_refresh_update_pulse;

    r_dh_gs_rank_refresh             <= 
                                        dh_gs_rank_refresh;         // flop the incoming refresh command
    r_dh_gs_dis_auto_refresh         <= w_dh_gs_dis_auto_refresh;               // flop the incoming register signal
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
    r_dh_gs_dis_auto_refresh_r       <= r_dh_gs_dis_auto_refresh;               // flop the incoming register signal
  `endif
`endif

    r_same_rank_rd_delay        <= dh_gs_burst_rdwr - 4'b0001;
    r_same_rank_wr_delay        <= dh_gs_burst_rdwr - 4'b0001;
    rank_speculative_ref        <= rank_speculative_ref_w ;
    bank_speculative_ref        <= bank_speculative_ref_w ;
    refresh_required_predict    <= refresh_required_predict_w;
    rank_refresh_required       <= rank_refresh_required_w;
    gs_bs_rank_refresh_required <= gs_bs_rank_refresh_required_w;
    // Nominal refresh period is updated before the refresh timer starts, or when
    //  dh_gs_reset_update_level transitions (indicating that t_refi
    //  has changed, been synchronized to DRAM clock, and is now safe to use
    // It is also updated with the new t_refi value from Derate module
    // when derate_refresh_update_pulse goes high
    r_t_refi     <= 
                       (derate_refresh_update_pulse || (refab_forced ^ refab_forced_1d) || (dh_gs_refresh_update_pulse && dh_gs_derate_enable)) ? derated_t_refi :
                       (dh_gs_refresh_update_pulse || (~refresh_timer_started)) ? t_refi : r_t_refi;
                                    
    r_t_refie       <= 
                       (derate_refresh_update_pulse || (refab_forced ^ refab_forced_1d) || (dh_gs_refresh_update_pulse && dh_gs_derate_enable)) ? derated_t_refie    :
                       (dh_gs_refresh_update_pulse || (~refresh_timer_started)) ? t_refi : r_t_refie;
                                    
    r_t_refie_1d  <=  r_t_refie;

    // When auto_refresh is disabled, set the refreshes_to_burst to 1 so that the
    // refreshes are served as they come in.
    // [0]: 1/8     REFpb (per-bank refresh)
    // [1]: 1/4     REF4X (DDR4 FGR 4X mode)
    // [2]: 1/2     REF2X (DDR4 FGR 2X mode)
    // [3]: 1       REF/REFab
    refreshes_to_burst          <=  r_dh_gs_dis_auto_refresh    ? 7'b0001_000 :
                                    dh_gs_per_bank_refresh      ? ({1'b0, refresh_burst_w[5:0]}         + 7'b0000_001) : // +1/8
                                                                  ({1'b0, refresh_burst_w[2:0], 3'b000} + 7'b0001_000) ; // +1

    // ACT command
    //  Enforce min time between between ACTs to the same bank
    //  and tFAW - mean time in which a max of 4 ACTs may be issued
    if (any_act_this_rank
       || (dh_gs_per_bank_refresh && refresh_this_rank)
      ) begin
      if (t_faw_timer_0 == {$bits(t_faw_timer_0){1'b0}}) begin
        t_faw_timer_0           <= t_faw_timerx_val;
        acts_in_t_faw_0         <= {$bits(acts_in_t_faw_0){1'b0}};
        t_faw_timer_1           <= (t_faw_timer_1 == {$bits(t_faw_timer_1){1'b0}}) ? // ==0
                                   {$bits(t_faw_timer_1){1'b0}} : (t_faw_timer_1 - {{($bits(t_faw_timer_1)-1){1'b0}},1'b1}); // -1
        acts_in_t_faw_1         <= acts_in_t_faw_1 + {{($bits(acts_in_t_faw_1)-1){1'b0}},1'b1};
        t_faw_timer_2           <= (t_faw_timer_2 == {$bits(t_faw_timer_2){1'b0}}) ? // ==0
                                   {$bits(t_faw_timer_2){1'b0}} : (t_faw_timer_2 - {{($bits(t_faw_timer_2)-1){1'b0}},1'b1}); // -1
        acts_in_t_faw_2         <= acts_in_t_faw_2 + {{($bits(acts_in_t_faw_2)-1){1'b0}},1'b1};
        t_faw_timer_3           <= (t_faw_timer_3 == {$bits(t_faw_timer_3){1'b0}}) ? // ==0
                                   {$bits(t_faw_timer_3){1'b0}} : (t_faw_timer_3 - {{($bits(t_faw_timer_3)-1){1'b0}},1'b1}); // -1
        acts_in_t_faw_3         <= acts_in_t_faw_3 + {{($bits(acts_in_t_faw_3)-1){1'b0}},1'b1};
      end
      else if (t_faw_timer_1 == {$bits(t_faw_timer_1){1'b0}}) begin
        t_faw_timer_1           <= t_faw_timerx_val;
        acts_in_t_faw_1         <= {$bits(acts_in_t_faw_1){1'b0}};
        t_faw_timer_0           <= t_faw_timer_0 - {{($bits(t_faw_timer_0)-1){1'b0}},1'b1}; // -1
        acts_in_t_faw_0         <= acts_in_t_faw_0 + {{($bits(acts_in_t_faw_0)-1){1'b0}},1'b1};
        t_faw_timer_2           <= (t_faw_timer_2 == {$bits(t_faw_timer_2){1'b0}}) ? // ==0
                                   {$bits(t_faw_timer_2){1'b0}} : (t_faw_timer_2 - {{($bits(t_faw_timer_2)-1){1'b0}},1'b1}); // -1
        acts_in_t_faw_2         <= acts_in_t_faw_2 + {{($bits(acts_in_t_faw_2)-1){1'b0}},1'b1};
        t_faw_timer_3           <= (t_faw_timer_3 == {$bits(t_faw_timer_3){1'b0}}) ? // ==0
                                   {$bits(t_faw_timer_3){1'b0}} : (t_faw_timer_3 - {{($bits(t_faw_timer_3)-1){1'b0}},1'b1}); // -1
        acts_in_t_faw_3         <= acts_in_t_faw_3 + {{($bits(acts_in_t_faw_3)-1){1'b0}},1'b1};
      end
      else if (t_faw_timer_2 == {$bits(t_faw_timer_2){1'b0}}) begin
        t_faw_timer_2           <= t_faw_timerx_val;
        acts_in_t_faw_2         <= {$bits(acts_in_t_faw_2){1'b0}};
        t_faw_timer_0           <= t_faw_timer_0 - {{($bits(t_faw_timer_0)-1){1'b0}},1'b1}; // -1
        acts_in_t_faw_0         <= acts_in_t_faw_0 + {{($bits(acts_in_t_faw_0)-1){1'b0}},1'b1};
        t_faw_timer_1           <= t_faw_timer_1 - {{($bits(t_faw_timer_1)-1){1'b0}},1'b1}; // -1
        acts_in_t_faw_1         <= acts_in_t_faw_1 + {{($bits(acts_in_t_faw_1)-1){1'b0}},1'b1};
        t_faw_timer_3           <= (t_faw_timer_3 == {$bits(t_faw_timer_3){1'b0}}) ? // ==0
                                   {$bits(t_faw_timer_3){1'b0}} : (t_faw_timer_3 - {{($bits(t_faw_timer_3)-1){1'b0}},1'b1}); // -1
        acts_in_t_faw_3         <= acts_in_t_faw_3 + {{($bits(acts_in_t_faw_3)-1){1'b0}},1'b1};
      end
      else if (t_faw_timer_3 == {$bits(t_faw_timer_3){1'b0}}) begin
        t_faw_timer_3           <= t_faw_timerx_val;
        acts_in_t_faw_3         <= {$bits(acts_in_t_faw_3){1'b0}};
        t_faw_timer_0           <= t_faw_timer_0 - {{($bits(t_faw_timer_0)-1){1'b0}},1'b1}; // -1
        acts_in_t_faw_0         <= acts_in_t_faw_0 + {{($bits(acts_in_t_faw_0)-1){1'b0}},1'b1};
        t_faw_timer_1           <= t_faw_timer_1 - {{($bits(t_faw_timer_1)-1){1'b0}},1'b1}; // -1
        acts_in_t_faw_1         <= acts_in_t_faw_1 + {{($bits(acts_in_t_faw_1)-1){1'b0}},1'b1};
        t_faw_timer_2           <= t_faw_timer_2 - {{($bits(t_faw_timer_2)-1){1'b0}},1'b1}; // -1
        acts_in_t_faw_2         <= acts_in_t_faw_2 + {{($bits(acts_in_t_faw_2)-1){1'b0}},1'b1};
      end
    end 
    else begin
      t_faw_timer_0             <= (t_faw_timer_0 == {$bits(t_faw_timer_0){1'b0}}) ? {$bits(t_faw_timer_0){1'b0}} :  // == 0
                                   (lp5_wait_act2 && (acts_in_t_faw_0 == {$bits(acts_in_t_faw_0){1'b0}})) ? t_faw_timer_0 :
                                                                                     (t_faw_timer_0 - {{($bits(t_faw_timer_0)-1){1'b0}},1'b1}); // -1
      t_faw_timer_1             <= (t_faw_timer_1 == {$bits(t_faw_timer_1){1'b0}}) ? {$bits(t_faw_timer_1){1'b0}} :  // == 0
                                   (lp5_wait_act2 && (acts_in_t_faw_1 == {$bits(acts_in_t_faw_1){1'b0}})) ? t_faw_timer_1 :
                                                                                     (t_faw_timer_1 - {{($bits(t_faw_timer_1)-1){1'b0}},1'b1}); // -1
      t_faw_timer_2             <= (t_faw_timer_2 == {$bits(t_faw_timer_2){1'b0}}) ? {$bits(t_faw_timer_2){1'b0}} :  // == 0
                                   (lp5_wait_act2 && (acts_in_t_faw_2 == {$bits(acts_in_t_faw_2){1'b0}})) ? t_faw_timer_2 :
                                                                                     (t_faw_timer_2 - {{($bits(t_faw_timer_2)-1){1'b0}},1'b1}); // -1
      t_faw_timer_3             <= (t_faw_timer_3 == {$bits(t_faw_timer_3){1'b0}}) ? {$bits(t_faw_timer_3){1'b0}} :  // == 0
                                   (lp5_wait_act2 && (acts_in_t_faw_3 == {$bits(acts_in_t_faw_3){1'b0}})) ? t_faw_timer_3 :
                                                                                     (t_faw_timer_3 - {{($bits(t_faw_timer_3)-1){1'b0}},1'b1}); // -1
    end // else

    if (any_rd)                              
      block_rd_timer            <= rd_data_cycles;                            // this is same_rank or diff_rank value based on any_rd_this_rank
    else if (|block_rd_timer)
      block_rd_timer            <= (block_rd_timer - {{($bits(block_rd_timer)-1){1'b0}},1'b1});





    // Block Write logic
    if (any_wr)
      block_wr_timer            <= wr_data_cycles;
    else if (|block_wr_timer)
      block_wr_timer            <= (block_wr_timer - {{($bits(block_wr_timer)-1){1'b0}},1'b1});



        // tRRD timer (RAS-to-RAS delay, same rank)
        // (the cycle after the act, the timer should start at "[reg value] - 1";
        //  this approach should give only one instance of the decrementer)
        //  * if new RAS, start timer next cycle at register tRRD value minus 1
        //  * if not new RAS, and timer is 0, keep it at zero
        //  * otherwise, decrement timer
        for (integer trrd_idx=0; trrd_idx<BLK_ACT_TRRD_WDT; trrd_idx++) begin
            if (dh_gs_lpddr4 && dh_gs_per_bank_refresh && refresh_this_rank) begin // For LPDDR4 REFpb-to-ACT
                // -1 clock adjustment is required when 1:2 mode, because REFpb is 2-cycles and ACT is 4-cycles command
                // When 1:4 mode, clock adjustment is not needed, because REFpb is issued phase 2 and 3.
                t_rrd_timer[trrd_idx]   <= ((dh_gs_t_rrd_int > ({{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1})) ?
                                            ({{($bits(t_rrd_timer[trrd_idx])-$bits(dh_gs_t_rrd_int)){1'b0}},dh_gs_t_rrd_int} - ({{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},~dh_gs_frequency_ratio})) : {{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1}
                                           ) - {{($bits(t_rrd_timer[trrd_idx])-$bits(ignore_diff_dfi_phase)){1'b0}},ignore_diff_dfi_phase};
            end else if (dh_gs_lpddr4 && any_act_this_rank) begin // ACT-to-ACT or ACT-to-REFpb
                // For ACT-to-REFpb, +2 clock adjustment (+1 in 1:2 mode) is required, but not done here (done by trrd_adj_lpddr54 signal)
                t_rrd_timer[trrd_idx]   <= {{($bits(t_rrd_timer[trrd_idx])-$bits(dh_gs_t_rrd_int)){1'b0}},dh_gs_t_rrd_int} - {{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1};
            end else
            if (any_act_this_rank) begin
                //spyglass disable_block W216
                //SMD: Inappropriate range select for int_part_sel variable: "trrd_idx[(BG_BITS - 1):0] "
                //SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)
                if (bg_timing_mode && (trrd_idx[BG_BITS-1:0] != any_act_bg_num)) begin
                    if (t_rrd_timer[trrd_idx] < {{($bits(t_rrd_timer[trrd_idx])-$bits(dh_gs_t_rrd_s_int)){1'b0}},dh_gs_t_rrd_s_int}) begin
                        t_rrd_timer[trrd_idx]   <= {{($bits(t_rrd_timer[trrd_idx])-$bits(dh_gs_t_rrd_s_int)){1'b0}},dh_gs_t_rrd_s_int} - {{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1};
                    end
                    else begin
                        t_rrd_timer[trrd_idx]   <= t_rrd_timer[trrd_idx] - {{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1};
                    end
                end else
                //spyglass enable_block W216
                begin
                    t_rrd_timer[trrd_idx]   <= {{($bits(t_rrd_timer[trrd_idx])-$bits(dh_gs_t_rrd_int)){1'b0}},dh_gs_t_rrd_int} - {{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1};
                end
            end
            else if (t_rrd_timer[trrd_idx] != {$bits(t_rrd_timer[trrd_idx]){1'b0}}) begin
                t_rrd_timer[trrd_idx]   <=
                                           (lp5_wait_act2) ? t_rrd_timer[trrd_idx] :
                                                             t_rrd_timer[trrd_idx] - {{($bits(t_rrd_timer[trrd_idx])-1){1'b0}},1'b1};
            end
        end // for loop

        // refresh timer & counter
        refresh_timer_started <= (refresh_timer_started | (i_dh_gs_active_ranks & start_refresh_timer)) 
                                 && (gs_dh_operating_mode[2] != 1'b1);
                                 //if in deep-powerdown mode stop the refresh timer
              

    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '(refresh_timer_wider[16:0] > (r_t_refie_1d - r_t_refie))' found in module 'gs_rank_constraints'
    //SJ: No suitable (better) re-coding found
    //spyglass disable_block W164a
    //SMD: LHS: 'refresh_timer_wider' width 18 is less than RHS: '(refresh_timer_wider[16:0]  + (r_t_rfc_nom - r_t_rfc_nom_1d))' width 19 in assignment
    //SJ: Overflow should not occur. If it does, it will be caught by the a_refresh_timer_overflow assertion.
      
    if (~refresh_timer_started)
      refresh_timer_wider <= {1'b0,i_ref_timer_start_value_x32[T_REFI_X1_X32_WIDTH-1:0], {($bits(refresh_timer_wider)-$bits(i_ref_timer_start_value_x32[T_REFI_X1_X32_WIDTH-1:0])-1){1'b0}}};
    else if ((r_t_refie > r_t_refie_1d) && (refresh_timer_wider[$bits(refresh_timer)-1:0] >= {{($bits(refresh_timer)-$bits(refresh_margin)){1'b0}},refresh_margin}) && (!inc_refresh_cnt))
      // if r_t_refie has increased, and the timer value is greater than the refresh margin,
      // add the difference to the current timer value
      refresh_timer_wider <= refresh_timer_wider[$bits(refresh_timer)-1:0] + (r_t_refie - r_t_refie_1d);
    else if ((r_t_refie < r_t_refie_1d) && (refresh_timer_wider[$bits(refresh_timer)-1:0] >= {{($bits(refresh_timer)-$bits(refresh_margin)){1'b0}},refresh_margin}) && (!inc_refresh_cnt))
      // if r_t_refie has decreased, and the timer value is greater than the refresh margin,
      // subtract the difference from the current timer value, or set timer to refresh_margin if the difference is greater than the current timer value
      refresh_timer_wider <= ((refresh_timer_wider[$bits(refresh_timer)-1:0] - {{($bits(refresh_timer)-$bits(refresh_margin)){1'b0}},refresh_margin}) > (r_t_refie_1d - r_t_refie)) ?
                             (refresh_timer_wider[$bits(refresh_timer)-1:0] - (r_t_refie_1d - r_t_refie)) :
                          {{($bits(refresh_timer_wider)-$bits(refresh_margin)){1'b0}}, refresh_margin};
    else if (!((gs_dh_operating_mode == 3'b011) && (!rank_selfref_wait_ref)))
      // if > 0, subtract 1; else reset to the register value minus 1
      //                          (need to start at "[register value] - 1", because timer spends 1 cycle at "0"
      //                           and we want the whole timer cycle time to = register value)
      refresh_timer_wider <= ((|refresh_timer_wider) ? refresh_timer_wider[$bits(refresh_timer)-1:0] : r_t_refie) - {{($bits(refresh_timer)-1){1'b0}},1'b1};

    //spyglass enable_block W164a
    //spyglass enable_block SelfDeterminedExpr-ML


    // when timer expires, increment count (unless it's already at the saturation limit)
    // when refresh is issued, decrement count (unless it's already zero)
    refresh_request_cnt         <= refresh_request_cnt_w;
    // Need version which is delayed by 4 cycles.
    // set_bursting_refresh is used to block activates.
    // set_bursting_refresh_dly is used to trigger the actual refresh request
    set_bursting_refresh_r[0] <= set_bursting_refresh;
    set_bursting_refresh_r[`MEMC_GS_REF_DLY-2:1] <= set_bursting_refresh_r[`MEMC_GS_REF_DLY-3:0];
    set_bursting_refresh_dly <= set_bursting_refresh_r[`MEMC_GS_REF_DLY - 2];

    //spyglass disable_block W164a
    //SMD: LHS: 'core_refresh_request_cnt' width 7 is less than RHS: '(pending_auto_refreshes + {5'd0 ,extra_refreshes_required_for_fgr[1:0] })' width 8 in assignment
    //SJ: Overflow does not occur. Correct behaviour is checked by the a_core_refresh_request_cnt_le_saturate_cnt assertion

    // Count of how mant core-driven refreshes are pending.
    // Reset in  SR modes
    // If dis_auto_refresh is asserted, send all pending refreshes (or set to 1 if no pending refreshes)
    // Increment if a core-refresh arrives, or if dis_auto_ref is asserted
    // Decrement if a refresh is sent
    if ((i_dh_gs_active_ranks == 1'b0) || 
        (gs_dh_operating_mode[2] == 1'b1) || 
        (gs_dh_operating_mode == 0) || 
        (w_dh_gs_dis_auto_refresh == 1'b0))
      core_refresh_request_cnt <= {$bits(core_refresh_request_cnt){1'b0}};
    else if (!r_dh_gs_dis_auto_refresh && w_dh_gs_dis_auto_refresh)
      core_refresh_request_cnt <= pending_auto_refreshes
                                  ;
    else if (refab_forced && (~refab_forced_1d) && w_core_refresh_request_cnt_max)
      core_refresh_request_cnt <= w_core_ref_saturate_cnt;
    else if (r_dh_gs_dis_auto_refresh && r_dh_gs_rank_refresh && !w_core_refresh_request_cnt_max )
      core_refresh_request_cnt <= core_refresh_request_cnt + (dec_refresh_cnt ? {$bits(core_refresh_request_cnt){1'b0}} : {{($bits(core_refresh_request_cnt)-1){1'b0}},1'b1});
    else if (dec_refresh_cnt && (|core_refresh_request_cnt))
      core_refresh_request_cnt <= core_refresh_request_cnt - {{($bits(core_refresh_request_cnt)-1){1'b0}},1'b1};
    //spyglass enable_block W164a

    // Set to 1 when set_bursting_refresh is asserted.
    // Clear to 0 when refresh requests will be 0 basically.
    // Clear to 0 when number of REF2/REF4 will be round number during bursting to enter self-refresh in FGR 2x/4x mode.
    // Clear to 0 when the controller is in MPSM mode, so that REF will not be issued during MPSM Entry state where some MRS can be issued.
    bursting_refresh        <=  (set_bursting_refresh | (bursting_refresh & (
                                 refab_forced ? |(refresh_request_cnt[6:3]) :
                                 (|refresh_request_cnt))
                                & ~gs_dh_operating_mode[2] // MPSM
                                )
                                ) & (~w_dh_gs_dis_auto_refresh);

    // Set to 1 when delayed set_bursting_refresh is asserted AND refresh_request_cnt is NOT 0.
    // Clear to 0 when refresh requests will be 0 basically.
    // However, during bursting to enter self-refresh in FGR 2x/4x mode, clear to 0 when number of REF2/REF4 will be round number.
    // if only 1 refresh was pending and the tRFC(min) is less than imposed delay on burst_refresh
    // then there is a chance that a refresh could be issued even before burst_refresh_dly went high
    // hence the check for refresh_request_cnt NOT equal to 0 added to this logic
    bursting_refresh_dly    <=  ((set_bursting_refresh_dly & (
                                  refab_forced ? |(refresh_request_cnt_w[6:3]) :
                                  (|refresh_request_cnt_w)))| 
                                  (bursting_refresh_dly & (
                                  refab_forced ? |(refresh_request_cnt_w[6:3]) :
                                  (|refresh_request_cnt_w))
                                )
                                ) & (~w_dh_gs_dis_auto_refresh);                                
    // set bursting when core_refresh_req_cnt == burst_count OR when there is refresh cmd from core OR when auto_refresh disable is turned ON
    // when auto_refresh_disable is turned on, we want to burst out all the pending refreshes
    // Note: use of ">= refreshes_to_burst" instead of "==" to avoid tRFC violations due to refresh_request_cnt 
    // saturation for when refreshes_to_burst gets updated from a high to low value
    bursting_refresh_due_to_core_cmd    <= ((
                                            ((core_refresh_request_cnt >= refreshes_to_burst[6:0]) & dh_gs_per_bank_refresh) |
                                            ((core_refresh_request_cnt >= {3'd0,refreshes_to_burst[6:3]})
                                                & ~dh_gs_per_bank_refresh
                                            )) & w_dh_gs_dis_auto_refresh) |

                                            (((gs_dh_operating_mode[2] != 1'b1) & (gs_dh_operating_mode != 3'h0))
                                                & ((r_dh_gs_dis_auto_refresh & r_dh_gs_rank_refresh) | auto_refresh_disable_pulse)) |
                                            (bursting_refresh_due_to_core_cmd & (|core_refresh_request_cnt) & w_dh_gs_dis_auto_refresh);

  end // else
  //spyglass enable_block STARC05-2.11.3.1
  
  assign refresh_timer = refresh_timer_wider[$bits(refresh_timer)-1:0];

   // WCK Sync period
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_sync_period_r <= ({$bits(cnt_wck_sync_period_r){1'b0}});
      end
      else if(gs_ts_lrank_enable)
      begin
         if (any_rd_this_physical_rank) begin
            cnt_wck_sync_period_r <= reg_ddrc_max_rd_sync;
         end
         else if (any_wr_this_physical_rank) begin
            cnt_wck_sync_period_r <= reg_ddrc_max_wr_sync;
         end
         else if (cnt_wck_sync_period_r != ({$bits(cnt_wck_sync_period_r){1'b0}})) begin
            cnt_wck_sync_period_r <= cnt_wck_sync_period_r - {{($bits(cnt_wck_sync_period_r)-1){1'b0}},1'b1};
         end
      end
   end

   // WCK sync state
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         wck_sync_st_r <= 1'b0;
      end
      else if(gs_ts_lrank_enable)
      begin
         if (reg_ddrc_wck_on && (any_rd || any_wr)) begin
            wck_sync_st_r <= 1'b1;
         end
         else if (any_rd_this_physical_rank || any_wr_this_physical_rank) begin
            wck_sync_st_r <= 1'b1;
         end
         else if (gs_op_is_enter_powerdown || gs_op_is_enter_selfref ||
                  gs_op_is_enter_dsm       || gs_op_is_cas_ws_off) begin
            wck_sync_st_r <= 1'b0;
         end
         else if ((cnt_wck_sync_period_r <= {{($bits(cnt_wck_sync_period_r)-1){1'b0}},1'b1}) && !reg_ddrc_wck_on) begin
            wck_sync_st_r <= 1'b0;
         end
      end
   end

  assign wck_sync_st   = wck_sync_st_r;


   // CAS-WS_OFF request
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cas_ws_off_req_r <= 1'b0;
      end
      else if(gs_ts_lrank_enable)
      begin
         if (gs_op_is_cas_ws_off) begin
            cas_ws_off_req_r <= 1'b0;
         end
         else if (wck_sync_st_r && (cnt_wck_sync_period_r == {$bits(cnt_wck_sync_period_r){1'b0}}) && reg_ddrc_wck_on &&
                  (gs_pi_ctrlupd_req || gs_pi_phyupd_pause_req ||
                   (gs_dram_st_sr & gs_phymstr_sre_req & dh_gs_phymstr_en))) begin
            cas_ws_off_req_r <= 1'b1;
         end
         else begin
            cas_ws_off_req_r <= 1'b0;
         end
      end
   end

  assign cas_ws_off_req = cas_ws_off_req_r;

    reg [2:0] rank_selfref_wait_refpb_cnt;

    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
          rank_selfref_wait_refpb_cnt <= 3'b000;
      end else if(gs_ts_lrank_enable)
      begin
        if (auto_refab_occurred) begin
          rank_selfref_wait_refpb_cnt <= 3'b000;
        end
        else if (rank_selfref_wait_ref && gs_op_is_ref && (!gs_ref_cs_n[this_physical_rank])) begin // Not for DDR4, No 3DS related signals 
          rank_selfref_wait_refpb_cnt <= rank_selfref_wait_refpb_cnt + 1;
        end
      end
    end

    assign w_op_is_exit_selfref =
                                  lpddr_dev ? gs_op_is_exit_sr_lpddr :
                                  gs_op_is_exit_selfref;

    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
        rank_selfref_wait_ref <= 1'b0;
      end else if(gs_ts_lrank_enable)
      begin
        if (!i_dh_gs_active_ranks) begin
          rank_selfref_wait_ref <= 1'b0;
        end else begin
          if (w_op_is_exit_selfref) begin
            rank_selfref_wait_ref <= 1'b1;
          end
          else begin
            if (dh_gs_per_bank_refresh) begin
              if (gs_op_is_ref && (!gs_ref_cs_n[this_physical_rank]) && (rank_selfref_wait_refpb_cnt==3'b111)) begin // Not for DDR4, No 3DS related signals 
                rank_selfref_wait_ref <= 1'b0;
              end
            end else begin
              if (gs_op_is_ref && (!gs_ref_cs_n[this_physical_rank])) begin // Not for DDR4, No 3DS related signals 
                rank_selfref_wait_ref <= 1'b0;
              end
            end  
          end
        end
      end
    end



/* 
  Implement the JEDEC requirement that no more than 16 REF commands can be issued within 2*tREFI

  JEDEC 209-3, Section 4.8: At any given time, a maximum of 16 REF commands can be issued within 2 x tREFI;
  And for per bank refresh ... At any given time, a maximum of 2 x 8 x 8 per bank refresh commands can be issued within 2 x tREFI.
  JEDEC 79-3, Section 4.15: At any given time, a maximum of 16 REF commands can be issued within 2 x tREFI.
  JEDEC 79-4, Section 4.8: At any given time, a maximum of 16 REF/ 32 REF2 /64 REF4 commands can be issued
  within 2 x tREFI/ 4 x tREFI2/ 8 x tREFI4.
*/

  wire [3:0] inc_cnt_next;
  assign inc_cnt_next = 
                         dh_gs_per_bank_refresh ? 4'd1 :
                          4'd8;

  reg   [17:0] w2trefi_cnt[15:0];
  reg   [4:0]  w2trefi_cnt_not_zero_num;
  reg   [6:0]  w2trefi_cnt_next_r;
  
  //spyglass disable_block W164a
  //SMD: LHS: 'w2trefi_cnt_next' width 7 is less than RHS: '(w2trefi_cnt_next_r + {3'b000 ,inc_cnt_next})' width 8 in assignment
  //SJ: Overflow is considered and expected. The width of w2trefi_cnt_next is enough for all 16 w2trefi counters in case of maximum increment (inc_cnt_next == 'd8).
  wire  [6:0]  w2trefi_cnt_next;
  assign w2trefi_cnt_next =
                              // When entering self refresh state, the last 3 bits set to 0 for perbank bank refresh. 
                              (gs_dh_operating_mode == 3'b011) ? {w2trefi_cnt_next_r[6:3],3'b0} : 
                              (gs_op_is_ref && (!gs_ref_cs_n[this_physical_rank]) && ref_cid_match) ? w2trefi_cnt_next_r + {3'b000, inc_cnt_next} : w2trefi_cnt_next_r;
  //spyglass enable_block W164a

  wire  [17:0] w2trefi_val;
  reg   [18:0] w2trefi_val_wider;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
      w2trefi_val_wider <= 19'd0;
    else
 if(gs_ts_lrank_enable) begin
      if (refresh_update_pulse_1d | (~refresh_timer_started)
             | derate_refresh_update_pulse_1d
            )
              
    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '(r_t_refi + ((derate_refresh_update_pulse_1d | (refresh_update_pulse_1d & dh_gs_derate_enable)) ? ((derate_refresh_adj_x8 ? 18'd8 : derate_refresh_adj_x4 ? 18'd4 : derate_refresh_adj_x2 ? 18'd2: 18'd1) << ((dh_gs_t_rfc_nom_x1_sel & dh_gs_per_bank_refresh) ? 0 : 5)) : 18'h20))' found in module 'gs_rank_constraints'
    //SJ: No suitable (better) re-coding found

    w2trefi_val_wider <= (((r_t_refi // this is reg_ddrc_t_refi_x1_x32
                                    // multiplied by 32 if x1_sel==0
                                    // and multiplied by 1/2/4 depending on derating
                          + ( 18'h20 ) // if no derating, just add 32
                          ) 
                                    
                             << (dh_gs_per_bank_refresh ? 3 : 0)

                          )) << 1; // multiply by 2 (for 2*tREFI)
                    
        //spyglass enable_block SelfDeterminedExpr-ML
 end
    
  end
  
  assign w2trefi_val = w2trefi_val_wider[17:0];
  
  reg   [17:0] w2trefi_val_1d;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
      w2trefi_val_1d <= 18'd0;
    else
 if(gs_ts_lrank_enable) begin
      w2trefi_val_1d <= w2trefi_val;
 end
  end
  
  integer j;

  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
      w2trefi_cnt_next_r <= 7'd0;
      for (j=0; j<16; j=j+1)
        w2trefi_cnt[j] <= 18'd0;
    end else if(gs_ts_lrank_enable)
    begin
      w2trefi_cnt_next_r <= w2trefi_cnt_next;
      //spyglass disable_block W216
      //SMD: Inappropriate range select for int_part_sel variable: "j[3:0] "
      //SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)
      //spyglass disable_block SelfDeterminedExpr-ML
      //SMD: Self determined expression '((w2trefi_val_1d - w2trefi_cnt[j]) > w2trefi_val)' found in module 'gs_rank_constraints'
      //SJ: No suitable (better) re-coding found
      //spyglass disable_block W484
      //SMD: 1) Possible assignment overflow: lhs width 18 (Expr: 'w2trefi_cnt[j]') should be greater than rhs width 18 (Expr: '(w2trefi_cnt[j] + (w2trefi_val - w2trefi_val_1d))') to accommodate carry/borrow bit
      //SMD: 2) Possible assignment overflow: lhs width 18 (Expr: 'w2trefi_cnt[j]') should be greater than rhs width 18 (Expr: '(w2trefi_val - (w2trefi_val_1d - w2trefi_cnt[j]))') to accommodate carry/borrow bit
      //SJ: For 1), overflow not possible - checked by the following 2 assertions: a_w2trefi_cnt_no_overflow and a_w2trefi_val_1d_w2trefi_cnt_underflow . For 2), underflow is not possible as we are protected by 'if' condition.
      //spyglass disable_block W164a
      //SMD: LHS: 'w2trefi_cnt[j]' width 18 is less than RHS: '(w2trefi_cnt[j] + (w2trefi_val - w2trefi_val_1d))' width 20 in assignment 
      //SJ: For 1), overflow not possible - checked by the following 2 assertions: a_w2trefi_cnt_no_overflow and a_w2trefi_val_1d_w2trefi_cnt_underflow
      for (j=0; j<16; j=j+1) begin
        // update the non-zero counters when t_refi changes:
        if ((w2trefi_val > w2trefi_val_1d) & (|(w2trefi_cnt[j])))
        // if w2trefi_val has increased, add the difference to the current counter
          w2trefi_cnt[j] <= w2trefi_cnt[j] + (w2trefi_val - w2trefi_val_1d);
        else if ((w2trefi_val < w2trefi_val_1d) & (|(w2trefi_cnt[j]))) begin
        // if w2trefi_val has decreased:
          if ((w2trefi_val_1d - w2trefi_cnt[j]) > w2trefi_val)
          // if the counter has already counted more than the new value, set counter to 0
            w2trefi_cnt[j] <= 18'd0;
          else
          // else, subtract the already counted value from the new w2trefi value
            w2trefi_cnt[j] <= w2trefi_val - (w2trefi_val_1d - w2trefi_cnt[j]);
        end
        else if (gs_op_is_ref && (!gs_ref_cs_n[this_physical_rank]) && ref_cid_match && (j[3:0] == w2trefi_cnt_next_r[6:3])
                 && ((dh_gs_per_bank_refresh) ? (&w2trefi_cnt_next_r[2:0]) : 1'b1)
                )
          // REF was issued, start a new counter
          w2trefi_cnt[j] <= w2trefi_val;
        else if ((|(w2trefi_cnt[j])) && (gs_dh_operating_mode != 3'b000)) // Except INIT
          // decrement counter
          w2trefi_cnt[j] <= w2trefi_cnt[j] - 1;
      end
      //spyglass enable_block W164a
      //spyglass enable_block W484
      //spyglass enable_block SelfDeterminedExpr-ML
      //spyglass enable_block W216
    end
  end

  //spyglass disable_block W415a
  //SMD: Signal w2trefi_cnt_not_zero_num is being assigned multiple times in same always block. 
  //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
  always @(*) begin
    w2trefi_cnt_not_zero_num = 5'b0;
    for (j=0; j<16; j=j+1) begin
      w2trefi_cnt_not_zero_num = w2trefi_cnt_not_zero_num + ((|w2trefi_cnt[j]) ? 1'b1 : 1'b0);
    end
  end
  //spyglass enable_block W415a
  
  assign w2trefi_satisfied =
                               (w2trefi_cnt_not_zero_num < max_ref_cmd_within_2trefi);
 


// ----------------------------------------------------------------------------------------------------------------------
// block read/write request
// following RTL is moved from BSM module
// ----------------------------------------------------------------------------------------------------------------------

reg     [$bits(dh_bs_t_ccd)-1:0]                   t_ccd_timer[NUM_BG_PER_RANK-1:0];           // timer for CAS to CAS delay
reg     [$bits(dh_bs_wr2rd)-1:0]                   t_wr2rd_timer[NUM_BG_PER_RANK-1:0];         // timer for write-to-read turn-around
reg     [$bits(dh_gs_rd2wr)-1:0]                   t_rd2wr_timer[NUM_BG_PER_RANK-1:0];         // timer for read-to-write turn-around

wire    [NUM_BG_PER_RANK-1:0]               this_bg_gs_rdwr;            // this bg is being addressed

wire    [NUM_BG_PER_RANK-1:0]               this_bg_rd;
wire    [NUM_BG_PER_RANK-1:0]               this_bg_wr;                 // write to this bg
wire                                        this_logical_rank_rd;       // read to this rank
wire                                        this_logical_rank_wr;       // write to this rank
wire                                        this_logical_rank_act;      // activate to this rank
wire                                        this_physical_rank_act;     // activate to thie physical rank
wire                                        this_physical_rank_rd;      // read to thie physical rank
wire                                        this_physical_rank_wr;      // write to thie physical rank


wire                                        this_cid_gs_act;            // this cid  is being addressed
wire                                        this_cid_gs_rdwr;           // this cid  is being addressed
wire                                        this_physical_rank_gs_act;  // this physical rank is being addressed
wire                                        this_logical_rank_gs_act;   // this rank is being addressed
wire                                        this_physical_rank_gs_rdwr; // this physical rank is being addressed
wire                                        this_logical_rank_gs_rdwr;  // this rank is being addressed

wire    [$bits(dh_bs_wr2rd)-1:0]            larger_wr2rd_value[NUM_BG_PER_RANK-1:0];
wire    [RD2WR_WIDTH-1:0]                   larger_rd2wr_value[NUM_BG_PER_RANK-1:0];


// --------------------------------
// Physical/Logical rank assignment
// --------------------------------
    // For 1 physical rank configuration, any access is to this_physical_rank
    assign this_physical_rank_gs_act    = gs_ts_lrank_enable;
    assign this_logical_rank_gs_act     = this_physical_rank_gs_act & this_cid_gs_act;

    assign this_physical_rank_gs_rdwr    = gs_ts_lrank_enable;
    assign this_logical_rank_gs_rdwr     = this_physical_rank_gs_rdwr & this_cid_gs_rdwr;


// -----------------------
// Logical rank assignment
// -----------------------
    assign this_cid_gs_rdwr  = 1'b1;
    assign this_cid_gs_act   = 1'b1;

// --------------------
// ANY_BYPASS
// --------------------

//spyglass disable_block W528
//SMD: Variable this_physical_rank_act set but never read
//SJ: Used in RTL assertion 

// -------------
// rank Act
// -------------
    assign this_logical_rank_act        = (this_logical_rank_gs_act & gs_op_is_act);
        assign this_physical_rank_act   = this_logical_rank_act;
//spyglass enable_block W528
// -------------
// rank Read
// -------------
    assign this_logical_rank_rd         = (this_logical_rank_gs_rdwr & gs_op_is_rd);
        assign this_physical_rank_rd    = this_logical_rank_rd;

// -------------
// rank write
// -------------
assign this_logical_rank_wr         = (this_logical_rank_gs_rdwr & gs_op_is_wr);
    assign this_physical_rank_wr    = this_logical_rank_wr;




// Per Bank Group
genvar gen_bg;
generate
for (gen_bg = 0; gen_bg < NUM_BG_PER_RANK; gen_bg=gen_bg+1) begin : gen_this_bg
    // ---------------------
    // bank group assignment
    // ---------------------
        assign this_bg_gs_rdwr[gen_bg]      = ((gs_rdwr_rankbank_num[BG_BITS-1:0] == gen_bg[BG_BITS-1:0]) && bg_timing_mode && this_logical_rank_gs_rdwr);
    
        assign this_bg_wr[gen_bg]           = (this_bg_gs_rdwr[gen_bg] & gs_op_is_wr);
    
            assign this_bg_rd[gen_bg]       = (this_bg_gs_rdwr[gen_bg] & gs_op_is_rd);

end
endgenerate


// "-1 -1" i.e. "-2" operation performed later on t_ccd to set t_ccd_timer
// t_ccd=1 is valid value
// Ensure no rounding issues occur by setting to a min of 2 
wire [$bits(dh_bs_t_ccd)-1:0] dh_bs_t_ccd_int;
assign dh_bs_t_ccd_int = (dh_bs_t_ccd>{{($bits(dh_bs_t_ccd)-1){1'b0}},1'b1}) ? dh_bs_t_ccd : {{($bits(dh_bs_t_ccd)-2){1'b0}},2'b10};


    wire [$bits(dh_bs_t_ccd_s)-1:0] dh_bs_t_ccd_s_int_rd;
    wire [$bits(dh_bs_t_ccd_s)-1:0] dh_bs_t_ccd_s_int_wr;

    assign dh_bs_t_ccd_s_int_rd =
                                    // LPDDR5 1:2
                                  (!dh_gs_frequency_ratio) ? ( (dh_bs_t_ccd_s >= {{($bits(dh_bs_t_ccd_s)-3){1'b0}},3'b100}) ? dh_bs_t_ccd_s : {{($bits(dh_bs_t_ccd_s_int_rd)-3){1'b0}},3'b100} ) :
                                    // LPDDR5 1:4, DDR4 1:2
                                                             ( (dh_bs_t_ccd_s >= {{($bits(dh_bs_t_ccd_s)-1){1'b0}},1'b1}) ? dh_bs_t_ccd_s : {{($bits(dh_bs_t_ccd_s_int_rd)-2){1'b0}},2'b10} );
              
    assign dh_bs_t_ccd_s_int_wr =
                                    // LPDDR5 1:2
                                  (!dh_gs_frequency_ratio) ? ( (dh_bs_t_ccd_s >= {{($bits(dh_bs_t_ccd_s)-3){1'b0}},3'b100}) ? dh_bs_t_ccd_s : {{($bits(dh_bs_t_ccd_s_int_wr)-3){1'b0}},3'b100} ) :
                                       // LPDDR5 1:2
                                                             ((dh_bs_t_ccd_s > {{($bits(dh_bs_t_ccd_s)-2){1'b0}},2'b10}) ? dh_bs_t_ccd_s : {{($bits(dh_bs_t_ccd_s_int_wr)-2){1'b0}},2'b10});     // Max(dh_bs_t_ccd_s,2)

// Per Bank Group
generate
for (gen_bg=0; gen_bg<NUM_BG_PER_RANK; gen_bg=gen_bg+1) begin : gen_ccd_timer
    // -------------
    // tCCD timer
    // -------------
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            t_ccd_timer[gen_bg] <= {$bits(t_ccd_timer[gen_bg]){1'b0}};
        end // if: in reset
        else if(gs_ts_lrank_enable)
        begin
            // t_ccd timer implementation - use t_ccd for same bank group commands and t_ccd_s for different bank group
                  if (this_bg_rd[gen_bg] || this_bg_wr[gen_bg])
                    t_ccd_timer[gen_bg] <= {{($bits(t_ccd_timer[gen_bg])-$bits(dh_bs_t_ccd_int)){1'b0}},dh_bs_t_ccd_int} - {{($bits(t_ccd_timer[gen_bg])-2){1'b0}},2'b10};
                  else if (this_logical_rank_rd)
                    t_ccd_timer[gen_bg] <= ((bg_timing_mode) ? {{($bits(t_ccd_timer[gen_bg])-$bits(dh_bs_t_ccd_s_int_rd)){1'b0}}, dh_bs_t_ccd_s_int_rd} : dh_bs_t_ccd_int) - {{($bits(t_ccd_timer[gen_bg])-2){1'b0}},2'b10};
                  else if (this_logical_rank_wr)
                    t_ccd_timer[gen_bg] <= ((bg_timing_mode) ? {{($bits(t_ccd_timer[gen_bg])-$bits(dh_bs_t_ccd_s_int_wr)){1'b0}}, dh_bs_t_ccd_s_int_wr} : dh_bs_t_ccd_int) - {{($bits(t_ccd_timer[gen_bg])-2){1'b0}},2'b10};
                  else if (|t_ccd_timer[gen_bg])
                    t_ccd_timer[gen_bg] <= t_ccd_timer[gen_bg] - {{($bits(t_ccd_timer[gen_bg])-1){1'b0}},1'b1};
        end
    end

    assign gs_bs_blk_ccd_timer[gen_bg] = (|t_ccd_timer[gen_bg]) || this_physical_rank_rd || this_physical_rank_wr;

end
endgenerate

// CAS_B3 timing constraitns
   always_ff @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         block_cas_b3_timer <= {$bits(block_cas_b3_timer){1'b0}};
      end
      else if (this_physical_rank_wr) begin
         block_cas_b3_timer <= dh_bs_wr2rd_s + {{($bits(block_cas_b3_timer)-2){1'b0}},2'b10} - {{($bits(block_cas_b3_timer)-1){1'b0}},1'b1};
      end
      else if (block_cas_b3_timer != {$bits(block_cas_b3_timer){1'b0}}) begin
         block_cas_b3_timer <= block_cas_b3_timer - {{($bits(block_cas_b3_timer)-1){1'b0}},1'b1};
      end
   end

   // -------------
   // mrr2rd timer
   // -------------
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         t_mrr2rd_timer <= {$bits(t_mrr2rd_timer){1'b0}};
      end
      else begin
         if (any_mrr_this_rank) begin
            t_mrr2rd_timer <= reg_ddrc_mrr2rd - {{($bits(t_mrr2rd_timer)-1){1'b0}},1'b1};
         end
         else if (t_mrr2rd_timer != {$bits(t_mrr2rd_timer){1'b0}}) begin
            t_mrr2rd_timer <= t_mrr2rd_timer - {{($bits(t_mrr2rd_timer)-1){1'b0}},1'b1};
         end
      end
   end

   // -------------
   // mrr2wr timer
   // -------------
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         t_mrr2wr_timer <= {$bits(t_mrr2wr_timer){1'b0}};
      end
      else begin
         if (any_mrr_this_rank) begin
            t_mrr2wr_timer <= reg_ddrc_mrr2wr - {{($bits(t_mrr2wr_timer)-1){1'b0}},1'b1};
         end
         else if (t_mrr2wr_timer != {$bits(t_mrr2wr_timer){1'b0}}) begin
            t_mrr2wr_timer <= t_mrr2wr_timer - {{($bits(t_mrr2wr_timer)-1){1'b0}},1'b1};
         end
      end
   end

   // -------------
   // mrr2mrw timer
   // -------------
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         t_mrr2mrw_timer <= {$bits(t_mrr2mrw_timer){1'b0}};
      end
      else begin
         if (any_mrr_this_rank) begin
            t_mrr2mrw_timer <= reg_ddrc_mrr2mrw;
         end
         else if (t_mrr2mrw_timer != {$bits(t_mrr2mrw_timer){1'b0}}) begin
            t_mrr2mrw_timer <= t_mrr2mrw_timer - {{($bits(t_mrr2mrw_timer)-1){1'b0}},1'b1};
         end
      end
   end

   assign block_mrr2mrw = (|t_mrr2mrw_timer);


generate
for (gen_bg=0; gen_bg<NUM_BG_PER_RANK; gen_bg=gen_bg+1) begin : gen_wr2rd_timer
        // If the t_wr2rd_timer that started with dh_gs_wr2rd (tWTR_L) is counting down and if a new write happens to this rank,
        // but not to this bank group, then the value to be loaded is decide by whether the current timer value is larger
        // or dh_gs_wr2rd_s - that is the reason for the larger_wr2rd_value logic
        // +1 is added to the t_wr2rd_timer because the logic that loads this value into t_wr2rd_timer has a -2 in it,
        // where as we need to decrement by 1 only if the timer value is being used - hence do +1 to compensate for the -2 later
        assign larger_wr2rd_value[gen_bg]= ({{($bits(t_wr2rd_timer[gen_bg])-$bits(dh_bs_wr2rd_s)){1'b0}},dh_bs_wr2rd_s} > t_wr2rd_timer[gen_bg]) ? 
                                                           {{($bits(larger_wr2rd_value[gen_bg])-$bits(dh_bs_wr2rd_s)){1'b0}},dh_bs_wr2rd_s} : 
                                                           ({{($bits(larger_wr2rd_value[gen_bg])-$bits(t_wr2rd_timer[gen_bg])){1'b0}}, t_wr2rd_timer[gen_bg]} +
                                                                 {{($bits(larger_wr2rd_value[gen_bg])-1){1'b0}},1'b1});

    // -------------
    // wr2rd timer
    // -------------
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            t_wr2rd_timer[gen_bg]   <= {$bits(t_wr2rd_timer[gen_bg]){1'b0}};
        end // if: in reset
        else if(gs_ts_lrank_enable)
        begin
            // t_wr2rd timer implementation - use t_wr2rd for same bank group commands and t_wr2rd_s for different bankgroup
            // If the previous counter with dh_gs_wr2rd (tWTR_L) is counting down and if a new write happens to this rank,
            // but not to this bank group, then the value to be loaded is decide by whether the current timer value is larger
            // or dh_gs_wr2rd_s - that is the reason for the larger_wr2rd_value logic
            if (this_bg_wr[gen_bg]) begin
               t_wr2rd_timer[gen_bg] <= dh_bs_wr2rd - {{($bits(t_wr2rd_timer[gen_bg])-2){1'b0}},2'b10};
            end
            else if (this_physical_rank_wr) begin
               if (bg_timing_mode) begin
                  t_wr2rd_timer[gen_bg] <= larger_wr2rd_value[gen_bg] - {{($bits(t_wr2rd_timer[gen_bg])-2){1'b0}},2'b10};
               end
               else begin
                  t_wr2rd_timer[gen_bg] <= dh_bs_wr2rd - {{($bits(t_wr2rd_timer[gen_bg])-2){1'b0}},2'b10};
               end
            end
            else if (t_wr2rd_timer[gen_bg] != {$bits(t_wr2rd_timer[gen_bg]){1'b0}}) begin
               t_wr2rd_timer[gen_bg] <= t_wr2rd_timer[gen_bg] - {{($bits(t_wr2rd_timer[gen_bg])-1){1'b0}},1'b1};
            end
        end // else: not in reset
    end // always: synchronous process for timers

    assign gs_bs_blk_wr2rd_timer[gen_bg]    = (|t_wr2rd_timer[gen_bg]);


        // If the t_rd2wr_timer that started with dh_gs_rd2wr is counting down and if a new write happens to this rank,
        // but not to this bank group, then the value to be loaded is decide by whether the current timer value is larger
        // or reg_ddrc_rd2wr_s - that is the reason for the larger_rd2wr_value logic
        // +1 is added to the t_rd2wr_timer because the logic that loads this value into t_rd2wr_timer has a -2 in it,
        // where as we need to decrement by 1 only if the timer value is being used - hence do +1 to compensate for the -2 later
        assign larger_rd2wr_value[gen_bg]= (reg_ddrc_rd2wr_s > t_rd2wr_timer[gen_bg]) ? reg_ddrc_rd2wr_s : (t_rd2wr_timer[gen_bg]+{{($bits(t_rd2wr_timer[gen_bg])-1){1'b0}},1'b1});

    // -------------
    // rd2wr timer
    // -------------
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            t_rd2wr_timer[gen_bg]   <= {$bits(t_rd2wr_timer[gen_bg]){1'b0}};
        end // if: in reset
        else begin
            // t_rd2wr timer implementation - use t_rd2wr for same bank group commands and t_rd2wr_s for different bankgroup
            // If the previous counter with dh_gs_rd2wr (tWTR_L) is counting down and if a new write happens to this rank,
            // but not to this bank group, then the value to be loaded is decide by whether the current timer value is larger
            // or dh_gs_rd2wr_s - that is the reason for the larger_rd2wr_value logic
            if (this_bg_rd[gen_bg]) begin
               t_rd2wr_timer[gen_bg] <= dh_gs_rd2wr - {{($bits(t_rd2wr_timer[gen_bg])-2){1'b0}},2'b10};
            end
            else if (this_physical_rank_rd) begin
               if (reg_ddrc_lpddr5 & bg_timing_mode) begin
                  t_rd2wr_timer[gen_bg] <= larger_rd2wr_value[gen_bg] - {{($bits(t_rd2wr_timer[gen_bg])-2){1'b0}},2'b10};
               end else
               begin
                  t_rd2wr_timer[gen_bg] <= dh_gs_rd2wr - {{($bits(t_rd2wr_timer[gen_bg])-2){1'b0}},2'b10};
               end
            end
            else if (t_rd2wr_timer[gen_bg] != {$bits(t_rd2wr_timer[gen_bg]){1'b0}}) begin
               t_rd2wr_timer[gen_bg] <= t_rd2wr_timer[gen_bg] - {{($bits(t_rd2wr_timer[gen_bg])-1){1'b0}},1'b1};
            end
        end // else: not in reset
    end // always: synchronous process for timers

    assign gs_bs_blk_rd2wr_timer[gen_bg]    = (|t_rd2wr_timer[gen_bg]);

end
endgenerate

   assign any_mrr_this_rank = any_mrr
                              ;



`ifndef SYNTHESIS

`ifdef SNPS_ASSERT_ON
// disable coverage collection as this is a check in SVA only
// VCS coverage off


// caparity_retry_performed
// Once CA parity retry is performed, this is asserted to disable an assertion
reg caparity_retry_performed;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (!core_ddrc_rstn) caparity_retry_performed <= 1'b0;
end




generate
  if (UNUSED_FOR_REFPB == 0) begin : SVA_FOR_REFPB_GEN
    // -------------------------------------------------------
    //  Checkers for bank address of per-bank refresh
    // -------------------------------------------------------
    logic sync_refpb_bank;
    bit first_refpb_after_sync; // flag indicating that first REFpb command after synchronization event

    assign sync_refpb_bank = w_op_is_exit_selfref | load_mrw_reset_norm;

    always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn)              first_refpb_after_sync <= 1;
 if(gs_ts_lrank_enable) begin
        if (refresh_this_rank)            first_refpb_after_sync <= 0;
        else if (!refresh_timer_started)  first_refpb_after_sync <= 1;
        else if (sync_refpb_bank)         first_refpb_after_sync <= 1;
 end
    end

    // Check that in LPDDR4, there is no possible closed bank when REFpb to opened bank
    property p_lpddr4_no_closed_bank_when_spec_refpb_to_opened_bank;
      @(posedge co_yy_clk) disable iff (!core_ddrc_rstn || !gs_ts_lrank_enable || !(i_dh_gs_active_ranks && dh_gs_per_bank_refresh && dh_gs_lpddr4))
      rank_speculative_ref && !rank_refresh_required && ((~$past(os_gs_bank_closed) & (1<<gs_bs_refpb_bank)) != 0) && // REFpb bank is opened
      // ignore the following cases
      !$past(sync_refpb_bank) && // just after synchronization
      (gs_bs_refpb_bank != curr_refpb_bank_w) // just after REFpb bank updating
      |->
      ($past(os_gs_bank_closed & ref_idle_timeout & ~bank_ref_done_w & ~bank_no_lp4_refpb_sb) == 0); // there is no closed bank
    endproperty

    a_lpddr4_no_closed_bank_when_spec_refpb_to_opened_bank: assert property (p_lpddr4_no_closed_bank_when_spec_refpb_to_opened_bank)
      else $error("%m %t There is possible closed bank when LPDDR4 speculative per-bank refresh is requested to opened bank", $time);

    property p_lpddr4_no_closed_bank_when_crit_refpb_to_opened_bank;
      @(posedge co_yy_clk) disable iff (!core_ddrc_rstn || !gs_ts_lrank_enable || !(i_dh_gs_active_ranks && dh_gs_per_bank_refresh && dh_gs_lpddr4))
      rank_refresh_required && ((~$past(os_gs_bank_closed) & (1<<gs_bs_refpb_bank)) != 0) && // REFpb bank is opened
      // ignore the following cases
      !$past(sync_refpb_bank) && // just after synchronization
      (gs_bs_refpb_bank != curr_refpb_bank_w) // just after REFpb bank updating
      |->
      (($past(ref_idle_timeout) & (1<<gs_bs_refpb_bank)) != 0) ? // if REFpb bank is idle-expired
        ($past(os_gs_bank_closed & ref_idle_timeout & ~bank_ref_done_w & ~bank_no_lp4_refpb_sb) == 0) : // there is no closed & idle-expired bank
        ($past(os_gs_bank_closed & ~bank_ref_done_w & ~bank_no_lp4_refpb_sb) == 0); // there is no closed bank
    endproperty

    a_lpddr4_no_closed_bank_when_crit_refpb_to_opened_bank: assert property (p_lpddr4_no_closed_bank_when_crit_refpb_to_opened_bank)
      else $error("%m %t There is possible closed bank when LPDDR4 critical per-bank refresh is requested to opened bank", $time);

    // Check that in LPDDR4, there is no possible expired bank when critical REFpb to non-expired bank
    property p_lpddr4_no_exp_bank_when_refpb_to_noexp_bank;
      @(posedge co_yy_clk) disable iff (!core_ddrc_rstn || !gs_ts_lrank_enable || !(i_dh_gs_active_ranks && dh_gs_per_bank_refresh && dh_gs_lpddr4))
      //rank_refresh_required && ((~$past(ref_idle_timeout) & (1<<gs_bs_refpb_bank)) != 0) && // REFpb bank is non idle-expired
      rank_refresh_required && ((~$past(os_gs_bank_closed) & (1<<gs_bs_refpb_bank)) != 0) && // REFpb bank is not closed
      // ignore the following cases
      !$past(sync_refpb_bank) && // just after synchronization
      (gs_bs_refpb_bank != curr_refpb_bank_w) // just after REFpb bank updating
      |->
      //($past(ref_idle_timeout & ~bank_ref_done_w & ~bank_no_lp4_refpb_sb) == 0); // there is no idle-expired bank
      ($past(os_gs_bank_closed & ~bank_ref_done_w & ~bank_no_lp4_refpb_sb) == 0); // there is no closed bank
    endproperty

    a_lpddr4_no_exp_bank_when_refpb_to_noexp_bank: assert property (p_lpddr4_no_exp_bank_when_refpb_to_noexp_bank)
      else $error("%m %t There is possible expired bank when LPDDR4 critical per-bank refresh is requested to non-expired bank", $time);

    // Check that bank address of LPDDR4 REFpb is not same as previous one during tRFCpb cycles
    property p_lpddr4_not_same_refpb_bank_during_trfcpb;
      int bank, trfc_cnt;
      @(posedge co_yy_clk) disable iff (!core_ddrc_rstn || !gs_ts_lrank_enable || !(i_dh_gs_active_ranks && dh_gs_per_bank_refresh && dh_gs_lpddr4))
      (refresh_this_rank, bank=gs_bs_refpb_bank, trfc_cnt=dh_gs_t_rfc_min-1)
      |=> ((gs_bs_refpb_bank != bank) || rank_no_refresh_after_refresh) throughout ((trfc_cnt > 1), trfc_cnt--)[*1:$] ##1 (trfc_cnt == 1);
    endproperty : p_lpddr4_not_same_refpb_bank_during_trfcpb

    a_lpddr4_not_same_refpb_bank_during_trfcpb: assert property (p_lpddr4_not_same_refpb_bank_during_trfcpb)
      else $error("%m %t Unexpected bank address of LPDDR4 REFpb (gs_bs_refpb_bank), which is same as previous one during tRFCpb cycles", $time);

    // -------------------------------------------------------
  end : SVA_FOR_REFPB_GEN
endgenerate

covergroup cg_rank_lpddr4_refpb @(posedge co_yy_clk);
  option.per_instance = 1;

  // Observe bank order of LPDDR4 per-bank refresh
  // Since getting all transitions would not be realistic, get a state of bank_ref_done_w instead
  cp_refpb_bank_order: coverpoint(bank_ref_done_w) iff(core_ddrc_rstn && dh_gs_lpddr4 && dh_gs_per_bank_refresh)
  {
    option.auto_bin_max = 8;
  }

endgroup : cg_rank_lpddr4_refpb

cg_rank_lpddr4_refpb  cg_rank_lpddr4_refpb_inst = new();


// -------------------------------------------------------
//  Checkers for refresh_request_cnt[5:0]
// -------------------------------------------------------
// Check that decimal bits of refresh_request_cnt are used based on refresh mode
a_refresh_request_cnt_decimal_bits: assert property (
  @(posedge co_yy_clk) disable iff((!core_ddrc_rstn) || (!gs_ts_lrank_enable)) 
  $changed(refresh_request_cnt) && (gs_dh_operating_mode == 3'b001) |->
  ((dh_gs_per_bank_refresh == 1) || (refab_forced == 1)) ||
  (refresh_request_cnt[2:0] == 0)
);

// Check that refresh_request_cnt is less than or equal to w_ref_saturate_cnt
// When CA parity retry is performed, disable this register as CA parity retry logic is trying to issue extra refresh
// For per-bank refresh, it allows up to 72 as it adds +8 upon SRX
a_refresh_request_cnt_le_saturate_cnt: assert property (
  @(posedge co_yy_clk) disable iff((!core_ddrc_rstn) || (!gs_ts_lrank_enable) || caparity_retry_performed) 
  $changed(refresh_request_cnt) |->
  (refresh_request_cnt <= ((dh_gs_per_bank_refresh)? 72 : (refab_forced ? w_ref_saturate_cnt + 7 : w_ref_saturate_cnt)))

);

// Check that core_refresh_request_cnt is less than or equal to w_core_ref_saturate_cnt
a_core_refresh_request_cnt_le_saturate_cnt: assert property (
  @(posedge co_yy_clk) disable iff((!core_ddrc_rstn) || (!gs_ts_lrank_enable)) 
  $changed(core_refresh_request_cnt) |->
  (core_refresh_request_cnt <= w_core_ref_saturate_cnt
  )
);

property p_ref_timer_start_value_x32_no_overflow;
  @(posedge co_yy_clk) disable iff (~core_ddrc_rstn | !gs_ts_lrank_enable | ~i_dh_gs_active_ranks) i_ref_timer_start_value_x32[$bits(i_ref_timer_start_value_x32)-1:T_REFI_X1_X32_WIDTH] == {($bits(i_ref_timer_start_value_x32)-T_REFI_X1_X32_WIDTH){1'b0}};
endproperty

a_ref_timer_start_value_x32_no_overflow: assert property (p_ref_timer_start_value_x32_no_overflow)
  else $error("%m %t i_ref_timer_start_value_x32 overflow check register setting refresh_timerX_start_value_x32,refresh_timer_lr_offset_x32 \
  refresh_timerX_start_value_x32 + (Num 3DS stacks * refresh_timer_lr_offset_x32) must be less than 4096 ", $time);

for (genvar k=0; k<16; k++) begin

// check that non-zero w2trefi counters are not updated by refresh
property p_w2trefi_upd;
  @(posedge co_yy_clk) disable iff (~core_ddrc_rstn | !gs_ts_lrank_enable | ~i_dh_gs_active_ranks | dh_gs_per_bank_refresh) (gs_op_is_ref && (!gs_ref_cs_n[this_physical_rank]) && ref_cid_match && (k[3:0]==w2trefi_cnt_next_r[6:3]) && (w2trefi_cnt_next_r[2:0] == 3'd0))
   |-> w2trefi_cnt[k] == 0; 
endproperty

a_w2trefi_upd: assert property (p_w2trefi_upd)
  else $error("%m %t non-zero w2trefi counter %d updated by refresh", $time, k);
  
`ifdef VCS
// check w2trefi_cnt overflow/underflow
assert_never a_w2trefi_cnt_no_overflow (co_yy_clk, core_ddrc_rstn, (w2trefi_val_1d < w2trefi_val) && (w2trefi_cnt[k] > {$bits(w2trefi_cnt[k]){1'b0}}) && ((w2trefi_val - w2trefi_val_1d) > ({$bits(w2trefi_cnt[k]){1'b1}} - w2trefi_cnt[k])));
assert_never a_w2trefi_val_1d_w2trefi_cnt_underflow (co_yy_clk, core_ddrc_rstn, (w2trefi_val_1d > w2trefi_val) && (w2trefi_val_1d < w2trefi_cnt[k]));
`endif

end // for

// rrd_timer should not be decreased 2 or more
generate
    for (genvar idx=0; idx<BLK_ACT_TRRD_WDT; idx++) begin
        property p_rrd_timer_should_not_be_decreased_two_or_more;
            @(posedge co_yy_clk) disable iff((!core_ddrc_rstn) || (!gs_ts_lrank_enable)) 
              ((t_rrd_timer[idx] >= $past(t_rrd_timer[idx]) - {{($bits(t_rrd_timer[idx])-1){1'b0}},1'b1}) || $past(t_rrd_timer[idx])=={$bits(t_rrd_timer[idx]){1'b0}});
        endproperty

        a_rrd_timer_should_not_be_decreased_two_or_more : assert property (p_rrd_timer_should_not_be_decreased_two_or_more)
            else $error("[%t][%m] ERROR: RANK_CONSTRAINTS t_rrd_timer should not be decreased 2 or more", $time);
    end
endgenerate



//  max rank wr
// ==================================================  

// Check that refresh_request_cnt is not incremented during Self refresh mode, Deep Power Down mode or MPSM
// In Self refresh mode, it can be incremented while waiting for tXS/tXSDLL (tXSR)
reg         selfref_mode_flag;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (!core_ddrc_rstn) begin
    selfref_mode_flag <= 1'b0;
  end else if(gs_ts_lrank_enable)
  begin
    if (gs_op_is_enter_selfref)     selfref_mode_flag <= 1'b1;
    else if (w_op_is_exit_selfref)  selfref_mode_flag <= 1'b0;
  end
end

a_inc_refresh_request_cnt: assert property (
  @(posedge co_yy_clk) disable iff (!core_ddrc_rstn | !gs_ts_lrank_enable | ~i_dh_gs_active_ranks)
  (refresh_request_cnt > $past(refresh_request_cnt)) && $past(inc_refresh_cnt & ~refresh_update_pulse_2d)
    |-> (!gs_dh_operating_mode[2] || $rose(gs_dh_operating_mode[2])) && // not MPSM
        ((gs_dh_operating_mode != 3'b011) || $past(gs_op_is_enter_selfref) || !selfref_mode_flag) // not SELFREF
);



// Check the number of refreshes sent while dis_auto_refresh == 1
// The number of refreshes scheduled while dis_auto_refresh == 1 is the number of refreshes pending at the rising edge of dis_auto_refresh plus the number of core requests.
// The maximum number is the time window during which refreshes can be sent (core_refresh_ok=1) divided by t_rfc_min.
    
// the window during which refreshes can be sent while dis_auto_refresh == 1    
wire  core_refresh_ok;
assign core_refresh_ok =  w_dh_gs_dis_auto_refresh &&                           
                          ~dfi_phyupd_ack &&
                          ~dfi_ctrlupd_req && 
                          (gs_dh_operating_mode == 3'b001) && 
                          ((( dh_gs_lpddr4) && dh_gs_per_bank_refresh) ?
                          rank_next_ref_bank_closed : os_gs_rank_closed)
                          && (~zqcl_due_to_sr_exit_ext
                          )
                          && ~rank_nop_after_zqcs
                          && w2trefi_satisfied
                          && ~block_t_xs
                          && ~os_gs_no_2ck_cmds_after_pre
                          ;

reg core_refresh_ok_1d;
always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    core_refresh_ok_1d <= 1'b0;
  else
 if(gs_ts_lrank_enable) begin
    core_refresh_ok_1d <= core_refresh_ok;
 end
    
// count refreshes sent while dis_auto_refresh == 1    
reg   [6:0] refresh_cnt_during_dis_auto_refresh;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) 
  if (~core_ddrc_rstn)
    refresh_cnt_during_dis_auto_refresh <= 7'd0;
  else 
 if(gs_ts_lrank_enable)
  begin
    if ((gs_dh_operating_mode == 3'b000) || (gs_dh_operating_mode[2] == 1)) // reset if init/mpsm/deep-powerdown
      refresh_cnt_during_dis_auto_refresh <= 7'd0;
    else if (w_dh_gs_dis_auto_refresh && ~r_dh_gs_dis_auto_refresh) // reset at the rising edge of dis_auto_refresh
      refresh_cnt_during_dis_auto_refresh <= 7'd0;
    else if (w_dh_gs_dis_auto_refresh && refresh_this_rank && (refresh_cnt_during_dis_auto_refresh < 7'h7F))
      refresh_cnt_during_dis_auto_refresh <= refresh_cnt_during_dis_auto_refresh + 7'd1;     
  end

reg r_dh_gs_rank_refresh_1d;
always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_dh_gs_rank_refresh_1d <= 1'b0;
  else
 if(gs_ts_lrank_enable) begin
    r_dh_gs_rank_refresh_1d <= r_dh_gs_rank_refresh;      
 end
    
reg         increase_max_possible_refreshes;
int         max_possible_refreshes_during_dis_auto_refresh;
int         refreshes_requested_during_dis_auto_refresh; 

// the maximum number of refreshes that can be sent while dis_auto_refresh == 1    
always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    max_possible_refreshes_during_dis_auto_refresh <= 0;
  else
 if(gs_ts_lrank_enable)
  begin
    if ((gs_dh_operating_mode == 3'b000) || (gs_dh_operating_mode[2] == 1)) // reset if init/mpsm/deep-powerdown
      max_possible_refreshes_during_dis_auto_refresh <= 0;
    else if (~r_dh_gs_dis_auto_refresh) // reset if auto-refresh is enabled
      max_possible_refreshes_during_dis_auto_refresh <= 0;
    else if ((core_refresh_ok || (core_refresh_ok_1d && ~r_dh_gs_rank_refresh_1d)) && increase_max_possible_refreshes && (max_possible_refreshes_during_dis_auto_refresh < refreshes_requested_during_dis_auto_refresh))
      max_possible_refreshes_during_dis_auto_refresh <= max_possible_refreshes_during_dis_auto_refresh + 1; // increment if increase_max_possible_refreshes is asserted, refreshes can be sent, and more refreshes have been requested
  end

// signal which allows max_possible_refreshes to be incremented;
// it is asserted when tRFC timer has expired during dis_auto_refresh=1, and then refresh is scheduled
// it is de-asserted when max_possible_refreshes has been incremented, or at the falling edge of dis_auto_refresh
always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    increase_max_possible_refreshes <= 1'b0;   
  else
 if(gs_ts_lrank_enable)
  begin 
    if (refresh_this_rank && r_dh_gs_dis_auto_refresh)
      // permit the incrementation of max_possible_refreshes when tRFC timer has expired and then refresh is scheduled
      increase_max_possible_refreshes <= 1'b1;
    else if (((core_refresh_ok || (core_refresh_ok_1d && ~r_dh_gs_rank_refresh_1d)) && (max_possible_refreshes_during_dis_auto_refresh < refreshes_requested_during_dis_auto_refresh)) || (~w_dh_gs_dis_auto_refresh && r_dh_gs_dis_auto_refresh))
      increase_max_possible_refreshes <= 1'b0;               
  end

// the number of refreshes scheduled while dis_auto_refresh == 1              
always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    refreshes_requested_during_dis_auto_refresh <= 0;
  else
 if(gs_ts_lrank_enable)
  begin
  if (~i_dh_gs_active_ranks)
    refreshes_requested_during_dis_auto_refresh <= 0;
  else if ((gs_dh_operating_mode == 3'b000) || (gs_dh_operating_mode[2] == 1)) // reset if init/mpsm/deep-powerdown
    refreshes_requested_during_dis_auto_refresh <= 0;
  else if (~r_dh_gs_dis_auto_refresh && r_dh_gs_dis_auto_refresh_r) // reset if dis_auto_refresh is de-asserted
    refreshes_requested_during_dis_auto_refresh <= 0;
  else if (w_dh_gs_dis_auto_refresh && ~r_dh_gs_dis_auto_refresh) // number of refreshes expected at the rising edge of dis_auto_refresh
    if ((gs_dh_operating_mode == 3'b001 || gs_dh_operating_mode == 3'b010 || gs_dh_operating_mode == 3'b011) && (|refresh_request_cnt) && dh_gs_per_bank_refresh) begin
      refreshes_requested_during_dis_auto_refresh <= refresh_request_cnt[6:0];
    end else
    if ((gs_dh_operating_mode == 3'b001 || gs_dh_operating_mode == 3'b010 || gs_dh_operating_mode == 3'b011) && (|refresh_request_cnt[6:3])) begin
      refreshes_requested_during_dis_auto_refresh <= refresh_request_cnt[6:3];
    end else
    begin
      refreshes_requested_during_dis_auto_refresh <= 1;
    end
  else if (r_dh_gs_dis_auto_refresh && r_dh_gs_rank_refresh && 
          (refreshes_requested_during_dis_auto_refresh < 7'h7F) &&
          (refreshes_requested_during_dis_auto_refresh >= refresh_cnt_during_dis_auto_refresh ?
            ((refreshes_requested_during_dis_auto_refresh - refresh_cnt_during_dis_auto_refresh) <
              (
              dh_gs_per_bank_refresh ? p_ref8_saturate_cnt :
              p_ref1_saturate_cnt
              )
            ) : 1)
          ) // increase the number of expected refreshes if there is a core request
    refreshes_requested_during_dis_auto_refresh <= refreshes_requested_during_dis_auto_refresh + 1;
  end

wire [6:0] refreshes_expected_during_dis_auto_refresh;
assign refreshes_expected_during_dis_auto_refresh = (refreshes_requested_during_dis_auto_refresh <= max_possible_refreshes_during_dis_auto_refresh) ? 
                                                    refreshes_requested_during_dis_auto_refresh : 
                                                    max_possible_refreshes_during_dis_auto_refresh + ((increase_max_possible_refreshes && core_refresh_ok) ? 1 : 0);
// disable the assertion if there's a core request shortly before the falling edge of dis_auto_refresh                                                    
reg [5:0] dh_gs_rank_refresh_d;
always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    dh_gs_rank_refresh_d <= 6'd0;
  else
 if(gs_ts_lrank_enable)
  begin
    if (dh_gs_rank_refresh)
      dh_gs_rank_refresh_d <= 6'h10;
    else if (|dh_gs_rank_refresh_d) // & core_refresh_ok)
      dh_gs_rank_refresh_d <= dh_gs_rank_refresh_d - 6'd1;                                                                
  end

property p_refreshes_during_dis_auto_refresh;
  @(posedge co_yy_clk) disable iff (~core_ddrc_rstn | !gs_ts_lrank_enable | ~i_dh_gs_active_ranks) // Disable if this gs_rank_constraints is disabled
    (~w_dh_gs_dis_auto_refresh && r_dh_gs_dis_auto_refresh && ~(|dh_gs_rank_refresh_d) && (~refresh_this_rank)) |-> 
    ((refresh_cnt_during_dis_auto_refresh == refreshes_expected_during_dis_auto_refresh) || 
     ((refresh_cnt_during_dis_auto_refresh == (refreshes_expected_during_dis_auto_refresh - 1)) && (|refreshes_expected_during_dis_auto_refresh)) ||
     ((refresh_cnt_during_dis_auto_refresh == (refreshes_expected_during_dis_auto_refresh + 1)) && (~(&refreshes_expected_during_dis_auto_refresh))));
endproperty

a_refreshes_during_dis_auto_refresh: assert property (p_refreshes_during_dis_auto_refresh)
  else $error("%m @ %t: unexpected number of refreshes during dis_auto_refresh; expected: %d, occurred: %d", $time, refreshes_expected_during_dis_auto_refresh, refresh_cnt_during_dis_auto_refresh);

// VCS coverage on




// ==================================================  
//  max rank wr




//  max rank wr
// ==================================================  

localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

// refresh_timer overflow
assert_never #(0, 0, "refresh_timer overflow", CATEGORY) a_refresh_timer_overflow
  (co_yy_clk, core_ddrc_rstn, (refresh_timer_wider[$bits(refresh_timer_wider)-1]==1'b1));

// w2trefi_val overflow
assert_never #(0, 0, "w2trefi_val overflow", CATEGORY) a_w2trefi_val_overflow
  (co_yy_clk, core_ddrc_rstn, (w2trefi_val_wider[18]==1'b1));
  
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule  // gs_rank_constraints: track per-rank DDR constraints
