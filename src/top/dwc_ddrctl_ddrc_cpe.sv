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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/top/dwc_ddrctl_ddrc_cpe.sv#2 $
// -------------------------------------------------------------------------
// Description:
//     DDRC CPE wrapper module
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
`include "dfi/DWC_ddrctl_dfi_pkg.svh"
`include "top/dwc_ddrctl_ddrc_cpedfi_if.svh"
`include "top/dwc_ddrctl_ddrc_cpfcpe_if.svh"

module dwc_ddrctl_ddrc_cpe
import DWC_ddrctl_reg_pkg::*;
import DWC_ddrctl_dfi_pkg::*;
#(
    parameter       CHANNEL_NUM                 = 0,
    parameter       SHARED_AC                   = 0,
    parameter       RANK_BITS                   = `MEMC_RANK_BITS,
    parameter       BANK_BITS                   = `MEMC_BANK_BITS,
    parameter       MWR_BITS                    = 1,                                // currently 1-bit info (OR of all data beats)
    parameter       DBG_MR4_BYTE_RANK_WIDTH     = 5,
    parameter       PARTIAL_WR_BITS             = `UMCTL2_PARTIAL_WR_BITS,
    parameter       PW_NUM_DB                   = PARTIAL_WR_BITS,
    parameter       PW_FACTOR_HBW               = 2*`MEMC_FREQ_RATIO,
    parameter       PW_WORD_VALID_WD_HBW        = PW_NUM_DB*PW_FACTOR_HBW,
    parameter       PW_WORD_VALID_WD_MAX        = PW_WORD_VALID_WD_HBW,
    parameter       PW_WORD_CNT_WD_MAX          = `log2(PW_WORD_VALID_WD_MAX),
    parameter       PARTIAL_WR_BITS_LOG2        = `log2(PARTIAL_WR_BITS),
    parameter       BCM_VERIF_EN                = 1,
    parameter       BCM_DDRC_N_SYNC             = 2,
    parameter       NUM_LANES                   = 4,                                //Number of lanes in PHY - default is 4
    parameter       CID_WIDTH                   = `UMCTL2_CID_WIDTH,
    parameter       CID_WIDTH_DUP               = `UMCTL2_CID_WIDTH,
    parameter       AUTOPRE_BITS                = (`MEMC_INLINE_ECC_EN==1)? 2 : 1,
    parameter       NPORTS                      = 1,                                // no. of ports (for cactive_in_ddrc width) gets overwritten by toplevel
    parameter       A_SYNC_TABLE                = 16'hffff,                         // AXI sync table
    parameter       OCPAR_EN                    = 0,                                // enables on-chip parity
    parameter       WR_CAM_ENTRIES_IE           = 0,
    parameter       RD_CAM_ENTRIES              = 0,
    parameter       WR_CAM_ENTRIES              = 0,
    parameter       RD_CAM_ADDR_WIDTH           = `MEMC_RDCMD_ENTRY_BITS,           // bits to address into read CAM
    parameter       WR_CAM_ADDR_WIDTH           = `MEMC_WRCMD_ENTRY_BITS,           // bits to address into write CAM
    parameter       WR_CAM_ADDR_WIDTH_IE        = 0,
    parameter       MAX_CAM_ADDR_WIDTH          = 0,
    parameter       MAX_CMD_DELAY               = `UMCTL2_MAX_CMD_DELAY,

    parameter       IE_RD_TYPE_BITS             = `IE_RD_TYPE_BITS,
    parameter       IE_WR_TYPE_BITS             = `IE_WR_TYPE_BITS,
    parameter       IE_BURST_NUM_BITS           = `MEMC_BURST_LENGTH==16 ? 4 : 3,
    parameter       NO_OF_BT                    = `MEMC_NO_OF_BLK_TOKEN,
    parameter       BT_BITS                     = `log2(NO_OF_BT),
    parameter       ECCAP_BITS                  = `MEMC_ECCAP_EN,
    parameter       IE_TAG_BITS                 = (`MEMC_INLINE_ECC_EN==1) ? IE_RD_TYPE_BITS + IE_BURST_NUM_BITS + BT_BITS + ECCAP_BITS : 0,
    parameter       CMD_DELAY_BITS              = `UMCTL2_CMD_DELAY_BITS,

    parameter       CMD_LEN_BITS                = 1,                                // command length bit width
    parameter       CORE_TAG_WIDTH              = `MEMC_TAGBITS,                    // width of tag
    parameter       PW_BC_SEL_BITS              = 3,
    parameter       RMW_TYPE_BITS               = 2,                                // 2-bit RMW type

    parameter       UMCTL2_PHY_SPECIAL_IDLE     = 0,                                // A specially encoded "IDLE" command over the DFI bus: {ACT_n,RAS_n,CAS_n,WE_n,BA0}
    parameter       MEMC_ECC_SUPPORT            = 0,
    parameter       BG_BITS                     = `MEMC_BG_BITS,
    parameter       BG_BITS_DUP                 = `MEMC_BG_BITS,
    parameter       NUM_RANKS                   = `MEMC_NUM_RANKS,                  // max supported ranks (chip selects)
    parameter       PHY_DATA_WIDTH              = `MEMC_DFI_TOTAL_DATA_WIDTH,       // data width to PHY
    parameter       NUM_PHY_DRAM_CLKS           = `MEMC_NUM_CLKS,

    parameter       FATL_CODE_BITS              = 3,
    parameter       RETRY_MAX_ADD_RD_LAT_LG2    = 1,

    parameter       NUM_LRANKS                  = `UMCTL2_NUM_LRANKS_TOTAL,         // max supported logical ranks (chip selects * chip ID(for DDR4 3DS))
    parameter       PAGE_BITS                   = `MEMC_PAGE_BITS,
    parameter       WORD_BITS                   = `MEMC_WORD_BITS,                  // address a word within a burst
    parameter       BLK_BITS                    = `MEMC_BLK_BITS,                   // 2 column bits are critical word
    parameter       BSM_BITS                    = `UMCTL2_BSM_BITS,
    parameter       NUM_TOTAL_BANKS             = `MEMC_NUM_TOTAL_BANKS,            // max supported banks
    parameter       NUM_TOTAL_BSMS              = `UMCTL2_NUM_BSM,                  // max supported BSMs

    parameter       LRANK_BITS                  = `UMCTL2_LRANK_BITS,
    parameter       RANKBANK_BITS_FULL          = LRANK_BITS + BG_BITS + BANK_BITS,

    parameter       PHY_ADDR_BITS               = `MEMC_DFI_ADDR_WIDTH,
    parameter       PHY_MASK_WIDTH              = `MEMC_DFI_TOTAL_DATA_WIDTH/8,     // data mask width (internal to uMCTL2)
    parameter       MRS_A_BITS                  = `MEMC_PAGE_BITS,
    parameter       MRS_BA_BITS                 = `MEMC_BG_BANK_BITS,


    parameter       AM_ROW_WIDTH                = 5,

    parameter       MAX_CMD_NUM                 = 2,

    parameter       BG_BANK_BITS                = `MEMC_BG_BANK_BITS,
    parameter       RANKBANK_BITS               = LRANK_BITS + BG_BANK_BITS

    )
    (
     input                                                       core_ddrc_core_clk
    ,input                                                       core_ddrc_rstn
    ,input   [NUM_RANKS-1:0]                                     bsm_clk
    ,output  [NUM_RANKS-1:0]                                     bsm_clk_en
    ,input   [BSM_CLK_ON_WIDTH-1:0]                              bsm_clk_on

    ,dwc_ddrctl_ddrc_cpfcpe_if.o_gs_mp                            o_gs_cpfcpeif

    ,dwc_ddrctl_ddrc_cpfcpe_if.o_bs_mp                            o_bs_cpfcpeif

    ,dwc_ddrctl_ddrc_cpfcpe_if.o_os_mp                            o_os_cpfcpeif

//spyglass disable_block W240
//SMD: Input unused_w declared but not read
//SJ: Used to avoid empty modport
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_bm_bs_mp                         i_bm_bs_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_be_gs_mp                         i_be_gs_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_ih_bs_mp                         i_ih_bs_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_ih_gs_mp                         i_ih_gs_cpfcpeif
//spyglass enable_block W240

    ,dwc_ddrctl_ddrc_cpfcpe_if.i_te_bs_mp                         i_te_bs_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_te_os_mp                         i_te_os_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_te_gs_mp                         i_te_gs_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_be_os_mp                         i_be_os_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_te_pi_mp                         i_te_pi_cpfcpeif
    ,dwc_ddrctl_ddrc_cpfcpe_if.i_ih_pi_mp                         i_ih_pi_cpfcpeif


    ,input                                                       reg_ddrc_en_2t_timing_mode
    ,input  [3:0]                                                reg_ddrc_burst_rdwr_int
    ,input  [REFRESH_MARGIN_WIDTH-1:0]                           reg_ddrc_refresh_margin
    ,input  [T_RAS_MAX_WIDTH-1:0]                                reg_ddrc_t_ras_max
    ,input  [T_RAS_MIN_WIDTH-1:0]                                reg_ddrc_t_ras_min
    ,input  [T_RC_WIDTH-1:0]                                     reg_ddrc_t_rc
    ,input  [T_RCD_WIDTH-1:0]                                    reg_ddrc_t_rcd
    ,input  [T_RP_WIDTH-1:0]                                     reg_ddrc_t_rp
    ,input  [T_RRD_WIDTH-1:0]                                    reg_ddrc_t_rrd

    ,input  [RD2PRE_WIDTH-1:0]                                   reg_ddrc_rd2pre
    ,input  [WR2PRE_WIDTH-1:0]                                   reg_ddrc_wr2pre
    ,input  [RDA2PRE_WIDTH-1:0]                                  reg_ddrc_rda2pre
    ,input  [WRA2PRE_WIDTH-1:0]                                  reg_ddrc_wra2pre
    ,input                                                       reg_ddrc_pageclose
    ,input  [7:0]                                                reg_ddrc_pageclose_timer
    ,input                                                       reg_ddrc_frequency_ratio
    ,input                                                       reg_ddrc_dis_dq

    ,input  [15:0]                                               reg_ddrc_mr
    ,input  [15:0]                                               reg_ddrc_emr
    ,input  [15:0]                                               reg_ddrc_emr2
    ,input  [15:0]                                               reg_ddrc_emr3
    ,input  [15:0]                                               reg_ddrc_mr4
    ,input  [15:0]                                               reg_ddrc_mr5
    ,input  [15:0]                                               reg_ddrc_mr6
    ,input  [15:0]                                               reg_ddrc_mr22
    ,input  [PRE_CKE_X1024_WIDTH-1:0]                            reg_ddrc_pre_cke_x1024
    ,input  [POST_CKE_X1024_WIDTH-1:0]                           reg_ddrc_post_cke_x1024
    ,input  [RD2WR_WIDTH-1:0]                                    reg_ddrc_rd2wr
    ,input  [WR2RD_WIDTH-1:0]                                    reg_ddrc_wr2rd
    ,input                                                       reg_ddrc_dis_speculative_act
    ,input                                                       reg_ddrc_prefer_read
    ,input  [5:0]                                                reg_ddrc_refresh_burst
    ,input  [DFI_T_CTRLUPD_INTERVAL_MIN_X1024_WIDTH-1:0]         reg_ddrc_dfi_t_ctrlupd_interval_min_x1024
    ,input  [DFI_T_CTRLUPD_INTERVAL_MAX_X1024_WIDTH-1:0]         reg_ddrc_dfi_t_ctrlupd_interval_max_x1024
    ,input  [NUM_LRANKS-1:0]                                     reg_ddrc_rank_refresh
    ,output [NUM_LRANKS-1:0]                                     ddrc_reg_rank_refresh_busy
    ,input                                                       reg_ddrc_dis_auto_refresh
    ,input                                                       reg_ddrc_ctrlupd
    ,output                                                      ddrc_reg_ctrlupd_busy
    ,input                                                       reg_ddrc_dis_auto_ctrlupd
    ,input                                                       reg_ddrc_dis_auto_ctrlupd_srx
    ,input                                                       reg_ddrc_ctrlupd_pre_srx
    ,input                                                       reg_ddrc_mr_wr
    ,input  [3:0]                                                reg_ddrc_mr_addr
    ,input  [PAGE_BITS-1:0]                                      reg_ddrc_mr_data
    ,output                                                      ddrc_reg_mr_wr_busy
    ,input                                                       reg_ddrc_sw_init_int
    ,input                                                       reg_ddrc_mr_type
    ,input                                                       reg_ddrc_derate_enable
    ,output                                                      mrr_op_on
    ,input  [CMD_DELAY_BITS-1:0]                                 dfi_cmd_delay
    ,dwc_ddrctl_ddrc_cpedfi_if.ddrc_cpe_mp                        cpedfi_if
    ,input                                                       reg_ddrc_dfi_init_complete_en
    ,input  [DFI_T_CTRLUP_MIN_WIDTH-1:0]                         reg_ddrc_dfi_t_ctrlup_min
    ,input  [DFI_T_CTRLUP_MAX_WIDTH-1:0]                         reg_ddrc_dfi_t_ctrlup_max
    ,output [1:0]                                                gs_dh_ctrlupd_state
    ,input  [T_CCD_WIDTH-1:0]                                    reg_ddrc_t_ccd
    ,input  [T_CKE_WIDTH-1:0]                                    reg_ddrc_t_cke
    ,input  [T_FAW_WIDTH-1:0]                                    reg_ddrc_t_faw
    ,input  [T_RFC_MIN_WIDTH-1:0]                                reg_ddrc_t_rfc_min
    ,input  [T_RFC_MIN_AB_WIDTH-1:0]                             reg_ddrc_t_rfc_min_ab
    ,input  [T_PBR2PBR_WIDTH-1:0]                                reg_ddrc_t_pbr2pbr
    ,input  [T_PBR2ACT_WIDTH-1:0]                                reg_ddrc_t_pbr2act
    ,input  [T_REFI_X1_X32_WIDTH-1:0]                                   reg_ddrc_t_refi_x1_x32
    ,input                                                       reg_ddrc_t_refi_x1_sel
    ,input  [REFRESH_TO_X1_X32_WIDTH-1:0]                        reg_ddrc_refresh_to_x1_x32
    ,input                                                       reg_ddrc_prefer_write
    ,input  [6:0]                                                reg_ddrc_rdwr_idle_gap
    ,input  [POWERDOWN_EN_WIDTH-1:0]                             reg_ddrc_powerdown_en
    ,input  [POWERDOWN_TO_X32_WIDTH-1:0]                         reg_ddrc_powerdown_to_x32
    ,input  [T_XP_WIDTH-1:0]                                     reg_ddrc_t_xp
    ,input  [SELFREF_SW_WIDTH-1:0]                               reg_ddrc_selfref_sw
    ,input                                                       reg_ddrc_hw_lp_en
    ,input                                                       reg_ddrc_hw_lp_exit_idle_en
    ,input  [SELFREF_TO_X32_WIDTH-1:0]                           reg_ddrc_selfref_to_x32
    ,input  [HW_LP_IDLE_X32_WIDTH-1:0]                           reg_ddrc_hw_lp_idle_x32
    ,input                                                       hif_cmd_valid
    ,input                                                       cactive_in_ddrc_sync_or
    ,input  [NPORTS-1:0]                                         cactive_in_ddrc_async
    ,input                                                       csysreq_ddrc
    ,output                                                      csysack_ddrc
    ,output                                                      cactive_ddrc
    ,input [SELFREF_EN_WIDTH-1:0]                                reg_ddrc_selfref_en
    ,input  [NUM_RANKS-1:0]                                      reg_ddrc_mr_rank
    ,input  [T_XSR_WIDTH-1:0]                                    reg_ddrc_t_xsr
    ,input                                                       reg_ddrc_refresh_update_level
    ,input  [NUM_RANKS-1:0]                                      reg_ddrc_rank0_wr_odt
    ,input  [NUM_RANKS-1:0]                                      reg_ddrc_rank0_rd_odt

    ,output                                                      ts_pi_mwr
    ,input                                                       rt_gs_empty
    ,input                                                       mr_gs_empty
    ,input  [T_MR_WIDTH-1:0]                                     reg_ddrc_t_mr
    ,input  [WR2RD_S_WIDTH-1:0]                                  reg_ddrc_wr2rd_s
    ,input  [T_CCD_S_WIDTH-1:0]                                  reg_ddrc_t_ccd_s
    ,input  [T_RRD_S_WIDTH-1:0]                                  reg_ddrc_t_rrd_s
    ,input  [RD2WR_WIDTH-1:0]                                    reg_ddrc_rd2wr_s
    ,input  [MRR2RD_WIDTH-1:0]                                   reg_ddrc_mrr2rd
    ,input  [MRR2WR_WIDTH-1:0]                                   reg_ddrc_mrr2wr
    ,input  [MRR2MRW_WIDTH-1:0]                                  reg_ddrc_mrr2mrw
    ,input  [DRAM_RSTN_X1024_WIDTH-1:0]                          reg_ddrc_dram_rstn_x1024
    ,input  [T_ZQ_LONG_NOP_WIDTH-1:0]                            reg_ddrc_t_zq_long_nop
    ,input  [T_ZQ_SHORT_NOP_WIDTH-1:0]                           reg_ddrc_t_zq_short_nop
    ,input  [T_ZQ_SHORT_INTERVAL_X1024_WIDTH-1:0]                reg_ddrc_t_zq_short_interval_x1024
    ,input                                                       reg_ddrc_zq_calib_short
    ,output                                                      ddrc_reg_zq_calib_short_busy
    ,input                                                       reg_ddrc_dis_auto_zq
    ,input                                                       reg_ddrc_dis_srx_zqcl
    ,input                                                       reg_ddrc_zq_resistor_shared
    ,input  [READ_LATENCY_WIDTH-1:0]                             reg_ddrc_read_latency
    ,input  [WRITE_LATENCY_WIDTH-1:0]                            rl_plus_cmd_len
    ,input                                                       reg_ddrc_zq_reset
    ,input  [T_ZQ_RESET_NOP_WIDTH-1:0]                           reg_ddrc_t_zq_reset_nop
    ,output                                                      ddrc_reg_zq_reset_busy
    ,input                                                       reg_ddrc_per_bank_refresh
    ,input  [1:0]                                                reg_ddrc_auto_refab_en
    ,input  [REFRESH_TO_AB_X32_WIDTH-1:0]                        reg_ddrc_refresh_to_ab_x32
    ,output [BANK_BITS*NUM_RANKS-1:0]                            hif_refresh_req_bank
    ,input                                                       reg_ddrc_lpddr4
    ,input  [AM_ROW_WIDTH-1:0]                                   reg_ddrc_addrmap_row_b17
    ,input                                                       reg_ddrc_lpddr5
    ,input  [BANK_ORG_WIDTH-1:0]                                 reg_ddrc_bank_org
    ,input  [LPDDR4_DIFF_BANK_RWA2PRE_WIDTH-1:0]                 reg_ddrc_lpddr4_diff_bank_rwa2pre
    ,input                                                       reg_ddrc_stay_in_selfref
    ,input  [T_PPD_WIDTH-1:0]                                    reg_ddrc_t_ppd
    ,input  [T_CMDCKE_WIDTH-1:0]                                 reg_ddrc_t_cmdcke
    ,input                                                       reg_ddrc_dsm_en
    ,input  [T_PDN_WIDTH-1:0]                                    reg_ddrc_t_pdn
    ,input  [T_XSR_DSM_X1024_WIDTH-1:0]                                reg_ddrc_t_xsr_dsm_x1024
    ,input  [T_CSH_WIDTH-1:0]                                    reg_ddrc_t_csh
    ,input  [ODTLOFF_WIDTH-1:0]                                  reg_ddrc_odtloff
    ,input  [T_CCD_MW_WIDTH-1:0]                                 reg_ddrc_t_ccd_mw
    ,input  [RD2MR_WIDTH-1:0]                                    reg_ddrc_rd2mr
    ,input  [WR2MR_WIDTH-1:0]                                    reg_ddrc_wr2mr
    ,input                                                       reg_ddrc_wck_on
    ,input  [MAX_RD_SYNC_WIDTH-1:0]                              reg_ddrc_max_rd_sync
    ,input  [MAX_WR_SYNC_WIDTH-1:0]                              reg_ddrc_max_wr_sync
    ,input  [DFI_TWCK_DELAY_WIDTH-1:0]                           reg_ddrc_dfi_twck_delay
    ,input  [DFI_TWCK_EN_RD_WIDTH-1:0]                           reg_ddrc_dfi_twck_en_rd
    ,input  [DFI_TWCK_EN_WR_WIDTH-1:0]                           reg_ddrc_dfi_twck_en_wr
    ,input  [DFI_TWCK_DIS_WIDTH-1:0]                             reg_ddrc_dfi_twck_dis
    ,input  [DFI_TWCK_FAST_TOGGLE_WIDTH-1:0]                     reg_ddrc_dfi_twck_fast_toggle
    ,input  [DFI_TWCK_TOGGLE_WIDTH-1:0]                          reg_ddrc_dfi_twck_toggle
    ,input  [DFI_TWCK_TOGGLE_CS_WIDTH-1:0]                       reg_ddrc_dfi_twck_toggle_cs
    ,input  [DFI_TWCK_TOGGLE_POST_WIDTH-1:0]                     reg_ddrc_dfi_twck_toggle_post
    ,input  [7:0]                                                reg_ddrc_hpr_xact_run_length
    ,input  [15:0]                                               reg_ddrc_hpr_max_starve
    ,input  [7:0]                                                reg_ddrc_lpr_xact_run_length
    ,input  [15:0]                                               reg_ddrc_lpr_max_starve
    ,input  [7:0]                                                reg_ddrc_w_xact_run_length
    ,input  [15:0]                                               reg_ddrc_w_max_starve
    ,input                                                       hif_go2critical_lpr
    ,input                                                       hif_go2critical_hpr
    ,input                                                       hif_go2critical_wr
    ,input                                                       hif_go2critical_l1_wr
    ,input                                                       hif_go2critical_l2_wr
    ,input                                                       hif_go2critical_l1_lpr
    ,input                                                       hif_go2critical_l2_lpr
    ,input                                                       hif_go2critical_l1_hpr
    ,input                                                       hif_go2critical_l2_hpr

    ,input  [1:0]                                                wu_gs_enable_wr
    ,output [1:0]                                                gs_dh_hpr_q_state
    ,output [1:0]                                                gs_dh_lpr_q_state
    ,output [1:0]                                                gs_dh_w_q_state
    ,output [4:0]                                                gs_dh_init_curr_state
    ,output [4:0]                                                gs_dh_init_next_state
    ,output                                                      ddrc_reg_selfref_cam_not_empty
    ,output [2:0]                                                ddrc_reg_selfref_state
    ,output [2:0]                                                ddrc_reg_operating_mode_w
    ,output [SELFREF_TYPE_WIDTH-1:0]                             ddrc_reg_selfref_type
    ,output                                                      gs_pi_rd_data_pipeline_empty
    ,output                                                      gs_pi_wr_data_pipeline_empty
    ,output                                                      gs_pi_data_pipeline_empty

    ,output                                                      gs_pi_op_is_rd

    ,output                                                      gs_pi_op_is_exit_selfref
    ,input  [DFI_TPHY_WRLAT_WIDTH-1:0]                           reg_ddrc_dfi_tphy_wrlat
    ,input  [DFI_T_RDDATA_EN_WIDTH-1:0]                          reg_ddrc_dfi_t_rddata_en
    ,input  [DFI_TPHY_WRCSLAT_WIDTH-1:0]                         reg_ddrc_dfi_tphy_wrcslat
    ,input  [6:0]                                                reg_ddrc_dfi_tphy_rdcslat
    ,input                                                       reg_ddrc_dfi_data_cs_polarity
    ,input  [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0]                    reg_ddrc_dfi_t_dram_clk_enable
    ,input  [T_CKSRE_WIDTH-1:0]                                  reg_ddrc_t_cksre
    ,input  [T_CKSRX_WIDTH-1:0]                                  reg_ddrc_t_cksrx
    ,input  [T_CKCSX_WIDTH-1:0]                                  reg_ddrc_t_ckcsx
    ,input  [T_CKESR_WIDTH-1:0]                                  reg_ddrc_t_ckesr
    ,input                                                       dfi_reset_n_in
    ,output                                                      dfi_reset_n_ref
    ,input                                                       init_mr_done_in
    ,output                                                      init_mr_done_out
    ,input                                                       reg_ddrc_dfi_lp_data_req_en
    ,input                                                       reg_ddrc_dfi_lp_en_pd
    ,input  [DFI_LP_WAKEUP_PD_WIDTH-1:0]                         reg_ddrc_dfi_lp_wakeup_pd
    ,input                                                       reg_ddrc_dfi_lp_en_sr
    ,input  [DFI_LP_WAKEUP_SR_WIDTH-1:0]                         reg_ddrc_dfi_lp_wakeup_sr
    ,input                                                       reg_ddrc_dfi_lp_en_data
    ,input  [DFI_LP_WAKEUP_DATA_WIDTH-1:0]                       reg_ddrc_dfi_lp_wakeup_data
    ,input                                                       reg_ddrc_dfi_lp_en_dsm
    ,input  [DFI_LP_WAKEUP_DSM_WIDTH-1:0]                        reg_ddrc_dfi_lp_wakeup_dsm
    ,input  [DFI_TLP_RESP_WIDTH-1:0]                             reg_ddrc_dfi_tlp_resp

    ,output                                                      gs_mr_write
    ,input                                                       reg_ddrc_dfi_phyupd_en
    ,input                                                       reg_ddrc_dfi_phymstr_en
    ,input  [7:0]                                                reg_ddrc_dfi_phymstr_blk_ref_x32
    ,input                                                       reg_ddrc_dis_cam_drain_selfref
    ,input                                                       reg_ddrc_lpddr4_sr_allowed
    ,input                                                       reg_ddrc_lpddr4_opt_act_timing
    ,input                                                       reg_ddrc_lpddr5_opt_act_timing
    ,input  [DFI_T_CTRL_DELAY_WIDTH-1:0]                         reg_ddrc_dfi_t_ctrl_delay
    ,input  [DFI_T_WRDATA_DELAY_WIDTH-1:0]                       reg_ddrc_dfi_t_wrdata_delay
    ,input  [1:0]                                                reg_ddrc_skip_dram_init
    ,input                                                       reg_ddrc_opt_wrcam_fill_level
    ,input  [3:0]                                                reg_ddrc_delay_switch_write
    ,input  [WR_CAM_ADDR_WIDTH-1:0]                              reg_ddrc_wr_pghit_num_thresh
    ,input  [RD_CAM_ADDR_WIDTH-1:0]                              reg_ddrc_rd_pghit_num_thresh
    ,input  [WR_CAM_ADDR_WIDTH-1:0]                              reg_ddrc_wrcam_highthresh
    ,input  [WR_CAM_ADDR_WIDTH-1:0]                              reg_ddrc_wrcam_lowthresh
    ,input  [7:0]                                                reg_ddrc_wr_page_exp_cycles
    ,input  [7:0]                                                reg_ddrc_rd_page_exp_cycles
    ,input  [7:0]                                                reg_ddrc_wr_act_idle_gap
    ,input  [7:0]                                                reg_ddrc_rd_act_idle_gap
    ,input                                                       reg_ddrc_dis_opt_ntt_by_act

    ,input                                                       reg_ddrc_en_dfi_dram_clk_disable
    ,input  [DFI_T_DRAM_CLK_DISABLE_WIDTH-1:0]                   reg_ddrc_dfi_t_dram_clk_disable
    ,input  [3:0]                                                reg_ddrc_burst_rdwr


    ,output                                                      pi_rt_rd_vld
    ,output [CMD_LEN_BITS-1:0]                                   pi_rt_rd_partial
    ,output [WR_CAM_ADDR_WIDTH-1:0]                              pi_rt_wr_ram_addr
    ,output [RMW_TYPE_BITS-1:0]                                  pi_rt_rmwtype
    ,output                                                      pi_rt_rd_mrr_ext
    ,output                                                      pi_rt_rd_mrr
    ,output [CORE_TAG_WIDTH-1:0]                                 pi_rt_rd_tag
    ,output                                                      pi_rt_rd_addr_err
    ,output [RANKBANK_BITS_FULL-1:0]                             pi_rt_rankbank_num
    ,output [PAGE_BITS-1:0]                                      pi_rt_page_num
    ,output [BLK_BITS-1:0]                                       pi_rt_block_num
    ,output [WORD_BITS-1:0]                                      pi_rt_critical_word
    ,input  [6:0]                                                mr_t_rddata_en
    ,input  [DFI_TPHY_WRLAT_WIDTH-1:0]                           mr_t_wrlat
    ,input  [DFI_TWCK_EN_RD_WIDTH-2:0]                           mr_lp_data_rd
    ,input  [DFI_TWCK_EN_WR_WIDTH-2:0]                           mr_lp_data_wr
    ,output                                                      pi_ph_dfi_rddata_en
    ,output [`MEMC_FREQ_RATIO-1:0]                               pi_ph_dfi_wrdata_en
    ,output [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]                     ddrc_phy_cs
    ,input                                                       reg_ddrc_lpddr4_refresh_mode
    ,input  [ACTIVE_DERATE_BYTE_RANK_WIDTH-1:0]                       reg_ddrc_active_derate_byte_rank0
    ,output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte0_rank0
    ,output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte1_rank0
    ,output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte2_rank0
    ,output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte3_rank0
    ,output                                                      core_derate_temp_limit_intr
    ,input  [MR4_READ_INTERVAL_WIDTH-1:0]                        reg_ddrc_mr4_read_interval
    ,input                                                       derate_sync_ack_c2p
    ,input  [DERATED_T_RCD_WIDTH-1:0]                            reg_ddrc_derated_t_rcd
    ,input  [DERATED_T_RAS_MIN_WIDTH-1:0]                        reg_ddrc_derated_t_ras_min
    ,input  [DERATED_T_RP_WIDTH-1:0]                             reg_ddrc_derated_t_rp
    ,input  [DERATED_T_RRD_WIDTH-1:0]                            reg_ddrc_derated_t_rrd
    ,input  [DERATED_T_RC_WIDTH-1:0]                             reg_ddrc_derated_t_rc
    ,input                                                       reg_ddrc_derate_mr4_tuf_dis
    ,input                                                       reg_ddrc_derate_mr4_pause_fc
    ,input                                                       rt_rd_rd_mrr_ext
    ,input                                                       rd_mr4_data_valid

    ,input                                                       reg_ddrc_dis_trefi_x6x8
    ,input                                                       reg_ddrc_dis_trefi_x0125

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in only under MEMC_LPDDR2 in this file but signal should always exist for `ifdef MEMC_DDR4
    ,input  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]                    hif_mrr_data
//spyglass enable_block W240

    ,input  [5:0]                                                mr_t_wrdata
    ,input  [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]                     ddrc_phy_csn

    ,input                                                       reg_ddrc_dfi_init_start
    ,input  [4:0]                                                reg_ddrc_dfi_frequency
    ,output [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]                     dfi_wck_cs
    ,output [`MEMC_FREQ_RATIO-1:0]                               dfi_wck_en
    ,output [2*`MEMC_FREQ_RATIO-1:0]                             dfi_wck_toggle


`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
    ,input  [WR_CAM_ENTRIES_IE-1:0]                              te_ts_wr_entry_valid  // valid write entry in CAM, over entire CAM
    ,input  [WR_CAM_ENTRIES-1:0]                                 te_ts_rd_entry_valid  // valid read entry in CAM, over entire CAM
    ,input  [WR_CAM_ENTRIES_IE-1:0]                              te_ts_wr_page_hit_entries  // page-hit entry in CAM
    ,input  [RD_CAM_ENTRIES-1:0]                                 te_ts_rd_page_hit_entries
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

    ,input                                                reg_ddrc_dqsosc_enable                 // DQSOSC enable
    ,input  [T_OSCO_WIDTH-1:0]                            reg_ddrc_t_osco                        // t_osco timing
    ,input  [7:0]                                         reg_ddrc_dqsosc_runtime                // Oscillator runtime
    ,input  [7:0]                                         reg_ddrc_wck2dqo_runtime               // Oscillator runtime only for LPDDR5
    ,input  [11:0]                                        reg_ddrc_dqsosc_interval               // DQSOSC inverval
    ,input                                                reg_ddrc_dqsosc_interval_unit          // DQSOSC interval unit
    ,input                                                reg_ddrc_dis_dqsosc_srx
    ,output [2:0]                                         dqsosc_state
    ,output [NUM_RANKS-1:0]                               dqsosc_per_rank_stat
    ,output [3:0]                                         pi_ph_snoop_en
    ,output                                               pi_rt_rd_mrr_snoop
    ,input logic  [DFI_T_CTRLMSG_RESP_WIDTH-1:0]  reg_ddrc_dfi_t_ctrlmsg_resp
    ,input logic                                  reg_ddrc_dfi0_ctrlmsg_req
    ,input logic                                  reg_ddrc_dfi0_ctrlmsg_tout_clr
    ,input logic [DFI_CTRLMSG_CMD_WIDTH-1:0]      reg_ddrc_dfi0_ctrlmsg_cmd
    ,input logic [DFI_CTRLMSG_DATA_WIDTH-1:0]     reg_ddrc_dfi0_ctrlmsg_data
    ,output logic                                 ddrc_reg_dfi0_ctrlmsg_resp_tout
    ,output logic                                 ddrc_reg_dfi0_ctrlmsg_req_busy
    ,output logic [PARTIAL_WR_BITS_LOG2-1:0]              gs_pi_rdwr_ram_raddr_lsb_first
    ,output logic [PW_WORD_CNT_WD_MAX-1:0]                gs_pi_rdwr_pw_num_beats_m1
    );



localparam DDRCTL_DDR_EN                       = `DDRCTL_DDR_EN;
localparam SELFREF_TYPE_WIDTH_INT = (`DDRCTL_DDR_EN == 1) ? SELFREF_TYPE_WIDTH/NUM_RANKS : SELFREF_TYPE_WIDTH;
localparam SELFREF_EN_WIDTH_INT = (`DDRCTL_DDR_EN == 1) ? SELFREF_EN_WIDTH/NUM_RANKS : SELFREF_EN_WIDTH;
localparam POWERDOWN_EN_WIDTH_INT = (`DDRCTL_DDR_EN == 1) ? POWERDOWN_EN_WIDTH/NUM_RANKS : POWERDOWN_EN_WIDTH;

wire [SELFREF_TYPE_WIDTH_INT-1:0]                                ddrc_reg_selfref_type_w;
generate
   if (DDRCTL_DDR_EN == 1) begin : DDR_ctrl
     assign ddrc_reg_selfref_type = {{($bits(ddrc_reg_selfref_type)-$bits(ddrc_reg_selfref_type_w)){1'b0}},ddrc_reg_selfref_type_w};
   end else begin : LPDDR_ctrl
     assign ddrc_reg_selfref_type = ddrc_reg_selfref_type_w;
   end
endgenerate

wire [SELFREF_EN_WIDTH_INT-1:0]                                reg_ddrc_selfref_en_w;
// MSB are not used in DDR4 controller
assign reg_ddrc_selfref_en_w = reg_ddrc_selfref_en[$bits(reg_ddrc_selfref_en_w)-1:0];

wire [POWERDOWN_EN_WIDTH_INT-1:0]                                reg_ddrc_powerdown_en_w;
// MSB are not used in DDR4 controller
assign reg_ddrc_powerdown_en_w = reg_ddrc_powerdown_en[$bits(reg_ddrc_powerdown_en_w)-1:0];

    wire    [T_RAS_MIN_WIDTH-1:0]                                derate_ddrc_t_ras_min;
    wire    [T_RC_WIDTH-1:0]                                     derate_ddrc_t_rc;
    wire    [T_RCD_WIDTH-1:0]                                    derate_ddrc_t_rcd;
    wire    [T_RP_WIDTH-1:0]                                     derate_ddrc_t_rp;
    wire    [T_RRD_WIDTH-1:0]                                    derate_ddrc_t_rrd;
    wire    [T_RRD_S_WIDTH-1:0]                                  derate_ddrc_t_rrd_s;
    wire                                                         phy_dfi_init_complete;
    wire                                                         ddrc_dfi_ctrlupd_req;
    wire    [T_REFI_X1_X32_WIDTH+4:0]                                   derate_ddrc_t_refie;
    wire    [T_REFI_X1_X32_WIDTH+4:0]                                   derate_ddrc_t_refi;
    wire    [5:0]                                                max_postponed_ref_cmd;
    wire    [4:0]                                                max_ref_cmd_within_2trefi;
    wire                                                         derate_refresh_update_level;
    wire    [PAGE_BITS-1:0]                                      os_te_rdwr_page_unused;
    wire                                                         gs_pi_dram_rst_n;
    wire                                                         pi_gs_ctrlupd_ok;
    wire                                                         pi_gs_noxact;
    wire                                                         pi_gs_rd_vld;
    wire                                                         gs_pi_ctrlupd_req;

    wire                                                         gs_op_is_rd;
    wire                                                         gs_op_is_wr;
    wire                                                         gs_op_is_act;
    wire                                                         gs_op_is_pre;
    wire                                                         gs_op_is_ref;
    wire                                                         gs_op_is_enter_selfref;
    wire                                                         gs_op_is_exit_selfref;
    wire                                                         gs_op_is_enter_powerdown;
    wire                                                         gs_op_is_exit_powerdown;
    wire                                                         gs_op_is_load_mode;

    wire [BSM_BITS-1:0]                                          gs_rdwr_bsm_num;                   // BSM # for read & write commands
    wire [BSM_BITS-1:0]                                          gs_act_bsm_num;                    // BSM # for activate
    wire [BSM_BITS-1:0]                                          gs_pre_bsm_num;                    // BSM # for precharge

    wire [RANKBANK_BITS-1:0]                                     gs_pre_rankbank_num;                 // bank number to precharge the DRAM address for
    wire [RANKBANK_BITS-1:0]                                     gs_rdwr_rankbank_num;                // bank number to read/write the DRAM address for
    wire [RANKBANK_BITS-1:0]                                     gs_act_rankbank_num;                 // bank number to activate the DRAM address for

    wire [BANK_BITS-1:0]                                         gs_pi_refpb_bank;
    wire                                                         gs_cas_ws_req;
    wire                                                         pi_rdwr_ok;
    wire                                                         pi_lp5_act2_cmd;
    wire                                                         pi_lp5_noxact;
    wire                                                         pi_lp5_preref_ok;
    wire                                                         pi_col_b3;


    wire                                                         gs_pi_init_cke;
    wire    [MRS_A_BITS-1:0]                                     gs_pi_mrs_a;
    wire                                                         gs_pi_init_in_progress;
    wire    [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]                   gs_pi_odt;
    wire                                                         gs_pi_odt_pending;
    wire    [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0]       gs_pi_wrdata_cs_n;
    wire    [`MEMC_FREQ_RATIO * NUM_RANKS * NUM_LANES-1:0]       gs_pi_rddata_cs_n;
    wire                                                         gs_pi_pads_powerdown_unused;
    wire                                                         gs_pi_pads_selfref_unused;
    wire                                                         gs_op_is_enter_sr_lpddr;
    wire                                                         gs_op_is_exit_sr_lpddr;
    wire                                                         gs_op_is_enter_dsm;
    wire                                                         gs_op_is_exit_dsm;
    wire                                                         gs_wck_stop_ok;
    wire                                                         gs_mpc_zq_start;
    wire                                                         gs_mpc_zq_latch;
    wire                                                         gs_op_is_cas_ws_off;
    wire                                                         gs_pi_stop_clk_ok;
    wire    [1:0]                                                gs_pi_stop_clk_type;
    wire                                                         dfilp_ctrl_lp;
    wire                                                         pi_gs_stop_clk_early;
    wire    [1:0]                                                pi_gs_stop_clk_type;
    wire                                                         pi_gs_dfilp_wait;
    wire                                                         dfi_lp_ctrl_req_int;
    wire    [DFI_LP_WAKEUP_PD_WIDTH-1:0]                         dfi_lp_ctrl_wakeup_int;
    wire                                                         dfi_lp_data_req_int;
    wire    [DFI_LP_WAKEUP_PD_WIDTH-1:0]                         dfi_lp_data_wakeup_int;
    wire                                                         gs_pi_mrr;
    wire                                                         gs_pi_mrr_ext;
    wire                                                         mr4_req;
    wire                                                         phy_dfi_phyupd_req;
    wire                                                         dfi_phyupd_ack_int;
    wire                                                         dfi_phymstr_ack_int;
    wire                                                         gs_pi_phyupd_pause_req;
    wire                                                         pi_gs_phyupd_pause_ok;
    wire                                                         gs_pi_dfi_lp_changing;

    wire    [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]                     ddrc_phy_cke;
    wire    [`MEMC_FREQ_RATIO-1:0]                               ddrc_phy_rasn;
    wire    [`MEMC_FREQ_RATIO-1:0]                               ddrc_phy_casn;
    wire    [`MEMC_FREQ_RATIO-1:0]                               ddrc_phy_wen;
    wire    [`MEMC_FREQ_RATIO*BANK_BITS-1:0]                     ddrc_phy_ba;
    dfi_address_s                                                ddrc_phy_addr;
    wire                                                         ddrc_phy_stop_clk;
    wire                                                         ddrc_phy_dram_rst_n;
    wire    [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]                     ddrc_phy_odt;
    wire    [`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES-1:0]           ddrc_phy_wrdata_cs_n;
    wire    [`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES-1:0]           ddrc_phy_rddata_cs_n;
    wire                                                         clock_gating_en_int_unused;



    wire [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]                        gs_dfi_wck_cs;
    wire [`MEMC_FREQ_RATIO-1:0]                                  gs_dfi_wck_en;
    wire [2*`MEMC_FREQ_RATIO-1:0]                                gs_dfi_wck_toggle;
    wire                                                         dfilp_block_dfi_ctrlmsg;


    wire    [PAGE_BITS-1:0]                                      ts_act_page;
    wire                                               ts_act2_invalid_tmg;
    wire                                                         gs_mpc_dqsosc_start;
    wire [3:0]                                                   gs_pi_mrr_snoop_en;

    wire [CMD_LEN_BITS-1:0]                            gs_pi_rd_length;
    wire [WORD_BITS-1:0]                               gs_pi_rd_critical_word;
   // extend dfi_parity_in to 2 bits for each phase
    logic [`MEMC_FREQ_RATIO-1:0]                                 dfi_parity_in_w;


    wire                                                         os_te_autopre;

    wire                                                         gs_te_pri_level;
    wire [NUM_TOTAL_BSMS-1:0]                                    ts_te_sel_act_wr;
    wire [MAX_CAM_ADDR_WIDTH-1:0]                                os_te_rdwr_entry;


    wire    [PARTIAL_WR_BITS_LOG2-1:0]              gs_pi_rdwr_ram_raddr_lsb_first_w;
    wire    [PW_WORD_CNT_WD_MAX-1:0]                gs_pi_rdwr_pw_num_beats_m1_w;
    wire                                            gs_mr_write_w;


    wire    [T_CCD_WIDTH-1:0]                       reg_ddrc_t_ccd_int;
    wire    [T_RCD_WIDTH-1:0]                       reg_ddrc_t_rcd_int;
    assign reg_ddrc_t_ccd_int = reg_ddrc_t_ccd;
    assign reg_ddrc_t_rcd_int = reg_ddrc_t_rcd;


    assign   gs_pi_rdwr_ram_raddr_lsb_first  = gs_pi_rdwr_ram_raddr_lsb_first_w;
    assign   gs_pi_rdwr_pw_num_beats_m1      = gs_pi_rdwr_pw_num_beats_m1_w;
    assign   gs_mr_write                     = gs_mr_write_w;

   generate
      for (genvar i=0; i<`MEMC_FREQ_RATIO; i++) begin
         assign cpedfi_if.dfi_parity_in[i*2 +: 2] = {1'b0, dfi_parity_in_w[i]};
      end
   endgenerate

   // assignment for case of unsupported features
   generate
      if (`MEMC_DDR4_EN == 0) begin
         assign cpedfi_if.dfi_bg          = {(`MEMC_FREQ_RATIO*BG_BITS_DUP){1'b0}}; // note use of <param>_DUP
         assign cpedfi_if.dfi_act_n       = {`MEMC_FREQ_RATIO{1'b0}};
      end
      if ((`MEMC_DDR4_EN == 0) || (`MEMC_CMD_RTN2IDLE_EN == 1)) begin
         assign cpedfi_if.dfi_2n_mode     = 1'b0; // No geardown mode support
      end
      if (`DDRCTL_DDRC_CID_WIDTH == 0) begin
         assign cpedfi_if.dfi_cid         = {(`MEMC_FREQ_RATIO*CID_WIDTH_DUP){1'b0}}; // note use of <param>_DUP
      end
      if (`UMCTL2_HWFFC_EN_VAL == 0) begin
         assign cpedfi_if.dfi_frequency   = reg_ddrc_dfi_frequency;
      end
   endgenerate


// -------------------------------------------------------------------------------------


assign gs_mr_write_w                = gs_op_is_wr;
assign gs_pi_op_is_rd               = gs_op_is_rd;
assign gs_pi_op_is_exit_selfref     = gs_op_is_exit_selfref;





//----------------------------------------------------------------------------
assign o_bs_cpfcpeif.ts_act_page    = ts_act_page;

assign o_gs_cpfcpeif.gs_be_op_is_activate  = gs_op_is_act;
assign o_gs_cpfcpeif.gs_be_op_is_precharge = gs_op_is_pre;
assign o_gs_cpfcpeif.gs_be_op_is_rdwr      = gs_op_is_rd | gs_op_is_wr;
assign o_gs_cpfcpeif.gs_be_rdwr_bsm_num    = gs_rdwr_bsm_num;
assign o_gs_cpfcpeif.gs_be_act_bsm_num     = gs_act_bsm_num;
assign o_gs_cpfcpeif.gs_be_pre_bsm_num     = gs_pre_bsm_num;
assign o_gs_cpfcpeif.gs_te_op_is_rd        = gs_op_is_rd;
assign o_gs_cpfcpeif.gs_te_op_is_wr        = gs_op_is_wr;
assign o_gs_cpfcpeif.gs_te_op_is_activate  = gs_op_is_act;
assign o_gs_cpfcpeif.gs_te_op_is_precharge = gs_op_is_pre;
assign o_gs_cpfcpeif.gs_te_bsm_num4pre     = gs_pre_bsm_num;
assign o_gs_cpfcpeif.gs_te_bsm_num4rdwr    = gs_rdwr_bsm_num;
assign o_gs_cpfcpeif.gs_te_bsm_num4act     = gs_act_bsm_num;

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
assign o_gs_cpfcpeif.gs_te_rd_length = gs_pi_rd_length;
assign o_gs_cpfcpeif.gs_te_rd_word   = gs_pi_rd_critical_word;
assign o_gs_cpfcpeif.gs_te_raddr_lsb_first = gs_pi_rdwr_ram_raddr_lsb_first;
assign o_gs_cpfcpeif.gs_te_pw_num_beats_m1 = gs_pi_rdwr_pw_num_beats_m1;
`endif //SYNTHESIS
`endif //SNPS_ASSERT_ON


assign o_os_cpfcpeif.os_te_autopre = os_te_autopre;

assign o_gs_cpfcpeif.gs_te_pri_level = gs_te_pri_level;
assign o_bs_cpfcpeif.ts_te_sel_act_wr = ts_te_sel_act_wr;
assign o_os_cpfcpeif.os_te_rdwr_entry = os_te_rdwr_entry;


wire per_bank_refresh_int;
wire derate_force_refab;

// -------------------------------------------------------------------------------------
ts
      #(
                .CHANNEL_NUM                    (CHANNEL_NUM),
                .SHARED_AC                      (SHARED_AC),
                .RANK_BITS                      (RANK_BITS),
                .BANK_BITS                      (BANK_BITS),
                .MWR_BITS                       (MWR_BITS),
                .PW_WORD_CNT_WD_MAX             (PW_WORD_CNT_WD_MAX),
                .PARTIAL_WR_BITS_LOG2           (PARTIAL_WR_BITS_LOG2),
                .BCM_VERIF_EN                   (BCM_VERIF_EN),
                .BCM_DDRC_N_SYNC                (BCM_DDRC_N_SYNC),
                .NUM_LANES                      (NUM_LANES),
                .SELFREF_TYPE_WIDTH_INT         (SELFREF_TYPE_WIDTH_INT),
                .SELFREF_SW_WIDTH_INT           (SELFREF_SW_WIDTH),
                .SELFREF_EN_WIDTH_INT           (SELFREF_EN_WIDTH_INT),
                .POWERDOWN_EN_WIDTH_INT         (POWERDOWN_EN_WIDTH_INT),
                .AUTOPRE_BITS                   (AUTOPRE_BITS),
                .NPORTS                         (NPORTS),
                .A_SYNC_TABLE                   (A_SYNC_TABLE),
                .OCPAR_EN                       (OCPAR_EN),
                .RD_CAM_ENTRIES                 (RD_CAM_ENTRIES),
                .WR_CAM_ENTRIES                 (WR_CAM_ENTRIES),
                .WR_CAM_ENTRIES_IE              (WR_CAM_ENTRIES_IE),
                .RD_CAM_ADDR_BITS               (RD_CAM_ADDR_WIDTH),
                .WR_CAM_ADDR_BITS               (WR_CAM_ADDR_WIDTH),
                .WR_CAM_ADDR_BITS_IE            (WR_CAM_ADDR_WIDTH_IE),
                .MAX_CAM_ADDR_BITS              (MAX_CAM_ADDR_WIDTH),
                .MAX_CMD_DELAY                  (MAX_CMD_DELAY),
                .IE_TAG_BITS                    (IE_TAG_BITS),
                .CMD_LEN_BITS                   (CMD_LEN_BITS),
                .WORD_BITS                      (WORD_BITS),
                .CMD_DELAY_BITS                 (CMD_DELAY_BITS)
                )
        ts (
                .co_yy_clk                      (core_ddrc_core_clk),
                .core_ddrc_rstn                 (core_ddrc_rstn),
                .bsm_clk                        (bsm_clk           ),
                .bsm_clk_en                     (bsm_clk_en        ),
                .bsm_clk_on                     (bsm_clk_on        ),
                .dh_gs_2t_mode                  (reg_ddrc_en_2t_timing_mode),
                .dh_gs_burst_rdwr               (reg_ddrc_burst_rdwr_int),
                .dh_gs_refresh_margin           (reg_ddrc_refresh_margin),
                .dh_bs_t_ras_max                (reg_ddrc_t_ras_max),
                .dh_bs_t_ras_min                (derate_ddrc_t_ras_min),
                .dh_bs_t_rc                     (derate_ddrc_t_rc),
                .dh_bs_t_rcd                    (derate_ddrc_t_rcd),
                .dh_bs_t_rp                     (derate_ddrc_t_rp),
                .dh_bs_t_rrd                    (derate_ddrc_t_rrd),
                .dh_gs_t_rrd_s                  (derate_ddrc_t_rrd_s),
                .dh_bs_rd2pre                   (reg_ddrc_rd2pre),
                .dh_bs_wr2pre                   (reg_ddrc_wr2pre),
                .reg_ddrc_rda2pre               (reg_ddrc_rda2pre),
                .reg_ddrc_wra2pre               (reg_ddrc_wra2pre),
                .dh_bs_pageclose                (reg_ddrc_pageclose),
                .dh_bs_pageclose_timer          (reg_ddrc_pageclose_timer),
                .dh_bs_frequency_ratio          (reg_ddrc_frequency_ratio),
                .dh_gs_dis_dq                   (reg_ddrc_dis_dq),
                .dh_gs_mr                       (reg_ddrc_mr),
                .dh_gs_emr                      (reg_ddrc_emr),
                .dh_gs_emr2                     (reg_ddrc_emr2),
                .dh_gs_emr3                     (reg_ddrc_emr3),
                .dh_gs_mr4                      (reg_ddrc_mr4),
                .dh_gs_mr5                      (reg_ddrc_mr5),
                .dh_gs_mr6                      (reg_ddrc_mr6),
                .dh_gs_mr22                     (reg_ddrc_mr22),
                .dh_gs_pre_cke_x1024            (reg_ddrc_pre_cke_x1024),
                .dh_gs_post_cke_x1024           (reg_ddrc_post_cke_x1024),
                .dh_gs_rd2wr                    (reg_ddrc_rd2wr),
                .dh_bs_wr2rd                    (reg_ddrc_wr2rd),

                .reg_ddrc_dis_speculative_act  (reg_ddrc_dis_speculative_act),
                .reg_ddrc_prefer_read           (reg_ddrc_prefer_read),
                .dh_gs_refresh_burst            (reg_ddrc_refresh_burst),

                .dh_gs_ctrlupd_min_to_x1024     (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024),
                .dh_gs_ctrlupd_max_to_x1024     (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024),

                .dh_gs_rank_refresh             (reg_ddrc_rank_refresh),
                .gs_dh_rank_refresh_busy        (ddrc_reg_rank_refresh_busy),
                .dh_gs_dis_auto_refresh         (reg_ddrc_dis_auto_refresh),
                .dh_gs_ctrlupd                  (reg_ddrc_ctrlupd),
                .gs_dh_ctrlupd_busy             (ddrc_reg_ctrlupd_busy),
                .dh_gs_dis_auto_ctrlupd         (reg_ddrc_dis_auto_ctrlupd),
                .dh_gs_dis_auto_ctrlupd_srx     (reg_ddrc_dis_auto_ctrlupd_srx),
                .dh_gs_ctrlupd_pre_srx          (reg_ddrc_ctrlupd_pre_srx),
                .dh_gs_mr_wr                    (reg_ddrc_mr_wr),
                .dh_gs_mr_addr                  (reg_ddrc_mr_addr),
                .dh_gs_mr_data                  (reg_ddrc_mr_data),
                .gs_dh_mr_wr_busy               (ddrc_reg_mr_wr_busy),
                .dh_gs_sw_init_int              (reg_ddrc_sw_init_int),
                .dh_gs_mr_type                  (reg_ddrc_mr_type),
                .dh_gs_derate_enable            (reg_ddrc_derate_enable),
                .mrr_op_on                      (mrr_op_on),

                .dfi_cmd_delay                  (dfi_cmd_delay),
                .mr_lp_data_rd                  (mr_lp_data_rd),
                .mr_lp_data_wr                  (mr_lp_data_wr),


                .phy_dfi_ctrlupd_ack1           (cpedfi_if.dfi_ctrlupd_ack),
                .phy_dfi_init_complete          (phy_dfi_init_complete),
                .dh_gs_dfi_init_complete_en     (reg_ddrc_dfi_init_complete_en),
                .ddrc_dfi_ctrlupd_req           (ddrc_dfi_ctrlupd_req),
                .dh_gs_dfi_t_ctrlup_min         (reg_ddrc_dfi_t_ctrlup_min),
                .dh_gs_dfi_t_ctrlup_max         (reg_ddrc_dfi_t_ctrlup_max),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Debug pin. Not currently used in all configs.
                .gs_dh_ctrlupd_state            (gs_dh_ctrlupd_state),
//spyglass enable_block W528
                .dh_bs_t_ccd                    (reg_ddrc_t_ccd_int),
                .dh_gs_t_cke                    (reg_ddrc_t_cke),
                .dh_gs_t_faw                    (reg_ddrc_t_faw),
                .dh_gs_t_rfc_min                (reg_ddrc_t_rfc_min),
                .dh_gs_t_rfc_min_ab             (reg_ddrc_t_rfc_min_ab),
                .dh_gs_t_pbr2pbr                (reg_ddrc_t_pbr2pbr),
                .dh_gs_t_pbr2act                (reg_ddrc_t_pbr2act),
                .derate_gs_t_refie              (derate_ddrc_t_refie),
                .derate_gs_t_refi               (derate_ddrc_t_refi),
                .max_postponed_ref_cmd          (max_postponed_ref_cmd),
                .max_ref_cmd_within_2trefi      (max_ref_cmd_within_2trefi),
                .dh_gs_t_refi_x1_x32            (reg_ddrc_t_refi_x1_x32),
                .dh_gs_t_refi_x1_sel            (reg_ddrc_t_refi_x1_sel),
                .dh_gs_refresh_to_x1_x32        (reg_ddrc_refresh_to_x1_x32),
                .dh_gs_prefer_write             (reg_ddrc_prefer_write),
                .dh_gs_rdwr_idle_gap            (reg_ddrc_rdwr_idle_gap),
                .dh_gs_powerdown_en             (reg_ddrc_powerdown_en_w),
                .dh_gs_powerdown_to_x32         (reg_ddrc_powerdown_to_x32),
                .dh_gs_t_xp                     (reg_ddrc_t_xp),

                .reg_ddrc_selfref_sw            (reg_ddrc_selfref_sw),
                .reg_ddrc_hw_lp_en              (reg_ddrc_hw_lp_en),
                .reg_ddrc_hw_lp_exit_idle_en    (reg_ddrc_hw_lp_exit_idle_en),
                .reg_ddrc_selfref_to_x32        (reg_ddrc_selfref_to_x32),
                .reg_ddrc_hw_lp_idle_x32        (reg_ddrc_hw_lp_idle_x32),
                .ih_busy                        (i_ih_gs_cpfcpeif.ih_busy),
                .hif_cmd_valid                  (hif_cmd_valid),
                .gsfsm_sr_co_if_stall           (o_gs_cpfcpeif.gsfsm_sr_co_if_stall),
                .cactive_in_ddrc_sync_or        (cactive_in_ddrc_sync_or),
                .cactive_in_ddrc_async          (cactive_in_ddrc_async),
                .csysreq_ddrc                   (csysreq_ddrc),
                .csysack_ddrc                   (csysack_ddrc),
                .cactive_ddrc                   (cactive_ddrc),

                .dh_gs_selfref_en               (reg_ddrc_selfref_en_w),
                .dh_gs_mr_rank                  (reg_ddrc_mr_rank),
                .dh_gs_t_xsr                    (reg_ddrc_t_xsr),

                .dh_gs_refresh_update_level     (reg_ddrc_refresh_update_level),
                .derate_refresh_update_level    (derate_refresh_update_level),

                .dh_gs_rank0_wr_odt             (reg_ddrc_rank0_wr_odt),
                .dh_gs_rank0_rd_odt             (reg_ddrc_rank0_rd_odt),

                .be_os_page_table               (i_be_os_cpfcpeif.be_os_page_table),
                .os_te_rdwr_page                (os_te_rdwr_page_unused),
                .te_os_rd_entry_table           (i_te_os_cpfcpeif.te_os_rd_entry_table),
                .te_os_wr_entry_table           (i_te_os_cpfcpeif.te_os_wr_entry_table),

                .te_os_rd_page_table            (i_te_os_cpfcpeif.te_os_rd_page_table),
                .te_os_wr_page_table            (i_te_os_cpfcpeif.te_os_wr_page_table),
                .te_os_rd_cmd_autopre_table     (i_te_os_cpfcpeif.te_os_rd_cmd_autopre_table),
                .te_os_wr_cmd_autopre_table     (i_te_os_cpfcpeif.te_os_wr_cmd_autopre_table),
                .te_os_rd_pageclose_autopre     (i_te_os_cpfcpeif.te_os_rd_pageclose_autopre),
                .te_os_wr_pageclose_autopre     (i_te_os_cpfcpeif.te_os_wr_pageclose_autopre),
                .te_os_rd_cmd_length_table      (i_te_os_cpfcpeif.te_os_rd_length_table),
                .te_os_rd_critical_word_table   (i_te_os_cpfcpeif.te_os_rd_critical_word_table),
                .te_os_wr_mr_ram_raddr_lsb_first_table (i_te_os_cpfcpeif.te_os_wr_mr_ram_raddr_lsb_first_table),
                .te_os_wr_mr_pw_num_beats_m1_table     (i_te_os_cpfcpeif.te_os_wr_mr_pw_num_beats_m1_table),
                .te_os_mwr_table                (i_te_os_cpfcpeif.te_os_mwr_table),
                .te_b3_bit                      (i_te_os_cpfcpeif.te_b3_bit),
              //.os_te_rdwr_entry               (o_os_cpfcpeif.os_te_rdwr_entry),
                .os_te_rdwr_entry               (os_te_rdwr_entry),
                .ts_pi_mwr                      (ts_pi_mwr),
                .rt_gs_empty                    (rt_gs_empty),
                .mr_gs_empty                    (mr_gs_empty),
                .reg_ddrc_t_mr                  (reg_ddrc_t_mr),
                .dh_bs_wr2rd_s                  (reg_ddrc_wr2rd_s),
                .dh_bs_t_ccd_s                  (reg_ddrc_t_ccd_s),
                .reg_ddrc_rd2wr_s               (reg_ddrc_rd2wr_s),
                .reg_ddrc_mrr2rd                (reg_ddrc_mrr2rd),
                .reg_ddrc_mrr2wr                (reg_ddrc_mrr2wr),
                .reg_ddrc_mrr2mrw               (reg_ddrc_mrr2mrw),
                .dh_gs_dram_rstn_x1024          (reg_ddrc_dram_rstn_x1024),   // time for dram reset to stay low
                .gs_pi_dram_rst_n               (gs_pi_dram_rst_n),         // ddrc to dram active low reset
                .dh_gs_t_zq_long_nop            (reg_ddrc_t_zq_long_nop),  // time to wait in ZQCL during init sequence
                .dh_gs_t_zq_short_nop           (reg_ddrc_t_zq_short_nop), // time to wait in ZQCS during init sequence
                .dh_gs_t_zq_short_interval_x1024  (reg_ddrc_t_zq_short_interval_x1024),
                .dh_gs_zq_calib_short           (reg_ddrc_zq_calib_short),
                .gs_dh_zq_calib_short_busy      (ddrc_reg_zq_calib_short_busy),
                .dh_gs_dis_auto_zq              (reg_ddrc_dis_auto_zq),
                .dh_gs_dis_srx_zqcl             (reg_ddrc_dis_srx_zqcl),
                .dh_gs_zq_resistor_shared       (reg_ddrc_zq_resistor_shared),

                .dh_gs_read_latency             (reg_ddrc_read_latency),
                .dh_gs_write_latency            (rl_plus_cmd_len),

                .dh_gs_zq_reset                 (reg_ddrc_zq_reset),
                .dh_gs_t_zq_reset_nop           (reg_ddrc_t_zq_reset_nop),
                .gs_dh_zq_reset_busy            (ddrc_reg_zq_reset_busy),
                .dh_gs_per_bank_refresh         (reg_ddrc_per_bank_refresh),
                .per_bank_refresh_int           (per_bank_refresh_int),
                .derate_force_refab             (derate_force_refab),
                .reg_ddrc_refresh_to_ab_x32     (reg_ddrc_refresh_to_ab_x32),
                .hif_refresh_req_bank           (hif_refresh_req_bank),
                .dh_gs_lpddr4                   (reg_ddrc_lpddr4),
                .reg_ddrc_lpddr5                (reg_ddrc_lpddr5),
                .reg_ddrc_bank_org              (reg_ddrc_bank_org),
                .dh_gs_lpddr4_diff_bank_rwa2pre (reg_ddrc_lpddr4_diff_bank_rwa2pre),
                .dh_gs_stay_in_selfref          (reg_ddrc_stay_in_selfref),
                .dh_gs_t_ppd                    (reg_ddrc_t_ppd),
                .dh_gs_t_cmdcke                 (reg_ddrc_t_cmdcke),
                .reg_ddrc_dsm_en                (reg_ddrc_dsm_en),
                .reg_ddrc_t_pdn                 (reg_ddrc_t_pdn),
                .reg_ddrc_t_xsr_dsm_x1024       (reg_ddrc_t_xsr_dsm_x1024),
                .reg_ddrc_t_csh                 (reg_ddrc_t_csh),
                .dh_gs_odtloff                  (reg_ddrc_odtloff),
                .dh_bs_t_ccd_mw                 (reg_ddrc_t_ccd_mw),
                .reg_ddrc_rd2mr                 (reg_ddrc_rd2mr),
                .reg_ddrc_wr2mr                 (reg_ddrc_wr2mr),

                .dh_gs_hpr_xact_run_length      (reg_ddrc_hpr_xact_run_length),
                .dh_gs_hpr_max_starve           (reg_ddrc_hpr_max_starve),

                .dh_gs_lpr_xact_run_length      (reg_ddrc_lpr_xact_run_length),
                .dh_gs_lpr_max_starve           (reg_ddrc_lpr_max_starve),
                .dh_gs_w_xact_run_length        (reg_ddrc_w_xact_run_length),
                .dh_gs_w_max_starve             (reg_ddrc_w_max_starve),
                .pi_gs_ctrlupd_ok               (pi_gs_ctrlupd_ok),
                .pi_gs_noxact                   (pi_gs_noxact),
                .pi_gs_rd_vld                   (pi_gs_rd_vld),
                .te_bs_rd_page_hit              (i_te_bs_cpfcpeif.te_bs_rd_page_hit),
                .te_bs_rd_valid                 (i_te_bs_cpfcpeif.te_bs_rd_valid),
                .te_bs_wr_page_hit              (i_te_bs_cpfcpeif.te_bs_wr_page_hit),
                .te_bs_wr_valid                 (i_te_bs_cpfcpeif.te_bs_wr_valid),
                .te_bs_rd_bank_page_hit         (i_te_bs_cpfcpeif.te_bs_rd_bank_page_hit),
                .te_bs_wr_bank_page_hit         (i_te_bs_cpfcpeif.te_bs_wr_bank_page_hit),
                .te_bs_rd_hi                    (i_te_bs_cpfcpeif.te_bs_rd_hi),
                .te_gs_block_wr                 (i_te_gs_cpfcpeif.te_gs_block_wr),
                .te_os_hi_bsm_hint              (i_te_os_cpfcpeif.te_os_hi_bsm_hint),
                .te_os_lo_bsm_hint              (i_te_os_cpfcpeif.te_os_lo_bsm_hint),
                .te_os_wr_bsm_hint              (i_te_os_cpfcpeif.te_os_wr_bsm_hint),
                .te_os_lo_act_bsm_hint          (i_te_os_cpfcpeif.te_os_lo_act_bsm_hint),
                .te_os_wr_act_bsm_hint          (i_te_os_cpfcpeif.te_os_wr_act_bsm_hint),
                .hif_go2critical_lpr            (hif_go2critical_lpr),
                .hif_go2critical_hpr            (hif_go2critical_hpr),
                .hif_go2critical_wr             (hif_go2critical_wr),
                .hif_go2critical_l1_wr          (hif_go2critical_l1_wr ),
                .hif_go2critical_l2_wr          (hif_go2critical_l2_wr ),
                .hif_go2critical_l1_lpr         (hif_go2critical_l1_lpr),
                .hif_go2critical_l2_lpr         (hif_go2critical_l2_lpr),
                .hif_go2critical_l1_hpr         (hif_go2critical_l1_hpr),
                .hif_go2critical_l2_hpr         (hif_go2critical_l2_hpr),
                .ih_gs_rdlow_empty              (i_ih_gs_cpfcpeif.ih_gs_rdlow_empty),
                .ih_gs_rdhigh_empty             (i_ih_gs_cpfcpeif.ih_gs_rdhigh_empty),
//              .ih_gs_wr_empty                 (ih_gs_wr_empty),
                .ih_yy_xact_valid               (i_ih_gs_cpfcpeif.ih_yy_xact_valid),
                .te_gs_rd_flush                 (i_te_gs_cpfcpeif.te_gs_rd_flush),
                .te_gs_wr_flush                 (i_te_gs_cpfcpeif.te_gs_wr_flush),
                .te_gs_any_rd_pending           (i_te_gs_cpfcpeif.te_gs_any_rd_pending),
                .te_gs_any_wr_pending           (i_te_gs_cpfcpeif.te_gs_any_wr_pending),

                .wu_gs_enable_wr                (wu_gs_enable_wr),

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Debug pins. Not currently used in all configs.
                .gs_dh_hpr_q_state              (gs_dh_hpr_q_state),
                .gs_dh_lpr_q_state              (gs_dh_lpr_q_state),
                .gs_dh_w_q_state                (gs_dh_w_q_state),
                .gs_dh_init_curr_state          (gs_dh_init_curr_state),
                .gs_dh_init_next_state          (gs_dh_init_next_state),
//spyglass enable_block W528
                .gs_dh_selfref_cam_not_empty    (ddrc_reg_selfref_cam_not_empty),
                .gs_dh_selfref_state            (ddrc_reg_selfref_state),
                .gs_dh_operating_mode           (ddrc_reg_operating_mode_w),
                .ddrc_reg_selfref_type          (ddrc_reg_selfref_type_w),
                .gs_wr_mode                     (o_gs_cpfcpeif.gs_te_wr_mode),
                .gs_te_wr_possible              (o_gs_cpfcpeif.gs_te_wr_possible),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
              //.gs_te_pri_level                (o_gs_cpfcpeif.gs_te_pri_level),
                .gs_te_pri_level                (gs_te_pri_level),
//spyglass enable_block W528
                .gs_pi_ctrlupd_req              (gs_pi_ctrlupd_req),          // DFI controller update when DQ bus is idle
                .gs_pi_rd_data_pipeline_empty   (gs_pi_rd_data_pipeline_empty),
                .gs_pi_wr_data_pipeline_empty   (gs_pi_wr_data_pipeline_empty),
                .gs_pi_data_pipeline_empty      (gs_pi_data_pipeline_empty),
                .gs_pi_init_cke                 (gs_pi_init_cke),

                .gs_op_is_rd                    (gs_op_is_rd),
                .gs_op_is_wr                    (gs_op_is_wr),
                .gs_op_is_act                   (gs_op_is_act),
                .gs_op_is_pre                   (gs_op_is_pre),
                .gs_op_is_ref                   (gs_op_is_ref),
                .gs_op_is_enter_selfref         (gs_op_is_enter_selfref),
                .gs_op_is_exit_selfref          (gs_op_is_exit_selfref),
                .gs_op_is_enter_powerdown       (gs_op_is_enter_powerdown),
                .gs_op_is_exit_powerdown        (gs_op_is_exit_powerdown),
                .gs_op_is_load_mode             (gs_op_is_load_mode),

                .gs_rdwr_bsm_num                (gs_rdwr_bsm_num),
                .gs_act_bsm_num                 (gs_act_bsm_num),
                .gs_pre_bsm_num                 (gs_pre_bsm_num),

                .gs_pre_rankbank_num            (gs_pre_rankbank_num),
                .gs_rdwr_rankbank_num           (gs_rdwr_rankbank_num),
                .gs_act_rankbank_num            (gs_act_rankbank_num),
                .gs_pi_refpb_bank               (gs_pi_refpb_bank),
                .gs_cas_ws_req                  (gs_cas_ws_req),
                .pi_rdwr_ok                     (pi_rdwr_ok),
                .pi_lp5_act2_cmd                (pi_lp5_act2_cmd),
                .pi_lp5_noxact                  (pi_lp5_noxact),
                .pi_lp5_preref_ok               (pi_lp5_preref_ok),
                .pi_col_b3                      (pi_col_b3),

                .gs_pi_mrs_a                    (gs_pi_mrs_a),
                .gs_pi_init_in_progress         (gs_pi_init_in_progress),
                .gs_pi_odt                      (gs_pi_odt),
                .gs_pi_odt_pending              (gs_pi_odt_pending),
                .reg_ddrc_dfi_tphy_wrlat        (reg_ddrc_dfi_tphy_wrlat),
                .reg_ddrc_dfi_t_rddata_en       (reg_ddrc_dfi_t_rddata_en),
                .reg_ddrc_dfi_tphy_wrcslat      (reg_ddrc_dfi_tphy_wrcslat),
                .reg_ddrc_dfi_tphy_rdcslat      (reg_ddrc_dfi_tphy_rdcslat),
                .reg_ddrc_dfi_data_cs_polarity  (reg_ddrc_dfi_data_cs_polarity),
                .gs_pi_wrdata_cs_n              (gs_pi_wrdata_cs_n),
                .gs_pi_rddata_cs_n              (gs_pi_rddata_cs_n),
                .gs_pi_pads_powerdown           (gs_pi_pads_powerdown_unused),
                .gs_pi_pads_selfref             (gs_pi_pads_selfref_unused),
                .gs_op_is_enter_sr_lpddr        (gs_op_is_enter_sr_lpddr),
                .gs_op_is_exit_sr_lpddr         (gs_op_is_exit_sr_lpddr),
                .gs_op_is_enter_dsm             (gs_op_is_enter_dsm),
                .gs_op_is_exit_dsm              (gs_op_is_exit_dsm),
                .gs_op_is_cas_ws_off            (gs_op_is_cas_ws_off),
                .gs_wck_stop_ok                 (gs_wck_stop_ok),
                .gs_mpc_zq_start                (gs_mpc_zq_start),
                .gs_mpc_zq_latch                (gs_mpc_zq_latch),
                .gs_pi_rd_length               (gs_pi_rd_length),
                .gs_pi_rd_critical_word        (gs_pi_rd_critical_word),
                .gs_pi_rdwr_ram_raddr_lsb_first (gs_pi_rdwr_ram_raddr_lsb_first_w),
                .gs_pi_rdwr_pw_num_beats_m1     (gs_pi_rdwr_pw_num_beats_m1_w),
                .reg_en_dfi_dram_clk_disable    (reg_ddrc_en_dfi_dram_clk_disable),
                .gs_pi_stop_clk_ok              (gs_pi_stop_clk_ok),
                .gs_pi_stop_clk_type            (gs_pi_stop_clk_type),
                .dfilp_ctrl_lp                  (dfilp_ctrl_lp),
                .pi_gs_stop_clk_early           (pi_gs_stop_clk_early),
                .pi_gs_stop_clk_type            (pi_gs_stop_clk_type),
                .pi_gs_dfilp_wait               (pi_gs_dfilp_wait),
                .reg_ddrc_dfi_t_dram_clk_enable (reg_ddrc_dfi_t_dram_clk_enable),
                .reg_ddrc_t_cksre               (reg_ddrc_t_cksre),
                .reg_ddrc_t_cksrx               (reg_ddrc_t_cksrx),
                .reg_ddrc_t_ckcsx               (reg_ddrc_t_ckcsx),
                .reg_ddrc_t_ckesr               (reg_ddrc_t_ckesr),

                .dfi_lp_ctrl_req                (dfi_lp_ctrl_req_int),
                .dfi_lp_ctrl_wakeup             (dfi_lp_ctrl_wakeup_int),
                .dfi_lp_ctrl_ack                (cpedfi_if.dfi_lp_ctrl_ack),
                .dfi_lp_data_req                (dfi_lp_data_req_int),
                .dfi_lp_data_wakeup             (dfi_lp_data_wakeup_int),
                .dfi_lp_data_ack                (cpedfi_if.dfi_lp_data_ack),
                .dfi_reset_n_in                 (dfi_reset_n_in),
                .dfi_reset_n_ref                (dfi_reset_n_ref),
                .init_mr_done_in                (init_mr_done_in),
                .init_mr_done_out               (init_mr_done_out),
                .dfi_ctrlmsg_req_busy           (ddrc_reg_dfi0_ctrlmsg_req_busy),
                .dfi_ctrlmsg_req                (cpedfi_if.dfi_ctrlmsg_req),
                .dfilp_block_dfi_ctrlmsg        (dfilp_block_dfi_ctrlmsg),

                .reg_ddrc_dfi_lp_data_req_en    (reg_ddrc_dfi_lp_data_req_en),
                .reg_ddrc_dfi_lp_en_pd          (reg_ddrc_dfi_lp_en_pd),
                .reg_ddrc_dfi_lp_wakeup_pd      (reg_ddrc_dfi_lp_wakeup_pd),
                .reg_ddrc_dfi_lp_en_sr          (reg_ddrc_dfi_lp_en_sr),
                .reg_ddrc_dfi_lp_wakeup_sr      (reg_ddrc_dfi_lp_wakeup_sr),
                .reg_ddrc_dfi_lp_en_data        (reg_ddrc_dfi_lp_en_data),
                .reg_ddrc_dfi_lp_wakeup_data    (reg_ddrc_dfi_lp_wakeup_data),
                .reg_ddrc_dfi_lp_en_dsm         (reg_ddrc_dfi_lp_en_dsm),
                .reg_ddrc_dfi_lp_wakeup_dsm     (reg_ddrc_dfi_lp_wakeup_dsm),
                .reg_ddrc_dfi_tlp_resp          (reg_ddrc_dfi_tlp_resp),
                .gs_pi_mrr                      (gs_pi_mrr),
                .gs_pi_mrr_ext                  (gs_pi_mrr_ext),
                .dh_gs_mr4_req                  (mr4_req),

                .phy_dfi_phyupd_req             (cpedfi_if.dfi_phyupd_req),
                .phy_dfi_phyupd_req_r           (phy_dfi_phyupd_req),
                .ddrc_dfi_phyupd_ack            (dfi_phyupd_ack_int),


                .phy_dfi_phymstr_req            (cpedfi_if.dfi_phymstr_req),
                .phy_dfi_phymstr_cs_state       (cpedfi_if.dfi_phymstr_cs_state),
                .phy_dfi_phymstr_state_sel      (cpedfi_if.dfi_phymstr_state_sel),
                .phy_dfi_phymstr_type           (cpedfi_if.dfi_phymstr_type),
                .ddrc_dfi_phymstr_ack           (dfi_phymstr_ack_int),

                .reg_ddrc_dfi_phyupd_en         (reg_ddrc_dfi_phyupd_en),

                .reg_ddrc_dfi_phymstr_en        (reg_ddrc_dfi_phymstr_en),
                .reg_ddrc_dfi_phymstr_blk_ref_x32(reg_ddrc_dfi_phymstr_blk_ref_x32),
                .reg_ddrc_dis_cam_drain_selfref (reg_ddrc_dis_cam_drain_selfref),
                .reg_ddrc_lpddr4_sr_allowed     (reg_ddrc_lpddr4_sr_allowed),
                .reg_ddrc_lpddr4_opt_act_timing (reg_ddrc_lpddr4_opt_act_timing),
                .reg_ddrc_lpddr5_opt_act_timing (reg_ddrc_lpddr5_opt_act_timing),
                .reg_ddrc_dfi_t_ctrl_delay      (reg_ddrc_dfi_t_ctrl_delay),
                .reg_ddrc_dfi_t_wrdata_delay    (reg_ddrc_dfi_t_wrdata_delay),

                .gs_pi_phyupd_pause_req         (gs_pi_phyupd_pause_req),
                .pi_gs_phyupd_pause_ok          (pi_gs_phyupd_pause_ok),
                .reg_ddrc_skip_dram_init        (reg_ddrc_skip_dram_init),
                .gs_pi_dfi_lp_changing          (gs_pi_dfi_lp_changing)

              ,.ts_act_page                     (ts_act_page)
              ,.ts_act2_invalid_tmg             (ts_act2_invalid_tmg)


             ,  .te_gs_rank_wr_pending          (i_te_gs_cpfcpeif.te_gs_rank_wr_pending)
             ,  .te_gs_rank_rd_pending          (i_te_gs_cpfcpeif.te_gs_rank_rd_pending)
             ,  .te_gs_bank_wr_pending          (i_te_gs_cpfcpeif.te_gs_bank_wr_pending)
             ,  .te_gs_bank_rd_pending          (i_te_gs_cpfcpeif.te_gs_bank_rd_pending)

             ,  .dfi_init_start                 (cpedfi_if.dfi_init_start)
               ,.reg_ddrc_opt_wrcam_fill_level  (reg_ddrc_opt_wrcam_fill_level)
               ,.reg_ddrc_delay_switch_write    (reg_ddrc_delay_switch_write)
               ,.reg_ddrc_wr_pghit_num_thresh   (reg_ddrc_wr_pghit_num_thresh)
               ,.reg_ddrc_rd_pghit_num_thresh   (reg_ddrc_rd_pghit_num_thresh)
               ,.reg_ddrc_wrcam_highthresh      (reg_ddrc_wrcam_highthresh)
               ,.reg_ddrc_wrcam_lowthresh       (reg_ddrc_wrcam_lowthresh)
               ,.reg_ddrc_wr_page_exp_cycles    (reg_ddrc_wr_page_exp_cycles)
               ,.reg_ddrc_rd_page_exp_cycles    (reg_ddrc_rd_page_exp_cycles)
               ,.reg_ddrc_wr_act_idle_gap       (reg_ddrc_wr_act_idle_gap)
               ,.reg_ddrc_rd_act_idle_gap       (reg_ddrc_rd_act_idle_gap)

             //,.ts_te_sel_act_wr               (o_bs_cpfcpeif.ts_te_sel_act_wr) //tell TE the activate command is for write or read.
               ,.ts_te_sel_act_wr               (ts_te_sel_act_wr) //tell TE the activate command is for write or read.
               ,.te_rws_wr_col_bank             (i_te_bs_cpfcpeif.te_rws_wr_col_bank) // entry of colliding bank (1bit for 1bank)
               ,.te_rws_rd_col_bank             (i_te_bs_cpfcpeif.te_rws_rd_col_bank) // entry of colliding bank (1bit for 1bank)
               ,.te_num_wr_pghit_entries        (i_te_bs_cpfcpeif.te_num_wr_pghit_entries)
               ,.te_num_rd_pghit_entries        (i_te_bs_cpfcpeif.te_num_rd_pghit_entries)
               ,.te_wr_entry_avail              (i_te_bs_cpfcpeif.te_wr_entry_avail)           // Number of non-valid entries (WRCAM only, not include WRECC CAM)
               ,.reg_ddrc_dis_opt_ntt_by_act    (reg_ddrc_dis_opt_ntt_by_act)
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
               ,.te_ts_wr_entry_valid           (te_ts_wr_entry_valid)
               ,.te_ts_rd_entry_valid           (te_ts_rd_entry_valid)
               ,.te_ts_wr_page_hit_entries      (te_ts_wr_page_hit_entries)
               ,.te_ts_rd_page_hit_entries      (te_ts_rd_page_hit_entries)
`endif //SNPS_ASSERT_ON
`endif // SYNTHESIS
               ,.reg_ddrc_wck_on                (reg_ddrc_wck_on)
               ,.reg_ddrc_max_rd_sync           (reg_ddrc_max_rd_sync)
               ,.reg_ddrc_max_wr_sync           (reg_ddrc_max_wr_sync)
               ,.reg_ddrc_dfi_twck_delay        (reg_ddrc_dfi_twck_delay)
               ,.reg_ddrc_dfi_twck_en_rd        (reg_ddrc_dfi_twck_en_rd)
               ,.reg_ddrc_dfi_twck_en_wr        (reg_ddrc_dfi_twck_en_wr)
               ,.reg_ddrc_dfi_twck_dis          (reg_ddrc_dfi_twck_dis)
               ,.reg_ddrc_dfi_twck_fast_toggle  (reg_ddrc_dfi_twck_fast_toggle)
               ,.reg_ddrc_dfi_twck_toggle       (reg_ddrc_dfi_twck_toggle)
               ,.reg_ddrc_dfi_twck_toggle_cs    (reg_ddrc_dfi_twck_toggle_cs)
               ,.reg_ddrc_dfi_twck_toggle_post  (reg_ddrc_dfi_twck_toggle_post)
               ,.gs_dfi_wck_cs                  (gs_dfi_wck_cs)
               ,.gs_dfi_wck_en                  (gs_dfi_wck_en)
               ,.gs_dfi_wck_toggle              (gs_dfi_wck_toggle)
              ,.reg_ddrc_dqsosc_enable       (reg_ddrc_dqsosc_enable)
              ,.reg_ddrc_t_osco              (reg_ddrc_t_osco)
              ,.reg_ddrc_dqsosc_runtime      (reg_ddrc_dqsosc_runtime)
              ,.reg_ddrc_wck2dqo_runtime     (reg_ddrc_wck2dqo_runtime)
              ,.reg_ddrc_dqsosc_interval     (reg_ddrc_dqsosc_interval)
              ,.reg_ddrc_dqsosc_interval_unit(reg_ddrc_dqsosc_interval_unit)
              ,.reg_ddrc_dis_dqsosc_srx      (reg_ddrc_dis_dqsosc_srx)
              ,.dqsosc_state                 (dqsosc_state)
              ,.dqsosc_per_rank_stat         (dqsosc_per_rank_stat)
              ,.gs_mpc_dqsosc_start          (gs_mpc_dqsosc_start)
              ,.gs_pi_mrr_snoop_en           (gs_pi_mrr_snoop_en)
               ,.os_te_autopre                  (os_te_autopre)
               );


pi
      #(

                .CMD_LEN_BITS                   (CMD_LEN_BITS),
                .NUM_LANES                      (NUM_LANES),
                .AM_ROW_WIDTH                   (AM_ROW_WIDTH),
                .PARTIAL_WR_BITS                (PARTIAL_WR_BITS),
                .PW_WORD_CNT_WD_MAX             (PW_WORD_CNT_WD_MAX),
                .RMW_TYPE_BITS                  (RMW_TYPE_BITS),
                .RD_TAG_BITS                    (CORE_TAG_WIDTH)

      )
        pi (
                .core_ddrc_rstn                 (core_ddrc_rstn),
                .co_pi_clk                      (core_ddrc_core_clk),
                .gs_op_is_enter_sr_lpddr        (gs_op_is_enter_sr_lpddr),
                .gs_op_is_exit_sr_lpddr         (gs_op_is_exit_sr_lpddr),
                .gs_op_is_enter_dsm             (gs_op_is_enter_dsm),
                .gs_op_is_exit_dsm              (gs_op_is_exit_dsm),
                .gs_op_is_cas_ws_off            (gs_op_is_cas_ws_off),
                .gs_wck_stop_ok                 (gs_wck_stop_ok),
                .gs_pi_stop_clk_ok              (gs_pi_stop_clk_ok),
                .gs_pi_stop_clk_type            (gs_pi_stop_clk_type),
                .dh_pi_en_dfi_dram_clk_disable  (reg_ddrc_en_dfi_dram_clk_disable),
                .reg_ddrc_dfi_t_ctrl_delay      (reg_ddrc_dfi_t_ctrl_delay),
                .reg_ddrc_dfi_t_dram_clk_disable(reg_ddrc_dfi_t_dram_clk_disable),
                .reg_ddrc_t_cksre               (reg_ddrc_t_cksre),
                .reg_ddrc_t_mr                  (reg_ddrc_t_mr),
                .dh_pi_frequency_ratio          (reg_ddrc_frequency_ratio),
                .dh_pi_burst_rdwr               (reg_ddrc_burst_rdwr),
                .reg_ddrc_read_latency          (reg_ddrc_read_latency),
                .reg_ddrc_write_latency         (rl_plus_cmd_len),
                .ts_act_page                    (ts_act_page),
                .ts_act2_invalid_tmg            (ts_act2_invalid_tmg),
                .te_pi_rd_blk                   (i_te_pi_cpfcpeif.te_pi_rd_addr_blk),
                .te_pi_rd_addr_err              (i_te_pi_cpfcpeif.te_pi_rd_addr_err),
                .te_pi_rd_tag                   (i_te_pi_cpfcpeif.te_pi_rd_tag),
                .te_pi_rd_link_addr             (i_te_pi_cpfcpeif.te_pi_rd_link_addr),
                .te_pi_rd_rmw_type              (i_te_pi_cpfcpeif.te_pi_rd_rmw_type),
                .te_pi_rd_length                (gs_pi_rd_length),
                .te_pi_rd_word                  (gs_pi_rd_critical_word),
                .te_pi_wr_blk                   (i_te_pi_cpfcpeif.te_pi_wr_addr_blk),
                .te_pi_wr_word                  (i_te_pi_cpfcpeif.te_pi_wr_word),
                .ts_pi_mwr                      (ts_pi_mwr),
                .gs_mpc_zq_start                (gs_mpc_zq_start),
                .gs_mpc_zq_latch                (gs_mpc_zq_latch),
                .te_pi_rd_valid                 (i_te_pi_cpfcpeif.te_gs_any_rd_pending),
                .te_pi_wr_valid                 (i_te_pi_cpfcpeif.te_gs_any_wr_pending),
                .ih_pi_xact_valid               (i_ih_pi_cpfcpeif.ih_yy_xact_valid),
                .gs_pi_init_cke                 (gs_pi_init_cke),
                .gs_pi_mrs_a                    (gs_pi_mrs_a),


                .gs_op_is_rd                    (gs_op_is_rd),
                .gs_op_is_wr                    (gs_op_is_wr),
                .gs_op_is_act                   (gs_op_is_act),
                .gs_op_is_pre                   (gs_op_is_pre),
                .gs_op_is_ref                   (gs_op_is_ref),
                .gs_op_is_enter_selfref         (gs_op_is_enter_selfref),
                .gs_op_is_exit_selfref          (gs_op_is_exit_selfref),
                .gs_op_is_enter_powerdown       (gs_op_is_enter_powerdown),
                .gs_op_is_exit_powerdown        (gs_op_is_exit_powerdown),
                .gs_op_is_load_mode             (gs_op_is_load_mode),


                .gs_pre_rankbank_num            (gs_pre_rankbank_num),
                .gs_rdwr_rankbank_num           (gs_rdwr_rankbank_num),
                .gs_act_rankbank_num            (gs_act_rankbank_num),
                .gs_pi_refpb_bank               (gs_pi_refpb_bank),
                .gs_cas_ws_req                  (gs_cas_ws_req),
                .pi_rdwr_ok                     (pi_rdwr_ok),
                .pi_lp5_act2_cmd                (pi_lp5_act2_cmd),
                .pi_lp5_noxact                  (pi_lp5_noxact),
                .pi_lp5_preref_ok               (pi_lp5_preref_ok),
                .pi_col_b3                      (pi_col_b3),

                .gs_pi_init_in_progress         (gs_pi_init_in_progress),

                .gs_pi_dram_rst_n               (gs_pi_dram_rst_n),
                .gs_pi_odt                      (gs_pi_odt),
                .gs_pi_odt_pending              (gs_pi_odt_pending),
                .gs_pi_wrdata_cs_n              (gs_pi_wrdata_cs_n),
                .gs_pi_rddata_cs_n              (gs_pi_rddata_cs_n),
                .gs_pi_ctrlupd_req              (gs_pi_ctrlupd_req),
                .gs_pi_phyupd_pause_req         (gs_pi_phyupd_pause_req),
                .gs_pi_dfi_lp_changing          (gs_pi_dfi_lp_changing),
                .gs_pi_data_pipeline_empty      (gs_pi_data_pipeline_empty),
                .gs_pi_mrr                      (gs_pi_mrr),
                .gs_pi_mrr_ext                  (gs_pi_mrr_ext),

                .pi_gs_ctrlupd_ok               (pi_gs_ctrlupd_ok),
                .pi_gs_phyupd_pause_ok          (pi_gs_phyupd_pause_ok),
                .pi_gs_noxact                   (pi_gs_noxact),
                .pi_gs_rd_vld                   (pi_gs_rd_vld),
                .pi_rt_rd_vld                   (pi_rt_rd_vld),
                .pi_rt_rd_partial               (pi_rt_rd_partial),
                // Note: if no RMW, the following 4 signals
                //       are unused
                .pi_rt_wr_ram_addr              (pi_rt_wr_ram_addr),
                .pi_rt_rmw_type                 (pi_rt_rmwtype),
                .pi_rt_rd_tag                   ({
                                                 pi_rt_rd_mrr_snoop,
                                                 pi_rt_rd_mrr_ext, pi_rt_rd_mrr,
                                                 pi_rt_rd_tag}),
                .pi_rt_rd_addr_err              (pi_rt_rd_addr_err),
                .pi_rt_rankbank_num             (pi_rt_rankbank_num),
                .pi_rt_page_num                 (pi_rt_page_num),
                .pi_rt_block_num                (pi_rt_block_num),
                .pi_rt_critical_word            (pi_rt_critical_word),
                .mr_t_rddata_en                 (mr_t_rddata_en),
                .mr_t_wrlat                     (mr_t_wrlat),
                .pi_ph_dfi_rddata_en            (pi_ph_dfi_rddata_en),
                .pi_ph_dfi_wrdata_en            (pi_ph_dfi_wrdata_en),
                .ddrc_dfi_ctrlupd_req           (ddrc_dfi_ctrlupd_req),
                .pi_ph_cke                      (ddrc_phy_cke),
                .pi_ph_ras_n                    (ddrc_phy_rasn),
                .pi_ph_cas_n                    (ddrc_phy_casn),
                .pi_ph_we_n                     (ddrc_phy_wen),
                .pi_ph_bank                     (ddrc_phy_ba),
                .pi_ph_cs                       (ddrc_phy_cs),
                .pi_ph_addr                     (ddrc_phy_addr),
                .dh_pi_per_bank_refresh         (per_bank_refresh_int),
                .dh_pi_lpddr4                   (reg_ddrc_lpddr4),
                .dh_pi_addrmap_row_b17          (reg_ddrc_addrmap_row_b17),
                .reg_ddrc_lpddr5                (reg_ddrc_lpddr5),
                .reg_ddrc_bank_org              (reg_ddrc_bank_org),
                .reg_ddrc_t_csh                 (reg_ddrc_t_csh),
                .reg_ddrc_wck_on                (reg_ddrc_wck_on),

                .pi_ph_stop_clk                 (ddrc_phy_stop_clk),
                .dfilp_ctrl_lp                  (dfilp_ctrl_lp),
                .pi_gs_stop_clk_early           (pi_gs_stop_clk_early),
                .pi_gs_stop_clk_type            (pi_gs_stop_clk_type)
                ,.pi_gs_dfilp_wait              (pi_gs_dfilp_wait)
                ,.pi_ph_dram_rst_n              (ddrc_phy_dram_rst_n)
                ,.pi_ph_odt                     (ddrc_phy_odt)
                ,.pi_ph_wrdata_cs_n             (ddrc_phy_wrdata_cs_n)
                ,.pi_ph_rddata_cs_n             (ddrc_phy_rddata_cs_n)
                ,.clock_gating_en_int           (clock_gating_en_int_unused)
                ,.gs_mpc_dqsosc_start           (gs_mpc_dqsosc_start)
                ,.gs_pi_mrr_snoop_en            (gs_pi_mrr_snoop_en)
                ,.pi_ph_snoop_en                (pi_ph_snoop_en)
`ifdef SNPS_ASSERT_ON
                ,.gs_pi_wr_mode                 (o_gs_cpfcpeif.gs_te_wr_mode)
`endif // SNPS_ASSERT_ON
                ,.os_te_autopre                 (os_te_autopre)
  );

   // SMV
   //------------------------------------------------------------------------------
   // DERATE block
   //------------------------------------------------------------------------------

derate
 #(
                 .NUM_RANKS                  (NUM_RANKS)
) derate( /*AUTOINST*/
                 // Outputs
                 .mr4_req                      (mr4_req),
                 .core_derate_temp_limit_intr  (core_derate_temp_limit_intr),
                 .derate_ddrc_t_rcd            (derate_ddrc_t_rcd),
                 .derate_ddrc_t_ras_min        (derate_ddrc_t_ras_min),
                 .derate_ddrc_t_rc             (derate_ddrc_t_rc),
                 .derate_ddrc_t_rp             (derate_ddrc_t_rp),
                 .derate_ddrc_t_rrd            (derate_ddrc_t_rrd),
                 .derate_ddrc_t_rrd_s          (derate_ddrc_t_rrd_s),
                 .derate_ddrc_t_refie          (derate_ddrc_t_refie),
                 .derate_ddrc_t_refi           (derate_ddrc_t_refi),
                 .derate_refresh_update_level  (derate_refresh_update_level),
                 .max_postponed_ref_cmd        (max_postponed_ref_cmd),
                 .max_ref_cmd_within_2trefi    (max_ref_cmd_within_2trefi),
                 .ddrc_reg_dbg_mr4_byte0_rank0 (ddrc_reg_dbg_mr4_byte0_rank0),
                 .ddrc_reg_dbg_mr4_byte1_rank0 (ddrc_reg_dbg_mr4_byte1_rank0),
                 .ddrc_reg_dbg_mr4_byte2_rank0 (ddrc_reg_dbg_mr4_byte2_rank0),
                 .ddrc_reg_dbg_mr4_byte3_rank0 (ddrc_reg_dbg_mr4_byte3_rank0),
                 // Inputs
                 .clk                          (core_ddrc_core_clk),    // Templated
                 .core_ddrc_rstn               (core_ddrc_rstn),        // Templated
                 .reg_ddrc_mr4_read_interval   (reg_ddrc_mr4_read_interval),
                 .ddrc_reg_operating_mode      (ddrc_reg_operating_mode_w),
                 .derate_sync_ack_c2p          (derate_sync_ack_c2p),
                 .reg_ddrc_lpddr4_refresh_mode      (reg_ddrc_lpddr4_refresh_mode),
                 .reg_ddrc_active_derate_byte_rank0 (reg_ddrc_active_derate_byte_rank0),
                 .reg_ddrc_dis_trefi_x6x8      (reg_ddrc_dis_trefi_x6x8),
                 .reg_ddrc_dis_trefi_x0125     (reg_ddrc_dis_trefi_x0125),
                 .reg_ddrc_t_rcd               (reg_ddrc_t_rcd_int),
                 .reg_ddrc_t_ras_min           (reg_ddrc_t_ras_min),
                 .reg_ddrc_t_rc                (reg_ddrc_t_rc),
                 .reg_ddrc_t_rp                (reg_ddrc_t_rp),
                 .reg_ddrc_t_rrd               (reg_ddrc_t_rrd),
                 .reg_ddrc_t_rrd_s             (reg_ddrc_t_rrd_s),
                 .reg_ddrc_t_refi_x32          (reg_ddrc_t_refi_x1_x32),
                 .reg_ddrc_derate_enable       (reg_ddrc_derate_enable),
                 .reg_ddrc_derated_t_rcd       (reg_ddrc_derated_t_rcd),
                 .reg_ddrc_derated_t_ras_min   (reg_ddrc_derated_t_ras_min),
                 .reg_ddrc_derated_t_rp        (reg_ddrc_derated_t_rp),
                 .reg_ddrc_derated_t_rrd       (reg_ddrc_derated_t_rrd),
                 .reg_ddrc_derated_t_rc        (reg_ddrc_derated_t_rc),
                 .reg_ddrc_derate_mr4_tuf_dis  (reg_ddrc_derate_mr4_tuf_dis),
                 .reg_ddrc_derate_mr4_pause_fc (reg_ddrc_derate_mr4_pause_fc),
                 .reg_ddrc_lpddr4              (reg_ddrc_lpddr4),
                 .reg_ddrc_lpddr5              (reg_ddrc_lpddr5),
                 .reg_ddrc_t_refi_x1_sel       (reg_ddrc_t_refi_x1_sel),
                 .reg_ddrc_per_bank_refresh    (reg_ddrc_per_bank_refresh),
                 .reg_ddrc_auto_refab_en       (reg_ddrc_auto_refab_en),
                 .derate_force_refab           (derate_force_refab),
                 .rt_rd_rd_mrr_ext             (rt_rd_rd_mrr_ext),
                 .rd_mrr_data                  (hif_mrr_data),
                 .rd_mrr_data_valid            (rd_mr4_data_valid & reg_ddrc_derate_enable));   // Templated

   // SMV



dfi_ctrl
 #(
             .CHANNEL_NUM                   (CHANNEL_NUM),
             .SHARED_AC                     (SHARED_AC),
             .UMCTL2_PHY_SPECIAL_IDLE       (UMCTL2_PHY_SPECIAL_IDLE),
             .MEMC_ECC_SUPPORT              (MEMC_ECC_SUPPORT),
             .BG_BITS                       (BG_BITS),
             .BANK_BITS                     (BANK_BITS),
             .NUM_RANKS                     (NUM_RANKS),
             .PHY_DATA_WIDTH                (PHY_DATA_WIDTH),
             .NUM_DRAM_CLKS                 (NUM_PHY_DRAM_CLKS),
             .NUM_LANES                     (NUM_LANES)

           )
  dfi_ctrl (
             // Inputs
             .core_ddrc_core_clk            (core_ddrc_core_clk),
             .core_ddrc_rstn                (core_ddrc_rstn),
             .dfi_cmd_delay                 (dfi_cmd_delay),
             .mr_t_wrlat                    (mr_t_wrlat),
             .mr_t_wrdata                   (mr_t_wrdata),
             .reg_ddrc_frequency_ratio      (reg_ddrc_frequency_ratio),
             .dfi_phyupd_req                (cpedfi_if.dfi_phyupd_req),
             .dfi_init_complete             (cpedfi_if.dfi_init_complete),
             .ddrc_phy_addr                 (ddrc_phy_addr),
             .ddrc_phy_ba                   (ddrc_phy_ba),
             .ddrc_phy_casn                 (ddrc_phy_casn),
             .ddrc_phy_csn                  (ddrc_phy_csn),
             .ddrc_phy_cke                  (ddrc_phy_cke),
             .ddrc_phy_odt                  (ddrc_phy_odt),
             .ddrc_phy_rasn                 (ddrc_phy_rasn),
             .ddrc_phy_wen                  (ddrc_phy_wen),
             .ddrc_phy_dram_rst_n           (ddrc_phy_dram_rst_n),
             .ddrc_phy_wrdata_cs_n          (ddrc_phy_wrdata_cs_n),
             .ddrc_phy_rddata_cs_n          (ddrc_phy_rddata_cs_n),
             .ddrc_phy_stop_clk             (ddrc_phy_stop_clk),
             .ts_dfi_ctrlupd_req            (ddrc_dfi_ctrlupd_req),
             .reg_ddrc_dfi_init_start       (reg_ddrc_dfi_init_start),

             .dfi_phyupd_ack_int            (dfi_phyupd_ack_int),
             .dfi_phymstr_ack_int           (dfi_phymstr_ack_int),
             .dfi_lp_ctrl_wakeup_int        (dfi_lp_ctrl_wakeup_int),
             .dfi_lp_ctrl_req_int           (dfi_lp_ctrl_req_int),
             .dfi_lp_data_wakeup_int        (dfi_lp_data_wakeup_int),
             .dfi_lp_data_req_int           (dfi_lp_data_req_int),

             .reg_ddrc_lpddr4               (reg_ddrc_lpddr4),
             .reg_ddrc_lpddr5               (reg_ddrc_lpddr5),
             .gs_dfi_wck_cs                 (gs_dfi_wck_cs),
             .gs_dfi_wck_en                 (gs_dfi_wck_en),
             .gs_dfi_wck_toggle             (gs_dfi_wck_toggle),
               //Outputs
             .phy_dfi_phyupd_req            (phy_dfi_phyupd_req),
             .phy_dfi_init_complete         (phy_dfi_init_complete),
             .dfi_address                   (cpedfi_if.dfi_address),
             .dfi_bank                      (cpedfi_if.dfi_bank),
             .dfi_freq_ratio                (cpedfi_if.dfi_freq_ratio),
             .dfi_ras_n                     (cpedfi_if.dfi_ras_n),
             .dfi_cas_n                     (cpedfi_if.dfi_cas_n),
             .dfi_we_n                      (cpedfi_if.dfi_we_n),
             .dfi_cke                       (cpedfi_if.dfi_cke),
             .dfi_cs                        (cpedfi_if.dfi_cs),
             .dfi_odt                       (cpedfi_if.dfi_odt),
             .dfi_reset_n                   (cpedfi_if.dfi_reset_n),
             .dfi_wrdata_cs                 (cpedfi_if.dfi_wrdata_cs),
             .dfi_rddata_cs                 (cpedfi_if.dfi_rddata_cs),
             .dfi_ctrlupd_req               (cpedfi_if.dfi_ctrlupd_req),
             .dfi_phyupd_ack                (cpedfi_if.dfi_phyupd_ack),
             .dfi_phymstr_ack               (cpedfi_if.dfi_phymstr_ack),
             .dfi_lp_ctrl_wakeup            (cpedfi_if.dfi_lp_ctrl_wakeup),
             .dfi_lp_ctrl_req               (cpedfi_if.dfi_lp_ctrl_req),
             .dfi_lp_data_wakeup            (cpedfi_if.dfi_lp_data_wakeup),
             .dfi_lp_data_req               (cpedfi_if.dfi_lp_data_req),
             .dfi_dram_clk_disable          (cpedfi_if.dfi_dram_clk_disable),
             .dfi_wck_cs                    (dfi_wck_cs),
             .dfi_wck_en                    (dfi_wck_en),
             .dfi_wck_toggle                (dfi_wck_toggle),



             .dfi_init_start                (cpedfi_if.dfi_init_start),
          .reg_ddrc_dfi_t_ctrlmsg_resp             (reg_ddrc_dfi_t_ctrlmsg_resp),
          .reg_ddrc_dfi0_ctrlmsg_req               (reg_ddrc_dfi0_ctrlmsg_req),
          .reg_ddrc_dfi0_ctrlmsg_tout_clr          (reg_ddrc_dfi0_ctrlmsg_tout_clr),
          .reg_ddrc_dfi0_ctrlmsg_data              (reg_ddrc_dfi0_ctrlmsg_data),
          .reg_ddrc_dfi0_ctrlmsg_cmd               (reg_ddrc_dfi0_ctrlmsg_cmd),
          .ddrc_reg_dfi0_ctrlmsg_req_busy          (ddrc_reg_dfi0_ctrlmsg_req_busy),
          .ddrc_reg_dfi0_ctrlmsg_resp_tout         (ddrc_reg_dfi0_ctrlmsg_resp_tout),
          .dfi0_ctrlmsg_ack                        (cpedfi_if.dfi_ctrlmsg_ack),
          .dfi0_ctrlmsg_req                        (cpedfi_if.dfi_ctrlmsg_req),
          .dfi0_ctrlmsg                            (cpedfi_if.dfi_ctrlmsg),
          .dfi0_ctrlmsg_data                       (cpedfi_if.dfi_ctrlmsg_data),
          .gs_pi_ctrlupd_req                       (gs_pi_ctrlupd_req),
          .dfilp_block_dfi_ctrlmsg                 (dfilp_block_dfi_ctrlmsg),
          .dfi_parity_in                           (dfi_parity_in_w)
             );





endmodule : dwc_ddrctl_ddrc_cpe

