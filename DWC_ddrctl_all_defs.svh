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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/DWC_ddrctl_all_defs.svh#1 $
// -------------------------------------------------------------------------
// Description:
//
`ifndef __GUARD__DWC_DDRCTL_ALL_DEFS__SVH__
`define __GUARD__DWC_DDRCTL_ALL_DEFS__SVH__

`include "DWC_ddrctl_cc_constants.svh"
`include "apb/DWC_ddrctl_apb_defines.svh"
`include "ddrc_parameters.svh"
`include "DWC_ddrctl_ram_cc_constants.svh"

//ccx_module: DWC_ddrctl_bcm23 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm25 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm36_nhs ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddr_umctl2_bcmwrp36_nhs_inject_x ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm02 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm05 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm05_atv ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm06 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm06_atv ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm07 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm07_atv ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm21 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm21_atv ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm50 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm56 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm57 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm65 ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm65_atv ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm95_i ; This module is verified in a dedicated testbench and provided as fully verified
//ccx_module: DWC_ddrctl_bcm99 ; This module is verified in a dedicated testbench and provided as fully verified


  // =============================================================================
  // VCS UNR Macros
  // =============================================================================
  `ifdef SNPS_ASSERT_ON

    `define SNPS_UNR_CONSTANT(desc, cond, signal, value) \
      `ifdef SNPS_DDR_VCS_UNR_SIM\
        generate if(cond) always @(*) assume (value ==? signal) else $error("UNR_ERROR: UNR Coverage Constant Assumption is not true!!!\n - %s\n", desc); endgenerate \
        `ifdef SNPS_DDR_WRITE_UNR_CONSTANT\
          initial begin if(cond) $display("# %s\n-constant %m.signal value\n",desc); end \
        `endif \
      `endif \
    /*DO NOT REMOVE THIS COMMENT*/

    `define SNPS_UNR_CONSTRAINT(desc, cond, clk, const) \
      `ifdef SNPS_DDR_VCS_UNR_SIM\
        generate if(cond) always @(posedge clk) assume (const) else $error("UNR_ERROR: UNR Coverage Constraint Assumption is not true!!!\n - %s\n", desc); endgenerate \
      `endif \
      `ifdef SNPS_DDR_VCS_UNR\
        generate if(cond) always @(*) assume (const); endgenerate \
      `endif
    /*DO NOT REMOVE THIS COMMENT*/

    `define SNPS_UNR_CONSTRAINT_PROP(desc, cond, const) \
      `ifdef SNPS_DDR_VCS_UNR_SIM\
        generate if(cond) assume property (const) else $error("UNR_ERROR: UNR Coverage Constraint Assumption Property is not true!!!\n - %s\n", desc); endgenerate \
      `endif
    /*DO NOT REMOVE THIS COMMENT*/

  `else // SNPS_UNRCONST_ON

    `define SNPS_UNR_CONSTANT(desc, cond, signal, value) \
    /*DO NOT REMOVE THIS COMMENT*/

    `define SNPS_UNR_CONSTRAINT(desc, cond, clk, const) \
    /*DO NOT REMOVE THIS COMMENT*/

    `define SNPS_UNR_CONSTRAINT_PROP(desc, cond, const) \
    /*DO NOT REMOVE THIS COMMENT*/

  `endif // ! SNPS_UNRCONST_ON
  
`endif // __GUARD__DWC_DDRCTL_ALL_DEFS__SVH__
