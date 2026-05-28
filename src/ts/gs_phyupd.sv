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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_phyupd.sv#1 $
// -------------------------------------------------------------------------
// Description:
//         This module is responsible for responding to PHY updates on DFI.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_phyupd 
import DWC_ddrctl_reg_pkg::*;
#(
//------------------------------- PARAMETERS ----------------------------------
   parameter  RANK_BITS         = `MEMC_RANK_BITS
  ,parameter  NUM_RANKS         = 1 << RANK_BITS // max # of ranks supported
  ,parameter  CS_WIDTH          = `MEMC_FREQ_RATIO * NUM_RANKS
  ,parameter  CMD_DELAY_BITS    = `UMCTL2_CMD_DELAY_BITS
  ,parameter  FREQ_RATIO        = `MEMC_FREQ_RATIO
)
(
//--------------------------- INPUTS AND OUTPUTS -------------------------------
   input                      co_yy_clk                         // clock
  ,input                      core_ddrc_rstn                    // soft reset: async, active low

  ,input                      phy_dfi_phyupd_req                // DFI PHY update request
  ,output                     ddrc_dfi_phyupd_ack               // DFI PHY update acknowledge

  ,input                      ddrc_dfi_ctrlupd_req              // DFI CTRL update request

  ,input                      reg_ddrc_dfi_phyupd_en            // Enable for DFI PHY update logic
  ,input  [DFI_T_CTRL_DELAY_WIDTH-1:0]               reg_ddrc_dfi_t_ctrl_delay         // timer value for DFI tctrl_delay
  ,input  [4:0]               gs_dfi_t_wrdata_delay_cnt         // counter value for DFI twrdata_delay

  ,input [CMD_DELAY_BITS-1:0] dfi_cmd_delay
  ,output                     gs_pi_phyupd_pause_req            // Sent to rest of uMCTL2 to tell system to pause
  ,input                      pi_gs_phyupd_pause_ok             // resonse from PI to say alright to ack PHY update request
  ,input                      dfilp_phyupd_pause_ok
  ,input                      gs_wck_stop_ok

);

//---------------------------- LOCAL PARAMETERS --------------------------------
// States
localparam ST_SIZE = 4;
localparam ST_PHYUPD_IDLE      = 4'b0001;
localparam ST_PHYUPD_PAUSE     = 4'b0010;
localparam ST_PHYUPD_CTRLDELAY = 4'b0100;
localparam ST_PHYUPD_ACK       = 4'b1000;

//-------------------------------- MAIN CODE BLOCK -----------------------------



  reg [ST_SIZE-1:0] i_st, i_st_nxt;
  
  wire i_phyupd_ctrl_wrdata_delay_cnt_eq0;
  // 
  // External input ports registered and selected
  // 

  reg                               i_dfi_phyupd_req_r;

  // Register the input pin from the dfi_phyupd_req
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: dfi_phyupd_req_r_PROC
    if (!core_ddrc_rstn) begin
      i_dfi_phyupd_req_r <= 1'b0;
    end else begin
      i_dfi_phyupd_req_r <= phy_dfi_phyupd_req;
    end
  end

  // Rising edge detection
  wire i_dfi_phyupd_req_red = ((phy_dfi_phyupd_req) && (!i_dfi_phyupd_req_r)) ? 1'b1 : 1'b0;
   
  // Falling edge detection
  wire i_dfi_phyupd_req_fed = ((!phy_dfi_phyupd_req) && (i_dfi_phyupd_req_r)) ? 1'b1 : 1'b0;


  //
  // State Machine
  // 

  // FSM sequential
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: st_seq_PROC
    if (!core_ddrc_rstn)
      i_st <= ST_PHYUPD_IDLE;
    else
      i_st <= i_st_nxt;
  end

  // FSM combinatorial
  always @(*)
  begin: st_comb_PROC
    i_st_nxt = ST_PHYUPD_IDLE;

      //ccx_fsm:;i_st;ST_PHYUPD_CTRLDELAY->ST_PHYUPD_IDLE;This is to handle behavior outside the DFI specification, hits very rarely. See Bug 8604#c11
      //ccx_fsm:;i_st;ST_PHYUPD_PAUSE->ST_PHYUPD_IDLE;This is to handle behavior outside the DFI specification, hits very rarely. See Bug 8604#c11
    case(i_st)
      ST_PHYUPD_IDLE: begin
        // if enabled via SW and external request occurs
        if (i_dfi_phyupd_req_red && reg_ddrc_dfi_phyupd_en) begin
          i_st_nxt = ST_PHYUPD_PAUSE;     
        end else begin
          i_st_nxt = ST_PHYUPD_IDLE;
        end
      end


      ST_PHYUPD_PAUSE: begin
        if (i_dfi_phyupd_req_fed) begin
          i_st_nxt = ST_PHYUPD_IDLE;
        end else if (pi_gs_phyupd_pause_ok
                     && dfilp_phyupd_pause_ok
                     && gs_wck_stop_ok
        ) begin
          i_st_nxt = ST_PHYUPD_CTRLDELAY;     
        end else begin
          i_st_nxt = ST_PHYUPD_PAUSE;
        end
      end

      // ST_PHYUPD_CTRLDELAY used to wait larger of 
      // reg_ddrc_dfi_t_ctrl_delay
      // counter that started at reg_ddrc_dfi_t_ctrl_wrdata_delay
      ST_PHYUPD_CTRLDELAY: begin
        if (i_dfi_phyupd_req_fed) begin
          i_st_nxt = ST_PHYUPD_IDLE;    
        end else if (i_phyupd_ctrl_wrdata_delay_cnt_eq0) begin     
          i_st_nxt = ST_PHYUPD_ACK; 
        end else begin
          i_st_nxt = ST_PHYUPD_CTRLDELAY;
        end
      end

      //ST_PHYUPD_ACK
      default: begin
        if (i_dfi_phyupd_req_fed) begin  
          i_st_nxt = ST_PHYUPD_IDLE;    
  end else 
        begin
          i_st_nxt = ST_PHYUPD_ACK;
        end
      end

    endcase // case(i_st)
  end // block: st_comb_PROC

  wire i_st_idle;
  wire i_st_pause;
  wire i_st_ack;

  assign i_st_idle      = (i_st==ST_PHYUPD_IDLE)      ? 1'b1 : 1'b0;
  assign i_st_pause     = (i_st==ST_PHYUPD_PAUSE)     ? 1'b1 : 1'b0;
  assign i_st_ack       = (i_st==ST_PHYUPD_ACK)       ? 1'b1 : 1'b0;

  wire i_st_nxt_ctrldelay;
  assign i_st_nxt_ctrldelay = (i_st_nxt==ST_PHYUPD_CTRLDELAY) ? 1'b1 : 1'b0;

  // 
  // counter for ctrldelay (i.e. ST_PHYUPD_ACK state max timeout)
  // 
  
  wire i_phyupd_ctrl_wrdata_delay_cnt_start;
  wire [$bits(reg_ddrc_dfi_t_ctrl_delay)-1:0] i_phyupd_ctrl_wrdata_delay_cnt;
  reg  [$bits(reg_ddrc_dfi_t_ctrl_delay):0] i_phyupd_ctrl_wrdata_delay_cnt_wider;

  // start counter if moving into CTRLDELAY state from PAUSE
  assign i_phyupd_ctrl_wrdata_delay_cnt_start = (i_st_pause && i_st_nxt_ctrldelay) ? 1'b1 : 1'b0;
  
  // use larger of gs_dfi_t_wrdata_delay_cnt or reg_ddrc_dfi_t_ctrl_delay
  wire [$bits(reg_ddrc_dfi_t_ctrl_delay)-1:0] i_phyupd_ctrl_wrdata_delay_cnt_val;
  assign i_phyupd_ctrl_wrdata_delay_cnt_val = (gs_dfi_t_wrdata_delay_cnt>reg_ddrc_dfi_t_ctrl_delay) ? gs_dfi_t_wrdata_delay_cnt : reg_ddrc_dfi_t_ctrl_delay;

  // counter
  // Started if system is paused
  // Counts down by 1 each time
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_phyupd_ctrl_wrdata_delay_cnt_PROC
    if (!core_ddrc_rstn) begin
      i_phyupd_ctrl_wrdata_delay_cnt_wider <= {$bits(i_phyupd_ctrl_wrdata_delay_cnt_wider){1'b0}};
    end else begin     
      if (i_phyupd_ctrl_wrdata_delay_cnt_start) begin
        i_phyupd_ctrl_wrdata_delay_cnt_wider <= {{($bits(i_phyupd_ctrl_wrdata_delay_cnt_wider)-$bits(i_phyupd_ctrl_wrdata_delay_cnt_val)){1'b0}},i_phyupd_ctrl_wrdata_delay_cnt_val}
                                              + {{($bits(i_phyupd_ctrl_wrdata_delay_cnt_wider)-$bits(dfi_cmd_delay)){1'b0}}, dfi_cmd_delay};
      end else if (i_phyupd_ctrl_wrdata_delay_cnt_wider>{$bits(i_phyupd_ctrl_wrdata_delay_cnt_wider){1'b0}}) begin
        i_phyupd_ctrl_wrdata_delay_cnt_wider <= i_phyupd_ctrl_wrdata_delay_cnt_wider - {{($bits(i_phyupd_ctrl_wrdata_delay_cnt_wider)-1){1'b0}},1'b1};
      end
    end
  end
  
  assign i_phyupd_ctrl_wrdata_delay_cnt = i_phyupd_ctrl_wrdata_delay_cnt_wider[$bits(i_phyupd_ctrl_wrdata_delay_cnt)-1:0];
  assign i_phyupd_ctrl_wrdata_delay_cnt_eq0 = (i_phyupd_ctrl_wrdata_delay_cnt=={$bits(i_phyupd_ctrl_wrdata_delay_cnt){1'b0}}) ? 1'b1 : 1'b0;


  //
  // Drive outputs
  //


  // A pause request is driven in all states except IDLE state
  assign gs_pi_phyupd_pause_req = ~i_st_idle;


  // ack sent in ACK state
  assign ddrc_dfi_phyupd_ack = i_st_ack && (~ddrc_dfi_ctrlupd_req);

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
 
  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

  // i_phyupd_ctrl_wrdata_delay_cnt overflow
  assert_never #(0, 0, "i_phyupd_ctrl_wrdata_delay_cnt overflow", CATEGORY) a_i_phyupd_ctrl_wrdata_delay_cnt_overflow
    (co_yy_clk, core_ddrc_rstn, (i_phyupd_ctrl_wrdata_delay_cnt_wider[$bits(i_phyupd_ctrl_wrdata_delay_cnt_wider)-1]==1'b1));
    
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON 
  
endmodule // gs_phyupd

