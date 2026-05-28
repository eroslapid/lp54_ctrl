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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/wu/memc_wu.sv#2 $
// -------------------------------------------------------------------------
// Description:
//
// -------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module memc_wu 
import DWC_ddrctl_reg_pkg::*;
(co_yy_clk, core_ddrc_rstn,
    ddrc_cg_en,
    reg_ddrc_occap_en,
    reg_ddrc_occap_en_r,
    ddrc_occap_wufifo_parity_err,
    ddrc_occap_wuctrl_parity_err,
    dh_wu_lpddr4,
    reg_ddrc_lpddr5,

    co_wu_wdata_valid, 
    co_wu_wdata,
    co_wu_wdata_mask,
    co_wu_wdata_par,

    wu_co_wdata_stall,
    ih_wu_wr_valid,
    ih_wu_wr_valid_addr_err,
    ih_wu_rmw_type, ih_wu_wr_entry_num, ih_wu_critical_word,
    co_wu_data_end,
    te_wu_wr_retry,
    te_wu_wr_combine, te_wu_entry_num,
    mr_wu_free_wr_entry, mr_wu_free_wr_entry_valid,
    reg_ddrc_burst_mode,
    ra_wu_rdata_end,
    rd_wu_rdata_valid, rd_wu_rmw_type,
    rd_wu_wr_ram_addr,
    rd_wu_partial,


    te_wu_ie_flowctrl_req,

 

    mr_wu_raddr, wu_mr_rdata_mask,

    rd_wu_rdata,
    rd_wu_rdata_par,
    wu_ih_flow_cntrl_req,
    wu_fifo_empty,

    wu_te_enable_wr, wu_te_entry_num,
    dh_wu_dm_en,
    wu_te_mwr,
//    reg_ddrc_burst_rdwr,
    wu_te_wr_word_valid,
    reg_ddrc_frequency_ratio,
    reg_ddrc_burst_rdwr,
    wu_te_ram_raddr_lsb_first,
    wu_te_pw_num_beats_m1,
    wu_te_pw_num_cols_m1,

    wu_me_wdata,
    wu_me_wdata_par,
    wu_gs_enable_wr,
    wu_me_wmask,
    wu_me_wvalid, 
    wu_me_waddr
    


    );

//---------------------------- PARAMETERS ---------------------------------------

parameter CMD_LEN_BITS            = 1;
parameter WRCAM_ADDR_WIDTH        = 4;      // bits to address into CAM
parameter HIF_WRDATA_CYCLE_BITS   = 1; // 2-cycles data needs 1 bit
parameter WRDATA_RAM_ADDR_WIDTH   = WRCAM_ADDR_WIDTH + HIF_WRDATA_CYCLE_BITS; // data width to RAM
parameter CORE_DATA_WIDTH         = `MEMC_DFI_DATA_WIDTH; // internal data width
parameter CORE_MASK_WIDTH         = `MEMC_DFI_DATA_WIDTH/8; // data mask width
parameter WRSRAM_DATA_WIDTH       = `MEMC_DFI_DATA_WIDTH;   // WR-SRAM data width
parameter WRSRAM_MASK_WIDTH       = `MEMC_DFI_DATA_WIDTH/8; // WR-SRAM data mask width
parameter WDATA_PAR_WIDTH         = `UMCTL2_WDATARAM_PAR_DW;
parameter WDATA_PAR_WIDTH_EXT     = `UMCTL2_WDATARAM_PAR_DW_EXT;
parameter WORD_BITS               = 2;      // # of bits in critical word
parameter UMCTL2_SEQ_BURST_MODE   = 0;                    // Applies LPDDR4 like squential burst mode only
parameter OCCAP_EN                = 0;
parameter OCCAP_PIPELINE_EN       = 0;
parameter BANK_BITS               = 3;      // bits to address a bank within a rank
parameter ROW_BITS                = 16;      // row (page) address bits
parameter BLK_BITS                = `MEMC_BLK_BITS;       // column address bits - critical word address bits
parameter BG_BITS                 = 2;                    // Bank group bits
parameter BG_BANK_BITS            = 4;                    // bank group and bank bits combined
parameter   CORE_DCERRBITS_PKG        = `MEMC_DCERRBITS*2;

localparam  WRDATA_ENTRIES          = 1 << WRDATA_RAM_ADDR_WIDTH;
localparam  WRCAM_ENTRIES           = 1 << WRCAM_ADDR_WIDTH;
localparam  HIF_WRDATA_CYCLES       = 1 << HIF_WRDATA_CYCLE_BITS;

localparam  NUM_DB_LOG2             = `log2(`MEMC_BURST_LENGTH/(`MEMC_FREQ_RATIO*2));

localparam  MEMC_ECC_SUPPORT       = `MEMC_ECC_SUPPORT;


//--------------------------------------
//  Partial write relevant parameters
//--------------------------------------
parameter   PARTIAL_WR_BITS         = `UMCTL2_PARTIAL_WR_BITS;
localparam  PW_NUM_DB               = PARTIAL_WR_BITS;
localparam  PW_NUM_DB_LOG2          = `log2(PW_NUM_DB);
parameter   PW_WORD_CNT_WD_MAX      = 2;

localparam  PW_FACTOR_FBW           = 1*`MEMC_FREQ_RATIO;
localparam  PW_WORD_VALID_WD_FBW    = PW_NUM_DB*PW_FACTOR_FBW;

localparam  PW_WORD_VALID_WD_MAX    = PW_WORD_VALID_WD_FBW;

localparam  PW_WORD_CNT_WD_FBW      = `log2(PW_WORD_VALID_WD_FBW);
localparam  PW_WORD_CNT_WD_MAX_P1   = PW_WORD_CNT_WD_MAX + 1;

//--------------------------------------
//--------------------------------------
//  Masked write relevant parameters
//--------------------------------------
localparam  MASKED_WR_BITS          = HIF_WRDATA_CYCLES;
localparam  MW_NUM_DB               = MASKED_WR_BITS; // number of data beats
localparam  MW_NUM_DB_LOG2          = `log2(MW_NUM_DB);
localparam  MW_FACTOR_FBW           = 8/`MEMC_FREQ_RATIO;
localparam  MW_WORD_VALID_WD_FBW    = MW_NUM_DB/MW_FACTOR_FBW;
localparam  MW_WORD_VALID_WD_MAX    = MW_WORD_VALID_WD_FBW;
//--------------------------------------


//----------------------- INPUTS AND OUTPUTS -----------------------------------

input           co_yy_clk;                                      // system clock
input           core_ddrc_rstn;                                 // asynchronous falling-edge reset
input           ddrc_cg_en;                                     // DDRC clock gating enable signal
input           reg_ddrc_occap_en;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
input           reg_ddrc_occap_en_r;
//spyglass enable_block W240
output          ddrc_occap_wufifo_parity_err;
output          ddrc_occap_wuctrl_parity_err;

input           dh_wu_lpddr4;                                   // 1: LPDDR4 mode, 0: non-LPDDR4 mode
input           reg_ddrc_lpddr5;                                // 1: LPDDR5 mode, 0: non-LPDDR5 mode
input           co_wu_wdata_valid;          // valid write data from IH
                                            //  valid when co_wu_wdata_valid=1
                                            //  ~6 gate delays from inputs to flops
input  [CORE_DATA_WIDTH-1:0]    co_wu_wdata;    // write data from IH
                                                //  valid when co_wu_wdata_valid=1
                                                //  2 mux delays from this input before flopping
input  [CORE_MASK_WIDTH-1:0]    co_wu_wdata_mask; // mask for data from IH
                                                  //  1=byte enabled
                                                  //  0=byte disabled
                                                  //  valid when co_wu_wdata_valid=1
                                                  //  2 mux delays from this input before flopping
input  [WDATA_PAR_WIDTH-1:0]    co_wu_wdata_par;  // write data parity




output                          wu_co_wdata_stall;  // stall the data interface when this is 1
                                                    // core should deem data as accepted when
                                                    // data_valid is high and data_stall is low on the same clk edge

input                           ih_wu_wr_valid;    // new write command issued to CAM
input                           ih_wu_wr_valid_addr_err;// if 1, ih_wu_wr_valid is associated with address error
input  [1:0]                    ih_wu_rmw_type;       // new read command issued to CAM
input [WRCAM_ADDR_WIDTH-1:0]    ih_wu_wr_entry_num;   // command is a read, valid when ih_wu_wr_valid=1
input [WORD_BITS-1:0]           ih_wu_critical_word;  // critical word #, valid with ih_wu_wr_valid=1
input                           co_wu_data_end;       // for non-block writes, indicates last data phase
input                           te_wu_wr_retry;       // retry: stall from CAM when collisions occur
input                           te_wu_wr_combine;     // TE is providing an entry number to
                                                      //  be used for write combining
input [WRCAM_ADDR_WIDTH-1:0]    te_wu_entry_num;      // entry number to be used
                                                      //  for write combining
input [WRCAM_ADDR_WIDTH-1:0]    mr_wu_free_wr_entry;  // this write CAM entry # is being freed,
                                                      //  qualified by mr_wu_free_wr_entry_valid
input                           mr_wu_free_wr_entry_valid; // a write CAM entry is being freed
input                           reg_ddrc_burst_mode;  // 1 = interleaved burst mode, 0 = sequential burst mode


input                           ra_wu_rdata_end;      // last piece of data for this read
input                           rd_wu_rdata_valid;    // valid read data returned from DRAM
input [1:0]                     rd_wu_rmw_type;       // read-modify-write type:
                                                      //  00: partial write
                                                      //  01: scrub
                                                      //  10: AIR
                                                      //  11: no RMW
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used only for MEMC_WRDATA 2 cycles configs, but should always exist under MEMC_USE_RMW/MEMC_DDR4
 //spyglass enable_block W240
input [WRCAM_ADDR_WIDTH-1:0]    rd_wu_wr_ram_addr;    // address into the write RAM and
                                                      // scheduler CAM for RMW reads,
                                                      // valid with rd_wu_rdata_valid & rd_wu_rmw
input  [CMD_LEN_BITS-1:0]       rd_wu_partial;        // non-block read




input [CORE_DATA_WIDTH-1:0]             rd_wu_rdata;    // read data from DRAM
input [WDATA_PAR_WIDTH-1:0]             rd_wu_rdata_par;


input  [WRDATA_RAM_ADDR_WIDTH-1:0]      mr_wu_raddr;    // RAM address that MR is getting write data from
output  [CORE_MASK_WIDTH-1:0]           wu_mr_rdata_mask;  // data mask being returned to MR to be written to DRAM

output                                  wu_ih_flow_cntrl_req;   // request to flow control commands from core - wu_wdata_if fifo is full
output                                  wu_fifo_empty;          // used in ddrc_cg_en, so that clock is not gated when write data associated with invalid address are expected




output  [1:0]                           wu_te_enable_wr;  // enable the write transaction in TE
                                                          //  2 bits: [0]   write data completed
                                                          //          [1]  read data completed, or
                                                          //               not an RMW transaction
                                                          //  both bits must be set before
                                                          //  write will be performed
output [WRCAM_ADDR_WIDTH-1:0]           wu_te_entry_num;  // entry number for a write transaction
                //  to enable in TE
input                                   dh_wu_dm_en;      // data mask enable
output                                  wu_te_mwr;        // masked write information
//////spyglass disable_block W240
//////SMD: Input declared but not read
//////SJ: Used in generate block
//////input   [3:0]                           reg_ddrc_burst_rdwr;
//////spyglass enable_block W240
input                                   reg_ddrc_frequency_ratio; 
input   [3:0]                           reg_ddrc_burst_rdwr;
output [PARTIAL_WR_BITS-1:0]            wu_te_wr_word_valid;


output [PW_NUM_DB_LOG2-1:0]             wu_te_ram_raddr_lsb_first;
output [PW_WORD_CNT_WD_MAX-1:0]         wu_te_pw_num_beats_m1;
output [PW_WORD_CNT_WD_MAX-1:0]         wu_te_pw_num_cols_m1;

output  [1:0]                           wu_gs_enable_wr;  // flopped version of wu_te_enable_wr. this is used in
                                                          // GS for clock stop logic
                                                          // when any of these bits are 1, clock shouldn't be stopped

output                                  wu_me_wvalid;     // RAM write enable

//output  [CORE_DATA_WIDTH-1:0]           wu_me_wdata;      // RAM write data
output  [WRSRAM_DATA_WIDTH-1:0]         wu_me_wdata;      // RAM write data

output  [WDATA_PAR_WIDTH_EXT-1:0]       wu_me_wdata_par;  // RAM write data parity


output  [WRDATA_RAM_ADDR_WIDTH-1:0]     wu_me_waddr;    // RAM address (2 addresses per line)


//output  [CORE_MASK_WIDTH-1:0]           wu_me_wmask;    // mask to write or not write data+mask bits
output  [WRSRAM_MASK_WIDTH-1:0]         wu_me_wmask;    // mask to write or not write data+mask bits




input                              te_wu_ie_flowctrl_req;




// wires

wire  [WRDATA_RAM_ADDR_WIDTH-1:0]       next_ram_addr;  // address to send to RAM next cycle


wire  [CORE_MASK_WIDTH-1:0]             next_ram_datamask;  // data mask to be used on  RAM next cycle


wire        last_read;    // last beat of read data return
wire        any_rmw;    // any read-mod-write valid
              //  (explicit RMW command, partial writes w/o DM, and ECC scrubs)
wire        rmw_cmd;    // explicit read-mod-write data valid
wire        scrub;      // read-mod-write valid
wire        wu_co_wdata_stall;

// flops
reg  [HIF_WRDATA_CYCLE_BITS-1:0] rd_xfer_count;      // count read data transfers from RT
wire [HIF_WRDATA_CYCLE_BITS-1:0] rd_xfer_count_i;    // selected rd_xfer_count from Partial Read of RMW (for InlineECC) or other case

reg                                 wdata_valid_in_r;
reg                                 any_rmw_r;
reg                                 mr_wu_free_wr_entry_valid_r; // a write CAM entry is being freed
reg     [WRCAM_ADDR_WIDTH-1:0]      mr_wu_free_wr_entry_r; // this write CAM entry # is being freed,
reg  [CORE_MASK_WIDTH-1:0]          enabled_bytes     [WRDATA_ENTRIES-1:0];
reg  [CORE_MASK_WIDTH-1:0]          enabled_bytes_nxt [WRDATA_ENTRIES-1:0];

              // track enabled bytes in the RAM (active high)






//// more flopped inputs

wire                          r_rdata_end;          // flopped data-end indicator

reg                           rmw_cmd_ff;           // valid read data for an explicit RMW command
reg                           scrub_ff;             // valid read data for a scrub
wire  [WRCAM_ADDR_WIDTH-1:0]  r_last_rmw_wr_addr;   // upper bits of RAM address
reg   [WRCAM_ADDR_WIDTH-1:0]  r2_last_rmw_wr_addr;  // upper bits of RAM address, delayed one cycle to
                                                    //  allow for internal ECC calculation
reg                           last_rd_ff;           // flopped indication of the end of a block or non-block read





reg                               wu_me_wvalid;    // RAM write enable
reg [WRDATA_RAM_ADDR_WIDTH-1:0]   wu_me_waddr;  // RAM address


reg [WRSRAM_MASK_WIDTH-1:0]         wu_me_wmask;    // byte enables for MASK RAM


reg [WRSRAM_DATA_WIDTH-1:0]         wu_me_wdata;            // RAM write data

reg [WDATA_PAR_WIDTH_EXT-1:0]      wu_me_wdata_par;


wire  [WRCAM_ADDR_WIDTH-1:0]      enable_wr_entry_num;  // entry number for a write transaction
wire  [1:0]                       enable_wr;

// signals for the write data mask detection
wire  [MW_NUM_DB_LOG2-1:0]          mw_curr_word_num; // number of write data word
wire  [WRCAM_ADDR_WIDTH-1:0]        mw_curr_wrcam_entry; // number of WR CAM entry
reg                                 wmask_det_in_r; // detection for comming wdatamask_in
wire                                wmask_det_in; // detection for comming wdatamask_in
wire  [MASKED_WR_BITS-1:0]          wmask_word_be; // bit enable
reg   [MASKED_WR_BITS-1:0]          wmask_word_next;
reg   [MASKED_WR_BITS-1:0]          wmask_word [WRCAM_ENTRIES-1:0]; // masked info for each CAM entry
reg   [MASKED_WR_BITS-1:0]          wmask_word_nxt [WRCAM_ENTRIES-1:0]; // masked info for each CAM entry
wire  [MASKED_WR_BITS-1:0]          wmask_word_int;
reg [MW_WORD_VALID_WD_FBW-1:0]      mw_word_valid_fbw;
reg [MW_WORD_VALID_WD_FBW-1:0]      mw_word_valid_fbw_r; 
wire [MW_WORD_VALID_WD_MAX-1:0]     mw_word_valid;
reg [MW_WORD_VALID_WD_MAX-1:0]      mw_word_valid_bl16;
//reg     [MW_WORD_VALID_WD_MAX-1:0]      mw_word_valid_bl32;
reg                                 wu_te_mwr_in;

// signals for this logic
wire  [PW_NUM_DB_LOG2-1:0]          pw_curr_word_num;
wire  [WRCAM_ADDR_WIDTH-1:0]        pw_curr_wrcam_entry; // number of WR CAM entry
wire  [PARTIAL_WR_BITS-1:0]         pw_word_valid_bit;
reg   [PARTIAL_WR_BITS-1:0]         pw_word_valid_next;
reg   [PARTIAL_WR_BITS-1:0]         pw_word_valid[WRCAM_ENTRIES-1:0];  // valid_word for each CAM entry
reg   [PARTIAL_WR_BITS-1:0]         pw_word_valid_nxt[WRCAM_ENTRIES-1:0];  // valid_word for each CAM entry
wire  [PARTIAL_WR_BITS-1:0]         wu_te_wr_word_valid_int;

reg   [PW_WORD_VALID_WD_MAX-1:0]    wu_mr_pw_word_valid_bl8;
reg   [PW_WORD_VALID_WD_MAX-1:0]    wu_mr_pw_word_valid_bl8_col;
reg   [PW_WORD_VALID_WD_MAX-1:0]    wu_mr_pw_word_valid_bl16;
reg   [PW_WORD_VALID_WD_MAX-1:0]    wu_mr_pw_word_valid_bl16_col;

              //  used to update next transaction table



// outputs from the interface block; inputs to the WU core
wire  [WRDATA_RAM_ADDR_WIDTH-1:0]     waddr_in;
wire  [CORE_DATA_WIDTH-1:0]           wdata_in;


wire  [CORE_MASK_WIDTH-1:0]           wdatamask_in;

wire  [WDATA_PAR_WIDTH-1:0]           wdatapar_in;



wire                                    wdata_valid_in;         // valid write data from core
wire                                    wdata_end_in;           // last data phase from core
wire                                    combine_vld_in;         // write combine indicator out of input FIFO
wire  [1:0]                             rmw_type_in;            // rmw_type out of input FIFO


// signals from memc_wu_wdata_if
wire                                  combine_vld_in_if;         // write combine indicator out of input FIFO
wire  [1:0]                           rmw_type_in_if;            // rmw_type out of input FIFO
wire  [WRDATA_RAM_ADDR_WIDTH-1:0]     waddr_in_if;
wire  [CORE_DATA_WIDTH-1:0]           wdata_in_if;
wire  [CORE_MASK_WIDTH-1:0]           wdatamask_in_if;
wire  [WDATA_PAR_WIDTH-1:0]           wdatapar_in_if;
wire                                  wdata_valid_in_if;         // valid write data from core
wire                                  wdata_end_in_if;           // last data phase from core



wire [2:0]                            wdata_count_nxt;
wire [2:0]                            wdata_count;

wire                                  reg_ddrc_ddr5;
wire                                  ddr5_or_lpddr45;
wire [MASKED_WR_BITS-1:0]             bc8_wmask_en;



  reg   [$bits(rmw_type_in)-1:0]    rmw_type_in_r; // rmw_type out of input FIFO

  always_ff @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
      rmw_type_in_r   <= {$bits(rmw_type_in_r){1'b0}};
    end else if(ddrc_cg_en) begin
      rmw_type_in_r   <= rmw_type_in;
    end
  end







wire                           i_ra_wu_rdata_end;
wire                           i_rd_wu_rdata_valid;
wire [1:0]                     i_rd_wu_rmw_type;

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used only for MEMC_WRDATA 2 cycles configs, but should always exist under MEMC_USE_RMW/MEMC_DDR4
 //spyglass enable_block W240
wire [WRCAM_ADDR_WIDTH-1:0]    i_rd_wu_wr_ram_addr;
wire  [CMD_LEN_BITS-1:0]       i_rd_wu_partial;



wire [CORE_DATA_WIDTH-1:0]             i_rd_wu_rdata;
wire [WDATA_PAR_WIDTH-1:0]             i_rd_wu_rdata_par;


//------------------------------------------------------------------
// Non Read-CRC Retry config
assign i_ra_wu_rdata_end = ra_wu_rdata_end;
assign i_rd_wu_rdata_valid = rd_wu_rdata_valid;
assign i_rd_wu_rmw_type = rd_wu_rmw_type;
assign i_rd_wu_wr_ram_addr = rd_wu_wr_ram_addr;
assign i_rd_wu_partial = rd_wu_partial;
assign i_rd_wu_rdata = rd_wu_rdata;
assign i_rd_wu_rdata_par = rd_wu_rdata_par;


//------------------------------------------------------------------------------
// IH and core interface (custom for Aqua project: supports only block writes)
//------------------------------------------------------------------------------
// Count data phases.  For each entry use:
//  use data_end with !block_wr (N/A for Aqua, since all are block_wr)

memc_wu_wdata_if
 #(.WRCAM_ADDR_WIDTH      (WRCAM_ADDR_WIDTH),
                   .WRDATA_RAM_ADDR_WIDTH (WRDATA_RAM_ADDR_WIDTH),
                   .CORE_DATA_WIDTH       (CORE_DATA_WIDTH),
                   .CORE_MASK_WIDTH       (CORE_MASK_WIDTH),
                   .WDATA_PAR_WIDTH       (WDATA_PAR_WIDTH),
                   .WRSRAM_DATA_WIDTH     (WRSRAM_DATA_WIDTH),
                   .WRSRAM_MASK_WIDTH     (WRSRAM_MASK_WIDTH),
                   .WORD_BITS             (WORD_BITS),
                   .CORE_DCERRBITS_PKG    (CORE_DCERRBITS_PKG),
                   .UMCTL2_SEQ_BURST_MODE (UMCTL2_SEQ_BURST_MODE),
                   .OCCAP_EN              (OCCAP_EN),
                   .OCCAP_PIPELINE_EN     (OCCAP_PIPELINE_EN),
                   .PW_WORD_CNT_WD_MAX    (PW_WORD_CNT_WD_MAX)
                )
  memc_wu_wdata_if (
    .co_yy_clk    (co_yy_clk),
    .core_ddrc_rstn         (core_ddrc_rstn),
    .ddrc_cg_en             (ddrc_cg_en),
    .reg_ddrc_occap_en      (reg_ddrc_occap_en),
    .ddrc_occap_wufifo_parity_err (ddrc_occap_wufifo_parity_err),
//`ifdef DDRCTL_WR_CRC_RETRY
//    .reg_ddrc_burst_rdwr    (reg_ddrc_burst_rdwr),
//`endif
    .dh_wu_lpddr4           (dh_wu_lpddr4),
    .reg_ddrc_lpddr5        (reg_ddrc_lpddr5),
    .co_wu_wdata_valid      ((co_wu_wdata_valid & (~wu_co_wdata_stall))), // valid only when stall is low
    .co_wu_wdata            (co_wu_wdata),
    .co_wu_wdata_mask       (co_wu_wdata_mask),
    .co_wu_wdata_par        (co_wu_wdata_par),

    .ih_wu_wr_valid           (ih_wu_wr_valid),
    .ih_wu_wr_valid_addr_err  (ih_wu_wr_valid_addr_err),
    .ih_wu_rmw_type           (ih_wu_rmw_type),
    .ih_wu_wr_entry_num       (ih_wu_wr_entry_num),
    .ih_wu_critical_word      (ih_wu_critical_word),
    .co_wu_data_end           (co_wu_data_end),
    .te_wu_wr_retry           (te_wu_wr_retry),
    .te_wu_wr_combine         (te_wu_wr_combine),
    .te_wu_entry_num          (te_wu_entry_num),
    .reg_ddrc_burst_mode      (reg_ddrc_burst_mode),
    .waddr_in                 (waddr_in_if),
    .wdata_in                 (wdata_in_if),
    .wdatamask_in             (wdatamask_in_if),
    .wdatapar_in              (wdatapar_in_if),
    .wdata_valid_in           (wdata_valid_in_if),
    .wdata_end_in             (wdata_end_in_if),
    .wu_ih_flow_cntrl_req     (wu_ih_flow_cntrl_req),
    .wu_fifo_empty            (wu_fifo_empty),
    .rmw_type_in              (rmw_type_in_if),
    .combine_vld_in           (combine_vld_in_if),
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement and therefore must always exist
    .wdata_count_nxt          (wdata_count_nxt),
    .wdata_count              (wdata_count)
//spyglass enable_block W528
  );

//------------------------------------------------------------------------------
// Inline ECC logic
//------------------------------------------------------------------------------
assign combine_vld_in     =  combine_vld_in_if;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
assign rmw_type_in        =  rmw_type_in_if;
//spyglass enable_block W528
assign waddr_in           =  waddr_in_if;
assign wdata_in           =  wdata_in_if;
assign wdatamask_in       =  wdatamask_in_if;
assign wdatapar_in        =  wdatapar_in_if;
assign wdata_end_in       =  wdata_end_in_if;
assign wdata_valid_in     =  wdata_valid_in_if;


//------------------------------------------------------------------------------
// Combinational Logic
//------------------------------------------------------------------------------


// for RMW read, write the bytes that any previous write did not already fill in;
// for any other write, write the bytes enabled by this write
// NOTE: These are the byte enables to the data RAM, NOT the saved BEs

assign next_ram_datamask = any_rmw ? ~enabled_bytes[next_ram_addr] :
                                      wdatamask_in                 ;




assign last_read  = r_rdata_end;


// for RMW, take the RAM address from RT
// for standard writes, use address provided by core
// lower bits of RAM address are always provided by a counter.
assign next_ram_addr  = wdata_valid_in ? waddr_in                            :
                         {r_last_rmw_wr_addr, rd_xfer_count_i} ;

assign rd_xfer_count_i = rd_xfer_count;

// receiving read data for read-mod-write transaction
assign rmw_cmd    = i_rd_wu_rdata_valid &  (i_rd_wu_rmw_type == `MEMC_RMW_TYPE_RMW_CMD);

// receiving read data for scrub
assign any_rmw    = i_rd_wu_rdata_valid & (i_rd_wu_rmw_type != `MEMC_RMW_TYPE_NO_RMW);
assign scrub    = i_rd_wu_rdata_valid & (i_rd_wu_rmw_type == `MEMC_RMW_TYPE_SCRUB) & (MEMC_ECC_SUPPORT != 0);




// send rdata mask at the same time read data from WDATARAM arrives at DDRCTL
// use delayed read address to get the mask
assign wu_mr_rdata_mask          = enabled_bytes[mr_wu_raddr];



// assigning the write data stall signal
// data is accepted by the controller when data_valid is high and data_stall is low
// on the same clock edge
//   wu_co_wdata_stall will be asserted when requested from HWFFC
assign  wu_co_wdata_stall = any_rmw | te_wu_ie_flowctrl_req 
 ;




// -------------------- Combo logic to enable writes in TE ---------------------

// wu_te_enable_wr[1] is set when no more read data is required from DDR for this entry
//                    (NOTE: for write combine, this will keep the status from the first write; do not set it again)
//                    Fow non-RMW commands, this bit is set along with the wdata_end_in
//                    For RMW commands, it is set when last read data of the RMW arrives
// wu_te_enable_wr[0] is set when no more write data is required from the core interface for this entry
//                    For write commands, this will happen along with the wdata_end_in
//                    For those commands that do not have write data from core (for eg: scrub and rmw_cmd operations)
//                    this bit is set along with the arrival of the last read data for the RMW operation

assign enable_wr[1] = (wdata_valid_in && (rmw_type_in != `MEMC_RMW_TYPE_PARTIAL_NBW)) ? (wdata_end_in & (~combine_vld_in)) : (any_rmw & r_rdata_end);
assign enable_wr[0] = wdata_valid_in ? wdata_end_in : (any_rmw & r_rdata_end & (rmw_cmd | scrub));



// strip off data bit(s) from address to get CAM entry number to get the
// write number to enable in the TE CAM

   assign enable_wr_entry_num[WRCAM_ADDR_WIDTH-1:0] = wdata_valid_in ? next_ram_addr[WRDATA_RAM_ADDR_WIDTH-1:1] :
                                                                    r_last_rmw_wr_addr[WRCAM_ADDR_WIDTH-1:0]  ;





// assign 2-bit enable_wr and write-entry-number to outputs
reg [1:0] wu_te_enable_wr; 
reg [1:0] wu_gs_enable_wr; 
reg [WRCAM_ADDR_WIDTH-1:0] wu_te_entry_num;  // entry number for a write transaction
always  @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    wu_te_enable_wr <= 2'b00;
    wu_gs_enable_wr <= 2'b00;
    wu_te_entry_num <= {WRCAM_ADDR_WIDTH{1'b0}};
  end
  else if(ddrc_cg_en) begin
    wu_te_enable_wr <= enable_wr;
    wu_gs_enable_wr <= enable_wr;
    wu_te_entry_num <= enable_wr_entry_num;
  end


//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(i_cnt * MW_FACTOR_HBW)' found in module 'memc_wu'
//SJ: This coding style is acceptable and there is no plan to change it.

//------------------------------------------------------------------------------
//  Write data mask detection for MWR command in LPDDR4 mode
//------------------------------------------------------------------------------
// The WRITE CAM entry and the number of words are decoded from next write address to SRAM.
// These must be same as defined in memc_wu_wdata_if.

// DDR protocol
assign reg_ddrc_ddr5=1'b0;
assign ddr5_or_lpddr45 = dh_wu_lpddr4 | reg_ddrc_lpddr5 | reg_ddrc_ddr5;

// write data mask enable for BC8

// write data mask detection for wdatamask_in
assign wmask_det_in     = combine_vld_in    ? (|(~(wdatamask_in | enabled_bytes[next_ram_addr])))
                        :                     (|(~wdatamask_in))
                        ;

assign mw_curr_word_num     = wu_me_waddr[MW_NUM_DB_LOG2-1:0]; // lower bits
assign mw_curr_wrcam_entry  = wu_me_waddr[WRDATA_RAM_ADDR_WIDTH-1:MW_NUM_DB_LOG2]; // higher bits

always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    wmask_det_in_r  <= 1'b0;
  end else if(ddrc_cg_en) begin
    wmask_det_in_r  <= wmask_det_in;
  end
end

// masked info for each CAM entry
assign wmask_word_be    = ({{(MASKED_WR_BITS-1){1'b0}}, 1'b1} << mw_curr_word_num); // bit enable

always @(*) begin : wmask_word_next_PROC
  integer j;
  for (j=0; j<MASKED_WR_BITS; j=j+1) begin
    if (wdata_valid_in_r) begin
      if (wmask_word_be[j] && (rmw_type_in_r == `MEMC_RMW_TYPE_NO_RMW)) begin
        wmask_word_next[j] = wmask_det_in_r;
      end else begin
        wmask_word_next[j] = wmask_word[mw_curr_wrcam_entry][j];
      end
    end else if (any_rmw_r) begin
      wmask_word_next[j] = 1'b0;
    end else begin
      wmask_word_next[j] = wmask_word[mw_curr_wrcam_entry][j];
    end
  end
end


always @(*) begin : wmask_word_nxt_PROC
  integer mw_y_cnt;
//spyglass disable_block W216
//SMD: Inappropriate range select for int_part_sel variable: "mw_y_cnt[(WRCAM_ADDR_WIDTH - 1):0] "
//SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)

    for (mw_y_cnt=0; mw_y_cnt<WRCAM_ENTRIES; mw_y_cnt=mw_y_cnt+1) begin
      if ((mw_y_cnt[WRCAM_ADDR_WIDTH-1:0] == mw_curr_wrcam_entry) && wdata_valid_in_r) begin
        wmask_word_nxt[mw_y_cnt] = wmask_word_next;
      end else if ((mw_y_cnt[WRCAM_ADDR_WIDTH-1:0] == mw_curr_wrcam_entry) && any_rmw_r) begin
        wmask_word_nxt[mw_y_cnt] = {MASKED_WR_BITS{1'b0}};
      end else if ((mw_y_cnt[WRCAM_ADDR_WIDTH-1:0] == mr_wu_free_wr_entry_r) && mr_wu_free_wr_entry_valid_r) begin
        wmask_word_nxt[mw_y_cnt] = {MASKED_WR_BITS{1'b1}}; // all masked      
      end else begin
        wmask_word_nxt[mw_y_cnt] = wmask_word[mw_y_cnt]; // keep current value
      end
    end // for mw_y_cnt
//spyglass enable_block W216
end


integer mw_x_cnt;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : wmask_word_PROC
  if (~core_ddrc_rstn) begin
    for (mw_x_cnt=0; mw_x_cnt<WRCAM_ENTRIES; mw_x_cnt=mw_x_cnt+1) begin
      wmask_word[mw_x_cnt] <= {MASKED_WR_BITS{1'b1}}; 
    end
  end
  else if(ddrc_cg_en) begin
    for (mw_x_cnt=0; mw_x_cnt<WRCAM_ENTRIES; mw_x_cnt=mw_x_cnt+1) begin
        wmask_word[mw_x_cnt] <= wmask_word_nxt[mw_x_cnt];
     end // for mw_x_cnt
  end
end

// The mask info for the write CAM
// This is written in the write CAM at a timing when wu_te_enable_wr is valid.
assign wmask_word_int = wmask_word_next;

//spyglass disable_block W415a
//SMD: Signal mw_word_valid_fbw is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches

// FBW
// Convert wmask_word_int with is MASKED_WR_BITS wide
// into a vector that is MASKED_WR_BITS/MW_FACTOR_FBW
// TODO: FBW will be valid when MEMC_BURST_LENGTH_32 will be supported in future
always @(*) begin : mw_word_valid_fbw_PROC
  integer i_cnt;

  mw_word_valid_fbw = mw_word_valid_fbw_r;

  for (i_cnt=0; i_cnt<MW_WORD_VALID_WD_FBW; i_cnt=i_cnt+1) begin
    mw_word_valid_fbw[i_cnt] = (|(wmask_word_int[i_cnt*MW_FACTOR_FBW+:MW_FACTOR_FBW]));
  end

end
//spyglass enable_block W415a

// registered version of mw_word_valid_fbw
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    mw_word_valid_fbw_r <= {MW_WORD_VALID_WD_FBW{1'b0}};
  end else begin
    mw_word_valid_fbw_r <= mw_word_valid_fbw;
  end
end

assign  mw_word_valid = mw_word_valid_fbw;

// BL16
always @(*) begin : mw_word_valid_bl16_PROC
  integer k_cnt;

  mw_word_valid_bl16 = {MW_WORD_VALID_WD_MAX{1'b0}};

  for (k_cnt=0; k_cnt<MW_WORD_VALID_WD_MAX+1-1; k_cnt=k_cnt+1) begin
    mw_word_valid_bl16[k_cnt+:1] = (|(mw_word_valid[k_cnt+:1])) ? 1'b1 : 1'b0;
  end

end

// BL32
//always @(*) begin : mw_word_valid_bl32_PROC
//  integer k_cnt;
//
//  mw_word_valid_bl32 = {MW_WORD_VALID_WD_MAX{1'b0}};
//
//  for (k_cnt=0; k_cnt<MW_WORD_VALID_WD_MAX+1-2; k_cnt=k_cnt+2) begin
//    mw_word_valid_bl32[k_cnt+:2] = (|(mw_word_valid[k_cnt+:2])) ? 2'b11 : 2'b00;
//  end
//
//end

//spyglass disable_block W415a
//SMD: Signal wu_te_mwr_in is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
always @(*) begin : wu_te_mwr_in_PROC
  integer k_cnt;

  wu_te_mwr_in = 1'b0;

  if (ddr5_or_lpddr45 && dh_wu_dm_en) begin
    for (k_cnt=0; k_cnt<MW_WORD_VALID_WD_MAX; k_cnt=k_cnt+1) begin
      wu_te_mwr_in  = (mw_word_valid_bl16[k_cnt]
                    & wu_mr_pw_word_valid_bl16_col[k_cnt*8]
                    ) | wu_te_mwr_in;
    end
  end else begin
    wu_te_mwr_in  = 1'b0;
  end
end
//spyglass enable_block W415a


assign wu_te_mwr = wu_te_mwr_in;

//-----------------------------
// Logic that determines which data words are valid - used for Partial Writes
//-----------------------------

// The WRITE CAM entry and the number of words are decoded from next write address to SRAM.
// These must be same as defined in memc_wu_wdata_if.
assign pw_curr_word_num    = wu_me_waddr[PW_NUM_DB_LOG2-1:0]; // lower bits
assign pw_curr_wrcam_entry = wu_me_waddr[WRDATA_RAM_ADDR_WIDTH-1:PW_NUM_DB_LOG2]; // higher bits

// word_valid info for current CAM entry being accessed
assign pw_word_valid_bit    = ({{(PARTIAL_WR_BITS-1){1'b0}}, 1'b1} << pw_curr_word_num); // word_valid enable

always @(*) begin : pw_word_valid_next_PROC
  integer i_cnt;
  for (i_cnt=0; i_cnt<PARTIAL_WR_BITS; i_cnt=i_cnt+1) begin
    if (wdata_valid_in_r) begin
      if (pw_word_valid_bit[i_cnt]) begin
        pw_word_valid_next[i_cnt] = 1'b1;
      end else begin
        pw_word_valid_next[i_cnt] = pw_word_valid[pw_curr_wrcam_entry][i_cnt];
      end
    end else if (scrub_ff) begin
    // ccx_line_begin: ; This is related to scrub feature. uMCTL5 moved this function from ddrc to SBR block. So this is redundant. However we've not decided to remove this logic completely. This function has not been used in uMCTL2 for a long time.
      if (pw_word_valid_bit[i_cnt]) begin
        pw_word_valid_next[i_cnt] = 1'b1;
      end else begin
        pw_word_valid_next[i_cnt] = pw_word_valid[pw_curr_wrcam_entry][i_cnt];
      end
    // ccx_line_end
    end else begin
      pw_word_valid_next[i_cnt] = pw_word_valid[pw_curr_wrcam_entry][i_cnt];
    end
  end
end



// Loop through each WR CAM entry element in pw_word_valid
// Update with pw_word_valid_next if HIF write data is being received
// Reset to 0 via mr_wu_free_wr_entry*

always @(*) begin : pw_word_valid_nxt_PROC
  integer pw_y_cnt;
    //spyglass disable_block W216
    //SMD: Inappropriate range select for int_part_sel variable: "pw_y_cnt[(WRCAM_ADDR_WIDTH - 1):0] "
    //SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)
    for (pw_y_cnt=0; pw_y_cnt<WRCAM_ENTRIES; pw_y_cnt=pw_y_cnt+1) begin
      if ( (pw_y_cnt[WRCAM_ADDR_WIDTH-1:0]==pw_curr_wrcam_entry) && wdata_valid_in_r) begin
        pw_word_valid_nxt[pw_y_cnt] = pw_word_valid_next;
      end else if ( (pw_y_cnt[WRCAM_ADDR_WIDTH-1:0]==pw_curr_wrcam_entry) && scrub_ff) begin
      // ccx_line_begin: ; This is related to scrub feature. uMCTL5 moved this function from ddrc to SBR block. So this is redundant. However we've not decided to remove this logic completely. This function has not been used in uMCTL2 for a long time.
        pw_word_valid_nxt[pw_y_cnt] = pw_word_valid_next;
      // ccx_line_end
      end else if ((pw_y_cnt[WRCAM_ADDR_WIDTH-1:0]==mr_wu_free_wr_entry_r) && mr_wu_free_wr_entry_valid_r) begin
        pw_word_valid_nxt[pw_y_cnt] = {PARTIAL_WR_BITS{1'b0}}; // all not valid
      end else begin
        pw_word_valid_nxt[pw_y_cnt] = pw_word_valid[pw_y_cnt]; // keep current value
      end
    end // for pw_y_cnt
    //spyglass enable_block W216
end



integer pw_x_cnt;
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin : pw_word_valid_PROC
  if (~core_ddrc_rstn) begin
    for (pw_x_cnt=0; pw_x_cnt<WRCAM_ENTRIES; pw_x_cnt=pw_x_cnt+1) begin
      pw_word_valid[pw_x_cnt] <= {PARTIAL_WR_BITS{1'b0}}; // all not valid
    end
  end
  else if(ddrc_cg_en) begin
    for (pw_x_cnt=0; pw_x_cnt<WRCAM_ENTRIES; pw_x_cnt=pw_x_cnt+1) begin
        pw_word_valid[pw_x_cnt] <= pw_word_valid_nxt[pw_x_cnt];
     end // for pw_x_cnt
  end
end


// The word_valid info for the write CAM
// This is written in the write CAM at a timing when wu_te_enable_wr is valid.
assign wu_te_wr_word_valid_int = pw_word_valid_next;
assign wu_te_wr_word_valid = wu_te_wr_word_valid_int;

///
// Logic for wu_mr_ram_addr
//


// possibilities:
// 1:2 | BL8  | 2 data beats
// 1:2 | BL16 | 4 data beats
// 1:4 | BL16 | 2 data beats
//

// FBW
// Convert wu_te_wr_word_valid_int with is PARTIAL_WR_BITS wide
// into a vector that is PARTIAL_WR_BITS*FREQ_RATIO
reg [PW_WORD_VALID_WD_FBW-1:0] wu_mr_pw_word_valid_fbw;
reg [PW_WORD_VALID_WD_FBW-1:0] wu_mr_pw_word_valid_fbw_r;

//spyglass disable_block W415a
//SMD: Signal wu_mr_pw_word_valid_fbw is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
always @(*) begin : pw_wu_word_valid_fbw_PROC
  integer i_cnt;
  integer x_cnt;
  wu_mr_pw_word_valid_fbw = wu_mr_pw_word_valid_fbw_r;
  for (i_cnt=0; i_cnt<PW_NUM_DB; i_cnt=i_cnt+1) begin
    for (x_cnt=0; x_cnt<PW_FACTOR_FBW; x_cnt=x_cnt+1) begin
      if (wu_te_wr_word_valid_int[i_cnt]) begin
        wu_mr_pw_word_valid_fbw[i_cnt*PW_FACTOR_FBW + x_cnt] = 1'b1;
      end else begin
        wu_mr_pw_word_valid_fbw[i_cnt*PW_FACTOR_FBW + x_cnt] = 1'b0;
      end
    end
  end
end
//spyglass enable_block W415a

// registered version of wu_mr_pw_word_valid_fbw
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    wu_mr_pw_word_valid_fbw_r <= {PW_WORD_VALID_WD_FBW{1'b0}};
  end else begin
    wu_mr_pw_word_valid_fbw_r <= wu_mr_pw_word_valid_fbw;
  end
end

wire [PW_WORD_VALID_WD_MAX-1:0] wu_mr_pw_word_valid;
assign wu_mr_pw_word_valid = wu_mr_pw_word_valid_fbw;

//spyglass disable_block W415a
//SMD: Signal is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches


// BL8
always @(*) begin : wu_mr_pw_word_valid_bl8_PROC
  integer k_cnt;
  
  wu_mr_pw_word_valid_bl8 = {PW_WORD_VALID_WD_MAX{1'b0}};
  wu_mr_pw_word_valid_bl8_col = {PW_WORD_VALID_WD_MAX{1'b0}};

  // loop backwards from top to find last BL8 position in case of BC4
  // For non-last BL8,
  for (k_cnt=PW_WORD_VALID_WD_MAX-4; k_cnt>=0; k_cnt=k_cnt-4) begin
    if (|wu_mr_pw_word_valid[k_cnt+:4]) begin
      wu_mr_pw_word_valid_bl8_col[k_cnt] = 1'b1;
          wu_mr_pw_word_valid_bl8[k_cnt+:4] = 4'b1111;
    end
  end // for
end

// BL16
always @(*) begin : wu_mr_pw_word_valid_bl16_PROC
  integer k_cnt;

//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4 
  wu_mr_pw_word_valid_bl16 = {PW_WORD_VALID_WD_MAX{1'b0}};
  wu_mr_pw_word_valid_bl16_col = {PW_WORD_VALID_WD_MAX{1'b0}};

  for (k_cnt=0; k_cnt<PW_WORD_VALID_WD_MAX+1-8; k_cnt=k_cnt+8) begin
    if (|wu_mr_pw_word_valid[k_cnt+:8]) begin
      wu_mr_pw_word_valid_bl16_col[k_cnt] = 1'b1;
  //`ifdef MEMC_FREQ_RATIO_4
  //`endif // MEMC_FREQ_RATIO_4 
          wu_mr_pw_word_valid_bl16[k_cnt+:8] = 8'b1111_1111;
    end
  end // for

end
//spyglass enable_block W415a


wire [PW_WORD_VALID_WD_MAX-1:0] wu_mr_pw_word_valid_bl_sel;
assign wu_mr_pw_word_valid_bl_sel = (reg_ddrc_burst_rdwr[3]) ? wu_mr_pw_word_valid_bl16 : wu_mr_pw_word_valid_bl8;

wire [PW_WORD_VALID_WD_MAX-1:0] wu_mr_pw_word_valid_bl_col_sel;
assign wu_mr_pw_word_valid_bl_col_sel = (reg_ddrc_burst_rdwr[3]) ? wu_mr_pw_word_valid_bl16_col : wu_mr_pw_word_valid_bl8_col;

reg  [PW_WORD_CNT_WD_MAX-1:0] wu_mr_pw_word_valid_first;
reg  [PW_WORD_CNT_WD_MAX-1:0] wu_mr_pw_word_valid_first_r; 

//spyglass disable_block W415a
//SMD: Signal wu_mr_pw_word_valid_first is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
always @(*) begin : wu_mr_pw_word_valid_first_PROC
  integer j_cnt;
  wu_mr_pw_word_valid_first = wu_mr_pw_word_valid_first_r;
  //spyglass disable_block W216
  //SMD: Inappropriate range select for int_part_sel variable: "j_cnt[(PW_WORD_CNT_WD_MAX - 1):0] "
  //SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)
  
  // search backwards to find first location that is valid
  for (j_cnt=PW_WORD_VALID_WD_MAX-1; j_cnt>=0; j_cnt=j_cnt-1) begin
    if (wu_mr_pw_word_valid_bl_sel[j_cnt]) begin
      wu_mr_pw_word_valid_first = j_cnt[PW_WORD_CNT_WD_MAX-1:0];
    end
  end // for
  //spyglass enable_block W216
end
//spyglass enable_block W415a

// registered version of wu_mr_pw_word_valid_first
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    wu_mr_pw_word_valid_first_r <= {PW_WORD_CNT_WD_MAX{1'b0}};
  end
  else if(ddrc_cg_en) begin
    wu_mr_pw_word_valid_first_r <= wu_mr_pw_word_valid_first;
  end
end

// drive ram_raddr_lsb_first based on wu_mr_pw_word_valid_first
wire [PW_NUM_DB_LOG2-1:0] wu_mr_ram_raddr_lsb_first_int;
assign wu_mr_ram_raddr_lsb_first_int = wu_mr_pw_word_valid_first[PW_WORD_CNT_WD_FBW-1 -: PW_NUM_DB_LOG2] ;

assign wu_te_ram_raddr_lsb_first = wu_mr_ram_raddr_lsb_first_int;


//
// pw_num_beats
//
wire [PW_WORD_CNT_WD_MAX_P1-1:0] pw_num_beats;
reg  [PW_WORD_CNT_WD_MAX_P1:0]   pw_num_beats_wider;

//spyglass disable_block W415a
//SMD: Signal pw_num_beats_wider is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
always @(*) begin : pw_num_beats_PROC
  integer j_cnt;

  pw_num_beats_wider = {(PW_WORD_CNT_WD_MAX_P1+1){1'b0}};
  // j_cnt increments by 1 or 2, depending on FREQ_RATIO
  for (j_cnt=0; j_cnt<PW_WORD_VALID_WD_MAX; j_cnt=j_cnt+`MEMC_FREQ_RATIO) begin
    pw_num_beats_wider = pw_num_beats_wider[PW_WORD_CNT_WD_MAX_P1-1:0] + { {(PW_WORD_CNT_WD_MAX_P1-1){1'b0}}, wu_mr_pw_word_valid_bl_sel[j_cnt] };
  end
end
//spyglass enable_block W415a

assign pw_num_beats = pw_num_beats_wider[PW_WORD_CNT_WD_MAX_P1-1:0];

wire [PW_WORD_CNT_WD_MAX_P1-1:0] pw_num_beats_x;
// double down the num_beats of ram_raddr being Read if SW selected 1:4 mode in
// HW configured 1:4 mode
assign pw_num_beats_x = (!reg_ddrc_frequency_ratio) ? {pw_num_beats[PW_WORD_CNT_WD_MAX_P1-2:0], 1'b0} : pw_num_beats;

wire [PW_WORD_CNT_WD_MAX_P1-1:0] pw_num_beats_m1_x;
//spyglass disable_block TA_09
//SMD: Net 'DWC_ddrctl.U_ddrc.memc_wu.pw_num_beats_x[3]' [in 'memc_wu'] is not observable[affected by other input(s)]. Adding a test-point [Obs = y]  will make 11 nets observable.
//SJ: Functionally correct. In some configs, pw_num_beats_x[3] might never have value 1'b1.
assign pw_num_beats_m1_x = pw_num_beats_x - {{(PW_WORD_CNT_WD_MAX_P1-1){1'b0}}, 1'b1};
//spyglass enable_block TA_09
assign wu_te_pw_num_beats_m1 = pw_num_beats_m1_x[PW_WORD_CNT_WD_MAX-1:0];


//
// pw_num_cols_m1
//

wire [PW_WORD_CNT_WD_MAX_P1-1:0]  pw_num_cols;
reg  [PW_WORD_CNT_WD_MAX_P1:0]    pw_num_cols_wider;

//spyglass disable_block W415a
//SMD: Signal pw_num_cols_wider is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
always @(*) begin : pw_num_cols_PROC
  integer j_cnt;

  pw_num_cols_wider = {(PW_WORD_CNT_WD_MAX_P1+1){1'b0}};
  for (j_cnt=0; j_cnt<PW_WORD_VALID_WD_MAX; j_cnt=j_cnt+1) begin
    pw_num_cols_wider = pw_num_cols_wider[PW_WORD_CNT_WD_MAX_P1-1:0] + { {(PW_WORD_CNT_WD_MAX_P1-1){1'b0}}, wu_mr_pw_word_valid_bl_col_sel[j_cnt] };
  end
end
//spyglass enable_block W415a

assign pw_num_cols = pw_num_cols_wider[PW_WORD_CNT_WD_MAX_P1-1:0];

//spyglass disable_block TA_09
//SMD: Net 'DWC_ddrctl.U_ddrc.memc_wu.pw_num_cols[3]' [in 'memc_wu'] is not observable[affected by other input(s)]. Adding a test-point [Obs = y]  will make 16 nets observable.
//SJ: Functionally correct. In some configs, pw_num_cols[3] might never have value 1'b1.
wire [PW_WORD_CNT_WD_MAX_P1-1:0]  pw_num_cols_m1_exp = pw_num_cols - { {(PW_WORD_CNT_WD_MAX_P1-1){1'b0}}, 1'b1};
//spyglass enable_block TA_09
wire [PW_WORD_CNT_WD_MAX-1:0] pw_num_cols_m1 = pw_num_cols_m1_exp[PW_WORD_CNT_WD_MAX-1:0];

  
assign wu_te_pw_num_cols_m1 = pw_num_cols_m1;


//spyglass enable_block SelfDeterminedExpr-ML

//-----------------------------
// Logic that determines the beat in which cerr coming from IH should be written to the cerr fifo.
// in Advanced ECC mode, if poison_chip_en==1 (poison chip fail), all the beats are written the cerr flag.
//-----------------------------






assign r_rdata_end = i_ra_wu_rdata_end;



// generating a pulse when non-block read comes in
wire   rd_wu_partial_rd;
assign rd_wu_partial_rd = i_rd_wu_rdata_valid & |i_rd_wu_partial;

    // calculate byte enables for the word being written to
    //  if incoming read       -> all bytes enabled
    //  if write combine       -> previous bytes OR bytes written now
    //  if non-combining write -> byte enables from IH
    //  else                   -> no change
wire wu_me_wvalid_nxt  = wdata_valid_in | any_rmw;  // valid write OR RMW


reg [HIF_WRDATA_CYCLE_BITS-1:0] rd_xfer_count_nxt; 

always @(*) begin : rd_xfer_count_nxt_PROC


    rd_xfer_count_nxt  = rd_wu_partial_rd ? 1'b0 : (rd_xfer_count ^ i_rd_wu_rdata_valid);  // toggle for each read data from RT




end



always @(*) begin : enabled_bytes_nxt_PROC
  integer eb_cnt;
  //spyglass disable_block W216
  //SMD: Inappropriate range select for int_part_sel variable: "eb_cnt[WRDATA_RAM_ADDR_WIDTH-1:x] "
  //SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)

  for (eb_cnt=0; eb_cnt<WRDATA_ENTRIES; eb_cnt=eb_cnt+1) begin

//----------------------------
//----------------------

    if (mr_wu_free_wr_entry_valid && (eb_cnt[WRDATA_RAM_ADDR_WIDTH-1:1]==mr_wu_free_wr_entry)) begin
      enabled_bytes_nxt[eb_cnt] = {CORE_MASK_WIDTH{1'b0}};
    end

//---------------------
//---------------------

    // calculate byte enables for the word being written to
    //  if incoming read  -> all bytes enabled
    //  if incoming write -> byte enables from IH OR'd in,
    //                       ("OR" is necessary in case RMW read completes before write data gets here,
    //                        or in case of write combine.  It is acceptable even for "normal" writes,
    //                        because byte enables are zlways zero initially - cleared either by reset or
    //                        by free_entry indicator from TE)
    //  else              -> no change
    else if (wdata_valid_in && (eb_cnt[WRDATA_RAM_ADDR_WIDTH-1:0]==next_ram_addr)) begin
      enabled_bytes_nxt[eb_cnt] = (enabled_bytes[eb_cnt] | wdatamask_in);
    end else if (any_rmw && (eb_cnt[WRDATA_RAM_ADDR_WIDTH-1:0]==next_ram_addr)) begin
      enabled_bytes_nxt[eb_cnt] = {CORE_MASK_WIDTH{1'b1}};
    end else begin
      enabled_bytes_nxt[eb_cnt] = enabled_bytes[eb_cnt];
    end


  end // for
  //spyglass enable_block W216
  
end




//------------------------------------------------------------------------------
// Resetable Flops
//------------------------------------------------------------------------------

// resetable flops
always  @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin : wu_SEQ_PROC
  integer wu_seq_cnt;
  if (~core_ddrc_rstn) begin

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement and therefore must always exist
    rmw_cmd_ff    <= 1'b0;
    scrub_ff      <= 1'b0;
//spyglass enable_block W528

    wu_me_wvalid  <= 1'b0;

    rd_xfer_count       <= {HIF_WRDATA_CYCLE_BITS{1'b0}};

    for (wu_seq_cnt=0; wu_seq_cnt<WRDATA_ENTRIES; wu_seq_cnt=wu_seq_cnt+1) begin
      enabled_bytes[wu_seq_cnt]  <= {CORE_MASK_WIDTH{1'b0}};

 
    end



  end // if: reset

  else if(ddrc_cg_en) begin

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement and therefore must always exist
    rmw_cmd_ff    <= rmw_cmd;    // explicit RMW command
    scrub_ff      <= scrub;
//spyglass enable_block W528




     rd_xfer_count <= rd_xfer_count_nxt;

//----------------------------

//----------------------

    if (mr_wu_free_wr_entry_valid) begin
//      enabled_bytes[{mr_wu_free_wr_entry,1'b0}] <= {CORE_MASK_WIDTH{1'b0}};
//      enabled_bytes[{mr_wu_free_wr_entry,1'b1}] <= {CORE_MASK_WIDTH{1'b0}};
    end

//---------------------
//---------------------

    wu_me_wvalid  <= wu_me_wvalid_nxt;

    // calculate byte enables for the word being written to
    //  if incoming read  -> all bytes enabled
    //  if incoming write -> byte enables from IH OR'd in,
    //                       ("OR" is necessary in case RMW read completes before write data gets here,
    //                        or in case of write combine.  It is acceptable even for "normal" writes,
    //                        because byte enables are zlways zero initially - cleared either by reset or
    //                        by free_entry indicator from TE)
    //  else              -> no change
 //   if (wdata_valid_in) begin
 //     enabled_bytes[next_ram_addr] <= (enabled_bytes[next_ram_addr] | wdatamask_in);
//    end else if (any_rmw) begin
//      enabled_bytes[next_ram_addr] <= {CORE_MASK_WIDTH{1'b1}};
//    end
    for (wu_seq_cnt=0; wu_seq_cnt<WRDATA_ENTRIES; wu_seq_cnt=wu_seq_cnt+1) begin
      enabled_bytes[wu_seq_cnt]  <= enabled_bytes_nxt[wu_seq_cnt];
    end    


  
  end // else: not in reset
end

//spyglass disable_block W528
//SMD: Variable any_rmw_r is set but never read
//SJ: Used in generate block
    always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (~core_ddrc_rstn) begin
        wdata_valid_in_r            <= 1'b0;
        any_rmw_r                   <= 1'b0;
        mr_wu_free_wr_entry_valid_r <= 1'b0;
        mr_wu_free_wr_entry_r       <= {WRCAM_ADDR_WIDTH{1'b0}};
      end else if(ddrc_cg_en) begin
        wdata_valid_in_r            <= wdata_valid_in;
        any_rmw_r                   <= any_rmw;
        mr_wu_free_wr_entry_valid_r <= mr_wu_free_wr_entry_valid;
        mr_wu_free_wr_entry_r       <= mr_wu_free_wr_entry;
      end
    end
//spyglass enable_block W528

`ifdef SNPS_ASSERT_ON
    assert property ( @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn)
    (!(any_rmw & wdata_valid_in)) )
    else $error("[%t][%m] ERROR: Both any_rmw and wdata_valid_in asserted.", $time);
`endif


  // remember the address of the last RMW response
  assign    r_last_rmw_wr_addr  = (i_rd_wu_rdata_valid & (i_rd_wu_rmw_type != `MEMC_RMW_TYPE_NO_RMW)) ?
                                            i_rd_wu_wr_ram_addr[WRCAM_ADDR_WIDTH-1:0] : r2_last_rmw_wr_addr;



wire last_rd_ff_nxt = i_rd_wu_rdata_valid & last_read;

wire [CORE_DATA_WIDTH-1:0]  wu_me_wdata_int;
wire [WDATA_PAR_WIDTH-1:0]  wu_me_wdata_par_int;


//------------------------------------------------------------------------------
// Non-Resetable Flops
//------------------------------------------------------------------------------
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement
    last_rd_ff    <= 1'b0;
//spyglass enable_block W528
    r2_last_rmw_wr_addr  <= {WRCAM_ADDR_WIDTH{1'b0}};
    wu_me_waddr    <= {WRDATA_RAM_ADDR_WIDTH{1'b0}};
    wu_me_wmask    <= {WRSRAM_MASK_WIDTH{1'b0}};


    wu_me_wdata         <= {WRSRAM_DATA_WIDTH{1'b0}};

    wu_me_wdata_par     <= {WDATA_PAR_WIDTH_EXT{1'b0}};



  end
  else if(ddrc_cg_en) begin


  //// flopped inputs ////
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement
  last_rd_ff    <= last_rd_ff_nxt;
//spyglass enable_block W528

  r2_last_rmw_wr_addr  <= r_last_rmw_wr_addr;  // hold this an extra cycle, since read response data is
            //  delayed one cycle to add internal ECC encoding in RA


  //// flopped outputs ////
  wu_me_waddr    <= next_ram_addr;
  //Asserting all masks to WDATARAM to clear the stall data from the previous write for the fresh WR CMD
  wu_me_wmask    <= next_ram_datamask;




  wu_me_wdata           <= wu_me_wdata_int;

  wu_me_wdata_par       <= wu_me_wdata_par_int;



end // always: non-resetable flops







//------------------------------------------------------------------------------
// OCCAP protection of certain control related signals
//------------------------------------------------------------------------------

  //
  // Control logic for memc_wu module 
  // protect by following method:
  // - combining into one bus (nxt_bus) the nxt version of a number of unprotected
  //   control registers
  // - pgen on this combined bus
  // - register the parity information
  // - combine into one bus (curr_bus) the current version of number of unprotected
  //   control registers
  // - pcheck on this curr_bus with registered version of prevv generated
  //   parity info
  //
  //

//

   localparam   SL_W             = 8;   
   localparam CTRL_W =
                       2 + // wu_te_enable_wr
                       2 + // wu_gs_enable_wr
                       WRCAM_ADDR_WIDTH + // wu_te_entry_num
                       1 + // wmask_det_in_r
                       2 + // rmw_type_in_r
                       WRCAM_ENTRIES*MASKED_WR_BITS + // wmask_word
                       MW_WORD_VALID_WD_FBW + // mw_word_valid_fbw_r
                       WRCAM_ENTRIES*PARTIAL_WR_BITS + // pw_word_valid
                       PW_WORD_VALID_WD_FBW + // wu_mr_pw_word_valid_fbw_r
                       PW_WORD_CNT_WD_MAX +   // wu_mr_pw_word_valid_first_r
                       1 + // rmw_cmd_ff
                       1 + // scrub_ff
                       HIF_WRDATA_CYCLE_BITS + // rd_xfer_count               
                       1 + // wu_me_wvalid
                       CORE_MASK_WIDTH*WRDATA_ENTRIES + // enabled_bytes
//`ifdef MEMC_SIDEBAND_ECC
                       // enabled_bytes_int_ecc
                       // cerr
                       // ???
                       // wdata_first_in
//`endif // MEMC_SIDEBAND_ECC
                       
                       

                       1 + // wdata_valid_in_r
                       1 + // any_rmw_r
                       1 + // mr_wu_free_wr_entry_valid_r
                       WRCAM_ADDR_WIDTH + // mr_wu_free_wr_entry_r

                       1 + // last_rd_ff
                       WRCAM_ADDR_WIDTH + // r2_last_rmw_wr_addr
                      WRDATA_RAM_ADDR_WIDTH + // wu_me_waddr
                      CORE_MASK_WIDTH + // wu_me_wmask
//`ifdef MEMC_SIDEBAND_ECC
// wu_ih_rank_num
// ...
// r_wu_mr_cerr_rmw_first
//`endif // MEMC_SIDEBAND_ECC
// wu_me_wdata/wu_me_wdata_par already protected via OCPAR
//`ifdef MEMC_SIDEBAND_ECC
// wu_me_wdata_int_ecc
// wu_me_wdata_mask_int_ecc
//`endif // MEMC_SIDEBAND_ECC
// 
//`ifdef MEMC_SIDEBAND_ECC
//`ifdef UMCTL2_PARTIAL_WR
//                       1 + // reg_ddrc_data_poison_bit_r
//                       WRDATA_RAM_ADDR_WIDTH + // mr_wu_cerr_addr_r
//                       cerr_r, cerr_rmw_first_r etc

//`endif // UMCTL2_PARTIAL_WR
//`endif // MEMC_SIDEBAND_ECC
// SIDEBAND_ECC ???
//`ifdef MEMC_SIDEBAND_ECC
//                       4 + // corrected_err_ff
//                       4 + // uncorrected_err_ff
//                       1 + // wu_ih_scrub
//`endif // MEMC_SIDEBAND_ECC
                       3 // wdata_count
                     ;

  localparam   CTRL_PARW             = (OCCAP_EN==1) ? ((CTRL_W%SL_W>0) ? CTRL_W/SL_W+1 : CTRL_W/SL_W) : 0;

 wire ctrl_par_err;

  // drive output
 assign ddrc_occap_wuctrl_parity_err = ctrl_par_err;

 generate
   if (OCCAP_EN==1) begin: OCCAP_en 

      wire [CTRL_PARW-1:0] ctrl_parity_dummy, ctrl_mask_in;

      wire [CTRL_PARW-1:0] ctrl_pgen_in_par, ctrl_parity_err;
      wire [CTRL_PARW-1:0] ctrl_pgen_parity_corr_unused, ctrl_pcheck_parity_corr_unused;
      reg  [CTRL_PARW-1:0] ctrl_pgen_in_par_r;
      
      wire ctrl_pgen_en, ctrl_pcheck_en;

      assign ctrl_parity_dummy  = {CTRL_PARW{1'b1}};
      assign ctrl_mask_in       = {CTRL_PARW{1'b1}};

      wire   ctrl_poison_en     = 1'b0;

      wire par_en   = reg_ddrc_occap_en;
      wire par_en_r = reg_ddrc_occap_en_r;

      assign ctrl_pgen_en    = par_en;   

      // only check if par_en has been enabled for a cycle as pgen only
      // operates if par_en=1
      assign ctrl_pcheck_en  = par_en_r & par_en;


      //
      // rearrange some multi-dimensional signals into a single bus
      // wmask_word_nxt/wmask_word

      reg  [WRCAM_ENTRIES*MASKED_WR_BITS-1:0] wmask_word_nxt_w;
      reg  [WRCAM_ENTRIES*MASKED_WR_BITS-1:0] wmask_word_w;

      always @ (*) begin : wmask_word_w_PROC
      integer wrcam_count_a;
        for (wrcam_count_a=0; wrcam_count_a<WRCAM_ENTRIES; wrcam_count_a=wrcam_count_a+1) begin
          wmask_word_nxt_w[wrcam_count_a*MASKED_WR_BITS+:MASKED_WR_BITS] = wmask_word_nxt[wrcam_count_a];
          wmask_word_w[wrcam_count_a*MASKED_WR_BITS+:MASKED_WR_BITS]     = wmask_word[wrcam_count_a];
        end
      end


      // pw_word_valid_nxt/pw_word_valid

      reg  [WRCAM_ENTRIES*PARTIAL_WR_BITS-1:0] pw_word_valid_nxt_w;
      reg  [WRCAM_ENTRIES*PARTIAL_WR_BITS-1:0] pw_word_valid_w;

      always @ (*) begin : pw_word_valid_w_PROC
      integer wrcam_count;
        for (wrcam_count=0; wrcam_count<WRCAM_ENTRIES; wrcam_count=wrcam_count+1) begin
          pw_word_valid_nxt_w[wrcam_count*PARTIAL_WR_BITS+:PARTIAL_WR_BITS] = pw_word_valid_nxt[wrcam_count];
          pw_word_valid_w[wrcam_count*PARTIAL_WR_BITS+:PARTIAL_WR_BITS]     = pw_word_valid[wrcam_count];
        end
      end

      reg  [WRDATA_ENTRIES*CORE_MASK_WIDTH-1:0]          enabled_bytes_nxt_w;
      reg  [WRDATA_ENTRIES*CORE_MASK_WIDTH-1:0]          enabled_bytes_w;

      always @ (*) begin : enabled_bytes_w_PROC
      integer wde_count;
        for (wde_count=0; wde_count<WRDATA_ENTRIES; wde_count=wde_count+1) begin
          enabled_bytes_nxt_w[wde_count*CORE_MASK_WIDTH+:CORE_MASK_WIDTH] = enabled_bytes_nxt[wde_count];
          enabled_bytes_w[wde_count*CORE_MASK_WIDTH+:CORE_MASK_WIDTH]     = enabled_bytes[wde_count];
        end
      end

// 
// concat signals for pgen/pcheck
//
    
    wire [CTRL_W-1:0] ctrl_pgen_in_x;
    wire [CTRL_W-1:0] ctrl_pgen_in_mask;
    wire [CTRL_W-1:0] ctrl_pgen_in;
    wire [CTRL_W-1:0] ctrl_pcheck_in_x;
    wire [CTRL_W-1:0] ctrl_pcheck_in_mask;
    wire [CTRL_W-1:0] ctrl_pcheck_in;

    // generate concat bus of signals to pgen
    assign ctrl_pgen_in_x = {
                       enable_wr,
                       enable_wr,
                       enable_wr_entry_num,
                       wmask_det_in,
                       rmw_type_in,
                       wmask_word_nxt_w,
                       mw_word_valid_fbw,
                       pw_word_valid_nxt_w,
                       wu_mr_pw_word_valid_fbw,
                       wu_mr_pw_word_valid_first,
                       rmw_cmd,
                       scrub,
                       rd_xfer_count_nxt,
                       wu_me_wvalid_nxt, 
                       enabled_bytes_nxt_w,

                       wdata_valid_in,
                       any_rmw,
                       mr_wu_free_wr_entry_valid,
                       mr_wu_free_wr_entry,

                       last_rd_ff_nxt, 
                       r_last_rmw_wr_addr,
                      next_ram_addr,
                      next_ram_datamask,
                      wdata_count_nxt
                       };

    // generate mask bus of signals to pgen - based off whether it uses
    // cg_en or not
 wire ctrl_pgen_cg_en;
 wire ctrl_pgen_cg_en_r;
 
  reg  ddrc_cg_en_r;

  always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
    if (~core_ddrc_rstn) begin
      ddrc_cg_en_r <= 1'b0;
    end
    else begin
      ddrc_cg_en_r <= ddrc_cg_en;
    end

    assign ctrl_pgen_cg_en = ddrc_cg_en;

    assign ctrl_pgen_cg_en_r = ddrc_cg_en_r;

    assign ctrl_pgen_in_mask = {
                       {2{ctrl_pgen_cg_en}},
                       {2{ctrl_pgen_cg_en}},
                       {WRCAM_ADDR_WIDTH{ctrl_pgen_cg_en}},
                       {1{ctrl_pgen_cg_en}},
                       {2{ctrl_pgen_cg_en}},
                       {WRCAM_ENTRIES*MASKED_WR_BITS{ctrl_pgen_cg_en}},                     
                       {MW_WORD_VALID_WD_FBW{1'b1}},
                       {WRCAM_ENTRIES*PARTIAL_WR_BITS{ctrl_pgen_cg_en}},                     
                       {PW_WORD_VALID_WD_FBW{1'b1}},
                       {PW_WORD_CNT_WD_MAX{ctrl_pgen_cg_en}},
                       {1{ctrl_pgen_cg_en}},
                       {1{ctrl_pgen_cg_en}},
                       {HIF_WRDATA_CYCLE_BITS{ctrl_pgen_cg_en}}, // rd_xfer_count               
                       {1{ctrl_pgen_cg_en}},
                       {CORE_MASK_WIDTH*WRDATA_ENTRIES{ctrl_pgen_cg_en}}, // enabled_bytes

                       {1{ctrl_pgen_cg_en}},
                       {1{ctrl_pgen_cg_en}},
                       {1{ctrl_pgen_cg_en}},
                       {WRCAM_ADDR_WIDTH{ctrl_pgen_cg_en}},

                       {1{ctrl_pgen_cg_en}},
                       {WRCAM_ADDR_WIDTH{ctrl_pgen_cg_en}},
                       {WRDATA_RAM_ADDR_WIDTH{ctrl_pgen_cg_en}},
                       {CORE_MASK_WIDTH{ctrl_pgen_cg_en}},
                       {3{ctrl_pgen_cg_en}}
                       };


// combine the mask and the input signals to registers                       
assign ctrl_pgen_in = ctrl_pgen_in_x & ctrl_pgen_in_mask;


    // generate concat bus of signals to pcheck
assign ctrl_pcheck_in_x = {
                       wu_te_enable_wr,
                       wu_gs_enable_wr,
                       wu_te_entry_num,
                       wmask_det_in_r,
                       rmw_type_in_r,
                       wmask_word_w,
                       mw_word_valid_fbw_r,
                       pw_word_valid_w,
                       wu_mr_pw_word_valid_fbw_r,
                       wu_mr_pw_word_valid_first_r,
                       rmw_cmd_ff,
                       scrub_ff,
                       rd_xfer_count,
                       wu_me_wvalid,
                       enabled_bytes_w,

                       wdata_valid_in_r,
                       any_rmw_r,
                       mr_wu_free_wr_entry_valid_r,
                       mr_wu_free_wr_entry_r,

                       last_rd_ff,
                       r2_last_rmw_wr_addr,
                      wu_me_waddr,
                      wu_me_wmask,
                      wdata_count
                           };

assign ctrl_pcheck_in_mask = {
                       {2{ctrl_pgen_cg_en_r}},
                       {2{ctrl_pgen_cg_en_r}},
                       {WRCAM_ADDR_WIDTH{ctrl_pgen_cg_en_r}},
                       {1{ctrl_pgen_cg_en_r}},
                       {2{ctrl_pgen_cg_en_r}},
                       {WRCAM_ENTRIES*MASKED_WR_BITS{ctrl_pgen_cg_en_r}},                     
                       {MW_WORD_VALID_WD_FBW{1'b1}},
                       {WRCAM_ENTRIES*PARTIAL_WR_BITS{ctrl_pgen_cg_en_r}},
                       {PW_WORD_VALID_WD_FBW{1'b1}},
                       {PW_WORD_CNT_WD_MAX{ctrl_pgen_cg_en_r}},
                       {1{ctrl_pgen_cg_en_r}},
                       {1{ctrl_pgen_cg_en_r}},
                       {HIF_WRDATA_CYCLE_BITS{ctrl_pgen_cg_en_r}}, // rd_xfer_count               
                       {1{ctrl_pgen_cg_en_r}},
                       {CORE_MASK_WIDTH*WRDATA_ENTRIES{ctrl_pgen_cg_en_r}}, // enabled_bytes

                       {1{ctrl_pgen_cg_en_r}},
                       {1{ctrl_pgen_cg_en_r}},
                       {1{ctrl_pgen_cg_en_r}},
                       {WRCAM_ADDR_WIDTH{ctrl_pgen_cg_en_r}},

                       {1{ctrl_pgen_cg_en_r}},
                       {WRCAM_ADDR_WIDTH{ctrl_pgen_cg_en_r}},
                       {WRDATA_RAM_ADDR_WIDTH{ctrl_pgen_cg_en_r}},
                       {CORE_MASK_WIDTH{ctrl_pgen_cg_en_r}},
                       {3{ctrl_pgen_cg_en_r}}
                       };


// combine the mask and the input signals to registers                       
assign ctrl_pcheck_in = ctrl_pcheck_in_x & ctrl_pcheck_in_mask;




         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (CTRL_W), 
            .CALC    (1), // parity calc
            .PAR_DW  (CTRL_PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (ctrl_pgen_in),
            .parity_en     (ctrl_pgen_en),
            .parity_type   (ctrl_poison_en),
            .parity_in     (ctrl_parity_dummy),
            .mask_in       (ctrl_mask_in),
            .parity_out    (ctrl_pgen_in_par), // parity out
            .parity_corr   (ctrl_pgen_parity_corr_unused) // not used
         );



         always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
           if (~core_ddrc_rstn) begin
             ctrl_pgen_in_par_r <= {CTRL_PARW{1'b0}};
           end
           else begin
             ctrl_pgen_in_par_r <= ctrl_pgen_in_par;
           end

         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (CTRL_W),
            .CALC    (0), // parity check
            .PAR_DW  (CTRL_PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (ctrl_pcheck_in),
            .parity_en     (ctrl_pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (ctrl_pgen_in_par_r), // parity in
            .mask_in       (ctrl_mask_in),
            .parity_out    (ctrl_parity_err), // parity error
            .parity_corr   (ctrl_pcheck_parity_corr_unused) // not used
         );

              

         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg ctrl_par_err_r;
           always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin : ctrl_par_err_r_PROC
             if (~core_ddrc_rstn) begin
               ctrl_par_err_r <= 1'b0;
             end else begin
               ctrl_par_err_r <= |ctrl_parity_err;
             end
           end

           assign ctrl_par_err = ctrl_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign ctrl_par_err = |ctrl_parity_err; 

         end


    end // OCCAP_en 
    else begin: OCCAP_dis
   
      assign ctrl_par_err = 1'b0;
    end // OCCAP_dis 
   endgenerate



  assign wu_me_wdata_int = wdata_valid_in ? wdata_in : i_rd_wu_rdata;
  assign wu_me_wdata_par_int = wdata_valid_in ? wdatapar_in : i_rd_wu_rdata_par;


  wire [CORE_DATA_WIDTH-1:0]  poison_wdata_corr;










//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
// Assumptions
assume_no_wrcombine_wo_wrcmd:  // should not receive write combine indicator unless receiving write valid
    assert property ( @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
       (!(te_wu_wr_combine & ~ih_wu_wr_valid )) )
    else $error("[%t][%m] ERROR: Write combine indicated by TE, but no write command request from IH",$time);

// Coverage properties

property cover_wr_combine_retry;  // TBD: ensure this is possible from TE, else make this assumption
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
        (te_wu_wr_combine & te_wu_wr_retry);
endproperty

property cover_wr_combine_noretry;
        @(posedge co_yy_clk) disable iff (~core_ddrc_rstn)
        (te_wu_wr_combine & ~te_wu_wr_retry);
endproperty


localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

// pw_num_beats overflow
assert_never #(0, 0, "pw_num_beats overflow", CATEGORY) a_pw_num_beats_overflow
  (co_yy_clk, core_ddrc_rstn, (pw_num_beats_wider[PW_WORD_CNT_WD_MAX_P1]==1'b1));
  
// pw_num_cols overflow
assert_never #(0, 0, "pw_num_cols overflow", CATEGORY) a_pw_num_cols_overflow
  (co_yy_clk, core_ddrc_rstn, (pw_num_cols_wider[PW_WORD_CNT_WD_MAX_P1]==1'b1));   

   
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule  // memc_wu unit: Write Update Engine
