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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/bsm_pre_act.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module bsm_pre_act #(
  //------------------------------- PARAMETERS ----------------------------------
     parameter    IS_INACTIVE_BSM     = 0 // is parent BSM inactive?
  )
  (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                      co_yy_clk                       // clock
    ,input                                      core_ddrc_rstn                  // async falling-edge reset

    ,input [7:0]                                reg_ddrc_wr_page_exp_cycles
    ,input [7:0]                                reg_ddrc_rd_page_exp_cycles
    ,input [7:0]                                reg_ddrc_wr_act_idle_gap
    ,input [7:0]                                reg_ddrc_rd_act_idle_gap
    ,input                                      te_bs_rd_page_hit               // banks with reads pending to open pages
    ,input                                      te_bs_rd_valid                  // banks with reads pending
    ,input                                      te_bs_wr_page_hit               // banks with writes pending to open pages
    ,input                                      te_bs_wr_valid                  // banks with writes pending
    
    ,input                                      rd_more_crit 
    ,input                                      wr_more_crit

    ,input                                      delay_switch_write_state

    ,input                                      te_rws_wr_col_bank              // entry of colliding bank (1bit for 1bank)
    ,input                                      te_rws_rd_col_bank              // entry of colliding bank (1bit for 1bank)
    //// Current State & Write Mode Indicators ////
//    ,input                                      wr_mode_early                   // write mode indication, 1 cycle early
    ,input                                      wr_mode                         // next transaction should be a write

    ,output                                     sel_act_wr
    ,output                                     sel_act_rd

    `ifndef SYNTHESIS
    `ifdef SNPS_ASSERT_ON
    ,input                                      activate_ok
    `endif // SNPS_ASSERT_ON
    `endif // SYNTHESIS        
  );


localparam IDLE_CNT_BITS = 8;
localparam EXP_CNT_BITS = 8;

reg  sel_act_wr_r;
reg  sel_act_rd_r;
wire sel_act_wr_i;
wire sel_act_rd_i;
wire wr_pghit;
wire wrecc_pghit;
wire rd_pghit;
wire wr_pgmiss;
wire rd_pgmiss;
wire no_wr;
wire no_rd;


wire wr_col;
wire rd_col;
wire wr_crit;
wire rd_crit;
wire exp_vpw;
wire exp_vpr;

wire rd_idle_timeout;
wire wr_idle_timeout;
reg  [IDLE_CNT_BITS-1:0] rd_idle_cnt;
reg  [IDLE_CNT_BITS-1:0] wr_idle_cnt;

reg  [EXP_CNT_BITS-1:0] wr_page_exp_cnt;
reg  [EXP_CNT_BITS-1:0] rd_page_exp_cnt;
wire wr_page_exp_cnt_start;
wire rd_page_exp_cnt_start;
wire wr_page_exp;
wire rd_page_exp;


assign sel_act_wr = sel_act_wr_r & wr_pgmiss;
assign sel_act_rd = sel_act_rd_r & rd_pgmiss;

assign wr_pghit  = te_bs_wr_valid & te_bs_wr_page_hit;
assign rd_pghit  = te_bs_rd_valid & te_bs_rd_page_hit;

assign wrecc_pghit = 1'b0;

assign wr_pgmiss = te_bs_wr_valid & ~te_bs_wr_page_hit;
assign rd_pgmiss = te_bs_rd_valid & ~te_bs_rd_page_hit;

assign no_wr     = ~te_bs_wr_valid;
assign no_rd     = ~te_bs_rd_valid;

assign wr_col = te_bs_wr_valid & te_rws_wr_col_bank;
assign rd_col = te_bs_rd_valid & te_rws_rd_col_bank;
assign exp_vpw = 1'b0;
assign exp_vpr = 1'b0;

//wr_crit and rd_crit should be exclusive
assign wr_crit = te_bs_wr_valid & (wr_more_crit | (rd_page_exp & ~rd_more_crit));
assign rd_crit = te_bs_rd_valid & (rd_more_crit | (wr_page_exp & ~wr_more_crit));

assign sel_act_wr_i = (  
                      ~exp_vpr & (
                      exp_vpw ? wr_pgmiss :
                      (wr_col ^ rd_col) ? wr_col & wr_pgmiss :
                      (~wr_col & ~rd_col & (wr_crit|rd_crit)) ? wr_crit & wr_pgmiss : 
                      ( (no_rd & wr_pgmiss & (wr_mode | rd_idle_timeout)) | 
                        (wr_pgmiss & rd_pgmiss & wr_mode) )
                      )) 

                       ;

assign sel_act_rd_i = (  
                    (exp_vpr ? rd_pgmiss :
                     exp_vpw ? 1'b0 :
                     (wr_col ^ rd_col) ? rd_col & rd_pgmiss :
                     (~wr_col & ~rd_col & wr_mode & wrecc_pghit) ? 1'b0 :
                     (~wr_col & ~rd_col & (wr_crit|rd_crit)) ? rd_crit & rd_pgmiss :
                     (  (no_wr & rd_pgmiss & (~wr_mode | wr_idle_timeout)) | 
                        (rd_pgmiss & wr_pgmiss & ~wr_mode & ~delay_switch_write_state ))))

                       ;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
     sel_act_wr_r <= 1'b0;
     sel_act_rd_r <= 1'b0;
   end
   else begin
     sel_act_wr_r <= sel_act_wr_i;
     sel_act_rd_r <= sel_act_rd_i;
   end

//rdwr activate idle gap
//the counter start in two case,
//  1. in read mode, no read request, but write request is page-miss
//  2. in write mode, no write request, but read request is page-miss
//assign cnt_start = wr_mode ? no_wr & rd_pgmiss : no_rd & wr_pgmiss;
//
// only use it for wr idle in read mode
//assign cnt_start = ~wr_mode & no_rd & wr_pgmiss;
wire rd_idle_cnt_start;
assign rd_idle_cnt_start = no_rd;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
     rd_idle_cnt <= {IDLE_CNT_BITS{1'b0}};
   end
   else begin
      if (rd_idle_cnt_start) begin
         if(!rd_idle_timeout) begin
            rd_idle_cnt <= rd_idle_cnt + 1'b1;
         end
      end else begin
         rd_idle_cnt <= {IDLE_CNT_BITS{1'b0}};
      end
   end

assign  rd_idle_timeout= (rd_idle_cnt == reg_ddrc_rd_act_idle_gap);


wire wr_idle_cnt_start;
assign wr_idle_cnt_start = no_wr;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
     wr_idle_cnt <= {IDLE_CNT_BITS{1'b0}};
   end
   else begin
      if (wr_idle_cnt_start) begin
         if(!wr_idle_timeout) begin
            wr_idle_cnt <= wr_idle_cnt + 1'b1;
         end
      end else begin
         wr_idle_cnt <= {IDLE_CNT_BITS{1'b0}};
      end
   end


assign  wr_idle_timeout= (wr_idle_cnt == reg_ddrc_wr_act_idle_gap);

//-------------------------------------------------
// in read mode, counting write page-hit and read page-miss, if timer expired, make read is critical and then cause read be prepared
// this critical is not de-assert untill write became page-miss or bank is prechareged. 

assign wr_page_exp_cnt_start = ~wr_mode & rd_pgmiss & wr_pghit;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
     wr_page_exp_cnt <= {EXP_CNT_BITS{1'b0}};
   end
   else begin
      if (wr_page_exp_cnt_start) begin
         if(!wr_page_exp & !delay_switch_write_state) begin
            wr_page_exp_cnt <= wr_page_exp_cnt + 1'b1;
         end
      end else begin
         wr_page_exp_cnt <= {EXP_CNT_BITS{1'b0}};
      end
   end

assign  wr_page_exp = (wr_page_exp_cnt == reg_ddrc_wr_page_exp_cycles) & wr_page_exp_cnt_start;

//-------------------------------------------------
// in write mode, counting read page-hit and write page-miss, if timer expired, make read is critical and then cause write be prepared
// this critical is not de-assert untill read became page-miss or bank is prechareged. 

assign rd_page_exp_cnt_start = wr_mode & rd_pghit & wr_pgmiss;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
     rd_page_exp_cnt <= {EXP_CNT_BITS{1'b0}};
   end
   else begin
      if (rd_page_exp_cnt_start) begin
         if(!rd_page_exp) begin
            rd_page_exp_cnt <= rd_page_exp_cnt + 1'b1;
         end
      end else begin
         rd_page_exp_cnt <= {EXP_CNT_BITS{1'b0}};
      end
   end

assign  rd_page_exp = (rd_page_exp_cnt == reg_ddrc_rd_page_exp_cycles) & rd_page_exp_cnt_start;

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
// VCS coverage off

  // Exclude assertions if this bank is inactive. See Bug 11386 and Bug 11466.
  generate if(!IS_INACTIVE_BSM) begin : GEN_SVA

        wire rdwr_pol_sel;
        assign rdwr_pol_sel = 1'b1; 

        // sel_act_rd and sel_act_wr cannot be assert at the same time
        property p_sel_act_rd_wr_not_same_time;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
              (sel_act_wr) |-> ~sel_act_rd;
        endproperty 

        a_sel_act_rd_wr_not_same_time : assert property (p_sel_act_rd_wr_not_same_time)
            else $error("[%t][%m] ERROR: sel_act_rd and sel_act_wr cannot be assert at the same time", $time);    

        // rd_crit and wr_crit cannot be assert at the same time
        property p_rd_crit_wr_crit_not_same_time;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel) 
              ~(rd_crit & wr_crit);
        endproperty 

        a_rd_crit_wr_crit_not_same_time: assert property (p_rd_crit_wr_crit_not_same_time)
            else $error("[%t][%m] ERROR: rd_crit and wr_crit cannot be assert at the same time", $time);    

        // assertions to check pre-activate feature.    
        property p_pre_act_exvpr_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (exp_vpr && rd_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty
        
        a_pre_act_exvpr_sel_act_none: assert property (p_pre_act_exvpr_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_exvpr_sel_act_rd;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (exp_vpr && rd_pgmiss) ##1 activate_ok && rd_pgmiss |-> (~sel_act_wr && sel_act_rd);
        endproperty
        
        a_pre_act_exvpr_sel_act_rd: assert property (p_pre_act_exvpr_sel_act_rd)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_exvpw_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && exp_vpw && wr_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty
        
        a_pre_act_exvpw_sel_act_none: assert property (p_pre_act_exvpw_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_exvpw_sel_act_wr;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && exp_vpw && wr_pgmiss) ##1 activate_ok && wr_pgmiss |-> (sel_act_wr && ~sel_act_rd);
        endproperty
        
        a_pre_act_exvpw_sel_act_wr: assert property (p_pre_act_exvpw_sel_act_wr)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_rd_col_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && rd_col && ~wr_col && rd_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_rd_col_sel_act_none: assert property (p_pre_act_rd_col_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_rd_col_sel_act_rd;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && rd_col && ~wr_col && rd_pgmiss) ##1 activate_ok && rd_pgmiss |-> (~sel_act_wr && sel_act_rd);
        endproperty

        a_pre_act_rd_col_sel_act_rd: assert property (p_pre_act_rd_col_sel_act_rd)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_wr_col_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && wr_col && wr_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_wr_col_sel_act_none: assert property (p_pre_act_wr_col_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_wr_col_sel_act_wr;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && wr_col && wr_pgmiss) ##1 activate_ok && wr_pgmiss |-> (sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_wr_col_sel_act_wr: assert property (p_pre_act_wr_col_sel_act_wr)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_wrecc_hit_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && wr_mode && wrecc_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_wrecc_hit_sel_act_none: assert property (p_pre_act_wrecc_hit_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_rd_more_crit_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && rd_more_crit && rd_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty
            
        a_pre_act_rd_more_crit_sel_act_none: assert property (p_pre_act_rd_more_crit_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_rd_more_crit_sel_act_rd;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~(wr_mode && wrecc_pghit) && rd_more_crit && rd_pgmiss) ##1 activate_ok && rd_pgmiss |-> (~sel_act_wr && sel_act_rd);
        endproperty
            
        a_pre_act_rd_more_crit_sel_act_rd: assert property (p_pre_act_rd_more_crit_sel_act_rd)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_wr_more_crit_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && wr_more_crit && wr_pghit) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty
            
        a_pre_act_wr_more_crit_sel_act_none: assert property (p_pre_act_wr_more_crit_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_wr_more_crit_sel_act_wr;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && wr_more_crit && wr_pgmiss) ##1 activate_ok && wr_pgmiss |-> (sel_act_wr && ~sel_act_rd);
        endproperty
            
        a_pre_act_wr_more_crit_sel_act_wr: assert property (p_pre_act_wr_more_crit_sel_act_wr)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_wr_page_exp_sel_act_rd;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~(wr_mode && wrecc_pghit) && ~rd_more_crit && ~wr_more_crit && (wr_pghit && rd_pgmiss) && (~wr_mode && wr_page_exp)) ##1 activate_ok && rd_pgmiss |-> (~sel_act_wr && sel_act_rd);
        endproperty

        a_pre_act_wr_page_exp_sel_act_rd: assert property (p_pre_act_wr_page_exp_sel_act_rd)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        property p_pre_act_wr_page_exp_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && (wr_pghit && rd_pgmiss) && ~(~wr_mode && wr_page_exp)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_wr_page_exp_sel_act_none: assert property (p_pre_act_wr_page_exp_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_rd_page_exp_sel_act_wr;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && (rd_pghit && wr_pgmiss) && (wr_mode && rd_page_exp)) ##1 activate_ok && wr_pgmiss |-> (sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_rd_page_exp_sel_act_wr: assert property (p_pre_act_rd_page_exp_sel_act_wr)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        property p_pre_act_rd_page_exp_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && (rd_pghit && wr_pgmiss) && ~(wr_mode && rd_page_exp)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_rd_page_exp_sel_act_none: assert property (p_pre_act_rd_page_exp_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_delay_switch_wr_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && (rd_pgmiss && wr_pgmiss && delay_switch_write_state)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_delay_switch_wr_sel_act_none: assert property (p_pre_act_delay_switch_wr_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_rd_sel_act_rd;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~(wr_mode && wrecc_pghit) && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (~wr_mode && rd_pgmiss)) ##1 activate_ok && rd_pgmiss |-> (~sel_act_wr && sel_act_rd);
        endproperty

        a_pre_act_normal_rd_sel_act_rd: assert property (p_pre_act_normal_rd_sel_act_rd)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_rd_sel_act_wr;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (~wr_mode && ~te_bs_rd_valid && wr_pgmiss && rd_idle_timeout)) ##1 activate_ok && wr_pgmiss |-> (sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_normal_rd_sel_act_wr: assert property (p_pre_act_normal_rd_sel_act_wr)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_rd_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (~wr_mode && ~te_bs_rd_valid && wr_pgmiss && ~rd_idle_timeout)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_normal_rd_sel_act_none: assert property (p_pre_act_normal_rd_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_rd_sel_act_none2;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (~wr_mode && ~te_bs_rd_valid && ~te_bs_wr_valid)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_normal_rd_sel_act_none2: assert property (p_pre_act_normal_rd_sel_act_none2)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_wr_sel_act_wr;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (wr_mode && wr_pgmiss)) ##1 activate_ok && wr_pgmiss |-> (sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_normal_wr_sel_act_wr: assert property (p_pre_act_normal_wr_sel_act_wr)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_wr_sel_act_rd;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~(wr_mode && wrecc_pghit) && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (wr_mode && ~te_bs_wr_valid && rd_pgmiss && wr_idle_timeout)) ##1 activate_ok && rd_pgmiss |-> (~sel_act_wr && sel_act_rd);
        endproperty

        a_pre_act_normal_wr_sel_act_rd: assert property (p_pre_act_normal_wr_sel_act_rd)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_wr_sel_act_none;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (wr_mode && ~te_bs_wr_valid && rd_pgmiss && ~wr_idle_timeout)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_normal_wr_sel_act_none: assert property (p_pre_act_normal_wr_sel_act_none)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_pre_act_normal_wr_sel_act_none2;
            @(posedge co_yy_clk) disable iff(!core_ddrc_rstn || !rdwr_pol_sel)
                (~exp_vpr && ~exp_vpw && ~rd_col && ~wr_col && ~rd_more_crit && ~wr_more_crit && ~(wr_pghit && rd_pgmiss) && ~(rd_pghit && wr_pgmiss) && ~(rd_pgmiss && wr_pgmiss && delay_switch_write_state) && (wr_mode && ~te_bs_wr_valid && ~te_bs_rd_valid)) |-> ##1 (~sel_act_wr && ~sel_act_rd);
        endproperty

        a_pre_act_normal_wr_sel_act_none2: assert property (p_pre_act_normal_wr_sel_act_none2)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        // assertions to check wr_act_idle and rd_act_idle register function.
        property p_wr_act_idle_0;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                ~|reg_ddrc_wr_act_idle_gap && wr_idle_cnt_start |-> wr_idle_timeout;
        endproperty

        a_wr_act_idle_0: assert property (p_wr_act_idle_0)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_wr_act_idle_1;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_wr_act_idle_gap && (wr_idle_cnt < reg_ddrc_wr_act_idle_gap) |-> ~wr_idle_timeout;
        endproperty

        a_wr_act_idle_1: assert property (p_wr_act_idle_1)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_wr_act_idle_2;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_wr_act_idle_gap && (wr_idle_cnt == reg_ddrc_wr_act_idle_gap) /* && wr_idle_cnt_start */ |-> wr_idle_timeout;
        endproperty

        a_wr_act_idle_2: assert property (p_wr_act_idle_2)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_wr_act_idle_3;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_wr_act_idle_gap && (wr_idle_cnt < reg_ddrc_wr_act_idle_gap) && ~wr_idle_cnt_start |-> ##1 wr_idle_cnt==0;
        endproperty

        a_wr_act_idle_3: assert property (p_wr_act_idle_3)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        covergroup cg_wr_act_idle @(posedge co_yy_clk);
           
            cp_wr_act_idle_cnt: coverpoint ({wr_idle_cnt_start, reg_ddrc_wr_act_idle_gap - wr_idle_cnt}) iff(core_ddrc_rstn || rdwr_pol_sel) {
                bins satisfied_0    =   {1'b1, 0                                    };
                bins satisfied_1    =   {1'b1, [1:{IDLE_CNT_BITS{1'b1}}]            };
                bins unsatisfied_0  =   {1'b0, 0                                    };
                bins unsatisfied_1  =   {1'b0, [1:{IDLE_CNT_BITS{1'b1}}]            };
            }
            
            cp_reg_ddrc_wr_act_idle_gap: coverpoint ({reg_ddrc_wr_act_idle_gap}) iff(core_ddrc_rstn || rdwr_pol_sel) {
                bins watermark_0    =   {{IDLE_CNT_BITS{1'b1}}                      };
                // bins watermark_1    =   {{IDLE_CNT_BITS{1'b1}}-1                    };
                bins watermark_2    =   {0                                          };
                // bins watermark_3    =   {1                                          };
                bins watermark_4    =   {[1: {IDLE_CNT_BITS{1'b1}}-1]               };
            }

        endgroup: cg_wr_act_idle

        cg_wr_act_idle cg_wr_act_idle_inst = new;
        
        property p_rd_act_idle_0;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                ~|reg_ddrc_rd_act_idle_gap && rd_idle_cnt_start |-> rd_idle_timeout;
        endproperty

        a_rd_act_idle_0: assert property (p_rd_act_idle_0)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_rd_act_idle_1;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_rd_act_idle_gap && (rd_idle_cnt < reg_ddrc_rd_act_idle_gap) |-> ~rd_idle_timeout;
        endproperty

        a_rd_act_idle_1: assert property (p_rd_act_idle_1)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_rd_act_idle_2;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_rd_act_idle_gap && (rd_idle_cnt == reg_ddrc_rd_act_idle_gap) /* && rd_idle_cnt_start */ |-> rd_idle_timeout;
        endproperty

        a_rd_act_idle_2: assert property (p_rd_act_idle_2)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_rd_act_idle_3;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_rd_act_idle_gap && (rd_idle_cnt < reg_ddrc_rd_act_idle_gap) && ~rd_idle_cnt_start |-> ##1 rd_idle_cnt==0;
        endproperty

        a_rd_act_idle_3: assert property (p_rd_act_idle_3)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        covergroup cg_rd_act_idle @(posedge co_yy_clk);
           
            cp_rd_act_idle_cnt: coverpoint ({rd_idle_cnt_start, reg_ddrc_rd_act_idle_gap - rd_idle_cnt}) iff(core_ddrc_rstn) {
                bins satisfied_0    =   {1'b1, 0                                    };
                bins satisfied_1    =   {1'b1, [1:{IDLE_CNT_BITS{1'b1}}]            };
                bins unsatisfied_0  =   {1'b0, 0                                    };
                bins unsatisfied_1  =   {1'b0, [1:{IDLE_CNT_BITS{1'b1}}]            };
            }
            
            cp_reg_ddrc_rd_act_idle_gap: coverpoint ({reg_ddrc_rd_act_idle_gap}) iff(core_ddrc_rstn) {
                bins watermark_0    =   {{IDLE_CNT_BITS{1'b1}}                      };
                // bins watermark_1    =   {{IDLE_CNT_BITS{1'b1}}-1                    };
                bins watermark_2    =   {0                                          };
                // bins watermark_3    =   {1                                          };
                bins watermark_4    =   {[1: {IDLE_CNT_BITS{1'b1}}-1]               };
            }

        endgroup: cg_rd_act_idle

        cg_rd_act_idle cg_rd_act_idle_inst = new;

        // assertions to check wr_page_exp and rd_page_exp register function.
        property p_wr_page_exp_0;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                ~|reg_ddrc_wr_page_exp_cycles && wr_page_exp_cnt_start |-> wr_page_exp;
        endproperty        
        
        a_wr_page_exp_0: assert property (p_wr_page_exp_0)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        property p_wr_page_exp_1;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_wr_page_exp_cycles && (wr_page_exp_cnt < reg_ddrc_wr_page_exp_cycles) |-> ~wr_page_exp;
        endproperty        
        
        a_wr_page_exp_1: assert property (p_wr_page_exp_1)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        property p_wr_page_exp_2;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_wr_page_exp_cycles && ($past(wr_page_exp_cnt,1) == reg_ddrc_wr_page_exp_cycles-1) && (wr_page_exp_cnt == reg_ddrc_wr_page_exp_cycles) && !delay_switch_write_state && wr_page_exp_cnt_start |-> $rose(wr_page_exp) /* ##[1:64] $fell(wr_page_exp) */;
        endproperty        
        
        a_wr_page_exp_2: assert property (p_wr_page_exp_2)
            else $error("Inline SVA [%t][%m] FAILED", $time);
       
        genvar ci1;
            for (ci1 = 1; ci1 <= 64; ci1 = ci1 + 1) begin
                c_wr_page_exp_2: cover property (@(posedge co_yy_clk)
                    (core_ddrc_rstn && rdwr_pol_sel) throughout $rose(wr_page_exp) ##ci1 $fell(wr_page_exp) );
            end

        property p_wr_page_exp_3;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_wr_page_exp_cycles && (wr_page_exp_cnt < reg_ddrc_wr_page_exp_cycles) && ~wr_page_exp_cnt_start |-> ##1 wr_page_exp_cnt==0;
        endproperty        
        
        a_wr_page_exp_3: assert property (p_wr_page_exp_3)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        covergroup cg_wr_page_exp @(posedge co_yy_clk);
           
            cp_wr_page_exp_cnt: coverpoint ({wr_page_exp_cnt_start, reg_ddrc_wr_page_exp_cycles - wr_page_exp_cnt}) iff(core_ddrc_rstn && rdwr_pol_sel) {
                bins satisfied_0    =   {1'b1, 0                                    };
                bins satisfied_1    =   {1'b1, [1:{EXP_CNT_BITS{1'b1}}]             };
                bins unsatisfied_0  =   {1'b0, 0                                    };
                bins unsatisfied_1  =   {1'b0, [1:{EXP_CNT_BITS{1'b1}}]             };
            }
            
            cp_reg_ddrc_wr_page_exp_cycles: coverpoint ({reg_ddrc_wr_page_exp_cycles}) iff(core_ddrc_rstn && rdwr_pol_sel) {
                bins watermark_0    =   {{EXP_CNT_BITS{1'b1}}                       };
                // bins watermark_1    =   {{EXP_CNT_BITS{1'b1}}-1                     };
                bins watermark_2    =   {0                                          };
                // bins watermark_3    =   {1                                          };
                bins watermark_4    =   {[1: {EXP_CNT_BITS{1'b1}}-1]                };
            }

        endgroup: cg_wr_page_exp

        cg_wr_page_exp cg_wr_page_exp_inst = new;

        property p_rd_page_exp_0;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                ~|reg_ddrc_rd_page_exp_cycles && rd_page_exp_cnt_start |-> rd_page_exp;
        endproperty        
        
        a_rd_page_exp_0: assert property (p_rd_page_exp_0)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        property p_rd_page_exp_1;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_rd_page_exp_cycles && (rd_page_exp_cnt < reg_ddrc_rd_page_exp_cycles) |-> ~rd_page_exp;
        endproperty        
        
        a_rd_page_exp_1: assert property (p_rd_page_exp_1)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_rd_page_exp_2;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_rd_page_exp_cycles && ($past(rd_page_exp_cnt,1) == reg_ddrc_rd_page_exp_cycles - 1) && (rd_page_exp_cnt == reg_ddrc_rd_page_exp_cycles) && rd_page_exp_cnt_start |-> $rose(rd_page_exp) /* ##[1:64] $fell(rd_page_exp) */;
        endproperty        
        
        a_rd_page_exp_2: assert property (p_rd_page_exp_2)
            else $error("Inline SVA [%t][%m] FAILED", $time);

        property p_rd_page_exp_3;
            @(posedge co_yy_clk) disable iff(~core_ddrc_rstn || !rdwr_pol_sel)
                |reg_ddrc_rd_page_exp_cycles && (rd_page_exp_cnt < reg_ddrc_rd_page_exp_cycles) && ~rd_page_exp_cnt_start |-> ##1 rd_page_exp_cnt==0;
        endproperty        
        
        a_rd_page_exp_3: assert property (p_rd_page_exp_3)
            else $error("Inline SVA [%t][%m] FAILED", $time);
        
        covergroup cg_rd_page_exp @(posedge co_yy_clk);
            
            cp_rd_page_exp_cnt: coverpoint ({rd_page_exp_cnt_start, reg_ddrc_rd_page_exp_cycles - rd_page_exp_cnt}) iff(core_ddrc_rstn && rdwr_pol_sel) {
                bins satisfied_0    =   {1'b1, 0                                    };
                bins satisfied_1    =   {1'b1, [1:{EXP_CNT_BITS{1'b1}}]             };
                bins unsatisfied_0  =   {1'b0, 0                                    };
                bins unsatisfied_1  =   {1'b0, [1:{EXP_CNT_BITS{1'b1}}]             };
            }
            
            cp_reg_ddrc_rd_page_exp_cycles: coverpoint ({reg_ddrc_rd_page_exp_cycles}) iff(core_ddrc_rstn && rdwr_pol_sel) {
                bins watermark_0    =   {{EXP_CNT_BITS{1'b1}}                       };
                // bins watermark_1    =   {{EXP_CNT_BITS{1'b1}}-1                     };
                bins watermark_2    =   {0                                          };
                // bins watermark_3    =   {1                                          };
                bins watermark_4    =   {[1: {EXP_CNT_BITS{1'b1}}-1]                };
            }

        endgroup: cg_rd_page_exp

        cg_rd_page_exp cg_rd_page_exp_inst = new;

  end // generate if(!IS_INACTIVE_BSM)
  endgenerate

// VCS coverage on
`endif   // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule  
