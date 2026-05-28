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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/dfi_ic.sv#3 $
// -------------------------------------------------------------------------
// Description:
//            DFI interconnect
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module dfi_ic
import DWC_ddrctl_reg_pkg::*;
#(
    parameter     NUM_RANKS                     = `MEMC_NUM_RANKS
   ,parameter     DFI0_CS_WIDTH                 = `DDRCTL_DFI0_CS_WIDTH
   ,parameter     DFI1_CS_WIDTH                 = `DDRCTL_DFI1_CS_WIDTH
   ,parameter     FREQ_RATIO                    = `MEMC_FREQ_RATIO
   ,parameter     NUM_CHANNEL                   = `UMCTL2_NUM_DATA_CHANNEL
   ,parameter     LPDDR_DUAL_CHANNEL_EN         = `DDRCTL_LPDDR_DUAL_CHANNEL_EN
   ,parameter     DDR_DCH_HBW                   = `DDRCTL_DDR_DCH_HBW
   ,parameter     RESET_WIDTH                   = `UMCTL2_RESET_WIDTH
   ,parameter     NUM_CLKS                      = `MEMC_NUM_CLKS
   ,parameter     BANK_BITS                     = `MEMC_BANK_BITS
   ,parameter     BG_BITS                       = `MEMC_BG_BITS
   ,parameter     CID_WIDTH                     = `UMCTL2_CID_WIDTH
   ,parameter     DDRC_TOTAL_DATA_WIDTH         = `MEMC_DFI_TOTAL_DATA_WIDTH
   ,parameter     DDRC_TOTAL_DATAEN_WIDTH       = `MEMC_DFI_TOTAL_DATAEN_WIDTH
   ,parameter     DDRC_TOTAL_MASK_WIDTH         = `MEMC_DFI_TOTAL_MASK_WIDTH
   ,parameter     DRAM_TOTAL_DATA_WIDTH         = `MEMC_DRAM_TOTAL_DATA_WIDTH
   ,parameter     DRAM_DATA_WIDTH               = `DDRCTL_DDR_DRAM_DATA_WIDTH
   ,parameter     DRAM_ECC_WIDTH                = `DDRCTL_DDR_DRAM_ECC_WIDTH
   ,parameter     NUM_DFI                       = `UMCTL2_NUM_DFI
   ,parameter     DFI_ADDR_WIDTH                = `MEMC_DFI_ADDR_WIDTH
   ,parameter     DFI_BG_WIDTH                  = `DDRCTL_DFI_BG_WIDTH
   ,parameter     DFI_CID_WIDTH                 = `DDRCTL_DFI_CID_WIDTH
   ,parameter     DFI_LP_WAKEUP_WIDTH           = 4
   ,parameter     DFI_PARITY_IN_WIDTH           = 2
   ,parameter     DFI_DATA_WIDTH                = `DDRCTL_DFI_DATA_WIDTH
   ,parameter     DFI_MASK_WIDTH                = `DDRCTL_DFI_MASK_WIDTH
   ,parameter     DFI_DATAEN_WIDTH              = `DDRCTL_DFI_DATAEN_WIDTH
   ,parameter     REG_DFI_OUT_VAL               = `MEMC_REG_DFI_OUT_VAL
   ,parameter     OCCAP_EN                      = `UMCTL2_OCCAP_EN
   ,parameter     OCCAP_PIPELINE_EN             = 0
   ,parameter     BCM_VERIF_EN                  = 1
   ,parameter     BCM_DDRC_N_SYNC               = 2
)
(
   //-------------------------------------------
   // Command Interface
   //-------------------------------------------
    dwc_ddrctl_ddrc_cpedfi_if.dfi_ic_mp                              cp_dfiif_dch0
    //ccx_tgl : ; cp_dfiif_dch0.dfi_cs[3:2] ; ; The bits are assigned to dfi0_cs_P1[1:0] and is not toggled.
    //ccx_tgl : ; cp_dfiif_dch0.dfi_ctrlmsg[2] ; 0->1 ; SystemVerilog Interface(redundant): LPDDR5/4/4X Controller only supports Fixed value of 0x8,0x2,0x9,0xA (Similar thing was fixed in Bug 10153)
    //ccx_tgl : ; cp_dfiif_dch0.dfi_ctrlmsg[7:4] ; 0->1 ; SystemVerilog Interface(redundant): LPDDR5/4/4X Controller only supports Fixed value of 0x8,0x2,0x9,0xA (Similar thing was fixed in Bug 10153)
    //ccx_tgl : ; cp_dfiif_dch0.dfi_phyupd_type[1:0] ;  ; Both DDR5/4 and LPDDR5/4/4X SNPS PHY only employ tphyupd_type0 (2'b00)

   ,input   logic                                                    core_ddrc_core_clk
   ,input   logic                                                    core_ddrc_rstn

   ,input   logic [1:0]                                              reg_ddrc_dfi_channel_mode

   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P0-1:0]                      dfi0_address_P0_out
   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P1-1:0]                      dfi0_address_P1_out
   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P2-1:0]                      dfi0_address_P2_out
   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P3-1:0]                      dfi0_address_P3_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cke_P0_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cke_P1_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cke_P2_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cke_P3_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cs_P0_out
    //ccx_tgl : ; dfi0_cs_P1_out; ; dfi0_cs_P1/P3_out cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cs_P1_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cs_P2_out
    //ccx_tgl : ; dfi0_cs_P3_out; ; dfi0_cs_P1/P3_out cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_cs_P3_out


   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P0-1:0]                      dfi1_address_P0_out
   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P1-1:0]                      dfi1_address_P1_out
   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P2-1:0]                      dfi1_address_P2_out
   ,output  logic [`MEMC_DFI_ADDR_WIDTH_P3-1:0]                      dfi1_address_P3_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cke_P0_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cke_P1_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cke_P2_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cke_P3_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cs_P0_out
    //ccx_tgl : ; dfi1_cs_P1_out; ; dfi0_cs_P1/P3_out cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cs_P1_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cs_P2_out
    //ccx_tgl : ; dfi1_cs_P3_out; ; dfi0_cs_P1/P3_out cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_cs_P3_out
   //-------------------------------------------
   // Non-DFI uMCTL2 PHY Sideband Signals
   //-------------------------------------------
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH*4-1:0]                    dwc_ddrphy_snoop_en_dch0

   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy0_snoop_en_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy0_snoop_en_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy0_snoop_en_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy0_snoop_en_P3_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy1_snoop_en_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy1_snoop_en_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy1_snoop_en_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                         dwc_ddrphy1_snoop_en_P3_out

   //-------------------------------------------
   // Side-band Signals
   //-------------------------------------------
   ,output  logic [RESET_WIDTH-1:0]                                  dfi_reset_n_out

   ,output  logic                                                    dfi0_init_start_out
   ,output  logic [4:0]                                              dfi0_frequency_out
   ,output  logic [1:0]                                              dfi0_freq_ratio_out
   ,input   logic                                                    dfi0_init_complete_in
   //ccx_tgl : ; dfi0_freq_fsp_out[1]; ; DDRCTL only supports two FSPs, so dfin_freq_fsp[1] cannot be toggled. Toggle coverage for this pin should be waived off.
   ,output  logic [1:0]                                              dfi0_freq_fsp_out

   ,input   logic [FREQ_RATIO*NUM_RANKS-1:0]                         dfi_wck_cs_dch0
   ,input   logic [FREQ_RATIO-1:0]                                   dfi_wck_en_dch0
   ,input   logic [2*FREQ_RATIO-1:0]                                 dfi_wck_toggle_dch0

   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_wck_cs_P0_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_wck_cs_P1_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_wck_cs_P2_out
   ,output  logic [DFI0_CS_WIDTH-1:0]                                dfi0_wck_cs_P3_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi0_wck_en_P0_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi0_wck_en_P1_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi0_wck_en_P2_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi0_wck_en_P3_out
   ,output  logic [1:0]                                              dfi0_wck_toggle_P0_out
   ,output  logic [1:0]                                              dfi0_wck_toggle_P1_out
   ,output  logic [1:0]                                              dfi0_wck_toggle_P2_out
   ,output  logic [1:0]                                              dfi0_wck_toggle_P3_out

   ,output  logic [NUM_CLKS-1:0]                                     dfi0_dram_clk_disable_P0_out
   ,output  logic [NUM_CLKS-1:0]                                     dfi0_dram_clk_disable_P1_out
   ,output  logic [NUM_CLKS-1:0]                                     dfi0_dram_clk_disable_P2_out
   ,output  logic [NUM_CLKS-1:0]                                     dfi0_dram_clk_disable_P3_out
   ,output  logic                                                    dfi0_lp_ctrl_req_out
   ,output  logic [DFI_LP_WAKEUP_WIDTH-1:0]                          dfi0_lp_ctrl_wakeup_out
   ,input   logic                                                    dfi0_lp_ctrl_ack_in
   ,output  logic                                                    dfi0_lp_data_req_out
   ,output  logic [DFI_LP_WAKEUP_WIDTH-1:0]                          dfi0_lp_data_wakeup_out
   ,input   logic                                                    dfi0_lp_data_ack_in
   ,output  logic                                                    dfi0_ctrlupd_req_out
   ,input   logic                                                    dfi0_ctrlupd_ack_in
   ,input   logic                                                    dfi0_phyupd_req_in
    //ccx_tgl : ; dfi0_phyupd_type_in; ; Both DDR5/4 PHY and LPDDR5/4/4X PHY only employ tphyupd_type0 (2'b00)
   ,input   logic [1:0]                                              dfi0_phyupd_type_in
   ,output  logic                                                    dfi0_phyupd_ack_out
   ,output  logic                                                    dfi0_ctrlmsg_req_out
    //ccx_tgl : ; dfi0_ctrlmsg_out[2]; ; Controller only supports Fixed value of 0x4,0x2,0x9,0xA
    //ccx_tgl : ; dfi0_ctrlmsg_out[7:4]; ; Controller only supports Fixed value of 0x4,0x2,0x9,0xA
   ,output  logic [7:0]                                              dfi0_ctrlmsg_out
   ,output  logic [15:0]                                             dfi0_ctrlmsg_data_out
   ,input   logic                                                    dfi0_ctrlmsg_ack_in
   ,input   logic                                                    dfi0_phymstr_req_in
   ,input   logic [NUM_RANKS-1:0]                                    dfi0_phymstr_cs_state_in
   ,input   logic                                                    dfi0_phymstr_state_sel_in
   ,input   logic [1:0]                                              dfi0_phymstr_type_in
   ,output  logic                                                    dfi0_phymstr_ack_out

   ,output  logic                                                    dfi1_init_start_out
   ,output  logic [4:0]                                              dfi1_frequency_out
   ,output  logic [1:0]                                              dfi1_freq_ratio_out
   ,input   logic                                                    dfi1_init_complete_in
   //ccx_tgl : ; dfi1_freq_fsp_out[1]; ; DDRCTL only supports two FSPs, so dfin_freq_fsp[1] cannot be toggled. Toggle coverage for this pin should be waived off.
   ,output  logic [1:0]                                              dfi1_freq_fsp_out

   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_wck_cs_P0_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_wck_cs_P1_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_wck_cs_P2_out
   ,output  logic [DFI1_CS_WIDTH-1:0]                                dfi1_wck_cs_P3_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi1_wck_en_P0_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi1_wck_en_P1_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi1_wck_en_P2_out
   ,output  logic [DFI_DATA_WIDTH/16-1:0]                            dfi1_wck_en_P3_out
   ,output  logic [1:0]                                              dfi1_wck_toggle_P0_out
   ,output  logic [1:0]                                              dfi1_wck_toggle_P1_out
   ,output  logic [1:0]                                              dfi1_wck_toggle_P2_out
   ,output  logic [1:0]                                              dfi1_wck_toggle_P3_out

   ,output  logic [NUM_CLKS-1:0]                                     dfi1_dram_clk_disable_P0_out
   ,output  logic [NUM_CLKS-1:0]                                     dfi1_dram_clk_disable_P1_out
   ,output  logic [NUM_CLKS-1:0]                                     dfi1_dram_clk_disable_P2_out
   ,output  logic [NUM_CLKS-1:0]                                     dfi1_dram_clk_disable_P3_out
   ,output  logic                                                    dfi1_lp_ctrl_req_out
   ,output  logic [DFI_LP_WAKEUP_WIDTH-1:0]                          dfi1_lp_ctrl_wakeup_out
   ,input   logic                                                    dfi1_lp_ctrl_ack_in
   ,output  logic                                                    dfi1_lp_data_req_out
   ,output  logic [DFI_LP_WAKEUP_WIDTH-1:0]                          dfi1_lp_data_wakeup_out
   ,input   logic                                                    dfi1_lp_data_ack_in
   ,output  logic                                                    dfi1_ctrlupd_req_out
   ,input   logic                                                    dfi1_ctrlupd_ack_in
   ,input   logic                                                    dfi1_phyupd_req_in
    //ccx_tgl : ; dfi1_phyupd_type_in; ; Both DDR5/4 PHY and LPDDR5/4/4X PHY only employ tphyupd_type0 (2'b00)
   ,input   logic [1:0]                                              dfi1_phyupd_type_in
   ,output  logic                                                    dfi1_phyupd_ack_out
   ,output  logic                                                    dfi1_ctrlmsg_req_out
   ,output  logic [7:0]                                              dfi1_ctrlmsg_out
   ,output  logic [15:0]                                             dfi1_ctrlmsg_data_out
    // ccx_tgl: ;dfi1_ctrlmsg_ack_in; ; This DFI1* interface is not used and its present to comply with PHY
   ,input   logic                                                    dfi1_ctrlmsg_ack_in
   ,input   logic                                                    dfi1_phymstr_req_in
   // ccx_tgl: ;dfi1_phymstr_cs_state_in; ;  dfi1_phymstr_cs_state is not used in Single DDRC Dual DFI configuration
   ,input   logic [NUM_RANKS-1:0]                                    dfi1_phymstr_cs_state_in
   // ccx_tgl: ;dfi1_phymstr_state_sel_in; ;  dfi1_phymstr_state_sel_in is not used in Single DDRC Dual DFI configuration
   ,input   logic                                                    dfi1_phymstr_state_sel_in
   // ccx_tgl: ;dfi1_phymstr_type_in; ;  dfi1_phymstr_type_in is not used in Single DDRC Dual DFI configuration
   ,input   logic [1:0]                                              dfi1_phymstr_type_in
   ,output  logic                                                    dfi1_phymstr_ack_out

   //-------------------------------------------
   // Write Data Interface
   //-------------------------------------------
   ,input   logic [DDRC_TOTAL_DATA_WIDTH-1:0]                        dfi_wrdata_dch0
   ,input   logic [DDRC_TOTAL_MASK_WIDTH-1:0]                        dfi_wrdata_mask_dch0
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH-1:0]                      dfi_wrdata_en_dch0

   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi0_wrdata_P0_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi0_wrdata_P1_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi0_wrdata_P2_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi0_wrdata_P3_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi0_wrdata_mask_P0_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi0_wrdata_mask_P1_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi0_wrdata_mask_P2_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi0_wrdata_mask_P3_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_wrdata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_wrdata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_wrdata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_wrdata_en_P3_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_wrdata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_wrdata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_wrdata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_wrdata_cs_P3_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi1_wrdata_P0_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi1_wrdata_P1_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi1_wrdata_P2_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                               dfi1_wrdata_P3_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi1_wrdata_mask_P0_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi1_wrdata_mask_P1_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi1_wrdata_mask_P2_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                               dfi1_wrdata_mask_P3_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_wrdata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_wrdata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_wrdata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_wrdata_en_P3_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_wrdata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_wrdata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_wrdata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_wrdata_cs_P3_out

   //-------------------------------------------
   // Read Data Interface
   //-------------------------------------------
   ,output  logic [DDRC_TOTAL_DATA_WIDTH-1:0]                        dfi_rddata_dch0
   ,output  logic [(DDRC_TOTAL_DATA_WIDTH/8)-1:0]                    dfi_rddata_dbi_dch0
   ,output  logic [DDRC_TOTAL_DATAEN_WIDTH-1:0]                      dfi_rddata_valid_dch0
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH-1:0]                      dfi_rddata_en_dch0

   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi0_rddata_W0_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi0_rddata_W1_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi0_rddata_W2_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi0_rddata_W3_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi0_rddata_dbi_W0_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi0_rddata_dbi_W1_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi0_rddata_dbi_W2_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi0_rddata_dbi_W3_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_valid_W0_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_valid_W1_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_valid_W2_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_valid_W3_in
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi0_rddata_en_P3_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_rddata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_rddata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_rddata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI0_CS_WIDTH)-1:0]             dfi0_rddata_cs_P3_out
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi1_rddata_W0_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi1_rddata_W1_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi1_rddata_W2_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                               dfi1_rddata_W3_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi1_rddata_dbi_W0_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi1_rddata_dbi_W1_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi1_rddata_dbi_W2_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                           dfi1_rddata_dbi_W3_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_valid_W0_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_valid_W1_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_valid_W2_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_valid_W3_in
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                             dfi1_rddata_en_P3_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_rddata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_rddata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_rddata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*DFI1_CS_WIDTH)-1:0]             dfi1_rddata_cs_P3_out


);


   //---------------------------------------------------------------------------
   // Signal Declaration
   //---------------------------------------------------------------------------


   //---------------------------------------------------------------------------
   // Main Module
   //---------------------------------------------------------------------------
   //-------------------------------------------
   // Command path
   //-------------------------------------------
   dfi_ic_cp
    #(
       .NUM_RANKS                               (NUM_RANKS)
      ,.DFI0_CS_WIDTH                           (DFI0_CS_WIDTH)
      ,.DFI1_CS_WIDTH                           (DFI1_CS_WIDTH)
      ,.FREQ_RATIO                              (FREQ_RATIO)
      ,.LPDDR_DUAL_CHANNEL_EN                   (LPDDR_DUAL_CHANNEL_EN)
      ,.RESET_WIDTH                             (RESET_WIDTH)
      ,.NUM_CLKS                                (NUM_CLKS)
      ,.BANK_BITS                               (BANK_BITS)
      ,.BG_BITS                                 (BG_BITS)
      ,.CID_WIDTH                               (CID_WIDTH)
      ,.DFI_DATA_WIDTH                          (DFI_DATA_WIDTH)
      ,.DFI_ADDR_WIDTH                          (DFI_ADDR_WIDTH)
      ,.DFI_BG_WIDTH                            (DFI_BG_WIDTH)
      ,.DFI_CID_WIDTH                           (DFI_CID_WIDTH)
      ,.DFI_LP_WAKEUP_WIDTH                     (DFI_LP_WAKEUP_WIDTH)
      ,.DFI_PARITY_IN_WIDTH                     (DFI_PARITY_IN_WIDTH)
      ,.REG_DFI_OUT_VAL                         (REG_DFI_OUT_VAL)
      ,.OCCAP_EN                                (OCCAP_EN)
      ,.OCCAP_PIPELINE_EN                       (OCCAP_PIPELINE_EN)
      ,.BCM_VERIF_EN                            (BCM_VERIF_EN)
      ,.BCM_DDRC_N_SYNC                         (BCM_DDRC_N_SYNC)
   )
   U_cp (
       .cp_dfiif_dch0                           (cp_dfiif_dch0)
      ,.dfi_wck_cs_dch0                         (dfi_wck_cs_dch0)
      ,.dfi_wck_en_dch0                         (dfi_wck_en_dch0)
      ,.dfi_wck_toggle_dch0                     (dfi_wck_toggle_dch0)
      ,.core_ddrc_core_clk                      (core_ddrc_core_clk)
      ,.core_ddrc_rstn                          (core_ddrc_rstn)
      ,.dfi_reset_n_out                         (dfi_reset_n_out)
      ,.dfi0_init_start_out                     (dfi0_init_start_out)
      ,.dfi0_freq_fsp_out                       (dfi0_freq_fsp_out)
      ,.dfi0_frequency_out                      (dfi0_frequency_out)
      ,.dfi0_freq_ratio_out                     (dfi0_freq_ratio_out)
      ,.dfi0_init_complete_in                   (dfi0_init_complete_in)
      ,.dfi0_address_P0_out                     (dfi0_address_P0_out)
      ,.dfi0_address_P1_out                     (dfi0_address_P1_out)
      ,.dfi0_address_P2_out                     (dfi0_address_P2_out)
      ,.dfi0_address_P3_out                     (dfi0_address_P3_out)
      ,.dfi0_cke_P0_out                         (dfi0_cke_P0_out)
      ,.dfi0_cke_P1_out                         (dfi0_cke_P1_out)
      ,.dfi0_cke_P2_out                         (dfi0_cke_P2_out)
      ,.dfi0_cke_P3_out                         (dfi0_cke_P3_out)
      ,.dfi0_cs_P0_out                          (dfi0_cs_P0_out)
      ,.dfi0_cs_P1_out                          (dfi0_cs_P1_out)
      ,.dfi0_cs_P2_out                          (dfi0_cs_P2_out)
      ,.dfi0_cs_P3_out                          (dfi0_cs_P3_out)
      ,.dfi0_dram_clk_disable_P0_out            (dfi0_dram_clk_disable_P0_out)
      ,.dfi0_dram_clk_disable_P1_out            (dfi0_dram_clk_disable_P1_out)
      ,.dfi0_dram_clk_disable_P2_out            (dfi0_dram_clk_disable_P2_out)
      ,.dfi0_dram_clk_disable_P3_out            (dfi0_dram_clk_disable_P3_out)
      ,.dfi0_lp_ctrl_req_out                    (dfi0_lp_ctrl_req_out)
      ,.dfi0_lp_ctrl_wakeup_out                 (dfi0_lp_ctrl_wakeup_out)
      ,.dfi0_lp_ctrl_ack_in                     (dfi0_lp_ctrl_ack_in)
      ,.dfi0_lp_data_req_out                    (dfi0_lp_data_req_out)
      ,.dfi0_lp_data_wakeup_out                 (dfi0_lp_data_wakeup_out)
      ,.dfi0_lp_data_ack_in                     (dfi0_lp_data_ack_in)
      ,.dfi0_ctrlupd_req_out                    (dfi0_ctrlupd_req_out)
      ,.dfi0_ctrlupd_ack_in                     (dfi0_ctrlupd_ack_in)
      ,.dfi0_phyupd_req_in                      (dfi0_phyupd_req_in)
      ,.dfi0_phyupd_type_in                     (dfi0_phyupd_type_in)
      ,.dfi0_phyupd_ack_out                     (dfi0_phyupd_ack_out)
      ,.dfi0_ctrlmsg_req_out                    (dfi0_ctrlmsg_req_out)
      ,.dfi0_ctrlmsg_out                        (dfi0_ctrlmsg_out)
      ,.dfi0_ctrlmsg_data_out                   (dfi0_ctrlmsg_data_out)
      ,.dfi0_ctrlmsg_ack_in                     (dfi0_ctrlmsg_ack_in)
      ,.dfi0_phymstr_req_in                     (dfi0_phymstr_req_in)
      ,.dfi0_phymstr_cs_state_in                (dfi0_phymstr_cs_state_in)
      ,.dfi0_phymstr_state_sel_in               (dfi0_phymstr_state_sel_in)
      ,.dfi0_phymstr_type_in                    (dfi0_phymstr_type_in)
      ,.dfi0_phymstr_ack_out                    (dfi0_phymstr_ack_out)
      ,.dfi0_wck_cs_P0_out                      (dfi0_wck_cs_P0_out)
      ,.dfi0_wck_cs_P1_out                      (dfi0_wck_cs_P1_out)
      ,.dfi0_wck_cs_P2_out                      (dfi0_wck_cs_P2_out)
      ,.dfi0_wck_cs_P3_out                      (dfi0_wck_cs_P3_out)
      ,.dfi0_wck_en_P0_out                      (dfi0_wck_en_P0_out)
      ,.dfi0_wck_en_P1_out                      (dfi0_wck_en_P1_out)
      ,.dfi0_wck_en_P2_out                      (dfi0_wck_en_P2_out)
      ,.dfi0_wck_en_P3_out                      (dfi0_wck_en_P3_out)
      ,.dfi0_wck_toggle_P0_out                  (dfi0_wck_toggle_P0_out)
      ,.dfi0_wck_toggle_P1_out                  (dfi0_wck_toggle_P1_out)
      ,.dfi0_wck_toggle_P2_out                  (dfi0_wck_toggle_P2_out)
      ,.dfi0_wck_toggle_P3_out                  (dfi0_wck_toggle_P3_out)
      ,.dfi1_init_start_out                     (dfi1_init_start_out)
      ,.dfi1_frequency_out                      (dfi1_frequency_out)
      ,.dfi1_freq_ratio_out                     (dfi1_freq_ratio_out)
      ,.dfi1_init_complete_in                   (dfi1_init_complete_in)
      ,.dfi1_freq_fsp_out                       (dfi1_freq_fsp_out)
      ,.dfi1_address_P0_out                     (dfi1_address_P0_out)
      ,.dfi1_address_P1_out                     (dfi1_address_P1_out)
      ,.dfi1_address_P2_out                     (dfi1_address_P2_out)
      ,.dfi1_address_P3_out                     (dfi1_address_P3_out)
      ,.dfi1_cke_P0_out                         (dfi1_cke_P0_out)
      ,.dfi1_cke_P1_out                         (dfi1_cke_P1_out)
      ,.dfi1_cke_P2_out                         (dfi1_cke_P2_out)
      ,.dfi1_cke_P3_out                         (dfi1_cke_P3_out)
      ,.dfi1_cs_P0_out                          (dfi1_cs_P0_out)
      ,.dfi1_cs_P1_out                          (dfi1_cs_P1_out)
      ,.dfi1_cs_P2_out                          (dfi1_cs_P2_out)
      ,.dfi1_cs_P3_out                          (dfi1_cs_P3_out)
      ,.dfi1_dram_clk_disable_P0_out            (dfi1_dram_clk_disable_P0_out)
      ,.dfi1_dram_clk_disable_P1_out            (dfi1_dram_clk_disable_P1_out)
      ,.dfi1_dram_clk_disable_P2_out            (dfi1_dram_clk_disable_P2_out)
      ,.dfi1_dram_clk_disable_P3_out            (dfi1_dram_clk_disable_P3_out)
      ,.dfi1_lp_ctrl_req_out                    (dfi1_lp_ctrl_req_out)
      ,.dfi1_lp_ctrl_wakeup_out                 (dfi1_lp_ctrl_wakeup_out)
      ,.dfi1_lp_ctrl_ack_in                     (dfi1_lp_ctrl_ack_in)
      ,.dfi1_lp_data_req_out                    (dfi1_lp_data_req_out)
      ,.dfi1_lp_data_wakeup_out                 (dfi1_lp_data_wakeup_out)
      ,.dfi1_lp_data_ack_in                     (dfi1_lp_data_ack_in)
      ,.dfi1_ctrlupd_req_out                    (dfi1_ctrlupd_req_out)
      ,.dfi1_ctrlupd_ack_in                     (dfi1_ctrlupd_ack_in)
      ,.dfi1_phyupd_req_in                      (dfi1_phyupd_req_in)
      ,.dfi1_phyupd_type_in                     (dfi1_phyupd_type_in)
      ,.dfi1_phyupd_ack_out                     (dfi1_phyupd_ack_out)
      ,.dfi1_ctrlmsg_req_out                    (dfi1_ctrlmsg_req_out)
      ,.dfi1_ctrlmsg_out                        (dfi1_ctrlmsg_out)
      ,.dfi1_ctrlmsg_data_out                   (dfi1_ctrlmsg_data_out)
      ,.dfi1_ctrlmsg_ack_in                     (dfi1_ctrlmsg_ack_in)
      ,.dfi1_phymstr_req_in                     (dfi1_phymstr_req_in)
      ,.dfi1_phymstr_cs_state_in                (dfi1_phymstr_cs_state_in)
      ,.dfi1_phymstr_state_sel_in               (dfi1_phymstr_state_sel_in)
      ,.dfi1_phymstr_type_in                    (dfi1_phymstr_type_in)
      ,.dfi1_phymstr_ack_out                    (dfi1_phymstr_ack_out)
      ,.dfi1_wck_cs_P0_out                      (dfi1_wck_cs_P0_out)
      ,.dfi1_wck_cs_P1_out                      (dfi1_wck_cs_P1_out)
      ,.dfi1_wck_cs_P2_out                      (dfi1_wck_cs_P2_out)
      ,.dfi1_wck_cs_P3_out                      (dfi1_wck_cs_P3_out)
      ,.dfi1_wck_en_P0_out                      (dfi1_wck_en_P0_out)
      ,.dfi1_wck_en_P1_out                      (dfi1_wck_en_P1_out)
      ,.dfi1_wck_en_P2_out                      (dfi1_wck_en_P2_out)
      ,.dfi1_wck_en_P3_out                      (dfi1_wck_en_P3_out)
      ,.dfi1_wck_toggle_P0_out                  (dfi1_wck_toggle_P0_out)
      ,.dfi1_wck_toggle_P1_out                  (dfi1_wck_toggle_P1_out)
      ,.dfi1_wck_toggle_P2_out                  (dfi1_wck_toggle_P2_out)
      ,.dfi1_wck_toggle_P3_out                  (dfi1_wck_toggle_P3_out)
   ); // dfi_ic_cp


   //-------------------------------------------
   // Data path
   //-------------------------------------------
   dfi_ic_dp_lpddr
    #(
       .NUM_RANKS                               (NUM_RANKS)
      ,.FREQ_RATIO                              (FREQ_RATIO)
      ,.DDRC_TOTAL_DATA_WIDTH                   (DDRC_TOTAL_DATA_WIDTH)
      ,.DDRC_TOTAL_DATAEN_WIDTH                 (DDRC_TOTAL_DATAEN_WIDTH)
      ,.DDRC_TOTAL_MASK_WIDTH                   (DDRC_TOTAL_MASK_WIDTH)
      ,.DRAM_TOTAL_DATA_WIDTH                   (DRAM_TOTAL_DATA_WIDTH)
      ,.NUM_DFI                                 (NUM_DFI)
      ,.DFI_DATA_WIDTH                          (DFI_DATA_WIDTH)
      ,.DFI_MASK_WIDTH                          (DFI_MASK_WIDTH)
      ,.DFI_DATAEN_WIDTH                        (DFI_DATAEN_WIDTH)
      ,.REG_DFI_OUT_VAL                         (REG_DFI_OUT_VAL)
      ,.OCCAP_EN                                (OCCAP_EN)
      ,.OCCAP_PIPELINE_EN                       (OCCAP_PIPELINE_EN)
   )
   U_dp (
       .reg_ddrc_dfi_channel_mode               (reg_ddrc_dfi_channel_mode)
      ,.core_ddrc_core_clk                      (core_ddrc_core_clk)
      ,.core_ddrc_rstn                          (core_ddrc_rstn)
      ,.dfi_wrdata_dch0                         (dfi_wrdata_dch0)
      ,.dfi_wrdata_mask_dch0                    (dfi_wrdata_mask_dch0)
      ,.dfi_wrdata_en_dch0                      (dfi_wrdata_en_dch0)
      ,.dfi_wrdata_cs_dch0                      (cp_dfiif_dch0.dfi_wrdata_cs)
      ,.dfi_rddata_dch0                         (dfi_rddata_dch0)
      ,.dfi_rddata_dbi_dch0                     (dfi_rddata_dbi_dch0)
      ,.dfi_rddata_valid_dch0                   (dfi_rddata_valid_dch0)
      ,.dfi_rddata_en_dch0                      (dfi_rddata_en_dch0)
      ,.dfi_rddata_cs_dch0                      (cp_dfiif_dch0.dfi_rddata_cs)
      ,.dwc_ddrphy_snoop_en_dch0                (dwc_ddrphy_snoop_en_dch0)
      ,.dfi0_wrdata_P0_out                      (dfi0_wrdata_P0_out)
      ,.dfi0_wrdata_P1_out                      (dfi0_wrdata_P1_out)
      ,.dfi0_wrdata_P2_out                      (dfi0_wrdata_P2_out)
      ,.dfi0_wrdata_P3_out                      (dfi0_wrdata_P3_out)
      ,.dfi0_wrdata_mask_P0_out                 (dfi0_wrdata_mask_P0_out)
      ,.dfi0_wrdata_mask_P1_out                 (dfi0_wrdata_mask_P1_out)
      ,.dfi0_wrdata_mask_P2_out                 (dfi0_wrdata_mask_P2_out)
      ,.dfi0_wrdata_mask_P3_out                 (dfi0_wrdata_mask_P3_out)
      ,.dfi0_wrdata_en_P0_out                   (dfi0_wrdata_en_P0_out)
      ,.dfi0_wrdata_en_P1_out                   (dfi0_wrdata_en_P1_out)
      ,.dfi0_wrdata_en_P2_out                   (dfi0_wrdata_en_P2_out)
      ,.dfi0_wrdata_en_P3_out                   (dfi0_wrdata_en_P3_out)
      ,.dfi0_wrdata_cs_P0_out                   (dfi0_wrdata_cs_P0_out)
      ,.dfi0_wrdata_cs_P1_out                   (dfi0_wrdata_cs_P1_out)
      ,.dfi0_wrdata_cs_P2_out                   (dfi0_wrdata_cs_P2_out)
      ,.dfi0_wrdata_cs_P3_out                   (dfi0_wrdata_cs_P3_out)
      ,.dfi0_rddata_W0_in                       (dfi0_rddata_W0_in)
      ,.dfi0_rddata_W1_in                       (dfi0_rddata_W1_in)
      ,.dfi0_rddata_W2_in                       (dfi0_rddata_W2_in)
      ,.dfi0_rddata_W3_in                       (dfi0_rddata_W3_in)
      ,.dfi0_rddata_dbi_W0_in                   (dfi0_rddata_dbi_W0_in)
      ,.dfi0_rddata_dbi_W1_in                   (dfi0_rddata_dbi_W1_in)
      ,.dfi0_rddata_dbi_W2_in                   (dfi0_rddata_dbi_W2_in)
      ,.dfi0_rddata_dbi_W3_in                   (dfi0_rddata_dbi_W3_in)
      ,.dfi0_rddata_valid_W0_in                 (dfi0_rddata_valid_W0_in)
      ,.dfi0_rddata_valid_W1_in                 (dfi0_rddata_valid_W1_in)
      ,.dfi0_rddata_valid_W2_in                 (dfi0_rddata_valid_W2_in)
      ,.dfi0_rddata_valid_W3_in                 (dfi0_rddata_valid_W3_in)
      ,.dfi0_rddata_en_P0_out                   (dfi0_rddata_en_P0_out)
      ,.dfi0_rddata_en_P1_out                   (dfi0_rddata_en_P1_out)
      ,.dfi0_rddata_en_P2_out                   (dfi0_rddata_en_P2_out)
      ,.dfi0_rddata_en_P3_out                   (dfi0_rddata_en_P3_out)
      ,.dfi0_rddata_cs_P0_out                   (dfi0_rddata_cs_P0_out)
      ,.dfi0_rddata_cs_P1_out                   (dfi0_rddata_cs_P1_out)
      ,.dfi0_rddata_cs_P2_out                   (dfi0_rddata_cs_P2_out)
      ,.dfi0_rddata_cs_P3_out                   (dfi0_rddata_cs_P3_out)
      ,.dwc_ddrphy0_snoop_en_P0_out             (dwc_ddrphy0_snoop_en_P0_out)
      ,.dwc_ddrphy0_snoop_en_P1_out             (dwc_ddrphy0_snoop_en_P1_out)
      ,.dwc_ddrphy0_snoop_en_P2_out             (dwc_ddrphy0_snoop_en_P2_out)
      ,.dwc_ddrphy0_snoop_en_P3_out             (dwc_ddrphy0_snoop_en_P3_out)
      ,.dfi1_wrdata_P0_out                      (dfi1_wrdata_P0_out)
      ,.dfi1_wrdata_P1_out                      (dfi1_wrdata_P1_out)
      ,.dfi1_wrdata_P2_out                      (dfi1_wrdata_P2_out)
      ,.dfi1_wrdata_P3_out                      (dfi1_wrdata_P3_out)
      ,.dfi1_wrdata_mask_P0_out                 (dfi1_wrdata_mask_P0_out)
      ,.dfi1_wrdata_mask_P1_out                 (dfi1_wrdata_mask_P1_out)
      ,.dfi1_wrdata_mask_P2_out                 (dfi1_wrdata_mask_P2_out)
      ,.dfi1_wrdata_mask_P3_out                 (dfi1_wrdata_mask_P3_out)
      ,.dfi1_wrdata_en_P0_out                   (dfi1_wrdata_en_P0_out)
      ,.dfi1_wrdata_en_P1_out                   (dfi1_wrdata_en_P1_out)
      ,.dfi1_wrdata_en_P2_out                   (dfi1_wrdata_en_P2_out)
      ,.dfi1_wrdata_en_P3_out                   (dfi1_wrdata_en_P3_out)
      ,.dfi1_wrdata_cs_P0_out                   (dfi1_wrdata_cs_P0_out)
      ,.dfi1_wrdata_cs_P1_out                   (dfi1_wrdata_cs_P1_out)
      ,.dfi1_wrdata_cs_P2_out                   (dfi1_wrdata_cs_P2_out)
      ,.dfi1_wrdata_cs_P3_out                   (dfi1_wrdata_cs_P3_out)
      ,.dfi1_rddata_W0_in                       (dfi1_rddata_W0_in)
      ,.dfi1_rddata_W1_in                       (dfi1_rddata_W1_in)
      ,.dfi1_rddata_W2_in                       (dfi1_rddata_W2_in)
      ,.dfi1_rddata_W3_in                       (dfi1_rddata_W3_in)
      ,.dfi1_rddata_dbi_W0_in                   (dfi1_rddata_dbi_W0_in)
      ,.dfi1_rddata_dbi_W1_in                   (dfi1_rddata_dbi_W1_in)
      ,.dfi1_rddata_dbi_W2_in                   (dfi1_rddata_dbi_W2_in)
      ,.dfi1_rddata_dbi_W3_in                   (dfi1_rddata_dbi_W3_in)
      ,.dfi1_rddata_valid_W0_in                 (dfi1_rddata_valid_W0_in)
      ,.dfi1_rddata_valid_W1_in                 (dfi1_rddata_valid_W1_in)
      ,.dfi1_rddata_valid_W2_in                 (dfi1_rddata_valid_W2_in)
      ,.dfi1_rddata_valid_W3_in                 (dfi1_rddata_valid_W3_in)
      ,.dfi1_rddata_en_P0_out                   (dfi1_rddata_en_P0_out)
      ,.dfi1_rddata_en_P1_out                   (dfi1_rddata_en_P1_out)
      ,.dfi1_rddata_en_P2_out                   (dfi1_rddata_en_P2_out)
      ,.dfi1_rddata_en_P3_out                   (dfi1_rddata_en_P3_out)
      ,.dfi1_rddata_cs_P0_out                   (dfi1_rddata_cs_P0_out)
      ,.dfi1_rddata_cs_P1_out                   (dfi1_rddata_cs_P1_out)
      ,.dfi1_rddata_cs_P2_out                   (dfi1_rddata_cs_P2_out)
      ,.dfi1_rddata_cs_P3_out                   (dfi1_rddata_cs_P3_out)
      ,.dwc_ddrphy1_snoop_en_P0_out             (dwc_ddrphy1_snoop_en_P0_out)
      ,.dwc_ddrphy1_snoop_en_P1_out             (dwc_ddrphy1_snoop_en_P1_out)
      ,.dwc_ddrphy1_snoop_en_P2_out             (dwc_ddrphy1_snoop_en_P2_out)
      ,.dwc_ddrphy1_snoop_en_P3_out             (dwc_ddrphy1_snoop_en_P3_out)
   ); // dfi_ic_dp_lpddr



endmodule // dfi_ic
