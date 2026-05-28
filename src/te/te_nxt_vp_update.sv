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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_nxt_vp_update.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// Next Transaction Table update logic (in uMCTL2: with Variable Priority Commands) 
`include "DWC_ddrctl_all_defs.svh"
module te_nxt_vp_update
  #(
    parameter DATAW = 8
    )
   (
    input [DATAW-1:0]  ih_data               // data coming from IH
   ,input [DATAW-1:0]  replace_data          // data coming from te_replace
   ,input [DATAW-1:0]  replace_vp_data       // data coming from te_replace vprw selnet (in uPCTL2 should be always set to '0')  
   ,input [DATAW-1:0]  data_reg              // data reg
   ,input              load                  // load NTT, after RD/WR scheduled
   ,input              load_vp               // trigger load from VPRW selnet (in uPCTL2 should be always set to '0')  
   ,input              load_pre              // load NTT, after PRE scheduled
   ,input [DATAW-1:0]  replace_pre_data      // data comming from te_replace_pre
   ,input              ih_over_replace       // prefer IH to the te_replace (in uPCTL2 should be always set to '0')
   ,input              ih_over_existing      // prefer IH to the exisiting
   ,input              ih_over_existing_vp   // prefer IH expired VPRW to the exisiting (in uPCTL2 should be always set to '0')
   ,output [DATAW-1:0] data_next             // next data
`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
   ,input              clk
   ,input              rstn
   ,input              te_ts_valid
   ,input              entry_mem             // This module is for entry_mem
   ,input              wc_enabled            // write combine is enabled 
   ,input              reg_ddrc_dis_opt_ntt_by_pre
   ,input              reg_ddrc_dis_opt_ntt_by_act
 `endif
`endif
    );

   /* In UMCTL2:
    // Following priroity algorithm is implemented in the logic for te_ts_page_hit and entry_mem
    //
    // Valid exp-VPR from CAM present
    //    If incoming exp-VPR is better than CAM exp-VPR, pick incoming exp-VPR
    //    Else pick CAM exp-VPR
    // (Note: The following is already existing logic)
    // If Read CMD scheduled (existing entry has to be replaced in this case)
    //    If incoming command is better than CAM, pick incoming
    //    Else, pick CAM
    // If no Read CMD scheduled
    //    If incoming cmd is better than existing, pick incoming
    //    Else, update based on ACT/PRE
    */

   /* In uPCTL2:
   // If Read CMD scheduled (existing entry has to be replaced in this case)
   //     pick CAM
   // If no Read CMD scheduled
   //    If incoming cmd and NTT empty , pick incoming
   */

   assign data_next =  load_vp             ? replace_vp_data :
                       ih_over_existing_vp ? ih_data : 
                       load                ? (ih_over_replace ? ih_data : replace_data ) :
                       ih_over_existing    ? ih_data :
                       load_pre            ? replace_pre_data :
                                             data_reg;


`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON


  // Assertions/Coverpoints

  // Check that load and load_pre are exclusive event
  a_ntt_chk_load_load_pre_are_exclusive : assert property (
    @(posedge clk) disable iff (!rstn)
    (~(load_pre & load & (~$past(wc_enabled)) )));

    
  // Check that load_pre is never asserted with dis_opt_ntt_by_pre==1
  a_ntt_chk_load_pre_is_never_asserted_with_feature_disabled : assert property (
    @(posedge clk) disable iff (!rstn)
    (reg_ddrc_dis_opt_ntt_by_pre |-> (load_pre==1'b0)));

  // Check that replace_data and data_reg is unique when dis_opt_ntt_by_act==1
  a_ntt_chk_replace_data_and_data_reg_uniq : assert property (
    @(posedge clk) disable iff (!rstn)
    (
      (
      $past(te_ts_valid) & te_ts_valid // NTT is valid for these cycles 
    & $past(load)                      // There is load event
    & ~($past(ih_over_replace))        // No IH data (replace=empty) 
    & $past(entry_mem)                 // For entry mem only 
    & reg_ddrc_dis_opt_ntt_by_act      // Optimized NTT update has to be disabled 
      )  |-> ($past(replace_data) != $past(data_reg,2))
    )
  );

  // Observe replace logic try to load the same value (happens on ACT)
  cp_replace_data_and_data_reg_same : cover property (
    @(posedge clk) disable iff(~rstn)
      (
      $past(te_ts_valid) & te_ts_valid // NTT is valid for these cycles 
    & $past(load)                      // There is load event
    & ~($past(ih_over_replace))        // No IH data
    & $past(entry_mem)                 // For entry mem only 
    &  ($past(replace_data) == $past(data_reg,2)) // Replace data is same as original one (same)
      )
  ); 

  // Observe replace logic try to load the same value (happens on PRE)
  cp_replace_data_pre_and_data_reg_same : cover property (
    @(posedge clk) disable iff(~rstn)
    ($past(te_ts_valid) & te_ts_valid & $past(load_pre) & entry_mem & ($past(replace_pre_data) == $past(data_reg)))
  );


  `endif

`endif


endmodule
