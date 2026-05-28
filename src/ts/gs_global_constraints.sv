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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_global_constraints.sv#2 $
// -------------------------------------------------------------------------
// Description:
//
// Global Scheduler unit.  This block is responsible for choosing from
// among the available transactions to perform to DRAM, except for
// the bypass path (which this block also has the ability to disable).
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_global_constraints 
import DWC_ddrctl_reg_pkg::*;
#(
) (
//--------------------------- INPUTS AND OUTPUTS -------------------------------
   input              core_ddrc_rstn            // asynchronous falling-edge reset
  ,input              co_yy_clk                 // clock

  ,input  [3:0]       dh_gs_burst_rdwr          // 4'h0010=burst of 4 data read/write
                                                // 4'h0100=burst of 8 data read/write
                                                // 4'h1000=burst of 16 data read/write

  ,input  [RD2WR_WIDTH-1:0]       dh_gs_rd2wr               // write latency: AL + CL - 1
  ,input  [WR2RD_WIDTH-1:0]       dh_gs_wr2rd               // read latency:  AL + CL
  ,input  [T_CKE_WIDTH-1:0]       dh_gs_t_cke               // tCKE:    min clock enable time
  ,input  [T_CKESR_WIDTH-1:0]     reg_ddrc_t_ckesr          // tCKESR:  min clock enable time in Self Refresh
  ,input              gs_op_is_rd               // read command
  ,input              gs_op_is_wr               // write command
  ,input              gs_op_is_load_mode        // MRS/MRR command
  ,input              gs_pi_mrr                 // Internally generated MR4 command
  ,input              gs_pi_mrr_ext             // Externally triggered MRR command
  ,input              enter_powerdown           // enter power down mode
  ,input              enter_selfref             // enter power down mode
  ,input              dh_gs_lpddr4
  ,input              reg_ddrc_lpddr4_opt_act_timing
  ,input              reg_ddrc_lpddr5
  ,input  [BANK_ORG_WIDTH-1:0]    reg_ddrc_bank_org                       // bank organization (00:BG, 01:8B, 10:16B)
  ,input  [RD2WR_WIDTH-1:0]       reg_ddrc_rd2wr_s
  ,input                          os_te_autopre
  ,input  [WRA2PRE_WIDTH-1:0]     reg_ddrc_wra2pre
  ,input  [T_CMDCKE_WIDTH-1:0]    dh_gs_t_cmdcke
  ,output                         blk_pd_after_wra
  ,input              dh_gs_frequency_ratio
  ,output reg         lpddr4_blk_act_nxt
  ,input              exit_powerdown            // enter self refresh mode
  ,input              exit_selfref              // exit self refresh mode

  ,output             global_block_rd           // no bypass RD or MRR allowed this cycle - used in gs_next_xact.v
                                                // Reads coming from CAM uses the wr2rd timer in bsm.v - and hence choose_rd in gs_next_xact
                                                // doesn't use ~global_block_rd signal anymore
  ,output             global_block_wr_early     // no write allowed next cycle
  ,output             global_block_cke_change   // no transtions allowed on CKE
  ,input  [T_XP_WIDTH-1:0]    dh_gs_t_xp                 // tXP: duration of powerdown exit assertion/de-assertion
  ,input  [T_RCD_WIDTH-1:0]   dh_gs_t_rcd                // used for tMRRI in LPDDR3
  ,input  [T_CSH_WIDTH-1:0]   reg_ddrc_t_csh
  ,input  [RD2MR_WIDTH-1:0]   reg_ddrc_rd2mr
  ,input  [WR2MR_WIDTH-1:0]   reg_ddrc_wr2mr
  ,output                     mrri_satisfied
  ,output                     rdwr2mrw_satisfied
  ,output             global_block_rd_early
);

//-------------------------- REGISTERS DECLARATIONS ----------------------------

// This will be handled in rank_constraints instead now
reg  [$bits(dh_gs_wr2rd)-1:0]  rd_block_timer;    // time a rd is blocked after rd or wr
reg  [$bits(dh_gs_rd2wr)-1:0]  wr_block_timer;    // time a wr is blocked after rd or wr
reg  [$bits(dh_gs_t_cke)-1:0]  cke_timer;         // min time allowed between CKE changes
reg  [$bits(reg_ddrc_t_ckesr)-1:0]  ckesr_timer;       // min time allowed between CKE changes in Self Refresh

//----------------------------- ASSIGN OUTPUTS ---------------------------------

assign global_block_rd    = (|rd_block_timer);
// Use OR of cke_timer and ckesr_timer to Block CKE changes
assign global_block_cke_change  = (|cke_timer) | (|ckesr_timer);

assign global_block_wr_early  = (|wr_block_timer[$bits(wr_block_timer)-1:1]);
assign global_block_rd_early  = (|rd_block_timer[$bits(rd_block_timer)-1:1]);

//--------------------------------- FLOPS --------------------------------------

// value to adjust  by in generation of rd2wr timer init value
// In DFI 1:2 mode, MRR is on upper lane, while WR is on lower lane
// So MRR to WR timing should be made 1 cycle longer - else the tWTR requirement won't be met on the DRAM bus
wire [$bits(dh_gs_rd2wr)-1:0] rd2wr_int;
wire [$bits(dh_gs_rd2wr):0] rd2wr_int_wider;
wire       any_rd;
wire       any_wr;
  
// MR comand that is an MRR
wire i_mrr_cmd = gs_op_is_load_mode & (gs_pi_mrr || gs_pi_mrr_ext); 

wire       bg_timing_mode;
assign bg_timing_mode   = reg_ddrc_lpddr5 && (reg_ddrc_bank_org == {$bits(reg_ddrc_bank_org){1'b0}});

// sum of register and adjust value
assign rd2wr_int_wider = (
                          bg_timing_mode ? reg_ddrc_rd2wr_s :
                                           dh_gs_rd2wr);

assign rd2wr_int = rd2wr_int_wider[$bits(rd2wr_int)-1:0];

// detecting bypass read, CAM read and MRR
assign any_rd = 
                 gs_op_is_rd                                                         // read thru CAM
                 | i_mrr_cmd                                                // MRR
                 ;

// CAM write operations
assign any_wr = gs_op_is_wr;

//spyglass disable_block STARC05-2.11.3.1
//SMD: Combinational and sequential parts of an FSM described in same always block
//SJ: Reported for rd_block_timer and wr_block_timer. Coding style used to prevent underflow. No re-coding required.

// blocking timers
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    rd_block_timer  <= {$bits(rd_block_timer){1'b0}};
    wr_block_timer  <= {$bits(wr_block_timer){1'b0}};
    cke_timer       <= {$bits(cke_timer){1'b0}};
    ckesr_timer     <= {$bits(ckesr_timer){1'b0}};
  end
  else begin
    // read/write blocking timers
    if (any_rd) begin                                          // rd-2-rd timer is implemented in gs_rank_constraints
      wr_block_timer  <= rd2wr_int - {{($bits(rd2wr_int)-1){1'b0}},1'b1};
    end
    else if (any_wr) begin
      rd_block_timer  <= dh_gs_wr2rd - {{($bits(dh_gs_wr2rd)-1){1'b0}},1'b1};
      wr_block_timer  <= {{($bits(wr_block_timer)-$bits(dh_gs_burst_rdwr)){1'b0}}, dh_gs_burst_rdwr} - {{($bits(wr_block_timer)-1){1'b0}},1'b1};    // Assign 7 in case of BL16, 3 in case of BL8,1 in case of BL4, & 0 for BL2 i.e. burst_rdwr - 1    
    end
    else begin
      rd_block_timer  <= (rd_block_timer == {$bits(rd_block_timer){1'b0}}) ? {$bits(rd_block_timer){1'b0}} : (rd_block_timer - {{($bits(rd_block_timer)-1){1'b0}},1'b1});
      wr_block_timer  <= (wr_block_timer == {$bits(wr_block_timer){1'b0}}) ? {$bits(wr_block_timer){1'b0}} : (wr_block_timer - {{($bits(wr_block_timer)-1){1'b0}},1'b1});
    end

    // tCKE
    cke_timer    <= (enter_powerdown|enter_selfref|
          exit_powerdown |exit_selfref  ) ? dh_gs_t_cke     :
             (cke_timer != {$bits(cke_timer){1'b0}})              ? (cke_timer - {{($bits(cke_timer)-1){1'b0}},1'b1}) :
                                           {$bits(cke_timer){1'b0}}            ;

   // tCKESR
   // only for SRE
    ckesr_timer    <= (enter_selfref)       ? reg_ddrc_t_ckesr     :
             (ckesr_timer != {$bits(ckesr_timer){1'b0}}) ? (ckesr_timer - {{($bits(ckesr_timer)-1){1'b0}},1'b1}) :
                                 {$bits(ckesr_timer){1'b0}}                 ;

  end // else
//spyglass enable_block STARC05-2.11.3.1


reg  lpddr4_blk_act_cnt;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    lpddr4_blk_act_cnt <= 1'b0;
    lpddr4_blk_act_nxt <= 1'b0;
  end
  else begin
    if (dh_gs_lpddr4 & reg_ddrc_lpddr4_opt_act_timing) begin
      if (any_wr | any_rd) begin
        lpddr4_blk_act_cnt <= (dh_gs_frequency_ratio)? 1'b0 : 1'b1;
      end
      else if (lpddr4_blk_act_cnt) begin
        lpddr4_blk_act_cnt <= 1'b0;
      end

     lpddr4_blk_act_nxt <= (dh_gs_frequency_ratio)? 1'b0 : lpddr4_blk_act_cnt;

  end
end

// constraints from WRA to PDE
localparam BL_MAX_MINUS_MIN = 2;
reg   [WRA2PRE_WIDTH-1:0]  cnt_wra2pde_r;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      cnt_wra2pde_r <= {$bits(cnt_wra2pde_r){1'b0}};
   end
   else if (reg_ddrc_lpddr5 & any_wr & os_te_autopre) begin
      cnt_wra2pde_r <= reg_ddrc_wra2pre + dh_gs_t_cmdcke + 1 + (bg_timing_mode ? BL_MAX_MINUS_MIN : 0);
   end
   else if (|cnt_wra2pde_r) begin
      cnt_wra2pde_r <= cnt_wra2pde_r - 1;
   end
end

assign blk_pd_after_wra = (|cnt_wra2pde_r);




//--------------------------------- constraints for MRR/MRW --------------------------------- 

    wire bypass_rd;  // Bypass RD Command
    assign bypass_rd    = 1'b0;

   //spyglass disable_block STARC05-2.11.3.1
   //SMD: Combinational and sequential parts of an FSM described in same always block
   //SJ: Reported for mrri_timer. Coding style used to prevent underflow. No re-coding required.
   reg [$bits(dh_gs_t_rcd):0] mrri_timer; // t_xp + t_rcd is 5 bits + 5 bits => 6 bits
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
      if (~core_ddrc_rstn) begin
         mrri_timer <= {$bits(mrri_timer){1'b0}}; 
      end
      else if (exit_powerdown | exit_selfref) begin
        if(reg_ddrc_lpddr5)begin
         mrri_timer <= {{($bits(mrri_timer)-$bits(dh_gs_t_xp)){1'b0}}, dh_gs_t_xp} +
                       {{($bits(mrri_timer)-$bits(dh_gs_t_rcd)){1'b0}}, dh_gs_t_rcd} +
                       {{($bits(mrri_timer)-$bits(reg_ddrc_t_csh)){1'b0}}, reg_ddrc_t_csh};
        end else begin
         mrri_timer <= {{($bits(mrri_timer)-$bits(dh_gs_t_xp)){1'b0}}, dh_gs_t_xp} +
                       {{($bits(mrri_timer)-$bits(dh_gs_t_rcd)){1'b0}}, dh_gs_t_rcd}; 
        end
      end
      else if (mrri_timer != {$bits(mrri_timer){1'b0}}) begin
         mrri_timer <= mrri_timer - ({{($bits(mrri_timer)-1){1'b0}},1'b1});
      end

   //spyglass enable_block STARC05-2.11.3.1
   assign mrri_satisfied = (mrri_timer>0) ? 1'b0 : 1'b1;

   // RD to MRW
   reg [RD2MR_WIDTH-1:0] rd2mrw_count;
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
      if (~core_ddrc_rstn)
         rd2mrw_count <= {$bits(rd2mrw_count){1'b0}};
      else begin
         if (gs_op_is_rd || bypass_rd || i_mrr_cmd)
            rd2mrw_count <= reg_ddrc_rd2mr;
         else if (rd2mrw_count != {$bits(rd2mrw_count){1'b0}})
            rd2mrw_count <= rd2mrw_count - {{($bits(rd2mrw_count)-1){1'b0}},1'b1};
      end

   // WR to MRW
   reg [WR2MR_WIDTH-1:0] wr2mrw_count;
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
      if (~core_ddrc_rstn)
         wr2mrw_count <= {$bits(wr2mrw_count){1'b0}};
      else begin
         if (gs_op_is_wr)
            wr2mrw_count <= reg_ddrc_wr2mr;
         else if (wr2mrw_count != {$bits(wr2mrw_count){1'b0}})
            wr2mrw_count <= wr2mrw_count - {{($bits(wr2mrw_count)-1){1'b0}},1'b1};
      end

    assign rdwr2mrw_satisfied = (~(|rd2mrw_count)) & (~(|wr2mrw_count));




//--------------------------------- Assertion --------------------------------- 
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
 
  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time
  
  // rd2wr_int overflow
  assert_never #(0, 0, "rd2wr_int overflow", CATEGORY) a_rd2wr_int_overflow
    (co_yy_clk, core_ddrc_rstn, (rd2wr_int_wider[$bits(rd2wr_int_wider)-1]==1'b1));
    

  property p_lpddr4_blk_act_cnt_eq_zero;  
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
     (any_rd | any_wr) |-> (lpddr4_blk_act_cnt==0); 
  endproperty

  property p_lpddr4_blk_act_nxt_check;  
    @(posedge co_yy_clk) disable iff(!core_ddrc_rstn) 
     (dh_gs_lpddr4==0 || reg_ddrc_lpddr4_opt_act_timing==0) |-> (lpddr4_blk_act_nxt==0); 
  endproperty

  // lpddr4_blk_act_cnt==0 when rd/wr comes
  a_lpddr4_blk_act_cnt_eq_zero : assert property (p_lpddr4_blk_act_cnt_eq_zero) 
  else $display ("%0t ERROR : Design assumes lpddr4_blk_act_cnt==0 when any_rd | any_wr",$realtime);

  // lpddr4_blk_act_nxt==0 when feature is disabled
  a_lpddr4_blk_act_nxt_check : assert property (p_lpddr4_blk_act_nxt_check) 
  else $display ("%0t ERROR : When SCHED.lpddr4_opt_act_timing==0 or non-LPDDR4 mode, lpddr4_blk_act_nxt must be 0",$realtime);

  a_mrri_timer:       assert property(@(posedge co_yy_clk) disable iff (~core_ddrc_rstn) (mrri_timer[$bits(mrri_timer)-1] == 0));


`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON  

endmodule  // gs_global_constraints (global DDRC constraints)
