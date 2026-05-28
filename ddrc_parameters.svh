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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ddrc_parameters.svh#2 $
// -------------------------------------------------------------------------
// Description:
// ----------------------------------------------------------------------------
//                              Description
// This file provides all of the parameters required to configure the
// legacy Intelli DDR Memory Controller and PHY.
// ----------------------------------------------------------------------------
// This part prevents this file from being loaded multiple times
//  (which is necessary, since it will be included in most RTL files.)

`ifndef __GUARD__DDRC_PARAMETERS__SVH__
`define __GUARD__DDRC_PARAMETERS__SVH__

//------------------------------------------------------------------------------
// ECC related defines
//------------------------------------------------------------------------------
`define MEMC_SECDED_ECC_WIDTH_BITS  8   // Width of the secded ECC lane or ADVECC X4 CHIP KILL lane

     //`define MEMC_ECC_SYNDROME_WIDTH    (`MEMC_DRAM_DATA_WIDTH + `MEMC_SECDED_ECC_WIDTH_BITS)
   `define MEMC_ECC_SYNDROME_WIDTH_RD `MEMC_DRAM_DATA_WIDTH + `MEMC_SECDED_ECC_WIDTH_BITS

// Advanced ECC poison register width, = DRAM DATA WIDTH * Number of beats of one ECC code
//  Number of beats is 2 in FR1:1; Number of beats is 4 in FR1:2
`define ECC_POISON_REG_WIDTH   `MEMC_DRAM_TOTAL_DATA_WIDTH*(2*`MEMC_FREQ_RATIO)

// define InlineECC command type
// as used in ddrc_ctrl.v for always there outputs
   `define  IE_RD_TYPE_BITS   1
   `define  IE_WR_TYPE_BITS   1


`define  IE_RD_TYPE_RD_N   2'b00
`define  IE_RD_TYPE_RD_E   2'b01
`define  IE_RD_TYPE_RE_B   2'b10

`define  IE_WR_TYPE_WD_N   2'b00
`define  IE_WR_TYPE_WD_E   2'b01
`define  IE_WR_TYPE_WE_BW  2'b10

//------------------------------------------------------------------------------
// Derived parameters: calculated from above
//------------------------------------------------------------------------------

//-------
// Timing Optimization parameters
//-------
  `define MEMC_SPECIAL_IH_FIFO      1  // replicates IH flops to internal modules to reduce loading

`define MEMC_DCERRFIELD           (`MEMC_DCERRBITS-1):0
`define MEMC_WRCMD_ENTRIES_ADDR   (`MEMC_WRCMD_ENTRY_BITS-1):0     // addressing NUM_WRCMD_ENTRIES
                                                                   //  doubled for the 1X clock domain
// Defines For IH ADDRESS MAP

// The following are the address map base offsets
`define UMCTL2_AM_RANK_BASE 6
`define UMCTL2_AM_BANKGROUP_BASE 3
`define UMCTL2_AM_BANK_BASE 3
`define UMCTL2_AM_COLUMN_BASE 0
`define UMCTL2_AM_ROW_BASE 6
`define UMCTL2_AM_DATACHANNEL_BASE 3
`define UMCTL2_AM_CID_BASE 4

// The following are the address map HET LUT offsets
`define DDRCTL_AM_LUT_MAX_ACTIVE_HIF_ADDR_BASE 20
`define DDRCTL_AM_LUT_CS_BASE 6

// Define from gs_rank_constraints
`define MEMC_GS_REF_DLY 4                   // number of cycles to delay the
                                            //  assertion of "refresh_required".
                                            //  new activates will be blocked
                                            //  for this many cycles
                                            // Minimum value allowed is 2

`define MEMC_GS_RFM_DLY `MEMC_GS_REF_DLY

// Macros from gs_q_fsm.sv
// define high pri/low pri/write queue states
`define MEMC_GS_Q_ST_NORMAL         1'b0
`define MEMC_GS_Q_ST_CRITICAL       1'b1


// Macro from pi.sv
`define PI_ALLOW_BL2

`endif // __GUARD__DDRC_PARAMETERS__SVH__
