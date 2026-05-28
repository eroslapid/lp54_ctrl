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

// Revision $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddrctl_apb_coreif.sv#3 $
`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"

module DWC_ddrctl_apb_coreif
import DWC_ddrctl_reg_pkg::*;
  #(parameter APB_AW          = 16,
    parameter REG_WIDTH       = 32,
    parameter BCM_F_SYNC_TYPE_C2P = 2,
    parameter BCM_F_SYNC_TYPE_P2C = 2,
    parameter BCM_R_SYNC_TYPE_C2P = 2,
    parameter BCM_R_SYNC_TYPE_P2C = 2,
    parameter REG_OUTPUTS_C2P = 1,
    parameter REG_OUTPUTS_P2C = 1,
    parameter BCM_VERIF_EN    = 1,
    parameter RW_REGS         = `UMCTL2_REGS_RW_REGS,
    parameter RWSELWIDTH      = RW_REGS
    ) 
  (
    input                apb_clk
    ,input               apb_rst
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input               core_ddrc_core_clk
    ,input               sync_core_ddrc_rstn
    ,input               core_ddrc_rstn
    ,input [RWSELWIDTH-1:0] rwselect
    ,input               write_en
//spyglass enable_block W240
    ,input               fwd_reset_val
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current implementation.
    ,input               aclk_0
    ,input               sync_aresetn_0
//spyglass enable_block W240

    ,input              core_derate_temp_limit_intr
   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
   ,input  [REG_WIDTH -1:0] r0_mstr0
   ,output r0_mstr0_ack_pclk
   ,output r0_mstr0_ack_arba0_pclk
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
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
   ,input  [REG_WIDTH -1:0] r4_mstr4
   ,output r4_mstr4_ack_pclk
   ,output reg_ddrc_wck_on // @core_ddrc_core_clk
   ,output reg_ddrc_wck_suspend_en // @core_ddrc_core_clk
   ,output reg_ddrc_ws_off_en // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.STAT
   //------------------------
   ,output  [REG_WIDTH -1:0] r5_stat
   ,input [2:0] ddrc_reg_operating_mode // @core_ddrc_core_clk
   ,input [((`DDRCTL_DDR_EN==1) ? (`MEMC_NUM_RANKS*2) : 2)-1:0] ddrc_reg_selfref_type // @core_ddrc_core_clk
   ,input [2:0] ddrc_reg_selfref_state // @core_ddrc_core_clk
   ,input ddrc_reg_selfref_cam_not_empty // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r8_mrctrl0
   ,output r8_mrctrl0_ack_pclk
   ,output reg_ddrc_mr_type // @core_ddrc_core_clk
   ,output reg_ddrc_sw_init_int // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_mr_rank // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_mr_addr // @core_ddrc_core_clk
   ,output reg_ddrc_mrr_done_clr_ack_pclk
   ,output reg_ddrc_mrr_done_clr // @core_ddrc_core_clk
   ,output reg_ddrc_mr_wr_ack_pclk
   ,input ff_regb_ddrc_ch0_mr_wr_saved
   ,output reg_ddrc_mr_wr // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r9_mrctrl1
   ,output r9_mrctrl1_ack_pclk
   ,output [(`MEMC_PAGE_BITS)-1:0] reg_ddrc_mr_data // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r11_mrstat
   ,output ddrc_reg_mr_wr_busy_int
   ,input ddrc_reg_mr_wr_busy // @core_ddrc_core_clk
   ,input ddrc_reg_mrr_done // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA0
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r12_mrrdata0
   ,input [31:0] ddrc_reg_mrr_data_lwr // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA1
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r13_mrrdata1
   ,input [31:0] ddrc_reg_mrr_data_upr // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r14_deratectl0
   ,output r14_deratectl0_ack_pclk
   ,output reg_ddrc_derate_enable // @core_ddrc_core_clk
   ,output reg_ddrc_lpddr4_refresh_mode // @core_ddrc_core_clk
   ,output reg_ddrc_derate_mr4_pause_fc // @core_ddrc_core_clk
   ,output reg_ddrc_dis_trefi_x6x8 // @core_ddrc_core_clk
   ,output reg_ddrc_dis_trefi_x0125 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r15_deratectl1
   ,output r15_deratectl1_ack_pclk
   ,output [(`MEMC_DRAM_TOTAL_DATA_WIDTH/4)-1:0] reg_ddrc_active_derate_byte_rank0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
   ,input  [REG_WIDTH-1:0] r19_deratectl5
   ,output reg_ddrc_derate_temp_limit_intr_en // @pclk
   ,output reg_ddrc_derate_temp_limit_intr_clr_ack_pclk
   ,output reg_ddrc_derate_temp_limit_intr_clr // @pclk
   ,output reg_ddrc_derate_temp_limit_intr_force_ack_pclk
   ,output reg_ddrc_derate_temp_limit_intr_force // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
   ,input  [REG_WIDTH-1:0] r20_deratectl6
   ,output reg_ddrc_derate_mr4_tuf_dis // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATESTAT0
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r21_deratestat0
   ,input ddrc_reg_derate_temp_limit_intr // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r23_deratedbgctl
   ,output r23_deratedbgctl_ack_pclk
   ,output [2:0] reg_ddrc_dbg_mr4_grp_sel // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dbg_mr4_rank_sel // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r24_deratedbgstat
   ,input [7:0] ddrc_reg_dbg_mr4_byte0 // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte1 // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte2 // @core_ddrc_core_clk
   ,input [7:0] ddrc_reg_dbg_mr4_byte3 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r25_pwrctl
   ,output r25_pwrctl_ack_pclk
   ,output [((`DDRCTL_DDR_EN==1) ? `MEMC_NUM_RANKS : 1)-1:0] reg_ddrc_selfref_en // @core_ddrc_core_clk
   ,output [((`DDRCTL_DDR_EN==1) ? `MEMC_NUM_RANKS : 1)-1:0] reg_ddrc_powerdown_en // @core_ddrc_core_clk
   ,output reg_ddrc_en_dfi_dram_clk_disable // @core_ddrc_core_clk
   ,output reg_ddrc_selfref_sw // @core_ddrc_core_clk
   ,output reg_ddrc_stay_in_selfref // @core_ddrc_core_clk
   ,output reg_ddrc_dis_cam_drain_selfref // @core_ddrc_core_clk
   ,output reg_ddrc_lpddr4_sr_allowed // @core_ddrc_core_clk
   ,output reg_ddrc_dsm_en // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
   ,input  [REG_WIDTH-1:0] r26_hwlpctl
   ,output reg_ddrc_hw_lp_en // @core_ddrc_core_clk
   ,output reg_ddrc_hw_lp_exit_idle_en // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r28_clkgatectl
   ,output r28_clkgatectl_ack_pclk
   ,output [5:0] reg_ddrc_bsm_clk_on // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
   ,input  [REG_WIDTH -1:0] r29_rfshmod0
   ,output r29_rfshmod0_ack_pclk
   ,output [5:0] reg_ddrc_refresh_burst // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_auto_refab_en // @core_ddrc_core_clk
   ,output reg_ddrc_per_bank_refresh // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r31_rfshctl0
   ,output r31_rfshctl0_ack_pclk
   ,output reg_ddrc_dis_auto_refresh // @core_ddrc_core_clk
   ,output reg_ddrc_refresh_update_level // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r34_zqctl0
   ,output r34_zqctl0_ack_pclk
   ,output reg_ddrc_zq_resistor_shared // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_zq // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r35_zqctl1
   ,output r35_zqctl1_ack_pclk
   ,output reg_ddrc_zq_reset_ack_pclk
   ,input ff_regb_ddrc_ch0_zq_reset_saved
   ,output reg_ddrc_zq_reset // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
   ,input  [REG_WIDTH-1:0] r36_zqctl2
   ,output reg_ddrc_dis_srx_zqcl // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r37_zqstat
   ,output ddrc_reg_zq_reset_busy_int
   ,input ddrc_reg_zq_reset_busy // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
   ,input  [REG_WIDTH-1:0] r38_dqsoscruntime
   ,output [7:0] reg_ddrc_dqsosc_runtime // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wck2dqo_runtime // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCSTAT0
   //------------------------
   ,output  [REG_WIDTH -1:0] r39_dqsoscstat0
   ,input [2:0] ddrc_reg_dqsosc_state // @core_ddrc_core_clk
   ,input [(`MEMC_NUM_RANKS)-1:0] ddrc_reg_dqsosc_per_rank_stat // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r40_dqsosccfg0
   ,output reg_ddrc_dis_dqsosc_srx // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
   ,input  [REG_WIDTH-1:0] r42_sched0
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
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
   ,input  [REG_WIDTH-1:0] r43_sched1
   ,output [3:0] reg_ddrc_delay_switch_write // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_page_hit_limit_wr // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_page_hit_limit_rd // @core_ddrc_core_clk
   ,output reg_ddrc_opt_hit_gt_hpr // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
   ,input  [REG_WIDTH-1:0] r45_sched3
   ,output [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wrcam_lowthresh // @core_ddrc_core_clk
   ,output [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wrcam_highthresh // @core_ddrc_core_clk
   ,output [(`MEMC_WRCMD_ENTRY_BITS)-1:0] reg_ddrc_wr_pghit_num_thresh // @core_ddrc_core_clk
   ,output [(`MEMC_RDCMD_ENTRY_BITS)-1:0] reg_ddrc_rd_pghit_num_thresh // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
   ,input  [REG_WIDTH-1:0] r46_sched4
   ,output [7:0] reg_ddrc_rd_act_idle_gap // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr_act_idle_gap // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd_page_exp_cycles // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr_page_exp_cycles // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r56_dfilpcfg0
   ,output r56_dfilpcfg0_ack_pclk
   ,output reg_ddrc_dfi_lp_en_pd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_sr // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_dsm // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_en_data // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_lp_data_req_en // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
   ,input  [REG_WIDTH -1:0] r57_dfiupd0
   ,output r57_dfiupd0_ack_pclk
   ,output reg_ddrc_dfi_phyupd_en // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd_pre_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd_srx // @core_ddrc_core_clk
   ,output reg_ddrc_dis_auto_ctrlupd // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
   ,input  [REG_WIDTH -1:0] r59_dfimisc
   ,output r59_dfimisc_ack_pclk
   ,output reg_ddrc_dfi_init_complete_en // @core_ddrc_core_clk
   ,output reg_ddrc_phy_dbi_mode // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_data_cs_polarity // @core_ddrc_core_clk
   ,output reg_ddrc_dfi_init_start // @core_ddrc_core_clk
   ,output reg_ddrc_lp_optimized_write // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_frequency // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dfi_freq_fsp // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_dfi_channel_mode // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFISTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r60_dfistat
   ,input ddrc_reg_dfi_init_complete // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_lp_ctrl_ack_stat // @core_ddrc_core_clk
   ,input ddrc_reg_dfi_lp_data_ack_stat // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
   ,input  [REG_WIDTH -1:0] r61_dfiphymstr
   ,output r61_dfiphymstr_ack_pclk
   ,output reg_ddrc_dfi_phymstr_en // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_phymstr_blk_ref_x32 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r62_dfi0msgctl0
   ,output r62_dfi0msgctl0_ack_pclk
   ,output [15:0] reg_ddrc_dfi0_ctrlmsg_data // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi0_ctrlmsg_cmd // @core_ddrc_core_clk
   ,output reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk
   ,output reg_ddrc_dfi0_ctrlmsg_tout_clr // @core_ddrc_core_clk
   ,output reg_ddrc_dfi0_ctrlmsg_req_ack_pclk
   ,input ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved
   ,output reg_ddrc_dfi0_ctrlmsg_req // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGSTAT0
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r63_dfi0msgstat0
   ,output ddrc_reg_dfi0_ctrlmsg_req_busy_int
   ,input ddrc_reg_dfi0_ctrlmsg_req_busy // @core_ddrc_core_clk
   ,input ddrc_reg_dfi0_ctrlmsg_resp_tout // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
   ,input  [REG_WIDTH -1:0] r64_poisoncfg
   ,output r64_poisoncfg_ack_pclk
   ,output reg_ddrc_wr_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_poison_intr_clr_ack_pclk
   ,output reg_ddrc_wr_poison_intr_clr // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_slverr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_poison_intr_clr_ack_pclk
   ,output reg_ddrc_rd_poison_intr_clr // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.POISONSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r65_poisonstat
   ,input ddrc_reg_wr_poison_intr_0 // @core_ddrc_core_clk
   ,input ddrc_reg_rd_poison_intr_0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
   ,input  [REG_WIDTH-1:0] r215_opctrl0
   ,output reg_ddrc_dis_wc // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r216_opctrl1
   ,output r216_opctrl1_ack_pclk
   ,output reg_ddrc_dis_dq // @core_ddrc_core_clk
   ,output reg_ddrc_dis_hif // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCAM
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r217_opctrlcam
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_hpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_RDCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_lpr_q_depth // @core_ddrc_core_clk
   ,input [(`MEMC_WRCMD_ENTRY_BITS+1)-1:0] ddrc_reg_dbg_w_q_depth // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_stall // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_rd_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_dbg_wr_q_empty // @core_ddrc_core_clk
   ,input ddrc_reg_rd_data_pipeline_empty // @core_ddrc_core_clk
   ,input ddrc_reg_wr_data_pipeline_empty // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
   ,input  [REG_WIDTH -1:0] r218_opctrlcmd
   ,output r218_opctrlcmd_ack_pclk
   ,output reg_ddrc_zq_calib_short_ack_pclk
   ,input ff_regb_ddrc_ch0_zq_calib_short_saved
   ,output reg_ddrc_zq_calib_short // @core_ddrc_core_clk
   ,output reg_ddrc_ctrlupd_ack_pclk
   ,input ff_regb_ddrc_ch0_ctrlupd_saved
   ,output reg_ddrc_ctrlupd // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r219_opctrlstat
   ,output ddrc_reg_zq_calib_short_busy_int
   ,input ddrc_reg_zq_calib_short_busy // @core_ddrc_core_clk
   ,output ddrc_reg_ctrlupd_busy_int
   ,input ddrc_reg_ctrlupd_busy // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r221_oprefctrl0
   ,output r221_oprefctrl0_ack_pclk
   ,output reg_ddrc_rank0_refresh_ack_pclk
   ,input ff_regb_ddrc_ch0_rank0_refresh_saved
   ,output reg_ddrc_rank0_refresh // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPREFSTAT0
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r223_oprefstat0
   ,output ddrc_reg_rank0_refresh_busy_int
   ,input ddrc_reg_rank0_refresh_busy // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
   ,input  [REG_WIDTH-1:0] r225_swctl
   ,output reg_ddrc_sw_done // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.SWSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r226_swstat
   ,input ddrc_reg_sw_done_ack // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
   ,input  [REG_WIDTH -1:0] r230_dbictl
   ,output r230_dbictl_ack_pclk
   ,output reg_ddrc_dm_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_dbi_en // @core_ddrc_core_clk
   ,output reg_ddrc_rd_dbi_en // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
   ,input  [REG_WIDTH-1:0] r232_odtmap
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_wr_odt // @core_ddrc_core_clk
   ,output [(`MEMC_NUM_RANKS)-1:0] reg_ddrc_rank0_rd_odt // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r233_datactl0
   ,output r233_datactl0_ack_pclk
   ,output reg_ddrc_rd_data_copy_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_data_copy_en // @core_ddrc_core_clk
   ,output reg_ddrc_wr_data_x_en // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
   ,input  [REG_WIDTH-1:0] r234_swctlstatic
   ,output reg_ddrc_sw_static_unlock // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r235_inittmg0
   ,output r235_inittmg0_ack_pclk
   ,output [12:0] reg_ddrc_pre_cke_x1024 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_post_cke_x1024 // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_skip_dram_init // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
   ,input  [REG_WIDTH -1:0] r236_inittmg1
   ,output r236_inittmg1_ack_pclk
   ,output [9:0] reg_ddrc_dram_rstn_x1024 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_NUMBER
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r263_ddrctl_ver_number
   ,input [31:0] ddrc_reg_ver_number // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_TYPE
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r264_ddrctl_ver_type
   ,input [31:0] ddrc_reg_ver_type // @pclk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
   ,input  [REG_WIDTH-1:0] r450_addrmap3_map0
   ,output [5:0] reg_ddrc_addrmap_bank_b0_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b1_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bank_b2_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
   ,input  [REG_WIDTH-1:0] r451_addrmap4_map0
   ,output [5:0] reg_ddrc_addrmap_bg_b0_map0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_addrmap_bg_b1_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
   ,input  [REG_WIDTH-1:0] r452_addrmap5_map0
   ,output [4:0] reg_ddrc_addrmap_col_b7_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b8_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b9_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_col_b10_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
   ,input  [REG_WIDTH-1:0] r453_addrmap6_map0
   ,output [3:0] reg_ddrc_addrmap_col_b3_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b4_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b5_map0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_addrmap_col_b6_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
   ,input  [REG_WIDTH-1:0] r454_addrmap7_map0
   ,output [4:0] reg_ddrc_addrmap_row_b14_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b15_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b16_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b17_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
   ,input  [REG_WIDTH-1:0] r455_addrmap8_map0
   ,output [4:0] reg_ddrc_addrmap_row_b10_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b11_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b12_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b13_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
   ,input  [REG_WIDTH-1:0] r456_addrmap9_map0
   ,output [4:0] reg_ddrc_addrmap_row_b6_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b7_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b8_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b9_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
   ,input  [REG_WIDTH-1:0] r457_addrmap10_map0
   ,output [4:0] reg_ddrc_addrmap_row_b2_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b3_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b4_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b5_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
   ,input  [REG_WIDTH-1:0] r458_addrmap11_map0
   ,output [4:0] reg_ddrc_addrmap_row_b0_map0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_addrmap_row_b1_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
   ,input  [REG_WIDTH -1:0] r459_addrmap12_map0
   ,output r459_addrmap12_map0_ack_pclk
   ,output [2:0] reg_ddrc_nonbinary_device_density_map0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
   ,input  [REG_WIDTH-1:0] r474_pccfg_port0
   ,output reg_arb_go2critical_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_pagematch_limit_port0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
   ,input  [REG_WIDTH-1:0] r475_pcfgr_port0
   ,output [9:0] reg_arb_rd_port_priority_port0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_aging_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_urgent_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_rd_port_pagematch_en_port0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
   ,input  [REG_WIDTH-1:0] r476_pcfgw_port0
   ,output [9:0] reg_arb_wr_port_priority_port0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_aging_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_urgent_en_port0 // @core_ddrc_core_clk
   ,output reg_arb_wr_port_pagematch_en_port0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
   ,input  [REG_WIDTH -1:0] r509_pctrl_port0
   ,output r509_pctrl_port0_ack_pclk
   ,output r509_pctrl_port0_ack_arba0_pclk
   ,output reg_arb_port_en_port0 // @core_ddrc_core_clk
   ,output reg_apb_port_en_port0 // @pclk
   ,output reg_arba0_port_en_port0 // @aclk_0
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
   ,input  [REG_WIDTH-1:0] r510_pcfgqos0_port0
   ,output [(`UMCTL2_XPI_RQOS_MLW)-1:0] reg_arba0_rqos_map_level1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region0_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_RQOS_RW)-1:0] reg_arba0_rqos_map_region1_port0 // @aclk_0
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
   ,input  [REG_WIDTH-1:0] r511_pcfgqos1_port0
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutb_port0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_RQOS_TW)-1:0] reg_arb_rqos_map_timeoutr_port0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
   ,input  [REG_WIDTH-1:0] r512_pcfgwqos0_port0
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_MLW)-1:0] reg_arba0_wqos_map_level2_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region0_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region1_port0 // @aclk_0
   ,output [(`UMCTL2_XPI_WQOS_RW)-1:0] reg_arba0_wqos_map_region2_port0 // @aclk_0
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
   ,input  [REG_WIDTH-1:0] r513_pcfgwqos1_port0
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout1_port0 // @core_ddrc_core_clk
   ,output [(`UMCTL2_XPI_WQOS_TW)-1:0] reg_arb_wqos_map_timeout2_port0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PSTAT
   //------------------------
   ,output  reg  [REG_WIDTH -1:0] r535_pstat_port0
   ,input arb_reg_rd_port_busy_0_port0 // @aclk_0
   ,input arb_reg_wr_port_busy_0_port0 // @aclk_0
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r1882_dramset1tmg0_freq0
   ,output [7:0] reg_ddrc_t_ras_min_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_ras_max_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_faw_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wr2pre_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
   ,input  [REG_WIDTH-1:0] r1883_dramset1tmg1_freq0
   ,output [7:0] reg_ddrc_t_rc_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2pre_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_xp_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
   ,input  [REG_WIDTH-1:0] r1884_dramset1tmg2_freq0
   ,output [7:0] reg_ddrc_wr2rd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2wr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_read_latency_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_write_latency_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
   ,input  [REG_WIDTH-1:0] r1885_dramset1tmg3_freq0
   ,output [7:0] reg_ddrc_wr2mr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2mr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_mr_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
   ,input  [REG_WIDTH-1:0] r1886_dramset1tmg4_freq0
   ,output [6:0] reg_ddrc_t_rp_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_rrd_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_ccd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_rcd_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
   ,input  [REG_WIDTH -1:0] r1887_dramset1tmg5_freq0
   ,output r1887_dramset1tmg5_freq0_ack_pclk
   ,output [5:0] reg_ddrc_t_cke_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_ckesr_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_cksre_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_cksrx_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
   ,input  [REG_WIDTH-1:0] r1888_dramset1tmg6_freq0
   ,output [5:0] reg_ddrc_t_ckcsx_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
   ,input  [REG_WIDTH -1:0] r1889_dramset1tmg7_freq0
   ,output r1889_dramset1tmg7_freq0_ack_pclk
   ,output [3:0] reg_ddrc_t_csh_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
   ,input  [REG_WIDTH-1:0] r1891_dramset1tmg9_freq0
   ,output [7:0] reg_ddrc_wr2rd_s_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_t_rrd_s_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_t_ccd_s_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
   ,input  [REG_WIDTH-1:0] r1894_dramset1tmg12_freq0
   ,output [3:0] reg_ddrc_t_cmdcke_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
   ,input  [REG_WIDTH-1:0] r1895_dramset1tmg13_freq0
   ,output [3:0] reg_ddrc_t_ppd_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_t_ccd_mw_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_odtloff_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
   ,input  [REG_WIDTH-1:0] r1896_dramset1tmg14_freq0
   ,output [11:0] reg_ddrc_t_xsr_freq0 // @core_ddrc_core_clk
   ,output [8:0] reg_ddrc_t_osco_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
   ,input  [REG_WIDTH -1:0] r1905_dramset1tmg23_freq0
   ,output r1905_dramset1tmg23_freq0_ack_pclk
   ,output [11:0] reg_ddrc_t_pdn_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_xsr_dsm_x1024_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
   ,input  [REG_WIDTH-1:0] r1906_dramset1tmg24_freq0
   ,output [7:0] reg_ddrc_max_wr_sync_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_max_rd_sync_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_rd2wr_s_freq0 // @core_ddrc_core_clk
   ,output [1:0] reg_ddrc_bank_org_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
   ,input  [REG_WIDTH-1:0] r1907_dramset1tmg25_freq0
   ,output [7:0] reg_ddrc_rda2pre_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_wra2pre_freq0 // @core_ddrc_core_clk
   ,output [2:0] reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
   ,input  [REG_WIDTH -1:0] r1912_dramset1tmg30_freq0
   ,output r1912_dramset1tmg30_freq0_ack_pclk
   ,output [7:0] reg_ddrc_mrr2rd_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_mrr2wr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_mrr2mrw_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
   ,input  [REG_WIDTH-1:0] r1938_initmr0_freq0
   ,output [15:0] reg_ddrc_emr_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
   ,input  [REG_WIDTH -1:0] r1939_initmr1_freq0
   ,output r1939_initmr1_freq0_ack_pclk
   ,output [15:0] reg_ddrc_emr3_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_emr2_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
   ,input  [REG_WIDTH-1:0] r1940_initmr2_freq0
   ,output [15:0] reg_ddrc_mr5_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr4_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
   ,input  [REG_WIDTH-1:0] r1941_initmr3_freq0
   ,output [15:0] reg_ddrc_mr6_freq0 // @core_ddrc_core_clk
   ,output [15:0] reg_ddrc_mr22_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1942_dfitmg0_freq0
   ,output r1942_dfitmg0_freq0_ack_pclk
   ,output [((`DDRCTL_DDR_DUAL_CHANNEL_EN==1) ? 7 : 6)-1:0] reg_ddrc_dfi_tphy_wrlat_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_tphy_wrdata_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_dfi_t_rddata_en_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_ctrl_delay_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
   ,input  [REG_WIDTH -1:0] r1943_dfitmg1_freq0
   ,output r1943_dfitmg1_freq0_ack_pclk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_enable_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_dram_clk_disable_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_t_wrdata_delay_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
   ,input  [REG_WIDTH-1:0] r1944_dfitmg2_freq0
   ,output [((`DDRCTL_DDR_DUAL_CHANNEL_EN==1) ? 7 : 6)-1:0] reg_ddrc_dfi_tphy_wrcslat_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_dfi_tphy_rdcslat_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_dfi_twck_delay_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
   ,input  [REG_WIDTH-1:0] r1946_dfitmg4_freq0
   ,output [7:0] reg_ddrc_dfi_twck_dis_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_en_wr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_en_rd_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
   ,input  [REG_WIDTH-1:0] r1947_dfitmg5_freq0
   ,output [7:0] reg_ddrc_dfi_twck_toggle_post_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_toggle_cs_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_toggle_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_twck_fast_toggle_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1949_dfilptmg0_freq0
   ,output r1949_dfilptmg0_freq0_ack_pclk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_pd_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_sr_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_dsm_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
   ,input  [REG_WIDTH -1:0] r1950_dfilptmg1_freq0
   ,output r1950_dfilptmg1_freq0_ack_pclk
   ,output [4:0] reg_ddrc_dfi_lp_wakeup_data_freq0 // @core_ddrc_core_clk
   ,output [4:0] reg_ddrc_dfi_tlp_resp_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1951_dfiupdtmg0_freq0
   ,output r1951_dfiupdtmg0_freq0_ack_pclk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_min_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_dfi_t_ctrlup_max_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
   ,input  [REG_WIDTH-1:0] r1952_dfiupdtmg1_freq0
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r1953_dfimsgtmg0_freq0
   ,output [7:0] reg_ddrc_dfi_t_ctrlmsg_resp_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1955_rfshset1tmg0_freq0
   ,output r1955_rfshset1tmg0_freq0_ack_pclk
   ,output [11:0] reg_ddrc_t_refi_x1_x32_freq0 // @core_ddrc_core_clk
   ,output [5:0] reg_ddrc_refresh_to_x1_x32_freq0 // @core_ddrc_core_clk
   ,output [3:0] reg_ddrc_refresh_margin_freq0 // @core_ddrc_core_clk
   ,output reg_ddrc_t_refi_x1_sel_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
   ,input  [REG_WIDTH -1:0] r1956_rfshset1tmg1_freq0
   ,output r1956_rfshset1tmg1_freq0_ack_pclk
   ,output [11:0] reg_ddrc_t_rfc_min_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_t_rfc_min_ab_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
   ,input  [REG_WIDTH -1:0] r1957_rfshset1tmg2_freq0
   ,output r1957_rfshset1tmg2_freq0_ack_pclk
   ,output [7:0] reg_ddrc_t_pbr2pbr_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_t_pbr2act_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
   ,input  [REG_WIDTH -1:0] r1958_rfshset1tmg3_freq0
   ,output r1958_rfshset1tmg3_freq0_ack_pclk
   ,output [5:0] reg_ddrc_refresh_to_ab_x32_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1975_zqset1tmg0_freq0
   ,output r1975_zqset1tmg0_freq0_ack_pclk
   ,output [13:0] reg_ddrc_t_zq_long_nop_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_zq_short_nop_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
   ,input  [REG_WIDTH-1:0] r1976_zqset1tmg1_freq0
   ,output [19:0] reg_ddrc_t_zq_short_interval_x1024_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_t_zq_reset_nop_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1985_dqsoscctl0_freq0
   ,output r1985_dqsoscctl0_freq0_ack_pclk
   ,output reg_ddrc_dqsosc_enable_freq0 // @core_ddrc_core_clk
   ,output reg_ddrc_dqsosc_interval_unit_freq0 // @core_ddrc_core_clk
   ,output [11:0] reg_ddrc_dqsosc_interval_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
   ,input  [REG_WIDTH-1:0] r1986_derateint_freq0
   ,output [31:0] reg_ddrc_mr4_read_interval_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
   ,input  [REG_WIDTH -1:0] r1987_derateval0_freq0
   ,output r1987_derateval0_freq0_ack_pclk
   ,output [5:0] reg_ddrc_derated_t_rrd_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_derated_t_rp_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_derated_t_ras_min_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_derated_t_rcd_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
   ,input  [REG_WIDTH -1:0] r1988_derateval1_freq0
   ,output r1988_derateval1_freq0_ack_pclk
   ,output [7:0] reg_ddrc_derated_t_rc_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r1989_hwlptmg0_freq0
   ,output [11:0] reg_ddrc_hw_lp_idle_x32_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
   ,input  [REG_WIDTH-1:0] r1990_schedtmg0_freq0
   ,output [7:0] reg_ddrc_pageclose_timer_freq0 // @core_ddrc_core_clk
   ,output [6:0] reg_ddrc_rdwr_idle_gap_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
   ,input  [REG_WIDTH-1:0] r1991_perfhpr1_freq0
   ,output [15:0] reg_ddrc_hpr_max_starve_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_hpr_xact_run_length_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
   ,input  [REG_WIDTH-1:0] r1992_perflpr1_freq0
   ,output [15:0] reg_ddrc_lpr_max_starve_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_lpr_xact_run_length_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
   ,input  [REG_WIDTH-1:0] r1993_perfwr1_freq0
   ,output [15:0] reg_ddrc_w_max_starve_freq0 // @core_ddrc_core_clk
   ,output [7:0] reg_ddrc_w_xact_run_length_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
   ,input  [REG_WIDTH -1:0] r1994_tmgcfg_freq0
   ,output r1994_tmgcfg_freq0_ack_pclk
   ,output reg_ddrc_frequency_ratio_freq0 // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
   ,input  [REG_WIDTH-1:0] r1997_pwrtmg_freq0
   ,output [6:0] reg_ddrc_powerdown_to_x32_freq0 // @core_ddrc_core_clk
   ,output [9:0] reg_ddrc_selfref_to_x32_freq0 // @core_ddrc_core_clk

    ,output              pclk_derate_temp_limit_intr
    ,output              derate_sync_ack_c2p



   );
   
   localparam TMR_EN = 0; //`UMCTL2_REGPAR_EN;
   localparam WAIT_ACK_TIMEOUT = 96;
 



   reg  [REG_WIDTH -1:0] s_data_r0_mstr0;
   wire [REG_WIDTH -1:0] d_data_r0_mstr0;
   reg  [REG_WIDTH -1:0] s_data_arba0_r0_mstr0;
   wire [REG_WIDTH -1:0] d_data_arba0_r0_mstr0;
   wire reg_ddrc_lpddr4_pclk;
   wire reg_arba0_lpddr4_pclk;
   wire reg_ddrc_lpddr5_pclk;
   wire reg_arba0_lpddr5_pclk;
   wire reg_ddrc_en_2t_timing_mode_pclk;
   wire reg_arba0_en_2t_timing_mode_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH-1:0] reg_ddrc_data_bus_width_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH-1:0] reg_arba0_data_bus_width_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR-1:0] reg_ddrc_burst_rdwr_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR-1:0] reg_arba0_burst_rdwr_pclk;
   reg  [REG_WIDTH -1:0] s_data_r4_mstr4;
   wire [REG_WIDTH -1:0] d_data_r4_mstr4;
   wire reg_ddrc_wck_on_pclk;
   wire reg_ddrc_wck_suspend_en_pclk;
   wire reg_ddrc_ws_off_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r8_mrctrl0;
   wire [REG_WIDTH -1:0] d_data_r8_mrctrl0;
   wire reg_ddrc_mr_type_pclk;
   wire reg_ddrc_sw_init_int_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK-1:0] reg_ddrc_mr_rank_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR-1:0] reg_ddrc_mr_addr_pclk;
   wire reg_ddrc_mrr_done_clr_pclk;
   wire reg_ddrc_mr_wr_pclk;
   reg  [REG_WIDTH -1:0] s_data_r9_mrctrl1;
   wire [REG_WIDTH -1:0] d_data_r9_mrctrl1;
   wire [`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA-1:0] reg_ddrc_mr_data_pclk;
   wire ddrc_reg_mr_wr_busy_pclk;
   wire ddrc_reg_mrr_done_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MRRDATA0_MRR_DATA_LWR -1:0] ddrc_reg_mrr_data_lwr_pclk;
   wire [`REGB_DDRC_CH0_SIZE_MRRDATA1_MRR_DATA_UPR -1:0] ddrc_reg_mrr_data_upr_pclk;
   reg  [REG_WIDTH -1:0] s_data_r14_deratectl0;
   wire [REG_WIDTH -1:0] d_data_r14_deratectl0;
   wire reg_ddrc_derate_enable_pclk;
   wire reg_ddrc_lpddr4_refresh_mode_pclk;
   wire reg_ddrc_derate_mr4_pause_fc_pclk;
   wire reg_ddrc_dis_trefi_x6x8_pclk;
   wire reg_ddrc_dis_trefi_x0125_pclk;
   reg  [REG_WIDTH -1:0] s_data_r15_deratectl1;
   wire [REG_WIDTH -1:0] d_data_r15_deratectl1;
   wire [`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0-1:0] reg_ddrc_active_derate_byte_rank0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r23_deratedbgctl;
   wire [REG_WIDTH -1:0] d_data_r23_deratedbgctl;
   wire [`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL-1:0] reg_ddrc_dbg_mr4_grp_sel_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL-1:0] reg_ddrc_dbg_mr4_rank_sel_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE0 -1:0] ddrc_reg_dbg_mr4_byte0_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE1 -1:0] ddrc_reg_dbg_mr4_byte1_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE2 -1:0] ddrc_reg_dbg_mr4_byte2_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE3 -1:0] ddrc_reg_dbg_mr4_byte3_pclk;
   reg  [REG_WIDTH -1:0] s_data_r25_pwrctl;
   wire [REG_WIDTH -1:0] d_data_r25_pwrctl;
   wire [`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN-1:0] reg_ddrc_selfref_en_pclk;
   wire [`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN-1:0] reg_ddrc_powerdown_en_pclk;
   wire reg_ddrc_en_dfi_dram_clk_disable_pclk;
   wire reg_ddrc_selfref_sw_pclk;
   wire reg_ddrc_stay_in_selfref_pclk;
   wire reg_ddrc_dis_cam_drain_selfref_pclk;
   wire reg_ddrc_lpddr4_sr_allowed_pclk;
   wire reg_ddrc_dsm_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r28_clkgatectl;
   wire [REG_WIDTH -1:0] d_data_r28_clkgatectl;
   wire [`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON-1:0] reg_ddrc_bsm_clk_on_pclk;
   reg  [REG_WIDTH -1:0] s_data_r29_rfshmod0;
   wire [REG_WIDTH -1:0] d_data_r29_rfshmod0;
   wire [`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST-1:0] reg_ddrc_refresh_burst_pclk;
   wire [`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN-1:0] reg_ddrc_auto_refab_en_pclk;
   wire reg_ddrc_per_bank_refresh_pclk;
   reg  [REG_WIDTH -1:0] s_data_r31_rfshctl0;
   wire [REG_WIDTH -1:0] d_data_r31_rfshctl0;
   wire reg_ddrc_dis_auto_refresh_pclk;
   wire reg_ddrc_refresh_update_level_pclk;
   reg  [REG_WIDTH -1:0] s_data_r34_zqctl0;
   wire [REG_WIDTH -1:0] d_data_r34_zqctl0;
   wire reg_ddrc_zq_resistor_shared_pclk;
   wire reg_ddrc_dis_auto_zq_pclk;
   reg  [REG_WIDTH -1:0] s_data_r35_zqctl1;
   wire [REG_WIDTH -1:0] d_data_r35_zqctl1;
   wire reg_ddrc_zq_reset_pclk;
   wire ddrc_reg_zq_reset_busy_pclk;
   reg  [REG_WIDTH -1:0] s_data_r56_dfilpcfg0;
   wire [REG_WIDTH -1:0] d_data_r56_dfilpcfg0;
   wire reg_ddrc_dfi_lp_en_pd_pclk;
   wire reg_ddrc_dfi_lp_en_sr_pclk;
   wire reg_ddrc_dfi_lp_en_dsm_pclk;
   wire reg_ddrc_dfi_lp_en_data_pclk;
   wire reg_ddrc_dfi_lp_data_req_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r57_dfiupd0;
   wire [REG_WIDTH -1:0] d_data_r57_dfiupd0;
   wire reg_ddrc_dfi_phyupd_en_pclk;
   wire reg_ddrc_ctrlupd_pre_srx_pclk;
   wire reg_ddrc_dis_auto_ctrlupd_srx_pclk;
   wire reg_ddrc_dis_auto_ctrlupd_pclk;
   reg  [REG_WIDTH -1:0] s_data_r59_dfimisc;
   wire [REG_WIDTH -1:0] d_data_r59_dfimisc;
   wire reg_ddrc_dfi_init_complete_en_pclk;
   wire reg_ddrc_phy_dbi_mode_pclk;
   wire reg_ddrc_dfi_data_cs_polarity_pclk;
   wire reg_ddrc_dfi_init_start_pclk;
   wire reg_ddrc_lp_optimized_write_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY-1:0] reg_ddrc_dfi_frequency_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP-1:0] reg_ddrc_dfi_freq_fsp_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE-1:0] reg_ddrc_dfi_channel_mode_pclk;
   wire ddrc_reg_dfi_init_complete_pclk;
   wire ddrc_reg_dfi_lp_ctrl_ack_stat_pclk;
   wire ddrc_reg_dfi_lp_data_ack_stat_pclk;
   reg  [REG_WIDTH -1:0] s_data_r61_dfiphymstr;
   wire [REG_WIDTH -1:0] d_data_r61_dfiphymstr;
   wire reg_ddrc_dfi_phymstr_en_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32-1:0] reg_ddrc_dfi_phymstr_blk_ref_x32_pclk;
   reg  [REG_WIDTH -1:0] s_data_r62_dfi0msgctl0;
   wire [REG_WIDTH -1:0] d_data_r62_dfi0msgctl0;
   wire [`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA-1:0] reg_ddrc_dfi0_ctrlmsg_data_pclk;
   wire [`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD-1:0] reg_ddrc_dfi0_ctrlmsg_cmd_pclk;
   wire reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk;
   wire reg_ddrc_dfi0_ctrlmsg_req_pclk;
   wire ddrc_reg_dfi0_ctrlmsg_req_busy_pclk;
   wire ddrc_reg_dfi0_ctrlmsg_resp_tout_pclk;
   reg  [REG_WIDTH -1:0] s_data_r64_poisoncfg;
   wire [REG_WIDTH -1:0] d_data_r64_poisoncfg;
   wire reg_ddrc_wr_poison_slverr_en_pclk;
   wire reg_ddrc_wr_poison_intr_en_pclk;
   wire reg_ddrc_wr_poison_intr_clr_pclk;
   wire reg_ddrc_rd_poison_slverr_en_pclk;
   wire reg_ddrc_rd_poison_intr_en_pclk;
   wire reg_ddrc_rd_poison_intr_clr_pclk;
   wire ddrc_reg_wr_poison_intr_0_pclk;
   wire ddrc_reg_rd_poison_intr_0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r216_opctrl1;
   wire [REG_WIDTH -1:0] d_data_r216_opctrl1;
   wire reg_ddrc_dis_dq_pclk;
   wire reg_ddrc_dis_hif_pclk;
   wire [`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_HPR_Q_DEPTH -1:0] ddrc_reg_dbg_hpr_q_depth_pclk;
   wire [`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_LPR_Q_DEPTH -1:0] ddrc_reg_dbg_lpr_q_depth_pclk;
   wire [`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_W_Q_DEPTH -1:0] ddrc_reg_dbg_w_q_depth_pclk;
   wire ddrc_reg_dbg_stall_pclk;
   wire ddrc_reg_dbg_rd_q_empty_pclk;
   wire ddrc_reg_dbg_wr_q_empty_pclk;
   wire ddrc_reg_rd_data_pipeline_empty_pclk;
   wire ddrc_reg_wr_data_pipeline_empty_pclk;
   reg  [REG_WIDTH -1:0] s_data_r218_opctrlcmd;
   wire [REG_WIDTH -1:0] d_data_r218_opctrlcmd;
   wire reg_ddrc_zq_calib_short_pclk;
   wire reg_ddrc_ctrlupd_pclk;
   wire ddrc_reg_zq_calib_short_busy_pclk;
   wire ddrc_reg_ctrlupd_busy_pclk;
   reg  [REG_WIDTH -1:0] s_data_r221_oprefctrl0;
   wire [REG_WIDTH -1:0] d_data_r221_oprefctrl0;
   wire reg_ddrc_rank0_refresh_pclk;
   wire ddrc_reg_rank0_refresh_busy_pclk;
   reg  [REG_WIDTH -1:0] s_data_r230_dbictl;
   wire [REG_WIDTH -1:0] d_data_r230_dbictl;
   wire reg_ddrc_dm_en_pclk;
   wire reg_ddrc_wr_dbi_en_pclk;
   wire reg_ddrc_rd_dbi_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r233_datactl0;
   wire [REG_WIDTH -1:0] d_data_r233_datactl0;
   wire reg_ddrc_rd_data_copy_en_pclk;
   wire reg_ddrc_wr_data_copy_en_pclk;
   wire reg_ddrc_wr_data_x_en_pclk;
   reg  [REG_WIDTH -1:0] s_data_r235_inittmg0;
   wire [REG_WIDTH -1:0] d_data_r235_inittmg0;
   wire [`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024-1:0] reg_ddrc_pre_cke_x1024_pclk;
   wire [`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024-1:0] reg_ddrc_post_cke_x1024_pclk;
   wire [`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT-1:0] reg_ddrc_skip_dram_init_pclk;
   reg  [REG_WIDTH -1:0] s_data_r236_inittmg1;
   wire [REG_WIDTH -1:0] d_data_r236_inittmg1;
   wire [`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024-1:0] reg_ddrc_dram_rstn_x1024_pclk;
   reg  [REG_WIDTH -1:0] s_data_r459_addrmap12_map0;
   wire [REG_WIDTH -1:0] d_data_r459_addrmap12_map0;
   wire [`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY-1:0] reg_ddrc_nonbinary_device_density_map0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r509_pctrl_port0;
   wire [REG_WIDTH -1:0] d_data_r509_pctrl_port0;
   reg  [REG_WIDTH -1:0] s_data_arba0_r509_pctrl_port0;
   wire [REG_WIDTH -1:0] d_data_arba0_r509_pctrl_port0;
   wire reg_arb_port_en_port0_pclk;
   wire reg_arba0_port_en_port0_pclk;
   wire arb_reg_rd_port_busy_0_port0_pclk;
   wire arb_reg_wr_port_busy_0_port0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1887_dramset1tmg5_freq0;
   wire [REG_WIDTH -1:0] d_data_r1887_dramset1tmg5_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE-1:0] reg_ddrc_t_cke_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR-1:0] reg_ddrc_t_ckesr_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE-1:0] reg_ddrc_t_cksre_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX-1:0] reg_ddrc_t_cksrx_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1889_dramset1tmg7_freq0;
   wire [REG_WIDTH -1:0] d_data_r1889_dramset1tmg7_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH-1:0] reg_ddrc_t_csh_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1905_dramset1tmg23_freq0;
   wire [REG_WIDTH -1:0] d_data_r1905_dramset1tmg23_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN-1:0] reg_ddrc_t_pdn_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024-1:0] reg_ddrc_t_xsr_dsm_x1024_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1912_dramset1tmg30_freq0;
   wire [REG_WIDTH -1:0] d_data_r1912_dramset1tmg30_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD-1:0] reg_ddrc_mrr2rd_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR-1:0] reg_ddrc_mrr2wr_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW-1:0] reg_ddrc_mrr2mrw_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1939_initmr1_freq0;
   wire [REG_WIDTH -1:0] d_data_r1939_initmr1_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3-1:0] reg_ddrc_emr3_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2-1:0] reg_ddrc_emr2_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1942_dfitmg0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1942_dfitmg0_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT-1:0] reg_ddrc_dfi_tphy_wrlat_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA-1:0] reg_ddrc_dfi_tphy_wrdata_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN-1:0] reg_ddrc_dfi_t_rddata_en_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY-1:0] reg_ddrc_dfi_t_ctrl_delay_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1943_dfitmg1_freq0;
   wire [REG_WIDTH -1:0] d_data_r1943_dfitmg1_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE-1:0] reg_ddrc_dfi_t_dram_clk_enable_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE-1:0] reg_ddrc_dfi_t_dram_clk_disable_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY-1:0] reg_ddrc_dfi_t_wrdata_delay_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1949_dfilptmg0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1949_dfilptmg0_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD-1:0] reg_ddrc_dfi_lp_wakeup_pd_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR-1:0] reg_ddrc_dfi_lp_wakeup_sr_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM-1:0] reg_ddrc_dfi_lp_wakeup_dsm_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1950_dfilptmg1_freq0;
   wire [REG_WIDTH -1:0] d_data_r1950_dfilptmg1_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA-1:0] reg_ddrc_dfi_lp_wakeup_data_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP-1:0] reg_ddrc_dfi_tlp_resp_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1951_dfiupdtmg0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1951_dfiupdtmg0_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN-1:0] reg_ddrc_dfi_t_ctrlup_min_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX-1:0] reg_ddrc_dfi_t_ctrlup_max_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1955_rfshset1tmg0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1955_rfshset1tmg0_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32-1:0] reg_ddrc_t_refi_x1_x32_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32-1:0] reg_ddrc_refresh_to_x1_x32_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN-1:0] reg_ddrc_refresh_margin_freq0_pclk;
   wire reg_ddrc_t_refi_x1_sel_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1956_rfshset1tmg1_freq0;
   wire [REG_WIDTH -1:0] d_data_r1956_rfshset1tmg1_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN-1:0] reg_ddrc_t_rfc_min_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB-1:0] reg_ddrc_t_rfc_min_ab_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1957_rfshset1tmg2_freq0;
   wire [REG_WIDTH -1:0] d_data_r1957_rfshset1tmg2_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR-1:0] reg_ddrc_t_pbr2pbr_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT-1:0] reg_ddrc_t_pbr2act_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1958_rfshset1tmg3_freq0;
   wire [REG_WIDTH -1:0] d_data_r1958_rfshset1tmg3_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32-1:0] reg_ddrc_refresh_to_ab_x32_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1975_zqset1tmg0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1975_zqset1tmg0_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP-1:0] reg_ddrc_t_zq_long_nop_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP-1:0] reg_ddrc_t_zq_short_nop_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1985_dqsoscctl0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1985_dqsoscctl0_freq0;
   wire reg_ddrc_dqsosc_enable_freq0_pclk;
   wire reg_ddrc_dqsosc_interval_unit_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL-1:0] reg_ddrc_dqsosc_interval_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1987_derateval0_freq0;
   wire [REG_WIDTH -1:0] d_data_r1987_derateval0_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD-1:0] reg_ddrc_derated_t_rrd_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP-1:0] reg_ddrc_derated_t_rp_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN-1:0] reg_ddrc_derated_t_ras_min_freq0_pclk;
   wire [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD-1:0] reg_ddrc_derated_t_rcd_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1988_derateval1_freq0;
   wire [REG_WIDTH -1:0] d_data_r1988_derateval1_freq0;
   wire [`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC-1:0] reg_ddrc_derated_t_rc_freq0_pclk;
   reg  [REG_WIDTH -1:0] s_data_r1994_tmgcfg_freq0;
   wire [REG_WIDTH -1:0] d_data_r1994_tmgcfg_freq0;
   wire reg_ddrc_frequency_ratio_freq0_pclk;

   reg [`REGB_DDRC_CH0_SIZE_STAT_SELFREF_TYPE -1:0] ddrc_reg_selfref_type_cclk;
   reg [`REGB_DDRC_CH0_SIZE_STAT_SELFREF_STATE -1:0] ddrc_reg_selfref_state_cclk;
   reg ddrc_reg_selfref_cam_not_empty_cclk;
   reg ddrc_reg_mr_wr_busy_cclk;
   reg ddrc_reg_mrr_done_cclk;
   reg [`REGB_DDRC_CH0_SIZE_MRRDATA0_MRR_DATA_LWR -1:0] ddrc_reg_mrr_data_lwr_cclk;
   reg [`REGB_DDRC_CH0_SIZE_MRRDATA1_MRR_DATA_UPR -1:0] ddrc_reg_mrr_data_upr_cclk;
   reg [`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_STATE -1:0] ddrc_reg_dqsosc_state_cclk;
   reg [`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT -1:0] ddrc_reg_dqsosc_per_rank_stat_cclk;
   reg ddrc_reg_dfi_init_complete_cclk;
   reg ddrc_reg_dfi_lp_ctrl_ack_stat_cclk;
   reg ddrc_reg_dfi_lp_data_ack_stat_cclk;
   reg ddrc_reg_dfi0_ctrlmsg_req_busy_cclk;
   reg ddrc_reg_dfi0_ctrlmsg_resp_tout_cclk;
   reg ddrc_reg_dbg_stall_cclk;
   reg ddrc_reg_dbg_rd_q_empty_cclk;
   reg ddrc_reg_dbg_wr_q_empty_cclk;
   reg ddrc_reg_rd_data_pipeline_empty_cclk;
   reg ddrc_reg_wr_data_pipeline_empty_cclk;

   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
   assign reg_ddrc_lpddr4_pclk = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4];
   assign reg_apb_lpddr4 = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4];
   assign reg_arba0_lpddr4_pclk = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4];
   assign reg_ddrc_lpddr5_pclk = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5];
   assign reg_apb_lpddr5 = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5];
   assign reg_arba0_lpddr5_pclk = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5];
   assign reg_ddrc_en_2t_timing_mode_pclk = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE];
   assign reg_apb_en_2t_timing_mode = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE];
   assign reg_arba0_en_2t_timing_mode_pclk = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE];
   assign reg_ddrc_data_bus_width_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH) -1:0] = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH];
   assign reg_apb_data_bus_width[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH) -1:0] = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH];
   assign reg_arba0_data_bus_width_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH) -1:0] = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH];
   assign reg_ddrc_burst_rdwr_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR) -1:0] = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR];
   assign reg_apb_burst_rdwr[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR) -1:0] = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR];
   assign reg_arba0_burst_rdwr_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR) -1:0] = r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR];
   always_comb begin : s_data_r0_mstr0_combo_PROC
      s_data_r0_mstr0 = {REG_WIDTH {1'b0}};
      s_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4] = reg_ddrc_lpddr4_pclk;
      s_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5] = reg_ddrc_lpddr5_pclk;
      s_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE] = reg_ddrc_en_2t_timing_mode_pclk;
      s_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH] = reg_ddrc_data_bus_width_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH)-1:0];
      s_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR] = reg_ddrc_burst_rdwr_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR)-1:0];
   end
      assign reg_ddrc_lpddr4 = d_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4];
      assign reg_ddrc_lpddr5 = d_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5];
      assign reg_ddrc_en_2t_timing_mode = d_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE];
      assign reg_ddrc_data_bus_width[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH)-1:0] = d_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH];
      assign reg_ddrc_burst_rdwr[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR)-1:0] = d_data_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR];
   always_comb begin : s_data_arba0_r0_mstr0_combo_PROC
      s_data_arba0_r0_mstr0 = {REG_WIDTH {1'b0}};
      s_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4] = reg_arba0_lpddr4_pclk;
      s_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5] = reg_arba0_lpddr5_pclk;
      s_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE] = reg_arba0_en_2t_timing_mode_pclk;
      s_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH] = reg_arba0_data_bus_width_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH)-1:0];
      s_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR] = reg_arba0_burst_rdwr_pclk[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR)-1:0];
   end
      assign reg_arba0_lpddr4 = d_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4];
      assign reg_arba0_lpddr5 = d_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5];
      assign reg_arba0_en_2t_timing_mode = d_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE];
      assign reg_arba0_data_bus_width[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH)-1:0] = d_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH];
      assign reg_arba0_burst_rdwr[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR)-1:0] = d_data_arba0_r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR];
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
   assign reg_ddrc_wck_on_pclk = r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_ON+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_ON];
   assign reg_ddrc_wck_suspend_en_pclk = r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_SUSPEND_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_SUSPEND_EN];
   assign reg_ddrc_ws_off_en_pclk = r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WS_OFF_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WS_OFF_EN];
   always_comb begin : s_data_r4_mstr4_combo_PROC
      s_data_r4_mstr4 = {REG_WIDTH {1'b0}};
      s_data_r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_ON+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_ON] = reg_ddrc_wck_on_pclk;
      s_data_r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_SUSPEND_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_SUSPEND_EN] = reg_ddrc_wck_suspend_en_pclk;
      s_data_r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WS_OFF_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WS_OFF_EN] = reg_ddrc_ws_off_en_pclk;
   end
      assign reg_ddrc_wck_on = d_data_r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_ON+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_ON];
      assign reg_ddrc_wck_suspend_en = d_data_r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_SUSPEND_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_SUSPEND_EN];
      assign reg_ddrc_ws_off_en = d_data_r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WS_OFF_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WS_OFF_EN];
   //------------------------
   // Register REGB_DDRC_CH0.STAT
   //------------------------
   reg  [REG_WIDTH-1:0] r5_stat_cclk;
   always_comb begin : r5_stat_cclk_combo_PROC
      r5_stat_cclk = {REG_WIDTH{1'b0}};
      r5_stat_cclk[`REGB_DDRC_CH0_OFFSET_STAT_OPERATING_MODE+:`REGB_DDRC_CH0_SIZE_STAT_OPERATING_MODE] = ddrc_reg_operating_mode[(`REGB_DDRC_CH0_SIZE_STAT_OPERATING_MODE) -1:0];
      r5_stat_cclk[`REGB_DDRC_CH0_OFFSET_STAT_SELFREF_TYPE+:`REGB_DDRC_CH0_SIZE_STAT_SELFREF_TYPE] = ddrc_reg_selfref_type[(`REGB_DDRC_CH0_SIZE_STAT_SELFREF_TYPE) -1:0];
      r5_stat_cclk[`REGB_DDRC_CH0_OFFSET_STAT_SELFREF_STATE+:`REGB_DDRC_CH0_SIZE_STAT_SELFREF_STATE] = ddrc_reg_selfref_state[(`REGB_DDRC_CH0_SIZE_STAT_SELFREF_STATE) -1:0];
      r5_stat_cclk[`REGB_DDRC_CH0_OFFSET_STAT_SELFREF_CAM_NOT_EMPTY+:`REGB_DDRC_CH0_SIZE_STAT_SELFREF_CAM_NOT_EMPTY] = ddrc_reg_selfref_cam_not_empty;
   end
   // For interrupt
   wire [(`REGB_DDRC_CH0_SIZE_STAT_OPERATING_MODE) -1:0] ddrc_reg_operating_mode_pclk;
   assign ddrc_reg_operating_mode_pclk = r5_stat[`REGB_DDRC_CH0_OFFSET_STAT_OPERATING_MODE +: `REGB_DDRC_CH0_SIZE_STAT_OPERATING_MODE];
   wire [(`REGB_DDRC_CH0_SIZE_STAT_SELFREF_TYPE) -1:0] ddrc_reg_selfref_type_pclk;
   assign ddrc_reg_selfref_type_pclk = r5_stat[`REGB_DDRC_CH0_OFFSET_STAT_SELFREF_TYPE +: `REGB_DDRC_CH0_SIZE_STAT_SELFREF_TYPE];
   wire [(`REGB_DDRC_CH0_SIZE_STAT_SELFREF_STATE) -1:0] ddrc_reg_selfref_state_pclk;
   assign ddrc_reg_selfref_state_pclk = r5_stat[`REGB_DDRC_CH0_OFFSET_STAT_SELFREF_STATE +: `REGB_DDRC_CH0_SIZE_STAT_SELFREF_STATE];
   wire ddrc_reg_selfref_cam_not_empty_pclk;
   assign ddrc_reg_selfref_cam_not_empty_pclk = r5_stat[`REGB_DDRC_CH0_OFFSET_STAT_SELFREF_CAM_NOT_EMPTY +: `REGB_DDRC_CH0_SIZE_STAT_SELFREF_CAM_NOT_EMPTY];

   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
   assign reg_ddrc_mr_type_pclk = r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_TYPE+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_TYPE];
   assign reg_ddrc_sw_init_int_pclk = r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_SW_INIT_INT+:`REGB_DDRC_CH0_SIZE_MRCTRL0_SW_INIT_INT];
   assign reg_ddrc_mr_rank_pclk[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK) -1:0] = r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_RANK+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK];
   assign reg_ddrc_mr_addr_pclk[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR) -1:0] = r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_ADDR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR];
   assign reg_ddrc_mrr_done_clr_pclk = r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MRR_DONE_CLR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MRR_DONE_CLR];
   assign reg_ddrc_mr_wr_pclk = r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_WR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_WR];
   assign ddrc_reg_mr_wr_busy_int = ddrc_reg_mr_wr_busy_pclk;
   always_comb begin : s_data_r8_mrctrl0_combo_PROC
      s_data_r8_mrctrl0 = {REG_WIDTH {1'b0}};
      s_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_TYPE+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_TYPE] = reg_ddrc_mr_type_pclk;
      s_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_SW_INIT_INT+:`REGB_DDRC_CH0_SIZE_MRCTRL0_SW_INIT_INT] = reg_ddrc_sw_init_int_pclk;
      s_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_RANK+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK] = reg_ddrc_mr_rank_pclk[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK)-1:0];
      s_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_ADDR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR] = reg_ddrc_mr_addr_pclk[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR)-1:0];
   end
      assign reg_ddrc_mr_type = d_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_TYPE+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_TYPE];
      assign reg_ddrc_sw_init_int = d_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_SW_INIT_INT+:`REGB_DDRC_CH0_SIZE_MRCTRL0_SW_INIT_INT];
      assign reg_ddrc_mr_rank[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK)-1:0] = d_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_RANK+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK];
      assign reg_ddrc_mr_addr[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR)-1:0] = d_data_r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_ADDR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR];
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
   assign reg_ddrc_mr_data_pclk[(`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA) -1:0] = r9_mrctrl1[`REGB_DDRC_CH0_OFFSET_MRCTRL1_MR_DATA+:`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA];
   always_comb begin : s_data_r9_mrctrl1_combo_PROC
      s_data_r9_mrctrl1 = {REG_WIDTH {1'b0}};
      s_data_r9_mrctrl1[`REGB_DDRC_CH0_OFFSET_MRCTRL1_MR_DATA+:`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA] = reg_ddrc_mr_data_pclk[(`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA)-1:0];
   end
      assign reg_ddrc_mr_data[(`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA)-1:0] = d_data_r9_mrctrl1[`REGB_DDRC_CH0_OFFSET_MRCTRL1_MR_DATA+:`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA];
   //------------------------
   // Register REGB_DDRC_CH0.MRSTAT
   //------------------------
   wire ddrc_reg_mr_wr_busy_pulse_pclk;

   reg  ddrc_reg_mr_wr_busy_ahead;
   reg  reg_ddrc_mr_wr_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_mr_wr_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_mr_wr_busy_ahead <= 1'b0; 
         reg_ddrc_mr_wr_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_mr_wr_pclk_s0 <= reg_ddrc_mr_wr_pclk; 
         if (ddrc_reg_mr_wr_busy_pulse_pclk || ddrc_reg_mr_wr_busy_pclk) begin 
            ddrc_reg_mr_wr_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_mr_wr_pclk & (!reg_ddrc_mr_wr_pclk_s0)) begin 
            ddrc_reg_mr_wr_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

  // Check eventually get ddrc_reg_mr_wr_busy_pulse_pclk or ddrc_reg_mr_wr_busy_pclk when reg_ddrc_mr_wr_pclk is detected
  property p_any_pclk_ddrc_reg_mr_wr_busy_after_mr_wr;
    @(posedge apb_clk) disable iff(!apb_rst)
         $rose(reg_ddrc_mr_wr_pclk) |-> (##[0:$] (ddrc_reg_mr_wr_busy_pulse_pclk || ddrc_reg_mr_wr_busy_pclk));
  endproperty

  a_any_pclk_ddrc_reg_mr_wr_busy_after_mr_wr : assert property (p_any_pclk_ddrc_reg_mr_wr_busy_after_mr_wr) else
    $display("-> %0t ERROR: APB ddrc_reg_mr_wr_busy_pulse_pclk or ddrc_reg_mr_wr_busy_pclk never recieved for reg_ddrc_mr_wr_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   always_comb begin : r11_mrstat_combo_PROC
      r11_mrstat = {REG_WIDTH{1'b0}};
      r11_mrstat[`REGB_DDRC_CH0_OFFSET_MRSTAT_MR_WR_BUSY+:`REGB_DDRC_CH0_SIZE_MRSTAT_MR_WR_BUSY] = ddrc_reg_mr_wr_busy_pclk          | ddrc_reg_mr_wr_busy_ahead
          | ff_regb_ddrc_ch0_mr_wr_saved
;
      r11_mrstat[`REGB_DDRC_CH0_OFFSET_MRSTAT_MRR_DONE+:`REGB_DDRC_CH0_SIZE_MRSTAT_MRR_DONE] = ddrc_reg_mrr_done_pclk;
   end
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA0
   //------------------------
   always_comb begin : r12_mrrdata0_combo_PROC
      r12_mrrdata0 = {REG_WIDTH{1'b0}};
      r12_mrrdata0[`REGB_DDRC_CH0_OFFSET_MRRDATA0_MRR_DATA_LWR+:`REGB_DDRC_CH0_SIZE_MRRDATA0_MRR_DATA_LWR] = ddrc_reg_mrr_data_lwr_pclk[(`REGB_DDRC_CH0_SIZE_MRRDATA0_MRR_DATA_LWR) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA1
   //------------------------
   always_comb begin : r13_mrrdata1_combo_PROC
      r13_mrrdata1 = {REG_WIDTH{1'b0}};
      r13_mrrdata1[`REGB_DDRC_CH0_OFFSET_MRRDATA1_MRR_DATA_UPR+:`REGB_DDRC_CH0_SIZE_MRRDATA1_MRR_DATA_UPR] = ddrc_reg_mrr_data_upr_pclk[(`REGB_DDRC_CH0_SIZE_MRRDATA1_MRR_DATA_UPR) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
   assign reg_ddrc_derate_enable_pclk = r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_ENABLE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_ENABLE];
   assign reg_ddrc_lpddr4_refresh_mode_pclk = r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_LPDDR4_REFRESH_MODE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_LPDDR4_REFRESH_MODE];
   assign reg_ddrc_derate_mr4_pause_fc_pclk = r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_MR4_PAUSE_FC+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_MR4_PAUSE_FC];
   assign reg_ddrc_dis_trefi_x6x8_pclk = r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X6X8+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X6X8];
   assign reg_ddrc_dis_trefi_x0125_pclk = r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X0125+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X0125];
   always_comb begin : s_data_r14_deratectl0_combo_PROC
      s_data_r14_deratectl0 = {REG_WIDTH {1'b0}};
      s_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_ENABLE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_ENABLE] = reg_ddrc_derate_enable_pclk;
      s_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_LPDDR4_REFRESH_MODE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_LPDDR4_REFRESH_MODE] = reg_ddrc_lpddr4_refresh_mode_pclk;
      s_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_MR4_PAUSE_FC+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_MR4_PAUSE_FC] = reg_ddrc_derate_mr4_pause_fc_pclk;
      s_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X6X8+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X6X8] = reg_ddrc_dis_trefi_x6x8_pclk;
      s_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X0125+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X0125] = reg_ddrc_dis_trefi_x0125_pclk;
   end
      assign reg_ddrc_derate_enable = d_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_ENABLE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_ENABLE];
      assign reg_ddrc_lpddr4_refresh_mode = d_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_LPDDR4_REFRESH_MODE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_LPDDR4_REFRESH_MODE];
      assign reg_ddrc_derate_mr4_pause_fc = d_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_MR4_PAUSE_FC+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_MR4_PAUSE_FC];
      assign reg_ddrc_dis_trefi_x6x8 = d_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X6X8+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X6X8];
      assign reg_ddrc_dis_trefi_x0125 = d_data_r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X0125+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X0125];
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
   assign reg_ddrc_active_derate_byte_rank0_pclk[(`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0) -1:0] = r15_deratectl1[`REGB_DDRC_CH0_OFFSET_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0+:`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0];
   always_comb begin : s_data_r15_deratectl1_combo_PROC
      s_data_r15_deratectl1 = {REG_WIDTH {1'b0}};
      s_data_r15_deratectl1[`REGB_DDRC_CH0_OFFSET_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0+:`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0] = reg_ddrc_active_derate_byte_rank0_pclk[(`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0)-1:0];
   end
      assign reg_ddrc_active_derate_byte_rank0[(`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0)-1:0] = d_data_r15_deratectl1[`REGB_DDRC_CH0_OFFSET_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0+:`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0];
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
   assign reg_ddrc_derate_temp_limit_intr_en = r19_deratectl5[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN+:`REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN];
   wire reg_ddrc_derate_temp_limit_intr_clr_pclk;
   assign reg_ddrc_derate_temp_limit_intr_clr_pclk = r19_deratectl5[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR+:`REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR];
   reg reg_ddrc_derate_temp_limit_intr_clr_pclk_s0;
   reg reg_ddrc_derate_temp_limit_intr_clr_ack;
   // reset reg_ddrc_derate_temp_limit_intr_clr field when the core logic has completed the update
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_derate_temp_limit_intr_clr_ack_PROC
      if (~apb_rst) begin
         reg_ddrc_derate_temp_limit_intr_clr_pclk_s0 <= 1'b0;
         reg_ddrc_derate_temp_limit_intr_clr_ack <= 1'b0;
      end else begin
         reg_ddrc_derate_temp_limit_intr_clr_pclk_s0 <= reg_ddrc_derate_temp_limit_intr_clr_pclk;
         reg_ddrc_derate_temp_limit_intr_clr_ack <= reg_ddrc_derate_temp_limit_intr_clr;
      end
   end
   assign reg_ddrc_derate_temp_limit_intr_clr = reg_ddrc_derate_temp_limit_intr_clr_pclk & (!reg_ddrc_derate_temp_limit_intr_clr_pclk_s0);
   assign reg_ddrc_derate_temp_limit_intr_clr_ack_pclk = reg_ddrc_derate_temp_limit_intr_clr_ack;
   wire reg_ddrc_derate_temp_limit_intr_force_pclk;
   assign reg_ddrc_derate_temp_limit_intr_force_pclk = r19_deratectl5[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE+:`REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE];
   reg reg_ddrc_derate_temp_limit_intr_force_pclk_s0;
   reg reg_ddrc_derate_temp_limit_intr_force_ack;
   // reset reg_ddrc_derate_temp_limit_intr_force field when the core logic has completed the update
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_derate_temp_limit_intr_force_ack_PROC
      if (~apb_rst) begin
         reg_ddrc_derate_temp_limit_intr_force_pclk_s0 <= 1'b0;
         reg_ddrc_derate_temp_limit_intr_force_ack <= 1'b0;
      end else begin
         reg_ddrc_derate_temp_limit_intr_force_pclk_s0 <= reg_ddrc_derate_temp_limit_intr_force_pclk;
         reg_ddrc_derate_temp_limit_intr_force_ack <= reg_ddrc_derate_temp_limit_intr_force;
      end
   end
   assign reg_ddrc_derate_temp_limit_intr_force = reg_ddrc_derate_temp_limit_intr_force_pclk & (!reg_ddrc_derate_temp_limit_intr_force_pclk_s0);
   assign reg_ddrc_derate_temp_limit_intr_force_ack_pclk = reg_ddrc_derate_temp_limit_intr_force_ack;
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
   assign reg_ddrc_derate_mr4_tuf_dis = r20_deratectl6[`REGB_DDRC_CH0_OFFSET_DERATECTL6_DERATE_MR4_TUF_DIS+:`REGB_DDRC_CH0_SIZE_DERATECTL6_DERATE_MR4_TUF_DIS];
   //------------------------
   // Register REGB_DDRC_CH0.DERATESTAT0
   //------------------------
   always_comb begin : r21_deratestat0_combo_PROC
      r21_deratestat0 = {REG_WIDTH{1'b0}};
      r21_deratestat0[`REGB_DDRC_CH0_OFFSET_DERATESTAT0_DERATE_TEMP_LIMIT_INTR+:`REGB_DDRC_CH0_SIZE_DERATESTAT0_DERATE_TEMP_LIMIT_INTR] = ddrc_reg_derate_temp_limit_intr;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
   assign reg_ddrc_dbg_mr4_grp_sel_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL) -1:0] = r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_GRP_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL];
   assign reg_ddrc_dbg_mr4_rank_sel_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL) -1:0] = r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_RANK_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL];
   always_comb begin : s_data_r23_deratedbgctl_combo_PROC
      s_data_r23_deratedbgctl = {REG_WIDTH {1'b0}};
      s_data_r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_GRP_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL] = reg_ddrc_dbg_mr4_grp_sel_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL)-1:0];
      s_data_r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_RANK_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL] = reg_ddrc_dbg_mr4_rank_sel_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL)-1:0];
   end
      assign reg_ddrc_dbg_mr4_grp_sel[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL)-1:0] = d_data_r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_GRP_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL];
      assign reg_ddrc_dbg_mr4_rank_sel[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL)-1:0] = d_data_r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_RANK_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL];
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGSTAT
   //------------------------
   always_comb begin : r24_deratedbgstat_combo_PROC
      r24_deratedbgstat = {REG_WIDTH{1'b0}};
      r24_deratedbgstat[`REGB_DDRC_CH0_OFFSET_DERATEDBGSTAT_DBG_MR4_BYTE0+:`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE0] = ddrc_reg_dbg_mr4_byte0_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE0) -1:0];
      r24_deratedbgstat[`REGB_DDRC_CH0_OFFSET_DERATEDBGSTAT_DBG_MR4_BYTE1+:`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE1] = ddrc_reg_dbg_mr4_byte1_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE1) -1:0];
      r24_deratedbgstat[`REGB_DDRC_CH0_OFFSET_DERATEDBGSTAT_DBG_MR4_BYTE2+:`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE2] = ddrc_reg_dbg_mr4_byte2_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE2) -1:0];
      r24_deratedbgstat[`REGB_DDRC_CH0_OFFSET_DERATEDBGSTAT_DBG_MR4_BYTE3+:`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE3] = ddrc_reg_dbg_mr4_byte3_pclk[(`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE3) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
   assign reg_ddrc_selfref_en_pclk[(`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN) -1:0] = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN];
   assign reg_ddrc_powerdown_en_pclk[(`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN) -1:0] = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_POWERDOWN_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN];
   assign reg_ddrc_en_dfi_dram_clk_disable_pclk = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`REGB_DDRC_CH0_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE];
   assign reg_ddrc_selfref_sw_pclk = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_SW+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_SW];
   assign reg_ddrc_stay_in_selfref_pclk = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_STAY_IN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_STAY_IN_SELFREF];
   assign reg_ddrc_dis_cam_drain_selfref_pclk = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF];
   assign reg_ddrc_lpddr4_sr_allowed_pclk = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_LPDDR4_SR_ALLOWED+:`REGB_DDRC_CH0_SIZE_PWRCTL_LPDDR4_SR_ALLOWED];
   assign reg_ddrc_dsm_en_pclk = r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DSM_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_DSM_EN];
   always_comb begin : s_data_r25_pwrctl_combo_PROC
      s_data_r25_pwrctl = {REG_WIDTH {1'b0}};
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN] = reg_ddrc_selfref_en_pclk[(`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN)-1:0];
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_POWERDOWN_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN] = reg_ddrc_powerdown_en_pclk[(`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN)-1:0];
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`REGB_DDRC_CH0_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE] = reg_ddrc_en_dfi_dram_clk_disable_pclk;
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_SW+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_SW] = reg_ddrc_selfref_sw_pclk;
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_STAY_IN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_STAY_IN_SELFREF] = reg_ddrc_stay_in_selfref_pclk;
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF] = reg_ddrc_dis_cam_drain_selfref_pclk;
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_LPDDR4_SR_ALLOWED+:`REGB_DDRC_CH0_SIZE_PWRCTL_LPDDR4_SR_ALLOWED] = reg_ddrc_lpddr4_sr_allowed_pclk;
      s_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DSM_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_DSM_EN] = reg_ddrc_dsm_en_pclk;
   end
      assign reg_ddrc_selfref_en[(`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN)-1:0] = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN];
      assign reg_ddrc_powerdown_en[(`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN)-1:0] = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_POWERDOWN_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN];
      assign reg_ddrc_en_dfi_dram_clk_disable = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`REGB_DDRC_CH0_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE];
      assign reg_ddrc_selfref_sw = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_SW+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_SW];
      assign reg_ddrc_stay_in_selfref = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_STAY_IN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_STAY_IN_SELFREF];
      assign reg_ddrc_dis_cam_drain_selfref = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF];
      assign reg_ddrc_lpddr4_sr_allowed = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_LPDDR4_SR_ALLOWED+:`REGB_DDRC_CH0_SIZE_PWRCTL_LPDDR4_SR_ALLOWED];
      assign reg_ddrc_dsm_en = d_data_r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DSM_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_DSM_EN];
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
   assign reg_ddrc_hw_lp_en = r26_hwlpctl[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EN+:`REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EN];
   assign reg_ddrc_hw_lp_exit_idle_en = r26_hwlpctl[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN+:`REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN];
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
   assign reg_ddrc_bsm_clk_on_pclk[(`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON) -1:0] = r28_clkgatectl[`REGB_DDRC_CH0_OFFSET_CLKGATECTL_BSM_CLK_ON+:`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON];
   always_comb begin : s_data_r28_clkgatectl_combo_PROC
      s_data_r28_clkgatectl = {REG_WIDTH {1'b0}};
      s_data_r28_clkgatectl[`REGB_DDRC_CH0_OFFSET_CLKGATECTL_BSM_CLK_ON+:`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON] = reg_ddrc_bsm_clk_on_pclk[(`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON)-1:0];
   end
      assign reg_ddrc_bsm_clk_on[(`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON)-1:0] = d_data_r28_clkgatectl[`REGB_DDRC_CH0_OFFSET_CLKGATECTL_BSM_CLK_ON+:`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON];
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
   assign reg_ddrc_refresh_burst_pclk[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST) -1:0] = r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_REFRESH_BURST+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST];
   assign reg_ddrc_auto_refab_en_pclk[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN) -1:0] = r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_AUTO_REFAB_EN+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN];
   assign reg_ddrc_per_bank_refresh_pclk = r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_PER_BANK_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_PER_BANK_REFRESH];
   always_comb begin : s_data_r29_rfshmod0_combo_PROC
      s_data_r29_rfshmod0 = {REG_WIDTH {1'b0}};
      s_data_r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_REFRESH_BURST+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST] = reg_ddrc_refresh_burst_pclk[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST)-1:0];
      s_data_r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_AUTO_REFAB_EN+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN] = reg_ddrc_auto_refab_en_pclk[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN)-1:0];
      s_data_r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_PER_BANK_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_PER_BANK_REFRESH] = reg_ddrc_per_bank_refresh_pclk;
   end
      assign reg_ddrc_refresh_burst[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST)-1:0] = d_data_r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_REFRESH_BURST+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST];
      assign reg_ddrc_auto_refab_en[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN)-1:0] = d_data_r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_AUTO_REFAB_EN+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN];
      assign reg_ddrc_per_bank_refresh = d_data_r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_PER_BANK_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_PER_BANK_REFRESH];
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
   assign reg_ddrc_dis_auto_refresh_pclk = r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_DIS_AUTO_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_DIS_AUTO_REFRESH];
   assign reg_ddrc_refresh_update_level_pclk = r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_REFRESH_UPDATE_LEVEL+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_REFRESH_UPDATE_LEVEL];
   always_comb begin : s_data_r31_rfshctl0_combo_PROC
      s_data_r31_rfshctl0 = {REG_WIDTH {1'b0}};
      s_data_r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_DIS_AUTO_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_DIS_AUTO_REFRESH] = reg_ddrc_dis_auto_refresh_pclk;
      s_data_r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_REFRESH_UPDATE_LEVEL+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_REFRESH_UPDATE_LEVEL] = reg_ddrc_refresh_update_level_pclk;
   end
      assign reg_ddrc_dis_auto_refresh = d_data_r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_DIS_AUTO_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_DIS_AUTO_REFRESH];
      assign reg_ddrc_refresh_update_level = d_data_r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_REFRESH_UPDATE_LEVEL+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_REFRESH_UPDATE_LEVEL];
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
   assign reg_ddrc_zq_resistor_shared_pclk = r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`REGB_DDRC_CH0_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED];
   assign reg_ddrc_dis_auto_zq_pclk = r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`REGB_DDRC_CH0_SIZE_ZQCTL0_DIS_AUTO_ZQ];
   always_comb begin : s_data_r34_zqctl0_combo_PROC
      s_data_r34_zqctl0 = {REG_WIDTH {1'b0}};
      s_data_r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`REGB_DDRC_CH0_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED] = reg_ddrc_zq_resistor_shared_pclk;
      s_data_r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`REGB_DDRC_CH0_SIZE_ZQCTL0_DIS_AUTO_ZQ] = reg_ddrc_dis_auto_zq_pclk;
   end
      assign reg_ddrc_zq_resistor_shared = d_data_r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`REGB_DDRC_CH0_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED];
      assign reg_ddrc_dis_auto_zq = d_data_r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`REGB_DDRC_CH0_SIZE_ZQCTL0_DIS_AUTO_ZQ];
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
   assign reg_ddrc_zq_reset_pclk = r35_zqctl1[`REGB_DDRC_CH0_OFFSET_ZQCTL1_ZQ_RESET+:`REGB_DDRC_CH0_SIZE_ZQCTL1_ZQ_RESET];
   assign ddrc_reg_zq_reset_busy_int = ddrc_reg_zq_reset_busy_pclk;
   always_comb begin : s_data_r35_zqctl1_combo_PROC
      s_data_r35_zqctl1 = {REG_WIDTH {1'b0}};
   end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
   assign reg_ddrc_dis_srx_zqcl = r36_zqctl2[`REGB_DDRC_CH0_OFFSET_ZQCTL2_DIS_SRX_ZQCL+:`REGB_DDRC_CH0_SIZE_ZQCTL2_DIS_SRX_ZQCL];
   //------------------------
   // Register REGB_DDRC_CH0.ZQSTAT
   //------------------------
   wire ddrc_reg_zq_reset_busy_pulse_pclk;

   reg  ddrc_reg_zq_reset_busy_ahead;
   reg  reg_ddrc_zq_reset_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_zq_reset_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_zq_reset_busy_ahead <= 1'b0; 
         reg_ddrc_zq_reset_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_zq_reset_pclk_s0 <= reg_ddrc_zq_reset_pclk; 
         if (ddrc_reg_zq_reset_busy_pulse_pclk || ddrc_reg_zq_reset_busy_pclk) begin 
            ddrc_reg_zq_reset_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_zq_reset_pclk & (!reg_ddrc_zq_reset_pclk_s0)) begin 
            ddrc_reg_zq_reset_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

  // Check eventually get ddrc_reg_zq_reset_busy_pulse_pclk or ddrc_reg_zq_reset_busy_pclk when reg_ddrc_zq_reset_pclk is detected
  property p_any_pclk_ddrc_reg_zq_reset_busy_after_zq_reset;
    @(posedge apb_clk) disable iff(!apb_rst)
         $rose(reg_ddrc_zq_reset_pclk) |-> (##[0:$] (ddrc_reg_zq_reset_busy_pulse_pclk || ddrc_reg_zq_reset_busy_pclk));
  endproperty

  a_any_pclk_ddrc_reg_zq_reset_busy_after_zq_reset : assert property (p_any_pclk_ddrc_reg_zq_reset_busy_after_zq_reset) else
    $display("-> %0t ERROR: APB ddrc_reg_zq_reset_busy_pulse_pclk or ddrc_reg_zq_reset_busy_pclk never recieved for reg_ddrc_zq_reset_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   always_comb begin : r37_zqstat_combo_PROC
      r37_zqstat = {REG_WIDTH{1'b0}};
      r37_zqstat[`REGB_DDRC_CH0_OFFSET_ZQSTAT_ZQ_RESET_BUSY+:`REGB_DDRC_CH0_SIZE_ZQSTAT_ZQ_RESET_BUSY] = ddrc_reg_zq_reset_busy_pclk          | ddrc_reg_zq_reset_busy_ahead
          | ff_regb_ddrc_ch0_zq_reset_saved
;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
   assign reg_ddrc_dqsosc_runtime[(`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME) -1:0] = r38_dqsoscruntime[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_DQSOSC_RUNTIME+:`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME];
   assign reg_ddrc_wck2dqo_runtime[(`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME) -1:0] = r38_dqsoscruntime[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_WCK2DQO_RUNTIME+:`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME];
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCSTAT0
   //------------------------
   reg  [REG_WIDTH-1:0] r39_dqsoscstat0_cclk;
   always_comb begin : r39_dqsoscstat0_cclk_combo_PROC
      r39_dqsoscstat0_cclk = {REG_WIDTH{1'b0}};
      r39_dqsoscstat0_cclk[`REGB_DDRC_CH0_OFFSET_DQSOSCSTAT0_DQSOSC_STATE+:`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_STATE] = ddrc_reg_dqsosc_state[(`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_STATE) -1:0];
      r39_dqsoscstat0_cclk[`REGB_DDRC_CH0_OFFSET_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT+:`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT] = ddrc_reg_dqsosc_per_rank_stat[(`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT) -1:0];
   end
   // For interrupt
   wire [(`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_STATE) -1:0] ddrc_reg_dqsosc_state_pclk;
   assign ddrc_reg_dqsosc_state_pclk = r39_dqsoscstat0[`REGB_DDRC_CH0_OFFSET_DQSOSCSTAT0_DQSOSC_STATE +: `REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_STATE];
   wire [(`REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT) -1:0] ddrc_reg_dqsosc_per_rank_stat_pclk;
   assign ddrc_reg_dqsosc_per_rank_stat_pclk = r39_dqsoscstat0[`REGB_DDRC_CH0_OFFSET_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT +: `REGB_DDRC_CH0_SIZE_DQSOSCSTAT0_DQSOSC_PER_RANK_STAT];

   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
   assign reg_ddrc_dis_dqsosc_srx = r40_dqsosccfg0[`REGB_DDRC_CH0_OFFSET_DQSOSCCFG0_DIS_DQSOSC_SRX+:`REGB_DDRC_CH0_SIZE_DQSOSCCFG0_DIS_DQSOSC_SRX];
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
   assign reg_ddrc_prefer_write = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_WRITE+:`REGB_DDRC_CH0_SIZE_SCHED0_PREFER_WRITE];
   assign reg_ddrc_pageclose = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_PAGECLOSE+:`REGB_DDRC_CH0_SIZE_SCHED0_PAGECLOSE];
   assign reg_ddrc_opt_wrcam_fill_level = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_OPT_WRCAM_FILL_LEVEL+:`REGB_DDRC_CH0_SIZE_SCHED0_OPT_WRCAM_FILL_LEVEL];
   assign reg_ddrc_dis_opt_ntt_by_act = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_ACT+:`REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_ACT];
   assign reg_ddrc_dis_opt_ntt_by_pre = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_PRE+:`REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_PRE];
   assign reg_ddrc_autopre_rmw = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_AUTOPRE_RMW+:`REGB_DDRC_CH0_SIZE_SCHED0_AUTOPRE_RMW];
   assign reg_ddrc_lpr_num_entries[(`REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES) -1:0] = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_LPR_NUM_ENTRIES+:`REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES];
   assign reg_ddrc_lpddr4_opt_act_timing = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR4_OPT_ACT_TIMING+:`REGB_DDRC_CH0_SIZE_SCHED0_LPDDR4_OPT_ACT_TIMING];
   assign reg_ddrc_lpddr5_opt_act_timing = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR5_OPT_ACT_TIMING+:`REGB_DDRC_CH0_SIZE_SCHED0_LPDDR5_OPT_ACT_TIMING];
   assign reg_ddrc_prefer_read = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_READ+:`REGB_DDRC_CH0_SIZE_SCHED0_PREFER_READ];
   assign reg_ddrc_dis_speculative_act = r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_SPECULATIVE_ACT+:`REGB_DDRC_CH0_SIZE_SCHED0_DIS_SPECULATIVE_ACT];
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
   assign reg_ddrc_delay_switch_write[(`REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE) -1:0] = r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_DELAY_SWITCH_WRITE+:`REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE];
   assign reg_ddrc_page_hit_limit_wr[(`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR) -1:0] = r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_WR+:`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR];
   assign reg_ddrc_page_hit_limit_rd[(`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD) -1:0] = r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_RD+:`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD];
   assign reg_ddrc_opt_hit_gt_hpr = r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_OPT_HIT_GT_HPR+:`REGB_DDRC_CH0_SIZE_SCHED1_OPT_HIT_GT_HPR];
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
   assign reg_ddrc_wrcam_lowthresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH) -1:0] = r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_LOWTHRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH];
   assign reg_ddrc_wrcam_highthresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH) -1:0] = r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_HIGHTHRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH];
   assign reg_ddrc_wr_pghit_num_thresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH) -1:0] = r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_WR_PGHIT_NUM_THRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH];
   assign reg_ddrc_rd_pghit_num_thresh[(`REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH) -1:0] = r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_RD_PGHIT_NUM_THRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH];
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
   assign reg_ddrc_rd_act_idle_gap[(`REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP) -1:0] = r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_ACT_IDLE_GAP+:`REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP];
   assign reg_ddrc_wr_act_idle_gap[(`REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP) -1:0] = r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_ACT_IDLE_GAP+:`REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP];
   assign reg_ddrc_rd_page_exp_cycles[(`REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES) -1:0] = r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_PAGE_EXP_CYCLES+:`REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES];
   assign reg_ddrc_wr_page_exp_cycles[(`REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES) -1:0] = r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_PAGE_EXP_CYCLES+:`REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES];
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
   assign reg_ddrc_dfi_lp_en_pd_pclk = r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_PD];
   assign reg_ddrc_dfi_lp_en_sr_pclk = r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_SR];
   assign reg_ddrc_dfi_lp_en_dsm_pclk = r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DSM+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DSM];
   assign reg_ddrc_dfi_lp_en_data_pclk = r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DATA+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DATA];
   assign reg_ddrc_dfi_lp_data_req_en_pclk = r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_DATA_REQ_EN+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_DATA_REQ_EN];
   always_comb begin : s_data_r56_dfilpcfg0_combo_PROC
      s_data_r56_dfilpcfg0 = {REG_WIDTH {1'b0}};
      s_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_PD] = reg_ddrc_dfi_lp_en_pd_pclk;
      s_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_SR] = reg_ddrc_dfi_lp_en_sr_pclk;
      s_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DSM+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DSM] = reg_ddrc_dfi_lp_en_dsm_pclk;
      s_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DATA+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DATA] = reg_ddrc_dfi_lp_en_data_pclk;
      s_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_DATA_REQ_EN+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_DATA_REQ_EN] = reg_ddrc_dfi_lp_data_req_en_pclk;
   end
      assign reg_ddrc_dfi_lp_en_pd = d_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_PD];
      assign reg_ddrc_dfi_lp_en_sr = d_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_SR];
      assign reg_ddrc_dfi_lp_en_dsm = d_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DSM+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DSM];
      assign reg_ddrc_dfi_lp_en_data = d_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DATA+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DATA];
      assign reg_ddrc_dfi_lp_data_req_en = d_data_r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_DATA_REQ_EN+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_DATA_REQ_EN];
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
   assign reg_ddrc_dfi_phyupd_en_pclk = r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DFI_PHYUPD_EN+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DFI_PHYUPD_EN];
   assign reg_ddrc_ctrlupd_pre_srx_pclk = r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_CTRLUPD_PRE_SRX];
   assign reg_ddrc_dis_auto_ctrlupd_srx_pclk = r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX];
   assign reg_ddrc_dis_auto_ctrlupd_pclk = r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD];
   always_comb begin : s_data_r57_dfiupd0_combo_PROC
      s_data_r57_dfiupd0 = {REG_WIDTH {1'b0}};
      s_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DFI_PHYUPD_EN+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DFI_PHYUPD_EN] = reg_ddrc_dfi_phyupd_en_pclk;
      s_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_CTRLUPD_PRE_SRX] = reg_ddrc_ctrlupd_pre_srx_pclk;
      s_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX] = reg_ddrc_dis_auto_ctrlupd_srx_pclk;
      s_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD] = reg_ddrc_dis_auto_ctrlupd_pclk;
   end
      assign reg_ddrc_dfi_phyupd_en = d_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DFI_PHYUPD_EN+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DFI_PHYUPD_EN];
      assign reg_ddrc_ctrlupd_pre_srx = d_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_CTRLUPD_PRE_SRX];
      assign reg_ddrc_dis_auto_ctrlupd_srx = d_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX];
      assign reg_ddrc_dis_auto_ctrlupd = d_data_r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD];
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
   assign reg_ddrc_dfi_init_complete_en_pclk = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN];
   assign reg_ddrc_phy_dbi_mode_pclk = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_PHY_DBI_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_PHY_DBI_MODE];
   assign reg_ddrc_dfi_data_cs_polarity_pclk = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_DATA_CS_POLARITY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_DATA_CS_POLARITY];
   assign reg_ddrc_dfi_init_start_pclk = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_START+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_START];
   assign reg_ddrc_lp_optimized_write_pclk = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_LP_OPTIMIZED_WRITE+:`REGB_DDRC_CH0_SIZE_DFIMISC_LP_OPTIMIZED_WRITE];
   assign reg_ddrc_dfi_frequency_pclk[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY) -1:0] = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQUENCY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY];
   assign reg_ddrc_dfi_freq_fsp_pclk[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP) -1:0] = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQ_FSP+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP];
   assign reg_ddrc_dfi_channel_mode_pclk[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE) -1:0] = r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_CHANNEL_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE];
   always_comb begin : s_data_r59_dfimisc_combo_PROC
      s_data_r59_dfimisc = {REG_WIDTH {1'b0}};
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN] = reg_ddrc_dfi_init_complete_en_pclk;
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_PHY_DBI_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_PHY_DBI_MODE] = reg_ddrc_phy_dbi_mode_pclk;
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_DATA_CS_POLARITY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_DATA_CS_POLARITY] = reg_ddrc_dfi_data_cs_polarity_pclk;
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_START+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_START] = reg_ddrc_dfi_init_start_pclk;
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_LP_OPTIMIZED_WRITE+:`REGB_DDRC_CH0_SIZE_DFIMISC_LP_OPTIMIZED_WRITE] = reg_ddrc_lp_optimized_write_pclk;
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQUENCY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY] = reg_ddrc_dfi_frequency_pclk[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY)-1:0];
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQ_FSP+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP] = reg_ddrc_dfi_freq_fsp_pclk[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP)-1:0];
      s_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_CHANNEL_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE] = reg_ddrc_dfi_channel_mode_pclk[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE)-1:0];
   end
      assign reg_ddrc_dfi_init_complete_en = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN];
      assign reg_ddrc_phy_dbi_mode = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_PHY_DBI_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_PHY_DBI_MODE];
      assign reg_ddrc_dfi_data_cs_polarity = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_DATA_CS_POLARITY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_DATA_CS_POLARITY];
      assign reg_ddrc_dfi_init_start = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_START+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_START];
      assign reg_ddrc_lp_optimized_write = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_LP_OPTIMIZED_WRITE+:`REGB_DDRC_CH0_SIZE_DFIMISC_LP_OPTIMIZED_WRITE];
      assign reg_ddrc_dfi_frequency[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY)-1:0] = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQUENCY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY];
      assign reg_ddrc_dfi_freq_fsp[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP)-1:0] = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQ_FSP+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP];
      assign reg_ddrc_dfi_channel_mode[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE)-1:0] = d_data_r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_CHANNEL_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE];
   //------------------------
   // Register REGB_DDRC_CH0.DFISTAT
   //------------------------
   always_comb begin : r60_dfistat_combo_PROC
      r60_dfistat = {REG_WIDTH{1'b0}};
      r60_dfistat[`REGB_DDRC_CH0_OFFSET_DFISTAT_DFI_INIT_COMPLETE+:`REGB_DDRC_CH0_SIZE_DFISTAT_DFI_INIT_COMPLETE] = ddrc_reg_dfi_init_complete_pclk;
      r60_dfistat[`REGB_DDRC_CH0_OFFSET_DFISTAT_DFI_LP_CTRL_ACK_STAT+:`REGB_DDRC_CH0_SIZE_DFISTAT_DFI_LP_CTRL_ACK_STAT] = ddrc_reg_dfi_lp_ctrl_ack_stat_pclk;
      r60_dfistat[`REGB_DDRC_CH0_OFFSET_DFISTAT_DFI_LP_DATA_ACK_STAT+:`REGB_DDRC_CH0_SIZE_DFISTAT_DFI_LP_DATA_ACK_STAT] = ddrc_reg_dfi_lp_data_ack_stat_pclk;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
   assign reg_ddrc_dfi_phymstr_en_pclk = r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN];
   assign reg_ddrc_dfi_phymstr_blk_ref_x32_pclk[(`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32) -1:0] = r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32];
   always_comb begin : s_data_r61_dfiphymstr_combo_PROC
      s_data_r61_dfiphymstr = {REG_WIDTH {1'b0}};
      s_data_r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN] = reg_ddrc_dfi_phymstr_en_pclk;
      s_data_r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32] = reg_ddrc_dfi_phymstr_blk_ref_x32_pclk[(`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32)-1:0];
   end
      assign reg_ddrc_dfi_phymstr_en = d_data_r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN];
      assign reg_ddrc_dfi_phymstr_blk_ref_x32[(`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32)-1:0] = d_data_r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32];
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
   assign reg_ddrc_dfi0_ctrlmsg_data_pclk[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA) -1:0] = r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_DATA+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA];
   assign reg_ddrc_dfi0_ctrlmsg_cmd_pclk[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD) -1:0] = r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_CMD+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD];
   assign reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk = r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR];
   assign reg_ddrc_dfi0_ctrlmsg_req_pclk = r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_REQ+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_REQ];
   assign ddrc_reg_dfi0_ctrlmsg_req_busy_int = ddrc_reg_dfi0_ctrlmsg_req_busy_pclk;
   always_comb begin : s_data_r62_dfi0msgctl0_combo_PROC
      s_data_r62_dfi0msgctl0 = {REG_WIDTH {1'b0}};
      s_data_r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_DATA+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA] = reg_ddrc_dfi0_ctrlmsg_data_pclk[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA)-1:0];
      s_data_r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_CMD+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD] = reg_ddrc_dfi0_ctrlmsg_cmd_pclk[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD)-1:0];
   end
      assign reg_ddrc_dfi0_ctrlmsg_data[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA)-1:0] = d_data_r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_DATA+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA];
      assign reg_ddrc_dfi0_ctrlmsg_cmd[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD)-1:0] = d_data_r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_CMD+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD];
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGSTAT0
   //------------------------
   wire ddrc_reg_dfi0_ctrlmsg_req_busy_pulse_pclk;

   reg  ddrc_reg_dfi0_ctrlmsg_req_busy_ahead;
   reg  reg_ddrc_dfi0_ctrlmsg_req_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_dfi0_ctrlmsg_req_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_dfi0_ctrlmsg_req_busy_ahead <= 1'b0; 
         reg_ddrc_dfi0_ctrlmsg_req_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_dfi0_ctrlmsg_req_pclk_s0 <= reg_ddrc_dfi0_ctrlmsg_req_pclk; 
         if (ddrc_reg_dfi0_ctrlmsg_req_busy_pulse_pclk || ddrc_reg_dfi0_ctrlmsg_req_busy_pclk) begin 
            ddrc_reg_dfi0_ctrlmsg_req_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_dfi0_ctrlmsg_req_pclk & (!reg_ddrc_dfi0_ctrlmsg_req_pclk_s0)) begin 
            ddrc_reg_dfi0_ctrlmsg_req_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

  // Check eventually get ddrc_reg_dfi0_ctrlmsg_req_busy_pulse_pclk or ddrc_reg_dfi0_ctrlmsg_req_busy_pclk when reg_ddrc_dfi0_ctrlmsg_req_pclk is detected
  property p_any_pclk_ddrc_reg_dfi0_ctrlmsg_req_busy_after_dfi0_ctrlmsg_req;
    @(posedge apb_clk) disable iff(!apb_rst)
         $rose(reg_ddrc_dfi0_ctrlmsg_req_pclk) |-> (##[0:$] (ddrc_reg_dfi0_ctrlmsg_req_busy_pulse_pclk || ddrc_reg_dfi0_ctrlmsg_req_busy_pclk));
  endproperty

  a_any_pclk_ddrc_reg_dfi0_ctrlmsg_req_busy_after_dfi0_ctrlmsg_req : assert property (p_any_pclk_ddrc_reg_dfi0_ctrlmsg_req_busy_after_dfi0_ctrlmsg_req) else
    $display("-> %0t ERROR: APB ddrc_reg_dfi0_ctrlmsg_req_busy_pulse_pclk or ddrc_reg_dfi0_ctrlmsg_req_busy_pclk never recieved for reg_ddrc_dfi0_ctrlmsg_req_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   always_comb begin : r63_dfi0msgstat0_combo_PROC
      r63_dfi0msgstat0 = {REG_WIDTH{1'b0}};
      r63_dfi0msgstat0[`REGB_DDRC_CH0_OFFSET_DFI0MSGSTAT0_DFI0_CTRLMSG_REQ_BUSY+:`REGB_DDRC_CH0_SIZE_DFI0MSGSTAT0_DFI0_CTRLMSG_REQ_BUSY] = ddrc_reg_dfi0_ctrlmsg_req_busy_pclk          | ddrc_reg_dfi0_ctrlmsg_req_busy_ahead
          | ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved
;
      r63_dfi0msgstat0[`REGB_DDRC_CH0_OFFSET_DFI0MSGSTAT0_DFI0_CTRLMSG_RESP_TOUT+:`REGB_DDRC_CH0_SIZE_DFI0MSGSTAT0_DFI0_CTRLMSG_RESP_TOUT] = ddrc_reg_dfi0_ctrlmsg_resp_tout_pclk;
   end
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
   assign reg_ddrc_wr_poison_slverr_en_pclk = r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_SLVERR_EN];
   assign reg_ddrc_wr_poison_intr_en_pclk = r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_EN];
   assign reg_ddrc_wr_poison_intr_clr_pclk = r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_CLR+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_CLR];
   assign reg_ddrc_rd_poison_slverr_en_pclk = r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_SLVERR_EN];
   assign reg_ddrc_rd_poison_intr_en_pclk = r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_EN];
   assign reg_ddrc_rd_poison_intr_clr_pclk = r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_CLR+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_CLR];
   always_comb begin : s_data_r64_poisoncfg_combo_PROC
      s_data_r64_poisoncfg = {REG_WIDTH {1'b0}};
      s_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_SLVERR_EN] = reg_ddrc_wr_poison_slverr_en_pclk;
      s_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_EN] = reg_ddrc_wr_poison_intr_en_pclk;
      s_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_SLVERR_EN] = reg_ddrc_rd_poison_slverr_en_pclk;
      s_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_EN] = reg_ddrc_rd_poison_intr_en_pclk;
   end
      assign reg_ddrc_wr_poison_slverr_en = d_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_SLVERR_EN];
      assign reg_ddrc_wr_poison_intr_en = d_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_EN];
      assign reg_ddrc_rd_poison_slverr_en = d_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_SLVERR_EN];
      assign reg_ddrc_rd_poison_intr_en = d_data_r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_EN];
   //------------------------
   // Register REGB_DDRC_CH0.POISONSTAT
   //------------------------
   always_comb begin : r65_poisonstat_combo_PROC
      r65_poisonstat = {REG_WIDTH{1'b0}};
      r65_poisonstat[`REGB_DDRC_CH0_OFFSET_POISONSTAT_WR_POISON_INTR_0+:`REGB_DDRC_CH0_SIZE_POISONSTAT_WR_POISON_INTR_0] = ddrc_reg_wr_poison_intr_0_pclk;
      r65_poisonstat[`REGB_DDRC_CH0_OFFSET_POISONSTAT_RD_POISON_INTR_0+:`REGB_DDRC_CH0_SIZE_POISONSTAT_RD_POISON_INTR_0] = ddrc_reg_rd_poison_intr_0_pclk;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
   assign reg_ddrc_dis_wc = r215_opctrl0[`REGB_DDRC_CH0_OFFSET_OPCTRL0_DIS_WC+:`REGB_DDRC_CH0_SIZE_OPCTRL0_DIS_WC];
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
   assign reg_ddrc_dis_dq_pclk = r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_DQ+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_DQ];
   assign reg_ddrc_dis_hif_pclk = r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_HIF+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_HIF];
   always_comb begin : s_data_r216_opctrl1_combo_PROC
      s_data_r216_opctrl1 = {REG_WIDTH {1'b0}};
      s_data_r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_DQ+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_DQ] = reg_ddrc_dis_dq_pclk;
      s_data_r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_HIF+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_HIF] = reg_ddrc_dis_hif_pclk;
   end
      assign reg_ddrc_dis_dq = d_data_r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_DQ+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_DQ];
      assign reg_ddrc_dis_hif = d_data_r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_HIF+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_HIF];
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCAM
   //------------------------
   always_comb begin : r217_opctrlcam_combo_PROC
      r217_opctrlcam = {REG_WIDTH{1'b0}};
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_DBG_HPR_Q_DEPTH+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_HPR_Q_DEPTH] = ddrc_reg_dbg_hpr_q_depth_pclk[(`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_HPR_Q_DEPTH) -1:0];
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_DBG_LPR_Q_DEPTH+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_LPR_Q_DEPTH] = ddrc_reg_dbg_lpr_q_depth_pclk[(`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_LPR_Q_DEPTH) -1:0];
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_DBG_W_Q_DEPTH+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_W_Q_DEPTH] = ddrc_reg_dbg_w_q_depth_pclk[(`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_W_Q_DEPTH) -1:0];
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_DBG_STALL+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_STALL] = ddrc_reg_dbg_stall_pclk;
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_DBG_RD_Q_EMPTY+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_RD_Q_EMPTY] = ddrc_reg_dbg_rd_q_empty_pclk;
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_DBG_WR_Q_EMPTY+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_WR_Q_EMPTY] = ddrc_reg_dbg_wr_q_empty_pclk;
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_RD_DATA_PIPELINE_EMPTY+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_RD_DATA_PIPELINE_EMPTY] = ddrc_reg_rd_data_pipeline_empty_pclk;
      r217_opctrlcam[`REGB_DDRC_CH0_OFFSET_OPCTRLCAM_WR_DATA_PIPELINE_EMPTY+:`REGB_DDRC_CH0_SIZE_OPCTRLCAM_WR_DATA_PIPELINE_EMPTY] = ddrc_reg_wr_data_pipeline_empty_pclk;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
   assign reg_ddrc_zq_calib_short_pclk = r218_opctrlcmd[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_ZQ_CALIB_SHORT+:`REGB_DDRC_CH0_SIZE_OPCTRLCMD_ZQ_CALIB_SHORT];
   assign ddrc_reg_zq_calib_short_busy_int = ddrc_reg_zq_calib_short_busy_pclk;
   assign reg_ddrc_ctrlupd_pclk = r218_opctrlcmd[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_CTRLUPD+:`REGB_DDRC_CH0_SIZE_OPCTRLCMD_CTRLUPD];
   assign ddrc_reg_ctrlupd_busy_int = ddrc_reg_ctrlupd_busy_pclk;
   always_comb begin : s_data_r218_opctrlcmd_combo_PROC
      s_data_r218_opctrlcmd = {REG_WIDTH {1'b0}};
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLSTAT
   //------------------------
   wire ddrc_reg_zq_calib_short_busy_pulse_pclk;

   reg  ddrc_reg_zq_calib_short_busy_ahead;
   reg  reg_ddrc_zq_calib_short_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_zq_calib_short_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_zq_calib_short_busy_ahead <= 1'b0; 
         reg_ddrc_zq_calib_short_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_zq_calib_short_pclk_s0 <= reg_ddrc_zq_calib_short_pclk; 
         if (ddrc_reg_zq_calib_short_busy_pulse_pclk || ddrc_reg_zq_calib_short_busy_pclk) begin 
            ddrc_reg_zq_calib_short_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_zq_calib_short_pclk & (!reg_ddrc_zq_calib_short_pclk_s0)) begin 
            ddrc_reg_zq_calib_short_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

  // Check eventually get ddrc_reg_zq_calib_short_busy_pulse_pclk or ddrc_reg_zq_calib_short_busy_pclk when reg_ddrc_zq_calib_short_pclk is detected
  property p_any_pclk_ddrc_reg_zq_calib_short_busy_after_zq_calib_short;
    @(posedge apb_clk) disable iff(!apb_rst)
         $rose(reg_ddrc_zq_calib_short_pclk) |-> (##[0:$] (ddrc_reg_zq_calib_short_busy_pulse_pclk || ddrc_reg_zq_calib_short_busy_pclk));
  endproperty

  a_any_pclk_ddrc_reg_zq_calib_short_busy_after_zq_calib_short : assert property (p_any_pclk_ddrc_reg_zq_calib_short_busy_after_zq_calib_short) else
    $display("-> %0t ERROR: APB ddrc_reg_zq_calib_short_busy_pulse_pclk or ddrc_reg_zq_calib_short_busy_pclk never recieved for reg_ddrc_zq_calib_short_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   wire ddrc_reg_ctrlupd_busy_pulse_pclk;

   reg  ddrc_reg_ctrlupd_busy_ahead;
   reg  reg_ddrc_ctrlupd_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_ctrlupd_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_ctrlupd_busy_ahead <= 1'b0; 
         reg_ddrc_ctrlupd_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_ctrlupd_pclk_s0 <= reg_ddrc_ctrlupd_pclk; 
         if (ddrc_reg_ctrlupd_busy_pulse_pclk || ddrc_reg_ctrlupd_busy_pclk) begin 
            ddrc_reg_ctrlupd_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_ctrlupd_pclk & (!reg_ddrc_ctrlupd_pclk_s0)) begin 
            ddrc_reg_ctrlupd_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

  // Check eventually get ddrc_reg_ctrlupd_busy_pulse_pclk or ddrc_reg_ctrlupd_busy_pclk when reg_ddrc_ctrlupd_pclk is detected
  property p_any_pclk_ddrc_reg_ctrlupd_busy_after_ctrlupd;
    @(posedge apb_clk) disable iff(!apb_rst)
         $rose(reg_ddrc_ctrlupd_pclk) |-> (##[0:$] (ddrc_reg_ctrlupd_busy_pulse_pclk || ddrc_reg_ctrlupd_busy_pclk));
  endproperty

  a_any_pclk_ddrc_reg_ctrlupd_busy_after_ctrlupd : assert property (p_any_pclk_ddrc_reg_ctrlupd_busy_after_ctrlupd) else
    $display("-> %0t ERROR: APB ddrc_reg_ctrlupd_busy_pulse_pclk or ddrc_reg_ctrlupd_busy_pclk never recieved for reg_ddrc_ctrlupd_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   always_comb begin : r219_opctrlstat_combo_PROC
      r219_opctrlstat = {REG_WIDTH{1'b0}};
      r219_opctrlstat[`REGB_DDRC_CH0_OFFSET_OPCTRLSTAT_ZQ_CALIB_SHORT_BUSY+:`REGB_DDRC_CH0_SIZE_OPCTRLSTAT_ZQ_CALIB_SHORT_BUSY] = ddrc_reg_zq_calib_short_busy_pclk          | ddrc_reg_zq_calib_short_busy_ahead
          | ff_regb_ddrc_ch0_zq_calib_short_saved
;
      r219_opctrlstat[`REGB_DDRC_CH0_OFFSET_OPCTRLSTAT_CTRLUPD_BUSY+:`REGB_DDRC_CH0_SIZE_OPCTRLSTAT_CTRLUPD_BUSY] = ddrc_reg_ctrlupd_busy_pclk          | ddrc_reg_ctrlupd_busy_ahead
          | ff_regb_ddrc_ch0_ctrlupd_saved
;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
   assign reg_ddrc_rank0_refresh_pclk = r221_oprefctrl0[`REGB_DDRC_CH0_OFFSET_OPREFCTRL0_RANK0_REFRESH+:`REGB_DDRC_CH0_SIZE_OPREFCTRL0_RANK0_REFRESH];
   assign ddrc_reg_rank0_refresh_busy_int = ddrc_reg_rank0_refresh_busy_pclk;
   always_comb begin : s_data_r221_oprefctrl0_combo_PROC
      s_data_r221_oprefctrl0 = {REG_WIDTH {1'b0}};
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPREFSTAT0
   //------------------------
   wire ddrc_reg_rank0_refresh_busy_pulse_pclk;

   reg  ddrc_reg_rank0_refresh_busy_ahead;
   reg  reg_ddrc_rank0_refresh_pclk_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_pclk_ddrc_reg_rank0_refresh_busy_ahead_PROC
      if (~apb_rst) begin 
         ddrc_reg_rank0_refresh_busy_ahead <= 1'b0; 
         reg_ddrc_rank0_refresh_pclk_s0 <= 1'b0; 
      end else begin 
         reg_ddrc_rank0_refresh_pclk_s0 <= reg_ddrc_rank0_refresh_pclk; 
         if (ddrc_reg_rank0_refresh_busy_pulse_pclk || ddrc_reg_rank0_refresh_busy_pclk) begin 
            ddrc_reg_rank0_refresh_busy_ahead <= 1'b0; 
         end else if (reg_ddrc_rank0_refresh_pclk & (!reg_ddrc_rank0_refresh_pclk_s0)) begin 
            ddrc_reg_rank0_refresh_busy_ahead <= 1'b1; 
         end 
      end 
   end 
   
   
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

  // Check eventually get ddrc_reg_rank0_refresh_busy_pulse_pclk or ddrc_reg_rank0_refresh_busy_pclk when reg_ddrc_rank0_refresh_pclk is detected
  property p_any_pclk_ddrc_reg_rank0_refresh_busy_after_rank0_refresh;
    @(posedge apb_clk) disable iff(!apb_rst)
         $rose(reg_ddrc_rank0_refresh_pclk) |-> (##[0:$] (ddrc_reg_rank0_refresh_busy_pulse_pclk || ddrc_reg_rank0_refresh_busy_pclk));
  endproperty

  a_any_pclk_ddrc_reg_rank0_refresh_busy_after_rank0_refresh : assert property (p_any_pclk_ddrc_reg_rank0_refresh_busy_after_rank0_refresh) else
    $display("-> %0t ERROR: APB ddrc_reg_rank0_refresh_busy_pulse_pclk or ddrc_reg_rank0_refresh_busy_pclk never recieved for reg_ddrc_rank0_refresh_pclk !!!", $realtime);

   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   always_comb begin : r223_oprefstat0_combo_PROC
      r223_oprefstat0 = {REG_WIDTH{1'b0}};
      r223_oprefstat0[`REGB_DDRC_CH0_OFFSET_OPREFSTAT0_RANK0_REFRESH_BUSY+:`REGB_DDRC_CH0_SIZE_OPREFSTAT0_RANK0_REFRESH_BUSY] = ddrc_reg_rank0_refresh_busy_pclk          | ddrc_reg_rank0_refresh_busy_ahead
          | ff_regb_ddrc_ch0_rank0_refresh_saved
;
   end
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
   assign reg_ddrc_sw_done = r225_swctl[`REGB_DDRC_CH0_OFFSET_SWCTL_SW_DONE+:`REGB_DDRC_CH0_SIZE_SWCTL_SW_DONE];
   //------------------------
   // Register REGB_DDRC_CH0.SWSTAT
   //------------------------
   always_comb begin : r226_swstat_combo_PROC
      r226_swstat = {REG_WIDTH{1'b0}};
      r226_swstat[`REGB_DDRC_CH0_OFFSET_SWSTAT_SW_DONE_ACK+:`REGB_DDRC_CH0_SIZE_SWSTAT_SW_DONE_ACK] = ddrc_reg_sw_done_ack;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
   assign reg_ddrc_dm_en_pclk = r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_DM_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_DM_EN];
   assign reg_ddrc_wr_dbi_en_pclk = r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_WR_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_WR_DBI_EN];
   assign reg_ddrc_rd_dbi_en_pclk = r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_RD_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_RD_DBI_EN];
   always_comb begin : s_data_r230_dbictl_combo_PROC
      s_data_r230_dbictl = {REG_WIDTH {1'b0}};
      s_data_r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_DM_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_DM_EN] = reg_ddrc_dm_en_pclk;
      s_data_r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_WR_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_WR_DBI_EN] = reg_ddrc_wr_dbi_en_pclk;
      s_data_r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_RD_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_RD_DBI_EN] = reg_ddrc_rd_dbi_en_pclk;
   end
      assign reg_ddrc_dm_en = d_data_r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_DM_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_DM_EN];
      assign reg_ddrc_wr_dbi_en = d_data_r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_WR_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_WR_DBI_EN];
      assign reg_ddrc_rd_dbi_en = d_data_r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_RD_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_RD_DBI_EN];
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
   assign reg_ddrc_rank0_wr_odt[(`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT) -1:0] = r232_odtmap[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_WR_ODT+:`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT];
   assign reg_ddrc_rank0_rd_odt[(`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT) -1:0] = r232_odtmap[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_RD_ODT+:`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT];
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
   assign reg_ddrc_rd_data_copy_en_pclk = r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_RD_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_RD_DATA_COPY_EN];
   assign reg_ddrc_wr_data_copy_en_pclk = r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_COPY_EN];
   assign reg_ddrc_wr_data_x_en_pclk = r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_X_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_X_EN];
   always_comb begin : s_data_r233_datactl0_combo_PROC
      s_data_r233_datactl0 = {REG_WIDTH {1'b0}};
      s_data_r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_RD_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_RD_DATA_COPY_EN] = reg_ddrc_rd_data_copy_en_pclk;
      s_data_r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_COPY_EN] = reg_ddrc_wr_data_copy_en_pclk;
      s_data_r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_X_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_X_EN] = reg_ddrc_wr_data_x_en_pclk;
   end
      assign reg_ddrc_rd_data_copy_en = d_data_r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_RD_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_RD_DATA_COPY_EN];
      assign reg_ddrc_wr_data_copy_en = d_data_r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_COPY_EN];
      assign reg_ddrc_wr_data_x_en = d_data_r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_X_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_X_EN];
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
   assign reg_ddrc_sw_static_unlock = r234_swctlstatic[`REGB_DDRC_CH0_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK+:`REGB_DDRC_CH0_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK];
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
   assign reg_ddrc_pre_cke_x1024_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024) -1:0] = r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_PRE_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024];
   assign reg_ddrc_post_cke_x1024_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024) -1:0] = r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_POST_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024];
   assign reg_ddrc_skip_dram_init_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT) -1:0] = r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_SKIP_DRAM_INIT+:`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT];
   always_comb begin : s_data_r235_inittmg0_combo_PROC
      s_data_r235_inittmg0 = {REG_WIDTH {1'b0}};
      s_data_r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_PRE_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024] = reg_ddrc_pre_cke_x1024_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024)-1:0];
      s_data_r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_POST_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024] = reg_ddrc_post_cke_x1024_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024)-1:0];
      s_data_r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_SKIP_DRAM_INIT+:`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT] = reg_ddrc_skip_dram_init_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT)-1:0];
   end
      assign reg_ddrc_pre_cke_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024)-1:0] = d_data_r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_PRE_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024];
      assign reg_ddrc_post_cke_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024)-1:0] = d_data_r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_POST_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024];
      assign reg_ddrc_skip_dram_init[(`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT)-1:0] = d_data_r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_SKIP_DRAM_INIT+:`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT];
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
   assign reg_ddrc_dram_rstn_x1024_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024) -1:0] = r236_inittmg1[`REGB_DDRC_CH0_OFFSET_INITTMG1_DRAM_RSTN_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024];
   always_comb begin : s_data_r236_inittmg1_combo_PROC
      s_data_r236_inittmg1 = {REG_WIDTH {1'b0}};
      s_data_r236_inittmg1[`REGB_DDRC_CH0_OFFSET_INITTMG1_DRAM_RSTN_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024] = reg_ddrc_dram_rstn_x1024_pclk[(`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024)-1:0];
   end
      assign reg_ddrc_dram_rstn_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024)-1:0] = d_data_r236_inittmg1[`REGB_DDRC_CH0_OFFSET_INITTMG1_DRAM_RSTN_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024];
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_NUMBER
   //------------------------
   always_comb begin : r263_ddrctl_ver_number_combo_PROC
      r263_ddrctl_ver_number = {REG_WIDTH{1'b0}};
      r263_ddrctl_ver_number[`REGB_DDRC_CH0_OFFSET_DDRCTL_VER_NUMBER_VER_NUMBER+:`REGB_DDRC_CH0_SIZE_DDRCTL_VER_NUMBER_VER_NUMBER] = ddrc_reg_ver_number[(`REGB_DDRC_CH0_SIZE_DDRCTL_VER_NUMBER_VER_NUMBER) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_TYPE
   //------------------------
   always_comb begin : r264_ddrctl_ver_type_combo_PROC
      r264_ddrctl_ver_type = {REG_WIDTH{1'b0}};
      r264_ddrctl_ver_type[`REGB_DDRC_CH0_OFFSET_DDRCTL_VER_TYPE_VER_TYPE+:`REGB_DDRC_CH0_SIZE_DDRCTL_VER_TYPE_VER_TYPE] = ddrc_reg_ver_type[(`REGB_DDRC_CH0_SIZE_DDRCTL_VER_TYPE_VER_TYPE) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
   assign reg_ddrc_addrmap_bank_b0_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0) -1:0] = r450_addrmap3_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B0+:`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0];
   assign reg_ddrc_addrmap_bank_b1_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1) -1:0] = r450_addrmap3_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B1+:`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1];
   assign reg_ddrc_addrmap_bank_b2_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2) -1:0] = r450_addrmap3_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B2+:`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
   assign reg_ddrc_addrmap_bg_b0_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0) -1:0] = r451_addrmap4_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B0+:`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0];
   assign reg_ddrc_addrmap_bg_b1_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1) -1:0] = r451_addrmap4_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B1+:`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
   assign reg_ddrc_addrmap_col_b7_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7) -1:0] = r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B7+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7];
   assign reg_ddrc_addrmap_col_b8_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8) -1:0] = r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B8+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8];
   assign reg_ddrc_addrmap_col_b9_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9) -1:0] = r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B9+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9];
   assign reg_ddrc_addrmap_col_b10_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10) -1:0] = r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B10+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
   assign reg_ddrc_addrmap_col_b3_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3) -1:0] = r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B3+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3];
   assign reg_ddrc_addrmap_col_b4_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4) -1:0] = r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B4+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4];
   assign reg_ddrc_addrmap_col_b5_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5) -1:0] = r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B5+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5];
   assign reg_ddrc_addrmap_col_b6_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6) -1:0] = r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B6+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
   assign reg_ddrc_addrmap_row_b14_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14) -1:0] = r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B14+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14];
   assign reg_ddrc_addrmap_row_b15_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15) -1:0] = r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B15+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15];
   assign reg_ddrc_addrmap_row_b16_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16) -1:0] = r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16];
   assign reg_ddrc_addrmap_row_b17_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17) -1:0] = r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
   assign reg_ddrc_addrmap_row_b10_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10) -1:0] = r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B10+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10];
   assign reg_ddrc_addrmap_row_b11_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11) -1:0] = r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B11+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11];
   assign reg_ddrc_addrmap_row_b12_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12) -1:0] = r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B12+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12];
   assign reg_ddrc_addrmap_row_b13_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13) -1:0] = r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B13+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
   assign reg_ddrc_addrmap_row_b6_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6) -1:0] = r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B6+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6];
   assign reg_ddrc_addrmap_row_b7_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7) -1:0] = r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B7+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7];
   assign reg_ddrc_addrmap_row_b8_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8) -1:0] = r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B8+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8];
   assign reg_ddrc_addrmap_row_b9_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9) -1:0] = r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B9+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
   assign reg_ddrc_addrmap_row_b2_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2) -1:0] = r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B2+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2];
   assign reg_ddrc_addrmap_row_b3_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3) -1:0] = r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B3+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3];
   assign reg_ddrc_addrmap_row_b4_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4) -1:0] = r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B4+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4];
   assign reg_ddrc_addrmap_row_b5_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5) -1:0] = r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B5+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
   assign reg_ddrc_addrmap_row_b0_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0) -1:0] = r458_addrmap11_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B0+:`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0];
   assign reg_ddrc_addrmap_row_b1_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1) -1:0] = r458_addrmap11_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B1+:`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1];
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
   assign reg_ddrc_nonbinary_device_density_map0_pclk[(`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY) -1:0] = r459_addrmap12_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP12_NONBINARY_DEVICE_DENSITY+:`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY];
   always_comb begin : s_data_r459_addrmap12_map0_combo_PROC
      s_data_r459_addrmap12_map0 = {REG_WIDTH {1'b0}};
      s_data_r459_addrmap12_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP12_NONBINARY_DEVICE_DENSITY+:`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY] = reg_ddrc_nonbinary_device_density_map0_pclk[(`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY)-1:0];
   end
      assign reg_ddrc_nonbinary_device_density_map0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY)-1:0] = d_data_r459_addrmap12_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP12_NONBINARY_DEVICE_DENSITY+:`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY];
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
   assign reg_arb_go2critical_en_port0 = r474_pccfg_port0[`REGB_ARB_PORT0_OFFSET_PCCFG_GO2CRITICAL_EN+:`REGB_ARB_PORT0_SIZE_PCCFG_GO2CRITICAL_EN];
   assign reg_arb_pagematch_limit_port0 = r474_pccfg_port0[`REGB_ARB_PORT0_OFFSET_PCCFG_PAGEMATCH_LIMIT+:`REGB_ARB_PORT0_SIZE_PCCFG_PAGEMATCH_LIMIT];
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
   assign reg_arb_rd_port_priority_port0[(`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY) -1:0] = r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PRIORITY+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY];
   assign reg_arb_rd_port_aging_en_port0 = r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_AGING_EN+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_AGING_EN];
   assign reg_arb_rd_port_urgent_en_port0 = r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_URGENT_EN+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_URGENT_EN];
   assign reg_arb_rd_port_pagematch_en_port0 = r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PAGEMATCH_EN+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PAGEMATCH_EN];
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
   assign reg_arb_wr_port_priority_port0[(`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY) -1:0] = r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PRIORITY+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY];
   assign reg_arb_wr_port_aging_en_port0 = r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_AGING_EN+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_AGING_EN];
   assign reg_arb_wr_port_urgent_en_port0 = r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_URGENT_EN+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_URGENT_EN];
   assign reg_arb_wr_port_pagematch_en_port0 = r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PAGEMATCH_EN+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PAGEMATCH_EN];
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
   assign reg_arb_port_en_port0_pclk = r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN];
   assign reg_apb_port_en_port0 = r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN];
   assign reg_arba0_port_en_port0_pclk = r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN];
   always_comb begin : s_data_r509_pctrl_port0_combo_PROC
      s_data_r509_pctrl_port0 = {REG_WIDTH {1'b0}};
      s_data_r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN] = reg_arb_port_en_port0_pclk;
   end
      assign reg_arb_port_en_port0 = d_data_r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN];
   always_comb begin : s_data_arba0_r509_pctrl_port0_combo_PROC
      s_data_arba0_r509_pctrl_port0 = {REG_WIDTH {1'b0}};
      s_data_arba0_r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN] = reg_arba0_port_en_port0_pclk;
   end
      assign reg_arba0_port_en_port0 = d_data_arba0_r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN];
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
   assign reg_arba0_rqos_map_level1_port0[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1) -1:0] = r510_pcfgqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_LEVEL1+:`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1];
   assign reg_arba0_rqos_map_region0_port0[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0) -1:0] = r510_pcfgqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION0+:`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0];
   assign reg_arba0_rqos_map_region1_port0[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1) -1:0] = r510_pcfgqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION1+:`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1];
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
   assign reg_arb_rqos_map_timeoutb_port0[(`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB) -1:0] = r511_pcfgqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTB+:`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB];
   assign reg_arb_rqos_map_timeoutr_port0[(`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR) -1:0] = r511_pcfgqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTR+:`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR];
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
   assign reg_arba0_wqos_map_level1_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1) -1:0] = r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL1+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1];
   assign reg_arba0_wqos_map_level2_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2) -1:0] = r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL2+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2];
   assign reg_arba0_wqos_map_region0_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0) -1:0] = r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION0+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0];
   assign reg_arba0_wqos_map_region1_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1) -1:0] = r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION1+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1];
   assign reg_arba0_wqos_map_region2_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2) -1:0] = r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION2+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2];
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
   assign reg_arb_wqos_map_timeout1_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1) -1:0] = r513_pcfgwqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT1+:`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1];
   assign reg_arb_wqos_map_timeout2_port0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2) -1:0] = r513_pcfgwqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT2+:`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2];
   //------------------------
   // Register REGB_ARB_PORT0.PSTAT
   //------------------------
   always_comb begin : r535_pstat_port0_combo_PROC
      r535_pstat_port0 = {REG_WIDTH{1'b0}};
      r535_pstat_port0[`REGB_ARB_PORT0_OFFSET_PSTAT_RD_PORT_BUSY_0+:`REGB_ARB_PORT0_SIZE_PSTAT_RD_PORT_BUSY_0] = arb_reg_rd_port_busy_0_port0_pclk;
      r535_pstat_port0[`REGB_ARB_PORT0_OFFSET_PSTAT_WR_PORT_BUSY_0+:`REGB_ARB_PORT0_SIZE_PSTAT_WR_PORT_BUSY_0] = arb_reg_wr_port_busy_0_port0_pclk;
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
   assign reg_ddrc_t_ras_min_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN) -1:0] = r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MIN+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN];
   assign reg_ddrc_t_ras_max_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX) -1:0] = r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MAX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX];
   assign reg_ddrc_t_faw_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW) -1:0] = r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_FAW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW];
   assign reg_ddrc_wr2pre_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE) -1:0] = r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_WR2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
   assign reg_ddrc_t_rc_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC) -1:0] = r1883_dramset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_RC+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC];
   assign reg_ddrc_rd2pre_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE) -1:0] = r1883_dramset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_RD2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE];
   assign reg_ddrc_t_xp_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP) -1:0] = r1883_dramset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_XP+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
   assign reg_ddrc_wr2rd_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD) -1:0] = r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WR2RD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD];
   assign reg_ddrc_rd2wr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR) -1:0] = r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_RD2WR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR];
   assign reg_ddrc_read_latency_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY) -1:0] = r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_READ_LATENCY+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY];
   assign reg_ddrc_write_latency_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY) -1:0] = r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WRITE_LATENCY+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
   assign reg_ddrc_wr2mr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR) -1:0] = r1885_dramset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_WR2MR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR];
   assign reg_ddrc_rd2mr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR) -1:0] = r1885_dramset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_RD2MR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR];
   assign reg_ddrc_t_mr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR) -1:0] = r1885_dramset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_T_MR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
   assign reg_ddrc_t_rp_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP) -1:0] = r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RP+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP];
   assign reg_ddrc_t_rrd_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD) -1:0] = r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RRD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD];
   assign reg_ddrc_t_ccd_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD) -1:0] = r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_CCD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD];
   assign reg_ddrc_t_rcd_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD) -1:0] = r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RCD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
   assign reg_ddrc_t_cke_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE) -1:0] = r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE];
   assign reg_ddrc_t_ckesr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR) -1:0] = r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKESR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR];
   assign reg_ddrc_t_cksre_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE) -1:0] = r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE];
   assign reg_ddrc_t_cksrx_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX) -1:0] = r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX];
   always_comb begin : s_data_r1887_dramset1tmg5_freq0_combo_PROC
      s_data_r1887_dramset1tmg5_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE] = reg_ddrc_t_cke_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE)-1:0];
      s_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKESR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR] = reg_ddrc_t_ckesr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR)-1:0];
      s_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE] = reg_ddrc_t_cksre_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE)-1:0];
      s_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX] = reg_ddrc_t_cksrx_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX)-1:0];
   end
      assign reg_ddrc_t_cke_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE)-1:0] = d_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE];
      assign reg_ddrc_t_ckesr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR)-1:0] = d_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKESR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR];
      assign reg_ddrc_t_cksre_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE)-1:0] = d_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE];
      assign reg_ddrc_t_cksrx_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX)-1:0] = d_data_r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
   assign reg_ddrc_t_ckcsx_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX) -1:0] = r1888_dramset1tmg6_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG6_T_CKCSX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
   assign reg_ddrc_t_csh_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH) -1:0] = r1889_dramset1tmg7_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG7_T_CSH+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH];
   always_comb begin : s_data_r1889_dramset1tmg7_freq0_combo_PROC
      s_data_r1889_dramset1tmg7_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1889_dramset1tmg7_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG7_T_CSH+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH] = reg_ddrc_t_csh_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH)-1:0];
   end
      assign reg_ddrc_t_csh_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH)-1:0] = d_data_r1889_dramset1tmg7_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG7_T_CSH+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
   assign reg_ddrc_wr2rd_s_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S) -1:0] = r1891_dramset1tmg9_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_WR2RD_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S];
   assign reg_ddrc_t_rrd_s_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S) -1:0] = r1891_dramset1tmg9_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_RRD_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S];
   assign reg_ddrc_t_ccd_s_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S) -1:0] = r1891_dramset1tmg9_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_CCD_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
   assign reg_ddrc_t_cmdcke_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE) -1:0] = r1894_dramset1tmg12_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG12_T_CMDCKE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
   assign reg_ddrc_t_ppd_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD) -1:0] = r1895_dramset1tmg13_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_PPD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD];
   assign reg_ddrc_t_ccd_mw_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW) -1:0] = r1895_dramset1tmg13_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_CCD_MW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW];
   assign reg_ddrc_odtloff_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF) -1:0] = r1895_dramset1tmg13_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_ODTLOFF+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
   assign reg_ddrc_t_xsr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR) -1:0] = r1896_dramset1tmg14_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_XSR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR];
   assign reg_ddrc_t_osco_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO) -1:0] = r1896_dramset1tmg14_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_OSCO+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
   assign reg_ddrc_t_pdn_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN) -1:0] = r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_PDN+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN];
   assign reg_ddrc_t_xsr_dsm_x1024_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024) -1:0] = r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_XSR_DSM_X1024+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024];
   always_comb begin : s_data_r1905_dramset1tmg23_freq0_combo_PROC
      s_data_r1905_dramset1tmg23_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_PDN+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN] = reg_ddrc_t_pdn_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN)-1:0];
      s_data_r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_XSR_DSM_X1024+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024] = reg_ddrc_t_xsr_dsm_x1024_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024)-1:0];
   end
      assign reg_ddrc_t_pdn_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN)-1:0] = d_data_r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_PDN+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN];
      assign reg_ddrc_t_xsr_dsm_x1024_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024)-1:0] = d_data_r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_XSR_DSM_X1024+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
   assign reg_ddrc_max_wr_sync_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC) -1:0] = r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_WR_SYNC+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC];
   assign reg_ddrc_max_rd_sync_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC) -1:0] = r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_RD_SYNC+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC];
   assign reg_ddrc_rd2wr_s_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S) -1:0] = r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_RD2WR_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S];
   assign reg_ddrc_bank_org_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG) -1:0] = r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_BANK_ORG+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
   assign reg_ddrc_rda2pre_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE) -1:0] = r1907_dramset1tmg25_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_RDA2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE];
   assign reg_ddrc_wra2pre_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE) -1:0] = r1907_dramset1tmg25_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_WRA2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE];
   assign reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE) -1:0] = r1907_dramset1tmg25_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE];
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
   assign reg_ddrc_mrr2rd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD) -1:0] = r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2RD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD];
   assign reg_ddrc_mrr2wr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR) -1:0] = r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2WR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR];
   assign reg_ddrc_mrr2mrw_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW) -1:0] = r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2MRW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW];
   always_comb begin : s_data_r1912_dramset1tmg30_freq0_combo_PROC
      s_data_r1912_dramset1tmg30_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2RD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD] = reg_ddrc_mrr2rd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD)-1:0];
      s_data_r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2WR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR] = reg_ddrc_mrr2wr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR)-1:0];
      s_data_r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2MRW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW] = reg_ddrc_mrr2mrw_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW)-1:0];
   end
      assign reg_ddrc_mrr2rd_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD)-1:0] = d_data_r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2RD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD];
      assign reg_ddrc_mrr2wr_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR)-1:0] = d_data_r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2WR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR];
      assign reg_ddrc_mrr2mrw_freq0[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW)-1:0] = d_data_r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2MRW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW];
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
   assign reg_ddrc_emr_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR0_EMR) -1:0] = r1938_initmr0_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR0_EMR+:`REGB_FREQ0_CH0_SIZE_INITMR0_EMR];
   assign reg_ddrc_mr_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR0_MR) -1:0] = r1938_initmr0_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR0_MR+:`REGB_FREQ0_CH0_SIZE_INITMR0_MR];
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
   assign reg_ddrc_emr3_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3) -1:0] = r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR3+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3];
   assign reg_ddrc_emr2_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2) -1:0] = r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR2+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2];
   always_comb begin : s_data_r1939_initmr1_freq0_combo_PROC
      s_data_r1939_initmr1_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR3+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3] = reg_ddrc_emr3_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3)-1:0];
      s_data_r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR2+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2] = reg_ddrc_emr2_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2)-1:0];
   end
      assign reg_ddrc_emr3_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3)-1:0] = d_data_r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR3+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3];
      assign reg_ddrc_emr2_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2)-1:0] = d_data_r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR2+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2];
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
   assign reg_ddrc_mr5_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR2_MR5) -1:0] = r1940_initmr2_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR5+:`REGB_FREQ0_CH0_SIZE_INITMR2_MR5];
   assign reg_ddrc_mr4_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR2_MR4) -1:0] = r1940_initmr2_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR4+:`REGB_FREQ0_CH0_SIZE_INITMR2_MR4];
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
   assign reg_ddrc_mr6_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR3_MR6) -1:0] = r1941_initmr3_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR6+:`REGB_FREQ0_CH0_SIZE_INITMR3_MR6];
   assign reg_ddrc_mr22_freq0[(`REGB_FREQ0_CH0_SIZE_INITMR3_MR22) -1:0] = r1941_initmr3_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR22+:`REGB_FREQ0_CH0_SIZE_INITMR3_MR22];
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
   assign reg_ddrc_dfi_tphy_wrlat_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT) -1:0] = r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT];
   assign reg_ddrc_dfi_tphy_wrdata_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA) -1:0] = r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRDATA+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA];
   assign reg_ddrc_dfi_t_rddata_en_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN) -1:0] = r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_RDDATA_EN+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN];
   assign reg_ddrc_dfi_t_ctrl_delay_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY) -1:0] = r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_CTRL_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY];
   always_comb begin : s_data_r1942_dfitmg0_freq0_combo_PROC
      s_data_r1942_dfitmg0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT] = reg_ddrc_dfi_tphy_wrlat_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT)-1:0];
      s_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRDATA+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA] = reg_ddrc_dfi_tphy_wrdata_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA)-1:0];
      s_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_RDDATA_EN+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN] = reg_ddrc_dfi_t_rddata_en_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN)-1:0];
      s_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_CTRL_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY] = reg_ddrc_dfi_t_ctrl_delay_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY)-1:0];
   end
      assign reg_ddrc_dfi_tphy_wrlat_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT)-1:0] = d_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT];
      assign reg_ddrc_dfi_tphy_wrdata_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA)-1:0] = d_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRDATA+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA];
      assign reg_ddrc_dfi_t_rddata_en_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN)-1:0] = d_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_RDDATA_EN+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN];
      assign reg_ddrc_dfi_t_ctrl_delay_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY)-1:0] = d_data_r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_CTRL_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY];
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
   assign reg_ddrc_dfi_t_dram_clk_enable_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE) -1:0] = r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE];
   assign reg_ddrc_dfi_t_dram_clk_disable_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE) -1:0] = r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE];
   assign reg_ddrc_dfi_t_wrdata_delay_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY) -1:0] = r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY];
   always_comb begin : s_data_r1943_dfitmg1_freq0_combo_PROC
      s_data_r1943_dfitmg1_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE] = reg_ddrc_dfi_t_dram_clk_enable_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE)-1:0];
      s_data_r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE] = reg_ddrc_dfi_t_dram_clk_disable_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE)-1:0];
      s_data_r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY] = reg_ddrc_dfi_t_wrdata_delay_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY)-1:0];
   end
      assign reg_ddrc_dfi_t_dram_clk_enable_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE)-1:0] = d_data_r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE];
      assign reg_ddrc_dfi_t_dram_clk_disable_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE)-1:0] = d_data_r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE];
      assign reg_ddrc_dfi_t_wrdata_delay_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY)-1:0] = d_data_r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY];
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
   assign reg_ddrc_dfi_tphy_wrcslat_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT) -1:0] = r1944_dfitmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_WRCSLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT];
   assign reg_ddrc_dfi_tphy_rdcslat_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT) -1:0] = r1944_dfitmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_RDCSLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT];
   assign reg_ddrc_dfi_twck_delay_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY) -1:0] = r1944_dfitmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TWCK_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY];
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
   assign reg_ddrc_dfi_twck_dis_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS) -1:0] = r1946_dfitmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_DIS+:`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS];
   assign reg_ddrc_dfi_twck_en_wr_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR) -1:0] = r1946_dfitmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_WR+:`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR];
   assign reg_ddrc_dfi_twck_en_rd_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD) -1:0] = r1946_dfitmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_RD+:`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD];
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
   assign reg_ddrc_dfi_twck_toggle_post_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST) -1:0] = r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_POST+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST];
   assign reg_ddrc_dfi_twck_toggle_cs_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS) -1:0] = r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_CS+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS];
   assign reg_ddrc_dfi_twck_toggle_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE) -1:0] = r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE];
   assign reg_ddrc_dfi_twck_fast_toggle_freq0[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE) -1:0] = r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_FAST_TOGGLE+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE];
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
   assign reg_ddrc_dfi_lp_wakeup_pd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD) -1:0] = r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_PD+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD];
   assign reg_ddrc_dfi_lp_wakeup_sr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR) -1:0] = r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_SR+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR];
   assign reg_ddrc_dfi_lp_wakeup_dsm_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM) -1:0] = r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_DSM+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM];
   always_comb begin : s_data_r1949_dfilptmg0_freq0_combo_PROC
      s_data_r1949_dfilptmg0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_PD+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD] = reg_ddrc_dfi_lp_wakeup_pd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD)-1:0];
      s_data_r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_SR+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR] = reg_ddrc_dfi_lp_wakeup_sr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR)-1:0];
      s_data_r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_DSM+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM] = reg_ddrc_dfi_lp_wakeup_dsm_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM)-1:0];
   end
      assign reg_ddrc_dfi_lp_wakeup_pd_freq0[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD)-1:0] = d_data_r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_PD+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD];
      assign reg_ddrc_dfi_lp_wakeup_sr_freq0[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR)-1:0] = d_data_r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_SR+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR];
      assign reg_ddrc_dfi_lp_wakeup_dsm_freq0[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM)-1:0] = d_data_r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_DSM+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM];
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
   assign reg_ddrc_dfi_lp_wakeup_data_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA) -1:0] = r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_LP_WAKEUP_DATA+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA];
   assign reg_ddrc_dfi_tlp_resp_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP) -1:0] = r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_TLP_RESP+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP];
   always_comb begin : s_data_r1950_dfilptmg1_freq0_combo_PROC
      s_data_r1950_dfilptmg1_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_LP_WAKEUP_DATA+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA] = reg_ddrc_dfi_lp_wakeup_data_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA)-1:0];
      s_data_r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_TLP_RESP+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP] = reg_ddrc_dfi_tlp_resp_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP)-1:0];
   end
      assign reg_ddrc_dfi_lp_wakeup_data_freq0[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA)-1:0] = d_data_r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_LP_WAKEUP_DATA+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA];
      assign reg_ddrc_dfi_tlp_resp_freq0[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP)-1:0] = d_data_r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_TLP_RESP+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP];
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
   assign reg_ddrc_dfi_t_ctrlup_min_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN) -1:0] = r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MIN+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN];
   assign reg_ddrc_dfi_t_ctrlup_max_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX) -1:0] = r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MAX+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX];
   always_comb begin : s_data_r1951_dfiupdtmg0_freq0_combo_PROC
      s_data_r1951_dfiupdtmg0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MIN+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN] = reg_ddrc_dfi_t_ctrlup_min_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN)-1:0];
      s_data_r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MAX+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX] = reg_ddrc_dfi_t_ctrlup_max_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX)-1:0];
   end
      assign reg_ddrc_dfi_t_ctrlup_min_freq0[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN)-1:0] = d_data_r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MIN+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN];
      assign reg_ddrc_dfi_t_ctrlup_max_freq0[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX)-1:0] = d_data_r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MAX+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX];
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
   assign reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024) -1:0] = r1952_dfiupdtmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024];
   assign reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024) -1:0] = r1952_dfiupdtmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024];
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
   assign reg_ddrc_dfi_t_ctrlmsg_resp_freq0[(`REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP) -1:0] = r1953_dfimsgtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIMSGTMG0_DFI_T_CTRLMSG_RESP+:`REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP];
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
   assign reg_ddrc_t_refi_x1_x32_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32) -1:0] = r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32];
   assign reg_ddrc_refresh_to_x1_x32_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32) -1:0] = r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_TO_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32];
   assign reg_ddrc_refresh_margin_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN) -1:0] = r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_MARGIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN];
   assign reg_ddrc_t_refi_x1_sel_freq0_pclk = r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_SEL+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_SEL];
   always_comb begin : s_data_r1955_rfshset1tmg0_freq0_combo_PROC
      s_data_r1955_rfshset1tmg0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32] = reg_ddrc_t_refi_x1_x32_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32)-1:0];
      s_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_TO_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32] = reg_ddrc_refresh_to_x1_x32_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32)-1:0];
      s_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_MARGIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN] = reg_ddrc_refresh_margin_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN)-1:0];
      s_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_SEL+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_SEL] = reg_ddrc_t_refi_x1_sel_freq0_pclk;
   end
      assign reg_ddrc_t_refi_x1_x32_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32)-1:0] = d_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32];
      assign reg_ddrc_refresh_to_x1_x32_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32)-1:0] = d_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_TO_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32];
      assign reg_ddrc_refresh_margin_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN)-1:0] = d_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_MARGIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN];
      assign reg_ddrc_t_refi_x1_sel_freq0 = d_data_r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_SEL+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_SEL];
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
   assign reg_ddrc_t_rfc_min_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN) -1:0] = r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN];
   assign reg_ddrc_t_rfc_min_ab_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB) -1:0] = r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN_AB+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB];
   always_comb begin : s_data_r1956_rfshset1tmg1_freq0_combo_PROC
      s_data_r1956_rfshset1tmg1_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN] = reg_ddrc_t_rfc_min_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN)-1:0];
      s_data_r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN_AB+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB] = reg_ddrc_t_rfc_min_ab_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB)-1:0];
   end
      assign reg_ddrc_t_rfc_min_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN)-1:0] = d_data_r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN];
      assign reg_ddrc_t_rfc_min_ab_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB)-1:0] = d_data_r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN_AB+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB];
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
   assign reg_ddrc_t_pbr2pbr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR) -1:0] = r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2PBR+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR];
   assign reg_ddrc_t_pbr2act_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT) -1:0] = r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2ACT+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT];
   always_comb begin : s_data_r1957_rfshset1tmg2_freq0_combo_PROC
      s_data_r1957_rfshset1tmg2_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2PBR+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR] = reg_ddrc_t_pbr2pbr_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR)-1:0];
      s_data_r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2ACT+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT] = reg_ddrc_t_pbr2act_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT)-1:0];
   end
      assign reg_ddrc_t_pbr2pbr_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR)-1:0] = d_data_r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2PBR+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR];
      assign reg_ddrc_t_pbr2act_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT)-1:0] = d_data_r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2ACT+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT];
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
   assign reg_ddrc_refresh_to_ab_x32_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32) -1:0] = r1958_rfshset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG3_REFRESH_TO_AB_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32];
   always_comb begin : s_data_r1958_rfshset1tmg3_freq0_combo_PROC
      s_data_r1958_rfshset1tmg3_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1958_rfshset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG3_REFRESH_TO_AB_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32] = reg_ddrc_refresh_to_ab_x32_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32)-1:0];
   end
      assign reg_ddrc_refresh_to_ab_x32_freq0[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32)-1:0] = d_data_r1958_rfshset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG3_REFRESH_TO_AB_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32];
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
   assign reg_ddrc_t_zq_long_nop_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP) -1:0] = r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_LONG_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP];
   assign reg_ddrc_t_zq_short_nop_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP) -1:0] = r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_SHORT_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP];
   always_comb begin : s_data_r1975_zqset1tmg0_freq0_combo_PROC
      s_data_r1975_zqset1tmg0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_LONG_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP] = reg_ddrc_t_zq_long_nop_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP)-1:0];
      s_data_r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_SHORT_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP] = reg_ddrc_t_zq_short_nop_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP)-1:0];
   end
      assign reg_ddrc_t_zq_long_nop_freq0[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP)-1:0] = d_data_r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_LONG_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP];
      assign reg_ddrc_t_zq_short_nop_freq0[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP)-1:0] = d_data_r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_SHORT_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP];
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
   assign reg_ddrc_t_zq_short_interval_x1024_freq0[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024) -1:0] = r1976_zqset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024];
   assign reg_ddrc_t_zq_reset_nop_freq0[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP) -1:0] = r1976_zqset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_RESET_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP];
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
   assign reg_ddrc_dqsosc_enable_freq0_pclk = r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_ENABLE+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_ENABLE];
   assign reg_ddrc_dqsosc_interval_unit_freq0_pclk = r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT];
   assign reg_ddrc_dqsosc_interval_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL) -1:0] = r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL];
   always_comb begin : s_data_r1985_dqsoscctl0_freq0_combo_PROC
      s_data_r1985_dqsoscctl0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_ENABLE+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_ENABLE] = reg_ddrc_dqsosc_enable_freq0_pclk;
      s_data_r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT] = reg_ddrc_dqsosc_interval_unit_freq0_pclk;
      s_data_r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL] = reg_ddrc_dqsosc_interval_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL)-1:0];
   end
      assign reg_ddrc_dqsosc_enable_freq0 = d_data_r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_ENABLE+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_ENABLE];
      assign reg_ddrc_dqsosc_interval_unit_freq0 = d_data_r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT];
      assign reg_ddrc_dqsosc_interval_freq0[(`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL)-1:0] = d_data_r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL];
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
   assign reg_ddrc_mr4_read_interval_freq0[(`REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL) -1:0] = r1986_derateint_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEINT_MR4_READ_INTERVAL+:`REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL];
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
   assign reg_ddrc_derated_t_rrd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD) -1:0] = r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RRD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD];
   assign reg_ddrc_derated_t_rp_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP) -1:0] = r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RP+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP];
   assign reg_ddrc_derated_t_ras_min_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN) -1:0] = r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RAS_MIN+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN];
   assign reg_ddrc_derated_t_rcd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD) -1:0] = r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RCD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD];
   always_comb begin : s_data_r1987_derateval0_freq0_combo_PROC
      s_data_r1987_derateval0_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RRD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD] = reg_ddrc_derated_t_rrd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD)-1:0];
      s_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RP+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP] = reg_ddrc_derated_t_rp_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP)-1:0];
      s_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RAS_MIN+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN] = reg_ddrc_derated_t_ras_min_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN)-1:0];
      s_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RCD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD] = reg_ddrc_derated_t_rcd_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD)-1:0];
   end
      assign reg_ddrc_derated_t_rrd_freq0[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD)-1:0] = d_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RRD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD];
      assign reg_ddrc_derated_t_rp_freq0[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP)-1:0] = d_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RP+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP];
      assign reg_ddrc_derated_t_ras_min_freq0[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN)-1:0] = d_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RAS_MIN+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN];
      assign reg_ddrc_derated_t_rcd_freq0[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD)-1:0] = d_data_r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RCD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD];
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
   assign reg_ddrc_derated_t_rc_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC) -1:0] = r1988_derateval1_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL1_DERATED_T_RC+:`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC];
   always_comb begin : s_data_r1988_derateval1_freq0_combo_PROC
      s_data_r1988_derateval1_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1988_derateval1_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL1_DERATED_T_RC+:`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC] = reg_ddrc_derated_t_rc_freq0_pclk[(`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC)-1:0];
   end
      assign reg_ddrc_derated_t_rc_freq0[(`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC)-1:0] = d_data_r1988_derateval1_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL1_DERATED_T_RC+:`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC];
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
   assign reg_ddrc_hw_lp_idle_x32_freq0[(`REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32) -1:0] = r1989_hwlptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_HWLPTMG0_HW_LP_IDLE_X32+:`REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32];
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
   assign reg_ddrc_pageclose_timer_freq0[(`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER) -1:0] = r1990_schedtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_PAGECLOSE_TIMER+:`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER];
   assign reg_ddrc_rdwr_idle_gap_freq0[(`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP) -1:0] = r1990_schedtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_RDWR_IDLE_GAP+:`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP];
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
   assign reg_ddrc_hpr_max_starve_freq0[(`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE) -1:0] = r1991_perfhpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_MAX_STARVE+:`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE];
   assign reg_ddrc_hpr_xact_run_length_freq0[(`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH) -1:0] = r1991_perfhpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH+:`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH];
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
   assign reg_ddrc_lpr_max_starve_freq0[(`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE) -1:0] = r1992_perflpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_MAX_STARVE+:`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE];
   assign reg_ddrc_lpr_xact_run_length_freq0[(`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH) -1:0] = r1992_perflpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH+:`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH];
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
   assign reg_ddrc_w_max_starve_freq0[(`REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE) -1:0] = r1993_perfwr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_MAX_STARVE+:`REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE];
   assign reg_ddrc_w_xact_run_length_freq0[(`REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH) -1:0] = r1993_perfwr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_XACT_RUN_LENGTH+:`REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH];
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
   assign reg_ddrc_frequency_ratio_freq0_pclk = r1994_tmgcfg_freq0[`REGB_FREQ0_CH0_OFFSET_TMGCFG_FREQUENCY_RATIO+:`REGB_FREQ0_CH0_SIZE_TMGCFG_FREQUENCY_RATIO];
   always_comb begin : s_data_r1994_tmgcfg_freq0_combo_PROC
      s_data_r1994_tmgcfg_freq0 = {REG_WIDTH {1'b0}};
      s_data_r1994_tmgcfg_freq0[`REGB_FREQ0_CH0_OFFSET_TMGCFG_FREQUENCY_RATIO+:`REGB_FREQ0_CH0_SIZE_TMGCFG_FREQUENCY_RATIO] = reg_ddrc_frequency_ratio_freq0_pclk;
   end
      assign reg_ddrc_frequency_ratio_freq0 = d_data_r1994_tmgcfg_freq0[`REGB_FREQ0_CH0_OFFSET_TMGCFG_FREQUENCY_RATIO+:`REGB_FREQ0_CH0_SIZE_TMGCFG_FREQUENCY_RATIO];
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
   assign reg_ddrc_powerdown_to_x32_freq0[(`REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32) -1:0] = r1997_pwrtmg_freq0[`REGB_FREQ0_CH0_OFFSET_PWRTMG_POWERDOWN_TO_X32+:`REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32];
   assign reg_ddrc_selfref_to_x32_freq0[(`REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32) -1:0] = r1997_pwrtmg_freq0[`REGB_FREQ0_CH0_OFFSET_PWRTMG_SELFREF_TO_X32+:`REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32];












   //----------------------------------------------
   // Clock domain crossing: STATIC RO registers
   // Resample combo before sampling in pclk
   //----------------------------------------------
   always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin: sample_cclk_ro_static_PROC
      if (!core_ddrc_rstn) begin
         ddrc_reg_selfref_type_cclk <= 'h0;
         ddrc_reg_selfref_state_cclk <= 'h0;
         ddrc_reg_selfref_cam_not_empty_cclk <= 'h0;
         ddrc_reg_mr_wr_busy_cclk <= 'h0;
         ddrc_reg_mrr_done_cclk <= 'h0;
         ddrc_reg_mrr_data_lwr_cclk <= 'h0;
         ddrc_reg_mrr_data_upr_cclk <= 'h0;
         ddrc_reg_dqsosc_state_cclk <= 'h0;
         ddrc_reg_dqsosc_per_rank_stat_cclk <= 'h0;
         ddrc_reg_dfi_init_complete_cclk <= 'h0;
         ddrc_reg_dfi_lp_ctrl_ack_stat_cclk <= 'h0;
         ddrc_reg_dfi_lp_data_ack_stat_cclk <= 'h0;
         ddrc_reg_dfi0_ctrlmsg_req_busy_cclk <= 'h0;
         ddrc_reg_dfi0_ctrlmsg_resp_tout_cclk <= 'h0;
         ddrc_reg_dbg_stall_cclk <= 'h0;
         ddrc_reg_dbg_rd_q_empty_cclk <= 'h0;
         ddrc_reg_dbg_wr_q_empty_cclk <= 'h0;
         ddrc_reg_rd_data_pipeline_empty_cclk <= 'h0;
         ddrc_reg_wr_data_pipeline_empty_cclk <= 'h0;

      end else begin
         ddrc_reg_selfref_type_cclk <= ddrc_reg_selfref_type;
         ddrc_reg_selfref_state_cclk <= ddrc_reg_selfref_state;
         ddrc_reg_selfref_cam_not_empty_cclk <= ddrc_reg_selfref_cam_not_empty;
         ddrc_reg_mr_wr_busy_cclk <= ddrc_reg_mr_wr_busy;
         ddrc_reg_mrr_done_cclk <= ddrc_reg_mrr_done;
         ddrc_reg_mrr_data_lwr_cclk <= ddrc_reg_mrr_data_lwr;
         ddrc_reg_mrr_data_upr_cclk <= ddrc_reg_mrr_data_upr;
         ddrc_reg_dqsosc_state_cclk <= ddrc_reg_dqsosc_state;
         ddrc_reg_dqsosc_per_rank_stat_cclk <= ddrc_reg_dqsosc_per_rank_stat;
         ddrc_reg_dfi_init_complete_cclk <= ddrc_reg_dfi_init_complete;
         ddrc_reg_dfi_lp_ctrl_ack_stat_cclk <= ddrc_reg_dfi_lp_ctrl_ack_stat;
         ddrc_reg_dfi_lp_data_ack_stat_cclk <= ddrc_reg_dfi_lp_data_ack_stat;
         ddrc_reg_dfi0_ctrlmsg_req_busy_cclk <= ddrc_reg_dfi0_ctrlmsg_req_busy;
         ddrc_reg_dfi0_ctrlmsg_resp_tout_cclk <= ddrc_reg_dfi0_ctrlmsg_resp_tout;
         ddrc_reg_dbg_stall_cclk <= ddrc_reg_dbg_stall;
         ddrc_reg_dbg_rd_q_empty_cclk <= ddrc_reg_dbg_rd_q_empty;
         ddrc_reg_dbg_wr_q_empty_cclk <= ddrc_reg_dbg_wr_q_empty;
         ddrc_reg_rd_data_pipeline_empty_cclk <= ddrc_reg_rd_data_pipeline_empty;
         ddrc_reg_wr_data_pipeline_empty_cclk <= ddrc_reg_wr_data_pipeline_empty;

      end   
   end

   //-------------------------------------------------
   // Clock domain crossing: DYNAMIC registers
   //-------------------------------------------------   
   // Datasync CDC for register REGB_DDRC_CH0 mstr0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_mstr0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[0] & write_en) | fwd_reset_val),
       .s_data          (s_data_r0_mstr0),
       .d_data          (d_data_r0_mstr0),
       .s_ack           (r0_mstr0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 mstr0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_mstr0_arba0_p2a
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (aclk_0),
       .d_rst_n         (sync_aresetn_0),
       .s_send          ((rwselect[0] & write_en) | fwd_reset_val),
       .s_data          (s_data_arba0_r0_mstr0),
       .d_data          (d_data_arba0_r0_mstr0),
       .s_ack           (r0_mstr0_ack_arba0_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 mstr4
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_mstr4_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[4] & write_en) | fwd_reset_val),
       .s_data          (s_data_r4_mstr4),
       .d_data          (d_data_r4_mstr4),
       .s_ack           (r4_mstr4_ack_pclk));
   wire s_ack_regb_ddrc_ch0_stat_unconnected;
   // Datasync CDC for register REGB_DDRC_CH0 stat
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_regb_ddrc_ch0_stat_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (r5_stat_cclk),
       .s_send          (1'b0),
       .d_data          (r5_stat),
       .s_ack           (s_ack_regb_ddrc_ch0_stat_unconnected));





   // Pulse synch for field reg_ddrc_mrr_done_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_mrr_done_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_mrr_done_clr_pclk),
       .ack_s           (reg_ddrc_mrr_done_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_mrr_done_clr));
   reg reg_ddrc_mrr_done_clr_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_mrr_done_clr_PROC
      if (~apb_rst) begin
         reg_ddrc_mrr_done_clr_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_mrr_done_clr_pclk_r <= reg_ddrc_mrr_done_clr_pclk;
      end
   end
   reg wait_reg_ddrc_mrr_done_clr_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_mrr_done_clr_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_mrr_done_clr_ack <= 1'b0;
      else if (reg_ddrc_mrr_done_clr_pclk & (!reg_ddrc_mrr_done_clr_pclk_r))
         wait_reg_ddrc_mrr_done_clr_ack <= 1'b1;
      else if (reg_ddrc_mrr_done_clr_ack_pclk)
         wait_reg_ddrc_mrr_done_clr_ack <= 1'b0;
   end

   // Pulse synch for field reg_ddrc_mr_wr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_mr_wr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_mr_wr_pclk),
       .ack_s           (reg_ddrc_mr_wr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_mr_wr));

   reg reg_ddrc_mr_wr_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_mr_wr_PROC
      if (~apb_rst) begin
         reg_ddrc_mr_wr_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_mr_wr_pclk_r <= reg_ddrc_mr_wr_pclk;
      end
   end

   reg ff_regb_ddrc_ch0_mr_wr_saved_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : ff_regb_ddrc_ch0_mr_wr_saved_s0_PROC
      if (~apb_rst)
         ff_regb_ddrc_ch0_mr_wr_saved_s0 <= 1'b0;
      else
         ff_regb_ddrc_ch0_mr_wr_saved_s0 <= ff_regb_ddrc_ch0_mr_wr_saved;
   end

   reg [6:0] wait_reg_ddrc_mr_wr_ack_timeout;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_mr_wr_wait_ack_timeout_PROC
      if (~apb_rst)
         wait_reg_ddrc_mr_wr_ack_timeout <= 7'd0;
      else if ((reg_ddrc_mr_wr_pclk && (~reg_ddrc_mr_wr_pclk_r)) || (ff_regb_ddrc_ch0_mr_wr_saved && (~ff_regb_ddrc_ch0_mr_wr_saved_s0)))
         wait_reg_ddrc_mr_wr_ack_timeout <= WAIT_ACK_TIMEOUT;
      else if (wait_reg_ddrc_mr_wr_ack_timeout > 7'd0)
         wait_reg_ddrc_mr_wr_ack_timeout <= wait_reg_ddrc_mr_wr_ack_timeout - 7'd1;
   end

   reg wait_reg_ddrc_mr_wr_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_mr_wr_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_mr_wr_ack <= 1'b0;
      else if ((reg_ddrc_mr_wr_pclk && (~reg_ddrc_mr_wr_pclk_r)) || (ff_regb_ddrc_ch0_mr_wr_saved && (~ff_regb_ddrc_ch0_mr_wr_saved_s0)))
         wait_reg_ddrc_mr_wr_ack <= 1'b1;
      else if (reg_ddrc_mr_wr_ack_pclk || (wait_reg_ddrc_mr_wr_ack_timeout == 7'd0))
         wait_reg_ddrc_mr_wr_ack <= 1'b0;
   end
   wire r8_mrctrl0_ack_pclk_datasync;
   // Datasync CDC for register REGB_DDRC_CH0 mrctrl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_mrctrl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[5] & write_en) | fwd_reset_val),
       .s_data          (s_data_r8_mrctrl0),
       .d_data          (d_data_r8_mrctrl0),
       .s_ack           (r8_mrctrl0_ack_pclk_datasync));

   reg wait_r8_mrctrl0_datasync_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : r8_mrctrl0_wait_ack_PROC
      if (~apb_rst)
         wait_r8_mrctrl0_datasync_ack <= 1'b0;
      else if ((rwselect[5] & write_en) | fwd_reset_val)
         wait_r8_mrctrl0_datasync_ack <= 1'b1;
      else if (r8_mrctrl0_ack_pclk_datasync)
         wait_r8_mrctrl0_datasync_ack <= 1'b0;
   end

   wire wait_r8_mrctrl0_combined_ack;
   assign wait_r8_mrctrl0_combined_ack = wait_r8_mrctrl0_datasync_ack
                               | wait_reg_ddrc_mr_wr_ack
                               | wait_reg_ddrc_mrr_done_clr_ack
                               ;

   reg wait_r8_mrctrl0_combined_ack_r;
   always @(posedge apb_clk or negedge apb_rst) begin : r8_mrctrl0_wait_combined_ack_PROC
      if (~apb_rst)
         wait_r8_mrctrl0_combined_ack_r <= 1'b0;
      else if ((rwselect[5] & write_en) | fwd_reset_val)
         wait_r8_mrctrl0_combined_ack_r <= 1'b1;
      else if (~wait_r8_mrctrl0_combined_ack)
         wait_r8_mrctrl0_combined_ack_r <= 1'b0;
   end

   reg r8_mrctrl0_ack_pclk_combined;
   always @(posedge apb_clk or negedge apb_rst) begin : r8_mrctrl0_ack_pclk_PROC
      if (~apb_rst)
         r8_mrctrl0_ack_pclk_combined <= 1'b0;
      else if (~wait_r8_mrctrl0_combined_ack && wait_r8_mrctrl0_combined_ack_r)
         r8_mrctrl0_ack_pclk_combined <= 1'b1;
      else
         r8_mrctrl0_ack_pclk_combined <= 1'b0;
   end

   assign r8_mrctrl0_ack_pclk = r8_mrctrl0_ack_pclk_combined;
   // Datasync CDC for register REGB_DDRC_CH0 mrctrl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_mrctrl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[6] & write_en) | fwd_reset_val),
       .s_data          (s_data_r9_mrctrl1),
       .d_data          (d_data_r9_mrctrl1),
       .s_ack           (r9_mrctrl1_ack_pclk));

   // Single bit CDC for field ddrc_reg_mr_wr_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_mr_wr_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_mr_wr_busy_cclk),
       .data_d          (ddrc_reg_mr_wr_busy_pclk));

   wire ack_s_ddrc_reg_mr_wr_busy_unconnected;
   // Pulse synch for field ddrc_reg_mr_wr_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_mr_wr_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_mr_wr_busy_cclk),
       .ack_s           (ack_s_ddrc_reg_mr_wr_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_mr_wr_busy_pulse_pclk));


   // Single bit CDC for field ddrc_reg_mrr_done
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_mrr_done_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_mrr_done_cclk),
       .data_d          (ddrc_reg_mrr_done_pclk));


   wire s_ack_ddrc_reg_mrr_data_lwr_unconnected;
   // Datasync CDC for field ddrc_reg_mrr_data_lwr
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_MRRDATA0_MRR_DATA_LWR),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_mrr_data_lwr_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_mrr_data_lwr_cclk),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_mrr_data_lwr_pclk),
       .s_ack           (s_ack_ddrc_reg_mrr_data_lwr_unconnected));

   wire s_ack_ddrc_reg_mrr_data_upr_unconnected;
   // Datasync CDC for field ddrc_reg_mrr_data_upr
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_MRRDATA1_MRR_DATA_UPR),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_mrr_data_upr_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_mrr_data_upr_cclk),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_mrr_data_upr_pclk),
       .s_ack           (s_ack_ddrc_reg_mrr_data_upr_unconnected));
   // Datasync CDC for register REGB_DDRC_CH0 deratectl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_deratectl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[8] & write_en) | fwd_reset_val),
       .s_data          (s_data_r14_deratectl0),
       .d_data          (d_data_r14_deratectl0),
       .s_ack           (r14_deratectl0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 deratectl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_deratectl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[9] & write_en) | fwd_reset_val),
       .s_data          (s_data_r15_deratectl1),
       .d_data          (d_data_r15_deratectl1),
       .s_ack           (r15_deratectl1_ack_pclk));




   // Datasync CDC for register REGB_DDRC_CH0 deratedbgctl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_deratedbgctl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[15] & write_en) | fwd_reset_val),
       .s_data          (s_data_r23_deratedbgctl),
       .d_data          (d_data_r23_deratedbgctl),
       .s_ack           (r23_deratedbgctl_ack_pclk));

   wire s_ack_ddrc_reg_dbg_mr4_byte0_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_mr4_byte0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE0),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_mr4_byte0_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_mr4_byte0),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_mr4_byte0_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_mr4_byte0_unconnected));

   wire s_ack_ddrc_reg_dbg_mr4_byte1_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_mr4_byte1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE1),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_mr4_byte1_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_mr4_byte1),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_mr4_byte1_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_mr4_byte1_unconnected));

   wire s_ack_ddrc_reg_dbg_mr4_byte2_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_mr4_byte2
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE2),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_mr4_byte2_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_mr4_byte2),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_mr4_byte2_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_mr4_byte2_unconnected));

   wire s_ack_ddrc_reg_dbg_mr4_byte3_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_mr4_byte3
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_DERATEDBGSTAT_DBG_MR4_BYTE3),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_mr4_byte3_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_mr4_byte3),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_mr4_byte3_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_mr4_byte3_unconnected));
   // Datasync CDC for register REGB_DDRC_CH0 pwrctl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_pwrctl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[16] & write_en) | fwd_reset_val),
       .s_data          (s_data_r25_pwrctl),
       .d_data          (d_data_r25_pwrctl),
       .s_ack           (r25_pwrctl_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 clkgatectl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_clkgatectl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[19] & write_en) | fwd_reset_val),
       .s_data          (s_data_r28_clkgatectl),
       .d_data          (d_data_r28_clkgatectl),
       .s_ack           (r28_clkgatectl_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 rfshmod0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_rfshmod0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[20] & write_en) | fwd_reset_val),
       .s_data          (s_data_r29_rfshmod0),
       .d_data          (d_data_r29_rfshmod0),
       .s_ack           (r29_rfshmod0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 rfshctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_rfshctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[22] & write_en) | fwd_reset_val),
       .s_data          (s_data_r31_rfshctl0),
       .d_data          (d_data_r31_rfshctl0),
       .s_ack           (r31_rfshctl0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 zqctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_zqctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[25] & write_en) | fwd_reset_val),
       .s_data          (s_data_r34_zqctl0),
       .d_data          (d_data_r34_zqctl0),
       .s_ack           (r34_zqctl0_ack_pclk));

   // Pulse synch for field reg_ddrc_zq_reset
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_zq_reset_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_zq_reset_pclk),
       .ack_s           (reg_ddrc_zq_reset_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_zq_reset));

   reg reg_ddrc_zq_reset_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_zq_reset_PROC
      if (~apb_rst) begin
         reg_ddrc_zq_reset_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_zq_reset_pclk_r <= reg_ddrc_zq_reset_pclk;
      end
   end

   reg ff_regb_ddrc_ch0_zq_reset_saved_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : ff_regb_ddrc_ch0_zq_reset_saved_s0_PROC
      if (~apb_rst)
         ff_regb_ddrc_ch0_zq_reset_saved_s0 <= 1'b0;
      else
         ff_regb_ddrc_ch0_zq_reset_saved_s0 <= ff_regb_ddrc_ch0_zq_reset_saved;
   end

   reg [6:0] wait_reg_ddrc_zq_reset_ack_timeout;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_zq_reset_wait_ack_timeout_PROC
      if (~apb_rst)
         wait_reg_ddrc_zq_reset_ack_timeout <= 7'd0;
      else if ((reg_ddrc_zq_reset_pclk && (~reg_ddrc_zq_reset_pclk_r)) || (ff_regb_ddrc_ch0_zq_reset_saved && (~ff_regb_ddrc_ch0_zq_reset_saved_s0)))
         wait_reg_ddrc_zq_reset_ack_timeout <= WAIT_ACK_TIMEOUT;
      else if (wait_reg_ddrc_zq_reset_ack_timeout > 7'd0)
         wait_reg_ddrc_zq_reset_ack_timeout <= wait_reg_ddrc_zq_reset_ack_timeout - 7'd1;
   end

   reg wait_reg_ddrc_zq_reset_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_zq_reset_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_zq_reset_ack <= 1'b0;
      else if ((reg_ddrc_zq_reset_pclk && (~reg_ddrc_zq_reset_pclk_r)) || (ff_regb_ddrc_ch0_zq_reset_saved && (~ff_regb_ddrc_ch0_zq_reset_saved_s0)))
         wait_reg_ddrc_zq_reset_ack <= 1'b1;
      else if (reg_ddrc_zq_reset_ack_pclk || (wait_reg_ddrc_zq_reset_ack_timeout == 7'd0))
         wait_reg_ddrc_zq_reset_ack <= 1'b0;
   end
   wire r35_zqctl1_ack_pclk_datasync;
   // Datasync CDC for register REGB_DDRC_CH0 zqctl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_zqctl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[26] & write_en) | fwd_reset_val),
       .s_data          (s_data_r35_zqctl1),
       .d_data          (d_data_r35_zqctl1),
       .s_ack           (r35_zqctl1_ack_pclk_datasync));

   reg wait_r35_zqctl1_datasync_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : r35_zqctl1_wait_ack_PROC
      if (~apb_rst)
         wait_r35_zqctl1_datasync_ack <= 1'b0;
      else if ((rwselect[26] & write_en) | fwd_reset_val)
         wait_r35_zqctl1_datasync_ack <= 1'b1;
      else if (r35_zqctl1_ack_pclk_datasync)
         wait_r35_zqctl1_datasync_ack <= 1'b0;
   end

   wire wait_r35_zqctl1_combined_ack;
   assign wait_r35_zqctl1_combined_ack = wait_r35_zqctl1_datasync_ack
                               | wait_reg_ddrc_zq_reset_ack
                               ;

   reg wait_r35_zqctl1_combined_ack_r;
   always @(posedge apb_clk or negedge apb_rst) begin : r35_zqctl1_wait_combined_ack_PROC
      if (~apb_rst)
         wait_r35_zqctl1_combined_ack_r <= 1'b0;
      else if ((rwselect[26] & write_en) | fwd_reset_val)
         wait_r35_zqctl1_combined_ack_r <= 1'b1;
      else if (~wait_r35_zqctl1_combined_ack)
         wait_r35_zqctl1_combined_ack_r <= 1'b0;
   end

   reg r35_zqctl1_ack_pclk_combined;
   always @(posedge apb_clk or negedge apb_rst) begin : r35_zqctl1_ack_pclk_PROC
      if (~apb_rst)
         r35_zqctl1_ack_pclk_combined <= 1'b0;
      else if (~wait_r35_zqctl1_combined_ack && wait_r35_zqctl1_combined_ack_r)
         r35_zqctl1_ack_pclk_combined <= 1'b1;
      else
         r35_zqctl1_ack_pclk_combined <= 1'b0;
   end

   assign r35_zqctl1_ack_pclk = r35_zqctl1_ack_pclk_combined;

   // Single bit CDC for field ddrc_reg_zq_reset_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_zq_reset_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_zq_reset_busy),
       .data_d          (ddrc_reg_zq_reset_busy_pclk));

   wire ack_s_ddrc_reg_zq_reset_busy_unconnected;
   // Pulse synch for field ddrc_reg_zq_reset_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_zq_reset_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_zq_reset_busy),
       .ack_s           (ack_s_ddrc_reg_zq_reset_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_zq_reset_busy_pulse_pclk));
   wire s_ack_regb_ddrc_ch0_dqsoscstat0_unconnected;
   // Datasync CDC for register REGB_DDRC_CH0 dqsoscstat0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_regb_ddrc_ch0_dqsoscstat0_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (r39_dqsoscstat0_cclk),
       .s_send          (1'b0),
       .d_data          (r39_dqsoscstat0),
       .s_ack           (s_ack_regb_ddrc_ch0_dqsoscstat0_unconnected));







   // Datasync CDC for register REGB_DDRC_CH0 dfilpcfg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_dfilpcfg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[44] & write_en) | fwd_reset_val),
       .s_data          (s_data_r56_dfilpcfg0),
       .d_data          (d_data_r56_dfilpcfg0),
       .s_ack           (r56_dfilpcfg0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 dfiupd0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_dfiupd0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[45] & write_en) | fwd_reset_val),
       .s_data          (s_data_r57_dfiupd0),
       .d_data          (d_data_r57_dfiupd0),
       .s_ack           (r57_dfiupd0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 dfimisc
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_dfimisc_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[47] & write_en) | fwd_reset_val),
       .s_data          (s_data_r59_dfimisc),
       .d_data          (d_data_r59_dfimisc),
       .s_ack           (r59_dfimisc_ack_pclk));

   // Single bit CDC for field ddrc_reg_dfi_init_complete
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi_init_complete_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi_init_complete_cclk),
       .data_d          (ddrc_reg_dfi_init_complete_pclk));

   // Single bit CDC for field ddrc_reg_dfi_lp_ctrl_ack_stat
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi_lp_ctrl_ack_stat_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi_lp_ctrl_ack_stat_cclk),
       .data_d          (ddrc_reg_dfi_lp_ctrl_ack_stat_pclk));

   // Single bit CDC for field ddrc_reg_dfi_lp_data_ack_stat
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi_lp_data_ack_stat_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi_lp_data_ack_stat_cclk),
       .data_d          (ddrc_reg_dfi_lp_data_ack_stat_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 dfiphymstr
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_dfiphymstr_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[48] & write_en) | fwd_reset_val),
       .s_data          (s_data_r61_dfiphymstr),
       .d_data          (d_data_r61_dfiphymstr),
       .s_ack           (r61_dfiphymstr_ack_pclk));

   // Pulse synch for field reg_ddrc_dfi0_ctrlmsg_tout_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_dfi0_ctrlmsg_tout_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk),
       .ack_s           (reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_dfi0_ctrlmsg_tout_clr));
   reg reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_dfi0_ctrlmsg_tout_clr_PROC
      if (~apb_rst) begin
         reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk_r <= reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk;
      end
   end
   reg wait_reg_ddrc_dfi0_ctrlmsg_tout_clr_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_dfi0_ctrlmsg_tout_clr_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_dfi0_ctrlmsg_tout_clr_ack <= 1'b0;
      else if (reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk & (!reg_ddrc_dfi0_ctrlmsg_tout_clr_pclk_r))
         wait_reg_ddrc_dfi0_ctrlmsg_tout_clr_ack <= 1'b1;
      else if (reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk)
         wait_reg_ddrc_dfi0_ctrlmsg_tout_clr_ack <= 1'b0;
   end

   // Pulse synch for field reg_ddrc_dfi0_ctrlmsg_req
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_dfi0_ctrlmsg_req_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_dfi0_ctrlmsg_req_pclk),
       .ack_s           (reg_ddrc_dfi0_ctrlmsg_req_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_dfi0_ctrlmsg_req));

   reg reg_ddrc_dfi0_ctrlmsg_req_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_dfi0_ctrlmsg_req_PROC
      if (~apb_rst) begin
         reg_ddrc_dfi0_ctrlmsg_req_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_dfi0_ctrlmsg_req_pclk_r <= reg_ddrc_dfi0_ctrlmsg_req_pclk;
      end
   end

   reg ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved_s0_PROC
      if (~apb_rst)
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved_s0 <= 1'b0;
      else
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved_s0 <= ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved;
   end

   reg [6:0] wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_dfi0_ctrlmsg_req_wait_ack_timeout_PROC
      if (~apb_rst)
         wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout <= 7'd0;
      else if ((reg_ddrc_dfi0_ctrlmsg_req_pclk && (~reg_ddrc_dfi0_ctrlmsg_req_pclk_r)) || (ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved && (~ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved_s0)))
         wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout <= WAIT_ACK_TIMEOUT;
      else if (wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout > 7'd0)
         wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout <= wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout - 7'd1;
   end

   reg wait_reg_ddrc_dfi0_ctrlmsg_req_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_dfi0_ctrlmsg_req_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_dfi0_ctrlmsg_req_ack <= 1'b0;
      else if ((reg_ddrc_dfi0_ctrlmsg_req_pclk && (~reg_ddrc_dfi0_ctrlmsg_req_pclk_r)) || (ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved && (~ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved_s0)))
         wait_reg_ddrc_dfi0_ctrlmsg_req_ack <= 1'b1;
      else if (reg_ddrc_dfi0_ctrlmsg_req_ack_pclk || (wait_reg_ddrc_dfi0_ctrlmsg_req_ack_timeout == 7'd0))
         wait_reg_ddrc_dfi0_ctrlmsg_req_ack <= 1'b0;
   end
   wire r62_dfi0msgctl0_ack_pclk_datasync;
   // Datasync CDC for register REGB_DDRC_CH0 dfi0msgctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_dfi0msgctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[49] & write_en) | fwd_reset_val),
       .s_data          (s_data_r62_dfi0msgctl0),
       .d_data          (d_data_r62_dfi0msgctl0),
       .s_ack           (r62_dfi0msgctl0_ack_pclk_datasync));

   reg wait_r62_dfi0msgctl0_datasync_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : r62_dfi0msgctl0_wait_ack_PROC
      if (~apb_rst)
         wait_r62_dfi0msgctl0_datasync_ack <= 1'b0;
      else if ((rwselect[49] & write_en) | fwd_reset_val)
         wait_r62_dfi0msgctl0_datasync_ack <= 1'b1;
      else if (r62_dfi0msgctl0_ack_pclk_datasync)
         wait_r62_dfi0msgctl0_datasync_ack <= 1'b0;
   end

   wire wait_r62_dfi0msgctl0_combined_ack;
   assign wait_r62_dfi0msgctl0_combined_ack = wait_r62_dfi0msgctl0_datasync_ack
                               | wait_reg_ddrc_dfi0_ctrlmsg_tout_clr_ack
                               | wait_reg_ddrc_dfi0_ctrlmsg_req_ack
                               ;

   reg wait_r62_dfi0msgctl0_combined_ack_r;
   always @(posedge apb_clk or negedge apb_rst) begin : r62_dfi0msgctl0_wait_combined_ack_PROC
      if (~apb_rst)
         wait_r62_dfi0msgctl0_combined_ack_r <= 1'b0;
      else if ((rwselect[49] & write_en) | fwd_reset_val)
         wait_r62_dfi0msgctl0_combined_ack_r <= 1'b1;
      else if (~wait_r62_dfi0msgctl0_combined_ack)
         wait_r62_dfi0msgctl0_combined_ack_r <= 1'b0;
   end

   reg r62_dfi0msgctl0_ack_pclk_combined;
   always @(posedge apb_clk or negedge apb_rst) begin : r62_dfi0msgctl0_ack_pclk_PROC
      if (~apb_rst)
         r62_dfi0msgctl0_ack_pclk_combined <= 1'b0;
      else if (~wait_r62_dfi0msgctl0_combined_ack && wait_r62_dfi0msgctl0_combined_ack_r)
         r62_dfi0msgctl0_ack_pclk_combined <= 1'b1;
      else
         r62_dfi0msgctl0_ack_pclk_combined <= 1'b0;
   end

   assign r62_dfi0msgctl0_ack_pclk = r62_dfi0msgctl0_ack_pclk_combined;

   // Single bit CDC for field ddrc_reg_dfi0_ctrlmsg_req_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi0_ctrlmsg_req_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi0_ctrlmsg_req_busy_cclk),
       .data_d          (ddrc_reg_dfi0_ctrlmsg_req_busy_pclk));

   wire ack_s_ddrc_reg_dfi0_ctrlmsg_req_busy_unconnected;
   // Pulse synch for field ddrc_reg_dfi0_ctrlmsg_req_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_dfi0_ctrlmsg_req_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_dfi0_ctrlmsg_req_busy_cclk),
       .ack_s           (ack_s_ddrc_reg_dfi0_ctrlmsg_req_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_dfi0_ctrlmsg_req_busy_pulse_pclk));

   // Single bit CDC for field ddrc_reg_dfi0_ctrlmsg_resp_tout
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dfi0_ctrlmsg_resp_tout_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dfi0_ctrlmsg_resp_tout_cclk),
       .data_d          (ddrc_reg_dfi0_ctrlmsg_resp_tout_pclk));

   // Pulse synch for field reg_ddrc_wr_poison_intr_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_wr_poison_intr_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_wr_poison_intr_clr_pclk),
       .ack_s           (reg_ddrc_wr_poison_intr_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_wr_poison_intr_clr));
   reg reg_ddrc_wr_poison_intr_clr_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_wr_poison_intr_clr_PROC
      if (~apb_rst) begin
         reg_ddrc_wr_poison_intr_clr_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_wr_poison_intr_clr_pclk_r <= reg_ddrc_wr_poison_intr_clr_pclk;
      end
   end
   reg wait_reg_ddrc_wr_poison_intr_clr_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_wr_poison_intr_clr_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_wr_poison_intr_clr_ack <= 1'b0;
      else if (reg_ddrc_wr_poison_intr_clr_pclk & (!reg_ddrc_wr_poison_intr_clr_pclk_r))
         wait_reg_ddrc_wr_poison_intr_clr_ack <= 1'b1;
      else if (reg_ddrc_wr_poison_intr_clr_ack_pclk)
         wait_reg_ddrc_wr_poison_intr_clr_ack <= 1'b0;
   end

   // Pulse synch for field reg_ddrc_rd_poison_intr_clr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoclear_reg_ddrc_rd_poison_intr_clr_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_rd_poison_intr_clr_pclk),
       .ack_s           (reg_ddrc_rd_poison_intr_clr_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_rd_poison_intr_clr));
   reg reg_ddrc_rd_poison_intr_clr_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_rd_poison_intr_clr_PROC
      if (~apb_rst) begin
         reg_ddrc_rd_poison_intr_clr_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_rd_poison_intr_clr_pclk_r <= reg_ddrc_rd_poison_intr_clr_pclk;
      end
   end
   reg wait_reg_ddrc_rd_poison_intr_clr_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_rd_poison_intr_clr_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_rd_poison_intr_clr_ack <= 1'b0;
      else if (reg_ddrc_rd_poison_intr_clr_pclk & (!reg_ddrc_rd_poison_intr_clr_pclk_r))
         wait_reg_ddrc_rd_poison_intr_clr_ack <= 1'b1;
      else if (reg_ddrc_rd_poison_intr_clr_ack_pclk)
         wait_reg_ddrc_rd_poison_intr_clr_ack <= 1'b0;
   end
   wire r64_poisoncfg_ack_pclk_datasync;
   // Datasync CDC for register REGB_DDRC_CH0 poisoncfg
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_poisoncfg_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[50] & write_en) | fwd_reset_val),
       .s_data          (s_data_r64_poisoncfg),
       .d_data          (d_data_r64_poisoncfg),
       .s_ack           (r64_poisoncfg_ack_pclk_datasync));

   reg wait_r64_poisoncfg_datasync_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : r64_poisoncfg_wait_ack_PROC
      if (~apb_rst)
         wait_r64_poisoncfg_datasync_ack <= 1'b0;
      else if ((rwselect[50] & write_en) | fwd_reset_val)
         wait_r64_poisoncfg_datasync_ack <= 1'b1;
      else if (r64_poisoncfg_ack_pclk_datasync)
         wait_r64_poisoncfg_datasync_ack <= 1'b0;
   end

   wire wait_r64_poisoncfg_combined_ack;
   assign wait_r64_poisoncfg_combined_ack = wait_r64_poisoncfg_datasync_ack
                               | wait_reg_ddrc_rd_poison_intr_clr_ack
                               | wait_reg_ddrc_wr_poison_intr_clr_ack
                               ;

   reg wait_r64_poisoncfg_combined_ack_r;
   always @(posedge apb_clk or negedge apb_rst) begin : r64_poisoncfg_wait_combined_ack_PROC
      if (~apb_rst)
         wait_r64_poisoncfg_combined_ack_r <= 1'b0;
      else if ((rwselect[50] & write_en) | fwd_reset_val)
         wait_r64_poisoncfg_combined_ack_r <= 1'b1;
      else if (~wait_r64_poisoncfg_combined_ack)
         wait_r64_poisoncfg_combined_ack_r <= 1'b0;
   end

   reg r64_poisoncfg_ack_pclk_combined;
   always @(posedge apb_clk or negedge apb_rst) begin : r64_poisoncfg_ack_pclk_PROC
      if (~apb_rst)
         r64_poisoncfg_ack_pclk_combined <= 1'b0;
      else if (~wait_r64_poisoncfg_combined_ack && wait_r64_poisoncfg_combined_ack_r)
         r64_poisoncfg_ack_pclk_combined <= 1'b1;
      else
         r64_poisoncfg_ack_pclk_combined <= 1'b0;
   end

   assign r64_poisoncfg_ack_pclk = r64_poisoncfg_ack_pclk_combined;

   // Single bit CDC for field ddrc_reg_wr_poison_intr_0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_wr_poison_intr_0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_wr_poison_intr_0),
       .data_d          (ddrc_reg_wr_poison_intr_0_pclk));
















   // Single bit CDC for field ddrc_reg_rd_poison_intr_0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rd_poison_intr_0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rd_poison_intr_0),
       .data_d          (ddrc_reg_rd_poison_intr_0_pclk));




















































































































































































































   // Datasync CDC for register REGB_DDRC_CH0 opctrl1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_opctrl1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[123] & write_en) | fwd_reset_val),
       .s_data          (s_data_r216_opctrl1),
       .d_data          (d_data_r216_opctrl1),
       .s_ack           (r216_opctrl1_ack_pclk));

   wire s_ack_ddrc_reg_dbg_hpr_q_depth_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_hpr_q_depth
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_HPR_Q_DEPTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_hpr_q_depth_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_hpr_q_depth),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_hpr_q_depth_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_hpr_q_depth_unconnected));

   wire s_ack_ddrc_reg_dbg_lpr_q_depth_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_lpr_q_depth
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_LPR_Q_DEPTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_lpr_q_depth_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_lpr_q_depth),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_lpr_q_depth_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_lpr_q_depth_unconnected));

   wire s_ack_ddrc_reg_dbg_w_q_depth_unconnected;
   // Datasync CDC for field ddrc_reg_dbg_w_q_depth
   DWC_ddr_umctl2_datasync
   
     #(.DW              (`REGB_DDRC_CH0_SIZE_OPCTRLCAM_DBG_W_Q_DEPTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P), 
       .BCM_VERIF_EN    (BCM_VERIF_EN), 
       .REG_OUTPUTS     (REG_OUTPUTS_C2P),
       .DETECT_CHANGE   (1'b1))
   U_datasync_ddrc_reg_dbg_w_q_depth_c2p
      (.s_clk           (core_ddrc_core_clk),
       .s_rst_n         (core_ddrc_rstn),
       .d_clk           (apb_clk),
       .d_rst_n         (apb_rst),
       .s_data          (ddrc_reg_dbg_w_q_depth),
       .s_send          (1'b0),
       .d_data          (ddrc_reg_dbg_w_q_depth_pclk),
       .s_ack           (s_ack_ddrc_reg_dbg_w_q_depth_unconnected));

   // Single bit CDC for field ddrc_reg_dbg_stall
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_stall_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_stall_cclk),
       .data_d          (ddrc_reg_dbg_stall_pclk));

   // Single bit CDC for field ddrc_reg_dbg_rd_q_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_rd_q_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_rd_q_empty_cclk),
       .data_d          (ddrc_reg_dbg_rd_q_empty_pclk));

   // Single bit CDC for field ddrc_reg_dbg_wr_q_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_dbg_wr_q_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_dbg_wr_q_empty_cclk),
       .data_d          (ddrc_reg_dbg_wr_q_empty_pclk));

   // Single bit CDC for field ddrc_reg_rd_data_pipeline_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rd_data_pipeline_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rd_data_pipeline_empty_cclk),
       .data_d          (ddrc_reg_rd_data_pipeline_empty_pclk));

   // Single bit CDC for field ddrc_reg_wr_data_pipeline_empty
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_wr_data_pipeline_empty_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_wr_data_pipeline_empty_cclk),
       .data_d          (ddrc_reg_wr_data_pipeline_empty_pclk));



   // Pulse synch for field reg_ddrc_zq_calib_short
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_zq_calib_short_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_zq_calib_short_pclk),
       .ack_s           (reg_ddrc_zq_calib_short_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_zq_calib_short));

   reg reg_ddrc_zq_calib_short_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_zq_calib_short_PROC
      if (~apb_rst) begin
         reg_ddrc_zq_calib_short_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_zq_calib_short_pclk_r <= reg_ddrc_zq_calib_short_pclk;
      end
   end

   reg ff_regb_ddrc_ch0_zq_calib_short_saved_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : ff_regb_ddrc_ch0_zq_calib_short_saved_s0_PROC
      if (~apb_rst)
         ff_regb_ddrc_ch0_zq_calib_short_saved_s0 <= 1'b0;
      else
         ff_regb_ddrc_ch0_zq_calib_short_saved_s0 <= ff_regb_ddrc_ch0_zq_calib_short_saved;
   end

   reg [6:0] wait_reg_ddrc_zq_calib_short_ack_timeout;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_zq_calib_short_wait_ack_timeout_PROC
      if (~apb_rst)
         wait_reg_ddrc_zq_calib_short_ack_timeout <= 7'd0;
      else if ((reg_ddrc_zq_calib_short_pclk && (~reg_ddrc_zq_calib_short_pclk_r)) || (ff_regb_ddrc_ch0_zq_calib_short_saved && (~ff_regb_ddrc_ch0_zq_calib_short_saved_s0)))
         wait_reg_ddrc_zq_calib_short_ack_timeout <= WAIT_ACK_TIMEOUT;
      else if (wait_reg_ddrc_zq_calib_short_ack_timeout > 7'd0)
         wait_reg_ddrc_zq_calib_short_ack_timeout <= wait_reg_ddrc_zq_calib_short_ack_timeout - 7'd1;
   end

   reg wait_reg_ddrc_zq_calib_short_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_zq_calib_short_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_zq_calib_short_ack <= 1'b0;
      else if ((reg_ddrc_zq_calib_short_pclk && (~reg_ddrc_zq_calib_short_pclk_r)) || (ff_regb_ddrc_ch0_zq_calib_short_saved && (~ff_regb_ddrc_ch0_zq_calib_short_saved_s0)))
         wait_reg_ddrc_zq_calib_short_ack <= 1'b1;
      else if (reg_ddrc_zq_calib_short_ack_pclk || (wait_reg_ddrc_zq_calib_short_ack_timeout == 7'd0))
         wait_reg_ddrc_zq_calib_short_ack <= 1'b0;
   end

   // Pulse synch for field reg_ddrc_ctrlupd
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_ctrlupd_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_ctrlupd_pclk),
       .ack_s           (reg_ddrc_ctrlupd_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_ctrlupd));

   reg reg_ddrc_ctrlupd_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_ctrlupd_PROC
      if (~apb_rst) begin
         reg_ddrc_ctrlupd_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_ctrlupd_pclk_r <= reg_ddrc_ctrlupd_pclk;
      end
   end

   reg ff_regb_ddrc_ch0_ctrlupd_saved_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : ff_regb_ddrc_ch0_ctrlupd_saved_s0_PROC
      if (~apb_rst)
         ff_regb_ddrc_ch0_ctrlupd_saved_s0 <= 1'b0;
      else
         ff_regb_ddrc_ch0_ctrlupd_saved_s0 <= ff_regb_ddrc_ch0_ctrlupd_saved;
   end

   reg [6:0] wait_reg_ddrc_ctrlupd_ack_timeout;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_ctrlupd_wait_ack_timeout_PROC
      if (~apb_rst)
         wait_reg_ddrc_ctrlupd_ack_timeout <= 7'd0;
      else if ((reg_ddrc_ctrlupd_pclk && (~reg_ddrc_ctrlupd_pclk_r)) || (ff_regb_ddrc_ch0_ctrlupd_saved && (~ff_regb_ddrc_ch0_ctrlupd_saved_s0)))
         wait_reg_ddrc_ctrlupd_ack_timeout <= WAIT_ACK_TIMEOUT;
      else if (wait_reg_ddrc_ctrlupd_ack_timeout > 7'd0)
         wait_reg_ddrc_ctrlupd_ack_timeout <= wait_reg_ddrc_ctrlupd_ack_timeout - 7'd1;
   end

   reg wait_reg_ddrc_ctrlupd_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_ctrlupd_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_ctrlupd_ack <= 1'b0;
      else if ((reg_ddrc_ctrlupd_pclk && (~reg_ddrc_ctrlupd_pclk_r)) || (ff_regb_ddrc_ch0_ctrlupd_saved && (~ff_regb_ddrc_ch0_ctrlupd_saved_s0)))
         wait_reg_ddrc_ctrlupd_ack <= 1'b1;
      else if (reg_ddrc_ctrlupd_ack_pclk || (wait_reg_ddrc_ctrlupd_ack_timeout == 7'd0))
         wait_reg_ddrc_ctrlupd_ack <= 1'b0;
   end
   wire r218_opctrlcmd_ack_pclk_datasync;
   // Datasync CDC for register REGB_DDRC_CH0 opctrlcmd
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_opctrlcmd_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[124] & write_en) | fwd_reset_val),
       .s_data          (s_data_r218_opctrlcmd),
       .d_data          (d_data_r218_opctrlcmd),
       .s_ack           (r218_opctrlcmd_ack_pclk_datasync));

   reg wait_r218_opctrlcmd_datasync_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : r218_opctrlcmd_wait_ack_PROC
      if (~apb_rst)
         wait_r218_opctrlcmd_datasync_ack <= 1'b0;
      else if ((rwselect[124] & write_en) | fwd_reset_val)
         wait_r218_opctrlcmd_datasync_ack <= 1'b1;
      else if (r218_opctrlcmd_ack_pclk_datasync)
         wait_r218_opctrlcmd_datasync_ack <= 1'b0;
   end

   wire wait_r218_opctrlcmd_combined_ack;
   assign wait_r218_opctrlcmd_combined_ack = wait_r218_opctrlcmd_datasync_ack
                               | wait_reg_ddrc_zq_calib_short_ack
                               | wait_reg_ddrc_ctrlupd_ack
                               ;

   reg wait_r218_opctrlcmd_combined_ack_r;
   always @(posedge apb_clk or negedge apb_rst) begin : r218_opctrlcmd_wait_combined_ack_PROC
      if (~apb_rst)
         wait_r218_opctrlcmd_combined_ack_r <= 1'b0;
      else if ((rwselect[124] & write_en) | fwd_reset_val)
         wait_r218_opctrlcmd_combined_ack_r <= 1'b1;
      else if (~wait_r218_opctrlcmd_combined_ack)
         wait_r218_opctrlcmd_combined_ack_r <= 1'b0;
   end

   reg r218_opctrlcmd_ack_pclk_combined;
   always @(posedge apb_clk or negedge apb_rst) begin : r218_opctrlcmd_ack_pclk_PROC
      if (~apb_rst)
         r218_opctrlcmd_ack_pclk_combined <= 1'b0;
      else if (~wait_r218_opctrlcmd_combined_ack && wait_r218_opctrlcmd_combined_ack_r)
         r218_opctrlcmd_ack_pclk_combined <= 1'b1;
      else
         r218_opctrlcmd_ack_pclk_combined <= 1'b0;
   end

   assign r218_opctrlcmd_ack_pclk = r218_opctrlcmd_ack_pclk_combined;

   // Single bit CDC for field ddrc_reg_zq_calib_short_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_zq_calib_short_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_zq_calib_short_busy),
       .data_d          (ddrc_reg_zq_calib_short_busy_pclk));

   wire ack_s_ddrc_reg_zq_calib_short_busy_unconnected;
   // Pulse synch for field ddrc_reg_zq_calib_short_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_zq_calib_short_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_zq_calib_short_busy),
       .ack_s           (ack_s_ddrc_reg_zq_calib_short_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_zq_calib_short_busy_pulse_pclk));

   // Single bit CDC for field ddrc_reg_ctrlupd_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_ctrlupd_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_ctrlupd_busy),
       .data_d          (ddrc_reg_ctrlupd_busy_pclk));

   wire ack_s_ddrc_reg_ctrlupd_busy_unconnected;
   // Pulse synch for field ddrc_reg_ctrlupd_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_ctrlupd_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_ctrlupd_busy),
       .ack_s           (ack_s_ddrc_reg_ctrlupd_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_ctrlupd_busy_pulse_pclk));


   // Pulse synch for field reg_ddrc_rank0_refresh
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C))
   U_onetoset_reg_ddrc_rank0_refresh_p2c
      (.clk_s           (apb_clk),
       .rst_s_n         (apb_rst),
       .event_s         (reg_ddrc_rank0_refresh_pclk),
       .ack_s           (reg_ddrc_rank0_refresh_ack_pclk),
       .clk_d           (core_ddrc_core_clk),
       .rst_d_n         (sync_core_ddrc_rstn),
       .event_d         (reg_ddrc_rank0_refresh));

   reg reg_ddrc_rank0_refresh_pclk_r;
   always @(posedge apb_clk or negedge apb_rst) begin : sample_reg_ddrc_rank0_refresh_PROC
      if (~apb_rst) begin
         reg_ddrc_rank0_refresh_pclk_r <= 1'b0;
      end else begin
         reg_ddrc_rank0_refresh_pclk_r <= reg_ddrc_rank0_refresh_pclk;
      end
   end

   reg ff_regb_ddrc_ch0_rank0_refresh_saved_s0;
   always @(posedge apb_clk or negedge apb_rst) begin : ff_regb_ddrc_ch0_rank0_refresh_saved_s0_PROC
      if (~apb_rst)
         ff_regb_ddrc_ch0_rank0_refresh_saved_s0 <= 1'b0;
      else
         ff_regb_ddrc_ch0_rank0_refresh_saved_s0 <= ff_regb_ddrc_ch0_rank0_refresh_saved;
   end

   reg [6:0] wait_reg_ddrc_rank0_refresh_ack_timeout;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_rank0_refresh_wait_ack_timeout_PROC
      if (~apb_rst)
         wait_reg_ddrc_rank0_refresh_ack_timeout <= 7'd0;
      else if ((reg_ddrc_rank0_refresh_pclk && (~reg_ddrc_rank0_refresh_pclk_r)) || (ff_regb_ddrc_ch0_rank0_refresh_saved && (~ff_regb_ddrc_ch0_rank0_refresh_saved_s0)))
         wait_reg_ddrc_rank0_refresh_ack_timeout <= WAIT_ACK_TIMEOUT;
      else if (wait_reg_ddrc_rank0_refresh_ack_timeout > 7'd0)
         wait_reg_ddrc_rank0_refresh_ack_timeout <= wait_reg_ddrc_rank0_refresh_ack_timeout - 7'd1;
   end

   reg wait_reg_ddrc_rank0_refresh_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : reg_ddrc_rank0_refresh_wait_ack_PROC
      if (~apb_rst)
         wait_reg_ddrc_rank0_refresh_ack <= 1'b0;
      else if ((reg_ddrc_rank0_refresh_pclk && (~reg_ddrc_rank0_refresh_pclk_r)) || (ff_regb_ddrc_ch0_rank0_refresh_saved && (~ff_regb_ddrc_ch0_rank0_refresh_saved_s0)))
         wait_reg_ddrc_rank0_refresh_ack <= 1'b1;
      else if (reg_ddrc_rank0_refresh_ack_pclk || (wait_reg_ddrc_rank0_refresh_ack_timeout == 7'd0))
         wait_reg_ddrc_rank0_refresh_ack <= 1'b0;
   end































   wire r221_oprefctrl0_ack_pclk_datasync;
   // Datasync CDC for register REGB_DDRC_CH0 oprefctrl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_oprefctrl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[125] & write_en) | fwd_reset_val),
       .s_data          (s_data_r221_oprefctrl0),
       .d_data          (d_data_r221_oprefctrl0),
       .s_ack           (r221_oprefctrl0_ack_pclk_datasync));

   reg wait_r221_oprefctrl0_datasync_ack;
   always @(posedge apb_clk or negedge apb_rst) begin : r221_oprefctrl0_wait_ack_PROC
      if (~apb_rst)
         wait_r221_oprefctrl0_datasync_ack <= 1'b0;
      else if ((rwselect[125] & write_en) | fwd_reset_val)
         wait_r221_oprefctrl0_datasync_ack <= 1'b1;
      else if (r221_oprefctrl0_ack_pclk_datasync)
         wait_r221_oprefctrl0_datasync_ack <= 1'b0;
   end

   wire wait_r221_oprefctrl0_combined_ack;
   assign wait_r221_oprefctrl0_combined_ack = wait_r221_oprefctrl0_datasync_ack
                               | wait_reg_ddrc_rank0_refresh_ack
                               ;

   reg wait_r221_oprefctrl0_combined_ack_r;
   always @(posedge apb_clk or negedge apb_rst) begin : r221_oprefctrl0_wait_combined_ack_PROC
      if (~apb_rst)
         wait_r221_oprefctrl0_combined_ack_r <= 1'b0;
      else if ((rwselect[125] & write_en) | fwd_reset_val)
         wait_r221_oprefctrl0_combined_ack_r <= 1'b1;
      else if (~wait_r221_oprefctrl0_combined_ack)
         wait_r221_oprefctrl0_combined_ack_r <= 1'b0;
   end

   reg r221_oprefctrl0_ack_pclk_combined;
   always @(posedge apb_clk or negedge apb_rst) begin : r221_oprefctrl0_ack_pclk_PROC
      if (~apb_rst)
         r221_oprefctrl0_ack_pclk_combined <= 1'b0;
      else if (~wait_r221_oprefctrl0_combined_ack && wait_r221_oprefctrl0_combined_ack_r)
         r221_oprefctrl0_ack_pclk_combined <= 1'b1;
      else
         r221_oprefctrl0_ack_pclk_combined <= 1'b0;
   end

   assign r221_oprefctrl0_ack_pclk = r221_oprefctrl0_ack_pclk_combined;

































   // Single bit CDC for field ddrc_reg_rank0_refresh_busy
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_ddrc_reg_rank0_refresh_busy_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (ddrc_reg_rank0_refresh_busy),
       .data_d          (ddrc_reg_rank0_refresh_busy_pclk));

   wire ack_s_ddrc_reg_rank0_refresh_busy_unconnected;
   // Pulse synch for field ddrc_reg_rank0_refresh_busy
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_ddrc_reg_rank0_refresh_busy_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (ddrc_reg_rank0_refresh_busy),
       .ack_s           (ack_s_ddrc_reg_rank0_refresh_busy_unconnected),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (ddrc_reg_rank0_refresh_busy_pulse_pclk));































































   // Datasync CDC for register REGB_DDRC_CH0 dbictl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_dbictl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[131] & write_en) | fwd_reset_val),
       .s_data          (s_data_r230_dbictl),
       .d_data          (d_data_r230_dbictl),
       .s_ack           (r230_dbictl_ack_pclk));



   // Datasync CDC for register REGB_DDRC_CH0 datactl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_datactl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[133] & write_en) | fwd_reset_val),
       .s_data          (s_data_r233_datactl0),
       .d_data          (d_data_r233_datactl0),
       .s_ack           (r233_datactl0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 inittmg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_inittmg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[135] & write_en) | fwd_reset_val),
       .s_data          (s_data_r235_inittmg0),
       .d_data          (d_data_r235_inittmg0),
       .s_ack           (r235_inittmg0_ack_pclk));
   // Datasync CDC for register REGB_DDRC_CH0 inittmg1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_ddrc_ch0_inittmg1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[136] & write_en) | fwd_reset_val),
       .s_data          (s_data_r236_inittmg1),
       .d_data          (d_data_r236_inittmg1),
       .s_ack           (r236_inittmg1_ack_pclk));






















































































































































































































































































































































































































































































   // Datasync CDC for register REGB_ADDR_MAP0 addrmap12
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_addr_map0_addrmap12_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[231] & write_en) | fwd_reset_val),
       .s_data          (s_data_r459_addrmap12_map0),
       .d_data          (d_data_r459_addrmap12_map0),
       .s_ack           (r459_addrmap12_map0_ack_pclk));

   // Datasync CDC for register REGB_ARB_PORT0 pctrl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_arb_port0_pctrl_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[280] & write_en) | fwd_reset_val),
       .s_data          (s_data_r509_pctrl_port0),
       .d_data          (d_data_r509_pctrl_port0),
       .s_ack           (r509_pctrl_port0_ack_pclk));
   // Datasync CDC for register REGB_ARB_PORT0 pctrl
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_arb_port0_pctrl_arba0_p2a
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (aclk_0),
       .d_rst_n         (sync_aresetn_0),
       .s_send          ((rwselect[280] & write_en) | fwd_reset_val),
       .s_data          (s_data_arba0_r509_pctrl_port0),
       .d_data          (d_data_arba0_r509_pctrl_port0),
       .s_ack           (r509_pctrl_port0_ack_arba0_pclk));







   // Single bit CDC for field arb_reg_rd_port_busy_0_port0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_arb_reg_rd_port_busy_0_port0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (arb_reg_rd_port_busy_0_port0),
       .data_d          (arb_reg_rd_port_busy_0_port0_pclk));
















   // Single bit CDC for field arb_reg_wr_port_busy_0_port0
   DWC_ddr_umctl2_bitsync
   
     #(.BCM_SYNC_TYPE   (BCM_F_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_bitsync_arb_reg_wr_port_busy_0_port0_c2p
      (.clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .data_s          (arb_reg_wr_port_busy_0_port0),
       .data_d          (arb_reg_wr_port_busy_0_port0_pclk));





















































































































































































































































































































































   // Datasync CDC for register REGB_FREQ0_CH0 dramset1tmg5
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dramset1tmg5_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1476] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1887_dramset1tmg5_freq0),
       .d_data          (d_data_r1887_dramset1tmg5_freq0),
       .s_ack           (r1887_dramset1tmg5_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dramset1tmg7
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dramset1tmg7_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1478] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1889_dramset1tmg7_freq0),
       .d_data          (d_data_r1889_dramset1tmg7_freq0),
       .s_ack           (r1889_dramset1tmg7_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dramset1tmg23
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dramset1tmg23_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1494] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1905_dramset1tmg23_freq0),
       .d_data          (d_data_r1905_dramset1tmg23_freq0),
       .s_ack           (r1905_dramset1tmg23_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dramset1tmg30
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dramset1tmg30_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1501] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1912_dramset1tmg30_freq0),
       .d_data          (d_data_r1912_dramset1tmg30_freq0),
       .s_ack           (r1912_dramset1tmg30_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 initmr1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_initmr1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1528] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1939_initmr1_freq0),
       .d_data          (d_data_r1939_initmr1_freq0),
       .s_ack           (r1939_initmr1_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dfitmg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dfitmg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1531] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1942_dfitmg0_freq0),
       .d_data          (d_data_r1942_dfitmg0_freq0),
       .s_ack           (r1942_dfitmg0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dfitmg1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dfitmg1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1532] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1943_dfitmg1_freq0),
       .d_data          (d_data_r1943_dfitmg1_freq0),
       .s_ack           (r1943_dfitmg1_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dfilptmg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dfilptmg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1538] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1949_dfilptmg0_freq0),
       .d_data          (d_data_r1949_dfilptmg0_freq0),
       .s_ack           (r1949_dfilptmg0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dfilptmg1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dfilptmg1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1539] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1950_dfilptmg1_freq0),
       .d_data          (d_data_r1950_dfilptmg1_freq0),
       .s_ack           (r1950_dfilptmg1_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dfiupdtmg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dfiupdtmg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1540] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1951_dfiupdtmg0_freq0),
       .d_data          (d_data_r1951_dfiupdtmg0_freq0),
       .s_ack           (r1951_dfiupdtmg0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 rfshset1tmg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_rfshset1tmg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1544] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1955_rfshset1tmg0_freq0),
       .d_data          (d_data_r1955_rfshset1tmg0_freq0),
       .s_ack           (r1955_rfshset1tmg0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 rfshset1tmg1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_rfshset1tmg1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1545] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1956_rfshset1tmg1_freq0),
       .d_data          (d_data_r1956_rfshset1tmg1_freq0),
       .s_ack           (r1956_rfshset1tmg1_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 rfshset1tmg2
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_rfshset1tmg2_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1546] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1957_rfshset1tmg2_freq0),
       .d_data          (d_data_r1957_rfshset1tmg2_freq0),
       .s_ack           (r1957_rfshset1tmg2_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 rfshset1tmg3
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_rfshset1tmg3_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1547] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1958_rfshset1tmg3_freq0),
       .d_data          (d_data_r1958_rfshset1tmg3_freq0),
       .s_ack           (r1958_rfshset1tmg3_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 zqset1tmg0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_zqset1tmg0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1564] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1975_zqset1tmg0_freq0),
       .d_data          (d_data_r1975_zqset1tmg0_freq0),
       .s_ack           (r1975_zqset1tmg0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 dqsoscctl0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_dqsoscctl0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1574] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1985_dqsoscctl0_freq0),
       .d_data          (d_data_r1985_dqsoscctl0_freq0),
       .s_ack           (r1985_dqsoscctl0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 derateval0
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_derateval0_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1576] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1987_derateval0_freq0),
       .d_data          (d_data_r1987_derateval0_freq0),
       .s_ack           (r1987_derateval0_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 derateval1
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_derateval1_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1577] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1988_derateval1_freq0),
       .d_data          (d_data_r1988_derateval1_freq0),
       .s_ack           (r1988_derateval1_freq0_ack_pclk));
   // Datasync CDC for register REGB_FREQ0_CH0 tmgcfg
   DWC_ddr_umctl2_datasync
   
     #(.DW              (REG_WIDTH),
       .BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_P2C),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_P2C),
       .DETECT_CHANGE   (1'b0))
   U_datasync_regb_freq0_ch0_tmgcfg_p2c
      (.s_clk           (apb_clk),
       .s_rst_n         (apb_rst),
       .d_clk           (core_ddrc_core_clk),
       .d_rst_n         (sync_core_ddrc_rstn),
       .s_send          ((rwselect[1583] & write_en) | fwd_reset_val),
       .s_data          (s_data_r1994_tmgcfg_freq0),
       .d_data          (d_data_r1994_tmgcfg_freq0),
       .s_ack           (r1994_tmgcfg_freq0_ack_pclk));


   // Pulse synch for core_derate_temp_limit_intr
   DWC_ddr_umctl2_onetoset
   
     #(.BCM_F_SYNC_TYPE (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE (BCM_R_SYNC_TYPE_C2P),
       .BCM_VERIF_EN    (BCM_VERIF_EN),
       .REG_OUTPUTS     (REG_OUTPUTS_C2P))
   U_pulsesync_derate_temp_limit_intr_c2p
      (.clk_s           (core_ddrc_core_clk),
       .rst_s_n         (core_ddrc_rstn),
       .event_s         (core_derate_temp_limit_intr),
       .ack_s           (derate_sync_ack_c2p),
       .clk_d           (apb_clk),
       .rst_d_n         (apb_rst),
       .event_d         (pclk_derate_temp_limit_intr));


   //------------------------------------------------
   // instantiate ecc_poison_reg (indirect write registers)
   //------------------------------------------------


   //-----------------------------------------
   // Register Parity checking of *_busy logic
   //-----------------------------------------









endmodule
