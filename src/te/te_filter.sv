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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_filter.sv#1 $
// -------------------------------------------------------------------------
// Description:
// This filter classifies an entry to be one of the five classes.
// The five classes are listed in the order of favourable.
//   1. match prefer priority with page hit
//   2. match prefer priority without page hit
// After classification, the filter passes the entries that
// belong to the most favourable class to the selection network
// to participate a CAM search.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_filter (
  te_bank_hit,
  te_page_hit,
  te_entry_participate
);

parameter CAM_ENTRIES = 32;

input  [CAM_ENTRIES -1:0]  te_bank_hit;              // bank hit
input  [CAM_ENTRIES -1:0]  te_page_hit;           // page hit
output [CAM_ENTRIES -1:0]  te_entry_participate;  // qualified entry

wire   [CAM_ENTRIES -1:0]  i_choose_page_hit;         // same priority as prefer priority with page hit
wire   [CAM_ENTRIES -1:0]  i_choose_bank_hit;         // same priority as prefer priority without page hit
wire                       i_choose_page_hit_exist;          // existence of the class mentioned above (i_choose3)

// classify each entry
assign i_choose_page_hit = te_bank_hit &  te_page_hit;
assign i_choose_bank_hit = te_bank_hit &  ~te_page_hit;
// check existence of each class
assign i_choose_page_hit_exist = (| (i_choose_page_hit [CAM_ENTRIES -1:0]));
assign te_entry_participate =
                               i_choose_page_hit_exist ? i_choose_page_hit: i_choose_bank_hit;
   
endmodule // te_filter
