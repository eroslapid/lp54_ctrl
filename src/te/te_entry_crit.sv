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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_entry_crit.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module te_entry_crit #(
  //------------------------------- PARAMETERS ----------------------------------
     parameter         BSM_BITS               = `UMCTL2_BSM_BITS
    ,parameter         GEN_BSM_IDX            = 1                
  )
  (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     output                                     entry_critical_per_bsm_early_next
    ,input  [BSM_BITS-1:0]                      ts_bsm_num4rdwr
    ,input                                      te_rdwr_autopre
    ,input  [BSM_BITS-1:0]                      ts_bsm_num4pre
    ,input                                      ts_op_is_precharge
    ,input                                      page_hit_limit_reached
    ,input                                      entry_critical_per_bsm_early
  );

assign entry_critical_per_bsm_early_next = 
         (((ts_bsm_num4rdwr == GEN_BSM_IDX) & te_rdwr_autopre) | (ts_bsm_num4pre==GEN_BSM_IDX & ts_op_is_precharge))? 1'b0 : 
                                                                (page_hit_limit_reached & (ts_bsm_num4rdwr == GEN_BSM_IDX))? 1'b1 : 
                                                                                                                              entry_critical_per_bsm_early;

endmodule
