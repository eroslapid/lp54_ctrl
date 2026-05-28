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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_glue.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// Global Scheduler sub-unit.  This block is responsible for implementing the
// glue logic that does not fit naturally into any other GS sub-unit.  This
// will include the pulses to drive 32-cycle and 1024-cycle timers in all
// other sub-units as well as logic for glue logic used to tie together the
// refresh logic from all ranks.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_glue 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS ----------------------------------
     parameter    RANK_BITS           = `MEMC_RANK_BITS
    ,parameter    BANK_BITS           = `MEMC_BANK_BITS

    ,parameter    MRS_A_BITS          = `MEMC_PAGE_BITS
    ,parameter    MRS_BA_BITS         = `MEMC_BG_BANK_BITS

    ,parameter    CID_WIDTH           = `DDRCTL_DDRC_CID_WIDTH

    ,parameter    NUM_RANKS           = 1 << RANK_BITS
    ,parameter    NUM_LRANKS          = `DDRCTL_DDRC_NUM_LRANKS_TOTAL
    ,parameter    MAX_NUM_CMD         = 2

  )
  (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                      co_yy_clk
    ,input                                      core_ddrc_rstn                    // async falling-edge reset
    ,input                                      gs_op_is_wr                       // write from GS
    ,input                                      wr_mode_early                     // 1=write may be issued next cycle, not reads
                                                                                  // 0=read may be issued next cycle, not writes
    ,input                                      global_block_wr_early             // block writes in the following cycle

    ,input                                      gsnx_op_is_ref                    // normal-mode refresh command
    ,input                                      init_refresh                      // init sequence refresh command
    ,output                                     timer_pulse_x32                   // pulses once every 32 clocks
    ,output                                     timer_pulse_x1024                 // pulses once every 1024 clocks
                                                                                  // to allow speculative refresh
    ,output reg                                 gs_te_wr_possible                 // indicates that a write MAY be issued this cycle
                                                                                  // (used to disable write combine)
    ,output                                     gs_op_is_ref                      // send refresh command to PI
    ,output     [NUM_RANKS-1:0]                 gs_ref_cs_n                       // chip select to PI
    ,input                                      dh_gs_sw_init_int                 // SW intervention in auto SDRAM initialization


    ,input      [MRS_A_BITS-1:0]                gs_pi_mrs_a_init
    ,input      [MRS_A_BITS-1:0]                gs_pi_mrs_a_norm
    ,output     [MRS_A_BITS-1:0]                gs_pi_mrs_a

    ,input                                      gs_pi_op_is_load_mode_init
    ,input                                      gs_pi_op_is_load_mr_norm
    ,output                                     gs_op_is_load_mode

    ,input                                      init_operating_mode

    //---------------------------
    // Signals associated with refresh_update_level pulse generation
    //---------------------------
    ,input                                      dh_gs_refresh_update_level
    ,output                                     dh_gs_refresh_update_pulse
    ,input                                      derate_refresh_update_level
    ,output                                     derate_refresh_update_pulse

    ,input      [T_RFC_MIN_WIDTH-1:0]           dh_gs_t_rfc_min                   // minimum time between refreshes
    ,input      [T_RFC_MIN_AB_WIDTH-1:0]        dh_gs_t_rfc_min_ab
    ,input      [T_PBR2PBR_WIDTH-1:0]           dh_gs_t_pbr2pbr                   // minimum time between LPDDR4 per-bank refresh refreshes different bank
    ,input      [T_PBR2ACT_WIDTH-1:0]           dh_gs_t_pbr2act                   // minimum time between LPDDR5 per-bank refresh act different bank
    ,input      [REFRESH_MARGIN_WIDTH-1:0]      dh_gs_refresh_margin              // # of cycles (x32) early to attempt refresh
    ,input      [REFRESH_TO_X1_X32_WIDTH-1:0]   dh_gs_refresh_to_x1_x32           // timeout (x1/x32) before issuing a requested
                                                                                  // refresh when the DDRC is idle
    ,input      [5:0]                           dh_gs_refresh_burst               // 0 = refresh after each nominal refresh period
                                                                                  // 1 = send 2 consecutive refreshes after 2 nominal refresh periods
                                                                                  // ...
    ,input                                      dh_gs_t_refi_x1_sel
    ,input     [T_REFI_X1_X32_WIDTH-1:0]            dh_gs_t_refi_x1_x32
    ,input                                      dh_gs_per_bank_refresh
    ,output    [T_REFI_X1_X32_WIDTH+4:0]            t_refi
    ,input     [T_REFI_X1_X32_WIDTH+4:0]        derate_gs_t_refi
    ,input     [T_REFI_X1_X32_WIDTH+4:0]        derate_gs_t_refie
    ,output    [T_REFI_X1_X32_WIDTH+4:0]        derated_t_refi
    ,output    [T_REFI_X1_X32_WIDTH+4:0]        derated_t_refie
    ,input                                      derate_force_refab
    ,output reg                                 refab_forced
    ,input     [REFRESH_TO_X1_X32_WIDTH-1:0]    reg_ddrc_refresh_to_ab_x32
    ,output                                     per_bank_refresh
    // Updated refresh registers
    ,output reg [T_RFC_MIN_WIDTH-1:0]           t_rfc_min_upd
    ,output reg [T_PBR2PBR_WIDTH-1:0]           t_pbr2pbr_upd
    ,output reg [T_PBR2ACT_WIDTH-1:0]           t_pbr2act_upd
    ,output reg [REFRESH_MARGIN_WIDTH-1:0]      refresh_margin_upd
    ,output reg [REFRESH_TO_X1_X32_WIDTH-1:0]   refresh_to_x1_x32_upd
    ,output     [5:0]                           refresh_burst_upd
    ,input                                      init_mpc_zq_start
    ,input                                      init_mpc_zq_latch
    ,input                                      load_mpc_zq_start
    ,input                                      load_mpc_zq_latch
    ,output                                     gs_mpc_zq_start
    ,output                                     gs_mpc_zq_latch
  );

//--------------------------------- WIRES --------------------------------------

//------------------------------- REGISTERS ------------------------------------

reg     [4:0]               timer_x32;
reg     [4:0]               timer_x1024;
reg     [1:0]               timer_x4096;



//------------------------------------------------
// Generating the dh_gs_refresh_update_pulse
// This signal pulses everytime there is a change of state in the signals - refresh_update_level
// The pulse is sent to the various modules using the refresh registers
// The refresh register values are updated only in the cycle in which the pulse goes high
// The refresh signals that use this pulse are:
//    - t_rfc_min
//    - refresh_margin
//    - refresh_to_x1_x32
//    - refresh_burst
//------------------------------------------------
   

//------------------------------
// Generate refresh_update_pulse from the APB register
//------------------------------
reg             dh_gs_refresh_update_level_1d;        // 1ck delayed

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
      dh_gs_refresh_update_level_1d  <= 1'b0;
   end
   else begin
      dh_gs_refresh_update_level_1d  <= dh_gs_refresh_update_level;
   end
end

// Update pulse of refresh registers
 assign dh_gs_refresh_update_pulse  = 
                                      (dh_gs_refresh_update_level ^ dh_gs_refresh_update_level_1d);


//------------------------------
// Generate refresh_update_pulse from the Derate signal
//------------------------------

reg             derate_refresh_update_level_1d;        // 1ck delayed

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
      derate_refresh_update_level_1d <= 1'b0;
   end
   else begin
      derate_refresh_update_level_1d <= derate_refresh_update_level;
   end
end

// Update pulse of derate refresh_update signal
assign derate_refresh_update_pulse = derate_refresh_update_level ^ derate_refresh_update_level_1d;




//------------------------------
// Generate refresh_update_pulse from the Retry signal
//------------------------------



// ------------------------------------------------
// Generating pulse after reset is de-asserted
// ------------------------------------------------
reg             reset_over, reset_over_r;
wire            reset_over_pulse;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     begin
        if (!core_ddrc_rstn) begin  
           reset_over         <= 1'b0;
           reset_over_r       <= 1'b0;
        end
        else begin
           reset_over         <= 1'b1;
           reset_over_r       <= reset_over;
        end
     end

// pulse for one cycle after reset is de-asserted - used to load the refresh register values
  assign reset_over_pulse          = reset_over && ~reset_over_r;

   
//--------------------------------------------------
// Updating the refresh register values after reset de-assertion and change of
// state of refresh_update_level signal 
//
// t_refi selection is done inside gs_rank_constraints.v
// this is bcoz, the logic in gs_rank_cosntraints.v used 'refresh_timer_started' signal to load
// the intial APB value instead of reset over pulse
//
//--------------------------------------------------

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (!core_ddrc_rstn)
    refab_forced <= 1'b0;
  else if (~refab_forced & dh_gs_per_bank_refresh & derate_force_refab & (~gs_op_is_ref))
    refab_forced <= 1'b1;
  else if (~derate_force_refab)
    refab_forced <= 1'b0;
end

reg [T_RFC_MIN_WIDTH-1:0] t_rfc_min_upd_int;
reg [5:0] refresh_burst_upd_int;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if(!core_ddrc_rstn) begin
    t_rfc_min_upd_int     <= {$bits(t_rfc_min_upd_int){1'b0}};
    t_pbr2pbr_upd         <= {($bits(t_pbr2pbr_upd)){1'b0}};
    t_pbr2act_upd         <= {($bits(t_pbr2act_upd)){1'b0}};
    refresh_margin_upd    <= {$bits(refresh_margin_upd){1'b0}};
    refresh_to_x1_x32_upd <= {$bits(refresh_to_x1_x32_upd){1'b0}};
    refresh_burst_upd_int <= {$bits(refresh_burst_upd_int){1'b0}};
  end
  else begin
    t_rfc_min_upd_int     <= (reset_over_pulse || dh_gs_refresh_update_pulse)  ? dh_gs_t_rfc_min       : t_rfc_min_upd_int;
    t_pbr2pbr_upd         <= (reset_over_pulse || dh_gs_refresh_update_pulse)  ? dh_gs_t_pbr2pbr       : t_pbr2pbr_upd;
    t_pbr2act_upd         <= (reset_over_pulse || dh_gs_refresh_update_pulse)  ? dh_gs_t_pbr2act       : t_pbr2act_upd;
    refresh_margin_upd    <= (reset_over_pulse || dh_gs_refresh_update_pulse)  ? dh_gs_refresh_margin  : refresh_margin_upd;
    refresh_to_x1_x32_upd <= 
                              refab_forced ? reg_ddrc_refresh_to_ab_x32 :
                             (reset_over_pulse || dh_gs_refresh_update_pulse)  ? dh_gs_refresh_to_x1_x32 : refresh_to_x1_x32_upd;
    refresh_burst_upd_int <= (reset_over_pulse || dh_gs_refresh_update_pulse)  ? dh_gs_refresh_burst   : refresh_burst_upd_int;
  end
end

wire [T_RFC_MIN_WIDTH:0] t_rfc_min_upd_int_wider;
assign t_rfc_min_upd_int_wider = refab_forced ? {t_rfc_min_upd_int, 1'b0} : {1'b0, t_rfc_min_upd_int};
                              
assign t_rfc_min_upd = 
                          // if RFSHSET1TMG1.t_rfc_min_ab > 0, we use this as tRFCmin when we switch from REFpb to REFab. This is used for LPDDR5 2/6/8Gb
                          // if RFSHSET1TMG1.t_rfc_min_ab = 0, we use RFSHSET1TMG1.t_rfc_min * 2 as tRFCmin when we switch from REFpb to REFab. This is used for LPDDR4 6/8/12/16/24/32Gb and LPDDR5 3/4/12/16Gb
                          refab_forced ? ((dh_gs_t_rfc_min_ab > {$bits(dh_gs_t_rfc_min_ab){1'b0}}) ? dh_gs_t_rfc_min_ab : t_rfc_min_upd_int_wider[T_RFC_MIN_WIDTH-1:0]) :
                          t_rfc_min_upd_int;

assign refresh_burst_upd = 
                          refab_forced ? {3'b000, refresh_burst_upd_int[5:3]} : 
                          refresh_burst_upd_int;
                          
//------------------------------------------------
//------------------------------------------------
//------------------------------------------------



//--------------------------------- FLOPS --------------------------------------

always  @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    timer_x32           <= 5'b00000;
    timer_x1024         <= 5'b00000;
    timer_x4096         <= 2'b00;
    gs_te_wr_possible   <= 1'b0;
  end // if reset
  else begin
    timer_x32           <= timer_x32 + 5'h01;
    timer_x1024         <= (timer_x32 == 5'b11111) ? (timer_x1024 + 5'b00001) : timer_x1024;
    timer_x4096         <= (timer_x32 == 5'b11111 && timer_x1024 == 5'b11111) ? (timer_x4096 + 2'b01) : timer_x4096;
    gs_te_wr_possible   <= wr_mode_early & (~gs_op_is_wr) & (~global_block_wr_early);
  end



// 

//---------------------------- ASSIGN OUTPUTS ----------------------------------

assign per_bank_refresh = dh_gs_per_bank_refresh & (~refab_forced);

assign t_refi = 
                    (dh_gs_t_refi_x1_sel & dh_gs_per_bank_refresh) ? {{($bits(t_refi)-$bits(dh_gs_t_refi_x1_x32)){1'b0}}, dh_gs_t_refi_x1_x32} : 
                    {dh_gs_t_refi_x1_x32, {($bits(t_refi)-$bits(dh_gs_t_refi_x1_x32)){1'b0}}};

assign derated_t_refi = refab_forced ? {derate_gs_t_refi[T_REFI_X1_X32_WIDTH+1:0], 3'b000} : derate_gs_t_refi;
assign derated_t_refie = refab_forced ? {derate_gs_t_refie[T_REFI_X1_X32_WIDTH+1:0], 3'b000} : derate_gs_t_refie;

assign timer_pulse_x32  = (timer_x32 == 5'b11111);
assign timer_pulse_x1024= ((timer_x32 == 5'b11111) && (timer_x1024 == 5'b11111));

assign gs_op_is_ref     = gsnx_op_is_ref | init_refresh;

   assign gs_ref_cs_n   = 1'b0;


// Muxing the load mode signals during init and normal modes
assign  gs_pi_mrs_a        = (init_operating_mode && !dh_gs_sw_init_int) ? gs_pi_mrs_a_init           : gs_pi_mrs_a_norm;
assign  gs_op_is_load_mode = (init_operating_mode && !dh_gs_sw_init_int) ? gs_pi_op_is_load_mode_init : gs_pi_op_is_load_mr_norm;

   assign gs_mpc_zq_start  = (init_operating_mode && !dh_gs_sw_init_int) ? init_mpc_zq_start : load_mpc_zq_start;
   assign gs_mpc_zq_latch  = (init_operating_mode && !dh_gs_sw_init_int) ? init_mpc_zq_latch : load_mpc_zq_latch;

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON

// t_rfc_min_upd_int overflow
assert_never a_t_rfc_min_upd_int_overflow (co_yy_clk, core_ddrc_rstn, (t_rfc_min_upd_int_wider[T_RFC_MIN_WIDTH] == 1'b1));

`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule  // gs_glue: glue logic for global scheduler
