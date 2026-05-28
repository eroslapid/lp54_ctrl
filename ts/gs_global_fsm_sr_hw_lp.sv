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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_global_fsm_sr_hw_lp.sv#2 $
// -------------------------------------------------------------------------
// Description:
//
// gs_global_fsm - Global Scheduler
// This block implements the finite state machine responsible for tracking the
// global state of the DDR1/2 DRAM.  States are:
//  * init sequence
//  * "normal" (read/write) state
//  * self-refresh
// This blocks also chooses read mode/write mode and implements all
// starvations-avoidance state machines and indicates when to prefer low
// priority reads accordingly.
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
//
// Module that controls generation of Self Refresh Entry/Exit and
// responds to Hardare Low Power Interface
// 
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_global_fsm_sr_hw_lp 
import DWC_ddrctl_reg_pkg::*;
#(
//------------------------------- PARAMETERS ----------------------------------
   parameter        BCM_VERIF_EN        = 1
  ,parameter        BCM_DDRC_N_SYNC     = 2

  ,parameter        NPORTS              = 1 // no. of ports (for cactive_in_ddrc width) gets overwritten by toplevel
  ,parameter [16:0] A_SYNC_TABLE        = 17'h1ffff

  ,parameter        CMD_DELAY_BITS      = `UMCTL2_CMD_DELAY_BITS

  ,parameter        FSM_STATE_WIDTH     = 5

  ,parameter    SELFREF_SW_WIDTH_INT = SELFREF_SW_WIDTH
  ,parameter    SELFREF_EN_WIDTH_INT = SELFREF_EN_WIDTH
  ,parameter    SELFREF_TYPE_WIDTH_INT = SELFREF_TYPE_WIDTH
  ,parameter        NUM_RANKS           = 1
)
(
//--------------------------- INPUTS AND OUTPUTS -------------------------------
  // clk/rst
   input                          co_yy_clk
  ,input                          core_ddrc_rstn
  ,output reg    [NUM_RANKS-1:0]  bsm_clk_en                      // Clock enable for bsm instances
  ,input         [BSM_CLK_ON_WIDTH-1:0] bsm_clk_on                // bsm_clk always on

  // signals from top
  ,input [SELFREF_SW_WIDTH_INT-1:0]   reg_ddrc_selfref_sw
  ,input                          reg_ddrc_hw_lp_en
  ,input                          reg_ddrc_hw_lp_exit_idle_en
  ,input                          startup_in_self_ref
  ,output [SELFREF_TYPE_WIDTH_INT-1:0]ddrc_reg_selfref_type
  ,input                          ih_busy
  ,input                          hif_cmd_valid
  ,input  [DFI_T_CTRL_DELAY_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrl_delay
  ,input                          phy_dfi_phyupd_req
  ,input                          phy_dfi_phymstr_req
  ,input                          reg_ddrc_dfi_phymstr_en
  ,input                          reg_ddrc_dfi_phyupd_en
  ,input                          cactive_in_ddrc_sync_or
  ,input  [NPORTS-1:0]            cactive_in_ddrc_async
  ,input                          csysreq_ddrc
  ,output                         csysreq_ddrc_mux
  ,output                         csysack_ddrc
  ,output                         cactive_ddrc

  ,input                          load_mr_norm_required_1bit

  ,input  [FSM_STATE_WIDTH-1:0]   gsfsm_next_state
  ,input                          gsfsm_state_selfref_ent_dfilp
  ,input  [DFI_TLP_RESP_WIDTH-1:0]reg_ddrc_dfi_tlp_resp
  ,input  [CMD_DELAY_BITS-1:0]    dfi_cmd_delay
  ,input                          lpddr_dev

  ,input                          gsfsm_idle
  ,input  [SELFREF_EN_WIDTH_INT-1:0]      dh_gs_selfref_en
  ,input  [SELFREF_TO_X32_WIDTH-1:0]  reg_ddrc_selfref_to_x32
  ,input  [HW_LP_IDLE_X32_WIDTH-1:0]  reg_ddrc_hw_lp_idle_x32
  ,input                          timer_pulse_x32

  ,output                         gsfsm_sr_entry_req
  ,output                         gsfsm_sr_exit_req

  ,output                         gsfsm_sr_hw_lp_pd_cs_exit
  ,output                         gsfsm_sr_co_if_stall
  ,input                          gs_phymstr_sre_req
  ,input                          dh_gs_dis_cam_drain_selfref
  ,output                         gsfsm_sr_dis_dq
  ,output                         gs_bs_sre_stall
  ,output                         gs_bs_sre_hw_sw
  ,output reg                     gsfsm_srpd_to_sr
  ,output reg                     gsfsm_sr_no_pd_to_srx
  ,input                          dh_gs_lpddr4_sr_allowed
);

//---------------------------- LOCAL PARAMETERS --------------------------------
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

// if changing, check ddrc_reg_selfref_type generation too as uses
// sr_st_curr[5] for SR_ST_SR_ASR
// sr_st_curr[4] for SR_ST_SR_HW_SW
localparam SR_ST_SIZE             = 9;
localparam SR_ST_RST_INIT         = 9'b000000001;
localparam SR_ST_NORM_PD          = 9'b000000010;
localparam SR_ST_SRE_HW_SW        = 9'b000000100;
localparam SR_ST_SRE_ASR          = 9'b000001000;
localparam SR_ST_SR_HW_SW         = 9'b000010000;
localparam SR_ST_SR_ASR           = 9'b000100000;
localparam SR_ST_SRX              = 9'b001000000;
localparam SR_ST_SRE_HW_SW_STALL  = 9'b010000000;
localparam SR_ST_DSM              = 9'b100000000;


//------------------------------------ WIRES/REGS -----------------------------------

wire                 i_csysreq_ddrc_mux;
reg [SR_ST_SIZE-1:0] sr_st_curr, sr_st_nxt;


wire dh_gs_ddr4;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
assign dh_gs_ddr4 = 1'b0;
//spyglass enable_block W528

//------------------------------------ LOGIC -----------------------------------


//
// cactive_in_ddrc/csysreq_ddrc related signals
//

wire i_cactive_in_ddrc_sync_or = cactive_in_ddrc_sync_or;

// Select the unregistered input signal as there is no output
// directly driven by this signal
// It will be registered twice before acknoledging the request  
assign i_csysreq_ddrc_mux = csysreq_ddrc;

assign csysreq_ddrc_mux = i_csysreq_ddrc_mux;

//------------------------------------------------------------
// Clock removal for bsm 
//------------------------------------------------------------
// index of CLKGATECTL.bsm_clk_on
localparam BSM_CLK_ON_RANKS = 0;
localparam BSM_CLK_ON_INIT  = 1;
localparam BSM_CLK_ON_SR    = 2;
localparam BSM_CLK_ON_SRPD  = 3;
localparam BSM_CLK_ON_PD    = 4;
localparam BSM_CLK_ON_DSM   = 5;
// clock enable signal
wire bsm_clk_en_w = ~(
// list of clock DISABLE condition
       (gsfsm_next_state==GS_ST_RESET                        ) ||
       (gsfsm_next_state==GS_ST_INIT_DDR    && ~bsm_clk_on[BSM_CLK_ON_INIT]) ||
//     (gsfsm_next_state==GS_ST_SELFREF_ENT2&& ~bsm_clk_on[BSM_CLK_ON_SR  ]) ||
       (gsfsm_next_state==GS_ST_SELFREF     && ~bsm_clk_on[BSM_CLK_ON_SRPD]) ||
       (gsfsm_next_state==GS_ST_SELFREF_EX1 && ~bsm_clk_on[BSM_CLK_ON_SR  ]) ||
//     (gsfsm_next_state==GS_ST_SELFREF_EX2 && ~bsm_clk_on[BSM_CLK_ON_SR  ]) ||
      ((gsfsm_next_state==GS_ST_POWERDOWN   && ~bsm_clk_on[BSM_CLK_ON_PD  ]) && csysreq_ddrc) ||
       (gsfsm_next_state==GS_ST_DSM         && ~bsm_clk_on[BSM_CLK_ON_DSM ])
    );

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if(!core_ddrc_rstn) begin
    bsm_clk_en <= {NUM_RANKS{1'b1}};
  end else begin
    bsm_clk_en <= {NUM_RANKS{bsm_clk_en_w}}
    ;
  end
end


wire i_csysreq_ddrc = i_csysreq_ddrc_mux;

// register csysreq_ddrc before using it
reg i_csysreq_ddrc_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_csysreq_ddrc_r_PROC
  if(!core_ddrc_rstn) begin
    i_csysreq_ddrc_r <= 1'b1;
  end else begin
    i_csysreq_ddrc_r <= i_csysreq_ddrc;
  end 
end

reg i_csysreq_ddrc_r2;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_csysreq_ddrc_r2_PROC
  if(!core_ddrc_rstn) begin
    i_csysreq_ddrc_r2 <= 1'b1;
  end else begin
    i_csysreq_ddrc_r2 <= i_csysreq_ddrc_r;
  end 
end


// falling edge detection on csysreq_ddrc
// denotes a request to move to Low Power
// Only perform HW entry if enabled via software
// Only perform HW entry if cactive_in_ddrc==0 && ih_busy==0
// i.e. cactive_in_ddrc=0 if no new core commands and
// ih_busy=0 if CAM is empty
wire i_hw_e_int = (!i_csysreq_ddrc &&  i_csysreq_ddrc_r) ? reg_ddrc_hw_lp_en : 0;

wire i_hw_e = (!i_cactive_in_ddrc_sync_or && (!ih_busy) & (~gs_phymstr_sre_req)                              ) ? i_hw_e_int : 0;

// rising edge detection on csysreq_ddrc
wire i_hw_x = ( i_csysreq_ddrc && (!i_csysreq_ddrc_r)) ? 1 : 0;
// Store a i_hw_e condtion as 1 if it was successfully accepted
// used to exit from attempting self refresh if reg_ddrc_selfref_sw=0  while trying to move to Self Refresh
reg i_hw_e_stored;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_hw_e_stored_PROC
  if(!core_ddrc_rstn) begin
    i_hw_e_stored <= 1'b0;
  end else begin
    if (i_hw_e) begin
      if (sr_st_nxt==SR_ST_SRE_HW_SW_STALL || sr_st_nxt==SR_ST_SR_HW_SW) begin 
        i_hw_e_stored <= 1'b1;
      end else begin
        i_hw_e_stored <= 1'b0;
      end
    end else if (sr_st_nxt==SR_ST_SRX || sr_st_nxt==SR_ST_NORM_PD || sr_st_nxt==SR_ST_SRE_ASR) begin
      i_hw_e_stored <= 1'b0;
    end
    
  end 
end

reg i_hw_x_stored;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_hw_x_stored_PROC
  if(!core_ddrc_rstn) begin
    i_hw_x_stored <= 1'b0;
  end else begin
    if (i_hw_x && sr_st_nxt==SR_ST_SR_HW_SW) begin 
      i_hw_x_stored <= 1'b1;
    end else if (sr_st_nxt==SR_ST_SRX) begin
      i_hw_x_stored <= 1'b0;
    end
    
  end 
end

// signal indicating that HW LP i/f is enabled
reg i_hw_e_to_x;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_hw_e_to_x_PROC
   if(!core_ddrc_rstn) begin
      i_hw_e_to_x <= 1'b0;
   end else begin
      if (i_hw_e) begin
         i_hw_e_to_x <= 1'b1;
      end else if(i_hw_x) begin
         i_hw_e_to_x <= 1'b0;
      end else begin
         i_hw_e_to_x <= i_hw_e_to_x;
      end
   end
end

wire i_sre_dly_cnt_zero;
reg [6:0] i_sre_dly_cnt;

// set counter when entering SR state for first time i.e. SR_ST_SR_ASR or SR_ST_SR_HW_SW
// does not set if moving SR_ST_SR_ASR -> SR_ST_SR_HW_SW
wire i_sre_dly_cnt_set = (((sr_st_nxt==SR_ST_SR_HW_SW) && ((sr_st_curr==SR_ST_SRE_ASR) || (sr_st_curr==SR_ST_SRE_HW_SW))) || 
        ((sr_st_nxt==SR_ST_SR_ASR) && sr_st_curr==SR_ST_SRE_ASR)) ? 1'b1 : 1'b0;

// counts reg_ddrc_dfi_t_ctrl_delay or reg_ddrc_dfi_tlp_resp + dfi_cmd_delay + 8 (8 is chosen as a safe margin for
// time for SRE to appear on DFI or dfi_lp_ctrl_req is deasserted when the PHY did not respond and few extra cycles for safety)
wire [$bits(reg_ddrc_dfi_tlp_resp)-1:0] i_sre_wait_val;
wire [$bits(i_sre_wait_val)+1:0] i_sre_dly_cnt_val; 

assign  i_sre_wait_val = (reg_ddrc_dfi_tlp_resp > reg_ddrc_dfi_t_ctrl_delay) ? reg_ddrc_dfi_tlp_resp : reg_ddrc_dfi_t_ctrl_delay;
assign i_sre_dly_cnt_val = ({{($bits(i_sre_dly_cnt_val)-$bits(i_sre_wait_val)){1'b0}}, i_sre_wait_val} + {{($bits(i_sre_dly_cnt_val)-$bits(dfi_cmd_delay)){1'b0}}, dfi_cmd_delay} + {{($bits(i_sre_dly_cnt_val)-4){1'b0}},4'b1000});

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_sre_dly_cnt_PROC
  if(!core_ddrc_rstn) begin
    i_sre_dly_cnt <= {$bits(i_sre_dly_cnt){1'b0}};
  end else begin   
    if (i_sre_dly_cnt_set) begin
      i_sre_dly_cnt <= {{($bits(i_sre_dly_cnt)-$bits(i_sre_dly_cnt_val)){1'b0}},i_sre_dly_cnt_val};
    end else if (!i_sre_dly_cnt_zero) begin
      i_sre_dly_cnt <= i_sre_dly_cnt - {{($bits(i_sre_dly_cnt)-1){1'b0}},1'b1};
    end
  end
end


assign i_sre_dly_cnt_zero = (i_sre_dly_cnt==0) ? 1 : 0;

wire i_sre_dly_flag = (!i_sre_dly_cnt_zero) || (i_sre_dly_cnt_set) ||
                                     (gsfsm_state_selfref_ent_dfilp);

// delay csysack_ddrc setting if in SR for a no. of cycles via i_sre_dly_cnt_zero/i_sre_dly_cnt_set
reg i_csysack_ddrc_int;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_csysack_ddrc_int_PROC
  if(!core_ddrc_rstn) begin
    i_csysack_ddrc_int <= 1'b1;
  end else begin   
    
    if (!((sr_st_nxt==SR_ST_SRE_HW_SW) || (i_hw_x && sr_st_nxt==SR_ST_SR_HW_SW) ||
          (i_hw_x_stored)              || (sr_st_nxt==SR_ST_SRX) ||
    i_sre_dly_flag ) ) begin
      i_csysack_ddrc_int <= i_csysreq_ddrc_r;     
    end
  end 
end

wire   i_csysack_ddrc;
reg i_csysack_ddrc_r;

// i_cactive_ddrc_hw_e_rej=1 when a HW LP entry is being rejected
// i_cactive_ddrc_hw_e_rej=0 one cycle after csysack_ddrc goes low
// This is cover issues of cactive_ddrc going low between
// csysreq_ddrc going low and csysack_ddrc going low, 
// even though HW LP entry was rejected
// e.g.
// Covers the issue of cactive_in_ddrc going low, with ih_busy=0, 
// in between csysreq_ddrc going low and csysack_ddrc going low
// cactive_ddrc low at time => results in clocks being removed even though HW LP request was
// rejected
// Another example covered by this would be i_cactive_ddrc_idle going low in between
// a rejected csysreq_ddrc going low and corresponding csysack_ddrc going
// low
reg i_cactive_ddrc_hw_e_rej;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_cactive_ddrc_hw_e_rej_PROC
  if(!core_ddrc_rstn) begin
    i_cactive_ddrc_hw_e_rej <= 1'b0;
  end else begin   
    if (i_hw_e_int && (!i_hw_e)) begin
      i_cactive_ddrc_hw_e_rej <= 1'b1;
    end else if (!i_csysack_ddrc && i_csysack_ddrc_r) begin
      i_cactive_ddrc_hw_e_rej <= 1'b0;
    end
  end
end


// Acknowledge is delayed version of request signal if hardware low power signals are not 
// enabled, otherwise they are defined by signal i_csysack_ddrc_int
assign i_csysack_ddrc = (reg_ddrc_hw_lp_en) ? i_csysack_ddrc_int : i_csysreq_ddrc_r2;

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_csysack_ddrc_r_PROC
  if(!core_ddrc_rstn) begin
    i_csysack_ddrc_r <= 1'b1;
  end else begin
    i_csysack_ddrc_r <= i_csysack_ddrc;    
  end 
end

// drive output from register
assign csysack_ddrc = i_csysack_ddrc_r;

// SW entry is level sensitive
wire i_sw_e = reg_ddrc_selfref_sw
              ;
              
// SW entry masked by PHY Master request
// - masking not added to i_sw_e directly becasue transition from SR_HW_SW to SRX should happen only
// if SW selfref is dropped; by masking it SR_HW_SW -> SRX transition happens unexpectedly
wire i_sw_e_phymstr_mask = i_sw_e & (~gs_phymstr_sre_req);

wire  i_sw_e_ih_idle = ~ih_busy & i_sw_e_phymstr_mask;


// SR entry due to PHY Master reqeust
wire i_phymstr_e = gs_phymstr_sre_req 
                   ;

//
// Auto Self Refresh/Auto cactive related timers
//


wire i_asr_idle_states = ((sr_st_nxt == SR_ST_NORM_PD) || 
                          (sr_st_nxt == SR_ST_SRE_ASR) ||
                          (sr_st_nxt == SR_ST_SR_ASR) ) ? 1 : 0;
      
// auto cactive counter only in NORM_PD or SRE_ASR or SR_ST_SR_ASR, same as i_asr_idle_states
wire i_cactive_ddrc_idle_states = i_asr_idle_states;

wire i_cactive_ddrc_idle_cnt_val_load = ((!i_cactive_ddrc_idle_states) || (!gsfsm_idle)) ? 1 : 0;

                                 
reg [11:0] i_cactive_ddrc_idle_cnt;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_cactive_ddrc_idle_cnt_PROC
  if(!core_ddrc_rstn) begin
     i_cactive_ddrc_idle_cnt <= 12'hFFF;
  end else begin
    if (i_cactive_ddrc_idle_cnt_val_load) begin
      i_cactive_ddrc_idle_cnt <= reg_ddrc_hw_lp_idle_x32;
    end else if (i_cactive_ddrc_idle_cnt>0) begin
      if (timer_pulse_x32) begin
        i_cactive_ddrc_idle_cnt <= i_cactive_ddrc_idle_cnt - 1;
      end
    end        
  end 
end


// disable i_cactive_ddrc_idle if reg_ddrc_hw_lp_idle_x32 is all zeroes
// or if reg_ddrc_hw_lp_en=0
wire i_cactive_ddrc_idle_en =(reg_ddrc_hw_lp_idle_x32!=0) ? reg_ddrc_hw_lp_en : 0;

// only set if i_cactive_ddrc_idle_cnt==0
wire i_cactive_ddrc_idle_cnt_zero = (i_cactive_ddrc_idle_cnt==0) ? 1 : 0;

// AND of both conditions => set i_cactive_ddrc_idle=0
// Otherwise              => set i_cactive_ddrc_idle=i_cactive_ddrc_idle_en
// as i_cactive_ddrc_idle=1 if reg_ddrc_hw_lp_idle_x32==0
wire i_cactive_ddrc_idle = (i_cactive_ddrc_idle_en && i_cactive_ddrc_idle_cnt_zero) ? 0 : 1;


// exit from following immediately if any bit cactive_in_ddrc goes high
// and this feature has been enabled in SW - hw_lp_exit_idle_en (hw_lp_en=1 needs to be set too):
// - Auto Self Refresh
// - Power Down
// - Clock Stop
wire i_hw_lp_sr_pd_cs_exit = i_cactive_in_ddrc_sync_or & reg_ddrc_hw_lp_exit_idle_en & reg_ddrc_hw_lp_en;

// reset counter if:
// - not in NORM_PD or SRE_ASR or SR_ASR &&
// - not idle &&
// - Any bit of cactive_in_ddrc is high and logic for ASR exit is enabled
wire i_asr_idle_cnt_val_load = ((!i_asr_idle_states) || (!gsfsm_idle) || i_hw_lp_sr_pd_cs_exit) ? 1 : 0;

reg [$bits(reg_ddrc_selfref_to_x32)-1:0] i_asr_idle_cnt;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_asr_idle_cnt_PROC
  if(!core_ddrc_rstn) begin
     i_asr_idle_cnt <= {$bits(i_asr_idle_cnt){1'b1}};
  end else begin
    if (i_asr_idle_cnt_val_load) begin     
      i_asr_idle_cnt <= reg_ddrc_selfref_to_x32;
    end else if (i_asr_idle_cnt>{$bits(i_asr_idle_cnt){1'b0}}) begin
      if (timer_pulse_x32) begin
        i_asr_idle_cnt <= i_asr_idle_cnt - {{($bits(i_asr_idle_cnt)-1){1'b0}},1'b1};
      end
    end        
  end 
end

// Auto Self Refresh is enabled counter has reached all zeroes and 
// counter is not being loaded i.e. gsfsm_idle && !i_hw_lp_sr_pd_cs_exit
wire i_asr_en_idle = ((i_asr_idle_cnt=={$bits(i_asr_idle_cnt){1'b0}}) && gsfsm_idle && (!i_hw_lp_sr_pd_cs_exit)) ? 1 : 0;
   
// Auto Self Refresh is attempted if:
// - timer has expire - i_asr_en_idle
// - enabled via SW - dh_gs_selfref_en 
// - MR request from gs_load_mr - ~load_mr_norm_required_1bit
wire i_asr_en_tmp = i_asr_en_idle & dh_gs_selfref_en & (~load_mr_norm_required_1bit);


wire i_asr_en = i_asr_en_tmp;

// drive output to gsfsm to exit PD/CS
assign gsfsm_sr_hw_lp_pd_cs_exit = i_hw_lp_sr_pd_cs_exit;

//
// Signals for State M/C transitions
//

// Added MEMC_GS_ST_SELFREF_ENT2 to i_ns_sr as SRE is guaranteed after this
// state occurs
// same for MEMC_GS_ST_SELFREF/MEMC_GS_ST_SELFREF_ENT_DFILP
// makes two state m/cs keeping in sync easier
wire i_ns_sr = (gsfsm_next_state==GS_ST_SELFREF) || (gsfsm_next_state==GS_ST_SELFREF_ENT_DFILP) ? 1 : 0;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
wire i_ns_sr_ent2 = ((gsfsm_next_state==GS_ST_SELFREF_ENT2) && (lpddr_dev || dh_gs_ddr4)) ? 1 : 0;
wire i_ns_sr_ex1  = ((gsfsm_next_state==GS_ST_SELFREF_EX1)  && (lpddr_dev || dh_gs_ddr4)) ? 1 : 0;
//spyglass enable_block W528

wire i_ns_norm = (gsfsm_next_state==GS_ST_NORMAL_RD || gsfsm_next_state==GS_ST_NORMAL_WR) ? 1 : 0;

wire i_ns_rst_init = (gsfsm_next_state==GS_ST_RESET || gsfsm_next_state==GS_ST_INIT_DDR) ? 1 : 0;




wire i_ns_dsm    = (gsfsm_next_state==GS_ST_DSM) ||
                   (gsfsm_next_state==GS_ST_DSM_ENT_DFILP) ||
                   (gsfsm_next_state==GS_ST_DSM_EX_DFILP) ? 1 : 0;

// conditions for SR_ST_SRE_ASR -> SR_ST_SR_ASR transition
// 1. LPDDR4
//    - ASR case             : when global-fsm is in in SR-PD state
//    - normal_ppt2_prepre case and
//    - dfi_phymstr_req case : when global-fsm is in SR without PD state
// 2. non-LPDDR4             : when global-fsm is in in SR state
wire asr_sre_to_sr = 
                     (lpddr_dev & i_phymstr_e) ?    (i_ns_sr_ent2 | i_ns_sr_ex1) : // LPDDR4 dfi_phymstr_req
                                                    i_ns_sr; // LPDDR4 ASR, no dfi_phymstr_req, or non-LPDDR4
// register i_phymstr_e
reg i_phymstr_e_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_phymstr_e_r_PROC
  if(!core_ddrc_rstn) begin
    i_phymstr_e_r <= 1'b0;
  end else begin
    i_phymstr_e_r <= i_phymstr_e;
  end
end

// falling edge on i_phymstr_e
wire i_phymstr_e_fed = ~i_phymstr_e & i_phymstr_e_r;

// CAM draining can be skipped if it is allowed via SW and we don't have HW SR
wire skip_dram_draining = dh_gs_dis_cam_drain_selfref & !i_hw_e & !i_hw_e_to_x;

// Transition from SR-PD to SR and back to SR-PD if allowed
wire srpd_to_sr_allowed = dh_gs_lpddr4_sr_allowed & !i_hw_e & !i_hw_e_to_x & (!ih_busy | (ih_busy & dh_gs_dis_cam_drain_selfref));

// if we are in SR_ST_SRE_HW_SW state (i.e. waiting for SR-PD) and there is a PHY Master request, we will first handle the request (in SR);
// after the request is handled we need to return to SR_ST_SRE_HW_SW state (to enter SR-PD without going to IDLE state first)
reg return_sre_after_phymstr;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: return_sre_after_phymstr_PROC
   if(!core_ddrc_rstn) begin
      return_sre_after_phymstr <= 1'b0;
   end else if (sr_st_curr==SR_ST_SRE_HW_SW && sr_st_nxt==SR_ST_SRE_ASR) begin
      return_sre_after_phymstr <= 1'b1;
   end else if (sr_st_nxt==SR_ST_SRE_HW_SW || sr_st_nxt==SR_ST_SRX) begin
      return_sre_after_phymstr <= 1'b0;
   end else begin
      return_sre_after_phymstr <= return_sre_after_phymstr;
   end
end

// SR_ST_SR_HW_SR -> SR_ST_SRX when
// - HW exit and no new HW entry
// - SW entry is dropped
// - no phymstr_req (only non-LPDDR4 case)
wire sr_hw_sw_to_srx = (i_hw_x || i_hw_x_stored || (!i_hw_e_stored)) && (!i_sw_e)
                        && (lpddr_dev ? 1'b1 : (!i_phymstr_e))
                        ;

//
// State M/C
//
   // FSM sequential
   always @(posedge co_yy_clk or negedge core_ddrc_rstn)
   begin: sr_st_seq_PROC
      if( !core_ddrc_rstn ) begin
        sr_st_curr <= SR_ST_RST_INIT;
      end else begin
        sr_st_curr <= sr_st_nxt;
      end
   end

   // FSM combinatorial
   always @(*)
   begin: sr_st_comb_PROC


      case(sr_st_curr)
        
        SR_ST_RST_INIT: begin
          if (!i_ns_rst_init) begin
            if (startup_in_self_ref)
              sr_st_nxt = SR_ST_SR_HW_SW;
            else
              sr_st_nxt = SR_ST_NORM_PD;
          end else begin
            sr_st_nxt = SR_ST_RST_INIT;
          end
        end

        SR_ST_NORM_PD: begin   
          if (i_ns_dsm) begin
            sr_st_nxt = SR_ST_DSM;
          end else
          if (i_sw_e_phymstr_mask && (!i_hw_e) && dh_gs_dis_cam_drain_selfref) begin
            sr_st_nxt = SR_ST_SRE_HW_SW;
          end else if (i_hw_e || i_sw_e_phymstr_mask) begin
            sr_st_nxt = SR_ST_SRE_HW_SW_STALL;
          end else if (i_asr_en || i_phymstr_e) begin
            sr_st_nxt = SR_ST_SRE_ASR;      
          end else begin 
            sr_st_nxt = SR_ST_NORM_PD;
          end
        end

        SR_ST_SRE_HW_SW_STALL: begin
          if (!ih_busy) begin
            sr_st_nxt = SR_ST_SRE_HW_SW;
          end else begin
            sr_st_nxt = SR_ST_SRE_HW_SW_STALL;
          end
        end


        SR_ST_SRE_HW_SW: begin
          if (lpddr_dev && i_phymstr_e) begin
            sr_st_nxt = SR_ST_SRE_ASR; 
          end else
          if (i_ns_sr) begin
            sr_st_nxt = SR_ST_SR_HW_SW; 
          end else begin
            sr_st_nxt = SR_ST_SRE_HW_SW;
           end
        end

        SR_ST_SRE_ASR: begin
          if (i_hw_e || i_sw_e_ih_idle) begin
            sr_st_nxt = SR_ST_SRE_HW_SW_STALL;
          end else if (asr_sre_to_sr) begin            
            sr_st_nxt = SR_ST_SR_ASR;
          end else if (i_ns_sr_ent2) begin
            sr_st_nxt = SR_ST_SRE_ASR;
          end else if (!i_asr_en && !gs_phymstr_sre_req) begin
            sr_st_nxt = SR_ST_NORM_PD;      
          end else begin
            sr_st_nxt = SR_ST_SRE_ASR;
          end
        end
  
        SR_ST_SR_HW_SW: begin
          if (lpddr_dev && i_phymstr_e && srpd_to_sr_allowed) begin
            sr_st_nxt = SR_ST_SRE_ASR;
          end else
          if (sr_hw_sw_to_srx) begin
            sr_st_nxt = SR_ST_SRX; 
          end else begin
            sr_st_nxt = SR_ST_SR_HW_SW;
           end
        end

        SR_ST_SR_ASR: begin  
          if (lpddr_dev && i_sw_e_phymstr_mask && (!i_phymstr_e) && 
               // after finishing PHY Master request handling go directly to SW SR Entry in following cases:
               // - SRPD -> SR transition allowed and was performed - go back to SRPD
               // - we were in SR and were waiting for SRPD when PHY Master request was asserted - go back to that state
               // - CAMs are not expected to be drained upon SW SR Entry
              (srpd_to_sr_allowed || return_sre_after_phymstr || skip_dram_draining)) begin
            sr_st_nxt = SR_ST_SRE_HW_SW;
          // if SDRAM is in SR-PD state due to ASR and a phymstr_req is issued, transition to SR_ST_SRE_ASR and wait for SR entry
          end else if (lpddr_dev && i_phymstr_e && i_ns_sr) begin
            sr_st_nxt = SR_ST_SRE_ASR;
          end else
          if ((i_hw_e || i_sw_e_ih_idle) && (!i_phymstr_e_fed)) begin
            sr_st_nxt = SR_ST_SR_HW_SW;
          end else if (i_phymstr_e_fed || (!i_asr_en && !i_phymstr_e)) begin
            sr_st_nxt = SR_ST_SRX;
          end else begin
            sr_st_nxt = SR_ST_SR_ASR;
           end
        end

        SR_ST_DSM: begin
          if (i_ns_dsm) begin
            sr_st_nxt = SR_ST_DSM;
          end else begin
            sr_st_nxt = SR_ST_SR_HW_SW;
          end
        end


        default: begin // SR_ST_SRX
          if (i_phymstr_e & (i_ns_sr_ent2 | i_ns_sr_ex1)) begin
            sr_st_nxt = SR_ST_SRE_ASR;
          end else
          if (i_ns_norm) begin
            sr_st_nxt = SR_ST_NORM_PD;      
          end else begin
            sr_st_nxt = SR_ST_SRX;
           end
        end
      
      endcase // case(sr_st_curr)
   end
        
// 
// Outputs of block based on state
// 

assign gsfsm_sr_entry_req = (sr_st_curr==SR_ST_SRE_ASR || sr_st_curr==SR_ST_SRE_HW_SW) ? 1 : 0;
assign gsfsm_sr_exit_req  = (sr_st_curr==SR_ST_SRX) ? 1 : 0;

// note use of sr_st_nxt, not sr_st_curr
// as output is later generated from register
wire [SELFREF_TYPE_WIDTH_INT-1:0] i_ddrc_reg_selfref_type_nxt;       
assign i_ddrc_reg_selfref_type_nxt =
       // for LPDDR4 phymstr_req case selfref_type={{($bits(i_ddrc_reg_selfref_type_nxt)-1){1'b0}},1'b1} is not blocked by err_window/i_sre_dly_flag
       (lpddr_dev & sr_st_nxt==SR_ST_SR_ASR & i_phymstr_e) ? {{($bits(i_ddrc_reg_selfref_type_nxt)-1){1'b0}},1'b1} :
       (lpddr_dev & sr_st_nxt==SR_ST_DSM)                  ? {{($bits(i_ddrc_reg_selfref_type_nxt)-2){1'b0}},2'b10} :
       // SR_ST_SR_ASR means SR due to:
       // - PHY Master request - if i_phymstr_e
       // - auto self-refreshes
       (sr_st_nxt==SR_ST_SR_ASR)   ? ((i_sre_dly_flag) ? {$bits(i_ddrc_reg_selfref_type_nxt){1'b0}} : 
                                      ((i_phymstr_e) ? {{($bits(i_ddrc_reg_selfref_type_nxt)-1){1'b0}},1'b1} : {{($bits(i_ddrc_reg_selfref_type_nxt)-2){1'b0}},2'b11})) : 
       // SR_ST_SR_HW_SW means SR due to:
       // - SW/HW SR entry request - typically
       // - PHY Master request - only non-LPDDR4, when PHY Master comes while already in SR due to SW/HW SR request
       (sr_st_nxt==SR_ST_SR_HW_SW) ? ((i_sre_dly_flag) ? {$bits(i_ddrc_reg_selfref_type_nxt){1'b0}} : 
                                      ((
                                          ~lpddr_dev &
                                          i_phymstr_e) ?  {{($bits(i_ddrc_reg_selfref_type_nxt)-1){1'b0}},1'b1} : {{($bits(i_ddrc_reg_selfref_type_nxt)-2){1'b0}},2'b10})) : 
       {$bits(i_ddrc_reg_selfref_type_nxt){1'b0}};


reg [1:0] i_ddrc_reg_selfref_type_nxt_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_ddrc_reg_selfref_type_nxt_r_PROC
  if(!core_ddrc_rstn) begin
    i_ddrc_reg_selfref_type_nxt_r <= {$bits(i_ddrc_reg_selfref_type_nxt_r){1'b0}};
  end else begin
    i_ddrc_reg_selfref_type_nxt_r <= i_ddrc_reg_selfref_type_nxt;
  end
end

// drive output from register
assign ddrc_reg_selfref_type = i_ddrc_reg_selfref_type_nxt_r;

wire sr_st_nxt_hw_sw = (sr_st_nxt==SR_ST_SRE_HW_SW_STALL) || (sr_st_nxt==SR_ST_SRE_HW_SW) || (sr_st_nxt==SR_ST_SR_HW_SW);
wire sr_st_nxt_dsm   = (sr_st_nxt==SR_ST_DSM);

assign gsfsm_sr_co_if_stall = (
                                 // if SR HW LP
                                 (sr_st_nxt_hw_sw && !i_sw_e)
                                 // if DSM
                                 || (sr_st_nxt_dsm)
                                 // if selfref_sw=1 and PHY Master request is not active (use i_sw_e_phymstr_mask instead of i_sw_e, because SW entry 
                                 // requests are masked by phymstr_req)
                                 || (i_sw_e_phymstr_mask && (!dh_gs_dis_cam_drain_selfref))
                                 // if SR SW and CAMs must be empty or CAM draining can be skipped but there is no data in CAMs (keep CAMs empty 
                                 // in this situation for correct selfref_cam_not_empty generation in gs_global_fsm.v)
                                 || (sr_st_nxt_hw_sw && (!dh_gs_dis_cam_drain_selfref || (dh_gs_dis_cam_drain_selfref && !ih_busy)))
                                 // PHY Master and there is no data in CAMs (keep CAMs empty in this situation for correct selfref_cam_not_empty 
                                 // generation in gs_global_fsm.v)
                                 || (((sr_st_nxt==SR_ST_SRE_ASR) || (sr_st_nxt==SR_ST_SR_ASR)) && i_phymstr_e && !ih_busy)
                              ) ? 1'b1 : 1'b0;
                              
wire i_cactive_ddrc_sr_int  = (sr_st_nxt==SR_ST_SR_HW_SW)  ? 0 : 1;

// drive cactive_ddrc low in Self Refresh only if HW LP I/F is enabled
wire i_cactive_ddrc_sr = (reg_ddrc_hw_lp_en) ? i_cactive_ddrc_sr_int : 1;

// cactive_ddrc due to Self Refresh and due to Idle are both 1
// cactive_ddrc_int_x=1, 
// otherwise,
// cactive_ddrc_int_x=0
// Hence use of AND
wire i_cactive_ddrc_int_x = i_cactive_ddrc_sr & i_cactive_ddrc_idle;

// cactive_ddrc forced high if HW LP entry request is in flight that 
// is being rejected 
wire i_cactive_ddrc_int_y = i_cactive_ddrc_hw_e_rej;

// OR the X and Y cases
wire i_cactive_ddrc_int_x_or_y = i_cactive_ddrc_int_x | i_cactive_ddrc_int_y;

// if there's a command in CAM (ih_busy=1)
// then cactive_ddrc should be 1
wire i_cactive_ddrc_int = i_cactive_ddrc_int_x_or_y | ih_busy;

// register output
reg i_cactive_ddrc_int_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_cactive_ddrc_int_r_PROC
  if(!core_ddrc_rstn) begin
    i_cactive_ddrc_int_r <= 1'b1;
  end else begin
    i_cactive_ddrc_int_r <= i_cactive_ddrc_int;
  end
end

// ASYNC OR of cactive_in_ddrc port
wire i_cactive_in_ddrc_async_or = |cactive_in_ddrc_async;

// async AND of phy_dfi_phyupd_req input and SW bit
wire i_phy_dfi_phyupd_req_and_en = phy_dfi_phyupd_req & reg_ddrc_dfi_phyupd_en;

// register i_phy_dfi_phyupd_req_and_en
reg i_phy_dfi_phyupd_req_and_en_r;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: i_phy_dfi_phyupd_req_and_en_r_PROC
  if(!core_ddrc_rstn) begin
    i_phy_dfi_phyupd_req_and_en_r <= 1'b1;
  end else begin
    i_phy_dfi_phyupd_req_and_en_r <= i_phy_dfi_phyupd_req_and_en;
  end
end

// ASYNC AND of phy_dfi_phymstr_req input and SW bit
wire i_phy_dfi_phymstr_req_and_en = phy_dfi_phymstr_req & reg_ddrc_dfi_phymstr_en;

// note asynchronous path for cactive_in_ddrc 
// note asynchronous path for hif_cmd_valid
// Means cactive_ddrc stays high, even if in Self Refresh or idle counter expired, 
// if cactive_in_ddrc goes high or if new core command (hif_cmd_valid)
// hif_cmd_valid is used in ih_busy already, so registered signal i_cactive_ddrc_int
// already uses hif_cmd_valid
// note asynchronous path related to phy_dfi_phyupd_req (as long as reg_ddrc_dfi_phyupd_en==1 as well)
// also, registered path for phy_dfi_phyupd_req/reg_ddrc_dfi_phyupd_en due to
// timing required to detect dfi_phyupd_req going low in gs_phyupd state m/c
assign cactive_ddrc = 
                      i_cactive_ddrc_int_r | i_cactive_in_ddrc_async_or | hif_cmd_valid | i_phy_dfi_phyupd_req_and_en | i_phy_dfi_phyupd_req_and_en_r | i_phy_dfi_phymstr_req_and_en;

// inform gsfsm that it can start SRE without waiting for the CAMs to be empty
// - when DFI PHY MSTR request
// - when SW entry and dis_cam_drain_selfref==1
assign gsfsm_sr_dis_dq = ((sr_st_nxt==SR_ST_SRE_ASR   && i_phymstr_e) || 
                          (sr_st_nxt==SR_ST_SRE_HW_SW && skip_dram_draining)) ? 1'b1 : 1'b0;

// indication of SR_ST_SRE_HW_SW_STALL state    
assign gs_bs_sre_stall = (sr_st_curr == SR_ST_SRE_HW_SW_STALL) ? 1'b1 : 1'b0;

// indication of SR_ST_SRE_HW_SW state
assign gs_bs_sre_hw_sw = (sr_st_curr == SR_ST_SRE_HW_SW) ? 1'b1 : 1'b0;

// allow transition from SR-PD to SR
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: gsfsm_srpd_to_sr_PROC
  if (!core_ddrc_rstn) begin
    gsfsm_srpd_to_sr <= 1'b0;
  end else if (i_ns_sr && sr_st_nxt==SR_ST_SRE_ASR) begin
    gsfsm_srpd_to_sr <= 1'b1;
  end else if (
      gsfsm_srpd_to_sr==1 && (
           sr_st_nxt==SR_ST_SRX
        || sr_st_nxt==SR_ST_SR_HW_SW
        )
    ) begin
    gsfsm_srpd_to_sr <= 1'b0;
  end else begin
    gsfsm_srpd_to_sr <= gsfsm_srpd_to_sr;
  end
end

// allow transition from SR directly to Normal Operating mode
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: gsfsm_sr_no_pd_to_srx_PROC
   if (!core_ddrc_rstn) begin
      gsfsm_sr_no_pd_to_srx <= 1'b0;
   end else if (lpddr_dev & i_phymstr_e_fed & (sr_st_nxt==SR_ST_SRX)) begin
      gsfsm_sr_no_pd_to_srx <= 1'b1;
   end else if (i_ns_norm || (sr_st_nxt==SR_ST_SRE_ASR)) begin
      gsfsm_sr_no_pd_to_srx <= 1'b0;
   end
end






endmodule  // gs_global_fsm_sr_hw_lp
