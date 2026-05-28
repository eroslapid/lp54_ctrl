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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/teengine.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// ---------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module teengine #(
   //-------------------------------- PARAMETERS ----------------------------------    
    parameter  CHANNEL_NUM             = 0
   ,parameter  RD_CAM_ADDR_BITS        = 0
   ,parameter  WR_CAM_ADDR_BITS        = 0
   ,parameter  WR_ECC_CAM_ADDR_BITS    = 0
   ,parameter  WR_CAM_ADDR_BITS_IE     = 0
   ,parameter  MAX_CAM_ADDR_BITS       = 0
   ,parameter  RANK_BITS               = `MEMC_RANK_BITS
   ,parameter  LRANK_BITS              = `UMCTL2_LRANK_BITS        // max supported of ranks in the system 
                                                                   // This depends on number of Logical rank not Physical rank.
                                                                   // This is the same for non 3DS configuration.
   ,parameter  BG_BITS                 = `MEMC_BG_BITS             // max supported bank groups per rank
   ,parameter  BANK_BITS               = `MEMC_BANK_BITS           // max supported banks per rank
   ,parameter  BG_BANK_BITS            = `MEMC_BG_BANK_BITS        // max supported banks groups per rank
   ,parameter  PAGE_BITS               = `MEMC_PAGE_BITS
   ,parameter  BLK_BITS                = `MEMC_BLK_BITS            // write CAM only
   ,parameter  BSM_BITS                = `UMCTL2_BSM_BITS          // max supported BSM
   ,parameter  CMD_LEN_BITS            = 1
   ,parameter  OTHER_RD_ENTRY_BITS     = 30                        // override: # of other bits to track in read CAM
   ,parameter  OTHER_WR_ENTRY_BITS     = 2                         // override: # of other bits to track in write CAM
   ,parameter  OTHER_RD_RMW_LSB        = `MEMC_TAGBITS                         // LSB of RMW type for RD_OTHER field
   ,parameter  OTHER_RD_RMW_TYPE_BITS  = 2                         // no if bits of RMW type for RD_OTHER field
   ,parameter  PARTIAL_WR_BITS         = `UMCTL2_PARTIAL_WR_BITS   // bits for PARTIAL_WR logic
   ,parameter  PARTIAL_WR_BITS_LOG2    = `log2(PARTIAL_WR_BITS)     // bits for PARTIAL_WR logic
   ,parameter  PW_WORD_CNT_WD_MAX      = 2
   ,parameter  PW_BC_SEL_BITS          = 3
   ,parameter  AUTOPRE_BITS            = 1
   ,parameter  RANKBANK_BITS           = LRANK_BITS + BG_BANK_BITS
   ,parameter  TOTAL_LRANKS            = 1 << LRANK_BITS
   ,parameter  TOTAL_BANKS             = 1 << (LRANK_BITS + BG_BANK_BITS)
   ,parameter  RD_CAM_ENTRIES          = 0
   ,parameter  WR_CAM_ENTRIES          = 0
   ,parameter  WR_CAM_ENTRIES_IE       = 0
   ,parameter  WR_ECC_CAM_ENTRIES      = 0
   ,parameter  TOTAL_BSMS              = `UMCTL2_NUM_BSM
   ,parameter  RD_LATENCY_BITS         = `UMCTL2_XPI_RQOS_TW
   ,parameter  WR_LATENCY_BITS         = `UMCTL2_XPI_WQOS_TW
   ,parameter  MWR_BITS                = 1
   ,parameter  BT_BITS                 = `MEMC_BLK_TOKEN_BITS  // Override
   ,parameter  NO_OF_BT                = `MEMC_NO_OF_BLK_TOKEN // Override
   ,parameter  IE_RD_TYPE_BITS         = 2 // Override
   ,parameter  IE_WR_TYPE_BITS         = 2 // Override
   ,parameter  IE_BURST_NUM_BITS       = 3
   ,parameter  HI_PRI_BITS             = 2
   ,parameter  IE_MASKED_BITS          = 1
   ,parameter  ECCAP_BITS              = 1
   ,parameter  WORD_BITS               = `MEMC_WORD_BITS
   ,parameter  RETRY_TIMES_WIDTH       = 3
   ,parameter  ENTRY_RETRY_TIMES_WIDTH = 4
   ,parameter   RETRY_WR_BITS          = 1
   ,parameter   RETRY_RD_BITS          = 1
   ,parameter  DDR4_COL3_BITS          = 1
   ,parameter  IE_TAG_BITS             = IE_RD_TYPE_BITS + IE_BURST_NUM_BITS + BT_BITS + ECCAP_BITS
   ,parameter  RMW_BITS                = 1
   ,parameter  CID_WIDTH               = `UMCTL2_CID_WIDTH
   ,parameter  AM_COL_WIDTH_H          = 5
   ,parameter  AM_COL_WIDTH_L          = 4
   ,parameter  WP_BITS                 = 1
   )
   (
   //---------------------------- INPUTS AND OUTPUTS ------------------------------
    input                                       core_ddrc_rstn
   ,input                                       dh_te_pageclose
   ,input   [7:0]                               dh_te_pageclose_timer
   ,input                                       co_te_clk
   ,input                                       ddrc_cg_en
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in te_assertions
   ,input                                       dh_te_dis_wc
//spyglass enable_block W240
   ,output  [TOTAL_BANKS-1:0]                   te_dh_rd_valid
   ,output  [TOTAL_BANKS-1:0]                   te_dh_rd_page_hit
   ,output  [TOTAL_BANKS-1:0]                   te_dh_wr_valid
   ,output  [TOTAL_BANKS-1:0]                   te_dh_wr_page_hit
//    ,input                                       dh_te_dis_autopre_collide_opt     // by default, auto-precharge will
//                                                                                   //  not be used when issuing a colliding
//                                                                                   //  read/write, to allow the subsequent
//                                                                                   //  write/read to take advantage of the
//                                                                                   //  open page.
//                                                                                   // set this bit to '1' to disable this
//                                                                                   //  performance optimization
   ,output  [TOTAL_BANKS-1:0]                   te_dh_rd_hi
   ,input   [RD_CAM_ADDR_BITS-1:0]              ih_te_rd_entry_num
   ,input                                       ih_te_rd_valid
   ,input   [WR_CAM_ADDR_BITS_IE-1:0]           ih_te_wr_entry_num
   ,input                                       ih_te_wr_valid
   ,input                                       ih_te_rd_autopre
   ,input                                       ih_te_wr_autopre
   ,input   [1:0]                               ih_te_rd_hi_pri
   ,input                                       reg_ddrc_autopre_rmw
   ,input                                       reg_ddrc_dis_opt_ntt_by_act
   ,input                                       reg_ddrc_dis_opt_ntt_by_pre
   ,input                                       ih_te_rd_rmw
   ,input  [BG_BANK_BITS-1:0]                   ih_te_rd_bg_bank_num
   ,input  [BG_BANK_BITS-1:0]                   ih_te_wr_bg_bank_num
   ,input  [PAGE_BITS-1:0]                      ih_te_rd_page_num
   ,input  [PAGE_BITS-1:0]                      ih_te_wr_page_num
   ,input  [BLK_BITS-1:0]                       ih_te_rd_block_num
   ,input  [BLK_BITS-1:0]                       ih_te_wr_block_num
   ,input  [CMD_LEN_BITS-1:0]                   ih_te_rd_length
   ,input  [WORD_BITS-1:0]                      ih_te_critical_dword

   ,input  [OTHER_RD_ENTRY_BITS-1:0]            ih_te_rd_other_fields             // everything else TE needs to track in the read CAM
   ,input  [OTHER_WR_ENTRY_BITS-1:0]            ih_te_wr_other_fields             // everything else TE needs to track in the read CAM
   ,output                                      te_ih_retry
   ,output                                      te_wu_wr_retry
   ,output                                      te_ih_free_rd_entry_valid
   ,output [RD_CAM_ADDR_BITS-1:0]               te_ih_free_rd_entry
   ,input  [1:0]                                wu_te_enable_wr
   ,input  [WR_CAM_ADDR_BITS-1:0]               wu_te_entry_num
   ,input  [PARTIAL_WR_BITS-1:0]                wu_te_wr_word_valid
   ,input  [PARTIAL_WR_BITS_LOG2-1:0]           wu_te_ram_raddr_lsb_first
   ,input  [PW_WORD_CNT_WD_MAX-1:0]             wu_te_pw_num_beats_m1
   ,input  [PW_WORD_CNT_WD_MAX-1:0]             wu_te_pw_num_cols_m1
   ,output [WR_CAM_ADDR_BITS_IE-1:0]            te_mr_wr_ram_addr
   ,output                                      te_yy_wr_combine                  // write from IH being combined with existing entry
   ,output [WR_CAM_ADDR_BITS-1:0]               te_wu_entry_num
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in uPCTL2
   ,input                                       be_te_page_hit
   ,input                                       be_te_wr_page_hit
//spyglass enable_block W240
   ,input                                       be_wr_page_hit
   ,output [BSM_BITS-1:0]                       te_be_bsm_num
   ,output [PAGE_BITS-1:0]                      te_be_page_num
   ,input                                       ts_te_autopre                     // auto-precharge indicator 
   ,input  [BSM_BITS-1:0]                       gs_te_bsm_num4pre
   ,input  [BSM_BITS-1:0]                       gs_te_bsm_num4rdwr
   ,input  [BSM_BITS-1:0]                       gs_te_bsm_num4act
   ,input                                       gs_te_op_is_rd
   ,input                                       gs_te_op_is_wr
   ,input                                       gs_te_op_is_precharge
   ,input                                       gs_te_op_is_activate
   ,input                                       gs_te_wr_mode
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  ,input  logic [CMD_LEN_BITS-1:0]              gs_te_rd_length
  ,input  logic [WORD_BITS-1:0]                 gs_te_rd_word
  ,input  logic [PARTIAL_WR_BITS_LOG2-1:0]      gs_te_raddr_lsb_first
  ,input  logic [PW_WORD_CNT_WD_MAX-1:0]        gs_te_pw_num_beats_m1      
`endif
`endif

   ,input  [WP_BITS-1:0]                        gs_te_wr_possible                 // write MAY be issued this cycle
                                                                                  //  clean off flop; before we know if it WILL be issued this cycle
   ,input                                       gs_te_pri_level
   ,output [TOTAL_BSMS-1:0]                     te_bs_rd_hi
   ,output                                      te_gs_hi_rd_page_hit_vld
   ,output [BSM_BITS-1:0]                       te_os_hi_bsm_hint
   ,output [BSM_BITS-1:0]                       te_os_lo_bsm_hint
   ,output [BSM_BITS-1:0]                       te_os_wr_bsm_hint
   ,output                                      te_gs_block_wr 
   ,input  [RD_CAM_ADDR_BITS-1:0]               reg_ddrc_lpr_num_entries
   ,output [BSM_BITS-1:0]                       te_os_lo_act_bsm_hint
   ,output [BSM_BITS-1:0]                       te_os_wr_act_bsm_hint
   ,output [TOTAL_BSMS-1:0]                     te_bs_rd_page_hit
   ,output [TOTAL_BSMS-1:0]                     te_bs_rd_valid
   ,output [TOTAL_BSMS-1:0]                     te_bs_wr_page_hit
   ,output [TOTAL_BSMS-1:0]                     te_bs_wr_valid
   ,output  [TOTAL_BSMS-1:0]                    te_bs_rd_bank_page_hit
   ,output  [TOTAL_BSMS-1:0]                    te_bs_wr_bank_page_hit
   ,output                                      te_gs_rd_flush
   ,output                                      te_gs_wr_flush
   ,output                                      te_gs_any_rd_pending
   ,output                                      te_gs_any_wr_pending
   //,output [`MEMC_RD_ENTRY_ADDR]               te_pi_rd_addr
   ,output  [BLK_BITS-1:0]                      te_pi_rd_addr_blk                 // was part of te_pi_rd_addr
   ,output  [OTHER_RD_ENTRY_BITS-1:0]           te_pi_rd_other_fields_rd
   ,output  [BLK_BITS-1:0]                      te_pi_wr_addr_blk                 // was part of te_pi_wr_addr
   ,output  [OTHER_WR_ENTRY_BITS-1:0]           te_pi_wr_other_fields_wr          // everything else we need to keep track of in the CAM - writes

   ,output  [PARTIAL_WR_BITS-1:0]               te_pi_wr_word_valid
   ,output [TOTAL_BSMS*RD_CAM_ADDR_BITS-1:0]    te_os_rd_entry_table             // All Read entry numbers in TE next table 
   ,output [TOTAL_BSMS*WR_CAM_ADDR_BITS_IE-1:0] te_os_wr_entry_table             // All write entry numbers in TE next table
   ,output [TOTAL_BSMS*PAGE_BITS-1:0]           te_os_rd_page_table              // All read page numbers in TE next table
   ,output [TOTAL_BSMS*PAGE_BITS-1:0]           te_os_wr_page_table              // All read page numbers in TE next table   
   ,output [TOTAL_BSMS*AUTOPRE_BITS-1:0]        te_os_rd_cmd_autopre_table
   ,output [TOTAL_BSMS*AUTOPRE_BITS-1:0]        te_os_wr_cmd_autopre_table       
   ,output [TOTAL_BSMS*CMD_LEN_BITS-1:0]        te_os_rd_length_table             // All Read Length Field in TE Next Table
   ,output [TOTAL_BSMS*WORD_BITS-1:0]           te_os_rd_critical_word_table      // All Read Critical Word in TE Next Table
//    `ifdef DDRCTL_DDR_OR_MEMC_LPDDR4
   ,output [TOTAL_BSMS-1:0]                     te_os_rd_pageclose_autopre
//    `endif
   ,output [TOTAL_BSMS-1:0]                     te_os_wr_pageclose_autopre
   ,output [TOTAL_BSMS*PARTIAL_WR_BITS_LOG2-1:0]  te_os_wr_mr_ram_raddr_lsb_first_table
   ,output [TOTAL_BSMS*PW_WORD_CNT_WD_MAX-1:0]    te_os_wr_mr_pw_num_beats_m1_table
   ,input  [MAX_CAM_ADDR_BITS-1:0]              os_te_rdwr_entry                 // CAM entry # for read write replacement from selection n/w
//    ,input  [AUTOPRE_BITS-1:0]                   ts_rdwr_cmd_autopre
   ,input [PAGE_BITS-1:0]                       ts_act_page                      // Activate page  
   ,input   [MWR_BITS-1:0]                      wu_te_mwr                        // Masked write information
   ,output  [TOTAL_BSMS-1:0]                    te_os_mwr_table                  // Masked write entry in CAM, over entire banks
   ,output  [TOTAL_BSMS-1:0]                    te_b3_bit                        // burst bit(column bit)[3] in TE next table
   ,output [TOTAL_LRANKS-1:0]                   te_gs_rank_wr_pending            // WR command pending in the CAM per rank
   ,output [TOTAL_LRANKS-1:0]                   te_gs_rank_rd_pending            // RD command pending in the CAM per rank
   ,output [TOTAL_BANKS-1:0]                    te_gs_bank_wr_pending            // WR command pending in the CAM per rank/bank
   ,output [TOTAL_BANKS-1:0]                    te_gs_bank_rd_pending            // RD command pending in the CAM per rank/bank
   `ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS
   ,input                                       wu_ih_flow_cntrl_req
   `endif // SYNTHESIS
   `endif // SNPS_ASSERT_ON
   ,input  [2:0]                                        reg_ddrc_page_hit_limit_rd
   ,input  [2:0]                                        reg_ddrc_page_hit_limit_wr
   ,input                                               reg_ddrc_opt_hit_gt_hpr
   ,input  [TOTAL_BSMS-1:0]                             ts_te_sel_act_wr         //tell TE the activate command is for write or read.
   ,output [TOTAL_BSMS-1:0]                             te_rws_wr_col_bank                     // entry of colliding bank (1bit for 1bank)
   ,output [TOTAL_BSMS-1:0]                             te_rws_rd_col_bank                     // entry of colliding bank (1bit for 1bank)
   ,output [WR_CAM_ADDR_BITS_IE:0]                      te_num_wr_pghit_entries
   ,output [RD_CAM_ADDR_BITS:0]                         te_num_rd_pghit_entries
   ,output reg [WR_CAM_ADDR_BITS:0]                     te_wr_entry_avail         // Number of non-valid entries (WRCAM only, not include WRECC CAM)
   `ifndef SYNTHESIS
   `ifdef SNPS_ASSERT_ON
   ,output [WR_CAM_ENTRIES_IE-1:0]                      te_wr_entry_valid         // valid write entry in CAM, over entire CAM
   ,output [RD_CAM_ENTRIES-1:0]                         te_rd_entry_valid         // valid write entry in CAM, over entire CAM
   ,output [WR_CAM_ENTRIES_IE-1:0]                      te_wr_page_hit_entries    // valid page-hit entry in CAM
   ,output [RD_CAM_ENTRIES-1:0]                         te_rd_page_hit
   ,input [1:0]                                         reg_ddrc_data_bus_width
   `endif // SNPS_ASSERT_ON
   `endif // SYNTHESIS
   ,input                                               reg_ddrc_lpddr4
   );

//---------------------------------- WIRES -------------------------------------
wire [RD_CAM_ENTRIES*RANKBANK_BITS-1:0]       te_rd_entry_rankbank;      // rankbank addresses of all CAM entries
wire [WR_CAM_ENTRIES_IE*RANKBANK_BITS-1:0]    te_wr_entry_rankbank;      // rankbank addresses of all CAM entries

wire [RD_CAM_ENTRIES*BSM_BITS-1:0]            te_rd_entry_bsm_num;       // bsm number addresses of all CAM entries
wire [WR_CAM_ENTRIES_IE*BSM_BITS-1:0]         te_wr_entry_bsm_num;       // bsm number of all CAM entries

wire [RD_CAM_ADDR_BITS-1:0]                   te_hi_rd_prefer;
wire [RD_CAM_ADDR_BITS-1:0]                   te_lo_rd_prefer;
wire [WR_CAM_ADDR_BITS_IE-1:0]                te_wr_prefer;
wire [PW_WORD_CNT_WD_MAX-1:0]                 te_sel_pw_num_cols_m1;     // partial write of selected CAM entry
wire [WR_CAM_ENTRIES_IE*PW_WORD_CNT_WD_MAX -1:0] te_pw_num_cols_m1_table;   // partial write of all CAM entries
// wire                                          te_pi_rd_autopre;
// wire                                          te_wr_autopre;
wire [RD_CAM_ENTRIES -1:0]                    te_rd_bank_hit;            // valid read entry matching bank from CAM search
wire [RD_CAM_ENTRIES -1:0]                    te_rd_bank_hit_filtred;    // valid read entry matching bank from CAM search excluding entries already in NTT
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_bank_hit;            // valid write entry matching bank from CAM search
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_bank_hit_filtred;    // valid write entry matching bank from CAM search excluding entries already in NTT 
`ifdef SYNTHESIS
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_entry_valid;         // valid write entry in CAM, over entire CAM
wire [RD_CAM_ENTRIES -1:0]                    te_rd_entry_valid;         // valid read entry in CAM, over entire CAM
`elsif SNPS_ASSERT_ON
`else
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_entry_valid;         // valid write entry in CAM, over entire CAM
wire [RD_CAM_ENTRIES -1:0]                    te_rd_entry_valid;         // valid read entry in CAM, over entire CAM
`endif
wire [RD_CAM_ENTRIES -1:0]                    te_rd_entry_loaded;        // loaded read entry in CAM, over entire CAM
wire [RD_CAM_ENTRIES*PAGE_BITS-1:0]           te_rd_page_table;          // page addresses of all CAM entries
wire [WR_CAM_ENTRIES_IE*PAGE_BITS-1:0]        te_wr_page_table;          // page addresses of all CAM entries
wire [RD_CAM_ENTRIES*AUTOPRE_BITS-1:0]        te_rd_cmd_autopre_table ;  // cmd_autopre  of all CAM entries   
wire [WR_CAM_ENTRIES_IE*AUTOPRE_BITS-1:0]     te_wr_cmd_autopre_table ;  // cmd_autopre  of all CAM entries
wire [RD_CAM_ENTRIES*CMD_LEN_BITS-1:0]        te_rd_cmd_length_table;  // read tag, anything else required - during reads
wire [RD_CAM_ENTRIES*WORD_BITS-1:0]           te_rd_critical_word_table;  // read tag, anything else required - during reads

wire [WR_CAM_ENTRIES_IE*MWR_BITS -1:0]        te_mwr_table;              // masked write of all CAM entries
wire [WR_CAM_ENTRIES_IE*PARTIAL_WR_BITS_LOG2-1:0] te_wr_mr_ram_raddr_lsb_first_table;
wire [WR_CAM_ENTRIES_IE*PW_WORD_CNT_WD_MAX-1:0]   te_wr_mr_pw_num_beats_m1_table;
`ifdef SYNTHESIS
wire [RD_CAM_ENTRIES -1:0]                    te_rd_page_hit;
`elsif SNPS_ASSERT_ON
`else
wire [RD_CAM_ENTRIES -1:0]                    te_rd_page_hit;
`endif // SYNTHESIS
wire                                          te_sel_rd_valid;
wire                                          te_sel_wr_valid;
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_page_hit;
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_cam_page_hit;
wire [RD_CAM_ENTRIES -1:0]                    te_rd_page_hit_filtred;    //considered page-hit limiter 
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_page_hit_filtred;    //considered page-hit limiter
wire [RD_CAM_ENTRIES -1:0]                    te_rd_entry_pri;
wire                                          te_rd_flush;
wire                                          te_wr_flush;
wire                                          te_rd_flush_due_rd;
wire                                          te_rd_flush_due_wr;
wire                                          te_wr_nxt_wr_combine;
wire                                          te_wr_flush_due_rd;
wire                                          te_wr_flush_due_wr;
wire                                          te_rd_flush_started;     // read flush started (clean off flop)
wire                                          te_wr_flush_started;     // write flush started (clean off flop)
wire [RD_CAM_ADDR_BITS -1:0]                  te_rd_col_entry;         // flopped version of collided entry number
wire [WR_CAM_ADDR_BITS_IE -1:0]               te_wr_col_entry;         // flopped version of collided entry number
wire [TOTAL_BSMS  -1:0]                       te_wr_col_bank;          // flopped version of collided entry number
wire [RD_CAM_ADDR_BITS-1:0]                   te_sel_rd_entry;
wire [WR_CAM_ADDR_BITS_IE-1:0]                te_sel_wr_entry;
wire [PAGE_BITS-1:0]                          te_sel_wr_page;           // Row address of selected CAM entry
wire [PAGE_BITS-1:0]                          te_sel_rd_page;           // Row address of selected CAM entry
wire [AUTOPRE_BITS-1:0]                       te_sel_wr_cmd_autopre;    // cmd_autopre of selected CAM entry
wire [AUTOPRE_BITS-1:0]                       te_sel_rd_cmd_autopre;    // cmd_autopre of selected CAM entry
wire [CMD_LEN_BITS-1:0]                       te_sel_rd_length;          // Read Other fields of selected CAM entry
wire [WORD_BITS-1:0]                          te_sel_rd_critical_word;   // Read Other fields of selected CAM entry
wire [MWR_BITS-1:0]                           te_sel_mwr;               // masked write of selected CAM entry
wire [PARTIAL_WR_BITS_LOG2-1:0]               te_sel_wr_mr_ram_raddr_lsb;
wire [PW_WORD_CNT_WD_MAX-1:0]                 te_sel_wr_mr_pw_num_beats_m1;      
wire                                          te_rdwr_autopre;         // indicates a read or write from GS w/ auto-precharge
wire [TOTAL_BSMS-1:0]                         te_wr_pghit_vld;         // one or more valid write page hits
wire                                          rd_pghit_vld_unused;      // unused next table output
wire                                          i_load_ntt;

wire [WR_CAM_ENTRIES_IE-1:0]                  wr_nxt_entry_in_ntt;     // vector indicating entries in NTT
wire [RD_CAM_ENTRIES-1:0]                     rd_nxt_entry_in_ntt;     // vector indicating entries in NTT


wire                                          te_wr_collision_vld_due_rd;
wire                                          te_wr_collision_vld_due_wr;
`ifdef SYNTHESIS
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_page_hit_entries;
`elsif SNPS_ASSERT_ON
`else
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_page_hit_entries;
`endif // SNPS_ASSERT_ON

`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
  wire [CMD_LEN_BITS-1:0]                       te_pi_rd_length_int;
  wire [WORD_BITS-1:0]                          te_pi_rd_word_int;
      wire  [PARTIAL_WR_BITS_LOG2-1:0]          te_mr_ram_raddr_lsb_first_int;
      wire  [PW_WORD_CNT_WD_MAX-1:0]            te_mr_pw_num_beats_m1_int;
  `endif //SYNTHESIS
`endif //SNPS_ASSERT_ON
`ifdef SNPS_ASSERT_ON
`endif // SNPS_ASSERT_ON
// rd_nxt_entry_in_ntt in masking te_wr_bank_hit depending on command inside rd cam to avoid filtering it for ACT
// don't need consider bm_te_rd_bank_hit_mask (entry is allocated or not) because te_rd_bank_hit_filtred
// is used for normal replace that is based on a read is scheduled from this bank.
assign te_rd_bank_hit_filtred = te_rd_bank_hit // te_rd_bank_hit is already filtered 
////   `ifdef  UMCTL2_DYN_BSM
////     & (~bm_te_rd_bank_hit_mask)
////   `endif // UMCTL2_DYN_BSM
   ;
// wr_nxt_entry_in_ntt in masking te_wr_bank_hit inside wr cam to avoid filtering write combine valid
// don't need consider bm_te_wr_bank_hit_mask (entry is allocated or not) because te_wr_bank_hit_filtred
// is used for normal replace that is based on a write/combine is scheduled from this bank.
assign te_wr_bank_hit_filtred = te_wr_bank_hit
////   `ifdef  UMCTL2_DYN_BSM
////     & (~bm_te_wr_bank_hit_mask)
////   `endif // UMCTL2_DYN_BSM
   ;

wire [TOTAL_BSMS-1:0]                         te_dh_rd_bsm_valid;
wire [TOTAL_BSMS-1:0]                         te_dh_rd_bsm_page_hit;
wire [TOTAL_BSMS-1:0]                         te_dh_wr_bsm_valid;
wire [TOTAL_BSMS-1:0]                         te_dh_wr_bsm_page_hit;

wire                                          ih_te_rd_autopre_i;
// When reg_ddrc_autopre_rmw==1, AP is not applied to read part of RMW 
assign ih_te_rd_autopre_i = (reg_ddrc_autopre_rmw & ih_te_rd_rmw)? 1'b0 :ih_te_rd_autopre;


wire [RD_CAM_ADDR_BITS-1:0]                   i_ih_te_lo_rd_prefer;
wire [RD_CAM_ADDR_BITS-1:0]                   i_ih_te_hi_rd_prefer;
wire [BSM_BITS-1:0]                           te_bypass_rank_bg_bank_num;
wire [WR_CAM_ADDR_BITS-1:0]                   i_ih_te_wr_prefer;



  





//----------------------------------------------
// Interface for replace logic triggered by PRE
//----------------------------------------------

wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_bank_hit_pre;        // valid write entry matching bank from CAM search excluding entries already in NTT 
wire [RD_CAM_ENTRIES -1:0]                    te_rd_bank_hit_pre;        // valid write entry matching bank from CAM search excluding entries already in NTT 
wire [RD_CAM_ADDR_BITS-1:0]                   te_sel_rd_entry_pre;
wire [WR_CAM_ADDR_BITS_IE-1:0]                te_sel_wr_entry_pre;
wire [PAGE_BITS-1:0]                          te_sel_wr_page_pre;           // Row address of selected CAM entry
wire [PAGE_BITS-1:0]                          te_sel_rd_page_pre;           // Row address of selected CAM entry
wire [AUTOPRE_BITS-1:0]                       te_sel_wr_cmd_autopre_pre;    // cmd_autopre of selected CAM entry
wire [AUTOPRE_BITS-1:0]                       te_sel_rd_cmd_autopre_pre;    // cmd_autopre of selected CAM entry
wire [CMD_LEN_BITS-1:0]                       te_sel_rd_cmd_length_pre;   // Other Fields of selected CAM entry
wire [WORD_BITS-1:0]                          te_sel_rd_critical_word_pre;   // Other Fields of selected CAM entry
wire [MWR_BITS-1:0]                           te_sel_mwr_pre;               // masked write of selected CAM entry
wire                                          te_sel_rd_valid_pre_unused;
wire                                          te_sel_wr_valid_pre_unused;
wire [PW_WORD_CNT_WD_MAX-1:0]                 te_sel_pw_num_cols_m1_pre;     // partial write of selected CAM entry
wire [PARTIAL_WR_BITS_LOG2-1:0]               te_sel_wr_mr_ram_raddr_lsb_pre;         // ram addr of selected CAM entry
wire [PW_WORD_CNT_WD_MAX-1:0]                 te_sel_wr_mr_pw_num_beats_m1_pre;         // num beats of selected CAM entry
wire [WR_CAM_ADDR_BITS_IE-1:0]                te_wr_prefer_pre_unused;
wire [RD_CAM_ADDR_BITS-1:0]                   te_lo_rd_prefer_pre_unused;
wire [RD_CAM_ADDR_BITS-1:0]                   te_hi_rd_prefer_pre_unused;
wire [PW_WORD_CNT_WD_MAX-1:0]                 te_sel_pw_num_cols_m1_pre_unused;     // partial write of selected CAM entry



//---------------------------------------------
// Localparam for hmatrix
//---------------------------------------------
// For Enhanced CAM pointer feature
// Number of comparator sets for each hmatrix
localparam RD_NUM_COMPS    = 1 + 1 ; 
localparam WR_NUM_COMPS    = 1 + 1 ; 

//---------------------------------------
// Interface between replace and hmatrix
//---------------------------------------
wire [RD_CAM_ENTRIES*RD_NUM_COMPS-1:0]        hmx_rd_masks;
wire [RD_CAM_ENTRIES*RD_NUM_COMPS-1:0]        hmx_rd_oldest_ohs;

wire [WR_CAM_ENTRIES*WR_NUM_COMPS-1:0]        hmx_wr_masks;
wire [WR_CAM_ENTRIES*WR_NUM_COMPS-1:0]        hmx_wr_oldest_ohs;

wire [RD_CAM_ENTRIES-1:0]                     hmx_rd_mask;
wire [WR_CAM_ENTRIES-1:0]                     hmx_wr_mask;
wire [WR_CAM_ENTRIES-1:0]                     hmx_rd_oldest_oh;
wire [WR_CAM_ENTRIES-1:0]                     hmx_wr_oldest_oh;
wire [RD_CAM_ENTRIES-1:0]                     hmx_rd_pre_mask;
wire [WR_CAM_ENTRIES-1:0]                     hmx_wr_pre_mask;
wire [RD_CAM_ENTRIES-1:0]                     hmx_rd_pre_oldest_oh;
wire [WR_CAM_ENTRIES-1:0]                     hmx_wr_pre_oldest_oh;





//----------
// CAM push      
//----------
wire                                          push_rd_cam;     // Push an entry into RDCAM(LPR or HPR)
wire                                          push_lpr_cam;    // Push an entry into LPR CAM
wire                                          push_hpr_cam;    // Push an entry into HPR CAM
wire                                          push_wr_cam;     // Push an entry into WR CAM

wire                                          pop_rd_cam;      // Pop an entry into RDCAM(LPR or HPR)
wire                                          pop_lpr_cam;     // Pop an entry into LPR CAM
wire                                          pop_hpr_cam;     // Pop an entry into HPR CAM
wire                                          pop_wr_cam;      // Pop an entry into WR CAM

// Page-hit Limiter
wire [WR_CAM_ENTRIES_IE -1:0]                 te_wr_entry_critical_early;
wire [TOTAL_BSMS -1:0]                        te_wr_entry_critical_per_bsm;
wire [RD_CAM_ENTRIES -1:0]                    te_rd_entry_critical_early;
wire [TOTAL_BSMS -1:0]                        te_rd_entry_critical_per_bsm;



//----------------------------
// Mask assignment for hmatrix
//----------------------------
assign hmx_rd_masks = 
    {
       hmx_rd_pre_mask,
       hmx_rd_mask
    };

assign hmx_wr_masks = 
    {
       hmx_wr_pre_mask,
       hmx_wr_mask
    };


wire [RD_CAM_ENTRIES*RD_NUM_COMPS-1:0]        hmx_rd_oldest_ohs_w;
wire [WR_CAM_ENTRIES*WR_NUM_COMPS-1:0]        hmx_wr_oldest_ohs_w;
assign hmx_rd_oldest_ohs_w = hmx_rd_oldest_ohs;
assign hmx_wr_oldest_ohs_w = hmx_wr_oldest_ohs;


assign 
    {
       hmx_rd_pre_oldest_oh,
       hmx_rd_oldest_oh
    } 
    = hmx_rd_oldest_ohs_w;

assign
    {
       hmx_wr_pre_oldest_oh,
       hmx_wr_oldest_oh
    }  
    = hmx_wr_oldest_ohs_w;




wire                                          te_ih_rd_retry_int;
wire                                          te_ih_wr_retry_int;

assign te_rd_page_hit_filtred = te_rd_page_hit & (~te_rd_entry_critical_early) ;
assign te_wr_page_hit_filtred = te_wr_page_hit & (~te_wr_entry_critical_early) ;





wire                                          ih_te_rd_link_to_write;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read - ih_te_rd_link_to_write
//SJ: Signal gets different values depending on config. Used only for uMCTL2. Decided to keep current implementation.
// te_ih_rd_retry_int/te_ih_wr_retry_int used by subblocks in 
// tengine, but use same retry signal
assign te_ih_rd_retry_int = te_ih_retry;
assign te_ih_wr_retry_int = te_ih_retry;

// for ih_te_rd_valid only high at same time as ih_te_wr_valid for RMW 
assign ih_te_rd_link_to_write = ih_te_rd_valid;
//spyglass enable_block W528

wire [TOTAL_BSMS*PAGE_BITS -1:0]              rd_nxt_page_table;       // rd NTT next xact page for each rank/bank
wire [TOTAL_BSMS*PAGE_BITS -1:0]              wr_nxt_page_table;       // wr NTT next xact page for each rank/bank

wire [TOTAL_BSMS*AUTOPRE_BITS-1:0]            rd_nxt_cmd_autopre_table;
wire [TOTAL_BSMS*AUTOPRE_BITS-1:0]            wr_nxt_cmd_autopre_table;

wire [TOTAL_BSMS*CMD_LEN_BITS-1:0]            rd_nxt_length_table;
wire [TOTAL_BSMS*WORD_BITS-1:0]               rd_nxt_word_table;
wire [TOTAL_BSMS*PARTIAL_WR_BITS_LOG2-1:0]    wr_nxt_mr_ram_raddr_lsb_first_table;
wire [TOTAL_BSMS*PW_WORD_CNT_WD_MAX-1:0]      wr_nxt_mr_pw_num_beats_m1_table;
 
assign te_os_rd_page_table = rd_nxt_page_table;                       // All read page numbers in TE next table
assign te_os_wr_page_table = wr_nxt_page_table;                       // All write page numbers in TE next table   

assign te_os_wr_cmd_autopre_table = wr_nxt_cmd_autopre_table;
assign te_os_rd_cmd_autopre_table = rd_nxt_cmd_autopre_table;


assign te_os_rd_length_table        = rd_nxt_length_table;
assign te_os_rd_critical_word_table = rd_nxt_word_table;


assign te_os_wr_mr_ram_raddr_lsb_first_table = wr_nxt_mr_ram_raddr_lsb_first_table;
assign te_os_wr_mr_pw_num_beats_m1_table     = wr_nxt_mr_pw_num_beats_m1_table;

 
wire                                          be_op_is_activate_bypass;

   assign be_op_is_activate_bypass= 1'b0;   

//localparam IE_UNIQ_BLK_BITS  = (`MEMC_INLINE_ECC_EN==0)? 0 : (`MEMC_BURST_LENGTH==16)? 5 : 4; 
//Can be reduced: need to 3 highest columun bits number.
localparam IE_UNIQ_BLK_BITS  = (`MEMC_INLINE_ECC_EN==0)? 0 : BLK_BITS; 
localparam IE_UNIQ_BLK_LSB   = 0;
localparam IE_UNIQ_CID_BITS  = (`MEMC_BURST_LENGTH==16)? `UMCTL2_CID_WIDTH : 0;
localparam IE_UNIQ_RBK_BITS  = (`MEMC_INLINE_ECC_EN==0)? 0 : BG_BANK_BITS+IE_UNIQ_CID_BITS;


wire                        te_entry_valid_clr_by_wc; // Only apply for [WR_CAM_ENTRIES-1:0]

always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    te_wr_entry_avail <= {1'b1,{WR_CAM_ADDR_BITS{1'b0}}};
  end
  else begin
    // te_wr_entry_avail calculation
    if (i_load_ntt & ~(te_entry_valid_clr_by_wc | (gs_te_op_is_wr ))) begin
      te_wr_entry_avail <= te_wr_entry_avail - 1'b1;
    end
    else if (~i_load_ntt & (te_entry_valid_clr_by_wc | (gs_te_op_is_wr ))) begin
      te_wr_entry_avail <= te_wr_entry_avail + 1'b1;
    end
    // te_wrecc_entry_avail calculation
  end
end

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
wire [WR_CAM_ENTRIES_IE-1:0]          i_wr_entry_we_bw_loaded;
`endif
`endif


// Max rank wr/rd logic

// TODO: temporary assignment
// burst bit(column bit)[3] in TE next table
assign te_b3_bit = {TOTAL_BSMS{1'b0}};

//------------------------------- INSTANTIATIONS -------------------------------
  te_rd_cam
   #(
    .RD_CAM_ADDR_BITS       (RD_CAM_ADDR_BITS), 
    .RANK_BITS              (LRANK_BITS), 
    .BG_BITS                (BG_BITS), 
    .BANK_BITS              (BANK_BITS), 
    .BG_BANK_BITS           (BG_BANK_BITS), 
    .PAGE_BITS              (PAGE_BITS), 
    .BLK_BITS               (BLK_BITS), 
    .BSM_BITS               (BSM_BITS), 
    .OTHER_RD_RMW_LSB       (OTHER_RD_RMW_LSB), 
    .OTHER_RD_RMW_TYPE_BITS (OTHER_RD_RMW_TYPE_BITS),
    .WORD_BITS              (WORD_BITS),
    .CMD_LEN_BITS           (CMD_LEN_BITS),
    .OTHER_RD_ENTRY_BITS    (OTHER_RD_ENTRY_BITS),
    .BT_BITS                (BT_BITS),
    .NO_OF_BT               (NO_OF_BT),
    .IE_WR_TYPE_BITS        (IE_WR_TYPE_BITS),
    .IE_RD_TYPE_BITS        (IE_RD_TYPE_BITS),
    .IE_BURST_NUM_BITS      (IE_BURST_NUM_BITS),
    .IE_TAG_BITS            (IE_TAG_BITS),
    .IE_UNIQ_BLK_BITS       (IE_UNIQ_BLK_BITS),
    .IE_UNIQ_BLK_LSB        (IE_UNIQ_BLK_LSB),
    .IE_MASKED_BITS         (IE_MASKED_BITS),
    .ENTRY_AUTOPRE_BITS     (AUTOPRE_BITS),
    .ECCAP_BITS             (ECCAP_BITS),
    .DDR4_COL3_BITS         (DDR4_COL3_BITS),
    .RETRY_RD_BITS          (RETRY_RD_BITS),
    .RETRY_TIMES_WIDTH      (RETRY_TIMES_WIDTH),
    .CRC_RETRY_TIMES_WIDTH  (0),
    .UE_RETRY_TIMES_WIDTH   (0),
    .RD_CRC_RETRY_LIMIT_REACH_BITS (0),
    .RD_UE_RETRY_LIMIT_REACH_BITS (0),
    .RMW_BITS               (RMW_BITS)
  )
  RDcam (
              .core_ddrc_rstn            (core_ddrc_rstn) 
             ,.dh_te_pageclose           (dh_te_pageclose) 
             ,.dh_te_pageclose_timer     (dh_te_pageclose_timer) 
             ,.co_te_clk                 (co_te_clk)
             ,.ddrc_cg_en                (ddrc_cg_en) 
             ,.i_rd_command              (ih_te_rd_valid) 
             ,.i_wr_command              (ih_te_wr_valid) 
             ,.ih_te_rd_bg_bank_num      (ih_te_rd_bg_bank_num [BG_BANK_BITS-1:0]) 
             ,.ih_te_rd_page_num         (ih_te_rd_page_num [PAGE_BITS-1:0]) 
             ,.ih_te_rd_block_num        (ih_te_rd_block_num [BLK_BITS-1:0]) 
             ,.ih_te_rd_autopre          (ih_te_rd_autopre_i) 
             ,.ih_te_rmw                 (ih_te_rd_rmw) 
             ,.rd_nxt_entry_in_ntt       (rd_nxt_entry_in_ntt)
             ,.gs_te_wr_mode             (gs_te_wr_mode)
             ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
`endif
`endif
             ,.ts_bsm_num4pre            (gs_te_bsm_num4pre [BSM_BITS-1:0]) 
             ,.ts_bsm_num4act            (gs_te_bsm_num4act [BSM_BITS-1:0]) 
             ,.te_rdwr_autopre           (te_rdwr_autopre) 
             ,.ts_op_is_precharge        (gs_te_op_is_precharge) 
             ,.ts_op_is_activate         (gs_te_op_is_activate) 
             ,.be_te_page_hit            (be_te_page_hit)            
             ,.ts_act_page               (ts_act_page) 
             ,.ih_te_rd_length           (ih_te_rd_length)
             ,.ih_te_critical_dword      (ih_te_critical_dword)
             ,.ih_te_rd_other_fields     (ih_te_rd_other_fields[OTHER_RD_ENTRY_BITS-1:0]) 
             ,.ih_te_rd_entry_num        (ih_te_rd_entry_num [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_rd_entry_rankbank      (te_rd_entry_rankbank)
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs but output must always exist
             ,.te_rd_entry_bsm_num       (te_rd_entry_bsm_num) 
//spyglass enable_block W528
             ,.te_lo_rd_prefer           (te_lo_rd_prefer [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_hi_rd_prefer           (te_hi_rd_prefer [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_yy_wr_combine          (te_yy_wr_combine) 
             ,.te_ih_rd_retry            (te_ih_rd_retry_int)   
             ,.ih_te_hi_pri              (ih_te_rd_hi_pri) 
             ,.te_ts_hi_bsm_hint         (te_os_hi_bsm_hint [BSM_BITS-1:0]) 
             ,.te_ts_lo_bsm_hint         (te_os_lo_bsm_hint [BSM_BITS-1:0]) 
             ,.te_entry_pri              (te_rd_entry_pri [RD_CAM_ENTRIES -1:0]) 
             ,.te_rd_flush               (te_rd_flush) 
             ,.te_rd_flush_due_rd        (te_rd_flush_due_rd) 
             ,.te_rd_flush_due_wr        (te_rd_flush_due_wr) 
             ,.te_rd_flush_started       (te_rd_flush_started) 
             ,.te_rd_col_entry           (te_rd_col_entry)
             ,.be_op_is_activate_bypass  (be_op_is_activate_bypass) 

             ,.te_ts_act_bsm_hint        (te_os_lo_act_bsm_hint [BSM_BITS-1:0]) 
             ,.ts_bsm_num4rdwr           (gs_te_bsm_num4rdwr [BSM_BITS-1:0]) 
             ,.ts_op_is_rd               (gs_te_op_is_rd) 
             ,.te_rd_page_table          (te_rd_page_table) 
             ,.te_rd_cmd_autopre_table   (te_rd_cmd_autopre_table) 
             ,.te_rd_cmd_length_table    (te_rd_cmd_length_table)
             ,.te_rd_critical_word_table (te_rd_critical_word_table)
             ,.te_rd_entry               (os_te_rdwr_entry [RD_CAM_ADDR_BITS -1:0]) 
             ,.te_pi_rd_addr_blk         (te_pi_rd_addr_blk)
             ,.te_pi_rd_other_fields_rd  (te_pi_rd_other_fields_rd) 
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
             ,.te_pi_rd_length_int       (te_pi_rd_length_int)
             ,.te_pi_rd_word_int         (te_pi_rd_word_int) 
`endif
`endif 
//              ,.te_pi_rd_autopre          (te_pi_rd_autopre ) 
// `ifdef DDRCTL_DDR_OR_MEMC_LPDDR4
             ,.te_os_rd_pageclose_autopre(te_os_rd_pageclose_autopre)
// `endif
             ,.te_bank_hit               (te_rd_bank_hit [RD_CAM_ENTRIES -1:0]) 
             ,.te_bank_hit_pre           (te_rd_bank_hit_pre [RD_CAM_ENTRIES -1:0]) 
             ,.te_page_hit               (te_rd_page_hit [RD_CAM_ENTRIES -1:0]) 
             ,.te_entry_valid            (te_rd_entry_valid [RD_CAM_ENTRIES -1:0]) 
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs and in te_assertions module
             ,.te_entry_loaded           (te_rd_entry_loaded [RD_CAM_ENTRIES -1:0]) 
//spyglass enable_block W528
//              ,.ts_rdwr_cmd_autopre       (ts_rdwr_cmd_autopre)           
             ,.te_entry_critical_per_bsm (te_rd_entry_critical_per_bsm)
             ,.te_entry_critical_early   (te_rd_entry_critical_early)
             ,.reg_ddrc_page_hit_limit_rd(reg_ddrc_page_hit_limit_rd)
`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
  `endif
`endif
             ,.ts_te_sel_act_wr           (ts_te_sel_act_wr)
            );


  te_rd_replace
   #( .RD_CAM_ADDR_BITS    (RD_CAM_ADDR_BITS), 
                   .WORD_BITS           (WORD_BITS),
                   .CMD_LEN_BITS        (CMD_LEN_BITS),
                   .AUTOPRE_BITS        (AUTOPRE_BITS),
                   .IE_TAG_BITS         (IE_TAG_BITS)
                 )
          RDreplace (
              .co_te_clk                 (co_te_clk) 
             ,.core_ddrc_rstn            (core_ddrc_rstn) 
             ,.ih_te_lo_rd_prefer        (i_ih_te_lo_rd_prefer) 
             ,.te_rd_page_table          (te_rd_page_table) 
             ,.te_rd_cmd_autopre_table   (te_rd_cmd_autopre_table)  
             ,.te_rd_cmd_length_table    (te_rd_cmd_length_table)
             ,.te_rd_critical_word_table (te_rd_critical_word_table)
             ,.te_rd_bank_hit           (te_rd_bank_hit_filtred[RD_CAM_ENTRIES-1:0]) 
             ,.ddrc_cg_en               (ddrc_cg_en)
             ,.te_lo_rd_prefer          (te_lo_rd_prefer [RD_CAM_ADDR_BITS-1:0]) 
             ,.ih_te_hi_rd_prefer       (i_ih_te_hi_rd_prefer) 
             ,.te_rd_entry_pri          (te_rd_entry_pri [RD_CAM_ENTRIES -1:0]) 
             ,.te_rd_page_hit           (te_rd_page_hit_filtred [RD_CAM_ENTRIES-1:0]) 
             ,.te_rd_flush_started      (te_rd_flush_started) 
             ,.te_rd_col_entry          (te_rd_col_entry) 
             ,.gs_te_pri_level          (gs_te_pri_level) 
             ,.te_hi_rd_prefer          (te_hi_rd_prefer [RD_CAM_ADDR_BITS-1:0]) 
             ,.hmx_mask                 (hmx_rd_mask)
             ,.hmx_oldest_oh            (hmx_rd_oldest_oh)
             ,.reg_ddrc_opt_hit_gt_hpr  (reg_ddrc_opt_hit_gt_hpr)
             ,.te_sel_rd_entry          (te_sel_rd_entry [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_sel_rd_page           (te_sel_rd_page)        
             ,.te_sel_rd_valid          (te_sel_rd_valid)
             ,.te_sel_rd_length         (te_sel_rd_length)
             ,.te_sel_rd_critical_word  (te_sel_rd_critical_word)
             ,.te_sel_rd_cmd_autopre    (te_sel_rd_cmd_autopre)
             );

  te_rd_replace
   #( .RD_CAM_ADDR_BITS    (RD_CAM_ADDR_BITS), 
                   .WORD_BITS           (WORD_BITS),
                   .CMD_LEN_BITS        (CMD_LEN_BITS),
                   .AUTOPRE_BITS        (AUTOPRE_BITS),
                   .IE_TAG_BITS         (IE_TAG_BITS)
                 )
          RDreplace_pre (
              .co_te_clk                (co_te_clk) 
             ,.core_ddrc_rstn           (core_ddrc_rstn) 
             ,.ih_te_lo_rd_prefer       (i_ih_te_lo_rd_prefer) 
             ,.te_rd_page_table         (te_rd_page_table) 
             ,.te_rd_cmd_autopre_table  (te_rd_cmd_autopre_table)  
             ,.te_rd_cmd_length_table   (te_rd_cmd_length_table)
             ,.te_rd_critical_word_table (te_rd_critical_word_table)
             ,.te_rd_bank_hit           (te_rd_bank_hit_pre[RD_CAM_ENTRIES-1:0]) 
             ,.ddrc_cg_en               (1'b1) // PRE can be served out side of traffic
            ,.te_lo_rd_prefer          (te_lo_rd_prefer_pre_unused) 
             ,.ih_te_hi_rd_prefer       (i_ih_te_hi_rd_prefer) 
             ,.te_rd_entry_pri          (te_rd_entry_pri [RD_CAM_ENTRIES -1:0]) 
             ,.te_rd_page_hit           ({RD_CAM_ENTRIES{1'b0}}) 
             ,.te_rd_flush_started      (te_rd_flush_started) 
             ,.te_rd_col_entry          (te_rd_col_entry) 
             ,.gs_te_pri_level          (gs_te_pri_level) 
             ,.te_hi_rd_prefer          (te_hi_rd_prefer_pre_unused) 
             ,.hmx_mask                 (hmx_rd_pre_mask)
             ,.hmx_oldest_oh            (hmx_rd_pre_oldest_oh)
             ,.reg_ddrc_opt_hit_gt_hpr  (reg_ddrc_opt_hit_gt_hpr)
             ,.te_sel_rd_entry          (te_sel_rd_entry_pre [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_sel_rd_page           (te_sel_rd_page_pre)        
             ,.te_sel_rd_length         (te_sel_rd_cmd_length_pre)
             ,.te_sel_rd_critical_word  (te_sel_rd_critical_word_pre)
             ,.te_sel_rd_valid          (te_sel_rd_valid_pre_unused) 
             ,.te_sel_rd_cmd_autopre    (te_sel_rd_cmd_autopre_pre)
             );

  te_rd_nxt
   
  #(.AUTOPRE_BITS        (AUTOPRE_BITS),
    .WORD_BITS           (WORD_BITS),
    .CMD_LEN_BITS        (CMD_LEN_BITS),
    .IE_TAG_BITS         (IE_TAG_BITS) 
   )
  RDnxt (
              .core_ddrc_rstn             (core_ddrc_rstn) 
             ,.co_te_clk                  (co_te_clk) 
             ,.ih_te_rd_valid             (ih_te_rd_valid) 
             ,.te_sel_entry               (te_sel_rd_entry [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_sel_rd_page             (te_sel_rd_page) 
             ,.te_sel_rd_cmd_autopre      (te_sel_rd_cmd_autopre)
             ,.te_sel_rd_length           (te_sel_rd_length)                       
             ,.te_sel_rd_critical_word    (te_sel_rd_critical_word)                       
             ,.te_sel_valid               (te_sel_rd_valid) 
 
             ,.te_page_hit                (te_rd_page_hit [RD_CAM_ENTRIES -1:0]) 
             ,.te_entry_pri               (te_rd_entry_pri [RD_CAM_ENTRIES -1:0]) 
             ,.ih_te_hi_pri               (ih_te_rd_hi_pri)    // hooking up both prority bits to NTT
                                                              // It will be changed to the upper bit only inside NTT
                                                              // this is done to not touch the logic in NTT as the 
                                                              // original design uses 1-bit priority
                                                              // pri=00(LPR) 01(VPR) will be marked as pri=0(LPR) in NTT
                                                              // pri=10(HPR) will be marked as pri=1(HPR) in NTT
                                                              // VPR to HPR conversion can happen only through the CAM
                                                              // Timed-out VPR entries that come in from IH into NTT are
                                                              // blocked in NTT
             ,.te_ih_rd_retry             (te_ih_rd_retry_int)   
             ,.ts_pri_level               (gs_te_pri_level) 
             ,.te_ts_hi_xact              (te_bs_rd_hi [TOTAL_BSMS-1:0]) 
             ,.te_ts_valid                (te_bs_rd_valid [TOTAL_BSMS-1:0]) 
             ,.te_gs_hi_xact_page_hit_vld (te_gs_hi_rd_page_hit_vld) 
             ,.rd_nxt_entry_in_ntt        (rd_nxt_entry_in_ntt)   
             ,.be_te_page_hit             (be_te_page_hit)                     
             ,.ts_act_page                (ts_act_page)
             ,.ih_te_bsm_num              ({
                                         ih_te_rd_bg_bank_num}) 
             ,.ih_te_bsm_alloc            (1'b1)
             ,.ih_te_entry_num            (ih_te_rd_entry_num [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_bs_rd_bank_page_hit     (te_bs_rd_bank_page_hit) 
             ,.te_rd_page_table           (te_rd_page_table) 
             ,.te_rd_cmd_autopre_table    (te_rd_cmd_autopre_table)                 
             ,.te_rd_cmd_length_table     (te_rd_cmd_length_table)
             ,.te_rd_critical_word_table  (te_rd_critical_word_table)
             ,.ts_bsm_num4pre             (gs_te_bsm_num4pre [BSM_BITS-1:0]) 
             ,.ts_bsm_num4act             (gs_te_bsm_num4act [BSM_BITS-1:0]) 
             ,.ts_bsm_num4rdwr            (gs_te_bsm_num4rdwr [BSM_BITS-1:0]) 
             ,.te_rdwr_autopre            (te_rdwr_autopre) 
             ,.ts_op_is_rd                (gs_te_op_is_rd) 
             ,.ts_op_is_precharge         (gs_te_op_is_precharge) 
             ,.ts_op_is_activate          (gs_te_op_is_activate) 
             ,.ts_wr_mode                 (gs_te_wr_mode) 
             ,.te_ts_page_hit             (te_bs_rd_page_hit [TOTAL_BSMS-1:0]) 
             ,.te_dh_valid                (te_dh_rd_bsm_valid) 
             ,.te_dh_page_hit             (te_dh_rd_bsm_page_hit) 
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((TOTAL_BSMS * RD_CAM_ADDR_BITS) - 1)' found in module 'teengine'
//SJ: This coding style is acceptable and there is no plan to change it.
             ,.te_os_rd_entry_table       (te_os_rd_entry_table[TOTAL_BSMS*RD_CAM_ADDR_BITS-1:0]) 
             ,.te_pghit_vld               (rd_pghit_vld_unused) 
             ,.rd_nxt_page_table          (rd_nxt_page_table[TOTAL_BSMS*PAGE_BITS-1:0]) 
             ,.rd_nxt_cmd_autopre_table   (rd_nxt_cmd_autopre_table[TOTAL_BSMS*AUTOPRE_BITS-1:0])           
             ,.rd_nxt_length_table        (rd_nxt_length_table[TOTAL_BSMS*CMD_LEN_BITS-1:0])
             ,.rd_nxt_word_table          (rd_nxt_word_table[TOTAL_BSMS*WORD_BITS-1:0])
//spyglass enable_block SelfDeterminedExpr-ML
             ,.te_sel_entry_pre           (te_sel_rd_entry_pre [RD_CAM_ADDR_BITS-1:0]) 
             ,.te_sel_rd_page_pre         (te_sel_rd_page_pre)        
             ,.te_sel_rd_cmd_autopre_pre  (te_sel_rd_cmd_autopre_pre)
             ,.te_sel_rd_cmd_length_pre    (te_sel_rd_cmd_length_pre)
             ,.te_sel_rd_critical_word_pre (te_sel_rd_critical_word_pre)
             ,.te_entry_critical_per_bsm  (te_rd_entry_critical_per_bsm)
             ,.reg_ddrc_opt_hit_gt_hpr    (reg_ddrc_opt_hit_gt_hpr)
             ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
             ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
             ,.ts_te_sel_act_wr           (ts_te_sel_act_wr)
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
             ,.ts_te_act_page            (ts_act_page) 
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
            );

  te_wr_cam
   #(
    .WR_CAM_ADDR_BITS     (WR_CAM_ADDR_BITS), 
    .WR_CAM_ADDR_BITS_IE  (WR_CAM_ADDR_BITS_IE), 
    .WR_CAM_ENTRIES       (WR_CAM_ENTRIES),
    .WR_ECC_CAM_ENTRIES   (WR_ECC_CAM_ENTRIES),
    .WR_ECC_CAM_ADDR_BITS (WR_ECC_CAM_ADDR_BITS),
    .WR_CAM_ENTRIES_IE    (WR_CAM_ENTRIES_IE),
    .RANK_BITS            (LRANK_BITS), 
    .BG_BITS              (BG_BITS), 
    .BANK_BITS            (BANK_BITS), 
    .BG_BANK_BITS         (BG_BANK_BITS), 
    .PAGE_BITS            (PAGE_BITS), 
    .BLK_BITS             (BLK_BITS), 
    .BSM_BITS             (BSM_BITS), 
    .MWR_BITS             (MWR_BITS), 
    .PARTIAL_WR_BITS      (PARTIAL_WR_BITS), 
    .PARTIAL_WR_BITS_LOG2 (PARTIAL_WR_BITS_LOG2), 
    .PW_WORD_CNT_WD_MAX   (PW_WORD_CNT_WD_MAX), 
    .BT_BITS              (BT_BITS),
    .NO_OF_BT             (NO_OF_BT),
    .IE_WR_TYPE_BITS      (IE_WR_TYPE_BITS),
    .IE_RD_TYPE_BITS      (IE_RD_TYPE_BITS),
    .IE_BURST_NUM_BITS    (IE_BURST_NUM_BITS),
    .IE_TAG_BITS          (IE_TAG_BITS),
    .IE_UNIQ_BLK_BITS     (IE_UNIQ_BLK_BITS),
    .IE_UNIQ_BLK_LSB      (IE_UNIQ_BLK_LSB),
    .ECCAP_BITS           (ECCAP_BITS),
    .RETRY_WR_BITS        (RETRY_WR_BITS),
    .ENTRY_RETRY_TIMES_WIDTH(0),
    .WORD_BITS              (0),
    .DDR4_COL3_BITS       (DDR4_COL3_BITS),
    .ENTRY_AUTOPRE_BITS   (AUTOPRE_BITS), 
    .HI_PRI_BITS          (HI_PRI_BITS),
    .WR_LATENCY_BITS      (WR_LATENCY_BITS),
    .PW_BC_SEL_BITS       (PW_BC_SEL_BITS),
    .WP_BITS              (WP_BITS),
    .OTHER_WR_ENTRY_BITS  (OTHER_WR_ENTRY_BITS))      // unused; can't go lower than 1
  WRcam (
             .core_ddrc_rstn               (core_ddrc_rstn) 
             ,.dh_te_pageclose              (dh_te_pageclose) 
             ,.dh_te_pageclose_timer        (dh_te_pageclose_timer) 
             ,.co_te_clk                    (co_te_clk) 
             ,.ddrc_cg_en                   (ddrc_cg_en)
             ,.ih_te_rd_valid               (ih_te_rd_valid) 
             ,.ih_te_wr_valid               (ih_te_wr_valid) 
             ,.ih_te_wr_bg_bank_num         (ih_te_wr_bg_bank_num) 
             ,.ih_te_wr_page_num            (ih_te_wr_page_num) 
             ,.ih_te_wr_block_num           (ih_te_wr_block_num) 
             ,.ih_te_wr_autopre             (ih_te_wr_autopre) 
             ,.ih_te_rd_bg_bank_num         (ih_te_rd_bg_bank_num) 
             ,.ih_te_rd_page_num            (ih_te_rd_page_num) 
             ,.ih_te_wr_entry_num           (ih_te_wr_entry_num [WR_CAM_ADDR_BITS_IE-1:0]) 
             ,.ih_te_wr_other_fields        (ih_te_wr_other_fields[OTHER_WR_ENTRY_BITS-1:0]) 
             ,.te_wr_prefer                 (te_wr_prefer) 
             ,.ts_bsm_num4pre               (gs_te_bsm_num4pre [BSM_BITS-1:0]) 
             ,.ts_bsm_num4act               (gs_te_bsm_num4act [BSM_BITS-1:0]) 
             ,.te_rdwr_autopre              (te_rdwr_autopre) 
             ,.ts_op_is_precharge           (gs_te_op_is_precharge) 
             ,.ts_op_is_activate            (gs_te_op_is_activate) 
             ,.be_te_page_hit               (be_wr_page_hit)            
             ,.te_wr_entry_rankbank         (te_wr_entry_rankbank)
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs but output must always exist
             ,.te_wr_entry_bsm_num          (te_wr_entry_bsm_num) 
//spyglass enable_block W528
             ,.gs_te_wr_mode                (gs_te_wr_mode)
             ,.reg_ddrc_dis_opt_ntt_by_act  (reg_ddrc_dis_opt_ntt_by_act)
             ,.te_bypass_rank_bg_bank_num   (te_bypass_rank_bg_bank_num)
             ,.ih_te_link_to_write          (ih_te_rd_link_to_write)  // ???_PT
             ,.dh_te_dis_wc                 (dh_te_dis_wc) 
             ,.te_wr_pghit_vld              (te_wr_pghit_vld) 
             ,.te_ih_wr_retry               (te_ih_wr_retry_int) 
             ,.i_enc_entry                  (te_wu_entry_num [WR_CAM_ADDR_BITS-1:0]) 
             ,.wu_te_entry_num              (wu_te_entry_num [WR_CAM_ADDR_BITS-1:0]) 
             ,.te_yy_wr_combine             (te_yy_wr_combine) 
             ,.te_wr_nxt_wr_combine         (te_wr_nxt_wr_combine) 
             ,.te_flush_due_rd              (te_wr_flush_due_rd) 
             ,.te_flush_due_wr              (te_wr_flush_due_wr) 
             ,.te_flush                     (te_wr_flush) 
             ,.te_flush_started             (te_wr_flush_started) 
             ,.te_wr_col_entry              (te_wr_col_entry) 
             ,.te_wr_col_bank               (te_wr_col_bank)
             ,.be_op_is_activate_bypass     (be_op_is_activate_bypass) 
             ,.wu_te_enable_wr              (wu_te_enable_wr [1:0]) 
             ,.wu_te_mwr                    (wu_te_mwr) 
             ,.wu_te_wr_word_valid          (wu_te_wr_word_valid) 
             ,.wu_te_ram_raddr_lsb_first    (wu_te_ram_raddr_lsb_first) 
             ,.wu_te_pw_num_beats_m1        (wu_te_pw_num_beats_m1) 
             ,.wu_te_pw_num_cols_m1         (wu_te_pw_num_cols_m1) 
             ,.i_load_ntt                   (i_load_ntt) 
             ,.ts_op_is_wr                  (gs_te_op_is_wr) 
             ,.ts_bsm_num4rdwr              (gs_te_bsm_num4rdwr [BSM_BITS-1:0]) 
             ,.te_be_bsm_num                (te_be_bsm_num [BSM_BITS-1:0]) 
             ,.te_be_page_num               (te_be_page_num [PAGE_BITS-1:0]) 
             ,.ts_wr_possible               (gs_te_wr_possible) 
             ,.te_gs_block_wr               (te_gs_block_wr) 
             ,.te_ts_wr_bsm_hint            (te_os_wr_bsm_hint [BSM_BITS-1:0]) 
             ,.te_wr_cam_page_hit           (te_wr_cam_page_hit)
             ,.te_ts_wr_act_bsm_hint        (te_os_wr_act_bsm_hint [BSM_BITS-1:0]) 
             ,.te_wr_page_table             (te_wr_page_table) 
             ,.te_wr_cmd_autopre_table      (te_wr_cmd_autopre_table)  
             ,.te_wr_entry                  (os_te_rdwr_entry [WR_CAM_ADDR_BITS_IE -1:0]) 
             ,.te_mr_wr_ram_addr            (te_mr_wr_ram_addr [WR_CAM_ADDR_BITS_IE-1:0]) 
             ,.te_pi_wr_addr_blk            (te_pi_wr_addr_blk) 
             ,.te_pi_wr_other_fields_wr     (te_pi_wr_other_fields_wr)
//             ,.te_wr_autopre                (te_wr_autopre) 
             ,.te_mwr_table                 (te_mwr_table) 
             ,.te_pw_num_cols_m1_table      (te_pw_num_cols_m1_table) 
             ,.te_pi_wr_word_valid          (te_pi_wr_word_valid)   
             ,.te_wr_mr_ram_raddr_lsb_first_table (te_wr_mr_ram_raddr_lsb_first_table)
             ,.te_wr_mr_pw_num_beats_m1_table     (te_wr_mr_pw_num_beats_m1_table)
`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
             ,.te_mr_ram_raddr_lsb_first_int  (te_mr_ram_raddr_lsb_first_int) 
             ,.te_mr_pw_num_beats_m1_int      (te_mr_pw_num_beats_m1_int) 
  `endif //SYNTHESIS
`endif //SNPS_ASSERT_ON
             ,.te_bank_hit                  (te_wr_bank_hit [WR_CAM_ENTRIES_IE-1:0]) 
             ,.te_bank_hit_pre              (te_wr_bank_hit_pre [WR_CAM_ENTRIES_IE-1:0]) 
             ,.te_page_hit                  (te_wr_page_hit [WR_CAM_ENTRIES_IE-1:0]) 
             ,.te_entry_valid               (te_wr_entry_valid  [WR_CAM_ENTRIES_IE-1:0]) 
             ,.ts_act_page                  (ts_act_page) 
//              ,.ts_rdwr_cmd_autopre          (ts_rdwr_cmd_autopre) 
             ,.wr_nxt_entry_in_ntt          (wr_nxt_entry_in_ntt)                   
             ,.te_entry_critical_early      (te_wr_entry_critical_early)
             ,.te_entry_critical_per_bsm    (te_wr_entry_critical_per_bsm)
             ,.reg_ddrc_page_hit_limit_wr   (reg_ddrc_page_hit_limit_wr)
             ,.te_entry_valid_clr_by_wc     (te_entry_valid_clr_by_wc)
             ,.te_page_hit_entries          (te_wr_page_hit_entries [WR_CAM_ENTRIES_IE-1:0]) 
             ,.te_wr_collision_vld_due_rd   (te_wr_collision_vld_due_rd)
             ,.te_wr_collision_vld_due_wr   (te_wr_collision_vld_due_wr)
             ,.ts_te_sel_act_wr             (ts_te_sel_act_wr)
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
             ,.i_entry_we_bw_loaded         (i_wr_entry_we_bw_loaded)
             ,.wu_ih_flow_cntrl_req         (wu_ih_flow_cntrl_req)
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
             ,.te_os_wr_pageclose_autopre  (te_os_wr_pageclose_autopre)
            );



  te_wr_replace
   #(
             .WR_CAM_ADDR_BITS          (WR_CAM_ADDR_BITS),
             .WR_ECC_CAM_ADDR_BITS      (WR_ECC_CAM_ADDR_BITS),
             .WR_CAM_ADDR_BITS_IE       (WR_CAM_ADDR_BITS_IE),
             .WR_CAM_ENTRIES            (WR_CAM_ENTRIES),
             .WR_CAM_ENTRIES_IE         (WR_CAM_ENTRIES_IE),
             .WR_ECC_CAM_ENTRIES        (WR_ECC_CAM_ENTRIES),
             .MWR_BITS                  (MWR_BITS), 
             .PW_WORD_CNT_WD_MAX        (PW_WORD_CNT_WD_MAX), 
             .PARTIAL_WR_BITS_LOG2      (PARTIAL_WR_BITS_LOG2),
             .AUTOPRE_BITS              (AUTOPRE_BITS),
             .IE_TAG_BITS               (IE_TAG_BITS)
              )
         WRreplace (
              .co_te_clk                 (co_te_clk) 
             ,.core_ddrc_rstn            (core_ddrc_rstn) 
             ,.ih_te_wr_prefer           (i_ih_te_wr_prefer) 
             ,.te_wr_entry_valid         (te_wr_bank_hit_filtred[WR_CAM_ENTRIES_IE-1:0]) 
             ,.ddrc_cg_en               (ddrc_cg_en)
             ,.te_wr_page_hit            (te_wr_page_hit_filtred [WR_CAM_ENTRIES_IE-1:0]) 
             ,.te_wr_flush_started       (te_wr_flush_started) 
             ,.te_wr_col_entry           (te_wr_col_entry) 
             ,.te_wr_page_table          (te_wr_page_table) 
             ,.te_wr_cmd_autopre_table   (te_wr_cmd_autopre_table) 
             ,.te_mwr_table              (te_mwr_table) 
             ,.te_pw_num_cols_m1_table   (te_pw_num_cols_m1_table) 
             ,.te_sel_pw_num_cols_m1     (te_sel_pw_num_cols_m1) 
             ,.te_wr_mr_ram_raddr_lsb_first_table (te_wr_mr_ram_raddr_lsb_first_table)
             ,.te_wr_mr_pw_num_beats_m1_table     (te_wr_mr_pw_num_beats_m1_table)
             ,.te_wr_prefer              (te_wr_prefer) 
             ,.te_sel_wr_entry           (te_sel_wr_entry) 
             ,.te_sel_wr_page            (te_sel_wr_page) 
             ,.te_sel_wr_cmd_autopre     (te_sel_wr_cmd_autopre) 
             ,.te_sel_mwr                (te_sel_mwr) 
             ,.te_sel_wr_mr_ram_raddr_lsb (te_sel_wr_mr_ram_raddr_lsb)
             ,.te_sel_wr_mr_pw_num_beats_m1  (te_sel_wr_mr_pw_num_beats_m1)
             ,.te_sel_wr_valid           (te_sel_wr_valid)
             ,.hmx_mask                  (hmx_wr_mask)
             ,.hmx_oldest_oh             (hmx_wr_oldest_oh)
             );

  te_wr_replace
   #(
             .WR_CAM_ADDR_BITS          (WR_CAM_ADDR_BITS),
             .WR_ECC_CAM_ADDR_BITS      (WR_ECC_CAM_ADDR_BITS),
             .WR_CAM_ADDR_BITS_IE       (WR_CAM_ADDR_BITS_IE),
             .WR_CAM_ENTRIES            (WR_CAM_ENTRIES),
             .WR_CAM_ENTRIES_IE         (WR_CAM_ENTRIES_IE),
             .WR_ECC_CAM_ENTRIES        (WR_ECC_CAM_ENTRIES),
             .MWR_BITS                  (MWR_BITS), 
             .PW_WORD_CNT_WD_MAX        (PW_WORD_CNT_WD_MAX), 
             .PARTIAL_WR_BITS_LOG2      (PARTIAL_WR_BITS_LOG2),
             .AUTOPRE_BITS              (AUTOPRE_BITS),
             .IE_TAG_BITS               (IE_TAG_BITS)
              )
         WRreplace_pre (
             .co_te_clk                  (co_te_clk) 
             ,.core_ddrc_rstn            (core_ddrc_rstn) 
             ,.ih_te_wr_prefer           (i_ih_te_wr_prefer) 
             ,.te_wr_entry_valid         (te_wr_bank_hit_pre[WR_CAM_ENTRIES_IE-1:0]) 
             ,.ddrc_cg_en                (1'b1)
             ,.te_wr_page_hit            ({WR_CAM_ENTRIES_IE{1'b0}}) 
             ,.te_wr_flush_started       (te_wr_flush_started) 
             ,.te_wr_col_entry           (te_wr_col_entry) 
             ,.te_wr_page_table          (te_wr_page_table) 
             ,.te_wr_cmd_autopre_table   (te_wr_cmd_autopre_table) 
             ,.te_mwr_table              (te_mwr_table) 
             ,.te_pw_num_cols_m1_table   (te_pw_num_cols_m1_table) 
             ,.te_sel_pw_num_cols_m1     (te_sel_pw_num_cols_m1_pre) 
             ,.te_wr_mr_ram_raddr_lsb_first_table (te_wr_mr_ram_raddr_lsb_first_table)
             ,.te_wr_mr_pw_num_beats_m1_table     (te_wr_mr_pw_num_beats_m1_table)
             ,.te_wr_prefer              (te_wr_prefer_pre_unused) 
             ,.te_sel_wr_entry           (te_sel_wr_entry_pre) 
             ,.te_sel_wr_page            (te_sel_wr_page_pre) 
             ,.te_sel_wr_cmd_autopre     (te_sel_wr_cmd_autopre_pre) 
             ,.te_sel_mwr                (te_sel_mwr_pre) 
             ,.te_sel_wr_mr_ram_raddr_lsb (te_sel_wr_mr_ram_raddr_lsb_pre)
             ,.te_sel_wr_mr_pw_num_beats_m1 (te_sel_wr_mr_pw_num_beats_m1_pre)
             ,.te_sel_wr_valid           (te_sel_wr_valid_pre_unused)
             ,.hmx_mask                  (hmx_wr_pre_mask)
             ,.hmx_oldest_oh             (hmx_wr_pre_oldest_oh)
             );


    te_wr_nxt
    
        #(
            .MWR_BITS                   (MWR_BITS), 
            .PW_WORD_CNT_WD_MAX         (PW_WORD_CNT_WD_MAX),
            .PARTIAL_WR_BITS_LOG2       (PARTIAL_WR_BITS_LOG2),
            .CMD_ENTRY_BITS             (WR_CAM_ADDR_BITS_IE), // Including WR ECC CAM if it's there
            .NUM_CAM_ENTRIES            (WR_CAM_ENTRIES_IE), // Including WR ECC CAM if it's there
            .AUTOPRE_BITS               (AUTOPRE_BITS),
            .IE_TAG_BITS                (IE_TAG_BITS)
        )
    WRnxt (
             .core_ddrc_rstn            (core_ddrc_rstn) 
             ,.co_te_clk                 (co_te_clk) 
             ,.i_wr_enabled              (i_load_ntt) 
             ,.te_sel_entry              (te_sel_wr_entry) 
             ,.te_sel_wr_page            (te_sel_wr_page) 
             ,.te_sel_wr_cmd_autopre     (te_sel_wr_cmd_autopre) 
             ,.te_sel_mwr                (te_sel_mwr) 
             ,.te_sel_wr_mr_ram_raddr_lsb (te_sel_wr_mr_ram_raddr_lsb)
             ,.te_sel_wr_mr_pw_num_beats_m1  (te_sel_wr_mr_pw_num_beats_m1)
             ,.te_sel_pw_num_cols_m1     (te_sel_pw_num_cols_m1) 
             ,.te_pw_num_cols_m1_table     (te_pw_num_cols_m1_table) 
             ,.te_sel_valid              (te_sel_wr_valid) 
             ,.te_page_hit               (te_wr_page_hit) 
             ,.te_wr_cam_page_hit        (te_wr_cam_page_hit)
             ,.i_wr_en_bsm_num           (te_be_bsm_num[BSM_BITS-1:0]) 
             ,.i_wr_en_bsm_alloc         (1'b1)
             ,.ih_te_rd_page_num         (ih_te_rd_page_num)
             ,.be_op_is_activate_bypass  (be_op_is_activate_bypass)
             ,.te_bypass_rank_bg_bank_num(te_bypass_rank_bg_bank_num)  
             ,.i_wr_en_entry_num         ({ wu_te_entry_num [WR_CAM_ADDR_BITS-1:0]}) 
             ,.te_wr_col_bank            (te_wr_col_bank)
             ,.te_gs_block_wr            (te_gs_block_wr)
             ,.te_ih_wr_retry            (te_ih_wr_retry_int) // because new transactions are loaded
              //  when new writes are enabled  and not
              //  when write commands arrive from IH 
              //  there is no need for retry here
             ,.ih_te_bsm_num             ({
                                         ih_te_wr_bg_bank_num}) 
             ,.ih_te_bsm_alloc           (1'b1)
             ,.te_yy_wr_combine          (te_wr_nxt_wr_combine) 
             ,.te_ts_valid               (te_bs_wr_valid [TOTAL_BSMS-1:0]) 
             ,.wr_nxt_entry_in_ntt       (wr_nxt_entry_in_ntt) 
             ,.be_te_page_hit            (be_te_wr_page_hit) 
             ,.ts_act_page               (ts_act_page)
             ,.ts_bsm_num4pre            (gs_te_bsm_num4pre [BSM_BITS-1:0]) 
             ,.ts_bsm_num4act            (gs_te_bsm_num4act [BSM_BITS-1:0]) 
             ,.ts_bsm_num4rdwr           (gs_te_bsm_num4rdwr [BSM_BITS-1:0]) 
             ,.te_rdwr_autopre           (te_rdwr_autopre) 
             ,.ts_op_is_rdwr             (gs_te_op_is_wr) 
             ,.ts_op_is_precharge        (gs_te_op_is_precharge) 
             ,.ts_op_is_activate         (gs_te_op_is_activate) 
             ,.ts_wr_mode                (gs_te_wr_mode) 
             ,.te_ts_page_hit            (te_bs_wr_page_hit [TOTAL_BSMS-1:0])
             ,.te_bs_wr_bank_page_hit    (te_bs_wr_bank_page_hit) 
             ,.te_wr_page_table          (te_wr_page_table) 
             ,.te_wr_cmd_autopre_table   (te_wr_cmd_autopre_table)       
             ,.te_wr_mr_ram_raddr_lsb_first_table (te_wr_mr_ram_raddr_lsb_first_table)
             ,.te_wr_mr_pw_num_beats_m1_table     (te_wr_mr_pw_num_beats_m1_table)
             ,.te_mwr_table              (te_mwr_table) 
             ,.te_os_mwr_table           (te_os_mwr_table) 
             ,.te_dh_valid               (te_dh_wr_bsm_valid) 
             ,.te_dh_page_hit            (te_dh_wr_bsm_page_hit) 
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((TOTAL_BSMS * WR_CAM_ADDR_BITS_IE) - 1)' found in module 'teengine'
//SJ: This coding style is acceptable and there is no plan to change it.
             ,.te_os_wr_entry_table      (te_os_wr_entry_table[TOTAL_BSMS*WR_CAM_ADDR_BITS_IE-1:0]) 
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used only for uMCTL2, but output always declared in te_wr_nxt module
             ,.te_pghit_vld              (te_wr_pghit_vld) 
//spyglass enable_block W528
             ,.wr_nxt_page_table         (wr_nxt_page_table[TOTAL_BSMS*PAGE_BITS-1:0])      
             ,.wr_nxt_cmd_autopre_table  (wr_nxt_cmd_autopre_table[TOTAL_BSMS*AUTOPRE_BITS-1:0])
//spyglass enable_block SelfDeterminedExpr-ML
             ,.wr_nxt_mr_ram_raddr_lsb_first_table (wr_nxt_mr_ram_raddr_lsb_first_table[TOTAL_BSMS*PARTIAL_WR_BITS_LOG2-1:0])
             ,.wr_nxt_mr_pw_num_beats_m1_table     (wr_nxt_mr_pw_num_beats_m1_table[TOTAL_BSMS*PW_WORD_CNT_WD_MAX-1:0])
             ,.te_sel_entry_pre          (te_sel_wr_entry_pre) 
             ,.te_sel_wr_page_pre        (te_sel_wr_page_pre) 
             ,.te_sel_wr_cmd_autopre_pre (te_sel_wr_cmd_autopre_pre) 
             ,.te_sel_mwr_pre            (te_sel_mwr_pre) 
             ,.te_sel_wr_mr_ram_raddr_lsb_pre (te_sel_wr_mr_ram_raddr_lsb_pre)
             ,.te_sel_wr_mr_pw_num_beats_m1_pre (te_sel_wr_mr_pw_num_beats_m1_pre)
             ,.te_sel_pw_num_cols_m1_pre (te_sel_pw_num_cols_m1_pre) 
             ,.te_wr_entry_critical_per_bsm (te_wr_entry_critical_per_bsm)
             ,.reg_ddrc_dis_opt_ntt_by_act    (reg_ddrc_dis_opt_ntt_by_act)
             ,.reg_ddrc_dis_opt_ntt_by_pre    (reg_ddrc_dis_opt_ntt_by_pre)
             ,.ts_te_sel_act_wr             (ts_te_sel_act_wr)
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
             ,.ts_te_act_page            (ts_act_page) 
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
            );

  te_misc
   #(  .RD_CAM_ADDR_BITS (RD_CAM_ADDR_BITS), 
              .WR_CAM_ADDR_BITS (WR_CAM_ADDR_BITS_IE),
              .MAX_CAM_ADDR_BITS(MAX_CAM_ADDR_BITS),
              .RD_CAM_ENTRIES   (RD_CAM_ENTRIES),
              .WR_CAM_ENTRIES   (WR_CAM_ENTRIES_IE), 
              .WR_ECC_CAM_ENTRIES(WR_ECC_CAM_ENTRIES),
              .WR_ECC_CAM_ADDR_BITS(WR_ECC_CAM_ADDR_BITS),
              .RANK_BITS        (RANK_BITS), 
              .LRANK_BITS       (LRANK_BITS), 
              .BG_BITS          (BG_BITS), 
              .BANK_BITS        (BANK_BITS), 
              .BG_BANK_BITS     (BG_BANK_BITS), 
              .PAGE_BITS        (PAGE_BITS),
              .BSM_BITS         (BSM_BITS),
              .IE_WR_TYPE_BITS  (IE_WR_TYPE_BITS)
           )
    te_misc (
                        .core_ddrc_rstn            (core_ddrc_rstn) 
                       ,.co_te_clk                 (co_te_clk) 
                       ,.ddrc_cg_en                (ddrc_cg_en) 
//                        ,.te_wr_autopre             (te_wr_autopre ) 
//                        ,.te_pi_rd_autopre          (te_pi_rd_autopre ) 
//                        ,.dh_te_dis_autopre_collide_opt (dh_te_dis_autopre_collide_opt) 
                       ,.dh_te_dis_wc              (dh_te_dis_wc) 
//  `ifdef UMCTL2_DUAL_HIF_1_OR_DDRCTL_RD_CRC_RETRY
                       ,.te_ts_rd_flush           (te_gs_rd_flush) 
                       ,.te_ts_wr_flush           (te_gs_wr_flush) 
                       ,.te_rd_flush              (te_rd_flush) 
                       ,.te_rd_flush_due_rd       (te_rd_flush_due_rd) 
                       ,.te_rd_flush_due_wr       (te_rd_flush_due_wr) 
                       ,.te_wr_flush_due_rd       (te_wr_flush_due_rd) 
                       ,.te_wr_flush_due_wr       (te_wr_flush_due_wr) 
                       ,.te_wr_flush              (te_wr_flush) 
//                        ,.te_rd_flush_started      (te_rd_flush_started) 
//                        ,.te_wr_flush_started      (te_wr_flush_started) 
                       ,.te_wu_wr_retry           (te_wu_wr_retry) 
                       ,.te_ih_retry              (te_ih_retry) 
//                        ,.ts_bsm_num4rdwr           (gs_te_bsm_num4rdwr) 
                       ,.te_ih_free_rd_entry_valid (te_ih_free_rd_entry_valid) 
                       ,.te_ih_free_rd_entry       (te_ih_free_rd_entry [RD_CAM_ADDR_BITS-1:0]) 
                       ,.ts_op_is_rd               (gs_te_op_is_rd) 
                       ,.ts_op_is_wr               (gs_te_op_is_wr) 
//                        ,.ts_wr_mode                (gs_te_wr_mode) 
                       ,.te_rdwr_autopre           (te_rdwr_autopre) 
                       ,.te_rdwr_entry             (os_te_rdwr_entry) 
                       ,.ts_te_autopre             (ts_te_autopre) 
                       ,.te_dh_rd_bsm_valid        (te_dh_rd_bsm_valid) 
                       ,.te_dh_rd_bsm_page_hit     (te_dh_rd_bsm_page_hit) 
                       ,.te_dh_wr_bsm_valid        (te_dh_wr_bsm_valid) 
                       ,.te_dh_wr_bsm_page_hit     (te_dh_wr_bsm_page_hit) 
                       ,.te_dh_rd_valid            (te_dh_rd_valid) 
                       ,.te_dh_rd_page_hit         (te_dh_rd_page_hit) 
                       ,.te_dh_wr_valid            (te_dh_wr_valid) 
                       ,.te_dh_wr_page_hit         (te_dh_wr_page_hit) 
                       ,.te_bs_rd_hi               (te_bs_rd_hi)
                       ,.te_dh_rd_hi               (te_dh_rd_hi)
                       ,.te_wr_entry_valid         (te_wr_entry_valid)
                       ,.te_rd_entry_valid         (te_rd_entry_valid)
                       ,.te_wr_entry_rankbank      (te_wr_entry_rankbank)
                       ,.te_rd_entry_rankbank      (te_rd_entry_rankbank)
                       ,.te_gs_any_wr_pending      (te_gs_any_wr_pending)
                       ,.te_gs_any_rd_pending      (te_gs_any_rd_pending)
                       ,.te_gs_rank_wr_pending     (te_gs_rank_wr_pending)
                       ,.te_gs_rank_rd_pending     (te_gs_rank_rd_pending)
                       ,.te_gs_bank_wr_pending     (te_gs_bank_wr_pending)
                       ,.te_gs_bank_rd_pending     (te_gs_bank_rd_pending)
                       ,.ih_te_wr_bg_bank_num      (ih_te_wr_bg_bank_num) 
                       ,.ih_te_rd_bg_bank_num      (ih_te_rd_bg_bank_num) 
                       ,.te_wr_collision_vld_due_rd   (te_wr_collision_vld_due_rd)
                       ,.te_wr_collision_vld_due_wr   (te_wr_collision_vld_due_wr)
                       ,.te_rws_wr_col_bank        (te_rws_wr_col_bank)
                       ,.te_rws_rd_col_bank        (te_rws_rd_col_bank)
                       ,.te_rd_page_hit            (te_rd_page_hit)
                       ,.te_wr_page_hit_entries    (te_wr_page_hit_entries)
                       ,.te_num_wr_pghit_entries   (te_num_wr_pghit_entries)
                       ,.te_num_rd_pghit_entries   (te_num_rd_pghit_entries)
                       ,.reg_ddrc_lpddr4           (reg_ddrc_lpddr4)
                      );

//--------------
// Push/Pop CAM
//--------------
assign push_rd_cam = ih_te_rd_valid 
                  & ~te_ih_retry 
;

assign push_lpr_cam = push_rd_cam & (ih_te_rd_entry_num[RD_CAM_ADDR_BITS-1:0] <= reg_ddrc_lpr_num_entries);
assign push_hpr_cam = push_rd_cam & (reg_ddrc_lpr_num_entries                 <  ih_te_rd_entry_num[RD_CAM_ADDR_BITS-1:0]);

assign push_wr_cam = ih_te_wr_valid 
                  & ~te_yy_wr_combine 
                  & ~te_ih_retry 
;


assign pop_rd_cam     = gs_te_op_is_rd;
assign pop_lpr_cam    = pop_rd_cam & (os_te_rdwr_entry[RD_CAM_ADDR_BITS-1:0] <= reg_ddrc_lpr_num_entries);
assign pop_hpr_cam    = pop_rd_cam & (reg_ddrc_lpr_num_entries               <  os_te_rdwr_entry[RD_CAM_ADDR_BITS-1:0]);
assign pop_wr_cam     = gs_te_op_is_wr ;

// hmatrix for RD(LPR+HPR)
  te_hmatrix
   #(  
              .CAM_ADDR_BITS (RD_CAM_ADDR_BITS), 
              .CAM_ENTRIES   (RD_CAM_ENTRIES),
              .NUM_COMPS     (RD_NUM_COMPS)
           )
  te_rd_hmatrix (
                        .core_ddrc_rstn            (core_ddrc_rstn) 
                       ,.core_ddrc_core_clk        (co_te_clk) 
                       ,.ddrc_cg_en                (ddrc_cg_en)
                       ,.push                      (push_rd_cam)
                       ,.push_entry                (ih_te_rd_entry_num)
                       ,.pop                       (pop_rd_cam)
                       ,.pop_entry                 (os_te_rdwr_entry[RD_CAM_ADDR_BITS-1:0])
                       ,.masks                     (hmx_rd_masks)
                       ,.oldest_ohs                (hmx_rd_oldest_ohs)
                );

// hmatrix for WR
  te_hmatrix
   #(  
              .CAM_ADDR_BITS (WR_CAM_ADDR_BITS), 
              .CAM_ENTRIES   (WR_CAM_ENTRIES),
              .NUM_COMPS     (WR_NUM_COMPS)
           )
  te_wr_hmatrix (
                        .core_ddrc_rstn            (core_ddrc_rstn) 
                       ,.core_ddrc_core_clk        (co_te_clk) 
                       ,.ddrc_cg_en                (ddrc_cg_en)
                       ,.push                      (push_wr_cam)
                       ,.push_entry                (ih_te_wr_entry_num[WR_CAM_ADDR_BITS-1:0])
                       ,.pop                       (pop_wr_cam)
                       ,.pop_entry                 (os_te_rdwr_entry[WR_CAM_ADDR_BITS-1:0])
                       ,.masks                     (hmx_wr_masks)
                       ,.oldest_ohs                (hmx_wr_oldest_ohs)
                );

// te_lpr_oldest_tracker
  te_oldest_tracker
   #(  
              .CAM_ADDR_BITS (RD_CAM_ADDR_BITS), 
              .CAM_ENTRIES   (RD_CAM_ENTRIES)
           )
  te_lpr_oldest_tracker (
                        .core_ddrc_rstn            (core_ddrc_rstn) 
                       ,.core_ddrc_core_clk        (co_te_clk) 
                       ,.push                      (push_lpr_cam)
                       ,.push_entry                (ih_te_rd_entry_num)
                       ,.pop                       (pop_lpr_cam)
                       ,.pop_entry                 (os_te_rdwr_entry[RD_CAM_ADDR_BITS-1:0])
                       ,.oldest_entry              (i_ih_te_lo_rd_prefer)
           );

// te_hpr_oldest_tracker
  te_oldest_tracker
   #(  
              .CAM_ADDR_BITS (RD_CAM_ADDR_BITS), 
              .CAM_ENTRIES   (RD_CAM_ENTRIES)
           )
  te_hpr_oldest_tracker (
                        .core_ddrc_rstn            (core_ddrc_rstn) 
                       ,.core_ddrc_core_clk        (co_te_clk) 
                       ,.push                      (push_hpr_cam)
                       ,.push_entry                (ih_te_rd_entry_num)
                       ,.pop                       (pop_hpr_cam)
                       ,.pop_entry                 (os_te_rdwr_entry[RD_CAM_ADDR_BITS-1:0])
                       ,.oldest_entry              (i_ih_te_hi_rd_prefer)
           );

// te_wr_oldest_tracker
  te_oldest_tracker
   #(  
              .CAM_ADDR_BITS (WR_CAM_ADDR_BITS), 
              .CAM_ENTRIES   (WR_CAM_ENTRIES)
           )
  te_wr_oldest_tracker (
                        .core_ddrc_rstn            (core_ddrc_rstn) 
                       ,.core_ddrc_core_clk        (co_te_clk) 
                       ,.push                      (push_wr_cam)
                       ,.push_entry                (ih_te_wr_entry_num[WR_CAM_ADDR_BITS-1:0])
                       ,.pop                       (pop_wr_cam)
                       ,.pop_entry                 (os_te_rdwr_entry[WR_CAM_ADDR_BITS-1:0])
                       ,.oldest_entry              (i_ih_te_wr_prefer)
           );







`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
te_assertions
 #(
      .CHANNEL_NUM            (CHANNEL_NUM), 
      .RANKBANK_BITS          (RANKBANK_BITS), 
      .RD_CAM_ADDR_BITS       (RD_CAM_ADDR_BITS), 
      .WR_CAM_ADDR_BITS       (WR_CAM_ADDR_BITS_IE),
      .WR_CAM_ENTRIES         (WR_CAM_ENTRIES_IE), 
      .MAX_CAM_ADDR_BITS      (MAX_CAM_ADDR_BITS),
      .PAGE_BITS              (PAGE_BITS), 
      .BLK_BITS               (BLK_BITS), 
      .OTHER_RD_ENTRY_BITS    (OTHER_RD_ENTRY_BITS), 
      .OTHER_WR_ENTRY_BITS    (OTHER_WR_ENTRY_BITS), 
      .OTHER_RD_RMW_LSB       (OTHER_RD_RMW_LSB), 
      .OTHER_RD_RMW_TYPE_BITS (OTHER_RD_RMW_TYPE_BITS),
      .IE_RD_TYPE_BITS        (IE_RD_TYPE_BITS),
      .IE_WR_TYPE_BITS        (IE_WR_TYPE_BITS),
      .BT_BITS                (BT_BITS),
      .NO_OF_BT               (NO_OF_BT),
      .IE_BURST_NUM_BITS      (IE_BURST_NUM_BITS), 
      .IE_UNIQ_BLK_BITS       (IE_UNIQ_BLK_BITS),
      .IE_UNIQ_RBK_BITS       (IE_UNIQ_RBK_BITS),
      .IE_UNIQ_BLK_LSB        (IE_UNIQ_BLK_LSB),
      .RANK_BITS              (LRANK_BITS),
      .AM_COL_WIDTH_H         (AM_COL_WIDTH_H),
      .AM_COL_WIDTH_L         (AM_COL_WIDTH_L),
      .BG_BANK_BITS           (BG_BANK_BITS)
    )
  te_assertions (
     .core_ddrc_rstn           (core_ddrc_rstn) 
    ,.co_te_clk                (co_te_clk) 
    ,.ih_te_rd_entry_num       (ih_te_rd_entry_num) 
    ,.ih_te_rd_valid           (ih_te_rd_valid) 
    ,.ih_te_wr_entry_num       (ih_te_wr_entry_num) 
    ,.ih_te_wr_valid           (ih_te_wr_valid) 
    ,.ih_te_wr_rankbank_num    ({
                                 ih_te_wr_bg_bank_num}) 
    ,.ih_te_wr_page_num        (ih_te_wr_page_num) 
    ,.ih_te_wr_block_num       (ih_te_wr_block_num) 
    ,.ih_te_rd_rankbank_num    ({
                                 ih_te_rd_bg_bank_num}) 
    ,.ih_te_rd_page_num        (ih_te_rd_page_num) 
    ,.ih_te_rd_block_num       (ih_te_rd_block_num) 
    ,.ih_te_rd_other_fields    (ih_te_rd_other_fields) 
    ,.ih_te_wr_other_fields    (ih_te_wr_other_fields) 
    ,.te_rd_flush              (te_rd_flush) 
    ,.te_rd_flush_due_wr       (te_rd_flush_due_wr)        
    ,.te_rd_flush_due_rd       (te_rd_flush_due_rd) 
    ,.te_rd_col_entry          (te_rd_col_entry) 
    ,.te_wr_flush              (te_wr_flush) 
    ,.te_wr_flush_due_wr       (te_wr_flush_due_wr)        
    ,.te_wr_flush_due_rd       (te_wr_flush_due_rd) 
    ,.te_wr_flush_started      (te_wr_flush_started) 
    ,.te_wr_col_entry          (te_wr_col_entry) 
    ,.te_os_hi_bsm_hint        (te_os_hi_bsm_hint) 
    ,.te_os_lo_bsm_hint        (te_os_lo_bsm_hint) 
    ,.te_os_wr_bsm_hint        (te_os_wr_bsm_hint) 
    ,.te_ih_rd_retry           (te_ih_rd_retry_int) 
    ,.te_ih_wr_retry           (te_ih_wr_retry_int) 
    ,.te_bs_rd_valid           (te_bs_rd_valid) 
    ,.te_bs_wr_valid           (te_bs_wr_valid) 
//     ,.dh_te_dis_autopre_collide_opt (dh_te_dis_autopre_collide_opt) 
    ,.te_rd_entry_valid        (te_rd_bank_hit_filtred) 
    ,.te_sel_rd_entry          (te_sel_rd_entry) 
    ,.os_te_rdwr_entry         (os_te_rdwr_entry) 
    ,.te_wr_entry_valid        (te_wr_bank_hit_filtred) 
    ,.te_rd_act_entry          (/*os_te_rd_act_entry*/) 
    ,.te_wr_act_entry          (/*os_te_wr_act_entry*/) 
    ,.te_sel_wr_entry          (te_sel_wr_entry) 
    ,.te_yy_wr_combine         (te_yy_wr_combine) 
    ,.te_wr_entry_we_bw_loaded (i_wr_entry_we_bw_loaded)
    ,.gs_te_op_is_rd           (gs_te_op_is_rd) 
    ,.gs_te_op_is_wr           (gs_te_op_is_wr) 
    ,.gs_te_op_is_precharge    (gs_te_op_is_precharge) 
    ,.gs_te_op_is_activate     (gs_te_op_is_activate) 
    ,.gs_te_bsm_num4pre        (gs_te_bsm_num4pre) 
    ,.gs_te_bsm_num4act        (gs_te_bsm_num4act) 
    ,.gs_te_bsm_num4rdwr       (gs_te_bsm_num4rdwr) 
    ,.te_pi_rd_addr_blk        (te_pi_rd_addr_blk) 
    ,.te_pi_rd_other_fields_rd (te_pi_rd_other_fields_rd)
    ,.ts_act_page              (ts_act_page) 
    ,.te_pi_wr_addr_blk        (te_pi_wr_addr_blk) 
    ,.te_pi_wr_other_fields_wr (te_pi_wr_other_fields_wr) 
    ,.te_rd_page_hit           (te_rd_page_hit) 
    ,.te_wr_page_hit           (te_wr_page_hit) 
    ,.ts_te_autopre            (ts_te_autopre) 
    ,.rd_nxt_page_table        (rd_nxt_page_table) 
    ,.wr_nxt_page_table        (wr_nxt_page_table) 
    ,.gs_te_wr_mode            (gs_te_wr_mode) 
    ,.rd_nxt_entry_in_ntt      (rd_nxt_entry_in_ntt) 
    ,.wr_nxt_entry_in_ntt      (wr_nxt_entry_in_ntt) 
    ,.te_os_rd_entry_table     (te_os_rd_entry_table) 
    ,.te_os_wr_entry_table     (te_os_wr_entry_table) 
    ,.te_rd_entry_valid_cam    (te_rd_entry_valid) 
    ,.te_rd_entry_loaded_cam   (te_rd_entry_loaded)
    ,.te_wr_entry_valid_cam    (te_wr_entry_valid) 
    ,.ih_te_rd_autopre         (ih_te_rd_autopre_i)       
    ,.ih_te_rd_autopre_org      (ih_te_rd_autopre) 
    ,.reg_ddrc_autopre_rmw      (reg_ddrc_autopre_rmw)
    ,.ih_te_rd_rmw              (ih_te_rd_rmw) 
    ,.ih_te_wr_autopre         (ih_te_wr_autopre)       
    ,.dh_te_pageclose          (dh_te_pageclose)        
    ,.dh_te_pageclose_timer    (dh_te_pageclose_timer)  
//     ,.te_pi_rd_autopre         (te_pi_rd_autopre)       
//     ,.te_wr_autopre            (te_wr_autopre) 
    ,.te_be_bsm_num            (te_be_bsm_num)
    ,.rd_cam_delayed_autopre_update_fe (RDcam.delayed_autopre_update_fe)
    ,.wr_cam_delayed_autopre_update_fe (WRcam.delayed_autopre_update_fe)
    ,.wr_cam_rd_and_wr_data_rdy        (WRcam.rd_and_wr_data_rdy)
    ,.wr_cam_i_combine_match           (WRcam.i_combine_match)
    ,.reg_ddrc_data_bus_width          (reg_ddrc_data_bus_width)
);



  // If te_gs_wr_flush=1, the collision should not be solved by combine (in Dual HIF, combine can happen, but it should not solve collision  
  property p_te_gs_wr_flush_check;              @(posedge co_te_clk) disable iff(!core_ddrc_rstn) te_gs_wr_flush |-> ~te_yy_wr_combine; endproperty

  a_te_gs_wr_flush_check            : assert property (p_te_gs_wr_flush_check) 
  else $display ("%0t ERROR : te_gs_wr_flush is asserted but the collision is solved by write combine",$realtime);


//Length Comparison
//`ifdef DDRCTL_LLC_4CYCSCH
// property p_te_rd_length_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_rd |-> ($past(gs_te_rd_length,1) == te_pi_rd_length_int) ; endproperty
//`else  // DDRCTL_LLC_4CYCSCH
 property p_te_rd_length_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_rd |-> (gs_te_rd_length == te_pi_rd_length_int) ; endproperty
//`endif // DDRCTL_LLC_4CYCSCH

  a_te_rd_length_check : assert property (p_te_rd_length_check)
  else $display ("%0t ERROR : the length field is mismatching gs_te_rd_length = %h te_pi_rd_length_int = %h ", $realtime,gs_te_rd_length, te_pi_rd_length_int);


//`ifdef DDRCTL_LLC_4CYCSCH
// property p_te_rd_word_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_rd |-> ($past(gs_te_rd_word,1) == te_pi_rd_word_int) ; endproperty
//`else  // DDRCTL_LLC_4CYCSCH
 property p_te_rd_word_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_rd |-> (gs_te_rd_word == te_pi_rd_word_int) ; endproperty
//`endif // DDRCTL_LLC_4CYCSCH

  a_te_rd_word_check : assert property (p_te_rd_word_check)
  else $display ("%0t ERROR : the critical word field is mismatching gs_te_rd_word = %h te_pi_rd_word_int = %h ", $realtime,gs_te_rd_word, te_pi_rd_word_int);


//`ifdef DDRCTL_LLC_4CYCSCH
// property p_te_wr_ram_raddr_lsb_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_wr |-> ($past(gs_te_raddr_lsb_first,1) == te_mr_ram_raddr_lsb_first_int) ; endproperty
//`else  // DDRCTL_LLC_4CYCSCH
 property p_te_wr_ram_raddr_lsb_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_wr |-> (gs_te_raddr_lsb_first == te_mr_ram_raddr_lsb_first_int) ; endproperty
//`endif // DDRCTL_LLC_4CYCSCH

  a_te_wr_ram_raddr_lsb_check : assert property (p_te_wr_ram_raddr_lsb_check)
  else $display ("%0t ERROR : the ram_raddr_lsb_first field is mismatching  gs_te_raddr_lsb_first = %h te_mr_ram_raddr_lsb_first_int = %h ", $realtime,gs_te_raddr_lsb_first,te_mr_ram_raddr_lsb_first_int);


//`ifdef DDRCTL_LLC_4CYCSCH
// property p_te_wr_pw_num_beats_m1_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_wr |-> ($past(gs_te_pw_num_beats_m1,1) == te_mr_pw_num_beats_m1_int) ; endproperty
//`else  // DDRCTL_LLC_4CYCSCH
 property p_te_wr_pw_num_beats_m1_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) gs_te_op_is_wr |-> (gs_te_pw_num_beats_m1 == te_mr_pw_num_beats_m1_int) ; endproperty
//`endif // DDRCTL_LLC_4CYCSCH

  a_te_wr_pw_num_beats_m1_check : assert property (p_te_wr_pw_num_beats_m1_check)
  else $display ("%0t ERROR : the pw_num_beats_m1 field is mismatching gs_te_pw_num_beats_m1 = %h te_mr_pw_num_beats_m1_int = %h ", $realtime,gs_te_pw_num_beats_m1, te_mr_pw_num_beats_m1_int);
`endif // SNPS_ASSERT_ON
`endif // `ifndef SYNTHESIS
endmodule
