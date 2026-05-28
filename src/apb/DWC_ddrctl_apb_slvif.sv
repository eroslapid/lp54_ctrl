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

// Revision $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddrctl_apb_slvif.sv#3 $
`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"

module DWC_ddrctl_apb_slvif
import DWC_ddrctl_reg_pkg::*;
  #(parameter APB_AW = 16,
    parameter APB_DW = 32,
    parameter RW_REGS = `UMCTL2_REGS_RW_REGS,
    parameter REG_WIDTH = 32,
    parameter RWSELWIDTH = RW_REGS
    )
   (input                     pclk
    ,input                     presetn
    ,input [APB_DW-1:0]        pwdata
    ,input [RWSELWIDTH-1:0]    rwselect
    ,input                     write_en
    ,input                     store_rqst
    // static registers write enable
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
    ,input               static_wr_en_aclk_0
    ,input               quasi_dyn_wr_en_aclk_0
//spyglass enable_block W240
    ,input               static_wr_en_core_ddrc_core_clk
    ,input               quasi_dyn_wr_en_core_ddrc_core_clk
//`ifdef UMCTL2_OCECC_EN_1    
//    ,input               quasi_dyn_wr_en_pclk
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1 
    //----------------------------------
   ,output reg [REG_WIDTH -1:0] r0_mstr0
   ,output reg [REG_WIDTH -1:0] r4_mstr4
   ,output reg [REG_WIDTH -1:0] r8_mrctrl0
   ,input reg_ddrc_mrr_done_clr_ack_pclk
   ,input reg_ddrc_mr_wr_ack_pclk
   ,output reg ff_regb_ddrc_ch0_mr_wr_saved
   ,output reg [REG_WIDTH -1:0] r9_mrctrl1
   ,input ddrc_reg_mr_wr_busy_int
   ,output reg [REG_WIDTH -1:0] r14_deratectl0
   ,output reg [REG_WIDTH -1:0] r15_deratectl1
   ,output reg [REG_WIDTH -1:0] r19_deratectl5
   ,input reg_ddrc_derate_temp_limit_intr_clr_ack_pclk
   ,input reg_ddrc_derate_temp_limit_intr_force_ack_pclk
   ,output reg [REG_WIDTH -1:0] r20_deratectl6
   ,output reg [REG_WIDTH -1:0] r23_deratedbgctl
   ,output reg [REG_WIDTH -1:0] r25_pwrctl
   ,output reg [REG_WIDTH -1:0] r26_hwlpctl
   ,output reg [REG_WIDTH -1:0] r28_clkgatectl
   ,output reg [REG_WIDTH -1:0] r29_rfshmod0
   ,output reg [REG_WIDTH -1:0] r31_rfshctl0
   ,output reg [REG_WIDTH -1:0] r34_zqctl0
   ,output reg [REG_WIDTH -1:0] r35_zqctl1
   ,input reg_ddrc_zq_reset_ack_pclk
   ,output reg ff_regb_ddrc_ch0_zq_reset_saved
   ,output reg [REG_WIDTH -1:0] r36_zqctl2
   ,input ddrc_reg_zq_reset_busy_int
   ,output reg [REG_WIDTH -1:0] r38_dqsoscruntime
   ,output reg [REG_WIDTH -1:0] r40_dqsosccfg0
   ,output reg [REG_WIDTH -1:0] r42_sched0
   ,output reg [REG_WIDTH -1:0] r43_sched1
   ,output reg [REG_WIDTH -1:0] r45_sched3
   ,output reg [REG_WIDTH -1:0] r46_sched4
   ,output reg [REG_WIDTH -1:0] r56_dfilpcfg0
   ,output reg [REG_WIDTH -1:0] r57_dfiupd0
   ,output reg [REG_WIDTH -1:0] r59_dfimisc
   ,output reg [REG_WIDTH -1:0] r61_dfiphymstr
   ,output reg [REG_WIDTH -1:0] r62_dfi0msgctl0
   ,input reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk
   ,input reg_ddrc_dfi0_ctrlmsg_req_ack_pclk
   ,output reg ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved
   ,input ddrc_reg_dfi0_ctrlmsg_req_busy_int
   ,output reg [REG_WIDTH -1:0] r64_poisoncfg
   ,input reg_ddrc_wr_poison_intr_clr_ack_pclk
   ,input reg_ddrc_rd_poison_intr_clr_ack_pclk
   ,output reg [REG_WIDTH -1:0] r215_opctrl0
   ,output reg [REG_WIDTH -1:0] r216_opctrl1
   ,output reg [REG_WIDTH -1:0] r218_opctrlcmd
   ,input reg_ddrc_zq_calib_short_ack_pclk
   ,output reg ff_regb_ddrc_ch0_zq_calib_short_saved
   ,input reg_ddrc_ctrlupd_ack_pclk
   ,output reg ff_regb_ddrc_ch0_ctrlupd_saved
   ,input ddrc_reg_zq_calib_short_busy_int
   ,input ddrc_reg_ctrlupd_busy_int
   ,output reg [REG_WIDTH -1:0] r221_oprefctrl0
   ,input reg_ddrc_rank0_refresh_ack_pclk
   ,output reg ff_regb_ddrc_ch0_rank0_refresh_saved
   ,input ddrc_reg_rank0_refresh_busy_int
   ,output reg [REG_WIDTH -1:0] r225_swctl
   ,output reg [REG_WIDTH -1:0] r230_dbictl
   ,output reg [REG_WIDTH -1:0] r232_odtmap
   ,output reg [REG_WIDTH -1:0] r233_datactl0
   ,output reg [REG_WIDTH -1:0] r234_swctlstatic
   ,output reg [REG_WIDTH -1:0] r235_inittmg0
   ,output reg [REG_WIDTH -1:0] r236_inittmg1
   ,output reg [REG_WIDTH -1:0] r450_addrmap3_map0
   ,output reg [REG_WIDTH -1:0] r451_addrmap4_map0
   ,output reg [REG_WIDTH -1:0] r452_addrmap5_map0
   ,output reg [REG_WIDTH -1:0] r453_addrmap6_map0
   ,output reg [REG_WIDTH -1:0] r454_addrmap7_map0
   ,output reg [REG_WIDTH -1:0] r455_addrmap8_map0
   ,output reg [REG_WIDTH -1:0] r456_addrmap9_map0
   ,output reg [REG_WIDTH -1:0] r457_addrmap10_map0
   ,output reg [REG_WIDTH -1:0] r458_addrmap11_map0
   ,output reg [REG_WIDTH -1:0] r459_addrmap12_map0
   ,output reg [REG_WIDTH -1:0] r474_pccfg_port0
   ,output reg [REG_WIDTH -1:0] r475_pcfgr_port0
   ,output reg [REG_WIDTH -1:0] r476_pcfgw_port0
   ,output reg [REG_WIDTH -1:0] r509_pctrl_port0
   ,output reg [REG_WIDTH -1:0] r510_pcfgqos0_port0
   ,output reg [REG_WIDTH -1:0] r511_pcfgqos1_port0
   ,output reg [REG_WIDTH -1:0] r512_pcfgwqos0_port0
   ,output reg [REG_WIDTH -1:0] r513_pcfgwqos1_port0
   ,output reg [REG_WIDTH -1:0] r1882_dramset1tmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1883_dramset1tmg1_freq0
   ,output reg [REG_WIDTH -1:0] r1884_dramset1tmg2_freq0
   ,output reg [REG_WIDTH -1:0] r1885_dramset1tmg3_freq0
   ,output reg [REG_WIDTH -1:0] r1886_dramset1tmg4_freq0
   ,output reg [REG_WIDTH -1:0] r1887_dramset1tmg5_freq0
   ,output reg [REG_WIDTH -1:0] r1888_dramset1tmg6_freq0
   ,output reg [REG_WIDTH -1:0] r1889_dramset1tmg7_freq0
   ,output reg [REG_WIDTH -1:0] r1891_dramset1tmg9_freq0
   ,output reg [REG_WIDTH -1:0] r1894_dramset1tmg12_freq0
   ,output reg [REG_WIDTH -1:0] r1895_dramset1tmg13_freq0
   ,output reg [REG_WIDTH -1:0] r1896_dramset1tmg14_freq0
   ,output reg [REG_WIDTH -1:0] r1905_dramset1tmg23_freq0
   ,output reg [REG_WIDTH -1:0] r1906_dramset1tmg24_freq0
   ,output reg [REG_WIDTH -1:0] r1907_dramset1tmg25_freq0
   ,output reg [REG_WIDTH -1:0] r1912_dramset1tmg30_freq0
   ,output reg [REG_WIDTH -1:0] r1938_initmr0_freq0
   ,output reg [REG_WIDTH -1:0] r1939_initmr1_freq0
   ,output reg [REG_WIDTH -1:0] r1940_initmr2_freq0
   ,output reg [REG_WIDTH -1:0] r1941_initmr3_freq0
   ,output reg [REG_WIDTH -1:0] r1942_dfitmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1943_dfitmg1_freq0
   ,output reg [REG_WIDTH -1:0] r1944_dfitmg2_freq0
   ,output reg [REG_WIDTH -1:0] r1946_dfitmg4_freq0
   ,output reg [REG_WIDTH -1:0] r1947_dfitmg5_freq0
   ,output reg [REG_WIDTH -1:0] r1949_dfilptmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1950_dfilptmg1_freq0
   ,output reg [REG_WIDTH -1:0] r1951_dfiupdtmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1952_dfiupdtmg1_freq0
   ,output reg [REG_WIDTH -1:0] r1953_dfimsgtmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1955_rfshset1tmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1956_rfshset1tmg1_freq0
   ,output reg [REG_WIDTH -1:0] r1957_rfshset1tmg2_freq0
   ,output reg [REG_WIDTH -1:0] r1958_rfshset1tmg3_freq0
   ,output reg [REG_WIDTH -1:0] r1975_zqset1tmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1976_zqset1tmg1_freq0
   ,output reg [REG_WIDTH -1:0] r1985_dqsoscctl0_freq0
   ,output reg [REG_WIDTH -1:0] r1986_derateint_freq0
   ,output reg [REG_WIDTH -1:0] r1987_derateval0_freq0
   ,output reg [REG_WIDTH -1:0] r1988_derateval1_freq0
   ,output reg [REG_WIDTH -1:0] r1989_hwlptmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1990_schedtmg0_freq0
   ,output reg [REG_WIDTH -1:0] r1991_perfhpr1_freq0
   ,output reg [REG_WIDTH -1:0] r1992_perflpr1_freq0
   ,output reg [REG_WIDTH -1:0] r1993_perfwr1_freq0
   ,output reg [REG_WIDTH -1:0] r1994_tmgcfg_freq0
   ,output reg [REG_WIDTH -1:0] r1997_pwrtmg_freq0


    );
  
   reg [APB_DW-1:0]         apb_data_r;
   reg [REG_WIDTH-1:0]      apb_data_expanded;

   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr0_lpddr4_mask;
   assign regb_ddrc_ch0_mstr0_lpddr4_mask = `REGB_DDRC_CH0_MSK_MSTR0_LPDDR4;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr0_lpddr5_mask;
   assign regb_ddrc_ch0_mstr0_lpddr5_mask = `REGB_DDRC_CH0_MSK_MSTR0_LPDDR5;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr0_en_2t_timing_mode_mask;
   assign regb_ddrc_ch0_mstr0_en_2t_timing_mode_mask = `REGB_DDRC_CH0_MSK_MSTR0_EN_2T_TIMING_MODE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr0_data_bus_width_mask;
   assign regb_ddrc_ch0_mstr0_data_bus_width_mask = `REGB_DDRC_CH0_MSK_MSTR0_DATA_BUS_WIDTH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr0_burst_rdwr_mask;
   assign regb_ddrc_ch0_mstr0_burst_rdwr_mask = `REGB_DDRC_CH0_MSK_MSTR0_BURST_RDWR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr4_wck_on_mask;
   assign regb_ddrc_ch0_mstr4_wck_on_mask = `REGB_DDRC_CH0_MSK_MSTR4_WCK_ON;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr4_wck_suspend_en_mask;
   assign regb_ddrc_ch0_mstr4_wck_suspend_en_mask = `REGB_DDRC_CH0_MSK_MSTR4_WCK_SUSPEND_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mstr4_ws_off_en_mask;
   assign regb_ddrc_ch0_mstr4_ws_off_en_mask = `REGB_DDRC_CH0_MSK_MSTR4_WS_OFF_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl0_mr_type_mask;
   assign regb_ddrc_ch0_mrctrl0_mr_type_mask = `REGB_DDRC_CH0_MSK_MRCTRL0_MR_TYPE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl0_sw_init_int_mask;
   assign regb_ddrc_ch0_mrctrl0_sw_init_int_mask = `REGB_DDRC_CH0_MSK_MRCTRL0_SW_INIT_INT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl0_mr_rank_mask;
   assign regb_ddrc_ch0_mrctrl0_mr_rank_mask = `REGB_DDRC_CH0_MSK_MRCTRL0_MR_RANK;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl0_mr_addr_mask;
   assign regb_ddrc_ch0_mrctrl0_mr_addr_mask = `REGB_DDRC_CH0_MSK_MRCTRL0_MR_ADDR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl0_mrr_done_clr_mask;
   assign regb_ddrc_ch0_mrctrl0_mrr_done_clr_mask = `REGB_DDRC_CH0_MSK_MRCTRL0_MRR_DONE_CLR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl0_mr_wr_mask;
   assign regb_ddrc_ch0_mrctrl0_mr_wr_mask = `REGB_DDRC_CH0_MSK_MRCTRL0_MR_WR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_mrctrl1_mr_data_mask;
   assign regb_ddrc_ch0_mrctrl1_mr_data_mask = `REGB_DDRC_CH0_MSK_MRCTRL1_MR_DATA;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl0_derate_enable_mask;
   assign regb_ddrc_ch0_deratectl0_derate_enable_mask = `REGB_DDRC_CH0_MSK_DERATECTL0_DERATE_ENABLE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl0_lpddr4_refresh_mode_mask;
   assign regb_ddrc_ch0_deratectl0_lpddr4_refresh_mode_mask = `REGB_DDRC_CH0_MSK_DERATECTL0_LPDDR4_REFRESH_MODE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl0_derate_mr4_pause_fc_mask;
   assign regb_ddrc_ch0_deratectl0_derate_mr4_pause_fc_mask = `REGB_DDRC_CH0_MSK_DERATECTL0_DERATE_MR4_PAUSE_FC;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl0_dis_trefi_x6x8_mask;
   assign regb_ddrc_ch0_deratectl0_dis_trefi_x6x8_mask = `REGB_DDRC_CH0_MSK_DERATECTL0_DIS_TREFI_X6X8;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl0_dis_trefi_x0125_mask;
   assign regb_ddrc_ch0_deratectl0_dis_trefi_x0125_mask = `REGB_DDRC_CH0_MSK_DERATECTL0_DIS_TREFI_X0125;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl1_active_derate_byte_rank0_mask;
   assign regb_ddrc_ch0_deratectl1_active_derate_byte_rank0_mask = `REGB_DDRC_CH0_MSK_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_en_mask;
   assign regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_en_mask = `REGB_DDRC_CH0_MSK_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_clr_mask;
   assign regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_clr_mask = `REGB_DDRC_CH0_MSK_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_force_mask;
   assign regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_force_mask = `REGB_DDRC_CH0_MSK_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratectl6_derate_mr4_tuf_dis_mask;
   assign regb_ddrc_ch0_deratectl6_derate_mr4_tuf_dis_mask = `REGB_DDRC_CH0_MSK_DERATECTL6_DERATE_MR4_TUF_DIS;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratedbgctl_dbg_mr4_grp_sel_mask;
   assign regb_ddrc_ch0_deratedbgctl_dbg_mr4_grp_sel_mask = `REGB_DDRC_CH0_MSK_DERATEDBGCTL_DBG_MR4_GRP_SEL;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_deratedbgctl_dbg_mr4_rank_sel_mask;
   assign regb_ddrc_ch0_deratedbgctl_dbg_mr4_rank_sel_mask = `REGB_DDRC_CH0_MSK_DERATEDBGCTL_DBG_MR4_RANK_SEL;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_selfref_en_mask;
   assign regb_ddrc_ch0_pwrctl_selfref_en_mask = `REGB_DDRC_CH0_MSK_PWRCTL_SELFREF_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_powerdown_en_mask;
   assign regb_ddrc_ch0_pwrctl_powerdown_en_mask = `REGB_DDRC_CH0_MSK_PWRCTL_POWERDOWN_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_en_dfi_dram_clk_disable_mask;
   assign regb_ddrc_ch0_pwrctl_en_dfi_dram_clk_disable_mask = `REGB_DDRC_CH0_MSK_PWRCTL_EN_DFI_DRAM_CLK_DISABLE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_selfref_sw_mask;
   assign regb_ddrc_ch0_pwrctl_selfref_sw_mask = `REGB_DDRC_CH0_MSK_PWRCTL_SELFREF_SW;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_stay_in_selfref_mask;
   assign regb_ddrc_ch0_pwrctl_stay_in_selfref_mask = `REGB_DDRC_CH0_MSK_PWRCTL_STAY_IN_SELFREF;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_dis_cam_drain_selfref_mask;
   assign regb_ddrc_ch0_pwrctl_dis_cam_drain_selfref_mask = `REGB_DDRC_CH0_MSK_PWRCTL_DIS_CAM_DRAIN_SELFREF;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_lpddr4_sr_allowed_mask;
   assign regb_ddrc_ch0_pwrctl_lpddr4_sr_allowed_mask = `REGB_DDRC_CH0_MSK_PWRCTL_LPDDR4_SR_ALLOWED;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_pwrctl_dsm_en_mask;
   assign regb_ddrc_ch0_pwrctl_dsm_en_mask = `REGB_DDRC_CH0_MSK_PWRCTL_DSM_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_hwlpctl_hw_lp_en_mask;
   assign regb_ddrc_ch0_hwlpctl_hw_lp_en_mask = `REGB_DDRC_CH0_MSK_HWLPCTL_HW_LP_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_hwlpctl_hw_lp_exit_idle_en_mask;
   assign regb_ddrc_ch0_hwlpctl_hw_lp_exit_idle_en_mask = `REGB_DDRC_CH0_MSK_HWLPCTL_HW_LP_EXIT_IDLE_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_clkgatectl_bsm_clk_on_mask;
   assign regb_ddrc_ch0_clkgatectl_bsm_clk_on_mask = `REGB_DDRC_CH0_MSK_CLKGATECTL_BSM_CLK_ON;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_rfshmod0_refresh_burst_mask;
   assign regb_ddrc_ch0_rfshmod0_refresh_burst_mask = `REGB_DDRC_CH0_MSK_RFSHMOD0_REFRESH_BURST;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_rfshmod0_auto_refab_en_mask;
   assign regb_ddrc_ch0_rfshmod0_auto_refab_en_mask = `REGB_DDRC_CH0_MSK_RFSHMOD0_AUTO_REFAB_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_rfshmod0_per_bank_refresh_mask;
   assign regb_ddrc_ch0_rfshmod0_per_bank_refresh_mask = `REGB_DDRC_CH0_MSK_RFSHMOD0_PER_BANK_REFRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_rfshctl0_dis_auto_refresh_mask;
   assign regb_ddrc_ch0_rfshctl0_dis_auto_refresh_mask = `REGB_DDRC_CH0_MSK_RFSHCTL0_DIS_AUTO_REFRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_rfshctl0_refresh_update_level_mask;
   assign regb_ddrc_ch0_rfshctl0_refresh_update_level_mask = `REGB_DDRC_CH0_MSK_RFSHCTL0_REFRESH_UPDATE_LEVEL;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_zqctl0_zq_resistor_shared_mask;
   assign regb_ddrc_ch0_zqctl0_zq_resistor_shared_mask = `REGB_DDRC_CH0_MSK_ZQCTL0_ZQ_RESISTOR_SHARED;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_zqctl0_dis_auto_zq_mask;
   assign regb_ddrc_ch0_zqctl0_dis_auto_zq_mask = `REGB_DDRC_CH0_MSK_ZQCTL0_DIS_AUTO_ZQ;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_zqctl1_zq_reset_mask;
   assign regb_ddrc_ch0_zqctl1_zq_reset_mask = `REGB_DDRC_CH0_MSK_ZQCTL1_ZQ_RESET;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_zqctl2_dis_srx_zqcl_mask;
   assign regb_ddrc_ch0_zqctl2_dis_srx_zqcl_mask = `REGB_DDRC_CH0_MSK_ZQCTL2_DIS_SRX_ZQCL;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dqsoscruntime_dqsosc_runtime_mask;
   assign regb_ddrc_ch0_dqsoscruntime_dqsosc_runtime_mask = `REGB_DDRC_CH0_MSK_DQSOSCRUNTIME_DQSOSC_RUNTIME;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dqsoscruntime_wck2dqo_runtime_mask;
   assign regb_ddrc_ch0_dqsoscruntime_wck2dqo_runtime_mask = `REGB_DDRC_CH0_MSK_DQSOSCRUNTIME_WCK2DQO_RUNTIME;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dqsosccfg0_dis_dqsosc_srx_mask;
   assign regb_ddrc_ch0_dqsosccfg0_dis_dqsosc_srx_mask = `REGB_DDRC_CH0_MSK_DQSOSCCFG0_DIS_DQSOSC_SRX;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_prefer_write_mask;
   assign regb_ddrc_ch0_sched0_prefer_write_mask = `REGB_DDRC_CH0_MSK_SCHED0_PREFER_WRITE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_pageclose_mask;
   assign regb_ddrc_ch0_sched0_pageclose_mask = `REGB_DDRC_CH0_MSK_SCHED0_PAGECLOSE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_opt_wrcam_fill_level_mask;
   assign regb_ddrc_ch0_sched0_opt_wrcam_fill_level_mask = `REGB_DDRC_CH0_MSK_SCHED0_OPT_WRCAM_FILL_LEVEL;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_dis_opt_ntt_by_act_mask;
   assign regb_ddrc_ch0_sched0_dis_opt_ntt_by_act_mask = `REGB_DDRC_CH0_MSK_SCHED0_DIS_OPT_NTT_BY_ACT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_dis_opt_ntt_by_pre_mask;
   assign regb_ddrc_ch0_sched0_dis_opt_ntt_by_pre_mask = `REGB_DDRC_CH0_MSK_SCHED0_DIS_OPT_NTT_BY_PRE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_autopre_rmw_mask;
   assign regb_ddrc_ch0_sched0_autopre_rmw_mask = `REGB_DDRC_CH0_MSK_SCHED0_AUTOPRE_RMW;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_lpr_num_entries_mask;
   assign regb_ddrc_ch0_sched0_lpr_num_entries_mask = `REGB_DDRC_CH0_MSK_SCHED0_LPR_NUM_ENTRIES;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_lpddr4_opt_act_timing_mask;
   assign regb_ddrc_ch0_sched0_lpddr4_opt_act_timing_mask = `REGB_DDRC_CH0_MSK_SCHED0_LPDDR4_OPT_ACT_TIMING;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_lpddr5_opt_act_timing_mask;
   assign regb_ddrc_ch0_sched0_lpddr5_opt_act_timing_mask = `REGB_DDRC_CH0_MSK_SCHED0_LPDDR5_OPT_ACT_TIMING;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_prefer_read_mask;
   assign regb_ddrc_ch0_sched0_prefer_read_mask = `REGB_DDRC_CH0_MSK_SCHED0_PREFER_READ;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched0_dis_speculative_act_mask;
   assign regb_ddrc_ch0_sched0_dis_speculative_act_mask = `REGB_DDRC_CH0_MSK_SCHED0_DIS_SPECULATIVE_ACT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched1_delay_switch_write_mask;
   assign regb_ddrc_ch0_sched1_delay_switch_write_mask = `REGB_DDRC_CH0_MSK_SCHED1_DELAY_SWITCH_WRITE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched1_page_hit_limit_wr_mask;
   assign regb_ddrc_ch0_sched1_page_hit_limit_wr_mask = `REGB_DDRC_CH0_MSK_SCHED1_PAGE_HIT_LIMIT_WR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched1_page_hit_limit_rd_mask;
   assign regb_ddrc_ch0_sched1_page_hit_limit_rd_mask = `REGB_DDRC_CH0_MSK_SCHED1_PAGE_HIT_LIMIT_RD;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched1_opt_hit_gt_hpr_mask;
   assign regb_ddrc_ch0_sched1_opt_hit_gt_hpr_mask = `REGB_DDRC_CH0_MSK_SCHED1_OPT_HIT_GT_HPR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched3_wrcam_lowthresh_mask;
   assign regb_ddrc_ch0_sched3_wrcam_lowthresh_mask = `REGB_DDRC_CH0_MSK_SCHED3_WRCAM_LOWTHRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched3_wrcam_highthresh_mask;
   assign regb_ddrc_ch0_sched3_wrcam_highthresh_mask = `REGB_DDRC_CH0_MSK_SCHED3_WRCAM_HIGHTHRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched3_wr_pghit_num_thresh_mask;
   assign regb_ddrc_ch0_sched3_wr_pghit_num_thresh_mask = `REGB_DDRC_CH0_MSK_SCHED3_WR_PGHIT_NUM_THRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched3_rd_pghit_num_thresh_mask;
   assign regb_ddrc_ch0_sched3_rd_pghit_num_thresh_mask = `REGB_DDRC_CH0_MSK_SCHED3_RD_PGHIT_NUM_THRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched4_rd_act_idle_gap_mask;
   assign regb_ddrc_ch0_sched4_rd_act_idle_gap_mask = `REGB_DDRC_CH0_MSK_SCHED4_RD_ACT_IDLE_GAP;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched4_wr_act_idle_gap_mask;
   assign regb_ddrc_ch0_sched4_wr_act_idle_gap_mask = `REGB_DDRC_CH0_MSK_SCHED4_WR_ACT_IDLE_GAP;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched4_rd_page_exp_cycles_mask;
   assign regb_ddrc_ch0_sched4_rd_page_exp_cycles_mask = `REGB_DDRC_CH0_MSK_SCHED4_RD_PAGE_EXP_CYCLES;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_sched4_wr_page_exp_cycles_mask;
   assign regb_ddrc_ch0_sched4_wr_page_exp_cycles_mask = `REGB_DDRC_CH0_MSK_SCHED4_WR_PAGE_EXP_CYCLES;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_pd_mask;
   assign regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_pd_mask = `REGB_DDRC_CH0_MSK_DFILPCFG0_DFI_LP_EN_PD;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_sr_mask;
   assign regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_sr_mask = `REGB_DDRC_CH0_MSK_DFILPCFG0_DFI_LP_EN_SR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_dsm_mask;
   assign regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_dsm_mask = `REGB_DDRC_CH0_MSK_DFILPCFG0_DFI_LP_EN_DSM;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_data_mask;
   assign regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_data_mask = `REGB_DDRC_CH0_MSK_DFILPCFG0_DFI_LP_EN_DATA;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfilpcfg0_dfi_lp_data_req_en_mask;
   assign regb_ddrc_ch0_dfilpcfg0_dfi_lp_data_req_en_mask = `REGB_DDRC_CH0_MSK_DFILPCFG0_DFI_LP_DATA_REQ_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfiupd0_dfi_phyupd_en_mask;
   assign regb_ddrc_ch0_dfiupd0_dfi_phyupd_en_mask = `REGB_DDRC_CH0_MSK_DFIUPD0_DFI_PHYUPD_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfiupd0_ctrlupd_pre_srx_mask;
   assign regb_ddrc_ch0_dfiupd0_ctrlupd_pre_srx_mask = `REGB_DDRC_CH0_MSK_DFIUPD0_CTRLUPD_PRE_SRX;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfiupd0_dis_auto_ctrlupd_srx_mask;
   assign regb_ddrc_ch0_dfiupd0_dis_auto_ctrlupd_srx_mask = `REGB_DDRC_CH0_MSK_DFIUPD0_DIS_AUTO_CTRLUPD_SRX;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfiupd0_dis_auto_ctrlupd_mask;
   assign regb_ddrc_ch0_dfiupd0_dis_auto_ctrlupd_mask = `REGB_DDRC_CH0_MSK_DFIUPD0_DIS_AUTO_CTRLUPD;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_dfi_init_complete_en_mask;
   assign regb_ddrc_ch0_dfimisc_dfi_init_complete_en_mask = `REGB_DDRC_CH0_MSK_DFIMISC_DFI_INIT_COMPLETE_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_phy_dbi_mode_mask;
   assign regb_ddrc_ch0_dfimisc_phy_dbi_mode_mask = `REGB_DDRC_CH0_MSK_DFIMISC_PHY_DBI_MODE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_dfi_data_cs_polarity_mask;
   assign regb_ddrc_ch0_dfimisc_dfi_data_cs_polarity_mask = `REGB_DDRC_CH0_MSK_DFIMISC_DFI_DATA_CS_POLARITY;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_dfi_init_start_mask;
   assign regb_ddrc_ch0_dfimisc_dfi_init_start_mask = `REGB_DDRC_CH0_MSK_DFIMISC_DFI_INIT_START;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_lp_optimized_write_mask;
   assign regb_ddrc_ch0_dfimisc_lp_optimized_write_mask = `REGB_DDRC_CH0_MSK_DFIMISC_LP_OPTIMIZED_WRITE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_dfi_frequency_mask;
   assign regb_ddrc_ch0_dfimisc_dfi_frequency_mask = `REGB_DDRC_CH0_MSK_DFIMISC_DFI_FREQUENCY;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_dfi_freq_fsp_mask;
   assign regb_ddrc_ch0_dfimisc_dfi_freq_fsp_mask = `REGB_DDRC_CH0_MSK_DFIMISC_DFI_FREQ_FSP;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfimisc_dfi_channel_mode_mask;
   assign regb_ddrc_ch0_dfimisc_dfi_channel_mode_mask = `REGB_DDRC_CH0_MSK_DFIMISC_DFI_CHANNEL_MODE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfiphymstr_dfi_phymstr_en_mask;
   assign regb_ddrc_ch0_dfiphymstr_dfi_phymstr_en_mask = `REGB_DDRC_CH0_MSK_DFIPHYMSTR_DFI_PHYMSTR_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfiphymstr_dfi_phymstr_blk_ref_x32_mask;
   assign regb_ddrc_ch0_dfiphymstr_dfi_phymstr_blk_ref_x32_mask = `REGB_DDRC_CH0_MSK_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_data_mask;
   assign regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_data_mask = `REGB_DDRC_CH0_MSK_DFI0MSGCTL0_DFI0_CTRLMSG_DATA;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_cmd_mask;
   assign regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_cmd_mask = `REGB_DDRC_CH0_MSK_DFI0MSGCTL0_DFI0_CTRLMSG_CMD;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_tout_clr_mask;
   assign regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_tout_clr_mask = `REGB_DDRC_CH0_MSK_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_req_mask;
   assign regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_req_mask = `REGB_DDRC_CH0_MSK_DFI0MSGCTL0_DFI0_CTRLMSG_REQ;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_poisoncfg_wr_poison_slverr_en_mask;
   assign regb_ddrc_ch0_poisoncfg_wr_poison_slverr_en_mask = `REGB_DDRC_CH0_MSK_POISONCFG_WR_POISON_SLVERR_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_poisoncfg_wr_poison_intr_en_mask;
   assign regb_ddrc_ch0_poisoncfg_wr_poison_intr_en_mask = `REGB_DDRC_CH0_MSK_POISONCFG_WR_POISON_INTR_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_poisoncfg_wr_poison_intr_clr_mask;
   assign regb_ddrc_ch0_poisoncfg_wr_poison_intr_clr_mask = `REGB_DDRC_CH0_MSK_POISONCFG_WR_POISON_INTR_CLR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_poisoncfg_rd_poison_slverr_en_mask;
   assign regb_ddrc_ch0_poisoncfg_rd_poison_slverr_en_mask = `REGB_DDRC_CH0_MSK_POISONCFG_RD_POISON_SLVERR_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_poisoncfg_rd_poison_intr_en_mask;
   assign regb_ddrc_ch0_poisoncfg_rd_poison_intr_en_mask = `REGB_DDRC_CH0_MSK_POISONCFG_RD_POISON_INTR_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_poisoncfg_rd_poison_intr_clr_mask;
   assign regb_ddrc_ch0_poisoncfg_rd_poison_intr_clr_mask = `REGB_DDRC_CH0_MSK_POISONCFG_RD_POISON_INTR_CLR;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_opctrl0_dis_wc_mask;
   assign regb_ddrc_ch0_opctrl0_dis_wc_mask = `REGB_DDRC_CH0_MSK_OPCTRL0_DIS_WC;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_opctrl1_dis_dq_mask;
   assign regb_ddrc_ch0_opctrl1_dis_dq_mask = `REGB_DDRC_CH0_MSK_OPCTRL1_DIS_DQ;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_opctrl1_dis_hif_mask;
   assign regb_ddrc_ch0_opctrl1_dis_hif_mask = `REGB_DDRC_CH0_MSK_OPCTRL1_DIS_HIF;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_opctrlcmd_zq_calib_short_mask;
   assign regb_ddrc_ch0_opctrlcmd_zq_calib_short_mask = `REGB_DDRC_CH0_MSK_OPCTRLCMD_ZQ_CALIB_SHORT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_opctrlcmd_ctrlupd_mask;
   assign regb_ddrc_ch0_opctrlcmd_ctrlupd_mask = `REGB_DDRC_CH0_MSK_OPCTRLCMD_CTRLUPD;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_oprefctrl0_rank0_refresh_mask;
   assign regb_ddrc_ch0_oprefctrl0_rank0_refresh_mask = `REGB_DDRC_CH0_MSK_OPREFCTRL0_RANK0_REFRESH;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_swctl_sw_done_mask;
   assign regb_ddrc_ch0_swctl_sw_done_mask = `REGB_DDRC_CH0_MSK_SWCTL_SW_DONE;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dbictl_dm_en_mask;
   assign regb_ddrc_ch0_dbictl_dm_en_mask = `REGB_DDRC_CH0_MSK_DBICTL_DM_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dbictl_wr_dbi_en_mask;
   assign regb_ddrc_ch0_dbictl_wr_dbi_en_mask = `REGB_DDRC_CH0_MSK_DBICTL_WR_DBI_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_dbictl_rd_dbi_en_mask;
   assign regb_ddrc_ch0_dbictl_rd_dbi_en_mask = `REGB_DDRC_CH0_MSK_DBICTL_RD_DBI_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_odtmap_rank0_wr_odt_mask;
   assign regb_ddrc_ch0_odtmap_rank0_wr_odt_mask = `REGB_DDRC_CH0_MSK_ODTMAP_RANK0_WR_ODT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_odtmap_rank0_rd_odt_mask;
   assign regb_ddrc_ch0_odtmap_rank0_rd_odt_mask = `REGB_DDRC_CH0_MSK_ODTMAP_RANK0_RD_ODT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_datactl0_rd_data_copy_en_mask;
   assign regb_ddrc_ch0_datactl0_rd_data_copy_en_mask = `REGB_DDRC_CH0_MSK_DATACTL0_RD_DATA_COPY_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_datactl0_wr_data_copy_en_mask;
   assign regb_ddrc_ch0_datactl0_wr_data_copy_en_mask = `REGB_DDRC_CH0_MSK_DATACTL0_WR_DATA_COPY_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_datactl0_wr_data_x_en_mask;
   assign regb_ddrc_ch0_datactl0_wr_data_x_en_mask = `REGB_DDRC_CH0_MSK_DATACTL0_WR_DATA_X_EN;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_swctlstatic_sw_static_unlock_mask;
   assign regb_ddrc_ch0_swctlstatic_sw_static_unlock_mask = `REGB_DDRC_CH0_MSK_SWCTLSTATIC_SW_STATIC_UNLOCK;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_inittmg0_pre_cke_x1024_mask;
   assign regb_ddrc_ch0_inittmg0_pre_cke_x1024_mask = `REGB_DDRC_CH0_MSK_INITTMG0_PRE_CKE_X1024;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_inittmg0_post_cke_x1024_mask;
   assign regb_ddrc_ch0_inittmg0_post_cke_x1024_mask = `REGB_DDRC_CH0_MSK_INITTMG0_POST_CKE_X1024;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_inittmg0_skip_dram_init_mask;
   assign regb_ddrc_ch0_inittmg0_skip_dram_init_mask = `REGB_DDRC_CH0_MSK_INITTMG0_SKIP_DRAM_INIT;
   wire [REG_WIDTH-1:0] regb_ddrc_ch0_inittmg1_dram_rstn_x1024_mask;
   assign regb_ddrc_ch0_inittmg1_dram_rstn_x1024_mask = `REGB_DDRC_CH0_MSK_INITTMG1_DRAM_RSTN_X1024;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap3_addrmap_bank_b0_mask;
   assign regb_addr_map0_addrmap3_addrmap_bank_b0_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP3_ADDRMAP_BANK_B0;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap3_addrmap_bank_b1_mask;
   assign regb_addr_map0_addrmap3_addrmap_bank_b1_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP3_ADDRMAP_BANK_B1;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap3_addrmap_bank_b2_mask;
   assign regb_addr_map0_addrmap3_addrmap_bank_b2_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP3_ADDRMAP_BANK_B2;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap4_addrmap_bg_b0_mask;
   assign regb_addr_map0_addrmap4_addrmap_bg_b0_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP4_ADDRMAP_BG_B0;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap4_addrmap_bg_b1_mask;
   assign regb_addr_map0_addrmap4_addrmap_bg_b1_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP4_ADDRMAP_BG_B1;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap5_addrmap_col_b7_mask;
   assign regb_addr_map0_addrmap5_addrmap_col_b7_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP5_ADDRMAP_COL_B7;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap5_addrmap_col_b8_mask;
   assign regb_addr_map0_addrmap5_addrmap_col_b8_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP5_ADDRMAP_COL_B8;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap5_addrmap_col_b9_mask;
   assign regb_addr_map0_addrmap5_addrmap_col_b9_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP5_ADDRMAP_COL_B9;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap5_addrmap_col_b10_mask;
   assign regb_addr_map0_addrmap5_addrmap_col_b10_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP5_ADDRMAP_COL_B10;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap6_addrmap_col_b3_mask;
   assign regb_addr_map0_addrmap6_addrmap_col_b3_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP6_ADDRMAP_COL_B3;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap6_addrmap_col_b4_mask;
   assign regb_addr_map0_addrmap6_addrmap_col_b4_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP6_ADDRMAP_COL_B4;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap6_addrmap_col_b5_mask;
   assign regb_addr_map0_addrmap6_addrmap_col_b5_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP6_ADDRMAP_COL_B5;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap6_addrmap_col_b6_mask;
   assign regb_addr_map0_addrmap6_addrmap_col_b6_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP6_ADDRMAP_COL_B6;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap7_addrmap_row_b14_mask;
   assign regb_addr_map0_addrmap7_addrmap_row_b14_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP7_ADDRMAP_ROW_B14;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap7_addrmap_row_b15_mask;
   assign regb_addr_map0_addrmap7_addrmap_row_b15_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP7_ADDRMAP_ROW_B15;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap7_addrmap_row_b16_mask;
   assign regb_addr_map0_addrmap7_addrmap_row_b16_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP7_ADDRMAP_ROW_B16;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap7_addrmap_row_b17_mask;
   assign regb_addr_map0_addrmap7_addrmap_row_b17_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP7_ADDRMAP_ROW_B17;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap8_addrmap_row_b10_mask;
   assign regb_addr_map0_addrmap8_addrmap_row_b10_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP8_ADDRMAP_ROW_B10;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap8_addrmap_row_b11_mask;
   assign regb_addr_map0_addrmap8_addrmap_row_b11_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP8_ADDRMAP_ROW_B11;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap8_addrmap_row_b12_mask;
   assign regb_addr_map0_addrmap8_addrmap_row_b12_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP8_ADDRMAP_ROW_B12;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap8_addrmap_row_b13_mask;
   assign regb_addr_map0_addrmap8_addrmap_row_b13_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP8_ADDRMAP_ROW_B13;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap9_addrmap_row_b6_mask;
   assign regb_addr_map0_addrmap9_addrmap_row_b6_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP9_ADDRMAP_ROW_B6;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap9_addrmap_row_b7_mask;
   assign regb_addr_map0_addrmap9_addrmap_row_b7_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP9_ADDRMAP_ROW_B7;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap9_addrmap_row_b8_mask;
   assign regb_addr_map0_addrmap9_addrmap_row_b8_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP9_ADDRMAP_ROW_B8;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap9_addrmap_row_b9_mask;
   assign regb_addr_map0_addrmap9_addrmap_row_b9_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP9_ADDRMAP_ROW_B9;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap10_addrmap_row_b2_mask;
   assign regb_addr_map0_addrmap10_addrmap_row_b2_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP10_ADDRMAP_ROW_B2;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap10_addrmap_row_b3_mask;
   assign regb_addr_map0_addrmap10_addrmap_row_b3_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP10_ADDRMAP_ROW_B3;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap10_addrmap_row_b4_mask;
   assign regb_addr_map0_addrmap10_addrmap_row_b4_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP10_ADDRMAP_ROW_B4;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap10_addrmap_row_b5_mask;
   assign regb_addr_map0_addrmap10_addrmap_row_b5_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP10_ADDRMAP_ROW_B5;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap11_addrmap_row_b0_mask;
   assign regb_addr_map0_addrmap11_addrmap_row_b0_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP11_ADDRMAP_ROW_B0;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap11_addrmap_row_b1_mask;
   assign regb_addr_map0_addrmap11_addrmap_row_b1_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP11_ADDRMAP_ROW_B1;
   wire [REG_WIDTH-1:0] regb_addr_map0_addrmap12_nonbinary_device_density_mask;
   assign regb_addr_map0_addrmap12_nonbinary_device_density_mask = `REGB_ADDR_MAP0_MSK_ADDRMAP12_NONBINARY_DEVICE_DENSITY;
   wire [REG_WIDTH-1:0] regb_arb_port0_pccfg_go2critical_en_mask;
   assign regb_arb_port0_pccfg_go2critical_en_mask = `REGB_ARB_PORT0_MSK_PCCFG_GO2CRITICAL_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pccfg_pagematch_limit_mask;
   assign regb_arb_port0_pccfg_pagematch_limit_mask = `REGB_ARB_PORT0_MSK_PCCFG_PAGEMATCH_LIMIT;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgr_rd_port_priority_mask;
   assign regb_arb_port0_pcfgr_rd_port_priority_mask = `REGB_ARB_PORT0_MSK_PCFGR_RD_PORT_PRIORITY;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgr_rd_port_aging_en_mask;
   assign regb_arb_port0_pcfgr_rd_port_aging_en_mask = `REGB_ARB_PORT0_MSK_PCFGR_RD_PORT_AGING_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgr_rd_port_urgent_en_mask;
   assign regb_arb_port0_pcfgr_rd_port_urgent_en_mask = `REGB_ARB_PORT0_MSK_PCFGR_RD_PORT_URGENT_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgr_rd_port_pagematch_en_mask;
   assign regb_arb_port0_pcfgr_rd_port_pagematch_en_mask = `REGB_ARB_PORT0_MSK_PCFGR_RD_PORT_PAGEMATCH_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgw_wr_port_priority_mask;
   assign regb_arb_port0_pcfgw_wr_port_priority_mask = `REGB_ARB_PORT0_MSK_PCFGW_WR_PORT_PRIORITY;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgw_wr_port_aging_en_mask;
   assign regb_arb_port0_pcfgw_wr_port_aging_en_mask = `REGB_ARB_PORT0_MSK_PCFGW_WR_PORT_AGING_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgw_wr_port_urgent_en_mask;
   assign regb_arb_port0_pcfgw_wr_port_urgent_en_mask = `REGB_ARB_PORT0_MSK_PCFGW_WR_PORT_URGENT_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgw_wr_port_pagematch_en_mask;
   assign regb_arb_port0_pcfgw_wr_port_pagematch_en_mask = `REGB_ARB_PORT0_MSK_PCFGW_WR_PORT_PAGEMATCH_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pctrl_port_en_mask;
   assign regb_arb_port0_pctrl_port_en_mask = `REGB_ARB_PORT0_MSK_PCTRL_PORT_EN;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgqos0_rqos_map_level1_mask;
   assign regb_arb_port0_pcfgqos0_rqos_map_level1_mask = `REGB_ARB_PORT0_MSK_PCFGQOS0_RQOS_MAP_LEVEL1;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgqos0_rqos_map_region0_mask;
   assign regb_arb_port0_pcfgqos0_rqos_map_region0_mask = `REGB_ARB_PORT0_MSK_PCFGQOS0_RQOS_MAP_REGION0;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgqos0_rqos_map_region1_mask;
   assign regb_arb_port0_pcfgqos0_rqos_map_region1_mask = `REGB_ARB_PORT0_MSK_PCFGQOS0_RQOS_MAP_REGION1;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgqos1_rqos_map_timeoutb_mask;
   assign regb_arb_port0_pcfgqos1_rqos_map_timeoutb_mask = `REGB_ARB_PORT0_MSK_PCFGQOS1_RQOS_MAP_TIMEOUTB;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgqos1_rqos_map_timeoutr_mask;
   assign regb_arb_port0_pcfgqos1_rqos_map_timeoutr_mask = `REGB_ARB_PORT0_MSK_PCFGQOS1_RQOS_MAP_TIMEOUTR;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos0_wqos_map_level1_mask;
   assign regb_arb_port0_pcfgwqos0_wqos_map_level1_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS0_WQOS_MAP_LEVEL1;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos0_wqos_map_level2_mask;
   assign regb_arb_port0_pcfgwqos0_wqos_map_level2_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS0_WQOS_MAP_LEVEL2;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos0_wqos_map_region0_mask;
   assign regb_arb_port0_pcfgwqos0_wqos_map_region0_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS0_WQOS_MAP_REGION0;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos0_wqos_map_region1_mask;
   assign regb_arb_port0_pcfgwqos0_wqos_map_region1_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS0_WQOS_MAP_REGION1;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos0_wqos_map_region2_mask;
   assign regb_arb_port0_pcfgwqos0_wqos_map_region2_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS0_WQOS_MAP_REGION2;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos1_wqos_map_timeout1_mask;
   assign regb_arb_port0_pcfgwqos1_wqos_map_timeout1_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS1_WQOS_MAP_TIMEOUT1;
   wire [REG_WIDTH-1:0] regb_arb_port0_pcfgwqos1_wqos_map_timeout2_mask;
   assign regb_arb_port0_pcfgwqos1_wqos_map_timeout2_mask = `REGB_ARB_PORT0_MSK_PCFGWQOS1_WQOS_MAP_TIMEOUT2;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg0_t_ras_min_mask;
   assign regb_freq0_ch0_dramset1tmg0_t_ras_min_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG0_T_RAS_MIN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg0_t_ras_max_mask;
   assign regb_freq0_ch0_dramset1tmg0_t_ras_max_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG0_T_RAS_MAX;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg0_t_faw_mask;
   assign regb_freq0_ch0_dramset1tmg0_t_faw_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG0_T_FAW;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg0_wr2pre_mask;
   assign regb_freq0_ch0_dramset1tmg0_wr2pre_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG0_WR2PRE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg1_t_rc_mask;
   assign regb_freq0_ch0_dramset1tmg1_t_rc_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG1_T_RC;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg1_rd2pre_mask;
   assign regb_freq0_ch0_dramset1tmg1_rd2pre_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG1_RD2PRE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg1_t_xp_mask;
   assign regb_freq0_ch0_dramset1tmg1_t_xp_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG1_T_XP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg2_wr2rd_mask;
   assign regb_freq0_ch0_dramset1tmg2_wr2rd_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG2_WR2RD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg2_rd2wr_mask;
   assign regb_freq0_ch0_dramset1tmg2_rd2wr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG2_RD2WR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg2_read_latency_mask;
   assign regb_freq0_ch0_dramset1tmg2_read_latency_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG2_READ_LATENCY;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg2_write_latency_mask;
   assign regb_freq0_ch0_dramset1tmg2_write_latency_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG2_WRITE_LATENCY;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg3_wr2mr_mask;
   assign regb_freq0_ch0_dramset1tmg3_wr2mr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG3_WR2MR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg3_rd2mr_mask;
   assign regb_freq0_ch0_dramset1tmg3_rd2mr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG3_RD2MR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg3_t_mr_mask;
   assign regb_freq0_ch0_dramset1tmg3_t_mr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG3_T_MR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg4_t_rp_mask;
   assign regb_freq0_ch0_dramset1tmg4_t_rp_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG4_T_RP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg4_t_rrd_mask;
   assign regb_freq0_ch0_dramset1tmg4_t_rrd_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG4_T_RRD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg4_t_ccd_mask;
   assign regb_freq0_ch0_dramset1tmg4_t_ccd_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG4_T_CCD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg4_t_rcd_mask;
   assign regb_freq0_ch0_dramset1tmg4_t_rcd_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG4_T_RCD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg5_t_cke_mask;
   assign regb_freq0_ch0_dramset1tmg5_t_cke_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG5_T_CKE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg5_t_ckesr_mask;
   assign regb_freq0_ch0_dramset1tmg5_t_ckesr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG5_T_CKESR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg5_t_cksre_mask;
   assign regb_freq0_ch0_dramset1tmg5_t_cksre_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG5_T_CKSRE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg5_t_cksrx_mask;
   assign regb_freq0_ch0_dramset1tmg5_t_cksrx_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG5_T_CKSRX;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg6_t_ckcsx_mask;
   assign regb_freq0_ch0_dramset1tmg6_t_ckcsx_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG6_T_CKCSX;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg7_t_csh_mask;
   assign regb_freq0_ch0_dramset1tmg7_t_csh_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG7_T_CSH;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg9_wr2rd_s_mask;
   assign regb_freq0_ch0_dramset1tmg9_wr2rd_s_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG9_WR2RD_S;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg9_t_rrd_s_mask;
   assign regb_freq0_ch0_dramset1tmg9_t_rrd_s_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG9_T_RRD_S;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg9_t_ccd_s_mask;
   assign regb_freq0_ch0_dramset1tmg9_t_ccd_s_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG9_T_CCD_S;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg12_t_cmdcke_mask;
   assign regb_freq0_ch0_dramset1tmg12_t_cmdcke_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG12_T_CMDCKE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg13_t_ppd_mask;
   assign regb_freq0_ch0_dramset1tmg13_t_ppd_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG13_T_PPD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg13_t_ccd_mw_mask;
   assign regb_freq0_ch0_dramset1tmg13_t_ccd_mw_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG13_T_CCD_MW;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg13_odtloff_mask;
   assign regb_freq0_ch0_dramset1tmg13_odtloff_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG13_ODTLOFF;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg14_t_xsr_mask;
   assign regb_freq0_ch0_dramset1tmg14_t_xsr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG14_T_XSR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg14_t_osco_mask;
   assign regb_freq0_ch0_dramset1tmg14_t_osco_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG14_T_OSCO;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg23_t_pdn_mask;
   assign regb_freq0_ch0_dramset1tmg23_t_pdn_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG23_T_PDN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg23_t_xsr_dsm_x1024_mask;
   assign regb_freq0_ch0_dramset1tmg23_t_xsr_dsm_x1024_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG23_T_XSR_DSM_X1024;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg24_max_wr_sync_mask;
   assign regb_freq0_ch0_dramset1tmg24_max_wr_sync_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG24_MAX_WR_SYNC;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg24_max_rd_sync_mask;
   assign regb_freq0_ch0_dramset1tmg24_max_rd_sync_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG24_MAX_RD_SYNC;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg24_rd2wr_s_mask;
   assign regb_freq0_ch0_dramset1tmg24_rd2wr_s_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG24_RD2WR_S;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg24_bank_org_mask;
   assign regb_freq0_ch0_dramset1tmg24_bank_org_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG24_BANK_ORG;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg25_rda2pre_mask;
   assign regb_freq0_ch0_dramset1tmg25_rda2pre_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG25_RDA2PRE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg25_wra2pre_mask;
   assign regb_freq0_ch0_dramset1tmg25_wra2pre_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG25_WRA2PRE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg25_lpddr4_diff_bank_rwa2pre_mask;
   assign regb_freq0_ch0_dramset1tmg25_lpddr4_diff_bank_rwa2pre_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg30_mrr2rd_mask;
   assign regb_freq0_ch0_dramset1tmg30_mrr2rd_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG30_MRR2RD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg30_mrr2wr_mask;
   assign regb_freq0_ch0_dramset1tmg30_mrr2wr_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG30_MRR2WR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dramset1tmg30_mrr2mrw_mask;
   assign regb_freq0_ch0_dramset1tmg30_mrr2mrw_mask = `REGB_FREQ0_CH0_MSK_DRAMSET1TMG30_MRR2MRW;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr0_emr_mask;
   assign regb_freq0_ch0_initmr0_emr_mask = `REGB_FREQ0_CH0_MSK_INITMR0_EMR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr0_mr_mask;
   assign regb_freq0_ch0_initmr0_mr_mask = `REGB_FREQ0_CH0_MSK_INITMR0_MR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr1_emr3_mask;
   assign regb_freq0_ch0_initmr1_emr3_mask = `REGB_FREQ0_CH0_MSK_INITMR1_EMR3;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr1_emr2_mask;
   assign regb_freq0_ch0_initmr1_emr2_mask = `REGB_FREQ0_CH0_MSK_INITMR1_EMR2;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr2_mr5_mask;
   assign regb_freq0_ch0_initmr2_mr5_mask = `REGB_FREQ0_CH0_MSK_INITMR2_MR5;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr2_mr4_mask;
   assign regb_freq0_ch0_initmr2_mr4_mask = `REGB_FREQ0_CH0_MSK_INITMR2_MR4;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr3_mr6_mask;
   assign regb_freq0_ch0_initmr3_mr6_mask = `REGB_FREQ0_CH0_MSK_INITMR3_MR6;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_initmr3_mr22_mask;
   assign regb_freq0_ch0_initmr3_mr22_mask = `REGB_FREQ0_CH0_MSK_INITMR3_MR22;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg0_dfi_tphy_wrlat_mask;
   assign regb_freq0_ch0_dfitmg0_dfi_tphy_wrlat_mask = `REGB_FREQ0_CH0_MSK_DFITMG0_DFI_TPHY_WRLAT;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg0_dfi_tphy_wrdata_mask;
   assign regb_freq0_ch0_dfitmg0_dfi_tphy_wrdata_mask = `REGB_FREQ0_CH0_MSK_DFITMG0_DFI_TPHY_WRDATA;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg0_dfi_t_rddata_en_mask;
   assign regb_freq0_ch0_dfitmg0_dfi_t_rddata_en_mask = `REGB_FREQ0_CH0_MSK_DFITMG0_DFI_T_RDDATA_EN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg0_dfi_t_ctrl_delay_mask;
   assign regb_freq0_ch0_dfitmg0_dfi_t_ctrl_delay_mask = `REGB_FREQ0_CH0_MSK_DFITMG0_DFI_T_CTRL_DELAY;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg1_dfi_t_dram_clk_enable_mask;
   assign regb_freq0_ch0_dfitmg1_dfi_t_dram_clk_enable_mask = `REGB_FREQ0_CH0_MSK_DFITMG1_DFI_T_DRAM_CLK_ENABLE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg1_dfi_t_dram_clk_disable_mask;
   assign regb_freq0_ch0_dfitmg1_dfi_t_dram_clk_disable_mask = `REGB_FREQ0_CH0_MSK_DFITMG1_DFI_T_DRAM_CLK_DISABLE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg1_dfi_t_wrdata_delay_mask;
   assign regb_freq0_ch0_dfitmg1_dfi_t_wrdata_delay_mask = `REGB_FREQ0_CH0_MSK_DFITMG1_DFI_T_WRDATA_DELAY;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg2_dfi_tphy_wrcslat_mask;
   assign regb_freq0_ch0_dfitmg2_dfi_tphy_wrcslat_mask = `REGB_FREQ0_CH0_MSK_DFITMG2_DFI_TPHY_WRCSLAT;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg2_dfi_tphy_rdcslat_mask;
   assign regb_freq0_ch0_dfitmg2_dfi_tphy_rdcslat_mask = `REGB_FREQ0_CH0_MSK_DFITMG2_DFI_TPHY_RDCSLAT;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg2_dfi_twck_delay_mask;
   assign regb_freq0_ch0_dfitmg2_dfi_twck_delay_mask = `REGB_FREQ0_CH0_MSK_DFITMG2_DFI_TWCK_DELAY;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg4_dfi_twck_dis_mask;
   assign regb_freq0_ch0_dfitmg4_dfi_twck_dis_mask = `REGB_FREQ0_CH0_MSK_DFITMG4_DFI_TWCK_DIS;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg4_dfi_twck_en_wr_mask;
   assign regb_freq0_ch0_dfitmg4_dfi_twck_en_wr_mask = `REGB_FREQ0_CH0_MSK_DFITMG4_DFI_TWCK_EN_WR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg4_dfi_twck_en_rd_mask;
   assign regb_freq0_ch0_dfitmg4_dfi_twck_en_rd_mask = `REGB_FREQ0_CH0_MSK_DFITMG4_DFI_TWCK_EN_RD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg5_dfi_twck_toggle_post_mask;
   assign regb_freq0_ch0_dfitmg5_dfi_twck_toggle_post_mask = `REGB_FREQ0_CH0_MSK_DFITMG5_DFI_TWCK_TOGGLE_POST;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg5_dfi_twck_toggle_cs_mask;
   assign regb_freq0_ch0_dfitmg5_dfi_twck_toggle_cs_mask = `REGB_FREQ0_CH0_MSK_DFITMG5_DFI_TWCK_TOGGLE_CS;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg5_dfi_twck_toggle_mask;
   assign regb_freq0_ch0_dfitmg5_dfi_twck_toggle_mask = `REGB_FREQ0_CH0_MSK_DFITMG5_DFI_TWCK_TOGGLE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfitmg5_dfi_twck_fast_toggle_mask;
   assign regb_freq0_ch0_dfitmg5_dfi_twck_fast_toggle_mask = `REGB_FREQ0_CH0_MSK_DFITMG5_DFI_TWCK_FAST_TOGGLE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_pd_mask;
   assign regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_pd_mask = `REGB_FREQ0_CH0_MSK_DFILPTMG0_DFI_LP_WAKEUP_PD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_sr_mask;
   assign regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_sr_mask = `REGB_FREQ0_CH0_MSK_DFILPTMG0_DFI_LP_WAKEUP_SR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_dsm_mask;
   assign regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_dsm_mask = `REGB_FREQ0_CH0_MSK_DFILPTMG0_DFI_LP_WAKEUP_DSM;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfilptmg1_dfi_lp_wakeup_data_mask;
   assign regb_freq0_ch0_dfilptmg1_dfi_lp_wakeup_data_mask = `REGB_FREQ0_CH0_MSK_DFILPTMG1_DFI_LP_WAKEUP_DATA;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfilptmg1_dfi_tlp_resp_mask;
   assign regb_freq0_ch0_dfilptmg1_dfi_tlp_resp_mask = `REGB_FREQ0_CH0_MSK_DFILPTMG1_DFI_TLP_RESP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfiupdtmg0_dfi_t_ctrlup_min_mask;
   assign regb_freq0_ch0_dfiupdtmg0_dfi_t_ctrlup_min_mask = `REGB_FREQ0_CH0_MSK_DFIUPDTMG0_DFI_T_CTRLUP_MIN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfiupdtmg0_dfi_t_ctrlup_max_mask;
   assign regb_freq0_ch0_dfiupdtmg0_dfi_t_ctrlup_max_mask = `REGB_FREQ0_CH0_MSK_DFIUPDTMG0_DFI_T_CTRLUP_MAX;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfiupdtmg1_dfi_t_ctrlupd_interval_max_x1024_mask;
   assign regb_freq0_ch0_dfiupdtmg1_dfi_t_ctrlupd_interval_max_x1024_mask = `REGB_FREQ0_CH0_MSK_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfiupdtmg1_dfi_t_ctrlupd_interval_min_x1024_mask;
   assign regb_freq0_ch0_dfiupdtmg1_dfi_t_ctrlupd_interval_min_x1024_mask = `REGB_FREQ0_CH0_MSK_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dfimsgtmg0_dfi_t_ctrlmsg_resp_mask;
   assign regb_freq0_ch0_dfimsgtmg0_dfi_t_ctrlmsg_resp_mask = `REGB_FREQ0_CH0_MSK_DFIMSGTMG0_DFI_T_CTRLMSG_RESP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg0_t_refi_x1_x32_mask;
   assign regb_freq0_ch0_rfshset1tmg0_t_refi_x1_x32_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG0_T_REFI_X1_X32;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg0_refresh_to_x1_x32_mask;
   assign regb_freq0_ch0_rfshset1tmg0_refresh_to_x1_x32_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG0_REFRESH_TO_X1_X32;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg0_refresh_margin_mask;
   assign regb_freq0_ch0_rfshset1tmg0_refresh_margin_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG0_REFRESH_MARGIN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg0_t_refi_x1_sel_mask;
   assign regb_freq0_ch0_rfshset1tmg0_t_refi_x1_sel_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG0_T_REFI_X1_SEL;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg1_t_rfc_min_mask;
   assign regb_freq0_ch0_rfshset1tmg1_t_rfc_min_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG1_T_RFC_MIN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg1_t_rfc_min_ab_mask;
   assign regb_freq0_ch0_rfshset1tmg1_t_rfc_min_ab_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG1_T_RFC_MIN_AB;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg2_t_pbr2pbr_mask;
   assign regb_freq0_ch0_rfshset1tmg2_t_pbr2pbr_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG2_T_PBR2PBR;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg2_t_pbr2act_mask;
   assign regb_freq0_ch0_rfshset1tmg2_t_pbr2act_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG2_T_PBR2ACT;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_rfshset1tmg3_refresh_to_ab_x32_mask;
   assign regb_freq0_ch0_rfshset1tmg3_refresh_to_ab_x32_mask = `REGB_FREQ0_CH0_MSK_RFSHSET1TMG3_REFRESH_TO_AB_X32;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_zqset1tmg0_t_zq_long_nop_mask;
   assign regb_freq0_ch0_zqset1tmg0_t_zq_long_nop_mask = `REGB_FREQ0_CH0_MSK_ZQSET1TMG0_T_ZQ_LONG_NOP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_zqset1tmg0_t_zq_short_nop_mask;
   assign regb_freq0_ch0_zqset1tmg0_t_zq_short_nop_mask = `REGB_FREQ0_CH0_MSK_ZQSET1TMG0_T_ZQ_SHORT_NOP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_zqset1tmg1_t_zq_short_interval_x1024_mask;
   assign regb_freq0_ch0_zqset1tmg1_t_zq_short_interval_x1024_mask = `REGB_FREQ0_CH0_MSK_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_zqset1tmg1_t_zq_reset_nop_mask;
   assign regb_freq0_ch0_zqset1tmg1_t_zq_reset_nop_mask = `REGB_FREQ0_CH0_MSK_ZQSET1TMG1_T_ZQ_RESET_NOP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dqsoscctl0_dqsosc_enable_mask;
   assign regb_freq0_ch0_dqsoscctl0_dqsosc_enable_mask = `REGB_FREQ0_CH0_MSK_DQSOSCCTL0_DQSOSC_ENABLE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dqsoscctl0_dqsosc_interval_unit_mask;
   assign regb_freq0_ch0_dqsoscctl0_dqsosc_interval_unit_mask = `REGB_FREQ0_CH0_MSK_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_dqsoscctl0_dqsosc_interval_mask;
   assign regb_freq0_ch0_dqsoscctl0_dqsosc_interval_mask = `REGB_FREQ0_CH0_MSK_DQSOSCCTL0_DQSOSC_INTERVAL;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_derateint_mr4_read_interval_mask;
   assign regb_freq0_ch0_derateint_mr4_read_interval_mask = `REGB_FREQ0_CH0_MSK_DERATEINT_MR4_READ_INTERVAL;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_derateval0_derated_t_rrd_mask;
   assign regb_freq0_ch0_derateval0_derated_t_rrd_mask = `REGB_FREQ0_CH0_MSK_DERATEVAL0_DERATED_T_RRD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_derateval0_derated_t_rp_mask;
   assign regb_freq0_ch0_derateval0_derated_t_rp_mask = `REGB_FREQ0_CH0_MSK_DERATEVAL0_DERATED_T_RP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_derateval0_derated_t_ras_min_mask;
   assign regb_freq0_ch0_derateval0_derated_t_ras_min_mask = `REGB_FREQ0_CH0_MSK_DERATEVAL0_DERATED_T_RAS_MIN;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_derateval0_derated_t_rcd_mask;
   assign regb_freq0_ch0_derateval0_derated_t_rcd_mask = `REGB_FREQ0_CH0_MSK_DERATEVAL0_DERATED_T_RCD;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_derateval1_derated_t_rc_mask;
   assign regb_freq0_ch0_derateval1_derated_t_rc_mask = `REGB_FREQ0_CH0_MSK_DERATEVAL1_DERATED_T_RC;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_hwlptmg0_hw_lp_idle_x32_mask;
   assign regb_freq0_ch0_hwlptmg0_hw_lp_idle_x32_mask = `REGB_FREQ0_CH0_MSK_HWLPTMG0_HW_LP_IDLE_X32;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_schedtmg0_pageclose_timer_mask;
   assign regb_freq0_ch0_schedtmg0_pageclose_timer_mask = `REGB_FREQ0_CH0_MSK_SCHEDTMG0_PAGECLOSE_TIMER;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_schedtmg0_rdwr_idle_gap_mask;
   assign regb_freq0_ch0_schedtmg0_rdwr_idle_gap_mask = `REGB_FREQ0_CH0_MSK_SCHEDTMG0_RDWR_IDLE_GAP;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_perfhpr1_hpr_max_starve_mask;
   assign regb_freq0_ch0_perfhpr1_hpr_max_starve_mask = `REGB_FREQ0_CH0_MSK_PERFHPR1_HPR_MAX_STARVE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_perfhpr1_hpr_xact_run_length_mask;
   assign regb_freq0_ch0_perfhpr1_hpr_xact_run_length_mask = `REGB_FREQ0_CH0_MSK_PERFHPR1_HPR_XACT_RUN_LENGTH;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_perflpr1_lpr_max_starve_mask;
   assign regb_freq0_ch0_perflpr1_lpr_max_starve_mask = `REGB_FREQ0_CH0_MSK_PERFLPR1_LPR_MAX_STARVE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_perflpr1_lpr_xact_run_length_mask;
   assign regb_freq0_ch0_perflpr1_lpr_xact_run_length_mask = `REGB_FREQ0_CH0_MSK_PERFLPR1_LPR_XACT_RUN_LENGTH;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_perfwr1_w_max_starve_mask;
   assign regb_freq0_ch0_perfwr1_w_max_starve_mask = `REGB_FREQ0_CH0_MSK_PERFWR1_W_MAX_STARVE;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_perfwr1_w_xact_run_length_mask;
   assign regb_freq0_ch0_perfwr1_w_xact_run_length_mask = `REGB_FREQ0_CH0_MSK_PERFWR1_W_XACT_RUN_LENGTH;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_tmgcfg_frequency_ratio_mask;
   assign regb_freq0_ch0_tmgcfg_frequency_ratio_mask = `REGB_FREQ0_CH0_MSK_TMGCFG_FREQUENCY_RATIO;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_pwrtmg_powerdown_to_x32_mask;
   assign regb_freq0_ch0_pwrtmg_powerdown_to_x32_mask = `REGB_FREQ0_CH0_MSK_PWRTMG_POWERDOWN_TO_X32;
   wire [REG_WIDTH-1:0] regb_freq0_ch0_pwrtmg_selfref_to_x32_mask;
   assign regb_freq0_ch0_pwrtmg_selfref_to_x32_mask = `REGB_FREQ0_CH0_MSK_PWRTMG_SELFREF_TO_X32;

   reg ff_regb_ddrc_ch0_lpddr4;
   reg ff_regb_ddrc_ch0_lpddr5;
   reg ff_regb_ddrc_ch0_en_2t_timing_mode;
   reg [`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH-1:0] ff_regb_ddrc_ch0_data_bus_width;
   reg [`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR-1:0] ff_regb_ddrc_ch0_burst_rdwr;
   reg ff_regb_ddrc_ch0_wck_on;
   reg ff_regb_ddrc_ch0_wck_suspend_en;
   reg ff_regb_ddrc_ch0_ws_off_en;
   reg ff_regb_ddrc_ch0_mr_type;
   reg ff_regb_ddrc_ch0_sw_init_int;
   reg [`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK-1:0] ff_regb_ddrc_ch0_mr_rank;
   reg [`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR-1:0] ff_regb_ddrc_ch0_mr_addr;
   reg ff_regb_ddrc_ch0_mrr_done_clr;
   reg ff_regb_ddrc_ch0_mr_wr_todo;
   reg ff_regb_ddrc_ch0_mr_wr;
   reg [`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA-1:0] ff_regb_ddrc_ch0_mr_data;
   reg ff_regb_ddrc_ch0_derate_enable;
   reg ff_regb_ddrc_ch0_lpddr4_refresh_mode;
   reg ff_regb_ddrc_ch0_derate_mr4_pause_fc;
   reg ff_regb_ddrc_ch0_dis_trefi_x6x8;
   reg ff_regb_ddrc_ch0_dis_trefi_x0125;
   reg [`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0-1:0] ff_regb_ddrc_ch0_active_derate_byte_rank0;
   reg cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_en;
   reg cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_clr;
   reg cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_force;
   reg cfgs_ff_regb_ddrc_ch0_derate_mr4_tuf_dis;
   reg [`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL-1:0] ff_regb_ddrc_ch0_dbg_mr4_grp_sel;
   reg [`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL-1:0] ff_regb_ddrc_ch0_dbg_mr4_rank_sel;
   reg [`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN-1:0] ff_regb_ddrc_ch0_selfref_en;
   reg [`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN-1:0] ff_regb_ddrc_ch0_powerdown_en;
   reg ff_regb_ddrc_ch0_en_dfi_dram_clk_disable;
   reg ff_regb_ddrc_ch0_selfref_sw;
   reg ff_regb_ddrc_ch0_stay_in_selfref;
   reg ff_regb_ddrc_ch0_dis_cam_drain_selfref;
   reg ff_regb_ddrc_ch0_lpddr4_sr_allowed;
   reg ff_regb_ddrc_ch0_dsm_en;
   reg cfgs_ff_regb_ddrc_ch0_hw_lp_en;
   reg cfgs_ff_regb_ddrc_ch0_hw_lp_exit_idle_en;
   reg [`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON-1:0] ff_regb_ddrc_ch0_bsm_clk_on;
   reg [`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST-1:0] ff_regb_ddrc_ch0_refresh_burst;
   reg [`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN-1:0] ff_regb_ddrc_ch0_auto_refab_en;
   reg ff_regb_ddrc_ch0_per_bank_refresh;
   reg ff_regb_ddrc_ch0_dis_auto_refresh;
   reg ff_regb_ddrc_ch0_refresh_update_level;
   reg ff_regb_ddrc_ch0_zq_resistor_shared;
   reg ff_regb_ddrc_ch0_dis_auto_zq;
   reg ff_regb_ddrc_ch0_zq_reset_todo;
   reg ff_regb_ddrc_ch0_zq_reset;
   reg cfgs_ff_regb_ddrc_ch0_dis_srx_zqcl;
   reg [`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME-1:0] cfgs_ff_regb_ddrc_ch0_dqsosc_runtime;
   reg [`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME-1:0] cfgs_ff_regb_ddrc_ch0_wck2dqo_runtime;
   reg cfgs_ff_regb_ddrc_ch0_dis_dqsosc_srx;
   reg cfgs_ff_regb_ddrc_ch0_prefer_write;
   reg cfgs_ff_regb_ddrc_ch0_pageclose;
   reg cfgs_ff_regb_ddrc_ch0_opt_wrcam_fill_level;
   reg cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_act;
   reg cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_pre;
   reg cfgs_ff_regb_ddrc_ch0_autopre_rmw;
   reg [`REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES-1:0] cfgs_ff_regb_ddrc_ch0_lpr_num_entries;
   reg cfgs_ff_regb_ddrc_ch0_lpddr4_opt_act_timing;
   reg cfgs_ff_regb_ddrc_ch0_lpddr5_opt_act_timing;
   reg cfgs_ff_regb_ddrc_ch0_prefer_read;
   reg cfgs_ff_regb_ddrc_ch0_dis_speculative_act;
   reg [`REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE-1:0] cfgs_ff_regb_ddrc_ch0_delay_switch_write;
   reg [`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR-1:0] cfgs_ff_regb_ddrc_ch0_page_hit_limit_wr;
   reg [`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD-1:0] cfgs_ff_regb_ddrc_ch0_page_hit_limit_rd;
   reg cfgs_ff_regb_ddrc_ch0_opt_hit_gt_hpr;
   reg [`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH-1:0] cfgs_ff_regb_ddrc_ch0_wrcam_lowthresh;
   reg [`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH-1:0] cfgs_ff_regb_ddrc_ch0_wrcam_highthresh;
   reg [`REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH-1:0] cfgs_ff_regb_ddrc_ch0_wr_pghit_num_thresh;
   reg [`REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH-1:0] cfgs_ff_regb_ddrc_ch0_rd_pghit_num_thresh;
   reg [`REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP-1:0] cfgs_ff_regb_ddrc_ch0_rd_act_idle_gap;
   reg [`REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP-1:0] cfgs_ff_regb_ddrc_ch0_wr_act_idle_gap;
   reg [`REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES-1:0] cfgs_ff_regb_ddrc_ch0_rd_page_exp_cycles;
   reg [`REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES-1:0] cfgs_ff_regb_ddrc_ch0_wr_page_exp_cycles;
   reg ff_regb_ddrc_ch0_dfi_lp_en_pd;
   reg ff_regb_ddrc_ch0_dfi_lp_en_sr;
   reg ff_regb_ddrc_ch0_dfi_lp_en_dsm;
   reg ff_regb_ddrc_ch0_dfi_lp_en_data;
   reg ff_regb_ddrc_ch0_dfi_lp_data_req_en;
   reg ff_regb_ddrc_ch0_dfi_phyupd_en;
   reg ff_regb_ddrc_ch0_ctrlupd_pre_srx;
   reg ff_regb_ddrc_ch0_dis_auto_ctrlupd_srx;
   reg ff_regb_ddrc_ch0_dis_auto_ctrlupd;
   reg ff_regb_ddrc_ch0_dfi_init_complete_en;
   reg ff_regb_ddrc_ch0_phy_dbi_mode;
   reg ff_regb_ddrc_ch0_dfi_data_cs_polarity;
   reg ff_regb_ddrc_ch0_dfi_init_start;
   reg ff_regb_ddrc_ch0_lp_optimized_write;
   reg [`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY-1:0] ff_regb_ddrc_ch0_dfi_frequency;
   reg [`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP-1:0] ff_regb_ddrc_ch0_dfi_freq_fsp;
   reg [`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE-1:0] ff_regb_ddrc_ch0_dfi_channel_mode;
   reg ff_regb_ddrc_ch0_dfi_phymstr_en;
   reg [`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32-1:0] ff_regb_ddrc_ch0_dfi_phymstr_blk_ref_x32;
   reg [`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA-1:0] ff_regb_ddrc_ch0_dfi0_ctrlmsg_data;
   reg [`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD-1:0] ff_regb_ddrc_ch0_dfi0_ctrlmsg_cmd;
   reg ff_regb_ddrc_ch0_dfi0_ctrlmsg_tout_clr;
   reg ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_todo;
   reg ff_regb_ddrc_ch0_dfi0_ctrlmsg_req;
   reg ff_regb_ddrc_ch0_wr_poison_slverr_en;
   reg ff_regb_ddrc_ch0_wr_poison_intr_en;
   reg ff_regb_ddrc_ch0_wr_poison_intr_clr;
   reg ff_regb_ddrc_ch0_rd_poison_slverr_en;
   reg ff_regb_ddrc_ch0_rd_poison_intr_en;
   reg ff_regb_ddrc_ch0_rd_poison_intr_clr;
   reg cfgs_ff_regb_ddrc_ch0_dis_wc;
   reg ff_regb_ddrc_ch0_dis_dq;
   reg ff_regb_ddrc_ch0_dis_hif;
   reg ff_regb_ddrc_ch0_zq_calib_short_todo;
   reg ff_regb_ddrc_ch0_zq_calib_short;
   reg ff_regb_ddrc_ch0_ctrlupd_todo;
   reg ff_regb_ddrc_ch0_ctrlupd;
   reg ff_regb_ddrc_ch0_rank0_refresh_todo;
   reg ff_regb_ddrc_ch0_rank0_refresh;
   reg cfgs_ff_regb_ddrc_ch0_sw_done;
   reg ff_regb_ddrc_ch0_dm_en;
   reg ff_regb_ddrc_ch0_wr_dbi_en;
   reg ff_regb_ddrc_ch0_rd_dbi_en;
   reg [`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT-1:0] cfgs_ff_regb_ddrc_ch0_rank0_wr_odt;
   reg [`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT-1:0] cfgs_ff_regb_ddrc_ch0_rank0_rd_odt;
   reg ff_regb_ddrc_ch0_rd_data_copy_en;
   reg ff_regb_ddrc_ch0_wr_data_copy_en;
   reg ff_regb_ddrc_ch0_wr_data_x_en;
   reg cfgs_ff_regb_ddrc_ch0_sw_static_unlock;
   reg [`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024-1:0] ff_regb_ddrc_ch0_pre_cke_x1024;
   reg [`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024-1:0] ff_regb_ddrc_ch0_post_cke_x1024;
   reg [`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT-1:0] ff_regb_ddrc_ch0_skip_dram_init;
   reg [`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024-1:0] ff_regb_ddrc_ch0_dram_rstn_x1024;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0-1:0] cfgs_ff_regb_addr_map0_addrmap_bank_b0;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1-1:0] cfgs_ff_regb_addr_map0_addrmap_bank_b1;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2-1:0] cfgs_ff_regb_addr_map0_addrmap_bank_b2;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0-1:0] cfgs_ff_regb_addr_map0_addrmap_bg_b0;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1-1:0] cfgs_ff_regb_addr_map0_addrmap_bg_b1;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b7;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b8;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b9;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b10;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b3;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b4;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b5;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6-1:0] cfgs_ff_regb_addr_map0_addrmap_col_b6;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b14;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b15;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b16;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b17;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b10;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b11;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b12;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b13;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b6;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b7;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b8;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b9;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b2;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b3;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b4;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b5;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b0;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1-1:0] cfgs_ff_regb_addr_map0_addrmap_row_b1;
   reg [`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY-1:0] ff_regb_addr_map0_nonbinary_device_density;
   reg cfgs_ff_regb_arb_port0_go2critical_en;
   reg cfgs_ff_regb_arb_port0_pagematch_limit;
   reg [`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY-1:0] cfgs_ff_regb_arb_port0_rd_port_priority;
   reg cfgs_ff_regb_arb_port0_rd_port_aging_en;
   reg cfgs_ff_regb_arb_port0_rd_port_urgent_en;
   reg cfgs_ff_regb_arb_port0_rd_port_pagematch_en;
   reg [`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY-1:0] cfgs_ff_regb_arb_port0_wr_port_priority;
   reg cfgs_ff_regb_arb_port0_wr_port_aging_en;
   reg cfgs_ff_regb_arb_port0_wr_port_urgent_en;
   reg cfgs_ff_regb_arb_port0_wr_port_pagematch_en;
   reg ff_regb_arb_port0_port_en;
   reg [`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1-1:0] cfgs_ff_regb_arb_port0_rqos_map_level1;
   reg [`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0-1:0] cfgs_ff_regb_arb_port0_rqos_map_region0;
   reg [`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1-1:0] cfgs_ff_regb_arb_port0_rqos_map_region1;
   reg [`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB-1:0] cfgs_ff_regb_arb_port0_rqos_map_timeoutb;
   reg [`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR-1:0] cfgs_ff_regb_arb_port0_rqos_map_timeoutr;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1-1:0] cfgs_ff_regb_arb_port0_wqos_map_level1;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2-1:0] cfgs_ff_regb_arb_port0_wqos_map_level2;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0-1:0] cfgs_ff_regb_arb_port0_wqos_map_region0;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1-1:0] cfgs_ff_regb_arb_port0_wqos_map_region1;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2-1:0] cfgs_ff_regb_arb_port0_wqos_map_region2;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1-1:0] cfgs_ff_regb_arb_port0_wqos_map_timeout1;
   reg [`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2-1:0] cfgs_ff_regb_arb_port0_wqos_map_timeout2;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN-1:0] cfgs_ff_regb_freq0_ch0_t_ras_min;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX-1:0] cfgs_ff_regb_freq0_ch0_t_ras_max;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW-1:0] cfgs_ff_regb_freq0_ch0_t_faw;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE-1:0] cfgs_ff_regb_freq0_ch0_wr2pre;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC-1:0] cfgs_ff_regb_freq0_ch0_t_rc;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE-1:0] cfgs_ff_regb_freq0_ch0_rd2pre;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP-1:0] cfgs_ff_regb_freq0_ch0_t_xp;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD-1:0] cfgs_ff_regb_freq0_ch0_wr2rd;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR-1:0] cfgs_ff_regb_freq0_ch0_rd2wr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY-1:0] cfgs_ff_regb_freq0_ch0_read_latency;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY-1:0] cfgs_ff_regb_freq0_ch0_write_latency;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR-1:0] cfgs_ff_regb_freq0_ch0_wr2mr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR-1:0] cfgs_ff_regb_freq0_ch0_rd2mr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR-1:0] cfgs_ff_regb_freq0_ch0_t_mr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP-1:0] cfgs_ff_regb_freq0_ch0_t_rp;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD-1:0] cfgs_ff_regb_freq0_ch0_t_rrd;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD-1:0] cfgs_ff_regb_freq0_ch0_t_ccd;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD-1:0] cfgs_ff_regb_freq0_ch0_t_rcd;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE-1:0] ff_regb_freq0_ch0_t_cke;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR-1:0] ff_regb_freq0_ch0_t_ckesr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE-1:0] ff_regb_freq0_ch0_t_cksre;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX-1:0] ff_regb_freq0_ch0_t_cksrx;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX-1:0] cfgs_ff_regb_freq0_ch0_t_ckcsx;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH-1:0] ff_regb_freq0_ch0_t_csh;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S-1:0] cfgs_ff_regb_freq0_ch0_wr2rd_s;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S-1:0] cfgs_ff_regb_freq0_ch0_t_rrd_s;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S-1:0] cfgs_ff_regb_freq0_ch0_t_ccd_s;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE-1:0] cfgs_ff_regb_freq0_ch0_t_cmdcke;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD-1:0] cfgs_ff_regb_freq0_ch0_t_ppd;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW-1:0] cfgs_ff_regb_freq0_ch0_t_ccd_mw;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF-1:0] cfgs_ff_regb_freq0_ch0_odtloff;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR-1:0] cfgs_ff_regb_freq0_ch0_t_xsr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO-1:0] cfgs_ff_regb_freq0_ch0_t_osco;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN-1:0] ff_regb_freq0_ch0_t_pdn;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024-1:0] ff_regb_freq0_ch0_t_xsr_dsm_x1024;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC-1:0] cfgs_ff_regb_freq0_ch0_max_wr_sync;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC-1:0] cfgs_ff_regb_freq0_ch0_max_rd_sync;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S-1:0] cfgs_ff_regb_freq0_ch0_rd2wr_s;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG-1:0] cfgs_ff_regb_freq0_ch0_bank_org;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE-1:0] cfgs_ff_regb_freq0_ch0_rda2pre;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE-1:0] cfgs_ff_regb_freq0_ch0_wra2pre;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE-1:0] cfgs_ff_regb_freq0_ch0_lpddr4_diff_bank_rwa2pre;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD-1:0] ff_regb_freq0_ch0_mrr2rd;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR-1:0] ff_regb_freq0_ch0_mrr2wr;
   reg [`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW-1:0] ff_regb_freq0_ch0_mrr2mrw;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR0_EMR-1:0] cfgs_ff_regb_freq0_ch0_emr;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR0_MR-1:0] cfgs_ff_regb_freq0_ch0_mr;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3-1:0] ff_regb_freq0_ch0_emr3;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2-1:0] ff_regb_freq0_ch0_emr2;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR2_MR5-1:0] cfgs_ff_regb_freq0_ch0_mr5;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR2_MR4-1:0] cfgs_ff_regb_freq0_ch0_mr4;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR3_MR6-1:0] cfgs_ff_regb_freq0_ch0_mr6;
   reg [`REGB_FREQ0_CH0_SIZE_INITMR3_MR22-1:0] cfgs_ff_regb_freq0_ch0_mr22;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT-1:0] ff_regb_freq0_ch0_dfi_tphy_wrlat;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA-1:0] ff_regb_freq0_ch0_dfi_tphy_wrdata;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN-1:0] ff_regb_freq0_ch0_dfi_t_rddata_en;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY-1:0] ff_regb_freq0_ch0_dfi_t_ctrl_delay;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE-1:0] ff_regb_freq0_ch0_dfi_t_dram_clk_enable;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE-1:0] ff_regb_freq0_ch0_dfi_t_dram_clk_disable;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY-1:0] ff_regb_freq0_ch0_dfi_t_wrdata_delay;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT-1:0] cfgs_ff_regb_freq0_ch0_dfi_tphy_wrcslat;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT-1:0] cfgs_ff_regb_freq0_ch0_dfi_tphy_rdcslat;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_delay;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_dis;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_en_wr;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_en_rd;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_post;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_cs;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_toggle;
   reg [`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE-1:0] cfgs_ff_regb_freq0_ch0_dfi_twck_fast_toggle;
   reg [`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD-1:0] ff_regb_freq0_ch0_dfi_lp_wakeup_pd;
   reg [`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR-1:0] ff_regb_freq0_ch0_dfi_lp_wakeup_sr;
   reg [`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM-1:0] ff_regb_freq0_ch0_dfi_lp_wakeup_dsm;
   reg [`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA-1:0] ff_regb_freq0_ch0_dfi_lp_wakeup_data;
   reg [`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP-1:0] ff_regb_freq0_ch0_dfi_tlp_resp;
   reg [`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN-1:0] ff_regb_freq0_ch0_dfi_t_ctrlup_min;
   reg [`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX-1:0] ff_regb_freq0_ch0_dfi_t_ctrlup_max;
   reg [`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024-1:0] cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_max_x1024;
   reg [`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024-1:0] cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_min_x1024;
   reg [`REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP-1:0] cfgs_ff_regb_freq0_ch0_dfi_t_ctrlmsg_resp;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32-1:0] ff_regb_freq0_ch0_t_refi_x1_x32;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32-1:0] ff_regb_freq0_ch0_refresh_to_x1_x32;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN-1:0] ff_regb_freq0_ch0_refresh_margin;
   reg ff_regb_freq0_ch0_t_refi_x1_sel;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN-1:0] ff_regb_freq0_ch0_t_rfc_min;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB-1:0] ff_regb_freq0_ch0_t_rfc_min_ab;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR-1:0] ff_regb_freq0_ch0_t_pbr2pbr;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT-1:0] ff_regb_freq0_ch0_t_pbr2act;
   reg [`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32-1:0] ff_regb_freq0_ch0_refresh_to_ab_x32;
   reg [`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP-1:0] ff_regb_freq0_ch0_t_zq_long_nop;
   reg [`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP-1:0] ff_regb_freq0_ch0_t_zq_short_nop;
   reg [`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024-1:0] cfgs_ff_regb_freq0_ch0_t_zq_short_interval_x1024;
   reg [`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP-1:0] cfgs_ff_regb_freq0_ch0_t_zq_reset_nop;
   reg ff_regb_freq0_ch0_dqsosc_enable;
   reg ff_regb_freq0_ch0_dqsosc_interval_unit;
   reg [`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL-1:0] ff_regb_freq0_ch0_dqsosc_interval;
   reg [`REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL-1:0] cfgs_ff_regb_freq0_ch0_mr4_read_interval;
   reg [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD-1:0] ff_regb_freq0_ch0_derated_t_rrd;
   reg [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP-1:0] ff_regb_freq0_ch0_derated_t_rp;
   reg [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN-1:0] ff_regb_freq0_ch0_derated_t_ras_min;
   reg [`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD-1:0] ff_regb_freq0_ch0_derated_t_rcd;
   reg [`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC-1:0] ff_regb_freq0_ch0_derated_t_rc;
   reg [`REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32-1:0] cfgs_ff_regb_freq0_ch0_hw_lp_idle_x32;
   reg [`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER-1:0] cfgs_ff_regb_freq0_ch0_pageclose_timer;
   reg [`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP-1:0] cfgs_ff_regb_freq0_ch0_rdwr_idle_gap;
   reg [`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE-1:0] cfgs_ff_regb_freq0_ch0_hpr_max_starve;
   reg [`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH-1:0] cfgs_ff_regb_freq0_ch0_hpr_xact_run_length;
   reg [`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE-1:0] cfgs_ff_regb_freq0_ch0_lpr_max_starve;
   reg [`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH-1:0] cfgs_ff_regb_freq0_ch0_lpr_xact_run_length;
   reg [`REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE-1:0] cfgs_ff_regb_freq0_ch0_w_max_starve;
   reg [`REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH-1:0] cfgs_ff_regb_freq0_ch0_w_xact_run_length;
   reg ff_regb_freq0_ch0_frequency_ratio;
   reg [`REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32-1:0] cfgs_ff_regb_freq0_ch0_powerdown_to_x32;
   reg [`REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32-1:0] cfgs_ff_regb_freq0_ch0_selfref_to_x32;



   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
   always_comb begin : r0_mstr0_combo_PROC
      r0_mstr0 = {REG_WIDTH {1'b0}};
      r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4] = ff_regb_ddrc_ch0_lpddr4;
      r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5+:`REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5] = ff_regb_ddrc_ch0_lpddr5;
      r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE+:`REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE] = ff_regb_ddrc_ch0_en_2t_timing_mode;
      r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH+:`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH] = ff_regb_ddrc_ch0_data_bus_width[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH) -1:0];
      r0_mstr0[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR+:`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR] = ff_regb_ddrc_ch0_burst_rdwr[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
   always_comb begin : r4_mstr4_combo_PROC
      r4_mstr4 = {REG_WIDTH {1'b0}};
      r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_ON+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_ON] = ff_regb_ddrc_ch0_wck_on;
      r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_SUSPEND_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WCK_SUSPEND_EN] = ff_regb_ddrc_ch0_wck_suspend_en;
      r4_mstr4[`REGB_DDRC_CH0_OFFSET_MSTR4_WS_OFF_EN+:`REGB_DDRC_CH0_SIZE_MSTR4_WS_OFF_EN] = ff_regb_ddrc_ch0_ws_off_en;
   end
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
   always_comb begin : r8_mrctrl0_combo_PROC
      r8_mrctrl0 = {REG_WIDTH {1'b0}};
      r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_TYPE+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_TYPE] = ff_regb_ddrc_ch0_mr_type;
      r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_SW_INIT_INT+:`REGB_DDRC_CH0_SIZE_MRCTRL0_SW_INIT_INT] = ff_regb_ddrc_ch0_sw_init_int;
      r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_RANK+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK] = ff_regb_ddrc_ch0_mr_rank[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK) -1:0];
      r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_ADDR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR] = ff_regb_ddrc_ch0_mr_addr[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR) -1:0];
      r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MRR_DONE_CLR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MRR_DONE_CLR] = ff_regb_ddrc_ch0_mrr_done_clr;
      r8_mrctrl0[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_WR+:`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_WR] = ff_regb_ddrc_ch0_mr_wr;
   end
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
   always_comb begin : r9_mrctrl1_combo_PROC
      r9_mrctrl1 = {REG_WIDTH {1'b0}};
      r9_mrctrl1[`REGB_DDRC_CH0_OFFSET_MRCTRL1_MR_DATA+:`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA] = ff_regb_ddrc_ch0_mr_data[(`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
   always_comb begin : r14_deratectl0_combo_PROC
      r14_deratectl0 = {REG_WIDTH {1'b0}};
      r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_ENABLE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_ENABLE] = ff_regb_ddrc_ch0_derate_enable;
      r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_LPDDR4_REFRESH_MODE+:`REGB_DDRC_CH0_SIZE_DERATECTL0_LPDDR4_REFRESH_MODE] = ff_regb_ddrc_ch0_lpddr4_refresh_mode;
      r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_MR4_PAUSE_FC+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_MR4_PAUSE_FC] = ff_regb_ddrc_ch0_derate_mr4_pause_fc;
      r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X6X8+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X6X8] = ff_regb_ddrc_ch0_dis_trefi_x6x8;
      r14_deratectl0[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X0125+:`REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X0125] = ff_regb_ddrc_ch0_dis_trefi_x0125;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
   always_comb begin : r15_deratectl1_combo_PROC
      r15_deratectl1 = {REG_WIDTH {1'b0}};
      r15_deratectl1[`REGB_DDRC_CH0_OFFSET_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0+:`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0] = ff_regb_ddrc_ch0_active_derate_byte_rank0[(`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
   always_comb begin : r19_deratectl5_combo_PROC
      r19_deratectl5 = {REG_WIDTH {1'b0}};
      r19_deratectl5[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN+:`REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN] = cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_en;
      r19_deratectl5[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR+:`REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR] = cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_clr;
      r19_deratectl5[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE+:`REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE] = cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_force;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
   always_comb begin : r20_deratectl6_combo_PROC
      r20_deratectl6 = {REG_WIDTH {1'b0}};
      r20_deratectl6[`REGB_DDRC_CH0_OFFSET_DERATECTL6_DERATE_MR4_TUF_DIS+:`REGB_DDRC_CH0_SIZE_DERATECTL6_DERATE_MR4_TUF_DIS] = cfgs_ff_regb_ddrc_ch0_derate_mr4_tuf_dis;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
   always_comb begin : r23_deratedbgctl_combo_PROC
      r23_deratedbgctl = {REG_WIDTH {1'b0}};
      r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_GRP_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL] = ff_regb_ddrc_ch0_dbg_mr4_grp_sel[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL) -1:0];
      r23_deratedbgctl[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_RANK_SEL+:`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL] = ff_regb_ddrc_ch0_dbg_mr4_rank_sel[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
   always_comb begin : r25_pwrctl_combo_PROC
      r25_pwrctl = {REG_WIDTH {1'b0}};
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN] = ff_regb_ddrc_ch0_selfref_en[(`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN) -1:0];
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_POWERDOWN_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN] = ff_regb_ddrc_ch0_powerdown_en[(`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN) -1:0];
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE+:`REGB_DDRC_CH0_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE] = ff_regb_ddrc_ch0_en_dfi_dram_clk_disable;
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_SW+:`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_SW] = ff_regb_ddrc_ch0_selfref_sw;
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_STAY_IN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_STAY_IN_SELFREF] = ff_regb_ddrc_ch0_stay_in_selfref;
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF+:`REGB_DDRC_CH0_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF] = ff_regb_ddrc_ch0_dis_cam_drain_selfref;
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_LPDDR4_SR_ALLOWED+:`REGB_DDRC_CH0_SIZE_PWRCTL_LPDDR4_SR_ALLOWED] = ff_regb_ddrc_ch0_lpddr4_sr_allowed;
      r25_pwrctl[`REGB_DDRC_CH0_OFFSET_PWRCTL_DSM_EN+:`REGB_DDRC_CH0_SIZE_PWRCTL_DSM_EN] = ff_regb_ddrc_ch0_dsm_en;
   end
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
   always_comb begin : r26_hwlpctl_combo_PROC
      r26_hwlpctl = {REG_WIDTH {1'b0}};
      r26_hwlpctl[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EN+:`REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EN] = cfgs_ff_regb_ddrc_ch0_hw_lp_en;
      r26_hwlpctl[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN+:`REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN] = cfgs_ff_regb_ddrc_ch0_hw_lp_exit_idle_en;
   end
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
   always_comb begin : r28_clkgatectl_combo_PROC
      r28_clkgatectl = {REG_WIDTH {1'b0}};
      r28_clkgatectl[`REGB_DDRC_CH0_OFFSET_CLKGATECTL_BSM_CLK_ON+:`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON] = ff_regb_ddrc_ch0_bsm_clk_on[(`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
   always_comb begin : r29_rfshmod0_combo_PROC
      r29_rfshmod0 = {REG_WIDTH {1'b0}};
      r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_REFRESH_BURST+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST] = ff_regb_ddrc_ch0_refresh_burst[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST) -1:0];
      r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_AUTO_REFAB_EN+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN] = ff_regb_ddrc_ch0_auto_refab_en[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN) -1:0];
      r29_rfshmod0[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_PER_BANK_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHMOD0_PER_BANK_REFRESH] = ff_regb_ddrc_ch0_per_bank_refresh;
   end
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
   always_comb begin : r31_rfshctl0_combo_PROC
      r31_rfshctl0 = {REG_WIDTH {1'b0}};
      r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_DIS_AUTO_REFRESH+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_DIS_AUTO_REFRESH] = ff_regb_ddrc_ch0_dis_auto_refresh;
      r31_rfshctl0[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_REFRESH_UPDATE_LEVEL+:`REGB_DDRC_CH0_SIZE_RFSHCTL0_REFRESH_UPDATE_LEVEL] = ff_regb_ddrc_ch0_refresh_update_level;
   end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
   always_comb begin : r34_zqctl0_combo_PROC
      r34_zqctl0 = {REG_WIDTH {1'b0}};
      r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED+:`REGB_DDRC_CH0_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED] = ff_regb_ddrc_ch0_zq_resistor_shared;
      r34_zqctl0[`REGB_DDRC_CH0_OFFSET_ZQCTL0_DIS_AUTO_ZQ+:`REGB_DDRC_CH0_SIZE_ZQCTL0_DIS_AUTO_ZQ] = ff_regb_ddrc_ch0_dis_auto_zq;
   end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
   always_comb begin : r35_zqctl1_combo_PROC
      r35_zqctl1 = {REG_WIDTH {1'b0}};
      r35_zqctl1[`REGB_DDRC_CH0_OFFSET_ZQCTL1_ZQ_RESET+:`REGB_DDRC_CH0_SIZE_ZQCTL1_ZQ_RESET] = ff_regb_ddrc_ch0_zq_reset;
   end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
   always_comb begin : r36_zqctl2_combo_PROC
      r36_zqctl2 = {REG_WIDTH {1'b0}};
      r36_zqctl2[`REGB_DDRC_CH0_OFFSET_ZQCTL2_DIS_SRX_ZQCL+:`REGB_DDRC_CH0_SIZE_ZQCTL2_DIS_SRX_ZQCL] = cfgs_ff_regb_ddrc_ch0_dis_srx_zqcl;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
   always_comb begin : r38_dqsoscruntime_combo_PROC
      r38_dqsoscruntime = {REG_WIDTH {1'b0}};
      r38_dqsoscruntime[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_DQSOSC_RUNTIME+:`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME] = cfgs_ff_regb_ddrc_ch0_dqsosc_runtime[(`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME) -1:0];
      r38_dqsoscruntime[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_WCK2DQO_RUNTIME+:`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME] = cfgs_ff_regb_ddrc_ch0_wck2dqo_runtime[(`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
   always_comb begin : r40_dqsosccfg0_combo_PROC
      r40_dqsosccfg0 = {REG_WIDTH {1'b0}};
      r40_dqsosccfg0[`REGB_DDRC_CH0_OFFSET_DQSOSCCFG0_DIS_DQSOSC_SRX+:`REGB_DDRC_CH0_SIZE_DQSOSCCFG0_DIS_DQSOSC_SRX] = cfgs_ff_regb_ddrc_ch0_dis_dqsosc_srx;
   end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
   always_comb begin : r42_sched0_combo_PROC
      r42_sched0 = {REG_WIDTH {1'b0}};
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_WRITE+:`REGB_DDRC_CH0_SIZE_SCHED0_PREFER_WRITE] = cfgs_ff_regb_ddrc_ch0_prefer_write;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_PAGECLOSE+:`REGB_DDRC_CH0_SIZE_SCHED0_PAGECLOSE] = cfgs_ff_regb_ddrc_ch0_pageclose;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_OPT_WRCAM_FILL_LEVEL+:`REGB_DDRC_CH0_SIZE_SCHED0_OPT_WRCAM_FILL_LEVEL] = cfgs_ff_regb_ddrc_ch0_opt_wrcam_fill_level;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_ACT+:`REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_ACT] = cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_act;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_PRE+:`REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_PRE] = cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_pre;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_AUTOPRE_RMW+:`REGB_DDRC_CH0_SIZE_SCHED0_AUTOPRE_RMW] = cfgs_ff_regb_ddrc_ch0_autopre_rmw;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_LPR_NUM_ENTRIES+:`REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES] = cfgs_ff_regb_ddrc_ch0_lpr_num_entries[(`REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES) -1:0];
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR4_OPT_ACT_TIMING+:`REGB_DDRC_CH0_SIZE_SCHED0_LPDDR4_OPT_ACT_TIMING] = cfgs_ff_regb_ddrc_ch0_lpddr4_opt_act_timing;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR5_OPT_ACT_TIMING+:`REGB_DDRC_CH0_SIZE_SCHED0_LPDDR5_OPT_ACT_TIMING] = cfgs_ff_regb_ddrc_ch0_lpddr5_opt_act_timing;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_READ+:`REGB_DDRC_CH0_SIZE_SCHED0_PREFER_READ] = cfgs_ff_regb_ddrc_ch0_prefer_read;
      r42_sched0[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_SPECULATIVE_ACT+:`REGB_DDRC_CH0_SIZE_SCHED0_DIS_SPECULATIVE_ACT] = cfgs_ff_regb_ddrc_ch0_dis_speculative_act;
   end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
   always_comb begin : r43_sched1_combo_PROC
      r43_sched1 = {REG_WIDTH {1'b0}};
      r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_DELAY_SWITCH_WRITE+:`REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE] = cfgs_ff_regb_ddrc_ch0_delay_switch_write[(`REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE) -1:0];
      r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_WR+:`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR] = cfgs_ff_regb_ddrc_ch0_page_hit_limit_wr[(`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR) -1:0];
      r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_RD+:`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD] = cfgs_ff_regb_ddrc_ch0_page_hit_limit_rd[(`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD) -1:0];
      r43_sched1[`REGB_DDRC_CH0_OFFSET_SCHED1_OPT_HIT_GT_HPR+:`REGB_DDRC_CH0_SIZE_SCHED1_OPT_HIT_GT_HPR] = cfgs_ff_regb_ddrc_ch0_opt_hit_gt_hpr;
   end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
   always_comb begin : r45_sched3_combo_PROC
      r45_sched3 = {REG_WIDTH {1'b0}};
      r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_LOWTHRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH] = cfgs_ff_regb_ddrc_ch0_wrcam_lowthresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH) -1:0];
      r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_HIGHTHRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH] = cfgs_ff_regb_ddrc_ch0_wrcam_highthresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH) -1:0];
      r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_WR_PGHIT_NUM_THRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH] = cfgs_ff_regb_ddrc_ch0_wr_pghit_num_thresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH) -1:0];
      r45_sched3[`REGB_DDRC_CH0_OFFSET_SCHED3_RD_PGHIT_NUM_THRESH+:`REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH] = cfgs_ff_regb_ddrc_ch0_rd_pghit_num_thresh[(`REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
   always_comb begin : r46_sched4_combo_PROC
      r46_sched4 = {REG_WIDTH {1'b0}};
      r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_ACT_IDLE_GAP+:`REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP] = cfgs_ff_regb_ddrc_ch0_rd_act_idle_gap[(`REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP) -1:0];
      r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_ACT_IDLE_GAP+:`REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP] = cfgs_ff_regb_ddrc_ch0_wr_act_idle_gap[(`REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP) -1:0];
      r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_PAGE_EXP_CYCLES+:`REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES] = cfgs_ff_regb_ddrc_ch0_rd_page_exp_cycles[(`REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES) -1:0];
      r46_sched4[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_PAGE_EXP_CYCLES+:`REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES] = cfgs_ff_regb_ddrc_ch0_wr_page_exp_cycles[(`REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
   always_comb begin : r56_dfilpcfg0_combo_PROC
      r56_dfilpcfg0 = {REG_WIDTH {1'b0}};
      r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_PD+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_PD] = ff_regb_ddrc_ch0_dfi_lp_en_pd;
      r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_SR+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_SR] = ff_regb_ddrc_ch0_dfi_lp_en_sr;
      r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DSM+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DSM] = ff_regb_ddrc_ch0_dfi_lp_en_dsm;
      r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DATA+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DATA] = ff_regb_ddrc_ch0_dfi_lp_en_data;
      r56_dfilpcfg0[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_DATA_REQ_EN+:`REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_DATA_REQ_EN] = ff_regb_ddrc_ch0_dfi_lp_data_req_en;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
   always_comb begin : r57_dfiupd0_combo_PROC
      r57_dfiupd0 = {REG_WIDTH {1'b0}};
      r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DFI_PHYUPD_EN+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DFI_PHYUPD_EN] = ff_regb_ddrc_ch0_dfi_phyupd_en;
      r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_CTRLUPD_PRE_SRX] = ff_regb_ddrc_ch0_ctrlupd_pre_srx;
      r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX] = ff_regb_ddrc_ch0_dis_auto_ctrlupd_srx;
      r57_dfiupd0[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD+:`REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD] = ff_regb_ddrc_ch0_dis_auto_ctrlupd;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
   always_comb begin : r59_dfimisc_combo_PROC
      r59_dfimisc = {REG_WIDTH {1'b0}};
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN] = ff_regb_ddrc_ch0_dfi_init_complete_en;
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_PHY_DBI_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_PHY_DBI_MODE] = ff_regb_ddrc_ch0_phy_dbi_mode;
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_DATA_CS_POLARITY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_DATA_CS_POLARITY] = ff_regb_ddrc_ch0_dfi_data_cs_polarity;
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_START+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_START] = ff_regb_ddrc_ch0_dfi_init_start;
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_LP_OPTIMIZED_WRITE+:`REGB_DDRC_CH0_SIZE_DFIMISC_LP_OPTIMIZED_WRITE] = ff_regb_ddrc_ch0_lp_optimized_write;
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQUENCY+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY] = ff_regb_ddrc_ch0_dfi_frequency[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY) -1:0];
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQ_FSP+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP] = ff_regb_ddrc_ch0_dfi_freq_fsp[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP) -1:0];
      r59_dfimisc[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_CHANNEL_MODE+:`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE] = ff_regb_ddrc_ch0_dfi_channel_mode[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
   always_comb begin : r61_dfiphymstr_combo_PROC
      r61_dfiphymstr = {REG_WIDTH {1'b0}};
      r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN] = ff_regb_ddrc_ch0_dfi_phymstr_en;
      r61_dfiphymstr[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32+:`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32] = ff_regb_ddrc_ch0_dfi_phymstr_blk_ref_x32[(`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
   always_comb begin : r62_dfi0msgctl0_combo_PROC
      r62_dfi0msgctl0 = {REG_WIDTH {1'b0}};
      r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_DATA+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA] = ff_regb_ddrc_ch0_dfi0_ctrlmsg_data[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA) -1:0];
      r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_CMD+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD] = ff_regb_ddrc_ch0_dfi0_ctrlmsg_cmd[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD) -1:0];
      r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR] = ff_regb_ddrc_ch0_dfi0_ctrlmsg_tout_clr;
      r62_dfi0msgctl0[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_REQ+:`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_REQ] = ff_regb_ddrc_ch0_dfi0_ctrlmsg_req;
   end
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
   always_comb begin : r64_poisoncfg_combo_PROC
      r64_poisoncfg = {REG_WIDTH {1'b0}};
      r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_SLVERR_EN] = ff_regb_ddrc_ch0_wr_poison_slverr_en;
      r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_EN] = ff_regb_ddrc_ch0_wr_poison_intr_en;
      r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_CLR+:`REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_CLR] = ff_regb_ddrc_ch0_wr_poison_intr_clr;
      r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_SLVERR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_SLVERR_EN] = ff_regb_ddrc_ch0_rd_poison_slverr_en;
      r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_EN+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_EN] = ff_regb_ddrc_ch0_rd_poison_intr_en;
      r64_poisoncfg[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_CLR+:`REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_CLR] = ff_regb_ddrc_ch0_rd_poison_intr_clr;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
   always_comb begin : r215_opctrl0_combo_PROC
      r215_opctrl0 = {REG_WIDTH {1'b0}};
      r215_opctrl0[`REGB_DDRC_CH0_OFFSET_OPCTRL0_DIS_WC+:`REGB_DDRC_CH0_SIZE_OPCTRL0_DIS_WC] = cfgs_ff_regb_ddrc_ch0_dis_wc;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
   always_comb begin : r216_opctrl1_combo_PROC
      r216_opctrl1 = {REG_WIDTH {1'b0}};
      r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_DQ+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_DQ] = ff_regb_ddrc_ch0_dis_dq;
      r216_opctrl1[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_HIF+:`REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_HIF] = ff_regb_ddrc_ch0_dis_hif;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
   always_comb begin : r218_opctrlcmd_combo_PROC
      r218_opctrlcmd = {REG_WIDTH {1'b0}};
      r218_opctrlcmd[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_ZQ_CALIB_SHORT+:`REGB_DDRC_CH0_SIZE_OPCTRLCMD_ZQ_CALIB_SHORT] = ff_regb_ddrc_ch0_zq_calib_short;
      r218_opctrlcmd[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_CTRLUPD+:`REGB_DDRC_CH0_SIZE_OPCTRLCMD_CTRLUPD] = ff_regb_ddrc_ch0_ctrlupd;
   end
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
   always_comb begin : r221_oprefctrl0_combo_PROC
      r221_oprefctrl0 = {REG_WIDTH {1'b0}};
      r221_oprefctrl0[`REGB_DDRC_CH0_OFFSET_OPREFCTRL0_RANK0_REFRESH+:`REGB_DDRC_CH0_SIZE_OPREFCTRL0_RANK0_REFRESH] = ff_regb_ddrc_ch0_rank0_refresh;
   end
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
   always_comb begin : r225_swctl_combo_PROC
      r225_swctl = {REG_WIDTH {1'b0}};
      r225_swctl[`REGB_DDRC_CH0_OFFSET_SWCTL_SW_DONE+:`REGB_DDRC_CH0_SIZE_SWCTL_SW_DONE] = cfgs_ff_regb_ddrc_ch0_sw_done;
   end
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
   always_comb begin : r230_dbictl_combo_PROC
      r230_dbictl = {REG_WIDTH {1'b0}};
      r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_DM_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_DM_EN] = ff_regb_ddrc_ch0_dm_en;
      r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_WR_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_WR_DBI_EN] = ff_regb_ddrc_ch0_wr_dbi_en;
      r230_dbictl[`REGB_DDRC_CH0_OFFSET_DBICTL_RD_DBI_EN+:`REGB_DDRC_CH0_SIZE_DBICTL_RD_DBI_EN] = ff_regb_ddrc_ch0_rd_dbi_en;
   end
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
   always_comb begin : r232_odtmap_combo_PROC
      r232_odtmap = {REG_WIDTH {1'b0}};
      r232_odtmap[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_WR_ODT+:`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT] = cfgs_ff_regb_ddrc_ch0_rank0_wr_odt[(`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT) -1:0];
      r232_odtmap[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_RD_ODT+:`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT] = cfgs_ff_regb_ddrc_ch0_rank0_rd_odt[(`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
   always_comb begin : r233_datactl0_combo_PROC
      r233_datactl0 = {REG_WIDTH {1'b0}};
      r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_RD_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_RD_DATA_COPY_EN] = ff_regb_ddrc_ch0_rd_data_copy_en;
      r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_COPY_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_COPY_EN] = ff_regb_ddrc_ch0_wr_data_copy_en;
      r233_datactl0[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_X_EN+:`REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_X_EN] = ff_regb_ddrc_ch0_wr_data_x_en;
   end
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
   always_comb begin : r234_swctlstatic_combo_PROC
      r234_swctlstatic = {REG_WIDTH {1'b0}};
      r234_swctlstatic[`REGB_DDRC_CH0_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK+:`REGB_DDRC_CH0_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK] = cfgs_ff_regb_ddrc_ch0_sw_static_unlock;
   end
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
   always_comb begin : r235_inittmg0_combo_PROC
      r235_inittmg0 = {REG_WIDTH {1'b0}};
      r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_PRE_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024] = ff_regb_ddrc_ch0_pre_cke_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024) -1:0];
      r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_POST_CKE_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024] = ff_regb_ddrc_ch0_post_cke_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024) -1:0];
      r235_inittmg0[`REGB_DDRC_CH0_OFFSET_INITTMG0_SKIP_DRAM_INIT+:`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT] = ff_regb_ddrc_ch0_skip_dram_init[(`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT) -1:0];
   end
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
   always_comb begin : r236_inittmg1_combo_PROC
      r236_inittmg1 = {REG_WIDTH {1'b0}};
      r236_inittmg1[`REGB_DDRC_CH0_OFFSET_INITTMG1_DRAM_RSTN_X1024+:`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024] = ff_regb_ddrc_ch0_dram_rstn_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
   always_comb begin : r450_addrmap3_map0_combo_PROC
      r450_addrmap3_map0 = {REG_WIDTH {1'b0}};
      r450_addrmap3_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B0+:`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0] = cfgs_ff_regb_addr_map0_addrmap_bank_b0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0) -1:0];
      r450_addrmap3_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B1+:`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1] = cfgs_ff_regb_addr_map0_addrmap_bank_b1[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1) -1:0];
      r450_addrmap3_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B2+:`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2] = cfgs_ff_regb_addr_map0_addrmap_bank_b2[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
   always_comb begin : r451_addrmap4_map0_combo_PROC
      r451_addrmap4_map0 = {REG_WIDTH {1'b0}};
      r451_addrmap4_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B0+:`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0] = cfgs_ff_regb_addr_map0_addrmap_bg_b0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0) -1:0];
      r451_addrmap4_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B1+:`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1] = cfgs_ff_regb_addr_map0_addrmap_bg_b1[(`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
   always_comb begin : r452_addrmap5_map0_combo_PROC
      r452_addrmap5_map0 = {REG_WIDTH {1'b0}};
      r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B7+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7] = cfgs_ff_regb_addr_map0_addrmap_col_b7[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7) -1:0];
      r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B8+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8] = cfgs_ff_regb_addr_map0_addrmap_col_b8[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8) -1:0];
      r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B9+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9] = cfgs_ff_regb_addr_map0_addrmap_col_b9[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9) -1:0];
      r452_addrmap5_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B10+:`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10] = cfgs_ff_regb_addr_map0_addrmap_col_b10[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
   always_comb begin : r453_addrmap6_map0_combo_PROC
      r453_addrmap6_map0 = {REG_WIDTH {1'b0}};
      r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B3+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3] = cfgs_ff_regb_addr_map0_addrmap_col_b3[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3) -1:0];
      r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B4+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4] = cfgs_ff_regb_addr_map0_addrmap_col_b4[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4) -1:0];
      r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B5+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5] = cfgs_ff_regb_addr_map0_addrmap_col_b5[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5) -1:0];
      r453_addrmap6_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B6+:`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6] = cfgs_ff_regb_addr_map0_addrmap_col_b6[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
   always_comb begin : r454_addrmap7_map0_combo_PROC
      r454_addrmap7_map0 = {REG_WIDTH {1'b0}};
      r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B14+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14] = cfgs_ff_regb_addr_map0_addrmap_row_b14[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14) -1:0];
      r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B15+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15] = cfgs_ff_regb_addr_map0_addrmap_row_b15[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15) -1:0];
      r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16] = cfgs_ff_regb_addr_map0_addrmap_row_b16[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16) -1:0];
      r454_addrmap7_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17+:`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17] = cfgs_ff_regb_addr_map0_addrmap_row_b17[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
   always_comb begin : r455_addrmap8_map0_combo_PROC
      r455_addrmap8_map0 = {REG_WIDTH {1'b0}};
      r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B10+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10] = cfgs_ff_regb_addr_map0_addrmap_row_b10[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10) -1:0];
      r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B11+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11] = cfgs_ff_regb_addr_map0_addrmap_row_b11[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11) -1:0];
      r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B12+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12] = cfgs_ff_regb_addr_map0_addrmap_row_b12[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12) -1:0];
      r455_addrmap8_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B13+:`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13] = cfgs_ff_regb_addr_map0_addrmap_row_b13[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
   always_comb begin : r456_addrmap9_map0_combo_PROC
      r456_addrmap9_map0 = {REG_WIDTH {1'b0}};
      r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B6+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6] = cfgs_ff_regb_addr_map0_addrmap_row_b6[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6) -1:0];
      r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B7+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7] = cfgs_ff_regb_addr_map0_addrmap_row_b7[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7) -1:0];
      r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B8+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8] = cfgs_ff_regb_addr_map0_addrmap_row_b8[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8) -1:0];
      r456_addrmap9_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B9+:`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9] = cfgs_ff_regb_addr_map0_addrmap_row_b9[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
   always_comb begin : r457_addrmap10_map0_combo_PROC
      r457_addrmap10_map0 = {REG_WIDTH {1'b0}};
      r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B2+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2] = cfgs_ff_regb_addr_map0_addrmap_row_b2[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2) -1:0];
      r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B3+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3] = cfgs_ff_regb_addr_map0_addrmap_row_b3[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3) -1:0];
      r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B4+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4] = cfgs_ff_regb_addr_map0_addrmap_row_b4[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4) -1:0];
      r457_addrmap10_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B5+:`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5] = cfgs_ff_regb_addr_map0_addrmap_row_b5[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
   always_comb begin : r458_addrmap11_map0_combo_PROC
      r458_addrmap11_map0 = {REG_WIDTH {1'b0}};
      r458_addrmap11_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B0+:`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0] = cfgs_ff_regb_addr_map0_addrmap_row_b0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0) -1:0];
      r458_addrmap11_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B1+:`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1] = cfgs_ff_regb_addr_map0_addrmap_row_b1[(`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1) -1:0];
   end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
   always_comb begin : r459_addrmap12_map0_combo_PROC
      r459_addrmap12_map0 = {REG_WIDTH {1'b0}};
      r459_addrmap12_map0[`REGB_ADDR_MAP0_OFFSET_ADDRMAP12_NONBINARY_DEVICE_DENSITY+:`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY] = ff_regb_addr_map0_nonbinary_device_density[(`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY) -1:0];
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
   always_comb begin : r474_pccfg_port0_combo_PROC
      r474_pccfg_port0 = {REG_WIDTH {1'b0}};
      r474_pccfg_port0[`REGB_ARB_PORT0_OFFSET_PCCFG_GO2CRITICAL_EN+:`REGB_ARB_PORT0_SIZE_PCCFG_GO2CRITICAL_EN] = cfgs_ff_regb_arb_port0_go2critical_en;
      r474_pccfg_port0[`REGB_ARB_PORT0_OFFSET_PCCFG_PAGEMATCH_LIMIT+:`REGB_ARB_PORT0_SIZE_PCCFG_PAGEMATCH_LIMIT] = cfgs_ff_regb_arb_port0_pagematch_limit;
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
   always_comb begin : r475_pcfgr_port0_combo_PROC
      r475_pcfgr_port0 = {REG_WIDTH {1'b0}};
      r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PRIORITY+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY] = cfgs_ff_regb_arb_port0_rd_port_priority[(`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY) -1:0];
      r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_AGING_EN+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_AGING_EN] = cfgs_ff_regb_arb_port0_rd_port_aging_en;
      r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_URGENT_EN+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_URGENT_EN] = cfgs_ff_regb_arb_port0_rd_port_urgent_en;
      r475_pcfgr_port0[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PAGEMATCH_EN+:`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PAGEMATCH_EN] = cfgs_ff_regb_arb_port0_rd_port_pagematch_en;
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
   always_comb begin : r476_pcfgw_port0_combo_PROC
      r476_pcfgw_port0 = {REG_WIDTH {1'b0}};
      r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PRIORITY+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY] = cfgs_ff_regb_arb_port0_wr_port_priority[(`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY) -1:0];
      r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_AGING_EN+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_AGING_EN] = cfgs_ff_regb_arb_port0_wr_port_aging_en;
      r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_URGENT_EN+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_URGENT_EN] = cfgs_ff_regb_arb_port0_wr_port_urgent_en;
      r476_pcfgw_port0[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PAGEMATCH_EN+:`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PAGEMATCH_EN] = cfgs_ff_regb_arb_port0_wr_port_pagematch_en;
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
   always_comb begin : r509_pctrl_port0_combo_PROC
      r509_pctrl_port0 = {REG_WIDTH {1'b0}};
      r509_pctrl_port0[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN+:`REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN] = ff_regb_arb_port0_port_en;
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
   always_comb begin : r510_pcfgqos0_port0_combo_PROC
      r510_pcfgqos0_port0 = {REG_WIDTH {1'b0}};
      r510_pcfgqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_LEVEL1+:`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1] = cfgs_ff_regb_arb_port0_rqos_map_level1[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1) -1:0];
      r510_pcfgqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION0+:`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0] = cfgs_ff_regb_arb_port0_rqos_map_region0[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0) -1:0];
      r510_pcfgqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION1+:`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1] = cfgs_ff_regb_arb_port0_rqos_map_region1[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1) -1:0];
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
   always_comb begin : r511_pcfgqos1_port0_combo_PROC
      r511_pcfgqos1_port0 = {REG_WIDTH {1'b0}};
      r511_pcfgqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTB+:`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB] = cfgs_ff_regb_arb_port0_rqos_map_timeoutb[(`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB) -1:0];
      r511_pcfgqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTR+:`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR] = cfgs_ff_regb_arb_port0_rqos_map_timeoutr[(`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR) -1:0];
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
   always_comb begin : r512_pcfgwqos0_port0_combo_PROC
      r512_pcfgwqos0_port0 = {REG_WIDTH {1'b0}};
      r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL1+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1] = cfgs_ff_regb_arb_port0_wqos_map_level1[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1) -1:0];
      r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL2+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2] = cfgs_ff_regb_arb_port0_wqos_map_level2[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2) -1:0];
      r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION0+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0] = cfgs_ff_regb_arb_port0_wqos_map_region0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0) -1:0];
      r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION1+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1] = cfgs_ff_regb_arb_port0_wqos_map_region1[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1) -1:0];
      r512_pcfgwqos0_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION2+:`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2] = cfgs_ff_regb_arb_port0_wqos_map_region2[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2) -1:0];
   end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
   always_comb begin : r513_pcfgwqos1_port0_combo_PROC
      r513_pcfgwqos1_port0 = {REG_WIDTH {1'b0}};
      r513_pcfgwqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT1+:`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1] = cfgs_ff_regb_arb_port0_wqos_map_timeout1[(`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1) -1:0];
      r513_pcfgwqos1_port0[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT2+:`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2] = cfgs_ff_regb_arb_port0_wqos_map_timeout2[(`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
   always_comb begin : r1882_dramset1tmg0_freq0_combo_PROC
      r1882_dramset1tmg0_freq0 = {REG_WIDTH {1'b0}};
      r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MIN+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN] = cfgs_ff_regb_freq0_ch0_t_ras_min[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN) -1:0];
      r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MAX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX] = cfgs_ff_regb_freq0_ch0_t_ras_max[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX) -1:0];
      r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_FAW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW] = cfgs_ff_regb_freq0_ch0_t_faw[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW) -1:0];
      r1882_dramset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_WR2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE] = cfgs_ff_regb_freq0_ch0_wr2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
   always_comb begin : r1883_dramset1tmg1_freq0_combo_PROC
      r1883_dramset1tmg1_freq0 = {REG_WIDTH {1'b0}};
      r1883_dramset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_RC+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC] = cfgs_ff_regb_freq0_ch0_t_rc[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC) -1:0];
      r1883_dramset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_RD2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE] = cfgs_ff_regb_freq0_ch0_rd2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE) -1:0];
      r1883_dramset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_XP+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP] = cfgs_ff_regb_freq0_ch0_t_xp[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
   always_comb begin : r1884_dramset1tmg2_freq0_combo_PROC
      r1884_dramset1tmg2_freq0 = {REG_WIDTH {1'b0}};
      r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WR2RD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD] = cfgs_ff_regb_freq0_ch0_wr2rd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD) -1:0];
      r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_RD2WR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR] = cfgs_ff_regb_freq0_ch0_rd2wr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR) -1:0];
      r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_READ_LATENCY+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY] = cfgs_ff_regb_freq0_ch0_read_latency[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY) -1:0];
      r1884_dramset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WRITE_LATENCY+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY] = cfgs_ff_regb_freq0_ch0_write_latency[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
   always_comb begin : r1885_dramset1tmg3_freq0_combo_PROC
      r1885_dramset1tmg3_freq0 = {REG_WIDTH {1'b0}};
      r1885_dramset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_WR2MR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR] = cfgs_ff_regb_freq0_ch0_wr2mr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR) -1:0];
      r1885_dramset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_RD2MR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR] = cfgs_ff_regb_freq0_ch0_rd2mr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR) -1:0];
      r1885_dramset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_T_MR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR] = cfgs_ff_regb_freq0_ch0_t_mr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
   always_comb begin : r1886_dramset1tmg4_freq0_combo_PROC
      r1886_dramset1tmg4_freq0 = {REG_WIDTH {1'b0}};
      r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RP+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP] = cfgs_ff_regb_freq0_ch0_t_rp[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP) -1:0];
      r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RRD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD] = cfgs_ff_regb_freq0_ch0_t_rrd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD) -1:0];
      r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_CCD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD] = cfgs_ff_regb_freq0_ch0_t_ccd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD) -1:0];
      r1886_dramset1tmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RCD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD] = cfgs_ff_regb_freq0_ch0_t_rcd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
   always_comb begin : r1887_dramset1tmg5_freq0_combo_PROC
      r1887_dramset1tmg5_freq0 = {REG_WIDTH {1'b0}};
      r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE] = ff_regb_freq0_ch0_t_cke[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE) -1:0];
      r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKESR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR] = ff_regb_freq0_ch0_t_ckesr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR) -1:0];
      r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE] = ff_regb_freq0_ch0_t_cksre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE) -1:0];
      r1887_dramset1tmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX] = ff_regb_freq0_ch0_t_cksrx[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
   always_comb begin : r1888_dramset1tmg6_freq0_combo_PROC
      r1888_dramset1tmg6_freq0 = {REG_WIDTH {1'b0}};
      r1888_dramset1tmg6_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG6_T_CKCSX+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX] = cfgs_ff_regb_freq0_ch0_t_ckcsx[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
   always_comb begin : r1889_dramset1tmg7_freq0_combo_PROC
      r1889_dramset1tmg7_freq0 = {REG_WIDTH {1'b0}};
      r1889_dramset1tmg7_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG7_T_CSH+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH] = ff_regb_freq0_ch0_t_csh[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
   always_comb begin : r1891_dramset1tmg9_freq0_combo_PROC
      r1891_dramset1tmg9_freq0 = {REG_WIDTH {1'b0}};
      r1891_dramset1tmg9_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_WR2RD_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S] = cfgs_ff_regb_freq0_ch0_wr2rd_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S) -1:0];
      r1891_dramset1tmg9_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_RRD_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S] = cfgs_ff_regb_freq0_ch0_t_rrd_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S) -1:0];
      r1891_dramset1tmg9_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_CCD_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S] = cfgs_ff_regb_freq0_ch0_t_ccd_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
   always_comb begin : r1894_dramset1tmg12_freq0_combo_PROC
      r1894_dramset1tmg12_freq0 = {REG_WIDTH {1'b0}};
      r1894_dramset1tmg12_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG12_T_CMDCKE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE] = cfgs_ff_regb_freq0_ch0_t_cmdcke[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
   always_comb begin : r1895_dramset1tmg13_freq0_combo_PROC
      r1895_dramset1tmg13_freq0 = {REG_WIDTH {1'b0}};
      r1895_dramset1tmg13_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_PPD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD] = cfgs_ff_regb_freq0_ch0_t_ppd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD) -1:0];
      r1895_dramset1tmg13_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_CCD_MW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW] = cfgs_ff_regb_freq0_ch0_t_ccd_mw[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW) -1:0];
      r1895_dramset1tmg13_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_ODTLOFF+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF] = cfgs_ff_regb_freq0_ch0_odtloff[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
   always_comb begin : r1896_dramset1tmg14_freq0_combo_PROC
      r1896_dramset1tmg14_freq0 = {REG_WIDTH {1'b0}};
      r1896_dramset1tmg14_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_XSR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR] = cfgs_ff_regb_freq0_ch0_t_xsr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR) -1:0];
      r1896_dramset1tmg14_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_OSCO+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO] = cfgs_ff_regb_freq0_ch0_t_osco[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
   always_comb begin : r1905_dramset1tmg23_freq0_combo_PROC
      r1905_dramset1tmg23_freq0 = {REG_WIDTH {1'b0}};
      r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_PDN+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN] = ff_regb_freq0_ch0_t_pdn[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN) -1:0];
      r1905_dramset1tmg23_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_XSR_DSM_X1024+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024] = ff_regb_freq0_ch0_t_xsr_dsm_x1024[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
   always_comb begin : r1906_dramset1tmg24_freq0_combo_PROC
      r1906_dramset1tmg24_freq0 = {REG_WIDTH {1'b0}};
      r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_WR_SYNC+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC] = cfgs_ff_regb_freq0_ch0_max_wr_sync[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC) -1:0];
      r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_RD_SYNC+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC] = cfgs_ff_regb_freq0_ch0_max_rd_sync[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC) -1:0];
      r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_RD2WR_S+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S] = cfgs_ff_regb_freq0_ch0_rd2wr_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S) -1:0];
      r1906_dramset1tmg24_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_BANK_ORG+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG] = cfgs_ff_regb_freq0_ch0_bank_org[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
   always_comb begin : r1907_dramset1tmg25_freq0_combo_PROC
      r1907_dramset1tmg25_freq0 = {REG_WIDTH {1'b0}};
      r1907_dramset1tmg25_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_RDA2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE] = cfgs_ff_regb_freq0_ch0_rda2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE) -1:0];
      r1907_dramset1tmg25_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_WRA2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE] = cfgs_ff_regb_freq0_ch0_wra2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE) -1:0];
      r1907_dramset1tmg25_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE] = cfgs_ff_regb_freq0_ch0_lpddr4_diff_bank_rwa2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
   always_comb begin : r1912_dramset1tmg30_freq0_combo_PROC
      r1912_dramset1tmg30_freq0 = {REG_WIDTH {1'b0}};
      r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2RD+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD] = ff_regb_freq0_ch0_mrr2rd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD) -1:0];
      r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2WR+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR] = ff_regb_freq0_ch0_mrr2wr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR) -1:0];
      r1912_dramset1tmg30_freq0[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2MRW+:`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW] = ff_regb_freq0_ch0_mrr2mrw[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
   always_comb begin : r1938_initmr0_freq0_combo_PROC
      r1938_initmr0_freq0 = {REG_WIDTH {1'b0}};
      r1938_initmr0_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR0_EMR+:`REGB_FREQ0_CH0_SIZE_INITMR0_EMR] = cfgs_ff_regb_freq0_ch0_emr[(`REGB_FREQ0_CH0_SIZE_INITMR0_EMR) -1:0];
      r1938_initmr0_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR0_MR+:`REGB_FREQ0_CH0_SIZE_INITMR0_MR] = cfgs_ff_regb_freq0_ch0_mr[(`REGB_FREQ0_CH0_SIZE_INITMR0_MR) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
   always_comb begin : r1939_initmr1_freq0_combo_PROC
      r1939_initmr1_freq0 = {REG_WIDTH {1'b0}};
      r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR3+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3] = ff_regb_freq0_ch0_emr3[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3) -1:0];
      r1939_initmr1_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR2+:`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2] = ff_regb_freq0_ch0_emr2[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
   always_comb begin : r1940_initmr2_freq0_combo_PROC
      r1940_initmr2_freq0 = {REG_WIDTH {1'b0}};
      r1940_initmr2_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR5+:`REGB_FREQ0_CH0_SIZE_INITMR2_MR5] = cfgs_ff_regb_freq0_ch0_mr5[(`REGB_FREQ0_CH0_SIZE_INITMR2_MR5) -1:0];
      r1940_initmr2_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR4+:`REGB_FREQ0_CH0_SIZE_INITMR2_MR4] = cfgs_ff_regb_freq0_ch0_mr4[(`REGB_FREQ0_CH0_SIZE_INITMR2_MR4) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
   always_comb begin : r1941_initmr3_freq0_combo_PROC
      r1941_initmr3_freq0 = {REG_WIDTH {1'b0}};
      r1941_initmr3_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR6+:`REGB_FREQ0_CH0_SIZE_INITMR3_MR6] = cfgs_ff_regb_freq0_ch0_mr6[(`REGB_FREQ0_CH0_SIZE_INITMR3_MR6) -1:0];
      r1941_initmr3_freq0[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR22+:`REGB_FREQ0_CH0_SIZE_INITMR3_MR22] = cfgs_ff_regb_freq0_ch0_mr22[(`REGB_FREQ0_CH0_SIZE_INITMR3_MR22) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
   always_comb begin : r1942_dfitmg0_freq0_combo_PROC
      r1942_dfitmg0_freq0 = {REG_WIDTH {1'b0}};
      r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT] = ff_regb_freq0_ch0_dfi_tphy_wrlat[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT) -1:0];
      r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRDATA+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA] = ff_regb_freq0_ch0_dfi_tphy_wrdata[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA) -1:0];
      r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_RDDATA_EN+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN] = ff_regb_freq0_ch0_dfi_t_rddata_en[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN) -1:0];
      r1942_dfitmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_CTRL_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY] = ff_regb_freq0_ch0_dfi_t_ctrl_delay[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
   always_comb begin : r1943_dfitmg1_freq0_combo_PROC
      r1943_dfitmg1_freq0 = {REG_WIDTH {1'b0}};
      r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE] = ff_regb_freq0_ch0_dfi_t_dram_clk_enable[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE) -1:0];
      r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE] = ff_regb_freq0_ch0_dfi_t_dram_clk_disable[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE) -1:0];
      r1943_dfitmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY] = ff_regb_freq0_ch0_dfi_t_wrdata_delay[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
   always_comb begin : r1944_dfitmg2_freq0_combo_PROC
      r1944_dfitmg2_freq0 = {REG_WIDTH {1'b0}};
      r1944_dfitmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_WRCSLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT] = cfgs_ff_regb_freq0_ch0_dfi_tphy_wrcslat[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT) -1:0];
      r1944_dfitmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_RDCSLAT+:`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT] = cfgs_ff_regb_freq0_ch0_dfi_tphy_rdcslat[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT) -1:0];
      r1944_dfitmg2_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TWCK_DELAY+:`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY] = cfgs_ff_regb_freq0_ch0_dfi_twck_delay[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
   always_comb begin : r1946_dfitmg4_freq0_combo_PROC
      r1946_dfitmg4_freq0 = {REG_WIDTH {1'b0}};
      r1946_dfitmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_DIS+:`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS] = cfgs_ff_regb_freq0_ch0_dfi_twck_dis[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS) -1:0];
      r1946_dfitmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_WR+:`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR] = cfgs_ff_regb_freq0_ch0_dfi_twck_en_wr[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR) -1:0];
      r1946_dfitmg4_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_RD+:`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD] = cfgs_ff_regb_freq0_ch0_dfi_twck_en_rd[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
   always_comb begin : r1947_dfitmg5_freq0_combo_PROC
      r1947_dfitmg5_freq0 = {REG_WIDTH {1'b0}};
      r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_POST+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST] = cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_post[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST) -1:0];
      r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_CS+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS] = cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_cs[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS) -1:0];
      r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE] = cfgs_ff_regb_freq0_ch0_dfi_twck_toggle[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE) -1:0];
      r1947_dfitmg5_freq0[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_FAST_TOGGLE+:`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE] = cfgs_ff_regb_freq0_ch0_dfi_twck_fast_toggle[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
   always_comb begin : r1949_dfilptmg0_freq0_combo_PROC
      r1949_dfilptmg0_freq0 = {REG_WIDTH {1'b0}};
      r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_PD+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD] = ff_regb_freq0_ch0_dfi_lp_wakeup_pd[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD) -1:0];
      r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_SR+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR] = ff_regb_freq0_ch0_dfi_lp_wakeup_sr[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR) -1:0];
      r1949_dfilptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_DSM+:`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM] = ff_regb_freq0_ch0_dfi_lp_wakeup_dsm[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
   always_comb begin : r1950_dfilptmg1_freq0_combo_PROC
      r1950_dfilptmg1_freq0 = {REG_WIDTH {1'b0}};
      r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_LP_WAKEUP_DATA+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA] = ff_regb_freq0_ch0_dfi_lp_wakeup_data[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA) -1:0];
      r1950_dfilptmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_TLP_RESP+:`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP] = ff_regb_freq0_ch0_dfi_tlp_resp[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
   always_comb begin : r1951_dfiupdtmg0_freq0_combo_PROC
      r1951_dfiupdtmg0_freq0 = {REG_WIDTH {1'b0}};
      r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MIN+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN] = ff_regb_freq0_ch0_dfi_t_ctrlup_min[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN) -1:0];
      r1951_dfiupdtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MAX+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX] = ff_regb_freq0_ch0_dfi_t_ctrlup_max[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
   always_comb begin : r1952_dfiupdtmg1_freq0_combo_PROC
      r1952_dfiupdtmg1_freq0 = {REG_WIDTH {1'b0}};
      r1952_dfiupdtmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024] = cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_max_x1024[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024) -1:0];
      r1952_dfiupdtmg1_freq0[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024+:`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024] = cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_min_x1024[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
   always_comb begin : r1953_dfimsgtmg0_freq0_combo_PROC
      r1953_dfimsgtmg0_freq0 = {REG_WIDTH {1'b0}};
      r1953_dfimsgtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_DFIMSGTMG0_DFI_T_CTRLMSG_RESP+:`REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP] = cfgs_ff_regb_freq0_ch0_dfi_t_ctrlmsg_resp[(`REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
   always_comb begin : r1955_rfshset1tmg0_freq0_combo_PROC
      r1955_rfshset1tmg0_freq0 = {REG_WIDTH {1'b0}};
      r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32] = ff_regb_freq0_ch0_t_refi_x1_x32[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32) -1:0];
      r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_TO_X1_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32] = ff_regb_freq0_ch0_refresh_to_x1_x32[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32) -1:0];
      r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_MARGIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN] = ff_regb_freq0_ch0_refresh_margin[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN) -1:0];
      r1955_rfshset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_SEL+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_SEL] = ff_regb_freq0_ch0_t_refi_x1_sel;
   end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
   always_comb begin : r1956_rfshset1tmg1_freq0_combo_PROC
      r1956_rfshset1tmg1_freq0 = {REG_WIDTH {1'b0}};
      r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN] = ff_regb_freq0_ch0_t_rfc_min[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN) -1:0];
      r1956_rfshset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN_AB+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB] = ff_regb_freq0_ch0_t_rfc_min_ab[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
   always_comb begin : r1957_rfshset1tmg2_freq0_combo_PROC
      r1957_rfshset1tmg2_freq0 = {REG_WIDTH {1'b0}};
      r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2PBR+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR] = ff_regb_freq0_ch0_t_pbr2pbr[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR) -1:0];
      r1957_rfshset1tmg2_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2ACT+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT] = ff_regb_freq0_ch0_t_pbr2act[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
   always_comb begin : r1958_rfshset1tmg3_freq0_combo_PROC
      r1958_rfshset1tmg3_freq0 = {REG_WIDTH {1'b0}};
      r1958_rfshset1tmg3_freq0[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG3_REFRESH_TO_AB_X32+:`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32] = ff_regb_freq0_ch0_refresh_to_ab_x32[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
   always_comb begin : r1975_zqset1tmg0_freq0_combo_PROC
      r1975_zqset1tmg0_freq0 = {REG_WIDTH {1'b0}};
      r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_LONG_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP] = ff_regb_freq0_ch0_t_zq_long_nop[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP) -1:0];
      r1975_zqset1tmg0_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_SHORT_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP] = ff_regb_freq0_ch0_t_zq_short_nop[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
   always_comb begin : r1976_zqset1tmg1_freq0_combo_PROC
      r1976_zqset1tmg1_freq0 = {REG_WIDTH {1'b0}};
      r1976_zqset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024] = cfgs_ff_regb_freq0_ch0_t_zq_short_interval_x1024[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024) -1:0];
      r1976_zqset1tmg1_freq0[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_RESET_NOP+:`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP] = cfgs_ff_regb_freq0_ch0_t_zq_reset_nop[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
   always_comb begin : r1985_dqsoscctl0_freq0_combo_PROC
      r1985_dqsoscctl0_freq0 = {REG_WIDTH {1'b0}};
      r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_ENABLE+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_ENABLE] = ff_regb_freq0_ch0_dqsosc_enable;
      r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT] = ff_regb_freq0_ch0_dqsosc_interval_unit;
      r1985_dqsoscctl0_freq0[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL+:`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL] = ff_regb_freq0_ch0_dqsosc_interval[(`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
   always_comb begin : r1986_derateint_freq0_combo_PROC
      r1986_derateint_freq0 = {REG_WIDTH {1'b0}};
      r1986_derateint_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEINT_MR4_READ_INTERVAL+:`REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL] = cfgs_ff_regb_freq0_ch0_mr4_read_interval[(`REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
   always_comb begin : r1987_derateval0_freq0_combo_PROC
      r1987_derateval0_freq0 = {REG_WIDTH {1'b0}};
      r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RRD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD] = ff_regb_freq0_ch0_derated_t_rrd[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD) -1:0];
      r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RP+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP] = ff_regb_freq0_ch0_derated_t_rp[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP) -1:0];
      r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RAS_MIN+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN] = ff_regb_freq0_ch0_derated_t_ras_min[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN) -1:0];
      r1987_derateval0_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RCD+:`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD] = ff_regb_freq0_ch0_derated_t_rcd[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
   always_comb begin : r1988_derateval1_freq0_combo_PROC
      r1988_derateval1_freq0 = {REG_WIDTH {1'b0}};
      r1988_derateval1_freq0[`REGB_FREQ0_CH0_OFFSET_DERATEVAL1_DERATED_T_RC+:`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC] = ff_regb_freq0_ch0_derated_t_rc[(`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
   always_comb begin : r1989_hwlptmg0_freq0_combo_PROC
      r1989_hwlptmg0_freq0 = {REG_WIDTH {1'b0}};
      r1989_hwlptmg0_freq0[`REGB_FREQ0_CH0_OFFSET_HWLPTMG0_HW_LP_IDLE_X32+:`REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32] = cfgs_ff_regb_freq0_ch0_hw_lp_idle_x32[(`REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
   always_comb begin : r1990_schedtmg0_freq0_combo_PROC
      r1990_schedtmg0_freq0 = {REG_WIDTH {1'b0}};
      r1990_schedtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_PAGECLOSE_TIMER+:`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER] = cfgs_ff_regb_freq0_ch0_pageclose_timer[(`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER) -1:0];
      r1990_schedtmg0_freq0[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_RDWR_IDLE_GAP+:`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP] = cfgs_ff_regb_freq0_ch0_rdwr_idle_gap[(`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
   always_comb begin : r1991_perfhpr1_freq0_combo_PROC
      r1991_perfhpr1_freq0 = {REG_WIDTH {1'b0}};
      r1991_perfhpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_MAX_STARVE+:`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE] = cfgs_ff_regb_freq0_ch0_hpr_max_starve[(`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE) -1:0];
      r1991_perfhpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH+:`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH] = cfgs_ff_regb_freq0_ch0_hpr_xact_run_length[(`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
   always_comb begin : r1992_perflpr1_freq0_combo_PROC
      r1992_perflpr1_freq0 = {REG_WIDTH {1'b0}};
      r1992_perflpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_MAX_STARVE+:`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE] = cfgs_ff_regb_freq0_ch0_lpr_max_starve[(`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE) -1:0];
      r1992_perflpr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH+:`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH] = cfgs_ff_regb_freq0_ch0_lpr_xact_run_length[(`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
   always_comb begin : r1993_perfwr1_freq0_combo_PROC
      r1993_perfwr1_freq0 = {REG_WIDTH {1'b0}};
      r1993_perfwr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_MAX_STARVE+:`REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE] = cfgs_ff_regb_freq0_ch0_w_max_starve[(`REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE) -1:0];
      r1993_perfwr1_freq0[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_XACT_RUN_LENGTH+:`REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH] = cfgs_ff_regb_freq0_ch0_w_xact_run_length[(`REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH) -1:0];
   end
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
   always_comb begin : r1994_tmgcfg_freq0_combo_PROC
      r1994_tmgcfg_freq0 = {REG_WIDTH {1'b0}};
      r1994_tmgcfg_freq0[`REGB_FREQ0_CH0_OFFSET_TMGCFG_FREQUENCY_RATIO+:`REGB_FREQ0_CH0_SIZE_TMGCFG_FREQUENCY_RATIO] = ff_regb_freq0_ch0_frequency_ratio;
   end
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
   always_comb begin : r1997_pwrtmg_freq0_combo_PROC
      r1997_pwrtmg_freq0 = {REG_WIDTH {1'b0}};
      r1997_pwrtmg_freq0[`REGB_FREQ0_CH0_OFFSET_PWRTMG_POWERDOWN_TO_X32+:`REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32] = cfgs_ff_regb_freq0_ch0_powerdown_to_x32[(`REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32) -1:0];
      r1997_pwrtmg_freq0[`REGB_FREQ0_CH0_OFFSET_PWRTMG_SELFREF_TO_X32+:`REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32] = cfgs_ff_regb_freq0_ch0_selfref_to_x32[(`REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32) -1:0];
   end



   always @ (posedge pclk or negedge presetn) begin : sample_pclk_wdata_PROC
      if (~presetn) begin
         apb_data_r  <= {APB_DW{1'b0}};
      end else begin
         apb_data_r  <= pwdata;
      end
   end

   always_comb begin : expand_data_PROC
      apb_data_expanded={REG_WIDTH{1'b0}};
      apb_data_expanded[REG_WIDTH-1:0]=apb_data_r[REG_WIDTH-1:0];
   end
   

   always @(posedge pclk or negedge presetn) begin : sample_pclk_regfields_PROC
      if (~presetn) begin
         ff_regb_ddrc_ch0_lpddr4 <= 'h0;
         ff_regb_ddrc_ch0_lpddr5 <= 'h0;
         ff_regb_ddrc_ch0_en_2t_timing_mode <= 'h0;
         ff_regb_ddrc_ch0_data_bus_width <= 'h0;
         ff_regb_ddrc_ch0_burst_rdwr <= 'h4;
         ff_regb_ddrc_ch0_wck_on <= 'h0;
         ff_regb_ddrc_ch0_wck_suspend_en <= 'h0;
         ff_regb_ddrc_ch0_ws_off_en <= 'h1;
         ff_regb_ddrc_ch0_mr_type <= 'h0;
         ff_regb_ddrc_ch0_sw_init_int <= 'h0;
         ff_regb_ddrc_ch0_mr_rank <= (`MEMC_NUM_RANKS==4) ? 'hF :((`MEMC_NUM_RANKS==2) ? 'h3 : 'h1);
         ff_regb_ddrc_ch0_mr_addr <= 'h0;
         ff_regb_ddrc_ch0_mrr_done_clr <= 'h0;
         ff_regb_ddrc_ch0_mr_wr_todo  <= 1'b0;
         ff_regb_ddrc_ch0_mr_wr_saved <= 1'b0;
         ff_regb_ddrc_ch0_mr_wr <= 'h0;
         ff_regb_ddrc_ch0_mr_data <= 'h0;
         ff_regb_ddrc_ch0_derate_enable <= 'h0;
         ff_regb_ddrc_ch0_lpddr4_refresh_mode <= 'h0;
         ff_regb_ddrc_ch0_derate_mr4_pause_fc <= 'h0;
         ff_regb_ddrc_ch0_dis_trefi_x6x8 <= 'h1;
         ff_regb_ddrc_ch0_dis_trefi_x0125 <= 'h1;
         ff_regb_ddrc_ch0_active_derate_byte_rank0 <= 'h0;
         cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_en <= 'h1;
         cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_clr <= 'h0;
         cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_force <= 'h0;
         cfgs_ff_regb_ddrc_ch0_derate_mr4_tuf_dis <= 'h0;
         ff_regb_ddrc_ch0_dbg_mr4_grp_sel <= 'h0;
         ff_regb_ddrc_ch0_dbg_mr4_rank_sel <= 'h0;
         ff_regb_ddrc_ch0_selfref_en <= 'h0;
         ff_regb_ddrc_ch0_powerdown_en <= 'h0;
         ff_regb_ddrc_ch0_en_dfi_dram_clk_disable <= 'h0;
         ff_regb_ddrc_ch0_selfref_sw <= 'h0;
         ff_regb_ddrc_ch0_stay_in_selfref <= 'h0;
         ff_regb_ddrc_ch0_dis_cam_drain_selfref <= 'h0;
         ff_regb_ddrc_ch0_lpddr4_sr_allowed <= 'h0;
         ff_regb_ddrc_ch0_dsm_en <= 'h0;
         cfgs_ff_regb_ddrc_ch0_hw_lp_en <= 'h1;
         cfgs_ff_regb_ddrc_ch0_hw_lp_exit_idle_en <= 'h1;
         ff_regb_ddrc_ch0_bsm_clk_on <= 'h3f;
         ff_regb_ddrc_ch0_refresh_burst <= 'h0;
         ff_regb_ddrc_ch0_auto_refab_en <= 'h0;
         ff_regb_ddrc_ch0_per_bank_refresh <= 'h0;
         ff_regb_ddrc_ch0_dis_auto_refresh <= 'h0;
         ff_regb_ddrc_ch0_refresh_update_level <= 'h0;
         ff_regb_ddrc_ch0_zq_resistor_shared <= 'h0;
         ff_regb_ddrc_ch0_dis_auto_zq <= 'h0;
         ff_regb_ddrc_ch0_zq_reset_todo  <= 1'b0;
         ff_regb_ddrc_ch0_zq_reset_saved <= 1'b0;
         ff_regb_ddrc_ch0_zq_reset <= 'h0;
         cfgs_ff_regb_ddrc_ch0_dis_srx_zqcl <= 'h0;
         cfgs_ff_regb_ddrc_ch0_dqsosc_runtime <= 'h40;
         cfgs_ff_regb_ddrc_ch0_wck2dqo_runtime <= 'h40;
         cfgs_ff_regb_ddrc_ch0_dis_dqsosc_srx <= 'h0;
         cfgs_ff_regb_ddrc_ch0_prefer_write <= 'h0;
         cfgs_ff_regb_ddrc_ch0_pageclose <= 'h1;
         cfgs_ff_regb_ddrc_ch0_opt_wrcam_fill_level <= 'h1;
         cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_act <= 'h0;
         cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_pre <= 'h0;
         cfgs_ff_regb_ddrc_ch0_autopre_rmw <= 'h0;
         cfgs_ff_regb_ddrc_ch0_lpr_num_entries <= $unsigned(`MEMC_NO_OF_ENTRY/2);
         cfgs_ff_regb_ddrc_ch0_lpddr4_opt_act_timing <= 'h0;
         cfgs_ff_regb_ddrc_ch0_lpddr5_opt_act_timing <= 'h1;
         cfgs_ff_regb_ddrc_ch0_prefer_read <= 'h0;
         cfgs_ff_regb_ddrc_ch0_dis_speculative_act <= 'h0;
         cfgs_ff_regb_ddrc_ch0_delay_switch_write <= 'h2;
         cfgs_ff_regb_ddrc_ch0_page_hit_limit_wr <= 'h0;
         cfgs_ff_regb_ddrc_ch0_page_hit_limit_rd <= 'h0;
         cfgs_ff_regb_ddrc_ch0_opt_hit_gt_hpr <= 'h0;
         cfgs_ff_regb_ddrc_ch0_wrcam_lowthresh <= 'h8;
         cfgs_ff_regb_ddrc_ch0_wrcam_highthresh <= 'h2;
         cfgs_ff_regb_ddrc_ch0_wr_pghit_num_thresh <= 'h4;
         cfgs_ff_regb_ddrc_ch0_rd_pghit_num_thresh <= 'h4;
         cfgs_ff_regb_ddrc_ch0_rd_act_idle_gap <= 'h10;
         cfgs_ff_regb_ddrc_ch0_wr_act_idle_gap <= 'h8;
         cfgs_ff_regb_ddrc_ch0_rd_page_exp_cycles <= 'h40;
         cfgs_ff_regb_ddrc_ch0_wr_page_exp_cycles <= 'h8;
         ff_regb_ddrc_ch0_dfi_lp_en_pd <= 'h0;
         ff_regb_ddrc_ch0_dfi_lp_en_sr <= 'h0;
         ff_regb_ddrc_ch0_dfi_lp_en_dsm <= 'h0;
         ff_regb_ddrc_ch0_dfi_lp_en_data <= 'h0;
         ff_regb_ddrc_ch0_dfi_lp_data_req_en <= 'h1;
         ff_regb_ddrc_ch0_dfi_phyupd_en <= 'h1;
         ff_regb_ddrc_ch0_ctrlupd_pre_srx <= 'h0;
         ff_regb_ddrc_ch0_dis_auto_ctrlupd_srx <= 'h0;
         ff_regb_ddrc_ch0_dis_auto_ctrlupd <= 'h0;
         ff_regb_ddrc_ch0_dfi_init_complete_en <= 'h1;
         ff_regb_ddrc_ch0_phy_dbi_mode <= 'h0;
         ff_regb_ddrc_ch0_dfi_data_cs_polarity <= 'h0;
         ff_regb_ddrc_ch0_dfi_init_start <= 'h0;
         ff_regb_ddrc_ch0_lp_optimized_write <= 'h0;
         ff_regb_ddrc_ch0_dfi_frequency <= 'h0;
         ff_regb_ddrc_ch0_dfi_freq_fsp <= 'h0;
         ff_regb_ddrc_ch0_dfi_channel_mode <= 'h0;
         ff_regb_ddrc_ch0_dfi_phymstr_en <= 'h1;
         ff_regb_ddrc_ch0_dfi_phymstr_blk_ref_x32 <= 'h80;
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_data <= 'h0;
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_cmd <= 'h0;
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_tout_clr <= 'h0;
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_todo  <= 1'b0;
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved <= 1'b0;
         ff_regb_ddrc_ch0_dfi0_ctrlmsg_req <= 'h0;
         ff_regb_ddrc_ch0_wr_poison_slverr_en <= 'h1;
         ff_regb_ddrc_ch0_wr_poison_intr_en <= 'h1;
         ff_regb_ddrc_ch0_wr_poison_intr_clr <= 'h0;
         ff_regb_ddrc_ch0_rd_poison_slverr_en <= 'h1;
         ff_regb_ddrc_ch0_rd_poison_intr_en <= 'h1;
         ff_regb_ddrc_ch0_rd_poison_intr_clr <= 'h0;
         cfgs_ff_regb_ddrc_ch0_dis_wc <= 'h0;
         ff_regb_ddrc_ch0_dis_dq <= 'h0;
         ff_regb_ddrc_ch0_dis_hif <= 'h0;
         ff_regb_ddrc_ch0_zq_calib_short_todo  <= 1'b0;
         ff_regb_ddrc_ch0_zq_calib_short_saved <= 1'b0;
         ff_regb_ddrc_ch0_zq_calib_short <= 'h0;
         ff_regb_ddrc_ch0_ctrlupd_todo  <= 1'b0;
         ff_regb_ddrc_ch0_ctrlupd_saved <= 1'b0;
         ff_regb_ddrc_ch0_ctrlupd <= 'h0;
         ff_regb_ddrc_ch0_rank0_refresh_todo  <= 1'b0;
         ff_regb_ddrc_ch0_rank0_refresh_saved <= 1'b0;
         ff_regb_ddrc_ch0_rank0_refresh <= 'h0;
         cfgs_ff_regb_ddrc_ch0_sw_done <= 'h1;
         ff_regb_ddrc_ch0_dm_en <= 'h1;
         ff_regb_ddrc_ch0_wr_dbi_en <= 'h0;
         ff_regb_ddrc_ch0_rd_dbi_en <= 'h0;
         cfgs_ff_regb_ddrc_ch0_rank0_wr_odt <= 'h1;
         cfgs_ff_regb_ddrc_ch0_rank0_rd_odt <= 'h1;
         ff_regb_ddrc_ch0_rd_data_copy_en <= 'h0;
         ff_regb_ddrc_ch0_wr_data_copy_en <= 'h0;
         ff_regb_ddrc_ch0_wr_data_x_en <= 'h0;
         cfgs_ff_regb_ddrc_ch0_sw_static_unlock <= 'h0;
         ff_regb_ddrc_ch0_pre_cke_x1024 <= 'h4e;
         ff_regb_ddrc_ch0_post_cke_x1024 <= 'h2;
         ff_regb_ddrc_ch0_skip_dram_init <= 'h0;
         ff_regb_ddrc_ch0_dram_rstn_x1024 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_bank_b0 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_bank_b1 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_bank_b2 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_bg_b0 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_bg_b1 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b7 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b8 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b9 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b10 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b3 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b4 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b5 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_col_b6 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b14 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b15 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b16 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b17 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b10 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b11 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b12 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b13 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b6 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b7 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b8 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b9 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b2 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b3 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b4 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b5 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b0 <= 'h0;
         cfgs_ff_regb_addr_map0_addrmap_row_b1 <= 'h0;
         ff_regb_addr_map0_nonbinary_device_density <= 'h0;
         cfgs_ff_regb_arb_port0_go2critical_en <= 'h0;
         cfgs_ff_regb_arb_port0_pagematch_limit <= 'h0;
         cfgs_ff_regb_arb_port0_rd_port_priority <= 'h1f;
         cfgs_ff_regb_arb_port0_rd_port_aging_en <= 'h1;
         cfgs_ff_regb_arb_port0_rd_port_urgent_en <= 'h0;
         cfgs_ff_regb_arb_port0_rd_port_pagematch_en <= (`MEMC_DDR4_EN==1) ? 'h0 : 'h1;
         cfgs_ff_regb_arb_port0_wr_port_priority <= 'h1f;
         cfgs_ff_regb_arb_port0_wr_port_aging_en <= 'h1;
         cfgs_ff_regb_arb_port0_wr_port_urgent_en <= 'h0;
         cfgs_ff_regb_arb_port0_wr_port_pagematch_en <= 'h1;
         ff_regb_arb_port0_port_en <= $unsigned(`UMCTL2_PORT_EN_RESET_VALUE);
         cfgs_ff_regb_arb_port0_rqos_map_level1 <= 'h0;
         cfgs_ff_regb_arb_port0_rqos_map_region0 <= 'h0;
         cfgs_ff_regb_arb_port0_rqos_map_region1 <= 'h0;
         cfgs_ff_regb_arb_port0_rqos_map_timeoutb <= 'h0;
         cfgs_ff_regb_arb_port0_rqos_map_timeoutr <= 'h0;
         cfgs_ff_regb_arb_port0_wqos_map_level1 <= 'h0;
         cfgs_ff_regb_arb_port0_wqos_map_level2 <= 'he;
         cfgs_ff_regb_arb_port0_wqos_map_region0 <= 'h0;
         cfgs_ff_regb_arb_port0_wqos_map_region1 <= 'h0;
         cfgs_ff_regb_arb_port0_wqos_map_region2 <= 'h0;
         cfgs_ff_regb_arb_port0_wqos_map_timeout1 <= 'h0;
         cfgs_ff_regb_arb_port0_wqos_map_timeout2 <= 'h0;
         cfgs_ff_regb_freq0_ch0_t_ras_min <= 'hf;
         cfgs_ff_regb_freq0_ch0_t_ras_max <= 'h1b;
         cfgs_ff_regb_freq0_ch0_t_faw <= 'h10;
         cfgs_ff_regb_freq0_ch0_wr2pre <= 'hf;
         cfgs_ff_regb_freq0_ch0_t_rc <= 'h14;
         cfgs_ff_regb_freq0_ch0_rd2pre <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_xp <= 'h8;
         cfgs_ff_regb_freq0_ch0_wr2rd <= 'hd;
         cfgs_ff_regb_freq0_ch0_rd2wr <= 'h6;
         cfgs_ff_regb_freq0_ch0_read_latency <= 'h5;
         cfgs_ff_regb_freq0_ch0_write_latency <= 'h3;
         cfgs_ff_regb_freq0_ch0_wr2mr <= 'h4;
         cfgs_ff_regb_freq0_ch0_rd2mr <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_mr <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_rp <= 'h5;
         cfgs_ff_regb_freq0_ch0_t_rrd <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_ccd <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_rcd <= 'h5;
         ff_regb_freq0_ch0_t_cke <= 'h3;
         ff_regb_freq0_ch0_t_ckesr <= 'h4;
         ff_regb_freq0_ch0_t_cksre <= 'h5;
         ff_regb_freq0_ch0_t_cksrx <= 'h5;
         cfgs_ff_regb_freq0_ch0_t_ckcsx <= 'h5;
         ff_regb_freq0_ch0_t_csh <= 'h0;
         cfgs_ff_regb_freq0_ch0_wr2rd_s <= 'hd;
         cfgs_ff_regb_freq0_ch0_t_rrd_s <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_ccd_s <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_cmdcke <= 'h2;
         cfgs_ff_regb_freq0_ch0_t_ppd <= 'h4;
         cfgs_ff_regb_freq0_ch0_t_ccd_mw <= 'h20;
         cfgs_ff_regb_freq0_ch0_odtloff <= 'h1c;
         cfgs_ff_regb_freq0_ch0_t_xsr <= 'ha0;
         cfgs_ff_regb_freq0_ch0_t_osco <= 'h8;
         ff_regb_freq0_ch0_t_pdn <= 'h0;
         ff_regb_freq0_ch0_t_xsr_dsm_x1024 <= 'h0;
         cfgs_ff_regb_freq0_ch0_max_wr_sync <= 'hf;
         cfgs_ff_regb_freq0_ch0_max_rd_sync <= 'hf;
         cfgs_ff_regb_freq0_ch0_rd2wr_s <= 'hf;
         cfgs_ff_regb_freq0_ch0_bank_org <= 'h0;
         cfgs_ff_regb_freq0_ch0_rda2pre <= 'h0;
         cfgs_ff_regb_freq0_ch0_wra2pre <= 'h0;
         cfgs_ff_regb_freq0_ch0_lpddr4_diff_bank_rwa2pre <= 'h0;
         ff_regb_freq0_ch0_mrr2rd <= 'h0;
         ff_regb_freq0_ch0_mrr2wr <= 'h0;
         ff_regb_freq0_ch0_mrr2mrw <= 'h0;
         cfgs_ff_regb_freq0_ch0_emr <= 'h510;
         cfgs_ff_regb_freq0_ch0_mr <= 'h0;
         ff_regb_freq0_ch0_emr3 <= 'h0;
         ff_regb_freq0_ch0_emr2 <= 'h0;
         cfgs_ff_regb_freq0_ch0_mr5 <= 'h0;
         cfgs_ff_regb_freq0_ch0_mr4 <= 'h0;
         cfgs_ff_regb_freq0_ch0_mr6 <= 'h0;
         cfgs_ff_regb_freq0_ch0_mr22 <= 'h0;
         ff_regb_freq0_ch0_dfi_tphy_wrlat <= 'h2;
         ff_regb_freq0_ch0_dfi_tphy_wrdata <= 'h0;
         ff_regb_freq0_ch0_dfi_t_rddata_en <= 'h2;
         ff_regb_freq0_ch0_dfi_t_ctrl_delay <= 'h7;
         ff_regb_freq0_ch0_dfi_t_dram_clk_enable <= 'h4;
         ff_regb_freq0_ch0_dfi_t_dram_clk_disable <= 'h4;
         ff_regb_freq0_ch0_dfi_t_wrdata_delay <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_tphy_wrcslat <= 'h2;
         cfgs_ff_regb_freq0_ch0_dfi_tphy_rdcslat <= 'h2;
         cfgs_ff_regb_freq0_ch0_dfi_twck_delay <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_dis <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_en_wr <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_en_rd <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_post <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_cs <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_toggle <= 'h0;
         cfgs_ff_regb_freq0_ch0_dfi_twck_fast_toggle <= 'h0;
         ff_regb_freq0_ch0_dfi_lp_wakeup_pd <= 'h0;
         ff_regb_freq0_ch0_dfi_lp_wakeup_sr <= 'h0;
         ff_regb_freq0_ch0_dfi_lp_wakeup_dsm <= 'h0;
         ff_regb_freq0_ch0_dfi_lp_wakeup_data <= 'h0;
         ff_regb_freq0_ch0_dfi_tlp_resp <= 'h7;
         ff_regb_freq0_ch0_dfi_t_ctrlup_min <= 'h3;
         ff_regb_freq0_ch0_dfi_t_ctrlup_max <= 'h40;
         cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_max_x1024 <= 'h1;
         cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_min_x1024 <= 'h1;
         cfgs_ff_regb_freq0_ch0_dfi_t_ctrlmsg_resp <= 'h4;
         ff_regb_freq0_ch0_t_refi_x1_x32 <= 'h62;
         ff_regb_freq0_ch0_refresh_to_x1_x32 <= 'h10;
         ff_regb_freq0_ch0_refresh_margin <= 'h2;
         ff_regb_freq0_ch0_t_refi_x1_sel <= 'h0;
         ff_regb_freq0_ch0_t_rfc_min <= 'h8c;
         ff_regb_freq0_ch0_t_rfc_min_ab <= 'h0;
         ff_regb_freq0_ch0_t_pbr2pbr <= 'h8c;
         ff_regb_freq0_ch0_t_pbr2act <= 'h8c;
         ff_regb_freq0_ch0_refresh_to_ab_x32 <= 'h10;
         ff_regb_freq0_ch0_t_zq_long_nop <= 'h200;
         ff_regb_freq0_ch0_t_zq_short_nop <= 'h40;
         cfgs_ff_regb_freq0_ch0_t_zq_short_interval_x1024 <= 'h100;
         cfgs_ff_regb_freq0_ch0_t_zq_reset_nop <= 'h20;
         ff_regb_freq0_ch0_dqsosc_enable <= 'h0;
         ff_regb_freq0_ch0_dqsosc_interval_unit <= 'h0;
         ff_regb_freq0_ch0_dqsosc_interval <= 'h7;
         cfgs_ff_regb_freq0_ch0_mr4_read_interval <= 'h800000;
         ff_regb_freq0_ch0_derated_t_rrd <= 'h4;
         ff_regb_freq0_ch0_derated_t_rp <= 'h5;
         ff_regb_freq0_ch0_derated_t_ras_min <= 'hf;
         ff_regb_freq0_ch0_derated_t_rcd <= 'h5;
         ff_regb_freq0_ch0_derated_t_rc <= 'h14;
         cfgs_ff_regb_freq0_ch0_hw_lp_idle_x32 <= 'h0;
         cfgs_ff_regb_freq0_ch0_pageclose_timer <= 'h0;
         cfgs_ff_regb_freq0_ch0_rdwr_idle_gap <= 'h0;
         cfgs_ff_regb_freq0_ch0_hpr_max_starve <= 'h1;
         cfgs_ff_regb_freq0_ch0_hpr_xact_run_length <= 'hf;
         cfgs_ff_regb_freq0_ch0_lpr_max_starve <= 'h7f;
         cfgs_ff_regb_freq0_ch0_lpr_xact_run_length <= 'hf;
         cfgs_ff_regb_freq0_ch0_w_max_starve <= 'h7f;
         cfgs_ff_regb_freq0_ch0_w_xact_run_length <= 'hf;
         ff_regb_freq0_ch0_frequency_ratio <= 'h0;
         cfgs_ff_regb_freq0_ch0_powerdown_to_x32 <= 'h10;
         cfgs_ff_regb_freq0_ch0_selfref_to_x32 <= 'h40;

      end else begin
   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
         if (rwselect[0] && write_en) begin
            ff_regb_ddrc_ch0_lpddr4 <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4 +: `REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4] & regb_ddrc_ch0_mstr0_lpddr4_mask[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR4 +: `REGB_DDRC_CH0_SIZE_MSTR0_LPDDR4];
         end
         if (rwselect[0] && write_en) begin
            ff_regb_ddrc_ch0_lpddr5 <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5 +: `REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5] & regb_ddrc_ch0_mstr0_lpddr5_mask[`REGB_DDRC_CH0_OFFSET_MSTR0_LPDDR5 +: `REGB_DDRC_CH0_SIZE_MSTR0_LPDDR5];
         end
         if (rwselect[0] && write_en) begin
            ff_regb_ddrc_ch0_en_2t_timing_mode <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE +: `REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE] & regb_ddrc_ch0_mstr0_en_2t_timing_mode_mask[`REGB_DDRC_CH0_OFFSET_MSTR0_EN_2T_TIMING_MODE +: `REGB_DDRC_CH0_SIZE_MSTR0_EN_2T_TIMING_MODE];
         end
         if (rwselect[0] && write_en) begin
            ff_regb_ddrc_ch0_data_bus_width[(`REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH +: `REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH] & regb_ddrc_ch0_mstr0_data_bus_width_mask[`REGB_DDRC_CH0_OFFSET_MSTR0_DATA_BUS_WIDTH +: `REGB_DDRC_CH0_SIZE_MSTR0_DATA_BUS_WIDTH];
         end
         if (rwselect[0] && write_en) begin
            ff_regb_ddrc_ch0_burst_rdwr[(`REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR +: `REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR] & regb_ddrc_ch0_mstr0_burst_rdwr_mask[`REGB_DDRC_CH0_OFFSET_MSTR0_BURST_RDWR +: `REGB_DDRC_CH0_SIZE_MSTR0_BURST_RDWR];
         end
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
         if (rwselect[4] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_wck_on <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_ON +: `REGB_DDRC_CH0_SIZE_MSTR4_WCK_ON] & regb_ddrc_ch0_mstr4_wck_on_mask[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_ON +: `REGB_DDRC_CH0_SIZE_MSTR4_WCK_ON];
            end
         end
         if (rwselect[4] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_wck_suspend_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_SUSPEND_EN +: `REGB_DDRC_CH0_SIZE_MSTR4_WCK_SUSPEND_EN] & regb_ddrc_ch0_mstr4_wck_suspend_en_mask[`REGB_DDRC_CH0_OFFSET_MSTR4_WCK_SUSPEND_EN +: `REGB_DDRC_CH0_SIZE_MSTR4_WCK_SUSPEND_EN];
            end
         end
         if (rwselect[4] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_ws_off_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MSTR4_WS_OFF_EN +: `REGB_DDRC_CH0_SIZE_MSTR4_WS_OFF_EN] & regb_ddrc_ch0_mstr4_ws_off_en_mask[`REGB_DDRC_CH0_OFFSET_MSTR4_WS_OFF_EN +: `REGB_DDRC_CH0_SIZE_MSTR4_WS_OFF_EN];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
         if (rwselect[5] && write_en) begin
            ff_regb_ddrc_ch0_mr_type <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_TYPE +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MR_TYPE] & regb_ddrc_ch0_mrctrl0_mr_type_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_TYPE +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MR_TYPE];
         end
         if (rwselect[5] && write_en) begin
            ff_regb_ddrc_ch0_sw_init_int <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_SW_INIT_INT +: `REGB_DDRC_CH0_SIZE_MRCTRL0_SW_INIT_INT] & regb_ddrc_ch0_mrctrl0_sw_init_int_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_SW_INIT_INT +: `REGB_DDRC_CH0_SIZE_MRCTRL0_SW_INIT_INT];
         end
         if (rwselect[5] && write_en) begin
            ff_regb_ddrc_ch0_mr_rank[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_RANK +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK] & regb_ddrc_ch0_mrctrl0_mr_rank_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_RANK +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MR_RANK];
         end
         if (rwselect[5] && write_en) begin
            ff_regb_ddrc_ch0_mr_addr[(`REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_ADDR +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR] & regb_ddrc_ch0_mrctrl0_mr_addr_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_ADDR +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MR_ADDR];
         end
         if (reg_ddrc_mrr_done_clr_ack_pclk) begin
            ff_regb_ddrc_ch0_mrr_done_clr <= 1'b0;
         end else begin
            if (rwselect[5] && write_en) begin
               ff_regb_ddrc_ch0_mrr_done_clr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MRR_DONE_CLR +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MRR_DONE_CLR] & regb_ddrc_ch0_mrctrl0_mrr_done_clr_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MRR_DONE_CLR +: `REGB_DDRC_CH0_SIZE_MRCTRL0_MRR_DONE_CLR];
            end
         end
         if (reg_ddrc_mr_wr_ack_pclk) begin
            ff_regb_ddrc_ch0_mr_wr <= 1'b0;
            ff_regb_ddrc_ch0_mr_wr_saved <= 1'b0;
         end else begin
            if (ff_regb_ddrc_ch0_mr_wr_todo & (!ddrc_reg_mr_wr_busy_int)) begin
               ff_regb_ddrc_ch0_mr_wr_todo <= 1'b0;
               ff_regb_ddrc_ch0_mr_wr <= ff_regb_ddrc_ch0_mr_wr_saved;
            end else if (rwselect[5] & store_rqst & (apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_WR] & regb_ddrc_ch0_mrctrl0_mr_wr_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_WR]) ) begin
               if (ddrc_reg_mr_wr_busy_int) begin
                  ff_regb_ddrc_ch0_mr_wr_todo <= 1'b1;
                  ff_regb_ddrc_ch0_mr_wr_saved <= 1'b1;
               end else begin
                  ff_regb_ddrc_ch0_mr_wr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_WR] & regb_ddrc_ch0_mrctrl0_mr_wr_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL0_MR_WR];
               end
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
         if (rwselect[6] && write_en) begin
            ff_regb_ddrc_ch0_mr_data[(`REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_MRCTRL1_MR_DATA +: `REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA] & regb_ddrc_ch0_mrctrl1_mr_data_mask[`REGB_DDRC_CH0_OFFSET_MRCTRL1_MR_DATA +: `REGB_DDRC_CH0_SIZE_MRCTRL1_MR_DATA];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
         if (rwselect[8] && write_en) begin
            ff_regb_ddrc_ch0_derate_enable <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_ENABLE +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_ENABLE] & regb_ddrc_ch0_deratectl0_derate_enable_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_ENABLE +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_ENABLE];
         end
         if (rwselect[8] && write_en) begin
            ff_regb_ddrc_ch0_lpddr4_refresh_mode <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL0_LPDDR4_REFRESH_MODE +: `REGB_DDRC_CH0_SIZE_DERATECTL0_LPDDR4_REFRESH_MODE] & regb_ddrc_ch0_deratectl0_lpddr4_refresh_mode_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL0_LPDDR4_REFRESH_MODE +: `REGB_DDRC_CH0_SIZE_DERATECTL0_LPDDR4_REFRESH_MODE];
         end
         if (rwselect[8] && write_en) begin
            ff_regb_ddrc_ch0_derate_mr4_pause_fc <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_MR4_PAUSE_FC +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_MR4_PAUSE_FC] & regb_ddrc_ch0_deratectl0_derate_mr4_pause_fc_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DERATE_MR4_PAUSE_FC +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DERATE_MR4_PAUSE_FC];
         end
         if (rwselect[8] && write_en) begin
            ff_regb_ddrc_ch0_dis_trefi_x6x8 <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X6X8 +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X6X8] & regb_ddrc_ch0_deratectl0_dis_trefi_x6x8_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X6X8 +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X6X8];
         end
         if (rwselect[8] && write_en) begin
            ff_regb_ddrc_ch0_dis_trefi_x0125 <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X0125 +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X0125] & regb_ddrc_ch0_deratectl0_dis_trefi_x0125_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL0_DIS_TREFI_X0125 +: `REGB_DDRC_CH0_SIZE_DERATECTL0_DIS_TREFI_X0125];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
         if (rwselect[9] && write_en) begin
            ff_regb_ddrc_ch0_active_derate_byte_rank0[(`REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0 +: `REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0] & regb_ddrc_ch0_deratectl1_active_derate_byte_rank0_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0 +: `REGB_DDRC_CH0_SIZE_DERATECTL1_ACTIVE_DERATE_BYTE_RANK0];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
         if (rwselect[13] && write_en) begin
            cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN +: `REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN] & regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_en_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN +: `REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_EN];
         end
         if (reg_ddrc_derate_temp_limit_intr_clr_ack_pclk) begin
            cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_clr <= 1'b0;
         end else begin
            if (rwselect[13] && write_en) begin
               cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_clr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR +: `REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR] & regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_clr_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR +: `REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_CLR];
            end
         end
         if (reg_ddrc_derate_temp_limit_intr_force_ack_pclk) begin
            cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_force <= 1'b0;
         end else begin
            if (rwselect[13] && write_en) begin
               cfgs_ff_regb_ddrc_ch0_derate_temp_limit_intr_force <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE +: `REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE] & regb_ddrc_ch0_deratectl5_derate_temp_limit_intr_force_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE +: `REGB_DDRC_CH0_SIZE_DERATECTL5_DERATE_TEMP_LIMIT_INTR_FORCE];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
         if (rwselect[14] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_derate_mr4_tuf_dis <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATECTL6_DERATE_MR4_TUF_DIS +: `REGB_DDRC_CH0_SIZE_DERATECTL6_DERATE_MR4_TUF_DIS] & regb_ddrc_ch0_deratectl6_derate_mr4_tuf_dis_mask[`REGB_DDRC_CH0_OFFSET_DERATECTL6_DERATE_MR4_TUF_DIS +: `REGB_DDRC_CH0_SIZE_DERATECTL6_DERATE_MR4_TUF_DIS];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
         if (rwselect[15] && write_en) begin
            ff_regb_ddrc_ch0_dbg_mr4_grp_sel[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_GRP_SEL +: `REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL] & regb_ddrc_ch0_deratedbgctl_dbg_mr4_grp_sel_mask[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_GRP_SEL +: `REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_GRP_SEL];
         end
         if (rwselect[15] && write_en) begin
            ff_regb_ddrc_ch0_dbg_mr4_rank_sel[(`REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_RANK_SEL +: `REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL] & regb_ddrc_ch0_deratedbgctl_dbg_mr4_rank_sel_mask[`REGB_DDRC_CH0_OFFSET_DERATEDBGCTL_DBG_MR4_RANK_SEL +: `REGB_DDRC_CH0_SIZE_DERATEDBGCTL_DBG_MR4_RANK_SEL];
         end
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_selfref_en[(`REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_EN +: `REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN] & regb_ddrc_ch0_pwrctl_selfref_en_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_EN +: `REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_EN];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_powerdown_en[(`REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_POWERDOWN_EN +: `REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN] & regb_ddrc_ch0_pwrctl_powerdown_en_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_POWERDOWN_EN +: `REGB_DDRC_CH0_SIZE_PWRCTL_POWERDOWN_EN];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_en_dfi_dram_clk_disable <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE +: `REGB_DDRC_CH0_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE] & regb_ddrc_ch0_pwrctl_en_dfi_dram_clk_disable_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_EN_DFI_DRAM_CLK_DISABLE +: `REGB_DDRC_CH0_SIZE_PWRCTL_EN_DFI_DRAM_CLK_DISABLE];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_selfref_sw <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_SW +: `REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_SW] & regb_ddrc_ch0_pwrctl_selfref_sw_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_SELFREF_SW +: `REGB_DDRC_CH0_SIZE_PWRCTL_SELFREF_SW];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_stay_in_selfref <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_STAY_IN_SELFREF +: `REGB_DDRC_CH0_SIZE_PWRCTL_STAY_IN_SELFREF] & regb_ddrc_ch0_pwrctl_stay_in_selfref_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_STAY_IN_SELFREF +: `REGB_DDRC_CH0_SIZE_PWRCTL_STAY_IN_SELFREF];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_dis_cam_drain_selfref <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF +: `REGB_DDRC_CH0_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF] & regb_ddrc_ch0_pwrctl_dis_cam_drain_selfref_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_DIS_CAM_DRAIN_SELFREF +: `REGB_DDRC_CH0_SIZE_PWRCTL_DIS_CAM_DRAIN_SELFREF];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_lpddr4_sr_allowed <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_LPDDR4_SR_ALLOWED +: `REGB_DDRC_CH0_SIZE_PWRCTL_LPDDR4_SR_ALLOWED] & regb_ddrc_ch0_pwrctl_lpddr4_sr_allowed_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_LPDDR4_SR_ALLOWED +: `REGB_DDRC_CH0_SIZE_PWRCTL_LPDDR4_SR_ALLOWED];
         end
         if (rwselect[16] && write_en) begin
            ff_regb_ddrc_ch0_dsm_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_PWRCTL_DSM_EN +: `REGB_DDRC_CH0_SIZE_PWRCTL_DSM_EN] & regb_ddrc_ch0_pwrctl_dsm_en_mask[`REGB_DDRC_CH0_OFFSET_PWRCTL_DSM_EN +: `REGB_DDRC_CH0_SIZE_PWRCTL_DSM_EN];
         end
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
         if (rwselect[17] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_hw_lp_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EN +: `REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EN] & regb_ddrc_ch0_hwlpctl_hw_lp_en_mask[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EN +: `REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EN];
            end
         end
         if (rwselect[17] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_hw_lp_exit_idle_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN +: `REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN] & regb_ddrc_ch0_hwlpctl_hw_lp_exit_idle_en_mask[`REGB_DDRC_CH0_OFFSET_HWLPCTL_HW_LP_EXIT_IDLE_EN +: `REGB_DDRC_CH0_SIZE_HWLPCTL_HW_LP_EXIT_IDLE_EN];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
         if (rwselect[19] && write_en) begin
            ff_regb_ddrc_ch0_bsm_clk_on[(`REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_CLKGATECTL_BSM_CLK_ON +: `REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON] & regb_ddrc_ch0_clkgatectl_bsm_clk_on_mask[`REGB_DDRC_CH0_OFFSET_CLKGATECTL_BSM_CLK_ON +: `REGB_DDRC_CH0_SIZE_CLKGATECTL_BSM_CLK_ON];
         end
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
         if (rwselect[20] && write_en) begin
            ff_regb_ddrc_ch0_refresh_burst[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_REFRESH_BURST +: `REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST] & regb_ddrc_ch0_rfshmod0_refresh_burst_mask[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_REFRESH_BURST +: `REGB_DDRC_CH0_SIZE_RFSHMOD0_REFRESH_BURST];
         end
         if (rwselect[20] && write_en) begin
            ff_regb_ddrc_ch0_auto_refab_en[(`REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_AUTO_REFAB_EN +: `REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN] & regb_ddrc_ch0_rfshmod0_auto_refab_en_mask[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_AUTO_REFAB_EN +: `REGB_DDRC_CH0_SIZE_RFSHMOD0_AUTO_REFAB_EN];
         end
         if (rwselect[20] && write_en) begin
            ff_regb_ddrc_ch0_per_bank_refresh <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_PER_BANK_REFRESH +: `REGB_DDRC_CH0_SIZE_RFSHMOD0_PER_BANK_REFRESH] & regb_ddrc_ch0_rfshmod0_per_bank_refresh_mask[`REGB_DDRC_CH0_OFFSET_RFSHMOD0_PER_BANK_REFRESH +: `REGB_DDRC_CH0_SIZE_RFSHMOD0_PER_BANK_REFRESH];
         end
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
         if (rwselect[22] && write_en) begin
            ff_regb_ddrc_ch0_dis_auto_refresh <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_DIS_AUTO_REFRESH +: `REGB_DDRC_CH0_SIZE_RFSHCTL0_DIS_AUTO_REFRESH] & regb_ddrc_ch0_rfshctl0_dis_auto_refresh_mask[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_DIS_AUTO_REFRESH +: `REGB_DDRC_CH0_SIZE_RFSHCTL0_DIS_AUTO_REFRESH];
         end
         if (rwselect[22] && write_en) begin
            ff_regb_ddrc_ch0_refresh_update_level <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_REFRESH_UPDATE_LEVEL +: `REGB_DDRC_CH0_SIZE_RFSHCTL0_REFRESH_UPDATE_LEVEL] & regb_ddrc_ch0_rfshctl0_refresh_update_level_mask[`REGB_DDRC_CH0_OFFSET_RFSHCTL0_REFRESH_UPDATE_LEVEL +: `REGB_DDRC_CH0_SIZE_RFSHCTL0_REFRESH_UPDATE_LEVEL];
         end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
         if (rwselect[25] && write_en) begin
            ff_regb_ddrc_ch0_zq_resistor_shared <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED +: `REGB_DDRC_CH0_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED] & regb_ddrc_ch0_zqctl0_zq_resistor_shared_mask[`REGB_DDRC_CH0_OFFSET_ZQCTL0_ZQ_RESISTOR_SHARED +: `REGB_DDRC_CH0_SIZE_ZQCTL0_ZQ_RESISTOR_SHARED];
         end
         if (rwselect[25] && write_en) begin
            ff_regb_ddrc_ch0_dis_auto_zq <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ZQCTL0_DIS_AUTO_ZQ +: `REGB_DDRC_CH0_SIZE_ZQCTL0_DIS_AUTO_ZQ] & regb_ddrc_ch0_zqctl0_dis_auto_zq_mask[`REGB_DDRC_CH0_OFFSET_ZQCTL0_DIS_AUTO_ZQ +: `REGB_DDRC_CH0_SIZE_ZQCTL0_DIS_AUTO_ZQ];
         end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
         if (reg_ddrc_zq_reset_ack_pclk) begin
            ff_regb_ddrc_ch0_zq_reset <= 1'b0;
            ff_regb_ddrc_ch0_zq_reset_saved <= 1'b0;
         end else begin
            if (ff_regb_ddrc_ch0_zq_reset_todo & (!ddrc_reg_zq_reset_busy_int)) begin
               ff_regb_ddrc_ch0_zq_reset_todo <= 1'b0;
               ff_regb_ddrc_ch0_zq_reset <= ff_regb_ddrc_ch0_zq_reset_saved;
            end else if (rwselect[26] & store_rqst & (apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ZQCTL1_ZQ_RESET] & regb_ddrc_ch0_zqctl1_zq_reset_mask[`REGB_DDRC_CH0_OFFSET_ZQCTL1_ZQ_RESET]) ) begin
               if (ddrc_reg_zq_reset_busy_int) begin
                  ff_regb_ddrc_ch0_zq_reset_todo <= 1'b1;
                  ff_regb_ddrc_ch0_zq_reset_saved <= 1'b1;
               end else begin
                  ff_regb_ddrc_ch0_zq_reset <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ZQCTL1_ZQ_RESET] & regb_ddrc_ch0_zqctl1_zq_reset_mask[`REGB_DDRC_CH0_OFFSET_ZQCTL1_ZQ_RESET];
               end
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
         if (rwselect[27] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dis_srx_zqcl <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ZQCTL2_DIS_SRX_ZQCL +: `REGB_DDRC_CH0_SIZE_ZQCTL2_DIS_SRX_ZQCL] & regb_ddrc_ch0_zqctl2_dis_srx_zqcl_mask[`REGB_DDRC_CH0_OFFSET_ZQCTL2_DIS_SRX_ZQCL +: `REGB_DDRC_CH0_SIZE_ZQCTL2_DIS_SRX_ZQCL];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
         if (rwselect[28] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dqsosc_runtime[(`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_DQSOSC_RUNTIME +: `REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME] & regb_ddrc_ch0_dqsoscruntime_dqsosc_runtime_mask[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_DQSOSC_RUNTIME +: `REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_DQSOSC_RUNTIME];
            end
         end
         if (rwselect[28] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_wck2dqo_runtime[(`REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_WCK2DQO_RUNTIME +: `REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME] & regb_ddrc_ch0_dqsoscruntime_wck2dqo_runtime_mask[`REGB_DDRC_CH0_OFFSET_DQSOSCRUNTIME_WCK2DQO_RUNTIME +: `REGB_DDRC_CH0_SIZE_DQSOSCRUNTIME_WCK2DQO_RUNTIME];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
         if (rwselect[29] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dis_dqsosc_srx <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DQSOSCCFG0_DIS_DQSOSC_SRX +: `REGB_DDRC_CH0_SIZE_DQSOSCCFG0_DIS_DQSOSC_SRX] & regb_ddrc_ch0_dqsosccfg0_dis_dqsosc_srx_mask[`REGB_DDRC_CH0_OFFSET_DQSOSCCFG0_DIS_DQSOSC_SRX +: `REGB_DDRC_CH0_SIZE_DQSOSCCFG0_DIS_DQSOSC_SRX];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
         if (rwselect[31] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_prefer_write <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_WRITE +: `REGB_DDRC_CH0_SIZE_SCHED0_PREFER_WRITE] & regb_ddrc_ch0_sched0_prefer_write_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_WRITE +: `REGB_DDRC_CH0_SIZE_SCHED0_PREFER_WRITE];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_pageclose <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_PAGECLOSE +: `REGB_DDRC_CH0_SIZE_SCHED0_PAGECLOSE] & regb_ddrc_ch0_sched0_pageclose_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_PAGECLOSE +: `REGB_DDRC_CH0_SIZE_SCHED0_PAGECLOSE];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_opt_wrcam_fill_level <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_OPT_WRCAM_FILL_LEVEL +: `REGB_DDRC_CH0_SIZE_SCHED0_OPT_WRCAM_FILL_LEVEL] & regb_ddrc_ch0_sched0_opt_wrcam_fill_level_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_OPT_WRCAM_FILL_LEVEL +: `REGB_DDRC_CH0_SIZE_SCHED0_OPT_WRCAM_FILL_LEVEL];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_act <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_ACT +: `REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_ACT] & regb_ddrc_ch0_sched0_dis_opt_ntt_by_act_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_ACT +: `REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_ACT];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dis_opt_ntt_by_pre <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_PRE +: `REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_PRE] & regb_ddrc_ch0_sched0_dis_opt_ntt_by_pre_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_OPT_NTT_BY_PRE +: `REGB_DDRC_CH0_SIZE_SCHED0_DIS_OPT_NTT_BY_PRE];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_autopre_rmw <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_AUTOPRE_RMW +: `REGB_DDRC_CH0_SIZE_SCHED0_AUTOPRE_RMW] & regb_ddrc_ch0_sched0_autopre_rmw_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_AUTOPRE_RMW +: `REGB_DDRC_CH0_SIZE_SCHED0_AUTOPRE_RMW];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_lpr_num_entries[(`REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_LPR_NUM_ENTRIES +: `REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES] & regb_ddrc_ch0_sched0_lpr_num_entries_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_LPR_NUM_ENTRIES +: `REGB_DDRC_CH0_SIZE_SCHED0_LPR_NUM_ENTRIES];
            end
         end
         if (rwselect[31] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_lpddr4_opt_act_timing <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR4_OPT_ACT_TIMING +: `REGB_DDRC_CH0_SIZE_SCHED0_LPDDR4_OPT_ACT_TIMING] & regb_ddrc_ch0_sched0_lpddr4_opt_act_timing_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR4_OPT_ACT_TIMING +: `REGB_DDRC_CH0_SIZE_SCHED0_LPDDR4_OPT_ACT_TIMING];
            end
         end
         if (rwselect[31] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_lpddr5_opt_act_timing <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR5_OPT_ACT_TIMING +: `REGB_DDRC_CH0_SIZE_SCHED0_LPDDR5_OPT_ACT_TIMING] & regb_ddrc_ch0_sched0_lpddr5_opt_act_timing_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_LPDDR5_OPT_ACT_TIMING +: `REGB_DDRC_CH0_SIZE_SCHED0_LPDDR5_OPT_ACT_TIMING];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_prefer_read <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_READ +: `REGB_DDRC_CH0_SIZE_SCHED0_PREFER_READ] & regb_ddrc_ch0_sched0_prefer_read_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_PREFER_READ +: `REGB_DDRC_CH0_SIZE_SCHED0_PREFER_READ];
            end
         end
         if (rwselect[31] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dis_speculative_act <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_SPECULATIVE_ACT +: `REGB_DDRC_CH0_SIZE_SCHED0_DIS_SPECULATIVE_ACT] & regb_ddrc_ch0_sched0_dis_speculative_act_mask[`REGB_DDRC_CH0_OFFSET_SCHED0_DIS_SPECULATIVE_ACT +: `REGB_DDRC_CH0_SIZE_SCHED0_DIS_SPECULATIVE_ACT];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
         if (rwselect[32] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_delay_switch_write[(`REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED1_DELAY_SWITCH_WRITE +: `REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE] & regb_ddrc_ch0_sched1_delay_switch_write_mask[`REGB_DDRC_CH0_OFFSET_SCHED1_DELAY_SWITCH_WRITE +: `REGB_DDRC_CH0_SIZE_SCHED1_DELAY_SWITCH_WRITE];
            end
         end
         if (rwselect[32] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_page_hit_limit_wr[(`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_WR +: `REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR] & regb_ddrc_ch0_sched1_page_hit_limit_wr_mask[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_WR +: `REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_WR];
            end
         end
         if (rwselect[32] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_page_hit_limit_rd[(`REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_RD +: `REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD] & regb_ddrc_ch0_sched1_page_hit_limit_rd_mask[`REGB_DDRC_CH0_OFFSET_SCHED1_PAGE_HIT_LIMIT_RD +: `REGB_DDRC_CH0_SIZE_SCHED1_PAGE_HIT_LIMIT_RD];
            end
         end
         if (rwselect[32] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_opt_hit_gt_hpr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED1_OPT_HIT_GT_HPR +: `REGB_DDRC_CH0_SIZE_SCHED1_OPT_HIT_GT_HPR] & regb_ddrc_ch0_sched1_opt_hit_gt_hpr_mask[`REGB_DDRC_CH0_OFFSET_SCHED1_OPT_HIT_GT_HPR +: `REGB_DDRC_CH0_SIZE_SCHED1_OPT_HIT_GT_HPR];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
         if (rwselect[34] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_wrcam_lowthresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_LOWTHRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH] & regb_ddrc_ch0_sched3_wrcam_lowthresh_mask[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_LOWTHRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_LOWTHRESH];
            end
         end
         if (rwselect[34] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_wrcam_highthresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_HIGHTHRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH] & regb_ddrc_ch0_sched3_wrcam_highthresh_mask[`REGB_DDRC_CH0_OFFSET_SCHED3_WRCAM_HIGHTHRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_WRCAM_HIGHTHRESH];
            end
         end
         if (rwselect[34] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_wr_pghit_num_thresh[(`REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED3_WR_PGHIT_NUM_THRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH] & regb_ddrc_ch0_sched3_wr_pghit_num_thresh_mask[`REGB_DDRC_CH0_OFFSET_SCHED3_WR_PGHIT_NUM_THRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_WR_PGHIT_NUM_THRESH];
            end
         end
         if (rwselect[34] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_rd_pghit_num_thresh[(`REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED3_RD_PGHIT_NUM_THRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH] & regb_ddrc_ch0_sched3_rd_pghit_num_thresh_mask[`REGB_DDRC_CH0_OFFSET_SCHED3_RD_PGHIT_NUM_THRESH +: `REGB_DDRC_CH0_SIZE_SCHED3_RD_PGHIT_NUM_THRESH];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
         if (rwselect[35] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_rd_act_idle_gap[(`REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_ACT_IDLE_GAP +: `REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP] & regb_ddrc_ch0_sched4_rd_act_idle_gap_mask[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_ACT_IDLE_GAP +: `REGB_DDRC_CH0_SIZE_SCHED4_RD_ACT_IDLE_GAP];
            end
         end
         if (rwselect[35] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_wr_act_idle_gap[(`REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_ACT_IDLE_GAP +: `REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP] & regb_ddrc_ch0_sched4_wr_act_idle_gap_mask[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_ACT_IDLE_GAP +: `REGB_DDRC_CH0_SIZE_SCHED4_WR_ACT_IDLE_GAP];
            end
         end
         if (rwselect[35] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_rd_page_exp_cycles[(`REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_PAGE_EXP_CYCLES +: `REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES] & regb_ddrc_ch0_sched4_rd_page_exp_cycles_mask[`REGB_DDRC_CH0_OFFSET_SCHED4_RD_PAGE_EXP_CYCLES +: `REGB_DDRC_CH0_SIZE_SCHED4_RD_PAGE_EXP_CYCLES];
            end
         end
         if (rwselect[35] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_wr_page_exp_cycles[(`REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_PAGE_EXP_CYCLES +: `REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES] & regb_ddrc_ch0_sched4_wr_page_exp_cycles_mask[`REGB_DDRC_CH0_OFFSET_SCHED4_WR_PAGE_EXP_CYCLES +: `REGB_DDRC_CH0_SIZE_SCHED4_WR_PAGE_EXP_CYCLES];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
         if (rwselect[44] && write_en) begin
            ff_regb_ddrc_ch0_dfi_lp_en_pd <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_PD +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_PD] & regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_pd_mask[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_PD +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_PD];
         end
         if (rwselect[44] && write_en) begin
            ff_regb_ddrc_ch0_dfi_lp_en_sr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_SR +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_SR] & regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_sr_mask[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_SR +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_SR];
         end
         if (rwselect[44] && write_en) begin
            ff_regb_ddrc_ch0_dfi_lp_en_dsm <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DSM +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DSM] & regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_dsm_mask[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DSM +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DSM];
         end
         if (rwselect[44] && write_en) begin
            ff_regb_ddrc_ch0_dfi_lp_en_data <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DATA +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DATA] & regb_ddrc_ch0_dfilpcfg0_dfi_lp_en_data_mask[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_EN_DATA +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_EN_DATA];
         end
         if (rwselect[44] && write_en) begin
            ff_regb_ddrc_ch0_dfi_lp_data_req_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_DATA_REQ_EN +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_DATA_REQ_EN] & regb_ddrc_ch0_dfilpcfg0_dfi_lp_data_req_en_mask[`REGB_DDRC_CH0_OFFSET_DFILPCFG0_DFI_LP_DATA_REQ_EN +: `REGB_DDRC_CH0_SIZE_DFILPCFG0_DFI_LP_DATA_REQ_EN];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
         if (rwselect[45] && write_en) begin
            ff_regb_ddrc_ch0_dfi_phyupd_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DFI_PHYUPD_EN +: `REGB_DDRC_CH0_SIZE_DFIUPD0_DFI_PHYUPD_EN] & regb_ddrc_ch0_dfiupd0_dfi_phyupd_en_mask[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DFI_PHYUPD_EN +: `REGB_DDRC_CH0_SIZE_DFIUPD0_DFI_PHYUPD_EN];
         end
         if (rwselect[45] && write_en) begin
            ff_regb_ddrc_ch0_ctrlupd_pre_srx <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX +: `REGB_DDRC_CH0_SIZE_DFIUPD0_CTRLUPD_PRE_SRX] & regb_ddrc_ch0_dfiupd0_ctrlupd_pre_srx_mask[`REGB_DDRC_CH0_OFFSET_DFIUPD0_CTRLUPD_PRE_SRX +: `REGB_DDRC_CH0_SIZE_DFIUPD0_CTRLUPD_PRE_SRX];
         end
         if (rwselect[45] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_dis_auto_ctrlupd_srx <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX +: `REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX] & regb_ddrc_ch0_dfiupd0_dis_auto_ctrlupd_srx_mask[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD_SRX +: `REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD_SRX];
            end
         end
         if (rwselect[45] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_dis_auto_ctrlupd <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD +: `REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD] & regb_ddrc_ch0_dfiupd0_dis_auto_ctrlupd_mask[`REGB_DDRC_CH0_OFFSET_DFIUPD0_DIS_AUTO_CTRLUPD +: `REGB_DDRC_CH0_SIZE_DFIUPD0_DIS_AUTO_CTRLUPD];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
         if (rwselect[47] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_dfi_init_complete_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN] & regb_ddrc_ch0_dfimisc_dfi_init_complete_en_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_COMPLETE_EN +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_COMPLETE_EN];
            end
         end
         if (rwselect[47] && write_en) begin
            ff_regb_ddrc_ch0_phy_dbi_mode <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_PHY_DBI_MODE +: `REGB_DDRC_CH0_SIZE_DFIMISC_PHY_DBI_MODE] & regb_ddrc_ch0_dfimisc_phy_dbi_mode_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_PHY_DBI_MODE +: `REGB_DDRC_CH0_SIZE_DFIMISC_PHY_DBI_MODE];
         end
         if (rwselect[47] && write_en) begin
            ff_regb_ddrc_ch0_dfi_data_cs_polarity <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_DATA_CS_POLARITY +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_DATA_CS_POLARITY] & regb_ddrc_ch0_dfimisc_dfi_data_cs_polarity_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_DATA_CS_POLARITY +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_DATA_CS_POLARITY];
         end
         if (rwselect[47] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_dfi_init_start <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_START +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_START] & regb_ddrc_ch0_dfimisc_dfi_init_start_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_INIT_START +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_INIT_START];
            end
         end
         if (rwselect[47] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_lp_optimized_write <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_LP_OPTIMIZED_WRITE +: `REGB_DDRC_CH0_SIZE_DFIMISC_LP_OPTIMIZED_WRITE] & regb_ddrc_ch0_dfimisc_lp_optimized_write_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_LP_OPTIMIZED_WRITE +: `REGB_DDRC_CH0_SIZE_DFIMISC_LP_OPTIMIZED_WRITE];
            end
         end
         if (rwselect[47] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_dfi_frequency[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQUENCY +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY] & regb_ddrc_ch0_dfimisc_dfi_frequency_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQUENCY +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQUENCY];
            end
         end
         if (rwselect[47] && write_en) begin
            ff_regb_ddrc_ch0_dfi_freq_fsp[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQ_FSP +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP] & regb_ddrc_ch0_dfimisc_dfi_freq_fsp_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_FREQ_FSP +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_FREQ_FSP];
         end
         if (rwselect[47] && write_en) begin
            ff_regb_ddrc_ch0_dfi_channel_mode[(`REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_CHANNEL_MODE +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE] & regb_ddrc_ch0_dfimisc_dfi_channel_mode_mask[`REGB_DDRC_CH0_OFFSET_DFIMISC_DFI_CHANNEL_MODE +: `REGB_DDRC_CH0_SIZE_DFIMISC_DFI_CHANNEL_MODE];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
         if (rwselect[48] && write_en) begin
            ff_regb_ddrc_ch0_dfi_phymstr_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN +: `REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN] & regb_ddrc_ch0_dfiphymstr_dfi_phymstr_en_mask[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_EN +: `REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_EN];
         end
         if (rwselect[48] && write_en) begin
            ff_regb_ddrc_ch0_dfi_phymstr_blk_ref_x32[(`REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32 +: `REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32] & regb_ddrc_ch0_dfiphymstr_dfi_phymstr_blk_ref_x32_mask[`REGB_DDRC_CH0_OFFSET_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32 +: `REGB_DDRC_CH0_SIZE_DFIPHYMSTR_DFI_PHYMSTR_BLK_REF_X32];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
         if (rwselect[49] && write_en) begin
            ff_regb_ddrc_ch0_dfi0_ctrlmsg_data[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_DATA +: `REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA] & regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_data_mask[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_DATA +: `REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_DATA];
         end
         if (rwselect[49] && write_en) begin
            ff_regb_ddrc_ch0_dfi0_ctrlmsg_cmd[(`REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_CMD +: `REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD] & regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_cmd_mask[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_CMD +: `REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_CMD];
         end
         if (reg_ddrc_dfi0_ctrlmsg_tout_clr_ack_pclk) begin
            ff_regb_ddrc_ch0_dfi0_ctrlmsg_tout_clr <= 1'b0;
         end else begin
            if (rwselect[49] && write_en) begin
               ff_regb_ddrc_ch0_dfi0_ctrlmsg_tout_clr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR +: `REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR] & regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_tout_clr_mask[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR +: `REGB_DDRC_CH0_SIZE_DFI0MSGCTL0_DFI0_CTRLMSG_TOUT_CLR];
            end
         end
         if (reg_ddrc_dfi0_ctrlmsg_req_ack_pclk) begin
            ff_regb_ddrc_ch0_dfi0_ctrlmsg_req <= 1'b0;
            ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved <= 1'b0;
         end else begin
            if (ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_todo & (!ddrc_reg_dfi0_ctrlmsg_req_busy_int)) begin
               ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_todo <= 1'b0;
               ff_regb_ddrc_ch0_dfi0_ctrlmsg_req <= ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved;
            end else if (rwselect[49] & store_rqst & (apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_REQ] & regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_req_mask[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_REQ]) ) begin
               if (ddrc_reg_dfi0_ctrlmsg_req_busy_int) begin
                  ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_todo <= 1'b1;
                  ff_regb_ddrc_ch0_dfi0_ctrlmsg_req_saved <= 1'b1;
               end else begin
                  ff_regb_ddrc_ch0_dfi0_ctrlmsg_req <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_REQ] & regb_ddrc_ch0_dfi0msgctl0_dfi0_ctrlmsg_req_mask[`REGB_DDRC_CH0_OFFSET_DFI0MSGCTL0_DFI0_CTRLMSG_REQ];
               end
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
         if (rwselect[50] && write_en) begin
            ff_regb_ddrc_ch0_wr_poison_slverr_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_SLVERR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_SLVERR_EN] & regb_ddrc_ch0_poisoncfg_wr_poison_slverr_en_mask[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_SLVERR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_SLVERR_EN];
         end
         if (rwselect[50] && write_en) begin
            ff_regb_ddrc_ch0_wr_poison_intr_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_EN] & regb_ddrc_ch0_poisoncfg_wr_poison_intr_en_mask[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_EN];
         end
         if (reg_ddrc_wr_poison_intr_clr_ack_pclk) begin
            ff_regb_ddrc_ch0_wr_poison_intr_clr <= 1'b0;
         end else begin
            if (rwselect[50] && write_en) begin
               ff_regb_ddrc_ch0_wr_poison_intr_clr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_CLR +: `REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_CLR] & regb_ddrc_ch0_poisoncfg_wr_poison_intr_clr_mask[`REGB_DDRC_CH0_OFFSET_POISONCFG_WR_POISON_INTR_CLR +: `REGB_DDRC_CH0_SIZE_POISONCFG_WR_POISON_INTR_CLR];
            end
         end
         if (rwselect[50] && write_en) begin
            ff_regb_ddrc_ch0_rd_poison_slverr_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_SLVERR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_SLVERR_EN] & regb_ddrc_ch0_poisoncfg_rd_poison_slverr_en_mask[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_SLVERR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_SLVERR_EN];
         end
         if (rwselect[50] && write_en) begin
            ff_regb_ddrc_ch0_rd_poison_intr_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_EN] & regb_ddrc_ch0_poisoncfg_rd_poison_intr_en_mask[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_EN +: `REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_EN];
         end
         if (reg_ddrc_rd_poison_intr_clr_ack_pclk) begin
            ff_regb_ddrc_ch0_rd_poison_intr_clr <= 1'b0;
         end else begin
            if (rwselect[50] && write_en) begin
               ff_regb_ddrc_ch0_rd_poison_intr_clr <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_CLR +: `REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_CLR] & regb_ddrc_ch0_poisoncfg_rd_poison_intr_clr_mask[`REGB_DDRC_CH0_OFFSET_POISONCFG_RD_POISON_INTR_CLR +: `REGB_DDRC_CH0_SIZE_POISONCFG_RD_POISON_INTR_CLR];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
         if (rwselect[122] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_dis_wc <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRL0_DIS_WC +: `REGB_DDRC_CH0_SIZE_OPCTRL0_DIS_WC] & regb_ddrc_ch0_opctrl0_dis_wc_mask[`REGB_DDRC_CH0_OFFSET_OPCTRL0_DIS_WC +: `REGB_DDRC_CH0_SIZE_OPCTRL0_DIS_WC];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
         if (rwselect[123] && write_en) begin
            ff_regb_ddrc_ch0_dis_dq <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_DQ +: `REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_DQ] & regb_ddrc_ch0_opctrl1_dis_dq_mask[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_DQ +: `REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_DQ];
         end
         if (rwselect[123] && write_en) begin
            ff_regb_ddrc_ch0_dis_hif <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_HIF +: `REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_HIF] & regb_ddrc_ch0_opctrl1_dis_hif_mask[`REGB_DDRC_CH0_OFFSET_OPCTRL1_DIS_HIF +: `REGB_DDRC_CH0_SIZE_OPCTRL1_DIS_HIF];
         end
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
         if (reg_ddrc_zq_calib_short_ack_pclk) begin
            ff_regb_ddrc_ch0_zq_calib_short <= 1'b0;
            ff_regb_ddrc_ch0_zq_calib_short_saved <= 1'b0;
         end else begin
            if (ff_regb_ddrc_ch0_zq_calib_short_todo & (!ddrc_reg_zq_calib_short_busy_int)) begin
               ff_regb_ddrc_ch0_zq_calib_short_todo <= 1'b0;
               ff_regb_ddrc_ch0_zq_calib_short <= ff_regb_ddrc_ch0_zq_calib_short_saved;
            end else if (rwselect[124] & store_rqst & (apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_ZQ_CALIB_SHORT] & regb_ddrc_ch0_opctrlcmd_zq_calib_short_mask[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_ZQ_CALIB_SHORT]) ) begin
               if (ddrc_reg_zq_calib_short_busy_int) begin
                  ff_regb_ddrc_ch0_zq_calib_short_todo <= 1'b1;
                  ff_regb_ddrc_ch0_zq_calib_short_saved <= 1'b1;
               end else begin
                  ff_regb_ddrc_ch0_zq_calib_short <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_ZQ_CALIB_SHORT] & regb_ddrc_ch0_opctrlcmd_zq_calib_short_mask[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_ZQ_CALIB_SHORT];
               end
            end
         end
         if (reg_ddrc_ctrlupd_ack_pclk) begin
            ff_regb_ddrc_ch0_ctrlupd <= 1'b0;
            ff_regb_ddrc_ch0_ctrlupd_saved <= 1'b0;
         end else begin
            if (ff_regb_ddrc_ch0_ctrlupd_todo & (!ddrc_reg_ctrlupd_busy_int)) begin
               ff_regb_ddrc_ch0_ctrlupd_todo <= 1'b0;
               ff_regb_ddrc_ch0_ctrlupd <= ff_regb_ddrc_ch0_ctrlupd_saved;
            end else if (rwselect[124] & store_rqst & (apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_CTRLUPD] & regb_ddrc_ch0_opctrlcmd_ctrlupd_mask[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_CTRLUPD]) ) begin
               if (ddrc_reg_ctrlupd_busy_int) begin
                  ff_regb_ddrc_ch0_ctrlupd_todo <= 1'b1;
                  ff_regb_ddrc_ch0_ctrlupd_saved <= 1'b1;
               end else begin
                  ff_regb_ddrc_ch0_ctrlupd <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_CTRLUPD] & regb_ddrc_ch0_opctrlcmd_ctrlupd_mask[`REGB_DDRC_CH0_OFFSET_OPCTRLCMD_CTRLUPD];
               end
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
         if (reg_ddrc_rank0_refresh_ack_pclk) begin
            ff_regb_ddrc_ch0_rank0_refresh <= 1'b0;
            ff_regb_ddrc_ch0_rank0_refresh_saved <= 1'b0;
         end else begin
            if (ff_regb_ddrc_ch0_rank0_refresh_todo & (!ddrc_reg_rank0_refresh_busy_int)) begin
               ff_regb_ddrc_ch0_rank0_refresh_todo <= 1'b0;
               ff_regb_ddrc_ch0_rank0_refresh <= ff_regb_ddrc_ch0_rank0_refresh_saved;
            end else if (rwselect[125] & store_rqst & (apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPREFCTRL0_RANK0_REFRESH] & regb_ddrc_ch0_oprefctrl0_rank0_refresh_mask[`REGB_DDRC_CH0_OFFSET_OPREFCTRL0_RANK0_REFRESH]) ) begin
               if (ddrc_reg_rank0_refresh_busy_int) begin
                  ff_regb_ddrc_ch0_rank0_refresh_todo <= 1'b1;
                  ff_regb_ddrc_ch0_rank0_refresh_saved <= 1'b1;
               end else begin
                  ff_regb_ddrc_ch0_rank0_refresh <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_OPREFCTRL0_RANK0_REFRESH] & regb_ddrc_ch0_oprefctrl0_rank0_refresh_mask[`REGB_DDRC_CH0_OFFSET_OPREFCTRL0_RANK0_REFRESH];
               end
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
         if (rwselect[127] && write_en) begin
            cfgs_ff_regb_ddrc_ch0_sw_done <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SWCTL_SW_DONE +: `REGB_DDRC_CH0_SIZE_SWCTL_SW_DONE] & regb_ddrc_ch0_swctl_sw_done_mask[`REGB_DDRC_CH0_OFFSET_SWCTL_SW_DONE +: `REGB_DDRC_CH0_SIZE_SWCTL_SW_DONE];
         end
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
         if (rwselect[131] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_dm_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DBICTL_DM_EN +: `REGB_DDRC_CH0_SIZE_DBICTL_DM_EN] & regb_ddrc_ch0_dbictl_dm_en_mask[`REGB_DDRC_CH0_OFFSET_DBICTL_DM_EN +: `REGB_DDRC_CH0_SIZE_DBICTL_DM_EN];
            end
         end
         if (rwselect[131] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_wr_dbi_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DBICTL_WR_DBI_EN +: `REGB_DDRC_CH0_SIZE_DBICTL_WR_DBI_EN] & regb_ddrc_ch0_dbictl_wr_dbi_en_mask[`REGB_DDRC_CH0_OFFSET_DBICTL_WR_DBI_EN +: `REGB_DDRC_CH0_SIZE_DBICTL_WR_DBI_EN];
            end
         end
         if (rwselect[131] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_rd_dbi_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DBICTL_RD_DBI_EN +: `REGB_DDRC_CH0_SIZE_DBICTL_RD_DBI_EN] & regb_ddrc_ch0_dbictl_rd_dbi_en_mask[`REGB_DDRC_CH0_OFFSET_DBICTL_RD_DBI_EN +: `REGB_DDRC_CH0_SIZE_DBICTL_RD_DBI_EN];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
         if (rwselect[132] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_rank0_wr_odt[(`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_WR_ODT +: `REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT] & regb_ddrc_ch0_odtmap_rank0_wr_odt_mask[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_WR_ODT +: `REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_WR_ODT];
            end
         end
         if (rwselect[132] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_ddrc_ch0_rank0_rd_odt[(`REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_RD_ODT +: `REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT] & regb_ddrc_ch0_odtmap_rank0_rd_odt_mask[`REGB_DDRC_CH0_OFFSET_ODTMAP_RANK0_RD_ODT +: `REGB_DDRC_CH0_SIZE_ODTMAP_RANK0_RD_ODT];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
         if (rwselect[133] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_rd_data_copy_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DATACTL0_RD_DATA_COPY_EN +: `REGB_DDRC_CH0_SIZE_DATACTL0_RD_DATA_COPY_EN] & regb_ddrc_ch0_datactl0_rd_data_copy_en_mask[`REGB_DDRC_CH0_OFFSET_DATACTL0_RD_DATA_COPY_EN +: `REGB_DDRC_CH0_SIZE_DATACTL0_RD_DATA_COPY_EN];
            end
         end
         if (rwselect[133] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_wr_data_copy_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_COPY_EN +: `REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_COPY_EN] & regb_ddrc_ch0_datactl0_wr_data_copy_en_mask[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_COPY_EN +: `REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_COPY_EN];
            end
         end
         if (rwselect[133] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_wr_data_x_en <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_X_EN +: `REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_X_EN] & regb_ddrc_ch0_datactl0_wr_data_x_en_mask[`REGB_DDRC_CH0_OFFSET_DATACTL0_WR_DATA_X_EN +: `REGB_DDRC_CH0_SIZE_DATACTL0_WR_DATA_X_EN];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
         if (rwselect[134] && write_en) begin
            cfgs_ff_regb_ddrc_ch0_sw_static_unlock <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK +: `REGB_DDRC_CH0_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK] & regb_ddrc_ch0_swctlstatic_sw_static_unlock_mask[`REGB_DDRC_CH0_OFFSET_SWCTLSTATIC_SW_STATIC_UNLOCK +: `REGB_DDRC_CH0_SIZE_SWCTLSTATIC_SW_STATIC_UNLOCK];
         end
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
         if (rwselect[135] && write_en) begin
            ff_regb_ddrc_ch0_pre_cke_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_INITTMG0_PRE_CKE_X1024 +: `REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024] & regb_ddrc_ch0_inittmg0_pre_cke_x1024_mask[`REGB_DDRC_CH0_OFFSET_INITTMG0_PRE_CKE_X1024 +: `REGB_DDRC_CH0_SIZE_INITTMG0_PRE_CKE_X1024];
         end
         if (rwselect[135] && write_en) begin
            ff_regb_ddrc_ch0_post_cke_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_INITTMG0_POST_CKE_X1024 +: `REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024] & regb_ddrc_ch0_inittmg0_post_cke_x1024_mask[`REGB_DDRC_CH0_OFFSET_INITTMG0_POST_CKE_X1024 +: `REGB_DDRC_CH0_SIZE_INITTMG0_POST_CKE_X1024];
         end
         if (rwselect[135] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_ddrc_ch0_skip_dram_init[(`REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_INITTMG0_SKIP_DRAM_INIT +: `REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT] & regb_ddrc_ch0_inittmg0_skip_dram_init_mask[`REGB_DDRC_CH0_OFFSET_INITTMG0_SKIP_DRAM_INIT +: `REGB_DDRC_CH0_SIZE_INITTMG0_SKIP_DRAM_INIT];
            end
         end
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
         if (rwselect[136] && write_en) begin
            ff_regb_ddrc_ch0_dram_rstn_x1024[(`REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024) -1:0] <= apb_data_expanded[`REGB_DDRC_CH0_OFFSET_INITTMG1_DRAM_RSTN_X1024 +: `REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024] & regb_ddrc_ch0_inittmg1_dram_rstn_x1024_mask[`REGB_DDRC_CH0_OFFSET_INITTMG1_DRAM_RSTN_X1024 +: `REGB_DDRC_CH0_SIZE_INITTMG1_DRAM_RSTN_X1024];
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
         if (rwselect[222] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_bank_b0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B0 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0] & regb_addr_map0_addrmap3_addrmap_bank_b0_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B0 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B0];
            end
         end
         if (rwselect[222] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_bank_b1[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B1 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1] & regb_addr_map0_addrmap3_addrmap_bank_b1_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B1 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B1];
            end
         end
         if (rwselect[222] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_bank_b2[(`REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B2 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2] & regb_addr_map0_addrmap3_addrmap_bank_b2_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP3_ADDRMAP_BANK_B2 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP3_ADDRMAP_BANK_B2];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
         if (rwselect[223] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_bg_b0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B0 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0] & regb_addr_map0_addrmap4_addrmap_bg_b0_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B0 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B0];
            end
         end
         if (rwselect[223] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_bg_b1[(`REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B1 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1] & regb_addr_map0_addrmap4_addrmap_bg_b1_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP4_ADDRMAP_BG_B1 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP4_ADDRMAP_BG_B1];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
         if (rwselect[224] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b7[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B7 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7] & regb_addr_map0_addrmap5_addrmap_col_b7_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B7 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B7];
            end
         end
         if (rwselect[224] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b8[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B8 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8] & regb_addr_map0_addrmap5_addrmap_col_b8_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B8 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B8];
            end
         end
         if (rwselect[224] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b9[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B9 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9] & regb_addr_map0_addrmap5_addrmap_col_b9_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B9 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B9];
            end
         end
         if (rwselect[224] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b10[(`REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B10 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10] & regb_addr_map0_addrmap5_addrmap_col_b10_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP5_ADDRMAP_COL_B10 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP5_ADDRMAP_COL_B10];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
         if (rwselect[225] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b3[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B3 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3] & regb_addr_map0_addrmap6_addrmap_col_b3_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B3 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B3];
            end
         end
         if (rwselect[225] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b4[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B4 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4] & regb_addr_map0_addrmap6_addrmap_col_b4_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B4 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B4];
            end
         end
         if (rwselect[225] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b5[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B5 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5] & regb_addr_map0_addrmap6_addrmap_col_b5_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B5 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B5];
            end
         end
         if (rwselect[225] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_col_b6[(`REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B6 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6] & regb_addr_map0_addrmap6_addrmap_col_b6_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP6_ADDRMAP_COL_B6 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP6_ADDRMAP_COL_B6];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
         if (rwselect[226] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b14[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B14 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14] & regb_addr_map0_addrmap7_addrmap_row_b14_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B14 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B14];
            end
         end
         if (rwselect[226] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b15[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B15 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15] & regb_addr_map0_addrmap7_addrmap_row_b15_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B15 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B15];
            end
         end
         if (rwselect[226] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b16[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16] & regb_addr_map0_addrmap7_addrmap_row_b16_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B16 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B16];
            end
         end
         if (rwselect[226] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b17[(`REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17] & regb_addr_map0_addrmap7_addrmap_row_b17_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP7_ADDRMAP_ROW_B17 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP7_ADDRMAP_ROW_B17];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
         if (rwselect[227] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b10[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B10 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10] & regb_addr_map0_addrmap8_addrmap_row_b10_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B10 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B10];
            end
         end
         if (rwselect[227] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b11[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B11 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11] & regb_addr_map0_addrmap8_addrmap_row_b11_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B11 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B11];
            end
         end
         if (rwselect[227] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b12[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B12 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12] & regb_addr_map0_addrmap8_addrmap_row_b12_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B12 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B12];
            end
         end
         if (rwselect[227] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b13[(`REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B13 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13] & regb_addr_map0_addrmap8_addrmap_row_b13_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP8_ADDRMAP_ROW_B13 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP8_ADDRMAP_ROW_B13];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
         if (rwselect[228] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b6[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B6 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6] & regb_addr_map0_addrmap9_addrmap_row_b6_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B6 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B6];
            end
         end
         if (rwselect[228] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b7[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B7 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7] & regb_addr_map0_addrmap9_addrmap_row_b7_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B7 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B7];
            end
         end
         if (rwselect[228] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b8[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B8 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8] & regb_addr_map0_addrmap9_addrmap_row_b8_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B8 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B8];
            end
         end
         if (rwselect[228] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b9[(`REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B9 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9] & regb_addr_map0_addrmap9_addrmap_row_b9_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP9_ADDRMAP_ROW_B9 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP9_ADDRMAP_ROW_B9];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
         if (rwselect[229] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b2[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B2 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2] & regb_addr_map0_addrmap10_addrmap_row_b2_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B2 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B2];
            end
         end
         if (rwselect[229] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b3[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B3 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3] & regb_addr_map0_addrmap10_addrmap_row_b3_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B3 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B3];
            end
         end
         if (rwselect[229] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b4[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B4 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4] & regb_addr_map0_addrmap10_addrmap_row_b4_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B4 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B4];
            end
         end
         if (rwselect[229] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b5[(`REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B5 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5] & regb_addr_map0_addrmap10_addrmap_row_b5_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP10_ADDRMAP_ROW_B5 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP10_ADDRMAP_ROW_B5];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
         if (rwselect[230] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b0[(`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B0 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0] & regb_addr_map0_addrmap11_addrmap_row_b0_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B0 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B0];
            end
         end
         if (rwselect[230] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_addr_map0_addrmap_row_b1[(`REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B1 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1] & regb_addr_map0_addrmap11_addrmap_row_b1_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP11_ADDRMAP_ROW_B1 +: `REGB_ADDR_MAP0_SIZE_ADDRMAP11_ADDRMAP_ROW_B1];
            end
         end
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
         if (rwselect[231] && write_en) begin
            ff_regb_addr_map0_nonbinary_device_density[(`REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY) -1:0] <= apb_data_expanded[`REGB_ADDR_MAP0_OFFSET_ADDRMAP12_NONBINARY_DEVICE_DENSITY +: `REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY] & regb_addr_map0_addrmap12_nonbinary_device_density_mask[`REGB_ADDR_MAP0_OFFSET_ADDRMAP12_NONBINARY_DEVICE_DENSITY +: `REGB_ADDR_MAP0_SIZE_ADDRMAP12_NONBINARY_DEVICE_DENSITY];
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
         if (rwselect[245] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_go2critical_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCCFG_GO2CRITICAL_EN +: `REGB_ARB_PORT0_SIZE_PCCFG_GO2CRITICAL_EN] & regb_arb_port0_pccfg_go2critical_en_mask[`REGB_ARB_PORT0_OFFSET_PCCFG_GO2CRITICAL_EN +: `REGB_ARB_PORT0_SIZE_PCCFG_GO2CRITICAL_EN];
            end
         end
         if (rwselect[245] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_pagematch_limit <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCCFG_PAGEMATCH_LIMIT +: `REGB_ARB_PORT0_SIZE_PCCFG_PAGEMATCH_LIMIT] & regb_arb_port0_pccfg_pagematch_limit_mask[`REGB_ARB_PORT0_OFFSET_PCCFG_PAGEMATCH_LIMIT +: `REGB_ARB_PORT0_SIZE_PCCFG_PAGEMATCH_LIMIT];
            end
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
         if (rwselect[246] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_rd_port_priority[(`REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PRIORITY +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY] & regb_arb_port0_pcfgr_rd_port_priority_mask[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PRIORITY +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PRIORITY];
            end
         end
         if (rwselect[246] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_rd_port_aging_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_AGING_EN +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_AGING_EN] & regb_arb_port0_pcfgr_rd_port_aging_en_mask[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_AGING_EN +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_AGING_EN];
            end
         end
         if (rwselect[246] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_rd_port_urgent_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_URGENT_EN +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_URGENT_EN] & regb_arb_port0_pcfgr_rd_port_urgent_en_mask[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_URGENT_EN +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_URGENT_EN];
            end
         end
         if (rwselect[246] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_rd_port_pagematch_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PAGEMATCH_EN +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PAGEMATCH_EN] & regb_arb_port0_pcfgr_rd_port_pagematch_en_mask[`REGB_ARB_PORT0_OFFSET_PCFGR_RD_PORT_PAGEMATCH_EN +: `REGB_ARB_PORT0_SIZE_PCFGR_RD_PORT_PAGEMATCH_EN];
            end
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
         if (rwselect[247] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_wr_port_priority[(`REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PRIORITY +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY] & regb_arb_port0_pcfgw_wr_port_priority_mask[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PRIORITY +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PRIORITY];
            end
         end
         if (rwselect[247] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_wr_port_aging_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_AGING_EN +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_AGING_EN] & regb_arb_port0_pcfgw_wr_port_aging_en_mask[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_AGING_EN +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_AGING_EN];
            end
         end
         if (rwselect[247] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_wr_port_urgent_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_URGENT_EN +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_URGENT_EN] & regb_arb_port0_pcfgw_wr_port_urgent_en_mask[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_URGENT_EN +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_URGENT_EN];
            end
         end
         if (rwselect[247] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_wr_port_pagematch_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PAGEMATCH_EN +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PAGEMATCH_EN] & regb_arb_port0_pcfgw_wr_port_pagematch_en_mask[`REGB_ARB_PORT0_OFFSET_PCFGW_WR_PORT_PAGEMATCH_EN +: `REGB_ARB_PORT0_SIZE_PCFGW_WR_PORT_PAGEMATCH_EN];
            end
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
         if (rwselect[280] && write_en) begin
            ff_regb_arb_port0_port_en <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN +: `REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN] & regb_arb_port0_pctrl_port_en_mask[`REGB_ARB_PORT0_OFFSET_PCTRL_PORT_EN +: `REGB_ARB_PORT0_SIZE_PCTRL_PORT_EN];
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
         if (rwselect[281] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_rqos_map_level1[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_LEVEL1 +: `REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1] & regb_arb_port0_pcfgqos0_rqos_map_level1_mask[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_LEVEL1 +: `REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_LEVEL1];
            end
         end
         if (rwselect[281] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_rqos_map_region0[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION0 +: `REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0] & regb_arb_port0_pcfgqos0_rqos_map_region0_mask[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION0 +: `REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION0];
            end
         end
         if (rwselect[281] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_rqos_map_region1[(`REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION1 +: `REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1] & regb_arb_port0_pcfgqos0_rqos_map_region1_mask[`REGB_ARB_PORT0_OFFSET_PCFGQOS0_RQOS_MAP_REGION1 +: `REGB_ARB_PORT0_SIZE_PCFGQOS0_RQOS_MAP_REGION1];
            end
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
         if (rwselect[282] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_rqos_map_timeoutb[(`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTB +: `REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB] & regb_arb_port0_pcfgqos1_rqos_map_timeoutb_mask[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTB +: `REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTB];
            end
         end
         if (rwselect[282] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_rqos_map_timeoutr[(`REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTR +: `REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR] & regb_arb_port0_pcfgqos1_rqos_map_timeoutr_mask[`REGB_ARB_PORT0_OFFSET_PCFGQOS1_RQOS_MAP_TIMEOUTR +: `REGB_ARB_PORT0_SIZE_PCFGQOS1_RQOS_MAP_TIMEOUTR];
            end
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
         if (rwselect[283] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_wqos_map_level1[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL1 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1] & regb_arb_port0_pcfgwqos0_wqos_map_level1_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL1 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL1];
            end
         end
         if (rwselect[283] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_wqos_map_level2[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL2 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2] & regb_arb_port0_pcfgwqos0_wqos_map_level2_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_LEVEL2 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_LEVEL2];
            end
         end
         if (rwselect[283] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_wqos_map_region0[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION0 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0] & regb_arb_port0_pcfgwqos0_wqos_map_region0_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION0 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION0];
            end
         end
         if (rwselect[283] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_wqos_map_region1[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION1 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1] & regb_arb_port0_pcfgwqos0_wqos_map_region1_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION1 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION1];
            end
         end
         if (rwselect[283] && write_en) begin
            if (quasi_dyn_wr_en_aclk_0 == 1'b0) begin // quasi dynamic write enable @aclk_0
               cfgs_ff_regb_arb_port0_wqos_map_region2[(`REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION2 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2] & regb_arb_port0_pcfgwqos0_wqos_map_region2_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS0_WQOS_MAP_REGION2 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS0_WQOS_MAP_REGION2];
            end
         end
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
         if (rwselect[284] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_wqos_map_timeout1[(`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT1 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1] & regb_arb_port0_pcfgwqos1_wqos_map_timeout1_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT1 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT1];
            end
         end
         if (rwselect[284] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_arb_port0_wqos_map_timeout2[(`REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2) -1:0] <= apb_data_expanded[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT2 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2] & regb_arb_port0_pcfgwqos1_wqos_map_timeout2_mask[`REGB_ARB_PORT0_OFFSET_PCFGWQOS1_WQOS_MAP_TIMEOUT2 +: `REGB_ARB_PORT0_SIZE_PCFGWQOS1_WQOS_MAP_TIMEOUT2];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
         if (rwselect[1471] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ras_min[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MIN +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN] & regb_freq0_ch0_dramset1tmg0_t_ras_min_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MIN +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MIN];
            end
         end
         if (rwselect[1471] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ras_max[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MAX +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX] & regb_freq0_ch0_dramset1tmg0_t_ras_max_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_RAS_MAX +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_RAS_MAX];
            end
         end
         if (rwselect[1471] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_faw[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_FAW +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW] & regb_freq0_ch0_dramset1tmg0_t_faw_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_T_FAW +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_T_FAW];
            end
         end
         if (rwselect[1471] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_wr2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_WR2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE] & regb_freq0_ch0_dramset1tmg0_wr2pre_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG0_WR2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG0_WR2PRE];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
         if (rwselect[1472] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_rc[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_RC +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC] & regb_freq0_ch0_dramset1tmg1_t_rc_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_RC +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_RC];
            end
         end
         if (rwselect[1472] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_rd2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_RD2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE] & regb_freq0_ch0_dramset1tmg1_rd2pre_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_RD2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_RD2PRE];
            end
         end
         if (rwselect[1472] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_xp[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_XP +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP] & regb_freq0_ch0_dramset1tmg1_t_xp_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG1_T_XP +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG1_T_XP];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
         if (rwselect[1473] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_wr2rd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WR2RD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD] & regb_freq0_ch0_dramset1tmg2_wr2rd_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WR2RD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WR2RD];
            end
         end
         if (rwselect[1473] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_rd2wr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_RD2WR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR] & regb_freq0_ch0_dramset1tmg2_rd2wr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_RD2WR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_RD2WR];
            end
         end
         if (rwselect[1473] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_read_latency[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_READ_LATENCY +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY] & regb_freq0_ch0_dramset1tmg2_read_latency_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_READ_LATENCY +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_READ_LATENCY];
            end
         end
         if (rwselect[1473] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_write_latency[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WRITE_LATENCY +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY] & regb_freq0_ch0_dramset1tmg2_write_latency_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG2_WRITE_LATENCY +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG2_WRITE_LATENCY];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
         if (rwselect[1474] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_wr2mr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_WR2MR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR] & regb_freq0_ch0_dramset1tmg3_wr2mr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_WR2MR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_WR2MR];
            end
         end
         if (rwselect[1474] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_rd2mr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_RD2MR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR] & regb_freq0_ch0_dramset1tmg3_rd2mr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_RD2MR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_RD2MR];
            end
         end
         if (rwselect[1474] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_mr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_T_MR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR] & regb_freq0_ch0_dramset1tmg3_t_mr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG3_T_MR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG3_T_MR];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
         if (rwselect[1475] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_rp[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RP +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP] & regb_freq0_ch0_dramset1tmg4_t_rp_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RP +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RP];
            end
         end
         if (rwselect[1475] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_rrd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RRD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD] & regb_freq0_ch0_dramset1tmg4_t_rrd_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RRD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RRD];
            end
         end
         if (rwselect[1475] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ccd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_CCD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD] & regb_freq0_ch0_dramset1tmg4_t_ccd_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_CCD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_CCD];
            end
         end
         if (rwselect[1475] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_rcd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RCD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD] & regb_freq0_ch0_dramset1tmg4_t_rcd_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG4_T_RCD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG4_T_RCD];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
         if (rwselect[1476] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_t_cke[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE] & regb_freq0_ch0_dramset1tmg5_t_cke_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKE];
            end
         end
         if (rwselect[1476] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_t_ckesr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKESR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR] & regb_freq0_ch0_dramset1tmg5_t_ckesr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKESR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKESR];
            end
         end
         if (rwselect[1476] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_t_cksre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE] & regb_freq0_ch0_dramset1tmg5_t_cksre_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRE];
            end
         end
         if (rwselect[1476] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_t_cksrx[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRX +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX] & regb_freq0_ch0_dramset1tmg5_t_cksrx_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG5_T_CKSRX +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG5_T_CKSRX];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
         if (rwselect[1477] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ckcsx[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG6_T_CKCSX +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX] & regb_freq0_ch0_dramset1tmg6_t_ckcsx_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG6_T_CKCSX +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG6_T_CKCSX];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
         if (rwselect[1478] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_t_csh[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG7_T_CSH +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH] & regb_freq0_ch0_dramset1tmg7_t_csh_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG7_T_CSH +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG7_T_CSH];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
         if (rwselect[1480] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_wr2rd_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_WR2RD_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S] & regb_freq0_ch0_dramset1tmg9_wr2rd_s_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_WR2RD_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_WR2RD_S];
            end
         end
         if (rwselect[1480] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_rrd_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_RRD_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S] & regb_freq0_ch0_dramset1tmg9_t_rrd_s_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_RRD_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_RRD_S];
            end
         end
         if (rwselect[1480] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ccd_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_CCD_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S] & regb_freq0_ch0_dramset1tmg9_t_ccd_s_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG9_T_CCD_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG9_T_CCD_S];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
         if (rwselect[1483] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_cmdcke[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG12_T_CMDCKE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE] & regb_freq0_ch0_dramset1tmg12_t_cmdcke_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG12_T_CMDCKE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG12_T_CMDCKE];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
         if (rwselect[1484] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ppd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_PPD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD] & regb_freq0_ch0_dramset1tmg13_t_ppd_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_PPD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_PPD];
            end
         end
         if (rwselect[1484] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_ccd_mw[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_CCD_MW +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW] & regb_freq0_ch0_dramset1tmg13_t_ccd_mw_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_T_CCD_MW +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_T_CCD_MW];
            end
         end
         if (rwselect[1484] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_odtloff[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_ODTLOFF +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF] & regb_freq0_ch0_dramset1tmg13_odtloff_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG13_ODTLOFF +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG13_ODTLOFF];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
         if (rwselect[1485] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_xsr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_XSR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR] & regb_freq0_ch0_dramset1tmg14_t_xsr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_XSR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_XSR];
            end
         end
         if (rwselect[1485] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_osco[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_OSCO +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO] & regb_freq0_ch0_dramset1tmg14_t_osco_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG14_T_OSCO +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG14_T_OSCO];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
         if (rwselect[1494] && write_en) begin
            ff_regb_freq0_ch0_t_pdn[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_PDN +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN] & regb_freq0_ch0_dramset1tmg23_t_pdn_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_PDN +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_PDN];
         end
         if (rwselect[1494] && write_en) begin
            ff_regb_freq0_ch0_t_xsr_dsm_x1024[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_XSR_DSM_X1024 +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024] & regb_freq0_ch0_dramset1tmg23_t_xsr_dsm_x1024_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG23_T_XSR_DSM_X1024 +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG23_T_XSR_DSM_X1024];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
         if (rwselect[1495] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_max_wr_sync[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_WR_SYNC +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC] & regb_freq0_ch0_dramset1tmg24_max_wr_sync_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_WR_SYNC +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_WR_SYNC];
            end
         end
         if (rwselect[1495] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_max_rd_sync[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_RD_SYNC +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC] & regb_freq0_ch0_dramset1tmg24_max_rd_sync_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_MAX_RD_SYNC +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_MAX_RD_SYNC];
            end
         end
         if (rwselect[1495] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_rd2wr_s[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_RD2WR_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S] & regb_freq0_ch0_dramset1tmg24_rd2wr_s_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_RD2WR_S +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_RD2WR_S];
            end
         end
         if (rwselect[1495] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_bank_org[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_BANK_ORG +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG] & regb_freq0_ch0_dramset1tmg24_bank_org_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG24_BANK_ORG +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG24_BANK_ORG];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
         if (rwselect[1496] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_rda2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_RDA2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE] & regb_freq0_ch0_dramset1tmg25_rda2pre_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_RDA2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_RDA2PRE];
            end
         end
         if (rwselect[1496] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_wra2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_WRA2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE] & regb_freq0_ch0_dramset1tmg25_wra2pre_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_WRA2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_WRA2PRE];
            end
         end
         if (rwselect[1496] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_lpddr4_diff_bank_rwa2pre[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE] & regb_freq0_ch0_dramset1tmg25_lpddr4_diff_bank_rwa2pre_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG25_LPDDR4_DIFF_BANK_RWA2PRE];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
         if (rwselect[1501] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_mrr2rd[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2RD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD] & regb_freq0_ch0_dramset1tmg30_mrr2rd_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2RD +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2RD];
            end
         end
         if (rwselect[1501] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_mrr2wr[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2WR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR] & regb_freq0_ch0_dramset1tmg30_mrr2wr_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2WR +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2WR];
            end
         end
         if (rwselect[1501] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_mrr2mrw[(`REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2MRW +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW] & regb_freq0_ch0_dramset1tmg30_mrr2mrw_mask[`REGB_FREQ0_CH0_OFFSET_DRAMSET1TMG30_MRR2MRW +: `REGB_FREQ0_CH0_SIZE_DRAMSET1TMG30_MRR2MRW];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
         if (rwselect[1527] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_emr[(`REGB_FREQ0_CH0_SIZE_INITMR0_EMR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR0_EMR +: `REGB_FREQ0_CH0_SIZE_INITMR0_EMR] & regb_freq0_ch0_initmr0_emr_mask[`REGB_FREQ0_CH0_OFFSET_INITMR0_EMR +: `REGB_FREQ0_CH0_SIZE_INITMR0_EMR];
            end
         end
         if (rwselect[1527] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_mr[(`REGB_FREQ0_CH0_SIZE_INITMR0_MR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR0_MR +: `REGB_FREQ0_CH0_SIZE_INITMR0_MR] & regb_freq0_ch0_initmr0_mr_mask[`REGB_FREQ0_CH0_OFFSET_INITMR0_MR +: `REGB_FREQ0_CH0_SIZE_INITMR0_MR];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
         if (rwselect[1528] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_emr3[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR3) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR3 +: `REGB_FREQ0_CH0_SIZE_INITMR1_EMR3] & regb_freq0_ch0_initmr1_emr3_mask[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR3 +: `REGB_FREQ0_CH0_SIZE_INITMR1_EMR3];
            end
         end
         if (rwselect[1528] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_emr2[(`REGB_FREQ0_CH0_SIZE_INITMR1_EMR2) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR2 +: `REGB_FREQ0_CH0_SIZE_INITMR1_EMR2] & regb_freq0_ch0_initmr1_emr2_mask[`REGB_FREQ0_CH0_OFFSET_INITMR1_EMR2 +: `REGB_FREQ0_CH0_SIZE_INITMR1_EMR2];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
         if (rwselect[1529] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_mr5[(`REGB_FREQ0_CH0_SIZE_INITMR2_MR5) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR5 +: `REGB_FREQ0_CH0_SIZE_INITMR2_MR5] & regb_freq0_ch0_initmr2_mr5_mask[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR5 +: `REGB_FREQ0_CH0_SIZE_INITMR2_MR5];
            end
         end
         if (rwselect[1529] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_mr4[(`REGB_FREQ0_CH0_SIZE_INITMR2_MR4) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR4 +: `REGB_FREQ0_CH0_SIZE_INITMR2_MR4] & regb_freq0_ch0_initmr2_mr4_mask[`REGB_FREQ0_CH0_OFFSET_INITMR2_MR4 +: `REGB_FREQ0_CH0_SIZE_INITMR2_MR4];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
         if (rwselect[1530] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_mr6[(`REGB_FREQ0_CH0_SIZE_INITMR3_MR6) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR6 +: `REGB_FREQ0_CH0_SIZE_INITMR3_MR6] & regb_freq0_ch0_initmr3_mr6_mask[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR6 +: `REGB_FREQ0_CH0_SIZE_INITMR3_MR6];
            end
         end
         if (rwselect[1530] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_mr22[(`REGB_FREQ0_CH0_SIZE_INITMR3_MR22) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR22 +: `REGB_FREQ0_CH0_SIZE_INITMR3_MR22] & regb_freq0_ch0_initmr3_mr22_mask[`REGB_FREQ0_CH0_OFFSET_INITMR3_MR22 +: `REGB_FREQ0_CH0_SIZE_INITMR3_MR22];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
         if (rwselect[1531] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_tphy_wrlat[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRLAT +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT] & regb_freq0_ch0_dfitmg0_dfi_tphy_wrlat_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRLAT +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRLAT];
            end
         end
         if (rwselect[1531] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_tphy_wrdata[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRDATA +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA] & regb_freq0_ch0_dfitmg0_dfi_tphy_wrdata_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_TPHY_WRDATA +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_TPHY_WRDATA];
            end
         end
         if (rwselect[1531] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_t_rddata_en[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_RDDATA_EN +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN] & regb_freq0_ch0_dfitmg0_dfi_t_rddata_en_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_RDDATA_EN +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_RDDATA_EN];
            end
         end
         if (rwselect[1531] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_t_ctrl_delay[(`REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_CTRL_DELAY +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY] & regb_freq0_ch0_dfitmg0_dfi_t_ctrl_delay_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG0_DFI_T_CTRL_DELAY +: `REGB_FREQ0_CH0_SIZE_DFITMG0_DFI_T_CTRL_DELAY];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
         if (rwselect[1532] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_t_dram_clk_enable[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE +: `REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE] & regb_freq0_ch0_dfitmg1_dfi_t_dram_clk_enable_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_ENABLE +: `REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_ENABLE];
            end
         end
         if (rwselect[1532] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_t_dram_clk_disable[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE +: `REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE] & regb_freq0_ch0_dfitmg1_dfi_t_dram_clk_disable_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_DRAM_CLK_DISABLE +: `REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_DRAM_CLK_DISABLE];
            end
         end
         if (rwselect[1532] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_dfi_t_wrdata_delay[(`REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY +: `REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY] & regb_freq0_ch0_dfitmg1_dfi_t_wrdata_delay_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG1_DFI_T_WRDATA_DELAY +: `REGB_FREQ0_CH0_SIZE_DFITMG1_DFI_T_WRDATA_DELAY];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
         if (rwselect[1533] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_tphy_wrcslat[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_WRCSLAT +: `REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT] & regb_freq0_ch0_dfitmg2_dfi_tphy_wrcslat_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_WRCSLAT +: `REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_WRCSLAT];
            end
         end
         if (rwselect[1533] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_tphy_rdcslat[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_RDCSLAT +: `REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT] & regb_freq0_ch0_dfitmg2_dfi_tphy_rdcslat_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TPHY_RDCSLAT +: `REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TPHY_RDCSLAT];
            end
         end
         if (rwselect[1533] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_delay[(`REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TWCK_DELAY +: `REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY] & regb_freq0_ch0_dfitmg2_dfi_twck_delay_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG2_DFI_TWCK_DELAY +: `REGB_FREQ0_CH0_SIZE_DFITMG2_DFI_TWCK_DELAY];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
         if (rwselect[1535] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_dis[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_DIS +: `REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS] & regb_freq0_ch0_dfitmg4_dfi_twck_dis_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_DIS +: `REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_DIS];
            end
         end
         if (rwselect[1535] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_en_wr[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_WR +: `REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR] & regb_freq0_ch0_dfitmg4_dfi_twck_en_wr_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_WR +: `REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_WR];
            end
         end
         if (rwselect[1535] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_en_rd[(`REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_RD +: `REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD] & regb_freq0_ch0_dfitmg4_dfi_twck_en_rd_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG4_DFI_TWCK_EN_RD +: `REGB_FREQ0_CH0_SIZE_DFITMG4_DFI_TWCK_EN_RD];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
         if (rwselect[1536] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_post[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_POST +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST] & regb_freq0_ch0_dfitmg5_dfi_twck_toggle_post_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_POST +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_POST];
            end
         end
         if (rwselect[1536] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_toggle_cs[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_CS +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS] & regb_freq0_ch0_dfitmg5_dfi_twck_toggle_cs_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE_CS +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE_CS];
            end
         end
         if (rwselect[1536] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_toggle[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE] & regb_freq0_ch0_dfitmg5_dfi_twck_toggle_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_TOGGLE +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_TOGGLE];
            end
         end
         if (rwselect[1536] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_twck_fast_toggle[(`REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_FAST_TOGGLE +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE] & regb_freq0_ch0_dfitmg5_dfi_twck_fast_toggle_mask[`REGB_FREQ0_CH0_OFFSET_DFITMG5_DFI_TWCK_FAST_TOGGLE +: `REGB_FREQ0_CH0_SIZE_DFITMG5_DFI_TWCK_FAST_TOGGLE];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
         if (rwselect[1538] && write_en) begin
            ff_regb_freq0_ch0_dfi_lp_wakeup_pd[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_PD +: `REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD] & regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_pd_mask[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_PD +: `REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_PD];
         end
         if (rwselect[1538] && write_en) begin
            ff_regb_freq0_ch0_dfi_lp_wakeup_sr[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_SR +: `REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR] & regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_sr_mask[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_SR +: `REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_SR];
         end
         if (rwselect[1538] && write_en) begin
            ff_regb_freq0_ch0_dfi_lp_wakeup_dsm[(`REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_DSM +: `REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM] & regb_freq0_ch0_dfilptmg0_dfi_lp_wakeup_dsm_mask[`REGB_FREQ0_CH0_OFFSET_DFILPTMG0_DFI_LP_WAKEUP_DSM +: `REGB_FREQ0_CH0_SIZE_DFILPTMG0_DFI_LP_WAKEUP_DSM];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
         if (rwselect[1539] && write_en) begin
            ff_regb_freq0_ch0_dfi_lp_wakeup_data[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_LP_WAKEUP_DATA +: `REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA] & regb_freq0_ch0_dfilptmg1_dfi_lp_wakeup_data_mask[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_LP_WAKEUP_DATA +: `REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_LP_WAKEUP_DATA];
         end
         if (rwselect[1539] && write_en) begin
            ff_regb_freq0_ch0_dfi_tlp_resp[(`REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_TLP_RESP +: `REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP] & regb_freq0_ch0_dfilptmg1_dfi_tlp_resp_mask[`REGB_FREQ0_CH0_OFFSET_DFILPTMG1_DFI_TLP_RESP +: `REGB_FREQ0_CH0_SIZE_DFILPTMG1_DFI_TLP_RESP];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
         if (rwselect[1540] && write_en) begin
            ff_regb_freq0_ch0_dfi_t_ctrlup_min[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MIN +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN] & regb_freq0_ch0_dfiupdtmg0_dfi_t_ctrlup_min_mask[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MIN +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MIN];
         end
         if (rwselect[1540] && write_en) begin
            ff_regb_freq0_ch0_dfi_t_ctrlup_max[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MAX +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX] & regb_freq0_ch0_dfiupdtmg0_dfi_t_ctrlup_max_mask[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG0_DFI_T_CTRLUP_MAX +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG0_DFI_T_CTRLUP_MAX];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
         if (rwselect[1541] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_max_x1024[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024 +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024] & regb_freq0_ch0_dfiupdtmg1_dfi_t_ctrlupd_interval_max_x1024_mask[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024 +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MAX_X1024];
            end
         end
         if (rwselect[1541] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_t_ctrlupd_interval_min_x1024[(`REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024 +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024] & regb_freq0_ch0_dfiupdtmg1_dfi_t_ctrlupd_interval_min_x1024_mask[`REGB_FREQ0_CH0_OFFSET_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024 +: `REGB_FREQ0_CH0_SIZE_DFIUPDTMG1_DFI_T_CTRLUPD_INTERVAL_MIN_X1024];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
         if (rwselect[1542] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_dfi_t_ctrlmsg_resp[(`REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DFIMSGTMG0_DFI_T_CTRLMSG_RESP +: `REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP] & regb_freq0_ch0_dfimsgtmg0_dfi_t_ctrlmsg_resp_mask[`REGB_FREQ0_CH0_OFFSET_DFIMSGTMG0_DFI_T_CTRLMSG_RESP +: `REGB_FREQ0_CH0_SIZE_DFIMSGTMG0_DFI_T_CTRLMSG_RESP];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
         if (rwselect[1544] && write_en) begin
            ff_regb_freq0_ch0_t_refi_x1_x32[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_X32 +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32] & regb_freq0_ch0_rfshset1tmg0_t_refi_x1_x32_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_X32 +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_X32];
         end
         if (rwselect[1544] && write_en) begin
            ff_regb_freq0_ch0_refresh_to_x1_x32[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_TO_X1_X32 +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32] & regb_freq0_ch0_rfshset1tmg0_refresh_to_x1_x32_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_TO_X1_X32 +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_TO_X1_X32];
         end
         if (rwselect[1544] && write_en) begin
            ff_regb_freq0_ch0_refresh_margin[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_MARGIN +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN] & regb_freq0_ch0_rfshset1tmg0_refresh_margin_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_REFRESH_MARGIN +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_REFRESH_MARGIN];
         end
         if (rwselect[1544] && write_en) begin
            ff_regb_freq0_ch0_t_refi_x1_sel <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_SEL +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_SEL] & regb_freq0_ch0_rfshset1tmg0_t_refi_x1_sel_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG0_T_REFI_X1_SEL +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG0_T_REFI_X1_SEL];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
         if (rwselect[1545] && write_en) begin
            ff_regb_freq0_ch0_t_rfc_min[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN] & regb_freq0_ch0_rfshset1tmg1_t_rfc_min_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN];
         end
         if (rwselect[1545] && write_en) begin
            ff_regb_freq0_ch0_t_rfc_min_ab[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN_AB +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB] & regb_freq0_ch0_rfshset1tmg1_t_rfc_min_ab_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG1_T_RFC_MIN_AB +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG1_T_RFC_MIN_AB];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
         if (rwselect[1546] && write_en) begin
            ff_regb_freq0_ch0_t_pbr2pbr[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2PBR +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR] & regb_freq0_ch0_rfshset1tmg2_t_pbr2pbr_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2PBR +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2PBR];
         end
         if (rwselect[1546] && write_en) begin
            ff_regb_freq0_ch0_t_pbr2act[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2ACT +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT] & regb_freq0_ch0_rfshset1tmg2_t_pbr2act_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG2_T_PBR2ACT +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG2_T_PBR2ACT];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
         if (rwselect[1547] && write_en) begin
            ff_regb_freq0_ch0_refresh_to_ab_x32[(`REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG3_REFRESH_TO_AB_X32 +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32] & regb_freq0_ch0_rfshset1tmg3_refresh_to_ab_x32_mask[`REGB_FREQ0_CH0_OFFSET_RFSHSET1TMG3_REFRESH_TO_AB_X32 +: `REGB_FREQ0_CH0_SIZE_RFSHSET1TMG3_REFRESH_TO_AB_X32];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
         if (rwselect[1564] && write_en) begin
            ff_regb_freq0_ch0_t_zq_long_nop[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_LONG_NOP +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP] & regb_freq0_ch0_zqset1tmg0_t_zq_long_nop_mask[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_LONG_NOP +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_LONG_NOP];
         end
         if (rwselect[1564] && write_en) begin
            ff_regb_freq0_ch0_t_zq_short_nop[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_SHORT_NOP +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP] & regb_freq0_ch0_zqset1tmg0_t_zq_short_nop_mask[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG0_T_ZQ_SHORT_NOP +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG0_T_ZQ_SHORT_NOP];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
         if (rwselect[1565] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_zq_short_interval_x1024[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024 +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024] & regb_freq0_ch0_zqset1tmg1_t_zq_short_interval_x1024_mask[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024 +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_SHORT_INTERVAL_X1024];
            end
         end
         if (rwselect[1565] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_t_zq_reset_nop[(`REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_RESET_NOP +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP] & regb_freq0_ch0_zqset1tmg1_t_zq_reset_nop_mask[`REGB_FREQ0_CH0_OFFSET_ZQSET1TMG1_T_ZQ_RESET_NOP +: `REGB_FREQ0_CH0_SIZE_ZQSET1TMG1_T_ZQ_RESET_NOP];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
         if (rwselect[1574] && write_en) begin
            ff_regb_freq0_ch0_dqsosc_enable <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_ENABLE +: `REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_ENABLE] & regb_freq0_ch0_dqsoscctl0_dqsosc_enable_mask[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_ENABLE +: `REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_ENABLE];
         end
         if (rwselect[1574] && write_en) begin
            ff_regb_freq0_ch0_dqsosc_interval_unit <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT +: `REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT] & regb_freq0_ch0_dqsoscctl0_dqsosc_interval_unit_mask[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT +: `REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL_UNIT];
         end
         if (rwselect[1574] && write_en) begin
            ff_regb_freq0_ch0_dqsosc_interval[(`REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL +: `REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL] & regb_freq0_ch0_dqsoscctl0_dqsosc_interval_mask[`REGB_FREQ0_CH0_OFFSET_DQSOSCCTL0_DQSOSC_INTERVAL +: `REGB_FREQ0_CH0_SIZE_DQSOSCCTL0_DQSOSC_INTERVAL];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
         if (rwselect[1575] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_mr4_read_interval[(`REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DERATEINT_MR4_READ_INTERVAL +: `REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL] & regb_freq0_ch0_derateint_mr4_read_interval_mask[`REGB_FREQ0_CH0_OFFSET_DERATEINT_MR4_READ_INTERVAL +: `REGB_FREQ0_CH0_SIZE_DERATEINT_MR4_READ_INTERVAL];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
         if (rwselect[1576] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_derated_t_rrd[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RRD +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD] & regb_freq0_ch0_derateval0_derated_t_rrd_mask[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RRD +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RRD];
            end
         end
         if (rwselect[1576] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_derated_t_rp[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RP +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP] & regb_freq0_ch0_derateval0_derated_t_rp_mask[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RP +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RP];
            end
         end
         if (rwselect[1576] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_derated_t_ras_min[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RAS_MIN +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN] & regb_freq0_ch0_derateval0_derated_t_ras_min_mask[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RAS_MIN +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RAS_MIN];
            end
         end
         if (rwselect[1576] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_derated_t_rcd[(`REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RCD +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD] & regb_freq0_ch0_derateval0_derated_t_rcd_mask[`REGB_FREQ0_CH0_OFFSET_DERATEVAL0_DERATED_T_RCD +: `REGB_FREQ0_CH0_SIZE_DERATEVAL0_DERATED_T_RCD];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
         if (rwselect[1577] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               ff_regb_freq0_ch0_derated_t_rc[(`REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_DERATEVAL1_DERATED_T_RC +: `REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC] & regb_freq0_ch0_derateval1_derated_t_rc_mask[`REGB_FREQ0_CH0_OFFSET_DERATEVAL1_DERATED_T_RC +: `REGB_FREQ0_CH0_SIZE_DERATEVAL1_DERATED_T_RC];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
         if (rwselect[1578] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_hw_lp_idle_x32[(`REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_HWLPTMG0_HW_LP_IDLE_X32 +: `REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32] & regb_freq0_ch0_hwlptmg0_hw_lp_idle_x32_mask[`REGB_FREQ0_CH0_OFFSET_HWLPTMG0_HW_LP_IDLE_X32 +: `REGB_FREQ0_CH0_SIZE_HWLPTMG0_HW_LP_IDLE_X32];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
         if (rwselect[1579] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_pageclose_timer[(`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_PAGECLOSE_TIMER +: `REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER] & regb_freq0_ch0_schedtmg0_pageclose_timer_mask[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_PAGECLOSE_TIMER +: `REGB_FREQ0_CH0_SIZE_SCHEDTMG0_PAGECLOSE_TIMER];
            end
         end
         if (rwselect[1579] && write_en) begin
            if (static_wr_en_core_ddrc_core_clk == 1'b0) begin // static write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_rdwr_idle_gap[(`REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_RDWR_IDLE_GAP +: `REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP] & regb_freq0_ch0_schedtmg0_rdwr_idle_gap_mask[`REGB_FREQ0_CH0_OFFSET_SCHEDTMG0_RDWR_IDLE_GAP +: `REGB_FREQ0_CH0_SIZE_SCHEDTMG0_RDWR_IDLE_GAP];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
         if (rwselect[1580] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_hpr_max_starve[(`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_MAX_STARVE +: `REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE] & regb_freq0_ch0_perfhpr1_hpr_max_starve_mask[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_MAX_STARVE +: `REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_MAX_STARVE];
            end
         end
         if (rwselect[1580] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_hpr_xact_run_length[(`REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH +: `REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH] & regb_freq0_ch0_perfhpr1_hpr_xact_run_length_mask[`REGB_FREQ0_CH0_OFFSET_PERFHPR1_HPR_XACT_RUN_LENGTH +: `REGB_FREQ0_CH0_SIZE_PERFHPR1_HPR_XACT_RUN_LENGTH];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
         if (rwselect[1581] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_lpr_max_starve[(`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_MAX_STARVE +: `REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE] & regb_freq0_ch0_perflpr1_lpr_max_starve_mask[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_MAX_STARVE +: `REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_MAX_STARVE];
            end
         end
         if (rwselect[1581] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_lpr_xact_run_length[(`REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH +: `REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH] & regb_freq0_ch0_perflpr1_lpr_xact_run_length_mask[`REGB_FREQ0_CH0_OFFSET_PERFLPR1_LPR_XACT_RUN_LENGTH +: `REGB_FREQ0_CH0_SIZE_PERFLPR1_LPR_XACT_RUN_LENGTH];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
         if (rwselect[1582] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_w_max_starve[(`REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_MAX_STARVE +: `REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE] & regb_freq0_ch0_perfwr1_w_max_starve_mask[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_MAX_STARVE +: `REGB_FREQ0_CH0_SIZE_PERFWR1_W_MAX_STARVE];
            end
         end
         if (rwselect[1582] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_w_xact_run_length[(`REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_XACT_RUN_LENGTH +: `REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH] & regb_freq0_ch0_perfwr1_w_xact_run_length_mask[`REGB_FREQ0_CH0_OFFSET_PERFWR1_W_XACT_RUN_LENGTH +: `REGB_FREQ0_CH0_SIZE_PERFWR1_W_XACT_RUN_LENGTH];
            end
         end
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
         if (rwselect[1583] && write_en) begin
            ff_regb_freq0_ch0_frequency_ratio <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_TMGCFG_FREQUENCY_RATIO +: `REGB_FREQ0_CH0_SIZE_TMGCFG_FREQUENCY_RATIO] & regb_freq0_ch0_tmgcfg_frequency_ratio_mask[`REGB_FREQ0_CH0_OFFSET_TMGCFG_FREQUENCY_RATIO +: `REGB_FREQ0_CH0_SIZE_TMGCFG_FREQUENCY_RATIO];
         end
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
         if (rwselect[1586] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_powerdown_to_x32[(`REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PWRTMG_POWERDOWN_TO_X32 +: `REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32] & regb_freq0_ch0_pwrtmg_powerdown_to_x32_mask[`REGB_FREQ0_CH0_OFFSET_PWRTMG_POWERDOWN_TO_X32 +: `REGB_FREQ0_CH0_SIZE_PWRTMG_POWERDOWN_TO_X32];
            end
         end
         if (rwselect[1586] && write_en) begin
            if (quasi_dyn_wr_en_core_ddrc_core_clk == 1'b0) begin // quasi dynamic write enable @core_ddrc_core_clk
               cfgs_ff_regb_freq0_ch0_selfref_to_x32[(`REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32) -1:0] <= apb_data_expanded[`REGB_FREQ0_CH0_OFFSET_PWRTMG_SELFREF_TO_X32 +: `REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32] & regb_freq0_ch0_pwrtmg_selfref_to_x32_mask[`REGB_FREQ0_CH0_OFFSET_PWRTMG_SELFREF_TO_X32 +: `REGB_FREQ0_CH0_SIZE_PWRTMG_SELFREF_TO_X32];
            end
         end

      end 
   end


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  // Check that ff_rank0_refresh_todo goes to 1 at least once.
  property p_apb_ff_todo_is_one(ff_todo_signal);
    @(posedge pclk) disable iff(!presetn)
         (ff_todo_signal == 0);
  endproperty

  a_antoniot_ff_regb_ddrc_ch0_zq_reset_todo_is_1 : assert property (p_apb_ff_todo_is_one(ff_regb_ddrc_ch0_zq_reset_todo)) else
    $display("-> %0t ERROR: CODE COVERAGE assertion to check that ff_regb_ddrc_ch0_zq_reset_todo goes to 1. Please, assign to antoniot.", $realtime);

  a_antoniot_ff_zq_calib_short_todo_is_1 : assert property (p_apb_ff_todo_is_one(ff_regb_ddrc_ch0_zq_calib_short_todo)) else
    $display("-> %0t ERROR: CODE COVERAGE assertion to check that ff_regb_ddrc_ch0_zq_calib_short_todo goes to 1. Please, assign to antoniot.", $realtime);

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule
