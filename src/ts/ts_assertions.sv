//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/ts_assertions.sv#3 $
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

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//                              Description
// this module contains all verification support for TS module
// assertions and coverage
// ----------------------------------------------------------------------------


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

`include "DWC_ddrctl_all_defs.svh"
module ts_assertions (
        clk,
        core_ddrc_rstn,
        // vlds
        bs_os_rdwr_hi_vlds,
        bs_os_act_hi_vlds,
        bs_os_rdwr_lo_vlds,
        bs_os_act_lo_vlds,
        bs_os_pre_req_vlds,
        bs_os_pre_crit_vlds,
        bs_os_act_wr_vlds,
        bs_os_pre_req_wr_vlds,
        // wall_next
        hi_rdwr_bsm_hint,
        hi_act_bsm_hint,
        lo_rdwr_bsm_hint,
        lo_act_bsm_hint,
        pre_req_bsm_hint,
        wr_act_bsm_hint,
        wr_pre_req_bsm_hint,
        // selected_vld
        os_gs_rdwr_hi_vld,
        os_gs_act_hi_vld,
        os_gs_rdwr_lo_vld,
        os_gs_act_lo_vld,
        os_gs_pre_req_vld,
        os_gs_pre_crit_vld,
        os_gs_act_wr_vld,
        os_gs_pre_req_wr_vld,
        // selected
        os_gs_rdwr_hi_bsm,
        os_gs_act_hi_bsm,
        os_gs_rdwr_lo_bsm,
        os_gs_act_lo_bsm,
        os_gs_pre_req_bsm,
        os_gs_pre_crit_bsm
       ,os_gs_act_wr_bsm,
        os_gs_pre_req_wr_bsm,
        ts_act_page,
        act_hi_tag_selected,
        act_lo_tag_selected,
        act_wr_tag_selected,

        gs_act_pre_rd_priority,
        reverse_priority,
        no_rdwr_cmd,
        no_critical_cmd,
        dh_gs_per_bank_refresh,
        no_critical_global_cmd, 
        block_t_xs,
        no_ops_allowed,
        pi_gs_noxact,
        critical_ref_possible_wo_trrd,
        gs_cas_ws_req,
        wr_mode,
        pi_col_b3,
        dh_gs_2t_mode,
        dh_gs_frequency_ratio,
        dh_gs_lpddr4,
        reg_ddrc_lpddr5,
        rank_block_pre,
        choose_ref_req,
        rank_nop_after_zqcs,
        speculative_ref_possible,
        critical_ref_possible,
        no_simul_cmd_pre,
        gs_pre_cs_n,
        gs_ts_any_vpr_timed_out,
        gs_ts_any_vpw_timed_out,
        rd_more_crit,
        wr_more_crit,
        gs_wr_mode,
        gs_te_pri_level
       ,gs_op_is_act
       ,gs_op_is_pre
       ,gs_act_bsm_num
       ,gs_pre_bsm_num
       ,gs_op_is_rd
       ,gs_op_is_wr
       ,gs_rdwr_rankbank_num
       ,gs_pre_rankbank_num
       ,gs_act_rankbank_num
       ,te_rws_rd_col_bank
       ,te_rws_wr_col_bank
);

// ----------------------------------------------------------------------------
// parameters
// ----------------------------------------------------------------------------
parameter   RANK_BITS           = `MEMC_RANK_BITS;
parameter   BG_BITS             = `MEMC_BG_BITS;
parameter   BANK_BITS           = `MEMC_BANK_BITS;
parameter   BG_BANK_BITS        = `MEMC_BG_BANK_BITS;
parameter   CID_WIDTH           = `DDRCTL_DDRC_CID_WIDTH;
parameter   NUM_TOTAL_BANKS     = `DDRCTL_DDRC_NUM_TOTAL_BANKS;
parameter   RANKBANK_BITS       = `DDRCTL_DDRC_LRANK_BITS + `MEMC_BG_BANK_BITS;
parameter   NUM_TOTAL_BSMS      = `UMCTL2_NUM_BSM;
parameter   BSM_BITS            = `UMCTL2_BSM_BITS;
parameter   CMD_IF_WIDTH        = `MEMC_FREQ_RATIO;
parameter  NUM_LRANKS           = `DDRCTL_DDRC_NUM_LRANKS_TOTAL;
parameter  PAGE_BITS            = `MEMC_PAGE_BITS;
parameter   NUM_RANKS           = `MEMC_NUM_RANKS;
parameter  SEL_ACT_TWDT        = PAGE_BITS
                                + 1
                                ;

// ----------------------------------------------------------------------------
// ports declaration
// ----------------------------------------------------------------------------
input                       clk;
input                       core_ddrc_rstn;
// vlds
input [NUM_TOTAL_BSMS-1:0]  bs_os_rdwr_hi_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_act_hi_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_rdwr_lo_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_act_lo_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_pre_req_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_pre_crit_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_act_wr_vlds;
input [NUM_TOTAL_BSMS-1:0]  bs_os_pre_req_wr_vlds;
// wall_next
input [BSM_BITS-1:0]        hi_rdwr_bsm_hint;
input [BSM_BITS-1:0]        hi_act_bsm_hint;
input [BSM_BITS-1:0]        lo_rdwr_bsm_hint;
input [BSM_BITS-1:0]        lo_act_bsm_hint;
input [BSM_BITS-1:0]        pre_req_bsm_hint;
input [BSM_BITS-1:0]        wr_act_bsm_hint;
input [BSM_BITS-1:0]        wr_pre_req_bsm_hint;
// selected_vld
input                       os_gs_rdwr_hi_vld;
input                       os_gs_act_hi_vld;
input                       os_gs_rdwr_lo_vld;
input                       os_gs_act_lo_vld;
input                       os_gs_pre_req_vld;
input                       os_gs_pre_crit_vld;
input                       os_gs_act_wr_vld;
input                       os_gs_pre_req_wr_vld;
// selected
input [BSM_BITS-1:0]        os_gs_rdwr_hi_bsm;
input [BSM_BITS-1:0]        os_gs_act_hi_bsm;
input [BSM_BITS-1:0]        os_gs_rdwr_lo_bsm;
input [BSM_BITS-1:0]        os_gs_act_lo_bsm;
input [BSM_BITS-1:0]        os_gs_pre_req_bsm;
input [BSM_BITS-1:0]        os_gs_pre_crit_bsm;
input [BSM_BITS-1:0]        os_gs_act_wr_bsm;
input [BSM_BITS-1:0]        os_gs_pre_req_wr_bsm;
input [PAGE_BITS-1:0]       ts_act_page;
input [SEL_ACT_TWDT-1:0]    act_hi_tag_selected;
input [SEL_ACT_TWDT-1:0]    act_lo_tag_selected;
input [SEL_ACT_TWDT-1:0]    act_wr_tag_selected;

input                       gs_act_pre_rd_priority;
input                       reverse_priority;
input                       no_rdwr_cmd;
input                       no_critical_cmd;
input                       dh_gs_per_bank_refresh;
input                       no_critical_global_cmd;
input                       block_t_xs;
input                       no_ops_allowed;
input                       pi_gs_noxact;
input [NUM_RANKS-1:0]       critical_ref_possible_wo_trrd; // critical refresh pending to a closed rank
input                       gs_cas_ws_req;
input                       wr_mode;
input                       pi_col_b3;
input                       dh_gs_2t_mode;
input                       dh_gs_frequency_ratio;
input                       dh_gs_lpddr4;
input                       reg_ddrc_lpddr5;
input [NUM_RANKS-1:0]       rank_block_pre;
input                       choose_ref_req;
input [NUM_RANKS-1:0]       rank_nop_after_zqcs;
input [NUM_RANKS-1:0]       speculative_ref_possible;
input [NUM_RANKS-1:0]       critical_ref_possible;
input                       no_simul_cmd_pre;
input [NUM_RANKS-1:0]       gs_pre_cs_n;

input                       gs_ts_any_vpr_timed_out;
input                       gs_ts_any_vpw_timed_out;
input                       rd_more_crit;
input                       wr_more_crit;
input                       gs_wr_mode;
input                       gs_te_pri_level;

    input                                       gs_op_is_act;
    input                                       gs_op_is_pre;
    input [BSM_BITS-1:0]                        gs_act_bsm_num;
    input [BSM_BITS-1:0]                        gs_pre_bsm_num;

    input                                       gs_op_is_rd;
    input                                       gs_op_is_wr;
    input [RANKBANK_BITS-1:0]                   gs_rdwr_rankbank_num;
    input [RANKBANK_BITS-1:0]                   gs_pre_rankbank_num;
    input [RANKBANK_BITS-1:0]                   gs_act_rankbank_num;
    input [NUM_TOTAL_BSMS-1:0]                  te_rws_rd_col_bank;
    input [NUM_TOTAL_BSMS-1:0]                  te_rws_wr_col_bank;

// ----------------------------------------------------------------------------
// internal signals declaration
// ----------------------------------------------------------------------------
reg   [BSM_BITS-1:0]        hi_rdwr_bsm_hint_r;
reg   [BSM_BITS-1:0]        hi_act_bsm_hint_r;
reg   [BSM_BITS-1:0]        lo_rdwr_bsm_hint_r;
reg   [BSM_BITS-1:0]        lo_act_bsm_hint_r;
reg   [BSM_BITS-1:0]        pre_req_bsm_hint_r;
reg   [BSM_BITS-1:0]        wr_act_bsm_hint_r;
reg   [BSM_BITS-1:0]        wr_pre_req_bsm_hint_r;
reg                         gs_ts_any_vpr_timed_out_r;
reg                         gs_ts_any_vpw_timed_out_r;
reg                         rd_more_crit_r;
reg                         wr_more_crit_r;
reg                         gs_te_wr_mode_r;
reg   [NUM_TOTAL_BSMS-1:0]  te_rws_rd_col_bank_r;
reg   [NUM_TOTAL_BSMS-1:0]  te_rws_wr_col_bank_r;


always @(posedge clk) hi_rdwr_bsm_hint_r  <= hi_rdwr_bsm_hint;
always @(posedge clk) hi_act_bsm_hint_r   <= hi_act_bsm_hint;
always @(posedge clk) lo_rdwr_bsm_hint_r  <= lo_rdwr_bsm_hint;
always @(posedge clk) lo_act_bsm_hint_r   <= lo_act_bsm_hint;
always @(posedge clk) pre_req_bsm_hint_r  <= pre_req_bsm_hint;
always @(posedge clk) wr_act_bsm_hint_r   <= wr_act_bsm_hint;
always @(posedge clk) wr_pre_req_bsm_hint_r   <= wr_pre_req_bsm_hint;
always @(posedge clk) gs_ts_any_vpr_timed_out_r   <= gs_ts_any_vpr_timed_out;
always @(posedge clk) gs_ts_any_vpw_timed_out_r   <= gs_ts_any_vpw_timed_out;
always @(posedge clk) rd_more_crit_r   <= rd_more_crit;
always @(posedge clk) wr_more_crit_r   <= wr_more_crit;
always @(posedge clk) gs_te_wr_mode_r   <= gs_wr_mode;
always @(posedge clk) te_rws_rd_col_bank_r  <= te_rws_rd_col_bank;
always @(posedge clk) te_rws_wr_col_bank_r  <= te_rws_wr_col_bank;

// ----------------------------------------------------------------------------
// properties & assertions
// ----------------------------------------------------------------------------

// OS_SEL_NET for RDWR_HI
// - check that if the oldest bank requests then it is served
property ts_select_net_rdwr_hi_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_rdwr_hi_vlds[hi_rdwr_bsm_hint_r] == 1'b1) |-> (os_gs_rdwr_hi_vld & (hi_rdwr_bsm_hint_r == os_gs_rdwr_hi_bsm));
endproperty

a_ts_select_net_rdwr_hi_check1: assert property (ts_select_net_rdwr_hi_check1)
  else $error("%m %t OS_SEL_NET for RDWR_HI - oldest bank%0d is requesting but is not served ", $time, hi_rdwr_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_rdwr_hi_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_rdwr_hi_vlds) |-> (os_gs_rdwr_hi_vld);
endproperty

a_ts_select_net_rdwr_hi_check2: assert property (ts_select_net_rdwr_hi_check2)
  else $error("%m %t OS_SEL_NET for RDWR_HI - there are active requests but none is served ", $time);

// OS_SEL_NET for RDWR_LO
// - check that if the oldest bank requests then it is served
property ts_select_net_rdwr_lo_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_rdwr_lo_vlds[lo_rdwr_bsm_hint_r] == 1'b1) |-> (os_gs_rdwr_lo_vld & (lo_rdwr_bsm_hint_r == os_gs_rdwr_lo_bsm));
endproperty

a_ts_select_net_rdwr_lo_check1: assert property (ts_select_net_rdwr_lo_check1)
  else $error("%m %t OS_SEL_NET for RDWR_LO - oldest bank%0d is requesting but is not served ", $time, lo_rdwr_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_rdwr_lo_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_rdwr_lo_vlds) |-> (os_gs_rdwr_lo_vld);
endproperty

a_ts_select_net_rdwr_lo_check2: assert property (ts_select_net_rdwr_lo_check2)
  else $error("%m %t OS_SEL_NET for RDWR_LO - there are active requests but none is served ", $time);
   

// OS_SEL_NET for ACT_HI
// - check that if the oldest bank requests then it is served
property ts_select_net_act_hi_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_act_hi_vlds[hi_act_bsm_hint_r] == 1'b1) |-> (os_gs_act_hi_vld & (hi_act_bsm_hint_r == os_gs_act_hi_bsm));
endproperty

a_ts_select_net_act_hi_check1: assert property (ts_select_net_act_hi_check1)
  else $error("%m %t OS_SEL_NET for ACT_HI - oldest bank%0d is requesting but is not served ", $time, hi_act_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_act_hi_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_act_hi_vlds) |-> (os_gs_act_hi_vld);
endproperty

a_ts_select_net_act_hi_check2: assert property (ts_select_net_act_hi_check2)
  else $error("%m %t OS_SEL_NET for ACT_HI - there are active requests but none is served ", $time);


// OS_SEL_NET for ACT_LO
// - check that if the oldest bank requests then it is served
property ts_select_net_act_lo_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_act_lo_vlds[lo_act_bsm_hint_r] == 1'b1) |-> (os_gs_act_lo_vld & (lo_act_bsm_hint_r == os_gs_act_lo_bsm));
endproperty

a_ts_select_net_act_lo_check1: assert property (ts_select_net_act_lo_check1)
  else $error("%m %t OS_SEL_NET for ACT_LO - oldest bank%0d is requesting but is not served ", $time, lo_act_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_act_lo_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_act_lo_vlds) |-> (os_gs_act_lo_vld);
endproperty

a_ts_select_net_act_lo_check2: assert property (ts_select_net_act_lo_check2)
  else $error("%m %t OS_SEL_NET for ACT_LO - there are active requests but none is served ", $time);


// OS_SEL_NET for PRE_REQ
// - check that if the oldest bank requests then it is served
property ts_select_net_pre_req_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_pre_req_vlds[pre_req_bsm_hint_r] == 1'b1) |-> (os_gs_pre_req_vld & (pre_req_bsm_hint_r == os_gs_pre_req_bsm));
endproperty

a_ts_select_net_pre_req_check1: assert property (ts_select_net_pre_req_check1)
  else $error("%m %t OS_SEL_NET for PRE_REQ - oldest bank%0d is requesting but is not served ", $time, pre_req_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_pre_req_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_pre_req_vlds) |-> (os_gs_pre_req_vld);
endproperty

a_ts_select_net_pre_req_check2: assert property (ts_select_net_pre_req_check2)
  else $error("%m %t OS_SEL_NET for PRE_REQ - there are active requests but none is served ", $time);


// OS_SEL_NET for PRE_CRIT
// - check that if the oldest bank requests then it is served
property ts_select_net_pre_crit_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_pre_crit_vlds[0] == 1'b1) |-> (os_gs_pre_crit_vld & (0 == os_gs_pre_crit_bsm));
endproperty

a_ts_select_net_pre_crit_check1: assert property (ts_select_net_pre_crit_check1)
  else $error("%m %t OS_SEL_NET for PRE_CRIT - oldest bank%0d is requesting but is not served ", $time, 0);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_pre_crit_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_pre_crit_vlds) |-> (os_gs_pre_crit_vld);
endproperty

a_ts_select_net_pre_crit_check2: assert property (ts_select_net_pre_crit_check2)
  else $error("%m %t OS_SEL_NET for PRE_CRIT - there are active requests but none is served ", $time);

// OS_SEL_NET for ACT_WR
// - check that if the oldest bank requests then it is served
property ts_select_net_act_wr_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_act_wr_vlds[wr_act_bsm_hint_r] == 1'b1) |-> (os_gs_act_wr_vld & (wr_act_bsm_hint_r == os_gs_act_wr_bsm));
endproperty

a_ts_select_net_act_wr_check1: assert property (ts_select_net_act_wr_check1)
  else $error("%m %t OS_SEL_NET for ACT_WR - oldest bank%0d is requesting but is not served ", $time, wr_act_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_act_wr_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_act_wr_vlds) |-> (os_gs_act_wr_vld);
endproperty
        
a_ts_select_net_act_wr_check2: assert property (ts_select_net_act_wr_check2)
  else $error("%m %t OS_SEL_NET for ACT_WR - there are active requests but none is served ", $time);


// OS_SEL_NET for PRE_REQ_WR
// - check that if the oldest bank requests then it is served
property ts_select_net_pre_req_wr_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (bs_os_pre_req_wr_vlds[wr_pre_req_bsm_hint_r] == 1'b1) |-> (os_gs_pre_req_wr_vld & (wr_pre_req_bsm_hint_r == os_gs_pre_req_wr_bsm));
endproperty

a_ts_select_net_pre_req_wr_check1: assert property (ts_select_net_pre_req_wr_check1)
  else $error("%m %t OS_SEL_NET for PRE_REQ_WR - oldest bank%0d is requesting but is not served ", $time, wr_pre_req_bsm_hint_r);

// - check that vld is continuously active as long as there are active requests
property ts_select_net_pre_req_wr_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (| bs_os_pre_req_wr_vlds) |-> (os_gs_pre_req_wr_vld);
endproperty
        
a_ts_select_net_pre_req_wr_check2: assert property (ts_select_net_pre_req_wr_check2)
  else $error("%m %t OS_SEL_NET for PRE_REQ_WR - there are active requests but none is served ", $time);

// - check that if the oldest bank requests then it is served
property ts_top_select_act_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  gs_op_is_act |-> ((os_gs_act_hi_vld & (gs_act_bsm_num == os_gs_act_hi_bsm)) |
                              (os_gs_act_lo_vld & (gs_act_bsm_num == os_gs_act_lo_bsm)) |
                              (os_gs_act_wr_vld & (gs_act_bsm_num == os_gs_act_wr_bsm)) 
                                                  );
endproperty

a_ts_top_select_act_check1: assert property (ts_top_select_act_check1)
  else $error("%m %t ACT BSM_NUM for pi - oldest bank%0d is requesting but is not served ", $time, gs_act_bsm_num);

wire pri_select_rd;
wire pri_select_wr;
wire choose_act;
wire choose_pre_req;
assign pri_select_rd = gs_ts_any_vpr_timed_out_r | 
                     (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & |te_rws_rd_col_bank_r & ~|te_rws_wr_col_bank_r) |
                     (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & |te_rws_rd_col_bank_r &  ~gs_te_wr_mode_r) |
                     (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & ~|te_rws_wr_col_bank_r & rd_more_crit_r) | 
                     (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & ~|te_rws_wr_col_bank_r & ~rd_more_crit_r & ~wr_more_crit_r & ~gs_te_wr_mode_r);

assign pri_select_wr = (~gs_ts_any_vpr_timed_out_r & gs_ts_any_vpw_timed_out_r) | 
                       (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & |te_rws_wr_col_bank_r & ~|te_rws_rd_col_bank_r) |
                       (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & |te_rws_wr_col_bank_r & gs_te_wr_mode_r) |
                       (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & ~|te_rws_rd_col_bank_r & wr_more_crit_r) |
                       (~gs_ts_any_vpr_timed_out_r & ~gs_ts_any_vpw_timed_out_r & ~|te_rws_rd_col_bank_r & ~rd_more_crit_r & gs_te_wr_mode_r);
 
// - check that vld is continuously active as long as there are active requests
property ts_top_select_act_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  gs_op_is_act |-> (os_gs_act_hi_vld & gs_te_pri_level & pri_select_rd) |
                             (os_gs_act_lo_vld & ~gs_te_pri_level & pri_select_rd) |
                             (os_gs_act_wr_vld & pri_select_wr) |
                             ((os_gs_act_hi_vld | os_gs_act_lo_vld | os_gs_act_wr_vld) & ~os_gs_pre_req_vld & ~os_gs_pre_req_wr_vld) 
                          | (~(dh_gs_2t_mode | dh_gs_lpddr4 | reg_ddrc_lpddr5) & (os_gs_act_lo_vld | os_gs_act_hi_vld | os_gs_act_wr_vld)) 
                              ;
endproperty


// TODO:SN - Bug 10006
 a_ts_top_select_act_check2: assert property (ts_top_select_act_check2)
   else $error("%m %t ACTIVATE Request for pi - there are activate requests but none is served ", $time);

// - check that vld is continuously active as long as there are active requests
property ts_top_select_act_check3;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (os_gs_act_hi_vld | os_gs_act_lo_vld | os_gs_act_wr_vld) & choose_act |-> gs_op_is_act;
endproperty

 a_ts_top_select_act_check3: assert property (ts_top_select_act_check3)
   else $error("%m %t ACTIVATE Request for pi - there are activate requests but none is served ", $time);

    assign choose_act   = (no_rdwr_cmd
                            | (reg_ddrc_lpddr5 && !gs_cas_ws_req && (wr_mode || !pi_col_b3))    // RD/WR without CAS
                           )
                        & (no_critical_global_cmd)
                        & (~block_t_xs)
                        & (~no_ops_allowed)
                        & (~pi_gs_noxact)
                        & (~dh_gs_2t_mode || (dh_gs_2t_mode && no_critical_cmd))
                        & (~(|(critical_ref_possible_wo_trrd
                              )))
                        & (no_critical_cmd)
                        & (
                           (~choose_ref_req &
                            (((reverse_priority ? (os_gs_act_lo_vld & gs_act_pre_rd_priority) : (os_gs_act_hi_vld & gs_act_pre_rd_priority)) | (os_gs_act_wr_vld & ~gs_act_pre_rd_priority))                   |   // HP act
                            ((os_gs_act_hi_vld | os_gs_act_lo_vld | os_gs_act_wr_vld) & ~os_gs_pre_req_vld & ~os_gs_pre_req_wr_vld)                    // LP act
                            )
                           )
                          )
                        // do not overlap with ZQ command, to any rank
                        & (~(|rank_nop_after_zqcs))
                        ;

    assign choose_pre_req   =
                            (no_critical_cmd | (dh_gs_frequency_ratio & dh_gs_lpddr4 & no_critical_global_cmd & ~os_gs_pre_crit_vld))
                            //In LPDDR4 frequency ration 1:4 mode, REF and PRE command can be issued same time.
                            & ((dh_gs_frequency_ratio & dh_gs_lpddr4) | ((~(|speculative_ref_possible)) & (~(|critical_ref_possible))))
                            & (~block_t_xs)
                            & (~no_ops_allowed)
                            & (~pi_gs_noxact)
                            & no_simul_cmd_pre
                            // In LPDDR4, blocks an extra cycles after ACT/RD/WR/MWR/REF to different bank of same rank
                            & ~(|(~gs_pre_cs_n & rank_block_pre))
                            ;


// - check that vld is continuously precahrge as long as there are active requests
wire pri_select_act;
assign pri_select_act = (os_gs_act_hi_vld & gs_te_pri_level & pri_select_rd) |
                        (os_gs_act_lo_vld & ~gs_te_pri_level & pri_select_rd) |
                        (os_gs_act_wr_vld & pri_select_wr) ;
                        
// - check that if the oldest bank requests then it is served
property ts_top_select_pre_check1;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  gs_op_is_pre |-> ((os_gs_pre_req_vld & ~os_gs_pre_crit_vld & (gs_pre_bsm_num == os_gs_pre_req_bsm)) |
                             (os_gs_pre_req_wr_vld & ~os_gs_pre_crit_vld & (gs_pre_bsm_num == os_gs_pre_req_wr_bsm)) |
                             (os_gs_pre_crit_vld & (gs_pre_bsm_num == os_gs_pre_crit_bsm))  
                                                  );
endproperty

a_ts_top_select_pre_check1: assert property (ts_top_select_pre_check1)
  else $error("%m %t PRE BSM_NUM for pi - oldest bank%0d is requesting but is not served ", $time, gs_act_bsm_num);

property ts_top_select_pre_check2;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  gs_op_is_pre |-> (os_gs_pre_req_vld & ~os_gs_pre_crit_vld & ~pri_select_act & (pri_select_rd | ~os_gs_pre_req_wr_vld)) |
                            (os_gs_pre_req_wr_vld & ~os_gs_pre_crit_vld & ~pri_select_act & (pri_select_wr | ~os_gs_pre_req_vld)) |
                            (os_gs_pre_crit_vld) 
                            | ((os_gs_pre_req_vld | os_gs_pre_req_wr_vld) & (~dh_gs_frequency_ratio & ~dh_gs_2t_mode & ~(dh_gs_lpddr4 | reg_ddrc_lpddr5)))
                              ;
endproperty
        
 // TODO:SN - Bug 10006
 a_ts_top_select_pre_check2: assert property (ts_top_select_pre_check2)
   else $error("%m %t PRECHARGE Request for pi - there are precharge requests but none is served ", $time);

wire [SEL_ACT_TWDT-1:0] exp_act_page;

assign exp_act_page = (os_gs_act_hi_vld & ((gs_te_pri_level & pri_select_rd) | (~(os_gs_act_lo_vld & ~gs_te_pri_level) & ~(os_gs_act_wr_vld & pri_select_wr)))) ? act_hi_tag_selected :
                      (os_gs_act_lo_vld & ((~gs_te_pri_level & pri_select_rd) | (~(os_gs_act_hi_vld & gs_te_pri_level) & ~(os_gs_act_wr_vld & pri_select_wr)))) ? act_lo_tag_selected :
                      (os_gs_act_wr_vld & (pri_select_wr | (~(os_gs_act_hi_vld & pri_select_rd) & ~(os_gs_act_lo_vld & pri_select_rd)))) ? act_wr_tag_selected :
                      act_hi_tag_selected;
                                                  
localparam ACT_TAG_ACT2_BANK_BITS = 0
                                    + 1
                                    ;
// - check that if the oldest bank requests then it is served
property ts_top_select_act_page_check;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  ts_act_page == exp_act_page[SEL_ACT_TWDT-1:ACT_TAG_ACT2_BANK_BITS];
endproperty
 
// TODO:SN - Bug 10006
a_ts_top_select_act_page_check: assert property (ts_top_select_act_page_check)
  else $error("%m %t ACT PAGE for pi - oldest bank%0d is requesting but is not served ", $time, ts_act_page);

// - check that vld is continuously active as long as there are active requests
property ts_top_select_pre_check3;
  @(posedge clk) disable iff (~core_ddrc_rstn)
  (os_gs_pre_req_vld | os_gs_pre_req_wr_vld) & choose_pre_req |-> gs_op_is_pre;
endproperty

 a_ts_top_select_pre_check3: assert property (ts_top_select_pre_check3)
   else $error("%m %t PRECHARGE Request for pi - there are precharge requests but none is served ", $time);



// ----------------------------------------------------------------------------
// coverage points
// ----------------------------------------------------------------------------

endmodule  // ts_assertions
`endif // `ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON
