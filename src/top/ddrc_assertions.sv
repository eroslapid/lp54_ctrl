//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/top/ddrc_assertions.sv#1 $
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
//
// ----------------------------------------------------------------------------


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module ddrc_assertions
import DWC_ddrctl_reg_pkg::*;
(
        core_ddrc_core_clk,
        core_ddrc_rstn,
        reg_ddrc_data_bus_width,
        reg_ddrc_t_mr,
        hif_cmd_valid,
        hif_cmd_stall,
        hif_cmd_type,
        hif_cmd_pri,
        hif_cmd_token,
//        dis_assert_core_refresh_latency,
        reg_ddrc_dm_en,
        reg_ddrc_burst_rdwr,
        reg_ddrc_dfi_tphy_wrlat,
        reg_ddrc_dfi_tphy_wrdata,
        reg_ddrc_rank_refresh,
        reg_ddrc_dis_auto_refresh,
        reg_ddrc_ctrlupd,
        reg_ddrc_dis_auto_ctrlupd,
        reg_ddrc_dis_auto_ctrlupd_srx,
        reg_ddrc_en_2t_timing_mode,
        reg_ddrc_zq_calib_short,
        reg_ddrc_dis_auto_zq,
        reg_ddrc_dis_srx_zqcl,
        reg_ddrc_zq_resistor_shared,
        reg_ddrc_t_zq_short_nop,
        reg_ddrc_t_zq_long_nop,
        reg_ddrc_refresh_burst,
        reg_ddrc_t_refi_x32,
        reg_ddrc_t_ras_min,
        reg_ddrc_t_rfc_min,

        dfi_cke,
        dfi_cs,
        dfi_ctrlupd_ack,
        dfi_ctrlupd_req,
        reg_ddrc_dfi_phyupd_en,
        reg_ddrc_lpr_num_entries,
        dfi_phyupd_req,
        dfi_phyupd_ack,
        dfi_lp_ctrl_ack,
        dfi_lp_data_ack,
        dfi_cmd_delay,
        ddrc_reg_operating_mode,
        ddrc_reg_wr_data_pipeline_empty,
        ddrc_reg_rd_data_pipeline_empty,

        ddrc_reg_selfref_state,
        ih_te_rd_valid,
        ih_te_wr_valid,
        ih_te_rmw_type,
        wu_me_wvalid,                   // write enable to the wdata_ram
        wu_me_waddr,                    // write address to the wdata_ram
        mr_me_re,                       // read enable to the wdata_ram
        mr_me_raddr,                    // read address to the wdata_ram
        hif_rdata_token,
        hif_rdata_valid,
        hif_rdata_end
        ,reg_ddrc_per_bank_refresh
        ,reg_ddrc_lpddr4
        ,reg_ddrc_lpddr5
        ,reg_ddrc_bank_org
        ,reg_ddrc_dfi_t_ctrl_delay
        ,reg_ddrc_dfi_t_dram_clk_disable
        ,reg_ddrc_t_rcd
        ,reg_ddrc_t_rp
        ,reg_ddrc_wr2pre
        ,reg_ddrc_rd2pre
        ,reg_ddrc_wra2pre
        ,reg_ddrc_rda2pre
        ,dfi_dram_clk_disable_bit_0
        ,dh_gs_stay_in_selfref
        ,gs_pi_op_is_exit_selfref
        ,reg_ddrc_frequency_ratio
);

//------------------------------------------------------------------------------
// parameters
//------------------------------------------------------------------------------
parameter       CHANNEL_NUM = 0;
parameter       SHARED_AC = 0;
parameter       WRDATA_RAM_ADDR_WIDTH = 3;      // correct value is passed from the top level
parameter       CORE_TAG_WIDTH  = `MEMC_TAGBITS;                         // width of tag
parameter       BANK_BITS       = `MEMC_BANK_BITS;
parameter       BG_BITS         = `MEMC_BG_BITS;
parameter       RD_CAM_ADDR_WIDTH  = `MEMC_RDCMD_ENTRY_BITS;


parameter       NUM_RANKS       = `MEMC_NUM_RANKS;              // max supported ranks (chip selects)
parameter       NUM_LRANKS      = `UMCTL2_NUM_LRANKS_TOTAL;     // max supported ranks (chip selects)

parameter T_REFI_X1_X32_WIDTH            = 1;
parameter T_RFC_MIN_WIDTH            = 1;
parameter T_RAS_MIN_WIDTH            = 1;

parameter T_RCD_WIDTH                = 1;
parameter T_RP_WIDTH                 = 1;

parameter RD2PRE_WIDTH               = 1;
parameter WR2PRE_WIDTH               = 1;

parameter T_MR_WIDTH  = 1; 
localparam      CMD_IF_WIDTH    = `MEMC_FREQ_RATIO; // 1 : when DFI is in 1:1 mode
                                                              // 2 : when DFI is in 1:2 mode

parameter CMD_DELAY_BITS         = `UMCTL2_CMD_DELAY_BITS;



//------------------------------------------------------------------------------
// inputs & outputs
//------------------------------------------------------------------------------

input                        core_ddrc_core_clk;
input                        core_ddrc_rstn;
input[1:0]                   reg_ddrc_data_bus_width;         // 00 - full DRAM bus width
                                                              // 01 - 1/2 DRAM bus width
                                                              // 10 - 1/4 DRAM bus width
                                                              // 11 - RESERVED
input [T_MR_WIDTH-1:0]       reg_ddrc_t_mr;
input                        hif_cmd_valid;
input                        hif_cmd_stall;
input[1:0]                   hif_cmd_type;
input[1:0]                   hif_cmd_pri;
input[CORE_TAG_WIDTH-1:0]    hif_cmd_token;
input[CORE_TAG_WIDTH-1:0]    hif_rdata_token;
input                        hif_rdata_valid;
input                        hif_rdata_end;
//input                        dis_assert_core_refresh_latency;
input                        reg_ddrc_dm_en;
input   [3:0]                reg_ddrc_burst_rdwr;
input [DFI_TPHY_WRLAT_WIDTH-1:0]     reg_ddrc_dfi_tphy_wrlat;       // Used to calculate latency through DFI block
input [5:0]                  reg_ddrc_dfi_tphy_wrdata;      // Used to calculate latency through DFI block
input                        ih_te_rd_valid;
input                        ih_te_wr_valid;
input[1:0]                   ih_te_rmw_type;

input                                wu_me_wvalid;      // write enable to the write data RAM
input[WRDATA_RAM_ADDR_WIDTH-1:0]     wu_me_waddr;       // write address to the write data RAM
input                                mr_me_re;          // read enable to the write data RAM
input[WRDATA_RAM_ADDR_WIDTH-1:0]     mr_me_raddr;       // read address to the write data RAM

input   [NUM_LRANKS-1:0]        reg_ddrc_rank_refresh;
input                           reg_ddrc_dis_auto_refresh;      // 1= disable auto_refresh issued by
                                                                // the controller. Issue refresh based only
                                                                // on the rank_refresh command from APB registers 
input                           reg_ddrc_ctrlupd;               // ctrlupd command 
input                           reg_ddrc_dis_auto_ctrlupd;      // 1 = disable ctrlupd issued by the controller
                                                                // ctrlupd command will be issued by APB register reg_ddrc_ctrlupd
                                                                // 0 = enable ctrlupd issued by the controller
input                           reg_ddrc_dis_auto_ctrlupd_srx;  // 1 = disable ctrlupd issued by the controller following a self-refresh exit
                                                                // ctrlupd command will be issued by APB register reg_ddrc_ctrlupd
                                                                // 0 = enable ctrlupd issued by the controller following a self-refresh exit                                                             
input                           reg_ddrc_en_2t_timing_mode;

input                           reg_ddrc_zq_calib_short;
input                           reg_ddrc_dis_auto_zq;
input                           reg_ddrc_dis_srx_zqcl;
input                           reg_ddrc_zq_resistor_shared;
input [9:0]                     reg_ddrc_t_zq_short_nop;
input [13:0]                    reg_ddrc_t_zq_long_nop;
input   [5:0]                   reg_ddrc_refresh_burst;

input   [T_REFI_X1_X32_WIDTH-1:0]                  reg_ddrc_t_refi_x32;         // tRFC(nom): nominal avg. required refresh period
input   [T_RFC_MIN_WIDTH-1:0] reg_ddrc_t_rfc_min;
input   [T_RAS_MIN_WIDTH-1:0] reg_ddrc_t_ras_min;


input  [(CMD_IF_WIDTH*NUM_RANKS)-1:0]    dfi_cke;
input  [(CMD_IF_WIDTH*NUM_RANKS)-1:0]    dfi_cs;


input                          dfi_ctrlupd_ack; // this ack is from PHY
input                          dfi_ctrlupd_req;
input                         reg_ddrc_dfi_phyupd_en;
input  [RD_CAM_ADDR_WIDTH-1:0] reg_ddrc_lpr_num_entries;
input                          dfi_phyupd_req;
input                          dfi_phyupd_ack;
input                          dfi_lp_ctrl_ack;
input                          dfi_lp_data_ack;
input  [CMD_DELAY_BITS-1:0]    dfi_cmd_delay;


input  [2:0]                   ddrc_reg_operating_mode;               // global schedule FSM state
input                          ddrc_reg_wr_data_pipeline_empty;
input                          ddrc_reg_rd_data_pipeline_empty;

    input [2:0] ddrc_reg_selfref_state;

input                   reg_ddrc_per_bank_refresh;      // REF Per bank
input                   reg_ddrc_lpddr4;
input                   reg_ddrc_lpddr5;
input [1:0]             reg_ddrc_bank_org;

input [4:0]             reg_ddrc_dfi_t_ctrl_delay;
input [4:0]             reg_ddrc_dfi_t_dram_clk_disable;
input [T_RCD_WIDTH-1:0] reg_ddrc_t_rcd;
input [T_RP_WIDTH-1:0] reg_ddrc_t_rp;
input [WR2PRE_WIDTH-1:0] reg_ddrc_wr2pre;
input [RD2PRE_WIDTH-1:0] reg_ddrc_rd2pre;
input [WR2PRE_WIDTH-1:0] reg_ddrc_wra2pre;
input [RD2PRE_WIDTH-1:0] reg_ddrc_rda2pre;
input                   dfi_dram_clk_disable_bit_0;
input                   dh_gs_stay_in_selfref;
input                   gs_pi_op_is_exit_selfref;
input                   reg_ddrc_frequency_ratio;

//------------------------------------------------------------------------------
// Assertions and Checks
//------------------------------------------------------------------------------
// Verilog to support subsequent SystemVerilog checks

// Track tags that are in-use in the controller
//reg [(1<<CORE_TAG_WIDTH)-1:0] tags_used;

// Not using the tag_width parameter above because, if the tag_width is a large number (above 16)
// compile error happens because the width of the vector tags_used becomes 2^16 (or such large number)
// In reality the tag in the controller need to have smaller width only as the outstanding tokens
// in the controller is usually small number (depth of read cam). Hence here the width of tags_used
// has been hard coded to 16
wire [CORE_TAG_WIDTH-1:0]    hif_cmd_token_check;
wire [CORE_TAG_WIDTH-1:0]    hif_rdata_token_check;
assign hif_cmd_token_check = hif_cmd_token;
assign hif_rdata_token_check = hif_rdata_token;

reg     tags_used [*];

always @ (posedge core_ddrc_core_clk or posedge core_ddrc_rstn)
        begin
                if (hif_cmd_valid & ~hif_cmd_stall & (hif_cmd_type==2'b01))
                        tags_used[hif_cmd_token_check]      = 1'b1;
                if (hif_rdata_valid & hif_rdata_end)
                        tags_used.delete(hif_rdata_token_check);
                if (~core_ddrc_rstn)
                        tags_used.delete();

        end


reg hif_cmd_token_exists;
reg hif_rdata_token_exists;
initial
begin
   wait (core_ddrc_rstn);
   forever
   begin
      assert_co_ih_token_check : assert (!(hif_cmd_valid & ~hif_cmd_stall & (hif_cmd_type==2'b01) & ((^hif_cmd_token) === 1'bX)))
      else `SNPS_SVA_MSG("ERROR", $sformatf ("hif_cmd_token is %h", hif_cmd_token));

      assert_hif_rdata_token_check : assert (!((hif_rdata_valid) && ((^hif_rdata_token) === 1'bX)))
      else `SNPS_SVA_MSG("ERROR", $sformatf ("hif_rdata_token is %h", hif_rdata_token));

      if ((^hif_cmd_token) === 1'bX)
      begin
          hif_cmd_token_exists <= 1'b0;
      end
      else
      begin
          if (hif_cmd_valid & ~hif_cmd_stall & (hif_cmd_type==2'b01))
             hif_cmd_token_exists <= tags_used.exists(hif_cmd_token_check);
          else
             hif_cmd_token_exists <= 1'b0;
      end
      if ((^hif_rdata_token) === 1'bX)
      begin
             hif_rdata_token_exists  <= 1'b0;
      end
      else
      begin
          if (hif_rdata_valid)
             hif_rdata_token_exists  <= tags_used.exists(hif_rdata_token_check);
          else
             hif_rdata_token_exists  <= 1'b0;
      end
      @(negedge core_ddrc_core_clk);
   end
end

// Once fatal erorr is detected by retry logic, Tag check should be disabled 


// DDRC checks
DDRC_tagsOnlyUsedOnce: // Check that tags are not used twice in the controller
    assert property ( @ (posedge core_ddrc_core_clk) disable iff (~core_ddrc_rstn)
                        (!(hif_cmd_valid & ~hif_cmd_stall & (hif_cmd_type==2'b01) & hif_cmd_token_exists ) ) )
    else `SNPS_SVA_MSG("ERROR", $sformatf("Same tag issued to controller twice: 0x%x; it will be impossible to differentiate responses",
                hif_cmd_token));

DDRC_respTagInUse: // Check that any tag that goes out of the CAM was in use in the CAM
    assert property ( @ (posedge core_ddrc_core_clk) disable iff (~core_ddrc_rstn)
                      (hif_rdata_valid |-> hif_rdata_token_exists ) )
    else `SNPS_SVA_MSG("ERROR", $sformatf("DDRC responded with tag that was not present in the controller: %x",
                hif_rdata_token));

//------------------------------------------------------------------------------
wire    [CMD_IF_WIDTH-1:0]               act_n = {CMD_IF_WIDTH{1'b1}};

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------

// High priority reads check (if the number of low priority credits is equal to the cam depth - 1, then no high priority credits are available, hence hpr must not be requested)

property hpr_with_no_credits;
        @(posedge core_ddrc_core_clk) disable iff (~core_ddrc_rstn)
                (~((hif_cmd_pri==2'b10) && reg_ddrc_lpr_num_entries == (`MEMC_NO_OF_ENTRY-1) && hif_cmd_type == 2'b01 && hif_cmd_valid));
endproperty


assert_hpr_req_with_no_credit: assert property (hpr_with_no_credits) else
                              `SNPS_SVA_MSG("ERROR", $sformatf("Illegal HPR request when number of LPR entries is %0d and total number of entries is %0d",reg_ddrc_lpr_num_entries,`MEMC_NO_OF_ENTRY));

//------------------------------------------------------------------------------

wire    [`MEMC_NUM_RANKS-1:0] ddrc_phy_refresh;

reg     [NUM_LRANKS-1:0]         reg_ddrc_rank_refresh_r;
reg     [NUM_LRANKS-1:0]         reg_ddrc_rank_refresh_2r;
reg     [9:0]           core_refresh_interval_cnt [NUM_LRANKS];

wire [9:0] core_refresh_interval_cnt_0_w;
assign core_refresh_interval_cnt_0_w = core_refresh_interval_cnt[0][9:0];



always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
   if(~core_ddrc_rstn) begin
        reg_ddrc_rank_refresh_r       <= {NUM_LRANKS{1'b0}};
        reg_ddrc_rank_refresh_2r      <= {NUM_LRANKS{1'b0}};
   end
   else begin
        reg_ddrc_rank_refresh_r       <= reg_ddrc_rank_refresh;
        reg_ddrc_rank_refresh_2r      <= reg_ddrc_rank_refresh_r;
   end


// Number of active ranks(physical ranks)
wire [31:0] num_physical_ranks =
    1
;
// Number of logical ranks per physical rank
wire [31:0] num_logicalranks = 
   1
;

wire [31:0]           active_logical_rank_full = (1 << (num_physical_ranks * num_logicalranks)) - 1;


genvar gen_ranks1;
generate

for (gen_ranks1=0; gen_ranks1<NUM_LRANKS; gen_ranks1=gen_ranks1+1) begin : cnt_define

    // set this counter to trfc(min) when a refresh request comes from the core
    // decrement it every clock afterwards until it reach 0
    // resetss to 0 if in Self Refresh, as core_ddrc_core_clk could be
    // removed while in Self Refresh
    always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
       if(~core_ddrc_rstn)
            core_refresh_interval_cnt[gen_ranks1] <= 10'h0;
       else begin
          // reset if in Self Refresh, as core_ddrc_core_clk could be removed
          if ((ddrc_reg_operating_mode == 'h3))
                core_refresh_interval_cnt[gen_ranks1] <= 10'h0;        
          else if(reg_ddrc_dis_auto_refresh && 
                   reg_ddrc_rank_refresh[gen_ranks1]
                   && active_logical_rank_full[gen_ranks1]
            )
               core_refresh_interval_cnt[gen_ranks1] <= reg_ddrc_t_rfc_min-1;
          else if(core_refresh_interval_cnt[gen_ranks1] != 10'h0)
               core_refresh_interval_cnt[gen_ranks1] <= core_refresh_interval_cnt[gen_ranks1] - 1'b1;
       end
    end
end // for

endgenerate

//------------------------------------------------------------------------------
int i;
reg [T_RFC_MIN_WIDTH-1:0]   dly1_reg_ddrc_t_rfc_min_r;
reg [T_RFC_MIN_WIDTH-1:0]   dly2_reg_ddrc_t_rfc_min_r;
reg [T_RFC_MIN_WIDTH-1:0]   t_rfc_min_r [NUM_LRANKS-1:0];

// Delay as refresh command latency
always @ (posedge core_ddrc_core_clk) begin
    dly1_reg_ddrc_t_rfc_min_r <= reg_ddrc_t_rfc_min;
    dly2_reg_ddrc_t_rfc_min_r <= dly1_reg_ddrc_t_rfc_min_r;
end

// latch tRFC value, same timing as uMCTL2's internal tRFC value
always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if(~core_ddrc_rstn)
        for ( i=0; i < NUM_LRANKS; i=i+1) begin
            t_rfc_min_r[i] <= 0;
        end
    else
        for (i=0; i < NUM_LRANKS; i=i+1) begin
            if (ddrc_phy_refresh[i])
                t_rfc_min_r[i] <= dly2_reg_ddrc_t_rfc_min_r;
        end
end


//------------------------------------------------------------------------------
property p_stable_dfi_cmd_delay;
        @(posedge core_ddrc_core_clk) disable iff ((~core_ddrc_rstn) || (ddrc_reg_operating_mode!=1))
                ($past(dfi_cmd_delay)==dfi_cmd_delay);
endproperty
assert_stable_dfi_cmd_delay: assert property (p_stable_dfi_cmd_delay) else
           `SNPS_SVA_MSG("ERROR", "dfi_cmd_delay was changed during Normal operating mode.");

//------------------------------------------------------------------------------
covergroup cg_dfi_cmd_delay @(posedge core_ddrc_core_clk);



    // Observe dfi_cmd_delay
    cp_dfi_cmd_delay_lpddr4: coverpoint (dfi_cmd_delay) iff(core_ddrc_rstn && (ddrc_reg_operating_mode==1) && reg_ddrc_lpddr4) {
              bins dly0 = {0};
              bins dly1 = {1};
              bins dly2 = {2};
              bins dly3 = {3};
    }

    // Observe dfi_cmd_delay
    cp_dfi_cmd_delay_lpddr5: coverpoint (dfi_cmd_delay) iff(core_ddrc_rstn && (ddrc_reg_operating_mode==1) && reg_ddrc_lpddr5) {
              bins dly0 = {0};
              bins dly1 = {1};
              bins dly2 = {2};
              bins dly3 = {3};
    }

endgroup

cg_dfi_cmd_delay dfi_cmd_delay_inst = new();



endmodule
`endif // `ifndef SYNTHESIS
`endif // SNPS_ASSERT_ON
