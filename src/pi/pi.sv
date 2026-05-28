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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pi/pi.sv#2 $
// -------------------------------------------------------------------------
// Description:
//
// ----------------------------------------------------------------------------

//--------------------------- DEFINES TO REMOVE UNUSED CODE ACCORDING TO CONFIGURATION ------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
`include "dfi/DWC_ddrctl_dfi_pkg.svh"

module pi 
import DWC_ddrctl_reg_pkg::*;
import DWC_ddrctl_dfi_pkg::*;
#(
   parameter CMD_LEN_BITS      = 1,
   // NOTE: Changing this requires changing `defines in ddrc_parameters.v
   parameter RMW_TYPE_BITS     = 2,        // rmw_type bits to pass through
   parameter WRCMD_ENTRY_BITS  = `MEMC_WRCMD_ENTRY_BITS,
   parameter RD_TAG_BITS       = `MEMC_TAGBITS,

   parameter RANK_BITS         = `MEMC_RANK_BITS,
   parameter LRANK_BITS        = `DDRCTL_DDRC_LRANK_BITS,
   parameter BG_BITS           = `MEMC_BG_BITS,
   parameter BANK_BITS         = `MEMC_BANK_BITS,
   parameter BG_BANK_BITS      = `MEMC_BG_BANK_BITS,
   parameter ROW_BITS          = `MEMC_PAGE_BITS,
   parameter BLK_BITS          = `MEMC_BLK_BITS,
   parameter WORD_BITS         = `MEMC_WORD_BITS,
   parameter RANKBANK_BITS     = LRANK_BITS + BG_BANK_BITS,

   parameter PARTIAL_WR_BITS   = `UMCTL2_PARTIAL_WR_BITS,
   parameter PW_WORD_CNT_WD_MAX = 2,

   parameter  PW_NUM_DB               = PARTIAL_WR_BITS,
   parameter  PW_NUM_DB_LOG2          = `log2(PW_NUM_DB),
   parameter MRS_A_BITS        = `MEMC_PAGE_BITS,
   parameter MRS_BA_BITS       = `MEMC_BG_BANK_BITS,
   parameter NUM_LANES         =  4, //PHY number of lanes - default is 4
   parameter PHY_ADDR_BITS     = `MEMC_DFI_ADDR_WIDTH,


   //
   parameter BG_BANK_BITS_FULL   = BG_BITS + BANK_BITS,              // this is different than BG_BANK_BITS
   parameter RANKBANK_BITS_FULL  = RANK_BITS + BG_BITS + BANK_BITS,  // For OnChipParity (Physical Rank + BG(Full) + Bank(Full))
   parameter LRANKBANK_BITS_FULL = LRANK_BITS + BG_BITS + BANK_BITS, // this is different than RANKBANK_BITS
                                                                     // In this case the 2-bits of BG and 3-bits of bank
                                                                     // are carried over in all cases
   parameter NUM_RANKS        = 1 << RANK_BITS,

   parameter AM_ROW_WIDTH     = 5,


   // values for counting COL accesses etc
   // max for rdwr_bl is 64 - 4*16
   parameter MAX_BL_WD       = 5, // max of MEMC_BURST_LENGTH_16 => 5 bits for 16
   parameter MAX_BL_WD_BW    = MAX_BL_WD + 2, // for QBW => MEMC_BURST_LENGTH_16 * 4
   parameter MAX_BL_WD_BW_M1 = MAX_BL_WD_BW - 1, // used to cnt COL - half of MAX_BL_WD_BW as

   //The MAX_CMD_NUM value means the number of command to be able to issue per one cycle.
   //Currently, this value is set to 2 in LPDDR4 1:4 and 1:2 mode both config.
   parameter MAX_CMD_NUM = 2
)
(
   //--------------------------- INPUTS AND OUTPUTS -------------------------------
   input           core_ddrc_rstn,
   input           gs_op_is_enter_sr_lpddr,        // command to enter lpddr4 self-refresh mode
   input           gs_op_is_exit_sr_lpddr,         // command to exit lpddr4 self-refresh mode
   input           gs_op_is_enter_dsm,                 // enter deep sleep mode
   input           gs_op_is_exit_dsm,                  // exit deep sleep mode
   input           gs_op_is_cas_ws_off,
   input           gs_wck_stop_ok,
   input           dh_pi_en_dfi_dram_clk_disable,
   input           gs_pi_stop_clk_ok,
   input  [1:0]    gs_pi_stop_clk_type,
   input           dfilp_ctrl_lp,
   input  [DFI_T_CTRL_DELAY_WIDTH-1:0] reg_ddrc_dfi_t_ctrl_delay,  // timer value for DF tctrl_delay
   input  [DFI_T_DRAM_CLK_DISABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_disable,
   input  [T_CKSRE_WIDTH-1:0]            reg_ddrc_t_cksre,

   input   [T_MR_WIDTH-1:0] reg_ddrc_t_mr,

   input           dh_pi_frequency_ratio, // 0=1:2 mode, 1=1:4 mode
   input   [3:0]   dh_pi_burst_rdwr,       // 4'h0010=burst of 4 data read/write
                                           // 4'h0100=burst of 8 data read/write
                                           // 4'h1000=burst of 16 data read/write
   //input           dh_pi_skip_init,
   input[READ_LATENCY_WIDTH-1:0]      reg_ddrc_read_latency,
   input[WRITE_LATENCY_WIDTH-1:0]      reg_ddrc_write_latency,
   input           co_pi_clk,
   input   [ROW_BITS-1:0]          ts_act_page,
   input                           ts_act2_invalid_tmg,
   input   [BLK_BITS-1:0]          te_pi_rd_blk,
   input   [WORD_BITS-1:0]         te_pi_rd_word,
   input   [RMW_TYPE_BITS-1:0]     te_pi_rd_rmw_type,
   input   [WRCMD_ENTRY_BITS-1:0]  te_pi_rd_link_addr,
   input   [CMD_LEN_BITS-1:0]      te_pi_rd_length,
   input   [RD_TAG_BITS-1:0]       te_pi_rd_tag,
   input                           te_pi_rd_addr_err,
   input   [BLK_BITS-1:0]          te_pi_wr_blk,
   input   [WORD_BITS-1:0]         te_pi_wr_word,
   input                   os_te_autopre,          // auto-precharge indication to TE
   input                   ts_pi_mwr,              // Mask-Write indication from selection n/w
   input                   te_pi_rd_valid,         // 1 or more reads pending in TE
   input                   te_pi_wr_valid,         // 1 or more writes pending in TE
   input                   ih_pi_xact_valid,       // new command from IH
   // TBD: updated for separate bypass paths for read/act/pre
   input                   gs_pi_init_cke,
   input  [MRS_A_BITS-1:0]     gs_pi_mrs_a,
   input                   gs_pi_init_in_progress,
   input                   gs_pi_dram_rst_n,
   input                   gs_mpc_zq_start,
   input                   gs_mpc_zq_latch,
   input                      gs_op_is_rd,                       // read command issued to DRAM
   input                      gs_op_is_wr,                       // read command issued to DRAM
   input                      gs_op_is_act,                      // activate command issued to DRAM
   input                      gs_op_is_pre,                      // precharge command issued to DRAM
   input                      gs_op_is_ref,                      // refresh command issued to DRAM
   input                      gs_op_is_enter_selfref,            // send command to enter self refresh
   input                      gs_op_is_exit_selfref,             // send command to exit self refresh
   input                      gs_op_is_enter_powerdown,          // send command to enter power-down
   input                      gs_op_is_exit_powerdown,           // send command to exit power-down
   input                      gs_op_is_load_mode,                // load mode register (only driven from init)



   input  [RANKBANK_BITS-1:0] gs_pre_rankbank_num,                 // bank number to precharge the DRAM address for
   input  [RANKBANK_BITS-1:0] gs_rdwr_rankbank_num,                // bank number to read/write the DRAM address for
   input  [RANKBANK_BITS-1:0] gs_act_rankbank_num,                 // bank number to activate the DRAM address for
   input [BANK_BITS-1:0]      gs_pi_refpb_bank,
   input                      gs_cas_ws_req,
   output                     pi_rdwr_ok,
   output                     pi_lp5_act2_cmd,
   output                     pi_lp5_noxact,
   output                     pi_lp5_preref_ok,
   output                     pi_col_b3,

   // TBD: updated for separate bypass paths for read/act/pre
   input   [`MEMC_FREQ_RATIO * NUM_RANKS-1:0] gs_pi_odt,   // ODT signal from gs_odt.  This is passed through to pi_ph_odt
   input                   gs_pi_odt_pending,         // waiting for the ODT command to complete
   input   [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0] gs_pi_wrdata_cs_n,   // wrdata_cs_n signal from gs_odt.  This is passed through to pi_ph_wrdata_cs_n
   input   [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0] gs_pi_rddata_cs_n,   // rddata_cs_n signal from gs_odt.  This is passed through to pi_ph_rddata_cs_n
   input                   gs_pi_ctrlupd_req,         // ctrlupd request when not is use
   output                  pi_gs_ctrlupd_ok,          // PI has issued DFI controller update to PHY
   input                   gs_pi_phyupd_pause_req,    // request to pause system due to PHY update
   output                  pi_gs_phyupd_pause_ok,     // PI has paused system due to PHY update
   input                   gs_pi_dfi_lp_changing,
   input                   gs_pi_data_pipeline_empty, // indicates no read/write data in flight
   output                  pi_gs_noxact,
   output                  pi_gs_rd_vld,
   output                  pi_rt_rd_vld,
   output [CMD_LEN_BITS-1:0] pi_rt_rd_partial,
   // SMV: 2 more bits are appended to the base tag to indicate: MRR(1)/MRW(0), External(1)/Internal(0).
   //`ifdef LPDDR45_DQSOSC_EN
   //output [RD_TAG_BITS+2:0]    pi_rt_rd_tag,
   //`else
   output [RD_TAG_BITS+1+`LPDDR45_DQSOSC:0]    pi_rt_rd_tag,
   //`endif
   output                        pi_rt_rd_addr_err,
   output [RMW_TYPE_BITS-1:0]    pi_rt_rmw_type,
   output [WRCMD_ENTRY_BITS-1:0] pi_rt_wr_ram_addr,

   output [LRANKBANK_BITS_FULL-1:0] pi_rt_rankbank_num,
   output [ROW_BITS-1:0]         pi_rt_page_num,
   output [BLK_BITS-1:0]         pi_rt_block_num,
   output [WORD_BITS-1:0]        pi_rt_critical_word,

   output                                          pi_ph_stop_clk,
   output                                          pi_gs_stop_clk_early,               // Early indication of clock stop output
   output  [1:0]                                   pi_gs_stop_clk_type,
   output                                          pi_gs_dfilp_wait,

   output  reg                                     pi_ph_dram_rst_n,
   output  [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]      pi_ph_cke,


   output  [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]      pi_ph_cs,

   output  [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]      pi_ph_odt,                          // ODT signal to dfi block.  This comes directly from gs_pi_odt.
   output  [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0]      pi_ph_wrdata_cs_n,                  // wrdata_cs_n signal to dfi block.  This comes directly from gs_pi_odt.
   output  [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0]      pi_ph_rddata_cs_n,                  // rddata_cs_n signal to dfi block.  This comes directly from gs_pi_odt.

   output  [`MEMC_FREQ_RATIO-1:0]                  pi_ph_ras_n,
   output  [`MEMC_FREQ_RATIO-1:0]                  pi_ph_cas_n,
   output  [`MEMC_FREQ_RATIO-1:0]                  pi_ph_we_n,
   output  [`MEMC_FREQ_RATIO * BANK_BITS-1:0]      pi_ph_bank,

   output  dfi_address_s                           pi_ph_addr,

   input                                           dh_pi_per_bank_refresh,// REF Per bank//Added by Naveen B
   input                         dh_pi_lpddr4,      //if set indicates LPDDR4 device
   input   [AM_ROW_WIDTH-1:0]    dh_pi_addrmap_row_b17, // if 'h1F('d31) indicates row17 is not used

   input                         reg_ddrc_lpddr5,      //if set indicates LPDDR5 device
   input   [BANK_ORG_WIDTH-1:0]  reg_ddrc_bank_org,
   input   [T_CSH_WIDTH-1:0]     reg_ddrc_t_csh,
   input                         reg_ddrc_wck_on,
   input                         gs_pi_mrr,
   input                         gs_pi_mrr_ext,

   input   [6:0]                      mr_t_rddata_en,           // register asociated with t_rddata_en from DFI spec
   input   [DFI_TPHY_WRLAT_WIDTH-1:0] mr_t_wrlat,               // register asociated with tphy_wrlat from DFI spec
   output                             pi_ph_dfi_rddata_en,      // rddata_en going to dfi phy
   output [`MEMC_FREQ_RATIO-1:0]      pi_ph_dfi_wrdata_en,      // wrdata_en going to dfi phy
   input                              ddrc_dfi_ctrlupd_req,     // request for PHY PVT update


   output                        clock_gating_en_int      // Signal indicating that it is ok to gate the clock
   ,input [3:0]                  gs_pi_mrr_snoop_en
   ,input                        gs_mpc_dqsosc_start
   ,output [3:0]                 pi_ph_snoop_en



   `ifdef SNPS_ASSERT_ON
   ,input                        gs_pi_wr_mode
   `endif // SNPS_ASSERT_ON
);
                                                        // this goes high when all the data and cmd queues inside the DDRC are empty


//--------------------------- REGISTERS AND WIRES ------------------------------


//
// output signals to phy for read/write/activate commands
//
// signals to phy for "other" commands
wire [NUM_RANKS-1:0]        pi_ph_cs_n_other;
wire                        pi_ph_cs_n_any_other;
wire                        pi_ph_ras_n_other;
wire                        pi_ph_cas_n_other;
wire                        pi_ph_we_n_other;
wire [BANK_BITS-1:0]        pi_ph_bank_other;
wire [BG_BITS-1:0]          pi_ph_bg_other;
wire [PHY_ADDR_BITS-1:0]    pi_ph_addr_other;
// signals for 2t command
wire                        pi_ph_ras_n_2t;
wire                        pi_ph_cas_n_2t;
wire                        pi_ph_we_n_2t;
wire [BANK_BITS-1:0]        pi_ph_bank_2t;
wire [BG_BITS-1:0]          pi_ph_bg_2t;
wire [PHY_ADDR_BITS-1:0]    pi_ph_addr_2t;
wire [NUM_RANKS-1:0]        pi_ph_cs_n_rwa;
wire                        pi_ph_cs_n_any_rwa;
wire                        pi_ph_ras_n_rwa;
wire                        pi_ph_cas_n_rwa;
wire                        pi_ph_we_n_rwa;
wire [BANK_BITS-1:0]        pi_ph_bank_rwa;
wire [BG_BITS-1:0]          pi_ph_bg_rwa;
wire [PHY_ADDR_BITS-1:0]    pi_ph_addr_rwa;

reg                         pi_ph_stop_clk_r;
reg                         stop_clk_entry_wait_r;

// flopped read command info from TE
reg     [ROW_BITS-1:0]                          r_ts_act_page;
reg     [BLK_BITS-1:0]                          r_te_rd_blk;
reg     [WORD_BITS-1:0]                         r_te_rd_word;
reg     [CMD_LEN_BITS-1:0]                      r_te_rd_length;         // 0=block/full read, 1=partial/non-block
reg     [RMW_TYPE_BITS-1:0]     r_te_rd_rmw_type;       // read-modify-write encoded
reg     [WRCMD_ENTRY_BITS-1:0]  r_te_rd_link_addr;      // write command linked to by this read,
                                                        //  valid only if r_te_rd_linked_wr=1
reg     [RD_TAG_BITS-1:0]       r_te_rd_tag;            // read tag
reg                             r_te_rd_addr_err;       // read address error flag

// flopped write command info from TE
//reg     [ROW_BITS-1:0]          r_te_wr_row;
reg     [BLK_BITS-1:0]          r_te_wr_blk;
reg     [WORD_BITS-1:0]         r_te_wr_word;

// flopped DFI controller update request
reg                             r_ctrlupd_req;       // flop ctrlupd request input

// flopped PHY update pause request
reg                             r_phyupd_pause_req;  // flop PHY update pause request input



// flop info for the last read/write command;
//  this will be used to re-issue a command for multi-burst modes
//  (that is, when a single read/write request requires multiple DRAM reads/writes)
wire    [MAX_CMD_NUM * BANK_BITS-1:0]      r_bank_num;
wire    [MAX_CMD_NUM * BG_BITS-1:0]        r_bg_num;
wire    [MAX_CMD_NUM * NUM_RANKS-1:0]           pi_ph_cke_w;
wire    [RD_TAG_BITS-1:0]                       pi_rt_rd_tag_base;
wire    [CMD_LEN_BITS-1:0]                      i_rd_partial;

dfi_address_s                                   pi_ph_addr_w;

wire    [MAX_CMD_NUM * PHY_ADDR_BITS-1:0]       pi_ph_addr_int;

//`ifdef MEMC_LPDDR4
//
//wire                                            pi_ph_mrr_cmd;
//`endif // MEMC_LPDDR4


wire                            r_op_any;               // any operation scheduled to PI last cycle;
reg                             r_op_any_rwa;
reg                             r_op_any_other;         // any operation scheduled to PI last cycle
wire                            r_op_any_rwa_final;     // any operation scheduled to PI last cycle - inclusing bypass
wire                            r_op_any_other_final;   // any operation scheduled to PI last cycle - inclusing bypass
reg      [0:0]                  r_op_rdwr;              // shift register: bit 1 = read or write operation scheduled to PI last cycle;
                                                        //                 bit 2 = read or write operation scheduled to PI 2 cycles back; etc.

wire [3:0]                      burst_rdwr_int;         // internal burst size assignment, always BL4 for MRR operation
                                                        // value taken from register for all other operations

// flopped from other input signals
reg                             r_init_in_progress;
wire                            r_init_cke;             // CKE pin value to drive during init
reg                             r_init_cke_non_lpddr;   // CKE pin value to drive during init for non-lpddr designs
reg                             r_gs_op_is_load_mode;   // RASn pin value to drive during init

logic  [RANKBANK_BITS-1:0]      pre_rankbank_num_r;
logic  [RANKBANK_BITS-1:0]      rdwr_rankbank_num_r;
logic  [RANKBANK_BITS-1:0]      act_rankbank_num_r;
logic [BANK_BITS-1:0]           refpb_bank_r;

reg     [MRS_A_BITS-1:0]        r_mrs_a;                // address pin values to drive for more register set
wire    [CMD_LEN_BITS-1:0]      i_rd_is_partial;
reg     [CMD_LEN_BITS-1:0]      r_rd_is_partial;      // last read or write was a partial read/write

reg                             r_gs_op_is_rd;          // register version of gs_pi_op_is_rd
reg                             r_gs_op_is_wr;          // register version of gs_pi_op_is_wr
reg                             r_gs_op_is_refresh;
reg                             r_enter_power_savings;  // de-assert CKE for powerdown or self refresh
reg                             r_exit_power_savings;   // assert CKE for powerdown or self refresh exit
reg                             r_act_any;              // register activate (scheduled or bypass)
reg                             r_pre_any;              // register precharge (scheduled or bypass)
reg                             r_pre_onebank;          // register precharge (scheduled or bypass)
reg                             r_autopre;              // auto-precharge for this read/write
reg     [6:0]                   r_total_wr_latency;     // write latency including data burst
reg     [6:0]                   r_total_rd_latency;     // read latency including data burst
reg     [6:0]                   rdwr_latency_timer;     // time the latency of read and write data for clock stop
wire                            rdwr_latency_timer_zero;
reg     [T_MR_WIDTH-1:0]        mrr_mrw_latency_timer;  // time the latency of MRR/MRW for clock stop
wire                            mrr_mrw_latency_timer_zero;
reg                             r_stop_clk_nxt;         // OK to stop the clock in the subsequent cycle
// intermediate state bits


reg     [ROW_BITS-1:0]                          r_last_rdwr_ecc_row;
reg     [BLK_BITS-1:0]                          r_last_rdwr_blk;
reg     [WORD_BITS-1:0]                         r_last_rdwr_word;

reg     [BANK_BITS-1:0]                         r_last_rdwr_bank;       // bank address of the last read or write
reg     [BG_BITS-1:0]                           r_last_rdwr_bg;         // bank group of the last read or write
reg     [MAX_CMD_NUM * NUM_RANKS-1:0]      r_last_cke;
reg     [CMD_LEN_BITS-1:0]                      r_last_rd_is_partial;     // 0=block read, 1=partial/non-block
reg     [WRCMD_ENTRY_BITS-1:0]                  r_last_rd_link_addr;    // write command linked to by this read,
                                                        //  valid only if rmw_type!=2'b11
reg     [RMW_TYPE_BITS-1:0]                     r_last_rd_rmw_type;     // read-modify-write encoded
reg     [RD_TAG_BITS-1:0]                       r_last_rd_tag;          // read tag
reg                                             r_last_rd_addr_err;     // read address error flag

// wires
reg [ROW_BITS-1:0]              row_addr;               // page address (row address)
wire[PHY_ADDR_BITS-1:0]         column_addr;            // column address
wire[PHY_ADDR_BITS-1:0]         column_addr_no_prech;   // column address, excluding precharge bit
wire[PHY_ADDR_BITS-1:0]         base_column_addr;       // base column address for transaction
wire[WORD_BITS+BLK_BITS-1:0]    column_addr_i;          // column address before insertion of auto precharge bit and left shift for half bus width operation
wire                            col_bit10;

wire                            lpddr4_row17_exist;     // indicate bit17 of row address exists


wire                            rdwr_is_rd;             // the last read or write issued was a read

reg                             gs_pi_op_is_pde_r;
reg                             gs_pi_op_is_pdx_r;

wire                            i_clock_stop_allowed;
wire                            i_stop_clk_entry_cnt_zero;






// -----------------------------------------
//  LPDDR4 related signals
// -----------------------------------------
logic  [2*6-1:0]                lpddr4_cmd_1st;
logic  [2*6-1:0]                lpddr4_cmd_2nd;
logic  [2*7-1:0]                lpddr5_cmd_1st;
logic  [2*7-1:0]                lpddr5_cmd_2nd_r;
logic                           lpddr5_2nd_cmd_en_r;
logic                           cas_ws_en;
logic                           cas_b3_en;
logic  [`MEMC_FREQ_RATIO*6-1:0] lpddr4_ca;
logic  [2*6-1:0]                lpddr4_ca_r;
logic  [NUM_RANKS-1:0]          lpddr4_cs_1st;
logic  [NUM_RANKS-1:0]          lpddr4_cs_2nd;
logic  [NUM_RANKS-1:0]          lpddr4_cs_2nd_r;
logic                           lpddr4_4cyc_cmd;
logic                           lpddr4_2cyc_cmd;

logic  [NUM_RANKS-1:0]          lpddr5_cs_1st;
logic  [NUM_RANKS-1:0]          lpddr5_act_cs_r;
logic  [NUM_RANKS-1:0]          lpddr5_cs_r;
logic  [T_CSH_WIDTH-1:0]        tcsh_timer_r;
logic                           act2_req_r;
logic                           gs_act_or_bypass;
logic [4:0]                     t_aad_timer_r;
logic                           act2_out_en;
logic                           act2_invalid_tmg_r;
logic                           act2_invalid_tmg_d2_r;


dfi_address_s                                  lpddr4_dfi_addr;
logic  [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]      lpddr4_dfi_cke;
logic  [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]      lpddr4_dfi_cs;

dfi_address_s                                  lpddr5_dfi_addr;
logic  [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]      lpddr5_dfi_cs;

logic                           mpc_cmd_en;
logic [6:0]                     op_mpc;
logic [7:0]                     op_mpc_lp5;
logic                           op_is_rd;
logic                           op_is_mrr;
logic                           op_is_mrw;
logic                           op_is_mpc;

logic                           lpddr4_noxact;
logic                           lpddr5_noxact;

logic                           lpddr4_cmd_tmg_r;

wire [NUM_RANKS-1:0]            pi_ph_cs_or_ph01;
wire [NUM_RANKS-1:0]            pi_ph_cs_or_ph23;
reg                             ts_pi_mwr_flag; //  Masked Write

logic                           mpc_zq_start_r;
logic                           mpc_zq_latch_r;
logic                           op_is_srpde_r;
logic                           op_is_srpdx_r;
logic                           op_is_dsme_r;
logic                           op_is_dsmx_r;
logic                           selfref_st_r;
logic                           op_is_ws_off_r;
reg     [133:0]                 snoop_en_pipe;         // pipe that stores the 1's
logic                           mpc_dqsosc_start_r;
logic [3:0]                     gs_pi_mrr_snoop_en_r;
logic [3:0]                     gs_pi_mrr_snoop_en_num;
logic                           dqsosc_in_prog;
logic                           cas_ws_fs_en;

reg                             op_is_lp_sre_r;
reg                             op_is_lp_srx_r;
wire                            upd_ok_lpddr4;
wire                            upd_ok_lpddr5;

wire    [NUM_RANKS-1:0]         active_ranks_lp4;

logic                   bg_16b_addr_mode;
   // ccx_cond:;;10; Redundant for now. 8B mode is not supported.
   assign bg_16b_addr_mode = (reg_ddrc_lpddr5 && (reg_ddrc_bank_org != {{($bits(reg_ddrc_bank_org)-1){1'b0}},1'b1}));




//------------------------------ MAINLINE CODE ---------------------------------
// Signal for no operations are issued and
// no re-issues are pending and
// no read data outstanding
wire                           upd_ok_int;
assign upd_ok_int = (~r_op_any) & gs_pi_data_pipeline_empty & (~gs_pi_odt_pending) & (~gs_pi_dfi_lp_changing)
                                                      & upd_ok_lpddr4
                                                      & upd_ok_lpddr5
                                             ;

// Calibration allowed after any cycle which satisfies upd_ok_int
wire                           ctrlupd_ok;
assign ctrlupd_ok = upd_ok_int & r_ctrlupd_req;
assign                         pi_gs_ctrlupd_ok = ctrlupd_ok;

// PHY update pause allowed after any cycle which satisfies upd_ok_int
assign                         pi_gs_phyupd_pause_ok = upd_ok_int & r_phyupd_pause_req;

assign                         clock_gating_en_int = upd_ok_int;

wire [3:0] dh_pi_burst_rdwr_core_clk;
assign dh_pi_burst_rdwr_core_clk = (dh_pi_frequency_ratio) ? (dh_pi_burst_rdwr >> 2) : (dh_pi_burst_rdwr >> 1) ;

//************************************************************************
//bypass_vld is derived from three global broadcast signals
//************************************************************************



// Variables for incoming rd/wr transactions

assign i_rd_is_partial =             gs_op_is_rd       ? te_pi_rd_length  :
                                     gs_op_is_wr       ? {CMD_LEN_BITS{1'b0}} :        // all writes are full writes
                                                         r_rd_is_partial ;

wire i_op_rdwr;

assign i_op_rdwr = gs_op_is_rd | gs_op_is_wr;


//-------------------------------
// Splitting ih_pi_bg_bank_num signal to bank group and bank signals
//-------------------------------




//------------------------------------------------------------------------------
// Flopped Inputs
//------------------------------------------------------------------------------
always @ (posedge co_pi_clk or negedge core_ddrc_rstn)
        if (~core_ddrc_rstn) begin
                r_init_in_progress      <= {{($bits(r_init_in_progress)-1){1'b0}},1'b1};
                r_init_cke_non_lpddr    <= {$bits(r_init_cke_non_lpddr){1'b0}};
                r_gs_op_is_load_mode    <= {$bits(r_gs_op_is_load_mode){1'b0}};
                gs_pi_op_is_pde_r       <= {$bits(gs_pi_op_is_pde_r){1'b0}};
                gs_pi_op_is_pdx_r       <= {$bits(gs_pi_op_is_pdx_r){1'b0}};

                r_mrs_a                 <= {$bits(r_mrs_a){1'b0}};
                r_gs_op_is_rd           <= {$bits(r_gs_op_is_rd){1'b0}};
                r_gs_op_is_wr           <= {$bits(r_gs_op_is_wr){1'b0}};
                r_gs_op_is_refresh      <= {$bits(r_gs_op_is_refresh){1'b0}};
                r_ctrlupd_req           <= {$bits(r_ctrlupd_req){1'b0}};
                r_phyupd_pause_req      <= {$bits(r_phyupd_pause_req){1'b0}};
                r_act_any               <= {$bits(r_act_any){1'b0}};
                r_pre_any               <= {$bits(r_pre_any){1'b0}};
                r_pre_onebank           <= {$bits(r_pre_onebank){1'b0}};
                r_enter_power_savings   <= {$bits(r_enter_power_savings){1'b0}};
                r_exit_power_savings    <= {$bits(r_exit_power_savings){1'b0}};
                //r_te_rd_row             <= {$bits(r_te_rd_row){1'b0}};
                r_ts_act_page           <= {$bits(r_ts_act_page){1'b0}};
                r_te_rd_blk                 <= {$bits(r_te_rd_blk){1'b0}};
                r_te_rd_word            <= {$bits(r_te_rd_word){1'b0}};
                r_te_rd_rmw_type        <= {$bits(r_te_rd_rmw_type){1'b0}};
                r_te_rd_link_addr       <= {$bits(r_te_rd_link_addr){1'b0}};
                r_te_rd_length          <= {$bits(r_te_rd_length){1'b0}};
                r_te_rd_tag             <= {$bits(r_te_rd_tag){1'b0}};
                r_te_rd_addr_err        <= {$bits(r_te_rd_addr_err){1'b0}};
                //r_te_wr_row             <= {$bits(r_te_wr_row){1'b0}};
                r_te_wr_blk             <= {$bits(r_te_wr_blk){1'b0}};
                r_te_wr_word            <= {$bits(r_te_wr_word){1'b0}};

                r_autopre               <= {$bits(r_autopre){1'b0}};
                r_op_any_rwa            <= {$bits(r_op_any_rwa){1'b0}};
                r_op_any_other          <= {$bits(r_op_any_other){1'b0}};
                r_op_rdwr               <= {$bits(r_op_rdwr){1'b0}};
                r_rd_is_partial         <= {$bits(r_rd_is_partial){1'b0}};
                r_total_rd_latency      <= {$bits(r_total_rd_latency){1'b0}};
                r_total_wr_latency      <= {$bits(r_total_wr_latency){1'b0}};
                rdwr_latency_timer      <= {$bits(rdwr_latency_timer){1'b0}};
                r_stop_clk_nxt          <= {$bits(r_stop_clk_nxt){1'b0}};

   end else begin
                r_init_in_progress      <= gs_pi_init_in_progress;
                r_init_cke_non_lpddr    <= gs_pi_init_cke;
                r_gs_op_is_load_mode    <= gs_op_is_load_mode
                                           ;
                r_mrs_a                 <= gs_pi_mrs_a;


                // if read or write, set auto-precharge indicator appropriately
                // note: read bypass is never issued with auto-precharge
                r_autopre <= (gs_op_is_rd | gs_op_is_wr) & os_te_autopre;

                r_ts_act_page <= ts_act_page;
                r_te_rd_blk <= te_pi_rd_blk;
                r_te_rd_word <= te_pi_rd_word;
                r_te_rd_rmw_type <= te_pi_rd_rmw_type;
                r_te_rd_link_addr <= te_pi_rd_link_addr;
                r_te_rd_length <= te_pi_rd_length;
                r_te_rd_tag <= te_pi_rd_tag;
                r_te_rd_addr_err <= te_pi_rd_addr_err;
                r_te_wr_blk <= te_pi_wr_blk;

                r_te_wr_word <= te_pi_wr_word;
                r_gs_op_is_rd <= gs_op_is_rd;
                r_gs_op_is_wr <= gs_op_is_wr;
                r_gs_op_is_refresh        <= gs_op_is_ref;
                r_ctrlupd_req <= ddrc_dfi_ctrlupd_req | gs_pi_ctrlupd_req;
                r_phyupd_pause_req <= gs_pi_phyupd_pause_req;

                r_enter_power_savings <= gs_op_is_enter_selfref | gs_op_is_enter_powerdown |
                                         1'b0;
                r_exit_power_savings <= gs_op_is_exit_selfref | gs_op_is_exit_powerdown |
                                        1'b0;


                r_act_any     <= gs_op_is_act ;
                r_pre_any     <= gs_op_is_pre;
                r_pre_onebank <= gs_op_is_pre;
                // assert something for ANY operation

                r_op_any_rwa <=

                            //In LPDDR4 1:4 mode, PRE command is issued phase 0 & 1.
                            (dh_pi_frequency_ratio & gs_op_is_pre)      |
                            gs_op_is_act | gs_op_is_rd | gs_op_is_wr;

                r_op_any_other <=
                            //In LPDDR4 1:4 mode, PRE command is issued phase 0 & 1.
                            (!dh_pi_frequency_ratio & gs_op_is_pre)      |
                            gs_op_is_enter_selfref   | gs_op_is_exit_selfref   |
                            gs_op_is_enter_powerdown | gs_op_is_exit_powerdown |
                            gs_op_is_load_mode
                              | gs_op_is_ref                                       ;

                gs_pi_op_is_pde_r  <= gs_op_is_enter_powerdown;
                gs_pi_op_is_pdx_r  <= gs_op_is_exit_powerdown;

                // assign the r_op_rdwr pipeline for counting read/write cycles
                r_op_rdwr[0] <= i_op_rdwr;
                r_rd_is_partial <= i_rd_is_partial ;

                // Assign total required time for clock to continue to run fullowing
                // a read or a write command. The clock to DRAM will be stopped when
                // the rdwr_latency_timer expires.
                // NOTE: One cycle has been added to the latencies, but that seemed
                // to be required in simulation.
                //

                r_total_wr_latency <= {{($bits(r_total_wr_latency)-$bits(reg_ddrc_write_latency)){1'b0}}, reg_ddrc_write_latency} + {{($bits(r_total_wr_latency)-$bits(dh_pi_burst_rdwr_core_clk)){1'b0}}, dh_pi_burst_rdwr_core_clk} + {{($bits(r_total_wr_latency)-1){1'b0}},1'b1};
                r_total_rd_latency <= {{($bits(r_total_rd_latency)-$bits(reg_ddrc_read_latency)){1'b0}}, reg_ddrc_read_latency} + {{($bits(r_total_rd_latency)-$bits(dh_pi_burst_rdwr_core_clk)){1'b0}}, dh_pi_burst_rdwr_core_clk} + {{($bits(r_total_rd_latency)-1){1'b0}},1'b1};


                rdwr_latency_timer <= r_op_rdwr[0] ? (r_gs_op_is_wr ?               r_total_wr_latency        :
                                                                                    r_total_rd_latency       ):
                                                       ((|rdwr_latency_timer) ?    (rdwr_latency_timer-{{($bits(rdwr_latency_timer)-1){1'b0}},1'b1}):
                                                                                    {$bits(rdwr_latency_timer){1'b0}}) ;

                r_stop_clk_nxt <=
                                  (dh_pi_en_dfi_dram_clk_disable) & (i_clock_stop_allowed       ) &
                                  (i_stop_clk_entry_cnt_zero    ) &                                  // clock stop entry timer requirements satisfied
                                  (mrr_mrw_latency_timer_zero   ) &                                  // tMRR/tMRW must be met
                                  (gs_wck_stop_ok               ) &
                                  (~ih_pi_xact_valid            ) & (~r_op_any                  ) &  // no new transactions, this cycle or last
                                  (~te_pi_rd_valid              ) & (~te_pi_wr_valid            ) &  // no pending transactions
                                  (~gs_op_is_enter_powerdown    ) & (~gs_op_is_exit_powerdown   ) &  // no powerdown entry
                                  (~gs_op_is_enter_selfref      ) & (~gs_op_is_exit_selfref     ) &  // no powerdown exit
                                  (gs_pi_data_pipeline_empty    ) &                                  // no read data outstanding
                                  (~dqsosc_in_prog              ) &                                  // NO DQSOSC is running
                                  (~gs_pi_odt_pending           ) &                                  // No ODT pending
                                  (gs_pi_stop_clk_ok            );                                   // no other requirement to run clock

        end


    assign r_op_any = r_op_any_other | r_op_any_rwa;


   // Latch
   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         pre_rankbank_num_r   <= {RANKBANK_BITS{1'b0}};
         rdwr_rankbank_num_r  <= {RANKBANK_BITS{1'b0}};
         act_rankbank_num_r   <= {RANKBANK_BITS{1'b0}};
         refpb_bank_r         <= {BANK_BITS{1'b0}};
      end
      else begin
         pre_rankbank_num_r   <= gs_pre_rankbank_num;
         rdwr_rankbank_num_r  <= gs_rdwr_rankbank_num;
         act_rankbank_num_r   <= gs_act_rankbank_num;
         refpb_bank_r         <= gs_pi_refpb_bank;
      end
   end

//------------------------------------------------------------------------------
// Clock Stop functionality
//------------------------------------------------------------------------------

// Clock stop only allowed for Self Refresh if DDR2/DDR3
// Always allowed if LPDDR4

assign i_clock_stop_allowed =
        dh_pi_lpddr4 | (reg_ddrc_lpddr5 & (!reg_ddrc_wck_on | (gs_pi_stop_clk_type != 2'b11))) |
        (gs_pi_stop_clk_type == 2'b00);

// logic only needed for MEMC_LPDDR4 as i_gs_pi_stop_clk_type_ed only used
// in i_stop_clk_entry_cnt_val_upd if MEMC_LPDDR4 is defined

reg [1:0] i_gs_pi_stop_clk_type_r;

// register on gs_pi_stop_clk_type
always @(posedge co_pi_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_gs_pi_stop_clk_type_r <= {$bits(i_gs_pi_stop_clk_type_r){1'b0}};
  end else begin
    i_gs_pi_stop_clk_type_r <= gs_pi_stop_clk_type;
  end
end

// gs_pi_stop_clk_type value is changing
wire i_gs_pi_stop_clk_type_ed;
assign i_gs_pi_stop_clk_type_ed = (gs_pi_stop_clk_type!=i_gs_pi_stop_clk_type_r) ? 1'b1 : 1'b0;


// rising edge detection
wire pi_gs_stop_clk_early_red;
assign pi_gs_stop_clk_early_red = pi_gs_stop_clk_early & (~pi_ph_stop_clk_r);

reg [1:0] i_pi_gs_stop_clk_type;

// uses pi_gs_stop_clk_early_red to store gs_pi_stop_clk_type value
// used to drive pi_gs_stop_clk_type
always @(posedge co_pi_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_pi_gs_stop_clk_type <= {$bits(i_pi_gs_stop_clk_type){1'b0}};
  end else begin
    if (pi_gs_stop_clk_early_red) begin
      i_pi_gs_stop_clk_type <= gs_pi_stop_clk_type;
    end
  end
end

// update type if i_pi_gs_stop_clk_type currently changing (pi_gs_stop_clk_early_red)
assign  pi_gs_stop_clk_type = (pi_gs_stop_clk_early_red) ? gs_pi_stop_clk_type : i_pi_gs_stop_clk_type;


// width is based on fact all inputs are 4 bits wide


reg [$bits(reg_ddrc_t_cksre)-1:0] i_stop_clk_entry_cnt_val_sel;
wire i_stop_clk_entry_cnt_val_upd;

// select between which cnt values as defined in gs_global_fsm signal gs_pi_stop_clk_type :
// - t_cksre for SR/MPSM (for MPSM tCKMPE is required - satisfied by counter in gs_load_mr; gs_pi_stop_clk_type in gs_global_fsm is set
//   to 0 for MPSM like in the case of SR, so there is an extra tCKSRE which does not affect performance
// - t_cksre(tCKPDE) for PD
//
// gs_pi_stop_clk_type = 2'b00 : self-refresh / MPSM
//                       2'b01 : power down
//                       2'b10 : deep power down (The legacy protocol only supported deep power down. This is not used.)
//                       2'b11 : active
always @(*) begin
    case (gs_pi_stop_clk_type)
        2'b01   : i_stop_clk_entry_cnt_val_sel = {{($bits(i_stop_clk_entry_cnt_val_sel)-$bits(reg_ddrc_t_cksre)){1'b0}}, reg_ddrc_t_cksre};
        2'b11   : begin
                  // Extra 4 clock
                  if (dh_pi_lpddr4)
                    i_stop_clk_entry_cnt_val_sel = (dh_pi_frequency_ratio ? {{($bits(i_stop_clk_entry_cnt_val_sel)-3){1'b0}},3'b100} : {{($bits(i_stop_clk_entry_cnt_val_sel)-2){1'b0}},2'b10});
                  else
                    i_stop_clk_entry_cnt_val_sel = {$bits(i_stop_clk_entry_cnt_val_sel){1'b0}};
        end
        default : i_stop_clk_entry_cnt_val_sel = {{($bits(i_stop_clk_entry_cnt_val_sel)-$bits(reg_ddrc_t_cksre)){1'b0}},reg_ddrc_t_cksre};
    endcase
end

// if stopping clock is not ok or
// if gs_pi_stop_clk_type has changed (i_gs_pi_stop_clk_type_ed) or
// if ODT is still pending from a previous command
assign i_stop_clk_entry_cnt_val_upd = r_op_any | (~gs_pi_stop_clk_ok) | i_gs_pi_stop_clk_type_ed | gs_pi_odt_pending;


wire [$bits(i_stop_clk_entry_cnt_val_sel):0] i_stop_clk_entry_cnt_val_add;
assign i_stop_clk_entry_cnt_val_add = {{($bits(i_stop_clk_entry_cnt_val_add)-$bits(reg_ddrc_dfi_t_ctrl_delay)){1'b0}}, reg_ddrc_dfi_t_ctrl_delay} +
                                                                             {{($bits(i_stop_clk_entry_cnt_val_add)-$bits(i_stop_clk_entry_cnt_val_sel)){1'b0}}, i_stop_clk_entry_cnt_val_sel}
        // In case of LPDDR4, ACT is 4-cycle command and the timing parameter is
        // base on the end cycle of commands. Since BSM treats command-to-command
        // timing which is based on the first cycle of commands, gs_pi_stop_clk_ok is
        // 3 clocks faster than the actual timing.
                                          + (dh_pi_frequency_ratio ? {{($bits(i_stop_clk_entry_cnt_val_add)-1){1'b0}},1'b1} : {{($bits(i_stop_clk_entry_cnt_val_add)-2){1'b0}},2'b10})
                                          ;

wire [$bits(reg_ddrc_dfi_t_dram_clk_disable):0] i_stop_clk_entry_cnt_val_sub;
assign i_stop_clk_entry_cnt_val_sub = {{($bits(i_stop_clk_entry_cnt_val_sub)-$bits(reg_ddrc_dfi_t_dram_clk_disable)){1'b0}}, reg_ddrc_dfi_t_dram_clk_disable} + {{($bits(i_stop_clk_entry_cnt_val_sub)-1){1'b0}},1'b1};

//spyglass disable_block W164a
//SMD: LHS: 'i_stop_clk_entry_cnt_val' width 8 is less than RHS: '(i_stop_clk_entry_cnt_val_add - i_stop_clk_entry_cnt_val_sub)' width 9 in assignment
//SJ: Underflow not possible. Protected by conditional operator used in assignment (i?j:k)
wire [$bits(i_stop_clk_entry_cnt_val_add)-1:0] i_stop_clk_entry_cnt_val;
assign i_stop_clk_entry_cnt_val = (i_stop_clk_entry_cnt_val_add>{{($bits(i_stop_clk_entry_cnt_val_add)-$bits(i_stop_clk_entry_cnt_val_sub)){1'b0}},i_stop_clk_entry_cnt_val_sub}) ?
                                                                                   {{($bits(i_stop_clk_entry_cnt_val)-$bits(i_stop_clk_entry_cnt_val_add)){1'b0}},i_stop_clk_entry_cnt_val_add} -
                                                                                                {{($bits(i_stop_clk_entry_cnt_val)-$bits(i_stop_clk_entry_cnt_val_sub)){1'b0}},i_stop_clk_entry_cnt_val_sub} :
                                                                                   {($bits(i_stop_clk_entry_cnt_val)){1'b0}};
//spyglass enable_block W164a

reg [$bits(i_stop_clk_entry_cnt_val)-1:0] i_stop_clk_entry_cnt;
always @(posedge co_pi_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_stop_clk_entry_cnt <= {$bits(i_stop_clk_entry_cnt){1'b0}};
  end else begin
    if (i_stop_clk_entry_cnt_val_upd) begin
      i_stop_clk_entry_cnt <= i_stop_clk_entry_cnt_val;
    end else if (i_stop_clk_entry_cnt>{$bits(i_stop_clk_entry_cnt){1'b0}} && rdwr_latency_timer_zero) begin
      i_stop_clk_entry_cnt <= i_stop_clk_entry_cnt - {{($bits(i_stop_clk_entry_cnt)-1){1'b0}},1'b1};
    end
  end
end

assign i_stop_clk_entry_cnt_zero = (i_stop_clk_entry_cnt=={$bits(i_stop_clk_entry_cnt){1'b0}}) ? 1'b1 : 1'b0;
assign rdwr_latency_timer_zero = (rdwr_latency_timer==0) ? 1'b1 : 1'b0;
assign mrr_mrw_latency_timer_zero = (mrr_mrw_latency_timer==0) ? 1'b1 : 1'b0;


//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(2 * NUM_RANKS)'/'(i * 6)'/'(i * 10)'/others found in module 'pi'
//SJ: This coding style is acceptable and there is no plan to change it.

//------------------------------------------------------------------------------
// Intermediate Signals
//------------------------------------------------------------------------------

assign rdwr_is_rd = ~r_gs_op_is_wr;




// wrdata_cs_n/rddata_cs_n logic - feed through. All timing is handled in the gs_odt block
assign pi_ph_wrdata_cs_n = gs_pi_wrdata_cs_n;
assign pi_ph_rddata_cs_n = gs_pi_rddata_cs_n;



   //-----------------------------------------------------------------------------
   // LPDDR4 command encode
   //-----------------------------------------------------------------------------

   assign active_ranks_lp4 = {NUM_RANKS{1'b1}};

   assign column_addr =
                        r_gs_op_is_wr ? {r_te_wr_blk, r_te_wr_word} :
                                        {r_te_rd_blk, r_te_rd_word};

   assign row_addr    =
                                       r_ts_act_page;   // scheduled activates

   reg per_bank_refresh_r;
   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
        per_bank_refresh_r <= 1'b0;
      end else begin
        per_bank_refresh_r <= dh_pi_per_bank_refresh;
      end
   end

   // all bank refresh
   wire ab_ref_flag;
   assign ab_ref_flag  = ~per_bank_refresh_r;

   // precharge all
   wire ab_pre_flag;
   assign ab_pre_flag  = ~(r_pre_onebank);

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         op_is_lp_sre_r  <= 1'b0;
         op_is_lp_srx_r  <= 1'b0;
         mpc_zq_start_r  <= 1'b0;
         mpc_zq_latch_r  <= 1'b0;
         op_is_srpde_r   <= 1'b0;
         op_is_srpdx_r   <= 1'b0;
         op_is_dsme_r    <= 1'b0;
         op_is_dsmx_r    <= 1'b0;
         op_is_ws_off_r  <= 1'b0;
         mpc_dqsosc_start_r <= 1'b0;
      end else begin
         op_is_lp_sre_r  <= gs_op_is_enter_sr_lpddr;
         op_is_lp_srx_r  <= gs_op_is_exit_sr_lpddr;
         mpc_zq_start_r  <= gs_mpc_zq_start;
         mpc_zq_latch_r  <= gs_mpc_zq_latch;
         op_is_srpde_r   <= gs_op_is_enter_selfref;
         op_is_srpdx_r   <= gs_op_is_exit_selfref;
         op_is_dsme_r    <= gs_op_is_enter_dsm;
         op_is_dsmx_r    <= gs_op_is_exit_dsm;
         op_is_ws_off_r  <= gs_op_is_cas_ws_off;
         mpc_dqsosc_start_r <= gs_mpc_dqsosc_start;
      end
   end

   // MPC command
   assign mpc_cmd_en  = (mpc_zq_start_r | mpc_zq_latch_r | mpc_dqsosc_start_r);
   // MPC OP
   assign op_mpc      = mpc_dqsosc_start_r ?  r_mrs_a[13:7]: (mpc_zq_latch_r) ? 7'b1010001 : 7'b1001111;

   assign op_is_rd    =
                        r_gs_op_is_rd;

   // MRR command
   assign op_is_mrr   = (r_gs_op_is_load_mode && (gs_pi_mrr | gs_pi_mrr_ext));
   // MRW command
   assign op_is_mrw   = (r_gs_op_is_load_mode && !(gs_pi_mrr | gs_pi_mrr_ext) && !mpc_cmd_en);
   // MPC command
   assign op_is_mpc   = (r_gs_op_is_load_mode && mpc_cmd_en);

   logic [2:0] act_bank_num;
   logic [2:0] rdwr_bank_num;

   assign act_bank_num  =
                                         act_rankbank_num_r[2:0];

   assign rdwr_bank_num =
                                         rdwr_rankbank_num_r[2:0];


   // 1st command encode
   always_comb begin
                           // {L: CA[5:0], H: CA[5:0]}
      if (r_act_any) begin                            // ACT1
         lpddr4_cmd_1st = {{row_addr[11:10], row_addr[16], act_bank_num},
                           {row_addr[15:12], 2'b01}};
      end
      else if (op_is_rd) begin                        // RD1
         lpddr4_cmd_1st = {{r_autopre, column_addr[9], 1'b0, rdwr_bank_num},
                           {1'b0, 5'b00010}};
      end
      else if (r_gs_op_is_wr & ts_pi_mwr_flag) begin  // MWR1
         lpddr4_cmd_1st = {{r_autopre, column_addr[9], 1'b0, rdwr_bank_num},
                           {6'b001100}};
      end
      else if (r_gs_op_is_wr) begin                   // WR1
         lpddr4_cmd_1st = {{r_autopre, column_addr[9], 1'b0, rdwr_bank_num},
                           {1'b0, 5'b00100}};
      end
      else if (op_is_mrr) begin                       // MRR1
         lpddr4_cmd_1st = {{r_mrs_a[13:8]},
                           {1'b0, 5'b01110}};
      end
      else if (r_gs_op_is_load_mode && mpc_cmd_en) begin   // MPC
         lpddr4_cmd_1st = {{op_mpc[5:0]},
                           {op_mpc[6], 5'b00000}};
      end
      else if (r_gs_op_is_load_mode) begin            // MRW1
         lpddr4_cmd_1st = {{r_mrs_a[13:8]},
                           {r_mrs_a[7], 5'b00110}};
      end
      else if (r_pre_any) begin                       // PRE
         lpddr4_cmd_1st = {{3'b000, pre_rankbank_num_r[2:0]},
                           {ab_pre_flag, 5'b10000}};
      end
      else if (r_gs_op_is_refresh && !dh_pi_frequency_ratio) begin   // REF (1:2 mode)
         lpddr4_cmd_1st = {{3'b000, refpb_bank_r},
                           {ab_ref_flag, 5'b01000}};
      end
      else if (op_is_lp_sre_r) begin                  // SRE
         lpddr4_cmd_1st = {{6'b000000},
                           {1'b0, 5'b11000}};
      end
      else if (op_is_lp_srx_r) begin                  // SRX
         lpddr4_cmd_1st = {{6'b000000},
                           {1'b0, 5'b10100}};
      end
      else begin                                      // all-0
         lpddr4_cmd_1st = {lpddr4_ca_r[11:6],
                           lpddr4_ca_r[11:6]};
      end
   end

   // 2nd command encode
   always_comb begin
                           // {L: CA[5:0], H: CA[5:0]}
      if (r_act_any) begin                            // ACT2
         lpddr4_cmd_2nd = {{row_addr[5:0]},
                           {row_addr[9:6], lpddr4_row17_exist ? {1'b1, row_addr[17]} : 2'b11}};
      end
      else if (op_is_rd || r_gs_op_is_wr) begin       // CAS2 (RD2, WR2)
         lpddr4_cmd_2nd = {{column_addr[7:2]},
                           {column_addr[8], 5'b10010}};
      end
      else if (op_is_mrr) begin                       // CAS2 (MRR2)
         lpddr4_cmd_2nd = {{6'b000000},
                           {1'b0, 5'b10010}};
      end
      else if (r_gs_op_is_load_mode && !mpc_cmd_en) begin   // MRW2
         lpddr4_cmd_2nd = {{r_mrs_a[5:0]},
                           {r_mrs_a[6], 5'b10110}};
      end
      else if (r_gs_op_is_refresh && dh_pi_frequency_ratio) begin    // REF (1:4 mode)
         lpddr4_cmd_2nd = {{3'b000, refpb_bank_r},
                           {ab_ref_flag, 5'b01000}};
      end
      else begin                                      // all-0
         lpddr4_cmd_2nd = {lpddr4_cmd_1st[11:6],
                           lpddr4_cmd_1st[11:6]};
      end
   end


   // 4 cycle command
   assign lpddr4_4cyc_cmd = (r_act_any || op_is_rd || r_gs_op_is_wr || r_gs_op_is_load_mode);

   // 2 cycle command
   assign lpddr4_2cyc_cmd = (op_is_lp_sre_r || op_is_lp_srx_r ||
                             r_gs_op_is_refresh || r_pre_any);

   // to issue LPDDR4 command at next cycle
   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr4_cmd_tmg_r <= 1'b0;
      end
      else if(lpddr4_4cyc_cmd && !dh_pi_frequency_ratio) begin      // 4 cycle command at 1:2 mode
         lpddr4_cmd_tmg_r <= 1'b1;
      end
      else begin
         lpddr4_cmd_tmg_r <= 1'b0;
      end
   end

   // latch last command
   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr4_ca_r <= {2*6{1'b0}};
      end
      else if (lpddr4_4cyc_cmd) begin
         lpddr4_ca_r <= lpddr4_cmd_2nd;
      end
      else if (lpddr4_2cyc_cmd) begin
         if (r_gs_op_is_refresh && dh_pi_frequency_ratio) begin    // REF (1:4 mode)
            lpddr4_ca_r <= lpddr4_cmd_2nd;
         end
         else begin
            lpddr4_ca_r <= lpddr4_cmd_1st;
         end
      end
   end

   // CA bus
   always_comb begin
      if (dh_pi_frequency_ratio) begin // 1:4 mode
         lpddr4_ca = {lpddr4_cmd_2nd, lpddr4_cmd_1st};
      end else
      begin                       // 1:2 mode
         if (lpddr4_cmd_tmg_r) begin
            lpddr4_ca = {{(`MEMC_FREQ_RATIO-2)*6{1'b0}}, lpddr4_ca_r};
         end
         else begin
            lpddr4_ca = {{(`MEMC_FREQ_RATIO-2)*6{1'b0}}, lpddr4_cmd_1st};
         end
      end
   end


   // CA bus
   assign lpddr4_dfi_addr.p3 = lpddr4_ca[23:18];
   assign lpddr4_dfi_addr.p2 = lpddr4_ca[17:12];
   assign lpddr4_dfi_addr.p1 = lpddr4_ca[11: 6];
   assign lpddr4_dfi_addr.p0 = {{(`MEMC_DFI_ADDR_WIDTH_P0-6){1'b0}}, lpddr4_ca[ 5: 0]};

   // CS
   always_comb begin
      if (r_act_any) begin
         lpddr4_cs_1st = 1'b1;
         lpddr4_cs_2nd = 1'b1;
      end
      else if (op_is_rd || r_gs_op_is_wr) begin
         lpddr4_cs_1st = 1'b1;
         lpddr4_cs_2nd = 1'b1;
      end
      else if (r_gs_op_is_load_mode && !mpc_cmd_en) begin
         lpddr4_cs_1st = 1'b1;
         lpddr4_cs_2nd = 1'b1;
      end
      else if (op_is_lp_sre_r || op_is_lp_srx_r) begin
         lpddr4_cs_1st = active_ranks_lp4;
         lpddr4_cs_2nd = {NUM_RANKS{1'b0}};
      end
      else begin
         if (dh_pi_frequency_ratio) begin    // 1:4 mode
            lpddr4_cs_1st = (r_pre_any | r_gs_op_is_load_mode);
            lpddr4_cs_2nd = r_gs_op_is_refresh;
         end
         else begin
            lpddr4_cs_1st = (r_pre_any | r_gs_op_is_refresh | r_gs_op_is_load_mode);
            lpddr4_cs_2nd = 1'b0;
         end
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr4_cs_2nd_r <= {NUM_RANKS{1'b0}};
      end
      else begin
         lpddr4_cs_2nd_r <= lpddr4_cs_2nd;
      end
   end

   // cs
   assign lpddr4_dfi_cs[          0+:NUM_RANKS] = dh_pi_frequency_ratio ? lpddr4_cs_1st   :
                                                  lpddr4_cmd_tmg_r      ? lpddr4_cs_2nd_r :
                                                                          lpddr4_cs_1st;
   assign lpddr4_dfi_cs[  NUM_RANKS+:NUM_RANKS] = {NUM_RANKS{1'b0}};

   assign lpddr4_dfi_cs[2*NUM_RANKS+:NUM_RANKS] = dh_pi_frequency_ratio ? lpddr4_cs_2nd :
                                                                          {NUM_RANKS{1'b0}};
   assign lpddr4_dfi_cs[3*NUM_RANKS+:NUM_RANKS] = {NUM_RANKS{1'b0}};

   assign lpddr4_noxact = (lpddr4_4cyc_cmd && dh_pi_lpddr4 && !dh_pi_frequency_ratio);
   assign upd_ok_lpddr4 = (!dh_pi_lpddr4 || !(lpddr4_cmd_tmg_r || lpddr4_4cyc_cmd || lpddr4_2cyc_cmd));


   assign lpddr4_dfi_cke = {`MEMC_FREQ_RATIO{active_ranks_lp4}} & (
                           r_init_in_progress    ? {`MEMC_FREQ_RATIO*NUM_RANKS{r_init_cke_non_lpddr}} :
                           r_enter_power_savings ? {{(`MEMC_FREQ_RATIO-1)*NUM_RANKS{1'b0}}, {NUM_RANKS{1'b1}}} :
                           r_exit_power_savings  ? {{(`MEMC_FREQ_RATIO-1)*NUM_RANKS{1'b1}}, {NUM_RANKS{1'b0}}} :
                                                   {`MEMC_FREQ_RATIO{r_last_cke[NUM_RANKS-1:0]}});

   // time the latency after MRR/MRW :
   // - load tMRW when MRW or MRR detected
   // - decrement counter until it reaches 0
   always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         mrr_mrw_latency_timer <= {$bits(mrr_mrw_latency_timer){1'b0}};
      end
      else if (r_gs_op_is_load_mode) begin
         mrr_mrw_latency_timer <= reg_ddrc_t_mr;
      end
      else if (|mrr_mrw_latency_timer) begin
         mrr_mrw_latency_timer <= mrr_mrw_latency_timer - {{($bits(mrr_mrw_latency_timer)-1){1'b0}},1'b1};
      end
   end

   assign lpddr4_row17_exist = dh_pi_lpddr4 ? (~(&dh_pi_addrmap_row_b17)) : 1'b0;

   always @(posedge co_pi_clk or negedge core_ddrc_rstn) begin
       if (~core_ddrc_rstn) begin
           ts_pi_mwr_flag <= {$bits(ts_pi_mwr_flag){1'b0}};
       end else if(gs_op_is_wr) begin
           ts_pi_mwr_flag <= ts_pi_mwr;
       end
   end


   // ----------------------------------------------------------------------------
   // LPDDR5 command encode
   // ----------------------------------------------------------------------------

   assign cas_ws_fs_en = 1'b0;

   // Self refresh state
   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         selfref_st_r <= 1'b0;
      end
      else if (op_is_lp_sre_r || op_is_srpde_r || op_is_dsme_r) begin
         selfref_st_r <= 1'b1;
      end
      else if (op_is_lp_srx_r) begin
         selfref_st_r <= 1'b0;
      end
   end

   // BG, bank
   logic [3:0] act_bg_bank_num;
   logic [3:0] rdwr_bg_bank_num;
   logic [3:0] pre_bg_bank_num;
   assign act_bg_bank_num  =
                                            {act_rankbank_num_r[0+:BG_BITS], act_rankbank_num_r[BG_BITS+:2]};
   assign rdwr_bg_bank_num =
                                            {rdwr_rankbank_num_r[0+:BG_BITS], rdwr_rankbank_num_r[BG_BITS+:2]};
   assign pre_bg_bank_num  =                {pre_rankbank_num_r[0+:BG_BITS], pre_rankbank_num_r[BG_BITS+:2]};

   logic    gs_cas_ws_req_r;

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         gs_cas_ws_req_r <= 1'b0;
      end
      else begin
         gs_cas_ws_req_r <= gs_cas_ws_req;
      end
   end

   // column bit3
   assign pi_col_b3  = column_addr[3];

   // CAS-WS
   assign cas_ws_en  = (gs_cas_ws_req_r && (op_is_rd || r_gs_op_is_wr || op_is_mrr));
   // CAS-B3
   assign cas_b3_en  = (column_addr[3] && op_is_rd);
   // MPC OP
   assign op_mpc_lp5 = mpc_dqsosc_start_r ?  r_mrs_a[13:6]: (mpc_zq_latch_r) ? 8'b1000_0110 : 8'b1000_0101;


   // 1st command encode
   always_comb begin
                           // {F: CA[6:0], R: CA[6:0]}
      if (r_act_any) begin                            // ACT1
         lpddr5_cmd_1st = {{row_addr[13:11], act_bg_bank_num},
                           {row_addr[17:14], 3'b111}};
      end
      else if (cas_ws_en) begin                       // CAS-WS
         lpddr5_cmd_1st = {{(column_addr[3] && op_is_rd), 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
                           {cas_ws_fs_en, (op_is_rd | op_is_mrr) & ~cas_ws_fs_en, r_gs_op_is_wr & ~cas_ws_fs_en, 4'b1100}};
      end
      else if (cas_b3_en) begin                       // CAS-B3
         lpddr5_cmd_1st = {{column_addr[3], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
                           {1'b0, 1'b0, 1'b0, 4'b1100}};
      end
      else if (r_gs_op_is_load_mode && mpc_cmd_en) begin   // MPC
         lpddr5_cmd_1st = {{op_mpc_lp5[6:0]},
                           {op_mpc_lp5[7], 6'b110000}};
      end
      else if (op_is_mrw) begin                       // MRW1
         lpddr5_cmd_1st = {{r_mrs_a[14:8]},
                           {7'b1011000}};
      end
      else if (r_pre_any) begin                       // PRE
         lpddr5_cmd_1st = {{ab_pre_flag, 1'b0, 1'b0, pre_bg_bank_num},
                           {7'b1111000}};
      end
      else if (r_gs_op_is_refresh) begin              // REF
         lpddr5_cmd_1st = {{ab_ref_flag, 1'b0, 1'b0, 1'b0, refpb_bank_r},
                           {7'b0111000}};
      end
      else if (op_is_lp_sre_r) begin                  // SRE
         lpddr5_cmd_1st = {{1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
                           {7'b1101000}};
      end
      else if (op_is_srpde_r && !selfref_st_r) begin  // SR-PD
         lpddr5_cmd_1st = {{1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
                           {7'b1101000}};
      end
      else if (op_is_dsme_r) begin                    // DSM
         lpddr5_cmd_1st = {{1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0},
                           {7'b1101000}};
      end
      else if (op_is_lp_srx_r) begin                  // SRX
         lpddr5_cmd_1st = {{7'b0000000},
                           {7'b0101000}};
      end
      else if (gs_pi_op_is_pde_r ||                   // PDE
               (op_is_srpde_r && selfref_st_r)) begin // PDE in SR
         lpddr5_cmd_1st = {{7'b0000000},
                           {7'b1000000}};
      end
      else if (op_is_ws_off_r) begin                  // CAS-WS_OFF
         lpddr5_cmd_1st = {{7'b0000000},
                           {3'b111, 4'b1100}};
      end
      else begin                                      // NOP/DES /PDX
         lpddr5_cmd_1st = {{7'b0000000},
                           {7'b0000000}};
      end
   end

   logic [13:0]   lpddr5_act2_r;

   // 2nd command encode
   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr5_act2_r <= 14'd0;
      end                     // {F: CA[6:0], R: CA[6:0]}
      else if (r_act_any) begin                       // ACT2
         lpddr5_act2_r <= {{row_addr[6:0]},
                           {row_addr[10:7], 3'b011}};
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr5_cmd_2nd_r <= 14'd0;
      end                     // {F: CA[6:0], R: CA[6:0]}
      else if (op_is_rd) begin                        // RD
         lpddr5_cmd_2nd_r <= {{r_autopre, column_addr[6:5], rdwr_bg_bank_num},
                              {column_addr[9:7], column_addr[4], 3'b001}};
      end
      else if (r_gs_op_is_wr & ts_pi_mwr_flag) begin  // MWR
         lpddr5_cmd_2nd_r <= {{r_autopre, column_addr[6:5], rdwr_bg_bank_num},
                              {column_addr[9:7], column_addr[4], 3'b010}};
      end
      else if (r_gs_op_is_wr) begin                   // WR
         lpddr5_cmd_2nd_r <= {{r_autopre, column_addr[6:5], rdwr_bg_bank_num},
                              {column_addr[9:7], column_addr[4], 3'b110}};
      end
      else if (op_is_mrr) begin                       // MRR
         lpddr5_cmd_2nd_r <= {{r_mrs_a[14:8]},
                              {7'b0011000}};
      end
      else if (op_is_mrw) begin                       // MRW2
         lpddr5_cmd_2nd_r <= {{r_mrs_a[6:0]},
                              {r_mrs_a[7], 6'b001000}};
      end
   end

   // CS
   always_comb begin
      if (r_act_any) begin                            // ACT
         lpddr5_cs_1st = 1'b1;
      end
      else if (op_is_mrr && gs_cas_ws_req_r) begin    // CAS-WS (MRR)
         lpddr5_cs_1st = 1'b1;
      end
      else if (cas_ws_en || cas_b3_en) begin          // CAS-WS (RD/WR)
         lpddr5_cs_1st = 1'b1;
      end
      else if (op_is_mrw || op_is_mpc) begin          // MRW/MPC
         lpddr5_cs_1st = 1'b1;
      end
      else if (r_pre_any) begin                       // PRE
         lpddr5_cs_1st = 1'b1;
      end
      else if (r_gs_op_is_refresh) begin              // REF
         lpddr5_cs_1st = 1'b1;
      end
      else if (op_is_ws_off_r) begin                  // CAS-WS_OFF
         lpddr5_cs_1st = 1'b1;
      end
      else if (op_is_lp_sre_r || op_is_lp_srx_r ||
               op_is_srpde_r  || op_is_srpdx_r  ||
               op_is_dsme_r   || op_is_dsmx_r   ||
               gs_pi_op_is_pde_r || gs_pi_op_is_pdx_r) begin   // SRE/SRX/SRPDE/SRPDX/DSME/DSMX/PDE/PDX
         lpddr5_cs_1st = 1'b1;
      end
      else begin
         lpddr5_cs_1st = {NUM_RANKS{1'b0}};
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr5_cs_r <= {NUM_RANKS{1'b0}};
      end
      else if (op_is_rd || r_gs_op_is_wr) begin
         lpddr5_cs_r <= 1'b1;
      end
      else if (op_is_mrr) begin
         lpddr5_cs_r <= 1'b1;
      end
      else if (|tcsh_timer_r) begin
         lpddr5_cs_r <= lpddr5_cs_r;
      end
      else begin
         lpddr5_cs_r <= lpddr5_cs_1st;
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         tcsh_timer_r <= {T_CSH_WIDTH{1'b0}};
      end
      else if (op_is_srpdx_r || op_is_dsmx_r || gs_pi_op_is_pdx_r) begin   // SRPDX/DSMX/PDX
         tcsh_timer_r <= reg_ddrc_t_csh - {{($bits(tcsh_timer_r)-1){1'b0}},1'b1};
      end
      else if (|tcsh_timer_r) begin
         tcsh_timer_r <= tcsh_timer_r - {{($bits(tcsh_timer_r)-1){1'b0}},1'b1};
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr5_act_cs_r <= {NUM_RANKS{1'b0}};
      end
      else if (r_act_any) begin                            // ACT
         lpddr5_act_cs_r <= 1'b1;
      end
   end

   assign act2_out_en = (~(r_act_any | cas_ws_en | cas_b3_en | lpddr5_2nd_cmd_en_r | act2_invalid_tmg_d2_r));

   assign gs_act_or_bypass = gs_op_is_act
                                       ;

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         act2_req_r <= 1'b0;
      end
      else if (gs_act_or_bypass) begin
         act2_req_r <= 1'b1;
      end
      else if (act2_out_en) begin
         act2_req_r <= 1'b0;
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         lpddr5_2nd_cmd_en_r <= 1'b0;
      end
      else if (op_is_rd | r_gs_op_is_wr | op_is_mrr | op_is_mrw) begin
         lpddr5_2nd_cmd_en_r <= 1'b1;
      end
      else begin
         lpddr5_2nd_cmd_en_r <= 1'b0;
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         t_aad_timer_r <= 5'd0;
      end
      else if (gs_act_or_bypass) begin
         t_aad_timer_r <= 5'd8;
      end
      else if (act2_req_r) begin
         t_aad_timer_r <= t_aad_timer_r - 5'd1;
      end
      else begin
         t_aad_timer_r <= 5'd0;
      end
   end

   always_ff @(posedge co_pi_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         act2_invalid_tmg_r    <= 1'b0;
         act2_invalid_tmg_d2_r <= 1'b0;
      end
      else begin
         act2_invalid_tmg_r    <= gs_op_is_act & ts_act2_invalid_tmg;
         act2_invalid_tmg_d2_r <= act2_invalid_tmg_r;
      end
   end

   assign lpddr5_noxact    = (op_is_rd | r_gs_op_is_wr | op_is_mrr | op_is_mrw | (act2_req_r && !act2_out_en)) && reg_ddrc_lpddr5;
   assign pi_lp5_noxact    = lpddr5_noxact;

   assign upd_ok_lpddr5    = (!reg_ddrc_lpddr5 || !(lpddr5_2nd_cmd_en_r | act2_req_r | (|tcsh_timer_r) | (|lpddr5_cs_1st)));
   assign pi_rdwr_ok       = act2_req_r && !act2_out_en && (t_aad_timer_r != 5'd0);
   assign pi_lp5_act2_cmd  = act2_req_r &&  act2_out_en;
   assign pi_lp5_preref_ok = reg_ddrc_lpddr5 && act2_invalid_tmg_r && !(op_is_rd | r_gs_op_is_wr | op_is_mrr | op_is_mrw);

   assign lpddr5_dfi_addr.p3 = {`MEMC_DFI_ADDR_WIDTH_P3{1'b0}};
   assign lpddr5_dfi_addr.p2 = {`MEMC_DFI_ADDR_WIDTH_P2{1'b0}};
   assign lpddr5_dfi_addr.p1 = {`MEMC_DFI_ADDR_WIDTH_P1{1'b0}};
   assign lpddr5_dfi_addr.p0 = lpddr5_2nd_cmd_en_r ? lpddr5_cmd_2nd_r :
                               pi_lp5_act2_cmd     ? lpddr5_act2_r    :
                                                     lpddr5_cmd_1st;


   assign lpddr5_dfi_cs[`MEMC_FREQ_RATIO * NUM_RANKS-1:NUM_RANKS] = {(`MEMC_FREQ_RATIO-1)*NUM_RANKS{1'b0}};
   assign lpddr5_dfi_cs[NUM_RANKS-1:0] = lpddr5_2nd_cmd_en_r ? lpddr5_cs_r     :
                                         pi_lp5_act2_cmd     ? lpddr5_act_cs_r :
                                         (|tcsh_timer_r)     ? lpddr5_cs_r     :
                                                               lpddr5_cs_1st;


   assign pi_ph_cs    = reg_ddrc_lpddr5 ? lpddr5_dfi_cs            : lpddr4_dfi_cs;
   assign pi_ph_addr  = reg_ddrc_lpddr5 ? lpddr5_dfi_addr          : lpddr4_dfi_addr;
   assign pi_ph_cke   = reg_ddrc_lpddr5 ? {$bits(pi_ph_cke){1'b0}} : lpddr4_dfi_cke;

   assign pi_ph_odt   = gs_pi_odt;

   assign pi_ph_ras_n = {$bits(pi_ph_ras_n){1'b1}};
   assign pi_ph_cas_n = {$bits(pi_ph_cas_n){1'b1}};
   assign pi_ph_we_n  = {$bits(pi_ph_we_n){1'b1}};
   assign pi_ph_bank  = {$bits(pi_ph_bank){1'b1}};






                // NOTE: One combinatorial path to output required
                //       to restart clock early enough.
                //       Care is taken to keep this paths short.
                //       ih_pi_xact valid has 1 gate after flops before PI
assign pi_gs_stop_clk_early = (dfilp_ctrl_lp | r_ctrlupd_req) ? pi_ph_stop_clk_r :
                                              r_stop_clk_nxt & (~ih_pi_xact_valid) & (~(|rdwr_latency_timer));

  always @(posedge co_pi_clk or negedge core_ddrc_rstn)
        if (~core_ddrc_rstn)
                pi_ph_stop_clk_r <= {$bits(pi_ph_stop_clk_r){1'b0}};
        else
                pi_ph_stop_clk_r <= pi_gs_stop_clk_early;

// extra clock delay in dfi designs as the command path in DFI PHY
// has one more clock delay compared to native PHY
// use registered and unregistered version as
// clock stop may no longer be applicable
assign pi_ph_stop_clk = pi_ph_stop_clk_r & pi_gs_stop_clk_early;

// DFI LP entry wait
assign pi_gs_dfilp_wait = (stop_clk_entry_wait_r & ~pi_ph_stop_clk_r);

   always @(posedge co_pi_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         stop_clk_entry_wait_r <= {$bits(stop_clk_entry_wait_r){1'b0}};
      end
      else begin
         stop_clk_entry_wait_r <= ((~i_stop_clk_entry_cnt_zero & ~i_stop_clk_entry_cnt_val_upd)
                                   | (~gs_wck_stop_ok & reg_ddrc_lpddr5)
                                  );
      end
   end


  always @(posedge co_pi_clk or negedge core_ddrc_rstn)
        if (~core_ddrc_rstn)
                pi_ph_dram_rst_n <= {$bits(pi_ph_dram_rst_n){1'b0}};
        else
                pi_ph_dram_rst_n <= gs_pi_dram_rst_n;

//------------------------------------------------------------------------------
// Outputs to BS, GS, and RT
//------------------------------------------------------------------------------

// Do not schedule operation (ANYTHING) this cycle
// The slot is used by PI to send out 2T related command or remaining
// bursts if its a multi-burst transaction
// Note: For 2T, we need to block the cycle after a command for holding addr/cmd;
//       We also must block the cycle before a re-issued read/write,
//       because any operation before this will need to hold its addr/cmd for an extra cycle
//    2T blocking is needed only in configs with MEMC_FREQ_RATIO_1 is defined
//    In MEMC_FREQ_RATIO_2 configs, with 2T mode, the gs_next_xact module allows only one command to be executed in any DDRC cycle
//    and hence there is no need to block the commands in the following DDRC cycle

//dh_pi_frequency_ratio condition

assign   pi_gs_noxact =  r_ctrlupd_req | r_phyupd_pause_req
                         | lpddr4_noxact | lpddr5_noxact
                         ;


// pi_rt_rd_vld validates all signals (like tag, etc...) going from PI to RT.
// If timing is 1T, then its validated in the cycle after GS or BE sends a command
// If the timing is 2T, then it validates this two cycles later
assign pi_gs_rd_vld = (r_op_rdwr[0]) & rdwr_is_rd;
                                               // for DFI controller update; notify for every read to DRAM
                                               // once per request (even if it's 2 DRAM commands)
assign pi_rt_rd_vld =
  // only if load_mode and MRR i.e. does not expect read token for MRW/MRS
  (gs_op_is_load_mode && (gs_pi_mrr | gs_pi_mrr_ext)) |
                      r_op_rdwr[0] & rdwr_is_rd;


logic [BANK_BITS-1:0] rdwr_bank;
logic [BG_BITS-1:0]   rdwr_bg;

   assign rdwr_bank =
                          bg_16b_addr_mode ? rdwr_rankbank_num_r[BG_BANK_BITS-1:BG_BITS] :
                                             rdwr_rankbank_num_r[BANK_BITS-1:0];

   assign rdwr_bg =
                          bg_16b_addr_mode ? rdwr_rankbank_num_r[BG_BITS-1:0] :
                                             {BG_BITS{1'b0}};

wire  [BG_BANK_BITS_FULL-1:0] r_bg_bank_num;
wire  [BG_BANK_BITS_FULL-1:0] r_last_rdwr_bg_bank;

assign r_bg_bank_num = {
                           rdwr_bank
                           ,rdwr_bg
                       };

assign r_last_rdwr_bg_bank = {
                           r_last_rdwr_bank
                           ,r_last_rdwr_bg
                             };


//------------------------------------------------------------------------------
// Generate outputs to RT
// Note: this gets a little hairy with the ifdefs.  Basically:
//  - rank/bank/row/column/word are passed back for RMW
//  - need to check path from IH for all of these signals if read bypass is used
//------------------------------------------------------------------------------


assign i_rd_partial             = r_op_rdwr[0] ? ((r_gs_op_is_rd) ? r_te_rd_length : {CMD_LEN_BITS{1'b0}})  : (r_last_rd_is_partial);
assign pi_rt_rd_tag_base                = r_op_rdwr[0] ? r_te_rd_tag      : r_last_rd_tag;
assign pi_rt_rd_addr_err        = r_op_rdwr[0] ? r_te_rd_addr_err : r_last_rd_addr_err;
assign pi_rt_rmw_type           = r_op_rdwr[0] ? r_te_rd_rmw_type : r_last_rd_rmw_type;
assign pi_rt_wr_ram_addr        = r_op_rdwr[0] ? r_te_rd_link_addr: r_last_rd_link_addr;
assign pi_rt_rankbank_num         = r_op_rdwr[0] ? r_bg_bank_num : r_last_rdwr_bg_bank;


assign pi_rt_page_num             = r_op_rdwr[0] ?
                                                   //r_te_rd_row :
                                                   r_ts_act_page :
                                                   r_last_rdwr_ecc_row;

assign pi_rt_block_num            = r_op_rdwr[0] ? r_te_rd_blk :
                                                   r_last_rdwr_blk;

assign pi_rt_critical_word        = r_op_rdwr[0] ? r_te_rd_word :
                                                   r_last_rdwr_word;



assign pi_rt_rd_partial           = i_rd_partial;



   // SMV: If it is MR operation append 2 bit tag else append 2 zeros.
assign pi_rt_rd_tag  = gs_op_is_load_mode ? { (|gs_pi_mrr_snoop_en), gs_pi_mrr_ext, gs_pi_mrr, pi_rt_rd_tag_base} :
                                               { 1'b0, 2'b00, pi_rt_rd_tag_base};
   // SMV

//------------------------------------------------------------------------------
// Outputs flopped locally for later use
//------------------------------------------------------------------------------

always @ (posedge co_pi_clk or negedge core_ddrc_rstn)
        if (~core_ddrc_rstn) begin
                r_last_cke <= {MAX_CMD_NUM * NUM_RANKS{1'b1}};
                r_last_rdwr_bg <= {$bits(r_last_rdwr_bg){1'b0}};
                r_last_rdwr_bank <= {$bits(r_last_rdwr_bank){1'b0}};
                r_last_rdwr_ecc_row     <= {$bits(r_last_rdwr_ecc_row){1'b0}};
                r_last_rdwr_blk         <= {$bits(r_last_rdwr_blk){1'b0}};
                r_last_rdwr_word        <= {$bits(r_last_rdwr_word){1'b0}};
//`ifdef MEMC_NUM_RANKS_GT_1
//                r_last_rdwr_cs_n <= {MAX_CMD_NUM * NUM_RANKS{1'b1}};
//`endif // > 1 rank
                r_last_rd_is_partial <= {$bits(r_last_rd_is_partial){1'b0}};
                r_last_rd_rmw_type <= {$bits(r_last_rd_rmw_type){1'b0}};
                r_last_rd_link_addr <= {$bits(r_last_rd_link_addr){1'b0}};
                r_last_rd_tag <= {$bits(r_last_rd_tag){1'b0}};
                r_last_rd_addr_err <= {$bits(r_last_rd_addr_err){1'b0}};
        end
        else begin // not in reset
                //r_last_cke <= {MAX_CMD_NUM{pi_ph_cke[(`MEMC_FREQ_RATIO-1)*NUM_RANKS+:NUM_RANKS]}};
                r_last_cke <= {MAX_CMD_NUM{pi_ph_cke[(2-1)*NUM_RANKS+:NUM_RANKS]}};
//`ifdef MEMC_NUM_RANKS_GT_1
//                r_last_rdwr_cs_n <= r_op_rdwr[0] ? new_cs_n : r_last_rdwr_cs_n;
//`endif // > 1 rank

                r_last_rdwr_bank <= r_op_rdwr[0] ? rdwr_bank : r_last_rdwr_bank;
                r_last_rdwr_bg  <= r_op_rdwr[0] ? rdwr_bg : r_last_rdwr_bg;


                        r_last_rd_is_partial    <= ~r_gs_op_is_wr ? r_rd_is_partial :
                                                                    r_last_rd_is_partial  ;
                        r_last_rdwr_ecc_row     <= r_op_rdwr[0] ? (r_gs_op_is_wr ? r_ts_act_page :
                                                                                   //r_te_rd_row) :
                                                                                   r_ts_act_page) :
                                                                   r_last_rdwr_ecc_row;
                        r_last_rdwr_blk         <= r_op_rdwr[0] ? (r_gs_op_is_wr ? r_te_wr_blk :
                                                                                   r_te_rd_blk) :
                                                                   r_last_rdwr_blk;
                        r_last_rdwr_word       <= r_op_rdwr[0] ? (r_gs_op_is_wr ? r_te_wr_word :
                                                                                  r_te_rd_word) :
                                                                   r_last_rdwr_word;
                        r_last_rd_rmw_type      <= r_gs_op_is_rd ? r_te_rd_rmw_type  : r_last_rd_rmw_type ;
                        r_last_rd_link_addr     <= r_gs_op_is_rd ? r_te_rd_link_addr : r_last_rd_link_addr ;
                        r_last_rd_tag           <= r_gs_op_is_rd ? r_te_rd_tag  : r_last_rd_tag ;
                        r_last_rd_addr_err      <= r_gs_op_is_rd ? r_te_rd_addr_err : r_last_rd_addr_err;
        end // else not in reset


reg     [133:0]  rddata_en_pipe;         // pipe that stores the 1's
reg     [69:0]   wrdata_en_pipe_lwr;     // pipe that stores the 1's
reg     [69:0]   wrdata_en_pipe_upr;     // pipe that stores the 1's
reg     [69:0]   wrdata_en_pipe_third;     // pipe that stores the 1's
reg     [69:0]   wrdata_en_pipe_fourth;     // pipe that stores the 1's
wire            ddrc_phy_read;          // read issued to PHY
wire            ddrc_phy_write_ph0;     // write issued to PHY
wire            ddrc_phy_write_ph1;     // write issued to PHY
wire            issue_rddata_en;        // pulse when rddata_en has to be issued
wire            issue_wrdata_en;        // pulse when wrdata_en has to be issued

   assign  ddrc_phy_read      = op_is_rd;
   assign  ddrc_phy_write_ph0 = r_gs_op_is_wr;
   assign  ddrc_phy_write_ph1 = 1'b0;



//------------------------------------------------------------------------------
// dfi_rddata_en
//------------------------------------------------------------------------------


// Issue rddata_en for Reads, MRR in LPDDR4
assign  issue_rddata_en =  ddrc_phy_read
                           || op_is_mrr
                           ;

wire [3:0] burst_rdwr_mrr_int;
assign burst_rdwr_mrr_int = 4'b0100  >>  dh_pi_frequency_ratio;

assign burst_rdwr_int = (op_is_mrr) ? burst_rdwr_mrr_int : dh_pi_burst_rdwr_core_clk;


// Subtract one from mr_t_rddata_en so that ddrc_dfi_rddata_en acts
// according to definition of reg_ddrc_t_rddata_en in databook i.e. the DFI definition
wire [7:0] mr_t_rddata_en_m1;
wire [7:0] mr_t_rddata_en_p1;
wire [7:0] mr_t_rddata_en_p2;

assign mr_t_rddata_en_m1 = {1'b0, mr_t_rddata_en} - 8'h01;
assign mr_t_rddata_en_p1 = {1'b0, mr_t_rddata_en} + 8'h01;
assign mr_t_rddata_en_p2 = {1'b0, mr_t_rddata_en} + 8'h02;

// pipeline for issuing dfi_rddata_en
always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin

   if (~core_ddrc_rstn) begin
      rddata_en_pipe <= 134'h0;
   end
   else begin
      rddata_en_pipe <= (rddata_en_pipe >> 1);
      if(issue_rddata_en) begin
        casez (burst_rdwr_int)
                4'b01?? :       // burst of 8 mode - 4 clocks of data on the phy_ddrc interface
                begin
                        if (mr_t_rddata_en != 7'h00)
                            rddata_en_pipe[mr_t_rddata_en_m1]        <= 1'b1;
                        rddata_en_pipe[{1'b0, mr_t_rddata_en}]       <= 1'b1;
                            rddata_en_pipe[mr_t_rddata_en_p1]        <= 1'b1;
                            rddata_en_pipe[mr_t_rddata_en_p2]        <= 1'b1;
                end
                default :       // burst of 4 mode - 2 clocks of data on the phy-ddrc interface. 1:4 mode
                begin
                        if (mr_t_rddata_en != 7'h00)
                            rddata_en_pipe[mr_t_rddata_en_m1]        <= 1'b1;
                        rddata_en_pipe[{1'b0, mr_t_rddata_en}]       <= 1'b1;
                end
        endcase
      end
   end
end

// output assignment
assign pi_ph_dfi_rddata_en = ((mr_t_rddata_en == 7'h00) & issue_rddata_en) | rddata_en_pipe[0];


always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin

   if (~core_ddrc_rstn) begin
      snoop_en_pipe <= 134'h0;
   end
   else begin
      snoop_en_pipe  <= (snoop_en_pipe >> 1);
      if(issue_rddata_en) begin
        casez (burst_rdwr_int)
                4'b01?? :       // burst of 8 mode - 4 clocks of data on the phy_ddrc interface
                begin
                        if (mr_t_rddata_en != 7'h00)
                            snoop_en_pipe[mr_t_rddata_en_m1]        <= |gs_pi_mrr_snoop_en_r;
                            snoop_en_pipe[{1'b0, mr_t_rddata_en}]   <= |gs_pi_mrr_snoop_en_r;
                            snoop_en_pipe[mr_t_rddata_en_p1]        <= |gs_pi_mrr_snoop_en_r;
                            snoop_en_pipe[mr_t_rddata_en_p2]        <= |gs_pi_mrr_snoop_en_r;
                end
                default :       // burst of 4 mode - 2 clocks of data on the phy-ddrc interface. 1:4 mode
                begin
                        if (mr_t_rddata_en != 7'h00)
                            snoop_en_pipe[mr_t_rddata_en_m1]        <= |gs_pi_mrr_snoop_en_r;
                            snoop_en_pipe[{1'b0, mr_t_rddata_en}]   <= |gs_pi_mrr_snoop_en_r;
                end
        endcase
      end
   end
end

always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin : dqsosc_in_prog_PROC
   if (~core_ddrc_rstn) begin
      dqsosc_in_prog <= 1'b0;
   end else begin
      if (gs_op_is_load_mode && gs_mpc_dqsosc_start)
         dqsosc_in_prog <= 1'b1;
      else if (gs_op_is_load_mode && (|gs_pi_mrr_snoop_en)) 
         dqsosc_in_prog <= 1'b0;
   end  
end

always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin : gs_pi_mrr_snoop_en_r_PROC
   if (~core_ddrc_rstn) begin
      gs_pi_mrr_snoop_en_r <= 4'h0;
   end else begin
      if(gs_op_is_load_mode && (gs_pi_mrr | gs_pi_mrr_ext))
         gs_pi_mrr_snoop_en_r <= gs_pi_mrr_snoop_en;
      else if( gs_op_is_rd)
         gs_pi_mrr_snoop_en_r <= 4'h0;
   end
end

always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin : gs_pi_mrr_snoop_en_num_PROC
   if (~core_ddrc_rstn) begin
      gs_pi_mrr_snoop_en_num <= 4'h0;
   end else begin
      if(gs_op_is_load_mode && (gs_pi_mrr | gs_pi_mrr_ext))
         gs_pi_mrr_snoop_en_num <= gs_pi_mrr_snoop_en;
   end
end
assign pi_ph_snoop_en = ({4{snoop_en_pipe[0]}} & gs_pi_mrr_snoop_en_num) | ({4{((mr_t_rddata_en == 7'h00) & issue_rddata_en)}} & gs_pi_mrr_snoop_en_r);


//------------------------------------------------------------------------------
// dfi_wrdata_en
//------------------------------------------------------------------------------



// Issue wrdata_en for Write, PDA in DDR4
assign  issue_wrdata_en = (  ddrc_phy_write_ph0 )
                          | (ddrc_phy_write_ph1 )
                          ;

//spyglass enable_block SelfDeterminedExpr-ML

// Subtract one from mr_t_wrlat so that ddrc_dfi_wrdata_en acts
// according to definition of reg_ddrc_t_wrdata_en in databook i.e. the DFI definition
wire [DFI_TPHY_WRLAT_WIDTH:0] mr_t_wrlat_m1;
wire [DFI_TPHY_WRLAT_WIDTH:0] mr_t_wrlat_p1;
wire [DFI_TPHY_WRLAT_WIDTH:0] mr_t_wrlat_p2;

assign mr_t_wrlat_m1 = {1'b0, mr_t_wrlat} - {{($bits(mr_t_wrlat_m1)-1){1'b0}},1'b1};
assign mr_t_wrlat_p1 = {1'b0, mr_t_wrlat} + {{($bits(mr_t_wrlat_p1)-1){1'b0}},1'b1};
assign mr_t_wrlat_p2 = {1'b0, mr_t_wrlat} + {{($bits(mr_t_wrlat_p2)-2){1'b0}},2'b10};

// pipeline for issuing dfi_wrdata_en
always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin

   if (~core_ddrc_rstn) begin
      wrdata_en_pipe_lwr <= 70'h0;
   end
   else begin
      wrdata_en_pipe_lwr <= (wrdata_en_pipe_lwr >> 1);
      if(issue_wrdata_en) begin
        casez (burst_rdwr_int)
                4'b01?? :       // burst of 8 mode - 4 clocks of data on the phy_ddrc interface
                begin
                        if (|mr_t_wrlat)
                            wrdata_en_pipe_lwr[mr_t_wrlat_m1[6:0]]        <= 1'b1;
                        wrdata_en_pipe_lwr[{1'b0,mr_t_wrlat}]             <= 1'b1;
                            wrdata_en_pipe_lwr[mr_t_wrlat_p1[6:0]]        <= 1'b1;
                            wrdata_en_pipe_lwr[mr_t_wrlat_p2[6:0]]        <= 1'b1;
                end
                default :       // burst of 4 mode - 2 clocks of data on the phy-ddrc interface
                begin
                        if (|mr_t_wrlat)
                            wrdata_en_pipe_lwr[mr_t_wrlat_m1[6:0]]        <= 1'b1;
                        wrdata_en_pipe_lwr[{1'b0,mr_t_wrlat}]             <= 1'b1;
                end
        endcase
      end
   end
end

// output assignment
assign pi_ph_dfi_wrdata_en[0] = ((mr_t_wrlat == {DFI_TPHY_WRLAT_WIDTH{1'b0}}) & issue_wrdata_en) | wrdata_en_pipe_lwr[0];


    // pipeline for issuing dfi_wrdata_en
    always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin

       if (~core_ddrc_rstn) begin
          wrdata_en_pipe_upr <= 70'h0;
       end
       else begin
          wrdata_en_pipe_upr <= (wrdata_en_pipe_upr >> 1);
          if(issue_wrdata_en) begin
            casez (burst_rdwr_int)
                    4'b01?? :       // burst of 8 mode - 4 clocks of data on the phy_ddrc interface
                    begin
                            if (|mr_t_wrlat)
                                wrdata_en_pipe_upr[mr_t_wrlat_m1[6:0]]        <= 1'b1;
                                wrdata_en_pipe_upr[{1'b0,mr_t_wrlat}]         <= 1'b1;
                                wrdata_en_pipe_upr[mr_t_wrlat_p1[6:0]]        <= 1'b1;
                                wrdata_en_pipe_upr[mr_t_wrlat_p2[6:0]]        <= 1'b1;
                    end
                    default :       // burst of 4 mode - 2 clocks of data on the phy-ddrc interface
                    begin
                            if (|mr_t_wrlat)
                                wrdata_en_pipe_upr[mr_t_wrlat_m1[6:0]]        <= 1'b1;
                            wrdata_en_pipe_upr[{1'b0,mr_t_wrlat}]             <= 1'b1;
                    end
            endcase
          end
       end
    end

    assign pi_ph_dfi_wrdata_en[1] = ((mr_t_wrlat == {DFI_TPHY_WRLAT_WIDTH{1'b0}}) & issue_wrdata_en) | wrdata_en_pipe_upr[0];

// pipeline for issuing dfi_wrdata_en
always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin

   if (~core_ddrc_rstn) begin
      wrdata_en_pipe_third <= 70'h0;
   end
   else begin
      wrdata_en_pipe_third <= (wrdata_en_pipe_third >> 1);
      if(issue_wrdata_en) begin
        casez (burst_rdwr_int)
                4'b01?? :       // burst of 8 mode - 4 clocks of data on the phy_ddrc interface
                begin
                            // For now, this situation is for 1to2 mode.
                            // 1to2 mode does not use this phase signal.
                          //  if (mr_t_wrlat != 6'h00)
                          //      wrdata_en_pipe_third[mr_t_wrlat_m1]        <= 1'b1;
                          //  wrdata_en_pipe_third[mr_t_wrlat]               <= 1'b1;
                          //  `ifdef MEMC_DDR4
                          //  if (!burst_chop_wr) begin
                          //      wrdata_en_pipe_third[mr_t_wrlat+6'h1]      <= 1'b1;
                          //      wrdata_en_pipe_third[mr_t_wrlat+6'h2]      <= 1'b1;
                          //  end
                          //  `else
                          //      wrdata_en_pipe_third[mr_t_wrlat+6'h1]      <= 1'b1;
                          //      wrdata_en_pipe_third[mr_t_wrlat+6'h2]      <= 1'b1;
                          //  `endif
                end
                default :       // burst of 4 mode - 2 clocks of data on the phy-ddrc interface
                begin
                        if (|mr_t_wrlat)
                            wrdata_en_pipe_third[mr_t_wrlat_m1[6:0]]   <= 1'b1;
                        wrdata_en_pipe_third[{1'b0, mr_t_wrlat}]       <= 1'b1;
                end
        endcase
      end
   end
end

// output assignment
assign pi_ph_dfi_wrdata_en[2] = ((mr_t_wrlat == {DFI_TPHY_WRLAT_WIDTH{1'b0}}) & issue_wrdata_en) | wrdata_en_pipe_third[0];

    // pipeline for issuing dfi_wrdata_en
    always @ (posedge co_pi_clk or negedge core_ddrc_rstn) begin

       if (~core_ddrc_rstn) begin
          wrdata_en_pipe_fourth <= 70'h0;
       end
       else begin
          wrdata_en_pipe_fourth <= (wrdata_en_pipe_fourth >> 1);
          if(issue_wrdata_en) begin
            casez (burst_rdwr_int)
                    4'b01?? :       // burst of 8 mode - 4 clocks of data on the phy_ddrc interface
                    begin
                                // For now, this situation is for 1to2 mode.
                                // 1to2 mode does not use this phase signal.
                            //if (mr_t_wrlat != 6'h00)
                            //    wrdata_en_pipe_fourth[mr_t_wrlat_m1]        <= 1'b1;
                            //wrdata_en_pipe_fourth[mr_t_wrlat]               <= 1'b1;
                            //`ifdef MEMC_DDR4
                            //if (!burst_chop_wr) begin
                            //    wrdata_en_pipe_fourth[mr_t_wrlat+6'h1]      <= 1'b1;
                            //    wrdata_en_pipe_fourth[mr_t_wrlat+6'h2]      <= 1'b1;
                            //end
                            //`else
                            //    wrdata_en_pipe_fourth[mr_t_wrlat+6'h1]      <= 1'b1;
                            //    wrdata_en_pipe_fourth[mr_t_wrlat+6'h2]      <= 1'b1;
                            //`endif
                    end
                    default :       // burst of 4 mode - 2 clocks of data on the phy-ddrc interface
                    begin
                            if (|mr_t_wrlat)
                                wrdata_en_pipe_fourth[mr_t_wrlat_m1[6:0]]   <= 1'b1;
                            wrdata_en_pipe_fourth[{1'b0, mr_t_wrlat}]       <= 1'b1;
                    end
            endcase
          end
       end
    end

    assign pi_ph_dfi_wrdata_en[3] = ((mr_t_wrlat == {DFI_TPHY_WRLAT_WIDTH{1'b0}}) & issue_wrdata_en) | wrdata_en_pipe_fourth[0];






//------------------------------------------------------------------------------
// PI Assertions Module
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
pi_assertions

       #(
           .CMD_LEN_BITS (CMD_LEN_BITS)
          ,.T_CCD_WIDTH  (T_CCD_WIDTH)
       )
    pi_assertions (
        .co_pi_clk               (co_pi_clk),
        .core_ddrc_rstn          (core_ddrc_rstn),
        .pi_ph_stop_clk          (pi_ph_stop_clk),
        .dh_pi_lpddr4            (dh_pi_lpddr4),
        .lpddr4_row17_exist      (lpddr4_row17_exist),
        .active_ranks            ({NUM_RANKS{1'b1}}),
        .dh_pi_burst_rdwr        (dh_pi_burst_rdwr_core_clk),
        .dh_pi_per_bank_refresh  (per_bank_refresh_r),
        .pi_ph_cs                (pi_ph_cs),
        .pi_ph_cas_n             (pi_ph_cas_n),
        .pi_ph_ras_n             (pi_ph_ras_n),
        .pi_ph_we_n              (pi_ph_we_n),
        .pi_ph_bank              (act_bank_num),
        .pi_ph_addr              (pi_ph_addr),
        .pi_ph_cke               (pi_ph_cke),
        .ctrlupd_req             (r_ctrlupd_req),
        .phyupd_pause_req        (r_phyupd_pause_req),
        .upd_ok_lpddr4           (upd_ok_lpddr4),
        .pi_gs_ctrlupd_ok        (pi_gs_ctrlupd_ok),
        .pi_gs_phyupd_pause_ok   (pi_gs_phyupd_pause_ok),
        .col_addr                (pi_ph_addr_rwa[15:0]),
        .gs_op_is_act            (gs_op_is_act),
        .gs_op_is_pre            (gs_op_is_pre),
        .gs_op_is_load_mode      (gs_op_is_load_mode),
        .gs_op_is_rd             (gs_op_is_rd),
        .gs_op_is_wr             (gs_op_is_wr),
        .gs_op_is_enter_selfref  (gs_op_is_enter_selfref),
        .gs_op_is_exit_selfref   (gs_op_is_exit_selfref),
        .gs_op_is_enter_powerdown(gs_op_is_enter_powerdown),
        .gs_op_is_exit_powerdown (gs_op_is_exit_powerdown),
        .gs_op_is_ref            (gs_op_is_ref),
        .gs_pi_wr_mode           (gs_pi_wr_mode),
        .gs_pre_rankbank_num     (gs_pre_rankbank_num),
        .gs_rdwr_rankbank_num    (gs_rdwr_rankbank_num),
        .gs_act_rankbank_num     (gs_act_rankbank_num),
        .gs_pi_refpb_bank        (gs_pi_refpb_bank),
        .gs_op_is_enter_sr_lpddr (gs_op_is_enter_sr_lpddr),
        .gs_op_is_exit_sr_lpddr  (gs_op_is_exit_sr_lpddr),
        .gs_pi_mrr               (gs_pi_mrr),
        .gs_pi_mrr_ext           (gs_pi_mrr_ext),
        .gs_pi_mrs_a             (gs_pi_mrs_a),
        .gs_mpc_zq_start         (gs_mpc_zq_start),
        .gs_mpc_zq_latch         (gs_mpc_zq_latch),
        .gs_mpc_dqsosc_start     (gs_mpc_dqsosc_start),
        .ts_act_page             (ts_act_page),
        .te_pi_rd_blk            (te_pi_rd_blk),
        .te_pi_wr_blk            (te_pi_wr_blk),
        .te_pi_rd_word           (te_pi_rd_word),
        .te_autopre              (os_te_autopre),
        .ts_pi_mwr               (ts_pi_mwr),
        .reg_ddrc_lpddr5         (reg_ddrc_lpddr5),
        .ts_act2_invalid_tmg     (ts_act2_invalid_tmg),
        .pi_lp5_preref_ok        (pi_lp5_preref_ok),
        .t_aad_timer_r           (t_aad_timer_r),
        .pi_lp5_act2_cmd         (pi_lp5_act2_cmd),
        .act2_req_r              (act2_req_r),
        .act2_out_en             (act2_out_en),
        .te_pi_wr_word           (te_pi_wr_word),
        .dh_pi_frequency_ratio   (dh_pi_frequency_ratio)
        );
`endif // `ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule
