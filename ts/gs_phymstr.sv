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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_phymstr.sv#1 $
// -------------------------------------------------------------------------
// Description:
// This module is responsible for responding to PHY Master interface on DFI.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_phymstr 
import DWC_ddrctl_reg_pkg::*;
#(
    parameter    RANK_BITS       = `MEMC_RANK_BITS
   ,parameter    NUM_RANKS       = 1 << RANK_BITS // max # of physical ranks supported
    ,parameter    SELFREF_SW_WIDTH_INT = SELFREF_SW_WIDTH
    ,parameter    SELFREF_TYPE_WIDTH_INT = SELFREF_TYPE_WIDTH
   )
   (
    input                         co_yy_clk                             // clock
   ,input                         core_ddrc_rstn                        // async falling-edge reset
   ,input                         phy_dfi_phymstr_req                   // requst from PHY to control the DFI
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Signals unused. Keeping these as they are part of the phymstr interface.
   ,input [`MEMC_NUM_RANKS-1 : 0] phy_dfi_phymstr_cs_state              // state of DRAM when the PHY becomes master
   ,input                         phy_dfi_phymstr_state_sel             // required memory state
   ,input [1:0]                   phy_dfi_phymstr_type                  // PHY Master IF time selector
//spyglass enable_block W240
   ,output reg                    ddrc_dfi_phymstr_ack                  // grant access of the DFI bus to the PHY
   ,input                         gs_phymstr_lp_ack                     // dfi_lp_ack (from gs_dfilp)
   ,input                         st_lp_e_ack_check                     // wait for LP ack state of DFI LP FSM
   ,input                         gs_phymstr_dram_st_sr                 // indicates that the DRAM is in SR (from gs_global_fsm_sr_hw_lp)
   ,input                         gs_ctrlupd_req                        // indicates a ctrlupd_req (from gs)
   ,output reg                    gs_phymstr_clr_lp_req                 // request to exit DFI LP requests (to gs_dfilp)
   ,output reg                    gs_phymstr_sre_req                    // request SRE (to gs_global_fsm_sr_hw_lp)
   ,output reg                    gs_phymstr_mask_dfilp                 // mask SR triggers (to gs_dfilp)
   ,input                         dh_gs_phymstr_en                      // indicates if PHY Master IF is enabled
   ,input [SELFREF_SW_WIDTH_INT-1:0]  reg_ddrc_selfref_sw                   // SW initiated SR
   ,input                         reg_ddrc_hw_lp_en                     // HW SR enable
   ,input                         csysreq_ddrc_mux                      // csysreq_ddrc from low power controller FSM
   ,input                         dfi_init_start
   ,input [4:0]                   reg_ddrc_dfi_t_ctrl_delay             // timer value for DFI tctrl_delay
   ,input                         clock_stop_exited                     // clock is not stopped
   ,input [4:0]                   gs_dfi_t_wrdata_delay_cnt             // counter value for DFI twrdata_delay
   ,input                         zqcl_due_to_sr_exit_ext               // ZQ calib due to SR exit
   ,input [NUM_RANKS-1:0]         rank_nop_after_zqcs_gfsm              // nop time between ZQCal(start) and ZQCal(Latch)
   
   ,input                         gs_pi_odt_pending                     // waiting for the ODT command to complete
   
   ,input                         gs_pi_op_is_load_mr_norm              // load_mr_norm command issued to DRAM
   ,input      [NUM_RANKS-1:0]    rank_nop_after_load_mr_norm           // nop time after load_mr_norm
   ,input      [NUM_RANKS-1:0]    load_mr_norm_required                 // load mr required during normal operation
   
   ,input                         gs_pi_data_pipeline_empty             // no read/write data in flight
   
   ,input                         dh_gs_stay_in_selfref                 // stay_in_selfref register value
   ,input                         dh_gs_lpddr4                          // LPDDR4 SDRAM
   ,input                         gs_wck_stop_ok                        // WCK stop flag
   ,input                         gsfsm_sr_exit_req                     // SR exit request
   ,output                        phymstr_active                        // indication that there is activity on PHY Master IF
   ,output reg                    no_sr_mrrw_due_to_phymstr             // block MRR/MRW/ZQCal commands while PHY Master req is being handled
);

//----------------------------------- PARAMETERS -------------------------------

// states
localparam ST_SIZE               = 3;
localparam ST_PHYMSTR_IDLE       = 3'b000;
localparam ST_PHYMSTR_CLEAR_LP   = 3'b001;
localparam ST_PHYMSTR_SR_ENTRY   = 3'b010;
localparam ST_PHYMSTR_PHY_RESP   = 3'b011;
localparam ST_PHYMSTR_SR_EXIT    = 3'b100;

// Estimated maximum delay for a command to go through uMCTL2:
// - through DFI (+3 cycles)
// - 2T mode (+1 cycle)
// - geardown mode (+1 cycle)
// - extra margin (+8 cycles)
localparam max_ctrl_dly = 13;

//------------------------------ WIRES AND REGISTERS ---------------------------

// FSM state
reg [ST_SIZE-1 : 0] current_state;
reg [ST_SIZE-1 : 0] next_state;

// FSM state indicators
wire i_st_idle;
wire i_st_clear_lp;
wire i_st_sr_entry;
wire i_st_phy_resp;

// t_cmd_delay logic
// t_cmd_delay = max_delay_through_uMCTL2 + dfi_t_ctrl_delay (i.e. delay through PHY)
reg [5:0] dfi_t_cmd_delay_timer;
wire dfi_t_cmd_delay_timer_eq_0;
wire phymstr_sr_entry_ok;
reg i_phymstr_sr_entry_ok_r;
wire dfi_t_cmd_delay_timer_load;
wire [5:0] dfi_t_cmd_delay_timer_load_val;
wire [4:0] phymstr_ctrl_wrdata_delay_cnt_val;


// Signals related to blocking MR commands during PHY Master
wire no_sr_mrrw_set;
reg [4:0] no_sr_mrrw_reset_timer;
wire no_sr_mrrw_reset_timer_load;
wire no_sr_mrrw_reset;

//-------------------------------- MAIN CODE BLOCK -----------------------------

   //
   // State Machine
   // 

   // FSM sequential
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : phymstr_st_seq_PROC
      if (!core_ddrc_rstn)
         current_state <= ST_PHYMSTR_IDLE;
      else
         current_state <= next_state;
   end

   // FSM combinatorial
   always @(*) begin : phymstr_st_comb_PROC
      case (current_state)

         ST_PHYMSTR_IDLE :  begin
            // if there is a PHY Master request from the PHY and we have no ctrlupd_req move to ST_PHYMSTR_CLEAR_LP state
            // if PHY Master IF is not enabled remain in ST_PHYMSTR_IDLE state
            if (
                phy_dfi_phymstr_req & ~gs_ctrlupd_req & dh_gs_phymstr_en
                & ~dfi_init_start
               )
               next_state = ST_PHYMSTR_CLEAR_LP;
            else
               next_state = ST_PHYMSTR_IDLE;
         end // ST_PHYMSTR_IDLE

         ST_PHYMSTR_CLEAR_LP : begin
            // if there is a DFI LP request in service wait until it is serviced and move to ST_PHYMSTR_SR_ENTRY state
            if (~gs_phymstr_lp_ack & ~st_lp_e_ack_check)
               next_state = ST_PHYMSTR_SR_ENTRY;
            else
               next_state = ST_PHYMSTR_CLEAR_LP;
         end // ST_PHYMSTR_CLEAR_LP

         ST_PHYMSTR_SR_ENTRY : begin
            // wait for the requested SRE to happen and for SRE command to be sent to SDRAM and then move to ST_PHYMSTR_PHY_RESP state
            if (phymstr_sr_entry_ok & dfi_t_cmd_delay_timer_eq_0 & ~dfi_t_cmd_delay_timer_load
                // no read/write data in flight
                & gs_pi_data_pipeline_empty
                // not waiting for the ODT command to complete
                & (~gs_pi_odt_pending)
                // not dfi_init_start initiated
                & ~dfi_init_start
               )
               next_state = ST_PHYMSTR_PHY_RESP;
            else
               next_state = ST_PHYMSTR_SR_ENTRY;
         end // ST_PHYMSTR_SR_ENTRY

         ST_PHYMSTR_PHY_RESP : begin
            if (~phy_dfi_phymstr_req)
               next_state = ST_PHYMSTR_SR_EXIT;
            else
               next_state = ST_PHYMSTR_PHY_RESP;
         end // ST_PHYMSTR_PHY_RESP

         // ST_PHYMSTR_SR_EXIT
         default : begin
            // wait for the requested SRX to happen and move to ST_PHYMSTR_IDLE state
            if (~gs_phymstr_dram_st_sr
                | reg_ddrc_selfref_sw
                | dh_gs_stay_in_selfref
                | (reg_ddrc_hw_lp_en & ~csysreq_ddrc_mux)
               )
               next_state = ST_PHYMSTR_IDLE;
            else
               next_state = ST_PHYMSTR_SR_EXIT;
         end // ST_PHYMSTR_SR_EXIT

      endcase // case (current_state)
   end
   
   //
   // Aditional Logic
   //
   
   // FSM state indicators
   assign i_st_idle     = (current_state == ST_PHYMSTR_IDLE)     ? 1'b1 : 1'b0;
   assign i_st_clear_lp = (current_state == ST_PHYMSTR_CLEAR_LP) ? 1'b1 : 1'b0;
   assign i_st_sr_entry = (current_state == ST_PHYMSTR_SR_ENTRY) ? 1'b1 : 1'b0;
   assign i_st_phy_resp = (current_state == ST_PHYMSTR_PHY_RESP) ? 1'b1 : 1'b0;
   
   // ST_PHYMSTR_SR_ENTRY is possible if:
   // - we are in SR state
   // - no SR exit request for non-LPDDR4 case (in LPDDR4 no problem since we first exit SR-PD)
   assign phymstr_sr_entry_ok = gs_phymstr_dram_st_sr &
                                clock_stop_exited &                             
                                // no ZQ calib
                                (~(|rank_nop_after_zqcs_gfsm)) & (~zqcl_due_to_sr_exit_ext) &
                                // no MR activity
                                (~(|rank_nop_after_load_mr_norm)) & (~gs_pi_op_is_load_mr_norm) & (~(|load_mr_norm_required)) &
                                gs_wck_stop_ok &
                                (~gsfsm_sr_exit_req
                                       | dh_gs_lpddr4
                                );
   
   // flopped phymstr_sr_entry_ok
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : i_phymstr_sr_entry_ok_r_PROC
      if (!core_ddrc_rstn)
         i_phymstr_sr_entry_ok_r <= 1'b0;
      else 
         i_phymstr_sr_entry_ok_r <= phymstr_sr_entry_ok;
   end
   
   // t_ctrl_delay timer load:
   // - on rising edge of phymstr_sr_entry_ok
   // - if no MR scheduled
   assign dfi_t_cmd_delay_timer_load = phymstr_sr_entry_ok & ~i_phymstr_sr_entry_ok_r;
   
   // use larger of gs_dfi_t_wrdata_delay_cnt or reg_ddrc_dfi_t_ctrl_delay
   assign phymstr_ctrl_wrdata_delay_cnt_val = (gs_dfi_t_wrdata_delay_cnt > reg_ddrc_dfi_t_ctrl_delay) ? gs_dfi_t_wrdata_delay_cnt : reg_ddrc_dfi_t_ctrl_delay;
   
   // set ctrl_delay_timer load value to MAX(gs_dfi_t_wrdata_delay_cnt, reg_ddrc_dfi_t_ctrl_delay) + MAX delay through controller
   assign dfi_t_cmd_delay_timer_load_val = {1'b0, phymstr_ctrl_wrdata_delay_cnt_val} + max_ctrl_dly[5:0];
   
   // t_ctrl_delay timer
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : dfi_t_cmd_delay_timer_PROC
      if (!core_ddrc_rstn)
         dfi_t_cmd_delay_timer <= 6'h0;
      else if (dfi_t_cmd_delay_timer_load)
         dfi_t_cmd_delay_timer <= dfi_t_cmd_delay_timer_load_val;
      else if (|dfi_t_cmd_delay_timer)
         dfi_t_cmd_delay_timer <= dfi_t_cmd_delay_timer - 6'h1;
      else 
         dfi_t_cmd_delay_timer <= 6'h0;
   end
   
   assign dfi_t_cmd_delay_timer_eq_0 = (dfi_t_cmd_delay_timer == 0) ? 1'b1 : 1'b0;
   

   // pulse to set no_sr_mrrw_due_to_phymstr to 1
   assign no_sr_mrrw_set = i_st_sr_entry && (next_state == ST_PHYMSTR_PHY_RESP);
   
   // load no_sr_mrrw_reset_timer when we are about to de-assert PHY Master acknowledge
   assign no_sr_mrrw_reset_timer_load = ((next_state == ST_PHYMSTR_SR_EXIT) && i_st_phy_resp) ? 1'b1 : 1'b0;
   
   // timer used to delay no_sr_mrrw_due_to_phymstr de-assertion after phymstr_ack is de-asserted
   // needed to make sure dfi_phymstr_ack is dropped on DFI as well
   // - load when transitioning to ST_PHYMSTR_SR_EXIT state
   // - count down till 0
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : no_sr_mrrw_reset_timer_PROC
      if (!core_ddrc_rstn)
         no_sr_mrrw_reset_timer <= 'h0;
      else if (no_sr_mrrw_reset_timer_load)
         no_sr_mrrw_reset_timer <= max_ctrl_dly[4:0] + 5'b00001;
      else if (|no_sr_mrrw_reset_timer)
         no_sr_mrrw_reset_timer <= no_sr_mrrw_reset_timer - 5'b00001;
      else
         no_sr_mrrw_reset_timer <= no_sr_mrrw_reset_timer;
   end
   
   // pulse to set no_sr_mrrw_due_to_phymstr back to 0
   assign no_sr_mrrw_reset = (no_sr_mrrw_reset_timer == 1) ? 1'b1 : 1'b0;
   
   // Drive outputs
   //
   
   // assert phymstr_ack after SR is entered and de-assert 1 cycle after phymstr_req is dropped
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : ddrc_dfi_phymstr_ack_PROC
      if (!core_ddrc_rstn)
         ddrc_dfi_phymstr_ack <= 1'b0;
      else if (next_state == ST_PHYMSTR_SR_EXIT)
         ddrc_dfi_phymstr_ack <= 1'b0;
      else if (i_st_phy_resp & ~gs_ctrlupd_req)
         ddrc_dfi_phymstr_ack <= 1'b1;
      else
         ddrc_dfi_phymstr_ack <= ddrc_dfi_phymstr_ack;
   end
   
   // if there is a LP request in service, take the LP FSM out of ST_LP_WAIT state, so that dfi_lp_req is de-asserted
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : gs_phymstr_clr_lp_req_PROC
      if (!core_ddrc_rstn)
         gs_phymstr_clr_lp_req <= 1'b0;
      else if (next_state == ST_PHYMSTR_CLEAR_LP)
         gs_phymstr_clr_lp_req <= 1'b1;
      else if (next_state == ST_PHYMSTR_SR_ENTRY)
         gs_phymstr_clr_lp_req <= 1'b0;
      else
         gs_phymstr_clr_lp_req <= gs_phymstr_clr_lp_req;
   end
   
   // SRE request pulse - send SRE request to gs_global_fsm_sr_hw_lp when state transitions to ST_PHYMSTR_SR_ENTRY                     
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : gs_phymstr_sre_req_PROC
      if (!core_ddrc_rstn)
         gs_phymstr_sre_req <= 1'b0;
      else if (next_state == ST_PHYMSTR_SR_ENTRY)
         gs_phymstr_sre_req <= 1'b1;
      else if (next_state == ST_PHYMSTR_SR_EXIT)
         gs_phymstr_sre_req <= 1'b0;
      else
         gs_phymstr_sre_req <= gs_phymstr_sre_req;
   end
   
   // mask future DFI LP requests upon CLEAR_LP and keep the mask until the DFI Master Interface handshaking is eneded
   // (i.e. dfi_phymstr_req dropped)
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : gs_phymstr_mask_dfilp_PROC
      if (!core_ddrc_rstn)
         gs_phymstr_mask_dfilp <= 1'b0;
      else if (i_st_clear_lp)
         gs_phymstr_mask_dfilp <= 1'b1;
      else if (next_state == ST_PHYMSTR_SR_EXIT)
         gs_phymstr_mask_dfilp <= 1'b0;
      else
         gs_phymstr_mask_dfilp <= gs_phymstr_mask_dfilp;
   end

   // PHY Master is active if we are not in IDLE state
   assign phymstr_active = ~i_st_idle;
   
   // Block MR commands
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : no_sr_mrrw_due_to_phymstr_PROC
      if (!core_ddrc_rstn)
         no_sr_mrrw_due_to_phymstr <= 1'b0;
      else if (no_sr_mrrw_set)
         no_sr_mrrw_due_to_phymstr <= 1'b1;
      else if (no_sr_mrrw_reset)
         no_sr_mrrw_due_to_phymstr <= 1'b0;
      else
         no_sr_mrrw_due_to_phymstr <= no_sr_mrrw_due_to_phymstr;
   end

endmodule // gs_phymstr
