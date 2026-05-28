//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/top/dwc_ddrctl_ddrc_cp.sv#2 $
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
//                              DDR Controller
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
//                              Description
//
// This is the wrapper for CTRL related modules for the DDR Controller.
// This instantiates and connects all units related to CTRL of the DDR Controller.
// Excludes data related modules
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
`include "dfi/DWC_ddrctl_dfi_pkg.svh"
`include "top/dwc_ddrctl_ddrc_cpedfi_if.svh"
`include "top/dwc_ddrctl_ddrc_cpfcpe_if.svh"

module dwc_ddrctl_ddrc_cp
import DWC_ddrctl_reg_pkg::*;
import DWC_ddrctl_dfi_pkg::*;
  #(
//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
parameter       CHANNEL_NUM = 0,
parameter       SHARED_AC = 0,
parameter       SHARED_AC_INTERLEAVE = 0,
parameter       BCM_VERIF_EN = 1,
parameter       BCM_DDRC_N_SYNC = 2,
parameter       MEMC_ECC_SUPPORT = 0,
parameter       UMCTL2_SEQ_BURST_MODE = 0,                       // Applies LPDDR4 like squential burst mode only
parameter       UMCTL2_PHY_SPECIAL_IDLE = 0,                     // A specially encoded "IDLE" command over the DFI bus: {ACT_n,RAS_n,CAS_n,WE_n,BA0}
parameter       OCPAR_EN = 0,                                    // enables on-chip parity
parameter       NPORTS = 1,                                      // no. of ports (for cactive_in_ddrc width) gets overwritten by toplevel
parameter       NPORTS_LG2 = 1,                                      // log2 of no. of ports (for ih_dual) gets overwritten by toplevel
parameter       A_SYNC_TABLE = 16'hffff, // AXI sync table
parameter       RD_CAM_ADDR_WIDTH  = `MEMC_RDCMD_ENTRY_BITS,   // bits to address into read CAM
parameter       WR_CAM_ADDR_WIDTH  = `MEMC_WRCMD_ENTRY_BITS,   // bits to address into write CAM
parameter       WR_ECC_CAM_ADDR_WIDTH = 0,
parameter       WR_CAM_ADDR_WIDTH_IE = 0,
parameter       MAX_CAM_ADDR_WIDTH = 0,
parameter       RD_CAM_ENTRIES = 0,
parameter       WR_CAM_ENTRIES = 0,
parameter       WR_ECC_CAM_ENTRIES = 0,
parameter       WR_CAM_ENTRIES_IE =0,
parameter       CORE_DATA_WIDTH = `MEMC_DFI_DATA_WIDTH,        // internal data width
parameter       CORE_ADDR_WIDTH = `MEMC_HIF_ADDR_WIDTH_MAX,
// This is the actual width of the address bus used inside DDRC
parameter       CORE_ADDR_INT_WIDTH = (`UMCTL2_LRANK_BITS+`MEMC_BG_BANK_BITS+`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS),

parameter       CORE_TAG_WIDTH  = `MEMC_TAGBITS,                // width of tag

parameter       RETRY_FIFO_DEPTH  = `DDRCTL_RETRY_FIFO_DEPTH,
// widths used for some outputs of ddrc_ctrl that would be
// [X-1:0]=>[-1:0]
// wide otherwise as X=0
parameter       RANK_BITS_DUP   = `MEMC_RANK_BITS,
parameter       LRANK_BITS_DUP  = `UMCTL2_LRANK_BITS,
parameter       BG_BITS_DUP     = `MEMC_BG_BITS,
parameter       CID_WIDTH_DUP   = `UMCTL2_CID_WIDTH,
parameter       CORE_ECC_WIDTH_DUP          = (`MEMC_DFI_ECC_WIDTH==0)  ? 1 : `MEMC_DFI_ECC_WIDTH,
parameter       CORE_ECC_MASK_WIDTH_DUP     = (`MEMC_DFI_ECC_WIDTH==0)  ? 1 : `MEMC_DFI_ECC_WIDTH/8,

parameter       RANK_BITS       = `MEMC_RANK_BITS,
parameter       LRANK_BITS      = `UMCTL2_LRANK_BITS,
parameter       CID_WIDTH       = `UMCTL2_CID_WIDTH,
parameter       BG_BITS         = `MEMC_BG_BITS,
parameter       BG_BANK_BITS    = `MEMC_BG_BANK_BITS,
parameter       BANK_BITS       = `MEMC_BANK_BITS,
parameter       PAGE_BITS       = `MEMC_PAGE_BITS,
parameter       WORD_BITS       = `MEMC_WORD_BITS,              // address a word within a burst
parameter       BLK_BITS        = `MEMC_BLK_BITS,               // 2 column bits are critical word
parameter       BSM_BITS        = `UMCTL2_BSM_BITS,

parameter       MRS_A_BITS      = `MEMC_PAGE_BITS,
parameter       MRS_BA_BITS     = `MEMC_BG_BANK_BITS,

parameter       PHY_ADDR_BITS   = `MEMC_DFI_ADDR_WIDTH,

parameter       NUM_TOTAL_BANKS = `MEMC_NUM_TOTAL_BANKS,        // max supported banks
parameter       NUM_RANKS       = `MEMC_NUM_RANKS,              // max supported ranks (chip selects)
parameter       NUM_LRANKS      = `UMCTL2_NUM_LRANKS_TOTAL,     // max supported logical ranks (chip selects * chip ID(for DDR4 3DS))
parameter       NUM_TOTAL_BSMS  = `UMCTL2_NUM_BSM,              // max supported BSMs

parameter       NUM_PHY_DRAM_CLKS = `MEMC_NUM_CLKS,

parameter       PHY_DATA_WIDTH  = `MEMC_DFI_TOTAL_DATA_WIDTH,       // data width to PHY
parameter       PHY_MASK_WIDTH  = `MEMC_DFI_TOTAL_DATA_WIDTH/8,     // data mask width (internal to uMCTL2)


parameter MWR_BITS = 1, // currently 1-bit info (OR of all data beats)
parameter PARTIAL_WR_BITS = `UMCTL2_PARTIAL_WR_BITS,

parameter       NUM_LANES  = 4, //Number of lanes in PHY - default is 4
parameter       PARITY_IN_WIDTH  = 2,

parameter       RETRY_MAX_ADD_RD_LAT_LG2 = 1,
parameter       CMD_LEN_BITS     = 1,                            // command length bit width
parameter       FATL_CODE_BITS   = 3,

parameter       WRDATA_CYCLES    = 2,

// were localparams but need to parameters as signal widths depend on them
parameter      CMD_TYPE_BITS   = 2,                           // command type bit width
parameter      WDATA_PTR_BITS  = `MEMC_WDATA_PTR_BITS,
parameter      CMD_RMW_BITS    = 1,                            // unused, but '0' breaks things still...
parameter      RMW_TYPE_BITS   = 2,                            // 2-bit RMW type
                                                                //  (partial
                                                                //  write,
                                                                //  scrub,
                                                                //  atomic
                                                                //  RMW, none)


parameter PARTIAL_WR_BITS_LOG2 = `log2(PARTIAL_WR_BITS),
parameter PW_NUM_DB = PARTIAL_WR_BITS,

parameter PW_FACTOR_QBW = 4*`MEMC_FREQ_RATIO,
parameter PW_FACTOR_HBW = 2*`MEMC_FREQ_RATIO,
parameter PW_FACTOR_FBW = 1*`MEMC_FREQ_RATIO,

parameter PW_WORD_VALID_WD_QBW = PW_NUM_DB*PW_FACTOR_QBW,
parameter PW_WORD_VALID_WD_HBW = PW_NUM_DB*PW_FACTOR_HBW,
parameter PW_WORD_VALID_WD_FBW = PW_NUM_DB*PW_FACTOR_FBW,

parameter PW_WORD_VALID_WD_MAX = PW_WORD_VALID_WD_HBW,

parameter PW_WORD_CNT_WD_MAX = `log2(PW_WORD_VALID_WD_MAX),

parameter RANKBANK_BITS_FULL = LRANK_BITS + BG_BITS + BANK_BITS,


parameter NO_OF_BT          = `MEMC_NO_OF_BLK_TOKEN,
parameter NO_OF_BWT         = `MEMC_NO_OF_BWT,
parameter NO_OF_BRT         = `MEMC_NO_OF_BRT,
parameter BT_BITS           = `log2(NO_OF_BT),
parameter BWT_BITS          = `log2(NO_OF_BWT),
parameter BRT_BITS          = `log2(NO_OF_BRT),
parameter NO_OF_BLK_CHN     = `MEMC_NO_OF_BLK_CHANNEL,
parameter BLK_CHN_BITS      = `log2(NO_OF_BLK_CHN),
parameter IE_RD_TYPE_BITS   = `IE_RD_TYPE_BITS,
parameter IE_WR_TYPE_BITS   = `IE_WR_TYPE_BITS,
parameter IE_BURST_NUM_BITS = `MEMC_BURST_LENGTH==16 ? 4 : 3,
//unused code, tobe removed, keep it just for avoiding re-numbering in cmp and output number mismatch
parameter IE_PW_BITS        = `MEMC_BURST_LENGTH==16 ? 4 : 2,

parameter MAX_CMD_DELAY    = `UMCTL2_MAX_CMD_DELAY,
parameter CMD_DELAY_BITS   = `UMCTL2_CMD_DELAY_BITS,
parameter AM_DCH_WIDTH     = 6,
parameter AM_CS_WIDTH      = 6,
parameter AM_CID_WIDTH     = 6,
parameter AM_BANK_WIDTH    = 6,
parameter AM_BG_WIDTH      = 6,
parameter AM_ROW_WIDTH     = 5,
parameter AM_COL_WIDTH_H   = 5,
parameter AM_COL_WIDTH_L   = 4,
parameter MAX_CMD_NUM      = 2,
parameter OTHER_RD_ENTRY_BITS   = (CORE_TAG_WIDTH+((`MEMC_ADDR_ERR==1) ? 1: 0) + ((`MEMC_USE_RMW_EN==1) ? (WR_CAM_ADDR_WIDTH + RMW_TYPE_BITS) : 0)) ,
parameter PW_BC_SEL_BITS        = (`UMCTL2_PARTIAL_WR_EN==1) ? ((`MEMC_DDR4_EN==1) ? 3 : 0) : 0,
parameter DFI_T_CTRLMSG_RESP_WIDTH = 8,
parameter DFI_CTRLMSG_DATA_WIDTH   = 16,
parameter DFI_CTRLMSG_CMD_WIDTH    = 8

  )
  (
//------------------------------------------------------------------------------
// Input and Output Declarations
//------------------------------------------------------------------------------

input                           core_ddrc_core_clk,
input                           core_ddrc_rstn,


input   [NUM_RANKS-1:0]         bsm_clk,                // For power saving purpose, bsm instances speficic clock
input   [BSM_CLK_ON_WIDTH-1:0]  bsm_clk_on,             // 0: bsm_clk can be removed. 1: bsm_clk is not removed.
output  [NUM_RANKS-1:0]         bsm_clk_en,             // Clock enable for bsm instances


input                           hif_cmd_valid,          // valid command
input   [CMD_TYPE_BITS-1:0]     hif_cmd_type,           // command type:
                                                        //  00 - block write
                                                        //  01 - read
                                                        //  10 - partial write
                                                        //  01 - read-mod-write
input   [1:0]                   hif_cmd_pri,            // priority: // TEMP ONLY - make it 2-bits when ARB is connected
                                                        //  HIF config: 0 - LPR, 1 - HPR
                                                        //  Arbiter config: 00 - LPR, 01 - VPR, 10 - HPR, 11 - Unused
input   [CORE_ADDR_WIDTH-1:0]   hif_cmd_addr,           // address
input   [CMD_LEN_BITS-1:0]      hif_cmd_length,         // length (1 word or 2)
                                                        //  1 - 1 word length
                                                        //  2 - 2 word lengths
                                                        // (where 1 word equals the size of the data transfer
                                                        //  between the core and the controller)
input   [CORE_TAG_WIDTH-1:0]    hif_cmd_token,          // read token,
                                                        //  returned w/ read data
input   [WDATA_PTR_BITS-1:0]    hif_cmd_wdata_ptr,      // incoming wdata ptr



input                           hif_cmd_autopre,        // auto precharge enable


input                           hif_go2critical_lpr,
input                           hif_go2critical_hpr,
input                           hif_go2critical_wr,
input                           hif_go2critical_l1_wr,
input                           hif_go2critical_l2_wr,
input                           hif_go2critical_l1_lpr,
input                           hif_go2critical_l2_lpr,
input                           hif_go2critical_l1_hpr,
input                           hif_go2critical_l2_hpr,

output                          hif_cmd_stall,            // request stall
output                          hif_rcmd_stall,           // rcmd stall
output                          hif_wcmd_stall,           // wcmd stall

output                          hif_wdata_ptr_valid,
output  [WDATA_PTR_BITS-1:0]    hif_wdata_ptr,
output                          hif_wdata_ptr_addr_err,   // Indicates that the write was associated with an invalid address
output [`MEMC_HIF_CREDIT_BITS-1:0]  hif_lpr_credit,
output                              hif_wr_credit,
output [`MEMC_HIF_CREDIT_BITS-1:0]  hif_hpr_credit,
output [1:0]                        hif_wrecc_credit,


input                           reg_ddrc_mr_wr,            // input from core to write mode register
input                           reg_ddrc_sw_init_int,       // SW intervention in auto SDRAM initialization
input                           reg_ddrc_mr_type,          // MR Type R/W.
input   [3:0]                   reg_ddrc_mr_addr,          // input from core: mode register address
                                                            // 0000: MR0, 0001: MR1, 0010: MR2, 0011: MR3, 0100: MR4, 0101: MR5, 0110: MR6
input   [PAGE_BITS-1:0]          reg_ddrc_mr_data,          // mode register data to be written
output                          ddrc_reg_mr_wr_busy,       // indicates that mode register write operation is in progress
output                          ddrc_reg_pda_done,         // indicates that MRS operation related to PDA mode has done

input                           reg_ddrc_derate_mr4_tuf_dis,
input                           derate_sync_ack_c2p,
input   [ACTIVE_DERATE_BYTE_RANK_WIDTH-1:0] reg_ddrc_active_derate_byte_rank0,
input   [DBG_MR4_RANK_SEL_WIDTH-1:0]        reg_ddrc_dbg_mr4_rank_sel,
input   [DBG_MR4_GRP_SEL_WIDTH-1:0]         reg_ddrc_dbg_mr4_grp_sel,
input                                   reg_ddrc_lpddr4_refresh_mode,
input                           reg_ddrc_zq_reset,
input   [T_ZQ_RESET_NOP_WIDTH-1:0]                                           reg_ddrc_t_zq_reset_nop,
input   [DERATE_ENABLE_WIDTH-1:0]   reg_ddrc_derate_enable,
input   [DERATED_T_RCD_WIDTH-1:0]     reg_ddrc_derated_t_rcd,
input   [DERATED_T_RAS_MIN_WIDTH-1:0] reg_ddrc_derated_t_ras_min,
input   [DERATED_T_RP_WIDTH-1:0]      reg_ddrc_derated_t_rp,
input   [DERATED_T_RRD_WIDTH-1:0]     reg_ddrc_derated_t_rrd,
input   [DERATED_T_RC_WIDTH-1:0]      reg_ddrc_derated_t_rc,

input                           reg_ddrc_derate_mr4_pause_fc,
input   [MR4_READ_INTERVAL_WIDTH-1:0]                  reg_ddrc_mr4_read_interval,

output  [DBG_MR4_BYTE_WIDTH-1:0]            ddrc_reg_dbg_mr4_byte0,
output  [DBG_MR4_BYTE_WIDTH-1:0]            ddrc_reg_dbg_mr4_byte1,
output  [DBG_MR4_BYTE_WIDTH-1:0]            ddrc_reg_dbg_mr4_byte2,
output  [DBG_MR4_BYTE_WIDTH-1:0]            ddrc_reg_dbg_mr4_byte3,

output                                      core_derate_temp_limit_intr,
output  [REFRESH_RATE_RANK_WIDTH-1:0]       ddrc_reg_refresh_rate_rank0,
output  [REFRESH_RATE_RANK_WIDTH-1:0]       ddrc_reg_refresh_rate_rank1,
output  [REFRESH_RATE_RANK_WIDTH-1:0]       ddrc_reg_refresh_rate_rank2,
output  [REFRESH_RATE_RANK_WIDTH-1:0]       ddrc_reg_refresh_rate_rank3,
output                                      ddrc_reg_zq_reset_busy,

output                                               hif_cmd_q_not_empty,    // indicates that there are commands pending in the cams

input                                                cactive_in_ddrc_sync_or,
input        [NPORTS-1:0]                            cactive_in_ddrc_async,
input                                                csysreq_ddrc,
output                                               csysack_ddrc,
output                                               cactive_ddrc,

output [SELFREF_TYPE_WIDTH-1:0]                      stat_ddrc_reg_selfref_type,
output [3:0]                                         stat_ddrc_reg_retry_current_state,

output [2:0]                                         dbg_dfi_ie_cmd_type,
output                                               dbg_dfi_in_retry,

output [BSM_BITS:0]                                  ddrc_reg_num_alloc_bsm,
output [BSM_BITS:0]                                  ddrc_reg_max_num_alloc_bsm,
output [RD_CAM_ADDR_WIDTH+1:0]                       ddrc_reg_max_num_unalloc_entries,


output    perf_hif_rd_or_wr,
output    perf_hif_wr,
output    perf_hif_rd,
output    perf_hif_rmw,
output    perf_hif_hi_pri_rd,

output    perf_read_bypass,
output    perf_act_bypass,

output    perf_hpr_xact_when_critical, // hpr transaction when hpr q is critical
output    perf_lpr_xact_when_critical, // lpr transaction when lpr q is critical
output    perf_wr_xact_when_critical,  // wr transaction when wr q is critical

output    perf_op_is_activate,
output    perf_op_is_rd_or_wr,
output    perf_op_is_rd_activate,
output    perf_op_is_rd,
output    perf_op_is_wr,
output    perf_op_is_mwr,
output    perf_op_is_cas,
output    perf_op_is_cas_ws,
output    perf_op_is_cas_ws_off,
output    perf_op_is_cas_wck_sus,
output    perf_op_is_enter_dsm,
output    perf_op_is_rfm,
output    perf_op_is_precharge,
output    perf_precharge_for_rdwr,
output    perf_precharge_for_other,

output    perf_rdwr_transitions,

output    perf_write_combine,
output    perf_write_combine_noecc,
output    perf_write_combine_wrecc,
output    perf_war_hazard,
output    perf_raw_hazard,
output    perf_waw_hazard,
output    perf_ie_blk_hazard,

output    [NUM_RANKS-1:0] perf_op_is_enter_selfref,
output    [NUM_RANKS-1:0] perf_op_is_enter_powerdown,
output    [NUM_RANKS-1:0] perf_op_is_enter_mpsm,
output    [NUM_RANKS-1:0] perf_selfref_mode,

output    perf_op_is_refresh,
output    perf_op_is_crit_ref,
output    perf_op_is_spec_ref,
output    perf_op_is_load_mode,
output    perf_op_is_zqcl,
output    perf_op_is_zqcs,

output    [RANK_BITS_DUP-1:0]   perf_rank,
output    [`MEMC_BANK_BITS-1:0] perf_bank,
output    [BG_BITS_DUP-1:0]     perf_bg,
output    [CID_WIDTH_DUP-1:0]   perf_cid,
output    [RANK_BITS_DUP-1:0]   perf_bypass_rank,
output    [`MEMC_BANK_BITS-1:0] perf_bypass_bank,
output    [BG_BITS_DUP-1:0]     perf_bypass_bg,
output    [CID_WIDTH_DUP-1:0]   perf_bypass_cid,
output                          perf_bsm_alloc,
output                          perf_bsm_starvation,
output    [BSM_BITS:0]          perf_num_alloc_bsm,
output                          perf_visible_window_limit_reached_rd,
output                          perf_visible_window_limit_reached_wr,
output                          perf_op_is_dqsosc_mpc,
output                          perf_op_is_dqsosc_mrr,
output                          perf_op_is_tcr_mrr,
output                          perf_op_is_zqstart,
output                          perf_op_is_zqlatch,

output  [2:0]   ddrc_core_reg_dbg_operating_mode,
output  [4:0]   ddrc_core_reg_dbg_global_fsm_state,

output  [4:0]   ddrc_core_reg_dbg_init_curr_state,
output  [4:0]   ddrc_core_reg_dbg_init_next_state,

output  [1:0]   ddrc_core_reg_dbg_ctrlupd_state,

output  [1:0]  ddrc_core_reg_dbg_lpr_q_state,
output  [1:0]  ddrc_core_reg_dbg_hpr_q_state,
output  [1:0]  ddrc_core_reg_dbg_wr_q_state,


output  [RD_CAM_ADDR_WIDTH:0]  ddrc_core_reg_dbg_lpr_q_depth,
output  [RD_CAM_ADDR_WIDTH:0]  ddrc_core_reg_dbg_hpr_q_depth,
output  [WR_CAM_ADDR_WIDTH:0]  ddrc_core_reg_dbg_wr_q_depth,
output  [WR_CAM_ADDR_WIDTH:0]  ddrc_core_reg_dbg_wrecc_q_depth,

output         ddrc_core_reg_dbg_hif_cmd_stall,

output         ddrc_core_reg_dbg_hif_rcmd_stall,
output         ddrc_core_reg_dbg_hif_wcmd_stall,



output  [NUM_TOTAL_BANKS-1:0]               ddrc_core_reg_dbg_rd_valid_rank,     // each bit indicates a bank
output  [NUM_TOTAL_BANKS-1:0]               ddrc_core_reg_dbg_rd_page_hit_rank,  // each bit indicates a bank
output  [NUM_TOTAL_BANKS-1:0]               ddrc_core_reg_dbg_rd_pri_rank,       // each bit indicates a bank
output  [NUM_TOTAL_BANKS-1:0]               ddrc_core_reg_dbg_wr_valid_rank,     // each bit indicates a bank
output  [NUM_TOTAL_BANKS-1:0]               ddrc_core_reg_dbg_wr_page_hit_rank,  // each bit indicates a bank

output      [7:0]                           ddrc_core_reg_dbg_wr_cam_7_0_valid, // 1-bit per cam location
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_7_0_valid, // 1-bit per cam location
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_15_8_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_15_8_valid,
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_23_16_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_23_16_valid,
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_31_24_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_31_24_valid,
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_39_32_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_39_32_valid,
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_47_40_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_47_40_valid,
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_55_48_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_55_48_valid,
output      [7:0]                           ddrc_core_reg_dbg_wr_cam_63_56_valid,
output      [7:0]                           ddrc_core_reg_dbg_rd_cam_63_56_valid,



output  [`MEMC_FREQ_RATIO*BG_BITS_DUP-1:0]      dfi_bg,
output  [`MEMC_FREQ_RATIO-1:0]                  dfi_act_n,
output  [(`MEMC_FREQ_RATIO*CID_WIDTH_DUP)-1:0]  dfi_cid,
output  dfi_address_s                           dfi_address,
output  [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0]      dfi_bank,
output  [1:0]                                   dfi_freq_ratio,
output  [`MEMC_FREQ_RATIO-1:0]                  dfi_cas_n,
output  [`MEMC_FREQ_RATIO-1:0]                  dfi_ras_n,
output  [`MEMC_FREQ_RATIO-1:0]                  dfi_we_n,
output  [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]      dfi_cke,
output  [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]      dfi_cs,
output  [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]      dfi_odt,
output  [`UMCTL2_RESET_WIDTH-1:0]               dfi_reset_n,
output  [`MEMC_HIF_ADDR_WIDTH-1:0]              dfi_hif_cmd_addr,

output [`DDRCTL_DFI_HIF_CMD_WDATA_PTR_RANGE-1:0] dfi_hif_cmd_wdata_ptr,

input  [DFI_TPHY_WRLAT_WIDTH-1:0]           reg_ddrc_dfi_tphy_wrlat,
input  [DFI_T_RDDATA_EN_WIDTH-1:0]          reg_ddrc_dfi_t_rddata_en,
input  [DFI_TPHY_WRCSLAT_WIDTH-1:0]         reg_ddrc_dfi_tphy_wrcslat,
input  [6:0]                    reg_ddrc_dfi_tphy_rdcslat,
input                           reg_ddrc_dfi_data_cs_polarity,
output [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0] dfi_wrdata_cs,
output [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0] dfi_rddata_cs,

input                           dfi_ctrlupd_ack,        // this ack is from PHY
output                          dfi_ctrlupd_req,
output [1:0]                    dfi_ctrlupd_type,
output [1:0]                    dfi_ctrlupd_target,

output  [NUM_PHY_DRAM_CLKS-1:0] dfi_dram_clk_disable,

output  [`MEMC_FREQ_RATIO*PARITY_IN_WIDTH-1:0]     dfi_parity_in,

output [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]   dfi_wck_cs,
output [`MEMC_FREQ_RATIO-1:0]             dfi_wck_en,
output [2*`MEMC_FREQ_RATIO-1:0]           dfi_wck_toggle,


input                           reg_ddrc_dfi_init_start,
input  [DFI_FREQ_FSP_WIDTH-1:0] reg_ddrc_dfi_freq_fsp,
input   [4:0]                   reg_ddrc_dfi_frequency,
output                          dfi_init_start,
output  [1:0]                   dfi_freq_fsp,
output  [4:0]                   dfi_frequency,
input                           dfi_init_complete,
output                          dfi_2n_mode,
input                           dfi_reset_n_in,
input                           init_mr_done_in,
output                          dfi_reset_n_ref,
output                          init_mr_done_out,



output                                              ddrc_reg_ppr_done,

output  [RETRY_FIFO_FILL_LEVEL_WIDTH-1:0]  ddrc_reg_retry_fifo_fill_level,
output                                     ddrc_reg_wr_crc_err_max_reached_intr,
output  [RETRY_STAT_WIDTH-1:0]             ddrc_reg_retry_stat,
output                                     ddrc_reg_wr_crc_retry_limit_intr,       
output                                     ddrc_reg_rd_retry_limit_intr,       
output                                     ddrc_reg_rd_crc_retry_limit_reached,       
output                                     ddrc_reg_rd_ue_retry_limit_reached,       
output                                     dbg_wr_crc_retry_pulse,
output                                     dbg_rd_crc_retry_pulse,
output                                     dbg_rd_ue_retry_pulse,
output  [LRANK_BITS_DUP-1:0]               dbg_rd_retry_rank, 
output  [WR_CRC_ERR_CNT_WIDTH-1:0]         ddrc_reg_wr_crc_err_cnt,
output                                     ddrc_reg_wr_crc_err_intr,
output                                     ddrc_reg_capar_retry_limit_intr,
output                                     ddrc_reg_capar_fatl_err_intr,
output  [CAPAR_FATL_ERR_CODE_WIDTH-1:0]    ddrc_reg_capar_fatl_err_code,
output                                     ddrc_reg_capar_err_max_reached_intr,
output                                     ddrc_reg_capar_err_intr,
output [CAPAR_ERR_CNT_WIDTH-1:0]           ddrc_reg_capar_err_cnt,

output                                     retryram_din,
output                                     retryram_waddr,
output                                     retryram_raddr,
output                                     retryram_re,
output                                     retryram_we,
output                                     retryram_mask,


input                           reg_ddrc_dfi_init_complete_en,
input                           reg_ddrc_frequency_ratio,      // Frequency ratio, 1 - 1:1 mode, 0 - 1:2 mode

input                           reg_ddrc_en_dfi_dram_clk_disable,       // 1=allow controller+PHY to stop the clock to DRAM

//---- register inputs ----
input   [3:0]                   reg_ddrc_burst_rdwr,            // 4'h0010=burst of 4 data read/write
                                                                // 4'h0100=burst of 8 data read/write
                                                                // 4'h1000=burst of 16 data read/write

input                           reg_ddrc_dis_dq,                // 1=disable dequeue (stall scheduler), 0=normal operation
input                           reg_ddrc_dis_hif,               // 1=disable to accept rd/wr on hif (stall hif), 0=normal operation
input                           reg_ddrc_dis_wc,                // 1=disable write combine, 0=allow write combine


input   [NUM_LRANKS-1:0]        reg_ddrc_rank_refresh,          // cmd issuing refresh to rank
output  [NUM_LRANKS-1:0]        ddrc_reg_rank_refresh_busy,     // If 1: Previous dh_gs_rank_refresh has not been stored
output  [NUM_LRANKS-1:0]        ext_rank_refresh_busy,          // If 1: Previous dh_gs_rank_refresh has not been stored
input                           reg_ddrc_dis_auto_refresh,      // 1= disable auto_refresh issued by
                                                                // the controller. Issue refresh based only
                                                                // on the rankX_refresh command from reg_ddrc_rankX_refresh, where X = 0, 1, 2, 3
input                           reg_ddrc_ctrlupd,               // ctrlupd command
output                          ddrc_reg_ctrlupd_busy,          // If 1: Previous ctrlupd from APB register reg_ddrc_ctrlupd has not been initiated
input                           reg_ddrc_dis_auto_ctrlupd,      // 1 = disable ctrlupd issued by the controller
                                                                // ctrlupd command will be issued by APB register reg_ddrc_ctrlupd
                                                                // 0 = enable ctrlupd issued by the controller
input                           reg_ddrc_dis_auto_ctrlupd_srx,  // 1 = disable ctrlupd issued by the controller following a self-refresh exit
                                                                // ctrlupd command will be issued by APB register reg_ddrc_ctrlupd
                                                                // 0 = enable ctrlupd issued by the controller following a self-refresh exit
input                           reg_ddrc_ctrlupd_pre_srx,       // 1 = ctrlupd sent before SRX
                                                                // 0 = ctrlupd sent after SRX

input                           reg_ddrc_dis_speculative_act,
input                           reg_ddrc_prefer_read,
input   [RD_CAM_ADDR_WIDTH-1:0] reg_ddrc_lpr_num_entries,       // number of entries in low priority read queue
input                           reg_ddrc_lpr_num_entries_changed, // lpr_num_entries register has been changed
input   [15:0]                  reg_ddrc_mr,                    // mode register (MR) value written in init
input   [15:0]                  reg_ddrc_emr,                   // extended mode register (EMR) value written in init
input   [15:0]                  reg_ddrc_emr2,                  // extended mode register 2 (EMR2) value written in init
input   [15:0]                  reg_ddrc_emr3,                  // extended mode register 3 (EMR3) value written in init
input   [15:0]                  reg_ddrc_mr4,                   // mode register (MR4) value written in init
input   [15:0]                  reg_ddrc_mr5,                   // mode register (MR5) value written in init
input   [15:0]                  reg_ddrc_mr6,                   // mode register (MR6) value written in init
input   [15:0]                  reg_ddrc_mr22,                  // mode register (MR22) value written in init
input   [T_RCD_WIDTH-1:0]       reg_ddrc_t_rcd,                 // tRCD: RAS-to-CAS delay
input   [T_RAS_MIN_WIDTH-1:0]   reg_ddrc_t_ras_min,             // tRAS(min): minimum page open time
input   [T_RAS_MAX_WIDTH-1:0]   reg_ddrc_t_ras_max,             // tRAS(max): maximum page open time
input   [T_RC_WIDTH-1:0]        reg_ddrc_t_rc,                  // tRC: row cycle time
input   [T_RP_WIDTH-1:0]        reg_ddrc_t_rp,                  // tRP: row precharge time
input   [T_RRD_WIDTH-1:0]       reg_ddrc_t_rrd,                 // tRRD: RAS-to-RAS min delay
input   [T_RRD_S_WIDTH-1:0]     reg_ddrc_t_rrd_s,               // tRRD_S: RAS-to-RAS min delay (short)
input   [RD2WR_WIDTH-1:0]       reg_ddrc_rd2wr_s,
input   [MRR2RD_WIDTH-1:0]      reg_ddrc_mrr2rd,
input   [MRR2WR_WIDTH-1:0]      reg_ddrc_mrr2wr,
input   [MRR2MRW_WIDTH-1:0]     reg_ddrc_mrr2mrw,
input   [RD2PRE_WIDTH-1:0]      reg_ddrc_rd2pre,                // min read-to-precharge command delay
input   [WR2PRE_WIDTH-1:0]      reg_ddrc_wr2pre,                // min write-to-precharge command delay
input   [RDA2PRE_WIDTH-1:0]     reg_ddrc_rda2pre,               // min read-to-precharge command delay
input   [WRA2PRE_WIDTH-1:0]     reg_ddrc_wra2pre,               // min write-to-precharge command delay
input                           reg_ddrc_pageclose,             // close open pages by default
input   [7:0]                   reg_ddrc_pageclose_timer,       // timer for close open pages by default
input   [2:0]                   reg_ddrc_page_hit_limit_rd,     // page-hit limiter for rd
input   [2:0]                   reg_ddrc_page_hit_limit_wr,     // page-hit limiter for wr
input                           reg_ddrc_opt_hit_gt_hpr,        // 0 - page-miss HPR > page-hit LPR; 1 - page-hit LPR > page-miss HPR
input                                     reg_ddrc_autopre_rmw,
input   [REFRESH_MARGIN_WIDTH-1:0]        reg_ddrc_refresh_margin,        // how early to start trying to refresh or
                                                                          //  close a page for tRAS(max)
input   [PRE_CKE_X1024_WIDTH-1:0]         reg_ddrc_pre_cke_x1024,         // wait time at start of init sequence
                                                                          //  (in pulses of 1024-cycle timer)
input   [POST_CKE_X1024_WIDTH-1:0]        reg_ddrc_post_cke_x1024,        // wait time after asserting CKE in init sequence
                                                                          //  (in pulses of 1024-cycle timer)
input   [RD2WR_WIDTH-1:0]                 reg_ddrc_rd2wr,                 // min read-to-write command delay
input   [WR2RD_WIDTH-1:0]                 reg_ddrc_wr2rd,                 // min write-to-read command delay
input   [WR2RD_S_WIDTH-1:0]               reg_ddrc_wr2rd_s,               // min write-to-read command delay (short)
input   [5:0]                             reg_ddrc_refresh_burst,         // this + 1 = # of refreshes to burst
input   [T_CCD_WIDTH-1:0]                 reg_ddrc_t_ccd,                 // tCCD: CAS-to-CAS min delay
input   [T_CCD_S_WIDTH-1:0]               reg_ddrc_t_ccd_s,               // tCCD_S: CAS-to-CAS min delay (short)
input   [ODTLOFF_WIDTH-1:0]               reg_ddrc_odtloff,               // ODTLoff: This is latency from CAS-2 command to tODToff reference.
input   [T_CCD_MW_WIDTH-1:0]              reg_ddrc_t_ccd_mw,              // tCCDMW: CAS-to-CAS min delay masked write
input   [RD2MR_WIDTH-1:0]                 reg_ddrc_rd2mr,
input   [WR2MR_WIDTH-1:0]                 reg_ddrc_wr2mr,
input                                     reg_ddrc_dis_trefi_x6x8,
input                                     reg_ddrc_dis_trefi_x0125,
input   [T_PPD_WIDTH-1:0]                 reg_ddrc_t_ppd,                 // tPPD: PRE(A)-to-PRE(A) min delay
input                                     reg_ddrc_wck_on,
input   [MAX_RD_SYNC_WIDTH-1:0]           reg_ddrc_max_rd_sync,
input   [MAX_WR_SYNC_WIDTH-1:0]           reg_ddrc_max_wr_sync,
input   [DFI_TWCK_DELAY_WIDTH-1:0]        reg_ddrc_dfi_twck_delay,
input   [DFI_TWCK_EN_RD_WIDTH-1:0]       reg_ddrc_dfi_twck_en_rd,
input   [DFI_TWCK_EN_WR_WIDTH-1:0]       reg_ddrc_dfi_twck_en_wr,
input   [DFI_TWCK_DIS_WIDTH-1:0]         reg_ddrc_dfi_twck_dis,
input   [DFI_TWCK_FAST_TOGGLE_WIDTH-1:0] reg_ddrc_dfi_twck_fast_toggle,
input   [DFI_TWCK_TOGGLE_WIDTH-1:0]      reg_ddrc_dfi_twck_toggle,
input   [DFI_TWCK_TOGGLE_CS_WIDTH-1:0]   reg_ddrc_dfi_twck_toggle_cs,
input   [DFI_TWCK_TOGGLE_POST_WIDTH-1:0] reg_ddrc_dfi_twck_toggle_post,
input   [T_CKE_WIDTH-1:0]            reg_ddrc_t_cke,                 // tCKE: min CKE transition times
input   [T_FAW_WIDTH-1:0]            reg_ddrc_t_faw,                 // tFAW: rolling window of 4 activates allowed
                                                                //       to a given rank
input   [T_RFC_MIN_WIDTH-1:0]        reg_ddrc_t_rfc_min,             // tRC(min): min time between refreshes
input   [T_RFC_MIN_AB_WIDTH-1:0]     reg_ddrc_t_rfc_min_ab,
input   [T_PBR2PBR_WIDTH-1:0]        reg_ddrc_t_pbr2pbr,             // tpbR2pbR: min time between LPDDR4 per-bank refreshes different bank
input   [T_PBR2ACT_WIDTH-1:0]        reg_ddrc_t_pbr2act,             // tpbR2act: min time between LPDDR5 per-bank refreshes to act different bank
input                                reg_ddrc_t_refi_x1_sel,      // specifies whether reg_ddrc_t_refi_x1_x32 reg is x1 or x32
input   [T_REFI_X1_X32_WIDTH-1:0]        reg_ddrc_t_refi_x1_x32,      // tRFC(nom): nominal avg. required refresh period
input   [T_MR_WIDTH-1:0]             reg_ddrc_t_mr,                  // tMRD: recorvery time for mode register update
input   [REFRESH_TO_X1_X32_WIDTH-1:0]reg_ddrc_refresh_to_x1_x32,     // idle period before doing speculative refresh
input                           reg_ddrc_en_2t_timing_mode,     // Enable 2T timing mode in the controller
input                           reg_ddrc_opt_wrcam_fill_level,
input [3:0]                     reg_ddrc_delay_switch_write,
input [WR_CAM_ADDR_WIDTH-1:0]   reg_ddrc_wr_pghit_num_thresh,
input [RD_CAM_ADDR_WIDTH-1:0]   reg_ddrc_rd_pghit_num_thresh,
input [WR_CAM_ADDR_WIDTH-1:0]   reg_ddrc_wrcam_highthresh,
input [WR_CAM_ADDR_WIDTH-1:0]   reg_ddrc_wrcam_lowthresh,
input [7:0]                     reg_ddrc_wr_page_exp_cycles,
input [7:0]                     reg_ddrc_rd_page_exp_cycles,
input [7:0]                     reg_ddrc_wr_act_idle_gap,
input [7:0]                     reg_ddrc_rd_act_idle_gap,
input                           reg_ddrc_dis_opt_ntt_by_act,
input                           reg_ddrc_dis_opt_ntt_by_pre,
input                           reg_ddrc_prefer_write,          // prefer writes (debug feature)
input   [6:0]                   reg_ddrc_rdwr_idle_gap,         // idle period before switching from reads to writes
input   [POWERDOWN_EN_WIDTH-1:0]     reg_ddrc_powerdown_en,          // enable powerdown during idle periods
input   [POWERDOWN_TO_X32_WIDTH-1:0] reg_ddrc_powerdown_to_x32,      // powerdown timeout: idle period before entering
                                                                     //  powerdown (if reg_ddrc_powerdown_en=1)
                                                                     //  (in pulses of 32-cycle timer)
input   [T_XP_WIDTH-1:0] reg_ddrc_t_xp,                  // tXP: powerdown exit time

input [SELFREF_SW_WIDTH-1:0]    reg_ddrc_selfref_sw,
input                           reg_ddrc_hw_lp_en,
input                           reg_ddrc_hw_lp_exit_idle_en,
input   [SELFREF_TO_X32_WIDTH-1:0]                   reg_ddrc_selfref_to_x32,
input   [HW_LP_IDLE_X32_WIDTH-1:0]                  reg_ddrc_hw_lp_idle_x32,

input   [DFI_T_CTRLUPD_INTERVAL_MIN_X1024_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrlupd_interval_min_x1024,
input   [DFI_T_CTRLUPD_INTERVAL_MAX_X1024_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrlupd_interval_max_x1024,

input [SELFREF_EN_WIDTH-1:0]    reg_ddrc_selfref_en,            // self refresh enable


input   [NUM_RANKS-1:0]         reg_ddrc_mr_rank,               //   register i/p for software configuarble rank selection
input   [T_XSR_WIDTH-1:0] reg_ddrc_t_xsr,                 // SRX to commands (unit of 1 cycle)


input                           reg_ddrc_refresh_update_level,  // toggle this signal if refresh value has to be updated
                                                                // used when freq is changed on the fly



input   [NUM_RANKS-1:0]         reg_ddrc_rank0_wr_odt,  // ODT settings for 4 ranks + controller when writing to rank 0
input   [NUM_RANKS-1:0]         reg_ddrc_rank0_rd_odt,  // ODT settings for 4 ranks + controller when reading from rank 0
input   [7:0]                   reg_ddrc_hpr_xact_run_length,
input   [15:0]                  reg_ddrc_hpr_max_starve,
input   [7:0]                   reg_ddrc_lpr_xact_run_length,
input   [15:0]                  reg_ddrc_lpr_max_starve,
input   [7:0]                   reg_ddrc_w_xact_run_length,
input   [15:0]                  reg_ddrc_w_max_starve,

input   [DFI_T_CTRLUP_MIN_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrlup_min, // min time for which the ctrlup request should stay high
input   [DFI_T_CTRLUP_MAX_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrlup_max, // max time for which the ctrlup request can stay high

input   [READ_LATENCY_WIDTH-1:0] reg_ddrc_read_latency,  // read latency as seen by controller
input   [WRITE_LATENCY_WIDTH-1:0]rl_plus_cmd_len,

                                                        // data is passed on the ECC bits

output                          ddrc_reg_capar_poison_complete,
output                          dbg_dfi_parity_poison,

// for address mapper
input   [AM_BANK_WIDTH-1:0]     reg_ddrc_addrmap_bank_b0,
input   [AM_BANK_WIDTH-1:0]     reg_ddrc_addrmap_bank_b1,
input   [AM_BANK_WIDTH-1:0]     reg_ddrc_addrmap_bank_b2,
input   [AM_BG_WIDTH-1:0]       reg_ddrc_addrmap_bg_b0,
input   [AM_BG_WIDTH-1:0]       reg_ddrc_addrmap_bg_b1,
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b3,
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b4,
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b5,
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b6,
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b7,
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b8,
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b9,
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b10,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b0,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b1,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b2,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b3,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b4,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b5,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b6,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b7,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b8,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b9,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b10,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b11,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b12,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b13,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b14,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b15,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b16,
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b17,


output [ADDRMAP_LUT_RDATA1_WIDTH-1  :0]                  ddrc_reg_addrmap_lut_rdata1,
output [ADDRMAP_LUT_RDATA0_WIDTH-1  :0]                  ddrc_reg_addrmap_lut_rdata0,
output [ADDRMAP_RANK_VALID_WIDTH-1  :0]                  ddrc_reg_addrmap_rank_valid,

// outputs to status & interrupt registers
// outputs to debug registers
output  [RD_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_hpr_q_depth,
output  [RD_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_lpr_q_depth,
output  [WR_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_w_q_depth,
output  [WR_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_wrecc_q_depth,
output                          ddrc_reg_dbg_stall,             // stall
output                          ddrc_reg_dbg_stall_rd,             // stall
output                          ddrc_reg_dbg_stall_wr,             // stall
output                          ddrc_reg_selfref_cam_not_empty,
output [2:0]                    ddrc_reg_selfref_state,
output [2:0]                    ddrc_reg_operating_mode,        // global schedule FSM state

output                             ddrc_reg_dfi_lp_state,
output [MPSM_STATE_WIDTH-1:0]      ddrc_reg_mpsm_state,
output [POWERDOWN_STATE_WIDTH-1:0] ddrc_reg_powerdown_state,
output [SELFREF_TYPE_WIDTH-1:0]    ddrc_reg_selfref_type,

output                          ddrc_reg_wr_q_empty,
output                          ddrc_reg_rd_q_empty,
output                          ddrc_reg_wr_data_pipeline_empty,
output                          ddrc_reg_rd_data_pipeline_empty,

input                           reg_ddrc_dis_auto_zq,           // when 1: disable auto zqcs
input                           reg_ddrc_dis_srx_zqcl,          // when 1: disable zqcl after self-refresh exit
input                           reg_ddrc_zq_resistor_shared,
input [T_ZQ_LONG_NOP_WIDTH-1:0]                    reg_ddrc_t_zq_long_nop,         // time to wait in ZQCL during init sequence
input [T_ZQ_SHORT_NOP_WIDTH-1:0]                     reg_ddrc_t_zq_short_nop,        // time to wait in ZQCS during init sequence
input [T_ZQ_SHORT_INTERVAL_X1024_WIDTH-1:0]                    reg_ddrc_t_zq_short_interval_x1024,  // interval between auto ZQCS commands
input                           reg_ddrc_zq_calib_short,            // zq calib short command
output                          ddrc_reg_zq_calib_short_busy,       // If 1: Previous zq calib short has not been initiated


input [DRAM_RSTN_X1024_WIDTH-1:0] reg_ddrc_dram_rstn_x1024,       // time for dram reset to stay low

//input  [T_MR_WIDTH-1:0] reg_ddrc_t_mr,
input                   reg_ddrc_per_bank_refresh,      // REF Per bank//Added by Naveen B
input [1:0]             reg_ddrc_auto_refab_en,
input [REFRESH_TO_AB_X32_WIDTH-1:0] reg_ddrc_refresh_to_ab_x32,
input                   reg_ddrc_lpddr4,
input                   reg_ddrc_lpddr5,
input [BANK_ORG_WIDTH-1:0]             reg_ddrc_bank_org,
input [LPDDR4_DIFF_BANK_RWA2PRE_WIDTH-1:0] reg_ddrc_lpddr4_diff_bank_rwa2pre,
input                   reg_ddrc_stay_in_selfref,
input [T_CMDCKE_WIDTH-1:0] reg_ddrc_t_cmdcke,
input                         reg_ddrc_dsm_en,
input  [T_PDN_WIDTH-1:0]      reg_ddrc_t_pdn,
input  [T_XSR_DSM_X1024_WIDTH-1:0]  reg_ddrc_t_xsr_dsm_x1024,
input  [T_CSH_WIDTH-1:0]      reg_ddrc_t_csh,
output [BANK_BITS*NUM_RANKS-1:0]  hif_refresh_req_bank,

output [NUM_RANKS-1:0]    hif_refresh_req,
output [6*NUM_RANKS-1:0]  hif_refresh_req_cnt,
output [2:0]              hif_refresh_req_derate,
output [NUM_RANKS-1:0]    hif_refresh_active,


//
input [2:0]             reg_ddrc_nonbinary_device_density,

input                   dfi_phyupd_req,     // DFI PHY update request
output                  dfi_phyupd_ack,     // DFI PHY update acknowledge

input                         dfi_phymstr_req,        // DFI PHY Master request
input [`MEMC_NUM_RANKS-1:0]   dfi_phymstr_cs_state,   // DFI PHY Master CS state
input                         dfi_phymstr_state_sel,  // DFI PHY Master state select
input [1:0]                   dfi_phymstr_type,       // DFI PHY Master time type
output                        dfi_phymstr_ack,        // DFI PHY Master acknowledge

input                   reg_ddrc_dfi_phyupd_en,         // Enable for DFI PHY update logic
input                   reg_ddrc_dfi_phymstr_en,        // Enable for PHY Master Interface
input  [7:0]            reg_ddrc_dfi_phymstr_blk_ref_x32,// Number of 32 DFI cycles that is delayed to block refresh when there is PHY Master
input                   reg_ddrc_dis_cam_drain_selfref, // Disable CAM draining before entering selfref
input                   reg_ddrc_lpddr4_sr_allowed,     // Allow transition from SR-PD to SR and back to SR-PD when PHY Master request
input                   reg_ddrc_lpddr4_opt_act_timing,
input                   reg_ddrc_lpddr5_opt_act_timing,
input  [DFI_T_CTRL_DELAY_WIDTH-1:0]            reg_ddrc_dfi_t_ctrl_delay,  // timer value for DFI tctrl_delay
input  [DFI_T_WRDATA_DELAY_WIDTH-1:0]            reg_ddrc_dfi_t_wrdata_delay,// timer value for DFI twrdata_delay

input  [DFI_T_DRAM_CLK_DISABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_disable,
input  [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_enable,
input  [T_CKSRE_WIDTH-1:0] reg_ddrc_t_cksre,
input  [T_CKSRX_WIDTH-1:0] reg_ddrc_t_cksrx,
input  [T_CKCSX_WIDTH-1:0] reg_ddrc_t_ckcsx,
input  [T_CKESR_WIDTH-1:0] reg_ddrc_t_ckesr,

output                                          dfi_lp_ctrl_req,
output [DFI_LP_WAKEUP_PD_WIDTH-1:0]             dfi_lp_ctrl_wakeup,
input                                           dfi_lp_ctrl_ack,
output                                          dfi_lp_data_req,
output [DFI_LP_WAKEUP_PD_WIDTH-1:0]             dfi_lp_data_wakeup,
input                                           dfi_lp_data_ack,

input                                  reg_ddrc_dfi_lp_data_req_en,
input                                  reg_ddrc_dfi_lp_en_pd,
input  [DFI_LP_WAKEUP_PD_WIDTH-1:0]    reg_ddrc_dfi_lp_wakeup_pd,
input                                  reg_ddrc_dfi_lp_en_sr,
input  [DFI_LP_WAKEUP_SR_WIDTH-1:0]    reg_ddrc_dfi_lp_wakeup_sr,
input                                  reg_ddrc_dfi_lp_en_data,
input  [DFI_LP_WAKEUP_DATA_WIDTH-1:0]  reg_ddrc_dfi_lp_wakeup_data,
input                                  reg_ddrc_dfi_lp_en_dsm,
input  [DFI_LP_WAKEUP_DSM_WIDTH-1:0]   reg_ddrc_dfi_lp_wakeup_dsm,


input  [1:0]            reg_ddrc_skip_dram_init,
input  [DFI_TLP_RESP_WIDTH-1:0]            reg_ddrc_dfi_tlp_resp,


output                  hwffc_target_freq_en,
output  [TARGET_FREQUENCY_WIDTH-1:0]    hwffc_target_freq,
output  [TARGET_FREQUENCY_WIDTH-1:0]    hwffc_target_freq_init,

output                  ddrc_reg_hwffc_in_progress,
output [TARGET_FREQUENCY_WIDTH-1:0]     ddrc_reg_current_frequency,
output                  ddrc_reg_current_fsp,
output                  ddrc_reg_current_vrcg,
output                  ddrc_reg_hwffc_operating_mode,
output                  ddrc_xpi_port_disable_req,
output                  ddrc_xpi_clock_required,
// to WU
output                  hwffc_hif_wd_stall,
output                  hwffc_i_reg_ddrc_dis_auto_zq,



// new i/os not in ddrc.v i/o list
// connects ddrc_ctrl.v sub-blocks to rest of ddrc.v e.g. mr/rd/rt etc

// ih_mr_ie_pw is removed from IH and MR,
output [IE_PW_BITS-1:0]            ih_mr_ie_pw,
output                             ih_mr_ie_blk_wr_end,
output [BRT_BITS-1:0]              ih_rd_ie_brt,
output                             ih_rd_ie_rd_cnt_inc,
output                             ih_rd_ie_blk_rd_end,
output [NO_OF_BWT-1:0]             ih_mr_ie_wr_cnt_dec_vct,
output                             ih_mr_ie_wr_cnt_inc,
output [BWT_BITS-1:0]              ih_mr_ie_bwt,
output [BRT_BITS-1:0]              ih_mr_ie_brt,
output                             ih_mr_ie_brt_vld,

// TE to MR
output [BT_BITS-1:0]               te_mr_ie_bt,
output [IE_WR_TYPE_BITS-1:0]       te_mr_ie_wr_type,
output [IE_BURST_NUM_BITS-1:0]     te_mr_ie_blk_burst_num,  //only for the Data command

// PI to RT
output  [BT_BITS-1:0]              pi_rt_ie_bt,
output  [IE_RD_TYPE_BITS-1:0]      pi_rt_ie_rd_type,
output  [IE_BURST_NUM_BITS-1:0]    pi_rt_ie_blk_burst_num,  //only for the Data command


//signals for look up BT table
output [BWT_BITS-1:0]              ih_mr_lkp_bwt,
output                             ih_mr_lkp_bwt_vld,
output [BRT_BITS-1:0]              ih_mr_lkp_brt,
output                             ih_mr_lkp_brt_vld,
output [BRT_BITS-1:0]              ih_rd_lkp_brt,
output                             ih_rd_lkp_brt_vld,
output [BWT_BITS-1:0]              ih_rd_lkp_bwt,
output                             ih_rd_lkp_bwt_vld,
output                             ih_ie_busy,


output                             te_mr_eccap,
output                             pi_rt_eccap,

output  [`MEMC_DCERRFIELD]         ih_wu_cerr,

input [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]    hif_mrr_data,

input                    rd_mr4_data_valid,
input                    rt_rd_rd_mrr_ext,
output                   pi_rt_rd_mrr,
output                   pi_rt_rd_mrr_ext,

output logic                                    sw_wr_data_valid,
output logic [CORE_DATA_WIDTH-1:0]              sw_wr_data,
output logic [CORE_DATA_WIDTH/8-1:0]            sw_wr_data_mask,
output logic                                    ci_manual_wr_mode, // used for open ddrc_cg_en
output logic                                    ci_manual_rd_mode, // used for open ddrc_cg_en
output logic [CORE_ECC_WIDTH_DUP-1:0]           sw_wr_ecc,
output logic [CORE_ECC_MASK_WIDTH_DUP-1:0]      sw_wr_ecc_mask,
output logic [RD_DATA_DQ0_WIDTH-1:0]            ddrc_reg_rd_data_dq0,
output logic [RD_DATA_DQ1_WIDTH-1:0]            ddrc_reg_rd_data_dq1,

output                                 pi_ph_dfi_rddata_en,
output [`MEMC_FREQ_RATIO-1:0]          pi_ph_dfi_wrdata_en,

output                                 ih_wu_wr_valid,         // Goes to WU

output                                 ih_wu_wr_valid_addr_err,

output                                 ih_te_rd_valid,
output                                 ih_te_wr_valid,
output [RMW_TYPE_BITS-1:0]             ih_wu_rmw_type,
output [WR_CAM_ADDR_WIDTH-1:0]         ih_wu_wr_entry,

output [WORD_BITS-1:0]                 ih_wu_critical_word,    // Goes to WU


//--------------------------------------------------------------
//---------------- MR -> IH/WU Interface --------------------------
//--------------------------------------------------------------
input                                  mr_yy_free_wr_entry_valid,
input  [WR_CAM_ADDR_WIDTH_IE-1:0]      mr_yy_free_wr_entry,

//--------------------------------------------------------------
//---------------- MR -> TS Interface --------------------------
//--------------------------------------------------------------
input                                  mr_gs_empty,            // MR has no writes in the pipeline
input                                  dfi_wr_q_empty,

//--------------------------------------------------------------
//---------------- PI -> TS Interface --------------------------
//--------------------------------------------------------------

output                                 pi_gs_geardown_mode_on, // to MR etc

//--------------------------------------------------------------
//---------------- PI -> RT Interface --------------------------
//--------------------------------------------------------------
output [CMD_LEN_BITS-1:0]              pi_rt_rd_partial,
output                                 pi_rt_rd_vld,
output [CORE_TAG_WIDTH-1:0]            pi_rt_rd_tag,
output                                 pi_rt_rd_crc_retry_limit_reach_pre,
output                                 pi_rt_rd_ue_retry_limit_reach_pre,
output                                 pi_rt_rd_addr_err,

output [WR_CAM_ADDR_WIDTH-1:0]         pi_rt_wr_ram_addr,
output [CMD_RMW_BITS-1:0]              pi_rt_rmwcmd,           // atomic RMW command instruction
output [RMW_TYPE_BITS-1:0]             pi_rt_rmwtype,          // RMW type (scrub, partial write, atomic RMW cmd, none)

output [RANKBANK_BITS_FULL-1:0]        pi_rt_rankbank_num,
output [PAGE_BITS-1:0]                 pi_rt_page_num,
output [BLK_BITS-1:0]                  pi_rt_block_num,
output [WORD_BITS-1:0]                 pi_rt_critical_word,


//--------------------------------------------------------------
//---------------- RT -> TS Interface --------------------------
//--------------------------------------------------------------
input                                  rt_gs_empty,            // RT has no read in its FIFO
input                                  rt_gs_empty_delayed,    // RT has no read in its FIFO - delayed version for clock gating logic

//--------------------------------------------------------------
//---------------- TE -> WU Interface --------------------------
//--------------------------------------------------------------
output                                 te_yy_wr_combine,       // also goes to IH/WU

//--------------------------------------------------------------
//---------------- TE -> MR Interface --------------------------
//--------------------------------------------------------------
output                                    ts_pi_mwr,                      // masked write information

output [PARTIAL_WR_BITS-1:0]              te_pi_wr_word_valid,




output [WR_CAM_ADDR_WIDTH_IE-1:0]         te_mr_wr_ram_addr,

//--------------------------------------------------------------
//---------------- TE -> WU Interface --------------------------
//--------------------------------------------------------------
output [WR_CAM_ADDR_WIDTH-1:0]            te_wu_entry_num,
output                                    te_wu_wr_retry,
output                                    te_wu_ie_flowctrl_req,

//--------------------------------------------------------------
//---------------- TS -> MR Interface --------------------------
//--------------------------------------------------------------
output                                    gs_mr_write,
output                                    gs_mr_load_mode_pda,
output [1:0]                              gs_mr_pda_data_sel,  // 00:Normal data  01: MRS to enter PDA mode  10: MRS in PDA mode  11: MRS to exit PDA mode
output                                    pda_mode,            // PDA mode (between 1st MRS and last MRS's tMod)
output                                    pda_mode_pre,        // PDA mode (between 1st MRS and last MRS's t_mod) assert 1cycle earlier than pda_mode
output [MAX_CMD_NUM*NUM_RANKS-1:0]        gs_pi_cs_n,

//-------------------------------------------------------------
//-----------------GS -> MR Interface--------------------------
//-------------------------------------------------------------
  output [PW_WORD_CNT_WD_MAX-1:0]           gs_mr_pw_num_beats_m1,
  output [PARTIAL_WR_BITS_LOG2-1:0]         gs_mr_ram_raddr_lsb_first,
  output [2:0]                              gs_wr_bc_sel,

  output [PW_WORD_CNT_WD_MAX-1:0]           gs_pi_rdwr_pw_num_beats_m1,
  output [PARTIAL_WR_BITS_LOG2-1:0]         gs_pi_rdwr_ram_raddr_lsb_first,
  output [2:0]                              gs_pi_rdwr_bc_sel,
//--------------------------------------------------------------
//---------------- WU -> IH Interface --------------------------
//--------------------------------------------------------------



input                                     wu_ih_flow_cntrl_req,

//--------------------------------------------------------------
//---------------- WU -> TE Interface --------------------------
//--------------------------------------------------------------
input  [1:0]                              wu_te_enable_wr,
input  [WR_CAM_ADDR_WIDTH-1:0]            wu_te_entry_num,
input                                     wu_te_mwr,

input  [PARTIAL_WR_BITS-1:0]              wu_te_wr_word_valid,
input  [PARTIAL_WR_BITS_LOG2-1:0]         wu_te_ram_raddr_lsb_first,
input  [PW_WORD_CNT_WD_MAX-1:0]           wu_te_pw_num_beats_m1,
input  [PW_WORD_CNT_WD_MAX-1:0]           wu_te_pw_num_cols_m1,

//--------------------------------------------------------------
//---------------- WU -> TS Interface --------------------------
//--------------------------------------------------------------
input  [1:0]                              wu_gs_enable_wr,

//--------------------------------------------------------------
//------------- Retry <-> RT Interface -------------------------
//--------------------------------------------------------------
output                                        retry_rt_rdatavld_gate_en,
output                                        retry_rt_fifo_init_n,
output                                        retry_rt_fatl_err_pulse,
output                                        retry_rt_now_sw_intervention,
output [7:0]                                  retry_rt_rd_timeout_value,

//--------------------------------------------------------------
//------------- Retry -> DFI Interface -------------------------
//--------------------------------------------------------------
output                                        retry_dfi_sel,
output [PHY_MASK_WIDTH-1:0]                   retry_phy_dm,
output [PHY_DATA_WIDTH-1:0]                   retry_phy_wdata,
output                                        retry_phy_wdata_vld_early,
output                                        retry_dfi_rddata_en,
output [`MEMC_FREQ_RATIO-1:0]                 retry_dfi_wrdata_en,


// active_ranks_int
output   [`MEMC_NUM_RANKS-1:0]                reg_ddrc_active_ranks_int,
input                                         ddrc_cg_en,
output                                        gs_pi_data_pipeline_empty,

output                                        mrr_op_on, // to ddrc_cg_en
output                                        pi_gs_mpr_mode, // to RT

output                                        ih_busy, // to ddrc_cg_en

//output                                        rd_rdata_discard,

input   [DFI_TPHY_WRLAT_WIDTH-1:0]            mr_t_wrlat,
input   [5:0]                                 mr_t_wrdata,
input   [6:0]                                 mr_t_rddata_en,
input   [DFI_TWCK_EN_RD_WIDTH-2:0]            mr_lp_data_rd,
input   [DFI_TWCK_EN_WR_WIDTH-2:0]            mr_lp_data_wr,

//input dfi_cmd_delay_1r,
//input dfi_cmd_delay_2r,
input [CMD_DELAY_BITS-1:0]     dfi_cmd_delay,

// additional outputs for ddrc_assertions.sv
output [NUM_LRANKS-1:0]        reg_ddrc_ext_rank_refresh,

output                         pi_gs_dll_off_mode,

output [2:0]                   reg_ddrc_fgr_mode_gated,

output                         ddrc_phy_cal_dl_enable,

output                         gs_pi_op_is_exit_selfref,

//--------------------------------------------------------------
//--------------------- PASPI -> DP ----------------------------
//--------------------------------------------------------------
output                         pi_rd_vld,
output [CMD_LEN_BITS-1:0]      pi_rd_partial,
output [CORE_TAG_WIDTH-1:0]    pi_rd_tag,
output                         pi_rd_crc_retry_limit_reach_pre,
output                         pi_rd_ue_retry_limit_reach_pre,
output                         pi_rd_mrr,
output                         pi_rd_mrr_ext,
output                         pi_rd_addr_err,
output [RMW_TYPE_BITS-1:0]     pi_rd_rmw_type,
output [WR_CAM_ADDR_WIDTH-1:0] pi_rd_wr_ram_addr,
output [PAGE_BITS-1:0]         pi_rd_page,
output [BLK_BITS-1:0]          pi_rd_blk,
output [WORD_BITS-1:0]         pi_rd_critical_word,
output [RANKBANK_BITS_FULL-1:0]pi_rd_rankbank,
output                         pi_wr_vld_nxt,
output [1:0]                   pi_wr_ph_nxt,
output [NUM_RANKS-1:0]         pi_wr_cs_nxt,
output                         pi_rd_vld_nxt,
output [1:0]                   pi_rd_ph_nxt,
output [`MEMC_FREQ_RATIO-1:0]  pi_dfi_wrdata_en,
output [`MEMC_FREQ_RATIO-1:0]  pi_dfi_rddata_en,
output                         pi_rd_mrr_snoop,
output [3:0]                   pi_phy_snoop_en,


//registers for DDR5

output  [PRANK_MODE_WIDTH-1:0]          ddrc_reg_prank3_mode,
output  [PRANK_MODE_WIDTH-1:0]          ddrc_reg_prank2_mode,
output  [PRANK_MODE_WIDTH-1:0]          ddrc_reg_prank1_mode,
output  [PRANK_MODE_WIDTH-1:0]          ddrc_reg_prank0_mode,

output  [DBG_STAT3_WIDTH-1:0]           ddrc_reg_dbg_stat3,
output  [DBG_STAT2_WIDTH-1:0]           ddrc_reg_dbg_stat2,
output  [DBG_STAT1_WIDTH-1:0]           ddrc_reg_dbg_stat1,
output  [DBG_STAT0_WIDTH-1:0]           ddrc_reg_dbg_stat0,

output                                        dch_sync_mode_o                 ,
output  [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]      dch_dfi_cs_o                    ,
output  [`MEMC_FREQ_RATIO*PHY_ADDR_BITS-1:0]  dch_dfi_address_o               ,
output  [`MEMC_FREQ_RATIO*2-1:0]              dch_dfi_parity_in_o             ,
output  [`MEMC_NUM_CLKS-1:0]                  dch_dfi_dram_clk_disable_o      ,
output                                        dch_dfi_ctrlupd_req_o           ,
output                                        dch_dfi_init_start_o            ,
output  [DFI_FREQUENCY_WIDTH-1:0]             dch_dfi_frequency_o             ,
output                                        dch_dfi_ctrlupd_ack_o           ,
output                                        dch_dfi_init_complete_o         ,

output                                        rank_idle_state_o             ,
output                                        rank_selfref_state_o          ,
output                                        selfref_idle_entry_o          ,
output                                        selfref_sw_entry_o            ,
output                                        selfref_hw_entry_o            ,
output                                        selfref_sw_o                  ,
output                                        selfref_idle_exit_o           ,
output                                        selfref_sw_exit_o             ,
output  [3:0]                                 channel_message_o             ,
output                                        rank_selfref_operating_mode_o ,
output                                        rank_selfref_swhw_state_o     ,
output                                        rank_selfref_tctrl_delay_ack_o,
output                                        dfi_lp_selfref_tlp_resp_ack_o ,
output                                        hw_lp_exit_idle_o             ,
output                                        hw_lp_selfref_hw_o            ,

output [DBG_RANK_CTRL_MC_CODE_0_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_code_0    ,
output [DBG_RANK_CTRL_MC_ADDR_0_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_addr_0    ,
output [DBG_RANK_CTRL_STATE_RSM_0_WIDTH-1:0]  ddrc_reg_dbg_rank_ctrl_state_rsm_0  ,
output [DBG_MCEU_CTRL_STATE_MCEU_0_WIDTH-1:0] ddrc_reg_dbg_mceu_ctrl_state_mceu_0 ,
output [DBG_SCEU_CTRL_STATE_SCEU_0_WIDTH-1:0] ddrc_reg_dbg_sceu_ctrl_state_sceu_0 ,
output [DBG_RANK_CTRL_MC_CODE_1_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_code_1    ,
output [DBG_RANK_CTRL_MC_ADDR_1_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_addr_1    ,
output [DBG_RANK_CTRL_STATE_RSM_1_WIDTH-1:0]  ddrc_reg_dbg_rank_ctrl_state_rsm_1  ,
output [DBG_MCEU_CTRL_STATE_MCEU_1_WIDTH-1:0] ddrc_reg_dbg_mceu_ctrl_state_mceu_1 ,
output [DBG_SCEU_CTRL_STATE_SCEU_1_WIDTH-1:0] ddrc_reg_dbg_sceu_ctrl_state_sceu_1 ,
output [DBG_RANK_CTRL_MC_CODE_2_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_code_2    ,
output [DBG_RANK_CTRL_MC_ADDR_2_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_addr_2    ,
output [DBG_RANK_CTRL_STATE_RSM_2_WIDTH-1:0]  ddrc_reg_dbg_rank_ctrl_state_rsm_2  ,
output [DBG_MCEU_CTRL_STATE_MCEU_2_WIDTH-1:0] ddrc_reg_dbg_mceu_ctrl_state_mceu_2 ,
output [DBG_SCEU_CTRL_STATE_SCEU_2_WIDTH-1:0] ddrc_reg_dbg_sceu_ctrl_state_sceu_2 ,
output [DBG_RANK_CTRL_MC_CODE_3_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_code_3    ,
output [DBG_RANK_CTRL_MC_ADDR_3_WIDTH-1:0]    ddrc_reg_dbg_rank_ctrl_mc_addr_3    ,
output [DBG_RANK_CTRL_STATE_RSM_3_WIDTH-1:0]  ddrc_reg_dbg_rank_ctrl_state_rsm_3  ,
output [DBG_MCEU_CTRL_STATE_MCEU_3_WIDTH-1:0] ddrc_reg_dbg_mceu_ctrl_state_mceu_3 ,
output [DBG_SCEU_CTRL_STATE_SCEU_3_WIDTH-1:0] ddrc_reg_dbg_sceu_ctrl_state_sceu_3 ,
output [DBG_HW_LP_STATE_HSM_WIDTH-1:0]        ddrc_reg_dbg_hw_lp_state_hsm        ,
output                                        ddrc_reg_dbg_dfi_lp_ctrl_ack        ,
output                                        ddrc_reg_dbg_dfi_lp_data_ack        ,
output [DBG_DFI_LP_STATE_DSM_WIDTH-1:0]       ddrc_reg_dbg_dfi_lp_state_dsm       ,
output [DBG_CAPAR_RETRY_MC_CODE_WIDTH-1:0]    ddrc_reg_dbg_capar_retry_mc_code    ,
output [DBG_CAPAR_RETRY_MC_ADDR_WIDTH-1:0]    ddrc_reg_dbg_capar_retry_mc_addr    ,
output [DBG_CAPAR_RETRY_STATE_CSM_WIDTH-1:0]  ddrc_reg_dbg_capar_retry_state_csm  ,
output [DBG_CAPAR_RETRY_STATE_MCEU_WIDTH-1:0] ddrc_reg_dbg_capar_retry_state_mceu ,
output [DBG_CAPAR_RETRY_STATE_SCEU_WIDTH-1:0] ddrc_reg_dbg_capar_retry_state_sceu ,

output [CMDFIFO_RD_DATA_WIDTH-1:0]            ddrc_reg_cmdfifo_rd_data            , 
output                                        ddrc_reg_cmdfifo_overflow           , 
output [CMDFIFO_RECORDED_CMD_NUM_WIDTH-1:0]   ddrc_reg_cmdfifo_recorded_cmd_num   , 
output [CMDFIFO_WINDOW_CMD_NUM_WIDTH-1:0]     ddrc_reg_cmdfifo_window_cmd_num     , 

// Register REGB_DDRC_CH0.CMDSTAT
output [CMD_RSLT_WIDTH-1:0]             ddrc_reg_cmd_rslt,
output                                  ddrc_reg_mrr_data_vld,
output                                  ddrc_reg_rd_data_vld,
output                                  ddrc_reg_ctrlupd_err_intr,
output                                  ddrc_reg_cmd_err,
output                                  ddrc_reg_cmd_done,

output [15:0]                           ddrc_reg_du_cfgbuf_rdata,
output [15:0]                           ddrc_reg_du_cmdbuf_rdata,
output [15:0]                           ddrc_reg_lp_cmdbuf_rdata,
output [15:0]                           ddrc_reg_capar_cmdbuf_rdata,

output [POWERDOWN_ONGOING_WIDTH-1:0]    ddrc_reg_powerdown_ongoing,
output [SELFREF_ONGOING_WIDTH-1:0]      ddrc_reg_selfref_ongoing,
//input  [CMD_WR_DATA_0_WIDTH-1:0]          reg_ddrc_cmd_wr_data_0,
output  [NUM_RANKS-1:0]                 dbg_prank_act_pd,
output  [NUM_RANKS-1:0]                 dbg_prank_pre_pd,

output [CMD_MRR_DATA_WIDTH-1:0]         ddrc_reg_cmd_mrr_data,

output                                  ddrc_reg_du_cur_blk_set,
output  [DU_CUR_BLK_INDEX_WIDTH-1:0]    ddrc_reg_du_cur_blk_index,
output  [DU_CUR_BLK_ADDR_WIDTH-1:0]     ddrc_reg_du_cur_blk_addr,
output  [DU_CUR_BLK_UCODE_WIDTH-1:0]    ddrc_reg_du_cur_blk_ucode,
output  [DU_MAIN_FSM_STATE_WIDTH-1:0]   ddrc_reg_du_main_fsm_state,

output  [GLB_BLK_EVENTS_ONGOING_WIDTH-1:0]      ddrc_reg_glb_blk_events_ongoing,
output  [RANK_BLK_EVENTS_ONGOING_WIDTH-1:0]     ddrc_reg_rank_blk_events_ongoing,
output  [DU_MCEU_FSM_STATE_WIDTH-1:0]           ddrc_reg_du_mceu_fsm_state,
output  [DU_SCEU_FSM_STATE_WIDTH-1:0]           ddrc_reg_du_sceu_fsm_state,

output                                  ddrc_reg_caparcmd_err_intr,
output  [CAPARCMD_ERR_STS_WIDTH-1:0]    ddrc_reg_caparcmd_err_sts,
output                                  ddrc_reg_lccmd_err_intr,
output                                  ddrc_reg_ducmd_err_intr,
output                                  ddrc_reg_swcmd_err_intr,
output  [SWCMD_ERR_STS_WIDTH-1:0]       ddrc_reg_swcmd_err_sts,
output  [DUCMD_ERR_STS_WIDTH-1:0]       ddrc_reg_ducmd_err_sts,
output  [LCCMD_ERR_STS_WIDTH-1:0]       ddrc_reg_lccmd_err_sts,

output                                  ddrc_reg_rfm_alert_intr,
output  [RFM_CMD_LOG_WIDTH-1:0]         ddrc_reg_rfm_cmd_log,

output                                  ddrc_reg_2n_mode,

input                                   reg_ddrc_dis_dqsosc_srx,
input                                   reg_ddrc_dqsosc_enable,                 // DQSOSC enable
input  [T_OSCO_WIDTH-1:0]               reg_ddrc_t_osco,                        // t_osco timing
input  [7:0]                            reg_ddrc_dqsosc_runtime,                // Oscillator runtime
input  [7:0]                            reg_ddrc_wck2dqo_runtime,               // Oscillator runtime only for LPDDR5
input  [11:0]                           reg_ddrc_dqsosc_interval,               // DQSOSC inverval
input                                   reg_ddrc_dqsosc_interval_unit,          // DQSOSC interval unit
output [2:0]                            dqsosc_state,
output [NUM_RANKS-1:0]                  dqsosc_per_rank_stat,
output [3:0]                            pi_ph_snoop_en,
output                                  pi_rt_rd_mrr_snoop,

`ifdef SNPS_ASSERT_ON
input [1:0]                             reg_ddrc_data_bus_width,
`endif
input  [DFI_T_CTRLMSG_RESP_WIDTH-1:0]   reg_ddrc_dfi_t_ctrlmsg_resp,
input                                   reg_ddrc_dfi0_ctrlmsg_req,
input                                   reg_ddrc_dfi0_ctrlmsg_tout_clr,
input  [DFI_CTRLMSG_DATA_WIDTH-1:0]     reg_ddrc_dfi0_ctrlmsg_data,
input  [DFI_CTRLMSG_CMD_WIDTH-1:0]      reg_ddrc_dfi0_ctrlmsg_cmd,
input                                   dfi_ctrlmsg_ack,

output                                  ddrc_reg_dfi0_ctrlmsg_req_busy,
output                                  ddrc_reg_dfi0_ctrlmsg_resp_tout,
output                                  dfi_ctrlmsg_req,
output  [7:0]                           dfi_ctrlmsg,
output  [15:0]                          dfi_ctrlmsg_data


   ,output                                   ih_wu_is_retry_wr
   ,output [PW_WORD_CNT_WD_MAX-1:0]          ih_wu_wr_pw_num_beats_m1
   ,output                                   retryctrl_head_exp
   ,output                                   retry_fifo_empty
   ,output                                   capar_retry_start
   ,output                                   capar_rd_expired
   ,output                                   dbg_capar_retry_pulse
    ,output [`DDRCTL_EAPAR_SIZE-1:0]         ih_wu_wr_eapar
   ,output                                   capar_rddata_en
    ,output                                              ddrc_reg_ppt2_burst_busy
    ,output [PPT2_STATE_WIDTH-1:0]                       ddrc_reg_ppt2_state
);




//////////////////////////////////////////////////////
// localparams
//////////////////////////////////////////////////////

localparam      COL_BITS        = WORD_BITS + BLK_BITS;

localparam      RANKBANK_BITS   = LRANK_BITS + BG_BANK_BITS;


localparam      OTHER_WR_ENTRY_BITS = RMW_TYPE_BITS ;



localparam AUTOPRE_BITS=(`MEMC_INLINE_ECC_EN==1 || `MEMC_USE_RMW_EN==1)? 2 : 1;

localparam ECCAP_BITS  = `MEMC_ECCAP_EN;

localparam IE_TAG_BITS = (`MEMC_INLINE_ECC_EN==1) ? IE_RD_TYPE_BITS + IE_BURST_NUM_BITS + BT_BITS + ECCAP_BITS : 0;


//parameters used for ddrc_cpe only
localparam CID_WIDTH_DDRC           = `DDRCTL_DDRC_CID_WIDTH;
localparam CID_WIDTH_DUP_DDRC       = `DDRCTL_DDRC_CID_WIDTH == 0 ? 1 : `DDRCTL_DDRC_CID_WIDTH;
localparam NUM_LRANKS_DDRC          = `DDRCTL_DDRC_NUM_LRANKS_TOTAL;
localparam LRANK_BITS_DDRC          = `DDRCTL_DDRC_LRANK_BITS;
localparam RANKBANK_BITS_DDRC       = `DDRCTL_DDRC_RANKBANK_BITS;
localparam RANKBANK_BITS_FULL_DDRC  = `DDRCTL_DDRC_LRANK_BITS + BG_BITS + BANK_BITS;
localparam NUM_TOTAL_BANKS_DDRC     = `DDRCTL_DDRC_NUM_TOTAL_BANKS;



    localparam DDR4_COL3_BITS = 0;

localparam RETRY_TIMES_WIDTH =  RD_CRC_RETRY_LIMITER_WIDTH; // RD_CRC_RETRY_LIMITER_WIDTH or WR_CRC_RETRY_LIMITER_WIDTH
localparam ENTRY_RETRY_TIMES_WIDTH = RETRY_TIMES_WIDTH + 1;
//------------------------------------------------------------------------------
// Interface
//------------------------------------------------------------------------------
dwc_ddrctl_ddrc_cpfcpe_if #(
    .NUM_LRANKS                  (NUM_LRANKS_DDRC           )
   ,.LRANK_BITS                  (LRANK_BITS_DDRC           )
   ,.RANKBANK_BITS               (RANKBANK_BITS_DDRC        )
   ,.NUM_TOTAL_BANKS             (NUM_TOTAL_BANKS_DDRC      )
   ,.BG_BANK_BITS                (BG_BANK_BITS              )
   ,.NUM_TOTAL_BSMS              (NUM_TOTAL_BSMS            )
   ,.RD_CAM_ADDR_WIDTH           (RD_CAM_ADDR_WIDTH         )
   ,.WR_CAM_ADDR_WIDTH_IE        (WR_CAM_ADDR_WIDTH_IE      )
   ,.PAGE_BITS                   (PAGE_BITS                 )
   ,.AUTOPRE_BITS                (AUTOPRE_BITS              )
   ,.PARTIAL_WR_BITS             (PARTIAL_WR_BITS           )
   ,.PARTIAL_WR_BITS_LOG2        (PARTIAL_WR_BITS_LOG2      )
   ,.PW_NUM_DB                   (PW_NUM_DB                 )
   ,.PW_FACTOR_HBW               (PW_FACTOR_HBW             )
   ,.PW_WORD_VALID_WD_HBW        (PW_WORD_VALID_WD_HBW      )
   ,.PW_WORD_VALID_WD_MAX        (PW_WORD_VALID_WD_MAX      )
   ,.PW_WORD_CNT_WD_MAX          (PW_WORD_CNT_WD_MAX        )
   ,.PW_BC_SEL_BITS              (PW_BC_SEL_BITS            )

   ,.IE_RD_TYPE_BITS             (IE_RD_TYPE_BITS           )
   ,.IE_BURST_NUM_BITS           (IE_BURST_NUM_BITS         )
   ,.NO_OF_BT                    (NO_OF_BT                  )
   ,.BT_BITS                     (BT_BITS                   )
   ,.ECCAP_BITS                  (ECCAP_BITS                )
   ,.IE_TAG_BITS                 (IE_TAG_BITS               )
   ,.WORD_BITS                   (WORD_BITS                 )
   ,.BLK_BITS                    (BLK_BITS                  )
   ,.BSM_BITS                    (BSM_BITS                  )
   ,.CMD_LEN_BITS                (CMD_LEN_BITS              )
   ,.CORE_TAG_WIDTH              (CORE_TAG_WIDTH            )
   ,.RMW_TYPE_BITS               (RMW_TYPE_BITS             )
   ,.WR_CAM_ADDR_WIDTH           (WR_CAM_ADDR_WIDTH         )
   ,.MAX_CAM_ADDR_WIDTH          (MAX_CAM_ADDR_WIDTH        )
   ) ddrc_cpfcpeif();

dwc_ddrctl_ddrc_cpedfi_if #(
    .NUM_RANKS                   (NUM_RANKS                 )
   ,.FREQ_RATIO                  (`MEMC_FREQ_RATIO          )
   ,.BANK_BITS                   (BANK_BITS                 )
   ,.BG_BITS                     (BG_BITS                   )
   ,.CID_WIDTH                   (CID_WIDTH_DUP_DDRC        )
   ,.ADDR_WIDTH                  (PHY_ADDR_BITS             )
   ,.RESET_WIDTH                 (`UMCTL2_RESET_WIDTH       )
   ,.PARITY_IN_WIDTH             (PARITY_IN_WIDTH           )
   ,.NUM_LANES                   (NUM_LANES                 )
   ,.NUM_DRAM_CLKS               (NUM_PHY_DRAM_CLKS         )
) ddrc_cpedfiif();


// ih_mr_ie_pw is removed from IH and MR,
assign ih_mr_ie_pw      = {IE_PW_BITS{1'b0}};
//------------------------------------------------------------------------------
// No ifdefs for outputs
// So need to drive certain outputs for else case i.e. ifndef
//------------------------------------------------------------------------------
assign  ih_wu_is_retry_wr              = 1'b0;
assign  ih_wu_wr_pw_num_beats_m1       = {PW_WORD_CNT_WD_MAX{1'b0}};
assign  retryctrl_head_exp             = 1'b0;
assign  retry_fifo_empty               = 1'b0;
assign  capar_retry_start              = 1'b0;
assign  capar_rd_expired               = 1'b0;
assign  capar_rddata_en                = 1'b0;
assign  dbg_capar_retry_pulse          = 1'b0;
assign                          hif_rcmd_stall = 1'b0;           // cmd stall
assign                          hif_wcmd_stall = 1'b0;           // cmd stall


assign                          ddrc_reg_pda_done = 1'b0;         // indicates that MRS operation related to PDA mode has done


assign                          stat_ddrc_reg_retry_current_state = 4'b0;

assign                          dbg_dfi_in_retry = 1'b0;
assign                          dbg_dfi_ie_cmd_type = 3'b0;
assign                          ddrc_reg_dbg_wrecc_q_depth = {(WR_CAM_ADDR_WIDTH+1){1'b0}};
assign                          ddrc_reg_num_alloc_bsm = {BSM_BITS{1'b0}};

assign   ddrc_reg_max_num_alloc_bsm          = {(BSM_BITS+1){1'b0}};
assign   ddrc_reg_max_num_unalloc_entries    = {(RD_CAM_ADDR_WIDTH+2){1'b0}};

assign ddrc_reg_addrmap_lut_rdata1   = {ADDRMAP_LUT_RDATA1_WIDTH{1'b0}};
assign ddrc_reg_addrmap_lut_rdata0   = {ADDRMAP_LUT_RDATA0_WIDTH{1'b0}};
assign ddrc_reg_addrmap_rank_valid   = {ADDRMAP_RANK_VALID_WIDTH{1'b0}};


assign    ddrc_core_reg_dbg_operating_mode = 3'b0;
assign    ddrc_core_reg_dbg_global_fsm_state = 5'b0;

assign    ddrc_core_reg_dbg_init_curr_state = 5'b0;
assign    ddrc_core_reg_dbg_init_next_state = 5'b0;

assign    ddrc_core_reg_dbg_ctrlupd_state = 2'b0;

assign    ddrc_core_reg_dbg_lpr_q_state = 2'b0;
assign    ddrc_core_reg_dbg_hpr_q_state = 2'b0;
assign    ddrc_core_reg_dbg_wr_q_state = 2'b0;


assign    ddrc_core_reg_dbg_lpr_q_depth    = {(RD_CAM_ADDR_WIDTH+1){1'b0}};
assign    ddrc_core_reg_dbg_hpr_q_depth    = {(RD_CAM_ADDR_WIDTH+1){1'b0}};
assign    ddrc_core_reg_dbg_wr_q_depth     = {(WR_CAM_ADDR_WIDTH+1){1'b0}};
assign    ddrc_core_reg_dbg_wrecc_q_depth  = {(WR_CAM_ADDR_WIDTH+1){1'b0}};

assign    ddrc_core_reg_dbg_hif_cmd_stall  = 1'b0;
assign    ddrc_core_reg_dbg_hif_rcmd_stall = 1'b0;
assign    ddrc_core_reg_dbg_hif_wcmd_stall = 1'b0;

assign                                 ddrc_core_reg_dbg_wr_cam_7_0_valid = 8'b0; // 1-bit per cam location
assign                                 ddrc_core_reg_dbg_rd_cam_7_0_valid = 8'b0; // 1-bit per cam location
assign                                 ddrc_core_reg_dbg_wr_cam_15_8_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_15_8_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_wr_cam_23_16_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_23_16_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_wr_cam_31_24_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_31_24_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_wr_cam_39_32_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_39_32_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_wr_cam_47_40_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_47_40_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_wr_cam_55_48_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_55_48_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_wr_cam_63_56_valid = 8'b0;
assign                                 ddrc_core_reg_dbg_rd_cam_63_56_valid = 8'b0;






assign                          dfi_ctrlupd_type    = 2'b0;
assign                          dfi_ctrlupd_target  = 2'b0;



assign                          ddrc_reg_capar_retry_limit_intr = 1'b0;
assign                          ddrc_reg_capar_fatl_err_intr = 1'b0;
assign                          ddrc_reg_capar_fatl_err_code = {CAPAR_FATL_ERR_CODE_WIDTH{1'b0}};
assign                          ddrc_reg_wr_crc_err_max_reached_intr = 1'b0;
assign                          ddrc_reg_wr_crc_err_cnt = {WR_CRC_ERR_CNT_WIDTH{1'b0}};
assign                          ddrc_reg_wr_crc_err_intr = 1'b0;
assign                          ddrc_reg_capar_err_max_reached_intr = 1'b0;
assign                          ddrc_reg_capar_err_intr = 1'b0;
assign                          ddrc_reg_capar_err_cnt  = {CAPAR_ERR_CNT_WIDTH{1'b0}};

//TODO need to connect
assign                          ddrc_reg_retry_fifo_fill_level = {RETRY_FIFO_FILL_LEVEL_WIDTH{1'b0}};
assign                          ddrc_reg_retry_stat = {RETRY_STAT_WIDTH{1'b0}};

assign                          ddrc_reg_wr_crc_retry_limit_intr =  1'b0;      
assign                          dbg_wr_crc_retry_pulse =1'b0;

assign                          ddrc_reg_rd_retry_limit_intr = 1'b0;
assign                          ddrc_reg_rd_crc_retry_limit_reached = 1'b0;      
assign                          dbg_rd_crc_retry_pulse =1'b0;

assign                          ddrc_reg_rd_ue_retry_limit_reached = 1'b0;      
assign                          dbg_rd_ue_retry_pulse =1'b0;
assign                          dbg_rd_retry_rank = {LRANK_BITS_DUP{1'b0}};

assign                          retryram_din   = 1'b0; // // note use of <param>_DUP
assign                          retryram_waddr = 1'b0; // // note use of <param>_DUP
assign                          retryram_raddr = 1'b0; // // note use of <param>_DUP
assign                          retryram_re    = 1'b0;
assign                          retryram_we    = 1'b0;
assign                          retryram_mask  = 1'b0; // // note use of <param>_DUP



assign                          ddrc_reg_capar_poison_complete = 1'b0;
assign                          dbg_dfi_parity_poison = 1'b0;

assign                          ddrc_reg_ppr_done = 1'b0;

assign                          ddrc_reg_dbg_stall_rd = 1'b0;
assign                          ddrc_reg_dbg_stall_wr = 1'b0;




assign                         hif_refresh_req = {NUM_RANKS{1'b0}};
assign                         hif_refresh_req_cnt = {6*NUM_RANKS{1'b0}};
assign                         hif_refresh_req_derate = 3'b0;
assign                         hif_refresh_active = {NUM_RANKS{1'b0}};


// Frequency selection
assign                  hwffc_target_freq_en = 1'b0;
assign                  hwffc_target_freq = {TARGET_FREQUENCY_WIDTH{1'b0}};
assign                  hwffc_target_freq_init = {TARGET_FREQUENCY_WIDTH{1'b0}};
// From/To APB (register)
assign                  ddrc_reg_hwffc_in_progress = 1'b0;
assign                  ddrc_reg_current_frequency = {TARGET_FREQUENCY_WIDTH{1'b0}};
assign                  ddrc_reg_current_fsp = 1'b0;
assign                  ddrc_reg_current_vrcg = 1'b0;
assign                  ddrc_reg_hwffc_operating_mode = 1'b0;

assign                  ddrc_xpi_port_disable_req = 1'b0;
assign                  ddrc_xpi_clock_required = 1'b0;

// to WU
assign                  hwffc_hif_wd_stall = 1'b0;
assign                  hwffc_i_reg_ddrc_dis_auto_zq = 1'b0;



assign                             ih_mr_ie_blk_wr_end = 1'b0;
assign                             ih_rd_ie_brt = {BRT_BITS{1'b0}};
assign                             ih_rd_ie_rd_cnt_inc = 1'b0;
assign                             ih_rd_ie_blk_rd_end = 1'b0;
assign                             ih_mr_ie_wr_cnt_dec_vct = {NO_OF_BWT{1'b0}};
assign                             ih_mr_ie_wr_cnt_inc = 1'b0;
assign                             ih_mr_ie_bwt = {BWT_BITS{1'b0}};
assign                             ih_mr_ie_brt = {BWT_BITS{1'b0}};
assign                             ih_mr_ie_brt_vld = 1'b0;

assign                             hif_wrecc_credit = 2'b00;


// TE to MR
assign                             te_mr_ie_bt = {BT_BITS{1'b0}};
assign                             te_mr_ie_wr_type = {IE_WR_TYPE_BITS{1'b0}};
assign                             te_mr_ie_blk_burst_num = {IE_BURST_NUM_BITS{1'b0}};  //only for the Data command

// PI to RT
assign                             pi_rt_ie_bt = {BT_BITS{1'b0}};
assign                             pi_rt_ie_rd_type = {IE_RD_TYPE_BITS{1'b0}};
assign                             pi_rt_ie_blk_burst_num = {IE_BURST_NUM_BITS{1'b0}};  //only for the Data command

// TE to WU

//signals for look up BT table
assign                             ih_mr_lkp_bwt = {BWT_BITS{1'b0}};
assign                             ih_mr_lkp_bwt_vld = 1'b0;
assign                             ih_mr_lkp_brt = {BRT_BITS{1'b0}};
assign                             ih_mr_lkp_brt_vld = 1'b0;
assign                             ih_rd_lkp_brt = {BRT_BITS{1'b0}};
assign                             ih_rd_lkp_brt_vld = 1'b0;
assign                             ih_rd_lkp_bwt = {BWT_BITS{1'b0}};
assign                             ih_rd_lkp_bwt_vld = 1'b0;
assign                             ih_ie_busy = 1'b0;
assign                             te_wu_ie_flowctrl_req = 1'b0; // no longer used.

assign                             te_mr_eccap = 1'b0;
assign                             pi_rt_eccap = 1'b0;

assign                             ih_wu_cerr = {`MEMC_DCERRBITS{1'b0}};


assign                                 pi_gs_geardown_mode_on = 1'b0;


assign                                 pi_rt_rd_crc_retry_limit_reach_pre = 1'b0;
assign                                 pi_rt_rd_ue_retry_limit_reach_pre = 1'b0;

assign                                 pi_rt_rmwcmd  = {CMD_RMW_BITS{1'b0}}; // unused



  assign                                    gs_pi_rdwr_bc_sel = 3'b0;


  assign                                    gs_wr_bc_sel = 3'b0;

assign                                    gs_mr_load_mode_pda = 1'b0;
assign                                    gs_mr_pda_data_sel = 2'b0;
assign                                    pda_mode = 1'b0;
assign                                    pda_mode_pre = 1'b0;
assign                                    gs_pi_cs_n = {MAX_CMD_NUM*NUM_RANKS{1'b0}};

assign                                        retry_dfi_sel = 1'b0;
assign                                        retry_phy_dm = {PHY_MASK_WIDTH{1'b0}};
assign                                        retry_phy_wdata = {PHY_DATA_WIDTH{1'b0}};
assign                                        retry_phy_wdata_vld_early = 1'b0;
assign                                        retry_dfi_rddata_en = 1'b0;
assign                                        retry_dfi_wrdata_en = 2'b0;
assign                                        retry_rt_rd_timeout_value = 8'b0;
assign                                        retry_rt_rdatavld_gate_en = 1'b0;
assign                                        retry_rt_now_sw_intervention = 1'b0;
assign                                        retry_rt_fatl_err_pulse = 1'b0;
assign                                        retry_rt_fifo_init_n = 1'b1;


// active_ranks_int
assign                                        reg_ddrc_active_ranks_int = {`MEMC_NUM_RANKS{1'b0}};

assign                                        pi_gs_mpr_mode = 1'b0;

assign                         reg_ddrc_ext_rank_refresh = {NUM_LRANKS{1'b0}};

assign                         pi_gs_dll_off_mode = 1'b0;
assign                         reg_ddrc_fgr_mode_gated = 3'b0;
assign                         ddrc_phy_cal_dl_enable = 1'b0;
assign dfi_hif_cmd_addr = {`MEMC_HIF_ADDR_WIDTH{1'b0}};


assign dfi_hif_cmd_wdata_ptr = {`DDRCTL_DFI_HIF_CMD_WDATA_PTR_RANGE{1'b0}};

assign                         ddrc_reg_prank3_mode      = {PRANK_MODE_WIDTH{1'b0}};
assign                         ddrc_reg_prank2_mode      = {PRANK_MODE_WIDTH{1'b0}};
assign                         ddrc_reg_prank1_mode      = {PRANK_MODE_WIDTH{1'b0}};
assign                         ddrc_reg_prank0_mode      = {PRANK_MODE_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_stat3        = {DBG_STAT3_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_stat2        = {DBG_STAT2_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_stat1        = {DBG_STAT1_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_stat0        = {DBG_STAT0_WIDTH{1'b0}};

assign                         dch_sync_mode_o           = 1'b0;
assign                         dch_dfi_cs_o              = {(`MEMC_FREQ_RATIO*NUM_RANKS){1'b0}};
assign                         dch_dfi_address_o         = {(`MEMC_FREQ_RATIO*PHY_ADDR_BITS){1'b0}};
assign                         dch_dfi_parity_in_o       = {(`MEMC_FREQ_RATIO*2){1'b0}};
assign                         dch_dfi_dram_clk_disable_o= {`MEMC_NUM_CLKS{1'b0}};
assign                         dch_dfi_ctrlupd_req_o     = 1'b0;
assign                         dch_dfi_init_start_o      = 1'b0;
assign                         dch_dfi_frequency_o       = {DFI_FREQUENCY_WIDTH{1'b0}};
assign                         dch_dfi_ctrlupd_ack_o     = 1'b0;
assign                         dch_dfi_init_complete_o   = 1'b0;

assign                         rank_idle_state_o              = 1'b0;
assign                         rank_selfref_state_o           = 1'b0;
assign                         selfref_idle_entry_o           = 1'b0;
assign                         selfref_sw_entry_o             = 1'b0;
assign                         selfref_hw_entry_o             = 1'b0;
assign                         selfref_sw_o                   = 1'b0;
assign                         selfref_idle_exit_o            = 1'b0;
assign                         selfref_sw_exit_o              = 1'b0;
assign                         channel_message_o              = 4'b0;
assign                         rank_selfref_operating_mode_o  = 1'b0;
assign                         rank_selfref_swhw_state_o      = 1'b0;
assign                         rank_selfref_tctrl_delay_ack_o = 1'b0;
assign                         dfi_lp_selfref_tlp_resp_ack_o  = 1'b0;
assign                         hw_lp_exit_idle_o              = 1'b0;
assign                         hw_lp_selfref_hw_o             = 1'b0;

assign                         ddrc_reg_cmd_rslt           = {CMD_RSLT_WIDTH{1'b0}};

assign                         ddrc_reg_mrr_data_vld       = 1'b0;
assign                         ddrc_reg_rd_data_vld        = 1'b0;
assign                         ddrc_reg_ctrlupd_err_intr   = 1'b0;
assign                         ddrc_reg_cmd_done           = 1'b0;
assign                         ddrc_reg_cmd_err            = 1'b0;
assign                         ddrc_reg_cmd_mrr_data       = {CMD_MRR_DATA_WIDTH{1'b0}};
assign                         ddrc_reg_du_cfgbuf_rdata    = {16{1'b0}};
assign                         ddrc_reg_du_cmdbuf_rdata    = {16{1'b0}};
assign                         ddrc_reg_lp_cmdbuf_rdata    = {16{1'b0}};
assign                         ddrc_reg_capar_cmdbuf_rdata = {16{1'b0}};
assign                         ddrc_reg_powerdown_ongoing  = {POWERDOWN_ONGOING_WIDTH{1'b0}};
assign                         ddrc_reg_selfref_ongoing    = {SELFREF_ONGOING_WIDTH{1'b0}};
assign                         ddrc_reg_dfi_lp_state       = 1'b0;
assign                         ddrc_reg_mpsm_state         = {MPSM_STATE_WIDTH{1'b0}};
assign                         ddrc_reg_powerdown_state    = {POWERDOWN_STATE_WIDTH{1'b0}};
assign                         ddrc_reg_du_cur_blk_set     = 1'b0;
assign                         ddrc_reg_du_cur_blk_index   = {DU_CUR_BLK_INDEX_WIDTH{1'b0}};
assign                         ddrc_reg_du_cur_blk_addr    = {DU_CUR_BLK_ADDR_WIDTH{1'b0}};
assign                         ddrc_reg_du_cur_blk_ucode   = {DU_CUR_BLK_UCODE_WIDTH{1'b0}};
assign                         ddrc_reg_du_main_fsm_state       = {DU_MAIN_FSM_STATE_WIDTH{1'b0}};
assign                         ddrc_reg_glb_blk_events_ongoing  = {GLB_BLK_EVENTS_ONGOING_WIDTH{1'b0}};
assign                         ddrc_reg_rank_blk_events_ongoing = {RANK_BLK_EVENTS_ONGOING_WIDTH{1'b0}};
assign                         ddrc_reg_du_mceu_fsm_state       = {DU_MCEU_FSM_STATE_WIDTH{1'b0}};
assign                         ddrc_reg_du_sceu_fsm_state       = {DU_SCEU_FSM_STATE_WIDTH{1'b0}};
assign                         ddrc_reg_caparcmd_err_intr = 1'b0;
assign                         ddrc_reg_caparcmd_err_sts  = {CAPARCMD_ERR_STS_WIDTH{1'b0}};
assign                         ddrc_reg_lccmd_err_intr   = 1'b0;
assign                         ddrc_reg_ducmd_err_intr   = 1'b0;
assign                         ddrc_reg_swcmd_err_intr   = 1'b0;
assign                         ddrc_reg_swcmd_err_sts    = {SWCMD_ERR_STS_WIDTH{1'b0}};
assign                         ddrc_reg_ducmd_err_sts    = {DUCMD_ERR_STS_WIDTH{1'b0}};
assign                         ddrc_reg_lccmd_err_sts    = {LCCMD_ERR_STS_WIDTH{1'b0}};
assign                         ddrc_reg_rfm_alert_intr   = 1'b0;
assign                         ddrc_reg_rfm_cmd_log      = {RFM_CMD_LOG_WIDTH{1'b0}};
assign                         ddrc_reg_2n_mode          = 1'b0;
assign                         ddrc_reg_dbg_rank_ctrl_mc_code_0            = {DBG_RANK_CTRL_MC_CODE_0_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_addr_0            = {DBG_RANK_CTRL_MC_ADDR_0_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_state_rsm_0          = {DBG_RANK_CTRL_STATE_RSM_0_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_mceu_ctrl_state_mceu_0         = {DBG_MCEU_CTRL_STATE_MCEU_0_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_sceu_ctrl_state_sceu_0         = {DBG_SCEU_CTRL_STATE_SCEU_0_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_code_1            = {DBG_RANK_CTRL_MC_CODE_1_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_addr_1            = {DBG_RANK_CTRL_MC_ADDR_1_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_state_rsm_1          = {DBG_RANK_CTRL_STATE_RSM_1_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_mceu_ctrl_state_mceu_1         = {DBG_MCEU_CTRL_STATE_MCEU_1_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_sceu_ctrl_state_sceu_1         = {DBG_SCEU_CTRL_STATE_SCEU_1_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_code_2            = {DBG_RANK_CTRL_MC_CODE_2_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_addr_2            = {DBG_RANK_CTRL_MC_ADDR_2_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_state_rsm_2          = {DBG_RANK_CTRL_STATE_RSM_2_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_mceu_ctrl_state_mceu_2         = {DBG_MCEU_CTRL_STATE_MCEU_2_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_sceu_ctrl_state_sceu_2         = {DBG_SCEU_CTRL_STATE_SCEU_2_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_code_3            = {DBG_RANK_CTRL_MC_CODE_3_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_mc_addr_3            = {DBG_RANK_CTRL_MC_ADDR_3_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_rank_ctrl_state_rsm_3          = {DBG_RANK_CTRL_STATE_RSM_3_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_mceu_ctrl_state_mceu_3         = {DBG_MCEU_CTRL_STATE_MCEU_3_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_sceu_ctrl_state_sceu_3         = {DBG_SCEU_CTRL_STATE_SCEU_3_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_hw_lp_state_hsm                = {DBG_HW_LP_STATE_HSM_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_dfi_lp_ctrl_ack                = 1'b0;
assign                         ddrc_reg_dbg_dfi_lp_data_ack                = 1'b0;
assign                         ddrc_reg_dbg_dfi_lp_state_dsm               = {DBG_DFI_LP_STATE_DSM_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_capar_retry_mc_code            = {DBG_CAPAR_RETRY_MC_CODE_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_capar_retry_mc_addr            = {DBG_CAPAR_RETRY_MC_ADDR_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_capar_retry_state_csm          = {DBG_CAPAR_RETRY_STATE_CSM_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_capar_retry_state_mceu         = {DBG_CAPAR_RETRY_STATE_MCEU_WIDTH{1'b0}};
assign                         ddrc_reg_dbg_capar_retry_state_sceu         = {DBG_CAPAR_RETRY_STATE_SCEU_WIDTH{1'b0}};
assign                         ddrc_reg_cmdfifo_rd_data                    = {CMDFIFO_RD_DATA_WIDTH{1'b0}};
assign                         ddrc_reg_cmdfifo_overflow                   = 1'b0;
assign                         ddrc_reg_cmdfifo_recorded_cmd_num           = {CMDFIFO_RECORDED_CMD_NUM_WIDTH{1'b0}};
assign                         ddrc_reg_cmdfifo_window_cmd_num             = {CMDFIFO_WINDOW_CMD_NUM_WIDTH{1'b0}};

assign ih_wu_wr_eapar    = {`DDRCTL_EAPAR_SIZE{1'b0}};

//------------------------------------------------------------------------------
// Wires
//------------------------------------------------------------------------------


wire                              gs_pi_init_in_progress;

wire [PAGE_BITS-1:0]              ts_act_page;

// if sdram mode, then burst8_rdwr is set even though BL=4
// for ddr, it gets the real value from the register
wire [3:0]                        reg_ddrc_burst_rdwr_int;
assign  reg_ddrc_burst_rdwr_int = (reg_ddrc_frequency_ratio) ? reg_ddrc_burst_rdwr >> 2 : reg_ddrc_burst_rdwr >> 1;


wire  [CORE_ADDR_INT_WIDTH-1:0]   hif_cmd_addr_w;
generate
    if (CORE_ADDR_INT_WIDTH > CORE_ADDR_WIDTH) begin: ADDR_INT_WIDTH_GT_ADDR_WIDTH
        assign hif_cmd_addr_w = {{(CORE_ADDR_INT_WIDTH - CORE_ADDR_WIDTH){1'b0}}, hif_cmd_addr};
    end
    else begin: nADDR_INT_WIDTH_GT_ADDR_WIDTH
        assign hif_cmd_addr_w = hif_cmd_addr[CORE_ADDR_INT_WIDTH-1:0];
    end
endgenerate



wire    [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    ddrc_phy_cs;

//--------------------------------------------------------------
//---------------- DDRC -> PHY Interface -----------------------
//--------------------------------------------------------------

wire                  dfi_phyupd_ack_int;     // DFI PHY update acknowledge
wire                  phy_dfi_phyupd_req;
wire                  phy_dfi_init_complete;

wire                  dfi_phymstr_ack_int; // PHY Master acknowledge

wire                                    ddrc_dfi_ctrlupd_req;
wire    [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    ddrc_phy_cke;
wire    [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    ddrc_phy_csn = ddrc_phy_cs;
wire    [`MEMC_FREQ_RATIO-1:0]          ddrc_phy_rasn;
wire    [`MEMC_FREQ_RATIO-1:0]          ddrc_phy_casn;
wire    [`MEMC_FREQ_RATIO-1:0]          ddrc_phy_wen;
wire    [`MEMC_FREQ_RATIO*BANK_BITS-1:0]    ddrc_phy_ba;
wire    [`MEMC_FREQ_RATIO*PHY_ADDR_BITS-1:0]    ddrc_phy_addr;

wire    [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    ddrc_phy_odt;

wire    [`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES-1:0]    ddrc_phy_wrdata_cs_n;
wire    [`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES-1:0]    ddrc_phy_rddata_cs_n;

wire                                    ddrc_phy_stop_clk;      // stop the clock to DRAM in the subsequent cycle
wire                                    pi_gs_stop_clk_early;
wire    [1:0]                           pi_gs_stop_clk_type;

wire    [`MEMC_FREQ_RATIO-1:0]              ddrc_phy_dram_rst_n;


wire i_reg_ddrc_derate_mr4_pause_fc = reg_ddrc_derate_mr4_pause_fc;


//At this stage, dfi_freq_fsp is not considered HWFFC
assign dfi_freq_fsp = reg_ddrc_dfi_freq_fsp;


//--------------------------------------------------------------
//---------------- BM Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- GS -> BM Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- BS -> BM Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- IH Interface --------------------------
//--------------------------------------------------------------
wire                                                    ih_gs_rdlow_empty;
wire                                                    ih_gs_rdhigh_empty;



//--------------------------------------------------------------
//---------------- GS -> IH Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- BE Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- GS -> BE Interface --------------------------
//--------------------------------------------------------------
wire                                                    gs_be_op_is_activate;
wire                                                    gs_be_op_is_precharge;
wire                                                    gs_be_op_is_rdwr;
wire     [BSM_BITS-1:0]                                 gs_be_rdwr_bsm_num;
wire     [BSM_BITS-1:0]                                 gs_be_act_bsm_num;
wire     [BSM_BITS-1:0]                                 gs_be_pre_bsm_num;

//--------------------------------------------------------------
//---------------- BS -> BE Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- TE Interface --------------------------
//--------------------------------------------------------------
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_rd_page_hit;
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_rd_valid;
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_wr_page_hit;
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_wr_valid;
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_rd_bank_page_hit;
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_wr_bank_page_hit;
wire     [NUM_TOTAL_BSMS-1:0]                           te_bs_rd_hi;
wire     [NUM_TOTAL_BSMS*RD_CAM_ADDR_WIDTH-1:0]         te_os_rd_entry_table;
wire     [NUM_TOTAL_BSMS*WR_CAM_ADDR_WIDTH_IE-1:0]      te_os_wr_entry_table;
wire     [NUM_TOTAL_BSMS*PAGE_BITS-1:0]                 te_os_rd_page_table;
wire     [NUM_TOTAL_BSMS*PAGE_BITS-1:0]                 te_os_wr_page_table;
wire     [NUM_TOTAL_BSMS*AUTOPRE_BITS-1:0]              te_os_rd_cmd_autopre_table;
wire     [NUM_TOTAL_BSMS*AUTOPRE_BITS-1:0]              te_os_wr_cmd_autopre_table;
wire     [NUM_TOTAL_BSMS-1:0]                           te_os_rd_pageclose_autopre;
wire     [NUM_TOTAL_BSMS-1:0]                           te_os_wr_pageclose_autopre;
wire     [NUM_TOTAL_BSMS*CMD_LEN_BITS-1:0]              te_os_rd_length_table;
wire     [NUM_TOTAL_BSMS*WORD_BITS-1:0]                 te_os_rd_critical_word_table;
wire     [NUM_TOTAL_BSMS-1:0]                           te_os_mwr_table;
wire     [NUM_TOTAL_BSMS-1:0]                           te_b3_bit;
wire     [NUM_TOTAL_BSMS*PARTIAL_WR_BITS_LOG2-1:0]      te_os_wr_mr_ram_raddr_lsb_first_table;
wire     [NUM_TOTAL_BSMS*PW_WORD_CNT_WD_MAX-1:0]        te_os_wr_mr_pw_num_beats_m1_table;
wire     [BSM_BITS-1:0]                                 te_os_hi_bsm_hint;
wire     [BSM_BITS-1:0]                                 te_os_lo_bsm_hint;
wire     [BSM_BITS-1:0]                                 te_os_wr_bsm_hint;
wire     [BSM_BITS-1:0]                                 te_os_lo_act_bsm_hint;
wire     [BSM_BITS-1:0]                                 te_os_wr_act_bsm_hint;
wire                                                    te_gs_rd_flush;
wire                                                    te_gs_wr_flush;
wire                                                    te_gs_block_wr;
wire                                                    te_gs_any_rd_pending;
wire                                                    te_gs_any_wr_pending;
wire     [NUM_LRANKS-1:0]                               te_gs_rank_wr_pending;
wire     [NUM_LRANKS-1:0]                               te_gs_rank_rd_pending;
wire     [NUM_TOTAL_BANKS-1:0]                          te_gs_bank_wr_pending;
wire     [NUM_TOTAL_BANKS-1:0]                          te_gs_bank_rd_pending;
wire     [BLK_BITS-1:0]                                 te_pi_rd_addr_blk;
wire     [CORE_TAG_WIDTH-1:0]                           te_pi_rd_tag;
wire     [RMW_TYPE_BITS-1:0]                            te_pi_rd_rmw_type;
wire     [WR_CAM_ADDR_WIDTH-1:0]                        te_pi_rd_link_addr;
wire                                                    te_pi_rd_addr_err;
wire     [BLK_BITS-1:0]                                 te_pi_wr_addr_blk;

//--------------------------------------------------------------
//---------------- BS -> BE Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- GS -> TE Interface --------------------------
//--------------------------------------------------------------
wire                                                    gs_te_op_is_rd;
wire                                                    gs_te_op_is_wr;
wire                                                    gs_te_op_is_activate;
wire                                                    gs_te_op_is_precharge;
wire     [BSM_BITS-1:0]                                 gs_te_bsm_num4pre;
wire     [BSM_BITS-1:0]                                 gs_te_bsm_num4rdwr;
wire     [BSM_BITS-1:0]                                 gs_te_bsm_num4act;
`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
    wire [CMD_LEN_BITS-1:0]                                 gs_te_rd_length;
    wire [WORD_BITS-1:0]                                    gs_te_rd_word;
      wire [PARTIAL_WR_BITS_LOG2-1:0]                         gs_te_raddr_lsb_first;
        wire [PW_WORD_CNT_WD_MAX-1:0]                           gs_te_pw_num_beats_m1;
  `endif //SYNTHESIS
`endif //SNPS_ASSERT
wire                                                    gs_te_wr_mode;
wire     [NUM_TOTAL_BSMS-1:0]                           gs_te_wr_possible;
wire                                                    gs_te_pri_level;

//--------------------------------------------------------------
//---------------- OS -> TE Interface --------------------------
//--------------------------------------------------------------
wire     [MAX_CAM_ADDR_WIDTH-1:0]                       os_te_rdwr_entry;

//--------------------------------------------------------------
//---------------- BE -> OS Interface --------------------------
//--------------------------------------------------------------
// Optimization for decoding read/write page number by passing it through the OS selection network
wire    [NUM_TOTAL_BSMS*PAGE_BITS-1:0]  be_os_page_table; // all pages of page table concatenated

//--------------------------------------------------------------
//---------------- BE -> TE Interface --------------------------
//--------------------------------------------------------------
wire                                    be_te_page_hit;

//--------------------------------------------------------------
//---------------- IH -> BE Interface --------------------------
//--------------------------------------------------------------
wire    [BG_BANK_BITS-1:0]              ih_yy_bg_bank_num_rd; // to BE and PI for bypass
wire    [PAGE_BITS -1:0]                ih_be_page_num;

//--------------------------------------------------------------
//---------------- IH -> BE Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- IH -> TE Interface --------------------------
//--------------------------------------------------------------
wire                                    ih_yy_wr_valid;         // Goes to TE
wire                                    ih_te_rd_valid_no_addrerr;  // ih_te_rd_valid, excluding RMW with address error
wire                                    ih_yy_wr_valid_no_addrerr;  // ih_te_wr_valid, excluding WR/RMW with address error
wire                                    ih_te_rd_valid_addr_err;    // address error associated with ih_te_rd_valid. For both RD/RMW
wire                                    ih_yy_wr_valid_addr_err;    // address error associated with ih_te_wr_valid. For both WR/RMW
wire                                    ih_yy_rd_addr_err;          // If 1, RD (not RMW) is associated with address error
wire    [CORE_TAG_WIDTH-1:0]            ih_te_rd_tag;
wire    [RMW_TYPE_BITS-1:0]             ih_yy_rmw_type;         // read-mod-write type
                                                                //  (partial write, scrub, atomic RMW, none)
wire    [WR_CAM_ADDR_WIDTH_IE-1:0]      ih_yy_wr_entry;         // Goes to TE & WU

//--------------------------------------------------------------
//---------------- IH - TS Interface --------------------------
//--------------------------------------------------------------
wire                                    ih_yy_xact_valid;
wire                                    ih_gs_wr_empty;         //not used in cpe

//--------------------------------------------------------------
//---------------- PI -> TS Interface --------------------------
//--------------------------------------------------------------
wire                                    pi_gs_ctrlupd_ok;
wire                                    pi_gs_phyupd_pause_ok;
wire                                    pi_gs_noxact;
wire                                    pi_gs_rd_vld;

//--------------------------------------------------------------
//---------------- PI -> GS Interface --------------------------
//--------------------------------------------------------------



//--------------------------------------------------------------
//---------------- TE -> IH Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- TE -> TS Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- TE -> DH Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- TE -> PI Interface --------------------------
//--------------------------------------------------------------
wire [WORD_BITS-1:0] te_pi_wr_word;

assign te_pi_wr_word[1:0] = 2'b00;
assign te_pi_wr_word[WORD_BITS-1:WORD_BITS-2] = 2'b00;

//--------------------------------------------------------------
//---------------- TE -> TS Interface --------------------------
//--------------------------------------------------------------

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
wire [WR_CAM_ENTRIES_IE-1:0]            te_ts_wr_entry_valid; // valid write entry in CAM, over entire CAM
wire [WR_CAM_ENTRIES-1:0]               te_ts_rd_entry_valid; // valid read entry in CAM, over entire CAM
wire [WR_CAM_ENTRIES_IE-1:0]            te_ts_wr_page_hit_entries; // page-hit entry in CAM
wire [RD_CAM_ENTRIES-1:0]               te_ts_rd_page_hit_entries;
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

//--------------------------------------------------------------
//---------------- TE -> DBG Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- TS -> IH Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- TS -> DH Interface --------------------------
//--------------------------------------------------------------
wire    [4:0]                           gs_dh_init_curr_state;
wire    [4:0]                           gs_dh_init_next_state;

wire    [1:0]                           gs_dh_ctrlupd_state;

wire    [1:0]                           gs_dh_hpr_q_state;
wire    [1:0]                           gs_dh_lpr_q_state;
wire    [1:0]                           gs_dh_w_q_state;


//--------------------------------------------------------------
//---------------- TS -> TE Interface --------------------------
//--------------------------------------------------------------
wire                                    ts_te_autopre;

//--------------------------------------------------------------
//---------------- TS -> PI Interface --------------------------
//--------------------------------------------------------------
wire                                    gs_pi_ctrlupd_req;
wire                                    gs_pi_phyupd_pause_req;
wire                                    gs_pi_dfi_lp_changing;
wire                                    gs_pi_rd_data_pipeline_empty;
wire                                    gs_pi_wr_data_pipeline_empty;
wire                                    gs_pi_init_cke;
wire                                    gs_pi_op_is_load_mode;
wire    [MRS_BA_BITS-1:0]               gs_pi_mrs_ba;
wire    [MRS_A_BITS-1:0]                gs_pi_mrs_a;
wire    [MAX_CMD_NUM*BANK_BITS-1:0]     gs_pi_bank_num;
wire                                    gs_pi_op_is_rd;
//wire                                    gs_pi_op_is_exit_powerdown;


wire                                    gs_pi_dram_rst_n;
wire    [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]  gs_pi_odt;              // per-rank ODT enables
wire                                    gs_pi_odt_pending;          // waiting for the ODT command to complete
wire    [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0]  gs_pi_wrdata_cs_n;      // per-rank WR Data CS_N
wire    [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0]  gs_pi_rddata_cs_n;      // per-rank RD Data CS_N
wire                                    gs_pi_pads_powerdown_unused;
wire                                    gs_pi_pads_selfref_unused;
wire                                    gs_pi_op_is_enter_sr_lpddr4;         // enter lpddr4 self-refresh mode
wire                                    gs_pi_op_is_exit_sr_lpddr4;          // exit lpddr4 self-refresh mode
wire                                    gs_pi_stop_clk_ok;      // stop the clock during self refresh
wire [1:0]                              gs_pi_stop_clk_type;



wire                                    clock_gating_en_int_unused;


//--------------------------------------------------------------
//---------------- Derate -> TS Interface --------------------------
//--------------------------------------------------------------
wire                                    derate_refresh_update_level;


//--------------------------------------------------------------
//------------- PI -> DP Interface ___--------------------------
//--------------------------------------------------------------
wire    [RANKBANK_BITS_FULL_DDRC-1:0]           pi_dp_rankbank_num;






wire   [NUM_TOTAL_BSMS-1:0]                         ts_te_sel_act_wr;         //tell TE the activate command is for write or read.
wire   [NUM_TOTAL_BSMS-1:0]                         te_rws_wr_col_bank;                     // entry of colliding bank (1bit for 1bank)
wire   [NUM_TOTAL_BSMS-1:0]                         te_rws_rd_col_bank;                     // entry of colliding bank (1bit for 1bank)
wire   [WR_CAM_ADDR_WIDTH_IE:0]                     te_num_wr_pghit_entries;
wire   [RD_CAM_ADDR_WIDTH:0]                        te_num_rd_pghit_entries;
wire   [WR_CAM_ADDR_WIDTH:0]                        te_wr_entry_avail;                      // Number of non-valid entries (WRCAM only, not include WRECC CAM)


//--------------------------------------------------------------
//---------------- REG -> PAS_CPE/DDRC_CPE --------------------
//--------------------------------------------------------------
logic  [NUM_LRANKS_DDRC-1:0]                        reg_ddrc_cpe_rank_refresh;






assign reg_ddrc_cpe_rank_refresh       = reg_ddrc_rank_refresh[NUM_LRANKS_DDRC-1:0];


//--------------------------------------------------------------
//---------------- DDRC_CPE -> REG  --------------------------
//--------------------------------------------------------------
logic  [NUM_LRANKS_DDRC-1:0]                        ddrc_rank_refresh_busy;
logic                                               ddrc_wr_data_pipeline_empty;
logic                                               ddrc_rd_data_pipeline_empty;
logic                                               ddrc_data_pipeline_empty;


logic                                               ddrc_mrr_op_on;


logic  [2:0]                                        ddrc_operating_mode;
logic  [SELFREF_TYPE_WIDTH-1:0]                     ddrc_selfref_type;

logic                                               ddrc_cactive_ddrc;
logic                                               ddrc_csysack_ddrc;




wire   gsfsm_sr_co_if_stall;


wire   ih_fifo_wr_empty;
wire   ih_fifo_rd_empty;

assign pi_rt_rankbank_num  = {{(RANKBANK_BITS_FULL-RANKBANK_BITS_FULL_DDRC){1'b0}},pi_dp_rankbank_num};

assign ddrc_reg_wr_q_empty =
                             gs_pi_wr_data_pipeline_empty && ih_fifo_wr_empty && dfi_wr_q_empty && ih_gs_wr_empty
;

assign ddrc_reg_rd_q_empty =
                             gs_pi_rd_data_pipeline_empty && ih_fifo_rd_empty && rt_gs_empty_delayed && ih_gs_rdlow_empty
                            && ih_gs_rdhigh_empty
                             ;

assign ddrc_reg_wr_data_pipeline_empty = gs_pi_wr_data_pipeline_empty;
assign ddrc_reg_rd_data_pipeline_empty = gs_pi_rd_data_pipeline_empty;

// Indicates that queue is not empty
assign  hif_cmd_q_not_empty = te_gs_any_wr_pending || te_gs_any_rd_pending;

//------------------------------------------------------------------------------
// Logic that determines how much delay to be introduced on the DFI command path
//------------------------------------------------------------------------------



// Discard RMWs with address error
assign ih_te_rd_valid_no_addrerr = (ih_te_rd_valid_addr_err & ih_yy_wr_valid_addr_err & (ih_yy_rmw_type == `MEMC_RMW_TYPE_PARTIAL_NBW)) ? 1'b0 : ih_te_rd_valid;

// Discard WRs with address error
assign ih_yy_wr_valid_no_addrerr = (ih_yy_wr_valid_addr_err) ? 1'b0 : ih_yy_wr_valid;

assign ih_wu_wr_valid_addr_err = ih_yy_wr_valid_addr_err;

// Mark RDs (not RMW) with address error. This is used to assert hif_rdata_addr_err
assign ih_yy_rd_addr_err = ih_te_rd_valid_addr_err & (ih_yy_rmw_type == `MEMC_RMW_TYPE_NO_RMW);
assign ih_te_wr_valid = ih_yy_wr_valid;
assign ih_wu_rmw_type = ih_yy_rmw_type;
assign ih_wu_wr_entry = ih_yy_wr_entry[WR_CAM_ADDR_WIDTH-1:0];

// get rid of this later - all modules that uses ddrc2006 have to be updated together for this


wire [OTHER_WR_ENTRY_BITS-1:0] ih_te_wr_other_fields;
assign ih_te_wr_other_fields = ih_yy_rmw_type;

// status signal used for HW pin
assign stat_ddrc_reg_selfref_type = ddrc_reg_selfref_type;


dwc_ddrctl_ddrc_cpf
 #(
            //parameters for ih_inst.v
             .RANK_BITS                                  (RANK_BITS                                   )
            ,.CMD_TYPE_BITS                              (CMD_TYPE_BITS                               )
            ,.NUM_TOTAL_BANKS                            (NUM_TOTAL_BANKS                             )
            ,.PARTIAL_WR_BITS                            (PARTIAL_WR_BITS                             )
            ,.PARTIAL_WR_BITS_LOG2                       (PARTIAL_WR_BITS_LOG2                        )
            ,.PW_NUM_DB                                  (PW_NUM_DB                                   )
            ,.PW_FACTOR_HBW                              (PW_FACTOR_HBW                               )
            ,.PW_WORD_VALID_WD_HBW                       (PW_WORD_VALID_WD_HBW                        )
            ,.PW_WORD_VALID_WD_MAX                       (PW_WORD_VALID_WD_MAX                        )
            ,.PW_WORD_CNT_WD_MAX                         (PW_WORD_CNT_WD_MAX                          )
            ,.PW_BC_SEL_BITS                             (PW_BC_SEL_BITS                              )
            ,.NUM_TOTAL_BSMS                             (NUM_TOTAL_BSMS                              )
            ,.BSM_BITS                                   (BSM_BITS                                    )
            ,.NUM_LRANKS                                 (NUM_LRANKS                                  )

            ,.CORE_ADDR_INT_WIDTH                        (CORE_ADDR_INT_WIDTH                         )
            ,.CORE_TAG_WIDTH                             (CORE_TAG_WIDTH                              )
            ,.CMD_LEN_BITS                               (CMD_LEN_BITS                                )
            ,.WR_CAM_ADDR_WIDTH                          (WR_CAM_ADDR_WIDTH                           )
            ,.WR_ECC_CAM_ADDR_WIDTH                      (WR_ECC_CAM_ADDR_WIDTH                       )
            ,.WR_CAM_ADDR_WIDTH_IE                       (WR_CAM_ADDR_WIDTH_IE                        )
            ,.RD_CAM_ADDR_WIDTH                          (RD_CAM_ADDR_WIDTH                           )
            ,.RMW_TYPE_BITS                              (RMW_TYPE_BITS                               )
            ,.WRDATA_CYCLES                              (WRDATA_CYCLES                               )
            ,.NO_OF_BT                                   (NO_OF_BT                                    )
            ,.BT_BITS                                    (BT_BITS                                     )
            ,.IE_BURST_NUM_BITS                          (IE_BURST_NUM_BITS                           )
            ,.IE_RD_TYPE_BITS                            (IE_RD_TYPE_BITS                             )
            ,.WDATA_PTR_BITS                             (WDATA_PTR_BITS                              )
            ,.MWR_BITS                                   (MWR_BITS                                    )
            ,.CHANNEL_NUM                                (CHANNEL_NUM                                 )
            ,.LRANK_BITS                                 (LRANK_BITS                                  )
            ,.BANK_BITS                                  (BANK_BITS                                   )
            ,.PAGE_BITS                                  (PAGE_BITS                                   )
            ,.BLK_BITS                                   (BLK_BITS                                    )
            ,.OTHER_WR_ENTRY_BITS                        (OTHER_WR_ENTRY_BITS                         )
            ,.WORD_BITS                                  (WORD_BITS                                   )
            ,.ECCAP_BITS                                 (ECCAP_BITS                                  )
            ,.IE_TAG_BITS                                (IE_TAG_BITS                                 )
            ,.AUTOPRE_BITS                               (AUTOPRE_BITS                                )
            ,.OTHER_RD_ENTRY_BITS                        (OTHER_RD_ENTRY_BITS                         )
            ,.MAX_CAM_ADDR_WIDTH                         (MAX_CAM_ADDR_WIDTH                          )
            ,.RD_CAM_ENTRIES                             (RD_CAM_ENTRIES                              )
            ,.WR_CAM_ENTRIES                             (WR_CAM_ENTRIES                              )
            ,.WR_CAM_ENTRIES_IE                          (WR_CAM_ENTRIES_IE                           )
            ,.WR_ECC_CAM_ENTRIES                         (WR_ECC_CAM_ENTRIES                          )
            ,.RETRY_FIFO_DEPTH                           (RETRY_FIFO_DEPTH                            )
            ,.RETRY_TIMES_WIDTH                          (0)
            ,.ENTRY_RETRY_TIMES_WIDTH                    (0) //only for special format in teengine
            ,.RETRY_WR_BITS                              (0)
            ,.RETRY_RD_BITS                              (0)

            ,.BG_BANK_BITS                               (BG_BANK_BITS                                )
            ,.BG_BITS                                    (BG_BITS                                     )
            ,.NUM_OF_BG                                  (1<< BG_BITS                                 )
            ,.RANKBANK_BITS                              (RANKBANK_BITS                               )
            ,.DDR4_COL3_BITS                             (DDR4_COL3_BITS                              )
            ,.AM_DCH_WIDTH                               (AM_DCH_WIDTH                                )
            ,.AM_CS_WIDTH                                (AM_CS_WIDTH                                 )
            ,.AM_CID_WIDTH                               (AM_CID_WIDTH                                )
            ,.AM_BANK_WIDTH                              (AM_BANK_WIDTH                               )
            ,.AM_BG_WIDTH                                (AM_BG_WIDTH                                 )
            ,.AM_ROW_WIDTH                               (AM_ROW_WIDTH                                )
            ,.AM_COL_WIDTH_H                             (AM_COL_WIDTH_H                              )
            ,.AM_COL_WIDTH_L                             (AM_COL_WIDTH_L                              )

            )
U_ddrc_cpf(
             .core_ddrc_core_clk                         (core_ddrc_core_clk                          )
            ,.core_ddrc_rstn                             (core_ddrc_rstn                              )
            ,.ddrc_cg_en                                 (ddrc_cg_en                                  )

            ,.ih_gs_rdlow_empty                          (ih_gs_rdlow_empty                           )
            ,.ih_gs_rdhigh_empty                         (ih_gs_rdhigh_empty                          )



            ,.gs_be_op_is_activate                       (gs_be_op_is_activate                        )
            ,.gs_be_op_is_precharge                      (gs_be_op_is_precharge                       )
            ,.gs_be_op_is_rdwr                           (gs_be_op_is_rdwr                            )
            ,.gs_be_rdwr_bsm_num                         (gs_be_rdwr_bsm_num                          )
            ,.gs_be_act_bsm_num                          (gs_be_act_bsm_num                           )
            ,.gs_be_pre_bsm_num                          (gs_be_pre_bsm_num                           )


            ,.te_bs_rd_page_hit                          (te_bs_rd_page_hit                           )
            ,.te_bs_rd_valid                             (te_bs_rd_valid                              )
            ,.te_bs_wr_page_hit                          (te_bs_wr_page_hit                           )
            ,.te_bs_wr_valid                             (te_bs_wr_valid                              )
            ,.te_bs_rd_bank_page_hit                     (te_bs_rd_bank_page_hit                      )
            ,.te_bs_wr_bank_page_hit                     (te_bs_wr_bank_page_hit                      )
            ,.te_bs_rd_hi                                (te_bs_rd_hi                                 )
            ,.te_os_rd_entry_table                       (te_os_rd_entry_table                        )
            ,.te_os_wr_entry_table                       (te_os_wr_entry_table                        )
            ,.te_os_rd_page_table                        (te_os_rd_page_table                         )
            ,.te_os_wr_page_table                        (te_os_wr_page_table                         )
            ,.te_os_rd_cmd_autopre_table                 (te_os_rd_cmd_autopre_table                  )
            ,.te_os_wr_cmd_autopre_table                 (te_os_wr_cmd_autopre_table                  )
            ,.te_os_rd_pageclose_autopre                 (te_os_rd_pageclose_autopre                  )
            ,.te_os_wr_pageclose_autopre                 (te_os_wr_pageclose_autopre                  )
            ,.te_os_rd_length_table                      (te_os_rd_length_table                       )
            ,.te_os_rd_critical_word_table               (te_os_rd_critical_word_table                )
            ,.te_os_mwr_table                            (te_os_mwr_table                             )
            ,.te_b3_bit                                  (te_b3_bit                                   )
            ,.te_os_wr_mr_ram_raddr_lsb_first_table      (te_os_wr_mr_ram_raddr_lsb_first_table       )
            ,.te_os_wr_mr_pw_num_beats_m1_table          (te_os_wr_mr_pw_num_beats_m1_table           )
            ,.te_os_hi_bsm_hint                          (te_os_hi_bsm_hint                           )
            ,.te_os_lo_bsm_hint                          (te_os_lo_bsm_hint                           )
            ,.te_os_wr_bsm_hint                          (te_os_wr_bsm_hint                           )
            ,.te_os_lo_act_bsm_hint                      (te_os_lo_act_bsm_hint                       )
            ,.te_os_wr_act_bsm_hint                      (te_os_wr_act_bsm_hint                       )
            ,.te_gs_rd_flush                             (te_gs_rd_flush                              )
            ,.te_gs_wr_flush                             (te_gs_wr_flush                              )
            ,.te_gs_block_wr                             (te_gs_block_wr                              )
            ,.te_gs_any_rd_pending                       (te_gs_any_rd_pending                        )
            ,.te_gs_any_wr_pending                       (te_gs_any_wr_pending                        )
            ,.te_gs_rank_wr_pending                      (te_gs_rank_wr_pending                       )
            ,.te_gs_rank_rd_pending                      (te_gs_rank_rd_pending                       )
            ,.te_gs_bank_wr_pending                      (te_gs_bank_wr_pending                       )
            ,.te_gs_bank_rd_pending                      (te_gs_bank_rd_pending                       )
            ,.te_pi_rd_addr_blk                          (te_pi_rd_addr_blk                           )
            ,.te_pi_rd_tag                               (te_pi_rd_tag                                )
            ,.te_pi_rd_rmw_type                          (te_pi_rd_rmw_type                           )
            ,.te_pi_rd_link_addr                         (te_pi_rd_link_addr                          )
            ,.te_pi_rd_addr_err                          (te_pi_rd_addr_err                           )
            ,.te_pi_wr_addr_blk                          (te_pi_wr_addr_blk                           )



            ,.gs_te_op_is_rd                             (gs_te_op_is_rd                              )
            ,.gs_te_op_is_wr                             (gs_te_op_is_wr                              )
            ,.gs_te_op_is_activate                       (gs_te_op_is_activate                        )
            ,.gs_te_op_is_precharge                      (gs_te_op_is_precharge                       )
            ,.gs_te_bsm_num4pre                          (gs_te_bsm_num4pre                           )
            ,.gs_te_bsm_num4rdwr                         (gs_te_bsm_num4rdwr                          )
            ,.gs_te_bsm_num4act                          (gs_te_bsm_num4act                           )


`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
            ,.gs_te_rd_length                            (gs_te_rd_length                             )
            ,.gs_te_rd_word                              (gs_te_rd_word                               )
            ,.gs_te_raddr_lsb_first                      (gs_te_raddr_lsb_first                       )
            ,.gs_te_pw_num_beats_m1                      (gs_te_pw_num_beats_m1                       )
  `endif //SYNTHESIS
`endif //SNPS_ASSERT


            ,.gs_te_wr_mode                              (gs_te_wr_mode                               )
            ,.gs_te_wr_possible                          (gs_te_wr_possible                           )
            ,.gs_te_pri_level                            (gs_te_pri_level                             )

            ,.os_te_rdwr_entry                           (os_te_rdwr_entry                            )

            ,.ddrc_reg_operating_mode_w                  (ddrc_reg_operating_mode                     )
            ,.reg_ddrc_lpddr4                            (reg_ddrc_lpddr4                             )
            ,.reg_ddrc_lpddr5                            (reg_ddrc_lpddr5                             )
            ,.reg_ddrc_bank_org                          (reg_ddrc_bank_org                           )
            ,.reg_ddrc_nonbinary_device_density          (reg_ddrc_nonbinary_device_density           )
            ,.reg_ddrc_dis_hif                           (reg_ddrc_dis_hif                            )
            ,.hif_cmd_valid                              (hif_cmd_valid                               )
            ,.hif_cmd_type                               (hif_cmd_type                                )
            ,.hif_cmd_pri                                (hif_cmd_pri                                 )
            ,.hif_cmd_addr                               (hif_cmd_addr_w                              )
            ,.hif_cmd_length                             (hif_cmd_length                              )
            ,.hif_cmd_token                              (hif_cmd_token                               )
            ,.hif_cmd_wdata_ptr                          (hif_cmd_wdata_ptr                           )
            ,.hif_cmd_autopre                            (hif_cmd_autopre                             )
            ,.gsfsm_sr_co_if_stall                       (gsfsm_sr_co_if_stall                        )
            ,.hif_cmd_stall                              (hif_cmd_stall                               )
            ,.ih_busy                                    (ih_busy                                     )
            ,.ih_fifo_rd_empty                           (ih_fifo_rd_empty                            )
            ,.ih_fifo_wr_empty                           (ih_fifo_wr_empty                            )
            ,.hif_wdata_ptr                              (hif_wdata_ptr                               )
            ,.hif_wdata_ptr_valid                        (hif_wdata_ptr_valid                         )
            ,.hif_wdata_ptr_addr_err                     (hif_wdata_ptr_addr_err                      )
            ,.hif_wr_credit                              (hif_wr_credit                               )
            ,.hif_lpr_credit                             (hif_lpr_credit                              )
            ,.hif_hpr_credit                             (hif_hpr_credit                              )
            ,.reg_ddrc_lpr_num_entries_changed           (reg_ddrc_lpr_num_entries_changed            )
            ,.wu_ih_flow_cntrl_req                       (wu_ih_flow_cntrl_req                        )
            ,.ih_te_rd_valid                             (ih_te_rd_valid                              )
            ,.ih_yy_wr_valid                             (ih_yy_wr_valid                              )
            ,.ih_wu_wr_valid                             (ih_wu_wr_valid                              )
            ,.ih_te_rd_valid_addr_err                    (ih_te_rd_valid_addr_err                     )
            ,.ih_yy_wr_valid_addr_err                    (ih_yy_wr_valid_addr_err                     )
            ,.ih_yy_rmw_type                             (ih_yy_rmw_type                              )
            ,.ih_yy_wr_entry                             (ih_yy_wr_entry                              )
            ,.ih_wu_critical_word                        (ih_wu_critical_word                         )
            ,.mr_yy_free_wr_entry                        (mr_yy_free_wr_entry                         )
            ,.mr_yy_free_wr_entry_valid                  (mr_yy_free_wr_entry_valid)
            ,.te_yy_wr_combine                           (te_yy_wr_combine                            )
            ,.ih_yy_xact_valid                           (ih_yy_xact_valid                            )
            ,.ih_gs_wr_empty                             (ih_gs_wr_empty                              )
            ,.reg_ddrc_lpr_num_entries                   (reg_ddrc_lpr_num_entries                    )
            ,.reg_ddrc_addrmap_bank_b0                   (reg_ddrc_addrmap_bank_b0                    )
            ,.reg_ddrc_addrmap_bank_b1                   (reg_ddrc_addrmap_bank_b1                    )
            ,.reg_ddrc_addrmap_bank_b2                   (reg_ddrc_addrmap_bank_b2                    )
            ,.reg_ddrc_addrmap_bg_b0                     (reg_ddrc_addrmap_bg_b0                      )
            ,.reg_ddrc_addrmap_bg_b1                     (reg_ddrc_addrmap_bg_b1                      )
            ,.reg_ddrc_addrmap_col_b3                    (reg_ddrc_addrmap_col_b3                     )
            ,.reg_ddrc_addrmap_col_b4                    (reg_ddrc_addrmap_col_b4                     )
            ,.reg_ddrc_addrmap_col_b5                    (reg_ddrc_addrmap_col_b5                     )
            ,.reg_ddrc_addrmap_col_b6                    (reg_ddrc_addrmap_col_b6                     )
            ,.reg_ddrc_addrmap_col_b7                    (reg_ddrc_addrmap_col_b7                     )
            ,.reg_ddrc_addrmap_col_b8                    (reg_ddrc_addrmap_col_b8                     )
            ,.reg_ddrc_addrmap_col_b9                    (reg_ddrc_addrmap_col_b9                     )
            ,.reg_ddrc_addrmap_col_b10                   (reg_ddrc_addrmap_col_b10                    )
            ,.reg_ddrc_addrmap_row_b0                    (reg_ddrc_addrmap_row_b0                     )
            ,.reg_ddrc_addrmap_row_b1                    (reg_ddrc_addrmap_row_b1                     )
            ,.reg_ddrc_addrmap_row_b2                    (reg_ddrc_addrmap_row_b2                     )
            ,.reg_ddrc_addrmap_row_b3                    (reg_ddrc_addrmap_row_b3                     )
            ,.reg_ddrc_addrmap_row_b4                    (reg_ddrc_addrmap_row_b4                     )
            ,.reg_ddrc_addrmap_row_b5                    (reg_ddrc_addrmap_row_b5                     )
            ,.reg_ddrc_addrmap_row_b6                    (reg_ddrc_addrmap_row_b6                     )
            ,.reg_ddrc_addrmap_row_b7                    (reg_ddrc_addrmap_row_b7                     )
            ,.reg_ddrc_addrmap_row_b8                    (reg_ddrc_addrmap_row_b8                     )
            ,.reg_ddrc_addrmap_row_b9                    (reg_ddrc_addrmap_row_b9                     )
            ,.reg_ddrc_addrmap_row_b10                   (reg_ddrc_addrmap_row_b10                    )
            ,.reg_ddrc_addrmap_row_b11                   (reg_ddrc_addrmap_row_b11                    )
            ,.reg_ddrc_addrmap_row_b12                   (reg_ddrc_addrmap_row_b12                    )
            ,.reg_ddrc_addrmap_row_b13                   (reg_ddrc_addrmap_row_b13                    )
            ,.reg_ddrc_addrmap_row_b14                   (reg_ddrc_addrmap_row_b14                    )
            ,.reg_ddrc_addrmap_row_b15                   (reg_ddrc_addrmap_row_b15                    )
            ,.reg_ddrc_addrmap_row_b16                   (reg_ddrc_addrmap_row_b16                    )
            ,.reg_ddrc_addrmap_row_b17                   (reg_ddrc_addrmap_row_b17                    )
            ,.ddrc_reg_dbg_hpr_q_depth                   (ddrc_reg_dbg_hpr_q_depth                    )
            ,.ddrc_reg_dbg_stall                         (ddrc_reg_dbg_stall                          )
            ,.reg_ddrc_burst_rdwr                        (reg_ddrc_burst_rdwr                         )
            ,.ddrc_reg_dbg_w_q_depth                     (ddrc_reg_dbg_w_q_depth                      )
            ,.ddrc_reg_dbg_lpr_q_depth                   (ddrc_reg_dbg_lpr_q_depth                    )
            ,.reg_ddrc_frequency_ratio                   (reg_ddrc_frequency_ratio                    )

            ,.reg_ddrc_pageclose                         (reg_ddrc_pageclose                          )
            ,.reg_ddrc_pageclose_timer                   (reg_ddrc_pageclose_timer                    )
            ,.reg_ddrc_page_hit_limit_rd                 (reg_ddrc_page_hit_limit_rd                  )
            ,.reg_ddrc_page_hit_limit_wr                 (reg_ddrc_page_hit_limit_wr                  )
            ,.reg_ddrc_opt_hit_gt_hpr                    (reg_ddrc_opt_hit_gt_hpr                     )
            ,.reg_ddrc_dis_opt_ntt_by_act                (reg_ddrc_dis_opt_ntt_by_act                 )
            ,.reg_ddrc_dis_opt_ntt_by_pre                (reg_ddrc_dis_opt_ntt_by_pre                 )
            ,.reg_ddrc_autopre_rmw                       (reg_ddrc_autopre_rmw                        )
            ,.reg_ddrc_dis_wc                            (reg_ddrc_dis_wc                             )
            ,.te_dh_rd_page_hit                          (ddrc_core_reg_dbg_rd_page_hit_rank          )
            ,.te_dh_rd_valid                             (ddrc_core_reg_dbg_rd_valid_rank             )
            ,.te_dh_wr_page_hit                          (ddrc_core_reg_dbg_wr_page_hit_rank          )
            ,.te_dh_wr_valid                             (ddrc_core_reg_dbg_wr_valid_rank             )
            ,.te_dh_rd_hi                                (ddrc_core_reg_dbg_rd_pri_rank               )
            ,.ih_te_rd_valid_no_addrerr                  (ih_te_rd_valid_no_addrerr                   )
            ,.ih_yy_wr_valid_no_addrerr                  (ih_yy_wr_valid_no_addrerr                   )
            ,.ih_te_wr_other_fields                      (ih_te_wr_other_fields                       )
            ,.ih_yy_rd_addr_err                          (ih_yy_rd_addr_err                           )
            ,.wu_te_enable_wr                            (wu_te_enable_wr                             )
            ,.wu_te_entry_num                            (wu_te_entry_num                             )
            ,.wu_te_wr_word_valid                        (wu_te_wr_word_valid                         )
            ,.wu_te_ram_raddr_lsb_first                  (wu_te_ram_raddr_lsb_first                   )
            ,.wu_te_pw_num_beats_m1                      (wu_te_pw_num_beats_m1                       )
            ,.wu_te_pw_num_cols_m1                       (wu_te_pw_num_cols_m1                        )
            ,.te_mr_wr_ram_addr                          (te_mr_wr_ram_addr                           )
            ,.te_wu_entry_num                            (te_wu_entry_num                             )
            ,.wu_te_mwr                                  (wu_te_mwr                                   )
            ,.ts_te_autopre                              (ts_te_autopre                               )
            ,.te_wu_wr_retry                             (te_wu_wr_retry                              )
            ,.te_pi_wr_word_valid                        (te_pi_wr_word_valid                         )
           // ,.te_mr_pw_num_beats_m1                      (te_mr_pw_num_beats_m1                       )
            ,.ts_act_page                                (ts_act_page                                 )

            ,.ts_te_sel_act_wr                           (ts_te_sel_act_wr                            )
            ,.te_rws_wr_col_bank                         (te_rws_wr_col_bank                          )
            ,.te_rws_rd_col_bank                         (te_rws_rd_col_bank                          )
            ,.te_num_wr_pghit_entries                    (te_num_wr_pghit_entries                     )
            ,.te_num_rd_pghit_entries                    (te_num_rd_pghit_entries                     )
            ,.te_wr_entry_avail                          (te_wr_entry_avail                           )
            ,.be_os_page_table                           (be_os_page_table                            )



`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
                ,.te_ts_wr_entry_valid                   (te_ts_wr_entry_valid                        )
                ,.te_ts_rd_entry_valid                   (te_ts_rd_entry_valid                        )
                ,.te_ts_wr_page_hit_entries              (te_ts_wr_page_hit_entries                   )
                ,.te_ts_rd_page_hit_entries              (te_ts_rd_page_hit_entries                   )
                ,.reg_ddrc_data_bus_width                (reg_ddrc_data_bus_width                     )
`endif //SNPS_ASSERT_ON
`endif //SYNTHESIS




            );

logic [4:0]         ddrc_reg_dbg_mr4_byte0_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte1_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte2_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte3_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte4_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte5_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte6_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte7_rank0;
logic [4:0]         ddrc_reg_dbg_mr4_byte0_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte1_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte2_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte3_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte4_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte5_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte6_rank1;
logic [4:0]         ddrc_reg_dbg_mr4_byte7_rank1;

generate
   if((CHANNEL_NUM==0) || (`DDRCTL_DUAL_DDRC_CPE_EN==1)) begin : GEN_DDRC_CPE_EN

dwc_ddrctl_ddrc_cpe
 #(
             .CHANNEL_NUM                                (CHANNEL_NUM                                 )
            ,.SHARED_AC                                  (SHARED_AC                                   )
            ,.RANK_BITS                                  (RANK_BITS                                   )
            ,.BANK_BITS                                  (BANK_BITS                                   )
            ,.CID_WIDTH                                  (CID_WIDTH_DDRC                              )
            ,.CID_WIDTH_DUP                              (CID_WIDTH_DUP_DDRC                          )
            ,.NUM_LRANKS                                 (NUM_LRANKS_DDRC                             )
            ,.NUM_TOTAL_BANKS                            (NUM_TOTAL_BANKS_DDRC                        )
            ,.LRANK_BITS                                 (LRANK_BITS_DDRC                             )
            ,.RANKBANK_BITS                              (RANKBANK_BITS_DDRC                          )
            ,.RANKBANK_BITS_FULL                         (RANKBANK_BITS_FULL_DDRC                     )
            ,.MWR_BITS                                   (MWR_BITS                                    )
            ,.PARTIAL_WR_BITS                            (PARTIAL_WR_BITS                             )
            ,.PARTIAL_WR_BITS_LOG2                       (PARTIAL_WR_BITS_LOG2                        )
            ,.PW_NUM_DB                                  (PW_NUM_DB                                   )
            ,.PW_FACTOR_HBW                              (PW_FACTOR_HBW                               )
            ,.PW_WORD_VALID_WD_HBW                       (PW_WORD_VALID_WD_HBW                        )
            ,.PW_WORD_VALID_WD_MAX                       (PW_WORD_VALID_WD_MAX                        )
            ,.PW_WORD_CNT_WD_MAX                         (PW_WORD_CNT_WD_MAX                          )
            ,.PW_BC_SEL_BITS                             (PW_BC_SEL_BITS                              )
            ,.BCM_VERIF_EN                               (BCM_VERIF_EN                                )
            ,.BCM_DDRC_N_SYNC                            (BCM_DDRC_N_SYNC                             )
            ,.NUM_LANES                                  (NUM_LANES                                   )
            ,.AUTOPRE_BITS                               (AUTOPRE_BITS                                )
            ,.NPORTS                                     (NPORTS                                      )
            ,.A_SYNC_TABLE                               (A_SYNC_TABLE                                )
            ,.OCPAR_EN                                   (OCPAR_EN                                    )
            ,.WR_CAM_ENTRIES_IE                          (WR_CAM_ENTRIES_IE                           )
            ,.RD_CAM_ENTRIES                             (RD_CAM_ENTRIES                              )
            ,.WR_CAM_ENTRIES                             (WR_CAM_ENTRIES                              )
            ,.RD_CAM_ADDR_WIDTH                          (RD_CAM_ADDR_WIDTH                           )
            ,.WR_CAM_ADDR_WIDTH                          (WR_CAM_ADDR_WIDTH                           )
            ,.WR_CAM_ADDR_WIDTH_IE                       (WR_CAM_ADDR_WIDTH_IE                        )
            ,.MAX_CAM_ADDR_WIDTH                         (MAX_CAM_ADDR_WIDTH                          )
            ,.MAX_CMD_DELAY                              (MAX_CMD_DELAY                               )

            ,.IE_RD_TYPE_BITS                            (IE_RD_TYPE_BITS                             )
            ,.IE_WR_TYPE_BITS                            (IE_WR_TYPE_BITS                             )
            ,.IE_BURST_NUM_BITS                          (IE_BURST_NUM_BITS                           )
            ,.NO_OF_BT                                   (NO_OF_BT                                    )
            ,.BT_BITS                                    (BT_BITS                                     )
            ,.ECCAP_BITS                                 (ECCAP_BITS                                  )
            ,.IE_TAG_BITS                                (IE_TAG_BITS                                 )
            ,.CMD_DELAY_BITS                             (CMD_DELAY_BITS                              )

            ,.CMD_LEN_BITS                               (CMD_LEN_BITS                                )
            ,.CORE_TAG_WIDTH                             (CORE_TAG_WIDTH                              )
            ,.RMW_TYPE_BITS                              (RMW_TYPE_BITS                               )

            ,.UMCTL2_PHY_SPECIAL_IDLE                    (UMCTL2_PHY_SPECIAL_IDLE                     )
            ,.MEMC_ECC_SUPPORT                           (MEMC_ECC_SUPPORT                            )
            ,.BG_BITS                                    (BG_BITS                                     )
            ,.BG_BITS_DUP                                (BG_BITS_DUP                                 )
            ,.NUM_RANKS                                  (NUM_RANKS                                   )
            ,.PHY_DATA_WIDTH                             (PHY_DATA_WIDTH                              )
            ,.NUM_PHY_DRAM_CLKS                          (NUM_PHY_DRAM_CLKS                           )

            ,.FATL_CODE_BITS                             (FATL_CODE_BITS                              )
            ,.RETRY_MAX_ADD_RD_LAT_LG2                   (RETRY_MAX_ADD_RD_LAT_LG2                    )

            ,.PAGE_BITS                                  (PAGE_BITS                                   )
            ,.WORD_BITS                                  (WORD_BITS                                   )
            ,.BLK_BITS                                   (BLK_BITS                                    )
            ,.BSM_BITS                                   (BSM_BITS                                    )
            ,.NUM_TOTAL_BSMS                             (NUM_TOTAL_BSMS                              )

            ,.PHY_ADDR_BITS                              (PHY_ADDR_BITS                               )
            ,.PHY_MASK_WIDTH                             (PHY_MASK_WIDTH                              )
            ,.MRS_A_BITS                                 (MRS_A_BITS                                  )
            ,.MRS_BA_BITS                                (MRS_BA_BITS                                 )


            ,.AM_ROW_WIDTH                               (AM_ROW_WIDTH                                )

            ,.BG_BANK_BITS                               (BG_BANK_BITS                                )
            ,.MAX_CMD_NUM                                (MAX_CMD_NUM                                 )
            )
U_ddrc_cpe(
             .core_ddrc_rstn                             (core_ddrc_rstn                              )
            ,.core_ddrc_core_clk                         (core_ddrc_core_clk                          )
            ,.bsm_clk                                    (bsm_clk                                     ) // Input : gated clock for bsm instances
            ,.bsm_clk_en                                 (bsm_clk_en                                  ) // Output: used to generate bsm_clk externally
            ,.bsm_clk_on                                 (bsm_clk_on                                  ) // Input : 0: bsm_clk can be removed. 1: bsm_clk is not removed.

            ,.o_gs_cpfcpeif                              (ddrc_cpfcpeif                               )
            ,.o_bs_cpfcpeif                              (ddrc_cpfcpeif                               )
            ,.o_os_cpfcpeif                              (ddrc_cpfcpeif                               )
            ,.i_bm_bs_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_be_gs_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_ih_gs_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_ih_bs_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_te_bs_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_te_os_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_te_gs_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_be_os_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_te_pi_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.i_ih_pi_cpfcpeif                           (ddrc_cpfcpeif                               )
            ,.reg_ddrc_en_2t_timing_mode                 (reg_ddrc_en_2t_timing_mode                  )
            ,.reg_ddrc_burst_rdwr_int                    (reg_ddrc_burst_rdwr_int                     )
            ,.reg_ddrc_refresh_margin                    (reg_ddrc_refresh_margin                     )
            ,.reg_ddrc_t_ras_max                         (reg_ddrc_t_ras_max                          )
            ,.reg_ddrc_t_ras_min                         (reg_ddrc_t_ras_min                          )
            ,.reg_ddrc_t_rc                              (reg_ddrc_t_rc                               )
            ,.reg_ddrc_t_rcd                             (reg_ddrc_t_rcd                              )
            ,.reg_ddrc_t_rp                              (reg_ddrc_t_rp                               )
            ,.reg_ddrc_t_rrd                             (reg_ddrc_t_rrd                              )

            ,.reg_ddrc_rd2pre                            (reg_ddrc_rd2pre                             )
            ,.reg_ddrc_wr2pre                            (reg_ddrc_wr2pre                             )
            ,.reg_ddrc_rda2pre                           (reg_ddrc_rda2pre                            )
            ,.reg_ddrc_wra2pre                           (reg_ddrc_wra2pre                            )
            ,.reg_ddrc_pageclose                         (reg_ddrc_pageclose                          )
            ,.reg_ddrc_pageclose_timer                   (reg_ddrc_pageclose_timer                    )
            ,.reg_ddrc_frequency_ratio                   (reg_ddrc_frequency_ratio                    )
            ,.reg_ddrc_dis_dq                            (reg_ddrc_dis_dq                             )

            ,.reg_ddrc_mr                                (reg_ddrc_mr                                 )
            ,.reg_ddrc_emr                               (reg_ddrc_emr                                )
            ,.reg_ddrc_emr2                              (reg_ddrc_emr2                               )
            ,.reg_ddrc_emr3                              (reg_ddrc_emr3                               )
            ,.reg_ddrc_mr4                               (reg_ddrc_mr4                                )
            ,.reg_ddrc_mr5                               (reg_ddrc_mr5                                )
            ,.reg_ddrc_mr6                               (reg_ddrc_mr6                                )
            ,.reg_ddrc_mr22                              (reg_ddrc_mr22                               )
            ,.reg_ddrc_pre_cke_x1024                     (reg_ddrc_pre_cke_x1024                      )
            ,.reg_ddrc_post_cke_x1024                    (reg_ddrc_post_cke_x1024                     )
            ,.reg_ddrc_rd2wr                             (reg_ddrc_rd2wr                              )
            ,.reg_ddrc_wr2rd                             (reg_ddrc_wr2rd                              )
            ,.reg_ddrc_refresh_burst                     (reg_ddrc_refresh_burst                      )
            ,.reg_ddrc_dfi_t_ctrlupd_interval_min_x1024  (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024   )
            ,.reg_ddrc_dfi_t_ctrlupd_interval_max_x1024  (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024   )
            ,.reg_ddrc_rank_refresh                      (reg_ddrc_cpe_rank_refresh                   )
            ,.ddrc_reg_rank_refresh_busy                 (ddrc_rank_refresh_busy                      )
            ,.reg_ddrc_dis_auto_refresh                  (reg_ddrc_dis_auto_refresh                   )
            ,.reg_ddrc_ctrlupd                           (reg_ddrc_ctrlupd                            )
            ,.ddrc_reg_ctrlupd_busy                      (ddrc_reg_ctrlupd_busy                       )
            ,.reg_ddrc_dis_auto_ctrlupd                  (reg_ddrc_dis_auto_ctrlupd                   )
            ,.reg_ddrc_dis_auto_ctrlupd_srx              (reg_ddrc_dis_auto_ctrlupd_srx               )
            ,.reg_ddrc_ctrlupd_pre_srx                   (reg_ddrc_ctrlupd_pre_srx                    )
            ,.reg_ddrc_mr_wr                             (reg_ddrc_mr_wr                              )
            ,.reg_ddrc_mr_addr                           (reg_ddrc_mr_addr                            )
            ,.reg_ddrc_mr_data                           (reg_ddrc_mr_data                            )
            ,.ddrc_reg_mr_wr_busy                        (ddrc_reg_mr_wr_busy                         )
            ,.reg_ddrc_sw_init_int                       (reg_ddrc_sw_init_int                        )
            ,.reg_ddrc_mr_type                           (reg_ddrc_mr_type                            )
            ,.reg_ddrc_derate_enable                     (reg_ddrc_derate_enable                      )
            ,.mrr_op_on                                  (ddrc_mrr_op_on                              )
            ,.dfi_cmd_delay                              (dfi_cmd_delay                               )
            ,.cpedfi_if                                  (ddrc_cpedfiif                               ) // DDRC_CPE/DFI interface
            ,.reg_ddrc_dfi_init_complete_en              (reg_ddrc_dfi_init_complete_en               )
            ,.reg_ddrc_dfi_t_ctrlup_min                  (reg_ddrc_dfi_t_ctrlup_min                   )
            ,.reg_ddrc_dfi_t_ctrlup_max                  (reg_ddrc_dfi_t_ctrlup_max                   )
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Debug pins. Not currently used in all configs.
            ,.gs_dh_ctrlupd_state                        (gs_dh_ctrlupd_state                         )
//spyglass enable_block W528
            ,.reg_ddrc_t_ccd                             (reg_ddrc_t_ccd                              )
            ,.reg_ddrc_t_cke                             (reg_ddrc_t_cke                              )
            ,.reg_ddrc_t_faw                             (reg_ddrc_t_faw                              )
            ,.reg_ddrc_t_rfc_min                         (reg_ddrc_t_rfc_min                          )
            ,.reg_ddrc_t_rfc_min_ab                      (reg_ddrc_t_rfc_min_ab                       )
            ,.reg_ddrc_t_pbr2pbr                         (reg_ddrc_t_pbr2pbr                          )
            ,.reg_ddrc_t_pbr2act                         (reg_ddrc_t_pbr2act                          )
            ,.reg_ddrc_t_refi_x1_x32                  (reg_ddrc_t_refi_x1_x32                   )
            ,.reg_ddrc_t_refi_x1_sel                  (reg_ddrc_t_refi_x1_sel                   )
            ,.reg_ddrc_refresh_to_x1_x32                 (reg_ddrc_refresh_to_x1_x32                  )
            ,.reg_ddrc_prefer_write                      (reg_ddrc_prefer_write                       )
            ,.reg_ddrc_rdwr_idle_gap                     (reg_ddrc_rdwr_idle_gap                      )
            ,.reg_ddrc_powerdown_en                      (reg_ddrc_powerdown_en                       )
            ,.reg_ddrc_powerdown_to_x32                  (reg_ddrc_powerdown_to_x32                   )
            ,.reg_ddrc_t_xp                              (reg_ddrc_t_xp                               )
            ,.reg_ddrc_selfref_sw                        (reg_ddrc_selfref_sw                         )
            ,.reg_ddrc_hw_lp_en                          (reg_ddrc_hw_lp_en                           )
            ,.reg_ddrc_hw_lp_exit_idle_en                (reg_ddrc_hw_lp_exit_idle_en                 )
            ,.reg_ddrc_selfref_to_x32                    (reg_ddrc_selfref_to_x32                     )
            ,.reg_ddrc_hw_lp_idle_x32                    (reg_ddrc_hw_lp_idle_x32                     )
            ,.hif_cmd_valid                              (hif_cmd_valid                               )
            ,.cactive_in_ddrc_sync_or                    (cactive_in_ddrc_sync_or                     )
            ,.cactive_in_ddrc_async                      (cactive_in_ddrc_async                       )
            ,.csysreq_ddrc                               (csysreq_ddrc                                )
            ,.csysack_ddrc                               (ddrc_csysack_ddrc                           )
            ,.cactive_ddrc                               (ddrc_cactive_ddrc                           )
            ,.reg_ddrc_selfref_en                        (reg_ddrc_selfref_en                         )
            ,.reg_ddrc_mr_rank                           (reg_ddrc_mr_rank                            )
            ,.reg_ddrc_t_xsr                             (reg_ddrc_t_xsr                              )
            ,.reg_ddrc_refresh_update_level              (reg_ddrc_refresh_update_level               )
            ,.reg_ddrc_rank0_wr_odt                      (reg_ddrc_rank0_wr_odt                       )
            ,.reg_ddrc_rank0_rd_odt                      (reg_ddrc_rank0_rd_odt                       )
            ,.reg_ddrc_dis_speculative_act              (reg_ddrc_dis_speculative_act               )
            ,.reg_ddrc_prefer_read                       (reg_ddrc_prefer_read)
            ,.ts_pi_mwr                                  (ts_pi_mwr                                   )
            ,.rt_gs_empty                                (rt_gs_empty                                 )
            ,.mr_gs_empty                                (mr_gs_empty                                 )
            ,.reg_ddrc_t_mr                              (reg_ddrc_t_mr                               )
            ,.reg_ddrc_wr2rd_s                           (reg_ddrc_wr2rd_s                            )
            ,.reg_ddrc_t_ccd_s                           (reg_ddrc_t_ccd_s                            )
            ,.reg_ddrc_t_rrd_s                           (reg_ddrc_t_rrd_s                            )
            ,.reg_ddrc_rd2wr_s                           (reg_ddrc_rd2wr_s                            )
            ,.reg_ddrc_mrr2rd                            (reg_ddrc_mrr2rd                             )
            ,.reg_ddrc_mrr2wr                            (reg_ddrc_mrr2wr                             )
            ,.reg_ddrc_mrr2mrw                           (reg_ddrc_mrr2mrw                            )
            ,.reg_ddrc_dram_rstn_x1024                   (reg_ddrc_dram_rstn_x1024                    )
            ,.reg_ddrc_t_zq_long_nop                     (reg_ddrc_t_zq_long_nop                      )
            ,.reg_ddrc_t_zq_short_nop                    (reg_ddrc_t_zq_short_nop                     )
            ,.reg_ddrc_t_zq_short_interval_x1024         (reg_ddrc_t_zq_short_interval_x1024          )
            ,.reg_ddrc_zq_calib_short                    (reg_ddrc_zq_calib_short                     )
            ,.ddrc_reg_zq_calib_short_busy               (ddrc_reg_zq_calib_short_busy                )
            ,.reg_ddrc_dis_auto_zq                       (reg_ddrc_dis_auto_zq                        )
            ,.reg_ddrc_dis_srx_zqcl                      (reg_ddrc_dis_srx_zqcl                       )
            ,.reg_ddrc_zq_resistor_shared                (reg_ddrc_zq_resistor_shared                 )
            ,.reg_ddrc_read_latency                      (reg_ddrc_read_latency                       )
            ,.rl_plus_cmd_len                            (rl_plus_cmd_len                             )
            ,.reg_ddrc_zq_reset                          (reg_ddrc_zq_reset                           )
            ,.reg_ddrc_t_zq_reset_nop                    (reg_ddrc_t_zq_reset_nop                     )
            ,.ddrc_reg_zq_reset_busy                     (ddrc_reg_zq_reset_busy                      )
            ,.reg_ddrc_per_bank_refresh                  (reg_ddrc_per_bank_refresh                   )
            ,.reg_ddrc_auto_refab_en                     (reg_ddrc_auto_refab_en                      )
            ,.reg_ddrc_refresh_to_ab_x32                 (reg_ddrc_refresh_to_ab_x32                  )
            ,.hif_refresh_req_bank                       (hif_refresh_req_bank                        )
            ,.reg_ddrc_t_ppd                             (reg_ddrc_t_ppd                              )
            ,.reg_ddrc_odtloff                           (reg_ddrc_odtloff                            )
            ,.reg_ddrc_t_ccd_mw                          (reg_ddrc_t_ccd_mw                           )
            ,.reg_ddrc_dis_trefi_x6x8                    (reg_ddrc_dis_trefi_x6x8                     )
            ,.reg_ddrc_dis_trefi_x0125                   (reg_ddrc_dis_trefi_x0125                    )
            ,.reg_ddrc_lpddr4                            (reg_ddrc_lpddr4                             )
            ,.reg_ddrc_addrmap_row_b17                   (reg_ddrc_addrmap_row_b17                    )
            ,.reg_ddrc_lpddr5                            (reg_ddrc_lpddr5                             )
            ,.reg_ddrc_bank_org                          (reg_ddrc_bank_org                           )
            ,.reg_ddrc_lpddr4_diff_bank_rwa2pre          (reg_ddrc_lpddr4_diff_bank_rwa2pre           )
            ,.reg_ddrc_stay_in_selfref                   (reg_ddrc_stay_in_selfref                    )
            ,.reg_ddrc_t_cmdcke                          (reg_ddrc_t_cmdcke                           )
            ,.reg_ddrc_dsm_en                            (reg_ddrc_dsm_en                             )
            ,.reg_ddrc_t_pdn                             (reg_ddrc_t_pdn                              )
            ,.reg_ddrc_t_xsr_dsm_x1024                   (reg_ddrc_t_xsr_dsm_x1024                    )
            ,.reg_ddrc_t_csh                             (reg_ddrc_t_csh                              )
            ,.reg_ddrc_rd2mr                             (reg_ddrc_rd2mr                              )
            ,.reg_ddrc_wr2mr                             (reg_ddrc_wr2mr                              )
            ,.reg_ddrc_wck_on                            (reg_ddrc_wck_on                             )
            ,.reg_ddrc_max_rd_sync                       (reg_ddrc_max_rd_sync                        )
            ,.reg_ddrc_max_wr_sync                       (reg_ddrc_max_wr_sync                        )
            ,.reg_ddrc_dfi_twck_delay                    (reg_ddrc_dfi_twck_delay                     )
            ,.reg_ddrc_dfi_twck_en_rd                    (reg_ddrc_dfi_twck_en_rd                     )
            ,.reg_ddrc_dfi_twck_en_wr                    (reg_ddrc_dfi_twck_en_wr                     )
            ,.reg_ddrc_dfi_twck_dis                      (reg_ddrc_dfi_twck_dis                       )
            ,.reg_ddrc_dfi_twck_fast_toggle              (reg_ddrc_dfi_twck_fast_toggle               )
            ,.reg_ddrc_dfi_twck_toggle                   (reg_ddrc_dfi_twck_toggle                    )
            ,.reg_ddrc_dfi_twck_toggle_cs                (reg_ddrc_dfi_twck_toggle_cs                 )
            ,.reg_ddrc_dfi_twck_toggle_post              (reg_ddrc_dfi_twck_toggle_post               )
            ,.reg_ddrc_hpr_xact_run_length               (reg_ddrc_hpr_xact_run_length                )
            ,.reg_ddrc_hpr_max_starve                    (reg_ddrc_hpr_max_starve                     )
            ,.reg_ddrc_lpr_xact_run_length               (reg_ddrc_lpr_xact_run_length                )
            ,.reg_ddrc_lpr_max_starve                    (reg_ddrc_lpr_max_starve                     )
            ,.reg_ddrc_w_xact_run_length                 (reg_ddrc_w_xact_run_length                  )
            ,.reg_ddrc_w_max_starve                      (reg_ddrc_w_max_starve                       )
            ,.hif_go2critical_lpr                        (hif_go2critical_lpr                         )
            ,.hif_go2critical_hpr                        (hif_go2critical_hpr                         )
            ,.hif_go2critical_wr                         (hif_go2critical_wr                          )
            ,.hif_go2critical_l1_wr                      (hif_go2critical_l1_wr                       )
            ,.hif_go2critical_l2_wr                      (hif_go2critical_l2_wr                       )
            ,.hif_go2critical_l1_lpr                     (hif_go2critical_l1_lpr                      )
            ,.hif_go2critical_l2_lpr                     (hif_go2critical_l2_lpr                      )
            ,.hif_go2critical_l1_hpr                     (hif_go2critical_l1_hpr                      )
            ,.hif_go2critical_l2_hpr                     (hif_go2critical_l2_hpr                      )
            ,.wu_gs_enable_wr                            (wu_gs_enable_wr                             )
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Debug pins. Not currently used in all configs.
            ,.gs_dh_hpr_q_state                          (gs_dh_hpr_q_state                           )
            ,.gs_dh_lpr_q_state                          (gs_dh_lpr_q_state                           )
            ,.gs_dh_w_q_state                            (gs_dh_w_q_state                             )
            ,.gs_dh_init_curr_state                      (gs_dh_init_curr_state                       )
            ,.gs_dh_init_next_state                      (gs_dh_init_next_state                       )
//spyglass enable_block W528
            ,.ddrc_reg_selfref_cam_not_empty             (ddrc_reg_selfref_cam_not_empty              )
            ,.ddrc_reg_selfref_state                     (ddrc_reg_selfref_state                      )
            ,.ddrc_reg_operating_mode_w                  (ddrc_operating_mode                         )
            ,.ddrc_reg_selfref_type                      (ddrc_selfref_type                           )
            ,.gs_pi_rd_data_pipeline_empty               (ddrc_rd_data_pipeline_empty                 )
            ,.gs_pi_wr_data_pipeline_empty               (ddrc_wr_data_pipeline_empty                 )
            ,.gs_pi_data_pipeline_empty                  (ddrc_data_pipeline_empty                    )
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: used in performance log and inline logic
            ,.gs_pi_op_is_rd                             (gs_pi_op_is_rd                              )
//spyglass enable_block W528
            ,.gs_pi_op_is_exit_selfref                   (gs_pi_op_is_exit_selfref                    )
            ,.reg_ddrc_dfi_tphy_wrlat                    (reg_ddrc_dfi_tphy_wrlat                     )
            ,.reg_ddrc_dfi_t_rddata_en                   (reg_ddrc_dfi_t_rddata_en                    )
            ,.reg_ddrc_dfi_tphy_wrcslat                  (reg_ddrc_dfi_tphy_wrcslat                   )
            ,.reg_ddrc_dfi_tphy_rdcslat                  (reg_ddrc_dfi_tphy_rdcslat                   )
            ,.reg_ddrc_dfi_data_cs_polarity              (reg_ddrc_dfi_data_cs_polarity               )
            ,.reg_ddrc_dfi_t_dram_clk_enable             (reg_ddrc_dfi_t_dram_clk_enable              )
            ,.reg_ddrc_t_cksre                           (reg_ddrc_t_cksre                            )
            ,.reg_ddrc_t_cksrx                           (reg_ddrc_t_cksrx                            )
            ,.reg_ddrc_t_ckcsx                           (reg_ddrc_t_ckcsx                            )
            ,.reg_ddrc_t_ckesr                           (reg_ddrc_t_ckesr                            )
            ,.dfi_reset_n_in                             (dfi_reset_n_in                              )
            ,.dfi_reset_n_ref                            (dfi_reset_n_ref                             )
            ,.init_mr_done_in                            (init_mr_done_in                             )
            ,.init_mr_done_out                           (init_mr_done_out                            )
            ,.reg_ddrc_dfi_lp_data_req_en                (reg_ddrc_dfi_lp_data_req_en                 )
            ,.reg_ddrc_dfi_lp_en_pd                      (reg_ddrc_dfi_lp_en_pd                       )
            ,.reg_ddrc_dfi_lp_wakeup_pd                  (reg_ddrc_dfi_lp_wakeup_pd                   )
            ,.reg_ddrc_dfi_lp_en_sr                      (reg_ddrc_dfi_lp_en_sr                       )
            ,.reg_ddrc_dfi_lp_wakeup_sr                  (reg_ddrc_dfi_lp_wakeup_sr                   )
            ,.reg_ddrc_dfi_lp_en_data                    (reg_ddrc_dfi_lp_en_data                     )
            ,.reg_ddrc_dfi_lp_wakeup_data                (reg_ddrc_dfi_lp_wakeup_data                 )
            ,.reg_ddrc_dfi_lp_en_dsm                     (reg_ddrc_dfi_lp_en_dsm                      )
            ,.reg_ddrc_dfi_lp_wakeup_dsm                 (reg_ddrc_dfi_lp_wakeup_dsm                  )
            ,.reg_ddrc_dfi_tlp_resp                      (reg_ddrc_dfi_tlp_resp                       )

            ,.gs_mr_write                                (gs_mr_write                                 )
            ,.reg_ddrc_dfi_phyupd_en                     (reg_ddrc_dfi_phyupd_en                      )

            ,.reg_ddrc_dfi_phymstr_en                    (reg_ddrc_dfi_phymstr_en                     )
            ,.reg_ddrc_dfi_phymstr_blk_ref_x32           (reg_ddrc_dfi_phymstr_blk_ref_x32            )
            ,.reg_ddrc_dis_cam_drain_selfref             (reg_ddrc_dis_cam_drain_selfref              )
            ,.reg_ddrc_lpddr4_sr_allowed                 (reg_ddrc_lpddr4_sr_allowed                  )
            ,.reg_ddrc_lpddr4_opt_act_timing             (reg_ddrc_lpddr4_opt_act_timing              )
            ,.reg_ddrc_lpddr5_opt_act_timing             (reg_ddrc_lpddr5_opt_act_timing              )
            ,.reg_ddrc_dfi_t_ctrl_delay                  (reg_ddrc_dfi_t_ctrl_delay                   )
            ,.reg_ddrc_dfi_t_wrdata_delay                (reg_ddrc_dfi_t_wrdata_delay                 )
            ,.reg_ddrc_skip_dram_init                    (reg_ddrc_skip_dram_init                     )
            ,.reg_ddrc_opt_wrcam_fill_level              (reg_ddrc_opt_wrcam_fill_level               )
            ,.reg_ddrc_delay_switch_write                (reg_ddrc_delay_switch_write                 )
            ,.reg_ddrc_wr_pghit_num_thresh               (reg_ddrc_wr_pghit_num_thresh                )
            ,.reg_ddrc_rd_pghit_num_thresh               (reg_ddrc_rd_pghit_num_thresh                )
            ,.reg_ddrc_wrcam_highthresh                  (reg_ddrc_wrcam_highthresh                   )
            ,.reg_ddrc_wrcam_lowthresh                   (reg_ddrc_wrcam_lowthresh                    )
            ,.reg_ddrc_wr_page_exp_cycles                (reg_ddrc_wr_page_exp_cycles                 )
            ,.reg_ddrc_rd_page_exp_cycles                (reg_ddrc_rd_page_exp_cycles                 )
            ,.reg_ddrc_wr_act_idle_gap                   (reg_ddrc_wr_act_idle_gap                    )
            ,.reg_ddrc_rd_act_idle_gap                   (reg_ddrc_rd_act_idle_gap                    )
            ,.reg_ddrc_dis_opt_ntt_by_act                (reg_ddrc_dis_opt_ntt_by_act                 )

            ,.reg_ddrc_en_dfi_dram_clk_disable           (reg_ddrc_en_dfi_dram_clk_disable            )
            ,.reg_ddrc_dfi_t_dram_clk_disable            (reg_ddrc_dfi_t_dram_clk_disable             )
            ,.reg_ddrc_burst_rdwr                        (reg_ddrc_burst_rdwr                         )

            ,.pi_rt_rd_vld                               (pi_rt_rd_vld                                )
            ,.pi_rt_rd_partial                           (pi_rt_rd_partial                            )
            ,.pi_rt_wr_ram_addr                          (pi_rt_wr_ram_addr                           )
            ,.pi_rt_rmwtype                              (pi_rt_rmwtype                               )
            ,.pi_rt_rd_mrr_ext                           (pi_rt_rd_mrr_ext                            )
            ,.pi_rt_rd_mrr                               (pi_rt_rd_mrr                                )
            ,.pi_rt_rd_tag                               (pi_rt_rd_tag                                )
            ,.pi_rt_rd_addr_err                          (pi_rt_rd_addr_err                           )
            ,.pi_rt_rankbank_num                         (pi_dp_rankbank_num                          )
            ,.pi_rt_page_num                             (pi_rt_page_num                              )
            ,.pi_rt_block_num                            (pi_rt_block_num                             )
            ,.pi_rt_critical_word                        (pi_rt_critical_word                         )
            ,.mr_t_rddata_en                             (mr_t_rddata_en                              )
            ,.mr_t_wrlat                                 (mr_t_wrlat                                  )
            ,.mr_lp_data_rd                              (mr_lp_data_rd                               )
            ,.mr_lp_data_wr                              (mr_lp_data_wr                               )
            ,.pi_ph_dfi_rddata_en                        (pi_ph_dfi_rddata_en                         )
            ,.pi_ph_dfi_wrdata_en                        (pi_ph_dfi_wrdata_en                         )
            ,.ddrc_phy_cs                                (ddrc_phy_cs                                 )
            ,.core_derate_temp_limit_intr                (core_derate_temp_limit_intr                 )
            ,.reg_ddrc_mr4_read_interval                 (reg_ddrc_mr4_read_interval                  )
            ,.derate_sync_ack_c2p                        (derate_sync_ack_c2p                         )
            ,.reg_ddrc_lpddr4_refresh_mode               (reg_ddrc_lpddr4_refresh_mode                )
            ,.reg_ddrc_active_derate_byte_rank0          (reg_ddrc_active_derate_byte_rank0           )
            ,.ddrc_reg_dbg_mr4_byte0_rank0               (ddrc_reg_dbg_mr4_byte0_rank0                )
            ,.ddrc_reg_dbg_mr4_byte1_rank0               (ddrc_reg_dbg_mr4_byte1_rank0                )
            ,.ddrc_reg_dbg_mr4_byte2_rank0               (ddrc_reg_dbg_mr4_byte2_rank0                )
            ,.ddrc_reg_dbg_mr4_byte3_rank0               (ddrc_reg_dbg_mr4_byte3_rank0                )
            ,.reg_ddrc_derated_t_rcd                     (reg_ddrc_derated_t_rcd                      )
            ,.reg_ddrc_derated_t_ras_min                 (reg_ddrc_derated_t_ras_min                  )
            ,.reg_ddrc_derated_t_rp                      (reg_ddrc_derated_t_rp                       )
            ,.reg_ddrc_derated_t_rrd                     (reg_ddrc_derated_t_rrd                      )
            ,.reg_ddrc_derated_t_rc                      (reg_ddrc_derated_t_rc                       )
            ,.reg_ddrc_derate_mr4_tuf_dis                (reg_ddrc_derate_mr4_tuf_dis                 )
            ,.reg_ddrc_derate_mr4_pause_fc               (i_reg_ddrc_derate_mr4_pause_fc              )
            ,.rt_rd_rd_mrr_ext                           (rt_rd_rd_mrr_ext                            )
            ,.rd_mr4_data_valid                          (rd_mr4_data_valid                           )

            ,.hif_mrr_data                               (hif_mrr_data                                )

            ,.mr_t_wrdata                                (mr_t_wrdata                                 )
            ,.ddrc_phy_csn                               (ddrc_phy_csn                                )
            ,.reg_ddrc_dfi_init_start                    (reg_ddrc_dfi_init_start                     )
            ,.reg_ddrc_dfi_frequency                     (reg_ddrc_dfi_frequency                      )
            ,.dfi_wck_cs                                 (dfi_wck_cs                                  )
            ,.dfi_wck_en                                 (dfi_wck_en                                  )
            ,.dfi_wck_toggle                             (dfi_wck_toggle                              )


`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
            ,.te_ts_wr_entry_valid                       (te_ts_wr_entry_valid                        )
            ,.te_ts_rd_entry_valid                       (te_ts_rd_entry_valid                        )
            ,.te_ts_wr_page_hit_entries                  (te_ts_wr_page_hit_entries                   )
            ,.te_ts_rd_page_hit_entries                  (te_ts_rd_page_hit_entries                   )
`endif //SNPS_ASSERT_ON
`endif // SYNTHESIS

              ,.reg_ddrc_dqsosc_enable       (reg_ddrc_dqsosc_enable)
              ,.reg_ddrc_t_osco              (reg_ddrc_t_osco)
              ,.reg_ddrc_dqsosc_runtime      (reg_ddrc_dqsosc_runtime)
              ,.reg_ddrc_wck2dqo_runtime     (reg_ddrc_wck2dqo_runtime)
              ,.reg_ddrc_dqsosc_interval     (reg_ddrc_dqsosc_interval)
              ,.reg_ddrc_dqsosc_interval_unit(reg_ddrc_dqsosc_interval_unit)
              ,.reg_ddrc_dis_dqsosc_srx      (reg_ddrc_dis_dqsosc_srx)
              ,.dqsosc_state                 (dqsosc_state)
              ,.dqsosc_per_rank_stat         (dqsosc_per_rank_stat)
              ,.pi_ph_snoop_en               (pi_ph_snoop_en)
              ,.pi_rt_rd_mrr_snoop           (pi_rt_rd_mrr_snoop)

             ,.reg_ddrc_dfi_t_ctrlmsg_resp             (reg_ddrc_dfi_t_ctrlmsg_resp)
             ,.reg_ddrc_dfi0_ctrlmsg_req               (reg_ddrc_dfi0_ctrlmsg_req)
             ,.reg_ddrc_dfi0_ctrlmsg_tout_clr          (reg_ddrc_dfi0_ctrlmsg_tout_clr)
             ,.reg_ddrc_dfi0_ctrlmsg_data              (reg_ddrc_dfi0_ctrlmsg_data)
             ,.reg_ddrc_dfi0_ctrlmsg_cmd               (reg_ddrc_dfi0_ctrlmsg_cmd)
             ,.ddrc_reg_dfi0_ctrlmsg_req_busy          (ddrc_reg_dfi0_ctrlmsg_req_busy)
             ,.ddrc_reg_dfi0_ctrlmsg_resp_tout         (ddrc_reg_dfi0_ctrlmsg_resp_tout)
             ,.gs_pi_rdwr_ram_raddr_lsb_first          (gs_pi_rdwr_ram_raddr_lsb_first)
             ,.gs_pi_rdwr_pw_num_beats_m1              (gs_pi_rdwr_pw_num_beats_m1)
            );

   end else begin : GEN_DDRC_CPE_MASK_OUT

assign ddrc_cpfcpeif.gs_be_op_is_activate       = {$bits(ddrc_cpfcpeif.gs_be_op_is_activate){1'b0}};
assign ddrc_cpfcpeif.gs_be_op_is_precharge      = {$bits(ddrc_cpfcpeif.gs_be_op_is_precharge){1'b0}};
assign ddrc_cpfcpeif.gs_be_op_is_rdwr           = {$bits(ddrc_cpfcpeif.gs_be_op_is_rdwr){1'b0}};
assign ddrc_cpfcpeif.gs_be_rdwr_bsm_num         = {$bits(ddrc_cpfcpeif.gs_be_rdwr_bsm_num){1'b0}};
assign ddrc_cpfcpeif.gs_be_act_bsm_num          = {$bits(ddrc_cpfcpeif.gs_be_act_bsm_num){1'b0}};
assign ddrc_cpfcpeif.gs_be_pre_bsm_num          = {$bits(ddrc_cpfcpeif.gs_be_pre_bsm_num){1'b0}};
assign ddrc_cpfcpeif.gs_te_op_is_rd             = {$bits(ddrc_cpfcpeif.gs_te_op_is_rd){1'b0}};
assign ddrc_cpfcpeif.gs_te_op_is_wr             = {$bits(ddrc_cpfcpeif.gs_te_op_is_wr){1'b0}};
assign ddrc_cpfcpeif.gs_te_op_is_activate       = {$bits(ddrc_cpfcpeif.gs_te_op_is_activate){1'b0}};
assign ddrc_cpfcpeif.gs_te_op_is_precharge      = {$bits(ddrc_cpfcpeif.gs_te_op_is_precharge){1'b0}};
assign ddrc_cpfcpeif.gs_te_bsm_num4pre          = {$bits(ddrc_cpfcpeif.gs_te_bsm_num4pre){1'b0}};
assign ddrc_cpfcpeif.gs_te_bsm_num4rdwr         = {$bits(ddrc_cpfcpeif.gs_te_bsm_num4rdwr){1'b0}};
assign ddrc_cpfcpeif.gs_te_bsm_num4act          = {$bits(ddrc_cpfcpeif.gs_te_bsm_num4act){1'b0}};
assign ddrc_cpfcpeif.gs_te_wr_mode              = {$bits(ddrc_cpfcpeif.gs_te_wr_mode){1'b0}};
assign ddrc_cpfcpeif.gs_te_wr_possible          = {$bits(ddrc_cpfcpeif.gs_te_wr_possible){1'b0}};
assign ddrc_cpfcpeif.gs_te_pri_level            = {$bits(ddrc_cpfcpeif.gs_te_pri_level){1'b0}};
assign ddrc_cpfcpeif.gsfsm_sr_co_if_stall       = {$bits(ddrc_cpfcpeif.gsfsm_sr_co_if_stall){1'b0}};
assign ddrc_cpfcpeif.ts_act_page                = {$bits(ddrc_cpfcpeif.ts_act_page){1'b0}};
assign ddrc_cpfcpeif.ts_te_sel_act_wr           = {$bits(ddrc_cpfcpeif.ts_te_sel_act_wr){1'b0}};
assign ddrc_cpfcpeif.os_te_rdwr_entry           = {$bits(ddrc_cpfcpeif.os_te_rdwr_entry){1'b0}};
assign ddrc_cpfcpeif.os_te_autopre              = {$bits(ddrc_cpfcpeif.os_te_autopre){1'b0}};

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
assign ddrc_cpfcpeif.gs_te_rd_length = {$bits(ddrc_cpfcpeif.gs_te_rd_length){1'b0}};
assign ddrc_cpfcpeif.gs_te_rd_word   = {$bits(ddrc_cpfcpeif.gs_te_rd_word){1'b0}};
assign ddrc_cpfcpeif.gs_te_raddr_lsb_first = {$bits(ddrc_cpfcpeif.gs_te_raddr_lsb_first){1'b0}};
assign ddrc_cpfcpeif.gs_te_pw_num_beats_m1 = {$bits(ddrc_cpfcpeif.gs_te_pw_num_beats_m1){1'b0}};
`endif //SYNTHESIS
`endif //SNPS_ASSERT_ON



assign ddrc_cpedfiif.dfi_address                = {$bits(ddrc_cpedfiif.dfi_address){1'b0}};
assign ddrc_cpedfiif.dfi_bank                   = {$bits(ddrc_cpedfiif.dfi_bank){1'b0}};
assign ddrc_cpedfiif.dfi_bg                     = {$bits(ddrc_cpedfiif.dfi_bg){1'b0}};
assign ddrc_cpedfiif.dfi_cid                    = {$bits(ddrc_cpedfiif.dfi_cid){1'b0}};
assign ddrc_cpedfiif.dfi_act_n                  = {$bits(ddrc_cpedfiif.dfi_act_n){1'b0}};
assign ddrc_cpedfiif.dfi_cas_n                  = {$bits(ddrc_cpedfiif.dfi_cas_n){1'b0}};
assign ddrc_cpedfiif.dfi_ras_n                  = {$bits(ddrc_cpedfiif.dfi_ras_n){1'b0}};
assign ddrc_cpedfiif.dfi_we_n                   = {$bits(ddrc_cpedfiif.dfi_we_n){1'b0}};
assign ddrc_cpedfiif.dfi_odt                    = {$bits(ddrc_cpedfiif.dfi_odt){1'b0}};
assign ddrc_cpedfiif.dfi_parity_in              = {$bits(ddrc_cpedfiif.dfi_parity_in){1'b0}};
assign ddrc_cpedfiif.dfi_2n_mode                = {$bits(ddrc_cpedfiif.dfi_2n_mode){1'b0}};
assign ddrc_cpedfiif.dfi_freq_ratio             = {$bits(ddrc_cpedfiif.dfi_freq_ratio){1'b0}};
assign ddrc_cpedfiif.dfi_cke                    = {$bits(ddrc_cpedfiif.dfi_cke){1'b0}};
assign ddrc_cpedfiif.dfi_cs                     = {$bits(ddrc_cpedfiif.dfi_cs){1'b0}};
assign ddrc_cpedfiif.dfi_reset_n                = {$bits(ddrc_cpedfiif.dfi_reset_n){1'b0}};
assign ddrc_cpedfiif.dfi_init_start             = {$bits(ddrc_cpedfiif.dfi_init_start){1'b0}};
assign ddrc_cpedfiif.dfi_frequency              = {$bits(ddrc_cpedfiif.dfi_frequency){1'b0}};
assign ddrc_cpedfiif.dfi_ctrlupd_req            = {$bits(ddrc_cpedfiif.dfi_ctrlupd_req){1'b0}};
assign ddrc_cpedfiif.dfi_phyupd_ack             = {$bits(ddrc_cpedfiif.dfi_phyupd_ack){1'b0}};
assign ddrc_cpedfiif.dfi_phymstr_ack            = {$bits(ddrc_cpedfiif.dfi_phymstr_ack){1'b0}};
assign ddrc_cpedfiif.dfi_lp_ctrl_req            = {$bits(ddrc_cpedfiif.dfi_lp_ctrl_req){1'b0}};
assign ddrc_cpedfiif.dfi_lp_ctrl_wakeup         = {$bits(ddrc_cpedfiif.dfi_lp_ctrl_wakeup){1'b0}};
assign ddrc_cpedfiif.dfi_lp_data_req            = {$bits(ddrc_cpedfiif.dfi_lp_data_req){1'b0}};
assign ddrc_cpedfiif.dfi_lp_data_wakeup         = {$bits(ddrc_cpedfiif.dfi_lp_data_wakeup){1'b0}};
assign ddrc_cpedfiif.dfi_dram_clk_disable       = {$bits(ddrc_cpedfiif.dfi_dram_clk_disable){1'b0}};
assign ddrc_cpedfiif.dfi_wrdata_cs              = {$bits(ddrc_cpedfiif.dfi_wrdata_cs){1'b0}};
assign ddrc_cpedfiif.dfi_rddata_cs              = {$bits(ddrc_cpedfiif.dfi_rddata_cs){1'b0}};
assign ddrc_rank_refresh_busy                   = {$bits(ddrc_rank_refresh_busy){1'b0}};
assign ddrc_reg_ctrlupd_busy                    = {$bits(ddrc_reg_ctrlupd_busy){1'b0}};
assign ddrc_reg_mr_wr_busy                      = {$bits(ddrc_reg_mr_wr_busy){1'b0}};
assign ddrc_mrr_op_on                           = {$bits(ddrc_mrr_op_on){1'b0}};
assign ddrc_csysack_ddrc                        = 1'b1;
assign ddrc_cactive_ddrc                        = 1'b1;
assign ddrc_reg_zq_calib_short_busy             = {$bits(ddrc_reg_zq_calib_short_busy){1'b0}};
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Debug pins. Not currently used in all configs.
assign gs_dh_ctrlupd_state                      = {$bits(gs_dh_ctrlupd_state){1'b0}};
assign gs_dh_hpr_q_state                        = {$bits(gs_dh_hpr_q_state){1'b0}};
assign gs_dh_lpr_q_state                        = {$bits(gs_dh_lpr_q_state){1'b0}};
assign gs_dh_w_q_state                          = {$bits(gs_dh_w_q_state){1'b0}};
assign gs_dh_init_curr_state                    = {$bits(gs_dh_init_curr_state){1'b0}};
assign gs_dh_init_next_state                    = {$bits(gs_dh_init_next_state){1'b0}};
//spyglass enable_block W528
assign ddrc_reg_selfref_cam_not_empty           = {$bits(ddrc_reg_selfref_cam_not_empty){1'b0}};
assign ddrc_operating_mode                      = {$bits(ddrc_operating_mode){1'b0}};
assign ddrc_selfref_type                        = {$bits(ddrc_selfref_type){1'b0}};
assign ddrc_rd_data_pipeline_empty              = 1'b1;
assign ddrc_wr_data_pipeline_empty              = 1'b1;
assign ddrc_data_pipeline_empty                 = 1'b1;
assign gs_pi_op_is_rd                           = 1'b0;
assign gs_pi_op_is_exit_selfref                 = 1'b0;
assign gs_mr_write                              = {$bits(gs_mr_write){1'b0}};
assign pi_rt_rd_vld                             = {$bits(pi_rt_rd_vld){1'b0}};
assign pi_rt_rd_partial                         = {$bits(pi_rt_rd_partial){1'b0}};
assign pi_rt_wr_ram_addr                        = {$bits(pi_rt_wr_ram_addr){1'b0}};
assign pi_rt_rmwtype                            = {$bits(pi_rt_rmwtype){1'b0}};
assign pi_rt_rd_mrr_ext                         = {$bits(pi_rt_rd_mrr_ext){1'b0}};
assign pi_rt_rd_mrr                             = {$bits(pi_rt_rd_mrr){1'b0}};
assign pi_rt_rd_tag                             = {$bits(pi_rt_rd_tag){1'b0}};
assign pi_rt_rd_addr_err                        = {$bits(pi_rt_rd_addr_err){1'b0}};
assign pi_dp_rankbank_num                       = {$bits(pi_dp_rankbank_num){1'b0}};
assign pi_rt_page_num                           = {$bits(pi_rt_page_num){1'b0}};
assign pi_rt_block_num                          = {$bits(pi_rt_block_num){1'b0}};
assign pi_rt_critical_word                      = {$bits(pi_rt_critical_word){1'b0}};
assign pi_ph_dfi_rddata_en                      = {$bits(pi_ph_dfi_rddata_en){1'b0}};
assign pi_ph_dfi_wrdata_en                      = {$bits(pi_ph_dfi_wrdata_en){1'b0}};

assign gs_pi_rdwr_pw_num_beats_m1               = {$bits(gs_pi_rdwr_pw_num_beats_m1){1'b0}};
assign gs_pi_rdwr_ram_raddr_lsb_first           = {$bits(gs_pi_rdwr_ram_raddr_lsb_first){1'b0}};

   end
endgenerate

  assign ddrc_reg_ppt2_burst_busy             = {$bits(ddrc_reg_ppt2_burst_busy){1'b0}};
  assign ddrc_reg_ppt2_state                  = {$bits(ddrc_reg_ppt2_state){1'b0}};

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: the signals are used in some configurations
logic   [DBG_MR4_RANK_SEL_WIDTH-1:0]        mr4_rank_sel;
logic   [DBG_MR4_GRP_SEL_WIDTH-1:0]         mr4_grp_sel;

assign mr4_rank_sel = reg_ddrc_dbg_mr4_rank_sel;
assign mr4_grp_sel  = reg_ddrc_dbg_mr4_grp_sel;


assign ddrc_reg_dbg_mr4_byte4_rank0 = 5'b0;
assign ddrc_reg_dbg_mr4_byte5_rank0 = 5'b0;
assign ddrc_reg_dbg_mr4_byte6_rank0 = 5'b0;
assign ddrc_reg_dbg_mr4_byte7_rank0 = 5'b0;
assign ddrc_reg_dbg_mr4_byte0_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte1_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte2_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte3_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte4_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte5_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte6_rank1 = 5'b0;
assign ddrc_reg_dbg_mr4_byte7_rank1 = 5'b0;
//spyglass enable_block W528

assign ddrc_reg_dbg_mr4_byte0       = {3'h0, ddrc_reg_dbg_mr4_byte0_rank0};
assign ddrc_reg_dbg_mr4_byte1       = {3'h0, ddrc_reg_dbg_mr4_byte1_rank0};
assign ddrc_reg_dbg_mr4_byte2       = {3'h0, ddrc_reg_dbg_mr4_byte2_rank0};
assign ddrc_reg_dbg_mr4_byte3       = {3'h0, ddrc_reg_dbg_mr4_byte3_rank0};



dwc_ddrctl_ddrc_cpfcpeic
 #(
            // parameter from ddrc_cpfcpeif
             .LRANK_BITS                                 (LRANK_BITS                                  )
            ,.BG_BANK_BITS                               (BG_BANK_BITS                                )
            ,.RANKBANK_BITS                              (RANKBANK_BITS                               )
            ,.NUM_LRANKS                                 (NUM_LRANKS                                  )
            ,.NUM_TOTAL_BANKS                            (NUM_TOTAL_BANKS                             )
            ,.LRANK_BITS_DDRC                            (LRANK_BITS_DDRC                             )
            ,.NUM_LRANKS_DDRC                            (NUM_LRANKS_DDRC                             )
            ,.RANKBANK_BITS_DDRC                         (RANKBANK_BITS_DDRC                          )
            ,.NUM_TOTAL_BANKS_DDRC                       (NUM_TOTAL_BANKS_DDRC                        )
            ,.BSM_BITS                                   (BSM_BITS                                    )
            ,.CORE_TAG_WIDTH                             (CORE_TAG_WIDTH                              )
            ,.RMW_TYPE_BITS                              (RMW_TYPE_BITS                               )
            ,.WR_CAM_ADDR_WIDTH_IE                       (WR_CAM_ADDR_WIDTH_IE                        )
            ,.BLK_BITS                                   (BLK_BITS                                    )
            ,.WORD_BITS                                  (WORD_BITS                                   )
            ,.CMD_LEN_BITS                               (CMD_LEN_BITS                                )
            ,.NUM_TOTAL_BSMS                             (NUM_TOTAL_BSMS                              )
            ,.PAGE_BITS                                  (PAGE_BITS                                   )
            ,.RD_CAM_ADDR_WIDTH                          (RD_CAM_ADDR_WIDTH                           )
            ,.AUTOPRE_BITS                               (AUTOPRE_BITS                                )
            ,.PARTIAL_WR_BITS                            (PARTIAL_WR_BITS                             )
            ,.PARTIAL_WR_BITS_LOG2                       (PARTIAL_WR_BITS_LOG2                        )
            ,.PW_WORD_CNT_WD_MAX                         (PW_WORD_CNT_WD_MAX                          )
            ,.WR_CAM_ADDR_WIDTH                          (WR_CAM_ADDR_WIDTH                           )
            ,.MAX_CAM_ADDR_WIDTH                         (MAX_CAM_ADDR_WIDTH                          )

   // parameter from ddrc_cpfcpeif

) U_ddrc_cpfcpeic (
   // IO list
   //IF FROM DDRC_CPE
             .o_bm_mp_ddrc                               (ddrc_cpfcpeif                               )
            ,.i_gs_bm_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.i_bs_bm_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.o_ih_mp_ddrc                               (ddrc_cpfcpeif                               )
            ,.i_gs_ih_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.o_be_mp_ddrc                               (ddrc_cpfcpeif                               )
            ,.i_gs_be_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.i_bs_be_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.o_te_mp_ddrc                               (ddrc_cpfcpeif                               )
            ,.i_bs_te_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.i_gs_te_mp_ddrc                            (ddrc_cpfcpeif                               )
            ,.i_os_te_mp_ddrc                            (ddrc_cpfcpeif                               )



            ,.ih_gs_rdlow_empty                          (ih_gs_rdlow_empty                           )
            ,.ih_gs_rdhigh_empty                         (ih_gs_rdhigh_empty                          )
            ,.ih_busy                                    (ih_busy                                     )
            ,.ih_yy_xact_valid                           (ih_yy_xact_valid                            )

            ,.gsfsm_sr_co_if_stall                       (gsfsm_sr_co_if_stall                        )

            ,.be_os_page_table                           (be_os_page_table                            )

            ,.gs_be_op_is_activate                       (gs_be_op_is_activate                        )
            ,.gs_be_op_is_precharge                      (gs_be_op_is_precharge                       )
            ,.gs_be_op_is_rdwr                           (gs_be_op_is_rdwr                            )
            ,.gs_be_rdwr_bsm_num                         (gs_be_rdwr_bsm_num                          )
            ,.gs_be_act_bsm_num                          (gs_be_act_bsm_num                           )
            ,.gs_be_pre_bsm_num                          (gs_be_pre_bsm_num                           )

            ,.ts_act_page                                (ts_act_page                                 )

            ,.te_bs_rd_page_hit                          (te_bs_rd_page_hit                           )
            ,.te_bs_rd_valid                             (te_bs_rd_valid                              )
            ,.te_bs_wr_page_hit                          (te_bs_wr_page_hit                           )
            ,.te_bs_wr_valid                             (te_bs_wr_valid                              )
            ,.te_bs_rd_bank_page_hit                     (te_bs_rd_bank_page_hit                      )
            ,.te_bs_wr_bank_page_hit                     (te_bs_wr_bank_page_hit                      )
            ,.te_bs_rd_hi                                (te_bs_rd_hi                                 )
            ,.te_os_rd_entry_table                       (te_os_rd_entry_table                        )
            ,.te_os_wr_entry_table                       (te_os_wr_entry_table                        )
            ,.te_os_rd_page_table                        (te_os_rd_page_table                         )
            ,.te_os_wr_page_table                        (te_os_wr_page_table                         )
            ,.te_os_rd_cmd_autopre_table                 (te_os_rd_cmd_autopre_table                  )
            ,.te_os_wr_cmd_autopre_table                 (te_os_wr_cmd_autopre_table                  )
            ,.te_os_rd_pageclose_autopre                 (te_os_rd_pageclose_autopre                  )
            ,.te_os_wr_pageclose_autopre                 (te_os_wr_pageclose_autopre                  )
            ,.te_os_rd_length_table                      (te_os_rd_length_table                       )
            ,.te_os_rd_critical_word_table               (te_os_rd_critical_word_table                )
            ,.te_os_wr_mr_ram_raddr_lsb_first_table      (te_os_wr_mr_ram_raddr_lsb_first_table       )
            ,.te_os_wr_mr_pw_num_beats_m1_table          (te_os_wr_mr_pw_num_beats_m1_table           )
            ,.te_os_mwr_table                            (te_os_mwr_table                             )
            ,.te_b3_bit                                  (te_b3_bit                                   )
            ,.te_os_hi_bsm_hint                          (te_os_hi_bsm_hint                           )
            ,.te_os_lo_bsm_hint                          (te_os_lo_bsm_hint                           )
            ,.te_os_wr_bsm_hint                          (te_os_wr_bsm_hint                           )
            ,.te_os_lo_act_bsm_hint                      (te_os_lo_act_bsm_hint                       )
            ,.te_os_wr_act_bsm_hint                      (te_os_wr_act_bsm_hint                       )
            ,.te_gs_rd_flush                             (te_gs_rd_flush                              )
            ,.te_gs_wr_flush                             (te_gs_wr_flush                              )
            ,.te_gs_block_wr                             (te_gs_block_wr                              )
            ,.te_gs_any_rd_pending                       (te_gs_any_rd_pending                        )
            ,.te_gs_any_wr_pending                       (te_gs_any_wr_pending                        )
            ,.te_gs_rank_wr_pending                      (te_gs_rank_wr_pending                       )
            ,.te_gs_rank_rd_pending                      (te_gs_rank_rd_pending                       )
            ,.te_gs_bank_wr_pending                      (te_gs_bank_wr_pending                       )
            ,.te_gs_bank_rd_pending                      (te_gs_bank_rd_pending                       )
            ,.te_pi_rd_addr_blk                          (te_pi_rd_addr_blk                           )
            ,.te_pi_rd_tag                               (te_pi_rd_tag                                )
            ,.te_pi_rd_rmw_type                          (te_pi_rd_rmw_type                           )
            ,.te_pi_rd_link_addr                         (te_pi_rd_link_addr                          )
            ,.te_pi_rd_addr_err                          (te_pi_rd_addr_err                           )
            ,.te_pi_wr_addr_blk                          (te_pi_wr_addr_blk                           )
            ,.te_pi_wr_word                              (te_pi_wr_word                               )

            ,.ts_te_sel_act_wr                           (ts_te_sel_act_wr                            )
            ,.te_rws_wr_col_bank                         (te_rws_wr_col_bank                          )
            ,.te_rws_rd_col_bank                         (te_rws_rd_col_bank                          )
            ,.te_num_wr_pghit_entries                    (te_num_wr_pghit_entries                     )
            ,.te_num_rd_pghit_entries                    (te_num_rd_pghit_entries                     )
            ,.te_wr_entry_avail                          (te_wr_entry_avail                           )

            ,.gs_te_op_is_rd                             (gs_te_op_is_rd                              )
            ,.gs_te_op_is_wr                             (gs_te_op_is_wr                              )
            ,.gs_te_op_is_activate                       (gs_te_op_is_activate                        )
            ,.gs_te_op_is_precharge                      (gs_te_op_is_precharge                       )
            ,.gs_te_bsm_num4pre                          (gs_te_bsm_num4pre                           )
            ,.gs_te_bsm_num4rdwr                         (gs_te_bsm_num4rdwr                          )
            ,.gs_te_bsm_num4act                          (gs_te_bsm_num4act                           )
            ,.gs_te_wr_mode                              (gs_te_wr_mode                               )
            ,.gs_te_wr_possible                          (gs_te_wr_possible                           )
            ,.gs_te_pri_level                            (gs_te_pri_level                             )
`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
            ,.gs_te_rd_length                            (gs_te_rd_length                             )
            ,.gs_te_rd_word                              (gs_te_rd_word                               )
            ,.gs_te_raddr_lsb_first                      (gs_te_raddr_lsb_first                       )
            ,.gs_te_pw_num_beats_m1                      (gs_te_pw_num_beats_m1                       )
  `endif //SYNTHESIS
`endif //SNPS_ASSERT


            ,.os_te_rdwr_entry                           (os_te_rdwr_entry                            )
            ,.ts_te_autopre                              (ts_te_autopre                               )
);

assign pi_rd_vld                    = 1'b0;
assign pi_rd_partial                = {CMD_LEN_BITS{1'b0}};
assign pi_rd_tag                    = {CORE_TAG_WIDTH{1'b0}};
assign pi_rd_mrr                    = 1'b0;
assign pi_rd_mrr_ext                = 1'b0;
assign pi_rd_crc_retry_limit_reach_pre  = 1'b0;
assign pi_rd_ue_retry_limit_reach_pre  = 1'b0;
assign pi_rd_addr_err               = 1'b0;
assign pi_rd_rmw_type               = {RMW_TYPE_BITS{1'b0}};
assign pi_rd_wr_ram_addr            = {WR_CAM_ADDR_WIDTH{1'b0}};
assign pi_rd_page                   = {PAGE_BITS{1'b0}};
assign pi_rd_blk                    = {BLK_BITS{1'b0}};
assign pi_rd_critical_word          = {WORD_BITS{1'b0}};
assign pi_rd_rankbank               = {RANKBANK_BITS_FULL{1'b0}};
assign pi_wr_vld_nxt                = 1'b0;
assign pi_wr_ph_nxt                 = 2'b00;
assign pi_wr_cs_nxt                 = {NUM_RANKS{1'b1}};
assign pi_rd_vld_nxt                = 1'b0;
assign pi_rd_ph_nxt                 = 2'b00;
assign pi_dfi_wrdata_en             = {`MEMC_FREQ_RATIO{1'b0}};
assign pi_dfi_rddata_en             = {`MEMC_FREQ_RATIO{1'b0}};
assign pi_rd_mrr_snoop              = 1'b0;
assign pi_phy_snoop_en              = 4'b0;
assign dbg_prank_act_pd             = {NUM_RANKS{1'b0}};
assign dbg_prank_pre_pd             = {NUM_RANKS{1'b0}};
assign gs_mr_pw_num_beats_m1        = {PW_WORD_CNT_WD_MAX{1'b0}};
assign gs_mr_ram_raddr_lsb_first    = {PARTIAL_WR_BITS_LOG2{1'b0}};
assign mrr_op_on                    = ddrc_mrr_op_on;
assign ddrc_reg_refresh_rate_rank0  = 3'b000;
assign ddrc_reg_refresh_rate_rank1  = 3'b000;
assign ddrc_reg_refresh_rate_rank2  = 3'b000;
assign ddrc_reg_refresh_rate_rank3  = 3'b000;

assign sw_wr_data_valid       = 1'b0;
assign sw_wr_data             = {CORE_DATA_WIDTH{1'b0}};
assign sw_wr_data_mask        = {(CORE_DATA_WIDTH/8){1'b0}};
assign ci_manual_wr_mode      = 1'b0;
assign ci_manual_rd_mode      = 1'b0;
assign sw_wr_ecc              = {CORE_ECC_WIDTH_DUP{1'b0}};
assign sw_wr_ecc_mask         = {CORE_ECC_MASK_WIDTH_DUP{1'b0}};
assign ddrc_reg_rd_data_dq0   = {RD_DATA_DQ0_WIDTH{1'b0}};
assign ddrc_reg_rd_data_dq1   = {RD_DATA_DQ1_WIDTH{1'b0}};

//-------------------------------------------------------
// CPE-DFI signals
//-------------------------------------------------------
dwc_ddrctl_ddrc_cpedfiic
 #(
             .NUM_RANKS                                  (NUM_RANKS                                   )
            ,.FREQ_RATIO                                 (`MEMC_FREQ_RATIO                            )
            ,.BANK_BITS                                  (BANK_BITS                                   )
            ,.BG_BITS                                    (BG_BITS_DUP                                 )
            ,.CID_WIDTH                                  (CID_WIDTH_DUP                               )
            ,.CID_WIDTH_DDRC                             (CID_WIDTH_DUP_DDRC                          )
            ,.ADDR_WIDTH                                 (PHY_ADDR_BITS                               )
            ,.RESET_WIDTH                                (`UMCTL2_RESET_WIDTH                         )
            ,.NUM_LANES                                  (NUM_LANES                                   )
            ,.PARITY_IN_WIDTH                            (PARITY_IN_WIDTH                             )
            ,.NUM_DRAM_CLKS                              (NUM_PHY_DRAM_CLKS                           )
) U_cpedfi_ic (
             .ddrc_cpedfiif                              (ddrc_cpedfiif                               )
            ,.dfi_address                                (dfi_address                                 )
            ,.dfi_bank                                   (dfi_bank                                    )
            ,.dfi_freq_ratio                             (dfi_freq_ratio                              )
            ,.dfi_bg                                     (dfi_bg                                      )
            ,.dfi_act_n                                  (dfi_act_n                                   )
            ,.dfi_cid                                    (dfi_cid                                     )
            ,.dfi_cas_n                                  (dfi_cas_n                                   )
            ,.dfi_ras_n                                  (dfi_ras_n                                   )
            ,.dfi_we_n                                   (dfi_we_n                                    )
            ,.dfi_cke                                    (dfi_cke                                     )
            ,.dfi_cs                                     (dfi_cs                                      )
            ,.dfi_odt                                    (dfi_odt                                     )
            ,.dfi_reset_n                                (dfi_reset_n                                 )
            ,.dfi_parity_in                              (dfi_parity_in                               )
            ,.dfi_init_complete                          (dfi_init_complete                           )
            ,.dfi_init_start                             (dfi_init_start                              )
            ,.dfi_frequency                              (dfi_frequency                               )
            ,.dfi_2n_mode                                (dfi_2n_mode                                 )
            ,.dfi_ctrlupd_req                            (dfi_ctrlupd_req                             )
            ,.dfi_ctrlupd_ack                            (dfi_ctrlupd_ack                             )
            ,.dfi_phyupd_req                             (dfi_phyupd_req                              )
            ,.dfi_phyupd_ack                             (dfi_phyupd_ack                              )      //
            ,.dfi_lp_ctrl_req                            (dfi_lp_ctrl_req                             )      //
            ,.dfi_lp_ctrl_wakeup                         (dfi_lp_ctrl_wakeup                          )      //
            ,.dfi_lp_ctrl_ack                            (dfi_lp_ctrl_ack                             )      //
            ,.dfi_lp_data_req                            (dfi_lp_data_req                             )      //
            ,.dfi_lp_data_wakeup                         (dfi_lp_data_wakeup                          )      //
            ,.dfi_lp_data_ack                            (dfi_lp_data_ack                             )      //
            ,.dfi_dram_clk_disable                       (dfi_dram_clk_disable                        )      //
            ,.dfi_phymstr_req                            (dfi_phymstr_req                             )      // exists in DDRC_CPE only
            ,.dfi_phymstr_cs_state                       (dfi_phymstr_cs_state                        )      // exists in DDRC_CPE only
            ,.dfi_phymstr_state_sel                      (dfi_phymstr_state_sel                       )      // exists in DDRC_CPE only
            ,.dfi_phymstr_type                           (dfi_phymstr_type                            )      // exists in DDRC_CPE only
            ,.dfi_phymstr_ack                            (dfi_phymstr_ack                             )      // exists in DDRC_CPE only
            ,.dfi_wrdata_cs                              (dfi_wrdata_cs                               )      //
            ,.dfi_rddata_cs                              (dfi_rddata_cs                               )      //
            ,.dfi_ctrlmsg_req                            (dfi_ctrlmsg_req                             )
            ,.dfi_ctrlmsg                                (dfi_ctrlmsg                                 )
            ,.dfi_ctrlmsg_data                           (dfi_ctrlmsg_data                            )
            ,.dfi_ctrlmsg_ack                            (dfi_ctrlmsg_ack                             )
);

dwc_ddrctl_ddrc_cperegic
 #(
             .NUM_RANKS                                  (NUM_RANKS                                   )
            ,.NUM_LRANKS                                 (NUM_LRANKS                                  )
            ,.NUM_LRANKS_DDRC                            (NUM_LRANKS_DDRC                             )
) U_cpereg_ic(
             .core_ddrc_core_clk                         (core_ddrc_core_clk                          )
            ,.core_ddrc_rstn                             (core_ddrc_rstn                              )
         ///////////////////////////////////////////////////////////////////////////////////////////////
         // mux output
         ///////////////////////////////////////////////////////////////////////////////////////////////
            ,.ddrc_reg_rank_refresh_busy                 (ddrc_reg_rank_refresh_busy                  )
            ,.ext_rank_refresh_busy                      (ext_rank_refresh_busy                       )
            ,.gs_pi_wr_data_pipeline_empty               (gs_pi_wr_data_pipeline_empty                )
            ,.gs_pi_rd_data_pipeline_empty               (gs_pi_rd_data_pipeline_empty                )
            ,.gs_pi_data_pipeline_empty                  (gs_pi_data_pipeline_empty                   )

            ,.ddrc_reg_operating_mode                    (ddrc_reg_operating_mode                     )
            ,.ddrc_reg_selfref_type                      (ddrc_reg_selfref_type                       )

            ,.cactive_ddrc                               (cactive_ddrc                                )
            ,.csysack_ddrc                               (csysack_ddrc                                )


         ///////////////////////////////////////////////////////////////////////////////////////////////
         // input from ddrc_cpe
         ///////////////////////////////////////////////////////////////////////////////////////////////
            ,.ddrc_rank_refresh_busy                     (ddrc_rank_refresh_busy                      )
            ,.ddrc_wr_data_pipeline_empty                (ddrc_wr_data_pipeline_empty                 )
            ,.ddrc_rd_data_pipeline_empty                (ddrc_rd_data_pipeline_empty                 )
            ,.ddrc_data_pipeline_empty                   (ddrc_data_pipeline_empty                    )

            ,.ddrc_operating_mode                        (ddrc_operating_mode                         )
            ,.ddrc_selfref_type                          (ddrc_selfref_type                           )

            ,.ddrc_cactive_ddrc                          (ddrc_cactive_ddrc                           )
            ,.ddrc_csysack_ddrc                          (ddrc_csysack_ddrc                           )


         ///////////////////////////////////////////////////////////////////////////////////////////////
         // input from pas_cpe
         ///////////////////////////////////////////////////////////////////////////////////////////////
);


//-------------------------------------------------------
// perf I/F signals
//-------------------------------------------------------
   dwc_ddrctl_ddrc_cpperfic
    #(
       .NUM_RANKS               (NUM_RANKS)
      ,.RANK_BITS_DUP           (RANK_BITS_DUP)
      ,.BG_BITS_DUP             (BG_BITS_DUP)
      ,.CID_WIDTH_DUP           (CID_WIDTH_DUP)
      ,.BSM_BITS                (BSM_BITS)
      ,.NUM_TOTAL_BSMS          (NUM_TOTAL_BSMS)
      ,.LRANK_BITS              (LRANK_BITS)
      ,.BG_BANK_BITS            (BG_BANK_BITS)
      ,.RANKBANK_BITS           (RANKBANK_BITS)
      ,.BG_BITS                 (BG_BITS)
      ,.BANK_BITS               (BANK_BITS)
      ,.CID_WIDTH               (CID_WIDTH)
      ,.RANK_BITS               (RANK_BITS)

   ) U_cpperfic (
       .perf_hif_rd_or_wr                    (perf_hif_rd_or_wr                   )
      ,.perf_hif_wr                          (perf_hif_wr                         )
      ,.perf_hif_rd                          (perf_hif_rd                         )
      ,.perf_hif_rmw                         (perf_hif_rmw                        )
      ,.perf_hif_hi_pri_rd                   (perf_hif_hi_pri_rd                  )
      ,.perf_read_bypass                     (perf_read_bypass                    )
      ,.perf_act_bypass                      (perf_act_bypass                     )
      ,.perf_hpr_xact_when_critical          (perf_hpr_xact_when_critical         )
      ,.perf_lpr_xact_when_critical          (perf_lpr_xact_when_critical         )
      ,.perf_wr_xact_when_critical           (perf_wr_xact_when_critical          )
      ,.perf_op_is_activate                  (perf_op_is_activate                 )
      ,.perf_op_is_rd_or_wr                  (perf_op_is_rd_or_wr                 )
      ,.perf_op_is_rd_activate               (perf_op_is_rd_activate              )
      ,.perf_op_is_rd                        (perf_op_is_rd                       )
      ,.perf_op_is_wr                        (perf_op_is_wr                       )
      ,.perf_op_is_mwr                       (perf_op_is_mwr                      )
      ,.perf_op_is_cas                       (perf_op_is_cas                      )
      ,.perf_op_is_cas_ws                    (perf_op_is_cas_ws                   )
      ,.perf_op_is_cas_ws_off                (perf_op_is_cas_ws_off               )
      ,.perf_op_is_cas_wck_sus               (perf_op_is_cas_wck_sus              )
      ,.perf_op_is_enter_dsm                 (perf_op_is_enter_dsm                )
      ,.perf_op_is_rfm                       (perf_op_is_rfm                      )
      ,.perf_op_is_precharge                 (perf_op_is_precharge                )
      ,.perf_precharge_for_rdwr              (perf_precharge_for_rdwr             )
      ,.perf_precharge_for_other             (perf_precharge_for_other            )
      ,.perf_rdwr_transitions                (perf_rdwr_transitions               )
      ,.perf_write_combine                   (perf_write_combine                  )
      ,.perf_write_combine_noecc             (perf_write_combine_noecc            )
      ,.perf_write_combine_wrecc             (perf_write_combine_wrecc            )
      ,.perf_war_hazard                      (perf_war_hazard                     )
      ,.perf_raw_hazard                      (perf_raw_hazard                     )
      ,.perf_waw_hazard                      (perf_waw_hazard                     )
      ,.perf_ie_blk_hazard                   (perf_ie_blk_hazard                  )
      ,.perf_op_is_enter_selfref             (perf_op_is_enter_selfref            )
      ,.perf_op_is_enter_powerdown           (perf_op_is_enter_powerdown          )
      ,.perf_op_is_enter_mpsm                (perf_op_is_enter_mpsm               )
      ,.perf_selfref_mode                    (perf_selfref_mode                   )
      ,.perf_op_is_refresh                   (perf_op_is_refresh                  )
      ,.perf_op_is_crit_ref                  (perf_op_is_crit_ref                 )
      ,.perf_op_is_spec_ref                  (perf_op_is_spec_ref                 )
      ,.perf_op_is_load_mode                 (perf_op_is_load_mode                )
      ,.perf_op_is_zqcl                      (perf_op_is_zqcl                     )
      ,.perf_op_is_zqcs                      (perf_op_is_zqcs                     )
      ,.perf_rank                            (perf_rank                           )
      ,.perf_bank                            (perf_bank                           )
      ,.perf_bg                              (perf_bg                             )
      ,.perf_cid                             (perf_cid                            )
      ,.perf_bypass_rank                     (perf_bypass_rank                    )
      ,.perf_bypass_bank                     (perf_bypass_bank                    )
      ,.perf_bypass_bg                       (perf_bypass_bg                      )
      ,.perf_bypass_cid                      (perf_bypass_cid                     )
      ,.perf_bsm_alloc                       (perf_bsm_alloc                      )
      ,.perf_bsm_starvation                  (perf_bsm_starvation                 )
      ,.perf_num_alloc_bsm                   (perf_num_alloc_bsm                  )
      ,.perf_visible_window_limit_reached_rd (perf_visible_window_limit_reached_rd)
      ,.perf_visible_window_limit_reached_wr (perf_visible_window_limit_reached_wr)
      ,.perf_op_is_dqsosc_mpc                (perf_op_is_dqsosc_mpc               )
      ,.perf_op_is_dqsosc_mrr                (perf_op_is_dqsosc_mrr               )
      ,.perf_op_is_tcr_mrr                   (perf_op_is_tcr_mrr                  )
      ,.perf_op_is_zqstart                   (perf_op_is_zqstart                  )
      ,.perf_op_is_zqlatch                   (perf_op_is_zqlatch                  )


);




endmodule
