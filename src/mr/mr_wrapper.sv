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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/mr/mr_wrapper.sv#2 $
// -------------------------------------------------------------------------
// Description:
//                Memory Read Engine.  This unit takes the write command
//                from GS & TE, controls reading data out of the write data
//                RAM, performs ECC encoding if necessary, and sends the
//                data to memory when a write is performed.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module mr_wrapper 
import DWC_ddrctl_reg_pkg::*;
#(
   parameter CORE_DATA_WIDTH     = `MEMC_DFI_DATA_WIDTH       // internal data width
  ,parameter CORE_MASK_WIDTH     = `MEMC_DFI_DATA_WIDTH/8     // data mask width
  ,parameter WRSRAM_DATA_WIDTH   = `MEMC_DFI_DATA_WIDTH       // WR-SRAM data width
  ,parameter WRSRAM_MASK_WIDTH   = `MEMC_DFI_DATA_WIDTH/8     // WR-SRAM data mask width
  ,parameter CORE_DCERRBITS      = `MEMC_DCERRBITS

  ,parameter PHY_DATA_WIDTH      = `MEMC_DFI_TOTAL_DATA_WIDTH   // width of data to the PHY
                                                                 // (should be 2x the DDR DQ width)
  ,parameter PHY_MASK_WIDTH      = PHY_DATA_WIDTH/8             // width of data mask bits to the PHY
                                                       // (note that if both ECC and DM
                                                       //  are supported in a system:
                                                       //  1) Only one or the other allowed at any given time
                                                       //  2) ECC byte enable need not be maskable           )

  ,parameter NUM_RANKS             = `MEMC_NUM_RANKS
  ,parameter WRCAM_ADDR_WIDTH      = 4                          // bits to address into CAM
  ,parameter WRDATA_RAM_ADDR_WIDTH = WRCAM_ADDR_WIDTH + 1  // data width to RAM
  ,parameter WRCAM_ADDR_WIDTH_IE   = 4
  ,parameter PARTIAL_WR_BITS       = `UMCTL2_PARTIAL_WR_BITS
  ,parameter PW_WORD_CNT_WD_MAX    = 2
  ,parameter PARTIAL_WR_BITS_LOG2  = `log2(PARTIAL_WR_BITS)
  ,parameter OCPAR_EN              = 0 // enables on-chip parity
  ,parameter ECC_POISON_REG_WIDTH  = `ECC_POISON_REG_WIDTH
   
  ,parameter WRDATA_CYCLES         = 2
  ,parameter CMD_LEN_BITS          = 1

  ,parameter BWT_BITS              = 4
  ,parameter BRT_BITS              = 4
  ,parameter BT_BITS               = 4
  ,parameter ECC_RAM_ADDR_BITS     = `log2(`MEMC_ECC_RAM_DEPTH)
  ,parameter ECC_ERR_RAM_ADDR_BITS = 4

  ,parameter OCCAP_EN              = 0
  ,parameter CMP_REG               = 0
  ,parameter WDATARAM_RD_LATENCY   = `DDRCTL_WDATARAM_RD_LATENCY
  ,parameter MAX_CMD_DELAY         = `UMCTL2_MAX_CMD_DELAY
  ,parameter CMD_DELAY_BITS        = `UMCTL2_CMD_DELAY_BITS
  
  ,parameter OCECC_EN              = 0
  ,parameter OCECC_MR_RD_GRANU     = 8
  ,parameter WDATA_PAR_WIDTH       = `UMCTL2_WDATARAM_PAR_DW
  ,parameter WDATA_PAR_WIDTH_EXT   = `UMCTL2_WDATARAM_PAR_DW_EXT
  ,parameter DRAM_BYTE_NUM         = `MEMC_DRAM_TOTAL_BYTE_NUM
  ,parameter DFI_KBD_WIDTH         = `DDRCTL_DFI_KBD_WIDTH

)
(     
   input           co_yy_clk                              // clock
  ,input           core_ddrc_rstn                         // asynchronous negative-edge reset
  ,input           ddrc_cg_en                             // clock gating enable
  ,input [1:0]     dh_mr_data_bus_width                   // Width of the DRAM data bus:
                                                        //  00: 64 bits wide
                                                        //  01: 32 bits wide
                                                        //  10: 16 bits wide
                                                        //  11: unused 
  ,input           dh_mr_en_2t_timing_mode                // 2T timing enable, send write data one clock later
  ,input           dh_mr_frequency_ratio                  // 0 - 1:2 mode, 1 - 1:1 mode
  ,input           dh_mr_lpddr4                           // LPDDR4 mode
  ,input           reg_ddrc_lpddr5
  ,input           ts_pi_mwr
  ,input           reg_ddrc_lp_optimized_write            // To save power consumption LPDDR4 write DQ is set to 8'hF8 if this is set to 1 (masked + DBI)

  ,input           gs_mr_write                            // write command issued this cycle 
//`ifdef MEMC_FREQ_RATIO_4
  ,input [1:0]     gs_mr_write_ph                         // indicates that write command phase
  ,input [1:0]     gs_mr_read_ph                          // indicates that read command phase
//`endif // MEMC_FREQ_RATIO_4
  ,output [NUM_RANKS-1:0] mr_wr_empty_per_rank
  ,input [WRCAM_ADDR_WIDTH_IE-1:0] te_mr_wr_ram_addr// write RAM address

  ,input   [PARTIAL_WR_BITS-1:0]   te_pi_wr_word_valid
  ,input   [PARTIAL_WR_BITS_LOG2-1:0]      te_mr_ram_raddr_lsb_first
  ,input   [PW_WORD_CNT_WD_MAX-1:0]        te_mr_pw_num_beats_m1
   
   
//,input [CORE_DATA_WIDTH-1:0]     me_mr_rdata    // write data read from write data RAM
  ,input [CORE_MASK_WIDTH-1:0]     me_mr_rdatamask// write data read from write data RAM
  ,input [WRSRAM_DATA_WIDTH-1:0]   me_mr_rdata    // write data read from write data RAM
//,input [WRSRAM_MASK_WIDTH-1:0]   me_mr_rdatamask// write data read from write data RAM
  ,output [PHY_MASK_WIDTH-1:0]     mr_ph_wdatamask// write data output to phy with ECC
  ,output [PHY_MASK_WIDTH-1:0]     mr_ph_wdatamask_retry// write data output to retry with ECC

  ,input [WDATA_PAR_WIDTH_EXT-1:0] me_mr_rdatapar
   
  ,output [WRDATA_RAM_ADDR_WIDTH-1:0] mr_wu_raddr    // read address to wu module
  ,output [WRDATA_RAM_ADDR_WIDTH-1:0] mr_me_raddr    // read address to write data RAM
  ,output                             mr_me_re       // read enable: enables the RAM read path
  ,output [PHY_DATA_WIDTH-1:0]        mr_ph_wdata    // write data output to phy with ECC
                                                      //  encoding, valid only with
                                                      //  mr_ph_datavld=1
  ,output [PHY_DATA_WIDTH-1:0]        mr_ph_wdata_retry    // write data output to retry with ECC
  ,output                             mr_ph_wdatavld_early   // write data valid to phy - comes one clock earlier than mr_ph_wdatavld
  ,output                             mr_ph_wdatavld_early_retry   // write data valid to retry - comes one clock earlier than mr_ph_wdatavld
  ,output                             mr_yy_free_wr_entry_valid// done with this write entry
  ,output [WRCAM_ADDR_WIDTH_IE-1:0]   mr_yy_free_wr_entry    //write RAM to be used by TE
                                                              //  to return this entry to
                                                              //  the pool of available entries
                                                              // (qualified by mr_yy_free_wr_entry_valid) 
  ,output                             mr_gs_empty    // MR pipeline is empty
                                                      // (used to issue DFI controller update)

  ,input                              oc_parity_en // enables on-chip parity
  ,input                              oc_parity_type // selects parity type. 0 even, 1 odd
  ,output                             wdata_par_err
  ,output [CORE_MASK_WIDTH-1:0]       wdata_par_err_vec
  ,output                             wdata_par_err_ie

  ,input                              reg_ddrc_phy_dbi_mode
  ,input                              reg_ddrc_wr_dbi_en
  ,input                              reg_ddrc_dm_en
  ,input [3:0]                        reg_ddrc_burst_rdwr
   

   // MR to IH for free BWT
  // MR to WU for copy ECC to WR RAM //was removed, keep it just for avoiding re-numbering
//,output [1:0]                       mr_wu_ie_rmw_type
//,output [WRDATA_RAM_ADDR_WIDTH-1:0] mr_wu_ie_wr_ram_addr
//,output [CORE_DATA_WIDTH-1:0]       mr_wu_ie_wdata
//,output [CORE_DATA_WIDTH/8-1:0]     mr_wu_ie_wdata_mask_n
//,output [CORE_MASK_WIDTH-1:0]       mr_wu_ie_wdatapar 
//,output                             mr_wu_ie_wdata_valid
//,output                             mr_wu_ie_wdata_end
 

    ,input  [DFI_T_RDDATA_EN_WIDTH-1:0] reg_ddrc_dfi_t_rddata_en    // t_rddata_en parameter from dfi spec
    ,input  [DFI_TPHY_WRLAT_WIDTH-1:0]  reg_ddrc_dfi_tphy_wrlat     // write latency (command to data latency)
    ,input  [DFI_TPHY_WRDATA_WIDTH-1:0] reg_ddrc_dfi_tphy_wrdata    // tphy_wrdata parameter from dfi spec
    ,input                              reg_ddrc_dfi_lp_en_data
    ,input  [DFI_TWCK_EN_RD_WIDTH-1:0]  reg_ddrc_dfi_twck_en_rd     // WCK enable read timing
    ,input  [DFI_TWCK_EN_WR_WIDTH-1:0]  reg_ddrc_dfi_twck_en_wr     // WCK enable write timing


    ,output [CMD_DELAY_BITS-1:0]        dfi_cmd_delay
    ,output [1:0]                       mr_t_wrlat_add_sdr
    ,output [DFI_TPHY_WRLAT_WIDTH-1:0]     mr_t_wrlat
    ,output [1:0]                       mr_t_wrdata_add_sdr
    ,output [DFI_TPHY_WRDATA_WIDTH-1:0]    mr_t_wrdata
    ,output [1:0]                       mr_t_rddata_en_add_sdr
    ,output [DFI_T_RDDATA_EN_WIDTH-1:0] mr_t_rddata_en
    ,output [DFI_TWCK_EN_RD_WIDTH-2:0]  mr_lp_data_rd
    ,output [DFI_TWCK_EN_WR_WIDTH-2:0]  mr_lp_data_wr
    
// ocecc inputs
   ,input                                          ocecc_en
   ,input                                          ocecc_poison_pgen_mr_ecc
   ,input                                          ocecc_uncorr_err_intr_clr
// ocecc err outputs
   ,output                                         ocecc_mr_rd_corr_err
   ,output                                         ocecc_mr_rd_uncorr_err
   ,output [CORE_DATA_WIDTH/OCECC_MR_RD_GRANU-1:0] ocecc_mr_rd_byte_num

// occap specific input/output

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block
   ,input                      ddrc_cmp_en
   ,input                      ddrc_data_cmp_poison
   ,input                      ddrc_data_cmp_poison_full
   ,input                      ddrc_data_cmp_poison_err_inj
//spyglass enable_block W240
   ,output                     ddrc_data_cmp_error_mr
   ,output                     ddrc_data_cmp_error_full_mr
   ,output                     ddrc_data_cmp_error_seq_mr
   ,output                     ddrc_data_cmp_poison_complete_mr
);

  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------


   localparam NUM_INST = OCCAP_EN==1 ? 2 : 1;
   //localparam NUM_INST = 1;

   localparam NUM_OUTS = 60; // WARNING: update whenever a new output is added to mr.v
   localparam PW       = 32;
   // assign outputs width to internal parameters, update if outputs/parameters are changed
   localparam OUT0_W    = PHY_MASK_WIDTH; // mr_ph_wdatamask 
   localparam OUT1_W    = WRDATA_RAM_ADDR_WIDTH; // mr_wu_cerr_addr
   localparam OUT2_W    = WRDATA_RAM_ADDR_WIDTH; // mr_me_raddr
   localparam OUT3_W    = 1; // mr_me_re
   localparam OUT4_W    = PHY_DATA_WIDTH; // mr_ph_wdata
   localparam OUT5_W    = 1; // mr_ph_wdatavld_early
   localparam OUT6_W    = 1; // mr_yy_free_wr_entry_valid
   localparam OUT7_W    = WRCAM_ADDR_WIDTH_IE; // mr_yy_free_wr_entry
   localparam OUT8_W    = 1; // mr_gs_empty
   localparam OUT9_W    = 1; // wdata_par_err

   localparam OUT10_W   = CORE_MASK_WIDTH; // wdata_par_err_vec
   localparam OUT11_W   = 1; // wdata_par_err_ie
   localparam OUT12_W   = 1; // mr_ih_free_bwt_vld
   localparam OUT13_W   = BWT_BITS; // mr_ih_free_bwt
   localparam OUT14_W   = 2; // mr_wu_ie_rmw_type
   localparam OUT15_W   = WRDATA_RAM_ADDR_WIDTH; // mr_wu_ie_wr_ram_addr
   localparam OUT16_W   = CORE_DATA_WIDTH; // mr_wu_ie_wdata
   localparam OUT17_W   = CORE_DATA_WIDTH/8; // mr_wu_ie_wdata_mask_n
   localparam OUT18_W   = CORE_MASK_WIDTH; // mr_wu_ie_wdatapar
   localparam OUT19_W   = 1; // mr_wu_ie_wdata_valid

   localparam OUT20_W   = 1; // mr_wu_ie_wdata_end
   localparam OUT21_W   = BT_BITS; // mr_ih_lkp_bwt_by_bt
   localparam OUT22_W   = BT_BITS; // mr_ih_lkp_brt_by_bt
   localparam OUT23_W   = 1; // mr_ecc_acc_wr
   localparam OUT24_W   = ECC_RAM_ADDR_BITS; // mr_ecc_acc_waddr 
   localparam OUT25_W   = CORE_DATA_WIDTH; // mr_ecc_acc_wdata
   localparam OUT26_W   = CORE_MASK_WIDTH; // mr_ecc_acc_wdata_par
   localparam OUT27_W   = CORE_MASK_WIDTH; // mr_ecc_acc_wdata_mask_n
   localparam OUT28_W   = 1; // mr_ecc_acc_rd
   localparam OUT29_W   = ECC_RAM_ADDR_BITS; // mr_ecc_acc_raddr

   localparam OUT30_W   = ECC_RAM_ADDR_BITS; // mr_ecc_ram_raddr_2
   localparam OUT31_W   = 1; // mr_ecc_err_rd
   localparam OUT32_W   = ECC_ERR_RAM_ADDR_BITS; // mr_ecc_err_raddr
   localparam OUT33_W   = CMD_DELAY_BITS;    // dfi_cmd_delay
   localparam OUT34_W   = 2; // mr_t_wrlat_add_sdr
   localparam OUT35_W   = 6; // mr_t_wrlat
   localparam OUT36_W   = 2; // mr_t_wrdata_add_sdr
   localparam OUT37_W   = 6; // mr_t_wrdata
   localparam OUT38_W   = 2; // mr_t_rddata_en_add_sdr
   localparam OUT39_W   = 7; // mr_t_rddata_en

   localparam OUT40_W   = 1; // mr_ecc_acc_flush_en
   localparam OUT41_W   = BWT_BITS; // mr_ecc_acc_flush_addr
   localparam OUT42_W   = 1; // ocecc_mr_rd_corr_err
   localparam OUT43_W   = 1; // ocecc_mr_rd_uncorr_err
   localparam OUT44_W   = CORE_DATA_WIDTH/OCECC_MR_RD_GRANU; // ocecc_mr_rd_byte_num
   localparam OUT45_W   = PHY_MASK_WIDTH; // mr_ph_wdatamask_retry
   localparam OUT46_W   = PHY_DATA_WIDTH; // mr_ph_wdata_retry
   localparam OUT47_W   = 1; // mr_ph_wdatavld_early_retry
   localparam OUT48_W   = NUM_RANKS; // mr_wr_empty_per_rank
   localparam OUT49_W   = 1; // ddrc_reg_crc_poison_inject_complete
   localparam OUT50_W   = DFI_TWCK_EN_RD_WIDTH-1;  // mr_lp_data_rd
   localparam OUT51_W   = DFI_TWCK_EN_WR_WIDTH-1;  // mr_lp_data_wr
   localparam OUT52_W   = CORE_MASK_WIDTH; // dfi_wrdata_link_ecc
   localparam OUT53_W   = 1; // ddrc_reg_wr_linkecc_poison_complete
   localparam OUT54_W   = WRDATA_RAM_ADDR_WIDTH; // mr_wu_raddr
   localparam OUT55_W   = 1; // mr_me_re_last
   localparam OUT56_W   = CORE_DCERRBITS;//mr_ph_dbg_dfi_ecc_corrupt0
   localparam OUT57_W   = CORE_DCERRBITS;//mr_ph_dbg_dfi_ecc_corrupt1
   localparam OUT58_W   = DFI_KBD_WIDTH;//mr_ph_dbg_dfi_ecc_wdata_kbd
   localparam OUT59_W   = 1; // mr_re_wdata_lsb_sel
                  
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

   localparam OUT_TOTW = OUT59_OFF;

   localparam [NUM_OUTS*PW-1:0] WIDTH_OFFSET =
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

  wire                    full_w [NUM_INST-1:0];
    
  wire [PHY_MASK_WIDTH-1:0]        mr_ph_wdatamask_w [NUM_INST-1:0];
  wire [WRDATA_RAM_ADDR_WIDTH-1:0] mr_wu_cerr_addr_w [NUM_INST-1:0];
  wire [WRDATA_RAM_ADDR_WIDTH-1:0] mr_wu_raddr_w [NUM_INST-1:0];
  wire [WRDATA_RAM_ADDR_WIDTH-1:0] mr_me_raddr_w [NUM_INST-1:0];
  wire                             mr_me_re_w [NUM_INST-1:0];
  wire [PHY_DATA_WIDTH-1:0]        mr_ph_wdata_w [NUM_INST-1:0];
  wire                             mr_ph_wdatavld_early_w [NUM_INST-1:0];
  wire                             mr_yy_free_wr_entry_valid_w [NUM_INST-1:0];
  wire [WRCAM_ADDR_WIDTH_IE-1:0]   mr_yy_free_wr_entry_w [NUM_INST-1:0];
  wire                             mr_gs_empty_w [NUM_INST-1:0];
  wire                             wdata_par_err_w [NUM_INST-1:0];
  wire [CORE_MASK_WIDTH-1:0]       wdata_par_err_vec_w [NUM_INST-1:0];
  wire                             wdata_par_err_ie_w [NUM_INST-1:0];
  wire                             mr_ih_free_bwt_vld_w [NUM_INST-1:0];
  wire [BWT_BITS-1:0]              mr_ih_free_bwt_w [NUM_INST-1:0];
  wire [1:0]                       mr_wu_ie_rmw_type_w [NUM_INST-1:0];
  wire [WRDATA_RAM_ADDR_WIDTH-1:0] mr_wu_ie_wr_ram_addr_w [NUM_INST-1:0];
  wire [CORE_DATA_WIDTH-1:0]       mr_wu_ie_wdata_w [NUM_INST-1:0];
  wire [CORE_DATA_WIDTH/8-1:0]     mr_wu_ie_wdata_mask_n_w [NUM_INST-1:0];
  wire [CORE_MASK_WIDTH-1:0]       mr_wu_ie_wdatapar_w [NUM_INST-1:0];
  wire                             mr_wu_ie_wdata_valid_w [NUM_INST-1:0];
  wire                             mr_wu_ie_wdata_end_w [NUM_INST-1:0];
  wire [BT_BITS-1:0]               mr_ih_lkp_bwt_by_bt_w [NUM_INST-1:0];
  wire [BT_BITS-1:0]               mr_ih_lkp_brt_by_bt_w [NUM_INST-1:0];
  wire                             mr_ecc_acc_wr_w [NUM_INST-1:0];
  wire [ECC_RAM_ADDR_BITS-1:0]     mr_ecc_acc_waddr_w [NUM_INST-1:0];
  wire [CORE_DATA_WIDTH-1:0]       mr_ecc_acc_wdata_w [NUM_INST-1:0];
  wire [CORE_MASK_WIDTH-1:0]       mr_ecc_acc_wdata_par_w [NUM_INST-1:0];
  wire [CORE_MASK_WIDTH-1:0]       mr_ecc_acc_wdata_mask_n_w [NUM_INST-1:0];
  wire                             mr_ecc_acc_rd_w [NUM_INST-1:0];
  wire [ECC_RAM_ADDR_BITS-1:0]     mr_ecc_acc_raddr_w [NUM_INST-1:0];
  wire [ECC_RAM_ADDR_BITS-1:0]     mr_ecc_ram_raddr_2_w [NUM_INST-1:0];
  wire                             mr_ecc_err_rd_w [NUM_INST-1:0];
  wire [ECC_ERR_RAM_ADDR_BITS-1:0] mr_ecc_err_raddr_w [NUM_INST-1:0];
  wire [CMD_DELAY_BITS-1:0]        dfi_cmd_delay_w [NUM_INST-1:0];
  wire [1:0]                       mr_t_wrlat_add_sdr_w [NUM_INST-1:0];
  wire [$bits(mr_t_wrlat)-1:0]     mr_t_wrlat_w [NUM_INST-1:0];
  wire [1:0]                       mr_t_wrdata_add_sdr_w [NUM_INST-1:0];
  wire [$bits(mr_t_wrdata)-1:0]    mr_t_wrdata_w [NUM_INST-1:0];
  wire [1:0]                       mr_t_rddata_en_add_sdr_w [NUM_INST-1:0];
  wire [$bits(mr_t_rddata_en)-1:0] mr_t_rddata_en_w [NUM_INST-1:0];
  wire [DFI_TWCK_EN_RD_WIDTH-2:0]  mr_lp_data_rd_w [NUM_INST-1:0];
  wire [DFI_TWCK_EN_WR_WIDTH-2:0]  mr_lp_data_wr_w [NUM_INST-1:0];
  wire                             mr_ecc_acc_flush_en_w [NUM_INST-1:0];
  wire [BWT_BITS-1:0]              mr_ecc_acc_flush_addr_w [NUM_INST-1:0];
  wire                             ocecc_mr_rd_corr_err_w [NUM_INST-1:0];
  wire                             ocecc_mr_rd_uncorr_err_w [NUM_INST-1:0];
  wire [CORE_DATA_WIDTH/OCECC_MR_RD_GRANU-1:0] ocecc_mr_rd_byte_num_w [NUM_INST-1:0];
  wire [PHY_MASK_WIDTH-1:0]        mr_ph_wdatamask_retry_w [NUM_INST-1:0];
  wire [PHY_DATA_WIDTH-1:0]        mr_ph_wdata_retry_w [NUM_INST-1:0];
  wire                             mr_ph_wdatavld_early_retry_w [NUM_INST-1:0];
  wire [NUM_RANKS-1:0]             mr_wr_empty_per_rank_w [NUM_INST-1:0];
  wire                             ddrc_reg_crc_poison_inject_complete_w [NUM_INST-1:0];
  wire [CORE_MASK_WIDTH-1:0]       dfi_wrdata_link_ecc_w [NUM_INST-1:0];
  wire                             ddrc_reg_wr_linkecc_poison_complete_w [NUM_INST-1:0];
  wire                             mr_me_re_last_w [NUM_INST-1:0];
  wire [CORE_DCERRBITS-1:0]        mr_ph_dbg_dfi_ecc_corrupt0_w[NUM_INST-1:0];
  wire [CORE_DCERRBITS-1:0]        mr_ph_dbg_dfi_ecc_corrupt1_w[NUM_INST-1:0];
  wire [DFI_KBD_WIDTH-1:0]         mr_ph_dbg_dfi_ecc_wdata_kbd_w[NUM_INST-1:0];
  wire                             mr_re_wdata_lsb_sel_w [NUM_INST-1:0];


  // output assign drivwen from inst0
  assign mr_ph_wdatamask = mr_ph_wdatamask_w[0];
  assign mr_wu_raddr = mr_wu_raddr_w[0];
  assign mr_me_raddr = mr_me_raddr_w[0];
  assign mr_me_re = mr_me_re_w[0];
  assign mr_ph_wdata = mr_ph_wdata_w[0];
  assign mr_ph_wdatavld_early = mr_ph_wdatavld_early_w[0];
  assign mr_yy_free_wr_entry_valid = mr_yy_free_wr_entry_valid_w[0];
  assign mr_yy_free_wr_entry = mr_yy_free_wr_entry_w[0];
  assign mr_gs_empty = mr_gs_empty_w[0];
  assign wdata_par_err = wdata_par_err_w[0];
  assign wdata_par_err_vec = wdata_par_err_vec_w[0];
  assign wdata_par_err_ie = wdata_par_err_ie_w[0];
//assign mr_wu_ie_rmw_type = mr_wu_ie_rmw_type_w[0];
//assign mr_wu_ie_wr_ram_addr = mr_wu_ie_wr_ram_addr_w[0];
//assign mr_wu_ie_wdata = mr_wu_ie_wdata_w[0];
//assign mr_wu_ie_wdata_mask_n = mr_wu_ie_wdata_mask_n_w[0];
//assign mr_wu_ie_wdatapar = mr_wu_ie_wdatapar_w[0];
//assign mr_wu_ie_wdata_valid = mr_wu_ie_wdata_valid_w[0];
//assign mr_wu_ie_wdata_end = mr_wu_ie_wdata_end_w[0];
  assign dfi_cmd_delay              = dfi_cmd_delay_w[0];
  assign mr_t_wrlat_add_sdr         = mr_t_wrlat_add_sdr_w[0];
  assign mr_t_wrlat                 = mr_t_wrlat_w[0];
  assign mr_t_wrdata_add_sdr        = mr_t_wrdata_add_sdr_w[0];
  assign mr_t_wrdata                = mr_t_wrdata_w[0];
  assign mr_t_rddata_en_add_sdr     = mr_t_rddata_en_add_sdr_w[0];
  assign mr_t_rddata_en             = mr_t_rddata_en_w[0];
  assign mr_lp_data_rd              = mr_lp_data_rd_w[0];
  assign mr_lp_data_wr              = mr_lp_data_wr_w[0];
  assign ocecc_mr_rd_corr_err = ocecc_mr_rd_corr_err_w[0];
  assign ocecc_mr_rd_uncorr_err = ocecc_mr_rd_uncorr_err_w[0];
  assign ocecc_mr_rd_byte_num = ocecc_mr_rd_byte_num_w[0];
  assign mr_ph_wdatamask_retry = mr_ph_wdatamask_retry_w[0];
  assign mr_ph_wdata_retry = mr_ph_wdata_retry_w[0];
  assign mr_ph_wdatavld_early_retry = mr_ph_wdatavld_early_retry_w[0];
  assign mr_wr_empty_per_rank = mr_wr_empty_per_rank_w[0];


  generate
    for (n=0; n<NUM_INST; n=n+1) begin: mr_inst
 
    // MR (Memory Read) block : read data from RAM to perform DDR Writes
    mr
        
              #(        

                .CORE_DATA_WIDTH                (CORE_DATA_WIDTH),
                .CORE_MASK_WIDTH                (CORE_MASK_WIDTH),
                .WRSRAM_DATA_WIDTH              (WRSRAM_DATA_WIDTH),
                .WRSRAM_MASK_WIDTH              (WRSRAM_MASK_WIDTH),
                .PHY_DATA_WIDTH                 (PHY_DATA_WIDTH),
                .PHY_MASK_WIDTH                 (PHY_MASK_WIDTH),
                .WRCAM_ADDR_WIDTH               (WRCAM_ADDR_WIDTH),
                .WRCAM_ADDR_WIDTH_IE            (WRCAM_ADDR_WIDTH_IE),
                .WRDATA_RAM_ADDR_WIDTH          (WRDATA_RAM_ADDR_WIDTH),
                .PARTIAL_WR_BITS                (PARTIAL_WR_BITS),
                .PW_WORD_CNT_WD_MAX             (PW_WORD_CNT_WD_MAX),
                .NUM_RANKS                      (NUM_RANKS),
                .WDATARAM_RD_LATENCY            (WDATARAM_RD_LATENCY),
                .MAX_CMD_DELAY                  (MAX_CMD_DELAY),
                .CMD_DELAY_BITS                 (CMD_DELAY_BITS),
                .OCPAR_EN                       (OCPAR_EN),
                .WRDATA_CYCLES                  (WRDATA_CYCLES),
                .CMD_LEN_BITS                   (CMD_LEN_BITS),
                
                .OCECC_EN                       (OCECC_EN         ),
                .OCECC_MR_RD_GRANU              (OCECC_MR_RD_GRANU),
                .WDATA_PAR_WIDTH                (WDATA_PAR_WIDTH  ),
                .WDATA_PAR_WIDTH_EXT            (WDATA_PAR_WIDTH_EXT),
                .DRAM_BYTE_NUM                  (DRAM_BYTE_NUM)
               ,.DFI_KBD_WIDTH                  (DFI_KBD_WIDTH)

                )
        mr (
                .co_yy_clk                      (co_yy_clk),
                .core_ddrc_rstn                 (core_ddrc_rstn),
                .ddrc_cg_en                     (ddrc_cg_en),
                .dh_mr_data_bus_width           (dh_mr_data_bus_width),
                .dh_mr_en_2t_timing_mode        (dh_mr_en_2t_timing_mode),
                .dh_mr_frequency_ratio          (dh_mr_frequency_ratio),
                .dh_mr_lpddr4                   (dh_mr_lpddr4),
                .reg_ddrc_lpddr5                (reg_ddrc_lpddr5),
                .ts_pi_mwr                      (ts_pi_mwr),
                .reg_ddrc_lp_optimized_write    (reg_ddrc_lp_optimized_write), // To save power consumption LPDDR4 write DQ is set to 8'hF8 if this is set to 1 (masked + DBI)
                .gs_mr_write                    (gs_mr_write),
//`ifdef MEMC_FREQ_RATIO_4
                .gs_mr_write_ph                 (gs_mr_write_ph),
                .gs_mr_read_ph                  (gs_mr_read_ph),
//`endif // MEMC_FREQ_RATIO_4
                .mr_wr_empty_per_rank           (mr_wr_empty_per_rank_w[n]),
                .te_mr_wr_ram_addr              (te_mr_wr_ram_addr),
                .te_pi_wr_word_valid            (te_pi_wr_word_valid),
                .te_mr_ram_raddr_lsb_first      (te_mr_ram_raddr_lsb_first),
                .te_mr_pw_num_beats_m1          (te_mr_pw_num_beats_m1),


                .me_mr_rdata                    (me_mr_rdata),
                .me_mr_rdatamask                (me_mr_rdatamask),
                .mr_ph_wdatamask                (mr_ph_wdatamask_w[n]),
                .mr_ph_wdatamask_retry          (mr_ph_wdatamask_retry_w[n]),
                .me_mr_rdatapar                 (me_mr_rdatapar),
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and Sideband-ECC are disabled
//SJ: Intentionally left unread
                .mr_wu_cerr_addr                (mr_wu_cerr_addr_w[n]),
//spyglass enable_block W528
                .mr_wu_raddr                    (mr_wu_raddr_w[n]),

                .oc_parity_en                   (oc_parity_en),
                .oc_parity_type                 (oc_parity_type),
                .wdata_par_err                  (wdata_par_err_w[n]),
                .wdata_par_err_vec              (wdata_par_err_vec_w[n]),
                .wdata_par_err_ie               (wdata_par_err_ie_w[n]),

                .mr_gs_empty                    (mr_gs_empty_w[n]),
                .mr_me_raddr                    (mr_me_raddr_w[n]),
                .mr_me_re                       (mr_me_re_w[n]),
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when write CRC Retry is disabled
//SJ: Intentionally left unread
                .mr_me_re_last                  (mr_me_re_last_w[n]),
                .mr_re_wdata_lsb_sel            (mr_re_wdata_lsb_sel_w[n]),
//spyglass enable_block W528
                .mr_yy_free_wr_entry_valid      (mr_yy_free_wr_entry_valid_w[n]),
                .mr_yy_free_wr_entry            (mr_yy_free_wr_entry_w[n]),
                .mr_ph_wdatavld_early           (mr_ph_wdatavld_early_w[n]),
                .mr_ph_wdatavld_early_retry     (mr_ph_wdatavld_early_retry_w[n]),
                .mr_ph_wdata                    (mr_ph_wdata_w[n]),
                .mr_ph_wdata_retry              (mr_ph_wdata_retry_w[n])
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when Link-ECC are disabled
//SJ: Intentionally left unread
                ,.dfi_wrdata_link_ecc            (dfi_wrdata_link_ecc_w[n])
                ,.ddrc_reg_wr_linkecc_poison_complete (ddrc_reg_wr_linkecc_poison_complete_w[n])
//spyglass enable_block W528
                ,.reg_ddrc_phy_dbi_mode          (reg_ddrc_phy_dbi_mode)
                ,.reg_ddrc_wr_dbi_en             (reg_ddrc_wr_dbi_en)
                ,.reg_ddrc_dm_en                 (reg_ddrc_dm_en)

                ,.reg_ddrc_burst_rdwr            (reg_ddrc_burst_rdwr)    
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and DDR4 are disabled
//SJ: Intentionally left unread
                ,.ddrc_reg_crc_poison_inject_complete (ddrc_reg_crc_poison_inject_complete_w[n])
//spyglass enable_block W528
                // MR to IH for free BWT
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR and Inline-ECC are disabled
//SJ: Intentionally left unread
                ,.mr_ih_free_bwt_vld            (mr_ih_free_bwt_vld_w[n]    )
                ,.mr_ih_free_bwt                (mr_ih_free_bwt_w[n]        )

                ,.mr_ih_lkp_bwt_by_bt           (mr_ih_lkp_bwt_by_bt_w[n]  )
                ,.mr_ih_lkp_brt_by_bt           (mr_ih_lkp_brt_by_bt_w[n]  )
                
                ,.mr_ecc_acc_wr                 (mr_ecc_acc_wr_w[n]          )
                ,.mr_ecc_acc_waddr              (mr_ecc_acc_waddr_w[n]       )
                ,.mr_ecc_acc_wdata              (mr_ecc_acc_wdata_w[n]       )
                ,.mr_ecc_acc_wdata_par          (mr_ecc_acc_wdata_par_w[n]   )
                ,.mr_ecc_acc_wdata_mask_n       (mr_ecc_acc_wdata_mask_n_w[n])
                ,.mr_ecc_acc_rd                 (mr_ecc_acc_rd_w[n]          )
                ,.mr_ecc_acc_raddr              (mr_ecc_acc_raddr_w[n]       )
                ,.mr_ecc_ram_raddr_2            (mr_ecc_ram_raddr_2_w[n]     )
                ,.mr_ecc_err_rd                 (mr_ecc_err_rd_w[n]          )
                ,.mr_ecc_err_raddr              (mr_ecc_err_raddr_w[n]       )
                ,.mr_ecc_acc_flush_en           (mr_ecc_acc_flush_en_w[n]    )
                ,.mr_ecc_acc_flush_addr         (mr_ecc_acc_flush_addr_w[n]  )
//spyglass enable_block W528

               ,.reg_ddrc_dfi_t_rddata_en       (reg_ddrc_dfi_t_rddata_en)
               ,.reg_ddrc_dfi_tphy_wrlat        (reg_ddrc_dfi_tphy_wrlat)
               ,.reg_ddrc_dfi_tphy_wrdata       (reg_ddrc_dfi_tphy_wrdata)
               ,.reg_ddrc_dfi_lp_en_data        (reg_ddrc_dfi_lp_en_data)
               ,.reg_ddrc_dfi_twck_en_rd        (reg_ddrc_dfi_twck_en_rd)
               ,.reg_ddrc_dfi_twck_en_wr        (reg_ddrc_dfi_twck_en_wr)
               ,.dfi_cmd_delay                  (dfi_cmd_delay_w[n])
               ,.mr_t_wrlat_add_sdr             (mr_t_wrlat_add_sdr_w[n])
               ,.mr_t_wrlat                     (mr_t_wrlat_w[n])
               ,.mr_t_wrdata_add_sdr            (mr_t_wrdata_add_sdr_w[n])
               ,.mr_t_wrdata                    (mr_t_wrdata_w[n])
               ,.mr_t_rddata_en_add_sdr         (mr_t_rddata_en_add_sdr_w[n])
               ,.mr_t_rddata_en                 (mr_t_rddata_en_w[n])
               ,.mr_lp_data_rd                  (mr_lp_data_rd_w[n])
               ,.mr_lp_data_wr                  (mr_lp_data_wr_w[n])
               ,.ocecc_en                       (ocecc_en)
               ,.ocecc_poison_pgen_mr_ecc       (ocecc_poison_pgen_mr_ecc)
               ,.ocecc_uncorr_err_intr_clr      (ocecc_uncorr_err_intr_clr)
               ,.ocecc_mr_rd_corr_err           (ocecc_mr_rd_corr_err_w[n])
               ,.ocecc_mr_rd_uncorr_err         (ocecc_mr_rd_uncorr_err_w[n])
               ,.ocecc_mr_rd_byte_num           (ocecc_mr_rd_byte_num_w[n])
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when OCPAR is disabled
//SJ: Intentionally left unread
               ,.mr_wu_ie_rmw_type              (mr_wu_ie_rmw_type_w[n])
               ,.mr_wu_ie_wr_ram_addr           (mr_wu_ie_wr_ram_addr_w[n])
               ,.mr_wu_ie_wdata                 (mr_wu_ie_wdata_w[n])
               ,.mr_wu_ie_wdata_mask_n          (mr_wu_ie_wdata_mask_n_w[n])
               ,.mr_wu_ie_wdatapar              (mr_wu_ie_wdatapar_w[n])
               ,.mr_wu_ie_wdata_valid           (mr_wu_ie_wdata_valid_w[n])
               ,.mr_wu_ie_wdata_end             (mr_wu_ie_wdata_end_w[n])
//spyglass enable_block W528
//spyglass disable_block W528
//SMD: Signal or Variable set but not read when DDRCTL_EXT_SBECC are disabled
//SJ: Intentionally left unread
               ,.mr_ph_dbg_dfi_ecc_corrupt0    (mr_ph_dbg_dfi_ecc_corrupt0_w[n])
               ,.mr_ph_dbg_dfi_ecc_corrupt1    (mr_ph_dbg_dfi_ecc_corrupt1_w[n])
               ,.mr_ph_dbg_dfi_ecc_wdata_kbd   (mr_ph_dbg_dfi_ecc_wdata_kbd_w[n])
//spyglass enable_block W528
        ); // end mr instantiation

    end // mr_inst

    if (OCCAP_EN==1) begin: CMP_en

      // handle Xs

      // mr_ph_wdata can have X in any config
      reg [PHY_DATA_WIDTH-1:0]    mr_ph_wdata_w_no_x [NUM_INST-1:0];      
      // drive to a value in possible x case
      // passthrough otherwise
      always @(mr_ph_wdata_w[0] or mr_ph_wdata_w[1]) begin : mr_ph_wdata_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
        
         
          for (x_cnt=0; x_cnt< PHY_DATA_WIDTH; x_cnt=x_cnt+1) begin
            if (mr_ph_wdata_w[i_cnt][x_cnt]) begin
              mr_ph_wdata_w_no_x[i_cnt][x_cnt] = 1'b1;
            end else begin
              mr_ph_wdata_w_no_x[i_cnt][x_cnt] = 1'b0;
           end
          end // for x_cnt      
        end // for i_cnt
      end

      // mr_ecc_acc_wdata/mr_ecc_acc_wdata_par can have x 
      reg [CORE_DATA_WIDTH-1:0]       mr_ecc_acc_wdata_w_no_x[NUM_INST-1:0];
      reg [CORE_MASK_WIDTH-1:0]       mr_ecc_acc_wdata_par_w_no_x[NUM_INST-1:0];
      reg [CORE_MASK_WIDTH-1:0]       mr_wu_ie_wdatapar_w_no_x[NUM_INST-1:0];
 
      // drive to a value in possible x case
      // passthrough otherwise
      always @(   mr_ecc_acc_wdata_w[0] or mr_ecc_acc_wdata_w[1] 
               or mr_ecc_acc_wdata_par_w[0] or mr_ecc_acc_wdata_par_w[1] 
               or mr_wu_ie_wdatapar_w[0] or mr_wu_ie_wdatapar_w[1]) begin : mr_ecc_acc_wdata_w_no_x_PROC
        integer i_cnt;
        integer x_cnt;
        integer y_cnt;
        integer z_cnt;
        for (i_cnt=0; i_cnt< NUM_INST; i_cnt=i_cnt+1) begin
        
              mr_ecc_acc_wdata_w_no_x[i_cnt]     = mr_ecc_acc_wdata_w[i_cnt];
              mr_ecc_acc_wdata_par_w_no_x[i_cnt] = mr_ecc_acc_wdata_par_w[i_cnt];
              mr_wu_ie_wdatapar_w_no_x[i_cnt]    = mr_wu_ie_wdatapar_w[i_cnt];
        end // for i_cnt

      end

      wire [OUT_TOTW-1:0] cmp_in0, cmp_in1;

      assign cmp_in0 = {                  
                        mr_ph_dbg_dfi_ecc_wdata_kbd_w[0],
                        mr_ph_dbg_dfi_ecc_corrupt1_w[0],
                        mr_ph_dbg_dfi_ecc_corrupt0_w[0],
                        mr_me_re_last_w[0],
                        ddrc_reg_wr_linkecc_poison_complete_w[0],
                        mr_lp_data_rd_w[0],
                        mr_lp_data_wr_w[0],
                        dfi_wrdata_link_ecc_w[0],
                        ddrc_reg_crc_poison_inject_complete_w[0],
                        mr_wr_empty_per_rank,
                        mr_ph_wdatavld_early_retry,      
                        mr_ph_wdata_retry,
                        mr_ph_wdatamask_retry,
                        ocecc_mr_rd_byte_num,
                        ocecc_mr_rd_uncorr_err,
                        ocecc_mr_rd_corr_err,
                        mr_ecc_acc_flush_addr_w[0],
                        mr_ecc_acc_flush_en_w[0],
                        mr_t_rddata_en,
                        mr_t_rddata_en_add_sdr,
                        mr_t_wrdata,
                        mr_t_wrdata_add_sdr,
                        mr_t_wrlat,
                        mr_t_wrlat_add_sdr,
                        dfi_cmd_delay,
                        mr_ecc_err_raddr_w[0],
                        mr_ecc_err_rd_w[0],
                        mr_ecc_ram_raddr_2_w[0],
                        mr_ecc_acc_raddr_w[0],
                        mr_ecc_acc_rd_w[0],
                        mr_ecc_acc_wdata_mask_n_w[0],
                        mr_ecc_acc_wdata_par_w_no_x[0], // no_x
                        mr_ecc_acc_wdata_w_no_x[0], // no_x
                        mr_ecc_acc_waddr_w[0],
                        mr_ecc_acc_wr_w[0],
                        mr_ih_lkp_brt_by_bt_w[0],
                        mr_ih_lkp_bwt_by_bt_w[0],
                        mr_wu_ie_wdata_end_w[0],
                        mr_wu_ie_wdata_valid_w[0],
                        mr_wu_ie_wdatapar_w_no_x[0],
                        mr_wu_ie_wdata_mask_n_w[0],
                        mr_wu_ie_wdata_w[0],
                        mr_wu_ie_wr_ram_addr_w[0],
                        mr_wu_ie_rmw_type_w[0],
                        mr_ih_free_bwt_w[0],
                        mr_ih_free_bwt_vld_w[0],
                        wdata_par_err_ie,
                        wdata_par_err_vec,
                        wdata_par_err,
                        mr_gs_empty,
                        mr_yy_free_wr_entry,
                        mr_yy_free_wr_entry_valid,
                        mr_ph_wdatavld_early,
                        mr_ph_wdata_w_no_x[0], // no_x
                        mr_me_re,
                        mr_me_raddr,
                        mr_wu_cerr_addr_w[0],
                        mr_wu_raddr_w[0],
                        mr_ph_wdatamask,
                        mr_re_wdata_lsb_sel_w[0]
                        };


      assign cmp_in1 = {
                        mr_ph_dbg_dfi_ecc_wdata_kbd_w[NUM_INST-1],
                        mr_ph_dbg_dfi_ecc_corrupt1_w[NUM_INST-1],
                        mr_ph_dbg_dfi_ecc_corrupt0_w[NUM_INST-1],
                        mr_me_re_last_w[NUM_INST-1],
                        ddrc_reg_wr_linkecc_poison_complete_w[NUM_INST-1],
                        mr_lp_data_rd_w[NUM_INST-1],
                        mr_lp_data_wr_w[NUM_INST-1],
                        dfi_wrdata_link_ecc_w[NUM_INST-1],
                        ddrc_reg_crc_poison_inject_complete_w[NUM_INST-1],
                        mr_wr_empty_per_rank_w[NUM_INST-1],
                        mr_ph_wdatavld_early_retry_w[NUM_INST-1],
                        mr_ph_wdata_retry_w[NUM_INST-1],
                        mr_ph_wdatamask_retry_w[NUM_INST-1],
                        ocecc_mr_rd_byte_num_w[NUM_INST-1],
                        ocecc_mr_rd_uncorr_err_w[NUM_INST-1],
                        ocecc_mr_rd_corr_err_w[NUM_INST-1],
                        mr_ecc_acc_flush_addr_w[NUM_INST-1],
                        mr_ecc_acc_flush_en_w[NUM_INST-1],
                        mr_t_rddata_en_w[NUM_INST-1],
                        mr_t_rddata_en_add_sdr_w[NUM_INST-1],
                        mr_t_wrdata_w[NUM_INST-1],
                        mr_t_wrdata_add_sdr_w[NUM_INST-1],
                        mr_t_wrlat_w[NUM_INST-1],
                        mr_t_wrlat_add_sdr_w[NUM_INST-1],
                        dfi_cmd_delay_w[NUM_INST-1],
                        mr_ecc_err_raddr_w[NUM_INST-1],
                        mr_ecc_err_rd_w[NUM_INST-1],
                        mr_ecc_ram_raddr_2_w[NUM_INST-1],
                        mr_ecc_acc_raddr_w[NUM_INST-1],
                        mr_ecc_acc_rd_w[NUM_INST-1],
                        mr_ecc_acc_wdata_mask_n_w[NUM_INST-1],
                        mr_ecc_acc_wdata_par_w_no_x[NUM_INST-1], // no_x
                        mr_ecc_acc_wdata_w_no_x[NUM_INST-1], // no_x
                        mr_ecc_acc_waddr_w[NUM_INST-1],
                        mr_ecc_acc_wr_w[NUM_INST-1],
                        mr_ih_lkp_brt_by_bt_w[NUM_INST-1],
                        mr_ih_lkp_bwt_by_bt_w[NUM_INST-1],
                        mr_wu_ie_wdata_end_w[NUM_INST-1],
                        mr_wu_ie_wdata_valid_w[NUM_INST-1],
                        mr_wu_ie_wdatapar_w_no_x[NUM_INST-1],
                        mr_wu_ie_wdata_mask_n_w[NUM_INST-1],
                        mr_wu_ie_wdata_w[NUM_INST-1],
                        mr_wu_ie_wr_ram_addr_w[NUM_INST-1],
                        mr_wu_ie_rmw_type_w[NUM_INST-1],
                        mr_ih_free_bwt_w[NUM_INST-1],
                        mr_ih_free_bwt_vld_w[NUM_INST-1],
                        wdata_par_err_ie_w[NUM_INST-1],
                        wdata_par_err_vec_w[NUM_INST-1],
                        wdata_par_err_w[NUM_INST-1],
                        mr_gs_empty_w[NUM_INST-1],
                        mr_yy_free_wr_entry_w[NUM_INST-1],
                        mr_yy_free_wr_entry_valid_w[NUM_INST-1],
                        mr_ph_wdatavld_early_w[NUM_INST-1],
                        mr_ph_wdata_w_no_x[NUM_INST-1], // no_x
                        mr_me_re_w[NUM_INST-1],
                        mr_me_raddr_w[NUM_INST-1],
                        mr_wu_cerr_addr_w[NUM_INST-1],
                        mr_wu_raddr_w[NUM_INST-1],
                        mr_ph_wdatamask_w[NUM_INST-1],
                        mr_re_wdata_lsb_sel_w[NUM_INST-1]
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
      mr_cmp
      (
         .clk                 (co_yy_clk),
         .rst_n               (core_ddrc_rstn),
         .in0                 (cmp_in0),
         .in1                 (cmp_in1),
         .cmp_en              (ddrc_cmp_en),
         .cmp_poison          (ddrc_data_cmp_poison),
         .cmp_poison_full     (ddrc_data_cmp_poison_full),
         .cmp_poison_err_inj  (ddrc_data_cmp_poison_err_inj),
         .cmp_err             (ddrc_data_cmp_error_mr),
         .cmp_err_full        (ddrc_data_cmp_error_full_mr),
         .cmp_err_seq         (ddrc_data_cmp_error_seq_mr),
         .cmp_poison_complete (ddrc_data_cmp_poison_complete_mr)
      );

   end // CMP_en
   else begin: OCCAP_dis
      assign ddrc_data_cmp_error_mr           = 1'b0;
      assign ddrc_data_cmp_error_full_mr      = 1'b0;
      assign ddrc_data_cmp_error_seq_mr       = 1'b0;
      assign ddrc_data_cmp_poison_complete_mr = 1'b0;

   end // OCCAP_dis

endgenerate

endmodule // mr_wrapper
