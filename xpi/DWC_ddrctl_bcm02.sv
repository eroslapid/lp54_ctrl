
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

//
// Description : DWC_ddrctl_bcm02.v Verilog module for DWC_ddrctl
//
// DesignWare IP ID: 6a51c14a
//
////////////////////////////////////////////////////////////////////////////////



module DWC_ddrctl_bcm02(
        a,
        sel,
        mux
        );

   parameter    integer A_WIDTH    = 8;  // width of input array
   parameter    integer SEL_WIDTH  = 2;  // width of selection index
   parameter    integer MUX_WIDTH  = 2;  // width of selected output
   
   input [A_WIDTH-1:0] a;       // input array to select from
   input [SEL_WIDTH-1:0] sel;   // selection index

   output [MUX_WIDTH-1:0] mux;  // selected output
   reg    [MUX_WIDTH-1:0] mux;

   // Selects one of N equal sized subsections of an
   // input vector to the specified output.
   
  always @ (a or sel) begin : mux_PROC 
    integer     mxny_i, mxny_j, mxny_k;
      mux = {MUX_WIDTH {1'b0}};
      mxny_j = 0;
      mxny_k = 0;
      for (mxny_i=0 ; mxny_i<A_WIDTH/MUX_WIDTH ; mxny_i=mxny_i+1) begin
        if ($unsigned(mxny_i) == sel) begin
          for (mxny_k=0 ; mxny_k<MUX_WIDTH ; mxny_k=mxny_k+1) begin
// spyglass disable_block W415a
// SMD: Signal may be multiply assigned (beside initialization) in the same scope
// SJ: The design checked and verified that not any one of a single bit of the bus is assigned more than once beside initialization or the multiple assignments are intentional.
// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The expression indexing the vector/array will never exceed the bound of the vector/array.
            mux[mxny_k] = a[mxny_j + mxny_k];
// spyglass enable_block W415a
// spyglass enable_block SelfDeterminedExpr-ML
          end // for (mxny_k
        end // if
        mxny_j = mxny_j + MUX_WIDTH;
      end // for (mxny_i
  end

endmodule
