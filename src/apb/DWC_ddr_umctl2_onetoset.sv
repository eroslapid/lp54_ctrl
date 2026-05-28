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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddr_umctl2_onetoset.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_onetoset
  #(parameter BCM_F_SYNC_TYPE = 2,
    parameter BCM_R_SYNC_TYPE = 2,
    parameter BCM_VERIF_EN    = 0,
    parameter REG_OUTPUTS     = 1)
   (input           clk_s,
    input           rst_s_n,
    input           event_s,
    output          ack_s,
    input           clk_d, 
    input           rst_d_n,
    output          event_d 
    );

   localparam PULSE_MODE=1;  //toggle transition in produces single clock cycle pulse out
   localparam REG_ACK=1;     //ack_s will be retimed, event is delayed 1 cycle
   localparam ACK_DELAY=0;   //acknowledge from dest to src will be sent before the dest domain hashad time to detect the event,

   wire             busy_s_unused;
   

   DWC_ddrctl_bcm23
    
     #(.REG_EVENT   (REG_OUTPUTS),
       .REG_ACK     (REG_ACK),
       .ACK_DELAY   (ACK_DELAY),
       .F_SYNC_TYPE (BCM_F_SYNC_TYPE),
       .R_SYNC_TYPE (BCM_R_SYNC_TYPE),
       .VERIF_EN    (BCM_VERIF_EN), 
       .PULSE_MODE  (PULSE_MODE))
   DW_pulse_sync
     (
      .clk_s        (clk_s), 
      .rst_s_n      (rst_s_n), 
      .event_s      (event_s), 
      .ack_s        (ack_s),
      .busy_s       (busy_s_unused),
      .clk_d        (clk_d), 
      .rst_d_n      (rst_d_n), 
      .event_d      (event_d)
      );

endmodule 
