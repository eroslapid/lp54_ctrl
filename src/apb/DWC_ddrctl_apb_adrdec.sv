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

// Revision $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddrctl_apb_adrdec.sv#3 $
`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"

module DWC_ddrctl_apb_adrdec
import DWC_ddrctl_reg_pkg::*;
  #(parameter APB_AW       = 16,
    parameter APB_DW       = 32,
    parameter REG_WIDTH    = 32,    
    parameter N_REGS       = `UMCTL2_REGS_N_REGS,
    parameter RW_REGS      = `UMCTL2_REGS_RW_REGS,
    parameter RWSELWIDTH   = RW_REGS,
    parameter N_APBFSMSTAT =
                            8
    )
   (input                       presetn,
    input                       pclk,
    input [APB_AW-1:2]          paddr,
    input                       pwrite,
    input                       psel,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Secure access is not supported    
    input                       apb_secure,
//spyglass enable_block W240
    input [N_APBFSMSTAT-1:0]    apb_slv_ns,
    output reg [RWSELWIDTH-1:0] rwselect,
    output     [APB_DW-1:0]     prdata,
    output reg                  pslverr
   ,input [REG_WIDTH -1:0] r0_mstr0
   ,input [REG_WIDTH -1:0] r4_mstr4
   ,input [REG_WIDTH -1:0] r5_stat
   ,input [REG_WIDTH -1:0] r8_mrctrl0
   ,input [REG_WIDTH -1:0] r9_mrctrl1
   ,input [REG_WIDTH -1:0] r11_mrstat
   ,input [REG_WIDTH -1:0] r12_mrrdata0
   ,input [REG_WIDTH -1:0] r13_mrrdata1
   ,input [REG_WIDTH -1:0] r14_deratectl0
   ,input [REG_WIDTH -1:0] r15_deratectl1
   ,input [REG_WIDTH -1:0] r19_deratectl5
   ,input [REG_WIDTH -1:0] r20_deratectl6
   ,input [REG_WIDTH -1:0] r21_deratestat0
   ,input [REG_WIDTH -1:0] r23_deratedbgctl
   ,input [REG_WIDTH -1:0] r24_deratedbgstat
   ,input [REG_WIDTH -1:0] r25_pwrctl
   ,input [REG_WIDTH -1:0] r26_hwlpctl
   ,input [REG_WIDTH -1:0] r28_clkgatectl
   ,input [REG_WIDTH -1:0] r29_rfshmod0
   ,input [REG_WIDTH -1:0] r31_rfshctl0
   ,input [REG_WIDTH -1:0] r34_zqctl0
   ,input [REG_WIDTH -1:0] r35_zqctl1
   ,input [REG_WIDTH -1:0] r36_zqctl2
   ,input [REG_WIDTH -1:0] r37_zqstat
   ,input [REG_WIDTH -1:0] r38_dqsoscruntime
   ,input [REG_WIDTH -1:0] r39_dqsoscstat0
   ,input [REG_WIDTH -1:0] r40_dqsosccfg0
   ,input [REG_WIDTH -1:0] r42_sched0
   ,input [REG_WIDTH -1:0] r43_sched1
   ,input [REG_WIDTH -1:0] r45_sched3
   ,input [REG_WIDTH -1:0] r46_sched4
   ,input [REG_WIDTH -1:0] r56_dfilpcfg0
   ,input [REG_WIDTH -1:0] r57_dfiupd0
   ,input [REG_WIDTH -1:0] r59_dfimisc
   ,input [REG_WIDTH -1:0] r60_dfistat
   ,input [REG_WIDTH -1:0] r61_dfiphymstr
   ,input [REG_WIDTH -1:0] r62_dfi0msgctl0
   ,input [REG_WIDTH -1:0] r63_dfi0msgstat0
   ,input [REG_WIDTH -1:0] r64_poisoncfg
   ,input [REG_WIDTH -1:0] r65_poisonstat
   ,input [REG_WIDTH -1:0] r215_opctrl0
   ,input [REG_WIDTH -1:0] r216_opctrl1
   ,input [REG_WIDTH -1:0] r217_opctrlcam
   ,input [REG_WIDTH -1:0] r218_opctrlcmd
   ,input [REG_WIDTH -1:0] r219_opctrlstat
   ,input [REG_WIDTH -1:0] r221_oprefctrl0
   ,input [REG_WIDTH -1:0] r223_oprefstat0
   ,input [REG_WIDTH -1:0] r225_swctl
   ,input [REG_WIDTH -1:0] r226_swstat
   ,input [REG_WIDTH -1:0] r230_dbictl
   ,input [REG_WIDTH -1:0] r232_odtmap
   ,input [REG_WIDTH -1:0] r233_datactl0
   ,input [REG_WIDTH -1:0] r234_swctlstatic
   ,input [REG_WIDTH -1:0] r235_inittmg0
   ,input [REG_WIDTH -1:0] r236_inittmg1
   ,input [REG_WIDTH -1:0] r263_ddrctl_ver_number
   ,input [REG_WIDTH -1:0] r264_ddrctl_ver_type
   ,input [REG_WIDTH -1:0] r450_addrmap3_map0
   ,input [REG_WIDTH -1:0] r451_addrmap4_map0
   ,input [REG_WIDTH -1:0] r452_addrmap5_map0
   ,input [REG_WIDTH -1:0] r453_addrmap6_map0
   ,input [REG_WIDTH -1:0] r454_addrmap7_map0
   ,input [REG_WIDTH -1:0] r455_addrmap8_map0
   ,input [REG_WIDTH -1:0] r456_addrmap9_map0
   ,input [REG_WIDTH -1:0] r457_addrmap10_map0
   ,input [REG_WIDTH -1:0] r458_addrmap11_map0
   ,input [REG_WIDTH -1:0] r459_addrmap12_map0
   ,input [REG_WIDTH -1:0] r474_pccfg_port0
   ,input [REG_WIDTH -1:0] r475_pcfgr_port0
   ,input [REG_WIDTH -1:0] r476_pcfgw_port0
   ,input [REG_WIDTH -1:0] r509_pctrl_port0
   ,input [REG_WIDTH -1:0] r510_pcfgqos0_port0
   ,input [REG_WIDTH -1:0] r511_pcfgqos1_port0
   ,input [REG_WIDTH -1:0] r512_pcfgwqos0_port0
   ,input [REG_WIDTH -1:0] r513_pcfgwqos1_port0
   ,input [REG_WIDTH -1:0] r535_pstat_port0
   ,input [REG_WIDTH -1:0] r1882_dramset1tmg0_freq0
   ,input [REG_WIDTH -1:0] r1883_dramset1tmg1_freq0
   ,input [REG_WIDTH -1:0] r1884_dramset1tmg2_freq0
   ,input [REG_WIDTH -1:0] r1885_dramset1tmg3_freq0
   ,input [REG_WIDTH -1:0] r1886_dramset1tmg4_freq0
   ,input [REG_WIDTH -1:0] r1887_dramset1tmg5_freq0
   ,input [REG_WIDTH -1:0] r1888_dramset1tmg6_freq0
   ,input [REG_WIDTH -1:0] r1889_dramset1tmg7_freq0
   ,input [REG_WIDTH -1:0] r1891_dramset1tmg9_freq0
   ,input [REG_WIDTH -1:0] r1894_dramset1tmg12_freq0
   ,input [REG_WIDTH -1:0] r1895_dramset1tmg13_freq0
   ,input [REG_WIDTH -1:0] r1896_dramset1tmg14_freq0
   ,input [REG_WIDTH -1:0] r1905_dramset1tmg23_freq0
   ,input [REG_WIDTH -1:0] r1906_dramset1tmg24_freq0
   ,input [REG_WIDTH -1:0] r1907_dramset1tmg25_freq0
   ,input [REG_WIDTH -1:0] r1912_dramset1tmg30_freq0
   ,input [REG_WIDTH -1:0] r1938_initmr0_freq0
   ,input [REG_WIDTH -1:0] r1939_initmr1_freq0
   ,input [REG_WIDTH -1:0] r1940_initmr2_freq0
   ,input [REG_WIDTH -1:0] r1941_initmr3_freq0
   ,input [REG_WIDTH -1:0] r1942_dfitmg0_freq0
   ,input [REG_WIDTH -1:0] r1943_dfitmg1_freq0
   ,input [REG_WIDTH -1:0] r1944_dfitmg2_freq0
   ,input [REG_WIDTH -1:0] r1946_dfitmg4_freq0
   ,input [REG_WIDTH -1:0] r1947_dfitmg5_freq0
   ,input [REG_WIDTH -1:0] r1949_dfilptmg0_freq0
   ,input [REG_WIDTH -1:0] r1950_dfilptmg1_freq0
   ,input [REG_WIDTH -1:0] r1951_dfiupdtmg0_freq0
   ,input [REG_WIDTH -1:0] r1952_dfiupdtmg1_freq0
   ,input [REG_WIDTH -1:0] r1953_dfimsgtmg0_freq0
   ,input [REG_WIDTH -1:0] r1955_rfshset1tmg0_freq0
   ,input [REG_WIDTH -1:0] r1956_rfshset1tmg1_freq0
   ,input [REG_WIDTH -1:0] r1957_rfshset1tmg2_freq0
   ,input [REG_WIDTH -1:0] r1958_rfshset1tmg3_freq0
   ,input [REG_WIDTH -1:0] r1975_zqset1tmg0_freq0
   ,input [REG_WIDTH -1:0] r1976_zqset1tmg1_freq0
   ,input [REG_WIDTH -1:0] r1985_dqsoscctl0_freq0
   ,input [REG_WIDTH -1:0] r1986_derateint_freq0
   ,input [REG_WIDTH -1:0] r1987_derateval0_freq0
   ,input [REG_WIDTH -1:0] r1988_derateval1_freq0
   ,input [REG_WIDTH -1:0] r1989_hwlptmg0_freq0
   ,input [REG_WIDTH -1:0] r1990_schedtmg0_freq0
   ,input [REG_WIDTH -1:0] r1991_perfhpr1_freq0
   ,input [REG_WIDTH -1:0] r1992_perflpr1_freq0
   ,input [REG_WIDTH -1:0] r1993_perfwr1_freq0
   ,input [REG_WIDTH -1:0] r1994_tmgcfg_freq0
   ,input [REG_WIDTH -1:0] r1997_pwrtmg_freq0

    );   

   localparam IDLE       = 8'b00000001;
   localparam ADDRDECODE = 8'b00000010;
   localparam SAMPLERDY  = 8'b00001000;
   localparam SELWIDTH   = N_REGS;

   localparam REG_AW = APB_AW - 2;
   localparam REGB_DDRC_CH0_MSTR0_ADDR = `REGB_DDRC_CH0_MSTR0_ADDR;
   localparam REGB_DDRC_CH0_MSTR4_ADDR = `REGB_DDRC_CH0_MSTR4_ADDR;
   localparam REGB_DDRC_CH0_STAT_ADDR = `REGB_DDRC_CH0_STAT_ADDR;
   localparam REGB_DDRC_CH0_MRCTRL0_ADDR = `REGB_DDRC_CH0_MRCTRL0_ADDR;
   localparam REGB_DDRC_CH0_MRCTRL1_ADDR = `REGB_DDRC_CH0_MRCTRL1_ADDR;
   localparam REGB_DDRC_CH0_MRSTAT_ADDR = `REGB_DDRC_CH0_MRSTAT_ADDR;
   localparam REGB_DDRC_CH0_MRRDATA0_ADDR = `REGB_DDRC_CH0_MRRDATA0_ADDR;
   localparam REGB_DDRC_CH0_MRRDATA1_ADDR = `REGB_DDRC_CH0_MRRDATA1_ADDR;
   localparam REGB_DDRC_CH0_DERATECTL0_ADDR = `REGB_DDRC_CH0_DERATECTL0_ADDR;
   localparam REGB_DDRC_CH0_DERATECTL1_ADDR = `REGB_DDRC_CH0_DERATECTL1_ADDR;
   localparam REGB_DDRC_CH0_DERATECTL5_ADDR = `REGB_DDRC_CH0_DERATECTL5_ADDR;
   localparam REGB_DDRC_CH0_DERATECTL6_ADDR = `REGB_DDRC_CH0_DERATECTL6_ADDR;
   localparam REGB_DDRC_CH0_DERATESTAT0_ADDR = `REGB_DDRC_CH0_DERATESTAT0_ADDR;
   localparam REGB_DDRC_CH0_DERATEDBGCTL_ADDR = `REGB_DDRC_CH0_DERATEDBGCTL_ADDR;
   localparam REGB_DDRC_CH0_DERATEDBGSTAT_ADDR = `REGB_DDRC_CH0_DERATEDBGSTAT_ADDR;
   localparam REGB_DDRC_CH0_PWRCTL_ADDR = `REGB_DDRC_CH0_PWRCTL_ADDR;
   localparam REGB_DDRC_CH0_HWLPCTL_ADDR = `REGB_DDRC_CH0_HWLPCTL_ADDR;
   localparam REGB_DDRC_CH0_CLKGATECTL_ADDR = `REGB_DDRC_CH0_CLKGATECTL_ADDR;
   localparam REGB_DDRC_CH0_RFSHMOD0_ADDR = `REGB_DDRC_CH0_RFSHMOD0_ADDR;
   localparam REGB_DDRC_CH0_RFSHCTL0_ADDR = `REGB_DDRC_CH0_RFSHCTL0_ADDR;
   localparam REGB_DDRC_CH0_ZQCTL0_ADDR = `REGB_DDRC_CH0_ZQCTL0_ADDR;
   localparam REGB_DDRC_CH0_ZQCTL1_ADDR = `REGB_DDRC_CH0_ZQCTL1_ADDR;
   localparam REGB_DDRC_CH0_ZQCTL2_ADDR = `REGB_DDRC_CH0_ZQCTL2_ADDR;
   localparam REGB_DDRC_CH0_ZQSTAT_ADDR = `REGB_DDRC_CH0_ZQSTAT_ADDR;
   localparam REGB_DDRC_CH0_DQSOSCRUNTIME_ADDR = `REGB_DDRC_CH0_DQSOSCRUNTIME_ADDR;
   localparam REGB_DDRC_CH0_DQSOSCSTAT0_ADDR = `REGB_DDRC_CH0_DQSOSCSTAT0_ADDR;
   localparam REGB_DDRC_CH0_DQSOSCCFG0_ADDR = `REGB_DDRC_CH0_DQSOSCCFG0_ADDR;
   localparam REGB_DDRC_CH0_SCHED0_ADDR = `REGB_DDRC_CH0_SCHED0_ADDR;
   localparam REGB_DDRC_CH0_SCHED1_ADDR = `REGB_DDRC_CH0_SCHED1_ADDR;
   localparam REGB_DDRC_CH0_SCHED3_ADDR = `REGB_DDRC_CH0_SCHED3_ADDR;
   localparam REGB_DDRC_CH0_SCHED4_ADDR = `REGB_DDRC_CH0_SCHED4_ADDR;
   localparam REGB_DDRC_CH0_DFILPCFG0_ADDR = `REGB_DDRC_CH0_DFILPCFG0_ADDR;
   localparam REGB_DDRC_CH0_DFIUPD0_ADDR = `REGB_DDRC_CH0_DFIUPD0_ADDR;
   localparam REGB_DDRC_CH0_DFIMISC_ADDR = `REGB_DDRC_CH0_DFIMISC_ADDR;
   localparam REGB_DDRC_CH0_DFISTAT_ADDR = `REGB_DDRC_CH0_DFISTAT_ADDR;
   localparam REGB_DDRC_CH0_DFIPHYMSTR_ADDR = `REGB_DDRC_CH0_DFIPHYMSTR_ADDR;
   localparam REGB_DDRC_CH0_DFI0MSGCTL0_ADDR = `REGB_DDRC_CH0_DFI0MSGCTL0_ADDR;
   localparam REGB_DDRC_CH0_DFI0MSGSTAT0_ADDR = `REGB_DDRC_CH0_DFI0MSGSTAT0_ADDR;
   localparam REGB_DDRC_CH0_POISONCFG_ADDR = `REGB_DDRC_CH0_POISONCFG_ADDR;
   localparam REGB_DDRC_CH0_POISONSTAT_ADDR = `REGB_DDRC_CH0_POISONSTAT_ADDR;
   localparam REGB_DDRC_CH0_OPCTRL0_ADDR = `REGB_DDRC_CH0_OPCTRL0_ADDR;
   localparam REGB_DDRC_CH0_OPCTRL1_ADDR = `REGB_DDRC_CH0_OPCTRL1_ADDR;
   localparam REGB_DDRC_CH0_OPCTRLCAM_ADDR = `REGB_DDRC_CH0_OPCTRLCAM_ADDR;
   localparam REGB_DDRC_CH0_OPCTRLCMD_ADDR = `REGB_DDRC_CH0_OPCTRLCMD_ADDR;
   localparam REGB_DDRC_CH0_OPCTRLSTAT_ADDR = `REGB_DDRC_CH0_OPCTRLSTAT_ADDR;
   localparam REGB_DDRC_CH0_OPREFCTRL0_ADDR = `REGB_DDRC_CH0_OPREFCTRL0_ADDR;
   localparam REGB_DDRC_CH0_OPREFSTAT0_ADDR = `REGB_DDRC_CH0_OPREFSTAT0_ADDR;
   localparam REGB_DDRC_CH0_SWCTL_ADDR = `REGB_DDRC_CH0_SWCTL_ADDR;
   localparam REGB_DDRC_CH0_SWSTAT_ADDR = `REGB_DDRC_CH0_SWSTAT_ADDR;
   localparam REGB_DDRC_CH0_DBICTL_ADDR = `REGB_DDRC_CH0_DBICTL_ADDR;
   localparam REGB_DDRC_CH0_ODTMAP_ADDR = `REGB_DDRC_CH0_ODTMAP_ADDR;
   localparam REGB_DDRC_CH0_DATACTL0_ADDR = `REGB_DDRC_CH0_DATACTL0_ADDR;
   localparam REGB_DDRC_CH0_SWCTLSTATIC_ADDR = `REGB_DDRC_CH0_SWCTLSTATIC_ADDR;
   localparam REGB_DDRC_CH0_INITTMG0_ADDR = `REGB_DDRC_CH0_INITTMG0_ADDR;
   localparam REGB_DDRC_CH0_INITTMG1_ADDR = `REGB_DDRC_CH0_INITTMG1_ADDR;
   localparam REGB_DDRC_CH0_DDRCTL_VER_NUMBER_ADDR = `REGB_DDRC_CH0_DDRCTL_VER_NUMBER_ADDR;
   localparam REGB_DDRC_CH0_DDRCTL_VER_TYPE_ADDR = `REGB_DDRC_CH0_DDRCTL_VER_TYPE_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP3_ADDR = `REGB_ADDR_MAP0_ADDRMAP3_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP4_ADDR = `REGB_ADDR_MAP0_ADDRMAP4_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP5_ADDR = `REGB_ADDR_MAP0_ADDRMAP5_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP6_ADDR = `REGB_ADDR_MAP0_ADDRMAP6_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP7_ADDR = `REGB_ADDR_MAP0_ADDRMAP7_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP8_ADDR = `REGB_ADDR_MAP0_ADDRMAP8_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP9_ADDR = `REGB_ADDR_MAP0_ADDRMAP9_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP10_ADDR = `REGB_ADDR_MAP0_ADDRMAP10_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP11_ADDR = `REGB_ADDR_MAP0_ADDRMAP11_ADDR;
   localparam REGB_ADDR_MAP0_ADDRMAP12_ADDR = `REGB_ADDR_MAP0_ADDRMAP12_ADDR;
   localparam REGB_ARB_PORT0_PCCFG_ADDR = `REGB_ARB_PORT0_PCCFG_ADDR;
   localparam REGB_ARB_PORT0_PCFGR_ADDR = `REGB_ARB_PORT0_PCFGR_ADDR;
   localparam REGB_ARB_PORT0_PCFGW_ADDR = `REGB_ARB_PORT0_PCFGW_ADDR;
   localparam REGB_ARB_PORT0_PCTRL_ADDR = `REGB_ARB_PORT0_PCTRL_ADDR;
   localparam REGB_ARB_PORT0_PCFGQOS0_ADDR = `REGB_ARB_PORT0_PCFGQOS0_ADDR;
   localparam REGB_ARB_PORT0_PCFGQOS1_ADDR = `REGB_ARB_PORT0_PCFGQOS1_ADDR;
   localparam REGB_ARB_PORT0_PCFGWQOS0_ADDR = `REGB_ARB_PORT0_PCFGWQOS0_ADDR;
   localparam REGB_ARB_PORT0_PCFGWQOS1_ADDR = `REGB_ARB_PORT0_PCFGWQOS1_ADDR;
   localparam REGB_ARB_PORT0_PSTAT_ADDR = `REGB_ARB_PORT0_PSTAT_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG0_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG0_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG1_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG1_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG2_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG2_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG3_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG3_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG4_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG4_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG5_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG5_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG6_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG6_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG7_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG7_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG9_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG9_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG12_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG12_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG13_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG13_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG14_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG14_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG23_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG23_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG24_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG24_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG25_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG25_ADDR;
   localparam REGB_FREQ0_CH0_DRAMSET1TMG30_ADDR = `REGB_FREQ0_CH0_DRAMSET1TMG30_ADDR;
   localparam REGB_FREQ0_CH0_INITMR0_ADDR = `REGB_FREQ0_CH0_INITMR0_ADDR;
   localparam REGB_FREQ0_CH0_INITMR1_ADDR = `REGB_FREQ0_CH0_INITMR1_ADDR;
   localparam REGB_FREQ0_CH0_INITMR2_ADDR = `REGB_FREQ0_CH0_INITMR2_ADDR;
   localparam REGB_FREQ0_CH0_INITMR3_ADDR = `REGB_FREQ0_CH0_INITMR3_ADDR;
   localparam REGB_FREQ0_CH0_DFITMG0_ADDR = `REGB_FREQ0_CH0_DFITMG0_ADDR;
   localparam REGB_FREQ0_CH0_DFITMG1_ADDR = `REGB_FREQ0_CH0_DFITMG1_ADDR;
   localparam REGB_FREQ0_CH0_DFITMG2_ADDR = `REGB_FREQ0_CH0_DFITMG2_ADDR;
   localparam REGB_FREQ0_CH0_DFITMG4_ADDR = `REGB_FREQ0_CH0_DFITMG4_ADDR;
   localparam REGB_FREQ0_CH0_DFITMG5_ADDR = `REGB_FREQ0_CH0_DFITMG5_ADDR;
   localparam REGB_FREQ0_CH0_DFILPTMG0_ADDR = `REGB_FREQ0_CH0_DFILPTMG0_ADDR;
   localparam REGB_FREQ0_CH0_DFILPTMG1_ADDR = `REGB_FREQ0_CH0_DFILPTMG1_ADDR;
   localparam REGB_FREQ0_CH0_DFIUPDTMG0_ADDR = `REGB_FREQ0_CH0_DFIUPDTMG0_ADDR;
   localparam REGB_FREQ0_CH0_DFIUPDTMG1_ADDR = `REGB_FREQ0_CH0_DFIUPDTMG1_ADDR;
   localparam REGB_FREQ0_CH0_DFIMSGTMG0_ADDR = `REGB_FREQ0_CH0_DFIMSGTMG0_ADDR;
   localparam REGB_FREQ0_CH0_RFSHSET1TMG0_ADDR = `REGB_FREQ0_CH0_RFSHSET1TMG0_ADDR;
   localparam REGB_FREQ0_CH0_RFSHSET1TMG1_ADDR = `REGB_FREQ0_CH0_RFSHSET1TMG1_ADDR;
   localparam REGB_FREQ0_CH0_RFSHSET1TMG2_ADDR = `REGB_FREQ0_CH0_RFSHSET1TMG2_ADDR;
   localparam REGB_FREQ0_CH0_RFSHSET1TMG3_ADDR = `REGB_FREQ0_CH0_RFSHSET1TMG3_ADDR;
   localparam REGB_FREQ0_CH0_ZQSET1TMG0_ADDR = `REGB_FREQ0_CH0_ZQSET1TMG0_ADDR;
   localparam REGB_FREQ0_CH0_ZQSET1TMG1_ADDR = `REGB_FREQ0_CH0_ZQSET1TMG1_ADDR;
   localparam REGB_FREQ0_CH0_DQSOSCCTL0_ADDR = `REGB_FREQ0_CH0_DQSOSCCTL0_ADDR;
   localparam REGB_FREQ0_CH0_DERATEINT_ADDR = `REGB_FREQ0_CH0_DERATEINT_ADDR;
   localparam REGB_FREQ0_CH0_DERATEVAL0_ADDR = `REGB_FREQ0_CH0_DERATEVAL0_ADDR;
   localparam REGB_FREQ0_CH0_DERATEVAL1_ADDR = `REGB_FREQ0_CH0_DERATEVAL1_ADDR;
   localparam REGB_FREQ0_CH0_HWLPTMG0_ADDR = `REGB_FREQ0_CH0_HWLPTMG0_ADDR;
   localparam REGB_FREQ0_CH0_SCHEDTMG0_ADDR = `REGB_FREQ0_CH0_SCHEDTMG0_ADDR;
   localparam REGB_FREQ0_CH0_PERFHPR1_ADDR = `REGB_FREQ0_CH0_PERFHPR1_ADDR;
   localparam REGB_FREQ0_CH0_PERFLPR1_ADDR = `REGB_FREQ0_CH0_PERFLPR1_ADDR;
   localparam REGB_FREQ0_CH0_PERFWR1_ADDR = `REGB_FREQ0_CH0_PERFWR1_ADDR;
   localparam REGB_FREQ0_CH0_TMGCFG_ADDR = `REGB_FREQ0_CH0_TMGCFG_ADDR;
   localparam REGB_FREQ0_CH0_PWRTMG_ADDR = `REGB_FREQ0_CH0_PWRTMG_ADDR;


   logic [SELWIDTH-1:0]             onehotsel;
   reg [REG_AW-1:0]                 reg_addr;
   reg [REG_WIDTH
                  -1:0]  rfm_data_decoded;
   logic [$bits(rfm_data_decoded) -1:0]  rfm_data_decoded_next;
   reg                              invalid_access;

 always_ff @(posedge pclk or negedge presetn) begin : sample_pclk_paddr_PROC
      if (~presetn) begin
         reg_addr <= {REG_AW{1'b0}};
      end else begin
         if(psel) begin
            // -- Register address
            // -- Strip off bits [1:0] which are embedded into byte enables
            reg_addr <= paddr[APB_AW-1:$clog2(APB_DW/8)];
         end
      end
   end

   // -- Write Address Decoding ----
   always_comb begin : rwselect_combo_PROC
      rwselect = {RWSELWIDTH{1'b0}};
      if(reg_addr==REGB_DDRC_CH0_MSTR0_ADDR[REG_AW-1:0]) begin
         rwselect[0] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_MSTR4_ADDR[REG_AW-1:0]) begin
         rwselect[4] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_MRCTRL0_ADDR[REG_AW-1:0]) begin
         rwselect[5] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_MRCTRL1_ADDR[REG_AW-1:0]) begin
         rwselect[6] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DERATECTL0_ADDR[REG_AW-1:0]) begin
         rwselect[8] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DERATECTL1_ADDR[REG_AW-1:0]) begin
         rwselect[9] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DERATECTL5_ADDR[REG_AW-1:0]) begin
         rwselect[13] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DERATECTL6_ADDR[REG_AW-1:0]) begin
         rwselect[14] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DERATEDBGCTL_ADDR[REG_AW-1:0]) begin
         rwselect[15] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_PWRCTL_ADDR[REG_AW-1:0]) begin
         rwselect[16] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_HWLPCTL_ADDR[REG_AW-1:0]) begin
         rwselect[17] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_CLKGATECTL_ADDR[REG_AW-1:0]) begin
         rwselect[19] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_RFSHMOD0_ADDR[REG_AW-1:0]) begin
         rwselect[20] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_RFSHCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[22] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_ZQCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[25] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_ZQCTL1_ADDR[REG_AW-1:0]) begin
         rwselect[26] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_ZQCTL2_ADDR[REG_AW-1:0]) begin
         rwselect[27] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DQSOSCRUNTIME_ADDR[REG_AW-1:0]) begin
         rwselect[28] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DQSOSCCFG0_ADDR[REG_AW-1:0]) begin
         rwselect[29] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_SCHED0_ADDR[REG_AW-1:0]) begin
         rwselect[31] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_SCHED1_ADDR[REG_AW-1:0]) begin
         rwselect[32] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_SCHED3_ADDR[REG_AW-1:0]) begin
         rwselect[34] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_SCHED4_ADDR[REG_AW-1:0]) begin
         rwselect[35] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DFILPCFG0_ADDR[REG_AW-1:0]) begin
         rwselect[44] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DFIUPD0_ADDR[REG_AW-1:0]) begin
         rwselect[45] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DFIMISC_ADDR[REG_AW-1:0]) begin
         rwselect[47] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DFIPHYMSTR_ADDR[REG_AW-1:0]) begin
         rwselect[48] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DFI0MSGCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[49] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_POISONCFG_ADDR[REG_AW-1:0]) begin
         rwselect[50] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_OPCTRL0_ADDR[REG_AW-1:0]) begin
         rwselect[122] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_OPCTRL1_ADDR[REG_AW-1:0]) begin
         rwselect[123] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_OPCTRLCMD_ADDR[REG_AW-1:0]) begin
         rwselect[124] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_OPREFCTRL0_ADDR[REG_AW-1:0]) begin
         rwselect[125] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_SWCTL_ADDR[REG_AW-1:0]) begin
         rwselect[127] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DBICTL_ADDR[REG_AW-1:0]) begin
         rwselect[131] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_ODTMAP_ADDR[REG_AW-1:0]) begin
         rwselect[132] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_DATACTL0_ADDR[REG_AW-1:0]) begin
         rwselect[133] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_SWCTLSTATIC_ADDR[REG_AW-1:0]) begin
         rwselect[134] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_INITTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[135] = 1'b1;
      end
      if(reg_addr==REGB_DDRC_CH0_INITTMG1_ADDR[REG_AW-1:0]) begin
         rwselect[136] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP3_ADDR[REG_AW-1:0]) begin
         rwselect[222] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP4_ADDR[REG_AW-1:0]) begin
         rwselect[223] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP5_ADDR[REG_AW-1:0]) begin
         rwselect[224] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP6_ADDR[REG_AW-1:0]) begin
         rwselect[225] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP7_ADDR[REG_AW-1:0]) begin
         rwselect[226] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP8_ADDR[REG_AW-1:0]) begin
         rwselect[227] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP9_ADDR[REG_AW-1:0]) begin
         rwselect[228] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP10_ADDR[REG_AW-1:0]) begin
         rwselect[229] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP11_ADDR[REG_AW-1:0]) begin
         rwselect[230] = 1'b1;
      end
      if(reg_addr==REGB_ADDR_MAP0_ADDRMAP12_ADDR[REG_AW-1:0]) begin
         rwselect[231] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCCFG_ADDR[REG_AW-1:0]) begin
         rwselect[245] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCFGR_ADDR[REG_AW-1:0]) begin
         rwselect[246] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCFGW_ADDR[REG_AW-1:0]) begin
         rwselect[247] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCTRL_ADDR[REG_AW-1:0]) begin
         rwselect[280] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCFGQOS0_ADDR[REG_AW-1:0]) begin
         rwselect[281] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCFGQOS1_ADDR[REG_AW-1:0]) begin
         rwselect[282] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCFGWQOS0_ADDR[REG_AW-1:0]) begin
         rwselect[283] = 1'b1;
      end
      if(reg_addr==REGB_ARB_PORT0_PCFGWQOS1_ADDR[REG_AW-1:0]) begin
         rwselect[284] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1471] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG1_ADDR[REG_AW-1:0]) begin
         rwselect[1472] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG2_ADDR[REG_AW-1:0]) begin
         rwselect[1473] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG3_ADDR[REG_AW-1:0]) begin
         rwselect[1474] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG4_ADDR[REG_AW-1:0]) begin
         rwselect[1475] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG5_ADDR[REG_AW-1:0]) begin
         rwselect[1476] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG6_ADDR[REG_AW-1:0]) begin
         rwselect[1477] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG7_ADDR[REG_AW-1:0]) begin
         rwselect[1478] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG9_ADDR[REG_AW-1:0]) begin
         rwselect[1480] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG12_ADDR[REG_AW-1:0]) begin
         rwselect[1483] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG13_ADDR[REG_AW-1:0]) begin
         rwselect[1484] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG14_ADDR[REG_AW-1:0]) begin
         rwselect[1485] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG23_ADDR[REG_AW-1:0]) begin
         rwselect[1494] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG24_ADDR[REG_AW-1:0]) begin
         rwselect[1495] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG25_ADDR[REG_AW-1:0]) begin
         rwselect[1496] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG30_ADDR[REG_AW-1:0]) begin
         rwselect[1501] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_INITMR0_ADDR[REG_AW-1:0]) begin
         rwselect[1527] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_INITMR1_ADDR[REG_AW-1:0]) begin
         rwselect[1528] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_INITMR2_ADDR[REG_AW-1:0]) begin
         rwselect[1529] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_INITMR3_ADDR[REG_AW-1:0]) begin
         rwselect[1530] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFITMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1531] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFITMG1_ADDR[REG_AW-1:0]) begin
         rwselect[1532] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFITMG2_ADDR[REG_AW-1:0]) begin
         rwselect[1533] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFITMG4_ADDR[REG_AW-1:0]) begin
         rwselect[1535] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFITMG5_ADDR[REG_AW-1:0]) begin
         rwselect[1536] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFILPTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1538] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFILPTMG1_ADDR[REG_AW-1:0]) begin
         rwselect[1539] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFIUPDTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1540] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFIUPDTMG1_ADDR[REG_AW-1:0]) begin
         rwselect[1541] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DFIMSGTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1542] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1544] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG1_ADDR[REG_AW-1:0]) begin
         rwselect[1545] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG2_ADDR[REG_AW-1:0]) begin
         rwselect[1546] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG3_ADDR[REG_AW-1:0]) begin
         rwselect[1547] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_ZQSET1TMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1564] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_ZQSET1TMG1_ADDR[REG_AW-1:0]) begin
         rwselect[1565] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DQSOSCCTL0_ADDR[REG_AW-1:0]) begin
         rwselect[1574] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DERATEINT_ADDR[REG_AW-1:0]) begin
         rwselect[1575] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DERATEVAL0_ADDR[REG_AW-1:0]) begin
         rwselect[1576] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_DERATEVAL1_ADDR[REG_AW-1:0]) begin
         rwselect[1577] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_HWLPTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1578] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_SCHEDTMG0_ADDR[REG_AW-1:0]) begin
         rwselect[1579] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_PERFHPR1_ADDR[REG_AW-1:0]) begin
         rwselect[1580] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_PERFLPR1_ADDR[REG_AW-1:0]) begin
         rwselect[1581] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_PERFWR1_ADDR[REG_AW-1:0]) begin
         rwselect[1582] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_TMGCFG_ADDR[REG_AW-1:0]) begin
         rwselect[1583] = 1'b1;
      end
      if(reg_addr==REGB_FREQ0_CH0_PWRTMG_ADDR[REG_AW-1:0]) begin
         rwselect[1586] = 1'b1;
      end

   end

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
   property apb_rwselect_legal;
      @(posedge pclk) disable iff(!presetn)
      $onehot0(rwselect);
   endproperty : apb_rwselect_legal
   a_apb_rwselect_legal :  assert property (apb_rwselect_legal) else 
     $display("%0t ERROR: RW register selector is one hot.",$realtime);
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
   // -- Read Address Decoding ----
   // The incoming binary address is decoded to onehot.
   // Individual bits of the one hot address are used
   // to select the respective register in the map
   always_comb begin : onehotsel_combo_PROC
      onehotsel = {SELWIDTH{1'b0}};
         if(reg_addr==REGB_DDRC_CH0_MSTR0_ADDR[REG_AW-1:0]) begin
            onehotsel[0] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_MSTR4_ADDR[REG_AW-1:0]) begin
            onehotsel[4] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_STAT_ADDR[REG_AW-1:0]) begin
            onehotsel[5] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_MRCTRL0_ADDR[REG_AW-1:0]) begin
            onehotsel[8] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_MRCTRL1_ADDR[REG_AW-1:0]) begin
            onehotsel[9] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_MRSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[11] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_MRRDATA0_ADDR[REG_AW-1:0]) begin
            onehotsel[12] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_MRRDATA1_ADDR[REG_AW-1:0]) begin
            onehotsel[13] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATECTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[14] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATECTL1_ADDR[REG_AW-1:0]) begin
            onehotsel[15] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATECTL5_ADDR[REG_AW-1:0]) begin
            onehotsel[19] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATECTL6_ADDR[REG_AW-1:0]) begin
            onehotsel[20] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATESTAT0_ADDR[REG_AW-1:0]) begin
            onehotsel[21] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATEDBGCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[23] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DERATEDBGSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[24] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_PWRCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[25] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_HWLPCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[26] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_CLKGATECTL_ADDR[REG_AW-1:0]) begin
            onehotsel[28] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_RFSHMOD0_ADDR[REG_AW-1:0]) begin
            onehotsel[29] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_RFSHCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[31] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_ZQCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[34] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_ZQCTL1_ADDR[REG_AW-1:0]) begin
            onehotsel[35] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_ZQCTL2_ADDR[REG_AW-1:0]) begin
            onehotsel[36] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_ZQSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[37] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DQSOSCRUNTIME_ADDR[REG_AW-1:0]) begin
            onehotsel[38] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DQSOSCSTAT0_ADDR[REG_AW-1:0]) begin
            onehotsel[39] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DQSOSCCFG0_ADDR[REG_AW-1:0]) begin
            onehotsel[40] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SCHED0_ADDR[REG_AW-1:0]) begin
            onehotsel[42] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SCHED1_ADDR[REG_AW-1:0]) begin
            onehotsel[43] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SCHED3_ADDR[REG_AW-1:0]) begin
            onehotsel[45] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SCHED4_ADDR[REG_AW-1:0]) begin
            onehotsel[46] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFILPCFG0_ADDR[REG_AW-1:0]) begin
            onehotsel[56] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFIUPD0_ADDR[REG_AW-1:0]) begin
            onehotsel[57] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFIMISC_ADDR[REG_AW-1:0]) begin
            onehotsel[59] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFISTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[60] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFIPHYMSTR_ADDR[REG_AW-1:0]) begin
            onehotsel[61] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFI0MSGCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[62] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DFI0MSGSTAT0_ADDR[REG_AW-1:0]) begin
            onehotsel[63] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_POISONCFG_ADDR[REG_AW-1:0]) begin
            onehotsel[64] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_POISONSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[65] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPCTRL0_ADDR[REG_AW-1:0]) begin
            onehotsel[215] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPCTRL1_ADDR[REG_AW-1:0]) begin
            onehotsel[216] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPCTRLCAM_ADDR[REG_AW-1:0]) begin
            onehotsel[217] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPCTRLCMD_ADDR[REG_AW-1:0]) begin
            onehotsel[218] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPCTRLSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[219] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPREFCTRL0_ADDR[REG_AW-1:0]) begin
            onehotsel[221] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_OPREFSTAT0_ADDR[REG_AW-1:0]) begin
            onehotsel[223] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SWCTL_ADDR[REG_AW-1:0]) begin
            onehotsel[225] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SWSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[226] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DBICTL_ADDR[REG_AW-1:0]) begin
            onehotsel[230] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_ODTMAP_ADDR[REG_AW-1:0]) begin
            onehotsel[232] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DATACTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[233] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_SWCTLSTATIC_ADDR[REG_AW-1:0]) begin
            onehotsel[234] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_INITTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[235] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_INITTMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[236] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DDRCTL_VER_NUMBER_ADDR[REG_AW-1:0]) begin
            onehotsel[263] = 1'b1;
         end
         if(reg_addr==REGB_DDRC_CH0_DDRCTL_VER_TYPE_ADDR[REG_AW-1:0]) begin
            onehotsel[264] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP3_ADDR[REG_AW-1:0]) begin
            onehotsel[450] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP4_ADDR[REG_AW-1:0]) begin
            onehotsel[451] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP5_ADDR[REG_AW-1:0]) begin
            onehotsel[452] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP6_ADDR[REG_AW-1:0]) begin
            onehotsel[453] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP7_ADDR[REG_AW-1:0]) begin
            onehotsel[454] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP8_ADDR[REG_AW-1:0]) begin
            onehotsel[455] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP9_ADDR[REG_AW-1:0]) begin
            onehotsel[456] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP10_ADDR[REG_AW-1:0]) begin
            onehotsel[457] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP11_ADDR[REG_AW-1:0]) begin
            onehotsel[458] = 1'b1;
         end
         if(reg_addr==REGB_ADDR_MAP0_ADDRMAP12_ADDR[REG_AW-1:0]) begin
            onehotsel[459] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCCFG_ADDR[REG_AW-1:0]) begin
            onehotsel[474] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCFGR_ADDR[REG_AW-1:0]) begin
            onehotsel[475] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCFGW_ADDR[REG_AW-1:0]) begin
            onehotsel[476] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCTRL_ADDR[REG_AW-1:0]) begin
            onehotsel[509] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCFGQOS0_ADDR[REG_AW-1:0]) begin
            onehotsel[510] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCFGQOS1_ADDR[REG_AW-1:0]) begin
            onehotsel[511] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCFGWQOS0_ADDR[REG_AW-1:0]) begin
            onehotsel[512] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PCFGWQOS1_ADDR[REG_AW-1:0]) begin
            onehotsel[513] = 1'b1;
         end
         if(reg_addr==REGB_ARB_PORT0_PSTAT_ADDR[REG_AW-1:0]) begin
            onehotsel[535] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1882] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[1883] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG2_ADDR[REG_AW-1:0]) begin
            onehotsel[1884] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG3_ADDR[REG_AW-1:0]) begin
            onehotsel[1885] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG4_ADDR[REG_AW-1:0]) begin
            onehotsel[1886] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG5_ADDR[REG_AW-1:0]) begin
            onehotsel[1887] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG6_ADDR[REG_AW-1:0]) begin
            onehotsel[1888] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG7_ADDR[REG_AW-1:0]) begin
            onehotsel[1889] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG9_ADDR[REG_AW-1:0]) begin
            onehotsel[1891] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG12_ADDR[REG_AW-1:0]) begin
            onehotsel[1894] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG13_ADDR[REG_AW-1:0]) begin
            onehotsel[1895] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG14_ADDR[REG_AW-1:0]) begin
            onehotsel[1896] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG23_ADDR[REG_AW-1:0]) begin
            onehotsel[1905] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG24_ADDR[REG_AW-1:0]) begin
            onehotsel[1906] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG25_ADDR[REG_AW-1:0]) begin
            onehotsel[1907] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DRAMSET1TMG30_ADDR[REG_AW-1:0]) begin
            onehotsel[1912] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_INITMR0_ADDR[REG_AW-1:0]) begin
            onehotsel[1938] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_INITMR1_ADDR[REG_AW-1:0]) begin
            onehotsel[1939] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_INITMR2_ADDR[REG_AW-1:0]) begin
            onehotsel[1940] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_INITMR3_ADDR[REG_AW-1:0]) begin
            onehotsel[1941] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFITMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1942] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFITMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[1943] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFITMG2_ADDR[REG_AW-1:0]) begin
            onehotsel[1944] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFITMG4_ADDR[REG_AW-1:0]) begin
            onehotsel[1946] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFITMG5_ADDR[REG_AW-1:0]) begin
            onehotsel[1947] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFILPTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1949] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFILPTMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[1950] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFIUPDTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1951] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFIUPDTMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[1952] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DFIMSGTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1953] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1955] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[1956] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG2_ADDR[REG_AW-1:0]) begin
            onehotsel[1957] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_RFSHSET1TMG3_ADDR[REG_AW-1:0]) begin
            onehotsel[1958] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_ZQSET1TMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1975] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_ZQSET1TMG1_ADDR[REG_AW-1:0]) begin
            onehotsel[1976] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DQSOSCCTL0_ADDR[REG_AW-1:0]) begin
            onehotsel[1985] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DERATEINT_ADDR[REG_AW-1:0]) begin
            onehotsel[1986] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DERATEVAL0_ADDR[REG_AW-1:0]) begin
            onehotsel[1987] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_DERATEVAL1_ADDR[REG_AW-1:0]) begin
            onehotsel[1988] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_HWLPTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1989] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_SCHEDTMG0_ADDR[REG_AW-1:0]) begin
            onehotsel[1990] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_PERFHPR1_ADDR[REG_AW-1:0]) begin
            onehotsel[1991] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_PERFLPR1_ADDR[REG_AW-1:0]) begin
            onehotsel[1992] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_PERFWR1_ADDR[REG_AW-1:0]) begin
            onehotsel[1993] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_TMGCFG_ADDR[REG_AW-1:0]) begin
            onehotsel[1994] = 1'b1;
         end
         if(reg_addr==REGB_FREQ0_CH0_PWRTMG_ADDR[REG_AW-1:0]) begin
            onehotsel[1997] = 1'b1;
         end

   end
 
   // --- Multiplex the output data based on selects ---   
   always_comb begin : select_data_combo_PROC
      case (onehotsel)
         {2833'b0,1'b1} : rfm_data_decoded_next = r0_mstr0; // 0 
         {2829'b0,1'b1,4'b0} : rfm_data_decoded_next = r4_mstr4; // 4 
         {2828'b0,1'b1,5'b0} : rfm_data_decoded_next = r5_stat; // 5 
         {2825'b0,1'b1,8'b0} : rfm_data_decoded_next = r8_mrctrl0; // 8 
         {2824'b0,1'b1,9'b0} : rfm_data_decoded_next = r9_mrctrl1; // 9 
         {2822'b0,1'b1,11'b0} : rfm_data_decoded_next = r11_mrstat ; // 11 
         {2821'b0,1'b1,12'b0} : rfm_data_decoded_next = r12_mrrdata0 ; // 12 
         {2820'b0,1'b1,13'b0} : rfm_data_decoded_next = r13_mrrdata1 ; // 13 
         {2819'b0,1'b1,14'b0} : rfm_data_decoded_next = r14_deratectl0; // 14 
         {2818'b0,1'b1,15'b0} : rfm_data_decoded_next = r15_deratectl1; // 15 
         {2814'b0,1'b1,19'b0} : rfm_data_decoded_next = r19_deratectl5; // 19 
         {2813'b0,1'b1,20'b0} : rfm_data_decoded_next = r20_deratectl6; // 20 
         {2812'b0,1'b1,21'b0} : rfm_data_decoded_next = r21_deratestat0 ; // 21 
         {2810'b0,1'b1,23'b0} : rfm_data_decoded_next = r23_deratedbgctl; // 23 
         {2809'b0,1'b1,24'b0} : rfm_data_decoded_next = r24_deratedbgstat ; // 24 
         {2808'b0,1'b1,25'b0} : rfm_data_decoded_next = r25_pwrctl; // 25 
         {2807'b0,1'b1,26'b0} : rfm_data_decoded_next = r26_hwlpctl; // 26 
         {2805'b0,1'b1,28'b0} : rfm_data_decoded_next = r28_clkgatectl; // 28 
         {2804'b0,1'b1,29'b0} : rfm_data_decoded_next = r29_rfshmod0; // 29 
         {2802'b0,1'b1,31'b0} : rfm_data_decoded_next = r31_rfshctl0; // 31 
         {2799'b0,1'b1,34'b0} : rfm_data_decoded_next = r34_zqctl0; // 34 
         {2798'b0,1'b1,35'b0} : rfm_data_decoded_next = r35_zqctl1; // 35 
         {2797'b0,1'b1,36'b0} : rfm_data_decoded_next = r36_zqctl2; // 36 
         {2796'b0,1'b1,37'b0} : rfm_data_decoded_next = r37_zqstat ; // 37 
         {2795'b0,1'b1,38'b0} : rfm_data_decoded_next = r38_dqsoscruntime; // 38 
         {2794'b0,1'b1,39'b0} : rfm_data_decoded_next = r39_dqsoscstat0; // 39 
         {2793'b0,1'b1,40'b0} : rfm_data_decoded_next = r40_dqsosccfg0; // 40 
         {2791'b0,1'b1,42'b0} : rfm_data_decoded_next = r42_sched0; // 42 
         {2790'b0,1'b1,43'b0} : rfm_data_decoded_next = r43_sched1; // 43 
         {2788'b0,1'b1,45'b0} : rfm_data_decoded_next = r45_sched3; // 45 
         {2787'b0,1'b1,46'b0} : rfm_data_decoded_next = r46_sched4; // 46 
         {2777'b0,1'b1,56'b0} : rfm_data_decoded_next = r56_dfilpcfg0; // 56 
         {2776'b0,1'b1,57'b0} : rfm_data_decoded_next = r57_dfiupd0; // 57 
         {2774'b0,1'b1,59'b0} : rfm_data_decoded_next = r59_dfimisc; // 59 
         {2773'b0,1'b1,60'b0} : rfm_data_decoded_next = r60_dfistat ; // 60 
         {2772'b0,1'b1,61'b0} : rfm_data_decoded_next = r61_dfiphymstr; // 61 
         {2771'b0,1'b1,62'b0} : rfm_data_decoded_next = r62_dfi0msgctl0; // 62 
         {2770'b0,1'b1,63'b0} : rfm_data_decoded_next = r63_dfi0msgstat0 ; // 63 
         {2769'b0,1'b1,64'b0} : rfm_data_decoded_next = r64_poisoncfg; // 64 
         {2768'b0,1'b1,65'b0} : rfm_data_decoded_next = r65_poisonstat ; // 65 
         {2618'b0,1'b1,215'b0} : rfm_data_decoded_next = r215_opctrl0; // 215 
         {2617'b0,1'b1,216'b0} : rfm_data_decoded_next = r216_opctrl1; // 216 
         {2616'b0,1'b1,217'b0} : rfm_data_decoded_next = r217_opctrlcam ; // 217 
         {2615'b0,1'b1,218'b0} : rfm_data_decoded_next = r218_opctrlcmd; // 218 
         {2614'b0,1'b1,219'b0} : rfm_data_decoded_next = r219_opctrlstat ; // 219 
         {2612'b0,1'b1,221'b0} : rfm_data_decoded_next = r221_oprefctrl0; // 221 
         {2610'b0,1'b1,223'b0} : rfm_data_decoded_next = r223_oprefstat0 ; // 223 
         {2608'b0,1'b1,225'b0} : rfm_data_decoded_next = r225_swctl; // 225 
         {2607'b0,1'b1,226'b0} : rfm_data_decoded_next = r226_swstat ; // 226 
         {2603'b0,1'b1,230'b0} : rfm_data_decoded_next = r230_dbictl; // 230 
         {2601'b0,1'b1,232'b0} : rfm_data_decoded_next = r232_odtmap; // 232 
         {2600'b0,1'b1,233'b0} : rfm_data_decoded_next = r233_datactl0; // 233 
         {2599'b0,1'b1,234'b0} : rfm_data_decoded_next = r234_swctlstatic; // 234 
         {2598'b0,1'b1,235'b0} : rfm_data_decoded_next = r235_inittmg0; // 235 
         {2597'b0,1'b1,236'b0} : rfm_data_decoded_next = r236_inittmg1; // 236 
         {2570'b0,1'b1,263'b0} : rfm_data_decoded_next = r263_ddrctl_ver_number ; // 263 
         {2569'b0,1'b1,264'b0} : rfm_data_decoded_next = r264_ddrctl_ver_type ; // 264 
         {2383'b0,1'b1,450'b0} : rfm_data_decoded_next = r450_addrmap3_map0; // 450 
         {2382'b0,1'b1,451'b0} : rfm_data_decoded_next = r451_addrmap4_map0; // 451 
         {2381'b0,1'b1,452'b0} : rfm_data_decoded_next = r452_addrmap5_map0; // 452 
         {2380'b0,1'b1,453'b0} : rfm_data_decoded_next = r453_addrmap6_map0; // 453 
         {2379'b0,1'b1,454'b0} : rfm_data_decoded_next = r454_addrmap7_map0; // 454 
         {2378'b0,1'b1,455'b0} : rfm_data_decoded_next = r455_addrmap8_map0; // 455 
         {2377'b0,1'b1,456'b0} : rfm_data_decoded_next = r456_addrmap9_map0; // 456 
         {2376'b0,1'b1,457'b0} : rfm_data_decoded_next = r457_addrmap10_map0; // 457 
         {2375'b0,1'b1,458'b0} : rfm_data_decoded_next = r458_addrmap11_map0; // 458 
         {2374'b0,1'b1,459'b0} : rfm_data_decoded_next = r459_addrmap12_map0; // 459 
         {2359'b0,1'b1,474'b0} : rfm_data_decoded_next = r474_pccfg_port0; // 474 
         {2358'b0,1'b1,475'b0} : rfm_data_decoded_next = r475_pcfgr_port0; // 475 
         {2357'b0,1'b1,476'b0} : rfm_data_decoded_next = r476_pcfgw_port0; // 476 
         {2324'b0,1'b1,509'b0} : rfm_data_decoded_next = r509_pctrl_port0; // 509 
         {2323'b0,1'b1,510'b0} : rfm_data_decoded_next = r510_pcfgqos0_port0; // 510 
         {2322'b0,1'b1,511'b0} : rfm_data_decoded_next = r511_pcfgqos1_port0; // 511 
         {2321'b0,1'b1,512'b0} : rfm_data_decoded_next = r512_pcfgwqos0_port0; // 512 
         {2320'b0,1'b1,513'b0} : rfm_data_decoded_next = r513_pcfgwqos1_port0; // 513 
         {2298'b0,1'b1,535'b0} : rfm_data_decoded_next = r535_pstat_port0 ; // 535 
         {951'b0,1'b1,1882'b0} : rfm_data_decoded_next = r1882_dramset1tmg0_freq0; // 1882 
         {950'b0,1'b1,1883'b0} : rfm_data_decoded_next = r1883_dramset1tmg1_freq0; // 1883 
         {949'b0,1'b1,1884'b0} : rfm_data_decoded_next = r1884_dramset1tmg2_freq0; // 1884 
         {948'b0,1'b1,1885'b0} : rfm_data_decoded_next = r1885_dramset1tmg3_freq0; // 1885 
         {947'b0,1'b1,1886'b0} : rfm_data_decoded_next = r1886_dramset1tmg4_freq0; // 1886 
         {946'b0,1'b1,1887'b0} : rfm_data_decoded_next = r1887_dramset1tmg5_freq0; // 1887 
         {945'b0,1'b1,1888'b0} : rfm_data_decoded_next = r1888_dramset1tmg6_freq0; // 1888 
         {944'b0,1'b1,1889'b0} : rfm_data_decoded_next = r1889_dramset1tmg7_freq0; // 1889 
         {942'b0,1'b1,1891'b0} : rfm_data_decoded_next = r1891_dramset1tmg9_freq0; // 1891 
         {939'b0,1'b1,1894'b0} : rfm_data_decoded_next = r1894_dramset1tmg12_freq0; // 1894 
         {938'b0,1'b1,1895'b0} : rfm_data_decoded_next = r1895_dramset1tmg13_freq0; // 1895 
         {937'b0,1'b1,1896'b0} : rfm_data_decoded_next = r1896_dramset1tmg14_freq0; // 1896 
         {928'b0,1'b1,1905'b0} : rfm_data_decoded_next = r1905_dramset1tmg23_freq0; // 1905 
         {927'b0,1'b1,1906'b0} : rfm_data_decoded_next = r1906_dramset1tmg24_freq0; // 1906 
         {926'b0,1'b1,1907'b0} : rfm_data_decoded_next = r1907_dramset1tmg25_freq0; // 1907 
         {921'b0,1'b1,1912'b0} : rfm_data_decoded_next = r1912_dramset1tmg30_freq0; // 1912 
         {895'b0,1'b1,1938'b0} : rfm_data_decoded_next = r1938_initmr0_freq0; // 1938 
         {894'b0,1'b1,1939'b0} : rfm_data_decoded_next = r1939_initmr1_freq0; // 1939 
         {893'b0,1'b1,1940'b0} : rfm_data_decoded_next = r1940_initmr2_freq0; // 1940 
         {892'b0,1'b1,1941'b0} : rfm_data_decoded_next = r1941_initmr3_freq0; // 1941 
         {891'b0,1'b1,1942'b0} : rfm_data_decoded_next = r1942_dfitmg0_freq0; // 1942 
         {890'b0,1'b1,1943'b0} : rfm_data_decoded_next = r1943_dfitmg1_freq0; // 1943 
         {889'b0,1'b1,1944'b0} : rfm_data_decoded_next = r1944_dfitmg2_freq0; // 1944 
         {887'b0,1'b1,1946'b0} : rfm_data_decoded_next = r1946_dfitmg4_freq0; // 1946 
         {886'b0,1'b1,1947'b0} : rfm_data_decoded_next = r1947_dfitmg5_freq0; // 1947 
         {884'b0,1'b1,1949'b0} : rfm_data_decoded_next = r1949_dfilptmg0_freq0; // 1949 
         {883'b0,1'b1,1950'b0} : rfm_data_decoded_next = r1950_dfilptmg1_freq0; // 1950 
         {882'b0,1'b1,1951'b0} : rfm_data_decoded_next = r1951_dfiupdtmg0_freq0; // 1951 
         {881'b0,1'b1,1952'b0} : rfm_data_decoded_next = r1952_dfiupdtmg1_freq0; // 1952 
         {880'b0,1'b1,1953'b0} : rfm_data_decoded_next = r1953_dfimsgtmg0_freq0; // 1953 
         {878'b0,1'b1,1955'b0} : rfm_data_decoded_next = r1955_rfshset1tmg0_freq0; // 1955 
         {877'b0,1'b1,1956'b0} : rfm_data_decoded_next = r1956_rfshset1tmg1_freq0; // 1956 
         {876'b0,1'b1,1957'b0} : rfm_data_decoded_next = r1957_rfshset1tmg2_freq0; // 1957 
         {875'b0,1'b1,1958'b0} : rfm_data_decoded_next = r1958_rfshset1tmg3_freq0; // 1958 
         {858'b0,1'b1,1975'b0} : rfm_data_decoded_next = r1975_zqset1tmg0_freq0; // 1975 
         {857'b0,1'b1,1976'b0} : rfm_data_decoded_next = r1976_zqset1tmg1_freq0; // 1976 
         {848'b0,1'b1,1985'b0} : rfm_data_decoded_next = r1985_dqsoscctl0_freq0; // 1985 
         {847'b0,1'b1,1986'b0} : rfm_data_decoded_next = r1986_derateint_freq0; // 1986 
         {846'b0,1'b1,1987'b0} : rfm_data_decoded_next = r1987_derateval0_freq0; // 1987 
         {845'b0,1'b1,1988'b0} : rfm_data_decoded_next = r1988_derateval1_freq0; // 1988 
         {844'b0,1'b1,1989'b0} : rfm_data_decoded_next = r1989_hwlptmg0_freq0; // 1989 
         {843'b0,1'b1,1990'b0} : rfm_data_decoded_next = r1990_schedtmg0_freq0; // 1990 
         {842'b0,1'b1,1991'b0} : rfm_data_decoded_next = r1991_perfhpr1_freq0; // 1991 
         {841'b0,1'b1,1992'b0} : rfm_data_decoded_next = r1992_perflpr1_freq0; // 1992 
         {840'b0,1'b1,1993'b0} : rfm_data_decoded_next = r1993_perfwr1_freq0; // 1993 
         {839'b0,1'b1,1994'b0} : rfm_data_decoded_next = r1994_tmgcfg_freq0; // 1994 
         {836'b0,1'b1,1997'b0} : rfm_data_decoded_next = r1997_pwrtmg_freq0; // 1997 

        default : rfm_data_decoded_next = rfm_data_decoded;
      endcase 
   end  

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
   property apb_onehotsel_legal;
      @(posedge pclk) disable iff(!presetn)
      $onehot0(onehotsel);
   endproperty : apb_onehotsel_legal
   a_apb_onehotsel_legal :  assert property (apb_onehotsel_legal) else 
     $display("%0t ERROR: register selector is one hot.",$realtime);
     
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

   always @(posedge pclk or negedge presetn) begin : sample_pclk_rdata_PROC
      if (~presetn) begin
         rfm_data_decoded <= {($bits(rfm_data_decoded)){1'b0}};
      end else begin
        if(apb_slv_ns==ADDRDECODE && (~pwrite)) begin
            rfm_data_decoded <=  rfm_data_decoded_next;
         end else if (apb_slv_ns==SAMPLERDY && (~pwrite) && invalid_access) begin
            rfm_data_decoded <=  REG_WIDTH'(0);
         end
      end
   end

   assign prdata[APB_DW-1:0] = rfm_data_decoded[REG_WIDTH-1:0];
    
   // pslverr set whein sync with pready, asserted when 
   // [1] address out of range in sync with pready
   // [2] NS read access to Trustzone register  
   always @ (posedge pclk or negedge presetn) begin : sample_pclk_err_PROC
      if (~presetn) begin
         invalid_access <= 1'b0;
         pslverr   <= 1'b0;
      end else begin
         if(apb_slv_ns==IDLE) begin
            invalid_access <= 1'b0;
         end else if(apb_slv_ns==ADDRDECODE) begin
            if(~(|onehotsel)) begin
               invalid_access <= 1'b1;
            end
         end         
         pslverr <= (invalid_access && apb_slv_ns==SAMPLERDY) ? 1'b1 : 1'b0;
      end 
   end

endmodule
