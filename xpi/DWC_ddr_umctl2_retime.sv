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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_retime.sv#1 $
// -------------------------------------------------------------------------
// Description:
//       Retiming stage
`include "DWC_ddrctl_all_defs.svh"
  module DWC_ddr_umctl2_retime (
         clk,    
         rst_n,    
         d,
         wr,
         rd,
         par_en,
         q,
         fe,
         ff,
         par_err
         );
   parameter         SIZE = 32;
   parameter         OCCAP_EN = 0;
   parameter         OCCAP_PIPELINE_EN = 0;

   input             clk;
   input             rst_n;
   input  [SIZE-1:0] d;
   input             wr;
   input             rd;

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input             par_en;
//spyglass enable_block W240

   output [SIZE-1:0] q;
   output            fe;
   output            ff;

   output            par_err;
   
   localparam        IDLE       = 3'b100;
   localparam        FILL_LOC0  = 3'b001;
   localparam        FILL_LOC1  = 3'b010;

   localparam SL_W         = SIZE<8 ? SIZE : 8;
   localparam PARW         = (SIZE%SL_W>0) ? SIZE/SL_W+1 : SIZE/SL_W;
    
   reg  [2:0]        retime_fsm_reg;
   reg  [2:0]        retime_fsm_next;
   reg  [SIZE-1:0]   data0_reg;
   reg  [SIZE-1:0]   data1_reg;
   wire [SIZE-1:0]   data0_next;
   wire [SIZE-1:0]   data1_next;
   reg               retime_fsm_use_loc1;
   reg               retime_fsm_use_loc0;
   reg               retime_fsm_flip;
    

   assign q                        = data0_reg;
   assign data0_next               = (retime_fsm_use_loc0==1'b1) ? d :
                                     (retime_fsm_flip==1'b1)     ? data1_reg :
                                                                   data0_reg;
   assign data1_next               = (retime_fsm_use_loc1==1'b1) ? d : data1_reg;

   assign fe                       = retime_fsm_reg[2];
   assign ff                       = retime_fsm_reg[1];                             

   always @(*)
   begin:retime_fsm
     retime_fsm_next               = retime_fsm_reg;
     retime_fsm_use_loc1           = 1'b0;
     retime_fsm_use_loc0           = 1'b0;
     retime_fsm_flip               = 1'b0;
     case (retime_fsm_reg)
       IDLE:
         if ( wr )
           begin
              retime_fsm_use_loc0 = 1'b1;
              retime_fsm_next     = FILL_LOC0;
           end
       FILL_LOC0:
         if ( rd & ~ wr )
           begin
              retime_fsm_next    = IDLE;
           end
         else if  ( wr & ~rd ) 
           begin
              retime_fsm_use_loc1  = 1'b1;
              retime_fsm_next      = FILL_LOC1;
           end
         else if ( wr ) 
           begin
              retime_fsm_use_loc0 = 1'b1;
           end
            
       default:
         if ( rd )
           begin
              retime_fsm_flip    = 1'b1;
              retime_fsm_next    = FILL_LOC0;
           end
        endcase
      end

      always @(posedge clk or negedge rst_n)
      begin
        if (rst_n ==1'b0)
          begin 
            retime_fsm_reg                    <= IDLE;
            data0_reg                         <= {(SIZE) {1'b0}};
            data1_reg                         <= {(SIZE) {1'b0}};
          end
          
        else
          begin 
            retime_fsm_reg                     <= retime_fsm_next;
            data0_reg                          <= data0_next;
            data1_reg                          <= data1_next;
          end // else: !if(rst_n ==1'b0)
         
      end // always @ (posedge clk or negedge rst_n)
   
   generate
   if (OCCAP_EN==1) begin: PAR_check

      reg  [PARW-1:0]   par0_reg;
      reg  [PARW-1:0]   par1_reg;
      wire [PARW-1:0]   par0_next;
      wire [PARW-1:0]   par1_next;

      wire [PARW-1:0] parity_dummy, mask_in;

      wire [PARW-1:0] d_par, q_par, parity_err;
      wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;

      wire pgen_en, pcheck_en;

      wire poison_en = 1'b0;

      assign parity_dummy  = {PARW{1'b1}};
      assign mask_in       = {PARW{1'b1}};

      assign pgen_en    = wr & ~ff;
      assign pcheck_en  = par_en & rd & ~fe;


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (SIZE),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (d),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (d_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (SIZE),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (q),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (q_par), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );


         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg par_err_r;
           always @ (posedge clk or negedge rst_n) begin : par_err_r_PROC
             if (~rst_n) begin
               par_err_r <= 1'b0;
             end else begin
               par_err_r <= |parity_err;
             end
           end

           assign par_err = par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign par_err = |parity_err;

         end 



      assign q_par      = par0_reg;
      assign par0_next  = (retime_fsm_use_loc0==1'b1) ? d_par :
                          (retime_fsm_flip==1'b1)     ? par1_reg :
                                                        par0_reg;
      assign par1_next  = (retime_fsm_use_loc1==1'b1) ? d_par : par1_reg;

      always @(posedge clk or negedge rst_n) begin
         if (~rst_n) begin 
            par0_reg    <= {(PARW){1'b0}};
            par1_reg    <= {(PARW){1'b0}};
         end
         else begin 
            par0_reg    <= par0_next;
            par1_reg    <= par1_next;
         end  
      end

    end // PAR_check
    else begin: OCCAP_dis
   
      assign par_err = 1'b0;

    end // OCCAP_dis
    endgenerate

endmodule // DWC_ddr_umctl2_retime
