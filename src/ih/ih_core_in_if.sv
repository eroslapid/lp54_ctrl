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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_core_in_if.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This is the input interface module of IH. The signals from the DDRC are flopped
// in this module. The flopped input signals get stored in a 2-deep input fifo. 
// The full from this fifo is used to generate the stall signal in ih_core_out_if.v 
// module. There are 3 flavors of the input fifo based on the timing requirement.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ih_core_in_if(
  co_ih_clk,
  core_ddrc_rstn,
  hif_cmd_valid,
  hif_cmd_type,
  hif_cmd_addr,
  hif_cmd_token,
  hif_cmd_pri,
  hif_cmd_length,
  hif_cmd_wdata_ptr,
  hif_cmd_autopre,
  input_fifo_full,
  input_fifo_empty,
  ih_in_busy,
  ih_fifo_wr_empty,
  ih_fifo_rd_empty,
  hif_cmd_stall,
  te_ih_retry,
  wu_ih_flow_cntrl_req,
  reg_ddrc_ecc_type,

  rxcmd_valid,
  rxcmd_addr,
  rxcmd_addr_dup,
  rxcmd_type,
  rxcmd_token,

  rxcmd_pri,
  rxcmd_length,
  rxcmd_autopre,
  rxcmd_wdata_ptr);


//------------------------------ PARAMETERS ------------------------------------
parameter  ECCAP_DATA_BITS   = (`MEMC_ECCAP_EN & `MEMC_OPT_TIMING_EN)? 1 : 0;
parameter  IE_FIFO_DATA_BITS = `MEMC_INLINE_ECC_EN ? 10 : 0;


parameter  WRCMD_ENTRY_BITS= `MEMC_WRCMD_ENTRY_BITS;  // bits to address all entries in write CAM
parameter  CORE_ADDR_WIDTH = 35;                      // any change may necessitate a change to address map in IC
parameter  IH_TAG_WIDTH    = `MEMC_TAGBITS;           // width of token/tag field from core
parameter  CMD_LEN_BITS    = 1;                       // bits for command length, when used
                                                           //  (partial write, scrub, or none)
parameter  WDATA_PTR_BITS  = `MEMC_WDATA_PTR_BITS;

parameter  REFRESH_EN_BITS = `MEMC_NUM_RANKS;

parameter  CMD_TYPE_BITS   = 2;                       // any change will require RTL modifications in IC
localparam WRDATA_ENTRY_BITS= WRCMD_ENTRY_BITS + 1;   // write data RAM entries
                                                           // (only support 2 datas per command at the moment)

parameter       WDATA_MASK_FULL_BITS = `MEMC_WRDATA_CYCLES;

// 2-bit command type encodings
localparam CMD_TYPE_BLK_WR   = `MEMC_CMD_TYPE_BLK_WR;
localparam CMD_TYPE_BLK_RD   = `MEMC_CMD_TYPE_BLK_RD;
localparam CMD_TYPE_RMW      = `MEMC_CMD_TYPE_RMW;
localparam CMD_TYPE_RESERVED = `MEMC_CMD_TYPE_RESERVED;

// 2-bit read priority encoding
localparam CMD_PRI_LPR       = `MEMC_CMD_PRI_LPR;
localparam CMD_PRI_VPR       = `MEMC_CMD_PRI_VPR;
localparam CMD_PRI_HPR       = `MEMC_CMD_PRI_HPR;
localparam CMD_PRI_XVPR      = `MEMC_CMD_PRI_XVPR;

// 2-bit write priority encoding
localparam CMD_PRI_NPW       = `MEMC_CMD_PRI_NPW;
localparam CMD_PRI_VPW       = `MEMC_CMD_PRI_VPW;
localparam CMD_PRI_RSVD      = `MEMC_CMD_PRI_RSVD;
localparam CMD_PRI_XVPW      = `MEMC_CMD_PRI_XVPW;


//------------------------------ PARAMETERS ------------------------------------


input                           co_ih_clk;              // clock
input                           core_ddrc_rstn;         // reset

input                           hif_cmd_valid;          // valid command
input   [CMD_TYPE_BITS-1:0]     hif_cmd_type;           // command type:
                                                        //  00 - block write
                                                        //  01 - read
                                                        //  10 - rmw
                                                        //  11 - reserved
input   [CORE_ADDR_WIDTH-1:0]   hif_cmd_addr;           // address
input   [IH_TAG_WIDTH-1:0]      hif_cmd_token;          // read token returned w/ read data
input   [1:0]                   hif_cmd_pri;            // priority:
                                                        //  00 - low priority, 01 - VPR
                                                        //  10 - high priority, 11 - unused
                                                        // For writes: 00 - NPW, 01 - VPW, 10, 11 - reserved
input   [CMD_LEN_BITS-1:0]      hif_cmd_length;         // length (1 word or 2)
                                                        //  1 - 1 word
                                                        //  0 - 2 words
input   [WDATA_PTR_BITS-1:0]    hif_cmd_wdata_ptr;      // 
input                           hif_cmd_autopre;        // auto precharge enable
output                          input_fifo_full;        // indication that input fifo is full - used to generate stall
output                          input_fifo_empty;       // indication that input fifo is empty
output                          ih_in_busy;             // stays high when any cmd comes into the controller and the FIFOs are non-empty
                                                        // combinational signal generated from the input cmd valid signal (hif_cmd_valid)


input                           hif_cmd_stall;          // Stall from IH to Core


input                           te_ih_retry;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in !MEMC_IH_TE_PIPELINE configs only, but input should always exist
input                           wu_ih_flow_cntrl_req;   // indication that wu_wdata_if fifo is full
                                                        // all the commands in the fifo are waiting for data_valid
input                           reg_ddrc_ecc_type; 
//spyglass enable_block W240

output                          rxcmd_valid;
output  [CORE_ADDR_WIDTH-1:0]   rxcmd_addr;
output  [CMD_TYPE_BITS-1:0]     rxcmd_type;
output  [IH_TAG_WIDTH-1:0]      rxcmd_token;
output  [1:0]                   rxcmd_pri;
output                          rxcmd_autopre;
output  [CMD_LEN_BITS-1:0]      rxcmd_length;
output  [WDATA_PTR_BITS-1:0]    rxcmd_wdata_ptr;
output  [CORE_ADDR_WIDTH-1:0]   rxcmd_addr_dup;

output                          ih_fifo_wr_empty;
output                          ih_fifo_rd_empty;

wire                            ih_fifo_wr_empty;
wire                            ih_fifo_rd_empty;

localparam  AUTOPRE_FIELD               = 0;
localparam  ADDR_FIELD_LSB              = 1;
localparam  ADDR_FIELD_MSB              = ADDR_FIELD_LSB            + CORE_ADDR_WIDTH      - 1;
localparam  TYPE_FIELD_LSB              = ADDR_FIELD_MSB            + 1;
localparam  TYPE_FIELD_MSB              = TYPE_FIELD_LSB            + CMD_TYPE_BITS        - 1;
localparam  TOKEN_FIELD_LSB             = TYPE_FIELD_MSB            + 1;
localparam  TOKEN_FIELD_MSB             = TOKEN_FIELD_LSB           + IH_TAG_WIDTH         - 1;
localparam  PRI_FIELD_LSB               = TOKEN_FIELD_MSB           + 1;
localparam  PRI_FIELD_MSB               = PRI_FIELD_LSB             + 2                    - 1; // 2-bit priority field
localparam  LEN_FIELD_LSB               = PRI_FIELD_MSB             + 1;
localparam  LEN_FIELD_MSB               = LEN_FIELD_LSB             + CMD_LEN_BITS         - 1;
localparam  WDATA_PTR_FIELD_LSB         = LEN_FIELD_MSB             + 1;
localparam  WDATA_PTR_FIELD_MSB         = WDATA_PTR_FIELD_LSB       + WDATA_PTR_BITS       - 1;
localparam  ECCAP_FIELD_LSB             = WDATA_PTR_FIELD_MSB       + 1;
localparam  ECCAP_FIELD_MSB             = ECCAP_FIELD_LSB           + ECCAP_DATA_BITS      - 1;
localparam  IE_FIELD_LSB                = ECCAP_FIELD_MSB           + 1;
localparam  IE_FIELD_MSB                = IE_FIELD_LSB              + IE_FIFO_DATA_BITS    - 1;
localparam  REFRESH_EN_FIELD_LSB        = IE_FIELD_MSB              + 1;
localparam  REFRESH_EN_FIELD_MSB        = REFRESH_EN_FIELD_LSB      + REFRESH_EN_BITS      - 1;
localparam  WDATA_MASK_FULL_FIELD_LSB   = REFRESH_EN_FIELD_MSB      + 1;
localparam  WDATA_MASK_FULL_FIELD_MSB   = WDATA_MASK_FULL_FIELD_LSB + WDATA_MASK_FULL_BITS - 1;
localparam  INPUT_FIFO_WIDTH            = WDATA_MASK_FULL_FIELD_MSB + 1;


wire                          input_fifo_put;
wire                          input_fifo_get;
wire  [INPUT_FIFO_WIDTH-1:0]  input_fifo_din;
wire  [INPUT_FIFO_WIDTH-1:0]  input_fifo_dout;

wire  [CORE_ADDR_WIDTH:0]     input_fifo_dup_dout;

wire                          ih_in_busy;

wire                          input_fifo_full;
wire                          input_fifo_empty;

wire                          rxcmd_valid;

wire  [CORE_ADDR_WIDTH-1:0]   rxcmd_addr;
wire  [CMD_TYPE_BITS-1:0]     rxcmd_type;
wire  [IH_TAG_WIDTH-1:0]      rxcmd_token;
wire  [1:0]                   rxcmd_pri;
wire                          rxcmd_autopre;
wire  [CMD_LEN_BITS-1:0]      rxcmd_length;
wire  [WDATA_PTR_BITS-1:0]    rxcmd_wdata_ptr;

wire  [CORE_ADDR_WIDTH-1:0]   rxcmd_addr_dup;

wire                          i_hif_cmd_valid;

// IH Input module is busy when there is an input command or when the Input FIFO is not empty
assign  i_hif_cmd_valid = hif_cmd_valid && (~hif_cmd_stall);
assign  ih_in_busy      = i_hif_cmd_valid || (~input_fifo_empty);

assign  input_fifo_put  = i_hif_cmd_valid;
//if MEMC_IH_TE_PIPELINE enabled, wu_ih_flow_cntrl_req will be used to stall command at output of ih_te_pipeline for IE case instead
// unused here in IE case
assign  input_fifo_get  = (!te_ih_retry) 
                                           && (!wu_ih_flow_cntrl_req) 
                                         ;

assign  input_fifo_din  = {
                            hif_cmd_wdata_ptr,hif_cmd_length,hif_cmd_pri,
                            hif_cmd_token,hif_cmd_type,hif_cmd_addr,hif_cmd_autopre};

//if MEMC_IH_TE_PIPELINE enabled, wu_ih_flow_cntrl_req will be used to stall command at output of ih_te_pipeline for IE case instead
// unused here in IE case
assign  rxcmd_valid = (!input_fifo_empty) 
                                           && (!wu_ih_flow_cntrl_req) 
                                         ;

assign  rxcmd_addr  = input_fifo_dout[ADDR_FIELD_MSB:ADDR_FIELD_LSB];
assign  rxcmd_type  = input_fifo_dout[TYPE_FIELD_MSB:TYPE_FIELD_LSB];
assign  rxcmd_token = input_fifo_dout[TOKEN_FIELD_MSB:TOKEN_FIELD_LSB];
assign  rxcmd_pri   = input_fifo_dout[PRI_FIELD_MSB:PRI_FIELD_LSB];
assign  rxcmd_length    = input_fifo_dout[LEN_FIELD_MSB:LEN_FIELD_LSB];
assign  rxcmd_wdata_ptr = input_fifo_dout[WDATA_PTR_FIELD_MSB:WDATA_PTR_FIELD_LSB];
assign  rxcmd_autopre   = input_fifo_dout[AUTOPRE_FIELD];

assign  rxcmd_addr_dup  = input_fifo_dup_dout[ADDR_FIELD_MSB:ADDR_FIELD_LSB];


//-----------------------------------------
// Logic for generating the separate Write and Read FIFO empty signals
//-----------------------------------------

// The width of 2-bits has an assumption that the input FIFO will always be 2-deep
reg [1:0] wr_in_fifo, rd_in_fifo;
wire      fifo_get, fifo_put;
wire      wr_put, wr_get;
wire      rd_put, rd_get;

assign fifo_put = input_fifo_put && (~input_fifo_full);
assign fifo_get = input_fifo_get && (~input_fifo_empty);

assign    wr_put = fifo_put && ((hif_cmd_type == CMD_TYPE_BLK_WR) || (hif_cmd_type == CMD_TYPE_RMW));
assign    wr_get = fifo_get && ((rxcmd_type == CMD_TYPE_BLK_WR)       || (rxcmd_type == CMD_TYPE_RMW));

assign    rd_put = fifo_put && ((hif_cmd_type == CMD_TYPE_BLK_RD) || (hif_cmd_type == CMD_TYPE_RMW));
assign    rd_get = fifo_get && ((rxcmd_type == CMD_TYPE_BLK_RD)       || (rxcmd_type == CMD_TYPE_RMW));

// generation of signals that indicate that there is a read or write 
// command in the input FIFO
always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
       wr_in_fifo <= 2'b00;
       rd_in_fifo <= 2'b00;
   end
   else begin

  // generating wr_in_fifo - Increment when WR or RMW command comes in
  // Decrement when WR or RMW command goes out
      if(wr_put & (~wr_get))
             wr_in_fifo <= wr_in_fifo + 2'b01;
      else if(wr_get & (~wr_put))
             wr_in_fifo <= wr_in_fifo - 2'b01;

  // generating rd_in_fifo - Increment when RD or RMW command comes in
  // Decrement when RD or RMW command goes out
      if(rd_put & (~rd_get))
             rd_in_fifo <= rd_in_fifo + 2'b01;
      else if(rd_get & (~rd_put))
             rd_in_fifo <= rd_in_fifo - 2'b01;

   end
end

assign ih_fifo_wr_empty = (wr_in_fifo == 2'b00);
assign ih_fifo_rd_empty = (rd_in_fifo == 2'b00);



//--------------------------------------
// There are 2 versions of input fifo used here
// If MEMC_OPT_TIMING is defined - then *flopout* version with repeated flop is used
// If it is not defined, then sync_fifo_rst is used
//--------------------------------------

// 2-deep input FIFO
ingot_sync_fifo_flopout_rst_rep #( // this version improves internal timing within the controller
                                    // this has a higher gate count, but no latency penalty
                                    // this version also has some of the flops replicated
  .WIDTH                (INPUT_FIFO_WIDTH),
  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression '(CORE_ADDR_WIDTH + 1)' found in module 'ih_core_in_if'
  //SJ: This coding style is acceptable and there is no plan to change it.
  .FLOP_REPLICATE_WIDTH (CORE_ADDR_WIDTH + 1), // this parameter determines how many LSB bits of dout flop
                                               // gets replicated
  //spyglass enable_block SelfDeterminedExpr-ML
  .DEPTH_LOG2 (1))
    
    ih_input_fifo (
        .clk    (co_ih_clk),
        .rstb   (core_ddrc_rstn),
        .put    (input_fifo_put),
        .din    (input_fifo_din),
        .get    (input_fifo_get),
        .dout   (input_fifo_dout),
        .dup_dout  (input_fifo_dup_dout),
        .full   (input_fifo_full),
        .empty  (input_fifo_empty)   );


//-----------------------------------------------------
// Logic for storing and decrementing the rd_latency value for VPR commands
// Assumption in the logic below that the Input FIFO depth is 2
//-----------------------------------------------------




//-----------------------------------------------------
// Logic for storing and decrementing the rd_latency value for VPW commands
// Assumption in the logic below that the Input FIFO depth is 2
//-----------------------------------------------------


`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON


ih_rd_wr_fifo_empty: //---------------------------------------------------------
    assert property ( @ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
         (input_fifo_empty |-> (ih_fifo_wr_empty && ih_fifo_rd_empty))) 
    else $error("[%t][%m] ERROR: ih_fifo_rd_empty OR ih_fifo_wr_empty is showing non-empty when input_fifo_empty is showing empty.", $time);

ih_rd_wr_fifo_non_empty: //---------------------------------------------------------
    assert property ( @ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
         (~input_fifo_empty |-> (~ih_fifo_wr_empty || ~ih_fifo_rd_empty))) 
    else $error("[%t][%m] ERROR: ih_fifo_rd_empty AND ih_fifo_wr_empty are both HIGH when input_fifo_empty is low.", $time);

ih_input_fifo_no_wr_when_full:
    assert property ( @ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
         (fifo_put |-> ~input_fifo_full)) 
    else $error("[%t][%m] ERROR: Write into IH Input FIFO when it is FULL.", $time);

ih_input_fifo_no_rd_when_empty:
    assert property ( @ (posedge co_ih_clk) disable iff (~core_ddrc_rstn)
         (fifo_get |-> ~input_fifo_empty)) 
    else $error("[%t][%m] ERROR: Read from IH Input FIFO when it is Empty.", $time);



`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule
