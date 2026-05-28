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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_zq_calib.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_zq_calib 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS ----------------------------------
     parameter    RANK_BITS                 = (`MEMC_RANK_BITS >= 1)? `MEMC_RANK_BITS : 1

    ,parameter    GS_ST_SELFREF_ENT_DFILP   = 5'b00011    // DFI LP I/F entry SR
    ,parameter    GS_ST_SELFREF             = 5'b01100    // DDR is in self-refresh
    ,parameter    GS_ST_SELFREF_EX_DFILP    = 5'b01101    // DFI LP I/F exit SR
    ,parameter    GS_ST_SELFREF_EX1         = 5'b01110    // power up pads
    ,parameter    GS_ST_SELFREF_EX2         = 5'b01111    // bring DDR out of self-refresh

    ,parameter    NUM_RANKS                 = `MEMC_NUM_RANKS
    ,parameter    FSM_STATE_WIDTH           = 5

  )
  (
  //--------------------------- INPUTS AND OUTPUTS ------------------------------
     input                              co_yy_clk
    ,input                              core_ddrc_rstn

    ,input                              dh_gs_lpddr4
    ,input                              dh_gs_zq_reset                        // ZQ Reset command
    ,input      [T_ZQ_RESET_NOP_WIDTH-1:0]                   dh_gs_t_zq_reset_nop                  // ZQ Reset NOP period
    ,output reg                         gs_dh_zq_reset_busy                   // Previous ZQ Reset is being processed when this is high
                                                                              // New ZQ Reset command is accepted only when this signal is low
    ,input                              reg_ddrc_lpddr5

    ,input                              dh_gs_dis_srx_zqcl                    // when 1, disable zqcl at self-refresh exit
    ,input                              dh_gs_zq_resistor_shared              // when 1, ZQ resistor is shared

    ,input                              timer_pulse_x1024                     // pulse every 1024 clocks used for timers
    ,input                              dh_gs_zq_calib_short                  // Command issuing ZQCS
    ,output reg                         gs_dh_zq_calib_short_busy             // Previous ZQCS has not been initiated when this is high 
    ,input                              dh_gs_dis_auto_zq                     // accept the cmd from core only if this is 1
    ,input      [T_ZQ_SHORT_NOP_WIDTH-1:0]   dh_gs_t_zq_short_nop             // tZQCS timer
    ,input      [T_ZQ_LONG_NOP_WIDTH-1:0]    dh_gs_t_zq_long_nop              // tZQOPER timer
    ,input      [T_ZQ_SHORT_INTERVAL_X1024_WIDTH-1:0]                  dh_gs_t_zq_short_interval_x1024       // interval between the auto zq commands issued by the controller
    ,input                              gsnx_op_is_zqcs                       // ZQ Calib Short command scheduled
    ,input                              start_zqcs_timer                      // start the ZQCS timer

    ,output     [NUM_RANKS-1:0]         rank_nop_after_zqcs                   // NOP after ZQCS
    ,output     [NUM_RANKS-1:0]         rank_nop_after_zqcs_gfsm              // NOP after ZQCS gs_global_fsm
    ,output     [NUM_RANKS-1:0]         zq_calib_short_required               // request to issue zq calib short command - level signal

    ,input      [FSM_STATE_WIDTH-1:0]   gs_dh_global_fsm_state                // state from global_fsm module

    ,output reg                         zqcl_due_to_sr_exit                   // Signal to GS module to indicate that ZQCS is initiated due to Self-Refresh exit
    ,output reg                         zqcl_mask_cmds_zq_resistor_shared     //
    ,input                              zqcl_due_to_sr_exit_ext_block_new_zq  // flags that ZQCL due to SR Exit is being extended due to extra cycles for stagger_cs and/or pi_gs_noxact    

    ,output reg                         zq_reset_req_on
    ,output                             zq_lat
    ,output                             block_zqlat
    ,input                              sr_mrrw_en
    ,input      [ODTLOFF_WIDTH-1:0]     dh_gs_odtloff
    ,input                              gs_op_is_wr
  );

//---------------------------- LOCAL PARAMETERS --------------------------------
localparam  IDLE                        = 2'b00;
localparam  WAIT_FOR_ZQCS               = 2'b01;
localparam  WAIT_FOR_ZQCS_NOP           = 2'b10;
localparam  ZQ_RESISTOR_SHARED_SETUP    = 2'b11;

//-----------------------
// Registers
//-----------------------
reg                        dh_gs_zq_calib_short_r;
reg                        co_gs_zq_calib_long_r;

reg    [1:0]               zq_calib_curr_state;
reg    [NUM_RANKS-1:0]     rank_nop_after_zqcs_d;
reg    [NUM_RANKS-1:0]     rank_nop_after_zqcs_r;
reg    [T_ZQ_LONG_NOP_WIDTH-1:0]  zq_short_timer;
reg    [NUM_RANKS-1:0]     zq_calib_short_required_r;

reg    [1:0]               zq_calib_next_state;
reg    [NUM_RANKS-1:0]     rank_nop_after_zqcs_w;
reg    [T_ZQ_LONG_NOP_WIDTH-1:0]  zq_short_timer_w;
reg    [NUM_RANKS-1:0]     zq_calib_short_required_w;


reg    [19:0]              auto_zq_timer_x1024;
wire   [19:0]              auto_zq_timer_x1024_w;

wire                       auto_zq_request;

wire                       zqcs_timer_started_w;
reg                        zqcs_timer_started;

wire    [NUM_RANKS-1:0]    active_ranks_int;        // internal active ranks signal
wire                       zq_detected;           //if zq cmd is detected, issue close page req
wire                       zqcl_detected;           // zqcl command to be issued due to self-refresh exit

reg                        zqcl_req_on_w;
reg                        zqcl_req_on;

wire                       zqcl_nop_over;
wire                       zqcs_nop_over;
wire                       zq_reset_nop_over;
wire                       zqcal_nop_over;  // LPDDR4 tZQCAL
wire                       zqlat_nop_over;  // LPDDR4 tZQLAT
wire                       zq_nop_over;

reg                        zq_reset_cmd_r;
reg                        zq_reset_cmd;

wire                       zq_reset_cmd_pulse;
wire                       zq_reset_detected;

reg                        zq_reset_req_on_w;

wire                       global_fsm_eq_self_ref;     // self-refresh state(gs_dh_global_fsm_state[3:2] == 2'b11)

wire dh_gs_zq_calib_short_w; // ZQ short calibration 

reg  dis_auto_zq_r;
wire dis_auto_zq_fall_edge_lp5;

always@(posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn)begin
      dis_auto_zq_r <= 1'b0;
   end
   else begin
      dis_auto_zq_r <= dh_gs_dis_auto_zq;
   end
end

assign dis_auto_zq_fall_edge_lp5 = (reg_ddrc_lpddr5 & !dh_gs_dis_auto_zq & dis_auto_zq_r);

//-----------------------
// Combinational Logic
//-----------------------


assign zq_detected     = (dh_gs_dis_auto_zq) ? dh_gs_zq_calib_short_r : ((auto_zq_request & (|(dh_gs_t_zq_short_interval_x1024)))
                                                                         | dis_auto_zq_fall_edge_lp5
                                                                         );


assign zqcl_detected     = co_gs_zq_calib_long_r;

assign zq_reset_detected = zq_reset_cmd;

assign  zqcs_timer_started_w = zqcs_timer_started | start_zqcs_timer;


// if not of ddr4 or lpddr4 mode - freeze the timer to max value
// if the controller is used for ddr4 or lpddr4:
//   If  : in self-refresh state, reset the timer to the programmed register value. This is b'coz a ZQCL will be issued at Self-Refresh exit
//   Else:  run the following auto_zq_timer
//          Decrement the timer when there is timer pulse, zqcs_timer started, not of dis_auto_zq and the timer is non-zero
// if the controller is used for lpddr4:
//   If  : in SR-Powerdown state, reset the timer to the programmed register value. This is b'coz a ZQCL will be issued at SR-Powerdown exit
//   Else:  run the following auto_zq_timer
//          Decrement the timer when there is timer pulse, zqcs_timer started, not of dis_auto_zq and the timer is non-zero
assign    auto_zq_timer_x1024_w    =  (~|(dh_gs_t_zq_short_interval_x1024))                             ? 20'hF_FFFF : 
                                        (global_fsm_eq_self_ref)                                        ? dh_gs_t_zq_short_interval_x1024 : // self-refresh state
                                        (timer_pulse_x1024 && zqcs_timer_started && (!dh_gs_dis_auto_zq)) ?
                                        (((|auto_zq_timer_x1024) ? auto_zq_timer_x1024 : dh_gs_t_zq_short_interval_x1024) - 20'h00001) :
                                        auto_zq_timer_x1024;

// self-refresh state(gs_dh_global_fsm_state[3:2] == 2'b11)
assign  global_fsm_eq_self_ref = 
// This might be updated for LPDDR5
//        (dh_gs_lpddr4)?    
                                 ((gs_dh_global_fsm_state == GS_ST_SELFREF_ENT_DFILP)||
                                  (gs_dh_global_fsm_state == GS_ST_SELFREF)          ||
                                  (gs_dh_global_fsm_state == GS_ST_SELFREF_EX_DFILP)) ;


// Make the request when the timer is at 0 and a new pulse comes and dis_auto_zq is at 0
assign    auto_zq_request    = (auto_zq_timer_x1024 == 20'h0) && timer_pulse_x1024 && zqcs_timer_started
                                 && (!gs_dh_global_fsm_state[4]
                                 || sr_mrrw_en
                                    ) ;


// Assigning internal active_ranks signal
// If more than one rank, dh_gs_active_ranks is assigned to internal active ranks
// If only one rank, then it is assigned 1
// It is done this way to avoid using many 'ifndef MEMC_NUM_RANKS_1' in the code that uses active_ranks (FSM)

reg [NUM_RANKS-1:0] i_active_ranks_int_st_mc;
reg [NUM_RANKS-1:0] i_active_ranks_int_st_mc_prev;

assign    active_ranks_int = 1'b1;



reg [RANK_BITS+1-1:0] i_active_ranks_int_st_mc_sel;
reg [RANK_BITS+1-1:0] i_active_ranks_int_st_mc_sel_prev;

assign zq_lat = i_active_ranks_int_st_mc_sel[0];


//spyglass disable_block W484
//SMD: Possible assignment overflow: lhs width 11 (Expr: 'dh_gs_t_zq_long_nop_aux') should be greater than rhs width 11 (Expr: 'dh_gs_t_zq_long_nop - 11'h003') to accommodate carry/borrow bit \
//     Possible assignment overflow: lhs width 11 (Expr: 'dh_gs_t_zq_reset_nop_aux') should be greater than rhs width 11 (Expr: '{1'b0,dh_gs_t_zq_reset_nop} + 11'h003') to accommodate carry/borrow bit
//SJ: For 1),2) and 3) Underflow does occur, but the *_aux signals are not used in these situations (code protected by 'if' conditions below) \
//    For 4) Overflow cannot occur in these conditions (mathematically impossible)

// For LPDDR4, length of MRW based ZQ-Reset command is 4 cycle. Need to adjust 3 cycles.
// For LPDDR5, length of MRW based ZQ-Reset command is 2 cycle. Need to adjust 1 cycles.
wire [$bits(dh_gs_t_zq_reset_nop):0] dh_gs_t_zq_reset_nop_aux;
assign dh_gs_t_zq_reset_nop_aux = {1'b0,dh_gs_t_zq_reset_nop} + ((dh_gs_lpddr4) ?  {{($bits(dh_gs_t_zq_reset_nop_aux)-2){1'b0}},2'b11} : {{($bits(dh_gs_t_zq_reset_nop_aux)-1){1'b0}},1'b1});
//spyglass enable_block W484 

// If ZQCL is request is ON, wait for long_nop timer, else wait for short_nop timer
// By using this method, we are reusing the zqcs logic for zqcl also

        // For LPDDR4, length of MRW based ZQ-Reset command is 4 cycle. Need to adjust 3 cycles.
        // For LPDDR5, length of MRW based ZQ-Reset command is 2 cycle. Need to adjust 1 cycles.
assign zq_reset_nop_over = (zq_short_timer == {{{$bits(zq_short_timer) - $bits(dh_gs_t_zq_reset_nop_aux)}{1'b0}},dh_gs_t_zq_reset_nop_aux});

wire [$bits(dh_gs_t_zq_long_nop)-1:0] dh_gs_t_zq_long_nop_p1;
assign dh_gs_t_zq_long_nop_p1 = dh_gs_t_zq_long_nop + {{($bits(dh_gs_t_zq_long_nop_p1)-1){1'b0}},1'b1};
wire [$bits(dh_gs_t_zq_short_nop):0] dh_gs_t_zq_short_nop_p1;
assign dh_gs_t_zq_short_nop_p1 = {1'b0,dh_gs_t_zq_short_nop} + {{($bits(dh_gs_t_zq_short_nop_p1)-1){1'b0}},1'b1};
// For LPDDR4, length of MPC(ZQ Cal) command is 2 cycle.
assign zqcal_nop_over  = (zq_short_timer == dh_gs_t_zq_long_nop_p1);
assign zqlat_nop_over  = (zq_short_timer == {{{$bits(zq_short_timer) - $bits(dh_gs_t_zq_short_nop_p1)}{1'b0}},dh_gs_t_zq_short_nop_p1});
assign zq_nop_over       =
                           ((zq_reset_req_on && ~zqcl_req_on) ? zq_reset_nop_over : ((i_active_ranks_int_st_mc_sel[0])? zqlat_nop_over : zqcal_nop_over));


assign dh_gs_zq_calib_short_w = 
                                dh_gs_zq_calib_short;

//-----------------------
// State Machine
//-----------------------
always @ (*) begin

    //ccx_fsm:;zq_calib_curr_state;WAIT_FOR_ZQCS->IDLE;Resetting DDRCTL is required to cover.
    //ccx_fsm:;zq_calib_curr_state;ZQ_RESISTOR_SHARED_SETUP->IDLE;Resetting DDRCTL is required to cover.
    case(zq_calib_curr_state)

       IDLE : begin

             zq_short_timer_w        = {$bits(zq_short_timer_w){1'b0}};
             rank_nop_after_zqcs_w  = {NUM_RANKS{1'b0}};
     
             i_active_ranks_int_st_mc_sel = {(RANK_BITS+1){1'b0}};


             // move from IDLE if ZQCS or ZQCL detected
             // but do not move from IDLE if ZQCL is being performed still by zqcl_due_to_sr_exit_ext_block_new_zq 
             if((zq_detected | zqcl_detected) & (~zqcl_due_to_sr_exit_ext_block_new_zq)) begin
                zqcl_req_on_w             = zqcl_detected;                       // assert this when request is due to zqcl. hold this high until NOP is done.
                zq_reset_req_on_w         = 1'b0;
              if (dh_gs_zq_resistor_shared) begin
                i_active_ranks_int_st_mc[0] = 1'b1;
                zq_calib_next_state       = WAIT_FOR_ZQCS;
                zq_calib_short_required_w = i_active_ranks_int_st_mc & {NUM_RANKS{1'b1}};
              end else begin
                i_active_ranks_int_st_mc  = active_ranks_int;
                zq_calib_next_state       = (reg_ddrc_lpddr5) ? ((dis_auto_zq_fall_edge_lp5 | zqcl_detected) ? WAIT_FOR_ZQCS_NOP : ZQ_RESISTOR_SHARED_SETUP) : WAIT_FOR_ZQCS;
                zq_calib_short_required_w = (reg_ddrc_lpddr5) ?  {NUM_RANKS{1'b0}} : (i_active_ranks_int_st_mc & {NUM_RANKS{1'b1}});// if zqcs cmd is detected, issue close page request
              end
             end
             else if(zq_reset_detected) begin // ZQ Reset command
                i_active_ranks_int_st_mc  = active_ranks_int;
                zq_calib_short_required_w = (i_active_ranks_int_st_mc & {NUM_RANKS{1'b1}});
                zqcl_req_on_w             = 1'b0;
                zq_reset_req_on_w         = zq_reset_detected;
                zq_calib_next_state       = WAIT_FOR_ZQCS;
             end
             else begin
                i_active_ranks_int_st_mc[NUM_RANKS-1:0] = {(NUM_RANKS){1'b0}};
                zq_calib_short_required_w = {NUM_RANKS{1'b0}};
                zqcl_req_on_w             = 1'b0;
                zq_reset_req_on_w         = 1'b0;
                zq_calib_next_state       = IDLE;
             end

          end


       WAIT_FOR_ZQCS : begin


            i_active_ranks_int_st_mc  = i_active_ranks_int_st_mc_prev;
            i_active_ranks_int_st_mc_sel  = i_active_ranks_int_st_mc_sel_prev;


            zq_short_timer_w        = {$bits(zq_short_timer_w){1'b0}};
            zqcl_req_on_w           = zqcl_req_on || zqcl_detected; // hold the request or latch new request due to SR exit
                                                                    // if FSM is already in this state due to ZQCS or ZQReset

            zq_reset_req_on_w       = zq_reset_req_on;              // hold the request

            // for shared ZQ resistor, WAIT_FOR_ZQCS could have been
            // entered under zq_reset_req_on control but was subsequently 
            // followed by zqcl_detected occurring
            // ZQCL has higher priority than ZQ Reset, so update rank
            // select accordingly
         //   `ifdef MEMC_LPDDR4
         // if ((dh_gs_zq_resistor_shared || dh_gs_lpddr4) && zqcl_detected && !zqcl_req_on && zq_reset_req_on) begin
         //   `else  // MEMC_LPDDR4
            if (dh_gs_zq_resistor_shared && zqcl_detected && !zqcl_req_on && zq_reset_req_on) begin
         //   `endif // MEMC_LPDDR4
              i_active_ranks_int_st_mc[0] = 1'b1;
            end

            if(gsnx_op_is_zqcs) begin // zqcs command issued
                    rank_nop_after_zqcs_w     = 1'b1; // assert rank_nop
                    zq_calib_short_required_w = 1'b0; // de-assert the required signal
                                        
            end else begin
                rank_nop_after_zqcs_w     = rank_nop_after_zqcs_d;
                zq_calib_short_required_w = zq_calib_short_required_r; // hold the request
            end

            // check zq_calib_short_required_r that hold request is cleared 
         // Override ZQ reset to ZQ Latch
            if(zqcl_detected && !zqcl_req_on && zq_reset_req_on && reg_ddrc_lpddr5) begin
                zq_calib_next_state    = WAIT_FOR_ZQCS_NOP;
            end else
            if (zq_calib_short_required_r == {NUM_RANKS{1'b0}}) begin
                zq_calib_next_state    = WAIT_FOR_ZQCS_NOP;
            end else begin
                zq_calib_next_state    = WAIT_FOR_ZQCS;
            end
            
        end

// ZQ_RESISTOR_SHARED_SETUP state only if mult-rank
// If single rank, WAIT_FOR_ZQCS_NOP is default state
// Note: Use ifndef MEMC_NUM_RANKS_GT_1 as RCE complains if use ifdef MEMC_NUM_RANKS_1
       WAIT_FOR_ZQCS_NOP : begin
                   i_active_ranks_int_st_mc  = i_active_ranks_int_st_mc_prev;
                   i_active_ranks_int_st_mc_sel  = i_active_ranks_int_st_mc_sel_prev;

                   zq_calib_short_required_w = {NUM_RANKS{1'b0}}; //i_active_ranks_int_st_mc & {NUM_RANKS{1'b0}}

                   // If ZQCL is request is ON, wait for long_nop timer, else wait for short_nop timer
                   // By using this method, we are reusing the zqcs logic for zqcl also
                   if(zq_nop_over) begin
                      zq_short_timer_w        = {$bits(zq_short_timer_w){1'b0}}; // reset the timer
                      rank_nop_after_zqcs_w   = {NUM_RANKS{1'b0}}; // de-assert the rank_nop signal
                      zq_reset_req_on_w       = 1'b0; // reset the request with the NOP timer expires

                          if (i_active_ranks_int_st_mc_sel[0]==1'b0) begin
                            // for zq_reset, only do it once, to all ranks,
                            // even if dh_gs_zq_resistor_shared=1
                            if (zq_reset_req_on && !zqcl_req_on) begin
                              zq_calib_next_state     = IDLE;
                              zqcl_req_on_w           = 1'b0; // reset the request when the ZCCL nop timer expires
    
                            end else begin
                              zq_calib_next_state     = ZQ_RESISTOR_SHARED_SETUP;
                              zqcl_req_on_w           = zqcl_req_on; // hold the request
                            end
    
                          end else begin
                            zqcl_req_on_w           = 1'b0; // reset the request when the ZCCL nop timer expires
                            zq_calib_next_state     = IDLE;
                          end

                   end
                   else begin
                      zq_short_timer_w        = zq_short_timer + {{($bits(zq_short_timer_w)-1){1'b0}},1'b1};
                      rank_nop_after_zqcs_w   = (reg_ddrc_lpddr5) ? {NUM_RANKS{1'b1}} : rank_nop_after_zqcs_d;
                      zqcl_req_on_w           = zqcl_req_on;         // hold the request
                      zq_reset_req_on_w       = zq_reset_req_on;              // hold the request
                      zq_calib_next_state     = WAIT_FOR_ZQCS_NOP;
                   end

               end


       //ZQ_RESISTOR_SHARED_SETUP : begin
       default : begin

                    zq_short_timer_w        = {$bits(zq_short_timer_w){1'b0}}; 
                    rank_nop_after_zqcs_w   = rank_nop_after_zqcs_d;

                    zqcl_req_on_w             = zqcl_req_on; // hold the request
                    zq_reset_req_on_w         = 1'b0;        

                    i_active_ranks_int_st_mc  = ((i_active_ranks_int_st_mc_sel_prev[0]==1'b0) && (dh_gs_lpddr4==1'b1))? i_active_ranks_int_st_mc_prev : active_ranks_int;

                    i_active_ranks_int_st_mc_sel = i_active_ranks_int_st_mc_sel_prev + 1;
                    zq_calib_short_required_w = i_active_ranks_int_st_mc & {NUM_RANKS{1'b1}}; 
                    zq_calib_next_state       = WAIT_FOR_ZQCS;
                 end

    endcase

end

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
     i_active_ranks_int_st_mc_prev <= {NUM_RANKS{1'b1}};
     i_active_ranks_int_st_mc_sel_prev <= {(RANK_BITS+1){1'b0}};

   end else begin
     i_active_ranks_int_st_mc_prev <= i_active_ranks_int_st_mc;
     i_active_ranks_int_st_mc_sel_prev <= i_active_ranks_int_st_mc_sel;
   end
 end

// In LPDDR5, registor_shared should be set to 0
wire zqcl_mask_cmds_zq_resistor_shared_set = (dh_gs_lpddr4) ? zqcl_req_on_w : 1'b0;

wire zqcl_mask_cmds_zq_resistor_shared_clr = (zq_calib_next_state==IDLE) ? 1 : 0;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
     zqcl_mask_cmds_zq_resistor_shared <= 1'b0;
   end else begin
     if (zqcl_mask_cmds_zq_resistor_shared_set) begin
       zqcl_mask_cmds_zq_resistor_shared <= 1'b1;
     end else if (zqcl_mask_cmds_zq_resistor_shared_clr) begin
       zqcl_mask_cmds_zq_resistor_shared <= 1'b0;
     end
     
   end
 end

// output zq_calib_short_required is disabled during MPR mode, but request is hold by zq_calib_short_required_r
assign zq_calib_short_required = zq_calib_short_required_r 
                               ;

//-----------------------
// All the flops
//-----------------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
    zq_calib_curr_state     <= 2'b00;
    rank_nop_after_zqcs_d   <= {NUM_RANKS{1'b0}};
    zq_short_timer          <= {$bits(zq_short_timer){1'b0}};
    zq_calib_short_required_r <= {NUM_RANKS{1'b0}};
    auto_zq_timer_x1024     <= 20'h1;
    zqcs_timer_started      <= 1'b0;
    zqcl_req_on             <= 1'b0;
    zq_reset_req_on         <= 1'b0;
   end
   else begin
    zq_calib_curr_state     <= zq_calib_next_state;
    rank_nop_after_zqcs_d   <= rank_nop_after_zqcs_w;
    zq_short_timer          <= zq_short_timer_w;
    zq_calib_short_required_r <= zq_calib_short_required_w;
    auto_zq_timer_x1024     <= auto_zq_timer_x1024_w;
    zqcs_timer_started      <= zqcs_timer_started_w;
    zqcl_req_on             <= zqcl_req_on_w;
    zq_reset_req_on         <= zq_reset_req_on_w;
   end
end

// registered value of rank_nop_after_zqcs
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
    rank_nop_after_zqcs_r     <= {NUM_RANKS{1'b0}};
   end else begin
    rank_nop_after_zqcs_r     <= rank_nop_after_zqcs_d;
   end
end

assign rank_nop_after_zqcs = ((zq_lat) || (zq_reset_req_on))? rank_nop_after_zqcs_d : {NUM_RANKS{1'b0}};

// for dh_gs_zq_resistor_shared, loop around zq_calib_curr_state by going
// into ZQ_RESISTOR_SHARED_SETUP state for one cycle
// rank_nop_after_zqcs=0 for one cycle as a result, which can lead the
// global_fsm to change state to PD/SR/etc. in middle of performing ZQ
// commands to each rank individually
// So have special version of rank_nop_after_zqcs for gs_global_fsm
// called rank_nop_after_zqcs_gfsm which is 1 in ZQ_RESISTOR_SHARED_SETUP state
// will be 1 for only 1 cycle, as ZQ_RESISTOR_SHARED_SETUP is only for one
// cycle
wire [NUM_RANKS-1:0] rank_nop_after_zqcs_zq_resistor_shared;
assign rank_nop_after_zqcs_zq_resistor_shared = (zq_calib_curr_state==ZQ_RESISTOR_SHARED_SETUP) ? rank_nop_after_zqcs_r : {NUM_RANKS{1'b0}};
assign rank_nop_after_zqcs_gfsm = rank_nop_after_zqcs_d | rank_nop_after_zqcs_zq_resistor_shared
                                  | ({NUM_RANKS{i_active_ranks_int_st_mc_sel[0]}} & i_active_ranks_int_st_mc)
                                  ;


// Latch the ZQCS command coming from external interface and hold it high until the FSM moves to IDLE state
// Ignore the command if the controller is in Self-refresh or DPD state
// This is to handle the case when the external ZQCS command comes when the FSM is in the process of executing another ZQCS command
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn)
            dh_gs_zq_calib_short_r <= 1'b0;
        else if (dh_gs_zq_calib_short_w & (~gs_dh_global_fsm_state[4] || (gs_dh_global_fsm_state == 5'h15)))
            dh_gs_zq_calib_short_r <= 1'b1;
        // do not clear if zqcl_due_to_sr_exit_ext_block_new_zq==1 as will not move
        // from IDLE to WAIT_FOR_ZQCS unless 
        else if (zq_calib_curr_state == IDLE && zqcl_due_to_sr_exit_ext_block_new_zq == 1'b0)
            dh_gs_zq_calib_short_r <= 1'b0;
end


// zq_calib_short_busy logic
// assert when command is received
// de-assert when FSM is in IDLE state and command can be processed at the next clock cycle
// If in DPD or MPSM, de-assert after one cycle.  APB logic requires that every zq_calib_short pulse is acknowledged with a busy.
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn) begin
            gs_dh_zq_calib_short_busy <= 1'b0;
        end
        else begin
            if (dh_gs_zq_calib_short_w)
                gs_dh_zq_calib_short_busy <= 1'b1;
            else if (gs_dh_global_fsm_state[4] && (gs_dh_global_fsm_state != 5'h15)) 
                gs_dh_zq_calib_short_busy <= 1'b0;
            // do not clear if zqcl_due_to_sr_exit_ext_block_new_zq==1 as will not move
            // from IDLE to WAIT_FOR_ZQCS unless 
            else if (zq_calib_curr_state == IDLE && zqcl_due_to_sr_exit_ext_block_new_zq == 1'b0)
                gs_dh_zq_calib_short_busy <= 1'b0;
        end
end


// assert when in either of the self-refresh exit states (SELFREF_EX1 or SELFREF_EX2)
wire   selfref_ex_state;

reg  [FSM_STATE_WIDTH-1:0] gs_dh_global_fsm_state_r;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn)
            gs_dh_global_fsm_state_r <= {FSM_STATE_WIDTH{1'b0}};
        else begin
            gs_dh_global_fsm_state_r <= gs_dh_global_fsm_state;
        end
end

assign selfref_ex_state =                                                  
// This might be updated for LPDDR5
//            (dh_gs_lpddr4)?
            ((gs_dh_global_fsm_state == GS_ST_SELFREF_EX1) && 
             ((gs_dh_global_fsm_state_r == GS_ST_SELFREF)          ||
              (gs_dh_global_fsm_state_r == GS_ST_SELFREF_EX_DFILP)));




// When in DDR4 or LPDDR4 mode, during Self-Refresh exit (SELFREF_EX1 or SELFREF_EX2 state), DRAM requires ZQCL command
// use it with the enable register - dh_gs_dis_srx_zqcl
// When in LPDDR5 mode, zqcl no longer exists.
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn)
            co_gs_zq_calib_long_r <= 1'b0;
        else begin
           if (selfref_ex_state & (~dh_gs_dis_srx_zqcl))
              co_gs_zq_calib_long_r <= 1'b1;
           else if ((zq_calib_curr_state == IDLE) || (zq_calib_curr_state == WAIT_FOR_ZQCS))
              co_gs_zq_calib_long_r <= 1'b0;
        end
end


// Signal to GS module to indicate that ZQCL is initiated due to Self-Refresh exit
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn)
           zqcl_due_to_sr_exit <= 1'b0;
        else begin
          if (selfref_ex_state & (~dh_gs_dis_srx_zqcl))
              zqcl_due_to_sr_exit <= 1'b1;
          else if(zq_calib_next_state==WAIT_FOR_ZQCS_NOP)
              zqcl_due_to_sr_exit <= 1'b0;
        end
end



// Flop the input ZQ Reset command
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn) begin
           zq_reset_cmd_r <= 1'b0;
        end
        else begin
           zq_reset_cmd_r <= dh_gs_zq_reset;
        end
end

// Detecting the rising edge of the ZQ reset command - only if zq_reset_busy is low - and if in LPDDR4 mode
assign zq_reset_cmd_pulse = (dh_gs_zq_reset & (~zq_reset_cmd_r)) & (~gs_dh_zq_reset_busy);


// Asserting the ZQ Reset command when the rising edge is detected
// De-asserting it when the ZQ Reset command is recognized by the FSM
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn) begin
           zq_reset_cmd <= 1'b0;
        end
        else begin
          if (zq_reset_cmd_pulse & (~gs_dh_global_fsm_state[4] || (gs_dh_global_fsm_state == 5'h15)))
               zq_reset_cmd <= 1'b1;
          else if (zq_reset_req_on)   // command detected in the FSM
               zq_reset_cmd <= 1'b0;
        end
end


// zq_reset_busy logic
// assert when command is received
// de-assert when command is fully serviced including the NOP period
// If in DPD or MPSM, de-assert after one cycle.  APB logic requires that every zq_reset pulse is acknowledged with a busy.
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if(!core_ddrc_rstn) begin
           gs_dh_zq_reset_busy <= 1'b0;
        end
        else begin
            if (zq_reset_cmd_pulse)
                gs_dh_zq_reset_busy <= 1'b1;
            else if (gs_dh_global_fsm_state[4] && (gs_dh_global_fsm_state != 5'h15))
                gs_dh_zq_reset_busy <= 1'b0;
            else if (zq_reset_req_on && zq_nop_over)   // NOP period over for ZQ Reset
               gs_dh_zq_reset_busy <= 1'b0;
        end
end

// ODTLoff latency + tODToff calculation
//   ODTLoff latency      : DRAMTMG13.odtloff
//   tODToff(max)=3.5ns   : 4cycle=3.5ns/0.937ns (LPDDR54 PHY supporting max DFI clock is 1067Mhz=0.937ns)
//   Write command length : Need adjust 2cycle (Freq-ratio=1:2 mode)
// starts when write data is empty
wire [$bits(dh_gs_odtloff):0]         odt_turnoff_cnt_val;
assign odt_turnoff_cnt_val = {{($bits(odt_turnoff_cnt_val)-$bits(dh_gs_odtloff)){1'b0}},dh_gs_odtloff} + {{($bits(odt_turnoff_cnt_val)-3){1'b0}},3'b100} + {{($bits(odt_turnoff_cnt_val)-2){1'b0}},2'b10};
reg  [$bits(odt_turnoff_cnt_val)-1:0] odt_turnoff_cnt;

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (!core_ddrc_rstn) begin
    odt_turnoff_cnt <= {$bits(odt_turnoff_cnt){1'b0}};
  end else begin
    if (gs_op_is_wr) begin
      odt_turnoff_cnt <= odt_turnoff_cnt_val;
    end else if (odt_turnoff_cnt > {$bits(odt_turnoff_cnt){1'b0}}) begin
      odt_turnoff_cnt <= odt_turnoff_cnt - {{($bits(odt_turnoff_cnt)-1){1'b0}},1'b1};
    end
  end
end

assign block_zqlat = ((zq_lat) && (zq_calib_curr_state == WAIT_FOR_ZQCS) && (odt_turnoff_cnt!={$bits(odt_turnoff_cnt){1'b0}}));

endmodule

