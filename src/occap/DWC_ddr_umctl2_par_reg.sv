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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/occap/DWC_ddr_umctl2_par_reg.sv#1 $
// -------------------------------------------------------------------------
// Description:
//       Register with parity check
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_par_reg
  #(
      parameter DW      = 32, // data width
      parameter OCCAP   = 0, // 1 parity check enabled
      parameter OCCAP_PIPELINE_EN   = 0, // 1 Pipeline on parity check - assumes OCCAP=1
      parameter REG_EN  = 0,
      parameter SL_W    = 8, // 1 byte
      parameter RESVAL  = 0
  )
  (
      input                   clk,
      input                   rst_n,
      input    [DW-1:0]       data_in,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate blocks.
      input                   reg_set,
      input                   parity_en,
      input                   poison_en,
//spyglass enable_block W240
      output   [DW-1:0]       data_out,
      output                  parity_err
  );

  //---------------------------------------------------------------------------
  // Local Parameters 
  //--------------------------------------------------------------------------- 

   localparam SL_W_INT = (DW<SL_W) ? DW : SL_W;
   
   localparam PARW = (DW%SL_W_INT>0) ? DW/SL_W_INT+1 : 
                                       DW/SL_W_INT;


  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------

   reg [DW-1:0] data_r;

   //---------------------------------------------------------------------------
   // Output assign
   //---------------------------------------------------------------------------

   assign data_out = data_r;


  //---------------------------------------------------------------------------
  // Main module
  //---------------------------------------------------------------------------

   // parity gen/check
   generate
      if (OCCAP==1) begin: OCCAP_en

         wire [PARW-1:0] parity_in, parity_dummy, parity_error, mask_in;
         wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;
         reg [PARW-1:0] parity_r;

         wire pgen_en;
         reg pcheck_en;

         assign parity_dummy  = {PARW{1'b1}};
         assign mask_in       = {PARW{1'b1}};

        
         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (DW),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W_INT)
         )
         U_pgen
         (
            .data_in       (data_in),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (parity_in), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (DW),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W_INT)
         )
         U_pcheck
         (
            .data_in       (data_r),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (parity_r), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_error), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );

        //--------------------------------------------------------------
        // Parity calculation assertions
        //--------------------------------------------------------------
        `ifdef SNPS_ASSERT_ON
          `ifndef SYNTHESIS
            `ifndef VIRL_PAR_REG_ASSERT_DISABLE
              // For PGEN module, check that parity is correctly calculated
              for (genvar i=0; i<PARW-1; i++) begin
                 a_pgen_parity_calc: assert property (
                                                      @(posedge clk) disable iff (!rst_n) 
                                                      if (pgen_en) (
                                                         if (parity_in[i] == 0) 
                                                           (($countones(data_in[i*8+:8]))%2 == 0)
                                                         else  
                                                           (($countones(data_in[i*8+:8]))%2 == 1)
                                                                   )
                                                     );
              end
              a_pgen_parity_calc_last_bits: assert property (
                                                             @(posedge clk) disable iff (!rst_n) 
                                                             if (pgen_en) (
                                                               if (parity_in[PARW-1] == 0) 
                                                                   (($countones(data_in[(DW-1):(PARW-1)*8]))%2 == 0)
                                                               else  
                                                                   (($countones(data_in[(DW-1):(PARW-1)*8]))%2 == 1)
                                                                          )
                                                            );
            `endif
          `endif
        `endif
        

         // assign pcheck_en = parity_en;
        always @(posedge clk or negedge rst_n) begin
           if (~rst_n) begin
              pcheck_en <= 0;
           end
           else begin
              pcheck_en <= parity_en;
           end
        end

         if (REG_EN==1) begin: REG_en

            assign pgen_en = reg_set;

            always @(posedge clk or negedge rst_n) begin
               if (~rst_n) begin
                  parity_r <= 0;
               end
               else begin
                  if (reg_set) parity_r <= parity_in;
               end
            end

         end // REG_en
         else begin: REG_N_en

            assign pgen_en = 1'b1;

            always @(posedge clk or negedge rst_n) begin
               if (~rst_n) begin
                  parity_r <= 0;
               end
               else begin
                  parity_r <= parity_in;
               end
            end

         end // REG_N_en



         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg parity_error_r;
           always @ (posedge clk or negedge rst_n) begin : parity_error_r_PROC
             if (~rst_n) begin
               parity_error_r <= 1'b0;
             end else begin
               parity_error_r <= |parity_error;
             end
           end

           assign parity_err = parity_error_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign parity_err = |parity_error; 

         end


      end // OCCAP_en
      else begin: OCCAP_dis

         assign parity_err = 1'b0;

      end // OCCAP_dis

      // main register
      if (REG_EN==1) begin: REG_en

         always @(posedge clk or negedge rst_n) begin
            if (~rst_n) begin
               data_r <= RESVAL;
            end
            else begin
               if (reg_set) data_r <= data_in;
            end
         end

      end // REG_en
      else begin: REG_N_en

         always @(posedge clk or negedge rst_n) begin
            if (~rst_n) begin
               data_r <= RESVAL;
            end
            else begin
               data_r <= data_in;
            end
         end

      end // REG_N_en
   endgenerate


endmodule // DWC_ddr_umctl2_xpi_ocpar_calc
