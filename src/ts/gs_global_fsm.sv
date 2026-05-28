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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_global_fsm.sv#3 $
// -------------------------------------------------------------------------
// Description:
//
// gs_global_fsm - Global Scheduler
// This block implements the finite state machine responsible for tracking the
// global state of the DDR1/2 DRAM.  States are:
//  * init sequence
//  * "normal" (read/write) state
//  * powerdown
//  * self-refresh
// This blocks also chooses read mode/write mode and implements all
// starvations-avoidance state machines and indicates when to prefer low
// priority reads accordingly.
// POWERDOWN EXIT SEQUENCE is as follows:
//  1) In POWERDOWN state.  End of powerdown marked by:
//      * clearing powerdown bit or new transaction coming into DDRC, AND
//      * we've been in powerdown for at least [2 x pad-powerdown-time]
//  3) In POWERDOWN_EX state.  Wait for tXP. 
//     The power_state_timer waits for dh_gs_t_xp cycles.
//  4) Back up and running in read or write mode (depending on prefer_wr) 
//------------------------------------------------------------------------------ 
// SELF-REFRESH EXIT SEQUENCE is as follows:
//  1) In SELFREF state.  End of self-refresh marked by:
//      * clearing self-refresh bit or new transaction registered by TE.
//  3) In SELFREF_EX state.  Wait for tXS in case of non DDR4 devices.
//     Wait for tXS_FAST in case of DDR4 devices.
//     The mode_exit_timer waits for dh_gs_t_xs_x32/dh_gs_t_xs_dll_x32
//     /dh_gs_t_xs_abort_x32/dh_gs_t_xs_fast_x32 pulses of the pulse_x32 
//     pulse in case of DDR4 SDRAMs, and for dh_gs_t_xsr 
//     clock cycles in case of LPDDR4 SDRAMs.
//  4) Back up and running in read or write mode (depending on prefer_wr) 
//
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_global_fsm 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS ----------------------------------
     parameter    CHANNEL_NUM         = 0
    ,parameter    RANK_BITS           = `MEMC_RANK_BITS
    ,parameter    NUM_TOTAL_BANKS     = `DDRCTL_DDRC_NUM_TOTAL_BANKS
    ,parameter    NUM_TOTAL_BSMS      = `UMCTL2_NUM_BSM

    ,parameter    BCM_VERIF_EN        = 1
    ,parameter    BCM_DDRC_N_SYNC     = 2

    ,parameter    NPORTS              = 1 // no. of ports (for cactive_in_ddrc width) gets overwritten by toplevel

    ,parameter    A_SYNC_TABLE        = 16'hffff

    ,parameter    NUM_RANKS           = 1 << RANK_BITS // max # of physical ranks supported
    ,parameter    NUM_LRANKS          = `DDRCTL_DDRC_NUM_LRANKS_TOTAL // max # of logical ranks supported

    ,parameter    CMD_DELAY_BITS      = `UMCTL2_CMD_DELAY_BITS

    ,parameter    FSM_STATE_WIDTH     = 5
    ,parameter    SELFREF_EN_WIDTH_INT = SELFREF_EN_WIDTH
    ,parameter    SELFREF_SW_WIDTH_INT = SELFREF_SW_WIDTH
    ,parameter    SELFREF_TYPE_WIDTH_INT = SELFREF_TYPE_WIDTH
    ,parameter    POWERDOWN_EN_WIDTH_INT = POWERDOWN_EN_WIDTH

  )
  (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                      co_yy_clk                           // clock
    ,input                                      core_ddrc_rstn                      // async falling-edge reset
    ,output     [NUM_RANKS-1:0]                 bsm_clk_en                          // Clock enable for bsm instances
    ,input      [BSM_CLK_ON_WIDTH-1:0]          bsm_clk_on                          // bsm_clk always on

    //// Register Configs ////
    ,input                                      dh_gs_prefer_write                  // prefer writes
    ,input      [6:0]                           dh_gs_rdwr_idle_gap                 // time to wait after reads are down
                                                                                    // before switching to writes
                                                                                    // (except when prefer_write=1,
                                                                                    //  when this will mean the opposite.)
    ,input                                      dh_gs_dis_dq                        // disable dq of commands out of controller
                                                                                    // when self-refresh is enabled and this signal is high
                                                                                    // the controller goes into self-refresh
    ,input      [POWERDOWN_EN_WIDTH_INT-1:0]        dh_gs_powerdown_en                  // powerdown enable
    ,input      [POWERDOWN_TO_X32_WIDTH-1:0]    dh_gs_powerdown_to_x32              // timeout period (clock cycles x 32) before powerdown
    ,input      [T_XP_WIDTH-1:0]                dh_gs_t_xp                          // tXP: duration of powerdown exit assertion/de-assertion
    ,input                                      dh_gs_dis_auto_ctrlupd_srx          // 1- disable ctrlupd issued by the controller at self-refresh exit
    ,input                                      dh_gs_ctrlupd_pre_srx               // ctrlupd behaviour at SRX (sent before or after SRX)

    ,input [SELFREF_SW_WIDTH_INT-1:0]               reg_ddrc_selfref_sw
    ,input                                      reg_ddrc_hw_lp_en
    ,input                                      reg_ddrc_hw_lp_exit_idle_en
    ,input      [SELFREF_TO_X32_WIDTH-1:0]      reg_ddrc_selfref_to_x32
    ,input      [HW_LP_IDLE_X32_WIDTH-1:0]      reg_ddrc_hw_lp_idle_x32
    ,input      [1:0]                           reg_ddrc_skip_dram_init
    ,output     [SELFREF_TYPE_WIDTH_INT-1:0]        ddrc_reg_selfref_type 
    ,input                                      ih_busy
    ,input                                      hif_cmd_valid
    ,output                                     gsfsm_sr_co_if_stall
    ,input      [DFI_T_CTRL_DELAY_WIDTH-1:0]    reg_ddrc_dfi_t_ctrl_delay
    ,input                                      phy_dfi_phyupd_req
    ,input                                      reg_ddrc_dfi_phyupd_en
    ,input                                      phy_dfi_phymstr_req
    ,input                                      reg_ddrc_dfi_phymstr_en
    ,input                                      cactive_in_ddrc_sync_or
    ,input      [NPORTS-1:0]                    cactive_in_ddrc_async
    ,input                                      csysreq_ddrc
    ,output                                     csysreq_ddrc_mux
    ,output                                     csysack_ddrc
    ,output                                     cactive_ddrc
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input                                      dh_gs_frequency_ratio               // 0 - 1:2 freq ratio, 1 - 1:4 freq ratio
//spyglass enable_block W240
    ,input      [SELFREF_EN_WIDTH_INT-1:0]      dh_gs_selfref_en                    // self-refresh enable
    ,input      [T_XSR_WIDTH-1:0]               dh_gs_t_xsr                         // SRX to commands (unit of 1 cycle)
    ,input      [T_CKESR_WIDTH-1:0]             reg_ddrc_t_ckesr
    ,input  [DFI_TLP_RESP_WIDTH-1:0]            reg_ddrc_dfi_tlp_resp
    ,input  [CMD_DELAY_BITS-1:0]                dfi_cmd_delay
    ,output reg                                 block_t_xs                          // block during tXS period
    ,output reg                                 block_t_xs_dll                      // block during tXSDLL period

    ,input      [READ_LATENCY_WIDTH-1:0]        dh_gs_read_latency                  // Read latency - used to ensure that PDE/SRE does not occur within RL of an MRR command
    ,input      [WRITE_LATENCY_WIDTH-1:0]       dh_gs_write_latency                 // Write latency
    ,input                                      dh_gs_lpddr4
    ,input                                      reg_ddrc_lpddr5
    ,input                                      dh_gs_stay_in_selfref
    ,input      [T_CMDCKE_WIDTH-1:0]            dh_gs_t_cmdcke
    ,input                                      reg_ddrc_dsm_en
    ,input      [T_PDN_WIDTH-1:0]               reg_ddrc_t_pdn
    ,input      [T_XSR_DSM_X1024_WIDTH-1:0]           reg_ddrc_t_xsr_dsm_x1024
    ,input      [T_CSH_WIDTH-1:0]               reg_ddrc_t_csh
    ,input                                      reg_ddrc_prefer_read
    //// High priority read queue related inputs
    ,input      [7:0]                           dh_gs_hpr_xact_run_length           // # of cycles the high priority queue is guaranteed to be serviced once queue is critical
    ,input      [15:0]                          dh_gs_hpr_max_starve                // # of cycles the high priority queue can be starved before going critical
    ,input                                      ih_gs_rdhigh_empty                  // no high priority reads pending
    ,input                                      ih_gs_rdlow_empty                   // no low priority reads pending

    //// Low priority read queue related inputs
    ,input      [7:0]                           dh_gs_lpr_xact_run_length           // # of cycles the low priority queue is guaranteed to be serviced once queue is critical
    ,input      [15:0]                          dh_gs_lpr_max_starve                // # of cycles the low priority queue can be starved before going critical
    ,input                                      gs_op_is_rd_hi                      // high priority read transaction
    ,input                                      gs_op_is_rd_lo                      // low priority read transaction
    ,input                                      gs_op_is_wr                         // write issued to DRAM
    //// Write queue related inputs
    ,input      [7:0]                           dh_gs_w_xact_run_length             // # of transactions to service when the write queue is critical
    ,input                                      refresh_required                    // refresh is required
    ,input                                      refresh_pending                     // refresh is pending (earlier than refresh_required_early,
                                                                                    // which only asserts when it's time to actually schedule)
                                                                                    // This signal also includes speculative refreshes
    ,input                                      refresh_required_early              // This is the unflopped version of rank_refresh_required

    ,input      [1:0]                           wu_gs_enable_wr                     // data_enable coming from WU module
                                                                                    // if any of these bits are 1, it indicates that a write operation is going on.
                                                                                    // This is used in gs_global_fsm in clock_stop logic.

    ,input      [NUM_LRANKS-1:0]                rank_selfref_wait_ref               // for SRX to SRE, need a REF  before SRE is allowed
                                                                                    // (The width is "NUM_LRANKS" but this sigal is only used as |rank_selfref_wait_ref
                                                                                    //  therefore width does not matter even if NUM_LRANKS > NUM_RANKS)
    ,input      [NUM_RANKS-1:0]                 zq_calib_short_required             // zq_calib_short command is required
    ,input      [NUM_RANKS-1:0]                 rank_nop_after_zqcs_gfsm            // nop time after zqcs

    ,input                                      gs_pi_op_is_load_mr_norm            // load_mr_norm command issued to DRAM
    ,input      [NUM_RANKS-1:0]                 rank_nop_after_load_mr_norm         // nop time after load_mr_norm
    ,input      [NUM_RANKS-1:0]                 load_mr_norm_required               // load mr required during normal operation

    ,input                                      hif_go2critical_lpr                 // go to critical lp read after critical_starve time
    ,input                                      hif_go2critical_hpr                 // go to critical hp read after critical_starve time
    ,input                                      hif_go2critical_wr                  // go to critical read after critical_starve time
    ,input                                      hif_go2critical_l1_wr
    ,input                                      hif_go2critical_l2_wr
    ,input                                      hif_go2critical_l1_lpr
    ,input                                      hif_go2critical_l2_lpr
    ,input                                      hif_go2critical_l1_hpr
    ,input                                      hif_go2critical_l2_hpr
    ,input      [15:0]                          dh_gs_w_max_starve                  // # of cycles the write queue can be starved before going critical
    ,input                                      ih_gs_xact_valid                    // transaction valid in input handler 

    ,input                                      gs_op_is_ref                        // refresh operation in this cycle

    //// Flush & Queue Valids from TE ////
    ,input                                      te_gs_wr_flush                      // TE requesting a write flush
    ,input                                      te_gs_rd_flush                      // TE requesting a read flush
    ,input                                      te_gs_rd_vld                        // 1 or more valid reads
    ,input                                      te_gs_wr_vld                        // 1 or more valid writes
    ,input                                      te_gs_rd_vld_ref_rdwr_switch        // 1 or more valid reads  wrt rank not being refreshed
    ,input                                      te_gs_wr_vld_ref_rdwr_switch        // 1 or more valid writes wrt rank not being refreshed
    //// OS indicates banks open per rank ////
    ,input      [NUM_LRANKS-1:0]                os_gs_rank_closed                   // '1' for each rank with all banks closed
                                                                                    // (The width is "NUM_LRANKS" but this sigal is only used as &os_gs_rank_closed
                                                                                    // therefore width does not matter even if NUM_LRANKS > NUM_RANKS)
    ,input      [`MEMC_NUM_RANKS-1:0]           os_gs_no_2ck_cmds_after_pre         // blocks 2-cycles commands after PRE or commands w/AP
    ,input                                      timer_pulse_x1024                   // pulse for timers every 1024 clocks

    //// Inputs from other GS blocks ////
    ,input      [NUM_LRANKS-1:0]                rank_nop_after_refresh              // block everything after refresh (rank)

    ,input                                      global_block_cke_change             // block a transition on CKE (to enforce tCKE)
    ,input                                      end_init_ddr                        // DDR initialization sequence complete
    ,input                                      timer_pulse_x32                     // timer pulse every 32 clocks
    ,input                                      ctrlupd_req                         // request for DFI controller update
    ,input                                      gs_pi_phyupd_pause_req              // request for PHY update

    //// Current State & Write Mode Indicators ////
    ,output                                     gs_os_wr_mode_early                 // indication to OS to do writes 
    ,output                                     gs_bs_wr_mode_early                 // indication to BSM to do writes 
    ,output                                     wr_mode_early                       // write mode indication, 1 cycle early
    ,output reg                                 gs_wr_mode                          // indication to do writes 
    ,output reg                                 wr_mode                             // next transaction should be a write
    ,output                                     close_pages                         // indication to scheduler to close all
                                                                                    // open pages in preperation for
                                                                                    // powerdown or self-refresh or zq calib or load_mr_norm
    ,output                                     gs_op_is_enter_powerdown            // issuing powerdown entry command
    ,output                                     gs_op_is_exit_powerdown             // exit powerdown mode
    ,output                                     gs_op_is_enter_selfref              // issuing self refresh entry command
    ,output                                     gs_op_is_exit_selfref               // exit self-refresh mode
    ,output reg                                 enter_powerdown                     // issuing powerdown entry command
    ,output reg                                 exit_powerdown                      // exit powerdown mode
    ,output reg                                 enter_selfref                       // issuing self refresh entry command
    ,output reg                                 exit_selfref                        // exit self-refresh mode
    ,output reg                                 exit_selfref_ready                  // ready to exit self-refresh mode
    ,output                                     normal_operating_mode               // in normal operating mode
    ,output                                     rdwr_operating_mode                 // read/write operating mode
    ,output                                     init_operating_mode                 // performing initialization sequence
    ,output                                     gs_dh_selfref_cam_not_empty
    ,output     [2:0]                           gs_dh_selfref_state
    ,output                                     sr_mrrw_en                          // MRR/MRW enable during Self refresh
    ,output                                     enter_selfref_related_state         // Enter to SR, SRPD and DSM
    ,output     [2:0]                           gs_dh_operating_mode                // current operating mode indicator
                                                                                    // to DCR handler:
                                                                                    //  000 = initialization
                                                                                    //  001 = normal mode
                                                                                    //  010 = powerdown mode
                                                                                    //  011 = self-refresh mode
                                                                                    //        maximum power saving mode
    ,output     [FSM_STATE_WIDTH-1:0]           gs_dh_global_fsm_state              // more detailed version of above for debug register readback

    //// Power Logic Control Signals ////
    ,output                                     gs_pi_pads_powerdown                // powerdown many pads for DDR powerdown mode 
    ,output                                     gs_pi_pads_selfref                  // powerdown more pads for DDR self-refresh mode 

    ,input                                      gs_pi_mrr
    ,input                                      gs_pi_mrr_ext
    ,output                                     gs_op_is_enter_sr_lpddr             // enter lpddr self-refresh mode
    ,output                                     gs_op_is_exit_sr_lpddr              // exit lpddr self-refresh mode
    ,output reg                                 gs_op_is_enter_dsm                  // enter deep sleep mode
    ,output reg                                 gs_op_is_exit_dsm                   // exit deep sleep mode

    ,output                                     gsfsm_sr_entry_req                  // enter self refresh request
    ,input                                      blk_pd_after_wra
    ,input      [NUM_TOTAL_BSMS-1:0]            bs_gs_stop_clk_ok                   // stop clock Ok signal from all the BSMs
    ,output                                     gs_pi_stop_clk_ok                   // stop the clock from PI in the following cycle
    ,output     [1:0]                           gs_pi_stop_clk_type
    ,input                                      clock_stop_exited
    ,output     [1:0]                           gs_dh_lpr_q_state
    ,output     [1:0]                           gs_dh_hpr_q_state
    ,output                                     reverse_priority                    // reverse priority to allow
                                                                                    // low priotiy reads to complete (for starvation prevention)
    ,output                                     gs_te_pri_level                     // 1=prefer low priority

    ,input                                      gs_op_is_rd
    ,input      [RD2WR_WIDTH-1:0]               dh_gs_rd2wr

    ,output     [1:0]                           gs_dh_w_q_state
    ,output     [7:0]                           powerdown_idle_timer                // idle time before powerdown (x32)

    // DFI LP I/F
    ,input                                      reg_ddrc_dfi_lp_en_pd
    ,input                                      reg_ddrc_dfi_lp_en_sr
    ,input                                      reg_ddrc_dfi_lp_en_dsm

    // from gs_global_fsm
    //,output                                     gsfsm_idle
    ,output                                     gfsm_dfilp_trig_pde
    ,output                                     gfsm_dfilp_trig_pdx
    ,output                                     gfsm_dfilp_trig_sre
    ,output                                     gfsm_dfilp_trig_srx
    ,output                                     gfsm_dfilp_trig_dsme
    ,output                                     gfsm_dfilp_trig_dsmx

    ,input                                      dfilp_pde_done
    ,input                                      dfilp_pde_aborted
    ,input                                      dfilp_pdx_aborted
    ,input                                      dfilp_pdx_done
    ,input                                      dfilp_sre_done
    ,input                                      dfilp_sre_aborted
    ,input                                      dfilp_srx_done
    ,input                                      dfilp_dsme_done
    ,input                                      dfilp_dsme_aborted
    ,input                                      dfilp_dsmx_done

    ,input                                      dfilp_active

    ,output                                     gs_pi_dfi_lp_changing

    ,input                                      gs_pi_data_pipeline_empty
    ,input                                      gs_pi_odt_pending
    ,output                                     gsfsm_dis_dq
    ,output                                     gs_dram_st_sr
    ,input                                      gs_phymstr_sre_req
    ,input                                      gs_phymstr_clr_lp_req
    ,input                                      dh_gs_dis_cam_drain_selfref
    ,input                                      dh_gs_lpddr4_sr_allowed

    ,output                                     gs_bs_sre_stall
    ,output                                     gs_bs_sre_hw_sw
    ,output                                     gsfsm_sr_exit_req


    ,input                                      reg_ddrc_opt_wrcam_fill_level
    ,input [3:0]                                reg_ddrc_delay_switch_write

    ,input   [NUM_TOTAL_BSMS-1:0]               te_bs_rd_page_hit               // banks with reads pending to open pages
    ,input   [NUM_TOTAL_BSMS-1:0]               te_bs_rd_valid                  // banks with reads pending
    ,input   [NUM_TOTAL_BSMS-1:0]               te_bs_wr_page_hit               // banks with writes pending to open pages
    ,input   [NUM_TOTAL_BSMS-1:0]               te_bs_wr_valid                  // banks with writes pending
    ,input   [NUM_TOTAL_BSMS-1:0]               te_rws_wr_col_bank               // banks with colliding writes pending
    ,input   [NUM_TOTAL_BSMS-1:0]               te_rws_rd_col_bank               // banks with colliding reads pending

    ,input   [NUM_TOTAL_BSMS-1:0]               bank_activated_early             // banks are in activated status in next cycle
    ,input                                      global_block_rd_early            // global status to block read. read cannot be issued until next cycle of it is de-assert
    ,input                                      wr_cam_up_highth                 // write CAM is above high threshold [WR_CAM_ENTRIES-1:WR_CAM_ENTRIES]
    ,input                                      wr_cam_up_lowth                  // write CAM is above low threshold
    ,input                                      wr_pghit_up_thresh
    ,input                                      rd_pghit_up_thresh
    ,output                                     delay_switch_write_state
    ,output  reg                                wr_more_crit
    ,output  reg                                rd_more_crit
    ,input                                      dqsosc_pd_forbidden
    ,input                                      dqsosc_required
    ,output                                     powerdown_operating_mode

  );

//------------------------------------ localparam -----------------------------------
// define global FSM states
// NOTE: Changing any encoding will require a corresponding change to the
//       next_state MUX in the code below 

    localparam GS_ST_RESET                = 5'b00000;
    localparam GS_ST_INIT_DDR             = 5'b00010;
    localparam GS_ST_NORMAL_RD            = 5'b00100;
    localparam GS_ST_NORMAL_WR            = 5'b00101;
    localparam GS_ST_POWERDOWN_ENT        = 5'b00110;    // powerdown pads then DDR
    localparam GS_ST_POWERDOWN_ENT_DFILP  = 5'b00001;    // DFI LP I/F entry PD
    localparam GS_ST_POWERDOWN            = 5'b01000;    // in powerdown
    localparam GS_ST_POWERDOWN_EX_DFILP   = 5'b01001;    // DFI LP I/F exit PD
    localparam GS_ST_POWERDOWN_EX1        = 5'b01010;    // power up pads
    localparam GS_ST_POWERDOWN_EX2        = 5'b01011;    // power up DDR
    localparam GS_ST_SELFREF_ENT          = 5'b00111;    // put DDR in self-refresh then power down pads
    localparam GS_ST_SELFREF_ENT2         = 5'b10101;    // Disable C/A Parity before SR if C/A parity had been enabled 
    localparam GS_ST_SELFREF_ENT_DFILP    = 5'b00011;    // DFI LP I/F entry SR
    localparam GS_ST_SELFREF              = 5'b01100;    // DDR is in self-refresh
    localparam GS_ST_SELFREF_EX_DFILP     = 5'b01101;    // DFI LP I/F exit SR
    localparam GS_ST_SELFREF_EX1          = 5'b01110;    // power up pads
    localparam GS_ST_SELFREF_EX2          = 5'b01111;    // bring DDR out of self-refresh

        localparam GS_ST_DSM_ENT_DFILP    = 5'b11000;    // DFI LP I/F entry DSM
        localparam GS_ST_DSM              = 5'b11001;    // DDR is in deep sleep mode
        localparam GS_ST_DSM_EX_DFILP     = 5'b11010;    // DFI LP I/F exit DSM

    localparam T_XDSM_XP_WIDTH = 4;
    localparam T_XDSM_XP       = 4'h9;

//------------------------------------ WIRES -----------------------------------

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
wire      lpddr_dev;
assign lpddr_dev = dh_gs_lpddr4 | reg_ddrc_lpddr5;
//spyglass enable_block W528


//// intermediate signals
wire            powerdown_idle_timeout; // powerdown idle timer expired
wire            wr_mode_next;           // write mode, before flopped
wire            any_rd;                 // indication of a pending read, whether it's in TE or thru bypass
reg   [4:0]     next_state;             // the next state for the fsm (assigned combinatorially)

wire gsfsm_sr_hw_lp_pd_cs_exit;


//// state transitions
wire            normal_rd_to_normal_wr;         // only valid in normal read mode
wire            normal_wr_to_normal_rd;         // only valid in normal write mode
wire            normal_rdwr_to_powerdown;       // only valid in normal read/write
wire            normal_rdwr_to_selfref;         // only valid in normal read/write
wire            powerdown_to_powerdown_ex;      // only valid in powerdown mode
wire            powerdown_ex_to_normal_rd;      // only valid in powerdown mode
wire            powerdown_ex_to_normal_wr;      // only valid in powerdown mode
wire            selfref_to_selfref_ex;          // only valid in self-refresh mode
wire            selfref_ex_to_normal_rd;        // only valid in self-refresh mode
wire            selfref_ex_to_normal_wr;        // only valid in self-refresh mode
wire            pdx_srx_ex1_to_ex2;             // only valid in powerdown or self refresh mode
wire            selfref_ex_cond;                // only valid in self-refresh mode
    wire            dsm_to_dsm_ex;
    wire            dsm_ex_dfilp_to_srpd;

wire            gsfsm_idle;

//// Outputs from starvation-avoidance FSMs
wire            prefer_rd;              // do reads before writes
wire            rdwr_idle_timeout;      // read-to-write idle timer expired

wire            rdhigh_critical;        // high priority is critical
wire            rdlow_critical;         // low priority is critical
wire            wr_critical;

wire            startup_in_self_ref;


    // For LPDDR4, Delay from valid command to CKE Low (tCMDCKE)
    // For LPDDR5, Delay from valid command to CKE Low (tCMDPD)
    wire t_cmdcke_satisfied;
    // For LPDDR4/LPDDR5, Valid command requirement after CKE High (tXP)
    wire t_xp_satisfied;

    reg  wait_dfilp_srx_done;   // wait SRX for ctrlupd and phyupd

wire            ctrlupd_req_int;                // ctrlupd_req | gs_pi_phyupd_pause_req; 

//--------------------------------- REGISTERS ----------------------------------
//// registered state indicators
reg             selfref_to_selfref_ex_rdy_pre_srx; // ready to exit selfref after ctrlupd has been issued (used in ctrlupd_pre_srx mode)
reg                                       sr_pdx_pending;             // SR PDX pending
reg                                       enter_sr_lpddr;             // enter selfref mode
reg                                       exit_sr_lpddr;              // exit selfref mode
reg  [$bits(dh_gs_read_latency)-1:0]      mrr2pdsr_count;             // Counter from MRR command to powerdown or self refresh
reg  [T_XSR_DSM_X1024_WIDTH-1:0]                xsr_dsm_timer_r;
reg  [T_CKESR_WIDTH-1:0]                  tsr_timer_r;
reg  [T_XDSM_XP_WIDTH-1:0]                txdsm_xp_timer_r;

    reg [4:0]  current_state;               // current state of global state machine
    reg [4:0]  current_state_prev;                  // flopped current_state signal
reg         close_pages_ff;

wire[$bits(dh_gs_t_xsr)-1:0] dh_gs_t_xs_w;
wire[$bits(dh_gs_t_xsr)-1:0] dh_gs_t_xs_dll_w;

//// timers
reg      [$bits(dh_gs_rdwr_idle_gap):0]  rdwr_idle_timer;        // idle time before switching to do writes
reg      [$bits(dh_gs_powerdown_to_x32):0]  powerdown_idle_timer_int;   // idle time before powerdown (x32)
assign powerdown_idle_timer = powerdown_idle_timer_int[$bits(powerdown_idle_timer)-1:0];
reg      [$bits(dh_gs_t_xp):0]  power_state_timer;      // down-counting cycle counter in each state
wire     [$bits(dh_gs_t_xs_w)-1:0]  mode_exit_timer;        // enforced delay before scheduling after Self-refresh or MPSM
reg      [$bits(mode_exit_timer):0] mode_exit_timer_wider;

reg             rd_flush_ff;            // break the timing path from TE;
reg             wr_flush_ff;            //  once cycle delay to flush is acceptable;
                                        //  flushes should be rare

//// registered outputs 
reg             r_enable_wr;            // WU is enabling a write in the CAM after
                                        //  receiving data for that write

reg           r_go2critical_lpr;           // go to critical lp read after critical_starve time
reg           r_go2critical_hpr;           // go to critical hp read after critical_starve time
reg           r_go2critical_wr;           // go to critical read after critical_starve time
reg           r_go2critical_l1_wr;
reg           r_go2critical_l2_wr;
reg           r_go2critical_l1_lpr;
reg           r_go2critical_l2_lpr;
reg           r_go2critical_l1_hpr;
reg           r_go2critical_l2_hpr;

reg           hpr_more_crit;
reg           wr_crit_l123;
reg           rd_crit_l123;




always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
        r_go2critical_wr  <= 1'b0;
        r_go2critical_lpr <= 1'b0;
        r_go2critical_hpr <= 1'b0;
        r_go2critical_l1_wr  <= 1'b0;
        r_go2critical_l2_wr  <= 1'b0;
        r_go2critical_l1_lpr <= 1'b0;
        r_go2critical_l2_lpr <= 1'b0;
        r_go2critical_l1_hpr <= 1'b0;
        r_go2critical_l2_hpr <= 1'b0;
  end
  else begin
        r_go2critical_wr  <= hif_go2critical_wr;
        r_go2critical_lpr <= hif_go2critical_lpr;
        r_go2critical_hpr <= hif_go2critical_hpr;
        r_go2critical_l1_wr  <= hif_go2critical_l1_wr ;
        r_go2critical_l2_wr  <= hif_go2critical_l2_wr ;
        r_go2critical_l1_lpr <= hif_go2critical_l1_lpr;
        r_go2critical_l2_lpr <= hif_go2critical_l2_lpr;
        r_go2critical_l1_hpr <= hif_go2critical_l1_hpr;
        r_go2critical_l2_hpr <= hif_go2critical_l2_hpr;
  end


// mask to disable switching between RD->WR 
// - switch from WR->RD just occurred and
// - RD->WR request was also high at time of switch
// similarly
// mask to disable switching between WR->RD 
// - switch from RD->WR just occurred and
// - WR->RD request was also high at time of switch 

reg normal_rd_to_normal_wr_mask;
reg normal_wr_to_normal_rd_mask;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
        normal_rd_to_normal_wr_mask <= 1'b0;
        normal_wr_to_normal_rd_mask <= 1'b0;
  end
  else begin
        if (current_state==GS_ST_NORMAL_WR && next_state==GS_ST_NORMAL_RD) begin
          normal_rd_to_normal_wr_mask <= normal_rd_to_normal_wr;
        end else begin
          normal_rd_to_normal_wr_mask <= 1'b0;
        end
        if (current_state==GS_ST_NORMAL_RD && next_state==GS_ST_NORMAL_WR) begin
          normal_wr_to_normal_rd_mask <= normal_wr_to_normal_rd;
        end else begin
          normal_wr_to_normal_rd_mask <= 1'b0;
        end
  end




wire any_rd_ref_rdwr_switch;

// indication of a pending read, whether it's in TE or thru bypass
//  (don't need to know if the bypass is actually taken)
assign          any_rd = te_gs_rd_vld;
assign          any_rd_ref_rdwr_switch = te_gs_rd_vld_ref_rdwr_switch;


//Created wire to avoid geneartion of condition in IF statement condition it self
wire rdwr_idle_timer_start;
assign rdwr_idle_timer_start = dh_gs_prefer_write ? (~te_gs_wr_vld & any_rd) : (~any_rd & te_gs_wr_vld) ;


// Start in self-refresh mode if skipping dram init, reg_ddrc_skip_dram_init[0] = 1'b1, and reg_ddrc_skip_dram_init[1] = 1'b1
assign startup_in_self_ref = &reg_ddrc_skip_dram_init;

//----------------------------- Assign Outputs ---------------------------------
// tell the scheduler to close all pages when the current state is
// GS_ST_POWERDOWN_ENT (4'b0110) or GS_ST_SELFREF_ENT (4'b0111)
// OR when load_mr_norm or zq calib short request is present
assign close_pages              = ((current_state == GS_ST_POWERDOWN_ENT) || (current_state == GS_ST_SELFREF_ENT)) ||
                                  (|load_mr_norm_required) 
                                  || (|zq_calib_short_required)        // zq_calib_short command is required
                                   ;

assign gs_pi_pads_powerdown     = (current_state == GS_ST_POWERDOWN);
assign gs_pi_pads_selfref       = (current_state == GS_ST_SELFREF);

// generate gs_dram_st_sr for gs_phymstr module
assign gs_dram_st_sr = 
                  // for LPDDR4 SR without PD is needed
                  (current_state==GS_ST_SELFREF_ENT2 ||
                   current_state==GS_ST_SELFREF_EX1) ? 1'b1 : 1'b0;

// can be decoded from upper bits of current_state, except in one of
// MEMC_GS_ST_POWERDOWN_ENT_DFILP
// MEMC_GS_ST_SELFREF_ENT_DFILP
    assign gs_dh_operating_mode = 
                                  (current_state==GS_ST_SELFREF_ENT2)        ? 3'b011 :
                                  (current_state==GS_ST_DSM_ENT_DFILP)       ? 3'b011 :
                                  (current_state==GS_ST_DSM)                 ? 3'b011 :
                                  (current_state==GS_ST_DSM_EX_DFILP)        ? 3'b011 :
                                  (current_state==GS_ST_NORMAL_RD)           ? 3'b001 :
                                  (current_state==GS_ST_NORMAL_WR)           ? 3'b001 :
                                  (current_state==GS_ST_POWERDOWN_ENT)       ? 3'b001 :
                                  (current_state==GS_ST_POWERDOWN_ENT_DFILP) ? 3'b010 :
                                  (current_state==GS_ST_POWERDOWN)           ? 3'b010 :
                                  (current_state==GS_ST_POWERDOWN_EX_DFILP)  ? 3'b010 :
                                  (current_state==GS_ST_POWERDOWN_EX1)       ? 3'b010 :
                                  (current_state==GS_ST_POWERDOWN_EX2)       ? 3'b010 :
                                  (current_state==GS_ST_SELFREF_ENT)         ? 3'b001 :
                                  //(current_state==GS_ST_SELFREF_ENT2)        ? 3'b011 :
                                  (current_state==GS_ST_SELFREF_ENT_DFILP)   ? 3'b011 :
                                  (current_state==GS_ST_SELFREF)             ? 3'b011 :
                                  (current_state==GS_ST_SELFREF_EX_DFILP)    ? 3'b011 :
                                  (current_state==GS_ST_SELFREF_EX1)         ? 3'b011 :
                                  (current_state==GS_ST_SELFREF_EX2)         ? 3'b011 :
                                  (current_state==GS_ST_INIT_DDR)            ? 3'b000 : 3'b000; // GS_ST_RESET
    assign gs_dh_selfref_state = (current_state==GS_ST_SELFREF_ENT2)      ? 3'b001 :
                                 (current_state==GS_ST_SELFREF_ENT_DFILP) ? 3'b010 :
                                 (current_state==GS_ST_SELFREF)           ? 3'b010 :
                                 (current_state==GS_ST_SELFREF_EX_DFILP)  ? 3'b010 :
                                 (current_state==GS_ST_SELFREF_EX1)       ? 3'b011 :
                                 (current_state==GS_ST_SELFREF_EX2)       ? 3'b011 :
                                 (current_state==GS_ST_DSM_ENT_DFILP)     ? 3'b100 :
                                 (current_state==GS_ST_DSM)               ? 3'b100 :
                                 (current_state==GS_ST_DSM_EX_DFILP)      ? 3'b100 : 3'b000;

// flopped gs_dh_operating_mode
reg [2:0] gs_dh_operating_mode_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
      gs_dh_operating_mode_r <= 
                                 3'b0;
   end else begin
      gs_dh_operating_mode_r <= gs_dh_operating_mode;
   end

   assign enter_selfref_related_state = ((gs_dh_operating_mode_r != 3'b011) && (gs_dh_operating_mode == 3'b011));

// register used to determine if CAM empty or not upon SR entry
// - set on rising edge of selfref operating_mode
// - reset upon SR exit
// this logic is not directly used for gs_dh_selfref_cam_not_empty, because gs_dh_selfref_cam_not_empty
// need to be combinational response
reg cam_not_empty_sr;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
      cam_not_empty_sr <= 1'b0;
   end else if ( (gs_dh_operating_mode == 3'b011) && (gs_dh_operating_mode_r != 3'b011) && ih_busy) begin
      cam_not_empty_sr <= 1'b1;
   end else if ((next_state == GS_ST_NORMAL_RD) || (next_state == GS_ST_NORMAL_WR)) begin
      cam_not_empty_sr <= 1'b0;
   end else begin
      cam_not_empty_sr <= cam_not_empty_sr;
   end

// collect status of CAMs when we enter SR, keep value constant while operating_mode is SR
assign gs_dh_selfref_cam_not_empty = 
         ((gs_dh_operating_mode == 3'b011) && (gs_dh_operating_mode_r != 3'b011)) ?
         ih_busy : cam_not_empty_sr;

assign gs_dh_global_fsm_state   = current_state;
//assign init_operating_mode    = (current_state[3:2] == 2'b00) & ~dh_gs_skip_init;
//assign normal_operating_mode  = (current_state[3:2] == 2'b01) | dh_gs_skip_init;
assign init_operating_mode      = (gs_dh_operating_mode[2:0] == 3'b000) ;
assign normal_operating_mode    = (((gs_dh_operating_mode[1:0] == 2'b01)
                                  && (!gs_dh_operating_mode[2]))
                                  );
assign powerdown_operating_mode = (gs_dh_operating_mode[2:0] == 3'b010);

// MRR/MRW enable during Self refresh for LPDDR4
assign  sr_mrrw_en = lpddr_dev && !ctrlupd_req_int &&
                     (((current_state == GS_ST_SELFREF_ENT2) && !enter_sr_lpddr) ||
                      ((current_state == GS_ST_SELFREF_EX1)  && t_xp_satisfied));

// commands are idle
assign gsfsm_idle = ((~ih_gs_xact_valid) & (~te_gs_rd_vld) & (~te_gs_wr_vld));  


// read/write operating mode (not entering powerdown or selfref). Only mode OK for DFI controller update.
assign rdwr_operating_mode      = (current_state == GS_ST_NORMAL_RD) || (current_state == GS_ST_NORMAL_WR);
//assign powerdown_operating_mode       = (current_state[3:2] == 2'b10);
//assign selfref_operating_mode = (current_state[3:2] == 2'b11);
assign rdwr_idle_timeout        = (rdwr_idle_timer == {($bits(rdwr_idle_timer)){1'b0}});
assign powerdown_idle_timeout   = (powerdown_idle_timer_int  == {($bits(powerdown_idle_timer_int)){1'b0}}) & gsfsm_idle;
assign gs_os_wr_mode_early      = wr_mode_next;
assign gs_bs_wr_mode_early      = wr_mode_next;
assign wr_mode_early            = wr_mode_next;
assign prefer_rd                = ~dh_gs_prefer_write;


//------------------------------
// Generation of the priority signal that is used in the selection n/w in TE to pick between HPR and LPR commands
// This is 1 when HPR has to be picked and 0 when LPR has to be picked
// The priority implemented in this logic is as below:
//    - any_vpr_timed_out                                             - Pick HPR 
//    - r_go2critical_hpr                                             - Pick HPR
//    - !r_go2critical_hpr AND r_go2critical_lpr                      - Pick LPR
//    - !r_go2critical_hpr AND !r_go2critical_lpr AND rdhigh_critical - Pick HPR
//    - !r_go2critical_hpr AND !r_go2critical_lpr AND rdlow_critical  - Pick LPR
//    - No signals are high                                           - Pick HPR
//------------------------------

wire  gs_te_pri_level_enh;
assign gs_te_pri_level_enh       = hpr_more_crit
                                  ;
assign gs_te_pri_level = gs_te_pri_level_enh;

// This is the inverse of the above signal, and is used in gs_next_xact
// When 1, commands from LoPri OS n/w is picked over HiPri OS n/w
assign reverse_priority         = ~gs_te_pri_level;



reg     refresh_pending_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
        refresh_pending_r <= 1'b0;
  else
        refresh_pending_r <= refresh_pending;


// stop the clock from PI when the DRAM is in
// powerdown, self refresh, or normal mode, but NOT transitioning between them
// Include ENT_DFILP and EX_DFILP states for Power Down/Self Refresh 
// AND the stop clock signal from all the BSMs are high
// AND the exit due to HW LP i/f is not high (~gsfsm_sr_hw_lp_pd_cs_exit)
// AND rank_nop_after_refresh is non-zero (this is to make sure that clock doesn't stop during tRFC(min) period)
// AND zq_calib_short request not pending and rank_nop for zqcs is non-zero
// AND load_mr_norm request not pending and rank_nop after load_mr_norm is non-zero
// AND r_enable_wr is non-zero (this ensures that clock is started before sending a write command
//     immediately after the data for that write is received; note that it
//     takes 2 cycles for the next table to update after wu_te_enable_wr,
//     hence we use the flopped version of wr_ge_enable_wr here)
// AND current_state in previous clock was not INIT_DDR. This is to cover the case when refresh
//     happens in the first clock after coming out of Init state
// AND (powerdown state and refresh is required)
// AND (normal_rd or normal_wr and refresh is requested)
// AND not of 'close_pages' ( closed pages is asserted when the s/m is in either
//     MEMC_GS_ST_POWERDOWN_ENT or MEMC_GS_ST_SELFREF_ENT states. all pages are closed before
//     the controller enters powerdown or self-refresh states and the clock should be running
//     during that time)
assign gs_pi_stop_clk_ok        = ((current_state == GS_ST_NORMAL_RD) |
                                   (current_state == GS_ST_NORMAL_WR) |
                                   (current_state == GS_ST_POWERDOWN) |
                                   (current_state == GS_ST_POWERDOWN_ENT_DFILP) |
                                   (current_state == GS_ST_POWERDOWN_EX_DFILP) |
                                   (current_state == GS_ST_DSM)      |
                                   (current_state == GS_ST_DSM_ENT_DFILP)      |
                                   (current_state == GS_ST_DSM_EX_DFILP) |

                                   ( (current_state == GS_ST_SELFREF) & (~(gs_phymstr_sre_req)) )   |
                                   (current_state == GS_ST_SELFREF_ENT_DFILP)   |
                                   (current_state == GS_ST_SELFREF_EX_DFILP)) 
                                  & ((&os_gs_rank_closed) | dh_gs_lpddr4)
                                  & (&bs_gs_stop_clk_ok)
                                  & (~(gsfsm_sr_hw_lp_pd_cs_exit & gs_pi_stop_clk_type==2'b11))
                                  & (~(|rank_nop_after_refresh))
                                  & (~(r_enable_wr & (~gsfsm_dis_dq)))
                                  & (~(|rank_nop_after_zqcs_gfsm))
                                  & (~(|zq_calib_short_required))
                                  & (~(|rank_nop_after_load_mr_norm))
                                  & (~(|load_mr_norm_required))
                                  & (~(current_state_prev == GS_ST_INIT_DDR))
                                  & (~((current_state == GS_ST_POWERDOWN) & refresh_required_early))
                                  & (~(((current_state==GS_ST_NORMAL_RD) | (current_state == GS_ST_NORMAL_WR)) 
                                        & (refresh_pending | refresh_pending_r)))
                                  & (~(close_pages | close_pages_ff));


assign gs_pi_stop_clk_type = ((current_state == GS_ST_SELFREF)   ||
                              (current_state == GS_ST_SELFREF_ENT_DFILP) ||
                              (current_state == GS_ST_SELFREF_EX_DFILP))   ? 2'b00 : 
                             ((current_state == GS_ST_POWERDOWN) ||
                              (current_state == GS_ST_POWERDOWN_ENT_DFILP) ||
                              (current_state == GS_ST_POWERDOWN_EX_DFILP)) ? 2'b01 :
                             ((current_state == GS_ST_DSM)      |
                              (current_state == GS_ST_DSM_ENT_DFILP)      |
                              (current_state == GS_ST_DSM_EX_DFILP))       ? 2'b00 :
                             2'b11; // clock stop

// DFI LP I/F - signals to dfilp module from gs_global_fsm

wire st_change = (current_state!=next_state) ? 1'b1 : 1'b0;

reg st_change_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   begin
      if (~core_ddrc_rstn) begin
         st_change_r <= 1'b0;
      end else begin
         st_change_r <= st_change;
      end
   end


assign                  gfsm_dfilp_trig_pde = (current_state==GS_ST_POWERDOWN_ENT_DFILP) ? st_change_r : 1'b0;
assign                  gfsm_dfilp_trig_pdx = (current_state==GS_ST_POWERDOWN_EX_DFILP)  ? st_change_r : 1'b0;
assign                  gfsm_dfilp_trig_sre = (current_state==GS_ST_SELFREF_ENT_DFILP)   ? st_change_r : 1'b0;
assign                  gfsm_dfilp_trig_srx = (current_state==GS_ST_SELFREF_EX_DFILP)    ? st_change_r : 1'b0;

assign                  gfsm_dfilp_trig_dsme = (current_state==GS_ST_DSM_ENT_DFILP)    ? st_change_r : 1'b0;
assign                  gfsm_dfilp_trig_dsmx = (current_state==GS_ST_DSM_EX_DFILP)     ? st_change_r : 1'b0;


//--------------------------- End Assign Outputs -------------------------------

//--------------------- Global FSM: Instance of gs_global_fsm_sr_hw_lp --------------------------

reg  gsfsm_sr_exit_req_r;
reg gs_phymstr_sre_req_r;

wire load_mr_norm_required_1bit_x = (|load_mr_norm_required);

// load_mr_norm_required_1bit used in gs_global_fsm_sr_hw_lp to
// drive it's i_asr_en (... ~load_mr_norm_required_1bit)
// But don't want asr_en==0 falsely for MRS performed in DDR4
// while in SELFREF_ENT2 state to trigger SRX later 
// (i_asr_en used in gs_global_fsm_sr_hw_lp state m/c),
// so masking it via ~gsfsm_cs_selfref_ent2
wire load_mr_norm_required_1bit = load_mr_norm_required_1bit_x
                                  ;
wire gsfsm_sr_dis_dq;
wire gsfsm_srpd_to_sr;

reg i_gsfsm_srpd_to_sr_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   begin
      if (~core_ddrc_rstn) begin
         i_gsfsm_srpd_to_sr_r <= 1'b0;
      end else begin
         i_gsfsm_srpd_to_sr_r <= gsfsm_srpd_to_sr;
      end
   end

wire gsfsm_sr_no_pd_to_srx;

reg  i_gsfsm_sr_no_pd_to_srx_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   begin
      if (~core_ddrc_rstn) begin
         i_gsfsm_sr_no_pd_to_srx_r <= 1'b0;
      end else begin
         i_gsfsm_sr_no_pd_to_srx_r <= gsfsm_sr_no_pd_to_srx;
      end
   end

wire gsfsm_sr_no_pd_to_srx_red = gsfsm_sr_no_pd_to_srx & ~i_gsfsm_sr_no_pd_to_srx_r;
   

//wire gsfsm_asr_en;
//--------------------- Global FSM: State Transitions --------------------------


wire gsfsm_state_selfref_ent_dfilp_int = (next_state==GS_ST_SELFREF_ENT_DFILP) || (current_state==GS_ST_SELFREF_ENT_DFILP);

reg gsfsm_state_selfref_ent_dfilp_int_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   begin
      if (~core_ddrc_rstn) begin
         gsfsm_state_selfref_ent_dfilp_int_r <= 1'b0;
      end else begin
         gsfsm_state_selfref_ent_dfilp_int_r <= gsfsm_state_selfref_ent_dfilp_int;
      end
   end

wire gsfsm_state_selfref_ent_dfilp = gsfsm_state_selfref_ent_dfilp_int | gsfsm_state_selfref_ent_dfilp_int_r;

wire stay_in_selfref = dh_gs_stay_in_selfref;

  gs_global_fsm_sr_hw_lp
   #(
     .BCM_VERIF_EN          (BCM_VERIF_EN)
    ,.BCM_DDRC_N_SYNC       (BCM_DDRC_N_SYNC)
    ,.NPORTS                (NPORTS) 
    ,.A_SYNC_TABLE          (A_SYNC_TABLE)
    ,.CMD_DELAY_BITS        (CMD_DELAY_BITS)
    ,.SELFREF_SW_WIDTH_INT  (SELFREF_SW_WIDTH_INT)
    ,.SELFREF_EN_WIDTH_INT  (SELFREF_EN_WIDTH_INT)
    ,.SELFREF_TYPE_WIDTH_INT (SELFREF_TYPE_WIDTH_INT)
    ,.NUM_RANKS             (NUM_RANKS)
  ) gs_global_fsm_sr_hw_lp (
    .co_yy_clk                    (co_yy_clk),
    .core_ddrc_rstn               (core_ddrc_rstn),
    .bsm_clk_en                   (bsm_clk_en    ),
    .bsm_clk_on                   (bsm_clk_on    ),
    .reg_ddrc_selfref_sw          (reg_ddrc_selfref_sw),
    .reg_ddrc_hw_lp_en            (reg_ddrc_hw_lp_en),
    .reg_ddrc_hw_lp_exit_idle_en  (reg_ddrc_hw_lp_exit_idle_en),
    .startup_in_self_ref          (startup_in_self_ref),
    .ddrc_reg_selfref_type        (ddrc_reg_selfref_type),
    .ih_busy                      (ih_busy),
    .hif_cmd_valid                (hif_cmd_valid),
    .reg_ddrc_dfi_t_ctrl_delay    (reg_ddrc_dfi_t_ctrl_delay),
    .phy_dfi_phyupd_req           (phy_dfi_phyupd_req),
    .reg_ddrc_dfi_phyupd_en       (reg_ddrc_dfi_phyupd_en),
    .phy_dfi_phymstr_req          (phy_dfi_phymstr_req),
    .reg_ddrc_dfi_phymstr_en      (reg_ddrc_dfi_phymstr_en),
    .cactive_in_ddrc_sync_or      (cactive_in_ddrc_sync_or),
    .cactive_in_ddrc_async        (cactive_in_ddrc_async),
    .csysreq_ddrc                 (csysreq_ddrc),
    .csysreq_ddrc_mux             (csysreq_ddrc_mux),

    .csysack_ddrc                 (csysack_ddrc),
    .cactive_ddrc                 (cactive_ddrc),

    .load_mr_norm_required_1bit   (load_mr_norm_required_1bit),
    .gsfsm_next_state             (next_state),
    .gsfsm_state_selfref_ent_dfilp(gsfsm_state_selfref_ent_dfilp),
    .reg_ddrc_dfi_tlp_resp        (reg_ddrc_dfi_tlp_resp),
    .dfi_cmd_delay                (dfi_cmd_delay),
    .lpddr_dev                    (lpddr_dev),
    .gsfsm_idle                   (gsfsm_idle),
    .dh_gs_selfref_en             (dh_gs_selfref_en),
    .reg_ddrc_selfref_to_x32      (reg_ddrc_selfref_to_x32),
    .reg_ddrc_hw_lp_idle_x32      (reg_ddrc_hw_lp_idle_x32),
    .timer_pulse_x32              (timer_pulse_x32),
    .gsfsm_sr_entry_req           (gsfsm_sr_entry_req),
    .gsfsm_sr_exit_req            (gsfsm_sr_exit_req),
    .gsfsm_sr_hw_lp_pd_cs_exit    (gsfsm_sr_hw_lp_pd_cs_exit),
    .gsfsm_sr_co_if_stall         (gsfsm_sr_co_if_stall),
    .gs_phymstr_sre_req           (gs_phymstr_sre_req),
    .dh_gs_dis_cam_drain_selfref  (dh_gs_dis_cam_drain_selfref),
    .gsfsm_sr_dis_dq              (gsfsm_sr_dis_dq),
    .gs_bs_sre_stall              (gs_bs_sre_stall),
    .gs_bs_sre_hw_sw              (gs_bs_sre_hw_sw)
    ,.gsfsm_srpd_to_sr             (gsfsm_srpd_to_sr)
    ,.gsfsm_sr_no_pd_to_srx        (gsfsm_sr_no_pd_to_srx)
    ,.dh_gs_lpddr4_sr_allowed      (dh_gs_lpddr4_sr_allowed)
  );

  
  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: gsfsm_sr_exit_req_r_PROC
    if (~core_ddrc_rstn) begin
      gsfsm_sr_exit_req_r <= 1'b0;
    end else begin
      gsfsm_sr_exit_req_r <= gsfsm_sr_exit_req;
    end
  end

  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: gs_phymstr_sre_req_r_PROC
    if (~core_ddrc_rstn) begin
      gs_phymstr_sre_req_r <= 1'b0;
    end else begin
      gs_phymstr_sre_req_r <= gs_phymstr_sre_req;
    end
  end
  
  // drive output for use in bsm/gs_next_xact
  assign gsfsm_dis_dq = dh_gs_dis_dq
                  | gsfsm_sr_dis_dq
                  ;
  
reg i_gsfsm_dis_dq_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_gsfsm_dis_dq_r_PROC
  if(!core_ddrc_rstn) begin
    i_gsfsm_dis_dq_r <= 1'b1;
  end else begin
    i_gsfsm_dis_dq_r <= gsfsm_dis_dq;
  end 
end

//--------------------- Global FSM: State Transitions --------------------------
// combine DFI controller update/PHY update requests into one internal signal
// used to stop state changes
assign ctrlupd_req_int = ctrlupd_req | gs_pi_phyupd_pause_req; 

/*assign gs_pi_dfi_lp_changing = ((current_state==GS_ST_POWERDOWN_ENT_DFILP) || (current_state==GS_ST_POWERDOWN_EX_DFILP) ||
                                (current_state==GS_ST_SELFREF_ENT_DFILP)    || (current_state==GS_ST_SELFREF_EX_DFILP)) ?
                                1'b1 : 1'b0;
*/
assign gs_pi_dfi_lp_changing = 1'b0;

// move to powerdown when enabled & idle timeoue and no powerdown, and
// it's allowed (not blocked by refresh or cke or zqcs requirement)
// refresh_pending - when a refresh request is pending, don't get into powerdown
// zq_calib_short_required - when zqcs is pending, don't get into powerdown
// ctrlupd_req_int - when DFI controller update/PHY update is pending, also don't go into powerdown
// In case of LPDDR4, wait for REFpb to be over before entering powerdown
//
// In case of DDR4, wait for one extra REF, same as a requirement to enter Self-Refresh.
// In other cases, such a condition is not specified, and FSM transits to Normal after a delay of tXS.
// So no condition related to Self-Refresh Exit is required.

assign normal_rdwr_to_powerdown = powerdown_idle_timeout &
                                  gs_pi_data_pipeline_empty &
                                  (~gsfsm_sr_hw_lp_pd_cs_exit) &
                                    (dh_gs_powerdown_en
                                    ) & (~gsfsm_sr_entry_req) &
                                    (~(reg_ddrc_dsm_en & reg_ddrc_lpddr5)) &
                                    (mrr2pdsr_count == {$bits(mrr2pdsr_count){1'b0}}) &
                                    (~(|rank_nop_after_zqcs_gfsm)) &
                                    (~(|zq_calib_short_required)) &
                                    (~dqsosc_pd_forbidden) &
                                    (~blk_pd_after_wra) &
                                    (~(|rank_nop_after_load_mr_norm)) &
                                    (~gs_pi_op_is_load_mr_norm) &
                                    (~(|load_mr_norm_required)) &
                                    (~ctrlupd_req_int) &
                                    (~global_block_cke_change) &
                                    (~(|rank_nop_after_refresh)) &
                                    (~gs_op_is_ref) &
                                    (~refresh_pending) &
                                    (~gs_phymstr_sre_req);


// move to self-refresh it's enabled and it's allowed
// when dis_dq is set and selfrefresh is enabled get into self-refresh
// LPDDR4 - when a regular refresh has not happened after a prev self-refresh state, don't get into self-refresh again
// DDR4 - zq_calib_short_required - when zqcs is pending, don't get into self-refresh
// Load Mode operation pending - don't get into self-refresh
// ctrlupd_req_int - when DFI controller update/PHY update is pending, also don't go into self-refresh
// refresh_pending - when a refresh request is pending don't get into self-refresh
assign normal_rdwr_to_selfref   = (gsfsm_sr_entry_req
                                   | (reg_ddrc_dsm_en & reg_ddrc_lpddr5)
                                  ) &
                                  gs_pi_data_pipeline_empty   &
                                  (~gs_pi_odt_pending)        &
                                  (~(|rank_selfref_wait_ref)) &
                                  (mrr2pdsr_count == {$bits(mrr2pdsr_count){1'b0}}) &
                                  (~(|rank_nop_after_zqcs_gfsm)) &
                                  (~(|zq_calib_short_required)) &
                                  (~dqsosc_pd_forbidden) &
                                  (~blk_pd_after_wra) &
                                  (~(|rank_nop_after_load_mr_norm)) &
                                  (~gs_pi_op_is_load_mr_norm) &
                                  (~(|load_mr_norm_required)) &
                                  (~ctrlupd_req_int) &
                                  (~global_block_cke_change) &
                                  (~(|rank_nop_after_refresh)) &
                                  (~gs_op_is_ref) &
                                  (~refresh_pending);

localparam DWD_CNT_BITS = 5;

wire normal_rd_to_normal_wr_enh;
wire normal_wr_to_normal_rd_enh;

wire delay_switch_write_timeout;
reg  [DWD_CNT_BITS-1:0] dwd_cnt;
wire dwd_cnt_start;

wire                      wr2rd_mid_mode_early;
wire [NUM_TOTAL_BSMS-1:0] te_bs_wr_page_hit_tm1;
wire [NUM_TOTAL_BSMS-1:0] te_bs_rd_page_hit_tm1;

wire [NUM_TOTAL_BSMS-1:0] rd_col_bank;
wire [NUM_TOTAL_BSMS-1:0] wr_col_bank;
wire [NUM_TOTAL_BSMS-1:0] rd_col_bank_page_hit;
wire [NUM_TOTAL_BSMS-1:0] wr_col_bank_page_hit;

wire any_wr_pghit;  //any page-hit based on timnig1 (ACT+tRCD)
wire any_rd_pghit;  //any page-hit based on timing1 (ACT+tRCD)
wire any_rd_pghit_tm0; //any page-hit based on timing0 (after ACT)


assign te_bs_wr_page_hit_tm1 = te_bs_wr_page_hit & bank_activated_early;
assign te_bs_rd_page_hit_tm1 = te_bs_rd_page_hit & bank_activated_early;

assign wr2rd_mid_mode_early = global_block_rd_early & ~rd_flush_ff & ~rd_crit_l123 & ~(rd_pghit_up_thresh & any_rd_pghit )  //add any_rd_pghit to meeting timing 1.
                              ;

assign any_wr_pghit = | (te_bs_wr_valid & te_bs_wr_page_hit_tm1);
assign any_rd_pghit = | (te_bs_rd_valid & te_bs_rd_page_hit_tm1);

assign any_rd_pghit_tm0 = | (te_bs_rd_valid & te_bs_rd_page_hit);



assign rd_col_bank = te_rws_rd_col_bank;
assign wr_col_bank = te_rws_wr_col_bank;
assign rd_col_bank_page_hit = rd_col_bank & te_bs_rd_valid & te_bs_rd_page_hit; 
assign wr_col_bank_page_hit = wr_col_bank & te_bs_wr_valid & te_bs_wr_page_hit; 

//Delay write drain counter
//the delay start in read mode, and no read page-hit, but write page-hit
assign dwd_cnt_start = ~wr_mode_next & (te_gs_wr_vld_ref_rdwr_switch & any_wr_pghit) & (any_rd_ref_rdwr_switch & ~any_rd_pghit);

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
     dwd_cnt <= {DWD_CNT_BITS{1'b0}};
   end
   else begin
      if(dwd_cnt_start) begin
         if(!delay_switch_write_timeout) begin
            dwd_cnt <= dwd_cnt + 1'b1;
         end
      end else begin
         dwd_cnt <= {DWD_CNT_BITS{1'b0}};
      end
   end


assign  delay_switch_write_timeout =  ~|reg_ddrc_delay_switch_write ? 1'b1: (dwd_cnt == {reg_ddrc_delay_switch_write, 1'b0});
assign  delay_switch_write_state = |dwd_cnt;


assign normal_rd_to_normal_wr_enh   =
        (~normal_rd_to_normal_wr_mask) && (// do not switch back to WR if just entered RD from WR on this cycle        
            (rd_flush_ff & |(rd_col_bank_page_hit)) ? 1'b0 :
            (wr_flush_ff & |(wr_col_bank_page_hit)) ? 1'b1 :
            (any_rd_ref_rdwr_switch & any_rd_pghit_tm0 & rd_more_crit) ? 1'b0 :
            (te_gs_wr_vld_ref_rdwr_switch & (any_wr_pghit | wr_cam_up_highth) & wr_more_crit) ? 1'b1 :
            (any_rd_ref_rdwr_switch & any_rd_pghit)  ? 1'b0 :
//            (te_gs_wr_vld_ref_rdwr_switch & any_wr_pghit & (delay_switch_write_timeout | ~any_rd_ref_rdwr_switch)) ? 1'b1 :
            (te_gs_wr_vld_ref_rdwr_switch & any_wr_pghit & (wr_pghit_up_thresh | delay_switch_write_timeout | ~any_rd_ref_rdwr_switch | wr_crit_l123)) ? 1'b1 :   //if any level write critical happened, don't need delay switch write or wr page-hti thresh.
            (any_rd_ref_rdwr_switch )  ? 1'b0 :
            (dh_gs_prefer_write || (te_gs_wr_vld_ref_rdwr_switch && rdwr_idle_timeout))
         );

assign normal_wr_to_normal_rd_enh   =
        (~normal_wr_to_normal_rd_mask) && ( // do not switch back to RD if just entered WR from RD on this cycle 
         ~wr2rd_mid_mode_early ) && (   //if it is in wr2rd turning around, keep to write mode during waiting tR2W (if rd is critical/collision/exvpr, this signal will be ignored)
            (wr_flush_ff & |(wr_col_bank_page_hit)) ? 1'b0 :
            (rd_flush_ff & |(rd_col_bank_page_hit)) ? 1'b1 :

            (te_gs_wr_vld_ref_rdwr_switch & (((any_wr_pghit | wr_cam_up_lowth) & wr_more_crit))) ? 1'b0:
            (te_gs_rd_vld_ref_rdwr_switch & any_rd_pghit_tm0 & rd_more_crit) ? 1'b1 :
            (te_gs_wr_vld_ref_rdwr_switch & any_wr_pghit) ? 1'b0 :
            (te_gs_rd_vld_ref_rdwr_switch & any_rd_pghit)  ? 1'b1 :
            (te_gs_wr_vld_ref_rdwr_switch) ? 1'b0 :
            (prefer_rd || (te_gs_rd_vld_ref_rdwr_switch && rdwr_idle_timeout))
        );


      assign normal_rd_to_normal_wr = normal_rd_to_normal_wr_enh;
      assign normal_wr_to_normal_rd = normal_wr_to_normal_rd_enh;


// exit powerdown when a new transaction arrives or register bit is cleared
// or if cactive_in_ddrc=1 and hw_lp_exit_idle_en=1 (gsfsm_sr_hw_lp_pd_cs_exit=1)
// or if to to do so by SR state M/c (gsfsm_sr_entry_req)
// or if told to exit via HW LP I/F causing transition to SR
// note: DFI controller updates not allowed in powerdown state
assign powerdown_to_powerdown_ex= (!gsfsm_idle |
                                   gsfsm_sr_hw_lp_pd_cs_exit |
                                   gsfsm_sr_entry_req |
                                   (|zq_calib_short_required) |
                                   (reg_ddrc_dsm_en & reg_ddrc_lpddr5) | 
                                   (dqsosc_required) | 
                                   (|load_mr_norm_required) |
                                   (~dh_gs_powerdown_en) |
                                   refresh_required |
                                   gs_phymstr_clr_lp_req
                                  ) &
                                  (~ctrlupd_req_int) &
                                  (~(|power_state_timer));
// exit self-refresh when a new transaction arrives or self-refresh bit is
// cleared or when load mr request arrives. don't exit for ZQCS.
// NOTE: When the force-self-refresh pin is set, dis_dq will be forced
//       high, so that this block will not see any read or writes from TE
//       (Also, this is why we can't check ih_gs_xact_valid to see new
//        incoming transactions - for force-self-refresh, this may toggle,
//        but we must ignore it here.) 
//                                   (|load_mr_norm_required)                          ) &&
// NOTE: when dis_auto_ctrlupd_srx=0 and ctrlupd_pre_srx=1 exit self-refresh 
//       must be delayed after ctrlupd_req is issued                           
//Also exit self refresh on DFI controller message request while dfilp is active. This is 
//to ensure PHY master request is triggered on time.
assign selfref_to_selfref_ex    = ((~dh_gs_dis_auto_ctrlupd_srx & dh_gs_ctrlupd_pre_srx) ?
                                    selfref_to_selfref_ex_rdy_pre_srx : (
                                    // transition SR-PD -> SR when we have a dfi_phymstr_req and this transition is allowed
                                    (lpddr_dev & gsfsm_srpd_to_sr) |
                                    gsfsm_sr_exit_req))
                                     & (~((global_block_cke_change | enter_selfref) & lpddr_dev))
                                     & (~reg_ddrc_lpddr5 | ~(|txdsm_xp_timer_r))
                                     & (~ctrlupd_req_int);                        
                                  
assign powerdown_ex_to_normal_rd= ~dh_gs_prefer_write & (~(|power_state_timer));
assign powerdown_ex_to_normal_wr=  dh_gs_prefer_write & (~(|power_state_timer));
// For fast self-refresh exit,
// tXS/tXSDLL determines whether FSM will transit from SRX to NORMAL_RD or NORMAL_WR
//   To NORMAL_RD:
//     - In DLL-off mode, the FSM can transit according to prefer_write after the fastest tXS elapses.
//     - In DLL-on mode, the FSM can transit after tXSDLL elapses.
//       prefer_write is for LPDDR4, which has only one kind of delay.
//   To NORMAL_WR:
//     - In DLL-off mode, the FSM can transit according to prefer_write after the fastest tXS elapses.
//     - In DLL-on mode, the FSM can transit regardless of prefer_write after the fastest tXS elapses.
assign selfref_ex_to_normal_rd  = ~dh_gs_prefer_write & (~block_t_xs_dll);
assign selfref_ex_to_normal_wr  = ~block_t_xs;

// Powerdown    : MEMC_GS_ST_POWERDOWN_EX1 to MEMC_GS_ST_POWERDOWN_EX2 
// Self refresh : MEMC_GS_ST_SELFREF_EX1   to MEMC_GS_ST_SELFREF_EX2
assign pdx_srx_ex1_to_ex2 = (~(|power_state_timer) & (~global_block_cke_change) & (~ctrlupd_req_int) & clock_stop_exited
                            );

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation.

// Conditions to exit selfref
// MEMC_GS_ST_SELFREF_EX1  -> MEMC_GS_ST_SELFREF_EX2
// MEMC_GS_ST_SELFREF_ENT2 -> MEMC_GS_ST_SELFREF_EX2 (lpddr4)
assign selfref_ex_cond = (pdx_srx_ex1_to_ex2
                          & ((~(|xsr_dsm_timer_r)) | dh_gs_lpddr4)
                          & (~(|tsr_timer_r))
                          & ((~lpddr_dev) |
                             ((~exit_selfref) &
                              (~stay_in_selfref) &
                              (~gs_phymstr_sre_req) &
                              t_xp_satisfied &
                              (gs_pi_data_pipeline_empty) &
                              (~gs_pi_op_is_load_mr_norm) &
                              (~(|load_mr_norm_required)) &
                              (~(|rank_nop_after_load_mr_norm)) &
                              (~(|rank_nop_after_zqcs_gfsm)) &
                              (~(|zq_calib_short_required))
                              )
                             )
                         );
//spyglass enable_block W528


always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    mrr2pdsr_count <= {$bits(mrr2pdsr_count){1'b0}};
  end
  else begin
      if (gs_pi_mrr || gs_pi_mrr_ext) begin
        if (lpddr_dev) begin
          mrr2pdsr_count <= {{($bits(mrr2pdsr_count)-$bits(dh_gs_read_latency)){1'b0}}, dh_gs_read_latency}
                // For LPDDR4, MRR is always BL16, which corresponds to 4 (1:2 freq ratio)/2 (1:4 freq ratio) cycles of controller clock 
                // and change the start point of measure regarding timing parameter
                +({{($bits(mrr2pdsr_count)-3){1'b0}},3'b110} >> dh_gs_frequency_ratio) ;
        end
    end else if (mrr2pdsr_count > {$bits(mrr2pdsr_count){1'b0}})
        mrr2pdsr_count <= mrr2pdsr_count - {{($bits(mrr2pdsr_count)-1){1'b0}},1'b1};
  end



   reg  [T_PDN_WIDTH-1:0] tpdn_timer;
   // tPDN timer
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         tpdn_timer <= {T_PDN_WIDTH{1'b0}};
      end
      else if (gs_op_is_enter_dsm) begin
         tpdn_timer <= reg_ddrc_t_pdn;
      end
      else if (|tpdn_timer) begin
         tpdn_timer <= tpdn_timer - {{($bits(tpdn_timer)-1){1'b0}},1'b1};
      end
   end

   // tCSH + tXDSM_XP timer
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         txdsm_xp_timer_r <= {T_XDSM_XP_WIDTH{1'b0}};
      end
      else if (gs_op_is_enter_dsm) begin
         txdsm_xp_timer_r <= {{T_XDSM_XP_WIDTH-T_CSH_WIDTH{1'b0}}, reg_ddrc_t_csh} + T_XDSM_XP;
      end
      else if ((current_state == GS_ST_SELFREF) & (|txdsm_xp_timer_r)) begin
         txdsm_xp_timer_r <= txdsm_xp_timer_r - {{($bits(txdsm_xp_timer_r)-1){1'b0}},1'b1};
      end
   end

    reg     r_dfilp_dsmx_done;
    // latch dfilp_dsmx_done
    // wait transition from DSM_EX_DFILP to DSM_EX until ctrlupd_req_int = 0
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
            r_dfilp_dsmx_done <= 1'b0;
        else begin
            if (dfilp_dsmx_done)
                r_dfilp_dsmx_done <= 1'b1;
            else if (~ctrlupd_req_int)
                r_dfilp_dsmx_done <= 1'b0;
        end
    end

    assign dsm_to_dsm_ex        = (~reg_ddrc_dsm_en & reg_ddrc_lpddr5 & (~global_block_cke_change) & (~ctrlupd_req_int) & (~(|tpdn_timer)));
    assign dsm_ex_dfilp_to_srpd = r_dfilp_dsmx_done & (~ctrlupd_req_int);


    wire bypass_rd;  // Bypass RD Command
    assign bypass_rd    = 1'b0;

    
    // MR comand that is an MRR
    wire i_mrr_cmd = gs_pi_op_is_load_mr_norm & (gs_pi_mrr || gs_pi_mrr_ext); 

    // For LPDDR4, check read-to-powerdown times.
    // Read to powerdown is defined as RL + tDQSCKmax/tCK + BL/2 + 1.
    // But tRTW = RL + tDQSCKmax/tCK + BL/2 + 1 -WL
    // Therefore, Read to Powerdown = tRTW + WL
    // Also checks MRR to PD (as well as RD to PD)
    //
    reg [7:0]   rd2pd_count;
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
        if (~core_ddrc_rstn)
            rd2pd_count <= 8'b0;
        else begin
            if ((gs_op_is_rd || bypass_rd || i_mrr_cmd) && lpddr_dev)
                rd2pd_count <= {{($bits(rd2pd_count)-$bits(dh_gs_rd2wr)){1'b0}}, dh_gs_rd2wr} + {{($bits(rd2pd_count)-$bits(dh_gs_write_latency)){1'b0}}, dh_gs_write_latency};
            else if (rd2pd_count != 8'b0)
                rd2pd_count <= rd2pd_count - 8'h01;
        end

    wire t_rd2pd_satisfied = !(|rd2pd_count);


    reg [$bits(dh_gs_t_xp)-1:0]   sr_cke_count;
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
        if (~core_ddrc_rstn)
            sr_cke_count <= {$bits(sr_cke_count){1'b0}};
        else begin
            if (current_state == GS_ST_SELFREF_ENT)
                sr_cke_count <= {{($bits(sr_cke_count)-$bits(dh_gs_t_cmdcke)){1'b0}}, dh_gs_t_cmdcke} + {{($bits(sr_cke_count)-1){1'b0}},1'b1};          // +1 for SRE command length
            else if (current_state == GS_ST_SELFREF_ENT2) begin
                if (~(gs_pi_data_pipeline_empty & (~gs_pi_op_is_load_mr_norm) & (~(|load_mr_norm_required)) & (~(|rank_nop_after_load_mr_norm)) 
                                                         & (~(|rank_nop_after_zqcs_gfsm)) & (~(|zq_calib_short_required)))
                )
                    sr_cke_count <= {{($bits(sr_cke_count)-$bits(dh_gs_t_cmdcke)){1'b0}}, dh_gs_t_cmdcke};
                else if (sr_cke_count != {$bits(sr_cke_count){1'b0}})
                    sr_cke_count <= sr_cke_count - {{($bits(sr_cke_count)-1){1'b0}},1'b1};
            end
            else if ((current_state == GS_ST_SELFREF) || (current_state == GS_ST_SELFREF_EX_DFILP))begin
              if(reg_ddrc_lpddr5)begin  
                sr_cke_count <= dh_gs_t_xp + {{($bits(sr_cke_count)-$bits(reg_ddrc_t_csh)){1'b0}}, reg_ddrc_t_csh};
              end else begin    
                sr_cke_count <= dh_gs_t_xp;
              end    
            end
            else if ((current_state == GS_ST_SELFREF_EX1) && (~sr_pdx_pending)) begin
                if (sr_cke_count != {$bits(sr_cke_count){1'b0}})
                    sr_cke_count <= sr_cke_count - {{($bits(sr_cke_count)-1){1'b0}},1'b1};
            end
        end

    assign t_cmdcke_satisfied  = (sr_cke_count == {$bits(sr_cke_count){1'b0}});
    assign t_xp_satisfied      = (sr_cke_count == {$bits(sr_cke_count){1'b0}});

    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
            wait_dfilp_srx_done <= 1'b0;
        else if (!ctrlupd_req_int)
            wait_dfilp_srx_done <= 1'b0;
        else if (dfilp_srx_done)
            wait_dfilp_srx_done <= 1'b1;
    end

//--------------------- Global FSM: Assign Next State --------------------------
always @(*)

    begin


    casez (current_state [4:0])
        GS_ST_INIT_DDR :
            next_state = end_init_ddr ? (dh_gs_prefer_write ? GS_ST_NORMAL_WR :
                                                              GS_ST_NORMAL_RD) :
                                        GS_ST_INIT_DDR;
        GS_ST_NORMAL_RD :
            next_state = (normal_rd_to_normal_wr) ? GS_ST_NORMAL_WR : //TODO may impact on some assertion, need to check
                         normal_rdwr_to_powerdown ? GS_ST_POWERDOWN_ENT :
                         normal_rdwr_to_selfref   ? GS_ST_SELFREF_ENT  :
                                                    GS_ST_NORMAL_RD ;
        GS_ST_NORMAL_WR :
            next_state = (normal_wr_to_normal_rd) ? GS_ST_NORMAL_RD : //TODO may impact on some assertion, need to check
                         normal_rdwr_to_powerdown ? GS_ST_POWERDOWN_ENT :
                         normal_rdwr_to_selfref   ? GS_ST_SELFREF_ENT :
                                                    GS_ST_NORMAL_WR ;
        GS_ST_POWERDOWN_ENT :
            // continue to powerdown when all open rows are closed;
            // return to normal read/write if read, write, zq_calib, ctrlupd_req_int or refresh calls for it
            next_state = ((dh_gs_powerdown_en
                          ) &
                          gs_pi_data_pipeline_empty
                          & gsfsm_idle
                          & ~refresh_pending
                          & (~gs_pi_op_is_load_mr_norm)
                          & (~(|load_mr_norm_required))
                          & (~ctrlupd_req_int)
                          & (~gs_phymstr_sre_req)
                          & (~(|zq_calib_short_required))
                          & (~dqsosc_pd_forbidden)
                          & (~blk_pd_after_wra)
                         ) ? (
                               (
                                // In LPDDR4, need to block PDE after precharging is done because of 2/4-cycles commands
                                !(|os_gs_no_2ck_cmds_after_pre) &&
                                (&os_gs_rank_closed) &&
                                t_rd2pd_satisfied &&
                                clock_stop_exited
                               ) ?
                                   (
                                    ((reg_ddrc_dfi_lp_en_pd
                                      & ~gs_phymstr_sre_req
                                      & ~dfilp_pde_aborted)       ? GS_ST_POWERDOWN_ENT_DFILP :
                                                                    GS_ST_POWERDOWN
                                    )) :
                                   GS_ST_POWERDOWN_ENT ) :
                             (dh_gs_prefer_write ? GS_ST_NORMAL_WR :
                                                   GS_ST_NORMAL_RD ) ;
        GS_ST_POWERDOWN_ENT_DFILP :
            next_state = (dfilp_pde_done | dfilp_pde_aborted)  ? GS_ST_POWERDOWN :
                                                                 GS_ST_POWERDOWN_ENT_DFILP;
        GS_ST_POWERDOWN :
            next_state = powerdown_to_powerdown_ex ? ((dfilp_active &
                                                       ~dfilp_pdx_aborted &
                                                       ~dfilp_pdx_done) ? GS_ST_POWERDOWN_EX_DFILP :
                                                                          GS_ST_POWERDOWN_EX1) :
                                                     GS_ST_POWERDOWN ;
        GS_ST_POWERDOWN_EX_DFILP :
            next_state = (dfilp_pdx_done) ? GS_ST_POWERDOWN_EX1 :
                                            GS_ST_POWERDOWN_EX_DFILP ;
        GS_ST_POWERDOWN_EX1 : // waiting for pads to power up
            next_state = pdx_srx_ex1_to_ex2 ? GS_ST_POWERDOWN_EX2 :
                                              GS_ST_POWERDOWN_EX1 ;
        GS_ST_POWERDOWN_EX2 : // waiting for tXSNR
            next_state = powerdown_ex_to_normal_rd ? GS_ST_NORMAL_RD :
                         powerdown_ex_to_normal_wr ? GS_ST_NORMAL_WR :
                                                     GS_ST_POWERDOWN_EX2 ;
        GS_ST_SELFREF_ENT :
            // continue to self refresh when all open rows are closed;
            // return to normal read/write if read, write, zq_calib, ctrlupd_req_int or refresh calls for it
            // or if dh_gs_selfref_en goes low
            // or if hif_refresh_req is asserted
            next_state = 
                         ((gsfsm_sr_entry_req
                           | (reg_ddrc_dsm_en & reg_ddrc_lpddr5)
                          )&
                          (gsfsm_idle | i_gsfsm_dis_dq_r) &
                          gs_pi_data_pipeline_empty
                          & (~gs_pi_odt_pending)
                          & (~refresh_pending)
                          & (~gs_pi_op_is_load_mr_norm)
                          & (~(|load_mr_norm_required))
                          & (~ctrlupd_req_int)
                          & (~(|zq_calib_short_required)) 
                          & (~dqsosc_pd_forbidden)
                         ) ?
                             (((&os_gs_rank_closed) &&
                          // In LPDDR4, need to block SRE after precharging is done because of 2/4-cycles commands
                               (!(|os_gs_no_2ck_cmds_after_pre)) &&
                               t_rd2pd_satisfied &&
                               clock_stop_exited
                              ) ?
                                  dh_gs_lpddr4              ? GS_ST_SELFREF_ENT2 :
                                  gs_phymstr_sre_req        ? GS_ST_SELFREF_ENT2 :
                                  reg_ddrc_dsm_en           ?
                                                              (reg_ddrc_dfi_lp_en_dsm ? GS_ST_DSM_ENT_DFILP :
                                                                                        GS_ST_DSM ) :
                                  stay_in_selfref           ? GS_ST_SELFREF_ENT2 :
                                  ((reg_ddrc_dfi_lp_en_sr
                                   & ~gs_phymstr_sre_req)   ? GS_ST_SELFREF_ENT_DFILP :
                                                              GS_ST_SELFREF
                                  ) :
                                  GS_ST_SELFREF_ENT 
                             ) :
                             (dh_gs_prefer_write ? GS_ST_NORMAL_WR :
                                                   GS_ST_NORMAL_RD ) ;
        GS_ST_SELFREF_ENT2 :
            next_state = 
                         // if SR was caused by dfi_phymstr_req, exit directly, without going through SR-PD
                         (lpddr_dev & gsfsm_sr_no_pd_to_srx) ? ((selfref_ex_cond) ? GS_ST_SELFREF_EX2 :
                                                                                    GS_ST_SELFREF_ENT2
                                                               ) :
                         (((~ctrlupd_req_int) &
                           (~gs_pi_op_is_load_mr_norm) &
                           (~(|rank_nop_after_load_mr_norm)) &
                           ((~(|load_mr_norm_required))
                           ) &
                           (
                            (lpddr_dev &
                             (~stay_in_selfref) &
                             (~gs_phymstr_sre_req) &
                             (~gs_phymstr_sre_req_r) &
                             t_cmdcke_satisfied &
                             (~(|rank_nop_after_zqcs_gfsm)) 
                             & ((~(|zq_calib_short_required))
                               )
                            )
                           )
                          ) ? ((reg_ddrc_dfi_lp_en_sr &
                                ~gs_phymstr_sre_req)  ? GS_ST_SELFREF_ENT_DFILP :
                                                        GS_ST_SELFREF) :
                              GS_ST_SELFREF_ENT2);

        GS_ST_SELFREF_ENT_DFILP :
            next_state = (dfilp_sre_done
                          | dfilp_sre_aborted
                         ) ? GS_ST_SELFREF :
                             GS_ST_SELFREF_ENT_DFILP;
        GS_ST_SELFREF :
            next_state = (selfref_to_selfref_ex ? ((dfilp_active) ? GS_ST_SELFREF_EX_DFILP :
                                                                    GS_ST_SELFREF_EX1) :
                                                  GS_ST_SELFREF) ;
        GS_ST_SELFREF_EX_DFILP :
            next_state = ((dfilp_srx_done
                           | ~dfilp_active
                           | wait_dfilp_srx_done)
                          & (~ctrlupd_req_int))
                            ? GS_ST_SELFREF_EX1 :
                              GS_ST_SELFREF_EX_DFILP ;
        GS_ST_SELFREF_EX1 :   // waiting for pads to power up
            next_state = 
                        (gsfsm_srpd_to_sr &
                         (~gs_phymstr_sre_req) &
                         (~gs_phymstr_sre_req_r)) ? GS_ST_SELFREF_ENT2 :
                        ((selfref_ex_cond)        ? GS_ST_SELFREF_EX2 :
                                                    GS_ST_SELFREF_EX1) ;
        GS_ST_SELFREF_EX2 : // waiting for tXSNR
            next_state = selfref_ex_to_normal_rd   ? GS_ST_NORMAL_RD :
                         selfref_ex_to_normal_wr   ? GS_ST_NORMAL_WR :
                                                     GS_ST_SELFREF_EX2 ;


        GS_ST_DSM_ENT_DFILP :
            next_state = (dfilp_dsme_done | dfilp_dsme_aborted) ? GS_ST_DSM :
                                                                  GS_ST_DSM_ENT_DFILP;
        GS_ST_DSM :
            next_state = dsm_to_dsm_ex       ? ((dfilp_active) ? GS_ST_DSM_EX_DFILP :
                                                                 GS_ST_SELFREF) :
                                               GS_ST_DSM ;
        GS_ST_DSM_EX_DFILP :
            next_state = dsm_ex_dfilp_to_srpd ? GS_ST_SELFREF :
                                                GS_ST_DSM_EX_DFILP ;


         // move MEMC_GS_ST_RESET to default to improve coverage and remove
         // setting of unused states
        //5'b00000 :  // GS_ST_RESET
        default :   
             next_state = startup_in_self_ref ? GS_ST_SELFREF :
                                                GS_ST_INIT_DDR;

    endcase
  end


//------------------- Global FSM: End Next State Assignment --------------------

assign wr_mode_next = (next_state == GS_ST_NORMAL_WR);

//----------------------------- Resetable Flops --------------------------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    rd_flush_ff                 <= 1'b0;
    wr_flush_ff                 <= 1'b0;
    wr_mode                     <= 1'b0;        // write mode is in the critical
    gs_wr_mode                  <= 1'b0;        //  for each destination
    rdwr_idle_timer             <= {($bits(rdwr_idle_timer)){1'b0}};       // re-assign to dh_gs_rdwr_idle_gap after reset
    powerdown_idle_timer_int    <= {($bits(powerdown_idle_timer_int)){1'b0}};       // re-assign to dh_gs_powerdown_to_x32 after reset
    current_state               <= GS_ST_RESET;
    current_state_prev          <= GS_ST_RESET;
    close_pages_ff              <= 1'b0;
    exit_powerdown              <= 1'b0;
    enter_selfref               <= 1'b0;
    enter_powerdown             <= 1'b0;
    exit_selfref                <= 1'b0;
    exit_selfref_ready          <= 1'b0;
    selfref_to_selfref_ex_rdy_pre_srx <= 1'b0;
    sr_pdx_pending              <= 1'b0;
    enter_sr_lpddr              <= 1'b0;
    exit_sr_lpddr               <= 1'b0;
    gs_op_is_enter_dsm          <= 1'b0;
    gs_op_is_exit_dsm           <= 1'b0;
    r_enable_wr                 <= 1'b0;
  end
  else begin
    rd_flush_ff                 <= te_gs_rd_flush;
    wr_flush_ff                 <= te_gs_wr_flush;
    wr_mode                     <= wr_mode_next;// write mode is in the critical
    gs_wr_mode                  <= wr_mode_next;//  for each destination

    ////
    // Timers
    ////

    // Idle timers: read-to-write idle time & idle time before powering down
    if (((current_state != GS_ST_NORMAL_RD) && (current_state != GS_ST_NORMAL_WR) &&
         (~(current_state == GS_ST_POWERDOWN_ENT && gsfsm_idle))) ||
        (!gsfsm_idle) ||
        (gsfsm_sr_hw_lp_pd_cs_exit) ) 
      // reset timer if we're not in normal running mode, 
      // or transactions are pending
      // or if cactive_in_ddrc=1 and hw_lp_exit_idle_en=1 (gsfsm_sr_hw_lp_pd_cs_exit=1) 
      powerdown_idle_timer_int      <= {{($bits(powerdown_idle_timer_int)-$bits(dh_gs_powerdown_to_x32)){1'b0}}, dh_gs_powerdown_to_x32};
    else
      if (timer_pulse_x32 && powerdown_idle_timer_int != {$bits(powerdown_idle_timer_int){1'b0}})
        powerdown_idle_timer_int    <= (powerdown_idle_timer_int - {{($bits(powerdown_idle_timer_int)-1){1'b0}},1'b1});

    // if there's a write pending and no read, count down the timer; otherwise reset
    //  (unless prefer_write is set; then count down when there's a read and no writes) 
    if(rdwr_idle_timer_start && rdwr_idle_timer != {$bits(rdwr_idle_timer){1'b0}}) 
      rdwr_idle_timer           <= rdwr_idle_timer - {{($bits(rdwr_idle_timer)-1){1'b0}},1'b1};
    else
      rdwr_idle_timer           <= {{($bits(rdwr_idle_timer)-$bits(dh_gs_rdwr_idle_gap)){1'b0}}, dh_gs_rdwr_idle_gap};

    // miscellaneous status flops: first clock after reset, current state
    current_state               <= next_state;
    current_state_prev          <= current_state;

    close_pages_ff              <= close_pages;
    exit_powerdown              <= (current_state == GS_ST_POWERDOWN_EX1) &&
                                   (next_state    == GS_ST_POWERDOWN_EX2);
    enter_powerdown             <= ((current_state != GS_ST_POWERDOWN) &&
                                    (current_state != GS_ST_POWERDOWN_ENT_DFILP)  &&
                                    (next_state    == GS_ST_POWERDOWN)) ||
                                   ((current_state != GS_ST_POWERDOWN_ENT_DFILP) &&
                                    (next_state    == GS_ST_POWERDOWN_ENT_DFILP))
                                    ;
    enter_selfref               <= ((current_state != GS_ST_SELFREF)  &&
                                    (current_state != GS_ST_SELFREF_ENT_DFILP)  &&
                                    (current_state != GS_ST_RESET)  &&
                                    (current_state != GS_ST_DSM)  &&
                                    (current_state != GS_ST_DSM_EX_DFILP)  &&
                                    (next_state    == GS_ST_SELFREF)) ||
                                   ((current_state != GS_ST_SELFREF_ENT_DFILP) &&
                                    (next_state    == GS_ST_SELFREF_ENT_DFILP))
                                    ;
    exit_selfref                <= 
                                    lpddr_dev ? ((current_state == GS_ST_SELFREF_EX1) &&
                                                 (pdx_srx_ex1_to_ex2 && sr_pdx_pending)) :
                                                ((current_state == GS_ST_SELFREF_EX1) &&
                                                 (next_state    == GS_ST_SELFREF_EX2))  ;
    // Controller is ready to exit selfref on rising edge of gsfsm_sr_exit_req, if dis_auto_ctrlupd_srx = 0 and ctrlupd_pre_srx = 1
    exit_selfref_ready          <= (~dh_gs_dis_auto_ctrlupd_srx & 
                                     dh_gs_ctrlupd_pre_srx & 
                                     (current_state != GS_ST_SELFREF_EX1) &
                                       // SR exit trigger - exclude situation when SR-PD was already exited due to PHY Master request
                                     ( ((gsfsm_sr_exit_req & ~gsfsm_sr_exit_req_r & ~i_gsfsm_srpd_to_sr_r) |
                                       // SR-PD is exited due to PHY Master request
                                        (gsfsm_srpd_to_sr & ~i_gsfsm_srpd_to_sr_r))
                                       & ~gsfsm_sr_no_pd_to_srx)
                                    ) ? 1'b1 : 1'b0;
    // selfref to selfref_ex transition is ready between pulse of exit_selfref_ready and falling edge of gsfsm_sr_exit_req
    if (exit_selfref_ready)
       selfref_to_selfref_ex_rdy_pre_srx <= 1'b1;
    else if ( (~gsfsm_sr_exit_req & gsfsm_sr_exit_req_r)
               || (~gsfsm_srpd_to_sr  & i_gsfsm_srpd_to_sr_r)
            )
       selfref_to_selfref_ex_rdy_pre_srx <= 1'b0;
    sr_pdx_pending              <= ( current_state == GS_ST_SELFREF)          ? 1'b1 :
                                   ((current_state == GS_ST_SELFREF_EX1) && 
                                    (pdx_srx_ex1_to_ex2 && sr_pdx_pending))         ? 1'b0 : sr_pdx_pending;
    enter_sr_lpddr              <= lpddr_dev && (current_state == GS_ST_SELFREF_ENT) &&
                                                (next_state    == GS_ST_SELFREF_ENT2); 
    exit_sr_lpddr               <= lpddr_dev && (((current_state == GS_ST_SELFREF_EX1) &&
                                                  (next_state    == GS_ST_SELFREF_EX2))
                                                     // exit SR wihout PD
                                                 || ((current_state == GS_ST_SELFREF_ENT2) &&
                                                     (next_state    == GS_ST_SELFREF_EX2 )));
    gs_op_is_enter_dsm          <= reg_ddrc_lpddr5 && (((current_state != GS_ST_DSM) &&
                                                        (current_state != GS_ST_DSM_ENT_DFILP)  &&
                                                        (next_state    == GS_ST_DSM)) ||
                                                       ((current_state != GS_ST_DSM_ENT_DFILP) &&
                                                        (next_state    == GS_ST_DSM_ENT_DFILP)));
    gs_op_is_exit_dsm           <= reg_ddrc_lpddr5 && (((current_state == GS_ST_DSM) ||
                                                        (current_state == GS_ST_DSM_EX_DFILP))  &&
                                                       (next_state    == GS_ST_SELFREF));
    r_enable_wr                 <= |wu_gs_enable_wr;

  end // else: resetable flops not in reset

  assign gs_op_is_exit_powerdown  = exit_powerdown;
  assign gs_op_is_enter_powerdown = enter_powerdown;
  assign gs_op_is_enter_selfref   = enter_selfref;
  assign gs_op_is_exit_selfref    = exit_selfref;

    assign gs_op_is_enter_sr_lpddr = enter_sr_lpddr;
    assign gs_op_is_exit_sr_lpddr  = exit_sr_lpddr;


//--------------------------- End Resetable Flops ------------------------------

//--------------------------- Non-Resetable Flops ------------------------------

// -----------------------------------------------------------------------------
// - Mode exit timer (increment counter)
// This is used to enforce tXS and tXSDLL
// (in case of DDR4, tXS_ABORT and tXS_FAST as well) after Self-refresh.
// Additionally, in case of DDR4, to enforce tXMPDLL after MPSM.
// -----------------------------------------------------------------------------

assign dh_gs_t_xs_w = //dh_gs_t_xs_w chooses between t_xsr and t_xs_x32 depending on the connected memory type
                           {{($bits(dh_gs_t_xs_w)-$bits(dh_gs_t_xsr)){1'b0}}, dh_gs_t_xsr}; 

assign dh_gs_t_xs_dll_w = //dh_gs_t_xs_dll_w chooses between t_xsr (t_xs_dll does not exist because dll is not used for LPDDR4) and t_xs_dll_x32 depending on the connected memory type                   
                               {{($bits(dh_gs_t_xs_w)-$bits(dh_gs_t_xsr)){1'b0}}, dh_gs_t_xsr};
                          
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (!core_ddrc_rstn) begin
        mode_exit_timer_wider <= {($bits(mode_exit_timer_wider)){1'b0}};
    end else if ((current_state == GS_ST_SELFREF)
        || gsfsm_sr_no_pd_to_srx_red
    ) begin
        mode_exit_timer_wider <= {($bits(mode_exit_timer_wider)){1'b0}};
    end else if (block_t_xs
    ) begin
        mode_exit_timer_wider <= mode_exit_timer_wider[$bits(mode_exit_timer)-1:0] + //if we have connected a LPDDR4 we are using t_xsr, therefore the mode_exit_timer needs to be incremented on each clock cycle
                                              ((lpddr_dev) ? {{($bits(mode_exit_timer_wider)-1){1'b0}},1'b1} :
                                                             {{($bits(mode_exit_timer_wider)-$bits(timer_pulse_x32)){1'b0}}, timer_pulse_x32}
                                            )
                                            ;
    end else if (block_t_xs_dll
    ) begin
        mode_exit_timer_wider <= mode_exit_timer_wider[$bits(mode_exit_timer)-1:0] + //if we have connected aLPDDR4 we are using t_xsr, therefore the mode_exit_timer needs to be incremented on each clock cycle
                                              ((lpddr_dev) ? {{($bits(mode_exit_timer_wider)-1){1'b0}},1'b1} :
                                                             {{($bits(mode_exit_timer_wider)-$bits(timer_pulse_x32)){1'b0}}, timer_pulse_x32}
                                              )
                                              ;
    end
end

assign mode_exit_timer = mode_exit_timer_wider [$bits(mode_exit_timer)-1:0];

// block against commands after self-refresh exit
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (!core_ddrc_rstn) begin
        block_t_xs          <= 1'b0;
        block_t_xs_dll      <= 1'b0;
    end else if ((current_state == GS_ST_SELFREF)
    ) begin
        block_t_xs          <= 1'b0;
        block_t_xs_dll      <= 1'b0;
    end else begin
        block_t_xs          <= ((current_state == GS_ST_SELFREF_EX1) && (next_state == GS_ST_SELFREF_EX2)) |
                               // satisfy tXSR when exiting SR (case when SR-PD was not entered at all) 
                               ((current_state == GS_ST_SELFREF_ENT2) && (next_state == GS_ST_SELFREF_EX2)) |
                               (block_t_xs & (mode_exit_timer <  {{($bits(mode_exit_timer)-$bits(dh_gs_t_xs_w)){1'b0}},dh_gs_t_xs_w}));
        block_t_xs_dll      <= ((current_state == GS_ST_SELFREF_EX1) && (next_state == GS_ST_SELFREF_EX2)) |
                               // satisfy tXSR when exiting SR (case when SR-PD was not entered at all)
                               ((current_state == GS_ST_SELFREF_ENT2) && (next_state == GS_ST_SELFREF_EX2)) |
                               (block_t_xs_dll & ((mode_exit_timer < {{($bits(mode_exit_timer)-$bits(dh_gs_t_xs_dll_w)){1'b0}},dh_gs_t_xs_dll_w})
                               ));
    end
end

// tSR timer
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      tsr_timer_r <= {$bits(tsr_timer_r){1'b0}};
   end
   else if (gs_op_is_enter_sr_lpddr) begin
      tsr_timer_r <= reg_ddrc_t_ckesr;
   end
   else if (|tsr_timer_r) begin
      tsr_timer_r <= tsr_timer_r - {{($bits(tsr_timer_r)-1){1'b0}},1'b1};
   end
end

// tXSR_DSM timer
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      xsr_dsm_timer_r <= {$bits(xsr_dsm_timer_r){1'b0}};
   end
   else if (gs_op_is_exit_dsm) begin
      xsr_dsm_timer_r <= reg_ddrc_t_xsr_dsm_x1024 + {{($bits(xsr_dsm_timer_r)-1){1'b0}},1'b1};
   end
   else if (timer_pulse_x1024 & (|xsr_dsm_timer_r)) begin
      xsr_dsm_timer_r <= xsr_dsm_timer_r - {{($bits(xsr_dsm_timer_r)-1){1'b0}},1'b1};
   end
end


//spyglass disable_block STARC05-2.11.3.1
//SMD: Combinational and sequential parts of an FSM described in same always block
//SJ: Reported for power_state_timer. Coding style used to prevent underflow. No re-coding required.
// -----------------------------------------------------------------------------
// - Power state timer
// This is used to enforce tXP.
// -----------------------------------------------------------------------------
  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        power_state_timer <= {$bits(power_state_timer){1'b0}};
    end
    else begin
      if (next_state != current_state) begin
        if ((next_state == GS_ST_POWERDOWN)         || (next_state == GS_ST_SELFREF) ||
            (next_state == GS_ST_POWERDOWN_EX_DFILP)|| (next_state == GS_ST_SELFREF_EX_DFILP) ||
            (next_state == GS_ST_POWERDOWN_EX1)     || (next_state == GS_ST_SELFREF_EX1)
           ) begin
          power_state_timer <= {$bits(power_state_timer){1'b0}};
        end
        else begin
          if(reg_ddrc_lpddr5)begin
            power_state_timer <= {{($bits(power_state_timer)-$bits(dh_gs_t_xp)){1'b0}}, dh_gs_t_xp} + {{($bits(power_state_timer)-$bits(reg_ddrc_t_csh)){1'b0}}, reg_ddrc_t_csh};
          end else begin  
            power_state_timer <= {{($bits(power_state_timer)-$bits(dh_gs_t_xp)){1'b0}}, dh_gs_t_xp};
          end 
        end
      end
      else if (power_state_timer != {$bits(power_state_timer){1'b0}}) begin
        power_state_timer   <= (power_state_timer - {{($bits(power_state_timer)-1){1'b0}},1'b1})   ;
      end
    end
  end
//spyglass enable_block STARC05-2.11.3.1




//------------------------ End Non-Resetable Flops -----------------------------

//------------------------------------------------------------------------------
// High Priority Read Queue Starvation-Avoidance FSM
//------------------------------------------------------------------------------

gs_q_fsm
 hpr_q_fsm (
        .co_yy_clk              (co_yy_clk),
        .core_ddrc_rstn         (core_ddrc_rstn),
        .xact_run_length        (dh_gs_hpr_xact_run_length),
        .max_starve             (dh_gs_hpr_max_starve),
        .go2critical            (r_go2critical_hpr),
// High priority will only be critical for starvation, not depth
        .empty                  (ih_gs_rdhigh_empty),
        .xact_this_q            (gs_op_is_rd_hi),
        .q_critical             (rdhigh_critical),
        .q_state                (gs_dh_hpr_q_state)
);

//------------------- End High Priority Read Queue FSM --------------------------

//------------------------------------------------------------------------------
// Low Priority Read Queue Starvation-Avoidance FSM
//------------------------------------------------------------------------------
gs_q_fsm
 lpr_q_fsm (
        .co_yy_clk              (co_yy_clk),
        .core_ddrc_rstn         (core_ddrc_rstn),
        .xact_run_length        (dh_gs_lpr_xact_run_length),
        .max_starve             (dh_gs_lpr_max_starve),
        .go2critical            (r_go2critical_lpr),
// TE valid signal is a better indicator that ih_gs_..., because it's
// updated sooner.  Currently, we do not have seperate hi & lo indicators
// from TE, tho.  In the future, if priority is used, it would be
// preferable to get hi & lo indicators from TE instead of using the IH emptys
        .empty                  (ih_gs_rdlow_empty),
        .xact_this_q            (gs_op_is_rd_lo),
        .q_critical             (rdlow_critical),
        .q_state                (gs_dh_lpr_q_state)
);
//------------------- End Low Priority Read Queue FSM --------------------------

//------------------------------------------------------------------------------
// Write Queue Starvation-Avoidance FSM
//------------------------------------------------------------------------------
gs_q_fsm
 w_q_fsm (
        .co_yy_clk              (co_yy_clk),
        .core_ddrc_rstn         (core_ddrc_rstn),
        .xact_run_length        (dh_gs_w_xact_run_length),
        .max_starve             (dh_gs_w_max_starve),
        .go2critical            (r_go2critical_wr),
        .empty                  (~te_gs_wr_vld), // only looking at wr valid that is available for scheduling, not all valids
        .xact_this_q            (gs_op_is_wr),
        .q_critical             (wr_critical),
        .q_state                (gs_dh_w_q_state)
);

//----------------------------- End Write Queue FSM ----------------------------

//------------------------------------------------------------------------------
// Critical compare
//

wire wrcam_up_thresh;
wire wr_critical_l1;
wire wr_critical_l2;
wire wr_critical_l3;
wire rdlow_critical_l1;
wire rdlow_critical_l2;
wire rdlow_critical_l3;
wire rdhigh_critical_l1;
wire rdhigh_critical_l2;
wire rdhigh_critical_l3;
wire rd_critical_l1;
wire rd_critical_l2;
wire rd_critical_l3;
wire w_wr_more_crit;
wire w_rd_more_crit;
wire w_hpr_more_crit;
wire w_wr_crit_l123;
wire w_rd_crit_l123;
wire rd_l1_wr_l1;
wire rd_l2_wr_l2;

assign wrcam_up_thresh = (wr_mode_next & wr_cam_up_lowth) | (~wr_mode_next & wr_cam_up_highth) ;


assign wr_critical_l1 = te_gs_wr_vld & r_go2critical_l1_wr;
assign wr_critical_l2 = te_gs_wr_vld & r_go2critical_l2_wr; 
assign wr_critical_l3 = te_gs_wr_vld & wr_critical & ~reg_ddrc_opt_wrcam_fill_level;

assign rdlow_critical_l1  = ~ih_gs_rdlow_empty  & r_go2critical_l1_lpr;
assign rdlow_critical_l2  = ~ih_gs_rdlow_empty  & r_go2critical_l2_lpr;
assign rdlow_critical_l3  = rdlow_critical;
assign rdhigh_critical_l1 = ~ih_gs_rdhigh_empty & r_go2critical_l1_hpr;
assign rdhigh_critical_l2 = ~ih_gs_rdhigh_empty & r_go2critical_l2_hpr;
assign rdhigh_critical_l3 = rdhigh_critical;

assign rd_critical_l1 = rdlow_critical_l1 | rdhigh_critical_l1; 
assign rd_critical_l2 = rdlow_critical_l2 | rdhigh_critical_l2; 
assign rd_critical_l3 = rdlow_critical_l3 | rdhigh_critical_l3; 

assign rd_l1_wr_l1     = wr_critical_l1 & rd_critical_l1; //read write both in L1
assign rd_l2_wr_l2     = ~wr_critical_l1 & ~rd_critical_l1 & ~wrcam_up_thresh & wr_critical_l2 & rd_critical_l2; //read write both in L2

assign w_wr_more_crit  = {wr_critical_l1, wrcam_up_thresh, wr_critical_l2, wr_critical_l3} > {rd_critical_l1, 1'b0, rd_critical_l2, rd_critical_l3} & ~rd_l1_wr_l1 & ~rd_l2_wr_l2;
assign w_rd_more_crit  = (({wr_critical_l1, wrcam_up_thresh, wr_critical_l2, wr_critical_l3} < {rd_critical_l1, 1'b0, rd_critical_l2, rd_critical_l3}) || (reg_ddrc_prefer_read && ~(ih_gs_rdhigh_empty && ih_gs_rdlow_empty) && ({wr_critical_l1, wrcam_up_thresh, wr_critical_l2, wr_critical_l3} == {rd_critical_l1, 1'b0, rd_critical_l2, rd_critical_l3})) ) & ~rd_l1_wr_l1 & ~rd_l2_wr_l2;
assign w_hpr_more_crit = {rdhigh_critical_l1, rdhigh_critical_l2, rdhigh_critical_l3} >= {rdlow_critical_l1, rdlow_critical_l2, rdlow_critical_l3};
assign w_wr_crit_l123  = wr_critical_l1 | wr_critical_l2 | wr_critical_l3;
assign w_rd_crit_l123  = rd_critical_l1 | rd_critical_l2 | rd_critical_l3;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
      wr_more_crit  <= 1'b0;
      rd_more_crit  <= 1'b0;
      hpr_more_crit <= 1'b0;
      wr_crit_l123  <= 1'b0;
      rd_crit_l123  <= 1'b0;
   end
   else begin
      wr_more_crit  <= w_wr_more_crit ;
      rd_more_crit  <= w_rd_more_crit ;
      hpr_more_crit <= w_hpr_more_crit;
      wr_crit_l123  <= w_wr_crit_l123;
      rd_crit_l123  <= w_rd_crit_l123 | (reg_ddrc_prefer_read && ~(ih_gs_rdhigh_empty && ih_gs_rdlow_empty));
   end
//------------------------------------------------------------------------------

`ifndef SYNTHESIS

`ifdef SNPS_ASSERT_ON

//-------------------------------------------
//-------------------------------------------

reg[6:0]        selfref_gap_x32;        // gap counter post self refresh
reg[4:0]        cnt_32;                 // counter up to 32
reg[2:0]        pad_powerdown_timer;    // time for pad power down, in number of clock cycles

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
                pad_powerdown_timer <= 3'b0;
        else if (~(next_state == GS_ST_POWERDOWN_EX1))   // clear timer if state is not in powerdown_ex1
                pad_powerdown_timer <= 3'b0;
        else if (pad_powerdown_timer == 3'b111)                // saturate timer to maximum value
                pad_powerdown_timer <= pad_powerdown_timer;
        else
                pad_powerdown_timer <= pad_powerdown_timer + 1'b1;
end

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
                cnt_32 <= 5'b0;
        else
                cnt_32 <= cnt_32 + 1'b1;
end

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
                selfref_gap_x32 <= 7'b0;
        else if (~(current_state == GS_ST_SELFREF_EX2))  // current state is non-selfref_ex2, clear the counter
                selfref_gap_x32 <= 7'b0;
  // disable coverage collection as this is a saturaion check in SVA only            
  // VCS coverage off 
        else if (selfref_gap_x32 == 7'b111_1111)               // saturate counter
                selfref_gap_x32 <= selfref_gap_x32;
  // VCS coverage on          
        else if (cnt_32 == 5'b1_1111)                          // current state is selfref_ex2, decrement counter every 32 cycles
                selfref_gap_x32 <= selfref_gap_x32 + 1'b1;
end

    // -----------------------------------------------------------------------------
    //  Assertions for self-refresh exit
    // -----------------------------------------------------------------------------
    // Check to ensure that a period of asserting block_t_xs is between
    //   - ((dh_gs_t_xs_x32-1)*32) clocks and ((dh_gs_t_xs_x32+1)*32) clocks in non self-refresh abort mode / DDR2/3/4
    //   - block_t_xs >= dh_gs_t_xsr for LPDDR4
    //   - ((dh_gs_t_xs_abort_x32-1)*32) clocks and ((dh_gs_t_xs_abort_x32+1)*32) clocks in self-refresh abort mode
    property p_block_t_xs_period;
        int cnt;
        @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || (current_state == GS_ST_SELFREF_ENT)
        )
        $rose(block_t_xs)   |-> (1, cnt=0)
                            ##1 (block_t_xs, cnt++)[*1:$]
                            ##1 $fell(block_t_xs) ##0
                                     (cnt >= (dh_gs_t_xsr));
    endproperty : p_block_t_xs_period

    a_block_t_xs_period : assert property (p_block_t_xs_period);

    // Check to ensure that a period of asserting block_t_xs_dll is between ((dh_gs_t_xs_dll_x32-1)*32) clocks and ((dh_gs_t_xs_dll_x32+1)*32) clocks.
    property p_block_t_xs_dll_period;
        int cnt;
        @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || (current_state == GS_ST_SELFREF_ENT)
        )
        $rose(block_t_xs_dll)   |-> (1, cnt=0)
                                ##1 (block_t_xs_dll, cnt++)[*1:$]
                                ##1 $fell(block_t_xs_dll) ##0 
                                     (cnt >= (dh_gs_t_xsr));
    endproperty : p_block_t_xs_dll_period

    a_block_t_xs_dll_period : assert property (p_block_t_xs_dll_period);


    // Check to ensure that asserting period of block_t_xs is less than or equal to block_t_xs_dll.
    sequence s_block_t_xs;
        @(posedge co_yy_clk)
        $rose(block_t_xs) ##1 $fell(block_t_xs)[->1];
    endsequence : s_block_t_xs

    sequence s_block_t_xs_dll;
        @(posedge co_yy_clk)
        $rose(block_t_xs_dll) ##1 $fell(block_t_xs_dll)[->1];
    endsequence : s_block_t_xs_dll

    property p_correlation_between_txs_and_txsdll;
        @(posedge co_yy_clk) disable iff(!core_ddrc_rstn)
        $rose(block_t_xs) |-> s_block_t_xs.ended[->1] within s_block_t_xs_dll;
    endproperty : p_correlation_between_txs_and_txsdll

    a_correlation_between_txs_and_txsdll : assert property (p_correlation_between_txs_and_txsdll)
        else $error("%m %t block_t_xs is longer than block_t_xs_dll.", $time);

    // -----------------------------------------------------------------------------
   // Counter Overflow/Underflow Assertions
   // Note that these counter/timer widths are incremented by one to
   // catch the overflow/underflow condition; the MST bit must never be asserted.
   // Additional bit introduced is expected to be optimized away by the DesignCompiler
   // if we have limiters in these counters.
    // -----------------------------------------------------------------------------
   a_power_state_timer:         assert property(@(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (power_state_timer[$bits(power_state_timer)-1] == 0));
   a_powerdown_idle_timer_int:  assert property(@(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (powerdown_idle_timer_int[$bits(powerdown_idle_timer_int)-1] == 0));
   a_rdwr_idle_timer:           assert property(@(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (rdwr_idle_timer[$bits(rdwr_idle_timer)-1] == 0));

    a_rd2pd_count:      assert property(@(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (rd2pd_count[$bits(rd2pd_count)-1] == 0));




//--------------------
// CODE coverage check
//--------------------

localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

// mode_exit_timer overflow
assert_never #(0, 0, "mode_exit_timer overflow", CATEGORY) a_mode_exit_timer_overflow
  (co_yy_clk, core_ddrc_rstn, (mode_exit_timer_wider[$bits(mode_exit_timer_wider)-1]==1'b1));


wire rdwr_pol_sel;
assign rdwr_pol_sel = 1'b1; 

// assertions to check read to read/write

property p_switch_rd_rd_col_hit_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && rd_flush_ff && |rd_col_bank_page_hit |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/; //pghit0 && bitmap signal
endproperty

a_switch_rd_rd_col_hit_rd: assert property (p_switch_rd_rd_col_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_wr_col_hit_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode && ~normal_rd_to_normal_wr_mask
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && wr_flush_ff && |wr_col_bank_page_hit |-> normal_rd_to_normal_wr /*##1 wr_mode*/; //pghit0 and bitmap signal
endproperty

a_switch_rd_wr_col_hit_wr: assert property (p_switch_rd_wr_col_hit_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_rd_more_critical_hit_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && rd_more_crit && any_rd_pghit_tm0 && any_rd_ref_rdwr_switch
        |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/; //pghit0 and 1bit signal
endproperty

a_switch_rd_rd_more_critical_hit_rd: assert property (p_switch_rd_rd_more_critical_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_wr_more_critical_hit_or_cam_high_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode && ~normal_rd_to_normal_wr_mask
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && wr_more_crit && (any_wr_pghit | wr_cam_up_highth) && te_gs_wr_vld_ref_rdwr_switch
        |-> normal_rd_to_normal_wr /*##1 wr_mode*/; //pghit0 and 1bit signal
endproperty

a_switch_rd_wr_more_critical_hit_or_cam_high_wr: assert property (p_switch_rd_wr_more_critical_hit_or_cam_high_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_rd_hit_rd;    
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && any_rd_pghit && any_rd_ref_rdwr_switch
        |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/;
endproperty

a_switch_rd_rd_hit_rd: assert property (p_switch_rd_rd_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_wr_hit_wr;    
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode && ~normal_rd_to_normal_wr_mask
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && any_wr_pghit && (wr_pghit_up_thresh | delay_switch_write_timeout | ~any_rd_ref_rdwr_switch | wr_crit_l123) &&  te_gs_wr_vld_ref_rdwr_switch
        |-> normal_rd_to_normal_wr /*##1 wr_mode*/;
endproperty

a_switch_rd_wr_hit_wr: assert property (p_switch_rd_wr_hit_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_wr_hit_rd;    
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && any_wr_pghit && ~(wr_pghit_up_thresh | delay_switch_write_timeout | ~any_rd_ref_rdwr_switch | wr_crit_l123)
        |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/;
endproperty

a_switch_rd_wr_hit_rd: assert property (p_switch_rd_wr_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);
    
property p_switch_rd_rd_pending_rd;    
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && ~any_wr_pghit
        && any_rd_ref_rdwr_switch
        |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/;
endproperty

a_switch_rd_rd_pending_rd: assert property (p_switch_rd_rd_pending_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_wr_pending_wr;    
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode && ~normal_rd_to_normal_wr_mask
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && ~any_wr_pghit
        && ~any_rd_ref_rdwr_switch
        && (dh_gs_prefer_write || rdwr_idle_timeout) && te_gs_wr_vld_ref_rdwr_switch //pghit1 and bitmap
        |-> normal_rd_to_normal_wr /*##1 wr_mode*/;
endproperty

a_switch_rd_wr_pending_wr: assert property (p_switch_rd_wr_pending_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_wr_pending_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && ~any_wr_pghit
        && ~any_rd_ref_rdwr_switch
        && ~(dh_gs_prefer_write || rdwr_idle_timeout) && te_gs_wr_vld_ref_rdwr_switch //pghit1 and bitmap
        |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/;
endproperty

a_switch_rd_wr_pending_rd: assert property (p_switch_rd_wr_pending_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_no_pending_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && ~any_wr_pghit
        && ~any_rd_ref_rdwr_switch
        && ~te_gs_wr_vld_ref_rdwr_switch && ~dh_gs_prefer_write
        |-> ~normal_rd_to_normal_wr /*##1 ~wr_mode*/;
endproperty

a_switch_rd_no_pending_rd: assert property (p_switch_rd_no_pending_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_rd_no_pending_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_mode && ~normal_rd_to_normal_wr_mask
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~(wr_more_crit && (any_wr_pghit | wr_cam_up_highth))
        && ~any_rd_pghit
        && ~any_wr_pghit
        && ~any_rd_ref_rdwr_switch
        && ~te_gs_wr_vld_ref_rdwr_switch && dh_gs_prefer_write
        |-> normal_rd_to_normal_wr /*##1 wr_mode*/;
endproperty

a_switch_rd_no_pending_wr: assert property (p_switch_rd_no_pending_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

// assertions to check write to read/write

property p_switch_wr_wr_col_hit_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode
        && wr_flush_ff && |wr_col_bank_page_hit |-> ~normal_wr_to_normal_rd /*##1 wr_mode*/;
endproperty

a_switch_wr_wr_col_hit_wr: assert property (p_switch_wr_wr_col_hit_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_rd_col_hit_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode && ~normal_wr_to_normal_rd_mask && ~wr2rd_mid_mode_early
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && rd_flush_ff && |rd_col_bank_page_hit |-> normal_wr_to_normal_rd /*##1 ~wr_mode*/;
endproperty

a_switch_wr_rd_col_hit_rd: assert property (p_switch_wr_rd_col_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_wr_more_critical_hit_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && wr_more_crit && (any_wr_pghit || wr_cam_up_lowth) && te_gs_wr_vld_ref_rdwr_switch
        |-> ~normal_wr_to_normal_rd /*##1 wr_mode*/;
endproperty

a_switch_wr_wr_more_critical_hit_wr: assert property (p_switch_wr_wr_more_critical_hit_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);


property p_switch_wr_rd_more_critical_hit_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode && ~normal_wr_to_normal_rd_mask
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && rd_more_crit && any_rd_pghit_tm0 && any_rd_ref_rdwr_switch
        |-> normal_wr_to_normal_rd /*##1 ~wr_mode*/;
endproperty

a_switch_wr_rd_more_critical_hit_rd: assert property (p_switch_wr_rd_more_critical_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_wr_hit_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && any_wr_pghit && te_gs_wr_vld_ref_rdwr_switch
        |-> ~normal_wr_to_normal_rd /*##1 wr_mode*/;
endproperty

a_switch_wr_wr_hit_wr: assert property (p_switch_wr_wr_hit_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_rd_hit_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode && ~normal_wr_to_normal_rd_mask
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~any_wr_pghit
        && (~global_block_rd_early || rd_pghit_up_thresh) && any_rd_pghit && any_rd_ref_rdwr_switch
        |-> normal_wr_to_normal_rd /*##1 ~wr_mode*/;
endproperty

a_switch_wr_rd_hit_rd: assert property (p_switch_wr_rd_hit_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_wr_pending_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~any_wr_pghit
        && ~any_rd_pghit
        && te_gs_wr_vld_ref_rdwr_switch
        |-> ~normal_wr_to_normal_rd /*##1 wr_mode*/;
endproperty

a_switch_wr_wr_pending_wr: assert property (p_switch_wr_wr_pending_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_rd_pending_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode && ~normal_wr_to_normal_rd_mask
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~any_wr_pghit
        && ~any_rd_pghit
        && ~te_gs_wr_vld_ref_rdwr_switch
        && any_rd_ref_rdwr_switch && (~dh_gs_prefer_write || rdwr_idle_timeout) && ~wr2rd_mid_mode_early
        |-> normal_wr_to_normal_rd /*##1 ~wr_mode*/;
endproperty

a_switch_wr_rd_pending_rd: assert property (p_switch_wr_rd_pending_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_rd_pending_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~any_wr_pghit
        && ~any_rd_pghit
        && ~te_gs_wr_vld_ref_rdwr_switch
        && any_rd_ref_rdwr_switch && ~((~dh_gs_prefer_write || rdwr_idle_timeout) && ~wr2rd_mid_mode_early)
        |-> ~normal_wr_to_normal_rd /*##1 wr_mode*/;
endproperty

a_switch_wr_rd_pending_wr: assert property (p_switch_wr_rd_pending_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);
    
property p_switch_wr_no_pending_wr;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~any_wr_pghit
        && ~any_rd_pghit
        && ~te_gs_wr_vld_ref_rdwr_switch
        && ~any_rd_ref_rdwr_switch
        && dh_gs_prefer_write
        |-> ~normal_wr_to_normal_rd /*##1 wr_mode*/;
endproperty

a_switch_wr_no_pending_wr: assert property (p_switch_wr_no_pending_wr)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_switch_wr_no_pending_rd;
    @(posedge co_yy_clk) disable iff (~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_mode && ~normal_wr_to_normal_rd_mask
        && ~(wr_flush_ff && |wr_col_bank_page_hit)
        && ~(rd_flush_ff && |rd_col_bank_page_hit)
        && ~(wr_more_crit && (any_wr_pghit || wr_cam_up_lowth))

        && ~(rd_more_crit && any_rd_pghit_tm0)
        && ~any_wr_pghit
        && ~any_rd_pghit
        && ~te_gs_wr_vld_ref_rdwr_switch
        && ~any_rd_ref_rdwr_switch
        && ~dh_gs_prefer_write && ~wr2rd_mid_mode_early
        |-> normal_wr_to_normal_rd /*##1 ~wr_mode*/;
endproperty

a_switch_wr_no_pending_rd: assert property (p_switch_wr_no_pending_rd)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_delay_switch_write_state;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        (next_state == GS_ST_NORMAL_RD) && any_rd_ref_rdwr_switch && ~any_rd_pghit && te_gs_wr_vld_ref_rdwr_switch && any_wr_pghit |-> ##1 delay_switch_write_state ^~ (|reg_ddrc_delay_switch_write);
endproperty

a_delay_switch_write_state: assert property (p_delay_switch_write_state)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_delay_switch_write_0;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~|reg_ddrc_delay_switch_write |-> delay_switch_write_timeout;
endproperty

a_delay_switch_write_0: assert property (p_delay_switch_write_0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_delay_switch_write_1;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        |reg_ddrc_delay_switch_write && (dwd_cnt < ({reg_ddrc_delay_switch_write,1'b0})) |-> ~delay_switch_write_timeout;
endproperty

a_delay_switch_write_1: assert property (p_delay_switch_write_1)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_delay_switch_write_2;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        |reg_ddrc_delay_switch_write && (dwd_cnt == ({reg_ddrc_delay_switch_write,1'b0})) |-> delay_switch_write_timeout;
endproperty

a_delay_switch_write_2: assert property (p_delay_switch_write_2)    
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_delay_switch_write_3;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        |reg_ddrc_delay_switch_write && (dwd_cnt < ({reg_ddrc_delay_switch_write,1'b0})) && ~dwd_cnt_start |-> ##1 dwd_cnt==0;
endproperty

a_delay_switch_write_3: assert property (p_delay_switch_write_3)    
    else $error("Inline SVA [%t][%m] FAILED", $time);

covergroup cg_delay_switch_write @(posedge co_yy_clk);

    cp_dwd_cnt: coverpoint ({delay_switch_write_state, reg_ddrc_delay_switch_write - dwd_cnt}) iff(core_ddrc_rstn && rdwr_pol_sel) {
        bins satisfied_0    =   {1'b1,  0                           };
        bins satisfied_1    =   {1'b1,  [1:{DWD_CNT_BITS{1'b1}}]    };
        bins unsatisfied_0  =   {1'b0,  0                           };
        bins unsatisfied_1  =   {1'b0,  [1:{DWD_CNT_BITS{1'b1}}]    };
    }

    cp_reg_ddrc_delay_switch_write: coverpoint ({reg_ddrc_delay_switch_write}) iff(core_ddrc_rstn && rdwr_pol_sel) {
        bins watermark_0    =   {{(DWD_CNT_BITS-1){1'b1}}                       };
        bins watermark_1    =   {{(DWD_CNT_BITS-1){1'b1}}-1                     };
        bins watermark_2    =   {0                                          };
        bins watermark_3    =   {1                                          };
        bins watermark_4    =   {[2: {(DWD_CNT_BITS-1){1'b1}}-2]                };
    }

    endgroup: cg_delay_switch_write

cg_delay_switch_write cg_delay_switch_write_inst = new;    

// assertions to check wr_more_critical
property p_wr_more_critical_l1_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        wr_critical_l1 && ~rd_critical_l1 |-> ##1 wr_more_crit && ~rd_more_crit;
endproperty

a_wr_more_critical_l1_chk: assert property (p_wr_more_critical_l1_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_wr_more_critical_cam_low_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && ~rd_critical_l1 &&
        (next_state==GS_ST_NORMAL_WR) && wr_cam_up_lowth /* && reg_ddrc_opt_wrcam_fill_level */
        |-> ##1 wr_more_crit && ~rd_more_crit;
endproperty

a_wr_more_critical_cam_low_chk: assert property (p_wr_more_critical_cam_low_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);


property p_wr_more_critical_cam_high_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && ~rd_critical_l1 &&
        wr_cam_up_highth
        |-> ##1 wr_more_crit && ~rd_more_crit;
endproperty

a_wr_more_critical_cam_high_chk: assert property (p_wr_more_critical_cam_high_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);


property p_wr_more_critical_l2_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && ~rd_critical_l1 &&
        ~((next_state==GS_ST_NORMAL_WR) && (wr_cam_up_lowth)) &&
        ~wr_cam_up_highth &&
        wr_critical_l2 && ~rd_critical_l2
        |-> ##1 wr_more_crit && ~rd_more_crit;
endproperty

a_wr_more_critical_l2_chk: assert property (p_wr_more_critical_l2_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_wr_more_critical_l3_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && ~rd_critical_l1 &&
        ~((next_state==GS_ST_NORMAL_WR) && (wr_cam_up_lowth)) &&
        ~wr_cam_up_highth &&
        ~wr_critical_l2 && ~rd_critical_l2 &&
        wr_critical_l3 && ~rd_critical_l3
        |-> ##1 wr_more_crit && ~rd_more_crit;
endproperty

a_wr_more_critical_l3_chk: assert property (p_wr_more_critical_l3_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

// assertions to check rd_more_critical
property p_rd_more_critical_l1_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && rd_critical_l1 |-> ##1 ~wr_more_crit && rd_more_crit;
endproperty

a_rd_more_critical_l1_chk: assert property (p_rd_more_critical_l1_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_rd_more_critical_l2_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && ~rd_critical_l1 &&
        ~((next_state==GS_ST_NORMAL_WR) && (wr_cam_up_lowth)) &&
        ~wr_cam_up_highth &&
        ~wr_critical_l2 && rd_critical_l2
        |-> ##1 ~wr_more_crit && rd_more_crit;
endproperty

a_rd_more_critical_l2_chk: assert property (p_rd_more_critical_l2_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_rd_more_critical_l3_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        ~wr_critical_l1 && ~rd_critical_l1 &&
        ~((next_state==GS_ST_NORMAL_WR) && (wr_cam_up_lowth)) &&
        ~wr_cam_up_highth &&
        ~wr_critical_l2 && ~rd_critical_l2 &&
        ~wr_critical_l3 && rd_critical_l3
        |-> ##1 ~wr_more_crit && rd_more_crit;
endproperty
a_rd_more_critical_l3_chk: assert property (p_rd_more_critical_l3_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

// assertions to check wr_more_crit && rd_more_crit
property p_wr_rd_more_critical_chk;
    @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || ~rdwr_pol_sel)
        (wr_more_crit && rd_more_crit) == 0;
endproperty

a_wr_rd_more_critical_chk: assert property (p_wr_rd_more_critical_chk)
    else $error("Inline SVA [%t][%m] FAILED", $time);

covergroup cg_rws_critical_level @(posedge co_yy_clk);

    cp_rws_wr_critical_level: coverpoint ({wr_critical_l1, wr_critical_l2, wr_critical_l3, |reg_ddrc_opt_wrcam_fill_level ,wr_cam_up_highth, wr_cam_up_lowth}) iff(core_ddrc_rstn && rdwr_pol_sel) {
        wildcard illegal_bins highth_small_lowth = {6'b????10} ;
        wildcard illegal_bins opt_wrcam_en = {6'b??11??} ;
        wildcard illegal_bins opt_dis_high = {6'b???01?} ;
        wildcard illegal_bins opt_dis_low = {6'b???0?1} ;
        }

    cp_rws_rdlow_critical_level: coverpoint ({rdlow_critical_l1, rdlow_critical_l2, rdlow_critical_l3}) iff(core_ddrc_rstn) {}
    
    cp_rws_rdhigh_critical_level: coverpoint ({rdhigh_critical_l1, rdhigh_critical_l2, rdhigh_critical_l3}) iff(core_ddrc_rstn) {}

    cp_rws_wr_rd_critical_level: cross cp_rws_wr_critical_level, cp_rws_rdlow_critical_level, cp_rws_rdhigh_critical_level;

endgroup: cg_rws_critical_level

// Coverage group instantiation
cg_rws_critical_level cg_rws_critical_level_inst = new;



`endif   // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule  // gs_global_fsm: global DDR-tracking state machine


