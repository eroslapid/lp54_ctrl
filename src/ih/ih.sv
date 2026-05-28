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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This is the top level of IH module.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module ih 
import DWC_ddrctl_reg_pkg::*;
#(
    //------------------------------ PARAMETERS ------------------------------------
     parameter CORE_ADDR_WIDTH   = (`UMCTL2_LRANK_BITS+`MEMC_BG_BANK_BITS+`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS) 
    ,parameter IH_TAG_WIDTH      = `MEMC_TAGBITS                 // width of token/tag field from core
    ,parameter CMD_LEN_BITS      = 1                             // bits for command length, when used
    ,parameter RDCMD_ENTRY_BITS  = `MEMC_RDCMD_ENTRY_BITS        // bits to address all entries in read CAM
    ,parameter WRCMD_ENTRY_BITS  = `MEMC_WRCMD_ENTRY_BITS        // bits to address all entries in write CAM
    ,parameter WRECCCMD_ENTRY_BITS = 0                           // overridden 
    ,parameter WRCMD_ENTRY_BITS_IE = 0                           // overridden 
    ,parameter RMW_TYPE_BITS     = 2                             // 2 bits for RMW type
                                                                 //  (partial write, atomic RMW, scrub, or none)
    ,parameter WDATA_PTR_BITS    = `MEMC_WDATA_PTR_BITS 
    ,parameter CMD_TYPE_BITS     = 2                             // any change will require RTL modifications in IC
    
    ,parameter WRDATA_ENTRY_BITS = WRCMD_ENTRY_BITS + 1          // write data RAM entries
                                                                 // (only support 2 datas per command at the moment)
    ,parameter WRDATA_CYCLES     = `MEMC_WRDATA_CYCLES 
//    `ifdef DDRCTL_ANY_RETRY
    ,parameter RETRY_TIMES_WIDTH  = 3
//    `endif
    ,parameter PW_WORD_CNT_WD_MAX = 1 
    ,parameter       AM_DCH_WIDTH     = 6
    ,parameter       AM_CS_WIDTH      = 6
    ,parameter       AM_CID_WIDTH     = 6
    ,parameter       AM_BANK_WIDTH    = 6
    ,parameter       AM_BG_WIDTH      = 6
    ,parameter       AM_ROW_WIDTH     = 5
    ,parameter       AM_COL_WIDTH_H   = 5
    ,parameter       AM_COL_WIDTH_L   = 4
    )
    (
    //-------------------------- INPUTS AND OUTPUTS --------------------------------    
     input                               co_ih_clk                 // clock
    ,input                               core_ddrc_rstn            // reset

    //////////////////////
    // Core Interface
    //////////////////////
    ,input                               hif_cmd_valid             // valid command
    ,input [CMD_TYPE_BITS-1:0]           hif_cmd_type              // command type:
                                                                   //  00 - block write
                                                                   //  01 - read
                                                                   //  10 - rmw
                                                                   //  11 - reserved

    ,input [CORE_ADDR_WIDTH-1:0]         hif_cmd_addr              // address
    ,input [IH_TAG_WIDTH-1:0]            hif_cmd_token             // read token returned w/ read data
    ,input [1:0]                         hif_cmd_pri               // priority:
                                                                   //  00 - low priority, 01 - VPR
                                                                   //  10 - high priority, 11 - Unused
    ,input [CMD_LEN_BITS-1:0]            hif_cmd_length            // length (1 word or 2)
                                                                   //  1 - 1 word
                                                                   //  0 - 2 words
    ,input [WDATA_PTR_BITS-1:0]          hif_cmd_wdata_ptr         //
    ,input                               hif_cmd_autopre           // auto precharge enable
    ,input                               gsfsm_sr_co_if_stall 
    ,output                              ih_busy                   // is high when a cmd comes into IH and when the FIFO's are non-empty
    ,output                              ih_fifo_wr_empty 
    ,output                              ih_fifo_rd_empty 
    ,output                              hif_cmd_stall             // cmd stall
    ,output [WDATA_PTR_BITS-1:0]         hif_wdata_ptr 
    ,output                              hif_wdata_ptr_valid 
    ,output                              hif_wdata_ptr_addr_err 
    ,output                              hif_wr_credit 
    ,output [`MEMC_HIF_CREDIT_BITS-1:0]  hif_lpr_credit 
    ,output [`MEMC_HIF_CREDIT_BITS-1:0]  hif_hpr_credit 
    ,input                               co_ih_lpr_num_entries_changed 
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in ih_assertions module
    ,input [2:0]                         dh_ih_operating_mode       // global schedule FSM state
//spyglass enable_block W240
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used at uMCTL2
//spyglass enable_block W240
    ,input [2:0]                         dh_ih_nonbinary_device_density
    ,input                               reg_ddrc_lpddr5
    ,input [BANK_ORG_WIDTH-1:0]          reg_ddrc_bank_org
    ,input                               dh_ih_dis_hif             // disable (stall) hif
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input  [3:0]                        reg_ddrc_burst_rdwr 
//spyglass enable_block W240
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
    ,input                               reg_ddrc_ecc_type
//spyglass enable_block W240
    /////////////////
    // WU Interface
    /////////////////
    ,input                               wu_ih_flow_cntrl_req      // wu_wdata_if fifo in WU is full
    
    /////////////////
    // TE Interface
    /////////////////
    ,output                              ih_te_rd_valid 
    ,output                              ih_te_wr_valid 
    ,output                              ih_wu_wr_valid 
    ,output                              ih_te_rd_valid_addr_err 
    ,output                              ih_te_wr_valid_addr_err 
    ,output [CMD_LEN_BITS-1:0]           ih_te_rd_length 
    ,output [IH_TAG_WIDTH-1:0]           ih_te_rd_tag 
    ,output [RMW_TYPE_BITS-1:0]          ih_te_rmwtype             // 00 - partial write
                                                                   // 01 - atomic RMW commands
                                                                   // 10 - scrub
                                                                   // 11 - no RMW
    ,output [`MEMC_BG_BITS -1:0]         ih_te_rd_bankgroup_num    // bankgroup of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BG_BITS -1:0]         ih_te_wr_bankgroup_num    // bankgroup of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BG_BANK_BITS -1:0]    ih_te_rd_bg_bank_num      // bank & bg of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BG_BANK_BITS -1:0]    ih_te_wr_bg_bank_num      // bank & bg of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BANK_BITS -1:0]       ih_te_rd_bank_num         // bank of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BANK_BITS -1:0]       ih_te_wr_bank_num         // bank of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_PAGE_BITS -1:0]       ih_te_rd_page_num         // page/row of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_PAGE_BITS -1:0]       ih_te_wr_page_num         // page/row of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BLK_BITS  -1:0]       ih_te_rd_block_num        // block  of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_BLK_BITS  -1:0]       ih_te_wr_block_num        // block  of request to TE, qualified by (ih_te_rd_valid or ih_te_wr_valid)
    ,output [`MEMC_WORD_BITS-1:0]        ih_te_critical_dword      // for reads only, critical word within a block - not currently supported
                                                                   // would be qualified by ((ih_te_rd_valid | ih_te_wr_valid) & ih_te_rd))
                                                                   // for rmw, this is forced to 0
    ,output [RDCMD_ENTRY_BITS-1:0]       ih_te_rd_entry 
    ,output [WRCMD_ENTRY_BITS_IE-1:0]    ih_te_wr_entry 
    ,output [WRCMD_ENTRY_BITS-1:0]       ih_te_wr_entry_rmw 
    ,output [WRCMD_ENTRY_BITS-1:0]       ih_te_wr_prefer 
    ,output [RDCMD_ENTRY_BITS-1:0]       ih_te_lo_rd_prefer 
    ,output [RDCMD_ENTRY_BITS-1:0]       ih_te_hi_rd_prefer 
    ,output [1:0]                        ih_te_rd_hi_pri           // priority of read request
    ,output [1:0]                        ih_te_wr_hi_pri           // priority of write request
    ,output                              ih_te_rd_autopre 
    ,output                              ih_te_wr_autopre 
    ,output [`MEMC_WORD_BITS-1:0]        ih_wu_critical_dword      // for reads only, critical word within a block - not currently supported
                                                                   //  would be qualified by ((ih_te_rd_valid | ih_te_wr_valid) & ih_te_rd))
                                                                   // for rmw, this is NOT forced to 0
    ,input [RDCMD_ENTRY_BITS-1:0]        te_ih_free_rd_entry       // read CAM entry # to be freed, when te_ih_free_rd_entry_valid=1
    ,input                               te_ih_free_rd_entry_valid // a read CAM entry # is being freed
    ,input [WRCMD_ENTRY_BITS_IE-1:0]     mr_ih_free_wr_entry       // write CAM entry # to be freed, when mr_ih_free_wr_entry_valid=1
    ,input                               mr_ih_free_wr_entry_valid // a write CAM entry # is being freed
    ,input                               te_ih_retry               // collision detected. stall IH outputs.
    ,input                               te_ih_wr_combine          // collision detected. stall IH outputs.
    
    `ifdef SNPS_ASSERT_ON
     `ifndef SYNTHESIS
     `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
    
    /////////////////
    // TS Interface
    /////////////////
    ,output                              ih_yy_xact_valid          // any valid request from IH (read or write)
    ,output                              ih_gs_rdlow_empty         // transaction queue is empty
    ,output                              ih_gs_wr_empty            // transaction queue is empty
    ,output                              ih_gs_rdhigh_empty        // transaction queue is empty
    
    /////////////////
    // BE Interface
    /////////////////
    ,output                              ih_be_hi_pri_rd_xact      // hi priority read transaction valid
    ,output [`MEMC_BG_BANK_BITS -1:0]    ih_be_bg_bank_num_rd 
    ,output [`MEMC_BG_BANK_BITS -1:0]    ih_be_bg_bank_num_wr 
    ,output [`MEMC_PAGE_BITS -1:0]       ih_be_page_num 
    
    /////////////////
    // Inline ECC interface
    /////////////////
    /////////////////////////////////////////
    //  Retry Ctrl Interface
    /////////////////////////////////////////
   
    ////////////////////////
    // Register Interface
    ////////////////////////
    ,input [RDCMD_ENTRY_BITS-1:0]        dh_ih_lpr_num_entries 
    ,input   [AM_BANK_WIDTH-1:0]         dh_ih_addrmap_bank_b0 
    ,input   [AM_BANK_WIDTH-1:0]         dh_ih_addrmap_bank_b1 
    ,input   [AM_BANK_WIDTH-1:0]         dh_ih_addrmap_bank_b2 
    ,input   [AM_BG_WIDTH-1:0]           dh_ih_addrmap_bg_b0 
    ,input   [AM_BG_WIDTH-1:0]           dh_ih_addrmap_bg_b1 
    ,input   [AM_COL_WIDTH_L-1:0]        dh_ih_addrmap_col_b3 
    ,input   [AM_COL_WIDTH_L-1:0]        dh_ih_addrmap_col_b4 
    ,input   [AM_COL_WIDTH_L-1:0]        dh_ih_addrmap_col_b5 
    ,input   [AM_COL_WIDTH_L-1:0]        dh_ih_addrmap_col_b6 
    ,input   [AM_COL_WIDTH_H-1:0]        dh_ih_addrmap_col_b7 
    ,input   [AM_COL_WIDTH_H-1:0]        dh_ih_addrmap_col_b8 
    ,input   [AM_COL_WIDTH_H-1:0]        dh_ih_addrmap_col_b9 
    ,input   [AM_COL_WIDTH_H-1:0]        dh_ih_addrmap_col_b10 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b0 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b1 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b2 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b3 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b4 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b5 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b6 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b7 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b8 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b9 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b10 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b11 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b12 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b13 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b14 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b15 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b16 
    ,input   [AM_ROW_WIDTH-1:0]          dh_ih_addrmap_row_b17 

    
    ////////////////////
    // Debug signals
    ////////////////////
    ,output                              ih_dh_stall 
    ,output [RDCMD_ENTRY_BITS:0]         ih_dh_hpr_q_depth       // number of valid entries in the high priority read queue
    ,output [RDCMD_ENTRY_BITS:0]         ih_dh_lpr_q_depth       // number of valid entries in the low priority read queue
    ,output [WRCMD_ENTRY_BITS:0]         ih_dh_wr_q_depth        // number of valid entries in the write queue
    );


wire   te_ih_core_in_stall; //it indicate block the input fifo, will be assert when te_ih_retry or ie_cmd_active assert 
wire   te_ppl_ih_stall;
wire   te_ih_retry_i;
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in ih_assertions module.
assign te_ih_core_in_stall = te_ppl_ih_stall;
assign te_ih_retry_i       = te_ih_retry; 
//spyglass enable_block W528
////////////////////////////
// WIRES 
////////////////////////////
wire                            hif_rcmd_stall;
wire                            hif_wcmd_stall;

assign hif_cmd_stall = hif_rcmd_stall | hif_wcmd_stall;

wire                            rxcmd_valid;
wire [CORE_ADDR_WIDTH-1:0]      rxcmd_addr;
wire [CMD_TYPE_BITS-1:0]        rxcmd_type;
wire [IH_TAG_WIDTH-1:0]         rxcmd_token;
wire [CMD_LEN_BITS-1:0]         rxcmd_length;
wire [WDATA_PTR_BITS-1:0]       rxcmd_wdata_ptr;        

wire [CORE_ADDR_WIDTH-1:0]      rxcmd_addr_dup;

wire                            ih_te_autopre;          // auto precharge enable flag
wire                            rxcmd_autopre;
wire                            rxcmd_invalid_addr;
wire                            rxcmd_invalid_addr_row13_12;
wire                            rxcmd_invalid_addr_row14_13;
wire                            rxcmd_invalid_addr_row15_14;
wire                            rxcmd_invalid_addr_row16_15;
wire                            rxcmd_invalid_addr_row17_16;


wire [1:0]                      rxcmd_pri;
wire [1:0]                      ih_te_hi_pri;           // priority that is affected by the force_low_pri_n signal
wire [1:0]                      ih_te_hi_pri_int;       // internal priority signal, same as the incoming co_rxcmd_pri

wire [RDCMD_ENTRY_BITS:0]       hpr_fifo_fill_level;




wire [WRCMD_ENTRY_BITS:0]       wr_fifo_fill_level;
wire [RDCMD_ENTRY_BITS:0]       lpr_fifo_fill_level;

// Based on address mapper widths, regardless of bits used by
//  any particular design instance
wire [`MEMC_BG_BANK_BITS-1:0]   mapped_bg_bank_num;
wire [`MEMC_PAGE_BITS-1:0]      mapped_page_num;

wire [`MEMC_BLK_BITS-1:0]       mapped_block_num;
wire [`MEMC_WORD_BITS-1:0]      critical_dword;

wire [`MEMC_BG_BANK_BITS-1:0]   mapped_bg_bank_num_to_te;
wire [`MEMC_PAGE_BITS-1:0]      mapped_page_num_to_te;

wire [`MEMC_BLK_BITS-1:0]       mapped_block_num_to_te;
wire [`MEMC_WORD_BITS-1:0]      critical_dword_to_te;




wire [`MEMC_BG_BANK_BITS-1:0]   ih_yy_bg_bank_num;
wire [`MEMC_PAGE_BITS-1:0]      ih_yy_page_num;
wire [`MEMC_PAGE_BITS-1:0]      ih_yy_page_num_corr;





wire [`MEMC_BG_BITS-1:0]        ih_te_bankgroup_num;
wire [`MEMC_BG_BANK_BITS -1:0]  ih_te_bg_bank_num;
wire [`MEMC_BANK_BITS -1:0]     ih_te_bank_num;
wire [`MEMC_PAGE_BITS-1:0]      ih_te_page_num_corr;
wire [`MEMC_BLK_BITS -1:0]      ih_te_block_num;

wire                            input_fifo_full;
wire                            input_fifo_empty;
wire                            ih_in_busy;

wire                            lpr_cam_empty ;
wire                            lpr_cam_full  ;
wire                            hpr_cam_empty ;
wire                            hpr_cam_full  ;
wire                            wr_cam_empty  ;
wire                            wr_cam_full   ;
wire                            wrecc_cam_empty  ;
wire                            wrecc_cam_full   ;
wire                            wr_cam_full_unused;

wire                            bg_b16_addr_mode;

// signals for IH_TE_PIPELINE  -- begin -- //
wire [WDATA_PTR_BITS-1:0]         ppl_rxcmd_wdata_ptr;        

wire                              ih_ppl_te_rd_valid; 
wire                              ih_ppl_te_wr_valid; 
wire                              ih_ppl_wu_wr_valid; 
wire                              ih_ppl_te_rd_valid_addr_err; 
wire                              ih_ppl_te_wr_valid_addr_err; 
wire [CMD_LEN_BITS-1:0]           ih_ppl_te_rd_length; 
wire [IH_TAG_WIDTH-1:0]           ih_ppl_te_rd_tag; 
wire [RMW_TYPE_BITS-1:0]          ih_ppl_te_rmwtype; 

wire [1:0]                        ih_ppl_te_hi_pri; 
wire [1:0]                        ih_ppl_te_hi_pri_int;

wire                              ih_ppl_te_autopre;
wire [`MEMC_BG_BITS-1:0]          ih_ppl_te_bankgroup_num;
wire [`MEMC_BG_BANK_BITS -1:0]    ih_ppl_te_bg_bank_num;
wire [`MEMC_BANK_BITS -1:0]       ih_ppl_te_bank_num;
wire [`MEMC_PAGE_BITS -1:0]       ih_ppl_te_page_num;
wire [`MEMC_PAGE_BITS-1:0]        ih_ppl_te_page_num_corr; 
wire [`MEMC_BLK_BITS -1:0]        ih_ppl_te_block_num;
wire [`MEMC_WORD_BITS-1:0]        ih_ppl_te_critical_dword;
wire [`MEMC_WORD_BITS-1:0]        ih_ppl_wu_critical_dword;




// Signals for IH_TE_PIPELINE  -- end -- //

// Signals for ih_retry_mux -- begin -- //
   //data in from IH
wire                              i_ih_te_rd_valid;
wire                              i_ih_te_wr_valid;
wire                              i_ih_wu_wr_valid;
wire [RMW_TYPE_BITS-1:0]          i_ih_te_rmwtype;
wire                              i_ih_te_wr_valid_addr_err;
wire                              i_ih_te_rd_valid_addr_err;
wire [CMD_LEN_BITS-1:0]           i_ih_te_rd_length; 
wire [IH_TAG_WIDTH-1:0]           i_ih_te_rd_tag;




wire  [1:0]                       i_ih_te_hi_pri;          // priority that is affected by the force_low_pri_n signal
wire  [1:0]                       i_ih_te_hi_pri_int;      
wire                              i_ih_te_autopre;         // auto precharge enable flag
wire   [`MEMC_BG_BITS-1:0]        i_ih_te_bankgroup_num;
wire   [`MEMC_BG_BANK_BITS -1:0]  i_ih_te_bg_bank_num;
wire   [`MEMC_BANK_BITS -1:0]     i_ih_te_bank_num;
wire   [`MEMC_PAGE_BITS -1:0]     i_ih_te_page_num_corr;
wire   [`MEMC_BLK_BITS -1:0]      i_ih_te_block_num;
wire   [`MEMC_WORD_BITS-1:0]      i_ih_te_critical_dword;      // for reads only, critical word within a block - not currently supported
wire   [`MEMC_WORD_BITS-1:0]      i_ih_wu_critical_dword;     // for reads only, critical word within a block - not currently supported


wire  [`MEMC_BG_BITS-1:0]        retryctrl_bankgroup_num;

// Signals for ih_retry_mux -- end -- //








assign ih_dh_stall = hif_cmd_stall;

// drive dual ih_te_rd*/ih_te_wr* outputs from single internal signals
// as both RD/WR are same for ih.v
assign ih_te_rd_bankgroup_num = ih_te_bankgroup_num;  
assign ih_te_wr_bankgroup_num = ih_te_bankgroup_num;
assign ih_te_rd_bg_bank_num = ih_te_bg_bank_num;
assign ih_te_wr_bg_bank_num = ih_te_bg_bank_num;
assign ih_te_rd_bank_num = ih_te_bank_num;
assign ih_te_wr_bank_num = ih_te_bank_num;
assign ih_te_rd_page_num = ih_te_page_num_corr;
assign ih_te_wr_page_num = ih_te_page_num_corr;
assign ih_te_rd_block_num = ih_te_block_num;
assign ih_te_wr_block_num = ih_te_block_num;
assign ih_te_rd_autopre = ih_te_autopre;
assign ih_te_wr_autopre = ih_te_autopre;
assign ih_te_rd_hi_pri  = ih_te_hi_pri;
assign ih_te_wr_hi_pri  = ih_te_hi_pri;

// There are 4 signals that contribute to this:
//
// (1) ih_in_busy:
//     - Signal goes high in the clock in which the input command valid arrives (hif_cmd_valid)
//     - In the next cycle, input_fifo_empty goes low and that keeps the ih_in_busy signal high
//
// (2) In the following cycle, the FIFO control empty signals go low and that will again keep ih_busy high
// This will go LOW only when all the FIFO's are empty (indicating no more cmds inside DDRC) and no new input cmd
//
// (3) ECC scrub requests are pending. When both the 'entry_avail' signals are high, it indicates both rd and wr scrub 
//     requests have been serviced
//
// (4) w_fifo_fill_level: this ensures that all write credits have been returned
//

assign  ih_busy         =    ih_in_busy
                          || (~ih_gs_rdhigh_empty)
                          || (~ih_gs_rdlow_empty) 
                          || (~ih_gs_wr_empty)
                          || (|wr_fifo_fill_level)
                           ;


// When OPT_TIMING is defined, the address map module is instantiated before the input flops
// Hence get the mapped_* group of signal on the RHS, instead of the rxcmd_addr_*
wire [CORE_ADDR_WIDTH-1:0] mapped_addr;
assign mapped_addr = {
                               mapped_bg_bank_num,mapped_page_num,mapped_block_num,critical_dword
                          };


//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(((((3 + 4) + 18) + 9) + 3) - 1)' found in module 'ih'
//SJ: This coding style is acceptable and there is no plan to change it.

//--------------------
// This section uses the duplicate flops rxcmd_addr flop coming out of the input fifo
// The ih_yy_* signals are used to drive the BE, BS & PI modules
//--------------------


     assign ih_yy_bg_bank_num   = rxcmd_addr_dup[`MEMC_BG_BANK_BITS+`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS-1:
                                                 `MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS];

     assign ih_yy_page_num   = rxcmd_addr_dup[`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS-1:
                                              `MEMC_BLK_BITS+`MEMC_WORD_BITS];


//--------------------
// This section allocates the rank, bank, page & block addresses when the address map
// is present externally (before the input fifo). rxcmd_addr is the output of the input_fifo
// These signals go to the ih_te_if module
//--------------------


  assign mapped_bg_bank_num_to_te = rxcmd_addr[`MEMC_BG_BANK_BITS+`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS-1:
                                              `MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS];

  assign mapped_page_num_to_te = rxcmd_addr[`MEMC_PAGE_BITS+`MEMC_BLK_BITS+`MEMC_WORD_BITS-1:
                                            `MEMC_BLK_BITS+`MEMC_WORD_BITS];

  assign mapped_block_num_to_te = rxcmd_addr[`MEMC_BLK_BITS+`MEMC_WORD_BITS-1:`MEMC_WORD_BITS];

  assign critical_dword_to_te = rxcmd_addr[`MEMC_WORD_BITS-1:0];
  

//--------------------
// This section allocates the rank, bank, page & block addresses when the address map
// is present internally (after the input fifo). mapped_* signals are the outputs of the 
// address_map module. The mapped_*_to_te signals go to the ih_te_if module
//--------------------
//spyglass enable_block SelfDeterminedExpr-ML

      assign rxcmd_invalid_addr_row13_12 = ((dh_ih_nonbinary_device_density == 3'b001) && (ih_ppl_te_page_num[13:12] == 2'b11)) ? 1'b1 : 1'b0;
      assign rxcmd_invalid_addr_row14_13 = ((dh_ih_nonbinary_device_density == 3'b010) && (ih_ppl_te_page_num[14:13] == 2'b11)) ? 1'b1 : 1'b0;
      assign rxcmd_invalid_addr_row15_14 = ((dh_ih_nonbinary_device_density == 3'b011) && (ih_ppl_te_page_num[15:14] == 2'b11)) ? 1'b1 : 1'b0;
      assign rxcmd_invalid_addr_row16_15 = ((dh_ih_nonbinary_device_density == 3'b100) && (ih_ppl_te_page_num[16:15] == 2'b11)) ? 1'b1 : 1'b0;
      assign rxcmd_invalid_addr_row17_16 = ((dh_ih_nonbinary_device_density == 3'b101) && (ih_ppl_te_page_num[17:16] == 2'b11)) ? 1'b1 : 1'b0;

      assign ih_ppl_te_page_num_corr[`MEMC_PAGE_BITS-1:12] =
                                                          rxcmd_invalid_addr_row13_12 ? {ih_ppl_te_page_num[`MEMC_PAGE_BITS-1:14],2'b10} :
                                                          rxcmd_invalid_addr_row14_13 ? {ih_ppl_te_page_num[`MEMC_PAGE_BITS-1:14],1'b0,ih_ppl_te_page_num[12]} :
                                                          rxcmd_invalid_addr_row15_14 ? {ih_ppl_te_page_num[`MEMC_PAGE_BITS-1:15],1'b0,ih_ppl_te_page_num[13:12]} :
                                                          rxcmd_invalid_addr_row16_15 ? {ih_ppl_te_page_num[`MEMC_PAGE_BITS-1:16],1'b0,ih_ppl_te_page_num[14:12]} :
                                                          rxcmd_invalid_addr_row17_16 ? {ih_ppl_te_page_num[`MEMC_PAGE_BITS-1:17],1'b0,ih_ppl_te_page_num[15:12]} :
                                                          ih_ppl_te_page_num[`MEMC_PAGE_BITS-1:12];

      assign ih_ppl_te_page_num_corr[11:0]                 = ih_ppl_te_page_num[11:0];
      assign ih_yy_page_num_corr[`MEMC_PAGE_BITS-1:12] =
                                                          rxcmd_invalid_addr_row13_12 ? {ih_yy_page_num[`MEMC_PAGE_BITS-1:14],2'b10} :
                                                          rxcmd_invalid_addr_row14_13 ? {ih_yy_page_num[`MEMC_PAGE_BITS-1:14],1'b0,ih_yy_page_num[12]} :
                                                          rxcmd_invalid_addr_row15_14 ? {ih_yy_page_num[`MEMC_PAGE_BITS-1:15],1'b0,ih_yy_page_num[13:12]} :
                                                          rxcmd_invalid_addr_row16_15 ? {ih_yy_page_num[`MEMC_PAGE_BITS-1:16],1'b0,ih_yy_page_num[14:12]} :
                                                          rxcmd_invalid_addr_row17_16 ? {ih_yy_page_num[`MEMC_PAGE_BITS-1:17],1'b0,ih_yy_page_num[15:12]} :
                                                          ih_yy_page_num[`MEMC_PAGE_BITS-1:12];

      assign ih_yy_page_num_corr[11:0]                 = ih_yy_page_num[11:0];

      assign rxcmd_invalid_addr = rxcmd_invalid_addr_row13_12 || rxcmd_invalid_addr_row14_13 || rxcmd_invalid_addr_row15_14 || rxcmd_invalid_addr_row16_15 || rxcmd_invalid_addr_row17_16
                                  ;
                                  

// ccx_cond:;;10; Redundant for now. 8B mode is not supported.
assign bg_b16_addr_mode = reg_ddrc_lpddr5 && (reg_ddrc_bank_org != {{($bits(reg_ddrc_bank_org)-1){1'b0}},1'b1});




ih_core_in_if
      #(
   .WRCMD_ENTRY_BITS    (WRCMD_ENTRY_BITS),
   .CORE_ADDR_WIDTH     (CORE_ADDR_WIDTH),
   .IH_TAG_WIDTH        (IH_TAG_WIDTH),
   .CMD_LEN_BITS        (CMD_LEN_BITS),
   .WDATA_PTR_BITS      (WDATA_PTR_BITS),
  .REFRESH_EN_BITS      (0),
  .WDATA_MASK_FULL_BITS (0),
  .CMD_TYPE_BITS        (CMD_TYPE_BITS) )

  ih_core_in_if(

  .co_ih_clk            (co_ih_clk),
  .core_ddrc_rstn       (core_ddrc_rstn),

  .hif_cmd_valid        (hif_cmd_valid),
  .hif_cmd_type         (hif_cmd_type),
  .hif_cmd_addr         (mapped_addr),
  .hif_cmd_token        (hif_cmd_token),
  .hif_cmd_pri          (hif_cmd_pri),
  .hif_cmd_length       (hif_cmd_length),
  .hif_cmd_wdata_ptr    (hif_cmd_wdata_ptr),
  .hif_cmd_autopre      (hif_cmd_autopre),
  .wu_ih_flow_cntrl_req (wu_ih_flow_cntrl_req),
  .input_fifo_full      (input_fifo_full),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in ih_assertions module and under different `ifdefs.
  .input_fifo_empty     (input_fifo_empty),
//spyglass enable_block W528
  .ih_in_busy           (ih_in_busy),
  .hif_cmd_stall       (hif_cmd_stall),
  .te_ih_retry         (te_ih_core_in_stall),
  .ih_fifo_rd_empty    (ih_fifo_rd_empty),
  .ih_fifo_wr_empty    (ih_fifo_wr_empty),

  .rxcmd_addr_dup      (rxcmd_addr_dup),

  .rxcmd_valid         (rxcmd_valid),
  .rxcmd_addr          (rxcmd_addr),
  .rxcmd_type          (rxcmd_type),
  .rxcmd_token         (rxcmd_token),
  .rxcmd_autopre       (rxcmd_autopre),
  .rxcmd_pri           (rxcmd_pri),
  .rxcmd_length        (rxcmd_length),
  .rxcmd_wdata_ptr     (ppl_rxcmd_wdata_ptr),  //to ih-te pipeline
  .reg_ddrc_ecc_type   (reg_ddrc_ecc_type)
  
  );


ih_core_out_if
      #(
  .RDCMD_ENTRY_BITS    (RDCMD_ENTRY_BITS),
  .WRCMD_ENTRY_BITS    (WRCMD_ENTRY_BITS),
  .WRECCCMD_ENTRY_BITS (WRECCCMD_ENTRY_BITS),
  .RMW_TYPE_BITS       (RMW_TYPE_BITS),
  .WDATA_PTR_BITS      (WDATA_PTR_BITS),
  .CMD_TYPE_BITS       (CMD_TYPE_BITS)   )

  ih_core_out_if(

  .co_ih_clk                (co_ih_clk),
  .core_ddrc_rstn           (core_ddrc_rstn),

  .rxcmd_wdata_ptr          (rxcmd_wdata_ptr),   //from ih-te pipeline 
  .ih_te_rd_valid           (ih_te_rd_valid),
  .ih_te_wr_valid           (ih_te_wr_valid),
  .ih_te_wr_valid_addr_err  (ih_te_wr_valid_addr_err),
  .ih_te_hi_pri             (ih_te_hi_pri_int[1]),  // only connecting the upper bit in order to keep the logic in ih_core_out_if unchanged
  .te_ih_rd_retry           (te_ih_retry),
  .te_ih_wr_retry           (te_ih_retry),
  .wr_fifo_fill_level       (wr_fifo_fill_level),
  .lpr_fifo_fill_level      (lpr_fifo_fill_level),
  .hpr_fifo_fill_level      (hpr_fifo_fill_level),
  .dh_ih_dis_hif            (dh_ih_dis_hif),
  .dh_ih_lpr_num_entries    (dh_ih_lpr_num_entries),


  .input_fifo_full_rd       (input_fifo_full),
  .input_fifo_full_wr       (input_fifo_full),
  .gsfsm_sr_co_if_stall     (gsfsm_sr_co_if_stall),
  .hif_rcmd_stall           (hif_rcmd_stall),
  .hif_wcmd_stall           (hif_wcmd_stall),
  .hif_wdata_ptr            (hif_wdata_ptr),
  .hif_wdata_ptr_valid      (hif_wdata_ptr_valid),
  .hif_wdata_ptr_addr_err   (hif_wdata_ptr_addr_err),
  .hif_lpr_credit           (hif_lpr_credit[0]),
  .hif_hpr_credit           (hif_hpr_credit[0]),
  .hif_wr_credit            (hif_wr_credit),
  .co_ih_lpr_num_entries_changed   (co_ih_lpr_num_entries_changed)
  );



ih_address_map_wrapper
 
       #(
                .AM_DCH_WIDTH           (AM_DCH_WIDTH     )
               ,.AM_CS_WIDTH            (AM_CS_WIDTH      )
               ,.AM_CID_WIDTH           (AM_CID_WIDTH     )
               ,.AM_BANK_WIDTH          (AM_BANK_WIDTH    )
               ,.AM_BG_WIDTH            (AM_BG_WIDTH      )
               ,.AM_ROW_WIDTH           (AM_ROW_WIDTH     )
               ,.AM_COL_WIDTH_H         (AM_COL_WIDTH_H   )
               ,.AM_COL_WIDTH_L         (AM_COL_WIDTH_L   )
        )
  ih_address_map_wrapper
        (
        .bg_b16_addr_mode               (bg_b16_addr_mode),
        .am_block                       (mapped_block_num),
        .am_critical_dword              (critical_dword),
        .am_row                         (mapped_page_num),
        .am_bg_bank                     (mapped_bg_bank_num),

        .am_cpu_address                 (hif_cmd_addr[`MEMC_HIF_ADDR_WIDTH-1:0]),

        .am_bs_offset_bit0              (dh_ih_addrmap_bank_b0),
        .am_bs_offset_bit1              (dh_ih_addrmap_bank_b1),
        .am_bs_offset_bit2              (dh_ih_addrmap_bank_b2),
        .am_bg_offset_bit0              (dh_ih_addrmap_bg_b0),
        .am_bg_offset_bit1              (dh_ih_addrmap_bg_b1),
        .am_row_offset_bit0             (dh_ih_addrmap_row_b0),
        .am_row_offset_bit1             (dh_ih_addrmap_row_b1),
        .am_row_offset_bit2             (dh_ih_addrmap_row_b2),
        .am_row_offset_bit3             (dh_ih_addrmap_row_b3),
        .am_row_offset_bit4             (dh_ih_addrmap_row_b4),
        .am_row_offset_bit5             (dh_ih_addrmap_row_b5),
        .am_row_offset_bit6             (dh_ih_addrmap_row_b6),
        .am_row_offset_bit7             (dh_ih_addrmap_row_b7),
        .am_row_offset_bit8             (dh_ih_addrmap_row_b8),
        .am_row_offset_bit9             (dh_ih_addrmap_row_b9),
        .am_row_offset_bit10            (dh_ih_addrmap_row_b10),
        .am_row_offset_bit11            (dh_ih_addrmap_row_b11),
        .am_row_offset_bit12            (dh_ih_addrmap_row_b12),
        .am_row_offset_bit13            (dh_ih_addrmap_row_b13),
        .am_row_offset_bit14            (dh_ih_addrmap_row_b14),
        .am_row_offset_bit15            (dh_ih_addrmap_row_b15),
        .am_row_offset_bit16            (dh_ih_addrmap_row_b16),
        .am_row_offset_bit17            (dh_ih_addrmap_row_b17),
        .am_column_offset_bit3          (dh_ih_addrmap_col_b3),
        .am_column_offset_bit4          (dh_ih_addrmap_col_b4),
        .am_column_offset_bit5          (dh_ih_addrmap_col_b5),
        .am_column_offset_bit6          (dh_ih_addrmap_col_b6),
        .am_column_offset_bit7          (dh_ih_addrmap_col_b7),
        .am_column_offset_bit8          (dh_ih_addrmap_col_b8),
        .am_column_offset_bit9          (dh_ih_addrmap_col_b9),
        .am_column_offset_bit10         (dh_ih_addrmap_col_b10)

//I/O for het rank mapping
);

ih_te_if
      #(
  .IH_TAG_WIDTH      (IH_TAG_WIDTH),
  .CMD_LEN_BITS      (CMD_LEN_BITS),
  .RMW_TYPE_BITS     (RMW_TYPE_BITS),
  .CMD_TYPE_BITS     (CMD_TYPE_BITS)    )

  ih_te_if (

  .bg_b16_addr_mode               (bg_b16_addr_mode),

  // from core_if
  .rxcmd_valid                    (rxcmd_valid),
  .rxcmd_type                     (rxcmd_type),
  .rxcmd_token                    (rxcmd_token),
  .rxcmd_autopre                  (rxcmd_autopre),
  .rxcmd_pri                      (rxcmd_pri),
  .rxcmd_length                   (rxcmd_length),
  .rxcmd_invalid_addr             (rxcmd_invalid_addr),

  // Address from address_map module
  .am_bg_bank                     (mapped_bg_bank_num_to_te[`MEMC_BG_BANK_BITS-1:0]),
  .am_row                         (mapped_page_num_to_te[`MEMC_PAGE_BITS-1:0]),
  .am_block                       (mapped_block_num_to_te),
  .am_critical_dword              (critical_dword_to_te),


  // outputs for TE
  .ih_te_rd_valid       (ih_ppl_te_rd_valid),   
  .ih_te_wr_valid       (ih_ppl_te_wr_valid),   
  .ih_wu_wr_valid       (ih_ppl_wu_wr_valid),   
  .ih_te_rd_valid_addr_err (ih_ppl_te_rd_valid_addr_err),  
  .ih_te_wr_valid_addr_err (ih_ppl_te_wr_valid_addr_err),  
  .ih_te_rd_length      (ih_ppl_te_rd_length),  
  .ih_te_rd_tag         (ih_ppl_te_rd_tag),     
  .ih_te_rmwtype        (ih_ppl_te_rmwtype),    
  .ih_te_hi_pri         (ih_ppl_te_hi_pri),     
  .ih_te_hi_pri_int     (ih_ppl_te_hi_pri_int), 

  .ih_te_autopre        (ih_ppl_te_autopre),    
  .ih_te_bankgroup_num  (ih_ppl_te_bankgroup_num),
  .ih_te_bg_bank_num    (ih_ppl_te_bg_bank_num), 
  .ih_te_bank_num       (ih_ppl_te_bank_num), 
  .ih_te_page_num       (ih_ppl_te_page_num), 
  .ih_te_block_num      (ih_ppl_te_block_num), 
  .ih_te_critical_dword (ih_ppl_te_critical_dword),
  .ih_wu_critical_dword (ih_ppl_wu_critical_dword)
);


ih_be_if
  ih_be_if (

  // from core_if
  .ih_te_rd_valid           (ih_te_rd_valid),
  .ih_te_hi_pri             (ih_te_hi_pri),



  // outputs for BE
  .ih_be_hi_pri_rd_xact     (ih_be_hi_pri_rd_xact)
  );






        assign ih_be_bg_bank_num_rd = ih_yy_bg_bank_num;
////        `ifndef MEMC_LPDDR3
////        assign ih_be_page_num   = ih_yy_page_num;
////        `else
        assign ih_be_page_num       = ih_yy_page_num_corr;
////        `endif






// for BE, some come from wr
      assign ih_be_bg_bank_num_wr= ih_te_wr_bg_bank_num;

ih_fifo_if
  #(
  .RDCMD_ENTRY_BITS    (RDCMD_ENTRY_BITS),
  .WRCMD_ENTRY_BITS    (WRCMD_ENTRY_BITS),
  .WRECCCMD_ENTRY_BITS (WRECCCMD_ENTRY_BITS),
  .WRCMD_ENTRY_BITS_IE (WRCMD_ENTRY_BITS_IE),
  .RMW_TYPE_BITS       (RMW_TYPE_BITS) )    
  
  ih_fifo_if (

  .co_ih_clk                (co_ih_clk),
  .core_ddrc_rstn           (core_ddrc_rstn),
  // inputs from te_if
  .rd_valid                 (ih_te_rd_valid),
  .wr_valid                 (ih_te_wr_valid),
        .rd_valid_addr_err              (ih_te_rd_valid_addr_err),
        .wr_valid_addr_err              (ih_te_wr_valid_addr_err),
        .rmwtype                        (ih_te_rmwtype),
  .pri                      (ih_te_hi_pri_int),
  .rd_entry                 (ih_te_rd_entry),
  .wr_entry                 (ih_te_wr_entry),
  .lo_rd_prefer             (ih_te_lo_rd_prefer),
  .wr_prefer                (ih_te_wr_prefer),
  .hi_rd_prefer             (ih_te_hi_rd_prefer),

  .rd_retry                 (te_ih_retry),
  .wr_retry                 (te_ih_retry),
  .wr_combine               (te_ih_wr_combine),

  
  .free_rd_entry            (te_ih_free_rd_entry),
  .free_rd_entry_valid      (te_ih_free_rd_entry_valid),
  .free_wr_entry            (mr_ih_free_wr_entry),
  .free_wr_entry_valid      (mr_ih_free_wr_entry_valid),
  .wr_cam_full              (wr_cam_full_unused ),
// TS Interface
  .any_xact                 (ih_yy_xact_valid),
  .rdlow_empty              (ih_gs_rdlow_empty),
  .wr_empty                 (ih_gs_wr_empty),
  .rdhigh_empty             (ih_gs_rdhigh_empty),
  .lpr_fifo_fill_level      (lpr_fifo_fill_level),
  .hpr_fifo_fill_level      (hpr_fifo_fill_level),
  .wr_fifo_fill_level       (wr_fifo_fill_level),


  .dh_ih_lpr_num_entries    (dh_ih_lpr_num_entries),

  .ih_dh_lpr_q_depth        (ih_dh_lpr_q_depth),
  .ih_dh_hpr_q_depth        (ih_dh_hpr_q_depth),
  .ih_dh_wr_q_depth         (ih_dh_wr_q_depth)
);



ih_te_pipeline
 #(
     .CMD_LEN_BITS   (CMD_LEN_BITS)
    ,.IH_TAG_WIDTH   (IH_TAG_WIDTH)
    ,.RMW_TYPE_BITS  (RMW_TYPE_BITS)
    ,.WDATA_PTR_BITS (WDATA_PTR_BITS)

)
ih_te_pipeline(

   .te_ih_retry              (te_ih_retry)
  ,.te_ppl_ih_stall          (te_ppl_ih_stall)



   //data out of pipeline
  ,.rxcmd_wdata_ptr      (rxcmd_wdata_ptr)
  ,.ih_te_rd_valid       (i_ih_te_rd_valid)   
  ,.ih_te_wr_valid       (i_ih_te_wr_valid)   
  ,.ih_wu_wr_valid       (i_ih_wu_wr_valid)   
  ,.ih_te_rd_valid_addr_err (i_ih_te_rd_valid_addr_err)  
  ,.ih_te_wr_valid_addr_err (i_ih_te_wr_valid_addr_err)  
  ,.ih_te_rd_length      (i_ih_te_rd_length)  
  ,.ih_te_rd_tag         (i_ih_te_rd_tag)     
  ,.ih_te_rmwtype        (i_ih_te_rmwtype)    
  ,.ih_te_hi_pri         (i_ih_te_hi_pri)     
  ,.ih_te_hi_pri_int     (i_ih_te_hi_pri_int) 

  ,.ih_te_autopre        (i_ih_te_autopre)    
  ,.ih_te_bankgroup_num  (i_ih_te_bankgroup_num)
  ,.ih_te_bg_bank_num    (i_ih_te_bg_bank_num) 
  ,.ih_te_bank_num       (i_ih_te_bank_num) 
  ,.ih_te_page_num       (i_ih_te_page_num_corr) 
  ,.ih_te_block_num      (i_ih_te_block_num) 
  ,.ih_te_critical_dword (i_ih_te_critical_dword)
  ,.ih_wu_critical_dword (i_ih_wu_critical_dword)


   //data in of pipeline
  ,.ppl_rxcmd_wdata_ptr      (ppl_rxcmd_wdata_ptr)
  ,.ih_ppl_te_rd_valid       (ih_ppl_te_rd_valid)   
  ,.ih_ppl_te_wr_valid       (ih_ppl_te_wr_valid)   
  ,.ih_ppl_wu_wr_valid       (ih_ppl_wu_wr_valid)   
  ,.ih_ppl_te_rd_valid_addr_err (ih_ppl_te_rd_valid_addr_err)  
  ,.ih_ppl_te_wr_valid_addr_err (ih_ppl_te_wr_valid_addr_err)  
  ,.ih_ppl_te_rd_length      (ih_ppl_te_rd_length)  
  ,.ih_ppl_te_rd_tag         (ih_ppl_te_rd_tag)     
  ,.ih_ppl_te_rmwtype        (ih_ppl_te_rmwtype)    
  ,.ih_ppl_te_hi_pri         (ih_ppl_te_hi_pri)     
  ,.ih_ppl_te_hi_pri_int     (ih_ppl_te_hi_pri_int) 

  ,.ih_ppl_te_autopre        (ih_ppl_te_autopre)    
  ,.ih_ppl_te_bankgroup_num  (ih_ppl_te_bankgroup_num)
  ,.ih_ppl_te_bg_bank_num    (ih_ppl_te_bg_bank_num) 
  ,.ih_ppl_te_bank_num       (ih_ppl_te_bank_num) 
  ,.ih_ppl_te_page_num       (ih_ppl_te_page_num_corr) 
  ,.ih_ppl_te_block_num      (ih_ppl_te_block_num) 
  ,.ih_ppl_te_critical_dword (ih_ppl_te_critical_dword)
  ,.ih_ppl_wu_critical_dword (ih_ppl_wu_critical_dword)



);

ih_retry_mux
 #(
    //------------------------------ PARAMETERS ------------------------------------
      .RMW_TYPE_BITS (RMW_TYPE_BITS)
//fdef DDRCTL_ANY_RETRY
     ,.RETRY_TIMES_WIDTH (RETRY_TIMES_WIDTH)
//`ifdef DDRCTL_RD_CRC_RETRY
     ,.CMD_LEN_BITS      (CMD_LEN_BITS)
     ,.IH_TAG_WIDTH      (IH_TAG_WIDTH)
     ,.RD_LATENCY_BITS   (`UMCTL2_XPI_RQOS_TW)
     ,.WR_LATENCY_BITS   (`UMCTL2_XPI_WQOS_TW)
//`endif
//`endif
    ) u_ih_retry_mux
    (
    //-------------------------- INPUTS AND OUTPUTS --------------------------------  
   //data out of pipeline
   .ih_te_rd_valid      (ih_te_rd_valid)
  ,.ih_te_wr_valid      (ih_te_wr_valid)
  ,.ih_wu_wr_valid      (ih_wu_wr_valid)
  ,.ih_te_rmwtype       (ih_te_rmwtype)    
  ,.ih_te_wr_valid_addr_err   (ih_te_wr_valid_addr_err)
  ,.ih_te_rd_valid_addr_err   (ih_te_rd_valid_addr_err)
  ,.ih_te_hi_pri        (ih_te_hi_pri)
  ,.ih_te_hi_pri_int    (ih_te_hi_pri_int)
  ,.ih_te_autopre       (ih_te_autopre)   // auto precharge enable flag
  ,.ih_te_bankgroup_num  (ih_te_bankgroup_num)
  ,.ih_te_bg_bank_num    (ih_te_bg_bank_num   ) 
  ,.ih_te_bank_num       (ih_te_bank_num      ) 
  ,.ih_te_page_num       (ih_te_page_num_corr ) 
  ,.ih_te_block_num      (ih_te_block_num     ) 
  ,.ih_te_critical_dword (ih_te_critical_dword)      // for reads only, critical word within a block - not currently supported
  ,.ih_wu_critical_dword (ih_wu_critical_dword)      // for reads only, critical word within a block - not currently supported
  ,.ih_te_wr_entry_rmw   (ih_te_wr_entry_rmw  )
  ,.ih_te_rd_length      (ih_te_rd_length     )
  ,.ih_te_rd_tag         (ih_te_rd_tag        )

   //data in from IH
  ,.i_ih_te_rd_valid     (i_ih_te_rd_valid)
  ,.i_ih_te_wr_valid     (i_ih_te_wr_valid)
  ,.i_ih_wu_wr_valid     (i_ih_wu_wr_valid)
  ,.i_ih_te_rmwtype      (i_ih_te_rmwtype)    
  ,.i_ih_te_wr_valid_addr_err (i_ih_te_wr_valid_addr_err)
  ,.i_ih_te_rd_valid_addr_err (i_ih_te_rd_valid_addr_err)
  ,.i_ih_te_hi_pri       (i_ih_te_hi_pri)
  ,.i_ih_te_hi_pri_int   (i_ih_te_hi_pri_int)
  ,.i_ih_te_autopre      (i_ih_te_autopre)    // auto precharge enable flag
  ,.i_ih_te_bankgroup_num(i_ih_te_bankgroup_num)
  ,.i_ih_te_bg_bank_num       (i_ih_te_bg_bank_num    )
  ,.i_ih_te_bank_num          (i_ih_te_bank_num       )
  ,.i_ih_te_page_num          (i_ih_te_page_num_corr  )
  ,.i_ih_te_block_num         (i_ih_te_block_num      )
  ,.i_ih_te_critical_dword    (i_ih_te_critical_dword )  // for reads only, critical word within a block - not currently supported
  ,.i_ih_wu_critical_dword    (i_ih_wu_critical_dword )  // for reads only, critical word within a block - not currently supported
  ,.i_ih_te_wr_entry          (ih_te_wr_entry[WRCMD_ENTRY_BITS-1:0]) // used to generate ih_te_wr_entry_rmw
  ,.i_ih_te_rd_length         (i_ih_te_rd_length      )
  ,.i_ih_te_rd_tag            (i_ih_te_rd_tag         )

);




`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

ih_assertions
  #(
  .RDCMD_ENTRY_BITS    (RDCMD_ENTRY_BITS),
  .WRCMD_ENTRY_BITS    (WRCMD_ENTRY_BITS_IE),
  .CORE_ADDR_WIDTH     (CORE_ADDR_WIDTH),
  .IH_TAG_WIDTH        (IH_TAG_WIDTH),
  .CMD_LEN_BITS        (CMD_LEN_BITS),
  .RMW_TYPE_BITS       (RMW_TYPE_BITS),
  .WDATA_PTR_BITS      (WDATA_PTR_BITS),
  .CMD_TYPE_BITS       (CMD_TYPE_BITS)
)

  ih_assertions(

        .co_ih_clk                      (co_ih_clk),
        .core_ddrc_rstn                 (core_ddrc_rstn),

        .dh_ih_operating_mode           (dh_ih_operating_mode),
        .hif_cmd_valid                  (hif_cmd_valid),
        .hif_cmd_type                   (hif_cmd_type),
        .hif_cmd_addr                   (hif_cmd_addr),
        .hif_cmd_token                  (hif_cmd_token),
        .hif_cmd_pri                    (hif_cmd_pri),
        .hif_cmd_length                 (hif_cmd_length),
        .hif_cmd_wdata_ptr              (hif_cmd_wdata_ptr),

        .hif_cmd_stall                  (hif_cmd_stall),
        .hif_wdata_ptr                  (hif_wdata_ptr),
        .hif_wdata_ptr_valid            (hif_wdata_ptr_valid),
        .hif_lpr_credit                 (hif_lpr_credit),
        .hif_hpr_credit                 (hif_hpr_credit),
        .hif_wr_credit                  (hif_wr_credit),

        // WU Interface
        .wu_ih_flow_cntrl_req           (wu_ih_flow_cntrl_req),

        // outputs for TE
        .ih_te_rd_valid                 (ih_te_rd_valid),
        .ih_te_wr_valid                 (ih_te_wr_valid),
        .ih_te_rd_valid_addr_err        (ih_te_rd_valid_addr_err),
        .ih_te_wr_valid_addr_err        (ih_te_wr_valid_addr_err),
        .ih_te_rd_length                (ih_te_rd_length),
        .ih_te_rd_tag                   (ih_te_rd_tag),
        .ih_te_rmwtype                  (ih_te_rmwtype),
        .ih_te_bg_bank_num              (ih_te_bg_bank_num),
        .ih_te_page_num                 (ih_te_page_num_corr),
        .ih_te_block_num                (ih_te_block_num),
        .ih_te_critical_dword           (ih_te_critical_dword),
        .ih_te_rd_entry                 (ih_te_rd_entry),
        .ih_te_wr_entry                 (ih_te_wr_entry),
        .ih_te_lo_rd_prefer             (ih_te_lo_rd_prefer),
        .ih_te_wr_prefer                (ih_te_wr_prefer),

        .ih_te_hi_pri                   (ih_te_hi_pri),
        .ih_te_hi_rd_prefer             (ih_te_hi_rd_prefer),

        .ih_gs_rdhigh_empty             (ih_gs_rdhigh_empty),
        .ih_be_hi_pri_rd_xact           (ih_be_hi_pri_rd_xact),
        .dh_ih_lpr_num_entries          (dh_ih_lpr_num_entries),

        .ih_be_bg_bank_num              (ih_be_bg_bank_num_rd),
        .ih_be_page_num                 (ih_be_page_num),

        .te_ih_free_rd_entry            (te_ih_free_rd_entry),
        .te_ih_free_rd_entry_valid      (te_ih_free_rd_entry_valid),
        .mr_ih_free_wr_entry            (mr_ih_free_wr_entry),
        .mr_ih_free_wr_entry_valid      (mr_ih_free_wr_entry_valid),
        .te_ih_retry                    (te_ih_retry),
        .te_ih_retry_i                  (te_ih_retry_i),
        .te_ih_core_in_stall            (te_ih_core_in_stall),
        .te_ih_wr_combine               (te_ih_wr_combine)
       ,.reg_ddrc_ecc_type              (reg_ddrc_ecc_type)
);


`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule
