//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddrctl_apb_slvtop.sv#6 $
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

`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"


module DWC_ddrctl_apb_slvtop
import DWC_ddrctl_reg_pkg::*;
  #(parameter APB_AW  = `UMCTL2_APB_AW,
    parameter APB_DW  = `UMCTL2_APB_DW,
    parameter BCM_F_SYNC_TYPE_C2P = 2,
    parameter BCM_F_SYNC_TYPE_P2C = 2,
    parameter BCM_R_SYNC_TYPE_C2P = 2,
    parameter BCM_R_SYNC_TYPE_P2C = 2,
    parameter REG_OUTPUTS_C2P = 1,
    parameter REG_OUTPUTS_P2C = 1,
    parameter BCM_VERIF_EN    = 1,
    parameter N_REGS  = `UMCTL2_REGS_N_REGS,
    parameter RW_REGS = `UMCTL2_REGS_RW_REGS
    )
   (
    //---APB MASTER INTERFACE---//
    input               pclk,    
    input               presetn,
    input [APB_AW-1:2]  paddr,
    input [APB_DW-1:0]  pwdata,
    input               pwrite,
    input               psel,
    input               penable,
    output              pready,
    output [APB_DW-1:0] prdata,
    output              pslverr
    //--- uMCTL2 INTERFACE ---//
    ,input              core_ddrc_core_clk
    ,input              sync_core_ddrc_rstn
    ,input              core_ddrc_rstn
    ,input               aclk_0
    ,input               sync_aresetn_0
  `ifndef SYNTHESIS
    ,input               aresetn_0
  `endif //SYNTHESIS
    ,input               static_wr_en_core_ddrc_core_clk
    ,input               quasi_dyn_wr_en_core_ddrc_core_clk
//`ifdef UMCTL2_OCECC_EN_1    
//    ,input               quasi_dyn_wr_en_pclk
//`endif //UMCTL2_OCPAR_OR_OCECC_EN_1
    ,input               static_wr_en_aclk_0
    ,input               quasi_dyn_wr_en_aclk_0

    ,input               core_derate_temp_limit_intr

   ,output reg_ddrc_lpddr4 // @core_ddrc_core_clk
   ,output reg_apb_lpddr4 // @pclk 
   ,output reg_arba0_lpddr4 // @aclk_0
   ,output reg_ddrc_lpddr5 // @core_ddrc_core_clk
   ,output reg_apb_lpddr5 // @pclk 
   ,output reg_arba0_lpddr5 // @aclk_0
   ,output reg_ddrc_en_2t_timing_mode // @core_ddrc_core_clk
   ,output reg_apb_en_2t_timing_mode // @pclk 
   ,output reg_arba0_en_2t_timing_mode // @aclk_0
   ,output [1:0] reg_ddrc_data_bus_width // @core_ddrc_core_clk
   ,output [1:0] reg_apb_data_bus_width // @pclk 
   ,output [1:0] reg_arba0_data_bus_width // @aclk_0
   ,output [4:0] reg_ddrc_burst_rdwr // @core_ddrc_core_clk
   ,output [4:0] reg_apb_burst_rdwr // @pclk 
   ,output [4:0] reg_arba0_burst_rdwr // @aclk_0
   ,output reg_ddrc_wck_on // @core_ddrc_core_clk
   ,output reg_ddrc_wck_suspend_en // @core_ddrc_core_clk
   ,output reg_ddrc_ws_off_en // @core_ddrc_core_clk
   ,input [2:0] ddrc_reg_operating_mode // @core_ddrc_core_clk
   ,input [((`DDRCTL_DDR_EN==1) ? (`MEMC_NUM_RANKS*2) : 2)-1:0] ddrc_reg_selfref_type // @core_ddrc_core_clk
   ,input [2:0] ddrc_reg_selfref_state // @core_ddrc_core_clk
   ,input ddrc_reg_selfref_cam_not_empty // @core_ddrc_core_clk
   ,output reg_ddrc_mr_type // @core_ddrc_core_clk
   ,output reg_ddrc_sw_init_int // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_mr_rank // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_mr_addr // @core_ddrc_core_clk
   ,output reg_ddrc_mrr_done_clr // @core_ddrc_core_clk
   ,output reg_ddrc_mr_wr // @core_ddrc_core_clk
   ,output [(`MEMC_PAGE_BITS)-1:0] reg_ddrc_mr_data // @core_ddrc_core_clk
   ,input ddrc_reg_mr_wr_busy // @core_ddrc_core_clk
   ,input ddrc_reg_mrr_done // @core_ddrc_core_clk
   ,input [31:0] ddrc_reg_mrr_data_lwr // @core_ddrc_core_clk
   ,input [31:0] ddrc_reg_mrr_data_upr // @core_ddrc_core_clk
   ,output reg_ddrc_derate_enable // @core_ddrc_core_clk
   ,output reg_ddrc_lpddr4_refresh_mode // @core_ddrc_core_clk
   ,output reg_ddrc_derate_mr4_pause_fc // @core_ddrc_core_clk
   ,output reg_ddrc_dis_trefi_x6x8 // @core_ddrc_core_clk
   ,output reg_ddrc_dis_trefi_x0125 // @core_ddrc_core_clk
   ,output [(`MEMC_DRAM_TOTAL_DATA_WIDTH/4)-1:0] reg_ddrc_active_derate_byte_rank0 // @core_ddrc_core_clk
   ,output reg_ddrc_derate_temp_limit_intr_en // @pclk
   ,output reg_ddrc_derate_temp_limit_intr_clr // @pclk
   ,output reg_ddrc_derate_temp_limit_intr_force // @pclk
   ,output reg_ddrc_derate_mr4_tuf_dis // @core_ddrc_core_clk
   ,input ddrc_reg_derate_temp_limit_intr // @pclk
   ,output [2:0] reg_ddrc_dbg_mr4_grp_sel // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dbg_mr4_rank_sel // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte0 // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte1 // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte2 // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte3 // @core_ddrc_core_clk
   ,output [((`DDRCTL_DDR_EN==1) ? `MEMC_NUM_RANKS : 1)-1:0] reg_ddrc_selfref_en // @core_ddrc_core_clk
   ,output [((`DDRCTL_DDR_EN==1) ? `MEMC_NUM_RANKS : 1)-1:0] reg_ddrc_powerdown_en // @core_ddrc_core_clk
   ,output reg_ddrc_en_dfi_dram_clk_disable // @core_ddrc_core_clk
   ,output reg_ddrc_selfref_sw // @core_ddrc_core_clk
   ,output reg_ddrc_stay_in_selfref // @core_ddrc_core_clk
   ,output reg_ddrc_dis_cam_drain_selfref // @core_ddrc_core_clk
   ,output reg_ddrc_lpddr4_sr_allowed // @core_ddrc_core_clk
   ,output reg_ddrc_dsm_en // @core_ddrc_core_clk
   ,output reg_ddrc_hw_lp_en // @core_ddrc_core_clk
   ,output reg_ddrc_hw_lp_exit_idle_en // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_bsm_clk_on // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_refresh_burst // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_auto_refab_en // @core_ddrc_core_clk
   ,output reg_ddrc_per_bank_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_refresh_update_level // @core_ddrc_core_clk
   ,output reg_ddrc_zq_resistor_shared // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_zq // @core_ddrc_core_clk
   ,output reg_ddrc_zq_reset // @core_ddrc_core_clk
   ,output reg_ddrc_dis_srx_zqcl // @core_ddrc_core_clk
   ,input ddrc_reg_zq_reset_busy // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dqsosc_runtime // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wck2dqo_runtime // @core_ddrc_core_clk
   ,input [2:0] ddrc_reg_dqsosc_state // @core_ddrc_core_clk
   ,input [(`MEMC_NUM_RANKS)-1:0] ddrc_reg_dqsosc_per_rank_stat // @core_ddrc_core_clk
   ,output reg_ddrc_dis_dqsosc_srx // @core_ddrc_core_clk
   ,output reg_ddrc_prefer_write // @core_ddrc_core_clk
   ,output reg_ddrc_pageclose // @core_ddrc_core_clk
   ,output reg_ddrc_opt_wrcam_fill_level // @core_ddrc_core_clk
   ,output reg_ddrc_dis_opt_ntt_by_act // @core_ddrc_core_clk
   ,output reg_ddrc_dis_opt_ntt_by_pre // @core_ddrc_core_clk
   ,output reg_ddrc_autopre_rmw // @core_ddrc_core_clk
   ,output [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_lpr_num_entries // @core_ddrc_core_clk
   ,output reg_ddrc_lpddr4_opt_act_timing // @core_ddrc_core_clk
   ,output reg_ddrc_lpddr5_opt_act_timing // @core_ddrc_core_clk
   ,output reg_ddrc_prefer_read // @core_ddrc_core_clk
   ,output reg_ddrc_dis_speculative_act // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_delay_switch_write // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_page_hit_limit_wr // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_page_hit_limit_rd // @core_ddrc_core_clk
   ,output reg_ddrc_opt_hit_gt_hpr // @core_ddrc_core_clk
   ,output [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wrcam_lowthresh // @core_ddrc_core_clk
   ,output [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wrcam_highthresh // @core_ddrc_core_clk
   ,output [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wr_pghit_num_thresh // @core_ddrc_core_clk
   ,output [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_rd_pghit_num_thresh // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd_act_idle_gap // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr_act_idle_gap // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd_page_exp_cycles // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr_page_exp_cycles // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_pd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_sr // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_dsm // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_data // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_data_req_en // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_phyupd_en // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd_pre_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_init_complete_en // @core_ddrc_core_clk
   ,output reg_ddrc_phy_dbi_mode // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_data_cs_polarity // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_init_start // @core_ddrc_core_clk
   ,output reg_ddrc_lp_optimized_write // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_frequency // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dfi_freq_fsp // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dfi_channel_mode // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_init_complete // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_lp_ctrl_ack_stat // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_lp_data_ack_stat // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_phymstr_en // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_phymstr_blk_ref_x32 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_dfi0_ctrlmsg_data // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi0_ctrlmsg_cmd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi0_ctrlmsg_tout_clr // @core_ddrc_core_clk
   ,output reg_ddrc_dfi0_ctrlmsg_req // @core_ddrc_core_clk
   ,input ddrc_reg_dfi0_ctrlmsg_req_busy // @core_ddrc_core_clk
   ,input ddrc_reg_dfi0_ctrlmsg_resp_tout // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_clr // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_clr // @core_ddrc_core_clk
   ,input ddrc_reg_wr_poison_intr_0 // @core_ddrc_core_clk
   ,input ddrc_reg_rd_poison_intr_0 // @core_ddrc_core_clk
   ,output reg_ddrc_dis_wc // @core_ddrc_core_clk
   ,output reg_ddrc_dis_dq // @core_ddrc_core_clk
   ,output reg_ddrc_dis_hif // @core_ddrc_core_clk
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_hpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_lpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_WRCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_w_q_depth // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_stall // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_rd_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_wr_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_rd_data_pipeline_empty // @core_ddrc_core_clk
   ,input ddrc_reg_wr_data_pipeline_empty // @core_ddrc_core_clk
   ,output reg_ddrc_zq_calib_short // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd // @core_ddrc_core_clk
   ,input ddrc_reg_zq_calib_short_busy // @core_ddrc_core_clk
   ,input ddrc_reg_ctrlupd_busy // @core_ddrc_core_clk
   ,output reg_ddrc_rank0_refresh // @core_ddrc_core_clk
   ,input ddrc_reg_rank0_refresh_busy // @core_ddrc_core_clk
   ,output reg_ddrc_sw_done // @pclk
   ,input ddrc_reg_sw_done_ack // @core_ddrc_core_clk
   ,output reg_ddrc_dm_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_dbi_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_dbi_en // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_wr_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_rd_odt // @core_ddrc_core_clk
   ,output reg_ddrc_rd_data_copy_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_data_copy_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_data_x_en // @core_ddrc_core_clk
   ,output reg_ddrc_sw_static_unlock // @pclk
   ,output [12:0] reg_ddrc_pre_cke_x1024 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_post_cke_x1024 // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_skip_dram_init // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dram_rstn_x1024 // @core_ddrc_core_clk
   ,input [31:0] ddrc_reg_ver_number // @pclk
   ,input [31:0] ddrc_reg_ver_type // @pclk
   ,output [5:0] reg_ddrc_addrmap_bank_b0_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b1_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b2_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bg_b0_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bg_b1_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b7_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b8_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b9_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b10_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b3_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b4_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b5_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b6_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b14_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b15_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b16_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b17_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b10_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b11_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b12_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b13_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b6_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b7_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b8_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b9_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b2_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b3_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b4_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b5_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b0_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b1_map0 // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_nonbinary_device_density_map0 // @core_ddrc_core_clk
   ,output reg_arb_go2critical_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_pagematch_limit_port0 // @core_ddrc_core_clk
   ,output [9:0] reg_arb_rd_port_priority_port0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_aging_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_urgent_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_pagematch_en_port0 // @core_ddrc_core_clk
   ,output [9:0] reg_arb_wr_port_priority_port0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_aging_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_urgent_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_pagematch_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_port_en_port0 // @core_ddrc_core_clk
   ,output reg_apb_port_en_port0 // @pclk 
   ,output reg_arba0_port_en_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_MLW)-1:0] reg_arba0_rqos_map_level1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region0_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutb_port0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutr_port0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level2_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region0_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region2_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout1_port0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout2_port0 // @core_ddrc_core_clk
   ,input arb_reg_rd_port_busy_0_port0 // @aclk_0
   ,input arb_reg_wr_port_busy_0_port0 // @aclk_0
   ,output [7:0] reg_ddrc_t_ras_min_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_ras_max_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_faw_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr2pre_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_rc_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2pre_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_xp_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr2rd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2wr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_read_latency_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_write_latency_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr2mr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2mr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_mr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_rp_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_rrd_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_ccd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_rcd_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_cke_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_ckesr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_cksre_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_cksrx_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_ckcsx_freq0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_csh_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr2rd_s_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_rrd_s_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_ccd_s_freq0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_cmdcke_freq0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_t_ppd_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_ccd_mw_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_odtloff_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_xsr_freq0 // @core_ddrc_core_clk
   ,output [8:0] reg_ddrc_t_osco_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_pdn_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_xsr_dsm_x1024_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_max_wr_sync_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_max_rd_sync_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2wr_s_freq0 // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_bank_org_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rda2pre_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wra2pre_freq0 // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_mrr2rd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_mrr2wr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_mrr2mrw_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr3_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr2_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr5_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr4_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr6_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr22_freq0 // @core_ddrc_core_clk
   ,output [((`DDRCTL_DDR_DUAL_CHANNEL_EN==1) ? 7 : 6)-1:0] reg_ddrc_dfi_tphy_wrlat_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_tphy_wrdata_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_dfi_t_rddata_en_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_ctrl_delay_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_enable_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_disable_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_wrdata_delay_freq0 // @core_ddrc_core_clk
   ,output [((`DDRCTL_DDR_DUAL_CHANNEL_EN==1) ? 7 : 6)-1:0] reg_ddrc_dfi_tphy_wrcslat_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_dfi_tphy_rdcslat_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_twck_delay_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_dis_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_en_wr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_en_rd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_toggle_post_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_toggle_cs_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_toggle_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_fast_toggle_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_pd_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_sr_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_dsm_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_data_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_tlp_resp_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_min_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_max_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlmsg_resp_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_refi_x1_x32_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_refresh_to_x1_x32_freq0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_refresh_margin_freq0 // @core_ddrc_core_clk
   ,output reg_ddrc_t_refi_x1_sel_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_rfc_min_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_rfc_min_ab_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_pbr2pbr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_pbr2act_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_refresh_to_ab_x32_freq0 // @core_ddrc_core_clk
   ,output [13:0] reg_ddrc_t_zq_long_nop_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_zq_short_nop_freq0 // @core_ddrc_core_clk
   ,output [19:0] reg_ddrc_t_zq_short_interval_x1024_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_zq_reset_nop_freq0 // @core_ddrc_core_clk
   ,output reg_ddrc_dqsosc_enable_freq0 // @core_ddrc_core_clk
   ,output reg_ddrc_dqsosc_interval_unit_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_dqsosc_interval_freq0 // @core_ddrc_core_clk
   ,output [31:0] reg_ddrc_mr4_read_interval_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_derated_t_rrd_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_derated_t_rp_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_derated_t_ras_min_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_derated_t_rcd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_derated_t_rc_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_hw_lp_idle_x32_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_pageclose_timer_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_rdwr_idle_gap_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_hpr_max_starve_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_hpr_xact_run_length_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_lpr_max_starve_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_lpr_xact_run_length_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_w_max_starve_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_w_xact_run_length_freq0 // @core_ddrc_core_clk
   ,output reg_ddrc_frequency_ratio_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_powerdown_to_x32_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_selfref_to_x32_freq0 // @core_ddrc_core_clk


    ,output                derate_sync_ack_c2p
    ,output                derate_temp_limit_intr_out
    ,output                derate_temp_limit_intr_ret
    ,output [1:0]          derate_temp_limit_intr_fault

    );

   localparam REG_WIDTH = `UMCTL2_REGS_REG_WIDTH;

   localparam N_APBFSMSTAT=
                           8;

   // No of bits in the one-hot addr
   localparam RWSELWIDTH = RW_REGS;
      
   wire [N_APBFSMSTAT-1:0] apb_slv_cs_unused;
   wire [N_APBFSMSTAT-1:0] apb_slv_ns;
   wire                    write_en_s0;
   wire                    recalc_parity;
   wire [RWSELWIDTH-1:0]   rwselect;
   wire                    fwd_reset_val;
   wire                    write_en_pulse;
   wire                    write_en;
   wire                    store_rqst;
   wire                    set_async_reg;
   wire                    ack_async_reg;
   
  wire pclk_derate_temp_limit_intr;
  reg  r_derate_temp_limit_intr;
  reg  r_derate_temp_limit_intr_fault;

  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      r_derate_temp_limit_intr_fault <= 1'b0;
    end
    else if (pclk_derate_temp_limit_intr | (r_derate_temp_limit_intr_fault & ~reg_ddrc_derate_temp_limit_intr_clr)) begin
      r_derate_temp_limit_intr_fault <= 1'b1;
    end
    else begin
      r_derate_temp_limit_intr_fault <= 1'b0;
    end
  end
 
  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      r_derate_temp_limit_intr <= 1'b0;
    end
    else if (pclk_derate_temp_limit_intr | reg_ddrc_derate_temp_limit_intr_force | (r_derate_temp_limit_intr & ~reg_ddrc_derate_temp_limit_intr_clr)) begin
      r_derate_temp_limit_intr <= 1'b1;
    end
    else begin
      r_derate_temp_limit_intr <= 1'b0;
    end
  end

  assign derate_temp_limit_intr_ret   = r_derate_temp_limit_intr; // Passed to DERATESTAT.derate_temp_limit_intr status register through TOP 
  //assign derate_temp_limit_intr_out   = r_derate_temp_limit_intr & reg_ddrc_derate_temp_limit_intr_en;
  //assign derate_temp_limit_intr_fault = r_derate_temp_limit_intr_fault;
    DWC_ddrctl_antivalent_reg
     U_derate_temp_limit_intr_fault (
       .clk                       (pclk)
      ,.rstn                      (presetn)
      ,.fault_intr                (r_derate_temp_limit_intr_fault)
      ,.intr                      (r_derate_temp_limit_intr)
      ,.intr_en                   (reg_ddrc_derate_temp_limit_intr_en)
      ,.antivalent_fault_intr_out (derate_temp_limit_intr_fault)
      ,.intr_out                  (derate_temp_limit_intr_out)
    );    
 












   wire [REG_WIDTH -1:0] r0_mstr0;
   wire r0_mstr0_ack_pclk;
   wire r0_mstr0_ack_pclk_i;
   wire r0_mstr0_ack_arba0_pclk_i;
   wire [REG_WIDTH -1:0] r4_mstr4;
   wire r4_mstr4_ack_pclk;
   wire [REG_WIDTH -1:0] r5_stat;
   wire [REG_WIDTH -1:0] r8_mrctrl0;
   wire r8_mrctrl0_ack_pclk;
   wire reg_ddrc_mrr_done_clr_ack_pclk;
   wire reg_ddrc_mr_wr_ack_pclk;
   wire ff_regb_ddrc_ch0_mr_wr_saved;
   wire [REG_WIDTH -1:0] r9_mrctrl1;
   wire r9_mrctrl1_ack_pclk;
   wire [REG_WIDTH -1:0] r11_mrstat;
   wire ddrc_reg_mr_wr_busy_int;
   wire [REG_WIDTH -1:0] r12_mrrdata0;
   wire [REG_WIDTH -1:0] r13_mrrdata1;
   wire [REG_WIDTH -1:0] r14_deratectl0;
   wire r14_deratectl0_ack_pclk;
   wire [REG_WIDTH -1:0] r15_deratectl1;
   wire r15_deratectl1_ack_pclk;
   wire [REG_WIDTH -1:0] r19_deratectl5;
   wire reg_ddrc_derate_temp_limit_intr_clr_ack_pclk;
   wire reg_ddrc_derate_temp_limit_intr_force_ack_pclk;
   wire [REG_WIDTH -1:0] r20_deratectl6;
   wire [REG_WIDTH -1:0] r21_deratestat0;
   wire [REG_WIDTH -1:0] r23_deratedbgctl;
   wire r23_deratedbgctl_ack_pclk;
   wire [REG_WIDTH -1:0] r24_deratedbgstat;
   wire [REG_WIDTH -1:0] r25_pwrctl;
   wire r25_pwrctl_ack_pclk;
   wire [REG_WIDTH -1:0] r26_hwlpctl;
   wire [REG_WIDTH -1:0] r28_clkgatectl;
   wire r28_clkgatectl_ack_pclk;
   wire [REG_WIDTH -1:0] r29_rfshmod0;
   wire r29_rfshmod0_ack_pclk;
   wire [REG_WIDTH -1:0] r31_rfshctl0;
   wire r31_rfshctl0_ack_pclk;
   wire [REG_WIDTH -1:0] r34_zqctl0;
   wire r34_zqctl0_ack_pclk;
   wire [REG_WIDTH -1:0] r35_zqctl1;
   wire r35_zqctl1_ack_pclk;
   wire reg_ddrc_zq_reset_ack_pclk;
   wire ff_regb_ddrc_ch0_zq_reset_saved;
   wire [REG_WIDTH -1:0] r36_zqctl2;
   wire [REG_WIDTH -1:0] r37_zqstat;
   wire ddrc_reg_zq_reset_busy_int;
   wire [REG_WIDTH -1:0] r38_dqsoscruntime;
   wire [REG_WIDTH -1:0] r39_dqsoscstat0;
   wire [REG_WIDTH -1:0] r40_dqsosccfg0;
   wire [REG_WIDTH -1:0] r42_sched0;
   wire [REG_WIDTH -1:0] r43_sched1;
   wire [REG_WIDTH -1:0] r45_sched3;
   wire [REG_WIDTH -1:0] r46_sched4;
   wire [REG_WIDTH -1:0] r56_dfilpcfg0;
   wire r56_dfilpcfg0_ack_pclk;
   wire [REG_WIDTH -1:0] r57_dfiupd0;
   wire r57_dfiupd0_ack_pclk;
   wire [REG_WIDTH -1:0] r59_dfimisc;
   wire r59_dfimisc_ack_pclk;
   wire [REG_WIDTH -1:0] r60_dfistat;
   wire [REG_WIDTH -1:0] r61_dfiphymstr;
   wire r61_dfiphymstr_ack_pclk;
   wire [REG_WIDTH -1:0] r62_dfi0msgctl0;
   wire r62_dfi0msgctl0_ack_pclk;
   wire reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk;
   wire reg_ddrc_dfi0_ctrlmsg_req_ack_pclk;
   wire ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved;
   wire [REG_WIDTH -1:0] r63_dfi0msgstat0;
   wire ddrc_reg_dfi0_ctrlmsg_req_busy_int;
   wire [REG_WIDTH -1:0] r64_poisoncfg;
   wire r64_poisoncfg_ack_pclk;
   wire reg_ddrc_wr_poison_intr_clr_ack_pclk;
   wire reg_ddrc_rd_poison_intr_clr_ack_pclk;
   wire [REG_WIDTH -1:0] r65_poisonstat;
   wire [REG_WIDTH -1:0] r215_opctrl0;
   wire [REG_WIDTH -1:0] r216_opctrl1;
   wire r216_opctrl1_ack_pclk;
   wire [REG_WIDTH -1:0] r217_opctrlcam;
   wire [REG_WIDTH -1:0] r218_opctrlcmd;
   wire r218_opctrlcmd_ack_pclk;
   wire reg_ddrc_zq_calib_short_ack_pclk;
   wire ff_regb_ddrc_ch0_zq_calib_short_saved;
   wire reg_ddrc_ctrlupd_ack_pclk;
   wire ff_regb_ddrc_ch0_ctrlupd_saved;
   wire [REG_WIDTH -1:0] r219_opctrlstat;
   wire ddrc_reg_zq_calib_short_busy_int;
   wire ddrc_reg_ctrlupd_busy_int;
   wire [REG_WIDTH -1:0] r221_oprefctrl0;
   wire r221_oprefctrl0_ack_pclk;
   wire reg_ddrc_rank0_refresh_ack_pclk;
   wire ff_regb_ddrc_ch0_rank0_refresh_saved;
   wire [REG_WIDTH -1:0] r223_oprefstat0;
   wire ddrc_reg_rank0_refresh_busy_int;
   wire [REG_WIDTH -1:0] r225_swctl;
   wire [REG_WIDTH -1:0] r226_swstat;
   wire [REG_WIDTH -1:0] r230_dbictl;
   wire r230_dbictl_ack_pclk;
   wire [REG_WIDTH -1:0] r232_odtmap;
   wire [REG_WIDTH -1:0] r233_datactl0;
   wire r233_datactl0_ack_pclk;
   wire [REG_WIDTH -1:0] r234_swctlstatic;
   wire [REG_WIDTH -1:0] r235_inittmg0;
   wire r235_inittmg0_ack_pclk;
   wire [REG_WIDTH -1:0] r236_inittmg1;
   wire r236_inittmg1_ack_pclk;
   wire [REG_WIDTH -1:0] r263_ddrctl_ver_number;
   wire [REG_WIDTH -1:0] r264_ddrctl_ver_type;
   wire [REG_WIDTH -1:0] r450_addrmap3_map0;
   wire [REG_WIDTH -1:0] r451_addrmap4_map0;
   wire [REG_WIDTH -1:0] r452_addrmap5_map0;
   wire [REG_WIDTH -1:0] r453_addrmap6_map0;
   wire [REG_WIDTH -1:0] r454_addrmap7_map0;
   wire [REG_WIDTH -1:0] r455_addrmap8_map0;
   wire [REG_WIDTH -1:0] r456_addrmap9_map0;
   wire [REG_WIDTH -1:0] r457_addrmap10_map0;
   wire [REG_WIDTH -1:0] r458_addrmap11_map0;
   wire [REG_WIDTH -1:0] r459_addrmap12_map0;
   wire r459_addrmap12_map0_ack_pclk;
   wire [REG_WIDTH -1:0] r474_pccfg_port0;
   wire [REG_WIDTH -1:0] r475_pcfgr_port0;
   wire [REG_WIDTH -1:0] r476_pcfgw_port0;
   wire [REG_WIDTH -1:0] r509_pctrl_port0;
   wire r509_pctrl_port0_ack_pclk;
   wire r509_pctrl_port0_ack_pclk_i;
   wire r509_pctrl_port0_ack_arba0_pclk_i;
   wire [REG_WIDTH -1:0] r510_pcfgqos0_port0;
   wire [REG_WIDTH -1:0] r511_pcfgqos1_port0;
   wire [REG_WIDTH -1:0] r512_pcfgwqos0_port0;
   wire [REG_WIDTH -1:0] r513_pcfgwqos1_port0;
   wire [REG_WIDTH -1:0] r535_pstat_port0;
   wire [REG_WIDTH -1:0] r1882_dramset1tmg0_freq0;
   wire [REG_WIDTH -1:0] r1883_dramset1tmg1_freq0;
   wire [REG_WIDTH -1:0] r1884_dramset1tmg2_freq0;
   wire [REG_WIDTH -1:0] r1885_dramset1tmg3_freq0;
   wire [REG_WIDTH -1:0] r1886_dramset1tmg4_freq0;
   wire [REG_WIDTH -1:0] r1887_dramset1tmg5_freq0;
   wire r1887_dramset1tmg5_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1888_dramset1tmg6_freq0;
   wire [REG_WIDTH -1:0] r1889_dramset1tmg7_freq0;
   wire r1889_dramset1tmg7_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1891_dramset1tmg9_freq0;
   wire [REG_WIDTH -1:0] r1894_dramset1tmg12_freq0;
   wire [REG_WIDTH -1:0] r1895_dramset1tmg13_freq0;
   wire [REG_WIDTH -1:0] r1896_dramset1tmg14_freq0;
   wire [REG_WIDTH -1:0] r1905_dramset1tmg23_freq0;
   wire r1905_dramset1tmg23_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1906_dramset1tmg24_freq0;
   wire [REG_WIDTH -1:0] r1907_dramset1tmg25_freq0;
   wire [REG_WIDTH -1:0] r1912_dramset1tmg30_freq0;
   wire r1912_dramset1tmg30_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1938_initmr0_freq0;
   wire [REG_WIDTH -1:0] r1939_initmr1_freq0;
   wire r1939_initmr1_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1940_initmr2_freq0;
   wire [REG_WIDTH -1:0] r1941_initmr3_freq0;
   wire [REG_WIDTH -1:0] r1942_dfitmg0_freq0;
   wire r1942_dfitmg0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1943_dfitmg1_freq0;
   wire r1943_dfitmg1_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1944_dfitmg2_freq0;
   wire [REG_WIDTH -1:0] r1946_dfitmg4_freq0;
   wire [REG_WIDTH -1:0] r1947_dfitmg5_freq0;
   wire [REG_WIDTH -1:0] r1949_dfilptmg0_freq0;
   wire r1949_dfilptmg0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1950_dfilptmg1_freq0;
   wire r1950_dfilptmg1_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1951_dfiupdtmg0_freq0;
   wire r1951_dfiupdtmg0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1952_dfiupdtmg1_freq0;
   wire [REG_WIDTH -1:0] r1953_dfimsgtmg0_freq0;
   wire [REG_WIDTH -1:0] r1955_rfshset1tmg0_freq0;
   wire r1955_rfshset1tmg0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1956_rfshset1tmg1_freq0;
   wire r1956_rfshset1tmg1_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1957_rfshset1tmg2_freq0;
   wire r1957_rfshset1tmg2_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1958_rfshset1tmg3_freq0;
   wire r1958_rfshset1tmg3_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1975_zqset1tmg0_freq0;
   wire r1975_zqset1tmg0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1976_zqset1tmg1_freq0;
   wire [REG_WIDTH -1:0] r1985_dqsoscctl0_freq0;
   wire r1985_dqsoscctl0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1986_derateint_freq0;
   wire [REG_WIDTH -1:0] r1987_derateval0_freq0;
   wire r1987_derateval0_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1988_derateval1_freq0;
   wire r1988_derateval1_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1989_hwlptmg0_freq0;
   wire [REG_WIDTH -1:0] r1990_schedtmg0_freq0;
   wire [REG_WIDTH -1:0] r1991_perfhpr1_freq0;
   wire [REG_WIDTH -1:0] r1992_perflpr1_freq0;
   wire [REG_WIDTH -1:0] r1993_perfwr1_freq0;
   wire [REG_WIDTH -1:0] r1994_tmgcfg_freq0;
   wire r1994_tmgcfg_freq0_ack_pclk;
   wire [REG_WIDTH -1:0] r1997_pwrtmg_freq0;

   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS
   // Assertions for ddrc_reg_mr_wr_busy register
   // ddrc_reg_mr_wr_busy_ahead only goes 0 to 1 when reg_ddrc_mr_wr_pclk goes 0 to 1 on previous clk
   property p_ddrc_reg_mr_wr_busy_ahead_rise;
      @(posedge pclk) disable iff(!presetn)
      $past($rose(coreif.reg_ddrc_mr_wr_pclk) && ~slvif.ff_regb_ddrc_ch0_mr_wr_saved) |-> $rose(coreif.ddrc_reg_mr_wr_busy_ahead);
   endproperty

//   a_ddrc_reg_mr_wr_busy_ahead_rise : assert property (p_ddrc_reg_mr_wr_busy_ahead_rise) else
//      $display("-> %0t ERROR: APB ddrc_reg_mr_wr_busy_ahead goes 0 to 1 without reg_ddrc_mr_wr_pclk !!!", $realtime);

   // Assertions for ddrc_reg_zq_reset_busy register
   // ddrc_reg_zq_reset_busy_ahead only goes 0 to 1 when reg_ddrc_zq_reset_pclk goes 0 to 1 on previous clk
   property p_ddrc_reg_zq_reset_busy_ahead_rise;
      @(posedge pclk) disable iff(!presetn)
      $past($rose(coreif.reg_ddrc_zq_reset_pclk) && ~slvif.ff_regb_ddrc_ch0_zq_reset_saved) |-> $rose(coreif.ddrc_reg_zq_reset_busy_ahead);
   endproperty

//   a_ddrc_reg_zq_reset_busy_ahead_rise : assert property (p_ddrc_reg_zq_reset_busy_ahead_rise) else
//      $display("-> %0t ERROR: APB ddrc_reg_zq_reset_busy_ahead goes 0 to 1 without reg_ddrc_zq_reset_pclk !!!", $realtime);

   // Assertions for ddrc_reg_dfi0_ctrlmsg_req_busy register
   // ddrc_reg_dfi0_ctrlmsg_req_busy_ahead only goes 0 to 1 when reg_ddrc_dfi0_ctrlmsg_req_pclk goes 0 to 1 on previous clk
   property p_ddrc_reg_dfi0_ctrlmsg_req_busy_ahead_rise;
      @(posedge pclk) disable iff(!presetn)
      $past($rose(coreif.reg_ddrc_dfi0_ctrlmsg_req_pclk) && ~slvif.ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved) |-> $rose(coreif.ddrc_reg_dfi0_ctrlmsg_req_busy_ahead);
   endproperty

//   a_ddrc_reg_dfi0_ctrlmsg_req_busy_ahead_rise : assert property (p_ddrc_reg_dfi0_ctrlmsg_req_busy_ahead_rise) else
//      $display("-> %0t ERROR: APB ddrc_reg_dfi0_ctrlmsg_req_busy_ahead goes 0 to 1 without reg_ddrc_dfi0_ctrlmsg_req_pclk !!!", $realtime);

   // Assertions for ddrc_reg_zq_calib_short_busy register
   // ddrc_reg_zq_calib_short_busy_ahead only goes 0 to 1 when reg_ddrc_zq_calib_short_pclk goes 0 to 1 on previous clk
   property p_ddrc_reg_zq_calib_short_busy_ahead_rise;
      @(posedge pclk) disable iff(!presetn)
      $past($rose(coreif.reg_ddrc_zq_calib_short_pclk) && ~slvif.ff_regb_ddrc_ch0_zq_calib_short_saved) |-> $rose(coreif.ddrc_reg_zq_calib_short_busy_ahead);
   endproperty

//   a_ddrc_reg_zq_calib_short_busy_ahead_rise : assert property (p_ddrc_reg_zq_calib_short_busy_ahead_rise) else
//      $display("-> %0t ERROR: APB ddrc_reg_zq_calib_short_busy_ahead goes 0 to 1 without reg_ddrc_zq_calib_short_pclk !!!", $realtime);

   // Assertions for ddrc_reg_ctrlupd_busy register
   // ddrc_reg_ctrlupd_busy_ahead only goes 0 to 1 when reg_ddrc_ctrlupd_pclk goes 0 to 1 on previous clk
   property p_ddrc_reg_ctrlupd_busy_ahead_rise;
      @(posedge pclk) disable iff(!presetn)
      $past($rose(coreif.reg_ddrc_ctrlupd_pclk) && ~slvif.ff_regb_ddrc_ch0_ctrlupd_saved) |-> $rose(coreif.ddrc_reg_ctrlupd_busy_ahead);
   endproperty

//   a_ddrc_reg_ctrlupd_busy_ahead_rise : assert property (p_ddrc_reg_ctrlupd_busy_ahead_rise) else
//      $display("-> %0t ERROR: APB ddrc_reg_ctrlupd_busy_ahead goes 0 to 1 without reg_ddrc_ctrlupd_pclk !!!", $realtime);

   // Assertions for ddrc_reg_rank0_refresh_busy register
   // ddrc_reg_rank0_refresh_busy_ahead only goes 0 to 1 when reg_ddrc_rank0_refresh_pclk goes 0 to 1 on previous clk
   property p_ddrc_reg_rank0_refresh_busy_ahead_rise;
      @(posedge pclk) disable iff(!presetn)
      $past($rose(coreif.reg_ddrc_rank0_refresh_pclk) && ~slvif.ff_regb_ddrc_ch0_rank0_refresh_saved) |-> $rose(coreif.ddrc_reg_rank0_refresh_busy_ahead);
   endproperty

//   a_ddrc_reg_rank0_refresh_busy_ahead_rise : assert property (p_ddrc_reg_rank0_refresh_busy_ahead_rise) else
//      $display("-> %0t ERROR: APB ddrc_reg_rank0_refresh_busy_ahead goes 0 to 1 without reg_ddrc_rank0_refresh_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON


//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation.
   assign set_async_reg = (1'b0
                        | rwselect[0] // REGB_DDRC_CH0 MSTR0
                        | rwselect[4] // REGB_DDRC_CH0 MSTR4
                        | rwselect[5] // REGB_DDRC_CH0 MRCTRL0
                        | rwselect[6] // REGB_DDRC_CH0 MRCTRL1
                        | rwselect[8] // REGB_DDRC_CH0 DERATECTL0
                        | rwselect[9] // REGB_DDRC_CH0 DERATECTL1
                        | rwselect[15] // REGB_DDRC_CH0 DERATEDBGCTL
                        | rwselect[16] // REGB_DDRC_CH0 PWRCTL
                        | rwselect[19] // REGB_DDRC_CH0 CLKGATECTL
                        | rwselect[20] // REGB_DDRC_CH0 RFSHMOD0
                        | rwselect[22] // REGB_DDRC_CH0 RFSHCTL0
                        | rwselect[25] // REGB_DDRC_CH0 ZQCTL0
                        | rwselect[26] // REGB_DDRC_CH0 ZQCTL1
                        | rwselect[44] // REGB_DDRC_CH0 DFILPCFG0
                        | rwselect[45] // REGB_DDRC_CH0 DFIUPD0
                        | rwselect[47] // REGB_DDRC_CH0 DFIMISC
                        | rwselect[48] // REGB_DDRC_CH0 DFIPHYMSTR
                        | rwselect[49] // REGB_DDRC_CH0 DFI0MSGCTL0
                        | rwselect[50] // REGB_DDRC_CH0 POISONCFG
                        | rwselect[123] // REGB_DDRC_CH0 OPCTRL1
                        | rwselect[124] // REGB_DDRC_CH0 OPCTRLCMD
                        | rwselect[125] // REGB_DDRC_CH0 OPREFCTRL0
                        | rwselect[131] // REGB_DDRC_CH0 DBICTL
                        | rwselect[133] // REGB_DDRC_CH0 DATACTL0
                        | rwselect[135] // REGB_DDRC_CH0 INITTMG0
                        | rwselect[136] // REGB_DDRC_CH0 INITTMG1
                        | rwselect[231] // REGB_ADDR_MAP0 ADDRMAP12
                        | rwselect[280] // REGB_ARB_PORT0 PCTRL
                        | rwselect[1476] // REGB_FREQ0_CH0 DRAMSET1TMG5
                        | rwselect[1478] // REGB_FREQ0_CH0 DRAMSET1TMG7
                        | rwselect[1494] // REGB_FREQ0_CH0 DRAMSET1TMG23
                        | rwselect[1501] // REGB_FREQ0_CH0 DRAMSET1TMG30
                        | rwselect[1528] // REGB_FREQ0_CH0 INITMR1
                        | rwselect[1531] // REGB_FREQ0_CH0 DFITMG0
                        | rwselect[1532] // REGB_FREQ0_CH0 DFITMG1
                        | rwselect[1538] // REGB_FREQ0_CH0 DFILPTMG0
                        | rwselect[1539] // REGB_FREQ0_CH0 DFILPTMG1
                        | rwselect[1540] // REGB_FREQ0_CH0 DFIUPDTMG0
                        | rwselect[1544] // REGB_FREQ0_CH0 RFSHSET1TMG0
                        | rwselect[1545] // REGB_FREQ0_CH0 RFSHSET1TMG1
                        | rwselect[1546] // REGB_FREQ0_CH0 RFSHSET1TMG2
                        | rwselect[1547] // REGB_FREQ0_CH0 RFSHSET1TMG3
                        | rwselect[1564] // REGB_FREQ0_CH0 ZQSET1TMG0
                        | rwselect[1574] // REGB_FREQ0_CH0 DQSOSCCTL0
                        | rwselect[1576] // REGB_FREQ0_CH0 DERATEVAL0
                        | rwselect[1577] // REGB_FREQ0_CH0 DERATEVAL1
                        | rwselect[1583] // REGB_FREQ0_CH0 TMGCFG

                           ) & write_en;

   assign ack_async_reg =
                        ( r0_mstr0_ack_pclk) |
                        ( r4_mstr4_ack_pclk) |
                        ( r8_mrctrl0_ack_pclk) |
                        ( r9_mrctrl1_ack_pclk) |
                        ( r14_deratectl0_ack_pclk) |
                        ( r15_deratectl1_ack_pclk) |
                        reg_ddrc_derate_temp_limit_intr_clr_ack_pclk |
                        reg_ddrc_derate_temp_limit_intr_force_ack_pclk |
                        ( r23_deratedbgctl_ack_pclk) |
                        ( r25_pwrctl_ack_pclk) |
                        ( r28_clkgatectl_ack_pclk) |
                        ( r29_rfshmod0_ack_pclk) |
                        ( r31_rfshctl0_ack_pclk) |
                        ( r34_zqctl0_ack_pclk) |
                        ( r35_zqctl1_ack_pclk) |
                        ( r56_dfilpcfg0_ack_pclk) |
                        ( r57_dfiupd0_ack_pclk) |
                        ( r59_dfimisc_ack_pclk) |
                        ( r61_dfiphymstr_ack_pclk) |
                        ( r62_dfi0msgctl0_ack_pclk) |
                        ( r64_poisoncfg_ack_pclk) |
                        ( r216_opctrl1_ack_pclk) |
                        ( r218_opctrlcmd_ack_pclk) |
                        ( r221_oprefctrl0_ack_pclk) |
                        ( r230_dbictl_ack_pclk) |
                        ( r233_datactl0_ack_pclk) |
                        ( r235_inittmg0_ack_pclk) |
                        ( r236_inittmg1_ack_pclk) |
                        ( r459_addrmap12_map0_ack_pclk) |
                        ( r509_pctrl_port0_ack_pclk) |
                        ( r1887_dramset1tmg5_freq0_ack_pclk) |
                        ( r1889_dramset1tmg7_freq0_ack_pclk) |
                        ( r1905_dramset1tmg23_freq0_ack_pclk) |
                        ( r1912_dramset1tmg30_freq0_ack_pclk) |
                        ( r1939_initmr1_freq0_ack_pclk) |
                        ( r1942_dfitmg0_freq0_ack_pclk) |
                        ( r1943_dfitmg1_freq0_ack_pclk) |
                        ( r1949_dfilptmg0_freq0_ack_pclk) |
                        ( r1950_dfilptmg1_freq0_ack_pclk) |
                        ( r1951_dfiupdtmg0_freq0_ack_pclk) |
                        ( r1955_rfshset1tmg0_freq0_ack_pclk) |
                        ( r1956_rfshset1tmg1_freq0_ack_pclk) |
                        ( r1957_rfshset1tmg2_freq0_ack_pclk) |
                        ( r1958_rfshset1tmg3_freq0_ack_pclk) |
                        ( r1975_zqset1tmg0_freq0_ack_pclk) |
                        ( r1985_dqsoscctl0_freq0_ack_pclk) |
                        ( r1987_derateval0_freq0_ack_pclk) |
                        ( r1988_derateval1_freq0_ack_pclk) |
                        ( r1994_tmgcfg_freq0_ack_pclk) |

                           1'b0;
//spyglass enable_block W528

wire              psel_int;
wire              pready_int;
wire              pslverr_int;
wire [APB_DW-1:0] prdata_int;
assign psel_int   = psel;
assign pready     = pready_int;
assign pslverr    = pslverr_int;
assign prdata     = prdata_int;

 wire  apb_secure;
  assign apb_secure = 1'b0;

   // ----------------------------------------------------------------------------
   // The block performs the address decoding and data multiplexing for the local
   // interface and the configuration registers. The input address is decoded to
   // give a one-hot address that selects the respective register from the bank
   // ----------------------------------------------------------------------------
   DWC_ddrctl_apb_adrdec
   
     #(.APB_AW       (APB_AW),
       .APB_DW       (APB_DW),
       .REG_WIDTH    (REG_WIDTH),
       .N_REGS       (N_REGS),
       .RW_REGS      (RW_REGS),
       .RWSELWIDTH   (RWSELWIDTH),
       .N_APBFSMSTAT (N_APBFSMSTAT)
       )
   adrdec
     (.presetn           (presetn),
      .pclk              (pclk),
      .paddr             (paddr),
      .pwrite            (pwrite),
      .psel              (psel_int),
      .apb_secure        (apb_secure),
      .apb_slv_ns        (apb_slv_ns),
      //----------------------------  
      .rwselect          (rwselect),
      .prdata            (prdata_int),
      .pslverr           (pslverr_int)

      ,.r0_mstr0 (r0_mstr0)
      ,.r4_mstr4 (r4_mstr4)
      ,.r5_stat (r5_stat)
      ,.r8_mrctrl0 (r8_mrctrl0)
      ,.r9_mrctrl1 (r9_mrctrl1)
      ,.r11_mrstat (r11_mrstat)
      ,.r12_mrrdata0 (r12_mrrdata0)
      ,.r13_mrrdata1 (r13_mrrdata1)
      ,.r14_deratectl0 (r14_deratectl0)
      ,.r15_deratectl1 (r15_deratectl1)
      ,.r19_deratectl5 (r19_deratectl5)
      ,.r20_deratectl6 (r20_deratectl6)
      ,.r21_deratestat0 (r21_deratestat0)
      ,.r23_deratedbgctl (r23_deratedbgctl)
      ,.r24_deratedbgstat (r24_deratedbgstat)
      ,.r25_pwrctl (r25_pwrctl)
      ,.r26_hwlpctl (r26_hwlpctl)
      ,.r28_clkgatectl (r28_clkgatectl)
      ,.r29_rfshmod0 (r29_rfshmod0)
      ,.r31_rfshctl0 (r31_rfshctl0)
      ,.r34_zqctl0 (r34_zqctl0)
      ,.r35_zqctl1 (r35_zqctl1)
      ,.r36_zqctl2 (r36_zqctl2)
      ,.r37_zqstat (r37_zqstat)
      ,.r38_dqsoscruntime (r38_dqsoscruntime)
      ,.r39_dqsoscstat0 (r39_dqsoscstat0)
      ,.r40_dqsosccfg0 (r40_dqsosccfg0)
      ,.r42_sched0 (r42_sched0)
      ,.r43_sched1 (r43_sched1)
      ,.r45_sched3 (r45_sched3)
      ,.r46_sched4 (r46_sched4)
      ,.r56_dfilpcfg0 (r56_dfilpcfg0)
      ,.r57_dfiupd0 (r57_dfiupd0)
      ,.r59_dfimisc (r59_dfimisc)
      ,.r60_dfistat (r60_dfistat)
      ,.r61_dfiphymstr (r61_dfiphymstr)
      ,.r62_dfi0msgctl0 (r62_dfi0msgctl0)
      ,.r63_dfi0msgstat0 (r63_dfi0msgstat0)
      ,.r64_poisoncfg (r64_poisoncfg)
      ,.r65_poisonstat (r65_poisonstat)
      ,.r215_opctrl0 (r215_opctrl0)
      ,.r216_opctrl1 (r216_opctrl1)
      ,.r217_opctrlcam (r217_opctrlcam)
      ,.r218_opctrlcmd (r218_opctrlcmd)
      ,.r219_opctrlstat (r219_opctrlstat)
      ,.r221_oprefctrl0 (r221_oprefctrl0)
      ,.r223_oprefstat0 (r223_oprefstat0)
      ,.r225_swctl (r225_swctl)
      ,.r226_swstat (r226_swstat)
      ,.r230_dbictl (r230_dbictl)
      ,.r232_odtmap (r232_odtmap)
      ,.r233_datactl0 (r233_datactl0)
      ,.r234_swctlstatic (r234_swctlstatic)
      ,.r235_inittmg0 (r235_inittmg0)
      ,.r236_inittmg1 (r236_inittmg1)
      ,.r263_ddrctl_ver_number (r263_ddrctl_ver_number)
      ,.r264_ddrctl_ver_type (r264_ddrctl_ver_type)
      ,.r450_addrmap3_map0 (r450_addrmap3_map0)
      ,.r451_addrmap4_map0 (r451_addrmap4_map0)
      ,.r452_addrmap5_map0 (r452_addrmap5_map0)
      ,.r453_addrmap6_map0 (r453_addrmap6_map0)
      ,.r454_addrmap7_map0 (r454_addrmap7_map0)
      ,.r455_addrmap8_map0 (r455_addrmap8_map0)
      ,.r456_addrmap9_map0 (r456_addrmap9_map0)
      ,.r457_addrmap10_map0 (r457_addrmap10_map0)
      ,.r458_addrmap11_map0 (r458_addrmap11_map0)
      ,.r459_addrmap12_map0 (r459_addrmap12_map0)
      ,.r474_pccfg_port0 (r474_pccfg_port0)
      ,.r475_pcfgr_port0 (r475_pcfgr_port0)
      ,.r476_pcfgw_port0 (r476_pcfgw_port0)
      ,.r509_pctrl_port0 (r509_pctrl_port0)
      ,.r510_pcfgqos0_port0 (r510_pcfgqos0_port0)
      ,.r511_pcfgqos1_port0 (r511_pcfgqos1_port0)
      ,.r512_pcfgwqos0_port0 (r512_pcfgwqos0_port0)
      ,.r513_pcfgwqos1_port0 (r513_pcfgwqos1_port0)
      ,.r535_pstat_port0 (r535_pstat_port0)
      ,.r1882_dramset1tmg0_freq0 (r1882_dramset1tmg0_freq0)
      ,.r1883_dramset1tmg1_freq0 (r1883_dramset1tmg1_freq0)
      ,.r1884_dramset1tmg2_freq0 (r1884_dramset1tmg2_freq0)
      ,.r1885_dramset1tmg3_freq0 (r1885_dramset1tmg3_freq0)
      ,.r1886_dramset1tmg4_freq0 (r1886_dramset1tmg4_freq0)
      ,.r1887_dramset1tmg5_freq0 (r1887_dramset1tmg5_freq0)
      ,.r1888_dramset1tmg6_freq0 (r1888_dramset1tmg6_freq0)
      ,.r1889_dramset1tmg7_freq0 (r1889_dramset1tmg7_freq0)
      ,.r1891_dramset1tmg9_freq0 (r1891_dramset1tmg9_freq0)
      ,.r1894_dramset1tmg12_freq0 (r1894_dramset1tmg12_freq0)
      ,.r1895_dramset1tmg13_freq0 (r1895_dramset1tmg13_freq0)
      ,.r1896_dramset1tmg14_freq0 (r1896_dramset1tmg14_freq0)
      ,.r1905_dramset1tmg23_freq0 (r1905_dramset1tmg23_freq0)
      ,.r1906_dramset1tmg24_freq0 (r1906_dramset1tmg24_freq0)
      ,.r1907_dramset1tmg25_freq0 (r1907_dramset1tmg25_freq0)
      ,.r1912_dramset1tmg30_freq0 (r1912_dramset1tmg30_freq0)
      ,.r1938_initmr0_freq0 (r1938_initmr0_freq0)
      ,.r1939_initmr1_freq0 (r1939_initmr1_freq0)
      ,.r1940_initmr2_freq0 (r1940_initmr2_freq0)
      ,.r1941_initmr3_freq0 (r1941_initmr3_freq0)
      ,.r1942_dfitmg0_freq0 (r1942_dfitmg0_freq0)
      ,.r1943_dfitmg1_freq0 (r1943_dfitmg1_freq0)
      ,.r1944_dfitmg2_freq0 (r1944_dfitmg2_freq0)
      ,.r1946_dfitmg4_freq0 (r1946_dfitmg4_freq0)
      ,.r1947_dfitmg5_freq0 (r1947_dfitmg5_freq0)
      ,.r1949_dfilptmg0_freq0 (r1949_dfilptmg0_freq0)
      ,.r1950_dfilptmg1_freq0 (r1950_dfilptmg1_freq0)
      ,.r1951_dfiupdtmg0_freq0 (r1951_dfiupdtmg0_freq0)
      ,.r1952_dfiupdtmg1_freq0 (r1952_dfiupdtmg1_freq0)
      ,.r1953_dfimsgtmg0_freq0 (r1953_dfimsgtmg0_freq0)
      ,.r1955_rfshset1tmg0_freq0 (r1955_rfshset1tmg0_freq0)
      ,.r1956_rfshset1tmg1_freq0 (r1956_rfshset1tmg1_freq0)
      ,.r1957_rfshset1tmg2_freq0 (r1957_rfshset1tmg2_freq0)
      ,.r1958_rfshset1tmg3_freq0 (r1958_rfshset1tmg3_freq0)
      ,.r1975_zqset1tmg0_freq0 (r1975_zqset1tmg0_freq0)
      ,.r1976_zqset1tmg1_freq0 (r1976_zqset1tmg1_freq0)
      ,.r1985_dqsoscctl0_freq0 (r1985_dqsoscctl0_freq0)
      ,.r1986_derateint_freq0 (r1986_derateint_freq0)
      ,.r1987_derateval0_freq0 (r1987_derateval0_freq0)
      ,.r1988_derateval1_freq0 (r1988_derateval1_freq0)
      ,.r1989_hwlptmg0_freq0 (r1989_hwlptmg0_freq0)
      ,.r1990_schedtmg0_freq0 (r1990_schedtmg0_freq0)
      ,.r1991_perfhpr1_freq0 (r1991_perfhpr1_freq0)
      ,.r1992_perflpr1_freq0 (r1992_perflpr1_freq0)
      ,.r1993_perfwr1_freq0 (r1993_perfwr1_freq0)
      ,.r1994_tmgcfg_freq0 (r1994_tmgcfg_freq0)
      ,.r1997_pwrtmg_freq0 (r1997_pwrtmg_freq0)

      );    

   // ----------------------------------------------------------------------------
   // Module apbslvif (APB Slave Interface)
   // This module drives all the outputs for the APB module. It receives the
   // decoded address and depending on the SM state latches the data for a
   // write operation. This module also asserts pslverr in case the timer expires
   // or the address is out of bounds
   // The data is latched on the last clock of address decode (should we do it here
   // or move it to the address decoder-the latter seems to be easier)
   // pready is asserted and the data is put on the bus. This is on the same clk
   // when the SM is in the dataxfer state
   // The slave interfaces with the actual register file and retrieves the read
   // data from the register file (should the reg_file module be instantiated here?)
   // ----------------------------------------------------------------------------
      
   DWC_ddrctl_apb_slvif
   
     #(.APB_AW        (APB_AW),
       .APB_DW        (APB_DW),
       .RW_REGS       (RW_REGS),
       .REG_WIDTH     (REG_WIDTH),
       .RWSELWIDTH    (RWSELWIDTH)
       ) 
   slvif
     (.pclk               (pclk)
      ,.presetn            (presetn)
      ,.pwdata             (pwdata)
      ,.rwselect           (rwselect)
      ,.write_en           (write_en_pulse)
      ,.store_rqst         (store_rqst)
      // static registers write enable
      ,.static_wr_en_aclk_0             (static_wr_en_aclk_0)
      ,.quasi_dyn_wr_en_aclk_0          (quasi_dyn_wr_en_aclk_0)
      ,.static_wr_en_core_ddrc_core_clk    (static_wr_en_core_ddrc_core_clk)
      ,.quasi_dyn_wr_en_core_ddrc_core_clk (quasi_dyn_wr_en_core_ddrc_core_clk)
//`ifdef UMCTL2_OCECC_EN_1      
//      ,.quasi_dyn_wr_en_pclk               (quasi_dyn_wr_en_pclk)
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1
      //------------------------------
      ,.r0_mstr0 (r0_mstr0)
      ,.r4_mstr4 (r4_mstr4)
      ,.r8_mrctrl0 (r8_mrctrl0)
      ,.reg_ddrc_mrr_done_clr_ack_pclk (reg_ddrc_mrr_done_clr_ack_pclk)
      ,.reg_ddrc_mr_wr_ack_pclk (reg_ddrc_mr_wr_ack_pclk)
      ,.ff_regb_ddrc_ch0_mr_wr_saved (ff_regb_ddrc_ch0_mr_wr_saved)
      ,.r9_mrctrl1 (r9_mrctrl1)
      ,.ddrc_reg_mr_wr_busy_int (ddrc_reg_mr_wr_busy_int)
      ,.r14_deratectl0 (r14_deratectl0)
      ,.r15_deratectl1 (r15_deratectl1)
      ,.r19_deratectl5 (r19_deratectl5)
      ,.reg_ddrc_derate_temp_limit_intr_clr_ack_pclk (reg_ddrc_derate_temp_limit_intr_clr_ack_pclk)
      ,.reg_ddrc_derate_temp_limit_intr_force_ack_pclk (reg_ddrc_derate_temp_limit_intr_force_ack_pclk)
      ,.r20_deratectl6 (r20_deratectl6)
      ,.r23_deratedbgctl (r23_deratedbgctl)
      ,.r25_pwrctl (r25_pwrctl)
      ,.r26_hwlpctl (r26_hwlpctl)
      ,.r28_clkgatectl (r28_clkgatectl)
      ,.r29_rfshmod0 (r29_rfshmod0)
      ,.r31_rfshctl0 (r31_rfshctl0)
      ,.r34_zqctl0 (r34_zqctl0)
      ,.r35_zqctl1 (r35_zqctl1)
      ,.reg_ddrc_zq_reset_ack_pclk (reg_ddrc_zq_reset_ack_pclk)
      ,.ff_regb_ddrc_ch0_zq_reset_saved (ff_regb_ddrc_ch0_zq_reset_saved)
      ,.r36_zqctl2 (r36_zqctl2)
      ,.ddrc_reg_zq_reset_busy_int (ddrc_reg_zq_reset_busy_int)
      ,.r38_dqsoscruntime (r38_dqsoscruntime)
      ,.r40_dqsosccfg0 (r40_dqsosccfg0)
      ,.r42_sched0 (r42_sched0)
      ,.r43_sched1 (r43_sched1)
      ,.r45_sched3 (r45_sched3)
      ,.r46_sched4 (r46_sched4)
      ,.r56_dfilpcfg0 (r56_dfilpcfg0)
      ,.r57_dfiupd0 (r57_dfiupd0)
      ,.r59_dfimisc (r59_dfimisc)
      ,.r61_dfiphymstr (r61_dfiphymstr)
      ,.r62_dfi0msgctl0 (r62_dfi0msgctl0)
      ,.reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk (reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk)
      ,.reg_ddrc_dfi0_ctrlmsg_req_ack_pclk (reg_ddrc_dfi0_ctrlmsg_req_ack_pclk)
      ,.ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved (ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved)
      ,.ddrc_reg_dfi0_ctrlmsg_req_busy_int (ddrc_reg_dfi0_ctrlmsg_req_busy_int)
      ,.r64_poisoncfg (r64_poisoncfg)
      ,.reg_ddrc_wr_poison_intr_clr_ack_pclk (reg_ddrc_wr_poison_intr_clr_ack_pclk)
      ,.reg_ddrc_rd_poison_intr_clr_ack_pclk (reg_ddrc_rd_poison_intr_clr_ack_pclk)
      ,.r215_opctrl0 (r215_opctrl0)
      ,.r216_opctrl1 (r216_opctrl1)
      ,.r218_opctrlcmd (r218_opctrlcmd)
      ,.reg_ddrc_zq_calib_short_ack_pclk (reg_ddrc_zq_calib_short_ack_pclk)
      ,.ff_regb_ddrc_ch0_zq_calib_short_saved (ff_regb_ddrc_ch0_zq_calib_short_saved)
      ,.reg_ddrc_ctrlupd_ack_pclk (reg_ddrc_ctrlupd_ack_pclk)
      ,.ff_regb_ddrc_ch0_ctrlupd_saved (ff_regb_ddrc_ch0_ctrlupd_saved)
      ,.ddrc_reg_zq_calib_short_busy_int (ddrc_reg_zq_calib_short_busy_int)
      ,.ddrc_reg_ctrlupd_busy_int (ddrc_reg_ctrlupd_busy_int)
      ,.r221_oprefctrl0 (r221_oprefctrl0)
      ,.reg_ddrc_rank0_refresh_ack_pclk (reg_ddrc_rank0_refresh_ack_pclk)
      ,.ff_regb_ddrc_ch0_rank0_refresh_saved (ff_regb_ddrc_ch0_rank0_refresh_saved)
      ,.ddrc_reg_rank0_refresh_busy_int (ddrc_reg_rank0_refresh_busy_int)
      ,.r225_swctl (r225_swctl)
      ,.r230_dbictl (r230_dbictl)
      ,.r232_odtmap (r232_odtmap)
      ,.r233_datactl0 (r233_datactl0)
      ,.r234_swctlstatic (r234_swctlstatic)
      ,.r235_inittmg0 (r235_inittmg0)
      ,.r236_inittmg1 (r236_inittmg1)
      ,.r450_addrmap3_map0 (r450_addrmap3_map0)
      ,.r451_addrmap4_map0 (r451_addrmap4_map0)
      ,.r452_addrmap5_map0 (r452_addrmap5_map0)
      ,.r453_addrmap6_map0 (r453_addrmap6_map0)
      ,.r454_addrmap7_map0 (r454_addrmap7_map0)
      ,.r455_addrmap8_map0 (r455_addrmap8_map0)
      ,.r456_addrmap9_map0 (r456_addrmap9_map0)
      ,.r457_addrmap10_map0 (r457_addrmap10_map0)
      ,.r458_addrmap11_map0 (r458_addrmap11_map0)
      ,.r459_addrmap12_map0 (r459_addrmap12_map0)
      ,.r474_pccfg_port0 (r474_pccfg_port0)
      ,.r475_pcfgr_port0 (r475_pcfgr_port0)
      ,.r476_pcfgw_port0 (r476_pcfgw_port0)
      ,.r509_pctrl_port0 (r509_pctrl_port0)
      ,.r510_pcfgqos0_port0 (r510_pcfgqos0_port0)
      ,.r511_pcfgqos1_port0 (r511_pcfgqos1_port0)
      ,.r512_pcfgwqos0_port0 (r512_pcfgwqos0_port0)
      ,.r513_pcfgwqos1_port0 (r513_pcfgwqos1_port0)
      ,.r1882_dramset1tmg0_freq0 (r1882_dramset1tmg0_freq0)
      ,.r1883_dramset1tmg1_freq0 (r1883_dramset1tmg1_freq0)
      ,.r1884_dramset1tmg2_freq0 (r1884_dramset1tmg2_freq0)
      ,.r1885_dramset1tmg3_freq0 (r1885_dramset1tmg3_freq0)
      ,.r1886_dramset1tmg4_freq0 (r1886_dramset1tmg4_freq0)
      ,.r1887_dramset1tmg5_freq0 (r1887_dramset1tmg5_freq0)
      ,.r1888_dramset1tmg6_freq0 (r1888_dramset1tmg6_freq0)
      ,.r1889_dramset1tmg7_freq0 (r1889_dramset1tmg7_freq0)
      ,.r1891_dramset1tmg9_freq0 (r1891_dramset1tmg9_freq0)
      ,.r1894_dramset1tmg12_freq0 (r1894_dramset1tmg12_freq0)
      ,.r1895_dramset1tmg13_freq0 (r1895_dramset1tmg13_freq0)
      ,.r1896_dramset1tmg14_freq0 (r1896_dramset1tmg14_freq0)
      ,.r1905_dramset1tmg23_freq0 (r1905_dramset1tmg23_freq0)
      ,.r1906_dramset1tmg24_freq0 (r1906_dramset1tmg24_freq0)
      ,.r1907_dramset1tmg25_freq0 (r1907_dramset1tmg25_freq0)
      ,.r1912_dramset1tmg30_freq0 (r1912_dramset1tmg30_freq0)
      ,.r1938_initmr0_freq0 (r1938_initmr0_freq0)
      ,.r1939_initmr1_freq0 (r1939_initmr1_freq0)
      ,.r1940_initmr2_freq0 (r1940_initmr2_freq0)
      ,.r1941_initmr3_freq0 (r1941_initmr3_freq0)
      ,.r1942_dfitmg0_freq0 (r1942_dfitmg0_freq0)
      ,.r1943_dfitmg1_freq0 (r1943_dfitmg1_freq0)
      ,.r1944_dfitmg2_freq0 (r1944_dfitmg2_freq0)
      ,.r1946_dfitmg4_freq0 (r1946_dfitmg4_freq0)
      ,.r1947_dfitmg5_freq0 (r1947_dfitmg5_freq0)
      ,.r1949_dfilptmg0_freq0 (r1949_dfilptmg0_freq0)
      ,.r1950_dfilptmg1_freq0 (r1950_dfilptmg1_freq0)
      ,.r1951_dfiupdtmg0_freq0 (r1951_dfiupdtmg0_freq0)
      ,.r1952_dfiupdtmg1_freq0 (r1952_dfiupdtmg1_freq0)
      ,.r1953_dfimsgtmg0_freq0 (r1953_dfimsgtmg0_freq0)
      ,.r1955_rfshset1tmg0_freq0 (r1955_rfshset1tmg0_freq0)
      ,.r1956_rfshset1tmg1_freq0 (r1956_rfshset1tmg1_freq0)
      ,.r1957_rfshset1tmg2_freq0 (r1957_rfshset1tmg2_freq0)
      ,.r1958_rfshset1tmg3_freq0 (r1958_rfshset1tmg3_freq0)
      ,.r1975_zqset1tmg0_freq0 (r1975_zqset1tmg0_freq0)
      ,.r1976_zqset1tmg1_freq0 (r1976_zqset1tmg1_freq0)
      ,.r1985_dqsoscctl0_freq0 (r1985_dqsoscctl0_freq0)
      ,.r1986_derateint_freq0 (r1986_derateint_freq0)
      ,.r1987_derateval0_freq0 (r1987_derateval0_freq0)
      ,.r1988_derateval1_freq0 (r1988_derateval1_freq0)
      ,.r1989_hwlptmg0_freq0 (r1989_hwlptmg0_freq0)
      ,.r1990_schedtmg0_freq0 (r1990_schedtmg0_freq0)
      ,.r1991_perfhpr1_freq0 (r1991_perfhpr1_freq0)
      ,.r1992_perflpr1_freq0 (r1992_perflpr1_freq0)
      ,.r1993_perfwr1_freq0 (r1993_perfwr1_freq0)
      ,.r1994_tmgcfg_freq0 (r1994_tmgcfg_freq0)
      ,.r1997_pwrtmg_freq0 (r1997_pwrtmg_freq0)

      );

   // ----------------------------------------------------------------------------
   // APB Slave State Machine
   // The APB Slave machine has the following states:
   // Idle : This is the default state. During Idle, if psel & penable
   // are asserted, apb_addr is latched.
   //
   // Address Decode: The SM enters Address Decode on psel & penable.
   // The  address is decoded in 4 clock cycles. During the last cycle the data
   // is latched (in case of a write). If there is an error during address
   // decode, pslverr is asserted with pready and the SM moves back to Idle
   //
   // Data Transfer: For a read operation the data is put on the bus and
   // pready is asserted for one clock cycle. In case of an error,
   // pslverr is asserted with pready
   // ----------------------------------------------------------------------------
   DWC_ddrctl_apb_slvfsm
   
     #(.N_APBFSMSTAT(N_APBFSMSTAT))
   slvfsm
     (.pclk           (pclk),
      .presetn        (presetn),
      .psel           (psel_int),
      .penable        (penable),
      .pwrite         (pwrite),
      //------------------------------
      .set_async_reg  (set_async_reg),
      .ack_async_reg  (ack_async_reg),
      //------------------------------
      .apb_slv_cs     (apb_slv_cs_unused),
      .apb_slv_ns     (apb_slv_ns),
      .pready         (pready_int),
      .write_en       (write_en),
      .write_en_pulse (write_en_pulse),
      .write_en_s0    (write_en_s0),
      .fwd_reset_val  (fwd_reset_val),
      .store_rqst     (store_rqst)
      );

   wire reg_ddrc_derate_mr4_tuf_dis_bcm36in;
   wire reg_ddrc_hw_lp_en_bcm36in;
   wire reg_ddrc_hw_lp_exit_idle_en_bcm36in;
   wire reg_ddrc_dis_srx_zqcl_bcm36in;
   wire [8-1:0] reg_ddrc_dqsosc_runtime_bcm36in;
   wire [8-1:0] reg_ddrc_wck2dqo_runtime_bcm36in;
   wire reg_ddrc_dis_dqsosc_srx_bcm36in;
   wire reg_ddrc_prefer_write_bcm36in;
   wire reg_ddrc_pageclose_bcm36in;
   wire reg_ddrc_opt_wrcam_fill_level_bcm36in;
   wire reg_ddrc_dis_opt_ntt_by_act_bcm36in;
   wire reg_ddrc_dis_opt_ntt_by_pre_bcm36in;
   wire reg_ddrc_autopre_rmw_bcm36in;
   wire [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_lpr_num_entries_bcm36in;
   wire reg_ddrc_lpddr4_opt_act_timing_bcm36in;
   wire reg_ddrc_lpddr5_opt_act_timing_bcm36in;
   wire reg_ddrc_prefer_read_bcm36in;
   wire reg_ddrc_dis_speculative_act_bcm36in;
   wire [4-1:0] reg_ddrc_delay_switch_write_bcm36in;
   wire [3-1:0] reg_ddrc_page_hit_limit_wr_bcm36in;
   wire [3-1:0] reg_ddrc_page_hit_limit_rd_bcm36in;
   wire reg_ddrc_opt_hit_gt_hpr_bcm36in;
   wire [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wrcam_lowthresh_bcm36in;
   wire [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wrcam_highthresh_bcm36in;
   wire [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wr_pghit_num_thresh_bcm36in;
   wire [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_rd_pghit_num_thresh_bcm36in;
   wire [8-1:0] reg_ddrc_rd_act_idle_gap_bcm36in;
   wire [8-1:0] reg_ddrc_wr_act_idle_gap_bcm36in;
   wire [8-1:0] reg_ddrc_rd_page_exp_cycles_bcm36in;
   wire [8-1:0] reg_ddrc_wr_page_exp_cycles_bcm36in;
   wire reg_ddrc_dis_wc_bcm36in;
   wire [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_wr_odt_bcm36in;
   wire [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_rd_odt_bcm36in;
   wire [6-1:0] reg_ddrc_addrmap_bank_b0_map0_bcm36in;
   wire [6-1:0] reg_ddrc_addrmap_bank_b1_map0_bcm36in;
   wire [6-1:0] reg_ddrc_addrmap_bank_b2_map0_bcm36in;
   wire [6-1:0] reg_ddrc_addrmap_bg_b0_map0_bcm36in;
   wire [6-1:0] reg_ddrc_addrmap_bg_b1_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_col_b7_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_col_b8_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_col_b9_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_col_b10_map0_bcm36in;
   wire [4-1:0] reg_ddrc_addrmap_col_b3_map0_bcm36in;
   wire [4-1:0] reg_ddrc_addrmap_col_b4_map0_bcm36in;
   wire [4-1:0] reg_ddrc_addrmap_col_b5_map0_bcm36in;
   wire [4-1:0] reg_ddrc_addrmap_col_b6_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b14_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b15_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b16_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b17_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b10_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b11_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b12_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b13_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b6_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b7_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b8_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b9_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b2_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b3_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b4_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b5_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b0_map0_bcm36in;
   wire [5-1:0] reg_ddrc_addrmap_row_b1_map0_bcm36in;
   wire reg_arb_go2critical_en_port0_bcm36in;
   wire reg_arb_pagematch_limit_port0_bcm36in;
   wire [10-1:0] reg_arb_rd_port_priority_port0_bcm36in;
   wire reg_arb_rd_port_aging_en_port0_bcm36in;
   wire reg_arb_rd_port_urgent_en_port0_bcm36in;
   wire reg_arb_rd_port_pagematch_en_port0_bcm36in;
   wire [10-1:0] reg_arb_wr_port_priority_port0_bcm36in;
   wire reg_arb_wr_port_aging_en_port0_bcm36in;
   wire reg_arb_wr_port_urgent_en_port0_bcm36in;
   wire reg_arb_wr_port_pagematch_en_port0_bcm36in;
   wire [(`UMCTL2_XPI_RQOS_MLW)-1:0] reg_arba0_rqos_map_level1_port0_bcm36in;
   wire [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region0_port0_bcm36in;
   wire [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region1_port0_bcm36in;
   wire [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutb_port0_bcm36in;
   wire [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutr_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level1_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level2_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region0_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region1_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region2_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout1_port0_bcm36in;
   wire [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout2_port0_bcm36in;
   wire [8-1:0] reg_ddrc_t_ras_min_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_t_ras_max_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_t_faw_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_wr2pre_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_t_rc_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_rd2pre_freq0_bcm36in;
   wire [6-1:0] reg_ddrc_t_xp_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_wr2rd_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_rd2wr_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_read_latency_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_write_latency_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_wr2mr_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_rd2mr_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_t_mr_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_t_rp_freq0_bcm36in;
   wire [6-1:0] reg_ddrc_t_rrd_freq0_bcm36in;
   wire [6-1:0] reg_ddrc_t_ccd_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_t_rcd_freq0_bcm36in;
   wire [6-1:0] reg_ddrc_t_ckcsx_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_wr2rd_s_freq0_bcm36in;
   wire [6-1:0] reg_ddrc_t_rrd_s_freq0_bcm36in;
   wire [5-1:0] reg_ddrc_t_ccd_s_freq0_bcm36in;
   wire [4-1:0] reg_ddrc_t_cmdcke_freq0_bcm36in;
   wire [4-1:0] reg_ddrc_t_ppd_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_t_ccd_mw_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_odtloff_freq0_bcm36in;
   wire [12-1:0] reg_ddrc_t_xsr_freq0_bcm36in;
   wire [9-1:0] reg_ddrc_t_osco_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_max_wr_sync_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_max_rd_sync_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_rd2wr_s_freq0_bcm36in;
   wire [2-1:0] reg_ddrc_bank_org_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_rda2pre_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_wra2pre_freq0_bcm36in;
   wire [3-1:0] reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_emr_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_mr_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_mr5_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_mr4_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_mr6_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_mr22_freq0_bcm36in;
   wire [((`DDRCTL_DDR_DUAL_CHANNEL_EN==1) ? 7 : 6)-1:0] reg_ddrc_dfi_tphy_wrcslat_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_dfi_tphy_rdcslat_freq0_bcm36in;
   wire [6-1:0] reg_ddrc_dfi_twck_delay_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_dis_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_en_wr_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_en_rd_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_toggle_post_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_toggle_cs_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_toggle_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_twck_fast_toggle_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_dfi_t_ctrlmsg_resp_freq0_bcm36in;
   wire [20-1:0] reg_ddrc_t_zq_short_interval_x1024_freq0_bcm36in;
   wire [10-1:0] reg_ddrc_t_zq_reset_nop_freq0_bcm36in;
   wire [32-1:0] reg_ddrc_mr4_read_interval_freq0_bcm36in;
   wire [12-1:0] reg_ddrc_hw_lp_idle_x32_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_pageclose_timer_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_rdwr_idle_gap_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_hpr_max_starve_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_hpr_xact_run_length_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_lpr_max_starve_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_lpr_xact_run_length_freq0_bcm36in;
   wire [16-1:0] reg_ddrc_w_max_starve_freq0_bcm36in;
   wire [8-1:0] reg_ddrc_w_xact_run_length_freq0_bcm36in;
   wire [7-1:0] reg_ddrc_powerdown_to_x32_freq0_bcm36in;
   wire [10-1:0] reg_ddrc_selfref_to_x32_freq0_bcm36in;


   // ----------------------------------------------------------------------------
   // output to the core is given from here. Each
   // register value is assigned to the corresponding core signal
   // ----------------------------------------------------------------------------     
   DWC_ddrctl_apb_coreif
   
     #(.APB_AW              (APB_AW),
       .REG_WIDTH           (REG_WIDTH),
       .BCM_F_SYNC_TYPE_C2P (BCM_F_SYNC_TYPE_C2P),
       .BCM_F_SYNC_TYPE_P2C (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE_C2P (BCM_R_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE_P2C (BCM_R_SYNC_TYPE_P2C),
       .REG_OUTPUTS_C2P     (REG_OUTPUTS_C2P),
       .REG_OUTPUTS_P2C     (REG_OUTPUTS_P2C),
       .BCM_VERIF_EN        (BCM_VERIF_EN),
       .RW_REGS             (RW_REGS),
       .RWSELWIDTH          (RWSELWIDTH)
       )
     coreif
     (
      .apb_clk            (pclk),
      .apb_rst            (presetn),
      .core_ddrc_core_clk (core_ddrc_core_clk),
      .sync_core_ddrc_rstn(sync_core_ddrc_rstn),
      .core_ddrc_rstn     (core_ddrc_rstn),
      .rwselect           (rwselect),// should be rwselect s0 but address is latched
      .fwd_reset_val      (fwd_reset_val),
      .write_en           (write_en_s0)
      ,.aclk_0             (aclk_0)
      ,.sync_aresetn_0     (sync_aresetn_0)

   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
      ,.r0_mstr0 (r0_mstr0)
      ,.r0_mstr0_ack_pclk (r0_mstr0_ack_pclk_i)
      ,.r0_mstr0_ack_arba0_pclk (r0_mstr0_ack_arba0_pclk_i)
      ,.reg_ddrc_lpddr4 (reg_ddrc_lpddr4)
      ,.reg_apb_lpddr4 (reg_apb_lpddr4)
      ,.reg_arba0_lpddr4 (reg_arba0_lpddr4)
      ,.reg_ddrc_lpddr5 (reg_ddrc_lpddr5)
      ,.reg_apb_lpddr5 (reg_apb_lpddr5)
      ,.reg_arba0_lpddr5 (reg_arba0_lpddr5)
      ,.reg_ddrc_en_2t_timing_mode (reg_ddrc_en_2t_timing_mode)
      ,.reg_apb_en_2t_timing_mode (reg_apb_en_2t_timing_mode)
      ,.reg_arba0_en_2t_timing_mode (reg_arba0_en_2t_timing_mode)
      ,.reg_ddrc_data_bus_width (reg_ddrc_data_bus_width)
      ,.reg_apb_data_bus_width (reg_apb_data_bus_width)
      ,.reg_arba0_data_bus_width (reg_arba0_data_bus_width)
      ,.reg_ddrc_burst_rdwr (reg_ddrc_burst_rdwr)
      ,.reg_apb_burst_rdwr (reg_apb_burst_rdwr)
      ,.reg_arba0_burst_rdwr (reg_arba0_burst_rdwr)
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
      ,.r4_mstr4 (r4_mstr4)
      ,.r4_mstr4_ack_pclk (r4_mstr4_ack_pclk)
      ,.reg_ddrc_wck_on (reg_ddrc_wck_on)
      ,.reg_ddrc_wck_suspend_en (reg_ddrc_wck_suspend_en)
      ,.reg_ddrc_ws_off_en (reg_ddrc_ws_off_en)
   //------------------------
   // Register REGB_DDRC_CH0.STAT
   //------------------------
      ,.r5_stat (r5_stat)
      ,.ddrc_reg_operating_mode (ddrc_reg_operating_mode)
      ,.ddrc_reg_selfref_type (ddrc_reg_selfref_type)
      ,.ddrc_reg_selfref_state (ddrc_reg_selfref_state)
      ,.ddrc_reg_selfref_cam_not_empty (ddrc_reg_selfref_cam_not_empty)
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
      ,.r8_mrctrl0 (r8_mrctrl0)
      ,.r8_mrctrl0_ack_pclk (r8_mrctrl0_ack_pclk)
      ,.reg_ddrc_mr_type (reg_ddrc_mr_type)
      ,.reg_ddrc_sw_init_int (reg_ddrc_sw_init_int)
      ,.reg_ddrc_mr_rank (reg_ddrc_mr_rank)
      ,.reg_ddrc_mr_addr (reg_ddrc_mr_addr)
      ,.reg_ddrc_mrr_done_clr_ack_pclk (reg_ddrc_mrr_done_clr_ack_pclk)
      ,.reg_ddrc_mrr_done_clr (reg_ddrc_mrr_done_clr)
      ,.reg_ddrc_mr_wr_ack_pclk (reg_ddrc_mr_wr_ack_pclk)
      ,.ff_regb_ddrc_ch0_mr_wr_saved (ff_regb_ddrc_ch0_mr_wr_saved)
      ,.reg_ddrc_mr_wr (reg_ddrc_mr_wr)
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
      ,.r9_mrctrl1 (r9_mrctrl1)
      ,.r9_mrctrl1_ack_pclk (r9_mrctrl1_ack_pclk)
      ,.reg_ddrc_mr_data (reg_ddrc_mr_data)
   //------------------------
   // Register REGB_DDRC_CH0.MRSTAT
   //------------------------
      ,.r11_mrstat (r11_mrstat)
      ,.ddrc_reg_mr_wr_busy_int (ddrc_reg_mr_wr_busy_int)
      ,.ddrc_reg_mr_wr_busy (ddrc_reg_mr_wr_busy)
      ,.ddrc_reg_mrr_done (ddrc_reg_mrr_done)
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA0
   //------------------------
      ,.r12_mrrdata0 (r12_mrrdata0)
      ,.ddrc_reg_mrr_data_lwr (ddrc_reg_mrr_data_lwr)
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA1
   //------------------------
      ,.r13_mrrdata1 (r13_mrrdata1)
      ,.ddrc_reg_mrr_data_upr (ddrc_reg_mrr_data_upr)
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
      ,.r14_deratectl0 (r14_deratectl0)
      ,.r14_deratectl0_ack_pclk (r14_deratectl0_ack_pclk)
      ,.reg_ddrc_derate_enable (reg_ddrc_derate_enable)
      ,.reg_ddrc_lpddr4_refresh_mode (reg_ddrc_lpddr4_refresh_mode)
      ,.reg_ddrc_derate_mr4_pause_fc (reg_ddrc_derate_mr4_pause_fc)
      ,.reg_ddrc_dis_trefi_x6x8 (reg_ddrc_dis_trefi_x6x8)
      ,.reg_ddrc_dis_trefi_x0125 (reg_ddrc_dis_trefi_x0125)
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
      ,.r15_deratectl1 (r15_deratectl1)
      ,.r15_deratectl1_ack_pclk (r15_deratectl1_ack_pclk)
      ,.reg_ddrc_active_derate_byte_rank0 (reg_ddrc_active_derate_byte_rank0)
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
      ,.r19_deratectl5 (r19_deratectl5[REG_WIDTH-1:0])
      ,.reg_ddrc_derate_temp_limit_intr_en (reg_ddrc_derate_temp_limit_intr_en)
      ,.reg_ddrc_derate_temp_limit_intr_clr_ack_pclk (reg_ddrc_derate_temp_limit_intr_clr_ack_pclk)
      ,.reg_ddrc_derate_temp_limit_intr_clr (reg_ddrc_derate_temp_limit_intr_clr)
      ,.reg_ddrc_derate_temp_limit_intr_force_ack_pclk (reg_ddrc_derate_temp_limit_intr_force_ack_pclk)
      ,.reg_ddrc_derate_temp_limit_intr_force (reg_ddrc_derate_temp_limit_intr_force)
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
      ,.r20_deratectl6 (r20_deratectl6[REG_WIDTH-1:0])
      ,.reg_ddrc_derate_mr4_tuf_dis (reg_ddrc_derate_mr4_tuf_dis_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.DERATESTAT0
   //------------------------
      ,.r21_deratestat0 (r21_deratestat0)
      ,.ddrc_reg_derate_temp_limit_intr (ddrc_reg_derate_temp_limit_intr)
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
      ,.r23_deratedbgctl (r23_deratedbgctl)
      ,.r23_deratedbgctl_ack_pclk (r23_deratedbgctl_ack_pclk)
      ,.reg_ddrc_dbg_mr4_grp_sel (reg_ddrc_dbg_mr4_grp_sel)
      ,.reg_ddrc_dbg_mr4_rank_sel (reg_ddrc_dbg_mr4_rank_sel)
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGSTAT
   //------------------------
      ,.r24_deratedbgstat (r24_deratedbgstat)
      ,.ddrc_reg_dbg_mr4_byte0 (ddrc_reg_dbg_mr4_byte0)
      ,.ddrc_reg_dbg_mr4_byte1 (ddrc_reg_dbg_mr4_byte1)
      ,.ddrc_reg_dbg_mr4_byte2 (ddrc_reg_dbg_mr4_byte2)
      ,.ddrc_reg_dbg_mr4_byte3 (ddrc_reg_dbg_mr4_byte3)
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
      ,.r25_pwrctl (r25_pwrctl)
      ,.r25_pwrctl_ack_pclk (r25_pwrctl_ack_pclk)
      ,.reg_ddrc_selfref_en (reg_ddrc_selfref_en)
      ,.reg_ddrc_powerdown_en (reg_ddrc_powerdown_en)
      ,.reg_ddrc_en_dfi_dram_clk_disable (reg_ddrc_en_dfi_dram_clk_disable)
      ,.reg_ddrc_selfref_sw (reg_ddrc_selfref_sw)
      ,.reg_ddrc_stay_in_selfref (reg_ddrc_stay_in_selfref)
      ,.reg_ddrc_dis_cam_drain_selfref (reg_ddrc_dis_cam_drain_selfref)
      ,.reg_ddrc_lpddr4_sr_allowed (reg_ddrc_lpddr4_sr_allowed)
      ,.reg_ddrc_dsm_en (reg_ddrc_dsm_en)
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
      ,.r26_hwlpctl (r26_hwlpctl[REG_WIDTH-1:0])
      ,.reg_ddrc_hw_lp_en (reg_ddrc_hw_lp_en_bcm36in)
      ,.reg_ddrc_hw_lp_exit_idle_en (reg_ddrc_hw_lp_exit_idle_en_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
      ,.r28_clkgatectl (r28_clkgatectl)
      ,.r28_clkgatectl_ack_pclk (r28_clkgatectl_ack_pclk)
      ,.reg_ddrc_bsm_clk_on (reg_ddrc_bsm_clk_on)
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
      ,.r29_rfshmod0 (r29_rfshmod0)
      ,.r29_rfshmod0_ack_pclk (r29_rfshmod0_ack_pclk)
      ,.reg_ddrc_refresh_burst (reg_ddrc_refresh_burst)
      ,.reg_ddrc_auto_refab_en (reg_ddrc_auto_refab_en)
      ,.reg_ddrc_per_bank_refresh (reg_ddrc_per_bank_refresh)
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
      ,.r31_rfshctl0 (r31_rfshctl0)
      ,.r31_rfshctl0_ack_pclk (r31_rfshctl0_ack_pclk)
      ,.reg_ddrc_dis_auto_refresh (reg_ddrc_dis_auto_refresh)
      ,.reg_ddrc_refresh_update_level (reg_ddrc_refresh_update_level)
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
      ,.r34_zqctl0 (r34_zqctl0)
      ,.r34_zqctl0_ack_pclk (r34_zqctl0_ack_pclk)
      ,.reg_ddrc_zq_resistor_shared (reg_ddrc_zq_resistor_shared)
      ,.reg_ddrc_dis_auto_zq (reg_ddrc_dis_auto_zq)
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
      ,.r35_zqctl1 (r35_zqctl1)
      ,.r35_zqctl1_ack_pclk (r35_zqctl1_ack_pclk)
      ,.reg_ddrc_zq_reset_ack_pclk (reg_ddrc_zq_reset_ack_pclk)
      ,.ff_regb_ddrc_ch0_zq_reset_saved (ff_regb_ddrc_ch0_zq_reset_saved)
      ,.reg_ddrc_zq_reset (reg_ddrc_zq_reset)
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
      ,.r36_zqctl2 (r36_zqctl2[REG_WIDTH-1:0])
      ,.reg_ddrc_dis_srx_zqcl (reg_ddrc_dis_srx_zqcl_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.ZQSTAT
   //------------------------
      ,.r37_zqstat (r37_zqstat)
      ,.ddrc_reg_zq_reset_busy_int (ddrc_reg_zq_reset_busy_int)
      ,.ddrc_reg_zq_reset_busy (ddrc_reg_zq_reset_busy)
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
      ,.r38_dqsoscruntime (r38_dqsoscruntime[REG_WIDTH-1:0])
      ,.reg_ddrc_dqsosc_runtime (reg_ddrc_dqsosc_runtime_bcm36in)
      ,.reg_ddrc_wck2dqo_runtime (reg_ddrc_wck2dqo_runtime_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCSTAT0
   //------------------------
      ,.r39_dqsoscstat0 (r39_dqsoscstat0)
      ,.ddrc_reg_dqsosc_state (ddrc_reg_dqsosc_state)
      ,.ddrc_reg_dqsosc_per_rank_stat (ddrc_reg_dqsosc_per_rank_stat)
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
      ,.r40_dqsosccfg0 (r40_dqsosccfg0[REG_WIDTH-1:0])
      ,.reg_ddrc_dis_dqsosc_srx (reg_ddrc_dis_dqsosc_srx_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
      ,.r42_sched0 (r42_sched0[REG_WIDTH-1:0])
      ,.reg_ddrc_prefer_write (reg_ddrc_prefer_write_bcm36in)
      ,.reg_ddrc_pageclose (reg_ddrc_pageclose_bcm36in)
      ,.reg_ddrc_opt_wrcam_fill_level (reg_ddrc_opt_wrcam_fill_level_bcm36in)
      ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act_bcm36in)
      ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre_bcm36in)
      ,.reg_ddrc_autopre_rmw (reg_ddrc_autopre_rmw_bcm36in)
      ,.reg_ddrc_lpr_num_entries (reg_ddrc_lpr_num_entries_bcm36in)
      ,.reg_ddrc_lpddr4_opt_act_timing (reg_ddrc_lpddr4_opt_act_timing_bcm36in)
      ,.reg_ddrc_lpddr5_opt_act_timing (reg_ddrc_lpddr5_opt_act_timing_bcm36in)
      ,.reg_ddrc_prefer_read (reg_ddrc_prefer_read_bcm36in)
      ,.reg_ddrc_dis_speculative_act (reg_ddrc_dis_speculative_act_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
      ,.r43_sched1 (r43_sched1[REG_WIDTH-1:0])
      ,.reg_ddrc_delay_switch_write (reg_ddrc_delay_switch_write_bcm36in)
      ,.reg_ddrc_page_hit_limit_wr (reg_ddrc_page_hit_limit_wr_bcm36in)
      ,.reg_ddrc_page_hit_limit_rd (reg_ddrc_page_hit_limit_rd_bcm36in)
      ,.reg_ddrc_opt_hit_gt_hpr (reg_ddrc_opt_hit_gt_hpr_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
      ,.r45_sched3 (r45_sched3[REG_WIDTH-1:0])
      ,.reg_ddrc_wrcam_lowthresh (reg_ddrc_wrcam_lowthresh_bcm36in)
      ,.reg_ddrc_wrcam_highthresh (reg_ddrc_wrcam_highthresh_bcm36in)
      ,.reg_ddrc_wr_pghit_num_thresh (reg_ddrc_wr_pghit_num_thresh_bcm36in)
      ,.reg_ddrc_rd_pghit_num_thresh (reg_ddrc_rd_pghit_num_thresh_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
      ,.r46_sched4 (r46_sched4[REG_WIDTH-1:0])
      ,.reg_ddrc_rd_act_idle_gap (reg_ddrc_rd_act_idle_gap_bcm36in)
      ,.reg_ddrc_wr_act_idle_gap (reg_ddrc_wr_act_idle_gap_bcm36in)
      ,.reg_ddrc_rd_page_exp_cycles (reg_ddrc_rd_page_exp_cycles_bcm36in)
      ,.reg_ddrc_wr_page_exp_cycles (reg_ddrc_wr_page_exp_cycles_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
      ,.r56_dfilpcfg0 (r56_dfilpcfg0)
      ,.r56_dfilpcfg0_ack_pclk (r56_dfilpcfg0_ack_pclk)
      ,.reg_ddrc_dfi_lp_en_pd (reg_ddrc_dfi_lp_en_pd)
      ,.reg_ddrc_dfi_lp_en_sr (reg_ddrc_dfi_lp_en_sr)
      ,.reg_ddrc_dfi_lp_en_dsm (reg_ddrc_dfi_lp_en_dsm)
      ,.reg_ddrc_dfi_lp_en_data (reg_ddrc_dfi_lp_en_data)
      ,.reg_ddrc_dfi_lp_data_req_en (reg_ddrc_dfi_lp_data_req_en)
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
      ,.r57_dfiupd0 (r57_dfiupd0)
      ,.r57_dfiupd0_ack_pclk (r57_dfiupd0_ack_pclk)
      ,.reg_ddrc_dfi_phyupd_en (reg_ddrc_dfi_phyupd_en)
      ,.reg_ddrc_ctrlupd_pre_srx (reg_ddrc_ctrlupd_pre_srx)
      ,.reg_ddrc_dis_auto_ctrlupd_srx (reg_ddrc_dis_auto_ctrlupd_srx)
      ,.reg_ddrc_dis_auto_ctrlupd (reg_ddrc_dis_auto_ctrlupd)
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
      ,.r59_dfimisc (r59_dfimisc)
      ,.r59_dfimisc_ack_pclk (r59_dfimisc_ack_pclk)
      ,.reg_ddrc_dfi_init_complete_en (reg_ddrc_dfi_init_complete_en)
      ,.reg_ddrc_phy_dbi_mode (reg_ddrc_phy_dbi_mode)
      ,.reg_ddrc_dfi_data_cs_polarity (reg_ddrc_dfi_data_cs_polarity)
      ,.reg_ddrc_dfi_init_start (reg_ddrc_dfi_init_start)
      ,.reg_ddrc_lp_optimized_write (reg_ddrc_lp_optimized_write)
      ,.reg_ddrc_dfi_frequency (reg_ddrc_dfi_frequency)
      ,.reg_ddrc_dfi_freq_fsp (reg_ddrc_dfi_freq_fsp)
      ,.reg_ddrc_dfi_channel_mode (reg_ddrc_dfi_channel_mode)
   //------------------------
   // Register REGB_DDRC_CH0.DFISTAT
   //------------------------
      ,.r60_dfistat (r60_dfistat)
      ,.ddrc_reg_dfi_init_complete (ddrc_reg_dfi_init_complete)
      ,.ddrc_reg_dfi_lp_ctrl_ack_stat (ddrc_reg_dfi_lp_ctrl_ack_stat)
      ,.ddrc_reg_dfi_lp_data_ack_stat (ddrc_reg_dfi_lp_data_ack_stat)
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
      ,.r61_dfiphymstr (r61_dfiphymstr)
      ,.r61_dfiphymstr_ack_pclk (r61_dfiphymstr_ack_pclk)
      ,.reg_ddrc_dfi_phymstr_en (reg_ddrc_dfi_phymstr_en)
      ,.reg_ddrc_dfi_phymstr_blk_ref_x32 (reg_ddrc_dfi_phymstr_blk_ref_x32)
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
      ,.r62_dfi0msgctl0 (r62_dfi0msgctl0)
      ,.r62_dfi0msgctl0_ack_pclk (r62_dfi0msgctl0_ack_pclk)
      ,.reg_ddrc_dfi0_ctrlmsg_data (reg_ddrc_dfi0_ctrlmsg_data)
      ,.reg_ddrc_dfi0_ctrlmsg_cmd (reg_ddrc_dfi0_ctrlmsg_cmd)
      ,.reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk (reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk)
      ,.reg_ddrc_dfi0_ctrlmsg_tout_clr (reg_ddrc_dfi0_ctrlmsg_tout_clr)
      ,.reg_ddrc_dfi0_ctrlmsg_req_ack_pclk (reg_ddrc_dfi0_ctrlmsg_req_ack_pclk)
      ,.ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved (ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved)
      ,.reg_ddrc_dfi0_ctrlmsg_req (reg_ddrc_dfi0_ctrlmsg_req)
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGSTAT0
   //------------------------
      ,.r63_dfi0msgstat0 (r63_dfi0msgstat0)
      ,.ddrc_reg_dfi0_ctrlmsg_req_busy_int (ddrc_reg_dfi0_ctrlmsg_req_busy_int)
      ,.ddrc_reg_dfi0_ctrlmsg_req_busy (ddrc_reg_dfi0_ctrlmsg_req_busy)
      ,.ddrc_reg_dfi0_ctrlmsg_resp_tout (ddrc_reg_dfi0_ctrlmsg_resp_tout)
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
      ,.r64_poisoncfg (r64_poisoncfg)
      ,.r64_poisoncfg_ack_pclk (r64_poisoncfg_ack_pclk)
      ,.reg_ddrc_wr_poison_slverr_en (reg_ddrc_wr_poison_slverr_en)
      ,.reg_ddrc_wr_poison_intr_en (reg_ddrc_wr_poison_intr_en)
      ,.reg_ddrc_wr_poison_intr_clr_ack_pclk (reg_ddrc_wr_poison_intr_clr_ack_pclk)
      ,.reg_ddrc_wr_poison_intr_clr (reg_ddrc_wr_poison_intr_clr)
      ,.reg_ddrc_rd_poison_slverr_en (reg_ddrc_rd_poison_slverr_en)
      ,.reg_ddrc_rd_poison_intr_en (reg_ddrc_rd_poison_intr_en)
      ,.reg_ddrc_rd_poison_intr_clr_ack_pclk (reg_ddrc_rd_poison_intr_clr_ack_pclk)
      ,.reg_ddrc_rd_poison_intr_clr (reg_ddrc_rd_poison_intr_clr)
   //------------------------
   // Register REGB_DDRC_CH0.POISONSTAT
   //------------------------
      ,.r65_poisonstat (r65_poisonstat)
      ,.ddrc_reg_wr_poison_intr_0 (ddrc_reg_wr_poison_intr_0)
      ,.ddrc_reg_rd_poison_intr_0 (ddrc_reg_rd_poison_intr_0)
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
      ,.r215_opctrl0 (r215_opctrl0[REG_WIDTH-1:0])
      ,.reg_ddrc_dis_wc (reg_ddrc_dis_wc_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
      ,.r216_opctrl1 (r216_opctrl1)
      ,.r216_opctrl1_ack_pclk (r216_opctrl1_ack_pclk)
      ,.reg_ddrc_dis_dq (reg_ddrc_dis_dq)
      ,.reg_ddrc_dis_hif (reg_ddrc_dis_hif)
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCAM
   //------------------------
      ,.r217_opctrlcam (r217_opctrlcam)
      ,.ddrc_reg_dbg_hpr_q_depth (ddrc_reg_dbg_hpr_q_depth)
      ,.ddrc_reg_dbg_lpr_q_depth (ddrc_reg_dbg_lpr_q_depth)
      ,.ddrc_reg_dbg_w_q_depth (ddrc_reg_dbg_w_q_depth)
      ,.ddrc_reg_dbg_stall (ddrc_reg_dbg_stall)
      ,.ddrc_reg_dbg_rd_q_empty (ddrc_reg_dbg_rd_q_empty)
      ,.ddrc_reg_dbg_wr_q_empty (ddrc_reg_dbg_wr_q_empty)
      ,.ddrc_reg_rd_data_pipeline_empty (ddrc_reg_rd_data_pipeline_empty)
      ,.ddrc_reg_wr_data_pipeline_empty (ddrc_reg_wr_data_pipeline_empty)
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
      ,.r218_opctrlcmd (r218_opctrlcmd)
      ,.r218_opctrlcmd_ack_pclk (r218_opctrlcmd_ack_pclk)
      ,.reg_ddrc_zq_calib_short_ack_pclk (reg_ddrc_zq_calib_short_ack_pclk)
      ,.ff_regb_ddrc_ch0_zq_calib_short_saved (ff_regb_ddrc_ch0_zq_calib_short_saved)
      ,.reg_ddrc_zq_calib_short (reg_ddrc_zq_calib_short)
      ,.reg_ddrc_ctrlupd_ack_pclk (reg_ddrc_ctrlupd_ack_pclk)
      ,.ff_regb_ddrc_ch0_ctrlupd_saved (ff_regb_ddrc_ch0_ctrlupd_saved)
      ,.reg_ddrc_ctrlupd (reg_ddrc_ctrlupd)
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLSTAT
   //------------------------
      ,.r219_opctrlstat (r219_opctrlstat)
      ,.ddrc_reg_zq_calib_short_busy_int (ddrc_reg_zq_calib_short_busy_int)
      ,.ddrc_reg_zq_calib_short_busy (ddrc_reg_zq_calib_short_busy)
      ,.ddrc_reg_ctrlupd_busy_int (ddrc_reg_ctrlupd_busy_int)
      ,.ddrc_reg_ctrlupd_busy (ddrc_reg_ctrlupd_busy)
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
      ,.r221_oprefctrl0 (r221_oprefctrl0)
      ,.r221_oprefctrl0_ack_pclk (r221_oprefctrl0_ack_pclk)
      ,.reg_ddrc_rank0_refresh_ack_pclk (reg_ddrc_rank0_refresh_ack_pclk)
      ,.ff_regb_ddrc_ch0_rank0_refresh_saved (ff_regb_ddrc_ch0_rank0_refresh_saved)
      ,.reg_ddrc_rank0_refresh (reg_ddrc_rank0_refresh)
   //------------------------
   // Register REGB_DDRC_CH0.OPREFSTAT0
   //------------------------
      ,.r223_oprefstat0 (r223_oprefstat0)
      ,.ddrc_reg_rank0_refresh_busy_int (ddrc_reg_rank0_refresh_busy_int)
      ,.ddrc_reg_rank0_refresh_busy (ddrc_reg_rank0_refresh_busy)
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
      ,.r225_swctl (r225_swctl[REG_WIDTH-1:0])
      ,.reg_ddrc_sw_done (reg_ddrc_sw_done)
   //------------------------
   // Register REGB_DDRC_CH0.SWSTAT
   //------------------------
      ,.r226_swstat (r226_swstat)
      ,.ddrc_reg_sw_done_ack (ddrc_reg_sw_done_ack)
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
      ,.r230_dbictl (r230_dbictl)
      ,.r230_dbictl_ack_pclk (r230_dbictl_ack_pclk)
      ,.reg_ddrc_dm_en (reg_ddrc_dm_en)
      ,.reg_ddrc_wr_dbi_en (reg_ddrc_wr_dbi_en)
      ,.reg_ddrc_rd_dbi_en (reg_ddrc_rd_dbi_en)
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
      ,.r232_odtmap (r232_odtmap[REG_WIDTH-1:0])
      ,.reg_ddrc_rank0_wr_odt (reg_ddrc_rank0_wr_odt_bcm36in)
      ,.reg_ddrc_rank0_rd_odt (reg_ddrc_rank0_rd_odt_bcm36in)
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
      ,.r233_datactl0 (r233_datactl0)
      ,.r233_datactl0_ack_pclk (r233_datactl0_ack_pclk)
      ,.reg_ddrc_rd_data_copy_en (reg_ddrc_rd_data_copy_en)
      ,.reg_ddrc_wr_data_copy_en (reg_ddrc_wr_data_copy_en)
      ,.reg_ddrc_wr_data_x_en (reg_ddrc_wr_data_x_en)
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
      ,.r234_swctlstatic (r234_swctlstatic[REG_WIDTH-1:0])
      ,.reg_ddrc_sw_static_unlock (reg_ddrc_sw_static_unlock)
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
      ,.r235_inittmg0 (r235_inittmg0)
      ,.r235_inittmg0_ack_pclk (r235_inittmg0_ack_pclk)
      ,.reg_ddrc_pre_cke_x1024 (reg_ddrc_pre_cke_x1024)
      ,.reg_ddrc_post_cke_x1024 (reg_ddrc_post_cke_x1024)
      ,.reg_ddrc_skip_dram_init (reg_ddrc_skip_dram_init)
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
      ,.r236_inittmg1 (r236_inittmg1)
      ,.r236_inittmg1_ack_pclk (r236_inittmg1_ack_pclk)
      ,.reg_ddrc_dram_rstn_x1024 (reg_ddrc_dram_rstn_x1024)
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_NUMBER
   //------------------------
      ,.r263_ddrctl_ver_number (r263_ddrctl_ver_number)
      ,.ddrc_reg_ver_number (ddrc_reg_ver_number)
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_TYPE
   //------------------------
      ,.r264_ddrctl_ver_type (r264_ddrctl_ver_type)
      ,.ddrc_reg_ver_type (ddrc_reg_ver_type)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
      ,.r450_addrmap3_map0 (r450_addrmap3_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_bank_b0_map0 (reg_ddrc_addrmap_bank_b0_map0_bcm36in)
      ,.reg_ddrc_addrmap_bank_b1_map0 (reg_ddrc_addrmap_bank_b1_map0_bcm36in)
      ,.reg_ddrc_addrmap_bank_b2_map0 (reg_ddrc_addrmap_bank_b2_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
      ,.r451_addrmap4_map0 (r451_addrmap4_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_bg_b0_map0 (reg_ddrc_addrmap_bg_b0_map0_bcm36in)
      ,.reg_ddrc_addrmap_bg_b1_map0 (reg_ddrc_addrmap_bg_b1_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
      ,.r452_addrmap5_map0 (r452_addrmap5_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_col_b7_map0 (reg_ddrc_addrmap_col_b7_map0_bcm36in)
      ,.reg_ddrc_addrmap_col_b8_map0 (reg_ddrc_addrmap_col_b8_map0_bcm36in)
      ,.reg_ddrc_addrmap_col_b9_map0 (reg_ddrc_addrmap_col_b9_map0_bcm36in)
      ,.reg_ddrc_addrmap_col_b10_map0 (reg_ddrc_addrmap_col_b10_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
      ,.r453_addrmap6_map0 (r453_addrmap6_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_col_b3_map0 (reg_ddrc_addrmap_col_b3_map0_bcm36in)
      ,.reg_ddrc_addrmap_col_b4_map0 (reg_ddrc_addrmap_col_b4_map0_bcm36in)
      ,.reg_ddrc_addrmap_col_b5_map0 (reg_ddrc_addrmap_col_b5_map0_bcm36in)
      ,.reg_ddrc_addrmap_col_b6_map0 (reg_ddrc_addrmap_col_b6_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
      ,.r454_addrmap7_map0 (r454_addrmap7_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b14_map0 (reg_ddrc_addrmap_row_b14_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b15_map0 (reg_ddrc_addrmap_row_b15_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b16_map0 (reg_ddrc_addrmap_row_b16_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b17_map0 (reg_ddrc_addrmap_row_b17_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
      ,.r455_addrmap8_map0 (r455_addrmap8_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b10_map0 (reg_ddrc_addrmap_row_b10_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b11_map0 (reg_ddrc_addrmap_row_b11_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b12_map0 (reg_ddrc_addrmap_row_b12_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b13_map0 (reg_ddrc_addrmap_row_b13_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
      ,.r456_addrmap9_map0 (r456_addrmap9_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b6_map0 (reg_ddrc_addrmap_row_b6_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b7_map0 (reg_ddrc_addrmap_row_b7_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b8_map0 (reg_ddrc_addrmap_row_b8_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b9_map0 (reg_ddrc_addrmap_row_b9_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
      ,.r457_addrmap10_map0 (r457_addrmap10_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b2_map0 (reg_ddrc_addrmap_row_b2_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b3_map0 (reg_ddrc_addrmap_row_b3_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b4_map0 (reg_ddrc_addrmap_row_b4_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b5_map0 (reg_ddrc_addrmap_row_b5_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
      ,.r458_addrmap11_map0 (r458_addrmap11_map0[REG_WIDTH-1:0])
      ,.reg_ddrc_addrmap_row_b0_map0 (reg_ddrc_addrmap_row_b0_map0_bcm36in)
      ,.reg_ddrc_addrmap_row_b1_map0 (reg_ddrc_addrmap_row_b1_map0_bcm36in)
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
      ,.r459_addrmap12_map0 (r459_addrmap12_map0)
      ,.r459_addrmap12_map0_ack_pclk (r459_addrmap12_map0_ack_pclk)
      ,.reg_ddrc_nonbinary_device_density_map0 (reg_ddrc_nonbinary_device_density_map0)
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
      ,.r474_pccfg_port0 (r474_pccfg_port0[REG_WIDTH-1:0])
      ,.reg_arb_go2critical_en_port0 (reg_arb_go2critical_en_port0_bcm36in)
      ,.reg_arb_pagematch_limit_port0 (reg_arb_pagematch_limit_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
      ,.r475_pcfgr_port0 (r475_pcfgr_port0[REG_WIDTH-1:0])
      ,.reg_arb_rd_port_priority_port0 (reg_arb_rd_port_priority_port0_bcm36in)
      ,.reg_arb_rd_port_aging_en_port0 (reg_arb_rd_port_aging_en_port0_bcm36in)
      ,.reg_arb_rd_port_urgent_en_port0 (reg_arb_rd_port_urgent_en_port0_bcm36in)
      ,.reg_arb_rd_port_pagematch_en_port0 (reg_arb_rd_port_pagematch_en_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
      ,.r476_pcfgw_port0 (r476_pcfgw_port0[REG_WIDTH-1:0])
      ,.reg_arb_wr_port_priority_port0 (reg_arb_wr_port_priority_port0_bcm36in)
      ,.reg_arb_wr_port_aging_en_port0 (reg_arb_wr_port_aging_en_port0_bcm36in)
      ,.reg_arb_wr_port_urgent_en_port0 (reg_arb_wr_port_urgent_en_port0_bcm36in)
      ,.reg_arb_wr_port_pagematch_en_port0 (reg_arb_wr_port_pagematch_en_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
      ,.r509_pctrl_port0 (r509_pctrl_port0)
      ,.r509_pctrl_port0_ack_pclk (r509_pctrl_port0_ack_pclk_i)
      ,.r509_pctrl_port0_ack_arba0_pclk (r509_pctrl_port0_ack_arba0_pclk_i)
      ,.reg_arb_port_en_port0 (reg_arb_port_en_port0)
      ,.reg_apb_port_en_port0 (reg_apb_port_en_port0)
      ,.reg_arba0_port_en_port0 (reg_arba0_port_en_port0)
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
      ,.r510_pcfgqos0_port0 (r510_pcfgqos0_port0[REG_WIDTH-1:0])
      ,.reg_arba0_rqos_map_level1_port0 (reg_arba0_rqos_map_level1_port0_bcm36in)
      ,.reg_arba0_rqos_map_region0_port0 (reg_arba0_rqos_map_region0_port0_bcm36in)
      ,.reg_arba0_rqos_map_region1_port0 (reg_arba0_rqos_map_region1_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
      ,.r511_pcfgqos1_port0 (r511_pcfgqos1_port0[REG_WIDTH-1:0])
      ,.reg_arb_rqos_map_timeoutb_port0 (reg_arb_rqos_map_timeoutb_port0_bcm36in)
      ,.reg_arb_rqos_map_timeoutr_port0 (reg_arb_rqos_map_timeoutr_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
      ,.r512_pcfgwqos0_port0 (r512_pcfgwqos0_port0[REG_WIDTH-1:0])
      ,.reg_arba0_wqos_map_level1_port0 (reg_arba0_wqos_map_level1_port0_bcm36in)
      ,.reg_arba0_wqos_map_level2_port0 (reg_arba0_wqos_map_level2_port0_bcm36in)
      ,.reg_arba0_wqos_map_region0_port0 (reg_arba0_wqos_map_region0_port0_bcm36in)
      ,.reg_arba0_wqos_map_region1_port0 (reg_arba0_wqos_map_region1_port0_bcm36in)
      ,.reg_arba0_wqos_map_region2_port0 (reg_arba0_wqos_map_region2_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
      ,.r513_pcfgwqos1_port0 (r513_pcfgwqos1_port0[REG_WIDTH-1:0])
      ,.reg_arb_wqos_map_timeout1_port0 (reg_arb_wqos_map_timeout1_port0_bcm36in)
      ,.reg_arb_wqos_map_timeout2_port0 (reg_arb_wqos_map_timeout2_port0_bcm36in)
   //------------------------
   // Register REGB_ARB_PORT0.PSTAT
   //------------------------
      ,.r535_pstat_port0 (r535_pstat_port0)
      ,.arb_reg_rd_port_busy_0_port0 (arb_reg_rd_port_busy_0_port0)
      ,.arb_reg_wr_port_busy_0_port0 (arb_reg_wr_port_busy_0_port0)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
      ,.r1882_dramset1tmg0_freq0 (r1882_dramset1tmg0_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_ras_min_freq0 (reg_ddrc_t_ras_min_freq0_bcm36in)
      ,.reg_ddrc_t_ras_max_freq0 (reg_ddrc_t_ras_max_freq0_bcm36in)
      ,.reg_ddrc_t_faw_freq0 (reg_ddrc_t_faw_freq0_bcm36in)
      ,.reg_ddrc_wr2pre_freq0 (reg_ddrc_wr2pre_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
      ,.r1883_dramset1tmg1_freq0 (r1883_dramset1tmg1_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_rc_freq0 (reg_ddrc_t_rc_freq0_bcm36in)
      ,.reg_ddrc_rd2pre_freq0 (reg_ddrc_rd2pre_freq0_bcm36in)
      ,.reg_ddrc_t_xp_freq0 (reg_ddrc_t_xp_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
      ,.r1884_dramset1tmg2_freq0 (r1884_dramset1tmg2_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_wr2rd_freq0 (reg_ddrc_wr2rd_freq0_bcm36in)
      ,.reg_ddrc_rd2wr_freq0 (reg_ddrc_rd2wr_freq0_bcm36in)
      ,.reg_ddrc_read_latency_freq0 (reg_ddrc_read_latency_freq0_bcm36in)
      ,.reg_ddrc_write_latency_freq0 (reg_ddrc_write_latency_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
      ,.r1885_dramset1tmg3_freq0 (r1885_dramset1tmg3_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_wr2mr_freq0 (reg_ddrc_wr2mr_freq0_bcm36in)
      ,.reg_ddrc_rd2mr_freq0 (reg_ddrc_rd2mr_freq0_bcm36in)
      ,.reg_ddrc_t_mr_freq0 (reg_ddrc_t_mr_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
      ,.r1886_dramset1tmg4_freq0 (r1886_dramset1tmg4_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_rp_freq0 (reg_ddrc_t_rp_freq0_bcm36in)
      ,.reg_ddrc_t_rrd_freq0 (reg_ddrc_t_rrd_freq0_bcm36in)
      ,.reg_ddrc_t_ccd_freq0 (reg_ddrc_t_ccd_freq0_bcm36in)
      ,.reg_ddrc_t_rcd_freq0 (reg_ddrc_t_rcd_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
      ,.r1887_dramset1tmg5_freq0 (r1887_dramset1tmg5_freq0)
      ,.r1887_dramset1tmg5_freq0_ack_pclk (r1887_dramset1tmg5_freq0_ack_pclk)
      ,.reg_ddrc_t_cke_freq0 (reg_ddrc_t_cke_freq0)
      ,.reg_ddrc_t_ckesr_freq0 (reg_ddrc_t_ckesr_freq0)
      ,.reg_ddrc_t_cksre_freq0 (reg_ddrc_t_cksre_freq0)
      ,.reg_ddrc_t_cksrx_freq0 (reg_ddrc_t_cksrx_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
      ,.r1888_dramset1tmg6_freq0 (r1888_dramset1tmg6_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_ckcsx_freq0 (reg_ddrc_t_ckcsx_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
      ,.r1889_dramset1tmg7_freq0 (r1889_dramset1tmg7_freq0)
      ,.r1889_dramset1tmg7_freq0_ack_pclk (r1889_dramset1tmg7_freq0_ack_pclk)
      ,.reg_ddrc_t_csh_freq0 (reg_ddrc_t_csh_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
      ,.r1891_dramset1tmg9_freq0 (r1891_dramset1tmg9_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_wr2rd_s_freq0 (reg_ddrc_wr2rd_s_freq0_bcm36in)
      ,.reg_ddrc_t_rrd_s_freq0 (reg_ddrc_t_rrd_s_freq0_bcm36in)
      ,.reg_ddrc_t_ccd_s_freq0 (reg_ddrc_t_ccd_s_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
      ,.r1894_dramset1tmg12_freq0 (r1894_dramset1tmg12_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_cmdcke_freq0 (reg_ddrc_t_cmdcke_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
      ,.r1895_dramset1tmg13_freq0 (r1895_dramset1tmg13_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_ppd_freq0 (reg_ddrc_t_ppd_freq0_bcm36in)
      ,.reg_ddrc_t_ccd_mw_freq0 (reg_ddrc_t_ccd_mw_freq0_bcm36in)
      ,.reg_ddrc_odtloff_freq0 (reg_ddrc_odtloff_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
      ,.r1896_dramset1tmg14_freq0 (r1896_dramset1tmg14_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_xsr_freq0 (reg_ddrc_t_xsr_freq0_bcm36in)
      ,.reg_ddrc_t_osco_freq0 (reg_ddrc_t_osco_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
      ,.r1905_dramset1tmg23_freq0 (r1905_dramset1tmg23_freq0)
      ,.r1905_dramset1tmg23_freq0_ack_pclk (r1905_dramset1tmg23_freq0_ack_pclk)
      ,.reg_ddrc_t_pdn_freq0 (reg_ddrc_t_pdn_freq0)
      ,.reg_ddrc_t_xsr_dsm_x1024_freq0 (reg_ddrc_t_xsr_dsm_x1024_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
      ,.r1906_dramset1tmg24_freq0 (r1906_dramset1tmg24_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_max_wr_sync_freq0 (reg_ddrc_max_wr_sync_freq0_bcm36in)
      ,.reg_ddrc_max_rd_sync_freq0 (reg_ddrc_max_rd_sync_freq0_bcm36in)
      ,.reg_ddrc_rd2wr_s_freq0 (reg_ddrc_rd2wr_s_freq0_bcm36in)
      ,.reg_ddrc_bank_org_freq0 (reg_ddrc_bank_org_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
      ,.r1907_dramset1tmg25_freq0 (r1907_dramset1tmg25_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_rda2pre_freq0 (reg_ddrc_rda2pre_freq0_bcm36in)
      ,.reg_ddrc_wra2pre_freq0 (reg_ddrc_wra2pre_freq0_bcm36in)
      ,.reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0 (reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
      ,.r1912_dramset1tmg30_freq0 (r1912_dramset1tmg30_freq0)
      ,.r1912_dramset1tmg30_freq0_ack_pclk (r1912_dramset1tmg30_freq0_ack_pclk)
      ,.reg_ddrc_mrr2rd_freq0 (reg_ddrc_mrr2rd_freq0)
      ,.reg_ddrc_mrr2wr_freq0 (reg_ddrc_mrr2wr_freq0)
      ,.reg_ddrc_mrr2mrw_freq0 (reg_ddrc_mrr2mrw_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
      ,.r1938_initmr0_freq0 (r1938_initmr0_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_emr_freq0 (reg_ddrc_emr_freq0_bcm36in)
      ,.reg_ddrc_mr_freq0 (reg_ddrc_mr_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
      ,.r1939_initmr1_freq0 (r1939_initmr1_freq0)
      ,.r1939_initmr1_freq0_ack_pclk (r1939_initmr1_freq0_ack_pclk)
      ,.reg_ddrc_emr3_freq0 (reg_ddrc_emr3_freq0)
      ,.reg_ddrc_emr2_freq0 (reg_ddrc_emr2_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
      ,.r1940_initmr2_freq0 (r1940_initmr2_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_mr5_freq0 (reg_ddrc_mr5_freq0_bcm36in)
      ,.reg_ddrc_mr4_freq0 (reg_ddrc_mr4_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
      ,.r1941_initmr3_freq0 (r1941_initmr3_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_mr6_freq0 (reg_ddrc_mr6_freq0_bcm36in)
      ,.reg_ddrc_mr22_freq0 (reg_ddrc_mr22_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
      ,.r1942_dfitmg0_freq0 (r1942_dfitmg0_freq0)
      ,.r1942_dfitmg0_freq0_ack_pclk (r1942_dfitmg0_freq0_ack_pclk)
      ,.reg_ddrc_dfi_tphy_wrlat_freq0 (reg_ddrc_dfi_tphy_wrlat_freq0)
      ,.reg_ddrc_dfi_tphy_wrdata_freq0 (reg_ddrc_dfi_tphy_wrdata_freq0)
      ,.reg_ddrc_dfi_t_rddata_en_freq0 (reg_ddrc_dfi_t_rddata_en_freq0)
      ,.reg_ddrc_dfi_t_ctrl_delay_freq0 (reg_ddrc_dfi_t_ctrl_delay_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
      ,.r1943_dfitmg1_freq0 (r1943_dfitmg1_freq0)
      ,.r1943_dfitmg1_freq0_ack_pclk (r1943_dfitmg1_freq0_ack_pclk)
      ,.reg_ddrc_dfi_t_dram_clk_enable_freq0 (reg_ddrc_dfi_t_dram_clk_enable_freq0)
      ,.reg_ddrc_dfi_t_dram_clk_disable_freq0 (reg_ddrc_dfi_t_dram_clk_disable_freq0)
      ,.reg_ddrc_dfi_t_wrdata_delay_freq0 (reg_ddrc_dfi_t_wrdata_delay_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
      ,.r1944_dfitmg2_freq0 (r1944_dfitmg2_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_tphy_wrcslat_freq0 (reg_ddrc_dfi_tphy_wrcslat_freq0_bcm36in)
      ,.reg_ddrc_dfi_tphy_rdcslat_freq0 (reg_ddrc_dfi_tphy_rdcslat_freq0_bcm36in)
      ,.reg_ddrc_dfi_twck_delay_freq0 (reg_ddrc_dfi_twck_delay_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
      ,.r1946_dfitmg4_freq0 (r1946_dfitmg4_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_twck_dis_freq0 (reg_ddrc_dfi_twck_dis_freq0_bcm36in)
      ,.reg_ddrc_dfi_twck_en_wr_freq0 (reg_ddrc_dfi_twck_en_wr_freq0_bcm36in)
      ,.reg_ddrc_dfi_twck_en_rd_freq0 (reg_ddrc_dfi_twck_en_rd_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
      ,.r1947_dfitmg5_freq0 (r1947_dfitmg5_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_twck_toggle_post_freq0 (reg_ddrc_dfi_twck_toggle_post_freq0_bcm36in)
      ,.reg_ddrc_dfi_twck_toggle_cs_freq0 (reg_ddrc_dfi_twck_toggle_cs_freq0_bcm36in)
      ,.reg_ddrc_dfi_twck_toggle_freq0 (reg_ddrc_dfi_twck_toggle_freq0_bcm36in)
      ,.reg_ddrc_dfi_twck_fast_toggle_freq0 (reg_ddrc_dfi_twck_fast_toggle_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
      ,.r1949_dfilptmg0_freq0 (r1949_dfilptmg0_freq0)
      ,.r1949_dfilptmg0_freq0_ack_pclk (r1949_dfilptmg0_freq0_ack_pclk)
      ,.reg_ddrc_dfi_lp_wakeup_pd_freq0 (reg_ddrc_dfi_lp_wakeup_pd_freq0)
      ,.reg_ddrc_dfi_lp_wakeup_sr_freq0 (reg_ddrc_dfi_lp_wakeup_sr_freq0)
      ,.reg_ddrc_dfi_lp_wakeup_dsm_freq0 (reg_ddrc_dfi_lp_wakeup_dsm_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
      ,.r1950_dfilptmg1_freq0 (r1950_dfilptmg1_freq0)
      ,.r1950_dfilptmg1_freq0_ack_pclk (r1950_dfilptmg1_freq0_ack_pclk)
      ,.reg_ddrc_dfi_lp_wakeup_data_freq0 (reg_ddrc_dfi_lp_wakeup_data_freq0)
      ,.reg_ddrc_dfi_tlp_resp_freq0 (reg_ddrc_dfi_tlp_resp_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
      ,.r1951_dfiupdtmg0_freq0 (r1951_dfiupdtmg0_freq0)
      ,.r1951_dfiupdtmg0_freq0_ack_pclk (r1951_dfiupdtmg0_freq0_ack_pclk)
      ,.reg_ddrc_dfi_t_ctrlup_min_freq0 (reg_ddrc_dfi_t_ctrlup_min_freq0)
      ,.reg_ddrc_dfi_t_ctrlup_max_freq0 (reg_ddrc_dfi_t_ctrlup_max_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
      ,.r1952_dfiupdtmg1_freq0 (r1952_dfiupdtmg1_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0 (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0_bcm36in)
      ,.reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0 (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
      ,.r1953_dfimsgtmg0_freq0 (r1953_dfimsgtmg0_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_dfi_t_ctrlmsg_resp_freq0 (reg_ddrc_dfi_t_ctrlmsg_resp_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
      ,.r1955_rfshset1tmg0_freq0 (r1955_rfshset1tmg0_freq0)
      ,.r1955_rfshset1tmg0_freq0_ack_pclk (r1955_rfshset1tmg0_freq0_ack_pclk)
      ,.reg_ddrc_t_refi_x1_x32_freq0 (reg_ddrc_t_refi_x1_x32_freq0)
      ,.reg_ddrc_refresh_to_x1_x32_freq0 (reg_ddrc_refresh_to_x1_x32_freq0)
      ,.reg_ddrc_refresh_margin_freq0 (reg_ddrc_refresh_margin_freq0)
      ,.reg_ddrc_t_refi_x1_sel_freq0 (reg_ddrc_t_refi_x1_sel_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
      ,.r1956_rfshset1tmg1_freq0 (r1956_rfshset1tmg1_freq0)
      ,.r1956_rfshset1tmg1_freq0_ack_pclk (r1956_rfshset1tmg1_freq0_ack_pclk)
      ,.reg_ddrc_t_rfc_min_freq0 (reg_ddrc_t_rfc_min_freq0)
      ,.reg_ddrc_t_rfc_min_ab_freq0 (reg_ddrc_t_rfc_min_ab_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
      ,.r1957_rfshset1tmg2_freq0 (r1957_rfshset1tmg2_freq0)
      ,.r1957_rfshset1tmg2_freq0_ack_pclk (r1957_rfshset1tmg2_freq0_ack_pclk)
      ,.reg_ddrc_t_pbr2pbr_freq0 (reg_ddrc_t_pbr2pbr_freq0)
      ,.reg_ddrc_t_pbr2act_freq0 (reg_ddrc_t_pbr2act_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
      ,.r1958_rfshset1tmg3_freq0 (r1958_rfshset1tmg3_freq0)
      ,.r1958_rfshset1tmg3_freq0_ack_pclk (r1958_rfshset1tmg3_freq0_ack_pclk)
      ,.reg_ddrc_refresh_to_ab_x32_freq0 (reg_ddrc_refresh_to_ab_x32_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
      ,.r1975_zqset1tmg0_freq0 (r1975_zqset1tmg0_freq0)
      ,.r1975_zqset1tmg0_freq0_ack_pclk (r1975_zqset1tmg0_freq0_ack_pclk)
      ,.reg_ddrc_t_zq_long_nop_freq0 (reg_ddrc_t_zq_long_nop_freq0)
      ,.reg_ddrc_t_zq_short_nop_freq0 (reg_ddrc_t_zq_short_nop_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
      ,.r1976_zqset1tmg1_freq0 (r1976_zqset1tmg1_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_t_zq_short_interval_x1024_freq0 (reg_ddrc_t_zq_short_interval_x1024_freq0_bcm36in)
      ,.reg_ddrc_t_zq_reset_nop_freq0 (reg_ddrc_t_zq_reset_nop_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
      ,.r1985_dqsoscctl0_freq0 (r1985_dqsoscctl0_freq0)
      ,.r1985_dqsoscctl0_freq0_ack_pclk (r1985_dqsoscctl0_freq0_ack_pclk)
      ,.reg_ddrc_dqsosc_enable_freq0 (reg_ddrc_dqsosc_enable_freq0)
      ,.reg_ddrc_dqsosc_interval_unit_freq0 (reg_ddrc_dqsosc_interval_unit_freq0)
      ,.reg_ddrc_dqsosc_interval_freq0 (reg_ddrc_dqsosc_interval_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
      ,.r1986_derateint_freq0 (r1986_derateint_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_mr4_read_interval_freq0 (reg_ddrc_mr4_read_interval_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
      ,.r1987_derateval0_freq0 (r1987_derateval0_freq0)
      ,.r1987_derateval0_freq0_ack_pclk (r1987_derateval0_freq0_ack_pclk)
      ,.reg_ddrc_derated_t_rrd_freq0 (reg_ddrc_derated_t_rrd_freq0)
      ,.reg_ddrc_derated_t_rp_freq0 (reg_ddrc_derated_t_rp_freq0)
      ,.reg_ddrc_derated_t_ras_min_freq0 (reg_ddrc_derated_t_ras_min_freq0)
      ,.reg_ddrc_derated_t_rcd_freq0 (reg_ddrc_derated_t_rcd_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
      ,.r1988_derateval1_freq0 (r1988_derateval1_freq0)
      ,.r1988_derateval1_freq0_ack_pclk (r1988_derateval1_freq0_ack_pclk)
      ,.reg_ddrc_derated_t_rc_freq0 (reg_ddrc_derated_t_rc_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
      ,.r1989_hwlptmg0_freq0 (r1989_hwlptmg0_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_hw_lp_idle_x32_freq0 (reg_ddrc_hw_lp_idle_x32_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
      ,.r1990_schedtmg0_freq0 (r1990_schedtmg0_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_pageclose_timer_freq0 (reg_ddrc_pageclose_timer_freq0_bcm36in)
      ,.reg_ddrc_rdwr_idle_gap_freq0 (reg_ddrc_rdwr_idle_gap_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
      ,.r1991_perfhpr1_freq0 (r1991_perfhpr1_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_hpr_max_starve_freq0 (reg_ddrc_hpr_max_starve_freq0_bcm36in)
      ,.reg_ddrc_hpr_xact_run_length_freq0 (reg_ddrc_hpr_xact_run_length_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
      ,.r1992_perflpr1_freq0 (r1992_perflpr1_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_lpr_max_starve_freq0 (reg_ddrc_lpr_max_starve_freq0_bcm36in)
      ,.reg_ddrc_lpr_xact_run_length_freq0 (reg_ddrc_lpr_xact_run_length_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
      ,.r1993_perfwr1_freq0 (r1993_perfwr1_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_w_max_starve_freq0 (reg_ddrc_w_max_starve_freq0_bcm36in)
      ,.reg_ddrc_w_xact_run_length_freq0 (reg_ddrc_w_xact_run_length_freq0_bcm36in)
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
      ,.r1994_tmgcfg_freq0 (r1994_tmgcfg_freq0)
      ,.r1994_tmgcfg_freq0_ack_pclk (r1994_tmgcfg_freq0_ack_pclk)
      ,.reg_ddrc_frequency_ratio_freq0 (reg_ddrc_frequency_ratio_freq0)
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
      ,.r1997_pwrtmg_freq0 (r1997_pwrtmg_freq0[REG_WIDTH-1:0])
      ,.reg_ddrc_powerdown_to_x32_freq0 (reg_ddrc_powerdown_to_x32_freq0_bcm36in)
      ,.reg_ddrc_selfref_to_x32_freq0 (reg_ddrc_selfref_to_x32_freq0_bcm36in)




      ,.core_derate_temp_limit_intr     (core_derate_temp_limit_intr)
      ,.pclk_derate_temp_limit_intr     (pclk_derate_temp_limit_intr)
      ,.derate_sync_ack_c2p             (derate_sync_ack_c2p)


);

   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_derate_mr4_tuf_dis (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_derate_mr4_tuf_dis_bcm36in),
       .data_d     (reg_ddrc_derate_mr4_tuf_dis)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_hw_lp_en (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_hw_lp_en_bcm36in),
       .data_d     (reg_ddrc_hw_lp_en)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_hw_lp_exit_idle_en (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_hw_lp_exit_idle_en_bcm36in),
       .data_d     (reg_ddrc_hw_lp_exit_idle_en)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dis_srx_zqcl (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dis_srx_zqcl_bcm36in),
       .data_d     (reg_ddrc_dis_srx_zqcl)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dqsosc_runtime (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dqsosc_runtime_bcm36in),
       .data_d     (reg_ddrc_dqsosc_runtime)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wck2dqo_runtime (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wck2dqo_runtime_bcm36in),
       .data_d     (reg_ddrc_wck2dqo_runtime)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dis_dqsosc_srx (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dis_dqsosc_srx_bcm36in),
       .data_d     (reg_ddrc_dis_dqsosc_srx)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_prefer_write (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_prefer_write_bcm36in),
       .data_d     (reg_ddrc_prefer_write)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_pageclose (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_pageclose_bcm36in),
       .data_d     (reg_ddrc_pageclose)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_opt_wrcam_fill_level (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_opt_wrcam_fill_level_bcm36in),
       .data_d     (reg_ddrc_opt_wrcam_fill_level)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dis_opt_ntt_by_act (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dis_opt_ntt_by_act_bcm36in),
       .data_d     (reg_ddrc_dis_opt_ntt_by_act)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dis_opt_ntt_by_pre (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dis_opt_ntt_by_pre_bcm36in),
       .data_d     (reg_ddrc_dis_opt_ntt_by_pre)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_autopre_rmw (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_autopre_rmw_bcm36in),
       .data_d     (reg_ddrc_autopre_rmw)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_RDCMD_ENTRY_BITS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_lpr_num_entries (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_lpr_num_entries_bcm36in),
       .data_d     (reg_ddrc_lpr_num_entries)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_lpddr4_opt_act_timing (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_lpddr4_opt_act_timing_bcm36in),
       .data_d     (reg_ddrc_lpddr4_opt_act_timing)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_lpddr5_opt_act_timing (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_lpddr5_opt_act_timing_bcm36in),
       .data_d     (reg_ddrc_lpddr5_opt_act_timing)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_prefer_read (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_prefer_read_bcm36in),
       .data_d     (reg_ddrc_prefer_read)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dis_speculative_act (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dis_speculative_act_bcm36in),
       .data_d     (reg_ddrc_dis_speculative_act)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_delay_switch_write (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_delay_switch_write_bcm36in),
       .data_d     (reg_ddrc_delay_switch_write)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (3),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_page_hit_limit_wr (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_page_hit_limit_wr_bcm36in),
       .data_d     (reg_ddrc_page_hit_limit_wr)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (3),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_page_hit_limit_rd (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_page_hit_limit_rd_bcm36in),
       .data_d     (reg_ddrc_page_hit_limit_rd)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_opt_hit_gt_hpr (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_opt_hit_gt_hpr_bcm36in),
       .data_d     (reg_ddrc_opt_hit_gt_hpr)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_WRCMD_ENTRY_BITS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wrcam_lowthresh (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wrcam_lowthresh_bcm36in),
       .data_d     (reg_ddrc_wrcam_lowthresh)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_WRCMD_ENTRY_BITS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wrcam_highthresh (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wrcam_highthresh_bcm36in),
       .data_d     (reg_ddrc_wrcam_highthresh)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_WRCMD_ENTRY_BITS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr_pghit_num_thresh (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr_pghit_num_thresh_bcm36in),
       .data_d     (reg_ddrc_wr_pghit_num_thresh)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_RDCMD_ENTRY_BITS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd_pghit_num_thresh (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd_pghit_num_thresh_bcm36in),
       .data_d     (reg_ddrc_rd_pghit_num_thresh)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd_act_idle_gap (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd_act_idle_gap_bcm36in),
       .data_d     (reg_ddrc_rd_act_idle_gap)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr_act_idle_gap (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr_act_idle_gap_bcm36in),
       .data_d     (reg_ddrc_wr_act_idle_gap)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd_page_exp_cycles (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd_page_exp_cycles_bcm36in),
       .data_d     (reg_ddrc_rd_page_exp_cycles)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr_page_exp_cycles (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr_page_exp_cycles_bcm36in),
       .data_d     (reg_ddrc_wr_page_exp_cycles)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dis_wc (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dis_wc_bcm36in),
       .data_d     (reg_ddrc_dis_wc)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_NUM_RANKS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rank0_wr_odt (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rank0_wr_odt_bcm36in),
       .data_d     (reg_ddrc_rank0_wr_odt)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`MEMC_NUM_RANKS),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rank0_rd_odt (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rank0_rd_odt_bcm36in),
       .data_d     (reg_ddrc_rank0_rd_odt)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_bank_b0_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_bank_b0_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_bank_b0_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_bank_b1_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_bank_b1_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_bank_b1_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_bank_b2_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_bank_b2_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_bank_b2_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_bg_b0_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_bg_b0_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_bg_b0_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_bg_b1_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_bg_b1_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_bg_b1_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b7_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b7_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b7_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b8_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b8_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b8_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b9_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b9_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b9_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b10_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b10_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b10_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b3_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b3_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b3_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b4_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b4_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b4_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b5_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b5_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b5_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_col_b6_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_col_b6_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_col_b6_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b14_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b14_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b14_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b15_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b15_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b15_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b16_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b16_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b16_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b17_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b17_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b17_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b10_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b10_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b10_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b11_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b11_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b11_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b12_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b12_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b12_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b13_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b13_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b13_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b6_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b6_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b6_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b7_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b7_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b7_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b8_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b8_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b8_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b9_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b9_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b9_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b2_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b2_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b2_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b3_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b3_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b3_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b4_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b4_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b4_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b5_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b5_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b5_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b0_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b0_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b0_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_addrmap_row_b1_map0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_addrmap_row_b1_map0_bcm36in),
       .data_d     (reg_ddrc_addrmap_row_b1_map0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_go2critical_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_go2critical_en_port0_bcm36in),
       .data_d     (reg_arb_go2critical_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_pagematch_limit_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_pagematch_limit_port0_bcm36in),
       .data_d     (reg_arb_pagematch_limit_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (10),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_rd_port_priority_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_rd_port_priority_port0_bcm36in),
       .data_d     (reg_arb_rd_port_priority_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_rd_port_aging_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_rd_port_aging_en_port0_bcm36in),
       .data_d     (reg_arb_rd_port_aging_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_rd_port_urgent_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_rd_port_urgent_en_port0_bcm36in),
       .data_d     (reg_arb_rd_port_urgent_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_rd_port_pagematch_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_rd_port_pagematch_en_port0_bcm36in),
       .data_d     (reg_arb_rd_port_pagematch_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (10),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_wr_port_priority_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_wr_port_priority_port0_bcm36in),
       .data_d     (reg_arb_wr_port_priority_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_wr_port_aging_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_wr_port_aging_en_port0_bcm36in),
       .data_d     (reg_arb_wr_port_aging_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_wr_port_urgent_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_wr_port_urgent_en_port0_bcm36in),
       .data_d     (reg_arb_wr_port_urgent_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (1),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_wr_port_pagematch_en_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_wr_port_pagematch_en_port0_bcm36in),
       .data_d     (reg_arb_wr_port_pagematch_en_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_RQOS_MLW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_rqos_map_level1_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_rqos_map_level1_port0_bcm36in),
       .data_d     (reg_arba0_rqos_map_level1_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_RQOS_RW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_rqos_map_region0_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_rqos_map_region0_port0_bcm36in),
       .data_d     (reg_arba0_rqos_map_region0_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_RQOS_RW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_rqos_map_region1_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_rqos_map_region1_port0_bcm36in),
       .data_d     (reg_arba0_rqos_map_region1_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_RQOS_TW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_rqos_map_timeoutb_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_rqos_map_timeoutb_port0_bcm36in),
       .data_d     (reg_arb_rqos_map_timeoutb_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_RQOS_TW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_rqos_map_timeoutr_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_rqos_map_timeoutr_port0_bcm36in),
       .data_d     (reg_arb_rqos_map_timeoutr_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_MLW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_wqos_map_level1_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_wqos_map_level1_port0_bcm36in),
       .data_d     (reg_arba0_wqos_map_level1_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_MLW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_wqos_map_level2_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_wqos_map_level2_port0_bcm36in),
       .data_d     (reg_arba0_wqos_map_level2_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_RW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_wqos_map_region0_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_wqos_map_region0_port0_bcm36in),
       .data_d     (reg_arba0_wqos_map_region0_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_RW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_wqos_map_region1_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_wqos_map_region1_port0_bcm36in),
       .data_d     (reg_arba0_wqos_map_region1_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_RW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arba0_wqos_map_region2_port0 (
   `ifndef SYNTHESIS
       .clk_d      (aclk_0),
       .rst_d_n    (aresetn_0),
   `endif
       .data_s     (reg_arba0_wqos_map_region2_port0_bcm36in),
       .data_d     (reg_arba0_wqos_map_region2_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_TW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_wqos_map_timeout1_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_wqos_map_timeout1_port0_bcm36in),
       .data_d     (reg_arb_wqos_map_timeout1_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (`UMCTL2_XPI_WQOS_TW),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_arb_wqos_map_timeout2_port0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_arb_wqos_map_timeout2_port0_bcm36in),
       .data_d     (reg_arb_wqos_map_timeout2_port0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ras_min_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ras_min_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ras_min_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ras_max_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ras_max_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ras_max_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_faw_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_faw_freq0_bcm36in),
       .data_d     (reg_ddrc_t_faw_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr2pre_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr2pre_freq0_bcm36in),
       .data_d     (reg_ddrc_wr2pre_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_rc_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_rc_freq0_bcm36in),
       .data_d     (reg_ddrc_t_rc_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd2pre_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd2pre_freq0_bcm36in),
       .data_d     (reg_ddrc_rd2pre_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_xp_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_xp_freq0_bcm36in),
       .data_d     (reg_ddrc_t_xp_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr2rd_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr2rd_freq0_bcm36in),
       .data_d     (reg_ddrc_wr2rd_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd2wr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd2wr_freq0_bcm36in),
       .data_d     (reg_ddrc_rd2wr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_read_latency_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_read_latency_freq0_bcm36in),
       .data_d     (reg_ddrc_read_latency_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_write_latency_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_write_latency_freq0_bcm36in),
       .data_d     (reg_ddrc_write_latency_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr2mr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr2mr_freq0_bcm36in),
       .data_d     (reg_ddrc_wr2mr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd2mr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd2mr_freq0_bcm36in),
       .data_d     (reg_ddrc_rd2mr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_mr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_mr_freq0_bcm36in),
       .data_d     (reg_ddrc_t_mr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_rp_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_rp_freq0_bcm36in),
       .data_d     (reg_ddrc_t_rp_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_rrd_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_rrd_freq0_bcm36in),
       .data_d     (reg_ddrc_t_rrd_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ccd_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ccd_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ccd_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_rcd_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_rcd_freq0_bcm36in),
       .data_d     (reg_ddrc_t_rcd_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ckcsx_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ckcsx_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ckcsx_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wr2rd_s_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wr2rd_s_freq0_bcm36in),
       .data_d     (reg_ddrc_wr2rd_s_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_rrd_s_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_rrd_s_freq0_bcm36in),
       .data_d     (reg_ddrc_t_rrd_s_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (5),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ccd_s_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ccd_s_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ccd_s_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_cmdcke_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_cmdcke_freq0_bcm36in),
       .data_d     (reg_ddrc_t_cmdcke_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (4),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ppd_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ppd_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ppd_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_ccd_mw_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_ccd_mw_freq0_bcm36in),
       .data_d     (reg_ddrc_t_ccd_mw_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_odtloff_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_odtloff_freq0_bcm36in),
       .data_d     (reg_ddrc_odtloff_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (12),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_xsr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_xsr_freq0_bcm36in),
       .data_d     (reg_ddrc_t_xsr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (9),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_osco_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_osco_freq0_bcm36in),
       .data_d     (reg_ddrc_t_osco_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_max_wr_sync_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_max_wr_sync_freq0_bcm36in),
       .data_d     (reg_ddrc_max_wr_sync_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_max_rd_sync_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_max_rd_sync_freq0_bcm36in),
       .data_d     (reg_ddrc_max_rd_sync_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rd2wr_s_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rd2wr_s_freq0_bcm36in),
       .data_d     (reg_ddrc_rd2wr_s_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (2),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_bank_org_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_bank_org_freq0_bcm36in),
       .data_d     (reg_ddrc_bank_org_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rda2pre_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rda2pre_freq0_bcm36in),
       .data_d     (reg_ddrc_rda2pre_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_wra2pre_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_wra2pre_freq0_bcm36in),
       .data_d     (reg_ddrc_wra2pre_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (3),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0_bcm36in),
       .data_d     (reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_emr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_emr_freq0_bcm36in),
       .data_d     (reg_ddrc_emr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_mr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_mr_freq0_bcm36in),
       .data_d     (reg_ddrc_mr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_mr5_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_mr5_freq0_bcm36in),
       .data_d     (reg_ddrc_mr5_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_mr4_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_mr4_freq0_bcm36in),
       .data_d     (reg_ddrc_mr4_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_mr6_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_mr6_freq0_bcm36in),
       .data_d     (reg_ddrc_mr6_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_mr22_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_mr22_freq0_bcm36in),
       .data_d     (reg_ddrc_mr22_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      ((`DDRCTL_DDR_DUAL_CHANNEL_EN==1) ? 7 : 6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_tphy_wrcslat_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_tphy_wrcslat_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_tphy_wrcslat_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_tphy_rdcslat_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_tphy_rdcslat_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_tphy_rdcslat_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (6),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_delay_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_delay_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_delay_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_dis_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_dis_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_dis_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_en_wr_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_en_wr_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_en_wr_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_en_rd_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_en_rd_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_en_rd_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_toggle_post_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_toggle_post_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_toggle_post_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_toggle_cs_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_toggle_cs_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_toggle_cs_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_toggle_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_toggle_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_toggle_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_twck_fast_toggle_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_twck_fast_toggle_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_twck_fast_toggle_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_dfi_t_ctrlmsg_resp_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_dfi_t_ctrlmsg_resp_freq0_bcm36in),
       .data_d     (reg_ddrc_dfi_t_ctrlmsg_resp_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (20),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_zq_short_interval_x1024_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_zq_short_interval_x1024_freq0_bcm36in),
       .data_d     (reg_ddrc_t_zq_short_interval_x1024_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (10),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_t_zq_reset_nop_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_t_zq_reset_nop_freq0_bcm36in),
       .data_d     (reg_ddrc_t_zq_reset_nop_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (32),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_mr4_read_interval_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_mr4_read_interval_freq0_bcm36in),
       .data_d     (reg_ddrc_mr4_read_interval_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (12),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_hw_lp_idle_x32_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_hw_lp_idle_x32_freq0_bcm36in),
       .data_d     (reg_ddrc_hw_lp_idle_x32_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_pageclose_timer_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_pageclose_timer_freq0_bcm36in),
       .data_d     (reg_ddrc_pageclose_timer_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_rdwr_idle_gap_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_rdwr_idle_gap_freq0_bcm36in),
       .data_d     (reg_ddrc_rdwr_idle_gap_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_hpr_max_starve_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_hpr_max_starve_freq0_bcm36in),
       .data_d     (reg_ddrc_hpr_max_starve_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_hpr_xact_run_length_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_hpr_xact_run_length_freq0_bcm36in),
       .data_d     (reg_ddrc_hpr_xact_run_length_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_lpr_max_starve_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_lpr_max_starve_freq0_bcm36in),
       .data_d     (reg_ddrc_lpr_max_starve_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_lpr_xact_run_length_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_lpr_xact_run_length_freq0_bcm36in),
       .data_d     (reg_ddrc_lpr_xact_run_length_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (16),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_w_max_starve_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_w_max_starve_freq0_bcm36in),
       .data_d     (reg_ddrc_w_max_starve_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (8),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_w_xact_run_length_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_w_xact_run_length_freq0_bcm36in),
       .data_d     (reg_ddrc_w_xact_run_length_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (7),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_powerdown_to_x32_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_powerdown_to_x32_freq0_bcm36in),
       .data_d     (reg_ddrc_powerdown_to_x32_freq0)
       );
   DWC_ddr_umctl2_bcmwrp36_nhs_inject_x
   
     #(.WIDTH      (10),
       .DATA_DELAY (`UMCTL2_BCM36_NHS_DELAY),
       .INJECT_X   (`UMCTL2_BCM36_NHS_INJECT_X))
   U_bcm36_nhs_inject_x_reg_ddrc_selfref_to_x32_freq0 (
   `ifndef SYNTHESIS
       .clk_d      (core_ddrc_core_clk),
       .rst_d_n    (core_ddrc_rstn),
   `endif
       .data_s     (reg_ddrc_selfref_to_x32_freq0_bcm36in),
       .data_d     (reg_ddrc_selfref_to_x32_freq0)
       );


wire r0_mstr0_ack_pclk_done_p;
reg r0_mstr0_ack_pclk_r;
always @(posedge pclk or negedge presetn) begin : r0_mstr0_ack_pclk_r_PROC 
   if (~presetn) begin 
      r0_mstr0_ack_pclk_r <= 1'b0; 
   end else if (r0_mstr0_ack_pclk_done_p) begin 
      r0_mstr0_ack_pclk_r <= 1'b0; 
   end else if (r0_mstr0_ack_pclk_i) begin 
      r0_mstr0_ack_pclk_r <= 1'b1; 
   end else begin 
      r0_mstr0_ack_pclk_r <= r0_mstr0_ack_pclk_r; 
   end 
end 
reg r0_mstr0_ack_arba0_pclk_r;
always @(posedge pclk or negedge presetn) begin : r0_mstr0_ack_arba0_pclk_r_PROC 
   if (~presetn) begin 
      r0_mstr0_ack_arba0_pclk_r <= 1'b0; 
   end else if (r0_mstr0_ack_pclk_done_p) begin 
      r0_mstr0_ack_arba0_pclk_r <= 1'b0; 
   end else if (r0_mstr0_ack_arba0_pclk_i) begin 
       r0_mstr0_ack_arba0_pclk_r <= 1'b1; 
   end else begin 
      r0_mstr0_ack_arba0_pclk_r <= r0_mstr0_ack_arba0_pclk_r; 
   end 
end 
wire r0_mstr0_ack_pclk_done;
reg  r0_mstr0_ack_pclk_done_r;
reg  r0_mstr0_ack_pclk_done_p_d1;
reg  r0_mstr0_ack_pclk_done_p_d2;
assign  r0_mstr0_ack_pclk_done = 1'b1 
   & r0_mstr0_ack_pclk_r
   & r0_mstr0_ack_arba0_pclk_r
;
always @(posedge pclk or negedge presetn) begin :  r0_mstr0_ack_pclk_done_r_PROC 
   if (~presetn) begin 
      r0_mstr0_ack_pclk_done_r <= 1'b0; 
      r0_mstr0_ack_pclk_done_p_d1 <= 1'b0; 
      r0_mstr0_ack_pclk_done_p_d2 <= 1'b0; 
   end else begin 
      r0_mstr0_ack_pclk_done_r <= r0_mstr0_ack_pclk_done; 
      r0_mstr0_ack_pclk_done_p_d1 <= r0_mstr0_ack_pclk_done_p; 
      r0_mstr0_ack_pclk_done_p_d2 <= r0_mstr0_ack_pclk_done_p_d1; 
   end 
end 
assign r0_mstr0_ack_pclk_done_p =  r0_mstr0_ack_pclk_done_r &&  r0_mstr0_ack_pclk_done;
assign r0_mstr0_ack_pclk        =  r0_mstr0_ack_pclk_done_p_d2;
wire r509_pctrl_port0_ack_pclk_done_p;
reg r509_pctrl_port0_ack_pclk_r;
always @(posedge pclk or negedge presetn) begin : r509_pctrl_port0_ack_pclk_r_PROC 
   if (~presetn) begin 
      r509_pctrl_port0_ack_pclk_r <= 1'b0; 
   end else if (r509_pctrl_port0_ack_pclk_done_p) begin 
      r509_pctrl_port0_ack_pclk_r <= 1'b0; 
   end else if (r509_pctrl_port0_ack_pclk_i) begin 
      r509_pctrl_port0_ack_pclk_r <= 1'b1; 
   end else begin 
      r509_pctrl_port0_ack_pclk_r <= r509_pctrl_port0_ack_pclk_r; 
   end 
end 
reg r509_pctrl_port0_ack_arba0_pclk_r;
always @(posedge pclk or negedge presetn) begin : r509_pctrl_port0_ack_arba0_pclk_r_PROC 
   if (~presetn) begin 
      r509_pctrl_port0_ack_arba0_pclk_r <= 1'b0; 
   end else if (r509_pctrl_port0_ack_pclk_done_p) begin 
      r509_pctrl_port0_ack_arba0_pclk_r <= 1'b0; 
   end else if (r509_pctrl_port0_ack_arba0_pclk_i) begin 
       r509_pctrl_port0_ack_arba0_pclk_r <= 1'b1; 
   end else begin 
      r509_pctrl_port0_ack_arba0_pclk_r <= r509_pctrl_port0_ack_arba0_pclk_r; 
   end 
end 
wire r509_pctrl_port0_ack_pclk_done;
reg  r509_pctrl_port0_ack_pclk_done_r;
reg  r509_pctrl_port0_ack_pclk_done_p_d1;
reg  r509_pctrl_port0_ack_pclk_done_p_d2;
assign  r509_pctrl_port0_ack_pclk_done = 1'b1 
   & r509_pctrl_port0_ack_pclk_r
   & r509_pctrl_port0_ack_arba0_pclk_r
;
always @(posedge pclk or negedge presetn) begin :  r509_pctrl_port0_ack_pclk_done_r_PROC 
   if (~presetn) begin 
      r509_pctrl_port0_ack_pclk_done_r <= 1'b0; 
      r509_pctrl_port0_ack_pclk_done_p_d1 <= 1'b0; 
      r509_pctrl_port0_ack_pclk_done_p_d2 <= 1'b0; 
   end else begin 
      r509_pctrl_port0_ack_pclk_done_r <= r509_pctrl_port0_ack_pclk_done; 
      r509_pctrl_port0_ack_pclk_done_p_d1 <= r509_pctrl_port0_ack_pclk_done_p; 
      r509_pctrl_port0_ack_pclk_done_p_d2 <= r509_pctrl_port0_ack_pclk_done_p_d1; 
   end 
end 
assign r509_pctrl_port0_ack_pclk_done_p =  r509_pctrl_port0_ack_pclk_done_r &&  r509_pctrl_port0_ack_pclk_done;
assign r509_pctrl_port0_ack_pclk        =  r509_pctrl_port0_ack_pclk_done_p_d2;







endmodule // DWC_ddrctl_apb_slvtop
