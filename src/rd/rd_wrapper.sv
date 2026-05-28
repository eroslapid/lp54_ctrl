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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/rd/rd_wrapper.sv#2 $
// -------------------------------------------------------------------------
// Description:
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
module rd_wrapper 
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

   ,parameter SECDED_1B_LANE_WIDTH    = `MEMC_ECC_SYNDROME_WIDTH_RD     // width of a single SEC/DED lane
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

   ,parameter OCCAP_EN              = 0
   ,parameter CMP_REG         = 0

   ,parameter       MAX_NUM_NIBBLES = 18
   ,parameter       DRAM_BYTE_NUM   = `MEMC_DRAM_TOTAL_BYTE_NUM
)
(
    input                           co_yy_clk              // 1X clock
   ,input                           core_ddrc_rstn         // active low reset
   ,input                           ddrc_cg_en             // clock gating enable
   ,input                           dh_rd_frequency_ratio  // Frequency ratio
                                                            // 1 - 1:1 mode, 0 - 1:2 mode
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
   
 

   
   ,input                           reg_ddrc_phy_dbi_mode  // DBI implemented in DDRC or PHY
   ,input                           reg_ddrc_rd_dbi_en     // read DBI enable
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
   
   
   
   




   
   ,input                           reg_ddrc_oc_parity_en // enables on-chip parity
   ,input                           reg_ddrc_oc_parity_type // selects parity type. 0 even, 1 odd
   
   ,input                           reg_ddrc_par_poison_en // enable ocpar poison
   ,input                           reg_ddrc_par_poison_loc_rd_iecc_type

   ,input                           reg_ddrc_par_rdata_err_intr_clr

   ,output                          par_rdata_in_err_ecc_pulse
   
   ,input   [RMW_TYPE_BITS-1:0]        rt_rd_rmwtype          // 2-bit RMW type indicator.  See ddrc_parameters.v for encodings.
   ,input                              rt_rd_rmw_word_sel     // selects which word to return to RA
   ,input   [WU_INFO_WIDTH-1:0]        rt_rd_wu_info          // address and RMW type from RT for RMW and ECC scrubs
   ,output                             rd_wu_rdata_end        // end data out of this block
   ,output                             rd_wu_rdata_valid      // valid data out of this block
   ,output     [WU_INFO_WIDTH-1:0]     rd_wu_info             // address, RMW type, etc. from RT and provided to WU
   ,output                             rd_rw_rdata_valid      // valid data out of this block (to read-mod-write
   ,output     [CORE_DATA_WIDTH-1:0]   rd_rw_rdata            // read data in from IOLM, corrected for
   ,output     [UMCTL2_WDATARAM_PAR_DW-1:0]   rd_rw_rdata_par


   ,output                             rd_ra_rdata_valid      // valid data out of this block
   ,output     [CORE_DATA_WIDTH-1:0]   rd_ra_rdata            // read data in from IOLM, corrected for
   ,output     [CORE_MASK_WIDTH-1:0]   rd_ra_rdata_parity     // calculated parity for read data
   ,output                             rd_ra_eod              // end of data from RD
   ,output     [CMD_LEN_BITS-1:0]      rd_wu_partial          // partial read 
   ,output     [RA_INFO_WIDTH-1:0]     rd_ra_info             // tag, etc. from RT to be provided to RA for data return

   ,output                             rd_ra_rd_addr_err      // read address error flag
   ,input                           rt_rd_rd_mrr_sod
   ,input                           rt_rd_rd_mrr
   ,input                           rt_rd_rd_mrr_ext
   ,output                          rd_mrr_data_valid
   ,output  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0] rd_mrr_data
   ,output                          rd_mr4_data_valid
   ,input                           reg_ddrc_mrr_done_clr
   ,output                          ddrc_reg_mrr_done
   ,output  [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0] ddrc_reg_mrr_data
   
// OCECC
   ,input                           ocecc_en
   ,input                           ocecc_poison_egen_mr_rd_1
   ,input [OCECC_MR_BNUM_WIDTH-1:0] ocecc_poison_egen_mr_rd_1_bnum
   ,input                           ocecc_poison_egen_xpi_rd_0
   ,input                           ocecc_poison_single
   ,input                           ocecc_poison_pgen_rd
   ,input                           ocecc_uncorr_err_intr_clr

// occap specific input/output

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block
   ,input                      ddrc_cmp_en
   ,input                      ddrc_data_cmp_poison
   ,input                      ddrc_data_cmp_poison_full
   ,input                      ddrc_data_cmp_poison_err_inj
//spyglass enable_block W240
   ,output                     ddrc_data_cmp_error_rd
   ,output                     ddrc_data_cmp_error_full_rd
   ,output                     ddrc_data_cmp_error_seq_rd
   ,output                     ddrc_data_cmp_poison_complete_rd
   ,input                     rt_rd_rd_mrr_snoop
   
                );

  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  // for output where width varies
   localparam RD_MRR_DATA_W = `MEMC_DRAM_TOTAL_DATA_WIDTH;

   localparam NUM_INST = OCCAP_EN==1 ? 2 : 1;

   localparam NUM_OUTS = 129; // WARNING: update whenever a new output is added to rd.v
   localparam PW       = 32;
  
   // assign outputs width to internal parameters, update if outputs/parameters are changed
   localparam OUT0_W    = 1; // rd_ih_free_brt_vld 
   localparam OUT1_W    = BRT_BITS; // rd_ih_free_brt
   localparam OUT2_W    = 1; // rd_ecc_ram_wr
   localparam OUT3_W    = ECC_RAM_ADDR_BITS; // rd_ecc_ram_waddr
   localparam OUT4_W    = CORE_DATA_WIDTH; // rd_ecc_ram_wdata
   localparam OUT5_W    = CORE_MASK_WIDTH; // rd_ecc_ram_wdata_mask_n
   localparam OUT6_W    = CORE_MASK_WIDTH; // rd_ecc_ram_wdata_par
   localparam OUT7_W    = ECC_RAM_ADDR_BITS; // rd_ecc_ram_raddr
   localparam OUT8_W    = ECC_RAM_ADDR_BITS; // rd_ecc_acc_raddr_2
   localparam OUT9_W    = ECC_ERR_RAM_WIDTH; // ecc_err_mr_rdata

   localparam OUT10_W   = BT_BITS; // rd_ih_lkp_bwt_by_bt
   localparam OUT11_W   = BT_BITS; // rd_ih_lkp_brt_by_bt
   localparam OUT12_W   = 1; // ddrc_reg_ecc_ap_err
   localparam OUT13_W   = 1; // rd_wu_ecc_corrected_err
   localparam OUT14_W   = 1; // rd_wu_ecc_uncorrected_err
   localparam OUT15_W   = 1; // rd_ra_ecc_corrected_err
   localparam OUT16_W   = 1; // rd_ra_ecc_uncorrected_err
   localparam OUT17_W   = ECC_CORRECTED_ERR_WIDTH; // rd_dh_ecc_corrected_err
   localparam OUT18_W   = ECC_UNCORRECTED_ERR_WIDTH; // rd_dh_ecc_uncorrected_err
   localparam OUT19_W   = `MEMC_ECC_SYNDROME_WIDTH; // rd_dh_ecc_corr_syndromes

   localparam OUT20_W   = `MEMC_ECC_SYNDROME_WIDTH; // rd_dh_ecc_uncorr_syndromes
   localparam OUT21_W   = 7; // rd_dh_ecc_corrected_bit_num
   localparam OUT22_W   = `MEMC_ECC_SYNDROME_WIDTH; // rd_dh_ecc_corr_bit_mask
   localparam OUT23_W   = 16; // ddrc_reg_ecc_corr_err_cnt
   localparam OUT24_W   = 16; // ddrc_reg_ecc_uncorr_err_cnt
   localparam OUT25_W   = RANK_BITS_DUP; // rd_dh_ecc_corr_rank
   localparam OUT26_W   = RANK_BITS_DUP; // rd_dh_ecc_uncorr_rank
   localparam OUT27_W   = BANK_BITS; // rd_dh_ecc_corr_bank
   localparam OUT28_W   = BANK_BITS; // rd_dh_ecc_uncorr_bank
   localparam OUT29_W   = BG_BITS_DUP; // rd_dh_ecc_corr_bg

   localparam OUT30_W   = BG_BITS_DUP; // rd_dh_ecc_uncorr_bg 
   localparam OUT31_W   = CID_WIDTH_DUP; // rd_dh_ecc_corr_cid
   localparam OUT32_W   = CID_WIDTH_DUP; // rd_dh_ecc_uncorr_cid
   localparam OUT33_W   = ROW_BITS; // rd_dh_ecc_corr_row
   localparam OUT34_W   = ROW_BITS; // rd_dh_ecc_uncorr_row
   localparam OUT35_W   = COL_BITS; // rd_dh_ecc_corr_col
   localparam OUT36_W   = COL_BITS; // rd_dh_ecc_uncorr_col
   localparam OUT37_W   = 1; // ddrc_reg_advecc_corrected_err
   localparam OUT38_W   = 1; // ddrc_reg_advecc_uncorrected_err
   localparam OUT39_W   = ADVECC_NUM_ERR_SYMBOL_WIDTH; // ddrc_reg_advecc_num_err_symbol

   localparam OUT40_W   = ADVECC_ERR_SYMBOL_POS_WIDTH; // ddrc_reg_advecc_err_symbol_pos
   localparam OUT41_W   = ADVECC_ERR_SYMBOL_BITS_WIDTH; // ddrc_reg_advecc_err_symbol_bits
   localparam OUT42_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_eighth
   localparam OUT43_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_seventh
   localparam OUT44_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_sixth
   localparam OUT45_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_fifth
   localparam OUT46_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_fourth
   localparam OUT47_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_third
   localparam OUT48_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_second
   localparam OUT49_W   = SECDED_LANES_DUP; // rd_wu_ecc_uncorrected_err_first

   localparam OUT50_W   = CORE_ECC_WIDTH_DUP; // rd_ra_ecc_rdata
   localparam OUT51_W   = 1; // par_rdata_in_err_ecc_pulse
   localparam OUT52_W   = 1; // rd_wu_rdata_valid
   localparam OUT53_W   = WU_INFO_WIDTH; // rd_wu_info
   localparam OUT54_W   = 1; // rd_rw_rdata_valid
   localparam OUT55_W   = CORE_DATA_WIDTH; // rd_rw_rdata
   localparam OUT56_W   = UMCTL2_WDATARAM_PAR_DW; // rd_rw_rdata_par
   localparam OUT57_W   = WORD_BITS; // rd_wu_word_num
   localparam OUT58_W   = 1; // rd_wu_burst_chop_rd
   localparam OUT59_W   = 1; // rd_ra_rdata_valid

   localparam OUT60_W   = CORE_DATA_WIDTH; // rd_ra_rdata
   localparam OUT61_W   = CORE_MASK_WIDTH; // rd_ra_rdata_parity
   localparam OUT62_W   = 1; // rd_ra_eod
   localparam OUT63_W   = CMD_LEN_BITS; // rd_ra_eod
   localparam OUT64_W   = RA_INFO_WIDTH; // rd_ra_info
   localparam OUT65_W   = 1; // rd_ra_rd_addr_err
   localparam OUT66_W   = 1; // rd_mrr_data_valid
   localparam OUT67_W   = RD_MRR_DATA_W; // rd_mrr_data
   localparam OUT68_W   = 1; // rd_mr4_data_valid
   localparam OUT69_W   = `MEMC_DRAM_TOTAL_DATA_WIDTH; // ddrc_reg_mrr_data

   localparam OUT70_W   = 1; //ddrc_reg_mrr_done
   localparam OUT71_W   = RANK_BITS_DUP; // rd_dh_rd_crc_err_rank
   localparam OUT72_W   = CID_WIDTH_DUP; // rd_dh_rd_crc_err_cid
   localparam OUT73_W   = BG_BITS_DUP;   // rd_dh_rd_crc_err_bg
   localparam OUT74_W   = BANK_BITS;     // rd_dh_rd_crc_err_bank
   localparam OUT75_W   = ROW_BITS;      // rd_dh_rd_crc_err_row
   localparam OUT76_W   = COL_BITS;      // rd_dh_rd_crc_err_col
   localparam OUT77_W   = 1; // rd_dh_crc_poison_inject_complete
   localparam OUT78_W   = MAX_NUM_NIBBLES; // rd_dh_rd_crc_err_max_reached_int_nibble
   localparam OUT79_W   = 1; // rd_dh_rd_crc_err_max_reached_int
   
   localparam OUT80_W   = 1; // rd_crc_err
   localparam OUT81_W   = 12*MAX_NUM_NIBBLES; // rd_dh_rd_crc_err_cnt
   localparam OUT82_W   = 1; // ddrc_reg_linkecc_poison_complete
   localparam OUT83_W   = RD_LINK_ECC_UNCORR_CNT_WIDTH;   // ddrc_reg_rd_link_ecc_uncorr_cnt
   localparam OUT84_W   = RD_LINK_ECC_CORR_CNT_WIDTH;     // ddrc_reg_rd_link_ecc_corr_cnt
   localparam OUT85_W   = RD_LINK_ECC_ERR_SYNDROME_WIDTH; // ddrc_reg_rd_link_ecc_err_syndrome
   localparam OUT86_W   = 1; // rd_link_ecc_uncorr_err
   localparam OUT87_W   = RD_LINK_ECC_UNCORR_ERR_INT_WIDTH; // ddrc_reg_rd_link_ecc_uncorr_err_int
   localparam OUT88_W   = RD_LINK_ECC_CORR_ERR_INT_WIDTH;   // ddrc_reg_rd_link_ecc_corr_err_int
   localparam OUT89_W   = 8;   // rd_dh_ecc_cb_corr_syndromes
   localparam OUT90_W   = 8;   // rd_dh_ecc_cb_uncorr_syndromes
   localparam OUT91_W   = `DDRCTL_HIF_KBD_WIDTH;   // rd_ra_kbd 
   localparam OUT92_W   = `DDRCTL_HIF_KBD_WIDTH;   // rd_rw_kbd 
   localparam OUT93_W   = 1; //rd_dh_scrubber_read_ecc_ce
   localparam OUT94_W   = 1; //rd_dh_scrubber_read_ecc_ue
   localparam OUT95_W   = `DDRCTL_HIF_DRAM_ADDR_WIDTH; //rd_ra_rdata_dram_addr 
   localparam OUT96_W   = `MEMC_ECC_SYNDROME_WIDTH; // rd_dh_ecc_corr_rsd_data
   localparam OUT97_W   = `MEMC_ECC_SYNDROME_WIDTH; // rd_dh_ecc_uncorr_rsd_data
   localparam OUT98_W   = `MEMC_FREQ_RATIO/2; // ddrc_reg_advecc_ce_kbd_stat
   localparam OUT99_W  = `MEMC_FREQ_RATIO/2; // ddrc_reg_advecc_ue_kbd_stat
   localparam OUT100_W   = 1; //rd_dh_scrubber_read_advecc_ce
   localparam OUT101_W   = 1; //rd_dh_scrubber_read_advecc_ue
   localparam OUT102_W   = 1; //rd_ra_rdata_valid_retry
   localparam OUT103_W   = 1; //rd_ra_eod_retry
   localparam OUT104_W   = RA_INFO_WIDTH; //rd_ra_info_retry
   localparam OUT105_W   = 1; //rd_crc_err_retry
   localparam OUT106_W   = 1; //rd_ra_ecc_uncorrected_err_retry
   localparam OUT107_W   = ECC_CORR_ERR_PER_RANK_INTR_WIDTH; //ddrc_reg_ecc_corr_err_per_rank_intr
   localparam OUT108_W   = ECC_CORR_ERR_CNT_RANK_WIDTH; //ddrc_reg_ecc_corr_err_cnt_rank0
   localparam OUT109_W   = ECC_CORR_ERR_CNT_RANK_WIDTH; //ddrc_reg_ecc_corr_err_cnt_rank1
   localparam OUT110_W   = ECC_CORR_ERR_CNT_RANK_WIDTH; //ddrc_reg_ecc_corr_err_cnt_rank2
   localparam OUT111_W   = ECC_CORR_ERR_CNT_RANK_WIDTH; //ddrc_reg_ecc_corr_err_cnt_rank3
   localparam OUT112_W   = 1; // rd_wu_rdata_end
   localparam OUT113_W   = 1; // rd_wu_rd_crc_err
   localparam OUT114_W   = 1; // rd_wu_rdata_valid_retry
   localparam OUT115_W   = `DDRCTL_EAPAR_SIZE*SECDED_LANES;//ddrc_reg_eapar_error
   localparam OUT116_W   = 16; //ddrc_reg_eapar_err_cnt  
   localparam OUT117_W   = 1;  //rd_wu_eapar_err
   localparam OUT118_W   = 1;  //rd_ra_eapar_err
   localparam OUT119_W   = RANK_BITS_DUP;//ddrc_reg_eapar_err_rank
   localparam OUT120_W   = BANK_BITS;//ddrc_reg_eapar_err_bank
   localparam OUT121_W   = BG_BITS_DUP;//ddrc_reg_eapar_err_bg
   localparam OUT122_W   = CID_WIDTH_DUP;//ddrc_reg_eapar_err_cid
   localparam OUT123_W   = ROW_BITS;//ddrc_reg_eapar_err_row
   localparam OUT124_W   = COL_BITS;//ddrc_reg_eapar_err_col
   localparam OUT125_W   = `MEMC_ECC_SYNDROME_WIDTH;//ddrc_reg_eapar_err_syndromes 
   localparam OUT126_W   = 8;//ddrc_reg_eapar_err_cb_syndromes
   localparam OUT127_W   = 1;//ddrc_reg_eapar_err_sbr_rd
   localparam OUT128_W   = `DDRCTL_EAPAR_SIZE;//rd_wu_eapar
 
   localparam OUT0_OFF = OUT0_W;
   localparam OUT1_OFF = OUT0_OFF + OUT1_W;
   localparam OUT2_OFF = OUT1_OFF + OUT2_W;
   localparam OUT3_OFF = OUT2_OFF + OUT3_W;
   localparam OUT4_OFF = OUT3_OFF + OUT4_W;
   localparam OUT5_OFF = OUT4_OFF + OUT5_W;
   localparam OUT6_OFF = OUT5_OFF + OUT6_W;
   localparam OUT7_OFF = OUT6_OFF + OUT7_W;
   localparam OUT8_OFF = OUT7_OFF + OUT8_W;
   localparam OUT9_OFF = OUT8_OFF + OUT9_W;

   localparam OUT10_OFF = OUT9_OFF + OUT10_W;
   localparam OUT11_OFF = OUT10_OFF + OUT11_W;
   localparam OUT12_OFF = OUT11_OFF + OUT12_W;
   localparam OUT13_OFF = OUT12_OFF + OUT13_W;
   localparam OUT14_OFF = OUT13_OFF + OUT14_W;
   localparam OUT15_OFF = OUT14_OFF + OUT15_W;
   localparam OUT16_OFF = OUT15_OFF + OUT16_W;
   localparam OUT17_OFF = OUT16_OFF + OUT17_W;
   localparam OUT18_OFF = OUT17_OFF + OUT18_W;
   localparam OUT19_OFF = OUT18_OFF + OUT19_W;

   localparam OUT20_OFF = OUT19_OFF + OUT20_W;
   localparam OUT21_OFF = OUT20_OFF + OUT21_W;
   localparam OUT22_OFF = OUT21_OFF + OUT22_W;
   localparam OUT23_OFF = OUT22_OFF + OUT23_W;
   localparam OUT24_OFF = OUT23_OFF + OUT24_W;
   localparam OUT25_OFF = OUT24_OFF + OUT25_W;
   localparam OUT26_OFF = OUT25_OFF + OUT26_W;
   localparam OUT27_OFF = OUT26_OFF + OUT27_W;
   localparam OUT28_OFF = OUT27_OFF + OUT28_W;
   localparam OUT29_OFF = OUT28_OFF + OUT29_W;

   localparam OUT30_OFF = OUT29_OFF + OUT30_W;
   localparam OUT31_OFF = OUT30_OFF + OUT31_W;
   localparam OUT32_OFF = OUT31_OFF + OUT32_W;
   localparam OUT33_OFF = OUT32_OFF + OUT33_W;
   localparam OUT34_OFF = OUT33_OFF + OUT34_W;
   localparam OUT35_OFF = OUT34_OFF + OUT35_W;
   localparam OUT36_OFF = OUT35_OFF + OUT36_W;
   localparam OUT37_OFF = OUT36_OFF + OUT37_W;
   localparam OUT38_OFF = OUT37_OFF + OUT38_W;
   localparam OUT39_OFF = OUT38_OFF + OUT39_W;

   localparam OUT40_OFF = OUT39_OFF + OUT40_W;
   localparam OUT41_OFF = OUT40_OFF + OUT41_W;
   localparam OUT42_OFF = OUT41_OFF + OUT42_W;
   localparam OUT43_OFF = OUT42_OFF + OUT43_W;
   localparam OUT44_OFF = OUT43_OFF + OUT44_W;
   localparam OUT45_OFF = OUT44_OFF + OUT45_W;
   localparam OUT46_OFF = OUT45_OFF + OUT46_W;
   localparam OUT47_OFF = OUT46_OFF + OUT47_W;
   localparam OUT48_OFF = OUT47_OFF + OUT48_W;
   localparam OUT49_OFF = OUT48_OFF + OUT49_W;

   localparam OUT50_OFF = OUT49_OFF + OUT50_W;
   localparam OUT51_OFF = OUT50_OFF + OUT51_W;
   localparam OUT52_OFF = OUT51_OFF + OUT52_W;
   localparam OUT53_OFF = OUT52_OFF + OUT53_W;
   localparam OUT54_OFF = OUT53_OFF + OUT54_W;
   localparam OUT55_OFF = OUT54_OFF + OUT55_W;
   localparam OUT56_OFF = OUT55_OFF + OUT56_W;
   localparam OUT57_OFF = OUT56_OFF + OUT57_W;
   localparam OUT58_OFF = OUT57_OFF + OUT58_W;
   localparam OUT59_OFF = OUT58_OFF + OUT59_W;

   localparam OUT60_OFF = OUT59_OFF + OUT60_W;
   localparam OUT61_OFF = OUT60_OFF + OUT61_W;
   localparam OUT62_OFF = OUT61_OFF + OUT62_W;
   localparam OUT63_OFF = OUT62_OFF + OUT63_W;
   localparam OUT64_OFF = OUT63_OFF + OUT64_W;
   localparam OUT65_OFF = OUT64_OFF + OUT65_W;
   localparam OUT66_OFF = OUT65_OFF + OUT66_W;
   localparam OUT67_OFF = OUT66_OFF + OUT67_W;
   localparam OUT68_OFF = OUT67_OFF + OUT68_W;
   localparam OUT69_OFF = OUT68_OFF + OUT69_W;

   localparam OUT70_OFF = OUT69_OFF + OUT70_W;
   localparam OUT71_OFF = OUT70_OFF + OUT71_W;
   localparam OUT72_OFF = OUT71_OFF + OUT72_W;
   localparam OUT73_OFF = OUT72_OFF + OUT73_W;
   localparam OUT74_OFF = OUT73_OFF + OUT74_W;
   localparam OUT75_OFF = OUT74_OFF + OUT75_W;
   localparam OUT76_OFF = OUT75_OFF + OUT76_W;
   localparam OUT77_OFF = OUT76_OFF + OUT77_W;
   localparam OUT78_OFF = OUT77_OFF + OUT78_W;
   localparam OUT79_OFF = OUT78_OFF + OUT79_W;

   localparam OUT80_OFF = OUT79_OFF + OUT80_W;
   localparam OUT81_OFF = OUT80_OFF + OUT81_W;
   localparam OUT82_OFF = OUT81_OFF + OUT82_W;
   localparam OUT83_OFF = OUT82_OFF + OUT83_W;
   localparam OUT84_OFF = OUT83_OFF + OUT84_W;
   localparam OUT85_OFF = OUT84_OFF + OUT85_W;
   localparam OUT86_OFF = OUT85_OFF + OUT86_W;
   localparam OUT87_OFF = OUT86_OFF + OUT87_W;
   localparam OUT88_OFF = OUT87_OFF + OUT88_W;
   localparam OUT89_OFF = OUT88_OFF + OUT89_W;
   localparam OUT90_OFF = OUT89_OFF + OUT90_W;
   localparam OUT91_OFF = OUT90_OFF + OUT91_W;
   localparam OUT92_OFF = OUT91_OFF + OUT92_W;
   localparam OUT93_OFF = OUT92_OFF + OUT93_W;
   localparam OUT94_OFF = OUT93_OFF + OUT94_W;
   localparam OUT95_OFF = OUT94_OFF + OUT95_W;
   localparam OUT96_OFF = OUT95_OFF + OUT96_W;
   localparam OUT97_OFF = OUT96_OFF + OUT97_W;
   localparam OUT98_OFF = OUT97_OFF + OUT98_W;
   localparam OUT99_OFF = OUT98_OFF + OUT99_W;
   localparam OUT100_OFF = OUT99_OFF + OUT100_W;
   localparam OUT101_OFF = OUT100_OFF + OUT101_W;
   localparam OUT102_OFF = OUT101_OFF + OUT102_W;
   localparam OUT103_OFF = OUT102_OFF + OUT103_W;
   localparam OUT104_OFF = OUT103_OFF + OUT104_W;
   localparam OUT105_OFF = OUT104_OFF + OUT105_W;
   localparam OUT106_OFF = OUT105_OFF + OUT106_W;
   localparam OUT107_OFF = OUT106_OFF + OUT107_W;
   localparam OUT108_OFF = OUT107_OFF + OUT108_W;
   localparam OUT109_OFF = OUT108_OFF + OUT109_W;
   localparam OUT110_OFF = OUT109_OFF + OUT110_W;
   localparam OUT111_OFF = OUT110_OFF + OUT111_W;
   localparam OUT112_OFF = OUT111_OFF + OUT112_W;
   localparam OUT113_OFF = OUT112_OFF + OUT113_W;
   localparam OUT114_OFF = OUT113_OFF + OUT114_W;
   localparam OUT115_OFF = OUT114_OFF + OUT115_W;

   localparam OUT116_OFF = OUT115_OFF + OUT116_W;
   localparam OUT117_OFF = OUT116_OFF + OUT117_W;
   localparam OUT118_OFF = OUT117_OFF + OUT118_W;
   localparam OUT119_OFF = OUT118_OFF + OUT119_W;
   localparam OUT120_OFF = OUT119_OFF + OUT120_W;
   localparam OUT121_OFF = OUT120_OFF + OUT121_W;
   localparam OUT122_OFF = OUT121_OFF + OUT122_W;
   localparam OUT123_OFF = OUT122_OFF + OUT123_W;
   localparam OUT124_OFF = OUT123_OFF + OUT124_W;
   localparam OUT125_OFF = OUT124_OFF + OUT125_W;
   localparam OUT126_OFF = OUT125_OFF + OUT126_W;
   localparam OUT127_OFF = OUT126_OFF + OUT127_W;
   localparam OUT128_OFF = OUT127_OFF + OUT128_W;
   localparam OUT_TOTW = OUT128_OFF;

   localparam [NUM_OUTS*PW-1:0] WIDTH_OFFSET =
                                              (OUT128_OFF<<128*PW)+
                                              (OUT127_OFF<<127*PW)+
                                              (OUT126_OFF<<126*PW)+
                                              (OUT125_OFF<<125*PW)+
                                              (OUT124_OFF<<124*PW)+
                                              (OUT123_OFF<<123*PW)+
                                              (OUT122_OFF<<122*PW)+
                                              (OUT121_OFF<<121*PW)+
                                              (OUT120_OFF<<120*PW)+
                                              (OUT119_OFF<<119*PW)+
                                              (OUT118_OFF<<118*PW)+
                                              (OUT117_OFF<<117*PW)+
                                              (OUT116_OFF<<116*PW)+
                                              (OUT115_OFF<<115*PW)+
                                              (OUT114_OFF<<114*PW)+
                                              (OUT113_OFF<<113*PW)+
                                              (OUT112_OFF<<112*PW)+
                                              (OUT111_OFF<<111*PW)+
                                              (OUT110_OFF<<110*PW)+
                                              (OUT109_OFF<<109*PW)+
                                              (OUT108_OFF<<108*PW)+
                                              (OUT107_OFF<<107*PW)+
                                              (OUT106_OFF<<106*PW)+
                                              (OUT105_OFF<<105*PW)+
                                              (OUT104_OFF<<104*PW)+
                                              (OUT103_OFF<<103*PW)+
                                              (OUT102_OFF<<102*PW)+
                                              (OUT101_OFF<<101*PW)+
                                              (OUT100_OFF<<100*PW)+
                                              (OUT99_OFF<<99*PW)+
                                              (OUT98_OFF<<98*PW)+
                                              (OUT97_OFF<<97*PW)+
                                              (OUT96_OFF<<96*PW)+
                                              (OUT95_OFF<<95*PW)+
                                              (OUT94_OFF<<94*PW)+
                                              (OUT93_OFF<<93*PW)+
                                              (OUT92_OFF<<92*PW)+
                                              (OUT91_OFF<<91*PW)+
                                              (OUT90_OFF<<90*PW)+
                                              (OUT89_OFF<<89*PW)+
                                              (OUT88_OFF<<88*PW)+
                                              (OUT87_OFF<<87*PW)+
                                              (OUT86_OFF<<86*PW)+
                                              (OUT85_OFF<<85*PW)+
                                              (OUT84_OFF<<84*PW)+
                                              (OUT83_OFF<<83*PW)+
                                              (OUT82_OFF<<82*PW)+
                                              (OUT81_OFF<<81*PW)+
                                              (OUT80_OFF<<80*PW)+

                                              (OUT79_OFF<<79*PW)+
                                              (OUT78_OFF<<78*PW)+
                                              (OUT77_OFF<<77*PW)+
                                              (OUT76_OFF<<76*PW)+
                                              (OUT75_OFF<<75*PW)+
                                              (OUT74_OFF<<74*PW)+
                                              (OUT73_OFF<<73*PW)+
                                              (OUT72_OFF<<72*PW)+
                                              (OUT71_OFF<<71*PW)+
                                              (OUT70_OFF<<70*PW)+

                                              (OUT69_OFF<<69*PW)+
                                              (OUT68_OFF<<68*PW)+
                                              (OUT67_OFF<<67*PW)+
                                              (OUT66_OFF<<66*PW)+
                                              (OUT65_OFF<<65*PW)+
                                              (OUT64_OFF<<64*PW)+
                                              (OUT63_OFF<<63*PW)+
                                              (OUT62_OFF<<62*PW)+
                                              (OUT61_OFF<<61*PW)+
                                              (OUT60_OFF<<60*PW)+

                                              (OUT59_OFF<<59*PW)+
                                              (OUT58_OFF<<58*PW)+
                                              (OUT57_OFF<<57*PW)+
                                              (OUT56_OFF<<56*PW)+
                                              (OUT55_OFF<<55*PW)+
                                              (OUT54_OFF<<54*PW)+
                                              (OUT53_OFF<<53*PW)+
                                              (OUT52_OFF<<52*PW)+
                                              (OUT51_OFF<<51*PW)+
                                              (OUT50_OFF<<50*PW)+

                                              (OUT49_OFF<<49*PW)+
                                              (OUT48_OFF<<48*PW)+
                                              (OUT47_OFF<<47*PW)+
                                              (OUT46_OFF<<46*PW)+
                                              (OUT45_OFF<<45*PW)+
                                              (OUT44_OFF<<44*PW)+
                                              (OUT43_OFF<<43*PW)+
                                              (OUT42_OFF<<42*PW)+
                                              (OUT41_OFF<<41*PW)+
                                              (OUT40_OFF<<40*PW)+

                                              (OUT39_OFF<<39*PW)+
                                              (OUT38_OFF<<38*PW)+
                                              (OUT37_OFF<<37*PW)+
                                              (OUT36_OFF<<36*PW)+
                                              (OUT35_OFF<<35*PW)+
                                              (OUT34_OFF<<34*PW)+
                                              (OUT33_OFF<<33*PW)+
                                              (OUT32_OFF<<32*PW)+
                                              (OUT31_OFF<<31*PW)+
                                              (OUT30_OFF<<30*PW)+
                                              (OUT29_OFF<<29*PW)+
                                              (OUT28_OFF<<28*PW)+
                                              (OUT27_OFF<<27*PW)+
                                              (OUT26_OFF<<26*PW)+
                                              (OUT25_OFF<<25*PW)+
                                              (OUT24_OFF<<24*PW)+
                                              (OUT23_OFF<<23*PW)+
                                              (OUT22_OFF<<22*PW)+
                                              (OUT21_OFF<<21*PW)+
                                              (OUT20_OFF<<20*PW)+
                                              (OUT19_OFF<<19*PW)+
                                              (OUT18_OFF<<18*PW)+
                                              (OUT17_OFF<<17*PW)+
                                              (OUT16_OFF<<16*PW)+
                                              (OUT15_OFF<<15*PW)+
                                              (OUT14_OFF<<14*PW)+
                                              (OUT13_OFF<<13*PW)+
                                              (OUT12_OFF<<12*PW)+
                                              (OUT11_OFF<<11*PW)+
                                              (OUT10_OFF<<10*PW)+
                                              (OUT9_OFF<<9*PW)+
                                              (OUT8_OFF<<8*PW)+
                                              (OUT7_OFF<<7*PW)+
                                              (OUT6_OFF<<6*PW)+
                                              (OUT5_OFF<<5*PW)+
                                              (OUT4_OFF<<4*PW)+
                                              (OUT3_OFF<<3*PW)+
                                              (OUT2_OFF<<2*PW)+
                                              (OUT1_OFF<<1*PW)+
                                              OUT0_OFF;


    localparam [NUM_OUTS*PW-1:0] WIDTH_ARRAY =
                                              (OUT128_W<<128*PW)+
                                              (OUT127_W<<127*PW)+
                                              (OUT126_W<<126*PW)+
                                              (OUT125_W<<125*PW)+
                                              (OUT124_W<<124*PW)+
                                              (OUT123_W<<123*PW)+
                                              (OUT122_W<<122*PW)+
                                              (OUT121_W<<121*PW)+
                                              (OUT120_W<<120*PW)+
                                              (OUT119_W<<119*PW)+
                                              (OUT118_W<<118*PW)+
                                              (OUT117_W<<117*PW)+
                                              (OUT116_W<<116*PW)+
                                              (OUT115_W<<115*PW)+    
                                              (OUT114_W<<114*PW)+
                                              (OUT113_W<<113*PW)+
                                              (OUT112_W<<112*PW)+
                                              (OUT111_W<<111*PW)+
                                              (OUT110_W<<110*PW)+
                                              (OUT109_W<<109*PW)+
                                              (OUT108_W<<108*PW)+
                                              (OUT107_W<<107*PW)+
                                              (OUT106_W<<106*PW)+
                                              (OUT105_W<<105*PW)+
                                              (OUT104_W<<104*PW)+
                                              (OUT103_W<<103*PW)+
                                              (OUT102_W<<102*PW)+
                                              (OUT101_W<<101*PW)+
                                              (OUT100_W<<100*PW)+
                                              (OUT99_W<<99*PW)+
                                              (OUT98_W<<98*PW)+
                                              (OUT97_W<<97*PW)+
                                              (OUT96_W<<96*PW)+
                                              (OUT95_W<<95*PW)+
                                              (OUT94_W<<94*PW)+
                                              (OUT93_W<<93*PW)+
                                              (OUT92_W<<92*PW)+
                                              (OUT91_W<<91*PW)+
                                              (OUT90_W<<90*PW)+
                                              (OUT89_W<<89*PW)+
                                              (OUT88_W<<88*PW)+
                                              (OUT87_W<<87*PW)+
                                              (OUT86_W<<86*PW)+
                                              (OUT85_W<<85*PW)+
                                              (OUT84_W<<84*PW)+
                                              (OUT83_W<<83*PW)+
                                              (OUT82_W<<82*PW)+
                                              (OUT81_W<<81*PW)+
                                              (OUT80_W<<80*PW)+

                                              (OUT79_W<<79*PW)+
                                              (OUT78_W<<78*PW)+
                                              (OUT77_W<<77*PW)+
                                              (OUT76_W<<76*PW)+
                                              (OUT75_W<<75*PW)+
                                              (OUT74_W<<74*PW)+
                                              (OUT73_W<<73*PW)+
                                              (OUT72_W<<72*PW)+
                                              (OUT71_W<<71*PW)+
                                              (OUT70_W<<70*PW)+

                                              (OUT69_W<<69*PW)+
                                              (OUT68_W<<68*PW)+
                                              (OUT67_W<<67*PW)+
                                              (OUT66_W<<66*PW)+
                                              (OUT65_W<<65*PW)+
                                              (OUT64_W<<64*PW)+
                                              (OUT63_W<<63*PW)+
                                              (OUT62_W<<62*PW)+
                                              (OUT61_W<<61*PW)+
                                              (OUT60_W<<60*PW)+

                                              (OUT59_W<<59*PW)+
                                              (OUT58_W<<58*PW)+
                                              (OUT57_W<<57*PW)+
                                              (OUT56_W<<56*PW)+
                                              (OUT55_W<<55*PW)+
                                              (OUT54_W<<54*PW)+
                                              (OUT53_W<<53*PW)+
                                              (OUT52_W<<52*PW)+
                                              (OUT51_W<<51*PW)+
                                              (OUT50_W<<50*PW)+

                                              (OUT49_W<<49*PW)+
                                              (OUT48_W<<48*PW)+
                                              (OUT47_W<<47*PW)+
                                              (OUT46_W<<46*PW)+
                                              (OUT45_W<<45*PW)+
                                              (OUT44_W<<44*PW)+
                                              (OUT43_W<<43*PW)+
                                              (OUT42_W<<42*PW)+
                                              (OUT41_W<<41*PW)+
                                              (OUT40_W<<40*PW)+

                                              (OUT39_W<<39*PW)+
                                              (OUT38_W<<38*PW)+
                                              (OUT37_W<<37*PW)+
                                              (OUT36_W<<36*PW)+
                                              (OUT35_W<<35*PW)+
                                              (OUT34_W<<34*PW)+
                                              (OUT33_W<<33*PW)+
                                              (OUT32_W<<32*PW)+
                                              (OUT31_W<<31*PW)+
                                              (OUT30_W<<30*PW)+
                                              (OUT29_W<<29*PW)+
                                              (OUT28_W<<28*PW)+
                                              (OUT27_W<<27*PW)+
                                              (OUT26_W<<26*PW)+
                                              (OUT25_W<<25*PW)+
                                              (OUT24_W<<24*PW)+
                                              (OUT23_W<<23*PW)+
                                              (OUT22_W<<22*PW)+
                                              (OUT21_W<<21*PW)+
                                              (OUT20_W<<20*PW)+
                                              (OUT19_W<<19*PW)+
                                              (OUT18_W<<18*PW)+
                                              (OUT17_W<<17*PW)+
                                              (OUT16_W<<16*PW)+
                                              (OUT15_W<<15*PW)+
                                              (OUT14_W<<14*PW)+
                                              (OUT13_W<<13*PW)+
                                              (OUT12_W<<12*PW)+
                                              (OUT11_W<<11*PW)+
                                              (OUT10_W<<10*PW)+
                                              (OUT9_W<<9*PW)+
                                              (OUT8_W<<8*PW)+
                                              (OUT7_W<<7*PW)+
                                              (OUT6_W<<6*PW)+
                                              (OUT5_W<<5*PW)+
                                              (OUT4_W<<4*PW)+
                                              (OUT3_W<<3*PW)+
                                              (OUT2_W<<2*PW)+
                                              (OUT1_W<<1*PW)+
                                              OUT0_W;
//---------------------------- PARAMETERS --------------------------------------

//-------------------------------- WIRES ---------------------------------------

   //----------------------- COMPONENT INSTANTIATIONS -----------------------------

  genvar n;


   wire                           rd_ih_free_brt_vld_w [NUM_INST-1:0];
   wire  [BRT_BITS-1:0]           rd_ih_free_brt_w [NUM_INST-1:0];
   wire                           rd_ecc_ram_wr_w [NUM_INST-1:0];
   wire  [ECC_RAM_ADDR_BITS-1:0]  rd_ecc_ram_waddr_w [NUM_INST-1:0];
   wire  [CORE_DATA_WIDTH-1:0]    rd_ecc_ram_wdata_w [NUM_INST-1:0];
   wire  [CORE_MASK_WIDTH-1:0]    rd_ecc_ram_wdata_mask_n_w [NUM_INST-1:0];
   wire  [CORE_MASK_WIDTH-1:0]    rd_ecc_ram_wdata_par_w [NUM_INST-1:0];
   wire  [ECC_RAM_ADDR_BITS-1:0]  rd_ecc_ram_raddr_w [NUM_INST-1:0];
   wire  [ECC_RAM_ADDR_BITS-1:0]  rd_ecc_acc_raddr_2_w [NUM_INST-1:0];
   wire  [ECC_ERR_RAM_WIDTH-1:0]      ecc_err_mr_rdata_w [NUM_INST-1:0];
   wire  [BT_BITS-1:0]     rd_ih_lkp_bwt_by_bt_w [NUM_INST-1:0];
   wire  [BT_BITS-1:0]     rd_ih_lkp_brt_by_bt_w [NUM_INST-1:0];
   wire                           ddrc_reg_ecc_ap_err_w [NUM_INST-1:0];
   wire                           rd_wu_ecc_corrected_err_w [NUM_INST-1:0];
   wire                           rd_wu_ecc_uncorrected_err_w [NUM_INST-1:0];
   wire                           rd_ra_ecc_corrected_err_w [NUM_INST-1:0];
   wire                           rd_ra_ecc_uncorrected_err_w [NUM_INST-1:0];
   wire   [ECC_CORRECTED_ERR_WIDTH-1:0]        rd_dh_ecc_corrected_err_w [NUM_INST-1:0];
   wire   [ECC_UNCORRECTED_ERR_WIDTH-1:0]      rd_dh_ecc_uncorrected_err_w [NUM_INST-1:0];
   wire   [`MEMC_ECC_SYNDROME_WIDTH-1:0]  rd_dh_ecc_corr_syndromes_w [NUM_INST-1:0];
   wire   [`MEMC_ECC_SYNDROME_WIDTH-1:0]  rd_dh_ecc_uncorr_syndromes_w [NUM_INST-1:0];
   wire   [6:0]                           rd_dh_ecc_corrected_bit_num_w [NUM_INST-1:0];
   wire   [`MEMC_ECC_SYNDROME_WIDTH-1:0]  rd_dh_ecc_corr_bit_mask_w [NUM_INST-1:0];
   wire   [15:0]                  ddrc_reg_ecc_corr_err_cnt_w [NUM_INST-1:0];
   wire   [15:0]                  ddrc_reg_ecc_uncorr_err_cnt_w [NUM_INST-1:0];
   wire   [RANK_BITS_DUP-1:0]     rd_dh_ecc_corr_rank_w [NUM_INST-1:0];
   wire   [RANK_BITS_DUP-1:0]     rd_dh_ecc_uncorr_rank_w [NUM_INST-1:0];
   wire   [BANK_BITS-1:0]         rd_dh_ecc_corr_bank_w [NUM_INST-1:0];
   wire   [BANK_BITS-1:0]         rd_dh_ecc_uncorr_bank_w [NUM_INST-1:0];
   wire   [BG_BITS_DUP-1:0]       rd_dh_ecc_corr_bg_w [NUM_INST-1:0];
   wire   [BG_BITS_DUP-1:0]       rd_dh_ecc_uncorr_bg_w [NUM_INST-1:0];
   wire   [CID_WIDTH_DUP-1:0]     rd_dh_ecc_corr_cid_w [NUM_INST-1:0];
   wire   [CID_WIDTH_DUP-1:0]     rd_dh_ecc_uncorr_cid_w [NUM_INST-1:0];
   wire   [ROW_BITS-1:0]          rd_dh_ecc_corr_row_w [NUM_INST-1:0];
   wire   [ROW_BITS-1:0]          rd_dh_ecc_uncorr_row_w [NUM_INST-1:0];
   wire   [COL_BITS-1:0]          rd_dh_ecc_corr_col_w [NUM_INST-1:0];
   wire   [COL_BITS-1:0]          rd_dh_ecc_uncorr_col_w [NUM_INST-1:0];
   wire                                                          ddrc_reg_advecc_corrected_err_w [NUM_INST-1:0];
   wire                                                          ddrc_reg_advecc_uncorrected_err_w [NUM_INST-1:0];
   wire  [ADVECC_NUM_ERR_SYMBOL_WIDTH-1:0] ddrc_reg_advecc_num_err_symbol_w [NUM_INST-1:0];
   wire  [ADVECC_ERR_SYMBOL_POS_WIDTH-1:0] ddrc_reg_advecc_err_symbol_pos_w [NUM_INST-1:0];
   wire  [ADVECC_ERR_SYMBOL_BITS_WIDTH-1:0] ddrc_reg_advecc_err_symbol_bits_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_eighth_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_seventh_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_sixth_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_fifth_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_fourth_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_third_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_second_w [NUM_INST-1:0];
   wire      [SECDED_LANES_DUP-1:0]   rd_wu_ecc_uncorrected_err_first_w [NUM_INST-1:0];
   wire                               rd_wu_rd_crc_err_w [NUM_INST-1:0];
   wire      [CORE_ECC_WIDTH_DUP-1:0] rd_ra_ecc_rdata_w [NUM_INST-1:0];
   wire                               par_rdata_in_err_ecc_pulse_w [NUM_INST-1:0];
   wire                              rd_wu_rdata_valid_w [NUM_INST-1:0];
   wire                              rd_wu_rdata_end_w [NUM_INST-1:0];
   wire      [WU_INFO_WIDTH-1:0]     rd_wu_info_w [NUM_INST-1:0];
   wire                              rd_rw_rdata_valid_w [NUM_INST-1:0];
   wire      [CORE_DATA_WIDTH-1:0]   rd_rw_rdata_w [NUM_INST-1:0];
   wire      [UMCTL2_WDATARAM_PAR_DW-1:0]   rd_rw_rdata_par_w [NUM_INST-1:0];
   wire      [WORD_BITS-1:0]         rd_wu_word_num_w [NUM_INST-1:0];
   wire                              rd_wu_burst_chop_rd_w [NUM_INST-1:0];
   wire                              rd_ra_rdata_valid_w [NUM_INST-1:0];
   wire      [CORE_DATA_WIDTH-1:0]   rd_ra_rdata_w [NUM_INST-1:0];
   wire      [CORE_MASK_WIDTH-1:0]   rd_ra_rdata_parity_w [NUM_INST-1:0];
   wire                              rd_ra_eod_w [NUM_INST-1:0];
   wire      [CMD_LEN_BITS-1:0]      rd_wu_partial_w [NUM_INST-1:0];
   wire      [RA_INFO_WIDTH-1:0]     rd_ra_info_w [NUM_INST-1:0];
   wire                              rd_ra_rd_addr_err_w [NUM_INST-1:0];
   wire                              rd_mrr_data_valid_w [NUM_INST-1:0];
   wire   [RD_MRR_DATA_W-1:0]        rd_mrr_data_w [NUM_INST-1:0];
   wire                              rd_mr4_data_valid_w [NUM_INST-1:0];
   wire      [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]  ddrc_reg_mrr_data_w [NUM_INST-1:0];
   wire                              ddrc_reg_mrr_done_w [NUM_INST-1:0];
   wire      [RANK_BITS_DUP-1:0]     rd_dh_rd_crc_err_rank_w [NUM_INST-1:0];
   wire      [CID_WIDTH_DUP-1:0]     rd_dh_rd_crc_err_cid_w [NUM_INST-1:0];
   wire      [BG_BITS_DUP-1:0]       rd_dh_rd_crc_err_bg_w [NUM_INST-1:0];
   wire      [BANK_BITS-1:0]         rd_dh_rd_crc_err_bank_w [NUM_INST-1:0];
   wire      [ROW_BITS-1:0]          rd_dh_rd_crc_err_row_w [NUM_INST-1:0];
   wire      [COL_BITS-1:0]          rd_dh_rd_crc_err_col_w [NUM_INST-1:0];
   wire                              rd_dh_crc_poison_inject_complete_w [NUM_INST-1:0];
   wire      [MAX_NUM_NIBBLES-1:0]   rd_dh_rd_crc_err_max_reached_int_nibble_w [NUM_INST-1:0];
   wire                              rd_dh_rd_crc_err_max_reached_int_w [NUM_INST-1:0];
   wire      [MAX_NUM_NIBBLES*12-1:0] rd_dh_rd_crc_err_cnt_nibble_w [NUM_INST-1:0];
   wire                              rd_crc_err_w [NUM_INST-1:0];
   wire                                             ddrc_reg_rd_linkecc_poison_complete_w [NUM_INST-1:0];
   wire      [RD_LINK_ECC_UNCORR_CNT_WIDTH    -1:0] ddrc_reg_rd_link_ecc_uncorr_cnt_w [NUM_INST-1:0];
   wire      [RD_LINK_ECC_CORR_CNT_WIDTH      -1:0] ddrc_reg_rd_link_ecc_corr_cnt_w [NUM_INST-1:0];
   wire      [RD_LINK_ECC_ERR_SYNDROME_WIDTH  -1:0] ddrc_reg_rd_link_ecc_err_syndrome_w [NUM_INST-1:0];
   wire                                             rd_link_ecc_uncorr_err_w [NUM_INST-1:0];
   wire      [RD_LINK_ECC_UNCORR_ERR_INT_WIDTH-1:0] ddrc_reg_rd_link_ecc_uncorr_err_int_w [NUM_INST-1:0];
   wire      [RD_LINK_ECC_CORR_ERR_INT_WIDTH  -1:0] ddrc_reg_rd_link_ecc_corr_err_int_w [NUM_INST-1:0];
   wire                                       [7:0] rd_dh_ecc_cb_corr_syndromes_w [NUM_INST-1:0];
   wire                                       [7:0] rd_dh_ecc_cb_uncorr_syndromes_w [NUM_INST-1:0];
   wire      [`DDRCTL_HIF_KBD_WIDTH           -1:0] rd_ra_kbd_w [NUM_INST-1:0];
   wire      [`DDRCTL_HIF_KBD_WIDTH           -1:0] rd_rw_kbd_w [NUM_INST-1:0];
   wire                                             rd_dh_scrubber_read_ecc_ce_w [NUM_INST-1:0];                                          
   wire                                             rd_dh_scrubber_read_ecc_ue_w [NUM_INST-1:0];                                          
   wire      [`DDRCTL_HIF_DRAM_ADDR_WIDTH     -1:0] rd_ra_rdata_dram_addr_w [NUM_INST-1:0];
   wire      [`MEMC_ECC_SYNDROME_WIDTH        -1:0] rd_dh_ecc_corr_rsd_data_w [NUM_INST-1:0];
   wire      [`MEMC_ECC_SYNDROME_WIDTH        -1:0] rd_dh_ecc_uncorr_rsd_data_w [NUM_INST-1:0];
   wire      [`MEMC_FREQ_RATIO/2              -1:0] ddrc_reg_advecc_ce_kbd_stat_w [NUM_INST-1:0];
   wire      [`MEMC_FREQ_RATIO/2              -1:0] ddrc_reg_advecc_ue_kbd_stat_w [NUM_INST-1:0];
   wire                                             rd_dh_scrubber_read_advecc_ce_w [NUM_INST-1:0];                                          
   wire                                             rd_dh_scrubber_read_advecc_ue_w [NUM_INST-1:0];                                          
   wire                                             rd_ra_rdata_valid_retry_w [NUM_INST-1:0];
   wire                                             rd_wu_rdata_valid_retry_w [NUM_INST-1:0];
   wire                                             rd_ra_eod_retry_w [NUM_INST-1:0];
   wire      [RA_INFO_WIDTH-1:0]                    rd_ra_info_retry_w [NUM_INST-1:0];
   wire                                             rd_crc_err_retry_w [NUM_INST-1:0];
   wire                                             rd_ra_ecc_uncorrected_err_retry_w [NUM_INST-1:0];


   wire [ECC_CORR_ERR_PER_RANK_INTR_WIDTH-1:0]      ddrc_reg_ecc_corr_intr_sts_w[NUM_INST-1:0];
   wire [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]           ddrc_reg_ecc_corr_err_cnt_rank0_w[NUM_INST-1:0];
   wire [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]           ddrc_reg_ecc_corr_err_cnt_rank1_w[NUM_INST-1:0];
   wire [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]           ddrc_reg_ecc_corr_err_cnt_rank2_w[NUM_INST-1:0];
   wire [ECC_CORR_ERR_CNT_RANK_WIDTH-1:0]           ddrc_reg_ecc_corr_err_cnt_rank3_w[NUM_INST-1:0];

   wire [`DDRCTL_EAPAR_SIZE*SECDED_LANES-1:0]   ddrc_reg_eapar_error_w[NUM_INST-1:0];
   wire [15:0]                              ddrc_reg_eapar_err_cnt_w[NUM_INST-1:0];      // Count of correctable ECC errors// 
   wire [`DDRCTL_EAPAR_SIZE-1:0]            rd_wu_eapar_w[NUM_INST-1:0];
   wire                                     rd_wu_eapar_err_w[NUM_INST-1:0];
   wire                                     rd_ra_eapar_err_w[NUM_INST-1:0];
   wire  [RANK_BITS_DUP-1:0]                ddrc_reg_eapar_err_rank_w[NUM_INST-1:0];
   wire  [BANK_BITS-1:0]                    ddrc_reg_eapar_err_bank_w[NUM_INST-1:0];
   wire  [BG_BITS_DUP-1:0]                  ddrc_reg_eapar_err_bg_w[NUM_INST-1:0];
   wire  [CID_WIDTH_DUP-1:0]                ddrc_reg_eapar_err_cid_w[NUM_INST-1:0];
   wire  [ROW_BITS-1:0]                     ddrc_reg_eapar_err_row_w[NUM_INST-1:0];
   wire  [COL_BITS-1:0]                     ddrc_reg_eapar_err_col_w[NUM_INST-1:0];
   wire  [`MEMC_ECC_SYNDROME_WIDTH-1:0]     ddrc_reg_eapar_err_syndromes_w[NUM_INST-1:0]; 
   wire  [7:0]                              ddrc_reg_eapar_err_cb_syndromes_w[NUM_INST-1:0];
   wire                                     ddrc_reg_eapar_err_sbr_rd_w[NUM_INST-1:0];   
  // output assign drivwen from inst0
  assign par_rdata_in_err_ecc_pulse = par_rdata_in_err_ecc_pulse_w[0];
  assign rd_wu_rdata_end = rd_wu_rdata_end_w[0];
  assign rd_wu_rdata_valid = rd_wu_rdata_valid_w[0];
  assign rd_wu_info = rd_wu_info_w[0];
  assign rd_rw_rdata_valid = rd_rw_rdata_valid_w[0];
  assign rd_rw_rdata = rd_rw_rdata_w[0];
  assign rd_rw_rdata_par = rd_rw_rdata_par_w[0];
  assign rd_ra_rdata_valid = rd_ra_rdata_valid_w[0];
  assign rd_ra_rdata = rd_ra_rdata_w[0];
  assign rd_ra_rdata_parity = rd_ra_rdata_parity_w[0];
  assign rd_ra_eod = rd_ra_eod_w[0];
  assign rd_wu_partial = rd_wu_partial_w[0];
  assign rd_ra_info = rd_ra_info_w[0];
  assign rd_ra_rd_addr_err = rd_ra_rd_addr_err_w[0];
  assign rd_mrr_data_valid = rd_mrr_data_valid_w[0];
  assign rd_mrr_data = rd_mrr_data_w[0];
  assign rd_mr4_data_valid = rd_mr4_data_valid_w[0];
  assign ddrc_reg_mrr_data = ddrc_reg_mrr_data_w[0];
  assign ddrc_reg_mrr_done = ddrc_reg_mrr_done_w[0];


//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4




  generate
    for (n=0; n<NUM_INST; n=n+1) begin: rd_inst
 
      rd
            #(
                 .CMD_LEN_BITS                  (CMD_LEN_BITS)
                ,.PHY_DATA_WIDTH                (PHY_DATA_WIDTH)
                ,.PHY_DBI_WIDTH                 (PHY_DBI_WIDTH)
                ,.CORE_DATA_WIDTH               (CORE_DATA_WIDTH)
                ,.RMW_TYPE_BITS                 (RMW_TYPE_BITS)
                ,.RA_INFO_WIDTH                 (RA_INFO_WIDTH)
                ,.ECC_INFO_WIDTH                (ECC_INFO_WIDTH)
                ,.CRC_INFO_WIDTH                (CRC_INFO_WIDTH)
                ,.WU_INFO_WIDTH                 (WU_INFO_WIDTH)
                ,.BT_BITS                       (BT_BITS           )
                ,.BRT_BITS                      (BRT_BITS          )
                ,.ECC_RAM_DEPTH                 (ECC_RAM_DEPTH     )
                ,.ECC_RAM_ADDR_BITS             (ECC_RAM_ADDR_BITS )
                ,.ECC_ERR_RAM_WIDTH             (ECC_ERR_RAM_WIDTH ) 
                ,.OCPAR_EN                      (OCPAR_EN)
                ,.CORE_MASK_WIDTH               (CORE_MASK_WIDTH)
                
                ,.OCECC_EN                      (OCECC_EN)
                ,.OCECC_XPI_RD_GRANU            (OCECC_XPI_RD_GRANU)
                ,.OCECC_MR_RD_GRANU             (OCECC_MR_RD_GRANU)
                ,.OCECC_MR_BNUM_WIDTH           (OCECC_MR_BNUM_WIDTH)
                ,.UMCTL2_WDATARAM_PAR_DW        (UMCTL2_WDATARAM_PAR_DW)

                ,.RANK_BITS                     (RANK_BITS)
                ,.LRANK_BITS                    (LRANK_BITS)
                ,.CID_WIDTH                     (CID_WIDTH)
                ,.BG_BITS                       (BG_BITS)
                ,.BANK_BITS                     (BANK_BITS)
                ,.BG_BANK_BITS                  (BG_BANK_BITS)
                ,.ROW_BITS                      (ROW_BITS)
                ,.WORD_BITS                     (WORD_BITS)
                ,.BLK_BITS                      (BLK_BITS)
                ,.COL_BITS                      (COL_BITS)

                ,.CORE_ECC_WIDTH                (CORE_ECC_WIDTH)
                
                ,.SECDED_1B_LANE_WIDTH          (SECDED_1B_LANE_WIDTH)
                
                ,.ECC_LANE_WIDTH_1B             (ECC_LANE_WIDTH_1B)
                ,.SECDED_CORESIDE_LANE_WIDTH    (SECDED_CORESIDE_LANE_WIDTH)

                ,.SECDED_LANES                  (SECDED_LANES)
                ,.ECC_BITS                      (ECC_BITS)

                ,.RANK_BITS_DUP                 (RANK_BITS_DUP)
                ,.BG_BITS_DUP                   (BG_BITS_DUP)
                ,.CID_WIDTH_DUP                 (CID_WIDTH_DUP)
                ,.CORE_ECC_WIDTH_DUP            (CORE_ECC_WIDTH_DUP)                              
                ,.SECDED_LANES_DUP              (SECDED_LANES_DUP)

                ,.RD_IE_PAR_ERR_PIPELINE        (CMP_REG) // set by OCCAP_PIPELINE_EN at higher level
                ,.MAX_NUM_NIBBLES               (MAX_NUM_NIBBLES)
                ,.DRAM_BYTE_NUM                 (DRAM_BYTE_NUM)
               )

        rd (
                .co_yy_clk                      (co_yy_clk),
                .core_ddrc_rstn                 (core_ddrc_rstn),
                .ddrc_cg_en                     (ddrc_cg_en),
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
                .dh_rd_frequency_ratio          (dh_rd_frequency_ratio),
                .reg_ddrc_lpddr4                (reg_ddrc_lpddr4),
                .reg_ddrc_lpddr5                (reg_ddrc_lpddr5),
                .ph_rd_rdbi_n                   (ph_rd_rdbi_n), // full bus width used
                .ph_rd_rdata                    (ph_rd_rdata),  // full bus width used
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
                .rt_rd_rd_valid                 (rt_rd_rd_valid),               // read data valid from PHY
                .rt_rd_eod                      (rt_rd_eod),
                .rt_rd_partial                  (rt_rd_partial),                // this read is partial
                .rt_rd_ra_info                  (rt_rd_ra_info),
                .rt_rd_rd_addr_err              (rt_rd_rd_addr_err),

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and Inline-ECC are disabled
//SJ: Intentionally left unread
                .rd_ih_free_brt_vld             (rd_ih_free_brt_vld_w[n]    ),
                .rd_ih_free_brt                 (rd_ih_free_brt_w[n]        ),
                .rd_ecc_ram_wr                  (rd_ecc_ram_wr_w[n]          ),
                .rd_ecc_ram_waddr               (rd_ecc_ram_waddr_w[n]       ),
                .rd_ecc_ram_wdata               (rd_ecc_ram_wdata_w[n]       ),
                .rd_ecc_ram_wdata_mask_n        (rd_ecc_ram_wdata_mask_n_w[n]), //should be all 1, no mask. 
                .rd_ecc_ram_wdata_par           (rd_ecc_ram_wdata_par_w[n]   ),
                .rd_ecc_ram_raddr               (rd_ecc_ram_raddr_w[n]       ),
                .rd_ecc_acc_raddr_2             (rd_ecc_acc_raddr_2_w[n]     ),
                .ecc_err_mr_rdata               (ecc_err_mr_rdata_w[n]      ),
                .rd_ih_lkp_bwt_by_bt            (rd_ih_lkp_bwt_by_bt_w[n]   ),
                .rd_ih_lkp_brt_by_bt            (rd_ih_lkp_brt_by_bt_w[n]   ),
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and ECCAP are disabled
//SJ: Intentionally left unread
                .ddrc_reg_ecc_ap_err            (ddrc_reg_ecc_ap_err_w[n]),
//spyglass enable_block W528
   
                .reg_ddrc_phy_dbi_mode          (reg_ddrc_phy_dbi_mode),
                .reg_ddrc_rd_dbi_en             (reg_ddrc_rd_dbi_en),
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and ECC are disabled
//SJ: Intentionally left unread
                .rd_ra_dram_addr                (rd_ra_rdata_dram_addr_w[n]) ,
//spyglass enable_block W528


//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and ECC are disabled
//SJ: Intentionally left unread
                .rd_wu_ecc_corrected_err        (rd_wu_ecc_corrected_err_w[n]),
                .rd_wu_ecc_uncorrected_err      (rd_wu_ecc_uncorrected_err_w[n]),
                .rd_ra_ecc_corrected_err        (rd_ra_ecc_corrected_err_w[n]),
                .rd_ra_ecc_uncorrected_err      (rd_ra_ecc_uncorrected_err_w[n]),
                .rd_dh_ecc_corrected_err        (rd_dh_ecc_corrected_err_w[n]),       // 1 bit per ECC lane
                .rd_dh_ecc_uncorrected_err      (rd_dh_ecc_uncorrected_err_w[n]),     // 1 bit per ECC lane
                .rd_dh_ecc_corr_syndromes       (rd_dh_ecc_corr_syndromes_w[n]),      // 72 bits
                .rd_dh_ecc_uncorr_syndromes     (rd_dh_ecc_uncorr_syndromes_w[n]),    // 72 bits
                .rd_dh_ecc_corrected_bit_num    (rd_dh_ecc_corrected_bit_num_w[n]),
                .rd_dh_ecc_corr_bit_mask        (rd_dh_ecc_corr_bit_mask_w[n]),
                .ddrc_reg_ecc_corr_err_cnt      (ddrc_reg_ecc_corr_err_cnt_w[n]),
                .ddrc_reg_ecc_uncorr_err_cnt    (ddrc_reg_ecc_uncorr_err_cnt_w[n]),

                .rd_dh_ecc_corr_rank            (rd_dh_ecc_corr_rank_w[n]),
                .rd_dh_ecc_uncorr_rank          (rd_dh_ecc_uncorr_rank_w[n]),
                
                .rd_dh_ecc_corr_bank            (rd_dh_ecc_corr_bank_w[n]),
                .rd_dh_ecc_uncorr_bank          (rd_dh_ecc_uncorr_bank_w[n]),
                
                .rd_dh_ecc_corr_bg             (rd_dh_ecc_corr_bg_w[n]),
                .rd_dh_ecc_uncorr_bg           (rd_dh_ecc_uncorr_bg_w[n]),
//spyglass enable_block W528

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and 3DS are disabled
//SJ: Intentionally left unread
                .rd_dh_ecc_corr_cid            (rd_dh_ecc_corr_cid_w[n]),
                .rd_dh_ecc_uncorr_cid          (rd_dh_ecc_uncorr_cid_w[n]),
//spyglass enable_block W528
                
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and ECC are disabled
//SJ: Intentionally left unread
                .rd_dh_ecc_corr_row             (rd_dh_ecc_corr_row_w[n]),
                .rd_dh_ecc_uncorr_row           (rd_dh_ecc_uncorr_row_w[n]),
                .rd_dh_ecc_corr_col             (rd_dh_ecc_corr_col_w[n]),
                .rd_dh_ecc_uncorr_col           (rd_dh_ecc_uncorr_col_w[n]),
//spyglass enable_block W528
                
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and MEMC_ADV_SIDEBAND_ECC are disabled
//SJ: Intentionally left unread
                .ddrc_reg_advecc_corrected_err   (ddrc_reg_advecc_corrected_err_w[n])  ,
                .ddrc_reg_advecc_uncorrected_err (ddrc_reg_advecc_uncorrected_err_w[n]),
                .ddrc_reg_advecc_num_err_symbol  (ddrc_reg_advecc_num_err_symbol_w[n]) ,
                .ddrc_reg_advecc_err_symbol_pos  (ddrc_reg_advecc_err_symbol_pos_w[n]) ,
                .ddrc_reg_advecc_err_symbol_bits (ddrc_reg_advecc_err_symbol_bits_w[n]),
//spyglass enable_block W528
 

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR is disabled
//SJ: Intentionally left unread
                .rd_ra_ecc_rdata                (rd_ra_ecc_rdata_w[n]),

                .rd_wu_ecc_uncorrected_err_eighth  (rd_wu_ecc_uncorrected_err_eighth_w[n]),
                .rd_wu_ecc_uncorrected_err_seventh (rd_wu_ecc_uncorrected_err_seventh_w[n] ),
                .rd_wu_ecc_uncorrected_err_sixth   (rd_wu_ecc_uncorrected_err_sixth_w[n]),
                .rd_wu_ecc_uncorrected_err_fifth   (rd_wu_ecc_uncorrected_err_fifth_w[n] ),
                .rd_wu_ecc_uncorrected_err_fourth  (rd_wu_ecc_uncorrected_err_fourth_w[n]),
                .rd_wu_ecc_uncorrected_err_third   (rd_wu_ecc_uncorrected_err_third_w[n] ),
                .rd_wu_ecc_uncorrected_err_second  (rd_wu_ecc_uncorrected_err_second_w[n]),
                .rd_wu_ecc_uncorrected_err_first   (rd_wu_ecc_uncorrected_err_first_w[n] ),
                .rd_wu_rd_crc_err                  (rd_wu_rd_crc_err_w[n]),

//spyglass enable_block W528

                .reg_ddrc_oc_parity_en          (reg_ddrc_oc_parity_en),
                .reg_ddrc_par_poison_en         (reg_ddrc_par_poison_en),
                .reg_ddrc_par_poison_loc_rd_iecc_type (reg_ddrc_par_poison_loc_rd_iecc_type),
                .reg_ddrc_par_rdata_err_intr_clr(reg_ddrc_par_rdata_err_intr_clr),
                .reg_ddrc_oc_parity_type        (reg_ddrc_oc_parity_type),
                .par_rdata_in_err_ecc_pulse     (par_rdata_in_err_ecc_pulse_w[n]),

                .rt_rd_rmwtype                  (rt_rd_rmwtype),
                .rt_rd_rmw_word_sel             (rt_rd_rmw_word_sel), 
                .rt_rd_wu_info                  (rt_rd_wu_info),
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and RMW are disabled
//SJ: Intentionally left unread
                .rd_wu_rdata_end                (rd_wu_rdata_end_w[n]),
                .rd_wu_rdata_valid              (rd_wu_rdata_valid_w[n]),
                .rd_wu_info                     (rd_wu_info_w[n]),
                .rd_rw_rdata_valid              (rd_rw_rdata_valid_w[n]),
                .rd_rw_rdata                    (rd_rw_rdata_w[n]),
                .rd_rw_rdata_par                (rd_rw_rdata_par_w[n]),
//spyglass enable_block W528

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and Inline-ECC are disabled
//SJ: Intentionally left unread
                .rd_wu_word_num                 (rd_wu_word_num_w[n]),
//spyglass enable_block W528

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and RMW are disabled
//SJ: Intentionally left unread
                .rd_wu_burst_chop_rd            (rd_wu_burst_chop_rd_w[n]),
//spyglass enable_block W528

                .rd_ra_rdata_valid              (rd_ra_rdata_valid_w[n]),
                .rd_ra_rdata                    (rd_ra_rdata_w[n]),
                .rd_ra_rdata_parity             (rd_ra_rdata_parity_w[n]),
                .rd_ra_eod                      (rd_ra_eod_w[n]),
                .rd_wu_partial                  (rd_wu_partial_w[n]),
                .rd_ra_info                     (rd_ra_info_w[n]),
                .rd_ra_rd_addr_err              (rd_ra_rd_addr_err_w[n]),
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when RD_CRC_RETRY are disabled
//SJ: Intentionally left unread
                .rd_ra_rdata_valid_retry         (rd_ra_rdata_valid_retry_w[n]),
                .rd_wu_rdata_valid_retry         (rd_wu_rdata_valid_retry_w[n]),
                .rd_ra_eod_retry                 (rd_ra_eod_retry_w[n]),
                .rd_ra_info_retry                (rd_ra_info_retry_w[n]),
                .rd_crc_err_retry                (rd_crc_err_retry_w[n]), 
                .rd_ra_ecc_uncorrected_err_retry (rd_ra_ecc_uncorrected_err_retry_w[n]),
//spyglass enable_block W528
                .rt_rd_rd_mrr_sod               (rt_rd_rd_mrr_sod),
                .rt_rd_rd_mrr                   (rt_rd_rd_mrr),
                .rt_rd_rd_mrr_ext               (rt_rd_rd_mrr_ext),
                .rd_mrr_data_valid              (rd_mrr_data_valid_w[n]),
                .rd_mrr_data                    (rd_mrr_data_w[n]),
                .reg_ddrc_mrr_done_clr          (reg_ddrc_mrr_done_clr),
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and LPDDR4 are disabled
//SJ: Intentionally left unread
                .rd_mr4_data_valid              (rd_mr4_data_valid_w[n]),
                .ddrc_reg_mrr_done              (ddrc_reg_mrr_done_w[n]),
                .ddrc_reg_mrr_data              (ddrc_reg_mrr_data_w[n]),
//spyglass enable_block W528
                
                .ocecc_en                       (ocecc_en),
                .ocecc_poison_egen_mr_rd_1      (ocecc_poison_egen_mr_rd_1),
                .ocecc_poison_egen_mr_rd_1_bnum (ocecc_poison_egen_mr_rd_1_bnum),
                .ocecc_poison_egen_xpi_rd_0     (ocecc_poison_egen_xpi_rd_0),
                .ocecc_poison_single            (ocecc_poison_single),
                .ocecc_poison_pgen_rd           (ocecc_poison_pgen_rd),
                .ocecc_uncorr_err_intr_clr      (ocecc_uncorr_err_intr_clr)
                ,.rt_rd_rd_mrr_snoop            (rt_rd_rd_mrr_snoop)

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and Link-ECC are disabled
//SJ: Intentionally left unread
               ,.ddrc_reg_rd_linkecc_poison_complete (ddrc_reg_rd_linkecc_poison_complete_w[n]),
                .ddrc_reg_rd_link_ecc_uncorr_cnt     (ddrc_reg_rd_link_ecc_uncorr_cnt_w[n]),
                .ddrc_reg_rd_link_ecc_corr_cnt       (ddrc_reg_rd_link_ecc_corr_cnt_w[n]),
                .ddrc_reg_rd_link_ecc_err_syndrome   (ddrc_reg_rd_link_ecc_err_syndrome_w[n]),
                .ddrc_reg_rd_link_ecc_uncorr_err_int (ddrc_reg_rd_link_ecc_uncorr_err_int_w[n]),
                .ddrc_reg_rd_link_ecc_corr_err_int   (ddrc_reg_rd_link_ecc_corr_err_int_w[n]),
                .rd_link_ecc_uncorr_err              (rd_link_ecc_uncorr_err_w[n])
//spyglass enable_block W528

//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and DDR5 are disabled
//SJ: Intentionally left unread
               ,.rd_dh_rd_crc_err_rank           (rd_dh_rd_crc_err_rank_w[n]),
                .rd_dh_rd_crc_err_cid            (rd_dh_rd_crc_err_cid_w[n]),
                .rd_dh_rd_crc_err_bg             (rd_dh_rd_crc_err_bg_w[n]),
                .rd_dh_rd_crc_err_bank           (rd_dh_rd_crc_err_bank_w[n]),
                .rd_dh_rd_crc_err_row            (rd_dh_rd_crc_err_row_w[n]),
                .rd_dh_rd_crc_err_col            (rd_dh_rd_crc_err_col_w[n]),
                .rd_dh_crc_poison_inject_complete (rd_dh_crc_poison_inject_complete_w[n]),
                .rd_dh_rd_crc_err_max_reached_int_nibble (rd_dh_rd_crc_err_max_reached_int_nibble_w[n]),
                .rd_dh_rd_crc_err_cnt_nibble     (rd_dh_rd_crc_err_cnt_nibble_w[n]),
                .rd_dh_rd_crc_err_max_reached_int(rd_dh_rd_crc_err_max_reached_int_w[n]),
                .rd_crc_err                      (rd_crc_err_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when MEMC_SECDED_SIDEBAND_ECC is disabled
//SJ: Intentionally left unread
                ,.rd_dh_ecc_cb_corr_syndromes      (rd_dh_ecc_cb_corr_syndromes_w[n])
                ,.rd_dh_ecc_cb_uncorr_syndromes    (rd_dh_ecc_cb_uncorr_syndromes_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when DDRCTL_KBD_SBECC_EN  are disabled
//SJ: Intentionally left unread
                ,.rd_ra_kbd                        (rd_ra_kbd_w[n])
                ,.rd_rw_kbd                        (rd_rw_kbd_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when UMCTL2_SBR_EN_1 are disabled
//SJ: Intentionally left unread
                ,.rd_dh_scrubber_read_ecc_ce       (rd_dh_scrubber_read_ecc_ce_w[n])
                ,.rd_dh_scrubber_read_ecc_ue       (rd_dh_scrubber_read_ecc_ue_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when MEMC_ADV_SIDEBAND_ECC is disabled
//SJ: Intentionally left unread
                ,.rd_dh_ecc_corr_rsd_data          (rd_dh_ecc_corr_rsd_data_w[n])
                ,.rd_dh_ecc_uncorr_rsd_data        (rd_dh_ecc_uncorr_rsd_data_w[n])
                ,.ddrc_reg_advecc_ce_kbd_stat      (ddrc_reg_advecc_ce_kbd_stat_w[n])
                ,.ddrc_reg_advecc_ue_kbd_stat      (ddrc_reg_advecc_ue_kbd_stat_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when UMCTL2_SBR_EN_1 are disabled
//SJ: Intentionally left unread
                ,.rd_dh_scrubber_read_advecc_ce       (rd_dh_scrubber_read_advecc_ce_w[n])
                ,.rd_dh_scrubber_read_advecc_ue       (rd_dh_scrubber_read_advecc_ue_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when DDRCTL_ENH_ECC_REPORT_EN are disabled
//SJ: Intentionally left unread
                ,.ddrc_reg_ecc_corr_err_per_rank_intr (ddrc_reg_ecc_corr_intr_sts_w[n])
                ,.ddrc_reg_ecc_corr_err_cnt_rank0     (ddrc_reg_ecc_corr_err_cnt_rank0_w[n])
                ,.ddrc_reg_ecc_corr_err_cnt_rank1     (ddrc_reg_ecc_corr_err_cnt_rank1_w[n])
                ,.ddrc_reg_ecc_corr_err_cnt_rank2     (ddrc_reg_ecc_corr_err_cnt_rank2_w[n])
                ,.ddrc_reg_ecc_corr_err_cnt_rank3     (ddrc_reg_ecc_corr_err_cnt_rank3_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when DDRCTL_ENH_ECC_REPORT_EN are disabled
//SJ: Intentionally left unread
   ,.ddrc_reg_eapar_error                 (ddrc_reg_eapar_error_w[n])
   ,.ddrc_reg_eapar_err_cnt               (ddrc_reg_eapar_err_cnt_w[n])// Count of correctable ECC errors// 
   ,.rd_wu_eapar                          (rd_wu_eapar_w[n])
   ,.rd_wu_eapar_err                      (rd_wu_eapar_err_w[n])
   ,.rd_ra_eapar_err                      (rd_ra_eapar_err_w[n])
   ,.ddrc_reg_eapar_err_rank              (ddrc_reg_eapar_err_rank_w[n])
   ,.ddrc_reg_eapar_err_bank              (ddrc_reg_eapar_err_bank_w[n])
   ,.ddrc_reg_eapar_err_bg                (ddrc_reg_eapar_err_bg_w[n])
   ,.ddrc_reg_eapar_err_cid               (ddrc_reg_eapar_err_cid_w[n])
   ,.ddrc_reg_eapar_err_row               (ddrc_reg_eapar_err_row_w[n])
   ,.ddrc_reg_eapar_err_col               (ddrc_reg_eapar_err_col_w[n])
   ,.ddrc_reg_eapar_err_syndromes         (ddrc_reg_eapar_err_syndromes_w[n])
   ,.ddrc_reg_eapar_err_cb_syndromes      (ddrc_reg_eapar_err_cb_syndromes_w[n])
   ,.ddrc_reg_eapar_err_sbr_rd            (ddrc_reg_eapar_err_sbr_rd_w[n])
//spyglass enable_block W528

        ); // end rd block instantiation

    end // rd_inst
       
     if (OCCAP_EN==1) begin: CMP_en

      // handle Xs
      
      reg [CORE_DATA_WIDTH-1:0] rd_ecc_ram_wdata_w_no_x [NUM_INST-1:0];
      always @(rd_ecc_ram_wdata_w[0] or rd_ecc_ram_wdata_w[1]) begin : rd_ecc_ram_wdata_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_ecc_ram_wdata_w_no_x[i_cnt] = rd_ecc_ram_wdata_w[i_cnt];
        end // for i_cnt
      end

      reg [CORE_MASK_WIDTH-1:0] rd_ecc_ram_wdata_par_w_no_x [NUM_INST-1:0];
      always @(rd_ecc_ram_wdata_par_w[0] or rd_ecc_ram_wdata_par_w[1]) begin : rd_ecc_ram_wdata_par_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_ecc_ram_wdata_par_w_no_x[i_cnt] = rd_ecc_ram_wdata_par_w[i_cnt];
        end // for i_cnt
      end


      
      reg [RD_MRR_DATA_W-1:0] rd_mrr_data_w_no_x [NUM_INST-1:0];
      always @(rd_mrr_data_w[0] or rd_mrr_data_w[1]) begin : rd_mrr_data_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
            for (x_cnt=0; x_cnt< RD_MRR_DATA_W; x_cnt=x_cnt+1) begin
              if (rd_mrr_data_w[i_cnt][x_cnt]) begin
                rd_mrr_data_w_no_x[i_cnt][x_cnt] = 1'b1;
              end else begin
                rd_mrr_data_w_no_x[i_cnt][x_cnt] = 1'b0;
              end
            end // for x_cnt      
        end // for i_cnt
      end


      reg [UMCTL2_WDATARAM_PAR_DW-1:0] rd_rw_rdata_par_w_no_x [NUM_INST-1:0];
      always @(rd_rw_rdata_par_w[0] or rd_rw_rdata_par_w[1]) begin : rd_rw_rdata_par_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
            for (x_cnt=0; x_cnt< UMCTL2_WDATARAM_PAR_DW; x_cnt=x_cnt+1) begin
              if (rd_rw_rdata_par_w[i_cnt][x_cnt]) begin
                rd_rw_rdata_par_w_no_x[i_cnt][x_cnt] = 1'b1;
              end else begin
                rd_rw_rdata_par_w_no_x[i_cnt][x_cnt] = 1'b0;
              end
            end // for x_cnt      
        end // for i_cnt
      end

      reg [CORE_DATA_WIDTH-1:0] rd_rw_rdata_w_no_x [NUM_INST-1:0];
      always @(rd_rw_rdata_w[0] or rd_rw_rdata_w[1]) begin : rd_rw_rdata_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
            for (x_cnt=0; x_cnt< CORE_DATA_WIDTH; x_cnt=x_cnt+1) begin
              if (rd_rw_rdata_w[i_cnt][x_cnt]) begin
                rd_rw_rdata_w_no_x[i_cnt][x_cnt] = 1'b1;
              end else begin
                rd_rw_rdata_w_no_x[i_cnt][x_cnt] = 1'b0;
              end
            end // for x_cnt      
        end // for i_cnt
      end

      reg [CORE_MASK_WIDTH-1:0] rd_ra_rdata_parity_w_no_x [NUM_INST-1:0];
      always @(rd_ra_rdata_parity_w[0] or rd_ra_rdata_parity_w[1]) begin : rd_ra_rdata_parity_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
          for (x_cnt=0; x_cnt< CORE_MASK_WIDTH; x_cnt=x_cnt+1) begin
            if (rd_ra_rdata_parity_w[i_cnt][x_cnt]) begin
              rd_ra_rdata_parity_w_no_x[i_cnt][x_cnt] = 1'b1;
            end else begin
              rd_ra_rdata_parity_w_no_x[i_cnt][x_cnt] = 1'b0;
            end
          end // for x_cnt      
        end // for i_cnt
      end

      reg [CORE_DATA_WIDTH-1:0] rd_ra_rdata_w_no_x [NUM_INST-1:0];
      always @(rd_ra_rdata_w[0] or rd_ra_rdata_w[1]) begin : rd_ra_rdata_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
          for (x_cnt=0; x_cnt< CORE_DATA_WIDTH; x_cnt=x_cnt+1) begin
            if (rd_ra_rdata_w[i_cnt][x_cnt]) begin
              rd_ra_rdata_w_no_x[i_cnt][x_cnt] = 1'b1;
            end else begin
              rd_ra_rdata_w_no_x[i_cnt][x_cnt] = 1'b0;
            end
          end // for x_cnt      
        end // for i_cnt
      end

      reg [CORE_ECC_WIDTH_DUP-1:0] rd_ra_ecc_rdata_w_no_x [NUM_INST-1:0];
      always @(rd_ra_ecc_rdata_w[0] or rd_ra_ecc_rdata_w[1]) begin : rd_ra_ecc_rdata_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_ra_ecc_rdata_w_no_x[i_cnt] = rd_ra_ecc_rdata_w[i_cnt];
        end // for i_cnt
      end

      reg [SECDED_LANES_DUP-1:0] rd_wu_ecc_uncorrected_err_eighth_w_no_x [NUM_INST-1:0];
      always @(rd_wu_ecc_uncorrected_err_eighth_w[0] or rd_wu_ecc_uncorrected_err_eighth_w[1]) begin : rd_wu_ecc_uncorrected_err_eighth_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_wu_ecc_uncorrected_err_eighth_w_no_x[i_cnt] = rd_wu_ecc_uncorrected_err_eighth_w[i_cnt];
        end // for i_cnt
      end

      reg [SECDED_LANES_DUP-1:0] rd_wu_ecc_uncorrected_err_seventh_w_no_x [NUM_INST-1:0];
      always @(rd_wu_ecc_uncorrected_err_seventh_w[0] or rd_wu_ecc_uncorrected_err_seventh_w[1]) begin : rd_wu_ecc_uncorrected_err_seventh_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_wu_ecc_uncorrected_err_seventh_w_no_x[i_cnt] = rd_wu_ecc_uncorrected_err_seventh_w[i_cnt];
        end // for i_cnt
      end

      reg [SECDED_LANES_DUP-1:0] rd_wu_ecc_uncorrected_err_sixth_w_no_x [NUM_INST-1:0];
      always @(rd_wu_ecc_uncorrected_err_sixth_w[0] or rd_wu_ecc_uncorrected_err_sixth_w[1]) begin : rd_wu_ecc_uncorrected_err_sixth_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_wu_ecc_uncorrected_err_sixth_w_no_x[i_cnt] = rd_wu_ecc_uncorrected_err_sixth_w[i_cnt];
        end // for i_cnt
      end

      reg [SECDED_LANES_DUP-1:0] rd_wu_ecc_uncorrected_err_fifth_w_no_x [NUM_INST-1:0];
      always @(rd_wu_ecc_uncorrected_err_fifth_w[0] or rd_wu_ecc_uncorrected_err_fifth_w[1]) begin : rd_wu_ecc_uncorrected_err_fifth_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_wu_ecc_uncorrected_err_fifth_w_no_x[i_cnt] = rd_wu_ecc_uncorrected_err_fifth_w[i_cnt];
        end // for i_cnt
      end

            
      reg [SECDED_LANES_DUP-1:0] rd_wu_ecc_uncorrected_err_fourth_w_no_x [NUM_INST-1:0];
      always @(rd_wu_ecc_uncorrected_err_fourth_w[0] or rd_wu_ecc_uncorrected_err_fourth_w[1]) begin : rd_wu_ecc_uncorrected_err_fourth_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_wu_ecc_uncorrected_err_fourth_w_no_x[i_cnt] = rd_wu_ecc_uncorrected_err_fourth_w[i_cnt];
        end // for i_cnt
      end

            
      reg [SECDED_LANES_DUP-1:0] rd_wu_ecc_uncorrected_err_third_w_no_x [NUM_INST-1:0];
      always @(rd_wu_ecc_uncorrected_err_third_w[0] or rd_wu_ecc_uncorrected_err_third_w[1]) begin : rd_wu_ecc_uncorrected_err_third_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
              rd_wu_ecc_uncorrected_err_third_w_no_x[i_cnt] = rd_wu_ecc_uncorrected_err_third_w[i_cnt];
        end // for i_cnt
      end
        
      

      wire [OUT_TOTW-1:0] cmp_in0, cmp_in1;

      assign cmp_in0 = {
                        rd_wu_eapar_w[0],
                        ddrc_reg_eapar_err_sbr_rd_w[0],
                        ddrc_reg_eapar_err_cb_syndromes_w[0],
                        ddrc_reg_eapar_err_syndromes_w[0],
                        ddrc_reg_eapar_err_col_w[0],
                        ddrc_reg_eapar_err_row_w[0],
                        ddrc_reg_eapar_err_cid_w[0],
                        ddrc_reg_eapar_err_bg_w[0],
                        ddrc_reg_eapar_err_bank_w[0],
                        ddrc_reg_eapar_err_rank_w[0],
                        rd_ra_eapar_err_w[0],
                        rd_wu_eapar_err_w[0],
                        ddrc_reg_eapar_err_cnt_w[0],
                        ddrc_reg_eapar_error_w[0],
                        ddrc_reg_ecc_corr_err_cnt_rank3_w[0],                       
                        ddrc_reg_ecc_corr_err_cnt_rank2_w[0],                       
                        ddrc_reg_ecc_corr_err_cnt_rank1_w[0],                       
                        ddrc_reg_ecc_corr_err_cnt_rank0_w[0], 
                        ddrc_reg_ecc_corr_intr_sts_w[0],
                        rd_dh_scrubber_read_advecc_ue_w[0],
                        rd_dh_scrubber_read_advecc_ce_w[0],
                        ddrc_reg_advecc_ue_kbd_stat_w[0],
                        ddrc_reg_advecc_ce_kbd_stat_w[0],
                        rd_dh_ecc_uncorr_rsd_data_w[0],
                        rd_dh_ecc_corr_rsd_data_w[0],
                        rd_ra_rdata_dram_addr_w[0],                
                        rd_dh_scrubber_read_ecc_ue_w[0],
                        rd_dh_scrubber_read_ecc_ce_w[0],
                        rd_rw_kbd_w[0],
                        rd_ra_kbd_w[0],
                        rd_dh_ecc_cb_uncorr_syndromes_w[0],
                        rd_dh_ecc_cb_corr_syndromes_w[0],
                        ddrc_reg_rd_link_ecc_uncorr_err_int_w[0],
                        ddrc_reg_rd_link_ecc_corr_err_int_w[0],
                        rd_link_ecc_uncorr_err_w[0],
                        ddrc_reg_rd_link_ecc_err_syndrome_w[0],
                        ddrc_reg_rd_link_ecc_corr_cnt_w[0],
                        ddrc_reg_rd_link_ecc_uncorr_cnt_w[0],
                        ddrc_reg_rd_linkecc_poison_complete_w[0],
                        rd_crc_err_w[0],
                        rd_dh_rd_crc_err_cnt_nibble_w[0],
                        rd_dh_rd_crc_err_max_reached_int_w[0],
                        rd_dh_rd_crc_err_max_reached_int_nibble_w[0],
                        rd_dh_crc_poison_inject_complete_w[0],
                        rd_dh_rd_crc_err_rank_w[0],
                        rd_dh_rd_crc_err_cid_w[0],
                        rd_dh_rd_crc_err_bg_w[0],
                        rd_dh_rd_crc_err_bank_w[0],
                        rd_dh_rd_crc_err_row_w[0],
                        rd_dh_rd_crc_err_col_w[0],
                        ddrc_reg_mrr_done_w[0],
                        ddrc_reg_mrr_data_w[0],
                        rd_mr4_data_valid_w[0],
                        rd_mrr_data_w_no_x[0], // no_x
                        rd_mrr_data_valid,
                        rd_ra_rd_addr_err_w[0],
                        rd_ra_info,
                        rd_wu_partial,
                        rd_ra_eod,
                        rd_ra_rdata_parity_w_no_x[0], // no_x
                        rd_ra_rdata_w_no_x[0], // no_x
                        rd_ra_rdata_valid,
                        rd_wu_burst_chop_rd_w[0],
                        rd_wu_word_num_w[0],
                        rd_rw_rdata_par_w_no_x[0], // no_x
                        rd_rw_rdata_w_no_x[0], // no_x
                        rd_rw_rdata_valid_w[0],
                        rd_wu_info_w[0],
                        rd_wu_rdata_end_w[0],
                        rd_wu_rdata_valid_w[0],
                        par_rdata_in_err_ecc_pulse,
                        rd_ra_ecc_rdata_w_no_x[0], // no_x
                        rd_wu_rd_crc_err_w[0],
                        rd_wu_ecc_uncorrected_err_first_w[0],
                        rd_wu_ecc_uncorrected_err_second_w[0],
                        rd_wu_ecc_uncorrected_err_third_w_no_x[0], // no_x
                        rd_wu_ecc_uncorrected_err_fourth_w_no_x[0], // no_x
                        rd_wu_ecc_uncorrected_err_fifth_w_no_x[0], // no_x
                        rd_wu_ecc_uncorrected_err_sixth_w_no_x[0], // no_x
                        rd_wu_ecc_uncorrected_err_seventh_w_no_x[0], // no_x
                        rd_wu_ecc_uncorrected_err_eighth_w_no_x[0], // no_x
                        ddrc_reg_advecc_err_symbol_bits_w[0],
                        ddrc_reg_advecc_err_symbol_pos_w[0],
                        ddrc_reg_advecc_num_err_symbol_w[0],
                        ddrc_reg_advecc_uncorrected_err_w[0],
                        ddrc_reg_advecc_corrected_err_w[0],
                        rd_dh_ecc_uncorr_col_w[0],
                        rd_dh_ecc_corr_col_w[0],
                        rd_dh_ecc_uncorr_row_w[0],
                        rd_dh_ecc_corr_row_w[0],
                        rd_dh_ecc_uncorr_cid_w[0],
                        rd_dh_ecc_corr_cid_w[0],
                        rd_dh_ecc_uncorr_bg_w[0],
                        rd_dh_ecc_corr_bg_w[0],
                        rd_dh_ecc_uncorr_bank_w[0],
                        rd_dh_ecc_corr_bank_w[0],
                        rd_dh_ecc_uncorr_rank_w[0],
                        rd_dh_ecc_corr_rank_w[0],
                        ddrc_reg_ecc_uncorr_err_cnt_w[0],
                        ddrc_reg_ecc_corr_err_cnt_w[0],
                        rd_dh_ecc_corr_bit_mask_w[0],
                        rd_dh_ecc_corrected_bit_num_w[0],
                        rd_dh_ecc_uncorr_syndromes_w[0],
                        rd_dh_ecc_corr_syndromes_w[0],
                        rd_dh_ecc_uncorrected_err_w[0],
                        rd_dh_ecc_corrected_err_w[0],
                        rd_ra_ecc_uncorrected_err_w[0],
                        rd_ra_ecc_corrected_err_w[0],
                        rd_wu_ecc_uncorrected_err_w[0],
                        rd_wu_ecc_corrected_err_w[0],
                        ddrc_reg_ecc_ap_err_w[0],
                        rd_ih_lkp_brt_by_bt_w[0],
                        rd_ih_lkp_bwt_by_bt_w[0],
                        ecc_err_mr_rdata_w[0],
                        rd_ecc_acc_raddr_2_w[0],
                        rd_ecc_ram_raddr_w[0],
                        rd_ecc_ram_wdata_par_w_no_x[0], // no_x
                        rd_ecc_ram_wdata_mask_n_w[0],
                        rd_ecc_ram_wdata_w_no_x[0], // no_x
                        rd_ecc_ram_waddr_w[0],
                        rd_ecc_ram_wr_w[0],
                        rd_ih_free_brt_w[0],
                        rd_ih_free_brt_vld_w[0],
                        rd_ra_rdata_valid_retry_w[0],
                        rd_ra_eod_retry_w[0],
                        rd_ra_info_retry_w[0],
                        rd_crc_err_retry_w[0], 
                        rd_ra_ecc_uncorrected_err_retry_w[0],
                        rd_wu_rdata_valid_retry_w[0]
                        };


      assign cmp_in1 = {
                        rd_wu_eapar_w[NUM_INST-1],
                        ddrc_reg_eapar_err_sbr_rd_w[NUM_INST-1],
                        ddrc_reg_eapar_err_cb_syndromes_w[NUM_INST-1],
                        ddrc_reg_eapar_err_syndromes_w[NUM_INST-1],
                        ddrc_reg_eapar_err_col_w[NUM_INST-1],
                        ddrc_reg_eapar_err_row_w[NUM_INST-1],
                        ddrc_reg_eapar_err_cid_w[NUM_INST-1],
                        ddrc_reg_eapar_err_bg_w[NUM_INST-1],
                        ddrc_reg_eapar_err_bank_w[NUM_INST-1],
                        ddrc_reg_eapar_err_rank_w[NUM_INST-1],
                        rd_ra_eapar_err_w[NUM_INST-1],
                        rd_wu_eapar_err_w[NUM_INST-1],
                        ddrc_reg_eapar_err_cnt_w[NUM_INST-1],
                        ddrc_reg_eapar_error_w[NUM_INST-1],
                        ddrc_reg_ecc_corr_err_cnt_rank3_w[NUM_INST-1],                       
                        ddrc_reg_ecc_corr_err_cnt_rank2_w[NUM_INST-1],                       
                        ddrc_reg_ecc_corr_err_cnt_rank1_w[NUM_INST-1],                       
                        ddrc_reg_ecc_corr_err_cnt_rank0_w[NUM_INST-1], 
                        ddrc_reg_ecc_corr_intr_sts_w[NUM_INST-1],
                        rd_dh_scrubber_read_advecc_ue_w[NUM_INST-1],
                        rd_dh_scrubber_read_advecc_ce_w[NUM_INST-1],
                        ddrc_reg_advecc_ue_kbd_stat_w[NUM_INST-1],
                        ddrc_reg_advecc_ce_kbd_stat_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_rsd_data_w[NUM_INST-1],
                        rd_dh_ecc_corr_rsd_data_w[NUM_INST-1],
                        rd_ra_rdata_dram_addr_w[NUM_INST-1], 
                        rd_dh_scrubber_read_ecc_ue_w[NUM_INST-1],
                        rd_dh_scrubber_read_ecc_ce_w[NUM_INST-1],
                        rd_rw_kbd_w[NUM_INST-1],
                        rd_ra_kbd_w[NUM_INST-1],
                        rd_dh_ecc_cb_uncorr_syndromes_w[NUM_INST-1],
                        rd_dh_ecc_cb_corr_syndromes_w[NUM_INST-1],
                        ddrc_reg_rd_link_ecc_uncorr_err_int_w[NUM_INST-1],
                        ddrc_reg_rd_link_ecc_corr_err_int_w[NUM_INST-1],
                        rd_link_ecc_uncorr_err_w[NUM_INST-1],
                        ddrc_reg_rd_link_ecc_err_syndrome_w[NUM_INST-1],
                        ddrc_reg_rd_link_ecc_corr_cnt_w[NUM_INST-1],
                        ddrc_reg_rd_link_ecc_uncorr_cnt_w[NUM_INST-1],
                        ddrc_reg_rd_linkecc_poison_complete_w[NUM_INST-1],
                        rd_crc_err_w[NUM_INST-1],
                        rd_dh_rd_crc_err_cnt_nibble_w[NUM_INST-1],
                        rd_dh_rd_crc_err_max_reached_int_w[NUM_INST-1],
                        rd_dh_rd_crc_err_max_reached_int_nibble_w[NUM_INST-1],
                        rd_dh_crc_poison_inject_complete_w[NUM_INST-1],
                        rd_dh_rd_crc_err_rank_w[NUM_INST-1],
                        rd_dh_rd_crc_err_cid_w[NUM_INST-1],
                        rd_dh_rd_crc_err_bg_w[NUM_INST-1],
                        rd_dh_rd_crc_err_bank_w[NUM_INST-1],
                        rd_dh_rd_crc_err_row_w[NUM_INST-1],
                        rd_dh_rd_crc_err_col_w[NUM_INST-1],
                        ddrc_reg_mrr_done_w[NUM_INST-1],
                        ddrc_reg_mrr_data_w[NUM_INST-1],
                        rd_mr4_data_valid_w[NUM_INST-1],
                        rd_mrr_data_w_no_x[NUM_INST-1], // no_x
                        rd_mrr_data_valid_w[NUM_INST-1],
                        rd_ra_rd_addr_err_w[NUM_INST-1],
                        rd_ra_info_w[NUM_INST-1],
                        rd_wu_partial_w[NUM_INST-1],
                        rd_ra_eod_w[NUM_INST-1],
                        rd_ra_rdata_parity_w_no_x[NUM_INST-1], // no_x
                        rd_ra_rdata_w_no_x[NUM_INST-1], // no_x
                        rd_ra_rdata_valid_w[NUM_INST-1],
                        rd_wu_burst_chop_rd_w[NUM_INST-1],
                        rd_wu_word_num_w[NUM_INST-1],
                        rd_rw_rdata_par_w_no_x[NUM_INST-1], // no_x
                        rd_rw_rdata_w_no_x[NUM_INST-1], // no_x
                        rd_rw_rdata_valid_w[NUM_INST-1],
                        rd_wu_info_w[NUM_INST-1],
                        rd_wu_rdata_end_w[NUM_INST-1],
                        rd_wu_rdata_valid_w[NUM_INST-1],
                        par_rdata_in_err_ecc_pulse_w[NUM_INST-1],
                        rd_ra_ecc_rdata_w_no_x[NUM_INST-1], // no_x
                        rd_wu_rd_crc_err_w[NUM_INST-1],
                        rd_wu_ecc_uncorrected_err_first_w[NUM_INST-1],
                        rd_wu_ecc_uncorrected_err_second_w[NUM_INST-1],
                        rd_wu_ecc_uncorrected_err_third_w_no_x[NUM_INST-1], // no_x
                        rd_wu_ecc_uncorrected_err_fourth_w_no_x[NUM_INST-1], // no_x
                        rd_wu_ecc_uncorrected_err_fifth_w_no_x[NUM_INST-1], // no_x
                        rd_wu_ecc_uncorrected_err_sixth_w_no_x[NUM_INST-1], // no_x
                        rd_wu_ecc_uncorrected_err_seventh_w_no_x[NUM_INST-1], // no_x
                        rd_wu_ecc_uncorrected_err_eighth_w_no_x[NUM_INST-1], // no_x
                        ddrc_reg_advecc_err_symbol_bits_w[NUM_INST-1],
                        ddrc_reg_advecc_err_symbol_pos_w[NUM_INST-1],
                        ddrc_reg_advecc_num_err_symbol_w[NUM_INST-1],
                        ddrc_reg_advecc_uncorrected_err_w[NUM_INST-1],
                        ddrc_reg_advecc_corrected_err_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_col_w[NUM_INST-1],
                        rd_dh_ecc_corr_col_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_row_w[NUM_INST-1],
                        rd_dh_ecc_corr_row_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_cid_w[NUM_INST-1],
                        rd_dh_ecc_corr_cid_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_bg_w[NUM_INST-1],
                        rd_dh_ecc_corr_bg_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_bank_w[NUM_INST-1],
                        rd_dh_ecc_corr_bank_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_rank_w[NUM_INST-1],
                        rd_dh_ecc_corr_rank_w[NUM_INST-1],
                        ddrc_reg_ecc_uncorr_err_cnt_w[NUM_INST-1],
                        ddrc_reg_ecc_corr_err_cnt_w[NUM_INST-1],
                        rd_dh_ecc_corr_bit_mask_w[NUM_INST-1],
                        rd_dh_ecc_corrected_bit_num_w[NUM_INST-1],
                        rd_dh_ecc_uncorr_syndromes_w[NUM_INST-1],
                        rd_dh_ecc_corr_syndromes_w[NUM_INST-1],
                        rd_dh_ecc_uncorrected_err_w[NUM_INST-1],
                        rd_dh_ecc_corrected_err_w[NUM_INST-1],
                        rd_ra_ecc_uncorrected_err_w[NUM_INST-1],
                        rd_ra_ecc_corrected_err_w[NUM_INST-1],
                        rd_wu_ecc_uncorrected_err_w[NUM_INST-1],
                        rd_wu_ecc_corrected_err_w[NUM_INST-1],
                        ddrc_reg_ecc_ap_err_w[NUM_INST-1],
                        rd_ih_lkp_brt_by_bt_w[NUM_INST-1],
                        rd_ih_lkp_bwt_by_bt_w[NUM_INST-1],
                        ecc_err_mr_rdata_w[NUM_INST-1],
                        rd_ecc_acc_raddr_2_w[NUM_INST-1],
                        rd_ecc_ram_raddr_w[NUM_INST-1],
                        rd_ecc_ram_wdata_par_w_no_x[NUM_INST-1], // no_x
                        rd_ecc_ram_wdata_mask_n_w[NUM_INST-1],
                        rd_ecc_ram_wdata_w_no_x[NUM_INST-1], // no_x
                        rd_ecc_ram_waddr_w[NUM_INST-1],
                        rd_ecc_ram_wr_w[NUM_INST-1],
                        rd_ih_free_brt_w[NUM_INST-1],
                        rd_ih_free_brt_vld_w[NUM_INST-1],
                        rd_ra_rdata_valid_retry_w[NUM_INST-1],
                        rd_ra_eod_retry_w[NUM_INST-1],
                        rd_ra_info_retry_w[NUM_INST-1],
                        rd_crc_err_retry_w[NUM_INST-1], 
                        rd_ra_ecc_uncorrected_err_retry_w[NUM_INST-1],
                        rd_wu_rdata_valid_retry_w[NUM_INST-1]
                        };
                   
      occap_cmp
      
      #(
         .CMP_REG       (CMP_REG),
         .NUM_INS       (NUM_OUTS),
         .IN_WIDTH      (OUT_TOTW),
         .PW            (PW),
         .WIDTH_OFFSET  (WIDTH_OFFSET),
         .WIDTH_ARRAY   (WIDTH_ARRAY),
         .SVA_X_Z_CHECK_EN (1) // enable check on X/Z
      )
      rd_cmp
      (
         .clk                 (co_yy_clk),
         .rst_n               (core_ddrc_rstn),
         .in0                 (cmp_in0),
         .in1                 (cmp_in1),
         .cmp_en              (ddrc_cmp_en),
         .cmp_poison          (ddrc_data_cmp_poison),
         .cmp_poison_full     (ddrc_data_cmp_poison_full),
         .cmp_poison_err_inj  (ddrc_data_cmp_poison_err_inj),
         .cmp_err             (ddrc_data_cmp_error_rd),
         .cmp_err_full        (ddrc_data_cmp_error_full_rd),
         .cmp_err_seq         (ddrc_data_cmp_error_seq_rd),
         .cmp_poison_complete (ddrc_data_cmp_poison_complete_rd)
      );

   end // CMP_en
   else begin: OCCAP_dis
      assign ddrc_data_cmp_error_rd           = 1'b0;
      assign ddrc_data_cmp_error_full_rd      = 1'b0;
      assign ddrc_data_cmp_error_seq_rd       = 1'b0;
      assign ddrc_data_cmp_poison_complete_rd = 1'b0;

   end // OCCAP_dis

endgenerate



endmodule  // rd_wrapper

