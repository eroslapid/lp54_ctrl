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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_dfilp.sv#3 $
// -------------------------------------------------------------------------
// Description:
//                This module is responsible for handling of DFI LP I/F
//                Performs handshaking of interface.
//                Interacts with gs_global_fsm.v when entering/exiting
//                PD/SR.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_dfilp 
import DWC_ddrctl_reg_pkg::*;
#(
   parameter    CMD_DELAY_BITS      = `UMCTL2_CMD_DELAY_BITS

  )
  (
//--------------------------- INPUTS AND OUTPUTS -------------------------------
   input                      co_yy_clk         // clock
  ,input                      core_ddrc_rstn    // reset; async, active low

  ,output                     dfi_lp_ctrl_req
  ,output [4:0]               dfi_lp_ctrl_wakeup
  ,input                      dfi_lp_ctrl_ack

  ,output                     dfi_lp_data_req
  ,output [4:0]               dfi_lp_data_wakeup
  ,input                      dfi_lp_data_ack

  ,input                                  reg_ddrc_dfi_lp_data_req_en
  ,input                                  reg_ddrc_dfi_lp_en_pd
  ,input  [DFI_LP_WAKEUP_PD_WIDTH-1:0]    reg_ddrc_dfi_lp_wakeup_pd
  ,input                                  reg_ddrc_dfi_lp_en_sr
  ,input  [DFI_LP_WAKEUP_SR_WIDTH-1:0]    reg_ddrc_dfi_lp_wakeup_sr
  ,input                                  reg_ddrc_dfi_lp_en_data
  ,input  [DFI_LP_WAKEUP_DATA_WIDTH-1:0]  reg_ddrc_dfi_lp_wakeup_data
  ,input                                  reg_ddrc_dfi_lp_en_dsm
  ,input  [DFI_LP_WAKEUP_DSM_WIDTH-1:0]   reg_ddrc_dfi_lp_wakeup_dsm

  ,input [DFI_TWCK_EN_RD_WIDTH-2:0]       mr_lp_data_rd
  ,input [DFI_TWCK_EN_WR_WIDTH-2:0]       mr_lp_data_wr
  ,input [CMD_DELAY_BITS-1:0]             dfi_cmd_delay

  // from gs_global_fsm
  ,input                      gfsm_dfilp_trig_pde
  ,input                      gfsm_dfilp_trig_pdx
  ,input                      gfsm_dfilp_trig_sre
  ,input                      gfsm_dfilp_trig_srx
  ,input                      gfsm_dfilp_trig_dsme
  ,input                      gfsm_dfilp_trig_dsmx
  ,input                      dfi_ctrlmsg_req_busy
  ,input                      gs_op_is_rd
  ,input                      gs_op_is_wr
  ,input                      ctrlupd_req
  ,input                      gs_pi_phyupd_pause_req
  ,input                      phy_dfi_init_complete
  ,input                      gs_pi_op_is_load_mr_norm
  ,input                      gs_pi_mrr
  ,input                      gs_pi_mrr_ext
  ,input [DFI_T_WRDATA_DELAY_WIDTH-1:0]   reg_ddrc_dfi_t_wrdata_delay
  ,input                      gs_pi_wr_data_pipeline_empty
  ,input                      gs_pi_rd_data_pipeline_empty

  ,output                     dfilp_pde_done
  ,output                     dfilp_pde_aborted
  ,output                     dfilp_pdx_done
  ,output                     dfilp_pdx_aborted
  ,output                     dfilp_sre_done
  ,output                     dfilp_sre_aborted
  ,output                     dfilp_srx_done
  ,output                     dfilp_ctrlupd_ok
  ,output                     dfilp_phyupd_pause_ok
  ,output                     dfilp_dsme_done
  ,output                     dfilp_dsme_aborted
  ,output                     dfilp_dsmx_done
  ,input                      dfi_ctrlmsg_req
  ,output                     dfilp_block_dfi_ctrlmsg
  ,output                     dfilp_active

  ,input  [DFI_TLP_RESP_WIDTH-1:0]     reg_ddrc_dfi_tlp_resp
  ,input  [DFI_T_CTRL_DELAY_WIDTH-1:0] reg_ddrc_dfi_t_ctrl_delay
  ,input  [4:0]               gs_dfi_t_wrdata_delay_cnt
  ,input  [DFI_T_DRAM_CLK_ENABLE_WIDTH-1:0]  reg_ddrc_dfi_t_dram_clk_enable
  ,input  [T_CKSRE_WIDTH-1:0] reg_ddrc_t_cksre
  ,input  [T_CKSRX_WIDTH-1:0] reg_ddrc_t_cksrx
  ,input  [T_CKCSX_WIDTH-1:0] reg_ddrc_t_ckcsx
  ,input                      reg_en_dfi_dram_clk_disable
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep the current coding style for now.
  ,input  [1:0]               stop_clk_type
//spyglass enable_block W240
  ,input                      pi_gs_dfilp_wait
  ,input                      gs_pi_odt_pending
  ,input                      gs_phymstr_clr_lp_req
  ,input                      gs_phymstr_mask_dfilp
  ,output                     st_lp_e_ack_check
  ,output                     dfilp_ctrl_lp
);

//---------------------------- LOCAL PARAMETERS --------------------------------

localparam LP_CNTW_X = 19; // tlp_wakeup is upto 262144 = 2^18 => 19 bits to count

localparam ST_SIZE = 6;
localparam ST_INIT            = 6'b000001;
localparam ST_LP_E_CTRLDELAY  = 6'b000010;
localparam ST_LP_E_ACK_CHECK  = 6'b000100;
localparam ST_LP_WAIT         = 6'b001000;
localparam ST_LP_X_WAKEUP_CNT = 6'b010000;
localparam ST_LP_SUSPEND      = 6'b100000;

// this needs to be large enough to hold the sum of registers that set i_lp_entry_trig_sel
localparam LP_ENTRY_TRIG_SIZE   = CMD_DELAY_BITS + 1;
localparam LP_ENTRY_TRIG_REGS_X = 1<<LP_ENTRY_TRIG_SIZE;
localparam LP_ENTRY_TRIG_REGS   = LP_ENTRY_TRIG_REGS_X + 2;

localparam ST_LPD_INIT           = 3'd0;
localparam ST_LPD_ENTRY          = 3'd1;
localparam ST_LPD_ACK            = 3'd2;
localparam ST_LPD_WAKEUP         = 3'd3;
localparam ST_LPD_SUSPEND        = 3'd4;
localparam ST_LPD_WAIT_CMD_DLY   = 3'd5;

//------------------------------ WIRES AND REGISTERS ---------------------------

// drive unconnected inputs to all zeros so that internal logic does not require
// `ifdef
wire       gfsm_dfilp_trig_mpsme       = 1'b0;
wire       gfsm_dfilp_trig_mpsmx       = 1'b0;

// output ports do not exist - declare as wire
wire       dfilp_mpsme_done_unused;
wire       dfilp_mpsme_aborted_unused;
wire       dfilp_mpsmx_done_unused;



wire       st_init;
wire       st_lp_e_ctrldelay;
wire       st_lp_wait;
wire       st_lp_x_wakeup_cnt;
wire       st_lp_suspend;
wire       st_nxt_lp_e_ack_check;

reg                              dfilp_data_req_r;
reg  [4:0]                       dfilp_data_wakeup_r;
wire                             dfilp_data_req_deassert;
wire                             dfilp_data_req_assert;
reg  [DFI_TWCK_EN_RD_WIDTH-2:0]  cnt_data_req_deassert_tmg_r;
wire                             data_pipeline_empty;
reg                              data_pipeline_empty_r;
reg [DFI_T_WRDATA_DELAY_WIDTH-1:0]  cnt_t_wrdata_delay_r;

wire                             bypass_rd;
wire                             op_is_mrr;


logic    [2:0]                   lp_data_state_r;
logic    [2:0]                   lp_data_state_next;

logic                            lp_data_entry;
logic                            lp_data_end;
logic                            lp_data_no_resp;
logic                            lp_data_suspend_req;
logic                            lp_data_wakeup_end;
logic                            lp_data_re_entry;

logic    [DFI_TLP_RESP_WIDTH:0]  cnt_lp_data_resp_r;
logic                            lp_data_wakeup_dly_r;
logic                            dfi_lp_data_ack_r;
logic                            lp_data_normal_r;

logic                            cmd_dly_eq0;
logic    [CMD_DELAY_BITS-1:0]    cnt_cmd_delay_r;
logic                            cnt_cmd_dly_eq0;

//-------------------------------- MAIN CODE BLOCK -----------------------------

  // ==================================================================
  // Register input signal dfi_lp_ctrl_ack before using it
  // ==================================================================
  reg i_dfi_lp_ctrl_ack_r;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_dfi_lp_ctrl_ack_r_PROC
    if (!core_ddrc_rstn) begin
      i_dfi_lp_ctrl_ack_r <= {$bits(i_dfi_lp_ctrl_ack_r){1'b0}};
    end else begin
      i_dfi_lp_ctrl_ack_r <= dfi_lp_ctrl_ack;
    end
  end

  wire i_reg_dfi_out;

  // Edge detection
  wire i_dfi_lp_ctrl_ack_fed = (!dfi_lp_ctrl_ack &&  i_dfi_lp_ctrl_ack_r) ? 1'b1 : 1'b0;

  assign dfilp_ctrl_lp = st_lp_e_ctrldelay | st_lp_e_ack_check | st_lp_wait | st_lp_suspend | i_dfi_lp_ctrl_ack_r;

  wire i_lp_en_pd   = reg_ddrc_dfi_lp_en_pd;
  wire i_lp_en_sr   = reg_ddrc_dfi_lp_en_sr;
  wire [$bits(reg_ddrc_dfi_lp_wakeup_sr)-1:0] i_lp_wakeup_sr;
  assign i_lp_wakeup_sr        = reg_ddrc_dfi_lp_wakeup_sr;
  wire [$bits(reg_ddrc_dfi_lp_wakeup_pd)-1:0] i_lp_wakeup_pd;
  assign i_lp_wakeup_pd        = reg_ddrc_dfi_lp_wakeup_pd;

  wire i_lp_en_mpsm = 1'b0;
  wire [3:0] i_lp_wakeup_mpsm;
  assign i_lp_wakeup_mpsm      = {$bits(i_lp_wakeup_mpsm){1'b0}};

  wire i_lp_en_dsm = reg_ddrc_dfi_lp_en_dsm;
  wire [$bits(reg_ddrc_dfi_lp_wakeup_dsm)-1:0] i_lp_wakeup_dsm;
  assign i_lp_wakeup_dsm      = reg_ddrc_dfi_lp_wakeup_dsm;

  // make counter value 6 bits wide to allow programming maximum value for reg_ddrc_dfi_tlp_resp and avoid
  // overflow when i_reg_dfi_out | dfi_cmd_delay
  wire [$bits(reg_ddrc_dfi_tlp_resp):0] i_lp_tlp_resp_cnt_val;
  assign i_lp_tlp_resp_cnt_val = {{($bits(i_lp_tlp_resp_cnt_val)-$bits(reg_ddrc_dfi_tlp_resp)){1'b0}}, reg_ddrc_dfi_tlp_resp} + {{($bits(i_lp_tlp_resp_cnt_val)-$bits(i_reg_dfi_out)){1'b0}},i_reg_dfi_out}
                                 + {{($bits(i_lp_tlp_resp_cnt_val)-$bits(dfi_cmd_delay)){1'b0}},dfi_cmd_delay};

  
  wire i_lp_entry_trig_red;
  
  wire i_lp_tlp_resp_cnt_zero_red;
  wire i_lp_exit_trig_red;
  wire i_lp_clk_en_cnt_zero;
  wire i_lp_tlp_wakeup_cnt_zero;
  wire i_lp_dfitctrldelay_cnt_eq0;
  wire i_lp_entry_trig_int;
  wire lp_suspend_req;
  reg  lp_suspend_req_r;

  reg [ST_SIZE-1:0] st_cgn, st_nxt;
 
  integer i; // for loop index
 
  // FSM sequential
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: st_seq_PROC
    if (!core_ddrc_rstn)
      st_cgn <= ST_INIT;
    else
      st_cgn <= st_nxt;
  end

  // FSM combinatorial
  always @(*)
  begin: st_comb_PROC
    st_nxt = ST_INIT;

    case(st_cgn)
      ST_INIT: begin
  if (i_lp_entry_trig_red) begin
          st_nxt = ST_LP_E_CTRLDELAY;      
  end else begin
          st_nxt = ST_INIT;
  end
      end

      // ST_LP_E_CTRLDELAY used to wait larger of 
      // reg_ddrc_dfi_t_ctrl_delay
      // reg_ddrc_dfi_t_ctrl_wrdata_delay counter value
      ST_LP_E_CTRLDELAY: begin
  // LP request is cleared by PHY Master request
  if (gs_phymstr_clr_lp_req | gs_phymstr_mask_dfilp) begin
          st_nxt = ST_INIT;
  end else if (i_lp_dfitctrldelay_cnt_eq0) begin
      if (lp_suspend_req) begin 
          st_nxt = ST_LP_SUSPEND;
      end else begin
          st_nxt = ST_LP_E_ACK_CHECK;
      end
  end else begin
          st_nxt = ST_LP_E_CTRLDELAY;
  end
      end

      
      ST_LP_E_ACK_CHECK: begin
   if (i_lp_tlp_resp_cnt_zero_red) begin    
     if (dfi_lp_ctrl_ack) begin
             st_nxt = ST_LP_WAIT;
     end else begin
             st_nxt = ST_INIT;  
     end
   end else begin
           st_nxt = ST_LP_E_ACK_CHECK;
   end
       end

       ST_LP_WAIT: begin
   // ST_LP_WAIT is exited when a LP Exit trigger comes, or when we have a PHY Master request
   if (i_lp_exit_trig_red | gs_phymstr_clr_lp_req) begin
           st_nxt = ST_LP_X_WAKEUP_CNT;    
   end else if (lp_suspend_req) begin
           st_nxt = ST_LP_SUSPEND;
   end else begin
           st_nxt = ST_LP_WAIT;
   end
       end
 
       ST_LP_X_WAKEUP_CNT: begin
   if (i_lp_tlp_wakeup_cnt_zero & i_lp_clk_en_cnt_zero 
       ) begin
           st_nxt = ST_INIT;
   end else begin
           st_nxt = ST_LP_X_WAKEUP_CNT;
   end
      end

       ST_LP_SUSPEND: begin
   if (i_lp_exit_trig_red | gs_phymstr_clr_lp_req) begin
           st_nxt = ST_LP_X_WAKEUP_CNT;    
   end else if (!lp_suspend_req &
                (i_lp_tlp_wakeup_cnt_zero & i_lp_clk_en_cnt_zero)) begin
           st_nxt = ST_LP_E_ACK_CHECK;
   end else begin
           st_nxt = ST_LP_SUSPEND;
   end
      end

       default: st_nxt = ST_INIT;
     endcase // case(st_cgn)
   end // block: st_comb_PROC

   wire st_change = (st_nxt != st_cgn) ? 1'b1 : 1'b0;
 
   assign st_init              = (st_cgn==ST_INIT)            ? 1'b1 : 1'b0;
   assign st_lp_e_ctrldelay    = (st_cgn==ST_LP_E_CTRLDELAY)  ? 1'b1 : 1'b0;
   assign st_lp_e_ack_check    = (st_cgn==ST_LP_E_ACK_CHECK)  ? 1'b1 : 1'b0;
   assign st_lp_wait           = (st_cgn==ST_LP_WAIT)         ? 1'b1 : 1'b0;
   assign st_lp_x_wakeup_cnt   = (st_cgn==ST_LP_X_WAKEUP_CNT) ? 1'b1 : 1'b0;
   assign st_lp_suspend        = (st_cgn==ST_LP_SUSPEND)      ? 1'b1 : 1'b0;
    
   wire st_nxt_lp_e_ctrldelay  = (st_nxt==ST_LP_E_CTRLDELAY)  ? 1'b1 : 1'b0;
   assign st_nxt_lp_e_ack_check= (st_nxt==ST_LP_E_ACK_CHECK)  ? 1'b1 : 1'b0;
   wire st_nxt_lp_wait         = (st_nxt==ST_LP_WAIT)         ? 1'b1 : 1'b0;
   wire st_nxt_lp_suspend      = (st_nxt==ST_LP_SUSPEND)      ? 1'b1 : 1'b0;

   // delayed request to suspend DFI LP
  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (!core_ddrc_rstn) begin
      lp_suspend_req_r <= 1'b0;
    end
    else begin
      lp_suspend_req_r <= (ctrlupd_req | gs_pi_phyupd_pause_req | dfi_ctrlmsg_req_busy);
    end
  end

   // when ctrlupd or phyupd is required, dfi_lp needs to stop.
   assign lp_suspend_req = (lp_suspend_req_r | ctrlupd_req | gs_pi_phyupd_pause_req | dfi_ctrlmsg_req_busy);
   //output to dfi_ctrlmsg to block ctrlmsg request since dfilp is active except during ST_LP_SUSPEND/ST_INIT state 
   assign dfilp_block_dfi_ctrlmsg = ~st_init & ~st_lp_suspend;

   // output to gsm_fsm to say DFI LP I/F is active
   // used for PDX/SRX in gs_global_fsm.v to know whether to know if
   // EX_DFILP states required or not
   assign dfilp_active = ~st_init;
   
   // low power entry triggers only used if enabled by software
   // - SR trigger is disabled while the PHY is the master of the SDRAM
   wire i_lp_entry_trig_sr_int   = (i_lp_en_sr & ~gs_phymstr_mask_dfilp) ? gfsm_dfilp_trig_sre   : 1'b0;
   wire i_lp_entry_trig_pd_int   = (i_lp_en_pd)   ? gfsm_dfilp_trig_pde   : 1'b0;
   wire i_lp_entry_trig_mpsm_int = (i_lp_en_mpsm) ? gfsm_dfilp_trig_mpsme : 1'b0;
   wire i_lp_entry_trig_dsm_int  = (i_lp_en_dsm)  ? gfsm_dfilp_trig_dsme  : 1'b0;
   
   // combine PD and SR into one bit
   assign i_lp_entry_trig_int = i_lp_entry_trig_sr_int | i_lp_entry_trig_pd_int | i_lp_entry_trig_mpsm_int | i_lp_entry_trig_dsm_int;

   // register to store if trigger of DFI LP i/f was self Refresh
   reg i_lp_entry_trig_sr_int_stored;
   always @(posedge co_yy_clk or negedge core_ddrc_rstn)
   begin: i_lp_entry_trig_sr_int_stored_PROC
     if (!core_ddrc_rstn) begin
       i_lp_entry_trig_sr_int_stored <= {$bits(i_lp_entry_trig_sr_int_stored){1'b0}};
     end else begin
       if (i_lp_entry_trig_int) begin
         i_lp_entry_trig_sr_int_stored <= i_lp_entry_trig_sr_int;
       end
     end
   end

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(i - 1)'/'(i + 2)' found in module 'gs_dfilp'
//SJ: This coding style is acceptable and there is no plan to change it.

  // registering of the trigger
  // Upto LP_ENTRY_TRIG_REGS delays
  //i_lp_entry_trig_int_r[0] = i_lp_entry_trig_int
  // selected delay depends on registering stages on DFI
  reg i_lp_entry_trig_int_r[LP_ENTRY_TRIG_REGS-1:0];
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_entry_trig_int_r_PROC
    if (!core_ddrc_rstn) begin
      for (i=0; i<LP_ENTRY_TRIG_REGS; i=i+1) begin
        i_lp_entry_trig_int_r[i] <= 1'b0;
      end 
    end else begin
      // reset shift-register if DFI LP is masked due to PHY Master
      if (gs_phymstr_mask_dfilp) begin
         for (i=0; i<LP_ENTRY_TRIG_REGS; i=i+1) begin
            i_lp_entry_trig_int_r[i] <= 1'b0;
         end
      end else begin
         i_lp_entry_trig_int_r[0] <= i_lp_entry_trig_int;
         for (i=1; i<LP_ENTRY_TRIG_REGS; i=i+1) begin
            i_lp_entry_trig_int_r[i] <= i_lp_entry_trig_int_r[i-1];
         end
      end
    end
  end

  assign i_reg_dfi_out = 1'b1;
  // Select between which register is used to trigger
  // r3 is base, due to delay between GS to DFI
  // Add 1 for each of following:
  // - staggering of CS for DIMMS (dh_gs_dimm_stagger_cs_en)
  // - DFI outputs registered in dfi.v (REG_DFI_OUT)
  // - ECC enabled in HW and SW (MEMC_ECC_SUPPORT=1 && reg_ddrc_ecc_mode==3'b100 && reg_ddrc_test_mode==0)
  // 
  wire [LP_ENTRY_TRIG_SIZE-1:0] i_lp_entry_trig_sel;

  assign i_lp_entry_trig_sel = {{(LP_ENTRY_TRIG_SIZE-1){1'b0}}, i_reg_dfi_out}
                               + {{(LP_ENTRY_TRIG_SIZE-CMD_DELAY_BITS){1'b0}},dfi_cmd_delay};


  reg [LP_ENTRY_TRIG_REGS_X-1:0] i_lp_entry_trig_sel_x;
  always @(*) begin : i_lp_entry_trig_sel_x_PROC
    for (i=0; i<LP_ENTRY_TRIG_REGS_X; i=i+1) begin
      i_lp_entry_trig_sel_x[i] = i_lp_entry_trig_int_r[i+2];
    end
  end
//spyglass enable_block SelfDeterminedExpr-ML

  // Select which delayed version to used depending on 
  // if RDIMM support enable and/or adjust by one due to use of registered
  // DCU outputs
  wire i_lp_entry_trig = i_lp_entry_trig_sel_x[i_lp_entry_trig_sel];
   
  // register
  reg i_lp_entry_trig_r;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_entry_trig_r_PROC
    if (!core_ddrc_rstn) begin
      i_lp_entry_trig_r <= {$bits(i_lp_entry_trig_r){1'b0}};
    end else if (i_lp_entry_trig_red | gs_phymstr_clr_lp_req | gs_phymstr_mask_dfilp) begin     
      i_lp_entry_trig_r <= 1'b0;
    end else if (i_lp_entry_trig) begin     
      i_lp_entry_trig_r <= 1'b1;
    end
  end


  // rising edge dectection
  // Used by state m/c
  assign i_lp_entry_trig_red = (i_lp_entry_trig | i_lp_entry_trig_r) &
                               (~reg_en_dfi_dram_clk_disable | ~pi_gs_dfilp_wait
                               );
   
  wire i_lp_resp_cnt_start   = (st_change && (st_lp_e_ctrldelay || st_lp_suspend)) ? 1'b1 : 1'b0;
  wire i_lp_wakeup_cnt_start = (st_change && st_lp_wait) ? 1'b1 : 1'b0;
   

  // SRE is done once LP_E_ACK_CHECK is complete
  assign dfilp_sre_done = (st_change && st_lp_e_ack_check) ? 1'b1 : 1'b0;
  
  // SRE is aborted if PHY Master request comes while waiting dfi_t_ctrl_delay
  assign dfilp_sre_aborted = gs_phymstr_clr_lp_req | gs_phymstr_mask_dfilp;
  
  // SRX is done if either:
  // - LP_X_WAKEUP_CNT is complete or 
  // - ST_E_LP_ACK_CHECK is done and moving to INIT (ie.e Low Power mode
  //   request ignored by PHY)
  wire   i_dfilp_srx_done_a = (st_change && st_lp_x_wakeup_cnt) ? 1'b1 : 1'b0;
  wire   i_dfilp_srx_done_b = (st_nxt==ST_INIT) ? dfilp_sre_done : 1'b0;
  assign dfilp_srx_done = i_dfilp_srx_done_a | i_dfilp_srx_done_b;

  // PDE/PDX done signals are same as SRE/SRX as only one of SR/PD ever done
  assign dfilp_pde_done = dfilp_sre_done;
  assign dfilp_pdx_done = dfilp_srx_done;
  
  assign dfilp_pde_aborted = dfilp_sre_aborted;
  
  // DFI LP PD exit is aborted if both:
  // - DFI LP is blocked by PHY Master request
  // - FSM next/current state is ST_LP_E_CTRLDELAY 
  assign dfilp_pdx_aborted = (gs_phymstr_clr_lp_req | gs_phymstr_mask_dfilp) & 
                             (st_nxt_lp_e_ctrldelay | st_lp_e_ctrldelay);
 
  // MPSME/MPSMX done signals are same as SRE/SRX as only one of SR/PD/MPSM ever done  
  assign dfilp_mpsme_done_unused = dfilp_sre_done;
  assign dfilp_mpsmx_done_unused = dfilp_srx_done;
  assign dfilp_mpsme_aborted_unused = dfilp_sre_aborted;
  
  // DSME/DSMX done signals are same as SRE/SRX as only one of SR/PD/MPSM ever done  
  assign dfilp_dsme_done = dfilp_sre_done;
  assign dfilp_dsmx_done = dfilp_srx_done;
  assign dfilp_dsme_aborted = dfilp_sre_aborted;
  

  
  // exit trig can be generated from OR of  PD and SR as they will only 
  // occur (gfsm_dfilp_trig_srx or gfsm_dfilp_trig_pdx) if on PDE/SRE, they were set
  wire i_lp_exit_trig_int = gfsm_dfilp_trig_srx   | gfsm_dfilp_trig_pdx   |
                            gfsm_dfilp_trig_mpsmx | gfsm_dfilp_trig_dsmx |
                            (~i_lp_en_sr & i_lp_entry_trig_sr_int_stored);

  //wire i_lp_exit_trig   = (!st_lp_e_ack_check) ? i_lp_exit_trig_int : 1'b0;
  
  // register
  reg i_lp_exit_trig_r;
  //always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  //begin: i_lp_exit_trig_r_PROC
  //  if (!core_ddrc_rstn) begin
  //    i_lp_exit_trig_r <= {$bits(i_lp_exit_trig_r){1'b0}};
  //  end else begin     
  //    i_lp_exit_trig_r <= i_lp_exit_trig;
  //  end
  //end 
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_exit_trig_r_PROC
    if (!core_ddrc_rstn) begin
      i_lp_exit_trig_r <= 1'b0;
    end else if (i_lp_exit_trig_red | st_init) begin     
      i_lp_exit_trig_r <= 1'b0;
    end else if (i_lp_exit_trig_int) begin     
      i_lp_exit_trig_r <= 1'b1;
    end
  end 

  // rising edge detection
  // Used by state machine
  //assign i_lp_exit_trig_red = (i_lp_exit_trig && (!i_lp_exit_trig_r)) ? 1'b1 : 1'b0; 
  assign i_lp_exit_trig_red = (i_lp_exit_trig_int || i_lp_exit_trig_r) &&
                              ((st_cgn == ST_LP_WAIT) || (st_cgn == ST_LP_SUSPEND));
 
  // counts tlp_resp
  // adjusts length of count if DFI command channel is registered
  reg [$bits(reg_ddrc_dfi_tlp_resp):0] i_lp_tlp_resp_cnt;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_tlp_resp_cnt_PROC
    if (!core_ddrc_rstn) begin
      i_lp_tlp_resp_cnt <= {$bits(i_lp_tlp_resp_cnt){1'b0}};
    end else begin
      if (i_lp_resp_cnt_start) begin
        i_lp_tlp_resp_cnt <= {{($bits(i_lp_tlp_resp_cnt)-$bits(i_lp_tlp_resp_cnt_val)){1'b0}},i_lp_tlp_resp_cnt_val};
      end else if (i_lp_tlp_resp_cnt > {$bits(i_lp_tlp_resp_cnt){1'b0}}) begin
        i_lp_tlp_resp_cnt <= i_lp_tlp_resp_cnt - {{($bits(i_lp_tlp_resp_cnt)-1){1'b0}},1'b1};
      end
    end
  end
  
  // resp_cnt has reached zero
  wire i_lp_tlp_resp_cnt_zero = (i_lp_tlp_resp_cnt=={$bits(i_lp_tlp_resp_cnt){1'b0}}) ? 1'b1 : 1'b0;
  
  // registered version
  reg  i_lp_tlp_resp_cnt_zero_r;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_tlp_resp_cnt_zero_r_PROC
    if (!core_ddrc_rstn) begin
      i_lp_tlp_resp_cnt_zero_r <= {$bits(i_lp_tlp_resp_cnt_zero_r){1'b0}};
    end else begin
      
      i_lp_tlp_resp_cnt_zero_r <= i_lp_tlp_resp_cnt_zero;
    end
  end
  
  // rising edge detection
  // Used by state machine
  assign i_lp_tlp_resp_cnt_zero_red = (i_lp_tlp_resp_cnt_zero && (!i_lp_tlp_resp_cnt_zero_r)) ? 1'b1 : 1'b0;

  // Select between power down or self refresh or deep power down wakeup value
  wire [$bits(i_lp_wakeup_sr)-1:0] i_dfi_lp_wakeup_sel_mux;
  assign i_dfi_lp_wakeup_sel_mux = (i_lp_entry_trig_sr_int)   ? i_lp_wakeup_sr   :
                                   (i_lp_entry_trig_mpsm_int) ? i_lp_wakeup_mpsm :
                                   (i_lp_entry_trig_dsm_int)  ? i_lp_wakeup_dsm  :
                                                                i_lp_wakeup_pd;


  // Set when i_lp_entry_trig_int occurs, so as to be inline with mux
  // selection on i_dfi_lp_wakeup_sel_mux
  // Slightliy earlier than when dfi_lp_ctrl_req occurs, but ok as state change
  // will occur
  wire [$bits(i_dfi_lp_wakeup_sel_mux)-1:0] i_dfi_lp_wakeup_sel;
  
  // wakeup selection is dependent on whether SR caused entry, 
  // or PD caused entry
  reg [$bits(i_dfi_lp_wakeup_sel)-1:0] i_dfi_lp_wakeup_sel_r;

  // register value
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_dfi_lp_wakeup_sel_r_PROC
    if (!core_ddrc_rstn) begin
      i_dfi_lp_wakeup_sel_r <= {$bits(i_dfi_lp_wakeup_sel_r){1'b0}};
    end else begin    
      i_dfi_lp_wakeup_sel_r <= i_dfi_lp_wakeup_sel;
    end
  end

  assign i_dfi_lp_wakeup_sel = (i_lp_entry_trig_int) ? i_dfi_lp_wakeup_sel_mux : i_dfi_lp_wakeup_sel_r;

  // infinite wakeup mode selected if all ones
  wire i_dfi_lp_wakeup_inf = &i_dfi_lp_wakeup_sel;

  // counter set to 2^(i_dfi_lp_wakeup_sel) 
  // Gotten by shifting to right 16 by wakeup 4 bit value and subtracting
  // one from it
  wire [LP_CNTW_X-1:0] i_lp_tlp_wakeup_cnt_val_int;
  assign i_lp_tlp_wakeup_cnt_val_int = ({{(LP_CNTW_X-1){1'b0}},1'b1} << i_dfi_lp_wakeup_sel) - 1;

  // value to count in wakeup counter:
  // in infinite mode, counter set to 1 and does not decrement
  // else, counter set to 2^(i_dfi_lp_wakeup_sel+4)
  wire [LP_CNTW_X-1:0] i_lp_tlp_wakeup_cnt_val;
  assign i_lp_tlp_wakeup_cnt_val = (i_dfi_lp_wakeup_inf) ? ({{LP_CNTW_X-1{1'b0}}, 1'b1}) : i_lp_tlp_wakeup_cnt_val_int;
  
  // - Counter uses programmed/selected wakeup cnt val
  // count value is adjusted by an extra cycle if DFI 
  // command channel has extra register on it
  // - counter reset to zero if dfi_lp_ctrl_ack goes low
  // - counter does not decrement if in infinite mode
  // - counter decrments by one if not already zero (as long as
  //   dfi_lp_wakeup!=4'b1111)
  reg [LP_CNTW_X-1:0] i_lp_tlp_wakeup_cnt;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_tlp_wakeup_cnt_PROC
    if (!core_ddrc_rstn) begin
      i_lp_tlp_wakeup_cnt <= {LP_CNTW_X{1'b0}};
    end else begin
      if (i_lp_wakeup_cnt_start) begin
        i_lp_tlp_wakeup_cnt <= i_lp_tlp_wakeup_cnt_val;
      end else if (i_dfi_lp_ctrl_ack_fed) begin
        i_lp_tlp_wakeup_cnt <= {LP_CNTW_X{1'b0}};
      end else if (i_lp_tlp_wakeup_cnt > 0) begin
        if (!i_dfi_lp_wakeup_inf) begin
          i_lp_tlp_wakeup_cnt <= i_lp_tlp_wakeup_cnt - 1;
        end
      end
    end
  end
  
  // flags that wakeup_cnt has reached zero
  assign i_lp_tlp_wakeup_cnt_zero = (i_lp_tlp_wakeup_cnt==0) ? 1'b1 : 1'b0;
  
  // select amount of time CK is maintained as a valid clock before exiting power saving mode
  // - t_cksrx for SR/MPSM (tCKMPX value is the same as tCKSRX)
  // - t_cksrx(t_ckpdx) for PD
  wire [$bits(reg_ddrc_t_cksrx)-1:0] i_t_ckx_sel;
  assign i_t_ckx_sel = 
                                    (stop_clk_type==2'b01) ? {{($bits(i_t_ckx_sel)-$bits(reg_ddrc_t_cksrx)){1'b0}},reg_ddrc_t_cksrx}  :
                                    (stop_clk_type==2'b11) ? {{($bits(i_t_ckx_sel)-$bits(reg_ddrc_t_ckcsx)){1'b0}},reg_ddrc_t_ckcsx}  :
                                    {{($bits(i_t_ckx_sel)-$bits(reg_ddrc_t_cksrx)){1'b0}},reg_ddrc_t_cksrx};
  
   // dfi_t_dram_clk_enable + t_cksrx/                                 
   wire [$bits(i_t_ckx_sel):0] i_lp_clk_en_cnt_val;
   assign i_lp_clk_en_cnt_val = {{($bits(i_lp_clk_en_cnt_val)-$bits(reg_ddrc_dfi_t_dram_clk_enable)){1'b0}}, reg_ddrc_dfi_t_dram_clk_enable} + {{($bits(i_lp_clk_en_cnt_val)-$bits(i_t_ckx_sel)){1'b0}}, i_t_ckx_sel};

  // clock enable counter, used to make sure that all timing parameters are satisfied before re-enabling clock;
  // used to delay wakeup if wakeup counter expires but the timing requirements are not satisfied 
  // - counter is set when entering LP_WAIT state
  // - counter decrments by one if not already zero 
  reg [$bits(i_lp_clk_en_cnt_val)-1:0] i_lp_clk_en_cnt;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_clk_en_cnt_PROC
    if (!core_ddrc_rstn) begin
      i_lp_clk_en_cnt <= {$bits(i_lp_clk_en_cnt_val){1'b0}};
    end else begin
      if (i_lp_wakeup_cnt_start) begin
        i_lp_clk_en_cnt <= i_lp_clk_en_cnt_val;
      end else if (i_lp_clk_en_cnt > {$bits(i_lp_clk_en_cnt_val){1'b0}}) begin
       i_lp_clk_en_cnt <= i_lp_clk_en_cnt - {{($bits(i_lp_clk_en_cnt_val)-1){1'b0}},1'b1};
      end
    end
  end
  

  // flags that wakeup_cnt has reached zero
  assign i_lp_clk_en_cnt_zero = (i_lp_clk_en_cnt==0) ? 1'b1 : 1'b0;

  // flag that indicate that i_lp_dfitctrldelay_cnt can be loaded
  wire i_lp_dfitctrldelay_cnt_load = (st_change) ? st_nxt_lp_e_ctrldelay : 1'b0; 

  // select amount of time CK is maintained as a valid clock after entering power saving mode :  
  // - t_cksre for SR/MPSM (for MPSM tCKMPE is required - satisfied by counter in gs_load_mr; gs_pi_stop_clk_type in gs_global_fsm is set 
  //   to 0 for MPSM like in the case of SR, so there is an extra tCKSRE which does not affect performance
  // - t_cksre(t_ckpde) for PD
  wire [$bits(reg_ddrc_t_cksre)-1:0] i_t_cke_sel;
  assign i_t_cke_sel = 
                                    (stop_clk_type==2'b01) ? {{($bits(i_t_cke_sel)-$bits(reg_ddrc_t_cksre)){1'b0}},reg_ddrc_t_cksre}  :
                                    (stop_clk_type==2'b11) ? {($bits(i_t_cke_sel)){1'b0}}                 :
                                    {{($bits(i_t_cke_sel)-$bits(reg_ddrc_t_cksre)){1'b0}},reg_ddrc_t_cksre};
                                    
  // dfi_t_ctrl_delay + t_cksre
  wire [7:0] i_lp_dfitctrldelay_cnt_add;
  assign i_lp_dfitctrldelay_cnt_add = {{($bits(i_lp_dfitctrldelay_cnt_add)-$bits(reg_ddrc_dfi_t_ctrl_delay)){1'b0}}, reg_ddrc_dfi_t_ctrl_delay} + {{($bits(i_lp_dfitctrldelay_cnt_add)-$bits(i_t_cke_sel)){1'b0}}, i_t_cke_sel};
  
  // use larger of gs_dfi_t_wrdata_delay_cnt or i_lp_dfitctrldelay_cnt_add
  wire [7:0] i_lp_dfitctrldelay_cnt_val;
  assign i_lp_dfitctrldelay_cnt_val = ({3'b000, gs_dfi_t_wrdata_delay_cnt} > i_lp_dfitctrldelay_cnt_add) ? {3'b000, gs_dfi_t_wrdata_delay_cnt} : i_lp_dfitctrldelay_cnt_add; 

  // avoid underflow
  wire [7:0] i_lp_dfitctrldelay_cnt_val_m1;
  assign i_lp_dfitctrldelay_cnt_val_m1 = (i_lp_dfitctrldelay_cnt_val > 0) ? (i_lp_dfitctrldelay_cnt_val - 1): 0;
  
  // counter used to delay entering LP - used to make sure timing requirements are satisfied
  reg [7:0] i_lp_dfitctrldelay_cnt;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_lp_dfitctrldelay_cnt_PROC
    if (!core_ddrc_rstn) begin
      i_lp_dfitctrldelay_cnt <= {$bits(i_lp_dfitctrldelay_cnt){1'b0}};
    end else begin
      // load counter value
      if (i_lp_dfitctrldelay_cnt_load) begin
        i_lp_dfitctrldelay_cnt <= i_lp_dfitctrldelay_cnt_val_m1;
      // decrement counter if value is loaded and ODT not pending
      end else if (|i_lp_dfitctrldelay_cnt & ~(gs_pi_odt_pending| dfi_ctrlmsg_req )) begin
        i_lp_dfitctrldelay_cnt <= i_lp_dfitctrldelay_cnt - 1;
      // delay decrement if ODT pending
      end else if (|i_lp_dfitctrldelay_cnt & (gs_pi_odt_pending| dfi_ctrlmsg_req)) begin
         i_lp_dfitctrldelay_cnt <= i_lp_dfitctrldelay_cnt;
      end else begin
        i_lp_dfitctrldelay_cnt <= {$bits(i_lp_dfitctrldelay_cnt){1'b0}};
      end
    end
  end

  // flags that i_lp_dfitctrldelay_cnt has reached zero
  assign i_lp_dfitctrldelay_cnt_eq0 = (i_lp_dfitctrldelay_cnt==0) ? 1'b1 : 1'b0;

  
  // dfi_lp_ctrl_req is high if ST_NXT in ST_LP_ACK_CHECK or ST_LP_WAIT
  wire i_dfi_lp_ctrl_req = st_nxt_lp_e_ack_check | st_nxt_lp_wait;
  
  // registered version
  reg  i_dfi_lp_ctrl_req_r;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_dfi_lp_ctrl_req_r_PROC
    if (!core_ddrc_rstn) begin
      i_dfi_lp_ctrl_req_r <= {$bits(i_dfi_lp_ctrl_req_r){1'b0}};
    end else begin
      i_dfi_lp_ctrl_req_r <= i_dfi_lp_ctrl_req;
    end
  end

  // Drive output from register
  assign dfi_lp_ctrl_req = i_dfi_lp_ctrl_req_r;



  // drive according to configuration value
  // driven inine with dfi_lp_ctrl_req signal, otherwise default to all zeroes
  wire [4:0] i_dfi_lp_ctrl_wakeup;
  assign i_dfi_lp_ctrl_wakeup = (i_dfi_lp_ctrl_req | st_nxt_lp_suspend) ? i_dfi_lp_wakeup_sel : 5'b00000;
 
  // registered version
  reg  [4:0] i_dfi_lp_ctrl_wakeup_r;
  always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin: i_dfi_lp_ctrl_wakeup_r_PROC
    if (!core_ddrc_rstn) begin
      i_dfi_lp_ctrl_wakeup_r <= {$bits(i_dfi_lp_ctrl_wakeup_r){1'b0}};
    end else begin
      i_dfi_lp_ctrl_wakeup_r <= i_dfi_lp_ctrl_wakeup;
    end
  end

  // Drive output from register
  assign dfi_lp_ctrl_wakeup = i_dfi_lp_ctrl_wakeup_r;

  assign dfilp_ctrlupd_ok      = !(dfi_lp_ctrl_req | dfi_lp_data_req | dfi_lp_ctrl_ack | dfi_lp_data_ack);
  assign dfilp_phyupd_pause_ok = dfilp_ctrlupd_ok;

   // ==================================================================
   // DFI Data Low Power interface
   // ==================================================================
   // FSM sequential
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) begin
         lp_data_state_r <= ST_LPD_INIT;
      end
      else begin
         lp_data_state_r <= lp_data_state_next;
      end
   end

   // FSM combinatorial
   always_comb begin
      case(lp_data_state_r)
         ST_LPD_INIT    : begin
            lp_data_state_next = lp_data_entry        ? ST_LPD_ENTRY    :
                                                        ST_LPD_INIT;
         end
         ST_LPD_ENTRY   : begin
            lp_data_state_next = lp_data_end          ? ST_LPD_INIT     :
                                                        ST_LPD_ACK;
         end
         ST_LPD_ACK     : begin
            lp_data_state_next = lp_data_end          ? ST_LPD_WAKEUP   :
                                 lp_data_suspend_req  ? ST_LPD_SUSPEND  :
                                                        ST_LPD_ACK;
         end
         ST_LPD_WAKEUP  : begin
            lp_data_state_next = lp_data_wakeup_end   ? ST_LPD_INIT     :
                                                        ST_LPD_WAKEUP;
         end
         ST_LPD_SUSPEND : begin
            lp_data_state_next = lp_data_end          ? ST_LPD_WAKEUP   :
                                 lp_data_suspend_req  ? ST_LPD_SUSPEND  :
                                 cmd_dly_eq0          ? ST_LPD_ENTRY    :
                                                        ST_LPD_WAIT_CMD_DLY;
         end
         default        : begin    // ST_LPD_WAIT_CMD_DLY
            lp_data_state_next = lp_data_end          ? ST_LPD_WAKEUP   :
                                 cnt_cmd_dly_eq0      ? ST_LPD_ENTRY    :
                                                        ST_LPD_WAIT_CMD_DLY;
         end
      endcase
   end

   // DFI LP Data entry
   assign lp_data_entry = reg_ddrc_dfi_lp_data_req_en &&
                          ~ctrlupd_req                &&       // No dfi_ctrlupd request
                          ~gs_pi_phyupd_pause_req     &&       // No dfi_phyupd request
                          ~gs_phymstr_clr_lp_req      &&       // No PHY master
                          ~gs_phymstr_mask_dfilp      &&       // No PHY master
                          ~dfi_ctrlmsg_req_busy       &&       // No dfi_ctrlmag_req
                          ((reg_ddrc_dfi_lp_en_data &&         // dfi_lp_data_en at normal mode
                            (dfilp_data_req_assert ||          // No data transaction
                             lp_data_re_entry))    ||          // re-entry at PDX/SRX
                           ((st_cgn == ST_LP_E_CTRLDELAY) &&
                             i_lp_dfitctrldelay_cnt_eq0));     // PD/SR entry

   // DFI LP Data end
   assign lp_data_end   = !reg_ddrc_dfi_lp_data_req_en ||
                          i_lp_exit_trig_red           ||      // low power end
                          gs_phymstr_clr_lp_req        ||      // PHY master
                          gs_phymstr_mask_dfilp        ||      // PHY master
                          dfilp_data_req_deassert      ||      // RD/WR/MRR command
                          lp_data_no_resp;                     // No response

   // No response
   assign lp_data_no_resp = (lp_data_state_r == ST_LPD_ACK) & ~(|cnt_lp_data_resp_r) & ~dfi_lp_data_ack;

   // Suspend request for ctrlupd and phyupd
   assign lp_data_suspend_req = lp_suspend_req;

   // Wakeup end
   assign lp_data_wakeup_end = (lp_data_normal_r & lp_data_wakeup_dly_r) | ~dfi_lp_data_ack;

   // wakeup count
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) begin
         lp_data_wakeup_dly_r <= 1'b0;
      end
      else begin
         lp_data_wakeup_dly_r <= (lp_data_state_r == ST_LPD_WAKEUP);
      end
   end

   // count tlp_resp of dfi_lp_data_ack
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) begin
         cnt_lp_data_resp_r <= {$bits(cnt_lp_data_resp_r){1'b0}};
      end
      else if (lp_data_state_next == ST_LPD_ENTRY) begin
         cnt_lp_data_resp_r <= i_lp_tlp_resp_cnt_val;
      end
      else if (|cnt_lp_data_resp_r) begin
         cnt_lp_data_resp_r <= cnt_lp_data_resp_r - {{$bits(cnt_lp_data_resp_r)-1{1'b0}}, 1'b1};
      end
   end

   // dfi_cmd_delay == 0
   assign cmd_dly_eq0 = ~(|dfi_cmd_delay);

   // count dfi_cmd_delay
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
      if (!core_ddrc_rstn) begin
         cnt_cmd_delay_r <= {$bits(cnt_cmd_delay_r){1'b0}};
      end
      else if (lp_data_state_r == ST_LPD_SUSPEND) begin
         cnt_cmd_delay_r <= dfi_cmd_delay;
      end
      else if (!cnt_cmd_dly_eq0) begin
         cnt_cmd_delay_r <= cnt_cmd_delay_r - {{$bits(cnt_cmd_delay_r)-1{1'b0}}, 1'b1};
      end
   end

   // cnt_cmd_delay_r == 0
   assign cnt_cmd_dly_eq0 = ~(|cnt_cmd_delay_r);

   // -----------------------------------------------------------------
   // dfi_lp_data_req
   // -----------------------------------------------------------------
   // dfi_lp_data_req
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: dfilp_data_req_r_PROC
      if (!core_ddrc_rstn) begin
         dfilp_data_req_r <= 1'b0;
      end
      else if ((lp_data_state_next == ST_LPD_ENTRY) ||
               (lp_data_state_next == ST_LPD_ACK)) begin
         dfilp_data_req_r <= 1'b1;
      end
      else begin
         dfilp_data_req_r <= 1'b0;
      end
   end

   // dfi_lp_data_req
   // Support only tlp_resp <= 2
   assign   dfi_lp_data_req = dfilp_data_req_r & ((lp_data_state_r != ST_LPD_ENTRY) || ~dfilp_data_req_deassert);


   // -----------------------------------------------------------------
   // De-assert timing at normal mode
   // -----------------------------------------------------------------
   // count deassert timing
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: cnt_data_req_deassert_tmg_r_PROC
      if (!core_ddrc_rstn) begin
         cnt_data_req_deassert_tmg_r <= {$bits(cnt_data_req_deassert_tmg_r){1'b0}};
      end
      else if (|cnt_data_req_deassert_tmg_r) begin
         cnt_data_req_deassert_tmg_r <= cnt_data_req_deassert_tmg_r - {{($bits(cnt_data_req_deassert_tmg_r)-1){1'b0}},1'b1};
      end
      else if (gs_op_is_rd | bypass_rd | op_is_mrr) begin
         cnt_data_req_deassert_tmg_r <= mr_lp_data_rd;
      end
      else if (gs_op_is_wr) begin
         cnt_data_req_deassert_tmg_r <= mr_lp_data_wr;
      end
   end

   // Bypass READ
   assign bypass_rd = 1'b0;

   // MRR
   assign op_is_mrr = (gs_pi_op_is_load_mr_norm & (gs_pi_mrr | gs_pi_mrr_ext));

   // deassert timing
   assign dfilp_data_req_deassert = ((gs_op_is_rd | bypass_rd | op_is_mrr) && ~(|mr_lp_data_rd)) ||
                                    (gs_op_is_wr && ~(|mr_lp_data_wr)) ||
                                    (cnt_data_req_deassert_tmg_r == {{($bits(cnt_data_req_deassert_tmg_r)-1){1'b0}},1'b1});

   // -----------------------------------------------------------------
   // Assert timing at normal mode
   // -----------------------------------------------------------------
   // count tphy_wrdata_delay
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: cnt_t_wrdata_delay_r_PROC
      if (!core_ddrc_rstn) begin
         cnt_t_wrdata_delay_r <= {$bits(cnt_t_wrdata_delay_r){1'b0}};
      end
      else if (!gs_pi_wr_data_pipeline_empty
              ) begin
         cnt_t_wrdata_delay_r <= reg_ddrc_dfi_t_wrdata_delay;
      end
      else if (|cnt_t_wrdata_delay_r) begin  // != 0
         cnt_t_wrdata_delay_r <= cnt_t_wrdata_delay_r - {{($bits(cnt_t_wrdata_delay_r)-1){1'b0}},1'b1};
      end
   end

   // data pipeline empty
   assign data_pipeline_empty = gs_pi_rd_data_pipeline_empty && gs_pi_wr_data_pipeline_empty &&
                                (cnt_t_wrdata_delay_r == {$bits(cnt_t_wrdata_delay_r){1'b0}});

   // latch data_pipeline_empty
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: data_pipeline_empty_r_PROC
      if (!core_ddrc_rstn) begin
         data_pipeline_empty_r <= 1'b0;
      end
      else begin
         data_pipeline_empty_r <= data_pipeline_empty;
      end
   end

   // assert timing (positive edge of gs_pi_data_pipeline_empty and no command is scheduled)
   assign dfilp_data_req_assert = (data_pipeline_empty && !data_pipeline_empty_r) && phy_dfi_init_complete &&
                                  ~(gs_op_is_rd | bypass_rd | op_is_mrr | gs_op_is_wr);

   // -----------------------------------------------------------------
   // assert timing of dfi_lp_data_req at exiting power down state
   // -----------------------------------------------------------------
   // latch dfi_lp_data_ack
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: dfilp_data_ack_r_PROC
      if (!core_ddrc_rstn) begin
         dfi_lp_data_ack_r <= 1'b0;
      end
      else begin
         dfi_lp_data_ack_r <= dfi_lp_data_ack;
      end
   end

   // negative edge of dfi_lp_data_ack for PD
   assign lp_data_re_entry = (dfi_lp_data_ack_r & ~dfi_lp_data_ack) & ~lp_data_normal_r & data_pipeline_empty_r;


   // -----------------------------------------------------------------
   // dfi_lp_data_wakeup
   // -----------------------------------------------------------------
   always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin: dfilp_data_wakeup_r_PROC
      if (!core_ddrc_rstn) begin
         dfilp_data_wakeup_r <= 5'd0;
         lp_data_normal_r    <= 1'b1;
      end
      else if (reg_ddrc_dfi_lp_en_data && (dfilp_data_req_assert || lp_data_re_entry)) begin    // pipeline empty or exit PD
         dfilp_data_wakeup_r <= reg_ddrc_dfi_lp_wakeup_data;
         lp_data_normal_r    <= 1'b1;
      end
      else if ((st_cgn == ST_LP_E_CTRLDELAY) && i_lp_dfitctrldelay_cnt_eq0) begin   // PD/SR entry
         dfilp_data_wakeup_r <= i_dfi_lp_ctrl_wakeup;
         lp_data_normal_r    <= 1'b0;
      end
   end

   assign dfi_lp_data_wakeup = dfilp_data_wakeup_r;


endmodule // gs_dfilp
