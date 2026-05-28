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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_pa_port.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               PA port. Implements aging counter, 
//               and output to DDRC priority (LPR,HPR) for reads
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_pa_port
  #(
    parameter QOSW               = 1,
    parameter REG_PORT_PRIORITYW = 10,
    parameter PORT_PRIORITYW     = 5,
    parameter EXT_PORTPRIO       = 0,
    parameter PA_OPT_TYPE        = 1,   //1==TWOCYCLE, 2==COMB
    parameter QOS_RW             = 2,
    parameter OCCAP_EN           = 0,
    parameter OCCAP_PIPELINE_EN  = 0
    )
   (
    input                          clk,
    input                          rst_n,
    
    input                          hif_cmd_stall,
    input                          req,
    input                          grant_nxt,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block. 
    input [QOSW-1:0]               qos,
//spyglass enable_block W240
    input [REG_PORT_PRIORITYW-1:0] reg_port_priority,
    input [QOS_RW-1:0]             qos_priority,
    input                          urgent,
    input                          vpt_expired,
    input                          reg_urgent_en,
    input                          reg_aging_en,

    input                          reg_ddrc_occap_en,
    output                         pa_port_parity_err,

    output                         priority0,
    output [PORT_PRIORITYW-1:0]    port_priority,
    output [QOS_RW-1:0]            pa_pri,
    output                         xa_pri
    );

    localparam PA_PORT_VEC_WIDTH = QOS_RW+1+1+REG_PORT_PRIORITYW;

    wire [PA_PORT_VEC_WIDTH-1:0] pa_port_vec_i, pa_port_vec_r;

   wire [QOS_RW-1:0] pri_reg_nxt;
   wire [QOS_RW-1:0] pri_reg_r;
   wire [QOS_RW-1:0] pri_reg;
   wire priority0_i;
   wire rst_dly1_nxt, rst_dly2_nxt;
   wire  rst_dly1, rst_dly2;
   reg [REG_PORT_PRIORITYW-1:0] aging_cnt_nxt;
   wire [REG_PORT_PRIORITYW-1:0] aging_cnt;   
   wire set_priority_on_rst;

   assign pa_port_vec_i = {pri_reg_nxt,rst_dly1_nxt,rst_dly2_nxt,aging_cnt_nxt};
   assign {pri_reg_r,rst_dly1,rst_dly2,aging_cnt} = pa_port_vec_r;

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (PA_PORT_VEC_WIDTH),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .REG_EN  (0),
      .SL_W    (8))
   U_pa_port_vec_r
   (  .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (pa_port_vec_i),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (pa_port_vec_r),
      .parity_err (pa_port_parity_err));

   assign pri_reg = (grant_nxt) ? qos_priority : {(QOS_RW){1'b0}};
   
   assign pri_reg_nxt = (~hif_cmd_stall) ? pri_reg : pri_reg_r;

   generate
      if (PA_OPT_TYPE==2) begin: COMB_pa
         assign pa_pri = pri_reg;
      end
      else begin: SEQ_pa
         assign pa_pri = pri_reg_r;
      end
   endgenerate
   
   // Single port configurations use dynamic AXI qos signal for DDRC transaction priority,
   // otherwise it is enabled by a register
   assign xa_pri = qos_priority[1];
      
     
   assign priority0_i = ~(|aging_cnt);
   assign priority0 = priority0_i;
   
   assign rst_dly1_nxt = 1'b1;
   assign rst_dly2_nxt = rst_dly1;
   
   assign set_priority_on_rst = (rst_dly1 & ~rst_dly2);


   // ------------------------------
   //   Aging counter
   // ------------------------------
   // 2 lsbs are h/wired to 00
   // Hold the aging ctr at high priority when urgent bit is set
   //     this has no effect down the pipeline if there is no req active
   //     but allows a master to preset the priority ahead of outgoing reqs
   // If aging_cnt reaches '0', stay there until granted (high priority)
   always @(*) begin: aging_cnt_COMB_PROC
      aging_cnt_nxt = aging_cnt;
      if (~hif_cmd_stall) begin
         if (set_priority_on_rst)   //FIXME_GG: Find a way to update it without reset or document the current behaviour in databook
           aging_cnt_nxt = {reg_port_priority[REG_PORT_PRIORITYW-1:2],2'b00};
         else if (vpt_expired)
           aging_cnt_nxt = {REG_PORT_PRIORITYW{1'b0}};
         else if (urgent && reg_urgent_en)
           aging_cnt_nxt = {REG_PORT_PRIORITYW{1'b0}};
         else if (~reg_aging_en)
           aging_cnt_nxt = {{(REG_PORT_PRIORITYW-3){1'b0}},3'b100};              
         else if (grant_nxt)
           aging_cnt_nxt = {reg_port_priority[REG_PORT_PRIORITYW-1:2],2'b00};
         else if (req)
           if (~priority0_i) begin
              aging_cnt_nxt = aging_cnt - 1'b1;
           end
      end
   end
   
   generate
      if ((EXT_PORTPRIO == 1)) begin: GEN_external_port_prio
         // For multiple-ports: HW parameter selects the port priorities
         assign port_priority = {{(PORT_PRIORITYW-QOSW){1'b0}},qos[QOSW-1:0]};
      end else begin: GEN_internal_port_prio
         // For single port, port priorities are determined by the aging counter
         // and external qos signals determine HPR/LPR
         assign port_priority = aging_cnt[REG_PORT_PRIORITYW-1 -: PORT_PRIORITYW];
      end
   endgenerate
   
endmodule // DWC_ddr_umctl2_pa_port
