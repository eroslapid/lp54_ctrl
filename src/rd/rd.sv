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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/rd/rd.sv#2 $
// -------------------------------------------------------------------------
// Description:
//===========================================================================
//
//                Read Data (RD) unit.  This block is responsible for handling
//                all ECC checking and correcting on read response data.
//                Data is then passed to the write update engine and the
//                response assembler.  This block is fully combinatorial.
//                All outputs from this block are qualified by a valid
//                indicator from the response tracker. 
//
//                Supports 64-bit core data bus width (1-lane ECC)
//                PHY-DDRC data width is 80-bits - this contains 64-bits data, 8-bit SECDED ECC, and 8 dummy bits
//                Dummy bits are removed before giving the data to the ECC decode engine
//
//===========================================================================
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module rd 
import DWC_ddrctl_reg_pkg::*;
#(
    parameter CMD_LEN_BITS        = 1
   ,parameter PHY_DATA_WIDTH      = 288                  // width of data to/from PHY (2x the DQ bus)
   ,parameter PHY_DBI_WIDTH       = 18                   // width of data mask bits from the PHY
   ,parameter CORE_DATA_WIDTH     = 256                  // data width to/from core logic
   ,parameter RMW_TYPE_BITS       = 2                    // 2-bit read-modify-write type.  See ddrc_parameters.v for encodings
   ,parameter RA_INFO_WIDTH       = 47                   // width of bits from RT to be passed through to RA
   ,parameter ECC_INFO_WIDTH      = 35                   // width of read info from RT to be passed
   ,parameter CRC_INFO_WIDTH      = 35                   // width of read info from RT to be passed

   ,parameter WU_INFO_WIDTH       = 47                   // width of bits from RT to be passed through to WU
  
   ,parameter BT_BITS             = 4 // Override
   ,parameter BRT_BITS            = 4 // Override
   ,parameter ECC_RAM_DEPTH         = `MEMC_ECC_RAM_DEPTH
   ,parameter ECC_RAM_ADDR_BITS     = `log2(ECC_RAM_DEPTH)
   ,parameter ECC_ERR_RAM_WIDTH      = 16 //MEMC_WRDATA_CYCLES*SECDED_LANES;
   
   ,parameter OCPAR_EN            = 0
   ,parameter CORE_MASK_WIDTH     = `MEMC_DFI_DATA_WIDTH/8
   
   ,parameter OCECC_EN            = 0
   ,parameter OCECC_XPI_RD_GRANU  = 64
   ,parameter OCECC_MR_RD_GRANU   = 8
   ,parameter OCECC_MR_BNUM_WIDTH = 5
   ,parameter UMCTL2_WDATARAM_PAR_DW = 40
   
   ,parameter RANK_BITS           = `MEMC_RANK_BITS
   ,parameter LRANK_BITS          = `UMCTL2_LRANK_BITS
   ,parameter CID_WIDTH           = `UMCTL2_CID_WIDTH
   ,parameter BG_BITS             = `MEMC_BG_BITS
   ,parameter BANK_BITS           = `MEMC_BANK_BITS
   ,parameter BG_BANK_BITS        = `MEMC_BG_BANK_BITS
   ,parameter ROW_BITS            = `MEMC_PAGE_BITS
   ,parameter WORD_BITS           = `MEMC_WORD_BITS      // address a word within a burst
   ,parameter BLK_BITS            = `MEMC_BLK_BITS       // 2 column bits are critical word
   ,parameter COL_BITS            = WORD_BITS + BLK_BITS
   
   ,parameter CORE_ECC_WIDTH      = `MEMC_DFI_ECC_WIDTH

   ,parameter SECDED_1B_LANE_WIDTH    = `MEMC_ECC_SYNDROME_WIDTH_RD    // width of a single SEC/DED lane
                                                   // (that is one single-error-correcting / double-error-detecting unit)
   ,parameter ECC_LANE_WIDTH_1B       = `MEMC_SECDED_ECC_WIDTH_BITS  // # of error-correction bits
   ,parameter SECDED_CORESIDE_LANE_WIDTH = `MEMC_DRAM_DATA_WIDTH//width of SECDED lane after error correction
   ,parameter SECDED_LANES            = `MEMC_DFI_TOTAL_DATA_WIDTH / SECDED_1B_LANE_WIDTH
   ,parameter ECC_BITS                = SECDED_LANES*ECC_LANE_WIDTH_1B         // width of all ECC bits

   // widths used for some outputs of rd that would be
   // [X-1:0]=>[-1:0]
   // wide otherwise as X=0 sometimes
   ,parameter       RANK_BITS_DUP   = `MEMC_RANK_BITS
   ,parameter       BG_BITS_DUP     = `MEMC_BG_BITS
   ,parameter       CID_WIDTH_DUP   = `UMCTL2_CID_WIDTH
   ,parameter       CORE_ECC_WIDTH_DUP = `MEMC_DFI_ECC_WIDTH

   ,parameter       SECDED_LANES_DUP = (SECDED_LANES==0) ? 1 : SECDED_LANES

   ,parameter       RD_IE_PAR_ERR_PIPELINE = 0
   ,parameter       MAX_NUM_NIBBLES = 18
   ,parameter       DRAM_BYTE_NUM   = `MEMC_DRAM_TOTAL_BYTE_NUM
)
(
    input                           co_yy_clk              // 1X clock
   ,input                           core_ddrc_rstn         // active low reset
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in SVA file and under certain configs
   ,input                           ddrc_cg_en             // clock gating enable
   ,input                           dh_rd_frequency_ratio  // Frequency ratio
                                                            // 1 - 1:4 mode, 0 - 1:2 mode
//spyglass enable_block W240

   ,input                           reg_ddrc_lpddr4
   ,input                           reg_ddrc_lpddr5
   ,input  [PHY_DBI_WIDTH-1:0]      ph_rd_rdbi_n           // all bits read from DDR,
   ,input  [PHY_DATA_WIDTH-1:0]     ph_rd_rdata            // all bits read from DDR,
                                                            //  re-organized for ECC if SEC/DED mode
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
   ,input                           rt_rd_rd_valid         // valid read data from PHY
   ,input                           rt_rd_eod              // end of data from RT
   ,input  [CMD_LEN_BITS-1:0]       rt_rd_partial          // indicates that the current read is a non-block read
                                                            //  (for which RD may have to discard excess data)
   ,input  [RA_INFO_WIDTH-1:0]      rt_rd_ra_info          // address and RMW type from RT for RMW and ECC scrubs
   
   ,input                           rt_rd_rd_addr_err      // read address error flag
   
   ,output                          rd_ih_free_brt_vld
   ,output [BRT_BITS-1:0]           rd_ih_free_brt
   
   ,output                          rd_ecc_ram_wr
   ,output [ECC_RAM_ADDR_BITS-1:0]  rd_ecc_ram_waddr
   ,output [CORE_DATA_WIDTH-1:0]    rd_ecc_ram_wdata
   ,output [CORE_MASK_WIDTH-1:0]    rd_ecc_ram_wdata_mask_n //should be all 1, no mask. 
   ,output [CORE_MASK_WIDTH-1:0]    rd_ecc_ram_wdata_par
   
   ,output [ECC_RAM_ADDR_BITS-1:0]  rd_ecc_ram_raddr
 
   ,output [ECC_RAM_ADDR_BITS-1:0]  rd_ecc_acc_raddr_2
 
   ,output [ECC_ERR_RAM_WIDTH-1:0]      ecc_err_mr_rdata

   ,output [BT_BITS-1:0]     rd_ih_lkp_bwt_by_bt
   ,output [BT_BITS-1:0]     rd_ih_lkp_brt_by_bt
 

   ,output                          ddrc_reg_ecc_ap_err
   
   ,input                           reg_ddrc_phy_dbi_mode  // DBI implemented in DDRC or PHY
   ,input                           reg_ddrc_rd_dbi_en     // read DBI enable
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
   
   ,output [`DDRCTL_HIF_DRAM_ADDR_WIDTH-1:0] rd_ra_dram_addr
   ,output                          rd_wu_ecc_corrected_err    // single-bit error that will be corrected, per lane
   ,output                          rd_wu_ecc_uncorrected_err  // double-bit error detected in read data, per lane
   ,output                          rd_ra_ecc_corrected_err   // correctable error indication, sync with rd_ra_rdata_valid
   ,output                          rd_ra_ecc_uncorrected_err // uncorrectable error indication, sync with rd_ra_rdata_valid

   ,output  [ECC_CORRECTED_ERR_WIDTH-1:0]        rd_dh_ecc_corrected_err   // single-bit error that will be corrected, per lane
   ,output  [ECC_UNCORRECTED_ERR_WIDTH-1:0]      rd_dh_ecc_uncorrected_err // double-bit error detected in read data, per lane
   ,output  [`MEMC_ECC_SYNDROME_WIDTH-1:0]  rd_dh_ecc_corr_syndromes   // data pattern that resulted in an error;
   ,output  [`MEMC_ECC_SYNDROME_WIDTH-1:0]  rd_dh_ecc_uncorr_syndromes // data pattern that resulted in an error;
   ,output  [6:0]                           rd_dh_ecc_corrected_bit_num// bit number corrected by single-bit error
   ,output  [`MEMC_ECC_SYNDROME_WIDTH-1:0]  rd_dh_ecc_corr_bit_mask   // mask for the bit that is corrected

   ,output  [15:0]                  ddrc_reg_ecc_corr_err_cnt      // Count of correctable ECC errors
   ,output  [15:0]                  ddrc_reg_ecc_uncorr_err_cnt    // Count of uncorrectable ECC errors

   ,output  [RANK_BITS_DUP-1:0]     rd_dh_ecc_corr_rank
   ,output  [RANK_BITS_DUP-1:0]     rd_dh_ecc_uncorr_rank
   
   ,output  [BANK_BITS-1:0]         rd_dh_ecc_corr_bank
   ,output  [BANK_BITS-1:0]         rd_dh_ecc_uncorr_bank
   
   ,output  [BG_BITS_DUP-1:0]       rd_dh_ecc_corr_bg
   ,output  [BG_BITS_DUP-1:0]       rd_dh_ecc_uncorr_bg
   
   
   ,output  [CID_WIDTH_DUP-1:0]     rd_dh_ecc_corr_cid
   ,output  [CID_WIDTH_DUP-1:0]     rd_dh_ecc_uncorr_cid
   
   ,output  [ROW_BITS-1:0]          rd_dh_ecc_corr_row
   ,output  [ROW_BITS-1:0]          rd_dh_ecc_uncorr_row
   ,output  [COL_BITS-1:0]          rd_dh_ecc_corr_col
   ,output  [COL_BITS-1:0]          rd_dh_ecc_uncorr_col

   ,output                                                         ddrc_reg_advecc_corrected_err
   ,output                                                         ddrc_reg_advecc_uncorrected_err
   ,output [ADVECC_NUM_ERR_SYMBOL_WIDTH-1:0] ddrc_reg_advecc_num_err_symbol
   ,output [ADVECC_ERR_SYMBOL_POS_WIDTH-1:0] ddrc_reg_advecc_err_symbol_pos
   ,output [ADVECC_ERR_SYMBOL_BITS_WIDTH-1:0] ddrc_reg_advecc_err_symbol_bits





   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_eighth
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_seventh
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_sixth
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_fifth
   
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_fourth
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_third
   
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_second
   ,output     [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_first

   ,output                              rd_wu_rd_crc_err

   ,output     [CORE_ECC_WIDTH_DUP-1:0] rd_ra_ecc_rdata           // ECC data going to the RA module and then to the production test logic

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block
   ,input                           reg_ddrc_oc_parity_en // enables on-chip parity
   ,input                           reg_ddrc_par_poison_en // enable ocpar poison
   ,input                           reg_ddrc_par_poison_loc_rd_iecc_type
   ,input                           reg_ddrc_par_rdata_err_intr_clr
   ,input                           reg_ddrc_oc_parity_type // selects parity type. 0 even, 1 odd
//spyglass enable_block W240
   ,output                          par_rdata_in_err_ecc_pulse
   
   ,input   [RMW_TYPE_BITS-1:0]        rt_rd_rmwtype          // 2-bit RMW type indicator.  See ddrc_parameters.v for encodings.
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
   ,input                              rt_rd_rmw_word_sel     // selects which word to return to RA
//spyglass enable_block W240
   ,input   [WU_INFO_WIDTH-1:0]        rt_rd_wu_info          // address and RMW type from RT for RMW and ECC scrubs
   ,output                             rd_wu_rdata_end        // end data out of this block
   ,output                             rd_wu_rdata_valid      // valid data out of this block
   ,output     [WU_INFO_WIDTH-1:0]     rd_wu_info             // address, RMW type, etc. from RT and provided to WU
   ,output                             rd_rw_rdata_valid      // valid data out of this block (to read-mod-write
   ,output     [CORE_DATA_WIDTH-1:0]   rd_rw_rdata            // read data in from IOLM, corrected for
   ,output     [UMCTL2_WDATARAM_PAR_DW-1:0]   rd_rw_rdata_par
   ,output     [WORD_BITS-1:0]         rd_wu_word_num         // start column address, etc. from RT and provided to wu
   ,output                             rd_wu_burst_chop_rd


   ,output                             rd_ra_rdata_valid      // valid data out of this block
   ,output     [CORE_DATA_WIDTH-1:0]   rd_ra_rdata            // read data in from IOLM, corrected for
   ,output     [CORE_MASK_WIDTH-1:0]   rd_ra_rdata_parity     // calculated parity for read data
   ,output                             rd_ra_eod              // end of data from RD
   ,output     [CMD_LEN_BITS-1:0]      rd_wu_partial          // partial read 
   ,output     [RA_INFO_WIDTH-1:0]     rd_ra_info             // tag, etc. from RT to be provided to RA for data return

   ,output                             rd_ra_rdata_valid_retry //no-masked rdata valid to retry_ctrl
   ,output                             rd_wu_rdata_valid_retry //no-masked rdata valid to retry_ctrl 
   ,output                             rd_ra_eod_retry
   ,output  [RA_INFO_WIDTH-1:0]        rd_ra_info_retry
   ,output                             rd_crc_err_retry
   ,output                             rd_ra_ecc_uncorrected_err_retry
   
   ,output                             rd_ra_rd_addr_err      // read address error flag

   ,input                           rt_rd_rd_mrr_sod
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used only under `ifdef MEMC_LPDDR4 in this file but signal should always exist under `ifdef MEMC_LPDDR2_OR_DDR4
   ,input                           rt_rd_rd_mrr
//spyglass enable_block W240
   ,input                           rt_rd_rd_mrr_ext
   ,output                          rd_mrr_data_valid
   ,output  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0] rd_mrr_data
   ,input                           reg_ddrc_mrr_done_clr
   ,output                          ddrc_reg_mrr_done
   ,output  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]   ddrc_reg_mrr_data
   ,output                          rd_mr4_data_valid

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.

// OCECC
   ,input                           ocecc_en
   ,input                           ocecc_poison_egen_mr_rd_1
   ,input [OCECC_MR_BNUM_WIDTH-1:0] ocecc_poison_egen_mr_rd_1_bnum
   ,input                           ocecc_poison_egen_xpi_rd_0
   ,input                           ocecc_poison_single
   ,input                           ocecc_poison_pgen_rd
   ,input                           ocecc_uncorr_err_intr_clr
//spyglass enable_block W240
   ,input                           rt_rd_rd_mrr_snoop

   ,output [RANK_BITS_DUP-1:0]      rd_dh_rd_crc_err_rank
   ,output [CID_WIDTH_DUP-1:0]      rd_dh_rd_crc_err_cid
   ,output [BG_BITS_DUP-1:0]        rd_dh_rd_crc_err_bg
   ,output [BANK_BITS-1:0]          rd_dh_rd_crc_err_bank
   ,output [ROW_BITS-1:0]           rd_dh_rd_crc_err_row
   ,output [COL_BITS-1:0]           rd_dh_rd_crc_err_col
   ,output                          rd_dh_crc_poison_inject_complete
   ,output [MAX_NUM_NIBBLES-1:0]    rd_dh_rd_crc_err_max_reached_int_nibble
   ,output                          rd_dh_rd_crc_err_max_reached_int
   ,output [MAX_NUM_NIBBLES*12-1:0] rd_dh_rd_crc_err_cnt_nibble
   ,output                          rd_crc_err

   ,output                                        ddrc_reg_rd_linkecc_poison_complete
   ,output [RD_LINK_ECC_UNCORR_CNT_WIDTH    -1:0] ddrc_reg_rd_link_ecc_uncorr_cnt
   ,output [RD_LINK_ECC_CORR_CNT_WIDTH      -1:0] ddrc_reg_rd_link_ecc_corr_cnt
   ,output [RD_LINK_ECC_ERR_SYNDROME_WIDTH  -1:0] ddrc_reg_rd_link_ecc_err_syndrome
   ,output [RD_LINK_ECC_UNCORR_ERR_INT_WIDTH-1:0] ddrc_reg_rd_link_ecc_uncorr_err_int
   ,output [RD_LINK_ECC_CORR_ERR_INT_WIDTH  -1:0] ddrc_reg_rd_link_ecc_corr_err_int
   ,output                                        rd_link_ecc_uncorr_err
   
   ,output  [7:0]                              rd_dh_ecc_cb_corr_syndromes   // data pattern that resulted in an error;
   ,output  [7:0]                              rd_dh_ecc_cb_uncorr_syndromes // data pattern that resulted in an error;
   ,output  [`DDRCTL_HIF_KBD_WIDTH-1:0]        rd_ra_kbd
   ,output  [`DDRCTL_HIF_KBD_WIDTH-1:0]        rd_rw_kbd
   ,output                                     rd_dh_scrubber_read_ecc_ce
   ,output                                     rd_dh_scrubber_read_ecc_ue 
   ,output  [`MEMC_ECC_SYNDROME_WIDTH-1:0]     rd_dh_ecc_corr_rsd_data   // RSD data pattern that resulted in an error;
   ,output  [`MEMC_ECC_SYNDROME_WIDTH-1:0]     rd_dh_ecc_uncorr_rsd_data // RSD data pattern that resulted in an error;
   ,output [`MEMC_FREQ_RATIO/2-1:0]            ddrc_reg_advecc_ce_kbd_stat
   ,output [`MEMC_FREQ_RATIO/2-1:0]            ddrc_reg_advecc_ue_kbd_stat
   ,output                                     rd_dh_scrubber_read_advecc_ce
   ,output                                     rd_dh_scrubber_read_advecc_ue
   ,output [ECC_CORR_ERR_PER_RANK_INTR_WIDTH-1:0]  ddrc_reg_ecc_corr_err_per_rank_intr
   ,output [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]   ddrc_reg_ecc_corr_err_cnt_rank0
   ,output [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]   ddrc_reg_ecc_corr_err_cnt_rank1
   ,output [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]   ddrc_reg_ecc_corr_err_cnt_rank2
   ,output [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]   ddrc_reg_ecc_corr_err_cnt_rank3
   ,output [`DDRCTL_EAPAR_SIZE*SECDED_LANES-1:0] ddrc_reg_eapar_error
   ,output [15:0]                              ddrc_reg_eapar_err_cnt      // Count of correctable ECC errors//
   ,output  [`DDRCTL_EAPAR_SIZE-1:0]           rd_wu_eapar
   ,output                                     rd_wu_eapar_err
   ,output                                     rd_ra_eapar_err
   ,output  [RANK_BITS_DUP-1:0]                ddrc_reg_eapar_err_rank
   ,output  [BANK_BITS-1:0]                    ddrc_reg_eapar_err_bank
   ,output  [BG_BITS_DUP-1:0]                  ddrc_reg_eapar_err_bg
   ,output  [CID_WIDTH_DUP-1:0]                ddrc_reg_eapar_err_cid
   ,output  [ROW_BITS-1:0]                     ddrc_reg_eapar_err_row
   ,output  [COL_BITS-1:0]                     ddrc_reg_eapar_err_col
   ,output  [`MEMC_ECC_SYNDROME_WIDTH-1:0]     ddrc_reg_eapar_err_syndromes 
   ,output  [7:0]                              ddrc_reg_eapar_err_cb_syndromes
   ,output                                     ddrc_reg_eapar_err_sbr_rd 
                    );

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------
// data_bus_width encodings
localparam      DATA_BUS_WIDTH_FULL     = 2'b00;        // use whole data bus
localparam      DATA_BUS_WIDTH_HALF     = 2'b01;        // use whole data bus
localparam      DATA_BUS_WIDTH_QUARTER  = 2'b10;        // use whole data bus

localparam      DATA_WIDTH_NO_ECC       = CORE_DATA_WIDTH;
// ecc_mode encodings
localparam      ECC_MODE_NO_ECC            = 3'b000; 
localparam      ECC_MODE_PARITY            = 3'b010;
localparam      ECC_MODE_SECDED            = 3'b100;
localparam      ECC_MODE_ADVECC            = 3'b101;       

// ocpar
localparam      OCPAR_SLICE_DW            = 8;
localparam      ECC_EN                    = `MEMC_ECC_SUPPORT;
localparam      FR                        = `MEMC_FREQ_RATIO;

// signal width adapt
localparam      ADVECC_WIDTH_ADAPT        = (ECC_EN == 3) ? 2 : 1;


localparam EAPAR_SIZE_SECDED_LANES = `DDRCTL_EAPAR_SIZE*SECDED_LANES;
//----------------------- outputs that require reg in certain configs -----------------------------
// following signals are register drivers of outputs depending on certain ifdef
// Was prev defined as output reg xxx inisde ifedef but changed to:
// output (wire - implicit) xxx [always there]
// Then depedning on ifdef:
// reg i<xxx;
// assign xxx = i_xxx;
// Reset of logic uses i_xxx instead of xxx;
// 






   reg                         i_rd_wu_rdata_valid;     
   reg [WU_INFO_WIDTH-1:0]     i_rd_wu_info;             
   reg                         i_rd_rw_rdata_valid;      
   reg [CORE_DATA_WIDTH-1:0]   i_rd_rw_rdata;          
   reg [UMCTL2_WDATARAM_PAR_DW-1:0]   i_rd_rw_rdata_par;


   assign                      rd_wu_rdata_valid = i_rd_wu_rdata_valid ;
   assign                      rd_wu_info        = i_rd_wu_info;
   assign                      rd_rw_rdata_valid = i_rd_rw_rdata_valid;
   assign                      rd_rw_rdata       = i_rd_rw_rdata;
   assign                      rd_rw_rdata_par   = i_rd_rw_rdata_par;




   reg                       i_rd_ra_rd_addr_err;
   wire                       i_rd_ra_rd_addr_err_mux;

   assign                    rd_ra_rd_addr_err = i_rd_ra_rd_addr_err_mux;


   reg                       mrr_recieved_r;
   reg  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0] mrr_data_r;

wire [PHY_DBI_WIDTH-1:0]     sel_ph_rd_rdbi_n;
wire [PHY_DATA_WIDTH-1:0]    sel_ph_rd_rdata;
wire                         sel_rt_rd_rd_valid;
wire                         sel_rt_rd_eod;
wire [CMD_LEN_BITS-1:0]      sel_rt_rd_partial;
wire [RA_INFO_WIDTH-1:0]     sel_rt_rd_ra_info;
wire                         sel_rt_rd_rd_mrr;
wire                         sel_rt_rd_rd_mrr_ext;
wire                         sel_rt_rd_rd_mrr_snoop;
wire                         sel_rt_rd_rd_mrr_sod;
wire  [RMW_TYPE_BITS-1:0]    sel_rt_rd_rmwtype;
wire  [WU_INFO_WIDTH-1:0]    sel_rt_rd_wu_info;
wire                         sel_rt_rd_rd_addr_err;

   






//----------------------- drive undriven outputs -----------------------------
  assign rd_ih_free_brt_vld = 1'b0;
  assign rd_ih_free_brt     = {BRT_BITS{1'b0}};
  
  assign rd_ecc_ram_wr = 1'b0;
  assign rd_ecc_ram_waddr = {ECC_RAM_ADDR_BITS{1'b0}}; 
  assign rd_ecc_ram_wdata = {CORE_DATA_WIDTH{1'b0}}; 
  assign rd_ecc_ram_wdata_mask_n = {CORE_MASK_WIDTH{1'b0}}; 
  assign rd_ecc_ram_wdata_par = {CORE_MASK_WIDTH{1'b0}}; 
 
  assign rd_ecc_ram_raddr = {ECC_RAM_ADDR_BITS{1'b0}}; 

  assign rd_ecc_acc_raddr_2 = {ECC_RAM_ADDR_BITS{1'b0}}; 

  assign ecc_err_mr_rdata = {ECC_ERR_RAM_WIDTH{1'b0}}; 

  assign rd_ih_lkp_bwt_by_bt = {BT_BITS{1'b0}}; 

  assign rd_ih_lkp_brt_by_bt = {BT_BITS{1'b0}}; 

  assign ddrc_reg_ecc_ap_err = 1'b0;



   assign rd_wu_ecc_corrected_err   = 1'b0;
   assign rd_wu_ecc_uncorrected_err = 1'b0;
   
   assign rd_ra_ecc_corrected_err   = 1'b0;
   assign rd_ra_ecc_uncorrected_err = 1'b0;

   assign rd_dh_ecc_corrected_err     = {ECC_CORRECTED_ERR_WIDTH{1'b0}};
   assign rd_dh_ecc_uncorrected_err   = {ECC_UNCORRECTED_ERR_WIDTH{1'b0}};
   assign rd_dh_ecc_corr_syndromes    = {`MEMC_ECC_SYNDROME_WIDTH{1'b0}};
   assign rd_dh_ecc_uncorr_syndromes  = {`MEMC_ECC_SYNDROME_WIDTH{1'b0}};
   assign rd_dh_ecc_corrected_bit_num = 7'b0;
   assign rd_dh_ecc_corr_bit_mask     = {`MEMC_ECC_SYNDROME_WIDTH{1'b0}};


   assign ddrc_reg_ecc_corr_err_cnt   = 16'b0;
   assign ddrc_reg_ecc_uncorr_err_cnt = 16'b0;

   assign rd_dh_ecc_corr_rank   = {RANK_BITS_DUP{1'b0}};
   assign rd_dh_ecc_uncorr_rank = {RANK_BITS_DUP{1'b0}};
   assign rd_dh_ecc_corr_bank   = {BANK_BITS{1'b0}};
   assign rd_dh_ecc_uncorr_bank = {BANK_BITS{1'b0}};
   assign rd_dh_ecc_corr_bg     = {BG_BITS_DUP{1'b0}};
   assign rd_dh_ecc_uncorr_bg   = {BG_BITS_DUP{1'b0}};

   assign rd_dh_ecc_corr_cid    = {CID_WIDTH_DUP{1'b0}};
   assign rd_dh_ecc_uncorr_cid  = {CID_WIDTH_DUP{1'b0}};
   assign rd_dh_ecc_corr_row    = {ROW_BITS{1'b0}};
   assign rd_dh_ecc_uncorr_row  = {ROW_BITS{1'b0}};
   assign rd_dh_ecc_corr_col    = {COL_BITS{1'b0}};
   assign rd_dh_ecc_uncorr_col  = {COL_BITS{1'b0}};
   
   assign ddrc_reg_advecc_corrected_err   = 1'b0;
   assign ddrc_reg_advecc_uncorrected_err = 1'b0;
   assign ddrc_reg_advecc_num_err_symbol  = {ADVECC_NUM_ERR_SYMBOL_WIDTH{1'b0}};
   assign ddrc_reg_advecc_err_symbol_pos  = {ADVECC_ERR_SYMBOL_POS_WIDTH{1'b0}};
   assign ddrc_reg_advecc_err_symbol_bits = {ADVECC_ERR_SYMBOL_BITS_WIDTH{1'b0}};
   assign ddrc_reg_advecc_ce_kbd_stat     = {`MEMC_FREQ_RATIO/2{1'b0}};
   assign ddrc_reg_advecc_ue_kbd_stat     = {`MEMC_FREQ_RATIO/2{1'b0}};
   assign rd_dh_ecc_cb_corr_syndromes    = {8{1'b0}};
   assign rd_dh_ecc_cb_uncorr_syndromes  = {8{1'b0}};
   assign rd_dh_scrubber_read_ecc_ce     = 1'b0;
   assign rd_dh_scrubber_read_ecc_ue     = 1'b0;
   assign rd_dh_scrubber_read_advecc_ce  = 1'b0;
   assign rd_dh_scrubber_read_advecc_ue  = 1'b0;

   assign rd_wu_ecc_uncorrected_err_eighth  = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_seventh = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_sixth   = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_fifth   = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_fourth  = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_third   = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_second  = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_ecc_uncorrected_err_first   = {SECDED_LANES_DUP{1'b0}};
   assign rd_wu_rd_crc_err                  = 1'b0;

   assign rd_ra_ecc_rdata                   = {CORE_ECC_WIDTH_DUP{1'b0}};
 


// else of ifndef => `ifdef MEMC_USE_RMW case
  //
   // as these are "output reg" cannot just assign
   assign rd_wu_word_num = {WORD_BITS{1'b0}};

   assign rd_wu_burst_chop_rd = 1'b0;




//------------------------------------------------------------------------------
// Wires and registers
//------------------------------------------------------------------------------

reg                             i_rd_ra_rdata_valid;
reg     [CORE_DATA_WIDTH-1:0]   i_rd_ra_rdata;
reg     [CORE_MASK_WIDTH-1:0]   i_rd_ra_rdata_parity;
reg                             i_rd_ra_eod;
reg     [CMD_LEN_BITS-1:0]      i_rd_wu_partial;
reg     [RA_INFO_WIDTH-1:0]     i_rd_ra_info;
wire                             i_rd_ra_rdata_valid_mux;
wire     [CORE_DATA_WIDTH-1:0]   i_rd_ra_rdata_mux;
wire     [CORE_MASK_WIDTH-1:0]   i_rd_ra_rdata_parity_mux;
wire                             i_rd_ra_eod_mux;
wire     [CMD_LEN_BITS-1:0]      i_rd_wu_partial_mux;
wire     [RA_INFO_WIDTH-1:0]     i_rd_ra_info_mux;

assign rd_wu_rdata_end = i_rd_ra_eod;  // 

assign rd_ra_rdata_valid  = i_rd_ra_rdata_valid_mux;
assign rd_ra_rdata        = i_rd_ra_rdata_mux;
assign rd_ra_rdata_parity = i_rd_ra_rdata_parity_mux;
assign rd_ra_eod          = i_rd_ra_eod_mux;
assign rd_wu_partial      = i_rd_wu_partial_mux;
assign rd_ra_info         = i_rd_ra_info_mux;
assign rd_ra_dram_addr    = {`DDRCTL_HIF_DRAM_ADDR_WIDTH{1'b0}};

wire rd_ra_rdata_valid_w;
wire rd_wu_rdata_valid_w;

wire                       rt_rd_rd_valid_int;
wire                       rt_rd_data_valid_int;
wire                       mrr_operation_on_int;
wire rd_rw_rdata_valid_w;
wire   [RMW_TYPE_BITS-1:0] rt_rd_rmwtype_int;
wire   [WU_INFO_WIDTH-1:0] rt_rd_wu_info_int;
wire                       rt_rd_eod_int;
wire   [CMD_LEN_BITS-1:0]  rt_rd_partial_int;
wire   [RA_INFO_WIDTH-1:0] rt_rd_ra_info_int;
wire                       rt_rd_rd_addr_err_int;  // read address error flag

wire                       rt_rd_data_valid_int_w;
wire                       mrr_operation_on_int_w;
wire   [RMW_TYPE_BITS-1:0] rt_rd_rmwtype_int_w;
wire   [WU_INFO_WIDTH-1:0] rt_rd_wu_info_int_w;
wire                       rt_rd_eod_int_w;
wire   [CMD_LEN_BITS-1:0]  rt_rd_partial_int_w;
wire   [RA_INFO_WIDTH-1:0] rt_rd_ra_info_int_w;
wire   [CORE_DATA_WIDTH-1:0] i_rd_ra_rdata_w;
wire   [CORE_MASK_WIDTH-1:0] i_rd_ra_rdata_parity_w;
wire                       rt_rd_rd_addr_err_int_w;
wire                       i_rd_ra_rd_addr_err_w;








wire                            mr4;
wire                            i_rd_mr4_data_valid;
reg                             r_rd_mr4_data_valid;
wire                            mrr_ext;
wire                            mrr_operation_on;
wire                            mrr_operation_on_r;
wire                            i_rd_mrr_data_valid;
reg                             r_rd_mrr_data_valid;
wire [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0] i_rd_mrr_data;
reg  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0] r_rd_mrr_data;

//------------------------------------------------------------------------------
// Internal Wires and registers
//------------------------------------------------------------------------------
reg     [PHY_DATA_WIDTH-1:0]    ph_rd_rdata_dbi;                // read data DBI
wire                            read_dbi_enable;        // read data DBI enable
wire    [PHY_DATA_WIDTH-1:0]    ph_rd_rdata_no_dbi;             // read data no DBI

wire    [4:0]                   word_num;               // count of valid_words - x [1 for each ECC lane] - max of 32 QBW 1:1 MEMC_BURST_LENGTH=16
wire    [4:0]                   word_num_int;               // count of valid_words - x [1 for each ECC lane] - max of 32 QBW 1:1 MEMC_BURST_LENGTH=16
reg     [5:0]                   word_num_wider;         // used to check that overflow does not occur


wire    [PHY_DATA_WIDTH-1:0]    data_out;
wire    [PHY_DATA_WIDTH-1:0]    data_out_w;
wire    [CORE_MASK_WIDTH-1:0]   parity_out;
wire    [CORE_MASK_WIDTH-1:0]   parity_out_w;

wire    [PHY_DATA_WIDTH-1:0]    data_out_non_sb;



// DBI logic
wire    [PHY_DBI_WIDTH-1:0]     rd_rdbi;

wire                             lpddr_mode;
assign lpddr_mode = reg_ddrc_lpddr4 | reg_ddrc_lpddr5;

assign rd_rdbi = 
            (lpddr_mode)? ~sel_ph_rd_rdbi_n :
                           sel_ph_rd_rdbi_n;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(i * 8)' found in module 'rd'
//SJ: This coding style is acceptable and there is no plan to change it.
integer i;
always @(*)
    for (i=0; i<PHY_DBI_WIDTH; i=i+1) begin
        ph_rd_rdata_dbi[i*8+:8] = (rd_rdbi[i]) ? sel_ph_rd_rdata[i*8+:8] : ~sel_ph_rd_rdata[i*8+:8];
    end
//spyglass enable_block SelfDeterminedExpr-ML

assign read_dbi_enable = ~reg_ddrc_phy_dbi_mode & reg_ddrc_rd_dbi_en;
assign ph_rd_rdata_no_dbi = 
                            ((read_dbi_enable) ? ph_rd_rdata_dbi : sel_ph_rd_rdata)
                     ;


//------------------------------------------------------------------------------
// ECC section
//     - Flopping all the inputs - flop it twince in the case of BW < 64
//     - Test mode instance
//     - ECC decoder instance
//     - Data Out Mux
//------------------------------------------------------------------------------

wire    [PHY_DATA_WIDTH-1:0]     ph_rd_rdata_r;
wire                             rt_rd_rd_valid_r;        // valid read data from PHY
wire  [CORE_DATA_WIDTH-1:0]      data_out_ecc;
wire  [CORE_DATA_WIDTH-1:0]      data_no_ecc_unused;


// When NoECC && DDR5(Read-CRC) && FREQ_RATIO=4, add extra one pipeline.
//  - Read-CRC is enabled : Extra one pipeline
//  - Read-CRC is disabled: Bypass this pipeline

wire    [PHY_DATA_WIDTH-1:0]     ph_rd_rdata_w;
wire                             rt_rd_rd_valid_w;       // valid read data from PHY
wire                             rt_rd_eod_w;            // end of data from RT
wire    [CMD_LEN_BITS-1:0]       rt_rd_partial_w;        // indicates that the current read is a non-block read
wire    [RA_INFO_WIDTH-1:0]      rt_rd_ra_info_w;        // address and RMW type from RT for RMW and ECC scrubs
wire                             mrr_operation_on_w;
wire                             rt_rd_rd_addr_err_w;    // read address error flag
wire    [RMW_TYPE_BITS-1:0]      rt_rd_rmwtype_w;        // 2-bit RMW type indicator.  See ddrc_parameters.v for encodings.
wire    [WU_INFO_WIDTH-1:0]      rt_rd_wu_info_w;        // address and RMW type from RT for RMW and ECC scrubs



assign ph_rd_rdata_w       = ph_rd_rdata_no_dbi;
assign rt_rd_rd_valid_w    = sel_rt_rd_rd_valid;
assign rt_rd_eod_w         = sel_rt_rd_eod;
assign rt_rd_partial_w     = sel_rt_rd_partial;
assign rt_rd_ra_info_w     = sel_rt_rd_ra_info;
assign mrr_operation_on_w  = mrr_operation_on;
assign rt_rd_rd_addr_err_w = sel_rt_rd_rd_addr_err;
assign rt_rd_rmwtype_w     = sel_rt_rd_rmwtype;
assign rt_rd_wu_info_w     = sel_rt_rd_wu_info;




//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Unused in some configs. Decided to keep current coding style.
     
// needed in OCPAR module
assign ph_rd_rdata_r    = {PHY_DATA_WIDTH{1'b0}};
assign rt_rd_rd_valid_r = rt_rd_rd_valid_w;
assign data_out_ecc     = {CORE_DATA_WIDTH{1'b0}};
//spyglass enable_block W528

//-------------------------------------
// End SIDEBAND ECC Section
//-------------------------------------

//----------------------------------------------------
// Non-ECC section (also used for IE case in SB=1 & IE=1 case)
//    - assembling the data in HBW & QBW modes
//    - mux to select the appropriate data based on bus width mode
//    - data_out generation
//----------------------------------------------------

//spyglass disable_block W528
//SMD: Signal declared but not read
//SJ: Used opcpar_rd_gen
wire [PHY_DATA_WIDTH-1:0] ph_rd_rdata_no_dbi_exp;
//spyglass enable_block W528



reg [CORE_DATA_WIDTH-1:0] ph_rd_rdata_no_dbi_core_width;

  always @(*) begin  : ph_rd_rdata_no_dbi_core_width_non_ie_PROC
    ph_rd_rdata_no_dbi_core_width = ph_rd_rdata_w;
  end

  //spyglass disable_block W528
//SMD: Signal declared but not read
//SJ: Used opcpar_rd_gen
    assign ph_rd_rdata_no_dbi_exp  = ph_rd_rdata_w;
//spyglass enable_block W528



  // Data alignment for FBW - SW 1:2 mode
   wire [(CORE_DATA_WIDTH/2)-1:0]       lwr_half_ph_rd_rdata;
   reg  [(CORE_DATA_WIDTH/2)-1:0]       lwr_half_data_ff;

// Data is arranged differently in partially populated (aka HBW, QBW), DFI 1:2 mode
  
   assign lwr_half_ph_rd_rdata     = ph_rd_rdata_no_dbi_core_width[(CORE_DATA_WIDTH/2)-1:0];

//spyglass disable_block W528
//SMD: A signal or variable is set but never read - lwr_half_data_ff
//SJ: Used under different `ifdefs. Decided to keep current implementation.

   // When only using partial data bus, flop data until a full core-side transfer has arrived
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     if (~core_ddrc_rstn) begin
        lwr_half_data_ff      <= {(CORE_DATA_WIDTH/2){1'b0}};
     end
     else if(ddrc_cg_en)
         begin 
            // flop the lower half of the data bus (post-ECC, if applicable)
            if(sel_rt_rd_rd_valid) begin
               lwr_half_data_ff      <= lwr_half_ph_rd_rdata;
            end
         end // flops not in reset
//spyglass enable_block W528


   // assign output data for configurations without ECC support
    assign      data_out_non_sb          = 
                                          (!dh_rd_frequency_ratio) ? {lwr_half_ph_rd_rdata, lwr_half_data_ff} : // FR2
                                                                      ph_rd_rdata_no_dbi_core_width;



//-------------------------------------
// End Non-ECC Section
//-------------------------------------

   assign data_out = data_out_non_sb;



  assign rd_dh_ecc_corr_rsd_data =
                          {`MEMC_ECC_SYNDROME_WIDTH{1'b0}};

  assign rd_dh_ecc_uncorr_rsd_data =
                          {`MEMC_ECC_SYNDROME_WIDTH{1'b0}};


   assign par_rdata_in_err_ecc_pulse = 1'b0;






//------------------------------------------------------------------------------
// ECC section
//    - All the ECC error reporting logic and their associated flops
//------------------------------------------------------------------------------


//-------------------------------------
// End ECC Section
//-------------------------------------


//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation.
assign rt_rd_rd_valid_int   = rt_rd_rd_valid_w;
assign mrr_operation_on_int = mrr_operation_on_w;
assign rt_rd_rmwtype_int    = rt_rd_rmwtype_w;
assign rt_rd_wu_info_int    = rt_rd_wu_info_w;
assign rt_rd_eod_int        = rt_rd_eod_w;
assign rt_rd_partial_int    = rt_rd_partial_w;
assign rt_rd_ra_info_int    = rt_rd_ra_info_w;
assign rt_rd_rd_addr_err_int = rt_rd_rd_addr_err_w;
//spyglass enable_block W528

// Word number
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    word_num_wider     <= 6'b0;
  end
  else if(ddrc_cg_en) begin     // flops not in reset
    word_num_wider     <= ((rt_rd_eod_int & rt_rd_rd_valid_int)
                              | mrr_operation_on_int
                          ) ? 5'b0 : (word_num_wider[4:0] + {4'b0000, rt_rd_rd_valid_int});
  end
  
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in MEMC_FREQ_RATIO_4 or MEMC_SIDEBAND_ECC. When MEMC_FREQ_RATIO_4 is always enabled, this is not needed.
assign word_num = word_num_wider[4:0]; 
assign word_num_int = word_num; 
//spyglass enable_block W528

assign rt_rd_data_valid_int = rt_rd_rd_valid_int
                              & ( 
                               // In PROG FREQ RATIO, SW 1:2 mode - only lower lane data valid
                               // so need to combine data {lwr_lane1,lwr_lane0} and generate valid accordingly
                               (!dh_rd_frequency_ratio)
                               ? (word_num[0])  
                               :  
                                 (1'b1)  
                               ) 
                               ;


//MUX between "Inline ECC" and "Not Inline ECC"
assign rt_rd_data_valid_int_w = rt_rd_data_valid_int;
assign mrr_operation_on_int_w = mrr_operation_on_int;
assign rt_rd_rmwtype_int_w    = rt_rd_rmwtype_int;
assign rt_rd_wu_info_int_w    = rt_rd_wu_info_int;
assign rt_rd_eod_int_w        = rt_rd_eod_int;
assign rt_rd_partial_int_w    = rt_rd_partial_int;
assign rt_rd_ra_info_int_w    = rt_rd_ra_info_int;
assign rt_rd_rd_addr_err_int_w = rt_rd_rd_addr_err_int;
assign data_out_w             = data_out;

assign rd_rw_rdata_valid_w = rt_rd_data_valid_int_w
                             &  ~mrr_operation_on_int_w                          // No valid to WU when MRR is ON
                             & (rt_rd_rmwtype_int_w != `MEMC_RMW_TYPE_NO_RMW) // No valid for normal read operations. only for RMW.
                           ;
     
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
assign rd_wu_rdata_valid_w = rt_rd_data_valid_int_w
                             &  ~mrr_operation_on_int_w // No valid to WU when MRR is ON
                           ;
//spyglass enable_block W528

assign rd_ra_rdata_valid_w =  rt_rd_data_valid_int_w
                             & ((rt_rd_rmwtype_int_w==`MEMC_RMW_TYPE_RMW_CMD)       ||
                                (rt_rd_rmwtype_int_w==`MEMC_RMW_TYPE_NO_RMW)          )
                             & ~mrr_operation_on_int_w
                          ;


//---------------------------
// Flopped outputs to WU & RW modules
//---------------------------


wire [UMCTL2_WDATARAM_PAR_DW-1:0] rd_rw_rdata_parity_w;
assign rd_rw_rdata_parity_w = parity_out_w;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    i_rd_wu_rdata_valid   <= 1'b0;
    i_rd_rw_rdata_valid   <= 1'b0;
    i_rd_wu_info          <= {WU_INFO_WIDTH{1'b0}};
    i_rd_rw_rdata         <= {CORE_DATA_WIDTH{1'b0}};
    i_rd_rw_rdata_par     <= {UMCTL2_WDATARAM_PAR_DW{1'b0}};
  end
  else if(ddrc_cg_en) begin     // flops not in reset

    i_rd_wu_rdata_valid   <= rd_wu_rdata_valid_w;

    i_rd_rw_rdata_valid   <= rd_rw_rdata_valid_w;

    i_rd_wu_info          <= rt_rd_wu_info_int_w;

    i_rd_rw_rdata         <= data_out_w[CORE_DATA_WIDTH-1:0];

    i_rd_rw_rdata_par     <= rd_rw_rdata_parity_w;



  end


wire [CORE_MASK_WIDTH-1:0]  rd_ra_rdata_parity_w;
assign rd_ra_rdata_parity_w = parity_out_w;

wire [CORE_MASK_WIDTH-1:0]  default_rdata_parity_w;
assign default_rdata_parity_w = {CORE_MASK_WIDTH{reg_ddrc_oc_parity_type}};


assign i_rd_ra_rdata_w =
                           (rt_rd_rd_addr_err_int_w == 1'b1) ? {DATA_WIDTH_NO_ECC{1'b0}} : 
                           data_out_w[CORE_DATA_WIDTH-1:0];

assign i_rd_ra_rdata_parity_w =
                        (rt_rd_rd_addr_err_int_w == 1'b1) ? default_rdata_parity_w : 
                         rd_ra_rdata_parity_w;

assign i_rd_ra_rd_addr_err_w = rt_rd_rd_addr_err_int_w & rd_ra_rdata_valid_w;




//--------------------------
// Flopped outputs to RA
//--------------------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    i_rd_ra_rdata_valid   <= 1'b0;
    i_rd_ra_eod           <= 1'b0;
    i_rd_wu_partial       <= {CMD_LEN_BITS{1'b0}};
    i_rd_ra_info          <= {RA_INFO_WIDTH{1'b0}};
    i_rd_ra_rdata         <= {DATA_WIDTH_NO_ECC{1'b0}};
    i_rd_ra_rdata_parity  <= {CORE_MASK_WIDTH{1'b0}};
    i_rd_ra_rd_addr_err <= 1'b0;
  end
  else if(ddrc_cg_en) begin     // flops not in reset
    // Assert data valid in the same cycle as the last data is received;
    //  calculated as the cycle before the last data is received, then flopped
    i_rd_ra_rdata_valid   <= rd_ra_rdata_valid_w;
    i_rd_ra_eod           <= rt_rd_eod_int_w;
    i_rd_wu_partial       <= rt_rd_partial_int_w;
    i_rd_ra_info          <= rt_rd_ra_info_int_w;
    i_rd_ra_rdata         <= i_rd_ra_rdata_w;
    i_rd_ra_rdata_parity <= i_rd_ra_rdata_parity_w;
    i_rd_ra_rd_addr_err <= i_rd_ra_rd_addr_err_w;
  end


// the MRR operation is a BL4 operation on the DRAM
// it results in 2 cycles of read data on the DFI interface
// the actual MRR data is 8-bits wide and is contained in the 
// least significant 8-bits of the 1st clock of the MRR data on the DFI bus

   assign mr4                =
                      //`ifdef MEMC_FREQ_RATIO_4
                      //`endif // MEMC_FREQ_RATIO_4
                              (!sel_rt_rd_rd_mrr_snoop) & 
                               sel_rt_rd_rd_mrr     & sel_rt_rd_rd_valid;

  wire mrr_snoop;
  assign mrr_snoop           = sel_rt_rd_rd_mrr_snoop & sel_rt_rd_rd_mrr & sel_rt_rd_rd_valid;     

   assign mrr_ext            = sel_rt_rd_rd_mrr_ext & sel_rt_rd_rd_valid;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in testbench file (ddrc_dbgcam_mon.sv)
  // goes high when the MRR valid data is on the bus
  // used to disable the normal read data valid going to other modules
   assign mrr_operation_on   = 
                               mr4 || 
                               mrr_snoop ||
                               mrr_ext;
//spyglass enable_block W528

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current coding style.
       assign mrr_operation_on_r = 1'b0;
//spyglass enable_block W528

// MRR data - coming through the ECC decoder
   assign i_rd_mrr_data        = ph_rd_rdata_no_dbi[`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0];

// generating a one cycle pulse for the MRR data valid
// data_out used in the above logic is flopped (coming through the ECC decoder)
// and so the MRR data valid is alsp generated from the flopped signals

   assign i_rd_mrr_data_valid  = 
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
                                 mrr_ext & sel_rt_rd_rd_mrr_sod;
   assign i_rd_mr4_data_valid  = 
                              //`ifdef MEMC_FREQ_RATIO_4
                              //`endif // MEMC_FREQ_RATIO_4
                                 lpddr_mode    ? mr4 & sel_rt_rd_rd_mrr_sod :
                                 1'b0;


// All the flops related to MRR operation
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     if (~core_ddrc_rstn) begin
          r_rd_mrr_data         <= {`MEMC_DRAM_TOTAL_DATA_WIDTH{1'b0}};
          r_rd_mrr_data_valid   <= 1'b0;
          r_rd_mr4_data_valid   <= 1'b0;
     end
     else if(ddrc_cg_en) begin
          r_rd_mrr_data       <= i_rd_mrr_data;
          r_rd_mrr_data_valid <= i_rd_mrr_data_valid;
          r_rd_mr4_data_valid <= i_rd_mr4_data_valid;
     end

   // drive output from registered signals
   assign rd_mrr_data        = r_rd_mrr_data;
   assign rd_mrr_data_valid  = r_rd_mrr_data_valid;
   assign rd_mr4_data_valid  = r_rd_mr4_data_valid;

   // Latch MRR data
   always_ff @ (posedge co_yy_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         mrr_data_r <= {`MEMC_DRAM_TOTAL_DATA_WIDTH{1'b0}};
      end
      else if (rd_mrr_data_valid) begin
         mrr_data_r <= rd_mrr_data;
      end
   end

   always_ff @ (posedge co_yy_clk, negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
         mrr_recieved_r <= 1'b0;
      end
      else if (reg_ddrc_mrr_done_clr) begin
         mrr_recieved_r <= 1'b0;
      end
      else if (rd_mrr_data_valid) begin
         mrr_recieved_r <= 1'b1;
      end
   end

   assign ddrc_reg_mrr_done = mrr_recieved_r;
   assign ddrc_reg_mrr_data = mrr_data_r;

// OCPAR section
//spyglass disable_block W528
//SMD: A signal or variable is set but never read - "parity_out"
//SJ: Used in generate statement and therefore must always exist.
generate
if (OCPAR_EN==1 || OCECC_EN==1) begin: OC_PAR_OR_ECC_en
   wire [PHY_DATA_WIDTH-1:0]     poison_data;
   wire                          poison_valid, poison_valid_w;
   wire                          uncorr_err, corr_err;
   wire    [CORE_MASK_WIDTH-1:0] parity_ncorr, parity_ncorr_w;
   wire                          op_is_scrub;
   wire [RMW_TYPE_BITS-1:0]      rmw_type;
   wire                          iecc_en;
   wire  [CORE_DATA_WIDTH-1:0]   data_in_post_dec;
   wire                          i_reg_ddrc_par_poison_loc_rd_iecc_type;
   wire                          advecc_en;


      assign op_is_scrub   = 1'b0;
   

      assign iecc_en  = 1'b0;

      assign data_in_post_dec = data_out_ecc;
      assign poison_valid     = rt_rd_data_valid_int_w;
      assign poison_valid_w   = rd_ra_rdata_valid_w;
      assign i_reg_ddrc_par_poison_loc_rd_iecc_type = reg_ddrc_par_poison_loc_rd_iecc_type;
      

   
   assign uncorr_err    = 1'b0;
   assign corr_err      = 1'b0;
   assign rmw_type      = {RMW_TYPE_BITS{1'b0}};

   assign advecc_en = 1'b0;

   ocpar_rd_gen
   
   #(
      .CORE_DATA_WIDTH  (CORE_DATA_WIDTH),
      .PHY_DATA_WIDTH   (PHY_DATA_WIDTH),
      .DRAM_DATA_WIDTH  (SECDED_CORESIDE_LANE_WIDTH),
      .SECDED_LW        (SECDED_1B_LANE_WIDTH),
      .SECDED_LANES     (SECDED_LANES),
      .ECC_EN           (ECC_EN),
      .SIDEBAND_ECC     (0),
      .INLINE_ECC       (`MEMC_INLINE_ECC_EN),
      .FREQ_RATIO       (FR),
      .SLICE_DW         (OCPAR_SLICE_DW),
      .PAR_DW           (CORE_MASK_WIDTH),
      .RSD_PIPELINE   (`DDRCTL_RSD_PIPELINE_EN))
   rd_parity_gen
   (
      .core_ddrc_core_clock   (co_yy_clk),
      .core_ddrc_rstn         (core_ddrc_rstn),
      .parity_en              (OCECC_EN==1 ? ocecc_en : reg_ddrc_oc_parity_en),
      .parity_type            (OCECC_EN==1 ? 1'b0 : reg_ddrc_oc_parity_type),
      .frequency_ratio        (dh_rd_frequency_ratio),
      .rd_valid               (sel_rt_rd_rd_valid),
      .uncorr_err             (uncorr_err),
      .corr_err               (corr_err),
      .iecc_en                (iecc_en),
      .ecc_mode_is_advecc     (1'b0),
      .data_in                (ph_rd_rdata_no_dbi_exp),
      .data_in_ecc            (data_in_post_dec),
      .parity_out             (parity_ncorr),
      .parity_out_w           (parity_ncorr_w));

   // poison the parity
   ocpar_poison
   
   #(
      .DATA_WIDTH    (PHY_DATA_WIDTH),
      .PAR_WIDTH     (CORE_MASK_WIDTH),
      .DATA_PATH_POISON (`MEMC_INLINE_ECC_EN), // only for INLINE_ECC case
      .DATA_PATH_POISON_SW (`MEMC_SIDEBAND_ECC_EN), // only for SIDEBAND_ECC case
      .BYTE_WIDTH    (OCPAR_SLICE_DW),
      .BYTE_POISON   (0), 
      .BYTE_POISON_SW(0) 
    )
   poison_rdata
   (
     .clk           (co_yy_clk),
     .rst_n         (core_ddrc_rstn),
     .corrupt_twice (1'b0), // this is used only for IECC write path
     .data_valid    (poison_valid), 
     .data_valid_w  (poison_valid_w),
     .parity_in     (parity_ncorr),
     .parity_in_w   (parity_ncorr_w),
     .byte_num      (1'b0), // not used
      .dpp_support_en (1'b0), // only data path poison support if IE case
     .pbp_support_en (1'b0), // not used
     .poison_en     (OCECC_EN==1 ? ocecc_poison_pgen_rd : reg_ddrc_par_poison_en),
     .poison_ie_type(i_reg_ddrc_par_poison_loc_rd_iecc_type),
     .poison_ie_clr (OCECC_EN==1 ? ocecc_uncorr_err_intr_clr : reg_ddrc_par_rdata_err_intr_clr),
     .parity_out    (parity_out),
     .parity_out_w  (parity_out_w));


end
else begin: OC_PAR_OR_ECC_nen
   assign parity_out          = {CORE_MASK_WIDTH{1'b0}};
   assign parity_out_w        = {CORE_MASK_WIDTH{1'b0}};
end
endgenerate
//spyglass enable_block W528


//`ifdef MEMC_FREQ_RATIO_4
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ:  This is temporary. It should be connected to APB register
assign rd_dh_rd_crc_err_rank = {RANK_BITS_DUP{1'b0}};
assign rd_dh_rd_crc_err_cid  = {CID_WIDTH_DUP{1'b0}};
assign rd_dh_rd_crc_err_bg   = {BG_BITS_DUP{1'b0}};
assign rd_dh_rd_crc_err_bank = {BANK_BITS{1'b0}};
assign rd_dh_rd_crc_err_row  = {ROW_BITS{1'b0}};
assign rd_dh_rd_crc_err_col  = {COL_BITS{1'b0}};
assign rd_dh_crc_poison_inject_complete = 1'b0;
assign rd_dh_rd_crc_err_max_reached_int_nibble = {MAX_NUM_NIBBLES{1'b0}};
assign rd_dh_rd_crc_err_max_reached_int = 1'b0;
//assign rd_dh_rd_crc_err_cnt = {16{1'b0}};
assign rd_dh_rd_crc_err_cnt_nibble = {(MAX_NUM_NIBBLES*12){1'b0}};
assign rd_crc_err = 1'b0;
//spyglass enable_block W528

// `else  // MEMC_FREQ_RATIO_4
// //spyglass disable_block W528
// //SMD: A signal or variable is set but never read
// //SJ:  This is temporary. It should be connected to APB register
// assign rd_dh_rd_crc_err_rank = {RANK_BITS_DUP{1'b0}};
// assign rd_dh_rd_crc_err_cid  = {CID_WIDTH_DUP{1'b0}};
// assign rd_dh_rd_crc_err_bg   = {BG_BITS_DUP{1'b0}};
// assign rd_dh_rd_crc_err_bank = {BANK_BITS{1'b0}};
// assign rd_dh_rd_crc_err_row  = {ROW_BITS{1'b0}};
// assign rd_dh_rd_crc_err_col  = {COL_BITS{1'b0}};
// assign rd_dh_crc_poison_inject_complete = 1'b0;
// assign rd_dh_rd_crc_err_max_reached_int_nibble = {MAX_NUM_NIBBLES{1'b0}};
// assign rd_dh_rd_crc_err_max_reached_int = 1'b0;
// //assign rd_dh_rd_crc_err_cnt = {16{1'b0}};
// assign rd_dh_rd_crc_err_cnt_nibble = {(MAX_NUM_NIBBLES*12){1'b0}};
// assign rd_crc_err = 1'b0;
// //spyglass enable_block W528
// `endif // MEMC_FREQ_RATIO_4


//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4


//------------------------------------------------------------
// No Link-ECC config: rt signals are bypassed
//------------------------------------------------------------
assign sel_ph_rd_rdbi_n       = ph_rd_rdbi_n;
assign sel_ph_rd_rdata        = ph_rd_rdata;
assign sel_rt_rd_rd_valid     = rt_rd_rd_valid;
assign sel_rt_rd_eod          = rt_rd_eod;
assign sel_rt_rd_partial      = rt_rd_partial;
assign sel_rt_rd_ra_info      = rt_rd_ra_info;
assign sel_rt_rd_rd_mrr       = rt_rd_rd_mrr;
assign sel_rt_rd_rd_mrr_ext   = rt_rd_rd_mrr_ext;
assign sel_rt_rd_rd_mrr_snoop = rt_rd_rd_mrr_snoop;
assign sel_rt_rd_rd_mrr_sod   = rt_rd_rd_mrr_sod;
assign sel_rt_rd_rmwtype      = rt_rd_rmwtype;
assign sel_rt_rd_wu_info      = rt_rd_wu_info;
assign sel_rt_rd_rd_addr_err  = rt_rd_rd_addr_err;

assign ddrc_reg_rd_linkecc_poison_complete = 1'b0;
assign ddrc_reg_rd_link_ecc_uncorr_cnt     = {8{1'b0}};
assign ddrc_reg_rd_link_ecc_corr_cnt       = {8{1'b0}};
assign ddrc_reg_rd_link_ecc_err_syndrome   = {9{1'b0}};
assign ddrc_reg_rd_link_ecc_uncorr_err_int = {8{1'b0}};
assign ddrc_reg_rd_link_ecc_corr_err_int   = {8{1'b0}};
assign rd_link_ecc_uncorr_err              = 1'b0;


assign rd_rw_kbd = {`DDRCTL_HIF_KBD_WIDTH{1'b0}};
assign rd_ra_kbd = {`DDRCTL_HIF_KBD_WIDTH{1'b0}};




//-----------------------------------------------------------------------------
// No Extra pipeline (Non-RETRY-config, Non-DDR5-config, FREQ_RATIO=2 config)
assign i_rd_ra_rdata_valid_mux   = i_rd_ra_rdata_valid;
assign i_rd_ra_rdata_mux         = i_rd_ra_rdata;
assign i_rd_ra_rdata_parity_mux  = i_rd_ra_rdata_parity;
assign i_rd_ra_eod_mux           = i_rd_ra_eod;
assign i_rd_wu_partial_mux       = i_rd_wu_partial;
assign i_rd_ra_info_mux          = i_rd_ra_info;
assign i_rd_ra_rd_addr_err_mux   = i_rd_ra_rd_addr_err;


assign rd_ra_rdata_valid_retry = 1'b0;
assign rd_wu_rdata_valid_retry = 1'b0;
assign rd_ra_eod_retry = 1'b0;
assign rd_ra_info_retry = {RA_INFO_WIDTH{1'b0}};
assign rd_crc_err_retry = 1'b0;
assign rd_ra_ecc_uncorrected_err_retry = 1'b0;


  assign ddrc_reg_ecc_corr_err_per_rank_intr      = {ECC_CORR_ERR_PER_RANK_INTR_WIDTH{1'b0}};
  assign ddrc_reg_ecc_corr_err_cnt_rank0          = {ECC_CORR_ERR_CNT_RANK_WIDTH{1'b0}};
  assign ddrc_reg_ecc_corr_err_cnt_rank1          = {ECC_CORR_ERR_CNT_RANK_WIDTH{1'b0}};
  assign ddrc_reg_ecc_corr_err_cnt_rank2          = {ECC_CORR_ERR_CNT_RANK_WIDTH{1'b0}};
  assign ddrc_reg_ecc_corr_err_cnt_rank3          = {ECC_CORR_ERR_CNT_RANK_WIDTH{1'b0}};

//-----------------------------------------------------------------------------
// Driving to 0 for non EAPAR config
//-----------------------------------------------------------------------------
assign ddrc_reg_eapar_error            = {EAPAR_SIZE_SECDED_LANES{1'b0}}; 
assign ddrc_reg_eapar_err_cnt          = 16'd0;
assign ddrc_reg_eapar_err_syndromes    = {`MEMC_ECC_SYNDROME_WIDTH{1'b0}};
assign ddrc_reg_eapar_err_cb_syndromes = {8{1'b0}};
assign ddrc_reg_eapar_err_sbr_rd       = 1'b0;
assign ddrc_reg_eapar_err_col          = {COL_BITS{1'b0}};
assign ddrc_reg_eapar_err_bank         = {BANK_BITS{1'b0}};
assign ddrc_reg_eapar_err_bg           = {BG_BITS{1'b0}};
assign ddrc_reg_eapar_err_row          = {ROW_BITS{1'b0}};
assign ddrc_reg_eapar_err_cid          = {CID_WIDTH_DUP{1'b0}};
assign ddrc_reg_eapar_err_rank         = {RANK_BITS_DUP{1'b0}};
assign rd_wu_eapar_err                 = 1'b0;
assign rd_ra_eapar_err                 = 1'b0;
assign rd_wu_eapar                     = {`DDRCTL_EAPAR_SIZE{1'b0}};

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

  //word_num overflow
  assert_never #(0, 0, "word_num overflow", CATEGORY) a_word_num_overflow
    (co_yy_clk, core_ddrc_rstn, (word_num_wider[5]==1'b1)); 



`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON 


endmodule  // rd: read data handler
