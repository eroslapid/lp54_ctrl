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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/dfi_ic_dp_lpddr.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            DFI interconnect - LPDDR data path
`include "DWC_ddrctl_all_defs.svh"
module dfi_ic_dp_lpddr
#(
    parameter     NUM_RANKS                     = `MEMC_NUM_RANKS
   ,parameter     FREQ_RATIO                    = `MEMC_FREQ_RATIO
   ,parameter     DDRC_TOTAL_DATA_WIDTH         = `MEMC_DFI_TOTAL_DATA_WIDTH
   ,parameter     DDRC_TOTAL_DATAEN_WIDTH       = `MEMC_DFI_TOTAL_DATAEN_WIDTH
   ,parameter     DDRC_TOTAL_MASK_WIDTH         = `MEMC_DFI_TOTAL_MASK_WIDTH
   ,parameter     DRAM_TOTAL_DATA_WIDTH         = `MEMC_DRAM_TOTAL_DATA_WIDTH
   ,parameter     NUM_DFI                       = `UMCTL2_NUM_DFI
   ,parameter     DFI_DATA_WIDTH                = `DDRCTL_DFI_DATA_WIDTH
   ,parameter     DFI_MASK_WIDTH                = `DDRCTL_DFI_MASK_WIDTH
   ,parameter     DFI_DATAEN_WIDTH              = `DDRCTL_DFI_DATAEN_WIDTH
   ,parameter     REG_DFI_OUT_VAL               = `MEMC_REG_DFI_OUT_VAL
   ,parameter     OCCAP_EN                      = `UMCTL2_OCCAP_EN
   ,parameter     OCCAP_PIPELINE_EN             = 0
)
(
    input   logic [1:0]                                     reg_ddrc_dfi_channel_mode // 00:Single CH, 01:Dual CH

   ,input   logic                                           core_ddrc_core_clk
   ,input   logic                                           core_ddrc_rstn

   // DDRC0 interface
   ,input   logic [DDRC_TOTAL_DATA_WIDTH-1:0]               dfi_wrdata_dch0
   ,input   logic [DDRC_TOTAL_MASK_WIDTH-1:0]               dfi_wrdata_mask_dch0
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH-1:0]             dfi_wrdata_en_dch0
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH*NUM_RANKS-1:0]   dfi_wrdata_cs_dch0

   ,output  logic [DDRC_TOTAL_DATA_WIDTH-1:0]               dfi_rddata_dch0
   ,output  logic [(DDRC_TOTAL_DATA_WIDTH/8)-1:0]           dfi_rddata_dbi_dch0
   ,output  logic [DDRC_TOTAL_DATAEN_WIDTH-1:0]             dfi_rddata_valid_dch0
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH-1:0]             dfi_rddata_en_dch0
   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH*NUM_RANKS-1:0]   dfi_rddata_cs_dch0

   ,input   logic [DDRC_TOTAL_DATAEN_WIDTH*4-1:0]           dwc_ddrphy_snoop_en_dch0

   // DFI interface
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi0_wrdata_P0_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi0_wrdata_P1_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi0_wrdata_P2_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi0_wrdata_P3_out

   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi0_wrdata_mask_P0_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi0_wrdata_mask_P1_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi0_wrdata_mask_P2_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi0_wrdata_mask_P3_out

   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_wrdata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_wrdata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_wrdata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_wrdata_en_P3_out

   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_wrdata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_wrdata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_wrdata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_wrdata_cs_P3_out


   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi0_rddata_W0_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi0_rddata_W1_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi0_rddata_W2_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi0_rddata_W3_in

   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi0_rddata_dbi_W0_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi0_rddata_dbi_W1_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi0_rddata_dbi_W2_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi0_rddata_dbi_W3_in

   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_valid_W0_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_valid_W1_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_valid_W2_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_valid_W3_in

   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi0_rddata_en_P3_out

   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_rddata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_rddata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_rddata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi0_rddata_cs_P3_out

   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy0_snoop_en_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy0_snoop_en_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy0_snoop_en_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy0_snoop_en_P3_out

   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi1_wrdata_P0_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi1_wrdata_P1_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi1_wrdata_P2_out
   ,output  logic [DFI_DATA_WIDTH-1:0]                      dfi1_wrdata_P3_out

   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi1_wrdata_mask_P0_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi1_wrdata_mask_P1_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi1_wrdata_mask_P2_out
   ,output  logic [DFI_MASK_WIDTH-1:0]                      dfi1_wrdata_mask_P3_out

   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_wrdata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_wrdata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_wrdata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_wrdata_en_P3_out

   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_wrdata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_wrdata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_wrdata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_wrdata_cs_P3_out


   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi1_rddata_W0_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi1_rddata_W1_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi1_rddata_W2_in
   ,input   logic [DFI_DATA_WIDTH-1:0]                      dfi1_rddata_W3_in

   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi1_rddata_dbi_W0_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi1_rddata_dbi_W1_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi1_rddata_dbi_W2_in
   ,input   logic [(DFI_DATA_WIDTH/8)-1:0]                  dfi1_rddata_dbi_W3_in

   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_valid_W0_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_valid_W1_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_valid_W2_in
   ,input   logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_valid_W3_in

   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_en_P0_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_en_P1_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_en_P2_out
   ,output  logic [DFI_DATAEN_WIDTH-1:0]                    dfi1_rddata_en_P3_out

   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_rddata_cs_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_rddata_cs_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_rddata_cs_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]        dfi1_rddata_cs_P3_out

   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy1_snoop_en_P0_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy1_snoop_en_P1_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy1_snoop_en_P2_out
   ,output  logic [(DFI_DATAEN_WIDTH*4)-1:0]                dwc_ddrphy1_snoop_en_P3_out
);

   //--------------------------------------------------------------------------
   // Local Parameters
   //--------------------------------------------------------------------------
   // For LPDDR DFI data
   localparam NUM_DFI_CHNS       = 2;                                      // Fixed by 2 because uMCTL5 always use both dfi0_* and dfi1*_. TODO: This comment is wrong but this is 2 irrespective of the number of DFI
   localparam NUM_DFI_PHASE      = FREQ_RATIO;                             // _P0/1 when MEMC_FREQ_RATIO_2. _P0/1/2/3 when MEMC_FREQ_RATIO_4
   localparam DW_PER_2BYTES      = 16;                                     // PHY spec
   localparam DE_PER_2BYTES      = 1;                                      // PHY spec
   localparam DM_PER_2BYTES      = 2;                                      // PHY spec
   localparam DBI_PER_2BYTES     = 2;                                      // PHY spec
   localparam CS_PER_2BYTES      = NUM_RANKS;                              // PHY spec
   localparam NUM_2BYTES         = DRAM_TOTAL_DATA_WIDTH/DW_PER_2BYTES;    // PHY spec


   //----------------------------------------------------------------------------
   // Signals
   //----------------------------------------------------------------------------
   logic [(NUM_2BYTES * DW_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_merge;
   logic [(NUM_2BYTES * DE_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_en_merge;
   logic [(NUM_2BYTES * DM_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_mask_merge;
   logic [(NUM_2BYTES * CS_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_cs_merge;

   logic [(NUM_2BYTES * DW_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_merge_pre;
   logic [(NUM_2BYTES * DE_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_en_merge_pre;
   logic [(NUM_2BYTES * DM_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_mask_merge_pre;
   logic [(NUM_2BYTES * CS_PER_2BYTES * 2 * 4)-1:0]            dfi_wrdata_cs_merge_pre;

   logic [DFI_DATA_WIDTH-1:0]                                  dfi0_wrdata_P0_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi0_wrdata_P1_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi0_wrdata_P2_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi0_wrdata_P3_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi0_wrdata_mask_P0_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi0_wrdata_mask_P1_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi0_wrdata_mask_P2_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi0_wrdata_mask_P3_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_wrdata_en_P0_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_wrdata_en_P1_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_wrdata_en_P2_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_wrdata_en_P3_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_wrdata_cs_P0_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_wrdata_cs_P1_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_wrdata_cs_P2_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_wrdata_cs_P3_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi1_wrdata_P0_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi1_wrdata_P1_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi1_wrdata_P2_w;
   logic [DFI_DATA_WIDTH-1:0]                                  dfi1_wrdata_P3_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi1_wrdata_mask_P0_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi1_wrdata_mask_P1_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi1_wrdata_mask_P2_w;
   logic [DFI_MASK_WIDTH-1:0]                                  dfi1_wrdata_mask_P3_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_wrdata_en_P0_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_wrdata_en_P1_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_wrdata_en_P2_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_wrdata_en_P3_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_wrdata_cs_P0_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_wrdata_cs_P1_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_wrdata_cs_P2_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_wrdata_cs_P3_w;

   logic [(NUM_2BYTES * DE_PER_2BYTES * 2 * 4)-1:0]            dfi_rddata_en_merge;
   logic [(NUM_2BYTES * CS_PER_2BYTES * 2 * 4)-1:0]            dfi_rddata_cs_merge;

   logic [(NUM_2BYTES * DE_PER_2BYTES * 2 * 4)-1:0]            dfi_rddata_en_merge_pre;
   logic [(NUM_2BYTES * CS_PER_2BYTES * 2 * 4)-1:0]            dfi_rddata_cs_merge_pre;

   logic [((NUM_2BYTES * DW_PER_2BYTES ) * 2 * 4)-1:0]         dfi_rddata_merge_pre;
   logic [((NUM_2BYTES * DE_PER_2BYTES ) * 2 * 4)-1:0]         dfi_rddata_valid_merge_pre;
   logic [((NUM_2BYTES * DBI_PER_2BYTES) * 2 * 4)-1:0]         dfi_rddata_dbi_merge_pre;

   logic [((NUM_2BYTES * DW_PER_2BYTES ) * 2 * 4)-1:0]         dfi_rddata_merge;
   logic [((NUM_2BYTES * DE_PER_2BYTES ) * 2 * 4)-1:0]         dfi_rddata_valid_merge;
   logic [((NUM_2BYTES * DBI_PER_2BYTES) * 2 * 4)-1:0]         dfi_rddata_dbi_merge;

   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_rddata_en_P0_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_rddata_en_P1_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_rddata_en_P2_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi0_rddata_en_P3_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_rddata_cs_P0_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_rddata_cs_P1_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_rddata_cs_P2_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi0_rddata_cs_P3_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy0_snoop_en_P0_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy0_snoop_en_P1_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy0_snoop_en_P2_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy0_snoop_en_P3_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_rddata_en_P0_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_rddata_en_P1_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_rddata_en_P2_w;
   logic [DFI_DATAEN_WIDTH-1:0]                                dfi1_rddata_en_P3_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_rddata_cs_P0_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_rddata_cs_P1_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_rddata_cs_P2_w;
   logic [(DFI_DATAEN_WIDTH*NUM_RANKS)-1:0]                    dfi1_rddata_cs_P3_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy1_snoop_en_P0_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy1_snoop_en_P1_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy1_snoop_en_P2_w;
   logic [(DFI_DATAEN_WIDTH*4)-1:0]                            dwc_ddrphy1_snoop_en_P3_w;


   //----------------------------------------------------------------------------
   // Circuit Description
   //----------------------------------------------------------------------------
   //-------------------------------------------
   // Write Data Interface
   //-------------------------------------------
   assign dfi_wrdata_merge_pre      = {{ ( (4 - NUM_DFI_PHASE) * 2 * NUM_2BYTES * DW_PER_2BYTES) {1'b0}}, dfi_wrdata_dch0};
   assign dfi_wrdata_en_merge_pre   = {{ ( (4 - NUM_DFI_PHASE) * 2 * NUM_2BYTES * DE_PER_2BYTES) {1'b0}}, dfi_wrdata_en_dch0};
   assign dfi_wrdata_mask_merge_pre = {{ ( (4 - NUM_DFI_PHASE) * 2 * NUM_2BYTES * DM_PER_2BYTES) {1'b0}}, dfi_wrdata_mask_dch0};
   assign dfi_wrdata_cs_merge_pre   = {{ ( (4 - NUM_DFI_PHASE) * 2 * NUM_2BYTES * CS_PER_2BYTES) {1'b0}}, dfi_wrdata_cs_dch0};
   generate
      for (genvar dfi_ch = 0; dfi_ch < NUM_DFI_CHNS; dfi_ch++) begin
         for (genvar phase = 0; phase < 4; phase++) begin
            for (genvar num_2byte= 0; num_2byte < NUM_2BYTES; num_2byte++) begin
               always_comb begin
                  if (reg_ddrc_dfi_channel_mode == 2'b00) begin
                     dfi_wrdata_merge           [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DW_PER_2BYTES +: DW_PER_2BYTES] =
                     dfi_wrdata_merge_pre       [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DW_PER_2BYTES +: DW_PER_2BYTES];
                     dfi_wrdata_en_merge        [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                     dfi_wrdata_en_merge_pre    [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DE_PER_2BYTES +: DE_PER_2BYTES];
                     dfi_wrdata_mask_merge      [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DM_PER_2BYTES +: DM_PER_2BYTES] =
                     dfi_wrdata_mask_merge_pre  [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DM_PER_2BYTES +: DM_PER_2BYTES];
                     dfi_wrdata_cs_merge        [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * CS_PER_2BYTES +: CS_PER_2BYTES] =
                     dfi_wrdata_cs_merge_pre    [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * CS_PER_2BYTES +: CS_PER_2BYTES];
                  end else begin
                     if (num_2byte < NUM_2BYTES/2) begin
                        dfi_wrdata_merge          [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DW_PER_2BYTES +: DW_PER_2BYTES] =
                        dfi_wrdata_merge_pre      [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DW_PER_2BYTES +: DW_PER_2BYTES];
                        dfi_wrdata_en_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                        dfi_wrdata_en_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES];
                        dfi_wrdata_mask_merge     [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DM_PER_2BYTES +: DM_PER_2BYTES] =
                        dfi_wrdata_mask_merge_pre [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DM_PER_2BYTES +: DM_PER_2BYTES];
                        dfi_wrdata_cs_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * CS_PER_2BYTES +: CS_PER_2BYTES] =
                        dfi_wrdata_cs_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )) * CS_PER_2BYTES +: CS_PER_2BYTES];
                     end else begin
                        dfi_wrdata_merge          [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DW_PER_2BYTES +: DW_PER_2BYTES] =
                        dfi_wrdata_merge_pre      [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )  +
                                                    (                NUM_2BYTES/2)) * DW_PER_2BYTES +: DW_PER_2BYTES];
                        dfi_wrdata_en_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                        dfi_wrdata_en_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )  +
                                                    (                NUM_2BYTES/2)) * DE_PER_2BYTES +: DE_PER_2BYTES];
                        dfi_wrdata_mask_merge     [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DM_PER_2BYTES +: DM_PER_2BYTES] =
                        dfi_wrdata_mask_merge_pre [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )  +
                                                    (                NUM_2BYTES/2)) * DM_PER_2BYTES +: DM_PER_2BYTES];
                        dfi_wrdata_cs_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * CS_PER_2BYTES +: CS_PER_2BYTES] =
                        dfi_wrdata_cs_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )  +
                                                    (                NUM_2BYTES/2)) * CS_PER_2BYTES +: CS_PER_2BYTES];
                     end // num_2bytes
                  end // reg_ddrc_dfi_channel_mode
               end // always_comb
            end // NUM_2BYTES
         end // NUM_DFI_PHASE
      end // NUM_DFI_CHNS
   endgenerate

//----------------------------------------------------------------------------
//  LPDDR54 Single DDRC Dual DFI (x16 SDRAM x 2 channels: 32-bit in total)
//----------------------------------------------------------------------------
   assign dfi1_wrdata_P3_w          = dfi_wrdata_merge      [ 7 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi1_wrdata_P2_w          = dfi_wrdata_merge      [ 6 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi1_wrdata_P1_w          = dfi_wrdata_merge      [ 5 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi1_wrdata_P0_w          = dfi_wrdata_merge      [ 4 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi0_wrdata_P3_w          = dfi_wrdata_merge      [ 3 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi0_wrdata_P2_w          = dfi_wrdata_merge      [ 2 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi0_wrdata_P1_w          = dfi_wrdata_merge      [ 1 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];
   assign dfi0_wrdata_P0_w          = dfi_wrdata_merge      [ 0 * NUM_2BYTES * DW_PER_2BYTES +: NUM_2BYTES *DW_PER_2BYTES];

   assign dfi1_wrdata_en_P3_w       = dfi_wrdata_en_merge   [ 7 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi1_wrdata_en_P2_w       = dfi_wrdata_en_merge   [ 6 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi1_wrdata_en_P1_w       = dfi_wrdata_en_merge   [ 5 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi1_wrdata_en_P0_w       = dfi_wrdata_en_merge   [ 4 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi0_wrdata_en_P3_w       = dfi_wrdata_en_merge   [ 3 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi0_wrdata_en_P2_w       = dfi_wrdata_en_merge   [ 2 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi0_wrdata_en_P1_w       = dfi_wrdata_en_merge   [ 1 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];
   assign dfi0_wrdata_en_P0_w       = dfi_wrdata_en_merge   [ 0 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES *DE_PER_2BYTES];

   assign dfi1_wrdata_mask_P3_w     = dfi_wrdata_mask_merge [ 7 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi1_wrdata_mask_P2_w     = dfi_wrdata_mask_merge [ 6 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi1_wrdata_mask_P1_w     = dfi_wrdata_mask_merge [ 5 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi1_wrdata_mask_P0_w     = dfi_wrdata_mask_merge [ 4 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi0_wrdata_mask_P3_w     = dfi_wrdata_mask_merge [ 3 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi0_wrdata_mask_P2_w     = dfi_wrdata_mask_merge [ 2 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi0_wrdata_mask_P1_w     = dfi_wrdata_mask_merge [ 1 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];
   assign dfi0_wrdata_mask_P0_w     = dfi_wrdata_mask_merge [ 0 * NUM_2BYTES * DM_PER_2BYTES +: NUM_2BYTES *DM_PER_2BYTES];

   assign dfi1_wrdata_cs_P3_w       = dfi_wrdata_cs_merge   [ 7 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi1_wrdata_cs_P2_w       = dfi_wrdata_cs_merge   [ 6 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi1_wrdata_cs_P1_w       = dfi_wrdata_cs_merge   [ 5 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi1_wrdata_cs_P0_w       = dfi_wrdata_cs_merge   [ 4 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi0_wrdata_cs_P3_w       = dfi_wrdata_cs_merge   [ 3 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi0_wrdata_cs_P2_w       = dfi_wrdata_cs_merge   [ 2 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi0_wrdata_cs_P1_w       = dfi_wrdata_cs_merge   [ 1 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];
   assign dfi0_wrdata_cs_P0_w       = dfi_wrdata_cs_merge   [ 0 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES *CS_PER_2BYTES];

   always_ff @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) begin
         dfi0_wrdata_P0_out            <= '0;
         dfi0_wrdata_P1_out            <= '0;
         dfi0_wrdata_P2_out            <= '0;
         dfi0_wrdata_P3_out            <= '0;
         dfi0_wrdata_mask_P0_out       <= '0;
         dfi0_wrdata_mask_P1_out       <= '0;
         dfi0_wrdata_mask_P2_out       <= '0;
         dfi0_wrdata_mask_P3_out       <= '0;
         dfi1_wrdata_P0_out            <= '0;
         dfi1_wrdata_P1_out            <= '0;
         dfi1_wrdata_P2_out            <= '0;
         dfi1_wrdata_P3_out            <= '0;
         dfi1_wrdata_mask_P0_out       <= '0;
         dfi1_wrdata_mask_P1_out       <= '0;
         dfi1_wrdata_mask_P2_out       <= '0;
         dfi1_wrdata_mask_P3_out       <= '0;
         dfi0_wrdata_en_P0_out         <= '0;
         dfi0_wrdata_en_P1_out         <= '0;
         dfi0_wrdata_en_P2_out         <= '0;
         dfi0_wrdata_en_P3_out         <= '0;
         dfi0_wrdata_cs_P0_out         <= '0;
         dfi0_wrdata_cs_P1_out         <= '0;
         dfi0_wrdata_cs_P2_out         <= '0;
         dfi0_wrdata_cs_P3_out         <= '0;
         dfi1_wrdata_en_P0_out         <= '0;
         dfi1_wrdata_en_P1_out         <= '0;
         dfi1_wrdata_en_P2_out         <= '0;
         dfi1_wrdata_en_P3_out         <= '0;
         dfi1_wrdata_cs_P0_out         <= '0;
         dfi1_wrdata_cs_P1_out         <= '0;
         dfi1_wrdata_cs_P2_out         <= '0;
         dfi1_wrdata_cs_P3_out         <= '0;
      end else begin
         dfi0_wrdata_P0_out            <= dfi0_wrdata_P0_w;
         dfi0_wrdata_P1_out            <= dfi0_wrdata_P1_w;
         dfi0_wrdata_P2_out            <= dfi0_wrdata_P2_w;
         dfi0_wrdata_P3_out            <= dfi0_wrdata_P3_w;
         dfi0_wrdata_mask_P0_out       <= dfi0_wrdata_mask_P0_w;
         dfi0_wrdata_mask_P1_out       <= dfi0_wrdata_mask_P1_w;
         dfi0_wrdata_mask_P2_out       <= dfi0_wrdata_mask_P2_w;
         dfi0_wrdata_mask_P3_out       <= dfi0_wrdata_mask_P3_w;
         dfi1_wrdata_P0_out            <= dfi1_wrdata_P0_w;
         dfi1_wrdata_P1_out            <= dfi1_wrdata_P1_w;
         dfi1_wrdata_P2_out            <= dfi1_wrdata_P2_w;
         dfi1_wrdata_P3_out            <= dfi1_wrdata_P3_w;
         dfi1_wrdata_mask_P0_out       <= dfi1_wrdata_mask_P0_w;
         dfi1_wrdata_mask_P1_out       <= dfi1_wrdata_mask_P1_w;
         dfi1_wrdata_mask_P2_out       <= dfi1_wrdata_mask_P2_w;
         dfi1_wrdata_mask_P3_out       <= dfi1_wrdata_mask_P3_w;
         dfi0_wrdata_en_P0_out         <= dfi0_wrdata_en_P0_w;
         dfi0_wrdata_en_P1_out         <= dfi0_wrdata_en_P1_w;
         dfi0_wrdata_en_P2_out         <= dfi0_wrdata_en_P2_w;
         dfi0_wrdata_en_P3_out         <= dfi0_wrdata_en_P3_w;
         dfi0_wrdata_cs_P0_out         <= dfi0_wrdata_cs_P0_w;
         dfi0_wrdata_cs_P1_out         <= dfi0_wrdata_cs_P1_w;
         dfi0_wrdata_cs_P2_out         <= dfi0_wrdata_cs_P2_w;
         dfi0_wrdata_cs_P3_out         <= dfi0_wrdata_cs_P3_w;
         dfi1_wrdata_en_P0_out         <= dfi1_wrdata_en_P0_w;
         dfi1_wrdata_en_P1_out         <= dfi1_wrdata_en_P1_w;
         dfi1_wrdata_en_P2_out         <= dfi1_wrdata_en_P2_w;
         dfi1_wrdata_en_P3_out         <= dfi1_wrdata_en_P3_w;
         dfi1_wrdata_cs_P0_out         <= dfi1_wrdata_cs_P0_w;
         dfi1_wrdata_cs_P1_out         <= dfi1_wrdata_cs_P1_w;
         dfi1_wrdata_cs_P2_out         <= dfi1_wrdata_cs_P2_w;
         dfi1_wrdata_cs_P3_out         <= dfi1_wrdata_cs_P3_w;
      end
   end


   //-------------------------------------------
   // Read Data Interface
   //-------------------------------------------
   assign dfi_rddata_en_merge_pre   = {{ ( (4 - NUM_DFI_PHASE) * 2 * NUM_2BYTES * DE_PER_2BYTES) {1'b0}}, dfi_rddata_en_dch0};
   assign dfi_rddata_cs_merge_pre   = {{ ( (4 - NUM_DFI_PHASE) * 2 * NUM_2BYTES * CS_PER_2BYTES) {1'b0}}, dfi_rddata_cs_dch0};
   generate
      for (genvar dfi_ch = 0; dfi_ch < NUM_DFI_CHNS; dfi_ch++) begin
         for (genvar phase = 0; phase < 4; phase++) begin
            for (genvar num_2byte= 0; num_2byte < NUM_2BYTES; num_2byte++) begin
               always_comb begin
                  if (reg_ddrc_dfi_channel_mode == 2'b00) begin
                     dfi_rddata_en_merge        [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                     dfi_rddata_en_merge_pre    [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * DE_PER_2BYTES +: DE_PER_2BYTES];
                     dfi_rddata_cs_merge        [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * CS_PER_2BYTES +: CS_PER_2BYTES] =
                     dfi_rddata_cs_merge_pre    [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase      *     NUM_2BYTES)  +
                                                  (num_2byte                  )) * CS_PER_2BYTES +: CS_PER_2BYTES];
                  end else begin
                     if (num_2byte < NUM_2BYTES/2) begin
                        dfi_rddata_en_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                        dfi_rddata_en_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES];
                        dfi_rddata_cs_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * CS_PER_2BYTES +: CS_PER_2BYTES] =
                        dfi_rddata_cs_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )) * CS_PER_2BYTES +: CS_PER_2BYTES];
                     end else begin
                        dfi_rddata_en_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                        dfi_rddata_en_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )  +
                                                    (                NUM_2BYTES/2)) * DE_PER_2BYTES +: DE_PER_2BYTES];
                        dfi_rddata_cs_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES  )  +
                                                    (num_2byte                   )) * CS_PER_2BYTES +: CS_PER_2BYTES] =
                        dfi_rddata_cs_merge_pre   [((dfi_ch    *     NUM_2BYTES/2)  +
                                                    (phase     * 2 * NUM_2BYTES  )  +
                                                    (num_2byte                   )  +
                                                    (                NUM_2BYTES/2)) * CS_PER_2BYTES +: CS_PER_2BYTES];
                     end // num_2bytes
                  end // reg_ddrc_dfi_channel_mode
               end // always_comb
            end // NUM_2BYTES
         end // NUM_DFI_PHASE
      end // NUM_DFI_CHNS
   endgenerate

   generate
      for (genvar dfi_ch = 0; dfi_ch < NUM_DFI_CHNS; dfi_ch++) begin
         for (genvar phase = 0; phase < 4; phase++) begin
            for (genvar  num_2byte= 0; num_2byte < NUM_2BYTES; num_2byte++) begin
               always_comb begin
                  if (reg_ddrc_dfi_channel_mode == 2'b00) begin
                     dfi_rddata_merge            [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                   (phase      *     NUM_2BYTES)  +
                                                   (num_2byte                  )) * DW_PER_2BYTES +: DW_PER_2BYTES] =
                     dfi_rddata_merge_pre        [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                   (phase      *     NUM_2BYTES)  +
                                                   (num_2byte                  )) * DW_PER_2BYTES +: DW_PER_2BYTES];
                     dfi_rddata_valid_merge      [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                  (phase       *     NUM_2BYTES)  +
                                                  (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                     dfi_rddata_valid_merge_pre  [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                   (phase      *     NUM_2BYTES)  +
                                                   (num_2byte                  )) * DE_PER_2BYTES +: DE_PER_2BYTES];
                     dfi_rddata_dbi_merge        [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                   (phase      *     NUM_2BYTES)  +
                                                   (num_2byte                  )) * DBI_PER_2BYTES +: DBI_PER_2BYTES] =
                     dfi_rddata_dbi_merge_pre    [((dfi_ch     * 4 * NUM_2BYTES)  +
                                                   (phase      *     NUM_2BYTES)  +
                                                   (num_2byte                  )) * DBI_PER_2BYTES +: DBI_PER_2BYTES];
                  end else begin
                     if (num_2byte < NUM_2BYTES/2) begin
                        dfi_rddata_merge           [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES  )  +
                                                     (num_2byte                   )) * DW_PER_2BYTES +: DW_PER_2BYTES] =
                        dfi_rddata_merge_pre       [((dfi_ch    * 2 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES/2)  +
                                                     (num_2byte                   )) * DW_PER_2BYTES +: DW_PER_2BYTES];
                        dfi_rddata_valid_merge     [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES  )  +
                                                     (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                        dfi_rddata_valid_merge_pre [((dfi_ch    * 2 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES/2)  +
                                                     (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES];
                        dfi_rddata_dbi_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES  )  +
                                                     (num_2byte                   )) * DBI_PER_2BYTES +: DBI_PER_2BYTES] =
                        dfi_rddata_dbi_merge_pre   [((dfi_ch    * 2 * NUM_2BYTES  )  +
                                                    (phase     *     NUM_2BYTES/2)  +
                                                    (num_2byte                   )) * DBI_PER_2BYTES +: DBI_PER_2BYTES];
                     end else begin
                        dfi_rddata_merge           [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES  )  +
                                                     (num_2byte                   )) * DW_PER_2BYTES +: DW_PER_2BYTES] =
                        dfi_rddata_merge_pre       [((dfi_ch    * 2 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES/2)  +
                                                     (num_2byte -     NUM_2BYTES/2)  +
                                                     (4         *     NUM_2BYTES  )) * DW_PER_2BYTES+: DW_PER_2BYTES];
                        dfi_rddata_valid_merge     [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES  )  +
                                                     (num_2byte                   )) * DE_PER_2BYTES +: DE_PER_2BYTES] =
                        dfi_rddata_valid_merge_pre [((dfi_ch    * 2 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES/2)  +
                                                     (num_2byte -     NUM_2BYTES/2)  +
                                                     (4         *     NUM_2BYTES  )) * DE_PER_2BYTES+: DE_PER_2BYTES];
                        dfi_rddata_dbi_merge       [((dfi_ch    * 4 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES  )  +
                                                     (num_2byte                   )) * DBI_PER_2BYTES +: DBI_PER_2BYTES] =
                        dfi_rddata_dbi_merge_pre   [((dfi_ch    * 2 * NUM_2BYTES  )  +
                                                     (phase     *     NUM_2BYTES/2)  +
                                                     (num_2byte -     NUM_2BYTES/2)  +
                                                     (4         *     NUM_2BYTES  )) * DBI_PER_2BYTES+: DBI_PER_2BYTES];
                     end
                  end // reg_ddrc_dfi_channel_mode
               end // always_comb
            end // NUM_2BYTES
         end // NUM_DFI_PHASE
      end // NUM_DFI_CHNS
   endgenerate

   assign dfi_rddata_dch0        = dfi_rddata_merge        [(NUM_2BYTES * DW_PER_2BYTES * 2 * NUM_DFI_PHASE) - 1 : 0];
   assign dfi_rddata_valid_dch0  = dfi_rddata_valid_merge  [(NUM_2BYTES * DE_PER_2BYTES * 2 * NUM_DFI_PHASE) - 1 : 0];
   assign dfi_rddata_dbi_dch0    = dfi_rddata_dbi_merge    [(NUM_2BYTES * DBI_PER_2BYTES * 2 * NUM_DFI_PHASE) - 1 : 0];

//----------------------------------------------------------------------------
//  LPDDR54 Single DDRC Dual DFI (x16 SDRAM x 2 channels: 32-bit in total)
//----------------------------------------------------------------------------
   assign dfi1_rddata_en_P3_w    = dfi_rddata_en_merge [ 7 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi1_rddata_en_P2_w    = dfi_rddata_en_merge [ 6 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi1_rddata_en_P1_w    = dfi_rddata_en_merge [ 5 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi1_rddata_en_P0_w    = dfi_rddata_en_merge [ 4 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi0_rddata_en_P3_w    = dfi_rddata_en_merge [ 3 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi0_rddata_en_P2_w    = dfi_rddata_en_merge [ 2 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi0_rddata_en_P1_w    = dfi_rddata_en_merge [ 1 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];
   assign dfi0_rddata_en_P0_w    = dfi_rddata_en_merge [ 0 * NUM_2BYTES * DE_PER_2BYTES +: NUM_2BYTES * DE_PER_2BYTES];

   assign dfi1_rddata_cs_P3_w    = dfi_rddata_cs_merge [ 7 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi1_rddata_cs_P2_w    = dfi_rddata_cs_merge [ 6 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi1_rddata_cs_P1_w    = dfi_rddata_cs_merge [ 5 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi1_rddata_cs_P0_w    = dfi_rddata_cs_merge [ 4 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi0_rddata_cs_P3_w    = dfi_rddata_cs_merge [ 3 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi0_rddata_cs_P2_w    = dfi_rddata_cs_merge [ 2 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi0_rddata_cs_P1_w    = dfi_rddata_cs_merge [ 1 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];
   assign dfi0_rddata_cs_P0_w    = dfi_rddata_cs_merge [ 0 * NUM_2BYTES * CS_PER_2BYTES +: NUM_2BYTES * CS_PER_2BYTES];

   assign dfi_rddata_merge_pre         = {
                                          dfi1_rddata_W3_in, // DFI_DATA_WIDTH = 16
                                          dfi1_rddata_W2_in, // DFI_DATA_WIDTH = 16  
                                          dfi1_rddata_W1_in, // DFI_DATA_WIDTH = 16
                                          dfi1_rddata_W0_in, // DFI_DATA_WIDTH = 16  
                                          dfi0_rddata_W3_in, // DFI_DATA_WIDTH = 16  
                                          dfi0_rddata_W2_in, // DFI_DATA_WIDTH = 16  
                                          dfi0_rddata_W1_in, // DFI_DATA_WIDTH = 16  
                                          dfi0_rddata_W0_in  // DFI_DATA_WIDTH = 16  
                                       };
   assign dfi_rddata_valid_merge_pre   = {
                                          dfi1_rddata_valid_W3_in,
                                          dfi1_rddata_valid_W2_in,
                                          dfi1_rddata_valid_W1_in,
                                          dfi1_rddata_valid_W0_in,
                                          dfi0_rddata_valid_W3_in,
                                          dfi0_rddata_valid_W2_in,
                                          dfi0_rddata_valid_W1_in,
                                          dfi0_rddata_valid_W0_in
                                       };
   assign dfi_rddata_dbi_merge_pre     = {
                                          dfi1_rddata_dbi_W3_in,
                                          dfi1_rddata_dbi_W2_in,
                                          dfi1_rddata_dbi_W1_in,
                                          dfi1_rddata_dbi_W0_in,
                                          dfi0_rddata_dbi_W3_in,
                                          dfi0_rddata_dbi_W2_in,
                                          dfi0_rddata_dbi_W1_in,
                                          dfi0_rddata_dbi_W0_in
                                       };


   //-------------------------------------------
   // Non-DFI uMCTL2 PHY Sideband Interface
   //-------------------------------------------
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(2 * (DW_PER_PHASE*4))' found in module 'dfi_ic'
//SJ: This coding style is acceptable and there is no plan to change it
   always_comb begin
   //----------------------------------------------------------------------------
   //  LPDDR54 Single DDRC Dual DFI (x16 SDRAM x 2 channels: 32-bit in total)
   //----------------------------------------------------------------------------
      if (reg_ddrc_dfi_channel_mode == 2'b00) begin
         // Case in LPDDR4x mPHY TODO: That PHY does not have "snoop_en" I/O, so these lines can be deleted
         dwc_ddrphy1_snoop_en_P3_w     =  dwc_ddrphy_snoop_en_dch0[ 7 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy1_snoop_en_P2_w     =  dwc_ddrphy_snoop_en_dch0[ 6 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy1_snoop_en_P1_w     =  dwc_ddrphy_snoop_en_dch0[ 5 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy1_snoop_en_P0_w     =  dwc_ddrphy_snoop_en_dch0[ 4 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy0_snoop_en_P3_w     =  dwc_ddrphy_snoop_en_dch0[ 3 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy0_snoop_en_P2_w     =  dwc_ddrphy_snoop_en_dch0[ 2 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy0_snoop_en_P1_w     =  dwc_ddrphy_snoop_en_dch0[ 1 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
         dwc_ddrphy0_snoop_en_P0_w     =  dwc_ddrphy_snoop_en_dch0[ 0 * (NUM_2BYTES * DE_PER_2BYTES * 4)   +: (NUM_2BYTES * DE_PER_2BYTES * 4)  ];
      end else begin
         // Case in LPDDR5/4 PHY
         dwc_ddrphy1_snoop_en_P3_w     = {dwc_ddrphy_snoop_en_dch0[15 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[14 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy0_snoop_en_P3_w     = {dwc_ddrphy_snoop_en_dch0[13 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[12 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy1_snoop_en_P2_w     = {dwc_ddrphy_snoop_en_dch0[11 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[10 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy0_snoop_en_P2_w     = {dwc_ddrphy_snoop_en_dch0[ 9 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[ 8 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy1_snoop_en_P1_w     = {dwc_ddrphy_snoop_en_dch0[ 7 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[ 6 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy0_snoop_en_P1_w     = {dwc_ddrphy_snoop_en_dch0[ 5 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[ 4 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy1_snoop_en_P0_w     = {dwc_ddrphy_snoop_en_dch0[ 3 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[ 2 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
         dwc_ddrphy0_snoop_en_P0_w     = {dwc_ddrphy_snoop_en_dch0[ 1 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2],
                                          dwc_ddrphy_snoop_en_dch0[ 0 * (NUM_2BYTES * DE_PER_2BYTES * 4)/2 +: (NUM_2BYTES * DE_PER_2BYTES * 4)/2]};
      end
   end
//spyglass enable_block SelfDeterminedExpr-ML

   always_ff @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) begin
         dfi0_rddata_en_P0_out         <= '0;
         dfi0_rddata_en_P1_out         <= '0;
         dfi0_rddata_en_P2_out         <= '0;
         dfi0_rddata_en_P3_out         <= '0;
         dfi0_rddata_cs_P0_out         <= '0;
         dfi0_rddata_cs_P1_out         <= '0;
         dfi0_rddata_cs_P2_out         <= '0;
         dfi0_rddata_cs_P3_out         <= '0;
         dwc_ddrphy0_snoop_en_P0_out   <= '0;
         dwc_ddrphy0_snoop_en_P1_out   <= '0;
         dwc_ddrphy0_snoop_en_P2_out   <= '0;
         dwc_ddrphy0_snoop_en_P3_out   <= '0;
         dfi1_rddata_en_P0_out         <= '0;
         dfi1_rddata_en_P1_out         <= '0;
         dfi1_rddata_en_P2_out         <= '0;
         dfi1_rddata_en_P3_out         <= '0;
         dfi1_rddata_cs_P0_out         <= '0;
         dfi1_rddata_cs_P1_out         <= '0;
         dfi1_rddata_cs_P2_out         <= '0;
         dfi1_rddata_cs_P3_out         <= '0;
         dwc_ddrphy1_snoop_en_P0_out   <= '0;
         dwc_ddrphy1_snoop_en_P1_out   <= '0;
         dwc_ddrphy1_snoop_en_P2_out   <= '0;
         dwc_ddrphy1_snoop_en_P3_out   <= '0;
      end else begin
         dfi0_rddata_en_P0_out         <= dfi0_rddata_en_P0_w;
         dfi0_rddata_en_P1_out         <= dfi0_rddata_en_P1_w;
         dfi0_rddata_en_P2_out         <= dfi0_rddata_en_P2_w;
         dfi0_rddata_en_P3_out         <= dfi0_rddata_en_P3_w;
         dfi0_rddata_cs_P0_out         <= dfi0_rddata_cs_P0_w;
         dfi0_rddata_cs_P1_out         <= dfi0_rddata_cs_P1_w;
         dfi0_rddata_cs_P2_out         <= dfi0_rddata_cs_P2_w;
         dfi0_rddata_cs_P3_out         <= dfi0_rddata_cs_P3_w;
         dwc_ddrphy0_snoop_en_P0_out   <= dwc_ddrphy0_snoop_en_P0_w;
         dwc_ddrphy0_snoop_en_P1_out   <= dwc_ddrphy0_snoop_en_P1_w;
         dwc_ddrphy0_snoop_en_P2_out   <= dwc_ddrphy0_snoop_en_P2_w;
         dwc_ddrphy0_snoop_en_P3_out   <= dwc_ddrphy0_snoop_en_P3_w;
         dfi1_rddata_en_P0_out         <= dfi1_rddata_en_P0_w;
         dfi1_rddata_en_P1_out         <= dfi1_rddata_en_P1_w;
         dfi1_rddata_en_P2_out         <= dfi1_rddata_en_P2_w;
         dfi1_rddata_en_P3_out         <= dfi1_rddata_en_P3_w;
         dfi1_rddata_cs_P0_out         <= dfi1_rddata_cs_P0_w;
         dfi1_rddata_cs_P1_out         <= dfi1_rddata_cs_P1_w;
         dfi1_rddata_cs_P2_out         <= dfi1_rddata_cs_P2_w;
         dfi1_rddata_cs_P3_out         <= dfi1_rddata_cs_P3_w;
         dwc_ddrphy1_snoop_en_P0_out   <= dwc_ddrphy1_snoop_en_P0_w;
         dwc_ddrphy1_snoop_en_P1_out   <= dwc_ddrphy1_snoop_en_P1_w;
         dwc_ddrphy1_snoop_en_P2_out   <= dwc_ddrphy1_snoop_en_P2_w;
         dwc_ddrphy1_snoop_en_P3_out   <= dwc_ddrphy1_snoop_en_P3_w;
      end
   end


endmodule : dfi_ic_dp_lpddr
