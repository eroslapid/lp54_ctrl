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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/os_glue.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// Operation Selection sub-unit.  This block is responsible for implementing the
// glue logic that does not fit naturally into any other OS sub-unit.
// This block implements muxing between the fences required various
// selection networks in read mode versus write mode. 
// Date:   February 10, 2004
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module os_glue #(
//------------------------------- PARAMETERS ----------------------------------
   parameter  RANK_BITS           = `MEMC_RANK_BITS
  ,parameter  LRANK_BITS          = `DDRCTL_DDRC_LRANK_BITS
  ,parameter  BANK_BITS           = `MEMC_BANK_BITS
  ,parameter  BG_BITS             = `MEMC_BG_BITS
  ,parameter  BG_BANK_BITS        = `MEMC_BG_BANK_BITS

  ,parameter  RANKBANK_BITS       = LRANK_BITS + BG_BANK_BITS // Use LRANK as te -> ts interface is using encoded (CS/CID) rank
  ,parameter  NUM_RANKS           = 1 << RANK_BITS
  ,parameter  NUM_LRANKS          = `DDRCTL_DDRC_NUM_LRANKS_TOTAL
  ,parameter  TOTAL_BANKS         = 1 << RANKBANK_BITS
  ,parameter  TOTAL_BSMS          = `UMCTL2_NUM_BSM
  ,parameter  BSM_BITS            = `UMCTL2_BSM_BITS
    ,parameter    DYN_NUM_RANKS       = 1
)
(
//--------------------------- INPUTS AND OUTPUTS -------------------------------
   input                            gs_os_wr_mode_early         // write mode, 1 cycle early
  ,input                            reg_ddrc_lpddr4             // LPDDR4 
  ,input  [TOTAL_BANKS-1:0]         bs_os_bank_closed           // banks with pages closed
  ,output [NUM_RANKS*8-1:0]         os_gs_bank_closed           // banks with pages closed
  ,input  [BSM_BITS-1:0]            te_os_hi_bsm_hint           // high priority read page hint
  ,input  [BSM_BITS-1:0]            te_os_lo_bsm_hint           // low priority read page hint
  ,input  [BSM_BITS-1:0]            te_os_wr_bsm_hint           // write page hint
  ,input  [BSM_BITS-1:0]            te_os_lo_act_bsm_hint       // bank to prefer for next low priority read
  ,input  [BSM_BITS-1:0]            te_os_wr_act_bsm_hint       // bank to prefer for next write
  ,input  [DYN_NUM_RANKS*TOTAL_BSMS-1:0] bs_os_no_2ck_cmds_after_pre // blocks 2-cycles commands after PRE or commands w/AP
  ,output reg   [NUM_RANKS-1:0]     os_gs_no_2ck_cmds_after_pre // blocks 2-cycles commands after PRE or commands w/AP
  ,output [BSM_BITS-1:0]            lo_rdwr_bsm_hint            // low priority bank hint (read or write)
  ,output [BSM_BITS-1:0]            hi_rdwr_bsm_hint            // low priority bank hint (read or write)
  ,output [BSM_BITS-1:0]            hi_act_bsm_hint            // low priority bank hint (read or write)
  ,output [BSM_BITS-1:0]            lo_act_bsm_hint            // low priority bank hint (read or write)
  ,output [BSM_BITS-1:0]            wr_act_bsm_hint            // write bank hint
  ,output [BSM_BITS-1:0]            pre_req_bsm_hint            // bank hint for requested precharge
  ,output [BSM_BITS-1:0]            wr_pre_req_bsm_hint         // bank wr hint for requested precharge
  ,output [NUM_LRANKS-1:0]          os_gs_rank_closed           // for each rank, all banks in rank have page closed
);

//---------------------------- LOCAL PARAMETERS --------------------------------
localparam  BANKS_PER_RANK      = 1 << BG_BANK_BITS;


// Low priority bank hint: prefer read or write based on write mode
assign lo_rdwr_bsm_hint = gs_os_wr_mode_early ? 
                                                te_os_wr_bsm_hint[BSM_BITS-1:0] :
                                                te_os_lo_bsm_hint[BSM_BITS-1:0]  ;
assign hi_rdwr_bsm_hint = 
                                                te_os_hi_bsm_hint[BSM_BITS-1:0];

assign hi_act_bsm_hint  = te_os_hi_bsm_hint[BSM_BITS-1:0]  ;


assign lo_act_bsm_hint  =  te_os_lo_act_bsm_hint[BSM_BITS-1:0]  ;
assign wr_act_bsm_hint  =  te_os_wr_act_bsm_hint[BSM_BITS-1:0]  ;

// Requested precharge bank hint: for read, use the high priority bank
// hint, even tho it will be wrong when there are no high priority requests
// ("requested precharge" is a precharge to close a page for a page miss) 
assign pre_req_bsm_hint = te_os_hi_bsm_hint[BSM_BITS-1:0] ;
assign wr_pre_req_bsm_hint = te_os_wr_bsm_hint[BSM_BITS-1:0] ;

genvar gen_ranks;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(gen_ranks * BANKS_PER_RANK)' found in module 'os_glue'
//SJ: This coding style is acceptable and there is no plan to change it.

// Rank closed
    // determine which ranks have all banks closed
    generate
        for (gen_ranks=0; gen_ranks<NUM_LRANKS; gen_ranks=gen_ranks+1)
        begin : closed_ranks
            assign os_gs_rank_closed[gen_ranks] = &bs_os_bank_closed[(gen_ranks*BANKS_PER_RANK)+:BANKS_PER_RANK];
        end
    endgenerate

// Bank closed
    genvar gen_banks;
    generate
        for (gen_banks=0; gen_banks<NUM_RANKS*8; gen_banks=gen_banks+1)
        begin : closed_banks
            assign  os_gs_bank_closed[gen_banks] = (reg_ddrc_lpddr4) ? bs_os_bank_closed[(gen_banks/8)*BANKS_PER_RANK+gen_banks[2:0]] :
                                                                       bs_os_bank_closed[(gen_banks/8)*BANKS_PER_RANK+{gen_banks[1:0], 1'b0,gen_banks[2]}] &
                                                                       bs_os_bank_closed[(gen_banks/8)*BANKS_PER_RANK+{gen_banks[1:0], 1'b1,gen_banks[2]}] ;
        end
    endgenerate

    integer idx_rank;

    always @(*) begin
        for (idx_rank=0; idx_rank<NUM_RANKS; idx_rank=idx_rank+1) begin
            os_gs_no_2ck_cmds_after_pre[idx_rank] = |bs_os_no_2ck_cmds_after_pre[(idx_rank*BANKS_PER_RANK)+:BANKS_PER_RANK];
        end
    end
//spyglass enable_block SelfDeterminedExpr-ML

endmodule  // os_glue: glue logic for operation selection
