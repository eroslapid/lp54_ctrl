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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_rmw.sv#2 $
// -------------------------------------------------------------------------
// Description:
/******************************************************************************
 *                                                                            *
 * DESCRIPTION: Read modify write generator                                   *
 *              Implements the RMW command generation based on write          *
 *              data strobe. A store and forward mechanism is applied to      *
 *              determine the generation of RMW or WR commands based on       *
 *              collected write data strobe. RMW are required in order        *
 *              to handle ECC calculation or non-DM mode on strobed writes.   *
 *              Store and forward and RMW generation are enbled via the       *
 *              register reg_xpi_rmw_mode. If reg_xpi_rmw_mode is 1'b0,       *
 *              The block will act as a passthrough buffer for address        *
 *              and data introducing one cycle of latency                     *
 *****************************************************************************/
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_rmw
import DWC_ddrctl_reg_pkg::*;
#(
  parameter ADDRW         = 32,
  parameter IDW           = 8,
  parameter NAB           = 1,
  parameter M_ECC         = `MEMC_ECC_SUPPORT,
  parameter M_SIDEBAND_ECC = `MEMC_SIDEBAND_ECC_EN,
  parameter M_INLINE_ECC  = `MEMC_INLINE_ECC_EN,
  parameter QOSW          = 2,
  parameter AXI_USERW     = 1,
  parameter DATAW         = 32,
  parameter STRBW         = 4,
  parameter PARW          = 4,
  parameter WDQD          = 8,
  parameter EXA_PYLD_W    = 1,
  parameter ORDER_TOKENW  = 4,
  parameter WARD          = 2,
  parameter NBEATS         = 4,
  parameter NBEATS_LG2     = 4,
  parameter CMD_LEN_BITS   = 2,
  parameter OCCAP_EN       = 0,
  parameter OCCAP_PIPELINE_EN = 0,
  parameter MEMC_BURST_LENGTH = 8,
  parameter VPW_EN        = 0,
  parameter VPRW          = 1,
  parameter WQOS_RW       = 2,
  parameter WQOS_TW       = 11,
  parameter DEACC_INFOW   = 5,
  parameter OCPAR_EN      = 0,
  parameter OCECC_EN      = 0,
  parameter DUAL_CHANNEL_INTERLEAVE = 0,
  parameter DATA_CHANNEL_INTERLEAVE_NS = 0,
  parameter DBW           = 2,
  parameter XPI_USE_RMWR_EN= 1
)
(
  input                                clk,             // clock
  input                                rst_n,           // asynchronous reset
  input                                reg_xpi_dm_dis,  // DM disable
  input                                reg_xpi_rmw_mode_ie,   // Enable RMW mode - Inline ECC
  input                                reg_xpi_rmw_mode_nonie,// Enable RMW mode - Non Inline ECC
  input                                reg_xpi_snf_mode,      // Enable the programmable SnF feature
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block  
  input                                reg_ddrc_ecc_type,
//SJ: Used in generate block. Used only if NAB==3
  input                                reg_mbl16_bl8_bc_crc_dis_nab3, //Indicates BL8 in NAB3 in MEMC_BL=16 Controller with Burst-chop(BC4)
  input [DBW-1:0]                      reg_ddrc_data_bus_width,
  input [ECC_MODE_WIDTH-1 : 0]         reg_ddrc_ecc_mode,
  input                                reg_ddrc_multi_beat_ecc,
//spyglass enable_block W240
  // XPI Write Address channel
  input [ADDRW-1:0]                    xpi_wr_awaddr,   // XPI write address
  input                                xpi_wr_awdata_channel,
  input                                xpi_wr_awlast,   // XPI write address last
  input                                xpi_wr_split,
  input                                xpi_wr_short_burst,
  input [IDW-1:0]                      xpi_wr_awid,     // XPI write address ID
  input [QOSW-1:0]                     xpi_wr_awqos,    // XPI write address qos
  input [AXI_USERW-1:0]                xpi_wr_awuser,
  input                                xpi_wr_awpagematch, // XPI write pagematch indicator
  input                                xpi_wr_awautopre, // XPI write auto precharge
  input                                xpi_wr_awvalid,  // XPI write address valid
  output                               rmw_awready,     // RMW write address ready
  input [ORDER_TOKENW-1:0]             xpi_wr_write_order_token,
  input                                xpi_wr_exa_acc,  // Exclusive Access Write 
  input [EXA_PYLD_W-1:0]               xpi_wr_exa_pyld, // Exclusive Access Payload
  input                                xpi_wr_exa_acc_lock, // Exclusive Access Write, asserted for all packets of an AXI burst
  input                                xpi_wr_wpoison,
  input                                xpi_wr_ocpar_err,
  input [WQOS_RW-1:0]                  xpi_wr_wqos_priority,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block  
  input [WQOS_TW-1:0]                  xpi_wr_wqos_timeout,
  input                                xpi_wr_vpw_expired,
//spyglass enable_block W240
  input                                xpi_wr_awvalid_iecc,
  input                                xpi_wr_awlast_iecc,
 
  // XPI Write Data Channel
  input [DATAW-1:0]                    xpi_wr_wdata,    // XPI write data
  input [STRBW-1:0]                    xpi_wr_wstrb,    // XPI write data strobe
  input                                xpi_wr_wdata_channel,
  input [DEACC_INFOW-1:0]              xpi_wr_deacc_info,
  input                                xpi_wr_wlast,    // XPI write data last
  input                                xpi_wr_wvalid,   // XPI write data valid
  output                               rmw_wready,      // RMW write data ready
  input                                xpi_wr_wlast_pkt,// XPI write last beat of the packet
  input [STRBW-1:0]                    xpi_wr_wpar_err,
  input [PARW-1:0]                     xpi_wr_wparity,

  // XPI Short Write Information
  input                                xpi_short_write,  // Short write infomation

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block  
  // inline ECC beat info
  input [NBEATS_LG2-1:0]               xpi_wr_beat_count,
//spyglass enable_block W240

  input                                reg_ddrc_occap_en,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block  
  input                                wperq_rd,
//spyglass enable_block W240

  // RMW Write Address channel
  output [ADDRW-1:0]                   rmw_awaddr,      // RMW write address
  output                               rmw_awdata_channel,
  output                               rmw_awlast,      // RMW write address last
  output                               rmw_split,
  output                               rmw_short_burst,
  output [IDW-1:0]                     rmw_awid,        // RMW write address ID
  output [QOSW-1:0]                    rmw_awqos,       // RMW write address qos
  output [AXI_USERW-1:0]               rmw_awuser,
  output                               rmw_awpagematch, // RMW write pagematch indicator
  output                               rmw_awautopre,   // RMW write auto precharge
  output                               rmw_awvalid,     // RMW write address valid
  output                               rmw_awrmw,       // RMW rmw request
  output [NBEATS-1:0]                  rmw_wdata_mask_full,
  output [ORDER_TOKENW-1:0]            rmw_write_order_token,
  output                               rmw_wpoison,
  output                               rmw_ocpar_err,
  output [WQOS_RW-1:0]                 rmw_wqos_priority,
  output [WQOS_TW-1:0]                 rmw_wqos_timeout,
  output                               rmw_vpw_expired,
  input                                hif_awready,     // HIF write address ready

  output                               rmw_wexa_acc,    // Exclusive Access Write 
  output [EXA_PYLD_W-1:0]              rmw_wexa_pyld,   // Exclusive Access Payload
  output                               rmw_wexa_acc_lock, // Exclusive Access Write, asserted for all packets of an AXI burst

  output                               rmw_awvalid_iecc,
  output                               rmw_awlast_iecc,

  output                               rmw_occap_par_err,
 
  // RMW Write Data Channel
  output [DATAW-1:0]                   rmw_wdata,       // RMW write data
  output [STRBW-1:0]                   rmw_wstrb,       // RMW write data strobe
  output                               rmw_wdata_channel,
  output [DEACC_INFOW-1:0]             rmw_deacc_info,
  output                               rmw_wlast,       // RMW write data last
  output                               rmw_wvalid,      // RMW write data valid
  input                                hif_wready,      // HIF write data ready
  output [STRBW-1:0]                   rmw_wpar_err,
  output [PARW-1:0]                    rmw_wparity,
  output                               rmw_wlast_pkt    // RMW write last beat of the packet
);
  
  //---------------------------------------------------------------------------
  // Local Parameters 
  //---------------------------------------------------------------------------  
  localparam LASTW = 1;
  localparam SPLITW = 1;
  localparam WARW = SPLITW + LASTW + ADDRW + IDW + QOSW + EXA_PYLD_W + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + ORDER_TOKENW + WQOS_RW + 1 + 1 + AXI_USERW; 
  localparam WDQW = ((DUAL_CHANNEL_INTERLEAVE==0) && (OCPAR_EN == 1 || OCECC_EN == 1))?
                     (1+ 1+ 1+ STRBW+ DATAW+ PARW+ DEACC_INFOW):(1+ 1+ 1+ STRBW+ DATAW+ PARW+ STRBW+ DEACC_INFOW);
  localparam WDQD_LG2 = `UMCTL_LOG2(WDQD);

  localparam WARD_LG2 = `UMCTL_LOG2(WARD);

  localparam WSRW = 1 + M_INLINE_ECC*(NBEATS);
  localparam MEM_STRBW = STRBW / (2**NAB) ;
  localparam QBW           = 2'b10;
  localparam HBW           = 2'b01;
  localparam FBW           = 2'b00;

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire                                 war_wr,war_rd,war_full,war_empty;      // WAR handshake
  wire                                 war_push, war_pop;
  wire [WARW-1:0]                      war_d;
  wire [WARW-1:0]                      war_q;
  wire                                 war_or_bypass_valid, war_or_bypass_ready;
  wire                                 wsr_wr,wsr_rd,wsr_full,wsr_empty;      // WSR handshake       
  wire [WSRW-1:0]                      wsr_d;
  wire [WSRW-1:0]                      wsr_q;

  wire                                 wdq_wr,wdq_rd,wdq_full,wdq_empty;       // WDQ handshake       
  wire                                 wperq_wr,wperq_full,wperq_empty_unused; // WPAR_ERR Acc logic       
  wire                                 wdq_or_bypass_valid, wdq_or_bypass_ready;
  wire [WDQW-1:0]                      wdq_d;
  wire [WDQW-1:0]                      wdq_q;
  wire                                 xpi_wr_wstrb_reduced;                  // Single bit ORed write strobe
  wire                                 wstrb_reduced_accu;                    // Accumulated single bit write strobe 
  wire                                 wstrb_reduced_next;                    // Single bit write strobe accumulator next
  wire                                 wstrb_reduced_reg;                     // Single bit write strobe accumulator reg
  wire                                 wstrb_is_rmw;
  wire                                 wsr_wstrb_reduced_accu;

  wire                                 rmw_dis_ie;

  wire                                 xpi_wr_wstrb_reduced_ie;                  // Single bit ORed write strobe
  wire                                 xpi_wr_wstrb_reduced_nonie;               // Single bit ORed write strobe
  wire                                 xpi_wr_wstrb_reduced_nonie_secded;
  wire                                 xpi_wr_wstrb_reduced_nonie_advecc;

  wire [WSRW-1:0]                      wsr_d_ie;
  wire [WSRW-1:0]                      wsr_d_nonie;
 
  wire                                 wsr_wstrb_reduced_accu_ie;
  wire                                 wsr_wstrb_reduced_accu_nonie;

  wire [NBEATS-1:0]                    rmw_wdata_mask_full_ie;
  wire [NBEATS-1:0]                    rmw_wdata_mask_full_nonie;
  
  wire                                 wdata_mask_full_par_err_ie;
  wire                                 wdata_mask_full_par_err_nonie;

  wire [WARD_LG2+1-1:0]                wcount_war_unused;

  wire                                 xpi_rmw_war_par_err, xpi_rmw_wdq_par_err,xpi_rmw_wperq_par_err, xpi_rmw_wsr_par_err, wdata_mask_full_par_err, wstrb_reduced_par_err, occap_xpi_war_vpw_err;
  wire                                 valid_wr_in_bc4;
  wire                                 valid_wr_in_bc4_secded;
  wire                                 valid_wr_in_bc4_advecc;

  wire i_reg_xpi_rmw_mode_or = reg_xpi_rmw_mode_ie | reg_xpi_rmw_mode_nonie;
  // Internal SnF mode is active if either RMW mode or programmable SnF is enabled.
  wire snf_mode_int = i_reg_xpi_rmw_mode_or | reg_xpi_snf_mode;
  // If XPI_USE_RMWR_EN==1, bypass path is always disabled.
  // else, bypass path active/inactive depends on snf_mode_int.
  wire xpi_rmw_bypass_dis = (XPI_USE_RMWR_EN == 0)? snf_mode_int : 1'b1;

`ifdef SNPS_ASSERT_ON
  `ifndef SYNTHESIS
  // Design assertions to check bypass mode and programmable SnF

  cp_snf_rmw  : cover property (@(posedge clk) disable iff(!rst_n) (reg_xpi_snf_mode & i_reg_xpi_rmw_mode_or));
  cp_nsnf_rmw : cover property (@(posedge clk) disable iff(!rst_n) (~reg_xpi_snf_mode & i_reg_xpi_rmw_mode_or));
  cp_snf_nrmw : cover property (@(posedge clk) disable iff(!rst_n) (reg_xpi_snf_mode & ~i_reg_xpi_rmw_mode_or));
  cp_nsnf_nrmw: cover property (@(posedge clk) disable iff(!rst_n) (~reg_xpi_snf_mode & ~i_reg_xpi_rmw_mode_or));

  // 1. When bypass is enabled RMW commands are not allowed
  property p_no_rmw_in_bypass_check;
    @(posedge clk) disable iff(!rst_n)
      (xpi_rmw_bypass_dis==0) |-> (rmw_awrmw == 0);
  endproperty
  a_no_rmw_in_bypass_check: assert property (p_no_rmw_in_bypass_check);

  // 2. When SnF mode is enabled command should be given only after all the data beats are available
  // Keep a counter. Increment when (xpi_wr_wvalid&xpi_wr_wlast_pkt)=1. Decrement when rmw_awvalid=1. Counter should be >1 when rmw_awvalid
  integer posted_wdata_count;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      posted_wdata_count <= 0;
    else
      if (xpi_wr_wvalid&rmw_wready&xpi_wr_wlast_pkt & ~(rmw_awvalid&hif_awready))
        posted_wdata_count <= posted_wdata_count+1;
      else if (rmw_awvalid & hif_awready & ~(xpi_wr_wvalid&rmw_wready&xpi_wr_wlast_pkt))
        posted_wdata_count <= posted_wdata_count-1;
  end

  property p_snf_check;
    @(posedge clk) disable iff(!rst_n)
      (rmw_awvalid&snf_mode_int) |-> (posted_wdata_count>0);
  endproperty
  a_snf_check: assert property (p_snf_check);

  // 3. When rmw_mode is disabled, RMW commands are not allowed
  property p_no_rmw_check;
    @(posedge clk) disable iff(!rst_n)
      (i_reg_xpi_rmw_mode_or==0) |-> (rmw_awrmw == 0);
  endproperty
  a_no_rmw_check: assert property (p_no_rmw_check);
  `endif
`endif

  // occap error
  assign rmw_occap_par_err = xpi_rmw_war_par_err | xpi_rmw_wdq_par_err | xpi_rmw_wperq_par_err | xpi_rmw_wsr_par_err | wdata_mask_full_par_err | wstrb_reduced_par_err | occap_xpi_war_vpw_err;

  // inline ECC rmw disable
  generate
   if (M_INLINE_ECC==1) begin: RMW_ie_en

      assign rmw_dis_ie = reg_xpi_rmw_mode_ie & ~reg_xpi_dm_dis & ~rmw_awvalid_iecc;

   end
   else begin: RMW_ie_dis

      assign rmw_dis_ie = 1'b0;

   end
  endgenerate

  //---------------------------------------------------------------------------
  // Write Address Retime
  //---------------------------------------------------------------------------
  assign war_d       = {xpi_wr_exa_pyld, xpi_wr_exa_acc, xpi_wr_exa_acc_lock, xpi_wr_awaddr, xpi_wr_awlast, xpi_wr_split, xpi_wr_short_burst, xpi_wr_awid, xpi_wr_awqos, xpi_wr_awuser, xpi_wr_awpagematch, xpi_wr_awautopre, xpi_wr_write_order_token, xpi_wr_wpoison, xpi_wr_ocpar_err, xpi_wr_awdata_channel, xpi_wr_wqos_priority, xpi_wr_awvalid_iecc, xpi_wr_awlast_iecc};
  assign               {rmw_wexa_pyld,   rmw_wexa_acc,   rmw_wexa_acc_lock,   rmw_awaddr,    rmw_awlast,    rmw_split,    rmw_short_burst,    rmw_awid,    rmw_awqos,    rmw_awuser,    rmw_awpagematch,    rmw_awautopre,    rmw_write_order_token,    rmw_wpoison,    rmw_ocpar_err,    rmw_awdata_channel,    rmw_wqos_priority,   rmw_awvalid_iecc,     rmw_awlast_iecc} = xpi_rmw_bypass_dis? war_q : war_d;
  // When internal snf is disabled, there is no need to wait for ~wsr_empty
  assign rmw_awvalid = war_or_bypass_valid & (~wsr_empty|~snf_mode_int); // Wait for strobe in WSR
  assign rmw_awready = war_or_bypass_ready;
  // block war_wr blocked when bypass enabled
  assign war_wr      = xpi_wr_awvalid & ~war_full & xpi_rmw_bypass_dis;
  assign war_rd      = hif_awready & (~wsr_empty|~snf_mode_int); // Wait for strobe in WSR

  DWC_ddr_umctl2_gfifo
  
  #(
    .WIDTH       (WARW),
    .DEPTH       (WARD),  
    .ADDR_WIDTH  (WARD_LG2),
    .COUNT_WIDTH (WARD_LG2+1),
    .OCCAP_EN    (OCCAP_EN),
    .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
  ) 
  U_war
  (
    .clk         (clk),
    .rst_n       (rst_n),
    .wr          (war_wr),  
    .d           (war_d),
    .rd          (war_rd),  
    .par_en      (reg_ddrc_occap_en),
    .init_n      (1'b1),
    .ff          (war_full),
    .wcount      (wcount_war_unused), 
    .q           (war_q),
    .fe          (war_empty),
    .par_err     (xpi_rmw_war_par_err)
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~war_empty
    ,.disable_sva_fifo_checker_wr (1'b0)
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
  );

  // valid is provided to the output side of war or bypass logic
  assign war_or_bypass_valid = xpi_rmw_bypass_dis? ~war_empty : // when WAR is active
                                                      xpi_wr_awvalid; // when bypass is active
  // ready is provided to the input side of war or bypass logic
  assign war_or_bypass_ready = xpi_rmw_bypass_dis? ~war_full :
                                                      hif_awready;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
  assign war_push = war_wr & ~war_full;
  assign war_pop  = war_rd & ~war_empty;
//spyglass enable_block W528  
  

  //---------------------------------------------------------------------------
  // VPW counters
  //---------------------------------------------------------------------------


  generate
   if (VPW_EN == 1) begin: VPW_en
      
      wire  war_in_vpw, war_out_vpw;
      wire  vpw_counters_empty_unused, vpw_counters_full_unused;
      wire  war_vpw_pop, war_vpw_push;
      wire  rmw_in_vpw_expired;

      assign rmw_in_vpw_expired = ~|xpi_wr_wqos_timeout;

      wire [WQOS_TW-1:0] rmw_wqos_timeout_w;

      DWC_ddr_umctl2_xpi_vpt
      
       #(
          .CNT_WIDTH    (WQOS_TW),
          .CNT_DEPTH    (WARD),
          .OCCAP_EN    (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
       )
       U_xpi_war_vpw
       (
         // inputs
          .e_clk               (clk),
          .e_rst_n             (rst_n),
          .push                (war_vpw_push),
          .pop                 (war_vpw_pop),
          .input_timeout       (xpi_wr_wqos_timeout),
          .input_timeout_zero  (rmw_in_vpw_expired),
          .reg_ddrc_occap_en   (reg_ddrc_occap_en),
          // outputs
          .counters_empty      (vpw_counters_empty_unused),
          .counters_full       (vpw_counters_full_unused),
          .output_timeout_zero (rmw_out_vpw_expired),
          .output_timeout      (rmw_wqos_timeout_w),
          .occap_xpi_vpt_par_err (occap_xpi_war_vpw_err)
       );

       assign war_in_vpw   = (xpi_wr_wqos_priority == VPRW)  ? 1'b1 : 1'b0;
       assign war_out_vpw  = (rmw_wqos_priority == VPRW)     ? 1'b1 : 1'b0;
       // bypass logic for timeout value and expired signal
       assign rmw_wqos_timeout = xpi_rmw_bypass_dis? rmw_wqos_timeout_w : xpi_wr_wqos_timeout;
       assign rmw_vpw_expired = (xpi_rmw_bypass_dis? (xpi_wr_vpw_expired | rmw_out_vpw_expired) : xpi_wr_vpw_expired) & rmw_awvalid;

       assign war_vpw_push = war_push & war_in_vpw;
       assign war_vpw_pop  = war_pop & war_out_vpw;

   end else begin: VPW_nen

      assign rmw_wqos_timeout  = {WQOS_TW{1'b0}};
      assign rmw_vpw_expired   = 1'b0;

      assign occap_xpi_war_vpw_err = 1'b0;

  end

  endgenerate

  //---------------------------------------------------------------------------
  // Write Strobe Accumulator
  //---------------------------------------------------------------------------
  // xpi_wr_wstrb_reduced indicates one or more bytes are strobed but not all bytes
  // in Advanced ECC mode, the xpi_wr_wstrb_reduce indicates one or more byte are 
  // strobed but not all bytes in consecutive 2 DRAM beats

  generate

    if (NAB==1&&STRBW>2) begin: xpi_wr_wstrb_reduced_freq_1t1
      assign valid_wr_in_bc4 = 1'b0; // Used in only NAB=3 case.
      if (M_INLINE_ECC==1) begin: inline_ecc
         if (MEM_STRBW==2) begin: EQ16bit_MEM_1t1
            // with 16 bit and fr1 not possible to have 64 bit at the HIF, only 32 available. Need to pack 2 consecutive HIF beats
            wire [STRBW*2-1:0]   xpi_wr_wstrb_double;
            reg [STRBW*2-1:0]    xpi_wr_wstrb_double_r; // SNPS_TMR
            reg                  strb_index; // SNPS_TMR
            wire                 strb_index_nxt;

            wire                 last_strb;
            wire                 xpi_wr_wstrb_partial;

            assign strb_index_nxt   = xpi_wr_wlast_pkt   ? 1'b0 : 
                                      xpi_wr_wvalid      ? strb_index+1'b1 : strb_index;

            assign last_strb        = xpi_wr_wlast_pkt | strb_index;

            always @(posedge clk or negedge rst_n) begin
               if (~rst_n) begin
                  strb_index <= 1'b0;
                  xpi_wr_wstrb_double_r <= {(STRBW*2){1'b0}};
               end
               else begin
                  strb_index <= strb_index_nxt;
                  xpi_wr_wstrb_double_r <= last_strb ? {(STRBW*2){1'b0}} : xpi_wr_wstrb_double;
               end
            end

            assign xpi_wr_wstrb_double[0+:MEM_STRBW*2]            = (xpi_wr_wvalid & ~strb_index) ? xpi_wr_wstrb[0+:MEM_STRBW*2] : xpi_wr_wstrb_double_r[0+:MEM_STRBW*2]; // lower half
            assign xpi_wr_wstrb_double[MEM_STRBW*2+:MEM_STRBW*2]  = (xpi_wr_wvalid & strb_index) ? xpi_wr_wstrb[0+:MEM_STRBW*2] : xpi_wr_wstrb_double_r[MEM_STRBW*2+:MEM_STRBW*2]; // upper half

            assign xpi_wr_wstrb_partial      = ~&xpi_wr_wstrb_double[0+:MEM_STRBW*4] & last_strb;
            assign xpi_wr_wstrb_reduced_ie  = (|xpi_wr_wstrb_double[0+:MEM_STRBW*4]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial;

         end
         else if (MEM_STRBW==4) begin: EQ32bit_MEM_1t1
            
            wire xpi_wr_wstrb_partial;
            
            assign xpi_wr_wstrb_partial      = ~&xpi_wr_wstrb[0+:MEM_STRBW*2];
            assign xpi_wr_wstrb_reduced_ie  = (|xpi_wr_wstrb[0+:MEM_STRBW*2]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial;

         end
         else begin: EQ64bit_MEM_1t1

            wire xpi_wr_wstrb_reduced0;
            wire xpi_wr_wstrb_reduced1;

            wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1;

            assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:MEM_STRBW];
            assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW];

            assign xpi_wr_wstrb_reduced0 = (|xpi_wr_wstrb[0+:MEM_STRBW]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
            assign xpi_wr_wstrb_reduced1 = (|xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
            assign xpi_wr_wstrb_reduced_ie  = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1;
            
         end
      end
      
     if (M_INLINE_ECC==0 || (M_INLINE_ECC==1 && M_SIDEBAND_ECC==1)) begin: ninline_ecc
         if (M_ECC==2) begin: ecc_mode_2_1t1
            assign xpi_wr_wstrb_reduced_nonie = (|xpi_wr_wstrb[0+:MEM_STRBW*2]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[0+:MEM_STRBW*2];
         end else begin: ecc_mode_0_1_3__1t1
            wire xpi_wr_wstrb_reduced0;
            wire xpi_wr_wstrb_reduced1;
        
            assign xpi_wr_wstrb_reduced0 = (|xpi_wr_wstrb[0+:MEM_STRBW]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[0+:MEM_STRBW];
            assign xpi_wr_wstrb_reduced1 = (|xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW];
            assign xpi_wr_wstrb_reduced_nonie  = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1;
         end
      end
    end
    if (NAB==2&&STRBW>4) begin: xpi_wr_wstrb_reduced_freq_1t2
      assign valid_wr_in_bc4 = 1'b0; // Used in only NAB=3 case.
      if (M_INLINE_ECC==1) begin: inline_ecc
         if (MEM_STRBW==2) begin: EQ16bit_MEM_1t2

            assign xpi_wr_wstrb_reduced_ie = (|xpi_wr_wstrb[0+:MEM_STRBW*4]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[0+:MEM_STRBW*4];

         end
         else if (MEM_STRBW==4) begin: EQ32bit_MEM_1t2

            wire xpi_wr_wstrb_reduced0;
            wire xpi_wr_wstrb_reduced1;

            wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1;

            assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:MEM_STRBW*2];
            assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2];

            assign xpi_wr_wstrb_reduced0  = (|xpi_wr_wstrb[0+:MEM_STRBW*2]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
            assign xpi_wr_wstrb_reduced1  = (|xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
            assign xpi_wr_wstrb_reduced_ie   = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1;

         end
         else begin: EQ64bit_MEM_1t2

            wire xpi_wr_wstrb_reduced0;
            wire xpi_wr_wstrb_reduced1;
            wire xpi_wr_wstrb_reduced2;
            wire xpi_wr_wstrb_reduced3;

            wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;

            assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:MEM_STRBW];
            assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW];
            assign xpi_wr_wstrb_partial2  = ~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW];
            assign xpi_wr_wstrb_partial3  = ~&xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW];

            assign xpi_wr_wstrb_reduced0  = (|xpi_wr_wstrb[0+:MEM_STRBW]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
            assign xpi_wr_wstrb_reduced1  = (|xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
            assign xpi_wr_wstrb_reduced2  = (|xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2;
            assign xpi_wr_wstrb_reduced3  = (|xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3;
            assign xpi_wr_wstrb_reduced_ie   = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3;

         end

      end
      if (M_INLINE_ECC==0 || (M_INLINE_ECC==1 && M_SIDEBAND_ECC==1)) begin: ninline_ecc      
         if (M_ECC==2) begin: ecc_mode_2_1t2
            wire xpi_wr_wstrb_reduced0;
            wire xpi_wr_wstrb_reduced1;
            assign xpi_wr_wstrb_reduced0 = (|xpi_wr_wstrb[0+:MEM_STRBW*2]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[0+:MEM_STRBW*2];
            assign xpi_wr_wstrb_reduced1 = (|xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2];
            assign xpi_wr_wstrb_reduced_nonie  = xpi_wr_wstrb_reduced0| 
                                          xpi_wr_wstrb_reduced1;
        
         end else begin: ecc_mode_0_1_3__1t2

           if (MEM_STRBW==16) begin : EQ64B_bus_1t2
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_reduced2;
             wire xpi_wr_wstrb_reduced3;
             wire xpi_wr_wstrb_reduced4;
             wire xpi_wr_wstrb_reduced5;
             wire xpi_wr_wstrb_reduced6;
             wire xpi_wr_wstrb_reduced7;

             assign xpi_wr_wstrb_reduced0 = (|xpi_wr_wstrb[0+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[0+:(MEM_STRBW/2)];                            
             assign xpi_wr_wstrb_reduced1 = (|xpi_wr_wstrb[(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[(MEM_STRBW/2)+:(MEM_STRBW/2)];    
             assign xpi_wr_wstrb_reduced2 = (|xpi_wr_wstrb[2*(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[2*(MEM_STRBW/2)+:(MEM_STRBW/2)];
             assign xpi_wr_wstrb_reduced3 = (|xpi_wr_wstrb[3*(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[3*(MEM_STRBW/2)+:(MEM_STRBW/2)];    
             assign xpi_wr_wstrb_reduced4 = (|xpi_wr_wstrb[4*(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[4*(MEM_STRBW/2)+:(MEM_STRBW/2)];
             assign xpi_wr_wstrb_reduced5 = (|xpi_wr_wstrb[5*(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[5*(MEM_STRBW/2)+:(MEM_STRBW/2)];
             assign xpi_wr_wstrb_reduced6 = (|xpi_wr_wstrb[6*(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[6*(MEM_STRBW/2)+:(MEM_STRBW/2)];
             assign xpi_wr_wstrb_reduced7 = (|xpi_wr_wstrb[7*(MEM_STRBW/2)+:(MEM_STRBW/2)]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[7*(MEM_STRBW/2)+:(MEM_STRBW/2)];
             assign xpi_wr_wstrb_reduced_nonie = xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3 |                 
                                            xpi_wr_wstrb_reduced4 | xpi_wr_wstrb_reduced5 | xpi_wr_wstrb_reduced6 | xpi_wr_wstrb_reduced7 ;     
 
           end else begin: nEQ64B_bus_1t2
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_reduced2;
             wire xpi_wr_wstrb_reduced3;

             assign xpi_wr_wstrb_reduced0 = (|xpi_wr_wstrb[0+:MEM_STRBW]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[0+:MEM_STRBW];
             assign xpi_wr_wstrb_reduced1 = (|xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_reduced2 = (|xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_reduced3 = (|xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW]|reg_xpi_dm_dis) & ~&xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_reduced_nonie = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1 |
                                            xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3;
           end
         end
      end
    end // block: xpi_wr_wstrb_reduced_freq_1t2
        
    if (NAB==3&&STRBW>8) begin: xpi_wr_wstrb_reduced_freq_1t4
      
      //Generating strobe mask pattern for HBW and QBW modes
      // MEM_STRBW =2 :
      //      HBW mask = 2'b01, QBW mask = <Invalid>
      // MEM_STRBW =4 :
      //      HBW mask = 4'b0011, QBW mask = 4'b0001
      // MEM_STRBW =8 :
      //      HBW mask = 8'h0F, QBW mask = 8'h03
      // MEM_STRBW =16 :
      //      HBW mask = 16'h0F0F, QBW mask = 16'h0303
      wire [MEM_STRBW-1 : 0] hbw_mem_strb_mask;
      assign hbw_mem_strb_mask =  (MEM_STRBW==16)? 16'h0F0F : {{(MEM_STRBW/2){1'b0}},{(MEM_STRBW/2){1'b1}}};
      wire [MEM_STRBW-1 : 0] qbw_mem_strb_mask;
//spyglass disable_block W528
//SMD: Variable 'qbw_mem_strb_mask[1:0]' set but not read
//SJ: Will not be used for (MEM_STRBW==2) as QBW mode is not valid.
      assign qbw_mem_strb_mask = (MEM_STRBW==16)? 16'h0303 :
                                 (MEM_STRBW==2)? 2'h0 : {{(MEM_STRBW*3/4){1'b0}},{(MEM_STRBW*1/4){1'b1}}};
//spyglass enable_block W528
      
      if (M_INLINE_ECC==1) begin: inline_ecc
         if (MEM_STRBW==2) begin: EQ16bit_MEM_1t4
             
             // in this combination of NAB and MEM_STRBW, there exists 2 64bit words in every HIF word (in FBW)
             // Strobe reduction is achieved by checking lower 64bit and higher 64bit words separately

             // In HBW, there is only one 64 bit word. Strobe reduction effectively checks for the only ECC word in the beat.
             // QBW is not valid in in DRAM_WIDTH=16 bits
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;

             wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1;
             wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1;
             wire beat_lsb_full_fbw, beat_msb_full_fbw, beat_lsb_empty_fbw, beat_msb_empty_fbw;
             // Partial signals indicate if there is atleast one byte masked.
             // 1: atleast one byte is masked in ECC word, 0: No byte is masked in ECC word
             assign xpi_wr_wstrb_partial0  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[0+:MEM_STRBW*4]) : (~&xpi_wr_wstrb[0+:MEM_STRBW*8]);
             assign xpi_wr_wstrb_partial1  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*4]) : 1'b0;
             // in HBW and QBW modes invalid byte strobes are kept high.
             // Strobs of these invalid bytes needs to be masked for the empty check performed below.
             wire [(8*MEM_STRBW)-1:0] hbw_strb_mask;
             assign hbw_strb_mask = {8{hbw_mem_strb_mask}};
             // not_empty signals indicate that there is atlast one valid byte(unmasked) in the ECC word.
             // 1: atleast one byte is valid in ECC word, 0: All bytes are masked in ECC word
             assign xpi_wr_wstrb_not_empty_0 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[0+:MEM_STRBW*4]) : (|(xpi_wr_wstrb[0+:MEM_STRBW*8] & hbw_strb_mask));
             assign xpi_wr_wstrb_not_empty_1 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*4]) : 1'b0;
             //Indicates if individual ECC words require a RMW or not.
             assign xpi_wr_wstrb_reduced0  = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
             assign xpi_wr_wstrb_reduced1  = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;

             assign beat_lsb_full_fbw = ~(xpi_wr_wstrb_reduced0);
             assign beat_msb_full_fbw = ~(xpi_wr_wstrb_reduced1);

             assign beat_lsb_empty_fbw = ~(xpi_wr_wstrb_not_empty_0);
             assign beat_msb_empty_fbw = ~(xpi_wr_wstrb_not_empty_1);
             // Indicates if the beat needs a RMW or not. 1: RMW required
             assign xpi_wr_wstrb_reduced_ie = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1;
             // Valid BC4 can happen only in FBW. In HBW only 8byte is availabe in HIF beat. BC4 means 4bytes which is not possible with Inline ECC.
             assign valid_wr_in_bc4 = (reg_ddrc_data_bus_width == FBW)? (((beat_lsb_full_fbw&beat_msb_empty_fbw)|(beat_msb_full_fbw&beat_lsb_empty_fbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      1'b0;
         end // EQ16bit_MEM_1t4
         else if (MEM_STRBW==4) begin: EQ32bit_MEM_1t4
             
             // In this config there can be 4 64bit words in each HIF beat
             // Strobe reduction is achieved by checking 4 quarters of HIF beat separately
             // In HBW there can be 2 64 bit words and in QBW 1 64 bit word.
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_reduced2;
             wire xpi_wr_wstrb_reduced3;

             wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;
             wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1, xpi_wr_wstrb_not_empty_2, xpi_wr_wstrb_not_empty_3;
             wire beat_lsb_full_fbw, beat_msb_full_fbw, beat_lsb_empty_fbw, beat_msb_empty_fbw;
             wire beat_lsb_full_hbw, beat_msb_full_hbw, beat_lsb_empty_hbw, beat_msb_empty_hbw;
             // Partial signals indicate if there is atleast one byte masked.
             // 1: atleast one byte is masked in ECC word, 0: No byte is masked in ECC word
             assign xpi_wr_wstrb_partial0  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[0+:MEM_STRBW*2]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[0+:MEM_STRBW*4]) : //HBW
                                             (~&xpi_wr_wstrb[0+:MEM_STRBW*8])); //QBW
             assign xpi_wr_wstrb_partial1  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*4]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial2  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*2]): //FBW
                                             1'b0; //HBW, QBW
             assign xpi_wr_wstrb_partial3  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW*2]): //FBW
                                             1'b0; //HBW, QBW

             wire [(4*MEM_STRBW)-1:0] hbw_strb_mask;
             wire [(8*MEM_STRBW)-1:0] qbw_strb_mask;
             // in HBW and QBW modes invalid byte strobes are kept high.
             // Strobs of these invalid bytes needs to be masked for the empty check performed below.
             assign hbw_strb_mask = {4{hbw_mem_strb_mask}};
             assign qbw_strb_mask = {8{qbw_mem_strb_mask}};
             // not_empty signals indicate that there is atlast one valid byte(unmasked) in the ECC word.
             // 1: atleast one byte is valid in ECC word, 0: All bytes are masked in ECC word
             assign xpi_wr_wstrb_not_empty_0 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[0+:MEM_STRBW*2]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[0+:MEM_STRBW*4] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[0+:MEM_STRBW*8] & qbw_strb_mask)));

             assign xpi_wr_wstrb_not_empty_1 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*4] & hbw_strb_mask)):
                                               1'b0);

             assign xpi_wr_wstrb_not_empty_2 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*2]):
                                               1'b0;

             assign xpi_wr_wstrb_not_empty_3 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW*2]):
                                               1'b0;
             //Indicates if individual ECC words require a RMW or not.
             // All 4 are valid in FBW as there are 4 ECC words.
             // First 4 are valid in HBW as there are 4 ECC words.
             // QBW is not valid.
             assign xpi_wr_wstrb_reduced0  = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
             assign xpi_wr_wstrb_reduced1  = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
             assign xpi_wr_wstrb_reduced2  = (xpi_wr_wstrb_not_empty_2|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2;
             assign xpi_wr_wstrb_reduced3  = (xpi_wr_wstrb_not_empty_3|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3;

             assign beat_lsb_full_fbw = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1);
             assign beat_msb_full_fbw = ~(xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);
             assign beat_lsb_empty_fbw = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1);
             assign beat_msb_empty_fbw = ~(xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);

             assign beat_lsb_full_hbw = ~(xpi_wr_wstrb_reduced0);
             assign beat_msb_full_hbw = ~(xpi_wr_wstrb_reduced1);
             assign beat_lsb_empty_hbw = ~(xpi_wr_wstrb_not_empty_0);
             assign beat_msb_empty_hbw = ~(xpi_wr_wstrb_not_empty_1);
             // Indicates if the beat needs a RMW or not. 1: RMW required
             assign xpi_wr_wstrb_reduced_ie = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1| xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3;
             //In QBW, one burst is 8 bytes. BC4 will have to write 4 bytes which is a partila ECC word. So BC4 is not possible in QBW mode
             assign valid_wr_in_bc4 = (reg_ddrc_data_bus_width == FBW)? (((beat_lsb_full_fbw&beat_msb_empty_fbw)|(beat_msb_full_fbw&beat_lsb_empty_fbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      ((reg_ddrc_data_bus_width == HBW)? (((beat_lsb_full_hbw&beat_msb_empty_hbw)|(beat_msb_full_hbw&beat_lsb_empty_hbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      1'b0);
         end  //EQ32bit_MEM_1t4
         else if (MEM_STRBW==8) begin: EQ64bit_MEM_1t4
             // In this config, there can be 8 64bit words in each HIF beat
             // Strobe reduction is achieved by checking 8 segments of HIF beat separately
             // In HBW there can be 4 64 bit words and in QBW 2 64 bit words.
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_reduced2;
             wire xpi_wr_wstrb_reduced3;
             wire xpi_wr_wstrb_reduced4;
             wire xpi_wr_wstrb_reduced5;
             wire xpi_wr_wstrb_reduced6;
             wire xpi_wr_wstrb_reduced7;

             wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;
             wire xpi_wr_wstrb_partial4, xpi_wr_wstrb_partial5, xpi_wr_wstrb_partial6, xpi_wr_wstrb_partial7;

             wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1, xpi_wr_wstrb_not_empty_2, xpi_wr_wstrb_not_empty_3;
             wire xpi_wr_wstrb_not_empty_4, xpi_wr_wstrb_not_empty_5, xpi_wr_wstrb_not_empty_6, xpi_wr_wstrb_not_empty_7;

             wire beat_lsb_full_fbw, beat_msb_full_fbw, beat_lsb_empty_fbw, beat_msb_empty_fbw;
             wire beat_lsb_full_hbw, beat_msb_full_hbw, beat_lsb_empty_hbw, beat_msb_empty_hbw;
             wire beat_lsb_full_qbw, beat_msb_full_qbw, beat_lsb_empty_qbw, beat_msb_empty_qbw;
             // Partial signals indicate if there is atleast one byte masked.
             // 1: atleast one byte is masked in ECC word, 0: No byte is masked in ECC word
             assign xpi_wr_wstrb_partial0  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[0+:MEM_STRBW]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[0+:MEM_STRBW*2]) : //HBW
                                             (~&xpi_wr_wstrb[0+:MEM_STRBW*4])); //QBW
             assign xpi_wr_wstrb_partial1  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2]) : //HBW
                                             (~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*4])); //QBW
             assign xpi_wr_wstrb_partial2  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*2]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial3  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW*2]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial4  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW]): //FBW
                                             1'b0; //HBW, QBW
             assign xpi_wr_wstrb_partial5  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[5*MEM_STRBW+:MEM_STRBW]): //FBW
                                             1'b0; //HBW, QBW
             assign xpi_wr_wstrb_partial6  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW]): //FBW
                                             1'b0; //HBW, QBW
             assign xpi_wr_wstrb_partial7  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[7*MEM_STRBW+:MEM_STRBW]): //FBW
                                             1'b0; //HBW, QBW

             wire [2*MEM_STRBW-1:0] hbw_strb_mask;
             wire [4*MEM_STRBW-1:0] qbw_strb_mask;
             // in HBW and QBW modes invalid byte strobes are kept high.
             // Strobs of these invalid bytes needs to be masked for the empty check performed below.
             assign hbw_strb_mask = {2{hbw_mem_strb_mask}};
             assign qbw_strb_mask = {4{qbw_mem_strb_mask}};
             // not_empty signals indicate that there is atlast one valid byte(unmasked) in the ECC word.
             // 1: atleast one byte is valid in ECC word, 0: All bytes are masked in ECC word
             assign xpi_wr_wstrb_not_empty_0 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[0+:MEM_STRBW]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[0+:MEM_STRBW*2] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[0+:MEM_STRBW*4] & qbw_strb_mask)));
             assign xpi_wr_wstrb_not_empty_1 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*4] & qbw_strb_mask)));

             assign xpi_wr_wstrb_not_empty_2 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*2] & hbw_strb_mask)):
                                               1'b0);
             assign xpi_wr_wstrb_not_empty_3 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW*2] & hbw_strb_mask)):
                                               1'b0);

             assign xpi_wr_wstrb_not_empty_4 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_5 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[5*MEM_STRBW+:MEM_STRBW]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_6 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_7 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[7*MEM_STRBW+:MEM_STRBW]):
                                               1'b0;
             //Indicates if individual ECC words require a RMW or not.
             // All 8 are valid in FBW as there are 8 ECC words.
             // First 4 are valid in HBW as there are 4 ECC words.
             // First 2 are valid in QBW as there are 2 ECC words.
             assign xpi_wr_wstrb_reduced0  = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
             assign xpi_wr_wstrb_reduced1  = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
             assign xpi_wr_wstrb_reduced2  = (xpi_wr_wstrb_not_empty_2|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2;
             assign xpi_wr_wstrb_reduced3  = (xpi_wr_wstrb_not_empty_3|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3;
             assign xpi_wr_wstrb_reduced4  = (xpi_wr_wstrb_not_empty_4|reg_xpi_dm_dis) & xpi_wr_wstrb_partial4;
             assign xpi_wr_wstrb_reduced5  = (xpi_wr_wstrb_not_empty_5|reg_xpi_dm_dis) & xpi_wr_wstrb_partial5;
             assign xpi_wr_wstrb_reduced6  = (xpi_wr_wstrb_not_empty_6|reg_xpi_dm_dis) & xpi_wr_wstrb_partial6;
             assign xpi_wr_wstrb_reduced7  = (xpi_wr_wstrb_not_empty_7|reg_xpi_dm_dis) & xpi_wr_wstrb_partial7;

             assign beat_lsb_full_fbw = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);
             assign beat_msb_full_fbw = ~(xpi_wr_wstrb_reduced4 | xpi_wr_wstrb_reduced5 | xpi_wr_wstrb_reduced6 | xpi_wr_wstrb_reduced7);
             assign beat_lsb_empty_fbw = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1 | xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);
             assign beat_msb_empty_fbw = ~(xpi_wr_wstrb_not_empty_4 | xpi_wr_wstrb_not_empty_5 | xpi_wr_wstrb_not_empty_6 | xpi_wr_wstrb_not_empty_7);

             assign beat_lsb_full_hbw = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1);
             assign beat_msb_full_hbw = ~(xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);
             assign beat_lsb_empty_hbw = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1);
             assign beat_msb_empty_hbw = ~(xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);

             assign beat_lsb_full_qbw = ~(xpi_wr_wstrb_reduced0);
             assign beat_msb_full_qbw = ~(xpi_wr_wstrb_reduced1);
             assign beat_lsb_empty_qbw = ~(xpi_wr_wstrb_not_empty_0);
             assign beat_msb_empty_qbw = ~(xpi_wr_wstrb_not_empty_1);
             // Indicates if the beat needs a RMW or not. 1: RMW required
             assign xpi_wr_wstrb_reduced_ie = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1| xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3 |
                                                  xpi_wr_wstrb_reduced4| xpi_wr_wstrb_reduced5| xpi_wr_wstrb_reduced6| xpi_wr_wstrb_reduced7;
             //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
             assign valid_wr_in_bc4 = (reg_ddrc_data_bus_width == FBW)? (((beat_lsb_full_fbw&beat_msb_empty_fbw)|(beat_msb_full_fbw&beat_lsb_empty_fbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      ((reg_ddrc_data_bus_width == HBW)? (((beat_lsb_full_hbw&beat_msb_empty_hbw)|(beat_msb_full_hbw&beat_lsb_empty_hbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      (((beat_lsb_full_qbw&beat_msb_empty_qbw)|(beat_msb_full_qbw&beat_lsb_empty_qbw)) & reg_mbl16_bl8_bc_crc_dis_nab3));
         end // EQ64bit_MEM_1t4
         else if (MEM_STRBW==16) begin: EQ128bit_MEM_1t4
             // In this config, there can be 16 64bit words in each HIF beat
             // Strobe reduction is achieved by checking 8 segments of HIF beat separately
             // In HBW there can be 8 64 bit words and in QBW 4 64 bit words.
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_reduced2;
             wire xpi_wr_wstrb_reduced3;
             wire xpi_wr_wstrb_reduced4;
             wire xpi_wr_wstrb_reduced5;
             wire xpi_wr_wstrb_reduced6;
             wire xpi_wr_wstrb_reduced7;
             wire xpi_wr_wstrb_reduced8;
             wire xpi_wr_wstrb_reduced9;
             wire xpi_wr_wstrb_reduced10;
             wire xpi_wr_wstrb_reduced11;
             wire xpi_wr_wstrb_reduced12;
             wire xpi_wr_wstrb_reduced13;
             wire xpi_wr_wstrb_reduced14;
             wire xpi_wr_wstrb_reduced15;

             wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;
             wire xpi_wr_wstrb_partial4, xpi_wr_wstrb_partial5, xpi_wr_wstrb_partial6, xpi_wr_wstrb_partial7;
             wire xpi_wr_wstrb_partial8, xpi_wr_wstrb_partial9, xpi_wr_wstrb_partial10, xpi_wr_wstrb_partial11;
             wire xpi_wr_wstrb_partial12, xpi_wr_wstrb_partial13, xpi_wr_wstrb_partial14, xpi_wr_wstrb_partial15;

             wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1, xpi_wr_wstrb_not_empty_2, xpi_wr_wstrb_not_empty_3;
             wire xpi_wr_wstrb_not_empty_4, xpi_wr_wstrb_not_empty_5, xpi_wr_wstrb_not_empty_6, xpi_wr_wstrb_not_empty_7;
             wire xpi_wr_wstrb_not_empty_8, xpi_wr_wstrb_not_empty_9, xpi_wr_wstrb_not_empty_10, xpi_wr_wstrb_not_empty_11;
             wire xpi_wr_wstrb_not_empty_12, xpi_wr_wstrb_not_empty_13, xpi_wr_wstrb_not_empty_14, xpi_wr_wstrb_not_empty_15;

             wire beat_lsb_full_fbw, beat_msb_full_fbw, beat_lsb_empty_fbw, beat_msb_empty_fbw;
             wire beat_lsb_full_hbw, beat_msb_full_hbw, beat_lsb_empty_hbw, beat_msb_empty_hbw;
             wire beat_lsb_full_qbw, beat_msb_full_qbw, beat_lsb_empty_qbw, beat_msb_empty_qbw;
             // Partial signals indicate if there is atleast one byte masked.
             // 1: atleast one byte is masked in ECC word, 0: No byte is masked in ECC word
             assign xpi_wr_wstrb_partial0  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[0+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[0+:MEM_STRBW]) : //HBW
                                             (~&xpi_wr_wstrb[0+:MEM_STRBW*2])); //QBW
             assign xpi_wr_wstrb_partial1  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]) : //HBW
                                             (~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2])); //QBW
             assign xpi_wr_wstrb_partial2  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(2*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[(2*MEM_STRBW)+:MEM_STRBW]) : //HBW
                                             (~&xpi_wr_wstrb[(4*MEM_STRBW)+:MEM_STRBW*2])); //QBW
             assign xpi_wr_wstrb_partial3  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(3*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[(3*MEM_STRBW)+:MEM_STRBW]) : //HBW
                                             (~&xpi_wr_wstrb[(6*MEM_STRBW)+:MEM_STRBW*2])); //QBW
             assign xpi_wr_wstrb_partial4  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(4*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[(4*MEM_STRBW)+:MEM_STRBW]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial5  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(5*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[(5*MEM_STRBW)+:MEM_STRBW]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial6  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(6*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[(6*MEM_STRBW)+:MEM_STRBW]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial7  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(7*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             ((reg_ddrc_data_bus_width == HBW)? (~&xpi_wr_wstrb[(7*MEM_STRBW)+:MEM_STRBW]) : //HBW
                                             1'b0); //QBW
             assign xpi_wr_wstrb_partial8  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(8*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial9  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(9*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial10  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(10*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial11  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(11*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial12  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(12*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial13  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(13*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial14  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(14*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;
             assign xpi_wr_wstrb_partial15  = (reg_ddrc_data_bus_width == FBW)? (~&xpi_wr_wstrb[(15*MEM_STRBW/2)+:(MEM_STRBW/2)]): //FBW
                                             1'b0;

             wire [MEM_STRBW-1:0] hbw_strb_mask;
             wire [2*MEM_STRBW-1:0] qbw_strb_mask;
             // in HBW and QBW modes invalid byte strobes are kept high.
             // Strobs of these invalid bytes needs to be masked for the empty check performed below.
             assign hbw_strb_mask = hbw_mem_strb_mask;
             assign qbw_strb_mask = {2{qbw_mem_strb_mask}};
             // not_empty signals indicate that there is atlast one valid byte(unmasked) in the ECC word.
             // 1: atleast one byte is valid in ECC word, 0: All bytes are masked in ECC word
             assign xpi_wr_wstrb_not_empty_0 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[0+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[0+:MEM_STRBW] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[0+:MEM_STRBW*2] & qbw_strb_mask)));
             assign xpi_wr_wstrb_not_empty_1 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW*2] & qbw_strb_mask)));
             assign xpi_wr_wstrb_not_empty_2 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(2*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW*2] & qbw_strb_mask)));
             assign xpi_wr_wstrb_not_empty_3 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(3*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               (|(xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW*2] & qbw_strb_mask)));

             assign xpi_wr_wstrb_not_empty_4 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(4*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               1'b0);
             assign xpi_wr_wstrb_not_empty_5 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(5*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[5*MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               1'b0);
             assign xpi_wr_wstrb_not_empty_6 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(6*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               1'b0);
             assign xpi_wr_wstrb_not_empty_7 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(7*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               ((reg_ddrc_data_bus_width == HBW)? (|(xpi_wr_wstrb[7*MEM_STRBW+:MEM_STRBW] & hbw_strb_mask)):
                                               1'b0);

             assign xpi_wr_wstrb_not_empty_8 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(8*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_9 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(9*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_10 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(10*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_11 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(11*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_12 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(12*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_13 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(13*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_14 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(14*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             assign xpi_wr_wstrb_not_empty_15 = (reg_ddrc_data_bus_width == FBW)? (|xpi_wr_wstrb[(15*MEM_STRBW/2)+:(MEM_STRBW/2)]):
                                               1'b0;
             //Indicates if individual ECC words require a RMW or not.
             // All 16 are valid in FBW as there are 16 ECC words.
             // First 8 are valid in HBW as there are 8 ECC words.
             // First 4 are valid in QBW as there are 4 ECC words.
             assign xpi_wr_wstrb_reduced0  = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
             assign xpi_wr_wstrb_reduced1  = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
             assign xpi_wr_wstrb_reduced2  = (xpi_wr_wstrb_not_empty_2|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2;
             assign xpi_wr_wstrb_reduced3  = (xpi_wr_wstrb_not_empty_3|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3;
             assign xpi_wr_wstrb_reduced4  = (xpi_wr_wstrb_not_empty_4|reg_xpi_dm_dis) & xpi_wr_wstrb_partial4;
             assign xpi_wr_wstrb_reduced5  = (xpi_wr_wstrb_not_empty_5|reg_xpi_dm_dis) & xpi_wr_wstrb_partial5;
             assign xpi_wr_wstrb_reduced6  = (xpi_wr_wstrb_not_empty_6|reg_xpi_dm_dis) & xpi_wr_wstrb_partial6;
             assign xpi_wr_wstrb_reduced7  = (xpi_wr_wstrb_not_empty_7|reg_xpi_dm_dis) & xpi_wr_wstrb_partial7;
             assign xpi_wr_wstrb_reduced8  = (xpi_wr_wstrb_not_empty_8|reg_xpi_dm_dis) & xpi_wr_wstrb_partial8;
             assign xpi_wr_wstrb_reduced9  = (xpi_wr_wstrb_not_empty_9|reg_xpi_dm_dis) & xpi_wr_wstrb_partial9;
             assign xpi_wr_wstrb_reduced10  = (xpi_wr_wstrb_not_empty_10|reg_xpi_dm_dis) & xpi_wr_wstrb_partial10;
             assign xpi_wr_wstrb_reduced11  = (xpi_wr_wstrb_not_empty_11|reg_xpi_dm_dis) & xpi_wr_wstrb_partial11;
             assign xpi_wr_wstrb_reduced12  = (xpi_wr_wstrb_not_empty_12|reg_xpi_dm_dis) & xpi_wr_wstrb_partial12;
             assign xpi_wr_wstrb_reduced13  = (xpi_wr_wstrb_not_empty_13|reg_xpi_dm_dis) & xpi_wr_wstrb_partial13;
             assign xpi_wr_wstrb_reduced14  = (xpi_wr_wstrb_not_empty_14|reg_xpi_dm_dis) & xpi_wr_wstrb_partial14;
             assign xpi_wr_wstrb_reduced15  = (xpi_wr_wstrb_not_empty_15|reg_xpi_dm_dis) & xpi_wr_wstrb_partial15;

             assign beat_lsb_full_fbw = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3 |
                                          xpi_wr_wstrb_reduced4 | xpi_wr_wstrb_reduced5 | xpi_wr_wstrb_reduced6 | xpi_wr_wstrb_reduced7);
             assign beat_msb_full_fbw = ~(xpi_wr_wstrb_reduced8 | xpi_wr_wstrb_reduced9 | xpi_wr_wstrb_reduced10 | xpi_wr_wstrb_reduced11 |
                                          xpi_wr_wstrb_reduced12 | xpi_wr_wstrb_reduced13 | xpi_wr_wstrb_reduced14 | xpi_wr_wstrb_reduced15);

             assign beat_lsb_empty_fbw = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1 | xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3 |
                                           xpi_wr_wstrb_not_empty_4 | xpi_wr_wstrb_not_empty_5 | xpi_wr_wstrb_not_empty_6 | xpi_wr_wstrb_not_empty_7);
             assign beat_msb_empty_fbw = ~(xpi_wr_wstrb_not_empty_8 | xpi_wr_wstrb_not_empty_9 | xpi_wr_wstrb_not_empty_10 | xpi_wr_wstrb_not_empty_11 |
                                           xpi_wr_wstrb_not_empty_12 | xpi_wr_wstrb_not_empty_13 | xpi_wr_wstrb_not_empty_14 | xpi_wr_wstrb_not_empty_15);

             assign beat_lsb_full_hbw = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);
             assign beat_msb_full_hbw = ~(xpi_wr_wstrb_reduced4 | xpi_wr_wstrb_reduced5 | xpi_wr_wstrb_reduced6 | xpi_wr_wstrb_reduced7);
             assign beat_lsb_empty_hbw = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1 | xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);
             assign beat_msb_empty_hbw = ~(xpi_wr_wstrb_not_empty_4 | xpi_wr_wstrb_not_empty_5 | xpi_wr_wstrb_not_empty_6 | xpi_wr_wstrb_not_empty_7);

             assign beat_lsb_full_qbw = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1);
             assign beat_msb_full_qbw = ~(xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);
             assign beat_lsb_empty_qbw = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1);
             assign beat_msb_empty_qbw = ~(xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);
             // Indicates if the beat needs a RMW or not. 1: RMW required
             assign xpi_wr_wstrb_reduced_ie = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1| xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3 |
                                           xpi_wr_wstrb_reduced4| xpi_wr_wstrb_reduced5| xpi_wr_wstrb_reduced6| xpi_wr_wstrb_reduced7 |
                                           xpi_wr_wstrb_reduced8| xpi_wr_wstrb_reduced9| xpi_wr_wstrb_reduced10| xpi_wr_wstrb_reduced11 |
                                           xpi_wr_wstrb_reduced12| xpi_wr_wstrb_reduced13| xpi_wr_wstrb_reduced14| xpi_wr_wstrb_reduced15;
             //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
             assign valid_wr_in_bc4 = (reg_ddrc_data_bus_width == FBW)? (((beat_lsb_full_fbw&beat_msb_empty_fbw)|(beat_msb_full_fbw&beat_lsb_empty_fbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      ((reg_ddrc_data_bus_width == HBW)? (((beat_lsb_full_hbw&beat_msb_empty_hbw)|(beat_msb_full_hbw&beat_lsb_empty_hbw)) & reg_mbl16_bl8_bc_crc_dis_nab3):
                                      (((beat_lsb_full_qbw&beat_msb_empty_qbw)|(beat_msb_full_qbw&beat_lsb_empty_qbw)) & reg_mbl16_bl8_bc_crc_dis_nab3));
         end // EQ128bit_MEM_1t4
      end else begin :  ninline_ecc
         if (M_ECC==2 || M_ECC==3) begin: gen_ecc_mode_2_3_1t4 //Advanced ECC x4
            if (DATA_CHANNEL_INTERLEAVE_NS==1) begin : EQ128B_bus_ecc2
            // When DATA_CHANNEL_INTERLEAVE_NS=1, MEM_STRBW contains 2 DRAM words.
            // ECC is calculated over 4 DRAM words. As this is a dual channel config, there is 16 DRAM words in HIF beat. So 4 ECC words.
            // Strobe reduction checks happen on each ECC word seperately.
              wire xpi_wr_wstrb_reduced0;
              wire xpi_wr_wstrb_reduced1;
              wire xpi_wr_wstrb_reduced2;
              wire xpi_wr_wstrb_reduced3;

              wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;

              wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1, xpi_wr_wstrb_not_empty_2, xpi_wr_wstrb_not_empty_3;

              wire beat_lsb_full, beat_msb_full, beat_lsb_empty, beat_msb_empty;
              // Checking if all the strobes are 1 or not.
              // 0:all individual strobes are 1
              // 1:one or more individual strobes are 0
              assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:(2*MEM_STRBW)];
              assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[2*MEM_STRBW+:(2*MEM_STRBW)];
              assign xpi_wr_wstrb_partial2  = ~&xpi_wr_wstrb[4*MEM_STRBW+:(2*MEM_STRBW)];
              assign xpi_wr_wstrb_partial3  = ~&xpi_wr_wstrb[6*MEM_STRBW+:(2*MEM_STRBW)];

              // in HBW and QBW modes invalid byte strobes are kept high.
              // Strobs of these invalid bytes needs to be masked for the empty check performed below.
              wire [(2*MEM_STRBW)-1:0] hbw_qbw_strb_mask;
              assign hbw_qbw_strb_mask = (reg_ddrc_data_bus_width == HBW)? {2{hbw_mem_strb_mask}} : ((reg_ddrc_data_bus_width == QBW)? {2{qbw_mem_strb_mask}} : {2*MEM_STRBW{1'b1}});

              //Checking if all the valid are 0 or not.
              // 0:all valid strobes are 0
              // 1:one or more valid strobes are 1
              assign xpi_wr_wstrb_not_empty_0 = |(xpi_wr_wstrb[0+:(2*MEM_STRBW)]           & hbw_qbw_strb_mask);
              assign xpi_wr_wstrb_not_empty_1 = |(xpi_wr_wstrb[2*MEM_STRBW+:(2*MEM_STRBW)] & hbw_qbw_strb_mask);
              assign xpi_wr_wstrb_not_empty_2 = |(xpi_wr_wstrb[4*MEM_STRBW+:(2*MEM_STRBW)] & hbw_qbw_strb_mask);
              assign xpi_wr_wstrb_not_empty_3 = |(xpi_wr_wstrb[6*MEM_STRBW+:(2*MEM_STRBW)] & hbw_qbw_strb_mask);
              //Indicates if individual ECC words require a RMW or not.
              // 1: The corresponding ECC word require a RMW, 0: The corresponding ECC word does not require a RMW
              assign xpi_wr_wstrb_reduced0  = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
              assign xpi_wr_wstrb_reduced1  = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
              assign xpi_wr_wstrb_reduced2  = (xpi_wr_wstrb_not_empty_2|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2;
              assign xpi_wr_wstrb_reduced3  = (xpi_wr_wstrb_not_empty_3|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3;

              assign beat_lsb_full = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1);
              assign beat_msb_full = ~(xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);

              assign beat_lsb_empty = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1);
              assign beat_msb_empty = ~(xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);
              // Indicates if the beat needs a RMW or not. 1: RMW required
              assign xpi_wr_wstrb_reduced_nonie_advecc = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1| xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3;
              //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
              assign valid_wr_in_bc4_advecc = ((beat_lsb_full&beat_msb_empty)|(beat_msb_full&beat_lsb_empty)) & reg_mbl16_bl8_bc_crc_dis_nab3;
            end else begin: nEQ128B_bus_ecc2
              // In this config, there are 2 sideband x4 ECC words in every HIF beat
              // each of these 2 words need to be checked for wstrb reduction
               wire xpi_wr_wstrb_reduced0;
               wire xpi_wr_wstrb_reduced1;
               wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1;
               wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1;
               wire beat_lsb_full, beat_msb_full, beat_lsb_empty, beat_msb_empty;
               
               // Checking if all the strobes are 1 or not.
               // 0:all individual strobes are 1
               // 1:one or more individual strobes are 0
               assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:(MEM_STRBW*4)];
               assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[(4*MEM_STRBW)+:(MEM_STRBW*4)];

               // in HBW and QBW modes invalid byte strobes are kept high.
               // Strobs of these invalid bytes needs to be masked for the empty check performed below.
               wire [(MEM_STRBW*4)-1:0] hbw_qbw_strb_mask;
               assign hbw_qbw_strb_mask = (reg_ddrc_data_bus_width == HBW)? {4{hbw_mem_strb_mask}} : ((reg_ddrc_data_bus_width == QBW)? {4{qbw_mem_strb_mask}} : {(MEM_STRBW*4){1'b1}});

               //Checking if all the valid are 0 or not.
               // 0:all valid strobes are 0
               // 1:one or more valid strobes are 1
               assign xpi_wr_wstrb_not_empty_0 = |(xpi_wr_wstrb[0+:(MEM_STRBW*4)]             & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_1 = |(xpi_wr_wstrb[(4*MEM_STRBW)+:(MEM_STRBW*4)] & hbw_qbw_strb_mask);
               //Indicates if individual ECC words require a RMW or not.
               // 1: The corresponding ECC word require a RMW, 0: The corresponding ECC word does not require a RMW
               assign xpi_wr_wstrb_reduced0 = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
               assign xpi_wr_wstrb_reduced1 = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;

               assign beat_lsb_full = ~(xpi_wr_wstrb_reduced0);
               assign beat_msb_full = ~(xpi_wr_wstrb_reduced1);

               assign beat_lsb_empty = ~(xpi_wr_wstrb_not_empty_0);
               assign beat_msb_empty = ~(xpi_wr_wstrb_not_empty_1);
               // Indicates if the beat needs a RMW or not. 1: RMW required
               assign xpi_wr_wstrb_reduced_nonie_advecc = xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1;
               //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
               assign valid_wr_in_bc4_advecc = ((beat_lsb_full&beat_msb_empty)|(beat_msb_full&beat_lsb_empty)) & reg_mbl16_bl8_bc_crc_dis_nab3;
            end //nEQ128B_bus_ecc2
         end //gen_ecc_mode_2_3_1t4

         if (M_ECC==1 || M_ECC==3) begin: gen_ecc_mode_1_3 //SECDED ECC
           if (DATA_CHANNEL_INTERLEAVE_NS==1) begin : EQ128B_bus_1t4
               // Wgen DATA_CHANNEL_INTERLEAVE_NS =1, MEM_STRBW contains 2 ECC words.
               // Normal SECDED is calculated over 1 DRAM word.
               // Multi beat SECDED is calculated over 2 DRAM words
               wire xpi_wr_wstrb_reduced0;
               wire xpi_wr_wstrb_reduced1;
               wire xpi_wr_wstrb_reduced2;
               wire xpi_wr_wstrb_reduced3;
               wire xpi_wr_wstrb_reduced4;
               wire xpi_wr_wstrb_reduced5;
               wire xpi_wr_wstrb_reduced6;
               wire xpi_wr_wstrb_reduced7;
               wire xpi_wr_wstrb_reduced8;
               wire xpi_wr_wstrb_reduced9;
               wire xpi_wr_wstrb_reduced10;
               wire xpi_wr_wstrb_reduced11;
               wire xpi_wr_wstrb_reduced12;
               wire xpi_wr_wstrb_reduced13;
               wire xpi_wr_wstrb_reduced14;
               wire xpi_wr_wstrb_reduced15;

               wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;
               wire xpi_wr_wstrb_partial4, xpi_wr_wstrb_partial5, xpi_wr_wstrb_partial6, xpi_wr_wstrb_partial7;
               wire xpi_wr_wstrb_partial8, xpi_wr_wstrb_partial9, xpi_wr_wstrb_partial10, xpi_wr_wstrb_partial11;
               wire xpi_wr_wstrb_partial12, xpi_wr_wstrb_partial13, xpi_wr_wstrb_partial14, xpi_wr_wstrb_partial15;

               wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1, xpi_wr_wstrb_not_empty_2, xpi_wr_wstrb_not_empty_3;
               wire xpi_wr_wstrb_not_empty_4, xpi_wr_wstrb_not_empty_5, xpi_wr_wstrb_not_empty_6, xpi_wr_wstrb_not_empty_7;
               wire xpi_wr_wstrb_not_empty_8, xpi_wr_wstrb_not_empty_9, xpi_wr_wstrb_not_empty_10, xpi_wr_wstrb_not_empty_11;
               wire xpi_wr_wstrb_not_empty_12, xpi_wr_wstrb_not_empty_13, xpi_wr_wstrb_not_empty_14, xpi_wr_wstrb_not_empty_15;

               // Multi beat ECC related signals
               wire xpi_wr_wstrb_partial0_mbeat, xpi_wr_wstrb_partial1_mbeat, xpi_wr_wstrb_partial2_mbeat, xpi_wr_wstrb_partial3_mbeat;
               wire xpi_wr_wstrb_partial4_mbeat, xpi_wr_wstrb_partial5_mbeat, xpi_wr_wstrb_partial6_mbeat, xpi_wr_wstrb_partial7_mbeat;
               wire xpi_wr_wstrb_not_empty_0_mbeat, xpi_wr_wstrb_not_empty_1_mbeat, xpi_wr_wstrb_not_empty_2_mbeat, xpi_wr_wstrb_not_empty_3_mbeat;
               wire xpi_wr_wstrb_not_empty_4_mbeat, xpi_wr_wstrb_not_empty_5_mbeat, xpi_wr_wstrb_not_empty_6_mbeat, xpi_wr_wstrb_not_empty_7_mbeat;
               wire beat_lsb_full_mbeat, beat_msb_full_mbeat, beat_lsb_empty_mbeat, beat_msb_empty_mbeat;
               wire xpi_wr_wstrb_reduced0_mbeat;
               wire xpi_wr_wstrb_reduced1_mbeat;
               wire xpi_wr_wstrb_reduced2_mbeat;
               wire xpi_wr_wstrb_reduced3_mbeat;
               wire xpi_wr_wstrb_reduced4_mbeat;
               wire xpi_wr_wstrb_reduced5_mbeat;
               wire xpi_wr_wstrb_reduced6_mbeat;
               wire xpi_wr_wstrb_reduced7_mbeat;

               wire beat_lsb_full, beat_msb_full, beat_lsb_empty, beat_msb_empty;
               wire xpi_wr_wstrb_reduced_in_bl;

               // Checking if all the strobes are 1 or not.
               // 0:all individual strobes are 1
               // 1:one or more individual strobes are 0
               assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial2  = ~&xpi_wr_wstrb[2*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial3  = ~&xpi_wr_wstrb[3*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial4  = ~&xpi_wr_wstrb[4*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial5  = ~&xpi_wr_wstrb[5*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial6  = ~&xpi_wr_wstrb[6*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial7  = ~&xpi_wr_wstrb[7*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial8  = ~&xpi_wr_wstrb[8*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial9  = ~&xpi_wr_wstrb[9*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial10  = ~&xpi_wr_wstrb[10*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial11  = ~&xpi_wr_wstrb[11*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial12  = ~&xpi_wr_wstrb[12*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial13  = ~&xpi_wr_wstrb[13*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial14  = ~&xpi_wr_wstrb[14*(MEM_STRBW/2)+:(MEM_STRBW/2)];
               assign xpi_wr_wstrb_partial15  = ~&xpi_wr_wstrb[15*(MEM_STRBW/2)+:(MEM_STRBW/2)];

               assign xpi_wr_wstrb_partial0_mbeat  = xpi_wr_wstrb_partial0  | xpi_wr_wstrb_partial1;
               assign xpi_wr_wstrb_partial1_mbeat  = xpi_wr_wstrb_partial2  | xpi_wr_wstrb_partial3;
               assign xpi_wr_wstrb_partial2_mbeat  = xpi_wr_wstrb_partial4  | xpi_wr_wstrb_partial5;
               assign xpi_wr_wstrb_partial3_mbeat  = xpi_wr_wstrb_partial6  | xpi_wr_wstrb_partial7;
               assign xpi_wr_wstrb_partial4_mbeat  = xpi_wr_wstrb_partial8  | xpi_wr_wstrb_partial9;
               assign xpi_wr_wstrb_partial5_mbeat  = xpi_wr_wstrb_partial10 | xpi_wr_wstrb_partial11;
               assign xpi_wr_wstrb_partial6_mbeat  = xpi_wr_wstrb_partial12 | xpi_wr_wstrb_partial13;
               assign xpi_wr_wstrb_partial7_mbeat  = xpi_wr_wstrb_partial14 | xpi_wr_wstrb_partial15;

               // in HBW and QBW modes invalid byte strobes are kept high.
               // Strobs of these invalid bytes needs to be masked for the empty check performed below.
               wire [(MEM_STRBW/2)-1:0] hbw_qbw_strb_mask;
               assign hbw_qbw_strb_mask = (reg_ddrc_data_bus_width == HBW)? hbw_mem_strb_mask[(MEM_STRBW/2)-1:0] : 
                                          (reg_ddrc_data_bus_width == QBW)? qbw_mem_strb_mask[(MEM_STRBW/2)-1:0]  : {(MEM_STRBW/2){1'b1}};

               //Checking if all the valid are 0 or not.
               // 0:all valid strobes are 0
               // 1:one or more valid strobes are 1
               assign xpi_wr_wstrb_not_empty_0 = |(xpi_wr_wstrb[0+:(MEM_STRBW/2)]               & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_1 = |(xpi_wr_wstrb[(MEM_STRBW/2)+:(MEM_STRBW/2)]   & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_2 = |(xpi_wr_wstrb[2*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_3 = |(xpi_wr_wstrb[3*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_4 = |(xpi_wr_wstrb[4*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_5 = |(xpi_wr_wstrb[5*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_6 = |(xpi_wr_wstrb[6*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_7 = |(xpi_wr_wstrb[7*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_8 = |(xpi_wr_wstrb[8*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_9 = |(xpi_wr_wstrb[9*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_10 = |(xpi_wr_wstrb[10*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_11 = |(xpi_wr_wstrb[11*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_12 = |(xpi_wr_wstrb[12*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_13 = |(xpi_wr_wstrb[13*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_14 = |(xpi_wr_wstrb[14*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);
               assign xpi_wr_wstrb_not_empty_15 = |(xpi_wr_wstrb[15*(MEM_STRBW/2)+:(MEM_STRBW/2)] & hbw_qbw_strb_mask);

               assign xpi_wr_wstrb_not_empty_0_mbeat  = xpi_wr_wstrb_not_empty_0  | xpi_wr_wstrb_not_empty_1;
               assign xpi_wr_wstrb_not_empty_1_mbeat  = xpi_wr_wstrb_not_empty_2  | xpi_wr_wstrb_not_empty_3;
               assign xpi_wr_wstrb_not_empty_2_mbeat  = xpi_wr_wstrb_not_empty_4  | xpi_wr_wstrb_not_empty_5;
               assign xpi_wr_wstrb_not_empty_3_mbeat  = xpi_wr_wstrb_not_empty_6  | xpi_wr_wstrb_not_empty_7;
               assign xpi_wr_wstrb_not_empty_4_mbeat  = xpi_wr_wstrb_not_empty_8  | xpi_wr_wstrb_not_empty_9;
               assign xpi_wr_wstrb_not_empty_5_mbeat  = xpi_wr_wstrb_not_empty_10 | xpi_wr_wstrb_not_empty_11;
               assign xpi_wr_wstrb_not_empty_6_mbeat  = xpi_wr_wstrb_not_empty_12 | xpi_wr_wstrb_not_empty_13;
               assign xpi_wr_wstrb_not_empty_7_mbeat  = xpi_wr_wstrb_not_empty_14 | xpi_wr_wstrb_not_empty_15;
               //Indicates if individual ECC words require a RMW or not.
               // 1: The corresponding ECC word require a RMW, 0: The corresponding ECC word does not require a RMW
               assign xpi_wr_wstrb_reduced0 =  (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial0; 
               assign xpi_wr_wstrb_reduced1 =  (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial1;
               assign xpi_wr_wstrb_reduced2 =  (xpi_wr_wstrb_not_empty_2|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial2;
               assign xpi_wr_wstrb_reduced3 =  (xpi_wr_wstrb_not_empty_3|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial3;
               assign xpi_wr_wstrb_reduced4 =  (xpi_wr_wstrb_not_empty_4|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial4;
               assign xpi_wr_wstrb_reduced5 =  (xpi_wr_wstrb_not_empty_5|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial5;
               assign xpi_wr_wstrb_reduced6 =  (xpi_wr_wstrb_not_empty_6|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial6;
               assign xpi_wr_wstrb_reduced7 =  (xpi_wr_wstrb_not_empty_7|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial7;
               assign xpi_wr_wstrb_reduced8 =  (xpi_wr_wstrb_not_empty_8|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial8;
               assign xpi_wr_wstrb_reduced9 =  (xpi_wr_wstrb_not_empty_9|reg_xpi_dm_dis)  & xpi_wr_wstrb_partial9;
               assign xpi_wr_wstrb_reduced10 = (xpi_wr_wstrb_not_empty_10|reg_xpi_dm_dis) & xpi_wr_wstrb_partial10;
               assign xpi_wr_wstrb_reduced11 = (xpi_wr_wstrb_not_empty_11|reg_xpi_dm_dis) & xpi_wr_wstrb_partial11;
               assign xpi_wr_wstrb_reduced12 = (xpi_wr_wstrb_not_empty_12|reg_xpi_dm_dis) & xpi_wr_wstrb_partial12;
               assign xpi_wr_wstrb_reduced13 = (xpi_wr_wstrb_not_empty_13|reg_xpi_dm_dis) & xpi_wr_wstrb_partial13;
               assign xpi_wr_wstrb_reduced14 = (xpi_wr_wstrb_not_empty_14|reg_xpi_dm_dis) & xpi_wr_wstrb_partial14;
               assign xpi_wr_wstrb_reduced15 = (xpi_wr_wstrb_not_empty_15|reg_xpi_dm_dis) & xpi_wr_wstrb_partial15;

               assign xpi_wr_wstrb_reduced0_mbeat  = (xpi_wr_wstrb_not_empty_0_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0_mbeat;
               assign xpi_wr_wstrb_reduced1_mbeat  = (xpi_wr_wstrb_not_empty_1_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1_mbeat;
               assign xpi_wr_wstrb_reduced2_mbeat  = (xpi_wr_wstrb_not_empty_2_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2_mbeat;
               assign xpi_wr_wstrb_reduced3_mbeat  = (xpi_wr_wstrb_not_empty_3_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3_mbeat;
               assign xpi_wr_wstrb_reduced4_mbeat  = (xpi_wr_wstrb_not_empty_4_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial4_mbeat;
               assign xpi_wr_wstrb_reduced5_mbeat  = (xpi_wr_wstrb_not_empty_5_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial5_mbeat;
               assign xpi_wr_wstrb_reduced6_mbeat  = (xpi_wr_wstrb_not_empty_6_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial6_mbeat;
               assign xpi_wr_wstrb_reduced7_mbeat  = (xpi_wr_wstrb_not_empty_7_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial7_mbeat;

               //These are needed only for BC4 support. BC4 is possible only in DDR4. Multi beat SECDED ECC is not applicable for DDR4
               assign beat_lsb_full = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3 |
                                        xpi_wr_wstrb_reduced4 | xpi_wr_wstrb_reduced5 | xpi_wr_wstrb_reduced6 | xpi_wr_wstrb_reduced7);

               assign beat_msb_full = ~(xpi_wr_wstrb_reduced8 | xpi_wr_wstrb_reduced9 | xpi_wr_wstrb_reduced10 | xpi_wr_wstrb_reduced11 |
                                        xpi_wr_wstrb_reduced12 | xpi_wr_wstrb_reduced13 | xpi_wr_wstrb_reduced14 | xpi_wr_wstrb_reduced15);

               assign beat_lsb_empty = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1 | xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3 |
                                         xpi_wr_wstrb_not_empty_4 | xpi_wr_wstrb_not_empty_5 | xpi_wr_wstrb_not_empty_6 | xpi_wr_wstrb_not_empty_7);

               assign beat_msb_empty = ~(xpi_wr_wstrb_not_empty_8 | xpi_wr_wstrb_not_empty_9 | xpi_wr_wstrb_not_empty_10 | xpi_wr_wstrb_not_empty_11 |
                                        xpi_wr_wstrb_not_empty_12 | xpi_wr_wstrb_not_empty_13 | xpi_wr_wstrb_not_empty_14 | xpi_wr_wstrb_not_empty_15);

               assign xpi_wr_wstrb_reduced_in_bl = (reg_ddrc_multi_beat_ecc==1'b0)? (xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1| xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3 |
                                                                              xpi_wr_wstrb_reduced4| xpi_wr_wstrb_reduced5| xpi_wr_wstrb_reduced6| xpi_wr_wstrb_reduced7 |
                                                                              xpi_wr_wstrb_reduced8| xpi_wr_wstrb_reduced9| xpi_wr_wstrb_reduced10| xpi_wr_wstrb_reduced11 |
                                                                              xpi_wr_wstrb_reduced12| xpi_wr_wstrb_reduced13| xpi_wr_wstrb_reduced14| xpi_wr_wstrb_reduced15) :
                                                                              (xpi_wr_wstrb_reduced0_mbeat | xpi_wr_wstrb_reduced1_mbeat |
                                                                               xpi_wr_wstrb_reduced2_mbeat | xpi_wr_wstrb_reduced3_mbeat |
                                                                               xpi_wr_wstrb_reduced4_mbeat | xpi_wr_wstrb_reduced5_mbeat | 
                                                                               xpi_wr_wstrb_reduced6_mbeat | xpi_wr_wstrb_reduced7_mbeat);

               //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
               assign valid_wr_in_bc4_secded = ((beat_lsb_full&beat_msb_empty)|(beat_msb_full&beat_lsb_empty)) & reg_mbl16_bl8_bc_crc_dis_nab3;
               // Indicates if the beat needs a RMW or not. 1: RMW required
               assign xpi_wr_wstrb_reduced_nonie_secded  = xpi_wr_wstrb_reduced_in_bl & ~((M_ECC==0) && (reg_xpi_dm_dis == 1'b0));
 
           end else begin: nEQ128B_bus_1t4
            // In this config, there are 8 sideband ECC words in every HIF beat
            // each of these 8 words need to be checked for wstrb reduction
             
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_reduced2;
             wire xpi_wr_wstrb_reduced3;
             wire xpi_wr_wstrb_reduced4;
             wire xpi_wr_wstrb_reduced5;
             wire xpi_wr_wstrb_reduced6;
             wire xpi_wr_wstrb_reduced7;

             wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1, xpi_wr_wstrb_partial2, xpi_wr_wstrb_partial3;
             wire xpi_wr_wstrb_partial4, xpi_wr_wstrb_partial5, xpi_wr_wstrb_partial6, xpi_wr_wstrb_partial7;

             wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1, xpi_wr_wstrb_not_empty_2, xpi_wr_wstrb_not_empty_3;
             wire xpi_wr_wstrb_not_empty_4, xpi_wr_wstrb_not_empty_5, xpi_wr_wstrb_not_empty_6, xpi_wr_wstrb_not_empty_7;

             wire beat_lsb_full, beat_msb_full, beat_lsb_empty, beat_msb_empty;
             wire xpi_wr_wstrb_reduced_in_bl;

             // Multi beat ECC related signals
             wire xpi_wr_wstrb_partial0_mbeat, xpi_wr_wstrb_partial1_mbeat, xpi_wr_wstrb_partial2_mbeat, xpi_wr_wstrb_partial3_mbeat;
             wire xpi_wr_wstrb_not_empty_0_mbeat, xpi_wr_wstrb_not_empty_1_mbeat, xpi_wr_wstrb_not_empty_2_mbeat, xpi_wr_wstrb_not_empty_3_mbeat;
             wire beat_lsb_full_mbeat, beat_msb_full_mbeat, beat_lsb_empty_mbeat, beat_msb_empty_mbeat;
             wire xpi_wr_wstrb_reduced0_mbeat;
             wire xpi_wr_wstrb_reduced1_mbeat;
             wire xpi_wr_wstrb_reduced2_mbeat;
             wire xpi_wr_wstrb_reduced3_mbeat;

             // Checking if all the strobes are 1 or not.
             // 0:all individual strobes are 1
             // 1:one or more individual strobes are 0
             assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:MEM_STRBW];
             assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_partial2  = ~&xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_partial3  = ~&xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_partial4  = ~&xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_partial5  = ~&xpi_wr_wstrb[5*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_partial6  = ~&xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW];
             assign xpi_wr_wstrb_partial7  = ~&xpi_wr_wstrb[7*MEM_STRBW+:MEM_STRBW];

             assign xpi_wr_wstrb_partial0_mbeat  = xpi_wr_wstrb_partial0 | xpi_wr_wstrb_partial1;
             assign xpi_wr_wstrb_partial1_mbeat  = xpi_wr_wstrb_partial2 | xpi_wr_wstrb_partial3;
             assign xpi_wr_wstrb_partial2_mbeat  = xpi_wr_wstrb_partial4 | xpi_wr_wstrb_partial5;
             assign xpi_wr_wstrb_partial3_mbeat  = xpi_wr_wstrb_partial6 | xpi_wr_wstrb_partial7;

             // in HBW and QBW modes invalid byte strobes are kept high.
             // Strobs of these invalid bytes needs to be masked for the empty check performed below.
             wire [MEM_STRBW-1:0] hbw_qbw_strb_mask;
             assign hbw_qbw_strb_mask = (reg_ddrc_data_bus_width == HBW)? hbw_mem_strb_mask : ((reg_ddrc_data_bus_width == QBW)? qbw_mem_strb_mask : {MEM_STRBW{1'b1}});
             //Checking if all the valid are 0 or not.
             // 0:all valid strobes are 0
             // 1:one or more valid strobes are 1
             assign xpi_wr_wstrb_not_empty_0 = |(xpi_wr_wstrb[0+:MEM_STRBW]           & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_1 = |(xpi_wr_wstrb[MEM_STRBW+:MEM_STRBW]   & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_2 = |(xpi_wr_wstrb[2*MEM_STRBW+:MEM_STRBW] & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_3 = |(xpi_wr_wstrb[3*MEM_STRBW+:MEM_STRBW] & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_4 = |(xpi_wr_wstrb[4*MEM_STRBW+:MEM_STRBW] & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_5 = |(xpi_wr_wstrb[5*MEM_STRBW+:MEM_STRBW] & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_6 = |(xpi_wr_wstrb[6*MEM_STRBW+:MEM_STRBW] & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_7 = |(xpi_wr_wstrb[7*MEM_STRBW+:MEM_STRBW] & hbw_qbw_strb_mask);

             assign xpi_wr_wstrb_not_empty_0_mbeat = xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1;
             assign xpi_wr_wstrb_not_empty_1_mbeat = xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3;
             assign xpi_wr_wstrb_not_empty_2_mbeat = xpi_wr_wstrb_not_empty_4 | xpi_wr_wstrb_not_empty_5;
             assign xpi_wr_wstrb_not_empty_3_mbeat = xpi_wr_wstrb_not_empty_6 | xpi_wr_wstrb_not_empty_7;

             //Indicates if individual ECC words require a RMW or not.
             // 1: The corresponding ECC word require a RMW, 0: The corresponding ECC word does not require a RMW
             assign xpi_wr_wstrb_reduced0  = (xpi_wr_wstrb_not_empty_0|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0;
             assign xpi_wr_wstrb_reduced1  = (xpi_wr_wstrb_not_empty_1|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1;
             assign xpi_wr_wstrb_reduced2  = (xpi_wr_wstrb_not_empty_2|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2;
             assign xpi_wr_wstrb_reduced3  = (xpi_wr_wstrb_not_empty_3|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3;
             assign xpi_wr_wstrb_reduced4  = (xpi_wr_wstrb_not_empty_4|reg_xpi_dm_dis) & xpi_wr_wstrb_partial4;
             assign xpi_wr_wstrb_reduced5  = (xpi_wr_wstrb_not_empty_5|reg_xpi_dm_dis) & xpi_wr_wstrb_partial5;
             assign xpi_wr_wstrb_reduced6  = (xpi_wr_wstrb_not_empty_6|reg_xpi_dm_dis) & xpi_wr_wstrb_partial6;
             assign xpi_wr_wstrb_reduced7  = (xpi_wr_wstrb_not_empty_7|reg_xpi_dm_dis) & xpi_wr_wstrb_partial7;

             assign xpi_wr_wstrb_reduced0_mbeat  = (xpi_wr_wstrb_not_empty_0_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial0_mbeat;
             assign xpi_wr_wstrb_reduced1_mbeat  = (xpi_wr_wstrb_not_empty_1_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial1_mbeat;
             assign xpi_wr_wstrb_reduced2_mbeat  = (xpi_wr_wstrb_not_empty_2_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial2_mbeat;
             assign xpi_wr_wstrb_reduced3_mbeat  = (xpi_wr_wstrb_not_empty_3_mbeat|reg_xpi_dm_dis) & xpi_wr_wstrb_partial3_mbeat;

             //These are needed only for BC4 support. BC4 is possible only in DDR4. Multi beat SECDED ECC is not applicable for DDR4
             assign beat_lsb_full = ~(xpi_wr_wstrb_reduced0 | xpi_wr_wstrb_reduced1 | xpi_wr_wstrb_reduced2 | xpi_wr_wstrb_reduced3);
             assign beat_msb_full = ~(xpi_wr_wstrb_reduced4 | xpi_wr_wstrb_reduced5 | xpi_wr_wstrb_reduced6 | xpi_wr_wstrb_reduced7);

             assign beat_lsb_empty = ~(xpi_wr_wstrb_not_empty_0 | xpi_wr_wstrb_not_empty_1 | xpi_wr_wstrb_not_empty_2 | xpi_wr_wstrb_not_empty_3);
             assign beat_msb_empty = ~(xpi_wr_wstrb_not_empty_4 | xpi_wr_wstrb_not_empty_5 | xpi_wr_wstrb_not_empty_6 | xpi_wr_wstrb_not_empty_7);

             assign xpi_wr_wstrb_reduced_in_bl = (reg_ddrc_multi_beat_ecc==1'b0)?
                                                 (xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1| xpi_wr_wstrb_reduced2| xpi_wr_wstrb_reduced3 |
                                                  xpi_wr_wstrb_reduced4| xpi_wr_wstrb_reduced5| xpi_wr_wstrb_reduced6| xpi_wr_wstrb_reduced7) :
                                                 (xpi_wr_wstrb_reduced0_mbeat | xpi_wr_wstrb_reduced1_mbeat |
                                                  xpi_wr_wstrb_reduced2_mbeat | xpi_wr_wstrb_reduced3_mbeat); //multi beat ECC
             //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
             assign valid_wr_in_bc4_secded = ((beat_lsb_full&beat_msb_empty)|(beat_msb_full&beat_lsb_empty)) & reg_mbl16_bl8_bc_crc_dis_nab3;
             // Indicates if the beat needs a RMW or not. 1: RMW required
             assign xpi_wr_wstrb_reduced_nonie_secded  = xpi_wr_wstrb_reduced_in_bl & ~((M_ECC==0) && (reg_xpi_dm_dis == 1'b0));

          end // nEQ64B_bus_1t4
        end else if (M_ECC==0) begin : gen_ecc_mode_0
             wire xpi_wr_wstrb_reduced0;
             wire xpi_wr_wstrb_reduced1;
             wire xpi_wr_wstrb_partial0, xpi_wr_wstrb_partial1;
             wire xpi_wr_wstrb_not_empty_0, xpi_wr_wstrb_not_empty_1;
             wire beat_lsb_full, beat_msb_full, beat_lsb_empty, beat_msb_empty;
             wire xpi_wr_wstrb_reduced_in_bl;
             // Checking if all the strobes are 1 or not.
             // 0:all individual strobes are 1
             // 1:one or more individual strobes are 0
             assign xpi_wr_wstrb_partial0  = ~&xpi_wr_wstrb[0+:(4*MEM_STRBW)];
             assign xpi_wr_wstrb_partial1  = ~&xpi_wr_wstrb[4*MEM_STRBW+:(4*MEM_STRBW)];
             // in HBW and QBW modes invalid byte strobes are kept high.
             // Strobs of these invalid bytes needs to be masked for the empty check performed below.
             wire [(4*MEM_STRBW)-1:0] hbw_qbw_strb_mask;
             assign hbw_qbw_strb_mask = (reg_ddrc_data_bus_width == HBW)? {4{hbw_mem_strb_mask}} : ((reg_ddrc_data_bus_width == QBW)? {4{qbw_mem_strb_mask}} : {(4*MEM_STRBW){1'b1}});
             //Checking if all the valid are 0 or not.
             // 0:all valid strobes are 0
             // 1:one or more valid strobes are 1
             assign xpi_wr_wstrb_not_empty_0 = |(xpi_wr_wstrb[0+:(4*MEM_STRBW)]           & hbw_qbw_strb_mask);
             assign xpi_wr_wstrb_not_empty_1 = |(xpi_wr_wstrb[4*MEM_STRBW+:(4*MEM_STRBW)] & hbw_qbw_strb_mask);
             //Indicates if individual ECC words require a RMW or not.
             // 1: The corresponding ECC word require a RMW, 0: The corresponding ECC word does not require a RMW
             assign xpi_wr_wstrb_reduced0  = reg_xpi_dm_dis & xpi_wr_wstrb_partial0;
             assign xpi_wr_wstrb_reduced1  = reg_xpi_dm_dis & xpi_wr_wstrb_partial1;

             assign beat_lsb_full = ~(xpi_wr_wstrb_reduced0);
             assign beat_msb_full = ~(xpi_wr_wstrb_reduced1);

             assign beat_lsb_empty = ~(xpi_wr_wstrb_not_empty_0);
             assign beat_msb_empty = ~(xpi_wr_wstrb_not_empty_1);

             assign xpi_wr_wstrb_reduced_in_bl = (xpi_wr_wstrb_reduced0| xpi_wr_wstrb_reduced1);

             //BC4 write can be performed if one half of the burst is fully masked and the other half does not require a RMW.
             assign valid_wr_in_bc4_secded = ((beat_lsb_full&beat_msb_empty)|(beat_msb_full&beat_lsb_empty)) & reg_mbl16_bl8_bc_crc_dis_nab3;
             // Indicates if the beat needs a RMW or not. 1: RMW required
             assign xpi_wr_wstrb_reduced_nonie_secded  = xpi_wr_wstrb_reduced_in_bl & ~((M_ECC==0) && (reg_xpi_dm_dis == 1'b0));

        end else begin // gen_ecc_mode_0
           assign xpi_wr_wstrb_reduced_nonie_secded = 1'b0;
           assign valid_wr_in_bc4_secded = 1'b0;
        end //gen_ecc_mode_1_3
        
        if (M_ECC==3) begin : gen_secded_adv
          assign xpi_wr_wstrb_reduced_nonie = (reg_ddrc_ecc_mode==3'b101)? xpi_wr_wstrb_reduced_nonie_advecc : xpi_wr_wstrb_reduced_nonie_secded;
          assign valid_wr_in_bc4 = (reg_ddrc_ecc_mode==3'b101)? valid_wr_in_bc4_advecc : valid_wr_in_bc4_secded;
        end else if (M_ECC==2) begin : gen_adv
          assign xpi_wr_wstrb_reduced_nonie = xpi_wr_wstrb_reduced_nonie_advecc;
          assign valid_wr_in_bc4 = valid_wr_in_bc4_advecc;
        end else if (M_ECC==0 || M_ECC==1) begin : gen_secded_or_noecc
          assign xpi_wr_wstrb_reduced_nonie = xpi_wr_wstrb_reduced_nonie_secded;
          assign valid_wr_in_bc4 = valid_wr_in_bc4_secded;
        end
      end //  ninline_ecc  
    end // block:  xpi_wr_wstrb_reduced_freq_1t4   
        
    // memory data width is one byte.
    if (NAB==1&&STRBW<=2 || NAB==2&&STRBW<=4 || NAB==3&&STRBW<=8) begin: xpi_wr_wstrb_reduced_mem_1b
      if (M_INLINE_ECC==1) begin: inline_ecc
        assign xpi_wr_wstrb_reduced_ie    = reg_xpi_dm_dis & ~&xpi_wr_wstrb;
      end  
      if (M_INLINE_ECC==0 || (M_INLINE_ECC==1 && M_SIDEBAND_ECC==1)) begin: ninline_ecc      
        assign xpi_wr_wstrb_reduced_nonie = reg_xpi_dm_dis & ~&xpi_wr_wstrb;
      end  
   end

   if (M_INLINE_ECC==1 && M_SIDEBAND_ECC==1) begin: IECC_NONIECC_enA
     assign xpi_wr_wstrb_reduced    = (reg_ddrc_ecc_type) ? xpi_wr_wstrb_reduced_ie : xpi_wr_wstrb_reduced_nonie;
   end else if (M_INLINE_ECC==1) begin: IECC_ONLY_enA
     assign xpi_wr_wstrb_reduced    = xpi_wr_wstrb_reduced_ie;
   end else  begin: IECC_ONLY_disA
     assign xpi_wr_wstrb_reduced    = xpi_wr_wstrb_reduced_nonie;
   end


   if (M_INLINE_ECC==1) begin: IECC_en
      
      wire wstrb_full;
      wire [NBEATS-1:0] wdata_mask_full_r, wdata_mask_full_next;
      reg  [NBEATS-1:0] wdata_mask_full;
      wire [NBEATS-1:0] wsr_wdata_mask_full;

      assign wstrb_full = &xpi_wr_wstrb & xpi_wr_wvalid;

      always @(*) begin: Mask_full_GEN
         wdata_mask_full = wdata_mask_full_r;
         wdata_mask_full[xpi_wr_beat_count] = wstrb_full;
      end

      assign wdata_mask_full_next = wsr_wr ? {NBEATS{1'b0}} : wdata_mask_full;

      DWC_ddr_umctl2_par_reg
      
      #(
         .DW      (NBEATS),
         .OCCAP   (OCCAP_EN),
         .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)         
      )
      U_wdata_mask_full
      (
         .clk        (clk),
         .rst_n      (rst_n),
         .data_in    (wdata_mask_full_next),
         .reg_set    (1'b0),
         .parity_en  (reg_ddrc_occap_en),
         .poison_en  (1'b0),
         .data_out   (wdata_mask_full_r),
         .parity_err (wdata_mask_full_par_err_ie)
      );

      assign wsr_d_ie   = reg_xpi_rmw_mode_ie ? {wstrb_is_rmw,wdata_mask_full} : {WSRW{1'b0}};
      assign {wsr_wstrb_reduced_accu_ie,wsr_wdata_mask_full} = xpi_rmw_bypass_dis? wsr_q : wsr_d;

      assign rmw_wdata_mask_full_ie   = wsr_wdata_mask_full;

    end else begin: XXX
    end 
   if (M_INLINE_ECC==0 || (M_INLINE_ECC==1 && M_SIDEBAND_ECC==1)) begin: IECC_dis
      assign wsr_d_nonie                   = wstrb_is_rmw;
      assign wsr_wstrb_reduced_accu_nonie  = xpi_rmw_bypass_dis? wsr_q[0] : wsr_d[0];
      assign rmw_wdata_mask_full_nonie     = {NBEATS{1'b0}};
      assign wdata_mask_full_par_err_nonie = 1'b0;

   end

   if (M_INLINE_ECC==1 && M_SIDEBAND_ECC==1) begin: IECC_NONIECC_enB
     assign wsr_d                   = (reg_ddrc_ecc_type) ? wsr_d_ie : wsr_d_nonie;
     assign wsr_wstrb_reduced_accu  = (reg_ddrc_ecc_type) ? wsr_wstrb_reduced_accu_ie : wsr_wstrb_reduced_accu_nonie;
     assign rmw_wdata_mask_full     = (reg_ddrc_ecc_type) ? rmw_wdata_mask_full_ie : rmw_wdata_mask_full_nonie;
     assign wdata_mask_full_par_err = (reg_ddrc_ecc_type) ? wdata_mask_full_par_err_ie : wdata_mask_full_par_err_nonie;
   end else if (M_INLINE_ECC==1) begin: IECC_ONLY_enB
     assign wsr_d                   = wsr_d_ie;
     assign wsr_wstrb_reduced_accu  = wsr_wstrb_reduced_accu_ie;
     assign rmw_wdata_mask_full     = rmw_wdata_mask_full_ie;
     assign wdata_mask_full_par_err = wdata_mask_full_par_err_ie;
   end else  begin: IECC_ONLY_disB
     assign wsr_d                   = wsr_d_nonie;
     assign wsr_wstrb_reduced_accu  = wsr_wstrb_reduced_accu_nonie;
     assign rmw_wdata_mask_full     = rmw_wdata_mask_full_nonie;
     assign wdata_mask_full_par_err = wdata_mask_full_par_err_nonie; 
   end


  endgenerate

  // Generate rmw command if accumulated strobed bytes within a burst OR exclusive access write OR short write OR poisoned write with DM disabled or parity error and DM disabled
  assign rmw_awrmw            = ((wsr_wstrb_reduced_accu & ~rmw_dis_ie) | (reg_xpi_dm_dis & rmw_wexa_acc_lock) | (rmw_wpoison & reg_xpi_dm_dis) | (rmw_ocpar_err & reg_xpi_dm_dis)) & (i_reg_xpi_rmw_mode_or);
  assign wstrb_reduced_accu   = wstrb_reduced_reg | (xpi_wr_wvalid & xpi_wr_wstrb_reduced);
  // Accumulate write strobe and clear register when last beat is received 
  assign wstrb_reduced_next   = wstrb_reduced_accu & ~(wdq_wr & xpi_wr_wlast_pkt);

  DWC_ddr_umctl2_par_reg
  
  #(
     .DW      (1),
     .OCCAP   (OCCAP_EN),
     .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)     
  )
  U_wstrb_reduced
  (
     .clk        (clk),
     .rst_n      (rst_n),
     .data_in    (wstrb_reduced_next),
     .reg_set    (1'b0),
     .parity_en  (reg_ddrc_occap_en),
     .poison_en  (1'b0),
     .data_out   (wstrb_reduced_reg),
     .parity_err (wstrb_reduced_par_err)
  );

  //---------------------------------------------------------------------------
  // Write Strobe Retime
  //---------------------------------------------------------------------------
  // If it is a valid BC4 write, RMW is not required.
  assign wstrb_is_rmw            = (wstrb_reduced_accu & ~valid_wr_in_bc4) | (xpi_short_write & reg_xpi_dm_dis);
  // blocking wsr_wr when bypass enabled.
  assign wsr_wr                  = xpi_wr_wvalid&(~wdq_full)&(~wperq_full) & xpi_wr_wlast_pkt & xpi_rmw_bypass_dis;
  assign wsr_rd                  = (snf_mode_int? (hif_awready & rmw_awvalid) : (wdq_rd & rmw_wlast_pkt));

   
  DWC_ddr_umctl2_retime
  
  #(
  .SIZE     (WSRW),
  .OCCAP_EN (OCCAP_EN),
  .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)  
  ) 
  U_wsr
  (
    .clk         (clk),    
    .rst_n       (rst_n),    
    .d           (wsr_d),
    .wr          (wsr_wr),
    .rd          (wsr_rd),
    .par_en      (reg_ddrc_occap_en),
    .q           (wsr_q),
    .fe          (wsr_empty),
    .ff          (wsr_full),
    .par_err     (xpi_rmw_wsr_par_err)
  );

  //---------------------------------------------------------------------------
  // Write Data Queue
  //---------------------------------------------------------------------------
  assign rmw_wvalid  = wdq_or_bypass_valid ;
  assign rmw_wready  = wdq_or_bypass_ready&((~wperq_full&(~wsr_full|~snf_mode_int)) | ~xpi_rmw_bypass_dis); //block write data when two bursts are stored
  // block wdq_wr when bypass is active.
  assign wdq_wr      = xpi_wr_wvalid & rmw_wready & xpi_rmw_bypass_dis;
  assign wdq_rd      = hif_wready;

  wire [WDQD_LG2:0] wcount_unused;
  DWC_ddr_umctl2_gfifo
  
  #(
    .WIDTH       (WDQW),
    .DEPTH       (WDQD),  
    .ADDR_WIDTH  (WDQD_LG2),
    .COUNT_WIDTH (WDQD_LG2+1),
    .OCCAP_EN    (OCCAP_EN),
    .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)    
  ) 
  U_wdq 
  (
    .clk         (clk),
    .rst_n       (rst_n),
    .wr          (wdq_wr),  
    .d           (wdq_d),
    .rd          (wdq_rd),
    .par_en      (reg_ddrc_occap_en),
    .init_n      (1'b1),
    .ff          (wdq_full),
    .wcount      (wcount_unused), 
    .q           (wdq_q),
    .fe          (wdq_empty),
    .par_err     (xpi_rmw_wdq_par_err)
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~wdq_empty
    ,.disable_sva_fifo_checker_wr (1'b0)
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
  );
  // valid to be given from wdq or bypass logic. If bypass is not active, then not(empty) is valid.
  // else xpi_wr_wvalid is passed as valid.
  assign wdq_or_bypass_valid = xpi_rmw_bypass_dis? ~wdq_empty :
                                                      xpi_wr_wvalid;
  // ready to be given from wdq or bypass logic. If bypass is not active, then not(full) is valid.
  // else hif_wready is passed as ready.
  assign wdq_or_bypass_ready = xpi_rmw_bypass_dis? ~wdq_full :
                                                      hif_wready;

  generate
  if ((DUAL_CHANNEL_INTERLEAVE==0) && (OCPAR_EN == 1 || OCECC_EN == 1)) begin: PAR_OR_ECC_en 
    assign wdq_d       = {xpi_wr_wlast,xpi_wr_wlast_pkt,xpi_wr_wstrb,xpi_wr_wdata, xpi_wr_wparity, xpi_wr_wdata_channel, xpi_wr_deacc_info};
    assign               {rmw_wlast,   rmw_wlast_pkt,   rmw_wstrb,   rmw_wdata,    rmw_wparity,    rmw_wdata_channel,    rmw_deacc_info} = xpi_rmw_bypass_dis? wdq_q : wdq_d;

    //Accumulation logic
    wire  [STRBW-1:0] wpar_err_acc_nxt;
    reg   [STRBW-1:0] wpar_err_acc;
    wire  [STRBW-1:0] wperq_d;
    wire              wperq_rd_i;
    // accumulating the the wr_par_err when internal snf mode is enabled.
    assign wperq_d =   snf_mode_int ? (xpi_wr_wpar_err|wpar_err_acc) : xpi_wr_wpar_err;
    
    assign wperq_wr =  (xpi_wr_wlast | (~snf_mode_int))  &  wdq_wr ;

    assign wperq_rd_i = snf_mode_int ? wperq_rd : wdq_rd ;
    
    assign wpar_err_acc_nxt =  wperq_wr ? {STRBW{1'b0}} :
                               xpi_wr_wvalid ? (xpi_wr_wpar_err | wpar_err_acc) :
                               wpar_err_acc;

    always @(posedge clk or negedge rst_n) begin: wpar_err_acc_PROC
        if (rst_n==1'b0) 
           wpar_err_acc <= {STRBW{1'b0}} ;
        else  
           wpar_err_acc <= wpar_err_acc_nxt ;
    end

     wire  [WDQD_LG2:0] wpercount_unused;
     wire  [STRBW-1:0]  rmw_wpar_err_w;
     DWC_ddr_umctl2_gfifo
     
     #(
       .WIDTH       (STRBW),
       .DEPTH       (WDQD),  
       .ADDR_WIDTH  (WDQD_LG2),
       .COUNT_WIDTH (WDQD_LG2+1),
       .OCCAP_EN    (OCCAP_EN),
       .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)       
     ) 
     U_wperq 
     (
       .clk         (clk),
       .rst_n       (rst_n),
       .wr          (wperq_wr),  
       .d           (wperq_d),
       .rd          (wperq_rd_i),
       .par_en      (reg_ddrc_occap_en),
       .init_n      (1'b1),
       .ff          (wperq_full),
       .wcount      (wpercount_unused), 
       .q           (rmw_wpar_err_w),
       .fe          (wperq_empty_unused),//unused
       .par_err     (xpi_rmw_wperq_par_err)
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~wdq_empty
    ,.disable_sva_fifo_checker_wr (1'b0)
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
     );
     // bypass logic
     assign rmw_wpar_err = xpi_rmw_bypass_dis? rmw_wpar_err_w : xpi_wr_wpar_err;

   end else begin : PAR_OR_ECC_dis
      assign wdq_d       = {xpi_wr_wlast,xpi_wr_wlast_pkt,xpi_wr_wstrb,xpi_wr_wdata, xpi_wr_wparity, xpi_wr_wpar_err, xpi_wr_wdata_channel, xpi_wr_deacc_info};
      assign               {rmw_wlast,   rmw_wlast_pkt,   rmw_wstrb,   rmw_wdata,    rmw_wparity,    rmw_wpar_err,    rmw_wdata_channel,    rmw_deacc_info} = xpi_rmw_bypass_dis? wdq_q : wdq_d;
      assign wperq_full  = 1'b0;
      assign xpi_rmw_wperq_par_err = 1'b0;
   end
  endgenerate


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  assert_never #(0, 0, "QBW when MEM_STRBW == 2 ", 5) qbw_mode_in_dram_width_16 (clk, rst_n, ((MEM_STRBW == 2) && (reg_ddrc_data_bus_width == QBW)));
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule // DWC_ddr_umctl2_xpi_rmw
