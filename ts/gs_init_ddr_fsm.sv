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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_init_ddr_fsm.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// gs_init_ddr_fsm - DDR Initialization FSM
// This block implements the fsm that walks the DDR thru the
// initialization sequence
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_init_ddr_fsm
import DWC_ddrctl_reg_pkg::*;
#(
  //----------------------------- PARAMETERS -------------------------------------
     parameter    CHANNEL_NUM                 = 0
    ,parameter    SHARED_AC                   = 0
    ,parameter    BANK_BITS                   = `MEMC_BANK_BITS // # of bank bits.  2 or 3 supported.
    ,parameter    RANK_BITS                   = `MEMC_RANK_BITS // # of rank bits.  0, 1, or 2 supported

    ,parameter    MRS_A_BITS                  = `MEMC_PAGE_BITS
    ,parameter    MRS_BA_BITS                 = `MEMC_BG_BANK_BITS

    ,parameter    NUM_RANKS                   = 1 << RANK_BITS

  )
  (
  //------------------------- INPUTS AND OUTPUTS ---------------------------------
     input                            co_yy_clk
    ,input                            core_ddrc_rstn                    // async falling-edge reset

    ,input      [15:0]                dh_gs_mr                          // mode register
    ,input      [15:0]                dh_gs_emr                         // extended mode register
    ,input      [15:0]                dh_gs_emr2                        // extended mode register 2 (ddr2 only)
    ,input      [15:0]                dh_gs_emr3                        // extended mode register 3 (ddr2 only)
    ,input      [T_MR_WIDTH-1:0]      reg_ddrc_t_mr                     // time to wait between MRS/MRW to valid command
    ,input      [DRAM_RSTN_X1024_WIDTH-1:0] dh_gs_dram_rstn_x1024        // cycles to wait for dram reset to stay low, in 1024 core clock cycles

    ,input                            dh_gs_per_bank_refresh
    ,input                            dh_gs_lpddr4                      // 1:LPDDR4 device, 0: non-LPDDR4 device
    ,input                            reg_ddrc_lpddr5                   // 1:LPDDR5 device, 0: non-LPDDR5 device
    ,input      [2:0]                 gs_dh_operating_mode              // 00 = uninitialized
                                                                        // 01 = normal
                                                                        // 02 = powerdown
                                                                        // 03 = self-refresh

    ,input                            phy_dfi_init_complete             // PHY initialization complete.All DFI signals that communicate commands or status
                                                                        // must be held at their default values until the dfi_init_complete signal asserts
    ,input                            dh_gs_dfi_init_complete_en

    ,input      [PRE_CKE_X1024_WIDTH-1:0]   dh_gs_pre_cke_x1024               // cycles to wait before enabling clock
    ,input      [POST_CKE_X1024_WIDTH-1:0]  dh_gs_post_cke_x1024              // cycles to wait after enabling clock
    ,input                            dh_gs_sw_init_int                 // SW intervention in auto SDRAM initialization
    ,output                           gs_sw_init_int_possible           // SW init intervention is possible
    ,input      [T_RFC_MIN_WIDTH-1:0] dh_gs_t_rfc_min                   // minimum time between refreshes
    ,input                            timer_pulse_x32                   // pulse for timers every 32 clocks
    ,input                            timer_pulse_x1024                 // pulse for timers every 1024 clocks

    ,input                            gs_pi_phyupd_pause_req
    ,input                            gs_pi_ctrlupd_req

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used only in MEMC_NUM_RANKS_GT_1 configs. Decided to keep the current implementation for now.
    ,input                            dh_gs_zq_resistor_shared
//spyglass enable_block W240
    ,output                           start_zqcs_timer                  // indicates that first ZQ has been issued and
                                                                        // running ZQ timer should be started
    ,input                            dfi_reset_n_in                    // dfi reset reference signal from the other channel's uMCTL2
    ,output                           dfi_reset_n_ref                   // dfi reset reference signal to the other channel's uMCTL2
    ,input                            init_mr_done_in                   // init_mr_done signal from the other channel's uMCTL2
    ,output                           init_mr_done_out                  // init_mr_done signal to the other channel's uMCTL2
    ,input      [T_ZQ_LONG_NOP_WIDTH-1:0]                dh_gs_t_zq_long_nop               // For LPDDR4: tZQCAL
    ,input      [T_ZQ_SHORT_NOP_WIDTH-1:0]                 dh_gs_t_zq_short_nop              // For LPDDR4: tZQLAT
    ,output                           init_mpc_zq_start                 // MPC: ZQStart
    ,output                           init_mpc_zq_latch                 // MPC: ZQLatch
    ,output                           gs_pi_dram_rst_n                  // ddrc to dram active low reset
    ,output     [NUM_RANKS-1:0]       init_cs_n                         // chip selects during initialization
    ,output                           gs_pi_init_cke                    // CKE pin value during init
    ,output                           gs_pi_op_is_load_mode             // send load mode command
    ,output                           init_refresh                      // refresh command
    ,output reg [MRS_A_BITS-1:0]      gs_pi_mrs_a                       // address lines during init
    ,output                           start_refresh_timer               // start the refresh timer
    ,input      [1:0]                 reg_ddrc_skip_dram_init           // skip sdram initialization
    ,output reg                       end_init_ddr                      // end of DDR initizlization sequence
    ,output                           gs_pi_init_in_progress

    ,output     [4:0]                 gs_dh_init_curr_state             // debug register with info about the init state
    ,output     [4:0]                 gs_dh_init_next_state             // debug register with info about the init state
  );

//---------------------------- LOCAL PARAMETERS --------------------------------
// Define state machine states
localparam  INIT_FSM_START                = 5'b00000;   // start here & do pre-CKE wait [>200 us]
localparam  INIT_FSM_CKE                  = 5'b00001;   // enable clock & do post-CKE wait [>400 ns]
//localparam  INIT_FSM_PCALL_1              = 5'b00010;   // Not used
localparam  INIT_FSM_EMR2                 = 5'b00011;   // write EMR2 & wait tMRD
localparam  INIT_FSM_EMR3                 = 5'b00100;   // write EMR3 & wait tMRD
localparam  INIT_FSM_EMR                  = 5'b00101;   // write EMR & wait tMRD
localparam  INIT_FSM_MR_1                 = 5'b00110;   // write MR, enabling DLL, and wait tMRD
//localparam  INIT_FSM_PCALL_2              = 5'b00111;   //Not used
localparam  INIT_FSM_REFRESH              = 5'b01000;   // Issue 2 or more refreshes
//localparam  INIT_FSM_MR_2                 = 5'b01001;   //Not used
//localparam  INIT_FSM_PRE_OCD_WT           = 5'b01010;   //Not used
localparam  INIT_DDR3_FSM_ZQCL            = 5'b01011;   // ZQ calibration
//localparam  INIT_DDR2_FSM_OCD_DEF         = 5'b01100;   //Not used
localparam  INIT_DDR3_FSM_RESET           = 5'b01100;   // de-asserting DRAM reset before CKE
//localparam  INIT_FSM_OCD_EXIT             = 5'b01101;   //Not used
localparam  INIT_FSM_END                  = 5'b01110;   // done

// Used to indrouce two states for each MRS In Case of UDIMM and RDIMM
localparam  INIT_FSM_NOP                  = 5'b11011;   // state machine will halt for a clock will do No Operation
//localparam  INIT_FSM_RFSH_NOP             = 5'b11100;   // Not used

//localparam  INIT_LPDDR2_FSM_CKE_IDLE      = 5'b10000;   // Not used
//localparam  INIT_LPDDR2_FSM_MRW           = 5'b10001;   //Not used
//localparam  INIT_LPDDR2_FSM_MRR           = 5'b10010;   //Not used
localparam  INIT_LPDDR2_FSM_ZQINIT        = 5'b10011;   // wait for ZQ initial calibration : tZQINIT
localparam  INIT_LPDDR2_FSM_MR_1          = 5'b10100;   // MR_1 register write, wait for t_mrd(for LPDDR4) cycles
localparam  INIT_LPDDR2_FSM_MR_2          = 5'b10101;   // MR_2 register write, wait for t_mrd(for LPDDR4) cycles
localparam  INIT_LPDDR2_FSM_MR_3          = 5'b10110;   // MR_3 register write, wait for t_mrd(for LPDDR4) cycles
//localparam  INIT_RFAB_DLY                 = 5'b10111;   //Not used

localparam  INIT_LPDDR4_FSM_MR_13         = 5'b00101;   // MR_13 register write, wait for t_mrd(for LPDDR4) cycles, //using with dh_gs_lpddr4

//------------------------- WIRES AND REGISTERS --------------------------------
wire    [MRS_A_BITS-1:0]    gs_pi_mrs_a_wire;   //
reg             resetb_ff;                      // set 1 clock after reset de-asserts
reg     [$bits(dh_gs_t_rfc_min)-1:0]   timer_x1;
reg     [6:0]   refresh_cnt;                    // number of refreshes left to perform
reg     [4:0]   current_state;
reg     [4:0]   last_state;
reg     [4:0]   prev_cycle_state;               // current_state delayed by one cycle
reg     [$bits(reg_ddrc_t_mr)-1:0]   timer_mod_lpddr2;                // timer to count reg_ddrc_t_mr cycles between load of MR0 and ZQCL
reg             zqcl_ddr3;                      // ZQ calibration long - tied to zero except in DDR3
reg             zqinit_lpddr2;                  // ZQ calibration init - tied to zero except in LPDDR2
reg     [$bits(dh_gs_dram_rstn_x1024)-1:0]   timer_dram_rstn_x1024;
reg             gs_pi_dram_rst_n_tmp;

wire            set_timer_x1;
wire    [$bits(dh_gs_t_rfc_min)-1:0]   timer_x1_value;
wire            set_timer_x32;
wire    [$bits(dh_gs_t_zq_long_nop)-4:0]   t_zq_wait_x32_lpddr4;           // Calculate tZQCAL+tZQLAT in x32 accuracy, for LPDR4
wire    [$bits(t_zq_wait_x32_lpddr4)-1:0]   timer_x32_value;
reg     [$bits(timer_x32_value)-1:0]   timer_x32;
wire            set_timer_x1024;
wire    [$bits(dh_gs_pre_cke_x1024)-1:0]  timer_x1024_value_other;
wire    [$bits(dh_gs_pre_cke_x1024)-1:0]  timer_x1024_value_lpddr4;
wire    [$bits(timer_x1024_value_other)-1:0]  timer_x1024_value;
reg     [$bits(timer_x1024_value)-1:0]  timer_x1024;
wire    [4:0]   next_state;
reg             refresh_pending;                // a refresh is pending - issue it when possible
wire            load_mode;                      // set mode register command
wire            chip_select;
wire    [4:0]   next_state_lpddr4;
reg     [2:0]   gs_dh_operating_mode_r;
////





wire            init_not_paused;
wire            i_upd_req   = (gs_pi_phyupd_pause_req

                    ) | gs_pi_ctrlupd_req;


// delayed version of i_upd_req
reg i_upd_req_r;
always@(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
        i_upd_req_r <= 1'b0;
    else begin
        i_upd_req_r <= i_upd_req;
    end
end

// Skip dram initialization reg_ddrc_skip_dram_init[0] = 1'b1
// Start in normal mode after skipping dram init reg_ddrc_skip_dram_init[1] = 1'b0
// Start in self-refresh mode after skipping dram init reg_ddrc_skip_dram_init[1] = 1'b1
wire normal_mode_after_skip_init    =  reg_ddrc_skip_dram_init[0] & (~reg_ddrc_skip_dram_init[1]);
wire self_refresh_after_skip_init   =  &reg_ddrc_skip_dram_init;

// signal used in each clocked process as an enable
// Registers do not change if  i_upd_req=1
assign init_not_paused = ~(i_upd_req);



// for DDR4/LPDDR4, send one refresh.
wire [6:0] num_init_refreshes;
assign num_init_refreshes =
                                (1'b0
                                  | dh_gs_lpddr4
                                ) ? 7'd1 : 7'd2;

// -----------------------------------------------------------------
//  generates odd_rank/upper_rank signals for MRS operation
// -----------------------------------------------------------------






// SW intervention in the initialization is allowed after tXPR
assign gs_sw_init_int_possible = ((current_state == INIT_FSM_CKE) && !(|timer_x1024)) ? 1'b1 : 1'b0;

// only zqcl_ddr3 is used, and not zqinit_lpddr2 in the logic below becauase, zqinit_lpddr2 is covered through mrs

// current_state assigned to this signal for debug purpose
assign gs_dh_init_curr_state = current_state;
assign gs_dh_init_next_state = next_state;



assign dfi_reset_n_ref = dh_gs_lpddr4 ? (gs_pi_dram_rst_n_tmp | reg_ddrc_skip_dram_init[0]) : 1'b1;

assign gs_pi_dram_rst_n =
                            dh_gs_lpddr4 ?  dfi_reset_n_ref & dfi_reset_n_in :
                            gs_pi_dram_rst_n_tmp | reg_ddrc_skip_dram_init[0];

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        gs_pi_dram_rst_n_tmp <= 1'b0;
        timer_dram_rstn_x1024 <= {{($bits(timer_dram_rstn_x1024)-9){1'b0}},9'b1111111}; // should be > 0 before initialized
    end
    else begin
        if (init_not_paused && dh_gs_dfi_init_complete_en && phy_dfi_init_complete)
            gs_pi_dram_rst_n_tmp <= ~(|timer_dram_rstn_x1024);
        if (~resetb_ff)
            timer_dram_rstn_x1024 <= dh_gs_dram_rstn_x1024;
        else if ((|timer_dram_rstn_x1024) && timer_pulse_x1024)
            timer_dram_rstn_x1024 <= timer_dram_rstn_x1024 - {{($bits(timer_dram_rstn_x1024)-1){1'b0}},1'b1};
    end
end


reg     init_mr_done_r;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        init_mr_done_r <= 1'b0;
    end
    else if(current_state == INIT_FSM_START) begin
        init_mr_done_r <= 1'b0;
    end
    else if((dh_gs_lpddr4) && (current_state == INIT_LPDDR2_FSM_MR_3) && (timer_mod_lpddr2=={$bits(timer_mod_lpddr2){1'b0}})) begin
        init_mr_done_r <= 1'b1;
    end
end

assign init_mr_done_out = dh_gs_lpddr4 ? init_mr_done_r : 1'b1;



//--------------- Timers Used to Count Cycles in Given States ------------------

// set single-clock timer when doing a refresh, precharge, or load mode
// (and a few other times needlessly)
// For refresh state, only set the timer when a refresh is actually sent (and at the start of the state)
assign set_timer_x1     = (next_state != current_state) || ((current_state == INIT_FSM_REFRESH) && (init_refresh == 1'b1));

assign timer_x1_value   =
                            ({{($bits(timer_x1_value)-$bits(dh_gs_t_rfc_min)){1'b0}}, dh_gs_t_rfc_min});

                                // for lpddr4 device, just after initialization a number of all bank refresh commands are issued to all ranks
                                // dh_gs_t_rfc_min should be set to tRFCpb min, hence tRFCab is derived fron tRFCpb


// set the 32-clock timer before and after OCD
assign set_timer_x32    = (next_state  != current_state);

assign timer_x32_value  =
                          dh_gs_lpddr4 ? t_zq_wait_x32_lpddr4 :     // timer value = tZQCAL+tZQLAT
                                                                    // For lpddr4, timer_x32 is needed in one case when moving to 'INIT_LPDDR2_FSM_ZQINIT'
                          {$bits(timer_x32_value){1'b0}}  ;

// For tZQCAL+tZQLAT, convert to x32 accuracy
// Guarantee t_zq_wait_x32_lpddr4*32 >= dh_gs_t_zq_long_nop+dh_gs_t_zq_short_nop
wire [$bits(dh_gs_t_zq_long_nop)-5:0] dh_gs_t_zq_long_nop_x32;
assign  dh_gs_t_zq_long_nop_x32 = dh_gs_t_zq_long_nop[$bits(dh_gs_t_zq_long_nop)-1:5];

wire [$bits(dh_gs_t_zq_short_nop)-5:0] dh_gs_t_zq_short_nop_x32;
assign  dh_gs_t_zq_short_nop_x32 = dh_gs_t_zq_short_nop[$bits(dh_gs_t_zq_short_nop)-1:5];

assign t_zq_wait_x32_lpddr4 = {{($bits(t_zq_wait_x32_lpddr4)-$bits(dh_gs_t_zq_long_nop_x32)){1'b0}}, dh_gs_t_zq_long_nop_x32} +
                               {{($bits(t_zq_wait_x32_lpddr4)-$bits(dh_gs_t_zq_short_nop_x32)){1'b0}}, dh_gs_t_zq_short_nop_x32} +
                               ({{($bits(t_zq_wait_x32_lpddr4)-3){1'b0}},3'b101});

// This logic should be corrected when new JEDEC spec will be reflected. (see bug 2859,2968)
reg    zqlat_expired_sel_r;
wire   t_zqcal_expired;
wire   t_zqcal_expired_norm;
wire   t_zqcal_expired_delay;
wire [$bits(dh_gs_t_zq_short_nop_x32):0] timer_x32_zqcal_expired_norm;
wire [$bits(dh_gs_t_zq_short_nop_x32):0] timer_x32_zqcal_expired_delay;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        zqlat_expired_sel_r <= 1'b0;
    end else if(current_state != INIT_LPDDR2_FSM_ZQINIT) begin
        zqlat_expired_sel_r <= 1'b0;
    end else if((~i_upd_req) && (i_upd_req_r) && (t_zqcal_expired_norm)) begin
        zqlat_expired_sel_r <= 1'b1;
    end else if(timer_pulse_x32) begin
        zqlat_expired_sel_r <= 1'b0;
    end
end

assign timer_x32_zqcal_expired_norm = {{($bits(timer_x32_zqcal_expired_norm)-$bits(dh_gs_t_zq_short_nop_x32)){1'b0}}, dh_gs_t_zq_short_nop_x32}
                                            + {{($bits(timer_x32_zqcal_expired_norm)-2){1'b0}},2'b11};
assign timer_x32_zqcal_expired_delay = {{($bits(timer_x32_zqcal_expired_delay)-$bits(dh_gs_t_zq_short_nop_x32)){1'b0}}, dh_gs_t_zq_short_nop_x32}
                                            + {{($bits(timer_x32_zqcal_expired_delay)-2){1'b0}},2'b10};

assign t_zqcal_expired_norm  = ((timer_x32 == {{($bits(timer_x32)-$bits(timer_x32_zqcal_expired_delay)){1'b0}},timer_x32_zqcal_expired_norm}) && timer_pulse_x32 &&
                                 dh_gs_lpddr4 && (current_state == INIT_LPDDR2_FSM_ZQINIT) && init_not_paused);
assign t_zqcal_expired_delay = ((timer_x32 == {{($bits(timer_x32)-$bits(timer_x32_zqcal_expired_delay)){1'b0}},timer_x32_zqcal_expired_delay}) && timer_pulse_x32 &&
                                 dh_gs_lpddr4 && (current_state == INIT_LPDDR2_FSM_ZQINIT) && init_not_paused);
assign t_zqcal_expired = (zqlat_expired_sel_r)? t_zqcal_expired_delay : t_zqcal_expired_norm;


//-------------------
// Setting set_timer_x1024
//-------------------

// set 1024-clock timer at beginning
// (the beginning setting happens in the synchronous reset portion of the
//  always block below)



assign set_timer_x1024  = init_not_paused && (~resetb_ff ||
                            (
                             dh_gs_lpddr4 ?
                                ((((current_state != INIT_DDR3_FSM_RESET) && (next_state_lpddr4 == INIT_DDR3_FSM_RESET)) && (phy_dfi_init_complete && dh_gs_dfi_init_complete_en)) ||
                                ((current_state != INIT_FSM_CKE) && (next_state_lpddr4 == INIT_FSM_CKE)) ||
                                ((current_state == INIT_FSM_END) && (next_state == INIT_FSM_START))) :
                                (((current_state != INIT_FSM_CKE) && (next_state == INIT_FSM_CKE) && (phy_dfi_init_complete && dh_gs_dfi_init_complete_en))
                        )));





//--------------
// Setting timer_x1024_value
//--------------

// Set the x1024_value for LPDDR4
assign timer_x1024_value_lpddr4 = ((next_state_lpddr4 == INIT_FSM_START)          ? {{($bits(timer_x1024_value_lpddr4)-$bits(dh_gs_dram_rstn_x1024)){1'b0}}, dh_gs_dram_rstn_x1024} : // timer value = tINIT1
                                   (next_state_lpddr4 == INIT_DDR3_FSM_RESET)     ? {{($bits(timer_x1024_value_lpddr4)-$bits(dh_gs_pre_cke_x1024)){1'b0}}, dh_gs_pre_cke_x1024} : // timer value = tINIT3
                                                                                    {{($bits(timer_x1024_value_lpddr4)-$bits(dh_gs_post_cke_x1024)){1'b0}}, dh_gs_post_cke_x1024}) ; // timer value = tINIT5

// Set the x1024_value for DDR2, DDR3 and LPDDR
assign timer_x1024_value_other  = (~resetb_ff || (~phy_dfi_init_complete && dh_gs_dfi_init_complete_en)
                                   ) ? {{($bits(timer_x1024_value_other)-$bits(dh_gs_pre_cke_x1024)){1'b0}}, dh_gs_pre_cke_x1024}  :
                                       {{($bits(timer_x1024_value_other)-$bits(dh_gs_post_cke_x1024)){1'b0}}, dh_gs_post_cke_x1024};

// select the final x1024 value based on whether the controller is in lpddr4, or other mode
assign timer_x1024_value =                                dh_gs_lpddr4 ? {{($bits(timer_x1024_value)-$bits(timer_x1024_value_lpddr4)){1'b0}},timer_x1024_value_lpddr4} :
                                               {{($bits(timer_x1024_value)-$bits(timer_x1024_value_other)){1'b0}},timer_x1024_value_other};

//---------------------- Next State Assignment ---------------------------------

// assign the next state, dependant on type of DRAM in use


assign next_state =
                    (dh_gs_dfi_init_complete_en == 1'b0 || !init_not_paused) ? current_state :
                    phy_dfi_init_complete == 1'b0 ? INIT_FSM_START :
                    reg_ddrc_skip_dram_init == 2'b11 ? INIT_FSM_END :
                    dh_gs_lpddr4 ? next_state_lpddr4 :
                    INIT_FSM_START;





//
// initilization sequence following ddr3 spec on pages 15 to 16
//

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        timer_mod_lpddr2 <= {$bits(timer_mod_lpddr2){1'b1}}; // timer to count reg_ddrc_t_mr cycles between load of MR0 and ZQCL
    end else begin
        if (init_not_paused) begin
            if (next_state != current_state) begin
                if (next_state == INIT_LPDDR2_FSM_MR_3) begin
                    timer_mod_lpddr2 <= reg_ddrc_t_mr
                        // commands in LPDDR4 can be different lengths. The JEDEC spec defines that timing parameters should be measured from the end of one command to the end of the
                        // next command. But our design measures from the start of one command to the start of the next command. Therefore, we need to compensate for this by adding extra time:
                        // - 2 cycles (when we know that the current command is 4 cycles long and the following command is 2 cycles long) - after MR3 we have ZQCL which is a MPC (2 cycles long)
                                      + (dh_gs_lpddr4 ? {{($bits(timer_mod_lpddr2)-2){1'b0}},2'b10} : {$bits(timer_mod_lpddr2){1'b0}})
                                      ;
                end else if ((next_state == INIT_LPDDR2_FSM_MR_1) || (next_state == INIT_LPDDR2_FSM_MR_2) || (next_state == INIT_LPDDR4_FSM_MR_13)) begin
                    timer_mod_lpddr2 <= reg_ddrc_t_mr;
            // Following lines are redundant. Excluded to improve line and condition coverage. Bug 10509
            //  end else if (timer_mod_lpddr2 != {$bits(timer_mod_lpddr2){1'b0}}) begin
            //      timer_mod_lpddr2 <= timer_mod_lpddr2 - {{($bits(timer_mod_lpddr2)-1){1'b0}},1'b1};
                end
            end else if (timer_mod_lpddr2 != {$bits(timer_mod_lpddr2){1'b0}}) begin
                timer_mod_lpddr2 <= timer_mod_lpddr2 - {{($bits(timer_mod_lpddr2)-1){1'b0}},1'b1};
            end
        end // if (init_not_paused)
    end
end


assign next_state_lpddr4 =  // Stay INIT_FSM_START state until the dfi_reset_n_in (from the other controller) has also deasserted
                            (current_state == INIT_FSM_START)               ? (reg_ddrc_skip_dram_init == 2'b01 ? INIT_FSM_REFRESH :
                                                                              (((|timer_dram_rstn_x1024) || (!dfi_reset_n_in)) ?          INIT_FSM_START            : INIT_DDR3_FSM_RESET)) : // wait prior to asserting reset
                            (current_state == INIT_DDR3_FSM_RESET)          ? ((|timer_x1024)     ? INIT_DDR3_FSM_RESET           : INIT_FSM_CKE)             : // wait prior to setting CKE
                            (current_state == INIT_FSM_CKE)                 ? ((|timer_x1024)
                                                                                | dh_gs_sw_init_int     ? INIT_FSM_CKE                  : INIT_LPDDR4_FSM_MR_13)    : // wait after CKE is set to 1

                            // Cur State will take the value of last sate (NOP state is bridge b/w MR states for even and odd ranks; NOP state will come in picture only if CS Staggering is enabled)
                            (current_state == INIT_FSM_NOP)                 ? last_state  :


                            // wait for device auto initialization ; tINIT5////CS staggering is not supported
                            (current_state == INIT_LPDDR4_FSM_MR_13)        ? ((|timer_mod_lpddr2   ) ? INIT_LPDDR4_FSM_MR_13 : INIT_LPDDR2_FSM_MR_1 ) :
                            // wait for t_mod cycles////If CS staggering is not supported
                            (current_state == INIT_LPDDR2_FSM_MR_1)         ? ((|timer_mod_lpddr2   ) ? INIT_LPDDR2_FSM_MR_1 : INIT_LPDDR2_FSM_MR_2 ) :
                            // wait for t_mod cycles////If CS staggering is not supported
                            (current_state == INIT_LPDDR2_FSM_MR_2)         ? ((|timer_mod_lpddr2   ) ? INIT_LPDDR2_FSM_MR_2 : INIT_LPDDR2_FSM_MR_3 ) :

                            // wait for t_mod cycles////If CS staggering is not supported
                            (current_state == INIT_LPDDR2_FSM_MR_3)         ? (((|timer_mod_lpddr2) || (!init_mr_done_in)) ? INIT_LPDDR2_FSM_MR_3 : INIT_LPDDR2_FSM_ZQINIT ) :
                            // wait for t_mod cycles////Issue ZQCAL_START and ZQCAL_LATCH command here
                            (current_state == INIT_LPDDR2_FSM_ZQINIT)       ? ((|timer_x32   ) ? INIT_LPDDR2_FSM_ZQINIT :
                                                                                INIT_FSM_REFRESH)   :
                            // wait for t_zqlat cycles////If CS staggering is not supported
                            (current_state == INIT_FSM_REFRESH)             ? (((|timer_x1) || (refresh_cnt != {$bits(refresh_cnt){1'b0}})) ? INIT_FSM_REFRESH : INIT_FSM_END) : INIT_FSM_END;

//----------------------------- Assign Commands --------------------------------


always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        refresh_pending <= 1'b0;
    end else begin
        if (init_refresh
            )
            refresh_pending <= 1'b0;                                                                    // Clear refresh_pending when the refresh is issued and another refresh is required
        else begin
            if ((current_state == INIT_FSM_REFRESH) && (refresh_cnt != {$bits(refresh_cnt){1'b0}}) && (timer_x1 == {$bits(timer_x1){1'b0}}))    // Set refresh_pending when timer_x1 (tRFC) expires
                refresh_pending <= 1'b1;
            else if ((current_state == INIT_FSM_REFRESH) && (prev_cycle_state != INIT_FSM_REFRESH))           // Set refresh_pending when entering REFRESH state
                refresh_pending <= 1'b1;
        end
    end
end


// start_refresh_timer pulse for the INIT state machine
// In DDR4, start refresh timer while changing to NORM mode from MPSM - REF disabled in MPSM (MPSM gotten from s_dh_operating_mode_r[2])

assign start_refresh_timer  =

                              (dh_gs_lpddr4) ? ((gs_dh_operating_mode == 3'b001) && (gs_dh_operating_mode_r == 3'b000) || (gs_dh_operating_mode_r == 3'b011 && self_refresh_after_skip_init)) :
                                           init_refresh || ((gs_dh_operating_mode == 3'b001) && ((gs_dh_operating_mode_r == 3'b000 & normal_mode_after_skip_init) || (gs_dh_operating_mode_r == 3'b011 && self_refresh_after_skip_init)));

assign load_mode        =
                          dh_gs_lpddr4 ? ((last_state != current_state) &&
                          ((current_state == INIT_LPDDR2_FSM_ZQINIT) ||
                          (current_state == INIT_LPDDR2_FSM_MR_1) || (current_state == INIT_LPDDR2_FSM_MR_2)
                          || (current_state == INIT_LPDDR2_FSM_MR_3)
                          || (current_state == INIT_LPDDR4_FSM_MR_13)
                          ))
                          // This logic should be corrected when new JEDEC spec will be reflected. (see bug 2859,2968)
                          | t_zqcal_expired
                           : // assign while performing MRW's
                          ((last_state != current_state) &&
                          ((current_state == INIT_FSM_MR_1)
                           || (current_state == INIT_FSM_EMR)
                           || (current_state == INIT_FSM_EMR2)
                           || (current_state == INIT_FSM_EMR3)
                           ));


wire dh_gs_ddr4_or_lpddr4;
assign  dh_gs_ddr4_or_lpddr4   =
                                    1'b0
                                    | dh_gs_lpddr4
                                    ;


wire gs_pi_init_cke_non_lpddr;

// For LPDDR4, same as DDR3

assign gs_pi_init_cke_non_lpddr   = !((current_state == INIT_FSM_START)                     ||
                                      (dh_gs_ddr4_or_lpddr4 && (current_state == INIT_DDR3_FSM_RESET)) );  // Adding lpddr4 configuration

// Put cke from the above logic (gs_pi_init_cke_non_lpddr)
assign gs_pi_init_cke = (gs_pi_init_cke_non_lpddr || normal_mode_after_skip_init);

// mask off one cycle after i_upd_req occurs
assign gs_pi_op_is_load_mode     = (i_upd_req_r
                                    | reg_ddrc_lpddr5
                                   ) ? 1'b0 : load_mode;
assign init_refresh     = (i_upd_req_r) ? 1'b0 : refresh_pending            // to be combined w/ normal refresh in GS before sending to PI
    ;






// mask off one cycle after i_upd_req occurs
assign start_zqcs_timer = (i_upd_req_r) ? 1'b0 : (zqcl_ddr3 | zqinit_lpddr2 | ((gs_dh_operating_mode == 3'b001) && ((gs_dh_operating_mode_r == 3'b000 & normal_mode_after_skip_init) || (gs_dh_operating_mode_r == 3'b011 & self_refresh_after_skip_init))  & dh_gs_ddr4_or_lpddr4));       // start the ZQ timers when ZQCL is first asserted
assign chip_select      = (load_mode | init_refresh | zqcl_ddr3);        // zqinit_lpddr2 is covered by load_mode

assign gs_pi_init_in_progress = (current_state != INIT_FSM_END);

assign init_cs_n        = ~chip_select;



// bank address: only matters for mode registers


//spyglass disable_block W415a
//SMD: Signal gs_pi_mrs_a is being assigned multiple times in same always block.
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches

always@(*) begin
    begin
            gs_pi_mrs_a = gs_pi_mrs_a_wire;
    end
end
//spyglass enable_block W415a

assign gs_pi_mrs_a_wire[MRS_A_BITS-1:16] = {(MRS_A_BITS-16){1'b0}};
assign gs_pi_mrs_a_wire[15:0]   =


                          (dh_gs_lpddr4 && (current_state == INIT_LPDDR4_FSM_MR_13))   ? {8'h0d, dh_gs_emr3[7:0]} :     // MR13 value

                          // This logic should be corrected when new JEDEC spec will be reflected. (see bug 2859,2968)
                          (dh_gs_lpddr4 && t_zqcal_expired)       ? 16'h0ABB                :     // MR10 value: This is translated to MPC(ZQCal Latch) command in pi module.
                         dh_gs_lpddr4                             ?
                        ((phy_dfi_init_complete == 0 && dh_gs_dfi_init_complete_en == 1'b1)  ? 16'h0700                :     // CA = NOP when phy init is not complete
                        (current_state == INIT_LPDDR2_FSM_ZQINIT) ? 16'h0AFF                :     // MR10 value
                        (current_state == INIT_LPDDR2_FSM_MR_1)   ? {8'h01, dh_gs_mr[7:0]}  :     // MR_1 value
                        (current_state == INIT_LPDDR2_FSM_MR_2)   ? {8'h02, dh_gs_emr[7:0]} :     // MR_2 value
                        {8'h03, dh_gs_emr2[7:0]}) :// MR_3 value

                          (current_state == INIT_FSM_EMR)               ? dh_gs_emr  :
                          (current_state == INIT_FSM_EMR2)              ? dh_gs_emr2 :
                          (current_state == INIT_FSM_EMR3)              ? dh_gs_emr3 :
                          (current_state == INIT_FSM_MR_1)              ? dh_gs_mr   :
                                                                          16'hFFFF; // for precharge all, A10=1

   assign init_mpc_zq_start = (!t_zqcal_expired && (current_state == INIT_LPDDR2_FSM_ZQINIT));
   assign init_mpc_zq_latch = t_zqcal_expired;


//------------ Resetable Flops: State, refresh counter, x1024 timer ------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
    if (~core_ddrc_rstn) begin
        resetb_ff               <= 1'b0;
        refresh_cnt             <= {$bits(refresh_cnt){1'b0}};
        current_state           <= INIT_FSM_START;
        last_state              <= INIT_FSM_START;
        prev_cycle_state        <= INIT_FSM_START;
        end_init_ddr            <= 1'b0;
        timer_x1024             <= 12'hFFF; // must come up as non-zero value
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep the current implementation.
        zqcl_ddr3               <= 1'b0;
        zqinit_lpddr2           <= 1'b0;
//spyglass enable_block W528
        gs_dh_operating_mode_r  <= 3'b000;
    end
    else begin
        prev_cycle_state <= current_state;

        if (current_state == INIT_FSM_START) begin
            if (dh_gs_per_bank_refresh & dh_gs_lpddr4)
                refresh_cnt <= num_init_refreshes << 3;     // Multiply by 8 for per-bank refreshes
            else
                refresh_cnt <= num_init_refreshes;
        end else

            refresh_cnt <= (init_refresh
                                           ) ? (refresh_cnt - {{($bits(refresh_cnt)-1){1'b0}},1'b1}) : refresh_cnt;

        if (init_not_paused || (current_state == INIT_FSM_START) || (current_state == INIT_FSM_CKE)
                || ((current_state == INIT_DDR3_FSM_RESET) && dh_gs_lpddr4)
            )    // No need to pause timer in INIT_FSM_START, INIT_FSM_CKE, INIT_DDR3_FSM_RESET state
           timer_x1024     <= set_timer_x1024   ? timer_x1024_value    :
                                (timer_pulse_x1024 & (|timer_x1024)) ? (timer_x1024 - {{($bits(timer_x1024)-1){1'b0}},1'b1}):
                                timer_x1024           ;

        current_state <= next_state;

        if (init_not_paused) begin
            resetb_ff <= 1'b1;
            last_state <= current_state;

            end_init_ddr    <= (current_state == INIT_FSM_END) ;
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep the current implementation.
            zqcl_ddr3           <= 1'b0;
            zqinit_lpddr2       <= ((current_state == INIT_LPDDR2_FSM_ZQINIT) && (last_state != INIT_LPDDR2_FSM_ZQINIT));
//spyglass enable_block W528

            gs_dh_operating_mode_r  <= gs_dh_operating_mode;
        end // if (init_not_paused)
    end // else: not in reset

//------------------- Non-Resetable Flops: Timers (x1, x32) --------------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
    if (~core_ddrc_rstn) begin
        timer_x1    <= {$bits(timer_x1){1'b0}};
        timer_x32   <= {$bits(timer_x32){1'b0}};
    end
    else begin
    // If we are in the final wait state, we don't want to pause the counters, even if a phyupd comes in.
    // This is because refreshes are disabled during this time, and we can get a tRFCmax violation if we wait too long in the final wait state
    // If we are in Refresh state, we should continue counting down.  refresh_pending will capture whether a refresh is pending, and a refresh will
    // be sent at the end of the update if necessary
    if (init_not_paused  || current_state == INIT_FSM_REFRESH) begin
        timer_x1    <= set_timer_x1      ? timer_x1_value       :
                       timer_x1 != {$bits(timer_x1){1'b0}} ? (timer_x1 - {{($bits(timer_x1)-1){1'b0}},1'b1})   :
                       timer_x1;
        timer_x32   <= set_timer_x32                    ? timer_x32_value     :
                       (timer_pulse_x32 & (|timer_x32)) ? (timer_x32 - {{($bits(timer_x32)-1){1'b0}},1'b1}) :
                                                          timer_x32           ;
    end
end // non-resetable flops

`ifndef SYNTHESIS
  `ifdef SYSTEM_VERILOG_ASSERT
// disable coverage collection as this is a check in SVA only
// VCS coverage off

// check on t_mr, for wait after mode register programming

reg[$bits(reg_ddrc_t_mr)-1:0]   mrd_cnt;   // timer for wait after mode register gets programmed

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
        mrd_cnt <= {$bits(mrd_cnt){1'b0}};
    else begin
        if (init_not_paused) begin
            if (1)
                mrd_cnt <= {$bits(mrd_cnt){1'b0}};
            else if (mrd_cnt[2:0] == 3'b111)
       mrd_cnt <= mrd_cnt;
            else
                mrd_cnt <= mrd_cnt + {{($bits(mrd_cnt)-1){1'b0}},1'b1};
        end // init_not_paused
    end
end

// check on t_mod: time to wait after finishing last mode register programming

reg[$bits(reg_ddrc_t_mr)-1:0]   mod_cnt;   // timer for wait after last mode register gets programmed

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
        mod_cnt <= {$bits(mod_cnt){1'b0}};
    else begin
       if (init_not_paused) begin

           if (&mod_cnt)            // prevent from overflowing
               mod_cnt <= mod_cnt;
           else if (~(&mod_cnt))
               mod_cnt <= mod_cnt + {{($bits(mod_cnt)-1){1'b0}},1'b1};
       end // if (init_not_paused)
    end
end


        // check on t_mrw, for wait after mode register programming, for LPDDR4
        reg[$bits(reg_ddrc_t_mr)-1:0]   mrw_cnt;   // timer for wait after mode register gets programmed
        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (~core_ddrc_rstn)
                mrw_cnt <= 10'b0;
            else begin
                if (init_not_paused) begin
                    if (((~(current_state == INIT_LPDDR4_FSM_MR_13) & (next_state_lpddr4 == INIT_LPDDR4_FSM_MR_13) |
                         ~(current_state == INIT_LPDDR2_FSM_MR_1)  & (next_state_lpddr4 == INIT_LPDDR2_FSM_MR_1)  |
                         ~(current_state == INIT_LPDDR2_FSM_MR_2)  & (next_state_lpddr4 == INIT_LPDDR2_FSM_MR_2)  |
                         ~(current_state == INIT_LPDDR2_FSM_MR_3)  & (next_state_lpddr4 == INIT_LPDDR2_FSM_MR_3)) & dh_gs_lpddr4))
                        mrw_cnt <= {$bits(mrw_cnt){1'b0}};
                    else if (~(&mrw_cnt) & (dh_gs_lpddr4))
                        mrw_cnt <= mrw_cnt + {{($bits(mrw_cnt)-1){1'b0}},1'b1};
                end // init_not_paused
            end
        end

//-------------
// DDR4 check
//-------------


//-------------
// LPDDR4 check
//-------------

// check on t_mrw: time to wait after finishing last mode register programming
// Note: tMRW is required for the interval between two MRW commands
//       Howervr, tMRD(dh_gs_t_mr)+2  is used here instead of tMRW, as always tMRD >= tMRW, to guarantee tMRD between MRW and ZQCAL.
//       "+2" is to compensate command length difference : (MRW is 4 clock command, MPC is 2 clock command)

property t_mr_check0_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 & ((current_state == INIT_LPDDR4_FSM_MR_13) & ~(next_state_lpddr4 == INIT_LPDDR4_FSM_MR_13))) |->
                (mrw_cnt >= reg_ddrc_t_mr);//tMRW
endproperty

a_t_mr_check0_lpddr4: assert property (t_mr_check0_lpddr4)  //
        else $error("%m %t wait after emr3(MR13) load is not long enough", $time);

property t_mr_check1_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 & ((current_state == INIT_LPDDR2_FSM_MR_1) & ~(next_state_lpddr4 == INIT_LPDDR2_FSM_MR_1))) |->
                (mrw_cnt >= reg_ddrc_t_mr);//tMRW
endproperty

a_t_mr_check1_lpddr4: assert property (t_mr_check1_lpddr4)  //
        else $error("%m %t wait after mr(MR1) load is not long enough", $time);

property t_mr_check2_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 & ((current_state == INIT_LPDDR2_FSM_MR_2) & ~(next_state_lpddr4 == INIT_LPDDR2_FSM_MR_2))) |->
                (mrw_cnt >= reg_ddrc_t_mr);//tMRW
endproperty

a_t_mr_check2_lpddr4: assert property (t_mr_check2_lpddr4)  //
        else $error("%m %t wait after emr(MR2) load is not long enough", $time);

property t_mr_check3_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 & ((current_state == INIT_LPDDR2_FSM_MR_3) & ~(next_state_lpddr4 == INIT_LPDDR2_FSM_MR_3))) |->
                (mrw_cnt >= reg_ddrc_t_mr + 2); //tMRD+2 - see comment in timer_mod_lpddr2 attribution
endproperty

a_t_mr_check3_lpddr4: assert property (t_mr_check3_lpddr4)  //
        else $error("%m %t wait after emr(MR3) load is not long enough", $time);

//
// Following property is prepared just to make sure the transition of FSM.
//   At least this should be kept for safety until dfi assertions for LPDDR4 (especially wrt REF/ZQ-cal) are updated.
property init_fsm_check_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 && (current_state != prev_cycle_state)) |->
                (!reg_ddrc_skip_dram_init[0]) && (
                    ((prev_cycle_state == INIT_FSM_START) && (current_state == INIT_DDR3_FSM_RESET)) ||
                    ((prev_cycle_state == INIT_DDR3_FSM_RESET) && (current_state == INIT_FSM_CKE)) ||
                    ((prev_cycle_state == INIT_FSM_CKE) && (current_state == INIT_LPDDR4_FSM_MR_13)) ||
                    ((prev_cycle_state == INIT_LPDDR4_FSM_MR_13) && (current_state == INIT_LPDDR2_FSM_MR_1)) ||
                    ((prev_cycle_state == INIT_LPDDR2_FSM_MR_1) && (current_state == INIT_LPDDR2_FSM_MR_2)) ||
                    ((prev_cycle_state == INIT_LPDDR2_FSM_MR_2) && (current_state == INIT_LPDDR2_FSM_MR_3)) ||
                    ((prev_cycle_state == INIT_LPDDR2_FSM_MR_3) && (current_state == INIT_LPDDR2_FSM_ZQINIT)) ||
                    ((prev_cycle_state == INIT_FSM_NOP) && (current_state == INIT_LPDDR2_FSM_ZQINIT)) ||
                    ((prev_cycle_state == INIT_LPDDR2_FSM_ZQINIT) && (current_state == INIT_FSM_NOP)) ||
                    ((prev_cycle_state == INIT_LPDDR2_FSM_ZQINIT) && (current_state == INIT_FSM_REFRESH)) ||
                    ((prev_cycle_state == INIT_FSM_REFRESH) && (current_state == INIT_FSM_END)) )
                ||
                (reg_ddrc_skip_dram_init == 2'b01) && (
                    ((prev_cycle_state == INIT_FSM_START) && (current_state == INIT_FSM_REFRESH)) ||
                    ((prev_cycle_state == INIT_FSM_REFRESH) && (current_state == INIT_FSM_END)) )

                ||
                (reg_ddrc_skip_dram_init == 2'b11) &&
                    (prev_cycle_state == INIT_FSM_START) && (current_state == INIT_FSM_END);
endproperty

a_init_fsm_check_lpddr4: assert property (init_fsm_check_lpddr4)  //
        else $error("%m %t Unexpected transition is observed in initialization FSM", $time);



// For dual channel mode
// Check that transition  of FSM is synchronized with dfi-reset_n signal of the other channel.
property sync_dfi_reset_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 & ((prev_cycle_state == INIT_FSM_START) & (current_state == INIT_DDR3_FSM_RESET))) |->
                (dfi_reset_n_in && dfi_reset_n_ref);
endproperty

a_sync_dfi_reset_lpddr4: assert property (sync_dfi_reset_lpddr4) // $info("%m %t PASSED: Transition was synchronized with dfi_reset_n signal of the other channel", $time);
        else $error("%m %t Transition was not synchronized with dfi_reset_n signal of the other channel", $time);

// For dual channel mode
// Check that transition  of FSM is synchronized with init_mr_done signal of the other channel.
property sync_init_mr_done_lpddr4;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (dh_gs_lpddr4 & ((prev_cycle_state == INIT_LPDDR2_FSM_MR_3) & (current_state == INIT_LPDDR2_FSM_ZQINIT))) |->
                (init_mr_done_in && init_mr_done_out);
endproperty

a_sync_init_mr_done_lpddr4: assert property (sync_init_mr_done_lpddr4) // $info("%m %t PASSED: Transition was synchronized with init_mr_done signal of the other channel", $time);
        else $error("%m %t Transition was not synchronized with init_mr_done signal of the other channel", $time);



//--------------------
// DDR4 check
//--------------------

`ifdef VCS
`endif // VCS - assertion library only supported for VCS

//--------------------
// CODE coverage check
//--------------------
// CODE coverage: phyupd and zqlat occured simultaneously during initialization sequence.
property p_zqlat_expired_sel_r_is_1;
  @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
  (zqlat_expired_sel_r == 1'b0);
endproperty

a_zqlat_expired_sel_r_is_1 : assert property (p_zqlat_expired_sel_r_is_1)
  else $error("%0t CODE_COVERAGE_ASSERTION - phyupd and zqlat occured simultaneously during initialization sequence. Line covered!", $time);

// VCS coverage on
  `endif // SYSTEM_VERILOG_ASSERT
`endif // SYNTHESIS

endmodule  // gs_init_ddr_fsm:  fsm to walk thru DDR2 initialization sequence
