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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_rp_wrapper.sv#1 $
// -------------------------------------------------------------------------
// Description:
//          uMCTL XPI Read Packetizer module wrapper
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_rp_wrapper
import DWC_ddrctl_reg_pkg::*;
  #(  
   //---------------------------------------------------------------------------
   // Parameters
   //---------------------------------------------------------------------------
      parameter OCCAP_EN                  = 0,
      parameter CMP_REG                   = 0,
      parameter M_DW                      = 32,
      parameter M_ADDRW                   = 32,
      parameter NAB                       = 2,
      parameter PDBW_CASE                 = 0,  // Programmable DRAM data width cases - Case1:1 ... Case5:5 
      parameter MEMC_BURST_LENGTH         = 8,
      parameter NTOKENS                   = 32,
      parameter NTOKENS_LG2               = `UMCTL_LOG2(NTOKENS),
      parameter NBEATS                    = 2,
      parameter NBEATS_LG2                = 1,
      parameter BEAT_INFOW                = 4,      
      parameter XPI_BRW                   = 3,  
      parameter AXI_ADDRW                 = 32,
      parameter AXI_MAXSIZE               = 2,
      parameter ACC_INFOW                 = 2,
      parameter ENIF_LENW                 = 6,
      parameter ENIF_SIZEW                = 3,
      parameter ENIF_LOCKW                = 2,
      parameter ENIF_STRBW                = 2,   
      parameter ENIF_MAXSIZE              = 1,
      parameter ENIF_HSIZEW               = 3,
      parameter ENIF_HMAXSIZE             = 1,
      parameter MAXSIZE                   = 2,
      parameter RPINFOW                   = 4,
      parameter UP_SIZE                   = 0,
      parameter DOWN_SIZE                 = 0,   
      parameter AXI_ADDR_BOUNDARY         = 12,
      parameter DUAL_CHANNEL_INTERLEAVE   = 0,
      parameter DDRCTL_HET_INTERLEAVE     = 0,
      parameter DDRCTL_LUT_ADDRMAP_EN     = 0,
      parameter INTLVMODEW                = 2,
      parameter RRB_THRESHOLD_EN              = 0,
      parameter RRB_LOCK_THRESHOLD_WIDTH  = 0,
      // Exclusive Access 
      parameter EXA_ACC_SUPPORT           = 0,
      parameter EXA_PYLD_W                = 2, 
      parameter EXA_MAX_LENW              = 12,
      parameter EXA_MAX_SIZEW             = 3,
      parameter EXA_MAX_ADDRW             = 12,
      parameter AXI_LENW                  = 6,
      parameter AXI_SIZEW                 = 2,
      parameter AXI_MAXSIZE_EXA           = 1
      )
  
                                    (
   
   //---------------------------------------------------------------------------
   // Interface Pins
   //---------------------------------------------------------------------------
   
   input                                clk,           // clock
   input                                rst_n,         // asynchronous reset
   
   input                                siu_bl16,
   input                                siu_bl8,
   input                                siu_bl4, 
   input [XPI_BRW-1:0]                  reg_burst_rdwr,
   input [1:0]                          reg_ddrc_data_bus_width, //MSTR's DRAM bus width setting
   // bankgroup mask
   input [M_ADDRW-1:0]                  bg_or_bank_addrmap_mask,  
   
   // interface with WRAPP SPLIT 
   input [AXI_ADDRW-1:0]                addr,         // AXI first INCR burst address
   input [ENIF_LENW-1:0]                alen,         // AXI first INCR burst length
   input                                split,         // Single INCR burst 
   input                                short_burst,   // Short WRAP burst not crossing one BL
   
   // interface to AXI write/read  address channel interleave_mode  
   input [ENIF_SIZEW-1:0]               asize,         // AXI burst size
   input [ENIF_LOCKW-1:0]               alock,         // AXI lock
   input                                wr,            // AXI address valid
   output                               full,          // AXI address ready
   input                                autopre,       // AXI auto precharge
   input  [AXI_ADDRW-1:0]               next_addr_wrap_autopre, // For AXI autopre wrap burst
   input  [ENIF_LENW-1:0]                next_alen_wrap_autopre, // For AXI autopre wrap burst
   
   // ENIF Address channel
   output [M_ADDRW-1:0]                 e_addr,
   
   output                               e_alast,       // ENIF address last
   output                               empty,         // ENIF address valid
   input                                rd,            // ENIF address ready
   output                               e_autopre,     // ENIF auto precharege

   output [ACC_INFOW-1:0]               acc_info,
   
   // POST_WAQ IF
   output [RPINFOW-1:0]                 info,      // Post write address queues data
   output                               exa_acc,       // asserted, if exclusive read/write, with the first packet
   output                               exa_acc_lock,  // asserted, if exclusive write, for all packets of an AXI burst
   output                               exa_acc_instr, // asserted, if exclusive read/write, with all the packets
   
   output [EXA_PYLD_W-1:0]              exa_acc_pyld,
   output [BEAT_INFOW-1:0]              beat_info,

   input [RRB_LOCK_THRESHOLD_WIDTH-1:0] reg_arb_rrb_lock_threshold,
   input [1:0]                          reg_arb_dch_density_ratio,
   input [5:0]                          dch_bit,
   input [5:0]                          e_addr_max_loc,
   input [5:0]                          e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]                  e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]                  e_addr_max_m1_loc_addrmap_mask,

   // Use SBAM (Simplified BAM) for RRB enhancement
   output                               sbam_lead_burst,
   output                               sbam_second_burst,
   output [NTOKENS_LG2:0]               sbam_tokens_allocated,

   output                               bam_lead_burst,
   output [AXI_MAXSIZE-1:0]             bam_addr_offset,
   
   // occap specific input/output
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                               rp_cmp_en,
   input                               rp_cmp_poison,
   input                               rp_cmp_poison_full,
   input                               rp_cmp_poison_err_inj,
//spyglass enable_block W240
   output                              rp_cmp_error,
   output                              rp_cmp_error_full,
   output                              rp_cmp_error_seq,
   output                              rp_cmp_poison_complete,

   input [AXI_MAXSIZE_EXA-1:0] exa_addr,
   input [AXI_LENW-1:0]        exa_alen,
   input [AXI_SIZEW-1:0]       exa_asize
   );
   
  //---------------------------------------------------------------------------
  // Local Parameters 
  //---------------------------------------------------------------------------

   localparam NUM_INST = OCCAP_EN==1 ? 2 : 1;
   localparam NUM_OUTS = 21; // WARNING: update whenever a new output is added to xpi_rp .
   localparam PW       = 32;
   // assign outputs width to internal parameters, update if outputs/parameters are changed
   localparam OUT0_W    = 1; // full
   localparam OUT1_W    = M_ADDRW; // e_addr
   localparam OUT2_W    = 1; // e_alast
   localparam OUT3_W    = 1; // empty
   localparam OUT4_W    = RPINFOW; // info
   localparam OUT5_W    = ACC_INFOW; // acc_info
   localparam OUT6_W    = 1; // exa_acc
   localparam OUT7_W    = 1; // exa_acc_instr
   localparam OUT8_W    = EXA_PYLD_W; // exa_acc_pyld
   localparam OUT9_W    = 1; // exa_acc_lock
   localparam OUT10_W   = BEAT_INFOW; // beat_info
   localparam OUT11_W   = 1; // e_autopre
   localparam OUT12_W   = 1; // bam_lead_burst
   localparam OUT13_W   = AXI_MAXSIZE; // bam_addr_offset
   localparam OUT14_W   = 1; // sbam_lead_burst
   localparam OUT15_W   = 1; // sbam_second_burst
   localparam OUT16_W   = NTOKENS_LG2 + 1; // sbam_tokens_allocated
   localparam OUT17_W   = (DDRCTL_LUT_ADDRMAP_EN==1)? M_ADDRW : 1; // e_addr_alt_out
   localparam OUT18_W   = 1; // e_addr_alt_addrmap_sel_out
   localparam OUT19_W   = (DDRCTL_LUT_ADDRMAP_EN==1)? `DDRCTL_LUT_ADDRMAP_CS_WIN_BITS : 1; //lut_sel
   localparam OUT20_W   = (DDRCTL_LUT_ADDRMAP_EN==1)? 2 : 1; //e_cs_out

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
   localparam OUT19_OFF = OUT18_OFF + OUT19_W;
   localparam OUT20_OFF = OUT19_OFF + OUT20_W;
   
   localparam OUT_TOTW = OUT20_OFF;

   localparam [NUM_OUTS*PW-1:0] WIDTH_OFFSET = 
                                              (OUT20_OFF<<20*PW)+
                                              (OUT19_OFF<<19*PW)+
                                              (OUT18_OFF<<18*PW)+
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

    localparam [NUM_OUTS*PW-1:0] WIDTH_ARRAY = 
                                              (OUT20_W<<20*PW)+
                                              (OUT19_W<<19*PW)+
                                              (OUT18_W<<18*PW)+
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

   wire                               full_w [NUM_INST-1:0];
   wire [M_ADDRW-1:0]                 e_addr_w [NUM_INST-1:0];
   wire                               e_alast_w [NUM_INST-1:0];
   wire                               empty_w [NUM_INST-1:0];
   wire                               e_autopre_w [NUM_INST-1:0]; 
   wire [ACC_INFOW-1:0]               acc_info_w [NUM_INST-1:0];
   wire [RPINFOW-1:0]                 info_w [NUM_INST-1:0];
   wire                               exa_acc_w [NUM_INST-1:0];
   wire                               exa_acc_lock_w [NUM_INST-1:0];
   wire                               exa_acc_instr_w [NUM_INST-1:0];
   wire [EXA_PYLD_W-1:0]              exa_acc_pyld_w [NUM_INST-1:0];
   wire [BEAT_INFOW-1:0]              beat_info_w [NUM_INST-1:0];
   wire                               bam_lead_burst_w[NUM_INST-1:0];
   wire [AXI_MAXSIZE-1:0]             bam_addr_offset_w[NUM_INST-1:0];
   wire                               sbam_lead_burst_w[NUM_INST-1:0];
   wire                               sbam_second_burst_w[NUM_INST-1:0];
   wire [NTOKENS_LG2:0]               sbam_tokens_allocated_w[NUM_INST-1:0];

   assign full          = full_w[0];
   assign e_addr        = e_addr_w[0];
   assign e_alast       = e_alast_w[0];
   assign empty         = empty_w[0];
   assign e_autopre     = e_autopre_w[0];
   assign acc_info      = acc_info_w[0];
   assign info          = info_w[0];
   assign exa_acc       = exa_acc_w[0];
   assign exa_acc_lock  = exa_acc_lock_w[0];
   assign exa_acc_instr = exa_acc_instr_w[0];
   assign exa_acc_pyld  = exa_acc_pyld_w[0];
   assign beat_info     = beat_info_w[0];
   assign bam_lead_burst             = bam_lead_burst_w[0];
   assign bam_addr_offset            = bam_addr_offset_w[0];
   assign sbam_lead_burst            = sbam_lead_burst_w[0];
   assign sbam_second_burst          = sbam_second_burst_w[0];
   assign sbam_tokens_allocated      = sbam_tokens_allocated_w[0];

   //---------------------------------------------------------------------------
   // RP instance
   //---------------------------------------------------------------------------

   generate
      for (n=0; n<NUM_INST; n=n+1) begin: RP_inst

         DWC_ddr_umctl2_xpi_rp
         
         #(
            .M_DW                   (M_DW),
            .M_ADDRW                (M_ADDRW),
            .NAB                    (NAB),
            .PDBW_CASE              (PDBW_CASE),
            .MEMC_BURST_LENGTH      (MEMC_BURST_LENGTH),
            .NBEATS                 (NBEATS),
            .NBEATS_LG2             (NBEATS_LG2),
            .NTOKENS                (NTOKENS),
            .NTOKENS_LG2            (NTOKENS_LG2),
            .BEAT_INFOW             (BEAT_INFOW),
            .XPI_BRW                (XPI_BRW),
            .AXI_ADDRW              (AXI_ADDRW),
            .AXI_MAXSIZE            (AXI_MAXSIZE),
            .ACC_INFOW              (ACC_INFOW),
            .ENIF_LENW              (ENIF_LENW),
            .ENIF_SIZEW             (ENIF_SIZEW),
            .ENIF_LOCKW             (ENIF_LOCKW),
            .ENIF_STRBW             (ENIF_STRBW),
            .ENIF_MAXSIZE           (ENIF_MAXSIZE),  
            .ENIF_HSIZEW            (ENIF_HSIZEW),
            .ENIF_HMAXSIZE          (ENIF_HMAXSIZE),
            .MAXSIZE                (MAXSIZE),     
            .RPINFOW                (RPINFOW),      
            .UP_SIZE                (UP_SIZE),
            .DOWN_SIZE              (DOWN_SIZE),     
            .AXI_ADDR_BOUNDARY      (AXI_ADDR_BOUNDARY),
            .DUAL_CHANNEL_INTERLEAVE(DUAL_CHANNEL_INTERLEAVE),
            .DDRCTL_HET_INTERLEAVE  (DDRCTL_HET_INTERLEAVE),
            .RRB_THRESHOLD_EN               (RRB_THRESHOLD_EN),
            .RRB_LOCK_THRESHOLD_WIDTH   (RRB_LOCK_THRESHOLD_WIDTH),
            .DDRCTL_LUT_ADDRMAP_EN  (DDRCTL_LUT_ADDRMAP_EN),
            .INTLVMODEW             (INTLVMODEW),
            .EXA_ACC_SUPPORT        (EXA_ACC_SUPPORT),
            .EXA_PYLD_W             (EXA_PYLD_W),  
            .EXA_MAX_LENW           (EXA_MAX_LENW),
            .EXA_MAX_SIZEW          (EXA_MAX_SIZEW),
            .EXA_MAX_ADDRW          (EXA_MAX_ADDRW),
            .AXI_LENW               (AXI_LENW),
            .AXI_SIZEW              (AXI_SIZEW),
            .AXI_MAXSIZE_EXA        (AXI_MAXSIZE_EXA))
         U_rp
         (
         // Outputs
         .full                               (full_w[n]),
         .e_addr                             (e_addr_w[n]),
         .e_alast                            (e_alast_w[n]),
         .empty                              (empty_w[n]),
         .e_autopre                          (e_autopre_w[n]),
         .info                               (info_w[n]),
         .acc_info                           (acc_info_w[n]),
         .exa_acc                            (exa_acc_w[n]),
         .exa_acc_instr                      (exa_acc_instr_w[n]),
         .exa_acc_pyld                       (exa_acc_pyld_w[n]),
         .exa_acc_lock                       (exa_acc_lock_w[n]),
         .beat_info                          (beat_info_w[n]),
         .bam_lead_burst                     (bam_lead_burst_w[n]),
         .bam_addr_offset                    (bam_addr_offset_w[n]),
         .sbam_lead_burst                    (sbam_lead_burst_w[n]),
         .sbam_second_burst                  (sbam_second_burst_w[n]),
         .sbam_tokens_allocated              (sbam_tokens_allocated_w[n]),
         // Inputs
         .clk                                (clk),
         .rst_n                              (rst_n),
         .siu_bl4                            (siu_bl4),
         .siu_bl8                            (siu_bl8),
         .siu_bl16                           (siu_bl16),
         .reg_burst_rdwr                     (reg_burst_rdwr),
         .reg_ddrc_data_bus_width            (reg_ddrc_data_bus_width),
         .bg_or_bank_addrmap_mask            (bg_or_bank_addrmap_mask),
         .reg_arb_rrb_lock_threshold         (reg_arb_rrb_lock_threshold),
         .reg_arb_dch_density_ratio          (reg_arb_dch_density_ratio),
         .dch_bit                            (dch_bit),
         .e_addr_max_loc                     (e_addr_max_loc),
         .e_addr_max_m1_loc                  (e_addr_max_m1_loc),  
         .e_addr_max_loc_addrmap_mask        (e_addr_max_loc_addrmap_mask),
         .e_addr_max_m1_loc_addrmap_mask     (e_addr_max_m1_loc_addrmap_mask),
         .addr                               (addr),
         .alen                               (alen),
         .split                              (split),
         .short_burst                        (short_burst),
         .asize                              (asize),
         .alock                              (alock),
         .wr                                 (wr),
         .rd                                 (rd),
         .autopre                            (autopre),
         .next_addr_wrap_autopre             (next_addr_wrap_autopre),
         .next_alen_wrap_autopre             (next_alen_wrap_autopre),
         .exa_addr                           (exa_addr),
         .exa_alen                           (exa_alen),
         .exa_asize                          (exa_asize)
         ); 

      end // RP_inst

      if (OCCAP_EN==1) begin: CMP_en
        

         wire [OUT_TOTW-1:0] cmp_in0, cmp_in1;

         assign cmp_in0 = {
                           1'b0,
                           1'b0,
                           1'b0,
                           1'b0,
                           sbam_tokens_allocated,
                           sbam_second_burst,
                           sbam_lead_burst,
                           bam_addr_offset,
                           bam_lead_burst,
                           beat_info,
                           exa_acc_lock,
                           exa_acc_pyld,
                           exa_acc_instr,
                           exa_acc,
                           acc_info,
                           info,
                           empty,
                           e_autopre,
                           e_alast,
                           e_addr,
                           full};

         assign cmp_in1 = {
                           1'b0,
                           1'b0,
                           1'b0,
                           1'b0,
                           sbam_tokens_allocated_w[NUM_INST-1],
                           sbam_second_burst_w[NUM_INST-1],
                           sbam_lead_burst_w[NUM_INST-1],
                           bam_addr_offset_w[NUM_INST-1],
                           bam_lead_burst_w[NUM_INST-1],
                           beat_info_w[NUM_INST-1],
                           exa_acc_lock_w[NUM_INST-1],
                           exa_acc_pyld_w[NUM_INST-1],
                           exa_acc_instr_w[NUM_INST-1],
                           exa_acc_w[NUM_INST-1],
                           acc_info_w[NUM_INST-1],
                           info_w[NUM_INST-1],
                           empty_w[NUM_INST-1],
                           e_autopre_w[NUM_INST-1],
                           e_alast_w[NUM_INST-1],
                           e_addr_w[NUM_INST-1],
                           full_w[NUM_INST-1]};

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
         rp_cmp
         (
            .clk                 (clk),
            .rst_n               (rst_n),
            .in0                 (cmp_in0),
            .in1                 (cmp_in1),
            .cmp_en              (rp_cmp_en),
            .cmp_poison          (rp_cmp_poison),
            .cmp_poison_full     (rp_cmp_poison_full),
            .cmp_poison_err_inj  (rp_cmp_poison_err_inj),
            .cmp_err             (rp_cmp_error),
            .cmp_err_full        (rp_cmp_error_full),
            .cmp_err_seq         (rp_cmp_error_seq),
            .cmp_poison_complete (rp_cmp_poison_complete)
         );
         

      end // CMP_en
      else begin: OCCAP_dis

         assign rp_cmp_error           = 1'b0;
         assign rp_cmp_error_full      = 1'b0;
         assign rp_cmp_error_seq       = 1'b0;
         assign rp_cmp_poison_complete = 1'b1;

      end // OCCAP_dis
   endgenerate

endmodule // DWC_ddr_umctl2_xpi_rp_wrapper
