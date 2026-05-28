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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_ws_wrapper.sv#1 $
// -------------------------------------------------------------------------
// Description:
//        uMCTL XPI wrap split module wrapper
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_ws_wrapper
#(
   //---------------------------------------------------------------------------
   // Parameters
   //---------------------------------------------------------------------------
   parameter OCCAP_EN                  = 0,
   parameter CMP_REG                   = 0,
   parameter WR                        = 1,                   // XPI Write address path    
   parameter AXI_ADDRW                 = 32,                  // AXI address width
   parameter M_DW                      = 32,                  // SDRAM data width
   parameter NAB                       = 2,
   parameter PDBW_CASE                 = 0,
   parameter XPI_BRW                   = 3,
   parameter MEMC_BURST_LENGTH         = 8,
   parameter AXI_USERW                 = 1,
   parameter AXI_LENW                  = 6,                   // AXI a*len width
   parameter AXI_SIZEW                 = 3,                   // AXI a*size width
   parameter AXI_STRBW                 = 3,                   // AXI a*size width   
   parameter AXI_MAXSIZE               = 2,
   parameter AXI_IDW                   = 8,
   parameter AXI_QOSW                  = 2,
   parameter AXI_LOCKW                 = 2, 
   parameter ORDER_TOKENW              = 8,
   parameter UP_SIZE                   = 0,
   parameter DOWN_SIZE                 = 0,
   parameter DUAL_CHANNEL_INTERLEAVE   = 0
)

                                    (

   //---------------------------------------------------------------------------
   // Interface Pins
   //---------------------------------------------------------------------------
 
   input                               clk,          // clock
   input                               rst_n,        // asynchronous reset
   input [XPI_BRW-1:0]                 reg_burst_rdwr,
   input [1:0]                         reg_ddrc_data_bus_width,
 
   // interface to AXI write/read  address channel
   input [AXI_ADDRW-1:0]               addr,          // AXI address
   input [AXI_LENW-1:0]                alen,          // AXI burst length
   input [AXI_SIZEW-1:0]               asize,         // AXI burst size
   input                               awrap,         // AXI burst type
   input [AXI_LOCKW-1:0]               alock,         // AXI Lock
   input                               wr,            // AXI address valid
   input [AXI_IDW-1:0]                 id,
   input [AXI_USERW-1:0]               user,
   input [AXI_QOSW-1:0]                qos,
   input                               poison,
   input                               ocpar_err,
   input [ORDER_TOKENW-1:0]            token,
   input                               autopre, // AXI auto precharge
   
   output                              full,          // AXI address ready
   
   output [AXI_ADDRW-1:0]              ws_addr,       // AXI first INCR burst address
   output [AXI_LENW-1:0]               ws_alen,        // AXI first INCR burst length
   output [AXI_IDW-1:0]                ws_id,
   output [AXI_USERW-1:0]              ws_user,
   output [AXI_QOSW-1:0]               ws_qos,
   output                              ws_poison,
   output                              ws_ocpar_err,
   output [ORDER_TOKENW-1:0]           ws_token,   
   output [AXI_SIZEW-1:0]              ws_asize,
   output [AXI_LOCKW-1:0]              ws_lock,       // Lock
   output                              ws_autopre,    // AXI auto precharge
   output                              split,         // Single burst
   output                              skip,          // extra INCR burst
   output                              hold_first_beat, // first and last AXI beats are both in the first HIF beat (only for short_wrap in case of UP_SIZE)   
   output                              short_burst,
   output [AXI_ADDRW-1:0]              ws_next_addr_wrap_autopre, // Wrapping boundary address for autopre
   output [AXI_LENW-1:0]               ws_next_alen_wrap_autopre, // Length for autopre with wrap burst
  
   output                              empty,         // ENIF address valid
   input                               rd,            // ENIF address ready

   // occap specific input/output
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                               ws_cmp_en,
   input                               ws_cmp_poison,
   input                               ws_cmp_poison_full,
   input                               ws_cmp_poison_err_inj,
//spyglass enable_block W240
   output                              ws_cmp_error,
   output                              ws_cmp_error_full,
   output                              ws_cmp_error_seq,
   output                              ws_cmp_poison_complete
);


  //---------------------------------------------------------------------------
  // Local Parameters 
  //---------------------------------------------------------------------------

   localparam NUM_INST = OCCAP_EN==1 ? 2 : 1;

   localparam NUM_OUTS  = 19; // WARNING: update whenever a new output is added to xpi_ws
   localparam PW        = 32;
   // assign outputs width to internal parameters, update if outputs/parameters are changed
   localparam OUT0_W    = 1; // full
   localparam OUT1_W    = AXI_ADDRW; // ws_addr
   localparam OUT2_W    = AXI_LENW; // ws_alen
   localparam OUT3_W    = AXI_IDW; // ws_id
   localparam OUT4_W    = AXI_QOSW; // ws_qos
   localparam OUT5_W    = 1; // ws_poison
   localparam OUT6_W    = 1; // ws_ocpar_err
   localparam OUT7_W    = ORDER_TOKENW; // ws_token
   localparam OUT8_W    = AXI_SIZEW; // ws_asize
   localparam OUT9_W    = AXI_LOCKW; // ws_lock
   localparam OUT10_W   = 1; // split
   localparam OUT11_W   = 1; // skip
   localparam OUT12_W   = 1; // short_burst
   localparam OUT13_W   = 1; // hold_first_beat
   localparam OUT14_W   = 1; // empty
   localparam OUT15_W   = AXI_USERW; // user
   localparam OUT16_W   = 1; // auto precharge
   localparam OUT17_W    = AXI_ADDRW; // next_addr_wrap_autopre 
   localparam OUT18_W    = AXI_LENW; // next_alen_wrap_autopre

   localparam OUT0_OFF = OUT0_W;
   localparam OUT1_OFF = OUT0_OFF + OUT1_W;
   localparam OUT2_OFF = OUT1_OFF + OUT2_W;
   localparam OUT3_OFF = OUT2_OFF + OUT3_W;
   localparam OUT4_OFF = OUT3_OFF + OUT4_W;
   localparam OUT5_OFF = OUT4_OFF + OUT5_W;
   localparam OUT6_OFF = OUT5_OFF + OUT6_W;
   localparam OUT7_OFF = OUT6_OFF + OUT7_W;
   localparam OUT8_OFF = OUT7_OFF + OUT8_W;
   localparam OUT9_OFF = OUT8_OFF + OUT9_W;
   localparam OUT10_OFF = OUT9_OFF + OUT10_W;
   localparam OUT11_OFF = OUT10_OFF + OUT11_W;
   localparam OUT12_OFF = OUT11_OFF + OUT12_W;
   localparam OUT13_OFF = OUT12_OFF + OUT13_W;
   localparam OUT14_OFF = OUT13_OFF + OUT14_W;
   localparam OUT15_OFF = OUT14_OFF + OUT15_W;
   localparam OUT16_OFF = OUT15_OFF + OUT16_W;
   localparam OUT17_OFF = OUT16_OFF + OUT17_W;
   localparam OUT18_OFF = OUT17_OFF + OUT18_W;

   localparam OUT_TOTW = OUT18_OFF;

   localparam [NUM_OUTS*PW-1:0] WIDTH_OFFSET = (OUT18_OFF<<18*PW)+
                                              (OUT17_OFF<<17*PW)+
                                              (OUT16_OFF<<16*PW)+
                                              (OUT15_OFF<<15*PW)+
                                              (OUT14_OFF<<14*PW)+
                                              (OUT13_OFF<<13*PW)+
                                              (OUT12_OFF<<12*PW)+
                                              (OUT11_OFF<<11*PW)+
                                              (OUT10_OFF<<10*PW)+
                                              (OUT9_OFF<<9*PW)+
                                              (OUT8_OFF<<8*PW)+
                                              (OUT7_OFF<<7*PW)+
                                              (OUT6_OFF<<6*PW)+
                                              (OUT5_OFF<<5*PW)+
                                              (OUT4_OFF<<4*PW)+
                                              (OUT3_OFF<<3*PW)+
                                              (OUT2_OFF<<2*PW)+
                                              (OUT1_OFF<<1*PW)+
                                              OUT0_OFF;

    localparam [NUM_OUTS*PW-1:0] WIDTH_ARRAY = (OUT18_W<<18*PW)+
                                              (OUT17_W<<17*PW)+
                                              (OUT16_W<<16*PW)+
                                              (OUT15_W<<15*PW)+
                                              (OUT14_W<<14*PW)+
                                              (OUT13_W<<13*PW)+
                                              (OUT12_W<<12*PW)+
                                              (OUT11_W<<11*PW)+
                                              (OUT10_W<<10*PW)+
                                              (OUT9_W<<9*PW)+
                                              (OUT8_W<<8*PW)+
                                              (OUT7_W<<7*PW)+
                                              (OUT6_W<<6*PW)+
                                              (OUT5_W<<5*PW)+
                                              (OUT4_W<<4*PW)+
                                              (OUT3_W<<3*PW)+
                                              (OUT2_W<<2*PW)+
                                              (OUT1_W<<1*PW)+
                                              OUT0_W;

   //---------------------------------------------------------------------------
   // Internal Signals
   //---------------------------------------------------------------------------


   genvar n;

   wire                              full_w [NUM_INST-1:0];
   wire [AXI_ADDRW-1:0]              ws_addr_w [NUM_INST-1:0];
   wire [AXI_LENW-1:0]               ws_alen_w [NUM_INST-1:0];
   wire [AXI_IDW-1:0]                ws_id_w [NUM_INST-1:0];
   wire [AXI_USERW-1:0]              ws_user_w [NUM_INST-1:0];
   wire [AXI_QOSW-1:0]               ws_qos_w [NUM_INST-1:0];
   wire                              ws_poison_w [NUM_INST-1:0];
   wire                              ws_ocpar_err_w [NUM_INST-1:0];
   wire [ORDER_TOKENW-1:0]           ws_token_w [NUM_INST-1:0];   
   wire [AXI_SIZEW-1:0]              ws_asize_w [NUM_INST-1:0];
   wire [AXI_LOCKW-1:0]              ws_lock_w [NUM_INST-1:0];
   wire                              ws_autopre_w [NUM_INST-1:0];
   wire                              split_w [NUM_INST-1:0];
   wire                              skip_w [NUM_INST-1:0];
   wire                              hold_first_beat_w [NUM_INST-1:0];
   wire                              short_burst_w [NUM_INST-1:0];
   wire                              empty_w [NUM_INST-1:0];
   wire [AXI_ADDRW-1:0]              ws_next_addr_wrap_autopre_w [NUM_INST-1:0];
   wire [AXI_LENW-1:0]               ws_next_alen_wrap_autopre_w [NUM_INST-1:0];

   assign empty            = empty_w[0];
   assign hold_first_beat  = hold_first_beat_w[0];
   assign short_burst      = short_burst_w[0];
   assign skip             = skip_w[0];
   assign split            = split_w[0];
   assign ws_lock          = ws_lock_w[0];
   assign ws_asize         = ws_asize_w[0]; 
   assign ws_token         = ws_token_w[0];
   assign ws_ocpar_err     = ws_ocpar_err_w[0];
   assign ws_poison        = ws_poison_w[0];
   assign ws_qos           = ws_qos_w[0];
   assign ws_id            = ws_id_w[0];
   assign ws_alen          = ws_alen_w[0];
   assign ws_addr          = ws_addr_w[0];
   assign full             = full_w[0];
   assign ws_user          = ws_user_w[0];
   assign ws_autopre       = ws_autopre_w[0];
   assign ws_next_addr_wrap_autopre = ws_next_addr_wrap_autopre_w[0];
   assign ws_next_alen_wrap_autopre = ws_next_alen_wrap_autopre_w[0];

   //---------------------------------------------------------------------------
   // WS instance
   //---------------------------------------------------------------------------

   generate
      for (n=0; n<NUM_INST; n=n+1) begin: WS_inst
  
         DWC_ddr_umctl2_xpi_ws
         
         #(
            .WR                        (WR),
            .AXI_ADDRW                 (AXI_ADDRW),
            .M_DW                      (M_DW),      
            .NAB                       (NAB),
            .PDBW_CASE                 (PDBW_CASE),
            .XPI_BRW                   (XPI_BRW),
            .MEMC_BURST_LENGTH         (MEMC_BURST_LENGTH),
            .AXI_USERW                 (AXI_USERW),
            .AXI_LENW                  (AXI_LENW),
            .AXI_SIZEW                 (AXI_SIZEW),
            .AXI_STRBW                 (AXI_STRBW),      
            .AXI_MAXSIZE               (AXI_MAXSIZE),
            .AXI_IDW                   (AXI_IDW),
            .AXI_QOSW                  (AXI_QOSW),
            .AXI_LOCKW                 (AXI_LOCKW),
            .ORDER_TOKENW              (ORDER_TOKENW),
            .UP_SIZE                   (UP_SIZE),
            .DOWN_SIZE                 (DOWN_SIZE),
            .DUAL_CHANNEL_INTERLEAVE   (DUAL_CHANNEL_INTERLEAVE))
         U_ws
         (
         // Outputs
         .full                               (full_w[n]),
         .ws_addr                            (ws_addr_w[n]),
         .ws_alen                            (ws_alen_w[n]),
         .ws_id                              (ws_id_w[n]), 
         .ws_user                            (ws_user_w[n]),
         .ws_qos                             (ws_qos_w[n]), 
         .ws_poison                          (ws_poison_w[n]),
         .ws_ocpar_err                       (ws_ocpar_err_w[n]),
         .ws_token                           (ws_token_w[n]),
         .ws_autopre                         (ws_autopre_w[n]),
         .ws_asize                           (ws_asize_w[n]),
         .ws_lock                            (ws_lock_w[n]),
         .split                              (split_w[n]),
         .skip                               (skip_w[n]),
         .short_burst                        (short_burst_w[n]),
         .hold_first_beat                    (hold_first_beat_w[n]),     
         .empty                              (empty_w[n]),
         .ws_next_addr_wrap_autopre          (ws_next_addr_wrap_autopre_w[n]), 
         .ws_next_alen_wrap_autopre          (ws_next_alen_wrap_autopre_w[n]),
         // Inputs
         .clk                                (clk),
         .rst_n                              (rst_n),
         .reg_burst_rdwr                     (reg_burst_rdwr),
         .reg_ddrc_data_bus_width            (reg_ddrc_data_bus_width),
         .addr                               (addr),
         .alen                               (alen),
         .asize                              (asize),
         .alock                              (alock),
         .id                                 (id), 
         .user                               (user),
         .qos                                (qos), 
         .poison                             (poison),
         .ocpar_err                          (ocpar_err),
         .token                              (token),
         .awrap                              (awrap),
         .autopre                            (autopre),
         .wr                                 (wr),
         .rd                                 (rd));

      end // WS_inst

      if (OCCAP_EN==1) begin: CMP_en

         wire [OUT_TOTW-1:0] cmp_in0, cmp_in1;

         assign cmp_in0 = {ws_user,
                           empty,
                           hold_first_beat,
                           short_burst,
                           skip,
                           split,
                           ws_lock,
                           ws_asize,
                           ws_token,
                           ws_ocpar_err,
                           ws_poison,
                           ws_autopre,
                           ws_qos,
                           ws_id,
                           ws_alen,
                           ws_addr,
                           full,
                           ws_next_addr_wrap_autopre,
                           ws_next_alen_wrap_autopre};

         assign cmp_in1 = {ws_user_w[NUM_INST-1],
                           empty_w[NUM_INST-1],
                           hold_first_beat_w[NUM_INST-1],
                           short_burst_w[NUM_INST-1],
                           skip_w[NUM_INST-1],
                           split_w[NUM_INST-1],
                           ws_lock_w[NUM_INST-1],
                           ws_asize_w[NUM_INST-1],
                           ws_token_w[NUM_INST-1],
                           ws_ocpar_err_w[NUM_INST-1],
                           ws_poison_w[NUM_INST-1],
                           ws_autopre_w[NUM_INST-1],
                           ws_qos_w[NUM_INST-1],
                           ws_id_w[NUM_INST-1],
                           ws_alen_w[NUM_INST-1],
                           ws_addr_w[NUM_INST-1],
                           full_w[NUM_INST-1],
                           ws_next_addr_wrap_autopre_w[NUM_INST-1],
                           ws_next_alen_wrap_autopre_w[NUM_INST-1]};
      

         occap_cmp
         
         #(
            .CMP_REG       (CMP_REG),
            .NUM_INS       (NUM_OUTS),
            .IN_WIDTH      (OUT_TOTW),
            .PW            (PW),
            .WIDTH_OFFSET  (WIDTH_OFFSET),
            .WIDTH_ARRAY   (WIDTH_ARRAY),
            .SVA_X_Z_CHECK_EN (1) // enable check on X/Z            
         )
         ws_cmp
         (
            .clk                 (clk),
            .rst_n               (rst_n),
            .in0                 (cmp_in0),
            .in1                 (cmp_in1),
            .cmp_en              (ws_cmp_en),
            .cmp_poison          (ws_cmp_poison),
            .cmp_poison_full     (ws_cmp_poison_full),
            .cmp_poison_err_inj  (ws_cmp_poison_err_inj),
            .cmp_err             (ws_cmp_error),
            .cmp_err_full        (ws_cmp_error_full),
            .cmp_err_seq         (ws_cmp_error_seq),
            .cmp_poison_complete (ws_cmp_poison_complete)
         );
   
      end // CMP_en
      else begin: OCCAP_dis

         assign ws_cmp_error           = 1'b0;
         assign ws_cmp_error_full      = 1'b0;
         assign ws_cmp_error_seq       = 1'b0;
         assign ws_cmp_poison_complete = 1'b0;

      end // OCCAP_dis
   endgenerate

endmodule // DWC_ddr_umctl2_xpi_ws_wrapper
