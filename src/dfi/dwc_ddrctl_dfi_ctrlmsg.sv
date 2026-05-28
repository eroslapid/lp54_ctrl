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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/dwc_ddrctl_dfi_ctrlmsg.sv#1 $
// -------------------------------------------------------------------------
// Description:
// This block implements the handshake for DFI controller message interface. 
// It generates the dfi_ctrlmsg_req based on register write 
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module dwc_ddrctl_dfi_ctrlmsg 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS ---------------------------------- 
) (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input logic                                  core_ddrc_core_clk                  // 
    ,input logic                                  core_ddrc_rstn                      //
  //--------------------------- REGISTER I/F----- -------------------------------
    ,input logic  [DFI_T_CTRLMSG_RESP_WIDTH-1:0]  reg_ddrc_dfi_t_ctrlmsg_resp  
    ,input logic                                  reg_ddrc_dfi_ctrlmsg_req
    ,input logic                                  reg_ddrc_dfi_ctrlmsg_tout_clr
    ,input logic [DFI_CTRLMSG_CMD_WIDTH-1:0]      reg_ddrc_dfi_ctrlmsg_cmd
    ,input logic [DFI_CTRLMSG_DATA_WIDTH-1:0]     reg_ddrc_dfi_ctrlmsg_data
    ,output logic                                 ddrc_reg_dfi_ctrlmsg_resp_tout
    ,output logic                                 ddrc_reg_dfi_ctrlmsg_req_busy
    ,input logic                                  dfi_init_complete
    ,input logic                                  dfi_init_start
    ,input logic                                  block_dfi_ctrlmsg
  //--------------------------- DFI control message I/F----- ----------------------
    ,output logic                                 dfi_ctrlmsg_req
    ,output logic [7:0]                           dfi_ctrlmsg 
    ,output logic [15:0]                          dfi_ctrlmsg_data
    ,input  logic                                 dfi_ctrlmsg_ack

);
  localparam HIGH = 1'b1;

   logic dfi_ctrlmsg_ack_ne; //negative edge for dfi_ctrlmsg_ack 
   logic dfi_ctrlmsg_ack_d1; //delayed version of dfi_ctrlmsg_ack
   logic dfi_ctrlmsg_resp_tout; //dfi control message response timeout 
   logic gen_dfi_ctrlmsg_req;
   logic [$bits(reg_ddrc_dfi_t_ctrlmsg_resp)-1:0]  dfi_ctrlmsg_resp_tout_cnt; //dfi control message response timeout count
   logic block_dfi_ctrlmsg_n;
  
   //dfi_ctrlmsg_ack not arrived within reg_ddrc_dfi_t_ctrlmsg_resp 
   //ccx_cond: ; ;110; when timeout is trigerred dfi_ctrlmsg_ack is not asserted by PHY
   assign dfi_ctrlmsg_resp_tout = (!(|dfi_ctrlmsg_resp_tout_cnt)) && dfi_ctrlmsg_req && (!dfi_ctrlmsg_ack);
   assign dfi_ctrlmsg_ack_ne = dfi_ctrlmsg_ack_d1 & (!dfi_ctrlmsg_ack);
   //assign ddrc_reg_dfi_ctrlmsg_req_busy = dfi_ctrlmsg_req;
   assign block_dfi_ctrlmsg_n = ~block_dfi_ctrlmsg;
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// Assert ddrc_reg_dfi_ctrlmsg_req_busy when there is a sw register write to DFIxMSGCTL0 register
// Deassert on control message response timeout or negative edge of dfi_ctrlmsg_ack 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin : ddrc_reg_dfi_ctrlmsg_req_busy_PROC
       if (!core_ddrc_rstn) begin
          ddrc_reg_dfi_ctrlmsg_req_busy   <= 1'b0;
       end else begin
          if (reg_ddrc_dfi_ctrlmsg_req)
             ddrc_reg_dfi_ctrlmsg_req_busy <= 1'b1;
          else if (dfi_ctrlmsg_ack_ne || dfi_ctrlmsg_resp_tout)
             ddrc_reg_dfi_ctrlmsg_req_busy <= 1'b0;
       end
    end

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// Assert dfi_ctrlmsg_req when there is a sw register write to DFIxMSGCTL0 register
// Deassert on control message response timeout or negative edge of dfi_ctrlmsg_ack 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin : gen_dfi_ctrlmsg_req_PROC
       if (!core_ddrc_rstn) begin
          gen_dfi_ctrlmsg_req   <= 1'b0;
       end else begin
          if (reg_ddrc_dfi_ctrlmsg_req)
             gen_dfi_ctrlmsg_req <= 1'b1;
          else if (block_dfi_ctrlmsg_n)
             gen_dfi_ctrlmsg_req <= 1'b0;
       end
    end

    always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin : dfi_ctrlmsg_req_PROC
       if (!core_ddrc_rstn) begin
          dfi_ctrlmsg_req   <= 1'b0;
       end else begin
          if (gen_dfi_ctrlmsg_req && (block_dfi_ctrlmsg_n))
             dfi_ctrlmsg_req <= 1'b1;
          else if (dfi_ctrlmsg_ack_ne || dfi_ctrlmsg_resp_tout) 
             dfi_ctrlmsg_req <= 1'b0;
       end
    end
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// DFI control message response timeout counter
// Loaded with reg_ddrc_dfi_t_ctrlmsg_resp when there is a sw register write to DFIxMSGCTL0 register 
// Decremented when the counter is non zero and there is no ack for dfi_ctrlmsg_req
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin : dfi_ctrlmsg_resp_tout_cnt_PROC
       if (!core_ddrc_rstn) begin
          dfi_ctrlmsg_resp_tout_cnt   <= {$bits(dfi_ctrlmsg_resp_tout_cnt){1'b0}};
       end else begin
          if (gen_dfi_ctrlmsg_req && (block_dfi_ctrlmsg_n))
             dfi_ctrlmsg_resp_tout_cnt <= reg_ddrc_dfi_t_ctrlmsg_resp 
;
//ccx_cond: ; ;1101+1110; DFI controller message request will be triggered only after DFI initialization is complete for a config without HWFFC support 
          else if ((|dfi_ctrlmsg_resp_tout_cnt) && (!dfi_ctrlmsg_ack) && (dfi_init_complete && (!dfi_init_start)))
//spyglass disable_block W164a
//SMD: LHS:'dfi_ctrlmsg_resp_tout_cnt' width 8 is less than RHS:'(dfi_ctrlmsg_resp_tout_cnt - {{($bits(dfi_ctrlmsg_resp_tout_cnt)-1){1'b0}},HIGH}' width 9
//SJ: The counter will stop decrementing at 0 and there will not be any overflow
             dfi_ctrlmsg_resp_tout_cnt <= dfi_ctrlmsg_resp_tout_cnt - {{($bits(dfi_ctrlmsg_resp_tout_cnt)-1){1'b0}},HIGH};
//spyglass enable_block W164a
       end
    end
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Registering flops
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin : dfi_ctrlmsg_REG_PROC
       if (!core_ddrc_rstn) begin
          dfi_ctrlmsg         <= {$bits(dfi_ctrlmsg){1'b0}};
          dfi_ctrlmsg_data    <= {$bits(dfi_ctrlmsg_data){1'b0}};
          dfi_ctrlmsg_ack_d1 <= 1'b0;
       end else begin
          dfi_ctrlmsg          <= reg_ddrc_dfi_ctrlmsg_cmd[7:0];
          dfi_ctrlmsg_data     <= reg_ddrc_dfi_ctrlmsg_data[15:0];
          dfi_ctrlmsg_ack_d1  <= dfi_ctrlmsg_ack;
       end
    end
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// DFI controller message response timeout
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge core_ddrc_core_clk, negedge core_ddrc_rstn) begin : ddrc_reg_dfi_ctrlmsg_resp_tout_PROC
       if (!core_ddrc_rstn) begin
          ddrc_reg_dfi_ctrlmsg_resp_tout   <= 1'b0;
       end else begin
          if (dfi_ctrlmsg_resp_tout)
             ddrc_reg_dfi_ctrlmsg_resp_tout <= 1'b1;
          else if (reg_ddrc_dfi_ctrlmsg_tout_clr)  
             ddrc_reg_dfi_ctrlmsg_resp_tout <= 1'b0;
       end
    end    

endmodule //dwc_ddrtcl_dfi_ctrlmsg
