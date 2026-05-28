//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_filter_2lv.sv#1 $
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
// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//                              Description
//
// This filter classifies an entry to be one of the five classes.
// The five classes are listed in the order of favourable.
//   1. match prefer priority with page hit
//   2. match prefer priority without page hit
// After classification, the filter passes the entries that
// belong to the most favourable class to the selection network
// to participate a CAM search.
//
// ----------------------------------------------------------------------------

`include "DWC_ddrctl_all_defs.svh"
module te_filter_2lv (
  te_bank_hit,
  te_page_hit,
  te_entry_pri,
  pri_level,
  reg_ddrc_opt_hit_gt_hpr,
  te_entry_participate
);

parameter CAM_ENTRIES = 32;

input  [CAM_ENTRIES -1:0]  te_bank_hit;           // bank hit
input  [CAM_ENTRIES -1:0]  te_page_hit;           // page hit
input  [CAM_ENTRIES -1:0]  te_entry_pri;          // page hit
input                      pri_level;
input                      reg_ddrc_opt_hit_gt_hpr;
output [CAM_ENTRIES -1:0]  te_entry_participate;  // qualified entry

wire   [CAM_ENTRIES -1:0]  te_entry_participate_hpr_gt_hit; // opt_hit_gt_hpr == 0, page-miss HPR > page-hit LPR
wire   [CAM_ENTRIES -1:0]  te_entry_participate_hit_gt_hpr; // opt_hit_gt_hpr == 1, page-hit LPR > page-miss HPR

wire   [CAM_ENTRIES -1:0]  i_choose_page_hit_hi;      // same priority as prefer priority with page hit
wire   [CAM_ENTRIES -1:0]  i_choose_bank_hit_hi;      // same priority as prefer priority without page hit
wire   [CAM_ENTRIES -1:0]  i_choose_page_hit_lo;      // same priority as prefer priority with page hit
wire   [CAM_ENTRIES -1:0]  i_choose_bank_hit_lo;      // same priority as prefer priority without page hit
wire                       i_choose_hi;
wire                       i_choose_page_hit;

wire                       i_choose_page_hit_with_pri_level;
wire                       i_choose_page_hit_hi_exist;          // existence of the class mentioned above (i_choose3)
wire                       i_choose_page_hit_lo_exist;          // existence of the class mentioned above (i_choose3)

// classify each entry
assign i_choose_page_hit_hi = te_bank_hit &  te_page_hit & te_entry_pri;
assign i_choose_bank_hit_hi = te_bank_hit &  te_entry_pri;
assign i_choose_page_hit_lo = te_bank_hit &  te_page_hit & ~te_entry_pri;
assign i_choose_bank_hit_lo = te_bank_hit &  ~te_entry_pri;

assign i_choose_hi = (pri_level & (|i_choose_bank_hit_hi)) | (~pri_level & ~(|i_choose_bank_hit_lo));

// check existence of each class
assign i_choose_page_hit_hi_exist = (| (i_choose_page_hit_hi [CAM_ENTRIES -1:0]));
assign i_choose_page_hit_lo_exist = (| (i_choose_page_hit_lo [CAM_ENTRIES -1:0]));

// check existence of page-hit/page-miss
assign i_choose_page_hit = i_choose_page_hit_hi_exist || i_choose_page_hit_lo_exist;

assign i_choose_page_hit_with_pri_level = (pri_level & i_choose_page_hit_hi_exist) || (~pri_level & ~i_choose_page_hit_lo_exist);
// for page-miss HPR > page-hit LPR (i.e. reg_ddrc_opt_hit_gt_hpr == 0)
// if pri_level == 1:
//   page-hit HPR > page-miss HPR > page-hit LPR > page-miss LPR
// if pri_level == 0:
//   page-hit LPR > page-miss LPR > page-hit HPR > page-miss HPR
assign te_entry_participate_hpr_gt_hit =
                                         i_choose_hi            ? (i_choose_page_hit_hi_exist ? i_choose_page_hit_hi : i_choose_bank_hit_hi):
                                                                  (i_choose_page_hit_lo_exist ? i_choose_page_hit_lo : i_choose_bank_hit_lo);

// for page-hit LPR > page-miss HPR (i.e. reg_ddrc_opt_hit_gt_hpr == 1)
// if pri_level == 1:
//   page-hit HPR > page-hit LPR > page-miss HPR > page-miss LPR
// if pri_level == 0:
//   page-hit LPR > page-hit HPR > page-miss LPR > page-miss HPR
assign te_entry_participate_hit_gt_hpr =
                                         i_choose_page_hit      ? (i_choose_page_hit_with_pri_level ? i_choose_page_hit_hi : i_choose_page_hit_lo):
                                                                  (i_choose_hi ? i_choose_bank_hit_hi : i_choose_bank_hit_lo);

assign te_entry_participate = reg_ddrc_opt_hit_gt_hpr ? te_entry_participate_hit_gt_hpr : te_entry_participate_hpr_gt_hit;

endmodule
