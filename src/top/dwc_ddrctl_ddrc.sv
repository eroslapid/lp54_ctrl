//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/top/dwc_ddrctl_ddrc.sv#6 $
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

// This is the top-level for the DDR Controller.  This instantiates and connects
// all units of the DDR Control.
//
// ----------------------------------------------------------------------------
//spyglass disable_block W287b
//SMD: Instance output port .* is not connected.
//SJ: all optional outputs of ddrc_ctrl.v always exist and they pass through ddrc.v
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
`include "top/dwc_ddrctl_ddrc_cpfdp_if.svh"
`include "top/dwc_ddrctl_ddrc_cpedp_if.svh"

module dwc_ddrctl_ddrc
import DWC_ddrctl_reg_pkg::*;
(
                core_ddrc_core_clk,
                core_ddrc_rstn,

                bsm_clk,
                bsm_clk_en,
                bsm_clk_on,



                hif_cmd_valid,
                hif_cmd_type,
                hif_cmd_addr,
                hif_cmd_pri,
                hif_cmd_token,
                hif_cmd_length,
                hif_cmd_wdata_ptr,
                hif_cmd_autopre,



                hif_wdata_valid,
                hif_wdata,
                hif_wdata_mask,
                hif_wdata_end,
                hif_wdata_parity,


                hif_wdata_stall,

                hif_go2critical_lpr,
                hif_go2critical_hpr,
                hif_go2critical_wr,
                hif_go2critical_l1_wr,
                hif_go2critical_l2_wr,
                hif_go2critical_l1_lpr,
                hif_go2critical_l2_lpr,
                hif_go2critical_l1_hpr,
                hif_go2critical_l2_hpr,

                hif_cmd_stall,
                hif_wdata_ptr,
                hif_wdata_ptr_valid,
                hif_wdata_ptr_addr_err,
                hif_lpr_credit,
                hif_wr_credit,
                hif_hpr_credit,
                hif_wrecc_credit,
                reg_ddrc_mr_wr,
                reg_ddrc_mr_type,
                reg_ddrc_mr_addr,
                reg_ddrc_mr_data,
                ddrc_reg_mr_wr_busy,
                reg_ddrc_burst_mode,

                hif_rdata_valid,
                hif_rdata_end,
                hif_rdata_token,
                hif_rdata,
                hif_rdata_parity,

                hif_rdata_addr_err,
                hif_cmd_q_not_empty,


                cactive_in_ddrc,
                cactive_in_ddrc_async,
                csysreq_ddrc,
                csysack_ddrc,
                cactive_ddrc,

                stat_ddrc_reg_selfref_type,




                cp_dfiif, // CP DFI signals

                dfi_wrdata,
                dfi_wrdata_en,
                dfi_wrdata_mask,
                dfi_rddata,
                dfi_rddata_en,
                dfi_rddata_valid,
                dfi_rddata_dbi,

                reg_ddrc_dfi_tphy_wrcslat,
                reg_ddrc_dfi_tphy_rdcslat,
                reg_ddrc_dfi_data_cs_polarity,

                dfi_wck_cs,
                dfi_wck_en,
                dfi_wck_toggle,
                reg_ddrc_dfi_init_start,
                reg_ddrc_dfi_frequency,
                reg_ddrc_dfi_freq_fsp,
                dfi_reset_n_in,
                dfi_reset_n_ref,
                init_mr_done_in,
                init_mr_done_out,

                reg_ddrc_dfi_init_complete_en,
                reg_ddrc_frequency_ratio,
                reg_ddrc_phy_dbi_mode,
                reg_ddrc_wr_dbi_en,
                reg_ddrc_rd_dbi_en,
                reg_ddrc_dm_en,
                wdataram_din,
                wdataram_dout,
                wdataram_mask,
                wdataram_wr,
                wdataram_raddr,
                wdataram_re,
                wdataram_waddr,
                wdataram_din_par,
                wdataram_dout_par,
                reg_ddrc_en_dfi_dram_clk_disable,
                reg_ddrc_powerdown_en,
                reg_ddrc_selfref_sw,
                reg_ddrc_hw_lp_en,
                reg_ddrc_hw_lp_exit_idle_en,
                reg_ddrc_selfref_to_x32,
                reg_ddrc_hw_lp_idle_x32,
                reg_ddrc_data_bus_width,
                reg_ddrc_refresh_burst,

                reg_ddrc_opt_wrcam_fill_level,
                reg_ddrc_delay_switch_write,
                reg_ddrc_wr_pghit_num_thresh,
                reg_ddrc_rd_pghit_num_thresh,
                reg_ddrc_wrcam_highthresh,
                reg_ddrc_wrcam_lowthresh,
                reg_ddrc_wr_page_exp_cycles,
                reg_ddrc_rd_page_exp_cycles,
                reg_ddrc_wr_act_idle_gap,
                reg_ddrc_rd_act_idle_gap,
                reg_ddrc_dis_opt_ntt_by_act,
                reg_ddrc_dis_opt_ntt_by_pre,
                reg_ddrc_autopre_rmw,
                reg_ddrc_rdwr_idle_gap,
                reg_ddrc_pageclose,
                reg_ddrc_pageclose_timer,
                reg_ddrc_page_hit_limit_rd,
                reg_ddrc_page_hit_limit_wr,
                reg_ddrc_opt_hit_gt_hpr,
                reg_ddrc_dis_speculative_act,
                reg_ddrc_prefer_read,
                reg_ddrc_lpr_num_entries,
                reg_ddrc_lpr_num_entries_changed,
                reg_ddrc_hpr_max_starve,
                reg_ddrc_hpr_xact_run_length,
                reg_ddrc_lpr_max_starve,
                reg_ddrc_lpr_xact_run_length,
                reg_ddrc_w_max_starve,
                reg_ddrc_w_xact_run_length,
                reg_ddrc_refresh_update_level,
                reg_ddrc_t_rc,
                reg_ddrc_t_rfc_min,
                reg_ddrc_t_rfc_min_ab,
                reg_ddrc_t_pbr2pbr,
                reg_ddrc_t_pbr2act,
                reg_ddrc_t_xsr,
                reg_ddrc_t_refi_x1_sel,
                reg_ddrc_t_refi_x1_x32,
                reg_ddrc_wr2pre,
                reg_ddrc_wra2pre,
                reg_ddrc_powerdown_to_x32,
                reg_ddrc_t_faw,
                reg_ddrc_t_ras_max,
                reg_ddrc_t_ras_min,
                reg_ddrc_dfi_t_rddata_en,
                reg_ddrc_dfi_tphy_wrdata,
                reg_ddrc_dfi_t_ctrlup_min,
                reg_ddrc_dfi_t_ctrlup_max,
                reg_ddrc_read_latency,
                reg_ddrc_write_latency,
                reg_ddrc_dfi_tphy_wrlat,
                reg_ddrc_rd2wr,
                reg_ddrc_wr2rd,
                reg_ddrc_wr2rd_s,
                reg_ddrc_t_xp,
                reg_ddrc_rd2pre,
                reg_ddrc_rda2pre,
                reg_ddrc_t_rcd,
                reg_ddrc_t_cke,
                reg_ddrc_t_ccd,
                reg_ddrc_t_ccd_s,
                reg_ddrc_odtloff,
                reg_ddrc_t_ccd_mw,
                reg_ddrc_dis_trefi_x6x8,
                reg_ddrc_dis_trefi_x0125,
                reg_ddrc_t_ppd,
                reg_ddrc_rd2wr_s,
                reg_ddrc_mrr2rd,
                reg_ddrc_mrr2wr,
                reg_ddrc_mrr2mrw,
                reg_ddrc_lp_optimized_write,
                reg_ddrc_rd2mr,
                reg_ddrc_wr2mr,
                reg_ddrc_wck_on,
                reg_ddrc_max_rd_sync,
                reg_ddrc_max_wr_sync,
                reg_ddrc_dfi_twck_delay,
                reg_ddrc_dfi_twck_en_rd,
                reg_ddrc_dfi_twck_en_wr,
                reg_ddrc_dfi_twck_dis,
                reg_ddrc_dfi_twck_fast_toggle,
                reg_ddrc_dfi_twck_toggle,
                reg_ddrc_dfi_twck_toggle_cs,
                reg_ddrc_dfi_twck_toggle_post,
                reg_ddrc_t_rrd,
                reg_ddrc_t_rrd_s,
                reg_ddrc_refresh_margin,
                reg_ddrc_t_rp,
                reg_ddrc_refresh_to_x1_x32,
                reg_ddrc_en_2t_timing_mode,
                reg_ddrc_prefer_write,


                reg_ddrc_t_mr,
                reg_ddrc_pre_cke_x1024,
                reg_ddrc_post_cke_x1024,
                reg_ddrc_emr2,
                reg_ddrc_emr3,
                reg_ddrc_mr,
                reg_ddrc_emr,
                reg_ddrc_mr4,
                reg_ddrc_mr5,
                reg_ddrc_mr6,
                reg_ddrc_mr22,
                reg_ddrc_dis_wc,
                reg_ddrc_dis_dq,
                reg_ddrc_dis_hif,
                reg_ddrc_rank_refresh,
                ddrc_reg_rank_refresh_busy,
                reg_ddrc_dis_auto_refresh,
                reg_ddrc_ctrlupd,
                ddrc_reg_ctrlupd_busy,
                reg_ddrc_dis_auto_ctrlupd,
                reg_ddrc_dis_auto_ctrlupd_srx,
                reg_ddrc_ctrlupd_pre_srx,
                reg_ddrc_addrmap_bank_b0,
                reg_ddrc_addrmap_bank_b1,
                reg_ddrc_addrmap_bank_b2,
                reg_ddrc_addrmap_bg_b0,
                reg_ddrc_addrmap_bg_b1,
                reg_ddrc_addrmap_col_b3,
                reg_ddrc_addrmap_col_b4,
                reg_ddrc_addrmap_col_b5,
                reg_ddrc_addrmap_col_b6,
                reg_ddrc_addrmap_col_b7,
                reg_ddrc_addrmap_col_b8,
                reg_ddrc_addrmap_col_b9,
                reg_ddrc_addrmap_col_b10,
                reg_ddrc_addrmap_row_b0,
                reg_ddrc_addrmap_row_b1,
                reg_ddrc_addrmap_row_b2,
                reg_ddrc_addrmap_row_b3,
                reg_ddrc_addrmap_row_b4,
                reg_ddrc_addrmap_row_b5,
                reg_ddrc_addrmap_row_b6,
                reg_ddrc_addrmap_row_b7,
                reg_ddrc_addrmap_row_b8,
                reg_ddrc_addrmap_row_b9,
                reg_ddrc_addrmap_row_b10,
                reg_ddrc_addrmap_row_b11,
                reg_ddrc_addrmap_row_b12,
                reg_ddrc_addrmap_row_b13,
                reg_ddrc_addrmap_row_b14,
                reg_ddrc_addrmap_row_b15,
                reg_ddrc_addrmap_row_b16,
                reg_ddrc_addrmap_row_b17,
                reg_ddrc_rank0_wr_odt,
                reg_ddrc_rank0_rd_odt,
                reg_ddrc_burst_rdwr,
                reg_ddrc_selfref_en,
                reg_ddrc_mr_rank,

                reg_ddrc_dfi_t_ctrlupd_interval_min_x1024,
                reg_ddrc_dfi_t_ctrlupd_interval_max_x1024,
                ddrc_reg_dbg_stall,
                ddrc_reg_dbg_w_q_depth,
                ddrc_reg_dbg_lpr_q_depth,
                ddrc_reg_dbg_hpr_q_depth,
                reg_ddrc_dis_auto_zq,
                reg_ddrc_dis_srx_zqcl,
                reg_ddrc_zq_resistor_shared,
                reg_ddrc_t_zq_long_nop,         // time to wait in ZQCL during init sequence
                reg_ddrc_t_zq_short_nop,        // time to wait in ZQCS during init sequence
                reg_ddrc_t_zq_short_interval_x1024,
                reg_ddrc_zq_calib_short,
                ddrc_reg_zq_calib_short_busy,
                reg_ddrc_sw_init_int,           // SW intervention in auto SDRAM initialization
                reg_ddrc_dram_rstn_x1024,          // time for dram reset to stay low

                reg_ddrc_derate_mr4_tuf_dis,
                core_derate_temp_limit_intr,
                derate_sync_ack_c2p,
                reg_ddrc_active_derate_byte_rank0,
                reg_ddrc_dbg_mr4_rank_sel,
                reg_ddrc_dbg_mr4_grp_sel,
                ddrc_reg_dbg_mr4_byte0,
                ddrc_reg_dbg_mr4_byte1,
                ddrc_reg_dbg_mr4_byte2,
                ddrc_reg_dbg_mr4_byte3,

                reg_ddrc_lpddr4_refresh_mode,
                reg_ddrc_zq_reset,
                reg_ddrc_t_zq_reset_nop,
                ddrc_reg_zq_reset_busy,
                reg_ddrc_derate_enable,
                reg_ddrc_derated_t_rcd,
                reg_ddrc_derated_t_ras_min,
                reg_ddrc_derated_t_rp,
                reg_ddrc_derated_t_rrd,
                reg_ddrc_derated_t_rc,
                reg_ddrc_derate_mr4_pause_fc,
                reg_ddrc_mr4_read_interval,
                reg_ddrc_per_bank_refresh,
                reg_ddrc_auto_refab_en,
                reg_ddrc_refresh_to_ab_x32,
                hif_refresh_req_bank,
                reg_ddrc_lpddr4,
                reg_ddrc_lpddr5,
                reg_ddrc_bank_org,
                reg_ddrc_lpddr4_diff_bank_rwa2pre,
                reg_ddrc_stay_in_selfref,
                reg_ddrc_t_cmdcke,
                reg_ddrc_dsm_en,
                reg_ddrc_t_pdn,
                reg_ddrc_t_xsr_dsm_x1024,
                reg_ddrc_t_csh,
                reg_ddrc_nonbinary_device_density,
                hif_mrr_data,
                hif_mrr_data_valid,
                ddrc_reg_selfref_cam_not_empty,
                ddrc_reg_selfref_state,
                reg_ddrc_mrr_done_clr,
                ddrc_reg_mrr_done,
                ddrc_reg_mrr_data_lwr,
                ddrc_reg_mrr_data_upr,
                ddrc_reg_operating_mode,
                ddrc_reg_selfref_type,
                ddrc_reg_wr_q_empty,
                ddrc_reg_rd_q_empty,
                ddrc_reg_wr_data_pipeline_empty,
                ddrc_reg_rd_data_pipeline_empty,

                reg_ddrc_dfi_phyupd_en,

                reg_ddrc_dfi_phymstr_en,
                reg_ddrc_dfi_phymstr_blk_ref_x32,
                reg_ddrc_dis_cam_drain_selfref,
                reg_ddrc_lpddr4_sr_allowed,
                reg_ddrc_lpddr4_opt_act_timing,
                reg_ddrc_lpddr5_opt_act_timing,
                reg_ddrc_dfi_t_ctrl_delay,
                reg_ddrc_dfi_t_wrdata_delay,

                reg_ddrc_dfi_t_dram_clk_disable,
                reg_ddrc_dfi_t_dram_clk_enable,
                reg_ddrc_t_cksre,
                reg_ddrc_t_cksrx,
                reg_ddrc_t_ckcsx,
                reg_ddrc_t_ckesr,

                reg_ddrc_oc_parity_en,
                reg_ddrc_oc_parity_type,

                reg_ddrc_par_poison_en,
                reg_ddrc_par_poison_loc_rd_iecc_type,

                par_rdata_in_err_ecc_pulse,
                par_wdata_out_err_pulse,
                par_wdata_out_err_ie_pulse,
                reg_ddrc_par_rdata_err_intr_clr,

                ocecc_en,
                ocecc_poison_egen_xpi_rd_0,
                ocecc_poison_egen_mr_rd_1,
                ocecc_poison_egen_mr_rd_1_byte_num,
                ocecc_poison_single,
                ocecc_poison_pgen_rd,
                ocecc_poison_pgen_mr_ecc,
                ocecc_uncorr_err_intr_clr,

                ocecc_mr_rd_corr_err,
                ocecc_mr_rd_uncorr_err,
                ocecc_mr_rd_byte_num,

                reg_ddrc_sw_done,
                reg_ddrc_occap_en,
                ddrc_occap_wufifo_parity_err,
                ddrc_occap_wuctrl_parity_err,
                ddrc_occap_rtfifo_parity_err,
                ddrc_occap_rtctrl_parity_err,
                ddrc_occap_dfidata_parity_err,
                ddrc_occap_eccaccarray_parity_err,
                reg_ddrc_occap_ddrc_ctrl_poison_seq,
                reg_ddrc_occap_ddrc_ctrl_poison_parallel,
                reg_ddrc_occap_ddrc_ctrl_poison_err_inj,
                occap_ddrc_ctrl_err,
                occap_ddrc_ctrl_poison_complete,
                occap_ddrc_ctrl_poison_seq_err,
                occap_ddrc_ctrl_poison_parallel_err,

                reg_ddrc_occap_ddrc_data_poison_seq,
                reg_ddrc_occap_ddrc_data_poison_parallel,
                reg_ddrc_occap_ddrc_data_poison_err_inj,
                occap_ddrc_data_err,
                occap_ddrc_data_poison_seq_err,
                occap_ddrc_data_poison_parallel_err,
                occap_ddrc_data_poison_complete,


                        reg_ddrc_dfi_lp_data_req_en,
                        reg_ddrc_dfi_lp_en_pd,
                        reg_ddrc_dfi_lp_wakeup_pd,
                        reg_ddrc_dfi_lp_en_sr,
                        reg_ddrc_dfi_lp_wakeup_sr,
                        reg_ddrc_dfi_lp_en_data,
                        reg_ddrc_dfi_lp_wakeup_data,
                        reg_ddrc_dfi_lp_en_dsm,
                        reg_ddrc_dfi_lp_wakeup_dsm,
                        reg_ddrc_skip_dram_init,
                        reg_ddrc_dfi_tlp_resp


                       ,reg_ddrc_dis_dqsosc_srx
                       ,reg_ddrc_dqsosc_enable                 // DQSOSC enable
                       ,reg_ddrc_t_osco                        // t_osco timing
                       ,reg_ddrc_dqsosc_runtime
                       ,reg_ddrc_wck2dqo_runtime               // Oscillator runtime only for LPDDR5
                       ,reg_ddrc_dqsosc_interval               // DQSOSC inverval
                       ,reg_ddrc_dqsosc_interval_unit          // DQSOSC interval unit
                       ,dqsosc_state
                       ,dqsosc_per_rank_stat
                     ,dwc_ddrphy_snoop_en
                      ,reg_ddrc_dfi_t_ctrlmsg_resp
                      ,reg_ddrc_dfi0_ctrlmsg_req
                      ,reg_ddrc_dfi0_ctrlmsg_tout_clr
                      ,reg_ddrc_dfi0_ctrlmsg_data
                      ,reg_ddrc_dfi0_ctrlmsg_cmd
                      ,ddrc_reg_dfi0_ctrlmsg_req_busy
                      ,ddrc_reg_dfi0_ctrlmsg_resp_tout
//registers for DDR5
                );

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
parameter UMCTL2_WDATARAM_DW    = 1;
parameter       CHANNEL_NUM = 0;
parameter       SHARED_AC = 0;
parameter       SHARED_AC_INTERLEAVE = 0;
parameter       BCM_VERIF_EN = 1;
parameter       BCM_DDRC_N_SYNC = 2;
parameter       BCM_F_SYNC_TYPE_P2C = 2;
parameter       MEMC_ECC_SUPPORT = 0;
parameter       UMCTL2_SEQ_BURST_MODE = 0;                       // Applies LPDDR4 like squential burst mode only
parameter       UMCTL2_PHY_SPECIAL_IDLE = 0;                     // A specially encoded "IDLE" command over the DFI bus: {ACT_n,RAS_n,CAS_n,WE_n,BA0}
parameter       OCPAR_EN = 0;                                    // enables on-chip parity
parameter       OCECC_EN = 0;                                    // enables on-chip ECC
localparam      OCPAR_OR_OCECC_EN = (OCPAR_EN==1 || OCECC_EN==1);
parameter       OCECC_XPI_RD_GRANU = 64;
parameter       OCECC_MR_RD_GRANU = 8;
parameter       OCECC_MR_BNUM_WIDTH = 5;
parameter       OCCAP_EN = 0;                                    // enables on-chip command/address path protection
parameter       OCCAP_PIPELINE_EN = 0;                           // enables pipeline for on-chip command/address path protection
parameter       CP_ASYNC = 0;
parameter       NPORTS = 1;                                      // no. of ports (for cactive_in_ddrc width) gets overwritten by toplevel
parameter       NPORTS_LG2 = 1;                                      // log2 of no. of ports (for ih_dual) gets overwritten by toplevel
parameter       A_SYNC_TABLE = 16'hffff; // AXI sync table
parameter       RD_CAM_ADDR_WIDTH     = `MEMC_RDCMD_ENTRY_BITS;   // bits to address into read CAM
parameter       WR_CAM_ADDR_WIDTH     = `MEMC_WRCMD_ENTRY_BITS;   // bits to address into write CAM
parameter       WR_ECC_CAM_ADDR_WIDTH = (`MEMC_INLINE_ECC_EN==1)? WR_CAM_ADDR_WIDTH - 1 : 0; // WR ECC CAM size is half of WR CAM
localparam      ADJ_WRDATA_RAM_ADDR_WIDTH = 0;
parameter       WRDATA_RAM_ADDR_WIDTH = `UMCTL2_WDATARAM_AW + ADJ_WRDATA_RAM_ADDR_WIDTH;
parameter       WRDATA_RAM_DEPTH = `UMCTL2_WDATARAM_DEPTH; // write data RAM depth
parameter       CORE_DATA_WIDTH = `MEMC_DFI_DATA_WIDTH;        // internal data width
parameter       CORE_MASK_WIDTH = `MEMC_DFI_DATA_WIDTH/8;              // data mask width
parameter       CORE_ADDR_WIDTH = `MEMC_HIF_ADDR_WIDTH_MAX;
parameter       WDATA_PAR_WIDTH = `UMCTL2_WDATARAM_PAR_DW;
parameter       WDATA_PAR_WIDTH_EXT = `UMCTL2_WDATARAM_PAR_DW_EXT;
localparam      WRSRAM_DATA_WIDTH = CORE_DATA_WIDTH;                 // WR-SRAM data width
localparam      WRSRAM_MASK_WIDTH = CORE_MASK_WIDTH;                 // WR-SRAM data mask width
// This is the actual width of the address bus used inside DDRC
parameter       CORE_ADDR_INT_WIDTH = (`UMCTL2_LRANK_BITS+`MEMC_BG_BANK_BITS+`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS);

parameter       CORE_TAG_WIDTH  = `MEMC_TAGBITS;                // width of tag

parameter       ECC_POISON_REG_WIDTH= `ECC_POISON_REG_WIDTH;

parameter       RANK_BITS       = `MEMC_RANK_BITS;
parameter       LRANK_BITS      = `UMCTL2_LRANK_BITS;
parameter       CID_WIDTH       = `UMCTL2_CID_WIDTH;
parameter       BG_BITS         = `MEMC_BG_BITS;
parameter       BG_BANK_BITS    = `MEMC_BG_BANK_BITS;
parameter       BANK_BITS       = `MEMC_BANK_BITS;
parameter       PAGE_BITS       = `MEMC_PAGE_BITS;
parameter       WORD_BITS       = `MEMC_WORD_BITS;              // address a word within a burst
parameter       BLK_BITS        = `MEMC_BLK_BITS;               // 2 column bits are critical word
parameter       BSM_BITS        = `UMCTL2_BSM_BITS;
localparam      COL_BITS        = WORD_BITS + BLK_BITS;

parameter       MRS_A_BITS      = `MEMC_PAGE_BITS;
parameter       MRS_BA_BITS     = `MEMC_BG_BANK_BITS;

parameter       PHY_ADDR_BITS   = `MEMC_DFI_ADDR_WIDTH;

parameter       NUM_TOTAL_BANKS = `MEMC_NUM_TOTAL_BANKS;        // max supported banks
parameter       NUM_RANKS       = `MEMC_NUM_RANKS;              // max supported ranks (chip selects)
parameter       NUM_LRANKS      = `UMCTL2_NUM_LRANKS_TOTAL;     // max supported logical ranks (chip selects * chip ID(for DDR4 3DS))
parameter       NUM_TOTAL_BSMS  = `UMCTL2_NUM_BSM;              // max supported BSMs

parameter       NUM_PHY_DRAM_CLKS = `MEMC_NUM_CLKS;

localparam      RD_CAM_ENTRIES          = 1 << RD_CAM_ADDR_WIDTH;
localparam      WR_CAM_ENTRIES          = 1 << WR_CAM_ADDR_WIDTH;
localparam      WR_ECC_CAM_ENTRIES      = (`MEMC_INLINE_ECC_EN==1)? WR_CAM_ENTRIES/2 : 0;
localparam      WR_CAM_ENTRIES_IE       = WR_CAM_ENTRIES +  WR_ECC_CAM_ENTRIES;
localparam      WR_CAM_ADDR_WIDTH_IE    = WR_CAM_ADDR_WIDTH + `MEMC_INLINE_ECC_EN;
localparam      MAX_CAM_ADDR_WIDTH      = (WR_CAM_ADDR_WIDTH_IE>RD_CAM_ADDR_WIDTH)? WR_CAM_ADDR_WIDTH_IE : RD_CAM_ADDR_WIDTH;


parameter       PHY_DATA_WIDTH  = `MEMC_DFI_TOTAL_DATA_WIDTH;       // data width to PHY
parameter       PHY_MASK_WIDTH  = `MEMC_DFI_TOTAL_DATA_WIDTH/8;     // data mask width (internal to uMCTL2)
parameter       PHY_DBI_WIDTH   = `MEMC_DFI_TOTAL_DATA_WIDTH/8;       // read data DBI width from PHY

parameter AM_DCH_WIDTH   = 6;
parameter AM_CS_WIDTH    = 6;
parameter AM_CID_WIDTH   = 6;
parameter AM_BANK_WIDTH  = 6;
parameter AM_BG_WIDTH    = 6;
parameter AM_ROW_WIDTH   = 5;
parameter AM_COL_WIDTH_H = 5;
parameter AM_COL_WIDTH_L = 4;
parameter DFI_T_CTRLMSG_RESP_WIDTH = 8;
parameter DFI_CTRLMSG_DATA_WIDTH   = 16;
parameter DFI_CTRLMSG_CMD_WIDTH    = 8;
parameter MWR_BITS = 1; // currently 1-bit info (OR of all data beats)
parameter PARTIAL_WR_BITS = `UMCTL2_PARTIAL_WR_BITS;
localparam PARTIAL_WR_BITS_LOG2 = $clog2(PARTIAL_WR_BITS);

localparam PW_NUM_DB = PARTIAL_WR_BITS;

localparam PW_FACTOR_QBW = 4*`MEMC_FREQ_RATIO;
localparam PW_FACTOR_HBW = 2*`MEMC_FREQ_RATIO;
localparam PW_FACTOR_FBW = 1*`MEMC_FREQ_RATIO;

localparam PW_WORD_VALID_WD_QBW = PW_NUM_DB*PW_FACTOR_QBW;
localparam PW_WORD_VALID_WD_HBW = PW_NUM_DB*PW_FACTOR_HBW;
localparam PW_WORD_VALID_WD_FBW = PW_NUM_DB*PW_FACTOR_FBW;

localparam PW_WORD_VALID_WD_MAX = PW_WORD_VALID_WD_QBW;

localparam PW_WORD_CNT_WD_MAX = $clog2(PW_WORD_VALID_WD_MAX);

parameter       CORE_ECC_WIDTH = `MEMC_DFI_ECC_WIDTH;    // width of the internal ECC bus
localparam      WSRAM_ECC_WIDTH = CORE_ECC_WIDTH;
localparam      WSRAM_ECC_MASK_WIDTH = WSRAM_ECC_WIDTH/8;

parameter       NUM_LANES  = 4; //Number of lanes in PHY - default is 4

parameter       RETRY_MAX_ADD_RD_LAT     = 2;
parameter       RETRY_MAX_ADD_RD_LAT_LG2 = 1;
parameter       CMD_LEN_BITS     = 1;                            // command length bit width

parameter       WRDATA_CYCLES    = 2;

parameter       MAX_NUM_NIBBLES = 18;
parameter       DRAM_BYTE_NUM = `MEMC_DRAM_TOTAL_BYTE_NUM;

// parameters used to avoid multi-concat issues in drivinig of ddrc_ctrl
// outpus[x-1:0] where x=0
localparam      RANK_BITS_DUP            = (RANK_BITS==0)       ? 1 : RANK_BITS;
localparam      LRANK_BITS_DUP           = (LRANK_BITS==0)      ? 1 : LRANK_BITS;
localparam      BG_BITS_DUP              = (BG_BITS==0)         ? 1 : BG_BITS;
localparam      CID_WIDTH_DUP            = (CID_WIDTH==0)       ? 1 : CID_WIDTH;
localparam      CORE_ECC_WIDTH_DUP       = (CORE_ECC_WIDTH==0)  ? 1 : CORE_ECC_WIDTH;
localparam      CORE_ECC_MASK_WIDTH_DUP  = (CORE_ECC_WIDTH==0)  ? 1 : CORE_ECC_WIDTH/8;

localparam      RANKBANK_BITS_FULL = LRANK_BITS + BG_BITS + BANK_BITS;
// any changes to this will also require RTL modifications
localparam      CMD_TYPE_BITS   = 2;                            // command type bit width
localparam      CMD_RMW_BITS    = 1;                            // unused, but '0' breaks things still...
localparam      RMW_TYPE_BITS   = 2;                            // 2-bit RMW type
                                                                //  (partial write, scrub, atomic RMW, none)
localparam      WDATA_PTR_BITS  = `MEMC_WDATA_PTR_BITS;

localparam      OTHER_WR_ENTRY_BITS = RMW_TYPE_BITS ;


localparam      FATL_CODE_BITS = `UMCTL2_FATL_BITS;

localparam DDRC_CTRL_CMP = 1; // OCCAP_EN comparison for DDRC_CTRL
localparam DDRC_DATA_CMP = 2; // OCCAP_EN comparison for DDRC_DATA
parameter MAX_CMD_NUM       = 2;

//------------------------------------------------------------------------------
// Input and Output Declarations
//------------------------------------------------------------------------------

input                           core_ddrc_core_clk;
input                           core_ddrc_rstn;

input   [NUM_RANKS-1:0]         bsm_clk;                // For power saving purpose, bsm instances speficic clock
output  [NUM_RANKS-1:0]         bsm_clk_en;             // Clock enable for bsm instances
input   [BSM_CLK_ON_WIDTH-1:0]  bsm_clk_on;             // bsm_clk always on


input                           hif_cmd_valid;          // valid command
input   [CMD_TYPE_BITS-1:0]     hif_cmd_type;           // command type:
                                                        //  00 - block write
                                                        //  01 - read
                                                        //  10 - partial write
                                                        //  01 - read-mod-write
input   [1:0]                   hif_cmd_pri;            // priority: // TEMP ONLY - make it 2-bits when ARB is connected
                                                        //  HIF config: 0 - LPR, 1 - HPR
                                                        //  Arbiter config: 00 - LPR, 01 - VPR, 10 - HPR, 11 - Unused
  //ccx_tgl : ; hif_cmd_addr[2:0]; ; HIF Address is always aligned to 8 DRAM words. So lower 3 bits are always 0.
input   [CORE_ADDR_WIDTH-1:0]   hif_cmd_addr;           // address
input   [CMD_LEN_BITS-1:0]      hif_cmd_length;         // length (1 word or 2)
                                                        //  1 - 1 word length
                                                        //  2 - 2 word lengths
                                                        // (where 1 word equals the size of the data transfer
                                                        //  between the core and the controller)
input   [CORE_TAG_WIDTH-1:0]    hif_cmd_token;          // read token,
                                                        //  returned w/ read data
input   [WDATA_PTR_BITS-1:0]    hif_cmd_wdata_ptr;      // incoming wdata ptr



input                           hif_cmd_autopre;        // auto precharge enable


input                           hif_wdata_valid;       // valid write data being transfered
input   [CORE_DATA_WIDTH-1:0]   hif_wdata;             // write data. valid when co_ih_rxdata_valid=1
input   [CORE_MASK_WIDTH-1:0]   hif_wdata_mask;        // write data. valid when co_ih_rxdata_valid=1
input                           hif_wdata_end;
input   [WDATA_PAR_WIDTH-1:0]   hif_wdata_parity;      // write data parity.



output                          hif_wdata_stall;        // write data stall signal
                                                        // write data/mask are accepted when data_valid is high
                                                        // and data_stall is low on the same clock edge

input                           hif_go2critical_lpr;
input                           hif_go2critical_hpr;
input                           hif_go2critical_wr;

input                           hif_go2critical_l1_wr;
input                           hif_go2critical_l2_wr;
input                           hif_go2critical_l1_lpr;
input                           hif_go2critical_l2_lpr;
input                           hif_go2critical_l1_hpr;
input                           hif_go2critical_l2_hpr;

output                          hif_cmd_stall;            // request stall
output                          hif_wdata_ptr_valid;
output  [WDATA_PTR_BITS-1:0]    hif_wdata_ptr;
output                          hif_wdata_ptr_addr_err;   // Indicates that the write was associated with an invalid address
output [`MEMC_HIF_CREDIT_BITS-1:0]  hif_lpr_credit;
output                              hif_wr_credit;
output [`MEMC_HIF_CREDIT_BITS-1:0]  hif_hpr_credit;
output [1:0]                        hif_wrecc_credit;
input                           reg_ddrc_mr_wr;            // input from core to write mode register
input                           reg_ddrc_sw_init_int;       // SW intervention in auto SDRAM initialization
input                           reg_ddrc_mr_type;          // MR Type R/W.
input   [3:0]                   reg_ddrc_mr_addr;          // input from core: mode register address
                                                            // 0000: MR0, 0001: MR1, 0010: MR2, 0011: MR3, 0100: MR4, 0101: MR5, 0110: MR6
input   [PAGE_BITS-1:0]         reg_ddrc_mr_data;          // mode register data to be written
output                          ddrc_reg_mr_wr_busy;       // indicates that mode register write operation is in progress
input                           reg_ddrc_burst_mode;       // 1 = interleaved burst mode, 0 = sequential burst mode

input                           reg_ddrc_derate_mr4_tuf_dis;
output                          core_derate_temp_limit_intr;
input        derate_sync_ack_c2p;
input   [ACTIVE_DERATE_BYTE_RANK_WIDTH-1:0] reg_ddrc_active_derate_byte_rank0;
input   [DBG_MR4_RANK_SEL_WIDTH-1:0]        reg_ddrc_dbg_mr4_rank_sel;
input   [DBG_MR4_GRP_SEL_WIDTH-1:0]         reg_ddrc_dbg_mr4_grp_sel;
output   [DBG_MR4_BYTE_WIDTH-1:0]           ddrc_reg_dbg_mr4_byte0;
output   [DBG_MR4_BYTE_WIDTH-1:0]           ddrc_reg_dbg_mr4_byte1;
output   [DBG_MR4_BYTE_WIDTH-1:0]           ddrc_reg_dbg_mr4_byte2;
output   [DBG_MR4_BYTE_WIDTH-1:0]           ddrc_reg_dbg_mr4_byte3;


input                               reg_ddrc_lpddr4_refresh_mode;
input                               reg_ddrc_zq_reset;
//ccx_tgl : ; reg_ddrc_t_zq_reset_nop[9]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [T_ZQ_RESET_NOP_WIDTH-1:0]  reg_ddrc_t_zq_reset_nop;
output                              ddrc_reg_zq_reset_busy;
input   [DERATE_ENABLE_WIDTH-1:0]   reg_ddrc_derate_enable;
  //ccx_tgl : ; reg_ddrc_derated_t_rcd[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. yy
input   [DERATED_T_RCD_WIDTH-1:0]     reg_ddrc_derated_t_rcd;
  //ccx_tgl : ; reg_ddrc_derated_t_ras_min[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. yy
input   [DERATED_T_RAS_MIN_WIDTH-1:0] reg_ddrc_derated_t_ras_min;
  //ccx_tgl : ; reg_ddrc_derated_t_rp[6]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. yy
input   [DERATED_T_RP_WIDTH-1:0]      reg_ddrc_derated_t_rp;
  //ccx_tgl : ; reg_ddrc_derated_t_rrd[5]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. yy
input   [DERATED_T_RRD_WIDTH-1:0]     reg_ddrc_derated_t_rrd;
  //ccx_tgl : ; reg_ddrc_derated_t_rc[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. yy
input   [DERATED_T_RC_WIDTH-1:0]      reg_ddrc_derated_t_rc;


input                           reg_ddrc_derate_mr4_pause_fc;
input   [MR4_READ_INTERVAL_WIDTH-1:0]                  reg_ddrc_mr4_read_interval;


output                          hif_rdata_valid;       // indicates valid response
output                          hif_rdata_end;         // current cycle is the last for this response
output  [CORE_TAG_WIDTH-1:0]    hif_rdata_token;       // provided with request and returned here with response
output  [CORE_DATA_WIDTH-1:0]   hif_rdata;        // data
output  [CORE_MASK_WIDTH-1:0]   hif_rdata_parity; // data parity


output                          hif_rdata_addr_err; // Indicates that the read token returned on hif_rdata_token was associated with an invalid address

input        [UMCTL2_WDATARAM_DW-1:0]       wdataram_dout;
output       [UMCTL2_WDATARAM_DW-1:0]       wdataram_din;
output       [UMCTL2_WDATARAM_DW/8-1:0]     wdataram_mask;

output                                                             wdataram_wr;
output       [WRDATA_RAM_ADDR_WIDTH-ADJ_WRDATA_RAM_ADDR_WIDTH-1:0] wdataram_raddr;
output                                                             wdataram_re;
output       [WRDATA_RAM_ADDR_WIDTH-ADJ_WRDATA_RAM_ADDR_WIDTH-1:0] wdataram_waddr;
input        [WDATA_PAR_WIDTH_EXT-1:0]               wdataram_dout_par;
output       [WDATA_PAR_WIDTH_EXT-1:0]               wdataram_din_par;


output                                               hif_cmd_q_not_empty;    // indicates that there are commands pending in the cams

input        [NPORTS-1:0]                            cactive_in_ddrc;
input        [NPORTS-1:0]                            cactive_in_ddrc_async;
input                                                csysreq_ddrc;
output                                               csysack_ddrc;
output                                               cactive_ddrc;

output [SELFREF_TYPE_WIDTH - 1:0]                    stat_ddrc_reg_selfref_type;






dwc_ddrctl_ddrc_cpedfi_if.cp_dfi_mp          cp_dfiif; // DFI interface
//ccx_tgl : ; cp_dfiif.dfi_cs[3:2] ; ; The bits are assigned to dfi0_cs_P1[1:0] and is not toggled.
//ccx_tgl : ; cp_dfiif.dfi_ctrlmsg[2] ; 0->1 ; SystemVerilog Interface(redundant): LPDDR5/4/4X Controller only supports Fixed value of 0x8,0x2,0x9,0xA (Similar thing was fixed in Bug 10153)
//ccx_tgl : ; cp_dfiif.dfi_ctrlmsg[7:4] ; 0->1 ; SystemVerilog Interface(redundant): LPDDR5/4/4X Controller only supports Fixed value of 0x8,0x2,0x9,0xA (Similar thing was fixed in Bug 10153)

output  [PHY_DATA_WIDTH-1:0]                 dfi_wrdata;
output  [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0]   dfi_wrdata_en;
output  [`MEMC_DFI_TOTAL_MASK_WIDTH-1:0]     dfi_wrdata_mask;

input   [PHY_DATA_WIDTH-1:0]                 dfi_rddata;
output  [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0]   dfi_rddata_en;
input   [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0]   dfi_rddata_valid;
input   [PHY_DBI_WIDTH-1:0]                  dfi_rddata_dbi;   // read data DBI from PHY (low active)

input   [DFI_TPHY_WRCSLAT_WIDTH-1:0]       reg_ddrc_dfi_tphy_wrcslat;
input  [6:0]                    reg_ddrc_dfi_tphy_rdcslat;
input                           reg_ddrc_dfi_data_cs_polarity;

output  [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]   dfi_wck_cs;
output  [`MEMC_FREQ_RATIO-1:0]             dfi_wck_en;
output  [2*`MEMC_FREQ_RATIO-1:0]           dfi_wck_toggle;


input                           reg_ddrc_dfi_init_start;
input   [4:0]                   reg_ddrc_dfi_frequency;
input  [DFI_FREQ_FSP_WIDTH-1:0] reg_ddrc_dfi_freq_fsp;
input                           dfi_reset_n_in;
output                          dfi_reset_n_ref;
input                           init_mr_done_in;
//ccx_tgl : ; init_mr_done_out; 0->1 ; This is covered in HIF configurations.
output                          init_mr_done_out;




input                           reg_ddrc_dfi_init_complete_en;
input                           reg_ddrc_frequency_ratio;      // Frequency ratio, 1 - 1:1 mode, 0 - 1:2 mode
input                           reg_ddrc_phy_dbi_mode;
input                           reg_ddrc_wr_dbi_en;
input                           reg_ddrc_rd_dbi_en;
input                           reg_ddrc_dm_en;

wire    [PHY_DATA_WIDTH-1:0]    phy_ddrc_rdata;         // read data from PHY
wire    [PHY_DBI_WIDTH-1:0]         phy_ddrc_rdbi_n;    // read dbi from PHY
wire    [PHY_DATA_WIDTH/16-1:0] phy_ddrc_rdatavld;

input                           reg_ddrc_en_dfi_dram_clk_disable;       // 1=allow controller+PHY to stop the clock to DRAM

//---- register inputs ----
input   [1:0]                   reg_ddrc_data_bus_width;        // data bus width.
                                                                //  00 - 4 beats (2 1X cycles) of data per CAM entry
                                                                //  01 - 8 beats (4 1X cycles) of data per CAM entry
                                                                //  10, 11 - RESERVED in ddrc6
input   [4:0]                   reg_ddrc_burst_rdwr;            // 5'h00010=burst of 4 data read/write
                                                                // 5'h00100=burst of 8 data read/write
                                                                // 5'h01000=burst of 16 data read/write
                                                                // 5'h10000=burst of 32 data read/write

input                           reg_ddrc_dis_dq;                // 1=disable dequeue (stall scheduler); 0=normal operation
input                           reg_ddrc_dis_hif;               // 1=disable to accept rd/wr on hif (stall hif); 0=normal operation
input                           reg_ddrc_dis_wc;                // 1=disable write combine; 0=allow write combine

input   [NUM_LRANKS-1:0]        reg_ddrc_rank_refresh;         // cmd issuing refresh to logical rank
output  [NUM_LRANKS-1:0]        ddrc_reg_rank_refresh_busy;    // If 1: Previous dh_gs_rank_refresh has not been stored
input                           reg_ddrc_dis_auto_refresh;      // 1= disable auto_refresh issued by
                                                                // the controller. Issue refresh based only
                                                                // on the rankX_refresh command from reg_ddrc_rankX_refresh, where X = 0, 1, 2, 3
input                           reg_ddrc_ctrlupd;               // ctrlupd command
output                          ddrc_reg_ctrlupd_busy;          // If 1: Previous ctrlupd from APB register reg_ddrc_ctrlupd has not been initiated
input                           reg_ddrc_dis_auto_ctrlupd;      // 1 = disable ctrlupd issued by the controller
                                                                // ctrlupd command will be issued by APB register reg_ddrc_ctrlupd
                                                                // 0 = enable ctrlupd issued by the controller
input                           reg_ddrc_dis_auto_ctrlupd_srx;  // 1 = disable ctrlupd issued by the controller following a self-refresh exit
                                                                // ctrlupd command will be issued by APB register reg_ddrc_ctrlupd
                                                                // 0 = enable ctrlupd issued by the controller following a self-refresh exit
input                           reg_ddrc_ctrlupd_pre_srx;       // 1 = ctrlupd sent before SRX
                                                                // 0 = ctrlupd sent after SRX
input                           reg_ddrc_dis_speculative_act;
input                           reg_ddrc_prefer_read;
input   [RD_CAM_ADDR_WIDTH-1:0] reg_ddrc_lpr_num_entries;       // number of entries in low priority read queue
input                           reg_ddrc_lpr_num_entries_changed; // lpr_num_entries register has been changed
input   [15:0]                  reg_ddrc_mr;                    // mode register (MR) value written in init
input   [15:0]                  reg_ddrc_emr;                   // extended mode register (EMR) value written in init
input   [15:0]                  reg_ddrc_emr2;                  // extended mode register 2 (EMR2) value written in init
input   [15:0]                  reg_ddrc_emr3;                  // extended mode register 3 (EMR3) value written in init
input   [15:0]                  reg_ddrc_mr4;                   // mode register (MR4) value written in init
input   [15:0]                  reg_ddrc_mr5;                   // mode register (MR5) value written in init
input   [15:0]                  reg_ddrc_mr6;                   // mode register (MR6) value written in init
input   [15:0]                  reg_ddrc_mr22;                  // mode register (MR22) value written in init
  //ccx_tgl : ; reg_ddrc_t_rcd[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RCD_WIDTH-1:0] reg_ddrc_t_rcd;                 // tRCD: RAS-to-CAS delay
  //ccx_tgl : ; reg_ddrc_t_ras_min[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RAS_MIN_WIDTH-1:0] reg_ddrc_t_ras_min;             // tRAS(min): minimum page open time
  //ccx_tgl : ; reg_ddrc_t_ras_max[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RAS_MAX_WIDTH-1:0] reg_ddrc_t_ras_max;             // tRAS(max): maximum page open time
  //ccx_tgl : ; reg_ddrc_t_rc[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RC_WIDTH-1:0] reg_ddrc_t_rc;                  // tRC: row cycle time
  //ccx_tgl : ; reg_ddrc_t_rp[6]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RP_WIDTH-1:0] reg_ddrc_t_rp;                  // tRP: row precharge time
  //ccx_tgl : ; reg_ddrc_t_rrd[5]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RRD_WIDTH-1:0] reg_ddrc_t_rrd;                 // tRRD: RAS-to-RAS min delay
  //ccx_tgl : ; reg_ddrc_t_rrd_s[5]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_RRD_S_WIDTH-1:0] reg_ddrc_t_rrd_s;               // tRRD_S: RAS-to-RAS min delay (short)
  //ccx_tgl : ; reg_ddrc_rd2pre[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [RD2PRE_WIDTH-1:0] reg_ddrc_rd2pre;                // min read-to-precharge command delay
  //ccx_tgl : ; reg_ddrc_wr2pre[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [WR2PRE_WIDTH-1:0] reg_ddrc_wr2pre;                // min write-to-precharge command delay
  //ccx_tgl : ; reg_ddrc_rda2pre[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [RDA2PRE_WIDTH-1:0] reg_ddrc_rda2pre;               // min read-to-precharge command delay
  //ccx_tgl : ; reg_ddrc_wra2pre[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [WRA2PRE_WIDTH-1:0] reg_ddrc_wra2pre;               // min write-to-precharge command delay
input                           reg_ddrc_pageclose;             // close open pages by default
input   [7:0]                   reg_ddrc_pageclose_timer;       // timer for close open pages by default
input   [2:0]                   reg_ddrc_page_hit_limit_rd;     // page-hit limiter for rd
input   [2:0]                   reg_ddrc_page_hit_limit_wr;     // page-hit limiter for wr
input                           reg_ddrc_opt_hit_gt_hpr;        // 0 - page-miss HPR > page-hit LPR; 1 - page-hit LPR > page-miss HPR
input   [REFRESH_MARGIN_WIDTH-1:0]                   reg_ddrc_refresh_margin;        // how early to start trying to refresh or
                                                                //  close a page for tRAS(max)
input   [PRE_CKE_X1024_WIDTH-1:0]  reg_ddrc_pre_cke_x1024;       // wait time at start of init sequence
                                                                //  (in pulses of 1024-cycle timer)
input   [POST_CKE_X1024_WIDTH-1:0] reg_ddrc_post_cke_x1024;      // wait time after asserting CKE in init sequence
                                                                //  (in pulses of 1024-cycle timer)
  //ccx_tgl : ; reg_ddrc_rd2wr[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [RD2WR_WIDTH-1:0] reg_ddrc_rd2wr;                 // min read-to-write command delay
  //ccx_tgl : ; reg_ddrc_wr2rd[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [WR2RD_WIDTH-1:0] reg_ddrc_wr2rd;                 // min write-to-read command delay
input   [WR2RD_S_WIDTH-1:0] reg_ddrc_wr2rd_s;               // min write-to-read command delay (short)
input   [5:0]                   reg_ddrc_refresh_burst;         // this + 1 = # of refreshes to burst
  //ccx_tgl : ; reg_ddrc_t_ccd[5]; ; This register bit width is wider than the maximum value which might be set in real.  
input   [T_CCD_WIDTH-1:0] reg_ddrc_t_ccd;                 // tCCD: CAS-to-CAS min delay
  //ccx_tgl : ; reg_ddrc_t_ccd_s[4]; ; 8bit toggle can be set with 12 or 16Gb density, all bank refresh and 4266Mbps config. And 0 to 1 toggling can be covered when frequency change happened with above config.  
input   [T_CCD_S_WIDTH-1:0] reg_ddrc_t_ccd_s;               // tCCD_S: CAS-to-CAS min delay (short)
  //ccx_tgl : ; reg_ddrc_odtloff[6]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [ODTLOFF_WIDTH-1:0]          reg_ddrc_odtloff;               // ODTLoff: This is latency from CAS-2 command to tODToff reference.
  //ccx_tgl : ; reg_ddrc_t_ccd_mw[6]; ; This register bit width is wider than the maximum value which might be set in real. Therefore bit[11:9] can't be covered  
input   [T_CCD_MW_WIDTH-1:0]         reg_ddrc_t_ccd_mw;              // tCCDMW: CAS-to-CAS min delay masked write
input                                reg_ddrc_dis_trefi_x6x8;
input                                reg_ddrc_dis_trefi_x0125;
  //ccx_tgl : ; reg_ddrc_t_ppd[3]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input   [T_PPD_WIDTH-1:0]            reg_ddrc_t_ppd;                 // tPPD: PRE(A)-to-PRE(A) min delay
input   [RD2WR_WIDTH-1:0]            reg_ddrc_rd2wr_s;
input   [MRR2RD_WIDTH-1:0]           reg_ddrc_mrr2rd;
input   [MRR2WR_WIDTH-1:0]           reg_ddrc_mrr2wr;
input   [MRR2MRW_WIDTH-1:0]          reg_ddrc_mrr2mrw;
input                                reg_ddrc_lp_optimized_write;    // To save power consumption LPDDR4 write DQ is set to 8'hF8 if this is set to 1 (masked + DBI)
  //ccx_tgl : ; reg_ddrc_rd2mr[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [RD2MR_WIDTH-1:0]            reg_ddrc_rd2mr;
  //ccx_tgl : ; reg_ddrc_wr2mr[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored./reg_ddrc_wr2pre
input   [WR2MR_WIDTH-1:0]            reg_ddrc_wr2mr;
input                                reg_ddrc_wck_on;
input   [MAX_RD_SYNC_WIDTH-1:0]      reg_ddrc_max_rd_sync;
input   [MAX_WR_SYNC_WIDTH-1:0]      reg_ddrc_max_wr_sync;
input   [DFI_TWCK_DELAY_WIDTH-1:0]   reg_ddrc_dfi_twck_delay;
input   [DFI_TWCK_EN_RD_WIDTH-1:0]       reg_ddrc_dfi_twck_en_rd;
input   [DFI_TWCK_EN_WR_WIDTH-1:0]       reg_ddrc_dfi_twck_en_wr;
input   [DFI_TWCK_DIS_WIDTH-1:0]         reg_ddrc_dfi_twck_dis;
input   [DFI_TWCK_FAST_TOGGLE_WIDTH-1:0] reg_ddrc_dfi_twck_fast_toggle;
input   [DFI_TWCK_TOGGLE_WIDTH-1:0]      reg_ddrc_dfi_twck_toggle;
input   [DFI_TWCK_TOGGLE_CS_WIDTH-1:0]   reg_ddrc_dfi_twck_toggle_cs;
input   [DFI_TWCK_TOGGLE_POST_WIDTH-1:0] reg_ddrc_dfi_twck_toggle_post;

  //ccx_tgl : ; reg_ddrc_t_cke[5]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.   
input   [T_CKE_WIDTH-1:0] reg_ddrc_t_cke;                 // tCKE: min CKE transition times
  //ccx_tgl : ; reg_ddrc_t_faw[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.    
input   [T_FAW_WIDTH-1:0] reg_ddrc_t_faw;                 // tFAW: rolling window of 4 activates allowed
                                                                //       to a given rank
  //ccx_tgl : ; reg_ddrc_t_rfc_min[11:9]; ; This register bit width is wider than the maximum value which might be set in real. Therefore bit[11:9] can't be covered.    
input   [T_RFC_MIN_WIDTH-1:0]    reg_ddrc_t_rfc_min;             // tRC(min): min time between refreshes
  //ccx_tgl : ; reg_ddrc_t_rfc_min_ab[11:9]; ; 8bit toggle can be set with 12 or 16Gb density, all bank refresh and 4266Mbps config. And 0 to 1 toggling can be covered when frequency change happened with above config. 
input   [T_RFC_MIN_AB_WIDTH-1:0] reg_ddrc_t_rfc_min_ab;
//ccx_tgl : ; reg_ddrc_t_pbr2pbr[7]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [T_PBR2PBR_WIDTH-1:0] reg_ddrc_t_pbr2pbr;             // tpbR2pbR: min time between LPDDR4 per-bank refreshes different bank
input   [T_PBR2ACT_WIDTH-1:0] reg_ddrc_t_pbr2act;             // tpbR2act: min time between LPDDR5 per-bank refreshes to act different bank

input                           reg_ddrc_t_refi_x1_sel;      // specifies whether reg_ddrc_t_refi_x1_x32 reg is x1 or x32
  //ccx_tgl : ; reg_ddrc_t_refi_x1_x32[11:10]; ; This register bit width is wider than the maximum value which might be set in real.    
input   [T_REFI_X1_X32_WIDTH-1:0]    reg_ddrc_t_refi_x1_x32;      // tRFC(nom): nominal avg. required refresh period
  //ccx_tgl : ; reg_ddrc_t_mr[6]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.   
input   [T_MR_WIDTH-1:0]         reg_ddrc_t_mr;                  // tMRD: recorvery time for mode register update
input   [REFRESH_TO_X1_X32_WIDTH-1:0]                   reg_ddrc_refresh_to_x1_x32;     // idle period before doing speculative refresh
input                           reg_ddrc_en_2t_timing_mode;     // Enable 2T timing mode in the controller
input                           reg_ddrc_opt_wrcam_fill_level;
input [3:0]                     reg_ddrc_delay_switch_write;
input [WR_CAM_ADDR_WIDTH-1:0]   reg_ddrc_wr_pghit_num_thresh;
input [RD_CAM_ADDR_WIDTH-1:0]   reg_ddrc_rd_pghit_num_thresh;
input [WR_CAM_ADDR_WIDTH-1:0]   reg_ddrc_wrcam_highthresh;
input [WR_CAM_ADDR_WIDTH-1:0]   reg_ddrc_wrcam_lowthresh;
input [7:0]                     reg_ddrc_wr_page_exp_cycles;
input [7:0]                     reg_ddrc_rd_page_exp_cycles;
input [7:0]                     reg_ddrc_wr_act_idle_gap;
input [7:0]                     reg_ddrc_rd_act_idle_gap;
input                           reg_ddrc_dis_opt_ntt_by_act;
input                           reg_ddrc_dis_opt_ntt_by_pre;
input                           reg_ddrc_autopre_rmw;
input                           reg_ddrc_prefer_write;          // prefer writes (debug feature)
input   [6:0]                   reg_ddrc_rdwr_idle_gap;         // idle period before switching from reads to writes
input   [POWERDOWN_EN_WIDTH-1:0]     reg_ddrc_powerdown_en;          // enable powerdown during idle periods
input   [POWERDOWN_TO_X32_WIDTH-1:0] reg_ddrc_powerdown_to_x32;      // powerdown timeout: idle period before entering
                                                                //  powerdown (if reg_ddrc_powerdown_en=1)
                                                                //  (in pulses of 32-cycle timer)
  //ccx_tgl : ; reg_ddrc_t_xp[5]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [T_XP_WIDTH-1:0]        reg_ddrc_t_xp;                  // tXP: powerdown exit time

input [SELFREF_SW_WIDTH-1:0]    reg_ddrc_selfref_sw;
input                           reg_ddrc_hw_lp_en;
input                           reg_ddrc_hw_lp_exit_idle_en;
input   [SELFREF_TO_X32_WIDTH-1:0] reg_ddrc_selfref_to_x32;
input   [11:0]                  reg_ddrc_hw_lp_idle_x32;

input   [7:0]                   reg_ddrc_dfi_t_ctrlupd_interval_min_x1024;
input   [7:0]                   reg_ddrc_dfi_t_ctrlupd_interval_max_x1024;

input [SELFREF_EN_WIDTH-1:0]    reg_ddrc_selfref_en;            // self refresh enable

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in both SVA files and RTL
//spyglass enable_block W240
input   [NUM_RANKS-1:0]         reg_ddrc_mr_rank;               //   register i/p for software configuarble rank selection
  //ccx_tgl : ; reg_ddrc_t_xsr[11]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [T_XSR_WIDTH-1:0] reg_ddrc_t_xsr;                 // SRX to commands (unit of 1 cycle)
input                           reg_ddrc_refresh_update_level;  // toggle this signal if refresh value has to be updated
                                                                // used when freq is changed on the fly


input   [NUM_RANKS-1:0]         reg_ddrc_rank0_wr_odt;  // ODT settings for 4 ranks + controller when writing to rank 0
input   [NUM_RANKS-1:0]         reg_ddrc_rank0_rd_odt;  // ODT settings for 4 ranks + controller when reading from rank 0
input   [7:0]                   reg_ddrc_hpr_xact_run_length;
input   [15:0]                  reg_ddrc_hpr_max_starve;
input   [7:0]                   reg_ddrc_lpr_xact_run_length;
input   [15:0]                  reg_ddrc_lpr_max_starve;
input   [7:0]                   reg_ddrc_w_xact_run_length;
input   [15:0]                  reg_ddrc_w_max_starve;

input   [DFI_T_RDDATA_EN_WIDTH-1:0]                   reg_ddrc_dfi_t_rddata_en; // t_rddata_en parameter from dfi spec
input   [DFI_TPHY_WRDATA_WIDTH-1:0]                   reg_ddrc_dfi_tphy_wrdata; // tphy_wrdata parameter from dfi spec
input   [DFI_T_CTRLUP_MIN_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrlup_min; // min time for which the ctrlup request should stay high
input   [DFI_T_CTRLUP_MAX_WIDTH-1:0]                   reg_ddrc_dfi_t_ctrlup_max; // max time for which the ctrlup request can stay high

   //ccx_tgl : ; reg_ddrc_read_latency[6]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [READ_LATENCY_WIDTH-1:0] reg_ddrc_read_latency;  // read latency as seen by controller
   //ccx_tgl : ; reg_ddrc_write_latency[6]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input   [WRITE_LATENCY_WIDTH-1:0] reg_ddrc_write_latency;

input   [DFI_TPHY_WRLAT_WIDTH-1:0]                   reg_ddrc_dfi_tphy_wrlat;        // write latency (command to data latency)

                                                        // data is passed on the ECC bits

// for address mapper
input   [AM_BANK_WIDTH-1:0]     reg_ddrc_addrmap_bank_b0;
input   [AM_BANK_WIDTH-1:0]     reg_ddrc_addrmap_bank_b1;
input   [AM_BANK_WIDTH-1:0]     reg_ddrc_addrmap_bank_b2;
input   [AM_BG_WIDTH-1:0]       reg_ddrc_addrmap_bg_b0;
input   [AM_BG_WIDTH-1:0]       reg_ddrc_addrmap_bg_b1;
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b3;
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b4;
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b5;
input   [AM_COL_WIDTH_L-1:0]    reg_ddrc_addrmap_col_b6;
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b7;
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b8;
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b9;
input   [AM_COL_WIDTH_H-1:0]    reg_ddrc_addrmap_col_b10;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b0;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b1;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b2;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b3;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b4;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b5;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b6;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b7;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b8;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b9;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b10;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b11;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b12;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b13;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b14;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b15;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b16;
input   [AM_ROW_WIDTH-1:0]      reg_ddrc_addrmap_row_b17;


// outputs to status & interrupt registers
// outputs to debug registers
output  [RD_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_hpr_q_depth;
output  [RD_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_lpr_q_depth;
output  [WR_CAM_ADDR_WIDTH:0]   ddrc_reg_dbg_w_q_depth;
output                          ddrc_reg_dbg_stall;             // stall
output                          ddrc_reg_selfref_cam_not_empty;
output [2:0]                    ddrc_reg_selfref_state;
input                           reg_ddrc_mrr_done_clr;
output                          ddrc_reg_mrr_done;
output [31:0]                   ddrc_reg_mrr_data_lwr;
output [31:0]                   ddrc_reg_mrr_data_upr;
    output  [2:0]               ddrc_reg_operating_mode;        // global schedule FSM state

output [SELFREF_TYPE_WIDTH - 1:0]     ddrc_reg_selfref_type;
output                          ddrc_reg_wr_q_empty;
output                          ddrc_reg_rd_q_empty;
output                          ddrc_reg_wr_data_pipeline_empty;
output                          ddrc_reg_rd_data_pipeline_empty;

input                           reg_ddrc_dis_auto_zq;           // when 1: disable auto zqcs
input                           reg_ddrc_dis_srx_zqcl;          // when 1: disable zqcl after self-refresh exit
input                           reg_ddrc_zq_resistor_shared;
  //ccx_tgl : ; reg_ddrc_t_zq_long_nop[13]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input [T_ZQ_LONG_NOP_WIDTH-1:0]                    reg_ddrc_t_zq_long_nop;         // time to wait in ZQCL during init sequence
  //ccx_tgl : ; reg_ddrc_t_zq_short_nop[9]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input [T_ZQ_SHORT_NOP_WIDTH-1:0]                     reg_ddrc_t_zq_short_nop;        // time to wait in ZQCS during init sequence
  //ccx_tgl : ; reg_ddrc_t_zq_short_interval_x1024[19]; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored.  
input [T_ZQ_SHORT_INTERVAL_X1024_WIDTH-1:0]                    reg_ddrc_t_zq_short_interval_x1024;  // interval between auto ZQCS commands
input                           reg_ddrc_zq_calib_short;            // zq calib short command
output                          ddrc_reg_zq_calib_short_busy;       // If 1: Previous zq calib short has not been initiated


input [DRAM_RSTN_X1024_WIDTH-1:0]  reg_ddrc_dram_rstn_x1024;       // time for dram reset to stay low

input                   reg_ddrc_per_bank_refresh;      // REF Per bank//Added by Naveen B
input [1:0]             reg_ddrc_auto_refab_en;
input [REFRESH_TO_AB_X32_WIDTH-1:0] reg_ddrc_refresh_to_ab_x32;
output [BANK_BITS*NUM_RANKS-1:0]  hif_refresh_req_bank;
input                   reg_ddrc_lpddr4;
input                   reg_ddrc_lpddr5;
input [BANK_ORG_WIDTH-1:0]             reg_ddrc_bank_org;
input [LPDDR4_DIFF_BANK_RWA2PRE_WIDTH-1:0]  reg_ddrc_lpddr4_diff_bank_rwa2pre;
input                   reg_ddrc_stay_in_selfref;
//ccx_tgl : ; reg_ddrc_t_cmdcke[3] ; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input [T_CMDCKE_WIDTH-1:0] reg_ddrc_t_cmdcke;
input                         reg_ddrc_dsm_en;
input  [T_PDN_WIDTH-1:0]      reg_ddrc_t_pdn;
input  [T_XSR_DSM_X1024_WIDTH-1:0]  reg_ddrc_t_xsr_dsm_x1024;
input  [T_CSH_WIDTH-1:0]      reg_ddrc_t_csh;

input [2:0]             reg_ddrc_nonbinary_device_density;

input                   reg_ddrc_dfi_phyupd_en;         // Enable for DFI PHY update logic

input                   reg_ddrc_dfi_phymstr_en;        // Enable for PHY Master Interface
input  [7:0]            reg_ddrc_dfi_phymstr_blk_ref_x32;// Number of 32 DFI cycles that is delayed to block refresh when there is PHY Master
input                   reg_ddrc_dis_cam_drain_selfref; // Disable CAM draining before entering selfref
input                   reg_ddrc_lpddr4_sr_allowed;     // Allow transition from SR-PD to SR and back to SR-PD when PHY Master request
input                   reg_ddrc_lpddr4_opt_act_timing;
input                   reg_ddrc_lpddr5_opt_act_timing;
input  [DFI_T_CTRL_DELAY_WIDTH-1:0]            reg_ddrc_dfi_t_ctrl_delay;  // timer value for DFI tctrl_delay
input  [DFI_T_WRDATA_DELAY_WIDTH-1:0]            reg_ddrc_dfi_t_wrdata_delay;// timer value for DFI twrdata_delay

input  [DFI_T_DRAM_CLK_DISABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_disable;
input  [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_enable;
input  [T_CKSRE_WIDTH-1:0] reg_ddrc_t_cksre;
input  [T_CKSRX_WIDTH-1:0] reg_ddrc_t_cksrx;
input  [T_CKCSX_WIDTH-1:0] reg_ddrc_t_ckcsx;
  //ccx_tgl : ; reg_ddrc_t_ckesr; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input  [T_CKESR_WIDTH-1:0] reg_ddrc_t_ckesr;

input                   reg_ddrc_oc_parity_en; // enables on-chip parity
input                   reg_ddrc_oc_parity_type; // selects parity type. 0 even, 1 odd

input                            reg_ddrc_par_poison_en; // enable ocpar poison
input                            reg_ddrc_par_poison_loc_rd_iecc_type; // select parity to poison with inline ECC: data or ecc

output                           par_rdata_in_err_ecc_pulse;
output                           par_wdata_out_err_pulse;
output                           par_wdata_out_err_ie_pulse;

input                            reg_ddrc_par_rdata_err_intr_clr;

input                             ocecc_en;
input                             ocecc_poison_egen_xpi_rd_0;
input                             ocecc_poison_egen_mr_rd_1;
input  [OCECC_MR_BNUM_WIDTH-1:0]  ocecc_poison_egen_mr_rd_1_byte_num;
input                             ocecc_poison_single;
input                             ocecc_poison_pgen_rd;
input                             ocecc_poison_pgen_mr_ecc;
input                             ocecc_uncorr_err_intr_clr;

output                            ocecc_mr_rd_corr_err;
output                            ocecc_mr_rd_uncorr_err;
output [CORE_DATA_WIDTH/OCECC_MR_RD_GRANU-1:0] ocecc_mr_rd_byte_num;

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
input                   reg_ddrc_sw_done;
//spyglass enable_block W240
input                   reg_ddrc_occap_en;
output                  ddrc_occap_wufifo_parity_err;
output                  ddrc_occap_wuctrl_parity_err;
output                  ddrc_occap_rtfifo_parity_err;
output                  ddrc_occap_rtctrl_parity_err;
output                  ddrc_occap_dfidata_parity_err;
output                  ddrc_occap_eccaccarray_parity_err;

input                   reg_ddrc_occap_ddrc_ctrl_poison_seq;
input                   reg_ddrc_occap_ddrc_ctrl_poison_parallel;
input                   reg_ddrc_occap_ddrc_ctrl_poison_err_inj;
output                  occap_ddrc_ctrl_err;
output                  occap_ddrc_ctrl_poison_complete;
output                  occap_ddrc_ctrl_poison_seq_err;
output                  occap_ddrc_ctrl_poison_parallel_err;
input                   reg_ddrc_occap_ddrc_data_poison_seq;
input                   reg_ddrc_occap_ddrc_data_poison_parallel;
input                   reg_ddrc_occap_ddrc_data_poison_err_inj;
output                  occap_ddrc_data_err;
output                  occap_ddrc_data_poison_complete;
output                  occap_ddrc_data_poison_seq_err;
output                  occap_ddrc_data_poison_parallel_err;

input                                  reg_ddrc_dfi_lp_data_req_en;
input                                  reg_ddrc_dfi_lp_en_pd;
input  [DFI_LP_WAKEUP_PD_WIDTH-1:0]    reg_ddrc_dfi_lp_wakeup_pd;
input                                  reg_ddrc_dfi_lp_en_sr;
input  [DFI_LP_WAKEUP_SR_WIDTH-1:0]    reg_ddrc_dfi_lp_wakeup_sr;
input                                  reg_ddrc_dfi_lp_en_data;
input  [DFI_LP_WAKEUP_DATA_WIDTH-1:0]  reg_ddrc_dfi_lp_wakeup_data;
input                                  reg_ddrc_dfi_lp_en_dsm;
input  [DFI_LP_WAKEUP_DSM_WIDTH-1:0]   reg_ddrc_dfi_lp_wakeup_dsm;
input  [1:0]            reg_ddrc_skip_dram_init;
input  [DFI_TLP_RESP_WIDTH-1:0]            reg_ddrc_dfi_tlp_resp;



input                      reg_ddrc_dis_dqsosc_srx;
input                      reg_ddrc_dqsosc_enable;                 // DQSOSC enable
  //ccx_tgl : ; reg_ddrc_t_osco[8] ; ; This register value is devided by frequency ratio. Thus this MSB can't be toggled. Can be ignored. 
input  [T_OSCO_WIDTH-1:0]  reg_ddrc_t_osco;                        // t_osco timing
input  [7:0]               reg_ddrc_dqsosc_runtime;                // Oscillator runtime
input  [7:0]               reg_ddrc_wck2dqo_runtime;               // Oscillator runtime only for LPDDR5
input  [11:0]              reg_ddrc_dqsosc_interval;               // DQSOSC inverval
input                      reg_ddrc_dqsosc_interval_unit;          // DQSOSC interval unit
output [2:0]               dqsosc_state;
output [NUM_RANKS-1:0]     dqsosc_per_rank_stat;
output [`MEMC_DFI_TOTAL_DATAEN_WIDTH*4-1:0] dwc_ddrphy_snoop_en;

input  [DFI_T_CTRLMSG_RESP_WIDTH-1:0]    reg_ddrc_dfi_t_ctrlmsg_resp;
input                                    reg_ddrc_dfi0_ctrlmsg_req;
input                                    reg_ddrc_dfi0_ctrlmsg_tout_clr;
input  [DFI_CTRLMSG_DATA_WIDTH-1:0]      reg_ddrc_dfi0_ctrlmsg_data;
input  [DFI_CTRLMSG_CMD_WIDTH-1:0]       reg_ddrc_dfi0_ctrlmsg_cmd;
output                                   ddrc_reg_dfi0_ctrlmsg_req_busy;
output                                   ddrc_reg_dfi0_ctrlmsg_resp_tout;

//registers for DDR5






localparam NO_OF_BT          = `MEMC_NO_OF_BLK_TOKEN;
localparam NO_OF_BWT         = `MEMC_NO_OF_BWT;
localparam NO_OF_BRT         = `MEMC_NO_OF_BRT;
localparam BT_BITS           = $clog2(NO_OF_BT);
localparam BWT_BITS          = $clog2(NO_OF_BWT);
localparam BRT_BITS          = $clog2(NO_OF_BRT);
localparam NO_OF_BLK_CHN     = `MEMC_NO_OF_BLK_CHANNEL;
localparam BLK_CHN_BITS      = `log2(NO_OF_BLK_CHN);
localparam IE_RD_TYPE_BITS   = `IE_RD_TYPE_BITS;
localparam IE_WR_TYPE_BITS   = `IE_WR_TYPE_BITS;
localparam IE_BURST_NUM_BITS = `MEMC_BURST_LENGTH==16 ? 5 : 3;

`ifndef CHB_PVE_MODE
//------------------------------------------------------------------------------
// Interface
//------------------------------------------------------------------------------
dwc_ddrctl_ddrc_cpfdp_if #(
    .NO_OF_BT                                             (NO_OF_BT                           )
   ,.BT_BITS                                              (BT_BITS                            )
   ,.PARTIAL_WR_BITS                                      (PARTIAL_WR_BITS                    )
   ,.PARTIAL_WR_BITS_LOG2                                 (PARTIAL_WR_BITS_LOG2               )
   ,.PW_NUM_DB                                            (PW_NUM_DB                          )
   ,.PW_FACTOR_QBW                                        (PW_FACTOR_QBW                      )
   ,.PW_FACTOR_HBW                                        (PW_FACTOR_HBW                      )
   ,.PW_WORD_VALID_WD_QBW                                 (PW_WORD_VALID_WD_QBW               )
   ,.PW_WORD_VALID_WD_HBW                                 (PW_WORD_VALID_WD_HBW               )
   ,.PW_WORD_VALID_WD_MAX                                 (PW_WORD_VALID_WD_MAX               )
   ,.PW_WORD_CNT_WD_MAX                                   (PW_WORD_CNT_WD_MAX                 )
   ,.RMW_TYPE_BITS                                        (RMW_TYPE_BITS                      )
   ,.WORD_BITS                                            (WORD_BITS                          )
   ,.WR_CAM_ADDR_WIDTH                                    (WR_CAM_ADDR_WIDTH                  )
   ,.WR_CAM_ADDR_WIDTH_IE                                 (WR_CAM_ADDR_WIDTH_IE               )
   ) cpfdpif();

dwc_ddrctl_ddrc_cpedp_if #(
    .CMD_LEN_BITS                                         (CMD_LEN_BITS                       )
   ,.WR_CAM_ADDR_WIDTH                                    (WR_CAM_ADDR_WIDTH                  )
   ,.RMW_TYPE_BITS                                        (RMW_TYPE_BITS                      )
   ,.CMD_RMW_BITS                                         (CMD_RMW_BITS                       )
   ,.CORE_TAG_WIDTH                                       (CORE_TAG_WIDTH                     )
   ,.PARTIAL_WR_BITS                                      (PARTIAL_WR_BITS                    )
   ,.PARTIAL_WR_BITS_LOG2                                 (PARTIAL_WR_BITS_LOG2               )
   ,.PW_NUM_DB                                            (PW_NUM_DB                          )   
   ,.PW_FACTOR_HBW                                        (PW_FACTOR_HBW                      )
   ,.PW_WORD_VALID_WD_HBW                                 (PW_WORD_VALID_WD_HBW               )
   ,.PW_WORD_VALID_WD_MAX                                 (PW_WORD_VALID_WD_MAX               )
   ,.PW_WORD_CNT_WD_MAX                                   (PW_WORD_CNT_WD_MAX                 )

   ,.LRANK_BITS                                           (LRANK_BITS                         )
   ,.BG_BITS                                              (BG_BITS                            )
   ,.BANK_BITS                                            (BANK_BITS                          )
   ,.RANKBANK_BITS_FULL                                   (RANKBANK_BITS_FULL                 )
   ,.PAGE_BITS                                            (PAGE_BITS                          )
   ,.BLK_BITS                                             (BLK_BITS                           )
   ,.WORD_BITS                                            (WORD_BITS                          )
   ) ddrc_cpedpif();


// ocpar
wire                          wdata_ocpar_error;
wire                          wdata_ocpar_error_ie;
wire                          write_data_parity_en;
// ----

wire                          ddrc_reg_wr_q_empty;
wire                          ddrc_reg_rd_q_empty;


wire                            hif_wdata_stall;

wire                                 ih_te_rd_valid;
wire                                 ih_te_wr_valid;

// if sdram mode, then burst8_rdwr is set even though BL=4
// for ddr, it gets the real value from the register
wire [4:0]      reg_ddrc_burst_rdwr_int;
assign  reg_ddrc_burst_rdwr_int = (reg_ddrc_frequency_ratio) ? reg_ddrc_burst_rdwr : reg_ddrc_burst_rdwr >> 1;


`endif // ifndef CHB_PVE_MODE

   output  wire [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]    hif_mrr_data;
   output  wire          hif_mrr_data_valid;

`ifndef CHB_PVE_MODE

   wire                  rd_mr4_data_valid;
   wire                  rt_rd_rd_mrr_ext;





//--------------------------------------------------------------
//---------------- ME -> MR Interface --------------------------
//--------------------------------------------------------------
wire    [CORE_DATA_WIDTH-1:0]                me_mr_rdata;

wire    [WDATA_PAR_WIDTH_EXT-1:0]            me_mr_rdata_par;


//--------------------------------------------------------------
//---------------- MR -> WU Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- MR -> ME Interface --------------------------
//--------------------------------------------------------------
wire    [WRDATA_RAM_ADDR_WIDTH-1:0]     mr_me_raddr;            // RAM read address for data & byte enables
wire                                    mr_me_re;               // RAM read enable
wire    [WRDATA_RAM_ADDR_WIDTH-ADJ_WRDATA_RAM_ADDR_WIDTH-1:0] wdataram_raddr;
wire                                    wdataram_re;


//--------------------------------------------------------------
//---------------- MR -> IH/WU Interface --------------------------
//--------------------------------------------------------------
wire                                    mr_wu_free_wr_entry_valid;
assign mr_wu_free_wr_entry_valid = cpfdpif.mr_yy_free_wr_entry_valid
;

//--------------------------------------------------------------
//---------------- MR -> TS Interface --------------------------
//--------------------------------------------------------------
wire                                    dfi_wr_q_empty;

//--------------------------------------------------------------
//---------------- PI -> TS Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- PI -> RT Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- RT -> RD Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- RD -> WU Interface --------------------------
//--------------------------------------------------------------
wire                                    rd_wu_rdata_valid;              // read data valid for write update engine

//--------------------------------------------------------------
//---------------- RD -> RW Interface --------------------------
//--------------------------------------------------------------
wire    [CMD_RMW_BITS-1:0]              rd_rw_rmwcmd_unused;            // read-mod-write command
wire    [CORE_DATA_WIDTH-1:0]           rd_rw_rdata;                    // read data, after ECC decoding

//--------------------------------------------------------------
//---------------- RT -> TS Interface --------------------------
//--------------------------------------------------------------
wire                                    rt_gs_empty;            // RT has no read in its FIFO
wire                                    rt_gs_empty_delayed;    // RT has no read in its FIFO - delayed version for clock gating logic


//--------------------------------------------------------------
//---------------- RW -> WU Interface --------------------------
//--------------------------------------------------------------
wire    [CORE_DATA_WIDTH-1:0]           rw_wu_rdata;            // read data, after ECC decoding


//--------------------------------------------------------------
//---------------- TE -> IH/WU Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- TE -> PI Interface --------------------------
//--------------------------------------------------------------

wire                                    ts_pi_mwr;                      // masked write information


//--------------------------------------------------------------
//---------------- TE -> MR Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- TE -> WU Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- TS -> MR Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- WU -> ME Interface --------------------------
//--------------------------------------------------------------
wire                                            wu_me_wvalid;
wire    [WRDATA_RAM_ADDR_WIDTH-1:0]             wu_me_waddr;
wire    [CORE_DATA_WIDTH-1:0]                   wu_me_wdata;            // data to write to RAM

wire    [WDATA_PAR_WIDTH_EXT-1:0]               wu_me_wdata_par;


wire    [CORE_MASK_WIDTH-1:0]                   wu_me_wmask;            // mask of which mask (and data) bits to write

wire                                            wdataram_wr;
wire    [WRDATA_RAM_ADDR_WIDTH-ADJ_WRDATA_RAM_ADDR_WIDTH-1:0] wdataram_waddr;

wire    [UMCTL2_WDATARAM_DW-1:0]                wdataram_din;

wire    [WDATA_PAR_WIDTH_EXT-1:0]                   wdataram_din_par;


//--------------------------------------------------------------
//---------------- WU -> MR Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- WU -> IH Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- WU -> TE Interface --------------------------
//--------------------------------------------------------------


//--------------------------------------------------------------
//---------------- WU -> TS Interface --------------------------
//--------------------------------------------------------------



//--------------------------------------------------------------
//------------- DDRC_CTRL -> ddrc_assertions -------------------
//--------------------------------------------------------------



wire                         gs_pi_op_is_exit_selfref;


//------------------------------------------------------------------------------
// RAM Instantiations
//------------------------------------------------------------------------------

      assign   wdataram_wr                              = wu_me_wvalid;
      assign   wdataram_raddr                           = mr_me_raddr[0 +: WRDATA_RAM_ADDR_WIDTH-ADJ_WRDATA_RAM_ADDR_WIDTH];
      assign   wdataram_re                              = mr_me_re;
      assign   wdataram_waddr                           = wu_me_waddr[0 +: WRDATA_RAM_ADDR_WIDTH-ADJ_WRDATA_RAM_ADDR_WIDTH];


      assign   wdataram_din                             = wu_me_wdata;
      assign   me_mr_rdata                              = wdataram_dout;
      assign   wdataram_mask                            = wu_me_wmask;

      assign wdataram_din_par                           = wu_me_wdata_par;
      assign me_mr_rdata_par                            = wdataram_dout_par;

`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON


`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

// wiring of dfi_rddata
wire  [PHY_DATA_WIDTH/16-1:0] dfi_rddata_valid_int;
wire  [PHY_DATA_WIDTH-1:0]    dfi_rddata_int;
wire  [PHY_DBI_WIDTH-1:0]     dfi_rddata_dbi_int;


wire [2:0]   ddrc_reg_operating_mode_w;
assign ddrc_reg_operating_mode   = ddrc_reg_operating_mode_w;


//-----------------------------
// mrr_data register bit assignment
//-----------------------------
wire  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]   ddrc_reg_mrr_data;

assign {ddrc_reg_mrr_data_upr, ddrc_reg_mrr_data_lwr} = {{(64 - `MEMC_DRAM_TOTAL_DATA_WIDTH){1'b0}}, ddrc_reg_mrr_data};




wire   gs_pi_data_pipeline_empty;

wire   mrr_op_on;
wire   ih_busy;
wire   ih_ie_busy;
wire   ddrc_cg_en;
wire   ddrc_cg_en_wo_ie;



wire   wu_fifo_empty;


wire    [WRITE_LATENCY_WIDTH-1:0]   rl_plus_cmd_len;        // read latency + command length - 1
assign  rl_plus_cmd_len =
                        reg_ddrc_lpddr4 ? reg_ddrc_write_latency + {{($bits(reg_ddrc_write_latency)-2){1'b0}},2'b11} :
                                          reg_ddrc_write_latency;

//
//--------------------------------------
// Enable for clock gating when idle
//--------------------------------------
// Note, not all registers use this clock gating enable
// Based on configuration parameter, UMCTL2_CG_EN:
// either use internally generated signal or else set ddrc_cg_en=1 always
// ddrc_cg_en should be LOW when there are no rd/wr transactions pending
// the LOW will cause the clock to be gated when there are no rd/wr transactions pending
//
//----------------------------------
// Clock gate turn-ON conditions:
//----------------------------------
//    - gs_pi_datapipeline_empty  is high - All the data pipelines are empty AND
//    - rt_gs_empty_delayed is high       - 8 clocks have passed after RT FIFO is empty (allowing ECC scrub generation if needed)
//    - ih_busy is low                    - CAM control fifo's empty, nothing in input FIFO's and no incoming command, no pending scrub requests
//    - mrr_op_on is low                  - No MRR operations in process
//    - wu_fifo_empty is high             - No write data are expected in HIF (co_wu_rxdata)
//----------------------------------
// Clock gate turn-OFF conditions:
//----------------------------------
//    - ih_busy is high                   - New command at HIF
//    - mrr_op_on is high                 - New MRR request (either external MRR or internal derating request)
//
//------------------------------
// Modules where clock gating is implemented: IH, TE (except NTT), WU, RT, RD, MR, DFI (wr_data pipeline flops)
// Rest of the modules (BE, PI, DFI, TS, DTI, DR are not eligible candidates as they deal with maintenance commands - PRE, REF, ZQ etc)
// There are some flops in IH, RT and RD modules that have been excluded from clock gating due to special conditions
// In IH due to the HIF interface control logic
// In RT due to the fifo_reset_timer logic and
// In RD due to the ECC error clearing logic
//-------------------------------

assign ddrc_cg_en_wo_ie = ((~gs_pi_data_pipeline_empty) || (~rt_gs_empty_delayed)
                                          || ih_busy
                                          || mrr_op_on
                                          || ~wu_fifo_empty
                                        );


assign ddrc_cg_en = ddrc_cg_en_wo_ie;



//------------------------------------------------------------------------------
// Logic that determines how much delay to be introduced on the DFI command path
//------------------------------------------------------------------------------

parameter WDATARAM_RD_LATENCY    = `DDRCTL_WDATARAM_RD_LATENCY;
parameter CMD_DELAY_BITS         = `UMCTL2_CMD_DELAY_BITS;
parameter MAX_CMD_DELAY          = `UMCTL2_MAX_CMD_DELAY;

wire     [CMD_DELAY_BITS-1:0]    dfi_cmd_delay;
wire [DFI_TPHY_WRLAT_WIDTH-1:0]  mr_t_wrlat;
wire [5:0]                       mr_t_wrdata;
wire [6:0]                       mr_t_rddata_en;
wire [1:0]                       mr_t_wrdata_add_sdr;
wire [DFI_TWCK_EN_RD_WIDTH-2:0]  mr_lp_data_rd;
wire [DFI_TWCK_EN_WR_WIDTH-2:0]  mr_lp_data_wr;

wire ddrc_cmp_en;

wire i_occap_ddrc_ctrl_poison_complete;
wire i_occap_ddrc_ctrl_poison_parallel_err;
wire i_occap_ddrc_ctrl_poison_seq_err;

wire occap_ddrc_ctrl_poison_complete_int;
wire occap_ddrc_ctrl_poison_parallel_err_int;
wire occap_ddrc_ctrl_poison_seq_err_int;

wire occap_ddrc_data_err_mr;
wire occap_ddrc_data_poison_parallel_err_mr;
wire occap_ddrc_data_poison_seq_err_mr;
wire occap_ddrc_data_poison_complete_mr;
wire occap_ddrc_data_err_rd;
wire occap_ddrc_data_poison_parallel_err_rd;
wire occap_ddrc_data_poison_seq_err_rd;
wire occap_ddrc_data_poison_complete_rd;

wire i_occap_ddrc_data_poison_complete;
wire i_occap_ddrc_data_poison_parallel_err;
wire i_occap_ddrc_data_poison_seq_err;

reg reg_ddrc_occap_en_r;
  always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
      if(~core_ddrc_rstn) begin
        reg_ddrc_occap_en_r <= 1'b0;
      end else begin
        reg_ddrc_occap_en_r <= reg_ddrc_occap_en;
      end
  end


generate
if (OCCAP_EN==1) begin: OCCAP_en

  genvar n;

  wire sw_done_core_clk;


  if (CP_ASYNC==1) begin: ddrc_cmp_cp_async


    DWC_ddr_umctl2_bitsync
    
          #( .BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_P2C),
             .BCM_VERIF_EN    (BCM_VERIF_EN))
          U_bitsync_sw_done_p2c
          (  .clk_d          (core_ddrc_core_clk),
             .rst_d_n        (core_ddrc_rstn),
             .data_s         (reg_ddrc_sw_done),
             .data_d         (sw_done_core_clk));
  end
  else begin: ddrc_ctrl_wrapper_cp_sync
    assign sw_done_core_clk = reg_ddrc_sw_done;
  end

  assign ddrc_cmp_en = reg_ddrc_occap_en & sw_done_core_clk;


  //
  // ddrc_ctrl
  //

  // logic to hold complete/err for ddrc_ctrl and send it as a pulse at end
  wire occap_ddrc_ctrl_poison;
  reg  occap_ddrc_ctrl_poison_r;
  wire occap_ddrc_ctrl_pulse;


  wire [DDRC_CTRL_CMP-1:0] occap_ddrc_ctrl_poison_complete_w, occap_ddrc_ctrl_poison_parallel_err_w, occap_ddrc_ctrl_poison_seq_err_w;
  reg  [DDRC_CTRL_CMP-1:0] occap_ddrc_ctrl_poison_complete_r, occap_ddrc_ctrl_poison_parallel_err_r, occap_ddrc_ctrl_poison_seq_err_r;

  assign occap_ddrc_ctrl_poison_complete_w     = {occap_ddrc_ctrl_poison_complete_int};
  assign occap_ddrc_ctrl_poison_parallel_err_w = {occap_ddrc_ctrl_poison_parallel_err_int};
  assign occap_ddrc_ctrl_poison_seq_err_w      = {occap_ddrc_ctrl_poison_seq_err_int};

  for (n=0; n<DDRC_CTRL_CMP; n=n+1) begin : ddrc_ctrl_poison_r
    always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
      if(~core_ddrc_rstn) begin
        occap_ddrc_ctrl_poison_complete_r[n]     <= 1'b0;
        occap_ddrc_ctrl_poison_parallel_err_r[n] <= 1'b0;
        occap_ddrc_ctrl_poison_seq_err_r[n]      <= 1'b0;
      end else begin
        if (occap_ddrc_ctrl_pulse) begin
          occap_ddrc_ctrl_poison_complete_r[n]     <= 1'b0; // clear all bits when all of them are 1 -> all FSM finished the poison loop
          occap_ddrc_ctrl_poison_parallel_err_r[n] <= 1'b0;
          occap_ddrc_ctrl_poison_seq_err_r[n]      <= 1'b0;

        end else if (occap_ddrc_ctrl_poison_complete_w[n]) begin
          occap_ddrc_ctrl_poison_complete_r[n]     <= 1'b1; // hold the bit when pulse is received
          occap_ddrc_ctrl_poison_parallel_err_r[n] <= occap_ddrc_ctrl_poison_parallel_err_w[n];
          occap_ddrc_ctrl_poison_seq_err_r[n]      <= occap_ddrc_ctrl_poison_seq_err_w[n];
        end
      end
    end
  end // for

  assign occap_ddrc_ctrl_poison = occap_ddrc_ctrl_poison_complete_r; // all core clock comparators finished

  always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
      occap_ddrc_ctrl_poison_r <= 1'b0;
    end else begin
       occap_ddrc_ctrl_poison_r <= occap_ddrc_ctrl_poison;
    end
  end

  assign occap_ddrc_ctrl_pulse = occap_ddrc_ctrl_poison & ~occap_ddrc_ctrl_poison_r; // generate core clock pulse

  assign i_occap_ddrc_ctrl_poison_complete     = occap_ddrc_ctrl_pulse;
  assign i_occap_ddrc_ctrl_poison_parallel_err = occap_ddrc_ctrl_poison_parallel_err_r;
  assign i_occap_ddrc_ctrl_poison_seq_err      = occap_ddrc_ctrl_poison_seq_err_r;



  //
  // ddrc_data
  //

  // logic to hold complete for both _rd/_mr and send it as a pulse at end
  wire occap_ddrc_data_poison;
  reg  occap_ddrc_data_poison_r;
  wire occap_ddrc_data_pulse;


  wire [DDRC_DATA_CMP-1:0] occap_ddrc_data_poison_complete_w, occap_ddrc_data_poison_parallel_err_w, occap_ddrc_data_poison_seq_err_w;
  reg  [DDRC_DATA_CMP-1:0] occap_ddrc_data_poison_complete_r, occap_ddrc_data_poison_parallel_err_r, occap_ddrc_data_poison_seq_err_r;

  assign occap_ddrc_data_poison_complete_w     = {occap_ddrc_data_poison_complete_rd,     occap_ddrc_data_poison_complete_mr};
  assign occap_ddrc_data_poison_parallel_err_w = {occap_ddrc_data_poison_parallel_err_rd, occap_ddrc_data_poison_parallel_err_mr};
  assign occap_ddrc_data_poison_seq_err_w      = {occap_ddrc_data_poison_seq_err_rd,      occap_ddrc_data_poison_seq_err_mr};

  for (n=0; n<DDRC_DATA_CMP; n=n+1) begin : ddrc_data_poison_r
    always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
      if(~core_ddrc_rstn) begin
        occap_ddrc_data_poison_complete_r[n]     <= 1'b0;
        occap_ddrc_data_poison_parallel_err_r[n] <= 1'b0;
        occap_ddrc_data_poison_seq_err_r[n]      <= 1'b0;
      end else begin
        if (occap_ddrc_data_pulse) begin
          occap_ddrc_data_poison_complete_r[n]     <= 1'b0; // clear all bits when all of them are 1 -> all FSM finished the poison loop
          occap_ddrc_data_poison_parallel_err_r[n] <= 1'b0;
          occap_ddrc_data_poison_seq_err_r[n]      <= 1'b0;

        end else if (occap_ddrc_data_poison_complete_w[n]) begin
          occap_ddrc_data_poison_complete_r[n]     <= 1'b1; // hold the bit when pulse is received
          occap_ddrc_data_poison_parallel_err_r[n] <= occap_ddrc_data_poison_parallel_err_w[n];
          occap_ddrc_data_poison_seq_err_r[n]      <= occap_ddrc_data_poison_seq_err_w[n];
        end
      end
    end
  end // for

  assign occap_ddrc_data_poison = &occap_ddrc_data_poison_complete_r; // all core clock comparators finished

  always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
      occap_ddrc_data_poison_r <= 1'b0;
    end else begin
       occap_ddrc_data_poison_r <= occap_ddrc_data_poison;
    end
  end

  assign occap_ddrc_data_pulse = occap_ddrc_data_poison & ~occap_ddrc_data_poison_r; // generate core clock pulse

  assign i_occap_ddrc_data_poison_complete     = occap_ddrc_data_pulse;
  assign i_occap_ddrc_data_poison_parallel_err = |occap_ddrc_data_poison_parallel_err_r;
  assign i_occap_ddrc_data_poison_seq_err      = |occap_ddrc_data_poison_seq_err_r;

end
else begin: OCCAP_dis
  // occap feature dsiabled
  assign ddrc_cmp_en = 1'b0;

  assign i_occap_ddrc_ctrl_poison_complete     = 1'b0;
  assign i_occap_ddrc_ctrl_poison_parallel_err = 1'b0;
  assign i_occap_ddrc_ctrl_poison_seq_err      = 1'b0;


  assign i_occap_ddrc_data_poison_complete     = 1'b0;
  assign i_occap_ddrc_data_poison_parallel_err = 1'b0;
  assign i_occap_ddrc_data_poison_seq_err      = 1'b0;
end
endgenerate

assign occap_ddrc_ctrl_poison_complete     = i_occap_ddrc_ctrl_poison_complete;
assign occap_ddrc_ctrl_poison_parallel_err = i_occap_ddrc_ctrl_poison_parallel_err;
assign occap_ddrc_ctrl_poison_seq_err      = i_occap_ddrc_ctrl_poison_seq_err;

assign occap_ddrc_data_poison_complete     = i_occap_ddrc_data_poison_complete;
assign occap_ddrc_data_poison_parallel_err = i_occap_ddrc_data_poison_parallel_err;
assign occap_ddrc_data_poison_seq_err      = i_occap_ddrc_data_poison_seq_err;


//-------------------
//Manual write read data to DP interface
//-------------------
wire                                    hif_rdata_valid_no_masked;
wire                                    hif_rdata_valid = hif_rdata_valid_no_masked;
wire [CORE_DATA_WIDTH-1:0]              hif_rdata; //MEMC_DFI_DATA_WIDTH


//-------------------
//Manual write read data to reg interface
//-------------------
//`ifdef MEMC_DDR5
//wire [31:0]                             ddrc_reg_sw_rd_data; //reg interface
//`endif //MEMC_DDR5

//------------------------------------------------------------------------------
// ddrc_ctrl_wrapper
//------------------------------------------------------------------------------
    dwc_ddrctl_ddrc_cp_top
    
        #(

          .CHANNEL_NUM                    (CHANNEL_NUM),
          .SHARED_AC                      (SHARED_AC),
          .SHARED_AC_INTERLEAVE           (SHARED_AC_INTERLEAVE),
          .BCM_VERIF_EN                   (BCM_VERIF_EN),
          .BCM_DDRC_N_SYNC                (BCM_DDRC_N_SYNC),
          .BCM_F_SYNC_TYPE_P2C            (BCM_F_SYNC_TYPE_P2C),
          .MEMC_ECC_SUPPORT               (MEMC_ECC_SUPPORT),
          .UMCTL2_SEQ_BURST_MODE          (UMCTL2_SEQ_BURST_MODE),
          .UMCTL2_PHY_SPECIAL_IDLE        (UMCTL2_PHY_SPECIAL_IDLE),
          .OCPAR_EN                       (OCPAR_EN),
          .OCCAP_EN                       (OCCAP_EN),
          .CP_ASYNC                       (CP_ASYNC),
          .CMP_REG                        (OCCAP_PIPELINE_EN), // pipelining on comparaotr inputs for OCCAP
          .NPORTS                         (NPORTS),
          .NPORTS_LG2                     (NPORTS_LG2),
          .A_SYNC_TABLE                   (A_SYNC_TABLE),
          .RD_CAM_ADDR_WIDTH              (RD_CAM_ADDR_WIDTH),
          .WR_CAM_ADDR_WIDTH              (WR_CAM_ADDR_WIDTH),
          .WR_ECC_CAM_ADDR_WIDTH          (WR_ECC_CAM_ADDR_WIDTH),
          .WR_CAM_ADDR_WIDTH_IE           (WR_CAM_ADDR_WIDTH_IE),
          .MAX_CAM_ADDR_WIDTH             (MAX_CAM_ADDR_WIDTH),
          .RD_CAM_ENTRIES                 (RD_CAM_ENTRIES),
          .WR_CAM_ENTRIES                 (WR_CAM_ENTRIES),
          .WR_ECC_CAM_ENTRIES             (WR_ECC_CAM_ENTRIES),
          .WR_CAM_ENTRIES_IE              (WR_CAM_ENTRIES_IE),
          .CORE_DATA_WIDTH                (CORE_DATA_WIDTH),
          .CORE_ADDR_WIDTH                (CORE_ADDR_WIDTH),
          .CORE_ADDR_INT_WIDTH            (CORE_ADDR_INT_WIDTH),
          .CORE_TAG_WIDTH                 (CORE_TAG_WIDTH),

          // widths used for some outputs of ddrc_ctrl that would be
          // [X-1:0]=>[-1:0]
          // wide otherwise as X=0
          .RANK_BITS_DUP                  (RANK_BITS_DUP),
          .LRANK_BITS_DUP                 (LRANK_BITS_DUP),
          .BG_BITS_DUP                    (BG_BITS_DUP),
          .CID_WIDTH_DUP                  (CID_WIDTH_DUP),

          .RANK_BITS                      (RANK_BITS),
          .LRANK_BITS                     (LRANK_BITS),
          .CID_WIDTH                      (CID_WIDTH),
          .BG_BITS                        (BG_BITS),
          .BG_BANK_BITS                   (BG_BANK_BITS),
          .BANK_BITS                      (BANK_BITS),
          .PAGE_BITS                      (PAGE_BITS),
          .WORD_BITS                      (WORD_BITS),
          .BLK_BITS                       (BLK_BITS),
          .BSM_BITS                       (BSM_BITS),

          .MRS_A_BITS                     (MRS_A_BITS),
          .MRS_BA_BITS                    (MRS_BA_BITS),
          .PHY_ADDR_BITS                  (PHY_ADDR_BITS),

          .NUM_TOTAL_BANKS                (NUM_TOTAL_BANKS),
          .NUM_RANKS                      (NUM_RANKS),
          .NUM_LRANKS                     (NUM_LRANKS),
          .NUM_TOTAL_BSMS                 (NUM_TOTAL_BSMS),
          .NUM_PHY_DRAM_CLKS              (NUM_PHY_DRAM_CLKS),

          .PHY_DATA_WIDTH                 (PHY_DATA_WIDTH),
          .PHY_MASK_WIDTH                 (PHY_MASK_WIDTH),

          .MWR_BITS                       (MWR_BITS),

          .PARTIAL_WR_BITS                (PARTIAL_WR_BITS),

          .NUM_LANES                      (NUM_LANES),

          .RETRY_MAX_ADD_RD_LAT_LG2       (RETRY_MAX_ADD_RD_LAT_LG2),
          .CMD_LEN_BITS                   (CMD_LEN_BITS),
          .FATL_CODE_BITS                 (FATL_CODE_BITS),

          .WRDATA_CYCLES                  (WRDATA_CYCLES),
          // localparams in ddrc.v
          .CMD_TYPE_BITS (CMD_TYPE_BITS),
          .WDATA_PTR_BITS (WDATA_PTR_BITS),
          .CMD_RMW_BITS (CMD_RMW_BITS),
          .RMW_TYPE_BITS (RMW_TYPE_BITS),

          .PARTIAL_WR_BITS_LOG2 (PARTIAL_WR_BITS_LOG2),
          .PW_NUM_DB (PW_NUM_DB),

          .PW_FACTOR_QBW (PW_FACTOR_QBW),
          .PW_FACTOR_HBW (PW_FACTOR_HBW),
          .PW_FACTOR_FBW (PW_FACTOR_FBW),

          .PW_WORD_VALID_WD_QBW (PW_WORD_VALID_WD_QBW),
          .PW_WORD_VALID_WD_HBW (PW_WORD_VALID_WD_HBW),
          .PW_WORD_VALID_WD_FBW (PW_WORD_VALID_WD_FBW),

          .PW_WORD_VALID_WD_MAX (PW_WORD_VALID_WD_MAX),

          .PW_WORD_CNT_WD_MAX (PW_WORD_CNT_WD_MAX),

          .CORE_ECC_WIDTH_DUP (CORE_ECC_WIDTH_DUP),
          .CORE_ECC_MASK_WIDTH_DUP (CORE_ECC_MASK_WIDTH_DUP),

          .RANKBANK_BITS_FULL (RANKBANK_BITS_FULL),
          .NO_OF_BT               (NO_OF_BT         ),
          .NO_OF_BWT              (NO_OF_BWT        ),
          .NO_OF_BRT              (NO_OF_BRT        ),
          .BT_BITS                (BT_BITS          ),
          .BWT_BITS               (BWT_BITS         ),
          .BRT_BITS               (BRT_BITS         ),
          .NO_OF_BLK_CHN          (NO_OF_BLK_CHN    ),
          .BLK_CHN_BITS           (BLK_CHN_BITS     ),
          .IE_RD_TYPE_BITS        (IE_RD_TYPE_BITS  ),
          .IE_WR_TYPE_BITS        (IE_WR_TYPE_BITS  ),
          .IE_BURST_NUM_BITS      (IE_BURST_NUM_BITS),

          .MAX_CMD_DELAY          (MAX_CMD_DELAY    ),
          .CMD_DELAY_BITS         (CMD_DELAY_BITS   ),
          .AM_DCH_WIDTH           (AM_DCH_WIDTH     ),
          .AM_CS_WIDTH            (AM_CS_WIDTH      ),
          .AM_CID_WIDTH           (AM_CID_WIDTH     ),
          .AM_BANK_WIDTH          (AM_BANK_WIDTH    ),
          .AM_BG_WIDTH            (AM_BG_WIDTH      ),
          .AM_ROW_WIDTH           (AM_ROW_WIDTH     ),
          .AM_COL_WIDTH_H         (AM_COL_WIDTH_H   ),
          .AM_COL_WIDTH_L         (AM_COL_WIDTH_L   ),
          .MAX_CMD_NUM            (MAX_CMD_NUM      )

         )
   U_ddrc_cp_top(
           .core_ddrc_core_clk                    (core_ddrc_core_clk),
           .core_ddrc_rstn                        (core_ddrc_rstn),

           .bsm_clk                               (bsm_clk),
           .bsm_clk_en                            (bsm_clk_en),
           .bsm_clk_on                            (bsm_clk_on),


            //cpfdpif
            .i_wu_ih_cpfdpif                      (cpfdpif),
            .i_wu_te_cpfdpif                      (cpfdpif),
            .i_mr_ih_cpfdpif                      (cpfdpif),
            .o_ih_cpfdpif                         (cpfdpif),
            .o_te_cpfdpif                         (cpfdpif),

            //ddrc_cpedpie
            .i_wu_gs_ddrc_cpedpif                 (ddrc_cpedpif),
            .i_mr_gs_ddrc_cpedpif                 (ddrc_cpedpif),
            .o_gs_ddrc_cpedpif                    (ddrc_cpedpif),
            .o_pi_ddrc_cpedpif                    (ddrc_cpedpif),


           .hif_cmd_valid                         (hif_cmd_valid),
           .hif_cmd_type                          (hif_cmd_type),
           .hif_cmd_addr                          (hif_cmd_addr),
           .hif_cmd_pri                           (hif_cmd_pri),
           .hif_cmd_token                         (hif_cmd_token),
           .hif_cmd_length                        (hif_cmd_length),
           .hif_cmd_wdata_ptr                     (hif_cmd_wdata_ptr),
           .hif_cmd_autopre                       (hif_cmd_autopre),

           .hif_go2critical_lpr                    (hif_go2critical_lpr),
           .hif_go2critical_hpr                    (hif_go2critical_hpr),
           .hif_go2critical_wr                     (hif_go2critical_wr),
           .hif_go2critical_l1_wr                  (hif_go2critical_l1_wr ),
           .hif_go2critical_l2_wr                  (hif_go2critical_l2_wr ),
           .hif_go2critical_l1_lpr                 (hif_go2critical_l1_lpr),
           .hif_go2critical_l2_lpr                 (hif_go2critical_l2_lpr),
           .hif_go2critical_l1_hpr                 (hif_go2critical_l1_hpr),
           .hif_go2critical_l2_hpr                 (hif_go2critical_l2_hpr),
           .hif_rcmd_stall                         (),
           .hif_wcmd_stall                         (),
           .hif_cmd_stall                          (hif_cmd_stall),
           .hif_wdata_ptr                          (hif_wdata_ptr),
           .hif_wdata_ptr_valid                    (hif_wdata_ptr_valid),
           .hif_wdata_ptr_addr_err                 (hif_wdata_ptr_addr_err),
           .hif_lpr_credit                         (hif_lpr_credit),
           .hif_wr_credit                          (hif_wr_credit),
           .hif_hpr_credit                         (hif_hpr_credit),
           .hif_wrecc_credit                       (hif_wrecc_credit),
           .ddrc_reg_dbg_wrecc_q_depth             (),
           .ddrc_core_reg_dbg_wrecc_q_depth        (),
           .reg_ddrc_mr_wr                         (reg_ddrc_mr_wr),
           .reg_ddrc_sw_init_int                   (reg_ddrc_sw_init_int),
           .reg_ddrc_mr_type                       (reg_ddrc_mr_type),
           .reg_ddrc_mr_addr                       (reg_ddrc_mr_addr),
           .reg_ddrc_mr_data                       (reg_ddrc_mr_data),
           .ddrc_reg_mr_wr_busy                    (ddrc_reg_mr_wr_busy),
           .ddrc_reg_pda_done                      (),

           .reg_ddrc_derate_mr4_tuf_dis            (reg_ddrc_derate_mr4_tuf_dis),
           .core_derate_temp_limit_intr            (core_derate_temp_limit_intr),
           .derate_sync_ack_c2p                    (derate_sync_ack_c2p),

          .reg_ddrc_active_derate_byte_rank0       (reg_ddrc_active_derate_byte_rank0),

          .reg_ddrc_dbg_mr4_rank_sel               (reg_ddrc_dbg_mr4_rank_sel),
          .reg_ddrc_dbg_mr4_grp_sel                (reg_ddrc_dbg_mr4_grp_sel),
          .ddrc_reg_dbg_mr4_byte0                  (ddrc_reg_dbg_mr4_byte0),
          .ddrc_reg_dbg_mr4_byte1                  (ddrc_reg_dbg_mr4_byte1),
          .ddrc_reg_dbg_mr4_byte2                  (ddrc_reg_dbg_mr4_byte2),
          .ddrc_reg_dbg_mr4_byte3                  (ddrc_reg_dbg_mr4_byte3),

           .ddrc_reg_refresh_rate_rank0            (),
           .ddrc_reg_refresh_rate_rank1            (),
           .ddrc_reg_refresh_rate_rank2            (),
           .ddrc_reg_refresh_rate_rank3            (),
           .reg_ddrc_lpddr4_refresh_mode           (reg_ddrc_lpddr4_refresh_mode),
           .reg_ddrc_zq_reset                      (reg_ddrc_zq_reset),
           .reg_ddrc_t_zq_reset_nop                (reg_ddrc_t_zq_reset_nop),
           .ddrc_reg_zq_reset_busy                 (ddrc_reg_zq_reset_busy),
           .reg_ddrc_derate_enable                 (reg_ddrc_derate_enable),
           .reg_ddrc_derated_t_rcd                 (reg_ddrc_derated_t_rcd),
           .reg_ddrc_derated_t_ras_min             (reg_ddrc_derated_t_ras_min),
           .reg_ddrc_derated_t_rp                  (reg_ddrc_derated_t_rp),
           .reg_ddrc_derated_t_rrd                 (reg_ddrc_derated_t_rrd),
           .reg_ddrc_derated_t_rc                  (reg_ddrc_derated_t_rc),
           .reg_ddrc_derate_mr4_pause_fc           (reg_ddrc_derate_mr4_pause_fc),
           .reg_ddrc_mr4_read_interval             (reg_ddrc_mr4_read_interval),


           .hif_cmd_q_not_empty                    (hif_cmd_q_not_empty),

           .cactive_in_ddrc                        (cactive_in_ddrc),
           .cactive_in_ddrc_async                  (cactive_in_ddrc_async),
           .csysreq_ddrc                           (csysreq_ddrc),
           .csysack_ddrc                           (csysack_ddrc),
           .cactive_ddrc                           (cactive_ddrc),

           .stat_ddrc_reg_selfref_type             (stat_ddrc_reg_selfref_type),
           .dbg_dfi_ie_cmd_type                    (),
           .dbg_dfi_in_retry                       (),
           .ddrc_reg_num_alloc_bsm                 (),
           .ddrc_reg_max_num_alloc_bsm             (),
           .ddrc_reg_max_num_unalloc_entries       (),

           .perf_hif_rd_or_wr                    (),
           .perf_hif_wr                          (),
           .perf_hif_rd                          (),
           .perf_hif_rmw                         (),
           .perf_hif_hi_pri_rd                   (),

           .perf_read_bypass                     (),
           .perf_act_bypass                      (),

           .perf_hpr_xact_when_critical          (),
           .perf_lpr_xact_when_critical          (),
           .perf_wr_xact_when_critical           (),

           .perf_op_is_activate                  (),
           .perf_op_is_rd_or_wr                  (),
           .perf_op_is_rd_activate               (),
           .perf_op_is_rd                        (),
           .perf_op_is_wr                        (),
           .perf_op_is_mwr                       (),
           .perf_op_is_cas                       (),
           .perf_op_is_cas_ws                    (),
           .perf_op_is_cas_ws_off                (),
           .perf_op_is_cas_wck_sus               (),
           .perf_op_is_enter_dsm                 (),
           .perf_op_is_rfm                       (),
           .perf_op_is_precharge                 (),
           .perf_precharge_for_rdwr              (),
           .perf_precharge_for_other             (),

           .perf_rdwr_transitions                (),

           .perf_write_combine                   (),
           .perf_write_combine_noecc             (),
           .perf_write_combine_wrecc             (),
           .perf_war_hazard                      (),
           .perf_raw_hazard                      (),
           .perf_waw_hazard                      (),
           .perf_ie_blk_hazard                   (),
           .perf_op_is_enter_selfref             (),
           .perf_op_is_enter_powerdown           (),
           .perf_op_is_enter_mpsm                (),
           .perf_selfref_mode                    (),

           .perf_op_is_refresh                   (),
           .perf_op_is_crit_ref                  (),
           .perf_op_is_spec_ref                  (),
           .perf_op_is_load_mode                 (),
           .perf_op_is_zqcl                      (),
           .perf_op_is_zqcs                      (),
           .perf_rank                            (),
           .perf_bank                            (),
           .perf_bg                              (),
           .perf_cid                             (),
           .perf_bypass_rank                     (),
           .perf_bypass_bank                     (),
           .perf_bypass_bg                       (),
           .perf_bypass_cid                      (),
           .perf_bsm_alloc                       (),
           .perf_bsm_starvation                  (),
           .perf_num_alloc_bsm                   (),
           .perf_visible_window_limit_reached_rd (),
           .perf_visible_window_limit_reached_wr (),
           .perf_op_is_dqsosc_mpc                (),
           .perf_op_is_dqsosc_mrr                (),
           .perf_op_is_tcr_mrr                   (),
           .perf_op_is_zqstart                   (),
           .perf_op_is_zqlatch                   (),

           .ddrc_core_reg_dbg_operating_mode       (),
           .ddrc_core_reg_dbg_global_fsm_state     (),
           .ddrc_core_reg_dbg_init_curr_state      (),
           .ddrc_core_reg_dbg_init_next_state      (),
           .ddrc_core_reg_dbg_ctrlupd_state        (),
           .ddrc_core_reg_dbg_lpr_q_state          (),
           .ddrc_core_reg_dbg_hpr_q_state          (),
           .ddrc_core_reg_dbg_wr_q_state           (),
           .ddrc_core_reg_dbg_lpr_q_depth          (),
           .ddrc_core_reg_dbg_hpr_q_depth          (),
           .ddrc_core_reg_dbg_wr_q_depth           (),

           .ddrc_core_reg_dbg_hif_rcmd_stall       (),
           .ddrc_core_reg_dbg_hif_wcmd_stall       (),
           .ddrc_core_reg_dbg_hif_cmd_stall        (),

           .ddrc_core_reg_dbg_rd_valid_rank        (),
           .ddrc_core_reg_dbg_rd_page_hit_rank     (),
           .ddrc_core_reg_dbg_rd_pri_rank          (),
           .ddrc_core_reg_dbg_wr_valid_rank        (),
           .ddrc_core_reg_dbg_wr_page_hit_rank     (),

           .ddrc_core_reg_dbg_wr_cam_7_0_valid     (),
           .ddrc_core_reg_dbg_rd_cam_7_0_valid     (),
           .ddrc_core_reg_dbg_wr_cam_15_8_valid    (),
           .ddrc_core_reg_dbg_rd_cam_15_8_valid    (),
           .ddrc_core_reg_dbg_wr_cam_23_16_valid   (),
           .ddrc_core_reg_dbg_rd_cam_23_16_valid   (),
           .ddrc_core_reg_dbg_wr_cam_31_24_valid   (),
           .ddrc_core_reg_dbg_rd_cam_31_24_valid   (),
           .ddrc_core_reg_dbg_wr_cam_39_32_valid   (),
           .ddrc_core_reg_dbg_rd_cam_39_32_valid   (),
           .ddrc_core_reg_dbg_wr_cam_47_40_valid   (),
           .ddrc_core_reg_dbg_rd_cam_47_40_valid   (),
           .ddrc_core_reg_dbg_wr_cam_55_48_valid   (),
           .ddrc_core_reg_dbg_rd_cam_55_48_valid   (),
           .ddrc_core_reg_dbg_wr_cam_63_56_valid   (),
           .ddrc_core_reg_dbg_rd_cam_63_56_valid   (),

           .cp_dfiif                               (cp_dfiif),

           .reg_ddrc_dfi_tphy_wrlat                (reg_ddrc_dfi_tphy_wrlat),
           .reg_ddrc_dfi_t_rddata_en               (reg_ddrc_dfi_t_rddata_en),
           .reg_ddrc_dfi_tphy_wrcslat              (reg_ddrc_dfi_tphy_wrcslat),
           .reg_ddrc_dfi_tphy_rdcslat              (reg_ddrc_dfi_tphy_rdcslat),
           .reg_ddrc_dfi_data_cs_polarity          (reg_ddrc_dfi_data_cs_polarity),

           .dfi_wck_cs                             (dfi_wck_cs),
           .dfi_wck_en                             (dfi_wck_en),
           .dfi_wck_toggle                         (dfi_wck_toggle),

           .reg_ddrc_dfi_init_start                (reg_ddrc_dfi_init_start),
           .reg_ddrc_dfi_frequency                 (reg_ddrc_dfi_frequency),

           .reg_ddrc_dfi_freq_fsp                  (reg_ddrc_dfi_freq_fsp),
           .dfi_reset_n_in                         (dfi_reset_n_in),
           .dfi_reset_n_ref                        (dfi_reset_n_ref),
           .init_mr_done_in                        (init_mr_done_in),
           .init_mr_done_out                       (init_mr_done_out),

           .retryram_din                           (),
           .retryram_waddr                         (),
           .retryram_raddr                         (),
           .retryram_re                            (),
           .retryram_we                            (),
           .retryram_mask                          (),

           .reg_ddrc_dfi_init_complete_en          (reg_ddrc_dfi_init_complete_en),
           .reg_ddrc_frequency_ratio               (reg_ddrc_frequency_ratio),
           .reg_ddrc_opt_wrcam_fill_level                   (reg_ddrc_opt_wrcam_fill_level),
           .reg_ddrc_delay_switch_write                     (reg_ddrc_delay_switch_write),
           .reg_ddrc_wr_pghit_num_thresh                    (reg_ddrc_wr_pghit_num_thresh),
           .reg_ddrc_rd_pghit_num_thresh                    (reg_ddrc_rd_pghit_num_thresh),
           .reg_ddrc_wrcam_highthresh                       (reg_ddrc_wrcam_highthresh),
           .reg_ddrc_wrcam_lowthresh                        (reg_ddrc_wrcam_lowthresh),
           .reg_ddrc_wr_page_exp_cycles                     (reg_ddrc_wr_page_exp_cycles),
           .reg_ddrc_rd_page_exp_cycles                     (reg_ddrc_rd_page_exp_cycles),
           .reg_ddrc_wr_act_idle_gap                        (reg_ddrc_wr_act_idle_gap),
           .reg_ddrc_rd_act_idle_gap                        (reg_ddrc_rd_act_idle_gap),

           .reg_ddrc_dis_opt_ntt_by_act            (reg_ddrc_dis_opt_ntt_by_act),
           .reg_ddrc_dis_opt_ntt_by_pre            (reg_ddrc_dis_opt_ntt_by_pre),
           .reg_ddrc_autopre_rmw                   (reg_ddrc_autopre_rmw),

           .reg_ddrc_en_dfi_dram_clk_disable       (reg_ddrc_en_dfi_dram_clk_disable),
           .reg_ddrc_burst_rdwr                    (reg_ddrc_burst_rdwr[3:0]),
           .reg_ddrc_dis_dq                        (reg_ddrc_dis_dq),
           .reg_ddrc_dis_hif                       (reg_ddrc_dis_hif),
           .reg_ddrc_dis_wc                        (reg_ddrc_dis_wc),
           .reg_ddrc_rank_refresh                  (reg_ddrc_rank_refresh),
           .ddrc_reg_rank_refresh_busy             (ddrc_reg_rank_refresh_busy),
           .reg_ddrc_dis_auto_refresh              (reg_ddrc_dis_auto_refresh),
           .reg_ddrc_ctrlupd                       (reg_ddrc_ctrlupd),
           .ddrc_reg_ctrlupd_busy                  (ddrc_reg_ctrlupd_busy),
           .reg_ddrc_dis_auto_ctrlupd              (reg_ddrc_dis_auto_ctrlupd),
           .reg_ddrc_dis_auto_ctrlupd_srx          (reg_ddrc_dis_auto_ctrlupd_srx),
           .reg_ddrc_ctrlupd_pre_srx               (reg_ddrc_ctrlupd_pre_srx),
           .reg_ddrc_dis_speculative_act          (reg_ddrc_dis_speculative_act),
           .reg_ddrc_prefer_read                   (reg_ddrc_prefer_read),
           .reg_ddrc_lpr_num_entries               (reg_ddrc_lpr_num_entries),
           .reg_ddrc_lpr_num_entries_changed       (reg_ddrc_lpr_num_entries_changed),
           .reg_ddrc_mr                            (reg_ddrc_mr),
           .reg_ddrc_emr                           (reg_ddrc_emr),
           .reg_ddrc_emr2                          (reg_ddrc_emr2),
           .reg_ddrc_emr3                          (reg_ddrc_emr3),
           .reg_ddrc_mr4                           (reg_ddrc_mr4),
           .reg_ddrc_mr5                           (reg_ddrc_mr5),
           .reg_ddrc_mr6                           (reg_ddrc_mr6),
           .reg_ddrc_mr22                          (reg_ddrc_mr22),

           .reg_ddrc_t_rcd                         (reg_ddrc_t_rcd),
           .reg_ddrc_t_ras_min                     (reg_ddrc_t_ras_min),
           .reg_ddrc_t_ras_max                     (reg_ddrc_t_ras_max),
           .reg_ddrc_t_rc                          (reg_ddrc_t_rc),
           .reg_ddrc_t_rp                          (reg_ddrc_t_rp),
           .reg_ddrc_t_rrd                         (reg_ddrc_t_rrd),
           .reg_ddrc_t_rrd_s                       (reg_ddrc_t_rrd_s),
           .reg_ddrc_rd2pre                        (reg_ddrc_rd2pre),
           .reg_ddrc_wr2pre                        (reg_ddrc_wr2pre),
           .reg_ddrc_rda2pre                       (reg_ddrc_rda2pre),
           .reg_ddrc_wra2pre                       (reg_ddrc_wra2pre),
           .reg_ddrc_pageclose                     (reg_ddrc_pageclose),
           .reg_ddrc_pageclose_timer               (reg_ddrc_pageclose_timer),
           .reg_ddrc_page_hit_limit_rd             (reg_ddrc_page_hit_limit_rd),
           .reg_ddrc_page_hit_limit_wr             (reg_ddrc_page_hit_limit_wr),
           .reg_ddrc_opt_hit_gt_hpr                (reg_ddrc_opt_hit_gt_hpr),
           .reg_ddrc_refresh_margin                (reg_ddrc_refresh_margin),
           .reg_ddrc_pre_cke_x1024                 (reg_ddrc_pre_cke_x1024),
           .reg_ddrc_post_cke_x1024                (reg_ddrc_post_cke_x1024),
           .reg_ddrc_rd2wr                         (reg_ddrc_rd2wr),
           .reg_ddrc_wr2rd                         (reg_ddrc_wr2rd),
           .reg_ddrc_wr2rd_s                       (reg_ddrc_wr2rd_s),
           .reg_ddrc_refresh_burst                 (reg_ddrc_refresh_burst),
           .reg_ddrc_t_ccd                         (reg_ddrc_t_ccd),
           .reg_ddrc_t_ccd_s                       (reg_ddrc_t_ccd_s),
           .reg_ddrc_odtloff                       (reg_ddrc_odtloff),
           .reg_ddrc_t_ccd_mw                      (reg_ddrc_t_ccd_mw),
           .reg_ddrc_rd2mr                         (reg_ddrc_rd2mr),
           .reg_ddrc_wr2mr                         (reg_ddrc_wr2mr),
           .reg_ddrc_dis_trefi_x6x8                (reg_ddrc_dis_trefi_x6x8),
           .reg_ddrc_dis_trefi_x0125               (reg_ddrc_dis_trefi_x0125),
           .reg_ddrc_t_ppd                         (reg_ddrc_t_ppd),
           .reg_ddrc_rd2wr_s                       (reg_ddrc_rd2wr_s),
           .reg_ddrc_mrr2rd                        (reg_ddrc_mrr2rd),
           .reg_ddrc_mrr2wr                        (reg_ddrc_mrr2wr),
           .reg_ddrc_mrr2mrw                       (reg_ddrc_mrr2mrw),
           .reg_ddrc_wck_on                        (reg_ddrc_wck_on),
           .reg_ddrc_max_rd_sync                   (reg_ddrc_max_rd_sync),
           .reg_ddrc_max_wr_sync                   (reg_ddrc_max_wr_sync),
           .reg_ddrc_dfi_twck_delay                (reg_ddrc_dfi_twck_delay),
           .reg_ddrc_dfi_twck_en_rd                (reg_ddrc_dfi_twck_en_rd),
           .reg_ddrc_dfi_twck_en_wr                (reg_ddrc_dfi_twck_en_wr),
           .reg_ddrc_dfi_twck_dis                  (reg_ddrc_dfi_twck_dis),
           .reg_ddrc_dfi_twck_fast_toggle          (reg_ddrc_dfi_twck_fast_toggle),
           .reg_ddrc_dfi_twck_toggle               (reg_ddrc_dfi_twck_toggle),
           .reg_ddrc_dfi_twck_toggle_cs            (reg_ddrc_dfi_twck_toggle_cs),
           .reg_ddrc_dfi_twck_toggle_post          (reg_ddrc_dfi_twck_toggle_post),
           .reg_ddrc_t_cke         (reg_ddrc_t_cke),
           .reg_ddrc_t_faw         (reg_ddrc_t_faw),

           .reg_ddrc_t_rfc_min    (reg_ddrc_t_rfc_min),
           .reg_ddrc_t_rfc_min_ab (reg_ddrc_t_rfc_min_ab),
           .reg_ddrc_t_pbr2pbr    (reg_ddrc_t_pbr2pbr),
           .reg_ddrc_t_pbr2act    (reg_ddrc_t_pbr2act),

           .reg_ddrc_t_refi_x1_sel (reg_ddrc_t_refi_x1_sel),
.reg_ddrc_t_refi_x1_x32     (reg_ddrc_t_refi_x1_x32),
.reg_ddrc_t_mr      (reg_ddrc_t_mr),
.reg_ddrc_refresh_to_x1_x32     (reg_ddrc_refresh_to_x1_x32),
.reg_ddrc_en_2t_timing_mode     (reg_ddrc_en_2t_timing_mode),
.reg_ddrc_prefer_write     (reg_ddrc_prefer_write),
.reg_ddrc_rdwr_idle_gap     (reg_ddrc_rdwr_idle_gap),
.reg_ddrc_powerdown_en     (reg_ddrc_powerdown_en),
.reg_ddrc_powerdown_to_x32     (reg_ddrc_powerdown_to_x32),
.reg_ddrc_t_xp     (reg_ddrc_t_xp),

.reg_ddrc_selfref_sw     (reg_ddrc_selfref_sw),
.reg_ddrc_hw_lp_en     (reg_ddrc_hw_lp_en),
.reg_ddrc_hw_lp_exit_idle_en     (reg_ddrc_hw_lp_exit_idle_en),
.reg_ddrc_selfref_to_x32     (reg_ddrc_selfref_to_x32),
.reg_ddrc_hw_lp_idle_x32     (reg_ddrc_hw_lp_idle_x32),

.reg_ddrc_dfi_t_ctrlupd_interval_min_x1024     (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024),
.reg_ddrc_dfi_t_ctrlupd_interval_max_x1024     (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024),

.reg_ddrc_selfref_en     (reg_ddrc_selfref_en),
.reg_ddrc_mr_rank     (reg_ddrc_mr_rank),
.reg_ddrc_t_xsr     (reg_ddrc_t_xsr),
.reg_ddrc_refresh_update_level     (reg_ddrc_refresh_update_level),




.reg_ddrc_rank0_wr_odt     (reg_ddrc_rank0_wr_odt),
.reg_ddrc_rank0_rd_odt     (reg_ddrc_rank0_rd_odt),
.reg_ddrc_hpr_xact_run_length     (reg_ddrc_hpr_xact_run_length),
.reg_ddrc_hpr_max_starve     (reg_ddrc_hpr_max_starve),
.reg_ddrc_lpr_xact_run_length     (reg_ddrc_lpr_xact_run_length),
.reg_ddrc_lpr_max_starve     (reg_ddrc_lpr_max_starve),
.reg_ddrc_w_xact_run_length     (reg_ddrc_w_xact_run_length),
.reg_ddrc_w_max_starve     (reg_ddrc_w_max_starve),

.reg_ddrc_dfi_t_ctrlup_min     (reg_ddrc_dfi_t_ctrlup_min),
.reg_ddrc_dfi_t_ctrlup_max     (reg_ddrc_dfi_t_ctrlup_max),

.reg_ddrc_read_latency     (reg_ddrc_read_latency),
.rl_plus_cmd_len           (rl_plus_cmd_len),

                                                        // data is passed on the ECC bits
          .ddrc_reg_capar_poison_complete         (),

// for address mapper
.reg_ddrc_addrmap_bank_b0     (reg_ddrc_addrmap_bank_b0),
.reg_ddrc_addrmap_bank_b1     (reg_ddrc_addrmap_bank_b1),
.reg_ddrc_addrmap_bank_b2     (reg_ddrc_addrmap_bank_b2),
.reg_ddrc_addrmap_bg_b0     (reg_ddrc_addrmap_bg_b0),
.reg_ddrc_addrmap_bg_b1     (reg_ddrc_addrmap_bg_b1),
.reg_ddrc_addrmap_col_b3     (reg_ddrc_addrmap_col_b3),
.reg_ddrc_addrmap_col_b4     (reg_ddrc_addrmap_col_b4),
.reg_ddrc_addrmap_col_b5     (reg_ddrc_addrmap_col_b5),
.reg_ddrc_addrmap_col_b6     (reg_ddrc_addrmap_col_b6),
.reg_ddrc_addrmap_col_b7     (reg_ddrc_addrmap_col_b7),
.reg_ddrc_addrmap_col_b8     (reg_ddrc_addrmap_col_b8),
.reg_ddrc_addrmap_col_b9     (reg_ddrc_addrmap_col_b9),
.reg_ddrc_addrmap_col_b10     (reg_ddrc_addrmap_col_b10),
.reg_ddrc_addrmap_row_b0     (reg_ddrc_addrmap_row_b0),
.reg_ddrc_addrmap_row_b1     (reg_ddrc_addrmap_row_b1),
.reg_ddrc_addrmap_row_b2     (reg_ddrc_addrmap_row_b2),
.reg_ddrc_addrmap_row_b3     (reg_ddrc_addrmap_row_b3),
.reg_ddrc_addrmap_row_b4     (reg_ddrc_addrmap_row_b4),
.reg_ddrc_addrmap_row_b5     (reg_ddrc_addrmap_row_b5),
.reg_ddrc_addrmap_row_b6     (reg_ddrc_addrmap_row_b6),
.reg_ddrc_addrmap_row_b7     (reg_ddrc_addrmap_row_b7),
.reg_ddrc_addrmap_row_b8     (reg_ddrc_addrmap_row_b8),
.reg_ddrc_addrmap_row_b9     (reg_ddrc_addrmap_row_b9),
.reg_ddrc_addrmap_row_b10     (reg_ddrc_addrmap_row_b10),
.reg_ddrc_addrmap_row_b11     (reg_ddrc_addrmap_row_b11),
.reg_ddrc_addrmap_row_b12     (reg_ddrc_addrmap_row_b12),
.reg_ddrc_addrmap_row_b13     (reg_ddrc_addrmap_row_b13),
.reg_ddrc_addrmap_row_b14     (reg_ddrc_addrmap_row_b14),
.reg_ddrc_addrmap_row_b15     (reg_ddrc_addrmap_row_b15),
.reg_ddrc_addrmap_row_b16     (reg_ddrc_addrmap_row_b16),
.reg_ddrc_addrmap_row_b17     (reg_ddrc_addrmap_row_b17),



// s to status & interrupt registers
// s to debug registers
.ddrc_reg_dbg_hpr_q_depth     (ddrc_reg_dbg_hpr_q_depth),
.ddrc_reg_dbg_lpr_q_depth     (ddrc_reg_dbg_lpr_q_depth),
.ddrc_reg_dbg_w_q_depth     (ddrc_reg_dbg_w_q_depth),
.ddrc_reg_dbg_stall_rd     (),
.ddrc_reg_dbg_stall_wr     (),
.ddrc_reg_dbg_stall     (ddrc_reg_dbg_stall),
.ddrc_reg_selfref_cam_not_empty     (ddrc_reg_selfref_cam_not_empty),
.ddrc_reg_selfref_state     (ddrc_reg_selfref_state),
.ddrc_reg_operating_mode     (ddrc_reg_operating_mode_w),   // note use of _w

.ddrc_reg_selfref_type     (ddrc_reg_selfref_type),
.ddrc_reg_wr_q_empty     (ddrc_reg_wr_q_empty),
.ddrc_reg_rd_q_empty     (ddrc_reg_rd_q_empty),
.ddrc_reg_wr_data_pipeline_empty     (ddrc_reg_wr_data_pipeline_empty),
.ddrc_reg_rd_data_pipeline_empty     (ddrc_reg_rd_data_pipeline_empty),

.reg_ddrc_dis_auto_zq     (reg_ddrc_dis_auto_zq),
.reg_ddrc_dis_srx_zqcl     (reg_ddrc_dis_srx_zqcl),
.reg_ddrc_zq_resistor_shared     (reg_ddrc_zq_resistor_shared),
.reg_ddrc_t_zq_long_nop     (reg_ddrc_t_zq_long_nop),
.reg_ddrc_t_zq_short_nop     (reg_ddrc_t_zq_short_nop),
.reg_ddrc_t_zq_short_interval_x1024     (reg_ddrc_t_zq_short_interval_x1024),
.reg_ddrc_zq_calib_short     (reg_ddrc_zq_calib_short),
.ddrc_reg_zq_calib_short_busy     (ddrc_reg_zq_calib_short_busy),


.reg_ddrc_dram_rstn_x1024     (reg_ddrc_dram_rstn_x1024),

.reg_ddrc_per_bank_refresh     (reg_ddrc_per_bank_refresh),
.reg_ddrc_auto_refab_en        (reg_ddrc_auto_refab_en),
.reg_ddrc_refresh_to_ab_x32    (reg_ddrc_refresh_to_ab_x32),
.hif_refresh_req_bank     (hif_refresh_req_bank),
.reg_ddrc_lpddr4     (reg_ddrc_lpddr4),
.reg_ddrc_lpddr5     (reg_ddrc_lpddr5),
.reg_ddrc_bank_org   (reg_ddrc_bank_org),
.reg_ddrc_lpddr4_diff_bank_rwa2pre (reg_ddrc_lpddr4_diff_bank_rwa2pre),
.reg_ddrc_stay_in_selfref     (reg_ddrc_stay_in_selfref),
.reg_ddrc_t_cmdcke            (reg_ddrc_t_cmdcke),
.reg_ddrc_dsm_en              (reg_ddrc_dsm_en),
.reg_ddrc_t_pdn               (reg_ddrc_t_pdn),
.reg_ddrc_t_xsr_dsm_x1024     (reg_ddrc_t_xsr_dsm_x1024),
.reg_ddrc_t_csh               (reg_ddrc_t_csh),

.hif_refresh_req          (),
.hif_refresh_req_cnt      (),
.hif_refresh_req_derate   (),
.hif_refresh_active       (),

//
.reg_ddrc_nonbinary_device_density   (reg_ddrc_nonbinary_device_density),

.reg_ddrc_dfi_phyupd_en     (reg_ddrc_dfi_phyupd_en),
.reg_ddrc_dfi_phymstr_en     (reg_ddrc_dfi_phymstr_en),
.reg_ddrc_dfi_phymstr_blk_ref_x32     (reg_ddrc_dfi_phymstr_blk_ref_x32),
.reg_ddrc_dis_cam_drain_selfref     (reg_ddrc_dis_cam_drain_selfref),
.reg_ddrc_lpddr4_sr_allowed     (reg_ddrc_lpddr4_sr_allowed),
.reg_ddrc_lpddr4_opt_act_timing (reg_ddrc_lpddr4_opt_act_timing),
.reg_ddrc_lpddr5_opt_act_timing (reg_ddrc_lpddr5_opt_act_timing),
.reg_ddrc_dfi_t_ctrl_delay     (reg_ddrc_dfi_t_ctrl_delay),
.reg_ddrc_dfi_t_wrdata_delay     (reg_ddrc_dfi_t_wrdata_delay),

.reg_ddrc_dfi_t_dram_clk_disable     (reg_ddrc_dfi_t_dram_clk_disable),
.reg_ddrc_dfi_t_dram_clk_enable     (reg_ddrc_dfi_t_dram_clk_enable),
.reg_ddrc_t_cksre     (reg_ddrc_t_cksre),
.reg_ddrc_t_cksrx     (reg_ddrc_t_cksrx),
.reg_ddrc_t_ckcsx     (reg_ddrc_t_ckcsx),
.reg_ddrc_t_ckesr     (reg_ddrc_t_ckesr),

.reg_ddrc_dfi_lp_data_req_en (reg_ddrc_dfi_lp_data_req_en),
.reg_ddrc_dfi_lp_en_pd       (reg_ddrc_dfi_lp_en_pd),
.reg_ddrc_dfi_lp_wakeup_pd   (reg_ddrc_dfi_lp_wakeup_pd),
.reg_ddrc_dfi_lp_en_sr       (reg_ddrc_dfi_lp_en_sr),
.reg_ddrc_dfi_lp_wakeup_sr   (reg_ddrc_dfi_lp_wakeup_sr),
.reg_ddrc_dfi_lp_en_data     (reg_ddrc_dfi_lp_en_data),
.reg_ddrc_dfi_lp_wakeup_data (reg_ddrc_dfi_lp_wakeup_data),
.reg_ddrc_dfi_lp_en_dsm      (reg_ddrc_dfi_lp_en_dsm),
.reg_ddrc_dfi_lp_wakeup_dsm  (reg_ddrc_dfi_lp_wakeup_dsm),


.reg_ddrc_skip_dram_init     (reg_ddrc_skip_dram_init),
.reg_ddrc_dfi_tlp_resp     (reg_ddrc_dfi_tlp_resp),

.hwffc_target_freq_en(),
.hwffc_target_freq(),
.hwffc_target_freq_init(),

.ddrc_reg_hwffc_in_progress(),
.ddrc_reg_current_frequency(),
.ddrc_reg_current_fsp(),
.ddrc_reg_current_vrcg(),
.ddrc_reg_hwffc_operating_mode(),
.ddrc_xpi_port_disable_req(),
.ddrc_xpi_clock_required(),

.hwffc_hif_wd_stall            (),
.hwffc_i_reg_ddrc_dis_auto_zq    (),



// new i/os not in ddrc.v i/o list
// connects ddrc_ctrl.v sub-blocks to rest of ddrc.v e.g. mr/rd/rt etc
.ih_rd_lkp_brt_vld       (),

.ih_mr_ie_pw      (),

.hif_mrr_data     (hif_mrr_data),

.rd_mr4_data_valid    (rd_mr4_data_valid),
.rt_rd_rd_mrr_ext     (rt_rd_rd_mrr_ext),

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in ddrc_assertions module
.ih_te_rd_valid    (ih_te_rd_valid),
.ih_te_wr_valid    (ih_te_wr_valid),
//spyglass enable_block W528


//--------------------------------------------------------------
//---------------- MR -> IH/WU Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- MR -> TS Interface --------------------------
//--------------------------------------------------------------
.dfi_wr_q_empty     (dfi_wr_q_empty),

//--------------------------------------------------------------
//---------------- PI -> TS Interface --------------------------
//--------------------------------------------------------------
.pi_gs_geardown_mode_on (), // to MR etc

//--------------------------------------------------------------
//---------------- PI -> RT Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- RT -> TS Interface --------------------------
//--------------------------------------------------------------
.rt_gs_empty     (rt_gs_empty),
.rt_gs_empty_delayed     (rt_gs_empty_delayed),

//--------------------------------------------------------------
//---------------- TE -> WU Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- TE -> MR Interface --------------------------
//--------------------------------------------------------------
.ts_pi_mwr                      (ts_pi_mwr),// masked write information

//--------------------------------------------------------------
//---------------- TE -> WU Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- TS -> MR Interface --------------------------
//--------------------------------------------------------------
.gs_pi_cs_n                     (),

//--------------------------------------------------------------
//---------------- WU -> IH Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- WU -> TE Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//---------------- WU -> TS Interface --------------------------
//--------------------------------------------------------------

//--------------------------------------------------------------
//------------- Retry <-> RT Interface -------------------------
//--------------------------------------------------------------
.retry_rt_rdatavld_gate_en     (),
.retry_rt_fifo_init_n     (),


//--------------------------------------------------------------
//------------- Retry -> DFI Interface -------------------------
//--------------------------------------------------------------
.retry_dfi_sel                         (),
.retry_phy_dm                          (),
.retry_phy_wdata                       (),
.retry_phy_wdata_vld_early             (),
.retry_dfi_rddata_en                   (),
.retry_dfi_wrdata_en                   (),
.stat_ddrc_reg_retry_current_state     (),

.retry_rt_now_sw_intervention     (),
.retry_rt_rd_timeout_value     (),
.retry_rt_fatl_err_pulse     (),

.retry_fifo_empty     (),
.ddrc_cg_en     (ddrc_cg_en),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in conditional selection based on hardware parameter value
.gs_pi_data_pipeline_empty (gs_pi_data_pipeline_empty),
.mrr_op_on     (mrr_op_on),
.ih_busy     (ih_busy),
//spyglass enable_block W528
.pi_gs_mpr_mode     (),

.mr_t_wrlat                  (mr_t_wrlat),
.mr_t_wrdata                 (mr_t_wrdata),
.mr_t_rddata_en              (mr_t_rddata_en),
.mr_lp_data_rd               (mr_lp_data_rd),
.mr_lp_data_wr               (mr_lp_data_wr),

.dfi_cmd_delay              (dfi_cmd_delay),

// additional outputs for ddrc_assertions.sv

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in ddrc_assertions module
.reg_ddrc_active_ranks_int     (),
.reg_ddrc_ext_rank_refresh   (),

.pi_gs_dll_off_mode          (),
.reg_ddrc_fgr_mode_gated (),
.ddrc_phy_cal_dl_enable      (),
.gs_pi_op_is_exit_selfref    (gs_pi_op_is_exit_selfref),
.ih_ie_busy                  (ih_ie_busy),
//spyglass enable_block W528

// occap specific input/output
.ddrc_cmp_en                    (ddrc_cmp_en),
.ddrc_ctrl_cmp_poison           (reg_ddrc_occap_ddrc_ctrl_poison_seq),
.ddrc_ctrl_cmp_poison_full      (reg_ddrc_occap_ddrc_ctrl_poison_parallel),
.ddrc_ctrl_cmp_poison_err_inj   (reg_ddrc_occap_ddrc_ctrl_poison_err_inj),
.ddrc_ctrl_cmp_error            (occap_ddrc_ctrl_err),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
.ddrc_ctrl_cmp_error_full       (occap_ddrc_ctrl_poison_parallel_err_int),
.ddrc_ctrl_cmp_error_seq        (occap_ddrc_ctrl_poison_seq_err_int),
.ddrc_ctrl_cmp_poison_complete  (occap_ddrc_ctrl_poison_complete_int)
//spyglass enable_block W528
   ,.reg_ddrc_dis_dqsosc_srx      (reg_ddrc_dis_dqsosc_srx)
   ,.reg_ddrc_dqsosc_enable       (reg_ddrc_dqsosc_enable)
   ,.reg_ddrc_t_osco              (reg_ddrc_t_osco)
   ,.reg_ddrc_dqsosc_runtime      (reg_ddrc_dqsosc_runtime)
   ,.reg_ddrc_wck2dqo_runtime     (reg_ddrc_wck2dqo_runtime)
   ,.reg_ddrc_dqsosc_interval     (reg_ddrc_dqsosc_interval)
   ,.reg_ddrc_dqsosc_interval_unit(reg_ddrc_dqsosc_interval_unit)
   ,.dqsosc_state                 (dqsosc_state)
   ,.dqsosc_per_rank_stat         (dqsosc_per_rank_stat)
   ,.reg_ddrc_dfi_t_ctrlmsg_resp             (reg_ddrc_dfi_t_ctrlmsg_resp)
   ,.reg_ddrc_dfi0_ctrlmsg_req               (reg_ddrc_dfi0_ctrlmsg_req)
   ,.reg_ddrc_dfi0_ctrlmsg_tout_clr          (reg_ddrc_dfi0_ctrlmsg_tout_clr)
   ,.reg_ddrc_dfi0_ctrlmsg_data              (reg_ddrc_dfi0_ctrlmsg_data)
   ,.reg_ddrc_dfi0_ctrlmsg_cmd               (reg_ddrc_dfi0_ctrlmsg_cmd)
   ,.ddrc_reg_dfi0_ctrlmsg_req_busy          (ddrc_reg_dfi0_ctrlmsg_req_busy)
   ,.ddrc_reg_dfi0_ctrlmsg_resp_tout         (ddrc_reg_dfi0_ctrlmsg_resp_tout)
`ifdef SNPS_ASSERT_ON
   ,.reg_ddrc_data_bus_width                 (reg_ddrc_data_bus_width)
`endif
   );



assign occap_ddrc_data_err      = occap_ddrc_data_err_mr | occap_ddrc_data_err_rd;

assign  phy_ddrc_rdata          = dfi_rddata_int;
assign  phy_ddrc_rdbi_n         = dfi_rddata_dbi_int;
// Temporary - phy_ddrc_rdatavld is per byte
assign  phy_ddrc_rdatavld       = dfi_rddata_valid_int;


//------------------------------------------------------------------------------
// RW (Read-modify-Write) block
//------------------------------------------------------------------------------
/* No RMW commands supported here; just ECC scrubs **
rw #(
                .CMD_RMW_BITS                   (CMD_RMW_BITS),
                .RMW_TYPE_BITS                  (RMW_TYPE_BITS) )
  rw (          .co_yy_clk                      (core_ddrc_core_clk),
                .dh_rw_resetb                   (core_ddrc_rstn),
                .rd_rw_rdata_in                 (rd_rw_rdata),
                .rd_rw_rdata_in_valid           (rd_rw_rdata_valid),
                .rd_rw_rmw_info                 (rd_rw_rmwcmd),
                .rd_rw_rmw_type                 (rd_yy_rmwtype),
                .rw_wu_rdata_out                (rw_wu_rdata)
        );
** No RMW commands supported here; just ECC scrubs */
assign rw_wu_rdata = rd_rw_rdata;

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

ddrc_assertions
 # (
                .CHANNEL_NUM                    (CHANNEL_NUM),
                .SHARED_AC                      (SHARED_AC),
                .CORE_TAG_WIDTH                 (CORE_TAG_WIDTH),
                .WRDATA_RAM_ADDR_WIDTH          (WRDATA_RAM_ADDR_WIDTH),
                .T_REFI_X1_X32_WIDTH                 (T_REFI_X1_X32_WIDTH),
                .T_RFC_MIN_WIDTH                 (T_RFC_MIN_WIDTH),
                .T_RAS_MIN_WIDTH                 (T_RAS_MIN_WIDTH),

                .WR2PRE_WIDTH                    (WR2PRE_WIDTH),
                .RD2PRE_WIDTH                    (RD2PRE_WIDTH),

                .T_MR_WIDTH                      (T_MR_WIDTH),
                .T_RCD_WIDTH                     (T_RCD_WIDTH),
                .T_RP_WIDTH                      (T_RP_WIDTH)

   )
    ddrc_assertions (
        .core_ddrc_core_clk(core_ddrc_core_clk),
        .core_ddrc_rstn(core_ddrc_rstn),
        .reg_ddrc_data_bus_width(reg_ddrc_data_bus_width),
        .reg_ddrc_t_mr (reg_ddrc_t_mr),
        .hif_cmd_valid(hif_cmd_valid),
        .hif_cmd_pri(hif_cmd_pri), // TEMP ONLY: make it 2-bits when DDRC input is changed
        .hif_cmd_stall(hif_cmd_stall),
        .hif_cmd_type(hif_cmd_type),
        .hif_cmd_token(hif_cmd_token),
        .reg_ddrc_dm_en  (reg_ddrc_dm_en),
        .reg_ddrc_burst_rdwr (reg_ddrc_burst_rdwr[3:0]),
        .reg_ddrc_dfi_tphy_wrlat(reg_ddrc_dfi_tphy_wrlat),
        .reg_ddrc_dfi_tphy_wrdata(reg_ddrc_dfi_tphy_wrdata),
        .reg_ddrc_rank_refresh (reg_ddrc_rank_refresh),
        .reg_ddrc_dis_auto_refresh (reg_ddrc_dis_auto_refresh),
        .reg_ddrc_ctrlupd (reg_ddrc_ctrlupd),
        .reg_ddrc_dis_auto_ctrlupd (reg_ddrc_dis_auto_ctrlupd),
        .reg_ddrc_dis_auto_ctrlupd_srx (reg_ddrc_dis_auto_ctrlupd_srx),
        .reg_ddrc_en_2t_timing_mode (reg_ddrc_en_2t_timing_mode),
        .reg_ddrc_zq_calib_short (reg_ddrc_zq_calib_short),
        .reg_ddrc_dis_auto_zq (reg_ddrc_dis_auto_zq),
        .reg_ddrc_dis_srx_zqcl (reg_ddrc_dis_srx_zqcl),
        .reg_ddrc_zq_resistor_shared (reg_ddrc_zq_resistor_shared),
        .reg_ddrc_t_zq_short_nop (reg_ddrc_t_zq_short_nop),
        .reg_ddrc_t_zq_long_nop (reg_ddrc_t_zq_long_nop),  // time to wait in ZQCL during init sequence
        .reg_ddrc_refresh_burst (reg_ddrc_refresh_burst),

        .reg_ddrc_t_refi_x32 (reg_ddrc_t_refi_x1_x32),
        .reg_ddrc_t_rfc_min     (reg_ddrc_t_rfc_min),
        .reg_ddrc_t_ras_min     (reg_ddrc_t_ras_min),

        .dfi_cke           (cp_dfiif.dfi_cke),
        .dfi_cs            (cp_dfiif.dfi_cs),
        .dfi_ctrlupd_ack   (cp_dfiif.dfi_ctrlupd_ack),
        .dfi_ctrlupd_req   (cp_dfiif.dfi_ctrlupd_req),
        .reg_ddrc_lpr_num_entries(reg_ddrc_lpr_num_entries),
        .reg_ddrc_dfi_phyupd_en(reg_ddrc_dfi_phyupd_en),
        .dfi_phyupd_req   (cp_dfiif.dfi_phyupd_req),
        .dfi_phyupd_ack   (cp_dfiif.dfi_phyupd_ack),
        .dfi_lp_ctrl_ack  (cp_dfiif.dfi_lp_ctrl_ack),
        .dfi_lp_data_ack  (cp_dfiif.dfi_lp_data_ack),

        .dfi_cmd_delay    (dfi_cmd_delay),
        .ddrc_reg_operating_mode (ddrc_reg_operating_mode),
        .ddrc_reg_wr_data_pipeline_empty     (ddrc_reg_wr_data_pipeline_empty),
        .ddrc_reg_rd_data_pipeline_empty     (ddrc_reg_rd_data_pipeline_empty),

.ddrc_reg_selfref_state     (ddrc_reg_selfref_state),
        .ih_te_rd_valid(ih_te_rd_valid),
        .ih_te_wr_valid(ih_te_wr_valid),
        .ih_te_rmw_type(cpfdpif.ih_wu_rmw_type),
        .wu_me_wvalid   (wu_me_wvalid),
        .wu_me_waddr    (wu_me_waddr),
        .mr_me_re       (mr_me_re),
        .mr_me_raddr    (mr_me_raddr),
        .hif_rdata_token(hif_rdata_token),
        .hif_rdata_valid(hif_rdata_valid),
        .hif_rdata_end(hif_rdata_end)
        ,.reg_ddrc_per_bank_refresh     (reg_ddrc_per_bank_refresh)
        ,.reg_ddrc_lpddr4               (reg_ddrc_lpddr4)
        ,.reg_ddrc_lpddr5               (reg_ddrc_lpddr5)
        ,.reg_ddrc_bank_org             (reg_ddrc_bank_org)
        ,.reg_ddrc_dfi_t_ctrl_delay       (reg_ddrc_dfi_t_ctrl_delay)
        ,.reg_ddrc_dfi_t_dram_clk_disable (reg_ddrc_dfi_t_dram_clk_disable)
        ,.reg_ddrc_t_rcd                  (reg_ddrc_t_rcd)
        ,.reg_ddrc_t_rp                   (reg_ddrc_t_rp)
        ,.reg_ddrc_wr2pre                 (reg_ddrc_wr2pre)
        ,.reg_ddrc_rd2pre                 (reg_ddrc_rd2pre)
        ,.reg_ddrc_wra2pre                (reg_ddrc_wra2pre)
        ,.reg_ddrc_rda2pre                (reg_ddrc_rda2pre)
        ,.dfi_dram_clk_disable_bit_0      (cp_dfiif.dfi_dram_clk_disable[0])
        ,.dh_gs_stay_in_selfref           (reg_ddrc_stay_in_selfref)
        ,.gs_pi_op_is_exit_selfref        (gs_pi_op_is_exit_selfref)
        ,.reg_ddrc_frequency_ratio        (reg_ddrc_frequency_ratio)
);

`endif //`ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON

generate
   if (OCPAR_EN==1 || OCECC_EN==1) begin: OC_PAR_OR_ECC_en

      reg wdata_ocpar_error_r, wdata_ocpar_error_ie_r;

      always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
         if (~core_ddrc_rstn) begin
            wdata_ocpar_error_r     <= 1'b0;
            wdata_ocpar_error_ie_r  <= 1'b0;
         end
         else begin
            wdata_ocpar_error_r     <= wdata_ocpar_error;
            wdata_ocpar_error_ie_r  <= wdata_ocpar_error_ie;
         end
      end

      assign par_wdata_out_err_pulse      = wdata_ocpar_error_r;
      assign par_wdata_out_err_ie_pulse   = wdata_ocpar_error_ie_r;

      assign write_data_parity_en   = reg_ddrc_oc_parity_en; // write data parity enabled
   end
   else begin: OC_PAR_OR_ECC_nen
      // on-chip parity disabled, pin to constant
      assign par_wdata_out_err_pulse   = 1'b0;
      assign par_wdata_out_err_ie_pulse= 1'b0;

      assign write_data_parity_en      = 1'b0;
   end
endgenerate


dwc_ddrctl_ddrc_dp
 #(
             .CORE_DATA_WIDTH                            (CORE_DATA_WIDTH                             )
            ,.CORE_MASK_WIDTH                            (CORE_MASK_WIDTH                             )
            ,.WRSRAM_DATA_WIDTH                          (CORE_DATA_WIDTH                             )
            ,.WRSRAM_MASK_WIDTH                          (CORE_MASK_WIDTH                             )
            ,.CORE_ECC_WIDTH                             (CORE_ECC_WIDTH                              )
            ,.PHY_DATA_WIDTH                             (PHY_DATA_WIDTH                              )
            ,.PHY_MASK_WIDTH                             (PHY_MASK_WIDTH                              )
            ,.WR_CAM_ADDR_WIDTH                          (WR_CAM_ADDR_WIDTH                           )
            ,.WR_CAM_ADDR_WIDTH_IE                       (WR_CAM_ADDR_WIDTH_IE                        )
            ,.WRDATA_RAM_ADDR_WIDTH                      (WRDATA_RAM_ADDR_WIDTH                       )
            ,.PARTIAL_WR_BITS                            (PARTIAL_WR_BITS                             )
            ,.PARTIAL_WR_BITS_LOG2                       (PARTIAL_WR_BITS_LOG2                        )
            ,.PW_NUM_DB                                  (PW_NUM_DB                                   )
            ,.PW_FACTOR_QBW                              (PW_FACTOR_QBW                               )
            ,.PW_FACTOR_HBW                              (PW_FACTOR_HBW                               )
            ,.PW_WORD_VALID_WD_QBW                       (PW_WORD_VALID_WD_QBW                        )
            ,.PW_WORD_VALID_WD_HBW                       (PW_WORD_VALID_WD_HBW                        )
            ,.PW_WORD_VALID_WD_MAX                       (PW_WORD_VALID_WD_MAX                        )
            ,.PW_WORD_CNT_WD_MAX                         (PW_WORD_CNT_WD_MAX                          )
            ,.WRDATA_CYCLES                              (WRDATA_CYCLES                               )
            ,.WDATARAM_RD_LATENCY                        (WDATARAM_RD_LATENCY                         )
            ,.MAX_CMD_DELAY                              (MAX_CMD_DELAY                               )
            ,.CMD_DELAY_BITS                             (CMD_DELAY_BITS                              )
            ,.OCPAR_EN                                   (OCPAR_EN                                    )
            ,.OCECC_EN                                   (OCECC_EN                                    )
            ,.OCPAR_OR_OCECC_EN                          (OCPAR_OR_OCECC_EN                           )
            ,.CMD_LEN_BITS                               (CMD_LEN_BITS                                )
            ,.OCCAP_EN                                   (OCCAP_EN                                    )
            ,.OCCAP_PIPELINE_EN                          (OCCAP_PIPELINE_EN                           ) // pipelining on comparator inputs for OCCAP
            ,.OCECC_MR_RD_GRANU                          (OCECC_MR_RD_GRANU                           )
            ,.WDATA_PAR_WIDTH                            (WDATA_PAR_WIDTH                             )
            ,.WDATA_PAR_WIDTH_EXT                        (WDATA_PAR_WIDTH_EXT                         )

            ,.OCECC_XPI_RD_GRANU                         (OCECC_XPI_RD_GRANU                          )
            ,.OCECC_MR_BNUM_WIDTH                        (OCECC_MR_BNUM_WIDTH                         )
            ,.PHY_DBI_WIDTH                              (PHY_DBI_WIDTH                               )
            ,.CORE_TAG_WIDTH                             (CORE_TAG_WIDTH                              )
            ,.LRANK_BITS                                 (LRANK_BITS                                  )
            ,.BG_BITS                                    (BG_BITS                                     )
            ,.BANK_BITS                                  (BANK_BITS                                   )
            ,.RANKBANK_BITS_FULL                         (RANKBANK_BITS_FULL                          )
            ,.PAGE_BITS                                  (PAGE_BITS                                   )
            ,.BLK_BITS                                   (BLK_BITS                                    )
            ,.CMD_RMW_BITS                               (CMD_RMW_BITS                                )
            ,.RMW_TYPE_BITS                              (RMW_TYPE_BITS                               )
            ,.RANK_BITS                                  (RANK_BITS                                   )
            ,.RANK_BITS_DUP                              (RANK_BITS_DUP                               )
            ,.BG_BITS_DUP                                (BG_BITS_DUP                                 )
            ,.CID_WIDTH                                  (CID_WIDTH                                   )
            ,.CID_WIDTH_DUP                              (CID_WIDTH_DUP                               )
            ,.CORE_ECC_WIDTH_DUP                         (CORE_ECC_WIDTH_DUP                          )

            ,.RETRY_MAX_ADD_RD_LAT                       (RETRY_MAX_ADD_RD_LAT                        )
            ,.RETRY_MAX_ADD_RD_LAT_LG2                   (RETRY_MAX_ADD_RD_LAT_LG2                    )

            ,.WORD_BITS                                  (WORD_BITS                                   )
            ,.COL_BITS                                   (COL_BITS                                    )
            ,.BG_BANK_BITS                               (BG_BANK_BITS                                )
            ,.UMCTL2_SEQ_BURST_MODE                      (UMCTL2_SEQ_BURST_MODE                       )

            ,.MEMC_ECC_SUPPORT                           (MEMC_ECC_SUPPORT                            )
            ,.NUM_RANKS                                  (NUM_RANKS                                   )

            ,.WRDATA_RAM_DEPTH                           (WRDATA_RAM_DEPTH                            )
            ,.ECC_POISON_REG_WIDTH                       (ECC_POISON_REG_WIDTH                        )

            ,.MAX_CMD_NUM                                (MAX_CMD_NUM                                 )
            ,.MAX_NUM_NIBBLES                            (MAX_NUM_NIBBLES                             )
            ,.DRAM_BYTE_NUM                              (DRAM_BYTE_NUM                               )

            )
U_ddrc_dp(
             .core_ddrc_core_clk                         (core_ddrc_core_clk                          )
            ,.core_ddrc_rstn                             (core_ddrc_rstn                              )

            //cpfdpif
            ,.i_ih_wu_cpfdpif                            (cpfdpif                                     )
            ,.i_te_wu_cpfdpif                            (cpfdpif                                     )
            ,.i_te_mr_cpfdpif                            (cpfdpif                                     )
            ,.o_mr_cpfdpif                               (cpfdpif                                     )
            ,.o_wu_cpfdpif                               (cpfdpif                                     )

            //ddrc_cpedpif
            ,.i_gs_mr_ddrc_cpedpif                       (ddrc_cpedpif                                )
            ,.i_pi_dfid_ddrc_cpedpif                     (ddrc_cpedpif                                )
            ,.i_pi_rt_ddrc_cpedpif                       (ddrc_cpedpif                                )
            ,.o_wu_ddrc_cpedpif                          (ddrc_cpedpif                                )
            ,.o_mr_ddrc_cpedpif                          (ddrc_cpedpif                                )

            ,.ddrc_cg_en                                 (ddrc_cg_en                                  )
            ,.reg_ddrc_data_bus_width                    (reg_ddrc_data_bus_width                     )
            ,.reg_ddrc_en_2t_timing_mode                 (reg_ddrc_en_2t_timing_mode                  )
            ,.reg_ddrc_frequency_ratio                   (reg_ddrc_frequency_ratio                    )
            ,.reg_ddrc_lpddr4                            (reg_ddrc_lpddr4                             )
            ,.reg_ddrc_lpddr5                            (reg_ddrc_lpddr5                             )
            ,.ts_pi_mwr                                  (ts_pi_mwr                                   )
            ,.reg_ddrc_lp_optimized_write                (reg_ddrc_lp_optimized_write                 )
            ,.me_mr_rdata                                (me_mr_rdata                                 )
            ,.me_mr_rdata_par                            (me_mr_rdata_par                             )
            ,.write_data_parity_en                       (write_data_parity_en                        )
            ,.reg_ddrc_oc_parity_type                    (reg_ddrc_oc_parity_type                     )
            ,.reg_ddrc_par_poison_en                     (reg_ddrc_par_poison_en                      )
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
            ,.wdata_ocpar_error                          (wdata_ocpar_error                           )
            ,.wdata_ocpar_error_ie                       (wdata_ocpar_error_ie                        )
//spyglass enable_block W528
            ,.mr_me_raddr                                (mr_me_raddr                                 )
            ,.mr_me_re                                   (mr_me_re                                    )
            ,.reg_ddrc_phy_dbi_mode                      (reg_ddrc_phy_dbi_mode                       )
            ,.reg_ddrc_wr_dbi_en                         (reg_ddrc_wr_dbi_en                          )
            ,.reg_ddrc_dm_en                             (reg_ddrc_dm_en                              )
            ,.reg_ddrc_burst_rdwr_int                    (reg_ddrc_burst_rdwr_int[3:0]                )
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4

            ,.reg_ddrc_dfi_twck_en_rd                    (reg_ddrc_dfi_twck_en_rd                     )
            ,.reg_ddrc_dfi_twck_en_wr                    (reg_ddrc_dfi_twck_en_wr                     )
            ,.reg_ddrc_dfi_t_rddata_en                   (reg_ddrc_dfi_t_rddata_en                    )
            ,.reg_ddrc_dfi_tphy_wrlat                    (reg_ddrc_dfi_tphy_wrlat                     )
            ,.reg_ddrc_dfi_tphy_wrdata                   (reg_ddrc_dfi_tphy_wrdata                    )
            ,.reg_ddrc_dfi_lp_en_data                    (reg_ddrc_dfi_lp_en_data                     )
            ,.dfi_cmd_delay                              (dfi_cmd_delay                               )
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: output must always exist
            ,.mr_t_wrdata_add_sdr                        (mr_t_wrdata_add_sdr                         )
//spyglass enable_block W528
            ,.mr_t_wrlat                                 (mr_t_wrlat                                  )
            ,.mr_t_wrdata                                (mr_t_wrdata                                 )
            ,.mr_t_rddata_en                             (mr_t_rddata_en                              )
            ,.mr_lp_data_rd                              (mr_lp_data_rd                               )
            ,.mr_lp_data_wr                              (mr_lp_data_wr                               )
            ,.ocecc_en                                   (ocecc_en                                    )
            ,.ocecc_poison_pgen_mr_ecc                   (ocecc_poison_pgen_mr_ecc                    )
            ,.ocecc_uncorr_err_intr_clr                  (ocecc_uncorr_err_intr_clr                   )
            ,.ocecc_mr_rd_corr_err                       (ocecc_mr_rd_corr_err                        )
            ,.ocecc_mr_rd_uncorr_err                     (ocecc_mr_rd_uncorr_err                      )
            ,.ocecc_mr_rd_byte_num                       (ocecc_mr_rd_byte_num                        )
            ,.ddrc_cmp_en                                (ddrc_cmp_en                                 )
            ,.reg_ddrc_occap_ddrc_data_poison_seq        (reg_ddrc_occap_ddrc_data_poison_seq         )
            ,.reg_ddrc_occap_ddrc_data_poison_parallel   (reg_ddrc_occap_ddrc_data_poison_parallel    )
            ,.reg_ddrc_occap_ddrc_data_poison_err_inj    (reg_ddrc_occap_ddrc_data_poison_err_inj     )
            ,.occap_ddrc_data_err_mr                     (occap_ddrc_data_err_mr                      )
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
            ,.occap_ddrc_data_poison_parallel_err_mr     (occap_ddrc_data_poison_parallel_err_mr      )
            ,.occap_ddrc_data_poison_seq_err_mr          (occap_ddrc_data_poison_seq_err_mr           )
            ,.occap_ddrc_data_poison_complete_mr         (occap_ddrc_data_poison_complete_mr          )
//spyglass enable_block W528

            ,.reg_ddrc_burst_rdwr                        (reg_ddrc_burst_rdwr[3:0]                    )
            ,.reg_ddrc_rd_dbi_en                         (reg_ddrc_rd_dbi_en                          )

            ,.reg_ddrc_oc_parity_en                      (reg_ddrc_oc_parity_en                       )
            ,.reg_ddrc_par_poison_loc_rd_iecc_type       (reg_ddrc_par_poison_loc_rd_iecc_type        )
            ,.reg_ddrc_par_rdata_err_intr_clr            (reg_ddrc_par_rdata_err_intr_clr             )
            ,.par_rdata_in_err_ecc_pulse                 (par_rdata_in_err_ecc_pulse                  )
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in ddrc_assertions module
            ,.rd_wu_rdata_valid                          (rd_wu_rdata_valid                           )
//spyglass enable_block W528
            ,.rd_rw_rdata                                (rd_rw_rdata                                 )
            ,.hif_rdata_token                            (hif_rdata_token                             )
            ,.hif_rdata_addr_err                         (hif_rdata_addr_err                          )
            ,.rt_rd_rd_mrr_ext                           (rt_rd_rd_mrr_ext                            )
            ,.hif_mrr_data                               (hif_mrr_data                                )
            ,.hif_mrr_data_valid                         (hif_mrr_data_valid                          )
            ,.rd_mr4_data_valid                          (rd_mr4_data_valid                           )
            ,.reg_ddrc_mrr_done_clr                      (reg_ddrc_mrr_done_clr                       )
            ,.ddrc_reg_mrr_done                          (ddrc_reg_mrr_done                           )
            ,.ddrc_reg_mrr_data                          (ddrc_reg_mrr_data                           )
            ,.hif_rdata_end                              (hif_rdata_end                               )
            ,.hif_rdata_valid                            (hif_rdata_valid_no_masked                   )
            ,.hif_rdata                                  (hif_rdata                                   )
            ,.hif_rdata_parity                           (hif_rdata_parity                            )
            ,.ocecc_poison_egen_mr_rd_1                  (ocecc_poison_egen_mr_rd_1                   )
            ,.ocecc_poison_egen_mr_rd_1_byte_num         (ocecc_poison_egen_mr_rd_1_byte_num          )
            ,.ocecc_poison_egen_xpi_rd_0                 (ocecc_poison_egen_xpi_rd_0                  )
            ,.ocecc_poison_single                        (ocecc_poison_single                         )
            ,.ocecc_poison_pgen_rd                       (ocecc_poison_pgen_rd                        )
            ,.occap_ddrc_data_err_rd                     (occap_ddrc_data_err_rd                      )
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
            ,.occap_ddrc_data_poison_parallel_err_rd     (occap_ddrc_data_poison_parallel_err_rd      )
            ,.occap_ddrc_data_poison_seq_err_rd          (occap_ddrc_data_poison_seq_err_rd           )
            ,.occap_ddrc_data_poison_complete_rd         (occap_ddrc_data_poison_complete_rd          )
//spyglass enable_block W528

            ,.dfi_rddata_valid                           (dfi_rddata_valid                            )
            ,.dfi_rddata                                 (dfi_rddata                                  )
            ,.dfi_rddata_dbi                             (dfi_rddata_dbi                              )
            ,.dfi_rddata_valid_int                       (dfi_rddata_valid_int                        )
            ,.dfi_rddata_int                             (dfi_rddata_int                              )
            ,.dfi_rddata_dbi_int                         (dfi_rddata_dbi_int                          )

            ,.reg_ddrc_occap_en                          (reg_ddrc_occap_en                           )
            ,.reg_ddrc_occap_en_r                        (reg_ddrc_occap_en_r                         )
            ,.ddrc_occap_rtfifo_parity_err               (ddrc_occap_rtfifo_parity_err                )
            ,.ddrc_occap_rtctrl_parity_err               (ddrc_occap_rtctrl_parity_err                )

            ,.phy_ddrc_rdatavld                          (phy_ddrc_rdatavld                           )
            ,.phy_ddrc_rdbi_n                            (phy_ddrc_rdbi_n                             )
            ,.phy_ddrc_rdata                             (phy_ddrc_rdata                              )
            ,.rt_gs_empty                                (rt_gs_empty                                 )
            ,.rt_gs_empty_delayed                        (rt_gs_empty_delayed                         )

            ,.ddrc_occap_wufifo_parity_err               (ddrc_occap_wufifo_parity_err                )
            ,.ddrc_occap_wuctrl_parity_err               (ddrc_occap_wuctrl_parity_err                )
            ,.hif_wdata_valid                            (hif_wdata_valid                             )
            ,.hif_wdata                                  (hif_wdata                                   )
            ,.hif_wdata_mask                             (hif_wdata_mask                              )
            ,.hif_wdata_parity                           (hif_wdata_parity                            )
            ,.hif_wdata_stall                            (hif_wdata_stall                             )
            ,.hif_wdata_end                              (hif_wdata_end                               )
            ,.mr_wu_free_wr_entry_valid                  (mr_wu_free_wr_entry_valid                   )
            ,.reg_ddrc_burst_mode                        (reg_ddrc_burst_mode                         )
            ,.rw_wu_rdata                                (rw_wu_rdata                                 )
            ,.wu_fifo_empty                              (wu_fifo_empty                               )
            ,.wu_me_wvalid                               (wu_me_wvalid                                )
            ,.wu_me_wmask                                (wu_me_wmask                                 )
            ,.wu_me_wdata                                (wu_me_wdata                                 )
            ,.wu_me_wdata_par                            (wu_me_wdata_par                             )
            ,.wu_me_waddr                                (wu_me_waddr                                 )

            ,.ddrc_occap_dfidata_parity_err              (ddrc_occap_dfidata_parity_err               )
            ,.dfi_wr_q_empty                             (dfi_wr_q_empty                              )
            ,.dfi_wrdata_en                              (dfi_wrdata_en                               )
            ,.dfi_wrdata                                 (dfi_wrdata                                  )
            ,.dfi_wrdata_mask                            (dfi_wrdata_mask                             )
            ,.dfi_rddata_en                              (dfi_rddata_en                               )

            ,.ddrc_occap_eccaccarray_parity_err          (ddrc_occap_eccaccarray_parity_err           )
           ,.dwc_ddrphy_snoop_en                        (dwc_ddrphy_snoop_en)
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
            );
`endif // `ifndef CHB_PVE_MODE
endmodule
//spyglass enable_block W287b

