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

// Revision $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/apb/DWC_ddrctl_apb_slvfsm.sv#1 $
`include "DWC_ddrctl_all_defs.svh"

`include "apb/DWC_ddrctl_reg_pkg.svh"

module DWC_ddrctl_apb_slvfsm
import DWC_ddrctl_reg_pkg::*;
  #(parameter N_APBFSMSTAT =
                            8
    )
  (input                     pclk,
   input                     presetn,
   input                     psel,
   input                     penable,
   input                     pwrite,
   input                     set_async_reg,
   input                     ack_async_reg,
   output [N_APBFSMSTAT-1:0] apb_slv_cs,
   output [N_APBFSMSTAT-1:0] apb_slv_ns,
   output reg                pready,
   output                    write_en,
   output                    write_en_pulse,
   output reg                write_en_s0,
   output                    fwd_reset_val,
   output reg                store_rqst
   );

   localparam IDLE       = 8'b00000001;
   localparam ADDRDECODE = 8'b00000010;
   localparam DATALATCH  = 8'b00000100;
   localparam SAMPLERDY  = 8'b00001000;
   localparam WAITACK    = 8'b00010000;
   localparam PWRUP      = 8'b00100000;
   localparam CDCDLY     = 8'b01000000;
   localparam FIXDLY     = 8'b10000000;

   reg [N_APBFSMSTAT-1:0]    current_state;
   reg [N_APBFSMSTAT-1:0]    next_state;
   reg                       pready_i;

   localparam TIMEOUTW = 7;
   localparam FIXCNTW = 2;
      
   assign apb_slv_ns = next_state;
   assign apb_slv_cs = current_state;

   assign write_en = psel & penable & pwrite;
   assign write_en_pulse = (apb_slv_ns==ADDRDECODE) ? write_en : 1'b0;


   assign fwd_reset_val = (apb_slv_cs==PWRUP) ? 1'b1 : 1'b0;
   wire [TIMEOUTW-1:0]       timeout;
   wire [TIMEOUTW-1:0]       cdctimeout;
   wire [FIXCNTW-1:0]        maxfixcnt;
   reg [TIMEOUTW-1:0]        cnt;
   reg [TIMEOUTW-1:0]        cdccnt;
   reg [FIXCNTW-1:0]         fixcnt; // wait for all acks to stabilize
   wire                      rst_timeout;
   wire                      inc_timeout;
   wire                      rst_cdctimeout;
   wire                      inc_cdctimeout;
   wire                      rst_fixcnt;
   wire                      inc_fixcnt;
   wire                      timer_expired;
   wire                      cdc_timer_expired;
   wire                      fixcnt_expired;
   assign timeout = {TIMEOUTW{1'b1}};
   assign cdctimeout = {TIMEOUTW{1'b1}};
   assign maxfixcnt = {FIXCNTW{1'b1}};
   //ccx_cond: ;2;01;cnt is incremented only when the STATE is WAITACK, so cnt >= timeout is not possible when STATE is not WAITACK
   assign rst_timeout = (((current_state==WAITACK) && (cnt >= timeout)) || (current_state==IDLE))? 1'b1: 1'b0;
   assign inc_timeout = (current_state==WAITACK) && (cnt < timeout)? 1'b1 : 1'b0;
   assign timer_expired = (cnt >= timeout)? 1'b1 : 1'b0;

   assign rst_cdctimeout = (current_state!=CDCDLY) ? 1'b1: 1'b0;
   //ccx_cond: ; ;0; cdccnt greater than cdctimeout cannot be triggered in normal operation
   assign inc_cdctimeout = (cdccnt < cdctimeout) ? 1'b1 : 1'b0;
   //ccx_cond: ; ;1; cdccnt greater or eqaul than cdctimeout cannot be triggered in normal operation
   assign cdc_timer_expired = (cdccnt >= cdctimeout)? 1'b1 : 1'b0;

   assign fixcnt_expired = (fixcnt >= maxfixcnt)? 1'b1 : 1'b0;
   assign rst_fixcnt = (current_state==CDCDLY) ? 1'b1: 1'b0;
   assign inc_fixcnt = (fixcnt < maxfixcnt)? 1'b1 : 1'b0;

   always @ (posedge pclk or negedge presetn) begin : sample_pclk_cnt_PROC
      if (~presetn) begin
         cnt <= {TIMEOUTW{1'b0}};
         cdccnt <= {TIMEOUTW{1'b0}};
         fixcnt <= {FIXCNTW{1'b0}};
      end else begin
         if(rst_timeout) begin
            cnt <= {TIMEOUTW{1'b0}};
         end else if(inc_timeout) begin
            cnt <= cnt + {{(TIMEOUTW-1){1'b0}},1'b1};    
         end
         if(rst_cdctimeout) begin
            cdccnt <= {TIMEOUTW{1'b0}};
         end else if(inc_cdctimeout) begin
            cdccnt <= cdccnt + {{(TIMEOUTW-1){1'b0}},1'b1};    
         end
         if(rst_fixcnt) begin
            fixcnt <= {FIXCNTW{1'b0}};
         end else if(inc_fixcnt) begin
            fixcnt <= fixcnt + {{(FIXCNTW-1){1'b0}},1'b1};    
         end  
      end
   end 

   always @ (posedge pclk or negedge presetn) begin : sample_pclk_state_PROC
      if (~presetn) begin
         current_state <= 
                          PWRUP;
         pready        <= 1'b0;
         write_en_s0   <= 1'b0;
      end else begin
         current_state <= next_state;
         pready        <= pready_i;
         write_en_s0   <= write_en_pulse;
      end
   end

   always @ (*) begin : next_fsm_combo_PROC
      store_rqst=1'b0;
      pready_i = 1'b0;
      case (current_state)
        PWRUP  : next_state = CDCDLY;
        CDCDLY : begin
           casez ({ack_async_reg,cdc_timer_expired})
             2'b1?   : next_state = FIXDLY ; // when any CDC acknowledges or timer expires 
             2'b01   : next_state = IDLE ;   // when timer expires before any CDC acknowledge pulse is received
             default : next_state = CDCDLY;
           endcase
        end
        FIXDLY : next_state = fixcnt_expired ? IDLE : FIXDLY;
        IDLE: begin
           if (psel & penable) begin
              next_state = ADDRDECODE;
           end else begin
              next_state = IDLE;
           end
        end        
        ADDRDECODE: begin
           if(pwrite) begin
              if(set_async_reg) begin                
                 store_rqst = 1'b1;
                 next_state = WAITACK;
              end else begin
                 store_rqst = 1'b1;
                 next_state = SAMPLERDY;
                 pready_i   = 1'b1;
              end
           end else begin
              next_state = DATALATCH;
           end
        end 
        WAITACK   : begin
           if(ack_async_reg | timer_expired) begin
              pready_i   = 1'b1;
              next_state = SAMPLERDY;
           end else begin
              next_state = WAITACK;
           end
        end
        DATALATCH : begin
           pready_i   = 1'b1;
           next_state = SAMPLERDY;
        end
        default   : next_state = IDLE;
      endcase
   end

endmodule
