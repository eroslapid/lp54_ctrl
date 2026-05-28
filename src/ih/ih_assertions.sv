//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_assertions.sv#1 $
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
//                              Description
//
// ----------------------------------------------------------------------------


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

`include "DWC_ddrctl_all_defs.svh"
module ih_assertions(
        co_ih_clk,
        core_ddrc_rstn,
        dh_ih_operating_mode,
  
        hif_cmd_valid,
        hif_cmd_addr,
        hif_cmd_type,
        hif_cmd_token,
        hif_cmd_pri,
        hif_cmd_length,
        hif_cmd_wdata_ptr,
        hif_cmd_stall,
        hif_wdata_ptr,
        hif_wdata_ptr_valid,
        hif_lpr_credit,
        hif_wr_credit,
        hif_hpr_credit,

        // WU Interface
        wu_ih_flow_cntrl_req,



// TE Interface
        ih_te_rd_valid,
        ih_te_wr_valid,
        ih_te_rd_valid_addr_err,
        ih_te_wr_valid_addr_err,
        ih_te_rd_length,
        ih_te_rd_tag,
        ih_te_rmwtype,
        ih_te_bg_bank_num,
        ih_te_page_num,
        ih_te_block_num,
        ih_te_critical_dword,
        ih_te_rd_entry,
        ih_te_wr_entry,
        ih_te_lo_rd_prefer,
        ih_te_wr_prefer,

        ih_te_hi_pri,
        ih_te_hi_rd_prefer,

        ih_gs_rdhigh_empty,
        ih_be_hi_pri_rd_xact,
        dh_ih_lpr_num_entries,
        ih_be_bg_bank_num,
        ih_be_page_num,

        te_ih_free_rd_entry,
        te_ih_free_rd_entry_valid,
        mr_ih_free_wr_entry,
        mr_ih_free_wr_entry_valid,
        te_ih_retry,
        te_ih_retry_i,
        te_ih_core_in_stall,
        te_ih_wr_combine
       ,reg_ddrc_ecc_type
);

parameter   RDCMD_ENTRY_BITS  = 5;    // bits to address all entries in read CAM                   
parameter   WRCMD_ENTRY_BITS  = 5;    // bits to address all entries in write CAM                  
parameter   CORE_ADDR_WIDTH   = 35;   // any change may necessitate a change to address map in IC  
parameter   IH_TAG_WIDTH      = 8;    // width of token/tag field from core                         
parameter   CMD_LEN_BITS      = 1;    // bits for command length, when used                        
parameter   RMW_TYPE_BITS     = 2;    // 2 bits for RMW type                                       
                                      //  (partial write, atomic RMW, scrub, or none)              
parameter   WDATA_PTR_BITS    = 8;                                                                 

parameter   CMD_TYPE_BITS     = 2;    // any change will require RTL modifications in IC           
localparam  WRDATA_ENTRY_BITS = WRCMD_ENTRY_BITS + 1;        // write data RAM entries
                                        // (only support 2 datas per command at the moment)

localparam  WR_CAM_DEPTH      = (1 << WRCMD_ENTRY_BITS);
localparam  RD_CAM_DEPTH      = (1 << RDCMD_ENTRY_BITS);
localparam  WRDATA_CYCLES     = `MEMC_WRDATA_CYCLES;


parameter IE_RD_TYPE_BITS   = `IE_RD_TYPE_BITS;
parameter IE_WR_TYPE_BITS   = `IE_WR_TYPE_BITS;

input                             co_ih_clk;
input                             core_ddrc_rstn;
 
    input [2:0]                   dh_ih_operating_mode;        // global schedule FSM state

  

input                             hif_cmd_valid;
input   [CMD_TYPE_BITS-1:0]       hif_cmd_type;
input   [CORE_ADDR_WIDTH-1:0]     hif_cmd_addr;
input   [IH_TAG_WIDTH-1:0]        hif_cmd_token;
input   [1:0]                     hif_cmd_pri;
input   [CMD_LEN_BITS-1:0]        hif_cmd_length;
input   [WDATA_PTR_BITS-1:0]      hif_cmd_wdata_ptr;
input                             hif_cmd_stall;
input  [WDATA_PTR_BITS-1:0]       hif_wdata_ptr;
input                             hif_wdata_ptr_valid;
input                              hif_wr_credit;
input  [`MEMC_HIF_CREDIT_BITS-1:0] hif_lpr_credit;
input  [`MEMC_HIF_CREDIT_BITS-1:0] hif_hpr_credit;

input                             wu_ih_flow_cntrl_req;


input                             ih_te_rd_valid;
input                             ih_te_wr_valid;
input                             ih_te_rd_valid_addr_err;
input                             ih_te_wr_valid_addr_err;
input  [CMD_LEN_BITS-1:0]         ih_te_rd_length;
input  [IH_TAG_WIDTH-1:0]         ih_te_rd_tag;
input  [RMW_TYPE_BITS-1:0]        ih_te_rmwtype;

input  [`MEMC_BG_BANK_BITS -1:0]  ih_te_bg_bank_num;
input  [`MEMC_PAGE_BITS -1:0]     ih_te_page_num;
input  [`MEMC_BLK_BITS  -1:0]     ih_te_block_num;
input  [`MEMC_WORD_BITS -1:0]     ih_te_critical_dword;

input  [RDCMD_ENTRY_BITS-1:0]     ih_te_rd_entry;
input  [WRCMD_ENTRY_BITS-1:0]     ih_te_wr_entry;
input  [WRCMD_ENTRY_BITS-1:0]     ih_te_wr_prefer;
input  [RDCMD_ENTRY_BITS-1:0]     ih_te_lo_rd_prefer;
input [RDCMD_ENTRY_BITS-1:0]      ih_te_hi_rd_prefer;
input [1:0]                       ih_te_hi_pri;


input  [`MEMC_BG_BANK_BITS -1:0]  ih_be_bg_bank_num;
input  [`MEMC_PAGE_BITS -1:0]     ih_be_page_num;

input   [RDCMD_ENTRY_BITS-1:0]    te_ih_free_rd_entry;
input                             te_ih_free_rd_entry_valid;
input   [WRCMD_ENTRY_BITS-1:0]    mr_ih_free_wr_entry;
input                             mr_ih_free_wr_entry_valid;
input                             te_ih_retry;
input                             te_ih_retry_i; //te_ih_retry_i will be assert when te_ih_retry or ie_cmd_active assert, indicate block the input fifo
input                             te_ih_core_in_stall;  //it will be assert when pipeline is full or overhead command is pushing to pipeline
input                             te_ih_wr_combine;



input                             reg_ddrc_ecc_type;

input                             ih_be_hi_pri_rd_xact;           // hi priority read transaction valid
input   [RDCMD_ENTRY_BITS-1:0]    dh_ih_lpr_num_entries;
input                             ih_gs_rdhigh_empty;             // transaction queue is empty

//--------------------------------------------------
//---------- AUXILLARY CODE    ---------------------
//--------------------------------------------------


         wire [WRCMD_ENTRY_BITS-1:0]      wr_oldest_radd = ih_te_wr_prefer;


   localparam IH_BUF_DEPTH = 2;
   localparam IH_BUF_ADDR_BITS = 1;


wire    valid_from_core_put, valid_from_core_get;
reg  [IH_BUF_ADDR_BITS-1:0]    valid_from_core_wptr, valid_from_core_rptr;
reg     valid_from_core_fifo   [IH_BUF_DEPTH-1:0];
wire    valid_from_core;

assign valid_from_core_put = hif_cmd_valid && ~hif_cmd_stall;
assign valid_from_core_get = (ih_te_rd_valid || ih_te_wr_valid) && ~te_ih_retry_i && ih_te_rmwtype!=`MEMC_RMW_TYPE_SCRUB;

always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(~core_ddrc_rstn) begin
      valid_from_core_wptr    <= {IH_BUF_ADDR_BITS{1'b0}};
   end
   else if(valid_from_core_put) begin
      valid_from_core_wptr    <= valid_from_core_wptr + 1'b1;
   end
end

always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
  if(~core_ddrc_rstn) begin
     for(int i=0; i<IH_BUF_DEPTH; i=i+1)
         valid_from_core_fifo[i] <= 1'b0;
  end
  else begin
    case({valid_from_core_get,valid_from_core_put})
      2'b00 : ;
      2'b01 : valid_from_core_fifo[valid_from_core_wptr] <= 1'b1;
      2'b10 : valid_from_core_fifo[valid_from_core_rptr] <= 1'b0;
      2'b11 : begin
              valid_from_core_fifo[valid_from_core_wptr] <= 1'b1;
              valid_from_core_fifo[valid_from_core_rptr] <= 1'b0;
            end
    endcase
  end
end


always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(~core_ddrc_rstn)
      valid_from_core_rptr            <= {IH_BUF_ADDR_BITS{1'b0}};
   else if(valid_from_core_get)
      valid_from_core_rptr            <= valid_from_core_rptr + 1'b1;
end

assign  valid_from_core = valid_from_core_fifo[valid_from_core_rptr];





//##############################
// CREDIT CHECKING LOGIC
//##############################


wire  [WRCMD_ENTRY_BITS-1:0]  max_wr_entries;
wire  [WRCMD_ENTRY_BITS-1:0]  max_wrecc_entries;
wire  [RDCMD_ENTRY_BITS-1:0]  max_lpr_entries;
wire  [RDCMD_ENTRY_BITS-1:0]  max_hpr_entries;

wire  [WRCMD_ENTRY_BITS-1:0]  init_wr_credits;
wire  [WRCMD_ENTRY_BITS-1:0]  init_wrecc_credits;
wire  [RDCMD_ENTRY_BITS-1:0]  init_lpr_credits;
wire  [RDCMD_ENTRY_BITS-1:0]  init_hpr_credits;


// Max value for credits

assign  init_wr_credits   = {WRCMD_ENTRY_BITS{1'b0}};
assign  init_wrecc_credits= {WRCMD_ENTRY_BITS{1'b0}};
assign  init_lpr_credits  = {RDCMD_ENTRY_BITS{1'b0}};
assign  init_hpr_credits  = {RDCMD_ENTRY_BITS{1'b0}};

assign  max_wr_entries  = {WRCMD_ENTRY_BITS{1'b1}};
assign  max_wrecc_entries = 0;
assign  max_lpr_entries = dh_ih_lpr_num_entries;
assign  max_hpr_entries = ({RDCMD_ENTRY_BITS{1'b1}} - dh_ih_lpr_num_entries);


//------------------------------------------
// Illegal value on the priority input for reads
// When Arbiter and VPR: pri=2'b11 is illegal (legal values: 00 - LPR, 01 - VPR, 10 - HPR)
//------------------------------------------

assign illegal_rd_pri_value = hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD) 
                                || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                ) && !hif_cmd_stall &&
                            ((hif_cmd_pri==`MEMC_CMD_PRI_XVPR) || (hif_cmd_pri==`MEMC_CMD_PRI_VPR));


property p_illegal_rd_pri_value;
        @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) ~illegal_rd_pri_value;
endproperty


assert_illegal_rd_pri_value: assert property (p_illegal_rd_pri_value);


//------------------------------------------
// Illegal value on the priority input for writes
// When Arbiter and VPW: pri=2'b10 and 2'b11 is illegal (legal values: 00 - NPW, 01 - VPW)
// HIF-only testbench puts non-zero value on hif_cmd_pri for write commands - these are ignnored by RTL
// hence the check is limited to configs with UMCTL2_INCL_ARB defined
//------------------------------------------

  
assign illegal_wr_pri_value = hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_WR)
                                || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                ) && !hif_cmd_stall
                         &&   ((hif_cmd_pri==`MEMC_CMD_PRI_XVPW) || (hif_cmd_pri==`MEMC_CMD_PRI_VPW) || (hif_cmd_pri==`MEMC_CMD_PRI_RSVD))
                        ;


property p_illegal_wr_pri_value;
        @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) ~illegal_wr_pri_value;
endproperty


assert_illegal_wr_pri_value: assert property (p_illegal_wr_pri_value);




/////////////////////////////
// WRITE Credit mechanism for generating the cmd_valid
/////////////////////////////

reg                           r_resetb;    // reset in the previous cycle
                                           //  (used by all 3 credit logic groups)
reg   [WRCMD_ENTRY_BITS:0]    wr_credits_avail;

wire                              incr_wr_credit;
wire                              decr_wr_credit;

assign decr_wr_credit = hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_WR)
                                || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                ) && !hif_cmd_stall;

        
assign incr_wr_credit = hif_wr_credit;

always @ (posedge co_ih_clk or negedge core_ddrc_rstn)  begin
  if(!core_ddrc_rstn) begin
    wr_credits_avail <= init_wr_credits;
    r_resetb         <= 1'b0;
  end
  else begin
    r_resetb         <= 1'b1;

    // assign credit_avail in the cycle after reset, in case it was modified
    //  in the same cycle that soft reset was de-asserted
    if (!r_resetb)
      wr_credits_avail <= init_wr_credits;

    case ({decr_wr_credit,incr_wr_credit})
      2'b00 : wr_credits_avail <= wr_credits_avail;
      2'b01 : wr_credits_avail <= wr_credits_avail + 1'b1;
      2'b10 : wr_credits_avail <= wr_credits_avail - 1'b1;
      2'b11 : wr_credits_avail <= wr_credits_avail;
    endcase

  end
end


/////////////////////////////
// LPR Credit mechanism for generating the cmd_valid
/////////////////////////////

reg   [RDCMD_ENTRY_BITS:0]      lpr_credits_avail;

wire  [`MEMC_HIF_CREDIT_BITS-1:0] incr_lpr_credit;
wire  [`MEMC_HIF_CREDIT_BITS-1:0] decr_lpr_credit;


assign decr_lpr_credit[0] = hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD)
                                || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                ) &&
                                !(hif_cmd_pri==2'b10) && !hif_cmd_stall;        
        
assign incr_lpr_credit = hif_lpr_credit; 

always @ (posedge co_ih_clk or negedge core_ddrc_rstn)  begin
  if(!core_ddrc_rstn)
    lpr_credits_avail <= init_lpr_credits;
  else begin

    // assign credit_avail in the cycle after reset, in case it was modified
    //  in the same cycle that soft reset was de-asserted
    if (!r_resetb)
      lpr_credits_avail <= init_lpr_credits;

    case ({decr_lpr_credit,incr_lpr_credit})
      2'b00 : lpr_credits_avail <= lpr_credits_avail;
      2'b01 : lpr_credits_avail <= lpr_credits_avail + 1'b1;
      2'b10 : lpr_credits_avail <= lpr_credits_avail - 1'b1;
      2'b11 : lpr_credits_avail <= lpr_credits_avail;
    endcase

  end
end


/////////////////////////////
// HPR Credit mechanism for generating the cmd_valid
/////////////////////////////

reg   [RDCMD_ENTRY_BITS-1:0]    hpr_credits_avail;
wire  [`MEMC_HIF_CREDIT_BITS-1:0] incr_hpr_credit;
wire  [`MEMC_HIF_CREDIT_BITS-1:0] decr_hpr_credit;


assign decr_hpr_credit[0] = hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD)
                                || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                ) && 
                                (hif_cmd_pri==2'b10) && !hif_cmd_stall;
      
assign incr_hpr_credit = hif_hpr_credit;

always @ (posedge co_ih_clk or negedge core_ddrc_rstn)  begin
  if(!core_ddrc_rstn)
    hpr_credits_avail <= init_hpr_credits;
  else begin

    // assign credit_avail in the cycle after reset, in case it was modified
    //  in the same cycle that soft reset was de-asserted
    if (!r_resetb)
      hpr_credits_avail <= init_hpr_credits;

    case ({decr_hpr_credit,incr_hpr_credit})
      2'b00 : hpr_credits_avail <= hpr_credits_avail;
      2'b01 : hpr_credits_avail <= hpr_credits_avail + 1'b1;
      2'b10 : hpr_credits_avail <= hpr_credits_avail - 1'b1;
      2'b11 : hpr_credits_avail <= hpr_credits_avail;
   endcase

  end
end




//---------------------------
// Keeping track of entries
//---------------------------
reg [WR_CAM_DEPTH-1:0] wr_entry_in_te;
reg [RD_CAM_DEPTH-1:0] rd_entry_in_te;


// WR CAM 
// 1 indicates there is an entry in the CAM 
// 0 indicates there is NO entry in the CAM 
always @(posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if (!core_ddrc_rstn) begin
       wr_entry_in_te <= {WR_CAM_DEPTH{1'b0}};
   end
   else begin
      if (~te_ih_retry && (ih_te_wr_valid 
                                && ~ih_te_wr_valid_addr_err
                          ) && ~te_ih_wr_combine )
         wr_entry_in_te[ih_te_wr_entry]   <= 1'b1;
      if (mr_ih_free_wr_entry_valid)
         wr_entry_in_te[mr_ih_free_wr_entry]   <= 1'b0;
   end
end


// RD CAM 
// 1 indicates there is an entry in the CAM 
// 0 indicates there is NO entry in the CAM 
always @(posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if (!core_ddrc_rstn) begin
       rd_entry_in_te <= {RD_CAM_DEPTH{1'b0}};
   end
   else begin
      if ((~te_ih_retry && (ih_te_rd_valid
                                && ~(ih_te_rd_valid_addr_err && ih_te_wr_valid_addr_err && ih_te_rmwtype==2'b00)
                           ) && (ih_te_rd_entry <= max_lpr_entries)) || 
          (~te_ih_retry && (ih_te_rd_valid
                                && ~(ih_te_rd_valid_addr_err && ih_te_wr_valid_addr_err && ih_te_rmwtype==2'b00)
                           ) && (ih_te_rd_entry > max_lpr_entries)))
         rd_entry_in_te[ih_te_rd_entry] <= 1'b1;
      if (te_ih_free_rd_entry_valid)
         rd_entry_in_te[te_ih_free_rd_entry] <= 1'b0;
   end
end






wire  other_retry;  // retry if for rd or wr request

assign  other_retry  = te_ih_retry && (ih_te_rd_valid ^ ih_te_wr_valid);




//--------------------------------------------------
//---------- INPUT ASSUMPTIONS ---------------------
//--------------------------------------------------

//---------------------------
//-------cmd_valid-----------
//---------------------------

property p_cmd_valid_keep_high;
  @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) hif_cmd_valid && hif_cmd_stall |-> ##1 hif_cmd_valid;
endproperty

property p_wr_cmd_valid_if_credit_avail;
  @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) (hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_WR)
                                                        || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                                        ) && !hif_cmd_stall)  |-> 
                (wr_credits_avail > 0);
endproperty



property p_lpr_cmd_valid_if_credit_avail;
  @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) (hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD)
                                                        || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                                        ) && 
              !(hif_cmd_pri==2'b10) && !hif_cmd_stall) |-> (lpr_credits_avail > 0);
endproperty


property p_hpr_cmd_valid_if_credit_avail;
  @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) (hif_cmd_valid && ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD)
                                                        || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                                                        ) &&
              (hif_cmd_pri==2'b10) && !hif_cmd_stall) |-> (hpr_credits_avail > 0);
endproperty


//---------------------------
//-------cmd_type-----------
//---------------------------
property p_cmd_type_legal;
     @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) (hif_cmd_valid && !hif_cmd_stall) |-> 
    ((hif_cmd_type == `MEMC_CMD_TYPE_BLK_WR) || 
     (hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD) 
                    || (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                    );
endproperty


//---------------------------
//------- RETRY allowed only if there is a rd_valid or wr_valid going to the TE
//---------------------------
property p_retry_legal;
   @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) te_ih_retry |-> (ih_te_rd_valid || ih_te_wr_valid);
endproperty


//---------------------------
//------- FREE RD ENTRY only if it has been allocated
//---------------------------
property p_free_rd_entry_only_if_allocated;
  @ (posedge co_ih_clk) disable iff (!core_ddrc_rstn) te_ih_free_rd_entry_valid |->
                rd_entry_in_te[te_ih_free_rd_entry];
endproperty


//---------------------------
//------- FREE WR ENTRY only if it has been allocated
//---------------------------
property p_free_wr_entry_only_if_allocated;
  @ (posedge co_ih_clk) disable iff (!core_ddrc_rstn) mr_ih_free_wr_entry_valid |->
                wr_entry_in_te[mr_ih_free_wr_entry];
endproperty








// Logic for generating a pulse one clock after reset de-asserts
reg     reset_ff;
wire    first_clk_after_reset;

// flop the reset
always @ (posedge co_ih_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn)
        reset_ff        <= 1'b0;
  else
        reset_ff        <= core_ddrc_rstn;

// pulse first clk after reset
assign first_clk_after_reset = core_ddrc_rstn & !reset_ff;

// Don't issue rxcmd_valid first clk after reset
// The max_entry_ff in the fifo_control module gets the value one clock after reset is de-asserted
// So if the request from core comes in the first clock after reset, it cannot be handled. the following is the
// constraint for preventing it
property p_no_cmd_first_clk_after_reset;
  @(posedge co_ih_clk) disable iff (~core_ddrc_rstn) hif_cmd_valid |-> ~first_clk_after_reset;
endproperty


//-------Calling the Assume properties -----------



assert_wr_cmd_valid_if_credit_avail  : assert property (p_wr_cmd_valid_if_credit_avail)
          else $error("%m @ %t WR cmd_valid asserted when no Write credits available", $time);


assert_lpr_cmd_valid_if_credit_avail  : assert property (p_lpr_cmd_valid_if_credit_avail)
          else $error("%m @ %t LPR cmd_valid asserted when no LPR credits available", $time);

assert_cmd_type_legal      : assert property (p_cmd_type_legal) 
          else $error("%m @ %t cmd_type received by IH is not legal. It should either be 2'b00 or 2'b01", $time);

assert_retry_legal      : assert property (p_retry_legal) 
          else $error("%m @ %t Retry received by IH is not legal. Retry should come only if there is either rd_valid or wr_valid going to TE", $time);

assert_free_rd_entry_only_if_allocated   : assert property (p_free_rd_entry_only_if_allocated) 
          else $error("%m @ %t Read entry was free'ed without being allocated", $time);

assert_free_wr_entry_only_if_allocated   : assert property (p_free_wr_entry_only_if_allocated) 
          else $error("%m @ %t Write entry was free'ed without being allocated", $time);





assert_hpr_cmd_valid_if_credit_avail  : assert property (p_hpr_cmd_valid_if_credit_avail)
          else $error("%m @ %t HPR cmd_valid asserted when no HPR credits available", $time);



assert_no_cmd_first_clk_after_reset  : assert property (p_no_cmd_first_clk_after_reset)
          else $error("%m @ %t hif_cmd_valid came in first clock after reset", $time);






//--------------------------------------------------
//----------     COVERGAE      ---------------------
//--------------------------------------------------

//--------------------------------------------------
// rd_cmd_valid scenario
//--------------------------------------------------
cover_rd_cmd_valid  : cover property (@(posedge co_ih_clk) disable iff (~core_ddrc_rstn)
        (hif_cmd_valid && (hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD)));

//--------------------------------------------------
//---- Making sure that credits are being issued
//--------------------------------------------------
cover_wr_credit  : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn) hif_wr_credit);
cover_lpr_credit : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn) hif_lpr_credit);
cover_hpr_credit : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn) hif_hpr_credit);


//--------------------------------------------------
// check for credit being issued 2 clocks after receiving free entry (in-order)
//--------------------------------------------------

cover_in_order_wr_free_credit_2clks : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                        (mr_ih_free_wr_entry_valid && (mr_ih_free_wr_entry <= {WRCMD_ENTRY_BITS{1'b1}}) &&
                                           (mr_ih_free_wr_entry == wr_oldest_radd)) ##2 hif_wr_credit);

cover_in_order_lpr_free_credit_2clks : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                        (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry <= dh_ih_lpr_num_entries) &&
                                           (te_ih_free_rd_entry == ih_te_lo_rd_prefer) ##2 hif_lpr_credit[0]));

cover_in_order_hpr_free_credit_2clks : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                        (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry > dh_ih_lpr_num_entries) &&
                                           (te_ih_free_rd_entry == ih_te_hi_rd_prefer) ##2 hif_hpr_credit[0]));


//--------------------------------------------------
// check for out of order free - if the free entry is not for the oldest entry, then no credit should be issued
// after 2 clocks
// FIXME: Is this true? Can credits from previous free's come during this period?
//--------------------------------------------------

/*
cover_out_of_order_wr_free_no_credit_NEG : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                          (mr_ih_free_wr_entry_valid && (mr_ih_free_wr_entry < {WRCMD_ENTRY_BITS{1'b1}}) &&
                                          (mr_ih_free_wr_entry != wr_oldest_radd)) ##0 (!hif_wr_credit[*2]));

cover_out_of_order_lpr_free_no_credit_NEG : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                           (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry < dh_ih_lpr_num_entries) &&
                                           (te_ih_free_rd_entry != ih_te_lo_rd_prefer) ##0 (!hif_lpr_credit[*2])));


`ifndef MEMC_NO_PRIORITY
cover_out_of_order_hpr_free_no_credit_NEG : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                           (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry > dh_ih_lpr_num_entries) &&
                                           (te_ih_free_rd_entry != ih_te_hi_rd_prefer) ##0 (!hif_hpr_credit[*2])));
`endif

*/

//--------------------------------------------------
// checking for a case where retry is on for 10 clocks
//--------------------------------------------------
cover_rd_valid_with_retry : cover property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                           ((hif_cmd_valid && (hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD) && !hif_cmd_stall) ##1
                            (ih_te_rd_valid && other_retry)[*10] ##1 (ih_te_rd_valid && !other_retry)));

//--------------------------------------------------
//----------     ASSERTIONS    ---------------------
//--------------------------------------------------

//--------------------------------------------------
// checking for a bad case of cmd_valid - if stall & cmd_valid are high, next clock cmd_valid & stall cannot be low
// valid is driven low when there is stall if PA is present
//--------------------------------------------------


//*********************************
//   IH_TE_WR_VALID
//*********************************

//------------------------------------
// wr request from core results in a write command to TE in the next clock
// Same as above, but retry is checked in the clock in which the command came in also
// This is to make sure that we are checking for case where there are no commands stored in IH input fifo
// New assertions have to written to cover cases where commands are stored in IH input fifo
//------------------------------------
assert_wr_valid_with_no_retry : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                   ((hif_cmd_valid && (hif_cmd_type == `MEMC_CMD_TYPE_BLK_WR) && !hif_cmd_stall && !te_ih_core_in_stall && !wu_ih_flow_cntrl_req) ##1 
                                   (!te_ih_core_in_stall && !wu_ih_flow_cntrl_req)) |->
                                   (ih_te_wr_valid && !ih_te_rd_valid));


// Auxillary code for wr_valid
reg     [3:0]   wr_req_counter;
wire            wr_req_incr;
wire            wr_req_decr;

assign  wr_req_incr = hif_cmd_valid && (hif_cmd_type == `MEMC_CMD_TYPE_BLK_WR) && !hif_cmd_stall;

assign  wr_req_decr = ih_te_wr_valid && !ih_te_rd_valid && !te_ih_retry_i;
                       
always @ (posedge co_ih_clk) begin
   if(!core_ddrc_rstn) begin
     wr_req_counter <= 0;
   end
   else begin
      case({wr_req_decr,wr_req_incr})
        2'b00 : wr_req_counter <= wr_req_counter; 
        2'b01 : wr_req_counter <= wr_req_counter + 1'b1;
        2'b10 : wr_req_counter <= wr_req_counter - 1'b1;
        2'b11 : wr_req_counter <= wr_req_counter;
      endcase
   end
end


//------------------------------------
// wr_valid to TE accounted for
//------------------------------------
assert_wr_valid_accounted : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn) 
          (ih_te_wr_valid && !ih_te_rd_valid && !te_ih_retry_i) |-> 
          (wr_req_counter> 0));


//------------------------------------
// Entry N cannot be granted unless N has been freed
//------------------------------------

property p_wr_entry_N_legal;
        @(posedge co_ih_clk) disable iff (~core_ddrc_rstn)
              (ih_te_wr_valid) |-> ~wr_entry_in_te[ih_te_wr_entry];
//[RUI] Why not add te_ih_retry as pre-condition???, such as below
// Inline ECC has the assertion failure, suggest changed as belwo.
//              (ih_te_wr_valid && ~te_ih_retry) |-> ~wr_entry_in_te[ih_te_wr_entry];
endproperty

assert_wr_entry_N_legal: assert property (p_wr_entry_N_legal);




//*********************************
//   IH_TE_RD_VALID
//*********************************

/////////////
// Auxillary code for rd_valid
/////////////
reg     [3:0]   rd_req_counter;
wire            rd_req_incr;
wire            rd_req_decr;

assign  rd_req_incr = hif_cmd_valid && (hif_cmd_type == `MEMC_CMD_TYPE_BLK_RD) && !hif_cmd_stall;

assign  rd_req_decr = ih_te_rd_valid && !ih_te_wr_valid && !te_ih_retry_i;

always @ (posedge co_ih_clk) begin
   if(!core_ddrc_rstn) begin
     rd_req_counter <= 0;
   end
   else begin
      case({rd_req_decr,rd_req_incr})
        2'b00 : rd_req_counter <= rd_req_counter;
        2'b01 : rd_req_counter <= rd_req_counter + 1'b1;
        2'b10 : rd_req_counter <= rd_req_counter - 1'b1;
        2'b11 : rd_req_counter <= rd_req_counter;
      endcase
   end
end


//------------------------------------
// rd_valid to TE accounted for
//------------------------------------
assert_rd_valid_accounted : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
               (ih_te_rd_valid && !ih_te_wr_valid && !te_ih_retry_i ) 
               |-> 
                    (rd_req_counter> 0));
                        

/////////////
// Auxillary code for RMW
/////////////
reg     [3:0]   rmw_req_counter;
wire            rmw_req_incr;
wire            rmw_req_decr;


assign  rmw_req_incr = hif_cmd_valid 
                            && (hif_cmd_type == `MEMC_CMD_TYPE_RMW)
                            && !hif_cmd_stall;

assign  rmw_req_decr = ih_te_rd_valid && ih_te_wr_valid && !te_ih_retry_i && ih_te_rmwtype!=2'b11;

always @ (posedge co_ih_clk) begin
   if(!core_ddrc_rstn) begin
     rmw_req_counter <= 0;
   end
   else begin
      case({rmw_req_decr,rmw_req_incr})
        2'b00 : rmw_req_counter <= rmw_req_counter;
        2'b01 : rmw_req_counter <= rmw_req_counter + 1'b1;
        2'b10 : rmw_req_counter <= rmw_req_counter - 1'b1;
        2'b11 : rmw_req_counter <= rmw_req_counter;
      endcase
   end
end


//------------------------------------
// rmw_valid to TE accounted for
//------------------------------------
assert_rmw_valid_accounted : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
               (ih_te_rd_valid && ih_te_wr_valid && !te_ih_retry_i && (ih_te_rmwtype!=2'b11)) |-> 
                    (rmw_req_counter> 0));


//------------------------------------
// Entry N cannot be granted unless N has been freed
//------------------------------------

property p_rd_entry_N_legal;
        @(posedge co_ih_clk) disable iff (~core_ddrc_rstn)
              (ih_te_rd_valid) |-> ~rd_entry_in_te[ih_te_rd_entry];
endproperty

assert_rd_entry_N_legal: assert property (p_rd_entry_N_legal);

//*********************************
//   IH_TE_RMW_TYPE
//*********************************


assert_rmw_type_other : assert property (@ (posedge co_ih_clk)  disable iff (~core_ddrc_rstn)
                                (ih_te_rd_valid ^ ih_te_wr_valid)|-> (ih_te_rmwtype == 2'b11));





//*********************************
//   IH_TE_BLOCK_RD
//*********************************


//*********************************
// Check for ih_te_rank
// Check for ih_te_bankgroup
// Check for ih_te_bank
// Check for ih_te_page
// Check for ih_te_col
// Check for ih_te_dword
//*********************************


//*********************************
//   hif_CREDITS
//*********************************


//------------------------------------
// High level property
// If credits available, then all wr_entries in CAM should not be used
//------------------------------------

//don't check during retry_stage because credit avail is not correct during retry_stage.
property p_wr_cam_oversubscription;
        @(posedge co_ih_clk) disable iff (~core_ddrc_rstn)
        (wr_credits_avail > 0) |-> (wr_entry_in_te != {WR_CAM_DEPTH{1'b1}});
endproperty

assert_wr_cam_oversubscription: assert property (p_wr_cam_oversubscription);


property p_rd_cam_oversubscription;
        @(posedge co_ih_clk) disable iff (~core_ddrc_rstn)
        ((lpr_credits_avail > 0) || (hpr_credits_avail > 0))  |-> (rd_entry_in_te != {RD_CAM_DEPTH{1'b1}});
endproperty

assert_rd_cam_oversubscription: assert property (p_rd_cam_oversubscription);



//------------------------------------
// if free entry match prefer, then credit issued exactly in the second clock after free arrived
//------------------------------------

assert_in_order_wr_free_credit_2clks : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                        (mr_ih_free_wr_entry_valid && (mr_ih_free_wr_entry <= {WRCMD_ENTRY_BITS{1'b1}}) &&
                                           (mr_ih_free_wr_entry == wr_oldest_radd)) |-> ##2 hif_wr_credit);

assert_in_order_lpr_free_credit_2clks : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                        (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry <= dh_ih_lpr_num_entries) &&
                                           (te_ih_free_rd_entry == ih_te_lo_rd_prefer) |-> ##2 hif_lpr_credit[0]));

assert_in_order_hpr_free_credit_2clks : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                        (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry > dh_ih_lpr_num_entries) &&
                                           (te_ih_free_rd_entry == ih_te_hi_rd_prefer) |-> ##2 hif_hpr_credit[0]));



//------------------------------------
// if free entry is received for scrubs, no credit is issued to the core
// TRIGGER WILL FAIL UNTIL SCRUBS ARE TURNED ON
// FIXME: Is this true? Can the credits os previous free entry request come in the cycles given below?
//------------------------------------


//------------------------------------
// if free entry doesn't match prefer, then no credits issued during the next 2 clocks
// FIXME: This is put as NEG because, I'm not sure if credits due to previous free's can interfere
// YES, CREDITS DUE TO PREVIOUS REQUESTS CAN INTERFERE - looks at the failed example waveform
//------------------------------------

/*

assert_out_of_order_wr_free_no_credit_NEG : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                                (mr_ih_free_wr_entry_valid && (mr_ih_free_wr_entry < {WRCMD_ENTRY_BITS{1'b1}}) &&
                                                    (mr_ih_free_wr_entry != wr_oldest_radd)) |-> (!hif_wr_credit[*2]));

assert_out_of_order_lpr_free_no_credit_NEG : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                                (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry < dh_ih_lpr_num_entries) &&
                                                   (te_ih_free_rd_entry != ih_te_lo_rd_prefer) |-> (!hif_lpr_credit[*2])));


`ifndef MEMC_NO_PRIORITY
assert_out_of_order_hpr_free_no_credit_NEG : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                                (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry > dh_ih_lpr_num_entries) &&
                                                  (te_ih_free_rd_entry != ih_te_hi_rd_prefer) |-> (!hif_hpr_credit[*2])));
`endif  // NO_PRIORITY

*/

//------------------------------------
// If N out of order free, followed by 1 in-order free, expect N+1 credits
// This is an example for 2 out of order, followed by an in-order, causing 3 credits to be issued (LPR)
//------------------------------------

/*

assert_out_of_order_lpr_free_credit_expect : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
                                                ((te_ih_free_rd_entry_valid && (te_ih_free_rd_entry < dh_ih_lpr_num_entries) &&
                                                   (te_ih_free_rd_entry != ih_te_lo_rd_prefer)) ##1 !te_ih_free_rd_entry_valid[*0:$]) [*2] ##1
                                                        (te_ih_free_rd_entry_valid && (te_ih_free_rd_entry < dh_ih_lpr_num_entries) &&
                                                            (te_ih_free_rd_entry == ih_te_lo_rd_prefer)) |-> ##2 hif_lpr_credit[*3]);
*/


//*********************************
//   hif_wdata_PTR_VALID
//*********************************

//------------------------------------
// FIXME: give a decription for the assertion
//------------------------------------

// note use of hif_cmd_stall_orig, not hif_cmd_stall
// This was original hif_cmd_stall before ability to stall core interface
// for Self Refresh was introduced
// safe to change it as hif_wdata_ptr_valid is not actually related to
// hif_cmd_stall, but was using info in hif_cmd_stall to know if ok
//assert_corrupt_wdata_ptr_valid  : assert property (@ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
//            hif_wdata_ptr_valid |-> (~hif_cmd_stall_orig && ~($past(te_ih_retry)) && $past(ih_te_wr_valid)))
//           else $error ("%m @ %t wdata_ptr_valid from IH to Core is corrupt.", $time);



endmodule
`endif // `ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON
