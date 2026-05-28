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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa_arb.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               PA arbitration block. 
//               Implements the round-robin arbitration to generate
//               the final grant vector amongst the requesting
//               read or write ports. Handles the stall from the DDRC.
//               Implements the round-robin pointer update.
//----------------------------------------------------------------------

`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa_arb
  #(
    parameter NPORTS       = 1,
    parameter OCCAP_EN     = 0,
    parameter OCCAP_PIPELINE_EN     = 0,
    parameter PA_OPT_TYPE  = 1   //1==TWOCYCLE, 2==COMB
    )
   (
    input                 clk,
    input                 rst_n,
    
    input                 hif_cmd_stall,
    input                 any_other_stall_condition,
    input [NPORTS-1:0]    stall_due_to_mask,
    input [NPORTS-1:0]    grant_hold,
    
    input [NPORTS-1:0]    req,

    input                 reg_ddrc_occap_en,

    output                pa_arb_parity_err,
    
    output                switch_states_en,
    output [NPORTS-1:0]   grant,
    output [NPORTS-1:0]   grant_nxt,
    output                grant_en
    );
 
   localparam SIG_VEC_WIDTH = NPORTS*4+1;
   localparam [SIG_VEC_WIDTH-1:0] SIG_VEC_RESVAL = {{NPORTS{1'b1}},{(NPORTS*3+1){1'b0}}}; // rr_pointer, rest

   wire [SIG_VEC_WIDTH-1:0] sig_vec_w, sig_vec_r;

   reg [NPORTS-1:0]       rr_pointer;
   wire [NPORTS-1:0]      rr_pointer_w;
   reg [NPORTS-1:0]       arb_grant_with_stall_switchstate;
   wire [NPORTS-1:0]      arb_grant_with_stall_switchstate_w;
   reg                    grant_en_r;
   wire                   grant_en_r_w;
   reg [NPORTS-1:0]       req_saved;
   wire [NPORTS-1:0]      req_saved_w;
   reg [NPORTS-1:0]       grant_saved;
   wire [NPORTS-1:0]      grant_saved_w;


   wire [NPORTS-1:0]      grant_rr;      
   wire [NPORTS-1:0]      mask_higher_pri_reqs;
   wire [NPORTS-1:0]      unmask_higher_pri_reqs;
   
   wire [NPORTS-1:0]      mhpr_upper, umhpr_upper;
   wire [NPORTS-1:0]      mhpr_lower, umhpr_lower;
   wire [NPORTS-1:0]      grant_rr_lower, grant_rr_upper;
   wire                   rmo, rmo_upper, rmo_lower;
   wire                   unmasked_req_on;
   wire [NPORTS-1:0]      arb_gnt_mask, arb_gnt_mask_switchstate;
   wire [NPORTS-1:0]      grant_nxt_int;
   wire                   lock;
   
   assign sig_vec_w = {rr_pointer,arb_grant_with_stall_switchstate,grant_en_r,req_saved,grant_saved};
   assign {rr_pointer_w,arb_grant_with_stall_switchstate_w,grant_en_r_w,req_saved_w,grant_saved_w} = sig_vec_r;

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (SIG_VEC_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .SL_W    (8),
      .RESVAL  (SIG_VEC_RESVAL)
   )
   U_pa_arb_sig_vec
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (sig_vec_w),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (sig_vec_r),
      .parity_err (pa_arb_parity_err)
   );
   
   // processes request vector from previous cycle,
   // excepting for the granted requestor and any dropped requests
   DWC_ddr_umctl2_pa_roundrobincore
    #(.NPORTS(NPORTS))
   U_roundrobincore_upper (
                           // Outputs
                           .req_masked_on(rmo_upper),
                           .grant(grant_rr_upper[NPORTS-1:0]),
                           .mask_higher_pri_reqs(mhpr_upper[NPORTS-1:0]),
                           .unmask_higher_pri_reqs(umhpr_upper[NPORTS-1:0]),
                           // Inputs
                           .req(req & req_saved_w),
                           .rr_pointer(rr_pointer_w[NPORTS-1:0]));

   
   DWC_ddr_umctl2_pa_roundrobincore
    #(.NPORTS(NPORTS))
   U_roundrobincore_lower (
                           // Outputs
                           .req_masked_on(rmo_lower),
                           .grant(grant_rr_lower[NPORTS-1:0]),
                           .mask_higher_pri_reqs(mhpr_lower[NPORTS-1:0]),
                           .unmask_higher_pri_reqs(umhpr_lower[NPORTS-1:0]),
                           // Inputs
                           .req(req[NPORTS-1:0]),
                           .rr_pointer(rr_pointer_w[NPORTS-1:0]));

   // save requests from previous cycle, sans request that was granted
   always @(*) begin: reg_saved_SEQ_PROC
      req_saved = req_saved_w;
      if(|grant_nxt) req_saved = req & ~grant_rr;
   end

   // Mux between upper and lower RR cores
   assign unmasked_req_on = |(req_saved_w & req);
   assign grant_rr = (unmasked_req_on) ? grant_rr_upper : grant_rr_lower;
   assign mask_higher_pri_reqs = (unmasked_req_on) ? mhpr_upper : mhpr_lower;
   assign unmask_higher_pri_reqs = (unmasked_req_on) ? umhpr_upper : umhpr_lower;
   assign rmo = (unmasked_req_on) ? rmo_upper : rmo_lower;
   
   // if stall OR wptr_ret_fifo full is high, grant shouldn't be issued
   assign arb_gnt_mask = ~({NPORTS{hif_cmd_stall}} | {NPORTS{any_other_stall_condition}} | stall_due_to_mask);

   // the ports can be throttled via stall_due_to_mask; we don't want to prevent direction switching if this happens
   // this is the reason of the twin signals with *_switchstate naming
   assign arb_gnt_mask_switchstate = ~({NPORTS{hif_cmd_stall}} | {NPORTS{any_other_stall_condition}});

   
   // issue grant when grant_rr and no stall and grant is enabled
   assign grant_nxt_int = grant_rr & arb_gnt_mask & {NPORTS{grant_en}};
   
   
   // holding the grant high if stall is present
   always @(*) begin: arb_grant_with_stall_switchstate_SEQ_PROC
      arb_grant_with_stall_switchstate = (grant_nxt | (arb_grant_with_stall_switchstate_w & ~arb_gnt_mask_switchstate));
   end
   
   
   // Arbiter should not give grant in consecutive cycles
   // the logic below is to take care of it
   // grant_en_r is set to 0 for one clock after grant_w
   // and then it is set to 1
   always @(*) begin: grant_en_r_SEQ_PROC
      grant_en_r = grant_en_r_w;
      if(|arb_gnt_mask_switchstate) begin // if no stall
        if(|grant_nxt)
          grant_en_r = 1'b0;
        else
          grant_en_r = 1'b1;
      end
   end

   generate
      if (PA_OPT_TYPE==2) begin: COMB_pa
         assign grant_en = 1'b1;
         // this is the real grant that goes to the ports
         assign grant = grant_nxt;
         // if the current grant is waiting for stall to go away, the s/m inside the preproc module
         // should stay in the same state
         // if this signal is set, switching of states in the controller is enabled
         assign switch_states_en = |arb_gnt_mask_switchstate;
      end
      else begin: SEQ_pa
         assign grant_en = grant_en_r_w;
         // this is the real grant that goes to the ports
         assign grant = (arb_grant_with_stall_switchstate_w & arb_gnt_mask_switchstate);
         // if the current grant is waiting for stall to go away, the s/m inside the preproc module
         // should stay in the same state
         // if this signal is set, switching of states in the controller is enabled
         assign switch_states_en = ~(|arb_grant_with_stall_switchstate_w);
      end
   endgenerate
   
   // Round Robin Pointer update
   // Update is basically an increment to keep things fair
   // Update has been changed to move pointer to port after the one which just received the grant
   // The actual grant though will be given to the highest priority requestor OR
   //    in case of equal priority, the grants will alternate betn active requestors
   // Stall or save-state when other port is running
   // i.e if this is the read side, stall when the write side is active
   
   always @(*) begin: rr_pointer_SEQ_PROC
      rr_pointer = rr_pointer_w;
      if(!hif_cmd_stall) begin
         if(|req & grant_en & |grant_nxt) begin
            if(rmo)
               rr_pointer = mask_higher_pri_reqs;
            else
               rr_pointer = unmask_higher_pri_reqs;
         end
      end
   end

   always @(*) begin: grant_saved_SEQ_PROC
      grant_saved = grant_saved_w;
      if (|grant) grant_saved = grant;
   end

   assign lock = |(grant_hold & grant_saved_w);
   
   assign grant_nxt = (lock) ? (grant_saved_w & arb_gnt_mask_switchstate & {NPORTS{grant_en}}) : grant_nxt_int;
   
endmodule // DWC_ddr_umctl2_pa_arb
