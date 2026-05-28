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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_te_if.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// -------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ih_te_if(
        bg_b16_addr_mode,

        // from core_if
        rxcmd_valid,
        rxcmd_type,
        rxcmd_token,
        rxcmd_autopre,
        rxcmd_pri,
        rxcmd_length,
        rxcmd_invalid_addr,

        // Address from address_map module
        am_bg_bank,
        am_row,
        am_block,
        am_critical_dword,


        // outputs for TE
        ih_te_rd_valid,
        ih_te_wr_valid,
        ih_wu_wr_valid,
        ih_te_rd_valid_addr_err,
        ih_te_wr_valid_addr_err,
        ih_te_rd_length,
        ih_te_rd_tag,
        ih_te_rmwtype,

        ih_te_hi_pri,
        ih_te_hi_pri_int,
        ih_te_autopre,
        ih_te_bankgroup_num,
        ih_te_bg_bank_num,
        ih_te_bank_num,
        ih_te_page_num,
        ih_te_block_num,
        ih_te_critical_dword,
        ih_wu_critical_dword
);

//------------------------------ PARAMETERS ------------------------------------

parameter       IH_TAG_WIDTH    = `MEMC_TAGBITS;                // width of token/tag field from core
parameter       CMD_LEN_BITS    = 1;                            // bits for command length, when used
parameter       RMW_TYPE_BITS   = 2;                            // 2 bits for RMW type
                                                                //  (partial write, scrub, or none)
parameter       CMD_TYPE_BITS   = 2;                            // any change will require RTL modifications in IC
// 2-bit command type encodings
localparam CMD_TYPE_BLK_WR   = `MEMC_CMD_TYPE_BLK_WR;
localparam CMD_TYPE_BLK_RD   = `MEMC_CMD_TYPE_BLK_RD;
localparam CMD_TYPE_RMW      = `MEMC_CMD_TYPE_RMW;
localparam CMD_TYPE_RESERVED = `MEMC_CMD_TYPE_RESERVED;

// 2-bit RMW type encodings
localparam RMW_TYPE_PARTIAL_NBW = `MEMC_RMW_TYPE_PARTIAL_NBW;
localparam RMW_TYPE_RMW_CMD     = `MEMC_RMW_TYPE_RMW_CMD;
localparam RMW_TYPE_SCRUB       = `MEMC_RMW_TYPE_SCRUB;
localparam RMW_TYPE_NO_RMW      = `MEMC_RMW_TYPE_NO_RMW;

// 2-bit read priority encoding
localparam CMD_PRI_LPR    = `MEMC_CMD_PRI_LPR;
localparam CMD_PRI_VPR    = `MEMC_CMD_PRI_VPR;
localparam CMD_PRI_HPR    = `MEMC_CMD_PRI_HPR;
localparam CMD_PRI_XVPR   = `MEMC_CMD_PRI_XVPR;




input                                   bg_b16_addr_mode;

input                                   rxcmd_valid;
input  [CMD_TYPE_BITS-1:0]              rxcmd_type;
input  [IH_TAG_WIDTH-1:0]               rxcmd_token;
input                                   rxcmd_autopre;
input  [1:0]                            rxcmd_pri;
input  [CMD_LEN_BITS-1:0]               rxcmd_length;
input                                   rxcmd_invalid_addr;

input [`MEMC_WORD_BITS-1:0]             am_critical_dword;
input [`MEMC_BLK_BITS-1:0]              am_block;
input [`MEMC_PAGE_BITS-1:0]             am_row;
input [`MEMC_BG_BANK_BITS-1:0]          am_bg_bank;


output                                  ih_te_rd_valid;
output                                  ih_te_wr_valid;
output                                  ih_wu_wr_valid;
output                                  ih_te_rd_valid_addr_err;    // High when detected RD/RMW with invalid address
output                                  ih_te_wr_valid_addr_err;    // High when detected WR/RMW with invalid address
output  [CMD_LEN_BITS-1:0]              ih_te_rd_length;
output  [IH_TAG_WIDTH-1:0]              ih_te_rd_tag;
output  [RMW_TYPE_BITS-1:0]             ih_te_rmwtype;
output  [1:0]                           ih_te_hi_pri;
output  [1:0]                           ih_te_hi_pri_int;
output                                  ih_te_autopre;


output  [`MEMC_BG_BITS-1:0]             ih_te_bankgroup_num;
output  [`MEMC_BG_BANK_BITS -1:0]       ih_te_bg_bank_num;
output  [`MEMC_BANK_BITS -1:0]          ih_te_bank_num;
output  [`MEMC_PAGE_BITS -1:0]          ih_te_page_num;
output  [`MEMC_BLK_BITS -1:0]           ih_te_block_num;
output  [`MEMC_WORD_BITS-1:0]           ih_te_critical_dword; 
output  [`MEMC_WORD_BITS-1:0]           ih_wu_critical_dword; 

wire                                    ih_te_rd_valid;
wire                                    ih_te_wr_valid;
wire                                    ih_wu_wr_valid;
wire                                    ih_te_rd_valid_addr_err;
wire                                    ih_te_wr_valid_addr_err;
wire    [CMD_LEN_BITS-1:0]              ih_te_rd_length;
wire    [IH_TAG_WIDTH-1:0]              ih_te_rd_tag;
wire    [RMW_TYPE_BITS-1:0]             ih_te_rmwtype;
wire    [1:0]                           ih_te_hi_pri;
wire    [1:0]                           ih_te_hi_pri_int;

wire                                    ih_te_autopre;

wire    [`MEMC_BG_BITS-1:0]             ih_te_bankgroup_num;
wire  [`MEMC_BG_BANK_BITS -1:0]         ih_te_bg_bank_num;
wire  [`MEMC_BANK_BITS -1:0]            ih_te_bank_num;
wire  [`MEMC_PAGE_BITS -1:0]            ih_te_page_num;
wire  [`MEMC_BLK_BITS -1:0]             ih_te_block_num;
wire  [`MEMC_WORD_BITS-1:0]             ih_te_critical_dword; 
wire  [`MEMC_WORD_BITS-1:0]             ih_wu_critical_dword; 





wire    [CMD_LEN_BITS-1:0]              rd_length_core;

wire  [`MEMC_WORD_BITS-1:0]             am_critical_dword_rmw;
wire  [CMD_LEN_BITS-1:0]                rxcmd_length_rmw;


// rd_length value
// if cmd_type is READ, then rd_length = 0, when length=0 and rd_length != 0, when length !=0
// if cmd_type is RMW, then rd_length = 0 irrespective of the length field
assign  rxcmd_length_rmw  = {CMD_LEN_BITS{1'b0}};

assign  rd_length_core   = (rxcmd_valid && (((rxcmd_type == CMD_TYPE_BLK_RD) && (rxcmd_length == {CMD_LEN_BITS{1'b0}}))
                                                || (rxcmd_type == CMD_TYPE_RMW)
                        )) ? rxcmd_length_rmw : rxcmd_length;



// Assert ih_te_rd_valid_addr_err for every ih_te_rd_valid with invalid address
// For INLINE ECC configration, ie_cmd_active has higher priority than rxcmd_valid,
// if ie_cmd_active=1, don't generate valid_addr_err.(for example, the current rxcmd_valid is invalid address, but at this monment IE is inject ECC command for previous valid address)
// addl, No overhead ECC command for invalid address.
// In inline ECC mode, access ecc_region_* with ecc_region_*_lock=1 that will cuase invalid address error
wire invalid_addr;
assign invalid_addr             = 
                                   rxcmd_invalid_addr ||
                                1'b0;
assign ih_te_rd_valid_addr_err  = 
                                  (rxcmd_valid && invalid_addr &&
                                  ((rxcmd_type == CMD_TYPE_BLK_RD)
                                  || (rxcmd_type == CMD_TYPE_RMW)
                                  ));

// Assert ih_te_wr_valid_addr_err for every ih_te_wr_valid with invalid address
assign ih_te_wr_valid_addr_err  = 
                                  (rxcmd_valid && invalid_addr &&
                                  ((rxcmd_type == CMD_TYPE_BLK_WR)
                                  || (rxcmd_type == CMD_TYPE_RMW)
                                  ));


wire wr_valid_rxcmd;
wire rd_valid_rxcmd;

// Assert rd_valid to TE when
// cmd_type is READ or RMW and there is no flow control from WU
// OR When SCRUB is on
assign  rd_valid_rxcmd          = (rxcmd_valid && 
                                  ((rxcmd_type == CMD_TYPE_BLK_RD)
                                  || (rxcmd_type == CMD_TYPE_RMW)
                                  ))
                                  ;

assign  ih_te_rd_valid  = 
                           rd_valid_rxcmd;



// Assert wr_valid to TE when
// cmd_type is WRITE or RMW and there is no flow control from WU
// OR When SCRUB is on
assign  wr_valid_rxcmd          = (rxcmd_valid &&
                                  ((rxcmd_type == CMD_TYPE_BLK_WR)
                                  || (rxcmd_type == CMD_TYPE_RMW)
                                  ))
                                  ;

assign  ih_te_wr_valid  = 
                           wr_valid_rxcmd;


// Don't tell Inline ECC overhead command to WU.
// MR will give wr_valid when a block end.
assign  ih_wu_wr_valid  = 
                           wr_valid_rxcmd;


assign  ih_te_rd_length         = 
                                  rxcmd_valid   ? rd_length_core  : {CMD_LEN_BITS{1'b0}};

assign  ih_te_rd_tag         = 
                                  rxcmd_valid   ? 
                                                   rxcmd_token  : {IH_TAG_WIDTH{1'b0}};
                                  
// If the incoming cmd_type is RMW, then set to PARTIAL_NBW,
// if no cmd, set to scrub
// else keep it at NO_RMW
// MEMC_RMW_TYPE_RMW_CMD is not supported for now
assign  ih_te_rmwtype   =                                    (rxcmd_valid && (rxcmd_type == CMD_TYPE_RMW)) ? RMW_TYPE_PARTIAL_NBW :
                                RMW_TYPE_NO_RMW;


assign  ih_te_bg_bank_num =
                          am_bg_bank;

assign  ih_te_page_num =
                          am_row;                          

assign  ih_te_block_num =
                          am_block;  
  


assign  ih_te_bankgroup_num = bg_b16_addr_mode ? ih_te_bg_bank_num[`MEMC_BG_BITS-1:0] : {`MEMC_BG_BITS{1'b0}};

assign  ih_te_bank_num      =                                     bg_b16_addr_mode ? ih_te_bg_bank_num[`MEMC_BG_BANK_BITS-1:`MEMC_BG_BITS] : 
                                     ih_te_bg_bank_num[`MEMC_BANK_BITS-1:0];

// send the critical word from the address mapper to TE when rxcmd_valid is present, else keep it 0
// the exception is RMW commands. when cmd_type is RMW, critical_word is forced to 0
// critical_word going to TE is used only during reads in the controller.
// during writes, the critical_word sent to WU will make the data to be correctly aligned.
//
// Inline ECC enabled in MEMC_BURST_LENGTH_16, 
//   if burst_rdwr=4'b0100 and HBW, read of RMW is quarter read, the critical_word could be 0,4,8,c to indicate which quater.
//   if burst_rdwr=4'b0100 or HBW, read of RMW is half read, the critical_word could be 0 or 8 to indicate which half.
//   otherwise, it is full read. (assume it is BL16 and FBW, don't support QBW)
assign  am_critical_dword_rmw  = {`MEMC_WORD_BITS{1'b0}};

assign  ih_te_critical_dword    = 
                                    (rxcmd_valid 
                                    && (rxcmd_type != CMD_TYPE_RMW)
                                    ) ? am_critical_dword : 
                                      am_critical_dword_rmw;



// send the critical word from the address mapper to TE when rxcmd_valid is present, else keep it 0
// this is needed even during RMW
assign  ih_wu_critical_dword    = 
                                 rxcmd_valid ? am_critical_dword : {`MEMC_WORD_BITS{1'b0}};



// this is the priority going out to TE. this is used by the global scheduler.
// the value of this priority is based on the incoming priroity as well as the register value
// CMD_PRI_LPR is used in the logic below, but it applies for Write priority as well.
// Since both LP Read and Write use the same encoding, it is ok to use it this way
assign  ih_te_hi_pri            = 
                                  rxcmd_valid ? rxcmd_pri : CMD_PRI_LPR;

// this is the priority used for credit mechanism. this is the real priority that came in.
assign  ih_te_hi_pri_int        = 
                                  rxcmd_valid ? rxcmd_pri : CMD_PRI_LPR;

assign ih_te_autopre            = rxcmd_valid && rxcmd_autopre;






`ifdef SNPS_ASSERT_ON


`endif // SNPS_ASSERT_ON



endmodule

