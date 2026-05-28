//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/DWC_ddrctl.sv#12 $
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

//==============================================================================
// Start License Usage
//==============================================================================
// Key Used   : DWC-DDRCTL                 (IP access)
// Key Used   : DWC-LPDDR54-CONTROLLER     (Add-on feature access: DWC LPDDR5/4/4X Controller)
// Key NotUsed: DWC-DDR54-CONTROLLER       (Add-on feature access: DWC DDR5/4 Controller)
// Key NotUsed: DWC-AP-LPDDR54-CONTROLLER  (Add-on feature access: DWC AP LPDDR5/4/4X Controller)
// Key NotUsed: DWC-AP-DDR54-CONTROLLER    (Add-on feature access: DWC AP DDR5/4 Controller)
// Key NotUsed: DWC-LPDDR54-CONTROLLER-AFP (Add-on feature access: DWC LPDDR5/4/4X Controller AFP)
// Key NotUsed: DWC-DDR54-CONTROLLER-AFP   (Add-on feature access: DWC DDR5/4 Controller AFP)
//==============================================================================
// End License Usage
//==============================================================================


//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Decided to keep all "unused" variables. Some are used in TB, the others are kept for debugging purposes. All internal modules have inline waivers for each reported variable


`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"


// VCS case 8001227322: Need to add SV interfaces to top level in order to be picked up by VCS when the definition is in a library file
`include "top/dwc_ddrctl_ddrc_cpfcpe_if.svh"

`include "top/dwc_ddrctl_ddrc_cpedfi_if.svh"

`include "top/dwc_ddrctl_ddrc_cpfdp_if.svh"

`include "top/dwc_ddrctl_ddrc_cpedp_if.svh"



module DWC_ddrctl
import DWC_ddrctl_reg_pkg::*;
(
    core_ddrc_core_clk,
    core_ddrc_rstn,

// Clock removal for bsm
// assign bsm_clk = {`MEMC_NUM_RANKS{core_ddrc_core_clk}} & bsm_clk_en;
    bsm_clk,
    //Each bsm_clk can be removed only when this signal for corresponding rank is 0, to save power. Otherwise bsm_clk should be running as equivalent to core_ddrc_core_clk.
    bsm_clk_en,



    //-----------------------------------------------
    // AXI Interface
    //-----------------------------------------------
    // AXI Port 0 Global Signals
    //-----------------------------------------------
    aresetn_0,
    aclk_0,
    // AXI Port 0 Write Address Channel
    //-----------------------------------------------
    awid_0,
    awaddr_0,
    awlen_0,
    awsize_0,
    awburst_0,
    awlock_0,
    awcache_0,
    awprot_0,
    awvalid_0,
    awready_0,
    awqos_0,
    awurgent_0,
    awpoison_0,
    awpoison_intr_0,
    awregion_0,
    waq_wcount_0,
    waq_pop_0,
    waq_push_0,
    waq_split_0,
    awautopre_0,
    // AXI Port 0 Write Data Channel
    wdata_0,
    wstrb_0,
    wlast_0,
    wvalid_0,
    wready_0,
    // AXI Port 0 Write Response Channel
    //-----------------------------------------------
    bid_0,
    bresp_0,
    bvalid_0,
    bready_0,

    // AXI Port 0 Read Address Channel
    //-----------------------------------------------
    arid_0,
    araddr_0,
    arlen_0,
    arsize_0,
    arburst_0,
    arlock_0,
    arcache_0,
    arprot_0,
    arvalid_0,
    arready_0,
    arqos_0,
    arpoison_0,
    arpoison_intr_0,
    arregion_0,
    arurgent_0,
    raq_wcount_0,
    raq_pop_0,
    raq_push_0,
    raq_split_0,
    arautopre_0,
    // AXI Port 0 Read Data Channel
    //-----------------------------------------------
    rid_0,
    rdata_0,
    rresp_0,
    rlast_0,
    rvalid_0,
    rready_0,

















     csysreq_0,
    csysack_0,
    cactive_0,




    wdataram_din,
    wdataram_dout,
    wdataram_mask,
    wdataram_wr,
    wdataram_waddr,
    wdataram_re,
    wdataram_raddr,


     hif_mrr_data,
     hif_mrr_data_valid,

    csysreq_ddrc,
    csysack_ddrc,
    cactive_ddrc,
    stat_ddrc_reg_selfref_type,




     //ccx_tgl : ; lpr_credit_cnt[6]; ; DDRCTL doesn't use this bit when MEMC_NO_OF_ENTRY<=32 because we can allocate up to 32 entries into LPR CAM.
     lpr_credit_cnt,
     //ccx_tgl : ; hpr_credit_cnt[5]; ; DDRCTL doesn't use this bit when MEMC_NO_OF_ENTRY<=32 because we can allocate up to 31 entries into HPR CAM.
     //ccx_tgl : ; hpr_credit_cnt[6]; ; DDRCTL doesn't use this bit when MEMC_NO_OF_ENTRY<=64 and its current max is 64. In this case we can allocate up to 63 entries into HPR CAM.
     hpr_credit_cnt,
     //ccx_tgl : ; wr_credit_cnt[6]; ; DDRCTL doesn't use this bit when MEMC_NO_OF_ENTRY<=32 because we can allocate up to 32 entries into LPR CAM.
     wr_credit_cnt,

     //ccx_tgl : ; pa_rmask[1]; ; One bit of pa_rmask is not toggled out of 4 bits. Lack of stimulus.This should be covered however stimulus is lacking. Task to cover this item is captured at https://jira.internal.synopsys.com/browse/P80001562-170174
     pa_rmask,

     pa_wmask,





    //-------------------------------------------
    // Command Interface
    //-------------------------------------------
    dfi0_address_P0,

    dfi0_address_P1,

    dfi0_address_P2,

    dfi0_address_P3,

    dfi0_cke_P0,

    dfi0_cke_P1,

    //ccx_tgl : ; dfi0_cke_P2; ; DDRCTL doesn't care this signal. This signal is only applicable for DDR4, and freq_ratio is fixed to 1:2 when DDR4 is selected.
    dfi0_cke_P2,

    //ccx_tgl : ; dfi0_cke_P3; ; DDRCTL doesn't care this signal. This signal is only applicable for DDR4, and freq_ratio is fixed to 1:2 when DDR4 is selected.
    dfi0_cke_P3,

    dfi0_cs_P0,

    //ccx_tgl : ; dfi0_cs_P1; ; dfi0_cs_P1/P3 cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
    dfi0_cs_P1,

    dfi0_cs_P2,

    //ccx_tgl : ; dfi0_cs_P3; ; dfi0_cs_P1/P3 cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
    dfi0_cs_P3,

    dfi0_dram_clk_disable_P0,

    dfi0_dram_clk_disable_P1,

    dfi0_dram_clk_disable_P2,

    dfi0_dram_clk_disable_P3,

    dfi1_address_P0,

    dfi1_address_P1,

    dfi1_address_P2,

    dfi1_address_P3,

    dfi1_cke_P0,

    dfi1_cke_P1,

    dfi1_cke_P2,

    dfi1_cke_P3,

    dfi1_cs_P0,

    //ccx_tgl : ; dfi1_cs_P1; ; dfi0_cs_P1/P3 cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
    dfi1_cs_P1,

    dfi1_cs_P2,

    //ccx_tgl : ; dfi1_cs_P3; ; dfi0_cs_P1/P3 cannot be toggled in LPDDR4, and LPDDR5 uses P0 only (redundant)
    dfi1_cs_P3,

    dfi1_dram_clk_disable_P0,

    dfi1_dram_clk_disable_P1,

    dfi1_dram_clk_disable_P2,

    dfi1_dram_clk_disable_P3,

    dfi_reset_n,




    //-------------------------------------------
    // Write Data Interface
    //-------------------------------------------
    dfi0_wrdata_P0,

    dfi0_wrdata_P1,

    dfi0_wrdata_P2,

    dfi0_wrdata_P3,

    dfi0_wrdata_en_P0,

    dfi0_wrdata_en_P1,

    dfi0_wrdata_en_P2,

    dfi0_wrdata_en_P3,

    dfi0_wrdata_mask_P0,

    dfi0_wrdata_mask_P1,

    dfi0_wrdata_mask_P2,

    dfi0_wrdata_mask_P3,

    dfi0_wrdata_cs_P0,

    dfi0_wrdata_cs_P1,

    dfi0_wrdata_cs_P2,

    dfi0_wrdata_cs_P3,
    dfi1_wrdata_P0,

    dfi1_wrdata_P1,

    dfi1_wrdata_P2,

    dfi1_wrdata_P3,

    dfi1_wrdata_en_P0,

    dfi1_wrdata_en_P1,

    dfi1_wrdata_en_P2,

    dfi1_wrdata_en_P3,

    dfi1_wrdata_mask_P0,

    dfi1_wrdata_mask_P1,

    dfi1_wrdata_mask_P2,

    dfi1_wrdata_mask_P3,

    dfi1_wrdata_cs_P0,

    dfi1_wrdata_cs_P1,

    dfi1_wrdata_cs_P2,

    dfi1_wrdata_cs_P3,

    //-------------------------------------------
    // Read Data Interface
    //-------------------------------------------
    dfi0_rddata_W0,

    dfi0_rddata_W1,

    dfi0_rddata_W2,

    dfi0_rddata_W3,

    dfi0_rddata_cs_P0,

    dfi0_rddata_cs_P1,

    dfi0_rddata_cs_P2,

    dfi0_rddata_cs_P3,

    // - 1: The DRAM has inverted the data on this byte lane and that the DDRC should flip it back to get the correct data.
    // - 0: The DRAM has not inverted the data and DDRC should not invert it.
    dfi0_rddata_dbi_W0,

    dfi0_rddata_dbi_W1,

    dfi0_rddata_dbi_W2,

    dfi0_rddata_dbi_W3,

    dfi0_rddata_en_P0,

    dfi0_rddata_en_P1,

    dfi0_rddata_en_P2,

    dfi0_rddata_en_P3,

    dfi0_rddata_valid_W0,

    dfi0_rddata_valid_W1,

    dfi0_rddata_valid_W2,

    dfi0_rddata_valid_W3,
    dfi1_rddata_W0,

    dfi1_rddata_W1,

    dfi1_rddata_W2,

    dfi1_rddata_W3,

    dfi1_rddata_cs_P0,

    dfi1_rddata_cs_P1,

    dfi1_rddata_cs_P2,

    dfi1_rddata_cs_P3,

    dfi1_rddata_dbi_W0,

    dfi1_rddata_dbi_W1,

    dfi1_rddata_dbi_W2,

    dfi1_rddata_dbi_W3,

    dfi1_rddata_en_P0,

    dfi1_rddata_en_P1,

    dfi1_rddata_en_P2,

    dfi1_rddata_en_P3,

    dfi1_rddata_valid_W0,

    dfi1_rddata_valid_W1,

    dfi1_rddata_valid_W2,

    dfi1_rddata_valid_W3,

    //-------------------------------------------
    // Update Interface
    //-------------------------------------------
    dfi0_ctrlupd_req,

    dfi0_ctrlupd_ack,


    dfi0_phyupd_req,

    //ccx_tgl : ; dfi0_phyupd_type; ; Both DDR5/4 and LPDDR5/4/4X SNPS PHY only employ tphyupd_type0 (2'b00)
    dfi0_phyupd_type,

    dfi0_phyupd_ack,

    dfi1_ctrlupd_req,

    dfi1_ctrlupd_ack,


    dfi1_phyupd_req,

    //ccx_tgl : ; dfi1_phyupd_type; ; Both DDR5/4 and LPDDR5/4/4X SNPS PHY only employ tphyupd_type0 (2'b00)
    dfi1_phyupd_type,

    dfi1_phyupd_ack,


    //-------------------------------------------
    // Status Interface
    //-------------------------------------------
    dfi0_freq_ratio,

    dfi0_init_complete,

    dfi0_init_start,

    dfi0_frequency,

    //ccx_tgl : ; dfi0_freq_fsp[1]; ; DDRCTL only supports two FSPs, so dfin_freq_fsp[1] cannot be toggled.
    //ccx_tgl : ; dfi0_freq_fsp[0]; ; If UMCTL2_FREQUENCY_NUM=1 in Customer Config, SWFFC cannot be run, hence dfi*_freq_fsp doesn't change. If UMCTL2_FAST_FREQUENCY_CHANGE is not defined, this should be ignored.
    dfi0_freq_fsp,


    dfi1_freq_ratio,

    dfi1_init_complete,

    dfi1_init_start,

    dfi1_frequency,

    //ccx_tgl : ; dfi1_freq_fsp[1]; ; DDRCTL only supports two FSPs, so dfin_freq_fsp[1] cannot be toggled.
    //ccx_tgl : ; dfi1_freq_fsp[0]; ; If UMCTL2_FREQUENCY_NUM=1 in Customer Config, SWFFC cannot be run, hence dfi*_freq_fsp doesn't change. If UMCTL2_FAST_FREQUENCY_CHANGE is not defined, this should be ignored.
    dfi1_freq_fsp,



    //-------------------------------------------
    // PHY Master Interface
    //-------------------------------------------
    dfi0_phymstr_req,

    dfi0_phymstr_cs_state,

    dfi0_phymstr_state_sel,

    dfi0_phymstr_type,

    dfi0_phymstr_ack,

    dfi1_phymstr_req,

    //ccx_tgl : ; dfi1_phymstr_cs_state; ; dfi1_phymstr_cs_state is not used even in Single DDRC Dual DFI configuration, so this signal is tied to fixed value
    dfi1_phymstr_cs_state,

    //ccx_tgl : ; dfi1_phymstr_state_sel; ; dfi1_phymstr_state_sel is not used even in Single DDRC Dual DFI configuration, so this signal is tied to fixed value
    dfi1_phymstr_state_sel,

    //ccx_tgl : ; dfi1_phymstr_type; ; dfi1_phymstr_type is not used even in Single DDRC Dual DFI configuration, so this signal is tied to fixed value
    dfi1_phymstr_type,

    dfi1_phymstr_ack,


   //-------------------------------------------
   // Low Power Control Interface
   //-------------------------------------------
    dfi0_lp_ctrl_req,

    dfi0_lp_ctrl_ack,

    dfi0_lp_ctrl_wakeup,

    dfi0_lp_data_req,

    dfi0_lp_data_ack,

    //ccx_tgl : ; dfi0_lp_data_wakeup[4]; ; wakeup[4] can be ignored as the controller does not support non-SNPS PHY for now. See bug 12044.
    dfi0_lp_data_wakeup,

    dfi1_lp_ctrl_req,

    dfi1_lp_ctrl_ack,

    //ccx_tgl : ; dfi1_lp_ctrl_wakeup[4]; ; wakeup[4] can be ignored as the controller does not support non-SNPS PHY for now. See bug 12044.
    dfi1_lp_ctrl_wakeup,

    dfi1_lp_data_req,

    dfi1_lp_data_ack,

    //ccx_tgl : ; dfi1_lp_data_wakeup[4]; ; wakeup[4] can be ignored as the controller does not support non-SNPS PHY for now. See bug 12044.
    dfi1_lp_data_wakeup,


    //-------------------------------------------
    // MC to PHY Message Interface
    //-------------------------------------------
    dfi0_ctrlmsg_req,

    //ccx_tgl : ; dfi0_ctrlmsg[2]; ; Controller only supports Fixed value of 0x4,0x2,0x9,0xA
    //ccx_tgl : ; dfi0_ctrlmsg[7:4]; ; Controller only supports Fixed value of 0x4,0x2,0x9,0xA
    dfi0_ctrlmsg,

    dfi0_ctrlmsg_data,

    dfi0_ctrlmsg_ack,

    // ccx_tgl: ;dfi1_ctrlmsg_req; ; This DFI1* interface is not used and its present to comply with PHY
    dfi1_ctrlmsg_req,

    // ccx_tgl: ;dfi1_ctrlmsg; ; This DFI1* interface is not used and its present to comply with PHY
    dfi1_ctrlmsg,

    // ccx_tgl: ;dfi1_ctrlmsg_data; ; This DFI1* interface is not used and its present to comply with PHY
    dfi1_ctrlmsg_data,

    // ccx_tgl: ;dfi1_ctrlmsg_ack; ; This DFI1* interface is not used and its present to comply with PHY
    dfi1_ctrlmsg_ack,

    //-------------------------------------------
    // WCK Control Interface
    //-------------------------------------------
    dfi0_wck_cs_P0,

    dfi0_wck_cs_P1,

    dfi0_wck_cs_P2,

    dfi0_wck_cs_P3,

    dfi0_wck_en_P0,

    dfi0_wck_en_P1,

    dfi0_wck_en_P2,

    dfi0_wck_en_P3,

    dfi0_wck_toggle_P0,

    dfi0_wck_toggle_P1,

    dfi0_wck_toggle_P2,

    dfi0_wck_toggle_P3,
    dfi1_wck_cs_P0,

    dfi1_wck_cs_P1,

    dfi1_wck_cs_P2,

    dfi1_wck_cs_P3,

    dfi1_wck_en_P0,

    dfi1_wck_en_P1,

    dfi1_wck_en_P2,

    dfi1_wck_en_P3,

    dfi1_wck_toggle_P0,

    dfi1_wck_toggle_P1,

    dfi1_wck_toggle_P2,

    dfi1_wck_toggle_P3,

    //-------------------------------------------
    // Non-DFI DDRCTL PHY Sideband Interface
    //-------------------------------------------
    dwc_ddrphy0_snoop_en_P0,

    dwc_ddrphy0_snoop_en_P1,

    dwc_ddrphy0_snoop_en_P2,

    dwc_ddrphy0_snoop_en_P3,
    dwc_ddrphy1_snoop_en_P0,

    dwc_ddrphy1_snoop_en_P1,

    dwc_ddrphy1_snoop_en_P2,

    dwc_ddrphy1_snoop_en_P3,

   //-------------------------------------------
   // Non-DFI DDRCTL PHY Sideband Interface
   //-------------------------------------------
    dfi_reset_n_in,

    dfi_reset_n_ref,

    init_mr_done_in,

    //ccx_tgl : ; init_mr_done_out; 0->1 ; This is asserted when HW SDRAM initialization sequence is completed. LPDDR54 controller does not use this because LPDDR54 PHY performs the initialization.
    init_mr_done_out,

    scanmode,
    scan_resetn,
    pclk,
    presetn,
    paddr,
    pwdata,
    pwrite,
    psel,
    penable,
    pready,
    prdata,
    pslverr


    ,hif_refresh_req_bank

    ,derate_temp_limit_intr
    ,derate_temp_limit_intr_fault






    );
   //--------------------------------------------------------------------------
   // Parameters
   //--------------------------------------------------------------------------
   parameter HIF_ADDR_WIDTH = `MEMC_HIF_ADDR_WIDTH;
   parameter NPORTS = `UMCTL2_A_NPORTS; // Number of ports
   parameter INT_NPORTS = `UMCTL2_INT_NPORTS;
   parameter INT_NPORTS_DATA = `UMCTL2_INT_NPORTS_DATA;
   parameter UMCTL2_A_NPORTS_LG2 = `UMCTL2_A_NPORTS_LG2;
   parameter SINGLE_PORT = `UMCTL2_SINGLE_PORT;
   parameter PA_OPT_TYPE = `UMCTL2_PA_OPT_TYPE;
   parameter PAGEMATCH_EN = `UMCTL2_PAGEMATCH_EN;
   parameter UMCTL2_CG_EN = `UMCTL2_CG_EN;
   parameter UMCTL2_SEQ_BURST_MODE = `UMCTL2_SEQ_BURST_MODE;
   parameter UMCTL2_PHY_SPECIAL_IDLE = `UMCTL2_PHY_SPECIAL_IDLE;
   parameter MEMC_TAGBITS = `MEMC_TAGBITS;
   parameter MEMC_NO_OF_ENTRY = `MEMC_NO_OF_ENTRY;
   parameter MEMC_WDATA_PTR_BITS = `MEMC_WDATA_PTR_BITS;
   parameter MEMC_ECC_SUPPORT = `MEMC_ECC_SUPPORT;
   parameter MEMC_SIDEBAND_ECC = `MEMC_SIDEBAND_ECC_EN;
   parameter MEMC_INLINE_ECC = `MEMC_INLINE_ECC_EN;
   parameter UMCTL2_CMD_LEN_BITS = `UMCTL2_CMD_LEN_BITS;
   parameter WRDATA_CYCLES = `MEMC_WRDATA_CYCLES;
   parameter UMCTL2_XPI_USE_RMW = `UMCTL2_XPI_USE_RMW;
   parameter UMCTL2_M_BLW = `UMCTL2_M_BLW;
   parameter A_DW = `UMCTL2_A_DW;
   parameter [15:0] RAQ_TABLE   = `UMCTL2_RAQ_TABLE;
   parameter OCPAR_EN = `UMCTL2_OCPAR_EN;
   parameter OCECC_EN = `UMCTL2_OCECC_EN;
//spyglass disable_block W576
//SMD: Logical operator(||) used on a multibit(32) value: OCPAR_EN/OCECC_EN
//SJ: OCPAR_EN/OCECC_EN seen as multibit because it is a parameter. Operation using the logical operator evaluates its arguments as Boolean (zero = false, non-zero = true), so there is no issue here.
   parameter OCPAR_OR_OCECC_EN = (OCPAR_EN==1) || (OCECC_EN==1);
//spyglass enable_block W576

   parameter OCCAP_EN = `UMCTL2_OCCAP_EN;
   parameter OCCAP_PIPELINE_EN = `UMCTL2_OCCAP_PIPELINE_EN;
   parameter SHARED_AC = `UMCTL2_SHARED_AC_EN;
   parameter DATA_CHANNEL_INTERLEAVE = `UMCTL2_DATA_CHANNEL_INTERLEAVE_EN;
   parameter DDRCTL_HET_INTERLEAVE_EN = `DDRCTL_HET_INTERLEAVE;
   parameter DATA_CHANNEL_INTERLEAVE_NS_0 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0;
   parameter A_DW_INT_0 = `UMCTL2_A_DW_INT_0;
   parameter DATA_CHANNEL_INTERLEAVE_NS_1 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1;
   parameter A_DW_INT_1 = `UMCTL2_A_DW_INT_1;
   parameter DATA_CHANNEL_INTERLEAVE_NS_2 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2;
   parameter A_DW_INT_2 = `UMCTL2_A_DW_INT_2;
   parameter DATA_CHANNEL_INTERLEAVE_NS_3 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3;
   parameter A_DW_INT_3 = `UMCTL2_A_DW_INT_3;
   parameter DATA_CHANNEL_INTERLEAVE_NS_4 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4;
   parameter A_DW_INT_4 = `UMCTL2_A_DW_INT_4;
   parameter DATA_CHANNEL_INTERLEAVE_NS_5 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5;
   parameter A_DW_INT_5 = `UMCTL2_A_DW_INT_5;
   parameter DATA_CHANNEL_INTERLEAVE_NS_6 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6;
   parameter A_DW_INT_6 = `UMCTL2_A_DW_INT_6;
   parameter DATA_CHANNEL_INTERLEAVE_NS_7 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7;
   parameter A_DW_INT_7 = `UMCTL2_A_DW_INT_7;
   parameter DATA_CHANNEL_INTERLEAVE_NS_8 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8;
   parameter A_DW_INT_8 = `UMCTL2_A_DW_INT_8;
   parameter DATA_CHANNEL_INTERLEAVE_NS_9 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9;
   parameter A_DW_INT_9 = `UMCTL2_A_DW_INT_9;
   parameter DATA_CHANNEL_INTERLEAVE_NS_10 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10;
   parameter A_DW_INT_10 = `UMCTL2_A_DW_INT_10;
   parameter DATA_CHANNEL_INTERLEAVE_NS_11 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11;
   parameter A_DW_INT_11 = `UMCTL2_A_DW_INT_11;
   parameter DATA_CHANNEL_INTERLEAVE_NS_12 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12;
   parameter A_DW_INT_12 = `UMCTL2_A_DW_INT_12;
   parameter DATA_CHANNEL_INTERLEAVE_NS_13 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13;
   parameter A_DW_INT_13 = `UMCTL2_A_DW_INT_13;
   parameter DATA_CHANNEL_INTERLEAVE_NS_14 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14;
   parameter A_DW_INT_14 = `UMCTL2_A_DW_INT_14;
   parameter DATA_CHANNEL_INTERLEAVE_NS_15 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15;
   parameter A_DW_INT_15 = `UMCTL2_A_DW_INT_15;
   parameter OCPAR_SLICE_WIDTH = `UMCTL2_OCPAR_SLICE_WIDTH;
   parameter OCPAR_ADDR_LOG_LOW_WIDTH = `UMCTL2_OCPAR_ADDR_LOG_LOW_WIDTH;
   parameter OCPAR_ADDR_LOG_HIGH_WIDTH = `UMCTL2_OCPAR_ADDR_LOG_HIGH_WIDTH;
   parameter OCPAR_NUM_BYTES = 32 << `DDRCTL_MAX_XPI_PORT_DW_GTEQ_512;
   parameter OCPAR_NUM_BYTES_LG2 = `UMCTL2_DATARAM_PAR_DW_LG2;
   parameter [15:0] AP_ASYNC_TABLE = `UMCTL2_AP_ASYNC_TABLE;
   parameter HIF_RQOS_TW = `UMCTL2_XPI_RQOS_TW;
   parameter HIF_WQOS_TW = `UMCTL2_XPI_WQOS_TW;

   parameter NUM_TOTAL_BANKS = `MEMC_NUM_TOTAL_BANKS;

   parameter SBR_EN = `UMCTL2_SBR_EN;

   parameter REG_SCRUB_INTERVALW = `UMCTL2_REG_SCRUB_INTERVALW;

   parameter SBR_RMW_FIFO_DEPTH = `DDRCTL_SBR_RMW_FIFO_DEPTH;

   //-----------------------------------------------
   // AXI Parameters and Constants
   //-----------------------------------------------
   parameter AXI_IDW = `UMCTL2_A_IDW; // AXI a*id width
   parameter AXI_ADDRW = `UMCTL2_AXI_ADDRW; // AXI a*addr width
   parameter AXI_LENW = `UMCTL2_A_LENW; // AXI a*len width
   parameter AXI_USERW = `UMCTL2_AXI_USER_WIDTH_INT;
   parameter OCPAR_ADDR_PARITY_WIDTH = `UMCTL2_OCPAR_ADDR_PARITY_W;

   parameter   UMCTL2_EXCL_ACCESS = `UMCTL2_EXCL_ACCESS;
   parameter AXI_ADDR_BOUNDARY = `UMCTL2_AXI_ADDR_BOUNDARY;
   parameter XPI_RD_BEAT_INFOW = `UMCTL2_XPI_RD_BEAT_INFOW;

   parameter RRB_EXTRAM_0  = `UMCTL2_RRB_EXTRAM_0;

   parameter RRB_EXTRAM_REG_0  = `UMCTL2_RRB_EXTRAM_REG_0;
   parameter RRB_EXTRAM_1  = `UMCTL2_RRB_EXTRAM_1;

   parameter RRB_EXTRAM_REG_1  = `UMCTL2_RRB_EXTRAM_REG_1;
   parameter RRB_EXTRAM_2  = `UMCTL2_RRB_EXTRAM_2;

   parameter RRB_EXTRAM_REG_2  = `UMCTL2_RRB_EXTRAM_REG_2;
   parameter RRB_EXTRAM_3  = `UMCTL2_RRB_EXTRAM_3;

   parameter RRB_EXTRAM_REG_3  = `UMCTL2_RRB_EXTRAM_REG_3;
   parameter RRB_EXTRAM_4  = `UMCTL2_RRB_EXTRAM_4;

   parameter RRB_EXTRAM_REG_4  = `UMCTL2_RRB_EXTRAM_REG_4;
   parameter RRB_EXTRAM_5  = `UMCTL2_RRB_EXTRAM_5;

   parameter RRB_EXTRAM_REG_5  = `UMCTL2_RRB_EXTRAM_REG_5;
   parameter RRB_EXTRAM_6  = `UMCTL2_RRB_EXTRAM_6;

   parameter RRB_EXTRAM_REG_6  = `UMCTL2_RRB_EXTRAM_REG_6;
   parameter RRB_EXTRAM_7  = `UMCTL2_RRB_EXTRAM_7;

   parameter RRB_EXTRAM_REG_7  = `UMCTL2_RRB_EXTRAM_REG_7;
   parameter RRB_EXTRAM_8  = `UMCTL2_RRB_EXTRAM_8;

   parameter RRB_EXTRAM_REG_8  = `UMCTL2_RRB_EXTRAM_REG_8;
   parameter RRB_EXTRAM_9  = `UMCTL2_RRB_EXTRAM_9;

   parameter RRB_EXTRAM_REG_9  = `UMCTL2_RRB_EXTRAM_REG_9;
   parameter RRB_EXTRAM_10  = `UMCTL2_RRB_EXTRAM_10;

   parameter RRB_EXTRAM_REG_10  = `UMCTL2_RRB_EXTRAM_REG_10;
   parameter RRB_EXTRAM_11  = `UMCTL2_RRB_EXTRAM_11;

   parameter RRB_EXTRAM_REG_11  = `UMCTL2_RRB_EXTRAM_REG_11;
   parameter RRB_EXTRAM_12  = `UMCTL2_RRB_EXTRAM_12;

   parameter RRB_EXTRAM_REG_12  = `UMCTL2_RRB_EXTRAM_REG_12;
   parameter RRB_EXTRAM_13  = `UMCTL2_RRB_EXTRAM_13;

   parameter RRB_EXTRAM_REG_13  = `UMCTL2_RRB_EXTRAM_REG_13;
   parameter RRB_EXTRAM_14  = `UMCTL2_RRB_EXTRAM_14;

   parameter RRB_EXTRAM_REG_14  = `UMCTL2_RRB_EXTRAM_REG_14;
   parameter RRB_EXTRAM_15  = `UMCTL2_RRB_EXTRAM_15;

   parameter RRB_EXTRAM_REG_15  = `UMCTL2_RRB_EXTRAM_REG_15;

   parameter EXT_PORTPRIO = `UMCTL2_EXT_PORTPRIO;

   parameter RDWR_ORDERED_0  = `UMCTL2_RDWR_ORDERED_0;
   parameter RDWR_ORDERED_1  = `UMCTL2_RDWR_ORDERED_1;
   parameter RDWR_ORDERED_2  = `UMCTL2_RDWR_ORDERED_2;
   parameter RDWR_ORDERED_3  = `UMCTL2_RDWR_ORDERED_3;
   parameter RDWR_ORDERED_4  = `UMCTL2_RDWR_ORDERED_4;
   parameter RDWR_ORDERED_5  = `UMCTL2_RDWR_ORDERED_5;
   parameter RDWR_ORDERED_6  = `UMCTL2_RDWR_ORDERED_6;
   parameter RDWR_ORDERED_7  = `UMCTL2_RDWR_ORDERED_7;
   parameter RDWR_ORDERED_8  = `UMCTL2_RDWR_ORDERED_8;
   parameter RDWR_ORDERED_9  = `UMCTL2_RDWR_ORDERED_9;
   parameter RDWR_ORDERED_10  = `UMCTL2_RDWR_ORDERED_10;
   parameter RDWR_ORDERED_11  = `UMCTL2_RDWR_ORDERED_11;
   parameter RDWR_ORDERED_12  = `UMCTL2_RDWR_ORDERED_12;
   parameter RDWR_ORDERED_13  = `UMCTL2_RDWR_ORDERED_13;
   parameter RDWR_ORDERED_14  = `UMCTL2_RDWR_ORDERED_14;
   parameter RDWR_ORDERED_15  = `UMCTL2_RDWR_ORDERED_15;

   parameter RRB_THRESHOLD_EN_0  = `UMCTL2_RRB_THRESHOLD_EN_0;
   parameter RRB_THRESHOLD_EN_1  = `UMCTL2_RRB_THRESHOLD_EN_1;
   parameter RRB_THRESHOLD_EN_2  = `UMCTL2_RRB_THRESHOLD_EN_2;
   parameter RRB_THRESHOLD_EN_3  = `UMCTL2_RRB_THRESHOLD_EN_3;
   parameter RRB_THRESHOLD_EN_4  = `UMCTL2_RRB_THRESHOLD_EN_4;
   parameter RRB_THRESHOLD_EN_5  = `UMCTL2_RRB_THRESHOLD_EN_5;
   parameter RRB_THRESHOLD_EN_6  = `UMCTL2_RRB_THRESHOLD_EN_6;
   parameter RRB_THRESHOLD_EN_7  = `UMCTL2_RRB_THRESHOLD_EN_7;
   parameter RRB_THRESHOLD_EN_8  = `UMCTL2_RRB_THRESHOLD_EN_8;
   parameter RRB_THRESHOLD_EN_9  = `UMCTL2_RRB_THRESHOLD_EN_9;
   parameter RRB_THRESHOLD_EN_10  = `UMCTL2_RRB_THRESHOLD_EN_10;
   parameter RRB_THRESHOLD_EN_11  = `UMCTL2_RRB_THRESHOLD_EN_11;
   parameter RRB_THRESHOLD_EN_12  = `UMCTL2_RRB_THRESHOLD_EN_12;
   parameter RRB_THRESHOLD_EN_13  = `UMCTL2_RRB_THRESHOLD_EN_13;
   parameter RRB_THRESHOLD_EN_14  = `UMCTL2_RRB_THRESHOLD_EN_14;
   parameter RRB_THRESHOLD_EN_15  = `UMCTL2_RRB_THRESHOLD_EN_15;

   parameter A_SYNC_0  = `UMCTL2_A_SYNC_0;
   parameter A_SYNC_1  = `UMCTL2_A_SYNC_1;
   parameter A_SYNC_2  = `UMCTL2_A_SYNC_2;
   parameter A_SYNC_3  = `UMCTL2_A_SYNC_3;
   parameter A_SYNC_4  = `UMCTL2_A_SYNC_4;
   parameter A_SYNC_5  = `UMCTL2_A_SYNC_5;
   parameter A_SYNC_6  = `UMCTL2_A_SYNC_6;
   parameter A_SYNC_7  = `UMCTL2_A_SYNC_7;
   parameter A_SYNC_8  = `UMCTL2_A_SYNC_8;
   parameter A_SYNC_9  = `UMCTL2_A_SYNC_9;
   parameter A_SYNC_10  = `UMCTL2_A_SYNC_10;
   parameter A_SYNC_11  = `UMCTL2_A_SYNC_11;
   parameter A_SYNC_12  = `UMCTL2_A_SYNC_12;
   parameter A_SYNC_13  = `UMCTL2_A_SYNC_13;
   parameter A_SYNC_14  = `UMCTL2_A_SYNC_14;
   parameter A_SYNC_15  = `UMCTL2_A_SYNC_15;

   parameter UMCTL2_STATIC_VIR_CH_0  = `UMCTL2_STATIC_VIR_CH_0;
   parameter UMCTL2_STATIC_VIR_CH_1  = `UMCTL2_STATIC_VIR_CH_1;
   parameter UMCTL2_STATIC_VIR_CH_2  = `UMCTL2_STATIC_VIR_CH_2;
   parameter UMCTL2_STATIC_VIR_CH_3  = `UMCTL2_STATIC_VIR_CH_3;
   parameter UMCTL2_STATIC_VIR_CH_4  = `UMCTL2_STATIC_VIR_CH_4;
   parameter UMCTL2_STATIC_VIR_CH_5  = `UMCTL2_STATIC_VIR_CH_5;
   parameter UMCTL2_STATIC_VIR_CH_6  = `UMCTL2_STATIC_VIR_CH_6;
   parameter UMCTL2_STATIC_VIR_CH_7  = `UMCTL2_STATIC_VIR_CH_7;
   parameter UMCTL2_STATIC_VIR_CH_8  = `UMCTL2_STATIC_VIR_CH_8;
   parameter UMCTL2_STATIC_VIR_CH_9  = `UMCTL2_STATIC_VIR_CH_9;
   parameter UMCTL2_STATIC_VIR_CH_10  = `UMCTL2_STATIC_VIR_CH_10;
   parameter UMCTL2_STATIC_VIR_CH_11  = `UMCTL2_STATIC_VIR_CH_11;
   parameter UMCTL2_STATIC_VIR_CH_12  = `UMCTL2_STATIC_VIR_CH_12;
   parameter UMCTL2_STATIC_VIR_CH_13  = `UMCTL2_STATIC_VIR_CH_13;
   parameter UMCTL2_STATIC_VIR_CH_14  = `UMCTL2_STATIC_VIR_CH_14;
   parameter UMCTL2_STATIC_VIR_CH_15  = `UMCTL2_STATIC_VIR_CH_15;

  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_0 = `UMCTL2_READ_DATA_INTERLEAVE_EN_0;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_1 = `UMCTL2_READ_DATA_INTERLEAVE_EN_1;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_2 = `UMCTL2_READ_DATA_INTERLEAVE_EN_2;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_3 = `UMCTL2_READ_DATA_INTERLEAVE_EN_3;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_4 = `UMCTL2_READ_DATA_INTERLEAVE_EN_4;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_5 = `UMCTL2_READ_DATA_INTERLEAVE_EN_5;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_6 = `UMCTL2_READ_DATA_INTERLEAVE_EN_6;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_7 = `UMCTL2_READ_DATA_INTERLEAVE_EN_7;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_8 = `UMCTL2_READ_DATA_INTERLEAVE_EN_8;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_9 = `UMCTL2_READ_DATA_INTERLEAVE_EN_9;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_10 = `UMCTL2_READ_DATA_INTERLEAVE_EN_10;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_11 = `UMCTL2_READ_DATA_INTERLEAVE_EN_11;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_12 = `UMCTL2_READ_DATA_INTERLEAVE_EN_12;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_13 = `UMCTL2_READ_DATA_INTERLEAVE_EN_13;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_14 = `UMCTL2_READ_DATA_INTERLEAVE_EN_14;
  parameter UMCTL2_READ_DATA_INTERLEAVE_EN_15 = `UMCTL2_READ_DATA_INTERLEAVE_EN_15;

   parameter XPI_USE_RMWR_EN = `DDRCTL_XPI_USE_RMWR_EN;

   localparam A_STRBW = A_DW/8;
   localparam A_PARW  = (OCECC_EN == 1) ? 5*A_STRBW : A_STRBW;
   localparam A_STRBW_INT_0 = A_DW_INT_0/8;
   localparam A_STRBW_INT_1 = A_DW_INT_1/8;
   localparam A_STRBW_INT_2 = A_DW_INT_2/8;
   localparam A_STRBW_INT_3 = A_DW_INT_3/8;
   localparam A_STRBW_INT_4 = A_DW_INT_4/8;
   localparam A_STRBW_INT_5 = A_DW_INT_5/8;
   localparam A_STRBW_INT_6 = A_DW_INT_6/8;
   localparam A_STRBW_INT_7 = A_DW_INT_7/8;
   localparam A_STRBW_INT_8 = A_DW_INT_8/8;
   localparam A_STRBW_INT_9 = A_DW_INT_9/8;
   localparam A_STRBW_INT_10 = A_DW_INT_10/8;
   localparam A_STRBW_INT_11 = A_DW_INT_11/8;
   localparam A_STRBW_INT_12 = A_DW_INT_12/8;
   localparam A_STRBW_INT_13 = A_DW_INT_13/8;
   localparam A_STRBW_INT_14 = A_DW_INT_14/8;
   localparam A_STRBW_INT_15 = A_DW_INT_15/8;
   localparam A_PARW_INT_0 = (OCECC_EN == 1) ? 5*A_STRBW_INT_0 : A_STRBW_INT_0;
   localparam A_PARW_INT_1 = (OCECC_EN == 1) ? 5*A_STRBW_INT_1 : A_STRBW_INT_1;
   localparam A_PARW_INT_2 = (OCECC_EN == 1) ? 5*A_STRBW_INT_2 : A_STRBW_INT_2;
   localparam A_PARW_INT_3 = (OCECC_EN == 1) ? 5*A_STRBW_INT_3 : A_STRBW_INT_3;
   localparam A_PARW_INT_4 = (OCECC_EN == 1) ? 5*A_STRBW_INT_4 : A_STRBW_INT_4;
   localparam A_PARW_INT_5 = (OCECC_EN == 1) ? 5*A_STRBW_INT_5 : A_STRBW_INT_5;
   localparam A_PARW_INT_6 = (OCECC_EN == 1) ? 5*A_STRBW_INT_6 : A_STRBW_INT_6;
   localparam A_PARW_INT_7 = (OCECC_EN == 1) ? 5*A_STRBW_INT_7 : A_STRBW_INT_7;
   localparam A_PARW_INT_8 = (OCECC_EN == 1) ? 5*A_STRBW_INT_8 : A_STRBW_INT_8;
   localparam A_PARW_INT_9 = (OCECC_EN == 1) ? 5*A_STRBW_INT_9 : A_STRBW_INT_9;
   localparam A_PARW_INT_10 = (OCECC_EN == 1) ? 5*A_STRBW_INT_10 : A_STRBW_INT_10;
   localparam A_PARW_INT_11 = (OCECC_EN == 1) ? 5*A_STRBW_INT_11 : A_STRBW_INT_11;
   localparam A_PARW_INT_12 = (OCECC_EN == 1) ? 5*A_STRBW_INT_12 : A_STRBW_INT_12;
   localparam A_PARW_INT_13 = (OCECC_EN == 1) ? 5*A_STRBW_INT_13 : A_STRBW_INT_13;
   localparam A_PARW_INT_14 = (OCECC_EN == 1) ? 5*A_STRBW_INT_14 : A_STRBW_INT_14;
   localparam A_PARW_INT_15 = (OCECC_EN == 1) ? 5*A_STRBW_INT_15 : A_STRBW_INT_15;

   localparam OCECC_XPI_WR_IN_GRANU = 64;
   localparam OCECC_XPI_RD_GRANU  = 64;
   localparam OCECC_MR_RD_GRANU = 8;
   localparam OCECC_PNUM_WIDTH = 4;
   localparam OCECC_MR_BNUM_WIDTH = 5;
   localparam OCECC_MR_BINDEX_WIDTH = `MEMC_DFI_DATA_WIDTH/OCECC_MR_RD_GRANU;
   localparam OCECC_CORR_UNCORR_WIDTH = 2;

   localparam OCPAR_PNUM_WIDTH = 4; // `UMCTL2_REGS_SIZE_OCPARAWLOG1_PAR_WADDR_LOG_PORT_NUM when OCPAR is enabled

   localparam RRB_LOCK_THRESHOLD_WIDTH = 4;

   localparam AXI_SIZEW  = `UMCTL2_AXI_SIZE_WIDTH; // AXI a*size width
   localparam AXI_BURSTW = `UMCTL2_AXI_BURST_WIDTH; // AXI a*burst width
   localparam AXI_LOCKW  = `UMCTL2_AXI_LOCK_WIDTH; // AXI a*lock fixed width (2)
   localparam AXI_CACHEW = `UMCTL2_AXI_CACHE_WIDTH; // AXI a*cache width
   localparam AXI_PROTW  = `UMCTL2_AXI_PROT_WIDTH; // AXI a*prot width
   localparam AXI_RESPW  = `UMCTL2_AXI_RESP_WIDTH; // AXI *resp width
   localparam AXI_QOSW   = `UMCTL2_A_QOSW; // AXI a*qos width

   localparam AXI_SAR_BW      = `UMCTL2_AXI_SAR_BW;
   localparam AXI_SAR_SW      = `UMCTL2_AXI_SAR_SW;
   localparam SAR_MIN_ADDRW   = `UMCTL2_SAR_MIN_ADDRW;

   // -------------------------------------------------------------------------
   // Exclusive Access Additional signals
   // -------------------------------------------------------------------------
   localparam EXA_ACC_SUPPORT   = (UMCTL2_EXCL_ACCESS==0)? 0 : 1;

   // Worst Case Dowsnsizing is Data Width of 256/16 bits with a AXI_LENW of 8.
   // Maximum length is 8 + log2(256/16) = 12

 // `ifdef DDRCTL_UMCTL5
   localparam EXA_MAX_LENW      = `UMCTL2_A_LENW + `UMCTL_LOG2(`UMCTL2_MAX_AXI_DATAW/(`UMCTL2_A_DW/4)) + 1;
 // `else
   //localparam EXA_MAX_LENW      = `UMCTL2_A_LENW + `UMCTL_LOG2(`UMCTL2_MAX_AXI_DATAW/`UMCTL2_A_DW) + 1;
 // `endif
   localparam EXA_MAX_SIZEW     = `UMCTL2_AXI_SIZE_WIDTH;         // Maximum AXI Size is 3 bits
   localparam EXA_MAX_ADDRW     = AXI_ADDRW;
   localparam EXA_PYLD_W        = (EXA_ACC_SUPPORT==0)? 1 : EXA_MAX_ADDRW + EXA_MAX_LENW + EXA_MAX_SIZEW;
   localparam BCM_VERIF_EN    = 1;
   localparam OCPAR_INFOW     =`MEMC_DFI_ADDR_WIDTH +
                              `MEMC_PAGE_BITS +
                              `MEMC_BANK_BITS +
                              `MEMC_BG_BITS +
                              `UMCTL2_CID_WIDTH +
                              `MEMC_RANK_BITS;

   localparam OCPAR_ADDR_PARITY_WIDTH_MIN = (OCPAR_ADDR_PARITY_WIDTH==1) ? OCPAR_ADDR_PARITY_WIDTH :
                                                                        ((AXI_ADDRW%8>0) ? AXI_ADDRW/8+1 : AXI_ADDRW/8);


   localparam [15:0] A_SYNC_TABLE = `UMCTL2_A_SYNC_TABLE;
   localparam [16:0] NPORTS_MASK = {{(17-NPORTS){1'b1}},{NPORTS{1'b0}}}; //   localparam [16:0] NPORTS_MASK = 17'h1ffff << NPORTS;
   localparam [16:0] A_SYNC_TABLE_MASKED = {1'b1,A_SYNC_TABLE} | NPORTS_MASK; // need to take into account scrubber

   parameter APB_DW = `UMCTL2_APB_DW;
   parameter APB_AW = `UMCTL2_APB_AW;
   parameter P_ASYNC_EN = `UMCTL2_P_ASYNC_EN;
   parameter BCM_F_SYNC_TYPE_C2P = `UMCTL2_ASYNC_REG_N_SYNC;
   parameter BCM_F_SYNC_TYPE_P2C = `UMCTL2_ASYNC_REG_N_SYNC;
   parameter BCM_R_SYNC_TYPE_C2P = `UMCTL2_ASYNC_REG_N_SYNC;
   parameter BCM_R_SYNC_TYPE_P2C = `UMCTL2_ASYNC_REG_N_SYNC;
   parameter REG_OUTPUTS_C2P = `UMCTL2_BCM_REG_OUTPUTS_C2P;
   parameter REG_OUTPUTS_P2C = `UMCTL2_BCM_REG_OUTPUTS_P2C;
   parameter BCM_DDRC_N_SYNC = `UMCTL2_ASYNC_DDRC_N_SYNC;
   parameter BCM_LP4DCI_N_SYNC = `UMCTL2_ASYNC_LP4DCI_N_SYNC;
   parameter UMCTL2_WDATARAM_DW = `UMCTL2_WDATARAM_DW;
   parameter UMCTL2_WDATARAM_AW = `UMCTL2_WDATARAM_AW;
   parameter UMCTL2_WDATARAM_DEPTH = `UMCTL2_WDATARAM_DEPTH;
   parameter UMCTL2_RDATARAM_DW = `UMCTL2_RDATARAM_DW;
   parameter UMCTL2_RDATARAM_AW = `UMCTL2_RDATARAM_AW;
   parameter UMCTL2_RDATARAM_DEPTH = `UMCTL2_RDATARAM_DEPTH;
   parameter UMCTL2_DATARAM_PAR_DW = `UMCTL2_DATARAM_PAR_DW;
   parameter UMCTL2_WDATARAM_PAR_DW = `UMCTL2_WDATARAM_PAR_DW;
   parameter UMCTL2_WDATARAM_PAR_DW_EXT = `UMCTL2_WDATARAM_PAR_DW_EXT;
   parameter WDATA_PAR_WIDTH_EXT        = `UMCTL2_WDATARAM_PAR_DW_EXT;
   parameter RETRY_MAX_ADD_RD_LAT = `DDRCTL_RETRY_MAX_ADD_RD_LAT;
   parameter RETRY_MAX_ADD_RD_LAT_LG2 = `DDRCTL_RETRY_MAX_ADD_RD_LAT_LG2;

//-------------------------------------------------//
// Addrmap register parameters
//-------------------------------------------------//

   parameter AM_DCH_WIDTH   = 6;
   parameter AM_CS_WIDTH    = 6;
   parameter AM_CID_WIDTH   = 6;
   parameter AM_BANK_WIDTH  = 6;
   parameter AM_BG_WIDTH    = 6;
   parameter AM_ROW_WIDTH   = 5;
   parameter AM_COL_WIDTH_H = 5;
   parameter AM_COL_WIDTH_L = 4;


   localparam NUM_LANES = `MEMC_DFI_TOTAL_DATAEN_WIDTH/`MEMC_FREQ_RATIO;

   // To avoid coretool error (UMCTL2_CID_WIDTH is always non-zero value whenever UMCTL2_CID_EN is defined.)
   localparam CID_WIDTH = (`UMCTL2_CID_WIDTH!=0)? `UMCTL2_CID_WIDTH : 1;

   localparam XPI_RAQD_LG2_0 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_0);
   localparam XPI_WAQD_LG2_0 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_0);
   localparam XPI_RAQD_LG2_1 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_1);
   localparam XPI_WAQD_LG2_1 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_1);
   localparam XPI_RAQD_LG2_2 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_2);
   localparam XPI_WAQD_LG2_2 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_2);
   localparam XPI_RAQD_LG2_3 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_3);
   localparam XPI_WAQD_LG2_3 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_3);
   localparam XPI_RAQD_LG2_4 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_4);
   localparam XPI_WAQD_LG2_4 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_4);
   localparam XPI_RAQD_LG2_5 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_5);
   localparam XPI_WAQD_LG2_5 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_5);
   localparam XPI_RAQD_LG2_6 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_6);
   localparam XPI_WAQD_LG2_6 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_6);
   localparam XPI_RAQD_LG2_7 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_7);
   localparam XPI_WAQD_LG2_7 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_7);
   localparam XPI_RAQD_LG2_8 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_8);
   localparam XPI_WAQD_LG2_8 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_8);
   localparam XPI_RAQD_LG2_9 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_9);
   localparam XPI_WAQD_LG2_9 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_9);
   localparam XPI_RAQD_LG2_10 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_10);
   localparam XPI_WAQD_LG2_10 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_10);
   localparam XPI_RAQD_LG2_11 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_11);
   localparam XPI_WAQD_LG2_11 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_11);
   localparam XPI_RAQD_LG2_12 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_12);
   localparam XPI_WAQD_LG2_12 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_12);
   localparam XPI_RAQD_LG2_13 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_13);
   localparam XPI_WAQD_LG2_13 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_13);
   localparam XPI_RAQD_LG2_14 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_14);
   localparam XPI_WAQD_LG2_14 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_14);
   localparam XPI_RAQD_LG2_15 = `UMCTL_LOG2(`UMCTL2_AXI_RAQD_15);
   localparam XPI_WAQD_LG2_15 = `UMCTL_LOG2(`UMCTL2_AXI_WAQD_15);

   localparam  DUAL_CHANNEL = (`UMCTL2_SHARED_AC_EN==1 || `UMCTL2_DUAL_CHANNEL_EN==1)? 1 : 0;

   localparam HWFFC_EN = `UMCTL2_HWFFC_EN_VAL ? 1 : 0;
   // this param must exist in all configs because it is used in 'generate if' statement
   localparam ARB_HWFFC_EN = (`UMCTL2_HWFFC_EN_VAL==1 && `UMCTL_A_HIF==0) ? 1 : 0;


   localparam DDR4_DUAL_CHANNEL = (`UMCTL2_DUAL_CHANNEL_EN==1 && `DDRCTL_DDR_EN==1) ? 1 : 0;

   localparam IH_TE_PIPELINE = `MEMC_IH_TE_PIPELINE_EN;


   //------------------------------------------------------------------------------
   // Input and Output Declarations
   //------------------------------------------------------------------------------

   input                                core_ddrc_core_clk;
   input                                core_ddrc_rstn;

   input  [`MEMC_NUM_RANKS-1:0]         bsm_clk;
   output [`MEMC_NUM_RANKS-1:0]         bsm_clk_en;

   //-----------------------------------------------
   // AXI Interface
   //-----------------------------------------------
   // AXI Port 0 Global Signals (clock, reset, low-power)
   input                                aresetn_0;
   input                                aclk_0;
   // AXI Port 0 Write Address Channel
   input [`UMCTL2_A_IDW-1:0]            awid_0;
   input [`UMCTL2_A_ADDRW-1:0]          awaddr_0;
   input [`UMCTL2_A_LENW-1:0]           awlen_0;
   input [2:0]                          awsize_0;
   input [1:0]                          awburst_0;
   input [`UMCTL2_AXI_LOCK_WIDTH_0-1:0] awlock_0;
   input [3:0]                          awcache_0;
   input [2:0]                          awprot_0;
   input                                awvalid_0;
   output                               awready_0;
   input [3:0]                          awqos_0;
   input                                awurgent_0;
   input                                awpoison_0;
   output                               awpoison_intr_0;
   input                                awautopre_0;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Unused signal. Keeping it as it is part of the standard set of AXI signals.
   input [3:0]                          awregion_0;
 //spyglass enable_block W240

   // AXI Port 0 Write Data Channel
   input [`UMCTL2_PORT_DW_0-1:0]        wdata_0;
   input [`UMCTL2_PORT_NBYTES_0-1:0]    wstrb_0;
   input                                wlast_0;
   input                                wvalid_0;
   output                               wready_0;

   // AXI Port 0 Write Response Channel
   output [`UMCTL2_A_IDW-1:0]           bid_0;
   output [AXI_RESPW-1:0]               bresp_0;
   output                               bvalid_0;
   input                                bready_0;

   // AXI Port 0 Read Address Channel
   input [`UMCTL2_A_IDW-1:0]            arid_0;
   input [`UMCTL2_A_ADDRW-1:0]          araddr_0;
   input [`UMCTL2_A_LENW-1:0]           arlen_0;
   input [AXI_SIZEW-1:0]                arsize_0;
   input [AXI_BURSTW-1:0]               arburst_0;
   input [`UMCTL2_AXI_LOCK_WIDTH_0-1:0] arlock_0;
   input [AXI_CACHEW-1:0]               arcache_0;
   input [AXI_PROTW-1:0]                arprot_0;
   input                                arvalid_0;
   output                               arready_0;
   input [AXI_QOSW-1:0]                 arqos_0;
   input                                arpoison_0;
   output                               arpoison_intr_0;
   input                                arautopre_0;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Unused signal. Keeping it as it is part of the standard set of AXI signals.
   input [`UMCTL2_AXI_REGION_WIDTH-1:0] arregion_0;
//spyglass enable_block W240

   // AXI Port 0 Read Data Channel
   output [`UMCTL2_A_IDW-1:0]           rid_0;
   output [`UMCTL2_PORT_DW_0-1:0]       rdata_0;
   output [AXI_RESPW-1:0]               rresp_0;
   output                               rlast_0;
   output                               rvalid_0;
   input                                rready_0;

    input                               arurgent_0;
    output [XPI_RAQD_LG2_0:0]           raq_wcount_0;
    output                              raq_pop_0;
    output                              raq_push_0;
   output                               raq_split_0;

    output [XPI_WAQD_LG2_0:0]           waq_wcount_0;
    output                              waq_pop_0;
    output                              waq_push_0;
    output                              waq_split_0;


      input                               csysreq_0;
      output                              csysack_0;
      output                              cactive_0;



































   //-----------------------------------------------
   // External Write Data RAM Interface
   //-----------------------------------------------
   input [UMCTL2_WDATARAM_DW-1:0]      wdataram_dout;
   output [UMCTL2_WDATARAM_DW-1:0]     wdataram_din;
   output [UMCTL2_WDATARAM_DW/8-1:0]   wdataram_mask;
   output                              wdataram_wr;
   output                              wdataram_re;
   output [UMCTL2_WDATARAM_AW-1:0]     wdataram_raddr;
   output [UMCTL2_WDATARAM_AW-1:0]     wdataram_waddr;



   output [`MEMC_MRR_DATA_TOTAL_DATA_WIDTH-1:0]         hif_mrr_data;
   output                              hif_mrr_data_valid;

input                                csysreq_ddrc;
output                               csysack_ddrc;
output                               cactive_ddrc;

output [SELFREF_TYPE_WIDTH-1:0]      stat_ddrc_reg_selfref_type;






output [6:0]    lpr_credit_cnt;
output [6:0]    hpr_credit_cnt;
output [6:0]    wr_credit_cnt;


input [2*NPORTS-1:0] pa_rmask;
input [NPORTS-1:0]   pa_wmask;





   //-------------------------------------------
   // Command Interface
   //-------------------------------------------
   output [`UMCTL2_RESET_WIDTH-1:0]                                              dfi_reset_n;

   output [`MEMC_DFI_ADDR_WIDTH_P0-1:0]                                          dfi0_address_P0;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cke_P0;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cs_P0;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi0_dram_clk_disable_P0;

   output [`MEMC_DFI_ADDR_WIDTH_P0-1:0]                                          dfi1_address_P0;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cke_P0;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cs_P0;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi1_dram_clk_disable_P0;
   output [`MEMC_DFI_ADDR_WIDTH_P1-1:0]                                          dfi0_address_P1;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cke_P1;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cs_P1;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi0_dram_clk_disable_P1;

   output [`MEMC_DFI_ADDR_WIDTH_P1-1:0]                                          dfi1_address_P1;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cke_P1;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cs_P1;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi1_dram_clk_disable_P1;
   output [`MEMC_DFI_ADDR_WIDTH_P2-1:0]                                          dfi0_address_P2;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cke_P2;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cs_P2;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi0_dram_clk_disable_P2;

   output [`MEMC_DFI_ADDR_WIDTH_P2-1:0]                                          dfi1_address_P2;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cke_P2;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cs_P2;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi1_dram_clk_disable_P2;
   output [`MEMC_DFI_ADDR_WIDTH_P3-1:0]                                          dfi0_address_P3;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cke_P3;
   output [`DDRCTL_DFI0_CS_WIDTH-1:0]                                            dfi0_cs_P3;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi0_dram_clk_disable_P3;

   output [`MEMC_DFI_ADDR_WIDTH_P3-1:0]                                          dfi1_address_P3;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cke_P3;
   output [`DDRCTL_DFI1_CS_WIDTH-1:0]                                            dfi1_cs_P3;
   output [`MEMC_NUM_CLKS-1:0]                                                   dfi1_dram_clk_disable_P3;

   //-------------------------------------------
   // Write Data Interface
   //-------------------------------------------
   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_wrdata_P0;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi0_wrdata_mask_P0;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_wrdata_en_P0;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_wrdata_cs_P0;
   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_wrdata_P0;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi1_wrdata_mask_P0;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_wrdata_en_P0;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_wrdata_cs_P0;

   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_wrdata_P1;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi0_wrdata_mask_P1;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_wrdata_en_P1;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_wrdata_cs_P1;
   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_wrdata_P1;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi1_wrdata_mask_P1;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_wrdata_en_P1;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_wrdata_cs_P1;

   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_wrdata_P2;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi0_wrdata_mask_P2;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_wrdata_en_P2;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_wrdata_cs_P2;
   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_wrdata_P2;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi1_wrdata_mask_P2;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_wrdata_en_P2;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_wrdata_cs_P2;

   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_wrdata_P3;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi0_wrdata_mask_P3;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_wrdata_en_P3;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_wrdata_cs_P3;
   output [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_wrdata_P3;
   output [`DDRCTL_DFI_MASK_WIDTH-1:0]                                           dfi1_wrdata_mask_P3;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_wrdata_en_P3;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_wrdata_cs_P3;


   //-------------------------------------------
   // Read Data Interface
   //-------------------------------------------
   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_rddata_W0;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi0_rddata_dbi_W0;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_valid_W0;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_en_P0;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_rddata_cs_P0;
   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_rddata_W0;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi1_rddata_dbi_W0;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_valid_W0;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_en_P0;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_rddata_cs_P0;

   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_rddata_W1;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi0_rddata_dbi_W1;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_valid_W1;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_en_P1;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_rddata_cs_P1;
   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_rddata_W1;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi1_rddata_dbi_W1;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_valid_W1;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_en_P1;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_rddata_cs_P1;

   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_rddata_W2;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi0_rddata_dbi_W2;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_valid_W2;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_en_P2;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_rddata_cs_P2;
   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_rddata_W2;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi1_rddata_dbi_W2;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_valid_W2;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_en_P2;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_rddata_cs_P2;

   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi0_rddata_W3;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi0_rddata_dbi_W3;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_valid_W3;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi0_rddata_en_P3;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI0_CS_WIDTH)-1:0]                 dfi0_rddata_cs_P3;
   input  [`DDRCTL_DFI_DATA_WIDTH-1:0]                                           dfi1_rddata_W3;
   input  [(`DDRCTL_DFI_DATA_WIDTH/8)-1:0]                                       dfi1_rddata_dbi_W3;
   input  [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_valid_W3;
   output [`DDRCTL_DFI_DATAEN_WIDTH-1:0]                                         dfi1_rddata_en_P3;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*`DDRCTL_DFI1_CS_WIDTH)-1:0]                 dfi1_rddata_cs_P3;


   //-------------------------------------------
   // Update Interface
   //-------------------------------------------
   output                                                                        dfi0_ctrlupd_req;
   input                                                                         dfi0_ctrlupd_ack;
   input                                                                         dfi0_phyupd_req;
   input  [1:0]                                                                  dfi0_phyupd_type;
   output                                                                        dfi0_phyupd_ack;

   output                                                                        dfi1_ctrlupd_req;
   input                                                                         dfi1_ctrlupd_ack;
   input                                                                         dfi1_phyupd_req;
   input  [1:0]                                                                  dfi1_phyupd_type;
   output                                                                        dfi1_phyupd_ack;

   //-------------------------------------------
   // Status Interface
   //-------------------------------------------
   input                                                                         dfi0_init_complete;
   output                                                                        dfi0_init_start;
   output [1:0]                                                                  dfi0_freq_ratio;
   output [1:0]                                                                  dfi0_freq_fsp;
   output [4:0]                                                                  dfi0_frequency;

   input                                                                         dfi1_init_complete;
   output                                                                        dfi1_init_start;
   output [1:0]                                                                  dfi1_freq_ratio;
   output [1:0]                                                                  dfi1_freq_fsp;
   output [4:0]                                                                  dfi1_frequency;

   //-------------------------------------------
   // PHY Master Interface
   //-------------------------------------------
   input  [`MEMC_NUM_RANKS-1:0]                                                  dfi0_phymstr_cs_state;
   input                                                                         dfi0_phymstr_req;
   input                                                                         dfi0_phymstr_state_sel;
   input  [1:0]                                                                  dfi0_phymstr_type;
   output                                                                        dfi0_phymstr_ack;

   input  [`MEMC_NUM_RANKS-1:0]                                                  dfi1_phymstr_cs_state;
   input                                                                         dfi1_phymstr_req;
   input                                                                         dfi1_phymstr_state_sel;
   input  [1:0]                                                                  dfi1_phymstr_type;
   output                                                                        dfi1_phymstr_ack;

   //-------------------------------------------
   // Low Power Control Interface
   //-------------------------------------------
   output                                                                        dfi0_lp_ctrl_req;
   output [DFI_LP_WAKEUP_PD_WIDTH-1:0]                                           dfi0_lp_ctrl_wakeup;
   input                                                                         dfi0_lp_ctrl_ack;
   output                                                                        dfi0_lp_data_req;
   output [DFI_LP_WAKEUP_PD_WIDTH-1:0]                                           dfi0_lp_data_wakeup;
   input                                                                         dfi0_lp_data_ack;

   output                                                                        dfi1_lp_ctrl_req;
   output [DFI_LP_WAKEUP_PD_WIDTH-1:0]                                           dfi1_lp_ctrl_wakeup;
   input                                                                         dfi1_lp_ctrl_ack;
   output                                                                        dfi1_lp_data_req;
   output [DFI_LP_WAKEUP_PD_WIDTH-1:0]                                           dfi1_lp_data_wakeup;
   input                                                                         dfi1_lp_data_ack;

   //-------------------------------------------
   // MC to PHY Message Interface
   //-------------------------------------------
   output                                                                        dfi0_ctrlmsg_req;
   output [7:0]                                                                  dfi0_ctrlmsg;
   output [15:0]                                                                 dfi0_ctrlmsg_data;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Unused signal. Keeping it as it is part of PHY I/O.
   input                                                                         dfi0_ctrlmsg_ack;
//spyglass enable_block W240

   output                                                                        dfi1_ctrlmsg_req;
   output [7:0]                                                                  dfi1_ctrlmsg;
   output [15:0]                                                                 dfi1_ctrlmsg_data;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Unused signal. Keeping it as it is part of PHY I/O.
   input                                                                         dfi1_ctrlmsg_ack;
//spyglass enable_block W240

   //-------------------------------------------
   // WCK Control Interface
   //-------------------------------------------
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi0_wck_cs_P0;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi0_wck_en_P0;
   output [1:0]                                                                  dfi0_wck_toggle_P0;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi1_wck_cs_P0;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi1_wck_en_P0;
   output [1:0]                                                                  dfi1_wck_toggle_P0;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi0_wck_cs_P1;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi0_wck_en_P1;
   output [1:0]                                                                  dfi0_wck_toggle_P1;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi1_wck_cs_P1;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi1_wck_en_P1;
   output [1:0]                                                                  dfi1_wck_toggle_P1;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi0_wck_cs_P2;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi0_wck_en_P2;
   output [1:0]                                                                  dfi0_wck_toggle_P2;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi1_wck_cs_P2;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi1_wck_en_P2;
   output [1:0]                                                                  dfi1_wck_toggle_P2;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi0_wck_cs_P3;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi0_wck_en_P3;
   output [1:0]                                                                  dfi0_wck_toggle_P3;
   output [`MEMC_NUM_RANKS-1:0]                                                  dfi1_wck_cs_P3;
   output [`DDRCTL_DFI_DATA_WIDTH/16-1:0]                                        dfi1_wck_en_P3;
   output [1:0]                                                                  dfi1_wck_toggle_P3;

   //-------------------------------------------
   // Non-DFI DDRCTL PHY Sideband Interface
   //-------------------------------------------
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy0_snoop_en_P0;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy1_snoop_en_P0;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy0_snoop_en_P1;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy1_snoop_en_P1;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy0_snoop_en_P2;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy1_snoop_en_P2;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy0_snoop_en_P3;
   output [(`DDRCTL_DFI_DATAEN_WIDTH*4)-1:0]                                     dwc_ddrphy1_snoop_en_P3;

   input                                 dfi_reset_n_in;
   output                                dfi_reset_n_ref;
   input                                 init_mr_done_in;
   output                                init_mr_done_out;



   input                                        scanmode;
   input                                        scan_resetn;
   input                                        pclk;
   input                                        presetn;
   input [`UMCTL2_APB_AW-1:0]                   paddr;
   input [`UMCTL2_APB_DW-1:0]                   pwdata;
   input                                        pwrite;
   input                                        psel;
   input                                        penable;

   output                                       pready;
   output [`UMCTL2_APB_DW-1:0]                  prdata;
   output                                       pslverr;


    output [`MEMC_NUM_RANKS*`MEMC_BANK_BITS-1:0]  hif_refresh_req_bank;


    output                                      derate_temp_limit_intr;
    output  [1:0]                               derate_temp_limit_intr_fault;




   // ------------------------------------------------------------------------- //
   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
   wire reg_ddrc_lpddr4;
   wire reg_apb_lpddr4;
   wire reg_arba0_lpddr4;
   wire reg_ddrc_lpddr5;
   wire reg_apb_lpddr5;
   wire reg_arba0_lpddr5;
   wire reg_ddrc_en_2t_timing_mode;
   wire reg_apb_en_2t_timing_mode;
   wire reg_arba0_en_2t_timing_mode;
   wire [DATA_BUS_WIDTH_WIDTH-1:0] reg_ddrc_data_bus_width;
   wire [DATA_BUS_WIDTH_WIDTH-1:0] reg_apb_data_bus_width;
   wire [DATA_BUS_WIDTH_WIDTH-1:0] reg_arba0_data_bus_width;
   wire [BURST_RDWR_WIDTH-1:0] reg_ddrc_burst_rdwr;
   wire [BURST_RDWR_WIDTH-1:0] reg_apb_burst_rdwr;
   wire [BURST_RDWR_WIDTH-1:0] reg_arba0_burst_rdwr;
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
   wire reg_ddrc_wck_on;
   wire reg_ddrc_wck_suspend_en;
   wire reg_ddrc_ws_off_en;
   //------------------------
   // Register REGB_DDRC_CH0.STAT
   //------------------------
   wire [OPERATING_MODE_WIDTH-1:0] ddrc_reg_operating_mode;
   wire [SELFREF_TYPE_WIDTH-1:0] ddrc_reg_selfref_type;
   wire [SELFREF_STATE_WIDTH-1:0] ddrc_reg_selfref_state;
   wire ddrc_reg_selfref_cam_not_empty;
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
   wire reg_ddrc_mr_type;
   wire reg_ddrc_sw_init_int;
   wire [MR_RANK_WIDTH-1:0] reg_ddrc_mr_rank;
   wire [MR_ADDR_WIDTH-1:0] reg_ddrc_mr_addr;
   wire reg_ddrc_mrr_done_clr;
   wire reg_ddrc_mr_wr;
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
   wire [MR_DATA_WIDTH-1:0] reg_ddrc_mr_data;
   //------------------------
   // Register REGB_DDRC_CH0.MRSTAT
   //------------------------
   wire ddrc_reg_mr_wr_busy;
   wire ddrc_reg_mrr_done;
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA0
   //------------------------
   wire [MRR_DATA_LWR_WIDTH-1:0] ddrc_reg_mrr_data_lwr;
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA1
   //------------------------
   wire [MRR_DATA_UPR_WIDTH-1:0] ddrc_reg_mrr_data_upr;
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
   wire reg_ddrc_derate_enable;
   wire reg_ddrc_lpddr4_refresh_mode;
   wire reg_ddrc_derate_mr4_pause_fc;
   wire reg_ddrc_dis_trefi_x6x8;
   wire reg_ddrc_dis_trefi_x0125;
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
   wire [ACTIVE_DERATE_BYTE_RANK_WIDTH-1:0] reg_ddrc_active_derate_byte_rank0;
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
   wire reg_ddrc_derate_temp_limit_intr_en;
   wire reg_ddrc_derate_temp_limit_intr_clr;
   wire reg_ddrc_derate_temp_limit_intr_force;
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
   wire reg_ddrc_derate_mr4_tuf_dis;
   //------------------------
   // Register REGB_DDRC_CH0.DERATESTAT0
   //------------------------
   wire ddrc_reg_derate_temp_limit_intr;
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
   wire [DBG_MR4_GRP_SEL_WIDTH-1:0] reg_ddrc_dbg_mr4_grp_sel;
   wire [DBG_MR4_RANK_SEL_WIDTH-1:0] reg_ddrc_dbg_mr4_rank_sel;
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGSTAT
   //------------------------
   wire [DBG_MR4_BYTE_WIDTH-1:0] ddrc_reg_dbg_mr4_byte0;
   wire [DBG_MR4_BYTE_WIDTH-1:0] ddrc_reg_dbg_mr4_byte1;
   wire [DBG_MR4_BYTE_WIDTH-1:0] ddrc_reg_dbg_mr4_byte2;
   wire [DBG_MR4_BYTE_WIDTH-1:0] ddrc_reg_dbg_mr4_byte3;
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
   wire [SELFREF_EN_WIDTH-1:0] reg_ddrc_selfref_en;
   wire [POWERDOWN_EN_WIDTH-1:0] reg_ddrc_powerdown_en;
   wire reg_ddrc_en_dfi_dram_clk_disable;
   wire reg_ddrc_selfref_sw;
   wire reg_ddrc_stay_in_selfref;
   wire reg_ddrc_dis_cam_drain_selfref;
   wire reg_ddrc_lpddr4_sr_allowed;
   wire reg_ddrc_dsm_en;
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
   wire reg_ddrc_hw_lp_en;
   wire reg_ddrc_hw_lp_exit_idle_en;
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
   wire [BSM_CLK_ON_WIDTH-1:0] reg_ddrc_bsm_clk_on;
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
   wire [REFRESH_BURST_WIDTH-1:0] reg_ddrc_refresh_burst;
   wire [AUTO_REFAB_EN_WIDTH-1:0] reg_ddrc_auto_refab_en;
   wire reg_ddrc_per_bank_refresh;
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
   wire reg_ddrc_dis_auto_refresh;
   wire reg_ddrc_refresh_update_level;
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
   wire reg_ddrc_zq_resistor_shared;
   wire reg_ddrc_dis_auto_zq;
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
   wire reg_ddrc_zq_reset;
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
   wire reg_ddrc_dis_srx_zqcl;
   //------------------------
   // Register REGB_DDRC_CH0.ZQSTAT
   //------------------------
   wire ddrc_reg_zq_reset_busy;
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
   wire [DQSOSC_RUNTIME_WIDTH-1:0] reg_ddrc_dqsosc_runtime;
   wire [WCK2DQO_RUNTIME_WIDTH-1:0] reg_ddrc_wck2dqo_runtime;
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCSTAT0
   //------------------------
   wire [DQSOSC_STATE_WIDTH-1:0] ddrc_reg_dqsosc_state;
   wire [DQSOSC_PER_RANK_STAT_WIDTH-1:0] ddrc_reg_dqsosc_per_rank_stat;
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
   wire reg_ddrc_dis_dqsosc_srx;
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
   wire reg_ddrc_prefer_write;
   wire reg_ddrc_pageclose;
   wire reg_ddrc_opt_wrcam_fill_level;
   wire reg_ddrc_dis_opt_ntt_by_act;
   wire reg_ddrc_dis_opt_ntt_by_pre;
   wire reg_ddrc_autopre_rmw;
   wire [LPR_NUM_ENTRIES_WIDTH-1:0] reg_ddrc_lpr_num_entries;
   wire reg_ddrc_lpddr4_opt_act_timing;
   wire reg_ddrc_lpddr5_opt_act_timing;
   wire reg_ddrc_prefer_read;
   wire reg_ddrc_dis_speculative_act;
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
   wire [DELAY_SWITCH_WRITE_WIDTH-1:0] reg_ddrc_delay_switch_write;
   wire [PAGE_HIT_LIMIT_WR_WIDTH-1:0] reg_ddrc_page_hit_limit_wr;
   wire [PAGE_HIT_LIMIT_RD_WIDTH-1:0] reg_ddrc_page_hit_limit_rd;
   wire reg_ddrc_opt_hit_gt_hpr;
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
   wire [WRCAM_LOWTHRESH_WIDTH-1:0] reg_ddrc_wrcam_lowthresh;
   wire [WRCAM_HIGHTHRESH_WIDTH-1:0] reg_ddrc_wrcam_highthresh;
   wire [WR_PGHIT_NUM_THRESH_WIDTH-1:0] reg_ddrc_wr_pghit_num_thresh;
   wire [RD_PGHIT_NUM_THRESH_WIDTH-1:0] reg_ddrc_rd_pghit_num_thresh;
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
   wire [RD_ACT_IDLE_GAP_WIDTH-1:0] reg_ddrc_rd_act_idle_gap;
   wire [WR_ACT_IDLE_GAP_WIDTH-1:0] reg_ddrc_wr_act_idle_gap;
   wire [RD_PAGE_EXP_CYCLES_WIDTH-1:0] reg_ddrc_rd_page_exp_cycles;
   wire [WR_PAGE_EXP_CYCLES_WIDTH-1:0] reg_ddrc_wr_page_exp_cycles;
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
   wire reg_ddrc_dfi_lp_en_pd;
   wire reg_ddrc_dfi_lp_en_sr;
   wire reg_ddrc_dfi_lp_en_dsm;
   wire reg_ddrc_dfi_lp_en_data;
   wire reg_ddrc_dfi_lp_data_req_en;
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
   wire reg_ddrc_dfi_phyupd_en;
   wire reg_ddrc_ctrlupd_pre_srx;
   wire reg_ddrc_dis_auto_ctrlupd_srx;
   wire reg_ddrc_dis_auto_ctrlupd;
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
   wire reg_ddrc_dfi_init_complete_en;
   wire reg_ddrc_phy_dbi_mode;
   wire reg_ddrc_dfi_data_cs_polarity;
   wire reg_ddrc_dfi_init_start;
   wire reg_ddrc_lp_optimized_write;
   wire [DFI_FREQUENCY_WIDTH-1:0] reg_ddrc_dfi_frequency;
   wire [DFI_FREQ_FSP_WIDTH-1:0] reg_ddrc_dfi_freq_fsp;
   wire [DFI_CHANNEL_MODE_WIDTH-1:0] reg_ddrc_dfi_channel_mode;
   //------------------------
   // Register REGB_DDRC_CH0.DFISTAT
   //------------------------
   wire ddrc_reg_dfi_init_complete;
   wire ddrc_reg_dfi_lp_ctrl_ack_stat;
   wire ddrc_reg_dfi_lp_data_ack_stat;
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
   wire reg_ddrc_dfi_phymstr_en;
   wire [DFI_PHYMSTR_BLK_REF_X32_WIDTH-1:0] reg_ddrc_dfi_phymstr_blk_ref_x32;
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
   wire [DFI_CTRLMSG_DATA_WIDTH-1:0] reg_ddrc_dfi0_ctrlmsg_data;
   wire [DFI_CTRLMSG_CMD_WIDTH-1:0] reg_ddrc_dfi0_ctrlmsg_cmd;
   wire reg_ddrc_dfi0_ctrlmsg_tout_clr;
   wire reg_ddrc_dfi0_ctrlmsg_req;
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGSTAT0
   //------------------------
   wire ddrc_reg_dfi0_ctrlmsg_req_busy;
   wire ddrc_reg_dfi0_ctrlmsg_resp_tout;
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
   wire reg_ddrc_wr_poison_slverr_en;
   wire reg_ddrc_wr_poison_intr_en;
   wire reg_ddrc_wr_poison_intr_clr;
   wire reg_ddrc_rd_poison_slverr_en;
   wire reg_ddrc_rd_poison_intr_en;
   wire reg_ddrc_rd_poison_intr_clr;
   //------------------------
   // Register REGB_DDRC_CH0.POISONSTAT
   //------------------------
   wire ddrc_reg_wr_poison_intr_0;
   wire ddrc_reg_rd_poison_intr_0;
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
   wire reg_ddrc_dis_wc;
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
   wire reg_ddrc_dis_dq;
   wire reg_ddrc_dis_hif;
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCAM
   //------------------------
   wire [DBG_HPR_Q_DEPTH_WIDTH-1:0] ddrc_reg_dbg_hpr_q_depth;
   wire [DBG_LPR_Q_DEPTH_WIDTH-1:0] ddrc_reg_dbg_lpr_q_depth;
   wire [DBG_W_Q_DEPTH_WIDTH-1:0] ddrc_reg_dbg_w_q_depth;
   wire ddrc_reg_dbg_stall;
   wire ddrc_reg_dbg_rd_q_empty;
   wire ddrc_reg_dbg_wr_q_empty;
   wire ddrc_reg_rd_data_pipeline_empty;
   wire ddrc_reg_wr_data_pipeline_empty;
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
   wire reg_ddrc_zq_calib_short;
   wire reg_ddrc_ctrlupd;
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLSTAT
   //------------------------
   wire ddrc_reg_zq_calib_short_busy;
   wire ddrc_reg_ctrlupd_busy;
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
   wire reg_ddrc_rank0_refresh;
   //------------------------
   // Register REGB_DDRC_CH0.OPREFSTAT0
   //------------------------
   wire ddrc_reg_rank0_refresh_busy;
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
   wire reg_ddrc_sw_done;
   //------------------------
   // Register REGB_DDRC_CH0.SWSTAT
   //------------------------
   wire ddrc_reg_sw_done_ack;
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
   wire reg_ddrc_dm_en;
   wire reg_ddrc_wr_dbi_en;
   wire reg_ddrc_rd_dbi_en;
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
   wire [RANK_WR_ODT_WIDTH-1:0] reg_ddrc_rank0_wr_odt;
   wire [RANK_RD_ODT_WIDTH-1:0] reg_ddrc_rank0_rd_odt;
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
   wire reg_ddrc_rd_data_copy_en;
   wire reg_ddrc_wr_data_copy_en;
   wire reg_ddrc_wr_data_x_en;
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
   wire reg_ddrc_sw_static_unlock;
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
   wire [PRE_CKE_X1024_WIDTH-1:0] reg_ddrc_pre_cke_x1024;
   wire [POST_CKE_X1024_WIDTH-1:0] reg_ddrc_post_cke_x1024;
   wire [SKIP_DRAM_INIT_WIDTH-1:0] reg_ddrc_skip_dram_init;
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
   wire [DRAM_RSTN_X1024_WIDTH-1:0] reg_ddrc_dram_rstn_x1024;
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_NUMBER
   //------------------------
   wire [VER_NUMBER_WIDTH-1:0] ddrc_reg_ver_number;
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_TYPE
   //------------------------
   wire [VER_TYPE_WIDTH-1:0] ddrc_reg_ver_type;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
   wire [ADDRMAP_BANK_B0_WIDTH-1:0] reg_ddrc_addrmap_bank_b0_map0;
   wire [ADDRMAP_BANK_B1_WIDTH-1:0] reg_ddrc_addrmap_bank_b1_map0;
   wire [ADDRMAP_BANK_B2_WIDTH-1:0] reg_ddrc_addrmap_bank_b2_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
   wire [ADDRMAP_BG_B0_WIDTH-1:0] reg_ddrc_addrmap_bg_b0_map0;
   wire [ADDRMAP_BG_B1_WIDTH-1:0] reg_ddrc_addrmap_bg_b1_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
   wire [ADDRMAP_COL_B7_WIDTH-1:0] reg_ddrc_addrmap_col_b7_map0;
   wire [ADDRMAP_COL_B8_WIDTH-1:0] reg_ddrc_addrmap_col_b8_map0;
   wire [ADDRMAP_COL_B9_WIDTH-1:0] reg_ddrc_addrmap_col_b9_map0;
   wire [ADDRMAP_COL_B10_WIDTH-1:0] reg_ddrc_addrmap_col_b10_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
   wire [ADDRMAP_COL_B3_WIDTH-1:0] reg_ddrc_addrmap_col_b3_map0;
   wire [ADDRMAP_COL_B4_WIDTH-1:0] reg_ddrc_addrmap_col_b4_map0;
   wire [ADDRMAP_COL_B5_WIDTH-1:0] reg_ddrc_addrmap_col_b5_map0;
   wire [ADDRMAP_COL_B6_WIDTH-1:0] reg_ddrc_addrmap_col_b6_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
   wire [ADDRMAP_ROW_B14_WIDTH-1:0] reg_ddrc_addrmap_row_b14_map0;
   wire [ADDRMAP_ROW_B15_WIDTH-1:0] reg_ddrc_addrmap_row_b15_map0;
   wire [ADDRMAP_ROW_B16_WIDTH-1:0] reg_ddrc_addrmap_row_b16_map0;
   wire [ADDRMAP_ROW_B17_WIDTH-1:0] reg_ddrc_addrmap_row_b17_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
   wire [ADDRMAP_ROW_B10_WIDTH-1:0] reg_ddrc_addrmap_row_b10_map0;
   wire [ADDRMAP_ROW_B11_WIDTH-1:0] reg_ddrc_addrmap_row_b11_map0;
   wire [ADDRMAP_ROW_B12_WIDTH-1:0] reg_ddrc_addrmap_row_b12_map0;
   wire [ADDRMAP_ROW_B13_WIDTH-1:0] reg_ddrc_addrmap_row_b13_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
   wire [ADDRMAP_ROW_B6_WIDTH-1:0] reg_ddrc_addrmap_row_b6_map0;
   wire [ADDRMAP_ROW_B7_WIDTH-1:0] reg_ddrc_addrmap_row_b7_map0;
   wire [ADDRMAP_ROW_B8_WIDTH-1:0] reg_ddrc_addrmap_row_b8_map0;
   wire [ADDRMAP_ROW_B9_WIDTH-1:0] reg_ddrc_addrmap_row_b9_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
   wire [ADDRMAP_ROW_B2_WIDTH-1:0] reg_ddrc_addrmap_row_b2_map0;
   wire [ADDRMAP_ROW_B3_WIDTH-1:0] reg_ddrc_addrmap_row_b3_map0;
   wire [ADDRMAP_ROW_B4_WIDTH-1:0] reg_ddrc_addrmap_row_b4_map0;
   wire [ADDRMAP_ROW_B5_WIDTH-1:0] reg_ddrc_addrmap_row_b5_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
   wire [ADDRMAP_ROW_B0_WIDTH-1:0] reg_ddrc_addrmap_row_b0_map0;
   wire [ADDRMAP_ROW_B1_WIDTH-1:0] reg_ddrc_addrmap_row_b1_map0;
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
   wire [NONBINARY_DEVICE_DENSITY_WIDTH-1:0] reg_ddrc_nonbinary_device_density_map0;
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
   wire reg_arb_go2critical_en_port0;
   wire reg_arb_pagematch_limit_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
   wire [RD_PORT_PRIORITY_WIDTH-1:0] reg_arb_rd_port_priority_port0;
   wire reg_arb_rd_port_aging_en_port0;
   wire reg_arb_rd_port_urgent_en_port0;
   wire reg_arb_rd_port_pagematch_en_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
   wire [WR_PORT_PRIORITY_WIDTH-1:0] reg_arb_wr_port_priority_port0;
   wire reg_arb_wr_port_aging_en_port0;
   wire reg_arb_wr_port_urgent_en_port0;
   wire reg_arb_wr_port_pagematch_en_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
   wire reg_arb_port_en_port0;
   wire reg_apb_port_en_port0;
   wire reg_arba0_port_en_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
   wire [RQOS_MAP_LEVEL1_WIDTH-1:0] reg_arba0_rqos_map_level1_port0;
   wire [RQOS_MAP_REGION0_WIDTH-1:0] reg_arba0_rqos_map_region0_port0;
   wire [RQOS_MAP_REGION1_WIDTH-1:0] reg_arba0_rqos_map_region1_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
   wire [RQOS_MAP_TIMEOUTB_WIDTH-1:0] reg_arb_rqos_map_timeoutb_port0;
   wire [RQOS_MAP_TIMEOUTR_WIDTH-1:0] reg_arb_rqos_map_timeoutr_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
   wire [WQOS_MAP_LEVEL1_WIDTH-1:0] reg_arba0_wqos_map_level1_port0;
   wire [WQOS_MAP_LEVEL2_WIDTH-1:0] reg_arba0_wqos_map_level2_port0;
   wire [WQOS_MAP_REGION0_WIDTH-1:0] reg_arba0_wqos_map_region0_port0;
   wire [WQOS_MAP_REGION1_WIDTH-1:0] reg_arba0_wqos_map_region1_port0;
   wire [WQOS_MAP_REGION2_WIDTH-1:0] reg_arba0_wqos_map_region2_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
   wire [WQOS_MAP_TIMEOUT1_WIDTH-1:0] reg_arb_wqos_map_timeout1_port0;
   wire [WQOS_MAP_TIMEOUT2_WIDTH-1:0] reg_arb_wqos_map_timeout2_port0;
   //------------------------
   // Register REGB_ARB_PORT0.PSTAT
   //------------------------
   wire arb_reg_rd_port_busy_0_port0;
   wire arb_reg_wr_port_busy_0_port0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
   wire [T_RAS_MIN_WIDTH-1:0] reg_ddrc_t_ras_min_freq0;
   wire [T_RAS_MAX_WIDTH-1:0] reg_ddrc_t_ras_max_freq0;
   wire [T_FAW_WIDTH-1:0] reg_ddrc_t_faw_freq0;
   wire [WR2PRE_WIDTH-1:0] reg_ddrc_wr2pre_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
   wire [T_RC_WIDTH-1:0] reg_ddrc_t_rc_freq0;
   wire [RD2PRE_WIDTH-1:0] reg_ddrc_rd2pre_freq0;
   wire [T_XP_WIDTH-1:0] reg_ddrc_t_xp_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
   wire [WR2RD_WIDTH-1:0] reg_ddrc_wr2rd_freq0;
   wire [RD2WR_WIDTH-1:0] reg_ddrc_rd2wr_freq0;
   wire [READ_LATENCY_WIDTH-1:0] reg_ddrc_read_latency_freq0;
   wire [WRITE_LATENCY_WIDTH-1:0] reg_ddrc_write_latency_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
   wire [WR2MR_WIDTH-1:0] reg_ddrc_wr2mr_freq0;
   wire [RD2MR_WIDTH-1:0] reg_ddrc_rd2mr_freq0;
   wire [T_MR_WIDTH-1:0] reg_ddrc_t_mr_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
   wire [T_RP_WIDTH-1:0] reg_ddrc_t_rp_freq0;
   wire [T_RRD_WIDTH-1:0] reg_ddrc_t_rrd_freq0;
   wire [T_CCD_WIDTH-1:0] reg_ddrc_t_ccd_freq0;
   wire [T_RCD_WIDTH-1:0] reg_ddrc_t_rcd_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
   wire [T_CKE_WIDTH-1:0] reg_ddrc_t_cke_freq0;
   wire [T_CKESR_WIDTH-1:0] reg_ddrc_t_ckesr_freq0;
   wire [T_CKSRE_WIDTH-1:0] reg_ddrc_t_cksre_freq0;
   wire [T_CKSRX_WIDTH-1:0] reg_ddrc_t_cksrx_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
   wire [T_CKCSX_WIDTH-1:0] reg_ddrc_t_ckcsx_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
   wire [T_CSH_WIDTH-1:0] reg_ddrc_t_csh_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
   wire [WR2RD_S_WIDTH-1:0] reg_ddrc_wr2rd_s_freq0;
   wire [T_RRD_S_WIDTH-1:0] reg_ddrc_t_rrd_s_freq0;
   wire [T_CCD_S_WIDTH-1:0] reg_ddrc_t_ccd_s_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
   wire [T_CMDCKE_WIDTH-1:0] reg_ddrc_t_cmdcke_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
   wire [T_PPD_WIDTH-1:0] reg_ddrc_t_ppd_freq0;
   wire [T_CCD_MW_WIDTH-1:0] reg_ddrc_t_ccd_mw_freq0;
   wire [ODTLOFF_WIDTH-1:0] reg_ddrc_odtloff_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
   wire [T_XSR_WIDTH-1:0] reg_ddrc_t_xsr_freq0;
   wire [T_OSCO_WIDTH-1:0] reg_ddrc_t_osco_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
   wire [T_PDN_WIDTH-1:0] reg_ddrc_t_pdn_freq0;
   wire [T_XSR_DSM_X1024_WIDTH-1:0] reg_ddrc_t_xsr_dsm_x1024_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
   wire [MAX_WR_SYNC_WIDTH-1:0] reg_ddrc_max_wr_sync_freq0;
   wire [MAX_RD_SYNC_WIDTH-1:0] reg_ddrc_max_rd_sync_freq0;
   wire [RD2WR_S_WIDTH-1:0] reg_ddrc_rd2wr_s_freq0;
   wire [BANK_ORG_WIDTH-1:0] reg_ddrc_bank_org_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
   wire [RDA2PRE_WIDTH-1:0] reg_ddrc_rda2pre_freq0;
   wire [WRA2PRE_WIDTH-1:0] reg_ddrc_wra2pre_freq0;
   wire [LPDDR4_DIFF_BANK_RWA2PRE_WIDTH-1:0] reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
   wire [MRR2RD_WIDTH-1:0] reg_ddrc_mrr2rd_freq0;
   wire [MRR2WR_WIDTH-1:0] reg_ddrc_mrr2wr_freq0;
   wire [MRR2MRW_WIDTH-1:0] reg_ddrc_mrr2mrw_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
   wire [EMR_WIDTH-1:0] reg_ddrc_emr_freq0;
   wire [MR_WIDTH-1:0] reg_ddrc_mr_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
   wire [EMR3_WIDTH-1:0] reg_ddrc_emr3_freq0;
   wire [EMR2_WIDTH-1:0] reg_ddrc_emr2_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
   wire [MR5_WIDTH-1:0] reg_ddrc_mr5_freq0;
   wire [MR4_WIDTH-1:0] reg_ddrc_mr4_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
   wire [MR6_WIDTH-1:0] reg_ddrc_mr6_freq0;
   wire [MR22_WIDTH-1:0] reg_ddrc_mr22_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
   wire [DFI_TPHY_WRLAT_WIDTH-1:0] reg_ddrc_dfi_tphy_wrlat_freq0;
   wire [DFI_TPHY_WRDATA_WIDTH-1:0] reg_ddrc_dfi_tphy_wrdata_freq0;
   wire [DFI_T_RDDATA_EN_WIDTH-1:0] reg_ddrc_dfi_t_rddata_en_freq0;
   wire [DFI_T_CTRL_DELAY_WIDTH-1:0] reg_ddrc_dfi_t_ctrl_delay_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
   wire [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0] reg_ddrc_dfi_t_dram_clk_enable_freq0;
   wire [DFI_T_DRAM_CLK_DISABLE_WIDTH-1:0] reg_ddrc_dfi_t_dram_clk_disable_freq0;
   wire [DFI_T_WRDATA_DELAY_WIDTH-1:0] reg_ddrc_dfi_t_wrdata_delay_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
   wire [DFI_TPHY_WRCSLAT_WIDTH-1:0] reg_ddrc_dfi_tphy_wrcslat_freq0;
   wire [DFI_TPHY_RDCSLAT_WIDTH-1:0] reg_ddrc_dfi_tphy_rdcslat_freq0;
   wire [DFI_TWCK_DELAY_WIDTH-1:0] reg_ddrc_dfi_twck_delay_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
   wire [DFI_TWCK_DIS_WIDTH-1:0] reg_ddrc_dfi_twck_dis_freq0;
   wire [DFI_TWCK_EN_WR_WIDTH-1:0] reg_ddrc_dfi_twck_en_wr_freq0;
   wire [DFI_TWCK_EN_RD_WIDTH-1:0] reg_ddrc_dfi_twck_en_rd_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
   wire [DFI_TWCK_TOGGLE_POST_WIDTH-1:0] reg_ddrc_dfi_twck_toggle_post_freq0;
   wire [DFI_TWCK_TOGGLE_CS_WIDTH-1:0] reg_ddrc_dfi_twck_toggle_cs_freq0;
   wire [DFI_TWCK_TOGGLE_WIDTH-1:0] reg_ddrc_dfi_twck_toggle_freq0;
   wire [DFI_TWCK_FAST_TOGGLE_WIDTH-1:0] reg_ddrc_dfi_twck_fast_toggle_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
   wire [DFI_LP_WAKEUP_PD_WIDTH-1:0] reg_ddrc_dfi_lp_wakeup_pd_freq0;
   wire [DFI_LP_WAKEUP_SR_WIDTH-1:0] reg_ddrc_dfi_lp_wakeup_sr_freq0;
   wire [DFI_LP_WAKEUP_DSM_WIDTH-1:0] reg_ddrc_dfi_lp_wakeup_dsm_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
   wire [DFI_LP_WAKEUP_DATA_WIDTH-1:0] reg_ddrc_dfi_lp_wakeup_data_freq0;
   wire [DFI_TLP_RESP_WIDTH-1:0] reg_ddrc_dfi_tlp_resp_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
   wire [DFI_T_CTRLUP_MIN_WIDTH-1:0] reg_ddrc_dfi_t_ctrlup_min_freq0;
   wire [DFI_T_CTRLUP_MAX_WIDTH-1:0] reg_ddrc_dfi_t_ctrlup_max_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
   wire [DFI_T_CTRLUPD_INTERVAL_MAX_X1024_WIDTH-1:0] reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0;
   wire [DFI_T_CTRLUPD_INTERVAL_MIN_X1024_WIDTH-1:0] reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
   wire [DFI_T_CTRLMSG_RESP_WIDTH-1:0] reg_ddrc_dfi_t_ctrlmsg_resp_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
   wire [T_REFI_X1_X32_WIDTH-1:0] reg_ddrc_t_refi_x1_x32_freq0;
   wire [REFRESH_TO_X1_X32_WIDTH-1:0] reg_ddrc_refresh_to_x1_x32_freq0;
   wire [REFRESH_MARGIN_WIDTH-1:0] reg_ddrc_refresh_margin_freq0;
   wire reg_ddrc_t_refi_x1_sel_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
   wire [T_RFC_MIN_WIDTH-1:0] reg_ddrc_t_rfc_min_freq0;
   wire [T_RFC_MIN_AB_WIDTH-1:0] reg_ddrc_t_rfc_min_ab_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
   wire [T_PBR2PBR_WIDTH-1:0] reg_ddrc_t_pbr2pbr_freq0;
   wire [T_PBR2ACT_WIDTH-1:0] reg_ddrc_t_pbr2act_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
   wire [REFRESH_TO_AB_X32_WIDTH-1:0] reg_ddrc_refresh_to_ab_x32_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
   wire [T_ZQ_LONG_NOP_WIDTH-1:0] reg_ddrc_t_zq_long_nop_freq0;
   wire [T_ZQ_SHORT_NOP_WIDTH-1:0] reg_ddrc_t_zq_short_nop_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
   wire [T_ZQ_SHORT_INTERVAL_X1024_WIDTH-1:0] reg_ddrc_t_zq_short_interval_x1024_freq0;
   wire [T_ZQ_RESET_NOP_WIDTH-1:0] reg_ddrc_t_zq_reset_nop_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
   wire reg_ddrc_dqsosc_enable_freq0;
   wire reg_ddrc_dqsosc_interval_unit_freq0;
   wire [DQSOSC_INTERVAL_WIDTH-1:0] reg_ddrc_dqsosc_interval_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
   wire [MR4_READ_INTERVAL_WIDTH-1:0] reg_ddrc_mr4_read_interval_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
   wire [DERATED_T_RRD_WIDTH-1:0] reg_ddrc_derated_t_rrd_freq0;
   wire [DERATED_T_RP_WIDTH-1:0] reg_ddrc_derated_t_rp_freq0;
   wire [DERATED_T_RAS_MIN_WIDTH-1:0] reg_ddrc_derated_t_ras_min_freq0;
   wire [DERATED_T_RCD_WIDTH-1:0] reg_ddrc_derated_t_rcd_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
   wire [DERATED_T_RC_WIDTH-1:0] reg_ddrc_derated_t_rc_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
   wire [HW_LP_IDLE_X32_WIDTH-1:0] reg_ddrc_hw_lp_idle_x32_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
   wire [PAGECLOSE_TIMER_WIDTH-1:0] reg_ddrc_pageclose_timer_freq0;
   wire [RDWR_IDLE_GAP_WIDTH-1:0] reg_ddrc_rdwr_idle_gap_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
   wire [HPR_MAX_STARVE_WIDTH-1:0] reg_ddrc_hpr_max_starve_freq0;
   wire [HPR_XACT_RUN_LENGTH_WIDTH-1:0] reg_ddrc_hpr_xact_run_length_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
   wire [LPR_MAX_STARVE_WIDTH-1:0] reg_ddrc_lpr_max_starve_freq0;
   wire [LPR_XACT_RUN_LENGTH_WIDTH-1:0] reg_ddrc_lpr_xact_run_length_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
   wire [W_MAX_STARVE_WIDTH-1:0] reg_ddrc_w_max_starve_freq0;
   wire [W_XACT_RUN_LENGTH_WIDTH-1:0] reg_ddrc_w_xact_run_length_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
   wire reg_ddrc_frequency_ratio_freq0;
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
   wire [POWERDOWN_TO_X32_WIDTH-1:0] reg_ddrc_powerdown_to_x32_freq0;
   wire [SELFREF_TO_X32_WIDTH-1:0] reg_ddrc_selfref_to_x32_freq0;

wire [DATA_BUS_WIDTH_WIDTH-1 :0] reg_ddrc_data_bus_width_int;
// reg_ddrc_ddr4 & reg_ddrc_ddr5 should be opposite to each other so that there should be no paths crossing from DDRC_CPE to PAS_CPE
wire                                reg_ddrc_ddr5_w;
wire                                reg_ddrc_ddr4_w;
wire                                reg_ddrc_ecc_type_w;

    assign reg_ddrc_ddr5_w                               = 1'b0;
    assign reg_ddrc_ddr4_w                               = 1'b0;


   wire hif_cmd_q_not_empty;            // indicates that there are commands pending in the cams
   wire [`MEMC_HIF_CREDIT_BITS-1:0]  hif_hpr_credit;
   wire [`MEMC_HIF_CREDIT_BITS-1:0]  ddrc_hif_hpr_credit;
   wire [`MEMC_HIF_CREDIT_BITS-1:0]  hif_lpr_credit;
   wire [`MEMC_HIF_CREDIT_BITS-1:0]  ddrc_hif_lpr_credit;
   wire                              hif_wr_credit;
   wire                              ddrc_hif_wr_credit;
   wire [1:0]                        hif_wrecc_credit;
   wire [1:0]                        ddrc_hif_wrecc_credit;

   wire hif_cmd_stall;
   wire ddrc_hif_cmd_stall;


   wire [MEMC_WDATA_PTR_BITS-1:0] hif_wdata_ptr;
   wire [MEMC_WDATA_PTR_BITS-1:0] ddrc_hif_wdata_ptr;
   wire hif_wdata_ptr_valid;
   wire ddrc_hif_wdata_ptr_valid;

   wire hif_wdata_ptr_addr_err;
   wire ddrc_hif_wdata_ptr_addr_err;
   wire hif_rdata_valid, hif_rdata_end;
   wire ddrc_hif_rdata_valid, ddrc_hif_rdata_end;
   wire [`MEMC_DRAM_DATA_WIDTH*`MEMC_FREQ_RATIO*2-1:0] hif_rdata;     // width equivalent to A_DW
   wire [`MEMC_DRAM_DATA_WIDTH*`MEMC_FREQ_RATIO*2-1:0] ddrc_hif_rdata;     // width equivalent to A_DW
   wire [`MEMC_DFI_DATA_WIDTH/8-1:0] hif_rdata_parity;
   wire [`MEMC_DFI_DATA_WIDTH/8-1:0] ddrc_hif_rdata_parity;
   wire [MEMC_TAGBITS-1:0] hif_rdata_token;
   wire [MEMC_TAGBITS-1:0] ddrc_hif_rdata_token;

   wire hif_rdata_addr_err;
   wire ddrc_hif_rdata_addr_err;
   wire hif_wdata_stall;
   wire ddrc_hif_wdata_stall;

//`ifdef MEMC_ECC
//// tie ecc_type to appropriate value:
//// - INLINE_ECC=1 && SIDEBAND_ECC=1 - > driven by register so do nothing
//// - INLINE_ECC=1 && SIDEBAND_ECC=0 - > tie to 1
//// - INLINE_ECC=0 && SIDEBAND_ECC=1 - > tie to 0
//`ifdef MEMC_INLINE_ECC
//  `ifndef MEMC_SIDEBAND_ECC
//    assign reg_ddrc_ecc_type                           = 1'b1;
//  `endif // MEMC_SIDEBAND_ECC
//`else
//    assign reg_ddrc_ecc_type                           = 1'b0;
//`endif // MEMC_INLINE_ECC
//`endif // MEMC_ECC






   wire arb_hif_cmd_valid;
   wire [1:0] arb_hif_cmd_type;
   wire [1:0] arb_hif_cmd_pri;

   wire [`MEMC_HIF_ADDR_WIDTH_MAX-1:0] arb_hif_cmd_addr;
   wire [UMCTL2_CMD_LEN_BITS-1:0] arb_hif_cmd_length;
   wire [MEMC_TAGBITS-1:0] arb_hif_cmd_token;
   wire [MEMC_WDATA_PTR_BITS-1:0] arb_hif_cmd_wdata_ptr;
   wire arb_hif_cmd_autopre;

   wire arb_hif_wdata_valid; // valid write data being transfered
   wire [`MEMC_DRAM_DATA_WIDTH*`MEMC_FREQ_RATIO*2-1:0] arb_hif_wdata; // write data. valid when co_ih_rxdata_valid=1
   wire [(`MEMC_DRAM_DATA_WIDTH*`MEMC_FREQ_RATIO*2)/8-1:0] arb_hif_wdata_mask; // write data. valid when co_ih_rxdata_valid=1
   wire arb_hif_wdata_end;
   wire arb_hif_go2critical_wr, arb_hif_go2critical_lpr, arb_hif_go2critical_hpr;
   wire arb_hif_go2critical_l1_wr, arb_hif_go2critical_l1_lpr, arb_hif_go2critical_l1_hpr;
   wire arb_hif_go2critical_l2_wr, arb_hif_go2critical_l2_lpr, arb_hif_go2critical_l2_hpr;

   wire [UMCTL2_WDATARAM_PAR_DW-1:0] arb_hif_wdata_parity; // write data parity.

   wire [UMCTL2_WDATARAM_DW-1:0]     wdataram_dout_int;
   wire [UMCTL2_WDATARAM_DW-1:0]     wdataram_din_int;
   wire [UMCTL2_WDATARAM_DW/8-1:0]   wdataram_mask_int;
    assign wdataram_din = wdataram_din_int[UMCTL2_WDATARAM_DW-1:0];
    assign wdataram_mask = wdataram_mask_int[UMCTL2_WDATARAM_DW/8-1:0];
    assign wdataram_dout_int[UMCTL2_WDATARAM_DW-1:0] = wdataram_dout[UMCTL2_WDATARAM_DW-1:0];

   wire [UMCTL2_WDATARAM_PAR_DW_EXT-1:0]          wdataram_dout_par_int;
   wire [UMCTL2_WDATARAM_PAR_DW_EXT-1:0]          wdataram_din_par_int;

    assign wdataram_dout_par_int = {UMCTL2_WDATARAM_PAR_DW_EXT{1'b0}};


  wire  multi_beat_ecc;
  assign multi_beat_ecc = 1'b0;

  // DFI mux used to introduce a delay
  // line when tphy_wrlat is set to 0
  // and delays are being modeled here
  //-------------------------------

   parameter XPI_RQOS_MLW = `UMCTL2_XPI_RQOS_MLW;
   parameter XPI_RQOS_RW = `UMCTL2_XPI_RQOS_RW;
   parameter XPI_WQOS_MLW = `UMCTL2_XPI_WQOS_MLW;
   parameter XPI_WQOS_RW = `UMCTL2_XPI_WQOS_RW;
   parameter DUAL_PA    = `UMCTL2_DUAL_PA;

   localparam ECC_H3_WIDTH = 6;

   genvar gv;
   genvar np;
   genvar dpa_np;


   localparam PORT_PRIORITYW = 5;
   localparam REG_PORT_PRIORITYW = 10; // FIXME_GG: This value to be driven from register automation


   wire hif_hif_wdata_valid;
   wire hif_hif_wdata_end;
   wire [A_DW-1:0] hif_hif_wdata;
   wire [A_STRBW-1:0] hif_hif_wdata_mask;
   wire [A_PARW-1:0] hif_hif_wdata_parity;

   wire [NPORTS-1:0] rd_port_busy, wr_port_busy;
   wire [NPORTS*REG_PORT_PRIORITYW-1:0] reg_wr_port_priority, reg_rd_port_priority;
   wire [NPORTS-1:0] reg_wr_port_aging_en, reg_rd_port_aging_en;
   wire [NPORTS-1:0] reg_wr_port_urgent_en, reg_rd_port_urgent_en;
   wire any_other_stall_condition      = 1'b0;
   wire any_other_stall_condition_dch1 = 1'b0;


   wire hif_hif_cmd_valid;
   wire [1:0] hif_hif_cmd_type;
   wire [HIF_ADDR_WIDTH-1:0] hif_hif_cmd_addr;
   wire [XPI_RQOS_RW-1:0] hif_hif_cmd_pri;
   wire [HIF_RQOS_TW-1:0] hif_hif_cmd_latency;

   wire [MEMC_TAGBITS-1:0] hif_hif_cmd_token;
   wire [UMCTL2_CMD_LEN_BITS-1:0] hif_hif_cmd_length;
   wire [MEMC_WDATA_PTR_BITS-1:0] hif_hif_cmd_wdata_ptr;
   wire hif_hif_cmd_autopre;

   wire hif_hif_cmd_ecc_region;
   wire [WRDATA_CYCLES-1:0] hif_hif_cmd_wdata_mask_full_ie;

   wire [`MEMC_HIF_ADDR_WIDTH_MAX-1:0]   hifx_hif_cmd_addr;

   wire pa_hif_go2critical_wr, pa_hif_go2critical_lpr, pa_hif_go2critical_hpr;
   wire pa_hif_go2critical_l1_wr, pa_hif_go2critical_l1_lpr, pa_hif_go2critical_l1_hpr;
   wire pa_hif_go2critical_l2_wr, pa_hif_go2critical_l2_lpr, pa_hif_go2critical_l2_hpr;

   wire [INT_NPORTS_DATA-1:0] wr_poison_intr_dch0;

   wire [INT_NPORTS_DATA-1:0] wr_poison_intr;
   wire [INT_NPORTS_DATA-1:0] rd_poison_intr;

   wire hif_hif_cmd_awlast;
   wire hif_hif_cmd_short_burst;


   wire [INT_NPORTS_DATA-1:0] wr_poison_intr_dch1;



   dwc_ddrctl_tb_hif_mux
   
   U_hif_mux
   (
         .hif_hif_wdata_valid                   (hif_hif_wdata_valid                   ),
         .hif_hif_wdata_end                     (hif_hif_wdata_end                     ),
         .hif_hif_wdata                         (hif_hif_wdata                         ),
         .hif_hif_wdata_mask                    (hif_hif_wdata_mask                    ),
         .hif_hif_wdata_parity                  (hif_hif_wdata_parity                  ),
         .pa_hif_go2critical_lpr                (pa_hif_go2critical_lpr                ),
         .pa_hif_go2critical_hpr                (pa_hif_go2critical_hpr                ),
         .pa_hif_go2critical_wr                 (pa_hif_go2critical_wr                 ),
         .pa_hif_go2critical_l1_lpr             (pa_hif_go2critical_l1_lpr             ),
         .pa_hif_go2critical_l1_hpr             (pa_hif_go2critical_l1_hpr             ),
         .pa_hif_go2critical_l1_wr              (pa_hif_go2critical_l1_wr              ),
         .pa_hif_go2critical_l2_lpr             (pa_hif_go2critical_l2_lpr             ),
         .pa_hif_go2critical_l2_hpr             (pa_hif_go2critical_l2_hpr             ),
         .pa_hif_go2critical_l2_wr              (pa_hif_go2critical_l2_wr              ),


         .hif_hif_cmd_valid                     (hif_hif_cmd_valid                     ),
         .hif_hif_cmd_type                      (hif_hif_cmd_type                      ),
         .hif_hif_cmd_addr                      (hifx_hif_cmd_addr                     ),
         .hif_hif_cmd_pri                       (hif_hif_cmd_pri                       ),
         .hif_hif_cmd_token                     (hif_hif_cmd_token                     ),
         .hif_hif_cmd_length                    (hif_hif_cmd_length                    ),
         .hif_hif_cmd_wdata_ptr                 (hif_hif_cmd_wdata_ptr                 ),
         .hif_hif_cmd_autopre                   (hif_hif_cmd_autopre                   ),



        .mux_hif_go2critical_l1_lpr             (arb_hif_go2critical_l1_lpr            ),
        .mux_hif_go2critical_l1_hpr             (arb_hif_go2critical_l1_hpr            ),
        .mux_hif_go2critical_l1_wr              (arb_hif_go2critical_l1_wr             ),
        .mux_hif_go2critical_l2_lpr             (arb_hif_go2critical_l2_lpr            ),
        .mux_hif_go2critical_l2_hpr             (arb_hif_go2critical_l2_hpr            ),
        .mux_hif_go2critical_l2_wr              (arb_hif_go2critical_l2_wr             ),



        .mux_hif_cmd_valid                      (arb_hif_cmd_valid                     ),
        .mux_hif_cmd_type                       (arb_hif_cmd_type                      ),
        .mux_hif_cmd_addr                       (arb_hif_cmd_addr                      ),
        .mux_hif_cmd_pri                        (arb_hif_cmd_pri                       ),
        .mux_hif_cmd_token                      (arb_hif_cmd_token                     ),
        .mux_hif_cmd_length                     (arb_hif_cmd_length                    ),
        .mux_hif_cmd_wdata_ptr                  (arb_hif_cmd_wdata_ptr                 ),
        .mux_hif_cmd_autopre                    (arb_hif_cmd_autopre                   ),


        .mux_hif_wdata_valid                    (arb_hif_wdata_valid                   ),
        .mux_hif_wdata_end                      (arb_hif_wdata_end                     ),
        .mux_hif_wdata                          (arb_hif_wdata                         ),
        .mux_hif_wdata_mask                     (arb_hif_wdata_mask                    ),
        .mux_hif_wdata_parity                   (arb_hif_wdata_parity                  ),
        .mux_hif_go2critical_lpr                (arb_hif_go2critical_lpr               ),
        .mux_hif_go2critical_hpr                (arb_hif_go2critical_hpr               ),
        .mux_hif_go2critical_wr                 (arb_hif_go2critical_wr                ),
        //ddrc---->tb_hif---->arb_top

        .hif_lpr_credit                         (hif_lpr_credit                         ),
        .hif_cmd_stall                          (hif_cmd_stall                          ),
        .hif_wr_credit                          (hif_wr_credit                          ),
        .hif_hpr_credit                         (hif_hpr_credit                         ),
        .hif_wrecc_credit                       (hif_wrecc_credit                       ),
        .hif_wdata_ptr                          (hif_wdata_ptr                          ),
        .hif_wdata_ptr_valid                    (hif_wdata_ptr_valid                    ),
        .hif_wdata_ptr_addr_err                 (hif_wdata_ptr_addr_err                 ),
        .hif_rdata_valid                        (hif_rdata_valid                        ),
        .hif_rdata_end                          (hif_rdata_end                          ),
        .hif_rdata_token                        (hif_rdata_token                        ),
        .hif_rdata                              (hif_rdata                              ),
        .hif_rdata_parity                       (hif_rdata_parity                       ),
        .hif_rdata_addr_err                     (hif_rdata_addr_err                     ),
        .hif_wdata_stall                        (hif_wdata_stall                        ),


        .ddrc_hif_lpr_credit                         (ddrc_hif_lpr_credit                         ),
        .ddrc_hif_cmd_stall                          (ddrc_hif_cmd_stall                          ),
        .ddrc_hif_wr_credit                          (ddrc_hif_wr_credit                          ),
        .ddrc_hif_hpr_credit                         (ddrc_hif_hpr_credit                         ),
        .ddrc_hif_wrecc_credit                       (ddrc_hif_wrecc_credit                       ),
        .ddrc_hif_wdata_ptr                          (ddrc_hif_wdata_ptr                          ),
        .ddrc_hif_wdata_ptr_valid                    (ddrc_hif_wdata_ptr_valid                    ),
        .ddrc_hif_wdata_ptr_addr_err                 (ddrc_hif_wdata_ptr_addr_err                 ),
        .ddrc_hif_rdata_addr_err                     (ddrc_hif_rdata_addr_err                     ),
        .ddrc_hif_rdata_valid                        (ddrc_hif_rdata_valid                        ),
        .ddrc_hif_rdata_end                          (ddrc_hif_rdata_end                          ),
        .ddrc_hif_rdata_token                        (ddrc_hif_rdata_token                        ),
        .ddrc_hif_rdata                              (ddrc_hif_rdata                              ),
        .ddrc_hif_rdata_parity                       (ddrc_hif_rdata_parity                       ),
        .ddrc_hif_wdata_stall                        (ddrc_hif_wdata_stall                        )
    );





// connect REF and ZQCS command access output signals
//---------------------------------------------------
    wire [`UMCTL2_NUM_LRANKS_TOTAL-1:0]      reg_ddrc_rank_refresh;
    wire [`UMCTL2_NUM_LRANKS_TOTAL-1:0]      ddrc_reg_rank_refresh_busy;

    assign reg_ddrc_rank_refresh[0]         = reg_ddrc_rank0_refresh;
    assign ddrc_reg_rank0_refresh_busy      = ddrc_reg_rank_refresh_busy[0];




   wire   sync_core_ddrc_rstn;
   DWC_ddr_umctl2_rstn_sync
   
     #(.BCM_VERIF_EN (BCM_VERIF_EN)
       )
   U_cclk_rstn_sync
     (.rstn       (presetn), // could use a soft reset @ pclk
      .clk        (core_ddrc_core_clk),
      .rstn_pin   (scan_resetn),
      .scanmode   (scanmode),
      .rstn_sync  (sync_core_ddrc_rstn));

   wire   sync_aresetn_0;
   DWC_ddr_umctl2_rstn_sync
   
     #(.BCM_VERIF_EN (BCM_VERIF_EN))
   U_aclk0_rstn_sync
     (.rstn       (presetn),
      .clk        (aclk_0),
      .rstn_pin   (scan_resetn),
      .scanmode   (scanmode),
      .rstn_sync  (sync_aresetn_0));


//common sync'd present for all chi ports. All chi port's chi_clk are sync
//needed to fix reset_sync04
   wire   sync_chi_resetn;



   wire [NPORTS+2-1:0]   apb_static_regs_wr_en, apb_quasi_dyn_wr_en; // NPORTS (total aclk) + 2 (pclk + core_clock)
   wire [NPORTS-1:0] aclk_vec, aresetn_vec, sync_aresetn_vec;
   wire              static_wr_en_core, quasi_dyn_wr_en_core;
//`ifdef UMCTL2_OCECC_EN_1
//   wire              quasi_dyn_wr_en_pclk;
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1


   assign static_wr_en_core      = apb_static_regs_wr_en[0];
   assign quasi_dyn_wr_en_core   = apb_quasi_dyn_wr_en[0];
//`ifdef UMCTL2_OCECC_EN_1
//   assign quasi_dyn_wr_en_pclk   = apb_quasi_dyn_wr_en[1];
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1


   wire static_wr_en_aclk_0, quasi_dyn_wr_en_aclk_0;

   assign aclk_vec[0]         = aclk_0;
   assign aresetn_vec[0]      = aresetn_0;
   assign sync_aresetn_vec[0] = sync_aresetn_0;

   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression '(2 + 2)' found in module 'DWC_ddrctl'
   //SJ: This coding style is acceptable and there is no plan to change it.
   assign static_wr_en_aclk_0      = apb_static_regs_wr_en[0+2];
   assign quasi_dyn_wr_en_aclk_0   = apb_quasi_dyn_wr_en[0+2];
   //spyglass enable_block SelfDeterminedExpr-ML




  wire   derate_temp_limit_intr_ret;
  assign ddrc_reg_derate_temp_limit_intr = derate_temp_limit_intr_ret;


  wire core_derate_temp_limit_intr;
  wire derate_sync_ack_c2p;

   wire  lpr_num_entries_changed;
   wire  lpr_num_entries_changed_dch1 = lpr_num_entries_changed; // lpr_num_entries is shared between the two channels
   DWC_ddr_umctl2_reg_en
   
      #(
         .HIF_ONLY               (`UMCTL_A_HIF),
         .NPORTS                 (NPORTS),
         .CP_ASYNC               (P_ASYNC_EN),
         .AP_ASYNC               (`UMCTL2_AP_ANY_ASYNC),
         .BCM_F_SYNC_TYPE        (BCM_F_SYNC_TYPE_C2P),
         .BCM_VERIF_EN           (BCM_VERIF_EN),
         .CAM_ADDRW              (`MEMC_RDCMD_ENTRY_BITS)
      )
   U_apb_reg_en
      (
         // inputs
         .pclk                      (pclk),
         .presetn                   (presetn),
         .core_ddrc_core_clk        (core_ddrc_core_clk),
         .core_ddrc_rstn            (core_ddrc_rstn),
         .aclk                      (aclk_vec),
         .aresetn                   (aresetn_vec),
         .reg_ddrc_sw_done          (reg_ddrc_sw_done),
         .reg_ddrc_sw_static_unlock (reg_ddrc_sw_static_unlock),
         .reg_ddrc_lpr_num_entries  (reg_ddrc_lpr_num_entries),
         // outputs
         .ddrc_reg_sw_done          (ddrc_reg_sw_done_ack),
         .lpr_num_entries_changed   (lpr_num_entries_changed),
         .apb_static_regs_wr_en     (apb_static_regs_wr_en),
         .apb_quasi_dyn_wr_en       (apb_quasi_dyn_wr_en)
      );




   DWC_ddrctl_apb_slvtop
   
     #(.APB_AW              (APB_AW),
       .APB_DW              (APB_DW),
       .BCM_F_SYNC_TYPE_C2P (BCM_F_SYNC_TYPE_C2P),
       .BCM_R_SYNC_TYPE_C2P (BCM_R_SYNC_TYPE_C2P),
       .BCM_F_SYNC_TYPE_P2C (BCM_F_SYNC_TYPE_P2C),
       .BCM_R_SYNC_TYPE_P2C (BCM_R_SYNC_TYPE_P2C),
       .REG_OUTPUTS_C2P     (REG_OUTPUTS_C2P),
       .REG_OUTPUTS_P2C     (REG_OUTPUTS_P2C),
       .BCM_VERIF_EN        (BCM_VERIF_EN)
       )
   U_apb_slvtop
     (.pclk      (pclk),
      .presetn   (presetn),
      .paddr     (paddr[`UMCTL2_APB_AW-1:2]),
      .pwdata    (pwdata),
      .pwrite    (pwrite),
      .psel      (psel),
      .penable   (penable),
      .pready    (pready),
      .prdata    (prdata),
      .pslverr   (pslverr)


      ,.core_ddrc_core_clk    (core_ddrc_core_clk)
      ,.sync_core_ddrc_rstn   (sync_core_ddrc_rstn)
      ,.core_ddrc_rstn        (core_ddrc_rstn)

      ,.aclk_0                (aclk_0)
      ,.sync_aresetn_0        (sync_aresetn_0)
     `ifndef SYNTHESIS
      ,.aresetn_0             (aresetn_0)
     `endif //SYNTHESIS


















      ,.static_wr_en_core_ddrc_core_clk      (static_wr_en_core)
      ,.quasi_dyn_wr_en_core_ddrc_core_clk   (quasi_dyn_wr_en_core)
//`ifdef UMCTL2_OCECC_EN_1
//      ,.quasi_dyn_wr_en_pclk                 (quasi_dyn_wr_en_pclk)
//`endif // UMCTL2_OCPAR_OR_OCECC_EN_1


      ,.static_wr_en_aclk_0                  (static_wr_en_aclk_0)
      ,.quasi_dyn_wr_en_aclk_0               (quasi_dyn_wr_en_aclk_0)

   //------------------------
   // Register REGB_DDRC_CH0.MSTR0
   //------------------------
   ,.reg_ddrc_lpddr4 (reg_ddrc_lpddr4) // @core_ddrc_core_clk
   ,.reg_apb_lpddr4 (reg_apb_lpddr4) // @pclk
   ,.reg_arba0_lpddr4 (reg_arba0_lpddr4) // @aclk_0
   ,.reg_ddrc_lpddr5 (reg_ddrc_lpddr5) // @core_ddrc_core_clk
   ,.reg_apb_lpddr5 (reg_apb_lpddr5) // @pclk
   ,.reg_arba0_lpddr5 (reg_arba0_lpddr5) // @aclk_0
   ,.reg_ddrc_en_2t_timing_mode (reg_ddrc_en_2t_timing_mode) // @core_ddrc_core_clk
   ,.reg_apb_en_2t_timing_mode (reg_apb_en_2t_timing_mode) // @pclk
   ,.reg_arba0_en_2t_timing_mode (reg_arba0_en_2t_timing_mode) // @aclk_0
   ,.reg_ddrc_data_bus_width (reg_ddrc_data_bus_width) // @core_ddrc_core_clk
   ,.reg_apb_data_bus_width (reg_apb_data_bus_width) // @pclk
   ,.reg_arba0_data_bus_width (reg_arba0_data_bus_width) // @aclk_0
   ,.reg_ddrc_burst_rdwr (reg_ddrc_burst_rdwr) // @core_ddrc_core_clk
   ,.reg_apb_burst_rdwr (reg_apb_burst_rdwr) // @pclk
   ,.reg_arba0_burst_rdwr (reg_arba0_burst_rdwr) // @aclk_0
   //------------------------
   // Register REGB_DDRC_CH0.MSTR4
   //------------------------
   ,.reg_ddrc_wck_on (reg_ddrc_wck_on) // @core_ddrc_core_clk
   ,.reg_ddrc_wck_suspend_en (reg_ddrc_wck_suspend_en) // @core_ddrc_core_clk
   ,.reg_ddrc_ws_off_en (reg_ddrc_ws_off_en) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.STAT
   //------------------------
   ,.ddrc_reg_operating_mode (ddrc_reg_operating_mode) // @core_ddrc_core_clk
   ,.ddrc_reg_selfref_type (ddrc_reg_selfref_type) // @core_ddrc_core_clk
   ,.ddrc_reg_selfref_state (ddrc_reg_selfref_state) // @core_ddrc_core_clk
   ,.ddrc_reg_selfref_cam_not_empty (ddrc_reg_selfref_cam_not_empty) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL0
   //------------------------
   ,.reg_ddrc_mr_type (reg_ddrc_mr_type) // @core_ddrc_core_clk
   ,.reg_ddrc_sw_init_int (reg_ddrc_sw_init_int) // @core_ddrc_core_clk
   ,.reg_ddrc_mr_rank (reg_ddrc_mr_rank) // @core_ddrc_core_clk
   ,.reg_ddrc_mr_addr (reg_ddrc_mr_addr) // @core_ddrc_core_clk
   ,.reg_ddrc_mrr_done_clr (reg_ddrc_mrr_done_clr) // @core_ddrc_core_clk
   ,.reg_ddrc_mr_wr (reg_ddrc_mr_wr) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRCTRL1
   //------------------------
   ,.reg_ddrc_mr_data (reg_ddrc_mr_data) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRSTAT
   //------------------------
   ,.ddrc_reg_mr_wr_busy (ddrc_reg_mr_wr_busy) // @core_ddrc_core_clk
   ,.ddrc_reg_mrr_done (ddrc_reg_mrr_done) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA0
   //------------------------
   ,.ddrc_reg_mrr_data_lwr (ddrc_reg_mrr_data_lwr) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.MRRDATA1
   //------------------------
   ,.ddrc_reg_mrr_data_upr (ddrc_reg_mrr_data_upr) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL0
   //------------------------
   ,.reg_ddrc_derate_enable (reg_ddrc_derate_enable) // @core_ddrc_core_clk
   ,.reg_ddrc_lpddr4_refresh_mode (reg_ddrc_lpddr4_refresh_mode) // @core_ddrc_core_clk
   ,.reg_ddrc_derate_mr4_pause_fc (reg_ddrc_derate_mr4_pause_fc) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_trefi_x6x8 (reg_ddrc_dis_trefi_x6x8) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_trefi_x0125 (reg_ddrc_dis_trefi_x0125) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL1
   //------------------------
   ,.reg_ddrc_active_derate_byte_rank0 (reg_ddrc_active_derate_byte_rank0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL5
   //------------------------
   ,.reg_ddrc_derate_temp_limit_intr_en (reg_ddrc_derate_temp_limit_intr_en) // @pclk
   ,.reg_ddrc_derate_temp_limit_intr_clr (reg_ddrc_derate_temp_limit_intr_clr) // @pclk
   ,.reg_ddrc_derate_temp_limit_intr_force (reg_ddrc_derate_temp_limit_intr_force) // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.DERATECTL6
   //------------------------
   ,.reg_ddrc_derate_mr4_tuf_dis (reg_ddrc_derate_mr4_tuf_dis) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATESTAT0
   //------------------------
   ,.ddrc_reg_derate_temp_limit_intr (ddrc_reg_derate_temp_limit_intr) // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGCTL
   //------------------------
   ,.reg_ddrc_dbg_mr4_grp_sel (reg_ddrc_dbg_mr4_grp_sel) // @core_ddrc_core_clk
   ,.reg_ddrc_dbg_mr4_rank_sel (reg_ddrc_dbg_mr4_rank_sel) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DERATEDBGSTAT
   //------------------------
   ,.ddrc_reg_dbg_mr4_byte0 (ddrc_reg_dbg_mr4_byte0) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_mr4_byte1 (ddrc_reg_dbg_mr4_byte1) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_mr4_byte2 (ddrc_reg_dbg_mr4_byte2) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_mr4_byte3 (ddrc_reg_dbg_mr4_byte3) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.PWRCTL
   //------------------------
   ,.reg_ddrc_selfref_en (reg_ddrc_selfref_en) // @core_ddrc_core_clk
   ,.reg_ddrc_powerdown_en (reg_ddrc_powerdown_en) // @core_ddrc_core_clk
   ,.reg_ddrc_en_dfi_dram_clk_disable (reg_ddrc_en_dfi_dram_clk_disable) // @core_ddrc_core_clk
   ,.reg_ddrc_selfref_sw (reg_ddrc_selfref_sw) // @core_ddrc_core_clk
   ,.reg_ddrc_stay_in_selfref (reg_ddrc_stay_in_selfref) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_cam_drain_selfref (reg_ddrc_dis_cam_drain_selfref) // @core_ddrc_core_clk
   ,.reg_ddrc_lpddr4_sr_allowed (reg_ddrc_lpddr4_sr_allowed) // @core_ddrc_core_clk
   ,.reg_ddrc_dsm_en (reg_ddrc_dsm_en) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.HWLPCTL
   //------------------------
   ,.reg_ddrc_hw_lp_en (reg_ddrc_hw_lp_en) // @core_ddrc_core_clk
   ,.reg_ddrc_hw_lp_exit_idle_en (reg_ddrc_hw_lp_exit_idle_en) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.CLKGATECTL
   //------------------------
   ,.reg_ddrc_bsm_clk_on (reg_ddrc_bsm_clk_on) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.RFSHMOD0
   //------------------------
   ,.reg_ddrc_refresh_burst (reg_ddrc_refresh_burst) // @core_ddrc_core_clk
   ,.reg_ddrc_auto_refab_en (reg_ddrc_auto_refab_en) // @core_ddrc_core_clk
   ,.reg_ddrc_per_bank_refresh (reg_ddrc_per_bank_refresh) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.RFSHCTL0
   //------------------------
   ,.reg_ddrc_dis_auto_refresh (reg_ddrc_dis_auto_refresh) // @core_ddrc_core_clk
   ,.reg_ddrc_refresh_update_level (reg_ddrc_refresh_update_level) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL0
   //------------------------
   ,.reg_ddrc_zq_resistor_shared (reg_ddrc_zq_resistor_shared) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_auto_zq (reg_ddrc_dis_auto_zq) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL1
   //------------------------
   ,.reg_ddrc_zq_reset (reg_ddrc_zq_reset) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQCTL2
   //------------------------
   ,.reg_ddrc_dis_srx_zqcl (reg_ddrc_dis_srx_zqcl) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ZQSTAT
   //------------------------
   ,.ddrc_reg_zq_reset_busy (ddrc_reg_zq_reset_busy) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCRUNTIME
   //------------------------
   ,.reg_ddrc_dqsosc_runtime (reg_ddrc_dqsosc_runtime) // @core_ddrc_core_clk
   ,.reg_ddrc_wck2dqo_runtime (reg_ddrc_wck2dqo_runtime) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCSTAT0
   //------------------------
   ,.ddrc_reg_dqsosc_state (ddrc_reg_dqsosc_state) // @core_ddrc_core_clk
   ,.ddrc_reg_dqsosc_per_rank_stat (ddrc_reg_dqsosc_per_rank_stat) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DQSOSCCFG0
   //------------------------
   ,.reg_ddrc_dis_dqsosc_srx (reg_ddrc_dis_dqsosc_srx) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED0
   //------------------------
   ,.reg_ddrc_prefer_write (reg_ddrc_prefer_write) // @core_ddrc_core_clk
   ,.reg_ddrc_pageclose (reg_ddrc_pageclose) // @core_ddrc_core_clk
   ,.reg_ddrc_opt_wrcam_fill_level (reg_ddrc_opt_wrcam_fill_level) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre) // @core_ddrc_core_clk
   ,.reg_ddrc_autopre_rmw (reg_ddrc_autopre_rmw) // @core_ddrc_core_clk
   ,.reg_ddrc_lpr_num_entries (reg_ddrc_lpr_num_entries) // @core_ddrc_core_clk
   ,.reg_ddrc_lpddr4_opt_act_timing (reg_ddrc_lpddr4_opt_act_timing) // @core_ddrc_core_clk
   ,.reg_ddrc_lpddr5_opt_act_timing (reg_ddrc_lpddr5_opt_act_timing) // @core_ddrc_core_clk
   ,.reg_ddrc_prefer_read (reg_ddrc_prefer_read) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_speculative_act (reg_ddrc_dis_speculative_act) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED1
   //------------------------
   ,.reg_ddrc_delay_switch_write (reg_ddrc_delay_switch_write) // @core_ddrc_core_clk
   ,.reg_ddrc_page_hit_limit_wr (reg_ddrc_page_hit_limit_wr) // @core_ddrc_core_clk
   ,.reg_ddrc_page_hit_limit_rd (reg_ddrc_page_hit_limit_rd) // @core_ddrc_core_clk
   ,.reg_ddrc_opt_hit_gt_hpr (reg_ddrc_opt_hit_gt_hpr) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED3
   //------------------------
   ,.reg_ddrc_wrcam_lowthresh (reg_ddrc_wrcam_lowthresh) // @core_ddrc_core_clk
   ,.reg_ddrc_wrcam_highthresh (reg_ddrc_wrcam_highthresh) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_pghit_num_thresh (reg_ddrc_wr_pghit_num_thresh) // @core_ddrc_core_clk
   ,.reg_ddrc_rd_pghit_num_thresh (reg_ddrc_rd_pghit_num_thresh) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SCHED4
   //------------------------
   ,.reg_ddrc_rd_act_idle_gap (reg_ddrc_rd_act_idle_gap) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_act_idle_gap (reg_ddrc_wr_act_idle_gap) // @core_ddrc_core_clk
   ,.reg_ddrc_rd_page_exp_cycles (reg_ddrc_rd_page_exp_cycles) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_page_exp_cycles (reg_ddrc_wr_page_exp_cycles) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFILPCFG0
   //------------------------
   ,.reg_ddrc_dfi_lp_en_pd (reg_ddrc_dfi_lp_en_pd) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_lp_en_sr (reg_ddrc_dfi_lp_en_sr) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_lp_en_dsm (reg_ddrc_dfi_lp_en_dsm) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_lp_en_data (reg_ddrc_dfi_lp_en_data) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_lp_data_req_en (reg_ddrc_dfi_lp_data_req_en) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFIUPD0
   //------------------------
   ,.reg_ddrc_dfi_phyupd_en (reg_ddrc_dfi_phyupd_en) // @core_ddrc_core_clk
   ,.reg_ddrc_ctrlupd_pre_srx (reg_ddrc_ctrlupd_pre_srx) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_auto_ctrlupd_srx (reg_ddrc_dis_auto_ctrlupd_srx) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_auto_ctrlupd (reg_ddrc_dis_auto_ctrlupd) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFIMISC
   //------------------------
   ,.reg_ddrc_dfi_init_complete_en (reg_ddrc_dfi_init_complete_en) // @core_ddrc_core_clk
   ,.reg_ddrc_phy_dbi_mode (reg_ddrc_phy_dbi_mode) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_data_cs_polarity (reg_ddrc_dfi_data_cs_polarity) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_init_start (reg_ddrc_dfi_init_start) // @core_ddrc_core_clk
   ,.reg_ddrc_lp_optimized_write (reg_ddrc_lp_optimized_write) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_frequency (reg_ddrc_dfi_frequency) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_freq_fsp (reg_ddrc_dfi_freq_fsp) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_channel_mode (reg_ddrc_dfi_channel_mode) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFISTAT
   //------------------------
   ,.ddrc_reg_dfi_init_complete (ddrc_reg_dfi_init_complete) // @core_ddrc_core_clk
   ,.ddrc_reg_dfi_lp_ctrl_ack_stat (ddrc_reg_dfi_lp_ctrl_ack_stat) // @core_ddrc_core_clk
   ,.ddrc_reg_dfi_lp_data_ack_stat (ddrc_reg_dfi_lp_data_ack_stat) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFIPHYMSTR
   //------------------------
   ,.reg_ddrc_dfi_phymstr_en (reg_ddrc_dfi_phymstr_en) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_phymstr_blk_ref_x32 (reg_ddrc_dfi_phymstr_blk_ref_x32) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGCTL0
   //------------------------
   ,.reg_ddrc_dfi0_ctrlmsg_data (reg_ddrc_dfi0_ctrlmsg_data) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi0_ctrlmsg_cmd (reg_ddrc_dfi0_ctrlmsg_cmd) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi0_ctrlmsg_tout_clr (reg_ddrc_dfi0_ctrlmsg_tout_clr) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi0_ctrlmsg_req (reg_ddrc_dfi0_ctrlmsg_req) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DFI0MSGSTAT0
   //------------------------
   ,.ddrc_reg_dfi0_ctrlmsg_req_busy (ddrc_reg_dfi0_ctrlmsg_req_busy) // @core_ddrc_core_clk
   ,.ddrc_reg_dfi0_ctrlmsg_resp_tout (ddrc_reg_dfi0_ctrlmsg_resp_tout) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.POISONCFG
   //------------------------
   ,.reg_ddrc_wr_poison_slverr_en (reg_ddrc_wr_poison_slverr_en) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_poison_intr_en (reg_ddrc_wr_poison_intr_en) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_poison_intr_clr (reg_ddrc_wr_poison_intr_clr) // @core_ddrc_core_clk
   ,.reg_ddrc_rd_poison_slverr_en (reg_ddrc_rd_poison_slverr_en) // @core_ddrc_core_clk
   ,.reg_ddrc_rd_poison_intr_en (reg_ddrc_rd_poison_intr_en) // @core_ddrc_core_clk
   ,.reg_ddrc_rd_poison_intr_clr (reg_ddrc_rd_poison_intr_clr) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.POISONSTAT
   //------------------------
   ,.ddrc_reg_wr_poison_intr_0 (ddrc_reg_wr_poison_intr_0) // @core_ddrc_core_clk
   ,.ddrc_reg_rd_poison_intr_0 (ddrc_reg_rd_poison_intr_0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL0
   //------------------------
   ,.reg_ddrc_dis_wc (reg_ddrc_dis_wc) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRL1
   //------------------------
   ,.reg_ddrc_dis_dq (reg_ddrc_dis_dq) // @core_ddrc_core_clk
   ,.reg_ddrc_dis_hif (reg_ddrc_dis_hif) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCAM
   //------------------------
   ,.ddrc_reg_dbg_hpr_q_depth (ddrc_reg_dbg_hpr_q_depth) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_lpr_q_depth (ddrc_reg_dbg_lpr_q_depth) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_w_q_depth (ddrc_reg_dbg_w_q_depth) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_stall (ddrc_reg_dbg_stall) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_rd_q_empty (ddrc_reg_dbg_rd_q_empty) // @core_ddrc_core_clk
   ,.ddrc_reg_dbg_wr_q_empty (ddrc_reg_dbg_wr_q_empty) // @core_ddrc_core_clk
   ,.ddrc_reg_rd_data_pipeline_empty (ddrc_reg_rd_data_pipeline_empty) // @core_ddrc_core_clk
   ,.ddrc_reg_wr_data_pipeline_empty (ddrc_reg_wr_data_pipeline_empty) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLCMD
   //------------------------
   ,.reg_ddrc_zq_calib_short (reg_ddrc_zq_calib_short) // @core_ddrc_core_clk
   ,.reg_ddrc_ctrlupd (reg_ddrc_ctrlupd) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPCTRLSTAT
   //------------------------
   ,.ddrc_reg_zq_calib_short_busy (ddrc_reg_zq_calib_short_busy) // @core_ddrc_core_clk
   ,.ddrc_reg_ctrlupd_busy (ddrc_reg_ctrlupd_busy) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPREFCTRL0
   //------------------------
   ,.reg_ddrc_rank0_refresh (reg_ddrc_rank0_refresh) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.OPREFSTAT0
   //------------------------
   ,.ddrc_reg_rank0_refresh_busy (ddrc_reg_rank0_refresh_busy) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SWCTL
   //------------------------
   ,.reg_ddrc_sw_done (reg_ddrc_sw_done) // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.SWSTAT
   //------------------------
   ,.ddrc_reg_sw_done_ack (ddrc_reg_sw_done_ack) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DBICTL
   //------------------------
   ,.reg_ddrc_dm_en (reg_ddrc_dm_en) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_dbi_en (reg_ddrc_wr_dbi_en) // @core_ddrc_core_clk
   ,.reg_ddrc_rd_dbi_en (reg_ddrc_rd_dbi_en) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.ODTMAP
   //------------------------
   ,.reg_ddrc_rank0_wr_odt (reg_ddrc_rank0_wr_odt) // @core_ddrc_core_clk
   ,.reg_ddrc_rank0_rd_odt (reg_ddrc_rank0_rd_odt) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DATACTL0
   //------------------------
   ,.reg_ddrc_rd_data_copy_en (reg_ddrc_rd_data_copy_en) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_data_copy_en (reg_ddrc_wr_data_copy_en) // @core_ddrc_core_clk
   ,.reg_ddrc_wr_data_x_en (reg_ddrc_wr_data_x_en) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.SWCTLSTATIC
   //------------------------
   ,.reg_ddrc_sw_static_unlock (reg_ddrc_sw_static_unlock) // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG0
   //------------------------
   ,.reg_ddrc_pre_cke_x1024 (reg_ddrc_pre_cke_x1024) // @core_ddrc_core_clk
   ,.reg_ddrc_post_cke_x1024 (reg_ddrc_post_cke_x1024) // @core_ddrc_core_clk
   ,.reg_ddrc_skip_dram_init (reg_ddrc_skip_dram_init) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.INITTMG1
   //------------------------
   ,.reg_ddrc_dram_rstn_x1024 (reg_ddrc_dram_rstn_x1024) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_NUMBER
   //------------------------
   ,.ddrc_reg_ver_number (ddrc_reg_ver_number) // @pclk
   //------------------------
   // Register REGB_DDRC_CH0.DDRCTL_VER_TYPE
   //------------------------
   ,.ddrc_reg_ver_type (ddrc_reg_ver_type) // @pclk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP3
   //------------------------
   ,.reg_ddrc_addrmap_bank_b0_map0 (reg_ddrc_addrmap_bank_b0_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_bank_b1_map0 (reg_ddrc_addrmap_bank_b1_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_bank_b2_map0 (reg_ddrc_addrmap_bank_b2_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP4
   //------------------------
   ,.reg_ddrc_addrmap_bg_b0_map0 (reg_ddrc_addrmap_bg_b0_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_bg_b1_map0 (reg_ddrc_addrmap_bg_b1_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP5
   //------------------------
   ,.reg_ddrc_addrmap_col_b7_map0 (reg_ddrc_addrmap_col_b7_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_col_b8_map0 (reg_ddrc_addrmap_col_b8_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_col_b9_map0 (reg_ddrc_addrmap_col_b9_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_col_b10_map0 (reg_ddrc_addrmap_col_b10_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP6
   //------------------------
   ,.reg_ddrc_addrmap_col_b3_map0 (reg_ddrc_addrmap_col_b3_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_col_b4_map0 (reg_ddrc_addrmap_col_b4_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_col_b5_map0 (reg_ddrc_addrmap_col_b5_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_col_b6_map0 (reg_ddrc_addrmap_col_b6_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP7
   //------------------------
   ,.reg_ddrc_addrmap_row_b14_map0 (reg_ddrc_addrmap_row_b14_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b15_map0 (reg_ddrc_addrmap_row_b15_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b16_map0 (reg_ddrc_addrmap_row_b16_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b17_map0 (reg_ddrc_addrmap_row_b17_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP8
   //------------------------
   ,.reg_ddrc_addrmap_row_b10_map0 (reg_ddrc_addrmap_row_b10_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b11_map0 (reg_ddrc_addrmap_row_b11_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b12_map0 (reg_ddrc_addrmap_row_b12_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b13_map0 (reg_ddrc_addrmap_row_b13_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP9
   //------------------------
   ,.reg_ddrc_addrmap_row_b6_map0 (reg_ddrc_addrmap_row_b6_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b7_map0 (reg_ddrc_addrmap_row_b7_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b8_map0 (reg_ddrc_addrmap_row_b8_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b9_map0 (reg_ddrc_addrmap_row_b9_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP10
   //------------------------
   ,.reg_ddrc_addrmap_row_b2_map0 (reg_ddrc_addrmap_row_b2_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b3_map0 (reg_ddrc_addrmap_row_b3_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b4_map0 (reg_ddrc_addrmap_row_b4_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b5_map0 (reg_ddrc_addrmap_row_b5_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP11
   //------------------------
   ,.reg_ddrc_addrmap_row_b0_map0 (reg_ddrc_addrmap_row_b0_map0) // @core_ddrc_core_clk
   ,.reg_ddrc_addrmap_row_b1_map0 (reg_ddrc_addrmap_row_b1_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ADDR_MAP0.ADDRMAP12
   //------------------------
   ,.reg_ddrc_nonbinary_device_density_map0 (reg_ddrc_nonbinary_device_density_map0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCCFG
   //------------------------
   ,.reg_arb_go2critical_en_port0 (reg_arb_go2critical_en_port0) // @core_ddrc_core_clk
   ,.reg_arb_pagematch_limit_port0 (reg_arb_pagematch_limit_port0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCFGR
   //------------------------
   ,.reg_arb_rd_port_priority_port0 (reg_arb_rd_port_priority_port0) // @core_ddrc_core_clk
   ,.reg_arb_rd_port_aging_en_port0 (reg_arb_rd_port_aging_en_port0) // @core_ddrc_core_clk
   ,.reg_arb_rd_port_urgent_en_port0 (reg_arb_rd_port_urgent_en_port0) // @core_ddrc_core_clk
   ,.reg_arb_rd_port_pagematch_en_port0 (reg_arb_rd_port_pagematch_en_port0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCFGW
   //------------------------
   ,.reg_arb_wr_port_priority_port0 (reg_arb_wr_port_priority_port0) // @core_ddrc_core_clk
   ,.reg_arb_wr_port_aging_en_port0 (reg_arb_wr_port_aging_en_port0) // @core_ddrc_core_clk
   ,.reg_arb_wr_port_urgent_en_port0 (reg_arb_wr_port_urgent_en_port0) // @core_ddrc_core_clk
   ,.reg_arb_wr_port_pagematch_en_port0 (reg_arb_wr_port_pagematch_en_port0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCTRL
   //------------------------
   ,.reg_arb_port_en_port0 (reg_arb_port_en_port0) // @core_ddrc_core_clk
   ,.reg_apb_port_en_port0 (reg_apb_port_en_port0) // @pclk
   ,.reg_arba0_port_en_port0 (reg_arba0_port_en_port0) // @aclk_0
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS0
   //------------------------
   ,.reg_arba0_rqos_map_level1_port0 (reg_arba0_rqos_map_level1_port0) // @aclk_0
   ,.reg_arba0_rqos_map_region0_port0 (reg_arba0_rqos_map_region0_port0) // @aclk_0
   ,.reg_arba0_rqos_map_region1_port0 (reg_arba0_rqos_map_region1_port0) // @aclk_0
   //------------------------
   // Register REGB_ARB_PORT0.PCFGQOS1
   //------------------------
   ,.reg_arb_rqos_map_timeoutb_port0 (reg_arb_rqos_map_timeoutb_port0) // @core_ddrc_core_clk
   ,.reg_arb_rqos_map_timeoutr_port0 (reg_arb_rqos_map_timeoutr_port0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS0
   //------------------------
   ,.reg_arba0_wqos_map_level1_port0 (reg_arba0_wqos_map_level1_port0) // @aclk_0
   ,.reg_arba0_wqos_map_level2_port0 (reg_arba0_wqos_map_level2_port0) // @aclk_0
   ,.reg_arba0_wqos_map_region0_port0 (reg_arba0_wqos_map_region0_port0) // @aclk_0
   ,.reg_arba0_wqos_map_region1_port0 (reg_arba0_wqos_map_region1_port0) // @aclk_0
   ,.reg_arba0_wqos_map_region2_port0 (reg_arba0_wqos_map_region2_port0) // @aclk_0
   //------------------------
   // Register REGB_ARB_PORT0.PCFGWQOS1
   //------------------------
   ,.reg_arb_wqos_map_timeout1_port0 (reg_arb_wqos_map_timeout1_port0) // @core_ddrc_core_clk
   ,.reg_arb_wqos_map_timeout2_port0 (reg_arb_wqos_map_timeout2_port0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_ARB_PORT0.PSTAT
   //------------------------
   ,.arb_reg_rd_port_busy_0_port0 (arb_reg_rd_port_busy_0_port0) // @aclk_0
   ,.arb_reg_wr_port_busy_0_port0 (arb_reg_wr_port_busy_0_port0) // @aclk_0
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG0
   //------------------------
   ,.reg_ddrc_t_ras_min_freq0 (reg_ddrc_t_ras_min_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_ras_max_freq0 (reg_ddrc_t_ras_max_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_faw_freq0 (reg_ddrc_t_faw_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_wr2pre_freq0 (reg_ddrc_wr2pre_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG1
   //------------------------
   ,.reg_ddrc_t_rc_freq0 (reg_ddrc_t_rc_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_rd2pre_freq0 (reg_ddrc_rd2pre_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_xp_freq0 (reg_ddrc_t_xp_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG2
   //------------------------
   ,.reg_ddrc_wr2rd_freq0 (reg_ddrc_wr2rd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_rd2wr_freq0 (reg_ddrc_rd2wr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_read_latency_freq0 (reg_ddrc_read_latency_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_write_latency_freq0 (reg_ddrc_write_latency_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG3
   //------------------------
   ,.reg_ddrc_wr2mr_freq0 (reg_ddrc_wr2mr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_rd2mr_freq0 (reg_ddrc_rd2mr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_mr_freq0 (reg_ddrc_t_mr_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG4
   //------------------------
   ,.reg_ddrc_t_rp_freq0 (reg_ddrc_t_rp_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_rrd_freq0 (reg_ddrc_t_rrd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_ccd_freq0 (reg_ddrc_t_ccd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_rcd_freq0 (reg_ddrc_t_rcd_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG5
   //------------------------
   ,.reg_ddrc_t_cke_freq0 (reg_ddrc_t_cke_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_ckesr_freq0 (reg_ddrc_t_ckesr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_cksre_freq0 (reg_ddrc_t_cksre_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_cksrx_freq0 (reg_ddrc_t_cksrx_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG6
   //------------------------
   ,.reg_ddrc_t_ckcsx_freq0 (reg_ddrc_t_ckcsx_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG7
   //------------------------
   ,.reg_ddrc_t_csh_freq0 (reg_ddrc_t_csh_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG9
   //------------------------
   ,.reg_ddrc_wr2rd_s_freq0 (reg_ddrc_wr2rd_s_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_rrd_s_freq0 (reg_ddrc_t_rrd_s_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_ccd_s_freq0 (reg_ddrc_t_ccd_s_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG12
   //------------------------
   ,.reg_ddrc_t_cmdcke_freq0 (reg_ddrc_t_cmdcke_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG13
   //------------------------
   ,.reg_ddrc_t_ppd_freq0 (reg_ddrc_t_ppd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_ccd_mw_freq0 (reg_ddrc_t_ccd_mw_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_odtloff_freq0 (reg_ddrc_odtloff_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG14
   //------------------------
   ,.reg_ddrc_t_xsr_freq0 (reg_ddrc_t_xsr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_osco_freq0 (reg_ddrc_t_osco_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG23
   //------------------------
   ,.reg_ddrc_t_pdn_freq0 (reg_ddrc_t_pdn_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_xsr_dsm_x1024_freq0 (reg_ddrc_t_xsr_dsm_x1024_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG24
   //------------------------
   ,.reg_ddrc_max_wr_sync_freq0 (reg_ddrc_max_wr_sync_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_max_rd_sync_freq0 (reg_ddrc_max_rd_sync_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_rd2wr_s_freq0 (reg_ddrc_rd2wr_s_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_bank_org_freq0 (reg_ddrc_bank_org_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG25
   //------------------------
   ,.reg_ddrc_rda2pre_freq0 (reg_ddrc_rda2pre_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_wra2pre_freq0 (reg_ddrc_wra2pre_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0 (reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DRAMSET1TMG30
   //------------------------
   ,.reg_ddrc_mrr2rd_freq0 (reg_ddrc_mrr2rd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_mrr2wr_freq0 (reg_ddrc_mrr2wr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_mrr2mrw_freq0 (reg_ddrc_mrr2mrw_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR0
   //------------------------
   ,.reg_ddrc_emr_freq0 (reg_ddrc_emr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_mr_freq0 (reg_ddrc_mr_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR1
   //------------------------
   ,.reg_ddrc_emr3_freq0 (reg_ddrc_emr3_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_emr2_freq0 (reg_ddrc_emr2_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR2
   //------------------------
   ,.reg_ddrc_mr5_freq0 (reg_ddrc_mr5_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_mr4_freq0 (reg_ddrc_mr4_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.INITMR3
   //------------------------
   ,.reg_ddrc_mr6_freq0 (reg_ddrc_mr6_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_mr22_freq0 (reg_ddrc_mr22_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG0
   //------------------------
   ,.reg_ddrc_dfi_tphy_wrlat_freq0 (reg_ddrc_dfi_tphy_wrlat_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_tphy_wrdata_freq0 (reg_ddrc_dfi_tphy_wrdata_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_t_rddata_en_freq0 (reg_ddrc_dfi_t_rddata_en_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_t_ctrl_delay_freq0 (reg_ddrc_dfi_t_ctrl_delay_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG1
   //------------------------
   ,.reg_ddrc_dfi_t_dram_clk_enable_freq0 (reg_ddrc_dfi_t_dram_clk_enable_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_t_dram_clk_disable_freq0 (reg_ddrc_dfi_t_dram_clk_disable_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_t_wrdata_delay_freq0 (reg_ddrc_dfi_t_wrdata_delay_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG2
   //------------------------
   ,.reg_ddrc_dfi_tphy_wrcslat_freq0 (reg_ddrc_dfi_tphy_wrcslat_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_tphy_rdcslat_freq0 (reg_ddrc_dfi_tphy_rdcslat_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_twck_delay_freq0 (reg_ddrc_dfi_twck_delay_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG4
   //------------------------
   ,.reg_ddrc_dfi_twck_dis_freq0 (reg_ddrc_dfi_twck_dis_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_twck_en_wr_freq0 (reg_ddrc_dfi_twck_en_wr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_twck_en_rd_freq0 (reg_ddrc_dfi_twck_en_rd_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFITMG5
   //------------------------
   ,.reg_ddrc_dfi_twck_toggle_post_freq0 (reg_ddrc_dfi_twck_toggle_post_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_twck_toggle_cs_freq0 (reg_ddrc_dfi_twck_toggle_cs_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_twck_toggle_freq0 (reg_ddrc_dfi_twck_toggle_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_twck_fast_toggle_freq0 (reg_ddrc_dfi_twck_fast_toggle_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG0
   //------------------------
   ,.reg_ddrc_dfi_lp_wakeup_pd_freq0 (reg_ddrc_dfi_lp_wakeup_pd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_lp_wakeup_sr_freq0 (reg_ddrc_dfi_lp_wakeup_sr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_lp_wakeup_dsm_freq0 (reg_ddrc_dfi_lp_wakeup_dsm_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFILPTMG1
   //------------------------
   ,.reg_ddrc_dfi_lp_wakeup_data_freq0 (reg_ddrc_dfi_lp_wakeup_data_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_tlp_resp_freq0 (reg_ddrc_dfi_tlp_resp_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG0
   //------------------------
   ,.reg_ddrc_dfi_t_ctrlup_min_freq0 (reg_ddrc_dfi_t_ctrlup_min_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_t_ctrlup_max_freq0 (reg_ddrc_dfi_t_ctrlup_max_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFIUPDTMG1
   //------------------------
   ,.reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0 (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0 (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DFIMSGTMG0
   //------------------------
   ,.reg_ddrc_dfi_t_ctrlmsg_resp_freq0 (reg_ddrc_dfi_t_ctrlmsg_resp_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG0
   //------------------------
   ,.reg_ddrc_t_refi_x1_x32_freq0 (reg_ddrc_t_refi_x1_x32_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_refresh_to_x1_x32_freq0 (reg_ddrc_refresh_to_x1_x32_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_refresh_margin_freq0 (reg_ddrc_refresh_margin_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_refi_x1_sel_freq0 (reg_ddrc_t_refi_x1_sel_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG1
   //------------------------
   ,.reg_ddrc_t_rfc_min_freq0 (reg_ddrc_t_rfc_min_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_rfc_min_ab_freq0 (reg_ddrc_t_rfc_min_ab_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG2
   //------------------------
   ,.reg_ddrc_t_pbr2pbr_freq0 (reg_ddrc_t_pbr2pbr_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_pbr2act_freq0 (reg_ddrc_t_pbr2act_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.RFSHSET1TMG3
   //------------------------
   ,.reg_ddrc_refresh_to_ab_x32_freq0 (reg_ddrc_refresh_to_ab_x32_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG0
   //------------------------
   ,.reg_ddrc_t_zq_long_nop_freq0 (reg_ddrc_t_zq_long_nop_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_zq_short_nop_freq0 (reg_ddrc_t_zq_short_nop_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.ZQSET1TMG1
   //------------------------
   ,.reg_ddrc_t_zq_short_interval_x1024_freq0 (reg_ddrc_t_zq_short_interval_x1024_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_t_zq_reset_nop_freq0 (reg_ddrc_t_zq_reset_nop_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DQSOSCCTL0
   //------------------------
   ,.reg_ddrc_dqsosc_enable_freq0 (reg_ddrc_dqsosc_enable_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dqsosc_interval_unit_freq0 (reg_ddrc_dqsosc_interval_unit_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_dqsosc_interval_freq0 (reg_ddrc_dqsosc_interval_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEINT
   //------------------------
   ,.reg_ddrc_mr4_read_interval_freq0 (reg_ddrc_mr4_read_interval_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL0
   //------------------------
   ,.reg_ddrc_derated_t_rrd_freq0 (reg_ddrc_derated_t_rrd_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_derated_t_rp_freq0 (reg_ddrc_derated_t_rp_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_derated_t_ras_min_freq0 (reg_ddrc_derated_t_ras_min_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_derated_t_rcd_freq0 (reg_ddrc_derated_t_rcd_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.DERATEVAL1
   //------------------------
   ,.reg_ddrc_derated_t_rc_freq0 (reg_ddrc_derated_t_rc_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.HWLPTMG0
   //------------------------
   ,.reg_ddrc_hw_lp_idle_x32_freq0 (reg_ddrc_hw_lp_idle_x32_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.SCHEDTMG0
   //------------------------
   ,.reg_ddrc_pageclose_timer_freq0 (reg_ddrc_pageclose_timer_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_rdwr_idle_gap_freq0 (reg_ddrc_rdwr_idle_gap_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PERFHPR1
   //------------------------
   ,.reg_ddrc_hpr_max_starve_freq0 (reg_ddrc_hpr_max_starve_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_hpr_xact_run_length_freq0 (reg_ddrc_hpr_xact_run_length_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PERFLPR1
   //------------------------
   ,.reg_ddrc_lpr_max_starve_freq0 (reg_ddrc_lpr_max_starve_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_lpr_xact_run_length_freq0 (reg_ddrc_lpr_xact_run_length_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PERFWR1
   //------------------------
   ,.reg_ddrc_w_max_starve_freq0 (reg_ddrc_w_max_starve_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_w_xact_run_length_freq0 (reg_ddrc_w_xact_run_length_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.TMGCFG
   //------------------------
   ,.reg_ddrc_frequency_ratio_freq0 (reg_ddrc_frequency_ratio_freq0) // @core_ddrc_core_clk
   //------------------------
   // Register REGB_FREQ0_CH0.PWRTMG
   //------------------------
   ,.reg_ddrc_powerdown_to_x32_freq0 (reg_ddrc_powerdown_to_x32_freq0) // @core_ddrc_core_clk
   ,.reg_ddrc_selfref_to_x32_freq0 (reg_ddrc_selfref_to_x32_freq0) // @core_ddrc_core_clk


      // interrupts
      ,.derate_temp_limit_intr_out      (derate_temp_limit_intr)
      ,.derate_temp_limit_intr_ret      (derate_temp_limit_intr_ret)
      ,.derate_temp_limit_intr_fault    (derate_temp_limit_intr_fault)
      ,.core_derate_temp_limit_intr     (core_derate_temp_limit_intr)
      ,.derate_sync_ack_c2p             (derate_sync_ack_c2p)


      ); // slvtop

// reg_ddrc_burst_mode_int is used in DDRC instance
// Uses register value in HIF only configs
// Use value of 1'b0 if Arbiter config

   wire                 oc_parity_en_core_clock;
   wire                 oc_parity_type_core_clock;
   wire  [NPORTS-1:0]   oc_parity_en_aclk;
   wire  [NPORTS-1:0]   oc_parity_type_aclk;
   wire  [NPORTS-1:0]   par_addr_slverr_en_aclk;
   wire                 par_addr_slverr_en_core_clock;
   wire  [NPORTS-1:0]   par_raddr_err_pulse;
   wire  [NPORTS-1:0]   par_waddr_err_pulse;
   wire  [NPORTS-1:0]   par_rdata_err_pulse;
   wire  [NPORTS-1:0]   par_wdata_in_err_pulse;
   wire                 par_rdata_in_err_ecc_pulse;
   wire                 par_wdata_out_err_pulse;
   wire                 par_wdata_out_err_ie_pulse;
   wire                 par_wdata_slverr_en;
   wire  [NPORTS-1:0]   par_rdata_slverr_en;

   wire                 par_wdata_axi_check_bypass_en;

   wire  [NPORTS-1:0]   par_poison_en_rd_port;
   wire  [NPORTS-1:0]   par_poison_en_wr_port;
   wire                 par_poison_en_core_clock;
   wire                 par_poison_loc_rd_iecc_type;

   wire                 par_wdata_err_intr_clr_core_clock;
   wire  [NPORTS-1:0]   par_wdata_err_intr_clr_aclk;
   wire                 par_rdata_err_intr_clr_core_clock;
   wire  [NPORTS-1:0]   par_rdata_err_intr_clr_aclk;

   wire  [AXI_ADDRW*NPORTS-1:0]        par_raddr_log;
   wire  [AXI_ADDRW*NPORTS-1:0]        par_waddr_log;
   wire  [OCPAR_NUM_BYTES*NPORTS-1:0]  par_rdata_byte_log;


   wire  [NPORTS-1:0]               xpi_a_parity_err;
   wire [NPORTS-1:0]                xpi_parity_err;
   wire [NPORTS-1:0]                xpi_aclk_cmp_err, xpi_aclk_cmp_err_full, xpi_aclk_cmp_err_seq;
   wire [NPORTS-1:0]                xpi_cclk_cmp_err, xpi_cclk_cmp_err_full, xpi_cclk_cmp_err_seq;
   wire [NPORTS-1:0]                xpi_cclk_cmp_poison_complete, xpi_aclk_cmp_poison_complete;
   wire                             pa_parity_err_dch0;
   wire                             pa_parity_err_dch1;
   wire                             pa_parity_err;
   wire                             hif_data_parity_err;
   wire                             hif_data_parity_err_dch0;
   wire                             hif_data_parity_err_dch1;
   wire                             exa_parity_err;
   wire                             exa_parity_err_dch0, exa_parity_err_dch1;
   wire                             sbr_parity_err;
   wire                             sbr_parity_err_dch0, sbr_parity_err_dch1;
   wire                             pm_mask_parity_err;

   assign hif_data_parity_err = hif_data_parity_err_dch0 | hif_data_parity_err_dch1;
   assign exa_parity_err      = exa_parity_err_dch0 | exa_parity_err_dch1;
   assign pa_parity_err       = pa_parity_err_dch0 | pa_parity_err_dch1;
   assign sbr_parity_err      = sbr_parity_err_dch0 | sbr_parity_err_dch1;

   wire [NPORTS-1:0] ddrc_reg_ocecc_err_xpi_wr_in;
   wire [NPORTS-1:0] ddrc_reg_ocecc_err_xpi_rd;

   wire [NPORTS-1:0]                      ocecc_en_aclk;
   wire [NPORTS-1:0]                      ocecc_poison_egen_mr_rd_0_aclk;
   wire [NPORTS*OCECC_MR_BNUM_WIDTH-1:0]  ocecc_poison_egen_mr_rd_0_byte_num_aclk;
   wire [NPORTS-1:0]                      ocecc_poison_egen_xpi_rd_out_aclk;
   wire [NPORTS-1:0]                      ocecc_poison_single_aclk;
   wire [NPORTS-1:0]                      ocecc_wdata_slverr_en_aclk;
   wire [NPORTS-1:0]                      ocecc_rdata_slverr_en_aclk;

   wire [NPORTS-1:0] ocecc_xpi_write_uncorr_err;
   wire [NPORTS-1:0] ocecc_xpi_read_uncorr_err;
   wire [NPORTS-1:0] ocecc_xpi_write_corr_err;
   wire [NPORTS-1:0] ocecc_xpi_read_corr_err;


   wire ddrc_reg_ocecc_err_xpi_wr_in_0;
   wire ddrc_reg_ocecc_err_xpi_rd_0;

   assign ddrc_reg_ocecc_err_xpi_wr_in_0 = ddrc_reg_ocecc_err_xpi_wr_in[0];
   assign ddrc_reg_ocecc_err_xpi_rd_0    = ddrc_reg_ocecc_err_xpi_rd[0];

   wire ocecc_en_aclk_0;

   assign ocecc_en_aclk_0 = ocecc_en_aclk[0];

   wire ocecc_poison_egen_mr_rd_0_0 = ocecc_poison_egen_mr_rd_0_aclk[0];
   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression '((OCECC_MR_BNUM_WIDTH * (6 + 1)) - 1)' found in module 'DWC_ddrctl'
   //SJ: This coding style is acceptable and there is no plan to change it.
   wire [OCECC_MR_BNUM_WIDTH-1:0] ocecc_poison_egen_mr_rd_0_byte_num_0 = ocecc_poison_egen_mr_rd_0_byte_num_aclk[OCECC_MR_BNUM_WIDTH*(0+1)-1 -: OCECC_MR_BNUM_WIDTH];
   //spyglass enable_block SelfDeterminedExpr-ML

   wire ocecc_poison_egen_xpi_rd_out_0 = ocecc_poison_egen_xpi_rd_out_aclk[0];
   wire ocecc_poison_single_0 = ocecc_poison_single_aclk[0];
   wire ocecc_wdata_slverr_en_0 = ocecc_wdata_slverr_en_aclk[0];
   wire ocecc_rdata_slverr_en_0 = ocecc_rdata_slverr_en_aclk[0];




















   wire reg_ddrc_ocecc_en = 1'b0;

   wire [OCPAR_NUM_BYTES_LG2-1:0] reg_ddrc_par_poison_byte_num = {OCPAR_NUM_BYTES_LG2{1'b0}};

   assign oc_parity_en_core_clock            = 1'b0;
   assign oc_parity_type_core_clock          = 1'b1;
   assign oc_parity_en_aclk                  = {NPORTS{1'b0}};
   assign oc_parity_type_aclk                = {NPORTS{1'b1}};
   assign par_addr_slverr_en_aclk            = {NPORTS{1'b0}};
   assign par_addr_slverr_en_core_clock      = 1'b0;

   assign par_wdata_slverr_en                = 1'b0;
   assign par_rdata_slverr_en                = {NPORTS{1'b0}};

   assign par_wdata_axi_check_bypass_en      = 1'b0;

   assign par_poison_en_rd_port                 = {NPORTS{1'b0}};
   assign par_poison_en_wr_port                 = {NPORTS{1'b0}};
   assign par_poison_en_core_clock              = 1'b0;
   assign par_poison_loc_rd_iecc_type           = 1'b0;
   assign par_wdata_err_intr_clr_core_clock     = 1'b0;
   assign par_wdata_err_intr_clr_aclk           = {NPORTS{1'b0}};
   assign par_rdata_err_intr_clr_core_clock     = 1'b0;
   assign par_rdata_err_intr_clr_aclk           = {NPORTS{1'b0}};





wire ddrc_occap_wufifo_parity_err;
wire ddrc_occap_wuctrl_parity_err;
wire ddrc_occap_rtfifo_parity_err;
wire ddrc_occap_rtctrl_parity_err;
wire ddrc_occap_dfidata_parity_err;
wire ddrc_occap_eccaccarray_parity_err;


      wire  occap_ddrc_ctrl_err;
      wire  occap_ddrc_ctrl_poison_complete;
      wire  occap_ddrc_ctrl_poison_seq_err;
      wire  occap_ddrc_ctrl_poison_parallel_err;

      wire  occap_ddrc_data_err;
      wire  occap_ddrc_data_poison_complete;
      wire  occap_ddrc_data_poison_seq_err;
      wire  occap_ddrc_data_poison_parallel_err;




   wire reg_ddrc_occap_en  = 1'b0;


    wire [NPORTS-1:0]               reg_arb_occap_arb_cmp_poison_seq       = {NPORTS{1'b0}};
    wire [NPORTS-1:0]               reg_arb_occap_arb_cmp_poison_parallel  = {NPORTS{1'b0}};
    wire [NPORTS-1:0]               reg_arb_occap_arb_cmp_poison_err_inj   = {NPORTS{1'b0}};
    wire [NPORTS-1:0]               reg_arb_occap_arb_raq_poison_en        = {NPORTS{1'b0}};
    wire                            reg_ddrc_occap_arb_cmp_poison_seq      = 1'b0;
    wire                            reg_ddrc_occap_arb_cmp_poison_parallel = 1'b0;
    wire                            reg_ddrc_occap_arb_cmp_poison_err_inj  = 1'b0;


   wire reg_ddrc_occap_ddrc_ctrl_poison_seq          = 1'b0;
   wire reg_ddrc_occap_ddrc_ctrl_poison_parallel     = 1'b0;
   wire reg_ddrc_occap_ddrc_ctrl_poison_err_inj      = 1'b0;


   wire reg_ddrc_occap_ddrc_data_poison_seq          = 1'b0;
   wire reg_ddrc_occap_ddrc_data_poison_parallel     = 1'b0;
   wire reg_ddrc_occap_ddrc_data_poison_err_inj      = 1'b0;


  wire                                  ocecc_en_cclk;
  wire                                  ocecc_poison_egen_mr_rd_1_cclk;
  wire [OCECC_MR_BNUM_WIDTH-1:0]        ocecc_poison_egen_mr_rd_1_byte_num_cclk;
  wire                                  ocecc_poison_egen_xpi_rd_0_cclk;

  wire                                  ocecc_poison_single_cclk;
  wire                                  ocecc_poison_pgen_rd_cclk;
  wire                                  ocecc_poison_pgen_mr_ecc_cclk;
  wire                                  ocecc_wdata_slverr_en_cclk;

  wire                                  ocecc_uncorrected_err_intr_clr_cclk;

  wire ocecc_ddrc_mr_rd_corr_err;
  wire ocecc_ddrc_mr_rd_uncorr_err;
  wire [OCECC_MR_BINDEX_WIDTH-1:0] ocecc_mr_rd_byte_num;

  wire ocecc_ddrc_mr_rd_corr_err_dch1_unused;
  wire ocecc_ddrc_mr_rd_uncorr_err_dch1_unused;
  wire [OCECC_MR_BINDEX_WIDTH-1:0] ocecc_mr_rd_byte_num_dch1_unused;

  assign ocecc_en_cclk = 1'b0;
  assign ocecc_poison_egen_mr_rd_1_cclk = 1'b0;
  assign ocecc_poison_egen_mr_rd_1_byte_num_cclk = {$bits(ocecc_poison_egen_mr_rd_1_byte_num_cclk){1'b0}};
  assign ocecc_poison_egen_xpi_rd_0_cclk = 1'b0;
  assign ocecc_poison_single_cclk = 1'b0;
  assign ocecc_poison_pgen_rd_cclk = 1'b0;
  assign ocecc_poison_pgen_mr_ecc_cclk = 1'b0;
  assign ocecc_uncorrected_err_intr_clr_cclk = 1'b0;

  assign ocecc_wdata_slverr_en_cclk = 1'b0;
  assign ddrc_reg_ocecc_err_xpi_wr_in = {NPORTS{1'b0}};
  assign ddrc_reg_ocecc_err_xpi_rd = {NPORTS{1'b0}};
  assign ocecc_en_aclk = {NPORTS{1'b0}};
  assign ocecc_poison_egen_mr_rd_0_aclk = {NPORTS{1'b0}};
  assign ocecc_poison_egen_mr_rd_0_byte_num_aclk = {(NPORTS*OCECC_MR_BNUM_WIDTH){1'b0}};
  assign ocecc_poison_egen_xpi_rd_out_aclk = {NPORTS{1'b0}};
  assign ocecc_poison_single_aclk = {NPORTS{1'b0}};
  assign ocecc_wdata_slverr_en_aclk = {NPORTS{1'b0}};
  assign ocecc_rdata_slverr_en_aclk = {NPORTS{1'b0}};

wire reg_ddrc_en_2t_timing_mode_int;
     assign reg_ddrc_en_2t_timing_mode_int = reg_ddrc_en_2t_timing_mode;

wire reg_ddrc_burst_mode_int;
   // For multi-port configuration burst_mode is ignored.
  assign reg_ddrc_burst_mode_int = 1'b0;

   wire [INT_NPORTS_DATA-1:0] cactive_in_ddrc_dch0;
   wire [INT_NPORTS_DATA-1:0] cactive_in_ddrc_async_dch0;
   //---------------------------------------------------------------------
   // ARB configuration
   //---------------------------------------------------------------------
      wire [INT_NPORTS_DATA-1:0] cactive_out_dch0;
      wire [INT_NPORTS_DATA-1:0] cactive_xpi_dch0;
      wire [NPORTS-1:0]       cactive_out; // cactive_out from XPI
      wire [NPORTS-1:0]       cactive_xpi; // cactive from XPI
         assign cactive_out_dch0 = cactive_out;
         assign cactive_xpi_dch0 = cactive_xpi;
       assign cactive_in_ddrc_dch0       = cactive_out_dch0;
       assign cactive_in_ddrc_async_dch0 = cactive_xpi_dch0;

// Control signals




wire            regmux_ddrc_frequency_ratio;


wire [T_ZQ_LONG_NOP_WIDTH-1:0] regmux_ddrc_t_zq_long_nop_div;
wire [T_ZQ_SHORT_NOP_WIDTH-1:0] regmux_ddrc_t_zq_short_nop_div;
wire [T_ZQ_RESET_NOP_WIDTH-1:0] regmux_ddrc_t_zq_reset_nop_div;
wire [T_ZQ_SHORT_INTERVAL_X1024_WIDTH-1:0] regmux_ddrc_t_zq_short_interval_x1024_div;

wire   [BANK_ORG_WIDTH-1:0]             regmux_ddrc_bank_org;
wire   [RD2WR_WIDTH-1:0]                regmux_ddrc_rd2wr_s;
wire   [MRR2RD_WIDTH-1:0]               regmux_ddrc_mrr2rd;
wire   [MRR2WR_WIDTH-1:0]               regmux_ddrc_mrr2wr;
wire   [MRR2MRW_WIDTH-1:0]              regmux_ddrc_mrr2mrw;
wire   [MAX_RD_SYNC_WIDTH-1:0]          regmux_ddrc_max_rd_sync;
wire   [MAX_WR_SYNC_WIDTH-1:0]          regmux_ddrc_max_wr_sync;
wire   [DFI_TWCK_DELAY_WIDTH-1:0]       regmux_ddrc_dfi_twck_delay;
wire   [DFI_TWCK_EN_RD_WIDTH-1:0]       regmux_ddrc_dfi_twck_en_rd;
wire   [DFI_TWCK_EN_WR_WIDTH-1:0]       regmux_ddrc_dfi_twck_en_wr;
wire   [DFI_TWCK_DIS_WIDTH-1:0]         regmux_ddrc_dfi_twck_dis;
wire   [DFI_TWCK_FAST_TOGGLE_WIDTH-1:0] regmux_ddrc_dfi_twck_fast_toggle;
wire   [DFI_TWCK_TOGGLE_WIDTH-1:0]      regmux_ddrc_dfi_twck_toggle;
wire   [DFI_TWCK_TOGGLE_CS_WIDTH-1:0]   regmux_ddrc_dfi_twck_toggle_cs;
wire   [DFI_TWCK_TOGGLE_POST_WIDTH-1:0] regmux_ddrc_dfi_twck_toggle_post;

wire [DFI_T_CTRLUPD_INTERVAL_MAX_X1024_WIDTH-1:0] regmux_ddrc_dfi_t_ctrlupd_interval_max_x1024;
wire [DFI_T_CTRLUPD_INTERVAL_MIN_X1024_WIDTH-1:0] regmux_ddrc_dfi_t_ctrlupd_interval_min_x1024;

   // PWRTMG
wire [POWERDOWN_TO_X32_WIDTH-1:0] regmux_ddrc_powerdown_to_x32_div;
wire [SELFREF_TO_X32_WIDTH-1:0] regmux_ddrc_selfref_to_x32_div;

wire [HW_LP_IDLE_X32_WIDTH-1:0] regmux_ddrc_hw_lp_idle_x32_div;

wire [MR4_READ_INTERVAL_WIDTH-1:0] regmux_ddrc_mr4_read_interval_div;




wire [REFRESH_TO_X1_X32_WIDTH-1:0] regmux_ddrc_refresh_to_x1_x32_div;
wire [REFRESH_TO_AB_X32_WIDTH-1:0] regmux_ddrc_refresh_to_ab_x32_div;

wire [T_RFC_MIN_WIDTH-1:0] regmux_ddrc_t_rfc_min_div;
wire [T_RFC_MIN_AB_WIDTH-1:0] regmux_ddrc_t_rfc_min_ab_div;
wire regmux_ddrc_t_refi_x1_sel;
wire [T_REFI_X1_X32_WIDTH-1:0] regmux_ddrc_t_refi_x1_x32_div;

wire [REFRESH_MARGIN_WIDTH-1:0] regmux_ddrc_refresh_margin_div;

wire [T_PBR2PBR_WIDTH-1:0] regmux_ddrc_t_pbr2pbr_div;
wire [T_PBR2ACT_WIDTH-1:0] regmux_ddrc_t_pbr2act;

wire [DERATED_T_RCD_WIDTH-1:0]     regmux_ddrc_derated_t_rcd_div;
wire [DERATED_T_RAS_MIN_WIDTH-1:0] regmux_ddrc_derated_t_ras_min_div;
wire [DERATED_T_RP_WIDTH-1:0]      regmux_ddrc_derated_t_rp_div;
wire [DERATED_T_RRD_WIDTH-1:0]     regmux_ddrc_derated_t_rrd_div;
wire [DERATED_T_RC_WIDTH-1:0]      regmux_ddrc_derated_t_rc_div;



wire [T_RAS_MIN_WIDTH-1:0] regmux_ddrc_t_ras_min_div;
wire [T_RAS_MAX_WIDTH-1:0] regmux_ddrc_t_ras_max_div;
wire [T_FAW_WIDTH-1:0] regmux_ddrc_t_faw_div;
wire [LPDDR4_DIFF_BANK_RWA2PRE_WIDTH-1:0] regmux_ddrc_lpddr4_diff_bank_rwa2pre_div;
wire [WR2PRE_WIDTH-1:0] regmux_ddrc_wr2pre_div;
wire [WRA2PRE_WIDTH-1:0] regmux_ddrc_wra2pre_div;

wire [T_RC_WIDTH-1:0] regmux_ddrc_t_rc_div;
wire [RD2PRE_WIDTH-1:0] regmux_ddrc_rd2pre_div;
wire [RDA2PRE_WIDTH-1:0] regmux_ddrc_rda2pre_div;
wire [T_XP_WIDTH-1:0] regmux_ddrc_t_xp_div;

wire [WR2RD_WIDTH-1:0] regmux_ddrc_wr2rd_div;
wire [RD2WR_WIDTH-1:0] regmux_ddrc_rd2wr_div;
wire [READ_LATENCY_WIDTH-1:0] regmux_ddrc_read_latency_div;
wire [WRITE_LATENCY_WIDTH-1:0] regmux_ddrc_write_latency_div;

wire [RD2MR_WIDTH-1:0] regmux_ddrc_rd2mr_div;
wire [T_MR_WIDTH-1:0] regmux_ddrc_t_mr_div;
wire [WR2MR_WIDTH-1:0] regmux_ddrc_wr2mr_div;

wire [T_RP_WIDTH-1:0] regmux_ddrc_t_rp_div;
wire [T_RRD_WIDTH-1:0] regmux_ddrc_t_rrd_div;
wire [T_CCD_WIDTH-1:0] regmux_ddrc_t_ccd_div;
wire [T_RCD_WIDTH-1:0] regmux_ddrc_t_rcd_div;

wire [T_CKE_WIDTH-1:0] regmux_ddrc_t_cke_div;
wire [T_CKESR_WIDTH-1:0] regmux_ddrc_t_ckesr_div;
wire [T_CKSRE_WIDTH-1:0] regmux_ddrc_t_cksre_div;
wire [T_CKSRX_WIDTH-1:0] regmux_ddrc_t_cksrx_div;

wire [T_CKCSX_WIDTH-1:0] regmux_ddrc_t_ckcsx_div;

wire [WR2RD_S_WIDTH-1:0] regmux_ddrc_wr2rd_s_div;
wire [T_RRD_S_WIDTH-1:0] regmux_ddrc_t_rrd_s_div;
wire [T_CCD_S_WIDTH-1:0] regmux_ddrc_t_ccd_s_div;

wire [T_CMDCKE_WIDTH-1:0] regmux_ddrc_t_cmdcke_div;
wire [T_PDN_WIDTH-1:0] regmux_ddrc_t_pdn;
wire [T_XSR_DSM_X1024_WIDTH-1:0] regmux_ddrc_t_xsr_dsm_x1024;
wire [T_CSH_WIDTH-1:0] regmux_ddrc_t_csh;
wire [T_CCD_MW_WIDTH-1:0] regmux_ddrc_t_ccd_mw_div;
wire [ODTLOFF_WIDTH-1:0] regmux_ddrc_odtloff_div;
wire [T_PPD_WIDTH-1:0] regmux_ddrc_t_ppd_div;


wire [T_XSR_WIDTH-1:0] regmux_ddrc_t_xsr_div;
wire  [T_OSCO_WIDTH-1:0]  regmux_ddrc_t_osco_div;
wire regmux_ddrc_dqsosc_enable;
wire regmux_ddrc_dqsosc_interval_unit;
wire [DQSOSC_INTERVAL_WIDTH-1:0] regmux_ddrc_dqsosc_interval;


// INIT3
wire [15:0] regmux_ddrc_mr;
wire [15:0] regmux_ddrc_emr;
// INIT4
wire [15:0] regmux_ddrc_emr2;
wire [15:0] regmux_ddrc_emr3;
// INIT6
wire [15:0] regmux_ddrc_mr4;
wire [15:0] regmux_ddrc_mr5;
// INIT7
wire [15:0] regmux_ddrc_mr6;
wire [15:0] regmux_ddrc_mr22;

wire [6:0] regmux_ddrc_dfi_t_rddata_en;
wire [5:0] regmux_ddrc_dfi_tphy_wrdata;
wire [DFI_TPHY_WRLAT_WIDTH-1:0] regmux_ddrc_dfi_tphy_wrlat;
wire [4:0] regmux_ddrc_dfi_t_wrdata_delay;
wire [DFI_T_CTRL_DELAY_WIDTH-1:0] regmux_ddrc_dfi_t_ctrl_delay;
wire [DFI_T_DRAM_CLK_DISABLE_WIDTH-1:0] regmux_ddrc_dfi_t_dram_clk_disable;
wire [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0] regmux_ddrc_dfi_t_dram_clk_enable;

wire [6:0] regmux_ddrc_dfi_tphy_rdcslat;
wire [DFI_TPHY_WRCSLAT_WIDTH-1:0] regmux_ddrc_dfi_tphy_wrcslat;






wire [HPR_MAX_STARVE_WIDTH-1:0] regmux_ddrc_hpr_max_starve;
wire [HPR_XACT_RUN_LENGTH_WIDTH-1:0] regmux_ddrc_hpr_xact_run_length;
wire [LPR_MAX_STARVE_WIDTH-1:0] regmux_ddrc_lpr_max_starve;
wire [LPR_XACT_RUN_LENGTH_WIDTH-1:0] regmux_ddrc_lpr_xact_run_length;
wire [W_MAX_STARVE_WIDTH-1:0] regmux_ddrc_w_max_starve;
wire [W_XACT_RUN_LENGTH_WIDTH-1:0] regmux_ddrc_w_xact_run_length;

wire [PAGECLOSE_TIMER_WIDTH-1:0] regmux_ddrc_pageclose_timer;
wire [RDWR_IDLE_GAP_WIDTH-1:0] regmux_ddrc_rdwr_idle_gap;




dwc_ddrctl_regmux_div

  U_regmux_div_ch0 (
       .core_ddrc_core_clk                     (core_ddrc_core_clk)
      ,.core_ddrc_rstn                         (core_ddrc_rstn)

  ////////////////////
  // Control signals //
  /////////////////////


      ,.reg_ddrc_lpddr5 (reg_ddrc_lpddr5)






  //////////////////////
  // Normal registers //
  //////////////////////

  /////////////////////
  // Freq0 registers //
  /////////////////////

      ,.reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0 (reg_ddrc_dfi_t_ctrlupd_interval_max_x1024_freq0)
      ,.reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0 (reg_ddrc_dfi_t_ctrlupd_interval_min_x1024_freq0)

       ,.reg_ddrc_hw_lp_idle_x32_freq0 (reg_ddrc_hw_lp_idle_x32_freq0)

      ,.reg_ddrc_frequency_ratio_freq0 (reg_ddrc_frequency_ratio_freq0)

      ,.reg_ddrc_derated_t_rcd_freq0     (reg_ddrc_derated_t_rcd_freq0)
      ,.reg_ddrc_derated_t_ras_min_freq0 (reg_ddrc_derated_t_ras_min_freq0)
      ,.reg_ddrc_derated_t_rp_freq0      (reg_ddrc_derated_t_rp_freq0)
      ,.reg_ddrc_derated_t_rrd_freq0     (reg_ddrc_derated_t_rrd_freq0)
      ,.reg_ddrc_derated_t_rc_freq0      (reg_ddrc_derated_t_rc_freq0)
      ,.reg_ddrc_mr4_read_interval_freq0 (reg_ddrc_mr4_read_interval_freq0)
      ,.reg_ddrc_powerdown_to_x32_freq0 (reg_ddrc_powerdown_to_x32_freq0)
      ,.reg_ddrc_selfref_to_x32_freq0 (reg_ddrc_selfref_to_x32_freq0)
      ,.reg_ddrc_refresh_margin_freq0 (reg_ddrc_refresh_margin_freq0)
      ,.reg_ddrc_refresh_to_x1_x32_freq0 (reg_ddrc_refresh_to_x1_x32_freq0)
      ,.reg_ddrc_refresh_to_ab_x32_freq0 (reg_ddrc_refresh_to_ab_x32_freq0)
      ,.reg_ddrc_t_refi_x1_sel_freq0 (reg_ddrc_t_refi_x1_sel_freq0)
      ,.reg_ddrc_t_refi_x1_x32_freq0 (reg_ddrc_t_refi_x1_x32_freq0)
      ,.reg_ddrc_t_rfc_min_freq0 (reg_ddrc_t_rfc_min_freq0)
      ,.reg_ddrc_t_rfc_min_ab_freq0 (reg_ddrc_t_rfc_min_ab_freq0)
      ,.reg_ddrc_t_pbr2pbr_freq0 (reg_ddrc_t_pbr2pbr_freq0)
      ,.reg_ddrc_t_pbr2act_freq0 (reg_ddrc_t_pbr2act_freq0)
      ,.reg_ddrc_mr_freq0 (reg_ddrc_mr_freq0)
      ,.reg_ddrc_emr_freq0 (reg_ddrc_emr_freq0)
      ,.reg_ddrc_emr2_freq0 (reg_ddrc_emr2_freq0)
      ,.reg_ddrc_emr3_freq0 (reg_ddrc_emr3_freq0)
      ,.reg_ddrc_mr4_freq0 (reg_ddrc_mr4_freq0)
      ,.reg_ddrc_mr5_freq0 (reg_ddrc_mr5_freq0)
      ,.reg_ddrc_mr6_freq0 (reg_ddrc_mr6_freq0)
      ,.reg_ddrc_mr22_freq0 (reg_ddrc_mr22_freq0)
      ,.reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0 (reg_ddrc_lpddr4_diff_bank_rwa2pre_freq0)
      ,.reg_ddrc_wr2pre_freq0 (reg_ddrc_wr2pre_freq0)
      ,.reg_ddrc_wra2pre_freq0 (reg_ddrc_wra2pre_freq0)
      ,.reg_ddrc_t_faw_freq0 (reg_ddrc_t_faw_freq0)
      ,.reg_ddrc_t_ras_max_freq0 (reg_ddrc_t_ras_max_freq0)
      ,.reg_ddrc_t_ras_min_freq0 (reg_ddrc_t_ras_min_freq0)
      ,.reg_ddrc_t_xp_freq0 (reg_ddrc_t_xp_freq0)
      ,.reg_ddrc_rd2pre_freq0 (reg_ddrc_rd2pre_freq0)
      ,.reg_ddrc_rda2pre_freq0 (reg_ddrc_rda2pre_freq0)
      ,.reg_ddrc_t_rc_freq0 (reg_ddrc_t_rc_freq0)
      ,.reg_ddrc_write_latency_freq0 (reg_ddrc_write_latency_freq0)
      ,.reg_ddrc_read_latency_freq0 (reg_ddrc_read_latency_freq0)
      ,.reg_ddrc_rd2wr_freq0 (reg_ddrc_rd2wr_freq0)
      ,.reg_ddrc_wr2rd_freq0 (reg_ddrc_wr2rd_freq0)
      ,.reg_ddrc_wr2mr_freq0 (reg_ddrc_wr2mr_freq0)
      ,.reg_ddrc_t_mr_freq0 (reg_ddrc_t_mr_freq0)
      ,.reg_ddrc_rd2mr_freq0 (reg_ddrc_rd2mr_freq0)
      ,.reg_ddrc_t_rcd_freq0 (reg_ddrc_t_rcd_freq0)
      ,.reg_ddrc_t_ccd_freq0 (reg_ddrc_t_ccd_freq0)
      ,.reg_ddrc_t_rrd_freq0 (reg_ddrc_t_rrd_freq0)
      ,.reg_ddrc_t_rp_freq0 (reg_ddrc_t_rp_freq0)
      ,.reg_ddrc_t_cksrx_freq0 (reg_ddrc_t_cksrx_freq0)
      ,.reg_ddrc_t_cksre_freq0 (reg_ddrc_t_cksre_freq0)
      ,.reg_ddrc_t_ckesr_freq0 (reg_ddrc_t_ckesr_freq0)
      ,.reg_ddrc_t_cke_freq0 (reg_ddrc_t_cke_freq0)
      ,.reg_ddrc_t_ckcsx_freq0 (reg_ddrc_t_ckcsx_freq0)
      ,.reg_ddrc_t_ccd_s_freq0 (reg_ddrc_t_ccd_s_freq0)
      ,.reg_ddrc_t_rrd_s_freq0 (reg_ddrc_t_rrd_s_freq0)
      ,.reg_ddrc_wr2rd_s_freq0 (reg_ddrc_wr2rd_s_freq0)
      ,.reg_ddrc_t_cmdcke_freq0 (reg_ddrc_t_cmdcke_freq0)
      ,.reg_ddrc_t_pdn_freq0 (reg_ddrc_t_pdn_freq0)
      ,.reg_ddrc_t_xsr_dsm_x1024_freq0 (reg_ddrc_t_xsr_dsm_x1024_freq0)
      ,.reg_ddrc_t_csh_freq0 (reg_ddrc_t_csh_freq0)
      ,.reg_ddrc_odtloff_freq0 (reg_ddrc_odtloff_freq0)
      ,.reg_ddrc_t_ccd_mw_freq0 (reg_ddrc_t_ccd_mw_freq0)
      ,.reg_ddrc_t_ppd_freq0 (reg_ddrc_t_ppd_freq0)
      ,.reg_ddrc_t_xsr_freq0 (reg_ddrc_t_xsr_freq0)
      ,.reg_ddrc_t_osco_freq0 (reg_ddrc_t_osco_freq0)
     ,.reg_ddrc_dqsosc_enable_freq0         (reg_ddrc_dqsosc_enable_freq0)
     ,.reg_ddrc_dqsosc_interval_unit_freq0  (reg_ddrc_dqsosc_interval_unit_freq0)
     ,.reg_ddrc_dqsosc_interval_freq0       (reg_ddrc_dqsosc_interval_freq0)
      ,.reg_ddrc_t_zq_long_nop_freq0 (reg_ddrc_t_zq_long_nop_freq0)
      ,.reg_ddrc_t_zq_short_nop_freq0 (reg_ddrc_t_zq_short_nop_freq0)

      ,.reg_ddrc_t_zq_reset_nop_freq0 (reg_ddrc_t_zq_reset_nop_freq0)
      ,.reg_ddrc_t_zq_short_interval_x1024_freq0 (reg_ddrc_t_zq_short_interval_x1024_freq0)
      ,.reg_ddrc_bank_org_freq0              (reg_ddrc_bank_org_freq0)
      ,.reg_ddrc_rd2wr_s_freq0               (reg_ddrc_rd2wr_s_freq0)
      ,.reg_ddrc_mrr2rd_freq0                (reg_ddrc_mrr2rd_freq0)
      ,.reg_ddrc_mrr2wr_freq0                (reg_ddrc_mrr2wr_freq0)
      ,.reg_ddrc_mrr2mrw_freq0               (reg_ddrc_mrr2mrw_freq0)
      ,.reg_ddrc_max_rd_sync_freq0           (reg_ddrc_max_rd_sync_freq0)
      ,.reg_ddrc_max_wr_sync_freq0           (reg_ddrc_max_wr_sync_freq0)
      ,.reg_ddrc_dfi_twck_delay_freq0        (reg_ddrc_dfi_twck_delay_freq0)
      ,.reg_ddrc_dfi_twck_en_rd_freq0        (reg_ddrc_dfi_twck_en_rd_freq0)
      ,.reg_ddrc_dfi_twck_en_wr_freq0        (reg_ddrc_dfi_twck_en_wr_freq0)
      ,.reg_ddrc_dfi_twck_dis_freq0          (reg_ddrc_dfi_twck_dis_freq0)
      ,.reg_ddrc_dfi_twck_fast_toggle_freq0  (reg_ddrc_dfi_twck_fast_toggle_freq0)
      ,.reg_ddrc_dfi_twck_toggle_freq0       (reg_ddrc_dfi_twck_toggle_freq0)
      ,.reg_ddrc_dfi_twck_toggle_cs_freq0    (reg_ddrc_dfi_twck_toggle_cs_freq0)
      ,.reg_ddrc_dfi_twck_toggle_post_freq0  (reg_ddrc_dfi_twck_toggle_post_freq0)
      ,.reg_ddrc_dfi_t_ctrl_delay_freq0 (reg_ddrc_dfi_t_ctrl_delay_freq0)
      ,.reg_ddrc_dfi_t_rddata_en_freq0 (reg_ddrc_dfi_t_rddata_en_freq0)
      ,.reg_ddrc_dfi_tphy_wrdata_freq0 (reg_ddrc_dfi_tphy_wrdata_freq0)
      ,.reg_ddrc_dfi_tphy_wrlat_freq0 (reg_ddrc_dfi_tphy_wrlat_freq0)
      ,.reg_ddrc_dfi_t_wrdata_delay_freq0 (reg_ddrc_dfi_t_wrdata_delay_freq0)
      ,.reg_ddrc_dfi_t_dram_clk_disable_freq0 (reg_ddrc_dfi_t_dram_clk_disable_freq0)
      ,.reg_ddrc_dfi_t_dram_clk_enable_freq0 (reg_ddrc_dfi_t_dram_clk_enable_freq0)
      ,.reg_ddrc_dfi_tphy_rdcslat_freq0 (reg_ddrc_dfi_tphy_rdcslat_freq0)
      ,.reg_ddrc_dfi_tphy_wrcslat_freq0 (reg_ddrc_dfi_tphy_wrcslat_freq0)



      ,.reg_ddrc_hpr_max_starve_freq0 (reg_ddrc_hpr_max_starve_freq0)
      ,.reg_ddrc_hpr_xact_run_length_freq0 (reg_ddrc_hpr_xact_run_length_freq0)
      ,.reg_ddrc_lpr_max_starve_freq0 (reg_ddrc_lpr_max_starve_freq0)
      ,.reg_ddrc_lpr_xact_run_length_freq0 (reg_ddrc_lpr_xact_run_length_freq0)
      ,.reg_ddrc_w_max_starve_freq0 (reg_ddrc_w_max_starve_freq0)
      ,.reg_ddrc_w_xact_run_length_freq0 (reg_ddrc_w_xact_run_length_freq0)

      ,.reg_ddrc_rdwr_idle_gap_freq0       (reg_ddrc_rdwr_idle_gap_freq0)
      ,.reg_ddrc_pageclose_timer_freq0     (reg_ddrc_pageclose_timer_freq0)



















      ,.regmux_ddrc_frequency_ratio (regmux_ddrc_frequency_ratio)




   // PWRTMG
      ,.regmux_ddrc_powerdown_to_x32_div (regmux_ddrc_powerdown_to_x32_div)
      ,.regmux_ddrc_selfref_to_x32_div (regmux_ddrc_selfref_to_x32_div)

       ,.regmux_ddrc_hw_lp_idle_x32_div (regmux_ddrc_hw_lp_idle_x32_div)

       ,.regmux_ddrc_mr4_read_interval_div (regmux_ddrc_mr4_read_interval_div)




      ,.regmux_ddrc_refresh_to_x1_x32_div (regmux_ddrc_refresh_to_x1_x32_div)
      ,.regmux_ddrc_refresh_to_ab_x32_div (regmux_ddrc_refresh_to_ab_x32_div)

      ,.regmux_ddrc_t_refi_x1_sel (regmux_ddrc_t_refi_x1_sel)
      ,.regmux_ddrc_t_rfc_min_div (regmux_ddrc_t_rfc_min_div)
      ,.regmux_ddrc_t_rfc_min_ab_div (regmux_ddrc_t_rfc_min_ab_div)
      ,.regmux_ddrc_t_refi_x1_x32_div (regmux_ddrc_t_refi_x1_x32_div)

      ,.regmux_ddrc_refresh_margin_div (regmux_ddrc_refresh_margin_div)

      ,.regmux_ddrc_t_pbr2pbr_div (regmux_ddrc_t_pbr2pbr_div)
      ,.regmux_ddrc_t_pbr2act     (regmux_ddrc_t_pbr2act)

       ,.regmux_ddrc_derated_t_rcd_div       (regmux_ddrc_derated_t_rcd_div)
       ,.regmux_ddrc_derated_t_ras_min_div   (regmux_ddrc_derated_t_ras_min_div)
       ,.regmux_ddrc_derated_t_rp_div        (regmux_ddrc_derated_t_rp_div)
       ,.regmux_ddrc_derated_t_rrd_div       (regmux_ddrc_derated_t_rrd_div)
       ,.regmux_ddrc_derated_t_rc_div        (regmux_ddrc_derated_t_rc_div)


      ,.regmux_ddrc_t_ras_min_div (regmux_ddrc_t_ras_min_div)
      ,.regmux_ddrc_t_ras_max_div (regmux_ddrc_t_ras_max_div)
      ,.regmux_ddrc_t_faw_div (regmux_ddrc_t_faw_div)
      ,.regmux_ddrc_lpddr4_diff_bank_rwa2pre_div (regmux_ddrc_lpddr4_diff_bank_rwa2pre_div)
      ,.regmux_ddrc_wr2pre_div (regmux_ddrc_wr2pre_div)
      ,.regmux_ddrc_wra2pre_div (regmux_ddrc_wra2pre_div)

      ,.regmux_ddrc_t_rc_div (regmux_ddrc_t_rc_div)
      ,.regmux_ddrc_rd2pre_div (regmux_ddrc_rd2pre_div)
      ,.regmux_ddrc_rda2pre_div (regmux_ddrc_rda2pre_div)
      ,.regmux_ddrc_t_xp_div (regmux_ddrc_t_xp_div)

      ,.regmux_ddrc_wr2rd_div (regmux_ddrc_wr2rd_div)
      ,.regmux_ddrc_rd2wr_div (regmux_ddrc_rd2wr_div)
      ,.regmux_ddrc_read_latency_div (regmux_ddrc_read_latency_div)
      ,.regmux_ddrc_write_latency_div (regmux_ddrc_write_latency_div)

      ,.regmux_ddrc_rd2mr_div (regmux_ddrc_rd2mr_div)
      ,.regmux_ddrc_t_mr_div  (regmux_ddrc_t_mr_div)
      ,.regmux_ddrc_wr2mr_div (regmux_ddrc_wr2mr_div)

       ,.regmux_ddrc_t_rp_div (regmux_ddrc_t_rp_div)
      ,.regmux_ddrc_t_rrd_div (regmux_ddrc_t_rrd_div)
      ,.regmux_ddrc_t_ccd_div (regmux_ddrc_t_ccd_div)
      ,.regmux_ddrc_t_rcd_div (regmux_ddrc_t_rcd_div)

       ,.regmux_ddrc_t_cke_div (regmux_ddrc_t_cke_div)
      ,.regmux_ddrc_t_ckesr_div (regmux_ddrc_t_ckesr_div)
      ,.regmux_ddrc_t_cksre_div (regmux_ddrc_t_cksre_div)
      ,.regmux_ddrc_t_cksrx_div (regmux_ddrc_t_cksrx_div)

       ,.regmux_ddrc_t_ckcsx_div (regmux_ddrc_t_ckcsx_div)

      ,.regmux_ddrc_wr2rd_s_div (regmux_ddrc_wr2rd_s_div)
      ,.regmux_ddrc_t_rrd_s_div (regmux_ddrc_t_rrd_s_div)
      ,.regmux_ddrc_t_ccd_s_div (regmux_ddrc_t_ccd_s_div)

      ,.regmux_ddrc_t_cmdcke_div (regmux_ddrc_t_cmdcke_div)
      ,.regmux_ddrc_t_pdn (regmux_ddrc_t_pdn)
      ,.regmux_ddrc_t_xsr_dsm_x1024 (regmux_ddrc_t_xsr_dsm_x1024)
      ,.regmux_ddrc_t_csh (regmux_ddrc_t_csh)
      ,.regmux_ddrc_t_ccd_mw_div (regmux_ddrc_t_ccd_mw_div)
      ,.regmux_ddrc_odtloff_div (regmux_ddrc_odtloff_div)
       ,.regmux_ddrc_t_ppd_div (regmux_ddrc_t_ppd_div)

       ,.regmux_ddrc_t_xsr_div (regmux_ddrc_t_xsr_div)
       ,.regmux_ddrc_t_osco_div (regmux_ddrc_t_osco_div)
       ,.regmux_ddrc_dqsosc_enable        (regmux_ddrc_dqsosc_enable)
       ,.regmux_ddrc_dqsosc_interval      (regmux_ddrc_dqsosc_interval)
       ,.regmux_ddrc_dqsosc_interval_unit (regmux_ddrc_dqsosc_interval_unit)


      ,.regmux_ddrc_t_zq_long_nop_div (regmux_ddrc_t_zq_long_nop_div)
      ,.regmux_ddrc_t_zq_short_nop_div (regmux_ddrc_t_zq_short_nop_div)
      ,.regmux_ddrc_t_zq_reset_nop_div (regmux_ddrc_t_zq_reset_nop_div)
      ,.regmux_ddrc_t_zq_short_interval_x1024_div (regmux_ddrc_t_zq_short_interval_x1024_div)
      ,.regmux_ddrc_bank_org              (regmux_ddrc_bank_org)
      ,.regmux_ddrc_rd2wr_s               (regmux_ddrc_rd2wr_s)
      ,.regmux_ddrc_mrr2rd                (regmux_ddrc_mrr2rd)
      ,.regmux_ddrc_mrr2wr                (regmux_ddrc_mrr2wr)
      ,.regmux_ddrc_mrr2mrw               (regmux_ddrc_mrr2mrw)
      ,.regmux_ddrc_max_rd_sync           (regmux_ddrc_max_rd_sync)
      ,.regmux_ddrc_max_wr_sync           (regmux_ddrc_max_wr_sync)
      ,.regmux_ddrc_dfi_twck_delay        (regmux_ddrc_dfi_twck_delay)
      ,.regmux_ddrc_dfi_twck_en_rd        (regmux_ddrc_dfi_twck_en_rd)
      ,.regmux_ddrc_dfi_twck_en_wr        (regmux_ddrc_dfi_twck_en_wr)
      ,.regmux_ddrc_dfi_twck_dis          (regmux_ddrc_dfi_twck_dis)
      ,.regmux_ddrc_dfi_twck_fast_toggle  (regmux_ddrc_dfi_twck_fast_toggle)
      ,.regmux_ddrc_dfi_twck_toggle       (regmux_ddrc_dfi_twck_toggle)
      ,.regmux_ddrc_dfi_twck_toggle_cs    (regmux_ddrc_dfi_twck_toggle_cs)
      ,.regmux_ddrc_dfi_twck_toggle_post  (regmux_ddrc_dfi_twck_toggle_post)

      ,.regmux_ddrc_dfi_t_ctrlupd_interval_max_x1024 (regmux_ddrc_dfi_t_ctrlupd_interval_max_x1024)
      ,.regmux_ddrc_dfi_t_ctrlupd_interval_min_x1024 (regmux_ddrc_dfi_t_ctrlupd_interval_min_x1024)

      ,.regmux_ddrc_emr2 (regmux_ddrc_emr2)
      ,.regmux_ddrc_emr3 (regmux_ddrc_emr3)
      ,.regmux_ddrc_mr (regmux_ddrc_mr)
      ,.regmux_ddrc_emr (regmux_ddrc_emr)
      ,.regmux_ddrc_mr4 (regmux_ddrc_mr4)
      ,.regmux_ddrc_mr5 (regmux_ddrc_mr5)
      ,.regmux_ddrc_mr6 (regmux_ddrc_mr6)
      ,.regmux_ddrc_mr22 (regmux_ddrc_mr22)
      ,.regmux_ddrc_dfi_t_rddata_en (regmux_ddrc_dfi_t_rddata_en)
      ,.regmux_ddrc_dfi_tphy_wrdata (regmux_ddrc_dfi_tphy_wrdata)
      ,.regmux_ddrc_dfi_tphy_wrlat (regmux_ddrc_dfi_tphy_wrlat)
      ,.regmux_ddrc_dfi_t_wrdata_delay (regmux_ddrc_dfi_t_wrdata_delay)
      ,.regmux_ddrc_dfi_t_ctrl_delay   (regmux_ddrc_dfi_t_ctrl_delay)
      ,.regmux_ddrc_dfi_t_dram_clk_disable (regmux_ddrc_dfi_t_dram_clk_disable)
      ,.regmux_ddrc_dfi_t_dram_clk_enable (regmux_ddrc_dfi_t_dram_clk_enable)
      ,.regmux_ddrc_dfi_tphy_rdcslat (regmux_ddrc_dfi_tphy_rdcslat)
      ,.regmux_ddrc_dfi_tphy_wrcslat (regmux_ddrc_dfi_tphy_wrcslat)




      ,.regmux_ddrc_hpr_max_starve (regmux_ddrc_hpr_max_starve)
      ,.regmux_ddrc_hpr_xact_run_length (regmux_ddrc_hpr_xact_run_length)
      ,.regmux_ddrc_lpr_max_starve (regmux_ddrc_lpr_max_starve)
      ,.regmux_ddrc_lpr_xact_run_length (regmux_ddrc_lpr_xact_run_length)
      ,.regmux_ddrc_w_max_starve (regmux_ddrc_w_max_starve)
      ,.regmux_ddrc_w_xact_run_length (regmux_ddrc_w_xact_run_length)

      ,.regmux_ddrc_rdwr_idle_gap       (regmux_ddrc_rdwr_idle_gap)
      ,.regmux_ddrc_pageclose_timer     (regmux_ddrc_pageclose_timer)




);




   //--------------------------------------------------------------------------------
   // Synchronizer
   //--------------------------------------------------------------------------------

   // xpi_ddrc_port_disable_ack
   wire [INT_NPORTS_DATA-1:0] xpi_ddrc_port_disable_ack_cclk;
   wire [INT_NPORTS_DATA-1:0] xpi_ddrc_port_disable_ack;

   genvar gen_port_disable_ack_sync;

   generate if (ARB_HWFFC_EN) begin: port_disable_ack_sync
   for (gen_port_disable_ack_sync=0; gen_port_disable_ack_sync<INT_NPORTS_DATA; gen_port_disable_ack_sync=gen_port_disable_ack_sync+1)
   begin : port_disable_ack_sync

      if (A_SYNC_TABLE_MASKED[gen_port_disable_ack_sync]==0) begin: A_async_1
      // Each bit of xpi_ddrc_port_disable_ack could be on diff clock domain
         DWC_ddr_umctl2_bitsync
         
         #( .BCM_SYNC_TYPE   (BCM_DDRC_N_SYNC),
            .BCM_VERIF_EN    (BCM_VERIF_EN))
         U_bitsync_port_disable_ack
         (  .clk_d          (core_ddrc_core_clk),
            .rst_d_n        (core_ddrc_rstn),
            .data_s         (xpi_ddrc_port_disable_ack[gen_port_disable_ack_sync]),
            .data_d         (xpi_ddrc_port_disable_ack_cclk[gen_port_disable_ack_sync]));

      end
      else begin: A_sync_1

         reg port_disable_ack_r;

         always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
            if(!core_ddrc_rstn) begin
               port_disable_ack_r <= 1'b0;
            end else begin
               port_disable_ack_r <= xpi_ddrc_port_disable_ack[gen_port_disable_ack_sync];
            end
         end

         assign xpi_ddrc_port_disable_ack_cclk[gen_port_disable_ack_sync] = port_disable_ack_r;

      end
   end // generate port_disable_ack_sync
   end // port_disable_ack_sync
   endgenerate

   // xpi_ddrc_wch_locked
   wire [NPORTS-1:0] xpi_ddrc_wch_locked_cclk;
   wire [NPORTS-1:0] xpi_ddrc_wch_locked;
   genvar gen_wch_locked_sync;

   generate if (ARB_HWFFC_EN) begin: wch_locked
   // generate individual BCM21 for each bit of xpi_ddrc_wch_locked
   for (gen_wch_locked_sync=0; gen_wch_locked_sync<NPORTS; gen_wch_locked_sync=gen_wch_locked_sync+1)
   begin : wch_locked_sync

      if (A_SYNC_TABLE_MASKED[gen_wch_locked_sync]==0) begin: xpi_ddrc_wch_locked_async
      // Each bit of xpi_ddrc_wch_locked could be on diff clock domain
         DWC_ddr_umctl2_bitsync
         
         #( .BCM_SYNC_TYPE   (BCM_DDRC_N_SYNC),
            .BCM_VERIF_EN    (BCM_VERIF_EN))
         U_bitsync_wch_locked
         (  .clk_d          (core_ddrc_core_clk),
            .rst_d_n        (core_ddrc_rstn),
            .data_s         (xpi_ddrc_wch_locked[gen_wch_locked_sync]),
            .data_d         (xpi_ddrc_wch_locked_cclk[gen_wch_locked_sync]));

      end
      else begin:  xpi_ddrc_wch_locked_sync

         reg wch_locked_r;

         always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
            if(!core_ddrc_rstn) begin
               wch_locked_r <= 1'b0;
            end else begin
               wch_locked_r <= xpi_ddrc_wch_locked[gen_wch_locked_sync];
            end
         end

         assign xpi_ddrc_wch_locked_cclk[gen_wch_locked_sync] = wch_locked_r;

      end
   end // generate wch_locked_sync
   end // wch_locked
   endgenerate

   //-------------------------------------------------------------------
   // DFI connection logics
   //-------------------------------------------------------------------

   localparam DFI_LP_WAKEUP_WIDTH  = DFI_LP_WAKEUP_PD_WIDTH;
   localparam BG_WIDTH             = (`MEMC_DDR4_EN==1) ? `MEMC_BG_BITS : 1;


   //-------------------------------------------
   // DFI signals from CP
   //-------------------------------------------
   dwc_ddrctl_ddrc_cpedfi_if #(
       .NUM_RANKS                   (`MEMC_NUM_RANKS           )
      ,.FREQ_RATIO                  (`MEMC_FREQ_RATIO          )
      ,.BANK_BITS                   (`MEMC_BANK_BITS           )
      ,.BG_BITS                     (`MEMC_BG_BITS             )
      ,.CID_WIDTH                   (CID_WIDTH                 )
      ,.ADDR_WIDTH                  (`MEMC_DFI_ADDR_WIDTH      )
      ,.RESET_WIDTH                 (`UMCTL2_RESET_WIDTH       )
      ,.NUM_LANES                   (NUM_LANES                 )
      ,.NUM_DRAM_CLKS               (`MEMC_NUM_CLKS            )
   ) cp_dfiif_dch0(); // DFI signals on CP

   //-------------------------------------------
   // Write Data Interface
   //-------------------------------------------
   wire [`MEMC_DFI_TOTAL_DATA_WIDTH-1:0]                           dfi_wrdata_dch0;
   wire [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0]                         dfi_wrdata_en_dch0;
   wire [`MEMC_DFI_TOTAL_MASK_WIDTH-1:0]                           dfi_wrdata_mask_dch0;
   //-------------------------------------------
   // Read Data Interface
   //-------------------------------------------
   wire [`MEMC_DFI_TOTAL_DATA_WIDTH   -1:0]                        dfi_rddata_dch0;
   wire [`MEMC_DFI_TOTAL_DATA_WIDTH/8 -1:0]                        dfi_rddata_dbi_dch0;
   wire [`MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]                        dfi_rddata_valid_dch0;
   wire [`MEMC_DFI_TOTAL_DATAEN_WIDTH -1:0]                        dfi_rddata_en_dch0;
   //-------------------------------------------
   // Status Interface
   //-------------------------------------------
   assign ddrc_reg_dfi_init_complete      = cp_dfiif_dch0.dfi_init_complete;

   //-------------------------------------------
   // Low Power Control Interface
   //-------------------------------------------
   assign ddrc_reg_dfi_lp_ctrl_ack_stat   = cp_dfiif_dch0.dfi_lp_ctrl_ack;
   assign ddrc_reg_dfi_lp_data_ack_stat   = cp_dfiif_dch0.dfi_lp_data_ack;

   //-------------------------------------------
   // Non-DFI Sideband Interface Signals
   //-------------------------------------------
   wire [`MEMC_DFI_TOTAL_DATAEN_WIDTH*4-1:0]               dwc_ddrphy_snoop_en_dch0;

   //-------------------------------------------
   // WCK Control Interface
   //-------------------------------------------
   wire  [`MEMC_FREQ_RATIO*`MEMC_NUM_RANKS-1:0]             dfi_wck_cs_dch0;
   wire  [`MEMC_FREQ_RATIO-1:0]                             dfi_wck_en_dch0;
   wire  [2*`MEMC_FREQ_RATIO-1:0]                           dfi_wck_toggle_dch0;



// put MEMC_REG_DFI_OUT logic for dbg_dfi_in_retry in top-level,
// will move to dfi_ic as dfi interface and consider dual_channel, sharedac, etc...

   dfi_ic
    #(
       .NUM_RANKS                               (`MEMC_NUM_RANKS)
      ,.DFI0_CS_WIDTH                           (`DDRCTL_DFI0_CS_WIDTH)
      ,.DFI1_CS_WIDTH                           (`DDRCTL_DFI1_CS_WIDTH)
      ,.FREQ_RATIO                              (`MEMC_FREQ_RATIO)
      ,.NUM_CHANNEL                             (`UMCTL2_NUM_DATA_CHANNEL)
      ,.LPDDR_DUAL_CHANNEL_EN                   (`DDRCTL_LPDDR_DUAL_CHANNEL_EN)
      ,.DDR_DCH_HBW                             (`DDRCTL_DDR_DCH_HBW)
      ,.RESET_WIDTH                             (`UMCTL2_RESET_WIDTH)
      ,.NUM_CLKS                                (`MEMC_NUM_CLKS)
      ,.BANK_BITS                               (`MEMC_BANK_BITS)
      ,.BG_BITS                                 (BG_WIDTH)
      ,.CID_WIDTH                               (CID_WIDTH)
      ,.DDRC_TOTAL_DATA_WIDTH                   (`MEMC_DFI_TOTAL_DATA_WIDTH)
      ,.DDRC_TOTAL_DATAEN_WIDTH                 (`MEMC_DFI_TOTAL_DATAEN_WIDTH)
      ,.DDRC_TOTAL_MASK_WIDTH                   (`MEMC_DFI_TOTAL_MASK_WIDTH)
      ,.DRAM_TOTAL_DATA_WIDTH                   (`MEMC_DRAM_TOTAL_DATA_WIDTH)
      ,.DRAM_DATA_WIDTH                         (`DDRCTL_DDR_DRAM_DATA_WIDTH)
      ,.DRAM_ECC_WIDTH                          (`DDRCTL_DDR_DRAM_ECC_WIDTH)
      ,.NUM_DFI                                 (`UMCTL2_NUM_DFI)
      ,.DFI_ADDR_WIDTH                          (`MEMC_DFI_ADDR_WIDTH)
      ,.DFI_BG_WIDTH                            (`DDRCTL_DFI_BG_WIDTH)
      ,.DFI_CID_WIDTH                           (`DDRCTL_DFI_CID_WIDTH)
      ,.DFI_LP_WAKEUP_WIDTH                     (DFI_LP_WAKEUP_WIDTH)
      ,.DFI_PARITY_IN_WIDTH                     (2)
      ,.DFI_DATA_WIDTH                          (`DDRCTL_DFI_DATA_WIDTH)
      ,.DFI_MASK_WIDTH                          (`DDRCTL_DFI_MASK_WIDTH)
      ,.DFI_DATAEN_WIDTH                        (`DDRCTL_DFI_DATAEN_WIDTH)
      ,.REG_DFI_OUT_VAL                         (`MEMC_REG_DFI_OUT_VAL)
      ,.OCCAP_EN                                (OCCAP_EN)
      ,.OCCAP_PIPELINE_EN                       (OCCAP_PIPELINE_EN)
      ,.BCM_VERIF_EN                            (BCM_VERIF_EN)
      ,.BCM_DDRC_N_SYNC                         (BCM_DDRC_N_SYNC)
   )
   U_dfi_ic (
      // --------------------------------------- DDRC0
       .cp_dfiif_dch0                           (cp_dfiif_dch0)
      ,.dfi_reset_n_out                         (dfi_reset_n)
      ,.dfi_wck_cs_dch0                         (dfi_wck_cs_dch0)
      ,.dfi_wck_en_dch0                         (dfi_wck_en_dch0)
      ,.dfi_wck_toggle_dch0                     (dfi_wck_toggle_dch0)
      ,.dfi_wrdata_dch0                         (dfi_wrdata_dch0)
      ,.dfi_wrdata_mask_dch0                    (dfi_wrdata_mask_dch0)
      ,.dfi_wrdata_en_dch0                      (dfi_wrdata_en_dch0)
      ,.dfi_rddata_dch0                         (dfi_rddata_dch0)
      ,.dfi_rddata_dbi_dch0                     (dfi_rddata_dbi_dch0)
      ,.dfi_rddata_valid_dch0                   (dfi_rddata_valid_dch0)
      ,.dfi_rddata_en_dch0                      (dfi_rddata_en_dch0)
      ,.dwc_ddrphy_snoop_en_dch0                (dwc_ddrphy_snoop_en_dch0)

      // --------------------------------------- APB Register
      ,.core_ddrc_core_clk                      (core_ddrc_core_clk)
      ,.core_ddrc_rstn                          (core_ddrc_rstn)
      ,.reg_ddrc_dfi_channel_mode               (reg_ddrc_dfi_channel_mode)
      // --------------------------------------- DFI0
      ,.dfi0_init_start_out                     (dfi0_init_start)
      ,.dfi0_freq_fsp_out                       (dfi0_freq_fsp)
      ,.dfi0_frequency_out                      (dfi0_frequency)
      ,.dfi0_freq_ratio_out                     (dfi0_freq_ratio)
      ,.dfi0_init_complete_in                   (dfi0_init_complete)
      ,.dfi0_lp_ctrl_req_out                    (dfi0_lp_ctrl_req)
      ,.dfi0_lp_ctrl_wakeup_out                 (dfi0_lp_ctrl_wakeup)
      ,.dfi0_lp_ctrl_ack_in                     (dfi0_lp_ctrl_ack)
      ,.dfi0_lp_data_req_out                    (dfi0_lp_data_req)
      ,.dfi0_lp_data_wakeup_out                 (dfi0_lp_data_wakeup)
      ,.dfi0_lp_data_ack_in                     (dfi0_lp_data_ack)
      ,.dfi0_ctrlupd_req_out                    (dfi0_ctrlupd_req)
      ,.dfi0_ctrlupd_ack_in                     (dfi0_ctrlupd_ack)
      ,.dfi0_phyupd_req_in                      (dfi0_phyupd_req)
      ,.dfi0_phyupd_type_in                     (dfi0_phyupd_type)
      ,.dfi0_phyupd_ack_out                     (dfi0_phyupd_ack)
      ,.dfi0_ctrlmsg_req_out                    (dfi0_ctrlmsg_req)
      ,.dfi0_ctrlmsg_out                        (dfi0_ctrlmsg)
      ,.dfi0_ctrlmsg_data_out                   (dfi0_ctrlmsg_data)
      ,.dfi0_ctrlmsg_ack_in                     (dfi0_ctrlmsg_ack)
      ,.dfi0_phymstr_req_in                     (dfi0_phymstr_req)
      ,.dfi0_phymstr_cs_state_in                (dfi0_phymstr_cs_state)
      ,.dfi0_phymstr_state_sel_in               (dfi0_phymstr_state_sel)
      ,.dfi0_phymstr_type_in                    (dfi0_phymstr_type)
      ,.dfi0_phymstr_ack_out                    (dfi0_phymstr_ack)
      ,.dfi0_dram_clk_disable_P0_out            (dfi0_dram_clk_disable_P0)
      ,.dfi0_address_P0_out                     (dfi0_address_P0)
      ,.dfi0_cke_P0_out                         (dfi0_cke_P0)
      ,.dfi0_cs_P0_out                          (dfi0_cs_P0)
      ,.dfi0_wck_cs_P0_out                      (dfi0_wck_cs_P0)
      ,.dfi0_wck_en_P0_out                      (dfi0_wck_en_P0)
      ,.dfi0_wck_toggle_P0_out                  (dfi0_wck_toggle_P0)
      ,.dfi0_wrdata_P0_out                      (dfi0_wrdata_P0)
      ,.dfi0_wrdata_mask_P0_out                 (dfi0_wrdata_mask_P0)
      ,.dfi0_wrdata_en_P0_out                   (dfi0_wrdata_en_P0)
      ,.dfi0_wrdata_cs_P0_out                   (dfi0_wrdata_cs_P0)
      ,.dfi0_rddata_W0_in                       (dfi0_rddata_W0)
      ,.dfi0_rddata_dbi_W0_in                   (dfi0_rddata_dbi_W0)
      ,.dfi0_rddata_valid_W0_in                 (dfi0_rddata_valid_W0)
      ,.dfi0_rddata_en_P0_out                   (dfi0_rddata_en_P0)
      ,.dfi0_rddata_cs_P0_out                   (dfi0_rddata_cs_P0)
      ,.dwc_ddrphy0_snoop_en_P0_out             (dwc_ddrphy0_snoop_en_P0)
      ,.dfi0_dram_clk_disable_P1_out            (dfi0_dram_clk_disable_P1)
      ,.dfi0_address_P1_out                     (dfi0_address_P1)
      ,.dfi0_cke_P1_out                         (dfi0_cke_P1)
      ,.dfi0_cs_P1_out                          (dfi0_cs_P1)
      ,.dfi0_wck_cs_P1_out                      (dfi0_wck_cs_P1)
      ,.dfi0_wck_en_P1_out                      (dfi0_wck_en_P1)
      ,.dfi0_wck_toggle_P1_out                  (dfi0_wck_toggle_P1)
      ,.dfi0_wrdata_P1_out                      (dfi0_wrdata_P1)
      ,.dfi0_wrdata_mask_P1_out                 (dfi0_wrdata_mask_P1)
      ,.dfi0_wrdata_en_P1_out                   (dfi0_wrdata_en_P1)
      ,.dfi0_wrdata_cs_P1_out                   (dfi0_wrdata_cs_P1)
      ,.dfi0_rddata_W1_in                       (dfi0_rddata_W1)
      ,.dfi0_rddata_dbi_W1_in                   (dfi0_rddata_dbi_W1)
      ,.dfi0_rddata_valid_W1_in                 (dfi0_rddata_valid_W1)
      ,.dfi0_rddata_en_P1_out                   (dfi0_rddata_en_P1)
      ,.dfi0_rddata_cs_P1_out                   (dfi0_rddata_cs_P1)
      ,.dwc_ddrphy0_snoop_en_P1_out             (dwc_ddrphy0_snoop_en_P1)
      ,.dfi0_dram_clk_disable_P2_out            (dfi0_dram_clk_disable_P2)
      ,.dfi0_address_P2_out                     (dfi0_address_P2)
      ,.dfi0_cke_P2_out                         (dfi0_cke_P2)
      ,.dfi0_cs_P2_out                          (dfi0_cs_P2)
      ,.dfi0_wck_cs_P2_out                      (dfi0_wck_cs_P2)
      ,.dfi0_wck_en_P2_out                      (dfi0_wck_en_P2)
      ,.dfi0_wck_toggle_P2_out                  (dfi0_wck_toggle_P2)
      ,.dfi0_wrdata_P2_out                      (dfi0_wrdata_P2)
      ,.dfi0_wrdata_mask_P2_out                 (dfi0_wrdata_mask_P2)
      ,.dfi0_wrdata_en_P2_out                   (dfi0_wrdata_en_P2)
      ,.dfi0_wrdata_cs_P2_out                   (dfi0_wrdata_cs_P2)
      ,.dfi0_rddata_W2_in                       (dfi0_rddata_W2)
      ,.dfi0_rddata_dbi_W2_in                   (dfi0_rddata_dbi_W2)
      ,.dfi0_rddata_valid_W2_in                 (dfi0_rddata_valid_W2)
      ,.dfi0_rddata_en_P2_out                   (dfi0_rddata_en_P2)
      ,.dfi0_rddata_cs_P2_out                   (dfi0_rddata_cs_P2)
      ,.dwc_ddrphy0_snoop_en_P2_out             (dwc_ddrphy0_snoop_en_P2)
      ,.dfi0_dram_clk_disable_P3_out            (dfi0_dram_clk_disable_P3)
      ,.dfi0_address_P3_out                     (dfi0_address_P3)
      ,.dfi0_cke_P3_out                         (dfi0_cke_P3)
      ,.dfi0_cs_P3_out                          (dfi0_cs_P3)
      ,.dfi0_wck_cs_P3_out                      (dfi0_wck_cs_P3)
      ,.dfi0_wck_en_P3_out                      (dfi0_wck_en_P3)
      ,.dfi0_wck_toggle_P3_out                  (dfi0_wck_toggle_P3)
      ,.dfi0_wrdata_P3_out                      (dfi0_wrdata_P3)
      ,.dfi0_wrdata_mask_P3_out                 (dfi0_wrdata_mask_P3)
      ,.dfi0_wrdata_en_P3_out                   (dfi0_wrdata_en_P3)
      ,.dfi0_wrdata_cs_P3_out                   (dfi0_wrdata_cs_P3)
      ,.dfi0_rddata_W3_in                       (dfi0_rddata_W3)
      ,.dfi0_rddata_dbi_W3_in                   (dfi0_rddata_dbi_W3)
      ,.dfi0_rddata_valid_W3_in                 (dfi0_rddata_valid_W3)
      ,.dfi0_rddata_en_P3_out                   (dfi0_rddata_en_P3)
      ,.dfi0_rddata_cs_P3_out                   (dfi0_rddata_cs_P3)
      ,.dwc_ddrphy0_snoop_en_P3_out             (dwc_ddrphy0_snoop_en_P3)
      // --------------------------------------- DFI1
      ,.dfi1_init_start_out                     (dfi1_init_start)
      ,.dfi1_freq_fsp_out                       (dfi1_freq_fsp)
      ,.dfi1_frequency_out                      (dfi1_frequency)
      ,.dfi1_freq_ratio_out                     (dfi1_freq_ratio)
      ,.dfi1_init_complete_in                   (dfi1_init_complete)
      ,.dfi1_lp_ctrl_req_out                    (dfi1_lp_ctrl_req)
      ,.dfi1_lp_ctrl_wakeup_out                 (dfi1_lp_ctrl_wakeup)
      ,.dfi1_lp_ctrl_ack_in                     (dfi1_lp_ctrl_ack)
      ,.dfi1_lp_data_req_out                    (dfi1_lp_data_req)
      ,.dfi1_lp_data_wakeup_out                 (dfi1_lp_data_wakeup)
      ,.dfi1_lp_data_ack_in                     (dfi1_lp_data_ack)
      ,.dfi1_ctrlupd_req_out                    (dfi1_ctrlupd_req)
      ,.dfi1_ctrlupd_ack_in                     (dfi1_ctrlupd_ack)
      ,.dfi1_phyupd_req_in                      (dfi1_phyupd_req)
      ,.dfi1_phyupd_type_in                     (dfi1_phyupd_type)
      ,.dfi1_phyupd_ack_out                     (dfi1_phyupd_ack)
      ,.dfi1_ctrlmsg_req_out                    (dfi1_ctrlmsg_req)
      ,.dfi1_ctrlmsg_out                        (dfi1_ctrlmsg)
      ,.dfi1_ctrlmsg_data_out                   (dfi1_ctrlmsg_data)
      ,.dfi1_ctrlmsg_ack_in                     (dfi1_ctrlmsg_ack)
      ,.dfi1_phymstr_req_in                     (dfi1_phymstr_req)
      ,.dfi1_phymstr_cs_state_in                (dfi1_phymstr_cs_state)
      ,.dfi1_phymstr_state_sel_in               (dfi1_phymstr_state_sel)
      ,.dfi1_phymstr_type_in                    (dfi1_phymstr_type)
      ,.dfi1_phymstr_ack_out                    (dfi1_phymstr_ack)
      ,.dfi1_dram_clk_disable_P0_out            (dfi1_dram_clk_disable_P0)
      ,.dfi1_address_P0_out                     (dfi1_address_P0)
      ,.dfi1_cke_P0_out                         (dfi1_cke_P0)
      ,.dfi1_cs_P0_out                          (dfi1_cs_P0)
      ,.dfi1_wck_cs_P0_out                      (dfi1_wck_cs_P0)
      ,.dfi1_wck_en_P0_out                      (dfi1_wck_en_P0)
      ,.dfi1_wck_toggle_P0_out                  (dfi1_wck_toggle_P0)
      ,.dfi1_wrdata_P0_out                      (dfi1_wrdata_P0)
      ,.dfi1_wrdata_mask_P0_out                 (dfi1_wrdata_mask_P0)
      ,.dfi1_wrdata_en_P0_out                   (dfi1_wrdata_en_P0)
      ,.dfi1_wrdata_cs_P0_out                   (dfi1_wrdata_cs_P0)
      ,.dfi1_rddata_W0_in                       (dfi1_rddata_W0)
      ,.dfi1_rddata_dbi_W0_in                   (dfi1_rddata_dbi_W0)
      ,.dfi1_rddata_valid_W0_in                 (dfi1_rddata_valid_W0)
      ,.dfi1_rddata_en_P0_out                   (dfi1_rddata_en_P0)
      ,.dfi1_rddata_cs_P0_out                   (dfi1_rddata_cs_P0)
      ,.dwc_ddrphy1_snoop_en_P0_out             (dwc_ddrphy1_snoop_en_P0)
      ,.dfi1_dram_clk_disable_P1_out            (dfi1_dram_clk_disable_P1)
      ,.dfi1_address_P1_out                     (dfi1_address_P1)
      ,.dfi1_cke_P1_out                         (dfi1_cke_P1)
      ,.dfi1_cs_P1_out                          (dfi1_cs_P1)
      ,.dfi1_wck_cs_P1_out                      (dfi1_wck_cs_P1)
      ,.dfi1_wck_en_P1_out                      (dfi1_wck_en_P1)
      ,.dfi1_wck_toggle_P1_out                  (dfi1_wck_toggle_P1)
      ,.dfi1_wrdata_P1_out                      (dfi1_wrdata_P1)
      ,.dfi1_wrdata_mask_P1_out                 (dfi1_wrdata_mask_P1)
      ,.dfi1_wrdata_en_P1_out                   (dfi1_wrdata_en_P1)
      ,.dfi1_wrdata_cs_P1_out                   (dfi1_wrdata_cs_P1)
      ,.dfi1_rddata_W1_in                       (dfi1_rddata_W1)
      ,.dfi1_rddata_dbi_W1_in                   (dfi1_rddata_dbi_W1)
      ,.dfi1_rddata_valid_W1_in                 (dfi1_rddata_valid_W1)
      ,.dfi1_rddata_en_P1_out                   (dfi1_rddata_en_P1)
      ,.dfi1_rddata_cs_P1_out                   (dfi1_rddata_cs_P1)
      ,.dwc_ddrphy1_snoop_en_P1_out             (dwc_ddrphy1_snoop_en_P1)
      ,.dfi1_dram_clk_disable_P2_out            (dfi1_dram_clk_disable_P2)
      ,.dfi1_address_P2_out                     (dfi1_address_P2)
      ,.dfi1_cke_P2_out                         (dfi1_cke_P2)
      ,.dfi1_cs_P2_out                          (dfi1_cs_P2)
      ,.dfi1_wck_cs_P2_out                      (dfi1_wck_cs_P2)
      ,.dfi1_wck_en_P2_out                      (dfi1_wck_en_P2)
      ,.dfi1_wck_toggle_P2_out                  (dfi1_wck_toggle_P2)
      ,.dfi1_wrdata_P2_out                      (dfi1_wrdata_P2)
      ,.dfi1_wrdata_mask_P2_out                 (dfi1_wrdata_mask_P2)
      ,.dfi1_wrdata_en_P2_out                   (dfi1_wrdata_en_P2)
      ,.dfi1_wrdata_cs_P2_out                   (dfi1_wrdata_cs_P2)
      ,.dfi1_rddata_W2_in                       (dfi1_rddata_W2)
      ,.dfi1_rddata_dbi_W2_in                   (dfi1_rddata_dbi_W2)
      ,.dfi1_rddata_valid_W2_in                 (dfi1_rddata_valid_W2)
      ,.dfi1_rddata_en_P2_out                   (dfi1_rddata_en_P2)
      ,.dfi1_rddata_cs_P2_out                   (dfi1_rddata_cs_P2)
      ,.dwc_ddrphy1_snoop_en_P2_out             (dwc_ddrphy1_snoop_en_P2)
      ,.dfi1_dram_clk_disable_P3_out            (dfi1_dram_clk_disable_P3)
      ,.dfi1_address_P3_out                     (dfi1_address_P3)
      ,.dfi1_cke_P3_out                         (dfi1_cke_P3)
      ,.dfi1_cs_P3_out                          (dfi1_cs_P3)
      ,.dfi1_wck_cs_P3_out                      (dfi1_wck_cs_P3)
      ,.dfi1_wck_en_P3_out                      (dfi1_wck_en_P3)
      ,.dfi1_wck_toggle_P3_out                  (dfi1_wck_toggle_P3)
      ,.dfi1_wrdata_P3_out                      (dfi1_wrdata_P3)
      ,.dfi1_wrdata_mask_P3_out                 (dfi1_wrdata_mask_P3)
      ,.dfi1_wrdata_en_P3_out                   (dfi1_wrdata_en_P3)
      ,.dfi1_wrdata_cs_P3_out                   (dfi1_wrdata_cs_P3)
      ,.dfi1_rddata_W3_in                       (dfi1_rddata_W3)
      ,.dfi1_rddata_dbi_W3_in                   (dfi1_rddata_dbi_W3)
      ,.dfi1_rddata_valid_W3_in                 (dfi1_rddata_valid_W3)
      ,.dfi1_rddata_en_P3_out                   (dfi1_rddata_en_P3)
      ,.dfi1_rddata_cs_P3_out                   (dfi1_rddata_cs_P3)
      ,.dwc_ddrphy1_snoop_en_P3_out             (dwc_ddrphy1_snoop_en_P3)
   );

   wire                                                    init_mr_done_out_unused;
   wire                                                    dfi_reset_n_ref_unused;
   // CDC logics for LPDDR4 Initialization Handshake Interface (dfi_reset_n_in/init_mr_done_in)
   // These are required only when LPDDR4 Single Channel mode is selected, but these
   // are implemented except for LPDDR4 Dual channel mode
   wire dfi_reset_n_in_cclk;
   wire init_mr_done_in_cclk;

      DWC_ddr_umctl2_bitsync
       #(
         .BCM_SYNC_TYPE  (BCM_LP4DCI_N_SYNC),
         .BCM_VERIF_EN   (BCM_VERIF_EN)
      ) U_bitsync_dfi_reset_n_in (
         .clk_d          (core_ddrc_core_clk),
         .rst_d_n        (core_ddrc_rstn),
         .data_s         (dfi_reset_n_in),
         .data_d         (dfi_reset_n_in_cclk)
      );

      DWC_ddr_umctl2_bitsync
       #(
         .BCM_SYNC_TYPE  (BCM_LP4DCI_N_SYNC),
         .BCM_VERIF_EN   (BCM_VERIF_EN)
      ) U_bitsync_init_mr_done_in (
         .clk_d          (core_ddrc_core_clk),
         .rst_d_n        (core_ddrc_rstn),
         .data_s         (init_mr_done_in),
         .data_d         (init_mr_done_in_cclk)
      );

   // channel 0 latency adjustment
      wire [$bits(regmux_ddrc_dfi_t_rddata_en)-1:0] regmux_ddrc_dfi_t_rddata_en_dch0;
      wire [$bits(regmux_ddrc_dfi_tphy_wrlat) -1:0] regmux_ddrc_dfi_tphy_wrlat_dch0;
         assign regmux_ddrc_dfi_t_rddata_en_dch0   = regmux_ddrc_dfi_t_rddata_en;
         assign regmux_ddrc_dfi_tphy_wrlat_dch0    = regmux_ddrc_dfi_tphy_wrlat;


localparam MAX_NUM_NIBBLES = 20;





    dwc_ddrctl_ddrc
    
        #(
          .UMCTL2_WDATARAM_DW             (UMCTL2_WDATARAM_DW),
          .CHANNEL_NUM                    (0),
          .SHARED_AC                      (SHARED_AC),
          .SHARED_AC_INTERLEAVE           (DATA_CHANNEL_INTERLEAVE),
          .BCM_VERIF_EN                   (BCM_VERIF_EN),
          .BCM_DDRC_N_SYNC                (BCM_DDRC_N_SYNC),
          .BCM_F_SYNC_TYPE_P2C            (BCM_F_SYNC_TYPE_P2C),
          .MEMC_ECC_SUPPORT               (MEMC_ECC_SUPPORT),
          .UMCTL2_SEQ_BURST_MODE          (UMCTL2_SEQ_BURST_MODE),
          .UMCTL2_PHY_SPECIAL_IDLE        (UMCTL2_PHY_SPECIAL_IDLE),
          .RETRY_MAX_ADD_RD_LAT           (RETRY_MAX_ADD_RD_LAT),
          .RETRY_MAX_ADD_RD_LAT_LG2       (RETRY_MAX_ADD_RD_LAT_LG2),
          .NUM_LANES                      (NUM_LANES),
          .MAX_NUM_NIBBLES                (MAX_NUM_NIBBLES),
          .OCPAR_EN                       (OCPAR_EN),
          .OCECC_EN                       (OCECC_EN),
          .OCECC_XPI_RD_GRANU             (OCECC_XPI_RD_GRANU),
          .OCECC_MR_RD_GRANU              (OCECC_MR_RD_GRANU),
          .OCECC_MR_BNUM_WIDTH            (OCECC_MR_BNUM_WIDTH),
          .OCCAP_EN                       (OCCAP_EN),
          .OCCAP_PIPELINE_EN              (OCCAP_PIPELINE_EN),
          .CP_ASYNC                       (P_ASYNC_EN),
          .NPORTS                         (INT_NPORTS_DATA),
          .NPORTS_LG2                     (UMCTL2_A_NPORTS_LG2),
          .A_SYNC_TABLE                   (A_SYNC_TABLE_MASKED),
          .CMD_LEN_BITS                   (UMCTL2_CMD_LEN_BITS),
          .WRDATA_CYCLES                  (WRDATA_CYCLES),
          .AM_DCH_WIDTH                   (AM_DCH_WIDTH),
          .AM_CS_WIDTH                    (AM_CS_WIDTH),
          .AM_CID_WIDTH                   (AM_CID_WIDTH),
          .AM_BANK_WIDTH                  (AM_BANK_WIDTH),
          .AM_BG_WIDTH                    (AM_BG_WIDTH),
          .AM_ROW_WIDTH                   (AM_ROW_WIDTH),
          .AM_COL_WIDTH_H                 (AM_COL_WIDTH_H),
          .AM_COL_WIDTH_L                 (AM_COL_WIDTH_L),
          .DFI_T_CTRLMSG_RESP_WIDTH       (DFI_T_CTRLMSG_RESP_WIDTH),
          .DFI_CTRLMSG_DATA_WIDTH         (DFI_CTRLMSG_DATA_WIDTH),
          .DFI_CTRLMSG_CMD_WIDTH          (DFI_CTRLMSG_CMD_WIDTH)
          )
   U_ddrc (
           .core_ddrc_core_clk                    (core_ddrc_core_clk),
           .core_ddrc_rstn                        (core_ddrc_rstn),

           .bsm_clk                               (bsm_clk           ),
           .bsm_clk_en                            (bsm_clk_en        ),
           .bsm_clk_on                            (reg_ddrc_bsm_clk_on),


           .hif_cmd_valid                         (arb_hif_cmd_valid),
           .hif_cmd_type                          (arb_hif_cmd_type),
           .hif_cmd_addr                          (arb_hif_cmd_addr),
           .hif_cmd_pri                           (arb_hif_cmd_pri),
           .hif_cmd_token                         (arb_hif_cmd_token),
           .hif_cmd_length                        (arb_hif_cmd_length),
           .hif_cmd_wdata_ptr                     (arb_hif_cmd_wdata_ptr),
           .hif_cmd_autopre                       (arb_hif_cmd_autopre),

           .hif_wdata_valid                       (arb_hif_wdata_valid),
           .hif_wdata                             (arb_hif_wdata),
           .hif_wdata_mask                        (arb_hif_wdata_mask),
           .hif_wdata_end                         (arb_hif_wdata_end),
           .hif_wdata_parity                      (arb_hif_wdata_parity),

           .hif_wdata_stall                        (ddrc_hif_wdata_stall),
           .hif_go2critical_lpr                    (arb_hif_go2critical_lpr),
           .hif_go2critical_hpr                    (arb_hif_go2critical_hpr),
           .hif_go2critical_wr                     (arb_hif_go2critical_wr),
           .hif_go2critical_l1_lpr                 (arb_hif_go2critical_l1_lpr),
           .hif_go2critical_l1_hpr                 (arb_hif_go2critical_l1_hpr),
           .hif_go2critical_l1_wr                  (arb_hif_go2critical_l1_wr),
           .hif_go2critical_l2_lpr                 (arb_hif_go2critical_l2_lpr),
           .hif_go2critical_l2_hpr                 (arb_hif_go2critical_l2_hpr),
           .hif_go2critical_l2_wr                  (arb_hif_go2critical_l2_wr),
           .hif_cmd_stall                          (ddrc_hif_cmd_stall),
           .hif_wdata_ptr                          (ddrc_hif_wdata_ptr),
           .hif_wdata_ptr_valid                    (ddrc_hif_wdata_ptr_valid),
           .hif_wdata_ptr_addr_err                 (ddrc_hif_wdata_ptr_addr_err),
           .hif_lpr_credit                         (ddrc_hif_lpr_credit),
           .hif_wr_credit                          (ddrc_hif_wr_credit),
           .hif_hpr_credit                         (ddrc_hif_hpr_credit),
           .hif_wrecc_credit                       (ddrc_hif_wrecc_credit),
           .reg_ddrc_mr_wr                         (reg_ddrc_mr_wr),
           .reg_ddrc_mr_type                       (reg_ddrc_mr_type),
           .reg_ddrc_mr_addr                       (reg_ddrc_mr_addr),
           .reg_ddrc_mr_data                       (reg_ddrc_mr_data),
           .ddrc_reg_mr_wr_busy                    (ddrc_reg_mr_wr_busy),
           .reg_ddrc_burst_mode                    (reg_ddrc_burst_mode_int),
           .hif_rdata_valid                        (ddrc_hif_rdata_valid),
           .hif_rdata_end                          (ddrc_hif_rdata_end),
           .hif_rdata_token                        (ddrc_hif_rdata_token),
           .hif_rdata                              (ddrc_hif_rdata),
           .hif_rdata_parity                       (ddrc_hif_rdata_parity),
           .hif_rdata_addr_err                     (ddrc_hif_rdata_addr_err),
           .hif_cmd_q_not_empty                    (hif_cmd_q_not_empty),

           .cactive_in_ddrc                        (cactive_in_ddrc_dch0),
           .cactive_in_ddrc_async                  (cactive_in_ddrc_async_dch0),
           .csysreq_ddrc                           (csysreq_ddrc),
           .csysack_ddrc                           (csysack_ddrc),
           .cactive_ddrc                           (cactive_ddrc),

           .stat_ddrc_reg_selfref_type             (stat_ddrc_reg_selfref_type),

           .ddrc_reg_wr_q_empty                    (ddrc_reg_dbg_wr_q_empty),
           .ddrc_reg_rd_q_empty                    (ddrc_reg_dbg_rd_q_empty),
           .ddrc_reg_wr_data_pipeline_empty        (ddrc_reg_wr_data_pipeline_empty),
           .ddrc_reg_rd_data_pipeline_empty        (ddrc_reg_rd_data_pipeline_empty),


           .cp_dfiif                               (cp_dfiif_dch0),

           .dfi_wrdata                             (dfi_wrdata_dch0),
           .dfi_wrdata_en                          (dfi_wrdata_en_dch0),
           .dfi_wrdata_mask                        (dfi_wrdata_mask_dch0),
           .dfi_rddata                             (dfi_rddata_dch0),
           .dfi_rddata_en                          (dfi_rddata_en_dch0),
           .dfi_rddata_valid                       (dfi_rddata_valid_dch0),
           .dfi_rddata_dbi                         (dfi_rddata_dbi_dch0),
           .dfi_wck_cs                             (dfi_wck_cs_dch0),
           .dfi_wck_en                             (dfi_wck_en_dch0),
           .dfi_wck_toggle                         (dfi_wck_toggle_dch0),
           .reg_ddrc_dfi_init_start                (reg_ddrc_dfi_init_start),
           .reg_ddrc_dfi_frequency                 (reg_ddrc_dfi_frequency),
           .reg_ddrc_dfi_freq_fsp                  (reg_ddrc_dfi_freq_fsp),
           .init_mr_done_in                        (init_mr_done_in_cclk),
           .init_mr_done_out                       (init_mr_done_out),
           .dfi_reset_n_in                         (dfi_reset_n_in_cclk),
           .dfi_reset_n_ref                        (dfi_reset_n_ref),
           .reg_ddrc_frequency_ratio               (regmux_ddrc_frequency_ratio),
           .reg_ddrc_phy_dbi_mode                  (reg_ddrc_phy_dbi_mode),
           .reg_ddrc_wr_dbi_en                     (reg_ddrc_wr_dbi_en),
           .reg_ddrc_rd_dbi_en                     (reg_ddrc_rd_dbi_en),
           .reg_ddrc_dm_en                         (reg_ddrc_dm_en),
           .reg_ddrc_dfi_init_complete_en          (reg_ddrc_dfi_init_complete_en),
           .reg_ddrc_lp_optimized_write            (reg_ddrc_lp_optimized_write), // To save power consumption LPDDR4 write DQ is set to 8'hF8 if this is set to 1 (masked + DBI)

           .wdataram_din                           (wdataram_din_int),
           .wdataram_dout                          (wdataram_dout_int),
           .wdataram_mask                          (wdataram_mask_int),
           .wdataram_wr                            (wdataram_wr),
           .wdataram_raddr                         (wdataram_raddr),
           .wdataram_re                            (wdataram_re),
           .wdataram_waddr                         (wdataram_waddr),
           .wdataram_din_par                       (wdataram_din_par_int),
           .wdataram_dout_par                      (wdataram_dout_par_int),
           .reg_ddrc_en_dfi_dram_clk_disable       (reg_ddrc_en_dfi_dram_clk_disable),
           .reg_ddrc_powerdown_en                  (reg_ddrc_powerdown_en),
           .reg_ddrc_selfref_sw                    (reg_ddrc_selfref_sw),
           .reg_ddrc_hw_lp_en                      (reg_ddrc_hw_lp_en),
           .reg_ddrc_hw_lp_exit_idle_en            (reg_ddrc_hw_lp_exit_idle_en),
           .reg_ddrc_hw_lp_idle_x32                (regmux_ddrc_hw_lp_idle_x32_div),
           .reg_ddrc_data_bus_width                (reg_ddrc_data_bus_width_int),
           .reg_ddrc_selfref_to_x32                (regmux_ddrc_selfref_to_x32_div),
           .reg_ddrc_refresh_burst                 (reg_ddrc_refresh_burst),

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
           .reg_ddrc_rdwr_idle_gap                 (regmux_ddrc_rdwr_idle_gap),
           .reg_ddrc_pageclose                     (reg_ddrc_pageclose),
           .reg_ddrc_pageclose_timer               (regmux_ddrc_pageclose_timer),
           .reg_ddrc_page_hit_limit_rd             (reg_ddrc_page_hit_limit_rd),
           .reg_ddrc_page_hit_limit_wr             (reg_ddrc_page_hit_limit_wr),
           .reg_ddrc_opt_hit_gt_hpr                (reg_ddrc_opt_hit_gt_hpr),
           .reg_ddrc_dis_speculative_act          (reg_ddrc_dis_speculative_act),
           .reg_ddrc_prefer_read                   (reg_ddrc_prefer_read),
           .reg_ddrc_lpr_num_entries               (reg_ddrc_lpr_num_entries),
           .reg_ddrc_lpr_num_entries_changed       (lpr_num_entries_changed),
           .reg_ddrc_hpr_max_starve                (regmux_ddrc_hpr_max_starve),
           .reg_ddrc_hpr_xact_run_length           (regmux_ddrc_hpr_xact_run_length),
           .reg_ddrc_lpr_max_starve                (regmux_ddrc_lpr_max_starve),
           .reg_ddrc_lpr_xact_run_length           (regmux_ddrc_lpr_xact_run_length),
           .reg_ddrc_w_max_starve                  (regmux_ddrc_w_max_starve),
           .reg_ddrc_w_xact_run_length             (regmux_ddrc_w_xact_run_length),
           .reg_ddrc_refresh_update_level          (reg_ddrc_refresh_update_level),
           .reg_ddrc_t_rc                          (regmux_ddrc_t_rc_div),
           .reg_ddrc_t_rfc_min                     (regmux_ddrc_t_rfc_min_div),
           .reg_ddrc_t_rfc_min_ab                  (regmux_ddrc_t_rfc_min_ab_div),
           .reg_ddrc_t_pbr2pbr                     (regmux_ddrc_t_pbr2pbr_div),
           .reg_ddrc_t_pbr2act                     (regmux_ddrc_t_pbr2act),
           .reg_ddrc_t_xsr                         (regmux_ddrc_t_xsr_div),
           .reg_ddrc_t_refi_x1_sel              (regmux_ddrc_t_refi_x1_sel),
           .reg_ddrc_t_refi_x1_x32              (regmux_ddrc_t_refi_x1_x32_div),
           .reg_ddrc_wr2pre                        (regmux_ddrc_wr2pre_div),
           .reg_ddrc_wra2pre                       (regmux_ddrc_wra2pre_div),
           .reg_ddrc_powerdown_to_x32              (regmux_ddrc_powerdown_to_x32_div),
           .reg_ddrc_t_faw                         (regmux_ddrc_t_faw_div),
           .reg_ddrc_t_ras_max                     (regmux_ddrc_t_ras_max_div),
           .reg_ddrc_t_ras_min                     (regmux_ddrc_t_ras_min_div),
           .reg_ddrc_dfi_t_rddata_en               (regmux_ddrc_dfi_t_rddata_en_dch0),
           .reg_ddrc_dfi_tphy_wrdata               (regmux_ddrc_dfi_tphy_wrdata),
           .reg_ddrc_dfi_t_ctrlup_min              (reg_ddrc_dfi_t_ctrlup_min_freq0),
           .reg_ddrc_dfi_t_ctrlup_max              (reg_ddrc_dfi_t_ctrlup_max_freq0),
           .reg_ddrc_write_latency                 (regmux_ddrc_write_latency_div),
           .reg_ddrc_read_latency                  (regmux_ddrc_read_latency_div),
           .reg_ddrc_dfi_tphy_wrlat                (regmux_ddrc_dfi_tphy_wrlat_dch0),

           .reg_ddrc_dfi_data_cs_polarity          (reg_ddrc_dfi_data_cs_polarity),
           .reg_ddrc_dfi_tphy_wrcslat              (regmux_ddrc_dfi_tphy_wrcslat),
           .reg_ddrc_dfi_tphy_rdcslat              (regmux_ddrc_dfi_tphy_rdcslat),
           .reg_ddrc_rd2wr                         (regmux_ddrc_rd2wr_div),
           .reg_ddrc_wr2rd                         (regmux_ddrc_wr2rd_div),
           .reg_ddrc_wr2rd_s                       (regmux_ddrc_wr2rd_s_div),
           .reg_ddrc_t_xp                          (regmux_ddrc_t_xp_div),
           .reg_ddrc_rd2pre                        (regmux_ddrc_rd2pre_div),
           .reg_ddrc_rda2pre                       (regmux_ddrc_rda2pre_div),
           .reg_ddrc_t_rcd                         (regmux_ddrc_t_rcd_div),
           .reg_ddrc_t_cke                         (regmux_ddrc_t_cke_div),
           .reg_ddrc_t_ccd                         (regmux_ddrc_t_ccd_div),
           .reg_ddrc_t_ccd_s                       (regmux_ddrc_t_ccd_s_div),
           .reg_ddrc_odtloff                       (regmux_ddrc_odtloff_div),
           .reg_ddrc_t_ccd_mw                      (regmux_ddrc_t_ccd_mw_div),
           .reg_ddrc_rd2mr                         (regmux_ddrc_rd2mr_div),
           .reg_ddrc_wr2mr                         (regmux_ddrc_wr2mr_div),
           .reg_ddrc_dis_trefi_x6x8                (reg_ddrc_dis_trefi_x6x8),
           .reg_ddrc_dis_trefi_x0125               (reg_ddrc_dis_trefi_x0125),
           .reg_ddrc_t_ppd                         (regmux_ddrc_t_ppd_div),
           .reg_ddrc_rd2wr_s                       (regmux_ddrc_rd2wr_s),
           .reg_ddrc_mrr2rd                        (regmux_ddrc_mrr2rd),
           .reg_ddrc_mrr2wr                        (regmux_ddrc_mrr2wr),
           .reg_ddrc_mrr2mrw                       (regmux_ddrc_mrr2mrw),
           .reg_ddrc_wck_on                        (reg_ddrc_wck_on),
           .reg_ddrc_max_rd_sync                   (regmux_ddrc_max_rd_sync),
           .reg_ddrc_max_wr_sync                   (regmux_ddrc_max_wr_sync),
           .reg_ddrc_dfi_twck_delay                (regmux_ddrc_dfi_twck_delay  ),
           .reg_ddrc_dfi_twck_en_rd                (regmux_ddrc_dfi_twck_en_rd      ),
           .reg_ddrc_dfi_twck_en_wr                (regmux_ddrc_dfi_twck_en_wr      ),
           .reg_ddrc_dfi_twck_dis                  (regmux_ddrc_dfi_twck_dis        ),
           .reg_ddrc_dfi_twck_fast_toggle          (regmux_ddrc_dfi_twck_fast_toggle),
           .reg_ddrc_dfi_twck_toggle               (regmux_ddrc_dfi_twck_toggle     ),
           .reg_ddrc_dfi_twck_toggle_cs            (regmux_ddrc_dfi_twck_toggle_cs  ),
           .reg_ddrc_dfi_twck_toggle_post          (regmux_ddrc_dfi_twck_toggle_post),
           .reg_ddrc_t_rrd                         (regmux_ddrc_t_rrd_div),
           .reg_ddrc_t_rrd_s                       (regmux_ddrc_t_rrd_s_div),
           .reg_ddrc_refresh_margin                (regmux_ddrc_refresh_margin_div),
           .reg_ddrc_t_rp                          (regmux_ddrc_t_rp_div),
           .reg_ddrc_refresh_to_x1_x32             (regmux_ddrc_refresh_to_x1_x32_div),
           .reg_ddrc_en_2t_timing_mode             (reg_ddrc_en_2t_timing_mode_int),

           .reg_ddrc_prefer_write                  (reg_ddrc_prefer_write),
           .reg_ddrc_t_mr                          (regmux_ddrc_t_mr_div),
           .reg_ddrc_pre_cke_x1024                 (reg_ddrc_pre_cke_x1024),
           .reg_ddrc_post_cke_x1024                (reg_ddrc_post_cke_x1024),
           .reg_ddrc_emr2                          (regmux_ddrc_emr2),
           .reg_ddrc_emr3                          (regmux_ddrc_emr3),
           .reg_ddrc_mr                            (regmux_ddrc_mr),
           .reg_ddrc_emr                           (regmux_ddrc_emr),
           .reg_ddrc_mr4                           (regmux_ddrc_mr4),
           .reg_ddrc_mr5                           (regmux_ddrc_mr5),
           .reg_ddrc_mr6                           (regmux_ddrc_mr6),
           .reg_ddrc_mr22                          (regmux_ddrc_mr22),
           .reg_ddrc_dis_wc                        (reg_ddrc_dis_wc),
           .reg_ddrc_dis_dq                        (reg_ddrc_dis_dq),
           .reg_ddrc_dis_hif                       (reg_ddrc_dis_hif),
           .reg_ddrc_rank_refresh                  (reg_ddrc_rank_refresh),
           .ddrc_reg_rank_refresh_busy             (ddrc_reg_rank_refresh_busy),
           .reg_ddrc_dis_auto_refresh              (reg_ddrc_dis_auto_refresh),
           .reg_ddrc_ctrlupd                       (reg_ddrc_ctrlupd),
           .ddrc_reg_ctrlupd_busy                  (ddrc_reg_ctrlupd_busy),
           .reg_ddrc_dis_auto_ctrlupd              (reg_ddrc_dis_auto_ctrlupd),
           .reg_ddrc_dis_auto_ctrlupd_srx          (reg_ddrc_dis_auto_ctrlupd_srx),
           .reg_ddrc_ctrlupd_pre_srx               (reg_ddrc_ctrlupd_pre_srx),
           .reg_ddrc_addrmap_bg_b0                 (reg_ddrc_addrmap_bg_b0_map0),
           .reg_ddrc_addrmap_bg_b1                 (reg_ddrc_addrmap_bg_b1_map0),
           .reg_ddrc_addrmap_bank_b0               (reg_ddrc_addrmap_bank_b0_map0),
           .reg_ddrc_addrmap_bank_b1               (reg_ddrc_addrmap_bank_b1_map0),
           .reg_ddrc_addrmap_bank_b2               (reg_ddrc_addrmap_bank_b2_map0),
           .reg_ddrc_addrmap_col_b3                (reg_ddrc_addrmap_col_b3_map0),
           .reg_ddrc_addrmap_col_b4                (reg_ddrc_addrmap_col_b4_map0),
           .reg_ddrc_addrmap_col_b5                (reg_ddrc_addrmap_col_b5_map0),
           .reg_ddrc_addrmap_col_b6                (reg_ddrc_addrmap_col_b6_map0),
           .reg_ddrc_addrmap_col_b7                (reg_ddrc_addrmap_col_b7_map0),
           .reg_ddrc_addrmap_col_b8                (reg_ddrc_addrmap_col_b8_map0),
           .reg_ddrc_addrmap_col_b9                (reg_ddrc_addrmap_col_b9_map0),
           .reg_ddrc_addrmap_col_b10               (reg_ddrc_addrmap_col_b10_map0),
           .reg_ddrc_addrmap_row_b0                (reg_ddrc_addrmap_row_b0_map0),
           .reg_ddrc_addrmap_row_b1                (reg_ddrc_addrmap_row_b1_map0),
           .reg_ddrc_addrmap_row_b2                (reg_ddrc_addrmap_row_b2_map0),
           .reg_ddrc_addrmap_row_b3                (reg_ddrc_addrmap_row_b3_map0),
           .reg_ddrc_addrmap_row_b4                (reg_ddrc_addrmap_row_b4_map0),
           .reg_ddrc_addrmap_row_b5                (reg_ddrc_addrmap_row_b5_map0),
           .reg_ddrc_addrmap_row_b6                (reg_ddrc_addrmap_row_b6_map0),
           .reg_ddrc_addrmap_row_b7                (reg_ddrc_addrmap_row_b7_map0),
           .reg_ddrc_addrmap_row_b8                (reg_ddrc_addrmap_row_b8_map0),
           .reg_ddrc_addrmap_row_b9                (reg_ddrc_addrmap_row_b9_map0),
           .reg_ddrc_addrmap_row_b10               (reg_ddrc_addrmap_row_b10_map0),
           .reg_ddrc_addrmap_row_b11               (reg_ddrc_addrmap_row_b11_map0),
           .reg_ddrc_addrmap_row_b12               (reg_ddrc_addrmap_row_b12_map0),
           .reg_ddrc_addrmap_row_b13               (reg_ddrc_addrmap_row_b13_map0),
           .reg_ddrc_addrmap_row_b14               (reg_ddrc_addrmap_row_b14_map0),
           .reg_ddrc_addrmap_row_b15               (reg_ddrc_addrmap_row_b15_map0),
           .reg_ddrc_addrmap_row_b16               (reg_ddrc_addrmap_row_b16_map0),
           .reg_ddrc_addrmap_row_b17               (reg_ddrc_addrmap_row_b17_map0),
           .reg_ddrc_rank0_wr_odt                  (reg_ddrc_rank0_wr_odt),
           .reg_ddrc_rank0_rd_odt                  (reg_ddrc_rank0_rd_odt),
           .reg_ddrc_burst_rdwr                    (reg_ddrc_burst_rdwr),
           .reg_ddrc_selfref_en                    (reg_ddrc_selfref_en),
           .reg_ddrc_mr_rank                       (reg_ddrc_mr_rank),
           .reg_ddrc_dfi_t_ctrlupd_interval_min_x1024   (regmux_ddrc_dfi_t_ctrlupd_interval_min_x1024),
           .reg_ddrc_dfi_t_ctrlupd_interval_max_x1024   (regmux_ddrc_dfi_t_ctrlupd_interval_max_x1024),
           .ddrc_reg_dbg_stall                     (ddrc_reg_dbg_stall),
           .ddrc_reg_dbg_w_q_depth                 (ddrc_reg_dbg_w_q_depth),
           .ddrc_reg_dbg_lpr_q_depth               (ddrc_reg_dbg_lpr_q_depth),
           .ddrc_reg_dbg_hpr_q_depth               (ddrc_reg_dbg_hpr_q_depth),
           .reg_ddrc_dis_auto_zq                   (reg_ddrc_dis_auto_zq),
           .reg_ddrc_dis_srx_zqcl                  (reg_ddrc_dis_srx_zqcl),
           .reg_ddrc_zq_resistor_shared            (reg_ddrc_zq_resistor_shared),

           .reg_ddrc_t_zq_long_nop                 (regmux_ddrc_t_zq_long_nop_div),         // time to wait in ZQCL during init sequence
           .reg_ddrc_t_zq_short_nop                (regmux_ddrc_t_zq_short_nop_div),        // time to wait in ZQCS during init sequence
           .reg_ddrc_t_zq_short_interval_x1024     (regmux_ddrc_t_zq_short_interval_x1024_div),
           .reg_ddrc_zq_calib_short                (reg_ddrc_zq_calib_short),
           .ddrc_reg_zq_calib_short_busy           (ddrc_reg_zq_calib_short_busy),
           .reg_ddrc_sw_init_int                   (reg_ddrc_sw_init_int),
           .reg_ddrc_dram_rstn_x1024               (reg_ddrc_dram_rstn_x1024),          // time for dram reset to stay low
           .reg_ddrc_derate_mr4_tuf_dis            (reg_ddrc_derate_mr4_tuf_dis),
           .derate_sync_ack_c2p                    (derate_sync_ack_c2p),
           .core_derate_temp_limit_intr            (core_derate_temp_limit_intr),

          .reg_ddrc_active_derate_byte_rank0       (reg_ddrc_active_derate_byte_rank0),

          .reg_ddrc_dbg_mr4_rank_sel               (reg_ddrc_dbg_mr4_rank_sel),
          .reg_ddrc_dbg_mr4_grp_sel                (reg_ddrc_dbg_mr4_grp_sel),
          .ddrc_reg_dbg_mr4_byte0                  (ddrc_reg_dbg_mr4_byte0),
          .ddrc_reg_dbg_mr4_byte1                  (ddrc_reg_dbg_mr4_byte1),
          .ddrc_reg_dbg_mr4_byte2                  (ddrc_reg_dbg_mr4_byte2),
          .ddrc_reg_dbg_mr4_byte3                  (ddrc_reg_dbg_mr4_byte3),

           .reg_ddrc_lpddr4_refresh_mode           (reg_ddrc_lpddr4_refresh_mode),
           .reg_ddrc_zq_reset                      (reg_ddrc_zq_reset),
           .reg_ddrc_t_zq_reset_nop                (regmux_ddrc_t_zq_reset_nop_div),
           .ddrc_reg_zq_reset_busy                 (ddrc_reg_zq_reset_busy),
           .reg_ddrc_derate_enable                 (reg_ddrc_derate_enable),
           .reg_ddrc_derated_t_rcd                 (regmux_ddrc_derated_t_rcd_div),
           .reg_ddrc_derated_t_ras_min             (regmux_ddrc_derated_t_ras_min_div),
           .reg_ddrc_derated_t_rp                  (regmux_ddrc_derated_t_rp_div),
           .reg_ddrc_derated_t_rrd                 (regmux_ddrc_derated_t_rrd_div),
           .reg_ddrc_derated_t_rc                  (regmux_ddrc_derated_t_rc_div),
           .reg_ddrc_mr4_read_interval             (regmux_ddrc_mr4_read_interval_div),
           .reg_ddrc_derate_mr4_pause_fc           (reg_ddrc_derate_mr4_pause_fc),
           .reg_ddrc_per_bank_refresh              (reg_ddrc_per_bank_refresh),
           .reg_ddrc_auto_refab_en                 (reg_ddrc_auto_refab_en),
           .reg_ddrc_refresh_to_ab_x32             (regmux_ddrc_refresh_to_ab_x32_div),
           .hif_refresh_req_bank                   (hif_refresh_req_bank),
           .reg_ddrc_lpddr4                        (reg_ddrc_lpddr4),               //1:LPDDR4 device
           .reg_ddrc_lpddr5                        (reg_ddrc_lpddr5  ),
           .reg_ddrc_bank_org                      (regmux_ddrc_bank_org),
           .reg_ddrc_lpddr4_diff_bank_rwa2pre      (regmux_ddrc_lpddr4_diff_bank_rwa2pre_div),
           .reg_ddrc_stay_in_selfref               (reg_ddrc_stay_in_selfref),
           .reg_ddrc_t_cmdcke                      (regmux_ddrc_t_cmdcke_div),
           .reg_ddrc_dsm_en                        (reg_ddrc_dsm_en),
           .reg_ddrc_t_pdn                         (regmux_ddrc_t_pdn),
           .reg_ddrc_t_xsr_dsm_x1024               (regmux_ddrc_t_xsr_dsm_x1024),
           .reg_ddrc_t_csh                         (regmux_ddrc_t_csh),
           .reg_ddrc_nonbinary_device_density      (reg_ddrc_nonbinary_device_density_map0),
           .hif_mrr_data                           (hif_mrr_data),
           .hif_mrr_data_valid                     (hif_mrr_data_valid),
           .ddrc_reg_selfref_cam_not_empty         (ddrc_reg_selfref_cam_not_empty),
           .ddrc_reg_selfref_state                 (ddrc_reg_selfref_state),
           .reg_ddrc_mrr_done_clr                  (reg_ddrc_mrr_done_clr),
           .ddrc_reg_mrr_done                      (ddrc_reg_mrr_done    ),
           .ddrc_reg_mrr_data_lwr                  (ddrc_reg_mrr_data_lwr),
           .ddrc_reg_mrr_data_upr                  (ddrc_reg_mrr_data_upr),
           .ddrc_reg_operating_mode                (ddrc_reg_operating_mode),
           .ddrc_reg_selfref_type                  (ddrc_reg_selfref_type),
           .reg_ddrc_dfi_phyupd_en                 (reg_ddrc_dfi_phyupd_en),

           .reg_ddrc_dfi_phymstr_en                (reg_ddrc_dfi_phymstr_en),
           .reg_ddrc_dfi_phymstr_blk_ref_x32       (reg_ddrc_dfi_phymstr_blk_ref_x32),
           .reg_ddrc_dis_cam_drain_selfref         (reg_ddrc_dis_cam_drain_selfref),
           .reg_ddrc_lpddr4_sr_allowed             (reg_ddrc_lpddr4_sr_allowed),
           .reg_ddrc_lpddr4_opt_act_timing         (reg_ddrc_lpddr4_opt_act_timing),
           .reg_ddrc_lpddr5_opt_act_timing         (reg_ddrc_lpddr5_opt_act_timing),
           .reg_ddrc_dfi_t_ctrl_delay              (regmux_ddrc_dfi_t_ctrl_delay),
           .reg_ddrc_dfi_t_wrdata_delay            (regmux_ddrc_dfi_t_wrdata_delay),
           .reg_ddrc_dfi_t_dram_clk_disable        (regmux_ddrc_dfi_t_dram_clk_disable),
           .reg_ddrc_dfi_t_dram_clk_enable         (regmux_ddrc_dfi_t_dram_clk_enable),
           .reg_ddrc_t_cksre                       (regmux_ddrc_t_cksre_div),
           .reg_ddrc_t_cksrx                       (regmux_ddrc_t_cksrx_div),
           .reg_ddrc_t_ckcsx                       (regmux_ddrc_t_ckcsx_div),
           .reg_ddrc_t_ckesr                       (regmux_ddrc_t_ckesr_div),

           .reg_ddrc_oc_parity_en                     (oc_parity_en_core_clock),
           .reg_ddrc_oc_parity_type                   (oc_parity_type_core_clock),

           .reg_ddrc_par_poison_en                    (par_poison_en_core_clock),
           .reg_ddrc_par_poison_loc_rd_iecc_type      (par_poison_loc_rd_iecc_type),

           .par_rdata_in_err_ecc_pulse                (par_rdata_in_err_ecc_pulse),
           .par_wdata_out_err_pulse                   (par_wdata_out_err_pulse),
           .par_wdata_out_err_ie_pulse                (par_wdata_out_err_ie_pulse),
           .reg_ddrc_par_rdata_err_intr_clr           (par_rdata_err_intr_clr_core_clock),

           .ocecc_en                                  (ocecc_en_cclk),
           .ocecc_poison_egen_xpi_rd_0                (ocecc_poison_egen_xpi_rd_0_cclk),
           .ocecc_poison_egen_mr_rd_1                 (ocecc_poison_egen_mr_rd_1_cclk),
           .ocecc_poison_egen_mr_rd_1_byte_num        (ocecc_poison_egen_mr_rd_1_byte_num_cclk),
           .ocecc_poison_single                       (ocecc_poison_single_cclk),
           .ocecc_poison_pgen_rd                      (ocecc_poison_pgen_rd_cclk),
           .ocecc_poison_pgen_mr_ecc                  (ocecc_poison_pgen_mr_ecc_cclk),
           .ocecc_uncorr_err_intr_clr                 (ocecc_uncorrected_err_intr_clr_cclk),

           .ocecc_mr_rd_corr_err                      (ocecc_ddrc_mr_rd_corr_err),
           .ocecc_mr_rd_uncorr_err                    (ocecc_ddrc_mr_rd_uncorr_err),
           .ocecc_mr_rd_byte_num                      (ocecc_mr_rd_byte_num),

           .reg_ddrc_sw_done                          (reg_ddrc_sw_done),
           .reg_ddrc_occap_en                         (reg_ddrc_occap_en),
           .ddrc_occap_wufifo_parity_err              (ddrc_occap_wufifo_parity_err),
           .ddrc_occap_wuctrl_parity_err              (ddrc_occap_wuctrl_parity_err),
           .ddrc_occap_rtfifo_parity_err              (ddrc_occap_rtfifo_parity_err),
           .ddrc_occap_rtctrl_parity_err              (ddrc_occap_rtctrl_parity_err),
           .ddrc_occap_dfidata_parity_err             (ddrc_occap_dfidata_parity_err),
           .ddrc_occap_eccaccarray_parity_err         (ddrc_occap_eccaccarray_parity_err),

           .reg_ddrc_occap_ddrc_ctrl_poison_seq       (reg_ddrc_occap_ddrc_ctrl_poison_seq),
           .reg_ddrc_occap_ddrc_ctrl_poison_parallel  (reg_ddrc_occap_ddrc_ctrl_poison_parallel),
           .reg_ddrc_occap_ddrc_ctrl_poison_err_inj   (reg_ddrc_occap_ddrc_ctrl_poison_err_inj),
           .occap_ddrc_ctrl_err                       (occap_ddrc_ctrl_err),
           .occap_ddrc_ctrl_poison_complete           (occap_ddrc_ctrl_poison_complete),
           .occap_ddrc_ctrl_poison_seq_err            (occap_ddrc_ctrl_poison_seq_err),
           .occap_ddrc_ctrl_poison_parallel_err       (occap_ddrc_ctrl_poison_parallel_err),

           .reg_ddrc_occap_ddrc_data_poison_seq       (reg_ddrc_occap_ddrc_data_poison_seq),
           .reg_ddrc_occap_ddrc_data_poison_parallel  (reg_ddrc_occap_ddrc_data_poison_parallel),
           .reg_ddrc_occap_ddrc_data_poison_err_inj   (reg_ddrc_occap_ddrc_data_poison_err_inj),
           .occap_ddrc_data_err                       (occap_ddrc_data_err),
           .occap_ddrc_data_poison_complete           (occap_ddrc_data_poison_complete),
           .occap_ddrc_data_poison_seq_err            (occap_ddrc_data_poison_seq_err),
           .occap_ddrc_data_poison_parallel_err       (occap_ddrc_data_poison_parallel_err),

           .reg_ddrc_dfi_lp_data_req_en            (reg_ddrc_dfi_lp_data_req_en),
           .reg_ddrc_dfi_lp_en_pd                  (reg_ddrc_dfi_lp_en_pd),
           .reg_ddrc_dfi_lp_wakeup_pd              (reg_ddrc_dfi_lp_wakeup_pd_freq0),
           .reg_ddrc_dfi_lp_en_sr                  (reg_ddrc_dfi_lp_en_sr),
           .reg_ddrc_dfi_lp_wakeup_sr              (reg_ddrc_dfi_lp_wakeup_sr_freq0),
           .reg_ddrc_dfi_lp_en_data                (reg_ddrc_dfi_lp_en_data),
           .reg_ddrc_dfi_lp_wakeup_data            (reg_ddrc_dfi_lp_wakeup_data_freq0),
           .reg_ddrc_dfi_lp_en_dsm                 (reg_ddrc_dfi_lp_en_dsm),
           .reg_ddrc_dfi_lp_wakeup_dsm             (reg_ddrc_dfi_lp_wakeup_dsm_freq0),
           .reg_ddrc_skip_dram_init                (reg_ddrc_skip_dram_init),
           .reg_ddrc_dfi_tlp_resp                  (reg_ddrc_dfi_tlp_resp_freq0)




         ,.reg_ddrc_dis_dqsosc_srx                 (reg_ddrc_dis_dqsosc_srx)
         ,.reg_ddrc_dqsosc_enable                  (regmux_ddrc_dqsosc_enable)
         ,.reg_ddrc_t_osco                         (regmux_ddrc_t_osco_div)
         ,.reg_ddrc_dqsosc_runtime                 (reg_ddrc_dqsosc_runtime)
         ,.reg_ddrc_wck2dqo_runtime                (reg_ddrc_wck2dqo_runtime)
         ,.reg_ddrc_dqsosc_interval                (regmux_ddrc_dqsosc_interval)
         ,.reg_ddrc_dqsosc_interval_unit           (regmux_ddrc_dqsosc_interval_unit)
         ,.dqsosc_state                            (ddrc_reg_dqsosc_state)
         ,.dqsosc_per_rank_stat                    (ddrc_reg_dqsosc_per_rank_stat)
         ,.dwc_ddrphy_snoop_en                     (dwc_ddrphy_snoop_en_dch0)//dfi_rddata_en_dch0
         ,.reg_ddrc_dfi_t_ctrlmsg_resp             (reg_ddrc_dfi_t_ctrlmsg_resp_freq0)
         ,.reg_ddrc_dfi0_ctrlmsg_req               (reg_ddrc_dfi0_ctrlmsg_req)
         ,.reg_ddrc_dfi0_ctrlmsg_tout_clr          (reg_ddrc_dfi0_ctrlmsg_tout_clr)
         ,.reg_ddrc_dfi0_ctrlmsg_data              (reg_ddrc_dfi0_ctrlmsg_data)
         ,.reg_ddrc_dfi0_ctrlmsg_cmd               (reg_ddrc_dfi0_ctrlmsg_cmd)
         ,.ddrc_reg_dfi0_ctrlmsg_req_busy          (ddrc_reg_dfi0_ctrlmsg_req_busy)
         ,.ddrc_reg_dfi0_ctrlmsg_resp_tout         (ddrc_reg_dfi0_ctrlmsg_resp_tout)

           );





   parameter XPI_SQD = `UMCTL2_XPI_SQD;
   parameter XPI_OUTS_WRW = `UMCTL2_XPI_OUTS_WRW;
   parameter XPI_OUTS_RDW = `UMCTL2_XPI_OUTS_RDW;
   parameter XPI_RMW_WDQD = `UMCTL2_XPI_RMW_WDQD;
   parameter XPI_RMW_WARD = `UMCTL2_XPI_RMW_WARD;
   parameter XPI_WARD = `UMCTL2_XPI_WARD;
   parameter XPI_RARD = `UMCTL2_XPI_RARD;
   parameter XPI_WDATA_PTR_QD = `UMCTL2_XPI_WDATA_PTR_QD;
   parameter XPI_USE_WAR = `UMCTL2_XPI_USE_WAR;
   parameter XPI_USE_RAR = `UMCTL2_XPI_USE_RAR;
   parameter XPI_USE_INPUT_RAR = `UMCTL2_XPI_USE_INPUT_RAR;
   parameter XPI_USE_RDR = `UMCTL2_XPI_USE_RDR;
   parameter XPI_USE_RPR = `UMCTL2_XPI_USE_RPR;
   parameter MEMC_FREQ_RATIO = `MEMC_FREQ_RATIO;
   parameter MEMC_BURST_LENGTH = `MEMC_BURST_LENGTH;
   parameter AXI_LOWPWR_NOPX_CNT = `UMCTL2_AXI_LOWPWR_NOPX_CNT;
   parameter UMCTL2_A_ID_MAPW    = `UMCTL2_A_ID_MAPW;
   parameter UMCTL2_MAX_AXI_TAGBITS    = `UMCTL2_MAX_AXI_TAGBITS;
   parameter DDRCTL_LUT_ADDRMAP_EN = `DDRCTL_LUT_ADDRMAP_EN;
   parameter UMCTL2_HET_RANK_EN = `UMCTL2_HET_RANK_EN;

   parameter UMCTL2_XPI_RD_INFOW_0  = `UMCTL2_XPI_RD_INFOW_0; // port 0 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_0  = `UMCTL2_XPI_RD_INFOW_NSA_0;
   parameter UMCTL2_XPI_RP_INFOW_0 = `UMCTL2_XPI_RP_INFOW_0;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_0  = `UMCTL2_XPI_WR_INFOW_0; // port 0 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_0 = `UMCTL2_ASYNC_FIFO_N_SYNC_0;
   parameter ASYNC_FIFO_EARLY_POP_STAT_0 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_0 = 0;
   parameter UMCTL2_AXI_TAGBITS_0 = `UMCTL2_AXI_TAGBITS_0;
   parameter UMCTL2_NUM_VIR_CH_0 = `UMCTL2_NUM_VIR_CH_0;
   parameter XPI_VPR_EN_0 = `UMCTL2_XPI_VPR_EN_0;
   parameter XPI_VPW_EN_0 = `UMCTL2_XPI_VPW_EN_0;
   parameter XPI_USE2RAQ_0 = `UMCTL2_XPI_USE2RAQ_0;

   parameter XPI_WDQD_0 = `UMCTL2_AXI_WDQD_0;
   parameter XPI_RDQD_0 = `UMCTL2_AXI_RDQD_0;
   parameter XPI_WAQD_0 = `UMCTL2_AXI_WAQD_0;
   parameter XPI_RAQD_0 = `UMCTL2_AXI_RAQD_0;
   parameter XPI_WRQD_0 = `UMCTL2_AXI_WRQD_0;

   parameter UMCTL2_XPI_RD_INFOW_1  = `UMCTL2_XPI_RD_INFOW_1; // port 1 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_1  = `UMCTL2_XPI_RD_INFOW_NSA_1;
   parameter UMCTL2_XPI_RP_INFOW_1 = `UMCTL2_XPI_RP_INFOW_1;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_1  = `UMCTL2_XPI_WR_INFOW_1; // port 1 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_1 = `UMCTL2_ASYNC_FIFO_N_SYNC_1;
   parameter ASYNC_FIFO_EARLY_POP_STAT_1 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_1 = 0;
   parameter UMCTL2_AXI_TAGBITS_1 = `UMCTL2_AXI_TAGBITS_1;
   parameter UMCTL2_NUM_VIR_CH_1 = `UMCTL2_NUM_VIR_CH_1;
   parameter XPI_VPR_EN_1 = `UMCTL2_XPI_VPR_EN_1;
   parameter XPI_VPW_EN_1 = `UMCTL2_XPI_VPW_EN_1;
   parameter XPI_USE2RAQ_1 = `UMCTL2_XPI_USE2RAQ_1;

   parameter XPI_WDQD_1 = `UMCTL2_AXI_WDQD_1;
   parameter XPI_RDQD_1 = `UMCTL2_AXI_RDQD_1;
   parameter XPI_WAQD_1 = `UMCTL2_AXI_WAQD_1;
   parameter XPI_RAQD_1 = `UMCTL2_AXI_RAQD_1;
   parameter XPI_WRQD_1 = `UMCTL2_AXI_WRQD_1;

   parameter UMCTL2_XPI_RD_INFOW_2  = `UMCTL2_XPI_RD_INFOW_2; // port 2 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_2  = `UMCTL2_XPI_RD_INFOW_NSA_2;
   parameter UMCTL2_XPI_RP_INFOW_2 = `UMCTL2_XPI_RP_INFOW_2;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_2  = `UMCTL2_XPI_WR_INFOW_2; // port 2 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_2 = `UMCTL2_ASYNC_FIFO_N_SYNC_2;
   parameter ASYNC_FIFO_EARLY_POP_STAT_2 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_2 = 0;
   parameter UMCTL2_AXI_TAGBITS_2 = `UMCTL2_AXI_TAGBITS_2;
   parameter UMCTL2_NUM_VIR_CH_2 = `UMCTL2_NUM_VIR_CH_2;
   parameter XPI_VPR_EN_2 = `UMCTL2_XPI_VPR_EN_2;
   parameter XPI_VPW_EN_2 = `UMCTL2_XPI_VPW_EN_2;
   parameter XPI_USE2RAQ_2 = `UMCTL2_XPI_USE2RAQ_2;

   parameter XPI_WDQD_2 = `UMCTL2_AXI_WDQD_2;
   parameter XPI_RDQD_2 = `UMCTL2_AXI_RDQD_2;
   parameter XPI_WAQD_2 = `UMCTL2_AXI_WAQD_2;
   parameter XPI_RAQD_2 = `UMCTL2_AXI_RAQD_2;
   parameter XPI_WRQD_2 = `UMCTL2_AXI_WRQD_2;

   parameter UMCTL2_XPI_RD_INFOW_3  = `UMCTL2_XPI_RD_INFOW_3; // port 3 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_3  = `UMCTL2_XPI_RD_INFOW_NSA_3;
   parameter UMCTL2_XPI_RP_INFOW_3 = `UMCTL2_XPI_RP_INFOW_3;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_3  = `UMCTL2_XPI_WR_INFOW_3; // port 3 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_3 = `UMCTL2_ASYNC_FIFO_N_SYNC_3;
   parameter ASYNC_FIFO_EARLY_POP_STAT_3 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_3 = 0;
   parameter UMCTL2_AXI_TAGBITS_3 = `UMCTL2_AXI_TAGBITS_3;
   parameter UMCTL2_NUM_VIR_CH_3 = `UMCTL2_NUM_VIR_CH_3;
   parameter XPI_VPR_EN_3 = `UMCTL2_XPI_VPR_EN_3;
   parameter XPI_VPW_EN_3 = `UMCTL2_XPI_VPW_EN_3;
   parameter XPI_USE2RAQ_3 = `UMCTL2_XPI_USE2RAQ_3;

   parameter XPI_WDQD_3 = `UMCTL2_AXI_WDQD_3;
   parameter XPI_RDQD_3 = `UMCTL2_AXI_RDQD_3;
   parameter XPI_WAQD_3 = `UMCTL2_AXI_WAQD_3;
   parameter XPI_RAQD_3 = `UMCTL2_AXI_RAQD_3;
   parameter XPI_WRQD_3 = `UMCTL2_AXI_WRQD_3;

   parameter UMCTL2_XPI_RD_INFOW_4  = `UMCTL2_XPI_RD_INFOW_4; // port 4 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_4  = `UMCTL2_XPI_RD_INFOW_NSA_4;
   parameter UMCTL2_XPI_RP_INFOW_4 = `UMCTL2_XPI_RP_INFOW_4;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_4  = `UMCTL2_XPI_WR_INFOW_4; // port 4 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_4 = `UMCTL2_ASYNC_FIFO_N_SYNC_4;
   parameter ASYNC_FIFO_EARLY_POP_STAT_4 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_4 = 0;
   parameter UMCTL2_AXI_TAGBITS_4 = `UMCTL2_AXI_TAGBITS_4;
   parameter UMCTL2_NUM_VIR_CH_4 = `UMCTL2_NUM_VIR_CH_4;
   parameter XPI_VPR_EN_4 = `UMCTL2_XPI_VPR_EN_4;
   parameter XPI_VPW_EN_4 = `UMCTL2_XPI_VPW_EN_4;
   parameter XPI_USE2RAQ_4 = `UMCTL2_XPI_USE2RAQ_4;

   parameter XPI_WDQD_4 = `UMCTL2_AXI_WDQD_4;
   parameter XPI_RDQD_4 = `UMCTL2_AXI_RDQD_4;
   parameter XPI_WAQD_4 = `UMCTL2_AXI_WAQD_4;
   parameter XPI_RAQD_4 = `UMCTL2_AXI_RAQD_4;
   parameter XPI_WRQD_4 = `UMCTL2_AXI_WRQD_4;

   parameter UMCTL2_XPI_RD_INFOW_5  = `UMCTL2_XPI_RD_INFOW_5; // port 5 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_5  = `UMCTL2_XPI_RD_INFOW_NSA_5;
   parameter UMCTL2_XPI_RP_INFOW_5 = `UMCTL2_XPI_RP_INFOW_5;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_5  = `UMCTL2_XPI_WR_INFOW_5; // port 5 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_5 = `UMCTL2_ASYNC_FIFO_N_SYNC_5;
   parameter ASYNC_FIFO_EARLY_POP_STAT_5 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_5 = 0;
   parameter UMCTL2_AXI_TAGBITS_5 = `UMCTL2_AXI_TAGBITS_5;
   parameter UMCTL2_NUM_VIR_CH_5 = `UMCTL2_NUM_VIR_CH_5;
   parameter XPI_VPR_EN_5 = `UMCTL2_XPI_VPR_EN_5;
   parameter XPI_VPW_EN_5 = `UMCTL2_XPI_VPW_EN_5;
   parameter XPI_USE2RAQ_5 = `UMCTL2_XPI_USE2RAQ_5;

   parameter XPI_WDQD_5 = `UMCTL2_AXI_WDQD_5;
   parameter XPI_RDQD_5 = `UMCTL2_AXI_RDQD_5;
   parameter XPI_WAQD_5 = `UMCTL2_AXI_WAQD_5;
   parameter XPI_RAQD_5 = `UMCTL2_AXI_RAQD_5;
   parameter XPI_WRQD_5 = `UMCTL2_AXI_WRQD_5;

   parameter UMCTL2_XPI_RD_INFOW_6  = `UMCTL2_XPI_RD_INFOW_6; // port 6 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_6  = `UMCTL2_XPI_RD_INFOW_NSA_6;
   parameter UMCTL2_XPI_RP_INFOW_6 = `UMCTL2_XPI_RP_INFOW_6;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_6  = `UMCTL2_XPI_WR_INFOW_6; // port 6 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_6 = `UMCTL2_ASYNC_FIFO_N_SYNC_6;
   parameter ASYNC_FIFO_EARLY_POP_STAT_6 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_6 = 0;
   parameter UMCTL2_AXI_TAGBITS_6 = `UMCTL2_AXI_TAGBITS_6;
   parameter UMCTL2_NUM_VIR_CH_6 = `UMCTL2_NUM_VIR_CH_6;
   parameter XPI_VPR_EN_6 = `UMCTL2_XPI_VPR_EN_6;
   parameter XPI_VPW_EN_6 = `UMCTL2_XPI_VPW_EN_6;
   parameter XPI_USE2RAQ_6 = `UMCTL2_XPI_USE2RAQ_6;

   parameter XPI_WDQD_6 = `UMCTL2_AXI_WDQD_6;
   parameter XPI_RDQD_6 = `UMCTL2_AXI_RDQD_6;
   parameter XPI_WAQD_6 = `UMCTL2_AXI_WAQD_6;
   parameter XPI_RAQD_6 = `UMCTL2_AXI_RAQD_6;
   parameter XPI_WRQD_6 = `UMCTL2_AXI_WRQD_6;

   parameter UMCTL2_XPI_RD_INFOW_7  = `UMCTL2_XPI_RD_INFOW_7; // port 7 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_7  = `UMCTL2_XPI_RD_INFOW_NSA_7;
   parameter UMCTL2_XPI_RP_INFOW_7 = `UMCTL2_XPI_RP_INFOW_7;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_7  = `UMCTL2_XPI_WR_INFOW_7; // port 7 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_7 = `UMCTL2_ASYNC_FIFO_N_SYNC_7;
   parameter ASYNC_FIFO_EARLY_POP_STAT_7 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_7 = 0;
   parameter UMCTL2_AXI_TAGBITS_7 = `UMCTL2_AXI_TAGBITS_7;
   parameter UMCTL2_NUM_VIR_CH_7 = `UMCTL2_NUM_VIR_CH_7;
   parameter XPI_VPR_EN_7 = `UMCTL2_XPI_VPR_EN_7;
   parameter XPI_VPW_EN_7 = `UMCTL2_XPI_VPW_EN_7;
   parameter XPI_USE2RAQ_7 = `UMCTL2_XPI_USE2RAQ_7;

   parameter XPI_WDQD_7 = `UMCTL2_AXI_WDQD_7;
   parameter XPI_RDQD_7 = `UMCTL2_AXI_RDQD_7;
   parameter XPI_WAQD_7 = `UMCTL2_AXI_WAQD_7;
   parameter XPI_RAQD_7 = `UMCTL2_AXI_RAQD_7;
   parameter XPI_WRQD_7 = `UMCTL2_AXI_WRQD_7;

   parameter UMCTL2_XPI_RD_INFOW_8  = `UMCTL2_XPI_RD_INFOW_8; // port 8 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_8  = `UMCTL2_XPI_RD_INFOW_NSA_8;
   parameter UMCTL2_XPI_RP_INFOW_8 = `UMCTL2_XPI_RP_INFOW_8;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_8  = `UMCTL2_XPI_WR_INFOW_8; // port 8 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_8 = `UMCTL2_ASYNC_FIFO_N_SYNC_8;
   parameter ASYNC_FIFO_EARLY_POP_STAT_8 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_8 = 0;
   parameter UMCTL2_AXI_TAGBITS_8 = `UMCTL2_AXI_TAGBITS_8;
   parameter UMCTL2_NUM_VIR_CH_8 = `UMCTL2_NUM_VIR_CH_8;
   parameter XPI_VPR_EN_8 = `UMCTL2_XPI_VPR_EN_8;
   parameter XPI_VPW_EN_8 = `UMCTL2_XPI_VPW_EN_8;
   parameter XPI_USE2RAQ_8 = `UMCTL2_XPI_USE2RAQ_8;

   parameter XPI_WDQD_8 = `UMCTL2_AXI_WDQD_8;
   parameter XPI_RDQD_8 = `UMCTL2_AXI_RDQD_8;
   parameter XPI_WAQD_8 = `UMCTL2_AXI_WAQD_8;
   parameter XPI_RAQD_8 = `UMCTL2_AXI_RAQD_8;
   parameter XPI_WRQD_8 = `UMCTL2_AXI_WRQD_8;

   parameter UMCTL2_XPI_RD_INFOW_9  = `UMCTL2_XPI_RD_INFOW_9; // port 9 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_9  = `UMCTL2_XPI_RD_INFOW_NSA_9;
   parameter UMCTL2_XPI_RP_INFOW_9 = `UMCTL2_XPI_RP_INFOW_9;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_9  = `UMCTL2_XPI_WR_INFOW_9; // port 9 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_9 = `UMCTL2_ASYNC_FIFO_N_SYNC_9;
   parameter ASYNC_FIFO_EARLY_POP_STAT_9 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_9 = 0;
   parameter UMCTL2_AXI_TAGBITS_9 = `UMCTL2_AXI_TAGBITS_9;
   parameter UMCTL2_NUM_VIR_CH_9 = `UMCTL2_NUM_VIR_CH_9;
   parameter XPI_VPR_EN_9 = `UMCTL2_XPI_VPR_EN_9;
   parameter XPI_VPW_EN_9 = `UMCTL2_XPI_VPW_EN_9;
   parameter XPI_USE2RAQ_9 = `UMCTL2_XPI_USE2RAQ_9;

   parameter XPI_WDQD_9 = `UMCTL2_AXI_WDQD_9;
   parameter XPI_RDQD_9 = `UMCTL2_AXI_RDQD_9;
   parameter XPI_WAQD_9 = `UMCTL2_AXI_WAQD_9;
   parameter XPI_RAQD_9 = `UMCTL2_AXI_RAQD_9;
   parameter XPI_WRQD_9 = `UMCTL2_AXI_WRQD_9;

   parameter UMCTL2_XPI_RD_INFOW_10  = `UMCTL2_XPI_RD_INFOW_10; // port 10 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_10  = `UMCTL2_XPI_RD_INFOW_NSA_10;
   parameter UMCTL2_XPI_RP_INFOW_10 = `UMCTL2_XPI_RP_INFOW_10;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_10  = `UMCTL2_XPI_WR_INFOW_10; // port 10 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_10 = `UMCTL2_ASYNC_FIFO_N_SYNC_10;
   parameter ASYNC_FIFO_EARLY_POP_STAT_10 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_10 = 0;
   parameter UMCTL2_AXI_TAGBITS_10 = `UMCTL2_AXI_TAGBITS_10;
   parameter UMCTL2_NUM_VIR_CH_10 = `UMCTL2_NUM_VIR_CH_10;
   parameter XPI_VPR_EN_10 = `UMCTL2_XPI_VPR_EN_10;
   parameter XPI_VPW_EN_10 = `UMCTL2_XPI_VPW_EN_10;
   parameter XPI_USE2RAQ_10 = `UMCTL2_XPI_USE2RAQ_10;

   parameter XPI_WDQD_10 = `UMCTL2_AXI_WDQD_10;
   parameter XPI_RDQD_10 = `UMCTL2_AXI_RDQD_10;
   parameter XPI_WAQD_10 = `UMCTL2_AXI_WAQD_10;
   parameter XPI_RAQD_10 = `UMCTL2_AXI_RAQD_10;
   parameter XPI_WRQD_10 = `UMCTL2_AXI_WRQD_10;

   parameter UMCTL2_XPI_RD_INFOW_11  = `UMCTL2_XPI_RD_INFOW_11; // port 11 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_11  = `UMCTL2_XPI_RD_INFOW_NSA_11;
   parameter UMCTL2_XPI_RP_INFOW_11 = `UMCTL2_XPI_RP_INFOW_11;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_11  = `UMCTL2_XPI_WR_INFOW_11; // port 11 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_11 = `UMCTL2_ASYNC_FIFO_N_SYNC_11;
   parameter ASYNC_FIFO_EARLY_POP_STAT_11 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_11 = 0;
   parameter UMCTL2_AXI_TAGBITS_11 = `UMCTL2_AXI_TAGBITS_11;
   parameter UMCTL2_NUM_VIR_CH_11 = `UMCTL2_NUM_VIR_CH_11;
   parameter XPI_VPR_EN_11 = `UMCTL2_XPI_VPR_EN_11;
   parameter XPI_VPW_EN_11 = `UMCTL2_XPI_VPW_EN_11;
   parameter XPI_USE2RAQ_11 = `UMCTL2_XPI_USE2RAQ_11;

   parameter XPI_WDQD_11 = `UMCTL2_AXI_WDQD_11;
   parameter XPI_RDQD_11 = `UMCTL2_AXI_RDQD_11;
   parameter XPI_WAQD_11 = `UMCTL2_AXI_WAQD_11;
   parameter XPI_RAQD_11 = `UMCTL2_AXI_RAQD_11;
   parameter XPI_WRQD_11 = `UMCTL2_AXI_WRQD_11;

   parameter UMCTL2_XPI_RD_INFOW_12  = `UMCTL2_XPI_RD_INFOW_12; // port 12 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_12  = `UMCTL2_XPI_RD_INFOW_NSA_12;
   parameter UMCTL2_XPI_RP_INFOW_12 = `UMCTL2_XPI_RP_INFOW_12;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_12  = `UMCTL2_XPI_WR_INFOW_12; // port 12 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_12 = `UMCTL2_ASYNC_FIFO_N_SYNC_12;
   parameter ASYNC_FIFO_EARLY_POP_STAT_12 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_12 = 0;
   parameter UMCTL2_AXI_TAGBITS_12 = `UMCTL2_AXI_TAGBITS_12;
   parameter UMCTL2_NUM_VIR_CH_12 = `UMCTL2_NUM_VIR_CH_12;
   parameter XPI_VPR_EN_12 = `UMCTL2_XPI_VPR_EN_12;
   parameter XPI_VPW_EN_12 = `UMCTL2_XPI_VPW_EN_12;
   parameter XPI_USE2RAQ_12 = `UMCTL2_XPI_USE2RAQ_12;

   parameter XPI_WDQD_12 = `UMCTL2_AXI_WDQD_12;
   parameter XPI_RDQD_12 = `UMCTL2_AXI_RDQD_12;
   parameter XPI_WAQD_12 = `UMCTL2_AXI_WAQD_12;
   parameter XPI_RAQD_12 = `UMCTL2_AXI_RAQD_12;
   parameter XPI_WRQD_12 = `UMCTL2_AXI_WRQD_12;

   parameter UMCTL2_XPI_RD_INFOW_13  = `UMCTL2_XPI_RD_INFOW_13; // port 13 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_13  = `UMCTL2_XPI_RD_INFOW_NSA_13;
   parameter UMCTL2_XPI_RP_INFOW_13 = `UMCTL2_XPI_RP_INFOW_13;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_13  = `UMCTL2_XPI_WR_INFOW_13; // port 13 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_13 = `UMCTL2_ASYNC_FIFO_N_SYNC_13;
   parameter ASYNC_FIFO_EARLY_POP_STAT_13 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_13 = 0;
   parameter UMCTL2_AXI_TAGBITS_13 = `UMCTL2_AXI_TAGBITS_13;
   parameter UMCTL2_NUM_VIR_CH_13 = `UMCTL2_NUM_VIR_CH_13;
   parameter XPI_VPR_EN_13 = `UMCTL2_XPI_VPR_EN_13;
   parameter XPI_VPW_EN_13 = `UMCTL2_XPI_VPW_EN_13;
   parameter XPI_USE2RAQ_13 = `UMCTL2_XPI_USE2RAQ_13;

   parameter XPI_WDQD_13 = `UMCTL2_AXI_WDQD_13;
   parameter XPI_RDQD_13 = `UMCTL2_AXI_RDQD_13;
   parameter XPI_WAQD_13 = `UMCTL2_AXI_WAQD_13;
   parameter XPI_RAQD_13 = `UMCTL2_AXI_RAQD_13;
   parameter XPI_WRQD_13 = `UMCTL2_AXI_WRQD_13;

   parameter UMCTL2_XPI_RD_INFOW_14  = `UMCTL2_XPI_RD_INFOW_14; // port 14 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_14  = `UMCTL2_XPI_RD_INFOW_NSA_14;
   parameter UMCTL2_XPI_RP_INFOW_14 = `UMCTL2_XPI_RP_INFOW_14;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_14  = `UMCTL2_XPI_WR_INFOW_14; // port 14 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_14 = `UMCTL2_ASYNC_FIFO_N_SYNC_14;
   parameter ASYNC_FIFO_EARLY_POP_STAT_14 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_14 = 0;
   parameter UMCTL2_AXI_TAGBITS_14 = `UMCTL2_AXI_TAGBITS_14;
   parameter UMCTL2_NUM_VIR_CH_14 = `UMCTL2_NUM_VIR_CH_14;
   parameter XPI_VPR_EN_14 = `UMCTL2_XPI_VPR_EN_14;
   parameter XPI_VPW_EN_14 = `UMCTL2_XPI_VPW_EN_14;
   parameter XPI_USE2RAQ_14 = `UMCTL2_XPI_USE2RAQ_14;

   parameter XPI_WDQD_14 = `UMCTL2_AXI_WDQD_14;
   parameter XPI_RDQD_14 = `UMCTL2_AXI_RDQD_14;
   parameter XPI_WAQD_14 = `UMCTL2_AXI_WAQD_14;
   parameter XPI_RAQD_14 = `UMCTL2_AXI_RAQD_14;
   parameter XPI_WRQD_14 = `UMCTL2_AXI_WRQD_14;

   parameter UMCTL2_XPI_RD_INFOW_15  = `UMCTL2_XPI_RD_INFOW_15; // port 15 rinfo XPI width
   parameter UMCTL2_XPI_RD_INFOW_NSA_15  = `UMCTL2_XPI_RD_INFOW_NSA_15;
   parameter UMCTL2_XPI_RP_INFOW_15 = `UMCTL2_XPI_RP_INFOW_15;      // width of packet information in e_arinfo and e_rinfo
   parameter UMCTL2_XPI_WR_INFOW_15  = `UMCTL2_XPI_WR_INFOW_15; // port 15 winfo XPI width
   parameter ASYNC_FIFO_N_SYNC_15 = `UMCTL2_ASYNC_FIFO_N_SYNC_15;
   parameter ASYNC_FIFO_EARLY_POP_STAT_15 = 0;
   parameter ASYNC_FIFO_EARLY_PUSH_STAT_15 = 0;
   parameter UMCTL2_AXI_TAGBITS_15 = `UMCTL2_AXI_TAGBITS_15;
   parameter UMCTL2_NUM_VIR_CH_15 = `UMCTL2_NUM_VIR_CH_15;
   parameter XPI_VPR_EN_15 = `UMCTL2_XPI_VPR_EN_15;
   parameter XPI_VPW_EN_15 = `UMCTL2_XPI_VPW_EN_15;
   parameter XPI_USE2RAQ_15 = `UMCTL2_XPI_USE2RAQ_15;

   parameter XPI_WDQD_15 = `UMCTL2_AXI_WDQD_15;
   parameter XPI_RDQD_15 = `UMCTL2_AXI_RDQD_15;
   parameter XPI_WAQD_15 = `UMCTL2_AXI_WAQD_15;
   parameter XPI_RAQD_15 = `UMCTL2_AXI_RAQD_15;
   parameter XPI_WRQD_15 = `UMCTL2_AXI_WRQD_15;


  wire [UMCTL2_NUM_VIR_CH_0*UMCTL2_A_ID_MAPW-1:0] reg_arba0_id_mask_0;
  assign reg_arba0_id_mask_0[UMCTL2_NUM_VIR_CH_0*UMCTL2_A_ID_MAPW-1:0] = {(UMCTL2_NUM_VIR_CH_0*UMCTL2_A_ID_MAPW){1'b0}};

   wire [UMCTL2_NUM_VIR_CH_0*UMCTL2_A_ID_MAPW-1:0] reg_arba0_id_value_0;
   assign reg_arba0_id_value_0[UMCTL2_NUM_VIR_CH_0*UMCTL2_A_ID_MAPW-1:0] = {(UMCTL2_NUM_VIR_CH_0*UMCTL2_A_ID_MAPW){1'b0}};



















// define sar register wires if SAR is not enabled
   wire [AXI_SAR_BW-1:0] reg_arb_base_addr_0_port0;
   wire [AXI_SAR_SW-1:0] reg_arb_nblocks_0_port0;

   assign reg_arb_base_addr_0_port0 = {(AXI_SAR_BW){1'b0}};
   assign reg_arb_nblocks_0_port0   = {(AXI_SAR_SW){1'b0}};
   wire [AXI_SAR_BW-1:0] reg_arb_base_addr_1_port0;
   wire [AXI_SAR_SW-1:0] reg_arb_nblocks_1_port0;

   assign reg_arb_base_addr_1_port0 = {(AXI_SAR_BW){1'b0}};
   assign reg_arb_nblocks_1_port0   = {(AXI_SAR_SW){1'b0}};
   wire [AXI_SAR_BW-1:0] reg_arb_base_addr_2_port0;
   wire [AXI_SAR_SW-1:0] reg_arb_nblocks_2_port0;

   assign reg_arb_base_addr_2_port0 = {(AXI_SAR_BW){1'b0}};
   assign reg_arb_nblocks_2_port0   = {(AXI_SAR_SW){1'b0}};
   wire [AXI_SAR_BW-1:0] reg_arb_base_addr_3_port0;
   wire [AXI_SAR_SW-1:0] reg_arb_nblocks_3_port0;

   assign reg_arb_base_addr_3_port0 = {(AXI_SAR_BW){1'b0}};
   assign reg_arb_nblocks_3_port0   = {(AXI_SAR_SW){1'b0}};

   wire [5:0] reg_ddrc_addrmap_dch_bit0_map0 = {6{1'b0}};



   wire [UMCTL2_RDATARAM_DW-1:0]     rdataram_dout_0;
   wire [UMCTL2_RDATARAM_DW-1:0]     rdataram_din_0;
   wire [UMCTL2_DATARAM_PAR_DW-1:0]  rdataram_dout_par_0;
   wire [UMCTL2_DATARAM_PAR_DW-1:0]  rdataram_din_par_0;
   wire                              rdataram_wr_0;
   wire                              rdataram_re_0;
   wire [UMCTL2_RDATARAM_AW-1:0]     rdataram_raddr_0;
   wire [UMCTL2_RDATARAM_AW-1:0]     rdataram_waddr_0;

   wire [UMCTL2_RDATARAM_DW-1:0]     rdataram_dout_dch1_0;
   wire [UMCTL2_RDATARAM_DW-1:0]     rdataram_din_dch1_0;
   wire [UMCTL2_DATARAM_PAR_DW-1:0]  rdataram_dout_par_dch1_0;
   wire [UMCTL2_DATARAM_PAR_DW-1:0]  rdataram_din_par_dch1_0;
   wire                              rdataram_wr_dch1_0;
   wire                              rdataram_re_dch1_0;
   wire [UMCTL2_RDATARAM_AW-1:0]     rdataram_raddr_dch1_0;
   wire [UMCTL2_RDATARAM_AW-1:0]     rdataram_waddr_dch1_0;

   wire [AXI_IDW-1:0]      xpi_awid_0;
   wire [AXI_IDW-1:0]      xpi_arid_0;
   wire [AXI_IDW-1:0]      xpi_wid_0;

      wire [HIF_WQOS_TW-1:0]    reg_arb_wqos_map_timeout1_0;
      wire [HIF_WQOS_TW-1:0]    reg_arb_wqos_map_timeout2_0;
      wire [XPI_WQOS_MLW-1:0]   reg_arba0_wqos_map_level1_0;
      wire [XPI_WQOS_MLW-1:0]   reg_arba0_wqos_map_level2_0;
      wire [XPI_WQOS_RW-1:0]    reg_arba0_wqos_map_region0_0;
      wire [XPI_WQOS_RW-1:0]    reg_arba0_wqos_map_region1_0;
      wire [XPI_WQOS_RW-1:0]    reg_arba0_wqos_map_region2_0;

      assign reg_arb_wqos_map_timeout1_0     = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_0     = {(HIF_WQOS_TW){1'b0}};
      assign reg_arba0_wqos_map_level1_0     = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba0_wqos_map_level2_0     = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba0_wqos_map_region0_0    = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba0_wqos_map_region1_0    = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba0_wqos_map_region2_0    = {(XPI_WQOS_RW){1'b0}};


   // Dual Channel XPI signals routing

      wire [HIF_RQOS_TW-1:0] reg_arb_rqos_map_timeoutb_0;
      wire [HIF_RQOS_TW-1:0] reg_arb_rqos_map_timeoutr_0;
      assign reg_arb_rqos_map_timeoutb_0 = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_0 = {(HIF_RQOS_TW){1'b0}};

       wire [XPI_RQOS_MLW-1:0]   reg_arba0_rqos_map_level2_port0;
       wire [XPI_RQOS_RW-1:0]    reg_arba0_rqos_map_region2_port0;
       assign reg_arba0_rqos_map_level2_port0    = {(XPI_RQOS_MLW){1'b1}};
       assign reg_arba0_rqos_map_region2_port0   = {(XPI_RQOS_RW){1'b0}};


  assign xpi_awid_0 = awid_0;
  assign xpi_arid_0 = arid_0;
      assign xpi_wid_0  = {AXI_IDW{1'b0}};

   wire reg_arb_port_data_channel_0_port0  = 1'b0;

   wire [AXI_ADDRW-1:0]          aw_axi_addr_0, ar_axi_addr_0;

   wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] aw_awparity_0, ar_arparity_0;

   generate
   if (`UMCTL2_A_ADDRW < `UMCTL2_MIN_ADDRW) begin: PAD_addrw_zeros_0
      assign aw_axi_addr_0[`UMCTL2_MIN_ADDRW-1:`UMCTL2_A_ADDRW]   = {(`UMCTL2_MIN_ADDRW-`UMCTL2_A_ADDRW){1'b0}};
      assign aw_axi_addr_0[`UMCTL2_A_ADDRW-1:0]                   = awaddr_0;
      assign ar_axi_addr_0[`UMCTL2_MIN_ADDRW-1:`UMCTL2_A_ADDRW]   = {(`UMCTL2_MIN_ADDRW-`UMCTL2_A_ADDRW){1'b0}};
      assign ar_axi_addr_0[`UMCTL2_A_ADDRW-1:0]                   = araddr_0;
   end else begin: nPAD_addrw_zeros_0
      assign aw_axi_addr_0 = awaddr_0;
      assign ar_axi_addr_0 = araddr_0;
   end
   if (OCPAR_ADDR_PARITY_WIDTH<OCPAR_ADDR_PARITY_WIDTH_MIN) begin: PAD_parw_zeros_0
       assign aw_awparity_0 = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
       assign ar_arparity_0 = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
   end
   else begin: nPAD_parw_zeros_0
       assign aw_awparity_0 = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
       assign ar_arparity_0 = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
   end
   endgenerate


   wire csysreq_xpi_0;
   wire csysack_xpi_0;

    assign csysreq_xpi_0 = csysreq_0;
    assign csysack_0     = csysack_xpi_0;
    assign cactive_0     = cactive_xpi[0];

   wire [XPI_RAQD_LG2_0:0] raqr_wcount_0;
   wire [XPI_RAQD_LG2_0:0] raqb_wcount_0;
   wire                    raqr_pop_0;
   wire                    raqb_pop_0;
   wire                    raqr_push_0;
   wire                    raqb_push_0;
     wire arurgentb_0;
     wire arurgentr_0;
     assign raq_pop_0      = raqb_pop_0;
     assign raq_push_0     = raqb_push_0;
     assign arurgentb_0    = arurgent_0;
     assign arurgentr_0    = 1'b0;



   assign wuser_0       = {(AXI_USERW){1'b0}};
   assign awuser_0      = {(AXI_USERW){1'b0}};
   assign aruser_0      = {(AXI_USERW){1'b0}};




   wire [`UMCTL2_PORT_NBYTES_0-1:0] wparity_0, rparity_0;

   assign wparity_0  = {`UMCTL2_PORT_NBYTES_0{1'b0}};


   assign awpoison_intr_0 = wr_poison_intr[0];
   assign arpoison_intr_0 = rd_poison_intr[0];

   assign rdataram_dout_dch1_0     = {UMCTL2_RDATARAM_DW{1'b0}};
   assign rdataram_dout_par_dch1_0 = {UMCTL2_DATARAM_PAR_DW{1'b0}};

   assign rdataram_dout_0     = {UMCTL2_RDATARAM_DW{1'b0}};
   assign rdataram_dout_par_0 = {UMCTL2_DATARAM_PAR_DW{1'b0}};



//Only valid values are passed down to submodules
assign reg_ddrc_data_bus_width_int = (`DDRCTL_PBW_MODE_SUPPORT == 0)? reg_ddrc_data_bus_width :
                                     (`DDRCTL_PBW_MODE_SUPPORT == 1)? ((reg_ddrc_data_bus_width==2'b00)? 2'b00 : 2'b01) : 2'b00;


   // PA assignments
   assign reg_wr_port_priority[REG_PORT_PRIORITYW*(0+1)-1 -: REG_PORT_PRIORITYW] = reg_arb_wr_port_priority_port0;
   assign reg_rd_port_priority[REG_PORT_PRIORITYW*(0+1)-1 -: REG_PORT_PRIORITYW] = reg_arb_rd_port_priority_port0;
   assign reg_wr_port_aging_en[0] = reg_arb_wr_port_aging_en_port0;
   assign reg_rd_port_aging_en[0] = reg_arb_rd_port_aging_en_port0;
   assign reg_wr_port_urgent_en[0] = reg_arb_wr_port_urgent_en_port0;
   assign reg_rd_port_urgent_en[0] = reg_arb_rd_port_urgent_en_port0;
   //assign xa_wpagematch[0] = xpi_awpagematch[0];
   //assign xa_rpagematch[0] = xpi_arpagematch[0];


   // poison interrupts
   assign wr_poison_intr = wr_poison_intr_dch0 | wr_poison_intr_dch1;


   assign hifx_hif_cmd_addr[HIF_ADDR_WIDTH-1:0] = hif_hif_cmd_addr[HIF_ADDR_WIDTH-1:0];
   generate
      for(gv=HIF_ADDR_WIDTH; gv<`MEMC_HIF_ADDR_WIDTH_MAX; gv=gv+1)  begin: GEN_unused_addr
         assign hifx_hif_cmd_addr[gv] = 1'b0;
      end
   endgenerate

   wire perf_hpr_req_with_nocredit_dch0, perf_lpr_req_with_nocredit_dch0;
   wire perf_hpr_req_with_nocredit_dch1, perf_lpr_req_with_nocredit_dch1;
   wire [6:0] lpr_credit_cnt, hpr_credit_cnt, wr_credit_cnt, wrecc_credit_cnt;


   wire perf_hpr_req_with_nocredit, perf_lpr_req_with_nocredit;
   assign perf_hpr_req_with_nocredit   = perf_hpr_req_with_nocredit_dch0;
   assign perf_lpr_req_with_nocredit   = perf_lpr_req_with_nocredit_dch0;

  //-----------------------------------------------------------------------------------
  //  Start arb_top Instantiation
  //-----------------------------------------------------------------------------------

localparam SELFREF_TYPE_WIDTH_INT = SELFREF_TYPE_WIDTH;

wire [SELFREF_TYPE_WIDTH_INT-1:0]     ddrc_reg_selfref_type_w;
assign ddrc_reg_selfref_type_w = ddrc_reg_selfref_type[$bits(ddrc_reg_selfref_type_w)-1:0];


  //-----------------------------------------------------------------------------------
  //  Instantiation file for arb_top local parameters
  //-----------------------------------------------------------------------------------

  localparam ARB_NPOTRS_MAX           = `MAX_UMCTL2_A_NPORTS;
  
  localparam NAB                      = (MEMC_FREQ_RATIO == 4) ? 3 : MEMC_FREQ_RATIO;
  
  localparam  ARB_ID_NB                = 24;
  localparam [ARB_ID_NB-1:0] ARB_ID_0  = `UMCTL2_NUM_VIR_CH_0 * `UMCTL2_A_ID_MAPW;    
  localparam [ARB_ID_NB-1:0] ARB_ID_1  = `UMCTL2_NUM_VIR_CH_1 * `UMCTL2_A_ID_MAPW;   
  localparam [ARB_ID_NB-1:0] ARB_ID_2  = `UMCTL2_NUM_VIR_CH_2 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_3  = `UMCTL2_NUM_VIR_CH_3 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_4  = `UMCTL2_NUM_VIR_CH_4 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_5  = `UMCTL2_NUM_VIR_CH_5 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_6  = `UMCTL2_NUM_VIR_CH_6 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_7  = `UMCTL2_NUM_VIR_CH_7 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_8  = `UMCTL2_NUM_VIR_CH_8 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_9  = `UMCTL2_NUM_VIR_CH_9 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_10 = `UMCTL2_NUM_VIR_CH_10 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_11 = `UMCTL2_NUM_VIR_CH_11 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_12 = `UMCTL2_NUM_VIR_CH_12 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_13 = `UMCTL2_NUM_VIR_CH_13 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_14 = `UMCTL2_NUM_VIR_CH_14 * `UMCTL2_A_ID_MAPW;
  localparam [ARB_ID_NB-1:0] ARB_ID_15 = `UMCTL2_NUM_VIR_CH_15 * `UMCTL2_A_ID_MAPW; 

   localparam [ARB_ID_NB*ARB_NPOTRS_MAX-1:0] ARB_ID_PRA_TABLE = {
                              ARB_ID_15, ARB_ID_14, ARB_ID_13, ARB_ID_12, 
                              ARB_ID_11, ARB_ID_10, ARB_ID_9,  ARB_ID_8, 
                              ARB_ID_7,  ARB_ID_6,  ARB_ID_5,  ARB_ID_4, 
                              ARB_ID_3,  ARB_ID_2,  ARB_ID_1,  ARB_ID_0}; 
 
   localparam ARB_TOTAL_ID = (ARB_ID_15 + ARB_ID_14 + ARB_ID_13 + ARB_ID_12 +  
                              ARB_ID_11 + ARB_ID_10 + ARB_ID_9  + ARB_ID_8  +  
                              ARB_ID_7  + ARB_ID_6  + ARB_ID_5  + ARB_ID_4  +  
                              ARB_ID_3  + ARB_ID_2  + ARB_ID_1  + ARB_ID_0   );
 
 
  localparam [ARB_ID_NB*(ARB_NPOTRS_MAX + 1)-1:0] ARB_ID_BUS_TABLE = { 
            ARB_ID_15[ARB_ID_NB-1:0]+ 
            ARB_ID_14[ARB_ID_NB-1:0]+ ARB_ID_13[ARB_ID_NB-1:0]+ ARB_ID_12[ARB_ID_NB-1:0]+ ARB_ID_11[ARB_ID_NB-1:0]+ ARB_ID_10[ARB_ID_NB-1:0]+
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,

            ARB_ID_14[ARB_ID_NB-1:0]+ ARB_ID_13[ARB_ID_NB-1:0]+ ARB_ID_12[ARB_ID_NB-1:0]+ ARB_ID_11[ARB_ID_NB-1:0]+ ARB_ID_10[ARB_ID_NB-1:0]+
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,

            ARB_ID_13[ARB_ID_NB-1:0]+ ARB_ID_12[ARB_ID_NB-1:0]+ ARB_ID_11[ARB_ID_NB-1:0]+ ARB_ID_10[ARB_ID_NB-1:0]+
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,

            ARB_ID_12[ARB_ID_NB-1:0]+ ARB_ID_11[ARB_ID_NB-1:0]+ ARB_ID_10[ARB_ID_NB-1:0]+
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,

            ARB_ID_11[ARB_ID_NB-1:0]+ ARB_ID_10[ARB_ID_NB-1:0]+
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7 + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2 + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
  
            ARB_ID_10[ARB_ID_NB-1:0]+
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] , 
 
            ARB_ID_9[ARB_ID_NB-1:0] + ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] + 
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
  
            ARB_ID_8[ARB_ID_NB-1:0] + ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] +
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
  
            ARB_ID_7[ARB_ID_NB-1:0] + ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] +
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
   
            ARB_ID_6[ARB_ID_NB-1:0] + ARB_ID_5[ARB_ID_NB-1:0] +
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
  
            ARB_ID_5[ARB_ID_NB-1:0] +
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2 [ARB_ID_NB-1:0]+ ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0],
  
            ARB_ID_4[ARB_ID_NB-1:0] + ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
 
            ARB_ID_3[ARB_ID_NB-1:0] + ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
 
            ARB_ID_2[ARB_ID_NB-1:0] + ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
 
            ARB_ID_1[ARB_ID_NB-1:0] + ARB_ID_0[ARB_ID_NB-1:0] ,
 
            ARB_ID_0[ARB_ID_NB-1:0] ,
            {ARB_ID_NB{1'b0}}}; 
  

  localparam MAX_A_DW_INT_NB                     = `MAX_A_DW_INT_NB;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_0 = `UMCTL2_A_DW_INT_0;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_1 = `UMCTL2_A_DW_INT_1;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_2 = `UMCTL2_A_DW_INT_2;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_3 = `UMCTL2_A_DW_INT_3;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_4 = `UMCTL2_A_DW_INT_4;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_5 = `UMCTL2_A_DW_INT_5;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_6 = `UMCTL2_A_DW_INT_6;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_7 = `UMCTL2_A_DW_INT_7;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_8 = `UMCTL2_A_DW_INT_8;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_9 = `UMCTL2_A_DW_INT_9;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_10 = `UMCTL2_A_DW_INT_10;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_11 = `UMCTL2_A_DW_INT_11;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_12 = `UMCTL2_A_DW_INT_12;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_13 = `UMCTL2_A_DW_INT_13;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_14 = `UMCTL2_A_DW_INT_14;
  localparam [MAX_A_DW_INT_NB-1:0] A_DW_INT_TABLE_15 = `UMCTL2_A_DW_INT_15;
  localparam [MAX_A_DW_INT_NB*ARB_NPOTRS_MAX-1:0] A_DW_INT_TABLE = {
                A_DW_INT_TABLE_15,
                A_DW_INT_TABLE_14,
                A_DW_INT_TABLE_13,
                A_DW_INT_TABLE_12,
                A_DW_INT_TABLE_11,
                A_DW_INT_TABLE_10,
                A_DW_INT_TABLE_9,
                A_DW_INT_TABLE_8,
                A_DW_INT_TABLE_7,
                A_DW_INT_TABLE_6,
                A_DW_INT_TABLE_5,
                A_DW_INT_TABLE_4,
                A_DW_INT_TABLE_3,
                A_DW_INT_TABLE_2,
                A_DW_INT_TABLE_1,
                A_DW_INT_TABLE_0 };


  localparam MAX_AXI_WAQD_NB                        = `MAX_AXI_WAQD_NB;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL2_AHB_WAQD_0 : `UMCTL2_AXI_WAQD_0;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_1 = (`UMCTL2_A_TYPE_1==2) ? `UMCTL2_AHB_WAQD_1 : `UMCTL2_AXI_WAQD_1;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_2 = (`UMCTL2_A_TYPE_2==2) ? `UMCTL2_AHB_WAQD_2 : `UMCTL2_AXI_WAQD_2;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_3 = (`UMCTL2_A_TYPE_3==2) ? `UMCTL2_AHB_WAQD_3 : `UMCTL2_AXI_WAQD_3;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_4 = (`UMCTL2_A_TYPE_4==2) ? `UMCTL2_AHB_WAQD_4 : `UMCTL2_AXI_WAQD_4;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_5 = (`UMCTL2_A_TYPE_5==2) ? `UMCTL2_AHB_WAQD_5 : `UMCTL2_AXI_WAQD_5;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_6 = (`UMCTL2_A_TYPE_6==2) ? `UMCTL2_AHB_WAQD_6 : `UMCTL2_AXI_WAQD_6;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_7 = (`UMCTL2_A_TYPE_7==2) ? `UMCTL2_AHB_WAQD_7 : `UMCTL2_AXI_WAQD_7;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_8 = (`UMCTL2_A_TYPE_8==2) ? `UMCTL2_AHB_WAQD_8 : `UMCTL2_AXI_WAQD_8;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_9 = (`UMCTL2_A_TYPE_9==2) ? `UMCTL2_AHB_WAQD_9 : `UMCTL2_AXI_WAQD_9;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_10 = (`UMCTL2_A_TYPE_10==2) ? `UMCTL2_AHB_WAQD_10 : `UMCTL2_AXI_WAQD_10;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_11 = (`UMCTL2_A_TYPE_11==2) ? `UMCTL2_AHB_WAQD_11 : `UMCTL2_AXI_WAQD_11;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_12 = (`UMCTL2_A_TYPE_12==2) ? `UMCTL2_AHB_WAQD_12 : `UMCTL2_AXI_WAQD_12;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_13 = (`UMCTL2_A_TYPE_13==2) ? `UMCTL2_AHB_WAQD_13 : `UMCTL2_AXI_WAQD_13;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_14 = (`UMCTL2_A_TYPE_14==2) ? `UMCTL2_AHB_WAQD_14 : `UMCTL2_AXI_WAQD_14;
  localparam [MAX_AXI_WAQD_NB-1:0] AXI_WAQD_TABLE_15 = (`UMCTL2_A_TYPE_15==2) ? `UMCTL2_AHB_WAQD_15 : `UMCTL2_AXI_WAQD_15;
  localparam [MAX_AXI_WAQD_NB*ARB_NPOTRS_MAX-1:0] AXI_WAQD_TABLE = {
                AXI_WAQD_TABLE_15,
                AXI_WAQD_TABLE_14,
                AXI_WAQD_TABLE_13,
                AXI_WAQD_TABLE_12,
                AXI_WAQD_TABLE_11,
                AXI_WAQD_TABLE_10,
                AXI_WAQD_TABLE_9,
                AXI_WAQD_TABLE_8,
                AXI_WAQD_TABLE_7,
                AXI_WAQD_TABLE_6,
                AXI_WAQD_TABLE_5,
                AXI_WAQD_TABLE_4,
                AXI_WAQD_TABLE_3,
                AXI_WAQD_TABLE_2,
                AXI_WAQD_TABLE_1,
                AXI_WAQD_TABLE_0 };


  localparam MAX_AXI_WDQD_NB                     = `MAX_AXI_WDQD_NB;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL2_AHB_WDQD_0 : `UMCTL2_AXI_WDQD_0;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_1 = (`UMCTL2_A_TYPE_1==2) ? `UMCTL2_AHB_WDQD_1 : `UMCTL2_AXI_WDQD_1;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_2 = (`UMCTL2_A_TYPE_2==2) ? `UMCTL2_AHB_WDQD_2 : `UMCTL2_AXI_WDQD_2;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_3 = (`UMCTL2_A_TYPE_3==2) ? `UMCTL2_AHB_WDQD_3 : `UMCTL2_AXI_WDQD_3;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_4 = (`UMCTL2_A_TYPE_4==2) ? `UMCTL2_AHB_WDQD_4 : `UMCTL2_AXI_WDQD_4;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_5 = (`UMCTL2_A_TYPE_5==2) ? `UMCTL2_AHB_WDQD_5 : `UMCTL2_AXI_WDQD_5;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_6 = (`UMCTL2_A_TYPE_6==2) ? `UMCTL2_AHB_WDQD_6 : `UMCTL2_AXI_WDQD_6;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_7 = (`UMCTL2_A_TYPE_7==2) ? `UMCTL2_AHB_WDQD_7 : `UMCTL2_AXI_WDQD_7;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_8 = (`UMCTL2_A_TYPE_8==2) ? `UMCTL2_AHB_WDQD_8 : `UMCTL2_AXI_WDQD_8;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_9 = (`UMCTL2_A_TYPE_9==2) ? `UMCTL2_AHB_WDQD_9 : `UMCTL2_AXI_WDQD_9;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_10 = (`UMCTL2_A_TYPE_10==2) ? `UMCTL2_AHB_WDQD_10 : `UMCTL2_AXI_WDQD_10;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_11 = (`UMCTL2_A_TYPE_11==2) ? `UMCTL2_AHB_WDQD_11 : `UMCTL2_AXI_WDQD_11;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_12 = (`UMCTL2_A_TYPE_12==2) ? `UMCTL2_AHB_WDQD_12 : `UMCTL2_AXI_WDQD_12;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_13 = (`UMCTL2_A_TYPE_13==2) ? `UMCTL2_AHB_WDQD_13 : `UMCTL2_AXI_WDQD_13;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_14 = (`UMCTL2_A_TYPE_14==2) ? `UMCTL2_AHB_WDQD_14 : `UMCTL2_AXI_WDQD_14;
  localparam [MAX_AXI_WDQD_NB-1:0] AXI_WDQD_TABLE_15 = (`UMCTL2_A_TYPE_15==2) ? `UMCTL2_AHB_WDQD_15 : `UMCTL2_AXI_WDQD_15;
  localparam [MAX_AXI_WDQD_NB*ARB_NPOTRS_MAX-1:0] AXI_WDQD_TABLE = {
                AXI_WDQD_TABLE_15,
                AXI_WDQD_TABLE_14,
                AXI_WDQD_TABLE_13,
                AXI_WDQD_TABLE_12,
                AXI_WDQD_TABLE_11,
                AXI_WDQD_TABLE_10,
                AXI_WDQD_TABLE_9,
                AXI_WDQD_TABLE_8,
                AXI_WDQD_TABLE_7,
                AXI_WDQD_TABLE_6,
                AXI_WDQD_TABLE_5,
                AXI_WDQD_TABLE_4,
                AXI_WDQD_TABLE_3,
                AXI_WDQD_TABLE_2,
                AXI_WDQD_TABLE_1,
                AXI_WDQD_TABLE_0 };

  localparam MAX_AXI_RAQD_NB                     = `MAX_AXI_RAQD_NB;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL2_AHB_RAQD_0 : `UMCTL2_AXI_RAQD_0;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_1 = (`UMCTL2_A_TYPE_1==2) ? `UMCTL2_AHB_RAQD_1 : `UMCTL2_AXI_RAQD_1;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_2 = (`UMCTL2_A_TYPE_2==2) ? `UMCTL2_AHB_RAQD_2 : `UMCTL2_AXI_RAQD_2;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_3 = (`UMCTL2_A_TYPE_3==2) ? `UMCTL2_AHB_RAQD_3 : `UMCTL2_AXI_RAQD_3;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_4 = (`UMCTL2_A_TYPE_4==2) ? `UMCTL2_AHB_RAQD_4 : `UMCTL2_AXI_RAQD_4;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_5 = (`UMCTL2_A_TYPE_5==2) ? `UMCTL2_AHB_RAQD_5 : `UMCTL2_AXI_RAQD_5;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_6 = (`UMCTL2_A_TYPE_6==2) ? `UMCTL2_AHB_RAQD_6 : `UMCTL2_AXI_RAQD_6;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_7 = (`UMCTL2_A_TYPE_7==2) ? `UMCTL2_AHB_RAQD_7 : `UMCTL2_AXI_RAQD_7;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_8 = (`UMCTL2_A_TYPE_8==2) ? `UMCTL2_AHB_RAQD_8 : `UMCTL2_AXI_RAQD_8;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_9 = (`UMCTL2_A_TYPE_9==2) ? `UMCTL2_AHB_RAQD_9 : `UMCTL2_AXI_RAQD_9;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_10 = (`UMCTL2_A_TYPE_10==2) ? `UMCTL2_AHB_RAQD_10 : `UMCTL2_AXI_RAQD_10;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_11 = (`UMCTL2_A_TYPE_11==2) ? `UMCTL2_AHB_RAQD_11 : `UMCTL2_AXI_RAQD_11;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_12 = (`UMCTL2_A_TYPE_12==2) ? `UMCTL2_AHB_RAQD_12 : `UMCTL2_AXI_RAQD_12;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_13 = (`UMCTL2_A_TYPE_13==2) ? `UMCTL2_AHB_RAQD_13 : `UMCTL2_AXI_RAQD_13;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_14 = (`UMCTL2_A_TYPE_14==2) ? `UMCTL2_AHB_RAQD_14 : `UMCTL2_AXI_RAQD_14;
  localparam [MAX_AXI_RAQD_NB-1:0] AXI_RAQD_TABLE_15 = (`UMCTL2_A_TYPE_15==2) ? `UMCTL2_AHB_RAQD_15 : `UMCTL2_AXI_RAQD_15;
  localparam [MAX_AXI_RAQD_NB*ARB_NPOTRS_MAX-1:0] AXI_RAQD_TABLE = {
                AXI_RAQD_TABLE_15,
                AXI_RAQD_TABLE_14,
                AXI_RAQD_TABLE_13,
                AXI_RAQD_TABLE_12,
                AXI_RAQD_TABLE_11,
                AXI_RAQD_TABLE_10,
                AXI_RAQD_TABLE_9,
                AXI_RAQD_TABLE_8,
                AXI_RAQD_TABLE_7,
                AXI_RAQD_TABLE_6,
                AXI_RAQD_TABLE_5,
                AXI_RAQD_TABLE_4,
                AXI_RAQD_TABLE_3,
                AXI_RAQD_TABLE_2,
                AXI_RAQD_TABLE_1,
                AXI_RAQD_TABLE_0 };


  localparam MAX_AXI_RDQD_NB                        = `MAX_AXI_RDQD_NB;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL2_AHB_RDQD_0 : `UMCTL2_AXI_RDQD_0;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_1 = (`UMCTL2_A_TYPE_1==2) ? `UMCTL2_AHB_RDQD_1 : `UMCTL2_AXI_RDQD_1;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_2 = (`UMCTL2_A_TYPE_2==2) ? `UMCTL2_AHB_RDQD_2 : `UMCTL2_AXI_RDQD_2;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_3 = (`UMCTL2_A_TYPE_3==2) ? `UMCTL2_AHB_RDQD_3 : `UMCTL2_AXI_RDQD_3;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_4 = (`UMCTL2_A_TYPE_4==2) ? `UMCTL2_AHB_RDQD_4 : `UMCTL2_AXI_RDQD_4;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_5 = (`UMCTL2_A_TYPE_5==2) ? `UMCTL2_AHB_RDQD_5 : `UMCTL2_AXI_RDQD_5;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_6 = (`UMCTL2_A_TYPE_6==2) ? `UMCTL2_AHB_RDQD_6 : `UMCTL2_AXI_RDQD_6;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_7 = (`UMCTL2_A_TYPE_7==2) ? `UMCTL2_AHB_RDQD_7 : `UMCTL2_AXI_RDQD_7;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_8 = (`UMCTL2_A_TYPE_8==2) ? `UMCTL2_AHB_RDQD_8 : `UMCTL2_AXI_RDQD_8;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_9 = (`UMCTL2_A_TYPE_9==2) ? `UMCTL2_AHB_RDQD_9 : `UMCTL2_AXI_RDQD_9;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_10 = (`UMCTL2_A_TYPE_10==2) ? `UMCTL2_AHB_RDQD_10 : `UMCTL2_AXI_RDQD_10;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_11 = (`UMCTL2_A_TYPE_11==2) ? `UMCTL2_AHB_RDQD_11 : `UMCTL2_AXI_RDQD_11;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_12 = (`UMCTL2_A_TYPE_12==2) ? `UMCTL2_AHB_RDQD_12 : `UMCTL2_AXI_RDQD_12;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_13 = (`UMCTL2_A_TYPE_13==2) ? `UMCTL2_AHB_RDQD_13 : `UMCTL2_AXI_RDQD_13;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_14 = (`UMCTL2_A_TYPE_14==2) ? `UMCTL2_AHB_RDQD_14 : `UMCTL2_AXI_RDQD_14;
  localparam [MAX_AXI_RDQD_NB-1:0] AXI_RDQD_TABLE_15 = (`UMCTL2_A_TYPE_15==2) ? `UMCTL2_AHB_RDQD_15 : `UMCTL2_AXI_RDQD_15;
  localparam [MAX_AXI_RDQD_NB*ARB_NPOTRS_MAX-1:0] AXI_RDQD_TABLE = {
                AXI_RDQD_TABLE_15,
                AXI_RDQD_TABLE_14,
                AXI_RDQD_TABLE_13,
                AXI_RDQD_TABLE_12,
                AXI_RDQD_TABLE_11,
                AXI_RDQD_TABLE_10,
                AXI_RDQD_TABLE_9,
                AXI_RDQD_TABLE_8,
                AXI_RDQD_TABLE_7,
                AXI_RDQD_TABLE_6,
                AXI_RDQD_TABLE_5,
                AXI_RDQD_TABLE_4,
                AXI_RDQD_TABLE_3,
                AXI_RDQD_TABLE_2,
                AXI_RDQD_TABLE_1,
                AXI_RDQD_TABLE_0 };


  localparam MAX_AXI_WRQD_NB                        = `MAX_AXI_WRQD_NB;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_0 = (`UMCTL2_A_TYPE_0==2) ? 10 : `UMCTL2_AXI_WRQD_0;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_1 = (`UMCTL2_A_TYPE_1==2) ? 10 : `UMCTL2_AXI_WRQD_1;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_2 = (`UMCTL2_A_TYPE_2==2) ? 10 : `UMCTL2_AXI_WRQD_2;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_3 = (`UMCTL2_A_TYPE_3==2) ? 10 : `UMCTL2_AXI_WRQD_3;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_4 = (`UMCTL2_A_TYPE_4==2) ? 10 : `UMCTL2_AXI_WRQD_4;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_5 = (`UMCTL2_A_TYPE_5==2) ? 10 : `UMCTL2_AXI_WRQD_5;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_6 = (`UMCTL2_A_TYPE_6==2) ? 10 : `UMCTL2_AXI_WRQD_6;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_7 = (`UMCTL2_A_TYPE_7==2) ? 10 : `UMCTL2_AXI_WRQD_7;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_8 = (`UMCTL2_A_TYPE_8==2) ? 10 : `UMCTL2_AXI_WRQD_8;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_9 = (`UMCTL2_A_TYPE_9==2) ? 10 : `UMCTL2_AXI_WRQD_9;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_10 = (`UMCTL2_A_TYPE_10==2) ? 10 : `UMCTL2_AXI_WRQD_10;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_11 = (`UMCTL2_A_TYPE_11==2) ? 10 : `UMCTL2_AXI_WRQD_11;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_12 = (`UMCTL2_A_TYPE_12==2) ? 10 : `UMCTL2_AXI_WRQD_12;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_13 = (`UMCTL2_A_TYPE_13==2) ? 10 : `UMCTL2_AXI_WRQD_13;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_14 = (`UMCTL2_A_TYPE_14==2) ? 10 : `UMCTL2_AXI_WRQD_14;
  localparam [MAX_AXI_WRQD_NB-1:0] AXI_WRQD_TABLE_15 = (`UMCTL2_A_TYPE_15==2) ? 10 : `UMCTL2_AXI_WRQD_15;
  localparam [MAX_AXI_WRQD_NB*ARB_NPOTRS_MAX-1:0] AXI_WRQD_TABLE = {
                AXI_WRQD_TABLE_15,
                AXI_WRQD_TABLE_14,
                AXI_WRQD_TABLE_13,
                AXI_WRQD_TABLE_12,
                AXI_WRQD_TABLE_11,
                AXI_WRQD_TABLE_10,
                AXI_WRQD_TABLE_9,
                AXI_WRQD_TABLE_8,
                AXI_WRQD_TABLE_7,
                AXI_WRQD_TABLE_6,
                AXI_WRQD_TABLE_5,
                AXI_WRQD_TABLE_4,
                AXI_WRQD_TABLE_3,
                AXI_WRQD_TABLE_2,
                AXI_WRQD_TABLE_1,
                AXI_WRQD_TABLE_0 };


  localparam MAX_AXI_SYNC_NB                        = `MAX_AXI_SYNC_NB;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_0 = `UMCTL2_A_SYNC_0;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_1 = `UMCTL2_A_SYNC_1;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_2 = `UMCTL2_A_SYNC_2;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_3 = `UMCTL2_A_SYNC_3;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_4 = `UMCTL2_A_SYNC_4;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_5 = `UMCTL2_A_SYNC_5;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_6 = `UMCTL2_A_SYNC_6;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_7 = `UMCTL2_A_SYNC_7;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_8 = `UMCTL2_A_SYNC_8;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_9 = `UMCTL2_A_SYNC_9;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_10 = `UMCTL2_A_SYNC_10;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_11 = `UMCTL2_A_SYNC_11;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_12 = `UMCTL2_A_SYNC_12;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_13 = `UMCTL2_A_SYNC_13;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_14 = `UMCTL2_A_SYNC_14;
  localparam [MAX_AXI_SYNC_NB-1:0] AXI_SYNC_TABLE_15 = `UMCTL2_A_SYNC_15;
  localparam [MAX_AXI_SYNC_NB*ARB_NPOTRS_MAX-1:0] AXI_SYNC_TABLE = {
                AXI_SYNC_TABLE_15,
                AXI_SYNC_TABLE_14,
                AXI_SYNC_TABLE_13,
                AXI_SYNC_TABLE_12,
                AXI_SYNC_TABLE_11,
                AXI_SYNC_TABLE_10,
                AXI_SYNC_TABLE_9,
                AXI_SYNC_TABLE_8,
                AXI_SYNC_TABLE_7,
                AXI_SYNC_TABLE_6,
                AXI_SYNC_TABLE_5,
                AXI_SYNC_TABLE_4,
                AXI_SYNC_TABLE_3,
                AXI_SYNC_TABLE_2,
                AXI_SYNC_TABLE_1,
                AXI_SYNC_TABLE_0 };


  localparam MAX_RINFOW_NB                       = `MAX_RINFOW_NB;   
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_0  = `UMCTL2_XPI_RD_INFOW_0;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_1  = `UMCTL2_XPI_RD_INFOW_1;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_2  = `UMCTL2_XPI_RD_INFOW_2;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_3  = `UMCTL2_XPI_RD_INFOW_3;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_4  = `UMCTL2_XPI_RD_INFOW_4;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_5  = `UMCTL2_XPI_RD_INFOW_5;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_6  = `UMCTL2_XPI_RD_INFOW_6;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_7  = `UMCTL2_XPI_RD_INFOW_7;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_8  = `UMCTL2_XPI_RD_INFOW_8;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_9  = `UMCTL2_XPI_RD_INFOW_9;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_10 = `UMCTL2_XPI_RD_INFOW_10;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_11 = `UMCTL2_XPI_RD_INFOW_11;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_12 = `UMCTL2_XPI_RD_INFOW_12;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_13 = `UMCTL2_XPI_RD_INFOW_13;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_14 = `UMCTL2_XPI_RD_INFOW_14;
  localparam [MAX_RINFOW_NB-1:0] RINFOW_TABLE_15 = `UMCTL2_XPI_RD_INFOW_15;
  localparam [MAX_RINFOW_NB*ARB_NPOTRS_MAX-1:0] RINFOW_TABLE = {
                RINFOW_TABLE_15,
                RINFOW_TABLE_14,
                RINFOW_TABLE_13,
                RINFOW_TABLE_12,
                RINFOW_TABLE_11,
                RINFOW_TABLE_10,
                RINFOW_TABLE_9,
                RINFOW_TABLE_8,
                RINFOW_TABLE_7,
                RINFOW_TABLE_6,
                RINFOW_TABLE_5,
                RINFOW_TABLE_4,
                RINFOW_TABLE_3,
                RINFOW_TABLE_2,
                RINFOW_TABLE_1,
                RINFOW_TABLE_0 };


  localparam MAX_RINFOW_NSA_NB                          = `MAX_RINFOW_NSA_NB; 
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_0 = `UMCTL2_XPI_RD_INFOW_NSA_0;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_1 = `UMCTL2_XPI_RD_INFOW_NSA_1;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_2 = `UMCTL2_XPI_RD_INFOW_NSA_2;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_3 = `UMCTL2_XPI_RD_INFOW_NSA_3;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_4 = `UMCTL2_XPI_RD_INFOW_NSA_4;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_5 = `UMCTL2_XPI_RD_INFOW_NSA_5;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_6 = `UMCTL2_XPI_RD_INFOW_NSA_6;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_7 = `UMCTL2_XPI_RD_INFOW_NSA_7;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_8 = `UMCTL2_XPI_RD_INFOW_NSA_8;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_9 = `UMCTL2_XPI_RD_INFOW_NSA_9;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_10 = `UMCTL2_XPI_RD_INFOW_NSA_10;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_11 = `UMCTL2_XPI_RD_INFOW_NSA_11;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_12 = `UMCTL2_XPI_RD_INFOW_NSA_12;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_13 = `UMCTL2_XPI_RD_INFOW_NSA_13;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_14 = `UMCTL2_XPI_RD_INFOW_NSA_14;
  localparam [MAX_RINFOW_NSA_NB-1:0] RINFOW_NSA_TABLE_15 = `UMCTL2_XPI_RD_INFOW_NSA_15;
  localparam [MAX_RINFOW_NSA_NB*ARB_NPOTRS_MAX-1:0] RINFOW_NSA_TABLE = {
                RINFOW_NSA_TABLE_15,
                RINFOW_NSA_TABLE_14,
                RINFOW_NSA_TABLE_13,
                RINFOW_NSA_TABLE_12,
                RINFOW_NSA_TABLE_11,
                RINFOW_NSA_TABLE_10,
                RINFOW_NSA_TABLE_9,
                RINFOW_NSA_TABLE_8,
                RINFOW_NSA_TABLE_7,
                RINFOW_NSA_TABLE_6,
                RINFOW_NSA_TABLE_5,
                RINFOW_NSA_TABLE_4,
                RINFOW_NSA_TABLE_3,
                RINFOW_NSA_TABLE_2,
                RINFOW_NSA_TABLE_1,
                RINFOW_NSA_TABLE_0 };


  localparam MAX_WINFOW_NB                       = `MAX_WINFOW_NB;  
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_0  = `UMCTL2_XPI_WR_INFOW_0;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_1  = `UMCTL2_XPI_WR_INFOW_1;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_2  = `UMCTL2_XPI_WR_INFOW_2;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_3  = `UMCTL2_XPI_WR_INFOW_3;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_4  = `UMCTL2_XPI_WR_INFOW_4;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_5  = `UMCTL2_XPI_WR_INFOW_5;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_6  = `UMCTL2_XPI_WR_INFOW_6;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_7  = `UMCTL2_XPI_WR_INFOW_7;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_8  = `UMCTL2_XPI_WR_INFOW_8;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_9  = `UMCTL2_XPI_WR_INFOW_9;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_10 = `UMCTL2_XPI_WR_INFOW_10;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_11 = `UMCTL2_XPI_WR_INFOW_11;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_12 = `UMCTL2_XPI_WR_INFOW_12;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_13 = `UMCTL2_XPI_WR_INFOW_13;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_14 = `UMCTL2_XPI_WR_INFOW_14;
  localparam [MAX_WINFOW_NB-1:0] WINFOW_TABLE_15 = `UMCTL2_XPI_WR_INFOW_15;
  localparam [MAX_WINFOW_NB*ARB_NPOTRS_MAX-1:0] WINFOW_TABLE = {
                WINFOW_TABLE_15,
                WINFOW_TABLE_14,
                WINFOW_TABLE_13,
                WINFOW_TABLE_12,
                WINFOW_TABLE_11,
                WINFOW_TABLE_10,
                WINFOW_TABLE_9,
                WINFOW_TABLE_8,
                WINFOW_TABLE_7,
                WINFOW_TABLE_6,
                WINFOW_TABLE_5,
                WINFOW_TABLE_4,
                WINFOW_TABLE_3,
                WINFOW_TABLE_2,
                WINFOW_TABLE_1,
                WINFOW_TABLE_0 };


  localparam MAX_RPINFOW_NB                      =  `MAX_RPINFOW_NB; 
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_0 = `UMCTL2_XPI_RP_INFOW_0;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_1 = `UMCTL2_XPI_RP_INFOW_1;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_2 = `UMCTL2_XPI_RP_INFOW_2;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_3 = `UMCTL2_XPI_RP_INFOW_3;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_4 = `UMCTL2_XPI_RP_INFOW_4;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_5 = `UMCTL2_XPI_RP_INFOW_5;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_6 = `UMCTL2_XPI_RP_INFOW_6;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_7 = `UMCTL2_XPI_RP_INFOW_7;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_8 = `UMCTL2_XPI_RP_INFOW_8;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_9 = `UMCTL2_XPI_RP_INFOW_9;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_10 = `UMCTL2_XPI_RP_INFOW_10;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_11 = `UMCTL2_XPI_RP_INFOW_11;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_12 = `UMCTL2_XPI_RP_INFOW_12;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_13 = `UMCTL2_XPI_RP_INFOW_13;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_14 = `UMCTL2_XPI_RP_INFOW_14;
  localparam [MAX_RPINFOW_NB-1:0] RPINFOW_TABLE_15 = `UMCTL2_XPI_RP_INFOW_15;
  localparam [MAX_RPINFOW_NB*ARB_NPOTRS_MAX-1:0] RPINFOW_TABLE = {
                RPINFOW_TABLE_15,
                RPINFOW_TABLE_14,
                RPINFOW_TABLE_13,
                RPINFOW_TABLE_12,
                RPINFOW_TABLE_11,
                RPINFOW_TABLE_10,
                RPINFOW_TABLE_9,
                RPINFOW_TABLE_8,
                RPINFOW_TABLE_7,
                RPINFOW_TABLE_6,
                RPINFOW_TABLE_5,
                RPINFOW_TABLE_4,
                RPINFOW_TABLE_3,
                RPINFOW_TABLE_2,
                RPINFOW_TABLE_1,
                RPINFOW_TABLE_0 };

  localparam AXI_TAGBITS_NB                     = 24;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_0 = `UMCTL2_AXI_TAGBITS_0;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_1 = `UMCTL2_AXI_TAGBITS_1;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_2 = `UMCTL2_AXI_TAGBITS_2;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_3 = `UMCTL2_AXI_TAGBITS_3;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_4 = `UMCTL2_AXI_TAGBITS_4;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_5 = `UMCTL2_AXI_TAGBITS_5;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_6 = `UMCTL2_AXI_TAGBITS_6;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_7 = `UMCTL2_AXI_TAGBITS_7;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_8 = `UMCTL2_AXI_TAGBITS_8;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_9 = `UMCTL2_AXI_TAGBITS_9;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_10 = `UMCTL2_AXI_TAGBITS_10;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_11 = `UMCTL2_AXI_TAGBITS_11;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_12 = `UMCTL2_AXI_TAGBITS_12;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_13 = `UMCTL2_AXI_TAGBITS_13;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_14 = `UMCTL2_AXI_TAGBITS_14;
  localparam [AXI_TAGBITS_NB-1:0] AXI_TAGBITS_15 = `UMCTL2_AXI_TAGBITS_15;

   localparam [AXI_TAGBITS_NB*ARB_NPOTRS_MAX-1:0] AXI_TAGBITS_PRA_TABLE ={
                   AXI_TAGBITS_15, AXI_TAGBITS_14, AXI_TAGBITS_13, AXI_TAGBITS_12, 
                   AXI_TAGBITS_11, AXI_TAGBITS_10, AXI_TAGBITS_9,  AXI_TAGBITS_8, 
                   AXI_TAGBITS_7,  AXI_TAGBITS_6,  AXI_TAGBITS_5,  AXI_TAGBITS_4, 
                   AXI_TAGBITS_3,  AXI_TAGBITS_2,  AXI_TAGBITS_1,  AXI_TAGBITS_0}; 

  localparam AXI_TAGBITS_TOTAL_ID = (AXI_TAGBITS_15 + AXI_TAGBITS_14 + AXI_TAGBITS_13 + AXI_TAGBITS_12 +  
                                     AXI_TAGBITS_11 + AXI_TAGBITS_10 + AXI_TAGBITS_9  + AXI_TAGBITS_8  +  
                                     AXI_TAGBITS_7  + AXI_TAGBITS_6  + AXI_TAGBITS_5  + AXI_TAGBITS_4  +  
                                     AXI_TAGBITS_3  + AXI_TAGBITS_2  + AXI_TAGBITS_1  + AXI_TAGBITS_0   ); 

   localparam [AXI_TAGBITS_NB*(ARB_NPOTRS_MAX + 1)-1:0] AXI_TAGBITS_BUS_TABLE = { 
            AXI_TAGBITS_15[AXI_TAGBITS_NB-1:0]+ 
            AXI_TAGBITS_14[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_13[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_12[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_11[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_10[AXI_TAGBITS_NB-1:0]+
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,

            AXI_TAGBITS_14[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_13[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_12[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_11[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_10[AXI_TAGBITS_NB-1:0]+
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0 ,

            AXI_TAGBITS_13[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_12[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_11[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_10[AXI_TAGBITS_NB-1:0]+
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,

            AXI_TAGBITS_12[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_11[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_10[AXI_TAGBITS_NB-1:0]+
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,

            AXI_TAGBITS_11[AXI_TAGBITS_NB-1:0]+ AXI_TAGBITS_10[AXI_TAGBITS_NB-1:0]+
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
  
            AXI_TAGBITS_10[AXI_TAGBITS_NB-1:0]+
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] , 
 
            AXI_TAGBITS_9[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] + 
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
  
            AXI_TAGBITS_8[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] +
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
  
            AXI_TAGBITS_7[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] +
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
   
            AXI_TAGBITS_6[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] +
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
  
            AXI_TAGBITS_5[AXI_TAGBITS_NB-1:0] +
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
  
            AXI_TAGBITS_4[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
 
            AXI_TAGBITS_3[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
 
            AXI_TAGBITS_2[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
 
            AXI_TAGBITS_1[AXI_TAGBITS_NB-1:0] + AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
 
            AXI_TAGBITS_0[AXI_TAGBITS_NB-1:0] ,
            {AXI_TAGBITS_NB{1'b0}}};  
  

  localparam MAX_ASYNC_FIFO_N_SYNC_NB            = `MAX_ASYNC_FIFO_N_SYNC_NB;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_0 = `UMCTL2_ASYNC_FIFO_N_SYNC_0;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_1 = `UMCTL2_ASYNC_FIFO_N_SYNC_1;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_2 = `UMCTL2_ASYNC_FIFO_N_SYNC_2;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_3 = `UMCTL2_ASYNC_FIFO_N_SYNC_3;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_4 = `UMCTL2_ASYNC_FIFO_N_SYNC_4;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_5 = `UMCTL2_ASYNC_FIFO_N_SYNC_5;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_6 = `UMCTL2_ASYNC_FIFO_N_SYNC_6;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_7 = `UMCTL2_ASYNC_FIFO_N_SYNC_7;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_8 = `UMCTL2_ASYNC_FIFO_N_SYNC_8;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_9 = `UMCTL2_ASYNC_FIFO_N_SYNC_9;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_10 = `UMCTL2_ASYNC_FIFO_N_SYNC_10;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_11 = `UMCTL2_ASYNC_FIFO_N_SYNC_11;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_12 = `UMCTL2_ASYNC_FIFO_N_SYNC_12;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_13 = `UMCTL2_ASYNC_FIFO_N_SYNC_13;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_14 = `UMCTL2_ASYNC_FIFO_N_SYNC_14;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB-1:0] ASYNC_FIFO_N_SYNC_TABLE_15 = `UMCTL2_ASYNC_FIFO_N_SYNC_15;
  localparam [MAX_ASYNC_FIFO_N_SYNC_NB*ARB_NPOTRS_MAX-1:0] ASYNC_FIFO_N_SYNC_TABLE = {
                ASYNC_FIFO_N_SYNC_TABLE_15,
                ASYNC_FIFO_N_SYNC_TABLE_14,
                ASYNC_FIFO_N_SYNC_TABLE_13,
                ASYNC_FIFO_N_SYNC_TABLE_12,
                ASYNC_FIFO_N_SYNC_TABLE_11,
                ASYNC_FIFO_N_SYNC_TABLE_10,
                ASYNC_FIFO_N_SYNC_TABLE_9,
                ASYNC_FIFO_N_SYNC_TABLE_8,
                ASYNC_FIFO_N_SYNC_TABLE_7,
                ASYNC_FIFO_N_SYNC_TABLE_6,
                ASYNC_FIFO_N_SYNC_TABLE_5,
                ASYNC_FIFO_N_SYNC_TABLE_4,
                ASYNC_FIFO_N_SYNC_TABLE_3,
                ASYNC_FIFO_N_SYNC_TABLE_2,
                ASYNC_FIFO_N_SYNC_TABLE_1,
                ASYNC_FIFO_N_SYNC_TABLE_0 };


  localparam MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB   = 3;  //not from cc_constant!!!
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_0 = ASYNC_FIFO_EARLY_PUSH_STAT_0;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_1 = ASYNC_FIFO_EARLY_PUSH_STAT_1;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_2 = ASYNC_FIFO_EARLY_PUSH_STAT_2;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_3 = ASYNC_FIFO_EARLY_PUSH_STAT_3;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_4 = ASYNC_FIFO_EARLY_PUSH_STAT_4;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_5 = ASYNC_FIFO_EARLY_PUSH_STAT_5;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_6 = ASYNC_FIFO_EARLY_PUSH_STAT_6;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_7 = ASYNC_FIFO_EARLY_PUSH_STAT_7;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_8 = ASYNC_FIFO_EARLY_PUSH_STAT_8;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_9 = ASYNC_FIFO_EARLY_PUSH_STAT_9;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_10 = ASYNC_FIFO_EARLY_PUSH_STAT_10;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_11 = ASYNC_FIFO_EARLY_PUSH_STAT_11;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_12 = ASYNC_FIFO_EARLY_PUSH_STAT_12;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_13 = ASYNC_FIFO_EARLY_PUSH_STAT_13;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_14 = ASYNC_FIFO_EARLY_PUSH_STAT_14;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_15 = ASYNC_FIFO_EARLY_PUSH_STAT_15;
  localparam [MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB*ARB_NPOTRS_MAX-1:0] ASYNC_FIFO_EARLY_PUSH_STAT_TABLE = {
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_15,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_14,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_13,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_12,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_11,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_10,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_9,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_8,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_7,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_6,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_5,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_4,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_3,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_2,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_1,
                ASYNC_FIFO_EARLY_PUSH_STAT_TABLE_0 };


  localparam MAX_ASYNC_FIFO_EARLY_POP_STAT_NB    = 3;  //not from cc_constant!!!
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_0 = ASYNC_FIFO_EARLY_POP_STAT_0;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_1 = ASYNC_FIFO_EARLY_POP_STAT_1;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_2 = ASYNC_FIFO_EARLY_POP_STAT_2;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_3 = ASYNC_FIFO_EARLY_POP_STAT_3;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_4 = ASYNC_FIFO_EARLY_POP_STAT_4;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_5 = ASYNC_FIFO_EARLY_POP_STAT_5;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_6 = ASYNC_FIFO_EARLY_POP_STAT_6;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_7 = ASYNC_FIFO_EARLY_POP_STAT_7;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_8 = ASYNC_FIFO_EARLY_POP_STAT_8;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_9 = ASYNC_FIFO_EARLY_POP_STAT_9;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_10 = ASYNC_FIFO_EARLY_POP_STAT_10;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_11 = ASYNC_FIFO_EARLY_POP_STAT_11;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_12 = ASYNC_FIFO_EARLY_POP_STAT_12;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_13 = ASYNC_FIFO_EARLY_POP_STAT_13;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_14 = ASYNC_FIFO_EARLY_POP_STAT_14;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE_15 = ASYNC_FIFO_EARLY_POP_STAT_15;
  localparam [MAX_ASYNC_FIFO_EARLY_POP_STAT_NB*ARB_NPOTRS_MAX-1:0] ASYNC_FIFO_EARLY_POP_STAT_TABLE = {
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_15,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_14,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_13,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_12,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_11,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_10,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_9,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_8,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_7,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_6,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_5,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_4,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_3,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_2,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_1,
                ASYNC_FIFO_EARLY_POP_STAT_TABLE_0 };


  localparam MAX_DATA_CHANNEL_INTERLEAVE_NS_NB   = 1;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_0 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_0;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_1 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_1;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_2 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_2;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_3 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_3;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_4 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_4;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_5 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_5;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_6 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_6;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_7 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_7;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_8 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_8;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_9 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_9;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_10 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_10;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_11 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_11;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_12 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_12;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_13 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_13;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_14 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_14;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE_15 = `UMCTL2_DATA_CHANNEL_INTERLEAVE_NS_15;
  localparam [MAX_DATA_CHANNEL_INTERLEAVE_NS_NB*ARB_NPOTRS_MAX-1:0] DATA_CHANNEL_INTERLEAVE_NS_TABLE = {
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_15,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_14,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_13,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_12,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_11,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_10,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_9,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_8,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_7,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_6,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_5,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_4,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_3,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_2,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_1,
                DATA_CHANNEL_INTERLEAVE_NS_TABLE_0 };


  localparam MAX_VPR_EN_NB                       = `MAX_VPR_EN_NB;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_0  = `UMCTL2_XPI_VPR_EN_0;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_1  = `UMCTL2_XPI_VPR_EN_1;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_2  = `UMCTL2_XPI_VPR_EN_2;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_3  = `UMCTL2_XPI_VPR_EN_3;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_4  = `UMCTL2_XPI_VPR_EN_4;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_5  = `UMCTL2_XPI_VPR_EN_5;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_6  = `UMCTL2_XPI_VPR_EN_6;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_7  = `UMCTL2_XPI_VPR_EN_7;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_8  = `UMCTL2_XPI_VPR_EN_8;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_9  = `UMCTL2_XPI_VPR_EN_9;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_10 = `UMCTL2_XPI_VPR_EN_10;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_11 = `UMCTL2_XPI_VPR_EN_11;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_12 = `UMCTL2_XPI_VPR_EN_12;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_13 = `UMCTL2_XPI_VPR_EN_13;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_14 = `UMCTL2_XPI_VPR_EN_14;
  localparam [MAX_VPR_EN_NB-1:0] VPR_EN_TABLE_15 = `UMCTL2_XPI_VPR_EN_15;
  localparam [MAX_VPR_EN_NB*ARB_NPOTRS_MAX-1:0] VPR_EN_TABLE = {
                VPR_EN_TABLE_15,
                VPR_EN_TABLE_14,
                VPR_EN_TABLE_13,
                VPR_EN_TABLE_12,
                VPR_EN_TABLE_11,
                VPR_EN_TABLE_10,
                VPR_EN_TABLE_9,
                VPR_EN_TABLE_8,
                VPR_EN_TABLE_7,
                VPR_EN_TABLE_6,
                VPR_EN_TABLE_5,
                VPR_EN_TABLE_4,
                VPR_EN_TABLE_3,
                VPR_EN_TABLE_2,
                VPR_EN_TABLE_1,
                VPR_EN_TABLE_0 };


  localparam MAX_VPW_EN_NB                       = `MAX_VPW_EN_NB;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_0  = `UMCTL2_XPI_VPW_EN_0;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_1  = `UMCTL2_XPI_VPW_EN_1;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_2  = `UMCTL2_XPI_VPW_EN_2;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_3  = `UMCTL2_XPI_VPW_EN_3;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_4  = `UMCTL2_XPI_VPW_EN_4;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_5  = `UMCTL2_XPI_VPW_EN_5;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_6  = `UMCTL2_XPI_VPW_EN_6;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_7  = `UMCTL2_XPI_VPW_EN_7;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_8  = `UMCTL2_XPI_VPW_EN_8;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_9  = `UMCTL2_XPI_VPW_EN_9;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_10 = `UMCTL2_XPI_VPW_EN_10;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_11 = `UMCTL2_XPI_VPW_EN_11;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_12 = `UMCTL2_XPI_VPW_EN_12;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_13 = `UMCTL2_XPI_VPW_EN_13;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_14 = `UMCTL2_XPI_VPW_EN_14;
  localparam [MAX_VPW_EN_NB-1:0] VPW_EN_TABLE_15 = `UMCTL2_XPI_VPW_EN_15;
  localparam [MAX_VPW_EN_NB*ARB_NPOTRS_MAX-1:0] VPW_EN_TABLE = {
                VPW_EN_TABLE_15,
                VPW_EN_TABLE_14,
                VPW_EN_TABLE_13,
                VPW_EN_TABLE_12,
                VPW_EN_TABLE_11,
                VPW_EN_TABLE_10,
                VPW_EN_TABLE_9,
                VPW_EN_TABLE_8,
                VPW_EN_TABLE_7,
                VPW_EN_TABLE_6,
                VPW_EN_TABLE_5,
                VPW_EN_TABLE_4,
                VPW_EN_TABLE_3,
                VPW_EN_TABLE_2,
                VPW_EN_TABLE_1,
                VPW_EN_TABLE_0 };


  localparam MAX_USE2RAQ_NB                       = `MAX_USE2RAQ_NB;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_0 = `UMCTL2_XPI_USE2RAQ_0;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_1 = `UMCTL2_XPI_USE2RAQ_1;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_2 = `UMCTL2_XPI_USE2RAQ_2;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_3 = `UMCTL2_XPI_USE2RAQ_3;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_4 = `UMCTL2_XPI_USE2RAQ_4;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_5 = `UMCTL2_XPI_USE2RAQ_5;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_6 = `UMCTL2_XPI_USE2RAQ_6;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_7 = `UMCTL2_XPI_USE2RAQ_7;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_8 = `UMCTL2_XPI_USE2RAQ_8;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_9 = `UMCTL2_XPI_USE2RAQ_9;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_10 = `UMCTL2_XPI_USE2RAQ_10;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_11 = `UMCTL2_XPI_USE2RAQ_11;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_12 = `UMCTL2_XPI_USE2RAQ_12;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_13 = `UMCTL2_XPI_USE2RAQ_13;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_14 = `UMCTL2_XPI_USE2RAQ_14;
  localparam [MAX_USE2RAQ_NB-1:0] USE2RAQ_TABLE_15 = `UMCTL2_XPI_USE2RAQ_15;
  localparam [MAX_USE2RAQ_NB*ARB_NPOTRS_MAX-1:0] USE2RAQ_TABLE = {
                USE2RAQ_TABLE_15,
                USE2RAQ_TABLE_14,
                USE2RAQ_TABLE_13,
                USE2RAQ_TABLE_12,
                USE2RAQ_TABLE_11,
                USE2RAQ_TABLE_10,
                USE2RAQ_TABLE_9,
                USE2RAQ_TABLE_8,
                USE2RAQ_TABLE_7,
                USE2RAQ_TABLE_6,
                USE2RAQ_TABLE_5,
                USE2RAQ_TABLE_4,
                USE2RAQ_TABLE_3,
                USE2RAQ_TABLE_2,
                USE2RAQ_TABLE_1,
                USE2RAQ_TABLE_0 };


  localparam MAX_NUM_VIR_CH_NB                          = `MAX_NUM_VIR_CH_NB;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_0 = `UMCTL2_NUM_VIR_CH_0;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_1 = `UMCTL2_NUM_VIR_CH_1;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_2 = `UMCTL2_NUM_VIR_CH_2;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_3 = `UMCTL2_NUM_VIR_CH_3;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_4 = `UMCTL2_NUM_VIR_CH_4;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_5 = `UMCTL2_NUM_VIR_CH_5;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_6 = `UMCTL2_NUM_VIR_CH_6;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_7 = `UMCTL2_NUM_VIR_CH_7;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_8 = `UMCTL2_NUM_VIR_CH_8;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_9 = `UMCTL2_NUM_VIR_CH_9;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_10 = `UMCTL2_NUM_VIR_CH_10;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_11 = `UMCTL2_NUM_VIR_CH_11;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_12 = `UMCTL2_NUM_VIR_CH_12;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_13 = `UMCTL2_NUM_VIR_CH_13;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_14 = `UMCTL2_NUM_VIR_CH_14;
  localparam [MAX_NUM_VIR_CH_NB-1:0] NUM_VIR_CH_TABLE_15 = `UMCTL2_NUM_VIR_CH_15;
  localparam [MAX_NUM_VIR_CH_NB*ARB_NPOTRS_MAX-1:0] NUM_VIR_CH_TABLE = {
                NUM_VIR_CH_TABLE_15,
                NUM_VIR_CH_TABLE_14,
                NUM_VIR_CH_TABLE_13,
                NUM_VIR_CH_TABLE_12,
                NUM_VIR_CH_TABLE_11,
                NUM_VIR_CH_TABLE_10,
                NUM_VIR_CH_TABLE_9,
                NUM_VIR_CH_TABLE_8,
                NUM_VIR_CH_TABLE_7,
                NUM_VIR_CH_TABLE_6,
                NUM_VIR_CH_TABLE_5,
                NUM_VIR_CH_TABLE_4,
                NUM_VIR_CH_TABLE_3,
                NUM_VIR_CH_TABLE_2,
                NUM_VIR_CH_TABLE_1,
                NUM_VIR_CH_TABLE_0 };


  localparam MAX_STATIC_VIR_CH_NB                             = `MAX_STATIC_VIR_CH_NB;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_0 = `UMCTL2_STATIC_VIR_CH_0;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_1 = `UMCTL2_STATIC_VIR_CH_1;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_2 = `UMCTL2_STATIC_VIR_CH_2;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_3 = `UMCTL2_STATIC_VIR_CH_3;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_4 = `UMCTL2_STATIC_VIR_CH_4;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_5 = `UMCTL2_STATIC_VIR_CH_5;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_6 = `UMCTL2_STATIC_VIR_CH_6;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_7 = `UMCTL2_STATIC_VIR_CH_7;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_8 = `UMCTL2_STATIC_VIR_CH_8;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_9 = `UMCTL2_STATIC_VIR_CH_9;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_10 = `UMCTL2_STATIC_VIR_CH_10;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_11 = `UMCTL2_STATIC_VIR_CH_11;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_12 = `UMCTL2_STATIC_VIR_CH_12;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_13 = `UMCTL2_STATIC_VIR_CH_13;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_14 = `UMCTL2_STATIC_VIR_CH_14;
  localparam [MAX_STATIC_VIR_CH_NB-1:0] STATIC_VIR_CH_TABLE_15 = `UMCTL2_STATIC_VIR_CH_15;
  localparam [MAX_STATIC_VIR_CH_NB*ARB_NPOTRS_MAX-1:0] STATIC_VIR_CH_TABLE = {
                STATIC_VIR_CH_TABLE_15,
                STATIC_VIR_CH_TABLE_14,
                STATIC_VIR_CH_TABLE_13,
                STATIC_VIR_CH_TABLE_12,
                STATIC_VIR_CH_TABLE_11,
                STATIC_VIR_CH_TABLE_10,
                STATIC_VIR_CH_TABLE_9,
                STATIC_VIR_CH_TABLE_8,
                STATIC_VIR_CH_TABLE_7,
                STATIC_VIR_CH_TABLE_6,
                STATIC_VIR_CH_TABLE_5,
                STATIC_VIR_CH_TABLE_4,
                STATIC_VIR_CH_TABLE_3,
                STATIC_VIR_CH_TABLE_2,
                STATIC_VIR_CH_TABLE_1,
                STATIC_VIR_CH_TABLE_0 };


  localparam MAX_RRB_EXTRAM_NB                          = `MAX_RRB_EXTRAM_NB;  //exteranl read data ram
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_0 = `UMCTL2_RRB_EXTRAM_0;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_1 = `UMCTL2_RRB_EXTRAM_1;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_2 = `UMCTL2_RRB_EXTRAM_2;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_3 = `UMCTL2_RRB_EXTRAM_3;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_4 = `UMCTL2_RRB_EXTRAM_4;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_5 = `UMCTL2_RRB_EXTRAM_5;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_6 = `UMCTL2_RRB_EXTRAM_6;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_7 = `UMCTL2_RRB_EXTRAM_7;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_8 = `UMCTL2_RRB_EXTRAM_8;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_9 = `UMCTL2_RRB_EXTRAM_9;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_10 = `UMCTL2_RRB_EXTRAM_10;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_11 = `UMCTL2_RRB_EXTRAM_11;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_12 = `UMCTL2_RRB_EXTRAM_12;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_13 = `UMCTL2_RRB_EXTRAM_13;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_14 = `UMCTL2_RRB_EXTRAM_14;
  localparam [MAX_RRB_EXTRAM_NB-1:0] RRB_EXTRAM_TABLE_15 = `UMCTL2_RRB_EXTRAM_15;
  localparam [MAX_RRB_EXTRAM_NB*ARB_NPOTRS_MAX-1:0] RRB_EXTRAM_TABLE = {
                RRB_EXTRAM_TABLE_15,
                RRB_EXTRAM_TABLE_14,
                RRB_EXTRAM_TABLE_13,
                RRB_EXTRAM_TABLE_12,
                RRB_EXTRAM_TABLE_11,
                RRB_EXTRAM_TABLE_10,
                RRB_EXTRAM_TABLE_9,
                RRB_EXTRAM_TABLE_8,
                RRB_EXTRAM_TABLE_7,
                RRB_EXTRAM_TABLE_6,
                RRB_EXTRAM_TABLE_5,
                RRB_EXTRAM_TABLE_4,
                RRB_EXTRAM_TABLE_3,
                RRB_EXTRAM_TABLE_2,
                RRB_EXTRAM_TABLE_1,
                RRB_EXTRAM_TABLE_0 };

  localparam  MAX_SMALL_SIZED_PORT_NB                          = `MAX_SMALL_SIZED_PORT_NB;  //exteranl read data ram
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_0 =  `UMCTL2_XPI_SMALL_SIZED_PORT_0;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_1 =  `UMCTL2_XPI_SMALL_SIZED_PORT_1;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_2 =  `UMCTL2_XPI_SMALL_SIZED_PORT_2;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_3 =  `UMCTL2_XPI_SMALL_SIZED_PORT_3;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_4 =  `UMCTL2_XPI_SMALL_SIZED_PORT_4;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_5 =  `UMCTL2_XPI_SMALL_SIZED_PORT_5;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_6 =  `UMCTL2_XPI_SMALL_SIZED_PORT_6;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_7 =  `UMCTL2_XPI_SMALL_SIZED_PORT_7;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_8 =  `UMCTL2_XPI_SMALL_SIZED_PORT_8;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_9 =  `UMCTL2_XPI_SMALL_SIZED_PORT_9;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_10 = `UMCTL2_XPI_SMALL_SIZED_PORT_10;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_11 = `UMCTL2_XPI_SMALL_SIZED_PORT_11;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_12 = `UMCTL2_XPI_SMALL_SIZED_PORT_12;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_13 = `UMCTL2_XPI_SMALL_SIZED_PORT_13;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_14 = `UMCTL2_XPI_SMALL_SIZED_PORT_14;
  localparam [MAX_SMALL_SIZED_PORT_NB-1:0] XPI_SMALL_SIZED_PORT_15 = `UMCTL2_XPI_SMALL_SIZED_PORT_15;
  localparam [MAX_SMALL_SIZED_PORT_NB*ARB_NPOTRS_MAX-1:0] XPI_SMALL_SIZED_PORT_TABLE = {
                XPI_SMALL_SIZED_PORT_15,
                XPI_SMALL_SIZED_PORT_14,
                XPI_SMALL_SIZED_PORT_13,
                XPI_SMALL_SIZED_PORT_12,
                XPI_SMALL_SIZED_PORT_11,
                XPI_SMALL_SIZED_PORT_10,
                XPI_SMALL_SIZED_PORT_9,
                XPI_SMALL_SIZED_PORT_8,
                XPI_SMALL_SIZED_PORT_7,
                XPI_SMALL_SIZED_PORT_6,
                XPI_SMALL_SIZED_PORT_5,
                XPI_SMALL_SIZED_PORT_4,
                XPI_SMALL_SIZED_PORT_3,
                XPI_SMALL_SIZED_PORT_2,
                XPI_SMALL_SIZED_PORT_1,
                XPI_SMALL_SIZED_PORT_0 };


  localparam MAX_RRB_EXTRAM_REG_NB               = `MAX_RRB_EXTRAM_REG_NB;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_0 = `UMCTL2_RRB_EXTRAM_REG_0;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_1 = `UMCTL2_RRB_EXTRAM_REG_1;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_2 = `UMCTL2_RRB_EXTRAM_REG_2;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_3 = `UMCTL2_RRB_EXTRAM_REG_3;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_4 = `UMCTL2_RRB_EXTRAM_REG_4;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_5 = `UMCTL2_RRB_EXTRAM_REG_5;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_6 = `UMCTL2_RRB_EXTRAM_REG_6;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_7 = `UMCTL2_RRB_EXTRAM_REG_7;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_8 = `UMCTL2_RRB_EXTRAM_REG_8;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_9 = `UMCTL2_RRB_EXTRAM_REG_9;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_10 = `UMCTL2_RRB_EXTRAM_REG_10;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_11 = `UMCTL2_RRB_EXTRAM_REG_11;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_12 = `UMCTL2_RRB_EXTRAM_REG_12;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_13 = `UMCTL2_RRB_EXTRAM_REG_13;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_14 = `UMCTL2_RRB_EXTRAM_REG_14;
  localparam [MAX_RRB_EXTRAM_REG_NB-1:0] RRB_EXTRAM_REG_TABLE_15 = `UMCTL2_RRB_EXTRAM_REG_15;
  localparam [MAX_RRB_EXTRAM_REG_NB*ARB_NPOTRS_MAX-1:0] RRB_EXTRAM_REG_TABLE = {
                RRB_EXTRAM_REG_TABLE_15,
                RRB_EXTRAM_REG_TABLE_14,
                RRB_EXTRAM_REG_TABLE_13,
                RRB_EXTRAM_REG_TABLE_12,
                RRB_EXTRAM_REG_TABLE_11,
                RRB_EXTRAM_REG_TABLE_10,
                RRB_EXTRAM_REG_TABLE_9,
                RRB_EXTRAM_REG_TABLE_8,
                RRB_EXTRAM_REG_TABLE_7,
                RRB_EXTRAM_REG_TABLE_6,
                RRB_EXTRAM_REG_TABLE_5,
                RRB_EXTRAM_REG_TABLE_4,
                RRB_EXTRAM_REG_TABLE_3,
                RRB_EXTRAM_REG_TABLE_2,
                RRB_EXTRAM_REG_TABLE_1,
                RRB_EXTRAM_REG_TABLE_0 };

  localparam MAX_RRB_EXTRAM_RETIME_NB               = `MAX_RRB_EXTRAM_REG_NB;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_0 =  `UMCTL2_RRB_EXTRAM_RETIME_0;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_1 =  `UMCTL2_RRB_EXTRAM_RETIME_1;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_2 =  `UMCTL2_RRB_EXTRAM_RETIME_2;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_3 =  `UMCTL2_RRB_EXTRAM_RETIME_3;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_4 =  `UMCTL2_RRB_EXTRAM_RETIME_4;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_5 =  `UMCTL2_RRB_EXTRAM_RETIME_5;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_6 =  `UMCTL2_RRB_EXTRAM_RETIME_6;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_7 =  `UMCTL2_RRB_EXTRAM_RETIME_7;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_8 =  `UMCTL2_RRB_EXTRAM_RETIME_8;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_9 =  `UMCTL2_RRB_EXTRAM_RETIME_9;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_10 = `UMCTL2_RRB_EXTRAM_RETIME_10;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_11 = `UMCTL2_RRB_EXTRAM_RETIME_11;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_12 = `UMCTL2_RRB_EXTRAM_RETIME_12;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_13 = `UMCTL2_RRB_EXTRAM_RETIME_13;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_14 = `UMCTL2_RRB_EXTRAM_RETIME_14;
  localparam [MAX_RRB_EXTRAM_RETIME_NB-1:0] RRB_EXTRAM_RETIME_TABLE_15 = `UMCTL2_RRB_EXTRAM_RETIME_15;
  localparam [MAX_RRB_EXTRAM_RETIME_NB*ARB_NPOTRS_MAX-1:0] RRB_EXTRAM_RETIME_TABLE = {
                RRB_EXTRAM_RETIME_TABLE_15,
                RRB_EXTRAM_RETIME_TABLE_14,
                RRB_EXTRAM_RETIME_TABLE_13,
                RRB_EXTRAM_RETIME_TABLE_12,
                RRB_EXTRAM_RETIME_TABLE_11,
                RRB_EXTRAM_RETIME_TABLE_10,
                RRB_EXTRAM_RETIME_TABLE_9,
                RRB_EXTRAM_RETIME_TABLE_8,
                RRB_EXTRAM_RETIME_TABLE_7,
                RRB_EXTRAM_RETIME_TABLE_6,
                RRB_EXTRAM_RETIME_TABLE_5,
                RRB_EXTRAM_RETIME_TABLE_4,
                RRB_EXTRAM_RETIME_TABLE_3,
                RRB_EXTRAM_RETIME_TABLE_2,
                RRB_EXTRAM_RETIME_TABLE_1,
                RRB_EXTRAM_RETIME_TABLE_0 };



  localparam MAX_RDWR_ORDERED_NB                            = `MAX_RDWR_ORDERED_NB;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_0 = `UMCTL2_RDWR_ORDERED_0;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_1 = `UMCTL2_RDWR_ORDERED_1;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_2 = `UMCTL2_RDWR_ORDERED_2;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_3 = `UMCTL2_RDWR_ORDERED_3;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_4 = `UMCTL2_RDWR_ORDERED_4;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_5 = `UMCTL2_RDWR_ORDERED_5;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_6 = `UMCTL2_RDWR_ORDERED_6;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_7 = `UMCTL2_RDWR_ORDERED_7;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_8 = `UMCTL2_RDWR_ORDERED_8;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_9 = `UMCTL2_RDWR_ORDERED_9;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_10 = `UMCTL2_RDWR_ORDERED_10;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_11 = `UMCTL2_RDWR_ORDERED_11;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_12 = `UMCTL2_RDWR_ORDERED_12;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_13 = `UMCTL2_RDWR_ORDERED_13;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_14 = `UMCTL2_RDWR_ORDERED_14;
  localparam [MAX_RDWR_ORDERED_NB-1:0] RDWR_ORDERED_TABLE_15 = `UMCTL2_RDWR_ORDERED_15;
  localparam [MAX_RDWR_ORDERED_NB*ARB_NPOTRS_MAX-1:0] RDWR_ORDERED_TABLE = {
                RDWR_ORDERED_TABLE_15,
                RDWR_ORDERED_TABLE_14,
                RDWR_ORDERED_TABLE_13,
                RDWR_ORDERED_TABLE_12,
                RDWR_ORDERED_TABLE_11,
                RDWR_ORDERED_TABLE_10,
                RDWR_ORDERED_TABLE_9,
                RDWR_ORDERED_TABLE_8,
                RDWR_ORDERED_TABLE_7,
                RDWR_ORDERED_TABLE_6,
                RDWR_ORDERED_TABLE_5,
                RDWR_ORDERED_TABLE_4,
                RDWR_ORDERED_TABLE_3,
                RDWR_ORDERED_TABLE_2,
                RDWR_ORDERED_TABLE_1,
                RDWR_ORDERED_TABLE_0 };

  localparam MAX_RRB_THRESHOLD_EN_NB = `MAX_RRB_THRESHOLD_EN_NB;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_0 = `UMCTL2_RRB_THRESHOLD_EN_0;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_1 = `UMCTL2_RRB_THRESHOLD_EN_1;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_2 = `UMCTL2_RRB_THRESHOLD_EN_2;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_3 = `UMCTL2_RRB_THRESHOLD_EN_3;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_4 = `UMCTL2_RRB_THRESHOLD_EN_4;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_5 = `UMCTL2_RRB_THRESHOLD_EN_5;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_6 = `UMCTL2_RRB_THRESHOLD_EN_6;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_7 = `UMCTL2_RRB_THRESHOLD_EN_7;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_8 = `UMCTL2_RRB_THRESHOLD_EN_8;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_9 = `UMCTL2_RRB_THRESHOLD_EN_9;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_10 = `UMCTL2_RRB_THRESHOLD_EN_10;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_11 = `UMCTL2_RRB_THRESHOLD_EN_11;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_12 = `UMCTL2_RRB_THRESHOLD_EN_12;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_13 = `UMCTL2_RRB_THRESHOLD_EN_13;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_14 = `UMCTL2_RRB_THRESHOLD_EN_14;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_EN_TABLE_15 = `UMCTL2_RRB_THRESHOLD_EN_15;
  localparam [MAX_RRB_THRESHOLD_EN_NB*ARB_NPOTRS_MAX-1:0] RRB_THRESHOLD_EN_TABLE = {
                RRB_THRESHOLD_EN_TABLE_15,
                RRB_THRESHOLD_EN_TABLE_14,
                RRB_THRESHOLD_EN_TABLE_13,
                RRB_THRESHOLD_EN_TABLE_12,
                RRB_THRESHOLD_EN_TABLE_11,
                RRB_THRESHOLD_EN_TABLE_10,
                RRB_THRESHOLD_EN_TABLE_9,
                RRB_THRESHOLD_EN_TABLE_8,
                RRB_THRESHOLD_EN_TABLE_7,
                RRB_THRESHOLD_EN_TABLE_6,
                RRB_THRESHOLD_EN_TABLE_5,
                RRB_THRESHOLD_EN_TABLE_4,
                RRB_THRESHOLD_EN_TABLE_3,
                RRB_THRESHOLD_EN_TABLE_2,
                RRB_THRESHOLD_EN_TABLE_1,
                RRB_THRESHOLD_EN_TABLE_0 };

  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_0 = `UMCTL2_RRB_THRESHOLD_PPL_0;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_1 = `UMCTL2_RRB_THRESHOLD_PPL_1;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_2 = `UMCTL2_RRB_THRESHOLD_PPL_2;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_3 = `UMCTL2_RRB_THRESHOLD_PPL_3;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_4 = `UMCTL2_RRB_THRESHOLD_PPL_4;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_5 = `UMCTL2_RRB_THRESHOLD_PPL_5;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_6 = `UMCTL2_RRB_THRESHOLD_PPL_6;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_7 = `UMCTL2_RRB_THRESHOLD_PPL_7;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_8 = `UMCTL2_RRB_THRESHOLD_PPL_8;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_9 = `UMCTL2_RRB_THRESHOLD_PPL_9;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_10 = `UMCTL2_RRB_THRESHOLD_PPL_10;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_11 = `UMCTL2_RRB_THRESHOLD_PPL_11;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_12 = `UMCTL2_RRB_THRESHOLD_PPL_12;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_13 = `UMCTL2_RRB_THRESHOLD_PPL_13;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_14 = `UMCTL2_RRB_THRESHOLD_PPL_14;
  localparam [MAX_RRB_THRESHOLD_EN_NB-1:0] RRB_THRESHOLD_PPL_TABLE_15 = `UMCTL2_RRB_THRESHOLD_PPL_15;
  localparam [MAX_RRB_THRESHOLD_EN_NB*ARB_NPOTRS_MAX-1:0] RRB_THRESHOLD_PPL_TABLE = {
                RRB_THRESHOLD_PPL_TABLE_15,
                RRB_THRESHOLD_PPL_TABLE_14,
                RRB_THRESHOLD_PPL_TABLE_13,
                RRB_THRESHOLD_PPL_TABLE_12,
                RRB_THRESHOLD_PPL_TABLE_11,
                RRB_THRESHOLD_PPL_TABLE_10,
                RRB_THRESHOLD_PPL_TABLE_9,
                RRB_THRESHOLD_PPL_TABLE_8,
                RRB_THRESHOLD_PPL_TABLE_7,
                RRB_THRESHOLD_PPL_TABLE_6,
                RRB_THRESHOLD_PPL_TABLE_5,
                RRB_THRESHOLD_PPL_TABLE_4,
                RRB_THRESHOLD_PPL_TABLE_3,
                RRB_THRESHOLD_PPL_TABLE_2,
                RRB_THRESHOLD_PPL_TABLE_1,
                RRB_THRESHOLD_PPL_TABLE_0 };

  localparam MAX_READ_DATA_INTERLEAVE_EN_NB                                       = `MAX_READ_DATA_INTERLEAVE_EN_NB;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_0 = `UMCTL2_READ_DATA_INTERLEAVE_EN_0;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_1 = `UMCTL2_READ_DATA_INTERLEAVE_EN_1;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_2 = `UMCTL2_READ_DATA_INTERLEAVE_EN_2;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_3 = `UMCTL2_READ_DATA_INTERLEAVE_EN_3;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_4 = `UMCTL2_READ_DATA_INTERLEAVE_EN_4;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_5 = `UMCTL2_READ_DATA_INTERLEAVE_EN_5;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_6 = `UMCTL2_READ_DATA_INTERLEAVE_EN_6;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_7 = `UMCTL2_READ_DATA_INTERLEAVE_EN_7;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_8 = `UMCTL2_READ_DATA_INTERLEAVE_EN_8;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_9 = `UMCTL2_READ_DATA_INTERLEAVE_EN_9;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_10 = `UMCTL2_READ_DATA_INTERLEAVE_EN_10;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_11 = `UMCTL2_READ_DATA_INTERLEAVE_EN_11;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_12 = `UMCTL2_READ_DATA_INTERLEAVE_EN_12;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_13 = `UMCTL2_READ_DATA_INTERLEAVE_EN_13;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_14 = `UMCTL2_READ_DATA_INTERLEAVE_EN_14;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB-1:0] READ_DATA_INTERLEAVE_EN_TABLE_15 = `UMCTL2_READ_DATA_INTERLEAVE_EN_15;
  localparam [MAX_READ_DATA_INTERLEAVE_EN_NB*ARB_NPOTRS_MAX-1:0] READ_DATA_INTERLEAVE_EN_TABLE = {
                READ_DATA_INTERLEAVE_EN_TABLE_15,
                READ_DATA_INTERLEAVE_EN_TABLE_14,
                READ_DATA_INTERLEAVE_EN_TABLE_13,
                READ_DATA_INTERLEAVE_EN_TABLE_12,
                READ_DATA_INTERLEAVE_EN_TABLE_11,
                READ_DATA_INTERLEAVE_EN_TABLE_10,
                READ_DATA_INTERLEAVE_EN_TABLE_9,
                READ_DATA_INTERLEAVE_EN_TABLE_8,
                READ_DATA_INTERLEAVE_EN_TABLE_7,
                READ_DATA_INTERLEAVE_EN_TABLE_6,
                READ_DATA_INTERLEAVE_EN_TABLE_5,
                READ_DATA_INTERLEAVE_EN_TABLE_4,
                READ_DATA_INTERLEAVE_EN_TABLE_3,
                READ_DATA_INTERLEAVE_EN_TABLE_2,
                READ_DATA_INTERLEAVE_EN_TABLE_1,
                READ_DATA_INTERLEAVE_EN_TABLE_0 };

  localparam WDATA_PTR_BITS                      = `MEMC_WDATA_PTR_BITS;
  localparam A_NPORTS                            = `UMCTL2_A_NPORTS;
  localparam M_DW                                = `MEMC_DRAM_DATA_WIDTH;
  localparam M_DW_INT                            = `MEMC_DRAM_DATA_WIDTH*`UMCTL2_NUM_DATA_CHANNEL;
  localparam M_LPDDR3                            = `MEMC_LPDDR3_EN;
  localparam M_DDR5                              = `MEMC_DDR5_EN;

  localparam AXI_LOCKW_FIX                       = `UMCTL2_AXI_LOCK_WIDTH;
  localparam BRW                                 = 4;
  localparam DBW                                 = 2;
  localparam AMCOLW_H                            = 5;
  localparam AMCOLW_L                            = 4;
  localparam AMCOLW_C3                           = 4;
  localparam AMDCHW                              = 6;
  localparam AMCSW                               = 6;
  localparam AMCIDW                              = 6;
  localparam AMBANKW                             = 6;
  localparam AMBGW                               = 6;
  localparam AMROWW                              = 5;

  localparam USE_SAR                             = `THEREIS_SAR;
  localparam NSAR                                = `UMCTL2_A_NSAR;
  localparam UMCTL2_PARTIAL_WR_EN                = `UMCTL2_PARTIAL_WR_EN;
  localparam MEMC_DDR4_EN                        = `MEMC_DDR4_EN;

  localparam MAX_A_PORT_NUM_NB                   = 4;  
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_0 = 0;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_1 = 1;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_2 = 2;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_3 = 3;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_4 = 4;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_5 = 5;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_6 = 6;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_7 = 7;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_8 = 8;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_9 = 9;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_10 = 10;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_11 = 11;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_12 = 12;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_13 = 13;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_14 = 14;
  localparam [MAX_A_PORT_NUM_NB-1:0] A_PORT_NUM_TABLE_15 = 15;
  localparam [MAX_A_PORT_NUM_NB*ARB_NPOTRS_MAX-1:0] A_PORT_NUM_TABLE = {
                A_PORT_NUM_TABLE_15,
                A_PORT_NUM_TABLE_14,
                A_PORT_NUM_TABLE_13,
                A_PORT_NUM_TABLE_12,
                A_PORT_NUM_TABLE_11,
                A_PORT_NUM_TABLE_10,
                A_PORT_NUM_TABLE_9,
                A_PORT_NUM_TABLE_8,
                A_PORT_NUM_TABLE_7,
                A_PORT_NUM_TABLE_6,
                A_PORT_NUM_TABLE_5,
                A_PORT_NUM_TABLE_4,
                A_PORT_NUM_TABLE_3,
                A_PORT_NUM_TABLE_2,
                A_PORT_NUM_TABLE_1,
                A_PORT_NUM_TABLE_0 };


  localparam MAX_A_STRBW_INT_NB                           = `MAX_A_DW_INT_NB;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_0 = `UMCTL2_A_DW_INT_0/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_1 = `UMCTL2_A_DW_INT_1/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_2 = `UMCTL2_A_DW_INT_2/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_3 = `UMCTL2_A_DW_INT_3/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_4 = `UMCTL2_A_DW_INT_4/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_5 = `UMCTL2_A_DW_INT_5/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_6 = `UMCTL2_A_DW_INT_6/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_7 = `UMCTL2_A_DW_INT_7/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_8 = `UMCTL2_A_DW_INT_8/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_9 = `UMCTL2_A_DW_INT_9/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_10 = `UMCTL2_A_DW_INT_10/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_11 = `UMCTL2_A_DW_INT_11/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_12 = `UMCTL2_A_DW_INT_12/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_13 = `UMCTL2_A_DW_INT_13/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_14 = `UMCTL2_A_DW_INT_14/8;
  localparam [MAX_A_STRBW_INT_NB-1:0] A_STRBW_INT_TABLE_15 = `UMCTL2_A_DW_INT_15/8;
  localparam [MAX_A_STRBW_INT_NB*ARB_NPOTRS_MAX-1:0] A_STRBW_INT_TABLE = {
                A_STRBW_INT_TABLE_15,
                A_STRBW_INT_TABLE_14,
                A_STRBW_INT_TABLE_13,
                A_STRBW_INT_TABLE_12,
                A_STRBW_INT_TABLE_11,
                A_STRBW_INT_TABLE_10,
                A_STRBW_INT_TABLE_9,
                A_STRBW_INT_TABLE_8,
                A_STRBW_INT_TABLE_7,
                A_STRBW_INT_TABLE_6,
                A_STRBW_INT_TABLE_5,
                A_STRBW_INT_TABLE_4,
                A_STRBW_INT_TABLE_3,
                A_STRBW_INT_TABLE_2,
                A_STRBW_INT_TABLE_1,
                A_STRBW_INT_TABLE_0 };


  localparam MAX_A_PARW_INT_NB                           =  `MAX_A_DW_INT_NB;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_0 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_0 : A_STRBW_INT_TABLE_0;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_1 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_1 : A_STRBW_INT_TABLE_1;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_2 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_2 : A_STRBW_INT_TABLE_2;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_3 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_3 : A_STRBW_INT_TABLE_3;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_4 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_4 : A_STRBW_INT_TABLE_4;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_5 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_5 : A_STRBW_INT_TABLE_5;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_6 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_6 : A_STRBW_INT_TABLE_6;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_7 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_7 : A_STRBW_INT_TABLE_7;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_8 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_8 : A_STRBW_INT_TABLE_8;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_9 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_9 : A_STRBW_INT_TABLE_9;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_10 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_10 : A_STRBW_INT_TABLE_10;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_11 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_11 : A_STRBW_INT_TABLE_11;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_12 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_12 : A_STRBW_INT_TABLE_12;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_13 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_13 : A_STRBW_INT_TABLE_13;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_14 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_14 : A_STRBW_INT_TABLE_14;
  localparam [MAX_A_PARW_INT_NB-1:0] A_PARW_INT_TABLE_15 = (OCECC_EN == 1) ? 5*A_STRBW_INT_TABLE_15 : A_STRBW_INT_TABLE_15;
  localparam [MAX_A_PARW_INT_NB*ARB_NPOTRS_MAX-1:0] A_PARW_INT_TABLE = {
                A_PARW_INT_TABLE_15,
                A_PARW_INT_TABLE_14,
                A_PARW_INT_TABLE_13,
                A_PARW_INT_TABLE_12,
                A_PARW_INT_TABLE_11,
                A_PARW_INT_TABLE_10,
                A_PARW_INT_TABLE_9,
                A_PARW_INT_TABLE_8,
                A_PARW_INT_TABLE_7,
                A_PARW_INT_TABLE_6,
                A_PARW_INT_TABLE_5,
                A_PARW_INT_TABLE_4,
                A_PARW_INT_TABLE_3,
                A_PARW_INT_TABLE_2,
                A_PARW_INT_TABLE_1,
                A_PARW_INT_TABLE_0 };


  localparam AXI_DW_NB =  24;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_0 = `UMCTL2_PORT_DW_0;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_1 = `UMCTL2_PORT_DW_1;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_2 = `UMCTL2_PORT_DW_2;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_3 = `UMCTL2_PORT_DW_3;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_4 = `UMCTL2_PORT_DW_4;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_5 = `UMCTL2_PORT_DW_5;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_6 = `UMCTL2_PORT_DW_6;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_7 = `UMCTL2_PORT_DW_7;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_8 = `UMCTL2_PORT_DW_8;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_9 = `UMCTL2_PORT_DW_9;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_10 = `UMCTL2_PORT_DW_10;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_11 = `UMCTL2_PORT_DW_11;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_12 = `UMCTL2_PORT_DW_12;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_13 = `UMCTL2_PORT_DW_13;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_14 = `UMCTL2_PORT_DW_14;
  localparam [AXI_DW_NB-1:0] AXI_DATAW_15 = `UMCTL2_PORT_DW_15;
 
  localparam [AXI_DW_NB*ARB_NPOTRS_MAX-1:0] AXI_DATAW_PRA_TABLE = {
            AXI_DATAW_15, AXI_DATAW_14, AXI_DATAW_13, AXI_DATAW_12,  
            AXI_DATAW_11, AXI_DATAW_10, AXI_DATAW_9,  AXI_DATAW_8,  
            AXI_DATAW_7,  AXI_DATAW_6,  AXI_DATAW_5,  AXI_DATAW_4,  
            AXI_DATAW_3,  AXI_DATAW_2,  AXI_DATAW_1,  AXI_DATAW_0};  

  localparam AXI_TOTAL_DW = (
            AXI_DATAW_0
 );
  
  localparam [AXI_DW_NB*(ARB_NPOTRS_MAX + 1)-1:0] AXI_DATAW_BUS_TABLE = { 
            AXI_DATAW_15[AXI_DW_NB-1:0]+ 
            AXI_DATAW_14[AXI_DW_NB-1:0]+ AXI_DATAW_13[AXI_DW_NB-1:0]+ AXI_DATAW_12[AXI_DW_NB-1:0]+ AXI_DATAW_11[AXI_DW_NB-1:0]+ AXI_DATAW_10[AXI_DW_NB-1:0]+
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,

            AXI_DATAW_14[AXI_DW_NB-1:0]+ AXI_DATAW_13[AXI_DW_NB-1:0]+ AXI_DATAW_12[AXI_DW_NB-1:0]+ AXI_DATAW_11[AXI_DW_NB-1:0]+ AXI_DATAW_10[AXI_DW_NB-1:0]+
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,

            AXI_DATAW_13[AXI_DW_NB-1:0]+ AXI_DATAW_12[AXI_DW_NB-1:0]+ AXI_DATAW_11[AXI_DW_NB-1:0]+ AXI_DATAW_10[AXI_DW_NB-1:0]+
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,

            AXI_DATAW_12[AXI_DW_NB-1:0]+ AXI_DATAW_11[AXI_DW_NB-1:0]+ AXI_DATAW_10[AXI_DW_NB-1:0]+
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,

            AXI_DATAW_11[AXI_DW_NB-1:0]+ AXI_DATAW_10[AXI_DW_NB-1:0]+
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
  
            AXI_DATAW_10[AXI_DW_NB-1:0]+
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] , 
 
            AXI_DATAW_9[AXI_DW_NB-1:0] + AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] + 
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
  
            AXI_DATAW_8[AXI_DW_NB-1:0] + AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] +
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
  
            AXI_DATAW_7[AXI_DW_NB-1:0] + AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] +
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
   
            AXI_DATAW_6[AXI_DW_NB-1:0] + AXI_DATAW_5[AXI_DW_NB-1:0] +
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
  
            AXI_DATAW_5[AXI_DW_NB-1:0] +
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
  
            AXI_DATAW_4[AXI_DW_NB-1:0] + AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
 
            AXI_DATAW_3[AXI_DW_NB-1:0] + AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
 
            AXI_DATAW_2[AXI_DW_NB-1:0] + AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
 
            AXI_DATAW_1[AXI_DW_NB-1:0] + AXI_DATAW_0[AXI_DW_NB-1:0] ,
 
            AXI_DATAW_0[AXI_DW_NB-1:0] ,
 
            {AXI_DW_NB{1'b0}}}; 
 
  localparam AXI_STRBW_NB = 22; 

  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_0 = `UMCTL2_PORT_NBYTES_0;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_1 = `UMCTL2_PORT_NBYTES_1;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_2 = `UMCTL2_PORT_NBYTES_2;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_3 = `UMCTL2_PORT_NBYTES_3;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_4 = `UMCTL2_PORT_NBYTES_4;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_5 = `UMCTL2_PORT_NBYTES_5;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_6 = `UMCTL2_PORT_NBYTES_6;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_7 = `UMCTL2_PORT_NBYTES_7;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_8 = `UMCTL2_PORT_NBYTES_8;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_9 = `UMCTL2_PORT_NBYTES_9;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_10 = `UMCTL2_PORT_NBYTES_10;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_11 = `UMCTL2_PORT_NBYTES_11;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_12 = `UMCTL2_PORT_NBYTES_12;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_13 = `UMCTL2_PORT_NBYTES_13;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_14 = `UMCTL2_PORT_NBYTES_14;
  localparam [AXI_STRBW_NB-1:0] AXI_STRBW_15 = `UMCTL2_PORT_NBYTES_15;

  localparam [AXI_STRBW_NB*ARB_NPOTRS_MAX-1:0] AXI_STRBW_PRA_TABLE = {
                       AXI_STRBW_15, AXI_STRBW_14, AXI_STRBW_13, AXI_STRBW_12, 
                       AXI_STRBW_11, AXI_STRBW_10, AXI_STRBW_9,  AXI_STRBW_8, 
                       AXI_STRBW_7,  AXI_STRBW_6,  AXI_STRBW_5,  AXI_STRBW_4, 
                       AXI_STRBW_3,  AXI_STRBW_2,  AXI_STRBW_1,  AXI_STRBW_0}; 
 
  localparam AXI_TOTAL_STRBW = (
            AXI_STRBW_0
 );
 
  localparam [AXI_STRBW_NB*(ARB_NPOTRS_MAX + 1)-1:0] AXI_STRBW_BUS_TABLE = { 
            AXI_STRBW_15[AXI_STRBW_NB-1:0]+ 
            AXI_STRBW_14[AXI_STRBW_NB-1:0]+ AXI_STRBW_13[AXI_STRBW_NB-1:0]+ AXI_STRBW_12[AXI_STRBW_NB-1:0]+ AXI_STRBW_11[AXI_STRBW_NB-1:0]+ AXI_STRBW_10[AXI_STRBW_NB-1:0]+
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,

            AXI_STRBW_14[AXI_STRBW_NB-1:0]+ AXI_STRBW_13[AXI_STRBW_NB-1:0]+ AXI_STRBW_12[AXI_STRBW_NB-1:0]+ AXI_STRBW_11[AXI_STRBW_NB-1:0]+ AXI_STRBW_10[AXI_STRBW_NB-1:0]+
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,

            AXI_STRBW_13[AXI_STRBW_NB-1:0]+ AXI_STRBW_12[AXI_STRBW_NB-1:0]+ AXI_STRBW_11[AXI_STRBW_NB-1:0]+ AXI_STRBW_10[AXI_STRBW_NB-1:0]+
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,

            AXI_STRBW_12[AXI_STRBW_NB-1:0]+ AXI_STRBW_11[AXI_STRBW_NB-1:0]+ AXI_STRBW_10[AXI_STRBW_NB-1:0]+
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,

            AXI_STRBW_11[AXI_STRBW_NB-1:0]+ AXI_STRBW_10[AXI_STRBW_NB-1:0]+
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
  
            AXI_STRBW_10[AXI_STRBW_NB-1:0]+
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] , 
 
            AXI_STRBW_9[AXI_STRBW_NB-1:0] + AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] + 
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
  
            AXI_STRBW_8[AXI_STRBW_NB-1:0] + AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] +
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
  
            AXI_STRBW_7[AXI_STRBW_NB-1:0] + AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] +
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
   
            AXI_STRBW_6[AXI_STRBW_NB-1:0] + AXI_STRBW_5[AXI_STRBW_NB-1:0] +
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
  
            AXI_STRBW_5[AXI_STRBW_NB-1:0] +
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
  
            AXI_STRBW_4[AXI_STRBW_NB-1:0] + AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1 + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
 
            AXI_STRBW_3[AXI_STRBW_NB-1:0] + AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
 
            AXI_STRBW_2[AXI_STRBW_NB-1:0] + AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
 
            AXI_STRBW_1[AXI_STRBW_NB-1:0] + AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
 
            AXI_STRBW_0[AXI_STRBW_NB-1:0] ,
            {AXI_STRBW_NB{1'b0}}}; 
   
  localparam AXI_LOCKW_NB = 12; 

  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_0 = `UMCTL2_AXI_LOCK_WIDTH_0;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_1 = `UMCTL2_AXI_LOCK_WIDTH_1;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_2 = `UMCTL2_AXI_LOCK_WIDTH_2;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_3 = `UMCTL2_AXI_LOCK_WIDTH_3;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_4 = `UMCTL2_AXI_LOCK_WIDTH_4;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_5 = `UMCTL2_AXI_LOCK_WIDTH_5;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_6 = `UMCTL2_AXI_LOCK_WIDTH_6;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_7 = `UMCTL2_AXI_LOCK_WIDTH_7;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_8 = `UMCTL2_AXI_LOCK_WIDTH_8;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_9 = `UMCTL2_AXI_LOCK_WIDTH_9;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_10 = `UMCTL2_AXI_LOCK_WIDTH_10;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_11 = `UMCTL2_AXI_LOCK_WIDTH_11;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_12 = `UMCTL2_AXI_LOCK_WIDTH_12;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_13 = `UMCTL2_AXI_LOCK_WIDTH_13;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_14 = `UMCTL2_AXI_LOCK_WIDTH_14;
  localparam [AXI_LOCKW_NB-1:0] AXI_LOCKW_15 = `UMCTL2_AXI_LOCK_WIDTH_15;

  localparam [AXI_LOCKW_NB*ARB_NPOTRS_MAX-1:0] AXI_LOCKW_PRA_TABLE = {
                       AXI_LOCKW_15, AXI_LOCKW_14, AXI_LOCKW_13, AXI_LOCKW_12, 
                       AXI_LOCKW_11, AXI_LOCKW_10, AXI_LOCKW_9,  AXI_LOCKW_8, 
                       AXI_LOCKW_7,  AXI_LOCKW_6,  AXI_LOCKW_5,  AXI_LOCKW_4, 
                       AXI_LOCKW_3,  AXI_LOCKW_2,  AXI_LOCKW_1,  AXI_LOCKW_0}; 
 
  localparam AXI_TOTAL_LOCKW = (
            AXI_LOCKW_15 + AXI_LOCKW_14 + AXI_LOCKW_13 + AXI_LOCKW_12 +  
            AXI_LOCKW_11 + AXI_LOCKW_10 + AXI_LOCKW_9  + AXI_LOCKW_8  +  
            AXI_LOCKW_7  + AXI_LOCKW_6  + AXI_LOCKW_5  + AXI_LOCKW_4  +  
            AXI_LOCKW_3  + AXI_LOCKW_2  + AXI_LOCKW_1  + AXI_LOCKW_0   ); 
 
  localparam [AXI_LOCKW_NB*(ARB_NPOTRS_MAX + 1)-1:0] AXI_LOCKW_BUS_TABLE = { 
            AXI_LOCKW_15[AXI_LOCKW_NB-1:0]+ 
            AXI_LOCKW_14[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_13[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_12[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_11[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_10[AXI_LOCKW_NB-1:0]+
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,

            AXI_LOCKW_14[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_13[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_12[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_11[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_10[AXI_LOCKW_NB-1:0]+
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,

            AXI_LOCKW_13[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_12[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_11[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_10[AXI_LOCKW_NB-1:0]+
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,

            AXI_LOCKW_12[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_11[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_10[AXI_LOCKW_NB-1:0]+
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,

            AXI_LOCKW_11[AXI_LOCKW_NB-1:0]+ AXI_LOCKW_10[AXI_LOCKW_NB-1:0]+
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
  
            AXI_LOCKW_10[AXI_LOCKW_NB-1:0]+
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] , 
 
            AXI_LOCKW_9[AXI_LOCKW_NB-1:0] + AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] + 
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
  
            AXI_LOCKW_8[AXI_LOCKW_NB-1:0] + AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] +
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
  
            AXI_LOCKW_7[AXI_LOCKW_NB-1:0] + AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] +
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
   
            AXI_LOCKW_6[AXI_LOCKW_NB-1:0] + AXI_LOCKW_5[AXI_LOCKW_NB-1:0] +
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
  
            AXI_LOCKW_5[AXI_LOCKW_NB-1:0] +
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
  
            AXI_LOCKW_4[AXI_LOCKW_NB-1:0] + AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
 
            AXI_LOCKW_3[AXI_LOCKW_NB-1:0] + AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
 
            AXI_LOCKW_2[AXI_LOCKW_NB-1:0] + AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
 
            AXI_LOCKW_1[AXI_LOCKW_NB-1:0] + AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
 
            AXI_LOCKW_0[AXI_LOCKW_NB-1:0] ,
            {AXI_LOCKW_NB{1'b0}}}; 

  localparam AXI_WAQD_LG2_NB = 24;
 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_0) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_0);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_1 = (`UMCTL2_A_TYPE_1==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_1) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_1);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_2 = (`UMCTL2_A_TYPE_2==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_2) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_2);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_3 = (`UMCTL2_A_TYPE_3==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_3) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_3);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_4 = (`UMCTL2_A_TYPE_4==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_4) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_4);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_5 = (`UMCTL2_A_TYPE_5==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_5) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_5);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_6 = (`UMCTL2_A_TYPE_6==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_6) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_6);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_7 = (`UMCTL2_A_TYPE_7==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_7) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_7);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_8 = (`UMCTL2_A_TYPE_8==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_8) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_8);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_9 = (`UMCTL2_A_TYPE_9==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_9) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_9);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_10 = (`UMCTL2_A_TYPE_10==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_10) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_10);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_11 = (`UMCTL2_A_TYPE_11==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_11) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_11);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_12 = (`UMCTL2_A_TYPE_12==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_12) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_12);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_13 = (`UMCTL2_A_TYPE_13==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_13) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_13);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_14 = (`UMCTL2_A_TYPE_14==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_14) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_14);
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_15 = (`UMCTL2_A_TYPE_15==2) ? `UMCTL_LOG2(`UMCTL2_AHB_WAQD_15) : `UMCTL_LOG2(`UMCTL2_AXI_WAQD_15); 

  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_0 = AXI_WAQD_LG2_0 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_1 = AXI_WAQD_LG2_1 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_2 = AXI_WAQD_LG2_2 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_3 = AXI_WAQD_LG2_3 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_4 = AXI_WAQD_LG2_4 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_5 = AXI_WAQD_LG2_5 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_6 = AXI_WAQD_LG2_6 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_7 = AXI_WAQD_LG2_7 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_8 = AXI_WAQD_LG2_8 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_9 = AXI_WAQD_LG2_9 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_10 = AXI_WAQD_LG2_10 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_11 = AXI_WAQD_LG2_11 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_12 = AXI_WAQD_LG2_12 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_13 = AXI_WAQD_LG2_13 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_14 = AXI_WAQD_LG2_14 + 1; 
  localparam [AXI_WAQD_LG2_NB-1:0] AXI_WAQD_LG2_PLUS1_15 = AXI_WAQD_LG2_15 + 1; 
   
  localparam [AXI_WAQD_LG2_NB*ARB_NPOTRS_MAX-1:0] AXI_WAQD_LG2_PRA_TABLE = {
                       AXI_WAQD_LG2_15, AXI_WAQD_LG2_14, AXI_WAQD_LG2_13, AXI_WAQD_LG2_12, 
                       AXI_WAQD_LG2_11, AXI_WAQD_LG2_10, AXI_WAQD_LG2_9,  AXI_WAQD_LG2_8, 
                       AXI_WAQD_LG2_7,  AXI_WAQD_LG2_6,  AXI_WAQD_LG2_5,  AXI_WAQD_LG2_4, 
                       AXI_WAQD_LG2_3,  AXI_WAQD_LG2_2,  AXI_WAQD_LG2_1,  AXI_WAQD_LG2_0}; 
 
  localparam AXI_TOTAL_WAQD_LG2 = (
            AXI_WAQD_LG2_PLUS1_0 
 );
 
  localparam [AXI_WAQD_LG2_NB*(ARB_NPOTRS_MAX + 1)-1:0] AXI_WAQD_LG2_BUS_TABLE = { 
            AXI_WAQD_LG2_PLUS1_15[AXI_WAQD_LG2_NB-1:0]+ 
            AXI_WAQD_LG2_PLUS1_14[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_13[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_12[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_11[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_10[AXI_WAQD_LG2_NB-1:0]+
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,

            AXI_WAQD_LG2_PLUS1_14[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_13[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_12[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_11[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_10[AXI_WAQD_LG2_NB-1:0]+
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,

            AXI_WAQD_LG2_PLUS1_13[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_12[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_11[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_10[AXI_WAQD_LG2_NB-1:0]+
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,

            AXI_WAQD_LG2_PLUS1_12[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_11[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_10[AXI_WAQD_LG2_NB-1:0]+
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,

            AXI_WAQD_LG2_PLUS1_11[AXI_WAQD_LG2_NB-1:0]+ AXI_WAQD_LG2_PLUS1_10[AXI_WAQD_LG2_NB-1:0]+
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
  
            AXI_WAQD_LG2_PLUS1_10[AXI_WAQD_LG2_NB-1:0]+
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] , 
 
            AXI_WAQD_LG2_PLUS1_9[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] + 
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
  
            AXI_WAQD_LG2_PLUS1_8[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] +
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
  
            AXI_WAQD_LG2_PLUS1_7[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] +
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
   
            AXI_WAQD_LG2_PLUS1_6[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] +
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
  
            AXI_WAQD_LG2_PLUS1_5[AXI_WAQD_LG2_NB-1:0] +
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
  
            AXI_WAQD_LG2_PLUS1_4[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
 
            AXI_WAQD_LG2_PLUS1_3[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
 
            AXI_WAQD_LG2_PLUS1_2[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
 
            AXI_WAQD_LG2_PLUS1_1[AXI_WAQD_LG2_NB-1:0] + AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
 
            AXI_WAQD_LG2_PLUS1_0[AXI_WAQD_LG2_NB-1:0] ,
 
            {AXI_WAQD_LG2_NB{1'b0}}}; 
 
  localparam AXI_RAQD_LG2_NB = 24;
 
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_0 = (`UMCTL2_A_TYPE_0==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_0) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_0);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_1 = (`UMCTL2_A_TYPE_1==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_1) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_1);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_2 = (`UMCTL2_A_TYPE_2==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_2) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_2);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_3 = (`UMCTL2_A_TYPE_3==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_3) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_3);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_4 = (`UMCTL2_A_TYPE_4==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_4) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_4);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_5 = (`UMCTL2_A_TYPE_5==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_5) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_5);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_6 = (`UMCTL2_A_TYPE_6==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_6) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_6);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_7 = (`UMCTL2_A_TYPE_7==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_7) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_7);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_8 = (`UMCTL2_A_TYPE_8==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_8) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_8);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_9 = (`UMCTL2_A_TYPE_9==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_9) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_9);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_10 = (`UMCTL2_A_TYPE_10==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_10) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_10);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_11 = (`UMCTL2_A_TYPE_11==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_11) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_11);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_12 = (`UMCTL2_A_TYPE_12==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_12) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_12);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_13 = (`UMCTL2_A_TYPE_13==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_13) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_13);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_14 = (`UMCTL2_A_TYPE_14==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_14) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_14);
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_15 = (`UMCTL2_A_TYPE_15==2) ? `UMCTL_LOG2(`UMCTL2_AHB_RAQD_15) : `UMCTL_LOG2(`UMCTL2_AXI_RAQD_15); 

  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_0 = AXI_RAQD_LG2_0 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_1 = AXI_RAQD_LG2_1 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_2 = AXI_RAQD_LG2_2 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_3 = AXI_RAQD_LG2_3 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_4 = AXI_RAQD_LG2_4 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_5 = AXI_RAQD_LG2_5 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_6 = AXI_RAQD_LG2_6 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_7 = AXI_RAQD_LG2_7 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_8 = AXI_RAQD_LG2_8 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_9 = AXI_RAQD_LG2_9 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_10 = AXI_RAQD_LG2_10 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_11 = AXI_RAQD_LG2_11 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_12 = AXI_RAQD_LG2_12 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_13 = AXI_RAQD_LG2_13 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_14 = AXI_RAQD_LG2_14 + 1;
  localparam [AXI_RAQD_LG2_NB-1:0] AXI_RAQD_LG2_PLUS1_15 = AXI_RAQD_LG2_15 + 1;
   
  localparam [AXI_RAQD_LG2_NB*ARB_NPOTRS_MAX-1:0] AXI_RAQD_LG2_PRA_TABLE = {
                       AXI_RAQD_LG2_15, AXI_RAQD_LG2_14, AXI_RAQD_LG2_13, AXI_RAQD_LG2_12, 
                       AXI_RAQD_LG2_11, AXI_RAQD_LG2_10, AXI_RAQD_LG2_9,  AXI_RAQD_LG2_8, 
                       AXI_RAQD_LG2_7,  AXI_RAQD_LG2_6,  AXI_RAQD_LG2_5,  AXI_RAQD_LG2_4, 
                       AXI_RAQD_LG2_3,  AXI_RAQD_LG2_2,  AXI_RAQD_LG2_1,  AXI_RAQD_LG2_0}; 
 
  localparam AXI_TOTAL_RAQD_LG2 = (
            AXI_RAQD_LG2_PLUS1_0
 );
 
  localparam [AXI_RAQD_LG2_NB*(ARB_NPOTRS_MAX + 1)-1:0] AXI_RAQD_LG2_BUS_TABLE = { 
            AXI_RAQD_LG2_PLUS1_15[AXI_RAQD_LG2_NB-1:0]+ 
            AXI_RAQD_LG2_PLUS1_14[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_13[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_12[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_11[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_10[AXI_RAQD_LG2_NB-1:0]+
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,

            AXI_RAQD_LG2_PLUS1_14[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_13[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_12[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_11[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_10[AXI_RAQD_LG2_NB-1:0]+
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,

            AXI_RAQD_LG2_PLUS1_13[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_12[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_11[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_10[AXI_RAQD_LG2_NB-1:0]+
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,

            AXI_RAQD_LG2_PLUS1_12[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_11[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_10[AXI_RAQD_LG2_NB-1:0]+
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,

            AXI_RAQD_LG2_PLUS1_11[AXI_RAQD_LG2_NB-1:0]+ AXI_RAQD_LG2_PLUS1_10[AXI_RAQD_LG2_NB-1:0]+
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
  
            AXI_RAQD_LG2_PLUS1_10[AXI_RAQD_LG2_NB-1:0]+
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] , 
 
            AXI_RAQD_LG2_PLUS1_9[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] + 
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
  
            AXI_RAQD_LG2_PLUS1_8[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] +
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
  
            AXI_RAQD_LG2_PLUS1_7[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] +
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0 [AXI_RAQD_LG2_NB-1:0],
   
            AXI_RAQD_LG2_PLUS1_6[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] +
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
  
            AXI_RAQD_LG2_PLUS1_5[AXI_RAQD_LG2_NB-1:0] +
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
  
            AXI_RAQD_LG2_PLUS1_4[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
 
            AXI_RAQD_LG2_PLUS1_3[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
 
            AXI_RAQD_LG2_PLUS1_2[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
 
            AXI_RAQD_LG2_PLUS1_1[AXI_RAQD_LG2_NB-1:0] + AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
 
            AXI_RAQD_LG2_PLUS1_0[AXI_RAQD_LG2_NB-1:0] ,
 
            {AXI_RAQD_LG2_NB{1'b0}}}; 
  

  localparam MAX_AP_ASYNC_NB                        = `MAX_AP_ASYNC_NB;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_0 = `UMCTL2_AP_ASYNC_A_0;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_1 = `UMCTL2_AP_ASYNC_A_1;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_2 = `UMCTL2_AP_ASYNC_A_2;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_3 = `UMCTL2_AP_ASYNC_A_3;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_4 = `UMCTL2_AP_ASYNC_A_4;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_5 = `UMCTL2_AP_ASYNC_A_5;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_6 = `UMCTL2_AP_ASYNC_A_6;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_7 = `UMCTL2_AP_ASYNC_A_7;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_8 = `UMCTL2_AP_ASYNC_A_8;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_9 = `UMCTL2_AP_ASYNC_A_9;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_10 = `UMCTL2_AP_ASYNC_A_10;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_11 = `UMCTL2_AP_ASYNC_A_11;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_12 = `UMCTL2_AP_ASYNC_A_12;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_13 = `UMCTL2_AP_ASYNC_A_13;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_14 = `UMCTL2_AP_ASYNC_A_14;
  localparam [MAX_AP_ASYNC_NB-1:0] AP_ASYNC_TABLE_15 = `UMCTL2_AP_ASYNC_A_15;
  localparam [MAX_AP_ASYNC_NB*ARB_NPOTRS_MAX-1:0] AP_ASYNC_TABLE_TABLE = {
                AP_ASYNC_TABLE_15,
                AP_ASYNC_TABLE_14,
                AP_ASYNC_TABLE_13,
                AP_ASYNC_TABLE_12,
                AP_ASYNC_TABLE_11,
                AP_ASYNC_TABLE_10,
                AP_ASYNC_TABLE_9,
                AP_ASYNC_TABLE_8,
                AP_ASYNC_TABLE_7,
                AP_ASYNC_TABLE_6,
                AP_ASYNC_TABLE_5,
                AP_ASYNC_TABLE_4,
                AP_ASYNC_TABLE_3,
                AP_ASYNC_TABLE_2,
                AP_ASYNC_TABLE_1,
                AP_ASYNC_TABLE_0 };

  localparam A2X_LOWPWR_IF                       = 0;
  localparam A2X_LOWPWR_NOPX_CNT                 = 2;
  localparam A2X_LOWPWR_RST_CNT                  = 2;
  localparam A2X_HCBUF_MODE                      = 1;
  localparam A2X_HCSNF_WLEN                      = 1;
  localparam A2X_HCSNF_RLEN                      = 1;
  localparam A2X_WBUF_MODE                       = 0;
  localparam A2X_RBUF_MODE                       = 0;
  localparam A2X_SNF_AWLEN_DFLT                  = 4;
  localparam A2X_SNF_ARLEN_DFLT                  = 4;
  localparam A2X_HINCR_WBCNT_MAX                 = 3;
  localparam A2X_HINCR_RBCNT_MAX                 = 3;
  localparam A2X_HINCR_HCBCNT                    = 1;
  localparam A2X_SINGLE_RBCNT                    = 0;
  localparam A2X_SINGLE_WBCNT                    = 0;
  localparam A2X_PP_MODE                         = 0;
  localparam A2X_UPSIZE                          = 0;
  localparam A2X_DOWNSIZE                        = 0;
  localparam A2X_LOCKED                          = 0;
  localparam A2X_AHB_WBF_SPLIT                   = 1;
  localparam A2X_RS_RATIO                        = 1;
  localparam A2X_RS_RATIO_LOG2                   = 0;
  localparam A2X_BRESP_ORDER                     = 0;
  localparam A2X_READ_ORDER                      = 0;
  localparam A2X_READ_INTLEV                     = 0;
  localparam A2X_PP_OSAW_LIMIT                   = 3;
  localparam A2X_PP_OSAW_LIMIT_LOG2              = 2;
  localparam A2X_B_OSW_LIMIT                     = 3;
  localparam A2X_B_OSW_LIMIT_LOG2                = 2;
  localparam A2X_SP_OSAW_LIMIT                   = 3;
  localparam A2X_SP_OSAW_LIMIT_LOG2              = 2;

  localparam AHB_HMASTERW                        = 10;
  localparam AHB_HBURSTW                         = 4;
  localparam AHB_HSIZEW                          = 2;
  localparam AHB_HPROTW                          = 3;
  localparam AHB_HRESPW                          = 2; 
  localparam A2X_OSR_LIMIT                       = 3;
  localparam A2X_OSR_LIMIT_LOG2                  = 2;
  localparam A2X_MIN_DEPTH                       = 2;
  localparam A2X_MIN_DEPTH_LOG2                  = `UMCTL_LOG2(A2X_MIN_DEPTH);
  localparam A2X_BOUNDARY_W                      = 12;

  localparam AHB_AWSBW                           = 0;
  localparam A2X_AW                              = `UMCTL2_A_ADDRW;
  localparam A2X_SP_AW                           = `UMCTL2_A_ADDRW;
  localparam A2X_HASBW                           = 1;
  localparam A2X_AWSBW                           = 1;
  localparam A2X_ARSBW                           = 1;
  localparam A2X_WSBW                            = 1;
  localparam A2X_RSBW                            = 1;
  localparam A2X_BSBW                            = 1;
  localparam A2X_CLK_MODE                        = 0;
  localparam A2X_PP_SYNC_DEPTH                   = 2;
  localparam A2X_SP_SYNC_DEPTH                   = 2;
  localparam A2X_SP_ENDIAN                       = 0;
  localparam A2X_RS_AW_TMO                       = 0;
  localparam A2X_RS_AR_TMO                       = 0;
  localparam A2X_RS_W_TMO                        = 0;
  localparam A2X_RS_B_TMO                        = 0;
  localparam A2X_RS_R_TMO                        = 0;

  localparam MAX_A2X_NUM_AHBM_NB                            = `MAX_A2X_NUM_AHBM_NB;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_0 = `UMCTL2_AHB_NUM_MST_0+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_1 = `UMCTL2_AHB_NUM_MST_1+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_2 = `UMCTL2_AHB_NUM_MST_2+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_3 = `UMCTL2_AHB_NUM_MST_3+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_4 = `UMCTL2_AHB_NUM_MST_4+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_5 = `UMCTL2_AHB_NUM_MST_5+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_6 = `UMCTL2_AHB_NUM_MST_6+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_7 = `UMCTL2_AHB_NUM_MST_7+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_8 = `UMCTL2_AHB_NUM_MST_8+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_9 = `UMCTL2_AHB_NUM_MST_9+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_10 = `UMCTL2_AHB_NUM_MST_10+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_11 = `UMCTL2_AHB_NUM_MST_11+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_12 = `UMCTL2_AHB_NUM_MST_12+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_13 = `UMCTL2_AHB_NUM_MST_13+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_14 = `UMCTL2_AHB_NUM_MST_14+1;
  localparam [MAX_A2X_NUM_AHBM_NB-1:0] A2X_NUM_AHBM_TABLE_15 = `UMCTL2_AHB_NUM_MST_15+1;
  localparam [MAX_A2X_NUM_AHBM_NB*ARB_NPOTRS_MAX-1:0] A2X_NUM_AHBM_TABLE = {
                A2X_NUM_AHBM_TABLE_15,
                A2X_NUM_AHBM_TABLE_14,
                A2X_NUM_AHBM_TABLE_13,
                A2X_NUM_AHBM_TABLE_12,
                A2X_NUM_AHBM_TABLE_11,
                A2X_NUM_AHBM_TABLE_10,
                A2X_NUM_AHBM_TABLE_9,
                A2X_NUM_AHBM_TABLE_8,
                A2X_NUM_AHBM_TABLE_7,
                A2X_NUM_AHBM_TABLE_6,
                A2X_NUM_AHBM_TABLE_5,
                A2X_NUM_AHBM_TABLE_4,
                A2X_NUM_AHBM_TABLE_3,
                A2X_NUM_AHBM_TABLE_2,
                A2X_NUM_AHBM_TABLE_1,
                A2X_NUM_AHBM_TABLE_0 };


  localparam MAX_A2X_BRESP_MODE_NB                              = `MAX_A2X_BRESP_MODE_NB;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_0 = `UMCTL2_AHB_WRITE_RESP_MODE_0;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_1 = `UMCTL2_AHB_WRITE_RESP_MODE_1;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_2 = `UMCTL2_AHB_WRITE_RESP_MODE_2;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_3 = `UMCTL2_AHB_WRITE_RESP_MODE_3;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_4 = `UMCTL2_AHB_WRITE_RESP_MODE_4;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_5 = `UMCTL2_AHB_WRITE_RESP_MODE_5;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_6 = `UMCTL2_AHB_WRITE_RESP_MODE_6;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_7 = `UMCTL2_AHB_WRITE_RESP_MODE_7;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_8 = `UMCTL2_AHB_WRITE_RESP_MODE_8;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_9 = `UMCTL2_AHB_WRITE_RESP_MODE_9;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_10 = `UMCTL2_AHB_WRITE_RESP_MODE_10;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_11 = `UMCTL2_AHB_WRITE_RESP_MODE_11;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_12 = `UMCTL2_AHB_WRITE_RESP_MODE_12;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_13 = `UMCTL2_AHB_WRITE_RESP_MODE_13;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_14 = `UMCTL2_AHB_WRITE_RESP_MODE_14;
  localparam [MAX_A2X_BRESP_MODE_NB-1:0] A2X_BRESP_MODE_TABLE_15 = `UMCTL2_AHB_WRITE_RESP_MODE_15;
  localparam [MAX_A2X_BRESP_MODE_NB*ARB_NPOTRS_MAX-1:0] A2X_BRESP_MODE_TABLE = {
                A2X_BRESP_MODE_TABLE_15,
                A2X_BRESP_MODE_TABLE_14,
                A2X_BRESP_MODE_TABLE_13,
                A2X_BRESP_MODE_TABLE_12,
                A2X_BRESP_MODE_TABLE_11,
                A2X_BRESP_MODE_TABLE_10,
                A2X_BRESP_MODE_TABLE_9,
                A2X_BRESP_MODE_TABLE_8,
                A2X_BRESP_MODE_TABLE_7,
                A2X_BRESP_MODE_TABLE_6,
                A2X_BRESP_MODE_TABLE_5,
                A2X_BRESP_MODE_TABLE_4,
                A2X_BRESP_MODE_TABLE_3,
                A2X_BRESP_MODE_TABLE_2,
                A2X_BRESP_MODE_TABLE_1,
                A2X_BRESP_MODE_TABLE_0 };


  localparam MAX_A2X_AHB_LITE_MODE_NB            = `MAX_A2X_AHB_LITE_MODE_NB;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_0 = `UMCTL2_AHB_LITE_MODE_0;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_1 = `UMCTL2_AHB_LITE_MODE_1;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_2 = `UMCTL2_AHB_LITE_MODE_2;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_3 = `UMCTL2_AHB_LITE_MODE_3;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_4 = `UMCTL2_AHB_LITE_MODE_4;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_5 = `UMCTL2_AHB_LITE_MODE_5;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_6 = `UMCTL2_AHB_LITE_MODE_6;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_7 = `UMCTL2_AHB_LITE_MODE_7;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_8 = `UMCTL2_AHB_LITE_MODE_8;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_9 = `UMCTL2_AHB_LITE_MODE_9;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_10 = `UMCTL2_AHB_LITE_MODE_10;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_11 = `UMCTL2_AHB_LITE_MODE_11;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_12 = `UMCTL2_AHB_LITE_MODE_12;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_13 = `UMCTL2_AHB_LITE_MODE_13;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_14 = `UMCTL2_AHB_LITE_MODE_14;
  localparam [MAX_A2X_AHB_LITE_MODE_NB-1:0] A2X_AHB_LITE_MODE_TABLE_15 = `UMCTL2_AHB_LITE_MODE_15;
  localparam [MAX_A2X_AHB_LITE_MODE_NB*ARB_NPOTRS_MAX-1:0] A2X_AHB_LITE_MODE_TABLE = {
                A2X_AHB_LITE_MODE_TABLE_15,
                A2X_AHB_LITE_MODE_TABLE_14,
                A2X_AHB_LITE_MODE_TABLE_13,
                A2X_AHB_LITE_MODE_TABLE_12,
                A2X_AHB_LITE_MODE_TABLE_11,
                A2X_AHB_LITE_MODE_TABLE_10,
                A2X_AHB_LITE_MODE_TABLE_9,
                A2X_AHB_LITE_MODE_TABLE_8,
                A2X_AHB_LITE_MODE_TABLE_7,
                A2X_AHB_LITE_MODE_TABLE_6,
                A2X_AHB_LITE_MODE_TABLE_5,
                A2X_AHB_LITE_MODE_TABLE_4,
                A2X_AHB_LITE_MODE_TABLE_3,
                A2X_AHB_LITE_MODE_TABLE_2,
                A2X_AHB_LITE_MODE_TABLE_1,
                A2X_AHB_LITE_MODE_TABLE_0 };


  localparam MAX_A2X_SPLIT_MODE_NB                              = `MAX_A2X_SPLIT_MODE_NB;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_0 = `UMCTL2_AHB_SPLIT_MODE_0;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_1 = `UMCTL2_AHB_SPLIT_MODE_1;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_2 = `UMCTL2_AHB_SPLIT_MODE_2;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_3 = `UMCTL2_AHB_SPLIT_MODE_3;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_4 = `UMCTL2_AHB_SPLIT_MODE_4;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_5 = `UMCTL2_AHB_SPLIT_MODE_5;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_6 = `UMCTL2_AHB_SPLIT_MODE_6;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_7 = `UMCTL2_AHB_SPLIT_MODE_7;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_8 = `UMCTL2_AHB_SPLIT_MODE_8;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_9 = `UMCTL2_AHB_SPLIT_MODE_9;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_10 = `UMCTL2_AHB_SPLIT_MODE_10;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_11 = `UMCTL2_AHB_SPLIT_MODE_11;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_12 = `UMCTL2_AHB_SPLIT_MODE_12;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_13 = `UMCTL2_AHB_SPLIT_MODE_13;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_14 = `UMCTL2_AHB_SPLIT_MODE_14;
  localparam [MAX_A2X_SPLIT_MODE_NB-1:0] A2X_SPLIT_MODE_TABLE_15 = `UMCTL2_AHB_SPLIT_MODE_15;
  localparam [MAX_A2X_SPLIT_MODE_NB*ARB_NPOTRS_MAX-1:0] A2X_SPLIT_MODE_TABLE = {
                A2X_SPLIT_MODE_TABLE_15,
                A2X_SPLIT_MODE_TABLE_14,
                A2X_SPLIT_MODE_TABLE_13,
                A2X_SPLIT_MODE_TABLE_12,
                A2X_SPLIT_MODE_TABLE_11,
                A2X_SPLIT_MODE_TABLE_10,
                A2X_SPLIT_MODE_TABLE_9,
                A2X_SPLIT_MODE_TABLE_8,
                A2X_SPLIT_MODE_TABLE_7,
                A2X_SPLIT_MODE_TABLE_6,
                A2X_SPLIT_MODE_TABLE_5,
                A2X_SPLIT_MODE_TABLE_4,
                A2X_SPLIT_MODE_TABLE_3,
                A2X_SPLIT_MODE_TABLE_2,
                A2X_SPLIT_MODE_TABLE_1,
                A2X_SPLIT_MODE_TABLE_0 };


  localparam MAX_A2X_HREADY_LOW_PERIOD_NB                                     = `MAX_A2X_HREADY_LOW_PERIOD_NB;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_0 = `UMCTL2_AHB_HREADY_LOW_PERIOD_0;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_1 = `UMCTL2_AHB_HREADY_LOW_PERIOD_1;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_2 = `UMCTL2_AHB_HREADY_LOW_PERIOD_2;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_3 = `UMCTL2_AHB_HREADY_LOW_PERIOD_3;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_4 = `UMCTL2_AHB_HREADY_LOW_PERIOD_4;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_5 = `UMCTL2_AHB_HREADY_LOW_PERIOD_5;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_6 = `UMCTL2_AHB_HREADY_LOW_PERIOD_6;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_7 = `UMCTL2_AHB_HREADY_LOW_PERIOD_7;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_8 = `UMCTL2_AHB_HREADY_LOW_PERIOD_8;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_9 = `UMCTL2_AHB_HREADY_LOW_PERIOD_9;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_10 = `UMCTL2_AHB_HREADY_LOW_PERIOD_10;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_11 = `UMCTL2_AHB_HREADY_LOW_PERIOD_11;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_12 = `UMCTL2_AHB_HREADY_LOW_PERIOD_12;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_13 = `UMCTL2_AHB_HREADY_LOW_PERIOD_13;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_14 = `UMCTL2_AHB_HREADY_LOW_PERIOD_14;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB-1:0] A2X_HREADY_LOW_PERIOD_TABLE_15 = `UMCTL2_AHB_HREADY_LOW_PERIOD_15;
  localparam [MAX_A2X_HREADY_LOW_PERIOD_NB*ARB_NPOTRS_MAX-1:0] A2X_HREADY_LOW_PERIOD_TABLE = {
                A2X_HREADY_LOW_PERIOD_TABLE_15,
                A2X_HREADY_LOW_PERIOD_TABLE_14,
                A2X_HREADY_LOW_PERIOD_TABLE_13,
                A2X_HREADY_LOW_PERIOD_TABLE_12,
                A2X_HREADY_LOW_PERIOD_TABLE_11,
                A2X_HREADY_LOW_PERIOD_TABLE_10,
                A2X_HREADY_LOW_PERIOD_TABLE_9,
                A2X_HREADY_LOW_PERIOD_TABLE_8,
                A2X_HREADY_LOW_PERIOD_TABLE_7,
                A2X_HREADY_LOW_PERIOD_TABLE_6,
                A2X_HREADY_LOW_PERIOD_TABLE_5,
                A2X_HREADY_LOW_PERIOD_TABLE_4,
                A2X_HREADY_LOW_PERIOD_TABLE_3,
                A2X_HREADY_LOW_PERIOD_TABLE_2,
                A2X_HREADY_LOW_PERIOD_TABLE_1,
                A2X_HREADY_LOW_PERIOD_TABLE_0 };


  localparam MAX_A2X_NUM_UWID_NB                            = `MAX_AHB_NUM_MST_NB;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_0 = `UMCTL2_AHB_NUM_MST_0;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_1 = `UMCTL2_AHB_NUM_MST_1;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_2 = `UMCTL2_AHB_NUM_MST_2;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_3 = `UMCTL2_AHB_NUM_MST_3;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_4 = `UMCTL2_AHB_NUM_MST_4;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_5 = `UMCTL2_AHB_NUM_MST_5;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_6 = `UMCTL2_AHB_NUM_MST_6;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_7 = `UMCTL2_AHB_NUM_MST_7;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_8 = `UMCTL2_AHB_NUM_MST_8;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_9 = `UMCTL2_AHB_NUM_MST_9;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_10 = `UMCTL2_AHB_NUM_MST_10;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_11 = `UMCTL2_AHB_NUM_MST_11;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_12 = `UMCTL2_AHB_NUM_MST_12;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_13 = `UMCTL2_AHB_NUM_MST_13;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_14 = `UMCTL2_AHB_NUM_MST_14;
  localparam [MAX_A2X_NUM_UWID_NB-1:0] A2X_NUM_UWID_TABLE_15 = `UMCTL2_AHB_NUM_MST_15;
  localparam [MAX_A2X_NUM_UWID_NB*ARB_NPOTRS_MAX-1:0] A2X_NUM_UWID_TABLE = {
                A2X_NUM_UWID_TABLE_15,
                A2X_NUM_UWID_TABLE_14,
                A2X_NUM_UWID_TABLE_13,
                A2X_NUM_UWID_TABLE_12,
                A2X_NUM_UWID_TABLE_11,
                A2X_NUM_UWID_TABLE_10,
                A2X_NUM_UWID_TABLE_9,
                A2X_NUM_UWID_TABLE_8,
                A2X_NUM_UWID_TABLE_7,
                A2X_NUM_UWID_TABLE_6,
                A2X_NUM_UWID_TABLE_5,
                A2X_NUM_UWID_TABLE_4,
                A2X_NUM_UWID_TABLE_3,
                A2X_NUM_UWID_TABLE_2,
                A2X_NUM_UWID_TABLE_1,
                A2X_NUM_UWID_TABLE_0 };


  localparam MAX_A2X_NUM_URID_NB                 = `MAX_AHB_NUM_MST_NB;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_0 = `UMCTL2_AHB_NUM_MST_0;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_1 = `UMCTL2_AHB_NUM_MST_1;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_2 = `UMCTL2_AHB_NUM_MST_2;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_3 = `UMCTL2_AHB_NUM_MST_3;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_4 = `UMCTL2_AHB_NUM_MST_4;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_5 = `UMCTL2_AHB_NUM_MST_5;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_6 = `UMCTL2_AHB_NUM_MST_6;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_7 = `UMCTL2_AHB_NUM_MST_7;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_8 = `UMCTL2_AHB_NUM_MST_8;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_9 = `UMCTL2_AHB_NUM_MST_9;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_10 = `UMCTL2_AHB_NUM_MST_10;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_11 = `UMCTL2_AHB_NUM_MST_11;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_12 = `UMCTL2_AHB_NUM_MST_12;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_13 = `UMCTL2_AHB_NUM_MST_13;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_14 = `UMCTL2_AHB_NUM_MST_14;
  localparam [MAX_A2X_NUM_URID_NB-1:0] A2X_NUM_URID_TABLE_15 = `UMCTL2_AHB_NUM_MST_15;
  localparam [MAX_A2X_NUM_URID_NB*ARB_NPOTRS_MAX-1:0] A2X_NUM_URID_TABLE = {
                A2X_NUM_URID_TABLE_15,
                A2X_NUM_URID_TABLE_14,
                A2X_NUM_URID_TABLE_13,
                A2X_NUM_URID_TABLE_12,
                A2X_NUM_URID_TABLE_11,
                A2X_NUM_URID_TABLE_10,
                A2X_NUM_URID_TABLE_9,
                A2X_NUM_URID_TABLE_8,
                A2X_NUM_URID_TABLE_7,
                A2X_NUM_URID_TABLE_6,
                A2X_NUM_URID_TABLE_5,
                A2X_NUM_URID_TABLE_4,
                A2X_NUM_URID_TABLE_3,
                A2X_NUM_URID_TABLE_2,
                A2X_NUM_URID_TABLE_1,
                A2X_NUM_URID_TABLE_0 };

  localparam MAX_A2X_PP_MAX_SIZE_NB                               = `UMCTL_LOG2(`MAX_PORT_NBYTES);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_0 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_0);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_1 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_1);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_2 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_2);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_3 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_3);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_4 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_4);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_5 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_5);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_6 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_6);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_7 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_7);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_8 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_8);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_9 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_9);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_10 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_10);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_11 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_11);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_12 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_12);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_13 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_13);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_14 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_14);
  localparam [MAX_A2X_PP_MAX_SIZE_NB-1:0] A2X_PP_MAX_SIZE_TABLE_15 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_15);
  localparam [MAX_A2X_PP_MAX_SIZE_NB*ARB_NPOTRS_MAX-1:0] A2X_PP_MAX_SIZE_TABLE = {
                A2X_PP_MAX_SIZE_TABLE_15,
                A2X_PP_MAX_SIZE_TABLE_14,
                A2X_PP_MAX_SIZE_TABLE_13,
                A2X_PP_MAX_SIZE_TABLE_12,
                A2X_PP_MAX_SIZE_TABLE_11,
                A2X_PP_MAX_SIZE_TABLE_10,
                A2X_PP_MAX_SIZE_TABLE_9,
                A2X_PP_MAX_SIZE_TABLE_8,
                A2X_PP_MAX_SIZE_TABLE_7,
                A2X_PP_MAX_SIZE_TABLE_6,
                A2X_PP_MAX_SIZE_TABLE_5,
                A2X_PP_MAX_SIZE_TABLE_4,
                A2X_PP_MAX_SIZE_TABLE_3,
                A2X_PP_MAX_SIZE_TABLE_2,
                A2X_PP_MAX_SIZE_TABLE_1,
                A2X_PP_MAX_SIZE_TABLE_0 };

  localparam MAX_A2X_PP_NUM_BYTES_LOG2_NB                                          = `UMCTL_LOG2(`MAX_PORT_NBYTES);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_0 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_0);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_1 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_1);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_2 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_2);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_3 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_3);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_4 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_4);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_5 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_5);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_6 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_6);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_7 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_7);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_8 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_8);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_9 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_9);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_10 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_10);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_11 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_11);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_12 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_12);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_13 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_13);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_14 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_14);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE_15 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_15);
  localparam [MAX_A2X_PP_NUM_BYTES_LOG2_NB*ARB_NPOTRS_MAX-1:0] A2X_PP_NUM_BYTES_LOG2_TABLE = {
                A2X_PP_NUM_BYTES_LOG2_TABLE_15,
                A2X_PP_NUM_BYTES_LOG2_TABLE_14,
                A2X_PP_NUM_BYTES_LOG2_TABLE_13,
                A2X_PP_NUM_BYTES_LOG2_TABLE_12,
                A2X_PP_NUM_BYTES_LOG2_TABLE_11,
                A2X_PP_NUM_BYTES_LOG2_TABLE_10,
                A2X_PP_NUM_BYTES_LOG2_TABLE_9,
                A2X_PP_NUM_BYTES_LOG2_TABLE_8,
                A2X_PP_NUM_BYTES_LOG2_TABLE_7,
                A2X_PP_NUM_BYTES_LOG2_TABLE_6,
                A2X_PP_NUM_BYTES_LOG2_TABLE_5,
                A2X_PP_NUM_BYTES_LOG2_TABLE_4,
                A2X_PP_NUM_BYTES_LOG2_TABLE_3,
                A2X_PP_NUM_BYTES_LOG2_TABLE_2,
                A2X_PP_NUM_BYTES_LOG2_TABLE_1,
                A2X_PP_NUM_BYTES_LOG2_TABLE_0 };


  localparam MAX_A2X_SP_DW_NB                    = `UMCTL_LOG2(`UMCTL2_MAX_AXI_DATAW)+1;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_0 = `UMCTL2_PORT_DW_0;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_1 = `UMCTL2_PORT_DW_1;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_2 = `UMCTL2_PORT_DW_2;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_3 = `UMCTL2_PORT_DW_3;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_4 = `UMCTL2_PORT_DW_4;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_5 = `UMCTL2_PORT_DW_5;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_6 = `UMCTL2_PORT_DW_6;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_7 = `UMCTL2_PORT_DW_7;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_8 = `UMCTL2_PORT_DW_8;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_9 = `UMCTL2_PORT_DW_9;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_10 = `UMCTL2_PORT_DW_10;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_11 = `UMCTL2_PORT_DW_11;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_12 = `UMCTL2_PORT_DW_12;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_13 = `UMCTL2_PORT_DW_13;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_14 = `UMCTL2_PORT_DW_14;
  localparam [MAX_A2X_SP_DW_NB-1:0] A2X_SP_DW_TABLE_15 = `UMCTL2_PORT_DW_15;
  localparam [MAX_A2X_SP_DW_NB*ARB_NPOTRS_MAX-1:0] A2X_SP_DW_TABLE = {
                A2X_SP_DW_TABLE_15,
                A2X_SP_DW_TABLE_14,
                A2X_SP_DW_TABLE_13,
                A2X_SP_DW_TABLE_12,
                A2X_SP_DW_TABLE_11,
                A2X_SP_DW_TABLE_10,
                A2X_SP_DW_TABLE_9,
                A2X_SP_DW_TABLE_8,
                A2X_SP_DW_TABLE_7,
                A2X_SP_DW_TABLE_6,
                A2X_SP_DW_TABLE_5,
                A2X_SP_DW_TABLE_4,
                A2X_SP_DW_TABLE_3,
                A2X_SP_DW_TABLE_2,
                A2X_SP_DW_TABLE_1,
                A2X_SP_DW_TABLE_0 };


  localparam MAX_A2X_SP_MAX_SIZE_NB                                    = `UMCTL_LOG2(`MAX_PORT_NBYTES);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_0 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_0);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_1 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_1);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_2 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_2);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_3 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_3);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_4 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_4);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_5 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_5);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_6 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_6);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_7 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_7);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_8 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_8);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_9 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_9);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_10 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_10);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_11 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_11);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_12 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_12);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_13 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_13);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_14 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_14);
  localparam [MAX_A2X_SP_MAX_SIZE_NB-1:0] A2X_SP_MAX_SIZE_TABLE_15 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_15);
  localparam [MAX_A2X_SP_MAX_SIZE_NB*ARB_NPOTRS_MAX-1:0]A2X_SP_MAX_SIZE_TABLE = {
                A2X_SP_MAX_SIZE_TABLE_15,
                A2X_SP_MAX_SIZE_TABLE_14,
                A2X_SP_MAX_SIZE_TABLE_13,
                A2X_SP_MAX_SIZE_TABLE_12,
                A2X_SP_MAX_SIZE_TABLE_11,
                A2X_SP_MAX_SIZE_TABLE_10,
                A2X_SP_MAX_SIZE_TABLE_9,
                A2X_SP_MAX_SIZE_TABLE_8,
                A2X_SP_MAX_SIZE_TABLE_7,
                A2X_SP_MAX_SIZE_TABLE_6,
                A2X_SP_MAX_SIZE_TABLE_5,
                A2X_SP_MAX_SIZE_TABLE_4,
                A2X_SP_MAX_SIZE_TABLE_3,
                A2X_SP_MAX_SIZE_TABLE_2,
                A2X_SP_MAX_SIZE_TABLE_1,
                A2X_SP_MAX_SIZE_TABLE_0 };

  localparam MAX_A2X_SP_NUM_BYTES_LOG2_NB                                     = `UMCTL_LOG2(`MAX_PORT_NBYTES)+1;  
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_0 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_0);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_1 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_1);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_2 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_2);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_3 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_3);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_4 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_4);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_5 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_5);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_6 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_6);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_7 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_7);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_8 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_8);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_9 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_9);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_10 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_10);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_11 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_11);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_12 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_12);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_13 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_13);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_14 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_14);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE_15 = `UMCTL_LOG2(`UMCTL2_PORT_NBYTES_15);
  localparam [MAX_A2X_SP_NUM_BYTES_LOG2_NB*ARB_NPOTRS_MAX-1:0] A2X_SP_NUM_BYTES_LOG2_TABLE = {
                A2X_SP_NUM_BYTES_LOG2_TABLE_15,
                A2X_SP_NUM_BYTES_LOG2_TABLE_14,
                A2X_SP_NUM_BYTES_LOG2_TABLE_13,
                A2X_SP_NUM_BYTES_LOG2_TABLE_12,
                A2X_SP_NUM_BYTES_LOG2_TABLE_11,
                A2X_SP_NUM_BYTES_LOG2_TABLE_10,
                A2X_SP_NUM_BYTES_LOG2_TABLE_9,
                A2X_SP_NUM_BYTES_LOG2_TABLE_8,
                A2X_SP_NUM_BYTES_LOG2_TABLE_7,
                A2X_SP_NUM_BYTES_LOG2_TABLE_6,
                A2X_SP_NUM_BYTES_LOG2_TABLE_5,
                A2X_SP_NUM_BYTES_LOG2_TABLE_4,
                A2X_SP_NUM_BYTES_LOG2_TABLE_3,
                A2X_SP_NUM_BYTES_LOG2_TABLE_2,
                A2X_SP_NUM_BYTES_LOG2_TABLE_1,
                A2X_SP_NUM_BYTES_LOG2_TABLE_0 };

  localparam HIF_CREDIT_BITS                     = `MEMC_HIF_CREDIT_BITS;
  localparam CRDT_CNT_WIDTH                      = 7;  

  localparam ADDR_ERR_EN                         = `MEMC_ADDR_ERR;

  localparam FREQ_RATIO                          = `MEMC_FREQ_RATIO;
  localparam A_PORT_NUM_SBR                      = INT_NPORTS_DATA-1;
  localparam BRDWR                               = 4;
  localparam MEMC_HIF_ADDR_WIDTH_MAX             = `MEMC_HIF_ADDR_WIDTH_MAX;
  localparam CMD_TYPE_BITS                       = 2;

  localparam EXA_RESP_FIFO_DEPTH                 = (`MEMC_IH_TE_PIPELINE_EN==1) ? 4 : 2;

  localparam LPDDR3_EN                           = `MEMC_LPDDR3_EN;
  localparam LPDDR4_EN                           = `MEMC_LPDDR4_EN;

  localparam MAX_RAQ_TABLE_TABLE_NB              = `MAX_RAQ_TABLE_TABLE_NB;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_0 = `UMCTL2_RAQ_TABLE_0;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_1 = `UMCTL2_RAQ_TABLE_1;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_2 = `UMCTL2_RAQ_TABLE_2;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_3 = `UMCTL2_RAQ_TABLE_3;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_4 = `UMCTL2_RAQ_TABLE_4;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_5 = `UMCTL2_RAQ_TABLE_5;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_6 = `UMCTL2_RAQ_TABLE_6;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_7 = `UMCTL2_RAQ_TABLE_7;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_8 = `UMCTL2_RAQ_TABLE_8;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_9 = `UMCTL2_RAQ_TABLE_9;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_10 = `UMCTL2_RAQ_TABLE_10;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_11 = `UMCTL2_RAQ_TABLE_11;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_12 = `UMCTL2_RAQ_TABLE_12;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_13 = `UMCTL2_RAQ_TABLE_13;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_14 = `UMCTL2_RAQ_TABLE_14;
  localparam [MAX_RAQ_TABLE_TABLE_NB-1:0] RAQ_TABLE_TABLE_15 = `UMCTL2_RAQ_TABLE_15;
  localparam RAQ_TABLE_TABLE = {
                RAQ_TABLE_TABLE_15[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_14[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_13[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_12[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_11[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_10[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_9[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_8[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_7[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_6[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_5[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_4[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_3[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_2[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_1[MAX_RAQ_TABLE_TABLE_NB-1:0],
                RAQ_TABLE_TABLE_0[MAX_RAQ_TABLE_TABLE_NB-1:0] };

  localparam MEMC_NUM_RANKS                      = `MEMC_NUM_RANKS;

//------------------------------------------------
// wires and concatenation/de-concatenation logic
//------------------------------------------------

  wire                                reg_ddrc_lpddr4_w;
  wire                                reg_ddrc_lpddr5_w;
  wire                                reg_ddrc_dm_en_w;
  wire [2:0]                          reg_ddrc_ecc_mode_w;
  wire                                reg_arb_address_parity_mode;
  wire                                reg_ddrc_ecc_region_map_w;
  wire                                reg_ddrc_ecc_region_map_granu_w;
  wire                                reg_ddrc_ecc_region_map_other_w;
  wire                                ddrc_xpi_port_disable_req_w;
  wire                                ddrc_xpi_clock_required_w;

  wire [15:0]                         aclk_vector;
  wire [15:0]                         aresetn_vector;
  wire [15:0]                         sync_aresetn_vector;
  wire [15:0]                         csysreq_xpi_vector;
  wire [A_NPORTS-1:0]                 csysack_xpi_vector;
  wire [1*16-1:0]                     csysack_xpi_vector_ext;
  wire [A_NPORTS-1:0]                 cactive_xpi_vector;
  wire [1*16-1:0]                     cactive_xpi_vector_ext;

  wire                                aclk_0_w;
  wire                                aresetn_0_w;
  wire                                sync_aresetn_0_w;
  wire                                csysreq_xpi_0_w;
  wire                                csysack_xpi_0_w;
  wire                                cactive_xpi_0_w;

  wire                                aclk_1_w;
  wire                                aresetn_1_w;
  wire                                sync_aresetn_1_w;
  wire                                csysreq_xpi_1_w;
  wire                                csysack_xpi_1_w;
  wire                                cactive_xpi_1_w;

  wire                                aclk_2_w;
  wire                                aresetn_2_w;
  wire                                sync_aresetn_2_w;
  wire                                csysreq_xpi_2_w;
  wire                                csysack_xpi_2_w;
  wire                                cactive_xpi_2_w;

  wire                                aclk_3_w;
  wire                                aresetn_3_w;
  wire                                sync_aresetn_3_w;
  wire                                csysreq_xpi_3_w;
  wire                                csysack_xpi_3_w;
  wire                                cactive_xpi_3_w;

  wire                                aclk_4_w;
  wire                                aresetn_4_w;
  wire                                sync_aresetn_4_w;
  wire                                csysreq_xpi_4_w;
  wire                                csysack_xpi_4_w;
  wire                                cactive_xpi_4_w;

  wire                                aclk_5_w;
  wire                                aresetn_5_w;
  wire                                sync_aresetn_5_w;
  wire                                csysreq_xpi_5_w;
  wire                                csysack_xpi_5_w;
  wire                                cactive_xpi_5_w;

  wire                                aclk_6_w;
  wire                                aresetn_6_w;
  wire                                sync_aresetn_6_w;
  wire                                csysreq_xpi_6_w;
  wire                                csysack_xpi_6_w;
  wire                                cactive_xpi_6_w;

  wire                                aclk_7_w;
  wire                                aresetn_7_w;
  wire                                sync_aresetn_7_w;
  wire                                csysreq_xpi_7_w;
  wire                                csysack_xpi_7_w;
  wire                                cactive_xpi_7_w;

  wire                                aclk_8_w;
  wire                                aresetn_8_w;
  wire                                sync_aresetn_8_w;
  wire                                csysreq_xpi_8_w;
  wire                                csysack_xpi_8_w;
  wire                                cactive_xpi_8_w;

  wire                                aclk_9_w;
  wire                                aresetn_9_w;
  wire                                sync_aresetn_9_w;
  wire                                csysreq_xpi_9_w;
  wire                                csysack_xpi_9_w;
  wire                                cactive_xpi_9_w;

  wire                                aclk_10_w;
  wire                                aresetn_10_w;
  wire                                sync_aresetn_10_w;
  wire                                csysreq_xpi_10_w;
  wire                                csysack_xpi_10_w;
  wire                                cactive_xpi_10_w;

  wire                                aclk_11_w;
  wire                                aresetn_11_w;
  wire                                sync_aresetn_11_w;
  wire                                csysreq_xpi_11_w;
  wire                                csysack_xpi_11_w;
  wire                                cactive_xpi_11_w;

  wire                                aclk_12_w;
  wire                                aresetn_12_w;
  wire                                sync_aresetn_12_w;
  wire                                csysreq_xpi_12_w;
  wire                                csysack_xpi_12_w;
  wire                                cactive_xpi_12_w;

  wire                                aclk_13_w;
  wire                                aresetn_13_w;
  wire                                sync_aresetn_13_w;
  wire                                csysreq_xpi_13_w;
  wire                                csysack_xpi_13_w;
  wire                                cactive_xpi_13_w;

  wire                                aclk_14_w;
  wire                                aresetn_14_w;
  wire                                sync_aresetn_14_w;
  wire                                csysreq_xpi_14_w;
  wire                                csysack_xpi_14_w;
  wire                                cactive_xpi_14_w;

  wire                                aclk_15_w;
  wire                                aresetn_15_w;
  wire                                sync_aresetn_15_w;
  wire                                csysreq_xpi_15_w;
  wire                                csysack_xpi_15_w;
  wire                                cactive_xpi_15_w;


  wire                                reg_ddrc_burstchop_w;
  wire                                reg_ddrc_wr_crc_enable_w;
  wire                                reg_ddrc_col_addr_shift_w;
  wire [15:0]                         reg_arb_occap_arb_cmp_poison_seq_vector;
  wire [15:0]                         reg_arb_occap_arb_cmp_poison_parallel_vector;
  wire [15:0]                         reg_arb_occap_arb_cmp_poison_err_inj_vector;
  wire [15:0]                         reg_arb_occap_arb_raq_poison_en_vector;
  wire [15:0]                         oc_parity_en_aclk_vector;
  wire [15:0]                         oc_parity_type_aclk_vector;
  wire [15:0]                         par_addr_slverr_en_aclk_vector;
  wire [15:0]                         par_rdata_slverr_en_vector;
  wire [15:0]                         rd_poison_en_vector;
  wire [15:0]                         wr_poison_en_vector;
  wire [15:0]                         par_wdata_err_intr_clr_vector;
  wire [15:0]                         par_rdata_err_intr_clr_vector;

  //ocecc input vectors
  wire [15:0]                         ocecc_en_aclk_vector;
  wire [15:0]                         ocecc_poison_egen_mr_rd_0_vector;
  wire [OCECC_MR_BNUM_WIDTH*16-1:0]   ocecc_poison_egen_mr_rd_0_byte_num_vector;
  wire [15:0]                         ocecc_poison_egen_xpi_rd_out_vector;
  wire [15:0]                         ocecc_poison_single_vector;
  wire [15:0]                         ocecc_wdata_slverr_en_vector;
  wire [15:0]                         ocecc_rdata_slverr_en_vector;

  wire [AXI_IDW*16-1:0]               awid_vector;
  wire [AXI_ADDRW*16-1:0]             awaddr_vector;
  wire [AXI_LENW*16-1:0]              awlen_vector;
  wire [AXI_SIZEW*16-1:0]             awsize_vector;
  wire [AXI_BURSTW*16-1:0]            awburst_vector;
  wire [AXI_TOTAL_LOCKW-1:0]          awlock_vector;
  wire [AXI_CACHEW*16-1:0]            awcache_vector;
  wire [AXI_PROTW*16-1:0]             awprot_vector;
  wire [AXI_USERW*16-1:0]             awuser_vector;
  wire [AXI_QOSW*16-1:0]              awqos_vector;
  wire [15:0]                         awurgent_vector;
  wire [15:0]                         awvalid_vector;
  wire [15:0]                         awpoison_vector;
  wire [15:0]                         awautopre_vector;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN*16-1:0] awparity_vector;
  wire [A_NPORTS-1:0]                 awready_vector;
  wire [1*16-1:0]                     awready_vector_ext;

  wire [AXI_IDW*16-1:0]               wid_vector;
  wire [AXI_TOTAL_DW-1:0]             wdata_vector;
  wire [AXI_TOTAL_STRBW-1:0]          wparity_vector;
  wire [AXI_TOTAL_STRBW-1:0]          wstrb_vector;
  wire [15:0]                         wlast_vector;
  wire [15:0]                         wvalid_vector;
  wire [A_NPORTS-1:0]                 wready_vector;
  wire [1*16-1:0]                     wready_vector_ext;
  wire [AXI_USERW*16-1:0]             wuser_vector;

  wire [AXI_IDW*A_NPORTS-1:0]         bid_vector;
  wire [AXI_IDW*16-1:0]               bid_vector_ext;
  wire [AXI_RESPW*A_NPORTS-1:0]       bresp_vector;
  wire [AXI_RESPW*16-1:0]             bresp_vector_ext;
  wire [AXI_USERW*A_NPORTS-1:0]       buser_vector;
  wire [AXI_USERW*16-1:0]             buser_vector_ext;
  wire [A_NPORTS-1:0]                 bvalid_vector;
  wire [1*16-1:0]                     bvalid_vector_ext;
  wire [15:0]                         bready_vector;

  wire [AXI_IDW*16-1:0]               arid_vector;
  wire [AXI_ADDRW*16-1:0]             araddr_vector;
  wire [AXI_LENW*16-1:0]              arlen_vector;
  wire [AXI_SIZEW*16-1:0]             arsize_vector;
  wire [AXI_BURSTW*16-1:0]            arburst_vector;
  wire [AXI_TOTAL_LOCKW-1:0]          arlock_vector;
  wire [AXI_CACHEW*16-1:0]            arcache_vector;
  wire [AXI_PROTW*16-1:0]             arprot_vector;
  wire [AXI_USERW*16-1:0]             aruser_vector;
  wire [AXI_QOSW*16-1:0]              arqos_vector;
  wire [15:0]                         arurgentb_vector;
  wire [15:0]                         arurgentr_vector;
  wire [15:0]                         arvalid_vector;
  wire [15:0]                         arpoison_vector;
  wire [15:0]                         arautopre_vector;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN*16-1:0] arparity_vector;
  wire [A_NPORTS-1:0]                 arready_vector;
  wire [1*16-1:0]                     arready_vector_ext;

  wire [AXI_IDW*A_NPORTS-1:0]         rid_vector;
  wire [AXI_IDW*16-1:0]               rid_vector_ext;
  wire [AXI_TOTAL_DW-1:0]             rdata_vector;
  wire [AXI_TOTAL_STRBW-1:0]          rparity_vector;
  wire [AXI_RESPW*A_NPORTS-1:0]       rresp_vector;
  wire [AXI_RESPW*16-1:0]             rresp_vector_ext;
  wire [AXI_USERW*A_NPORTS-1:0]       ruser_vector;
  wire [AXI_USERW*16-1:0]             ruser_vector_ext;
  wire [A_NPORTS-1:0]                 rlast_vector;
  wire [1*16-1:0]                     rlast_vector_ext;
  wire [A_NPORTS-1:0]                 rvalid_vector;
  wire [1*16-1:0]                     rvalid_vector_ext;
  wire [15:0]                         rready_vector;

  wire [AXI_IDW-1:0]                  awid_0_w;
  wire [AXI_ADDRW-1:0]                awaddr_0_w;
  wire [AXI_LENW-1:0]                 awlen_0_w;
  wire [AXI_SIZEW-1:0]                awsize_0_w;
  wire [AXI_BURSTW-1:0]               awburst_0_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_0-1:0] awlock_0_w;
  wire [AXI_CACHEW-1:0]               awcache_0_w;
  wire [AXI_PROTW-1:0]                awprot_0_w;
  wire [AXI_USERW-1:0]                awuser_0_w;
  wire [AXI_QOSW-1:0]                 awqos_0_w;
  wire                                awurgent_0_w;
  wire                                awvalid_0_w;
  wire                                awpoison_0_w;
  wire                                awautopre_0_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_0_w;
  wire                                awready_0_w;

  wire [AXI_IDW-1:0]                  wid_0_w;
  wire [`UMCTL2_PORT_DW_0-1:0]        wdata_0_w;
  wire [`UMCTL2_PORT_NBYTES_0-1:0]    wparity_0_w;
  wire [`UMCTL2_PORT_NBYTES_0-1:0]    wstrb_0_w;
  wire                                wlast_0_w;
  wire                                wvalid_0_w;
  wire                                wready_0_w;
  wire [AXI_USERW-1:0]                wuser_0_w;

  wire [AXI_IDW-1:0]                  bid_0_w;
  wire [AXI_RESPW-1:0]                bresp_0_w;
  wire [AXI_USERW-1:0]                buser_0_w;
  wire                                bvalid_0_w;
  wire                                bready_0_w;

  wire [AXI_IDW-1:0]                  arid_0_w;
  wire [AXI_ADDRW-1:0]                araddr_0_w;
  wire [AXI_LENW-1:0]                 arlen_0_w;
  wire [AXI_SIZEW-1:0]                arsize_0_w;
  wire [AXI_BURSTW-1:0]               arburst_0_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_0-1:0] arlock_0_w;
  wire [AXI_CACHEW-1:0]               arcache_0_w;
  wire [AXI_PROTW-1:0]                arprot_0_w;
  wire [AXI_USERW-1:0]                aruser_0_w;
  wire [AXI_QOSW-1:0]                 arqos_0_w;
  wire                                arurgentb_0_w;
  wire                                arurgentr_0_w;
  wire                                arvalid_0_w;
  wire                                arpoison_0_w;
  wire                                arautopre_0_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_0_w;
  wire                                arready_0_w;

  wire [AXI_IDW-1:0]                  rid_0_w;
  wire [`UMCTL2_PORT_DW_0-1:0]        rdata_0_w;
  wire [`UMCTL2_PORT_NBYTES_0-1:0]    rparity_0_w;
  wire [AXI_RESPW-1:0]                rresp_0_w;
  wire [AXI_USERW-1:0]                ruser_0_w;
  wire                                rlast_0_w;
  wire                                rvalid_0_w;
  wire                                rready_0_w;

  wire [AXI_IDW-1:0]                  awid_1_w;
  wire [AXI_ADDRW-1:0]                awaddr_1_w;
  wire [AXI_LENW-1:0]                 awlen_1_w;
  wire [AXI_SIZEW-1:0]                awsize_1_w;
  wire [AXI_BURSTW-1:0]               awburst_1_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_1-1:0] awlock_1_w;
  wire [AXI_CACHEW-1:0]               awcache_1_w;
  wire [AXI_PROTW-1:0]                awprot_1_w;
  wire [AXI_USERW-1:0]                awuser_1_w;
  wire [AXI_QOSW-1:0]                 awqos_1_w;
  wire                                awurgent_1_w;
  wire                                awvalid_1_w;
  wire                                awpoison_1_w;
  wire                                awautopre_1_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_1_w;
  wire                                awready_1_w;

  wire [AXI_IDW-1:0]                  wid_1_w;
  wire [`UMCTL2_PORT_DW_1-1:0]        wdata_1_w;
  wire [`UMCTL2_PORT_NBYTES_1-1:0]    wparity_1_w;
  wire [`UMCTL2_PORT_NBYTES_1-1:0]    wstrb_1_w;
  wire                                wlast_1_w;
  wire                                wvalid_1_w;
  wire                                wready_1_w;
  wire [AXI_USERW-1:0]                wuser_1_w;

  wire [AXI_IDW-1:0]                  bid_1_w;
  wire [AXI_RESPW-1:0]                bresp_1_w;
  wire [AXI_USERW-1:0]                buser_1_w;
  wire                                bvalid_1_w;
  wire                                bready_1_w;

  wire [AXI_IDW-1:0]                  arid_1_w;
  wire [AXI_ADDRW-1:0]                araddr_1_w;
  wire [AXI_LENW-1:0]                 arlen_1_w;
  wire [AXI_SIZEW-1:0]                arsize_1_w;
  wire [AXI_BURSTW-1:0]               arburst_1_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_1-1:0] arlock_1_w;
  wire [AXI_CACHEW-1:0]               arcache_1_w;
  wire [AXI_PROTW-1:0]                arprot_1_w;
  wire [AXI_USERW-1:0]                aruser_1_w;
  wire [AXI_QOSW-1:0]                 arqos_1_w;
  wire                                arurgentb_1_w;
  wire                                arurgentr_1_w;
  wire                                arvalid_1_w;
  wire                                arpoison_1_w;
  wire                                arautopre_1_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_1_w;
  wire                                arready_1_w;

  wire [AXI_IDW-1:0]                  rid_1_w;
  wire [`UMCTL2_PORT_DW_1-1:0]        rdata_1_w;
  wire [`UMCTL2_PORT_NBYTES_1-1:0]    rparity_1_w;
  wire [AXI_RESPW-1:0]                rresp_1_w;
  wire [AXI_USERW-1:0]                ruser_1_w;
  wire                                rlast_1_w;
  wire                                rvalid_1_w;
  wire                                rready_1_w;

  wire [AXI_IDW-1:0]                  awid_2_w;
  wire [AXI_ADDRW-1:0]                awaddr_2_w;
  wire [AXI_LENW-1:0]                 awlen_2_w;
  wire [AXI_SIZEW-1:0]                awsize_2_w;
  wire [AXI_BURSTW-1:0]               awburst_2_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_2-1:0] awlock_2_w;
  wire [AXI_CACHEW-1:0]               awcache_2_w;
  wire [AXI_PROTW-1:0]                awprot_2_w;
  wire [AXI_USERW-1:0]                awuser_2_w;
  wire [AXI_QOSW-1:0]                 awqos_2_w;
  wire                                awurgent_2_w;
  wire                                awvalid_2_w;
  wire                                awpoison_2_w;
  wire                                awautopre_2_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_2_w;
  wire                                awready_2_w;

  wire [AXI_IDW-1:0]                  wid_2_w;
  wire [`UMCTL2_PORT_DW_2-1:0]        wdata_2_w;
  wire [`UMCTL2_PORT_NBYTES_2-1:0]    wparity_2_w;
  wire [`UMCTL2_PORT_NBYTES_2-1:0]    wstrb_2_w;
  wire                                wlast_2_w;
  wire                                wvalid_2_w;
  wire                                wready_2_w;
  wire [AXI_USERW-1:0]                wuser_2_w;

  wire [AXI_IDW-1:0]                  bid_2_w;
  wire [AXI_RESPW-1:0]                bresp_2_w;
  wire [AXI_USERW-1:0]                buser_2_w;
  wire                                bvalid_2_w;
  wire                                bready_2_w;

  wire [AXI_IDW-1:0]                  arid_2_w;
  wire [AXI_ADDRW-1:0]                araddr_2_w;
  wire [AXI_LENW-1:0]                 arlen_2_w;
  wire [AXI_SIZEW-1:0]                arsize_2_w;
  wire [AXI_BURSTW-1:0]               arburst_2_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_2-1:0] arlock_2_w;
  wire [AXI_CACHEW-1:0]               arcache_2_w;
  wire [AXI_PROTW-1:0]                arprot_2_w;
  wire [AXI_USERW-1:0]                aruser_2_w;
  wire [AXI_QOSW-1:0]                 arqos_2_w;
  wire                                arurgentb_2_w;
  wire                                arurgentr_2_w;
  wire                                arvalid_2_w;
  wire                                arpoison_2_w;
  wire                                arautopre_2_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_2_w;
  wire                                arready_2_w;

  wire [AXI_IDW-1:0]                  rid_2_w;
  wire [`UMCTL2_PORT_DW_2-1:0]        rdata_2_w;
  wire [`UMCTL2_PORT_NBYTES_2-1:0]    rparity_2_w;
  wire [AXI_RESPW-1:0]                rresp_2_w;
  wire [AXI_USERW-1:0]                ruser_2_w;
  wire                                rlast_2_w;
  wire                                rvalid_2_w;
  wire                                rready_2_w;

  wire [AXI_IDW-1:0]                  awid_3_w;
  wire [AXI_ADDRW-1:0]                awaddr_3_w;
  wire [AXI_LENW-1:0]                 awlen_3_w;
  wire [AXI_SIZEW-1:0]                awsize_3_w;
  wire [AXI_BURSTW-1:0]               awburst_3_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_3-1:0] awlock_3_w;
  wire [AXI_CACHEW-1:0]               awcache_3_w;
  wire [AXI_PROTW-1:0]                awprot_3_w;
  wire [AXI_USERW-1:0]                awuser_3_w;
  wire [AXI_QOSW-1:0]                 awqos_3_w;
  wire                                awurgent_3_w;
  wire                                awvalid_3_w;
  wire                                awpoison_3_w;
  wire                                awautopre_3_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_3_w;
  wire                                awready_3_w;

  wire [AXI_IDW-1:0]                  wid_3_w;
  wire [`UMCTL2_PORT_DW_3-1:0]        wdata_3_w;
  wire [`UMCTL2_PORT_NBYTES_3-1:0]    wparity_3_w;
  wire [`UMCTL2_PORT_NBYTES_3-1:0]    wstrb_3_w;
  wire                                wlast_3_w;
  wire                                wvalid_3_w;
  wire                                wready_3_w;
  wire [AXI_USERW-1:0]                wuser_3_w;

  wire [AXI_IDW-1:0]                  bid_3_w;
  wire [AXI_RESPW-1:0]                bresp_3_w;
  wire [AXI_USERW-1:0]                buser_3_w;
  wire                                bvalid_3_w;
  wire                                bready_3_w;

  wire [AXI_IDW-1:0]                  arid_3_w;
  wire [AXI_ADDRW-1:0]                araddr_3_w;
  wire [AXI_LENW-1:0]                 arlen_3_w;
  wire [AXI_SIZEW-1:0]                arsize_3_w;
  wire [AXI_BURSTW-1:0]               arburst_3_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_3-1:0] arlock_3_w;
  wire [AXI_CACHEW-1:0]               arcache_3_w;
  wire [AXI_PROTW-1:0]                arprot_3_w;
  wire [AXI_USERW-1:0]                aruser_3_w;
  wire [AXI_QOSW-1:0]                 arqos_3_w;
  wire                                arurgentb_3_w;
  wire                                arurgentr_3_w;
  wire                                arvalid_3_w;
  wire                                arpoison_3_w;
  wire                                arautopre_3_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_3_w;
  wire                                arready_3_w;

  wire [AXI_IDW-1:0]                  rid_3_w;
  wire [`UMCTL2_PORT_DW_3-1:0]        rdata_3_w;
  wire [`UMCTL2_PORT_NBYTES_3-1:0]    rparity_3_w;
  wire [AXI_RESPW-1:0]                rresp_3_w;
  wire [AXI_USERW-1:0]                ruser_3_w;
  wire                                rlast_3_w;
  wire                                rvalid_3_w;
  wire                                rready_3_w;

  wire [AXI_IDW-1:0]                  awid_4_w;
  wire [AXI_ADDRW-1:0]                awaddr_4_w;
  wire [AXI_LENW-1:0]                 awlen_4_w;
  wire [AXI_SIZEW-1:0]                awsize_4_w;
  wire [AXI_BURSTW-1:0]               awburst_4_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_4-1:0] awlock_4_w;
  wire [AXI_CACHEW-1:0]               awcache_4_w;
  wire [AXI_PROTW-1:0]                awprot_4_w;
  wire [AXI_USERW-1:0]                awuser_4_w;
  wire [AXI_QOSW-1:0]                 awqos_4_w;
  wire                                awurgent_4_w;
  wire                                awvalid_4_w;
  wire                                awpoison_4_w;
  wire                                awautopre_4_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_4_w;
  wire                                awready_4_w;

  wire [AXI_IDW-1:0]                  wid_4_w;
  wire [`UMCTL2_PORT_DW_4-1:0]        wdata_4_w;
  wire [`UMCTL2_PORT_NBYTES_4-1:0]    wparity_4_w;
  wire [`UMCTL2_PORT_NBYTES_4-1:0]    wstrb_4_w;
  wire                                wlast_4_w;
  wire                                wvalid_4_w;
  wire                                wready_4_w;
  wire [AXI_USERW-1:0]                wuser_4_w;

  wire [AXI_IDW-1:0]                  bid_4_w;
  wire [AXI_RESPW-1:0]                bresp_4_w;
  wire [AXI_USERW-1:0]                buser_4_w;
  wire                                bvalid_4_w;
  wire                                bready_4_w;

  wire [AXI_IDW-1:0]                  arid_4_w;
  wire [AXI_ADDRW-1:0]                araddr_4_w;
  wire [AXI_LENW-1:0]                 arlen_4_w;
  wire [AXI_SIZEW-1:0]                arsize_4_w;
  wire [AXI_BURSTW-1:0]               arburst_4_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_4-1:0] arlock_4_w;
  wire [AXI_CACHEW-1:0]               arcache_4_w;
  wire [AXI_PROTW-1:0]                arprot_4_w;
  wire [AXI_USERW-1:0]                aruser_4_w;
  wire [AXI_QOSW-1:0]                 arqos_4_w;
  wire                                arurgentb_4_w;
  wire                                arurgentr_4_w;
  wire                                arvalid_4_w;
  wire                                arpoison_4_w;
  wire                                arautopre_4_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_4_w;
  wire                                arready_4_w;

  wire [AXI_IDW-1:0]                  rid_4_w;
  wire [`UMCTL2_PORT_DW_4-1:0]        rdata_4_w;
  wire [`UMCTL2_PORT_NBYTES_4-1:0]    rparity_4_w;
  wire [AXI_RESPW-1:0]                rresp_4_w;
  wire [AXI_USERW-1:0]                ruser_4_w;
  wire                                rlast_4_w;
  wire                                rvalid_4_w;
  wire                                rready_4_w;

  wire [AXI_IDW-1:0]                  awid_5_w;
  wire [AXI_ADDRW-1:0]                awaddr_5_w;
  wire [AXI_LENW-1:0]                 awlen_5_w;
  wire [AXI_SIZEW-1:0]                awsize_5_w;
  wire [AXI_BURSTW-1:0]               awburst_5_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_5-1:0] awlock_5_w;
  wire [AXI_CACHEW-1:0]               awcache_5_w;
  wire [AXI_PROTW-1:0]                awprot_5_w;
  wire [AXI_USERW-1:0]                awuser_5_w;
  wire [AXI_QOSW-1:0]                 awqos_5_w;
  wire                                awurgent_5_w;
  wire                                awvalid_5_w;
  wire                                awpoison_5_w;
  wire                                awautopre_5_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_5_w;
  wire                                awready_5_w;

  wire [AXI_IDW-1:0]                  wid_5_w;
  wire [`UMCTL2_PORT_DW_5-1:0]        wdata_5_w;
  wire [`UMCTL2_PORT_NBYTES_5-1:0]    wparity_5_w;
  wire [`UMCTL2_PORT_NBYTES_5-1:0]    wstrb_5_w;
  wire                                wlast_5_w;
  wire                                wvalid_5_w;
  wire                                wready_5_w;
  wire [AXI_USERW-1:0]                wuser_5_w;

  wire [AXI_IDW-1:0]                  bid_5_w;
  wire [AXI_RESPW-1:0]                bresp_5_w;
  wire [AXI_USERW-1:0]                buser_5_w;
  wire                                bvalid_5_w;
  wire                                bready_5_w;

  wire [AXI_IDW-1:0]                  arid_5_w;
  wire [AXI_ADDRW-1:0]                araddr_5_w;
  wire [AXI_LENW-1:0]                 arlen_5_w;
  wire [AXI_SIZEW-1:0]                arsize_5_w;
  wire [AXI_BURSTW-1:0]               arburst_5_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_5-1:0] arlock_5_w;
  wire [AXI_CACHEW-1:0]               arcache_5_w;
  wire [AXI_PROTW-1:0]                arprot_5_w;
  wire [AXI_USERW-1:0]                aruser_5_w;
  wire [AXI_QOSW-1:0]                 arqos_5_w;
  wire                                arurgentb_5_w;
  wire                                arurgentr_5_w;
  wire                                arvalid_5_w;
  wire                                arpoison_5_w;
  wire                                arautopre_5_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_5_w;
  wire                                arready_5_w;

  wire [AXI_IDW-1:0]                  rid_5_w;
  wire [`UMCTL2_PORT_DW_5-1:0]        rdata_5_w;
  wire [`UMCTL2_PORT_NBYTES_5-1:0]    rparity_5_w;
  wire [AXI_RESPW-1:0]                rresp_5_w;
  wire [AXI_USERW-1:0]                ruser_5_w;
  wire                                rlast_5_w;
  wire                                rvalid_5_w;
  wire                                rready_5_w;

  wire [AXI_IDW-1:0]                  awid_6_w;
  wire [AXI_ADDRW-1:0]                awaddr_6_w;
  wire [AXI_LENW-1:0]                 awlen_6_w;
  wire [AXI_SIZEW-1:0]                awsize_6_w;
  wire [AXI_BURSTW-1:0]               awburst_6_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_6-1:0] awlock_6_w;
  wire [AXI_CACHEW-1:0]               awcache_6_w;
  wire [AXI_PROTW-1:0]                awprot_6_w;
  wire [AXI_USERW-1:0]                awuser_6_w;
  wire [AXI_QOSW-1:0]                 awqos_6_w;
  wire                                awurgent_6_w;
  wire                                awvalid_6_w;
  wire                                awpoison_6_w;
  wire                                awautopre_6_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_6_w;
  wire                                awready_6_w;

  wire [AXI_IDW-1:0]                  wid_6_w;
  wire [`UMCTL2_PORT_DW_6-1:0]        wdata_6_w;
  wire [`UMCTL2_PORT_NBYTES_6-1:0]    wparity_6_w;
  wire [`UMCTL2_PORT_NBYTES_6-1:0]    wstrb_6_w;
  wire                                wlast_6_w;
  wire                                wvalid_6_w;
  wire                                wready_6_w;
  wire [AXI_USERW-1:0]                wuser_6_w;

  wire [AXI_IDW-1:0]                  bid_6_w;
  wire [AXI_RESPW-1:0]                bresp_6_w;
  wire [AXI_USERW-1:0]                buser_6_w;
  wire                                bvalid_6_w;
  wire                                bready_6_w;

  wire [AXI_IDW-1:0]                  arid_6_w;
  wire [AXI_ADDRW-1:0]                araddr_6_w;
  wire [AXI_LENW-1:0]                 arlen_6_w;
  wire [AXI_SIZEW-1:0]                arsize_6_w;
  wire [AXI_BURSTW-1:0]               arburst_6_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_6-1:0] arlock_6_w;
  wire [AXI_CACHEW-1:0]               arcache_6_w;
  wire [AXI_PROTW-1:0]                arprot_6_w;
  wire [AXI_USERW-1:0]                aruser_6_w;
  wire [AXI_QOSW-1:0]                 arqos_6_w;
  wire                                arurgentb_6_w;
  wire                                arurgentr_6_w;
  wire                                arvalid_6_w;
  wire                                arpoison_6_w;
  wire                                arautopre_6_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_6_w;
  wire                                arready_6_w;

  wire [AXI_IDW-1:0]                  rid_6_w;
  wire [`UMCTL2_PORT_DW_6-1:0]        rdata_6_w;
  wire [`UMCTL2_PORT_NBYTES_6-1:0]    rparity_6_w;
  wire [AXI_RESPW-1:0]                rresp_6_w;
  wire [AXI_USERW-1:0]                ruser_6_w;
  wire                                rlast_6_w;
  wire                                rvalid_6_w;
  wire                                rready_6_w;

  wire [AXI_IDW-1:0]                  awid_7_w;
  wire [AXI_ADDRW-1:0]                awaddr_7_w;
  wire [AXI_LENW-1:0]                 awlen_7_w;
  wire [AXI_SIZEW-1:0]                awsize_7_w;
  wire [AXI_BURSTW-1:0]               awburst_7_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_7-1:0] awlock_7_w;
  wire [AXI_CACHEW-1:0]               awcache_7_w;
  wire [AXI_PROTW-1:0]                awprot_7_w;
  wire [AXI_USERW-1:0]                awuser_7_w;
  wire [AXI_QOSW-1:0]                 awqos_7_w;
  wire                                awurgent_7_w;
  wire                                awvalid_7_w;
  wire                                awpoison_7_w;
  wire                                awautopre_7_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_7_w;
  wire                                awready_7_w;

  wire [AXI_IDW-1:0]                  wid_7_w;
  wire [`UMCTL2_PORT_DW_7-1:0]        wdata_7_w;
  wire [`UMCTL2_PORT_NBYTES_7-1:0]    wparity_7_w;
  wire [`UMCTL2_PORT_NBYTES_7-1:0]    wstrb_7_w;
  wire                                wlast_7_w;
  wire                                wvalid_7_w;
  wire                                wready_7_w;
  wire [AXI_USERW-1:0]                wuser_7_w;

  wire [AXI_IDW-1:0]                  bid_7_w;
  wire [AXI_RESPW-1:0]                bresp_7_w;
  wire [AXI_USERW-1:0]                buser_7_w;
  wire                                bvalid_7_w;
  wire                                bready_7_w;

  wire [AXI_IDW-1:0]                  arid_7_w;
  wire [AXI_ADDRW-1:0]                araddr_7_w;
  wire [AXI_LENW-1:0]                 arlen_7_w;
  wire [AXI_SIZEW-1:0]                arsize_7_w;
  wire [AXI_BURSTW-1:0]               arburst_7_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_7-1:0] arlock_7_w;
  wire [AXI_CACHEW-1:0]               arcache_7_w;
  wire [AXI_PROTW-1:0]                arprot_7_w;
  wire [AXI_USERW-1:0]                aruser_7_w;
  wire [AXI_QOSW-1:0]                 arqos_7_w;
  wire                                arurgentb_7_w;
  wire                                arurgentr_7_w;
  wire                                arvalid_7_w;
  wire                                arpoison_7_w;
  wire                                arautopre_7_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_7_w;
  wire                                arready_7_w;

  wire [AXI_IDW-1:0]                  rid_7_w;
  wire [`UMCTL2_PORT_DW_7-1:0]        rdata_7_w;
  wire [`UMCTL2_PORT_NBYTES_7-1:0]    rparity_7_w;
  wire [AXI_RESPW-1:0]                rresp_7_w;
  wire [AXI_USERW-1:0]                ruser_7_w;
  wire                                rlast_7_w;
  wire                                rvalid_7_w;
  wire                                rready_7_w;

  wire [AXI_IDW-1:0]                  awid_8_w;
  wire [AXI_ADDRW-1:0]                awaddr_8_w;
  wire [AXI_LENW-1:0]                 awlen_8_w;
  wire [AXI_SIZEW-1:0]                awsize_8_w;
  wire [AXI_BURSTW-1:0]               awburst_8_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_8-1:0] awlock_8_w;
  wire [AXI_CACHEW-1:0]               awcache_8_w;
  wire [AXI_PROTW-1:0]                awprot_8_w;
  wire [AXI_USERW-1:0]                awuser_8_w;
  wire [AXI_QOSW-1:0]                 awqos_8_w;
  wire                                awurgent_8_w;
  wire                                awvalid_8_w;
  wire                                awpoison_8_w;
  wire                                awautopre_8_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_8_w;
  wire                                awready_8_w;

  wire [AXI_IDW-1:0]                  wid_8_w;
  wire [`UMCTL2_PORT_DW_8-1:0]        wdata_8_w;
  wire [`UMCTL2_PORT_NBYTES_8-1:0]    wparity_8_w;
  wire [`UMCTL2_PORT_NBYTES_8-1:0]    wstrb_8_w;
  wire                                wlast_8_w;
  wire                                wvalid_8_w;
  wire                                wready_8_w;
  wire [AXI_USERW-1:0]                wuser_8_w;

  wire [AXI_IDW-1:0]                  bid_8_w;
  wire [AXI_RESPW-1:0]                bresp_8_w;
  wire [AXI_USERW-1:0]                buser_8_w;
  wire                                bvalid_8_w;
  wire                                bready_8_w;

  wire [AXI_IDW-1:0]                  arid_8_w;
  wire [AXI_ADDRW-1:0]                araddr_8_w;
  wire [AXI_LENW-1:0]                 arlen_8_w;
  wire [AXI_SIZEW-1:0]                arsize_8_w;
  wire [AXI_BURSTW-1:0]               arburst_8_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_8-1:0] arlock_8_w;
  wire [AXI_CACHEW-1:0]               arcache_8_w;
  wire [AXI_PROTW-1:0]                arprot_8_w;
  wire [AXI_USERW-1:0]                aruser_8_w;
  wire [AXI_QOSW-1:0]                 arqos_8_w;
  wire                                arurgentb_8_w;
  wire                                arurgentr_8_w;
  wire                                arvalid_8_w;
  wire                                arpoison_8_w;
  wire                                arautopre_8_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_8_w;
  wire                                arready_8_w;

  wire [AXI_IDW-1:0]                  rid_8_w;
  wire [`UMCTL2_PORT_DW_8-1:0]        rdata_8_w;
  wire [`UMCTL2_PORT_NBYTES_8-1:0]    rparity_8_w;
  wire [AXI_RESPW-1:0]                rresp_8_w;
  wire [AXI_USERW-1:0]                ruser_8_w;
  wire                                rlast_8_w;
  wire                                rvalid_8_w;
  wire                                rready_8_w;

  wire [AXI_IDW-1:0]                  awid_9_w;
  wire [AXI_ADDRW-1:0]                awaddr_9_w;
  wire [AXI_LENW-1:0]                 awlen_9_w;
  wire [AXI_SIZEW-1:0]                awsize_9_w;
  wire [AXI_BURSTW-1:0]               awburst_9_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_9-1:0] awlock_9_w;
  wire [AXI_CACHEW-1:0]               awcache_9_w;
  wire [AXI_PROTW-1:0]                awprot_9_w;
  wire [AXI_USERW-1:0]                awuser_9_w;
  wire [AXI_QOSW-1:0]                 awqos_9_w;
  wire                                awurgent_9_w;
  wire                                awvalid_9_w;
  wire                                awpoison_9_w;
  wire                                awautopre_9_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_9_w;
  wire                                awready_9_w;

  wire [AXI_IDW-1:0]                  wid_9_w;
  wire [`UMCTL2_PORT_DW_9-1:0]        wdata_9_w;
  wire [`UMCTL2_PORT_NBYTES_9-1:0]    wparity_9_w;
  wire [`UMCTL2_PORT_NBYTES_9-1:0]    wstrb_9_w;
  wire                                wlast_9_w;
  wire                                wvalid_9_w;
  wire                                wready_9_w;
  wire [AXI_USERW-1:0]                wuser_9_w;

  wire [AXI_IDW-1:0]                  bid_9_w;
  wire [AXI_RESPW-1:0]                bresp_9_w;
  wire [AXI_USERW-1:0]                buser_9_w;
  wire                                bvalid_9_w;
  wire                                bready_9_w;

  wire [AXI_IDW-1:0]                  arid_9_w;
  wire [AXI_ADDRW-1:0]                araddr_9_w;
  wire [AXI_LENW-1:0]                 arlen_9_w;
  wire [AXI_SIZEW-1:0]                arsize_9_w;
  wire [AXI_BURSTW-1:0]               arburst_9_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_9-1:0] arlock_9_w;
  wire [AXI_CACHEW-1:0]               arcache_9_w;
  wire [AXI_PROTW-1:0]                arprot_9_w;
  wire [AXI_USERW-1:0]                aruser_9_w;
  wire [AXI_QOSW-1:0]                 arqos_9_w;
  wire                                arurgentb_9_w;
  wire                                arurgentr_9_w;
  wire                                arvalid_9_w;
  wire                                arpoison_9_w;
  wire                                arautopre_9_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_9_w;
  wire                                arready_9_w;

  wire [AXI_IDW-1:0]                  rid_9_w;
  wire [`UMCTL2_PORT_DW_9-1:0]        rdata_9_w;
  wire [`UMCTL2_PORT_NBYTES_9-1:0]    rparity_9_w;
  wire [AXI_RESPW-1:0]                rresp_9_w;
  wire [AXI_USERW-1:0]                ruser_9_w;
  wire                                rlast_9_w;
  wire                                rvalid_9_w;
  wire                                rready_9_w;

  wire [AXI_IDW-1:0]                  awid_10_w;
  wire [AXI_ADDRW-1:0]                awaddr_10_w;
  wire [AXI_LENW-1:0]                 awlen_10_w;
  wire [AXI_SIZEW-1:0]                awsize_10_w;
  wire [AXI_BURSTW-1:0]               awburst_10_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_10-1:0] awlock_10_w;
  wire [AXI_CACHEW-1:0]               awcache_10_w;
  wire [AXI_PROTW-1:0]                awprot_10_w;
  wire [AXI_USERW-1:0]                awuser_10_w;
  wire [AXI_QOSW-1:0]                 awqos_10_w;
  wire                                awurgent_10_w;
  wire                                awvalid_10_w;
  wire                                awpoison_10_w;
  wire                                awautopre_10_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_10_w;
  wire                                awready_10_w;

  wire [AXI_IDW-1:0]                  wid_10_w;
  wire [`UMCTL2_PORT_DW_10-1:0]        wdata_10_w;
  wire [`UMCTL2_PORT_NBYTES_10-1:0]    wparity_10_w;
  wire [`UMCTL2_PORT_NBYTES_10-1:0]    wstrb_10_w;
  wire                                wlast_10_w;
  wire                                wvalid_10_w;
  wire                                wready_10_w;
  wire [AXI_USERW-1:0]                wuser_10_w;

  wire [AXI_IDW-1:0]                  bid_10_w;
  wire [AXI_RESPW-1:0]                bresp_10_w;
  wire [AXI_USERW-1:0]                buser_10_w;
  wire                                bvalid_10_w;
  wire                                bready_10_w;

  wire [AXI_IDW-1:0]                  arid_10_w;
  wire [AXI_ADDRW-1:0]                araddr_10_w;
  wire [AXI_LENW-1:0]                 arlen_10_w;
  wire [AXI_SIZEW-1:0]                arsize_10_w;
  wire [AXI_BURSTW-1:0]               arburst_10_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_10-1:0] arlock_10_w;
  wire [AXI_CACHEW-1:0]               arcache_10_w;
  wire [AXI_PROTW-1:0]                arprot_10_w;
  wire [AXI_USERW-1:0]                aruser_10_w;
  wire [AXI_QOSW-1:0]                 arqos_10_w;
  wire                                arurgentb_10_w;
  wire                                arurgentr_10_w;
  wire                                arvalid_10_w;
  wire                                arpoison_10_w;
  wire                                arautopre_10_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_10_w;
  wire                                arready_10_w;

  wire [AXI_IDW-1:0]                  rid_10_w;
  wire [`UMCTL2_PORT_DW_10-1:0]        rdata_10_w;
  wire [`UMCTL2_PORT_NBYTES_10-1:0]    rparity_10_w;
  wire [AXI_RESPW-1:0]                rresp_10_w;
  wire [AXI_USERW-1:0]                ruser_10_w;
  wire                                rlast_10_w;
  wire                                rvalid_10_w;
  wire                                rready_10_w;

  wire [AXI_IDW-1:0]                  awid_11_w;
  wire [AXI_ADDRW-1:0]                awaddr_11_w;
  wire [AXI_LENW-1:0]                 awlen_11_w;
  wire [AXI_SIZEW-1:0]                awsize_11_w;
  wire [AXI_BURSTW-1:0]               awburst_11_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_11-1:0] awlock_11_w;
  wire [AXI_CACHEW-1:0]               awcache_11_w;
  wire [AXI_PROTW-1:0]                awprot_11_w;
  wire [AXI_USERW-1:0]                awuser_11_w;
  wire [AXI_QOSW-1:0]                 awqos_11_w;
  wire                                awurgent_11_w;
  wire                                awvalid_11_w;
  wire                                awpoison_11_w;
  wire                                awautopre_11_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_11_w;
  wire                                awready_11_w;

  wire [AXI_IDW-1:0]                  wid_11_w;
  wire [`UMCTL2_PORT_DW_11-1:0]        wdata_11_w;
  wire [`UMCTL2_PORT_NBYTES_11-1:0]    wparity_11_w;
  wire [`UMCTL2_PORT_NBYTES_11-1:0]    wstrb_11_w;
  wire                                wlast_11_w;
  wire                                wvalid_11_w;
  wire                                wready_11_w;
  wire [AXI_USERW-1:0]                wuser_11_w;

  wire [AXI_IDW-1:0]                  bid_11_w;
  wire [AXI_RESPW-1:0]                bresp_11_w;
  wire [AXI_USERW-1:0]                buser_11_w;
  wire                                bvalid_11_w;
  wire                                bready_11_w;

  wire [AXI_IDW-1:0]                  arid_11_w;
  wire [AXI_ADDRW-1:0]                araddr_11_w;
  wire [AXI_LENW-1:0]                 arlen_11_w;
  wire [AXI_SIZEW-1:0]                arsize_11_w;
  wire [AXI_BURSTW-1:0]               arburst_11_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_11-1:0] arlock_11_w;
  wire [AXI_CACHEW-1:0]               arcache_11_w;
  wire [AXI_PROTW-1:0]                arprot_11_w;
  wire [AXI_USERW-1:0]                aruser_11_w;
  wire [AXI_QOSW-1:0]                 arqos_11_w;
  wire                                arurgentb_11_w;
  wire                                arurgentr_11_w;
  wire                                arvalid_11_w;
  wire                                arpoison_11_w;
  wire                                arautopre_11_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_11_w;
  wire                                arready_11_w;

  wire [AXI_IDW-1:0]                  rid_11_w;
  wire [`UMCTL2_PORT_DW_11-1:0]        rdata_11_w;
  wire [`UMCTL2_PORT_NBYTES_11-1:0]    rparity_11_w;
  wire [AXI_RESPW-1:0]                rresp_11_w;
  wire [AXI_USERW-1:0]                ruser_11_w;
  wire                                rlast_11_w;
  wire                                rvalid_11_w;
  wire                                rready_11_w;

  wire [AXI_IDW-1:0]                  awid_12_w;
  wire [AXI_ADDRW-1:0]                awaddr_12_w;
  wire [AXI_LENW-1:0]                 awlen_12_w;
  wire [AXI_SIZEW-1:0]                awsize_12_w;
  wire [AXI_BURSTW-1:0]               awburst_12_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_12-1:0] awlock_12_w;
  wire [AXI_CACHEW-1:0]               awcache_12_w;
  wire [AXI_PROTW-1:0]                awprot_12_w;
  wire [AXI_USERW-1:0]                awuser_12_w;
  wire [AXI_QOSW-1:0]                 awqos_12_w;
  wire                                awurgent_12_w;
  wire                                awvalid_12_w;
  wire                                awpoison_12_w;
  wire                                awautopre_12_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_12_w;
  wire                                awready_12_w;

  wire [AXI_IDW-1:0]                  wid_12_w;
  wire [`UMCTL2_PORT_DW_12-1:0]        wdata_12_w;
  wire [`UMCTL2_PORT_NBYTES_12-1:0]    wparity_12_w;
  wire [`UMCTL2_PORT_NBYTES_12-1:0]    wstrb_12_w;
  wire                                wlast_12_w;
  wire                                wvalid_12_w;
  wire                                wready_12_w;
  wire [AXI_USERW-1:0]                wuser_12_w;

  wire [AXI_IDW-1:0]                  bid_12_w;
  wire [AXI_RESPW-1:0]                bresp_12_w;
  wire [AXI_USERW-1:0]                buser_12_w;
  wire                                bvalid_12_w;
  wire                                bready_12_w;

  wire [AXI_IDW-1:0]                  arid_12_w;
  wire [AXI_ADDRW-1:0]                araddr_12_w;
  wire [AXI_LENW-1:0]                 arlen_12_w;
  wire [AXI_SIZEW-1:0]                arsize_12_w;
  wire [AXI_BURSTW-1:0]               arburst_12_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_12-1:0] arlock_12_w;
  wire [AXI_CACHEW-1:0]               arcache_12_w;
  wire [AXI_PROTW-1:0]                arprot_12_w;
  wire [AXI_USERW-1:0]                aruser_12_w;
  wire [AXI_QOSW-1:0]                 arqos_12_w;
  wire                                arurgentb_12_w;
  wire                                arurgentr_12_w;
  wire                                arvalid_12_w;
  wire                                arpoison_12_w;
  wire                                arautopre_12_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_12_w;
  wire                                arready_12_w;

  wire [AXI_IDW-1:0]                  rid_12_w;
  wire [`UMCTL2_PORT_DW_12-1:0]        rdata_12_w;
  wire [`UMCTL2_PORT_NBYTES_12-1:0]    rparity_12_w;
  wire [AXI_RESPW-1:0]                rresp_12_w;
  wire [AXI_USERW-1:0]                ruser_12_w;
  wire                                rlast_12_w;
  wire                                rvalid_12_w;
  wire                                rready_12_w;

  wire [AXI_IDW-1:0]                  awid_13_w;
  wire [AXI_ADDRW-1:0]                awaddr_13_w;
  wire [AXI_LENW-1:0]                 awlen_13_w;
  wire [AXI_SIZEW-1:0]                awsize_13_w;
  wire [AXI_BURSTW-1:0]               awburst_13_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_13-1:0] awlock_13_w;
  wire [AXI_CACHEW-1:0]               awcache_13_w;
  wire [AXI_PROTW-1:0]                awprot_13_w;
  wire [AXI_USERW-1:0]                awuser_13_w;
  wire [AXI_QOSW-1:0]                 awqos_13_w;
  wire                                awurgent_13_w;
  wire                                awvalid_13_w;
  wire                                awpoison_13_w;
  wire                                awautopre_13_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_13_w;
  wire                                awready_13_w;

  wire [AXI_IDW-1:0]                  wid_13_w;
  wire [`UMCTL2_PORT_DW_13-1:0]        wdata_13_w;
  wire [`UMCTL2_PORT_NBYTES_13-1:0]    wparity_13_w;
  wire [`UMCTL2_PORT_NBYTES_13-1:0]    wstrb_13_w;
  wire                                wlast_13_w;
  wire                                wvalid_13_w;
  wire                                wready_13_w;
  wire [AXI_USERW-1:0]                wuser_13_w;

  wire [AXI_IDW-1:0]                  bid_13_w;
  wire [AXI_RESPW-1:0]                bresp_13_w;
  wire [AXI_USERW-1:0]                buser_13_w;
  wire                                bvalid_13_w;
  wire                                bready_13_w;

  wire [AXI_IDW-1:0]                  arid_13_w;
  wire [AXI_ADDRW-1:0]                araddr_13_w;
  wire [AXI_LENW-1:0]                 arlen_13_w;
  wire [AXI_SIZEW-1:0]                arsize_13_w;
  wire [AXI_BURSTW-1:0]               arburst_13_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_13-1:0] arlock_13_w;
  wire [AXI_CACHEW-1:0]               arcache_13_w;
  wire [AXI_PROTW-1:0]                arprot_13_w;
  wire [AXI_USERW-1:0]                aruser_13_w;
  wire [AXI_QOSW-1:0]                 arqos_13_w;
  wire                                arurgentb_13_w;
  wire                                arurgentr_13_w;
  wire                                arvalid_13_w;
  wire                                arpoison_13_w;
  wire                                arautopre_13_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_13_w;
  wire                                arready_13_w;

  wire [AXI_IDW-1:0]                  rid_13_w;
  wire [`UMCTL2_PORT_DW_13-1:0]        rdata_13_w;
  wire [`UMCTL2_PORT_NBYTES_13-1:0]    rparity_13_w;
  wire [AXI_RESPW-1:0]                rresp_13_w;
  wire [AXI_USERW-1:0]                ruser_13_w;
  wire                                rlast_13_w;
  wire                                rvalid_13_w;
  wire                                rready_13_w;

  wire [AXI_IDW-1:0]                  awid_14_w;
  wire [AXI_ADDRW-1:0]                awaddr_14_w;
  wire [AXI_LENW-1:0]                 awlen_14_w;
  wire [AXI_SIZEW-1:0]                awsize_14_w;
  wire [AXI_BURSTW-1:0]               awburst_14_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_14-1:0] awlock_14_w;
  wire [AXI_CACHEW-1:0]               awcache_14_w;
  wire [AXI_PROTW-1:0]                awprot_14_w;
  wire [AXI_USERW-1:0]                awuser_14_w;
  wire [AXI_QOSW-1:0]                 awqos_14_w;
  wire                                awurgent_14_w;
  wire                                awvalid_14_w;
  wire                                awpoison_14_w;
  wire                                awautopre_14_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_14_w;
  wire                                awready_14_w;

  wire [AXI_IDW-1:0]                  wid_14_w;
  wire [`UMCTL2_PORT_DW_14-1:0]        wdata_14_w;
  wire [`UMCTL2_PORT_NBYTES_14-1:0]    wparity_14_w;
  wire [`UMCTL2_PORT_NBYTES_14-1:0]    wstrb_14_w;
  wire                                wlast_14_w;
  wire                                wvalid_14_w;
  wire                                wready_14_w;
  wire [AXI_USERW-1:0]                wuser_14_w;

  wire [AXI_IDW-1:0]                  bid_14_w;
  wire [AXI_RESPW-1:0]                bresp_14_w;
  wire [AXI_USERW-1:0]                buser_14_w;
  wire                                bvalid_14_w;
  wire                                bready_14_w;

  wire [AXI_IDW-1:0]                  arid_14_w;
  wire [AXI_ADDRW-1:0]                araddr_14_w;
  wire [AXI_LENW-1:0]                 arlen_14_w;
  wire [AXI_SIZEW-1:0]                arsize_14_w;
  wire [AXI_BURSTW-1:0]               arburst_14_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_14-1:0] arlock_14_w;
  wire [AXI_CACHEW-1:0]               arcache_14_w;
  wire [AXI_PROTW-1:0]                arprot_14_w;
  wire [AXI_USERW-1:0]                aruser_14_w;
  wire [AXI_QOSW-1:0]                 arqos_14_w;
  wire                                arurgentb_14_w;
  wire                                arurgentr_14_w;
  wire                                arvalid_14_w;
  wire                                arpoison_14_w;
  wire                                arautopre_14_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_14_w;
  wire                                arready_14_w;

  wire [AXI_IDW-1:0]                  rid_14_w;
  wire [`UMCTL2_PORT_DW_14-1:0]        rdata_14_w;
  wire [`UMCTL2_PORT_NBYTES_14-1:0]    rparity_14_w;
  wire [AXI_RESPW-1:0]                rresp_14_w;
  wire [AXI_USERW-1:0]                ruser_14_w;
  wire                                rlast_14_w;
  wire                                rvalid_14_w;
  wire                                rready_14_w;

  wire [AXI_IDW-1:0]                  awid_15_w;
  wire [AXI_ADDRW-1:0]                awaddr_15_w;
  wire [AXI_LENW-1:0]                 awlen_15_w;
  wire [AXI_SIZEW-1:0]                awsize_15_w;
  wire [AXI_BURSTW-1:0]               awburst_15_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_15-1:0] awlock_15_w;
  wire [AXI_CACHEW-1:0]               awcache_15_w;
  wire [AXI_PROTW-1:0]                awprot_15_w;
  wire [AXI_USERW-1:0]                awuser_15_w;
  wire [AXI_QOSW-1:0]                 awqos_15_w;
  wire                                awurgent_15_w;
  wire                                awvalid_15_w;
  wire                                awpoison_15_w;
  wire                                awautopre_15_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0]    awparity_15_w;
  wire                                awready_15_w;

  wire [AXI_IDW-1:0]                  wid_15_w;
  wire [`UMCTL2_PORT_DW_15-1:0]        wdata_15_w;
  wire [`UMCTL2_PORT_NBYTES_15-1:0]    wparity_15_w;
  wire [`UMCTL2_PORT_NBYTES_15-1:0]    wstrb_15_w;
  wire                                wlast_15_w;
  wire                                wvalid_15_w;
  wire                                wready_15_w;
  wire [AXI_USERW-1:0]                wuser_15_w;

  wire [AXI_IDW-1:0]                  bid_15_w;
  wire [AXI_RESPW-1:0]                bresp_15_w;
  wire [AXI_USERW-1:0]                buser_15_w;
  wire                                bvalid_15_w;
  wire                                bready_15_w;

  wire [AXI_IDW-1:0]                  arid_15_w;
  wire [AXI_ADDRW-1:0]                araddr_15_w;
  wire [AXI_LENW-1:0]                 arlen_15_w;
  wire [AXI_SIZEW-1:0]                arsize_15_w;
  wire [AXI_BURSTW-1:0]               arburst_15_w;
  wire [`UMCTL2_AXI_LOCK_WIDTH_15-1:0] arlock_15_w;
  wire [AXI_CACHEW-1:0]               arcache_15_w;
  wire [AXI_PROTW-1:0]                arprot_15_w;
  wire [AXI_USERW-1:0]                aruser_15_w;
  wire [AXI_QOSW-1:0]                 arqos_15_w;
  wire                                arurgentb_15_w;
  wire                                arurgentr_15_w;
  wire                                arvalid_15_w;
  wire                                arpoison_15_w;
  wire                                arautopre_15_w;
  wire [OCPAR_ADDR_PARITY_WIDTH_MIN-1:0] arparity_15_w;
  wire                                arready_15_w;

  wire [AXI_IDW-1:0]                  rid_15_w;
  wire [`UMCTL2_PORT_DW_15-1:0]        rdata_15_w;
  wire [`UMCTL2_PORT_NBYTES_15-1:0]    rparity_15_w;
  wire [AXI_RESPW-1:0]                rresp_15_w;
  wire [AXI_USERW-1:0]                ruser_15_w;
  wire                                rlast_15_w;
  wire                                rvalid_15_w;
  wire                                rready_15_w;


  //rdataram
  wire [UMCTL2_RDATARAM_DW*16-1:0]    rdataram_dout_vector;
  wire [UMCTL2_RDATARAM_DW*A_NPORTS-1:0] rdataram_din_vector;
  wire [UMCTL2_RDATARAM_DW*16-1:0]    rdataram_din_vector_ext;
  wire [A_NPORTS-1:0]                 rdataram_wr_vector;
  wire [1*16-1:0]                     rdataram_wr_vector_ext;
  wire [A_NPORTS-1:0]                 rdataram_re_vector;
  wire [1*16-1:0]                     rdataram_re_vector_ext;
  wire [UMCTL2_RDATARAM_AW*A_NPORTS-1:0] rdataram_raddr_vector;
  wire [UMCTL2_RDATARAM_AW*16-1:0]    rdataram_raddr_vector_ext;
  wire [UMCTL2_RDATARAM_AW*A_NPORTS-1:0] rdataram_waddr_vector;
  wire [UMCTL2_RDATARAM_AW*16-1:0]    rdataram_waddr_vector_ext;
  wire [UMCTL2_DATARAM_PAR_DW*16-1:0] rdataram_dout_par_vector;
  wire [UMCTL2_DATARAM_PAR_DW*A_NPORTS-1:0] rdataram_din_par_vector;
  wire [UMCTL2_DATARAM_PAR_DW*16-1:0] rdataram_din_par_vector_ext;

  wire [UMCTL2_RDATARAM_DW*16-1:0]    rdataram_dout_dch1_vector;
  wire [UMCTL2_RDATARAM_DW*A_NPORTS-1:0] rdataram_din_dch1_vector;
  wire [UMCTL2_RDATARAM_DW*16-1:0]    rdataram_din_dch1_vector_ext;
  wire [A_NPORTS-1:0]                 rdataram_wr_dch1_vector;
  wire [1*16-1:0]                     rdataram_wr_dch1_vector_ext;
  wire [A_NPORTS-1:0]                 rdataram_re_dch1_vector;
  wire [1*16-1:0]                     rdataram_re_dch1_vector_ext;
  wire [UMCTL2_RDATARAM_AW*A_NPORTS-1:0] rdataram_raddr_dch1_vector;
  wire [UMCTL2_RDATARAM_AW*16-1:0]    rdataram_raddr_dch1_vector_ext;
  wire [UMCTL2_RDATARAM_AW*A_NPORTS-1:0] rdataram_waddr_dch1_vector;
  wire [UMCTL2_RDATARAM_AW*16-1:0]    rdataram_waddr_dch1_vector_ext;
  wire [UMCTL2_DATARAM_PAR_DW*16-1:0] rdataram_dout_par_dch1_vector;
  wire [UMCTL2_DATARAM_PAR_DW*A_NPORTS-1:0] rdataram_din_par_dch1_vector;
  wire [UMCTL2_DATARAM_PAR_DW*16-1:0] rdataram_din_par_dch1_vector_ext;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_0_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_0_w;
  wire                                rdataram_wr_0_w;
  wire                                rdataram_re_0_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_0_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_0_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_0_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_0_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_0_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_0_w;
  wire                                rdataram_wr_dch1_0_w;
  wire                                rdataram_re_dch1_0_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_0_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_0_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_0_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_0_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_1_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_1_w;
  wire                                rdataram_wr_1_w;
  wire                                rdataram_re_1_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_1_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_1_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_1_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_1_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_1_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_1_w;
  wire                                rdataram_wr_dch1_1_w;
  wire                                rdataram_re_dch1_1_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_1_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_1_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_1_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_1_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_2_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_2_w;
  wire                                rdataram_wr_2_w;
  wire                                rdataram_re_2_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_2_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_2_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_2_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_2_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_2_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_2_w;
  wire                                rdataram_wr_dch1_2_w;
  wire                                rdataram_re_dch1_2_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_2_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_2_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_2_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_2_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_3_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_3_w;
  wire                                rdataram_wr_3_w;
  wire                                rdataram_re_3_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_3_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_3_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_3_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_3_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_3_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_3_w;
  wire                                rdataram_wr_dch1_3_w;
  wire                                rdataram_re_dch1_3_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_3_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_3_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_3_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_3_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_4_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_4_w;
  wire                                rdataram_wr_4_w;
  wire                                rdataram_re_4_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_4_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_4_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_4_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_4_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_4_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_4_w;
  wire                                rdataram_wr_dch1_4_w;
  wire                                rdataram_re_dch1_4_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_4_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_4_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_4_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_4_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_5_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_5_w;
  wire                                rdataram_wr_5_w;
  wire                                rdataram_re_5_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_5_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_5_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_5_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_5_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_5_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_5_w;
  wire                                rdataram_wr_dch1_5_w;
  wire                                rdataram_re_dch1_5_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_5_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_5_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_5_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_5_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_6_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_6_w;
  wire                                rdataram_wr_6_w;
  wire                                rdataram_re_6_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_6_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_6_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_6_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_6_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_6_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_6_w;
  wire                                rdataram_wr_dch1_6_w;
  wire                                rdataram_re_dch1_6_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_6_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_6_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_6_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_6_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_7_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_7_w;
  wire                                rdataram_wr_7_w;
  wire                                rdataram_re_7_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_7_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_7_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_7_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_7_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_7_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_7_w;
  wire                                rdataram_wr_dch1_7_w;
  wire                                rdataram_re_dch1_7_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_7_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_7_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_7_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_7_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_8_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_8_w;
  wire                                rdataram_wr_8_w;
  wire                                rdataram_re_8_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_8_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_8_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_8_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_8_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_8_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_8_w;
  wire                                rdataram_wr_dch1_8_w;
  wire                                rdataram_re_dch1_8_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_8_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_8_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_8_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_8_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_9_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_9_w;
  wire                                rdataram_wr_9_w;
  wire                                rdataram_re_9_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_9_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_9_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_9_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_9_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_9_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_9_w;
  wire                                rdataram_wr_dch1_9_w;
  wire                                rdataram_re_dch1_9_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_9_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_9_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_9_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_9_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_10_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_10_w;
  wire                                rdataram_wr_10_w;
  wire                                rdataram_re_10_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_10_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_10_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_10_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_10_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_10_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_10_w;
  wire                                rdataram_wr_dch1_10_w;
  wire                                rdataram_re_dch1_10_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_10_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_10_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_10_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_10_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_11_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_11_w;
  wire                                rdataram_wr_11_w;
  wire                                rdataram_re_11_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_11_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_11_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_11_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_11_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_11_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_11_w;
  wire                                rdataram_wr_dch1_11_w;
  wire                                rdataram_re_dch1_11_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_11_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_11_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_11_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_11_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_12_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_12_w;
  wire                                rdataram_wr_12_w;
  wire                                rdataram_re_12_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_12_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_12_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_12_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_12_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_12_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_12_w;
  wire                                rdataram_wr_dch1_12_w;
  wire                                rdataram_re_dch1_12_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_12_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_12_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_12_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_12_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_13_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_13_w;
  wire                                rdataram_wr_13_w;
  wire                                rdataram_re_13_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_13_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_13_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_13_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_13_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_13_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_13_w;
  wire                                rdataram_wr_dch1_13_w;
  wire                                rdataram_re_dch1_13_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_13_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_13_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_13_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_13_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_14_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_14_w;
  wire                                rdataram_wr_14_w;
  wire                                rdataram_re_14_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_14_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_14_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_14_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_14_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_14_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_14_w;
  wire                                rdataram_wr_dch1_14_w;
  wire                                rdataram_re_dch1_14_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_14_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_14_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_14_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_14_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_15_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_15_w;
  wire                                rdataram_wr_15_w;
  wire                                rdataram_re_15_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_15_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_15_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_15_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_15_w;

  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_dout_dch1_15_w;
  wire [UMCTL2_RDATARAM_DW-1:0]       rdataram_din_dch1_15_w;
  wire                                rdataram_wr_dch1_15_w;
  wire                                rdataram_re_dch1_15_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_raddr_dch1_15_w;
  wire [UMCTL2_RDATARAM_AW-1:0]       rdataram_waddr_dch1_15_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_dout_par_dch1_15_w;
  wire [UMCTL2_DATARAM_PAR_DW-1:0]    rdataram_din_par_dch1_15_w;



  wire [15:0]                         reg_arb_port_en_vector;
  wire [15:0]                         reg_arb_bypass_reorder_vector;
  wire [ARB_TOTAL_ID-1:0]             reg_arb_id_mask_vector;
  wire [ARB_TOTAL_ID-1:0]             reg_arb_id_value_vector;

  wire [XPI_RQOS_MLW*16-1:0]          reg_arba_rqos_map_level1_vector;
  wire [XPI_RQOS_MLW*16-1:0]          reg_arba_rqos_map_level2_vector;

  wire [XPI_RQOS_RW*16-1:0]           reg_arba_rqos_map_region0_vector;
  wire [XPI_RQOS_RW*16-1:0]           reg_arba_rqos_map_region1_vector;
  wire [XPI_RQOS_RW*16-1:0]           reg_arba_rqos_map_region2_vector;

  wire [HIF_RQOS_TW*16-1:0]           reg_arb_rqos_map_timeoutb_vector;
  wire [HIF_RQOS_TW*16-1:0]           reg_arb_rqos_map_timeoutr_vector;

  wire [XPI_WQOS_MLW*16-1:0]          reg_arba_wqos_map_level1_vector;
  wire [XPI_WQOS_MLW*16-1:0]          reg_arba_wqos_map_level2_vector;

  wire [XPI_WQOS_RW*16-1:0]           reg_arba_wqos_map_region0_vector;
  wire [XPI_WQOS_RW*16-1:0]           reg_arba_wqos_map_region1_vector;
  wire [XPI_WQOS_RW*16-1:0]           reg_arba_wqos_map_region2_vector;

  wire [HIF_WQOS_TW*16-1:0]           reg_arb_wqos_map_timeout1_vector;
  wire [HIF_WQOS_TW*16-1:0]           reg_arb_wqos_map_timeout2_vector;

  wire [15:0]                         reg_arb_rd_port_pagematch_en_vector;
  wire [15:0]                         reg_arb_wr_port_pagematch_en_vector;

  wire [15:0]                         reg_arb_rdwr_ordered_en_vector;
  wire [15:0]                         reg_arba_rdwr_ordered_en_vector;
  wire [31:0]                         reg_arba_data_bus_width_vector;
  wire [15:0]                         reg_xpi_snf_mode_vector;

  wire [RRB_LOCK_THRESHOLD_WIDTH*16-1:0]    reg_arb_rrb_lock_threshold_vector;

  wire [15:0]                         reg_arb_port_data_channel_vector;

  wire [REG_PORT_PRIORITYW*16-1:0]    reg_arb_wr_port_priority_vector;
  wire [REG_PORT_PRIORITYW*16-1:0]    reg_arb_rd_port_priority_vector;
  wire [16-1:0]                       reg_arb_wr_port_aging_en_vector;
  wire [16-1:0]                       reg_arb_rd_port_aging_en_vector;
  wire [16-1:0]                       reg_arb_wr_port_urgent_en_vector;
  wire [16-1:0]                       reg_arb_rd_port_urgent_en_vector;

  wire [4:0]                          reg_ddrc_addrmap_row_b16_w;
  wire [4:0]                          reg_ddrc_addrmap_row_b17_w;

  wire [AXI_TOTAL_RAQD_LG2-1:0]       raqb_wcount_vector;
  wire [A_NPORTS-1:0]                 raqb_pop_vector;
  wire [1*16-1:0]                     raqb_pop_vector_ext;
  wire [A_NPORTS-1:0]                 raqb_push_vector;
  wire [1*16-1:0]                     raqb_push_vector_ext;

  wire [AXI_TOTAL_RAQD_LG2-1:0]       raqr_wcount_vector;
  wire [A_NPORTS-1:0]                 raqr_pop_vector;
  wire [1*16-1:0]                     raqr_pop_vector_ext;
  wire [A_NPORTS-1:0]                 raqr_push_vector;
  wire [1*16-1:0]                     raqr_push_vector_ext;
  wire [A_NPORTS-1:0]                 raq_split_vector;
  wire [1*16-1:0]                     raq_split_vector_ext;

  wire [AXI_TOTAL_WAQD_LG2-1:0]       waq_wcount_vector;
  wire [A_NPORTS-1:0]                 waq_pop_vector;
  wire [1*16-1:0]                     waq_pop_vector_ext;
  wire [A_NPORTS-1:0]                 waq_push_vector;
  wire [1*16-1:0]                     waq_push_vector_ext;
  wire [A_NPORTS-1:0]                 waq_split_vector;
  wire [1*16-1:0]                     waq_split_vector_ext;


  wire                                reg_arba0_port_en_0_w;
  wire                                reg_arba0_read_reorder_bypass_en_0_w;
  wire [(ARB_ID_0)-1:0]               reg_arba0_id_mask_0_w;
  wire [(ARB_ID_0)-1:0]               reg_arba0_id_value_0_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba0_rqos_map_level1_0_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba0_rqos_map_level2_0_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba0_rqos_map_region0_0_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba0_rqos_map_region1_0_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba0_rqos_map_region2_0_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_0_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_0_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba0_wqos_map_level1_0_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba0_wqos_map_level2_0_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba0_wqos_map_region0_0_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba0_wqos_map_region1_0_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba0_wqos_map_region2_0_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_0_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_0_w;

  wire                                reg_arb_rd_port_pagematch_en_0_w;
  wire                                reg_arb_wr_port_pagematch_en_0_w;

  wire                                reg_arb_rdwr_ordered_en_0_w;
  wire                                reg_arba0_rdwr_ordered_en_0_w;
  wire [1:0]                          reg_arba_data_bus_width_0_w;
  wire                                reg_xpi_snf_mode_0_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_0_w;

  wire                                reg_arb_port_data_channel_0_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_0_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_0_w;
  wire                                reg_arb_wr_port_aging_en_0_w;
  wire                                reg_arb_rd_port_aging_en_0_w;
  wire                                reg_arb_wr_port_urgent_en_0_w;
  wire                                reg_arb_rd_port_urgent_en_0_w;

  wire                                raqb_pop_0_w;
  wire                                raqb_push_0_w;

  wire                                raqr_pop_0_w;
  wire                                raqr_push_0_w;
  wire                                raq_split_0_w;

  wire                                waq_pop_0_w;
  wire                                waq_push_0_w;
  wire                                waq_split_0_w;

  wire                                reg_arba1_port_en_1_w;
  wire                                reg_arba1_read_reorder_bypass_en_1_w;
  wire [(ARB_ID_1)-1:0]               reg_arba1_id_mask_1_w;
  wire [(ARB_ID_1)-1:0]               reg_arba1_id_value_1_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba1_rqos_map_level1_1_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba1_rqos_map_level2_1_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba1_rqos_map_region0_1_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba1_rqos_map_region1_1_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba1_rqos_map_region2_1_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_1_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_1_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba1_wqos_map_level1_1_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba1_wqos_map_level2_1_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba1_wqos_map_region0_1_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba1_wqos_map_region1_1_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba1_wqos_map_region2_1_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_1_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_1_w;

  wire                                reg_arb_rd_port_pagematch_en_1_w;
  wire                                reg_arb_wr_port_pagematch_en_1_w;

  wire                                reg_arb_rdwr_ordered_en_1_w;
  wire                                reg_arba1_rdwr_ordered_en_1_w;
  wire [1:0]                          reg_arba_data_bus_width_1_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_1_w;

  wire                                reg_arb_port_data_channel_1_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_1_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_1_w;
  wire                                reg_arb_wr_port_aging_en_1_w;
  wire                                reg_arb_rd_port_aging_en_1_w;
  wire                                reg_arb_wr_port_urgent_en_1_w;
  wire                                reg_arb_rd_port_urgent_en_1_w;

  wire                                raqb_pop_1_w;
  wire                                raqb_push_1_w;

  wire                                raqr_pop_1_w;
  wire                                raqr_push_1_w;
  wire                                raq_split_1_w;

  wire                                waq_pop_1_w;
  wire                                waq_push_1_w;
  wire                                waq_split_1_w;

  wire                                reg_arba2_port_en_2_w;
  wire                                reg_arba2_read_reorder_bypass_en_2_w;
  wire [(ARB_ID_2)-1:0]               reg_arba2_id_mask_2_w;
  wire [(ARB_ID_2)-1:0]               reg_arba2_id_value_2_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba2_rqos_map_level1_2_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba2_rqos_map_level2_2_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba2_rqos_map_region0_2_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba2_rqos_map_region1_2_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba2_rqos_map_region2_2_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_2_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_2_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba2_wqos_map_level1_2_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba2_wqos_map_level2_2_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba2_wqos_map_region0_2_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba2_wqos_map_region1_2_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba2_wqos_map_region2_2_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_2_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_2_w;

  wire                                reg_arb_rd_port_pagematch_en_2_w;
  wire                                reg_arb_wr_port_pagematch_en_2_w;

  wire                                reg_arb_rdwr_ordered_en_2_w;
  wire                                reg_arba2_rdwr_ordered_en_2_w;
  wire [1:0]                          reg_arba_data_bus_width_2_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_2_w;

  wire                                reg_arb_port_data_channel_2_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_2_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_2_w;
  wire                                reg_arb_wr_port_aging_en_2_w;
  wire                                reg_arb_rd_port_aging_en_2_w;
  wire                                reg_arb_wr_port_urgent_en_2_w;
  wire                                reg_arb_rd_port_urgent_en_2_w;

  wire                                raqb_pop_2_w;
  wire                                raqb_push_2_w;

  wire                                raqr_pop_2_w;
  wire                                raqr_push_2_w;
  wire                                raq_split_2_w;

  wire                                waq_pop_2_w;
  wire                                waq_push_2_w;
  wire                                waq_split_2_w;

  wire                                reg_arba3_port_en_3_w;
  wire                                reg_arba3_read_reorder_bypass_en_3_w;
  wire [(ARB_ID_3)-1:0]               reg_arba3_id_mask_3_w;
  wire [(ARB_ID_3)-1:0]               reg_arba3_id_value_3_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba3_rqos_map_level1_3_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba3_rqos_map_level2_3_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba3_rqos_map_region0_3_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba3_rqos_map_region1_3_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba3_rqos_map_region2_3_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_3_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_3_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba3_wqos_map_level1_3_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba3_wqos_map_level2_3_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba3_wqos_map_region0_3_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba3_wqos_map_region1_3_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba3_wqos_map_region2_3_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_3_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_3_w;

  wire                                reg_arb_rd_port_pagematch_en_3_w;
  wire                                reg_arb_wr_port_pagematch_en_3_w;

  wire                                reg_arb_rdwr_ordered_en_3_w;
  wire                                reg_arba3_rdwr_ordered_en_3_w;
  wire [1:0]                          reg_arba_data_bus_width_3_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_3_w;

  wire                                reg_arb_port_data_channel_3_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_3_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_3_w;
  wire                                reg_arb_wr_port_aging_en_3_w;
  wire                                reg_arb_rd_port_aging_en_3_w;
  wire                                reg_arb_wr_port_urgent_en_3_w;
  wire                                reg_arb_rd_port_urgent_en_3_w;

  wire                                raqb_pop_3_w;
  wire                                raqb_push_3_w;

  wire                                raqr_pop_3_w;
  wire                                raqr_push_3_w;
  wire                                raq_split_3_w;

  wire                                waq_pop_3_w;
  wire                                waq_push_3_w;
  wire                                waq_split_3_w;

  wire                                reg_arba4_port_en_4_w;
  wire                                reg_arba4_read_reorder_bypass_en_4_w;
  wire [(ARB_ID_4)-1:0]               reg_arba4_id_mask_4_w;
  wire [(ARB_ID_4)-1:0]               reg_arba4_id_value_4_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba4_rqos_map_level1_4_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba4_rqos_map_level2_4_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba4_rqos_map_region0_4_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba4_rqos_map_region1_4_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba4_rqos_map_region2_4_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_4_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_4_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba4_wqos_map_level1_4_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba4_wqos_map_level2_4_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba4_wqos_map_region0_4_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba4_wqos_map_region1_4_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba4_wqos_map_region2_4_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_4_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_4_w;

  wire                                reg_arb_rd_port_pagematch_en_4_w;
  wire                                reg_arb_wr_port_pagematch_en_4_w;

  wire                                reg_arb_rdwr_ordered_en_4_w;
  wire                                reg_arba4_rdwr_ordered_en_4_w;
  wire [1:0]                          reg_arba_data_bus_width_4_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_4_w;

  wire                                reg_arb_port_data_channel_4_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_4_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_4_w;
  wire                                reg_arb_wr_port_aging_en_4_w;
  wire                                reg_arb_rd_port_aging_en_4_w;
  wire                                reg_arb_wr_port_urgent_en_4_w;
  wire                                reg_arb_rd_port_urgent_en_4_w;

  wire                                raqb_pop_4_w;
  wire                                raqb_push_4_w;

  wire                                raqr_pop_4_w;
  wire                                raqr_push_4_w;
  wire                                raq_split_4_w;

  wire                                waq_pop_4_w;
  wire                                waq_push_4_w;
  wire                                waq_split_4_w;

  wire                                reg_arba5_port_en_5_w;
  wire                                reg_arba5_read_reorder_bypass_en_5_w;
  wire [(ARB_ID_5)-1:0]               reg_arba5_id_mask_5_w;
  wire [(ARB_ID_5)-1:0]               reg_arba5_id_value_5_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba5_rqos_map_level1_5_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba5_rqos_map_level2_5_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba5_rqos_map_region0_5_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba5_rqos_map_region1_5_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba5_rqos_map_region2_5_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_5_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_5_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba5_wqos_map_level1_5_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba5_wqos_map_level2_5_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba5_wqos_map_region0_5_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba5_wqos_map_region1_5_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba5_wqos_map_region2_5_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_5_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_5_w;

  wire                                reg_arb_rd_port_pagematch_en_5_w;
  wire                                reg_arb_wr_port_pagematch_en_5_w;

  wire                                reg_arb_rdwr_ordered_en_5_w;
  wire                                reg_arba5_rdwr_ordered_en_5_w;
  wire [1:0]                          reg_arba_data_bus_width_5_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_5_w;

  wire                                reg_arb_port_data_channel_5_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_5_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_5_w;
  wire                                reg_arb_wr_port_aging_en_5_w;
  wire                                reg_arb_rd_port_aging_en_5_w;
  wire                                reg_arb_wr_port_urgent_en_5_w;
  wire                                reg_arb_rd_port_urgent_en_5_w;

  wire                                raqb_pop_5_w;
  wire                                raqb_push_5_w;

  wire                                raqr_pop_5_w;
  wire                                raqr_push_5_w;
  wire                                raq_split_5_w;

  wire                                waq_pop_5_w;
  wire                                waq_push_5_w;
  wire                                waq_split_5_w;

  wire                                reg_arba6_port_en_6_w;
  wire                                reg_arba6_read_reorder_bypass_en_6_w;
  wire [(ARB_ID_6)-1:0]               reg_arba6_id_mask_6_w;
  wire [(ARB_ID_6)-1:0]               reg_arba6_id_value_6_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba6_rqos_map_level1_6_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba6_rqos_map_level2_6_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba6_rqos_map_region0_6_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba6_rqos_map_region1_6_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba6_rqos_map_region2_6_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_6_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_6_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba6_wqos_map_level1_6_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba6_wqos_map_level2_6_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba6_wqos_map_region0_6_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba6_wqos_map_region1_6_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba6_wqos_map_region2_6_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_6_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_6_w;

  wire                                reg_arb_rd_port_pagematch_en_6_w;
  wire                                reg_arb_wr_port_pagematch_en_6_w;

  wire                                reg_arb_rdwr_ordered_en_6_w;
  wire                                reg_arba6_rdwr_ordered_en_6_w;
  wire [1:0]                          reg_arba_data_bus_width_6_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_6_w;

  wire                                reg_arb_port_data_channel_6_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_6_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_6_w;
  wire                                reg_arb_wr_port_aging_en_6_w;
  wire                                reg_arb_rd_port_aging_en_6_w;
  wire                                reg_arb_wr_port_urgent_en_6_w;
  wire                                reg_arb_rd_port_urgent_en_6_w;

  wire                                raqb_pop_6_w;
  wire                                raqb_push_6_w;

  wire                                raqr_pop_6_w;
  wire                                raqr_push_6_w;
  wire                                raq_split_6_w;

  wire                                waq_pop_6_w;
  wire                                waq_push_6_w;
  wire                                waq_split_6_w;

  wire                                reg_arba7_port_en_7_w;
  wire                                reg_arba7_read_reorder_bypass_en_7_w;
  wire [(ARB_ID_7)-1:0]               reg_arba7_id_mask_7_w;
  wire [(ARB_ID_7)-1:0]               reg_arba7_id_value_7_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba7_rqos_map_level1_7_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba7_rqos_map_level2_7_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba7_rqos_map_region0_7_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba7_rqos_map_region1_7_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba7_rqos_map_region2_7_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_7_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_7_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba7_wqos_map_level1_7_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba7_wqos_map_level2_7_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba7_wqos_map_region0_7_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba7_wqos_map_region1_7_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba7_wqos_map_region2_7_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_7_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_7_w;

  wire                                reg_arb_rd_port_pagematch_en_7_w;
  wire                                reg_arb_wr_port_pagematch_en_7_w;

  wire                                reg_arb_rdwr_ordered_en_7_w;
  wire                                reg_arba7_rdwr_ordered_en_7_w;
  wire [1:0]                          reg_arba_data_bus_width_7_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_7_w;

  wire                                reg_arb_port_data_channel_7_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_7_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_7_w;
  wire                                reg_arb_wr_port_aging_en_7_w;
  wire                                reg_arb_rd_port_aging_en_7_w;
  wire                                reg_arb_wr_port_urgent_en_7_w;
  wire                                reg_arb_rd_port_urgent_en_7_w;

  wire                                raqb_pop_7_w;
  wire                                raqb_push_7_w;

  wire                                raqr_pop_7_w;
  wire                                raqr_push_7_w;
  wire                                raq_split_7_w;

  wire                                waq_pop_7_w;
  wire                                waq_push_7_w;
  wire                                waq_split_7_w;

  wire                                reg_arba8_port_en_8_w;
  wire                                reg_arba8_read_reorder_bypass_en_8_w;
  wire [(ARB_ID_8)-1:0]               reg_arba8_id_mask_8_w;
  wire [(ARB_ID_8)-1:0]               reg_arba8_id_value_8_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba8_rqos_map_level1_8_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba8_rqos_map_level2_8_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba8_rqos_map_region0_8_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba8_rqos_map_region1_8_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba8_rqos_map_region2_8_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_8_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_8_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba8_wqos_map_level1_8_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba8_wqos_map_level2_8_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba8_wqos_map_region0_8_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba8_wqos_map_region1_8_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba8_wqos_map_region2_8_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_8_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_8_w;

  wire                                reg_arb_rd_port_pagematch_en_8_w;
  wire                                reg_arb_wr_port_pagematch_en_8_w;

  wire                                reg_arb_rdwr_ordered_en_8_w;
  wire                                reg_arba8_rdwr_ordered_en_8_w;
  wire [1:0]                          reg_arba_data_bus_width_8_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_8_w;

  wire                                reg_arb_port_data_channel_8_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_8_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_8_w;
  wire                                reg_arb_wr_port_aging_en_8_w;
  wire                                reg_arb_rd_port_aging_en_8_w;
  wire                                reg_arb_wr_port_urgent_en_8_w;
  wire                                reg_arb_rd_port_urgent_en_8_w;

  wire                                raqb_pop_8_w;
  wire                                raqb_push_8_w;

  wire                                raqr_pop_8_w;
  wire                                raqr_push_8_w;
  wire                                raq_split_8_w;

  wire                                waq_pop_8_w;
  wire                                waq_push_8_w;
  wire                                waq_split_8_w;

  wire                                reg_arba9_port_en_9_w;
  wire                                reg_arba9_read_reorder_bypass_en_9_w;
  wire [(ARB_ID_9)-1:0]               reg_arba9_id_mask_9_w;
  wire [(ARB_ID_9)-1:0]               reg_arba9_id_value_9_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba9_rqos_map_level1_9_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba9_rqos_map_level2_9_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba9_rqos_map_region0_9_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba9_rqos_map_region1_9_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba9_rqos_map_region2_9_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_9_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_9_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba9_wqos_map_level1_9_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba9_wqos_map_level2_9_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba9_wqos_map_region0_9_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba9_wqos_map_region1_9_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba9_wqos_map_region2_9_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_9_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_9_w;

  wire                                reg_arb_rd_port_pagematch_en_9_w;
  wire                                reg_arb_wr_port_pagematch_en_9_w;

  wire                                reg_arb_rdwr_ordered_en_9_w;
  wire                                reg_arba9_rdwr_ordered_en_9_w;
  wire [1:0]                          reg_arba_data_bus_width_9_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_9_w;

  wire                                reg_arb_port_data_channel_9_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_9_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_9_w;
  wire                                reg_arb_wr_port_aging_en_9_w;
  wire                                reg_arb_rd_port_aging_en_9_w;
  wire                                reg_arb_wr_port_urgent_en_9_w;
  wire                                reg_arb_rd_port_urgent_en_9_w;

  wire                                raqb_pop_9_w;
  wire                                raqb_push_9_w;

  wire                                raqr_pop_9_w;
  wire                                raqr_push_9_w;
  wire                                raq_split_9_w;

  wire                                waq_pop_9_w;
  wire                                waq_push_9_w;
  wire                                waq_split_9_w;

  wire                                reg_arba10_port_en_10_w;
  wire                                reg_arba10_read_reorder_bypass_en_10_w;
  wire [(ARB_ID_10)-1:0]               reg_arba10_id_mask_10_w;
  wire [(ARB_ID_10)-1:0]               reg_arba10_id_value_10_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba10_rqos_map_level1_10_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba10_rqos_map_level2_10_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba10_rqos_map_region0_10_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba10_rqos_map_region1_10_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba10_rqos_map_region2_10_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_10_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_10_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba10_wqos_map_level1_10_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba10_wqos_map_level2_10_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba10_wqos_map_region0_10_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba10_wqos_map_region1_10_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba10_wqos_map_region2_10_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_10_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_10_w;

  wire                                reg_arb_rd_port_pagematch_en_10_w;
  wire                                reg_arb_wr_port_pagematch_en_10_w;

  wire                                reg_arb_rdwr_ordered_en_10_w;
  wire                                reg_arba10_rdwr_ordered_en_10_w;
  wire [1:0]                          reg_arba_data_bus_width_10_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_10_w;

  wire                                reg_arb_port_data_channel_10_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_10_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_10_w;
  wire                                reg_arb_wr_port_aging_en_10_w;
  wire                                reg_arb_rd_port_aging_en_10_w;
  wire                                reg_arb_wr_port_urgent_en_10_w;
  wire                                reg_arb_rd_port_urgent_en_10_w;

  wire                                raqb_pop_10_w;
  wire                                raqb_push_10_w;

  wire                                raqr_pop_10_w;
  wire                                raqr_push_10_w;
  wire                                raq_split_10_w;

  wire                                waq_pop_10_w;
  wire                                waq_push_10_w;
  wire                                waq_split_10_w;

  wire                                reg_arba11_port_en_11_w;
  wire                                reg_arba11_read_reorder_bypass_en_11_w;
  wire [(ARB_ID_11)-1:0]               reg_arba11_id_mask_11_w;
  wire [(ARB_ID_11)-1:0]               reg_arba11_id_value_11_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba11_rqos_map_level1_11_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba11_rqos_map_level2_11_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba11_rqos_map_region0_11_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba11_rqos_map_region1_11_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba11_rqos_map_region2_11_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_11_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_11_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba11_wqos_map_level1_11_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba11_wqos_map_level2_11_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba11_wqos_map_region0_11_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba11_wqos_map_region1_11_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba11_wqos_map_region2_11_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_11_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_11_w;

  wire                                reg_arb_rd_port_pagematch_en_11_w;
  wire                                reg_arb_wr_port_pagematch_en_11_w;

  wire                                reg_arb_rdwr_ordered_en_11_w;
  wire                                reg_arba11_rdwr_ordered_en_11_w;
  wire [1:0]                          reg_arba_data_bus_width_11_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_11_w;

  wire                                reg_arb_port_data_channel_11_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_11_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_11_w;
  wire                                reg_arb_wr_port_aging_en_11_w;
  wire                                reg_arb_rd_port_aging_en_11_w;
  wire                                reg_arb_wr_port_urgent_en_11_w;
  wire                                reg_arb_rd_port_urgent_en_11_w;

  wire                                raqb_pop_11_w;
  wire                                raqb_push_11_w;

  wire                                raqr_pop_11_w;
  wire                                raqr_push_11_w;
  wire                                raq_split_11_w;

  wire                                waq_pop_11_w;
  wire                                waq_push_11_w;
  wire                                waq_split_11_w;

  wire                                reg_arba12_port_en_12_w;
  wire                                reg_arba12_read_reorder_bypass_en_12_w;
  wire [(ARB_ID_12)-1:0]               reg_arba12_id_mask_12_w;
  wire [(ARB_ID_12)-1:0]               reg_arba12_id_value_12_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba12_rqos_map_level1_12_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba12_rqos_map_level2_12_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba12_rqos_map_region0_12_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba12_rqos_map_region1_12_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba12_rqos_map_region2_12_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_12_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_12_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba12_wqos_map_level1_12_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba12_wqos_map_level2_12_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba12_wqos_map_region0_12_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba12_wqos_map_region1_12_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba12_wqos_map_region2_12_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_12_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_12_w;

  wire                                reg_arb_rd_port_pagematch_en_12_w;
  wire                                reg_arb_wr_port_pagematch_en_12_w;

  wire                                reg_arb_rdwr_ordered_en_12_w;
  wire                                reg_arba12_rdwr_ordered_en_12_w;
  wire [1:0]                          reg_arba_data_bus_width_12_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_12_w;

  wire                                reg_arb_port_data_channel_12_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_12_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_12_w;
  wire                                reg_arb_wr_port_aging_en_12_w;
  wire                                reg_arb_rd_port_aging_en_12_w;
  wire                                reg_arb_wr_port_urgent_en_12_w;
  wire                                reg_arb_rd_port_urgent_en_12_w;

  wire                                raqb_pop_12_w;
  wire                                raqb_push_12_w;

  wire                                raqr_pop_12_w;
  wire                                raqr_push_12_w;
  wire                                raq_split_12_w;

  wire                                waq_pop_12_w;
  wire                                waq_push_12_w;
  wire                                waq_split_12_w;

  wire                                reg_arba13_port_en_13_w;
  wire                                reg_arba13_read_reorder_bypass_en_13_w;
  wire [(ARB_ID_13)-1:0]               reg_arba13_id_mask_13_w;
  wire [(ARB_ID_13)-1:0]               reg_arba13_id_value_13_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba13_rqos_map_level1_13_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba13_rqos_map_level2_13_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba13_rqos_map_region0_13_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba13_rqos_map_region1_13_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba13_rqos_map_region2_13_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_13_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_13_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba13_wqos_map_level1_13_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba13_wqos_map_level2_13_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba13_wqos_map_region0_13_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba13_wqos_map_region1_13_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba13_wqos_map_region2_13_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_13_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_13_w;

  wire                                reg_arb_rd_port_pagematch_en_13_w;
  wire                                reg_arb_wr_port_pagematch_en_13_w;

  wire                                reg_arb_rdwr_ordered_en_13_w;
  wire                                reg_arba13_rdwr_ordered_en_13_w;
  wire [1:0]                          reg_arba_data_bus_width_13_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_13_w;

  wire                                reg_arb_port_data_channel_13_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_13_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_13_w;
  wire                                reg_arb_wr_port_aging_en_13_w;
  wire                                reg_arb_rd_port_aging_en_13_w;
  wire                                reg_arb_wr_port_urgent_en_13_w;
  wire                                reg_arb_rd_port_urgent_en_13_w;

  wire                                raqb_pop_13_w;
  wire                                raqb_push_13_w;

  wire                                raqr_pop_13_w;
  wire                                raqr_push_13_w;
  wire                                raq_split_13_w;

  wire                                waq_pop_13_w;
  wire                                waq_push_13_w;
  wire                                waq_split_13_w;

  wire                                reg_arba14_port_en_14_w;
  wire                                reg_arba14_read_reorder_bypass_en_14_w;
  wire [(ARB_ID_14)-1:0]               reg_arba14_id_mask_14_w;
  wire [(ARB_ID_14)-1:0]               reg_arba14_id_value_14_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba14_rqos_map_level1_14_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba14_rqos_map_level2_14_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba14_rqos_map_region0_14_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba14_rqos_map_region1_14_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba14_rqos_map_region2_14_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_14_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_14_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba14_wqos_map_level1_14_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba14_wqos_map_level2_14_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba14_wqos_map_region0_14_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba14_wqos_map_region1_14_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba14_wqos_map_region2_14_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_14_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_14_w;

  wire                                reg_arb_rd_port_pagematch_en_14_w;
  wire                                reg_arb_wr_port_pagematch_en_14_w;

  wire                                reg_arb_rdwr_ordered_en_14_w;
  wire                                reg_arba14_rdwr_ordered_en_14_w;
  wire [1:0]                          reg_arba_data_bus_width_14_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_14_w;

  wire                                reg_arb_port_data_channel_14_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_14_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_14_w;
  wire                                reg_arb_wr_port_aging_en_14_w;
  wire                                reg_arb_rd_port_aging_en_14_w;
  wire                                reg_arb_wr_port_urgent_en_14_w;
  wire                                reg_arb_rd_port_urgent_en_14_w;

  wire                                raqb_pop_14_w;
  wire                                raqb_push_14_w;

  wire                                raqr_pop_14_w;
  wire                                raqr_push_14_w;
  wire                                raq_split_14_w;

  wire                                waq_pop_14_w;
  wire                                waq_push_14_w;
  wire                                waq_split_14_w;

  wire                                reg_arba15_port_en_15_w;
  wire                                reg_arba15_read_reorder_bypass_en_15_w;
  wire [(ARB_ID_15)-1:0]               reg_arba15_id_mask_15_w;
  wire [(ARB_ID_15)-1:0]               reg_arba15_id_value_15_w;

  wire [XPI_RQOS_MLW-1:0]             reg_arba15_rqos_map_level1_15_w;
  wire [XPI_RQOS_MLW-1:0]             reg_arba15_rqos_map_level2_15_w;

  wire [XPI_RQOS_RW-1:0]              reg_arba15_rqos_map_region0_15_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba15_rqos_map_region1_15_w;
  wire [XPI_RQOS_RW-1:0]              reg_arba15_rqos_map_region2_15_w;

  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutb_15_w;
  wire [HIF_RQOS_TW-1:0]              reg_arb_rqos_map_timeoutr_15_w;

  wire [XPI_WQOS_MLW-1:0]             reg_arba15_wqos_map_level1_15_w;
  wire [XPI_WQOS_MLW-1:0]             reg_arba15_wqos_map_level2_15_w;

  wire [XPI_WQOS_RW-1:0]              reg_arba15_wqos_map_region0_15_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba15_wqos_map_region1_15_w;
  wire [XPI_WQOS_RW-1:0]              reg_arba15_wqos_map_region2_15_w;

  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout1_15_w;
  wire [HIF_WQOS_TW-1:0]              reg_arb_wqos_map_timeout2_15_w;

  wire                                reg_arb_rd_port_pagematch_en_15_w;
  wire                                reg_arb_wr_port_pagematch_en_15_w;

  wire                                reg_arb_rdwr_ordered_en_15_w;
  wire                                reg_arba15_rdwr_ordered_en_15_w;
  wire [1:0]                          reg_arba_data_bus_width_15_w;

  wire [RRB_LOCK_THRESHOLD_WIDTH-1:0]  reg_arb_rrb_lock_threshold_15_w;

  wire                                reg_arb_port_data_channel_15_w;

  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_wr_port_priority_15_w;
  wire [REG_PORT_PRIORITYW-1:0]       reg_arb_rd_port_priority_15_w;
  wire                                reg_arb_wr_port_aging_en_15_w;
  wire                                reg_arb_rd_port_aging_en_15_w;
  wire                                reg_arb_wr_port_urgent_en_15_w;
  wire                                reg_arb_rd_port_urgent_en_15_w;

  wire                                raqb_pop_15_w;
  wire                                raqb_push_15_w;

  wire                                raqr_pop_15_w;
  wire                                raqr_push_15_w;
  wire                                raq_split_15_w;

  wire                                waq_pop_15_w;
  wire                                waq_push_15_w;
  wire                                waq_split_15_w;



















//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((AXI_RESPW * (2 + 1)) - 1)' found in module 'DWC_ddrctl'
//SJ: This coding style (such as "assign bresp_$_w = bresp_vector_ext[AXI_RESPW*($+1)-1:AXI_RESPW*$];") is acceptable and there is no plan to change it.

   assign aclk_0_w                      = aclk_0;
   assign aresetn_0_w                   = aresetn_0;

   assign reg_arb_wr_port_urgent_en_0_w = reg_arb_wr_port_urgent_en_port0;
   assign reg_arb_rd_port_urgent_en_0_w = reg_arb_rd_port_urgent_en_port0;
   assign reg_arb_wr_port_aging_en_0_w  = reg_arb_wr_port_aging_en_port0;
   assign reg_arb_rd_port_aging_en_0_w  = reg_arb_rd_port_aging_en_port0;
   assign reg_arb_wr_port_priority_0_w  = reg_arb_wr_port_priority_port0;
   assign reg_arb_rd_port_priority_0_w  = reg_arb_rd_port_priority_port0;

   assign sync_aresetn_0_w              = sync_aresetn_0;
   assign reg_arba0_id_mask_0_w         = reg_arba0_id_mask_0;
   assign reg_arba0_id_value_0_w        = reg_arba0_id_value_0;

   assign csysack_xpi_0                 = csysack_xpi_vector[0];  //output port, no "`else"

   assign arb_reg_rd_port_busy_0_port0        = rd_port_busy[0];
   assign arb_reg_wr_port_busy_0_port0        = wr_port_busy[0];

   //ocecc input vectors
   assign ocecc_en_aclk_vector[0]                    = ocecc_en_aclk_0;
   assign ocecc_poison_egen_mr_rd_0_vector[0]        = ocecc_poison_egen_mr_rd_0_0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(0+1)-1 -: OCECC_MR_BNUM_WIDTH] = ocecc_poison_egen_mr_rd_0_byte_num_0;
   assign ocecc_poison_egen_xpi_rd_out_vector[0]     = ocecc_poison_egen_xpi_rd_out_0;
   assign ocecc_poison_single_vector[0]              = ocecc_poison_single_0;
   assign ocecc_wdata_slverr_en_vector[0]            = ocecc_wdata_slverr_en_0;
   assign ocecc_rdata_slverr_en_vector[0]            = ocecc_rdata_slverr_en_0;

   assign aclk_1_w                      = 1'b0;
   assign aresetn_1_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_1_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_1_w = 1'b0;
   assign reg_arb_wr_port_aging_en_1_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_1_w  = 1'b0;
   assign reg_arb_wr_port_priority_1_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_1_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_1_w              = 1'b1;
   assign reg_arba1_id_mask_1_w         = {ARB_ID_0{1'b0}};
   assign reg_arba1_id_value_1_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[1]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[1]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(1+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[1]  = 1'b0;
   assign ocecc_poison_single_vector[1]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[1]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[1]         = 1'b0;

   assign aclk_2_w                      = 1'b0;
   assign aresetn_2_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_2_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_2_w = 1'b0;
   assign reg_arb_wr_port_aging_en_2_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_2_w  = 1'b0;
   assign reg_arb_wr_port_priority_2_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_2_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_2_w              = 1'b1;
   assign reg_arba2_id_mask_2_w         = {ARB_ID_0{1'b0}};
   assign reg_arba2_id_value_2_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[2]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[2]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(2+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[2]  = 1'b0;
   assign ocecc_poison_single_vector[2]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[2]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[2]         = 1'b0;

   assign aclk_3_w                      = 1'b0;
   assign aresetn_3_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_3_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_3_w = 1'b0;
   assign reg_arb_wr_port_aging_en_3_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_3_w  = 1'b0;
   assign reg_arb_wr_port_priority_3_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_3_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_3_w              = 1'b1;
   assign reg_arba3_id_mask_3_w         = {ARB_ID_0{1'b0}};
   assign reg_arba3_id_value_3_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[3]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[3]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(3+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[3]  = 1'b0;
   assign ocecc_poison_single_vector[3]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[3]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[3]         = 1'b0;

   assign aclk_4_w                      = 1'b0;
   assign aresetn_4_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_4_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_4_w = 1'b0;
   assign reg_arb_wr_port_aging_en_4_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_4_w  = 1'b0;
   assign reg_arb_wr_port_priority_4_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_4_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_4_w              = 1'b1;
   assign reg_arba4_id_mask_4_w         = {ARB_ID_0{1'b0}};
   assign reg_arba4_id_value_4_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[4]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[4]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(4+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[4]  = 1'b0;
   assign ocecc_poison_single_vector[4]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[4]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[4]         = 1'b0;

   assign aclk_5_w                      = 1'b0;
   assign aresetn_5_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_5_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_5_w = 1'b0;
   assign reg_arb_wr_port_aging_en_5_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_5_w  = 1'b0;
   assign reg_arb_wr_port_priority_5_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_5_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_5_w              = 1'b1;
   assign reg_arba5_id_mask_5_w         = {ARB_ID_0{1'b0}};
   assign reg_arba5_id_value_5_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[5]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[5]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(5+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[5]  = 1'b0;
   assign ocecc_poison_single_vector[5]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[5]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[5]         = 1'b0;

   assign aclk_6_w                      = 1'b0;
   assign aresetn_6_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_6_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_6_w = 1'b0;
   assign reg_arb_wr_port_aging_en_6_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_6_w  = 1'b0;
   assign reg_arb_wr_port_priority_6_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_6_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_6_w              = 1'b1;
   assign reg_arba6_id_mask_6_w         = {ARB_ID_0{1'b0}};
   assign reg_arba6_id_value_6_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[6]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[6]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(6+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[6]  = 1'b0;
   assign ocecc_poison_single_vector[6]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[6]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[6]         = 1'b0;

   assign aclk_7_w                      = 1'b0;
   assign aresetn_7_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_7_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_7_w = 1'b0;
   assign reg_arb_wr_port_aging_en_7_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_7_w  = 1'b0;
   assign reg_arb_wr_port_priority_7_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_7_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_7_w              = 1'b1;
   assign reg_arba7_id_mask_7_w         = {ARB_ID_0{1'b0}};
   assign reg_arba7_id_value_7_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[7]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[7]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(7+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[7]  = 1'b0;
   assign ocecc_poison_single_vector[7]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[7]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[7]         = 1'b0;

   assign aclk_8_w                      = 1'b0;
   assign aresetn_8_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_8_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_8_w = 1'b0;
   assign reg_arb_wr_port_aging_en_8_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_8_w  = 1'b0;
   assign reg_arb_wr_port_priority_8_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_8_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_8_w              = 1'b1;
   assign reg_arba8_id_mask_8_w         = {ARB_ID_0{1'b0}};
   assign reg_arba8_id_value_8_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[8]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[8]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(8+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[8]  = 1'b0;
   assign ocecc_poison_single_vector[8]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[8]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[8]         = 1'b0;

   assign aclk_9_w                      = 1'b0;
   assign aresetn_9_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_9_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_9_w = 1'b0;
   assign reg_arb_wr_port_aging_en_9_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_9_w  = 1'b0;
   assign reg_arb_wr_port_priority_9_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_9_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_9_w              = 1'b1;
   assign reg_arba9_id_mask_9_w         = {ARB_ID_0{1'b0}};
   assign reg_arba9_id_value_9_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[9]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[9]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(9+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[9]  = 1'b0;
   assign ocecc_poison_single_vector[9]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[9]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[9]         = 1'b0;

   assign aclk_10_w                      = 1'b0;
   assign aresetn_10_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_10_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_10_w = 1'b0;
   assign reg_arb_wr_port_aging_en_10_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_10_w  = 1'b0;
   assign reg_arb_wr_port_priority_10_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_10_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_10_w              = 1'b1;
   assign reg_arba10_id_mask_10_w         = {ARB_ID_0{1'b0}};
   assign reg_arba10_id_value_10_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[10]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[10]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(10+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[10]  = 1'b0;
   assign ocecc_poison_single_vector[10]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[10]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[10]         = 1'b0;

   assign aclk_11_w                      = 1'b0;
   assign aresetn_11_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_11_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_11_w = 1'b0;
   assign reg_arb_wr_port_aging_en_11_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_11_w  = 1'b0;
   assign reg_arb_wr_port_priority_11_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_11_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_11_w              = 1'b1;
   assign reg_arba11_id_mask_11_w         = {ARB_ID_0{1'b0}};
   assign reg_arba11_id_value_11_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[11]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[11]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(11+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[11]  = 1'b0;
   assign ocecc_poison_single_vector[11]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[11]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[11]         = 1'b0;

   assign aclk_12_w                      = 1'b0;
   assign aresetn_12_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_12_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_12_w = 1'b0;
   assign reg_arb_wr_port_aging_en_12_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_12_w  = 1'b0;
   assign reg_arb_wr_port_priority_12_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_12_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_12_w              = 1'b1;
   assign reg_arba12_id_mask_12_w         = {ARB_ID_0{1'b0}};
   assign reg_arba12_id_value_12_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[12]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[12]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(12+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[12]  = 1'b0;
   assign ocecc_poison_single_vector[12]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[12]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[12]         = 1'b0;

   assign aclk_13_w                      = 1'b0;
   assign aresetn_13_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_13_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_13_w = 1'b0;
   assign reg_arb_wr_port_aging_en_13_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_13_w  = 1'b0;
   assign reg_arb_wr_port_priority_13_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_13_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_13_w              = 1'b1;
   assign reg_arba13_id_mask_13_w         = {ARB_ID_0{1'b0}};
   assign reg_arba13_id_value_13_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[13]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[13]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(13+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[13]  = 1'b0;
   assign ocecc_poison_single_vector[13]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[13]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[13]         = 1'b0;

   assign aclk_14_w                      = 1'b0;
   assign aresetn_14_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_14_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_14_w = 1'b0;
   assign reg_arb_wr_port_aging_en_14_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_14_w  = 1'b0;
   assign reg_arb_wr_port_priority_14_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_14_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_14_w              = 1'b1;
   assign reg_arba14_id_mask_14_w         = {ARB_ID_0{1'b0}};
   assign reg_arba14_id_value_14_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[14]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[14]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(14+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[14]  = 1'b0;
   assign ocecc_poison_single_vector[14]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[14]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[14]         = 1'b0;

   assign aclk_15_w                      = 1'b0;
   assign aresetn_15_w                   = 1'b0;

   assign reg_arb_wr_port_urgent_en_15_w = 1'b0;
   assign reg_arb_rd_port_urgent_en_15_w = 1'b0;
   assign reg_arb_wr_port_aging_en_15_w  = 1'b0;
   assign reg_arb_rd_port_aging_en_15_w  = 1'b0;
   assign reg_arb_wr_port_priority_15_w  = {REG_PORT_PRIORITYW{1'b0}};
   assign reg_arb_rd_port_priority_15_w  = {REG_PORT_PRIORITYW{1'b0}};

   assign sync_aresetn_15_w              = 1'b1;
   assign reg_arba15_id_mask_15_w         = {ARB_ID_0{1'b0}};
   assign reg_arba15_id_value_15_w        = {ARB_ID_0{1'b0}};

   //ocecc input vectors
   assign ocecc_en_aclk_vector[15]                 = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_vector[15]     = 1'b0;
   assign ocecc_poison_egen_mr_rd_0_byte_num_vector[OCECC_MR_BNUM_WIDTH*(15+1)-1 -: OCECC_MR_BNUM_WIDTH] = {OCECC_MR_BNUM_WIDTH{1'b0}};
   assign ocecc_poison_egen_xpi_rd_out_vector[15]  = 1'b0;
   assign ocecc_poison_single_vector[15]           = 1'b0;
   assign ocecc_wdata_slverr_en_vector[15]         = 1'b0;
   assign ocecc_rdata_slverr_en_vector[15]         = 1'b0;



 // AXI Input Ports
     // AW Channel
     assign csysreq_xpi_0_w         = csysreq_xpi_0;
     assign awid_0_w                = xpi_awid_0;
     assign awaddr_0_w              = aw_axi_addr_0;
     assign awlen_0_w               = awlen_0;
     assign awsize_0_w              = awsize_0;
     assign awburst_0_w             = awburst_0;
     assign awlock_0_w              = awlock_0;
     assign awcache_0_w             = awcache_0;
     assign awprot_0_w              = awprot_0;
     assign awqos_0_w               = awqos_0;
     assign awurgent_0_w            = awurgent_0;
     assign awpoison_0_w            = awpoison_0;
     assign awautopre_0_w           = awautopre_0;
     assign awvalid_0_w             = awvalid_0;

     // W Channel
     assign wdata_0_w               = wdata_0;
     assign wid_0_w                 = xpi_wid_0; //No need to check if AXI4 or not, it's done at beginning
     assign wstrb_0_w               = wstrb_0;
     assign wlast_0_w               = wlast_0;
     assign wvalid_0_w              = wvalid_0;

     // B Channel
     assign bready_0_w              = bready_0;

     // AR Channel
     assign arid_0_w                = xpi_arid_0;
     assign araddr_0_w              = ar_axi_addr_0;
     assign arlen_0_w               = arlen_0;
     assign arsize_0_w              = arsize_0;
     assign arburst_0_w             = arburst_0;
     assign arlock_0_w              = arlock_0;
     assign arcache_0_w             = arcache_0;
     assign arprot_0_w              = arprot_0;
     assign arqos_0_w               = arqos_0;
     assign arurgentb_0_w           = arurgentb_0;
     assign arurgentr_0_w           = arurgentr_0;
     assign arpoison_0_w            = arpoison_0;
     assign arautopre_0_w           = arautopre_0;
     assign arvalid_0_w             = arvalid_0;

     // R Channel
     assign rready_0_w              = rready_0;

 // AXI Output Port
    //AW
    assign awready_0               = awready_vector[0];

     //W
    assign wready_0                = wready_vector[0];

     //B
    assign bid_0                   = bid_vector[AXI_IDW*(0+1)-1:AXI_IDW*0];
    assign bresp_0                 = bresp_vector[AXI_RESPW*(0+1)-1:AXI_RESPW*0];
    assign bvalid_0                = bvalid_vector[0];

     //AR
    assign arready_0               = arready_vector[0];  // output no else

     //R
    assign rid_0                   = rid_vector[AXI_IDW*(0+1)-1:AXI_IDW*0];
    assign rdata_0                 = rdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(0+2)-1:AXI_DW_NB*(0+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(0+1)-1:AXI_DW_NB*0]];
    assign rresp_0                 = rresp_vector[AXI_RESPW*(0+1)-1:AXI_RESPW*0];
    assign rlast_0                 = rlast_vector[0];
    assign rvalid_0                = rvalid_vector[0];

    // Misc
    assign raqb_pop_0              = raqb_pop_vector[0];
    assign raqb_push_0             = raqb_push_vector[0];
    assign raqr_pop_0              = raqr_pop_vector[0];
    assign raqr_push_0             = raqr_push_vector[0];
    assign raq_split_0             = raq_split_vector[0];
    assign waq_pop_0               = waq_pop_vector[0];
    assign waq_push_0              = waq_push_vector[0];
    assign waq_split_0             = waq_split_vector[0];

    assign ddrc_reg_wr_poison_intr_0 = wr_poison_intr[0];
    assign ddrc_reg_rd_poison_intr_0 = rd_poison_intr[0];


     // AW Channel
     assign csysreq_xpi_1_w         = 1'b1;
     assign awid_1_w                = {AXI_IDW{1'b0}};
     assign awaddr_1_w              = {AXI_ADDRW{1'b0}};
     assign awlen_1_w               = {AXI_LENW{1'b0}};
     assign awsize_1_w              = {AXI_SIZEW{1'b0}};
     assign awburst_1_w             = {AXI_BURSTW{1'b0}};
     assign awlock_1_w              = {`UMCTL2_AXI_LOCK_WIDTH_1{1'b0}};
     assign awcache_1_w             = {AXI_CACHEW{1'b0}};
     assign awprot_1_w              = {AXI_PROTW{1'b0}};
     assign awqos_1_w               = {AXI_QOSW{1'b0}};
     assign awurgent_1_w            = {1'b0};
     assign awpoison_1_w            = {1'b0};
     assign awautopre_1_w           = {1'b0};
     assign awvalid_1_w             = {1'b0};

      // W Channel
     assign wdata_1_w               = {`UMCTL2_PORT_DW_1{1'b0}};
     assign wid_1_w                 = {AXI_IDW{1'b0}};
     assign wstrb_1_w               = {`UMCTL2_PORT_NBYTES_1{1'b0}};
     assign wlast_1_w               = {1'b0};
     assign wvalid_1_w              = {1'b0};

      // B Channel
     assign bready_1_w              = {1'b0};

      // AR Channel
     assign arid_1_w                = {AXI_IDW{1'b0}};
     assign araddr_1_w              = {AXI_ADDRW{1'b0}};
     assign arlen_1_w               = {AXI_LENW{1'b0}};
     assign arsize_1_w              = {AXI_SIZEW{1'b0}};
     assign arburst_1_w             = {AXI_BURSTW{1'b0}};
     assign arlock_1_w              = {`UMCTL2_AXI_LOCK_WIDTH_1{1'b0}};
     assign arcache_1_w             = {AXI_CACHEW{1'b0}};
     assign arprot_1_w              = {AXI_PROTW{1'b0}};
     assign arqos_1_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_1_w           = {1'b0};
     assign arurgentr_1_w           = {1'b0};
     assign arpoison_1_w            = {1'b0};
     assign arautopre_1_w           = {1'b0};
     assign arvalid_1_w             = {1'b0};

      // R Channel
     assign rready_1_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_2_w         = 1'b1;
     assign awid_2_w                = {AXI_IDW{1'b0}};
     assign awaddr_2_w              = {AXI_ADDRW{1'b0}};
     assign awlen_2_w               = {AXI_LENW{1'b0}};
     assign awsize_2_w              = {AXI_SIZEW{1'b0}};
     assign awburst_2_w             = {AXI_BURSTW{1'b0}};
     assign awlock_2_w              = {`UMCTL2_AXI_LOCK_WIDTH_2{1'b0}};
     assign awcache_2_w             = {AXI_CACHEW{1'b0}};
     assign awprot_2_w              = {AXI_PROTW{1'b0}};
     assign awqos_2_w               = {AXI_QOSW{1'b0}};
     assign awurgent_2_w            = {1'b0};
     assign awpoison_2_w            = {1'b0};
     assign awautopre_2_w           = {1'b0};
     assign awvalid_2_w             = {1'b0};

      // W Channel
     assign wdata_2_w               = {`UMCTL2_PORT_DW_2{1'b0}};
     assign wid_2_w                 = {AXI_IDW{1'b0}};
     assign wstrb_2_w               = {`UMCTL2_PORT_NBYTES_2{1'b0}};
     assign wlast_2_w               = {1'b0};
     assign wvalid_2_w              = {1'b0};

      // B Channel
     assign bready_2_w              = {1'b0};

      // AR Channel
     assign arid_2_w                = {AXI_IDW{1'b0}};
     assign araddr_2_w              = {AXI_ADDRW{1'b0}};
     assign arlen_2_w               = {AXI_LENW{1'b0}};
     assign arsize_2_w              = {AXI_SIZEW{1'b0}};
     assign arburst_2_w             = {AXI_BURSTW{1'b0}};
     assign arlock_2_w              = {`UMCTL2_AXI_LOCK_WIDTH_2{1'b0}};
     assign arcache_2_w             = {AXI_CACHEW{1'b0}};
     assign arprot_2_w              = {AXI_PROTW{1'b0}};
     assign arqos_2_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_2_w           = {1'b0};
     assign arurgentr_2_w           = {1'b0};
     assign arpoison_2_w            = {1'b0};
     assign arautopre_2_w           = {1'b0};
     assign arvalid_2_w             = {1'b0};

      // R Channel
     assign rready_2_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_3_w         = 1'b1;
     assign awid_3_w                = {AXI_IDW{1'b0}};
     assign awaddr_3_w              = {AXI_ADDRW{1'b0}};
     assign awlen_3_w               = {AXI_LENW{1'b0}};
     assign awsize_3_w              = {AXI_SIZEW{1'b0}};
     assign awburst_3_w             = {AXI_BURSTW{1'b0}};
     assign awlock_3_w              = {`UMCTL2_AXI_LOCK_WIDTH_3{1'b0}};
     assign awcache_3_w             = {AXI_CACHEW{1'b0}};
     assign awprot_3_w              = {AXI_PROTW{1'b0}};
     assign awqos_3_w               = {AXI_QOSW{1'b0}};
     assign awurgent_3_w            = {1'b0};
     assign awpoison_3_w            = {1'b0};
     assign awautopre_3_w           = {1'b0};
     assign awvalid_3_w             = {1'b0};

      // W Channel
     assign wdata_3_w               = {`UMCTL2_PORT_DW_3{1'b0}};
     assign wid_3_w                 = {AXI_IDW{1'b0}};
     assign wstrb_3_w               = {`UMCTL2_PORT_NBYTES_3{1'b0}};
     assign wlast_3_w               = {1'b0};
     assign wvalid_3_w              = {1'b0};

      // B Channel
     assign bready_3_w              = {1'b0};

      // AR Channel
     assign arid_3_w                = {AXI_IDW{1'b0}};
     assign araddr_3_w              = {AXI_ADDRW{1'b0}};
     assign arlen_3_w               = {AXI_LENW{1'b0}};
     assign arsize_3_w              = {AXI_SIZEW{1'b0}};
     assign arburst_3_w             = {AXI_BURSTW{1'b0}};
     assign arlock_3_w              = {`UMCTL2_AXI_LOCK_WIDTH_3{1'b0}};
     assign arcache_3_w             = {AXI_CACHEW{1'b0}};
     assign arprot_3_w              = {AXI_PROTW{1'b0}};
     assign arqos_3_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_3_w           = {1'b0};
     assign arurgentr_3_w           = {1'b0};
     assign arpoison_3_w            = {1'b0};
     assign arautopre_3_w           = {1'b0};
     assign arvalid_3_w             = {1'b0};

      // R Channel
     assign rready_3_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_4_w         = 1'b1;
     assign awid_4_w                = {AXI_IDW{1'b0}};
     assign awaddr_4_w              = {AXI_ADDRW{1'b0}};
     assign awlen_4_w               = {AXI_LENW{1'b0}};
     assign awsize_4_w              = {AXI_SIZEW{1'b0}};
     assign awburst_4_w             = {AXI_BURSTW{1'b0}};
     assign awlock_4_w              = {`UMCTL2_AXI_LOCK_WIDTH_4{1'b0}};
     assign awcache_4_w             = {AXI_CACHEW{1'b0}};
     assign awprot_4_w              = {AXI_PROTW{1'b0}};
     assign awqos_4_w               = {AXI_QOSW{1'b0}};
     assign awurgent_4_w            = {1'b0};
     assign awpoison_4_w            = {1'b0};
     assign awautopre_4_w           = {1'b0};
     assign awvalid_4_w             = {1'b0};

      // W Channel
     assign wdata_4_w               = {`UMCTL2_PORT_DW_4{1'b0}};
     assign wid_4_w                 = {AXI_IDW{1'b0}};
     assign wstrb_4_w               = {`UMCTL2_PORT_NBYTES_4{1'b0}};
     assign wlast_4_w               = {1'b0};
     assign wvalid_4_w              = {1'b0};

      // B Channel
     assign bready_4_w              = {1'b0};

      // AR Channel
     assign arid_4_w                = {AXI_IDW{1'b0}};
     assign araddr_4_w              = {AXI_ADDRW{1'b0}};
     assign arlen_4_w               = {AXI_LENW{1'b0}};
     assign arsize_4_w              = {AXI_SIZEW{1'b0}};
     assign arburst_4_w             = {AXI_BURSTW{1'b0}};
     assign arlock_4_w              = {`UMCTL2_AXI_LOCK_WIDTH_4{1'b0}};
     assign arcache_4_w             = {AXI_CACHEW{1'b0}};
     assign arprot_4_w              = {AXI_PROTW{1'b0}};
     assign arqos_4_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_4_w           = {1'b0};
     assign arurgentr_4_w           = {1'b0};
     assign arpoison_4_w            = {1'b0};
     assign arautopre_4_w           = {1'b0};
     assign arvalid_4_w             = {1'b0};

      // R Channel
     assign rready_4_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_5_w         = 1'b1;
     assign awid_5_w                = {AXI_IDW{1'b0}};
     assign awaddr_5_w              = {AXI_ADDRW{1'b0}};
     assign awlen_5_w               = {AXI_LENW{1'b0}};
     assign awsize_5_w              = {AXI_SIZEW{1'b0}};
     assign awburst_5_w             = {AXI_BURSTW{1'b0}};
     assign awlock_5_w              = {`UMCTL2_AXI_LOCK_WIDTH_5{1'b0}};
     assign awcache_5_w             = {AXI_CACHEW{1'b0}};
     assign awprot_5_w              = {AXI_PROTW{1'b0}};
     assign awqos_5_w               = {AXI_QOSW{1'b0}};
     assign awurgent_5_w            = {1'b0};
     assign awpoison_5_w            = {1'b0};
     assign awautopre_5_w           = {1'b0};
     assign awvalid_5_w             = {1'b0};

      // W Channel
     assign wdata_5_w               = {`UMCTL2_PORT_DW_5{1'b0}};
     assign wid_5_w                 = {AXI_IDW{1'b0}};
     assign wstrb_5_w               = {`UMCTL2_PORT_NBYTES_5{1'b0}};
     assign wlast_5_w               = {1'b0};
     assign wvalid_5_w              = {1'b0};

      // B Channel
     assign bready_5_w              = {1'b0};

      // AR Channel
     assign arid_5_w                = {AXI_IDW{1'b0}};
     assign araddr_5_w              = {AXI_ADDRW{1'b0}};
     assign arlen_5_w               = {AXI_LENW{1'b0}};
     assign arsize_5_w              = {AXI_SIZEW{1'b0}};
     assign arburst_5_w             = {AXI_BURSTW{1'b0}};
     assign arlock_5_w              = {`UMCTL2_AXI_LOCK_WIDTH_5{1'b0}};
     assign arcache_5_w             = {AXI_CACHEW{1'b0}};
     assign arprot_5_w              = {AXI_PROTW{1'b0}};
     assign arqos_5_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_5_w           = {1'b0};
     assign arurgentr_5_w           = {1'b0};
     assign arpoison_5_w            = {1'b0};
     assign arautopre_5_w           = {1'b0};
     assign arvalid_5_w             = {1'b0};

      // R Channel
     assign rready_5_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_6_w         = 1'b1;
     assign awid_6_w                = {AXI_IDW{1'b0}};
     assign awaddr_6_w              = {AXI_ADDRW{1'b0}};
     assign awlen_6_w               = {AXI_LENW{1'b0}};
     assign awsize_6_w              = {AXI_SIZEW{1'b0}};
     assign awburst_6_w             = {AXI_BURSTW{1'b0}};
     assign awlock_6_w              = {`UMCTL2_AXI_LOCK_WIDTH_6{1'b0}};
     assign awcache_6_w             = {AXI_CACHEW{1'b0}};
     assign awprot_6_w              = {AXI_PROTW{1'b0}};
     assign awqos_6_w               = {AXI_QOSW{1'b0}};
     assign awurgent_6_w            = {1'b0};
     assign awpoison_6_w            = {1'b0};
     assign awautopre_6_w           = {1'b0};
     assign awvalid_6_w             = {1'b0};

      // W Channel
     assign wdata_6_w               = {`UMCTL2_PORT_DW_6{1'b0}};
     assign wid_6_w                 = {AXI_IDW{1'b0}};
     assign wstrb_6_w               = {`UMCTL2_PORT_NBYTES_6{1'b0}};
     assign wlast_6_w               = {1'b0};
     assign wvalid_6_w              = {1'b0};

      // B Channel
     assign bready_6_w              = {1'b0};

      // AR Channel
     assign arid_6_w                = {AXI_IDW{1'b0}};
     assign araddr_6_w              = {AXI_ADDRW{1'b0}};
     assign arlen_6_w               = {AXI_LENW{1'b0}};
     assign arsize_6_w              = {AXI_SIZEW{1'b0}};
     assign arburst_6_w             = {AXI_BURSTW{1'b0}};
     assign arlock_6_w              = {`UMCTL2_AXI_LOCK_WIDTH_6{1'b0}};
     assign arcache_6_w             = {AXI_CACHEW{1'b0}};
     assign arprot_6_w              = {AXI_PROTW{1'b0}};
     assign arqos_6_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_6_w           = {1'b0};
     assign arurgentr_6_w           = {1'b0};
     assign arpoison_6_w            = {1'b0};
     assign arautopre_6_w           = {1'b0};
     assign arvalid_6_w             = {1'b0};

      // R Channel
     assign rready_6_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_7_w         = 1'b1;
     assign awid_7_w                = {AXI_IDW{1'b0}};
     assign awaddr_7_w              = {AXI_ADDRW{1'b0}};
     assign awlen_7_w               = {AXI_LENW{1'b0}};
     assign awsize_7_w              = {AXI_SIZEW{1'b0}};
     assign awburst_7_w             = {AXI_BURSTW{1'b0}};
     assign awlock_7_w              = {`UMCTL2_AXI_LOCK_WIDTH_7{1'b0}};
     assign awcache_7_w             = {AXI_CACHEW{1'b0}};
     assign awprot_7_w              = {AXI_PROTW{1'b0}};
     assign awqos_7_w               = {AXI_QOSW{1'b0}};
     assign awurgent_7_w            = {1'b0};
     assign awpoison_7_w            = {1'b0};
     assign awautopre_7_w           = {1'b0};
     assign awvalid_7_w             = {1'b0};

      // W Channel
     assign wdata_7_w               = {`UMCTL2_PORT_DW_7{1'b0}};
     assign wid_7_w                 = {AXI_IDW{1'b0}};
     assign wstrb_7_w               = {`UMCTL2_PORT_NBYTES_7{1'b0}};
     assign wlast_7_w               = {1'b0};
     assign wvalid_7_w              = {1'b0};

      // B Channel
     assign bready_7_w              = {1'b0};

      // AR Channel
     assign arid_7_w                = {AXI_IDW{1'b0}};
     assign araddr_7_w              = {AXI_ADDRW{1'b0}};
     assign arlen_7_w               = {AXI_LENW{1'b0}};
     assign arsize_7_w              = {AXI_SIZEW{1'b0}};
     assign arburst_7_w             = {AXI_BURSTW{1'b0}};
     assign arlock_7_w              = {`UMCTL2_AXI_LOCK_WIDTH_7{1'b0}};
     assign arcache_7_w             = {AXI_CACHEW{1'b0}};
     assign arprot_7_w              = {AXI_PROTW{1'b0}};
     assign arqos_7_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_7_w           = {1'b0};
     assign arurgentr_7_w           = {1'b0};
     assign arpoison_7_w            = {1'b0};
     assign arautopre_7_w           = {1'b0};
     assign arvalid_7_w             = {1'b0};

      // R Channel
     assign rready_7_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_8_w         = 1'b1;
     assign awid_8_w                = {AXI_IDW{1'b0}};
     assign awaddr_8_w              = {AXI_ADDRW{1'b0}};
     assign awlen_8_w               = {AXI_LENW{1'b0}};
     assign awsize_8_w              = {AXI_SIZEW{1'b0}};
     assign awburst_8_w             = {AXI_BURSTW{1'b0}};
     assign awlock_8_w              = {`UMCTL2_AXI_LOCK_WIDTH_8{1'b0}};
     assign awcache_8_w             = {AXI_CACHEW{1'b0}};
     assign awprot_8_w              = {AXI_PROTW{1'b0}};
     assign awqos_8_w               = {AXI_QOSW{1'b0}};
     assign awurgent_8_w            = {1'b0};
     assign awpoison_8_w            = {1'b0};
     assign awautopre_8_w           = {1'b0};
     assign awvalid_8_w             = {1'b0};

      // W Channel
     assign wdata_8_w               = {`UMCTL2_PORT_DW_8{1'b0}};
     assign wid_8_w                 = {AXI_IDW{1'b0}};
     assign wstrb_8_w               = {`UMCTL2_PORT_NBYTES_8{1'b0}};
     assign wlast_8_w               = {1'b0};
     assign wvalid_8_w              = {1'b0};

      // B Channel
     assign bready_8_w              = {1'b0};

      // AR Channel
     assign arid_8_w                = {AXI_IDW{1'b0}};
     assign araddr_8_w              = {AXI_ADDRW{1'b0}};
     assign arlen_8_w               = {AXI_LENW{1'b0}};
     assign arsize_8_w              = {AXI_SIZEW{1'b0}};
     assign arburst_8_w             = {AXI_BURSTW{1'b0}};
     assign arlock_8_w              = {`UMCTL2_AXI_LOCK_WIDTH_8{1'b0}};
     assign arcache_8_w             = {AXI_CACHEW{1'b0}};
     assign arprot_8_w              = {AXI_PROTW{1'b0}};
     assign arqos_8_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_8_w           = {1'b0};
     assign arurgentr_8_w           = {1'b0};
     assign arpoison_8_w            = {1'b0};
     assign arautopre_8_w           = {1'b0};
     assign arvalid_8_w             = {1'b0};

      // R Channel
     assign rready_8_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_9_w         = 1'b1;
     assign awid_9_w                = {AXI_IDW{1'b0}};
     assign awaddr_9_w              = {AXI_ADDRW{1'b0}};
     assign awlen_9_w               = {AXI_LENW{1'b0}};
     assign awsize_9_w              = {AXI_SIZEW{1'b0}};
     assign awburst_9_w             = {AXI_BURSTW{1'b0}};
     assign awlock_9_w              = {`UMCTL2_AXI_LOCK_WIDTH_9{1'b0}};
     assign awcache_9_w             = {AXI_CACHEW{1'b0}};
     assign awprot_9_w              = {AXI_PROTW{1'b0}};
     assign awqos_9_w               = {AXI_QOSW{1'b0}};
     assign awurgent_9_w            = {1'b0};
     assign awpoison_9_w            = {1'b0};
     assign awautopre_9_w           = {1'b0};
     assign awvalid_9_w             = {1'b0};

      // W Channel
     assign wdata_9_w               = {`UMCTL2_PORT_DW_9{1'b0}};
     assign wid_9_w                 = {AXI_IDW{1'b0}};
     assign wstrb_9_w               = {`UMCTL2_PORT_NBYTES_9{1'b0}};
     assign wlast_9_w               = {1'b0};
     assign wvalid_9_w              = {1'b0};

      // B Channel
     assign bready_9_w              = {1'b0};

      // AR Channel
     assign arid_9_w                = {AXI_IDW{1'b0}};
     assign araddr_9_w              = {AXI_ADDRW{1'b0}};
     assign arlen_9_w               = {AXI_LENW{1'b0}};
     assign arsize_9_w              = {AXI_SIZEW{1'b0}};
     assign arburst_9_w             = {AXI_BURSTW{1'b0}};
     assign arlock_9_w              = {`UMCTL2_AXI_LOCK_WIDTH_9{1'b0}};
     assign arcache_9_w             = {AXI_CACHEW{1'b0}};
     assign arprot_9_w              = {AXI_PROTW{1'b0}};
     assign arqos_9_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_9_w           = {1'b0};
     assign arurgentr_9_w           = {1'b0};
     assign arpoison_9_w            = {1'b0};
     assign arautopre_9_w           = {1'b0};
     assign arvalid_9_w             = {1'b0};

      // R Channel
     assign rready_9_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_10_w         = 1'b1;
     assign awid_10_w                = {AXI_IDW{1'b0}};
     assign awaddr_10_w              = {AXI_ADDRW{1'b0}};
     assign awlen_10_w               = {AXI_LENW{1'b0}};
     assign awsize_10_w              = {AXI_SIZEW{1'b0}};
     assign awburst_10_w             = {AXI_BURSTW{1'b0}};
     assign awlock_10_w              = {`UMCTL2_AXI_LOCK_WIDTH_10{1'b0}};
     assign awcache_10_w             = {AXI_CACHEW{1'b0}};
     assign awprot_10_w              = {AXI_PROTW{1'b0}};
     assign awqos_10_w               = {AXI_QOSW{1'b0}};
     assign awurgent_10_w            = {1'b0};
     assign awpoison_10_w            = {1'b0};
     assign awautopre_10_w           = {1'b0};
     assign awvalid_10_w             = {1'b0};

      // W Channel
     assign wdata_10_w               = {`UMCTL2_PORT_DW_10{1'b0}};
     assign wid_10_w                 = {AXI_IDW{1'b0}};
     assign wstrb_10_w               = {`UMCTL2_PORT_NBYTES_10{1'b0}};
     assign wlast_10_w               = {1'b0};
     assign wvalid_10_w              = {1'b0};

      // B Channel
     assign bready_10_w              = {1'b0};

      // AR Channel
     assign arid_10_w                = {AXI_IDW{1'b0}};
     assign araddr_10_w              = {AXI_ADDRW{1'b0}};
     assign arlen_10_w               = {AXI_LENW{1'b0}};
     assign arsize_10_w              = {AXI_SIZEW{1'b0}};
     assign arburst_10_w             = {AXI_BURSTW{1'b0}};
     assign arlock_10_w              = {`UMCTL2_AXI_LOCK_WIDTH_10{1'b0}};
     assign arcache_10_w             = {AXI_CACHEW{1'b0}};
     assign arprot_10_w              = {AXI_PROTW{1'b0}};
     assign arqos_10_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_10_w           = {1'b0};
     assign arurgentr_10_w           = {1'b0};
     assign arpoison_10_w            = {1'b0};
     assign arautopre_10_w           = {1'b0};
     assign arvalid_10_w             = {1'b0};

      // R Channel
     assign rready_10_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_11_w         = 1'b1;
     assign awid_11_w                = {AXI_IDW{1'b0}};
     assign awaddr_11_w              = {AXI_ADDRW{1'b0}};
     assign awlen_11_w               = {AXI_LENW{1'b0}};
     assign awsize_11_w              = {AXI_SIZEW{1'b0}};
     assign awburst_11_w             = {AXI_BURSTW{1'b0}};
     assign awlock_11_w              = {`UMCTL2_AXI_LOCK_WIDTH_11{1'b0}};
     assign awcache_11_w             = {AXI_CACHEW{1'b0}};
     assign awprot_11_w              = {AXI_PROTW{1'b0}};
     assign awqos_11_w               = {AXI_QOSW{1'b0}};
     assign awurgent_11_w            = {1'b0};
     assign awpoison_11_w            = {1'b0};
     assign awautopre_11_w           = {1'b0};
     assign awvalid_11_w             = {1'b0};

      // W Channel
     assign wdata_11_w               = {`UMCTL2_PORT_DW_11{1'b0}};
     assign wid_11_w                 = {AXI_IDW{1'b0}};
     assign wstrb_11_w               = {`UMCTL2_PORT_NBYTES_11{1'b0}};
     assign wlast_11_w               = {1'b0};
     assign wvalid_11_w              = {1'b0};

      // B Channel
     assign bready_11_w              = {1'b0};

      // AR Channel
     assign arid_11_w                = {AXI_IDW{1'b0}};
     assign araddr_11_w              = {AXI_ADDRW{1'b0}};
     assign arlen_11_w               = {AXI_LENW{1'b0}};
     assign arsize_11_w              = {AXI_SIZEW{1'b0}};
     assign arburst_11_w             = {AXI_BURSTW{1'b0}};
     assign arlock_11_w              = {`UMCTL2_AXI_LOCK_WIDTH_11{1'b0}};
     assign arcache_11_w             = {AXI_CACHEW{1'b0}};
     assign arprot_11_w              = {AXI_PROTW{1'b0}};
     assign arqos_11_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_11_w           = {1'b0};
     assign arurgentr_11_w           = {1'b0};
     assign arpoison_11_w            = {1'b0};
     assign arautopre_11_w           = {1'b0};
     assign arvalid_11_w             = {1'b0};

      // R Channel
     assign rready_11_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_12_w         = 1'b1;
     assign awid_12_w                = {AXI_IDW{1'b0}};
     assign awaddr_12_w              = {AXI_ADDRW{1'b0}};
     assign awlen_12_w               = {AXI_LENW{1'b0}};
     assign awsize_12_w              = {AXI_SIZEW{1'b0}};
     assign awburst_12_w             = {AXI_BURSTW{1'b0}};
     assign awlock_12_w              = {`UMCTL2_AXI_LOCK_WIDTH_12{1'b0}};
     assign awcache_12_w             = {AXI_CACHEW{1'b0}};
     assign awprot_12_w              = {AXI_PROTW{1'b0}};
     assign awqos_12_w               = {AXI_QOSW{1'b0}};
     assign awurgent_12_w            = {1'b0};
     assign awpoison_12_w            = {1'b0};
     assign awautopre_12_w           = {1'b0};
     assign awvalid_12_w             = {1'b0};

      // W Channel
     assign wdata_12_w               = {`UMCTL2_PORT_DW_12{1'b0}};
     assign wid_12_w                 = {AXI_IDW{1'b0}};
     assign wstrb_12_w               = {`UMCTL2_PORT_NBYTES_12{1'b0}};
     assign wlast_12_w               = {1'b0};
     assign wvalid_12_w              = {1'b0};

      // B Channel
     assign bready_12_w              = {1'b0};

      // AR Channel
     assign arid_12_w                = {AXI_IDW{1'b0}};
     assign araddr_12_w              = {AXI_ADDRW{1'b0}};
     assign arlen_12_w               = {AXI_LENW{1'b0}};
     assign arsize_12_w              = {AXI_SIZEW{1'b0}};
     assign arburst_12_w             = {AXI_BURSTW{1'b0}};
     assign arlock_12_w              = {`UMCTL2_AXI_LOCK_WIDTH_12{1'b0}};
     assign arcache_12_w             = {AXI_CACHEW{1'b0}};
     assign arprot_12_w              = {AXI_PROTW{1'b0}};
     assign arqos_12_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_12_w           = {1'b0};
     assign arurgentr_12_w           = {1'b0};
     assign arpoison_12_w            = {1'b0};
     assign arautopre_12_w           = {1'b0};
     assign arvalid_12_w             = {1'b0};

      // R Channel
     assign rready_12_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_13_w         = 1'b1;
     assign awid_13_w                = {AXI_IDW{1'b0}};
     assign awaddr_13_w              = {AXI_ADDRW{1'b0}};
     assign awlen_13_w               = {AXI_LENW{1'b0}};
     assign awsize_13_w              = {AXI_SIZEW{1'b0}};
     assign awburst_13_w             = {AXI_BURSTW{1'b0}};
     assign awlock_13_w              = {`UMCTL2_AXI_LOCK_WIDTH_13{1'b0}};
     assign awcache_13_w             = {AXI_CACHEW{1'b0}};
     assign awprot_13_w              = {AXI_PROTW{1'b0}};
     assign awqos_13_w               = {AXI_QOSW{1'b0}};
     assign awurgent_13_w            = {1'b0};
     assign awpoison_13_w            = {1'b0};
     assign awautopre_13_w           = {1'b0};
     assign awvalid_13_w             = {1'b0};

      // W Channel
     assign wdata_13_w               = {`UMCTL2_PORT_DW_13{1'b0}};
     assign wid_13_w                 = {AXI_IDW{1'b0}};
     assign wstrb_13_w               = {`UMCTL2_PORT_NBYTES_13{1'b0}};
     assign wlast_13_w               = {1'b0};
     assign wvalid_13_w              = {1'b0};

      // B Channel
     assign bready_13_w              = {1'b0};

      // AR Channel
     assign arid_13_w                = {AXI_IDW{1'b0}};
     assign araddr_13_w              = {AXI_ADDRW{1'b0}};
     assign arlen_13_w               = {AXI_LENW{1'b0}};
     assign arsize_13_w              = {AXI_SIZEW{1'b0}};
     assign arburst_13_w             = {AXI_BURSTW{1'b0}};
     assign arlock_13_w              = {`UMCTL2_AXI_LOCK_WIDTH_13{1'b0}};
     assign arcache_13_w             = {AXI_CACHEW{1'b0}};
     assign arprot_13_w              = {AXI_PROTW{1'b0}};
     assign arqos_13_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_13_w           = {1'b0};
     assign arurgentr_13_w           = {1'b0};
     assign arpoison_13_w            = {1'b0};
     assign arautopre_13_w           = {1'b0};
     assign arvalid_13_w             = {1'b0};

      // R Channel
     assign rready_13_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_14_w         = 1'b1;
     assign awid_14_w                = {AXI_IDW{1'b0}};
     assign awaddr_14_w              = {AXI_ADDRW{1'b0}};
     assign awlen_14_w               = {AXI_LENW{1'b0}};
     assign awsize_14_w              = {AXI_SIZEW{1'b0}};
     assign awburst_14_w             = {AXI_BURSTW{1'b0}};
     assign awlock_14_w              = {`UMCTL2_AXI_LOCK_WIDTH_14{1'b0}};
     assign awcache_14_w             = {AXI_CACHEW{1'b0}};
     assign awprot_14_w              = {AXI_PROTW{1'b0}};
     assign awqos_14_w               = {AXI_QOSW{1'b0}};
     assign awurgent_14_w            = {1'b0};
     assign awpoison_14_w            = {1'b0};
     assign awautopre_14_w           = {1'b0};
     assign awvalid_14_w             = {1'b0};

      // W Channel
     assign wdata_14_w               = {`UMCTL2_PORT_DW_14{1'b0}};
     assign wid_14_w                 = {AXI_IDW{1'b0}};
     assign wstrb_14_w               = {`UMCTL2_PORT_NBYTES_14{1'b0}};
     assign wlast_14_w               = {1'b0};
     assign wvalid_14_w              = {1'b0};

      // B Channel
     assign bready_14_w              = {1'b0};

      // AR Channel
     assign arid_14_w                = {AXI_IDW{1'b0}};
     assign araddr_14_w              = {AXI_ADDRW{1'b0}};
     assign arlen_14_w               = {AXI_LENW{1'b0}};
     assign arsize_14_w              = {AXI_SIZEW{1'b0}};
     assign arburst_14_w             = {AXI_BURSTW{1'b0}};
     assign arlock_14_w              = {`UMCTL2_AXI_LOCK_WIDTH_14{1'b0}};
     assign arcache_14_w             = {AXI_CACHEW{1'b0}};
     assign arprot_14_w              = {AXI_PROTW{1'b0}};
     assign arqos_14_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_14_w           = {1'b0};
     assign arurgentr_14_w           = {1'b0};
     assign arpoison_14_w            = {1'b0};
     assign arautopre_14_w           = {1'b0};
     assign arvalid_14_w             = {1'b0};

      // R Channel
     assign rready_14_w              = {1'b0};

     // AW Channel
     assign csysreq_xpi_15_w         = 1'b1;
     assign awid_15_w                = {AXI_IDW{1'b0}};
     assign awaddr_15_w              = {AXI_ADDRW{1'b0}};
     assign awlen_15_w               = {AXI_LENW{1'b0}};
     assign awsize_15_w              = {AXI_SIZEW{1'b0}};
     assign awburst_15_w             = {AXI_BURSTW{1'b0}};
     assign awlock_15_w              = {`UMCTL2_AXI_LOCK_WIDTH_15{1'b0}};
     assign awcache_15_w             = {AXI_CACHEW{1'b0}};
     assign awprot_15_w              = {AXI_PROTW{1'b0}};
     assign awqos_15_w               = {AXI_QOSW{1'b0}};
     assign awurgent_15_w            = {1'b0};
     assign awpoison_15_w            = {1'b0};
     assign awautopre_15_w           = {1'b0};
     assign awvalid_15_w             = {1'b0};

      // W Channel
     assign wdata_15_w               = {`UMCTL2_PORT_DW_15{1'b0}};
     assign wid_15_w                 = {AXI_IDW{1'b0}};
     assign wstrb_15_w               = {`UMCTL2_PORT_NBYTES_15{1'b0}};
     assign wlast_15_w               = {1'b0};
     assign wvalid_15_w              = {1'b0};

      // B Channel
     assign bready_15_w              = {1'b0};

      // AR Channel
     assign arid_15_w                = {AXI_IDW{1'b0}};
     assign araddr_15_w              = {AXI_ADDRW{1'b0}};
     assign arlen_15_w               = {AXI_LENW{1'b0}};
     assign arsize_15_w              = {AXI_SIZEW{1'b0}};
     assign arburst_15_w             = {AXI_BURSTW{1'b0}};
     assign arlock_15_w              = {`UMCTL2_AXI_LOCK_WIDTH_15{1'b0}};
     assign arcache_15_w             = {AXI_CACHEW{1'b0}};
     assign arprot_15_w              = {AXI_PROTW{1'b0}};
     assign arqos_15_w               = {AXI_QOSW{1'b0}};
     assign arurgentb_15_w           = {1'b0};
     assign arurgentr_15_w           = {1'b0};
     assign arpoison_15_w            = {1'b0};
     assign arautopre_15_w           = {1'b0};
     assign arvalid_15_w             = {1'b0};

      // R Channel
     assign rready_15_w              = {1'b0};


      assign awparity_0_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_0_w                                   = {`UMCTL2_PORT_NBYTES_0{1'b0}};
      assign arparity_0_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_0_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_0_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_0_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_1_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_1_w                                   = {`UMCTL2_PORT_NBYTES_1{1'b0}};
      assign arparity_1_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_1_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_1_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_1_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_2_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_2_w                                   = {`UMCTL2_PORT_NBYTES_2{1'b0}};
      assign arparity_2_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_2_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_2_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_2_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_3_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_3_w                                   = {`UMCTL2_PORT_NBYTES_3{1'b0}};
      assign arparity_3_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_3_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_3_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_3_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_4_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_4_w                                   = {`UMCTL2_PORT_NBYTES_4{1'b0}};
      assign arparity_4_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_4_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_4_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_4_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_5_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_5_w                                   = {`UMCTL2_PORT_NBYTES_5{1'b0}};
      assign arparity_5_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_5_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_5_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_5_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_6_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_6_w                                   = {`UMCTL2_PORT_NBYTES_6{1'b0}};
      assign arparity_6_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_6_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_6_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_6_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_7_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_7_w                                   = {`UMCTL2_PORT_NBYTES_7{1'b0}};
      assign arparity_7_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_7_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_7_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_7_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_8_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_8_w                                   = {`UMCTL2_PORT_NBYTES_8{1'b0}};
      assign arparity_8_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_8_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_8_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_8_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_9_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_9_w                                   = {`UMCTL2_PORT_NBYTES_9{1'b0}};
      assign arparity_9_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_9_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_9_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_9_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_10_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_10_w                                   = {`UMCTL2_PORT_NBYTES_10{1'b0}};
      assign arparity_10_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_10_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_10_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_10_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_11_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_11_w                                   = {`UMCTL2_PORT_NBYTES_11{1'b0}};
      assign arparity_11_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_11_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_11_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_11_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_12_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_12_w                                   = {`UMCTL2_PORT_NBYTES_12{1'b0}};
      assign arparity_12_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_12_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_12_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_12_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_13_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_13_w                                   = {`UMCTL2_PORT_NBYTES_13{1'b0}};
      assign arparity_13_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_13_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_13_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_13_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_14_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_14_w                                   = {`UMCTL2_PORT_NBYTES_14{1'b0}};
      assign arparity_14_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_14_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_14_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_14_w                                    = {(AXI_USERW){1'b0}};


      assign awparity_15_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};
      assign wparity_15_w                                   = {`UMCTL2_PORT_NBYTES_15{1'b0}};
      assign arparity_15_w                                  = {OCPAR_ADDR_PARITY_WIDTH{1'b0}};

      assign awuser_15_w                                    = {(AXI_USERW){1'b0}};
      assign wuser_15_w                                     = {(AXI_USERW){1'b0}};
      assign aruser_15_w                                    = {(AXI_USERW){1'b0}};




    assign rdataram_dout_0_w                             = rdataram_dout_0;
    assign rdataram_din_0                                = rdataram_din_0_w;         // output no `else
    assign rdataram_wr_0                                 = rdataram_wr_0_w;          // output no `else
    assign rdataram_re_0                                 = rdataram_re_0_w;          // output no `else
    assign rdataram_raddr_0                              = rdataram_raddr_0_w;       // output no `else
    assign rdataram_waddr_0                              = rdataram_waddr_0_w;       // output no `else
    assign rdataram_dout_par_0_w                         = rdataram_dout_par_0;
    assign rdataram_din_par_0                            = rdataram_din_par_0_w;     // output no `else

    assign rdataram_dout_dch1_0_w                        = rdataram_dout_dch1_0;
    assign rdataram_din_dch1_0                           = rdataram_din_dch1_0_w;     // output no `else
    assign rdataram_wr_dch1_0                            = rdataram_wr_dch1_0_w;      // output no `else
    assign rdataram_re_dch1_0                            = rdataram_re_dch1_0_w;      // output no `else
    assign rdataram_raddr_dch1_0                         = rdataram_raddr_dch1_0_w;   // output no `else
    assign rdataram_waddr_dch1_0                         = rdataram_waddr_dch1_0_w;   // output no `else
    assign rdataram_dout_par_dch1_0_w                    = rdataram_dout_par_dch1_0;
    assign rdataram_din_par_dch1_0                       = rdataram_din_par_dch1_0_w; // output no `else


    assign rdataram_dout_1_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_1_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_1_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_1_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_2_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_2_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_2_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_2_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_3_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_3_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_3_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_3_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_4_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_4_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_4_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_4_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_5_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_5_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_5_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_5_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_6_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_6_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_6_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_6_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_7_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_7_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_7_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_7_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_8_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_8_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_8_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_8_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_9_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_9_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_9_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_9_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_10_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_10_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_10_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_10_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_11_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_11_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_11_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_11_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_12_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_12_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_12_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_12_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_13_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_13_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_13_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_13_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_14_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_14_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_14_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_14_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_15_w                             = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_15_w                         = {UMCTL2_DATARAM_PAR_DW{1'b0}};

    assign rdataram_dout_dch1_15_w                        = {UMCTL2_RDATARAM_DW{1'b0}};
    assign rdataram_dout_par_dch1_15_w                    = {UMCTL2_DATARAM_PAR_DW{1'b0}};



       assign reg_arba0_rqos_map_level2_0_w            = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
       assign reg_arba0_rqos_map_region2_0_w           = {(XPI_RQOS_RW){1'b0}};
       assign reg_arba0_rqos_map_level1_0_w            = reg_arba0_rqos_map_level1_port0;
       assign reg_arba0_rqos_map_region0_0_w           = reg_arba0_rqos_map_region0_port0;
       assign reg_arba0_rqos_map_region1_0_w           = reg_arba0_rqos_map_region1_port0;

      assign reg_arba1_rqos_map_level1_1_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba1_rqos_map_level2_1_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba1_rqos_map_region0_1_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba1_rqos_map_region1_1_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba1_rqos_map_region2_1_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba2_rqos_map_level1_2_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba2_rqos_map_level2_2_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba2_rqos_map_region0_2_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba2_rqos_map_region1_2_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba2_rqos_map_region2_2_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba3_rqos_map_level1_3_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba3_rqos_map_level2_3_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba3_rqos_map_region0_3_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba3_rqos_map_region1_3_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba3_rqos_map_region2_3_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba4_rqos_map_level1_4_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba4_rqos_map_level2_4_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba4_rqos_map_region0_4_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba4_rqos_map_region1_4_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba4_rqos_map_region2_4_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba5_rqos_map_level1_5_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba5_rqos_map_level2_5_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba5_rqos_map_region0_5_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba5_rqos_map_region1_5_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba5_rqos_map_region2_5_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba6_rqos_map_level1_6_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba6_rqos_map_level2_6_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba6_rqos_map_region0_6_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba6_rqos_map_region1_6_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba6_rqos_map_region2_6_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba7_rqos_map_level1_7_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba7_rqos_map_level2_7_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba7_rqos_map_region0_7_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba7_rqos_map_region1_7_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba7_rqos_map_region2_7_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba8_rqos_map_level1_8_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba8_rqos_map_level2_8_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba8_rqos_map_region0_8_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba8_rqos_map_region1_8_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba8_rqos_map_region2_8_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba9_rqos_map_level1_9_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba9_rqos_map_level2_9_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba9_rqos_map_region0_9_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba9_rqos_map_region1_9_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba9_rqos_map_region2_9_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba10_rqos_map_level1_10_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba10_rqos_map_level2_10_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba10_rqos_map_region0_10_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba10_rqos_map_region1_10_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba10_rqos_map_region2_10_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba11_rqos_map_level1_11_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba11_rqos_map_level2_11_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba11_rqos_map_region0_11_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba11_rqos_map_region1_11_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba11_rqos_map_region2_11_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba12_rqos_map_level1_12_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba12_rqos_map_level2_12_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba12_rqos_map_region0_12_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba12_rqos_map_region1_12_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba12_rqos_map_region2_12_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba13_rqos_map_level1_13_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba13_rqos_map_level2_13_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba13_rqos_map_region0_13_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba13_rqos_map_region1_13_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba13_rqos_map_region2_13_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba14_rqos_map_level1_14_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba14_rqos_map_level2_14_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba14_rqos_map_region0_14_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba14_rqos_map_region1_14_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba14_rqos_map_region2_14_w            = {(XPI_RQOS_RW){1'b0}};

      assign reg_arba15_rqos_map_level1_15_w             = {(XPI_RQOS_MLW){1'b0}};
      assign reg_arba15_rqos_map_level2_15_w             = {{(XPI_RQOS_MLW-1){1'b0}},1'b1};
      assign reg_arba15_rqos_map_region0_15_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba15_rqos_map_region1_15_w            = {(XPI_RQOS_RW){1'b0}};
      assign reg_arba15_rqos_map_region2_15_w            = {(XPI_RQOS_RW){1'b0}};


      assign reg_arb_rqos_map_timeoutb_0_w               = reg_arb_rqos_map_timeoutb_port0;
      assign reg_arb_rqos_map_timeoutr_0_w               = reg_arb_rqos_map_timeoutr_port0;

      assign reg_arb_rqos_map_timeoutb_1_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_1_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_2_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_2_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_3_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_3_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_4_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_4_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_5_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_5_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_6_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_6_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_7_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_7_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_8_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_8_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_9_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_9_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_10_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_10_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_11_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_11_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_12_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_12_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_13_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_13_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_14_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_14_w               = {(HIF_RQOS_TW){1'b0}};

      assign reg_arb_rqos_map_timeoutb_15_w               = {(HIF_RQOS_TW){1'b0}};
      assign reg_arb_rqos_map_timeoutr_15_w               = {(HIF_RQOS_TW){1'b0}};


      assign reg_arba0_wqos_map_level1_0_w               = reg_arba0_wqos_map_level1_port0;
      assign reg_arba0_wqos_map_level2_0_w               = reg_arba0_wqos_map_level2_port0;
      assign reg_arba0_wqos_map_region0_0_w              = reg_arba0_wqos_map_region0_port0;
      assign reg_arba0_wqos_map_region1_0_w              = reg_arba0_wqos_map_region1_port0;
      assign reg_arba0_wqos_map_region2_0_w              = reg_arba0_wqos_map_region2_port0;
      assign reg_arb_wqos_map_timeout1_0_w               = reg_arb_wqos_map_timeout1_port0;
      assign reg_arb_wqos_map_timeout2_0_w               = reg_arb_wqos_map_timeout2_port0;

      assign reg_arba1_wqos_map_level1_1_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba1_wqos_map_level2_1_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba1_wqos_map_region0_1_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba1_wqos_map_region1_1_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba1_wqos_map_region2_1_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_1_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_1_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba2_wqos_map_level1_2_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba2_wqos_map_level2_2_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba2_wqos_map_region0_2_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba2_wqos_map_region1_2_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba2_wqos_map_region2_2_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_2_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_2_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba3_wqos_map_level1_3_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba3_wqos_map_level2_3_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba3_wqos_map_region0_3_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba3_wqos_map_region1_3_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba3_wqos_map_region2_3_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_3_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_3_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba4_wqos_map_level1_4_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba4_wqos_map_level2_4_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba4_wqos_map_region0_4_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba4_wqos_map_region1_4_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba4_wqos_map_region2_4_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_4_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_4_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba5_wqos_map_level1_5_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba5_wqos_map_level2_5_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba5_wqos_map_region0_5_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba5_wqos_map_region1_5_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba5_wqos_map_region2_5_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_5_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_5_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba6_wqos_map_level1_6_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba6_wqos_map_level2_6_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba6_wqos_map_region0_6_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba6_wqos_map_region1_6_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba6_wqos_map_region2_6_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_6_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_6_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba7_wqos_map_level1_7_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba7_wqos_map_level2_7_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba7_wqos_map_region0_7_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba7_wqos_map_region1_7_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba7_wqos_map_region2_7_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_7_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_7_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba8_wqos_map_level1_8_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba8_wqos_map_level2_8_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba8_wqos_map_region0_8_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba8_wqos_map_region1_8_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba8_wqos_map_region2_8_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_8_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_8_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba9_wqos_map_level1_9_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba9_wqos_map_level2_9_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba9_wqos_map_region0_9_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba9_wqos_map_region1_9_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba9_wqos_map_region2_9_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_9_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_9_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba10_wqos_map_level1_10_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba10_wqos_map_level2_10_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba10_wqos_map_region0_10_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba10_wqos_map_region1_10_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba10_wqos_map_region2_10_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_10_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_10_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba11_wqos_map_level1_11_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba11_wqos_map_level2_11_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba11_wqos_map_region0_11_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba11_wqos_map_region1_11_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba11_wqos_map_region2_11_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_11_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_11_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba12_wqos_map_level1_12_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba12_wqos_map_level2_12_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba12_wqos_map_region0_12_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba12_wqos_map_region1_12_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba12_wqos_map_region2_12_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_12_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_12_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba13_wqos_map_level1_13_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba13_wqos_map_level2_13_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba13_wqos_map_region0_13_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba13_wqos_map_region1_13_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba13_wqos_map_region2_13_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_13_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_13_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba14_wqos_map_level1_14_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba14_wqos_map_level2_14_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba14_wqos_map_region0_14_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba14_wqos_map_region1_14_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba14_wqos_map_region2_14_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_14_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_14_w               = {(HIF_WQOS_TW){1'b0}};

      assign reg_arba15_wqos_map_level1_15_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba15_wqos_map_level2_15_w               = {(XPI_WQOS_MLW){1'b0}};
      assign reg_arba15_wqos_map_region0_15_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba15_wqos_map_region1_15_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arba15_wqos_map_region2_15_w              = {(XPI_WQOS_RW){1'b0}};
      assign reg_arb_wqos_map_timeout1_15_w               = {(HIF_WQOS_TW){1'b0}};
      assign reg_arb_wqos_map_timeout2_15_w               = {(HIF_WQOS_TW){1'b0}};



       assign reg_arba0_port_en_0_w                    = reg_arba0_port_en_port0; //connect to real input
       assign reg_arba0_read_reorder_bypass_en_0_w     = 1'b0;

     assign reg_arba1_port_en_1_w                      = 1'b0;
     assign reg_arba1_read_reorder_bypass_en_1_w       = 1'b0;

     assign reg_arba2_port_en_2_w                      = 1'b0;
     assign reg_arba2_read_reorder_bypass_en_2_w       = 1'b0;

     assign reg_arba3_port_en_3_w                      = 1'b0;
     assign reg_arba3_read_reorder_bypass_en_3_w       = 1'b0;

     assign reg_arba4_port_en_4_w                      = 1'b0;
     assign reg_arba4_read_reorder_bypass_en_4_w       = 1'b0;

     assign reg_arba5_port_en_5_w                      = 1'b0;
     assign reg_arba5_read_reorder_bypass_en_5_w       = 1'b0;

     assign reg_arba6_port_en_6_w                      = 1'b0;
     assign reg_arba6_read_reorder_bypass_en_6_w       = 1'b0;

     assign reg_arba7_port_en_7_w                      = 1'b0;
     assign reg_arba7_read_reorder_bypass_en_7_w       = 1'b0;

     assign reg_arba8_port_en_8_w                      = 1'b0;
     assign reg_arba8_read_reorder_bypass_en_8_w       = 1'b0;

     assign reg_arba9_port_en_9_w                      = 1'b0;
     assign reg_arba9_read_reorder_bypass_en_9_w       = 1'b0;

     assign reg_arba10_port_en_10_w                      = 1'b0;
     assign reg_arba10_read_reorder_bypass_en_10_w       = 1'b0;

     assign reg_arba11_port_en_11_w                      = 1'b0;
     assign reg_arba11_read_reorder_bypass_en_11_w       = 1'b0;

     assign reg_arba12_port_en_12_w                      = 1'b0;
     assign reg_arba12_read_reorder_bypass_en_12_w       = 1'b0;

     assign reg_arba13_port_en_13_w                      = 1'b0;
     assign reg_arba13_read_reorder_bypass_en_13_w       = 1'b0;

     assign reg_arba14_port_en_14_w                      = 1'b0;
     assign reg_arba14_read_reorder_bypass_en_14_w       = 1'b0;

     assign reg_arba15_port_en_15_w                      = 1'b0;
     assign reg_arba15_read_reorder_bypass_en_15_w       = 1'b0;



//PORT Arbitration related
    assign reg_arba_data_bus_width_0_w      = (`DDRCTL_PBW_MODE_SUPPORT == 0)? reg_arba0_data_bus_width :
                                              (`DDRCTL_PBW_MODE_SUPPORT == 1)? ((reg_arba0_data_bus_width==2'b00)? 2'b00 : 2'b01) : 2'b00;
    assign reg_xpi_snf_mode_0_w             = 1'b0;

           assign reg_arb_rdwr_ordered_en_0_w               = 1'b0;
           assign reg_arba0_rdwr_ordered_en_0_w             = 1'b0;
           assign reg_arb_rd_port_pagematch_en_0_w          = reg_arb_rd_port_pagematch_en_port0;
           assign reg_arb_wr_port_pagematch_en_0_w          = reg_arb_wr_port_pagematch_en_port0;

           assign reg_arb_port_data_channel_0_w             = 1'b0;

           assign reg_arb_rdwr_ordered_en_1_w               = 1'b0;
           assign reg_arba1_rdwr_ordered_en_1_w             = 1'b0;

           assign reg_arb_port_data_channel_1_w             = 1'b0;
           assign reg_arba_data_bus_width_1_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_1_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_1_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_2_w               = 1'b0;
           assign reg_arba2_rdwr_ordered_en_2_w             = 1'b0;

           assign reg_arb_port_data_channel_2_w             = 1'b0;
           assign reg_arba_data_bus_width_2_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_2_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_2_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_3_w               = 1'b0;
           assign reg_arba3_rdwr_ordered_en_3_w             = 1'b0;

           assign reg_arb_port_data_channel_3_w             = 1'b0;
           assign reg_arba_data_bus_width_3_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_3_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_3_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_4_w               = 1'b0;
           assign reg_arba4_rdwr_ordered_en_4_w             = 1'b0;

           assign reg_arb_port_data_channel_4_w             = 1'b0;
           assign reg_arba_data_bus_width_4_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_4_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_4_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_5_w               = 1'b0;
           assign reg_arba5_rdwr_ordered_en_5_w             = 1'b0;

           assign reg_arb_port_data_channel_5_w             = 1'b0;
           assign reg_arba_data_bus_width_5_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_5_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_5_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_6_w               = 1'b0;
           assign reg_arba6_rdwr_ordered_en_6_w             = 1'b0;

           assign reg_arb_port_data_channel_6_w             = 1'b0;
           assign reg_arba_data_bus_width_6_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_6_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_6_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_7_w               = 1'b0;
           assign reg_arba7_rdwr_ordered_en_7_w             = 1'b0;

           assign reg_arb_port_data_channel_7_w             = 1'b0;
           assign reg_arba_data_bus_width_7_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_7_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_7_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_8_w               = 1'b0;
           assign reg_arba8_rdwr_ordered_en_8_w             = 1'b0;

           assign reg_arb_port_data_channel_8_w             = 1'b0;
           assign reg_arba_data_bus_width_8_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_8_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_8_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_9_w               = 1'b0;
           assign reg_arba9_rdwr_ordered_en_9_w             = 1'b0;

           assign reg_arb_port_data_channel_9_w             = 1'b0;
           assign reg_arba_data_bus_width_9_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_9_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_9_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_10_w               = 1'b0;
           assign reg_arba10_rdwr_ordered_en_10_w             = 1'b0;

           assign reg_arb_port_data_channel_10_w             = 1'b0;
           assign reg_arba_data_bus_width_10_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_10_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_10_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_11_w               = 1'b0;
           assign reg_arba11_rdwr_ordered_en_11_w             = 1'b0;

           assign reg_arb_port_data_channel_11_w             = 1'b0;
           assign reg_arba_data_bus_width_11_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_11_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_11_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_12_w               = 1'b0;
           assign reg_arba12_rdwr_ordered_en_12_w             = 1'b0;

           assign reg_arb_port_data_channel_12_w             = 1'b0;
           assign reg_arba_data_bus_width_12_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_12_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_12_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_13_w               = 1'b0;
           assign reg_arba13_rdwr_ordered_en_13_w             = 1'b0;

           assign reg_arb_port_data_channel_13_w             = 1'b0;
           assign reg_arba_data_bus_width_13_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_13_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_13_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_14_w               = 1'b0;
           assign reg_arba14_rdwr_ordered_en_14_w             = 1'b0;

           assign reg_arb_port_data_channel_14_w             = 1'b0;
           assign reg_arba_data_bus_width_14_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_14_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_14_w          = 1'b0;

           assign reg_arb_rdwr_ordered_en_15_w               = 1'b0;
           assign reg_arba15_rdwr_ordered_en_15_w             = 1'b0;

           assign reg_arb_port_data_channel_15_w             = 1'b0;
           assign reg_arba_data_bus_width_15_w               = 2'b00;

           assign reg_arb_rd_port_pagematch_en_15_w          = 1'b0;
           assign reg_arb_wr_port_pagematch_en_15_w          = 1'b0;


  assign reg_arb_rrb_lock_threshold_0_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_1_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_2_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_3_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_4_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_5_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_6_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_7_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_8_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_9_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_10_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_11_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_12_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_13_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_14_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};
  assign reg_arb_rrb_lock_threshold_15_w = {(RRB_LOCK_THRESHOLD_WIDTH){1'b0}};

// AHB outpot

     assign hclk_0_w                                      = 1'b0;
     assign hresetn_0_w                                   = 1'b0;
     assign hsel_0_w                                      = 1'b0;
     assign hmaster_0_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_0_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_0_w                                    = 1'b0;
     assign hmastlock_0_w                                 = 1'b0;
     assign hburst_0_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_0_w                                   = 1'b0;
     assign htrans_0_w                                    = 2'b0;
     assign hsize_0_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_0_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_0_w                                    = {`UMCTL2_PORT_DW_0{1'b0}};
     assign hready_0_w                                    = {1'b0};

     assign reg_arba0_ahb_endianness_0_w                  = 2'b0;
     assign csysreq_0_w                                   = 1'b1;
     assign hclk_1_w                                      = 1'b0;
     assign hresetn_1_w                                   = 1'b0;
     assign hsel_1_w                                      = 1'b0;
     assign hmaster_1_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_1_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_1_w                                    = 1'b0;
     assign hmastlock_1_w                                 = 1'b0;
     assign hburst_1_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_1_w                                   = 1'b0;
     assign htrans_1_w                                    = 2'b0;
     assign hsize_1_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_1_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_1_w                                    = {`UMCTL2_PORT_DW_1{1'b0}};
     assign hready_1_w                                    = {1'b0};

     assign reg_arba1_ahb_endianness_1_w                  = 2'b0;
     assign csysreq_1_w                                   = 1'b1;
     assign hclk_2_w                                      = 1'b0;
     assign hresetn_2_w                                   = 1'b0;
     assign hsel_2_w                                      = 1'b0;
     assign hmaster_2_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_2_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_2_w                                    = 1'b0;
     assign hmastlock_2_w                                 = 1'b0;
     assign hburst_2_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_2_w                                   = 1'b0;
     assign htrans_2_w                                    = 2'b0;
     assign hsize_2_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_2_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_2_w                                    = {`UMCTL2_PORT_DW_2{1'b0}};
     assign hready_2_w                                    = {1'b0};

     assign reg_arba2_ahb_endianness_2_w                  = 2'b0;
     assign csysreq_2_w                                   = 1'b1;
     assign hclk_3_w                                      = 1'b0;
     assign hresetn_3_w                                   = 1'b0;
     assign hsel_3_w                                      = 1'b0;
     assign hmaster_3_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_3_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_3_w                                    = 1'b0;
     assign hmastlock_3_w                                 = 1'b0;
     assign hburst_3_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_3_w                                   = 1'b0;
     assign htrans_3_w                                    = 2'b0;
     assign hsize_3_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_3_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_3_w                                    = {`UMCTL2_PORT_DW_3{1'b0}};
     assign hready_3_w                                    = {1'b0};

     assign reg_arba3_ahb_endianness_3_w                  = 2'b0;
     assign csysreq_3_w                                   = 1'b1;
     assign hclk_4_w                                      = 1'b0;
     assign hresetn_4_w                                   = 1'b0;
     assign hsel_4_w                                      = 1'b0;
     assign hmaster_4_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_4_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_4_w                                    = 1'b0;
     assign hmastlock_4_w                                 = 1'b0;
     assign hburst_4_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_4_w                                   = 1'b0;
     assign htrans_4_w                                    = 2'b0;
     assign hsize_4_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_4_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_4_w                                    = {`UMCTL2_PORT_DW_4{1'b0}};
     assign hready_4_w                                    = {1'b0};

     assign reg_arba4_ahb_endianness_4_w                  = 2'b0;
     assign csysreq_4_w                                   = 1'b1;
     assign hclk_5_w                                      = 1'b0;
     assign hresetn_5_w                                   = 1'b0;
     assign hsel_5_w                                      = 1'b0;
     assign hmaster_5_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_5_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_5_w                                    = 1'b0;
     assign hmastlock_5_w                                 = 1'b0;
     assign hburst_5_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_5_w                                   = 1'b0;
     assign htrans_5_w                                    = 2'b0;
     assign hsize_5_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_5_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_5_w                                    = {`UMCTL2_PORT_DW_5{1'b0}};
     assign hready_5_w                                    = {1'b0};

     assign reg_arba5_ahb_endianness_5_w                  = 2'b0;
     assign csysreq_5_w                                   = 1'b1;
     assign hclk_6_w                                      = 1'b0;
     assign hresetn_6_w                                   = 1'b0;
     assign hsel_6_w                                      = 1'b0;
     assign hmaster_6_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_6_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_6_w                                    = 1'b0;
     assign hmastlock_6_w                                 = 1'b0;
     assign hburst_6_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_6_w                                   = 1'b0;
     assign htrans_6_w                                    = 2'b0;
     assign hsize_6_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_6_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_6_w                                    = {`UMCTL2_PORT_DW_6{1'b0}};
     assign hready_6_w                                    = {1'b0};

     assign reg_arba6_ahb_endianness_6_w                  = 2'b0;
     assign csysreq_6_w                                   = 1'b1;
     assign hclk_7_w                                      = 1'b0;
     assign hresetn_7_w                                   = 1'b0;
     assign hsel_7_w                                      = 1'b0;
     assign hmaster_7_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_7_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_7_w                                    = 1'b0;
     assign hmastlock_7_w                                 = 1'b0;
     assign hburst_7_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_7_w                                   = 1'b0;
     assign htrans_7_w                                    = 2'b0;
     assign hsize_7_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_7_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_7_w                                    = {`UMCTL2_PORT_DW_7{1'b0}};
     assign hready_7_w                                    = {1'b0};

     assign reg_arba7_ahb_endianness_7_w                  = 2'b0;
     assign csysreq_7_w                                   = 1'b1;
     assign hclk_8_w                                      = 1'b0;
     assign hresetn_8_w                                   = 1'b0;
     assign hsel_8_w                                      = 1'b0;
     assign hmaster_8_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_8_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_8_w                                    = 1'b0;
     assign hmastlock_8_w                                 = 1'b0;
     assign hburst_8_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_8_w                                   = 1'b0;
     assign htrans_8_w                                    = 2'b0;
     assign hsize_8_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_8_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_8_w                                    = {`UMCTL2_PORT_DW_8{1'b0}};
     assign hready_8_w                                    = {1'b0};

     assign reg_arba8_ahb_endianness_8_w                  = 2'b0;
     assign csysreq_8_w                                   = 1'b1;
     assign hclk_9_w                                      = 1'b0;
     assign hresetn_9_w                                   = 1'b0;
     assign hsel_9_w                                      = 1'b0;
     assign hmaster_9_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_9_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_9_w                                    = 1'b0;
     assign hmastlock_9_w                                 = 1'b0;
     assign hburst_9_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_9_w                                   = 1'b0;
     assign htrans_9_w                                    = 2'b0;
     assign hsize_9_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_9_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_9_w                                    = {`UMCTL2_PORT_DW_9{1'b0}};
     assign hready_9_w                                    = {1'b0};

     assign reg_arba9_ahb_endianness_9_w                  = 2'b0;
     assign csysreq_9_w                                   = 1'b1;
     assign hclk_10_w                                      = 1'b0;
     assign hresetn_10_w                                   = 1'b0;
     assign hsel_10_w                                      = 1'b0;
     assign hmaster_10_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_10_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_10_w                                    = 1'b0;
     assign hmastlock_10_w                                 = 1'b0;
     assign hburst_10_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_10_w                                   = 1'b0;
     assign htrans_10_w                                    = 2'b0;
     assign hsize_10_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_10_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_10_w                                    = {`UMCTL2_PORT_DW_10{1'b0}};
     assign hready_10_w                                    = {1'b0};

     assign reg_arba10_ahb_endianness_10_w                  = 2'b0;
     assign csysreq_10_w                                   = 1'b1;
     assign hclk_11_w                                      = 1'b0;
     assign hresetn_11_w                                   = 1'b0;
     assign hsel_11_w                                      = 1'b0;
     assign hmaster_11_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_11_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_11_w                                    = 1'b0;
     assign hmastlock_11_w                                 = 1'b0;
     assign hburst_11_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_11_w                                   = 1'b0;
     assign htrans_11_w                                    = 2'b0;
     assign hsize_11_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_11_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_11_w                                    = {`UMCTL2_PORT_DW_11{1'b0}};
     assign hready_11_w                                    = {1'b0};

     assign reg_arba11_ahb_endianness_11_w                  = 2'b0;
     assign csysreq_11_w                                   = 1'b1;
     assign hclk_12_w                                      = 1'b0;
     assign hresetn_12_w                                   = 1'b0;
     assign hsel_12_w                                      = 1'b0;
     assign hmaster_12_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_12_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_12_w                                    = 1'b0;
     assign hmastlock_12_w                                 = 1'b0;
     assign hburst_12_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_12_w                                   = 1'b0;
     assign htrans_12_w                                    = 2'b0;
     assign hsize_12_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_12_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_12_w                                    = {`UMCTL2_PORT_DW_12{1'b0}};
     assign hready_12_w                                    = {1'b0};

     assign reg_arba12_ahb_endianness_12_w                  = 2'b0;
     assign csysreq_12_w                                   = 1'b1;
     assign hclk_13_w                                      = 1'b0;
     assign hresetn_13_w                                   = 1'b0;
     assign hsel_13_w                                      = 1'b0;
     assign hmaster_13_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_13_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_13_w                                    = 1'b0;
     assign hmastlock_13_w                                 = 1'b0;
     assign hburst_13_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_13_w                                   = 1'b0;
     assign htrans_13_w                                    = 2'b0;
     assign hsize_13_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_13_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_13_w                                    = {`UMCTL2_PORT_DW_13{1'b0}};
     assign hready_13_w                                    = {1'b0};

     assign reg_arba13_ahb_endianness_13_w                  = 2'b0;
     assign csysreq_13_w                                   = 1'b1;
     assign hclk_14_w                                      = 1'b0;
     assign hresetn_14_w                                   = 1'b0;
     assign hsel_14_w                                      = 1'b0;
     assign hmaster_14_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_14_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_14_w                                    = 1'b0;
     assign hmastlock_14_w                                 = 1'b0;
     assign hburst_14_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_14_w                                   = 1'b0;
     assign htrans_14_w                                    = 2'b0;
     assign hsize_14_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_14_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_14_w                                    = {`UMCTL2_PORT_DW_14{1'b0}};
     assign hready_14_w                                    = {1'b0};

     assign reg_arba14_ahb_endianness_14_w                  = 2'b0;
     assign csysreq_14_w                                   = 1'b1;
     assign hclk_15_w                                      = 1'b0;
     assign hresetn_15_w                                   = 1'b0;
     assign hsel_15_w                                      = 1'b0;
     assign hmaster_15_w                                   = {AHB_HMASTERW{1'b0}};
     assign haddr_15_w                                     = {`UMCTL2_A_ADDRW{1'b0}};
     assign hwrite_15_w                                    = 1'b0;
     assign hmastlock_15_w                                 = 1'b0;
     assign hburst_15_w                                    = {AHB_HBURSTW{1'b0}};
     assign hresize_15_w                                   = 1'b0;
     assign htrans_15_w                                    = 2'b0;
     assign hsize_15_w                                     = {AHB_HSIZEW{1'b0}};
     assign hprot_15_w                                     = {AHB_HPROTW{1'b0}};
     assign hwdata_15_w                                    = {`UMCTL2_PORT_DW_15{1'b0}};
     assign hready_15_w                                    = {1'b0};

     assign reg_arba15_ahb_endianness_15_w                  = 2'b0;
     assign csysreq_15_w                                   = 1'b1;

    assign reg_ddrc_lpddr4_w                             = reg_ddrc_lpddr4; //connect to real input
    assign reg_ddrc_lpddr5_w                             = reg_ddrc_lpddr5;
    assign reg_ddrc_dm_en_w                              = reg_ddrc_dm_en; //connect to real input
    assign reg_ddrc_ecc_mode_w                           = 3'b000;

    assign reg_ddrc_ecc_region_map_w                     = 1'b0;
    assign reg_ddrc_ecc_region_map_granu_w               = 1'b0;
    assign reg_ddrc_ecc_region_map_other_w               = 1'b0;
    assign ddrc_xpi_port_disable_req_w                   = 1'b0;
    assign ddrc_xpi_clock_required_w                     = 1'b0;


    assign reg_ddrc_burstchop_w                          = 1'b0;
    assign reg_ddrc_wr_crc_enable_w                         = 1'b0;
    assign reg_ddrc_col_addr_shift_w                     = 1'b0;

     //Added to avoid sva_xpi.sv failure.
     assign raqb_wcount_0 = raqb_wcount_vector[AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(0+2)-1:AXI_RAQD_LG2_NB*(0+1)]-1:AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(0+1)-1:AXI_RAQD_LG2_NB*0]];
     assign raqr_wcount_0 = raqr_wcount_vector[AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(0+2)-1:AXI_RAQD_LG2_NB*(0+1)]-1:AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(0+1)-1:AXI_RAQD_LG2_NB*0]];
     assign raq_wcount_0 = raqb_wcount_vector[AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(0+2)-1:AXI_RAQD_LG2_NB*(0+1)]-1:AXI_RAQD_LG2_BUS_TABLE[AXI_RAQD_LG2_NB*(0+1)-1:AXI_RAQD_LG2_NB*0]];
     assign waq_wcount_0  = waq_wcount_vector[AXI_WAQD_LG2_BUS_TABLE[AXI_WAQD_LG2_NB*(0+2)-1:AXI_WAQD_LG2_NB*(0+1)]-1:AXI_WAQD_LG2_BUS_TABLE[AXI_WAQD_LG2_NB*(0+1)-1:AXI_WAQD_LG2_NB*0]];

















    assign reg_ddrc_addrmap_row_b16_w                    = reg_ddrc_addrmap_row_b16_map0; //connect to real input
    assign reg_ddrc_addrmap_row_b17_w                    = reg_ddrc_addrmap_row_b17_map0; //connect to real input

// Assign Input Vectors
  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(0+1)-1 : REG_PORT_PRIORITYW*0] = reg_arb_wr_port_priority_0_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(0+1)-1 : REG_PORT_PRIORITYW*0] = reg_arb_rd_port_priority_0_w;
  assign reg_arb_wr_port_aging_en_vector[0]                                               = reg_arb_wr_port_aging_en_0_w;
  assign reg_arb_rd_port_aging_en_vector[0]                                               = reg_arb_rd_port_aging_en_0_w;
  assign reg_arb_wr_port_urgent_en_vector[0]                                              = reg_arb_wr_port_urgent_en_0_w;
  assign reg_arb_rd_port_urgent_en_vector[0]                                              = reg_arb_rd_port_urgent_en_0_w;

  assign aclk_vector[0]                                                                   = aclk_0_w;
  assign aresetn_vector[0]                                                                = aresetn_0_w;
  assign sync_aresetn_vector[0]                                                           = sync_aresetn_0_w;
  assign csysreq_xpi_vector[0]                                                            = csysreq_xpi_0_w;
  assign reg_arb_port_en_vector[0]                                                        = reg_arba0_port_en_0_w;
  assign reg_arb_bypass_reorder_vector[0]                                                 = reg_arba0_read_reorder_bypass_en_0_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(0+2)-1:ARB_ID_NB*(0+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(0+1)-1:ARB_ID_NB*0]]  = reg_arba0_id_mask_0_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(0+2)-1:ARB_ID_NB*(0+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(0+1)-1:ARB_ID_NB*0]] = reg_arba0_id_value_0_w;

  assign awid_vector[AXI_IDW*(0+1)-1 : AXI_IDW*0]                                           = awid_0_w;
  assign awaddr_vector[AXI_ADDRW*(0+1)-1 : AXI_ADDRW*0]                                     = awaddr_0_w;
  assign awlen_vector[AXI_LENW*(0+1)-1 : AXI_LENW*0]                                        = awlen_0_w;
  assign awsize_vector[AXI_SIZEW*(0+1)-1 : AXI_SIZEW*0]                                     = awsize_0_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(0+2)-1:AXI_LOCKW_NB*(0+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(0+1)-1:AXI_LOCKW_NB*0]] = awlock_0_w;
  assign awburst_vector[AXI_BURSTW*(0+1)-1 : AXI_BURSTW*0]                                  = awburst_0_w;
  assign awcache_vector[AXI_CACHEW*(0+1)-1 : AXI_CACHEW*0]                                  = awcache_0_w;
  assign awprot_vector[AXI_PROTW*(0+1)-1 : AXI_PROTW*0]                                     = awprot_0_w;
  assign awqos_vector[AXI_QOSW*(0+1)-1 : AXI_QOSW*0]                                        = awqos_0_w;
  assign awurgent_vector[0]                                                                 = awurgent_0_w;
  assign awpoison_vector[0]                                                                 = awpoison_0_w;
  assign awautopre_vector[0]                                                                = awautopre_0_w;
  assign awvalid_vector[0]                                                                  = awvalid_0_w;
  assign awuser_vector[AXI_USERW*(0+1)-1 : AXI_USERW*0]                                     = awuser_0_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(0+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*0]       = awparity_0_w;

  assign wid_vector[AXI_IDW*(0+1)-1 : AXI_IDW*0]                                            = wid_0_w;
  assign wdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(0+2)-1:AXI_DW_NB*(0+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(0+1)-1:AXI_DW_NB*0]]               = wdata_0_w;
  assign wparity_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(0+2)-1:AXI_STRBW_NB*(0+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(0+1)-1:AXI_STRBW_NB*0]] = wparity_0_w;
  assign wstrb_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(0+2)-1:AXI_STRBW_NB*(0+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(0+1)-1:AXI_STRBW_NB*0]]   = wstrb_0_w;
  assign wlast_vector[0]                                                                    = wlast_0_w;
  assign wvalid_vector[0]                                                                   = wvalid_0_w;
  assign wuser_vector[AXI_USERW*(0+1)-1 : AXI_USERW*0]                                      = wuser_0_w;

  assign bready_vector[0]                                                                   = bready_0_w;

  assign arid_vector[AXI_IDW*(0+1)-1 : AXI_IDW*0]                                           = arid_0_w;
  assign araddr_vector[AXI_ADDRW*(0+1)-1 : AXI_ADDRW*0]                                     = araddr_0_w;
  assign arlen_vector[AXI_LENW*(0+1)-1 : AXI_LENW*0]                                        = arlen_0_w;
  assign arsize_vector[AXI_SIZEW*(0+1)-1 : AXI_SIZEW*0]                                     = arsize_0_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(0+2)-1:AXI_LOCKW_NB*(0+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(0+1)-1:AXI_LOCKW_NB*0]] = arlock_0_w;
  assign arburst_vector[AXI_BURSTW*(0+1)-1 : AXI_BURSTW*0]                                  = arburst_0_w;
  assign arcache_vector[AXI_CACHEW*(0+1)-1 : AXI_CACHEW*0]                                  = arcache_0_w;
  assign arprot_vector[AXI_PROTW*(0+1)-1 : AXI_PROTW*0]                                     = arprot_0_w;
  assign arqos_vector[AXI_QOSW*(0+1)-1 : AXI_QOSW*0]                                        = arqos_0_w;
  assign arurgentb_vector[0]                                                                = arurgentb_0_w;
  assign arurgentr_vector[0]                                                                = arurgentr_0_w;
  assign arpoison_vector[0]                                                                 = arpoison_0_w;
  assign arautopre_vector[0]                                                                = arautopre_0_w;
  assign arvalid_vector[0]                                                                  = arvalid_0_w;
  assign aruser_vector[AXI_USERW*(0+1)-1 : AXI_USERW*0]                                     = aruser_0_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(0+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*0]  = arparity_0_w;

  assign rready_vector[0]                                                                   = rready_0_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(0+1)-1 : UMCTL2_RDATARAM_DW*0]                 = rdataram_dout_0_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(0+1)-1 : UMCTL2_DATARAM_PAR_DW*0]       = rdataram_dout_par_0_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(0+1)-1 : UMCTL2_RDATARAM_DW*0]            = rdataram_dout_dch1_0_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(0+1)-1 : UMCTL2_DATARAM_PAR_DW*0]  = rdataram_dout_par_dch1_0_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(0+1)-1 : XPI_RQOS_MLW*0]                  = reg_arba0_rqos_map_level1_0_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(0+1)-1 : XPI_RQOS_MLW*0]                  = reg_arba0_rqos_map_level2_0_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(0+1)-1 : XPI_RQOS_RW*0]                   = reg_arba0_rqos_map_region0_0_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(0+1)-1 : XPI_RQOS_RW*0]                   = reg_arba0_rqos_map_region1_0_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(0+1)-1 : XPI_RQOS_RW*0]                   = reg_arba0_rqos_map_region2_0_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(0+1)-1 : HIF_RQOS_TW*0]                   = reg_arb_rqos_map_timeoutb_0_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(0+1)-1 : HIF_RQOS_TW*0]                   = reg_arb_rqos_map_timeoutr_0_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(0+1)-1 : XPI_WQOS_MLW*0]                  = reg_arba0_wqos_map_level1_0_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(0+1)-1 : XPI_WQOS_MLW*0]                  = reg_arba0_wqos_map_level2_0_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(0+1)-1 : XPI_WQOS_RW*0]                   = reg_arba0_wqos_map_region0_0_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(0+1)-1 : XPI_WQOS_RW*0]                   = reg_arba0_wqos_map_region1_0_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(0+1)-1 : XPI_WQOS_RW*0]                   = reg_arba0_wqos_map_region2_0_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(0+1)-1 : HIF_WQOS_TW*0]                   = reg_arb_wqos_map_timeout1_0_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(0+1)-1 : HIF_WQOS_TW*0]                   = reg_arb_wqos_map_timeout2_0_w;

  assign reg_arb_rd_port_pagematch_en_vector[0]                                                 = reg_arb_rd_port_pagematch_en_0_w;
  assign reg_arb_wr_port_pagematch_en_vector[0]                                                 = reg_arb_wr_port_pagematch_en_0_w;

  assign reg_arb_rdwr_ordered_en_vector[0]                                                      = reg_arb_rdwr_ordered_en_0_w;
  assign reg_arba_rdwr_ordered_en_vector[0]                                                     = reg_arba0_rdwr_ordered_en_0_w;
  assign reg_arb_port_data_channel_vector[0]                                                    = reg_arb_port_data_channel_0_w;
  assign reg_arba_data_bus_width_vector[2*(0+1)-1 : 2*0]                                        = reg_arba_data_bus_width_0_w;
  assign reg_xpi_snf_mode_vector[0]                                                             = reg_xpi_snf_mode_0_w;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(0+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*0]  = reg_arb_rrb_lock_threshold_0_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(1+1)-1 : REG_PORT_PRIORITYW*1] = reg_arb_wr_port_priority_1_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(1+1)-1 : REG_PORT_PRIORITYW*1] = reg_arb_rd_port_priority_1_w;
  assign reg_arb_wr_port_aging_en_vector[1]                                               = reg_arb_wr_port_aging_en_1_w;
  assign reg_arb_rd_port_aging_en_vector[1]                                               = reg_arb_rd_port_aging_en_1_w;
  assign reg_arb_wr_port_urgent_en_vector[1]                                              = reg_arb_wr_port_urgent_en_1_w;
  assign reg_arb_rd_port_urgent_en_vector[1]                                              = reg_arb_rd_port_urgent_en_1_w;

  assign aclk_vector[1]                                                                   = aclk_1_w;
  assign aresetn_vector[1]                                                                = aresetn_1_w;
  assign sync_aresetn_vector[1]                                                           = sync_aresetn_1_w;
  assign csysreq_xpi_vector[1]                                                            = csysreq_xpi_1_w;
  assign reg_arb_port_en_vector[1]                                                        = reg_arba1_port_en_1_w;
  assign reg_arb_bypass_reorder_vector[1]                                                 = reg_arba1_read_reorder_bypass_en_1_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(1+2)-1:ARB_ID_NB*(1+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(1+1)-1:ARB_ID_NB*1]]  = reg_arba1_id_mask_1_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(1+2)-1:ARB_ID_NB*(1+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(1+1)-1:ARB_ID_NB*1]] = reg_arba1_id_value_1_w;

  assign awid_vector[AXI_IDW*(1+1)-1 : AXI_IDW*1]                                           = awid_1_w;
  assign awaddr_vector[AXI_ADDRW*(1+1)-1 : AXI_ADDRW*1]                                     = awaddr_1_w;
  assign awlen_vector[AXI_LENW*(1+1)-1 : AXI_LENW*1]                                        = awlen_1_w;
  assign awsize_vector[AXI_SIZEW*(1+1)-1 : AXI_SIZEW*1]                                     = awsize_1_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(1+2)-1:AXI_LOCKW_NB*(1+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(1+1)-1:AXI_LOCKW_NB*1]] = awlock_1_w;
  assign awburst_vector[AXI_BURSTW*(1+1)-1 : AXI_BURSTW*1]                                  = awburst_1_w;
  assign awcache_vector[AXI_CACHEW*(1+1)-1 : AXI_CACHEW*1]                                  = awcache_1_w;
  assign awprot_vector[AXI_PROTW*(1+1)-1 : AXI_PROTW*1]                                     = awprot_1_w;
  assign awqos_vector[AXI_QOSW*(1+1)-1 : AXI_QOSW*1]                                        = awqos_1_w;
  assign awurgent_vector[1]                                                                 = awurgent_1_w;
  assign awpoison_vector[1]                                                                 = awpoison_1_w;
  assign awautopre_vector[1]                                                                = awautopre_1_w;
  assign awvalid_vector[1]                                                                  = awvalid_1_w;
  assign awuser_vector[AXI_USERW*(1+1)-1 : AXI_USERW*1]                                     = awuser_1_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(1+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*1]       = awparity_1_w;

  assign wid_vector[AXI_IDW*(1+1)-1 : AXI_IDW*1]                                            = wid_1_w;
  assign wlast_vector[1]                                                                    = wlast_1_w;
  assign wvalid_vector[1]                                                                   = wvalid_1_w;
  assign wuser_vector[AXI_USERW*(1+1)-1 : AXI_USERW*1]                                      = wuser_1_w;

  assign bready_vector[1]                                                                   = bready_1_w;

  assign arid_vector[AXI_IDW*(1+1)-1 : AXI_IDW*1]                                           = arid_1_w;
  assign araddr_vector[AXI_ADDRW*(1+1)-1 : AXI_ADDRW*1]                                     = araddr_1_w;
  assign arlen_vector[AXI_LENW*(1+1)-1 : AXI_LENW*1]                                        = arlen_1_w;
  assign arsize_vector[AXI_SIZEW*(1+1)-1 : AXI_SIZEW*1]                                     = arsize_1_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(1+2)-1:AXI_LOCKW_NB*(1+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(1+1)-1:AXI_LOCKW_NB*1]] = arlock_1_w;
  assign arburst_vector[AXI_BURSTW*(1+1)-1 : AXI_BURSTW*1]                                  = arburst_1_w;
  assign arcache_vector[AXI_CACHEW*(1+1)-1 : AXI_CACHEW*1]                                  = arcache_1_w;
  assign arprot_vector[AXI_PROTW*(1+1)-1 : AXI_PROTW*1]                                     = arprot_1_w;
  assign arqos_vector[AXI_QOSW*(1+1)-1 : AXI_QOSW*1]                                        = arqos_1_w;
  assign arurgentb_vector[1]                                                                = arurgentb_1_w;
  assign arurgentr_vector[1]                                                                = arurgentr_1_w;
  assign arpoison_vector[1]                                                                 = arpoison_1_w;
  assign arautopre_vector[1]                                                                = arautopre_1_w;
  assign arvalid_vector[1]                                                                  = arvalid_1_w;
  assign aruser_vector[AXI_USERW*(1+1)-1 : AXI_USERW*1]                                     = aruser_1_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(1+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*1]  = arparity_1_w;

  assign rready_vector[1]                                                                   = rready_1_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(1+1)-1 : UMCTL2_RDATARAM_DW*1]                 = rdataram_dout_1_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(1+1)-1 : UMCTL2_DATARAM_PAR_DW*1]       = rdataram_dout_par_1_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(1+1)-1 : UMCTL2_RDATARAM_DW*1]            = rdataram_dout_dch1_1_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(1+1)-1 : UMCTL2_DATARAM_PAR_DW*1]  = rdataram_dout_par_dch1_1_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(1+1)-1 : XPI_RQOS_MLW*1]                  = reg_arba1_rqos_map_level1_1_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(1+1)-1 : XPI_RQOS_MLW*1]                  = reg_arba1_rqos_map_level2_1_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(1+1)-1 : XPI_RQOS_RW*1]                   = reg_arba1_rqos_map_region0_1_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(1+1)-1 : XPI_RQOS_RW*1]                   = reg_arba1_rqos_map_region1_1_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(1+1)-1 : XPI_RQOS_RW*1]                   = reg_arba1_rqos_map_region2_1_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(1+1)-1 : HIF_RQOS_TW*1]                   = reg_arb_rqos_map_timeoutb_1_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(1+1)-1 : HIF_RQOS_TW*1]                   = reg_arb_rqos_map_timeoutr_1_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(1+1)-1 : XPI_WQOS_MLW*1]                  = reg_arba1_wqos_map_level1_1_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(1+1)-1 : XPI_WQOS_MLW*1]                  = reg_arba1_wqos_map_level2_1_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(1+1)-1 : XPI_WQOS_RW*1]                   = reg_arba1_wqos_map_region0_1_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(1+1)-1 : XPI_WQOS_RW*1]                   = reg_arba1_wqos_map_region1_1_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(1+1)-1 : XPI_WQOS_RW*1]                   = reg_arba1_wqos_map_region2_1_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(1+1)-1 : HIF_WQOS_TW*1]                   = reg_arb_wqos_map_timeout1_1_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(1+1)-1 : HIF_WQOS_TW*1]                   = reg_arb_wqos_map_timeout2_1_w;

  assign reg_arb_rd_port_pagematch_en_vector[1]                                                 = reg_arb_rd_port_pagematch_en_1_w;
  assign reg_arb_wr_port_pagematch_en_vector[1]                                                 = reg_arb_wr_port_pagematch_en_1_w;

  assign reg_arb_rdwr_ordered_en_vector[1]                                                      = reg_arb_rdwr_ordered_en_1_w;
  assign reg_arba_rdwr_ordered_en_vector[1]                                                     = reg_arba1_rdwr_ordered_en_1_w;
  assign reg_arb_port_data_channel_vector[1]                                                    = reg_arb_port_data_channel_1_w;
  assign reg_arba_data_bus_width_vector[2*(1+1)-1 : 2*1]                                        = reg_arba_data_bus_width_1_w;
  assign reg_xpi_snf_mode_vector[1]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(1+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*1]  = reg_arb_rrb_lock_threshold_1_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(2+1)-1 : REG_PORT_PRIORITYW*2] = reg_arb_wr_port_priority_2_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(2+1)-1 : REG_PORT_PRIORITYW*2] = reg_arb_rd_port_priority_2_w;
  assign reg_arb_wr_port_aging_en_vector[2]                                               = reg_arb_wr_port_aging_en_2_w;
  assign reg_arb_rd_port_aging_en_vector[2]                                               = reg_arb_rd_port_aging_en_2_w;
  assign reg_arb_wr_port_urgent_en_vector[2]                                              = reg_arb_wr_port_urgent_en_2_w;
  assign reg_arb_rd_port_urgent_en_vector[2]                                              = reg_arb_rd_port_urgent_en_2_w;

  assign aclk_vector[2]                                                                   = aclk_2_w;
  assign aresetn_vector[2]                                                                = aresetn_2_w;
  assign sync_aresetn_vector[2]                                                           = sync_aresetn_2_w;
  assign csysreq_xpi_vector[2]                                                            = csysreq_xpi_2_w;
  assign reg_arb_port_en_vector[2]                                                        = reg_arba2_port_en_2_w;
  assign reg_arb_bypass_reorder_vector[2]                                                 = reg_arba2_read_reorder_bypass_en_2_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(2+2)-1:ARB_ID_NB*(2+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(2+1)-1:ARB_ID_NB*2]]  = reg_arba2_id_mask_2_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(2+2)-1:ARB_ID_NB*(2+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(2+1)-1:ARB_ID_NB*2]] = reg_arba2_id_value_2_w;

  assign awid_vector[AXI_IDW*(2+1)-1 : AXI_IDW*2]                                           = awid_2_w;
  assign awaddr_vector[AXI_ADDRW*(2+1)-1 : AXI_ADDRW*2]                                     = awaddr_2_w;
  assign awlen_vector[AXI_LENW*(2+1)-1 : AXI_LENW*2]                                        = awlen_2_w;
  assign awsize_vector[AXI_SIZEW*(2+1)-1 : AXI_SIZEW*2]                                     = awsize_2_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(2+2)-1:AXI_LOCKW_NB*(2+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(2+1)-1:AXI_LOCKW_NB*2]] = awlock_2_w;
  assign awburst_vector[AXI_BURSTW*(2+1)-1 : AXI_BURSTW*2]                                  = awburst_2_w;
  assign awcache_vector[AXI_CACHEW*(2+1)-1 : AXI_CACHEW*2]                                  = awcache_2_w;
  assign awprot_vector[AXI_PROTW*(2+1)-1 : AXI_PROTW*2]                                     = awprot_2_w;
  assign awqos_vector[AXI_QOSW*(2+1)-1 : AXI_QOSW*2]                                        = awqos_2_w;
  assign awurgent_vector[2]                                                                 = awurgent_2_w;
  assign awpoison_vector[2]                                                                 = awpoison_2_w;
  assign awautopre_vector[2]                                                                = awautopre_2_w;
  assign awvalid_vector[2]                                                                  = awvalid_2_w;
  assign awuser_vector[AXI_USERW*(2+1)-1 : AXI_USERW*2]                                     = awuser_2_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(2+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*2]       = awparity_2_w;

  assign wid_vector[AXI_IDW*(2+1)-1 : AXI_IDW*2]                                            = wid_2_w;
  assign wlast_vector[2]                                                                    = wlast_2_w;
  assign wvalid_vector[2]                                                                   = wvalid_2_w;
  assign wuser_vector[AXI_USERW*(2+1)-1 : AXI_USERW*2]                                      = wuser_2_w;

  assign bready_vector[2]                                                                   = bready_2_w;

  assign arid_vector[AXI_IDW*(2+1)-1 : AXI_IDW*2]                                           = arid_2_w;
  assign araddr_vector[AXI_ADDRW*(2+1)-1 : AXI_ADDRW*2]                                     = araddr_2_w;
  assign arlen_vector[AXI_LENW*(2+1)-1 : AXI_LENW*2]                                        = arlen_2_w;
  assign arsize_vector[AXI_SIZEW*(2+1)-1 : AXI_SIZEW*2]                                     = arsize_2_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(2+2)-1:AXI_LOCKW_NB*(2+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(2+1)-1:AXI_LOCKW_NB*2]] = arlock_2_w;
  assign arburst_vector[AXI_BURSTW*(2+1)-1 : AXI_BURSTW*2]                                  = arburst_2_w;
  assign arcache_vector[AXI_CACHEW*(2+1)-1 : AXI_CACHEW*2]                                  = arcache_2_w;
  assign arprot_vector[AXI_PROTW*(2+1)-1 : AXI_PROTW*2]                                     = arprot_2_w;
  assign arqos_vector[AXI_QOSW*(2+1)-1 : AXI_QOSW*2]                                        = arqos_2_w;
  assign arurgentb_vector[2]                                                                = arurgentb_2_w;
  assign arurgentr_vector[2]                                                                = arurgentr_2_w;
  assign arpoison_vector[2]                                                                 = arpoison_2_w;
  assign arautopre_vector[2]                                                                = arautopre_2_w;
  assign arvalid_vector[2]                                                                  = arvalid_2_w;
  assign aruser_vector[AXI_USERW*(2+1)-1 : AXI_USERW*2]                                     = aruser_2_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(2+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*2]  = arparity_2_w;

  assign rready_vector[2]                                                                   = rready_2_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(2+1)-1 : UMCTL2_RDATARAM_DW*2]                 = rdataram_dout_2_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(2+1)-1 : UMCTL2_DATARAM_PAR_DW*2]       = rdataram_dout_par_2_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(2+1)-1 : UMCTL2_RDATARAM_DW*2]            = rdataram_dout_dch1_2_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(2+1)-1 : UMCTL2_DATARAM_PAR_DW*2]  = rdataram_dout_par_dch1_2_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(2+1)-1 : XPI_RQOS_MLW*2]                  = reg_arba2_rqos_map_level1_2_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(2+1)-1 : XPI_RQOS_MLW*2]                  = reg_arba2_rqos_map_level2_2_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(2+1)-1 : XPI_RQOS_RW*2]                   = reg_arba2_rqos_map_region0_2_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(2+1)-1 : XPI_RQOS_RW*2]                   = reg_arba2_rqos_map_region1_2_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(2+1)-1 : XPI_RQOS_RW*2]                   = reg_arba2_rqos_map_region2_2_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(2+1)-1 : HIF_RQOS_TW*2]                   = reg_arb_rqos_map_timeoutb_2_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(2+1)-1 : HIF_RQOS_TW*2]                   = reg_arb_rqos_map_timeoutr_2_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(2+1)-1 : XPI_WQOS_MLW*2]                  = reg_arba2_wqos_map_level1_2_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(2+1)-1 : XPI_WQOS_MLW*2]                  = reg_arba2_wqos_map_level2_2_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(2+1)-1 : XPI_WQOS_RW*2]                   = reg_arba2_wqos_map_region0_2_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(2+1)-1 : XPI_WQOS_RW*2]                   = reg_arba2_wqos_map_region1_2_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(2+1)-1 : XPI_WQOS_RW*2]                   = reg_arba2_wqos_map_region2_2_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(2+1)-1 : HIF_WQOS_TW*2]                   = reg_arb_wqos_map_timeout1_2_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(2+1)-1 : HIF_WQOS_TW*2]                   = reg_arb_wqos_map_timeout2_2_w;

  assign reg_arb_rd_port_pagematch_en_vector[2]                                                 = reg_arb_rd_port_pagematch_en_2_w;
  assign reg_arb_wr_port_pagematch_en_vector[2]                                                 = reg_arb_wr_port_pagematch_en_2_w;

  assign reg_arb_rdwr_ordered_en_vector[2]                                                      = reg_arb_rdwr_ordered_en_2_w;
  assign reg_arba_rdwr_ordered_en_vector[2]                                                     = reg_arba2_rdwr_ordered_en_2_w;
  assign reg_arb_port_data_channel_vector[2]                                                    = reg_arb_port_data_channel_2_w;
  assign reg_arba_data_bus_width_vector[2*(2+1)-1 : 2*2]                                        = reg_arba_data_bus_width_2_w;
  assign reg_xpi_snf_mode_vector[2]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(2+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*2]  = reg_arb_rrb_lock_threshold_2_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(3+1)-1 : REG_PORT_PRIORITYW*3] = reg_arb_wr_port_priority_3_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(3+1)-1 : REG_PORT_PRIORITYW*3] = reg_arb_rd_port_priority_3_w;
  assign reg_arb_wr_port_aging_en_vector[3]                                               = reg_arb_wr_port_aging_en_3_w;
  assign reg_arb_rd_port_aging_en_vector[3]                                               = reg_arb_rd_port_aging_en_3_w;
  assign reg_arb_wr_port_urgent_en_vector[3]                                              = reg_arb_wr_port_urgent_en_3_w;
  assign reg_arb_rd_port_urgent_en_vector[3]                                              = reg_arb_rd_port_urgent_en_3_w;

  assign aclk_vector[3]                                                                   = aclk_3_w;
  assign aresetn_vector[3]                                                                = aresetn_3_w;
  assign sync_aresetn_vector[3]                                                           = sync_aresetn_3_w;
  assign csysreq_xpi_vector[3]                                                            = csysreq_xpi_3_w;
  assign reg_arb_port_en_vector[3]                                                        = reg_arba3_port_en_3_w;
  assign reg_arb_bypass_reorder_vector[3]                                                 = reg_arba3_read_reorder_bypass_en_3_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(3+2)-1:ARB_ID_NB*(3+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(3+1)-1:ARB_ID_NB*3]]  = reg_arba3_id_mask_3_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(3+2)-1:ARB_ID_NB*(3+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(3+1)-1:ARB_ID_NB*3]] = reg_arba3_id_value_3_w;

  assign awid_vector[AXI_IDW*(3+1)-1 : AXI_IDW*3]                                           = awid_3_w;
  assign awaddr_vector[AXI_ADDRW*(3+1)-1 : AXI_ADDRW*3]                                     = awaddr_3_w;
  assign awlen_vector[AXI_LENW*(3+1)-1 : AXI_LENW*3]                                        = awlen_3_w;
  assign awsize_vector[AXI_SIZEW*(3+1)-1 : AXI_SIZEW*3]                                     = awsize_3_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(3+2)-1:AXI_LOCKW_NB*(3+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(3+1)-1:AXI_LOCKW_NB*3]] = awlock_3_w;
  assign awburst_vector[AXI_BURSTW*(3+1)-1 : AXI_BURSTW*3]                                  = awburst_3_w;
  assign awcache_vector[AXI_CACHEW*(3+1)-1 : AXI_CACHEW*3]                                  = awcache_3_w;
  assign awprot_vector[AXI_PROTW*(3+1)-1 : AXI_PROTW*3]                                     = awprot_3_w;
  assign awqos_vector[AXI_QOSW*(3+1)-1 : AXI_QOSW*3]                                        = awqos_3_w;
  assign awurgent_vector[3]                                                                 = awurgent_3_w;
  assign awpoison_vector[3]                                                                 = awpoison_3_w;
  assign awautopre_vector[3]                                                                = awautopre_3_w;
  assign awvalid_vector[3]                                                                  = awvalid_3_w;
  assign awuser_vector[AXI_USERW*(3+1)-1 : AXI_USERW*3]                                     = awuser_3_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(3+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*3]       = awparity_3_w;

  assign wid_vector[AXI_IDW*(3+1)-1 : AXI_IDW*3]                                            = wid_3_w;
  assign wlast_vector[3]                                                                    = wlast_3_w;
  assign wvalid_vector[3]                                                                   = wvalid_3_w;
  assign wuser_vector[AXI_USERW*(3+1)-1 : AXI_USERW*3]                                      = wuser_3_w;

  assign bready_vector[3]                                                                   = bready_3_w;

  assign arid_vector[AXI_IDW*(3+1)-1 : AXI_IDW*3]                                           = arid_3_w;
  assign araddr_vector[AXI_ADDRW*(3+1)-1 : AXI_ADDRW*3]                                     = araddr_3_w;
  assign arlen_vector[AXI_LENW*(3+1)-1 : AXI_LENW*3]                                        = arlen_3_w;
  assign arsize_vector[AXI_SIZEW*(3+1)-1 : AXI_SIZEW*3]                                     = arsize_3_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(3+2)-1:AXI_LOCKW_NB*(3+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(3+1)-1:AXI_LOCKW_NB*3]] = arlock_3_w;
  assign arburst_vector[AXI_BURSTW*(3+1)-1 : AXI_BURSTW*3]                                  = arburst_3_w;
  assign arcache_vector[AXI_CACHEW*(3+1)-1 : AXI_CACHEW*3]                                  = arcache_3_w;
  assign arprot_vector[AXI_PROTW*(3+1)-1 : AXI_PROTW*3]                                     = arprot_3_w;
  assign arqos_vector[AXI_QOSW*(3+1)-1 : AXI_QOSW*3]                                        = arqos_3_w;
  assign arurgentb_vector[3]                                                                = arurgentb_3_w;
  assign arurgentr_vector[3]                                                                = arurgentr_3_w;
  assign arpoison_vector[3]                                                                 = arpoison_3_w;
  assign arautopre_vector[3]                                                                = arautopre_3_w;
  assign arvalid_vector[3]                                                                  = arvalid_3_w;
  assign aruser_vector[AXI_USERW*(3+1)-1 : AXI_USERW*3]                                     = aruser_3_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(3+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*3]  = arparity_3_w;

  assign rready_vector[3]                                                                   = rready_3_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(3+1)-1 : UMCTL2_RDATARAM_DW*3]                 = rdataram_dout_3_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(3+1)-1 : UMCTL2_DATARAM_PAR_DW*3]       = rdataram_dout_par_3_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(3+1)-1 : UMCTL2_RDATARAM_DW*3]            = rdataram_dout_dch1_3_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(3+1)-1 : UMCTL2_DATARAM_PAR_DW*3]  = rdataram_dout_par_dch1_3_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(3+1)-1 : XPI_RQOS_MLW*3]                  = reg_arba3_rqos_map_level1_3_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(3+1)-1 : XPI_RQOS_MLW*3]                  = reg_arba3_rqos_map_level2_3_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(3+1)-1 : XPI_RQOS_RW*3]                   = reg_arba3_rqos_map_region0_3_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(3+1)-1 : XPI_RQOS_RW*3]                   = reg_arba3_rqos_map_region1_3_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(3+1)-1 : XPI_RQOS_RW*3]                   = reg_arba3_rqos_map_region2_3_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(3+1)-1 : HIF_RQOS_TW*3]                   = reg_arb_rqos_map_timeoutb_3_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(3+1)-1 : HIF_RQOS_TW*3]                   = reg_arb_rqos_map_timeoutr_3_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(3+1)-1 : XPI_WQOS_MLW*3]                  = reg_arba3_wqos_map_level1_3_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(3+1)-1 : XPI_WQOS_MLW*3]                  = reg_arba3_wqos_map_level2_3_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(3+1)-1 : XPI_WQOS_RW*3]                   = reg_arba3_wqos_map_region0_3_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(3+1)-1 : XPI_WQOS_RW*3]                   = reg_arba3_wqos_map_region1_3_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(3+1)-1 : XPI_WQOS_RW*3]                   = reg_arba3_wqos_map_region2_3_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(3+1)-1 : HIF_WQOS_TW*3]                   = reg_arb_wqos_map_timeout1_3_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(3+1)-1 : HIF_WQOS_TW*3]                   = reg_arb_wqos_map_timeout2_3_w;

  assign reg_arb_rd_port_pagematch_en_vector[3]                                                 = reg_arb_rd_port_pagematch_en_3_w;
  assign reg_arb_wr_port_pagematch_en_vector[3]                                                 = reg_arb_wr_port_pagematch_en_3_w;

  assign reg_arb_rdwr_ordered_en_vector[3]                                                      = reg_arb_rdwr_ordered_en_3_w;
  assign reg_arba_rdwr_ordered_en_vector[3]                                                     = reg_arba3_rdwr_ordered_en_3_w;
  assign reg_arb_port_data_channel_vector[3]                                                    = reg_arb_port_data_channel_3_w;
  assign reg_arba_data_bus_width_vector[2*(3+1)-1 : 2*3]                                        = reg_arba_data_bus_width_3_w;
  assign reg_xpi_snf_mode_vector[3]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(3+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*3]  = reg_arb_rrb_lock_threshold_3_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(4+1)-1 : REG_PORT_PRIORITYW*4] = reg_arb_wr_port_priority_4_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(4+1)-1 : REG_PORT_PRIORITYW*4] = reg_arb_rd_port_priority_4_w;
  assign reg_arb_wr_port_aging_en_vector[4]                                               = reg_arb_wr_port_aging_en_4_w;
  assign reg_arb_rd_port_aging_en_vector[4]                                               = reg_arb_rd_port_aging_en_4_w;
  assign reg_arb_wr_port_urgent_en_vector[4]                                              = reg_arb_wr_port_urgent_en_4_w;
  assign reg_arb_rd_port_urgent_en_vector[4]                                              = reg_arb_rd_port_urgent_en_4_w;

  assign aclk_vector[4]                                                                   = aclk_4_w;
  assign aresetn_vector[4]                                                                = aresetn_4_w;
  assign sync_aresetn_vector[4]                                                           = sync_aresetn_4_w;
  assign csysreq_xpi_vector[4]                                                            = csysreq_xpi_4_w;
  assign reg_arb_port_en_vector[4]                                                        = reg_arba4_port_en_4_w;
  assign reg_arb_bypass_reorder_vector[4]                                                 = reg_arba4_read_reorder_bypass_en_4_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(4+2)-1:ARB_ID_NB*(4+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(4+1)-1:ARB_ID_NB*4]]  = reg_arba4_id_mask_4_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(4+2)-1:ARB_ID_NB*(4+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(4+1)-1:ARB_ID_NB*4]] = reg_arba4_id_value_4_w;

  assign awid_vector[AXI_IDW*(4+1)-1 : AXI_IDW*4]                                           = awid_4_w;
  assign awaddr_vector[AXI_ADDRW*(4+1)-1 : AXI_ADDRW*4]                                     = awaddr_4_w;
  assign awlen_vector[AXI_LENW*(4+1)-1 : AXI_LENW*4]                                        = awlen_4_w;
  assign awsize_vector[AXI_SIZEW*(4+1)-1 : AXI_SIZEW*4]                                     = awsize_4_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(4+2)-1:AXI_LOCKW_NB*(4+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(4+1)-1:AXI_LOCKW_NB*4]] = awlock_4_w;
  assign awburst_vector[AXI_BURSTW*(4+1)-1 : AXI_BURSTW*4]                                  = awburst_4_w;
  assign awcache_vector[AXI_CACHEW*(4+1)-1 : AXI_CACHEW*4]                                  = awcache_4_w;
  assign awprot_vector[AXI_PROTW*(4+1)-1 : AXI_PROTW*4]                                     = awprot_4_w;
  assign awqos_vector[AXI_QOSW*(4+1)-1 : AXI_QOSW*4]                                        = awqos_4_w;
  assign awurgent_vector[4]                                                                 = awurgent_4_w;
  assign awpoison_vector[4]                                                                 = awpoison_4_w;
  assign awautopre_vector[4]                                                                = awautopre_4_w;
  assign awvalid_vector[4]                                                                  = awvalid_4_w;
  assign awuser_vector[AXI_USERW*(4+1)-1 : AXI_USERW*4]                                     = awuser_4_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(4+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*4]       = awparity_4_w;

  assign wid_vector[AXI_IDW*(4+1)-1 : AXI_IDW*4]                                            = wid_4_w;
  assign wlast_vector[4]                                                                    = wlast_4_w;
  assign wvalid_vector[4]                                                                   = wvalid_4_w;
  assign wuser_vector[AXI_USERW*(4+1)-1 : AXI_USERW*4]                                      = wuser_4_w;

  assign bready_vector[4]                                                                   = bready_4_w;

  assign arid_vector[AXI_IDW*(4+1)-1 : AXI_IDW*4]                                           = arid_4_w;
  assign araddr_vector[AXI_ADDRW*(4+1)-1 : AXI_ADDRW*4]                                     = araddr_4_w;
  assign arlen_vector[AXI_LENW*(4+1)-1 : AXI_LENW*4]                                        = arlen_4_w;
  assign arsize_vector[AXI_SIZEW*(4+1)-1 : AXI_SIZEW*4]                                     = arsize_4_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(4+2)-1:AXI_LOCKW_NB*(4+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(4+1)-1:AXI_LOCKW_NB*4]] = arlock_4_w;
  assign arburst_vector[AXI_BURSTW*(4+1)-1 : AXI_BURSTW*4]                                  = arburst_4_w;
  assign arcache_vector[AXI_CACHEW*(4+1)-1 : AXI_CACHEW*4]                                  = arcache_4_w;
  assign arprot_vector[AXI_PROTW*(4+1)-1 : AXI_PROTW*4]                                     = arprot_4_w;
  assign arqos_vector[AXI_QOSW*(4+1)-1 : AXI_QOSW*4]                                        = arqos_4_w;
  assign arurgentb_vector[4]                                                                = arurgentb_4_w;
  assign arurgentr_vector[4]                                                                = arurgentr_4_w;
  assign arpoison_vector[4]                                                                 = arpoison_4_w;
  assign arautopre_vector[4]                                                                = arautopre_4_w;
  assign arvalid_vector[4]                                                                  = arvalid_4_w;
  assign aruser_vector[AXI_USERW*(4+1)-1 : AXI_USERW*4]                                     = aruser_4_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(4+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*4]  = arparity_4_w;

  assign rready_vector[4]                                                                   = rready_4_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(4+1)-1 : UMCTL2_RDATARAM_DW*4]                 = rdataram_dout_4_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(4+1)-1 : UMCTL2_DATARAM_PAR_DW*4]       = rdataram_dout_par_4_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(4+1)-1 : UMCTL2_RDATARAM_DW*4]            = rdataram_dout_dch1_4_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(4+1)-1 : UMCTL2_DATARAM_PAR_DW*4]  = rdataram_dout_par_dch1_4_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(4+1)-1 : XPI_RQOS_MLW*4]                  = reg_arba4_rqos_map_level1_4_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(4+1)-1 : XPI_RQOS_MLW*4]                  = reg_arba4_rqos_map_level2_4_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(4+1)-1 : XPI_RQOS_RW*4]                   = reg_arba4_rqos_map_region0_4_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(4+1)-1 : XPI_RQOS_RW*4]                   = reg_arba4_rqos_map_region1_4_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(4+1)-1 : XPI_RQOS_RW*4]                   = reg_arba4_rqos_map_region2_4_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(4+1)-1 : HIF_RQOS_TW*4]                   = reg_arb_rqos_map_timeoutb_4_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(4+1)-1 : HIF_RQOS_TW*4]                   = reg_arb_rqos_map_timeoutr_4_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(4+1)-1 : XPI_WQOS_MLW*4]                  = reg_arba4_wqos_map_level1_4_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(4+1)-1 : XPI_WQOS_MLW*4]                  = reg_arba4_wqos_map_level2_4_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(4+1)-1 : XPI_WQOS_RW*4]                   = reg_arba4_wqos_map_region0_4_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(4+1)-1 : XPI_WQOS_RW*4]                   = reg_arba4_wqos_map_region1_4_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(4+1)-1 : XPI_WQOS_RW*4]                   = reg_arba4_wqos_map_region2_4_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(4+1)-1 : HIF_WQOS_TW*4]                   = reg_arb_wqos_map_timeout1_4_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(4+1)-1 : HIF_WQOS_TW*4]                   = reg_arb_wqos_map_timeout2_4_w;

  assign reg_arb_rd_port_pagematch_en_vector[4]                                                 = reg_arb_rd_port_pagematch_en_4_w;
  assign reg_arb_wr_port_pagematch_en_vector[4]                                                 = reg_arb_wr_port_pagematch_en_4_w;

  assign reg_arb_rdwr_ordered_en_vector[4]                                                      = reg_arb_rdwr_ordered_en_4_w;
  assign reg_arba_rdwr_ordered_en_vector[4]                                                     = reg_arba4_rdwr_ordered_en_4_w;
  assign reg_arb_port_data_channel_vector[4]                                                    = reg_arb_port_data_channel_4_w;
  assign reg_arba_data_bus_width_vector[2*(4+1)-1 : 2*4]                                        = reg_arba_data_bus_width_4_w;
  assign reg_xpi_snf_mode_vector[4]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(4+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*4]  = reg_arb_rrb_lock_threshold_4_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(5+1)-1 : REG_PORT_PRIORITYW*5] = reg_arb_wr_port_priority_5_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(5+1)-1 : REG_PORT_PRIORITYW*5] = reg_arb_rd_port_priority_5_w;
  assign reg_arb_wr_port_aging_en_vector[5]                                               = reg_arb_wr_port_aging_en_5_w;
  assign reg_arb_rd_port_aging_en_vector[5]                                               = reg_arb_rd_port_aging_en_5_w;
  assign reg_arb_wr_port_urgent_en_vector[5]                                              = reg_arb_wr_port_urgent_en_5_w;
  assign reg_arb_rd_port_urgent_en_vector[5]                                              = reg_arb_rd_port_urgent_en_5_w;

  assign aclk_vector[5]                                                                   = aclk_5_w;
  assign aresetn_vector[5]                                                                = aresetn_5_w;
  assign sync_aresetn_vector[5]                                                           = sync_aresetn_5_w;
  assign csysreq_xpi_vector[5]                                                            = csysreq_xpi_5_w;
  assign reg_arb_port_en_vector[5]                                                        = reg_arba5_port_en_5_w;
  assign reg_arb_bypass_reorder_vector[5]                                                 = reg_arba5_read_reorder_bypass_en_5_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(5+2)-1:ARB_ID_NB*(5+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(5+1)-1:ARB_ID_NB*5]]  = reg_arba5_id_mask_5_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(5+2)-1:ARB_ID_NB*(5+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(5+1)-1:ARB_ID_NB*5]] = reg_arba5_id_value_5_w;

  assign awid_vector[AXI_IDW*(5+1)-1 : AXI_IDW*5]                                           = awid_5_w;
  assign awaddr_vector[AXI_ADDRW*(5+1)-1 : AXI_ADDRW*5]                                     = awaddr_5_w;
  assign awlen_vector[AXI_LENW*(5+1)-1 : AXI_LENW*5]                                        = awlen_5_w;
  assign awsize_vector[AXI_SIZEW*(5+1)-1 : AXI_SIZEW*5]                                     = awsize_5_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(5+2)-1:AXI_LOCKW_NB*(5+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(5+1)-1:AXI_LOCKW_NB*5]] = awlock_5_w;
  assign awburst_vector[AXI_BURSTW*(5+1)-1 : AXI_BURSTW*5]                                  = awburst_5_w;
  assign awcache_vector[AXI_CACHEW*(5+1)-1 : AXI_CACHEW*5]                                  = awcache_5_w;
  assign awprot_vector[AXI_PROTW*(5+1)-1 : AXI_PROTW*5]                                     = awprot_5_w;
  assign awqos_vector[AXI_QOSW*(5+1)-1 : AXI_QOSW*5]                                        = awqos_5_w;
  assign awurgent_vector[5]                                                                 = awurgent_5_w;
  assign awpoison_vector[5]                                                                 = awpoison_5_w;
  assign awautopre_vector[5]                                                                = awautopre_5_w;
  assign awvalid_vector[5]                                                                  = awvalid_5_w;
  assign awuser_vector[AXI_USERW*(5+1)-1 : AXI_USERW*5]                                     = awuser_5_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(5+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*5]       = awparity_5_w;

  assign wid_vector[AXI_IDW*(5+1)-1 : AXI_IDW*5]                                            = wid_5_w;
  assign wlast_vector[5]                                                                    = wlast_5_w;
  assign wvalid_vector[5]                                                                   = wvalid_5_w;
  assign wuser_vector[AXI_USERW*(5+1)-1 : AXI_USERW*5]                                      = wuser_5_w;

  assign bready_vector[5]                                                                   = bready_5_w;

  assign arid_vector[AXI_IDW*(5+1)-1 : AXI_IDW*5]                                           = arid_5_w;
  assign araddr_vector[AXI_ADDRW*(5+1)-1 : AXI_ADDRW*5]                                     = araddr_5_w;
  assign arlen_vector[AXI_LENW*(5+1)-1 : AXI_LENW*5]                                        = arlen_5_w;
  assign arsize_vector[AXI_SIZEW*(5+1)-1 : AXI_SIZEW*5]                                     = arsize_5_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(5+2)-1:AXI_LOCKW_NB*(5+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(5+1)-1:AXI_LOCKW_NB*5]] = arlock_5_w;
  assign arburst_vector[AXI_BURSTW*(5+1)-1 : AXI_BURSTW*5]                                  = arburst_5_w;
  assign arcache_vector[AXI_CACHEW*(5+1)-1 : AXI_CACHEW*5]                                  = arcache_5_w;
  assign arprot_vector[AXI_PROTW*(5+1)-1 : AXI_PROTW*5]                                     = arprot_5_w;
  assign arqos_vector[AXI_QOSW*(5+1)-1 : AXI_QOSW*5]                                        = arqos_5_w;
  assign arurgentb_vector[5]                                                                = arurgentb_5_w;
  assign arurgentr_vector[5]                                                                = arurgentr_5_w;
  assign arpoison_vector[5]                                                                 = arpoison_5_w;
  assign arautopre_vector[5]                                                                = arautopre_5_w;
  assign arvalid_vector[5]                                                                  = arvalid_5_w;
  assign aruser_vector[AXI_USERW*(5+1)-1 : AXI_USERW*5]                                     = aruser_5_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(5+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*5]  = arparity_5_w;

  assign rready_vector[5]                                                                   = rready_5_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(5+1)-1 : UMCTL2_RDATARAM_DW*5]                 = rdataram_dout_5_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(5+1)-1 : UMCTL2_DATARAM_PAR_DW*5]       = rdataram_dout_par_5_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(5+1)-1 : UMCTL2_RDATARAM_DW*5]            = rdataram_dout_dch1_5_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(5+1)-1 : UMCTL2_DATARAM_PAR_DW*5]  = rdataram_dout_par_dch1_5_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(5+1)-1 : XPI_RQOS_MLW*5]                  = reg_arba5_rqos_map_level1_5_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(5+1)-1 : XPI_RQOS_MLW*5]                  = reg_arba5_rqos_map_level2_5_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(5+1)-1 : XPI_RQOS_RW*5]                   = reg_arba5_rqos_map_region0_5_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(5+1)-1 : XPI_RQOS_RW*5]                   = reg_arba5_rqos_map_region1_5_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(5+1)-1 : XPI_RQOS_RW*5]                   = reg_arba5_rqos_map_region2_5_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(5+1)-1 : HIF_RQOS_TW*5]                   = reg_arb_rqos_map_timeoutb_5_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(5+1)-1 : HIF_RQOS_TW*5]                   = reg_arb_rqos_map_timeoutr_5_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(5+1)-1 : XPI_WQOS_MLW*5]                  = reg_arba5_wqos_map_level1_5_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(5+1)-1 : XPI_WQOS_MLW*5]                  = reg_arba5_wqos_map_level2_5_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(5+1)-1 : XPI_WQOS_RW*5]                   = reg_arba5_wqos_map_region0_5_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(5+1)-1 : XPI_WQOS_RW*5]                   = reg_arba5_wqos_map_region1_5_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(5+1)-1 : XPI_WQOS_RW*5]                   = reg_arba5_wqos_map_region2_5_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(5+1)-1 : HIF_WQOS_TW*5]                   = reg_arb_wqos_map_timeout1_5_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(5+1)-1 : HIF_WQOS_TW*5]                   = reg_arb_wqos_map_timeout2_5_w;

  assign reg_arb_rd_port_pagematch_en_vector[5]                                                 = reg_arb_rd_port_pagematch_en_5_w;
  assign reg_arb_wr_port_pagematch_en_vector[5]                                                 = reg_arb_wr_port_pagematch_en_5_w;

  assign reg_arb_rdwr_ordered_en_vector[5]                                                      = reg_arb_rdwr_ordered_en_5_w;
  assign reg_arba_rdwr_ordered_en_vector[5]                                                     = reg_arba5_rdwr_ordered_en_5_w;
  assign reg_arb_port_data_channel_vector[5]                                                    = reg_arb_port_data_channel_5_w;
  assign reg_arba_data_bus_width_vector[2*(5+1)-1 : 2*5]                                        = reg_arba_data_bus_width_5_w;
  assign reg_xpi_snf_mode_vector[5]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(5+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*5]  = reg_arb_rrb_lock_threshold_5_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(6+1)-1 : REG_PORT_PRIORITYW*6] = reg_arb_wr_port_priority_6_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(6+1)-1 : REG_PORT_PRIORITYW*6] = reg_arb_rd_port_priority_6_w;
  assign reg_arb_wr_port_aging_en_vector[6]                                               = reg_arb_wr_port_aging_en_6_w;
  assign reg_arb_rd_port_aging_en_vector[6]                                               = reg_arb_rd_port_aging_en_6_w;
  assign reg_arb_wr_port_urgent_en_vector[6]                                              = reg_arb_wr_port_urgent_en_6_w;
  assign reg_arb_rd_port_urgent_en_vector[6]                                              = reg_arb_rd_port_urgent_en_6_w;

  assign aclk_vector[6]                                                                   = aclk_6_w;
  assign aresetn_vector[6]                                                                = aresetn_6_w;
  assign sync_aresetn_vector[6]                                                           = sync_aresetn_6_w;
  assign csysreq_xpi_vector[6]                                                            = csysreq_xpi_6_w;
  assign reg_arb_port_en_vector[6]                                                        = reg_arba6_port_en_6_w;
  assign reg_arb_bypass_reorder_vector[6]                                                 = reg_arba6_read_reorder_bypass_en_6_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(6+2)-1:ARB_ID_NB*(6+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(6+1)-1:ARB_ID_NB*6]]  = reg_arba6_id_mask_6_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(6+2)-1:ARB_ID_NB*(6+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(6+1)-1:ARB_ID_NB*6]] = reg_arba6_id_value_6_w;

  assign awid_vector[AXI_IDW*(6+1)-1 : AXI_IDW*6]                                           = awid_6_w;
  assign awaddr_vector[AXI_ADDRW*(6+1)-1 : AXI_ADDRW*6]                                     = awaddr_6_w;
  assign awlen_vector[AXI_LENW*(6+1)-1 : AXI_LENW*6]                                        = awlen_6_w;
  assign awsize_vector[AXI_SIZEW*(6+1)-1 : AXI_SIZEW*6]                                     = awsize_6_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(6+2)-1:AXI_LOCKW_NB*(6+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(6+1)-1:AXI_LOCKW_NB*6]] = awlock_6_w;
  assign awburst_vector[AXI_BURSTW*(6+1)-1 : AXI_BURSTW*6]                                  = awburst_6_w;
  assign awcache_vector[AXI_CACHEW*(6+1)-1 : AXI_CACHEW*6]                                  = awcache_6_w;
  assign awprot_vector[AXI_PROTW*(6+1)-1 : AXI_PROTW*6]                                     = awprot_6_w;
  assign awqos_vector[AXI_QOSW*(6+1)-1 : AXI_QOSW*6]                                        = awqos_6_w;
  assign awurgent_vector[6]                                                                 = awurgent_6_w;
  assign awpoison_vector[6]                                                                 = awpoison_6_w;
  assign awautopre_vector[6]                                                                = awautopre_6_w;
  assign awvalid_vector[6]                                                                  = awvalid_6_w;
  assign awuser_vector[AXI_USERW*(6+1)-1 : AXI_USERW*6]                                     = awuser_6_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(6+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*6]       = awparity_6_w;

  assign wid_vector[AXI_IDW*(6+1)-1 : AXI_IDW*6]                                            = wid_6_w;
  assign wlast_vector[6]                                                                    = wlast_6_w;
  assign wvalid_vector[6]                                                                   = wvalid_6_w;
  assign wuser_vector[AXI_USERW*(6+1)-1 : AXI_USERW*6]                                      = wuser_6_w;

  assign bready_vector[6]                                                                   = bready_6_w;

  assign arid_vector[AXI_IDW*(6+1)-1 : AXI_IDW*6]                                           = arid_6_w;
  assign araddr_vector[AXI_ADDRW*(6+1)-1 : AXI_ADDRW*6]                                     = araddr_6_w;
  assign arlen_vector[AXI_LENW*(6+1)-1 : AXI_LENW*6]                                        = arlen_6_w;
  assign arsize_vector[AXI_SIZEW*(6+1)-1 : AXI_SIZEW*6]                                     = arsize_6_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(6+2)-1:AXI_LOCKW_NB*(6+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(6+1)-1:AXI_LOCKW_NB*6]] = arlock_6_w;
  assign arburst_vector[AXI_BURSTW*(6+1)-1 : AXI_BURSTW*6]                                  = arburst_6_w;
  assign arcache_vector[AXI_CACHEW*(6+1)-1 : AXI_CACHEW*6]                                  = arcache_6_w;
  assign arprot_vector[AXI_PROTW*(6+1)-1 : AXI_PROTW*6]                                     = arprot_6_w;
  assign arqos_vector[AXI_QOSW*(6+1)-1 : AXI_QOSW*6]                                        = arqos_6_w;
  assign arurgentb_vector[6]                                                                = arurgentb_6_w;
  assign arurgentr_vector[6]                                                                = arurgentr_6_w;
  assign arpoison_vector[6]                                                                 = arpoison_6_w;
  assign arautopre_vector[6]                                                                = arautopre_6_w;
  assign arvalid_vector[6]                                                                  = arvalid_6_w;
  assign aruser_vector[AXI_USERW*(6+1)-1 : AXI_USERW*6]                                     = aruser_6_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(6+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*6]  = arparity_6_w;

  assign rready_vector[6]                                                                   = rready_6_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(6+1)-1 : UMCTL2_RDATARAM_DW*6]                 = rdataram_dout_6_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(6+1)-1 : UMCTL2_DATARAM_PAR_DW*6]       = rdataram_dout_par_6_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(6+1)-1 : UMCTL2_RDATARAM_DW*6]            = rdataram_dout_dch1_6_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(6+1)-1 : UMCTL2_DATARAM_PAR_DW*6]  = rdataram_dout_par_dch1_6_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(6+1)-1 : XPI_RQOS_MLW*6]                  = reg_arba6_rqos_map_level1_6_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(6+1)-1 : XPI_RQOS_MLW*6]                  = reg_arba6_rqos_map_level2_6_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(6+1)-1 : XPI_RQOS_RW*6]                   = reg_arba6_rqos_map_region0_6_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(6+1)-1 : XPI_RQOS_RW*6]                   = reg_arba6_rqos_map_region1_6_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(6+1)-1 : XPI_RQOS_RW*6]                   = reg_arba6_rqos_map_region2_6_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(6+1)-1 : HIF_RQOS_TW*6]                   = reg_arb_rqos_map_timeoutb_6_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(6+1)-1 : HIF_RQOS_TW*6]                   = reg_arb_rqos_map_timeoutr_6_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(6+1)-1 : XPI_WQOS_MLW*6]                  = reg_arba6_wqos_map_level1_6_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(6+1)-1 : XPI_WQOS_MLW*6]                  = reg_arba6_wqos_map_level2_6_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(6+1)-1 : XPI_WQOS_RW*6]                   = reg_arba6_wqos_map_region0_6_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(6+1)-1 : XPI_WQOS_RW*6]                   = reg_arba6_wqos_map_region1_6_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(6+1)-1 : XPI_WQOS_RW*6]                   = reg_arba6_wqos_map_region2_6_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(6+1)-1 : HIF_WQOS_TW*6]                   = reg_arb_wqos_map_timeout1_6_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(6+1)-1 : HIF_WQOS_TW*6]                   = reg_arb_wqos_map_timeout2_6_w;

  assign reg_arb_rd_port_pagematch_en_vector[6]                                                 = reg_arb_rd_port_pagematch_en_6_w;
  assign reg_arb_wr_port_pagematch_en_vector[6]                                                 = reg_arb_wr_port_pagematch_en_6_w;

  assign reg_arb_rdwr_ordered_en_vector[6]                                                      = reg_arb_rdwr_ordered_en_6_w;
  assign reg_arba_rdwr_ordered_en_vector[6]                                                     = reg_arba6_rdwr_ordered_en_6_w;
  assign reg_arb_port_data_channel_vector[6]                                                    = reg_arb_port_data_channel_6_w;
  assign reg_arba_data_bus_width_vector[2*(6+1)-1 : 2*6]                                        = reg_arba_data_bus_width_6_w;
  assign reg_xpi_snf_mode_vector[6]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(6+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*6]  = reg_arb_rrb_lock_threshold_6_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(7+1)-1 : REG_PORT_PRIORITYW*7] = reg_arb_wr_port_priority_7_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(7+1)-1 : REG_PORT_PRIORITYW*7] = reg_arb_rd_port_priority_7_w;
  assign reg_arb_wr_port_aging_en_vector[7]                                               = reg_arb_wr_port_aging_en_7_w;
  assign reg_arb_rd_port_aging_en_vector[7]                                               = reg_arb_rd_port_aging_en_7_w;
  assign reg_arb_wr_port_urgent_en_vector[7]                                              = reg_arb_wr_port_urgent_en_7_w;
  assign reg_arb_rd_port_urgent_en_vector[7]                                              = reg_arb_rd_port_urgent_en_7_w;

  assign aclk_vector[7]                                                                   = aclk_7_w;
  assign aresetn_vector[7]                                                                = aresetn_7_w;
  assign sync_aresetn_vector[7]                                                           = sync_aresetn_7_w;
  assign csysreq_xpi_vector[7]                                                            = csysreq_xpi_7_w;
  assign reg_arb_port_en_vector[7]                                                        = reg_arba7_port_en_7_w;
  assign reg_arb_bypass_reorder_vector[7]                                                 = reg_arba7_read_reorder_bypass_en_7_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(7+2)-1:ARB_ID_NB*(7+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(7+1)-1:ARB_ID_NB*7]]  = reg_arba7_id_mask_7_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(7+2)-1:ARB_ID_NB*(7+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(7+1)-1:ARB_ID_NB*7]] = reg_arba7_id_value_7_w;

  assign awid_vector[AXI_IDW*(7+1)-1 : AXI_IDW*7]                                           = awid_7_w;
  assign awaddr_vector[AXI_ADDRW*(7+1)-1 : AXI_ADDRW*7]                                     = awaddr_7_w;
  assign awlen_vector[AXI_LENW*(7+1)-1 : AXI_LENW*7]                                        = awlen_7_w;
  assign awsize_vector[AXI_SIZEW*(7+1)-1 : AXI_SIZEW*7]                                     = awsize_7_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(7+2)-1:AXI_LOCKW_NB*(7+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(7+1)-1:AXI_LOCKW_NB*7]] = awlock_7_w;
  assign awburst_vector[AXI_BURSTW*(7+1)-1 : AXI_BURSTW*7]                                  = awburst_7_w;
  assign awcache_vector[AXI_CACHEW*(7+1)-1 : AXI_CACHEW*7]                                  = awcache_7_w;
  assign awprot_vector[AXI_PROTW*(7+1)-1 : AXI_PROTW*7]                                     = awprot_7_w;
  assign awqos_vector[AXI_QOSW*(7+1)-1 : AXI_QOSW*7]                                        = awqos_7_w;
  assign awurgent_vector[7]                                                                 = awurgent_7_w;
  assign awpoison_vector[7]                                                                 = awpoison_7_w;
  assign awautopre_vector[7]                                                                = awautopre_7_w;
  assign awvalid_vector[7]                                                                  = awvalid_7_w;
  assign awuser_vector[AXI_USERW*(7+1)-1 : AXI_USERW*7]                                     = awuser_7_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(7+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*7]       = awparity_7_w;

  assign wid_vector[AXI_IDW*(7+1)-1 : AXI_IDW*7]                                            = wid_7_w;
  assign wlast_vector[7]                                                                    = wlast_7_w;
  assign wvalid_vector[7]                                                                   = wvalid_7_w;
  assign wuser_vector[AXI_USERW*(7+1)-1 : AXI_USERW*7]                                      = wuser_7_w;

  assign bready_vector[7]                                                                   = bready_7_w;

  assign arid_vector[AXI_IDW*(7+1)-1 : AXI_IDW*7]                                           = arid_7_w;
  assign araddr_vector[AXI_ADDRW*(7+1)-1 : AXI_ADDRW*7]                                     = araddr_7_w;
  assign arlen_vector[AXI_LENW*(7+1)-1 : AXI_LENW*7]                                        = arlen_7_w;
  assign arsize_vector[AXI_SIZEW*(7+1)-1 : AXI_SIZEW*7]                                     = arsize_7_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(7+2)-1:AXI_LOCKW_NB*(7+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(7+1)-1:AXI_LOCKW_NB*7]] = arlock_7_w;
  assign arburst_vector[AXI_BURSTW*(7+1)-1 : AXI_BURSTW*7]                                  = arburst_7_w;
  assign arcache_vector[AXI_CACHEW*(7+1)-1 : AXI_CACHEW*7]                                  = arcache_7_w;
  assign arprot_vector[AXI_PROTW*(7+1)-1 : AXI_PROTW*7]                                     = arprot_7_w;
  assign arqos_vector[AXI_QOSW*(7+1)-1 : AXI_QOSW*7]                                        = arqos_7_w;
  assign arurgentb_vector[7]                                                                = arurgentb_7_w;
  assign arurgentr_vector[7]                                                                = arurgentr_7_w;
  assign arpoison_vector[7]                                                                 = arpoison_7_w;
  assign arautopre_vector[7]                                                                = arautopre_7_w;
  assign arvalid_vector[7]                                                                  = arvalid_7_w;
  assign aruser_vector[AXI_USERW*(7+1)-1 : AXI_USERW*7]                                     = aruser_7_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(7+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*7]  = arparity_7_w;

  assign rready_vector[7]                                                                   = rready_7_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(7+1)-1 : UMCTL2_RDATARAM_DW*7]                 = rdataram_dout_7_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(7+1)-1 : UMCTL2_DATARAM_PAR_DW*7]       = rdataram_dout_par_7_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(7+1)-1 : UMCTL2_RDATARAM_DW*7]            = rdataram_dout_dch1_7_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(7+1)-1 : UMCTL2_DATARAM_PAR_DW*7]  = rdataram_dout_par_dch1_7_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(7+1)-1 : XPI_RQOS_MLW*7]                  = reg_arba7_rqos_map_level1_7_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(7+1)-1 : XPI_RQOS_MLW*7]                  = reg_arba7_rqos_map_level2_7_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(7+1)-1 : XPI_RQOS_RW*7]                   = reg_arba7_rqos_map_region0_7_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(7+1)-1 : XPI_RQOS_RW*7]                   = reg_arba7_rqos_map_region1_7_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(7+1)-1 : XPI_RQOS_RW*7]                   = reg_arba7_rqos_map_region2_7_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(7+1)-1 : HIF_RQOS_TW*7]                   = reg_arb_rqos_map_timeoutb_7_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(7+1)-1 : HIF_RQOS_TW*7]                   = reg_arb_rqos_map_timeoutr_7_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(7+1)-1 : XPI_WQOS_MLW*7]                  = reg_arba7_wqos_map_level1_7_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(7+1)-1 : XPI_WQOS_MLW*7]                  = reg_arba7_wqos_map_level2_7_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(7+1)-1 : XPI_WQOS_RW*7]                   = reg_arba7_wqos_map_region0_7_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(7+1)-1 : XPI_WQOS_RW*7]                   = reg_arba7_wqos_map_region1_7_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(7+1)-1 : XPI_WQOS_RW*7]                   = reg_arba7_wqos_map_region2_7_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(7+1)-1 : HIF_WQOS_TW*7]                   = reg_arb_wqos_map_timeout1_7_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(7+1)-1 : HIF_WQOS_TW*7]                   = reg_arb_wqos_map_timeout2_7_w;

  assign reg_arb_rd_port_pagematch_en_vector[7]                                                 = reg_arb_rd_port_pagematch_en_7_w;
  assign reg_arb_wr_port_pagematch_en_vector[7]                                                 = reg_arb_wr_port_pagematch_en_7_w;

  assign reg_arb_rdwr_ordered_en_vector[7]                                                      = reg_arb_rdwr_ordered_en_7_w;
  assign reg_arba_rdwr_ordered_en_vector[7]                                                     = reg_arba7_rdwr_ordered_en_7_w;
  assign reg_arb_port_data_channel_vector[7]                                                    = reg_arb_port_data_channel_7_w;
  assign reg_arba_data_bus_width_vector[2*(7+1)-1 : 2*7]                                        = reg_arba_data_bus_width_7_w;
  assign reg_xpi_snf_mode_vector[7]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(7+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*7]  = reg_arb_rrb_lock_threshold_7_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(8+1)-1 : REG_PORT_PRIORITYW*8] = reg_arb_wr_port_priority_8_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(8+1)-1 : REG_PORT_PRIORITYW*8] = reg_arb_rd_port_priority_8_w;
  assign reg_arb_wr_port_aging_en_vector[8]                                               = reg_arb_wr_port_aging_en_8_w;
  assign reg_arb_rd_port_aging_en_vector[8]                                               = reg_arb_rd_port_aging_en_8_w;
  assign reg_arb_wr_port_urgent_en_vector[8]                                              = reg_arb_wr_port_urgent_en_8_w;
  assign reg_arb_rd_port_urgent_en_vector[8]                                              = reg_arb_rd_port_urgent_en_8_w;

  assign aclk_vector[8]                                                                   = aclk_8_w;
  assign aresetn_vector[8]                                                                = aresetn_8_w;
  assign sync_aresetn_vector[8]                                                           = sync_aresetn_8_w;
  assign csysreq_xpi_vector[8]                                                            = csysreq_xpi_8_w;
  assign reg_arb_port_en_vector[8]                                                        = reg_arba8_port_en_8_w;
  assign reg_arb_bypass_reorder_vector[8]                                                 = reg_arba8_read_reorder_bypass_en_8_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(8+2)-1:ARB_ID_NB*(8+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(8+1)-1:ARB_ID_NB*8]]  = reg_arba8_id_mask_8_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(8+2)-1:ARB_ID_NB*(8+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(8+1)-1:ARB_ID_NB*8]] = reg_arba8_id_value_8_w;

  assign awid_vector[AXI_IDW*(8+1)-1 : AXI_IDW*8]                                           = awid_8_w;
  assign awaddr_vector[AXI_ADDRW*(8+1)-1 : AXI_ADDRW*8]                                     = awaddr_8_w;
  assign awlen_vector[AXI_LENW*(8+1)-1 : AXI_LENW*8]                                        = awlen_8_w;
  assign awsize_vector[AXI_SIZEW*(8+1)-1 : AXI_SIZEW*8]                                     = awsize_8_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(8+2)-1:AXI_LOCKW_NB*(8+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(8+1)-1:AXI_LOCKW_NB*8]] = awlock_8_w;
  assign awburst_vector[AXI_BURSTW*(8+1)-1 : AXI_BURSTW*8]                                  = awburst_8_w;
  assign awcache_vector[AXI_CACHEW*(8+1)-1 : AXI_CACHEW*8]                                  = awcache_8_w;
  assign awprot_vector[AXI_PROTW*(8+1)-1 : AXI_PROTW*8]                                     = awprot_8_w;
  assign awqos_vector[AXI_QOSW*(8+1)-1 : AXI_QOSW*8]                                        = awqos_8_w;
  assign awurgent_vector[8]                                                                 = awurgent_8_w;
  assign awpoison_vector[8]                                                                 = awpoison_8_w;
  assign awautopre_vector[8]                                                                = awautopre_8_w;
  assign awvalid_vector[8]                                                                  = awvalid_8_w;
  assign awuser_vector[AXI_USERW*(8+1)-1 : AXI_USERW*8]                                     = awuser_8_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(8+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*8]       = awparity_8_w;

  assign wid_vector[AXI_IDW*(8+1)-1 : AXI_IDW*8]                                            = wid_8_w;
  assign wlast_vector[8]                                                                    = wlast_8_w;
  assign wvalid_vector[8]                                                                   = wvalid_8_w;
  assign wuser_vector[AXI_USERW*(8+1)-1 : AXI_USERW*8]                                      = wuser_8_w;

  assign bready_vector[8]                                                                   = bready_8_w;

  assign arid_vector[AXI_IDW*(8+1)-1 : AXI_IDW*8]                                           = arid_8_w;
  assign araddr_vector[AXI_ADDRW*(8+1)-1 : AXI_ADDRW*8]                                     = araddr_8_w;
  assign arlen_vector[AXI_LENW*(8+1)-1 : AXI_LENW*8]                                        = arlen_8_w;
  assign arsize_vector[AXI_SIZEW*(8+1)-1 : AXI_SIZEW*8]                                     = arsize_8_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(8+2)-1:AXI_LOCKW_NB*(8+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(8+1)-1:AXI_LOCKW_NB*8]] = arlock_8_w;
  assign arburst_vector[AXI_BURSTW*(8+1)-1 : AXI_BURSTW*8]                                  = arburst_8_w;
  assign arcache_vector[AXI_CACHEW*(8+1)-1 : AXI_CACHEW*8]                                  = arcache_8_w;
  assign arprot_vector[AXI_PROTW*(8+1)-1 : AXI_PROTW*8]                                     = arprot_8_w;
  assign arqos_vector[AXI_QOSW*(8+1)-1 : AXI_QOSW*8]                                        = arqos_8_w;
  assign arurgentb_vector[8]                                                                = arurgentb_8_w;
  assign arurgentr_vector[8]                                                                = arurgentr_8_w;
  assign arpoison_vector[8]                                                                 = arpoison_8_w;
  assign arautopre_vector[8]                                                                = arautopre_8_w;
  assign arvalid_vector[8]                                                                  = arvalid_8_w;
  assign aruser_vector[AXI_USERW*(8+1)-1 : AXI_USERW*8]                                     = aruser_8_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(8+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*8]  = arparity_8_w;

  assign rready_vector[8]                                                                   = rready_8_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(8+1)-1 : UMCTL2_RDATARAM_DW*8]                 = rdataram_dout_8_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(8+1)-1 : UMCTL2_DATARAM_PAR_DW*8]       = rdataram_dout_par_8_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(8+1)-1 : UMCTL2_RDATARAM_DW*8]            = rdataram_dout_dch1_8_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(8+1)-1 : UMCTL2_DATARAM_PAR_DW*8]  = rdataram_dout_par_dch1_8_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(8+1)-1 : XPI_RQOS_MLW*8]                  = reg_arba8_rqos_map_level1_8_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(8+1)-1 : XPI_RQOS_MLW*8]                  = reg_arba8_rqos_map_level2_8_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(8+1)-1 : XPI_RQOS_RW*8]                   = reg_arba8_rqos_map_region0_8_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(8+1)-1 : XPI_RQOS_RW*8]                   = reg_arba8_rqos_map_region1_8_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(8+1)-1 : XPI_RQOS_RW*8]                   = reg_arba8_rqos_map_region2_8_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(8+1)-1 : HIF_RQOS_TW*8]                   = reg_arb_rqos_map_timeoutb_8_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(8+1)-1 : HIF_RQOS_TW*8]                   = reg_arb_rqos_map_timeoutr_8_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(8+1)-1 : XPI_WQOS_MLW*8]                  = reg_arba8_wqos_map_level1_8_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(8+1)-1 : XPI_WQOS_MLW*8]                  = reg_arba8_wqos_map_level2_8_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(8+1)-1 : XPI_WQOS_RW*8]                   = reg_arba8_wqos_map_region0_8_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(8+1)-1 : XPI_WQOS_RW*8]                   = reg_arba8_wqos_map_region1_8_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(8+1)-1 : XPI_WQOS_RW*8]                   = reg_arba8_wqos_map_region2_8_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(8+1)-1 : HIF_WQOS_TW*8]                   = reg_arb_wqos_map_timeout1_8_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(8+1)-1 : HIF_WQOS_TW*8]                   = reg_arb_wqos_map_timeout2_8_w;

  assign reg_arb_rd_port_pagematch_en_vector[8]                                                 = reg_arb_rd_port_pagematch_en_8_w;
  assign reg_arb_wr_port_pagematch_en_vector[8]                                                 = reg_arb_wr_port_pagematch_en_8_w;

  assign reg_arb_rdwr_ordered_en_vector[8]                                                      = reg_arb_rdwr_ordered_en_8_w;
  assign reg_arba_rdwr_ordered_en_vector[8]                                                     = reg_arba8_rdwr_ordered_en_8_w;
  assign reg_arb_port_data_channel_vector[8]                                                    = reg_arb_port_data_channel_8_w;
  assign reg_arba_data_bus_width_vector[2*(8+1)-1 : 2*8]                                        = reg_arba_data_bus_width_8_w;
  assign reg_xpi_snf_mode_vector[8]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(8+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*8]  = reg_arb_rrb_lock_threshold_8_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(9+1)-1 : REG_PORT_PRIORITYW*9] = reg_arb_wr_port_priority_9_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(9+1)-1 : REG_PORT_PRIORITYW*9] = reg_arb_rd_port_priority_9_w;
  assign reg_arb_wr_port_aging_en_vector[9]                                               = reg_arb_wr_port_aging_en_9_w;
  assign reg_arb_rd_port_aging_en_vector[9]                                               = reg_arb_rd_port_aging_en_9_w;
  assign reg_arb_wr_port_urgent_en_vector[9]                                              = reg_arb_wr_port_urgent_en_9_w;
  assign reg_arb_rd_port_urgent_en_vector[9]                                              = reg_arb_rd_port_urgent_en_9_w;

  assign aclk_vector[9]                                                                   = aclk_9_w;
  assign aresetn_vector[9]                                                                = aresetn_9_w;
  assign sync_aresetn_vector[9]                                                           = sync_aresetn_9_w;
  assign csysreq_xpi_vector[9]                                                            = csysreq_xpi_9_w;
  assign reg_arb_port_en_vector[9]                                                        = reg_arba9_port_en_9_w;
  assign reg_arb_bypass_reorder_vector[9]                                                 = reg_arba9_read_reorder_bypass_en_9_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(9+2)-1:ARB_ID_NB*(9+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(9+1)-1:ARB_ID_NB*9]]  = reg_arba9_id_mask_9_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(9+2)-1:ARB_ID_NB*(9+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(9+1)-1:ARB_ID_NB*9]] = reg_arba9_id_value_9_w;

  assign awid_vector[AXI_IDW*(9+1)-1 : AXI_IDW*9]                                           = awid_9_w;
  assign awaddr_vector[AXI_ADDRW*(9+1)-1 : AXI_ADDRW*9]                                     = awaddr_9_w;
  assign awlen_vector[AXI_LENW*(9+1)-1 : AXI_LENW*9]                                        = awlen_9_w;
  assign awsize_vector[AXI_SIZEW*(9+1)-1 : AXI_SIZEW*9]                                     = awsize_9_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(9+2)-1:AXI_LOCKW_NB*(9+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(9+1)-1:AXI_LOCKW_NB*9]] = awlock_9_w;
  assign awburst_vector[AXI_BURSTW*(9+1)-1 : AXI_BURSTW*9]                                  = awburst_9_w;
  assign awcache_vector[AXI_CACHEW*(9+1)-1 : AXI_CACHEW*9]                                  = awcache_9_w;
  assign awprot_vector[AXI_PROTW*(9+1)-1 : AXI_PROTW*9]                                     = awprot_9_w;
  assign awqos_vector[AXI_QOSW*(9+1)-1 : AXI_QOSW*9]                                        = awqos_9_w;
  assign awurgent_vector[9]                                                                 = awurgent_9_w;
  assign awpoison_vector[9]                                                                 = awpoison_9_w;
  assign awautopre_vector[9]                                                                = awautopre_9_w;
  assign awvalid_vector[9]                                                                  = awvalid_9_w;
  assign awuser_vector[AXI_USERW*(9+1)-1 : AXI_USERW*9]                                     = awuser_9_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(9+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*9]       = awparity_9_w;

  assign wid_vector[AXI_IDW*(9+1)-1 : AXI_IDW*9]                                            = wid_9_w;
  assign wlast_vector[9]                                                                    = wlast_9_w;
  assign wvalid_vector[9]                                                                   = wvalid_9_w;
  assign wuser_vector[AXI_USERW*(9+1)-1 : AXI_USERW*9]                                      = wuser_9_w;

  assign bready_vector[9]                                                                   = bready_9_w;

  assign arid_vector[AXI_IDW*(9+1)-1 : AXI_IDW*9]                                           = arid_9_w;
  assign araddr_vector[AXI_ADDRW*(9+1)-1 : AXI_ADDRW*9]                                     = araddr_9_w;
  assign arlen_vector[AXI_LENW*(9+1)-1 : AXI_LENW*9]                                        = arlen_9_w;
  assign arsize_vector[AXI_SIZEW*(9+1)-1 : AXI_SIZEW*9]                                     = arsize_9_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(9+2)-1:AXI_LOCKW_NB*(9+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(9+1)-1:AXI_LOCKW_NB*9]] = arlock_9_w;
  assign arburst_vector[AXI_BURSTW*(9+1)-1 : AXI_BURSTW*9]                                  = arburst_9_w;
  assign arcache_vector[AXI_CACHEW*(9+1)-1 : AXI_CACHEW*9]                                  = arcache_9_w;
  assign arprot_vector[AXI_PROTW*(9+1)-1 : AXI_PROTW*9]                                     = arprot_9_w;
  assign arqos_vector[AXI_QOSW*(9+1)-1 : AXI_QOSW*9]                                        = arqos_9_w;
  assign arurgentb_vector[9]                                                                = arurgentb_9_w;
  assign arurgentr_vector[9]                                                                = arurgentr_9_w;
  assign arpoison_vector[9]                                                                 = arpoison_9_w;
  assign arautopre_vector[9]                                                                = arautopre_9_w;
  assign arvalid_vector[9]                                                                  = arvalid_9_w;
  assign aruser_vector[AXI_USERW*(9+1)-1 : AXI_USERW*9]                                     = aruser_9_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(9+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*9]  = arparity_9_w;

  assign rready_vector[9]                                                                   = rready_9_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(9+1)-1 : UMCTL2_RDATARAM_DW*9]                 = rdataram_dout_9_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(9+1)-1 : UMCTL2_DATARAM_PAR_DW*9]       = rdataram_dout_par_9_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(9+1)-1 : UMCTL2_RDATARAM_DW*9]            = rdataram_dout_dch1_9_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(9+1)-1 : UMCTL2_DATARAM_PAR_DW*9]  = rdataram_dout_par_dch1_9_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(9+1)-1 : XPI_RQOS_MLW*9]                  = reg_arba9_rqos_map_level1_9_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(9+1)-1 : XPI_RQOS_MLW*9]                  = reg_arba9_rqos_map_level2_9_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(9+1)-1 : XPI_RQOS_RW*9]                   = reg_arba9_rqos_map_region0_9_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(9+1)-1 : XPI_RQOS_RW*9]                   = reg_arba9_rqos_map_region1_9_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(9+1)-1 : XPI_RQOS_RW*9]                   = reg_arba9_rqos_map_region2_9_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(9+1)-1 : HIF_RQOS_TW*9]                   = reg_arb_rqos_map_timeoutb_9_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(9+1)-1 : HIF_RQOS_TW*9]                   = reg_arb_rqos_map_timeoutr_9_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(9+1)-1 : XPI_WQOS_MLW*9]                  = reg_arba9_wqos_map_level1_9_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(9+1)-1 : XPI_WQOS_MLW*9]                  = reg_arba9_wqos_map_level2_9_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(9+1)-1 : XPI_WQOS_RW*9]                   = reg_arba9_wqos_map_region0_9_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(9+1)-1 : XPI_WQOS_RW*9]                   = reg_arba9_wqos_map_region1_9_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(9+1)-1 : XPI_WQOS_RW*9]                   = reg_arba9_wqos_map_region2_9_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(9+1)-1 : HIF_WQOS_TW*9]                   = reg_arb_wqos_map_timeout1_9_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(9+1)-1 : HIF_WQOS_TW*9]                   = reg_arb_wqos_map_timeout2_9_w;

  assign reg_arb_rd_port_pagematch_en_vector[9]                                                 = reg_arb_rd_port_pagematch_en_9_w;
  assign reg_arb_wr_port_pagematch_en_vector[9]                                                 = reg_arb_wr_port_pagematch_en_9_w;

  assign reg_arb_rdwr_ordered_en_vector[9]                                                      = reg_arb_rdwr_ordered_en_9_w;
  assign reg_arba_rdwr_ordered_en_vector[9]                                                     = reg_arba9_rdwr_ordered_en_9_w;
  assign reg_arb_port_data_channel_vector[9]                                                    = reg_arb_port_data_channel_9_w;
  assign reg_arba_data_bus_width_vector[2*(9+1)-1 : 2*9]                                        = reg_arba_data_bus_width_9_w;
  assign reg_xpi_snf_mode_vector[9]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(9+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*9]  = reg_arb_rrb_lock_threshold_9_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(10+1)-1 : REG_PORT_PRIORITYW*10] = reg_arb_wr_port_priority_10_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(10+1)-1 : REG_PORT_PRIORITYW*10] = reg_arb_rd_port_priority_10_w;
  assign reg_arb_wr_port_aging_en_vector[10]                                               = reg_arb_wr_port_aging_en_10_w;
  assign reg_arb_rd_port_aging_en_vector[10]                                               = reg_arb_rd_port_aging_en_10_w;
  assign reg_arb_wr_port_urgent_en_vector[10]                                              = reg_arb_wr_port_urgent_en_10_w;
  assign reg_arb_rd_port_urgent_en_vector[10]                                              = reg_arb_rd_port_urgent_en_10_w;

  assign aclk_vector[10]                                                                   = aclk_10_w;
  assign aresetn_vector[10]                                                                = aresetn_10_w;
  assign sync_aresetn_vector[10]                                                           = sync_aresetn_10_w;
  assign csysreq_xpi_vector[10]                                                            = csysreq_xpi_10_w;
  assign reg_arb_port_en_vector[10]                                                        = reg_arba10_port_en_10_w;
  assign reg_arb_bypass_reorder_vector[10]                                                 = reg_arba10_read_reorder_bypass_en_10_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(10+2)-1:ARB_ID_NB*(10+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(10+1)-1:ARB_ID_NB*10]]  = reg_arba10_id_mask_10_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(10+2)-1:ARB_ID_NB*(10+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(10+1)-1:ARB_ID_NB*10]] = reg_arba10_id_value_10_w;

  assign awid_vector[AXI_IDW*(10+1)-1 : AXI_IDW*10]                                           = awid_10_w;
  assign awaddr_vector[AXI_ADDRW*(10+1)-1 : AXI_ADDRW*10]                                     = awaddr_10_w;
  assign awlen_vector[AXI_LENW*(10+1)-1 : AXI_LENW*10]                                        = awlen_10_w;
  assign awsize_vector[AXI_SIZEW*(10+1)-1 : AXI_SIZEW*10]                                     = awsize_10_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(10+2)-1:AXI_LOCKW_NB*(10+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(10+1)-1:AXI_LOCKW_NB*10]] = awlock_10_w;
  assign awburst_vector[AXI_BURSTW*(10+1)-1 : AXI_BURSTW*10]                                  = awburst_10_w;
  assign awcache_vector[AXI_CACHEW*(10+1)-1 : AXI_CACHEW*10]                                  = awcache_10_w;
  assign awprot_vector[AXI_PROTW*(10+1)-1 : AXI_PROTW*10]                                     = awprot_10_w;
  assign awqos_vector[AXI_QOSW*(10+1)-1 : AXI_QOSW*10]                                        = awqos_10_w;
  assign awurgent_vector[10]                                                                 = awurgent_10_w;
  assign awpoison_vector[10]                                                                 = awpoison_10_w;
  assign awautopre_vector[10]                                                                = awautopre_10_w;
  assign awvalid_vector[10]                                                                  = awvalid_10_w;
  assign awuser_vector[AXI_USERW*(10+1)-1 : AXI_USERW*10]                                     = awuser_10_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(10+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*10]       = awparity_10_w;

  assign wid_vector[AXI_IDW*(10+1)-1 : AXI_IDW*10]                                            = wid_10_w;
  assign wlast_vector[10]                                                                    = wlast_10_w;
  assign wvalid_vector[10]                                                                   = wvalid_10_w;
  assign wuser_vector[AXI_USERW*(10+1)-1 : AXI_USERW*10]                                      = wuser_10_w;

  assign bready_vector[10]                                                                   = bready_10_w;

  assign arid_vector[AXI_IDW*(10+1)-1 : AXI_IDW*10]                                           = arid_10_w;
  assign araddr_vector[AXI_ADDRW*(10+1)-1 : AXI_ADDRW*10]                                     = araddr_10_w;
  assign arlen_vector[AXI_LENW*(10+1)-1 : AXI_LENW*10]                                        = arlen_10_w;
  assign arsize_vector[AXI_SIZEW*(10+1)-1 : AXI_SIZEW*10]                                     = arsize_10_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(10+2)-1:AXI_LOCKW_NB*(10+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(10+1)-1:AXI_LOCKW_NB*10]] = arlock_10_w;
  assign arburst_vector[AXI_BURSTW*(10+1)-1 : AXI_BURSTW*10]                                  = arburst_10_w;
  assign arcache_vector[AXI_CACHEW*(10+1)-1 : AXI_CACHEW*10]                                  = arcache_10_w;
  assign arprot_vector[AXI_PROTW*(10+1)-1 : AXI_PROTW*10]                                     = arprot_10_w;
  assign arqos_vector[AXI_QOSW*(10+1)-1 : AXI_QOSW*10]                                        = arqos_10_w;
  assign arurgentb_vector[10]                                                                = arurgentb_10_w;
  assign arurgentr_vector[10]                                                                = arurgentr_10_w;
  assign arpoison_vector[10]                                                                 = arpoison_10_w;
  assign arautopre_vector[10]                                                                = arautopre_10_w;
  assign arvalid_vector[10]                                                                  = arvalid_10_w;
  assign aruser_vector[AXI_USERW*(10+1)-1 : AXI_USERW*10]                                     = aruser_10_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(10+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*10]  = arparity_10_w;

  assign rready_vector[10]                                                                   = rready_10_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(10+1)-1 : UMCTL2_RDATARAM_DW*10]                 = rdataram_dout_10_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(10+1)-1 : UMCTL2_DATARAM_PAR_DW*10]       = rdataram_dout_par_10_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(10+1)-1 : UMCTL2_RDATARAM_DW*10]            = rdataram_dout_dch1_10_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(10+1)-1 : UMCTL2_DATARAM_PAR_DW*10]  = rdataram_dout_par_dch1_10_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(10+1)-1 : XPI_RQOS_MLW*10]                  = reg_arba10_rqos_map_level1_10_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(10+1)-1 : XPI_RQOS_MLW*10]                  = reg_arba10_rqos_map_level2_10_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(10+1)-1 : XPI_RQOS_RW*10]                   = reg_arba10_rqos_map_region0_10_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(10+1)-1 : XPI_RQOS_RW*10]                   = reg_arba10_rqos_map_region1_10_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(10+1)-1 : XPI_RQOS_RW*10]                   = reg_arba10_rqos_map_region2_10_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(10+1)-1 : HIF_RQOS_TW*10]                   = reg_arb_rqos_map_timeoutb_10_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(10+1)-1 : HIF_RQOS_TW*10]                   = reg_arb_rqos_map_timeoutr_10_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(10+1)-1 : XPI_WQOS_MLW*10]                  = reg_arba10_wqos_map_level1_10_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(10+1)-1 : XPI_WQOS_MLW*10]                  = reg_arba10_wqos_map_level2_10_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(10+1)-1 : XPI_WQOS_RW*10]                   = reg_arba10_wqos_map_region0_10_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(10+1)-1 : XPI_WQOS_RW*10]                   = reg_arba10_wqos_map_region1_10_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(10+1)-1 : XPI_WQOS_RW*10]                   = reg_arba10_wqos_map_region2_10_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(10+1)-1 : HIF_WQOS_TW*10]                   = reg_arb_wqos_map_timeout1_10_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(10+1)-1 : HIF_WQOS_TW*10]                   = reg_arb_wqos_map_timeout2_10_w;

  assign reg_arb_rd_port_pagematch_en_vector[10]                                                 = reg_arb_rd_port_pagematch_en_10_w;
  assign reg_arb_wr_port_pagematch_en_vector[10]                                                 = reg_arb_wr_port_pagematch_en_10_w;

  assign reg_arb_rdwr_ordered_en_vector[10]                                                      = reg_arb_rdwr_ordered_en_10_w;
  assign reg_arba_rdwr_ordered_en_vector[10]                                                     = reg_arba10_rdwr_ordered_en_10_w;
  assign reg_arb_port_data_channel_vector[10]                                                    = reg_arb_port_data_channel_10_w;
  assign reg_arba_data_bus_width_vector[2*(10+1)-1 : 2*10]                                        = reg_arba_data_bus_width_10_w;
  assign reg_xpi_snf_mode_vector[10]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(10+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*10]  = reg_arb_rrb_lock_threshold_10_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(11+1)-1 : REG_PORT_PRIORITYW*11] = reg_arb_wr_port_priority_11_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(11+1)-1 : REG_PORT_PRIORITYW*11] = reg_arb_rd_port_priority_11_w;
  assign reg_arb_wr_port_aging_en_vector[11]                                               = reg_arb_wr_port_aging_en_11_w;
  assign reg_arb_rd_port_aging_en_vector[11]                                               = reg_arb_rd_port_aging_en_11_w;
  assign reg_arb_wr_port_urgent_en_vector[11]                                              = reg_arb_wr_port_urgent_en_11_w;
  assign reg_arb_rd_port_urgent_en_vector[11]                                              = reg_arb_rd_port_urgent_en_11_w;

  assign aclk_vector[11]                                                                   = aclk_11_w;
  assign aresetn_vector[11]                                                                = aresetn_11_w;
  assign sync_aresetn_vector[11]                                                           = sync_aresetn_11_w;
  assign csysreq_xpi_vector[11]                                                            = csysreq_xpi_11_w;
  assign reg_arb_port_en_vector[11]                                                        = reg_arba11_port_en_11_w;
  assign reg_arb_bypass_reorder_vector[11]                                                 = reg_arba11_read_reorder_bypass_en_11_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(11+2)-1:ARB_ID_NB*(11+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(11+1)-1:ARB_ID_NB*11]]  = reg_arba11_id_mask_11_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(11+2)-1:ARB_ID_NB*(11+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(11+1)-1:ARB_ID_NB*11]] = reg_arba11_id_value_11_w;

  assign awid_vector[AXI_IDW*(11+1)-1 : AXI_IDW*11]                                           = awid_11_w;
  assign awaddr_vector[AXI_ADDRW*(11+1)-1 : AXI_ADDRW*11]                                     = awaddr_11_w;
  assign awlen_vector[AXI_LENW*(11+1)-1 : AXI_LENW*11]                                        = awlen_11_w;
  assign awsize_vector[AXI_SIZEW*(11+1)-1 : AXI_SIZEW*11]                                     = awsize_11_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(11+2)-1:AXI_LOCKW_NB*(11+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(11+1)-1:AXI_LOCKW_NB*11]] = awlock_11_w;
  assign awburst_vector[AXI_BURSTW*(11+1)-1 : AXI_BURSTW*11]                                  = awburst_11_w;
  assign awcache_vector[AXI_CACHEW*(11+1)-1 : AXI_CACHEW*11]                                  = awcache_11_w;
  assign awprot_vector[AXI_PROTW*(11+1)-1 : AXI_PROTW*11]                                     = awprot_11_w;
  assign awqos_vector[AXI_QOSW*(11+1)-1 : AXI_QOSW*11]                                        = awqos_11_w;
  assign awurgent_vector[11]                                                                 = awurgent_11_w;
  assign awpoison_vector[11]                                                                 = awpoison_11_w;
  assign awautopre_vector[11]                                                                = awautopre_11_w;
  assign awvalid_vector[11]                                                                  = awvalid_11_w;
  assign awuser_vector[AXI_USERW*(11+1)-1 : AXI_USERW*11]                                     = awuser_11_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(11+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*11]       = awparity_11_w;

  assign wid_vector[AXI_IDW*(11+1)-1 : AXI_IDW*11]                                            = wid_11_w;
  assign wlast_vector[11]                                                                    = wlast_11_w;
  assign wvalid_vector[11]                                                                   = wvalid_11_w;
  assign wuser_vector[AXI_USERW*(11+1)-1 : AXI_USERW*11]                                      = wuser_11_w;

  assign bready_vector[11]                                                                   = bready_11_w;

  assign arid_vector[AXI_IDW*(11+1)-1 : AXI_IDW*11]                                           = arid_11_w;
  assign araddr_vector[AXI_ADDRW*(11+1)-1 : AXI_ADDRW*11]                                     = araddr_11_w;
  assign arlen_vector[AXI_LENW*(11+1)-1 : AXI_LENW*11]                                        = arlen_11_w;
  assign arsize_vector[AXI_SIZEW*(11+1)-1 : AXI_SIZEW*11]                                     = arsize_11_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(11+2)-1:AXI_LOCKW_NB*(11+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(11+1)-1:AXI_LOCKW_NB*11]] = arlock_11_w;
  assign arburst_vector[AXI_BURSTW*(11+1)-1 : AXI_BURSTW*11]                                  = arburst_11_w;
  assign arcache_vector[AXI_CACHEW*(11+1)-1 : AXI_CACHEW*11]                                  = arcache_11_w;
  assign arprot_vector[AXI_PROTW*(11+1)-1 : AXI_PROTW*11]                                     = arprot_11_w;
  assign arqos_vector[AXI_QOSW*(11+1)-1 : AXI_QOSW*11]                                        = arqos_11_w;
  assign arurgentb_vector[11]                                                                = arurgentb_11_w;
  assign arurgentr_vector[11]                                                                = arurgentr_11_w;
  assign arpoison_vector[11]                                                                 = arpoison_11_w;
  assign arautopre_vector[11]                                                                = arautopre_11_w;
  assign arvalid_vector[11]                                                                  = arvalid_11_w;
  assign aruser_vector[AXI_USERW*(11+1)-1 : AXI_USERW*11]                                     = aruser_11_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(11+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*11]  = arparity_11_w;

  assign rready_vector[11]                                                                   = rready_11_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(11+1)-1 : UMCTL2_RDATARAM_DW*11]                 = rdataram_dout_11_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(11+1)-1 : UMCTL2_DATARAM_PAR_DW*11]       = rdataram_dout_par_11_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(11+1)-1 : UMCTL2_RDATARAM_DW*11]            = rdataram_dout_dch1_11_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(11+1)-1 : UMCTL2_DATARAM_PAR_DW*11]  = rdataram_dout_par_dch1_11_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(11+1)-1 : XPI_RQOS_MLW*11]                  = reg_arba11_rqos_map_level1_11_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(11+1)-1 : XPI_RQOS_MLW*11]                  = reg_arba11_rqos_map_level2_11_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(11+1)-1 : XPI_RQOS_RW*11]                   = reg_arba11_rqos_map_region0_11_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(11+1)-1 : XPI_RQOS_RW*11]                   = reg_arba11_rqos_map_region1_11_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(11+1)-1 : XPI_RQOS_RW*11]                   = reg_arba11_rqos_map_region2_11_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(11+1)-1 : HIF_RQOS_TW*11]                   = reg_arb_rqos_map_timeoutb_11_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(11+1)-1 : HIF_RQOS_TW*11]                   = reg_arb_rqos_map_timeoutr_11_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(11+1)-1 : XPI_WQOS_MLW*11]                  = reg_arba11_wqos_map_level1_11_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(11+1)-1 : XPI_WQOS_MLW*11]                  = reg_arba11_wqos_map_level2_11_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(11+1)-1 : XPI_WQOS_RW*11]                   = reg_arba11_wqos_map_region0_11_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(11+1)-1 : XPI_WQOS_RW*11]                   = reg_arba11_wqos_map_region1_11_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(11+1)-1 : XPI_WQOS_RW*11]                   = reg_arba11_wqos_map_region2_11_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(11+1)-1 : HIF_WQOS_TW*11]                   = reg_arb_wqos_map_timeout1_11_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(11+1)-1 : HIF_WQOS_TW*11]                   = reg_arb_wqos_map_timeout2_11_w;

  assign reg_arb_rd_port_pagematch_en_vector[11]                                                 = reg_arb_rd_port_pagematch_en_11_w;
  assign reg_arb_wr_port_pagematch_en_vector[11]                                                 = reg_arb_wr_port_pagematch_en_11_w;

  assign reg_arb_rdwr_ordered_en_vector[11]                                                      = reg_arb_rdwr_ordered_en_11_w;
  assign reg_arba_rdwr_ordered_en_vector[11]                                                     = reg_arba11_rdwr_ordered_en_11_w;
  assign reg_arb_port_data_channel_vector[11]                                                    = reg_arb_port_data_channel_11_w;
  assign reg_arba_data_bus_width_vector[2*(11+1)-1 : 2*11]                                        = reg_arba_data_bus_width_11_w;
  assign reg_xpi_snf_mode_vector[11]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(11+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*11]  = reg_arb_rrb_lock_threshold_11_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(12+1)-1 : REG_PORT_PRIORITYW*12] = reg_arb_wr_port_priority_12_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(12+1)-1 : REG_PORT_PRIORITYW*12] = reg_arb_rd_port_priority_12_w;
  assign reg_arb_wr_port_aging_en_vector[12]                                               = reg_arb_wr_port_aging_en_12_w;
  assign reg_arb_rd_port_aging_en_vector[12]                                               = reg_arb_rd_port_aging_en_12_w;
  assign reg_arb_wr_port_urgent_en_vector[12]                                              = reg_arb_wr_port_urgent_en_12_w;
  assign reg_arb_rd_port_urgent_en_vector[12]                                              = reg_arb_rd_port_urgent_en_12_w;

  assign aclk_vector[12]                                                                   = aclk_12_w;
  assign aresetn_vector[12]                                                                = aresetn_12_w;
  assign sync_aresetn_vector[12]                                                           = sync_aresetn_12_w;
  assign csysreq_xpi_vector[12]                                                            = csysreq_xpi_12_w;
  assign reg_arb_port_en_vector[12]                                                        = reg_arba12_port_en_12_w;
  assign reg_arb_bypass_reorder_vector[12]                                                 = reg_arba12_read_reorder_bypass_en_12_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(12+2)-1:ARB_ID_NB*(12+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(12+1)-1:ARB_ID_NB*12]]  = reg_arba12_id_mask_12_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(12+2)-1:ARB_ID_NB*(12+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(12+1)-1:ARB_ID_NB*12]] = reg_arba12_id_value_12_w;

  assign awid_vector[AXI_IDW*(12+1)-1 : AXI_IDW*12]                                           = awid_12_w;
  assign awaddr_vector[AXI_ADDRW*(12+1)-1 : AXI_ADDRW*12]                                     = awaddr_12_w;
  assign awlen_vector[AXI_LENW*(12+1)-1 : AXI_LENW*12]                                        = awlen_12_w;
  assign awsize_vector[AXI_SIZEW*(12+1)-1 : AXI_SIZEW*12]                                     = awsize_12_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(12+2)-1:AXI_LOCKW_NB*(12+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(12+1)-1:AXI_LOCKW_NB*12]] = awlock_12_w;
  assign awburst_vector[AXI_BURSTW*(12+1)-1 : AXI_BURSTW*12]                                  = awburst_12_w;
  assign awcache_vector[AXI_CACHEW*(12+1)-1 : AXI_CACHEW*12]                                  = awcache_12_w;
  assign awprot_vector[AXI_PROTW*(12+1)-1 : AXI_PROTW*12]                                     = awprot_12_w;
  assign awqos_vector[AXI_QOSW*(12+1)-1 : AXI_QOSW*12]                                        = awqos_12_w;
  assign awurgent_vector[12]                                                                 = awurgent_12_w;
  assign awpoison_vector[12]                                                                 = awpoison_12_w;
  assign awautopre_vector[12]                                                                = awautopre_12_w;
  assign awvalid_vector[12]                                                                  = awvalid_12_w;
  assign awuser_vector[AXI_USERW*(12+1)-1 : AXI_USERW*12]                                     = awuser_12_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(12+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*12]       = awparity_12_w;

  assign wid_vector[AXI_IDW*(12+1)-1 : AXI_IDW*12]                                            = wid_12_w;
  assign wlast_vector[12]                                                                    = wlast_12_w;
  assign wvalid_vector[12]                                                                   = wvalid_12_w;
  assign wuser_vector[AXI_USERW*(12+1)-1 : AXI_USERW*12]                                      = wuser_12_w;

  assign bready_vector[12]                                                                   = bready_12_w;

  assign arid_vector[AXI_IDW*(12+1)-1 : AXI_IDW*12]                                           = arid_12_w;
  assign araddr_vector[AXI_ADDRW*(12+1)-1 : AXI_ADDRW*12]                                     = araddr_12_w;
  assign arlen_vector[AXI_LENW*(12+1)-1 : AXI_LENW*12]                                        = arlen_12_w;
  assign arsize_vector[AXI_SIZEW*(12+1)-1 : AXI_SIZEW*12]                                     = arsize_12_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(12+2)-1:AXI_LOCKW_NB*(12+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(12+1)-1:AXI_LOCKW_NB*12]] = arlock_12_w;
  assign arburst_vector[AXI_BURSTW*(12+1)-1 : AXI_BURSTW*12]                                  = arburst_12_w;
  assign arcache_vector[AXI_CACHEW*(12+1)-1 : AXI_CACHEW*12]                                  = arcache_12_w;
  assign arprot_vector[AXI_PROTW*(12+1)-1 : AXI_PROTW*12]                                     = arprot_12_w;
  assign arqos_vector[AXI_QOSW*(12+1)-1 : AXI_QOSW*12]                                        = arqos_12_w;
  assign arurgentb_vector[12]                                                                = arurgentb_12_w;
  assign arurgentr_vector[12]                                                                = arurgentr_12_w;
  assign arpoison_vector[12]                                                                 = arpoison_12_w;
  assign arautopre_vector[12]                                                                = arautopre_12_w;
  assign arvalid_vector[12]                                                                  = arvalid_12_w;
  assign aruser_vector[AXI_USERW*(12+1)-1 : AXI_USERW*12]                                     = aruser_12_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(12+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*12]  = arparity_12_w;

  assign rready_vector[12]                                                                   = rready_12_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(12+1)-1 : UMCTL2_RDATARAM_DW*12]                 = rdataram_dout_12_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(12+1)-1 : UMCTL2_DATARAM_PAR_DW*12]       = rdataram_dout_par_12_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(12+1)-1 : UMCTL2_RDATARAM_DW*12]            = rdataram_dout_dch1_12_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(12+1)-1 : UMCTL2_DATARAM_PAR_DW*12]  = rdataram_dout_par_dch1_12_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(12+1)-1 : XPI_RQOS_MLW*12]                  = reg_arba12_rqos_map_level1_12_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(12+1)-1 : XPI_RQOS_MLW*12]                  = reg_arba12_rqos_map_level2_12_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(12+1)-1 : XPI_RQOS_RW*12]                   = reg_arba12_rqos_map_region0_12_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(12+1)-1 : XPI_RQOS_RW*12]                   = reg_arba12_rqos_map_region1_12_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(12+1)-1 : XPI_RQOS_RW*12]                   = reg_arba12_rqos_map_region2_12_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(12+1)-1 : HIF_RQOS_TW*12]                   = reg_arb_rqos_map_timeoutb_12_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(12+1)-1 : HIF_RQOS_TW*12]                   = reg_arb_rqos_map_timeoutr_12_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(12+1)-1 : XPI_WQOS_MLW*12]                  = reg_arba12_wqos_map_level1_12_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(12+1)-1 : XPI_WQOS_MLW*12]                  = reg_arba12_wqos_map_level2_12_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(12+1)-1 : XPI_WQOS_RW*12]                   = reg_arba12_wqos_map_region0_12_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(12+1)-1 : XPI_WQOS_RW*12]                   = reg_arba12_wqos_map_region1_12_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(12+1)-1 : XPI_WQOS_RW*12]                   = reg_arba12_wqos_map_region2_12_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(12+1)-1 : HIF_WQOS_TW*12]                   = reg_arb_wqos_map_timeout1_12_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(12+1)-1 : HIF_WQOS_TW*12]                   = reg_arb_wqos_map_timeout2_12_w;

  assign reg_arb_rd_port_pagematch_en_vector[12]                                                 = reg_arb_rd_port_pagematch_en_12_w;
  assign reg_arb_wr_port_pagematch_en_vector[12]                                                 = reg_arb_wr_port_pagematch_en_12_w;

  assign reg_arb_rdwr_ordered_en_vector[12]                                                      = reg_arb_rdwr_ordered_en_12_w;
  assign reg_arba_rdwr_ordered_en_vector[12]                                                     = reg_arba12_rdwr_ordered_en_12_w;
  assign reg_arb_port_data_channel_vector[12]                                                    = reg_arb_port_data_channel_12_w;
  assign reg_arba_data_bus_width_vector[2*(12+1)-1 : 2*12]                                        = reg_arba_data_bus_width_12_w;
  assign reg_xpi_snf_mode_vector[12]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(12+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*12]  = reg_arb_rrb_lock_threshold_12_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(13+1)-1 : REG_PORT_PRIORITYW*13] = reg_arb_wr_port_priority_13_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(13+1)-1 : REG_PORT_PRIORITYW*13] = reg_arb_rd_port_priority_13_w;
  assign reg_arb_wr_port_aging_en_vector[13]                                               = reg_arb_wr_port_aging_en_13_w;
  assign reg_arb_rd_port_aging_en_vector[13]                                               = reg_arb_rd_port_aging_en_13_w;
  assign reg_arb_wr_port_urgent_en_vector[13]                                              = reg_arb_wr_port_urgent_en_13_w;
  assign reg_arb_rd_port_urgent_en_vector[13]                                              = reg_arb_rd_port_urgent_en_13_w;

  assign aclk_vector[13]                                                                   = aclk_13_w;
  assign aresetn_vector[13]                                                                = aresetn_13_w;
  assign sync_aresetn_vector[13]                                                           = sync_aresetn_13_w;
  assign csysreq_xpi_vector[13]                                                            = csysreq_xpi_13_w;
  assign reg_arb_port_en_vector[13]                                                        = reg_arba13_port_en_13_w;
  assign reg_arb_bypass_reorder_vector[13]                                                 = reg_arba13_read_reorder_bypass_en_13_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(13+2)-1:ARB_ID_NB*(13+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(13+1)-1:ARB_ID_NB*13]]  = reg_arba13_id_mask_13_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(13+2)-1:ARB_ID_NB*(13+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(13+1)-1:ARB_ID_NB*13]] = reg_arba13_id_value_13_w;

  assign awid_vector[AXI_IDW*(13+1)-1 : AXI_IDW*13]                                           = awid_13_w;
  assign awaddr_vector[AXI_ADDRW*(13+1)-1 : AXI_ADDRW*13]                                     = awaddr_13_w;
  assign awlen_vector[AXI_LENW*(13+1)-1 : AXI_LENW*13]                                        = awlen_13_w;
  assign awsize_vector[AXI_SIZEW*(13+1)-1 : AXI_SIZEW*13]                                     = awsize_13_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(13+2)-1:AXI_LOCKW_NB*(13+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(13+1)-1:AXI_LOCKW_NB*13]] = awlock_13_w;
  assign awburst_vector[AXI_BURSTW*(13+1)-1 : AXI_BURSTW*13]                                  = awburst_13_w;
  assign awcache_vector[AXI_CACHEW*(13+1)-1 : AXI_CACHEW*13]                                  = awcache_13_w;
  assign awprot_vector[AXI_PROTW*(13+1)-1 : AXI_PROTW*13]                                     = awprot_13_w;
  assign awqos_vector[AXI_QOSW*(13+1)-1 : AXI_QOSW*13]                                        = awqos_13_w;
  assign awurgent_vector[13]                                                                 = awurgent_13_w;
  assign awpoison_vector[13]                                                                 = awpoison_13_w;
  assign awautopre_vector[13]                                                                = awautopre_13_w;
  assign awvalid_vector[13]                                                                  = awvalid_13_w;
  assign awuser_vector[AXI_USERW*(13+1)-1 : AXI_USERW*13]                                     = awuser_13_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(13+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*13]       = awparity_13_w;

  assign wid_vector[AXI_IDW*(13+1)-1 : AXI_IDW*13]                                            = wid_13_w;
  assign wlast_vector[13]                                                                    = wlast_13_w;
  assign wvalid_vector[13]                                                                   = wvalid_13_w;
  assign wuser_vector[AXI_USERW*(13+1)-1 : AXI_USERW*13]                                      = wuser_13_w;

  assign bready_vector[13]                                                                   = bready_13_w;

  assign arid_vector[AXI_IDW*(13+1)-1 : AXI_IDW*13]                                           = arid_13_w;
  assign araddr_vector[AXI_ADDRW*(13+1)-1 : AXI_ADDRW*13]                                     = araddr_13_w;
  assign arlen_vector[AXI_LENW*(13+1)-1 : AXI_LENW*13]                                        = arlen_13_w;
  assign arsize_vector[AXI_SIZEW*(13+1)-1 : AXI_SIZEW*13]                                     = arsize_13_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(13+2)-1:AXI_LOCKW_NB*(13+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(13+1)-1:AXI_LOCKW_NB*13]] = arlock_13_w;
  assign arburst_vector[AXI_BURSTW*(13+1)-1 : AXI_BURSTW*13]                                  = arburst_13_w;
  assign arcache_vector[AXI_CACHEW*(13+1)-1 : AXI_CACHEW*13]                                  = arcache_13_w;
  assign arprot_vector[AXI_PROTW*(13+1)-1 : AXI_PROTW*13]                                     = arprot_13_w;
  assign arqos_vector[AXI_QOSW*(13+1)-1 : AXI_QOSW*13]                                        = arqos_13_w;
  assign arurgentb_vector[13]                                                                = arurgentb_13_w;
  assign arurgentr_vector[13]                                                                = arurgentr_13_w;
  assign arpoison_vector[13]                                                                 = arpoison_13_w;
  assign arautopre_vector[13]                                                                = arautopre_13_w;
  assign arvalid_vector[13]                                                                  = arvalid_13_w;
  assign aruser_vector[AXI_USERW*(13+1)-1 : AXI_USERW*13]                                     = aruser_13_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(13+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*13]  = arparity_13_w;

  assign rready_vector[13]                                                                   = rready_13_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(13+1)-1 : UMCTL2_RDATARAM_DW*13]                 = rdataram_dout_13_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(13+1)-1 : UMCTL2_DATARAM_PAR_DW*13]       = rdataram_dout_par_13_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(13+1)-1 : UMCTL2_RDATARAM_DW*13]            = rdataram_dout_dch1_13_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(13+1)-1 : UMCTL2_DATARAM_PAR_DW*13]  = rdataram_dout_par_dch1_13_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(13+1)-1 : XPI_RQOS_MLW*13]                  = reg_arba13_rqos_map_level1_13_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(13+1)-1 : XPI_RQOS_MLW*13]                  = reg_arba13_rqos_map_level2_13_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(13+1)-1 : XPI_RQOS_RW*13]                   = reg_arba13_rqos_map_region0_13_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(13+1)-1 : XPI_RQOS_RW*13]                   = reg_arba13_rqos_map_region1_13_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(13+1)-1 : XPI_RQOS_RW*13]                   = reg_arba13_rqos_map_region2_13_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(13+1)-1 : HIF_RQOS_TW*13]                   = reg_arb_rqos_map_timeoutb_13_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(13+1)-1 : HIF_RQOS_TW*13]                   = reg_arb_rqos_map_timeoutr_13_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(13+1)-1 : XPI_WQOS_MLW*13]                  = reg_arba13_wqos_map_level1_13_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(13+1)-1 : XPI_WQOS_MLW*13]                  = reg_arba13_wqos_map_level2_13_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(13+1)-1 : XPI_WQOS_RW*13]                   = reg_arba13_wqos_map_region0_13_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(13+1)-1 : XPI_WQOS_RW*13]                   = reg_arba13_wqos_map_region1_13_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(13+1)-1 : XPI_WQOS_RW*13]                   = reg_arba13_wqos_map_region2_13_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(13+1)-1 : HIF_WQOS_TW*13]                   = reg_arb_wqos_map_timeout1_13_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(13+1)-1 : HIF_WQOS_TW*13]                   = reg_arb_wqos_map_timeout2_13_w;

  assign reg_arb_rd_port_pagematch_en_vector[13]                                                 = reg_arb_rd_port_pagematch_en_13_w;
  assign reg_arb_wr_port_pagematch_en_vector[13]                                                 = reg_arb_wr_port_pagematch_en_13_w;

  assign reg_arb_rdwr_ordered_en_vector[13]                                                      = reg_arb_rdwr_ordered_en_13_w;
  assign reg_arba_rdwr_ordered_en_vector[13]                                                     = reg_arba13_rdwr_ordered_en_13_w;
  assign reg_arb_port_data_channel_vector[13]                                                    = reg_arb_port_data_channel_13_w;
  assign reg_arba_data_bus_width_vector[2*(13+1)-1 : 2*13]                                        = reg_arba_data_bus_width_13_w;
  assign reg_xpi_snf_mode_vector[13]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(13+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*13]  = reg_arb_rrb_lock_threshold_13_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(14+1)-1 : REG_PORT_PRIORITYW*14] = reg_arb_wr_port_priority_14_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(14+1)-1 : REG_PORT_PRIORITYW*14] = reg_arb_rd_port_priority_14_w;
  assign reg_arb_wr_port_aging_en_vector[14]                                               = reg_arb_wr_port_aging_en_14_w;
  assign reg_arb_rd_port_aging_en_vector[14]                                               = reg_arb_rd_port_aging_en_14_w;
  assign reg_arb_wr_port_urgent_en_vector[14]                                              = reg_arb_wr_port_urgent_en_14_w;
  assign reg_arb_rd_port_urgent_en_vector[14]                                              = reg_arb_rd_port_urgent_en_14_w;

  assign aclk_vector[14]                                                                   = aclk_14_w;
  assign aresetn_vector[14]                                                                = aresetn_14_w;
  assign sync_aresetn_vector[14]                                                           = sync_aresetn_14_w;
  assign csysreq_xpi_vector[14]                                                            = csysreq_xpi_14_w;
  assign reg_arb_port_en_vector[14]                                                        = reg_arba14_port_en_14_w;
  assign reg_arb_bypass_reorder_vector[14]                                                 = reg_arba14_read_reorder_bypass_en_14_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(14+2)-1:ARB_ID_NB*(14+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(14+1)-1:ARB_ID_NB*14]]  = reg_arba14_id_mask_14_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(14+2)-1:ARB_ID_NB*(14+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(14+1)-1:ARB_ID_NB*14]] = reg_arba14_id_value_14_w;

  assign awid_vector[AXI_IDW*(14+1)-1 : AXI_IDW*14]                                           = awid_14_w;
  assign awaddr_vector[AXI_ADDRW*(14+1)-1 : AXI_ADDRW*14]                                     = awaddr_14_w;
  assign awlen_vector[AXI_LENW*(14+1)-1 : AXI_LENW*14]                                        = awlen_14_w;
  assign awsize_vector[AXI_SIZEW*(14+1)-1 : AXI_SIZEW*14]                                     = awsize_14_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(14+2)-1:AXI_LOCKW_NB*(14+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(14+1)-1:AXI_LOCKW_NB*14]] = awlock_14_w;
  assign awburst_vector[AXI_BURSTW*(14+1)-1 : AXI_BURSTW*14]                                  = awburst_14_w;
  assign awcache_vector[AXI_CACHEW*(14+1)-1 : AXI_CACHEW*14]                                  = awcache_14_w;
  assign awprot_vector[AXI_PROTW*(14+1)-1 : AXI_PROTW*14]                                     = awprot_14_w;
  assign awqos_vector[AXI_QOSW*(14+1)-1 : AXI_QOSW*14]                                        = awqos_14_w;
  assign awurgent_vector[14]                                                                 = awurgent_14_w;
  assign awpoison_vector[14]                                                                 = awpoison_14_w;
  assign awautopre_vector[14]                                                                = awautopre_14_w;
  assign awvalid_vector[14]                                                                  = awvalid_14_w;
  assign awuser_vector[AXI_USERW*(14+1)-1 : AXI_USERW*14]                                     = awuser_14_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(14+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*14]       = awparity_14_w;

  assign wid_vector[AXI_IDW*(14+1)-1 : AXI_IDW*14]                                            = wid_14_w;
  assign wlast_vector[14]                                                                    = wlast_14_w;
  assign wvalid_vector[14]                                                                   = wvalid_14_w;
  assign wuser_vector[AXI_USERW*(14+1)-1 : AXI_USERW*14]                                      = wuser_14_w;

  assign bready_vector[14]                                                                   = bready_14_w;

  assign arid_vector[AXI_IDW*(14+1)-1 : AXI_IDW*14]                                           = arid_14_w;
  assign araddr_vector[AXI_ADDRW*(14+1)-1 : AXI_ADDRW*14]                                     = araddr_14_w;
  assign arlen_vector[AXI_LENW*(14+1)-1 : AXI_LENW*14]                                        = arlen_14_w;
  assign arsize_vector[AXI_SIZEW*(14+1)-1 : AXI_SIZEW*14]                                     = arsize_14_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(14+2)-1:AXI_LOCKW_NB*(14+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(14+1)-1:AXI_LOCKW_NB*14]] = arlock_14_w;
  assign arburst_vector[AXI_BURSTW*(14+1)-1 : AXI_BURSTW*14]                                  = arburst_14_w;
  assign arcache_vector[AXI_CACHEW*(14+1)-1 : AXI_CACHEW*14]                                  = arcache_14_w;
  assign arprot_vector[AXI_PROTW*(14+1)-1 : AXI_PROTW*14]                                     = arprot_14_w;
  assign arqos_vector[AXI_QOSW*(14+1)-1 : AXI_QOSW*14]                                        = arqos_14_w;
  assign arurgentb_vector[14]                                                                = arurgentb_14_w;
  assign arurgentr_vector[14]                                                                = arurgentr_14_w;
  assign arpoison_vector[14]                                                                 = arpoison_14_w;
  assign arautopre_vector[14]                                                                = arautopre_14_w;
  assign arvalid_vector[14]                                                                  = arvalid_14_w;
  assign aruser_vector[AXI_USERW*(14+1)-1 : AXI_USERW*14]                                     = aruser_14_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(14+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*14]  = arparity_14_w;

  assign rready_vector[14]                                                                   = rready_14_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(14+1)-1 : UMCTL2_RDATARAM_DW*14]                 = rdataram_dout_14_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(14+1)-1 : UMCTL2_DATARAM_PAR_DW*14]       = rdataram_dout_par_14_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(14+1)-1 : UMCTL2_RDATARAM_DW*14]            = rdataram_dout_dch1_14_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(14+1)-1 : UMCTL2_DATARAM_PAR_DW*14]  = rdataram_dout_par_dch1_14_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(14+1)-1 : XPI_RQOS_MLW*14]                  = reg_arba14_rqos_map_level1_14_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(14+1)-1 : XPI_RQOS_MLW*14]                  = reg_arba14_rqos_map_level2_14_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(14+1)-1 : XPI_RQOS_RW*14]                   = reg_arba14_rqos_map_region0_14_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(14+1)-1 : XPI_RQOS_RW*14]                   = reg_arba14_rqos_map_region1_14_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(14+1)-1 : XPI_RQOS_RW*14]                   = reg_arba14_rqos_map_region2_14_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(14+1)-1 : HIF_RQOS_TW*14]                   = reg_arb_rqos_map_timeoutb_14_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(14+1)-1 : HIF_RQOS_TW*14]                   = reg_arb_rqos_map_timeoutr_14_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(14+1)-1 : XPI_WQOS_MLW*14]                  = reg_arba14_wqos_map_level1_14_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(14+1)-1 : XPI_WQOS_MLW*14]                  = reg_arba14_wqos_map_level2_14_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(14+1)-1 : XPI_WQOS_RW*14]                   = reg_arba14_wqos_map_region0_14_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(14+1)-1 : XPI_WQOS_RW*14]                   = reg_arba14_wqos_map_region1_14_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(14+1)-1 : XPI_WQOS_RW*14]                   = reg_arba14_wqos_map_region2_14_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(14+1)-1 : HIF_WQOS_TW*14]                   = reg_arb_wqos_map_timeout1_14_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(14+1)-1 : HIF_WQOS_TW*14]                   = reg_arb_wqos_map_timeout2_14_w;

  assign reg_arb_rd_port_pagematch_en_vector[14]                                                 = reg_arb_rd_port_pagematch_en_14_w;
  assign reg_arb_wr_port_pagematch_en_vector[14]                                                 = reg_arb_wr_port_pagematch_en_14_w;

  assign reg_arb_rdwr_ordered_en_vector[14]                                                      = reg_arb_rdwr_ordered_en_14_w;
  assign reg_arba_rdwr_ordered_en_vector[14]                                                     = reg_arba14_rdwr_ordered_en_14_w;
  assign reg_arb_port_data_channel_vector[14]                                                    = reg_arb_port_data_channel_14_w;
  assign reg_arba_data_bus_width_vector[2*(14+1)-1 : 2*14]                                        = reg_arba_data_bus_width_14_w;
  assign reg_xpi_snf_mode_vector[14]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(14+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*14]  = reg_arb_rrb_lock_threshold_14_w;

  assign reg_arb_wr_port_priority_vector[REG_PORT_PRIORITYW*(15+1)-1 : REG_PORT_PRIORITYW*15] = reg_arb_wr_port_priority_15_w;
  assign reg_arb_rd_port_priority_vector[REG_PORT_PRIORITYW*(15+1)-1 : REG_PORT_PRIORITYW*15] = reg_arb_rd_port_priority_15_w;
  assign reg_arb_wr_port_aging_en_vector[15]                                               = reg_arb_wr_port_aging_en_15_w;
  assign reg_arb_rd_port_aging_en_vector[15]                                               = reg_arb_rd_port_aging_en_15_w;
  assign reg_arb_wr_port_urgent_en_vector[15]                                              = reg_arb_wr_port_urgent_en_15_w;
  assign reg_arb_rd_port_urgent_en_vector[15]                                              = reg_arb_rd_port_urgent_en_15_w;

  assign aclk_vector[15]                                                                   = aclk_15_w;
  assign aresetn_vector[15]                                                                = aresetn_15_w;
  assign sync_aresetn_vector[15]                                                           = sync_aresetn_15_w;
  assign csysreq_xpi_vector[15]                                                            = csysreq_xpi_15_w;
  assign reg_arb_port_en_vector[15]                                                        = reg_arba15_port_en_15_w;
  assign reg_arb_bypass_reorder_vector[15]                                                 = reg_arba15_read_reorder_bypass_en_15_w;

  assign reg_arb_id_mask_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(15+2)-1:ARB_ID_NB*(15+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(15+1)-1:ARB_ID_NB*15]]  = reg_arba15_id_mask_15_w;
  assign reg_arb_id_value_vector[ARB_ID_BUS_TABLE[ARB_ID_NB*(15+2)-1:ARB_ID_NB*(15+1)]-1:ARB_ID_BUS_TABLE[ARB_ID_NB*(15+1)-1:ARB_ID_NB*15]] = reg_arba15_id_value_15_w;

  assign awid_vector[AXI_IDW*(15+1)-1 : AXI_IDW*15]                                           = awid_15_w;
  assign awaddr_vector[AXI_ADDRW*(15+1)-1 : AXI_ADDRW*15]                                     = awaddr_15_w;
  assign awlen_vector[AXI_LENW*(15+1)-1 : AXI_LENW*15]                                        = awlen_15_w;
  assign awsize_vector[AXI_SIZEW*(15+1)-1 : AXI_SIZEW*15]                                     = awsize_15_w;
  assign awlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(15+2)-1:AXI_LOCKW_NB*(15+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(15+1)-1:AXI_LOCKW_NB*15]] = awlock_15_w;
  assign awburst_vector[AXI_BURSTW*(15+1)-1 : AXI_BURSTW*15]                                  = awburst_15_w;
  assign awcache_vector[AXI_CACHEW*(15+1)-1 : AXI_CACHEW*15]                                  = awcache_15_w;
  assign awprot_vector[AXI_PROTW*(15+1)-1 : AXI_PROTW*15]                                     = awprot_15_w;
  assign awqos_vector[AXI_QOSW*(15+1)-1 : AXI_QOSW*15]                                        = awqos_15_w;
  assign awurgent_vector[15]                                                                 = awurgent_15_w;
  assign awpoison_vector[15]                                                                 = awpoison_15_w;
  assign awautopre_vector[15]                                                                = awautopre_15_w;
  assign awvalid_vector[15]                                                                  = awvalid_15_w;
  assign awuser_vector[AXI_USERW*(15+1)-1 : AXI_USERW*15]                                     = awuser_15_w;
  assign awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(15+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*15]       = awparity_15_w;

  assign wid_vector[AXI_IDW*(15+1)-1 : AXI_IDW*15]                                            = wid_15_w;
  assign wlast_vector[15]                                                                    = wlast_15_w;
  assign wvalid_vector[15]                                                                   = wvalid_15_w;
  assign wuser_vector[AXI_USERW*(15+1)-1 : AXI_USERW*15]                                      = wuser_15_w;

  assign bready_vector[15]                                                                   = bready_15_w;

  assign arid_vector[AXI_IDW*(15+1)-1 : AXI_IDW*15]                                           = arid_15_w;
  assign araddr_vector[AXI_ADDRW*(15+1)-1 : AXI_ADDRW*15]                                     = araddr_15_w;
  assign arlen_vector[AXI_LENW*(15+1)-1 : AXI_LENW*15]                                        = arlen_15_w;
  assign arsize_vector[AXI_SIZEW*(15+1)-1 : AXI_SIZEW*15]                                     = arsize_15_w;
  assign arlock_vector[AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(15+2)-1:AXI_LOCKW_NB*(15+1)]-1:AXI_LOCKW_BUS_TABLE[AXI_LOCKW_NB*(15+1)-1:AXI_LOCKW_NB*15]] = arlock_15_w;
  assign arburst_vector[AXI_BURSTW*(15+1)-1 : AXI_BURSTW*15]                                  = arburst_15_w;
  assign arcache_vector[AXI_CACHEW*(15+1)-1 : AXI_CACHEW*15]                                  = arcache_15_w;
  assign arprot_vector[AXI_PROTW*(15+1)-1 : AXI_PROTW*15]                                     = arprot_15_w;
  assign arqos_vector[AXI_QOSW*(15+1)-1 : AXI_QOSW*15]                                        = arqos_15_w;
  assign arurgentb_vector[15]                                                                = arurgentb_15_w;
  assign arurgentr_vector[15]                                                                = arurgentr_15_w;
  assign arpoison_vector[15]                                                                 = arpoison_15_w;
  assign arautopre_vector[15]                                                                = arautopre_15_w;
  assign arvalid_vector[15]                                                                  = arvalid_15_w;
  assign aruser_vector[AXI_USERW*(15+1)-1 : AXI_USERW*15]                                     = aruser_15_w;
  assign arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*(15+1)-1 : OCPAR_ADDR_PARITY_WIDTH_MIN*15]  = arparity_15_w;

  assign rready_vector[15]                                                                   = rready_15_w;

  assign rdataram_dout_vector[UMCTL2_RDATARAM_DW*(15+1)-1 : UMCTL2_RDATARAM_DW*15]                 = rdataram_dout_15_w;
  assign rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*(15+1)-1 : UMCTL2_DATARAM_PAR_DW*15]       = rdataram_dout_par_15_w;
  assign rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*(15+1)-1 : UMCTL2_RDATARAM_DW*15]            = rdataram_dout_dch1_15_w;
  assign rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*(15+1)-1 : UMCTL2_DATARAM_PAR_DW*15]  = rdataram_dout_par_dch1_15_w;

  assign reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*(15+1)-1 : XPI_RQOS_MLW*15]                  = reg_arba15_rqos_map_level1_15_w;
  assign reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*(15+1)-1 : XPI_RQOS_MLW*15]                  = reg_arba15_rqos_map_level2_15_w;
  assign reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*(15+1)-1 : XPI_RQOS_RW*15]                   = reg_arba15_rqos_map_region0_15_w;
  assign reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*(15+1)-1 : XPI_RQOS_RW*15]                   = reg_arba15_rqos_map_region1_15_w;
  assign reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*(15+1)-1 : XPI_RQOS_RW*15]                   = reg_arba15_rqos_map_region2_15_w;


  assign reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*(15+1)-1 : HIF_RQOS_TW*15]                   = reg_arb_rqos_map_timeoutb_15_w;
  assign reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*(15+1)-1 : HIF_RQOS_TW*15]                   = reg_arb_rqos_map_timeoutr_15_w;

  assign reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*(15+1)-1 : XPI_WQOS_MLW*15]                  = reg_arba15_wqos_map_level1_15_w;
  assign reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*(15+1)-1 : XPI_WQOS_MLW*15]                  = reg_arba15_wqos_map_level2_15_w;
  assign reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*(15+1)-1 : XPI_WQOS_RW*15]                   = reg_arba15_wqos_map_region0_15_w;
  assign reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*(15+1)-1 : XPI_WQOS_RW*15]                   = reg_arba15_wqos_map_region1_15_w;
  assign reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*(15+1)-1 : XPI_WQOS_RW*15]                   = reg_arba15_wqos_map_region2_15_w;

  assign reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*(15+1)-1 : HIF_WQOS_TW*15]                   = reg_arb_wqos_map_timeout1_15_w;
  assign reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*(15+1)-1 : HIF_WQOS_TW*15]                   = reg_arb_wqos_map_timeout2_15_w;

  assign reg_arb_rd_port_pagematch_en_vector[15]                                                 = reg_arb_rd_port_pagematch_en_15_w;
  assign reg_arb_wr_port_pagematch_en_vector[15]                                                 = reg_arb_wr_port_pagematch_en_15_w;

  assign reg_arb_rdwr_ordered_en_vector[15]                                                      = reg_arb_rdwr_ordered_en_15_w;
  assign reg_arba_rdwr_ordered_en_vector[15]                                                     = reg_arba15_rdwr_ordered_en_15_w;
  assign reg_arb_port_data_channel_vector[15]                                                    = reg_arb_port_data_channel_15_w;
  assign reg_arba_data_bus_width_vector[2*(15+1)-1 : 2*15]                                        = reg_arba_data_bus_width_15_w;
  assign reg_xpi_snf_mode_vector[15]                                                             = 1'b0;

  assign reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*(15+1)-1 : RRB_LOCK_THRESHOLD_WIDTH*15]  = reg_arb_rrb_lock_threshold_15_w;



  assign csysack_xpi_0_w = csysack_xpi_vector_ext[0];
  assign awready_0_w     = awready_vector_ext[0];
  assign wready_0_w      = wready_vector_ext[0];
  assign bid_0_w         = bid_vector_ext[AXI_IDW*(0+1)-1:AXI_IDW*0];
  assign bresp_0_w       = bresp_vector_ext[AXI_RESPW*(0+1)-1:AXI_RESPW*0];
  assign buser_0_w       = buser_vector_ext[AXI_USERW*(0+1)-1:AXI_USERW*0];
  assign bvalid_0_w      = bvalid_vector_ext[0];
  assign arready_0_w     = arready_vector_ext[0];
  assign rid_0_w         = rid_vector_ext[AXI_IDW*(0+1)-1:AXI_IDW*0];
  assign rdata_0_w       = rdata_vector[AXI_DATAW_BUS_TABLE[AXI_DW_NB*(0+2)-1:AXI_DW_NB*(0+1)]-1:AXI_DATAW_BUS_TABLE[AXI_DW_NB*(0+1)-1:AXI_DW_NB*0]];
  assign rparity_0_w     = rparity_vector[AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(0+2)-1:AXI_STRBW_NB*(0+1)]-1:AXI_STRBW_BUS_TABLE[AXI_STRBW_NB*(0+1)-1:AXI_STRBW_NB*0]];
  assign ruser_0_w       = ruser_vector_ext[AXI_USERW*(0+1)-1:AXI_USERW*0];
  assign rresp_0_w       = rresp_vector_ext[AXI_RESPW*(0+1)-1:AXI_RESPW*0];
  assign rlast_0_w       = rlast_vector_ext[0];
  assign rvalid_0_w      = rvalid_vector_ext[0];

  assign rdataram_din_0_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(0+1)-1:UMCTL2_RDATARAM_DW*0];
  assign rdataram_wr_0_w           = rdataram_wr_vector_ext[0];
  assign rdataram_re_0_w           = rdataram_re_vector_ext[0];
  assign rdataram_raddr_0_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(0+1)-1:UMCTL2_RDATARAM_AW*0];
  assign rdataram_waddr_0_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(0+1)-1:UMCTL2_RDATARAM_AW*0];
  assign rdataram_din_par_0_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(0+1)-1:UMCTL2_DATARAM_PAR_DW*0];

  assign rdataram_din_dch1_0_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(0+1)-1:UMCTL2_RDATARAM_DW*0];
  assign rdataram_wr_dch1_0_w      = rdataram_wr_dch1_vector_ext[0];
  assign rdataram_re_dch1_0_w      = rdataram_re_dch1_vector_ext[0];
  assign rdataram_raddr_dch1_0_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(0+1)-1:UMCTL2_RDATARAM_AW*0];
  assign rdataram_waddr_dch1_0_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(0+1)-1:UMCTL2_RDATARAM_AW*0];
  assign rdataram_din_par_dch1_0_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(0+1)-1:UMCTL2_DATARAM_PAR_DW*0];

  assign raqb_pop_0_w              = raqb_pop_vector_ext[0];
  assign raqb_push_0_w             = raqb_push_vector_ext[0];
  assign raqr_pop_0_w              = raqr_pop_vector_ext[0];
  assign raqr_push_0_w             = raqr_push_vector_ext[0];
  assign raq_split_0_w             = raq_split_vector_ext[0];

  assign waq_pop_0_w               = waq_pop_vector_ext[0];
  assign waq_push_0_w              = waq_push_vector_ext[0];
  assign waq_split_0_w             = waq_split_vector_ext[0];

  assign csysack_xpi_1_w = csysack_xpi_vector_ext[1];
  assign awready_1_w     = awready_vector_ext[1];
  assign wready_1_w      = wready_vector_ext[1];
  assign bid_1_w         = bid_vector_ext[AXI_IDW*(1+1)-1:AXI_IDW*1];
  assign bresp_1_w       = bresp_vector_ext[AXI_RESPW*(1+1)-1:AXI_RESPW*1];
  assign buser_1_w       = buser_vector_ext[AXI_USERW*(1+1)-1:AXI_USERW*1];
  assign bvalid_1_w      = bvalid_vector_ext[1];
  assign arready_1_w     = arready_vector_ext[1];
  assign rid_1_w         = rid_vector_ext[AXI_IDW*(1+1)-1:AXI_IDW*1];
  assign rdata_1_w       = {(`UMCTL2_PORT_DW_1){1'b0}};
  assign rparity_1_w     = {(`UMCTL2_PORT_NBYTES_1){1'b0}};
  assign ruser_1_w       = ruser_vector_ext[AXI_USERW*(1+1)-1:AXI_USERW*1];
  assign rresp_1_w       = rresp_vector_ext[AXI_RESPW*(1+1)-1:AXI_RESPW*1];
  assign rlast_1_w       = rlast_vector_ext[1];
  assign rvalid_1_w      = rvalid_vector_ext[1];

  assign rdataram_din_1_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(1+1)-1:UMCTL2_RDATARAM_DW*1];
  assign rdataram_wr_1_w           = rdataram_wr_vector_ext[1];
  assign rdataram_re_1_w           = rdataram_re_vector_ext[1];
  assign rdataram_raddr_1_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(1+1)-1:UMCTL2_RDATARAM_AW*1];
  assign rdataram_waddr_1_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(1+1)-1:UMCTL2_RDATARAM_AW*1];
  assign rdataram_din_par_1_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(1+1)-1:UMCTL2_DATARAM_PAR_DW*1];

  assign rdataram_din_dch1_1_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(1+1)-1:UMCTL2_RDATARAM_DW*1];
  assign rdataram_wr_dch1_1_w      = rdataram_wr_dch1_vector_ext[1];
  assign rdataram_re_dch1_1_w      = rdataram_re_dch1_vector_ext[1];
  assign rdataram_raddr_dch1_1_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(1+1)-1:UMCTL2_RDATARAM_AW*1];
  assign rdataram_waddr_dch1_1_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(1+1)-1:UMCTL2_RDATARAM_AW*1];
  assign rdataram_din_par_dch1_1_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(1+1)-1:UMCTL2_DATARAM_PAR_DW*1];

  assign raqb_pop_1_w              = raqb_pop_vector_ext[1];
  assign raqb_push_1_w             = raqb_push_vector_ext[1];
  assign raqr_pop_1_w              = raqr_pop_vector_ext[1];
  assign raqr_push_1_w             = raqr_push_vector_ext[1];
  assign raq_split_1_w             = raq_split_vector_ext[1];

  assign waq_pop_1_w               = waq_pop_vector_ext[1];
  assign waq_push_1_w              = waq_push_vector_ext[1];
  assign waq_split_1_w             = waq_split_vector_ext[1];

  assign csysack_xpi_2_w = csysack_xpi_vector_ext[2];
  assign awready_2_w     = awready_vector_ext[2];
  assign wready_2_w      = wready_vector_ext[2];
  assign bid_2_w         = bid_vector_ext[AXI_IDW*(2+1)-1:AXI_IDW*2];
  assign bresp_2_w       = bresp_vector_ext[AXI_RESPW*(2+1)-1:AXI_RESPW*2];
  assign buser_2_w       = buser_vector_ext[AXI_USERW*(2+1)-1:AXI_USERW*2];
  assign bvalid_2_w      = bvalid_vector_ext[2];
  assign arready_2_w     = arready_vector_ext[2];
  assign rid_2_w         = rid_vector_ext[AXI_IDW*(2+1)-1:AXI_IDW*2];
  assign rdata_2_w       = {(`UMCTL2_PORT_DW_2){1'b0}};
  assign rparity_2_w     = {(`UMCTL2_PORT_NBYTES_2){1'b0}};
  assign ruser_2_w       = ruser_vector_ext[AXI_USERW*(2+1)-1:AXI_USERW*2];
  assign rresp_2_w       = rresp_vector_ext[AXI_RESPW*(2+1)-1:AXI_RESPW*2];
  assign rlast_2_w       = rlast_vector_ext[2];
  assign rvalid_2_w      = rvalid_vector_ext[2];

  assign rdataram_din_2_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(2+1)-1:UMCTL2_RDATARAM_DW*2];
  assign rdataram_wr_2_w           = rdataram_wr_vector_ext[2];
  assign rdataram_re_2_w           = rdataram_re_vector_ext[2];
  assign rdataram_raddr_2_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(2+1)-1:UMCTL2_RDATARAM_AW*2];
  assign rdataram_waddr_2_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(2+1)-1:UMCTL2_RDATARAM_AW*2];
  assign rdataram_din_par_2_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(2+1)-1:UMCTL2_DATARAM_PAR_DW*2];

  assign rdataram_din_dch1_2_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(2+1)-1:UMCTL2_RDATARAM_DW*2];
  assign rdataram_wr_dch1_2_w      = rdataram_wr_dch1_vector_ext[2];
  assign rdataram_re_dch1_2_w      = rdataram_re_dch1_vector_ext[2];
  assign rdataram_raddr_dch1_2_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(2+1)-1:UMCTL2_RDATARAM_AW*2];
  assign rdataram_waddr_dch1_2_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(2+1)-1:UMCTL2_RDATARAM_AW*2];
  assign rdataram_din_par_dch1_2_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(2+1)-1:UMCTL2_DATARAM_PAR_DW*2];

  assign raqb_pop_2_w              = raqb_pop_vector_ext[2];
  assign raqb_push_2_w             = raqb_push_vector_ext[2];
  assign raqr_pop_2_w              = raqr_pop_vector_ext[2];
  assign raqr_push_2_w             = raqr_push_vector_ext[2];
  assign raq_split_2_w             = raq_split_vector_ext[2];

  assign waq_pop_2_w               = waq_pop_vector_ext[2];
  assign waq_push_2_w              = waq_push_vector_ext[2];
  assign waq_split_2_w             = waq_split_vector_ext[2];

  assign csysack_xpi_3_w = csysack_xpi_vector_ext[3];
  assign awready_3_w     = awready_vector_ext[3];
  assign wready_3_w      = wready_vector_ext[3];
  assign bid_3_w         = bid_vector_ext[AXI_IDW*(3+1)-1:AXI_IDW*3];
  assign bresp_3_w       = bresp_vector_ext[AXI_RESPW*(3+1)-1:AXI_RESPW*3];
  assign buser_3_w       = buser_vector_ext[AXI_USERW*(3+1)-1:AXI_USERW*3];
  assign bvalid_3_w      = bvalid_vector_ext[3];
  assign arready_3_w     = arready_vector_ext[3];
  assign rid_3_w         = rid_vector_ext[AXI_IDW*(3+1)-1:AXI_IDW*3];
  assign rdata_3_w       = {(`UMCTL2_PORT_DW_3){1'b0}};
  assign rparity_3_w     = {(`UMCTL2_PORT_NBYTES_3){1'b0}};
  assign ruser_3_w       = ruser_vector_ext[AXI_USERW*(3+1)-1:AXI_USERW*3];
  assign rresp_3_w       = rresp_vector_ext[AXI_RESPW*(3+1)-1:AXI_RESPW*3];
  assign rlast_3_w       = rlast_vector_ext[3];
  assign rvalid_3_w      = rvalid_vector_ext[3];

  assign rdataram_din_3_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(3+1)-1:UMCTL2_RDATARAM_DW*3];
  assign rdataram_wr_3_w           = rdataram_wr_vector_ext[3];
  assign rdataram_re_3_w           = rdataram_re_vector_ext[3];
  assign rdataram_raddr_3_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(3+1)-1:UMCTL2_RDATARAM_AW*3];
  assign rdataram_waddr_3_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(3+1)-1:UMCTL2_RDATARAM_AW*3];
  assign rdataram_din_par_3_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(3+1)-1:UMCTL2_DATARAM_PAR_DW*3];

  assign rdataram_din_dch1_3_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(3+1)-1:UMCTL2_RDATARAM_DW*3];
  assign rdataram_wr_dch1_3_w      = rdataram_wr_dch1_vector_ext[3];
  assign rdataram_re_dch1_3_w      = rdataram_re_dch1_vector_ext[3];
  assign rdataram_raddr_dch1_3_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(3+1)-1:UMCTL2_RDATARAM_AW*3];
  assign rdataram_waddr_dch1_3_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(3+1)-1:UMCTL2_RDATARAM_AW*3];
  assign rdataram_din_par_dch1_3_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(3+1)-1:UMCTL2_DATARAM_PAR_DW*3];

  assign raqb_pop_3_w              = raqb_pop_vector_ext[3];
  assign raqb_push_3_w             = raqb_push_vector_ext[3];
  assign raqr_pop_3_w              = raqr_pop_vector_ext[3];
  assign raqr_push_3_w             = raqr_push_vector_ext[3];
  assign raq_split_3_w             = raq_split_vector_ext[3];

  assign waq_pop_3_w               = waq_pop_vector_ext[3];
  assign waq_push_3_w              = waq_push_vector_ext[3];
  assign waq_split_3_w             = waq_split_vector_ext[3];

  assign csysack_xpi_4_w = csysack_xpi_vector_ext[4];
  assign awready_4_w     = awready_vector_ext[4];
  assign wready_4_w      = wready_vector_ext[4];
  assign bid_4_w         = bid_vector_ext[AXI_IDW*(4+1)-1:AXI_IDW*4];
  assign bresp_4_w       = bresp_vector_ext[AXI_RESPW*(4+1)-1:AXI_RESPW*4];
  assign buser_4_w       = buser_vector_ext[AXI_USERW*(4+1)-1:AXI_USERW*4];
  assign bvalid_4_w      = bvalid_vector_ext[4];
  assign arready_4_w     = arready_vector_ext[4];
  assign rid_4_w         = rid_vector_ext[AXI_IDW*(4+1)-1:AXI_IDW*4];
  assign rdata_4_w       = {(`UMCTL2_PORT_DW_4){1'b0}};
  assign rparity_4_w     = {(`UMCTL2_PORT_NBYTES_4){1'b0}};
  assign ruser_4_w       = ruser_vector_ext[AXI_USERW*(4+1)-1:AXI_USERW*4];
  assign rresp_4_w       = rresp_vector_ext[AXI_RESPW*(4+1)-1:AXI_RESPW*4];
  assign rlast_4_w       = rlast_vector_ext[4];
  assign rvalid_4_w      = rvalid_vector_ext[4];

  assign rdataram_din_4_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(4+1)-1:UMCTL2_RDATARAM_DW*4];
  assign rdataram_wr_4_w           = rdataram_wr_vector_ext[4];
  assign rdataram_re_4_w           = rdataram_re_vector_ext[4];
  assign rdataram_raddr_4_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(4+1)-1:UMCTL2_RDATARAM_AW*4];
  assign rdataram_waddr_4_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(4+1)-1:UMCTL2_RDATARAM_AW*4];
  assign rdataram_din_par_4_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(4+1)-1:UMCTL2_DATARAM_PAR_DW*4];

  assign rdataram_din_dch1_4_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(4+1)-1:UMCTL2_RDATARAM_DW*4];
  assign rdataram_wr_dch1_4_w      = rdataram_wr_dch1_vector_ext[4];
  assign rdataram_re_dch1_4_w      = rdataram_re_dch1_vector_ext[4];
  assign rdataram_raddr_dch1_4_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(4+1)-1:UMCTL2_RDATARAM_AW*4];
  assign rdataram_waddr_dch1_4_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(4+1)-1:UMCTL2_RDATARAM_AW*4];
  assign rdataram_din_par_dch1_4_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(4+1)-1:UMCTL2_DATARAM_PAR_DW*4];

  assign raqb_pop_4_w              = raqb_pop_vector_ext[4];
  assign raqb_push_4_w             = raqb_push_vector_ext[4];
  assign raqr_pop_4_w              = raqr_pop_vector_ext[4];
  assign raqr_push_4_w             = raqr_push_vector_ext[4];
  assign raq_split_4_w             = raq_split_vector_ext[4];

  assign waq_pop_4_w               = waq_pop_vector_ext[4];
  assign waq_push_4_w              = waq_push_vector_ext[4];
  assign waq_split_4_w             = waq_split_vector_ext[4];

  assign csysack_xpi_5_w = csysack_xpi_vector_ext[5];
  assign awready_5_w     = awready_vector_ext[5];
  assign wready_5_w      = wready_vector_ext[5];
  assign bid_5_w         = bid_vector_ext[AXI_IDW*(5+1)-1:AXI_IDW*5];
  assign bresp_5_w       = bresp_vector_ext[AXI_RESPW*(5+1)-1:AXI_RESPW*5];
  assign buser_5_w       = buser_vector_ext[AXI_USERW*(5+1)-1:AXI_USERW*5];
  assign bvalid_5_w      = bvalid_vector_ext[5];
  assign arready_5_w     = arready_vector_ext[5];
  assign rid_5_w         = rid_vector_ext[AXI_IDW*(5+1)-1:AXI_IDW*5];
  assign rdata_5_w       = {(`UMCTL2_PORT_DW_5){1'b0}};
  assign rparity_5_w     = {(`UMCTL2_PORT_NBYTES_5){1'b0}};
  assign ruser_5_w       = ruser_vector_ext[AXI_USERW*(5+1)-1:AXI_USERW*5];
  assign rresp_5_w       = rresp_vector_ext[AXI_RESPW*(5+1)-1:AXI_RESPW*5];
  assign rlast_5_w       = rlast_vector_ext[5];
  assign rvalid_5_w      = rvalid_vector_ext[5];

  assign rdataram_din_5_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(5+1)-1:UMCTL2_RDATARAM_DW*5];
  assign rdataram_wr_5_w           = rdataram_wr_vector_ext[5];
  assign rdataram_re_5_w           = rdataram_re_vector_ext[5];
  assign rdataram_raddr_5_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(5+1)-1:UMCTL2_RDATARAM_AW*5];
  assign rdataram_waddr_5_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(5+1)-1:UMCTL2_RDATARAM_AW*5];
  assign rdataram_din_par_5_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(5+1)-1:UMCTL2_DATARAM_PAR_DW*5];

  assign rdataram_din_dch1_5_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(5+1)-1:UMCTL2_RDATARAM_DW*5];
  assign rdataram_wr_dch1_5_w      = rdataram_wr_dch1_vector_ext[5];
  assign rdataram_re_dch1_5_w      = rdataram_re_dch1_vector_ext[5];
  assign rdataram_raddr_dch1_5_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(5+1)-1:UMCTL2_RDATARAM_AW*5];
  assign rdataram_waddr_dch1_5_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(5+1)-1:UMCTL2_RDATARAM_AW*5];
  assign rdataram_din_par_dch1_5_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(5+1)-1:UMCTL2_DATARAM_PAR_DW*5];

  assign raqb_pop_5_w              = raqb_pop_vector_ext[5];
  assign raqb_push_5_w             = raqb_push_vector_ext[5];
  assign raqr_pop_5_w              = raqr_pop_vector_ext[5];
  assign raqr_push_5_w             = raqr_push_vector_ext[5];
  assign raq_split_5_w             = raq_split_vector_ext[5];

  assign waq_pop_5_w               = waq_pop_vector_ext[5];
  assign waq_push_5_w              = waq_push_vector_ext[5];
  assign waq_split_5_w             = waq_split_vector_ext[5];

  assign csysack_xpi_6_w = csysack_xpi_vector_ext[6];
  assign awready_6_w     = awready_vector_ext[6];
  assign wready_6_w      = wready_vector_ext[6];
  assign bid_6_w         = bid_vector_ext[AXI_IDW*(6+1)-1:AXI_IDW*6];
  assign bresp_6_w       = bresp_vector_ext[AXI_RESPW*(6+1)-1:AXI_RESPW*6];
  assign buser_6_w       = buser_vector_ext[AXI_USERW*(6+1)-1:AXI_USERW*6];
  assign bvalid_6_w      = bvalid_vector_ext[6];
  assign arready_6_w     = arready_vector_ext[6];
  assign rid_6_w         = rid_vector_ext[AXI_IDW*(6+1)-1:AXI_IDW*6];
  assign rdata_6_w       = {(`UMCTL2_PORT_DW_6){1'b0}};
  assign rparity_6_w     = {(`UMCTL2_PORT_NBYTES_6){1'b0}};
  assign ruser_6_w       = ruser_vector_ext[AXI_USERW*(6+1)-1:AXI_USERW*6];
  assign rresp_6_w       = rresp_vector_ext[AXI_RESPW*(6+1)-1:AXI_RESPW*6];
  assign rlast_6_w       = rlast_vector_ext[6];
  assign rvalid_6_w      = rvalid_vector_ext[6];

  assign rdataram_din_6_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(6+1)-1:UMCTL2_RDATARAM_DW*6];
  assign rdataram_wr_6_w           = rdataram_wr_vector_ext[6];
  assign rdataram_re_6_w           = rdataram_re_vector_ext[6];
  assign rdataram_raddr_6_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(6+1)-1:UMCTL2_RDATARAM_AW*6];
  assign rdataram_waddr_6_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(6+1)-1:UMCTL2_RDATARAM_AW*6];
  assign rdataram_din_par_6_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(6+1)-1:UMCTL2_DATARAM_PAR_DW*6];

  assign rdataram_din_dch1_6_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(6+1)-1:UMCTL2_RDATARAM_DW*6];
  assign rdataram_wr_dch1_6_w      = rdataram_wr_dch1_vector_ext[6];
  assign rdataram_re_dch1_6_w      = rdataram_re_dch1_vector_ext[6];
  assign rdataram_raddr_dch1_6_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(6+1)-1:UMCTL2_RDATARAM_AW*6];
  assign rdataram_waddr_dch1_6_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(6+1)-1:UMCTL2_RDATARAM_AW*6];
  assign rdataram_din_par_dch1_6_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(6+1)-1:UMCTL2_DATARAM_PAR_DW*6];

  assign raqb_pop_6_w              = raqb_pop_vector_ext[6];
  assign raqb_push_6_w             = raqb_push_vector_ext[6];
  assign raqr_pop_6_w              = raqr_pop_vector_ext[6];
  assign raqr_push_6_w             = raqr_push_vector_ext[6];
  assign raq_split_6_w             = raq_split_vector_ext[6];

  assign waq_pop_6_w               = waq_pop_vector_ext[6];
  assign waq_push_6_w              = waq_push_vector_ext[6];
  assign waq_split_6_w             = waq_split_vector_ext[6];

  assign csysack_xpi_7_w = csysack_xpi_vector_ext[7];
  assign awready_7_w     = awready_vector_ext[7];
  assign wready_7_w      = wready_vector_ext[7];
  assign bid_7_w         = bid_vector_ext[AXI_IDW*(7+1)-1:AXI_IDW*7];
  assign bresp_7_w       = bresp_vector_ext[AXI_RESPW*(7+1)-1:AXI_RESPW*7];
  assign buser_7_w       = buser_vector_ext[AXI_USERW*(7+1)-1:AXI_USERW*7];
  assign bvalid_7_w      = bvalid_vector_ext[7];
  assign arready_7_w     = arready_vector_ext[7];
  assign rid_7_w         = rid_vector_ext[AXI_IDW*(7+1)-1:AXI_IDW*7];
  assign rdata_7_w       = {(`UMCTL2_PORT_DW_7){1'b0}};
  assign rparity_7_w     = {(`UMCTL2_PORT_NBYTES_7){1'b0}};
  assign ruser_7_w       = ruser_vector_ext[AXI_USERW*(7+1)-1:AXI_USERW*7];
  assign rresp_7_w       = rresp_vector_ext[AXI_RESPW*(7+1)-1:AXI_RESPW*7];
  assign rlast_7_w       = rlast_vector_ext[7];
  assign rvalid_7_w      = rvalid_vector_ext[7];

  assign rdataram_din_7_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(7+1)-1:UMCTL2_RDATARAM_DW*7];
  assign rdataram_wr_7_w           = rdataram_wr_vector_ext[7];
  assign rdataram_re_7_w           = rdataram_re_vector_ext[7];
  assign rdataram_raddr_7_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(7+1)-1:UMCTL2_RDATARAM_AW*7];
  assign rdataram_waddr_7_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(7+1)-1:UMCTL2_RDATARAM_AW*7];
  assign rdataram_din_par_7_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(7+1)-1:UMCTL2_DATARAM_PAR_DW*7];

  assign rdataram_din_dch1_7_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(7+1)-1:UMCTL2_RDATARAM_DW*7];
  assign rdataram_wr_dch1_7_w      = rdataram_wr_dch1_vector_ext[7];
  assign rdataram_re_dch1_7_w      = rdataram_re_dch1_vector_ext[7];
  assign rdataram_raddr_dch1_7_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(7+1)-1:UMCTL2_RDATARAM_AW*7];
  assign rdataram_waddr_dch1_7_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(7+1)-1:UMCTL2_RDATARAM_AW*7];
  assign rdataram_din_par_dch1_7_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(7+1)-1:UMCTL2_DATARAM_PAR_DW*7];

  assign raqb_pop_7_w              = raqb_pop_vector_ext[7];
  assign raqb_push_7_w             = raqb_push_vector_ext[7];
  assign raqr_pop_7_w              = raqr_pop_vector_ext[7];
  assign raqr_push_7_w             = raqr_push_vector_ext[7];
  assign raq_split_7_w             = raq_split_vector_ext[7];

  assign waq_pop_7_w               = waq_pop_vector_ext[7];
  assign waq_push_7_w              = waq_push_vector_ext[7];
  assign waq_split_7_w             = waq_split_vector_ext[7];

  assign csysack_xpi_8_w = csysack_xpi_vector_ext[8];
  assign awready_8_w     = awready_vector_ext[8];
  assign wready_8_w      = wready_vector_ext[8];
  assign bid_8_w         = bid_vector_ext[AXI_IDW*(8+1)-1:AXI_IDW*8];
  assign bresp_8_w       = bresp_vector_ext[AXI_RESPW*(8+1)-1:AXI_RESPW*8];
  assign buser_8_w       = buser_vector_ext[AXI_USERW*(8+1)-1:AXI_USERW*8];
  assign bvalid_8_w      = bvalid_vector_ext[8];
  assign arready_8_w     = arready_vector_ext[8];
  assign rid_8_w         = rid_vector_ext[AXI_IDW*(8+1)-1:AXI_IDW*8];
  assign rdata_8_w       = {(`UMCTL2_PORT_DW_8){1'b0}};
  assign rparity_8_w     = {(`UMCTL2_PORT_NBYTES_8){1'b0}};
  assign ruser_8_w       = ruser_vector_ext[AXI_USERW*(8+1)-1:AXI_USERW*8];
  assign rresp_8_w       = rresp_vector_ext[AXI_RESPW*(8+1)-1:AXI_RESPW*8];
  assign rlast_8_w       = rlast_vector_ext[8];
  assign rvalid_8_w      = rvalid_vector_ext[8];

  assign rdataram_din_8_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(8+1)-1:UMCTL2_RDATARAM_DW*8];
  assign rdataram_wr_8_w           = rdataram_wr_vector_ext[8];
  assign rdataram_re_8_w           = rdataram_re_vector_ext[8];
  assign rdataram_raddr_8_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(8+1)-1:UMCTL2_RDATARAM_AW*8];
  assign rdataram_waddr_8_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(8+1)-1:UMCTL2_RDATARAM_AW*8];
  assign rdataram_din_par_8_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(8+1)-1:UMCTL2_DATARAM_PAR_DW*8];

  assign rdataram_din_dch1_8_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(8+1)-1:UMCTL2_RDATARAM_DW*8];
  assign rdataram_wr_dch1_8_w      = rdataram_wr_dch1_vector_ext[8];
  assign rdataram_re_dch1_8_w      = rdataram_re_dch1_vector_ext[8];
  assign rdataram_raddr_dch1_8_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(8+1)-1:UMCTL2_RDATARAM_AW*8];
  assign rdataram_waddr_dch1_8_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(8+1)-1:UMCTL2_RDATARAM_AW*8];
  assign rdataram_din_par_dch1_8_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(8+1)-1:UMCTL2_DATARAM_PAR_DW*8];

  assign raqb_pop_8_w              = raqb_pop_vector_ext[8];
  assign raqb_push_8_w             = raqb_push_vector_ext[8];
  assign raqr_pop_8_w              = raqr_pop_vector_ext[8];
  assign raqr_push_8_w             = raqr_push_vector_ext[8];
  assign raq_split_8_w             = raq_split_vector_ext[8];

  assign waq_pop_8_w               = waq_pop_vector_ext[8];
  assign waq_push_8_w              = waq_push_vector_ext[8];
  assign waq_split_8_w             = waq_split_vector_ext[8];

  assign csysack_xpi_9_w = csysack_xpi_vector_ext[9];
  assign awready_9_w     = awready_vector_ext[9];
  assign wready_9_w      = wready_vector_ext[9];
  assign bid_9_w         = bid_vector_ext[AXI_IDW*(9+1)-1:AXI_IDW*9];
  assign bresp_9_w       = bresp_vector_ext[AXI_RESPW*(9+1)-1:AXI_RESPW*9];
  assign buser_9_w       = buser_vector_ext[AXI_USERW*(9+1)-1:AXI_USERW*9];
  assign bvalid_9_w      = bvalid_vector_ext[9];
  assign arready_9_w     = arready_vector_ext[9];
  assign rid_9_w         = rid_vector_ext[AXI_IDW*(9+1)-1:AXI_IDW*9];
  assign rdata_9_w       = {(`UMCTL2_PORT_DW_9){1'b0}};
  assign rparity_9_w     = {(`UMCTL2_PORT_NBYTES_9){1'b0}};
  assign ruser_9_w       = ruser_vector_ext[AXI_USERW*(9+1)-1:AXI_USERW*9];
  assign rresp_9_w       = rresp_vector_ext[AXI_RESPW*(9+1)-1:AXI_RESPW*9];
  assign rlast_9_w       = rlast_vector_ext[9];
  assign rvalid_9_w      = rvalid_vector_ext[9];

  assign rdataram_din_9_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(9+1)-1:UMCTL2_RDATARAM_DW*9];
  assign rdataram_wr_9_w           = rdataram_wr_vector_ext[9];
  assign rdataram_re_9_w           = rdataram_re_vector_ext[9];
  assign rdataram_raddr_9_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(9+1)-1:UMCTL2_RDATARAM_AW*9];
  assign rdataram_waddr_9_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(9+1)-1:UMCTL2_RDATARAM_AW*9];
  assign rdataram_din_par_9_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(9+1)-1:UMCTL2_DATARAM_PAR_DW*9];

  assign rdataram_din_dch1_9_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(9+1)-1:UMCTL2_RDATARAM_DW*9];
  assign rdataram_wr_dch1_9_w      = rdataram_wr_dch1_vector_ext[9];
  assign rdataram_re_dch1_9_w      = rdataram_re_dch1_vector_ext[9];
  assign rdataram_raddr_dch1_9_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(9+1)-1:UMCTL2_RDATARAM_AW*9];
  assign rdataram_waddr_dch1_9_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(9+1)-1:UMCTL2_RDATARAM_AW*9];
  assign rdataram_din_par_dch1_9_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(9+1)-1:UMCTL2_DATARAM_PAR_DW*9];

  assign raqb_pop_9_w              = raqb_pop_vector_ext[9];
  assign raqb_push_9_w             = raqb_push_vector_ext[9];
  assign raqr_pop_9_w              = raqr_pop_vector_ext[9];
  assign raqr_push_9_w             = raqr_push_vector_ext[9];
  assign raq_split_9_w             = raq_split_vector_ext[9];

  assign waq_pop_9_w               = waq_pop_vector_ext[9];
  assign waq_push_9_w              = waq_push_vector_ext[9];
  assign waq_split_9_w             = waq_split_vector_ext[9];

  assign csysack_xpi_10_w = csysack_xpi_vector_ext[10];
  assign awready_10_w     = awready_vector_ext[10];
  assign wready_10_w      = wready_vector_ext[10];
  assign bid_10_w         = bid_vector_ext[AXI_IDW*(10+1)-1:AXI_IDW*10];
  assign bresp_10_w       = bresp_vector_ext[AXI_RESPW*(10+1)-1:AXI_RESPW*10];
  assign buser_10_w       = buser_vector_ext[AXI_USERW*(10+1)-1:AXI_USERW*10];
  assign bvalid_10_w      = bvalid_vector_ext[10];
  assign arready_10_w     = arready_vector_ext[10];
  assign rid_10_w         = rid_vector_ext[AXI_IDW*(10+1)-1:AXI_IDW*10];
  assign rdata_10_w       = {(`UMCTL2_PORT_DW_10){1'b0}};
  assign rparity_10_w     = {(`UMCTL2_PORT_NBYTES_10){1'b0}};
  assign ruser_10_w       = ruser_vector_ext[AXI_USERW*(10+1)-1:AXI_USERW*10];
  assign rresp_10_w       = rresp_vector_ext[AXI_RESPW*(10+1)-1:AXI_RESPW*10];
  assign rlast_10_w       = rlast_vector_ext[10];
  assign rvalid_10_w      = rvalid_vector_ext[10];

  assign rdataram_din_10_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(10+1)-1:UMCTL2_RDATARAM_DW*10];
  assign rdataram_wr_10_w           = rdataram_wr_vector_ext[10];
  assign rdataram_re_10_w           = rdataram_re_vector_ext[10];
  assign rdataram_raddr_10_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(10+1)-1:UMCTL2_RDATARAM_AW*10];
  assign rdataram_waddr_10_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(10+1)-1:UMCTL2_RDATARAM_AW*10];
  assign rdataram_din_par_10_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(10+1)-1:UMCTL2_DATARAM_PAR_DW*10];

  assign rdataram_din_dch1_10_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(10+1)-1:UMCTL2_RDATARAM_DW*10];
  assign rdataram_wr_dch1_10_w      = rdataram_wr_dch1_vector_ext[10];
  assign rdataram_re_dch1_10_w      = rdataram_re_dch1_vector_ext[10];
  assign rdataram_raddr_dch1_10_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(10+1)-1:UMCTL2_RDATARAM_AW*10];
  assign rdataram_waddr_dch1_10_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(10+1)-1:UMCTL2_RDATARAM_AW*10];
  assign rdataram_din_par_dch1_10_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(10+1)-1:UMCTL2_DATARAM_PAR_DW*10];

  assign raqb_pop_10_w              = raqb_pop_vector_ext[10];
  assign raqb_push_10_w             = raqb_push_vector_ext[10];
  assign raqr_pop_10_w              = raqr_pop_vector_ext[10];
  assign raqr_push_10_w             = raqr_push_vector_ext[10];
  assign raq_split_10_w             = raq_split_vector_ext[10];

  assign waq_pop_10_w               = waq_pop_vector_ext[10];
  assign waq_push_10_w              = waq_push_vector_ext[10];
  assign waq_split_10_w             = waq_split_vector_ext[10];

  assign csysack_xpi_11_w = csysack_xpi_vector_ext[11];
  assign awready_11_w     = awready_vector_ext[11];
  assign wready_11_w      = wready_vector_ext[11];
  assign bid_11_w         = bid_vector_ext[AXI_IDW*(11+1)-1:AXI_IDW*11];
  assign bresp_11_w       = bresp_vector_ext[AXI_RESPW*(11+1)-1:AXI_RESPW*11];
  assign buser_11_w       = buser_vector_ext[AXI_USERW*(11+1)-1:AXI_USERW*11];
  assign bvalid_11_w      = bvalid_vector_ext[11];
  assign arready_11_w     = arready_vector_ext[11];
  assign rid_11_w         = rid_vector_ext[AXI_IDW*(11+1)-1:AXI_IDW*11];
  assign rdata_11_w       = {(`UMCTL2_PORT_DW_11){1'b0}};
  assign rparity_11_w     = {(`UMCTL2_PORT_NBYTES_11){1'b0}};
  assign ruser_11_w       = ruser_vector_ext[AXI_USERW*(11+1)-1:AXI_USERW*11];
  assign rresp_11_w       = rresp_vector_ext[AXI_RESPW*(11+1)-1:AXI_RESPW*11];
  assign rlast_11_w       = rlast_vector_ext[11];
  assign rvalid_11_w      = rvalid_vector_ext[11];

  assign rdataram_din_11_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(11+1)-1:UMCTL2_RDATARAM_DW*11];
  assign rdataram_wr_11_w           = rdataram_wr_vector_ext[11];
  assign rdataram_re_11_w           = rdataram_re_vector_ext[11];
  assign rdataram_raddr_11_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(11+1)-1:UMCTL2_RDATARAM_AW*11];
  assign rdataram_waddr_11_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(11+1)-1:UMCTL2_RDATARAM_AW*11];
  assign rdataram_din_par_11_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(11+1)-1:UMCTL2_DATARAM_PAR_DW*11];

  assign rdataram_din_dch1_11_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(11+1)-1:UMCTL2_RDATARAM_DW*11];
  assign rdataram_wr_dch1_11_w      = rdataram_wr_dch1_vector_ext[11];
  assign rdataram_re_dch1_11_w      = rdataram_re_dch1_vector_ext[11];
  assign rdataram_raddr_dch1_11_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(11+1)-1:UMCTL2_RDATARAM_AW*11];
  assign rdataram_waddr_dch1_11_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(11+1)-1:UMCTL2_RDATARAM_AW*11];
  assign rdataram_din_par_dch1_11_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(11+1)-1:UMCTL2_DATARAM_PAR_DW*11];

  assign raqb_pop_11_w              = raqb_pop_vector_ext[11];
  assign raqb_push_11_w             = raqb_push_vector_ext[11];
  assign raqr_pop_11_w              = raqr_pop_vector_ext[11];
  assign raqr_push_11_w             = raqr_push_vector_ext[11];
  assign raq_split_11_w             = raq_split_vector_ext[11];

  assign waq_pop_11_w               = waq_pop_vector_ext[11];
  assign waq_push_11_w              = waq_push_vector_ext[11];
  assign waq_split_11_w             = waq_split_vector_ext[11];

  assign csysack_xpi_12_w = csysack_xpi_vector_ext[12];
  assign awready_12_w     = awready_vector_ext[12];
  assign wready_12_w      = wready_vector_ext[12];
  assign bid_12_w         = bid_vector_ext[AXI_IDW*(12+1)-1:AXI_IDW*12];
  assign bresp_12_w       = bresp_vector_ext[AXI_RESPW*(12+1)-1:AXI_RESPW*12];
  assign buser_12_w       = buser_vector_ext[AXI_USERW*(12+1)-1:AXI_USERW*12];
  assign bvalid_12_w      = bvalid_vector_ext[12];
  assign arready_12_w     = arready_vector_ext[12];
  assign rid_12_w         = rid_vector_ext[AXI_IDW*(12+1)-1:AXI_IDW*12];
  assign rdata_12_w       = {(`UMCTL2_PORT_DW_12){1'b0}};
  assign rparity_12_w     = {(`UMCTL2_PORT_NBYTES_12){1'b0}};
  assign ruser_12_w       = ruser_vector_ext[AXI_USERW*(12+1)-1:AXI_USERW*12];
  assign rresp_12_w       = rresp_vector_ext[AXI_RESPW*(12+1)-1:AXI_RESPW*12];
  assign rlast_12_w       = rlast_vector_ext[12];
  assign rvalid_12_w      = rvalid_vector_ext[12];

  assign rdataram_din_12_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(12+1)-1:UMCTL2_RDATARAM_DW*12];
  assign rdataram_wr_12_w           = rdataram_wr_vector_ext[12];
  assign rdataram_re_12_w           = rdataram_re_vector_ext[12];
  assign rdataram_raddr_12_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(12+1)-1:UMCTL2_RDATARAM_AW*12];
  assign rdataram_waddr_12_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(12+1)-1:UMCTL2_RDATARAM_AW*12];
  assign rdataram_din_par_12_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(12+1)-1:UMCTL2_DATARAM_PAR_DW*12];

  assign rdataram_din_dch1_12_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(12+1)-1:UMCTL2_RDATARAM_DW*12];
  assign rdataram_wr_dch1_12_w      = rdataram_wr_dch1_vector_ext[12];
  assign rdataram_re_dch1_12_w      = rdataram_re_dch1_vector_ext[12];
  assign rdataram_raddr_dch1_12_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(12+1)-1:UMCTL2_RDATARAM_AW*12];
  assign rdataram_waddr_dch1_12_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(12+1)-1:UMCTL2_RDATARAM_AW*12];
  assign rdataram_din_par_dch1_12_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(12+1)-1:UMCTL2_DATARAM_PAR_DW*12];

  assign raqb_pop_12_w              = raqb_pop_vector_ext[12];
  assign raqb_push_12_w             = raqb_push_vector_ext[12];
  assign raqr_pop_12_w              = raqr_pop_vector_ext[12];
  assign raqr_push_12_w             = raqr_push_vector_ext[12];
  assign raq_split_12_w             = raq_split_vector_ext[12];

  assign waq_pop_12_w               = waq_pop_vector_ext[12];
  assign waq_push_12_w              = waq_push_vector_ext[12];
  assign waq_split_12_w             = waq_split_vector_ext[12];

  assign csysack_xpi_13_w = csysack_xpi_vector_ext[13];
  assign awready_13_w     = awready_vector_ext[13];
  assign wready_13_w      = wready_vector_ext[13];
  assign bid_13_w         = bid_vector_ext[AXI_IDW*(13+1)-1:AXI_IDW*13];
  assign bresp_13_w       = bresp_vector_ext[AXI_RESPW*(13+1)-1:AXI_RESPW*13];
  assign buser_13_w       = buser_vector_ext[AXI_USERW*(13+1)-1:AXI_USERW*13];
  assign bvalid_13_w      = bvalid_vector_ext[13];
  assign arready_13_w     = arready_vector_ext[13];
  assign rid_13_w         = rid_vector_ext[AXI_IDW*(13+1)-1:AXI_IDW*13];
  assign rdata_13_w       = {(`UMCTL2_PORT_DW_13){1'b0}};
  assign rparity_13_w     = {(`UMCTL2_PORT_NBYTES_13){1'b0}};
  assign ruser_13_w       = ruser_vector_ext[AXI_USERW*(13+1)-1:AXI_USERW*13];
  assign rresp_13_w       = rresp_vector_ext[AXI_RESPW*(13+1)-1:AXI_RESPW*13];
  assign rlast_13_w       = rlast_vector_ext[13];
  assign rvalid_13_w      = rvalid_vector_ext[13];

  assign rdataram_din_13_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(13+1)-1:UMCTL2_RDATARAM_DW*13];
  assign rdataram_wr_13_w           = rdataram_wr_vector_ext[13];
  assign rdataram_re_13_w           = rdataram_re_vector_ext[13];
  assign rdataram_raddr_13_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(13+1)-1:UMCTL2_RDATARAM_AW*13];
  assign rdataram_waddr_13_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(13+1)-1:UMCTL2_RDATARAM_AW*13];
  assign rdataram_din_par_13_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(13+1)-1:UMCTL2_DATARAM_PAR_DW*13];

  assign rdataram_din_dch1_13_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(13+1)-1:UMCTL2_RDATARAM_DW*13];
  assign rdataram_wr_dch1_13_w      = rdataram_wr_dch1_vector_ext[13];
  assign rdataram_re_dch1_13_w      = rdataram_re_dch1_vector_ext[13];
  assign rdataram_raddr_dch1_13_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(13+1)-1:UMCTL2_RDATARAM_AW*13];
  assign rdataram_waddr_dch1_13_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(13+1)-1:UMCTL2_RDATARAM_AW*13];
  assign rdataram_din_par_dch1_13_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(13+1)-1:UMCTL2_DATARAM_PAR_DW*13];

  assign raqb_pop_13_w              = raqb_pop_vector_ext[13];
  assign raqb_push_13_w             = raqb_push_vector_ext[13];
  assign raqr_pop_13_w              = raqr_pop_vector_ext[13];
  assign raqr_push_13_w             = raqr_push_vector_ext[13];
  assign raq_split_13_w             = raq_split_vector_ext[13];

  assign waq_pop_13_w               = waq_pop_vector_ext[13];
  assign waq_push_13_w              = waq_push_vector_ext[13];
  assign waq_split_13_w             = waq_split_vector_ext[13];

  assign csysack_xpi_14_w = csysack_xpi_vector_ext[14];
  assign awready_14_w     = awready_vector_ext[14];
  assign wready_14_w      = wready_vector_ext[14];
  assign bid_14_w         = bid_vector_ext[AXI_IDW*(14+1)-1:AXI_IDW*14];
  assign bresp_14_w       = bresp_vector_ext[AXI_RESPW*(14+1)-1:AXI_RESPW*14];
  assign buser_14_w       = buser_vector_ext[AXI_USERW*(14+1)-1:AXI_USERW*14];
  assign bvalid_14_w      = bvalid_vector_ext[14];
  assign arready_14_w     = arready_vector_ext[14];
  assign rid_14_w         = rid_vector_ext[AXI_IDW*(14+1)-1:AXI_IDW*14];
  assign rdata_14_w       = {(`UMCTL2_PORT_DW_14){1'b0}};
  assign rparity_14_w     = {(`UMCTL2_PORT_NBYTES_14){1'b0}};
  assign ruser_14_w       = ruser_vector_ext[AXI_USERW*(14+1)-1:AXI_USERW*14];
  assign rresp_14_w       = rresp_vector_ext[AXI_RESPW*(14+1)-1:AXI_RESPW*14];
  assign rlast_14_w       = rlast_vector_ext[14];
  assign rvalid_14_w      = rvalid_vector_ext[14];

  assign rdataram_din_14_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(14+1)-1:UMCTL2_RDATARAM_DW*14];
  assign rdataram_wr_14_w           = rdataram_wr_vector_ext[14];
  assign rdataram_re_14_w           = rdataram_re_vector_ext[14];
  assign rdataram_raddr_14_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(14+1)-1:UMCTL2_RDATARAM_AW*14];
  assign rdataram_waddr_14_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(14+1)-1:UMCTL2_RDATARAM_AW*14];
  assign rdataram_din_par_14_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(14+1)-1:UMCTL2_DATARAM_PAR_DW*14];

  assign rdataram_din_dch1_14_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(14+1)-1:UMCTL2_RDATARAM_DW*14];
  assign rdataram_wr_dch1_14_w      = rdataram_wr_dch1_vector_ext[14];
  assign rdataram_re_dch1_14_w      = rdataram_re_dch1_vector_ext[14];
  assign rdataram_raddr_dch1_14_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(14+1)-1:UMCTL2_RDATARAM_AW*14];
  assign rdataram_waddr_dch1_14_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(14+1)-1:UMCTL2_RDATARAM_AW*14];
  assign rdataram_din_par_dch1_14_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(14+1)-1:UMCTL2_DATARAM_PAR_DW*14];

  assign raqb_pop_14_w              = raqb_pop_vector_ext[14];
  assign raqb_push_14_w             = raqb_push_vector_ext[14];
  assign raqr_pop_14_w              = raqr_pop_vector_ext[14];
  assign raqr_push_14_w             = raqr_push_vector_ext[14];
  assign raq_split_14_w             = raq_split_vector_ext[14];

  assign waq_pop_14_w               = waq_pop_vector_ext[14];
  assign waq_push_14_w              = waq_push_vector_ext[14];
  assign waq_split_14_w             = waq_split_vector_ext[14];

  assign csysack_xpi_15_w = csysack_xpi_vector_ext[15];
  assign awready_15_w     = awready_vector_ext[15];
  assign wready_15_w      = wready_vector_ext[15];
  assign bid_15_w         = bid_vector_ext[AXI_IDW*(15+1)-1:AXI_IDW*15];
  assign bresp_15_w       = bresp_vector_ext[AXI_RESPW*(15+1)-1:AXI_RESPW*15];
  assign buser_15_w       = buser_vector_ext[AXI_USERW*(15+1)-1:AXI_USERW*15];
  assign bvalid_15_w      = bvalid_vector_ext[15];
  assign arready_15_w     = arready_vector_ext[15];
  assign rid_15_w         = rid_vector_ext[AXI_IDW*(15+1)-1:AXI_IDW*15];
  assign rdata_15_w       = {(`UMCTL2_PORT_DW_15){1'b0}};
  assign rparity_15_w     = {(`UMCTL2_PORT_NBYTES_15){1'b0}};
  assign ruser_15_w       = ruser_vector_ext[AXI_USERW*(15+1)-1:AXI_USERW*15];
  assign rresp_15_w       = rresp_vector_ext[AXI_RESPW*(15+1)-1:AXI_RESPW*15];
  assign rlast_15_w       = rlast_vector_ext[15];
  assign rvalid_15_w      = rvalid_vector_ext[15];

  assign rdataram_din_15_w          = rdataram_din_vector_ext[UMCTL2_RDATARAM_DW*(15+1)-1:UMCTL2_RDATARAM_DW*15];
  assign rdataram_wr_15_w           = rdataram_wr_vector_ext[15];
  assign rdataram_re_15_w           = rdataram_re_vector_ext[15];
  assign rdataram_raddr_15_w        = rdataram_raddr_vector_ext[UMCTL2_RDATARAM_AW*(15+1)-1:UMCTL2_RDATARAM_AW*15];
  assign rdataram_waddr_15_w        = rdataram_waddr_vector_ext[UMCTL2_RDATARAM_AW*(15+1)-1:UMCTL2_RDATARAM_AW*15];
  assign rdataram_din_par_15_w      = rdataram_din_par_vector_ext[UMCTL2_DATARAM_PAR_DW*(15+1)-1:UMCTL2_DATARAM_PAR_DW*15];

  assign rdataram_din_dch1_15_w     = rdataram_din_dch1_vector_ext[UMCTL2_RDATARAM_DW*(15+1)-1:UMCTL2_RDATARAM_DW*15];
  assign rdataram_wr_dch1_15_w      = rdataram_wr_dch1_vector_ext[15];
  assign rdataram_re_dch1_15_w      = rdataram_re_dch1_vector_ext[15];
  assign rdataram_raddr_dch1_15_w   = rdataram_raddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(15+1)-1:UMCTL2_RDATARAM_AW*15];
  assign rdataram_waddr_dch1_15_w   = rdataram_waddr_dch1_vector_ext[UMCTL2_RDATARAM_AW*(15+1)-1:UMCTL2_RDATARAM_AW*15];
  assign rdataram_din_par_dch1_15_w = rdataram_din_par_dch1_vector_ext[UMCTL2_DATARAM_PAR_DW*(15+1)-1:UMCTL2_DATARAM_PAR_DW*15];

  assign raqb_pop_15_w              = raqb_pop_vector_ext[15];
  assign raqb_push_15_w             = raqb_push_vector_ext[15];
  assign raqr_pop_15_w              = raqr_pop_vector_ext[15];
  assign raqr_push_15_w             = raqr_push_vector_ext[15];
  assign raq_split_15_w             = raq_split_vector_ext[15];

  assign waq_pop_15_w               = waq_pop_vector_ext[15];
  assign waq_push_15_w              = waq_push_vector_ext[15];
  assign waq_split_15_w             = waq_split_vector_ext[15];
//spyglass enable_block SelfDeterminedExpr-ML

  //Zero Extension for Ununique Output Vectors
  generate
    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
       assign reg_arb_occap_arb_cmp_poison_seq_vector       = reg_arb_occap_arb_cmp_poison_seq;      //connect to real input
       assign reg_arb_occap_arb_cmp_poison_parallel_vector  = reg_arb_occap_arb_cmp_poison_parallel; //connect to real input
       assign reg_arb_occap_arb_cmp_poison_err_inj_vector   = reg_arb_occap_arb_cmp_poison_err_inj;  //connect to real input
       assign reg_arb_occap_arb_raq_poison_en_vector        = reg_arb_occap_arb_raq_poison_en;       //connect to real input
       assign oc_parity_en_aclk_vector                      = oc_parity_en_aclk;                     //connect to real input
       assign oc_parity_type_aclk_vector                    = oc_parity_type_aclk;                   //connect to real input
       assign par_addr_slverr_en_aclk_vector                = par_addr_slverr_en_aclk;               //connect to real input
       assign par_rdata_slverr_en_vector                    = par_rdata_slverr_en;                   //connect to real input
       assign rd_poison_en_vector                           = par_poison_en_rd_port;                 //connect to real input
       assign wr_poison_en_vector                           = par_poison_en_wr_port;                 //connect to real input
       assign par_wdata_err_intr_clr_vector                 = par_wdata_err_intr_clr_aclk;           //connect to real input
       assign par_rdata_err_intr_clr_vector                 = par_rdata_err_intr_clr_aclk;           //connect to real input
    end else if (A_NPORTS < 16) begin
       assign reg_arb_occap_arb_cmp_poison_seq_vector       = {{16-A_NPORTS{1'b0}}, reg_arb_occap_arb_cmp_poison_seq};      //connect to real input
       assign reg_arb_occap_arb_cmp_poison_parallel_vector  = {{16-A_NPORTS{1'b0}}, reg_arb_occap_arb_cmp_poison_parallel}; //connect to real input
       assign reg_arb_occap_arb_cmp_poison_err_inj_vector   = {{16-A_NPORTS{1'b0}}, reg_arb_occap_arb_cmp_poison_err_inj};  //connect to real input
       assign reg_arb_occap_arb_raq_poison_en_vector        = {{16-A_NPORTS{1'b0}}, reg_arb_occap_arb_raq_poison_en};       //connect to real input
       assign oc_parity_en_aclk_vector                      = {{16-A_NPORTS{1'b0}}, oc_parity_en_aclk};                     //connect to real input
       assign oc_parity_type_aclk_vector                    = {{16-A_NPORTS{1'b0}}, oc_parity_type_aclk};                   //connect to real input
       assign par_addr_slverr_en_aclk_vector                = {{16-A_NPORTS{1'b0}}, par_addr_slverr_en_aclk};               //connect to real input
       assign par_rdata_slverr_en_vector                    = {{16-A_NPORTS{1'b0}}, par_rdata_slverr_en};                   //connect to real input
       assign rd_poison_en_vector                           = {{16-A_NPORTS{1'b0}}, par_poison_en_rd_port};                 //connect to real input
       assign wr_poison_en_vector                           = {{16-A_NPORTS{1'b0}}, par_poison_en_wr_port};                 //connect to real input
       assign par_wdata_err_intr_clr_vector                 = {{16-A_NPORTS{1'b0}}, par_wdata_err_intr_clr_aclk};           //connect to real input
       assign par_rdata_err_intr_clr_vector                 = {{16-A_NPORTS{1'b0}}, par_rdata_err_intr_clr_aclk};           //connect to real input
    end

    if (A_NPORTS == 16) begin
      assign csysack_xpi_vector_ext = csysack_xpi_vector;
    end
    else if (A_NPORTS < 16) begin
      assign csysack_xpi_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, csysack_xpi_vector};
    end

     //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign awready_vector_ext = awready_vector;
    end
    else if (A_NPORTS < 16) begin
      assign awready_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, awready_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign wready_vector_ext = wready_vector;
    end
    else if (A_NPORTS < 16) begin
      assign wready_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, wready_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign bid_vector_ext = bid_vector;
    end
    else if (A_NPORTS < 16) begin
      assign bid_vector_ext = {{(AXI_IDW*(16-A_NPORTS)){1'b0}}, bid_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign bresp_vector_ext = bresp_vector;
    end
    else if (A_NPORTS < 16) begin
      assign bresp_vector_ext = {{(AXI_RESPW*(16-A_NPORTS)){1'b0}}, bresp_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign buser_vector_ext = buser_vector;
    end
    else if (A_NPORTS < 16) begin
      assign buser_vector_ext = {{(AXI_USERW*(16-A_NPORTS)){1'b0}}, buser_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign bvalid_vector_ext = bvalid_vector;
    end
    else if (A_NPORTS < 16) begin
      assign bvalid_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, bvalid_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign arready_vector_ext = arready_vector;
    end
    else if (A_NPORTS < 16) begin
      assign arready_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, arready_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rid_vector_ext = rid_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rid_vector_ext = {{(AXI_IDW*(16-A_NPORTS)){1'b0}}, rid_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rresp_vector_ext = rresp_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rresp_vector_ext = {{(AXI_RESPW*(16-A_NPORTS)){1'b0}}, rresp_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign ruser_vector_ext = ruser_vector;
    end
    else if (A_NPORTS < 16) begin
      assign ruser_vector_ext = {{(AXI_USERW*(16-A_NPORTS)){1'b0}}, ruser_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rlast_vector_ext = rlast_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rlast_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, rlast_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rvalid_vector_ext = rvalid_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rvalid_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, rvalid_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_din_vector_ext = rdataram_din_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_din_vector_ext = {{(UMCTL2_RDATARAM_DW*(16-A_NPORTS)){1'b0}}, rdataram_din_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_wr_vector_ext = rdataram_wr_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_wr_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, rdataram_wr_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_re_vector_ext = rdataram_re_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_re_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, rdataram_re_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_raddr_vector_ext = rdataram_raddr_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_raddr_vector_ext = {{(UMCTL2_RDATARAM_AW*(16-A_NPORTS)){1'b0}}, rdataram_raddr_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_waddr_vector_ext = rdataram_waddr_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_waddr_vector_ext = {{(UMCTL2_RDATARAM_AW*(16-A_NPORTS)){1'b0}}, rdataram_waddr_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_din_par_vector_ext = rdataram_din_par_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_din_par_vector_ext = {{(UMCTL2_DATARAM_PAR_DW*(16-A_NPORTS)){1'b0}}, rdataram_din_par_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_din_dch1_vector_ext = rdataram_din_dch1_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_din_dch1_vector_ext = {{(UMCTL2_RDATARAM_DW*(16-A_NPORTS)){1'b0}}, rdataram_din_dch1_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_wr_dch1_vector_ext = rdataram_wr_dch1_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_wr_dch1_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, rdataram_wr_dch1_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_re_dch1_vector_ext = rdataram_re_dch1_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_re_dch1_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, rdataram_re_dch1_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_raddr_dch1_vector_ext = rdataram_raddr_dch1_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_raddr_dch1_vector_ext = {{(UMCTL2_RDATARAM_AW*(16-A_NPORTS)){1'b0}}, rdataram_raddr_dch1_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_waddr_dch1_vector_ext = rdataram_waddr_dch1_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_waddr_dch1_vector_ext = {{(UMCTL2_RDATARAM_AW*(16-A_NPORTS)){1'b0}}, rdataram_waddr_dch1_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign rdataram_din_par_dch1_vector_ext = rdataram_din_par_dch1_vector;
    end
    else if (A_NPORTS < 16) begin
      assign rdataram_din_par_dch1_vector_ext = {{(UMCTL2_DATARAM_PAR_DW*(16-A_NPORTS)){1'b0}}, rdataram_din_par_dch1_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign raqb_pop_vector_ext = raqb_pop_vector;
    end
    else if (A_NPORTS < 16) begin
      assign raqb_pop_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, raqb_pop_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign raqb_push_vector_ext = raqb_push_vector;
    end
    else if (A_NPORTS < 16) begin
      assign raqb_push_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, raqb_push_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign raqr_pop_vector_ext = raqr_pop_vector;
    end
    else if (A_NPORTS < 16) begin
      assign raqr_pop_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, raqr_pop_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign raqr_push_vector_ext = raqr_push_vector;
    end
    else if (A_NPORTS < 16) begin
      assign raqr_push_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, raqr_push_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign raq_split_vector_ext = raq_split_vector;
    end
    else if (A_NPORTS < 16) begin
      assign raq_split_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, raq_split_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign waq_pop_vector_ext = waq_pop_vector;
    end
    else if (A_NPORTS < 16) begin
      assign waq_pop_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, waq_pop_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign waq_push_vector_ext = waq_push_vector;
    end
    else if (A_NPORTS < 16) begin
      assign waq_push_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, waq_push_vector};
    end

    //extend vector signal to 16 ports
    if (A_NPORTS == 16) begin
      assign waq_split_vector_ext = waq_split_vector;
    end
    else if (A_NPORTS < 16) begin
      assign waq_split_vector_ext = {{(1*(16-A_NPORTS)){1'b0}}, waq_split_vector};
    end

  endgenerate




// The removed registers in uMCTL5
wire [4:0] reg_ddrc_addrmap_row_b2_10_map0 = 5'hF;
wire [4:0] reg_ddrc_addrmap_col_b11_map0   = 5'h1F;
wire [3:0] reg_ddrc_addrmap_col_b2_map0    = 4'h0;
wire       reg_ddrc_lpddr3_6gb_12gb_map0   = 1'b0;
wire [1:0] reg_ddrc_lpddr45_6gb_12gb_24gb_map0  = 2'b00;
wire       reg_arb_bl_exp_mode_port0 = 1'b0;
  //-----------------------------------------------------------------------------------
  //         Instantiate arb_top
  //-----------------------------------------------------------------------------------

  DWC_ddr_arb_top
  
    #(
      // Parameters
      .M_DW                                (M_DW                               ),
      .M_DW_INT                            (M_DW_INT                           ),
      .A_DW                                (A_DW                               ),
      .A_STRBW                             (A_STRBW                            ),
      .A_PARW                              (A_PARW                             ), 
      .M_ADDRW                             (HIF_ADDR_WIDTH                     ),
      .NAB                                 (NAB                                ),
      .M_BLW                               (UMCTL2_M_BLW                       ),
      .M_ECC                               (MEMC_ECC_SUPPORT                   ),
      .M_SIDEBAND_ECC                      (MEMC_SIDEBAND_ECC                  ),
      .M_INLINE_ECC                        (MEMC_INLINE_ECC                    ),
      .NBEATS                              (WRDATA_CYCLES                      ),
      .M_LPDDR3                            (M_LPDDR3                           ),
      .M_DDR5                              (M_DDR5                             ),
      .M_USE_RMW                           (UMCTL2_XPI_USE_RMW                 ),
      .AXI_ADDRW                           (AXI_ADDRW                          ),
      .AXI_IDW                             (AXI_IDW                            ),
      .AXI_LENW                            (AXI_LENW                           ),
      .AXI_SIZEW                           (AXI_SIZEW                          ),
      .AXI_BURSTW                          (AXI_BURSTW                         ),
      .AXI_LOCKW_FIX                       (AXI_LOCKW_FIX                      ),
      .AXI_USERW                           (AXI_USERW                          ),
      .AXI_CACHEW                          (AXI_CACHEW                         ),
      .AXI_PROTW                           (AXI_PROTW                          ),
      .AXI_QOSW                            (AXI_QOSW                           ),
      .AXI_RESPW                           (AXI_RESPW                          ),
      .XPI_RMW_WDQD                        (XPI_RMW_WDQD                       ),
      .XPI_SQD                             (XPI_SQD                            ),
      .LOWPWR_NOPX_CNT                     (AXI_LOWPWR_NOPX_CNT                ),
      .OUTS_WRW                            (XPI_OUTS_WRW                       ),
      .OUTS_RDW                            (XPI_OUTS_RDW                       ),
      .MEMC_NO_OF_ENTRY                    (MEMC_NO_OF_ENTRY                   ),
      .MEMC_BURST_LENGTH                   (MEMC_BURST_LENGTH                  ),
      .MEMC_WDATA_PTR_BITS                 (MEMC_WDATA_PTR_BITS                ),
      .USE_WAR                             (XPI_USE_WAR                        ),
      .USE_RAR                             (XPI_USE_RAR                        ),
      .USE_RDR                             (XPI_USE_RDR                        ),
      .USE_RPR                             (XPI_USE_RPR                        ),
      .USE_INPUT_RAR                       (XPI_USE_INPUT_RAR                  ),
      .RMW_WARD                            (XPI_RMW_WARD                       ),
      .RARD                                (XPI_RARD                           ),
      .WARD                                (XPI_WARD                           ),
      .BRW                                 (BRW                                ),
      .DBW                                 (DBW                                ),
      .AMCOLW_H                            (AMCOLW_H                           ),
      .AMCOLW_L                            (AMCOLW_L                           ),
      .AMCOLW_C3                           (AMCOLW_C3                          ),
      .AMCSW                               (AMCSW                              ),
      .AMDCHW                              (AMDCHW                             ),
      .AMCIDW                              (AMCIDW                             ),
      .AMBANKW                             (AMBANKW                            ),
      .AMBGW                               (AMBGW                              ),
      .AMROWW                              (AMROWW                             ),
      .DDRCTL_LUT_ADDRMAP_EN               (DDRCTL_LUT_ADDRMAP_EN              ),      
      .UMCTL2_HET_RANK_EN                  (UMCTL2_HET_RANK_EN                 ),
      .OCPAR_EN                            (OCPAR_EN                           ),
      .OCPAR_SLICE_WIDTH                   (OCPAR_SLICE_WIDTH                  ),
      .OCPAR_NUM_BYTES                     (OCPAR_NUM_BYTES                    ),
      .OCPAR_NUM_BYTES_LG2                 (OCPAR_NUM_BYTES_LG2                ),
      .OCPAR_ADDR_PAR_WIDTH                (OCPAR_ADDR_PARITY_WIDTH_MIN        ),
      .DUAL_CHANNEL                        (DUAL_CHANNEL                       ),
      .DATA_CHANNEL_INTERLEAVE             (DATA_CHANNEL_INTERLEAVE            ),
      .ECC_RM_WIDTH                        (1                                  ),
      .ECC_RMG_WIDTH                       (1                                  ),
      .ECC_H3_WIDTH                        (ECC_H3_WIDTH                       ),
      .OCCAP_EN                            (OCCAP_EN                           ),
      .OCCAP_PIPELINE_EN                   (OCCAP_PIPELINE_EN                  ),
      //newly added      
      .OCECC_EN                            (OCECC_EN                 ),
      .OCECC_XPI_WR_IN_GRANU               (OCECC_XPI_WR_IN_GRANU    ),
      .OCECC_XPI_RD_GRANU                  (OCECC_XPI_RD_GRANU       ),
      .OCECC_MR_RD_GRANU                   (OCECC_MR_RD_GRANU        ),
      .OCECC_MR_BNUM_WIDTH                 (OCECC_MR_BNUM_WIDTH      ),      
      //
      .PA_OPT_TYPE                         (PA_OPT_TYPE                        ),
      .A_NPORTS_LG2                        (UMCTL2_A_NPORTS_LG2                ),
      .WDATA_PTR_QD                        (XPI_WDATA_PTR_QD                   ),
      .RQOS_MLW                            (XPI_RQOS_MLW                       ),
      .RQOS_RW                             (XPI_RQOS_RW                        ),
      .RQOS_TW                             (HIF_RQOS_TW                        ),
      .WQOS_MLW                            (XPI_WQOS_MLW                       ),
      .WQOS_RW                             (XPI_WQOS_RW                        ),
      .WQOS_TW                             (HIF_WQOS_TW                        ),
      .EXA_ACC_SUPPORT                     (EXA_ACC_SUPPORT                    ),
      .EXA_MAX_LENW                        (EXA_MAX_LENW                       ),
      .EXA_MAX_SIZEW                       (EXA_MAX_SIZEW                      ),
      .EXA_MAX_ADDRW                       (EXA_MAX_ADDRW                      ),
      .EXA_PYLD_W                          (EXA_PYLD_W                         ),
      .ID_MAPW                             (UMCTL2_A_ID_MAPW                   ),
      .CMD_LEN_BITS                        (UMCTL2_CMD_LEN_BITS                ),
      .BEAT_INFOW                          (XPI_RD_BEAT_INFOW                  ),
      .AXI_SAR_BW                          (AXI_SAR_BW                         ),
      .AXI_SAR_SW                          (AXI_SAR_SW                         ),
      .USE_SAR                             (USE_SAR                            ),
      .NSAR                                (NSAR                               ),
      .SAR_MIN_ADDRW                       (SAR_MIN_ADDRW                      ),
      .RDATARAM_DW                         (UMCTL2_RDATARAM_DW                 ),
      .RDATARAM_AW                         (UMCTL2_RDATARAM_AW                 ),
      .RDATARAM_DEPTH                      (UMCTL2_RDATARAM_DEPTH              ),
      .DATARAM_PAR_DW                      (UMCTL2_DATARAM_PAR_DW              ),
      .AXI_ADDR_BOUNDARY                   (AXI_ADDR_BOUNDARY                  ),
      .UMCTL2_PARTIAL_WR_EN                (UMCTL2_PARTIAL_WR_EN               ),
      .MEMC_DDR4_EN                        (MEMC_DDR4_EN                       ),
      .BCM_VERIF_EN                        (BCM_VERIF_EN                       ),
      .HWFFC_EN                            (HWFFC_EN                           ),
      .IH_TE_PIPELINE                      (IH_TE_PIPELINE                     ),
      .ARB_ID_NB                           (ARB_ID_NB                          ),    
      .ARB_ID_PRA_TABLE                    (ARB_ID_PRA_TABLE                   ),
      .ARB_TOTAL_ID                        (ARB_TOTAL_ID                       ),
      .ARB_ID_BUS_TABLE                    (ARB_ID_BUS_TABLE                   ),
      .A_PORT_NUM_TABLE                    (A_PORT_NUM_TABLE                   ),
      .MAX_A_PORT_NUM_NB                   (MAX_A_PORT_NUM_NB                  ),
      .A_DW_INT_TABLE                      (A_DW_INT_TABLE                     ),
      .MAX_A_DW_INT_NB                     (MAX_A_DW_INT_NB                    ),
      .A_STRBW_INT_TABLE                   (A_STRBW_INT_TABLE                  ),
      .MAX_A_STRBW_INT_NB                  (MAX_A_STRBW_INT_NB                 ),
      .A_PARW_INT_TABLE                    (A_PARW_INT_TABLE                   ), //new !!
      .MAX_A_PARW_INT_NB                   (MAX_A_PARW_INT_NB                  ), //new !!
      .AXI_DW_NB                           (AXI_DW_NB                          ),
      .AXI_DATAW_PRA_TABLE                 (AXI_DATAW_PRA_TABLE                ),
      .AXI_TOTAL_DW                        (AXI_TOTAL_DW                       ),
      .AXI_DATAW_BUS_TABLE                 (AXI_DATAW_BUS_TABLE                ),
      .AXI_STRBW_NB                        (AXI_STRBW_NB                       ),
      .AXI_STRBW_PRA_TABLE                 (AXI_STRBW_PRA_TABLE                ),
      .AXI_TOTAL_STRBW                     (AXI_TOTAL_STRBW                    ),
      .AXI_STRBW_BUS_TABLE                 (AXI_STRBW_BUS_TABLE                ),
      .AXI_LOCKW_NB                        (AXI_LOCKW_NB                       ),
      .AXI_LOCKW_PRA_TABLE                 (AXI_LOCKW_PRA_TABLE                ),
      .AXI_TOTAL_LOCKW                     (AXI_TOTAL_LOCKW                    ),
      .AXI_LOCKW_BUS_TABLE                 (AXI_LOCKW_BUS_TABLE                ),
      .AXI_WAQD_TABLE                      (AXI_WAQD_TABLE                     ),
      .MAX_AXI_WAQD_NB                     (MAX_AXI_WAQD_NB                    ),
      .AXI_WAQD_LG2_NB                     (AXI_WAQD_LG2_NB                    ),     
      .AXI_WAQD_LG2_PRA_TABLE              (AXI_WAQD_LG2_PRA_TABLE             ),
      .AXI_TOTAL_WAQD_LG2                  (AXI_TOTAL_WAQD_LG2                 ),
      .AXI_WAQD_LG2_BUS_TABLE              (AXI_WAQD_LG2_BUS_TABLE             ),
      .AXI_WDQD_TABLE                      (AXI_WDQD_TABLE                     ),
      .MAX_AXI_WDQD_NB                     (MAX_AXI_WDQD_NB                    ),
      .AXI_RAQD_TABLE                      (AXI_RAQD_TABLE                     ),
      .MAX_AXI_RAQD_NB                     (MAX_AXI_RAQD_NB                    ),
      .AXI_RAQD_LG2_NB                     (AXI_RAQD_LG2_NB                    ),     
      .AXI_RAQD_LG2_PRA_TABLE              (AXI_RAQD_LG2_PRA_TABLE             ),
      .AXI_TOTAL_RAQD_LG2                  (AXI_TOTAL_RAQD_LG2                 ),
      .AXI_RAQD_LG2_BUS_TABLE              (AXI_RAQD_LG2_BUS_TABLE             ),
      .AXI_RDQD_TABLE                      (AXI_RDQD_TABLE                     ),
      .MAX_AXI_RDQD_NB                     (MAX_AXI_RDQD_NB                    ),
      .AXI_WRQD_TABLE                      (AXI_WRQD_TABLE                     ),
      .MAX_AXI_WRQD_NB                     (MAX_AXI_WRQD_NB                    ),
      .AXI_SYNC_TABLE                      (AXI_SYNC_TABLE                     ),
      .MAX_AXI_SYNC_NB                     (MAX_AXI_SYNC_NB                    ),
      .RINFOW_TABLE                        (RINFOW_TABLE                       ),
      .MAX_RINFOW_NB                       (MAX_RINFOW_NB                      ),
      .RINFOW_NSA_TABLE                    (RINFOW_NSA_TABLE                   ),
      .MAX_RINFOW_NSA_NB                   (MAX_RINFOW_NSA_NB                  ),
      .WINFOW_TABLE                        (WINFOW_TABLE                       ),
      .MAX_WINFOW_NB                       (MAX_WINFOW_NB                      ),
      .RPINFOW_TABLE                       (RPINFOW_TABLE                      ),
      .MAX_RPINFOW_NB                      (MAX_RPINFOW_NB                     ),
      .AXI_TAGBITS_NB                      (AXI_TAGBITS_NB                     ),// for internal signals!!!
      .AXI_TAGBITS_PRA_TABLE               (AXI_TAGBITS_PRA_TABLE              ),
      .AXI_TAGBITS_TOTAL_ID                (AXI_TAGBITS_TOTAL_ID               ),
      .AXI_TAGBITS_BUS_TABLE               (AXI_TAGBITS_BUS_TABLE              ),
      .ASYNC_FIFO_N_SYNC_TABLE             (ASYNC_FIFO_N_SYNC_TABLE            ),
      .MAX_ASYNC_FIFO_N_SYNC_NB            (MAX_ASYNC_FIFO_N_SYNC_NB           ),
      .ASYNC_FIFO_EARLY_PUSH_STAT_TABLE    (ASYNC_FIFO_EARLY_PUSH_STAT_TABLE   ),
      .MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB   (MAX_ASYNC_FIFO_EARLY_PUSH_STAT_NB  ),
      .ASYNC_FIFO_EARLY_POP_STAT_TABLE     (ASYNC_FIFO_EARLY_POP_STAT_TABLE    ),
      .MAX_ASYNC_FIFO_EARLY_POP_STAT_NB    (MAX_ASYNC_FIFO_EARLY_POP_STAT_NB   ),
      .AP_ASYNC_TABLE                      (AP_ASYNC_TABLE_TABLE               ),
      .MAX_AP_ASYNC_NB                     (MAX_AP_ASYNC_NB                    ),
      .DATA_CHANNEL_INTERLEAVE_NS_TABLE    (DATA_CHANNEL_INTERLEAVE_NS_TABLE   ),
      .MAX_DATA_CHANNEL_INTERLEAVE_NS_NB   (MAX_DATA_CHANNEL_INTERLEAVE_NS_NB  ),
      .VPR_EN_TABLE                        (VPR_EN_TABLE                       ),
      .MAX_VPR_EN_NB                       (MAX_VPR_EN_NB                      ),
      .VPW_EN_TABLE                        (VPW_EN_TABLE                       ),
      .MAX_VPW_EN_NB                       (MAX_VPW_EN_NB                      ),
      .USE2RAQ_TABLE                       (USE2RAQ_TABLE                      ),
      .MAX_USE2RAQ_NB                      (MAX_USE2RAQ_NB                     ),
      .NUM_VIR_CH_TABLE                    (NUM_VIR_CH_TABLE                   ),
      .MAX_NUM_VIR_CH_NB                   (MAX_NUM_VIR_CH_NB                  ),
      .STATIC_VIR_CH_TABLE                 (STATIC_VIR_CH_TABLE                ),
      .MAX_STATIC_VIR_CH_NB                (MAX_STATIC_VIR_CH_NB               ),
      .RRB_EXTRAM_TABLE                    (RRB_EXTRAM_TABLE                   ),
      .MAX_RRB_EXTRAM_NB                   (MAX_RRB_EXTRAM_NB                  ),
      .XPI_SMALL_SIZED_PORT_TABLE          (XPI_SMALL_SIZED_PORT_TABLE         ),
      .MAX_SMALL_SIZED_PORT_NB             (MAX_SMALL_SIZED_PORT_NB            ),
      .RRB_EXTRAM_REG_TABLE                (RRB_EXTRAM_REG_TABLE               ),
      .RRB_EXTRAM_RETIME_TABLE             (RRB_EXTRAM_RETIME_TABLE            ),
      .MAX_RRB_EXTRAM_REG_NB               (MAX_RRB_EXTRAM_REG_NB              ),
      .MAX_RRB_EXTRAM_RETIME_NB            (MAX_RRB_EXTRAM_RETIME_NB           ),
      .RDWR_ORDERED_TABLE                  (RDWR_ORDERED_TABLE                 ),
      .MAX_RDWR_ORDERED_NB                 (MAX_RDWR_ORDERED_NB                ),
      .RRB_THRESHOLD_EN_TABLE              (RRB_THRESHOLD_EN_TABLE             ),
      .RRB_THRESHOLD_PPL_TABLE             (RRB_THRESHOLD_PPL_TABLE            ),
      .MAX_RRB_THRESHOLD_EN_NB             (MAX_RRB_THRESHOLD_EN_NB            ),
      .RRB_LOCK_THRESHOLD_WIDTH            (RRB_LOCK_THRESHOLD_WIDTH           ),
      .READ_DATA_INTERLEAVE_EN_TABLE       (READ_DATA_INTERLEAVE_EN_TABLE      ),
      .MAX_READ_DATA_INTERLEAVE_EN_NB      (MAX_READ_DATA_INTERLEAVE_EN_NB     ),
      .A2X_LOWPWR_IF                       (A2X_LOWPWR_IF                      ),
      .A2X_LOWPWR_NOPX_CNT                 (A2X_LOWPWR_NOPX_CNT                ),
      .A2X_LOWPWR_RST_CNT                  (A2X_LOWPWR_RST_CNT                 ),
      .A2X_HCBUF_MODE                      (A2X_HCBUF_MODE                     ),
      .A2X_HCSNF_WLEN                      (A2X_HCSNF_WLEN                     ),
      .A2X_HCSNF_RLEN                      (A2X_HCSNF_RLEN                     ),
      .A2X_WBUF_MODE                       (A2X_WBUF_MODE                      ),
      .A2X_RBUF_MODE                       (A2X_RBUF_MODE                      ),
      .A2X_SNF_AWLEN_DFLT                  (A2X_SNF_AWLEN_DFLT                 ),
      .A2X_SNF_ARLEN_DFLT                  (A2X_SNF_ARLEN_DFLT                 ),
      .A2X_HINCR_WBCNT_MAX                 (A2X_HINCR_WBCNT_MAX                ),
      .A2X_HINCR_RBCNT_MAX                 (A2X_HINCR_RBCNT_MAX                ),
      .A2X_HINCR_HCBCNT                    (A2X_HINCR_HCBCNT                   ),
      .A2X_SINGLE_RBCNT                    (A2X_SINGLE_RBCNT                   ),
      .A2X_SINGLE_WBCNT                    (A2X_SINGLE_WBCNT                   ),
      .A2X_PP_MODE                         (A2X_PP_MODE                        ),
      .A2X_UPSIZE                          (A2X_UPSIZE                         ),
      .A2X_DOWNSIZE                        (A2X_DOWNSIZE                       ),
      .A2X_LOCKED                          (A2X_LOCKED                         ),
      .A2X_AHB_WBF_SPLIT                   (A2X_AHB_WBF_SPLIT                  ),
      .A2X_RS_RATIO                        (A2X_RS_RATIO                       ),
      .A2X_RS_RATIO_LOG2                   (A2X_RS_RATIO_LOG2                  ),
      .A2X_BRESP_ORDER                     (A2X_BRESP_ORDER                    ),
      .A2X_READ_ORDER                      (A2X_READ_ORDER                     ),
      .A2X_READ_INTLEV                     (A2X_READ_INTLEV                    ),
      .A2X_PP_OSAW_LIMIT                   (A2X_PP_OSAW_LIMIT                  ),
      .A2X_PP_OSAW_LIMIT_LOG2              (A2X_PP_OSAW_LIMIT_LOG2             ),
      .A2X_B_OSW_LIMIT                     (A2X_B_OSW_LIMIT                    ),
      .A2X_B_OSW_LIMIT_LOG2                (A2X_B_OSW_LIMIT_LOG2               ),
      .A2X_SP_OSAW_LIMIT                   (A2X_SP_OSAW_LIMIT                  ),
      .A2X_SP_OSAW_LIMIT_LOG2              (A2X_SP_OSAW_LIMIT_LOG2             ),
      .A2X_OSR_LIMIT                       (A2X_OSR_LIMIT                      ), //
      .A2X_OSR_LIMIT_LOG2                  (A2X_OSR_LIMIT_LOG2                 ), //
      .A2X_IDW                             (AHB_HMASTERW                       ),
      .A2X_HBLW                            (AHB_HBURSTW                        ),
      .A2X_BSW                             (AHB_HSIZEW                         ),
      .A2X_HPTW                            (AHB_HPROTW                         ),
      .A2X_HRESPW                          (AHB_HRESPW                         ),
      .A2X_INT_AWSBW                       (AHB_AWSBW                          ),
      .BOUNDARY_W                          (A2X_BOUNDARY_W                     ),
      .A2X_AW                              (A2X_AW                             ),
      .A2X_SP_AW                           (A2X_SP_AW                          ),
      .A2X_BLW                             (AXI_LENW                           ),
      .A2X_SP_BLW                          (AXI_LENW                           ),
      .A2X_HASBW                           (A2X_HASBW                          ),
      .A2X_AWSBW                           (A2X_AWSBW                          ),
      .A2X_ARSBW                           (A2X_ARSBW                          ),
      .A2X_WSBW                            (A2X_WSBW                           ),
      .A2X_RSBW                            (A2X_RSBW                           ),
      .A2X_BSBW                            (A2X_BSBW                           ),
      .A2X_CLK_MODE                        (A2X_CLK_MODE                       ),
      .A2X_PP_SYNC_DEPTH                   (A2X_PP_SYNC_DEPTH                  ),
      .A2X_SP_SYNC_DEPTH                   (A2X_SP_SYNC_DEPTH                  ),
      .A2X_AW_FIFO_DEPTH                   (A2X_MIN_DEPTH                      ),
      .A2X_AW_FIFO_DEPTH_LOG2              (A2X_MIN_DEPTH_LOG2                 ),
      .A2X_AR_FIFO_DEPTH                   (A2X_MIN_DEPTH                      ),
      .A2X_AR_FIFO_DEPTH_LOG2              (A2X_MIN_DEPTH_LOG2                 ),
      .A2X_WD_FIFO_DEPTH                   (A2X_MIN_DEPTH                      ),
      .A2X_WD_FIFO_DEPTH_LOG2              (A2X_MIN_DEPTH_LOG2                 ),
      .A2X_RD_FIFO_DEPTH                   (A2X_MIN_DEPTH                      ),
      .A2X_RD_FIFO_DEPTH_LOG2              (A2X_MIN_DEPTH_LOG2                 ),
      .A2X_LK_RD_FIFO_DEPTH                (A2X_MIN_DEPTH                      ),
      .A2X_LK_RD_FIFO_DEPTH_LOG2           (A2X_MIN_DEPTH_LOG2                 ),
      .A2X_BRESP_FIFO_DEPTH                (A2X_MIN_DEPTH                      ),
      .A2X_BRESP_FIFO_DEPTH_LOG2           (A2X_MIN_DEPTH_LOG2                 ),
      .A2X_SP_ENDIAN                       (A2X_SP_ENDIAN                      ),
      .A2X_RS_AW_TMO                       (A2X_RS_AW_TMO                      ),
      .A2X_RS_AR_TMO                       (A2X_RS_AR_TMO                      ),
      .A2X_RS_W_TMO                        (A2X_RS_W_TMO                       ),
      .A2X_RS_B_TMO                        (A2X_RS_B_TMO                       ),
      .A2X_RS_R_TMO                        (A2X_RS_R_TMO                       ),
      .A2X_NUM_AHBM_TABLE                  (A2X_NUM_AHBM_TABLE                 ),
      .MAX_A2X_NUM_AHBM_NB                 (MAX_A2X_NUM_AHBM_NB                ),
      .A2X_BRESP_MODE_TABLE                (A2X_BRESP_MODE_TABLE               ),
      .MAX_A2X_BRESP_MODE_NB               (MAX_A2X_BRESP_MODE_NB              ),
      .A2X_AHB_LITE_MODE_TABLE             (A2X_AHB_LITE_MODE_TABLE            ),
      .MAX_A2X_AHB_LITE_MODE_NB            (MAX_A2X_AHB_LITE_MODE_NB           ),
      .A2X_SPLIT_MODE_TABLE                (A2X_SPLIT_MODE_TABLE               ),
      .MAX_A2X_SPLIT_MODE_NB               (MAX_A2X_SPLIT_MODE_NB              ),
      .A2X_HREADY_LOW_PERIOD_TABLE         (A2X_HREADY_LOW_PERIOD_TABLE        ),
      .MAX_A2X_HREADY_LOW_PERIOD_NB        (MAX_A2X_HREADY_LOW_PERIOD_NB       ),
      .A2X_NUM_UWID_TABLE                  (A2X_NUM_UWID_TABLE                 ),
      .MAX_A2X_NUM_UWID_NB                 (MAX_A2X_NUM_UWID_NB                ),
      .A2X_NUM_URID_TABLE                  (A2X_NUM_URID_TABLE                 ),
      .MAX_A2X_NUM_URID_NB                 (MAX_A2X_NUM_URID_NB                ),
      .A2X_PP_MAX_SIZE_TABLE               (A2X_PP_MAX_SIZE_TABLE              ),
      .MAX_A2X_PP_MAX_SIZE_NB              (MAX_A2X_PP_MAX_SIZE_NB             ),
      .A2X_PP_NUM_BYTES_LOG2_TABLE         (A2X_PP_NUM_BYTES_LOG2_TABLE        ),
      .MAX_A2X_PP_NUM_BYTES_LOG2_NB        (MAX_A2X_PP_NUM_BYTES_LOG2_NB       ),
      .A2X_SP_DW_TABLE                     (A2X_SP_DW_TABLE                    ),
      .MAX_A2X_SP_DW_NB                    (MAX_A2X_SP_DW_NB                   ),
      .A2X_SP_MAX_SIZE_TABLE               (A2X_SP_MAX_SIZE_TABLE              ),
      .MAX_A2X_SP_MAX_SIZE_NB              (MAX_A2X_SP_MAX_SIZE_NB             ),
      .A2X_SP_NUM_BYTES_LOG2_TABLE         (A2X_SP_NUM_BYTES_LOG2_TABLE        ),
      .MAX_A2X_SP_NUM_BYTES_LOG2_NB        (MAX_A2X_SP_NUM_BYTES_LOG2_NB       ),
      .PORT_PRIORITYW                      (PORT_PRIORITYW                     ),
      .REG_PORT_PRIORITYW                  (REG_PORT_PRIORITYW                 ),
      .PAGEMATCH_EN                        (PAGEMATCH_EN                       ),
      .MEMC_ECC_SUPPORT                    (MEMC_ECC_SUPPORT                   ),
      .MEMC_INLINE_ECC                     (MEMC_INLINE_ECC                    ),
      .WDATA_PTR_BITS                      (WDATA_PTR_BITS                     ),
      .MEMC_TAGBITS                        (MEMC_TAGBITS                       ),
      .EXT_PORTPRIO                        (EXT_PORTPRIO                       ),
      .HIF_CREDIT_BITS                     (HIF_CREDIT_BITS                    ),
      .DUAL_PA                             (DUAL_PA                            ),
      .CRDT_CNT_WIDTH                      (CRDT_CNT_WIDTH                     ),
      .HIF_ADDR_WIDTH                      (HIF_ADDR_WIDTH                     ),
      .WRDATA_CYCLES                       (WRDATA_CYCLES                      ),
      .NPORTS_DATA                         (INT_NPORTS_DATA                    ),
      .ADDR_ERR_EN                         (ADDR_ERR_EN                        ),
      .DCH_INTERLEAVE                      (DATA_CHANNEL_INTERLEAVE            ),
      .DDRCTL_HET_INTERLEAVE               (DDRCTL_HET_INTERLEAVE_EN           ),
      .MEMC_HIF_ADDR_WIDTH_MAX             (MEMC_HIF_ADDR_WIDTH_MAX            ),
      .SBR_EN                              (SBR_EN                             ),
      .LPDDR3_EN                           (LPDDR3_EN                          ),
      .LPDDR4_EN                           (LPDDR4_EN                          ),
      .SELFREF_TYPE_WIDTH                  (SELFREF_TYPE_WIDTH_INT             ),
      .SELFREF_SW_WIDTH                    (SELFREF_SW_WIDTH                   ),
      .INLINE_ECC                          (MEMC_INLINE_ECC                    ),
      .MBL                                 (MEMC_BURST_LENGTH                  ),
      .RAQ_TABLE_TABLE                     (RAQ_TABLE_TABLE                    ),
      .MAX_RAQ_TABLE_TABLE_NB              (MAX_RAQ_TABLE_TABLE_NB             ),
      .UMCTL2_MAX_AXI_TAGBITS              (UMCTL2_MAX_AXI_TAGBITS             ),
      .RAQ_TABLE                           (RAQ_TABLE                          ),
      .MEMC_NUM_RANKS                      (MEMC_NUM_RANKS                     ),
      .A_NPORTS                            (A_NPORTS                           ),
      .INT_NPORTS_DATA                     (INT_NPORTS_DATA                    ),
      .INT_NPORTS                          (INT_NPORTS                         ),
      .XPI_USE_RMWR_EN                     (XPI_USE_RMWR_EN                    )
    )
    U_arb_top
    (
      // Ports
      .reg_ddrc_ddr4                                 (reg_ddrc_ddr4_w                                             ),
      .reg_ddrc_ddr5                                 (reg_ddrc_ddr5_w                                             ),
      .reg_ddrc_lpddr4                               (reg_ddrc_lpddr4_w                                           ),
      .reg_ddrc_lpddr5                               (reg_ddrc_lpddr5_w                                           ),
      .reg_ddrc_dm_en                                (reg_ddrc_dm_en_w                                            ),
      .reg_ddrc_ecc_type                             (reg_ddrc_ecc_type_w                                         ),
      .reg_ddrc_ecc_mode                             (reg_ddrc_ecc_mode_w[2:0]                                    ),
      .reg_ddrc_multi_beat_ecc                       (multi_beat_ecc                                              ),
      .reg_arb_base_addr_0                           (reg_arb_base_addr_0_port0[AXI_SAR_BW-1:0]                   ),
      .reg_arb_nblocks_0                             (reg_arb_nblocks_0_port0[AXI_SAR_SW-1:0]                     ),
      .reg_arb_base_addr_1                           (reg_arb_base_addr_1_port0[AXI_SAR_BW-1:0]                   ),
      .reg_arb_nblocks_1                             (reg_arb_nblocks_1_port0[AXI_SAR_SW-1:0]                     ),
      .reg_arb_base_addr_2                           (reg_arb_base_addr_2_port0[AXI_SAR_BW-1:0]                   ),
      .reg_arb_nblocks_2                             (reg_arb_nblocks_2_port0[AXI_SAR_SW-1:0]                     ),
      .reg_arb_base_addr_3                           (reg_arb_base_addr_3_port0[AXI_SAR_BW-1:0]                   ),
      .reg_arb_nblocks_3                             (reg_arb_nblocks_3_port0[AXI_SAR_SW-1:0]                     ),
      .reg_ddrc_par_poison_byte_num                  (reg_ddrc_par_poison_byte_num[OCPAR_NUM_BYTES_LG2-1:0]       ),
      .reg_ddrc_occap_en                             (reg_ddrc_occap_en                                           ),
      .reg_ddrc_occap_arb_cmp_poison_seq             (reg_ddrc_occap_arb_cmp_poison_seq                           ),
      .reg_ddrc_occap_arb_cmp_poison_parallel        (reg_ddrc_occap_arb_cmp_poison_parallel                      ),
      .reg_ddrc_occap_arb_cmp_poison_err_inj         (reg_ddrc_occap_arb_cmp_poison_err_inj                       ),
      .reg_ddrc_rd_poison_slverr_en                  (reg_ddrc_rd_poison_slverr_en                                ),
      .reg_ddrc_rd_poison_intr_en                    (reg_ddrc_rd_poison_intr_en                                  ),
      .reg_ddrc_rd_poison_intr_clr                   (reg_ddrc_rd_poison_intr_clr                                 ),
      .rd_poison_intr                                (rd_poison_intr[INT_NPORTS_DATA-1:0]                         ),
      .par_waddr_err_pulse                           (par_waddr_err_pulse[A_NPORTS-1:0]                           ),
      .par_raddr_err_pulse                           (par_raddr_err_pulse[A_NPORTS-1:0]                           ),
      .par_rdata_err_pulse                           (par_rdata_err_pulse[A_NPORTS-1:0]                           ),
      .par_wdata_in_err_pulse                        (par_wdata_in_err_pulse[A_NPORTS-1:0]                        ),
      .xpi_a_parity_err                              (xpi_a_parity_err[A_NPORTS-1:0]                              ),
      .xpi_parity_err                                (xpi_parity_err[A_NPORTS-1:0]                                ),
      .xpi_aclk_cmp_err                              (xpi_aclk_cmp_err[A_NPORTS-1:0]                              ),
      .xpi_aclk_cmp_err_full                         (xpi_aclk_cmp_err_full[A_NPORTS-1:0]                         ),
      .xpi_aclk_cmp_err_seq                          (xpi_aclk_cmp_err_seq[A_NPORTS-1:0]                          ),
      .xpi_cclk_cmp_err                              (xpi_cclk_cmp_err[A_NPORTS-1:0]                              ),
      .xpi_cclk_cmp_err_full                         (xpi_cclk_cmp_err_full[A_NPORTS-1:0]                         ),
      .xpi_cclk_cmp_err_seq                          (xpi_cclk_cmp_err_seq[A_NPORTS-1:0]                          ),
      .xpi_aclk_cmp_poison_complete                  (xpi_aclk_cmp_poison_complete[A_NPORTS-1:0]                  ),
      .xpi_cclk_cmp_poison_complete                  (xpi_cclk_cmp_poison_complete[A_NPORTS-1:0]                  ),
      .reg_ddrc_ecc_region_map                       (reg_ddrc_ecc_region_map_w                                   ),
      .reg_ddrc_ecc_region_map_granu                 (reg_ddrc_ecc_region_map_granu_w                             ),
      .reg_ddrc_ecc_region_map_other                 (reg_ddrc_ecc_region_map_other_w                             ),
      .ddrc_xpi_port_disable_req                     (ddrc_xpi_port_disable_req_w                                 ),
      .ddrc_xpi_clock_required                       (ddrc_xpi_clock_required_w                                   ),
      .xpi_ddrc_port_disable_ack                     (xpi_ddrc_port_disable_ack[INT_NPORTS_DATA-1:0]              ),
      .xpi_ddrc_wch_locked                           (xpi_ddrc_wch_locked                                         ),
      .aclk_vector                                   (aclk_vector[15:0]                                           ),
      .aresetn_vector                                (aresetn_vector[15:0]                                        ),
      .csysreq_xpi_vector                            (csysreq_xpi_vector[15:0]                                    ),
      .csysack_xpi_vector                            (csysack_xpi_vector[A_NPORTS-1:0]                            ),
      .cactive_xpi_vector                            (cactive_xpi[A_NPORTS-1:0]                                   ), 
      .cactive_out_vector                            (cactive_out[A_NPORTS-1:0]                                   ), 
      .rd_port_busy_vector                           (rd_port_busy[A_NPORTS-1:0]                                  ),
      .wr_port_busy_vector                           (wr_port_busy[A_NPORTS-1:0]                                  ),
      .reg_ddrc_burst_rdwr                           (reg_ddrc_burst_rdwr[BRW-1:0]                                ),
      .reg_ddrc_data_bus_width                       (reg_ddrc_data_bus_width_int[DBW-1:0]                        ),
      .reg_arba_data_bus_width_vector                (reg_arba_data_bus_width_vector                              ),
      .reg_xpi_snf_mode_vector                       (reg_xpi_snf_mode_vector[A_NPORTS-1:0]                       ),
      .reg_ddrc_burstchop                            (reg_ddrc_burstchop_w                                        ),
      .reg_ddrc_wr_crc_enable                        (reg_ddrc_wr_crc_enable_w                                    ),
      .reg_ddrc_col_addr_shift                       (reg_ddrc_col_addr_shift_w                                   ),


      .reg_ddrc_addrmap_col_b2                       (reg_ddrc_addrmap_col_b2_map0[AMCOLW_L-1:0]                   ),
      .reg_ddrc_addrmap_col_b3                       (reg_ddrc_addrmap_col_b3_map0[AMCOLW_C3-1:0]                  ),
      .oc_parity_type_core_clock                     (oc_parity_type_core_clock                                   ), 
      .reg_arb_bl_exp_mode                           (reg_arb_bl_exp_mode_port0                                         ),
      .reg_arb_port_en_vector                        (reg_arb_port_en_vector[15:0]                                ),
      .reg_arb_bypass_reorder_vector                 (reg_arb_bypass_reorder_vector[15:0]                         ),
      .reg_arb_id_mask_vector                        (reg_arb_id_mask_vector                                      ),
      .reg_arb_id_value_vector                       (reg_arb_id_value_vector                                     ),
      .reg_arb_occap_arb_cmp_poison_seq_vector       (reg_arb_occap_arb_cmp_poison_seq_vector[15:0]               ),
      .reg_arb_occap_arb_cmp_poison_parallel_vector  (reg_arb_occap_arb_cmp_poison_parallel_vector[15:0]          ),
      .reg_arb_occap_arb_cmp_poison_err_inj_vector   (reg_arb_occap_arb_cmp_poison_err_inj_vector[15:0]           ),
      .reg_arb_occap_arb_raq_poison_en_vector        (reg_arb_occap_arb_raq_poison_en_vector[15:0]                ),

      .ocecc_en_aclk_vector                          (ocecc_en_aclk_vector                       ),
      .ocecc_poison_egen_mr_rd_0_vector              (ocecc_poison_egen_mr_rd_0_vector           ),
      .ocecc_poison_egen_mr_rd_0_byte_num_vector     (ocecc_poison_egen_mr_rd_0_byte_num_vector  ),
      .ocecc_poison_egen_xpi_rd_out_vector           (ocecc_poison_egen_xpi_rd_out_vector        ),
      .ocecc_poison_single_vector                    (ocecc_poison_single_vector                 ),
      .ocecc_wdata_slverr_en_vector                  (ocecc_wdata_slverr_en_vector               ),
      .ocecc_rdata_slverr_en_vector                  (ocecc_rdata_slverr_en_vector               ),

      .oc_parity_en_aclk_vector                      (oc_parity_en_aclk_vector[15:0]                              ),
      .oc_parity_type_aclk_vector                    (oc_parity_type_aclk_vector[15:0]                            ),
      .par_addr_slverr_en_aclk_vector                (par_addr_slverr_en_aclk_vector[15:0]                        ),
      .par_rdata_slverr_en_vector                    (par_rdata_slverr_en_vector[15:0]                            ),
      .rd_poison_en_vector                           (rd_poison_en_vector[15:0]                                   ),
      .wr_poison_en_vector                           (wr_poison_en_vector[15:0]                                   ),
      .par_wdata_err_intr_clr_vector                 (par_wdata_err_intr_clr_vector[15:0]                         ),
      .par_rdata_err_intr_clr_vector                 (par_rdata_err_intr_clr_vector[15:0]                         ),
      .par_wdata_axi_check_bypass_en                 (par_wdata_axi_check_bypass_en                               ),
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((AXI_IDW * 16) - 1)' found in module 'DWC_ddrctl'
//SJ: This coding style (such as ".awid_vector (awid_vector[AXI_IDW*16-1:0]),") is acceptable and there is no plan to change it.
      .awid_vector                                   (awid_vector[AXI_IDW*16-1:0]                                 ),
      .awaddr_vector                                 (awaddr_vector[AXI_ADDRW*16-1:0]                             ),
      .awlen_vector                                  (awlen_vector[AXI_LENW*16-1:0]                               ),
      .awsize_vector                                 (awsize_vector[AXI_SIZEW*16-1:0]                             ),
      .awburst_vector                                (awburst_vector[AXI_BURSTW*16-1:0]                           ),
      .awlock_vector                                 (awlock_vector                                               ),
      .awcache_vector                                (awcache_vector[AXI_CACHEW*16-1:0]                           ),
      .awprot_vector                                 (awprot_vector[AXI_PROTW*16-1:0]                             ),
      .awuser_vector                                 (awuser_vector[AXI_USERW*16-1:0]                             ),
      .awqos_vector                                  (awqos_vector[AXI_QOSW*16-1:0]                               ),
      .awurgent_vector                               (awurgent_vector[15:0]                                       ),
      .awvalid_vector                                (awvalid_vector[15:0]                                        ),
      .awpoison_vector                               (awpoison_vector[15:0]                                       ),
      .awautopre_vector                              (awautopre_vector[15:0]                                      ),
      .awparity_vector                               (awparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*16-1:0]         ),
      .awready_vector                                (awready_vector[A_NPORTS-1:0]                                ),
      .wid_vector                                    (wid_vector[AXI_IDW*16-1:0]                                  ),
      .wdata_vector                                  (wdata_vector                                                ),
      .wparity_vector                                (wparity_vector                                              ),
      .wstrb_vector                                  (wstrb_vector                                                ),
      .wlast_vector                                  (wlast_vector[15:0]                                          ),
      .wvalid_vector                                 (wvalid_vector[15:0]                                         ),
      .wready_vector                                 (wready_vector[A_NPORTS-1:0]                                 ),
      .wuser_vector                                  (wuser_vector[AXI_USERW*16-1:0]                              ),
      .bid_vector                                    (bid_vector[AXI_IDW*A_NPORTS-1:0]                            ),
      .bresp_vector                                  (bresp_vector[AXI_RESPW*A_NPORTS-1:0]                        ),
      .buser_vector                                  (buser_vector[AXI_USERW*A_NPORTS-1:0]                        ),
      .bvalid_vector                                 (bvalid_vector[A_NPORTS-1:0]                                 ),
      .bready_vector                                 (bready_vector[15:0]                                         ),
      .arid_vector                                   (arid_vector[AXI_IDW*16-1:0]                                 ),
      .araddr_vector                                 (araddr_vector[AXI_ADDRW*16-1:0]                             ),
      .arlen_vector                                  (arlen_vector[AXI_LENW*16-1:0]                               ),
      .arsize_vector                                 (arsize_vector[AXI_SIZEW*16-1:0]                             ),
      .arburst_vector                                (arburst_vector[AXI_BURSTW*16-1:0]                           ),
      .arlock_vector                                 (arlock_vector                                               ),
      .arcache_vector                                (arcache_vector[AXI_CACHEW*16-1:0]                           ),
      .arprot_vector                                 (arprot_vector[AXI_PROTW*16-1:0]                             ),
      .aruser_vector                                 (aruser_vector[AXI_USERW*16-1:0]                             ),
      .arqos_vector                                  (arqos_vector[AXI_QOSW*16-1:0]                               ),
      .arurgentb_vector                              (arurgentb_vector[15:0]                                      ),
      .arurgentr_vector                              (arurgentr_vector[15:0]                                      ),
      .arvalid_vector                                (arvalid_vector[15:0]                                        ),
      .arpoison_vector                               (arpoison_vector[15:0]                                       ),
      .arautopre_vector                              (arautopre_vector[15:0]                                      ),
      .arparity_vector                               (arparity_vector[OCPAR_ADDR_PARITY_WIDTH_MIN*16-1:0]         ),
      .arready_vector                                (arready_vector[A_NPORTS-1:0]                                ),
      .rid_vector                                    (rid_vector[AXI_IDW*A_NPORTS-1:0]                            ),
      .rdata_vector                                  (rdata_vector                                                ),
      .rparity_vector                                (rparity_vector                                              ),
      .rresp_vector                                  (rresp_vector[AXI_RESPW*A_NPORTS-1:0]                        ),
      .ruser_vector                                  (ruser_vector[AXI_USERW*A_NPORTS-1:0]                        ),
      .rlast_vector                                  (rlast_vector[A_NPORTS-1:0]                                  ),
      .rvalid_vector                                 (rvalid_vector[A_NPORTS-1:0]                                 ),
      .rready_vector                                 (rready_vector[15:0]                                         ),
      .par_raddr_log_vector                          (par_raddr_log[AXI_ADDRW*NPORTS-1:0]                         ),
      .par_waddr_log_vector                          (par_waddr_log[AXI_ADDRW*NPORTS-1:0]                         ),
      .par_rdata_byte_log_vector                     (par_rdata_byte_log[OCPAR_NUM_BYTES*NPORTS-1:0]              ),
      // output vector and need to changing final destinaition assignment   
      .ocecc_xpi_write_uncorr_err_vector             (ocecc_xpi_write_uncorr_err                                  ), //directly mapping
      .ocecc_xpi_read_uncorr_err_vector              (ocecc_xpi_read_uncorr_err                                   ), //directly mapping
      .ocecc_xpi_write_corr_err_vector               (ocecc_xpi_write_corr_err                                    ), //directly mapping
      .ocecc_xpi_read_corr_err_vector                (ocecc_xpi_read_corr_err                                     ), //directly mapping
    
      .rdataram_dout_vector                          (rdataram_dout_vector[UMCTL2_RDATARAM_DW*16-1:0]             ),
      .rdataram_din_vector                           (rdataram_din_vector[UMCTL2_RDATARAM_DW*A_NPORTS-1:0]        ),
      .rdataram_wr_vector                            (rdataram_wr_vector[A_NPORTS-1:0]                            ),
      .rdataram_re_vector                            (rdataram_re_vector[A_NPORTS-1:0]                            ),
      .rdataram_raddr_vector                         (rdataram_raddr_vector[UMCTL2_RDATARAM_AW*A_NPORTS-1:0]      ),
      .rdataram_waddr_vector                         (rdataram_waddr_vector[UMCTL2_RDATARAM_AW*A_NPORTS-1:0]      ),
      .rdataram_dout_par_vector                      (rdataram_dout_par_vector[UMCTL2_DATARAM_PAR_DW*16-1:0]      ),
      .rdataram_din_par_vector                       (rdataram_din_par_vector[UMCTL2_DATARAM_PAR_DW*A_NPORTS-1:0] ),
      .rdataram_dout_dch1_vector                     (rdataram_dout_dch1_vector[UMCTL2_RDATARAM_DW*16-1:0]        ),
      .rdataram_din_dch1_vector                      (rdataram_din_dch1_vector[UMCTL2_RDATARAM_DW*A_NPORTS-1:0]   ),
      .rdataram_wr_dch1_vector                       (rdataram_wr_dch1_vector[A_NPORTS-1:0]                       ),
      .rdataram_re_dch1_vector                       (rdataram_re_dch1_vector[A_NPORTS-1:0]                       ),
      .rdataram_raddr_dch1_vector                    (rdataram_raddr_dch1_vector[UMCTL2_RDATARAM_AW*A_NPORTS-1:0] ),
      .rdataram_waddr_dch1_vector                    (rdataram_waddr_dch1_vector[UMCTL2_RDATARAM_AW*A_NPORTS-1:0] ),
      .rdataram_dout_par_dch1_vector                 (rdataram_dout_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*16-1:0] ),
      .rdataram_din_par_dch1_vector                  (rdataram_din_par_dch1_vector[UMCTL2_DATARAM_PAR_DW*A_NPORTS-1:0]),
      .reg_arba_rqos_map_level1_vector               (reg_arba_rqos_map_level1_vector[XPI_RQOS_MLW*16-1:0]        ),
      .reg_arba_rqos_map_level2_vector               (reg_arba_rqos_map_level2_vector[XPI_RQOS_MLW*16-1:0]        ),
      .reg_arba_rqos_map_region0_vector              (reg_arba_rqos_map_region0_vector[XPI_RQOS_RW*16-1:0]        ),
      .reg_arba_rqos_map_region1_vector              (reg_arba_rqos_map_region1_vector[XPI_RQOS_RW*16-1:0]        ),
      .reg_arba_rqos_map_region2_vector              (reg_arba_rqos_map_region2_vector[XPI_RQOS_RW*16-1:0]        ),
      .reg_arb_rqos_map_timeoutb_vector              (reg_arb_rqos_map_timeoutb_vector[HIF_RQOS_TW*16-1:0]        ),
      .reg_arb_rqos_map_timeoutr_vector              (reg_arb_rqos_map_timeoutr_vector[HIF_RQOS_TW*16-1:0]        ),
      .reg_arba_wqos_map_level1_vector               (reg_arba_wqos_map_level1_vector[XPI_WQOS_MLW*16-1:0]        ),
      .reg_arba_wqos_map_level2_vector               (reg_arba_wqos_map_level2_vector[XPI_WQOS_MLW*16-1:0]        ),
      .reg_arba_wqos_map_region0_vector              (reg_arba_wqos_map_region0_vector[XPI_WQOS_RW*16-1:0]        ),
      .reg_arba_wqos_map_region1_vector              (reg_arba_wqos_map_region1_vector[XPI_WQOS_RW*16-1:0]        ),
      .reg_arba_wqos_map_region2_vector              (reg_arba_wqos_map_region2_vector[XPI_WQOS_RW*16-1:0]        ),
      .reg_arb_wqos_map_timeout1_vector              (reg_arb_wqos_map_timeout1_vector[HIF_WQOS_TW*16-1:0]        ),
      .reg_arb_wqos_map_timeout2_vector              (reg_arb_wqos_map_timeout2_vector[HIF_WQOS_TW*16-1:0]        ),
      .reg_arb_rd_port_pagematch_en_vector           (reg_arb_rd_port_pagematch_en_vector[15:0]                   ),
      .reg_arb_wr_port_pagematch_en_vector           (reg_arb_wr_port_pagematch_en_vector[15:0]                   ),
      .reg_arb_rdwr_ordered_en_vector                (reg_arb_rdwr_ordered_en_vector[15:0]                        ),
      .reg_arba_rdwr_ordered_en_vector               (reg_arba_rdwr_ordered_en_vector[15:0]                       ),
      .reg_arb_rrb_lock_threshold_vector             (reg_arb_rrb_lock_threshold_vector[RRB_LOCK_THRESHOLD_WIDTH*16-1:0]),
      .reg_arb_port_data_channel_vector              (reg_arb_port_data_channel_vector[15:0]                      ),
      .raqb_wcount_vector                            (raqb_wcount_vector                                          ),
      .raqb_pop_vector                               (raqb_pop_vector[A_NPORTS-1:0]                               ),
      .raqb_push_vector                              (raqb_push_vector[A_NPORTS-1:0]                              ),
      .raqr_wcount_vector                            (raqr_wcount_vector                                          ),
      .raqr_pop_vector                               (raqr_pop_vector[A_NPORTS-1:0]                               ),
      .raqr_push_vector                              (raqr_push_vector[A_NPORTS-1:0]                              ),
      .raq_split_vector                              (raq_split_vector[A_NPORTS-1:0]                              ),
      .waq_wcount_vector                             (waq_wcount_vector                                           ),
      .waq_pop_vector                                (waq_pop_vector[A_NPORTS-1:0]                                ),
      .waq_push_vector                               (waq_push_vector[A_NPORTS-1:0]                               ),
      .waq_split_vector                              (waq_split_vector[A_NPORTS-1:0]                              ),
      .hif_lpr_credit                                (hif_lpr_credit[HIF_CREDIT_BITS-1:0]                         ),
      .hif_cmd_stall                                 (hif_cmd_stall                                               ),    
      .hif_wr_credit                                 (hif_wr_credit                                               ),
      .hif_hpr_credit                                (hif_hpr_credit[HIF_CREDIT_BITS-1:0]                         ),
      .hif_wrecc_credit                              (hif_wrecc_credit[1:0]                                       ),
      .pa_ddrc_go2critical_wr                        (pa_hif_go2critical_wr                                       ),
      .pa_ddrc_go2critical_lpr                       (pa_hif_go2critical_lpr                                      ),
      .pa_ddrc_go2critical_hpr                       (pa_hif_go2critical_hpr                                      ),
      .pa_hif_go2critical_l1_wr                      (pa_hif_go2critical_l1_wr                                    ),
      .pa_hif_go2critical_l2_wr                      (pa_hif_go2critical_l2_wr                                    ),
      .pa_hif_go2critical_l1_lpr                     (pa_hif_go2critical_l1_lpr                                   ),
      .pa_hif_go2critical_l2_lpr                     (pa_hif_go2critical_l2_lpr                                   ),
      .pa_hif_go2critical_l1_hpr                     (pa_hif_go2critical_l1_hpr                                   ),
      .pa_hif_go2critical_l2_hpr                     (pa_hif_go2critical_l2_hpr                                   ),
      .any_other_stall_condition                     (any_other_stall_condition                                   ),
      .lpr_num_entries_changed                       (lpr_num_entries_changed                                     ),
      .perf_hpr_req_with_nocredit_dch0               (perf_hpr_req_with_nocredit_dch0                             ),
      .perf_lpr_req_with_nocredit_dch0               (perf_lpr_req_with_nocredit_dch0                             ),
      .lpr_credit_cnt                                (lpr_credit_cnt[CRDT_CNT_WIDTH-1:0]                          ),
      .hpr_credit_cnt                                (hpr_credit_cnt[CRDT_CNT_WIDTH-1:0]                          ),
      .wr_credit_cnt                                 (wr_credit_cnt[CRDT_CNT_WIDTH-1:0]                           ),
      .wrecc_credit_cnt                              (wrecc_credit_cnt[CRDT_CNT_WIDTH-1:0]                        ),
      .pa_parity_err_dch0                            (pa_parity_err_dch0                                          ),
      .pa_parity_err_dch1                            (pa_parity_err_dch1                                          ),
      .reg_arb_go2critical_en                        (reg_arb_go2critical_en_port0                                      ),
      .reg_arb_pagematch_limit                       (reg_arb_pagematch_limit_port0                                     ),     
      .reg_wr_port_priority_vector                   (reg_arb_wr_port_priority_vector[INT_NPORTS*REG_PORT_PRIORITYW-1:0]  ),
      .reg_rd_port_priority_vector                   (reg_arb_rd_port_priority_vector[INT_NPORTS*REG_PORT_PRIORITYW-1:0]  ),
      .reg_rd_port_aging_en_vector                   (reg_arb_rd_port_aging_en_vector[INT_NPORTS-1:0]                     ),
      .reg_wr_port_aging_en_vector                   (reg_arb_wr_port_aging_en_vector[INT_NPORTS-1:0]                     ),
      .reg_wr_port_urgent_en_vector                  (reg_arb_wr_port_urgent_en_vector[INT_NPORTS-1:0]                    ),
      .reg_rd_port_urgent_en_vector                  (reg_arb_rd_port_urgent_en_vector[INT_NPORTS-1:0]                    ),
//spyglass enable_block SelfDeterminedExpr-ML
      .core_ddrc_core_clk                            (core_ddrc_core_clk                                          ),
      .core_ddrc_rstn                                (core_ddrc_rstn                                              ),
      .hif_hif_cmd_latency                           (hif_hif_cmd_latency[HIF_RQOS_TW-1:0]                        ),
      .hif_hif_cmd_valid                             (hif_hif_cmd_valid                                           ),
      .hif_hif_cmd_type                              (hif_hif_cmd_type[1:0]                                       ),
      .hif_hif_cmd_addr                              (hif_hif_cmd_addr[HIF_ADDR_WIDTH-1:0]                        ),
      .hif_hif_cmd_pri                               (hif_hif_cmd_pri[XPI_RQOS_RW-1:0]                            ),
      .hif_hif_cmd_token                             (hif_hif_cmd_token[MEMC_TAGBITS-1:0]                         ),
      .hif_hif_cmd_length                            (hif_hif_cmd_length[UMCTL2_CMD_LEN_BITS-1:0]                 ),
      .hif_hif_cmd_wdata_ptr                         (hif_hif_cmd_wdata_ptr[WDATA_PTR_BITS-1:0]                   ),
      .hif_hif_cmd_autopre                           (hif_hif_cmd_autopre                                         ),
      .hif_hif_cmd_ecc_region                        (hif_hif_cmd_ecc_region                                      ),
      .hif_hif_cmd_wdata_mask_full_ie                (hif_hif_cmd_wdata_mask_full_ie[WRDATA_CYCLES-1:0]           ),
      .hif_hif_cmd_awlast                            (hif_hif_cmd_awlast                                          ),            
      .hif_hif_cmd_short_burst                       (hif_hif_cmd_short_burst                                     ),       
     
      .hif_wdata_ptr                                 (hif_wdata_ptr[MEMC_WDATA_PTR_BITS-1:0]                      ),
      .hif_wdata_ptr_valid                           (hif_wdata_ptr_valid                                         ),
      .hif_wr_addr_err                               (hif_wdata_ptr_addr_err                                      ),
     
      .hif_rdata_valid                               (hif_rdata_valid                                             ),
      .hif_rdata_end                                 (hif_rdata_end                                               ),
      .hif_rdata_token                               (hif_rdata_token[MEMC_TAGBITS-1:0]                           ),
      .hif_rdata                                     (hif_rdata[A_DW-1:0]                                         ),
      .hif_rdata_parity                              (hif_rdata_parity[A_STRBW-1:0]                               ),
      .hif_rdata_uncorr_ecc_err                      (1'b0                                                        ),
      .hif_rdata_addr_err                            (hif_rdata_addr_err                                          ),
      .hif_rdata_crc_err                             (1'b0                                                        ),
     .hif_rdata_eapar_err                            (1'b0                                                        ),
     .hif_rdata_uncorr_linkecc_err                   (1'b0                                                        ),
      .hif_wdata_stall                               (hif_wdata_stall                                             ),
      .hif_wdata_valid                               (hif_hif_wdata_valid                                         ),
     
      .hif_wdata_end                                 (hif_hif_wdata_end                                           ),
      .hif_wdata                                     (hif_hif_wdata[A_DW-1:0]                                     ),
      .hif_wdata_mask                                (hif_hif_wdata_mask[A_STRBW-1:0]                             ),
      .hif_wdata_parity                              (hif_hif_wdata_parity[A_PARW-1:0]                           ),
     
      .reg_ddrc_par_addr_slverr_en                   (par_addr_slverr_en_core_clock                               ),
      .reg_ddrc_par_wdata_slverr_en                  (par_wdata_slverr_en                                         ),
      .reg_ddrc_ocecc_wdata_slverr_en                (ocecc_wdata_slverr_en_cclk                                  ),    
      .reg_ddrc_wr_poison_slverr_en                  (reg_ddrc_wr_poison_slverr_en                                ),
      .reg_ddrc_wr_poison_intr_en                    (reg_ddrc_wr_poison_intr_en                                  ),
      .reg_ddrc_wr_poison_intr_clr                   (reg_ddrc_wr_poison_intr_clr                                 ),
     
      .occap_hif_data_par_err_dch0                   (hif_data_parity_err_dch0                                    ),
      .wr_poison_intr_dch0                           (wr_poison_intr_dch0[INT_NPORTS_DATA-1:0]                    ),

      .occap_hif_data_par_err_dch1                   (hif_data_parity_err_dch1                                    ),
      .wr_poison_intr_dch1                           (wr_poison_intr_dch1[INT_NPORTS_DATA-1:0]                    ),


      .exa_parity_err                                (exa_parity_err_dch0                                         ),
      .exa_parity_err_dch1                           (exa_parity_err_dch1                                         ),


      .occap_sbr_par_err_dch0                        (sbr_parity_err_dch0                                         ),
      .occap_sbr_par_err_dch1                        (sbr_parity_err_dch1                                         ),
      .pa_rmask                                      (pa_rmask                                                    ),
      .pa_wmask                                      (pa_wmask                                                    ),
     
      .reg_ddrc_lpddr3_6gb_12gb                      (reg_ddrc_lpddr3_6gb_12gb_map0),
     
      .reg_ddrc_lpddr45_6gb_12gb_24gb                  (reg_ddrc_lpddr45_6gb_12gb_24gb_map0),

      .reg_ddrc_nonbinary_device_density             (reg_ddrc_nonbinary_device_density_map0),



      .reg_ddrc_addrmap_bank_b0                      (reg_ddrc_addrmap_bank_b0_map0[AMBANKW-1:0]                  ),
      .reg_ddrc_addrmap_bank_b1                      (reg_ddrc_addrmap_bank_b1_map0[AMBANKW-1:0]                  ),
      .reg_ddrc_addrmap_bank_b2                      (reg_ddrc_addrmap_bank_b2_map0[AMBANKW-1:0]                  ),
      .reg_ddrc_addrmap_col_b4                       (reg_ddrc_addrmap_col_b4_map0[AMCOLW_L-1:0]                  ),
      .reg_ddrc_addrmap_col_b5                       (reg_ddrc_addrmap_col_b5_map0[AMCOLW_L-1:0]                  ),
      .reg_ddrc_addrmap_col_b6                       (reg_ddrc_addrmap_col_b6_map0[AMCOLW_L-1:0]                  ),
      .reg_ddrc_addrmap_col_b7                       (reg_ddrc_addrmap_col_b7_map0[AMCOLW_H-1:0]                  ),
      .reg_ddrc_addrmap_col_b8                       (reg_ddrc_addrmap_col_b8_map0[AMCOLW_H-1:0]                  ),
      .reg_ddrc_addrmap_col_b9                       (reg_ddrc_addrmap_col_b9_map0[AMCOLW_H-1:0]                  ),
      .reg_ddrc_addrmap_col_b10                      (reg_ddrc_addrmap_col_b10_map0[AMCOLW_H-1:0]                 ),
      .reg_ddrc_addrmap_col_b11                      (reg_ddrc_addrmap_col_b11_map0[AMCOLW_H-1:0]                 ),
      .reg_ddrc_addrmap_row_b0                       (reg_ddrc_addrmap_row_b0_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b1                       (reg_ddrc_addrmap_row_b1_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b2                       (reg_ddrc_addrmap_row_b2_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b3                       (reg_ddrc_addrmap_row_b3_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b4                       (reg_ddrc_addrmap_row_b4_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b5                       (reg_ddrc_addrmap_row_b5_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b6                       (reg_ddrc_addrmap_row_b6_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b7                       (reg_ddrc_addrmap_row_b7_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b8                       (reg_ddrc_addrmap_row_b8_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b9                       (reg_ddrc_addrmap_row_b9_map0[AMROWW-1:0]                    ),
      .reg_ddrc_addrmap_row_b10                      (reg_ddrc_addrmap_row_b10_map0[AMROWW-1:0]                   ),
      .reg_ddrc_addrmap_row_b2_10                    (reg_ddrc_addrmap_row_b2_10_map0[AMROWW-1:0]                 ),
      .reg_ddrc_addrmap_row_b11                      (reg_ddrc_addrmap_row_b11_map0[AMROWW-1:0]                   ),
      .reg_ddrc_addrmap_row_b12                      (reg_ddrc_addrmap_row_b12_map0[AMROWW-1:0]                   ),
      .reg_ddrc_addrmap_row_b13                      (reg_ddrc_addrmap_row_b13_map0[AMROWW-1:0]                   ),
      .reg_ddrc_addrmap_row_b14                      (reg_ddrc_addrmap_row_b14_map0[AMROWW-1:0]                   ),
      .reg_ddrc_addrmap_row_b15                      (reg_ddrc_addrmap_row_b15_map0[AMROWW-1:0]                   ),
      .reg_ddrc_addrmap_row_b16                      (reg_ddrc_addrmap_row_b16_w[AMROWW-1:0]                      ),
      .reg_ddrc_addrmap_row_b17                      (reg_ddrc_addrmap_row_b17_w[AMROWW-1:0]                      ),
      .pm_mask_parity_err                            (pm_mask_parity_err                                          )
    );

  //-----------------------------------------------------------------------------------
  //  End arb_top Instantiation
  //-----------------------------------------------------------------------------------


    assign reg_ddrc_ecc_type_w                           = 1'b0;






















   assign ddrc_reg_ver_number = `DDRCTL_VER_NUMBER_VAL;
   assign ddrc_reg_ver_type   = `DDRCTL_VER_TYPE_VAL;





        `SNPS_UNR_CONSTANT("hif_cmd_length[0]==0 is required if MEMC_BURST_LENGTH=16 and MEMC_FREQ_RATIO=4", (1) ,arb_hif_cmd_length[0], 0)

// -----------------------------------------
// Assertions
// -----------------------------------------
`ifndef SYNTHESIS
  // Programmable bus width modes related
  property p_dbg_pbw_mode1_reg_value_chk;
      @ (posedge core_ddrc_core_clk) disable iff (~core_ddrc_rstn)
        (`DDRCTL_PBW_MODE_SUPPORT == 1) |-> ((reg_ddrc_data_bus_width==2'b00) || (reg_ddrc_data_bus_width==2'b01));
  endproperty

  property p_dbg_pbw_mode2_reg_value_chk;
      @ (posedge core_ddrc_core_clk) disable iff (~core_ddrc_rstn)
        (`DDRCTL_PBW_MODE_SUPPORT == 2) |-> (reg_ddrc_data_bus_width==2'b00);
  endproperty

  a_p_dbg_pbw_mode1_reg_value_chk: assert property (p_dbg_pbw_mode1_reg_value_chk)
                                   else $error ("MSTR0.data_bus_width must be equal to 2'b00(FBW) or 2'b01(HBW) when DDRCTL_PBW_MODE_SUPPORT=1");

  a_p_dbg_pbw_mode2_reg_value_chk: assert property (p_dbg_pbw_mode2_reg_value_chk)
                                   else $error ("MSTR0.data_bus_width must be equal to 2'b00(FBW) when DDRCTL_PBW_MODE_SUPPORT=2");


   `assert_coreclk(ERROR_REG_LPR_NUM_ENTRIES_PROGRAMMED_AFTER_RESET, (reg_ddrc_lpr_num_entries==$past(reg_ddrc_lpr_num_entries)) );

   wire umctl2_is_busy;
   assign umctl2_is_busy = (|rd_port_busy) | (|wr_port_busy);

   `assert_coreclk(ERROR_REG_RQOS_MAP_LEVEL_0_BAD_VALUE, (umctl2_is_busy |->
          ((reg_arba0_rqos_map_level2_port0 != reg_arba0_rqos_map_level1_port0) && (reg_arba0_rqos_map_level1_port0<(15-`UMCTL2_XPI_USE2RAQ_0)) && (reg_arba0_rqos_map_level2_port0>reg_arba0_rqos_map_level1_port0))));
   `assert_coreclk(ERROR_REG_RQOS_MAP_LEVEL_0_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |->
          ((reg_arba0_rqos_map_level2_port0==$past(reg_arba0_rqos_map_level2_port0)) && (reg_arba0_rqos_map_level1_port0==$past(reg_arba0_rqos_map_level1_port0)))));
   `assert_coreclk(ERROR_REG_RQOS_MAP_REGION_0_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |->
          ((reg_arba0_rqos_map_region2_port0==$past(reg_arba0_rqos_map_region2_port0)) && (reg_arba0_rqos_map_region1_port0==$past(reg_arba0_rqos_map_region1_port0)) &&
           (reg_arba0_rqos_map_region0_port0==$past(reg_arba0_rqos_map_region0_port0)))));
   `assert_coreclk(ERROR_REG_RQOS_MAP_TIMEOUT_0_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |->
          ((reg_arb_rqos_map_timeoutb_port0==$past(reg_arb_rqos_map_timeoutb_port0)) && (reg_arb_rqos_map_timeoutr_port0==$past(reg_arb_rqos_map_timeoutr_port0)))));















    `assert_coreclk(ERROR_REG_SARBASE0_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_base_addr_0_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARSIZE0_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_nblocks_0_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARBASE0_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_base_addr_0_port0==$past(reg_arb_base_addr_0_port0))));
    `assert_coreclk(ERROR_REG_SARSIZE0_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_nblocks_0_port0==$past(reg_arb_nblocks_0_port0))));

    `assert_coreclk(ERROR_REG_SARBASE1_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_base_addr_1_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARSIZE1_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_nblocks_1_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARBASE1_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_base_addr_1_port0==$past(reg_arb_base_addr_1_port0))));
    `assert_coreclk(ERROR_REG_SARSIZE1_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_nblocks_1_port0==$past(reg_arb_nblocks_1_port0))));

    `assert_coreclk(ERROR_REG_SARBASE2_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_base_addr_2_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARSIZE2_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_nblocks_2_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARBASE2_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_base_addr_2_port0==$past(reg_arb_base_addr_2_port0))));
    `assert_coreclk(ERROR_REG_SARSIZE2_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_nblocks_2_port0==$past(reg_arb_nblocks_2_port0))));

    `assert_coreclk(ERROR_REG_SARBASE3_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_base_addr_3_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARSIZE3_OUT_OF_RANGE, (umctl2_is_busy |-> (reg_arb_nblocks_3_port0< `UMCTL2_SAR_MAXNBLOCKS)));
    `assert_coreclk(ERROR_REG_SARBASE3_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_base_addr_3_port0==$past(reg_arb_base_addr_3_port0))));
    `assert_coreclk(ERROR_REG_SARSIZE3_PROGRAMMED_WHILE_BUSY, (umctl2_is_busy |-> (reg_arb_nblocks_3_port0==$past(reg_arb_nblocks_3_port0))));


//  `ifdef UMCTL2_DUAL_CHANNEL
//      `ifdef UMCTL2_DATA_CHANNEL_INTERLEAVE_EN_1
//         wire data_channel_0 = arb_hif_cmd_addr[reg_ddrc_addrmap_dch_bit0_map0+2];
//         wire data_channel_1 = arb_hif_cmd_addr_dch1[reg_ddrc_addrmap_dch_bit0_map0+2];
//
//         `assert_coreclk(ERROR_DATA_CHANNEL_0, (arb_hif_cmd_valid |-> (data_channel_0==0)));
//         `assert_coreclk(ERROR_DATA_CHANNEL_1, (arb_hif_cmd_valid_dch1 |-> (data_channel_1==1)));
//      `endif
//  `endif


`endif //  `ifndef SYNTHESIS
endmodule // DWC_ddrctl
//spyglass enable_block W528

