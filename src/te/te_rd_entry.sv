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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_rd_entry.sv#1 $
// -------------------------------------------------------------------------
// Description:
// 1. entry contents of the read CAM
// 2. returns participation and page hit on cam search
// 3. collision detection
//
// -------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_rd_entry #(
    //-------------------------------- PARAMETERS ----------------------------------
    // bit widths; should be overridden from read CAM
     parameter       RANKBANK_BITS      = 5
    ,parameter       PAGE_BITS          = 16
    ,parameter       BLK_BITS           = 10
    ,parameter       BG_BANK_BITS       = 4
    ,parameter       RANK_BITS          = 0
    ,parameter       BSM_BITS           = `UMCTL2_BSM_BITS
    ,parameter       OTHER_ENTRY_BITS   = 31
    ,parameter       BANK_BITS          = 3
    ,parameter       BG_BITS            = 2
    // fields of entry
    ,parameter       RMW_BITS           = 1
    ,parameter       RD_LATENCY_BITS    = `UMCTL2_XPI_RQOS_TW
    ,parameter       BT_BITS            = `MEMC_BLK_TOKEN_BITS // Override
    ,parameter       IE_WR_TYPE_BITS    = 2
    ,parameter       IE_RD_TYPE_BITS    = 2
    ,parameter       IE_BURST_NUM_BITS  = 3
    ,parameter       IE_UNIQ_BLK_BITS   = 4
    ,parameter       IE_UNIQ_BLK_LSB    = 3
    ,parameter       IE_MASKED_BITS     = 1
    ,parameter       ECCAP_BITS         = 1
    ,parameter       RETRY_RD_BITS      = 1
    ,parameter       RETRY_TIMES_WIDTH  = 3
    ,parameter       CRC_RETRY_TIMES_WIDTH  = 4
    ,parameter       UE_RETRY_TIMES_WIDTH  = 4
    ,parameter       RD_CRC_RETRY_LIMIT_REACH_BITS = 1
    ,parameter       RD_UE_RETRY_LIMIT_REACH_BITS = 1
    ,parameter       DDR4_COL3_BITS     = 1
    ,parameter       WORD_BITS          = 1
    ,parameter       CMD_LEN_BITS       = 1
    // 2-bit read priority encoding
    ,parameter       CMD_PRI_LPR        = `MEMC_CMD_PRI_LPR     
    ,parameter       CMD_PRI_VPR        = `MEMC_CMD_PRI_VPR      
    ,parameter       CMD_PRI_HPR        = `MEMC_CMD_PRI_HPR      
    ,parameter       CMD_PRI_XVPR       = `MEMC_CMD_PRI_XVPR      
    ,parameter       ENTRY_VALID        = 0                  // bit 0 of entry is the valid bit
    ,parameter       AUTOPRE_BITS       = 1                  // bit 1 of entry is auto pre-charge bit
    ,parameter       NUM_TOTAL_BANKS    = 1 << RANKBANK_BITS
    )
    (
    //---------------------------- INPUTS AND OUTPUTS ------------------------------
     input                         core_ddrc_rstn            // reset
    ,input                         co_te_clk                 // main clock
    ,input                         ddrc_cg_en                // clock gating enable
    ,input  [1:0]                  ih_te_hi_pri              // incoming is a high priority read command
    ,output [1:0]                  i_entry_out_pri           // priority
    ,input  [PAGE_BITS-1:0]        r_ts_act_page             // Row address of the activated page during read mode
    ,input                         r_te_rdwr_autopre         // autopre this cycle
    ,input  [BSM_BITS-1:0]         r_ts_bsm_num4pre          // BSM numer of the precharge cmd selected by the scheduler
    ,input  [BSM_BITS-1:0]         r_ts_bsm_num4any          // BSM number of the ACT , ACT bypass, PRE or RDWR (registered)
    ,input  [BSM_BITS-1:0]         r_ts_bsm_num4act          // BSM number of the ACT , ACT bypass (registered)      
    ,input  [BSM_BITS-1:0]         r_ts_bsm_num4rdwr         // BSM number of the RDWR (registered)      
    ,input                         r_ts_op_is_precharge      // precharge scheduled this cycle
    ,input                         r_ts_op_is_activate       // activate scheduled this cycle
    ,input                         be_te_page_hit            // the incoming command from IH has a current page hit    
    ,input                         ih_te_rmw                 // incoming is a read-modify-write
    ,input                         ih_te_rd_autopre          // auto precharge enable
    ,input  [RANKBANK_BITS-1:0]    ih_te_rd_rankbank_num     // bank number
    ,input  [PAGE_BITS-1:0]        ih_te_rd_page_num         // page number
    ,input  [BLK_BITS-1:0]         ih_te_rd_block_num        // page number

    ,input  [CMD_LEN_BITS-1:0]     ih_te_rd_length
    ,input  [WORD_BITS-1:0]        ih_te_critical_dword
    ,input  [OTHER_ENTRY_BITS-1:0] ih_te_other_fields        // everything else
    ,input  [BSM_BITS-1:0]         ts_bsm_num4rdwr           // BSM number on DRAM access
    ,input                         ts_op_is_rd               // current DRAM op is a read
    ,input                         i_load                    // store entry signal
    ,input                         i_entry_del               // delete entry signal
    ,output [RANKBANK_BITS-1:0]    i_entry_out_rankbank      // entry contents
    ,output [PAGE_BITS-1:0]        i_entry_out_page          // entry contents
    ,output [BLK_BITS-1:0]         i_entry_out_blk           // entry contents
    ,output [CMD_LEN_BITS-1:0]     i_entry_out_rd_length     // entry contents
    ,output [WORD_BITS-1:0]        i_entry_out_critical_dword //entry contents   
    ,output [OTHER_ENTRY_BITS-1:0] i_entry_out_other_fields  // entry contents
    ,output [AUTOPRE_BITS-1:0]     i_entry_out_autopre       // entry contents
    ,output                        i_same_addr_rd            // same address as incoming xaction address
    ,output                        i_same_addr_rmw           // same address as incoming xaction address
    ,output                        i_bank_hit                // same rank/bank number on cam search but asserted only if this entry is not expired-VPR
                                                             // in designs where UMCTL2_VPR_EN is not defined, this will be same as i_bank_hit
    ,output                        i_bank_hit_act            // same rank/bank number with ACT 
    ,input  [BSM_BITS-1:0]         ts_bsm_num4pre            // BSM numer of the precharge cmd selected by the scheduler
    ,output                        i_bank_hit_pre            // same rank/bank number with PRE 
    ,output                        i_page_hit                // same page number as in open page table in BE module
    ,output                        i_entry_valid             // entry is valid
    ,output                        i_entry_loaded            // entry is loaded
    ,output                        page_open_any_op          // page is open for this entry if same bank of ACT, RDWR, or PRE one cycle earlier
    ,input                         page_hit_limit_reached
    ,input                         page_hit_limit_incoming   // Incoming bank has page-hit_limiter expired
    ,output reg                    i_entry_critical_early
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    `endif
    `endif


    );

    //------------------------- LOCAL PARAMETERS -----------------------------------
    localparam        ENTRY_AUTOPRE_LSB      = 1;
    localparam        ENTRY_AUTOPRE_MSB      = ENTRY_AUTOPRE_LSB + AUTOPRE_BITS - 1; 
    localparam        ENTRY_HI_PRI_LSB       = ENTRY_AUTOPRE_MSB+1;
    localparam        ENTRY_HI_PRI_MSB       = ENTRY_HI_PRI_LSB + 2 - 1;
    localparam        ENTRY_RMW              = ENTRY_HI_PRI_MSB + RMW_BITS;
    localparam        ENTRY_BLK_LSB          = ENTRY_RMW + 1;
    localparam        ENTRY_BLK_MSB          = ENTRY_BLK_LSB + BLK_BITS - 1;
    localparam        ENTRY_ROW_LSB          = ENTRY_BLK_MSB + 1;
    localparam        ENTRY_ROW_MSB          = ENTRY_ROW_LSB + PAGE_BITS - 1;
    localparam        ENTRY_RANKBANK_LSB     = ENTRY_ROW_MSB + 1;
    localparam        ENTRY_RANKBANK_MSB     = ENTRY_RANKBANK_LSB + RANKBANK_BITS - 1;
    localparam        ENTRY_IE_BT_LSB        = ENTRY_RANKBANK_MSB + 1;
    localparam        ENTRY_IE_BT_MSB        = ENTRY_IE_BT_LSB + BT_BITS - 1;
    localparam        ENTRY_IE_RD_TYPE_LSB   = ENTRY_IE_BT_MSB + 1;
    localparam        ENTRY_IE_RD_TYPE_MSB   = ENTRY_IE_RD_TYPE_LSB + IE_RD_TYPE_BITS - 1;
    localparam        ENTRY_IE_BURST_NUM_LSB = ENTRY_IE_RD_TYPE_MSB + 1;
    localparam        ENTRY_IE_BURST_NUM_MSB = ENTRY_IE_BURST_NUM_LSB + IE_BURST_NUM_BITS - 1;
    localparam        ENTRY_IE_UNIQ_BLK_LSB  = ENTRY_IE_BURST_NUM_MSB + 1;
    localparam        ENTRY_IE_UNIQ_BLK_MSB  = ENTRY_IE_UNIQ_BLK_LSB + IE_UNIQ_BLK_BITS - 1;
    localparam        ENTRY_IE_MASKED_LSB    = ENTRY_IE_UNIQ_BLK_MSB + 1;
    localparam        ENTRY_IE_MASKED_MSB    = ENTRY_IE_MASKED_LSB + IE_MASKED_BITS - 1;
    localparam        ENTRY_ECCAP_LSB        = ENTRY_IE_MASKED_MSB + 1;
    localparam        ENTRY_ECCAP_MSB        = ENTRY_ECCAP_LSB + ECCAP_BITS - 1;
    localparam        ENTRY_RETRY_RD_LSB     = ENTRY_ECCAP_MSB + 1;
    localparam        ENTRY_RETRY_RD_MSB     = ENTRY_RETRY_RD_LSB + RETRY_RD_BITS - 1;
    localparam        ENTRY_CRC_RETRY_TIMES_LSB  = ENTRY_RETRY_RD_MSB + 1;
    localparam        ENTRY_CRC_RETRY_TIMES_MSB  = ENTRY_CRC_RETRY_TIMES_LSB + CRC_RETRY_TIMES_WIDTH -1;
    localparam        ENTRY_UE_RETRY_TIMES_LSB   = ENTRY_CRC_RETRY_TIMES_MSB + 1;
    localparam        ENTRY_UE_RETRY_TIMES_MSB   = ENTRY_UE_RETRY_TIMES_LSB + UE_RETRY_TIMES_WIDTH -1;
    localparam        ENTRY_RD_CRC_RETRY_LIMIT_REACH_LSB = ENTRY_UE_RETRY_TIMES_MSB + 1;
    localparam        ENTRY_RD_CRC_RETRY_LIMIT_REACH_MSB = ENTRY_RD_CRC_RETRY_LIMIT_REACH_LSB + RD_CRC_RETRY_LIMIT_REACH_BITS -1;
    localparam        ENTRY_RD_UE_RETRY_LIMIT_REACH_LSB = ENTRY_RD_CRC_RETRY_LIMIT_REACH_MSB + 1;
    localparam        ENTRY_RD_UE_RETRY_LIMIT_REACH_MSB = ENTRY_RD_UE_RETRY_LIMIT_REACH_LSB + RD_UE_RETRY_LIMIT_REACH_BITS -1;
    localparam        ENTRY_DDR4_COL3_LSB    = ENTRY_RD_UE_RETRY_LIMIT_REACH_MSB + 1;
    localparam        ENTRY_DDR4_COL3_MSB    = ENTRY_DDR4_COL3_LSB + DDR4_COL3_BITS - 1;
    localparam        ENTRY_OTHER_LSB        = ENTRY_DDR4_COL3_MSB + 1;
    localparam        ENTRY_OTHER_MSB        = ENTRY_OTHER_LSB + OTHER_ENTRY_BITS - 1;
    localparam        ENTRY_LENGTH_LSB       = ENTRY_OTHER_MSB + 1;
    localparam        ENTRY_LENGTH_MSB       = ENTRY_LENGTH_LSB + CMD_LEN_BITS - 1;
    localparam        ENTRY_WORD_LSB         = ENTRY_LENGTH_MSB + 1;
    localparam        ENTRY_WORD_MSB         = ENTRY_WORD_LSB + WORD_BITS - 1;
    localparam        ENTRY_BITS             = ENTRY_WORD_MSB + 1;

//----------------------------- REGS AND WIRES ---------------------------------

reg  [ENTRY_BITS-1:0]         r_entry;                  // actual storage

assign                        i_entry_out_pri = r_entry [ENTRY_HI_PRI_MSB:ENTRY_HI_PRI_LSB];

wire                          i_same_rdwr_bank;

//------------------------------ MAINLINE CODE ---------------------------------
assign i_entry_out_autopre          = r_entry [ENTRY_AUTOPRE_MSB:ENTRY_AUTOPRE_LSB];
assign i_entry_out_rd_length        = r_entry [ENTRY_LENGTH_MSB      : ENTRY_LENGTH_LSB];
assign i_entry_out_critical_dword   = r_entry [ENTRY_WORD_MSB        : ENTRY_WORD_LSB];
assign i_entry_out_other_fields     = r_entry [ENTRY_OTHER_MSB       : ENTRY_OTHER_LSB];
assign i_entry_out_rankbank         = r_entry [ENTRY_RANKBANK_MSB    : ENTRY_RANKBANK_LSB ];
assign i_entry_out_page             = r_entry [ENTRY_ROW_MSB         : ENTRY_ROW_LSB  ];
assign i_entry_out_blk              = r_entry [ENTRY_BLK_MSB         : ENTRY_BLK_LSB  ];
assign i_entry_loaded               = r_entry [ENTRY_VALID];
assign i_entry_valid                = i_entry_loaded
;

//-------------------------   r_page_open ---------------------------------------
reg   r_page_open;
wire  r_page_hit_act;
wire  set_page_open_for_act;
wire  set_page_close_for_pre;
wire  page_open_next;
wire  page_open;

   
//---------------------------
// comparators to decide bank and page hit for act and pre commands
// need this to generate the r_page_open flag per-entry
//---------------------------
wire r_same_bank_any_op;
wire r_same_bank_act_op;   
wire r_same_bank_rdwr_op;   
wire r_same_pre_bank;
wire i_entry_valid_same_bank = `UPCTL2_EN ? i_entry_valid : 1'b1; // wire used in uMCTL2/uPCTL2 combined logic


//Combine with r_same_pre_rank for the comparison of Rank.

assign r_same_bank_any_op   = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4any))  & i_entry_valid_same_bank;
assign r_same_bank_act_op   = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4act))  & i_entry_valid_same_bank;
assign r_same_bank_rdwr_op  = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4rdwr)) & i_entry_valid_same_bank;
assign r_same_pre_bank      = (& (i_entry_out_rankbank ~^ r_ts_bsm_num4pre))  & i_entry_valid_same_bank;
assign page_open_any_op     = `UPCTL2_EN ? page_open_next & r_same_bank_any_op :  page_open_next & r_same_bank_any_op & i_entry_loaded;  
   
assign r_page_hit_act       = (& (i_entry_out_page      ~^ r_ts_act_page   )) & r_same_bank_act_op;

assign set_page_open_for_act  = r_ts_op_is_activate & r_page_hit_act;

assign set_page_close_for_pre = (r_te_rdwr_autopre & r_same_bank_rdwr_op) | (r_ts_op_is_precharge & r_same_pre_bank)
;


wire   i_be_te_page_hit;
assign i_be_te_page_hit = be_te_page_hit;

reg r_be_te_page_hit;
reg r_load;
assign  page_open = set_page_open_for_act ? 1'b1 :
                    set_page_close_for_pre ? 1'b0 :
        r_load ? r_be_te_page_hit :r_page_open;

assign page_open_next = `UPCTL2_EN ? page_open : (page_open & i_entry_loaded);
   
always @ (posedge co_te_clk or negedge core_ddrc_rstn) begin
  if(~core_ddrc_rstn) begin
     r_page_open        <= 1'b0;
     r_be_te_page_hit   <= 1'b0;
     r_load             <= 1'b0;
  end
  else begin
     r_page_open        <= page_open_next;
     r_be_te_page_hit   <= i_be_te_page_hit;
     r_load             <= i_load;
  end
end // always @ (posedge co_te_clk or negedge core_ddrc_rstn)
   


// entry valid contents
always @(posedge co_te_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    r_entry [ENTRY_BITS-1:0] <= {ENTRY_BITS{1'b0}};
  end
  else if(ddrc_cg_en)
  begin
    if (i_load) begin
      r_entry[ENTRY_LENGTH_MSB:ENTRY_LENGTH_LSB]   <= ih_te_rd_length;
      r_entry[ENTRY_WORD_MSB: ENTRY_WORD_LSB]      <= ih_te_critical_dword;

      r_entry[ENTRY_OTHER_MSB:ENTRY_OTHER_LSB]     <= ih_te_other_fields; // read tag
      r_entry[ENTRY_RMW]                           <= ih_te_rmw;          // RMW type
      r_entry[ENTRY_AUTOPRE_LSB]                    <= ih_te_rd_autopre;      // auto precharge enable
      r_entry[ENTRY_AUTOPRE_MSB]                    <= ih_te_rmw; // For read part of RMW, AP is not applied
      r_entry[ENTRY_RANKBANK_MSB:ENTRY_RANKBANK_LSB]<= ih_te_rd_rankbank_num;// bank number
      r_entry[ENTRY_ROW_MSB:ENTRY_ROW_LSB]         <= ih_te_rd_page_num;     // page number
      r_entry[ENTRY_BLK_MSB:ENTRY_BLK_LSB]         <= ih_te_rd_block_num;    // block number
    end



    if (i_load)
       r_entry[ENTRY_VALID] <= 1'b1;
    else if (i_entry_del)
      r_entry[ENTRY_VALID]  <= 1'b0;
     if (i_load) begin
      r_entry[ENTRY_HI_PRI_MSB:ENTRY_HI_PRI_LSB]   <= ih_te_hi_pri;  // load value from IH
     end
  end

// comparators
assign i_same_rdwr_bank=(& (r_entry [ENTRY_RANKBANK_MSB:ENTRY_RANKBANK_LSB] ~^ ts_bsm_num4rdwr [BSM_BITS-1:0]));

// cam search
// this signal goes high for all the entries that have a bank-hit to the currently scheduled command
// this is used as the valid signal going to the filter n/w in the te_rd_replace module
assign i_bank_hit =   (ts_op_is_rd & i_same_rdwr_bank 
                      & (i_entry_valid   // This entry is valid
                        )); 

// cam serch by ACT for WR
assign i_bank_hit_act = r_same_bank_act_op & i_entry_valid;
// cam serch by PRE
assign i_bank_hit_pre       = (ts_bsm_num4pre==i_entry_out_rankbank) & i_entry_valid;


// page hit 
// no need to check rank/bank as the the page hit info will be used only for entries with i_bank_hit in te_rd_replce module
assign i_page_hit = page_open_next;   

// collision detection
// Internal address signal for collision detection

// CAM entry
reg  [RANKBANK_BITS-1:0]               i_entry_rankbank;
reg  [BLK_BITS-1:0]                    i_entry_blk;
reg  [PAGE_BITS-1:0]                   i_entry_page;

// Incomiing command
reg  [RANKBANK_BITS-1:0]               i_rd_incoming_rankbank;
reg  [BLK_BITS-1:0]                    i_rd_incoming_blk;
reg  [PAGE_BITS-1:0]                   i_rd_incoming_page;

// Assign Existing address to be compared
always @(*) begin
  // For existing entry
  i_entry_rankbank       = r_entry [ENTRY_RANKBANK_MSB:ENTRY_RANKBANK_LSB];
  i_entry_blk            = r_entry [ENTRY_BLK_MSB:ENTRY_BLK_LSB];
  i_entry_page           = r_entry [ENTRY_ROW_MSB:ENTRY_ROW_LSB];
  // For incoming entry
  i_rd_incoming_rankbank = ih_te_rd_rankbank_num;
  i_rd_incoming_blk      = ih_te_rd_block_num;
  i_rd_incoming_page     = ih_te_rd_page_num;
end


assign
  i_same_addr_rd = i_entry_loaded 
                   & (& (i_entry_rankbank ~^ i_rd_incoming_rankbank [RANKBANK_BITS-1:0])) 
                   & (& (i_entry_page     ~^ i_rd_incoming_page     [PAGE_BITS-1:0]))     
                   & (& (i_entry_blk      ~^ i_rd_incoming_blk      [BLK_BITS-1:0]))
 ;

assign i_same_addr_rmw = i_same_addr_rd & r_entry[ENTRY_RMW];

                 


//------------------
// page hit limiter
//------------------
always @(posedge co_te_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    i_entry_critical_early <= 1'b0;
  end
  else begin
    if (i_load & page_hit_limit_incoming) begin
      i_entry_critical_early <= 1'b1;
    end
    else if (~i_entry_loaded) begin        
      i_entry_critical_early <= 1'b0;
    end
    else begin
      i_entry_critical_early <= (set_page_close_for_pre)? 1'b0 : (r_same_bank_rdwr_op & page_hit_limit_reached)? 1'b1 : i_entry_critical_early;
    end
  end
end
   
//-------------------

`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON


camEntryOverwritten: //---------------------------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
    (!(i_entry_loaded & i_load)) )
    else $error("[%t][%m] ERROR: Read CAM entry gets overwritten.", $time);

invalidTransactionScheduled: //-------------------------------------------------
    assert property ( @ (posedge co_te_clk) disable iff (~core_ddrc_rstn)
    (!(~i_entry_loaded & i_entry_del)) )
    else $error("[%t][%m] ERROR: Invalid Transaction Scheduled.", $time);


reg rd_cam_overwr;
reg rd_cam_dup;

initial
begin
  rd_cam_overwr = 1'b0;
  rd_cam_dup    = 1'b0;
end

// disable coverage collection as this is a check in SVA only        
// VCS coverage off 

always @(posedge co_te_clk)
begin
  if (r_entry [0] && i_load)
  begin
    $display ("%m: at %t ERROR: CAM entry gets overwritten.", $time);
    rd_cam_overwr = 1'b1;
  end
  if (~r_entry [0] && i_entry_del)
  begin
    $display ("%m: at %t ERROR: CAM entry gets duplicated transaction.", $time);
    rd_cam_dup = 1'b1;
  end
end

// VCS coverage on








`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule // te_rd_entry
