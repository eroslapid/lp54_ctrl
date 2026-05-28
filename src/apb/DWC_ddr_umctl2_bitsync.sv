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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddr_umctl2_bitsync.sv#2 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_bitsync
  #(parameter BCM_SYNC_TYPE = 2,
    parameter BCM_VERIF_EN  = 0)
   (input          clk_d,
    input          rst_d_n,
    input          data_s,
    output         data_d);

   localparam WIDTH=1'b1;


      
         DWC_ddrctl_bcm21
         
           #(.WIDTH       (WIDTH),
             .F_SYNC_TYPE (BCM_SYNC_TYPE),
             .VERIF_EN    (BCM_VERIF_EN))
         U_bcm21
           (.clk_d    (clk_d),
            .rst_d_n  (rst_d_n),
            .data_s   (data_s),
            .data_d   (data_d)
            );
            
   
endmodule
