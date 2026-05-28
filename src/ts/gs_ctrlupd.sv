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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_ctrlupd.sv#2 $
// -------------------------------------------------------------------------
// Description:
//                This module is responsible for issuing auto DFI controller update
//                cycles.
//                Auto DFI controller update cycles will be issued any time there is
//                no data being read or written through the PHY.
//                This will always be scheduled in conjuction with a refresh
//                to reduce the total number of cycles wasted.  If no
//                refresh is pending, the auto DFI controller update will be delayed
//                until there is a refresh pending.
//                The sequence of events for issuing auto DFI controller update is
//                as follows:
//                1) DFI controller update timer is started at the programmed
//                   register value.  Any time there is no read or
//                   write data pending, a DFI controller update is indicated
//                   and the timer is reset.
//                   When the DFI controller update timer reached zero,
//                   then proceed to step 2.
//                2) When one or more refreshes is pending to proceed to
//                   step 3.  If a controller update is issued first,
//                   return to step 1.
//                3) Indicate to gs_next_xact that pending refreshes
//                   should be issued and block all reads or writes
//                   from being scheduled.  When there is finally no
//                   read data or write data pending, issue an auto DFI
//                   controller update cycle and return to step 1.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_ctrlupd 
import DWC_ddrctl_reg_pkg::*;
#(
   parameter    MAX_CMD_DELAY       = `UMCTL2_MAX_CMD_DELAY
  ,parameter    CMD_DELAY_BITS      = `UMCTL2_CMD_DELAY_BITS
  ,parameter  FREQ_RATIO        = `MEMC_FREQ_RATIO

 )
 (
//--------------------------- INPUTS AND OUTPUTS -------------------------------
   input                co_yy_clk                         // clock
  ,input                core_ddrc_rstn                    // reset; async, active low
  ,input      [DFI_T_CTRLUPD_INTERVAL_MIN_X1024_WIDTH-1:0]     dh_gs_ctrlupd_min_to_x1024        // min time between controller updates, in units of 1024 cycles
  ,input      [DFI_T_CTRLUPD_INTERVAL_MAX_X1024_WIDTH-1:0]     dh_gs_ctrlupd_max_to_x1024        // max time between controller updates, in units of 1024 cycles
  ,input                dh_gs_ctrlupd                     // cmd issuing ctrlupd
  ,input                dh_gs_dis_auto_ctrlupd
  ,input                dh_gs_dis_auto_ctrlupd_srx
  ,input                dh_gs_ctrlupd_pre_srx
  ,input                exit_selfref                      // self-refresh exit
  ,input                exit_selfref_ready                // controller is ready to exit selfref

  ,input                timer_pulse_x1024                 // pulse every 1024 clocks for controller update timer
  ,input                gs_op_is_ref                      // refresh timer expired at least once
  ,input                rt_gs_empty                       // read tracking pipeline is empty
  ,input                mr_gs_empty                       // write pipeline is empty
  ,input                pi_gs_rd_vld                      // valid read scheduled from PI
  ,input                end_init_ddr                      // goes high when the initialization sequence is done
  ,input                dfilp_ctrlupd_ok
  ,input                   gs_wck_stop_ok
  ,input                   dfi_ctrlmsg_req_busy

  ,output reg           gs_dh_ctrlupd_busy                // If 1: Previous dh_gs_ctrlupd has not been initiated

  ,output reg [DFI_T_CTRLUPD_INTERVAL_MIN_X1024_WIDTH-1:0]     min_ctrlupd_timer                 // timers for inserting auto DFI controller update cycles

  ,input [CMD_DELAY_BITS-1:0] dfi_cmd_delay

  ,output reg           ctrlupd_req                       // request a controller update. PI will stall this until pi_gs_ctrlupd_ok
  ,output               gs_pi_ctrlupd_req                 // request a controller update. PI will stall this until pi_gs_ctrlupd_ok
  ,input                pi_gs_ctrlupd_ok                  // if ctrlupd_req is assesrted, indicates that controller update request is being issued
  ,input                ddrc_dfi_phyupd_ack
  ,input                ddrc_dfi_phymstr_ack
  ,output               gs_pi_data_pipeline_empty         // read or write data in flight

  ,output               gs_pi_wr_data_pipeline_empty
  ,output               gs_pi_rd_data_pipeline_empty

  ,output     [1:0]     gs_dh_ctrlupd_state               // state info for debug bus

  ,input                phy_dfi_ctrlupd_ack1              // ack from PHY

  ,output reg           ddrc_dfi_ctrlupd_req              // control update req to PHY and io_calib

  ,input      [DFI_T_CTRLUP_MIN_WIDTH-1:0]     dh_gs_dfi_t_ctrlup_min            // min timer. duration during which the dfi_ctrlupd_req has to high
  ,input      [DFI_T_CTRLUP_MAX_WIDTH-1:0]     dh_gs_dfi_t_ctrlup_max            // max timer. this is the max time for the dfi_ctrlupd_req will be high, if ack present
  ,input      [DFI_T_CTRL_DELAY_WIDTH-1:0]     reg_ddrc_dfi_t_ctrl_delay         // timer value for DFI tctrl_delay
  ,input      [DFI_T_WRDATA_DELAY_WIDTH-1:0]   reg_ddrc_dfi_t_wrdata_delay       // timer value for DFI twrdata_delay
  ,output     [DFI_T_CTRL_DELAY_WIDTH-1:0]     gs_dfi_t_wrdata_delay_cnt         // counter value for DFI twrdata_delay sent to oter blocks

);

//---------------------------- LOCAL PARAMETERS --------------------------------
// define FSM states
localparam  DFI_CTRLUPD_IDLE              = 2'b00; // initial state;
localparam  DFI_CTRLUPD_REQ_DELAY_WAIT    = 2'b01; // DFI tCTRL_DELAY wait
localparam  DFI_CTRLUPD_REQ_MIN_WAIT      = 2'b10; // Min timer wait
localparam  DFI_CTRLUPD_ACK_LOW_WAIT      = 2'b11; // waiting for ack low and max timer expiration

//------------------------------ WIRES AND REGISTERS ---------------------------
// fixed signals instead of input port
wire            gs_mpsm_ctrlupd_ok = 1'b1;
wire            retry_gs_ctrlupd_ok = 1'b1;

wire            ddrc_dfi_ctrlupd_req_w;   // req signal in the state machine

reg     [1:0]   dfi_ctrlupd_curr_state;   // current state for control update request s/m
reg     [1:0]   dfi_ctrlupd_next_state;   // next state for control update request s/m

reg     [$bits(dh_gs_dfi_t_ctrlup_min)-1:0]   dfi_ctrlup_min_timer;     // min timer flop
reg     [$bits(dh_gs_dfi_t_ctrlup_max)-1:0]   dfi_ctrlup_max_timer;     // max timer flop

wire    [$bits(dh_gs_dfi_t_ctrlup_min)-1:0]   dfi_ctrlup_min_timer_w;   // min timer combo signal
wire    [$bits(dh_gs_dfi_t_ctrlup_max)-1:0]   dfi_ctrlup_max_timer_w;   // max timer combo signal


wire            ctrlupd;

reg     [$bits(dh_gs_ctrlupd_max_to_x1024)-1:0]   max_ctrlupd_timer;        //  in multi-rank configurations
reg [MAX_CMD_DELAY:0] r_mr_gs_empty;            // flopped version of mr_gs_empty
reg             r_dh_gs_dis_auto_ctrlupd;
reg             r_dh_gs_dis_auto_ctrlupd_srx;
wire            ctrlupd_req_w;

wire            ctrlupd_req_nxt;          // issue either ctrlupd type0 or type1 in the subsequent cycle
wire            ctrlupd_req_type0_nxt;    // issue controller update (ctrlupd type 0) in the subsequent cycle
wire            ctrlupd_req_type0_nxt_hp; // issue controller update (ctrlupd type 0) in the subsequent cycle (higher priority than PPT2)
reg             ctrlupd_pending;          // ctrlupd pending
wire            ctrlupd_req_trg;          // ctrlupd trigger

wire            init_done_pulse;          // pulse for one cycle when the controller comes out of initialization
                                          //  this is used to force a ctrlupd to DRAM
wire            data_pipeline_empty;      // indicates that there is read data or write data in flight
                                          //  for previosly-issued reads and writes
reg             end_init_ddr_latched;
reg             r_dh_gs_ctrlupd;

wire                                            type0_sent    = ddrc_dfi_ctrlupd_req && ~ddrc_dfi_ctrlupd_req_w;                                 // negedge of dfi_ctrlupd_req
wire                                            type0_sending = ddrc_dfi_ctrlupd_req                           ;

//-------------------------------- MAIN CODE BLOCK -----------------------------

// make sure there is no write data pending and no read data due back soon
//  "rd_ff" is required because there is one cycle after read is issued before it shows
//  up in RT.
assign gs_pi_ctrlupd_req    = ctrlupd_req;

// pass data pipeline empty to PI - now used to determine
// pi_gs_ctrlupd_ok, tho it was previously used in this block
assign gs_pi_data_pipeline_empty = data_pipeline_empty;

// write data is in flight
// Uses upto MAX_CMD_DELAY to cover worse case of latency through dfi.v block 
wire   wr_data_pipeline_empty = (&r_mr_gs_empty) & mr_gs_empty;

// eitiher read data or write data is in flight
assign data_pipeline_empty    = rt_gs_empty & (~pi_gs_rd_vld) & wr_data_pipeline_empty;

assign gs_pi_wr_data_pipeline_empty = wr_data_pipeline_empty;
assign gs_pi_rd_data_pipeline_empty = rt_gs_empty & (~pi_gs_rd_vld);

// gs_dfi_t_wrdata_delay_cnt calculation
// starts when write data is empty
// value gs_dfi_t_wrdata_delay_cnt used in following sub-blocks:
// - gs_dfilp
// - gs_phyupd
// - gs_ctrlupd (this block)
// These count either largest of gs_dfi_t_wrdata_delay_cnt or
// reg_ddrc_dfi_t_ctrl_delay 

wire [$bits(reg_ddrc_dfi_t_ctrl_delay)-1:0] i_dfi_t_wrdata_delay_cnt_val;
assign i_dfi_t_wrdata_delay_cnt_val = (reg_ddrc_dfi_t_wrdata_delay>{$bits(reg_ddrc_dfi_t_ctrl_delay){1'b0}}) ?
                                                               (reg_ddrc_dfi_t_wrdata_delay-{{($bits(reg_ddrc_dfi_t_ctrl_delay)-1){1'b0}},1'b1}) : 
                                                               {$bits(i_dfi_t_wrdata_delay_cnt_val){1'b0}};

reg [$bits(reg_ddrc_dfi_t_ctrl_delay)-1:0]  i_dfi_t_wrdata_delay_cnt;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_dfi_t_wrdata_delay_cnt_PROC
    if (!core_ddrc_rstn) begin
      i_dfi_t_wrdata_delay_cnt <= {$bits(i_dfi_t_wrdata_delay_cnt){1'b0}};
    end else begin
      if (!wr_data_pipeline_empty) begin
        i_dfi_t_wrdata_delay_cnt <= i_dfi_t_wrdata_delay_cnt_val;
      end else if (i_dfi_t_wrdata_delay_cnt > {$bits(i_dfi_t_wrdata_delay_cnt){1'b0}}) begin
        i_dfi_t_wrdata_delay_cnt <= i_dfi_t_wrdata_delay_cnt - {{($bits(i_dfi_t_wrdata_delay_cnt)-1){1'b0}},1'b1};
      end
    end
  end

          
assign gs_dfi_t_wrdata_delay_cnt = i_dfi_t_wrdata_delay_cnt;   

          
          
// --------
// Ctrlupd request is asserted for the following 7 cases
// --------
// 1. External Controller update request and Initialization is over (future enhancement should remove the init condition - bug 3265)
//    External Controller update should be allowed whenever there is long waits during Init - post_cke, final_wait etc
// 2. Controller update request from Init DDR FSM (before CKE is asserted)
// 3. (High priority) At the end of initialization routine (if internal controller update is not disabled)
// 4. Max Ctrlupd timer has expired, Initialization completed and internal Ctrlupd has not been disabled
// 5. Min Ctrlupd timer has expired, Refresh scheduled, Initialization completed and internal Ctrlupd has not been disabled
// 6. CRC/Parity error detected, Retry is enabled, issue ctrlupd before starting retry
// 7. (High priority) Before or after self-refresh exit (depending on ctrlupd_pre_srx), if dis_auto_ctrlupd_srx is 0 and the special transition SRPD->SR->SRPD due to normal PPT2 is NOT ongoing
// --------
assign ctrlupd_req_type0_nxt= (gs_dh_ctrlupd_busy & ~type0_sending)                                                                               |
                              ((max_ctrlupd_timer=={$bits(max_ctrlupd_timer){1'b0}}) &                (~r_dh_gs_dis_auto_ctrlupd) & end_init_ddr) |
                              ((min_ctrlupd_timer=={$bits(min_ctrlupd_timer){1'b0}}) & gs_op_is_ref & (~r_dh_gs_dis_auto_ctrlupd) & end_init_ddr) |
                              1'b0;
assign ctrlupd_req_type0_nxt_hp=(init_done_pulse & (~r_dh_gs_dis_auto_ctrlupd)) |
                                ((dh_gs_ctrlupd_pre_srx ? exit_selfref_ready : exit_selfref) & (~r_dh_gs_dis_auto_ctrlupd_srx)
                                );

assign ctrlupd_req_nxt        = ctrlupd_req_type0_nxt | ctrlupd_req_type0_nxt_hp;

// Pending ctrlupd_req when dfi_ctrlmsg_req_busy
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    ctrlupd_pending <= {$bits(ctrlupd_pending){1'b0}};
  end
  else if(~dfi_ctrlmsg_req_busy) begin
    ctrlupd_pending <= {$bits(ctrlupd_pending){1'b0}};
  end
  else if(ctrlupd_req_nxt & dfi_ctrlmsg_req_busy) begin
    ctrlupd_pending <= 1'b1;
  end

assign ctrlupd_req_trg =(ctrlupd_req_nxt | ctrlupd_pending) & ~dfi_ctrlmsg_req_busy;

// generating a pulse when the controller comes out of init
assign init_done_pulse = ~end_init_ddr_latched && end_init_ddr;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    min_ctrlupd_timer             <= {$bits(min_ctrlupd_timer){1'b0}};
    max_ctrlupd_timer             <= {$bits(max_ctrlupd_timer){1'b0}};
    r_mr_gs_empty                 <= {MAX_CMD_DELAY+1{1'b0}};
    ctrlupd_req                   <= {$bits(ctrlupd_req){1'b0}};
    end_init_ddr_latched          <= {$bits(end_init_ddr_latched){1'b0}};
    r_dh_gs_dis_auto_ctrlupd      <= {$bits(r_dh_gs_dis_auto_ctrlupd){1'b0}};
    r_dh_gs_dis_auto_ctrlupd_srx  <= {$bits(r_dh_gs_dis_auto_ctrlupd_srx){1'b0}};
  end
  else begin
    // ctrlupd timer is set to register value and counts down with each pulse of the 1024-cycle timer
    // They will be reset once they trigger ctrlupd(type0).
    // ctrlupd(type1) also resets timer as it includes type0 functionality.
    min_ctrlupd_timer     <=  type0_sending                               ? {{($bits(min_ctrlupd_timer)-$bits(dh_gs_ctrlupd_min_to_x1024)){1'b0}},dh_gs_ctrlupd_min_to_x1024}  :
                              (r_dh_gs_dis_auto_ctrlupd)                  ? {{($bits(min_ctrlupd_timer)-$bits(dh_gs_ctrlupd_min_to_x1024)){1'b0}},dh_gs_ctrlupd_min_to_x1024}  :
                              (timer_pulse_x1024 & (|min_ctrlupd_timer))  ? (min_ctrlupd_timer - {{($bits(min_ctrlupd_timer)-1){1'b0}},1'b1}) :
                                                                            min_ctrlupd_timer           ;
    max_ctrlupd_timer     <=  type0_sending                               ? {{($bits(max_ctrlupd_timer)-$bits(dh_gs_ctrlupd_max_to_x1024)){1'b0}},dh_gs_ctrlupd_max_to_x1024}  :
                              (r_dh_gs_dis_auto_ctrlupd)                  ? {{($bits(max_ctrlupd_timer)-$bits(dh_gs_ctrlupd_max_to_x1024)){1'b0}},dh_gs_ctrlupd_max_to_x1024}  :
                              (timer_pulse_x1024 & (|max_ctrlupd_timer))  ? (max_ctrlupd_timer - {{($bits(max_ctrlupd_timer)-1){1'b0}},1'b1}) :
                                                                            max_ctrlupd_timer           ;
    end_init_ddr_latched  <= end_init_ddr | end_init_ddr_latched;

    // empty indictors used to determine when it's safe to do a controller update
    r_mr_gs_empty                 <= {r_mr_gs_empty[MAX_CMD_DELAY-1:0], mr_gs_empty};
    ctrlupd_req                   <= ctrlupd_req_w;
    r_dh_gs_dis_auto_ctrlupd      <= dh_gs_dis_auto_ctrlupd;
    r_dh_gs_dis_auto_ctrlupd_srx  <= dh_gs_dis_auto_ctrlupd_srx;
  end


// AND of ctrlupd_req and ctrlupd_ok. this is when the ctrlupd is ready to send to PHY
assign  ctrlupd       =  ctrlupd_req & (pi_gs_ctrlupd_ok & gs_mpsm_ctrlupd_ok & retry_gs_ctrlupd_ok & ~ddrc_dfi_phyupd_ack & ~ddrc_dfi_phymstr_ack
                                        & dfilp_ctrlupd_ok
                                        & gs_wck_stop_ok
                                       );


assign ctrlupd_req_w  =  ctrlupd_req_trg                                         |
                        (ctrlupd_req & (~ctrlupd)) |
                        (dfi_ctrlupd_next_state==DFI_CTRLUPD_REQ_DELAY_WAIT)     | // keep ctrlupd_req asserted durinig ctrl_wrdata_delay wait
                         ddrc_dfi_ctrlupd_req_w;

// Ctrlupd busy
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    gs_dh_ctrlupd_busy  <= {$bits(gs_dh_ctrlupd_busy){1'b0}};
  end
  else begin
    if (dh_gs_ctrlupd & r_dh_gs_dis_auto_ctrlupd) begin
        gs_dh_ctrlupd_busy  <= 1'b1;
    end else if (type0_sent) begin
        gs_dh_ctrlupd_busy  <= {$bits(gs_dh_ctrlupd_busy){1'b0}};
    end
  end


//------------------------------------------------------------------------------
// DFI Logic
//------------------------------------------------------------------------------


// state information for the debug bus
assign  gs_dh_ctrlupd_state   = dfi_ctrlupd_curr_state;

//-------------------
// ctrl_delay_timer_w
//-------------------
// use larger of gs_dfi_t_wrdata_delay_cnt or reg_ddrc_dfi_t_ctrl_delay
wire [$bits(reg_ddrc_dfi_t_ctrl_delay)-1:0] i_reg_ddrc_dfi_t_ctrl_wrdata_delay;
assign i_reg_ddrc_dfi_t_ctrl_wrdata_delay = (gs_dfi_t_wrdata_delay_cnt>reg_ddrc_dfi_t_ctrl_delay) ? gs_dfi_t_wrdata_delay_cnt : reg_ddrc_dfi_t_ctrl_delay;

// Submtract 1 from register value for use in counter (avoids underflow)
wire [$bits(i_reg_ddrc_dfi_t_ctrl_wrdata_delay)-1:0] i_reg_ddrc_dfi_t_ctrl_wrdata_delay_m1;
assign i_reg_ddrc_dfi_t_ctrl_wrdata_delay_m1 = (i_reg_ddrc_dfi_t_ctrl_wrdata_delay=={$bits(i_reg_ddrc_dfi_t_ctrl_wrdata_delay){1'b0}}) ? 
                                                                                              {$bits(i_reg_ddrc_dfi_t_ctrl_wrdata_delay_m1){1'b0}} : 
                                                                                              (i_reg_ddrc_dfi_t_ctrl_wrdata_delay - {{($bits(i_reg_ddrc_dfi_t_ctrl_wrdata_delay_m1)-1){1'b0}},1'b1});

// Load the timer with the init value changing state into DFI_CTRLUPD_REQ_DELAY_WAIT state
// keep counting down 
// stop decrementing when the counter reaches 0
wire [$bits( i_reg_ddrc_dfi_t_ctrl_wrdata_delay_m1)-1:0] ctrl_wrdata_delay_timer_w;
reg     [$bits(ctrl_wrdata_delay_timer_w)-1:0]   ctrl_wrdata_delay_timer;

assign  ctrl_wrdata_delay_timer_w = ((dfi_ctrlupd_next_state==DFI_CTRLUPD_REQ_DELAY_WAIT) && (dfi_ctrlupd_next_state!=dfi_ctrlupd_curr_state)) 
                                                           ? i_reg_ddrc_dfi_t_ctrl_wrdata_delay_m1 :
                                                          (|ctrl_wrdata_delay_timer) ? (ctrl_wrdata_delay_timer - {{($bits(ctrl_wrdata_delay_timer)-1){1'b0}},1'b1}) 
                                                                                     : ctrl_wrdata_delay_timer;


// All the flops associated with the DFI ctrlupd logic
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
     ctrl_wrdata_delay_timer<= {$bits(ctrl_wrdata_delay_timer){1'b0}};
  end
  else begin
     ctrl_wrdata_delay_timer<= ctrl_wrdata_delay_timer_w;
  end

//-----------------------
// ctrlupd_req minimum interval timer
//-----------------------
//            ___________ <- 24 cycle at least -> _____
// ctrlupd_req           \_______________________/

localparam  [5-1:0] ctrlupd_req_min_interval = 5'd24;
logic       [5-1:0] ctrlupd_req_min_interval_timer;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    ctrlupd_req_min_interval_timer <= {$bits(ctrlupd_req_min_interval_timer){1'b0}};
  end else begin
    ctrlupd_req_min_interval_timer <=
      ddrc_dfi_ctrlupd_req && ~ddrc_dfi_ctrlupd_req_w ? ctrlupd_req_min_interval            : // ctrlupd_req deassertion
      |ctrlupd_req_min_interval_timer                 ? ctrlupd_req_min_interval_timer-5'd1 : // not expired -> decrement
                                                        ctrlupd_req_min_interval_timer;       // expired -> stay as 0
  end
end

//-----------------------
// dfi_ctrlupd_min_timer
//-----------------------
// load dfi_ctrup_*_timer(for min and max) when changing from DFI_CTRLUPD_REQ_DELAY_WAIT to DFI_CTRLUPD_REQ_MIN_WAIT states
wire dfi_ctrlup_timer_load = ((dfi_ctrlupd_next_state==DFI_CTRLUPD_REQ_MIN_WAIT) && (dfi_ctrlupd_next_state!=dfi_ctrlupd_curr_state)) ? 1 : 0;

// Load the timer with the init value when dfi_ctrlup_timer_load is generated
// as long as the counter is not zero, keep counting down when the dfi_ctrlupd_req is present
// stop decrementing when the counter reaches 0.
// We use "+1" to extend the dfi_ctrlupd_req by a cycle.  This is needed in cases where dfi_ctrlupd_req is registered twice in the dfi block,
// to ensure that it is not deasserted too early in the event of a dfi_ctrlupd_ack being received just before dfi_t_ctrlup_min expires.
//assign  dfi_ctrlup_min_timer_w = (dfi_ctrlup_timer_load)  ? ((dh_gs_dfi_t_ctrlup_min + 10'b1) + {9'b0, dfi_cmd_delay_2r})      :
assign  dfi_ctrlup_min_timer_w = (dfi_ctrlup_timer_load)  ? (dh_gs_dfi_t_ctrlup_min + {{($bits(dfi_ctrlup_min_timer_w)-1){1'b0}},1'b1} 
                                                            + {{($bits(dfi_ctrlup_min_timer_w)-$bits(dfi_cmd_delay)){1'b0}}, dfi_cmd_delay}) :
                                 ((|dfi_ctrlup_min_timer) ? (dfi_ctrlup_min_timer - {{($bits(dfi_ctrlup_min_timer)-1){1'b0}},1'b1}) :
                                                             dfi_ctrlup_min_timer);

//-----------------------
// dfi_ctrlupd_max_timer
//-----------------------
// Load the timer with the init value when dfi_ctrlup_timer_load is generated
// as long as the counter is not zero, keep counting down when the dfi_ctrlupd_req is present
// stop decrementing when the counter reaches 0
// reset the counter to 0, if the dfi_ctrlupd_req is de-asserted before the count reaches 0
assign  dfi_ctrlup_max_timer_w = (dfi_ctrlup_timer_load) ? (dh_gs_dfi_t_ctrlup_max - {{($bits(dh_gs_dfi_t_ctrlup_max)-1){1'b0}},1'b1}) :
        ((|dfi_ctrlup_max_timer) ? 
                   (ddrc_dfi_ctrlupd_req ? (dfi_ctrlup_max_timer - {{($bits(dfi_ctrlup_max_timer_w)-1){1'b0}},1'b1}) : {$bits(dfi_ctrlup_max_timer_w){1'b0}}) :
              dfi_ctrlup_max_timer);

assign  ddrc_dfi_ctrlupd_req_w =
  dfi_ctrlupd_next_state==DFI_CTRLUPD_REQ_MIN_WAIT ||
  dfi_ctrlupd_next_state==DFI_CTRLUPD_ACK_LOW_WAIT;
always @ (*) begin
  //ccx_fsm:;dfi_ctrlupd_curr_state;DFI_CTRLUPD_REQ_DELAY_WAIT->DFI_CTRLUPD_IDLE;Resetting DDRCTL is required to cover.
  case (dfi_ctrlupd_curr_state)

     // --------------
     // go to request_min_wait state when ctrlupd is issued
     // if MEMC_DDR4 is defined, look for leveling before going to min_wait state
     // --------------
     DFI_CTRLUPD_IDLE  : begin
        if (ctrlupd) begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_REQ_DELAY_WAIT;  
        end else begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_IDLE;  
        end
     end

     // --------------
     // --------------
     DFI_CTRLUPD_REQ_DELAY_WAIT : begin
        if (ctrl_wrdata_delay_timer=={$bits(ctrl_wrdata_delay_timer){1'b0}} &&
            ctrlupd_req_min_interval_timer=={$bits(ctrlupd_req_min_interval_timer){1'b0}} &&
            ~ddrc_dfi_phyupd_ack &&
            ~ddrc_dfi_phymstr_ack) begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_REQ_MIN_WAIT;
        end else begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_REQ_DELAY_WAIT;
        end        
     end

     // --------------
     // stay in this state until the min timer expires
     // once it expires, check if either ack is present
     // if ack is present, go to ack_low_wait state
     // if ack is not present, deassert the request and go to IDLE
     // --------------
     DFI_CTRLUPD_REQ_MIN_WAIT : begin
        if (|dfi_ctrlup_min_timer) begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_REQ_MIN_WAIT;
        end else if (phy_dfi_ctrlupd_ack1) begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_ACK_LOW_WAIT;
        end else begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_IDLE;
        end
     end


     // --------------
     // stay in this state until both ack's are low OR
     // until the max timer expires
     // once any of the above 2 conditions are reached, make the request low
     // and go to idle state
     // --------------
     // DFI_CTRLUPD_ACK_LOW_WAIT : begin
     default                 : begin // DFI_CTRLUPD_ACK_LOW_WAIT
        if (dfi_ctrlup_max_timer == 10'h0) begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_IDLE;
        end else if (~(phy_dfi_ctrlupd_ack1)) begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_IDLE;
        end else begin
           dfi_ctrlupd_next_state = DFI_CTRLUPD_ACK_LOW_WAIT;
        end
     end

  endcase
end

//spyglass disable_block W528
//SMD: Variable r_dh_gs_ctrlupd set but never read
//SJ: Used in RTL assertion

// All the flops associated with the DFI ctrlupd logic
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
     dfi_ctrlup_min_timer   <= {$bits(dfi_ctrlup_min_timer){1'b0}};
     dfi_ctrlup_max_timer   <= {$bits(dfi_ctrlup_max_timer){1'b0}};
     dfi_ctrlupd_curr_state <= {$bits(dfi_ctrlupd_curr_state){1'b0}};
     ddrc_dfi_ctrlupd_req   <= {$bits(ddrc_dfi_ctrlupd_req){1'b0}};
     r_dh_gs_ctrlupd        <= {$bits(r_dh_gs_ctrlupd){1'b0}};
  end
  else begin
     dfi_ctrlup_min_timer   <= dfi_ctrlup_min_timer_w;
     dfi_ctrlup_max_timer   <= dfi_ctrlup_max_timer_w;
     dfi_ctrlupd_curr_state <= dfi_ctrlupd_next_state;
     ddrc_dfi_ctrlupd_req   <= ddrc_dfi_ctrlupd_req_w;
     r_dh_gs_ctrlupd        <= dh_gs_ctrlupd;
  end
//spyglass enable_block W528

`ifdef SNPS_ASSERT_ON
reg[$bits(dh_gs_ctrlupd_min_to_x1024)-1:0]        ctrlupd_to_min_cnt_x1024;          // controller update minimum time out counter
reg[9:0]        cnt_1024;                          // counter up to 1024
reg             gs_pi_ctrlupd_reg;
reg             dh_gs_dis_ctrlupd_r2;
reg             dh_gs_dis_ctrlupd_r3;
reg             ctrlupd_init_en_r;
reg             ctrlupd_init_en;
wire            ctrlupd_init_en_nxt;  // enabling the ctrlupd generation due to end_init_ddr
                                      // goes high when init is over and goes low with the first ctrlupd
// set this when init is done, and reset when first ctrlupd is issued
assign ctrlupd_init_en_nxt = init_done_pulse | (ctrlupd_init_en & (~gs_pi_ctrlupd_req));

  wire          retry_gs_ctrlupd_req = 1'b0;

wire valid_ctrlupd;
reg curr_ctrlupd_min_to_x1024;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
                dh_gs_dis_ctrlupd_r2   <= {$bits(dh_gs_dis_ctrlupd_r2){1'b0}};
                dh_gs_dis_ctrlupd_r3   <= {$bits(dh_gs_dis_ctrlupd_r3){1'b0}};
                gs_pi_ctrlupd_reg      <= {$bits(gs_pi_ctrlupd_reg){1'b0}};
                ctrlupd_init_en        <= {$bits(ctrlupd_init_en){1'b0}};
                ctrlupd_init_en_r      <= {$bits(ctrlupd_init_en_r){1'b0}};
        end
        else begin
                dh_gs_dis_ctrlupd_r2   <= r_dh_gs_dis_auto_ctrlupd;
                dh_gs_dis_ctrlupd_r3   <= dh_gs_dis_ctrlupd_r2;
                gs_pi_ctrlupd_reg      <= gs_pi_ctrlupd_req;
                ctrlupd_init_en        <= ctrlupd_init_en_nxt;
                ctrlupd_init_en_r      <= ctrlupd_init_en;
        end
end

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)
                cnt_1024 <= {$bits(cnt_1024){1'b0}};
        else
                cnt_1024 <= cnt_1024 + {{($bits(cnt_1024)-1){1'b0}},1'b1};
end

// count up every 1024 cycles, starting from each controller update
// (saturates at max value)
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)                                    // reset counter to maximum possible value
                ctrlupd_to_min_cnt_x1024 <= dh_gs_ctrlupd_min_to_x1024;
        else if (gs_pi_ctrlupd_req & ~(pi_gs_ctrlupd_ok & gs_mpsm_ctrlupd_ok & retry_gs_ctrlupd_ok & dfilp_ctrlupd_ok
                                       & gs_wck_stop_ok
                )) // on rising edge of gs_pi_ctrlupd, reset couting
                ctrlupd_to_min_cnt_x1024 <= {$bits(ctrlupd_to_min_cnt_x1024){1'b0}};
  // disable coverage collection as this is a saturaion check in SVA only       
  // VCS coverage off 
        else if (ctrlupd_to_min_cnt_x1024 == {$bits(ctrlupd_to_min_cnt_x1024){1'b1}})      // saturate counter
                ctrlupd_to_min_cnt_x1024 <= ctrlupd_to_min_cnt_x1024;
  // VCS coverage on 
        else if (cnt_1024 == {$bits(cnt_1024){1'b1}})                  // increment counter every 1024 cycles
                ctrlupd_to_min_cnt_x1024 <= ctrlupd_to_min_cnt_x1024 + {{($bits(ctrlupd_to_min_cnt_x1024)-1){1'b0}},1'b1};
end

reg exit_selfref_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn)
    exit_selfref_r <= {$bits(exit_selfref_r){1'b0}};
  else
    exit_selfref_r <= exit_selfref;
end

reg exit_selfref_ready_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn)
    exit_selfref_ready_r <= {$bits(exit_selfref_ready_r){1'b0}};
  else
    exit_selfref_ready_r <= exit_selfref_ready;
end



assign mask_min_check = 0;


assign valid_ctrlupd = ((gs_pi_ctrlupd_req & ~gs_pi_ctrlupd_reg & ~dh_gs_dis_auto_ctrlupd & end_init_ddr  & (~exit_selfref_r) & 
                       (~exit_selfref_ready_r) & (~retry_gs_ctrlupd_req) & (~mask_min_check)) & ~(ctrlupd_init_en | ctrlupd_init_en_r));

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn)                                    // reset counter to initial value of register
                curr_ctrlupd_min_to_x1024 <= dh_gs_ctrlupd_min_to_x1024;
        else if (valid_ctrlupd)                                 // get new value of ctrupd min time
                curr_ctrlupd_min_to_x1024 <= dh_gs_ctrlupd_min_to_x1024;
end



// ctrlupd minimum time out check: after a controller update pulse is issued, the next one must be curr_ctrlupd_min_to_x1024 later.
// this check is exlcuded for the ctrlupd issued due to the completion of initialization or exiting self-refresh
property ctrlupd_min_to_check;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn | r_dh_gs_ctrlupd) 
                             valid_ctrlupd |-> 
                (ctrlupd_to_min_cnt_x1024 >= ((curr_ctrlupd_min_to_x1024 == {$bits(curr_ctrlupd_min_to_x1024){1'b0}}) ? {$bits(ctrlupd_to_min_cnt_x1024){1'b0}} : (curr_ctrlupd_min_to_x1024 - {{($bits(ctrlupd_to_min_cnt_x1024)-1){1'b0}},1'b1})));
endproperty

a_ctrlupd_min_to_check: assert property (ctrlupd_min_to_check)  //
        else $error("%m %t two controller updates are too close to each other", $time);



`endif   // SNPS_ASSERT_ON

endmodule // gs_ctrlupd
