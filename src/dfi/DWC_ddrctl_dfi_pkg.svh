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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/DWC_ddrctl_dfi_pkg.svh#1 $
// -------------------------------------------------------------------------
// Description:
//    DFI package
//
`ifndef __GUARD__DWC_DDRCTL_DFI_PKG__SVH__
`define __GUARD__DWC_DDRCTL_DFI_PKG__SVH__

`include "DWC_ddrctl_all_defs.svh"

package DWC_ddrctl_dfi_pkg;

   typedef struct packed {
     logic[`MEMC_DFI_ADDR_WIDTH_P3-1:0]  p3;
     logic[`MEMC_DFI_ADDR_WIDTH_P2-1:0]  p2;
     logic[`MEMC_DFI_ADDR_WIDTH_P1-1:0]  p1;
     logic[`MEMC_DFI_ADDR_WIDTH_P0-1:0]  p0;
   } dfi_address_s;

endpackage : DWC_ddrctl_dfi_pkg
`endif // __GUARD__DWC_DDRCTL_DFI_PKG__SVH__
