//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_wck.sv#5 $
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

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//                              Description
//
// This is the WCK management module.
//
// ----------------------------------------------------------------------------

`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"

module gs_wck 
import DWC_ddrctl_reg_pkg::*;
#(
   //------------------------------- PARAMETERS -----------------------------------
   parameter            FREQ_RATIO                    = `MEMC_FREQ_RATIO,
   parameter            NUM_RANKS                     = `MEMC_NUM_RANKS,
   parameter            RANK_BITS                     = `MEMC_RANK_BITS,
   parameter            CMD_DELAY_BITS                = `UMCTL2_CMD_DELAY_BITS
)
(
   //------------------------- INPUTS AND OUTPUTS ---------------------------------
   input                                     core_ddrc_core_clk,           // clock
   input                                     core_ddrc_rstn,               // async falling-edge reset

   input    [NUM_RANKS-1:0]                  gs_rdwr_cs_n,                 // chip selects for read/write
   input    [NUM_RANKS-1:0]                  gs_other_cs_n,                // chip selects for MRR
   input                                     gs_op_is_rd,                  // RD command
   input                                     gs_op_is_wr,                  // WR command
   input                                     gs_cas_ws_req,                // CAS_WS
   input                                     gs_op_is_load_mode,           // MRS/MRR command is being issued to pi
   input                                     gs_pi_mrr,                    // Current MR command is an internally-generated MRR
   input                                     gs_pi_mrr_ext,                // Current MR command is an externally-generated MRR
   input                                     gs_op_is_enter_powerdown,     // send command to enter power-down
   input                                     gs_op_is_enter_selfref,       // self-refresh power down entry operation
   input                                     gs_op_is_enter_dsm,           // enter deep sleep mode
   input                                     gs_op_is_cas_ws_off,          // CAS_WS-OFF
   input    [CMD_DELAY_BITS-1:0]             dfi_cmd_delay,

   input    [READ_LATENCY_WIDTH-1:0]         dh_gs_read_latency,           // read latency
   input    [WRITE_LATENCY_WIDTH-1:0]        dh_gs_write_latency ,         // write latency
   input                                     reg_ddrc_lpddr5,              // LPDDR5 mode
   input    [BANK_ORG_WIDTH-1:0]             reg_ddrc_bank_org,
   input                                     reg_ddrc_frequency_ratio,     // 1: 1:4 mode, 0: 1:2 mode
   input    [DFI_TPHY_WRLAT_WIDTH-1:0]       reg_ddrc_dfi_tphy_wrlat,
   input    [DFI_T_RDDATA_EN_WIDTH-1:0]      reg_ddrc_dfi_t_rddata_en,
   input    [T_CKSRE_WIDTH-1:0]              reg_ddrc_t_cksre,             // tCSLCK

   input                                     reg_ddrc_wck_on,              // WCK always ON mode
   input    [DFI_TWCK_DELAY_WIDTH-1:0]       reg_ddrc_dfi_twck_delay,
   input    [DFI_TWCK_EN_RD_WIDTH-1:0]       reg_ddrc_dfi_twck_en_rd,      // WCK enable read timing
   input    [DFI_TWCK_EN_WR_WIDTH-1:0]       reg_ddrc_dfi_twck_en_wr,      // WCK enable write timing
   input    [DFI_TWCK_DIS_WIDTH-1:0]         reg_ddrc_dfi_twck_dis,        // WCK off timing
   input    [DFI_TWCK_FAST_TOGGLE_WIDTH-1:0] reg_ddrc_dfi_twck_fast_toggle,// from TOGGLE to FAST_TOGGLE
   input    [DFI_TWCK_TOGGLE_WIDTH-1:0]      reg_ddrc_dfi_twck_toggle,     // from dfi_wck_en to TOGGLE
   //spyglass disable_block W240
   //SMD: Input declared but not read.
   //SJ: temporary disabled. might use in the future
   input    [DFI_TWCK_TOGGLE_CS_WIDTH-1:0]   reg_ddrc_dfi_twck_toggle_cs,  // command to dfi_wck_cs
   //spyglass enable_block W240
   input    [DFI_TWCK_TOGGLE_POST_WIDTH-1:0] reg_ddrc_dfi_twck_toggle_post,// dfi_wck_cs remaining time

   output logic                              gs_wck_stop_ok,      // WCK stop flag
   output logic                              gs_cas_cmd_disable,  // CAS command disable
   output logic   [FREQ_RATIO*NUM_RANKS-1:0] gs_dfi_wck_cs,       // WCK chip select
   output logic   [FREQ_RATIO-1:0]           gs_dfi_wck_en,       // WCK clock enable
   output logic   [2*FREQ_RATIO-1:0]         gs_dfi_wck_toggle    // WCK toggle

);

   //---------------------------- LOCAL PARAMETERS --------------------------------
   // WCK toggle
   localparam  WCK_STATIC_LOW    = 2'b00;
   localparam  WCK_STATIC_HIGH   = 2'b01;
   localparam  WCK_TOGGLE        = 2'b10;
   localparam  WCK_FAST_TOGGLE   = 2'b11;

   localparam  ST_IDLE           = 2'b00;
   localparam  ST_STATIC_LOW     = 2'b01;
   localparam  ST_TOGGLE         = 2'b10;
   localparam  ST_FAST_TOGGLE    = 2'b11;

   localparam  BL_N_MIN_PH       = 8'd8;  // BL/n_min * phase
   localparam  DFI_WCK_CMD_GAP   = 8'd4;  // gap from WCK to CMD in DFI
   localparam  MIN_WS_OFF2CAS_M1 = 2'b10; // 3 - 1

   localparam  BG_MODE           = 2'b00;

   localparam  RANK_WIDTH        = 1;

   //------------------------------- REGISTERS ------------------------------------
   logic    [7:0]    num_phase;
   logic             op_is_mrr;              // MRR
   logic    [7:0]    cmd_ph_delay;
   logic    [7:0]    twck_en_rdwr_sel;
   logic    [7:0]    twck_en_rdwr;

   logic    [7:0]    rdwr_latency_wck;
   logic    [7:0]    bl_n_min;
   logic    [7:0]    toggle_period;
   logic    [7:0]    twck_dis_cmd_dly;       // reg_ddrc_dfi_twck_dis + cmd_ph_delay
   logic    [7:0]    wck_en_period;
   logic    [7:0]    tcslck_wck;
   logic    [7:0]    tcslck_cmd_dly;

   logic    [7:0]    bl_n_max_wck;
   logic    [7:0]    rd_latency_wck;
   logic    [7:0]    wr_latency_wck;
   logic    [7:0]    latency_wck;
   logic    [7:0]    twckpst;
   logic    [7:0]    rdwr_sync_period;
   logic             wck_sync_off;
   logic             wck_on_postamble_r;

   logic             cnt_wck_en_eq0_r;
   logic    [7:0]    cnt_wck_en_r;
   logic             cnt_wck_en_le_ph;       // cnt_wck_en_r <= num_phase
   logic    [7:0]    cnt_wck_en_m_ph;        // cnt_wck_en_r - num_phase

   logic    [7:0]    cnt_wck_dis_r;
   logic             cnt_wck_dis_le_ph;      // cnt_wck_dis_r <= num_phase
   logic    [7:0]    cnt_wck_dis_m_ph;       // cnt_wck_dis_r - num_phase

   logic    [7:0]    cnt_wck_dis_b4_en_r;
   logic             cnt_wck_dis_b4_en_le_ph;   // cnt_wck_dis_b4_en_r <= num_phase
   logic    [7:0]    cnt_wck_dis_b4_en_m_ph;    // cnt_wck_dis_b4_en_r - num_phase

   logic             wck_en_r;

   //logic    [1:0]    toggle_state_r;
   logic    [1:0]    wck_toggle_r;
   logic    [7:0]    cnt_toggle_start_r;
   logic    [7:0]    cnt_toggle_start_m_ph;  // cnt_toggle_start_r - num_phase
   logic             cnt_toggle_start_le_ph; // cnt_toggle_start_r <= num_phase

   logic    [7:0]    cnt_toggle_dis_r;
   logic    [7:0]    cnt_toggle_dis_m_ph;    // cnt_toggle_dis_r - num_phase
   logic             cnt_toggle_dis_le_ph;   // cnt_toggle_dis_r <= num_phase
   logic    [7:0]    cnt_toggle_dis_b4_en_r;
   logic    [7:0]    cnt_toggle_dis_b4_en_m_ph;    // cnt_toggle_dis_r - num_phase
   logic             cnt_toggle_dis_b4_en_le_ph;   // cnt_toggle_dis_r <= num_phase
   logic             wck_toggle_stop;

   logic    [NUM_RANKS-1:0]         cnt_wck_cs_eq0_r;
   logic    [NUM_RANKS-1:0][7:0]    cnt_wck_cs_r;
   logic    [NUM_RANKS-1:0]         cnt_wck_cs_le_ph;    // cnt_wck_cs_r <= num_phase
   logic    [NUM_RANKS-1:0][7:0]    cnt_wck_cs_m_ph;     // cnt_wck_cs_r - num_phase

   logic    [7:0]    cnt_wck_cs_post_r;
   logic             cnt_wck_cs_post_le_ph;        // cnt_wck_cs_post_r <= num_phase
   logic    [7:0]    cnt_wck_cs_post_m_ph;         // cnt_wck_cs_post_r - num_phase

   logic    [7:0]    cnt_wck_cs_post_b4_en_r;
   logic             cnt_wck_cs_post_b4_en_le_ph;  // cnt_wck_cs_post_b4_en_r <= num_phase
   logic    [7:0]    cnt_wck_cs_post_b4_en_m_ph;   // cnt_wck_cs_post_b4_en_r - num_phase

   logic    [NUM_RANKS-1:0][FREQ_RATIO-1:0]  wck_cs_freq;   // WCK chip select

   logic    [NUM_RANKS-1:0]   wck_cs_r;

   logic    [1:0]    cnt_ws_off2cas_r;

   logic    [DFI_TWCK_DELAY_WIDTH-1:0]    twck_delay_ck;
   logic    [DFI_TWCK_DELAY_WIDTH-1:0]    cnt_twck_delay_r;

   //------------------------
   // frequency ratio
   //------------------------
   assign   num_phase    = reg_ddrc_frequency_ratio ? 8'd4 : 8'd2;  // 1: 1:4 mode, 0: 1:2 mode
   assign   cmd_ph_delay = reg_ddrc_frequency_ratio ? {{(8-CMD_DELAY_BITS-2){1'b0}}, dfi_cmd_delay, 2'b00} :
                                                      {{(8-CMD_DELAY_BITS-1){1'b0}}, dfi_cmd_delay, 1'b0};


   assign   twck_en_rdwr_sel =
                               gs_op_is_wr  ? reg_ddrc_dfi_twck_en_wr :
                                              reg_ddrc_dfi_twck_en_rd;

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible

   //spyglass disable_block W164a
   //SMD: LHS: 'twck_en_rdwr' width 8 is less than RHS: '(twck_en_rdwr_sel + cmd_ph_delay)' width 9 in assignment
   //SJ: Overflow not possible
   assign   twck_en_rdwr     = twck_en_rdwr_sel + cmd_ph_delay;

   assign   rdwr_latency_wck = gs_op_is_wr ? {{(8 - DFI_TPHY_WRLAT_WIDTH){1'b0}},  reg_ddrc_dfi_tphy_wrlat} :
                                             {{(8 - DFI_T_RDDATA_EN_WIDTH){1'b0}}, reg_ddrc_dfi_t_rddata_en};

   // RL/WL + BL/n_min + twck_toggle_post + 1(delay in PI)
   assign   toggle_period    = rdwr_latency_wck + BL_N_MIN_PH +
                               reg_ddrc_dfi_twck_toggle_post + num_phase + cmd_ph_delay -
                               (((reg_ddrc_bank_org == BG_MODE) && reg_ddrc_dfi_twck_toggle_post[1:0] == 2'b11) ? 2 : 0);

   assign   twck_dis_cmd_dly =  reg_ddrc_dfi_twck_dis + cmd_ph_delay;

   // dfi_wck is 2 clock faster than command at 1:2.
   assign   wck_en_period    = rdwr_sync_period + cmd_ph_delay -
                               (reg_ddrc_frequency_ratio ? 8'd0 : 8'd2);

   // twckpst (twck_dis = roundup(tWCKPST) - 4)
   assign   twckpst          = reg_ddrc_dfi_twck_dis + 8'd4 - 8'd1;

   // select sync period
   assign   rdwr_sync_period = latency_wck + bl_n_max_wck + 
                               ((reg_ddrc_bank_org == BG_MODE) ? {twckpst[7:2], 2'd0} : twckpst);

   // BL/n_max (unit: WCK)
   assign   bl_n_max_wck   = (reg_ddrc_bank_org == BG_MODE) ? 8'd16 : 8'd8;

   // read latency (unit: WCK)
   assign   rd_latency_wck = reg_ddrc_frequency_ratio ? {dh_gs_read_latency[5:0], 2'd0} :
                                                        {dh_gs_read_latency[6:0], 1'b0};

   // write latency (unit: WCK)
   assign   wr_latency_wck = reg_ddrc_frequency_ratio ? {dh_gs_write_latency[5:0], 2'd0} :
                                                        {dh_gs_write_latency[6:0], 1'b0};

   // rd/wr latency
   assign   latency_wck    = gs_op_is_wr ? wr_latency_wck : rd_latency_wck;

   // tCSLCK (unit: wck)
   assign   tcslck_wck     = reg_ddrc_frequency_ratio ? {reg_ddrc_t_cksre[5:0], 2'd0} :
                                                        {reg_ddrc_t_cksre[6:0], 1'b0};

   assign   tcslck_cmd_dly = tcslck_wck + cmd_ph_delay - DFI_WCK_CMD_GAP +
                             (reg_ddrc_frequency_ratio ? {reg_ddrc_dfi_twck_dis[7:2], 2'd0} : {reg_ddrc_dfi_twck_dis[7:1], 1'b0});

   //spyglass enable_block W164a
   //spyglass enable_block W484

   // MRR command
   assign   op_is_mrr = gs_op_is_load_mode & (gs_pi_mrr | gs_pi_mrr_ext);

   // sync off
   assign   wck_sync_off = gs_op_is_enter_powerdown || gs_op_is_enter_selfref ||
                           gs_op_is_enter_dsm;

   //------------------------------- WCK SYNC OFF ---------------------------------
   // post-amble duration at WCK ON = 1
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         wck_on_postamble_r <= 1'b0;
      end
      else if (wck_sync_off | gs_op_is_cas_ws_off) begin
         wck_on_postamble_r <= 1'b1;
      end
      else if (cnt_toggle_dis_le_ph |
               ((cnt_wck_en_r != 8'd0) && (cnt_toggle_dis_b4_en_r != 8'd0) && cnt_toggle_dis_b4_en_le_ph)) begin
         wck_on_postamble_r <= 1'b0;
      end
   end

   //------------------------------- dfi_wck_en -----------------------------------
   //------------------------
   // count WCK enable
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_en_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && gs_cas_ws_req) begin
            cnt_wck_en_r <= twck_en_rdwr;
         end
         else if (cnt_wck_en_le_ph) begin
            cnt_wck_en_r <= 8'd0;
         end
         else begin
            cnt_wck_en_r <= cnt_wck_en_m_ph;
         end
      end
   end

   // twck_en_rdwr = 0 (no delay)
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_en_eq0_r <= 1'b0;
      end
      else if (reg_ddrc_lpddr5) begin
         if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && gs_cas_ws_req &&
             (twck_en_rdwr == {$bits(twck_en_rdwr){1'b0}})) begin
            cnt_wck_en_eq0_r <= 1'b1;
         end
         else begin
            cnt_wck_en_eq0_r <= 1'b0;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible
   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_wck_en_m_ph' width 8 is less than RHS: '(cnt_wck_en_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_wck_en_m_ph  =  cnt_wck_en_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_wck_en_le_ph = (cnt_wck_en_r <= num_phase);

   //------------------------
   // count WCK disable
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_dis_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (gs_op_is_rd || op_is_mrr || gs_op_is_wr) begin
            cnt_wck_dis_r <= wck_en_period;
         end
         else if (wck_sync_off && wck_en_r) begin
            cnt_wck_dis_r <= tcslck_cmd_dly;
         end
         else if (gs_op_is_cas_ws_off && wck_en_r) begin
            cnt_wck_dis_r <= twck_dis_cmd_dly;
         end
         else if (cnt_wck_dis_le_ph) begin
            cnt_wck_dis_r <= 8'd0;
         end
         else if (!reg_ddrc_wck_on || wck_on_postamble_r) begin
            cnt_wck_dis_r <= cnt_wck_dis_m_ph;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible
   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_wck_dis_m_ph' width 8 is less than RHS: '(cnt_wck_dis_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_wck_dis_m_ph  = cnt_wck_dis_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_wck_dis_le_ph = (cnt_wck_dis_r <= num_phase);

   //------------------------
   // count WCK disable between command and enabled timing
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_dis_b4_en_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (!cnt_wck_dis_le_ph &&
             (gs_op_is_rd || op_is_mrr || gs_op_is_wr) && gs_cas_ws_req) begin
            cnt_wck_dis_b4_en_r <= cnt_wck_dis_m_ph;
         end
         else if (!cnt_wck_dis_b4_en_le_ph) begin
            cnt_wck_dis_b4_en_r <= cnt_wck_dis_b4_en_m_ph;
         end
         else begin
            cnt_wck_dis_b4_en_r <= 8'd0;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible
   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_wck_dis_b4_en_m_ph' width 8 is less than RHS: '(cnt_wck_dis_b4_en_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_wck_dis_b4_en_m_ph  = cnt_wck_dis_b4_en_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_wck_dis_b4_en_le_ph = (cnt_wck_dis_b4_en_r <= num_phase);

   //------------------------
   // dfi_wck_en
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         wck_en_r <= 1'b0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (cnt_wck_en_eq0_r || ((cnt_wck_en_r != 8'd0) && cnt_wck_en_le_ph)) begin
            wck_en_r <= 1'b1;
         end
         else if (cnt_wck_dis_le_ph &&
                  !((gs_op_is_rd || gs_op_is_wr || op_is_mrr) && !gs_cas_ws_req)) begin
            wck_en_r <= 1'b0;
         end
         else if ((cnt_wck_dis_b4_en_r != 8'd0) && cnt_wck_dis_b4_en_le_ph && (cnt_wck_en_r != 8'd0)) begin
            wck_en_r <= 1'b0;
         end
         else if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && !gs_cas_ws_req &&
                  (cnt_toggle_dis_r == 8'd0) && !reg_ddrc_frequency_ratio) begin    // wck signals are 2 clock earlier than commadn at 1:2 mode
            wck_en_r <= 1'b1;
         end
      end
   end

   //spyglass disable_block W163
   //SMD: Truncation of bits in constant. Most significant bits are lost
   //SJ: Temporary disabling. This failure happend when FREQ_RATIO_2. But it can not be supported.
   always_comb begin
      if (~reg_ddrc_lpddr5) begin
         gs_dfi_wck_en = 4'b0000;
      end
      else if (cnt_wck_en_eq0_r) begin
         gs_dfi_wck_en = 4'b1111;
      end
      else if (wck_en_r) begin
         if ((cnt_wck_en_r != 8'd0) && (cnt_wck_dis_b4_en_r != 8'd0) && cnt_wck_dis_b4_en_le_ph) begin
            unique case  (cnt_wck_dis_b4_en_r[1:0])
               2'd3     :  gs_dfi_wck_en = 4'b0111;
               2'd2     :  gs_dfi_wck_en = 4'b0011;
               2'd1     :  gs_dfi_wck_en = 4'b0001;
               default  :  gs_dfi_wck_en = 4'b1111;
            endcase
         end
         else if (~cnt_wck_dis_le_ph) begin
            gs_dfi_wck_en = 4'b1111;
         end
         else begin
            unique case  (cnt_wck_dis_r[1:0])
               2'd3     :  gs_dfi_wck_en = 4'b0111;
               2'd2     :  gs_dfi_wck_en = 4'b0011;
               2'd1     :  gs_dfi_wck_en = 4'b0001;
               default  :  gs_dfi_wck_en = 4'b1111;
            endcase
         end
      end
      else if ((cnt_wck_en_r != 8'd0) && cnt_wck_en_le_ph) begin
         unique case  (cnt_wck_en_r[1:0])
            2'd3     :  gs_dfi_wck_en = 4'b1000;
            2'd2     :  gs_dfi_wck_en = 4'b1100;
            2'd1     :  gs_dfi_wck_en = 4'b1110;
            default  :  gs_dfi_wck_en = 4'b0000;
         endcase
      end
      else if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && !gs_cas_ws_req &&
               (cnt_wck_en_r == 8'd0) && !reg_ddrc_frequency_ratio) begin    // wck signals are 2 clock earlier than commadn at 1:2 mode
         gs_dfi_wck_en = 4'b1111;
      end
      else begin
         gs_dfi_wck_en = 4'b0000;
      end
   end
   //spyglass enable_block W163

   // twck_delay core clock
   assign twck_delay_ck = reg_ddrc_frequency_ratio ?
                                 {2'b00, reg_ddrc_dfi_twck_delay[DFI_TWCK_DELAY_WIDTH-1:2]} +
                                 {{DFI_TWCK_DELAY_WIDTH-1{1'b0}}, (|reg_ddrc_dfi_twck_delay[1:0])} :
                                 {1'b0, reg_ddrc_dfi_twck_delay[DFI_TWCK_DELAY_WIDTH-1:1]} +
                                 {{DFI_TWCK_DELAY_WIDTH-1{1'b0}}, reg_ddrc_dfi_twck_delay[0]};

   // count twck_delay
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_twck_delay_r <= {DFI_TWCK_DELAY_WIDTH{1'b0}};
      end
      else if (|gs_dfi_wck_en) begin
         cnt_twck_delay_r <= twck_delay_ck;
      end
      else if (|cnt_twck_delay_r) begin
         cnt_twck_delay_r <= cnt_twck_delay_r - {{DFI_TWCK_DELAY_WIDTH-1{1'b0}}, 1'b1};
      end
   end

   // WCK stop flag
   assign gs_wck_stop_ok = ~(|gs_dfi_wck_en) & ~(|cnt_twck_delay_r);

   //------------------------------- dfi_wck_toggle -------------------------------
   //------------------------
   // count CAS_WS-OFF to CAS
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_ws_off2cas_r <= 2'b00;
      end
      else if (gs_op_is_cas_ws_off) begin
         cnt_ws_off2cas_r <= MIN_WS_OFF2CAS_M1;
      end
      else if (|cnt_ws_off2cas_r) begin
         cnt_ws_off2cas_r <= cnt_ws_off2cas_r - 2'b01;
      end
   end

   //------------------------
   // CAS command disable period
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         gs_cas_cmd_disable <= 1'b0;
      end
      else if (gs_op_is_cas_ws_off) begin
         gs_cas_cmd_disable <= 1'b1;
      end
      else if (~(|cnt_ws_off2cas_r)) begin
         gs_cas_cmd_disable <= 1'b0;
      end
   end

   //------------------------------- dfi_wck_toggle -------------------------------
   //------------------------
   // count WCK toggle start
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_toggle_start_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if ((twck_en_rdwr == 8'd0) &&
             (gs_op_is_rd || op_is_mrr || gs_op_is_wr) && gs_cas_ws_req) begin
            cnt_toggle_start_r <= reg_ddrc_dfi_twck_toggle;
         end
         else if (cnt_wck_en_le_ph && (cnt_wck_en_r != 8'd0)) begin
            //spyglass disable_block W484
            //SMD: Possible assignment overflow: lhs width 8
            //SJ: Overflow not possible
            //spyglass disable_block W164a
            //SMD: LHS: 'cnt_toggle_start_r' width 8 is less than RHS: '(cnt_wck_en_m_ph + reg_ddrc_dfi_twck_toggle)' width 9 in assignment
            //SJ: Overflow not possible
            cnt_toggle_start_r <= cnt_wck_en_m_ph + reg_ddrc_dfi_twck_toggle;
            //spyglass enable_block W164a
            //spyglass enable_block W484
         end
         else if (cnt_toggle_start_le_ph && (cnt_toggle_start_r != 8'd0)) begin
            //spyglass disable_block W484
            //SMD: Possible assignment overflow: lhs width 8
            //SJ: Overflow not possible
            //spyglass disable_block W164a
            //SMD: LHS: 'cnt_toggle_start_r' width 8 is less than RHS: '(cnt_toggle_start_m_ph + reg_ddrc_dfi_twck_fast_toggle)' width 9 in assignment
            //SJ: Overflow not possible
            //if ((toggle_state_r == ST_STATIC_LOW) && (reg_ddrc_dfi_twck_fast_toggle != 8'd0)) begin
            if ((wck_toggle_r == WCK_STATIC_LOW) && (reg_ddrc_dfi_twck_fast_toggle != 8'd0)) begin
               cnt_toggle_start_r <= cnt_toggle_start_m_ph + reg_ddrc_dfi_twck_fast_toggle;
            end
            //spyglass enable_block W164a
            //spyglass enable_block W484
            else begin 
               cnt_toggle_start_r <= 8'd0;
            end
         end
         else if (!cnt_toggle_start_le_ph) begin
            cnt_toggle_start_r <= cnt_toggle_start_m_ph;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible
   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_toggle_start_m_ph' width 8 is less than RHS: '(cnt_toggle_start_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_toggle_start_m_ph  = cnt_toggle_start_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_toggle_start_le_ph = (cnt_toggle_start_r <= num_phase);

   //------------------------
   // count WCK toggle disable
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_toggle_dis_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (gs_op_is_rd || gs_op_is_wr || op_is_mrr) begin
            cnt_toggle_dis_r <= toggle_period;
         end
         else if (wck_sync_off && wck_en_r) begin
            cnt_toggle_dis_r <= tcslck_cmd_dly;
         end
         else if (gs_op_is_cas_ws_off && wck_en_r) begin
            cnt_toggle_dis_r <= twck_dis_cmd_dly;
         end
         else if (cnt_toggle_dis_le_ph) begin
            cnt_toggle_dis_r <= 8'd0;
         end
         else if (!reg_ddrc_wck_on || wck_on_postamble_r) begin
            cnt_toggle_dis_r <= cnt_toggle_dis_m_ph;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible
   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_toggle_dis_m_ph' width 8 is less than RHS: '(cnt_toggle_dis_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_toggle_dis_m_ph  = cnt_toggle_dis_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_toggle_dis_le_ph = (cnt_toggle_dis_r <= num_phase);

   //------------------------
   // count WCK toggle disable before re-enable
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_toggle_dis_b4_en_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (!cnt_toggle_dis_le_ph &&
             (gs_op_is_rd || gs_op_is_wr || op_is_mrr) && gs_cas_ws_req) begin
            cnt_toggle_dis_b4_en_r <= cnt_toggle_dis_m_ph;
         end
         else if (!cnt_toggle_dis_b4_en_le_ph) begin
            cnt_toggle_dis_b4_en_r <= cnt_toggle_dis_b4_en_m_ph;
         end
         else begin
            cnt_toggle_dis_b4_en_r <= 8'd0;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible
   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_toggle_dis_b4_en_m_ph' width 8 is less than RHS: '(cnt_toggle_dis_b4_en_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_toggle_dis_b4_en_m_ph  = cnt_toggle_dis_b4_en_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_toggle_dis_b4_en_le_ph = (cnt_toggle_dis_b4_en_r <= num_phase);




   assign   wck_toggle_stop      = (((cnt_toggle_dis_r != 8'd0) && cnt_toggle_dis_le_ph &&
                                     !((gs_op_is_rd || gs_op_is_wr || op_is_mrr) && !gs_cas_ws_req)) ||
                                    ((cnt_toggle_dis_b4_en_r != 8'd0) && cnt_toggle_dis_b4_en_le_ph && (cnt_wck_en_r != 8'd0)));

   //------------------------
   // dfi_wck_toggle
   //------------------------
   //ccx_fsm:; wck_toggle_r; WCK_FAST_TOGGLE->WCK_TOGGLE; This transition never happen. See Bug 12962.
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         wck_toggle_r <= WCK_STATIC_LOW;
      end
      else if (reg_ddrc_lpddr5) begin
         if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && gs_cas_ws_req && (twck_en_rdwr == 8'd0)) begin
            wck_toggle_r <= WCK_STATIC_LOW;
         end
         else if ((cnt_wck_en_r != 8'd0) && cnt_wck_en_le_ph) begin
            wck_toggle_r <= WCK_STATIC_LOW;
         end
         else if ((cnt_toggle_start_r != 8'd0) && cnt_toggle_start_le_ph) begin
            if (wck_toggle_r == WCK_STATIC_LOW) begin
               wck_toggle_r <= WCK_TOGGLE;
            end
            else if ((wck_toggle_r == WCK_TOGGLE) && (reg_ddrc_dfi_twck_fast_toggle != 8'd0)) begin
               wck_toggle_r <= WCK_FAST_TOGGLE;
            end
         end
         else if (wck_toggle_stop) begin
            wck_toggle_r <= WCK_STATIC_LOW;
         end
         else if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && !gs_cas_ws_req &&
                  (cnt_toggle_dis_r == 8'd0) && !reg_ddrc_frequency_ratio) begin    // wck signals are 2 clock earlier than commadn at 1:2 mode
            wck_toggle_r <= WCK_TOGGLE;
         end
      end
   end

   //spyglass disable_block W163
   //SMD: Significant bits of constant will be truncated
   //SJ: Temporary disabling. This failure happend when FREQ_RATIO_2. But it can not be supported.
   //
   //spyglass disable_block W164a
   //SMD: LHS: 'gs_dfi_wck_toggle' width 4 is less than RHS: width 8 in assignment
   //SJ: Temporary disabling. This failure happend when FREQ_RATIO_2. But it can not be supported.
   always_comb begin
      if (~reg_ddrc_lpddr5) begin
         gs_dfi_wck_toggle = {FREQ_RATIO{WCK_STATIC_LOW}};
      end
      else if ((cnt_wck_en_r != 8'd0) && (cnt_toggle_dis_b4_en_r != 8'd0) && cnt_toggle_dis_b4_en_le_ph) begin
         unique case  (cnt_toggle_dis_b4_en_r[1:0])
            2'd3     :  gs_dfi_wck_toggle = {   WCK_STATIC_LOW,   {3{wck_toggle_r}}};
            2'd2     :  gs_dfi_wck_toggle = {{2{WCK_STATIC_LOW}}, {2{wck_toggle_r}}};
            2'd1     :  gs_dfi_wck_toggle = {{3{WCK_STATIC_LOW}},    wck_toggle_r  };
            default  :  gs_dfi_wck_toggle = {FREQ_RATIO{wck_toggle_r}};
         endcase
      end
      else if ((cnt_toggle_start_r != 8'd0) && cnt_toggle_start_le_ph) begin
         if (wck_toggle_r == WCK_STATIC_LOW) begin
            unique case  (cnt_toggle_start_r[1:0])
               2'd3     :  gs_dfi_wck_toggle = {   WCK_TOGGLE  , {3{WCK_STATIC_LOW}}};
               2'd2     :  gs_dfi_wck_toggle = {{2{WCK_TOGGLE}}, {2{WCK_STATIC_LOW}}};
               2'd1     :  gs_dfi_wck_toggle = {{3{WCK_TOGGLE}},    WCK_STATIC_LOW  };
               default  :  gs_dfi_wck_toggle =  {4{WCK_STATIC_LOW}};
            endcase
         end
         else if ((wck_toggle_r == WCK_TOGGLE) && (reg_ddrc_dfi_twck_fast_toggle != 8'd0)) begin
            unique case  (cnt_toggle_start_r[1:0])
               2'd3     :  gs_dfi_wck_toggle = {   WCK_FAST_TOGGLE  , {3{WCK_TOGGLE}}};
               2'd2     :  gs_dfi_wck_toggle = {{2{WCK_FAST_TOGGLE}}, {2{WCK_TOGGLE}}};
               2'd1     :  gs_dfi_wck_toggle = {{3{WCK_FAST_TOGGLE}},    WCK_TOGGLE  };
               default  :  gs_dfi_wck_toggle =  {4{WCK_TOGGLE}};
            endcase
         end
         else begin
            gs_dfi_wck_toggle = {FREQ_RATIO{wck_toggle_r}};
         end
      end
      else if ((cnt_toggle_dis_r != 8'd0) && cnt_toggle_dis_le_ph &&
               !((gs_op_is_rd || gs_op_is_wr || op_is_mrr) && !gs_cas_ws_req)) begin
         unique case  (cnt_toggle_dis_r[1:0])
            2'd3     :  gs_dfi_wck_toggle = {   WCK_STATIC_LOW,   {3{wck_toggle_r}}};
            2'd2     :  gs_dfi_wck_toggle = {{2{WCK_STATIC_LOW}}, {2{wck_toggle_r}}};
            2'd1     :  gs_dfi_wck_toggle = {{3{WCK_STATIC_LOW}},    wck_toggle_r  };
            default  :  gs_dfi_wck_toggle = {FREQ_RATIO{wck_toggle_r}};
         endcase
      end
      else if ((gs_op_is_rd || op_is_mrr || gs_op_is_wr) && !gs_cas_ws_req &&
               (cnt_toggle_dis_r == 8'd0) && !reg_ddrc_frequency_ratio) begin    // wck signals are 2 clock earlier than commadn at 1:2 mode
         gs_dfi_wck_toggle = {FREQ_RATIO{WCK_TOGGLE}};
      end
      else begin
         gs_dfi_wck_toggle = {FREQ_RATIO{wck_toggle_r}};
      end
   end
   //spyglass enable_block W163
   //spyglass enable_block W164a


   //------------------------------- dfi_wck_cs -----------------------------------
genvar   gv_rank;
for (gv_rank = 0; gv_rank<NUM_RANKS; gv_rank++) begin
   //------------------------
   // count CS enable
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_cs_r[gv_rank] <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (!reg_ddrc_wck_on && gs_cas_ws_req &&
             (((gs_op_is_rd || gs_op_is_wr) && !gs_rdwr_cs_n[gv_rank]) ||
              ( op_is_mrr                   && !gs_other_cs_n[gv_rank]))) begin
            cnt_wck_cs_r[gv_rank] <= twck_en_rdwr;
         end
         else if (reg_ddrc_wck_on && gs_cas_ws_req &&
                  (gs_op_is_rd || gs_op_is_wr || op_is_mrr)) begin
            cnt_wck_cs_r[gv_rank] <= twck_en_rdwr;
         end
         else if (cnt_wck_cs_le_ph[gv_rank]) begin
            cnt_wck_cs_r[gv_rank] <= 8'd0;
         end
         else begin
            cnt_wck_cs_r[gv_rank] <= cnt_wck_cs_m_ph[gv_rank];
         end
      end
   end

   // twck_en_rdwr = 0 (no delay)
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_cs_eq0_r[gv_rank] <= 1'b0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (!reg_ddrc_wck_on && gs_cas_ws_req &&
             (twck_en_rdwr == {$bits(twck_en_rdwr){1'b0}}) &&
             (((gs_op_is_rd || gs_op_is_wr) && !gs_rdwr_cs_n[gv_rank]) ||
              ( op_is_mrr                   && !gs_other_cs_n[gv_rank]))) begin
            cnt_wck_cs_eq0_r[gv_rank] <= 1'b1;
         end
         else if (reg_ddrc_wck_on && gs_cas_ws_req &&
                  (twck_en_rdwr == {$bits(twck_en_rdwr){1'b0}}) &&
                  (gs_op_is_rd || gs_op_is_wr || op_is_mrr)) begin
            cnt_wck_cs_eq0_r[gv_rank] <= 1'b1;
         end
         else begin
            cnt_wck_cs_eq0_r[gv_rank] <= 1'b0;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible

   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_wck_cs_m_ph[gv_rank]' width 8 is less than RHS: '(cnt_wck_cs_r[gv_rank] - num_phase)' width 9 in assignment 
   //SJ: Overflow not possible
   assign   cnt_wck_cs_m_ph[gv_rank]  =  cnt_wck_cs_r[gv_rank] - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_wck_cs_le_ph[gv_rank] = (cnt_wck_cs_r[gv_rank] <= num_phase);

end   // for (gv_rank = 0; gv_rank<NUM_RANKS; gv_rank++)

   //------------------------
   // count WCK post
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_cs_post_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (gs_op_is_rd || gs_op_is_wr || op_is_mrr) begin
            cnt_wck_cs_post_r <= wck_en_period;
         end
         else if (wck_sync_off && wck_en_r) begin
            cnt_wck_cs_post_r <= tcslck_cmd_dly;
         end
         else if (gs_op_is_cas_ws_off && wck_en_r) begin
            cnt_wck_cs_post_r <= twck_dis_cmd_dly;
         end
         else if (cnt_wck_cs_post_le_ph) begin
            cnt_wck_cs_post_r <= 8'd0;
         end
         else if (!reg_ddrc_wck_on || wck_on_postamble_r) begin
            cnt_wck_cs_post_r <= cnt_wck_cs_post_m_ph;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible

   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_wck_cs_post_m_ph' width 8 is less than RHS: '(cnt_wck_cs_post_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_wck_cs_post_m_ph  =  cnt_wck_cs_post_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_wck_cs_post_le_ph = (cnt_wck_cs_post_r <= num_phase);

   //------------------------
   // count WCK post between command and enabled timing
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         cnt_wck_cs_post_b4_en_r <= 8'd0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (!cnt_wck_cs_post_le_ph &&
             (gs_op_is_rd || gs_op_is_wr || op_is_mrr) && gs_cas_ws_req) begin
            cnt_wck_cs_post_b4_en_r <= cnt_wck_cs_post_m_ph;
         end
         else if (!cnt_wck_cs_post_b4_en_le_ph) begin
            cnt_wck_cs_post_b4_en_r <= cnt_wck_cs_post_b4_en_m_ph;
         end
         else begin
            cnt_wck_cs_post_b4_en_r <= 8'd0;
         end
      end
   end

   //spyglass disable_block W484
   //SMD: Possible assignment overflow: lhs width 8
   //SJ: Overflow not possible

   //spyglass disable_block W164a
   //SMD: LHS: 'cnt_wck_cs_post_b4_en_m_ph' width 8 is less than RHS: '(cnt_wck_cs_post_b4_en_r - num_phase)' width 9 in assignment
   //SJ: Overflow not possible
   assign   cnt_wck_cs_post_b4_en_m_ph  =  cnt_wck_cs_post_b4_en_r - num_phase;
   //spyglass enable_block W164a
   //spyglass enable_block W484
   assign   cnt_wck_cs_post_b4_en_le_ph = (cnt_wck_cs_post_b4_en_r <= num_phase);


for (gv_rank = 0; gv_rank<NUM_RANKS; gv_rank++) begin
   //------------------------
   // dfi_wck_cs
   //------------------------
   always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         wck_cs_r[gv_rank] <= 1'b0;
      end
      else if (reg_ddrc_lpddr5) begin
         if (cnt_wck_cs_eq0_r[gv_rank] || ((cnt_wck_cs_r[gv_rank] != 8'd0) && cnt_wck_cs_le_ph[gv_rank])) begin
            wck_cs_r[gv_rank] <= 1'b1;
         end
         else if (cnt_wck_cs_post_le_ph &&
                  !((gs_op_is_rd || gs_op_is_wr || op_is_mrr) && !gs_cas_ws_req)) begin
            wck_cs_r[gv_rank] <= 1'b0;
         end
         //else if ((|cnt_wck_cs_r) && cnt_wck_cs_post_b4_en_le_ph) begin
         else if ((|cnt_wck_cs_r) && (cnt_wck_cs_post_b4_en_r != 8'd0) && cnt_wck_cs_post_b4_en_le_ph) begin
            wck_cs_r[gv_rank] <= 1'b0;
         end
         else if (!gs_cas_ws_req &&
                  (((gs_op_is_rd || gs_op_is_wr) && !gs_rdwr_cs_n[gv_rank]) ||
                   ( op_is_mrr                   && !gs_other_cs_n[gv_rank])) &&
                  (cnt_toggle_dis_r == 8'd0) && !reg_ddrc_frequency_ratio) begin    // wck signals are 2 clock earlier than commadn at 1:2 mode
            wck_cs_r[gv_rank] <= 1'b1;
         end
      end
   end

   //spyglass disable_block W163
   //SMD: Significant bits of constant will be truncated
   //SJ: Temporary disabling. This failure happend when FREQ_RATIO_2. But it can not be supported.
   always_comb begin
      if (cnt_wck_cs_eq0_r[gv_rank]) begin
            wck_cs_freq[gv_rank] = 4'b1111;
      end
      else if (wck_cs_r[gv_rank]) begin
         if ((cnt_wck_en_r != 8'd0) && (cnt_wck_cs_post_b4_en_r != 8'd0) && cnt_wck_cs_post_b4_en_le_ph) begin
            unique case  (cnt_wck_cs_post_b4_en_r[1:0])
               2'd3     :  wck_cs_freq[gv_rank] = 4'b0111;
               2'd2     :  wck_cs_freq[gv_rank] = 4'b0011;
               2'd1     :  wck_cs_freq[gv_rank] = 4'b0001;
               default  :  wck_cs_freq[gv_rank] = 4'b1111;
            endcase
         end
         else if (~cnt_wck_cs_post_le_ph) begin
            wck_cs_freq[gv_rank] = 4'b1111;
         end
         else if (cnt_wck_cs_post_le_ph) begin
            unique case  (cnt_wck_cs_post_r[1:0])
               2'd3     :  wck_cs_freq[gv_rank] = 4'b0111;
               2'd2     :  wck_cs_freq[gv_rank] = 4'b0011;
               2'd1     :  wck_cs_freq[gv_rank] = 4'b0001;
               default  :  wck_cs_freq[gv_rank] = 4'b1111;
            endcase
         end
         else begin
            wck_cs_freq[gv_rank] = 4'b1111;
         end
      end
      else if ((cnt_wck_cs_r[gv_rank] != 8'd0) && cnt_wck_cs_le_ph[gv_rank]) begin
         unique case  (cnt_wck_cs_r[gv_rank][1:0])
            2'd3     :  wck_cs_freq[gv_rank] = 4'b1000;
            2'd2     :  wck_cs_freq[gv_rank] = 4'b1100;
            2'd1     :  wck_cs_freq[gv_rank] = 4'b1110;
            default  :  wck_cs_freq[gv_rank] = 4'b0000;     // cnt_wck_cs_r = 4
         endcase
      end
      else if (!gs_cas_ws_req &&
               (((gs_op_is_rd || gs_op_is_wr) && !gs_rdwr_cs_n[gv_rank]) ||
                ( op_is_mrr                   && !gs_other_cs_n[gv_rank])) &&
               (cnt_toggle_dis_r == 8'd0) && !reg_ddrc_frequency_ratio) begin    // wck signals are 2 clock earlier than commadn at 1:2 mode
         wck_cs_freq[gv_rank] = 4'b1111;
      end
      else begin
         wck_cs_freq[gv_rank] = 4'b0000;
      end
   end
   //spyglass enable_block W163

end   // for (gv_rank = 0; gv_rank<NUM_RANKS; gv_rank++)


   int   rank_num;
   int   ph_num;

   always_comb begin
      if (reg_ddrc_lpddr5) begin
         for (rank_num = 0; rank_num < NUM_RANKS; rank_num++) begin
            for (ph_num = 0; ph_num < FREQ_RATIO; ph_num++) begin
               gs_dfi_wck_cs[ph_num*NUM_RANKS+rank_num] = wck_cs_freq[rank_num][ph_num];
            end
         end
      end
      else begin
         gs_dfi_wck_cs = {$bits(gs_dfi_wck_cs){1'b0}};
      end
   end

endmodule
