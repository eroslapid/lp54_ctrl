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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_q_fsm.sv#1 $
// -------------------------------------------------------------------------
// Description:
// gs_q_fsm - Queue state FSM (critical/non-critical)
// This block implements the finite state machine responsible for
//  determining when a queue is in the "critical" state and should be
//  prioritized.
// The FSM for determining this has 3 states:
//  * critical              - servicing the queue should be prioritized
//  * normal (non-critical) - normal state.  will become critical if it is
//                            starved for a period of time, or it reaches a
//                            high watermark
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module gs_q_fsm 
                (
//--------------------------- INPUTS AND OUTPUTS -------------------------------
   input            co_yy_clk               // clock
  ,input            core_ddrc_rstn          // async falling-edge reset

  //// Register Configs ////
  ,input  [7:0]     xact_run_length         // # of transactions guaranteed to be
                                            // serviced once queue is critical
  ,input  [15:0]    max_starve              // # of cycles the queue can be
                                            // starved before going critical
                                            // 0=no starvation

  //// Queue Level Inputs from IH ////
  ,input            go2critical             // want to go critical state
  ,input            empty                   // this queue has no pending transactions


  //// Inputs from other GS blocks ////
  ,input            xact_this_q             // transaction valid in input handler 

  //// Outputs ////
  ,output           q_critical              // this queue is in critical state
  ,output  [1:0]    q_state                 // current state of the FSM for monitoring
);

//---------------------------- LOCAL PARAMETERS --------------------------------
// define high pri/low pri/write queue states
localparam MEMC_GS_Q_ST_NORMAL        = 1'b0;
localparam MEMC_GS_Q_ST_CRITICAL      = 1'b1;

//------------------------------------ WIRES -----------------------------------
wire            next_state;
wire            critical_done;

//--------------------------------- REGISTERS ----------------------------------
reg             current_state;          // current state of global state machine

//// timers & counters
reg     [15:0]  max_starve_timer;       // down-counting starvation timer
reg             use_starve_timer;       // disable the starvation timer if
                                        // max_starve is set to all 0s
reg     [7:0]   q_run_length;           // up-counter of transactions serviced in critical state


//// Assign outputs
assign q_critical         = (current_state == MEMC_GS_Q_ST_CRITICAL);
assign q_state            = {current_state, 1'b0};

//------------------------------------------------------------------------------
// Queue Starvation-Avoidance FSM
//------------------------------------------------------------------------------

wire starve_timer_expired = use_starve_timer & (~(|max_starve_timer));

// Assert the critical_done when the queue is empty OR whent he q_run_length is >= the programmed run length
// For HPR queues:
// AND if there are no expired VPR commands
//  This condition was added to keep the HPR queue in Critical state until all the expired_vpr commands are served
assign critical_done  = (empty | (q_run_length >= xact_run_length))
                           ;

// Calculate next queue FSM state
assign next_state  =
                     (current_state == MEMC_GS_Q_ST_NORMAL)        ?
                         ((((starve_timer_expired || go2critical) && (~empty))
                           )                                        ?  MEMC_GS_Q_ST_CRITICAL       :
                                                                       MEMC_GS_Q_ST_NORMAL       ) :
                         (critical_done                             ?  MEMC_GS_Q_ST_NORMAL         :
                                                                       MEMC_GS_Q_ST_CRITICAL     ) ;
    
// resetable flops: low priority read queue FSM state, starvation timer
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    current_state  <= MEMC_GS_Q_ST_NORMAL;
    max_starve_timer  <= 16'b0;  // dummy value > 0.  Real value is set below after reset.
    use_starve_timer    <= 1'b0;
  end
  else begin
    current_state  <= next_state;
    // if max_starve is 0, don't use the starvation timer
    if (use_starve_timer) begin
      max_starve_timer  <= (empty | xact_this_q)               ? max_starve                  :
             (|max_starve_timer) ? (max_starve_timer - 16'h001):
                          max_starve_timer             ;
    end
    use_starve_timer    <= |max_starve; // disable starvation timer if max_starve set to all 0's
  end //else: flops not in reset

// non-resetable flops: min non-critical timer, critical run length
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    q_run_length  <= 8'h00;
  end
  else begin
  q_run_length    <= (next_state!=MEMC_GS_Q_ST_CRITICAL)    ? 8'h00                 :
             xact_this_q                             ? (q_run_length + 8'h01):
                                                   q_run_length           ;
end // always: non-resetable flops


//------------------- End Queue FSM --------------------------
`ifdef SNPS_ASSERT_ON
  
//
// check for maximum starve state duration
//
reg[15:0]    max_starve_cnt;    // maximum duration for starving state 

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
                max_starve_cnt <= 16'b0;
        else if (empty | xact_this_q)
                max_starve_cnt <= 16'b0;
// disable coverage collection as this is a check in SVA only       
// VCS coverage off 
        else if (max_starve_cnt == 16'b1111_1111_1111_1111)
                max_starve_cnt <= max_starve_cnt;
// VCS coverage on
        else
                max_starve_cnt <= max_starve_cnt + 1'b1;
end


// staying in nonmal state should not be longer than max_starve
// unless starvation timer is disabled (ie, max_starve=0)
property max_starve_check;
        @(posedge co_yy_clk) disable iff ((~core_ddrc_rstn) || ~(|max_starve))
                ((current_state == MEMC_GS_Q_ST_NORMAL) && (max_starve_cnt >= max_starve) && ~empty) |->
                (next_state == MEMC_GS_Q_ST_CRITICAL);
endproperty

a_gs_q_fsm_max_starve_check: assert property (max_starve_check)
        else $error("%m %t queue fsm should go to critical state", $time);

// checking go2critical be able to trigger FSM go to critical state
property p_go2critical_check;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
                ((current_state == MEMC_GS_Q_ST_NORMAL) && go2critical && ~empty) |->
                (next_state == MEMC_GS_Q_ST_CRITICAL);
endproperty

a_go2critical_check: assert property (p_go2critical_check) 
        else $error("%m %t if go2critical assert, queue fsm should go to critical state", $time);

// checking FSM exit from critical state when empty
property p_exit_critical_when_empty;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
                ((current_state == MEMC_GS_Q_ST_CRITICAL) && empty 
               ) |->
                (next_state == MEMC_GS_Q_ST_NORMAL);
endproperty

a_exit_critical_when_empty : assert property (p_exit_critical_when_empty)  
        else $error("%m %t if queue is empty, queue fsm should exit from critical state", $time);
`endif   // SNPS_ASSERT_ON

endmodule  // gs_global_fsm: global DDR-tracking state machine
