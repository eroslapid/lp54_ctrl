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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_rd_nxt.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// Next Transaction Table provides the priority and the page hit info to the
//   scheduler to schedule dram operation properly. uMCTL2: In addition, the table
//   stores the CAM entry number for the next scheduled transaction.
//
// The table is updated when there is a new transaction coming in or there is
//   a CAM search.
//   In uPCTL2 the update is according to the oldest.
//   In uMCTL2 the update is according to the order of the following rules
//   1. oldest matching prefer priority with page hit
//   2. youngest matching prefer priority with page hit
//   3. oldest matching prefer priority without page hit
//   4. youngest matching prefer priority without page hit
//   5. oldest unmatching prefer priotity with page hit
//   6. youngest unmatching prefer priority with page hit
//   7. oldest unmatching prefer priority without page hit
//   8. youngest unmatching prefer priority without page hit
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_rd_nxt #(
    //------------------------------- PARAMETERS -----------------------------------
     parameter   RANK_BITS       = `UMCTL2_LRANK_BITS 
    ,parameter   BG_BITS         = `MEMC_BG_BITS 
    ,parameter   BANK_BITS       = `MEMC_BANK_BITS 
    ,parameter   BG_BANK_BITS    = `MEMC_BG_BANK_BITS 
    ,parameter   CMD_ENTRY_BITS  = `MEMC_WRCMD_ENTRY_BITS   // bits required to address into the CAM - arbitrarily defaulted to the size of the write CAM
    ,parameter   PAGE_BITS       = `MEMC_PAGE_BITS 
    ,parameter   RANKBANK_BITS   = RANK_BITS + BG_BANK_BITS 
    ,parameter   BSM_BITS        = `UMCTL2_BSM_BITS
    ,parameter   NUM_TOTAL_BANKS = 1 << RANKBANK_BITS 
    ,parameter   NUM_TOTAL_BSMS  = `UMCTL2_NUM_BSM
    ,parameter   NUM_CAM_ENTRIES = (1 << CMD_ENTRY_BITS) 
    ,parameter   AUTOPRE_BITS    = 1
    ,parameter   CMD_LEN_BITS    = 1
    ,parameter   WORD_BITS       = 1 
    ,parameter   IE_TAG_BITS     = 0 // overridden
    )
    (
    //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                       core_ddrc_rstn               // main reset
    ,input                                       co_te_clk                    // main clock
    ,input                                       ih_te_rd_valid               // valid read/write command from ih
    ,input  [CMD_ENTRY_BITS-1:0]                 te_sel_entry                 // entry number from selection networks
    ,input  [PAGE_BITS-1:0]                      te_sel_rd_page 
    ,input  [AUTOPRE_BITS-1:0]                   te_sel_rd_cmd_autopre        // cmd_autopre of selected CAM entry   
    ,input  [CMD_LEN_BITS-1:0]                   te_sel_rd_length             // Other Fields of selected CAM entry
    ,input  [WORD_BITS-1:0]                      te_sel_rd_critical_word       // Other Fields of selected CAM entry
    ,input                                       te_sel_valid                 // entry number from selection networks is valid
    ,input  [NUM_CAM_ENTRIES -1:0]               te_page_hit                  // stored xact address in CAM currently has an open page hit
    ,input                                       te_ih_rd_retry               // collision detected
    ,input  [NUM_CAM_ENTRIES -1:0]               te_entry_pri                 // stored xact in CAM is a high priority read
    ,input  [1:0]                                ih_te_hi_pri                 // incoming xact priority: 00-LPR, 01-VPR, 10-HPR, 11-expired-VPR
    ,input                                       ts_pri_level                 // priority level to participate current DRAM access
    ,output reg [NUM_TOTAL_BSMS-1:0]             te_ts_hi_xact                // next transaction is a high priority transaction
    ,output                                      te_gs_hi_xact_page_hit_vld   // valid transaction with high priority and page hit
    ,input                                       be_te_page_hit               // incoming xact currently has an open page hit
    ,input  [PAGE_BITS-1:0]                      ts_act_page                  // Activated page from TS
    ,input  [BSM_BITS-1:0]                       ih_te_bsm_num                // incoming xact BSM number
    ,input                                       ih_te_bsm_alloc              // bsm alloc info  When DYN_BSM is not defined,this port should be set to 1.
    ,input  [CMD_ENTRY_BITS-1:0]                 ih_te_entry_num              // incoming xact CAM entry number
    ,output [NUM_TOTAL_BSMS-1:0]                 te_bs_rd_bank_page_hit 
    ,input  [NUM_CAM_ENTRIES*PAGE_BITS-1:0]      te_rd_page_table             // page addresses of all CAM entries
    ,input  [NUM_CAM_ENTRIES*AUTOPRE_BITS-1:0]   te_rd_cmd_autopre_table      // cmd_autopre  of all CAM entries    
    ,input  [NUM_CAM_ENTRIES*CMD_LEN_BITS-1:0]   te_rd_cmd_length_table       // Other fields of all CAM entries
    ,input  [NUM_CAM_ENTRIES*WORD_BITS-1:0]      te_rd_critical_word_table    // Other fields of all CAM entries
    ,input  [BSM_BITS-1:0]                       ts_bsm_num4pre               // DRAM op BSM number for precharge
    ,input  [BSM_BITS-1:0]                       ts_bsm_num4rdwr              // BSM number applicable to reads and writes only
    ,input  [BSM_BITS-1:0]                       ts_bsm_num4act               // BSM number applicable to activates only
    ,input                                       te_rdwr_autopre              // a read or a write issued this cycle with auto-precharge
    ,input                                       ts_op_is_rd                  // DRAM op is a read or write operation
    ,input                                       ts_op_is_precharge           // DRAM op is precharge operation
    ,input                                       ts_op_is_activate            // DRAM op is activate operation
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style for now.
    ,input                                       ts_wr_mode                   // 1=GS issuing writes  0=GS issuing reads
//spyglass enable_block W240
    ,output reg [NUM_TOTAL_BSMS-1:0]             te_ts_page_hit               // next transaction has an open page hit
    ,output reg [NUM_TOTAL_BSMS-1:0]             te_ts_valid                  // next transaction is valid
    ,output [NUM_TOTAL_BSMS-1:0]                 te_dh_valid                  // next transaction is valid
    ,output [NUM_TOTAL_BSMS-1:0]                 te_dh_page_hit               // next transaction is page hit
    ,output [NUM_TOTAL_BSMS*CMD_ENTRY_BITS-1:0]  te_os_rd_entry_table         // outputs the entire contents of the nxt_table
                                                                              // entry num belonging to all the banks are put on a single bus
                                                                              // TS will do the entry selection instead of this module
    ,output                                      te_pghit_vld                 // one or more valid page hits in this table
    ,output [NUM_TOTAL_BSMS*PAGE_BITS-1:0]       rd_nxt_page_table            // outputs the page for each rank/bank 
    ,output [NUM_TOTAL_BSMS*AUTOPRE_BITS-1:0]    rd_nxt_cmd_autopre_table
    ,output [NUM_TOTAL_BSMS*CMD_LEN_BITS-1:0]    rd_nxt_length_table           // Read Other Fields Next xact
    ,output [NUM_TOTAL_BSMS*WORD_BITS-1:0]       rd_nxt_word_table // Read Other Fields Next xact
    ,output [NUM_CAM_ENTRIES-1:0]                rd_nxt_entry_in_ntt
    ,input  [CMD_ENTRY_BITS-1:0]                 te_sel_entry_pre             // entry number from selection networks
    ,input  [PAGE_BITS-1:0]                      te_sel_rd_page_pre
    ,input  [AUTOPRE_BITS-1:0]                   te_sel_rd_cmd_autopre_pre    // cmd_autopre of selected CAM entry   
    ,input  [CMD_LEN_BITS-1:0]                   te_sel_rd_cmd_length_pre   // Other fields of selected CAM entry
    ,input  [WORD_BITS-1:0]                      te_sel_rd_critical_word_pre  // Other fields of selected CAM entry
    ,input  [NUM_TOTAL_BSMS-1:0]                 te_entry_critical_per_bsm 
    ,input                                       reg_ddrc_opt_hit_gt_hpr
    ,input                                       reg_ddrc_dis_opt_ntt_by_act
    ,input                                       reg_ddrc_dis_opt_ntt_by_pre
    `ifndef SYNTHESIS
    `ifdef SNPS_ASSERT_ON
    ,input [PAGE_BITS-1:0]                       ts_te_act_page
    `endif // SNPS_ASSERT_ON
    `endif // SYNTHESIS
    ,input  [NUM_TOTAL_BSMS-1:0]                 ts_te_sel_act_wr         //tell TE the activate command is for write or read.
    );

//---------------------------- REGISTERS AND WIRES ------------------------------
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in uMCTL2 and for all UMCTL2_VPR_EN configs. Keeping current implementation.
wire [NUM_TOTAL_BSMS -1:0]    te_vpr_entry = {NUM_TOTAL_BSMS{1'b0}};   // next xact is a VPR entry
//spyglass enable_block W528

// NTT consists of valid, entry number, page hit and priority
reg  [CMD_ENTRY_BITS -1:0]    entry_mem [NUM_TOTAL_BSMS -1:0];               // table to store the next xact entry number for each rank/bank
wire [CMD_ENTRY_BITS -1:0]    entry_mem_next [NUM_TOTAL_BSMS -1:0];          // table to store the next xact entry number for each rank/bank   
reg  [PAGE_BITS -1:0]         page_mem [NUM_TOTAL_BSMS -1:0];                // table to store the next xact page for each rank/bank
wire [PAGE_BITS -1:0]         page_mem_next [NUM_TOTAL_BSMS -1:0];           // table to store the next xact page for each rank/bank
reg  [AUTOPRE_BITS -1:0]      cmd_autopre_mem [NUM_TOTAL_BSMS -1:0];         // table to store the next xact cmd_autopre for each rank/bank
wire [AUTOPRE_BITS -1:0]      cmd_autopre_mem_next [NUM_TOTAL_BSMS -1:0];    // table to store the next xact cmd_autopre for each rank/bank         
reg  [CMD_LEN_BITS-1:0]       length_mem [NUM_TOTAL_BSMS-1:0];               // table to store the next xact Other Fields for each rank/bank
wire [CMD_LEN_BITS-1:0]       length_mem_next [NUM_TOTAL_BSMS-1:0];          // table to store the next xact Other Fields for each rank/bank
reg  [WORD_BITS-1:0]          word_mem [NUM_TOTAL_BSMS-1:0];               // table to store the next xact Other Fields for each rank/bank
wire [WORD_BITS-1:0]          word_mem_next [NUM_TOTAL_BSMS-1:0];          // table to store the next xact Other Fields for each rank/bank
wire [NUM_TOTAL_BSMS -1:0]    te_ts_page_hit_next;                           // next xact has an open page hit, part of NTT   
reg  [BSM_BITS-1:0]           r_ts_bsm_num4pre;                              // flopped version of BSM number from scheduler
reg                           r_ts_op_is_pre_for_ntt_upd;
reg  [BSM_BITS-1:0]           r_ts_bsm_num4rdwr;                             // flopped version of BSM number from scheduler
reg  [NUM_CAM_ENTRIES -1:0]   r_cam_entry_pri;                               // flopped version of priority from CAM search:
                                                                             //  1 bit per CAM entry
reg                           r_ih_entry_pri;                                // flopped version of priority from IH
reg                           r_ih_effective_pri;                            // same as above, after accounting for priority level from GS
reg                           r_pri_level;                                   // flopped version of priority level service from scheduler
reg                           r_same_bank;                                   // cam search and incoming are pointing to the same rank/bank
reg                           r_ih_pghit;                                    // flopped version of page hit info from IH
reg  [BSM_BITS-1:0]           r_ts_bsm_num4act;                              // flopped version of BSM number from scheduler
reg  [BSM_BITS-1:0]           r_ts_bsm_num4act_d;                            // 2 stage flopped version of BSM number from scheduler
reg                           r_ts_op_is_activate_wr;
reg                           r_ts_op_is_activate_wr_d;
wire                          r_ts_op_is_activate_wr_i;
wire                          r_ts_op_is_activate_wr_d_i;
assign r_ts_op_is_activate_wr_i   = r_ts_op_is_activate_wr;
assign r_ts_op_is_activate_wr_d_i = r_ts_op_is_activate_wr_d;



reg  [NUM_CAM_ENTRIES -1:0]   r_cam_entry_pghit;                             // flopped version of page hit info from CAM search:
                                                                             //  1 bit per CAM entry
reg                           r_sel_cam;                                     // flopped version of cam search
reg  [BSM_BITS-1:0]           r_ih_rankbank_num;                             // flopped version of new incoming rank/bank
wire                          i_ih_pghit;                                    // page hit info from CAM
reg  [CMD_ENTRY_BITS-1:0]     r_ih_entry_num;                                // flopped version of entry num from IH
reg                           r_sel_incoming;                                // there is an incoming transaction

wire                          i_sel_cam;                                     // flopped version of cam search
wire [BSM_BITS-1:0]           i_cam_search_bank;
wire [NUM_TOTAL_BSMS-1:0]     te_ts_valid_nxt;                               // next transaction is valid

wire [NUM_TOTAL_BSMS-1:0]    i_incoming_over_existing;

integer  cnt; // for loop dummy variable

assign te_pghit_vld               = | (te_ts_valid [NUM_TOTAL_BSMS -1:0] &
                                       te_ts_page_hit  [NUM_TOTAL_BSMS -1:0]  );
assign te_gs_hi_xact_page_hit_vld = | (te_ts_valid [NUM_TOTAL_BSMS -1:0] &
                                       te_ts_hi_xact [NUM_TOTAL_BSMS -1:0]     &
                                       te_ts_page_hit [NUM_TOTAL_BSMS -1:0]   );

// calculate if bypass is taken (assigned to zero if bypass not supported)
wire                          i_choose_rd_bypass;
wire                          ih_te_hi_pri_int   = ih_te_hi_pri[1];  // only upper bit of priority coming from IH connected here
                                                                     // the encoding if incoming pri is:
                                                                     // 00 - LPR, 01 - VPR, 10 - HPR, 11 - Reserved
                                                                     // VPR to Expired-VPR conversion is done inside the CAM
                                                                     // NTT detects the incoming expired-VPR commands and blocks
                                                                     // from entering NTT. The logic becomes complex if expired-VPR commands
                                                                     // are directly put in NTT
wire                          i_ts_act4rd;                           // TS activating a page to read from it

wire                          i_open_page;                           // open a page for reads
reg                           r_open_page;                           // flopped indicator that a page has been opened/activated
wire                          i_same_bank;                           // IH and GS accessing same bank this cycle
wire                          i_same_bank_incoming_vs_rw;            // IH and GS (RW only) accessing same bank this cycle to qualify te_rdwr_autopre

reg                           r_ts_op_is_activate_for_upd;           // For NTT re-evaluation in terms of page-hit
reg   [PAGE_BITS-1:0]         r_ts_act_page;
wire                          i_close_page_pre;                      // close a page due to pre
wire                          i_close_page_autopre;                  // close a page due to autopre
wire  [BSM_BITS-1:0]          i_close_page_bank_pre;                 // Bank selected for closing for a pre
wire  [BSM_BITS-1:0]          i_close_page_bank_autopre;             // Bank selected for closing for autopre command
reg                           r_close_page_pre;                      // flopped indicator that a page is closed/precharged
reg                           r_close_page_autopre;                  // flopped indicator that a page is closed/precharged
reg   [BSM_BITS-1:0]          r_close_page_bank_pre;                 // flopped bank number of the page closed/precharged for a pre or autopre cmd
reg   [BSM_BITS-1:0]          r_close_page_bank_autopre;             // flopped bank number of the page closed/precharged for a pre or autopre cmd
wire [NUM_TOTAL_BSMS-1:0]     r_open_page_per_bank;                  // per-bank indications of page openings
wire [NUM_TOTAL_BSMS-1:0]     r_close_page_per_bank;                 // per-bank indications of page closes
wire [NUM_TOTAL_BSMS-1:0]     i_page_hit_update_per_bsm;

// combinations of flopped inputs
wire [NUM_TOTAL_BSMS-1:0]     page_hit_update_ext;                   // per-bank indications of page open or close (extended version)
wire [NUM_TOTAL_BSMS-1:0]     i_sel_incoming_per_bank;               // per-bank indications of incoming request
wire                          i_sel_page_hit;                        // page hit indicator from CAM replacement entry
wire                          i_incoming_over_cam;                   // indicates if new request should replace  (in uPCTL2 should be always set to '0')
                                                                     //  existing request in next table
wire [NUM_TOTAL_BSMS-1:0]     i_cam_vpr_over_existing;               // (in uPCTL2 should be always set to '0')
wire [NUM_TOTAL_BSMS-1:0]     i_incoming_vpr_over_existing;          // (in uPCTL2 should be always set to '0')
wire                          i_sel_vpr_page_hit;                    // (in uPCTL2 should be always set to '0')
wire [NUM_TOTAL_BSMS-1:0]     i_sel_cam_per_bank;                    // per-bank indications of CAM entry replacement taking place
wire [NUM_TOTAL_BSMS-1:0]     i_sel_replace_pre_per_bank;            // per-bank indications of CAM entry replacement by PRE
wire [NUM_TOTAL_BSMS-1:0]     i_sel_replace_pre_per_bank_w;          // per-bank indications of CAM entry replacement by PRE

wire [NUM_TOTAL_BSMS-1:0]     i_existing_effective_pri_per_bank;     // priority level of each entry in next table,
                                                                     //  after accounting for prefered priority from GS
wire                          i_sel_entry_pri;                       // priority CAM replacement entry
wire                          i_sel_effective_pri;                   // same as above after accounting for ts_pri_level

wire [NUM_TOTAL_BSMS-1:0]     r_open_page_per_bank_bypass;
reg                           r_ih_te_bsm_alloc;

//------------------------------- MAIN CODE -----------------------------------

assign                          te_dh_valid = te_ts_valid [NUM_TOTAL_BSMS-1:0];
assign                          te_dh_page_hit = te_ts_page_hit [NUM_TOTAL_BSMS-1:0];

// retrieve the page hit and priority of the selected entry in the CAM
assign i_sel_entry_pri     = r_cam_entry_pri [te_sel_entry [CMD_ENTRY_BITS -1:0]];

assign i_sel_page_hit      = r_cam_entry_pghit [te_sel_entry [CMD_ENTRY_BITS -1:0]];

assign i_close_page_pre    = ts_op_is_precharge;

assign i_close_page_autopre   = te_rdwr_autopre;

// the page close can be due to precharge or auto-pre
// separate signals because in 2x controller because both auto-pre and pre can be scheduled in the same cycle
assign i_close_page_bank_pre     = ts_bsm_num4pre;
assign i_close_page_bank_autopre = ts_bsm_num4rdwr;



wire rdwr_pol_sel;
assign rdwr_pol_sel = 1'b1; 

assign i_ts_act4rd = ts_op_is_activate & ( rdwr_pol_sel ? ~ts_te_sel_act_wr[ts_bsm_num4act] : ~ts_wr_mode);





assign i_open_page    = (i_ts_act4rd &
                        (~(
                           (i_incoming_over_existing[r_ih_rankbank_num]
                           ) & (ts_bsm_num4act==r_ih_rankbank_num) & (r_ih_te_bsm_alloc))));


// putting the entries of all banks into one big wire
genvar i;
generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : rd_entry_table_out_gen
  assign te_os_rd_entry_table[((i+1)*CMD_ENTRY_BITS)-1 : i*CMD_ENTRY_BITS] = entry_mem[i];
end
endgenerate

generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : rd_cmd_autopre_table_out_gen
  assign rd_nxt_cmd_autopre_table[((i+1)*AUTOPRE_BITS)-1 : i*AUTOPRE_BITS] = cmd_autopre_mem[i];
end
endgenerate

generate 
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : rd_cmd_length_table_out_gen
  assign rd_nxt_length_table[(i+1)*CMD_LEN_BITS-1:i*CMD_LEN_BITS] = length_mem[i];
end
endgenerate

generate 
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : rd_cmd_word_table_out_gen
  assign rd_nxt_word_table[(i+1)*WORD_BITS-1:i*WORD_BITS] = word_mem[i];
end
endgenerate


// array next xact entry one hot for each rank/bank
wire [NUM_CAM_ENTRIES-1:0] entry_oh_a [NUM_TOTAL_BSMS -1:0];
reg [NUM_CAM_ENTRIES-1:0] entry_in_ntt_next;

generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : entry_oh_a_gen
  assign entry_oh_a[i] = {{(NUM_CAM_ENTRIES-1){1'b0}},te_ts_valid[i]} << entry_mem[i];
end
endgenerate

//spyglass disable_block W415a
//SMD: Signal entry_in_ntt_next is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches   
always @(*) begin : entry_in_ntt_cmb_PROC
  integer y;
  entry_in_ntt_next = {NUM_CAM_ENTRIES{1'b0}};
  for (y = 0; y < NUM_TOTAL_BSMS; y=y+1) begin
    entry_in_ntt_next = entry_in_ntt_next | entry_oh_a[y];
  end
end
//spyglass enable_block W415a

assign rd_nxt_entry_in_ntt = entry_in_ntt_next;   
   
generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : rd_page_table_out_gen
  assign rd_nxt_page_table[((i+1)*PAGE_BITS)-1 : i*PAGE_BITS] = page_mem[i];
end
endgenerate


// 3 inputs to valid logic:
//     - existing valid
//     - new command (read from IH or write just enabled in CAM)
//     - result of CAM search for replacement
// generate vector from each with 1 bit per bank
//  (many valid bits, but other 2 will have at most 1 bit asserted)

wire [BSM_BITS-1:0]        cam_search_bank  = 
                                              r_ts_op_is_activate_wr_d_i ? r_ts_bsm_num4act_d :
                                                                         r_ts_bsm_num4rdwr; 

wire [NUM_TOTAL_BSMS-1:0]  sel_cam_per_bank = {{NUM_TOTAL_BSMS-1{1'b0}}, (i_sel_cam & te_sel_valid)} << i_cam_search_bank;


assign i_sel_cam = r_sel_cam;
assign i_cam_search_bank = cam_search_bank;



assign   te_ts_valid_nxt = (
                   (te_ts_valid & (~({{NUM_TOTAL_BSMS-1{1'b0}}, (i_sel_cam & (~te_sel_valid))} << i_cam_search_bank))) |
                   sel_cam_per_bank         |
                   i_sel_incoming_per_bank )
                   ;



always @(posedge co_te_clk or negedge core_ddrc_rstn)
begin
  // table entry valid bit
  if (~core_ddrc_rstn) begin
    te_ts_valid [NUM_TOTAL_BSMS -1:0]   <= {NUM_TOTAL_BSMS{1'b0}};
  end
  else begin
    // per bank valid register: previous valid and not issued command w/o
    //                          replacement or new valid command or replacement
    te_ts_valid <= te_ts_valid_nxt;
  end
end

assign i_choose_rd_bypass = 1'b0;
assign i_same_bank =  
                   r_ts_op_is_activate_wr_i ? (& (r_ts_bsm_num4act [BSM_BITS-1:0] ~^ ih_te_bsm_num)) & ih_te_bsm_alloc:
                                            i_same_bank_incoming_vs_rw;

// When an ACT is issued, compara page num with corresponding NTT and if it matchs, set ts_ts_page_hit=1
assign i_same_bank_incoming_vs_rw =
                                            (& (ts_bsm_num4rdwr [BSM_BITS-1:0] ~^ ih_te_bsm_num)) & ih_te_bsm_alloc;



assign i_page_hit_update_per_bsm = {{NUM_TOTAL_BSMS-1{1'b0}},((page_mem[r_ts_bsm_num4act] == r_ts_act_page) & r_ts_op_is_activate_for_upd)} << r_ts_bsm_num4act;

// flopped version of various signals
// because cam search needs 2 cycles to accomplish
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
  begin
    r_pri_level                           <= 1'b1;
    r_ih_entry_pri                        <= 1'b0;
    r_cam_entry_pri [NUM_CAM_ENTRIES -1:0] <= {NUM_CAM_ENTRIES{1'b0}};
    r_same_bank                           <= 1'b0; 
    r_ih_effective_pri                    <= 1'b0;
    r_open_page                           <= 1'b0;
    r_ih_te_bsm_alloc                     <= 1'b0;
    r_ih_pghit                            <= 1'b0;
    r_ts_bsm_num4act [BSM_BITS-1:0]       <= {BSM_BITS{1'b0}};
    r_ts_op_is_activate_for_upd           <= 1'b0;  
    r_ts_act_page                         <= {PAGE_BITS{1'b0}};
    r_sel_cam                             <= 1'b0;
    r_sel_incoming                        <= 1'b0;
    r_ih_rankbank_num [BSM_BITS-1:0]      <= {BSM_BITS{1'b0}};
    r_ts_bsm_num4rdwr [BSM_BITS-1:0]      <= {BSM_BITS{1'b0}};
    r_cam_entry_pghit [NUM_CAM_ENTRIES -1:0] <= {NUM_CAM_ENTRIES{1'b0}};
    r_ih_entry_num [CMD_ENTRY_BITS -1:0]  <= {CMD_ENTRY_BITS{1'b0}};
    r_close_page_pre                      <= 1'b0;
    r_close_page_autopre                  <= 1'b0;
    r_close_page_bank_pre                 <= {BSM_BITS{1'b0}};
    r_close_page_bank_autopre             <= {BSM_BITS{1'b0}};
    r_ts_bsm_num4act_d                    <= {BSM_BITS{1'b0}};
    r_ts_op_is_activate_wr                <= 1'b0;
    r_ts_op_is_activate_wr_d              <= 1'b0;
    r_ts_bsm_num4pre                      <= {BSM_BITS{1'b0}}; 
    r_ts_op_is_pre_for_ntt_upd            <= 1'b0;
  end
  else
  begin

    // delay DRAM op by 1 clock to sync with delay in selection networks
    r_sel_cam                             <= ts_op_is_rd | r_ts_op_is_activate_wr_i;
    r_ts_bsm_num4rdwr [BSM_BITS-1:0]      <= ts_bsm_num4rdwr [BSM_BITS-1:0];
    r_cam_entry_pri [NUM_CAM_ENTRIES -1:0] <= te_entry_pri [NUM_CAM_ENTRIES -1:0];
    r_pri_level                           <= ts_pri_level;
    r_ih_entry_pri      <= ih_te_hi_pri_int;
    r_ih_effective_pri  <= (ih_te_hi_pri_int==ts_pri_level);   // ts_pri_level indicates the preferred priority
    // both cam search and in xaction hit the same bank
    r_same_bank         <= i_same_bank;
    r_open_page         <= i_open_page;
    r_ih_te_bsm_alloc   <= ih_te_bsm_alloc;
    r_ih_pghit          <= (be_te_page_hit & (~(i_same_bank_incoming_vs_rw & te_rdwr_autopre)))
                                                   ;
    r_ts_bsm_num4act [BSM_BITS-1:0]       <= ts_bsm_num4act [BSM_BITS-1:0];
    r_ts_op_is_activate_for_upd <= ts_op_is_activate
                                       & ( ~ts_te_sel_act_wr[ts_bsm_num4act])
                                       // page-hit re-evaluation is enabled only if old policy or act for RD  
                                       // This is to make sure the page-hit information is delayed by one cycle against WR NTT
                                       // In new policy case, it relies on NTT update (in next cycle)
                                   ;
    r_ts_act_page               <= ts_act_page;

    // per-CAM-entry page hit indicators. invalidate after an auto-precharge.
    r_cam_entry_pghit  [NUM_CAM_ENTRIES -1:0] <= te_page_hit [NUM_CAM_ENTRIES -1:0] &
                                                      (~{NUM_CAM_ENTRIES{te_rdwr_autopre & ts_op_is_rd}});

    // In the following case (ACT for write followed by WR autopre), ACT and WR are on different bank
    // In this case, NTT update is triggerd by ACT in next cycle, and te_rdwr_autopre can be seen at the cycle
    // As the bank are independent, we should not mask page-hit info by te_rdwr_autopre (also read cannot be scheduled here)
    // hence it only valid with ts_op_is_rd 
    //             ____
    //  ACT _______|WR|_________
    //                 ____  
    //  WR  ___________|AP|_____
    //                 ____
    //  NTT Update ____|  |_____

    // delay in transaction by 1 clock to sync with DRAM op
    r_sel_incoming      <= ih_te_rd_valid & ih_te_bsm_alloc
                           & (~te_ih_rd_retry) & (~i_choose_rd_bypass)
                           ;

    r_ih_rankbank_num [BSM_BITS-1:0]  <= ih_te_bsm_num [BSM_BITS-1:0];
    r_ih_entry_num [CMD_ENTRY_BITS -1:0]  <= ih_te_entry_num[CMD_ENTRY_BITS -1:0];

    r_close_page_pre          <= i_close_page_pre;
    r_close_page_autopre      <= i_close_page_autopre;
    r_close_page_bank_pre     <= i_close_page_bank_pre;
    r_close_page_bank_autopre <= i_close_page_bank_autopre;
    r_ts_bsm_num4act_d        <= r_ts_bsm_num4act;
    r_ts_op_is_activate_wr    <= ts_op_is_activate & ( rdwr_pol_sel ? ts_te_sel_act_wr[ts_bsm_num4act] : ts_wr_mode) & (~reg_ddrc_dis_opt_ntt_by_act);
    r_ts_op_is_activate_wr_d  <= r_ts_op_is_activate_wr;
    r_ts_bsm_num4pre [BSM_BITS-1:0]       <= ts_bsm_num4pre [BSM_BITS-1:0];
    r_ts_op_is_pre_for_ntt_upd            <= i_close_page_pre & (~reg_ddrc_dis_opt_ntt_by_pre);


  end

// Non flopped version. This is not used for preference but for final page-hit info 
// For bypass ACT r_ih_pghit is needed
assign i_ih_pghit = te_page_hit[r_ih_entry_num];  

// compare preference of incoming transaction vs. replacement transaction
//  from CAM search (will be used only if incoming & CAM search are to same bank)
assign i_sel_effective_pri = (i_sel_entry_pri==r_pri_level); // r_pri_level indicates the preferred priority

wire i_opt_hit_gt_hpr;
assign i_opt_hit_gt_hpr = 1'b0 || reg_ddrc_opt_hit_gt_hpr;

assign i_incoming_over_cam = {r_sel_incoming,i_opt_hit_gt_hpr ? {r_ih_pghit, r_ih_effective_pri} : {r_ih_effective_pri,r_ih_pghit}} > {te_sel_valid, i_opt_hit_gt_hpr ? {(i_sel_page_hit | te_entry_critical_per_bsm[i_cam_search_bank]),i_sel_effective_pri} : {i_sel_effective_pri,(i_sel_page_hit | te_entry_critical_per_bsm[i_cam_search_bank])}}? r_same_bank:1'b0;   



assign i_sel_cam_per_bank  = ( {{NUM_TOTAL_BSMS-1{1'b0}}, i_sel_cam} << i_cam_search_bank
                             ) ;

assign i_sel_replace_pre_per_bank = {{NUM_TOTAL_BSMS-1{1'b0}},r_ts_op_is_pre_for_ntt_upd} << r_ts_bsm_num4pre;

assign i_sel_replace_pre_per_bank_w = i_sel_replace_pre_per_bank;

assign i_sel_vpr_page_hit = 1'b0;
wire [CMD_ENTRY_BITS-1:0] te_sel_vpr_entry = {CMD_ENTRY_BITS{1'b0}};
wire [PAGE_BITS-1:0]      te_sel_vpr_page = {PAGE_BITS{1'b0}};
wire [AUTOPRE_BITS-1:0]   te_sel_vpr_cmd_autopre = {AUTOPRE_BITS{1'b0}};             
wire [CMD_LEN_BITS-1:0] te_sel_vpr_length = {CMD_LEN_BITS{1'b0}};
wire [WORD_BITS-1:0]    te_sel_vpr_critical_word = {WORD_BITS{1'b0}};




// determine if incoming request should replace existing one next table
assign i_sel_incoming_per_bank = {{NUM_TOTAL_BSMS-1{1'b0}}, r_sel_incoming} << r_ih_rankbank_num;
genvar gen_banks;
generate
    for (gen_banks=0;gen_banks<NUM_TOTAL_BSMS; gen_banks=gen_banks+1)
    begin : gen_compare_ih_to_ntt
       assign i_cam_vpr_over_existing[gen_banks] = 1'b0;
       assign i_incoming_vpr_over_existing[gen_banks] = 1'b0;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(gen_banks * PAGE_BITS)' found in module 'te_rd_nxt'
//SJ: This coding style is acceptable and there is no plan to change it

        assign i_existing_effective_pri_per_bank[gen_banks] = (te_ts_hi_xact[gen_banks]==r_pri_level); // replacement priorities are:
        //   1. entry valid
        //   2. high priority indicator bit
        //   3. page hit
        // incoming request replaces existing request if it is better than
        // the existing request based on the above 3 criteria, in that order
        assign i_incoming_over_existing[gen_banks] = i_sel_incoming_per_bank[gen_banks]&

                                                     (i_opt_hit_gt_hpr ? 

                                                     // i_opt_hit_gt_hpr == 1, page-hit LPR > page-miss HPR
                                                     (~te_ts_valid[gen_banks]  |
                                                    ((r_ih_effective_pri & r_ih_pghit & ~i_existing_effective_pri_per_bank[gen_banks] & ~te_vpr_entry[gen_banks]) |
                                                    // the above line: incoming is HPR page-hit, while existing is LPR

                                                     (r_ih_effective_pri & ~i_existing_effective_pri_per_bank[gen_banks] & ~te_ts_page_hit[gen_banks] & ~te_vpr_entry[gen_banks] & ~te_entry_critical_per_bsm[gen_banks])) |
                                                    // the above line: incoming is HPR, while existing is LPR page-miss

                                                     (r_ih_pghit & ~te_ts_page_hit[gen_banks] & ~te_entry_critical_per_bsm[gen_banks] & ~te_vpr_entry[gen_banks])
                                                    // the above line: incoming page-hit and existing page-miss*/
                                                     ):

                                                     // i_opt_hit_gt_hpr == 0, page-miss HPR > page-hit LPR. (Same with previous behavior)
                                                     (~te_ts_valid[gen_banks]  |
                                                     (r_ih_effective_pri & ~i_existing_effective_pri_per_bank[gen_banks] & ~te_vpr_entry[gen_banks]) |
                                                     ((r_ih_effective_pri | ~i_existing_effective_pri_per_bank[gen_banks]) & r_ih_pghit & ~te_ts_page_hit[gen_banks] & ~te_vpr_entry[gen_banks] & ~te_entry_critical_per_bsm[gen_banks])));

                                                     // TODO Coding in this way, make code easier to read. How about timing ? e.g. te_ts_valid is common condition, do we need to make this complex but in favour of timing ?
                                                     // TODO Cover i_opt_hit_gt_hpr inline for HPR line or page-hit line ?


        // when MEMC_ENH_RDWR_SWITCH is enabled, MEMC_NTT_UPD_ACT is enabled as well, NTT will be updated after activate command, don't need page_hit_for_wr to drive page_hit_update
        assign page_hit_update_ext[gen_banks] = ((te_ts_page_hit[gen_banks] | r_open_page_per_bank[gen_banks]|r_open_page_per_bank_bypass[gen_banks] | i_page_hit_update_per_bsm[gen_banks]) & (~r_close_page_per_bank[gen_banks]));


//spyglass enable_block SelfDeterminedExpr-ML

  end
endgenerate

// page can be closed due to pre or autopre. both can happen in the same clock cycle in 2x controller.
// but they will be going to different banks. hence the OR in the following logic
assign r_close_page_per_bank =  ({{NUM_TOTAL_BSMS-1{1'b0}}, r_close_page_pre} << r_close_page_bank_pre) |
                                ({{NUM_TOTAL_BSMS-1{1'b0}}, r_close_page_autopre} << r_close_page_bank_autopre)

;

assign r_open_page_per_bank  = {{NUM_TOTAL_BSMS-1{1'b0}}, r_open_page} << r_ts_bsm_num4act;
assign r_open_page_per_bank_bypass  = {NUM_TOTAL_BSMS{1'b0}};   
//--------------------------------------------------
// Begin Main VPR related logic
//--------------------------------------------------
//--------------------------------------------------
// End Main VPR related logic
//--------------------------------------------------
   wire [PAGE_BITS-1:0]    r_rd_en_page;
   wire [AUTOPRE_BITS-1:0] r_rd_en_cmd_autopre;
   wire [CMD_LEN_BITS-1:0] r_rd_en_cmd_length;
   wire [WORD_BITS-1:0]    r_rd_en_critical_word;
    

// TODO get page and autopre directly from IH, get rid of the MUX
// te_rd_page_table and te_rd_cmd_autopre_table will not be required here simlify the CAM/NTT interface
 
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(1024 * 8)' found in module 'te_rd_nxt'
//SJ: This coding style is acceptable and there is no plan to change it - reported for `UMCTL_LOG2.

  te_mux
   #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (PAGE_BITS)
   )
   rd_en_page_mux (
     .in_port   (te_rd_page_table),
     .sel       (r_ih_entry_num),
     .out_port  (r_rd_en_page)
   );
   te_mux
    #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (AUTOPRE_BITS)
   )
   rd_en_cmd_autopre_mux (
     .in_port   (te_rd_cmd_autopre_table),
     .sel       (r_ih_entry_num),
     .out_port  (r_rd_en_cmd_autopre)
   );

   te_mux
    #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (CMD_LEN_BITS)
   )
   rd_en_cmd_length_mux (
     .in_port   (te_rd_cmd_length_table),
     .sel       (r_ih_entry_num),
     .out_port  (r_rd_en_cmd_length)
   );

  te_mux
   #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (WORD_BITS)
   )
   rd_en_critical_word_mux (
     .in_port   (te_rd_critical_word_table),
     .sel       (r_ih_entry_num),
     .out_port  (r_rd_en_critical_word)
   );



//spyglass enable_block SelfDeterminedExpr-ML

generate 
   for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
     begin : te_nxt_update_gen   
  te_nxt_vp_update
   #(.DATAW (1))
  te_ts_page_hit_nxt_update (
     .ih_data          (i_ih_pghit),               // data coming from IH
     .replace_data     (i_sel_page_hit),           // data coming from te_replace
     .data_reg         (page_hit_update_ext[i]),   // data reg
     .load             (i_sel_cam_per_bank[i]),    // load NTT, after RD/WR scheduled
     .ih_over_replace  (i_incoming_over_cam),      // prefer IH to the te_replace
     .ih_over_existing (i_incoming_over_existing[i]), // prefer IH to the exisiting
     .replace_vp_data     (i_sel_vpr_page_hit),       // data coming from te_replace vprw selnet
     .load_vp             (i_cam_vpr_over_existing[i]), // trigger load from VPRW selnet
     .ih_over_existing_vp (i_incoming_vpr_over_existing[i]), // prefer IH expired VPRW to the exisiting                
     .load_pre         (i_sel_replace_pre_per_bank_w[i]),
     .replace_pre_data (1'b0), // Because it is triggerd by PRE
     .data_next        (te_ts_page_hit_next[i]) 
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (1'b0)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
     );

  te_nxt_vp_update
   #(.DATAW (CMD_ENTRY_BITS))
        entry_mem_nxt_update (
     .ih_data          (r_ih_entry_num),           // data coming from IH
     .replace_data     (te_sel_entry),             // data coming from te_replace
     .data_reg         (entry_mem[i]),             // data reg
     .load             (i_sel_cam_per_bank[i]),    // load NTT, after RD/WR scheduled
     .ih_over_replace  (i_incoming_over_cam),      // prefer IH to the te_replace
     .ih_over_existing (i_incoming_over_existing[i]), // prefer IH to the exisiting
     .replace_vp_data     (te_sel_vpr_entry),       // data coming from te_replace vprw selnet
     .load_vp             (i_cam_vpr_over_existing[i]), // trigger load from VPRW selnet
     .ih_over_existing_vp (i_incoming_vpr_over_existing[i]), // prefer IH expired VPRW to the exisiting              
     .load_pre         (i_sel_replace_pre_per_bank_w[i]),
     .replace_pre_data (te_sel_entry_pre),
     .data_next        (entry_mem_next[i]) 
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b1)
       ,.wc_enabled             (1'b0)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
     );

  te_nxt_vp_update
   #(.DATAW (PAGE_BITS))
  page_mem_nxt_update (
     .ih_data          (r_rd_en_page),           // data coming from IH
     .replace_data     (te_sel_rd_page),             // data coming from te_replace
     .data_reg         (page_mem[i]),             // data reg
     .load             (i_sel_cam_per_bank[i]),    // load NTT, after RD/WR scheduled
     .ih_over_replace  (i_incoming_over_cam),      // prefer IH to the te_replace
     .ih_over_existing (i_incoming_over_existing[i]), // prefer IH to the exisiting
     .replace_vp_data     (te_sel_vpr_page),       // data coming from te_replace vprw selnet
     .load_vp             (i_cam_vpr_over_existing[i]), // trigger load from VPRW selnet
     .ih_over_existing_vp (i_incoming_vpr_over_existing[i]), // prefer IH expired VPRW to the exisiting         
     .load_pre         (i_sel_replace_pre_per_bank_w[i]),
     .replace_pre_data (te_sel_rd_page_pre),
     .data_next        (page_mem_next[i]) 
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (1'b0)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
     );


  te_nxt_vp_update
   #(.DATAW (AUTOPRE_BITS))
  cmd_autopre_mem_nxt_update (
     .ih_data          (r_rd_en_cmd_autopre),           // data coming from IH
     .replace_data     (te_sel_rd_cmd_autopre),             // data coming from te_replace
     .data_reg         (cmd_autopre_mem[i]),             // data reg
     .load             (i_sel_cam_per_bank[i]),    // load NTT, after RD/WR scheduled
     .ih_over_replace  (i_incoming_over_cam),      // prefer IH to the te_replace
     .ih_over_existing (i_incoming_over_existing[i]), // prefer IH to the exisiting
     .replace_vp_data     (te_sel_vpr_cmd_autopre),       // data coming from te_replace vprw selnet
     .load_vp             (i_cam_vpr_over_existing[i]), // trigger load from VPRW selnet
     .ih_over_existing_vp (i_incoming_vpr_over_existing[i]), // prefer IH expired VPRW to the exisiting              
     .load_pre         (i_sel_replace_pre_per_bank_w[i]),
     .replace_pre_data (te_sel_rd_cmd_autopre_pre),
     .data_next        (cmd_autopre_mem_next[i]) 
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (1'b0)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
     );


  te_nxt_vp_update
   #(.DATAW (CMD_LEN_BITS))
  rd_cmd_length_mem_nxt_update (
     .ih_data             (r_rd_en_cmd_length),           // data coming from IH
     .replace_data        (te_sel_rd_length),             // data coming from te_replace
     .data_reg            (length_mem[i]),             // data reg
     .load                (i_sel_cam_per_bank[i]),    // load NTT, after RD/WR scheduled
     .ih_over_replace     (i_incoming_over_cam),      // prefer IH to the te_replace
     .ih_over_existing    (i_incoming_over_existing[i]), // prefer IH to the exisiting
     .replace_vp_data     (te_sel_vpr_length),       // data coming from te_replace vprw selnet
     .load_vp             (i_cam_vpr_over_existing[i]), // trigger load from VPRW selnet
     .ih_over_existing_vp (i_incoming_vpr_over_existing[i]), // prefer IH expired VPRW to the exisiting              
     .load_pre            (i_sel_replace_pre_per_bank_w[i]),
     .replace_pre_data    (te_sel_rd_cmd_length_pre),
     .data_next           (length_mem_next[i]) 
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (1'b0)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
     );


  te_nxt_vp_update
   #(.DATAW (WORD_BITS))
  rd_critical_word_mem_nxt_update (
     .ih_data             (r_rd_en_critical_word),           // data coming from IH
     .replace_data        (te_sel_rd_critical_word),             // data coming from te_replace
     .data_reg            (word_mem[i]),             // data reg
     .load                (i_sel_cam_per_bank[i]),    // load NTT, after RD/WR scheduled
     .ih_over_replace     (i_incoming_over_cam),      // prefer IH to the te_replace
     .ih_over_existing    (i_incoming_over_existing[i]), // prefer IH to the exisiting
     .replace_vp_data     (te_sel_vpr_critical_word),       // data coming from te_replace vprw selnet
     .load_vp             (i_cam_vpr_over_existing[i]), // trigger load from VPRW selnet
     .ih_over_existing_vp (i_incoming_vpr_over_existing[i]), // prefer IH expired VPRW to the exisiting              
     .load_pre            (i_sel_replace_pre_per_bank_w[i]),
     .replace_pre_data    (te_sel_rd_critical_word_pre),
     .data_next           (word_mem_next[i]) 
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (1'b0)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
     );




     end // block: te_nxt_update_gen
endgenerate
   
always @(posedge co_te_clk or negedge core_ddrc_rstn)
    if (~core_ddrc_rstn) begin
       for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1) begin
          te_ts_hi_xact [cnt] <= 1'b0;
          te_ts_page_hit [cnt] <= 1'b0;
          entry_mem [cnt] <= {CMD_ENTRY_BITS{1'b0}};
          page_mem [cnt]  <= {PAGE_BITS {1'b0}};
          cmd_autopre_mem [cnt] <= {AUTOPRE_BITS {1'b0}};
          length_mem [cnt] <= {CMD_LEN_BITS{1'b0}};
          word_mem [cnt] <= {WORD_BITS{1'b0}};
       end
    end // if (~core_ddrc_rstn)
   
    else begin
       for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1) begin
    te_ts_hi_xact   [cnt] <=
            i_sel_cam_per_bank[cnt] ? ( i_incoming_over_cam ? r_ih_entry_pri : i_sel_entry_pri ) :
            i_incoming_over_existing[cnt] ? r_ih_entry_pri :
                                te_ts_hi_xact[cnt]
;
    // Note: if page is opened for write, it will not be marked as a page hit.  We will need to close and re-open it.
    te_ts_page_hit [cnt]  <= te_ts_page_hit_next[cnt];
    entry_mem [cnt]       <= entry_mem_next [cnt];
    page_mem [cnt]        <= page_mem_next [cnt];
    cmd_autopre_mem [cnt] <= cmd_autopre_mem_next [cnt];
    length_mem [cnt] <= length_mem_next [cnt];
    word_mem [cnt] <= word_mem_next [cnt];
       end // for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1)
    end // else: !if(~core_ddrc_rstn)



// combine valid cam entry with page hit info into one signal
wire [NUM_TOTAL_BSMS-1:0] i_te_bs_rd_bank_page_hit;
assign i_te_bs_rd_bank_page_hit = te_ts_valid & te_ts_page_hit;

// used by pageclose_timer to know if bank is closed
assign te_bs_rd_bank_page_hit = i_te_bs_rd_bank_page_hit;




`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON
// disable coverage collection as this is SVA only
// VCS coverage off

// check that same entry number is not loaded to multiple RD NTT fields
bit same_entry_loaded_to_multi_flds;
int same_entry_fld1, same_entry_fld2; // for failure info

always @(*) begin
  same_entry_loaded_to_multi_flds = 0;
  same_entry_fld1 = 0;
  same_entry_fld2 = 0;
  for (int i=0; i<NUM_TOTAL_BSMS; i++) begin
    if (te_ts_valid[i]) begin
      for (int j=0; j<NUM_TOTAL_BSMS; j++) begin
        if (j==i) continue;

        if (te_ts_valid[j] && (entry_mem[j] == entry_mem[i])) begin
          same_entry_loaded_to_multi_flds = 1;
          same_entry_fld1 = i;
          same_entry_fld2 = j;
        end
      end
    end
  end
end

a_no_same_rd_entry_loaded_to_multi_flds : assert property (
  @(posedge co_te_clk) disable iff (!core_ddrc_rstn)
  !$stable(te_os_rd_entry_table) |-> !same_entry_loaded_to_multi_flds
) else $error("%m @ %t RD NTT field %0d and %0d are loaded to same entry", $time, same_entry_fld1, same_entry_fld2);

// check if the incoming command (of any pri) replaces an existing command, when an ACT happens to the same bank as the incoming cmd
cp_any_incoming_over_exist_w_act_to_same_bank :
cover property (@(posedge co_te_clk) disable iff(!core_ddrc_rstn) 
                  (i_ts_act4rd & (ts_bsm_num4act==r_ih_rankbank_num) & i_incoming_over_existing[r_ih_rankbank_num]));


// Incoming command is picked over the commands coming from CAM
cp_incoming_over_cam :
cover property (@(posedge co_te_clk) disable iff(!core_ddrc_rstn)  i_incoming_over_cam );




sequence s_sel_act_rd_ntt_rd;
    (ts_op_is_activate && ~ts_te_sel_act_wr[ts_bsm_num4act]
    && ~i_incoming_over_existing[ts_bsm_num4act]
    ##1
    ~i_sel_cam_per_bank[$past(ts_bsm_num4act,1)] && ~i_incoming_over_existing[$past(ts_bsm_num4act,1)]
    && ~i_sel_replace_pre_per_bank_w[$past(ts_bsm_num4act,1)]
    );
endsequence:s_sel_act_rd_ntt_rd    

property p_sel_act_rd_ntt_rd_pghit0;
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
        s_sel_act_rd_ntt_rd |-> ~te_ts_page_hit[$past(ts_bsm_num4act,1)] ##1 te_ts_page_hit[$past(ts_bsm_num4act,2)];
endproperty

a_sel_act_rd_ntt_rd_pghit0: assert property (p_sel_act_rd_ntt_rd_pghit0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

sequence s_sel_act_wr_ntt_rd;
    (ts_op_is_activate && ts_te_sel_act_wr[ts_bsm_num4act]
    ##1
    ~te_rdwr_autopre // maybe a exvpr-pghit coming at this cycle
    // `ifdef UMCTL2_VPR_EN
    // otherwise the te_ts_page_hit will be asserted one cycle eariler
    // comparing with i_sel_cam_per_bank
    // && ~i_cam_vpr_over_existing[$past(ts_bsm_num4act,2)] && ~i_incoming_vpr_over_existing[$past(ts_bsm_num4act,2)]
    // `endif
    ##1
    te_ts_valid[$past(ts_bsm_num4act,2)] && (page_mem_next[$past(ts_bsm_num4act,2)]==$past(ts_te_act_page,2)) //&& ~te_rdwr_autopre
    );
endsequence:s_sel_act_wr_ntt_rd    
    
property p_sel_act_wr_ntt_rd_pghit0;
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
        s_sel_act_wr_ntt_rd |-> (i_sel_cam_per_bank[$past(ts_bsm_num4act,2)] ) /* && ~te_ts_page_hit[$past(ts_bsm_num4act,2)] */ ##1 te_ts_page_hit[$past(ts_bsm_num4act,3)]; // maybe a exvpr-pghit coming at this cycle
endproperty

a_sel_act_wr_ntt_rd_pghit0: assert property (p_sel_act_wr_ntt_rd_pghit0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_pre_ntt_rd_pghit0;    
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn)
        ts_op_is_precharge && te_ts_page_hit[ts_bsm_num4pre] ##1 te_ts_page_hit[$past(ts_bsm_num4pre,1)] |-> ##1 ~te_ts_page_hit[$past(ts_bsm_num4pre,2)];
endproperty

a_pre_ntt_rd_pghit0: assert property (p_pre_ntt_rd_pghit0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

c_pre_ntt_rd_pghit0_1clk: cover property ( @(posedge co_te_clk)
    core_ddrc_rstn throughout ts_op_is_precharge && te_ts_page_hit[ts_bsm_num4pre] ##1 ~te_ts_page_hit[$past(ts_bsm_num4pre,1)]);

c_pre_ntt_rd_pghit0_2clk: cover property ( @(posedge co_te_clk)
    core_ddrc_rstn throughout ts_op_is_precharge && te_ts_page_hit[ts_bsm_num4pre] ##2 ~te_ts_page_hit[$past(ts_bsm_num4pre,2)]);


// Page-hit Checker
reg [3*NUM_TOTAL_BSMS*(CMD_ENTRY_BITS+1+1)-1:0] ntt_stable_reg;
reg [NUM_TOTAL_BSMS-1:0]                        ntt_exception; // Hold exception
reg [2*NUM_TOTAL_BSMS-1:0]                      ntt_stable_d;
reg [NUM_TOTAL_BSMS-1:0]                        ntt_stable_exception_d;
wire [NUM_TOTAL_BSMS-1:0]                       ntt_stable;
reg [NUM_TOTAL_BSMS-1:0]                        ntt_ts_op_is_activate_per_bsm;

generate
genvar bsm_i;
  for (bsm_i=0; bsm_i<NUM_TOTAL_BSMS; bsm_i++) begin

    always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
        ntt_stable_reg[bsm_i*3+:3]           <= {3*(CMD_ENTRY_BITS+2){1'b0}};
        ntt_exception[bsm_i]                 <= 1'b0;
        ntt_stable_d[(bsm_i*2)+:2]           <= 2'b00;
        ntt_stable_exception_d[bsm_i]        <= 1'b0;
        ntt_ts_op_is_activate_per_bsm[bsm_i] <= 1'b0;
      end
      else begin
        ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] <= {te_ts_valid[bsm_i] ,te_page_hit[entry_mem[bsm_i]], entry_mem[bsm_i]};
        ntt_stable_reg[(bsm_i*3+1)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] <=  ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)];
        ntt_stable_reg[(bsm_i*3+2)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] <=  ntt_stable_reg[(bsm_i*3+1)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)];
        ntt_stable_d[(bsm_i*2)+:2]                                         <=  {ntt_stable_d[(bsm_i*2)],ntt_stable[bsm_i]};
        ntt_stable_exception_d[bsm_i]                                      <=  ntt_stable[bsm_i] & ntt_exception[bsm_i];
        ntt_ts_op_is_activate_per_bsm[bsm_i]                               <= ts_op_is_activate & (ts_bsm_num4act == bsm_i);
        if ((i_incoming_vpr_over_existing[bsm_i] | i_incoming_over_existing[bsm_i]) & ((ts_op_is_activate & (ts_bsm_num4act == bsm_i)) | ntt_ts_op_is_activate_per_bsm[bsm_i])) begin
          ntt_exception[bsm_i] <= 1'b0;
        end
        else if (ntt_stable_exception_d[bsm_i] & ~ntt_stable[bsm_i]) begin // failing edge of ntt_stable (1 cycle delay)
          ntt_exception[bsm_i] <= 1'b0;
        end
      end
    end

    assign ntt_stable[bsm_i] = (ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] == {te_ts_valid[bsm_i] ,te_page_hit[entry_mem[bsm_i]], entry_mem[bsm_i]}) &
                        (ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] == ntt_stable_reg[(bsm_i*3+1)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)]);

    // Check that page_hit information is correct
    a_rd_nxt_page_hit_check : assert property (
      @(posedge co_te_clk) disable iff (!core_ddrc_rstn)
      (ntt_stable[bsm_i] && (te_ts_valid[bsm_i] && te_page_hit[entry_mem[bsm_i]]) && ~ntt_exception[bsm_i] |-> te_ts_page_hit[bsm_i] == 1'b1)
    ) else $error("%m @ %t Entry loaded into NTT is page-hit, but te_ts_page_hit is 0 bsm=%d, entry=%d ", $time, bsm_i, entry_mem[bsm_i]);

  end
endgenerate

// VCS coverage on
`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule // te_rd_nxt
