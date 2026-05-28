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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/wrdata_no_toggle.sv#1 $
// -------------------------------------------------------------------------
// Description:
//                Logic to prevent unnecessary toggling of wrdata output in 
//                dfi.v for power savings. This is instantiated both in 
//                modules mr_data_steering.v (before any crc calculation in 
//                case of ddr4/crc) and in dfi.v
`include "DWC_ddrctl_all_defs.svh"
module wrdata_no_toggle (
    core_ddrc_core_clk,
    core_ddrc_rstn,
    ddrc_cg_en,
    wrdata_in,
    wrdata_mask,
    wrdata_valid,
    wrdata_out
);

parameter PHY_DATA_WIDTH = `MEMC_DFI_TOTAL_DATA_WIDTH;
parameter PHY_MASK_WIDTH = PHY_DATA_WIDTH/8;
parameter DATA_FLOP      = (`MEMC_FREQ_RATIO == 4) ? 7 : 6;
parameter NUM_DATA_CHUNK = 2*`MEMC_FREQ_RATIO;

input                           core_ddrc_core_clk;
input                           core_ddrc_rstn;
input                           ddrc_cg_en;     // Clock gate enable
input  [PHY_DATA_WIDTH-1:0]     wrdata_in;
input  [PHY_MASK_WIDTH-1:0]     wrdata_mask;
input                           wrdata_valid;

output [PHY_DATA_WIDTH-1:0]     wrdata_out;

reg    [PHY_DATA_WIDTH/(2*`MEMC_FREQ_RATIO)-1:0]   wrdata_out_r;   // The upper half(FR=1)/quarter(FR=2) of wrdata_out, flopped again


// Flop upper half of wrdata_out for FR=1, or upper quarter of wrdata_out for FR=2
always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    wrdata_out_r <= {(PHY_DATA_WIDTH/(2*`MEMC_FREQ_RATIO)){1'b0}};
  end else if(ddrc_cg_en) begin
    wrdata_out_r <= wrdata_out[PHY_DATA_WIDTH-1 : PHY_DATA_WIDTH*(DATA_FLOP)/8];
end


// Assign data; hold last value for power savings if byte is not enabled
genvar GEN_BYTES;
generate


for (GEN_BYTES=0; GEN_BYTES<PHY_MASK_WIDTH/NUM_DATA_CHUNK; GEN_BYTES=GEN_BYTES+1)
  begin : gen_data_bytes

    // Assigning first quarter of write data
    // When Byte is masked, assign the 4th quarter data from previous cycle, else assign the 1st quarter from current cycle
    assign wrdata_out[8*GEN_BYTES+7:8*GEN_BYTES] =
                            ((wrdata_mask[GEN_BYTES]                            | (~wrdata_valid))                          ? 
                                wrdata_out_r[(8*GEN_BYTES)+7 : (8*GEN_BYTES)]                                               :
                                wrdata_in[(8*GEN_BYTES)+7 : (8*GEN_BYTES)] )                                                ;

    // Assigning second quarter of write data
    // When Byte is masked, assign the 1st quarter data from the current cycle, else assign the 2nd quarter data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(1*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(1*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(1*PHY_MASK_WIDTH/NUM_DATA_CHUNK)]        | (~wrdata_valid))                                             ?
                                wrdata_out[(8*GEN_BYTES)+7 : (8*GEN_BYTES)]                                                                                   :
                                wrdata_in[(8*GEN_BYTES)+(1*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(1*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

    // Assigning third quarter of write data
    // When Byte is masked, assign the 2nd quarter data from the current cycle, else assign the 3rd quarter data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(2*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(2*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(2*(PHY_MASK_WIDTH/NUM_DATA_CHUNK))]        | (~wrdata_valid))                                           ?
                                wrdata_out[(8*GEN_BYTES)+(1*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(1*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))]           :
                                wrdata_in[(8*GEN_BYTES)+(2*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(2*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

    // Assigning fourth quarter of write data
    // When Byte is masked, assign the 3rd quarter data from the current cycle, else assign the 4th quarter data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(3*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(3*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(3*(PHY_MASK_WIDTH/NUM_DATA_CHUNK))]    | (~wrdata_valid))                                               ? 
                                wrdata_out[(8*GEN_BYTES)+(2*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(2*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))]           :
                                wrdata_in[(8*GEN_BYTES)+(3*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(3*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

    // Assigning fifth 8th of write data
    // When Byte is masked, assign the 4th 8th data from the current cycle, else assign the 5th 8th data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(4*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(4*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(4*(PHY_MASK_WIDTH/NUM_DATA_CHUNK))]        | (~wrdata_valid))                                           ?
                                wrdata_out[(8*GEN_BYTES)+(3*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(3*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))]           :
                                wrdata_in[(8*GEN_BYTES)+(4*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(4*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

    // Assigning sixth 8th of write data
    // When Byte is masked, assign the 5th 8th data from the current cycle, else assign the 6th 8th data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(5*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(5*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(5*(PHY_MASK_WIDTH/NUM_DATA_CHUNK))]    | (~wrdata_valid))                                               ? 
                                wrdata_out[(8*GEN_BYTES)+(4*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(4*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))]           :
                                wrdata_in[(8*GEN_BYTES)+(5*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(5*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

    // Assigning seventh 8th of write data
    // When Byte is masked, assign the 6th 8th data from the current cycle, else assign the 7th 8th data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(6*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(6*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(6*(PHY_MASK_WIDTH/NUM_DATA_CHUNK))]    | (~wrdata_valid))                                               ? 
                                wrdata_out[(8*GEN_BYTES)+(5*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(5*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))]           :
                                wrdata_in[(8*GEN_BYTES)+(6*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(6*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

    // Assigning eighth 8th of write data
    // When Byte is masked, assign the 7th 8th data from the current cycle, else assign the 8th 8th data from current cycle
    assign wrdata_out[(8*GEN_BYTES)+(7*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(7*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] =
                             ((wrdata_mask[GEN_BYTES+(7*(PHY_MASK_WIDTH/NUM_DATA_CHUNK))]    | (~wrdata_valid))                                               ? 
                                wrdata_out[(8*GEN_BYTES)+(6*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(6*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))]           :
                                wrdata_in[(8*GEN_BYTES)+(7*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))+7 : (8*GEN_BYTES)+(7*(PHY_DATA_WIDTH/NUM_DATA_CHUNK))] )          ;

  end // gen_data_bytes
endgenerate


endmodule //wrdata_no_toggle.v
