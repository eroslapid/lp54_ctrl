//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pi/pi_assertions.sv#1 $
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
//                              Description
//
// ----------------------------------------------------------------------------


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

`include "DWC_ddrctl_all_defs.svh"
module pi_assertions (
        co_pi_clk,
        core_ddrc_rstn,
        pi_ph_stop_clk,
        dh_pi_lpddr4,
        lpddr4_row17_exist,
        active_ranks,
        dh_pi_burst_rdwr,  
        dh_pi_per_bank_refresh,
        pi_ph_cs,
        pi_ph_cas_n,
        pi_ph_ras_n,
        pi_ph_we_n,
        pi_ph_bank,
        pi_ph_addr,
        pi_ph_cke,
        ctrlupd_req,
        phyupd_pause_req,
        upd_ok_lpddr4,
        pi_gs_ctrlupd_ok,
        pi_gs_phyupd_pause_ok,
        col_addr,

        gs_op_is_load_mode,
        gs_op_is_act,
        gs_op_is_pre,
        gs_op_is_rd,
        gs_op_is_wr,
        gs_op_is_enter_selfref,
        gs_op_is_exit_selfref,
        gs_op_is_enter_powerdown,
        gs_op_is_exit_powerdown,
        gs_op_is_ref,
        gs_pi_wr_mode,
        gs_pre_rankbank_num,
        gs_rdwr_rankbank_num,
        gs_act_rankbank_num,
        gs_pi_refpb_bank,
        gs_op_is_enter_sr_lpddr,
        gs_op_is_exit_sr_lpddr,
        gs_pi_mrr,
        gs_pi_mrr_ext,
        gs_pi_mrs_a,
        gs_mpc_zq_start,
        gs_mpc_zq_latch,
        gs_mpc_dqsosc_start,
        ts_act_page,
        te_pi_rd_blk,
        te_pi_wr_blk,
        te_pi_rd_word,
        te_autopre,
        ts_pi_mwr,
        
        reg_ddrc_lpddr5,
        ts_act2_invalid_tmg,
        pi_lp5_preref_ok,
        t_aad_timer_r,
        pi_lp5_act2_cmd,
        act2_req_r,
        act2_out_en,
        te_pi_wr_word,
        dh_pi_frequency_ratio
        );

parameter       CMD_LEN_BITS    = 1;
// NOTE: Changing this requires changing `defines in ddrc_parameters.v

parameter       RANK_BITS       = `MEMC_RANK_BITS;
parameter       LRANK_BITS      = `DDRCTL_DDRC_LRANK_BITS;
parameter       BG_BITS         = `MEMC_BG_BITS;
parameter       BANK_BITS       = `MEMC_BANK_BITS;
parameter       BG_BANK_BITS    = `MEMC_BG_BANK_BITS;
parameter       ROW_BITS        = `MEMC_PAGE_BITS;
parameter       BLK_BITS        = `MEMC_BLK_BITS;
parameter       WORD_BITS       = `MEMC_WORD_BITS;
parameter       CID_WIDTH       = `DDRCTL_DDRC_CID_WIDTH; 

parameter       MRS_A_BITS      = `MEMC_PAGE_BITS;
parameter       MRS_BA_BITS     = `MEMC_BG_BANK_BITS;

parameter       T_CCD_WIDTH     = 1;

parameter       MAX_CMD_NUM     = 2;

localparam      RANKBANK_BITS   = LRANK_BITS + BG_BANK_BITS;
localparam      NUM_RANKS       = 1 << RANK_BITS;

// values for counting COL accesses etc
// max for rdwr_bl is 64 - 4*16
localparam MAX_BL_WD       = 5; // max of MEMC_BURST_LENGTH_16 => 5 bits for 16
localparam MAX_BL_WD_BW    = MAX_BL_WD + 2; // for QBW => MEMC_BURST_LENGTH_16 * 4
localparam MAX_BL_WD_BW_M1 = MAX_BL_WD_BW - 1; // used to cnt COL - half of MAX_BL_WD_BW as


/////////////////////////////////////////////////////////////////////

input                               co_pi_clk;           // clock
input                               core_ddrc_rstn;      // active-low reset

input   [3:0]                       dh_pi_burst_rdwr;    // 4'h0010=burst of 4 data read/write
                                                         // 4'h0100=burst of 8 data read/write
                                                         // 4'h1000=burst of 16 data read/write
wire                                dh_pi_2t;
wire                            reg_ddrc_ddr4;
assign dh_pi_2t      = 1'b0;
assign reg_ddrc_ddr4 = 1'b0;
wire                            reg_ddrc_wr_crc_enable=0;
input                               pi_ph_stop_clk;
input                               dh_pi_lpddr4;
input                               lpddr4_row17_exist;
input   [NUM_RANKS-1:0]             active_ranks;

input [`MEMC_FREQ_RATIO-1:0]        pi_ph_ras_n;      // output RAS_n to PHY
input [`MEMC_FREQ_RATIO-1:0]        pi_ph_cas_n;      // output CAS_n to PHY
input [`MEMC_FREQ_RATIO-1:0]        pi_ph_we_n;       // output WE_n to PHY

input                                       dh_pi_per_bank_refresh;
input [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]      pi_ph_cs;    // output CS to PHY

input [BANK_BITS-1:0]                       pi_ph_bank;  // output bank # to PHY


input   DWC_ddrctl_dfi_pkg::dfi_address_s   pi_ph_addr;

input   [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]  pi_ph_cke;

input                                       ctrlupd_req;
input                                       phyupd_pause_req;
input                                       upd_ok_lpddr4;
input                                       pi_gs_ctrlupd_ok;
input                                       pi_gs_phyupd_pause_ok;
input [15:0]                                col_addr;


input                                   gs_op_is_act;
input                                   gs_op_is_pre;
input                                   gs_op_is_load_mode;
input                                   gs_op_is_rd;
input                                   gs_op_is_wr;
input                                   gs_op_is_enter_selfref;
input                                   gs_op_is_exit_selfref;
input                                   gs_op_is_enter_powerdown;
input                                   gs_op_is_exit_powerdown;
input                                   gs_op_is_ref;
input                                   gs_pi_wr_mode;
   input  [RANKBANK_BITS-1:0] gs_pre_rankbank_num;
   input  [RANKBANK_BITS-1:0] gs_rdwr_rankbank_num;
   input  [RANKBANK_BITS-1:0] gs_act_rankbank_num;
   input [BANK_BITS-1:0]      gs_pi_refpb_bank;
input                                   gs_op_is_enter_sr_lpddr;
input                                   gs_op_is_exit_sr_lpddr;
input                                   gs_pi_mrr;
input                                   gs_pi_mrr_ext;
input[MRS_A_BITS-1:0]                   gs_pi_mrs_a;
input                                   gs_mpc_zq_start;
input                                   gs_mpc_zq_latch;
input                                   gs_mpc_dqsosc_start;
input[ROW_BITS-1:0]                     ts_act_page; 
input[BLK_BITS-1:0]                     te_pi_rd_blk; 
input[BLK_BITS-1:0]                     te_pi_wr_blk; 
input[WORD_BITS-1:0]                    te_pi_rd_word;          
input[WORD_BITS-1:0]                    te_pi_wr_word;          
input                                   dh_pi_frequency_ratio;  
input                                   te_autopre;
input                                   ts_pi_mwr;

input                                   reg_ddrc_lpddr5;
input                                   ts_act2_invalid_tmg;
input                                   pi_lp5_preref_ok;
input  [4:0]                            t_aad_timer_r;
input                                   pi_lp5_act2_cmd;
input                                   act2_req_r;
input                                   act2_out_en;


wire[2:0]       data_cycles;

//------------------------------------------------------------------------------
// assignment
//------------------------------------------------------------------------------

wire  [MAX_CMD_NUM * BANK_BITS-1:0]  gs_pi_bank_num;
wire  [MAX_CMD_NUM * BG_BITS-1:0]    gs_pi_bg_num;


assign gs_pi_bank_num[        0+:BANK_BITS] = gs_op_is_act ? gs_act_rankbank_num [0+:BANK_BITS] :
                                              gs_op_is_pre ? gs_pre_rankbank_num [0+:BANK_BITS] :
                                                             gs_rdwr_rankbank_num[0+:BANK_BITS];
assign gs_pi_bank_num[BANK_BITS+:BANK_BITS] = gs_op_is_ref ? gs_pi_refpb_bank:
                                                             gs_pre_rankbank_num [0+:BANK_BITS];

assign gs_pi_bg_num[      0+:BG_BITS] = gs_op_is_act ? gs_act_rankbank_num [0+:BG_BITS] :
                                                       gs_rdwr_rankbank_num[0+:BG_BITS];
assign gs_pi_bg_num[BG_BITS+:BG_BITS] = gs_pre_rankbank_num [0+:BG_BITS];


//------------------------------------------------------------------------------

assign data_cycles = 4'h0;

wire  [2:0] dh_pi_data_cycles;
assign dh_pi_data_cycles = data_cycles;
  
parameter COLUMN_BITS = BLK_BITS+WORD_BITS;

reg                            pi_ph_cke_r;

always @ (posedge co_pi_clk) begin
        pi_ph_cke_r <= pi_ph_cke[0];
end







   


////////////////////////
// pi_ph_cs_n check
////////////////////////

wire bypass_cmd;  // bypass command
wire other_cmd;  // non-bypass command
wire bypass_rwa_cmd;
wire other_rwa_cmd;
wire other_non_rwa_cmd;
wire any_cmd;  // any command
wire any_rwa_cmd;
wire any_non_rwa_cmd;
wire rd_or_wr_cmd;  // read or write, or bypass read


assign any_cmd = bypass_cmd | other_cmd;
assign bypass_cmd = bypass_rwa_cmd ;
assign other_cmd  = other_rwa_cmd  | other_non_rwa_cmd;

assign any_rwa_cmd = bypass_rwa_cmd | other_rwa_cmd;
assign any_non_rwa_cmd = other_non_rwa_cmd;

assign bypass_rwa_cmd = 
                1'b0;


assign other_rwa_cmd = 
    gs_op_is_act        | gs_op_is_rd              | gs_op_is_wr
                ;

assign other_non_rwa_cmd = gs_op_is_pre | gs_op_is_enter_selfref | gs_op_is_ref  | gs_op_is_load_mode      
                           ;

// enter_powerdown, exit_powerdown and exit_selfref do not require a cs_n assertion

assign rd_or_wr_cmd =
    gs_op_is_rd 
// rd_or_wr_cmd used in cs_n_split* checkers - disable these for WR if
  // PARTIAL_WR enabled    
                ;



////////////////////////
// pi_ph_addr check
////////////////////////

reg        r_act_any;
reg        r_gs_op_is_act;
reg        r_gs_wr_mode;
reg[2:0]   r_column_addr_shift;
reg        r_scheduled_rd;
reg        r_scheduled_wr;


reg[ROW_BITS-1:0]       r_te_wr_row;
reg[ROW_BITS-1:0]       r_te_rd_row;
reg[COLUMN_BITS-1:0]    r_te_rd_column;
reg[COLUMN_BITS-1:0]    r_te_wr_column;
wire[14:0]              te_wr_column;
wire[14:0]              te_rd_column;

wire[14:0]              pi_ph_addr_column;


assign te_rd_column = r_column_addr_shift[2] ? {1'b0,r_te_rd_column[10:0], 3'b0} :
                      r_column_addr_shift[1] ? {2'b0, r_te_rd_column[10:0], 2'b0} :
                      r_column_addr_shift[0] ? {3'b0, r_te_rd_column[10:0], 1'b0} : {4'b0, r_te_rd_column[10:0]};

assign te_wr_column = r_column_addr_shift[2] ? {1'b0,r_te_wr_column[10:0], 3'b0} :
                      r_column_addr_shift[1] ? {2'b0, r_te_wr_column[10:0], 2'b0} :
                      r_column_addr_shift[0] ? {3'b0, r_te_wr_column[10:0], 1'b0} : {4'b0, r_te_wr_column[10:0]};

always @ (posedge co_pi_clk or negedge core_ddrc_rstn)
                      r_column_addr_shift <= 3'b000;  

always @ (posedge co_pi_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    r_act_any <= 1'b0;
    r_gs_op_is_act <= 1'b0;
    r_gs_wr_mode <= 1'b0;
    r_scheduled_rd <= 1'b0;    // scheduled read
    r_scheduled_wr <= 1'b0;    // scheduled write
    r_te_wr_row <= {ROW_BITS{1'b0}};
    r_te_rd_row <= {ROW_BITS{1'b0}};
    r_te_rd_column <= {COLUMN_BITS{1'b0}};
    r_te_wr_column <= {COLUMN_BITS{1'b0}};
  end
  else begin
    r_act_any <= gs_op_is_act;
    r_gs_op_is_act <= gs_op_is_act;
    r_gs_wr_mode <= gs_pi_wr_mode;
    r_scheduled_rd <= gs_op_is_rd;          // scheduled read
    r_scheduled_wr <= gs_op_is_wr;          // scheduled write
    r_te_wr_row <= ts_act_page;
    r_te_rd_row <= ts_act_page;
    r_te_rd_column <= {te_pi_rd_blk, te_pi_rd_word};
    r_te_wr_column <= {te_pi_wr_blk, te_pi_wr_word};
  end




/////////////////////////////
//  LPDDR4 command check
/////////////////////////////
`define LP4CMD_RD    8'b00010_111
`define LP4CMD_WR    8'b00100_111
`define LP4CMD_MWR   9'b001100_111
`define LP4CMD_CAS2  8'b10010_111
`define LP4CMD_ACT1  5'b01_111
`define LP4CMD_ACT2  5'b11_111
`define LP4CMD_MRW1  8'b00110_111
`define LP4CMD_MRW2  8'b10110_111
`define LP4CMD_MRR1  8'b01110_111
`define LP4CMD_REF   8'b01000_111
`define LP4CMD_PRE   8'b10000_111
`define LP4CMD_SRE   8'b11000_111
`define LP4CMD_SRX   8'b10100_111
`define LP4CMD_MPC   8'b00000_111

reg r_gs_mrw;
reg r_gs_mrr;
reg r_gs_mrw_zqs;
reg r_gs_mrw_zql;
reg r_mpc_dqsosc;
reg [MRS_A_BITS-1:0]     r_gs_mrs_a;
reg [`MEMC_FREQ_RATIO * BANK_BITS-1:0]  r_gs_bank_num;
reg [`MEMC_FREQ_RATIO * RANK_BITS-1:0]  r_gs_rank_num;
reg     r_gs_ref;
reg     r_gs_pre;
reg     r_gs_pre_all;
reg [MAX_CMD_NUM * NUM_RANKS-1:0] r_cmd_cs_n;
reg [`MEMC_FREQ_RATIO * NUM_RANKS-1:0] r_pi_ph_cke;
reg     r_te_autopre;
reg     r_ts_pi_mwr;
reg     r_gs_sre;
reg     r_gs_srx;

wire      lpddr4_bl;
assign lpddr4_bl=1'b0;  // This is always set to BL16 until BL32 mode is implemented.


always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        r_gs_mrw <= 1'b0;
        r_gs_mrr <= 1'b0;
        r_gs_mrw_zqs <= 1'b0;
        r_gs_mrw_zql <= 1'b0;
        r_mpc_dqsosc <= 1'b0;
        r_gs_mrs_a <= {MRS_A_BITS{1'b0}};
        r_gs_ref <= 1'b0;
        r_gs_pre <= 1'b0;
        r_gs_pre_all <= 1'b0;
        r_gs_bank_num <= {`MEMC_FREQ_RATIO*BANK_BITS{1'b0}};
        r_gs_rank_num <= 0;
        r_cmd_cs_n <= 0;
        r_pi_ph_cke   <= {`MEMC_FREQ_RATIO*NUM_RANKS{1'b0}};
        r_te_autopre <= 1'b0;
        r_ts_pi_mwr <= 1'b0;
        r_gs_sre <= 1'b0;
        r_gs_srx <= 1'b0;
    end
    else begin
        r_gs_mrw     <= gs_op_is_load_mode & ~(gs_pi_mrr | gs_pi_mrr_ext);
        r_gs_mrr     <= gs_op_is_load_mode &  (gs_pi_mrr | gs_pi_mrr_ext);
        r_gs_mrw_zqs <= gs_op_is_load_mode & ~(gs_pi_mrr | gs_pi_mrr_ext) & gs_mpc_zq_start;
//                    (gs_pi_mrs_a[7:0]==8'hab || gs_pi_mrs_a[7:0]==8'h56 || gs_pi_mrs_a[7:0]==8'hff) & (gs_pi_mrs_a[13:8]==6'h0a);
        r_gs_mrw_zql <= gs_op_is_load_mode & ~(gs_pi_mrr | gs_pi_mrr_ext) & gs_mpc_zq_latch;
        r_mpc_dqsosc <= gs_op_is_load_mode & ~(gs_pi_mrr | gs_pi_mrr_ext) & gs_mpc_dqsosc_start;
//                      (gs_pi_mrs_a[7:0]==8'hbb) & (gs_pi_mrs_a[13:8]==6'h0a);
    //  r_gs_mrs_a   <= gs_pi_mrs_a;
        r_gs_mrs_a   <= ((gs_op_is_load_mode) && ~(gs_pi_mrr | gs_pi_mrr_ext) && (gs_pi_mrs_a[7:0]==8'hc3) && (gs_pi_mrs_a[13:8]==7'h0a))?
                        {gs_pi_mrs_a[MRS_A_BITS-1:8],8'h01} : gs_pi_mrs_a;
        r_gs_ref     <= gs_op_is_ref;
        r_gs_pre     <= gs_op_is_pre;
        r_gs_pre_all <= 0;
        r_gs_bank_num <= gs_pi_bank_num;
        r_gs_rank_num <= 0;
        r_cmd_cs_n    <= 0;
        r_pi_ph_cke   <= pi_ph_cke;
        r_te_autopre <= te_autopre;
        r_ts_pi_mwr  <= ts_pi_mwr;
        r_gs_sre     <= gs_op_is_enter_sr_lpddr;
        r_gs_srx     <= gs_op_is_exit_sr_lpddr;
    end
end

wire [28*NUM_RANKS-1:0] lpddr4_cmd_trg_all;


    // Coverage group
    covergroup cg_pi_cmd_lpddr4_rank(
        reg  [27:0]     lpddr4_cmd_trg,
        reg             lpddr4_cmd_rd_trg,
        reg             lpddr4_cmd_wr_trg,
        reg             lpddr4_cmd_mwr_trg,
        reg             lpddr4_cmd_bypass_rd_trg
    ) @(posedge co_pi_clk);
        // Observe all trigger of genarating command
        cp_pi_cmd_lpddr4 : coverpoint (lpddr4_cmd_trg) iff(core_ddrc_rstn & dh_pi_lpddr4) {
            bins  lpddr4_cmd_rd_bl16    = {28'b1000_0000_0000_0000_0000_0000_0000};
            bins  lpddr4_cmd_rda_bl16   = {28'b0100_0000_0000_0000_0000_0000_0000};
        //  bins  lpddr4_cmd_rd_bl32    = {28'b0010_0000_0000_0000_0000_0000_0000};
        //  bins  lpddr4_cmd_rda_bl32   = {28'b0001_0000_0000_0000_0000_0000_0000};
            bins  lpddr4_cmd_wr_bl16    = {28'b0000_1000_0000_0000_0000_0000_0000};
            bins  lpddr4_cmd_wra_bl16   = {28'b0000_0100_0000_0000_0000_0000_0000};
        //  bins  lpddr4_cmd_wr_bl32    = {28'b0000_0010_0000_0000_0000_0000_0000};
        //  bins  lpddr4_cmd_wra_bl32   = {28'b0000_0001_0000_0000_0000_0000_0000};
            bins  lpddr4_cmd_mwr        = {28'b0000_0000_1000_0000_0000_0000_0000};
            bins  lpddr4_cmd_mwra       = {28'b0000_0000_0100_0000_0000_0000_0000};
            bins  lpddr4_cmd_act0       = {28'b0000_0000_0010_0000_0000_0000_0000};
            bins  lpddr4_cmd_act1       = {28'b0000_0000_0001_0000_0000_0000_0000};
            bins  lpddr4_cmd_mrw        = {28'b0000_0000_0000_0001_0000_0000_0000};
            bins  lpddr4_cmd_mrr        = {28'b0000_0000_0000_0000_1000_0000_0000};
            bins  lpddr4_cmd_zqc        = {28'b0000_0000_0000_0000_0100_0000_0000};
            bins  lpddr4_cmd_refab      = {28'b0000_0000_0000_0000_0010_0000_0000};
            bins  lpddr4_cmd_refpb      = {28'b0000_0000_0000_0000_0001_0000_0000};
            bins  lpddr4_cmd_preab      = {28'b0000_0000_0000_0000_0000_1000_0000};
            bins  lpddr4_cmd_prepb      = {28'b0000_0000_0000_0000_0000_0100_0000};
            bins  lpddr4_cmd_sre        = {28'b0000_0000_0000_0000_0000_0010_0000};
            bins  lpddr4_cmd_srx        = {28'b0000_0000_0000_0000_0000_0001_0000};
            bins  lpddr4_cmd_srpde      = {28'b0000_0000_0000_0000_0000_0000_1000};
            bins  lpddr4_cmd_srpdx      = {28'b0000_0000_0000_0000_0000_0000_0100};
            bins  lpddr4_cmd_pde        = {28'b0000_0000_0000_0000_0000_0000_0010};
            bins  lpddr4_cmd_pdx        = {28'b0000_0000_0000_0000_0000_0000_0001};
        }

        // Observe col address for read command
        cp_pi_cmd_lpddr4_col_rd : coverpoint ({lpddr4_cmd_rd_trg,col_addr[1:0]}) iff(core_ddrc_rstn & dh_pi_lpddr4) {
                    bins  lpddr4_00    = {{1'b1,2'b00}};
            illegal_bins  lpddr4_01    = {{1'b1,2'b01}};
            illegal_bins  lpddr4_10    = {{1'b1,2'b10}};
            illegal_bins  lpddr4_11    = {{1'b1,2'b11}};
        }

        // Observe col address for write command
        cp_pi_cmd_lpddr4_col_wr : coverpoint ({lpddr4_cmd_wr_trg,col_addr[3:0]}) iff(core_ddrc_rstn & dh_pi_lpddr4) {
                    bins  lpddr4_0000    = {{1'b1,4'b0000}};
            illegal_bins  lpddr4_0001    = {{1'b1,4'b0001}};
            illegal_bins  lpddr4_0010    = {{1'b1,4'b0010}};
            illegal_bins  lpddr4_0011    = {{1'b1,4'b0011}};
            illegal_bins  lpddr4_0100    = {{1'b1,4'b0100}};
            illegal_bins  lpddr4_0101    = {{1'b1,4'b0101}};
            illegal_bins  lpddr4_0110    = {{1'b1,4'b0110}};
            illegal_bins  lpddr4_0111    = {{1'b1,4'b0111}};
            illegal_bins  lpddr4_1000    = {{1'b1,4'b1000}};
            illegal_bins  lpddr4_1001    = {{1'b1,4'b1001}};
            illegal_bins  lpddr4_1010    = {{1'b1,4'b1010}};
            illegal_bins  lpddr4_1011    = {{1'b1,4'b1011}};
            illegal_bins  lpddr4_1100    = {{1'b1,4'b1100}};
            illegal_bins  lpddr4_1101    = {{1'b1,4'b1101}};
            illegal_bins  lpddr4_1110    = {{1'b1,4'b1110}};
            illegal_bins  lpddr4_1111    = {{1'b1,4'b1111}};
        }

        // Observe col address for masked write command
        cp_pi_cmd_lpddr4_col_mwr : coverpoint ({lpddr4_cmd_mwr_trg,col_addr[3:0]}) iff(core_ddrc_rstn & dh_pi_lpddr4) {
                    bins  lpddr4_0000    = {{1'b1,4'b0000}};
            illegal_bins  lpddr4_0001    = {{1'b1,4'b0001}};
            illegal_bins  lpddr4_0010    = {{1'b1,4'b0010}};
            illegal_bins  lpddr4_0011    = {{1'b1,4'b0011}};
            illegal_bins  lpddr4_0100    = {{1'b1,4'b0100}};
            illegal_bins  lpddr4_0101    = {{1'b1,4'b0101}};
            illegal_bins  lpddr4_0110    = {{1'b1,4'b0110}};
            illegal_bins  lpddr4_0111    = {{1'b1,4'b0111}};
            illegal_bins  lpddr4_1000    = {{1'b1,4'b1000}};
            illegal_bins  lpddr4_1001    = {{1'b1,4'b1001}};
            illegal_bins  lpddr4_1010    = {{1'b1,4'b1010}};
            illegal_bins  lpddr4_1011    = {{1'b1,4'b1011}};
            illegal_bins  lpddr4_1100    = {{1'b1,4'b1100}};
            illegal_bins  lpddr4_1101    = {{1'b1,4'b1101}};
            illegal_bins  lpddr4_1110    = {{1'b1,4'b1110}};
            illegal_bins  lpddr4_1111    = {{1'b1,4'b1111}};
        }

    endgroup // cg_pi_cmd_lpddr4_rank


generate
  genvar nk;
  for (nk=0; nk < NUM_RANKS; nk=nk+1) begin : pi_cov_gen
    //-------------------------------------------------------------------------------------
    wire[8:0] lpddr4_cmd_ph0;
    wire[8:0] lpddr4_cmd_ph1;
    wire[8:0] lpddr4_cmd_ph2;
    wire[8:0] lpddr4_cmd_ph3;
    wire      cmd_cs_lower_match;
    wire      cmd_cs_upper_match;
    wire      lpddr4_cmd_rd_trg;
    wire      lpddr4_cmd_wr_trg;
    wire      lpddr4_cmd_mwr_trg;
    wire      lpddr4_cmd_act0_trg;
    wire      lpddr4_cmd_act1_trg;
    wire      lpddr4_cmd_bypass_rd_trg;
    wire      lpddr4_cmd_bypass_act_trg;
    wire      lpddr4_cmd_mrw_trg;
    wire      lpddr4_cmd_mrr_trg;
    wire      lpddr4_cmd_zqc_trg;
    wire      lpddr4_cmd_ref_trg;
    wire      lpddr4_cmd_pre_trg;
    wire      lpddr4_cmd_sre_trg;
    wire      lpddr4_cmd_srx_trg;
    wire      lpddr4_cmd_srpde_trg;
    wire      lpddr4_cmd_srpdx_trg;
    wire      lpddr4_cmd_pde_trg;
    wire      lpddr4_cmd_pdx_trg;

    assign lpddr4_cmd_ph0 = {pi_ph_addr.p0[0+:6],pi_ph_cs[nk],pi_ph_cke[nk],r_pi_ph_cke[nk]};
    assign lpddr4_cmd_ph1 = {pi_ph_addr.p1[0+:6],pi_ph_cs[NUM_RANKS+nk],pi_ph_cke[NUM_RANKS+nk],r_pi_ph_cke[NUM_RANKS+nk]};
    assign lpddr4_cmd_ph2 = {pi_ph_addr.p2[0+:6],pi_ph_cs[2*NUM_RANKS+nk],pi_ph_cke[2*NUM_RANKS+nk],r_pi_ph_cke[2*NUM_RANKS+nk]};
    assign lpddr4_cmd_ph3 = {pi_ph_addr.p3[0+:6],pi_ph_cs[3*NUM_RANKS+nk],pi_ph_cke[3*NUM_RANKS+nk],r_pi_ph_cke[3*NUM_RANKS+nk]};
    assign cmd_cs_upper_match = (r_cmd_cs_n[NUM_RANKS+nk]==0);
    assign cmd_cs_lower_match = (r_cmd_cs_n[nk]==0);

    // command check trigger
    assign lpddr4_cmd_rd_trg  = (r_scheduled_rd && r_gs_rank_num[RANK_BITS-1:0]==nk);
    assign lpddr4_cmd_wr_trg  = (r_scheduled_wr && ~r_ts_pi_mwr && r_gs_rank_num[RANK_BITS-1:0]==nk);
    assign lpddr4_cmd_mwr_trg = (r_scheduled_wr &&  r_ts_pi_mwr && r_gs_rank_num[RANK_BITS-1:0]==nk);
    assign lpddr4_cmd_act0_trg  = (r_act_any && r_gs_op_is_act && ~r_gs_wr_mode && r_gs_rank_num[RANK_BITS-1:0]==nk);
    assign lpddr4_cmd_act1_trg  = (r_act_any && r_gs_op_is_act && r_gs_wr_mode && r_gs_rank_num[RANK_BITS-1:0]==nk);



    assign lpddr4_cmd_mrw_trg = (r_gs_mrw && ~r_gs_mrw_zqs && ~r_gs_mrw_zql
                                 && ~r_mpc_dqsosc
                                 && cmd_cs_upper_match);
    assign lpddr4_cmd_mrr_trg = (r_gs_mrr && cmd_cs_upper_match);
    assign lpddr4_cmd_zqc_trg = (r_gs_mrw_zqs && cmd_cs_upper_match);
    assign lpddr4_cmd_ref_trg = (r_gs_ref && cmd_cs_upper_match);
    assign lpddr4_cmd_pre_trg = ((r_gs_pre || r_gs_pre_all) && cmd_cs_lower_match);
    assign lpddr4_cmd_sre_trg = r_gs_sre & active_ranks[nk];
    assign lpddr4_cmd_srx_trg = r_gs_srx & active_ranks[nk];
    assign lpddr4_cmd_srpde_trg = gs_op_is_enter_selfref & active_ranks[nk];
    assign lpddr4_cmd_srpdx_trg = gs_op_is_exit_selfref  & active_ranks[nk];
    assign lpddr4_cmd_pde_trg = gs_op_is_enter_powerdown & active_ranks[nk];
    assign lpddr4_cmd_pdx_trg = gs_op_is_exit_powerdown  & active_ranks[nk];


    reg [`MEMC_FREQ_RATIO * BANK_BITS-1:0]  r_gs_bank_num2;
    reg                                     r_te_autopre2;

    always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            r_gs_bank_num2   <= {`MEMC_FREQ_RATIO*BANK_BITS{1'b0}};
            r_te_autopre2 <= 1'b0;
        end
        else if(lpddr4_cmd_rd_trg || lpddr4_cmd_wr_trg || lpddr4_cmd_mwr_trg || lpddr4_cmd_bypass_rd_trg) begin
            r_gs_bank_num2   <= r_gs_bank_num;
            r_te_autopre2 <= r_te_autopre;
        end
    end


    // split command is not supported yet.
    property lpddr4_cmd_rd;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_rd_trg) |->
               (lpddr4_cmd_ph0=={lpddr4_bl,`LP4CMD_RD})
            && (lpddr4_cmd_ph1=={$past(te_autopre,1),te_rd_column[9],1'b0,r_gs_bank_num[BANK_BITS-1:0],3'b011}) 
            && ((~dh_pi_frequency_ratio) ? 1'b1 :
                                           (lpddr4_cmd_ph2=={te_rd_column[8]  ,`LP4CMD_CAS2}) &&
                                           (lpddr4_cmd_ph3=={te_rd_column[7:2],3'b011})
               )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={$past(te_rd_column[8]  ,1),`LP4CMD_CAS2}) &&  
                                             (lpddr4_cmd_ph1=={$past(te_rd_column[7:2],1),3'b011}) ) :
                                           1'b1;
    endproperty

    // split command is not supported yet.
    property lpddr4_cmd_wr;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_wr_trg) |->
                (lpddr4_cmd_ph0=={lpddr4_bl,`LP4CMD_WR})
            &&  (lpddr4_cmd_ph1=={$past(te_autopre,1),te_wr_column[9],1'b0,r_gs_bank_num[BANK_BITS-1:0],3'b011})
            &&  ((~dh_pi_frequency_ratio) ? 1'b1 : 
                                            (lpddr4_cmd_ph2=={te_wr_column[8  ],`LP4CMD_CAS2}) &&
                                            (lpddr4_cmd_ph3=={te_wr_column[7:4],2'b00,3'b011})
                )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={$past(te_wr_column[8  ],1),`LP4CMD_CAS2}) && 
                                             (lpddr4_cmd_ph1=={$past(te_wr_column[7:4],1),2'b00,3'b011}) ) :
                                           1'b1;
    endproperty

    
    // split command is not supported yet.
    property lpddr4_cmd_mwr;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_mwr_trg) |->
                (lpddr4_cmd_ph0=={`LP4CMD_MWR})
            &&  (lpddr4_cmd_ph1=={$past(te_autopre,1),te_wr_column[9],1'b0,r_gs_bank_num[BANK_BITS-1:0],3'b011})
            &&  ((~dh_pi_frequency_ratio) ? 1'b1 : 
                                            (lpddr4_cmd_ph2=={te_wr_column[8  ],`LP4CMD_CAS2}) &&
                                            (lpddr4_cmd_ph3=={te_wr_column[7:4],2'b00,3'b011})
                )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={$past(te_wr_column[8  ],1),`LP4CMD_CAS2}) &&  
                                             (lpddr4_cmd_ph1=={$past(te_wr_column[7:4],1),2'b00,3'b011}) ) :
                                           1'b1;
    endproperty
    
    property lpddr4_cmd_act0;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_act0_trg) |->
                (lpddr4_cmd_ph0=={r_te_rd_row[15:12], `LP4CMD_ACT1})
            &&  (lpddr4_cmd_ph1=={r_te_rd_row[11:10], r_te_rd_row[16], r_gs_bank_num[BANK_BITS-1:0], 3'b011})   
            &&  ((~dh_pi_frequency_ratio) ?  1'b1 :
                                            (lpddr4_cmd_ph2=={r_te_rd_row[9:6], 1'b1, (lpddr4_row17_exist ? r_te_rd_row[17] : 1'b1), 3'b111}) &&
                                            (lpddr4_cmd_ph3=={r_te_rd_row[5:0], 3'b011})
                )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={$past(r_te_rd_row[9:6], 1), 1'b1, (lpddr4_row17_exist ? $past(r_te_rd_row[17], 1) : 1'b1), 3'b111}) && 
                                             (lpddr4_cmd_ph1=={$past(r_te_rd_row[5:0], 1), 3'b011}) ) :
                                           1'b1;
    endproperty

    property lpddr4_cmd_act1;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_act1_trg) |->
                (lpddr4_cmd_ph0=={r_te_wr_row[15:12], `LP4CMD_ACT1})
            &&  (lpddr4_cmd_ph1=={r_te_wr_row[11:10], r_te_wr_row[16], r_gs_bank_num[BANK_BITS-1:0], 3'b011}) 
            &&  ((~dh_pi_frequency_ratio) ? 1'b1 : 
                                            (lpddr4_cmd_ph2=={r_te_wr_row[9:6], 1'b1, (lpddr4_row17_exist ? r_te_rd_row[17] : 1'b1), 3'b111}) &&
                                            (lpddr4_cmd_ph3=={r_te_wr_row[5:0], 3'b011}) 
                )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={$past(r_te_wr_row[9:6], 1), 1'b1, (lpddr4_row17_exist ? $past(r_te_rd_row[17], 1) : 1'b1), 3'b111}) &&  
                                             (lpddr4_cmd_ph1=={$past(r_te_wr_row[5:0], 1), 3'b011}) ) :
                                           1'b1;
    endproperty

    // split command is not supported yet.


    property lpddr4_cmd_mrw;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_mrw_trg) |->
                (lpddr4_cmd_ph0=={      r_gs_mrs_a[   7],`LP4CMD_MRW1})
            &&  (lpddr4_cmd_ph1=={      r_gs_mrs_a[13:8],3'b011}) 
            &&  ((~dh_pi_frequency_ratio) ? 1'b1 :
                                            (lpddr4_cmd_ph2=={r_gs_mrs_a[6],`LP4CMD_MRW2}) &&
                                            (lpddr4_cmd_ph3=={r_gs_mrs_a[ 5:0],3'b011})
                )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={$past(r_gs_mrs_a[6],1),`LP4CMD_MRW2}) && 
                                             (lpddr4_cmd_ph1=={$past(r_gs_mrs_a[ 5:0],1),3'b011}) ) :
                                           1'b1;
    endproperty

    property lpddr4_cmd_mrr;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_mrr_trg) |->
                (lpddr4_cmd_ph0=={1'b0,`LP4CMD_MRR1})
            &&  (lpddr4_cmd_ph1=={r_gs_mrs_a[13:8],3'b011}) 
            &&  ((~dh_pi_frequency_ratio) ? (lpddr4_cmd_ph1=={r_gs_mrs_a[13:8],3'b011}) :
                                            (lpddr4_cmd_ph2=={1'b0,`LP4CMD_CAS2}) &&
                                            (lpddr4_cmd_ph3=={6'b00_0000,3'b011})
                )
            ##1 (~dh_pi_frequency_ratio) ? ( (lpddr4_cmd_ph0=={1'b0,`LP4CMD_CAS2}) && 
                                             (lpddr4_cmd_ph1=={6'b00_0000,3'b011}) ) :
                                           1'b1;
    endproperty
    
    property lpddr4_cmd_zqc_fr_1_2;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4 | dh_pi_frequency_ratio)
        (lpddr4_cmd_zqc_trg) |->
            // MPC(ZQCal Start)
                (lpddr4_cmd_ph0=={1'b1,`LP4CMD_MPC})
            &&  (lpddr4_cmd_ph1=={6'b001111,3'b011})
            ##1 (lpddr4_cmd_ph0[2:0]==3'b011)
            &&  (lpddr4_cmd_ph1[2:0]==3'b011)
            ##1 (lpddr4_cmd_ph0[1:0]==2'b11)
            // MPC(ZQCal Latch)
            ##[1:$] (lpddr4_cmd_ph0=={1'b1,`LP4CMD_MPC})
            &&  (lpddr4_cmd_ph1=={6'b010001,3'b011})
            ##1 (lpddr4_cmd_ph0[2:0]==3'b011)
            &&  (lpddr4_cmd_ph1[2:0]==3'b011)
            ##1 (lpddr4_cmd_ph0[1:0]==2'b11);
    endproperty
    
    property lpddr4_cmd_zqc_fr_1_4;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4 | !dh_pi_frequency_ratio)
        (lpddr4_cmd_zqc_trg) |->
            // MPC(ZQCal Start)
                (lpddr4_cmd_ph0=={1'b1,`LP4CMD_MPC})
            &&  (lpddr4_cmd_ph1=={6'b001111,3'b011})
            &&  (lpddr4_cmd_ph2[2:0]==3'b011)
            &&  (lpddr4_cmd_ph3[2:0]==3'b011)
            // MPC(ZQCal Latch)
            ##[1:$] (lpddr4_cmd_ph0=={1'b1,`LP4CMD_MPC})
            &&  (lpddr4_cmd_ph1=={6'b010001,3'b011})
            &&  (lpddr4_cmd_ph2[2:0]==3'b011)
            &&  (lpddr4_cmd_ph3[1:0]==2'b11);
    endproperty
    
    property lpddr4_cmd_ref;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_ref_trg) |->
            (~dh_pi_frequency_ratio) ? (lpddr4_cmd_ph0=={~dh_pi_per_bank_refresh,`LP4CMD_REF}) && (lpddr4_cmd_ph1=={3'b000,r_gs_bank_num[`MEMC_FREQ_RATIO*BANK_BITS-1:BANK_BITS],3'b011}) :  // Bank Num is dummy. They must be corrected when PerBank refresh feature will be implemented.
                                       (lpddr4_cmd_ph2=={~dh_pi_per_bank_refresh,`LP4CMD_REF}) && (lpddr4_cmd_ph3=={3'b000,r_gs_bank_num[`MEMC_FREQ_RATIO*BANK_BITS-1:BANK_BITS],3'b011});
    endproperty

    property lpddr4_cmd_pre;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_pre_trg) |->
            (lpddr4_cmd_ph0=={r_gs_pre_all,`LP4CMD_PRE}) && (lpddr4_cmd_ph1=={3'b000,r_gs_bank_num[BANK_BITS-1:0],3'b011});
    endproperty

    property lpddr4_cmd_sre;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_sre_trg) |->
                (lpddr4_cmd_ph0=={1'b0,`LP4CMD_SRE}) && (lpddr4_cmd_ph1=={6'b000000,3'b011});
    endproperty

    property lpddr4_cmd_srx;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_srx_trg) |->
                (lpddr4_cmd_ph0=={1'b0,`LP4CMD_SRX}) && (lpddr4_cmd_ph1=={6'b000000,3'b011});
    endproperty

    property lpddr4_cmd_srpde;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_srpde_trg) |->
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b011) && (lpddr4_cmd_ph1[2:0]==3'b001)) :
                                           ((lpddr4_cmd_ph0[2:0]==3'b011) && (lpddr4_cmd_ph1[2:0]==3'b001) && (lpddr4_cmd_ph2[2:0]==3'b001) && (lpddr4_cmd_ph3[2:0]==3'b001))
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b001) && (lpddr4_cmd_ph1[2:0]==3'b000)) : 
                                           ((lpddr4_cmd_ph0[2:0]==3'b001) && (lpddr4_cmd_ph1[2:0]==3'b000) && (lpddr4_cmd_ph2[2:0]==3'b000) && (lpddr4_cmd_ph3[2:0]==3'b000));
    endproperty

    property lpddr4_cmd_srpdx;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_srpdx_trg) |->
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b000) && (lpddr4_cmd_ph1[2:0]==3'b010)) : 
                                           ((lpddr4_cmd_ph0[2:0]==3'b000) && (lpddr4_cmd_ph1[2:0]==3'b010) && (lpddr4_cmd_ph2[2:0]==3'b010) && (lpddr4_cmd_ph3[2:0]==3'b010))
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b010) && (lpddr4_cmd_ph1[2:0]==3'b011)) :
                                           ((lpddr4_cmd_ph0[2:0]==3'b010) && (lpddr4_cmd_ph1[2:0]==3'b011) && (lpddr4_cmd_ph2[2:0]==3'b011) && (lpddr4_cmd_ph3[2:0]==3'b011));
    endproperty

    property lpddr4_cmd_pde;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_pde_trg) |->
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b011) && (lpddr4_cmd_ph1[2:0]==3'b001)) :
                                           ((lpddr4_cmd_ph0[2:0]==3'b011) && (lpddr4_cmd_ph1[2:0]==3'b001) && (lpddr4_cmd_ph2[2:0]==3'b001) && (lpddr4_cmd_ph3[2:0]==3'b001))
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b001) && (lpddr4_cmd_ph1[2:0]==3'b000)) :
                                           ((lpddr4_cmd_ph0[2:0]==3'b001) && (lpddr4_cmd_ph1[2:0]==3'b000) && (lpddr4_cmd_ph2[2:0]==3'b000) && (lpddr4_cmd_ph3[2:0]==3'b000));
    endproperty

    property lpddr4_cmd_pdx;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        (lpddr4_cmd_pdx_trg) |->
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b000) && (lpddr4_cmd_ph1[2:0]==3'b010)) :
                                           ((lpddr4_cmd_ph0[2:0]==3'b000) && (lpddr4_cmd_ph1[2:0]==3'b010) && (lpddr4_cmd_ph2[2:0]==3'b010) && (lpddr4_cmd_ph3[2:0]==3'b010))
            ##1 (~dh_pi_frequency_ratio) ? ((lpddr4_cmd_ph0[2:0]==3'b010) && (lpddr4_cmd_ph1[2:0]==3'b011)) : 
                                           ((lpddr4_cmd_ph0[2:0]==3'b010) && (lpddr4_cmd_ph1[2:0]==3'b011) && (lpddr4_cmd_ph2[2:0]==3'b011) && (lpddr4_cmd_ph3[2:0]==3'b011));
    endproperty


    //-------------------------------------------------------------------------------------
    a_lpddr4_cmd_rd: assert property (lpddr4_cmd_rd)
    //        $info("%m %t pass lpddr4 read command (from gs)", $time);
        else $error("%m %t fail lpddr4 read command (from gs)", $time);

    a_lpddr4_cmd_wr: assert property (lpddr4_cmd_wr)
    //        $info("%m %t pass lpddr4 write command (from gs)", $time);
        else $error("%m %t fail lpddr4 write command (from gs)", $time);

    a_lpddr4_cmd_mwr: assert property (lpddr4_cmd_mwr)
    //        $info("%m %t pass lpddr4 masked-write command (from gs)", $time);
        else $error("%m %t fail lpddr4 masked-write command (from gs)", $time);

    a_lpddr4_cmd_act0: assert property (lpddr4_cmd_act0)
    //        $info("%m %t pass lpddr4 active command (from gs and it is read)", $time);
        else $error("%m %t fail lpddr4 active command (from gs and it is read)", $time);

    a_lpddr4_cmd_act1: assert property (lpddr4_cmd_act1)
    //        $info("%m %t pass lpddr4 active command (from gs and it is write)", $time);
        else $error("%m %t fail lpddr4 active command (from gs and it is write)", $time);



    a_lpddr4_cmd_mrw: assert property (lpddr4_cmd_mrw)
    //        $info("%m %t pass lpddr4 mrw command", $time);
        else $error("%m %t fail lpddr4 mrw command", $time);

    a_lpddr4_cmd_mrr: assert property (lpddr4_cmd_mrr)
    //        $info("%m %t pass lpddr4 mrr command", $time);
        else $error("%m %t fail lpddr4 mrr command", $time);

      a_lpddr4_cmd_zqc_fr_1_2: assert property (lpddr4_cmd_zqc_fr_1_2)
      //        $info("%m %t pass lpddr4 MPC(ZQCal) command", $time);
          else $error("%m %t fail lpddr4 MPC(ZQCal) command", $time);
      

    a_lpddr4_cmd_ref: assert property (lpddr4_cmd_ref)
    //        $info("%m %t pass lpddr4 refresh command", $time);
        else $error("%m %t fail lpddr4 refresh command", $time);

    a_lpddr4_cmd_pre: assert property (lpddr4_cmd_pre)
    //        $info("%m %t pass lpddr4 precharge command (from gs)", $time);
        else $error("%m %t fail lpddr4 precharge command (from gs)", $time);

    a_lpddr4_cmd_sre: assert property (lpddr4_cmd_sre)
    //        $info("%m %t pass lpddr4 self-refresh entry", $time);
        else $error("%m %t fail lpddr4 self-refresh entry", $time);

    a_lpddr4_cmd_srx: assert property (lpddr4_cmd_srx)
    //        $info("%m %t pass lpddr4 self-refresh exit", $time);
        else $error("%m %t fail lpddr4 self-refresh exit", $time);

    a_lpddr4_cmd_srpde: assert property (lpddr4_cmd_srpde)
    //        $info("%m %t pass lpddr4 sr-powerdown entry", $time);
        else $error("%m %t fail lpddr4 sr-powerdown entry", $time);

    a_lpddr4_cmd_srpdx: assert property (lpddr4_cmd_srpdx)
    //        $info("%m %t pass lpddr4 sr-powerdown exit", $time);
        else $error("%m %t fail lpddr4 sr-powerdown exit", $time);

    a_lpddr4_cmd_pde: assert property (lpddr4_cmd_pde)
    //        $info("%m %t pass lpddr4 powerdown entry", $time);
        else $error("%m %t fail lpddr4 powerdown entry", $time);

    a_lpddr4_cmd_pdx: assert property (lpddr4_cmd_pdx)
    //        $info("%m %t pass lpddr4 powerdown exit", $time);
        else $error("%m %t fail lpddr4 powerdown exit", $time);
    //-------------------------------------------------------------------------------------
    wire [27:0] lpddr4_cmd_trg;
    assign lpddr4_cmd_trg_all[28*nk+27:28*nk] = lpddr4_cmd_trg;
    assign lpddr4_cmd_trg = {
            (lpddr4_cmd_rd_trg & ~r_te_autopre & ~lpddr4_bl),
            (lpddr4_cmd_rd_trg &  r_te_autopre & ~lpddr4_bl),
            (lpddr4_cmd_rd_trg & ~r_te_autopre &  lpddr4_bl),
            (lpddr4_cmd_rd_trg &  r_te_autopre &  lpddr4_bl),
            (lpddr4_cmd_wr_trg & ~r_te_autopre & ~lpddr4_bl),
            (lpddr4_cmd_wr_trg &  r_te_autopre & ~lpddr4_bl),
            (lpddr4_cmd_wr_trg & ~r_te_autopre &  lpddr4_bl),
            (lpddr4_cmd_wr_trg &  r_te_autopre &  lpddr4_bl),
            (lpddr4_cmd_mwr_trg & ~r_te_autopre),
            (lpddr4_cmd_mwr_trg &  r_te_autopre),
            lpddr4_cmd_act0_trg,
            lpddr4_cmd_act1_trg,
            1'b0,
            1'b0,
            1'b0,
            lpddr4_cmd_mrw_trg,
            lpddr4_cmd_mrr_trg,
            lpddr4_cmd_zqc_trg,
            (lpddr4_cmd_ref_trg & ~dh_pi_per_bank_refresh),
            (lpddr4_cmd_ref_trg &  dh_pi_per_bank_refresh),
            (lpddr4_cmd_pre_trg &  r_gs_pre_all),
            (lpddr4_cmd_pre_trg & ~r_gs_pre_all),
            lpddr4_cmd_sre_trg,
            lpddr4_cmd_srx_trg,
            lpddr4_cmd_srpde_trg,
            lpddr4_cmd_srpdx_trg,
            lpddr4_cmd_pde_trg,
            lpddr4_cmd_pdx_trg
        };


    //-------------------------------------------------------------------------------------
    // Coverage group instantiation
    cg_pi_cmd_lpddr4_rank cg_pi_cmd_lpddr4_rank_inst = new(
        lpddr4_cmd_trg,
        lpddr4_cmd_rd_trg,
        lpddr4_cmd_wr_trg,
        lpddr4_cmd_mwr_trg,
        lpddr4_cmd_bypass_rd_trg
    );
    //-------------------------------------------------------------------------------------
  end
endgenerate


    //-------------------------------------------------------------------------------------
    integer num_cmd_schedule;
    assign num_cmd_schedule =
            gs_op_is_rd +
            gs_op_is_wr +
            gs_op_is_act +
            gs_op_is_load_mode +
            ((dh_pi_frequency_ratio) ? (gs_op_is_ref | gs_op_is_pre) : (gs_op_is_ref + gs_op_is_pre)) +
            gs_op_is_enter_sr_lpddr +
            gs_op_is_exit_sr_lpddr +
            gs_op_is_enter_selfref +
            gs_op_is_exit_selfref +
            gs_op_is_enter_powerdown +
            gs_op_is_exit_powerdown;

    property lpddr4_cmd_req0;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4)
        num_cmd_schedule <= 1;
    endproperty

    property lpddr4_cmd_req1;
        @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~dh_pi_lpddr4 | dh_pi_frequency_ratio)
        (gs_op_is_rd  ||
         gs_op_is_wr  ||
         gs_op_is_act ||
         gs_op_is_load_mode
        ) |=>
                (num_cmd_schedule==0);
    endproperty


    a_lpddr4_cmd_req0: assert property (lpddr4_cmd_req0)
    //        $info("%m %t pass Chack number of lpddr4 command request", $time);
        else $error("%m %t fail Check number of lpddr4 command request", $time);

    a_lpddr4_cmd_req1: assert property (lpddr4_cmd_req1)
    //        $info("%m %t pass Check overlap of lpddr4 command request (Group1: 4 cycle command)", $time);
        else $error("%m %t fail Check overlap of lpddr4 command request (Group1: 4 cycle command)", $time);

    //-------------------------------------------------------------------------------------
    // Coverage group
    reg [27:0] lpddr4_cmd_trg;
    always @(*) begin
        integer i;
        lpddr4_cmd_trg = 28'd0;
        for (i=0; i<NUM_RANKS; i=i+1) begin
            lpddr4_cmd_trg =  lpddr4_cmd_trg | lpddr4_cmd_trg_all[28*i+:28];
        end
    end

    covergroup cg_pi_cmd_lpddr4 @(posedge co_pi_clk);
        // Observe ctrlupd and lpddr4 command generation occur simultaneously.
        cp_pi_cmd_lpddr4_ctrlupd : coverpoint ({ctrlupd_req,upd_ok_lpddr4}) iff(core_ddrc_rstn & dh_pi_lpddr4) {
            bins  upd_ng = {{1'b1,1'b0}};
            bins  upd_ok = {{1'b1,1'b1}};
        }

        // Observe phyupd request and lpddr4 command generation occur simultaneously.
        cp_pi_cmd_lpddr4_phyupd : coverpoint ({phyupd_pause_req,upd_ok_lpddr4}) iff(core_ddrc_rstn & dh_pi_lpddr4) {
            bins  upd_ng = {{1'b1,1'b0}};
            bins  upd_ok = {{1'b1,1'b1}};
        }

    endgroup // cg_pi_cmd_lpddr4
    // Coverage group instantiation
    cg_pi_cmd_lpddr4 cg_pi_cmd_lpddr4_inst = new;
    //-------------------------------------------------------------------------------------

    covergroup cg_pi_lp5_act_cmd @(posedge co_pi_clk);
      // Observe that ACT-1 is issued at "tRRD-2"
      cp_act_tmg_trrd_m2 : coverpoint ({gs_op_is_act, ts_act2_invalid_tmg}) iff(core_ddrc_rstn & reg_ddrc_lpddr5) {
         bins act1_trrd_m2 = {{1'b1, 1'b1}};
      }

      // Observe that PREpb is issued during tAAD
      cp_prepb_during_taad : coverpoint ({gs_op_is_pre, pi_lp5_preref_ok, act2_req_r, act2_out_en}) iff(core_ddrc_rstn & reg_ddrc_lpddr5) {
         bins         pre_during_taad  = {{1'b1, 1'b1, 1'b1, 1'b0}};
         illegal_bins illegal_pre_taad = {{1'b1, 1'b0, 1'b1, 1'b0}};
      }

      // Observe that REFpb is issued during tAAD
      cp_refpb_during_taad : coverpoint ({gs_op_is_ref, pi_lp5_preref_ok, act2_req_r, act2_out_en}) iff(core_ddrc_rstn & reg_ddrc_lpddr5 & dh_pi_per_bank_refresh) {
         bins         refpb_during_taad  = {{1'b1, 1'b1, 1'b1, 1'b0}};
         illegal_bins illegal_refpb_taad = {{1'b1, 1'b0, 1'b1, 1'b0}};
      }


      // Observe that ACT-2 is issued back-to-back
      cp_act2_back_to_back : coverpoint ({t_aad_timer_r, pi_lp5_act2_cmd}) iff(core_ddrc_rstn & reg_ddrc_lpddr5) {
         bins act2_back_to_back = {{5'd8, 1'b1}};
      }
   endgroup

   cg_pi_lp5_act_cmd cg_pi_lp5_act_cmd_inst = new;

   property lp5_act1_during_taad;
      @(posedge co_pi_clk) disable iff (~core_ddrc_rstn | ~reg_ddrc_lpddr5)
         gs_op_is_act |-> ~act2_req_r | act2_out_en;
   endproperty

   a_lp5_act1_during_taad : assert property (lp5_act1_during_taad)
            else $error("%m %t ACT command is not scheduled durig tAAD", $time);







//////////////////////////////////////////
// instantiations of cs_n check assertions (cs_n_check_1 and 2 are beside their associated properties)
//////////////////////////////////////////
 

////////////////////////////////////////////////
// instantiations of pi_ph_addr check assertions
////////////////////////////////////////////////

endmodule
`endif // `ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON
