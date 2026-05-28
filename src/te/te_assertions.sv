//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_assertions.sv#1 $
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

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//                              Description
//
// description  : this module implements system verilog assertions to check
//      that te is behaving properly.
//
// ----------------------------------------------------------------------------


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

`include "DWC_ddrctl_all_defs.svh"
module te_assertions #(
    //-------------------------------- parameters ----------------------------------
     parameter   CHANNEL_NUM       = 0 
    ,parameter   RANKBANK_BITS     = `UMCTL2_LRANK_BITS + `MEMC_BG_BANK_BITS 
    ,parameter   RD_CAM_ADDR_BITS  = `MEMC_WRCMD_ENTRY_BITS 
    ,parameter   WR_CAM_ADDR_BITS  = `MEMC_WRCMD_ENTRY_BITS 
    ,parameter   MAX_CAM_ADDR_BITS = 0
    ,parameter   PAGE_BITS         = `MEMC_PAGE_BITS 
    ,parameter   BLK_BITS          = `MEMC_BLK_BITS      // write CAM only
    ,parameter   BSM_BITS          = `UMCTL2_BSM_BITS
    ,parameter   OTHER_RD_ENTRY_BITS = 30                // override: # of other bits to track in read cam
    ,parameter   OTHER_WR_ENTRY_BITS = 1                 // override: # of other bits to track in write cam
    ,parameter   OTHER_RD_RMW_LSB        = 3             // LSB of RMW type for RD_OTHER field
    ,parameter   OTHER_RD_RMW_TYPE_BITS  = 2             // no if bits of RMW type for RD_OTHER field
    ,parameter   TOTAL_BANKS       = 1 << RANKBANK_BITS 
    ,parameter   TOTAL_BSMS        = `UMCTL2_NUM_BSM
    ,parameter   RD_CAM_ENTRIES    = 1 << RD_CAM_ADDR_BITS 
    ,parameter   WR_CAM_ENTRIES    = 1 << WR_CAM_ADDR_BITS 
    ,parameter   IE_RD_TYPE_BITS   = 2 // Override
    ,parameter   IE_WR_TYPE_BITS   = 2 // Override
    ,parameter   BT_BITS           = 1 // Override
    ,parameter   NO_OF_BT          = 1 // Override
    ,parameter   IE_BURST_NUM_BITS = 1 // Override
    ,parameter   IE_UNIQ_BLK_BITS  = 1 // Override
    ,parameter   IE_UNIQ_BLK_LSB   = 1 // Override
    ,parameter   IE_UNIQ_RBK_BITS  = 1 // Override
    ,parameter   RANK_BITS         = `UMCTL2_LRANK_BITS
    ,parameter   BG_BANK_BITS      = `MEMC_BG_BANK_BITS        // max supported banks groups per rank
    ,parameter   AM_COL_WIDTH_H    = 5
    ,parameter   AM_COL_WIDTH_L    = 4
    )
    
                     (
    //---------------------------- inputs and outputs ------------------------------    
     input                                    core_ddrc_rstn          // asynchronous de-assert active low reset
    ,input                                    co_te_clk               // clock
    ,input [RD_CAM_ADDR_BITS-1:0]             ih_te_rd_entry_num      // read CAM entry number
    ,input                                    ih_te_rd_valid          // valid read from IH
    ,input [WR_CAM_ADDR_BITS-1:0]             ih_te_wr_entry_num      // write CAM entry number
    ,input                                    ih_te_wr_valid          // valid write to IH
    ,input [RANKBANK_BITS-1:0]                ih_te_wr_rankbank_num   // rank & bank from IH
    ,input [PAGE_BITS-1:0]                    ih_te_wr_page_num       // page (row) number from IH
    ,input [BLK_BITS-1:0]                     ih_te_wr_block_num      // block number from IH
    ,input [RANKBANK_BITS-1:0]                ih_te_rd_rankbank_num   // rank & bank from IH
    ,input [PAGE_BITS-1:0]                    ih_te_rd_page_num       // page (row) number from IH
    ,input [BLK_BITS-1:0]                     ih_te_rd_block_num      // block number from IH
    ,input [OTHER_RD_ENTRY_BITS-1:0]          ih_te_rd_other_fields   // everything else TE needs to track in the read CAM
    ,input [OTHER_WR_ENTRY_BITS-1:0]          ih_te_wr_other_fields   // everything else TE needs to track in the read CAM    
    ,input   [MAX_CAM_ADDR_BITS-1:0]          os_te_rdwr_entry        // entry number for read write 
    ,input   [RD_CAM_ADDR_BITS-1:0]           te_rd_act_entry         // entry number for read activate
    ,input   [WR_CAM_ADDR_BITS-1:0]           te_wr_act_entry         // entry number for write activate
    ,input                                    te_rd_flush             // read flush for address collision
    ,input                                    te_rd_flush_due_wr      // read flush for address collision due to write
    ,input                                    te_rd_flush_due_rd      // read flush for address collision due to read
    ,input   [RD_CAM_ENTRIES -1:0]            te_rd_entry_valid       // valid read entry matching bank from CAM search
    ,input   [RD_CAM_ADDR_BITS-1:0]           te_sel_rd_entry         // replacement entry selected from read CAM
    ,input                                    te_wr_flush             // write flush for address collision
    ,input                                    te_wr_flush_due_wr      // write flush for address collision due to write
    ,input                                    te_wr_flush_due_rd      // write flush for address collision due to read
    ,input                                    te_wr_flush_started     // write flush underway for collision

    ,input   [WR_CAM_ADDR_BITS-1:0]           te_wr_col_entry         // colliding entry when colliding with a read
    ,input   [RD_CAM_ADDR_BITS-1:0]           te_rd_col_entry         // colliding entry when colliding with a read
    ,input   [BSM_BITS-1:0]                   te_os_hi_bsm_hint       // high priority read BSM hint to TS
    ,input   [BSM_BITS-1:0]                   te_os_lo_bsm_hint       // low (no) priority read BSM hint to TS
    ,input   [BSM_BITS-1:0]                   te_os_wr_bsm_hint       // write BSM hint to TS
    ,input   [WR_CAM_ENTRIES -1:0]            te_wr_entry_valid       // valid write entry matching bank from CAM search
    ,input   [WR_CAM_ADDR_BITS-1:0]           te_sel_wr_entry         // replacement entry selected from write CAM
    ,input                                    te_yy_wr_combine        // write from ih being combined with existing entry
    ,input   [WR_CAM_ENTRIES-1:0]             te_wr_entry_we_bw_loaded// Entry is WE_BW (inline ECC) and loaded
    ,input                                    gs_te_op_is_rd          // read operation from GS
    ,input                                    gs_te_op_is_wr          // write operation from GS
    ,input                                    gs_te_op_is_precharge   // precharge operation from GS
    ,input                                    gs_te_op_is_activate    // activate operation from GS
    ,input   [BSM_BITS-1:0]                   gs_te_bsm_num4rdwr      // BSM number for above operations
    ,input   [BSM_BITS-1:0]                   gs_te_bsm_num4act       // BSM number for above operations
    ,input   [BSM_BITS-1:0]                   gs_te_bsm_num4pre       // BSM number for above operations
    ,input [BLK_BITS-1:0]                     te_pi_rd_addr_blk          // was part of te_pi_rd_addr
    ,input [OTHER_RD_ENTRY_BITS-1:0]          te_pi_rd_other_fields_rd   // everything else we need to keep track of in the cam
    ,input [PAGE_BITS-1:0]                    ts_act_page                // was part of te_pi_wr_addr
    ,input [BLK_BITS-1:0]                     te_pi_wr_addr_blk          // was part of te_pi_wr_addr
    ,input [OTHER_WR_ENTRY_BITS-1:0]          te_pi_wr_other_fields_wr   // everything else we need to keep track of in the cam
    ,input [RD_CAM_ENTRIES-1:0]               te_rd_page_hit 
    ,input [WR_CAM_ENTRIES-1:0]               te_wr_page_hit 
    ,input                                    te_ih_rd_retry 
    ,input                                    te_ih_wr_retry 
    ,input                                    ts_te_autopre 
    ,input [TOTAL_BSMS*PAGE_BITS-1:0]         rd_nxt_page_table 
    ,input [TOTAL_BSMS*PAGE_BITS-1:0]         wr_nxt_page_table 
    ,input                                    gs_te_wr_mode 
    ,input [RD_CAM_ENTRIES-1:0]               rd_nxt_entry_in_ntt 
    ,input [WR_CAM_ENTRIES-1:0]               wr_nxt_entry_in_ntt 
    ,input [TOTAL_BSMS-1:0]                   te_bs_rd_valid 
    ,input [TOTAL_BSMS-1:0]                   te_bs_wr_valid 
//     ,input                                    dh_te_dis_autopre_collide_opt
    ,input [TOTAL_BSMS*RD_CAM_ADDR_BITS-1:0]  te_os_rd_entry_table 
    ,input [TOTAL_BSMS*WR_CAM_ADDR_BITS-1:0]  te_os_wr_entry_table 
    ,input [RD_CAM_ENTRIES -1:0]              te_rd_entry_valid_cam 
    ,input [RD_CAM_ENTRIES -1:0]              te_rd_entry_loaded_cam 
    ,input [WR_CAM_ENTRIES -1:0]              te_wr_entry_valid_cam 
    ,input                                    ih_te_rd_autopre 
    ,input                                    ih_te_rd_autopre_org // Original (before masked) version
    ,input                                    ih_te_rd_rmw
    ,input                                    reg_ddrc_autopre_rmw
    ,input                                    ih_te_wr_autopre 
    ,input                                    dh_te_pageclose 
    ,input [7:0]                              dh_te_pageclose_timer 
//     ,input                                    te_pi_rd_autopre 
//     ,input                                    te_wr_autopre 
    ,input [BSM_BITS-1:0]                     te_be_bsm_num 
    ,input                                    rd_cam_delayed_autopre_update_fe
    ,input                                    wr_cam_delayed_autopre_update_fe
    ,input [WR_CAM_ENTRIES -1:0]              wr_cam_rd_and_wr_data_rdy
    ,input [WR_CAM_ENTRIES -1:0]              wr_cam_i_combine_match
    , input [1:0]                             reg_ddrc_data_bus_width

    ); 


//--------------------------- wires and registers ------------------------------

reg   [PAGE_BITS-1:0]                   page_table    [TOTAL_BANKS-1:0];
reg   [TOTAL_BANKS-1:0]                 pages_open;

reg   [RANKBANK_BITS-1:0]               te_rd_rankbanks      [RD_CAM_ENTRIES-1:0];
reg   [PAGE_BITS-1:0]                   te_rd_pages          [RD_CAM_ENTRIES-1:0];
reg   [BLK_BITS-1:0]                    te_rd_blocks         [RD_CAM_ENTRIES-1:0];
reg   [OTHER_RD_ENTRY_BITS-1:0]         te_rd_other_fields   [RD_CAM_ENTRIES-1:0];
reg   [RD_CAM_ENTRIES-1:0]              te_rd_entry_vld;
reg   [RD_CAM_ENTRIES-1:0]              te_rd_autopre;

reg   [RANKBANK_BITS-1:0]               te_wr_rankbanks      [WR_CAM_ENTRIES-1:0];
reg   [PAGE_BITS-1:0]                   te_wr_pages          [WR_CAM_ENTRIES-1:0];
reg   [BLK_BITS-1:0]                    te_wr_blocks         [WR_CAM_ENTRIES-1:0];
reg   [OTHER_WR_ENTRY_BITS-1:0]         te_wr_other_fields   [WR_CAM_ENTRIES-1:0];
reg   [WR_CAM_ENTRIES-1:0]              te_wr_entry_vld;
reg   [WR_CAM_ENTRIES-1:0]              te_wr_autopre_a;

reg                                     r_op_is_rd;            // flopped read command scheduled
reg                                     r_rd_flush;
reg                                     r2_rd_flush;
reg                                     r_rd_flush_due_rd;
reg                                     r2_rd_flush_due_rd;
reg                                     r_rd_flush_due_wr;
reg                                     r2_rd_flush_due_wr;
reg   [WR_CAM_ENTRIES-1:0]              r_rd_entry_bank_match; // valid entries matching bank search (1 bit per entry)

reg                                     r_op_is_wr;            // flopped write command scheduled
reg                                     r_wr_flush;
reg                                     r2_wr_flush;
reg                                     r_wr_flush_due_wr;
reg                                     r2_wr_flush_due_wr;
reg                                     r_wr_flush_due_rd;
reg                                     r2_wr_flush_due_rd;
reg   [WR_CAM_ENTRIES-1:0]              r_wr_entry_bank_match; // valid entries matching bank search (1 bit per entry)

reg   [WR_CAM_ADDR_BITS-1:0]            r_rd_col_entry;        // colliding entry in read CAM, flopped
reg   [WR_CAM_ADDR_BITS-1:0]            r_wr_col_entry;        // colliding entry in read CAM, flopped


reg   [RANKBANK_BITS-1:0]               r_ih_wr_rankbank_num;
reg   [PAGE_BITS-1:0]                   r_ih_wr_page_num;
reg   [BLK_BITS-1:0]                    r_ih_wr_block_num;
reg   [RANKBANK_BITS-1:0]               r_ih_rd_rankbank_num;
reg   [PAGE_BITS-1:0]                   r_ih_rd_page_num;
reg   [BLK_BITS-1:0]                    r_ih_rd_block_num;



//----------------------------- supporting logic -------------------------------
wire i_te_te_wr_flush = te_wr_flush;
wire i_te_te_rd_flush = te_rd_flush;
wire bypass_flush     = te_wr_flush;

wire  [RANKBANK_BITS-1:0]               te_be_rankbank_num;
wire  [RANKBANK_BITS-1:0]               te_os_hi_bank_hint;
wire  [RANKBANK_BITS-1:0]               te_os_lo_bank_hint;
wire  [RANKBANK_BITS-1:0]               te_os_wr_bank_hint;

    wire  [RANKBANK_BITS-1:0]               gs_te_bank_num4pre;
    wire  [RANKBANK_BITS-1:0]               gs_te_bank_num4rdwr;
    wire  [RANKBANK_BITS-1:0]               gs_te_bank_num4act;

    assign  gs_te_bank_num4pre  = gs_te_bsm_num4pre;
    assign  gs_te_bank_num4rdwr = gs_te_bsm_num4rdwr;
    assign  gs_te_bank_num4act  = gs_te_bsm_num4act;

    assign  te_be_rankbank_num  = te_be_bsm_num;
    assign  te_os_hi_bank_hint  = te_os_hi_bsm_hint;
    assign  te_os_lo_bank_hint  = te_os_lo_bsm_hint;
    assign  te_os_wr_bank_hint  = te_os_wr_bsm_hint;

/////////////////////////
// bypass determination
/////////////////////////
wire  i_op_is_act_bypass = 1'b0;

/////////////////////////
// page table maintenance
/////////////////////////

// valid entries in page table
always @ (posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    pages_open <= {TOTAL_BANKS{1'b0}};
  end else begin
   if (gs_te_op_is_activate)
     pages_open[gs_te_bank_num4act] <= 1'b1;
   if (gs_te_op_is_precharge)
     pages_open[gs_te_bank_num4pre] <= 1'b0;
    if ((gs_te_op_is_rd | gs_te_op_is_wr) & ts_te_autopre)
      pages_open[gs_te_bank_num4rdwr] <= 1'b0;
  end
end

// page numbers in page table
always @ (posedge co_te_clk) begin
    if (gs_te_op_is_activate)
  page_table[gs_te_bank_num4act] <= ts_act_page;
end

/////////////////////////
// te entries
/////////////////////////

// te entries valid
always @ (posedge co_te_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        te_rd_entry_vld         <= {RD_CAM_ENTRIES{1'b0}};
        te_wr_entry_vld         <= {WR_CAM_ENTRIES{1'b0}};
        r_op_is_rd              <= 1'b0;
        r_rd_flush              <= 1'b0;
        r2_rd_flush             <= 1'b0;
        r_rd_flush_due_rd       <= 1'b0;
        r2_rd_flush_due_rd      <= 1'b0;
        r_rd_flush_due_wr       <= 1'b0;
        r2_rd_flush_due_wr      <= 1'b0;
        r_rd_entry_bank_match   <= {RD_CAM_ENTRIES{1'b0}};
        r_op_is_wr              <= 1'b0;
        r_wr_flush              <= 1'b0;
        r2_wr_flush             <= 1'b0;
        r_wr_flush_due_wr       <= 1'b0;
        r2_wr_flush_due_wr      <= 1'b0;
        r_wr_flush_due_rd       <= 1'b0;
        r2_wr_flush_due_rd      <= 1'b0;
        r_wr_entry_bank_match   <= {WR_CAM_ENTRIES{1'b0}};
        r_ih_wr_rankbank_num    <= {RANKBANK_BITS{1'b0}};
        r_ih_wr_page_num        <= {PAGE_BITS{1'b0}};
        r_ih_wr_block_num       <= {BLK_BITS{1'b0}};
        r_ih_rd_rankbank_num    <= {RANKBANK_BITS{1'b0}};
        r_ih_rd_page_num        <= {PAGE_BITS{1'b0}};
        r_ih_rd_block_num       <= {BLK_BITS{1'b0}};
        r_rd_col_entry          <= {RD_CAM_ADDR_BITS{1'b0}};
        r_wr_col_entry          <= {WR_CAM_ADDR_BITS{1'b0}};

    end
    else begin
        // track valids
  if (ih_te_rd_valid & ~i_te_te_rd_flush)
      te_rd_entry_vld[ih_te_rd_entry_num] <= 1'b1;
  if (gs_te_op_is_rd)
      te_rd_entry_vld[os_te_rdwr_entry]     <= 1'b0;
  if (ih_te_wr_valid & ~i_te_te_wr_flush)
      te_wr_entry_vld[ih_te_wr_entry_num] <= 1'b1;
  if (gs_te_op_is_wr)
      te_wr_entry_vld[os_te_rdwr_entry]     <= 1'b0;
        // flop inputs from RTL
        r_rd_flush           <= te_rd_flush;
        r2_rd_flush          <= r_rd_flush;
        r_rd_flush_due_rd    <= te_rd_flush_due_rd;
        r2_rd_flush_due_rd   <= r_rd_flush_due_rd;
        r_rd_flush_due_wr    <= te_rd_flush_due_wr;
        r2_rd_flush_due_wr   <= r_rd_flush_due_wr;
        r_op_is_rd           <= gs_te_op_is_rd;
        r_rd_entry_bank_match<= te_rd_entry_valid;
        r_wr_flush           <= te_wr_flush;
        r_op_is_wr           <= gs_te_op_is_wr;
        r2_wr_flush          <= r_wr_flush;
        r_wr_flush_due_wr    <= te_wr_flush_due_wr;
        r2_wr_flush_due_wr   <= r_wr_flush_due_wr;
        r_wr_flush_due_rd    <= te_wr_flush_due_rd;
        r2_wr_flush_due_rd   <= r_wr_flush_due_rd;
        r_wr_entry_bank_match<= te_wr_entry_valid;
        r_ih_wr_rankbank_num    <= ih_te_wr_rankbank_num;
        r_ih_wr_page_num        <= ih_te_wr_page_num;
        r_ih_wr_block_num       <= ih_te_wr_block_num;
        r_ih_rd_rankbank_num    <= ih_te_rd_rankbank_num;
        r_ih_rd_page_num        <= ih_te_rd_page_num;
        r_ih_rd_block_num       <= ih_te_rd_block_num;
        r_rd_col_entry       <= te_rd_col_entry;
        r_wr_col_entry       <= te_wr_col_entry;


    end
end

// te entries
always @ (posedge co_te_clk) begin
  te_rd_rankbanks   [ih_te_rd_entry_num] <= ih_te_rd_valid ? ih_te_rd_rankbank_num   : te_rd_rankbanks   [ih_te_rd_entry_num];
  te_rd_pages       [ih_te_rd_entry_num] <= ih_te_rd_valid ? ih_te_rd_page_num       : te_rd_pages       [ih_te_rd_entry_num];
  te_rd_blocks      [ih_te_rd_entry_num] <= ih_te_rd_valid ? ih_te_rd_block_num      : te_rd_blocks      [ih_te_rd_entry_num];
  te_rd_other_fields[ih_te_rd_entry_num] <= ih_te_rd_valid ? ih_te_rd_other_fields   : te_rd_other_fields[ih_te_rd_entry_num];
  te_rd_autopre     [ih_te_rd_entry_num] <= ih_te_rd_valid ? ih_te_rd_autopre        : te_rd_autopre     [ih_te_rd_entry_num];

  te_wr_rankbanks   [ih_te_wr_entry_num] <= ih_te_wr_valid ? ih_te_wr_rankbank_num   : te_wr_rankbanks   [ih_te_wr_entry_num];
  te_wr_pages       [ih_te_wr_entry_num] <= ih_te_wr_valid ? ih_te_wr_page_num       : te_wr_pages       [ih_te_wr_entry_num];
  te_wr_blocks      [ih_te_wr_entry_num] <= ih_te_wr_valid ? ih_te_wr_block_num      : te_wr_blocks      [ih_te_wr_entry_num];
  te_wr_other_fields[ih_te_wr_entry_num] <= ih_te_wr_valid ? ih_te_wr_other_fields   : te_wr_other_fields[ih_te_wr_entry_num];
  te_wr_autopre_a     [ih_te_wr_entry_num] <= ih_te_wr_valid ? ih_te_wr_autopre        : te_wr_autopre_a     [ih_te_wr_entry_num];
end

//------------------------------------ properties ---------------------------------------
//////////////////
// read properties
//////////////////
property rd_page_open;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_rd |-> pages_open[gs_te_bank_num4rdwr];
endproperty

property rd_entry_valid;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_rd |-> te_rd_entry_vld[os_te_rdwr_entry];
endproperty

property rd_correct_rank_bank;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_rd |-> (te_rd_rankbanks[os_te_rdwr_entry] == gs_te_bank_num4rdwr);
endproperty

property rd_correct_page;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_rd |-> (te_rd_pages[os_te_rdwr_entry] == page_table[gs_te_bank_num4rdwr]);
endproperty

property rd_correct_block;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_rd |-> (te_rd_blocks[os_te_rdwr_entry] == te_pi_rd_addr_blk);
endproperty

property rd_correct_other_fields_rd;
        @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
        gs_te_op_is_rd |-> (te_rd_other_fields[os_te_rdwr_entry] == te_pi_rd_other_fields_rd);
endproperty



// if flush has been asserted for at least 2 cycles,
// then if colliding entry is valid and matches bank to replace, it should be chosen
// (note: it takes 2 cycles to move the preference for selection networks,
//        so make sure the same entry from IH has been retried for 3 cycles)
// (also: selection takes 1 cycle, so te_sel_rd_entry is 1 cycle later than other inputs)

property rd_flush_entry_selected;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
         (te_rd_flush & r_rd_flush & r2_rd_flush &
         r_rd_entry_bank_match[r_rd_col_entry] &
         (ih_te_rd_rankbank_num==r_ih_rd_rankbank_num) & (ih_te_rd_rankbank_num==$past(r_ih_rd_rankbank_num))&
         (ih_te_rd_page_num==r_ih_rd_page_num)         & (ih_te_rd_page_num==$past(r_ih_rd_page_num))        &
         (ih_te_rd_block_num==r_ih_rd_block_num)       & (ih_te_rd_block_num==$past(r_ih_rd_block_num))      &
         r_op_is_rd) |=>
            (te_sel_rd_entry == r_rd_col_entry )
;
endproperty

// if flush has been asserted for at least 2 cycles,
//  then bank of colliding entry should be used as bank hint
// if flush has been asserted for at least 2 cycles,
//  then bank of colliding entry should be used as bank hint
// do this check only when there are no expired VPR commands
// when there are expired VPR commands and collided entries, the banks that belongs
// to the prefer signal of LPR cam is used as the hint (logic in te_rd_replace module)

wire rd_flush_xor = 1'b1;
wire [RANKBANK_BITS-1:0] rd_flush_rankbank_num = ih_te_rd_rankbank_num ;
wire rd_flush_due_rd_2_cycles =  1'b1;
wire rd_flush_due_wr_2_cycles =  1'b1;

property rd_hi_flush_bank_selected;
   @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
        (te_rd_flush & r_rd_flush & r2_rd_flush & rd_flush_xor & (rd_flush_due_rd_2_cycles | rd_flush_due_wr_2_cycles))
                             |-> (te_os_hi_bank_hint == rd_flush_rankbank_num);
endproperty

property rd_lo_flush_bank_selected;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
        (te_rd_flush & r_rd_flush & r2_rd_flush & rd_flush_xor & (rd_flush_due_rd_2_cycles | rd_flush_due_wr_2_cycles))
                             |-> (te_os_lo_bank_hint == rd_flush_rankbank_num);
endproperty


///////////////////
// Write Properties
///////////////////
property wr_page_open;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_wr |-> pages_open[gs_te_bank_num4rdwr];
endproperty

property wr_entry_valid;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_wr |-> te_wr_entry_vld[os_te_rdwr_entry];
endproperty

property wr_correct_rank_bank;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_wr |-> (te_wr_rankbanks[os_te_rdwr_entry] == gs_te_bank_num4rdwr);
endproperty

property wr_correct_page;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_wr |-> (te_wr_pages[os_te_rdwr_entry] == page_table[gs_te_bank_num4rdwr]);
endproperty

property wr_correct_block;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_wr |-> (te_wr_blocks[os_te_rdwr_entry] == te_pi_wr_addr_blk);
endproperty

property wr_correct_other_fields_wr;
        @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
        gs_te_op_is_wr |-> (te_wr_other_fields[os_te_rdwr_entry] == te_pi_wr_other_fields_wr);
endproperty


//Disable it with inline ECC configuration
//For inline ECC, we can have multiple colliding WR ENTRY because of block address collision,
//therefore a logic to select one of them has been introduced by Inline ECC development. 
//For non-Inline ECC case, colliding WR ENTRY is only one,therefor we don't see such an issue
// if flush has been asserted for at least 2 cycles,
// then if colliding entry is valid and matches bank to replace, it should be chosen
// (note: it takes 2 cycles to move the preference for selection networks)
// (also: selection takes 1 cycle, so te_sel_wr_entry is 1 cycle later than other inputs)
property wr_flush_entry_selected;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
         (te_wr_flush & r_wr_flush & r2_wr_flush & 
         r_wr_entry_bank_match[r_wr_col_entry] &
         (ih_te_wr_rankbank_num==r_ih_wr_rankbank_num) & (ih_te_wr_rankbank_num==$past(r_ih_wr_rankbank_num))&
         (ih_te_wr_page_num==r_ih_wr_page_num)         & (ih_te_wr_page_num==$past(r_ih_wr_page_num))        &
         (ih_te_wr_block_num==r_ih_wr_block_num)       & (ih_te_wr_block_num==$past(r_ih_wr_block_num))      &
         r_op_is_wr) |->
            (te_sel_wr_entry == r_wr_col_entry ) 
;
endproperty


wire wr_flush_xor = 1'b1;
wire [RANKBANK_BITS-1:0] wr_flush_rankbank_num =  ih_te_wr_rankbank_num;
wire wr_flush_due_wr_2_cycles =  1'b1;
wire wr_flush_due_rd_2_cycles =  1'b1;



//---------------------------------- ASSERTIONS --------------------------------
//////////////////
// Read Assertions
//////////////////
a_rd_page_open : assert property (rd_page_open)
                 else $error("%m %t Read to closed page", $time);

a_rd_entry_valid : assert property (rd_entry_valid)
                 else $error("%m %t Read to bank %h using invalid CAM entry at entry # %h",
                 $time, gs_te_bsm_num4rdwr, os_te_rdwr_entry);

a_rd_correct_rank_bank : assert property (rd_correct_rank_bank)
                 else $error("%m %t Read to incorrect rank/bank. rank/bank written: %h, rank/bank expected: %h",
                 $time, gs_te_bank_num4rdwr, te_rd_rankbanks[os_te_rdwr_entry]);

a_rd_correct_page : assert property (rd_correct_page)
                    else $error("%m %t Read to incorrect page in rank/bank %h. page read: %h, page expected: %h",
                    $time, gs_te_bsm_num4rdwr, te_rd_pages[os_te_rdwr_entry], page_table[gs_te_bsm_num4rdwr]);

a_rd_correct_block : assert property (rd_correct_block)
                 else $error("%m %t Read to incorrect block in rank/bank %h.  block written: %h, block expected: %h",
                 $time, gs_te_bsm_num4rdwr, te_pi_rd_addr_blk, te_rd_blocks[os_te_rdwr_entry]);

a_rd_correct_other_fields_rd : assert property (rd_correct_other_fields_rd)
                 else $error("%m %t Read with incorrect other_fields in rank/bank %h.  others written: %h, others expected: %h",
                             $time, gs_te_bsm_num4rdwr, te_pi_rd_other_fields_rd, te_rd_other_fields[os_te_rdwr_entry]);


a_rd_hi_flush_bank_selected : assert property (rd_hi_flush_bank_selected)
                 else $error("%m %t Colliding rank/bank (%h) not preferred for high priority read bank selection > 1 cycle after a flush has started. Rank/bank preferred: 5h",
                             $time, rd_flush_rankbank_num, te_os_hi_bank_hint);

a_rd_lo_flush_bank_selected : assert property (rd_lo_flush_bank_selected)
                 else $error("%m %t Colliding rank/bank (%h) not preferred for low priority read bank selection > 1 cycle after a flush has started. Rank/bank preferred: 5h",
                             $time, rd_flush_rankbank_num, te_os_lo_bank_hint);


///////////////////
// Write Assertions
///////////////////
a_wr_page_open : assert property (wr_page_open)
                 else $error("%m %t Write to closed page", $time);

a_wr_entry_valid : assert property (wr_entry_valid)
                 else $error("%m %t Write to bank %h using invalid CAM entry at entry # %h",
                 $time, gs_te_bsm_num4rdwr, os_te_rdwr_entry);

a_wr_correct_rank_bank : assert property (wr_correct_rank_bank)
                 else $error("%m %t Read to incorrect rank/bank. rank/bank written: %h, rank/bank expected: %h",
                 $time, gs_te_bank_num4rdwr, te_wr_rankbanks[os_te_rdwr_entry]);

a_wr_correct_page : assert property (wr_correct_page)
                    else $error("%m %t Write to incorrect page in rank/bank %h.  page written: %h, expected page: %h",
                    $time, gs_te_bsm_num4rdwr, ts_act_page, te_wr_pages[os_te_rdwr_entry]);

a_wr_correct_block : assert property (wr_correct_block)
                 else $error("%m %t Write to incorrect block in rank/bank %h.  block written: %h, expected block: %h",
                 $time, gs_te_bsm_num4rdwr, te_pi_wr_addr_blk, te_wr_blocks[os_te_rdwr_entry]);

a_wr_correct_other_fields_wr : assert property (wr_correct_other_fields_wr)
                 else $error("%m %t Write to rank/bank %h with incorrect wr_other_fields.  others written: %h, others expected: %h",
                             $time, gs_te_bsm_num4rdwr, te_pi_wr_other_fields_wr, te_wr_other_fields[os_te_rdwr_entry]);




a_wr_flush_entry_selected : assert property (wr_flush_entry_selected)
                 else $error("%m %t Colliding write CAM entry (%h) matched bank for replacement, but was not selected >1 cycle after flush started. Entry selected: %h",
                             $time, r_wr_col_entry, te_sel_wr_entry);


// if flush has been asserted for at least 2 cycles,
//  then bank of colliding entry should be used as bank hint
property wr_flush_bank_selected;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
        (te_wr_flush & r_wr_flush & r2_wr_flush & te_wr_flush_started & wr_flush_xor & (wr_flush_due_wr_2_cycles | wr_flush_due_rd_2_cycles)) 

                    |-> (te_os_wr_bank_hint == wr_flush_rankbank_num);
endproperty

a_wr_flush_bank_selected : assert property (wr_flush_bank_selected)
                 else $error("%m %t Colliding rank/bank (%h) not preferred for write bank selection > 1 cycle after a flush has started. Rank/bank preferred: 5h",
                             $time, wr_flush_rankbank_num, te_os_wr_bank_hint);





/////////////////////////
// RD/WR page hit vector Assertions
/////////////////////////

// locally used variables
reg    [RD_CAM_ENTRIES-1:0]  r_te_rd_entry_vld;
reg    [RD_CAM_ENTRIES-1:0]  te_rd_entry_load;
reg    [WR_CAM_ENTRIES-1:0]  te_wr_entry_load;


// RD page hit vector assertion
///////////////////////////////

// te_rd_entry_vld prediction used for this assertion
// first is generated the te_rd_entry_load as a pulse whenver there is a new RD entry
// then it is generated the r_te_rd_entry_vld:
//    - set when a new entry is added into the RD CAM
//    - clr when the entry is scheduled for execution
// i_op_is_act_bypass temporarely considered as workaround for bugzilla 3082 - comment 4

always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    te_rd_entry_load <= {RD_CAM_ENTRIES{1'b0}};
  end else begin
    te_rd_entry_load <= {RD_CAM_ENTRIES{1'b0}};
    if (ih_te_rd_valid & ~i_te_te_rd_flush & (~te_ih_rd_retry))
      te_rd_entry_load[ih_te_rd_entry_num] <= 1'b1;
  end
end

always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    r_te_rd_entry_vld <= {RD_CAM_ENTRIES{1'b0}};
  end else begin
    r_te_rd_entry_vld <= r_te_rd_entry_vld | te_rd_entry_load;
    if (gs_te_op_is_rd)
      r_te_rd_entry_vld[os_te_rdwr_entry] <= 1'b0;
  end
end


// assertion for each RD CAM entry
// whenever a new RD is scheduled, all valid entries
// belonging to the same bank as the bank of the scheduled RD are checked:
//   - page_hit==1 if the entry has the same page as the page of the scheduled RD
//   - page_hit==0 if the entry has a different page by the page of the scheduled RD


property p_te_op_rd_page_open_check;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (gs_te_op_is_rd & r_te_rd_entry_vld[os_te_rdwr_entry]) |-> pages_open[te_rd_rankbanks[os_te_rdwr_entry]];
endproperty

a_te_op_rd_page_open_check: assert property (p_te_op_rd_page_open_check)
  else $error("%0t ERROR - read entry %0d is scheduled to bank %0d. This bank has no open page!",$time,os_te_rdwr_entry,te_rd_rankbanks[os_te_rdwr_entry]);

property p_te_op_rd_diff_page_open_check;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (gs_te_op_is_rd & r_te_rd_entry_vld[os_te_rdwr_entry] & pages_open[te_rd_rankbanks[os_te_rdwr_entry]]) |-> te_rd_pages[os_te_rdwr_entry]==page_table[te_rd_rankbanks[os_te_rdwr_entry]] ;
endproperty

a_te_op_rd_diff_page_open_check: assert property (p_te_op_rd_diff_page_open_check)
  else $error("%0t ERROR - read entry %0d is scheduled to bank %0d, page %0d, but page %0d is currently open.",$time,os_te_rdwr_entry,te_rd_rankbanks[os_te_rdwr_entry],te_rd_pages[os_te_rdwr_entry],page_table[te_rd_rankbanks[os_te_rdwr_entry]]);

   
property te_rd_page_hit_check(entry);
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (gs_te_op_is_rd & r_te_rd_entry_vld[entry] & (gs_te_bank_num4rdwr == te_rd_rankbanks[entry])) |->
  ((page_table[gs_te_bank_num4rdwr] == te_rd_pages[entry]) == te_rd_page_hit[entry]);
endproperty
  
genvar entry;
generate// UPCTL2: TODO, FIXME, needs to be tailore to new design. pagehit flag in te_rd_cam gets cleared whenever gs_te_op_is_rd goes high (p4 3441785), so property not valid anymore
  for (entry=0; entry<RD_CAM_ENTRIES; entry++) begin: rd_page_hit_check
    a_te_te_rd_page_hit_check: assert property (te_rd_page_hit_check(entry))
      else $error("%0t ERROR - rd_page_hit mismatch for entry %0d, exp = 1'b%0b, act = 1'b%0b",$time,entry,~te_rd_page_hit[entry],te_rd_page_hit[entry]);
  end
endgenerate


// WR page hit vector assertion
///////////////////////////////

// te_wr_entry_load prediction used for this assertion
always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    te_wr_entry_load <= {WR_CAM_ENTRIES{1'b0}};
  end else begin
    if (ih_te_wr_valid & ~i_te_te_wr_flush & (~te_ih_wr_retry) & (~te_yy_wr_combine))
      te_wr_entry_load[ih_te_wr_entry_num] <= 1'b1;

      if (gs_te_op_is_wr)
        te_wr_entry_load[os_te_rdwr_entry] <= 1'b0;
  end
end


// assertion for each WR CAM entry
// whenever a new WR is scheduled, all valid entries
// belonging to the same bank as the bank of the scheduled WR are checked:
//   - page_hit==1 if the entry has the same page as the page of the scheduled WR
//   - page_hit==0 if the entry has a different page by the page of the scheduled WR

property te_wr_page_hit_check(entry);
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (gs_te_op_is_wr & te_wr_entry_load[entry] & pages_open[te_wr_rankbanks[entry]] & (gs_te_bank_num4rdwr == te_wr_rankbanks[entry])) |->
  ((te_wr_pages[os_te_rdwr_entry] == te_wr_pages[entry]) == te_wr_page_hit[entry]);
endproperty

generate
  for (entry=0; entry<WR_CAM_ENTRIES; entry++) begin: wr_page_hit_check
    a_te_te_wr_page_hit_check: assert property (te_wr_page_hit_check(entry))
      else $error("%0t ERROR - wr_page_hit mismatch for entry %0d, exp = 1'b%0b, act = 1'b%0b",$time,entry,~te_wr_page_hit[entry],te_wr_page_hit[entry]);
  end
endgenerate


// assertion to check the delay in between ACT and any command
property act_2_any_cmd_delay_check;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_activate |-> not (##[0:0] (gs_te_op_is_rd | gs_te_op_is_wr | gs_te_op_is_precharge));
endproperty
// OM commenting assertion
//a_act_2_any_cmd_delay_check : assert property (act_2_any_cmd_delay_check)
//  else $error("%m %t the ACT_2_any_cmd delay broken - one command given earlier than 2 cycles after ACT",$time);


// assertion to check the delay in between RDWR and any command
property rdwr_2_any_cmd_delay_check;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  (gs_te_op_is_rd | gs_te_op_is_wr) |-> not (##[0:0] (gs_te_op_is_activate | gs_te_op_is_precharge));
endproperty
// OM commenting assertion which fails in fr2.  
//a_rdwr_2_any_cmd_delay_check : assert property (rdwr_2_any_cmd_delay_check)
//  else $error("%m %t the RDWR_2_any_cmd delay broken - one command given earlier than 2 cycles after RDWR",$time);

// assertion to check the delay in between PRE and any command
property pre_2_any_cmd_delay_check;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  gs_te_op_is_precharge |-> not (##[0:0] (gs_te_op_is_rd | gs_te_op_is_wr | gs_te_op_is_activate));
endproperty
// OM commenting assertion
//a_pre_2_any_cmd_delay_check : assert property (pre_2_any_cmd_delay_check)
//  else $error("%m %t the PRE_2_any_cmd delay broken - one command given earlier than 2 cycles after PRE",$time);

/////////////////////////
// Covergroup for covering te_rd_flush_due_wr and te_wr_flush_due_rd are asserted at same time.
// not cover it when MEMC_USE_RMW is defined, because if there is RMW cmd, 
// it's easy that te_rd_flush_due_wr and te_wr_flush_due_rd are asserted at same time
/////////////////////////
covergroup cg_te_rd_flush_due_wr_te_wr_flush_due_rd @(negedge co_te_clk);
    cp_te_rd_flush_due_wr_te_wr_flush_due_rd : coverpoint ((te_rd_flush_due_wr==1) && (te_wr_flush_due_rd)==1) iff(core_ddrc_rstn) {
        bins not_asserted_at_same_time = {1'b0};
        bins asserted_at_same_time = {1'b1};
}
endgroup
cg_te_rd_flush_due_wr_te_wr_flush_due_rd cg_te_rd_flush_due_wr_te_wr_flush_due_rd_inst = new;

/////////////////////////
// Covergroup for covering the NTTs during ACT (Bugzilla 3085)
/////////////////////////
covergroup cg_ntt_entries_during_act @(negedge co_te_clk);

  // observe the ACT happened for each bank (each NTT)
  cp_gs_te_bsm_num4act : coverpoint (gs_te_bank_num4act) iff(core_ddrc_rstn & gs_te_op_is_activate) {
    option.auto_bin_max = 2**RANKBANK_BITS;
  }

  // observe, in WR mode, if the RD NTT entry (of the activated bank) is valid or not
  cp_te_bs_rd_valid : coverpoint (te_bs_rd_valid[gs_te_bsm_num4act]) iff(core_ddrc_rstn & gs_te_wr_mode & gs_te_op_is_activate) {
    bins not_valid  = {1'b0};
    bins valid      = {1'b1};
  }

  // observe, in RD mode, if the WR NTT entry (of the activated bank) is valid or not
  cp_te_bs_wr_valid : coverpoint (te_bs_wr_valid[gs_te_bsm_num4act]) iff(core_ddrc_rstn & ~gs_te_wr_mode & gs_te_op_is_activate) {
    bins not_valid  = {1'b0};
    bins valid      = {1'b1};
  }

  // observe if the rows from WR and RD NTTs (of the activated bank) are equal or not
  cp_equal_rd_rw_pages : coverpoint (rd_nxt_page_table[gs_te_bsm_num4act*PAGE_BITS +:PAGE_BITS] ==
                                     wr_nxt_page_table[gs_te_bsm_num4act*PAGE_BITS +:PAGE_BITS])
                                     iff(core_ddrc_rstn & gs_te_op_is_activate) {
    bins not_equal  = {1'b0};
    bins equal      = {1'b1};
  }

  // observe in WR mode, when ACT happens for a WR NTT entry the RD NTT entry (valid or not),
  // of the same bank, has the same row value or not
  // this is covered for each bank number
  cx_rd_ntt_entries_during_act : cross cp_te_bs_rd_valid, cp_equal_rd_rw_pages, cp_gs_te_bsm_num4act
                                       iff(core_ddrc_rstn & gs_te_wr_mode & gs_te_op_is_activate);

  // observe in RD mode, when ACT happens for a RD NTT entry the WR NTT entry (valid or not),
  // of the same bank, has the same row value or not
  // this is covered for each bank number
  cx_wr_ntt_entries_during_act : cross cp_te_bs_wr_valid, cp_equal_rd_rw_pages, cp_gs_te_bsm_num4act
                                       iff(core_ddrc_rstn & ~gs_te_wr_mode & gs_te_op_is_activate);

endgroup: cg_ntt_entries_during_act

// Coverage group instantiation
cg_ntt_entries_during_act cg_ntt_entries_during_act_inst = new;


////////////////////////////////////
// RD/WR "in NTT" vector Assertions
// Corelated to Enh8 - Bugzilla 3096
////////////////////////////////////

// locally used variables
genvar                      gen_bsm;
reg    [RD_CAM_ENTRIES-1:0] rd_entry_valid_mask = 0;
reg    [WR_CAM_ENTRIES-1:0] wr_entry_valid_mask = 0;
reg    [RD_CAM_ENTRIES-1:0] rd_nxt_entry_in_ntt_exp;
reg    [WR_CAM_ENTRIES-1:0] wr_nxt_entry_in_ntt_exp;
wire [RD_CAM_ADDR_BITS-1:0] rd_entry_mem [TOTAL_BSMS-1:0];
wire [WR_CAM_ADDR_BITS-1:0] wr_entry_mem [TOTAL_BSMS-1:0];
integer                     i;


// RD "in NTT" vector assertion
////////////////////////////////////

// te_os_rd_entry_table -> rd_entry_mem translation (from vector to matrix translation)
// this is needed in order to access the mem content using integer indexes
generate
  for (gen_bsm=0; gen_bsm<TOTAL_BSMS; gen_bsm++) begin: read_entry_mem
    assign rd_entry_mem[gen_bsm] = te_os_rd_entry_table[(gen_bsm*RD_CAM_ADDR_BITS) +: RD_CAM_ADDR_BITS];
  end
endgenerate

// RD "in NTT" vector (rd_nxt_entry_in_ntt) prediction
// this new vector (from NTT to Replace logic) says which CAM entries are in NTT
// added as synth enhancement (Enh8 - Bugzilla 3096)
// prediction done based on NTT content - valid bit and CAM entry number
// all NTT valid entries are expected to have the  CAM "IN NTT" flag set
always @(*) begin
  rd_nxt_entry_in_ntt_exp = 0;
  for (i=0; i<TOTAL_BSMS; i++)
    if (te_bs_rd_valid[i]) begin
      rd_nxt_entry_in_ntt_exp[rd_entry_mem[i]] = 1'b1;
    end
end

// assertion to check the "IN NTT" flag for each RD CAM entry
// the predicted value is always expected to match the RTL actual value
property rd_nxt_entry_in_ntt_check;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (rd_nxt_entry_in_ntt == rd_nxt_entry_in_ntt_exp);
endproperty

a_rd_nxt_entry_in_ntt_check: assert property (rd_nxt_entry_in_ntt_check)
  else $error("%0t ERROR - rd_nxt_entry_in_ntt mismatch, exp = %0d'h%0h, act = %0d'h%0h",
              $time,RD_CAM_ENTRIES,rd_nxt_entry_in_ntt_exp,RD_CAM_ENTRIES,rd_nxt_entry_in_ntt);


// RD rd_entry_valid vector assertion
////////////////////////////////////

// generate the checking mask used in a_rd_entry_valid_check assertion (mask per each bit/CAM entry)
// this is needed because of 1 clk delay in between te_rd_entry_valid_cam and rd_nxt_entry_in_ntt
// the checking is always masked 1 clk after each te_rd_entry_valid_cam[entry] change
generate
  for (entry=0; entry<RD_CAM_ENTRIES; entry++) begin: for_wr_entry_valid_mask
    always @(te_rd_entry_valid_cam[entry]) begin
      rd_entry_valid_mask[entry] = 1'b1;
      @(posedge co_te_clk);
      rd_entry_valid_mask[entry] = 1'b0;
    end
  end
endgenerate


// assertion for each RD CAM entry
// checks the dependency between "Valid" and "IN NTT" flags for each RD CAM entry
// the "IN NTT" CAM entries must be always "Valid" entries
property rd_entry_valid_check(entry);
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (rd_nxt_entry_in_ntt[entry] & ~rd_entry_valid_mask[entry]) |-> (te_rd_entry_valid_cam[entry]);
endproperty

generate
  for (entry=0; entry<RD_CAM_ENTRIES; entry++) begin: te_rd_entry_valid_check
    a_rd_entry_valid_check: assert property (rd_entry_valid_check(entry))
      else $error("%0t ERROR - mismatch for rd_nxt_entry_in_ntt[%0d] = 1'b%0b, te_rd_entry_valid[%0d] = 1'b%0b",
                  $time,entry,rd_nxt_entry_in_ntt[entry],entry,te_rd_entry_valid[entry]);
  end
endgenerate


// WR "in NTT" vector assertion
////////////////////////////////////

// te_os_wr_entry_table -> wr_entry_mem translation (from vector to matrix translation)
// this is needed in order to access the mem content using integer indexes
generate
  for (gen_bsm=0; gen_bsm<TOTAL_BSMS; gen_bsm++) begin: write_entry_mem
    assign wr_entry_mem[gen_bsm] = te_os_wr_entry_table[(gen_bsm*WR_CAM_ADDR_BITS) +: WR_CAM_ADDR_BITS];
  end
endgenerate

// WR "in NTT" vector (wr_nxt_entry_in_ntt) prediction
// this new vector (from NTT to Replace logic) says which CAM entries are in NTT
// added as synth enhancement (Enh8 - Bugzilla 3096)
// prediction done based on NTT content - valid bit and CAM entry number
// all NTT valid entries are expected to have the  CAM "IN NTT" flag set
always @(*) begin
  wr_nxt_entry_in_ntt_exp = 0;
  for (i=0; i<TOTAL_BSMS; i++)
    if (te_bs_wr_valid[i]) begin
      wr_nxt_entry_in_ntt_exp[wr_entry_mem[i]] = 1'b1;
    end
end

// assertion to check the "IN NTT" flag for each WR CAM entry
// the predicted value is always expected to match the RTL actual value
property wr_nxt_entry_in_ntt_check;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (wr_nxt_entry_in_ntt == wr_nxt_entry_in_ntt_exp);
endproperty

a_wr_nxt_entry_in_ntt_check: assert property (wr_nxt_entry_in_ntt_check)
  else $error("%0t ERROR - wr_nxt_entry_in_ntt mismatch, exp = %0d'h%0h, act = %0d'h%0h",
              $time,WR_CAM_ENTRIES,wr_nxt_entry_in_ntt_exp,WR_CAM_ENTRIES,wr_nxt_entry_in_ntt);


// WR wr_entry_valid vector assertion
////////////////////////////////////

// generate the checking mask used in a_wr_entry_valid_check assertion (mask per each bit/CAM entry)
// this is needed because of 1 clk delay in between te_wr_entry_valid_cam and wr_nxt_entry_in_ntt
// the checking is always masked 1 clk after each te_wr_entry_valid_cam[entry] change
generate
  for (entry=0; entry<WR_CAM_ENTRIES; entry++) begin: for_rd_entry_valid_mask
    always @(te_wr_entry_valid_cam[entry] or te_wr_entry_we_bw_loaded[entry]) begin
      wr_entry_valid_mask[entry] = 1'b1;
      @(posedge co_te_clk);
      wr_entry_valid_mask[entry] = 1'b0;
    end
  end
endgenerate


// assertion for each WR CAM entry
// checks the dependency between "Valid" and "IN NTT" flags for each WR CAM entry
// the "IN NTT" CAM entries must be always "Valid" entries
property wr_entry_valid_check(entry);
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
  (wr_nxt_entry_in_ntt[entry] & ~wr_entry_valid_mask[entry]) |-> (te_wr_entry_valid_cam[entry] | te_wr_entry_we_bw_loaded[entry]);
endproperty

generate
  for (entry=0; entry<WR_CAM_ENTRIES; entry++) begin: te_wr_entry_valid_check
    a_wr_entry_valid_check: assert property (wr_entry_valid_check(entry))
      else $error("%0t ERROR - mismatch for wr_nxt_entry_in_ntt[%0d] = 1'b%0b, te_wr_entry_valid[%0d] = 1'b%0b",
                  $time,entry,wr_nxt_entry_in_ntt[entry],entry,te_wr_entry_valid[entry]);
  end
endgenerate


////////////////////////////////////
// RD/WR "AutoPre" signal Assertions
// Corelated to Enh9 - Bugzilla 3102
////////////////////////////////////

// locally used variables
reg                         prev_load_bank_match_op_rd;
reg [RD_CAM_ENTRIES -1:0]   r_te_rd_entry_valid_cam;
reg [RD_CAM_ENTRIES -1:0]   r_te_rd_entry_loaded_cam;
reg                         any_rd_bank_page_hit;
reg                         any_wr_bank_page_hit;
reg [WR_CAM_ENTRIES -1:0]   r_te_wr_entry_valid_cam;
reg [WR_CAM_ENTRIES -1:0]   r_te_wr_entry_we_bw_loaded;
reg [TOTAL_BANKS-1:0]       te_pi_rd_autopre_check_mask;
reg [TOTAL_BANKS-1:0]       te_pi_wr_autopre_check_mask;
wire                        rd_load_cam;

// RD "te_pi_rd_autopre" signal assertion
////////////////////////////////////

// this register/logic is used to avoid considering the entries which are loaded
// one cycle before scheduling a new RD (with the same bank/page), for calculating the te_pi_rd_autopre
// the Enh9 added a latency and the entries just loaded 1 cycle before scheduling a RD are not seen
always @(posedge co_te_clk) r_te_rd_entry_valid_cam  <= `UPCTL2_EN ? {RD_CAM_ENTRIES{1'b1}} : te_rd_entry_valid_cam;
always @(posedge co_te_clk) r_te_rd_entry_loaded_cam <= `UPCTL2_EN ? {RD_CAM_ENTRIES{1'b1}} : te_rd_entry_loaded_cam;

// signal to decode when RD CAM is loaded
assign rd_load_cam = ih_te_rd_valid
                  & (~te_ih_rd_retry)
;

// signal used to mask the checking the te_pi_rd_autopre when scheduling a RD to a bank
// under some particular cases difficult to predict:
//   - rd_load_cam in parallel with any cmd (RD or ACT or ACT BYPASS)
//   - mask disabled when there is any cmd to that bank without any load in parallel to that bank
reg                     gs_te_op_is_rd_activate_siml;
reg                     gs_te_op_is_wr_activate_siml;
reg [RANKBANK_BITS-1:0] gs_te_bank_num4act_d;

always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    gs_te_op_is_rd_activate_siml <= 1'b0;
    gs_te_op_is_wr_activate_siml <= 1'b0;
    gs_te_bank_num4act_d <= {RANKBANK_BITS{1'b0}};
  end
  else begin
    gs_te_op_is_rd_activate_siml <= gs_te_op_is_rd & gs_te_op_is_activate;
    gs_te_op_is_wr_activate_siml <= gs_te_op_is_wr & gs_te_op_is_activate;
    gs_te_bank_num4act_d <= gs_te_bank_num4act;
  end
end


always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    te_pi_rd_autopre_check_mask = {TOTAL_BANKS{1'b0}};
  end else begin
    if (gs_te_op_is_rd) begin
      te_pi_rd_autopre_check_mask[gs_te_bank_num4rdwr] = 1'b0;
      if (rd_load_cam)
        te_pi_rd_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b1;
    end
    else if (gs_te_op_is_activate) begin
      te_pi_rd_autopre_check_mask[gs_te_bank_num4act] = 1'b0;
      if (rd_load_cam)
        te_pi_rd_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b1;
    end

    if (gs_te_op_is_rd_activate_siml) begin // Only for LPDDR5
      te_pi_rd_autopre_check_mask[gs_te_bank_num4act_d] = 1'b0;
      if (rd_load_cam)
        te_pi_rd_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b1;
    end    

    if (i_op_is_act_bypass) begin
      te_pi_rd_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b0;
      if (rd_load_cam)
        te_pi_rd_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b1;
    end
    if (~rd_cam_delayed_autopre_update_fe) begin
      if (rd_load_cam)
        te_pi_rd_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b1;
    end
  end
end

// whenever there is a new scheduled RD cmd
// predict/calculate if there is any other RD entry in the RD CAM
// belonging to the same bank/page as the scheduled RD
// used to predict the "te_pi_rd_autopre" value for "pageclose" policy
always @(posedge gs_te_op_is_rd) begin
  any_rd_bank_page_hit = 1'b0;
  prev_load_bank_match_op_rd = 1'b0;
  #1ps;
  for (i=0; i<RD_CAM_ENTRIES; i++) begin
    if ((i != os_te_rdwr_entry) & (gs_te_bank_num4rdwr == te_rd_rankbanks[i]) & te_rd_page_hit[i] & te_rd_entry_loaded_cam[i] & r_te_rd_entry_loaded_cam[i]) begin
      any_rd_bank_page_hit = 1'b1;
    end // if
  end // for
end

// note: following codes are commented out for bug 7584
// assertion to check the "te_pi_rd_autopre" from TE->PI (auto-precharge indicator)
// valid with op_is_rd pulses, saying if the scheduled RD is with auto-precharge or not
// this signal has 2 sources:
//    - Explicit Auto-Pre per command through HIF intf (hif_cmd_autopre signal)
//    - Page Close Policy through the following registers: SCHED.pageclose and SCHED1.pageclose_timer
// property te_pi_rd_autopre_check;
//   @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
//   (gs_te_op_is_rd & ~te_pi_rd_autopre_check_mask[gs_te_bank_num4rdwr] & ~prev_load_bank_match_op_rd 
//   `ifdef MEMC_INLINE_ECC
//    & (te_pi_ie_rd_type != `IE_RD_TYPE_RE_B) // For RE_B, AP=0 always as there must be page-hit RD_E for RE_B, checked by a_ie_te_pi_rd_autopre_must_be_zero_for_re_b
//   `endif
//   ) |->
//   ((te_rd_autopre[os_te_rdwr_entry] | (dh_te_pageclose & (dh_te_pageclose_timer==0) & ~any_rd_bank_page_hit)
// `ifdef MEMC_USE_RMW
//    & (te_pi_rd_other_fields_rd[OTHER_RD_RMW_LSB+:OTHER_RD_RMW_TYPE_BITS] == `MEMC_RMW_TYPE_NO_RMW)
// `endif
//    ) == te_pi_rd_autopre);
// endproperty
// 
// a_te_pi_rd_autopre_check : assert property (te_pi_rd_autopre_check)
//   else $error("%0t ERROR - te_pi_rd_autopre mismatch, exp = 1'b%0b, act = 1'b%0b",
//               $time,~te_pi_rd_autopre,te_pi_rd_autopre);

// WR "te_pi_wr_autopre" signal assertion
////////////////////////////////////

// this register/logic is used to avoid considering the entries which are loaded
// one cycle before scheduling a new WR (with the same bank/page), for calculating the te_wr_autopre
// the Enh9 added a latency and the entries just loaded 1 cycle before scheduling a WR are not seen
always @(posedge co_te_clk) r_te_wr_entry_valid_cam <= te_wr_entry_valid_cam;
always @(posedge co_te_clk) r_te_wr_entry_we_bw_loaded <= te_wr_entry_we_bw_loaded;

// signal used to mask the checking the te_wr_autopre when scheduling a WR to a bank
// under some particular cases difficult to predict:
//   - WR CAM loaded in parallel with any cmd (WR or ACT or ACT BYPASS)
//   - mask disabled when there is any cmd to that bank without any load in parallel to that bank
always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn)
    te_pi_wr_autopre_check_mask = {TOTAL_BANKS{1'b0}};
  else begin
    if (gs_te_op_is_wr) begin
      te_pi_wr_autopre_check_mask[gs_te_bank_num4rdwr] = 1'b0;
      if (|wr_cam_rd_and_wr_data_rdy)
        te_pi_wr_autopre_check_mask[te_be_rankbank_num] = 1'b1;
    end 
    else if (gs_te_op_is_activate) begin
      te_pi_wr_autopre_check_mask[gs_te_bank_num4act] = 1'b0;
      if (|wr_cam_rd_and_wr_data_rdy)
        te_pi_wr_autopre_check_mask[te_be_rankbank_num] = 1'b1;
    end

    if (gs_te_op_is_wr_activate_siml) begin // only for LPDDR5
      te_pi_wr_autopre_check_mask[gs_te_bank_num4act_d] = 1'b0;
      if (|wr_cam_rd_and_wr_data_rdy)
        te_pi_wr_autopre_check_mask[te_be_rankbank_num] = 1'b1;
    end


    if (i_op_is_act_bypass) begin
      te_pi_wr_autopre_check_mask[ih_te_rd_rankbank_num] = 1'b0;
      if (|wr_cam_rd_and_wr_data_rdy)
        te_pi_wr_autopre_check_mask[te_be_rankbank_num] = 1'b1;
    end
    if (~wr_cam_delayed_autopre_update_fe) begin
      if (|wr_cam_rd_and_wr_data_rdy)
        te_pi_wr_autopre_check_mask[te_be_rankbank_num] = 1'b1;
    end


    // mask checking also when there is a WR combine for an entry
    // base on the context is not predictable if this entry is considered or not
    // when calculating the te_wr_autopre for the next WR to the same bank
    for (i=0; i<WR_CAM_ENTRIES; i++) begin
      if (wr_cam_i_combine_match[i])
        te_pi_wr_autopre_check_mask[te_wr_rankbanks[i]] = 1'b1;
    end
  end
end

// whenever there is a new scheduled WR cmd
// predict/calculate if there is any other valid WR entry in the WR CAM
// belonging to the same bank/page as the scheduled WR
// used to predict the "te_pi_wr_autopre" value for "pageclose" policy
always @(posedge gs_te_op_is_wr) begin
  any_wr_bank_page_hit = 1'b0;
  #1ps;
  for (i=0; i<WR_CAM_ENTRIES; i++) begin
    if ((i != os_te_rdwr_entry) & (gs_te_bank_num4rdwr == te_wr_rankbanks[i]) & te_wr_page_hit[i] & 
         (
           (te_wr_entry_valid_cam[i] & r_te_wr_entry_valid_cam[i])        // Entry is valid at least for two cycles
         )
       ) begin
      any_wr_bank_page_hit = 1'b1;
    end // if
  end // for
end

// note: following codes are commented out for bug 7584
// assertion to check the "te_pi_wr_autopre" from TE->PI (auto-precharge indicator)
// valid with op_is_wr pulses, saying if the scheduled WR is with auto-precharge or not
// this signal has 2 sources:
//    - Explicit Auto-Pre per command through HIF intf (hif_cmd_autopre signal)
//    - Page Close Policy through the following registers: SCHED.pageclose and SCHED1.pageclose_timer
// property te_pi_wr_autopre_check;
//   @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
//   (gs_te_op_is_wr & ~te_pi_wr_autopre_check_mask[gs_te_bank_num4rdwr]
//   `ifdef MEMC_INLINE_ECC
//    & (te_mr_ie_wr_type != `IE_WR_TYPE_WD_E) // For WD_E, AP=0 always as there must be page-hit WE_B for WD_E, checked by a_ie_te_pi_wr_autopre_must_be_zero_for_wd_e
//   `endif
//   ) |->
//   ((te_wr_autopre_a[os_te_rdwr_entry] | (dh_te_pageclose & (dh_te_pageclose_timer==0) & ~any_wr_bank_page_hit)) == te_wr_autopre);
// endproperty
// 
// a_te_pi_wr_autopre_check : assert property (te_pi_wr_autopre_check)
//   else $error("%0t ERROR - te_wr_autopre mismatch, exp = 1'b%0b, act = 1'b%0b",
//               $time,~te_wr_autopre,te_wr_autopre);

// note: following codes are commented out for bug 7584
/////////////////////////////////////////////
// Covergroup for covering the AUTOPRE for RD
// Corelated to Enh9 - Bugzilla 3102
/////////////////////////////////////////////
// covergroup cg_te_pi_rd_autopre @(negedge co_te_clk);
// 
//   // observe the te_pi_rd_autopre for the new scheduled RD cmd
//   cp_te_pi_rd_autopre : coverpoint (te_pi_rd_autopre) iff(core_ddrc_rstn & gs_te_op_is_rd) {
//     bins autopre0  = {1'b0};
//     bins autopre1  = {1'b1};
//   }
// 
//   // observe the internal autopre for the new scheduled RD cmd (given through hif_cmd_autopre sig)
//   cp_int_rd_autopre : coverpoint (te_rd_autopre[os_te_rdwr_entry]) iff(core_ddrc_rstn & gs_te_op_is_rd) {
//     bins autopre0  = {1'b0};
//     bins autopre1  = {1'b1};
//   }
// 
//   // observe the bank number for which the RD cmd is given
//   cp_gs_te_bsm_num4rdwr : coverpoint (gs_te_bsm_num4rdwr) iff(core_ddrc_rstn & gs_te_op_is_rd) {
//     option.auto_bin_max = TOTAL_BSMS;
//   }
// 
//   // observe in RD mode, when RD happens the te_pi_rd_autopre is given or not
//   // if given then that it's given with each possible source (int or through pageclose policy)
//   // this is covered for each bank number
//   cx_autopre_during_rd : cross cp_te_pi_rd_autopre, cp_int_rd_autopre, cp_gs_te_bsm_num4rdwr
//                                iff(core_ddrc_rstn & gs_te_op_is_rd) {
//     ignore_bins not_possible = (binsof(cp_te_pi_rd_autopre.autopre0) && binsof(cp_int_rd_autopre.autopre1));
//   }
// 
// endgroup: cg_te_pi_rd_autopre

// Coverage group instantiation
// cg_te_pi_rd_autopre cg_te_pi_rd_autopre_inst = new;

// note: following codes are commented out for bug 7584
/////////////////////////////////////////////
// Covergroup for covering the AUTOPRE for WR
// Corelated to Enh9 - Bugzilla 3102
/////////////////////////////////////////////
// covergroup cg_te_pi_wr_autopre @(negedge co_te_clk);
// 
//   // observe the te_wr_autopre for the new scheduled WR cmd
//   cp_te_pi_wr_autopre : coverpoint (te_wr_autopre) iff(core_ddrc_rstn & gs_te_op_is_wr) {
//     bins autopre0  = {1'b0};
//     bins autopre1  = {1'b1};
//   }
// 
//   // observe the internal autopre for the new scheduled RD cmd (given through hif_cmd_autopre sig)
//   cp_int_wr_autopre : coverpoint (te_wr_autopre_a[os_te_rdwr_entry]) iff(core_ddrc_rstn & gs_te_op_is_wr) {
//     bins autopre0  = {1'b0};
//     bins autopre1  = {1'b1};
//   }
// 
//   // observe the bank number for which the WR cmd is given
//   cp_gs_te_bsm_num4rdwr : coverpoint (gs_te_bsm_num4rdwr) iff(core_ddrc_rstn & gs_te_op_is_wr) {
//     option.auto_bin_max = TOTAL_BSMS;
//   }
// 
//   // observe in WR mode, when WR happens the te_wr_autopre is given or not
//   // if given then that it's given with each possible source (int or through pageclose policy)
//   // this is covered for each bank number
//   cx_autopre_during_wr : cross cp_te_pi_wr_autopre, cp_int_wr_autopre, cp_gs_te_bsm_num4rdwr
//                                iff(core_ddrc_rstn & gs_te_op_is_wr) {
//     ignore_bins not_possible = (binsof(cp_te_pi_wr_autopre.autopre0) && binsof(cp_int_wr_autopre.autopre1));
//   }
// 
// endgroup: cg_te_pi_wr_autopre
// 
// Coverage group instantiation
// cg_te_pi_wr_autopre cg_te_pi_wr_autopre_inst = new;




//-------------------
// SCHED.autopre_rmw
//-------------------

// Check SCHED.autopre_rmw, check that ih_te_rd_autopre* is identical for non-RMW
property p_dis_autopre_rmw_check0;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  (~ih_te_rd_rmw) |-> (ih_te_rd_autopre == ih_te_rd_autopre_org);
endproperty
a_dis_autopre_rmw_check0 : assert property (p_dis_autopre_rmw_check0);

// Check SCHED.autopre_rmw, if disabled, check that ih_te_*_autopre are identical  
property p_dis_autopre_rmw_check1;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  (~reg_ddrc_autopre_rmw & ih_te_rd_valid & ih_te_rd_rmw) |-> (ih_te_rd_autopre == ih_te_wr_autopre);
endproperty
a_dis_autopre_rmw_check1 : assert property (p_dis_autopre_rmw_check1);

// Check SCHED.autopre_rmw, if disabled, check that ih_te_rd_autopre* are identical  
property p_dis_autopre_rmw_check2;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  (~reg_ddrc_autopre_rmw) |-> (ih_te_rd_autopre == ih_te_rd_autopre_org);
endproperty
a_dis_autopre_rmw_check2 : assert property (p_dis_autopre_rmw_check2);

// Check SCHED.autopre_rmw, if enabled, check that ih_te_rd_autopre is 0 for RMW  
property p_en_autopre_rmw_check;
  @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
  (reg_ddrc_autopre_rmw & ih_te_rd_valid & ih_te_rd_rmw) |-> (ih_te_rd_autopre == 1'b0);
endproperty
a_en_autopre_rmw_check : assert property (p_en_autopre_rmw_check);

covergroup cg_SCHED_autopre_rmw @(negedge co_te_clk);

  // Ovserve all required combination for SCHED.autopre_rmw
  cp_autopre_rmw_chk : coverpoint ({reg_ddrc_autopre_rmw,ih_te_rd_rmw,ih_te_rd_autopre_org}) iff(core_ddrc_rstn & ih_te_rd_valid ) {
    bins dis_reg_RMW_autopre1   = {{1'b0,1'b1,1'b1}};
    bins dis_reg_RMW_autopre0   = {{1'b0,1'b1,1'b0}};
    bins dis_reg_noRMW_autopre1 = {{1'b0,1'b0,1'b1}};
    bins dis_reg_noRMW_autopre0 = {{1'b0,1'b0,1'b0}};
    bins en_reg_RMW_autopre1    = {{1'b1,1'b1,1'b1}};
    bins en_reg_RMW_autopre0    = {{1'b1,1'b1,1'b0}};
    bins en_reg_noRMW_autopre1  = {{1'b1,1'b0,1'b1}};
    bins en_reg_noRMW_autopre0  = {{1'b1,1'b0,1'b0}};
  }
endgroup: cg_SCHED_autopre_rmw

// Coverage group instantiation
cg_SCHED_autopre_rmw cg_SCHED_autopre_rmw_inst = new;


endmodule // te_assertions
`endif // `ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON
