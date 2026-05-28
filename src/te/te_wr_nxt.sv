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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_wr_nxt.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// Next Transaction Table provides the page hit info to the
//   scheduler to schedule dram operation properly.  In addition, the table
//   stores the CAM entry number for the next scheduled transaction.
//
// The table is updated when there is a new transaction coming in or there is
//   a CAM search.  The update is according to the order of the following rules
//   1. oldest with page hit
//   2. youngest with page hit
//   3. oldest without page hit
//   4. youngest without page hit
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_wr_nxt #(
    //------------------------------- PARAMETERS -----------------------------------
     parameter  RANK_BITS          = `UMCTL2_LRANK_BITS 
    ,parameter  BG_BITS            = `MEMC_BG_BITS 
    ,parameter  BANK_BITS          = `MEMC_BANK_BITS 
    ,parameter  BG_BANK_BITS       = `MEMC_BG_BANK_BITS 
    ,parameter  CMD_ENTRY_BITS     = `MEMC_WRCMD_ENTRY_BITS     // bits required to address into the CAM
    ,parameter  PAGE_BITS          = `MEMC_PAGE_BITS            // arbitrarily defaulted to the size of the write CAM
    ,parameter  RANKBANK_BITS      = RANK_BITS + BG_BANK_BITS 
    ,parameter  BSM_BITS           = `UMCTL2_BSM_BITS
    ,parameter  NUM_TOTAL_BANKS    = 1 << RANKBANK_BITS 
    ,parameter  NUM_TOTAL_BSMS     = `UMCTL2_NUM_BSM
    ,parameter  NUM_CAM_ENTRIES    = (1 << CMD_ENTRY_BITS) 
    ,parameter  AUTOPRE_BITS       = 1 
    ,parameter  MWR_BITS           = 1 
    ,parameter  PW_WORD_CNT_WD_MAX = 2
    ,parameter  PARTIAL_WR_BITS_LOG2 = 1 
    ,parameter  IE_TAG_BITS        = 0 // Overridden 
    )
    (    
    //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                               core_ddrc_rstn                  // main reset
    ,input                                               co_te_clk                       // main clock
    ,output [NUM_TOTAL_BSMS-1:0]                         te_dh_valid                     // next transaction is valid
    ,output [NUM_TOTAL_BSMS-1:0]                         te_dh_page_hit                  // next transaction is page hit
    ,input                                               i_wr_enabled                    // valid read/write command from ih
    ,input [CMD_ENTRY_BITS-1:0]                          te_sel_entry                    // entry number from selection networks
    ,input [PAGE_BITS-1:0]                               te_sel_wr_page 
    ,input [AUTOPRE_BITS-1:0]                            te_sel_wr_cmd_autopre           // cmd_autopre of selected CAM entry
    ,input [MWR_BITS-1:0]                                te_sel_mwr                      // masked write of selected CAM entry
    ,input [PW_WORD_CNT_WD_MAX-1:0]                      te_sel_pw_num_cols_m1           // partial write of selected CAM entry
    ,input [PARTIAL_WR_BITS_LOG2-1:0]                    te_sel_wr_mr_ram_raddr_lsb
    ,input [PW_WORD_CNT_WD_MAX-1:0]                      te_sel_wr_mr_pw_num_beats_m1
    ,input                                               te_sel_valid                    // entry number from selection networks is valid
    ,input  [NUM_CAM_ENTRIES -1:0]                       te_page_hit                     // stored xact address in CAM currently has an open page hit
    ,input  [NUM_CAM_ENTRIES -1:0]                       te_wr_cam_page_hit              // passthrough page-hit infomation from CAM 
    ,input  [BSM_BITS-1:0]                               i_wr_en_bsm_num                 // incoming xact BSM number
    ,input                                               i_wr_en_bsm_alloc               // 
    ,input  [CMD_ENTRY_BITS-1:0]                         i_wr_en_entry_num               // incoming xact CAM entry number
    ,input                                               reg_ddrc_dis_opt_ntt_by_act  
    ,input                                               reg_ddrc_dis_opt_ntt_by_pre  
    ,input                                               be_op_is_activate_bypass        // Bypass ACT
    ,input  [BSM_BITS-1:0]                               te_bypass_rank_bg_bank_num      // BSM num for Bypass ACT  
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style for now.
    ,input                                               te_ih_wr_retry                  // collision detected
//spyglass enable_block W240
    ,input  [NUM_TOTAL_BSMS-1:0]                         te_wr_col_bank                  // entry of colliding bank (1bit for 1bank)
    ,input  [BSM_BITS-1:0]                               ih_te_bsm_num                   // write combine xact BSM number
    ,input                                               ih_te_bsm_alloc                 // bsm alloc info  When DYN_BSM is not defined,this port should be set to 1.
    ,input                                               te_yy_wr_combine                // combine incoming write from IH w/ a previous write
    ,output reg                                          te_gs_block_wr                  // Block Write this cycle, as replace logic is used this cycle
    ,input                                               be_te_page_hit                  // incoming xact currently has an open page hit
    ,input  [PAGE_BITS-1:0]                              ts_act_page                     // Activated page from TS
    ,input  [PAGE_BITS-1:0]                              ih_te_rd_page_num
    ,output [NUM_TOTAL_BSMS-1:0]                         te_bs_wr_bank_page_hit
    ,input  [NUM_CAM_ENTRIES*PAGE_BITS-1:0]              te_wr_page_table                // page addresses of all CAM entries
    ,input  [NUM_CAM_ENTRIES*AUTOPRE_BITS-1:0]           te_wr_cmd_autopre_table         // cmd_autopre  of all CAM entries   
    ,input  [NUM_CAM_ENTRIES*PARTIAL_WR_BITS_LOG2-1:0]   te_wr_mr_ram_raddr_lsb_first_table
    ,input  [NUM_CAM_ENTRIES*PW_WORD_CNT_WD_MAX-1:0]     te_wr_mr_pw_num_beats_m1_table
    ,input  [BSM_BITS-1:0]                               ts_bsm_num4pre                  // DRAM op BSM number
    ,input  [BSM_BITS-1:0]                               ts_bsm_num4act                  // DRAM op BSM number for reads/writes only (best timging)
    ,input  [BSM_BITS-1:0]                               ts_bsm_num4rdwr                 // DRAM op BSM number for reads/writes only (best timging)
    ,input                                               te_rdwr_autopre                 // a read or a write issued this cycle with auto-precharge
    ,input   [NUM_CAM_ENTRIES*MWR_BITS-1:0]              te_mwr_table                    // Entire masked write contents of all CAM entries
    ,output  [NUM_TOTAL_BSMS-1:0]                        te_os_mwr_table                 // Entire masked write contents of the NTT
    ,input   [NUM_CAM_ENTRIES*PW_WORD_CNT_WD_MAX-1:0]    te_pw_num_cols_m1_table         // Entire partial write contents of all CAM entries
    ,input                                               ts_op_is_rdwr                   // DRAM op is a read or write operation
    ,input                                               ts_op_is_precharge              // DRAM op is precharge operation
    ,input                                               ts_op_is_activate               // DRAM op is activate operation
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style for now.
    ,input                                               ts_wr_mode                      // 1=GS issuing writes  0=GS issuing reads
//spyglass enable_block W240
    ,output reg [NUM_TOTAL_BSMS-1:0]                     te_ts_page_hit                  // next transaction has an open page hit
    ,output reg [NUM_TOTAL_BSMS-1:0]                     te_ts_valid                     // next transaction is valid
    ,output [NUM_TOTAL_BSMS*CMD_ENTRY_BITS-1:0]          te_os_wr_entry_table            // outputs the entire contents of the nxt_table
                                                                                         // entry num belonging to all the banks are put on a single bus
                                                                                         // TS will do the entry selection instead of this module
    ,output [NUM_TOTAL_BSMS-1:0]                         te_pghit_vld                    // page hits per bsm
    ,output [NUM_TOTAL_BSMS*PAGE_BITS-1:0]               wr_nxt_page_table               // outputs the page for each rank/bank 
    ,output [NUM_TOTAL_BSMS*AUTOPRE_BITS-1:0]            wr_nxt_cmd_autopre_table  
    ,output [NUM_TOTAL_BSMS*PARTIAL_WR_BITS_LOG2-1:0]    wr_nxt_mr_ram_raddr_lsb_first_table
    ,output [NUM_TOTAL_BSMS*PW_WORD_CNT_WD_MAX-1:0]      wr_nxt_mr_pw_num_beats_m1_table
    ,output [NUM_CAM_ENTRIES-1:0]                        wr_nxt_entry_in_ntt   
    ,input [CMD_ENTRY_BITS-1:0]                          te_sel_entry_pre                // entry number from selection networks
    ,input [PAGE_BITS-1:0]                               te_sel_wr_page_pre
    ,input [AUTOPRE_BITS-1:0]                            te_sel_wr_cmd_autopre_pre       // cmd_autopre of selected CAM entry
    ,input [MWR_BITS-1:0]                                te_sel_mwr_pre                  // masked write of selected CAM entry
    ,input [PW_WORD_CNT_WD_MAX-1:0]                      te_sel_pw_num_cols_m1_pre       // partial write of selected CAM entry
    ,input [PARTIAL_WR_BITS_LOG2-1:0]                    te_sel_wr_mr_ram_raddr_lsb_pre
    ,input [PW_WORD_CNT_WD_MAX-1:0]                      te_sel_wr_mr_pw_num_beats_m1_pre
   
    ,input  [NUM_TOTAL_BSMS-1:0]                         te_wr_entry_critical_per_bsm

    ,input  [NUM_TOTAL_BSMS-1:0]                         ts_te_sel_act_wr         //tell TE the activate command is for write or read.
    `ifndef SYNTHESIS
    `ifdef SNPS_ASSERT_ON
    ,input [PAGE_BITS-1:0]                               ts_te_act_page
    `endif // SNPS_ASSERT_ON
    `endif // SYNTHESIS
    );

//---------------------------- REGISTERS AND WIRES ------------------------------
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block and under different `ifdefs. 
wire [NUM_TOTAL_BSMS -1:0]      te_vpw_entry = {NUM_TOTAL_BSMS{1'b0}};          // next xact is a VPW entry
//spyglass enable_block W528
// NTT consists of valid, entry number, and page hit
wire [CMD_ENTRY_BITS-1:0]       entry_mem_next [NUM_TOTAL_BSMS -1:0];           // table to store the next xact entry number for each rank/bank
reg  [CMD_ENTRY_BITS-1:0]       entry_mem [NUM_TOTAL_BSMS -1:0];                // table to store the next xact entry number for each rank/bank
reg  [PAGE_BITS -1:0]           page_mem [NUM_TOTAL_BSMS -1:0];                 // table to store the next xact page for each rank/bank
wire [PAGE_BITS -1:0]           page_mem_next [NUM_TOTAL_BSMS -1:0];            // table to store the next xact page for each rank/bank   
reg  [AUTOPRE_BITS -1:0]        cmd_autopre_mem [NUM_TOTAL_BSMS -1:0];          // table to store the next xact cmd_autopre for each rank/bank
wire [AUTOPRE_BITS -1:0]        cmd_autopre_mem_next [NUM_TOTAL_BSMS -1:0];     // table to store the next xact cmd_autopre for each rank/bank         
reg  [MWR_BITS-1:0]             mwr_mem [NUM_TOTAL_BSMS -1:0];                  // table to store the next xact mwr for each rank/bank
wire [MWR_BITS-1:0]             mwr_mem_next [NUM_TOTAL_BSMS -1:0];             // table to store the next xact mwr for each rank/bank   
reg  [PW_WORD_CNT_WD_MAX-1:0]   pw_num_cols_m1_mem [NUM_TOTAL_BSMS -1:0];       // table to store the next xact PW cols for each rank/bank
wire [PW_WORD_CNT_WD_MAX-1:0]   pw_num_cols_m1_mem_next [NUM_TOTAL_BSMS -1:0];  // table to store the next xact PW cols for each rank/bank
reg   [PARTIAL_WR_BITS_LOG2-1:0]  mr_ram_raddr_mem [NUM_TOTAL_BSMS-1:0];          // ram raddr LSB
wire  [PARTIAL_WR_BITS_LOG2-1:0]  mr_ram_raddr_mem_next [NUM_TOTAL_BSMS-1:0];          // ram raddr LSB

reg   [PW_WORD_CNT_WD_MAX-1:0]    pw_num_beats_m1_mem [NUM_TOTAL_BSMS-1:0];          // ram raddr LSB
wire  [PW_WORD_CNT_WD_MAX-1:0]    pw_num_beats_m1_mem_next [NUM_TOTAL_BSMS-1:0];          // ram raddr LSB
reg                             r_ts_op_is_activate_rd;
reg                             r_ts_op_is_activate_rd_d;
wire                            r_ts_op_is_activate_rd_d_i = 
                                r_ts_op_is_activate_rd_d
;
wire                            r_ts_op_is_activate_rd_i = 
                                r_ts_op_is_activate_rd
;
reg                             r_ts_op_is_activate_for_upd;                    // For NTT re-evaluation in terms of page-hit
reg  [PAGE_BITS-1:0]            r_ts_act_page;


reg  [BSM_BITS-1:0]             r_ts_bsm_num4pre;                               // flopped version of BSM number from scheduler
reg                             r_ts_op_is_pre_for_ntt_upd;                     // flopped version of ts_op_is_precharge (reg_ddrc_dis_opt_ntt_by_pre) is taken into account
reg  [BSM_BITS-1:0]             r_ts_bsm_num4rdwr;                              // flopped version of BSM number from scheduler - for rd/wr
wire                            i_incoming_over_cam;                            // indicates that new request should replace existing (in uPCTL2 should be always set to '0')
                                                                                //  existing request in next table
wire [NUM_TOTAL_BSMS-1:0]       i_cam_vpw_over_existing;                        // (in uPCTL2 should be always set to '0')
wire [NUM_TOTAL_BSMS-1:0]       i_incoming_vpw_over_existing;                   // (in uPCTL2 should be always set to '0')
wire                            i_sel_vpw_page_hit;                             // (in uPCTL2 should be always set to '0')
reg  [BSM_BITS-1:0]             r_ts_bsm_num4act;                               // flopped version of ts_bsm_num4act
reg  [BSM_BITS-1:0]             r_ts_bsm_num4act_d;                             // two flopped version of ts_bsm_num4act
reg                             r_wr_combine;                                   // write combine last cycle
reg  [BSM_BITS-1:0]             r_wc_bsm_num;                                   // flopped version of BSM number for write combine
reg                             r_same_bank;                                    // cam search and incoming are pointing to the same rank/bank
// page activity
wire                            i_open_page;                                    // open a page for reads
wire [BSM_BITS-1:0]             i_open_page_bank;                               // bank number of the page opened/activated
reg                             r_open_page;                                    // flopped indicator that a page has been opened/activated
reg  [BSM_BITS-1:0]             r_open_page_bank;                               // flopped bank number of the page opened/activated
wire                            i_ts_act4wr;                                    // TS activating a page to write from it
wire                            i_wr_combine   = te_yy_wr_combine & (~te_ih_wr_retry);




wire [NUM_TOTAL_BSMS-1:0]       i_sel_cam_per_bank;                             // per-bank indications of CAM entry replacement taking place
wire [NUM_TOTAL_BSMS-1:0]       i_sel_replace_pre_per_bank;
wire [NUM_TOTAL_BSMS-1:0]       i_sel_replace_pre_per_bank_w;
reg  [NUM_CAM_ENTRIES -1:0]     r_cam_entry_pghit;                              // flopped version of page hit info from CAM search:
                                                                                //  1 bit per CAM entry
reg                             r_sel_cam;                                      // flopped version of cam search
reg  [BSM_BITS-1:0]             r_wr_en_bsm_num;                                // flopped version of new incoming BSM number
wire                            i_wr_en_pghit;                                  // page hit info from CAM (non flopped)
reg  [CMD_ENTRY_BITS-1:0]       r_wr_en_entry_num;                              // flopped version of entry num from IH
assign                          te_pghit_vld   = (te_ts_valid [NUM_TOTAL_BSMS -1:0]   &
                                                    te_ts_page_hit [NUM_TOTAL_BSMS -1:0] );
assign                          te_dh_valid    = te_ts_valid [NUM_TOTAL_BSMS-1:0];
assign                          te_dh_page_hit = te_ts_page_hit [NUM_TOTAL_BSMS-1:0];
wire [NUM_TOTAL_BSMS-1:0]       te_ts_page_hit_next;   
reg                             r_sel_incoming;                                 // there is an incoming transaction
wire [NUM_TOTAL_BSMS-1:0]       i_page_hit_update_per_bsm;

wire [NUM_TOTAL_BSMS-1:0]       te_ts_valid_nxt;                                // next transaction is valid

wire                            i_same_bank;                                    // new command and executing command accessing same bank this cycle
wire                            i_same_bank_wr_combine_vs_rw;                   // Write combine bank and RDWR bank are the same (should be qualified by Read)
wire                            i_same_bank_incoming_vs_rw;                     // new command and executing RDWR accessing same bank this cycle
reg                             r_wr_en_pghit;                                  // flopped version of page hit info from IH
wire                            i_sel_page_hit = r_cam_entry_pghit [te_sel_entry [CMD_ENTRY_BITS -1:0]];
wire                            i_close_page_pre;                               // close a page due to pre
wire                            i_close_page_autopre;                           // close a page due to autopre
wire  [BSM_BITS-1:0]            i_close_page_bank_pre;                          // Bank selected for closing for a pre
wire  [BSM_BITS-1:0]            i_close_page_bank_autopre;                      // Bank selected for closing for autopre command
reg                             r_close_page_pre;                               // flopped indicator that a page is closed/precharged
reg                             r_close_page_autopre;                           // flopped indicator that a page is closed/precharged
reg   [BSM_BITS-1:0]            r_close_page_bank_pre;                          // flopped bank number of the page closed/precharged for a pre or autopre cmd
reg   [BSM_BITS-1:0]            r_close_page_bank_autopre;                      // flopped bank number of the page closed/precharged for a pre or autopre cmd
wire [NUM_TOTAL_BSMS-1:0]       r_open_page_per_bank;                           // per-bank indications of page openings
wire [NUM_TOTAL_BSMS-1:0]       r_close_page_per_bank;                          // per-bank indications of page closes
wire [NUM_TOTAL_BSMS-1:0]       i_incoming_over_existing;                       // per-bank indication of a page being closed
wire [NUM_TOTAL_BSMS-1:0]       i_sel_incoming_per_bank;                        // per-bank indications of incoming request


reg                             r_wr_en_bsm_alloc;
reg                             r_te_gs_block_wr;

// combinations of flopped inputs
wire [NUM_TOTAL_BSMS-1:0]       page_hit_update;                                // per-bank indications of page open or close
wire [NUM_TOTAL_BSMS-1:0]       page_hit_update_ext;                            // per-bank indications of page open or close (extended version)

assign i_close_page_pre          = ts_op_is_precharge;
assign i_close_page_autopre      = te_rdwr_autopre;
  
assign i_close_page_bank_pre     = ts_bsm_num4pre;
assign i_close_page_bank_autopre = ts_bsm_num4rdwr;

integer  cnt; // for loop dummy variable


wire rdwr_pol_sel;
assign rdwr_pol_sel = 1'b1; 

assign i_ts_act4wr    = ts_op_is_activate & ( rdwr_pol_sel ? ts_te_sel_act_wr[ts_bsm_num4act] : ts_wr_mode);



assign i_open_page    = i_ts_act4wr &
                        (~(
                          (i_incoming_over_existing[r_wr_en_bsm_num]
                          ) & (ts_bsm_num4act==r_wr_en_bsm_num) & (r_wr_en_bsm_alloc))) ;

assign i_open_page_bank      = ts_op_is_activate ? ts_bsm_num4act : i_wr_en_bsm_num;

// Putting all entries of all the banks into one big wire
genvar i;
generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : wr_entry_table_out_gen
  assign te_os_wr_entry_table[((i+1)*CMD_ENTRY_BITS)-1 : i*CMD_ENTRY_BITS] = entry_mem[i];
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

assign wr_nxt_entry_in_ntt = entry_in_ntt_next;   
   
generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : wr_page_table_out_gen
  assign wr_nxt_page_table[((i+1)*PAGE_BITS)-1 : i*PAGE_BITS] = page_mem[i];
end
endgenerate

generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : wr_cmd_autopre_table_out_gen
  assign wr_nxt_cmd_autopre_table[((i+1)*AUTOPRE_BITS)-1 : i*AUTOPRE_BITS] = cmd_autopre_mem[i];
end
endgenerate

generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : te_os_mwr_table_out_gen
  assign te_os_mwr_table[i] = |mwr_mem[i]  // still support only 1-bit info
  ;
end
endgenerate



generate 
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : wr_nxt_mr_ram_raddr_lsb_first_table_gen
  assign wr_nxt_mr_ram_raddr_lsb_first_table[((i+1)*PARTIAL_WR_BITS_LOG2)-1:i*PARTIAL_WR_BITS_LOG2] = mr_ram_raddr_mem[i];
end
endgenerate

generate 
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : wr_nxt_mr_pw_num_beats_m1_table_gen
  assign wr_nxt_mr_pw_num_beats_m1_table[((i+1)*PW_WORD_CNT_WD_MAX)-1:i*PW_WORD_CNT_WD_MAX] = pw_num_beats_m1_mem[i];
end
endgenerate

// 3 inputs to valid logic:
//     - existing valid
//     - new command (read from IH or write just enabled in CAM)
//     - result of CAM search for replacement
// generate vector from each with 1 bit per bank
//  (many valid bits, but other 2 will have at most 1 bit asserted)
// each vactor must be qualified to disable if a write combine is starting to same bank
//  (ideally, we would only disable a table entry if it contained the same CAM entry # as
//   the target of the write combine, but there's not enough time to make that determination
//   in a cycle)


// Determine which bank was used for the CAM search. CAM searches happen for 2 reasons:
//  1. write is issued and needs to be replaced (bank indicated by t_ts_bank_num)
//  2. write combine occurs and entry for that bank is removed from CAM (bank indicated by r_wc_bsm_num)
wire [BSM_BITS-1:0]        cam_search_bank  = r_wr_combine             ? r_wc_bsm_num: 
                       (r_ts_op_is_activate_rd_d_i | r_te_gs_block_wr) ? r_ts_bsm_num4act_d:
                                                                         r_ts_bsm_num4rdwr;
// check write combine is to the same bank as the incoming write
wire i_combine_incoming = ((ih_te_bsm_num == r_wr_en_bsm_num) && (ih_te_bsm_alloc) && (r_wr_en_bsm_alloc)) ? i_wr_combine : 1'b0;
// check write combine is to the same bank as the CAM search
wire i_combine_cam      = ((ih_te_bsm_num == cam_search_bank) && (ih_te_bsm_alloc)) ? i_wr_combine : 1'b0;
wire [NUM_TOTAL_BSMS-1:0]  sel_incoming_per_bank= {{NUM_TOTAL_BSMS - 1{1'b0}}, (r_sel_incoming & (~i_combine_incoming))}         << r_wr_en_bsm_num;
wire [NUM_TOTAL_BSMS-1:0]  sel_cam_per_bank  = {{NUM_TOTAL_BSMS - 1{1'b0}}, (r_sel_cam & te_sel_valid & (~i_combine_cam))} << cam_search_bank;





assign i_same_bank =
                     ( r_ts_op_is_activate_rd_i | te_gs_block_wr ) ?
                     (& (r_ts_bsm_num4act [BSM_BITS-1:0] ~^
                         i_wr_en_bsm_num [BSM_BITS-1:0]  )) & i_wr_en_bsm_alloc :
                     i_wr_combine ?
                     (& (ih_te_bsm_num [BSM_BITS-1:0]   ~^
                         i_wr_en_bsm_num [BSM_BITS-1:0]  )) & ih_te_bsm_alloc & i_wr_en_bsm_alloc :
                     i_same_bank_incoming_vs_rw;




assign i_same_bank_incoming_vs_rw =
                     (& (ts_bsm_num4rdwr [BSM_BITS-1:0] ~^
                         i_wr_en_bsm_num [BSM_BITS-1:0]  )) & i_wr_en_bsm_alloc ;

assign i_same_bank_wr_combine_vs_rw = 
                     i_wr_combine &
                     (& (ih_te_bsm_num [BSM_BITS-1:0]   ~^
                         ts_bsm_num4rdwr [BSM_BITS-1:0]  )) & ih_te_bsm_alloc;



// flopped version of various signals
// because cam search needs 2 cycles to accomplish
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
  begin
    r_sel_cam          <= 1'b0;
    r_sel_incoming        <= 1'b0;
    r_wr_en_bsm_num [BSM_BITS-1:0]           <= {BSM_BITS{1'b0}};
    r_wr_en_pghit        <= 1'b0;
    r_same_bank                              <= 1'b0;    
    r_wc_bsm_num [BSM_BITS-1:0]              <= {BSM_BITS{1'b0}};
    r_open_page_bank                         <= {BSM_BITS{1'b0}};
    r_open_page                              <= 1'b0;
    r_wr_combine                             <= 1'b0;
    r_wr_en_bsm_alloc                        <= 1'b0;    
    te_gs_block_wr                           <= 1'b0;
    r_te_gs_block_wr                         <= 1'b0;
    r_ts_bsm_num4act_d                       <= {BSM_BITS{1'b0}};
    r_ts_bsm_num4act                         <= {BSM_BITS{1'b0}};
    r_ts_op_is_activate_for_upd              <= 1'b0;
    r_ts_act_page                            <= {PAGE_BITS{1'b0}};
    r_ts_op_is_activate_rd                   <= 1'b0;
    r_ts_op_is_activate_rd_d                 <= 1'b0;
    r_ts_bsm_num4pre                         <= {BSM_BITS{1'b0}}; 
    r_ts_op_is_pre_for_ntt_upd               <= 1'b0;
    r_ts_bsm_num4rdwr[BSM_BITS-1:0]          <= {BSM_BITS{1'b0}};
    r_cam_entry_pghit [NUM_CAM_ENTRIES -1:0] <= {NUM_CAM_ENTRIES{1'b0}};
    r_wr_en_entry_num [CMD_ENTRY_BITS -1:0]  <= {CMD_ENTRY_BITS{1'b0}};
    r_close_page_pre                         <= 1'b0;
    r_close_page_autopre                     <= 1'b0;
    r_close_page_bank_pre                    <= {BSM_BITS{1'b0}};
    r_close_page_bank_autopre                <= {BSM_BITS{1'b0}};
  end
  else
  begin

    // delay DRAM op by 1 clock to sync with delay in selection networks

    r_ts_bsm_num4rdwr[BSM_BITS-1:0]       <= ts_bsm_num4rdwr[BSM_BITS-1:0];
    r_wr_en_pghit                         <= be_te_page_hit & (~(i_same_bank_incoming_vs_rw & te_rdwr_autopre)) & i_wr_en_bsm_alloc;
    r_wr_combine                          <= i_wr_combine & (ih_te_bsm_alloc);
    r_sel_cam                             <= ts_op_is_rdwr | (i_wr_combine & (ih_te_bsm_alloc)) | r_ts_op_is_activate_rd_i | te_gs_block_wr ;
    r_wc_bsm_num [BSM_BITS-1:0]           <= ih_te_bsm_num [BSM_BITS-1:0];
    // both cam search and in xaction hit the same bank
    r_same_bank                           <= i_same_bank;
    // NOTE: Pages opened for activate bypass for high priority reads
    //       are not tracked here.  A write to the same page will
    //       still be marked as a miss, resulting in closing and
    //       re-opening the page if switching from reads to writes
    //       while that page is still opened.
    r_open_page_bank                      <= i_open_page_bank;
    r_open_page                           <= i_open_page;

    r_close_page_pre                      <= i_close_page_pre;
    r_wr_en_bsm_alloc                     <= i_wr_en_bsm_alloc;    
    te_gs_block_wr                        <= te_yy_wr_combine & ih_te_bsm_alloc & 
                                             (
                                                (ts_op_is_activate        & (ih_te_bsm_num == ts_bsm_num4act            )) // Normal ACT
                                              | (be_op_is_activate_bypass & (ih_te_bsm_num == te_bypass_rank_bg_bank_num)) // Bypass ACT 
                                             ); 
    r_te_gs_block_wr                      <= te_gs_block_wr; 
    r_ts_bsm_num4act_d                    <= r_ts_bsm_num4act;
    r_ts_bsm_num4act                      <= (be_op_is_activate_bypass)? te_bypass_rank_bg_bank_num : ts_bsm_num4act [BSM_BITS-1:0];
    r_ts_op_is_activate_for_upd           <= (ts_op_is_activate
                                                & ( ts_te_sel_act_wr[ts_bsm_num4act])
                                                // page-hit re-evaluation is enabled only if old policy or act for WR  
                                                // This is to make sure the page-hit information is delayed by one cycle against RD NTT
                                                // In new policy case, it relies on NTT update (in next cycle)
                                             )
                                              | be_op_is_activate_bypass
                                            ;
    r_ts_act_page                         <= (ts_op_is_activate | (`UPCTL2_EN==1))?  ts_act_page : ih_te_rd_page_num;
    r_ts_op_is_activate_rd                <= ((ts_op_is_activate & ( rdwr_pol_sel ? ~ts_te_sel_act_wr[ts_bsm_num4act] : ~ts_wr_mode)) | be_op_is_activate_bypass) & (~reg_ddrc_dis_opt_ntt_by_act);
    r_ts_op_is_activate_rd_d              <= r_ts_op_is_activate_rd;
    r_ts_bsm_num4pre                      <= ts_bsm_num4pre; 
    r_ts_op_is_pre_for_ntt_upd            <= i_close_page_pre & (~reg_ddrc_dis_opt_ntt_by_pre);

    // per-CAM-entry page hit indicators. invalidate after an auto-precharge.
    r_cam_entry_pghit  [NUM_CAM_ENTRIES -1:0]  <= te_page_hit [NUM_CAM_ENTRIES -1:0] &
               (~{NUM_CAM_ENTRIES{(te_rdwr_autopre & (ts_op_is_rdwr | i_same_bank_wr_combine_vs_rw))}}) ; // ts_op_is_rdwr here meant ts_op_is_wr. te_rdwr_autopre is don't care when ts_op_is_wr=0 

    // In the following case (ACT for Read followed by RD autopre), ACT and RD are on different bank
    // In this case, NTT update is triggerd by ACT in next cycle, and te_rdwr_autopre can be seen at the cycle
    // As the bank are independent, we should not mask page-hit info by te_rdwr_autopre (also read cannot be scheduled here)
    // hence mask te_rdwr_autopre by r_ts_op_is_activate_wr
    //             ____
    //  ACT _______|RD|_________
    //                 ____  
    //  RD  ___________|AP|_____
    //                 ____
    //  NTT Update ____|  |_____

    // delay in transaction by 1 clock to sync with DRAM op
    r_sel_incoming               <= i_wr_enabled & i_wr_en_bsm_alloc;
    r_wr_en_bsm_num [BSM_BITS-1:0]           <= i_wr_en_bsm_num [BSM_BITS-1:0];
    r_wr_en_entry_num [CMD_ENTRY_BITS -1:0]  <= i_wr_en_entry_num[CMD_ENTRY_BITS -1:0];
    r_close_page_autopre         <= i_close_page_autopre;
    r_close_page_bank_pre        <= i_close_page_bank_pre;
    r_close_page_bank_autopre    <= i_close_page_bank_autopre;
  end

// Non flopped version (latest) page-hit infomation.
// To meet synthesis, this is not used for preference but used for te_ts_page_hit
assign i_wr_en_pghit = te_wr_cam_page_hit[r_wr_en_entry_num];

//------------------------------------------------------------------------------
// New stuff here!
//------------------------------------------------------------------------------

// compare preference of incoming transaction vs. replacement transaction
//  from CAM search (will be used only if incoming & CAM search are to same bank)
// When incoming is page-hit, replacement is page-miss, basically this logic prefers incoming. The only exception is replacement is for resolving collision.
// In this case, prefers replacement.
assign i_incoming_over_cam = {r_sel_incoming, r_wr_en_pghit} 
                           > {te_sel_valid  , (i_sel_page_hit | te_wr_col_bank[cam_search_bank] | te_wr_entry_critical_per_bsm[cam_search_bank])}? r_same_bank:1'b0;







// determine if incoming request should replace existing one next table
assign i_sel_incoming_per_bank = {{NUM_TOTAL_BSMS-1{1'b0}}, r_sel_incoming} << r_wr_en_bsm_num;

genvar gen_banks;
generate
    for (gen_banks=0;gen_banks<NUM_TOTAL_BSMS; gen_banks=gen_banks+1)
    begin : gen_compare_ih_to_ntt
        //   1. entry valid
        //   2. page hit (not for colliding bank)
        // incoming request replaces existing request if it is better than
        // the existing request based on the above 2 criteria, in that order
        assign i_cam_vpw_over_existing[gen_banks] = 1'b0;
        assign i_incoming_vpw_over_existing[gen_banks] = 1'b0;
        

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(gen_banks * PAGE_BITS)' found in module 'te_wr_nxt'
//SJ: This coding style is acceptable and there is no plan to change it

        // Incoming over existing is done with condition
        // A & (B | ((C | D) & (E & F & E)))
        // A. [There are incoming entry and it's not masked by BM]  
        // B. [No existing entry or existing entry becomes invalid] || ((
        // C. [Incoming is page-hit, existing is not]
        // D. [incoming is BTT=1] (Inline ECC specific)
        // E. [Existing is not exVPW]
        // F. [This bank is not colliding bank]
        // E. [Existing is not BTT=1] (Inline ECC specific)
        assign i_incoming_over_existing[gen_banks] = i_sel_incoming_per_bank[gen_banks]              &
                                             //   ((~te_ts_valid[gen_banks] `ifdef MEMC_INLINE_ECC | ~i_cam_valid_per_ntt[gen_banks] `endif  `ifdef DDRCTL_LLC_4CYCSCH | ~te_ts_valid_ne[gen_banks]  | i_incoming_over_cam_per_bank_pre[gen_banks] `endif)  |     // No existing entry
                                                  ((~te_ts_valid[gen_banks])  |     // No existing entry
                                                   (
                                                    ( 
                                                      (r_wr_en_pghit & ~te_ts_page_hit[gen_banks] & ~te_wr_entry_critical_per_bsm[gen_banks] )      // Incoming is page-hit, existing is page-miss
                                                    )
                                                  & (  ~te_vpw_entry[gen_banks]     // Existing is not exVPW
                                                     & ~te_wr_col_bank[gen_banks]   // Existing is not colliding bank.
                                                    ) 
                                                   )
                                                  );

        // page hit update for all activates
        // when enhanced read write switching policy is enabled, MEMC_NTT_UPD_ACT is enabled as well, NTT will be updated after activate command, don't need page_hit_for_rd to drive page_hit_update
        assign page_hit_update[gen_banks]       = (te_ts_page_hit[gen_banks] | r_open_page_per_bank[gen_banks] );
        // i_page_hit_update_per_bsm is only applied to te_nxt_vp_update for synthesis
        assign page_hit_update_ext[gen_banks]       = (page_hit_update[gen_banks] | i_page_hit_update_per_bsm[gen_banks]);

//spyglass enable_block SelfDeterminedExpr-ML

    end
endgenerate

assign r_close_page_per_bank =  ({{NUM_TOTAL_BSMS-1{1'b0}}, r_close_page_pre}      << r_close_page_bank_pre) |
                                ({{NUM_TOTAL_BSMS-1{1'b0}}, r_close_page_autopre}  << r_close_page_bank_autopre)
;
assign i_page_hit_update_per_bsm = {{NUM_TOTAL_BSMS-1{1'b0}},((page_mem[r_ts_bsm_num4act] == r_ts_act_page) & r_ts_op_is_activate_for_upd)} << r_ts_bsm_num4act;
assign r_open_page_per_bank  = {{NUM_TOTAL_BSMS-1{1'b0}}, r_open_page}     << r_open_page_bank;
// When an ACT is issued, compara page num with corresponding NTT and if it matchs, set ts_ts_page_hit=1


assign i_sel_cam_per_bank    = `UPCTL2_EN ? sel_cam_per_bank : 
                                            ({{NUM_TOTAL_BSMS-1{1'b0}}, r_sel_cam} << cam_search_bank)
                                            ;
assign i_sel_replace_pre_per_bank = {{NUM_TOTAL_BSMS-1{1'b0}}, r_ts_op_is_pre_for_ntt_upd} << r_ts_bsm_num4pre;
assign i_sel_replace_pre_per_bank_w = i_sel_replace_pre_per_bank;

wire [PAGE_BITS-1:0]    r_wr_en_page;
wire [AUTOPRE_BITS-1:0] r_wr_en_cmd_autopre;
   
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(1024 * 8)' found in module 'te_wr_nxt'
//SJ: This coding style is acceptable and there is no plan to change it - reported for `UMCTL_LOG2.

  te_mux
   #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (PAGE_BITS)
   )
   wr_en_page_mux (
     .in_port   (te_wr_page_table),
     .sel       (r_wr_en_entry_num),
     .out_port  (r_wr_en_page)
   );
   te_mux
    #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (AUTOPRE_BITS)
   )
   wr_en_cmd_autopre_mux (
     .in_port   (te_wr_cmd_autopre_table),
     .sel       (r_wr_en_entry_num),
     .out_port  (r_wr_en_cmd_autopre)
   );

wire [MWR_BITS-1:0] r_wr_en_mwr;

   te_mux
    #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (MWR_BITS)
   )
   wr_en_mwr_mux (
     .in_port   (te_mwr_table),
     .sel       (r_wr_en_entry_num),
     .out_port  (r_wr_en_mwr)
   );



wire [PARTIAL_WR_BITS_LOG2-1:0] r_wr_en_mr_raddr;
 te_mux
  #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (PARTIAL_WR_BITS_LOG2)
   )
   wr_en_cmd_mr_raddr_mux (
     .in_port   (te_wr_mr_ram_raddr_lsb_first_table),
     .sel       (r_wr_en_entry_num),
     .out_port  (r_wr_en_mr_raddr)
   );

wire [PW_WORD_CNT_WD_MAX-1:0] r_wr_en_pw_num_beats_m1;
 te_mux
  #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (PW_WORD_CNT_WD_MAX)
   )
   wr_en_cmd_pw_num_beats_mux (
     .in_port   (te_wr_mr_pw_num_beats_m1_table),
     .sel       (r_wr_en_entry_num),
     .out_port  (r_wr_en_pw_num_beats_m1)
   );
wire [PW_WORD_CNT_WD_MAX-1:0] r_wr_en_pw_num_cols_m1;

   te_mux
    #(
     .ADDRW      (`UMCTL_LOG2 (NUM_CAM_ENTRIES)),
     .NUM_INPUTS (NUM_CAM_ENTRIES),
     .DATAW      (PW_WORD_CNT_WD_MAX)
   )
   wr_en_pw_num_cols_m1_mux (
     .in_port   (te_pw_num_cols_m1_table),
     .sel       (r_wr_en_entry_num),
     .out_port  (r_wr_en_pw_num_cols_m1)
   );


//spyglass enable_block SelfDeterminedExpr-ML

wire [CMD_ENTRY_BITS-1:0]   te_sel_vpw_entry = {CMD_ENTRY_BITS{1'b0}};
wire [PAGE_BITS-1:0]        te_sel_vpw_page = {PAGE_BITS{1'b0}};
wire [AUTOPRE_BITS-1:0]     te_sel_vpw_cmd_autopre = {AUTOPRE_BITS{1'b0}};
wire [MWR_BITS-1:0]         te_sel_vpw_mwr = {MWR_BITS{1'b0}};
wire [PW_WORD_CNT_WD_MAX-1:0]   te_sel_vpw_pw_num_cols_m1 = {PW_WORD_CNT_WD_MAX{1'b0}};
wire [PARTIAL_WR_BITS_LOG2-1:0] te_sel_vpw_mr_ram_raddr_lsb = {PARTIAL_WR_BITS_LOG2{1'b0}};
wire [PW_WORD_CNT_WD_MAX-1:0]   te_sel_vpw_pw_num_beats_m1  = {PW_WORD_CNT_WD_MAX{1'b0}};
assign i_sel_vpw_page_hit = 1'b0;


generate 
   for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
     begin : te_nxt_update_gen   
    te_nxt_vp_update
     #(.DATAW (1))
    te_ts_page_hit_nxt_update (
        .ih_data                (i_wr_en_pghit), // data coming from IH
        .replace_data           (i_sel_page_hit), // data coming from te_replace
        .data_reg               (page_hit_update_ext[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (i_sel_vpw_page_hit), // data coming from te_replace vpww selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPWW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (1'b0), // Because this is triggered by PRE 
        .data_next              (te_ts_page_hit_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );

    te_nxt_vp_update
     #(.DATAW (CMD_ENTRY_BITS))
    entry_mem_nxt_update (
        .ih_data                (r_wr_en_entry_num), // data coming from IH
        .replace_data           (te_sel_entry), // data coming from te_replace
        .data_reg               (entry_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_entry), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_entry_pre),
        .data_next              (entry_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b1 & ~r_te_gs_block_wr) // To exclude extra replace by write combine/ACT to the same bank
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );

    te_nxt_vp_update
     #(.DATAW (PAGE_BITS))
    page_mem_nxt_update (
        .ih_data                (r_wr_en_page), // data coming from IH
        .replace_data           (te_sel_wr_page), // data coming from te_replace
        .data_reg               (page_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_page), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_wr_page_pre),
        .data_next              (page_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );

    te_nxt_vp_update
     #(.DATAW (AUTOPRE_BITS))
    cmd_autopre_mem_nxt_update (
        .ih_data                (r_wr_en_cmd_autopre), // data coming from IH
        .replace_data           (te_sel_wr_cmd_autopre), // data coming from te_replace
        .data_reg               (cmd_autopre_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_cmd_autopre), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_wr_cmd_autopre_pre),
        .data_next              (cmd_autopre_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );

    te_nxt_vp_update
     #(.DATAW (MWR_BITS))
    mwr_mem_nxt_update (
        .ih_data                (r_wr_en_mwr), // data coming from IH
        .replace_data           (te_sel_mwr), // data coming from te_replace
        .data_reg               (mwr_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_mwr), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_mwr_pre),

        .data_next              (mwr_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );





   te_nxt_vp_update
    #(.DATAW (PARTIAL_WR_BITS_LOG2))
    mr_ram_raddr_mem_nxt_update (
        .ih_data                (r_wr_en_mr_raddr), // data coming from IH
        .replace_data           (te_sel_wr_mr_ram_raddr_lsb), // data coming from te_replace
        .data_reg               (mr_ram_raddr_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_mr_ram_raddr_lsb), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_wr_mr_ram_raddr_lsb_pre),

        .data_next              (mr_ram_raddr_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );

   te_nxt_vp_update
    #(.DATAW (PW_WORD_CNT_WD_MAX))
    pw_num_beats_mem_nxt_update (
        .ih_data                (r_wr_en_pw_num_beats_m1), // data coming from IH
        .replace_data           (te_sel_wr_mr_pw_num_beats_m1), // data coming from te_replace
        .data_reg               (pw_num_beats_m1_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_pw_num_beats_m1), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_wr_mr_pw_num_beats_m1_pre),

        .data_next              (pw_num_beats_m1_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );

    te_nxt_vp_update
     #(.DATAW (PW_WORD_CNT_WD_MAX))
    pw_num_cols_m1_mem_nxt_update (
        .ih_data                (r_wr_en_pw_num_cols_m1), // data coming from IH
        .replace_data           (te_sel_pw_num_cols_m1), // data coming from te_replace
        .data_reg               (pw_num_cols_m1_mem[i]), // data reg
        .load                   (i_sel_cam_per_bank[i]), // load NTT, after RD/WR scheduled
        .ih_over_existing       (i_incoming_over_existing[i]), // prefer IH to the exisiting
        .ih_over_replace        (i_incoming_over_cam), // prefer IH to the te_replace
        .replace_vp_data        (te_sel_vpw_pw_num_cols_m1), // data coming from te_replace vprw selnet
        .load_vp                (i_cam_vpw_over_existing[i]), // trigger load from VPRW selnet
        .ih_over_existing_vp    (i_incoming_vpw_over_existing[i]), // prefer IH expired VPRW to the exisiting
        .load_pre               (i_sel_replace_pre_per_bank_w[i]),
        .replace_pre_data       (te_sel_pw_num_cols_m1_pre),
        .data_next              (pw_num_cols_m1_mem_next[i])
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
       ,.clk                    (co_te_clk)
       ,.rstn                   (core_ddrc_rstn)
       ,.te_ts_valid            (te_ts_valid[i])
       ,.entry_mem              (1'b0)
       ,.wc_enabled             (te_yy_wr_combine)
       ,.reg_ddrc_dis_opt_ntt_by_pre (reg_ddrc_dis_opt_ntt_by_pre)
       ,.reg_ddrc_dis_opt_ntt_by_act (reg_ddrc_dis_opt_ntt_by_act)
  `endif
`endif
    );



     end // block: te_nxt_update_gen
endgenerate


assign te_ts_valid_nxt  = ( (te_ts_valid                                                                                                   &
                            (~({{NUM_TOTAL_BSMS - 1{1'b0}}, (i_wr_combine & ih_te_bsm_alloc)} << ih_te_bsm_num))                                          &
                            (~({{NUM_TOTAL_BSMS - 1{1'b0}}, (r_sel_cam & (~te_sel_valid))} << cam_search_bank)) ) | sel_cam_per_bank     |
                     sel_incoming_per_bank )
                     ;



always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1) begin
      te_ts_valid [cnt]         <= 1'b0;
      te_ts_page_hit [cnt]      <= 1'b0;
      entry_mem [cnt]           <= {CMD_ENTRY_BITS{1'b0}};
      page_mem [cnt]            <= {PAGE_BITS {1'b0}};
      cmd_autopre_mem [cnt]     <= {AUTOPRE_BITS {1'b0}};
      mwr_mem [cnt]             <= {MWR_BITS {1'b0}};
      pw_num_cols_m1_mem[cnt]   <= {PW_WORD_CNT_WD_MAX{1'b0}};
      mr_ram_raddr_mem[cnt] <= {PARTIAL_WR_BITS_LOG2{1'b0}};
      pw_num_beats_m1_mem[cnt]   <= {PW_WORD_CNT_WD_MAX{1'b0}};
    end
  end
  else begin
    // per bank valid register: previous valid and not write combine and not issued command w/o
    //                          replacement or new valid command or replacement
     te_ts_valid  <= te_ts_valid_nxt;

    for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1) begin
      te_ts_page_hit  [cnt] <= `UPCTL2_EN ? te_ts_page_hit_next[cnt] : (~r_close_page_per_bank[cnt] & te_ts_page_hit_next[cnt]);
      entry_mem [cnt] <= entry_mem_next[cnt];
      page_mem [cnt] <= page_mem_next[cnt];
      cmd_autopre_mem [cnt] <=cmd_autopre_mem_next[cnt];
      mwr_mem [cnt] <= mwr_mem_next[cnt];
      pw_num_cols_m1_mem[cnt] <= pw_num_cols_m1_mem_next[cnt];
      mr_ram_raddr_mem[cnt] <= mr_ram_raddr_mem_next[cnt];
      pw_num_beats_m1_mem[cnt] <= pw_num_beats_m1_mem_next[cnt];
    end
  end // else: !if(~core_ddrc_rstn)



// combine valid cam entry with page hit info into one signal
wire [NUM_TOTAL_BSMS-1:0] i_te_bs_wr_bank_page_hit;
assign i_te_bs_wr_bank_page_hit = te_ts_valid & te_ts_page_hit;

// used by pageclose_timer to know if bank is closed
assign te_bs_wr_bank_page_hit = i_te_bs_wr_bank_page_hit;




`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON
// disable coverage collection as this is SVA only
// VCS coverage off

// check that same entry number is not loaded to multiple WR NTT fields
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
// VCS coverage on


a_no_same_wr_entry_loaded_to_multi_flds : assert property (
  @(posedge co_te_clk) disable iff (!core_ddrc_rstn)
  !$stable(te_os_wr_entry_table) |-> !same_entry_loaded_to_multi_flds
) else $error("%m @ %t WR NTT field %0d and %0d are loaded to same entry", $time, same_entry_fld1, same_entry_fld2);

// check if the incoming command (of any pri) replaces an existing command, when an ACT happens to the same bank as the incoming cmd
cp_any_incoming_over_exist_w_act_to_same_bank :
cover property (@(posedge co_te_clk) disable iff(!core_ddrc_rstn)
                  (ts_op_is_activate & (ts_bsm_num4act==r_wr_en_bsm_num) & i_incoming_over_existing[r_wr_en_bsm_num]));


// Check that if ACT and Write combine happen on same cycle
//a_wc_act_same_cycle : assert property (
//  @(posedge co_te_clk) disable iff (!core_ddrc_rstn)
//  (i_ts_act4wr & te_yy_wr_combine) |-> ((ih_te_bsm_num != ts_bsm_num4act) | !ih_te_bsm_alloc) 
//) else $error("%m @ %t Error: Write combine and ACT for write on same BSM", $time);


// Incoming command is picked over the commands coming from CAM
cp_incoming_over_cam :
cover property (@(posedge co_te_clk) disable iff(!core_ddrc_rstn)  i_incoming_over_cam );






sequence s_sel_act_rd_ntt_wr;
    (ts_op_is_activate && ~ts_te_sel_act_wr[ts_bsm_num4act]
    ##1 ~te_rdwr_autopre // entry_mem search finished; maybe a exvpw-pghit coming
    // `ifdef UMCTL2_VPW_EN // no load_vp and no ih_over_existing_vp,
    // otherwise the te_ts_page_hit will be asserted one cycle eariler
    // comparing with i_sel_cam_per_bank
    // && ~i_cam_vpw_over_existing[$past(ts_bsm_num4act,2)] && ~i_incoming_vpw_over_existing[$past(ts_bsm_num4act,2)]
    // `endif
    ##1 (page_mem_next[$past(ts_bsm_num4act,2)]==$past(ts_te_act_page,2)) && te_ts_valid[$past(ts_bsm_num4act,2)] // compare the act_page with current wr_ntt
    );
endsequence:s_sel_act_rd_ntt_wr

property p_sel_act_rd_ntt_wr_pghit0;
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
        s_sel_act_rd_ntt_wr |-> (i_sel_cam_per_bank[$past(ts_bsm_num4act,2)] ) /* && ~te_ts_page_hit[$past(ts_bsm_num4act,2)] */ ##1 te_ts_page_hit[$past(ts_bsm_num4act,3)]; // maybe a exvpw-pghit coming
endproperty         

a_sel_act_rd_ntt_wr_pghit0: assert property (p_sel_act_rd_ntt_wr_pghit0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

sequence s_sel_act_wr_ntt_wr;
    (ts_op_is_activate && ts_te_sel_act_wr[ts_bsm_num4act]
    && ~i_incoming_over_existing[ts_bsm_num4act]
    ##1 ~i_sel_cam_per_bank[$past(ts_bsm_num4act,1)] 
    && ~i_incoming_over_existing[$past(ts_bsm_num4act,1)] && ~i_sel_replace_pre_per_bank_w[$past(ts_bsm_num4act,1)]);
endsequence:s_sel_act_wr_ntt_wr

property p_sel_act_wr_ntt_wr_pghit0;
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
        s_sel_act_wr_ntt_wr |-> ~te_ts_page_hit[$past(ts_bsm_num4act,1)] ##1 te_ts_page_hit[$past(ts_bsm_num4act,2)];
endproperty

a_sel_act_wr_ntt_wr_pghit0: assert property (p_sel_act_wr_ntt_wr_pghit0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

property p_pre_ntt_wr_pghit0;    
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn)
        ts_op_is_precharge && te_ts_page_hit[ts_bsm_num4pre] ##1 te_ts_page_hit[$past(ts_bsm_num4pre,1)] |-> ##1 ~te_ts_page_hit[$past(ts_bsm_num4pre,2)];
endproperty

a_pre_ntt_wr_pghit0: assert property (p_pre_ntt_wr_pghit0)
    else $error("Inline SVA [%t][%m] FAILED", $time);

c_pre_ntt_wr_pghit0_1clk: cover property ( @(posedge co_te_clk)
    core_ddrc_rstn throughout ts_op_is_precharge && te_ts_page_hit[ts_bsm_num4pre] ##1 ~te_ts_page_hit[$past(ts_bsm_num4pre,1)]);

c_pre_ntt_wr_pghit0_2clk: cover property ( @(posedge co_te_clk)
    core_ddrc_rstn throughout ts_op_is_precharge && te_ts_page_hit[ts_bsm_num4pre] ##2 ~te_ts_page_hit[$past(ts_bsm_num4pre,2)]);



reg [3*NUM_TOTAL_BSMS*(CMD_ENTRY_BITS+1+1)-1:0] ntt_stable_reg;
wire [NUM_TOTAL_BSMS-1:0] ntt_stable;
generate
genvar bsm_i;
  for (bsm_i=0; bsm_i<NUM_TOTAL_BSMS; bsm_i++) begin

    always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
        ntt_stable_reg[bsm_i*3+:3] <= {3*(CMD_ENTRY_BITS+2){1'b0}};
      end
      else begin
        ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] <= {te_ts_valid[bsm_i] ,te_wr_cam_page_hit[entry_mem[bsm_i]], entry_mem[bsm_i]};
        ntt_stable_reg[(bsm_i*3+1)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] <=  ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)];
        ntt_stable_reg[(bsm_i*3+2)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] <=  ntt_stable_reg[(bsm_i*3+1)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)];
      end
    end

    assign ntt_stable[bsm_i] = (ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] == {te_ts_valid[bsm_i] ,te_wr_cam_page_hit[entry_mem[bsm_i]], entry_mem[bsm_i]}) &
                        (ntt_stable_reg[(bsm_i*3+0)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)] == ntt_stable_reg[(bsm_i*3+1)*(CMD_ENTRY_BITS+2)+:(CMD_ENTRY_BITS+2)]);

    // Check that page_hit information is correct
    a_wr_nxt_page_hit_check : assert property (
      @(posedge co_te_clk) disable iff (!core_ddrc_rstn)
      (ntt_stable[bsm_i] && (te_ts_valid[bsm_i] && te_wr_cam_page_hit[entry_mem[bsm_i]]) |-> te_ts_page_hit[bsm_i] == 1'b1)
    ) else $error("%m @ %t Entry loaded into NTT is page-hit, but te_ts_page_hit is 0 bsm=%d, entry=%d ", $time, bsm_i, entry_mem[bsm_i]);

  end
endgenerate


property p_wr_combine_check; @(posedge co_te_clk) disable iff(!core_ddrc_rstn) te_yy_wr_combine -> (te_ih_wr_retry==1'b0) ; endproperty
a_wr_combine_check : assert property (p_wr_combine_check)
  else $display ("%0t ERROR : te_yy_wr_combine=1 and te_ih_wr_retry=1 at the same time.", $time);


`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule // te_wr_nxt
