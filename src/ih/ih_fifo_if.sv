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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_fifo_if.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module ih_fifo_if #(
    //------------------------------ PARAMETERS ------------------------------------
     parameter RDCMD_ENTRY_BITS= 5     // bits to address all entries in read CAM
    ,parameter WRCMD_ENTRY_BITS= 5     // bits to address all entries in write CAM
    ,parameter WRECCCMD_ENTRY_BITS= 0  // bits to address all entries in write ECC CAM
    ,parameter WRCMD_ENTRY_BITS_IE= 0  // bits to address all entries in total write CAM
    ,parameter RMW_TYPE_BITS   = 2     // 2 bits for RMW type
    )
    (
    //-------------------------- INPUTS AND OUTPUTS ---------------------------------
     input                           co_ih_clk              // clock
    ,input                           core_ddrc_rstn         // active-low reset
    ,input                           rd_valid               // valid read request made to TE
    ,input                           wr_valid               // valid write request made to TE
    ,input                           rd_valid_addr_err      // when 1, rd_valid is associated with address error
    ,input                           wr_valid_addr_err      // when 1, wr_valid is associated with address error
    ,input [RMW_TYPE_BITS-1:0]       rmwtype                // denotes if command is RMW
    ,input                           rd_retry               // read/write request to TE no accepted
    ,input                           wr_retry               // read/write request to TE no accepted
    ,input                           wr_combine             // write combined w/ earlier write
    ,output  [RDCMD_ENTRY_BITS-1:0]  rd_entry               // entry # for read command
    ,output  [WRCMD_ENTRY_BITS_IE-1:0]  wr_entry               // entry # for write command
    ,output  [RDCMD_ENTRY_BITS-1:0]  lo_rd_prefer           // prefered (oldest) entry # for
                                                            //  low priority reads
    ,output  [RDCMD_ENTRY_BITS-1:0]  hi_rd_prefer 
    ,output  [WRCMD_ENTRY_BITS-1:0]  wr_prefer              // prefered (oldest) entry # for writes
    ,input [1:0]                     pri 
    ,output                          rdhigh_empty 
    ,output  [RDCMD_ENTRY_BITS:0]    hpr_fifo_fill_level 
    ,output  [RDCMD_ENTRY_BITS:0]    lpr_fifo_fill_level 
    ,output  [WRCMD_ENTRY_BITS:0]    wr_fifo_fill_level 
    ,output  [RDCMD_ENTRY_BITS:0]    ih_dh_hpr_q_depth      // number of valid entries in the high priority read queue
    ,input   [RDCMD_ENTRY_BITS-1:0]  free_rd_entry 
    ,input                           free_rd_entry_valid 
    ,input   [WRCMD_ENTRY_BITS_IE-1:0]  free_wr_entry 
    ,input                           free_wr_entry_valid 
    ,output                          any_xact 
    ,output                          rdlow_empty 
    ,output                          wr_empty 
    ,input   [RDCMD_ENTRY_BITS-1:0]  dh_ih_lpr_num_entries 
    ,output  [RDCMD_ENTRY_BITS:0]    ih_dh_lpr_q_depth      // number of valid entries in the low priority read queue
    ,output  [WRCMD_ENTRY_BITS:0]    ih_dh_wr_q_depth       // number of valid entries in the write queue
    ,output                          wr_cam_full

);


// Registers and Wires


wire                            rdlow_empty_int;
wire                            allocate_wr_entry;
wire                            free_wr_nom_entry;
wire                            allocate_lpr_entry;
wire                            free_entry_is_hp;
wire                            free_entry_is_wrecc;
wire                            free_lpr_entry;
wire                            free_normal_wr_entry;
wire  [WRCMD_ENTRY_BITS-1:0]    wr_entry_normal;
wire  [RDCMD_ENTRY_BITS-1:0]    lpr_entry;

// declarations for unconnected outputs from FIFOs
wire                            nc_w_stall_unused;
wire                            nc_lpr_stall_unused;
wire                            nc_hpr_stall_unused;

wire                            rd_valid_int;
wire                            wr_valid_int;
wire                            free_wr_num_entry;

wire                            lpr_cam_full_unused;
wire                            hpr_cam_full_unused;
wire                            nc_wrecc_stall_unused;
assign rd_valid_int = 
                        // Don't propagate RMW with address error
                        (rd_valid_addr_err & wr_valid_addr_err & (rmwtype == `MEMC_RMW_TYPE_PARTIAL_NBW)) ? 1'b0 : 
                        rd_valid;
assign wr_valid_int = 
                        // Don't propagate WR/RMW with address error
                        (wr_valid_addr_err) ? 1'b0 : 
                        wr_valid;

// Indication to TS that a transaction has been sent to TE
assign any_xact = rd_valid_int || wr_valid_int;


assign free_entry_is_wrecc   = 
                               1'b0;

// Allocate write entry when write valid and no scrub and no retry and no
//  write combine
assign allocate_wr_entry  = wr_valid_int && (~wr_retry) && (~wr_combine);
assign free_wr_nom_entry  = free_wr_entry_valid && ~free_entry_is_wrecc; 




wire   hi_pri;
assign hi_pri = (pri == 2'b10);

// LPR allocation and free signal generation

wire  [RDCMD_ENTRY_BITS:0]  real_lpr_entries;
assign  real_lpr_entries  = {1'b0, dh_ih_lpr_num_entries} + 1;

assign free_entry_is_hp   = (free_rd_entry > dh_ih_lpr_num_entries);

assign free_lpr_entry     = free_rd_entry_valid && (~free_entry_is_hp);
assign allocate_lpr_entry = rd_valid_int && (~hi_pri) && (~rd_retry);

// HPR allocation and free signal generation
wire    allocate_hpr_entry;
wire    free_hpr_entry;
wire    rd_valid_hi_pri;
assign rd_valid_hi_pri = (rd_valid_int) ? hi_pri : 0;

   assign allocate_hpr_entry = rd_valid_hi_pri & (~rd_retry);

assign free_hpr_entry = free_rd_entry_valid & free_entry_is_hp;

// Generation of the minu1 signal for the partitioning of the Rd CAM to LPR & HPR


///////
// ECC Scrub entry allocation
///////


//////////
// Mux'ing the scrub entry with normal entry
//////////

wire  [RDCMD_ENTRY_BITS-1:0] hpr_entry;


assign wr_entry[WRCMD_ENTRY_BITS-1:0] = 
                                                       wr_entry_normal;

assign rd_entry = 

                  (hi_pri) ? hpr_entry : lpr_entry;



// In ECC designs, the rdlow cam empty should indicate that the CAM is empty
// as well as that the scrub entry is available
// scrub requests are not stored in the CAM, instead in flops an hence this requirement
// when scrub_rd_entry_avail is 1, there is no scrub request pending (same empty)
// when it is 0, then a valid scrub read request is pending, and hence empty should be 0
// this is not applicable to ih_gs_rdhi_empty as the scrub requests are treated as LP read requests
// this is not applicable to write queue as the logic that used this signal in gs_global_fsm
// uses te_bs_wr_valid instead of ih_gs_w_empty
assign rdlow_empty = rdlow_empty_int;


//-------------------------- Sub-Module Instantiations -------------------------
ih_token_fifo
 #(
  .DEPTH (1 << WRCMD_ENTRY_BITS) )
  w_fifo (
  .clk               (co_ih_clk),
  .rstn              (core_ddrc_rstn),
  .token_offset      ({WRCMD_ENTRY_BITS{1'b0}}),
  .no_token          (1'b0),
  .token_max         ({WRCMD_ENTRY_BITS{1'b1}}),
  .allocate_token    (allocate_wr_entry),
  .allocate_token_num(wr_entry_normal),
  .release_token     (free_wr_nom_entry),
  .release_token_num (free_wr_entry[WRCMD_ENTRY_BITS-1:0]),
  .token_empty       (wr_cam_full),
  .token_full        (wr_empty), // token full (all available) means CAM is empty
  .fill_level        (wr_fifo_fill_level),
  .num_token_used    (ih_dh_wr_q_depth)
);
assign wr_prefer = {WRCMD_ENTRY_BITS{1'b0}};

ih_token_fifo
 #(
  .DEPTH (1 << RDCMD_ENTRY_BITS) )
  lpr_fifo (
  .clk               (co_ih_clk),
  .rstn              (core_ddrc_rstn),
  .token_offset      ({RDCMD_ENTRY_BITS{1'b0}}),
  .no_token          (1'b0),
  .token_max         (dh_ih_lpr_num_entries),
  .allocate_token    (allocate_lpr_entry),
  .allocate_token_num(lpr_entry),
  .release_token     (free_lpr_entry),
  .release_token_num (free_rd_entry),
  .token_empty       (lpr_cam_full_unused),
  .token_full        (rdlow_empty_int), // token full (all available) means CAM is empty
  .fill_level        (lpr_fifo_fill_level),
  .num_token_used    (ih_dh_lpr_q_depth)
);
assign lo_rd_prefer = {RDCMD_ENTRY_BITS{1'b0}};


ih_token_fifo
 #(
  .DEPTH (1 << RDCMD_ENTRY_BITS) )
  hpr_fifo (
  .clk               (co_ih_clk),
  .rstn              (core_ddrc_rstn),
  .token_offset      (real_lpr_entries[RDCMD_ENTRY_BITS-1:0]),
  .no_token          (&dh_ih_lpr_num_entries),  // When lpr_num_entries is all 1, no token available on HPR FIFO
  .token_max         ({RDCMD_ENTRY_BITS{1'b1}}),
  .allocate_token    (allocate_hpr_entry),
  .allocate_token_num(hpr_entry),
  .release_token     (free_hpr_entry),
  .release_token_num (free_rd_entry),
  .token_empty       (hpr_cam_full_unused),
  .token_full        (rdhigh_empty), // token full (all available) means CAM is empty
  .fill_level        (hpr_fifo_fill_level),
  .num_token_used    (ih_dh_hpr_q_depth)
);
assign hi_rd_prefer = {RDCMD_ENTRY_BITS{1'b0}};



endmodule
