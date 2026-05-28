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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_lpfsm.sv#1 $
// -------------------------------------------------------------------------
// Description:
// ---------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_lpfsm (
  // Outputs
  cactive, csysack, ready,
  occap_xpi_lpfsm_par_err,
  // Inputs
  aclk, aresetn, active_trans, csysreq,
  reg_ddrc_occap_en
  
  );
  
  // -------------------------------------------------------------------
  // Parameters
  // -------------------------------------------------------------------
  
  parameter LOWPWR_NOPX_CNT   = 0;
  parameter LOWPWR_NOPX_CNT_W = 1;
  parameter OCCAP_EN          = 0;
  parameter OCCAP_PIPELINE_EN = 0;

  localparam OCCAP_CTRLW = 
                            1 +                 // csysack_delay 
                            1 +                 // csysack
                            1 +                 // ready
                            LOWPWR_NOPX_CNT_W + // nopx_cnt
                            1;                  // nopx_end_cnt
   localparam SL_W = 8;
   localparam PARW = ((OCCAP_CTRLW%SL_W>0) ? OCCAP_CTRLW/SL_W+1 : OCCAP_CTRLW/SL_W);


  
  // -------------------------------------------------------------------
  // Ports
  // -------------------------------------------------------------------
  
  // Global signals  
  input                          aclk;         // clock 
  input                          aresetn;      // asynchronous reset 
  
  input                          active_trans; // active transaction  
  input                          csysreq;      // low power request 

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
  input                          reg_ddrc_occap_en;
//spyglass enable_block W240  

  output                         cactive;      // low power clock active 
  output                         csysack;      // low power acknowledge 
  output                         ready;        // ready signal
  
  output                         occap_xpi_lpfsm_par_err;

  reg                            csysack_delay;
  reg                            csysack_rise;
  reg                            cactive;
  reg                            csysack;
  reg                            ready;

  // wires for signals inside generate of LOWPWR_NOPX_CNT
  wire [LOWPWR_NOPX_CNT_W-1:0]   nopx_cnt_w; 
  wire                           nopx_end_cnt_w;  
  wire [LOWPWR_NOPX_CNT_W-1:0]   nopx_cnt_nxt_w;     
  wire                           nopx_end_cnt_nxt_w;    

  always@(posedge aclk or negedge aresetn)
  begin : csysack_PROC
    if(~aresetn)
    begin
      csysack       <= 1'b1;
      csysack_delay <= 1'b1;
    end
    else
    begin
      csysack       <= csysreq;
      csysack_delay <= csysack;
    end
  end
  
  always@(*)
  begin : csysack_rise_PROC
    csysack_rise = csysack && ~csysack_delay;
  end

  generate

    if (LOWPWR_NOPX_CNT == 0) 
    
    begin : gen_nopx_0

      always@(*)
      begin : cactive_zero_PROC
        cactive = active_trans || csysack_rise;
      end
      
      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in generate block
      assign nopx_cnt_nxt_w     = 1'b0;
      assign nopx_cnt_w         = 1'b0;
      assign nopx_end_cnt_nxt_w = 1'b0;
      assign nopx_end_cnt_w     = 1'b0;
      //spyglass enable_block W528
    end 
    
    else
    
    begin : gen_nopx_1
      reg                         csysreq_rise;
      reg [LOWPWR_NOPX_CNT_W-1:0] nopx_cnt; 
      reg                         nopx_end_cnt; 
  
      reg [LOWPWR_NOPX_CNT_W-1:0] nopx_cnt_nxt;     
      reg                         nopx_end_cnt_nxt;     
      
      always@(*)
      begin : csysreq_rise_PROC
        csysreq_rise = csysreq && ~csysack;
      end



      always@(*)
      begin : nopx_cnt_nxt_PROC
          if ( ~csysreq )
            nopx_cnt_nxt = {LOWPWR_NOPX_CNT_W{1'b0}};
          else begin
            if ( csysreq_rise )
              nopx_cnt_nxt = LOWPWR_NOPX_CNT;
            else begin
              if ( active_trans ) begin
                nopx_cnt_nxt = LOWPWR_NOPX_CNT-1;
              end else begin
                if ( nopx_cnt > 0 ) begin
                  nopx_cnt_nxt = nopx_cnt-1;
                end else begin
                  nopx_cnt_nxt = nopx_cnt;
                end
              end
            end
          end
      end

      always@(posedge aclk or negedge aresetn)
      begin : nopx_cnt_PROC
        if ( ~aresetn )
          nopx_cnt <= LOWPWR_NOPX_CNT-1;
        else
          nopx_cnt <= nopx_cnt_nxt;
      end

      always@(*) begin : nopx_end_cnt_nxt_PROC
          if ( ( nopx_cnt == 0 ) && ( active_trans == 1'b0 ) )
            nopx_end_cnt_nxt = 1'b1;
          else
            nopx_end_cnt_nxt = 1'b0;
      end  

      always@(posedge aclk or negedge aresetn)
      begin : nopx_end_cnt_PROC
        if(~aresetn)
          nopx_end_cnt <= 1'b0;
        else
          nopx_end_cnt <= nopx_end_cnt_nxt;
      end  

  
      always@(*)
      begin : cactive_PROC
        cactive = active_trans || csysack_rise
                  || ( ~nopx_end_cnt && csysack );
      end

      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in generate block

      // drive signal _w outside of generate
      assign nopx_cnt_nxt_w     = nopx_cnt_nxt;
      assign nopx_cnt_w         = nopx_cnt;
      assign nopx_end_cnt_nxt_w = nopx_end_cnt_nxt;
      assign nopx_end_cnt_w     = nopx_end_cnt;
      //spyglass enable_block W528
  
    end
 
  endgenerate
  

  reg ready_nxt;

  always@(*) begin : ready_nxt_PROC

    if ( cactive ) begin
      ready_nxt = 1'b1;
    end else if ( ~csysack ) begin
      ready_nxt = 1'b0;
    end else begin
      ready_nxt = ready;
    end

  end

  always@(posedge aclk or negedge aresetn)
  begin : ready_PROC
    if ( ~aresetn )
      ready <= 1'b1;
    else
      ready <= ready_nxt;
  end


  //---------------------------------------------------------------------------
  // OCCAP_EN process
  // for control related registers on e_clk
  //---------------------------------------------------------------------------

  generate
   if (OCCAP_EN==1) begin: OCCAP_en

     
     wire [OCCAP_CTRLW-1:0] pgen_in;  
     wire [OCCAP_CTRLW-1:0] pcheck_in;  

     // 
     // wiring of pgen_in/pcheck_in
     //


     assign pgen_in    = {csysreq,
                          csysack,
                          ready_nxt,
                          nopx_cnt_nxt_w,
                          nopx_end_cnt_nxt_w}; 

     assign pcheck_in  = {csysack,
                          csysack_delay,
                          ready,
                          nopx_cnt_w,
                          nopx_end_cnt_w};


     wire [PARW-1:0]        pgen_in_par;     
     reg  [PARW-1:0]        pgen_in_par_r;     
     wire [PARW-1:0]        pcheck_par_err; 
     wire [PARW-1:0]        pgen_parity_corr_unused, pcheck_parity_corr_unused;    
     
     wire                   parity_en;
     reg                    pcheck_en;
     wire [PARW-1:0]        parity_dummy,  mask_in;
     wire                   poison_en;

     assign parity_dummy  = {PARW{1'b1}};
     assign mask_in       = {PARW{1'b1}};
     assign poison_en     = 1'b0;

     assign parity_en = reg_ddrc_occap_en;
     always @(posedge aclk or negedge aresetn) begin
           if (~aresetn) begin
              pcheck_en <= 0;
           end
           else begin
              pcheck_en <= parity_en;
           end
        end

           
     // 
     // parity checking logic itself
     //
         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_CTRLW), 
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (pgen_in),
            .parity_en     (parity_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (pgen_in_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         always @ (posedge aclk or negedge aresetn)
           if (~aresetn) begin
             pgen_in_par_r <= {PARW{1'b0}};
           end
           else begin
             pgen_in_par_r <= pgen_in_par;
           end


         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_CTRLW),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (pcheck_in),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (pgen_in_par_r), // parity in
            .mask_in       (mask_in),
            .parity_out    (pcheck_par_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );     
      
         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg pcheck_par_err_r;
           always @ (posedge aclk or negedge aresetn) begin : pcheck_par_err_r_PROC
             if (~aresetn) begin
               pcheck_par_err_r <= 1'b0;
             end else begin
               pcheck_par_err_r <= |pcheck_par_err;
             end
           end

           assign occap_xpi_lpfsm_par_err = pcheck_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign occap_xpi_lpfsm_par_err = |pcheck_par_err;

         end 

         
   end else begin: OCCAP_ne
      assign occap_xpi_lpfsm_par_err = 1'b0;
  end
  endgenerate


        
endmodule
