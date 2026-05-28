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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_load_mr.sv#1 $
// -------------------------------------------------------------------------
// Description:
//                This module is responsible for issuing Load Mode Register command
//                when the controller is NOT in Initialization mode
//
//                The load_mode request from the core is accepted if busy is low and
//                a request is issued to the gs_next_xact module. Busy is set high.
//                When the gs_next_xact schedules the load_mr command to DRAM, this
//                module waits for t_mod and then de-asserts the busy.
//
//                The load mode request is muxed in the gs_glue module with the
//                load_mode during intialization and is then sent to PI
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_load_mr
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS ----------------------------------
     parameter    CHANNEL_NUM                 = 0
    ,parameter    SHARED_AC                   = 0

    ,parameter    BANK_BITS                   = `MEMC_BANK_BITS // # of bank bits.  2 or 3 supported.
    ,parameter    RANK_BITS                   = `MEMC_RANK_BITS

    ,parameter    MRS_A_BITS                  = `MEMC_PAGE_BITS
    ,parameter    MRS_BA_BITS                 = `MEMC_BG_BANK_BITS

    ,parameter    GS_ST_SELFREF_ENT           = 5'b00111      // put DDR in self-refresh then power down pads
    ,parameter    GS_ST_SELFREF_ENT2          = 5'b10101      // Disable C/A Parity before SR if C/A parity had been enabled
    ,parameter    GS_ST_SELFREF_ENT_DFILP     = 5'b00011      // DFI LP I/F entry SR
    ,parameter    GS_ST_SELFREF               = 5'b01100      // DDR is in self-refresh
    ,parameter    GS_ST_SELFREF_EX_DFILP      = 5'b01101      // DFI LP I/F exit SR
    ,parameter    GS_ST_SELFREF_EX1           = 5'b01110      // power up pads
    ,parameter    GS_ST_SELFREF_EX2           = 5'b01111      // bring DDR out of self-refresh
    ,parameter    GS_ST_MPSM_ENT              = 5'b11110      // MPSM entry (output MRS)
    ,parameter    GS_ST_MPSM_ENT_DFILP        = 5'b11111      // DFI LP I/F entry MPSM
    ,parameter    GS_ST_MPSM                  = 5'b10000      // DDR is in maximum power saving mode
    ,parameter    GS_ST_MPSM_EX_DFILP         = 5'b10001      // DFI LP I/F exit MPSM
    ,parameter    GS_ST_MPSM_EX1              = 5'b10010      // power up pads
    ,parameter    GS_ST_MPSM_EX2              = 5'b10011      // bring DDR out of MPSM

    ,parameter    NUM_RANKS                   = 1 << RANK_BITS
    ,parameter    FSM_STATE_WIDTH             = 5

  )
  (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                              co_yy_clk                           //
    ,input                              core_ddrc_rstn                      //
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in RTL assertions and under different `ifdefs
    ,input                              dh_gs_frequency_ratio               // 0 - 1:2 freq ratio, 1 - 1:1 freq ratio
//spyglass enable_block W240
    ,input                              dh_gs_lpddr4                        //
    ,input                              reg_ddrc_lpddr5
    ,input      [T_MR_WIDTH-1:0]        reg_ddrc_t_mr                       // time to wait between MRS/MRW to valid command

    ,input                              dh_gs_mr_wr                         // input from core to write mode register
                                                                            // 0000: MR0, 0001: MR1, 0010: MR2, 0011: MR3, 0100: MR4, 0101: MR5, 0110: MR6
    ,input      [MRS_A_BITS-1:0]        dh_gs_mr_data                       // mode register data to be written
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input      [3:0]                   dh_gs_mr_addr                       // input from core: mode register address
    ,input      [NUM_RANKS-1: 0]        dh_gs_mr_rank                       // user selected ranks (driven from register set)
                                                                            // user can select  subset of ranks like either even ranks only/odd ranks only/all ranks
                                                                            // due to address mirroing reuirment of UDIMM some address/bank bit are swapped (need to take care by software)
                                                                            // hence user can not select even and odd rank/ranks together
//spyglass enable_block W240
    ,output                             gs_dh_mr_wr_busy                    // indicates that mode register write operation is in progress
                                                                            // s/w should initiate a write only when this signal is 0
                                                                            // goes from 0 to 1 in the clock after 'dh_gs_mr_wr' is received
                                                                            // goes from 1 to 0 in the clock after the 'mr_wr' is received
                                                                            // any 'dh_gs_mr_wr' that comes when busy is high won't be accepted
    ,input      [FSM_STATE_WIDTH-1:0]   gs_dh_global_fsm_state              // state machine output from gs_global_fsm

    ,input                              sr_mrrw_en                          // MRR/MRW enable during Self refresh for LPDDR4
    ,input                              load_mr_norm                        // mode register write command sent to the DRAM
    ,output reg [NUM_RANKS-1:0]         load_mr_norm_required               // mode register write request to gs_next_xact
    ,output reg [NUM_RANKS-1:0]         load_mr_norm_required_to_fsm        // mode register write request to gs_global_fsm - to wake-up from self-refresh etc

    ,output     [MRS_A_BITS-1:0]        gs_pi_mrs_a_norm                    // address line during load MR
    ,output reg                         load_mpc_zq_start                   // MCP: ZQ Start
    ,output reg                         load_mpc_zq_latch                   // MCP: ZQ Latch

    ,output reg [NUM_RANKS-1:0]         rank_nop_after_load_mr_norm         // NOP after issuing load_mr command

    ,input                              zqcl_due_to_sr_exit_ext             // ZQCL requested due to Self-Refresh exit
    ,input      [NUM_RANKS-1:0]         zq_calib_short_required             // ZQ Calib request - only ctive for LPDDR4 mode
    ,input                              zq_reset_req_on                     // ZQ Reset request is ON
    ,output                             zq_calib_mr_cmd                     // Load MR scheduled for ZQCS or ZQCL scheduled. inform ZQ module.
    ,output                             load_mrw_reset_norm                 // load MR of type MRW scheduled to MRW Reset (addr=63 (x3F))
    ,input                              dh_gs_derate_enable                 // enable the derating operation
    ,input                              dh_gs_mr4_req                       // input from derating module requesting for MRR operation to MR4
//    ,output                             load_mr_mrs_a_norm_zq_lpddr2
    ,input                              zq_lat
    ,input                              dh_gs_mr_type                       // input from core to indicate read/write
    ,output                             gs_pi_mrr                           // MRR due to internal derating operation
    ,output                             gs_pi_mrr_ext                       // MRR due to external MRR request
    ,output                             mrr_op_on                           // goes high when the FSM moves from IDLE to next state due to MRR operation
                                                                            // goes low when FSM moves from NOP to IDLE state after MRR
                                                                            // used by the logic that handles clock gating
                                                                            // clock should be turned on in rt and rd modules for MRR operation

    ,input                              dqsosc_loadmr_upd_req_p
    ,output                             loadmr_dqsosc_upd_done_p
    ,input [MRS_A_BITS-1:0]             dqsosc_loadmr_a
    ,input                              dqsosc_loadmr_mpc
    ,input                              dqsosc_loadmr_mrr
    ,input  [3:0]                       dqsosc_loadmr_snoop_en
    ,output reg [3:0]                   gs_pi_mrr_snoop_en
    ,output reg                         load_mpc_dqsosc_start
  );

//---------------------------- LOCAL PARAMETERS --------------------------------
// Internal states
localparam  IDLE                      = 2'b00;
localparam  WAIT_FOR_LOAD_MR          = 2'b01;
localparam  WAIT_FOR_LOAD_MR_NOP      = 2'b10;


localparam TIMER_BITS = T_MR_WIDTH;

localparam    TERM_TMOD                = {TIMER_BITS{1'b0}};         // Decode value to terminate tMOD time period

   //-----------------------
   // Wires
   //-----------------------

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
wire      lpddr_dev;
assign lpddr_dev = dh_gs_lpddr4 | reg_ddrc_lpddr5;
//spyglass enable_block W528


    wire                        mr_wr_detect;                   // detection of mr_wr request by user
   //-----------------------
   // Registers
   //-----------------------

    reg [MRS_A_BITS-1:0]        r_dh_gs_mr_data;

    reg [TIMER_BITS-1:0]        mod_timer;
    reg [MRS_A_BITS-1:0]        mrs_a;
    reg                         mr_wr_busy;
    reg [1:0]                   load_mr_curr_state;

    reg [TIMER_BITS-1:0]        mod_timer_w;
    reg [NUM_RANKS-1:0]         rank_nop_after_load_mr_norm_w;
    reg [NUM_RANKS-1:0]         load_mr_norm_required_w;
    reg [MRS_A_BITS-1:0]        mrs_a_w;
    reg                         mpc_zq_start;
    reg                         mpc_zq_latch;
    wire                        mr_wr_busy_w;
    reg [1:0]                   load_mr_next_state;

    wire                        mrrw_req_in_sr_state; // external mrr/mrw request came when the controller is in any of the self-refresh states
    reg                         mrrw_req;
    reg                         mrrw_req_r;
    reg                         clear_mrrw_req;
    wire                        any_mr_req_lpddr2;
    wire                        any_mr_req;

    reg [1:0]                   load_mr_norm_type;
    reg [1:0]                   load_mr_norm_type_w;
    reg                         mrrw_type;
    reg                         dh_gs_derate_enable_r;
    reg                         mr4_req;
    reg                         mr4_req_r;
    reg                         mr4_req_ext;
    reg                         mr4_req_ext_r;
    reg                         clear_mr4_req;

    // decoding global FSM
    wire                        global_fsm_eq_self_ref;         // self-refresh state(gs_dh_global_fsm_state[3:2] == 2'b11)
    wire                        move_to_idle;                   // Transition from WAIT_FOR_LOAD_MR to IDLE
    wire                        move_to_idle_possible;          // Condition which needs to go back to IDLE state


    logic                      dqsosc_req;
    logic                      clear_dqsosc_req_p;
    logic                      mpc_dqsosc_start;
    logic                      dqsosc_cmd_in_prog;
    logic [3:0]                gs_pi_mrr_snoop_en_w;

   assign gs_pi_mrr      = load_mr_norm_type[1]   // Indicates internal or external MR4 read
                           || mr4_req_ext_r       // Indicates internal or external MR4 read
                           ;
   assign gs_pi_mrr_ext  = load_mr_norm_type[0];  // Indicates any external MRR operation

    // Detect either ZQCS or ZQCL or ZQReset
    assign zq_calib_mr_cmd = load_mr_norm & (|zq_calib_short_required) &
                                ((dh_gs_lpddr4 ? (gs_pi_mrs_a_norm[15:0] == 16'h0A01) :
                                                 (gs_pi_mrs_a_norm[15:0] == 16'h1C05))  // ZQ reset
                                 || load_mpc_zq_start || load_mpc_zq_latch
                                );


    // MRW to Address 63 ('h3F) i.e. is a MRW Reset
    assign load_mrw_reset_norm = (gs_pi_mrs_a_norm[15:8] == 8'h3F) & load_mr_norm & ~mrrw_type;

    // MRR operation is ON when the FSM is not in IDLE state and when the mr_type is not 2'b00
    // mr_type = 2'b01 for external MRR and is 2'b10 for internal MR4 derating request
    assign mrr_op_on = (load_mr_next_state != IDLE) && (load_mr_norm_type_w != 2'b00);

    //----------------------------------------------
    //  Decoding global FSM
    //----------------------------------------------
    // self-refresh state(gs_dh_global_fsm_state[3:2] == 2'b11)
    assign global_fsm_eq_self_ref   = ((gs_dh_global_fsm_state == GS_ST_SELFREF)          ||
                                       (gs_dh_global_fsm_state == GS_ST_SELFREF_EX_DFILP) ||
                                       ((gs_dh_global_fsm_state == GS_ST_SELFREF_EX1)
                                        && (!lpddr_dev || !sr_mrrw_en)
                                       ) ||
                                       (gs_dh_global_fsm_state == GS_ST_SELFREF_EX2)      ||
                                       (gs_dh_global_fsm_state == GS_ST_SELFREF_ENT_DFILP)
                                    || (
                                                        zqcl_due_to_sr_exit_ext
                                       )
                                    );




    // Below two signals indicate inversion or not in case of  Shared-AC RDIMM
    wire   shared_ac_rdimm;                        // indicate shared-ac rdimm mode
    wire   inv_en_shac;                            // indicate inversion or not

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep the current coding style.
    assign shared_ac_rdimm = 1'b0;
    assign inv_en_shac = 1'b0;
//spyglass enable_block W528


    //-----------------------
    // Combinational Logic
    //-----------------------

   //---------------------------------------------------------------------------------------------
   // load_mr_next_state
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               load_mr_next_state          = WAIT_FOR_LOAD_MR;         // go to next state
            end
            else begin //  any_mr_req==0
               load_mr_next_state          = IDLE;
            end
         end

         WAIT_FOR_LOAD_MR : begin
            if (move_to_idle_possible) begin
               load_mr_next_state              = IDLE;                         // move to IDLE
            end
            else if(load_mr_norm) begin                                     // MRS command issued to DRAM
               load_mr_next_state              = WAIT_FOR_LOAD_MR_NOP;         // go to next state
            end
            else begin
               load_mr_next_state              = WAIT_FOR_LOAD_MR;             // stay in curr state
            end
         end

         // WAIT_FOR_LOAD_MR_NOP :
         default :
         begin
            if(mod_timer ==  TERM_TMOD) begin                                   // t_mod satisfied
               load_mr_next_state              =
                                                  IDLE;  // go to next state
            end
            else begin
               load_mr_next_state              = WAIT_FOR_LOAD_MR_NOP;         // stay in current state
            end
        end


      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // mrs_a_w
   // mrs_ba_w
   //---------------------------------------------------------------------------------------------
   always_comb begin
      mpc_zq_start = 1'b0;
      mpc_zq_latch = 1'b0;
      mpc_dqsosc_start = 1'b0;
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               //*******************
               // DDR4
               //*******************

               //*******************
               // LPDDR4
               //*******************
                  if (dqsosc_req) begin
                     mrs_a_w                 = dqsosc_loadmr_a;
                     mpc_dqsosc_start        = dqsosc_loadmr_mpc;
                  end else
                  if(|zq_calib_short_required) begin
                     mrs_a_w       = zq_reset_req_on ?
                                                       (dh_gs_lpddr4 ? {{(MRS_A_BITS-16){1'b0}}, 16'h0A01} :
                                                                       {{(MRS_A_BITS-16){1'b0}}, 16'h1C05}) :  // LPDDR5: MR28[0] and set default ZQ interval value 2'b01 MR28 OP[3:2]
                                                       {MRS_A_BITS{1'b0}};
                     mpc_zq_start  = ((zqcl_due_to_sr_exit_ext || !zq_reset_req_on) && !zq_lat);
                     mpc_zq_latch  = ((zqcl_due_to_sr_exit_ext || !zq_reset_req_on) &&  zq_lat);
                  end
                  else if (mr4_req == 1'b1) begin
                     mrs_a_w                  = {{(MRS_A_BITS-16){1'b0}}, 16'h0400};             // load MR4 address  - LPDDR4 format - [7:0] - data, [15:8] - address
                  end
                  else begin
                     mrs_a_w                  = r_dh_gs_mr_data;   // load the data to the address bus - different meaning in LPDDR4 and non-LPDDR4
                  end
            end
            else begin //  any_mr_req==0
               mrs_a_w                     = {MRS_A_BITS{1'b0}};
            end
         end

         WAIT_FOR_LOAD_MR : begin
            if (move_to_idle_possible) begin
               mrs_a_w                         = {MRS_A_BITS{1'b0}};           // reset address
            end
            else if(load_mr_norm) begin                                     // MRS command issued to DRAM
               mrs_a_w                     = {MRS_A_BITS{1'b0}};           // reset address
            end
            else begin
               mrs_a_w                         = mrs_a;                        // hold address
               mpc_zq_start                    = load_mpc_zq_start;
               mpc_zq_latch                    = load_mpc_zq_latch;
               mpc_dqsosc_start                = load_mpc_dqsosc_start;
            end
         end

         // WAIT_FOR_LOAD_MR_NOP :
         default :

         begin
            mpc_zq_start                    = load_mpc_zq_start;
            mpc_zq_latch                    = load_mpc_zq_latch;
            mpc_dqsosc_start                = load_mpc_dqsosc_start;
            if(mod_timer ==  TERM_TMOD) begin                                   // t_mod satisfied
               mrs_a_w                         = {MRS_A_BITS{1'b0}};           // reset address
            end
            else begin
               mrs_a_w                         = mrs_a;
            end
         end

      endcase
   end // always_comb


   //---------------------------------------------------------------------------------------------
   // mod_timer_w
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)

         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
                mod_timer_w     =
                     // For LPDDR4, length of MRR/MRW command is 4 cycle.
                     // DQS oscillator command is higher priority than ZQ command.
                         (|zq_calib_short_required
                                  && (!dqsosc_req)
                                                  ) ? {($bits(mod_timer_w)){1'b0}} :
                     //TODO: LPDDR5 needs to be updated this.
                                  (dh_gs_lpddr4)       ? reg_ddrc_t_mr + ({{($bits(reg_ddrc_t_mr)-2){1'b0}},2'b10} >> dh_gs_frequency_ratio) :
                                  {{($bits(mod_timer_w)-$bits(reg_ddrc_t_mr)){1'b0}}, reg_ddrc_t_mr};
            end
            else begin //  any_mr_req==0
               mod_timer_w  = TERM_TMOD;
            end
         end


         WAIT_FOR_LOAD_MR : begin
            mod_timer_w = mod_timer;
         end

         // WAIT_FOR_LOAD_MR_NOP :
         default :
         begin
            if(mod_timer ==  TERM_TMOD) begin                     // t_mod satisfied
               mod_timer_w = TERM_TMOD;                    // reset the timer
            end
            else begin
               mod_timer_w = mod_timer - {{($bits(mod_timer)-1){1'b0}},1'b1};   // decrement mod timer
            end
         end


      endcase

   end // always_comb


   //---------------------------------------------------------------------------------------------
   // load_mr_norm_required_w
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)

         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
                  load_mr_norm_required_w     = {NUM_RANKS{1'b1}};         // set the request to gs_next_xact
            end
            else begin //  any_mr_req==0
               load_mr_norm_required_w     = {NUM_RANKS{1'b0}};
            end
         end

         WAIT_FOR_LOAD_MR : begin
            if (move_to_idle_possible || load_mr_norm) begin
               load_mr_norm_required_w         = {NUM_RANKS{1'b0}};           // deassert request
            end
            else begin
               load_mr_norm_required_w         = load_mr_norm_required;       // hold the request
            end
         end

         // WAIT_FOR_LOAD_MR_NOP :
         // WAIT_FOR_CMD_GEAR :
         default : begin
            load_mr_norm_required_w         = {NUM_RANKS{1'b0}};            // keep request deasserted
         end

      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // rank_nop_after_load_mr_norm_w
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)

         IDLE : begin
            rank_nop_after_load_mr_norm_w  = {NUM_RANKS{1'b0}};        // assert nop
         end

         WAIT_FOR_LOAD_MR : begin
            if (move_to_idle_possible) begin
               rank_nop_after_load_mr_norm_w   = {NUM_RANKS{1'b0}};            // keep rank nop 0
            end
            else if(load_mr_norm) begin                                     // MRS command issued to DRAM
               rank_nop_after_load_mr_norm_w   =
                                                  {NUM_RANKS{1'b1}};            // assert nop
            end
            else begin
               rank_nop_after_load_mr_norm_w   = {NUM_RANKS{1'b0}};            // keep rank nop 0
            end
         end

         // WAIT_FOR_LOAD_MR_NOP :
         default :
         begin
            if(mod_timer ==  TERM_TMOD) begin                                   // t_mod satisfied
               rank_nop_after_load_mr_norm_w   = {NUM_RANKS{1'b0}};            // reset nop
            end
            else begin
               rank_nop_after_load_mr_norm_w   =
                                                  {NUM_RANKS{1'b1}};            // assert nop
            end
         end


      endcase
   end // always_comb


   //---------------------------------------------------------------------------------------------
   // load_mr_norm_type_w
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               if (dqsosc_req) begin
                  load_mr_norm_type_w  = {dqsosc_loadmr_mrr,1'b0};
               end else
               if(|zq_calib_short_required) begin
                  load_mr_norm_type_w = 2'b00;
               end else if (mr4_req == 1'b1) begin
                  load_mr_norm_type_w = 2'b10;                // code for Internal MR4 Derate Read
               end
               else begin
                  if (mrrw_type == 1'b1) begin
                     load_mr_norm_type_w = 2'b01;             // External MRR operation
                  end else begin
                     load_mr_norm_type_w = 2'b00;             // External MRW operation
                  end
               end // if(|zq_calib_short_required)
            end
            else begin //  any_mr_req==0
               load_mr_norm_type_w = 2'b00;             // External MRW operation
            end
         end

         default : begin
            load_mr_norm_type_w = load_mr_norm_type;
         end
      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // gs_pi_mrr_snoop_en_w
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               if (dqsosc_req) begin
                  gs_pi_mrr_snoop_en_w  = dqsosc_loadmr_snoop_en;
               end else
                  gs_pi_mrr_snoop_en_w = 4'b0000;
            end
            else begin //  any_mr_req==0
               gs_pi_mrr_snoop_en_w = 4'b0000;
            end
         end

         default : begin
            gs_pi_mrr_snoop_en_w = gs_pi_mrr_snoop_en;
         end
      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // mr4_req_ext
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               if (dqsosc_req) begin
                  mr4_req_ext         = 1'b0;
               end else
               if ((|zq_calib_short_required) || (mr4_req == 1'b1)) begin
                  mr4_req_ext         = 1'b0;
               end else begin
                  if (mrrw_type == 1'b1) begin
                     mr4_req_ext         = (r_dh_gs_mr_data[15:8] == 8'h04); // set this if the external MRR is to address MR4
                  end else begin
                     mr4_req_ext         = 1'b0;
                  end
               end // if(|zq_calib_short_required)
            end
            else begin //  any_mr_req==0
               mr4_req_ext         = 1'b0;
            end
         end

         WAIT_FOR_LOAD_MR : begin
            if (move_to_idle_possible) begin
               mr4_req_ext   = 1'b0;                         // reset req
            end
            else begin
               mr4_req_ext   = mr4_req_ext_r;
            end
         end

         default : begin
            mr4_req_ext         = 1'b0;
         end
      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // clear_mr4_req
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               if (dqsosc_req) begin
                  clear_mr4_req        = 1'b0;
               end else
               if(!(|zq_calib_short_required) && (mr4_req == 1'b1)) begin
                  clear_mr4_req       = 1'b1;
               end
               else begin
                  clear_mr4_req       = 1'b0;
               end
            end
            else begin //  any_mr_req==0
               clear_mr4_req       = 1'b0;
            end
         end

         default : begin
            clear_mr4_req       = 1'b0;
         end
      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // clear_dqsosc_req_p
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               if (dqsosc_req) begin
                  clear_dqsosc_req_p        = 1'b1;
               end else
               if(!(|zq_calib_short_required) && (mr4_req == 1'b1)) begin
                  clear_dqsosc_req_p       = 1'b0;
               end
               else begin
                  clear_dqsosc_req_p       = 1'b0;
               end
            end
            else begin //  any_mr_req==0
               clear_dqsosc_req_p       = 1'b0;
            end
         end

         default : begin
            clear_dqsosc_req_p       = 1'b0;
         end
      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // clear_mrrw_req
   //---------------------------------------------------------------------------------------------
   always_comb begin
      case(load_mr_curr_state)
         IDLE : begin
            if(any_mr_req) begin               // accept the mr write or read request
               if (
                     (|zq_calib_short_required) |
                     (mr4_req == 1'b1)
                      | (dqsosc_req)
                    ) begin
                  clear_mrrw_req          = 1'b0;        // mrs_pda_req is issued automatically once it enters into PDA mode
               end
               else begin
                  clear_mrrw_req           =
                                                                  1'b1;
               end
            end
            else begin //  any_mr_req==0
               clear_mrrw_req                 = 1'b0;
            end
         end

         default : begin
            clear_mrrw_req              = 1'b0;
         end
      endcase
   end // always_comb

   //---------------------------------------------------------------------------------------------
   // mr_wr_busy_w
   //---------------------------------------------------------------------------------------------
   assign mr_wr_busy_w = (mrrw_req | dh_gs_mr_wr) | (load_mr_curr_state!=IDLE && mr_wr_busy);



    //-----------------------
    // Assigning the outputs
    //-----------------------

    assign gs_pi_mrs_a_norm     = mrs_a[MRS_A_BITS-1:0];
    assign gs_dh_mr_wr_busy     = mr_wr_busy;

// asserts when the FSM moves from WAIT_FOR_LOAD_MR back to IDLE, with out completing the request
// this happens when the Controller enters SR with a pending Load MR request
// This condition should only happen if the input request arrives 2 clocks before the Controller enters self-refresh mode
// Relies on inter-dependency between and gs_global_fsm and global_fsm_eq_self_ref
// move_to_idle is used in to re-assert mrrw_req/mr4_req if they get
// superseded by self refresh entry
assign move_to_idle = (load_mr_next_state == IDLE) && (load_mr_curr_state == WAIT_FOR_LOAD_MR);

//---------------------------------------------------------------------------------------
// In WAIT_FOR_LOAD_MR state, the following is condition that FSM moves to IDLE
// +--------------+----------+----------+------------------------------------------------
// |   [LPDDR4]   |          |
// |   MRR/MRW    |  Selfref | move_to_idle_possible
// |   in Selfref |          | (This signal doesn't include state information)
// +--------------+----------+------------------------------------------------
// |      0       |     0    | 0
// |      0       |     0    | 1
// |      0       |     1    | 1
// |      0       |     1    | 1
// +--------------+----------+------------------------------------------------
// |      1       |     X    | 0
// +--------------+----------+----------+------------------------------------------------
assign move_to_idle_possible = (global_fsm_eq_self_ref
                               ) & ~sr_mrrw_en;

assign mr_wr_detect =
       dh_gs_mr_wr;
   //-----------------------
   // All the flops
   //-----------------------
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if(!core_ddrc_rstn) begin
         mrrw_req                    <= 1'b0;
         mrrw_req_r                  <= 1'b0;
            dh_gs_derate_enable_r    <= 1'b0;
            mr4_req                  <= 1'b0;
            mr4_req_r                <= 1'b0;
            mrrw_type                <= 1'b0;
         r_dh_gs_mr_data             <= {MRS_A_BITS{1'b0}};
      end
      else begin
   // clear_mrrw_req indicates this transition IDLE to WAIT_FOR_LOAD_MR is by mrrw_req
   // mrrw_req_r set by clear_mr4_req
   // reset by transition back into IDLE state
   // if IDLE state was due to Self Refresh (global_fsm_eq_self_ref)
   // move_to_idle=1 will be the case
   // and mrrw_req gets re-asserted
   // More robust than prev logic that

         mrrw_req_r                  <= (clear_mrrw_req) ? 1'b1 : (load_mr_next_state == IDLE) ? 1'b0 : mrrw_req_r;  // store the request

         dh_gs_derate_enable_r       <= dh_gs_derate_enable;
   // clear_mr4_req indicates this transition IDLE to WAIT_FOR_LOAD_MR is by mr4_req
   // similar to mrrw_req above
     // we want to avoid MR4 read requests during initialization
         mr4_req_r                   <=  (clear_mr4_req) ? 1'b1 : (load_mr_next_state == IDLE) ? 1'b0 :  mr4_req_r;  // store the request
         if (mr_wr_detect) begin
           mrrw_req                  <= 1'b1;
            mrrw_type                <= dh_gs_mr_type;
           r_dh_gs_mr_data           <= dh_gs_mr_data;
         end
         else if (clear_mrrw_req == 1'b1)
           mrrw_req                  <= 1'b0;
         else if((move_to_idle == 1'b1) && mrrw_req_r)  // if FSM returned back to IDLE from WAIT_FOR_LOAD_MR (due to SRE), then re-assert the request
           mrrw_req                  <= 1'b1;
         // if MR request from derate module, set mr4_req
         // we want to avoid MR4 read requests during initialization
         // dh_gs_mr4_req is 1 cycle delay for dh_gs_dearte_enable, so need to use dh_gs_derate_enable_r here
         if (dh_gs_mr4_req & dh_gs_derate_enable_r)
           mr4_req                   <= 1'b1;
         else if ((clear_mr4_req == 1'b1))
           mr4_req                   <= 1'b0;
         else if ((move_to_idle == 1'b1) && mr4_req_r)  // if FSM returned back to IDLE from WAIT_FOR_LOAD_MR (due to SRE), then re-assert the request
           mr4_req                   <= 1'b1;
      end
   end // always @ (posedge co_yy_clk or negedge core_ddrc_rstn)



// request from external MR registers OR internal MR4 derating request
// external request or mr4 request is transferred to any_mr_req only if it is not in any of the self-refresh states
// if it is in self-refresh state, this module informs gs_global_fsm through load_mr_norm_required_to_fsm, but
// the actual load_mr_norm request process isn't started until self-refresh state is exited
    // we want to avoid MR4 read requests during initialization
    assign any_mr_req_lpddr2    = (mr4_req & (!global_fsm_eq_self_ref)) | (|zq_calib_short_required);

       assign any_mr_req           =  (mrrw_req & (!global_fsm_eq_self_ref))
                                     | any_mr_req_lpddr2
                                | dqsosc_req
                                ;

   assign mrrw_req_in_sr_state = mrrw_req & global_fsm_eq_self_ref;

   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if(!core_ddrc_rstn) begin
         mod_timer                   <= TERM_TMOD;
         rank_nop_after_load_mr_norm <= {NUM_RANKS{1'b0}};
         load_mr_norm_required       <= {NUM_RANKS{1'b0}};
         load_mr_norm_required_to_fsm <= {NUM_RANKS{1'b0}};
            load_mr_norm_type        <= 2'b00;
            mr4_req_ext_r            <= 1'b0;
            load_mpc_zq_start        <= 1'b0;
            load_mpc_zq_latch        <= 1'b0;
            load_mpc_dqsosc_start    <= 1'b0;
            gs_pi_mrr_snoop_en       <= 4'd0;
         mrs_a                       <= {MRS_A_BITS{1'b0}};
         mr_wr_busy                  <= 1'b0;
         load_mr_curr_state          <= 2'b00;
      end
      else begin
         mod_timer                   <= mod_timer_w;
         rank_nop_after_load_mr_norm <= rank_nop_after_load_mr_norm_w;

         // Load MR Norm required signal sent out due to the assertion of this in FSM or due to
         // MRR/MRW request appearing during self-refresh state (in LPDDR4 mode)
         load_mr_norm_required       <= load_mr_norm_required_w;
         load_mr_norm_required_to_fsm <= load_mr_norm_required_w
                                         | {NUM_RANKS{mrrw_req_in_sr_state}}
                                        ;
            load_mr_norm_type        <= load_mr_norm_type_w;
            mr4_req_ext_r            <= mr4_req_ext;
            load_mpc_zq_start        <= mpc_zq_start;
            load_mpc_zq_latch        <= mpc_zq_latch;
            load_mpc_dqsosc_start   <= mpc_dqsosc_start;
            gs_pi_mrr_snoop_en      <= gs_pi_mrr_snoop_en_w;
         mrs_a                       <= mrs_a_w;
         mr_wr_busy                  <= mr_wr_busy_w;
         load_mr_curr_state          <= load_mr_next_state;
      end
   end


    always_ff @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : dqsosc_req_PROC
       if (!core_ddrc_rstn)
          dqsosc_req  <= 1'b0;
       else if (dqsosc_loadmr_upd_req_p)
          dqsosc_req  <= 1'b1;
       else if (clear_dqsosc_req_p)
          dqsosc_req  <= 1'b0;
    end

    always_ff @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : dqsosc_cmd_in_prog_PROC
       if (!core_ddrc_rstn)
          dqsosc_cmd_in_prog  <= 1'b0;
       else if (clear_dqsosc_req_p)
          dqsosc_cmd_in_prog  <= 1'b1;
       else if (load_mr_norm)
          dqsosc_cmd_in_prog  <= 1'b0;
    end

    assign  loadmr_dqsosc_upd_done_p =  dqsosc_cmd_in_prog & load_mr_norm;



`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
`endif // SYNTHESIS

`endif // SNPS_ASSERT_ON

endmodule // gs_load_mr
