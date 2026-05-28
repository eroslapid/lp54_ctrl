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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ocpar/DWC_ddrctl_antivalent_reg.sv#1 $
// -------------------------------------------------------------------------
// Description:
/******************************************************************************
 *                                                                            *
 * DESCRIPTION: Generated antivalent fault interrrupt. Also align the timing  * 
 *              for normal interupt with fault interrupt                      *
 *                                                                            *
 *****************************************************************************/
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddrctl_antivalent_reg
#(parameter INTR_EN_WIDTH = 1)
(
   input                                     clk
  ,input                                     rstn
  ,input                                     fault_intr
  ,input [INTR_EN_WIDTH-1:0]                 intr
  ,input [INTR_EN_WIDTH-1:0]                 intr_en
  ,output logic [1:0]                        antivalent_fault_intr_out
  ,output logic                              intr_out
);

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// Antivalent fault generation
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge clk, negedge rstn) begin : antivalent_fault_intr_out_PROC
       if (!rstn) begin
          antivalent_fault_intr_out    <= 2'b01;
       end else begin
        if (fault_intr)
           antivalent_fault_intr_out   <= 2'b10;
        else  
           antivalent_fault_intr_out   <= 2'b01;
       end
    end
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Registering the interrupt to match timing with antivalent fault 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge clk, negedge rstn) begin : intr_out_PROC
       if (!rstn) begin
          intr_out    <= 1'b0;
       end else begin
          intr_out   <= |(intr & intr_en);
       end
    end

`ifdef SNPS_ASSERT_ON
   `ifndef SYNTHESIS

   antivalent_fault_default : assert property (@(posedge clk) (antivalent_fault_intr_out[0]== 1'b1 |-> antivalent_fault_intr_out[1]== 1'b0)) else $display ("[%0t] ERROR: antivalent fault is not at the default non active value",$time);
   
   antivalent_fault_set : assert property (@(posedge clk) (antivalent_fault_intr_out[0]== 1'b0 |-> antivalent_fault_intr_out[1]== 1'b1)) else $display ("[%0t] ERROR: antivalent fault is not set appropriately",$time);

   intr_timing_match: assert property (@(posedge clk) disable iff (!rstn) ($past(intr_en)==1'b1 && intr_en== 1'b1 && antivalent_fault_intr_out== 2'b10 |-> intr_out== 1'b1)) else $display ("[%0t] ERROR: Fault and associated interrupt are not asserted at the same time",$time);

   intr_out_disabled : assert property (@(posedge clk) disable iff (!rstn) ((|intr_en) == 1'b0 |-> ##1 intr_out == 1'b0)) else $display("[%0t] ERROR: Interrupt asserted even if interrupt disabled",$time);   
   
   normal_intr_asserted : assert property (@(posedge clk) disable iff (!rstn) ((|(intr_en & intr)) |-> ##1 intr_out == 1'b1)) else $display("[%0t] ERROR: Normal Interrupt not asserted ",$time);   
   
   normal_intr_deasserted_intr_en : assert property (@(posedge clk) disable iff (!rstn) ((|intr_en) == 1'b0 |-> ##1 intr_out == 1'b0)) else $display("[%0t] ERROR: Normal Interrupt not de-asserted when intr en is low ",$time);   

   normal_intr_deasserted_intr : assert property (@(posedge clk) disable iff (!rstn) ((|intr) == 1'b0 |-> ##1 intr_out == 1'b0)) else $display("[%0t] ERROR: Normal Interrupt not de-asserted when intr is low ",$time);   

   fault_intr_asserted  : assert property (@(posedge clk) disable iff (!rstn) (fault_intr == 1'b1 |-> ##1 antivalent_fault_intr_out == 2'b10)) else $display("[%0t] ERROR: Fault Interrupt not asserted ",$time);   
   
   fault_intr_deasserted  : assert property (@(posedge clk) disable iff (!rstn) (fault_intr == 1'b0 |-> ##1 antivalent_fault_intr_out == 2'b01)) else $display("[%0t] ERROR: Fault Interrupt not de-asserted ",$time);   
   `endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
endmodule // DWC_ddrctl_antivalent_reg
