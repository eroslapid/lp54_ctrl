//Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dr/derate.sv#2 $
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

`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module derate 
import DWC_ddrctl_reg_pkg::*;
(/*AUTOARG*/
   // Outputs
   mr4_req, derate_ddrc_t_rcd, derate_ddrc_t_ras_min,
   derate_ddrc_t_rc, derate_ddrc_t_rp,
   derate_ddrc_t_rrd, derate_ddrc_t_refie, derate_ddrc_t_refi, derate_refresh_update_level,
   derate_ddrc_t_rrd_s,
   max_postponed_ref_cmd, max_ref_cmd_within_2trefi,
   core_derate_temp_limit_intr,
   ddrc_reg_dbg_mr4_byte0_rank0,
   ddrc_reg_dbg_mr4_byte1_rank0,
   ddrc_reg_dbg_mr4_byte2_rank0,
   ddrc_reg_dbg_mr4_byte3_rank0,
   // Inputs
   clk, core_ddrc_rstn, reg_ddrc_mr4_read_interval,
   ddrc_reg_operating_mode,
   derate_sync_ack_c2p,
   reg_ddrc_t_rcd, reg_ddrc_t_ras_min,
   reg_ddrc_t_rc, reg_ddrc_t_rp, reg_ddrc_t_rrd, reg_ddrc_t_rrd_s,
   reg_ddrc_t_refi_x32, rt_rd_rd_mrr_ext, rd_mrr_data, 
   reg_ddrc_derate_enable,
   reg_ddrc_derated_t_rcd,
   reg_ddrc_derated_t_ras_min,
   reg_ddrc_derated_t_rp,
   reg_ddrc_derated_t_rrd,
   reg_ddrc_derated_t_rc,
   reg_ddrc_derate_mr4_tuf_dis,
   reg_ddrc_derate_mr4_pause_fc,
   reg_ddrc_lpddr4,
   reg_ddrc_lpddr5,
   reg_ddrc_t_refi_x1_sel,
   reg_ddrc_per_bank_refresh,
   reg_ddrc_auto_refab_en,
   derate_force_refab,
   reg_ddrc_lpddr4_refresh_mode,
   reg_ddrc_active_derate_byte_rank0,
   reg_ddrc_dis_trefi_x6x8,
   reg_ddrc_dis_trefi_x0125,
   rd_mrr_data_valid
   );

   //------------------------------------------------------------------------------
   // Parameters
   //------------------------------------------------------------------------------
   parameter NUM_RANKS                  = 1;
   parameter IDLE                       = 2'b00;
   parameter SEND_MRR_REQ               = 2'b01;
   parameter WAIT_MRR_DATA              = 2'b10;
   parameter DBG_MR4_BYTE_RANK_WIDTH    = 5;

   input                                                 clk;         
   input                                                 core_ddrc_rstn;      
   input [MR4_READ_INTERVAL_WIDTH-1:0]                   reg_ddrc_mr4_read_interval;
   input [2:0]                                           ddrc_reg_operating_mode;
   input [T_RCD_WIDTH-1:0]                               reg_ddrc_t_rcd;                       // tRCD: ACT to read/write delay
   input [T_RAS_MIN_WIDTH-1:0]                           reg_ddrc_t_ras_min;                   // tRAS(min): minimum page open time
   input [T_RC_WIDTH-1:0]                                reg_ddrc_t_rc;                        // tRC: row cycle time
   input [T_RP_WIDTH-1:0]                                reg_ddrc_t_rp;                        // tRP: row precharge time
   input [T_RRD_WIDTH-1:0]                               reg_ddrc_t_rrd;                       // tRRD: RAS-to-RAS min delay
   input [T_RRD_S_WIDTH-1:0]                             reg_ddrc_t_rrd_s;
   input [T_REFI_X1_X32_WIDTH-1:0]                              reg_ddrc_t_refi_x32;                  // tRFC(nom): nominal avg. required refresh period
   input [DERATE_ENABLE_WIDTH-1:0]                       reg_ddrc_derate_enable;               // Derate feature enabled
   input [DERATED_T_RCD_WIDTH-1:0]                       reg_ddrc_derated_t_rcd;
   input [DERATED_T_RAS_MIN_WIDTH-1:0]                   reg_ddrc_derated_t_ras_min;
   input [DERATED_T_RP_WIDTH-1:0]                        reg_ddrc_derated_t_rp;
   input [DERATED_T_RRD_WIDTH-1:0]                       reg_ddrc_derated_t_rrd;
   input [DERATED_T_RC_WIDTH-1:0]                        reg_ddrc_derated_t_rc;
   input                                                 reg_ddrc_derate_mr4_tuf_dis;
   input                                                 reg_ddrc_derate_mr4_pause_fc;
   input                                                 reg_ddrc_lpddr4;
   input                                                 reg_ddrc_lpddr5;
   input                                                 reg_ddrc_t_refi_x1_sel;
   input                                                 reg_ddrc_per_bank_refresh;
   input [1:0]                                           reg_ddrc_auto_refab_en;
   input                                                 rt_rd_rd_mrr_ext;                     // Indecates that MRR command via Software

   input [`MEMC_DRAM_TOTAL_DATA_WIDTH-1:0]               rd_mrr_data;
   input                                                 rd_mrr_data_valid;
   input                                                 derate_sync_ack_c2p;                  // Interrupt clear passed from CDC synchronizer
   input                                                 reg_ddrc_lpddr4_refresh_mode;         // 0:Legacy refresh mode, 1:Modified refresh mode
   input [ACTIVE_DERATE_BYTE_RANK_WIDTH-1:0]                  reg_ddrc_active_derate_byte_rank0;
   input                                                      reg_ddrc_dis_trefi_x6x8;
   input                                                      reg_ddrc_dis_trefi_x0125;
   
   output                                                mr4_req;
   output [T_RCD_WIDTH-1:0]                              derate_ddrc_t_rcd;                    // Derated tRCD
   output [T_RAS_MIN_WIDTH-1:0] derate_ddrc_t_ras_min;                // tRAS(min): minimum page open time
   output [T_RC_WIDTH-1:0]      derate_ddrc_t_rc;                     // tRC: row cycle time
   output [T_RP_WIDTH-1:0]      derate_ddrc_t_rp;                     // tRP: row precharge time
   output [T_RRD_WIDTH-1:0]     derate_ddrc_t_rrd;                    // tRRD: RAS-to-RAS min delay
   output [T_RRD_S_WIDTH-1:0]   derate_ddrc_t_rrd_s;
   output [T_REFI_X1_X32_WIDTH+4:0] derate_ddrc_t_refie;  
   output [T_REFI_X1_X32_WIDTH+4:0] derate_ddrc_t_refi;           
   output                   derate_refresh_update_level;          
   output                   derate_force_refab;                   // force all-bank refresh 
   output [5:0]             max_postponed_ref_cmd;                // Indicates the number of muximum postponed refresh command minus 1
   output [4:0]             max_ref_cmd_within_2trefi;            // Indicates that tha number of maximum refresh command within 2 * trefi
   output                   core_derate_temp_limit_intr;          // Derate interrupt signal
   output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte0_rank0;
   output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte1_rank0;
   output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte2_rank0;
   output [DBG_MR4_BYTE_RANK_WIDTH-1:0]                             ddrc_reg_dbg_mr4_byte3_rank0;
   
/*AUTOREG*/
   
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [T_RAS_MIN_WIDTH-1:0]           derate_ddrc_t_ras_min;
   reg [T_RC_WIDTH-1:0]                derate_ddrc_t_rc;
   reg [T_RCD_WIDTH-1:0]               derate_ddrc_t_rcd;
   wire [T_REFI_X1_X32_WIDTH+4:0]          derate_ddrc_t_refie;
   wire [T_REFI_X1_X32_WIDTH+4:0]          derate_ddrc_t_refi;
   reg [$bits(reg_ddrc_t_refi_x32)+2+5:0]           derate_ddrc_t_refie_int; // width is t_refie_WIDTH+3 as the maximum value is reg_ddrc_t_refi_x32 shifted by 3 bit and +5 bit due to per bank refresh
   reg [$bits(reg_ddrc_t_refi_x32)+2+5:0]           derate_ddrc_t_refi_int;       // width is t_refie_WIDTH+3 as the maximum value is reg_ddrc_t_refi_x32 shifted by 3 bit and +5 bit due to per bank refresh
   reg [T_RP_WIDTH-1:0]                derate_ddrc_t_rp;
   reg [T_RRD_WIDTH-1:0]               derate_ddrc_t_rrd;
   reg [T_RRD_S_WIDTH-1:0]             derate_ddrc_t_rrd_s;
   wire                     derate_refresh_adj_x2;
   wire                     derate_refresh_adj_x4;
   wire  [2:0]              max_num_of_postponed_refab;
   logic                    mr4_req;
   reg                      mr4_req_trigger;
   reg                      marged_tuf_r;
   reg                      rd_mrr_data_valid_r;
   wire  [4:0]              rd_mr4_data;
   wire  [4:0]              rd_mr4_data_worst;
   reg   [4:0]              rd_mr4_data_worst_rank0;
   reg [DBG_MR4_BYTE_RANK_WIDTH-1:0]        ddrc_reg_dbg_mr4_byte0_rank0;
   reg [DBG_MR4_BYTE_RANK_WIDTH-1:0]        ddrc_reg_dbg_mr4_byte1_rank0;
   reg [DBG_MR4_BYTE_RANK_WIDTH-1:0]        ddrc_reg_dbg_mr4_byte2_rank0;
   reg [DBG_MR4_BYTE_RANK_WIDTH-1:0]        ddrc_reg_dbg_mr4_byte3_rank0;
   reg                      core_derate_temp_limit_intr;         
   // End of automatics
   /*AUTOWIRE*/   



   reg [$bits(reg_ddrc_mr4_read_interval)-1:0] counter;

   reg derate_params;
   reg reduce_trfi_x07;  //tREFI*0.7 
   reg reduce_trfi_x05;  //tREFI*0.5
   reg reduce_trfi_x025; //tREFI*0.25
   reg reduce_trfi_x0125;//tREFI*0.125
   reg default_trfi_x1;  //tREFI*1
   reg boost_trfi_x1_3;  //tREFI*1.3
   reg boost_trfi_x1_7;  //tREFI*1.7
   reg boost_trfi_x2;    //tREFI*2.0
   reg boost_trfi_x2_5;  //tREFI*2.5
   reg boost_trfi_x3_3;  //tREFI*3.3
   reg boost_trfi_x4;    //tREFI*4.0
   reg boost_trfi_x6;    //tREFI*6
   reg boost_trfi_x8;    //tREFI*8

   reg reduce_trfi_x07_r;  //tREFI*0.7 
   reg reduce_trfi_x05_r;  //tREFI*0.5
   reg reduce_trfi_x025_r; //tREFI*0.25
   reg reduce_trfi_x0125_r;//tREFI*0.125
   reg default_trfi_x1_r;  //tREFI*1
   reg boost_trfi_x1_3_r;  //tREFI*1.3
   reg boost_trfi_x1_7_r;  //tREFI*1.7
   reg boost_trfi_x2_r;    //tREFI*2
   reg boost_trfi_x2_5_r;  //tREFI*2.5
   reg boost_trfi_x3_3_r;  //tREFI*3.3
   reg boost_trfi_x4_r;    //tREFI*4
   reg boost_trfi_x6_r;    //tREFI*6
   reg boost_trfi_x8_r;    //tREFI*8

   wire derate_params_w;

   wire reduce_trfi_x07_w;  //tREFI*0.7 
   wire reduce_trfi_x05_w;  //tREFI*0.5
   wire reduce_trfi_x025_w; //tREFI*0.25
   wire reduce_trfi_x0125_w;//tREFI*0.125
   wire default_trfi_x1_w;  //tREFI*1
   wire boost_trfi_x1_3_w;  //tREFI*1.3
   wire boost_trfi_x1_7_w;  //tREFI*1.7
   wire boost_trfi_x2_w;    //tREFI*2.0
   wire boost_trfi_x2_5_w;  //tREFI*2.5
   wire boost_trfi_x3_3_w;  //tREFI*3.3
   wire boost_trfi_x4_w;    //tREFI*4
   wire boost_trfi_x6_w;    //tREFI*6
   wire boost_trfi_x8_w;    //tREFI*8

   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x0125;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x025;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x05;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x07;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x10;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x1_3;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x1_7;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x20;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x2_5;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x3_3;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x40;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x60;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refie_x80;

   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x0125;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x025;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x05;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x07;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x10;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x20;
   wire [$bits(reg_ddrc_t_refi_x32)+2+5:0] t_refi_x40;

   reg derate_temp_limit_intr_trig_delay;       // Delayed interrupt trigger signal
   
   reg derate_refresh_update_level;
   wire derate_refresh_update_level_c;   
   
   wire             derate_temp_limit_intr_trig;   // Interrupt trigger signal
   // Derate interrupt trigger indicate whether HIGH/LOW temperature limit is exceeded or not. 
   // In LPDDR4 case:
   // MR4[2:0] = 3'b000: Low temperature limit is exceeded.
   // MR4[2:0] = 3'b111: High temperature limit is exceeded.
   // In LPDDR5 case:
   // MR4[4:0] = 5'b00000: Low temperature limit is exceeded.
   // MR4[4:0] = 5'b11111: High temperature limit is exceeded.
   // only sample if MR4[7]=1 or 
   // if usage or MR4[7] (TUF flag) is disabled via software
   wire             derate_temp_limit_over;   // Indicates temp limit over

//========================================================================================================================
//===========================================Calculate MRR data and TUF===================================================

wire                                  marged_tuf_w;

wire [ACTIVE_DERATE_BYTE_RANK_WIDTH-1:0]   active_derate_byte;
assign active_derate_byte = 
                                                  reg_ddrc_active_derate_byte_rank0;

      wire [4:0]  mr4_byte0;
      wire [4:0]  mr4_byte1;
      wire        tuf_byte0_w;
      wire        tuf_byte1_w;
      reg         tuf_byte0;
      reg         tuf_byte1;
      wire        derate_temp_limit_over_byte0;
      wire        derate_temp_limit_over_byte1;
      wire [4:0]  mr4_byte2;
      wire [4:0]  mr4_byte3;
      wire        tuf_byte2_w;
      wire        tuf_byte3_w;
      reg         tuf_byte2;
      reg         tuf_byte3;
      wire        derate_temp_limit_over_byte2;
      wire        derate_temp_limit_over_byte3;

      wire [31:0] actual_mrr_ref_rate_data;
      wire [4:0]  mrr_data_comp_tmp0;
      wire [4:0]  mrr_data_comp_tmp1;

      assign actual_mrr_ref_rate_data = (reg_ddrc_lpddr4) ? (32'h07_07_07_07 & rd_mrr_data) : //8'h07 = 8'b0000_0111, rd_mrr_data[2:0] is actual refresh rate data in LPDDR4 
                                                            (32'h1F_1F_1F_1F & rd_mrr_data) ; //8'h1F = 8'b0001_1111, rd_mrr_data[4:0] is actual refresh rate data in LPDDR5
      assign tuf_byte0_w = (active_derate_byte[0] & !rt_rd_rd_mrr_ext & (reg_ddrc_derate_mr4_tuf_dis | (!reg_ddrc_derate_mr4_tuf_dis & rd_mrr_data[7] )));
      assign tuf_byte1_w = (active_derate_byte[1] & !rt_rd_rd_mrr_ext & (reg_ddrc_derate_mr4_tuf_dis | (!reg_ddrc_derate_mr4_tuf_dis & rd_mrr_data[15])));
      assign tuf_byte2_w = (active_derate_byte[2] & !rt_rd_rd_mrr_ext & (reg_ddrc_derate_mr4_tuf_dis | (!reg_ddrc_derate_mr4_tuf_dis & rd_mrr_data[23])));
      assign tuf_byte3_w = (active_derate_byte[3] & !rt_rd_rd_mrr_ext & (reg_ddrc_derate_mr4_tuf_dis | (!reg_ddrc_derate_mr4_tuf_dis & rd_mrr_data[31])));

      always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
          tuf_byte0 <= 1'b0;
          tuf_byte1 <= 1'b0;
          tuf_byte2 <= 1'b0;
          tuf_byte3 <= 1'b0;
        end 
        else if(rd_mrr_data_valid) begin
          tuf_byte0 <= tuf_byte0_w;
          tuf_byte1 <= tuf_byte1_w;
          tuf_byte2 <= tuf_byte2_w;
          tuf_byte3 <= tuf_byte3_w;
        end
        else begin
          tuf_byte0 <= 1'b0;
          tuf_byte1 <= 1'b0;
          tuf_byte2 <= 1'b0;
          tuf_byte3 <= 1'b0;
        end  
      end

      always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
            ddrc_reg_dbg_mr4_byte0_rank0 <= 5'b0;
            ddrc_reg_dbg_mr4_byte1_rank0 <= 5'b0;
            ddrc_reg_dbg_mr4_byte2_rank0 <= 5'b0;
            ddrc_reg_dbg_mr4_byte3_rank0 <= 5'b0;
        end 
        else if(rd_mrr_data_valid) begin
             begin   
               ddrc_reg_dbg_mr4_byte0_rank0 <= (tuf_byte0_w) ? actual_mrr_ref_rate_data[4:0]   : ddrc_reg_dbg_mr4_byte0_rank0;
               ddrc_reg_dbg_mr4_byte1_rank0 <= (tuf_byte1_w) ? actual_mrr_ref_rate_data[12:8]  : ddrc_reg_dbg_mr4_byte1_rank0;
               ddrc_reg_dbg_mr4_byte2_rank0 <= (tuf_byte2_w) ? actual_mrr_ref_rate_data[20:16] : ddrc_reg_dbg_mr4_byte2_rank0;
               ddrc_reg_dbg_mr4_byte3_rank0 <= (tuf_byte3_w) ? actual_mrr_ref_rate_data[28:24] : ddrc_reg_dbg_mr4_byte3_rank0;
             end
        end
      end

      assign mr4_byte0 = ddrc_reg_dbg_mr4_byte0_rank0;
      assign mr4_byte1 = ddrc_reg_dbg_mr4_byte1_rank0;
      assign mr4_byte2 = ddrc_reg_dbg_mr4_byte2_rank0;
      assign mr4_byte3 = ddrc_reg_dbg_mr4_byte3_rank0;

      assign mrr_data_comp_tmp0 = (mr4_byte0 > mr4_byte1) ? mr4_byte0 : mr4_byte1;
      assign mrr_data_comp_tmp1 = (mr4_byte2 > mr4_byte3) ? mr4_byte2 : mr4_byte3;

      assign rd_mr4_data        = (mrr_data_comp_tmp0 > mrr_data_comp_tmp1) ? mrr_data_comp_tmp0 : mrr_data_comp_tmp1;
      
      assign marged_tuf_w       = tuf_byte0 | tuf_byte1 | tuf_byte2 | tuf_byte3;

      assign derate_temp_limit_over_byte0 = (tuf_byte0) ? ((reg_ddrc_lpddr4) ?  (~(|mr4_byte0[2:0]) | &(mr4_byte0[2:0])) : // For LPDDR4
                                                                                ((~(|mr4_byte0[4:0]) | (mr4_byte0[4]))     // For LPDDR5 
                                                                                 | (reg_ddrc_dis_trefi_x0125 && (&mr4_byte0[3:1])) // For LPDDR5 x0.125
                                                                                )
                                                          )
                                                        : 1'b0;
      assign derate_temp_limit_over_byte1 = (tuf_byte1) ? ((reg_ddrc_lpddr4) ?  (~(|mr4_byte1[2:0]) | &(mr4_byte1[2:0])) : // For LPDDR4
                                                                                ((~(|mr4_byte1[4:0]) | (mr4_byte1[4]))     // For LPDDR5 
                                                                                 | (reg_ddrc_dis_trefi_x0125 && (&mr4_byte1[3:1])) // For LPDDR5 x0.125
                                                                                )
                                                          )
                                                        : 1'b0;
      assign derate_temp_limit_over_byte2 = (tuf_byte2) ? ((reg_ddrc_lpddr4) ?  (~(|mr4_byte2[2:0]) | &(mr4_byte2[2:0])) : // For LPDDR4
                                                                                ((~(|mr4_byte2[4:0]) | (mr4_byte2[4]))     // For LPDDR5 
                                                                                 | (reg_ddrc_dis_trefi_x0125 && (&mr4_byte2[3:1])) // For LPDDR5 x0.125
                                                                                )
                                                          )
                                                        : 1'b0;
      assign derate_temp_limit_over_byte3 = (tuf_byte3) ? ((reg_ddrc_lpddr4) ?  (~(|mr4_byte3[2:0]) | &(mr4_byte3[2:0])) : // For LPDDR4
                                                                                ((~(|mr4_byte3[4:0]) | (mr4_byte3[4]))     // For LPDDR5 
                                                                                 | (reg_ddrc_dis_trefi_x0125 && (&mr4_byte3[3:1])) // For LPDDR5 x0.125
                                                                                )
                                                          )
                                                        : 1'b0;
      assign derate_temp_limit_over = derate_temp_limit_over_byte0 | derate_temp_limit_over_byte1 | derate_temp_limit_over_byte2 | derate_temp_limit_over_byte3 ; 



//=================================================END calculate==========================================================
//========================================================================================================================

   assign derate_ddrc_t_refie = derate_ddrc_t_refie_int[$bits(derate_ddrc_t_refie)-1:0];
   assign derate_ddrc_t_refi  = derate_ddrc_t_refi_int[$bits(derate_ddrc_t_refi)-1:0];

   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
           rd_mrr_data_valid_r <= 1'b0;
        end
        else begin
           rd_mrr_data_valid_r <= rd_mrr_data_valid;
        end
   end

   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
           rd_mr4_data_worst_rank0 <= {($bits(rd_mr4_data_worst_rank0)){1'b0}};
        end else begin
           if(rd_mrr_data_valid_r) begin
             begin
                rd_mr4_data_worst_rank0 <= rd_mr4_data;
             end
           end
           else begin
              rd_mr4_data_worst_rank0 <= rd_mr4_data_worst_rank0;
           end
        end
   end

   assign rd_mr4_data_worst =
                              rd_mr4_data_worst_rank0;
  

   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
           marged_tuf_r  <= 1'b0;
        end else begin
           marged_tuf_r  <= marged_tuf_w;
        end
   end
   
   /*
    MR4 response [2:0] or [4:0] indicates derating necessity. Thus, last 3 or 5 bits of MSB compared.    
    Take de-rate decision depending on MR4 read response.
    */

   assign derate_params_w    = (reg_ddrc_lpddr4 && ((rd_mr4_data_worst[2:0] == 3'b111) || // exceeded operated temp
                                                    (rd_mr4_data_worst[2:0] == 3'b110))) 
                            || (reg_ddrc_lpddr5 && ((rd_mr4_data_worst[4:0] == 5'b11111) || // exceeded operated temp
                                                    (rd_mr4_data_worst[4:0] == 5'b01111) ||
                                                    (rd_mr4_data_worst[4:0] == 5'b01101)));

   assign reduce_trfi_x0125_w = (reg_ddrc_lpddr5 && !reg_ddrc_dis_trefi_x0125 && (rd_mr4_data_worst[4:0] >= 5'b01110));

   assign reduce_trfi_x025_w  = (reg_ddrc_lpddr4 && ((rd_mr4_data_worst[2:0] == 3'b111) || (rd_mr4_data_worst[2:0] == 3'b110) || (rd_mr4_data_worst[2:0] == 3'b101))) ||
                                (reg_ddrc_lpddr5 && ((rd_mr4_data_worst[4:0] == 5'b01100) || (rd_mr4_data_worst[4:0] == 5'b01101) || (reg_ddrc_dis_trefi_x0125 && (rd_mr4_data_worst[4:0] >= 5'b01110))));

   assign reduce_trfi_x05_w   = (reg_ddrc_lpddr4 && (rd_mr4_data_worst[2:0] == 3'b100)) || 
                                (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b01011));

   assign reduce_trfi_x07_w   = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b01010));

   assign default_trfi_x1_w   = (reg_ddrc_lpddr4 && ((rd_mr4_data_worst[2:0] == 3'b011) || (rd_mr4_data_worst[2:0] == 3'b000))) ||
                                (reg_ddrc_lpddr5 && ((rd_mr4_data_worst[4:0] == 5'b01001) || (rd_mr4_data_worst[4:0] == 5'b00000)));

   assign boost_trfi_x1_3_w   = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b01000));

   assign boost_trfi_x1_7_w   = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b00111));

   assign boost_trfi_x2_w     = (reg_ddrc_lpddr4 && (rd_mr4_data_worst[2:0] == 3'b010)) ||
                                (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b00110));

   assign boost_trfi_x2_5_w   = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b00101));

   assign boost_trfi_x3_3_w   = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b00100));

   assign boost_trfi_x4_w     = (reg_ddrc_lpddr4 && (rd_mr4_data_worst[2:0] == 3'b001))   ||
                                (reg_ddrc_lpddr5 && ((rd_mr4_data_worst[4:0] == 5'b00011) ||
                                                   (((rd_mr4_data_worst[4:0] == 5'b00010) ||
                                                     (rd_mr4_data_worst[4:0] == 5'b00001)) && reg_ddrc_dis_trefi_x6x8)));

   assign boost_trfi_x6_w     = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b00010) && !reg_ddrc_dis_trefi_x6x8);

   assign boost_trfi_x8_w     = (reg_ddrc_lpddr5 && (rd_mr4_data_worst[4:0] == 5'b00001) && !reg_ddrc_dis_trefi_x6x8);


   reg  reg_ddrc_derate_mr4_pause_fc_r;
   always @(posedge clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
      reg_ddrc_derate_mr4_pause_fc_r <= 1'b0;
    else
      reg_ddrc_derate_mr4_pause_fc_r <= reg_ddrc_derate_mr4_pause_fc;
   end
   
   // Check if any of the reduce* or boost* have changed.  If they have, we need to toggle derate_refresh_update_level
   assign derate_refresh_update_level_c  = (reduce_trfi_x07_r   != reduce_trfi_x07) |
                                           (reduce_trfi_x05_r   != reduce_trfi_x05) |
                                           (reduce_trfi_x025_r  != reduce_trfi_x025) |
                                           (reduce_trfi_x0125_r != reduce_trfi_x0125) |
                                           (default_trfi_x1_r   != default_trfi_x1) |
                                           (boost_trfi_x1_3_r   != boost_trfi_x1_3) |
                                           (boost_trfi_x1_7_r   != boost_trfi_x1_7) |
                                           (boost_trfi_x2_r     != boost_trfi_x2) |
                                           (boost_trfi_x2_5_r   != boost_trfi_x2_5) |
                                           (boost_trfi_x3_3_r   != boost_trfi_x3_3) |
                                           (boost_trfi_x4_r     != boost_trfi_x4) |
                                           (boost_trfi_x6_r     != boost_trfi_x6) |
                                           (boost_trfi_x8_r     != boost_trfi_x8) |
                                           (~reg_ddrc_derate_mr4_pause_fc && reg_ddrc_derate_mr4_pause_fc_r && reg_ddrc_derate_enable);    // Also toggle when reg_ddrc_derate_mr4_pause_fc goes low

   assign derate_refresh_adj_x2 = boost_trfi_x2 | boost_trfi_x1_7 | boost_trfi_x1_3;
   assign derate_refresh_adj_x4 = boost_trfi_x4 | boost_trfi_x3_3 | boost_trfi_x2_5;

   assign max_postponed_ref_cmd = ((reg_ddrc_per_bank_refresh) ? 6'b000111 : 6'b000000) |                // In per bank refresh mode, the least 3 bits need to be filled of 1
                                  (max_num_of_postponed_refab << ((reg_ddrc_per_bank_refresh) ? 3 : 0)); // and 6'b001_000 corresponds one Refresh all bank.

   assign max_num_of_postponed_refab = reg_ddrc_lpddr4 & !reg_ddrc_lpddr4_refresh_mode  ? 3'h7 : // Legacy refresh mode
                                                      (boost_trfi_x8 | boost_trfi_x6)   ? 3'h0 :
                                                      (boost_trfi_x4 | boost_trfi_x3_3) ? 3'h1 :
                                                      (boost_trfi_x2_5)                 ? 3'h2 :
                                                      (boost_trfi_x2)                   ? 3'h3 :
                                                      (boost_trfi_x1_7)                 ? 3'h4 :
                                                      (boost_trfi_x1_3)                 ? 3'h5 :
                                                                                          3'h7 ; // Default value
                                            
   assign max_ref_cmd_within_2trefi = (reg_ddrc_lpddr5)                                 ? 5'b10000  : // 16 LPDDR5A
                                      (reg_ddrc_lpddr4 & !reg_ddrc_lpddr4_refresh_mode) ? 5'b10000  : // 16 LPDDR4 Legacy refresh mode
                                      (boost_trfi_x4)                                   ? 5'b00100  : // 4
                                      (boost_trfi_x2)                                   ? 5'b01000  : // 8
                                                                                          5'b10000  ; // 16


   assign derate_temp_limit_intr_trig = derate_temp_limit_over;

   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
            derate_refresh_update_level  <= 1'b0;
            reduce_trfi_x07_r   <= 1'b0;  
            reduce_trfi_x05_r   <= 1'b0;  
            reduce_trfi_x025_r  <= 1'b0; 
            reduce_trfi_x0125_r <= 1'b0;
            default_trfi_x1_r   <= 1'b0;
            boost_trfi_x1_3_r   <= 1'b0;   
            boost_trfi_x1_7_r   <= 1'b0;   
            boost_trfi_x2_r     <= 1'b0;   
            boost_trfi_x2_5_r   <= 1'b0;   
            boost_trfi_x3_3_r   <= 1'b0;   
            boost_trfi_x4_r     <= 1'b0;   
            boost_trfi_x6_r     <= 1'b0;   
            boost_trfi_x8_r     <= 1'b0;   
        end else begin
            derate_refresh_update_level  <= derate_refresh_update_level_c ^ derate_refresh_update_level;
            reduce_trfi_x07_r   <= reduce_trfi_x07;  
            reduce_trfi_x05_r   <= reduce_trfi_x05;  
            reduce_trfi_x025_r  <= reduce_trfi_x025; 
            reduce_trfi_x0125_r <= reduce_trfi_x0125;
            default_trfi_x1_r   <= default_trfi_x1;
            boost_trfi_x1_3_r   <= boost_trfi_x1_3;
            boost_trfi_x1_7_r   <= boost_trfi_x1_7;
            boost_trfi_x2_r     <= boost_trfi_x2;
            boost_trfi_x2_5_r   <= boost_trfi_x2_5;
            boost_trfi_x3_3_r   <= boost_trfi_x3_3;
            boost_trfi_x4_r     <= boost_trfi_x4;
            boost_trfi_x6_r     <= boost_trfi_x6;
            boost_trfi_x8_r     <= boost_trfi_x8;
        end
   end

   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
            counter                 <= {{($bits(counter)-1){1'b0}},1'b1};
        end else begin
           if (~reg_ddrc_derate_mr4_pause_fc && reg_ddrc_derate_mr4_pause_fc_r && reg_ddrc_derate_enable) begin // set counter to max when derate_mr4_pause_fc is set to 0 
              counter             <= reg_ddrc_mr4_read_interval;
           end else begin
             if(reg_ddrc_derate_enable && (~reg_ddrc_derate_mr4_pause_fc)) begin // increment the counter only when derate feature is enabled and MR4 reads are not paused for freq change
                if (counter >= {{($bits(counter)-$bits(reg_ddrc_mr4_read_interval)){1'b0}},reg_ddrc_mr4_read_interval}) begin
                    counter             <= {{($bits(counter)-1){1'b0}},1'b1};
                end
                else begin
                    counter             <= counter + {{($bits(counter)-1){1'b0}},1'b1};
                end
             end
            end
        end
   end
   
   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
            derate_params     <= 1'b0;
            reduce_trfi_x07   <= 1'b0;  
            reduce_trfi_x05   <= 1'b0;  
            reduce_trfi_x025  <= 1'b0; 
            reduce_trfi_x0125 <= 1'b0;
            default_trfi_x1   <= 1'b0;
            boost_trfi_x1_3   <= 1'b0;   
            boost_trfi_x1_7   <= 1'b0;   
            boost_trfi_x2     <= 1'b0;   
            boost_trfi_x2_5   <= 1'b0;   
            boost_trfi_x3_3   <= 1'b0;   
            boost_trfi_x4     <= 1'b0;   
            boost_trfi_x6     <= 1'b0;   
            boost_trfi_x8     <= 1'b0;   
        end else begin
            if (reg_ddrc_derate_enable) begin
            
                // only sample if MR4[7]=1 or 
                // if usage or MR4[7] (TUF flag) is disabled via software
                if (marged_tuf_r) begin
                    derate_params     <= derate_params_w;
                    reduce_trfi_x07   <= reduce_trfi_x07_w;  
                    reduce_trfi_x05   <= reduce_trfi_x05_w;  
                    reduce_trfi_x025  <= reduce_trfi_x025_w; 
                    reduce_trfi_x0125 <= reduce_trfi_x0125_w;
                    default_trfi_x1   <= default_trfi_x1_w;
                    boost_trfi_x1_3   <= boost_trfi_x1_3_w;   
                    boost_trfi_x1_7   <= boost_trfi_x1_7_w;   
                    boost_trfi_x2     <= boost_trfi_x2_w;   
                    boost_trfi_x2_5   <= boost_trfi_x2_5_w;   
                    boost_trfi_x3_3   <= boost_trfi_x3_3_w;   
                    boost_trfi_x4     <= boost_trfi_x4_w;   
                    boost_trfi_x6     <= boost_trfi_x6_w;   
                    boost_trfi_x8     <= boost_trfi_x8_w;   
                end
            end else begin
                derate_params     <= 1'b0;
                reduce_trfi_x07   <= 1'b0;  
                reduce_trfi_x05   <= 1'b0;  
                reduce_trfi_x025  <= 1'b0; 
                reduce_trfi_x0125 <= 1'b0;
                default_trfi_x1   <= 1'b0;
                boost_trfi_x1_3   <= 1'b0;   
                boost_trfi_x1_7   <= 1'b0;   
                boost_trfi_x2     <= 1'b0;   
                boost_trfi_x2_5   <= 1'b0;   
                boost_trfi_x3_3   <= 1'b0;   
                boost_trfi_x4     <= 1'b0;   
                boost_trfi_x6     <= 1'b0;   
                boost_trfi_x8     <= 1'b0;   
            end
        end
    end

    always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
           mr4_req_trigger       <= 1'b0;
        end
        else begin
            // MR4 requests can corrupt MRW commands sent during initialization, so disable mr4_req_trigger in INIT
            // also disable mr4_req_trigger in DPD, because DPD is followed by INIT
            if ((counter >= {{($bits(counter)-$bits(reg_ddrc_mr4_read_interval)){1'b0}},reg_ddrc_mr4_read_interval}) && reg_ddrc_derate_enable && (~reg_ddrc_derate_mr4_pause_fc) && (ddrc_reg_operating_mode != 3'b000) && (ddrc_reg_operating_mode[2] != 1'b1))
                mr4_req_trigger          <= 1'b1;
            else
                mr4_req_trigger          <= 1'b0;       
        end // else: !if(!core_ddrc_rstn)
    end

    assign mr4_req = mr4_req_trigger;

   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
           core_derate_temp_limit_intr       <= 1'b0;
        end
        else begin
           core_derate_temp_limit_intr <= (((derate_temp_limit_intr_trig | core_derate_temp_limit_intr) & ~derate_sync_ack_c2p) | derate_temp_limit_intr_trig_delay);
        end
   end

   // When set and clear singal is asserted at the same cycle, keep interrupt trigger for one cycle
   // to be re-asserted after it's cleared, 
   always @(posedge clk or negedge core_ddrc_rstn) begin
        if (!core_ddrc_rstn) begin
           derate_temp_limit_intr_trig_delay       <= 1'b0;
        end
        else if (derate_sync_ack_c2p & derate_temp_limit_intr_trig) begin
           derate_temp_limit_intr_trig_delay       <= 1'b1;
        end
        else begin
           derate_temp_limit_intr_trig_delay       <= 1'b0;
        end
   end

//spyglass disable_block W164a
//SMD: LHS: 't_refie_x60' width 20 is less than RHS: '(t_refie_x20 + t_refie_x40)' width 21 in assignment 
//SJ: Overflow not possible
    assign t_refie_x0125 = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} >> 3;
    assign t_refie_x025  = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} >> 2;
    assign t_refie_x05   = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} >> 1;
    // 0.68 = = 1/2 + 1/8 + 1/16
    assign t_refie_x07   = ({{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} >> 4) +
                             t_refie_x0125 +
                             t_refie_x05;
    assign t_refie_x10   = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32};
    assign t_refie_x1_3  = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} + t_refie_x025;
    assign t_refie_x1_7  = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} + t_refie_x07;
    assign t_refie_x20   = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} << 1;
    assign t_refie_x2_5  = t_refie_x05 + t_refie_x20;
    assign t_refie_x3_3  = t_refie_x1_3 + t_refie_x20;
    assign t_refie_x40   = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} << 2;
    assign t_refie_x60   = t_refie_x20 + t_refie_x40;
    assign t_refie_x80   = {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32} << 3;

// Calcurate for 2*tREFI
    assign t_refi_x0125 = t_refie_x0125;
    assign t_refi_x025  = t_refie_x025;
    assign t_refi_x05   = t_refie_x05;
    // 0.75 = = 1/2 + 1/4
    assign t_refi_x07   = t_refie_x025 + t_refie_x05;
    assign t_refi_x10   = t_refie_x10;
    assign t_refi_x20   = t_refie_x20;
    assign t_refi_x40   = t_refie_x40;
//spyglass enable_block W164a

   always @(posedge clk or negedge core_ddrc_rstn)
   begin
    if (!core_ddrc_rstn) begin
        derate_ddrc_t_rcd       <= {$bits(derate_ddrc_t_rcd){1'b0}};
        derate_ddrc_t_ras_min   <= {$bits(derate_ddrc_t_ras_min){1'b0}};
        derate_ddrc_t_rc        <= {$bits(derate_ddrc_t_rc){1'b0}};
        derate_ddrc_t_rp        <= {$bits(derate_ddrc_t_rp){1'b0}};
        derate_ddrc_t_rrd       <= {$bits(derate_ddrc_t_rrd){1'b0}};
        derate_ddrc_t_rrd_s     <= {$bits(derate_ddrc_t_rrd_s){1'b0}};
        derate_ddrc_t_refie_int  <= {$bits(derate_ddrc_t_refie_int) {1'b0}};
        derate_ddrc_t_refi_int       <= {$bits(derate_ddrc_t_refi_int) {1'b0}};
    end
    else if (!reg_ddrc_derate_enable) begin
        derate_ddrc_t_rcd       <= reg_ddrc_t_rcd;
        derate_ddrc_t_ras_min   <= reg_ddrc_t_ras_min;
        derate_ddrc_t_rc        <= reg_ddrc_t_rc;
        derate_ddrc_t_rp        <= reg_ddrc_t_rp;
        derate_ddrc_t_rrd       <= reg_ddrc_t_rrd;
        derate_ddrc_t_rrd_s     <= reg_ddrc_t_rrd_s;
        derate_ddrc_t_refie_int  <= ({{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}},reg_ddrc_t_refi_x32} << ((reg_ddrc_t_refi_x1_sel & reg_ddrc_per_bank_refresh) ? 0 : 5));
        derate_ddrc_t_refi_int   <= ({{($bits(derate_ddrc_t_refi_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}},reg_ddrc_t_refi_x32} << ((reg_ddrc_t_refi_x1_sel & reg_ddrc_per_bank_refresh) ? 0 : 5));
    end
    else begin
        if (derate_params == 1'b1) begin
            derate_ddrc_t_rcd     <= reg_ddrc_derated_t_rcd;
            derate_ddrc_t_ras_min <= reg_ddrc_derated_t_ras_min;
            derate_ddrc_t_rc      <= reg_ddrc_derated_t_rc;
            derate_ddrc_t_rp      <= reg_ddrc_derated_t_rp;
            derate_ddrc_t_rrd     <= reg_ddrc_derated_t_rrd;
            derate_ddrc_t_rrd_s   <= reg_ddrc_derated_t_rrd; // Derated tRRD_s value is not defined in LPDDR5 spec. So derated tRRD_s is set a derated tRRD value to be safety.
                                                             // See bugzilla 9192 #6

        end else begin
            derate_ddrc_t_rcd       <= reg_ddrc_t_rcd;
            derate_ddrc_t_ras_min   <= reg_ddrc_t_ras_min;
            derate_ddrc_t_rc        <= reg_ddrc_t_rc;
            derate_ddrc_t_rp        <= reg_ddrc_t_rp;
            derate_ddrc_t_rrd       <= reg_ddrc_t_rrd;
            derate_ddrc_t_rrd_s     <= reg_ddrc_t_rrd_s;
        end
// The following logic reduces or boosts the tRFC value based on the standard tRFC_nom value
// So only 4 options availabe - keep it same as before, reduce x2, boost x2, boost x4
        derate_ddrc_t_refie_int <= (((reduce_trfi_x0125) ? t_refie_x0125 :
                                     (reduce_trfi_x025)  ? t_refie_x025  :
                                     (reduce_trfi_x05)   ? t_refie_x05   :
                                     (reduce_trfi_x07)   ? t_refie_x07   :
                                     (boost_trfi_x8)     ? t_refie_x80   :
                                     (boost_trfi_x6)     ? t_refie_x60   :
                                     (boost_trfi_x4)     ? t_refie_x40   :
                                     (boost_trfi_x3_3)   ? t_refie_x3_3  :
                                     (boost_trfi_x2_5)   ? t_refie_x2_5  :
                                     (boost_trfi_x2)     ? t_refie_x20   :
                                     (boost_trfi_x1_7)   ? t_refie_x1_7  :
                                     (boost_trfi_x1_3)   ? t_refie_x1_3  :
                                                               {{($bits(derate_ddrc_t_refie_int)-$bits(reg_ddrc_t_refi_x32)){1'b0}}, reg_ddrc_t_refi_x32}
                                   ) << ((reg_ddrc_t_refi_x1_sel & reg_ddrc_per_bank_refresh) ? 0 : 5));

// REFab 'Burst' Interval Definition
// LPDDR4 : 2 x tREFI x refresh rate
// LPDDR5A: 2 x tREFI  or  2 x tREFI x refresh rate
//          ^ this multiplier '2' is not included to here
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression found in module 'derate'
//SJ: This coding style is acceptable and there is no plan to change it.
        derate_ddrc_t_refi_int <= ( ((reg_ddrc_lpddr4) ? (
                                      (reduce_trfi_x025)   ? t_refi_x025  :
                                      (reduce_trfi_x05)    ? t_refi_x05   :
                                      (boost_trfi_x4)      ? t_refi_x40   :
                                      (boost_trfi_x2)      ? t_refi_x20   :
                                                             t_refi_x10   ) : (
                                      // lpddr5
                                      (reduce_trfi_x0125)  ? t_refi_x0125 :
                                      (reduce_trfi_x025)   ? t_refi_x025  :
                                      (reduce_trfi_x05)    ? t_refi_x05   :
                                      (reduce_trfi_x07)    ? t_refi_x07   :
                                                             t_refi_x10   )
                                    ) + (
                                      derate_refresh_adj_x4 ? {{($bits(derate_ddrc_t_refi_int)-4){1'b0}},3'b100} :
                                      derate_refresh_adj_x2 ? {{($bits(derate_ddrc_t_refi_int)-3){1'b0}},2'b10} :
                                                              {{($bits(derate_ddrc_t_refi_int)-2){1'b0}},1'b1}
                                    )
                                  ) << ((reg_ddrc_t_refi_x1_sel & reg_ddrc_per_bank_refresh) ? 0 : 5);
//spyglass enable_block SelfDeterminedExpr-ML
        
    end // else: !if(!core_ddrc_rstn)

   end // always @ (posedge clk or negedge core_ddrc_rstn)

assign derate_force_refab = reg_ddrc_auto_refab_en == 2'b01 ? (reduce_trfi_x0125 || reduce_trfi_x025 || reduce_trfi_x05) : 
                            reg_ddrc_auto_refab_en == 2'b10 ? (reduce_trfi_x0125 || reduce_trfi_x025) :
                            reg_ddrc_auto_refab_en == 2'b11 ? (reduce_trfi_x0125) : 1'b0;

`ifndef SYNTHESIS
  `ifdef SNPS_ASSERT_ON
   
   // Coverpoint
   covergroup cg_core_derate_temp_limit_intr @(posedge clk);

   // Gather coverage data per instance for each channel
   option.per_instance = 1;

   // Check if the interrupt is caused
   cp_core_derate_temp_limit_intr: coverpoint (core_derate_temp_limit_intr) iff (core_ddrc_rstn) {
      bins bin_core_derate_temp_limit_intr0 = {0};
      bins bin_core_derate_temp_limit_intr1 = {1};
   }

   // Check if the interrupt for both low and high temperature is caused
   cp_core_derate_temp_limit_intr_mr4: coverpoint ({marged_tuf_r,rd_mr4_data_worst[4:0], reg_ddrc_derate_mr4_tuf_dis}) iff (core_ddrc_rstn && derate_temp_limit_intr_trig) {
      bins bin_core_derate_temp_limit_intr_low_mr4_tuf_dis_0   = {1'b1,5'h00, 1'b0};
      bins bin_core_derate_temp_limit_intr_high_mr4_tuf_dis_0  = {1'b1,5'h07, 1'b0};
      bins bin_core_derate_temp_limit_intr_low_mr4_tuf_dis_1   = {1'b1,5'h00, 1'b1};
      bins bin_core_derate_temp_limit_intr_high_mr4_tuf_dis_1  = {1'b1,5'h07, 1'b1};
   }
   endgroup

   cg_core_derate_temp_limit_intr cg_core_derate_temp_limit_intr_inst = new;

   // Assertions
   
   // Check clearing interrupt
    property p_core_derate_temp_limit_intr_clr;
      @ (posedge clk) disable iff (~core_ddrc_rstn)
      $rose(derate_sync_ack_c2p) |-> ## 1 (!core_derate_temp_limit_intr);
    endproperty
 
    a_core_derate_temp_limit_intr_clr: assert property (p_core_derate_temp_limit_intr_clr)
        else $error("%0t ERROR - core_derate_temp_limit_intr signal not indicating valid value!", $time);
 
    // Check setting interrupt
    property p_core_derate_temp_limit_intr_set;
      @ (posedge clk) disable iff (~core_ddrc_rstn)
      (derate_temp_limit_intr_trig & ~derate_sync_ack_c2p) |-> ## 1 (core_derate_temp_limit_intr);
    endproperty
 
    a_core_derate_temp_limit_intr_set: assert property (p_core_derate_temp_limit_intr_set)
        else $error("%0t ERROR - core_derate_temp_limit_intr signal not indicating valid value!", $time);


    property p_core_derate_temp_limit_intr_set_delay;
      @ (posedge clk) disable iff (~core_ddrc_rstn)
      derate_temp_limit_intr_trig_delay |-> ## 2 (core_derate_temp_limit_intr);
    endproperty
 
    a_core_derate_temp_limit_intr_set_delay: assert property (p_core_derate_temp_limit_intr_set_delay)
        else $error("%0t ERROR - core_derate_temp_limit_intr signal not indicating valid value!", $time);
   logic [1:0] derate_seq_curr_state = IDLE;
 
    // mr4_req expected if derate_mr4_pause_fc goes low and
    // - derate_enable=1
    // - operating_mode!=INIT
    // - operating_mode!=DPD
    // mr4_req is issued even if derate_mr4_pause_fc == 1 during derate_seq_curr_state != IDLE
    property p_mr4_req_sent_after_mr4_pause_fall;
      @ (posedge clk) disable iff (~core_ddrc_rstn)
      ($fell(reg_ddrc_derate_mr4_pause_fc) && reg_ddrc_derate_enable && (ddrc_reg_operating_mode != 3'b000) && (ddrc_reg_operating_mode[2] != 1'b1) && (derate_seq_curr_state == IDLE)) |-> ## [2:3] (mr4_req);
    endproperty

    
    a_mr4_req_sent_after_mr4_pause_fall: assert property (p_mr4_req_sent_after_mr4_pause_fall)
        else $error("%0t ERROR - mr4_req is not asserted after DERATEEN.derate_mr4_pause_fc goes to 0!", $time);

    property p_no_mr4_req_during_mr4_pause_1;
      @ (posedge clk) disable iff (~core_ddrc_rstn)
      (reg_ddrc_derate_mr4_pause_fc_r && (derate_seq_curr_state==IDLE)) |-> (mr4_req == 0);
    endproperty
 
    a_no_mr4_req_during_mr4_pause_1: assert property (p_no_mr4_req_during_mr4_pause_1)
        else $error("%0t ERROR - MR4 Request while derate_mr4_pause_fc is set !", $time);


  `endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule // derate
