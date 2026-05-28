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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_wp_wrapper.sv#1 $
// -------------------------------------------------------------------------
// Description:
//         uMCTL XPI Write Packetizer module wrapper
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_wp_wrapper
import DWC_ddrctl_reg_pkg::*;
  #(
   //---------------------------------------------------------------------------
   // Parameters
   //---------------------------------------------------------------------------
    parameter OCCAP_EN                 = 0,
    parameter CMP_REG                  = 0,
    parameter UP_SIZE                  = 0,
    parameter DOWN_SIZE                = 0, 
    parameter M_DW                     = 32,
    parameter M_ADDRW                  = 32,
    parameter NAB                      = 2,
    parameter PDBW_CASE                = 0,  // Programmable DRAM data width cases - Case1:1 ... Case5:5 
    parameter MEMC_BURST_LENGTH        = 8,
    parameter XPI_BRW                  = 3,
    parameter NBEATS_LG2               = 1,
    parameter AXI_ADDRW                = 32,
    parameter AXI_MAXSIZE              = 2,
    parameter ENIF_LENW                = 6, 
    parameter ENIF_SIZEW               = 3, 
    parameter ENIF_LOCKW               = 2,
    parameter ENIF_STRBW               = 2,   
    parameter ENIF_MAXSIZE             = 1,
    parameter ENIF_HSIZEW              = 3,
    parameter ENIF_HLENW               = 2,
    parameter ENIF_HMAXSIZE            = 1,
    parameter MAXSIZE                  = 2,
    parameter INFOW                    = 4,
    parameter DDRCTL_LUT_ADDRMAP_EN    = 0,    
    parameter UMCTL2_HET_RANK_EN       = 0,
    parameter AMCSW                    = 5,
    parameter AMCOLW                   = 4,
    parameter AMCOLW_C3                = 5,
    parameter AXI_ADDR_BOUNDARY        = 12,        
    parameter DUAL_CHANNEL_INTERLEAVE  = 0,
    parameter DDRCTL_HET_INTERLEAVE    = 0,
    parameter DEACC_INFOW              = 5,
    parameter EXA_ACC_SUPPORT          = 0,
    parameter EXA_PYLD_W               = 2, 
    parameter EXA_MAX_LENW             = 12,
    parameter EXA_MAX_SIZEW            = 3,
    parameter EXA_MAX_ADDRW            = 12,
    parameter AXI_LENW                 = 6,
    parameter AXI_SIZEW                = 2,
    parameter AXI_MAXSIZE_EXA          = 1
    )
   
                                    (
   input                       clk,           // clock
   input                       rst_n,         // asynchronous reset
   input                       siu_bl16,
   input                       siu_bl8,
   input                       siu_bl4, 
   input [XPI_BRW-1:0]         reg_burst_rdwr,
   input                       reg_ddrc_col_addr_shift,
   input [`MEMC_NUM_RANKS-1:0] reg_ddrc_active_ranks,
   input                       reg_ddrc_alt_addrmap_en,                       
   input [AMCSW-1:0]           reg_ddrc_addrmap_cs_bit0,
   input [AMCSW-1:0]           reg_ddrc_addrmap_cs_bit1,
   input [AMCOLW-1:0]          reg_ddrc_addrmap_col_b2_alt,
   input [AMCOLW_C3-1:0]       reg_ddrc_addrmap_col_b3_alt,
   input [AMCOLW-1:0]          reg_ddrc_addrmap_col_b2,
   input [AMCOLW_C3-1:0]       reg_ddrc_addrmap_col_b3,
   input [1:0]                 reg_ddrc_data_bus_width,
   // bankgroup mask
   input [M_ADDRW-1:0]         bg_or_bank_addrmap_mask,  
   
   // interface with WRAPP SPLIT 
   input [AXI_ADDRW-1:0]      addr,         // AXI first INCR burst address
   input [ENIF_LENW-1:0]      alen,         // AXI first INCR burst length
   input                      split,         // Single INCR burst 
   input                      short_burst,
  
   // interface to AXI write/read  address channel   
   input [ENIF_SIZEW-1:0]     asize,         // AXI burst size
   input [ENIF_LOCKW-1:0]     alock,         // AXI lock
   input                      wr,            // AXI address valid
   output                     full,          // AXI address ready
   input                      autopre,       // AXI address auto precharge
   input  [AXI_ADDRW-1:0]     next_addr_wrap_autopre, // For AXI autopre wrap burst
   input  [ENIF_LENW-1:0]     next_alen_wrap_autopre, // For AXI autopre wrap burst

   output [M_ADDRW-1:0]       e_addr,
   output                     e_alast,       // ENIF address last
   output                     empty,         // ENIF address valid
   input                      rd,            // ENIF address ready
   output                     e_autopre,     // ENIF address auto precharge

   
   input [1:0]                reg_arb_dch_density_ratio,
   input [5:0]                dch_bit,
   input [5:0]                e_addr_max_loc,
   input [5:0]                e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]        e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]        e_addr_max_m1_loc_addrmap_mask,

   output [DEACC_INFOW-1:0]   deacc_info,
   output [INFOW-1:0]         info,          // Post write address queues data  
   output                     exa_acc,       // asserted, if exclusive read/write, with the first packet
   output                     exa_acc_lock,  // asserted, if exclusive write, for all packets of an AXI burst
   output                     exa_acc_instr, // asserted, if exclusive read/write, with all the packets
   output [EXA_PYLD_W-1:0]    exa_acc_pyld,

   // occap specific input/output
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                      wp_cmp_en,
   input                      wp_cmp_poison,
   input                      wp_cmp_poison_full,
   input                      wp_cmp_poison_err_inj,
//spyglass enable_block W240
   output                     wp_cmp_error,
   output                     wp_cmp_error_full,
   output                     wp_cmp_error_seq,
   output                     wp_cmp_poison_complete,

   input [AXI_MAXSIZE_EXA-1:0] exa_addr,
   input [AXI_LENW-1:0]        exa_alen,
   input [AXI_SIZEW-1:0]       exa_asize
   );
  
  
  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

   localparam NUM_INST = OCCAP_EN==1 ? 2 : 1;
   localparam NUM_OUTS = 15; // WARNING: update whenever a new output is added to xpi_wp
   localparam PW       = 32;
   // assign outputs width to internal parameters, update if outputs/parameters are changed
   localparam OUT0_W    = 1; // full
   localparam OUT1_W    = M_ADDRW; // e_addr
   localparam OUT2_W    = 1; // e_alast
   localparam OUT3_W    = 1; // empty
   localparam OUT4_W    = DEACC_INFOW; // deacc_info
   localparam OUT5_W    = INFOW; // info
   localparam OUT6_W    = 1; // exa_acc
   localparam OUT7_W    = 1; // exa_acc_instr
   localparam OUT8_W    = EXA_PYLD_W; // exa_acc_pyld
   localparam OUT9_W    = 1; // exa_acc_lock
   localparam OUT10_W   = 1; // auto prechage
   localparam OUT11_W   = (DDRCTL_LUT_ADDRMAP_EN==1)? M_ADDRW : 1; //e_addr_alt_out
   localparam OUT12_W   = 1; //e_addr_alt_addrmap_sel_out
   localparam OUT13_W   = (DDRCTL_LUT_ADDRMAP_EN==1)? `DDRCTL_LUT_ADDRMAP_CS_WIN_BITS : 1; //lut_sel
   localparam OUT14_W   = (DDRCTL_LUT_ADDRMAP_EN==1)? 2 : 1; //e_cs_out


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

   localparam OUT_TOTW = OUT14_OFF;

   localparam [NUM_OUTS*PW-1:0] WIDTH_OFFSET =
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
   // WP instance
   //---------------------------------------------------------------------------  

         genvar n;

         wire                    full_w [NUM_INST-1:0];
         wire [M_ADDRW-1:0]      e_addr_w [NUM_INST-1:0];
         wire                    e_alast_w [NUM_INST-1:0];
         wire                    empty_w [NUM_INST-1:0];
         wire [DEACC_INFOW-1:0]  deacc_info_w [NUM_INST-1:0];
         wire [INFOW-1:0]        info_w [NUM_INST-1:0];
         wire                    e_autopre_w [NUM_INST-1:0];
         wire                    exa_acc_w [NUM_INST-1:0];
         wire                    exa_acc_instr_w [NUM_INST-1:0];
         wire [EXA_PYLD_W-1:0]   exa_acc_pyld_w [NUM_INST-1:0];
         wire                    exa_acc_lock_w [NUM_INST-1:0];

         // output assign
         assign full          = full_w[0];
         assign e_addr        = e_addr_w[0];
         assign e_alast       = e_alast_w[0];
         assign empty         = empty_w[0];
         assign deacc_info    = deacc_info_w[0];
         assign info          = info_w[0];
         assign e_autopre     = e_autopre_w[0];
         assign exa_acc       = exa_acc_w[0];
         assign exa_acc_instr = exa_acc_instr_w[0];
         assign exa_acc_pyld  = exa_acc_pyld_w[0];
         assign exa_acc_lock  = exa_acc_lock_w[0];

   generate
      for (n=0; n<NUM_INST; n=n+1) begin: WP_inst

      DWC_ddr_umctl2_xpi_wp
      
      #(
      .UP_SIZE                (UP_SIZE),
      .DOWN_SIZE              (DOWN_SIZE),     
      .M_DW                   (M_DW),
      .M_ADDRW                (M_ADDRW),
      .NAB                    (NAB),
      .PDBW_CASE              (PDBW_CASE),
      .MEMC_BURST_LENGTH      (MEMC_BURST_LENGTH),
      .XPI_BRW                (XPI_BRW),
      .NBEATS_LG2             (NBEATS_LG2),
      .AXI_ADDRW              (AXI_ADDRW),
      .AXI_MAXSIZE            (AXI_MAXSIZE),
      .ENIF_LENW              (ENIF_LENW), 
      .ENIF_SIZEW             (ENIF_SIZEW),
      .ENIF_LOCKW             (ENIF_LOCKW),
      .ENIF_STRBW             (ENIF_STRBW),
      .ENIF_MAXSIZE           (ENIF_MAXSIZE),
      .ENIF_HSIZEW            (ENIF_HSIZEW),
      .ENIF_HLENW             (ENIF_HLENW),
      .ENIF_HMAXSIZE          (ENIF_HMAXSIZE),
      .MAXSIZE                (MAXSIZE),
      .INFOW                  (INFOW),
      .DDRCTL_LUT_ADDRMAP_EN  (DDRCTL_LUT_ADDRMAP_EN),      
      .UMCTL2_HET_RANK_EN     (UMCTL2_HET_RANK_EN),
      .AMCSW                  (AMCSW),
      .AMCOLW                 (AMCOLW),
      .AMCOLW_C3              (AMCOLW_C3),
      .AXI_ADDR_BOUNDARY      (AXI_ADDR_BOUNDARY),   
      .DUAL_CHANNEL_INTERLEAVE(DUAL_CHANNEL_INTERLEAVE),
      .DDRCTL_HET_INTERLEAVE  (DDRCTL_HET_INTERLEAVE),
      .DEACC_INFOW            (DEACC_INFOW),
      .EXA_ACC_SUPPORT        (EXA_ACC_SUPPORT),
      .EXA_PYLD_W             (EXA_PYLD_W),
      .EXA_MAX_LENW           (EXA_MAX_LENW),
      .EXA_MAX_SIZEW          (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW          (EXA_MAX_ADDRW),
      .AXI_LENW               (AXI_LENW),
      .AXI_SIZEW              (AXI_SIZEW),
      .AXI_MAXSIZE_EXA        (AXI_MAXSIZE_EXA)
      )
      U_wp
      (
      // Outputs
      .full                               (full_w[n]),
      .e_addr                             (e_addr_w[n]),
      .e_alast                            (e_alast_w[n]),
      .empty                              (empty_w[n]),
      .deacc_info                         (deacc_info_w[n]),
      .info                               (info_w[n]),  
      .e_autopre                          (e_autopre_w[n]),
      .exa_acc                            (exa_acc_w[n]),
      .exa_acc_instr                      (exa_acc_instr_w[n]),
      .exa_acc_pyld                       (exa_acc_pyld_w[n]),
      .exa_acc_lock                       (exa_acc_lock_w[n]),
      // inputs
      .clk                                (clk),
      .rst_n                              (rst_n),
      .siu_bl4                            (siu_bl4),
      .siu_bl8                            (siu_bl8),
      .siu_bl16                           (siu_bl16),
      .reg_burst_rdwr                     (reg_burst_rdwr),
      .reg_ddrc_col_addr_shift            (reg_ddrc_col_addr_shift),
      .reg_ddrc_addrmap_col_b2            (reg_ddrc_addrmap_col_b2),
      .reg_ddrc_addrmap_col_b3            (reg_ddrc_addrmap_col_b3),
      .reg_ddrc_active_ranks              (reg_ddrc_active_ranks),
      .reg_ddrc_alt_addrmap_en            (reg_ddrc_alt_addrmap_en),
      .reg_ddrc_addrmap_cs_bit0           (reg_ddrc_addrmap_cs_bit0),
      .reg_ddrc_addrmap_cs_bit1           (reg_ddrc_addrmap_cs_bit1),        
      .reg_ddrc_addrmap_col_b2_alt        (reg_ddrc_addrmap_col_b2_alt),
      .reg_ddrc_addrmap_col_b3_alt        (reg_ddrc_addrmap_col_b3_alt),
      .bg_or_bank_addrmap_mask            (bg_or_bank_addrmap_mask),
      .reg_arb_dch_density_ratio          (reg_arb_dch_density_ratio),
      .dch_bit                            (dch_bit),
      .e_addr_max_loc                     (e_addr_max_loc),
      .e_addr_max_m1_loc                  (e_addr_max_m1_loc),  
      .e_addr_max_loc_addrmap_mask        (e_addr_max_loc_addrmap_mask),
      .e_addr_max_m1_loc_addrmap_mask     (e_addr_max_m1_loc_addrmap_mask),
      .reg_ddrc_data_bus_width            (reg_ddrc_data_bus_width),
      .addr                               (addr),
      .alen                               (alen),
      .split                              (split),
      .short_burst                        (short_burst),
      .asize                              (asize),
      .alock                              (alock),
      .autopre                            (autopre),
      .next_addr_wrap_autopre             (next_addr_wrap_autopre),
      .next_alen_wrap_autopre             (next_alen_wrap_autopre),
      .wr                                 (wr),
      .rd                                 (rd),
      .exa_addr                           (exa_addr),
      .exa_alen                           (exa_alen),
      .exa_asize                          (exa_asize)
      );

   end // WP_inst

   if (OCCAP_EN==1) begin: CMP_en

      wire [OUT_TOTW-1:0] cmp_in0, cmp_in1;

      assign cmp_in0 = {
                        1'b0,
                        1'b0,
                        1'b0,
                        1'b0,
                        exa_acc_lock,
                        exa_acc_pyld,
                        exa_acc_instr,
                        exa_acc,
                        info,
                        e_autopre,
                        deacc_info,
                        empty,
                        e_alast,
                        e_addr,
                        full};

      assign cmp_in1 = {
                        1'b0,
                        1'b0,
                        1'b0,
                        1'b0,
                        exa_acc_lock_w[NUM_INST-1],
                        exa_acc_pyld_w[NUM_INST-1],
                        exa_acc_instr_w[NUM_INST-1],
                        exa_acc_w[NUM_INST-1],
                        info_w[NUM_INST-1],
                        e_autopre_w[NUM_INST-1],
                        deacc_info_w[NUM_INST-1],
                        empty_w[NUM_INST-1],
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
      wp_cmp
      (
         .clk                 (clk),
         .rst_n               (rst_n),
         .in0                 (cmp_in0),
         .in1                 (cmp_in1),
         .cmp_en              (wp_cmp_en),
         .cmp_poison          (wp_cmp_poison),
         .cmp_poison_full     (wp_cmp_poison_full),
         .cmp_poison_err_inj  (wp_cmp_poison_err_inj),
         .cmp_err             (wp_cmp_error),
         .cmp_err_full        (wp_cmp_error_full),
         .cmp_err_seq         (wp_cmp_error_seq),
         .cmp_poison_complete (wp_cmp_poison_complete)
      );

   end // CMP_en
   else begin: OCCAP_dis

      assign wp_cmp_error           = 1'b0;
      assign wp_cmp_error_full      = 1'b0;
      assign wp_cmp_error_seq       = 1'b0;
      assign wp_cmp_poison_complete = 1'b0;

   end // OCCAP_dis
endgenerate


endmodule // DWC_ddr_umctl2_xpi_wp_wrapper
