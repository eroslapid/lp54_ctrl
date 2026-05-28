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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/top/dwc_ddrctl_ddrc_cpedfiic.sv#1 $
// -------------------------------------------------------------------------
// Description:
//    CPE-DFI interconnection
//
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
`include "dfi/DWC_ddrctl_dfi_pkg.svh"
`include "top/dwc_ddrctl_ddrc_cpedfi_if.svh"

module dwc_ddrctl_ddrc_cpedfiic
import DWC_ddrctl_reg_pkg::*;
import DWC_ddrctl_dfi_pkg::*;
#(
    parameter NUM_RANKS                            = `MEMC_NUM_RANKS
   ,parameter FREQ_RATIO                           = `MEMC_FREQ_RATIO
   ,parameter BANK_BITS                            = `MEMC_BANK_BITS
   ,parameter BG_BITS                              = `MEMC_BG_BITS
   ,parameter CID_WIDTH                            = `UMCTL2_CID_WIDTH
   ,parameter CID_WIDTH_DDRC                       = `DDRCTL_DDRC_CID_WIDTH
   ,parameter HIF_ADDR_WIDTH                       = `MEMC_HIF_ADDR_WIDTH
   ,parameter ADDR_WIDTH                           = `MEMC_DFI_ADDR_WIDTH
   ,parameter RESET_WIDTH                          = `UMCTL2_RESET_WIDTH
   ,parameter NUM_LANES                            = 4
   ,parameter DATA_CS_BITS                         = FREQ_RATIO*NUM_RANKS*NUM_LANES
   ,parameter PARITY_IN_WIDTH                      = 2
   ,parameter NUM_DRAM_CLKS                        = 3
)
(
    dwc_ddrctl_ddrc_cpedfi_if.ddrc_dfi_mp          ddrc_cpedfiif
   ,output  dfi_address_s                          dfi_address
   ,output  logic [FREQ_RATIO*BANK_BITS-1:0]       dfi_bank
   ,output  logic [1:0]                            dfi_freq_ratio
   ,output  logic [FREQ_RATIO*BG_BITS-1:0]         dfi_bg
   ,output  logic [FREQ_RATIO-1:0]                 dfi_act_n
   ,output  logic [FREQ_RATIO*CID_WIDTH-1:0]       dfi_cid
   ,output  logic [FREQ_RATIO-1:0]                 dfi_cas_n
   ,output  logic [FREQ_RATIO-1:0]                 dfi_ras_n
   ,output  logic [FREQ_RATIO-1:0]                 dfi_we_n
   ,output  logic [FREQ_RATIO*NUM_RANKS-1:0]       dfi_cke
   ,output  logic [FREQ_RATIO*NUM_RANKS-1:0]       dfi_cs
   ,output  logic [FREQ_RATIO*NUM_RANKS-1:0]       dfi_odt
   ,output  logic [RESET_WIDTH-1:0]                dfi_reset_n
   ,output  logic [FREQ_RATIO*PARITY_IN_WIDTH-1:0] dfi_parity_in
   ,input   logic                                  dfi_init_complete
   ,output  logic                                  dfi_init_start
   ,output  logic [4:0]                            dfi_frequency
   ,output  logic                                  dfi_2n_mode
   ,output  logic                                  dfi_ctrlupd_req
   ,input   logic                                  dfi_ctrlupd_ack
   ,input   logic                                  dfi_phyupd_req
   ,output  logic                                  dfi_phyupd_ack
   ,output  logic                                  dfi_lp_ctrl_req
   ,output  logic [DFI_LP_WAKEUP_PD_WIDTH-1:0]     dfi_lp_ctrl_wakeup
   ,input   logic                                  dfi_lp_ctrl_ack
   ,output  logic                                  dfi_lp_data_req
   ,output  logic [DFI_LP_WAKEUP_PD_WIDTH-1:0]     dfi_lp_data_wakeup
   ,input   logic                                  dfi_lp_data_ack
   ,output  logic [NUM_DRAM_CLKS-1:0]              dfi_dram_clk_disable
   ,input   logic                                  dfi_phymstr_req
   ,input   logic [NUM_RANKS-1:0]                  dfi_phymstr_cs_state
   ,input   logic                                  dfi_phymstr_state_sel
   ,input   logic [1:0]                            dfi_phymstr_type
   ,output  logic                                  dfi_phymstr_ack
   ,output  logic [DATA_CS_BITS-1:0]               dfi_wrdata_cs
   ,output  logic [DATA_CS_BITS-1:0]               dfi_rddata_cs
   ,output  logic                                  dfi_ctrlmsg_req
   ,output  logic [7:0]                            dfi_ctrlmsg
   ,output  logic [15:0]                           dfi_ctrlmsg_data
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Not used in some configuration with only DDR4
   ,input   logic                                  dfi_ctrlmsg_ack
//spyglass enable_block W240

);

   //-------------------------------------------------------
   // Internal signals aligned the width
   //-------------------------------------------------------
   logic [FREQ_RATIO*CID_WIDTH-1:0]    ddrc_dfi_cid;

   generate
      for (genvar i=0;i<FREQ_RATIO;i++) begin
         assign ddrc_dfi_cid[i*CID_WIDTH+:CID_WIDTH] = {{(CID_WIDTH-CID_WIDTH_DDRC){1'b0}},ddrc_cpedfiif.dfi_cid[i*CID_WIDTH_DDRC+:CID_WIDTH_DDRC]};

      end
   endgenerate
   
   //-------------------------------------------------------
   // signals from CPE are selected by DDR mode
   //-------------------------------------------------------
   always_comb begin
         dfi_act_n              = ddrc_cpedfiif.dfi_act_n;
         dfi_address            = ddrc_cpedfiif.dfi_address;
         dfi_bank               = ddrc_cpedfiif.dfi_bank;
         dfi_freq_ratio         = ddrc_cpedfiif.dfi_freq_ratio;
         dfi_bg                 = ddrc_cpedfiif.dfi_bg;
         dfi_cid                = ddrc_dfi_cid;
         dfi_cas_n              = ddrc_cpedfiif.dfi_cas_n;
         dfi_ras_n              = ddrc_cpedfiif.dfi_ras_n;
         dfi_we_n               = ddrc_cpedfiif.dfi_we_n;
         dfi_cke                = ddrc_cpedfiif.dfi_cke;
         dfi_cs                 = ddrc_cpedfiif.dfi_cs;
         dfi_odt                = ddrc_cpedfiif.dfi_odt;
         dfi_reset_n            = ddrc_cpedfiif.dfi_reset_n;
         dfi_parity_in          = ddrc_cpedfiif.dfi_parity_in;
         dfi_init_start         = ddrc_cpedfiif.dfi_init_start;
         dfi_frequency          = ddrc_cpedfiif.dfi_frequency;
         dfi_2n_mode            = ddrc_cpedfiif.dfi_2n_mode;
         dfi_ctrlupd_req        = ddrc_cpedfiif.dfi_ctrlupd_req;
         dfi_phyupd_ack         = ddrc_cpedfiif.dfi_phyupd_ack;
         dfi_phymstr_ack        = ddrc_cpedfiif.dfi_phymstr_ack;
         dfi_lp_ctrl_req        = ddrc_cpedfiif.dfi_lp_ctrl_req;
         dfi_lp_ctrl_wakeup     = ddrc_cpedfiif.dfi_lp_ctrl_wakeup;
         dfi_lp_data_req        = ddrc_cpedfiif.dfi_lp_data_req;
         dfi_lp_data_wakeup     = ddrc_cpedfiif.dfi_lp_data_wakeup;
         dfi_dram_clk_disable   = ddrc_cpedfiif.dfi_dram_clk_disable;
         dfi_wrdata_cs          = ddrc_cpedfiif.dfi_wrdata_cs;
         dfi_rddata_cs          = ddrc_cpedfiif.dfi_rddata_cs;
   end

   //-------------------------------------------------------
   // DFI controller message interface.
   //-------------------------------------------------------
   assign dfi_ctrlmsg_req                    = ddrc_cpedfiif.dfi_ctrlmsg_req;
   assign dfi_ctrlmsg                        = ddrc_cpedfiif.dfi_ctrlmsg;
   assign dfi_ctrlmsg_data                   = ddrc_cpedfiif.dfi_ctrlmsg_data;
   assign ddrc_cpedfiif.dfi_ctrlmsg_ack      = dfi_ctrlmsg_ack;

   //-------------------------------------------------------
   // signals from DFI go to DDRC_CPE
   //-------------------------------------------------------
   assign ddrc_cpedfiif.dfi_init_complete       = dfi_init_complete;
   assign ddrc_cpedfiif.dfi_ctrlupd_ack         = dfi_ctrlupd_ack;
   assign ddrc_cpedfiif.dfi_phyupd_req          = dfi_phyupd_req;
   assign ddrc_cpedfiif.dfi_lp_ctrl_ack         = dfi_lp_ctrl_ack;
   assign ddrc_cpedfiif.dfi_lp_data_ack         = dfi_lp_data_ack;

   // PHYMSTR is supported by DDRC_CPE only
   assign ddrc_cpedfiif.dfi_phymstr_req         = dfi_phymstr_req;
   assign ddrc_cpedfiif.dfi_phymstr_cs_state    = dfi_phymstr_cs_state;
   assign ddrc_cpedfiif.dfi_phymstr_state_sel   = dfi_phymstr_state_sel;
   assign ddrc_cpedfiif.dfi_phymstr_type        = dfi_phymstr_type;

   //-------------------------------------------------------
   // signals from DFI go to PAS CPE
   //-------------------------------------------------------

endmodule : dwc_ddrctl_ddrc_cpedfiic
