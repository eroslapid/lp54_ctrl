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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_wr_entry.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// 1. entry contents of the write CAM
// 2. returns participation and page hit on cam search
// 3. collision detection
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_wr_entry #(
    //---------------------------- PARAMETERS --------------------------------------
    // bit widths; should be overridden from read CAM
     parameter   IE_WR_ECC_ENTRY           = 1'b0 // 1 means this entry is dedicated for WR ECC Entry   
    ,parameter   RANK_BITS                 = `UMCTL2_LRANK_BITS
    ,parameter   BG_BITS                   = `MEMC_BG_BITS
    ,parameter   BANK_BITS                 = `MEMC_BANK_BITS
    ,parameter   BG_BANK_BITS              = `MEMC_BG_BANK_BITS
    ,parameter   RANKBANK_BITS             = RANK_BITS + BG_BANK_BITS
    ,parameter   PAGE_BITS                 = `MEMC_PAGE_BITS
    ,parameter   BLK_BITS                  = 13
    ,parameter   BSM_BITS                  = `UMCTL2_BSM_BITS
    ,parameter   NUM_TOTAL_BSMS            = 1 << BSM_BITS
    ,parameter   OTHER_ENTRY_BITS          = 1
    ,parameter   HI_PRI_BITS               = 2
    ,parameter   BT_BITS                   = `MEMC_BLK_TOKEN_BITS         // override
    ,parameter   NO_OF_BT                  = 1 // override
    ,parameter   IE_WR_TYPE_BITS           = 2
    ,parameter   IE_RD_TYPE_BITS           = 2
    ,parameter   IE_BURST_NUM_BITS         = 3
    ,parameter   IE_UNIQ_BLK_BITS          = 4
    ,parameter   IE_UNIQ_BLK_LSB           = 3
    ,parameter   ECCAP_BITS                = 1
    ,parameter   DDR4_COL3_BITS            = 1
    ,parameter   WORD_BITS                 = `MEMC_WORD_BITS
    ,parameter   RETRY_WR_BITS             = 1
    ,parameter   ENTRY_RETRY_TIMES_WIDTH   = 4
    ,parameter   ENTRY_AUTOPRE_BITS        = 1
    // fields of entry
    ,parameter   PARTIAL_WR_BITS           = `UMCTL2_PARTIAL_WR_BITS      // bits for PARTIAL_WR logic
    ,parameter   PARTIAL_WR_BITS_LOG2      = `log2(PARTIAL_WR_BITS)        // bits for PARTIAL_WR logic
    ,parameter   PW_WORD_CNT_WD_MAX        = 2
    ,parameter   WR_LATENCY_BITS           = `UMCTL2_XPI_WQOS_TW
    ,parameter   PW_BC_SEL_BITS            = 3
    ,parameter   MWR_BITS                  = 1
    // write command priority encoding
    ,parameter   CMD_PRI_NPW               = `MEMC_CMD_PRI_NPW
    ,parameter   CMD_PRI_VPW               = `MEMC_CMD_PRI_VPW
    ,parameter   CMD_PRI_RSVD              = `MEMC_CMD_PRI_RSVD
    ,parameter   CMD_PRI_XVPW              = `MEMC_CMD_PRI_XVPW
    // Entry Fields (Not override)
    ,parameter  ENTRY_VALID                = 0
    ,parameter  ENTRY_AUTOPRE_LSB          = 1
    ,parameter  ENTRY_AUTOPRE_MSB          = ENTRY_AUTOPRE_LSB+ENTRY_AUTOPRE_BITS - 1
    ,parameter  ENTRY_HI_PRI_LSB           = ENTRY_AUTOPRE_MSB+1
    ,parameter  ENTRY_HI_PRI_MSB           = ENTRY_HI_PRI_LSB + HI_PRI_BITS - 1
    ,parameter  ENTRY_VPW_LAT_LSB          = ENTRY_HI_PRI_MSB + 1
    ,parameter  ENTRY_VPW_LAT_MSB          = ENTRY_VPW_LAT_LSB + WR_LATENCY_BITS - 1
    ,parameter  ENTRY_BLK_LSB              = ENTRY_VPW_LAT_MSB + 1
    ,parameter  ENTRY_BLK_MSB              = ENTRY_BLK_LSB + BLK_BITS - 1
    ,parameter  ENTRY_ROW_LSB              = ENTRY_BLK_MSB + 1
    ,parameter  ENTRY_ROW_MSB              = ENTRY_ROW_LSB + PAGE_BITS - 1
    ,parameter  ENTRY_BANK_LSB             = ENTRY_ROW_MSB + 1
    ,parameter  ENTRY_BANK_MSB             = ENTRY_BANK_LSB + BG_BANK_BITS - 1
    ,parameter  ENTRY_RANK_LSB             = ENTRY_BANK_MSB + 1
    ,parameter  ENTRY_RANK_MSB             = ENTRY_RANK_LSB + RANK_BITS - 1
    ,parameter  ENTRY_MWR_LSB              = ENTRY_RANK_MSB + 1 
    ,parameter  ENTRY_MWR_MSB              = ENTRY_MWR_LSB + MWR_BITS - 1
    ,parameter  ENTRY_PW_WORD_VALID_LSB    = ENTRY_MWR_MSB + 1
    ,parameter  ENTRY_PW_WORD_VALID_MSB    = ENTRY_PW_WORD_VALID_LSB + PARTIAL_WR_BITS - 1
    ,parameter  ENTRY_PW_BC_SEL_LSB        = ENTRY_PW_WORD_VALID_MSB + 1
    ,parameter  ENTRY_PW_BC_SEL_MSB        = ENTRY_PW_BC_SEL_LSB + PW_BC_SEL_BITS - 1 
    ,parameter  ENTRY_PW_RAM_RADDR_LSB     = ENTRY_PW_BC_SEL_MSB + 1
    ,parameter  ENTRY_PW_RAM_RADDR_MSB     = ENTRY_PW_RAM_RADDR_LSB + PARTIAL_WR_BITS_LOG2 - 1
    ,parameter  ENTRY_PW_NUM_BEATS_M1_LSB  = ENTRY_PW_RAM_RADDR_MSB + 1
    ,parameter  ENTRY_PW_NUM_BEATS_M1_MSB  = ENTRY_PW_NUM_BEATS_M1_LSB + PW_WORD_CNT_WD_MAX - 1 
    ,parameter  ENTRY_PW_NUM_COLS_M1_LSB   = ENTRY_PW_NUM_BEATS_M1_MSB + 1
    ,parameter  ENTRY_PW_NUM_COLS_M1_MSB   = ENTRY_PW_NUM_COLS_M1_LSB + PW_WORD_CNT_WD_MAX - 1 
    ,parameter  ENTRY_IE_BT_LSB            = ENTRY_PW_NUM_COLS_M1_MSB + 1
    ,parameter  ENTRY_IE_BT_MSB            = ENTRY_IE_BT_LSB + BT_BITS - 1
    ,parameter  ENTRY_IE_WR_TYPE_LSB       = ENTRY_IE_BT_MSB + 1
    ,parameter  ENTRY_IE_WR_TYPE_MSB       = ENTRY_IE_WR_TYPE_LSB + IE_WR_TYPE_BITS - 1
    ,parameter  ENTRY_IE_BURST_NUM_LSB     = ENTRY_IE_WR_TYPE_MSB + 1
    ,parameter  ENTRY_IE_BURST_NUM_MSB     = ENTRY_IE_BURST_NUM_LSB + IE_BURST_NUM_BITS - 1
    ,parameter  ENTRY_IE_UNIQ_BLK_LSB      = ENTRY_IE_BURST_NUM_MSB + 1
    ,parameter  ENTRY_IE_UNIQ_BLK_MSB      = ENTRY_IE_UNIQ_BLK_LSB + IE_UNIQ_BLK_BITS - 1
    ,parameter  ENTRY_ECCAP_LSB            = ENTRY_IE_UNIQ_BLK_MSB + 1
    ,parameter  ENTRY_ECCAP_MSB            = ENTRY_ECCAP_LSB + ECCAP_BITS - 1
    ,parameter  ENTRY_RETRY_WR_LSB         = ENTRY_ECCAP_MSB + 1
    ,parameter  ENTRY_RETRY_WR_MSB         = ENTRY_RETRY_WR_LSB + RETRY_WR_BITS - 1
    ,parameter  ENTRY_RETRY_TIMES_LSB      = ENTRY_RETRY_WR_MSB + 1
    ,parameter  ENTRY_RETRY_TIMES_MSB      = ENTRY_RETRY_TIMES_LSB + ENTRY_RETRY_TIMES_WIDTH -1 
    ,parameter  ENTRY_DWORD_LSB            = ENTRY_RETRY_TIMES_MSB + 1
    ,parameter  ENTRY_DWORD_MSB            = ENTRY_DWORD_LSB + WORD_BITS - 1
    ,parameter  ENTRY_DDR4_COL3_LSB        = ENTRY_DWORD_MSB + 1
    ,parameter  ENTRY_DDR4_COL3_MSB        = ENTRY_DDR4_COL3_LSB + DDR4_COL3_BITS - 1
    ,parameter  ENTRY_OTHER_LSB            = ENTRY_DDR4_COL3_MSB + 1
    ,parameter  ENTRY_OTHER_MSB            = ENTRY_OTHER_LSB + OTHER_ENTRY_BITS - 1
    ,parameter  ENTRY_RD_DATA_PENDING      = ENTRY_OTHER_MSB + 1
    ,parameter  ENTRY_WR_DATA_PENDING      = ENTRY_RD_DATA_PENDING + 1
    ,parameter  ENTRY_BITS                 = ENTRY_WR_DATA_PENDING + 1

    )
    (
    //---------------------------- INPUTS AND OUTPUTS ------------------------------
     input                                    core_ddrc_rstn                    // reset
    ,input                                    co_te_clk                         // main clock
    ,input                                    ddrc_cg_en                        // clock gate enable
    ,input  [BG_BANK_BITS-1:0]                ih_te_wr_bg_bank_num              // bank number
    ,input  [PAGE_BITS-1:0]                   ih_te_wr_page_num                 // page number
    ,input  [BLK_BITS-1:0]                    ih_te_wr_block_num                // block number
    ,input                                    ih_te_wr_autopre                  // auto precharege bit
    ,input  [OTHER_ENTRY_BITS-1:0]            ih_te_wr_other_fields             // starting Dword location
    ,input  [PAGE_BITS-1:0]                   r_ts_act_page                     // Row address of the activated page
    ,input  [BSM_BITS-1:0]                    r_ts_bsm_num4pre                  // BSM numer of the precharge cmd selected by the scheduler
    ,input  [BSM_BITS-1:0]                    r_ts_bsm_num4any                  // BSM number of the ACT , ACT bypass, PRE or RDWR (registered)
    ,input  [BSM_BITS-1:0]                    r_ts_bsm_num4act                  // BSM number of the ACT , ACT bypass
    ,input  [BSM_BITS-1:0]                    r_ts_bsm_num4rdwr                 // BSM number of the RDWR (registered)
    ,input                                    r_te_rdwr_autopre                 // autopre this cycle
    ,input                                    r_ts_op_is_precharge              // precharge scheduled this cycle
    ,input                                    r_ts_op_is_activate               // activate scheduled this cycle
    ,input                                    be_te_page_hit                    // the incoming command from IH has a current page hit
    ,input  [BSM_BITS-1:0]                    ts_bsm_num4rdwr                   // BSM number on cam search    
    ,input                                    dh_te_dis_wc                      // disable write combine
    ,input                                    i_combine_ok                      // OK to write combine this cycle
    ,output                                   i_wr_combine_replace_bank_match   // incoming rank & bank matches address of current write combine with all data ready
    ,output                                   i_same_addr_wr                    // incoming address matches address of current write
    ,output                                   i_combine_match                   // incoming xaction may be combined with this pending xaction
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in RTL assertion.
    ,input                                    ih_te_wr_valid                    // incoming is a valid write command
//spyglass enable_block W240
    ,input                                    i_load                            // store entry signal
    ,input                                    i_entry_del                       // delete entry signal
    ,input                                    i_wr_data_rdy_wr_en               // enable write signal, write data complete
    ,input                                    i_rd_data_rdy_wr_en               // enable write signal, read data complete
    ,input   [MWR_BITS-1:0]                   i_mwr                             // Masked write information
    ,input  [PARTIAL_WR_BITS-1:0]             i_wr_word_valid
    ,input  [PARTIAL_WR_BITS_LOG2-1:0]        i_wr_ram_raddr_lsb_first
    ,input  [PW_WORD_CNT_WD_MAX-1:0]          i_wr_pw_num_beats_m1
    ,input  [PW_WORD_CNT_WD_MAX-1:0]          i_wr_pw_num_cols_m1

    ,output [ENTRY_OTHER_MSB-ENTRY_AUTOPRE_LSB:0] i_entry_out                       // entry_contents, excludes data ready signals
    ,output                                   i_load_ntt                        // load NTT enable
    ,output                                   i_entry_valid                     // entry is valid
    ,output                                   i_bank_hit                        // bank match for autopre calculation
    ,output                                   i_bank_hit_act                    // bank match for activate
    ,output                                   i_bank_hit_pre                    // bank match for activate
    ,input  [BSM_BITS-1:0]                    ts_bsm_num4pre                    // BSM numer of the precharge cmd selected by the scheduler
    ,output                                   i_page_hit                        // open page hit info during cam search, only valid when i_bank_hit=1
    ,output                                   page_open_any_op                  // page is open for this entry if same bank of ACT, RDWR, or PRE one cycle earlier
    ,output                                   rd_and_wr_data_rdy                // both write data and read data complete (i_wr_data_rdy_wr_en and i_rd_data_rdy_wr_en pulses occured in any order) 
    ,output reg                               i_entry_critical_early
    ,output reg                               i_entry_critical
    ,input                                    page_hit_limit_reached            // Pulse signal
    ,input                                    page_hit_limit_incoming           // Incoming bank has page-hit_limiter expired
    ,input                                    page_hit_limit_reached_incoming   // Incoming bank has page-hit_limiter expired
    ,input                                    ts_op_is_wr                       // BSM number on cam search    
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,output                                   i_entry_we_bw_loaded
    ,output                                   i_entry_ie_btt_sticky_sva         // This entry has ever been BTT=1 (only for assertion.)
    `endif
    `endif
    );




//------------------------------------------------------------------------------
// Wire and Register Declarations
//------------------------------------------------------------------------------
//spyglass disable_block W497
//SMD: Not all bits of bus 'r_entry'(11 bits) are set
//SJ: Expected to happen in inline ECC configs which have VPR/VPW enabled (bits driven in WRCAM_ENTRY3 generate block)
reg  [ENTRY_BITS-1:0]                  r_entry;                         // actual storage
//spyglass enable_block W497

reg                                    r_combine_dis;                   // disable write combine
wire                                   i_flag_nxt;                      // next value of 2 write datas pending flags
reg                                    r_flag;                          // awaiting write data for both a combined write and
                                                                        //  the first pre-combined write
wire                                   i_combine_cmd_ok;                // For inline ECC. combine is only allowed for non-protected resion command.  
wire                                   i_combine_match_norm;            // Indicate this is normal combine (not the special case for WE_BW).  
wire                                   i_entry_loaded;
wire                                   i_same_addr_wr_int;              // intermediate i_same_addr_wr
wire                                   i_same_page_blk_wr;              // matching rank/bank addr with incoming xaction
wire                                   i_same_bank_wr4combine;          // matching rank/bank addr with incoming xaction (for wr combine)
wire                                   i_same_bank_wr;                  // matching rank/bank addr with incoming xaction
wire                                   i_same_bank_as_rdwr_op;
wire [RANKBANK_BITS-1:0]               ih_te_wr_rankbank_num;
wire [PAGE_BITS-1:0]                   i_entry_out_page;                // entry contents
wire [RANKBANK_BITS-1:0]               i_entry_out_rankbank;            // entry contents
wire                                   i_entry_rd_data_pending;
wire                                   i_entry_wr_data_pending;

// Internal address signal for collision detection

// CAM entry
reg  [RANKBANK_BITS-1:0]               i_entry_rankbank;
reg  [BLK_BITS-1:0]                    i_entry_blk;
reg  [PAGE_BITS-1:0]                   i_entry_page;

// Incomiing command
reg  [RANKBANK_BITS-1:0]               i_wr_incoming_rankbank;
reg  [BLK_BITS-1:0]                    i_wr_incoming_blk;
reg  [PAGE_BITS-1:0]                   i_wr_incoming_page;


//--------------------------------------------------------------------------------------------
// Wire assignments based on the value of the entries in the CAM location
//--------------------------------------------------------------------------------------------

assign  i_entry_loaded           = r_entry [ENTRY_VALID];
assign  i_entry_out_page         = r_entry [ENTRY_ROW_MSB  : ENTRY_ROW_LSB  ];
assign  i_entry_out_rankbank     = r_entry [ENTRY_RANK_MSB : ENTRY_BANK_LSB ];
assign  i_entry_rd_data_pending  = r_entry [ENTRY_RD_DATA_PENDING];
assign  i_entry_wr_data_pending  = r_entry [ENTRY_WR_DATA_PENDING];

// valid indication - goes high after the entry is loaded and both the write and read data (if any) has arrived
wire   i_entry_valid_data;
assign i_entry_valid_data = i_entry_loaded & (~r_entry[ENTRY_WR_DATA_PENDING]) & (~r_entry[ENTRY_RD_DATA_PENDING]);
assign i_entry_valid = i_entry_valid_data;

// assign output entry, excluding data ready and valid indicators
assign i_entry_out [ENTRY_AUTOPRE_MSB-ENTRY_AUTOPRE_LSB:ENTRY_AUTOPRE_LSB-ENTRY_AUTOPRE_LSB] = r_entry [ENTRY_AUTOPRE_MSB:ENTRY_AUTOPRE_LSB];
assign i_entry_out [ENTRY_OTHER_MSB-ENTRY_AUTOPRE_LSB:ENTRY_BLK_LSB-ENTRY_AUTOPRE_LSB]       = r_entry [ENTRY_OTHER_MSB:ENTRY_BLK_LSB];



// rank/bank of the entry same as the rank/bank of the rd/wr command
assign i_same_bank_as_rdwr_op           = &(i_entry_out_rankbank ~^ ts_bsm_num4rdwr);

//-------------------------   r_page_open ---------------------------------------
reg   r_page_open;
wire  r_page_hit_act;
wire  set_page_open_for_act;
wire  set_page_close_for_pre;
wire  page_open_next;
wire  page_open;

//---------------------------
// comparators to decide bank and page hit for act and pre commands
// need this to generate the page_hit flag per-entry
//--------------------------- 
wire r_same_bank_any_op;
wire r_same_bank_act_op;
wire r_same_bank_rdwr_op;
wire r_same_pre_bank;
   
assign r_same_bank_any_op   = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4any));
assign r_same_bank_act_op   = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4act));
assign r_same_bank_rdwr_op  = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4rdwr));
assign r_same_pre_bank      = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4pre));
assign page_open_any_op     = page_open_next & r_same_bank_any_op & i_entry_valid;
   
assign r_page_hit_act       = (& (i_entry_out_page      ~^ r_ts_act_page )) & r_same_bank_act_op;

assign set_page_open_for_act  = r_ts_op_is_activate & r_page_hit_act;
assign set_page_close_for_pre = (r_te_rdwr_autopre & r_same_bank_rdwr_op) | (r_ts_op_is_precharge & r_same_pre_bank);
reg r_be_te_page_hit;
reg r_load;

assign page_open = set_page_open_for_act  ? 1'b1 :
                   set_page_close_for_pre  ? 1'b0 :
           r_load ? r_be_te_page_hit :r_page_open;
assign page_open_next = page_open & i_entry_loaded;

always @ (posedge co_te_clk or negedge core_ddrc_rstn) begin
  if(~core_ddrc_rstn) begin
     r_page_open        <= 1'b0;
     r_be_te_page_hit   <= 1'b0;
     r_load             <= 1'b0;
  end
  else begin
     r_page_open        <= page_open_next;
     r_be_te_page_hit   <= be_te_page_hit;
     r_load             <= i_load;
  end
end // always @ (posedge co_te_clk or negedge core_ddrc_rstn)


//------------------------------------------------------------------------------
// Logic
//------------------------------------------------------------------------------

assign ih_te_wr_rankbank_num = {
                               ih_te_wr_bg_bank_num
                            };



//spyglass disable_block W552
//SMD: Bus 'r_entry' is driven inside more than one sequential block
//SJ: 'r_entry' is driven per-bit based on parameter values which do not overlap

// entry valid
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_VALID] <= 1'b0;
  else if(ddrc_cg_en)
  begin
    if (i_load)
      r_entry [ENTRY_VALID] <= 1'b1;
    else if (i_entry_del)
      r_entry [ENTRY_VALID] <= 1'b0;
  end


// combine possible if:
//  - write command to the same address as this entry
//  - write combine not disabled (for register bit or for too many write combines outstanding to this entry)
//assign i_combine_match    = ih_te_wr_valid & i_same_addr_wr & (~r_combine_dis) & i_combine_ok & i_combine_cmd_ok `ifdef UMCTL2_DYN_BSM & (~i_bsm_alloc) `endif;
assign i_combine_match    = ih_te_wr_valid & i_same_addr_wr & (~r_combine_dis) & i_combine_ok & i_combine_cmd_ok;

assign i_flag_nxt = (r_entry [ENTRY_WR_DATA_PENDING] & i_combine_match_norm & (~i_wr_data_rdy_wr_en)) |
                    (r_flag & (~i_wr_data_rdy_wr_en));

assign rd_and_wr_data_rdy = ~i_entry_wr_data_pending & i_rd_data_rdy_wr_en |
                            ~i_entry_rd_data_pending & i_wr_data_rdy_wr_en & (~r_flag)|
                            (i_wr_data_rdy_wr_en & (~i_combine_match) & (~r_flag) & i_rd_data_rdy_wr_en);   


assign i_combine_cmd_ok = 1'b1;
assign i_combine_match_norm = i_combine_match;

// set flag when write data is NOT ready and there occurs a write combine
always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    r_flag <= 1'b0;
    r_combine_dis <= 1'b1;
  end
  else if(ddrc_cg_en) begin
    r_flag <= i_flag_nxt;
    r_combine_dis <= i_flag_nxt | dh_te_dis_wc;
  end
end //always

// enable write for this entry (write data ready)
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_WR_DATA_PENDING] <= 1'b0;
  else if(ddrc_cg_en)
  begin
    if (i_load)
      r_entry [ENTRY_WR_DATA_PENDING] <= 1'b1;
    else if (i_combine_match)
      r_entry [ENTRY_WR_DATA_PENDING] <= 1'b1;
    else if (i_wr_data_rdy_wr_en & (~r_flag))
      r_entry [ENTRY_WR_DATA_PENDING] <= 1'b0;
    end


// enable write for this entry (read data ready)
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_RD_DATA_PENDING] <= 1'b0;
  else if(ddrc_cg_en)
  begin
    if (i_load)
      r_entry [ENTRY_RD_DATA_PENDING] <= 1'b1;
    else if (i_rd_data_rdy_wr_en)
      r_entry [ENTRY_RD_DATA_PENDING] <= 1'b0;
  end

// masked write for this entry, that is set by i_load_ntt
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_MWR_MSB:ENTRY_MWR_LSB] <= {MWR_BITS{1'b0}};
  else if(ddrc_cg_en)
  begin
    if (i_load & (IE_WR_ECC_ENTRY==1'b0)) // Exclude this condition for WRECC CAM
        r_entry [ENTRY_MWR_MSB:ENTRY_MWR_LSB] <= {MWR_BITS{1'b0}};
    else if (i_load_ntt)
      r_entry [ENTRY_MWR_MSB:ENTRY_MWR_LSB] <= i_mwr[MWR_BITS-1:0];
  end



// wr_word_valid for this entry, that is set by i_load_ntt
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_PW_WORD_VALID_MSB:ENTRY_PW_WORD_VALID_LSB] <= {PARTIAL_WR_BITS{1'b0}};
  else if(ddrc_cg_en)
  begin
    if (i_load)
        r_entry [ENTRY_PW_WORD_VALID_MSB:ENTRY_PW_WORD_VALID_LSB] <= {PARTIAL_WR_BITS{1'b0}}; // set to 0 to flag that no bits are valid
    else if (i_load_ntt)
      r_entry [ENTRY_PW_WORD_VALID_MSB:ENTRY_PW_WORD_VALID_LSB] <= i_wr_word_valid[PARTIAL_WR_BITS-1:0];
  end


  // ram_raddr_lsb_first for this entry, that is set by i_load_ntt
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_PW_RAM_RADDR_MSB:ENTRY_PW_RAM_RADDR_LSB] <= {PARTIAL_WR_BITS_LOG2{1'b0}};
  else if(ddrc_cg_en)
  begin
    if (i_load)
        r_entry [ENTRY_PW_RAM_RADDR_MSB:ENTRY_PW_RAM_RADDR_LSB] <= {PARTIAL_WR_BITS_LOG2{1'b0}}; // set to 0 to flag that no bits are valid
    else if (i_load_ntt)
      r_entry [ENTRY_PW_RAM_RADDR_MSB:ENTRY_PW_RAM_RADDR_LSB] <= i_wr_ram_raddr_lsb_first[PARTIAL_WR_BITS_LOG2-1:0];
  end

    // pw_num_beats_m1 for this entry, that is set by i_load_ntt
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_PW_NUM_BEATS_M1_MSB:ENTRY_PW_NUM_BEATS_M1_LSB] <= {PW_WORD_CNT_WD_MAX{1'b0}};
  else if(ddrc_cg_en)
  begin
    if (i_load)
      r_entry [ENTRY_PW_NUM_BEATS_M1_MSB:ENTRY_PW_NUM_BEATS_M1_LSB] <= {PW_WORD_CNT_WD_MAX{1'b0}}; // set to 0 to flag that no bits are valid
    else if (i_load_ntt)
      r_entry [ENTRY_PW_NUM_BEATS_M1_MSB:ENTRY_PW_NUM_BEATS_M1_LSB] <= i_wr_pw_num_beats_m1;
  end

  // pw_num_cols_m1 for this entry, that is set by i_load_ntt
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
    r_entry [ENTRY_PW_NUM_COLS_M1_MSB:ENTRY_PW_NUM_COLS_M1_LSB] <= {PW_WORD_CNT_WD_MAX{1'b0}};
  else if(ddrc_cg_en)
  begin
    if (i_load)
      r_entry [ENTRY_PW_NUM_COLS_M1_MSB:ENTRY_PW_NUM_COLS_M1_LSB] <= {PW_WORD_CNT_WD_MAX{1'b0}}; // set to 0 to flag that no bits are valid
    else if (i_load_ntt)
      r_entry [ENTRY_PW_NUM_COLS_M1_MSB:ENTRY_PW_NUM_COLS_M1_LSB] <= i_wr_pw_num_cols_m1;
  end





// entry contents (excluding valid and ready indicators)
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
  begin
    r_entry[ENTRY_AUTOPRE_MSB:ENTRY_AUTOPRE_LSB]           <= {ENTRY_AUTOPRE_BITS{1'b0}};
    r_entry[ENTRY_BLK_MSB:ENTRY_BLK_LSB]                   <= {BLK_BITS{1'b0}};
    r_entry[ENTRY_ROW_MSB:ENTRY_ROW_LSB]                   <= {PAGE_BITS{1'b0}};
    r_entry[ENTRY_BANK_MSB:ENTRY_BANK_LSB]                 <= {BG_BANK_BITS{1'b0}};
    r_entry[ENTRY_OTHER_MSB:ENTRY_OTHER_LSB]    <= {OTHER_ENTRY_BITS{1'b0}};
  end
  else if(ddrc_cg_en)
  begin
    if (i_load)
    begin
      r_entry[ENTRY_AUTOPRE_LSB]                <= ih_te_wr_autopre;
      r_entry[ENTRY_AUTOPRE_MSB]                <= 1'b0; // Fixed to 0
      r_entry[ENTRY_BLK_MSB:ENTRY_BLK_LSB]      <= ih_te_wr_block_num;     // block number
      r_entry[ENTRY_ROW_MSB:ENTRY_ROW_LSB]      <= ih_te_wr_page_num;      // page number
      r_entry[ENTRY_BANK_MSB:ENTRY_BANK_LSB]    <= ih_te_wr_bg_bank_num;   // bank number
      r_entry[ENTRY_OTHER_MSB:ENTRY_OTHER_LSB]  <= ih_te_wr_other_fields;
    end
  end
  
// comparators// cam search
// this signal goes high for all the entries that have a bank-hit to the currently scheduled command
// this is used in the logic that determined whether to do autopre for pageclose feature or not
// this logic needs to see bank match from all entries (NPW, VPW and XVPW)
assign i_bank_hit     = (i_entry_valid 
                      & i_same_bank_as_rdwr_op
                        & (~i_combine_match)
                        )
                        ; 
// i_bank_hit_act 
assign i_bank_hit_act       = r_same_bank_act_op & i_entry_valid; 

assign i_bank_hit_pre       = (ts_bsm_num4pre == i_entry_out_rankbank) & i_entry_valid;
// CAM search page hit (based on page for read/write replacement, or base on page from IH for write combine)
assign i_page_hit = page_open_next; 

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation

// Assign Existing address to be compared
always @(*) begin
  // For existing entry
  i_entry_rankbank       = r_entry [ENTRY_RANK_MSB:ENTRY_BANK_LSB];
  i_entry_blk            = r_entry [ENTRY_BLK_MSB:ENTRY_BLK_LSB];
  i_entry_page           = r_entry [ENTRY_ROW_MSB:ENTRY_ROW_LSB];
  // For incoming entry
  i_wr_incoming_rankbank   = ih_te_wr_rankbank_num;
  i_wr_incoming_blk        = ih_te_wr_block_num;
  i_wr_incoming_page       = ih_te_wr_page_num;
end
//spyglass enable_block W528
                         


// rank_msb to bank_lsb used - appropriate bits will be selected based on UMCTL2_NUM_LRANKS_TOTAL_1 and MEMC_DDR4
assign i_same_bank_wr = (& (i_entry_rankbank ~^ i_wr_incoming_rankbank[RANKBANK_BITS-1:0]));

assign i_same_page_blk_wr = (& (i_entry_page ~^ i_wr_incoming_page [PAGE_BITS-1:0])) &
                            (& (i_entry_blk ~^ i_wr_incoming_blk [BLK_BITS-1:0]))  ;
assign i_same_addr_wr_int = i_same_bank_wr & i_same_page_blk_wr & r_entry[ENTRY_VALID];
assign i_same_addr_wr         = i_same_addr_wr_int;
assign i_same_bank_wr4combine = i_same_bank_wr;


// combine only done for writes  -does not use i_same_*_rd
assign i_wr_combine_replace_bank_match  = i_same_bank_wr4combine  & // bank match with incoming one
            r_entry[ENTRY_VALID]                &          // entry is valid      
            (~r_entry[ENTRY_RD_DATA_PENDING])   &          // entry has all read data, if any
            (~r_entry[ENTRY_WR_DATA_PENDING])   &          // entry has all write data    
            (~(i_same_page_blk_wr & i_combine_match));     // entry is not being combined    


// both read and write data have come
assign i_load_ntt =  (IE_WR_ECC_ENTRY==1'b1)? 1'b0 :
                     (~i_combine_match & 
                                        ((i_wr_data_rdy_wr_en & (~r_flag) & (~r_entry [ENTRY_RD_DATA_PENDING])) |
                                        (i_rd_data_rdy_wr_en & (~r_entry [ENTRY_WR_DATA_PENDING]))              |
                                        (i_wr_data_rdy_wr_en & (~r_flag) & i_rd_data_rdy_wr_en)));

//spyglass enable_block W552


// i_entry_critical_early version
always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_entry_critical_early <= 1'b0;
  end
  else begin
    if (i_load & page_hit_limit_incoming) begin
      i_entry_critical_early <= (IE_WR_ECC_ENTRY==1)? 1'b0 : 1'b1;
    end
    else if (~i_entry_loaded) begin        
      i_entry_critical_early <= 1'b0;
    end
    else begin
      // For WRECC entry, page_hit_limiter does not apply to make sure WRECC command has to be issued before page is closed
      i_entry_critical_early <= (set_page_close_for_pre | (IE_WR_ECC_ENTRY==1))? 1'b0 : (r_same_bank_rdwr_op & page_hit_limit_reached)? 1'b1 : i_entry_critical_early;
    end
  end
end

// i_entry_critical version
// it indicated the entry already exceed pagehit limite after the write operation scheduled out.
always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_entry_critical <= 1'b0;
  end
  else begin
    if (i_load & page_hit_limit_reached_incoming) begin
      i_entry_critical <= 1'b1;
    end else if (~i_entry_loaded) begin        
      i_entry_critical <= 1'b0;
    // For WRECC entry, page_hit_limiter does not apply to make sure WRECC command has to be issued before page is closed
    end else if (set_page_close_for_pre | (IE_WR_ECC_ENTRY==1)) begin
      i_entry_critical <= 1'b0;
    end else if (i_same_bank_as_rdwr_op & ts_op_is_wr & i_entry_critical_early)begin
      i_entry_critical <= 1'b1;
    end 
  end
end



//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
wire retry_fatl_err_detected = 1'b0;
camEntryOverwritten: //------------------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
    (!(r_entry[ENTRY_VALID] & i_load)) )
    else $error("[%t][%m] ERROR: Write CAM entry gets overwritten.", $time);

invalidTransactionScheduled: //----------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
    (!(~r_entry[ENTRY_VALID] & i_entry_del)) )
    else $error("[%t][%m] ERROR: Invalid Transaction Scheduled.", $time);

tooManyWriteCombine: //------------------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
    (!(i_combine_match & r_flag)) )
    else $error("[%t][%m] ERROR: Write combine with write data already pending for 2 previous writes.  TE cannot deal with this; please fix IH.", $time);

writeEntryRdDataEn: //------------------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn | retry_fatl_err_detected) //Disable the assertion once retry fatl error is detected
    (!(i_rd_data_rdy_wr_en & (~r_entry [ENTRY_RD_DATA_PENDING] ))) )
    else $error("[%t][%m] ERROR: Write CAM entry gets read data ready twice.", $time);
    // For inline ECC, WE_BW is never RMW, and ENTRY_RD_DATA_PENDING is no effect.

writeEntryWrDataEn: //------------------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
    (!(i_wr_data_rdy_wr_en & (~r_entry [ENTRY_WR_DATA_PENDING] ))) )
    else $error("[%t][%m] ERROR: Write CAM entry gets write data ready twice.", $time);

  // Check that write combine happens in the same cycle in which NTT is getting re-loaded due to a scheduled WR
  cp_wr_combine_happens_w_ntt_reload :
  cover property (@(posedge co_te_clk) disable iff(!core_ddrc_rstn) (i_entry_valid & ~i_entry_del & i_same_bank_as_rdwr_op & i_combine_match));

  // Check that write combine happens when the entry is valid
  cp_wr_combine_happens_w_entry_valid :
  cover property (@(posedge co_te_clk) disable iff(!core_ddrc_rstn) (i_entry_valid & i_combine_match));
//------------------------------------------------------------------------------

reg wr_cam_overwr;
reg wr_cam_dup;

initial
begin
  wr_cam_overwr = 1'b0;
  wr_cam_dup    = 1'b0;
end

// disable coverage collection as this is a check in SVA only        
// VCS coverage off 

always @(posedge co_te_clk)
begin
  if (r_entry [ENTRY_VALID] && i_load)
  begin
    $display ("%m: at %t ERROR: CAM entry gets overwritten.", $time);
    wr_cam_overwr = 1'b1;
  end
  if (~r_entry [ENTRY_VALID] && i_entry_del)
  begin
    $display ("%m: at %t ERROR: CAM entry gets duplicated transaction.", $time);
    wr_cam_dup = 1'b1;
  end
  // Added by Raj 7/8/06 to ensure IH/WU behave
  if (i_combine_match && r_flag)
  begin
    $display ("%m: at %t ERROR: Write combine with write data already pending for 2 previous writes.  TE is not equipped to handle this case.", $time);
  end
end
// VCS coverage on

assign i_entry_we_bw_loaded = 1'b0;
assign i_entry_ie_btt_sticky = 1'b0;







  
wire i_load_when_page_hit_limit_reached;
wire i_load_when_page_hit_limit_reaching;
wire i_sch_when_entry_critical_early; //entry was already loaded
wire i_same_bank_inc_as_rdwr_op;
wire r_same_bank_inc_as_pre;
wire r_same_bank_inc_as_any_op1;

assign i_same_bank_inc_as_rdwr_op    = &(ih_te_wr_rankbank_num ~^ ts_bsm_num4rdwr);
assign r_same_bank_inc_as_pre        = &(ih_te_wr_rankbank_num ~^ r_ts_bsm_num4pre);
assign r_same_bank_inc_as_any_op1    = &(ih_te_wr_rankbank_num ~^ r_ts_bsm_num4rdwr);

assign i_load_when_page_hit_limit_reached = i_load & (page_hit_limit_reached_incoming);
assign i_load_when_page_hit_limit_reaching = i_load &  (page_hit_limit_incoming & ts_op_is_wr & i_same_bank_inc_as_rdwr_op);
assign i_sch_when_entry_critical_early = i_entry_loaded & (i_same_bank_as_rdwr_op & ts_op_is_wr & i_entry_critical_early);
assign i_set_page_close_when_load  = i_load & ( (r_te_rdwr_autopre & r_same_bank_inc_as_any_op1) | (r_ts_op_is_precharge & r_same_bank_inc_as_pre) );

//Assertion to check critical assert when the entry is loading and page_hit_limiter is reached
property p_i_load_when_page_hit_limit_reached;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn || (IE_WR_ECC_ENTRY==1))
    i_load_when_page_hit_limit_reached |=> i_entry_critical==1'b1;
endproperty

//Assertion to check critical assert when the entry is loading and page_hit_limiter is just reaching and a pagehit is scheduled
property p_i_load_when_page_hit_limit_reaching;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn || (IE_WR_ECC_ENTRY==1))
    i_load_when_page_hit_limit_reaching |=> i_entry_critical==1'b1;
endproperty

//Assertion to check critical assert when the entry is set to critical early and a pagehit is scheduled
property p_i_sch_when_entry_critical_early;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn || (IE_WR_ECC_ENTRY==1))
    i_sch_when_entry_critical_early |=> i_entry_critical==1'b1;
endproperty

//Assertion to check critical de-assert when the a precharge or aoto-pre command to the bank of this entry
property p_set_page_close_for_pre_clr_critical;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn || (IE_WR_ECC_ENTRY==1))
    set_page_close_for_pre & i_entry_loaded |=> i_entry_critical==1'b0;
endproperty

//Assertion to check critical_early de-assert when the a precharge or aoto-pre command to the bank of this entry
property p_set_page_close_for_pre_clr_critical_early;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
    set_page_close_for_pre & i_entry_loaded |=> i_entry_critical_early==1'b0;
endproperty
//when the entry is loaded, and set page close for the bank of this entry, page_hit_limit_incoming and page_hit_limit_reached_incoming should not asserted to set entry_critical or entry_critical_early.
property p_set_page_close_when_load_no_page_hit_limit;
  @ (negedge co_te_clk) disable iff (~core_ddrc_rstn)
    i_set_page_close_when_load |-> ~page_hit_limit_incoming & ~page_hit_limit_reached_incoming;
endproperty

generate
  if (IE_WR_ECC_ENTRY==0) begin : WRCAM_ENTRY5
a_i_load_when_page_hit_limit_reached : assert property (p_i_load_when_page_hit_limit_reached);
a_i_load_when_page_hit_limit_reaching : assert property (p_i_load_when_page_hit_limit_reaching);
a_i_sch_when_entry_critical_early : assert property (p_i_sch_when_entry_critical_early);
a_set_page_close_for_pre_clr_critical: assert property (p_set_page_close_for_pre_clr_critical);
a_set_page_close_for_pre_clr_critical_early: assert property (p_set_page_close_for_pre_clr_critical_early);
a_set_page_close_when_load_no_page_hit_limit: assert property (p_set_page_close_when_load_no_page_hit_limit);
  end
endgenerate


covergroup cg_pagehit_limit @(posedge co_te_clk); 

  cp_entry_critical: coverpoint ({i_load_when_page_hit_limit_reached,i_load_when_page_hit_limit_reaching, i_set_page_close_when_load, i_sch_when_entry_critical_early, set_page_close_for_pre}) iff(core_ddrc_rstn) {
            bins  load_reached       = {5'b10000};
            bins  load_reaching      = {5'b01000};
            bins  load_pre           = {5'b00100};
            bins  sch_to_reached     = {5'b00010};
            bins  pre_to_clr         = {5'b00001};
  }
endgroup: cg_pagehit_limit

cg_pagehit_limit cg_pagehit_limit_inst = new;





`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule // te_wr_entry
