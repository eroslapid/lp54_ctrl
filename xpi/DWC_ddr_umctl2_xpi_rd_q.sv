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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_rd_q.sv#1 $
// -------------------------------------------------------------------------
// Description:
//         XPI read channel
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_rd_q
import DWC_ddrctl_reg_pkg::*;
   #(
      parameter M_DW                = 32, // SDRAM data width
      parameter M_DW_INT            = 16,
      parameter M_ADDRW             = 32, // Memory address width (word aligned address)
      parameter NAB                 = 2,
      parameter PDBW_CASE           = 0,  // Programmable DRAM data width cases - Case1:1 ... Case5:5 
      parameter MEMC_BURST_LENGTH   = 8,
      parameter NTOKENS       = 32,
      parameter NTOKENS_LG2 = `UMCTL_LOG2(NTOKENS),
      parameter NBEATS              = 2,
      parameter NBEATS_LG2          = 1,
      parameter BEAT_INFOW          = 4,      
      parameter XPI_BRW             = 3,  
      parameter AXI_ADDRW           = 32, // AXI address width
      parameter ENIF_DATAW          = 16,                  // Memory data width
      parameter ENIF_LENW           = 6,  // AXI a*len width
      parameter ENIF_SIZEW          = 3,  // AXI a*size width
      parameter ENIF_STRBW          = 2,   
      parameter ENIF_MAXSIZE        = 1,
      parameter ENIF_LOCKW          = 2,
      parameter ENIF_HDATAW         = 16,                  // Memory data width
      parameter ENIF_HSTRBW         = 2,
      parameter ENIF_HLENW          = 6,  // AXI a*len width
      parameter ENIF_HSIZEW         = 3,  // AXI a*size width
      parameter ENIF_HMAXSIZE       = 1,
      parameter MAXSIZE             = 2,
      parameter RPINFOW             = 4,
      parameter ARINFOW             = 4,
      parameter UP_SIZE             = 0,
      parameter DOWN_SIZE           = 0,   
      parameter AXI_ADDR_BOUNDARY   = 12,  // Defines AXI address no crossing boundary ( default is 4k)    
      parameter USE_RAR             = 0,
      parameter RARW                = 32,
      parameter NUM_VIR_CH_LG2      = 2, //width of channel identifier
      parameter AXI_QOSW            = 4, // AXI a*qos width
      parameter AXI_IDW             = 8,   // AXI ID width
      parameter ORDER_TOKENW        = 8,
      parameter USE_RAQ             = 0,
      parameter AXI_SIZEW           = 4,
      parameter AU_INFOW_L          = 4,
      parameter AXI_RAQD            = 32,
      parameter AXI_RAQD_LG2        = 5,
      parameter ASYNC_FIFO_N_SYNC   = 2,
      parameter AXI_SYNC            = 0,   // AXI synchronous or asynchronous
      parameter AU_INFOW            = 1,
      parameter AXI_USERW           = 1,
      parameter RAQ_SIZEW           = 4,
      parameter AXI_LOCKW           = 2,
      parameter AXI_LENW            = 6,
      parameter AXI_DATAW           = 32,                  // AXI data width
      parameter AXI_STRBW           = 4,                   // AXI number bytes
      parameter AXI_MAXSIZE         = 2,                   // AXI Maximum size
      parameter ACC_INFOW           = 2,
      parameter RQOS_RW             = 2,
      parameter USE2RAQ             = 0,
      parameter RQOS_TW             = 11,
      parameter VPR_EN              = 0,
      parameter VPRW_PUSH_SYNC_DEPTH = 16,
      parameter VPRW                = 1,
      parameter RRB_THRESHOLD_EN        = 0,
      parameter RRB_LOCK_THRESHOLD_WIDTH    = 0,
      parameter RAR_DEPTH           = 2,
      parameter DUAL_CHANNEL_INTERLEAVE     = 0,
      parameter DUAL_CHANNEL_INTERLEAVE_LP  = 0,
      parameter DDRCTL_HET_INTERLEAVE       = 0,
      parameter DDRCTL_LUT_ADDRMAP_EN       = 0,
      parameter ASYNC_FIFO_EARLY_PUSH_STAT  = 0,
      parameter ASYNC_FIFO_EARLY_POP_STAT   = 1,
      parameter INTLVMODEW          = 2,
      parameter OCCAP_EN            = 0,
      parameter OCCAP_PIPELINE_EN   = 0,
      parameter OCCAP_CMP_CC        = 2,
      // Exclusive Access 
      parameter EXA_ACC_SUPPORT     = 0,
      parameter EXA_PYLD_W          = 2, 
      parameter EXA_MAX_LENW        = 12, // Worst Case Dowsnsizing is 256/8 with a AXI_LENW of 6
      parameter EXA_MAX_SIZEW       = 3,  // Maximum AXI Size is 3 bits
      parameter EXA_MAX_ADDRW       = 12,  // 12 bits for 4K Boundary
      parameter BCM_VERIF_EN        = 2,
      // internal bcm07 parameters
      parameter PUSH_AE_LVL         =  2, 
      parameter PUSH_AF_LVL         =  2,
      parameter POP_AE_LVL          =  2,
      parameter POP_AF_LVL          =  2,
      parameter ERR_MODE            =  0,
      parameter AXI_MAXSIZE_EXA     =  1,
      parameter MEM_MODE            =  0, // RANGE 0 to 3
      parameter VERIF_EN            =  1  // RANGE 0 to 5 
   )
   
                              (
   //---------------------------------------------------------------------------
   // Interface Pins
   //---------------------------------------------------------------------------
   
   input                                aclk,           // clock
   input                                aresetn,         // asynchronous reset
   input                                e_clk,
   input                                e_rst_n,
   
   input                                siu_bl16,
   input                                siu_bl8,
   input                                siu_bl4, 
   input [XPI_BRW-1:0]                  reg_burst_rdwr,
   input [1:0]                          reg_ddrc_data_bus_width, //MSTR's DRAM bus width setting

   
   input [AXI_ADDRW-1:0]                addr,         // AXI first INCR burst address
   input [AXI_LENW-1:0]                 alen,         // AXI first INCR burst length
   input [RAQ_SIZEW-1:0]                asize,        // AXI burst size

   input                                split,        // Single INCR burst 
   input                                short_burst,  // Short WRAP burst not crossing one BL
   input                                skip,
    
   input [ENIF_LOCKW-1:0]               lock,         // AXI lock
   input                                wr,          // AXI address valid
  
   output                               full,      // packetizer full
   output                               empty,     // raq empty

   input [ORDER_TOKENW-1:0]             raq_pre_arb_order_token,
   input                                raq_bypass_reorder,
   input [NUM_VIR_CH_LG2-1:0]           raq_ch_num,
   input [AXI_QOSW-1:0]                 raq_qos,
   input [AXI_IDW-1:0]                  raq_id,
   input                                raq_poison,
   input                                raq_ocpar_err,
   input [AXI_USERW-1:0]                raq_user,
   input                                raq_autopre,
   input [AXI_ADDRW-1:0]                raq_next_addr_wrap_autopre,
   input [AXI_LENW-1:0]                 raq_next_alen_wrap_autopre,

   input [AU_INFOW_L-1:0]               raq_info,

   input [RQOS_RW-1:0]                  read_qos_priority,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input [RQOS_TW-1:0]                  rqos_map_timeout,
   // data channel mask
   input [M_ADDRW-1:0]                  data_channel_addrmap_mask,   
   // bankgroup mask
   input [M_ADDRW-1:0]                  bg_or_bank_addrmap_mask,
//spyglass enable_block W240
   output                               id_match,

   output                               e_vpr_expired,  // vpr read expired in the FIFO

   input                                reg_ddrc_occap_en,
   input                                reg_arb_occap_arb_raq_poison_en,
   input                                reg_ddrc_occap_arb_cmp_poison_seq,
   input                                reg_ddrc_occap_arb_cmp_poison_parallel,
   input                                reg_ddrc_occap_arb_cmp_poison_err_inj,

   output                               occap_xpi_read_par_err,

   output                               occap_cmp_error,
   output                               occap_cmp_error_full,
   output                               occap_cmp_error_seq,
   output                               occap_cmp_poison_complete,

   input [RRB_LOCK_THRESHOLD_WIDTH-1:0] reg_arb_rrb_lock_threshold,

   input [1:0]                          reg_arb_dch_density_ratio,
   input [5:0]                          dch_bit,
   input [5:0]                          e_addr_max_loc,
   input [5:0]                          e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]                  e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]                  e_addr_max_m1_loc_addrmap_mask,

   // Page match mask
   input [M_ADDRW-1:0]                  pagematch_addrmap_mask,
   input                                pagematch_en,

   output [BEAT_INFOW-1:0]              beat_info,
   output [ORDER_TOKENW-1:0]            xpi_read_order_token,

   // Use SBAM (Simplified BAM) for RRB enhancement
   output                               sbam_lead_burst,
   output                               sbam_second_burst,
   output [NTOKENS_LG2:0]               sbam_tokens_allocated,

  output                               bam_lead_burst,
  output [AXI_MAXSIZE-1:0]             bam_addr_offset,

   output                               e_poison,
   output                               e_ocpar_err,

   output [AXI_USERW-1:0]               e_user,
   output                               e_autopre,

   // Reored buffer virtual channel 
   output [NUM_VIR_CH_LG2-1:0]          xpi_read_ch_num,
   output                               xpi_read_bypass_reorder,

   // ENIF Exclusive Access Info
   output                               e_exa_acc,       // ENIF Exclusive Access, first packet
   output                               e_exa_acc_instr, // ENIF Exclusive Access, all the packets
   output [EXA_PYLD_W-1:0]              e_exa_pyld,      // ENIF Exclusive Access Payload

   // ENIF interface
   input                                e_arready,
   output                               e_split,
   output [M_ADDRW-1:0]                 e_araddr,       // ENIF read address
   output [AXI_IDW-1:0]                 e_arid,         // ENIF read address ID
   output [RQOS_RW-1:0]                 e_rqos_priority, // ENIF read priority
   output [RQOS_TW-1:0]                 e_rqos_timeout,
   output [AXI_QOSW-1:0]                e_arqos,        // ENIF read address qos
   output                               e_arpagematch,  // ENIF read pagematch indication
   output                               e_arlast,       // ENIF read address last
   output [ARINFOW-1:0]                 e_arinfo,       // ENIF read address info
   output                               e_arvalid,
   output                               e_dch,
   output reg [AXI_RAQD_LG2:0]          raq_wcount,
   output reg                           raq_pop, 
   output                               raq_push,
   
   //exa payload data
   input [AXI_MAXSIZE_EXA-1:0]            exa_addr,
   input [AXI_LENW-1:0]                   exa_alen,
   input [AXI_SIZEW-1:0]                  exa_asize
   );
// UNR constant declaration
`SNPS_UNR_CONSTANT("If AXI_USER_WIDTH is 0 in config, dummy signal is used internally", 1, e_user[0], 1'b0)

  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

   localparam RAQW      =  ((UP_SIZE==1) ? AU_INFOW : 0) +   // au_info
                           ORDER_TOKENW +
                           RQOS_RW +
                           (1+NUM_VIR_CH_LG2) + //  bypass_reorder ,ch_num
                           AXI_LOCKW +
                           1 + 1 + 1 + 1 + 1 + AXI_USERW +
                           AXI_QOSW+
                           AXI_IDW + 
                           AXI_LENW +
                           RAQ_SIZEW +
                           AXI_ADDRW + 
                           1 + // auto precharge
                           AXI_ADDRW + // next_addr_wrap_autopre
                           AXI_LENW+ // next_alen_wrap_autopre
                           AXI_MAXSIZE_EXA +
                           AXI_LENW +
                           AXI_SIZEW;

   localparam VPRW_PUSH_SYNC_DEPTH_LG2 = `UMCTL_LOG2(VPRW_PUSH_SYNC_DEPTH);

   localparam OCCAP_CTRLW = 
                            M_ADDRW +       // ep_addr_prev_dcb
                            M_ADDRW +       // ep_addr_prev/ep_addr_prev_dca
                            1 +             // raq_pop
                            AXI_RAQD_LG2+1; // raq_wcount
   localparam SL_W = 8;
   localparam PARW = ((OCCAP_CTRLW%SL_W>0) ? OCCAP_CTRLW/SL_W+1 : OCCAP_CTRLW/SL_W);

  //---------------------------------------------------------------------------
  // Internal signals 
  //---------------------------------------------------------------------------

    wire [M_ADDRW-1:0]          ep_addr;       // ENIF Packetizer address
    wire [M_ADDRW-1:0]          ep_addr_alt;
    wire [1:0]                  ep_cs;
    wire [M_ADDRW-1:0]          ep_addr_int;
    wire                        ep_addr_alt_addrmap_sel;
    wire [1:0]                  ep_cs_prev_dca;
    wire [1:0]                  ep_cs_prev_dcb;
    wire                        reg_ep_cs_prev_dca_par_err;
    wire                        reg_ep_cs_prev_dcb_par_err;
    wire                        het_pagematch_en_dca;
    wire                        het_pagematch_en_dcb;
    wire                        ep_alast;      // ENIF Packetizer address last
    wire                        ep_rd, ep_wr;
    wire                        ep_empty, ep_full;
    wire                        ep_exa_acc, ep_exa_acc_instr, ep_exa_acc_lock_unused;
    wire [EXA_PYLD_W-1:0]       ep_exa_pyld;
    wire [BEAT_INFOW-1:0]       ep_beat_info;
    wire                        ep_arpagematch;

    wire                        ep_sbam_lead_burst;
    wire                        ep_sbam_second_burst;
    wire [NTOKENS_LG2:0]        ep_sbam_tokens_allocated;

    wire                        ep_bam_lead_burst;
    wire [AXI_MAXSIZE-1:0]      ep_bam_addr_offset;

    wire [AXI_ADDRW-1:0]        addr2ep;
    wire [ENIF_LENW-1:0]        alen2ep;
    wire [ENIF_SIZEW-1:0]       asize2ep; 
    wire                        autopre2ep; 
    wire [AXI_ADDRW-1:0]        next_addr_wrap_autopre2ep;
    wire [ENIF_LENW-1:0]        next_alen_wrap_autopre2ep;

    wire [AXI_LENW-1:0]         alen_ep;
    wire [AXI_ADDRW-1:0]        addr_ep;
    wire [AXI_LENW-1:0]         next_alen_wrap_autopre_ep;
    wire [AXI_ADDRW-1:0]        next_addr_wrap_autopre_ep;
    wire                        ep_split, ep_short_burst, ep_skip_unused, ep_poison, ep_ocpar_err, ep_autopre;
    wire [AXI_USERW-1:0]        ep_user;
    wire [RAQ_SIZEW-1:0]        asize_ep;
    wire [ENIF_LOCKW-1:0]       ep_alock;
    wire [RQOS_RW-1:0]          ep_read_qos_priority;
    wire [RQOS_RW-1:0]          ep_post_read_qos_priority;

    wire                        raq_full, raq_empty, raq_rd, raq_wr;
    wire [RARW-1:0]             rar_d, rar_q;
    wire                        rar_full, rar_empty;
    wire                        rar_push, rar_pop, rar_in_vpr, rar_out_vpr;

    wire [RAQW-1:0]             raq_d;
    wire [RAQW-1:0]             raq_q;

    wire [RPINFOW-1:0]          rp_info;      // packetizer info

    wire [ACC_INFOW-1:0]        acc_info;

    wire [ARINFOW-1:0]          ep_info;
    wire [ARINFOW-1:0]          ep_info_up;
    wire [ARINFOW-1:0]          ep_info_dw;
    wire [AU_INFOW_L-1:0]       info_ep;
    wire [NUM_VIR_CH_LG2-1:0]   ep_ch_num;
    wire [AXI_IDW-1:0]          ep_id;
    wire [AXI_QOSW-1:0]         ep_qos;
    wire                        ep_bypass_reorder;
    wire [ORDER_TOKENW-1:0]     ep_pre_arb_order_token;

    wire                        rar_vpr_empty_unused, raq_vpr_empty, rar_vpr_full_unused, raq_vpr_full;
    wire                        vpr_gate_raq; // in case of vpr, we need to gate the rp -><- raq to prevent a counter value to be popped when nothing has been pushed yet
    wire                        vpr_gate_in_raq;
    wire                        raq_push_vpr, raq_push_aclk;

    wire                        raq_id_matched;

    wire                        rp_data_channel;

    wire [AXI_RAQD_LG2:0]       raq_wcount_i;

    wire                         occap_rar_par_err, occap_raq_par_err, occap_rar_vpr_err, occap_raq_vpr_err, occap_rd_q_ctrl_par_err;

    wire rp_cmp_error, rp_cmp_error_full, rp_cmp_error_seq, rp_cmp_poison_complete;

    assign occap_xpi_read_par_err = occap_rar_par_err | occap_raq_par_err | occap_rar_vpr_err | occap_raq_vpr_err | occap_rd_q_ctrl_par_err | reg_ep_cs_prev_dca_par_err | reg_ep_cs_prev_dcb_par_err;

   wire [AXI_MAXSIZE_EXA-1:0]            raq_exa_addr;
   wire [AXI_LENW-1:0]                   raq_exa_alen;
   wire [AXI_SIZEW-1:0]                  raq_exa_asize;

   wire [M_ADDRW-1:0]                    pagematch_addrmap_mask_int;

   generate
   if (DOWN_SIZE==1) begin: down_size

  //---------------------------------------------------------------------------
  // Address DownSizer 
  //---------------------------------------------------------------------------

      wire [AXI_SIZEW-1:0] ad_info;
      wire                 ad_empty, ad_full_unused, ad_wr, ad_rd;
      wire [AXI_ADDRW-1:0]        ad_addr;
      wire [ENIF_LENW-1:0]        ad_alen;
      wire [ENIF_SIZEW-1:0]       ad_asize;
      wire [AXI_ADDRW-1:0]        ad_next_addr_wrap_autopre;
      wire [ENIF_LENW-1:0]        ad_next_alen_wrap_autopre;
      wire                        ad_in_bypass;

      wire                 sq_wr_unused;

      if (DUAL_CHANNEL_INTERLEAVE==1) begin:Dual_dch
        if(UP_SIZE==1) begin : has_up_down //case2 - has both Upsize and downsize
         assign ep_info       = ad_in_bypass ? {acc_info,info_ep[AU_INFOW_L-1:0],rp_info} //use asize from upsizer's info
                                             : {acc_info,info_ep[AU_INFOW_L-1:AXI_SIZEW],ad_info,rp_info}; //use downsizer info
        end else begin : has_only_down
         assign ep_info       = {acc_info,ad_info,rp_info};
        end 
      end
      else begin: Single_dch
        if(UP_SIZE==1) begin : has_up_down //case2 - has both Upsize and downsize
         assign ep_info       = ad_in_bypass ? {info_ep[AU_INFOW_L-1:0],rp_info} //use asize from upsizer's info
                                             : {info_ep[AU_INFOW_L-1:AXI_SIZEW],ad_info,rp_info}; //use downsizer info
        end else begin : has_only_down
         assign ep_info       = {ad_info,rp_info};
        end
      end

      assign ep_wr         = ~ad_empty;
      assign addr2ep    = ad_addr;
      assign alen2ep    = ad_alen;
      assign asize2ep   = ad_asize;
      assign next_addr_wrap_autopre2ep = ad_next_addr_wrap_autopre;
      assign next_alen_wrap_autopre2ep = ad_next_alen_wrap_autopre;

   DWC_ddr_umctl2_xpi_ad
   
      
        #(
          .WR              (0),
          .AXI_DATAW       (AXI_DATAW),
          .AXI_STRBW       (AXI_STRBW),
          .AXI_MAXSIZE     (AXI_MAXSIZE),
          .AXI_SIZEW       (RAQ_SIZEW),
          .AXI_ADDRW       (AXI_ADDRW),
          .AXI_LENW        (AXI_LENW),
          .PDBW_CASE       (PDBW_CASE),

          .ENIF_DATAW      (ENIF_DATAW),
          .ENIF_STRBW      (ENIF_STRBW),
          .ENIF_MAXSIZE    (ENIF_MAXSIZE),
          .ENIF_SIZEW      (ENIF_SIZEW),
          .ENIF_LENW       (ENIF_LENW),
          .INFOW           (AXI_SIZEW)
          )
      U_ad (
            // Outputs
            .empty      (ad_empty), 
            .full       (ad_full_unused), 
            .addr_down  (ad_addr), 
            .alen_down  (ad_alen),  
            .asize_down (ad_asize),
            .sq_wr      (sq_wr_unused), 
            .info       (ad_info),
       //spyglass disable_block W528
       //SMD: A signal or variable is set but never read
       //SJ: Used in generate block 
            .ad_in_bypass (ad_in_bypass),
      //spyglass enable_block W528  
            .next_addr_wrap_autopre_down(ad_next_addr_wrap_autopre),
            .next_alen_wrap_autopre_down(ad_next_alen_wrap_autopre),
            // Inputs
            .clk        (e_clk), 
            .rst_n      (e_rst_n), 
            .wr         (ad_wr), 
            .rd         (ad_rd), 
            .addr       (addr_ep), 
            .alen       (alen_ep),
            .skip       (1'b0),
            .split      (ep_split),      
            .asize      (asize_ep), 
            .sq_full    (1'b0),
            .reg_ddrc_data_bus_width  (reg_ddrc_data_bus_width),
            .next_addr_wrap_autopre(next_addr_wrap_autopre_ep),
            .next_alen_wrap_autopre(next_alen_wrap_autopre_ep)
            );

      assign ad_wr = ~raq_empty & ~vpr_gate_raq;
      assign ad_rd = ~ep_full;


   end else if (UP_SIZE==1) begin: only_up_size
      if (DUAL_CHANNEL_INTERLEAVE==1) begin:Dual_dch
         assign ep_info    = {acc_info,info_ep,rp_info};
      end
      else begin: Single_dch
         assign ep_info    = {info_ep,rp_info};
      end
      
      assign ep_wr      = ~raq_empty & ~vpr_gate_raq;
      assign addr2ep    = addr_ep;
      assign alen2ep    = alen_ep;
      assign asize2ep   = asize_ep;
      assign next_addr_wrap_autopre2ep = next_addr_wrap_autopre_ep;
      assign next_alen_wrap_autopre2ep = next_alen_wrap_autopre_ep;
      //spyglass disable_block W528
       //SMD: A signal or variable is set but never read
       //SJ: Used in generate block 
      assign ad_in_bypass = 1'b0;
      //spyglass enable_block W528  
   end else begin: same_size
      if (DUAL_CHANNEL_INTERLEAVE==1) begin:Dual_dch
         assign ep_info    = {acc_info,rp_info};
      end
      else begin: Single_dch
         assign ep_info    = rp_info;
      end
      
      assign ep_wr      = ~raq_empty & ~vpr_gate_raq;
      assign addr2ep    = addr_ep;
      assign alen2ep    = alen_ep;
      assign asize2ep   = asize_ep;
      assign next_addr_wrap_autopre2ep = next_addr_wrap_autopre_ep;
      assign next_alen_wrap_autopre2ep = next_alen_wrap_autopre_ep;
      //spyglass disable_block W528
       //SMD: A signal or variable is set but never read
       //SJ: Used in generate block 
      assign ad_in_bypass = 1'b0;
      //spyglass enable_block W528  
   end
   endgenerate

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((((((((1 + 1) + 1) + 1) + 1) + AXI_USERW) + 1) + AXI_ADDRW) + AXI_LENW)' found in module 'DWC_ddr_umctl2_xpi_rd_q'
//SJ: This coding style is acceptable and there is no plan to change it.
  //---------------------------------------------------------------------------
  // Read Address Queue INFO field packer
  //---------------------------------------------------------------------------
   field_packer15
   
    # (AXI_IDW,AXI_ADDRW,RAQ_SIZEW,AXI_LENW,AXI_QOSW,1+1+1+1+1+AXI_USERW+1+AXI_ADDRW+AXI_LENW,AXI_LOCKW,1,NUM_VIR_CH_LG2,ORDER_TOKENW, (UP_SIZE==1) ? AU_INFOW_L : 0, RQOS_RW, AXI_MAXSIZE_EXA, AXI_LENW, AXI_SIZEW)
  raq_field_packer
    (// Outputs
     .out0                      (ep_id),
     .out1                      (addr_ep),
     .out2                      (asize_ep),
     .out3                      (alen_ep),
     .out4                      (ep_qos),
     .out5                      ({ep_skip_unused,ep_split,ep_short_burst,ep_poison,ep_ocpar_err,ep_user,autopre2ep,next_addr_wrap_autopre_ep,next_alen_wrap_autopre_ep}), 
     .out6                      (ep_alock),
     .out7                      (ep_bypass_reorder),
     .out8                      (ep_ch_num),
     .out9                      (ep_pre_arb_order_token),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .out10                     (info_ep),
//spyglass enable_block W528
     .out11                     (ep_read_qos_priority),
     .out12                     (raq_exa_addr),
     .out13                     (raq_exa_alen),
     .out14                     (raq_exa_asize),
     .pack_out                  (raq_d),
     // Inputs
     .in0                       (raq_id),
     .in1                       (addr),
     .in2                       (asize),
     .in3                       (alen),
     .in4                       (raq_qos),
     .in5                       ({skip,split,short_burst,raq_poison,raq_ocpar_err,raq_user,raq_autopre,raq_next_addr_wrap_autopre,raq_next_alen_wrap_autopre}), 
     .in6                       (lock),
     .in7                       (raq_bypass_reorder),
     .in8                       (raq_ch_num),
     .in9                       (raq_pre_arb_order_token),
     .in10                      (raq_info),
     .in11                      (read_qos_priority),
     .in12                      (exa_addr),
     .in13                      (exa_alen),
     .in14                      (exa_asize),
     .pack_in                   (raq_q));
//spyglass enable_block SelfDeterminedExpr-ML

  //---------------------------------------------------------------------------
  // Read Address Queue
  //---------------------------------------------------------------------------

  generate
    if (AXI_SYNC==1)  begin: sync_raq
      DWC_ddr_umctl2_gfifo_split
      
        
        #(
          .WIDTH           (RAQW),
          .WIDTH_SPLIT     (AXI_IDW),
          .SPLIT           (USE2RAQ),
          .DEPTH           (AXI_RAQD),
          .ADDR_WIDTH      (AXI_RAQD_LG2),
          .COUNT_WIDTH     (AXI_RAQD_LG2+1),
          .OCCAP_EN        (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
          ) 
      raq (
           .clk             (aclk),
           .rst_n           (aresetn),
           .wr              (raq_wr),
           .d               (raq_d),
           .rd              (raq_rd),
           .par_en          (reg_ddrc_occap_en),
           .poison_en       (reg_arb_occap_arb_raq_poison_en),
           .ff              (raq_full),
           .matched         (raq_id_matched),
           .wcount          (raq_wcount_i),
           .q               (raq_q),
           .fe              (raq_empty),
           .par_err         (occap_raq_par_err)
           );
    end // block: sync_raq
    // --
    // Asynchronous FIFO
    // --
    if (AXI_SYNC==0) begin: async_raq
      wire [AXI_RAQD_LG2:0]       push_wcount_unused;
      wire                        push_fe_unused;
      
      DWC_ddr_umctl2_gafifo_split
      
      
        #(
          .WIDTH              (RAQW),
          .WIDTH_SPLIT        (AXI_IDW),
          .SPLIT              (USE2RAQ),
          .DEPTH              (AXI_RAQD),
          .ADDR_WIDTH         (AXI_RAQD_LG2),
          .COUNT_WIDTH        (AXI_RAQD_LG2+1),
          .PUSH_SYNC          (ASYNC_FIFO_N_SYNC),
          .POP_SYNC           (ASYNC_FIFO_N_SYNC),
          .EARLY_PUSH_STAT    (ASYNC_FIFO_EARLY_PUSH_STAT),  // push side is all registered
          .EARLY_POP_STAT     (ASYNC_FIFO_EARLY_POP_STAT),   // registered /*unregistered pop_fe and pop_wcount*/ 
          .OCCAP_EN           (OCCAP_EN),
          .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)          
          )
      raq (
           .wclk               (aclk),
           .wrst_n             (aresetn),
           .wr                 (raq_wr),
           .d                  (raq_d),
           .rclk               (e_clk),
           .rrst_n             (e_rst_n),
           .rd                 (raq_rd),
           .par_en             (reg_ddrc_occap_en),
           .poison_en          (reg_arb_occap_arb_raq_poison_en),
           .ff                 (raq_full),
           .matched            (raq_id_matched),
           .push_wcount        (push_wcount_unused),
           .pop_wcount         (raq_wcount_i), 
           .q                  (raq_q),
           .push_fe            (push_fe_unused),
           .pop_fe             (raq_empty),
           .par_err         (occap_raq_par_err)
           );

    end // block: async_raq
  endgenerate

      assign raq_rd     = ~ep_full & ~vpr_gate_raq;
      assign raq_wr     = wr & ~raq_full & ~vpr_gate_in_raq;
      assign full       = raq_full | vpr_gate_in_raq;
      assign empty      = raq_empty;
      assign id_match   = raq_id_matched;

      // output debug signals
      always @(posedge e_clk or negedge e_rst_n) begin
         if (~e_rst_n) begin
            raq_wcount  <= {(AXI_RAQD_LG2+1){1'b0}};
            raq_pop     <= 1'b0;
         end
         else begin
            raq_wcount  <= raq_wcount_i;
            raq_pop     <= raq_rd;
         end
      end
 
      
      // raq_push is replaced by TMR if OCCAP_EN=1
      DWC_ddrctl_bcm95_i
       #(
                             .TMR    (OCCAP_EN), // use of TMR is dependent on OCCAP_EN
                             .WIDTH  (1),
                             .RSTVAL (0)      // rst to 0
                           )
      U_tmr_raq_push (
                 .clk     (aclk),
                 .rst_n   (aresetn),
                 .init_n  (1'b1), // do not use INIT_N
                 .d_in    (raq_wr),
                 .d_out   (raq_push)
                 );



  //---------------------------------------------------------------------------
  // ENIF Packetizer 
  //---------------------------------------------------------------------------
  DWC_ddr_umctl2_xpi_rp_wrapper
  
    #(
      .OCCAP_EN               (OCCAP_EN),
      .CMP_REG                (OCCAP_PIPELINE_EN), // registers on inputs in comparator for pipelining
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
      .DDRCTL_LUT_ADDRMAP_EN  (DDRCTL_LUT_ADDRMAP_EN),
      .INTLVMODEW             (INTLVMODEW),
      .EXA_ACC_SUPPORT        (EXA_ACC_SUPPORT),
      .EXA_PYLD_W             (EXA_PYLD_W),  
      .EXA_MAX_LENW           (EXA_MAX_LENW),
      .EXA_MAX_SIZEW          (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW          (EXA_MAX_ADDRW),
      .RRB_THRESHOLD_EN       (RRB_THRESHOLD_EN),
      .RRB_LOCK_THRESHOLD_WIDTH (RRB_LOCK_THRESHOLD_WIDTH),
      .AXI_LENW               (AXI_LENW),
      .AXI_SIZEW              (AXI_SIZEW),
      .AXI_MAXSIZE_EXA        (AXI_MAXSIZE_EXA)
      )
  U_rp
    (
     // Outputs
     .full                               (ep_full),
     .e_addr                             (ep_addr[M_ADDRW-1:0]),
     .e_alast                            (ep_alast),
     .empty                              (ep_empty),
     .e_autopre                          (ep_autopre),
     .info                               (rp_info[RPINFOW-1:0]),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .acc_info                           (acc_info),
//spyglass enable_block W528
     .exa_acc                            (ep_exa_acc),
     .exa_acc_instr                      (ep_exa_acc_instr),
     .exa_acc_pyld                       (ep_exa_pyld),
     .exa_acc_lock                       (ep_exa_acc_lock_unused),  // not used for reads
     .beat_info                          (ep_beat_info),
     .rp_cmp_error                       (rp_cmp_error),
     .rp_cmp_error_full                  (rp_cmp_error_full),
     .rp_cmp_error_seq                   (rp_cmp_error_seq),
     .rp_cmp_poison_complete             (rp_cmp_poison_complete),
     .sbam_lead_burst                    (ep_sbam_lead_burst),
     .sbam_second_burst                  (ep_sbam_second_burst),
     .sbam_tokens_allocated              (ep_sbam_tokens_allocated),
     .bam_lead_burst                     (ep_bam_lead_burst),
     .bam_addr_offset                    (ep_bam_addr_offset),
     // Inputs
     .clk                                (e_clk),
     .rst_n                              (e_rst_n),
     .siu_bl4                            (siu_bl4),
     .siu_bl8                            (siu_bl8),
     .siu_bl16                           (siu_bl16),
     .reg_burst_rdwr                     (reg_burst_rdwr),
     .reg_ddrc_data_bus_width            (reg_ddrc_data_bus_width),
     .bg_or_bank_addrmap_mask            (bg_or_bank_addrmap_mask),
     .addr                               (addr2ep[AXI_ADDRW-1:0]),
     .alen                               (alen2ep[ENIF_LENW-1:0]),
     .split                              (ep_split),
     .short_burst                        (ep_short_burst),
     .asize                              (asize2ep[ENIF_SIZEW-1:0]),
     .alock                              (ep_alock),
     .wr                                 (ep_wr),
     .rd                                 (ep_rd),
     .autopre                            (autopre2ep),
     .next_addr_wrap_autopre             (next_addr_wrap_autopre2ep[AXI_ADDRW-1:0]),
     .next_alen_wrap_autopre             (next_alen_wrap_autopre2ep[ENIF_LENW-1:0]),

     .reg_arb_rrb_lock_threshold         (reg_arb_rrb_lock_threshold),

     .reg_arb_dch_density_ratio          (reg_arb_dch_density_ratio),
     .dch_bit                            (dch_bit),
     .e_addr_max_loc                     (e_addr_max_loc),
     .e_addr_max_m1_loc                  (e_addr_max_m1_loc),  
     .e_addr_max_loc_addrmap_mask        (e_addr_max_loc_addrmap_mask),
     .e_addr_max_m1_loc_addrmap_mask     (e_addr_max_m1_loc_addrmap_mask),

     .rp_cmp_en                          (reg_ddrc_occap_en),
     .rp_cmp_poison                      (reg_ddrc_occap_arb_cmp_poison_seq),
     .rp_cmp_poison_full                 (reg_ddrc_occap_arb_cmp_poison_parallel),
     .rp_cmp_poison_err_inj              (reg_ddrc_occap_arb_cmp_poison_err_inj),
     .exa_addr                           (raq_exa_addr),
     .exa_alen                           (raq_exa_alen),
     .exa_asize                          (raq_exa_asize)
   );
   assign pagematch_addrmap_mask_int = pagematch_addrmap_mask;
   assign ep_addr_int = ep_addr;
   assign het_pagematch_en_dca = 1'b1;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used only in dual channel configs
   assign het_pagematch_en_dcb = 1'b1;
//spyglass enable_block W528
   assign reg_ep_cs_prev_dca_par_err = 1'b0;
   assign reg_ep_cs_prev_dcb_par_err = 1'b0;

   assign ep_rd = ~rar_full;

   // occap error assign

    assign occap_cmp_error             = rp_cmp_error;
    assign occap_cmp_error_full        = rp_cmp_error_full;
    assign occap_cmp_error_seq         = rp_cmp_error_seq;
    assign occap_cmp_poison_complete   = rp_cmp_poison_complete;
   

   generate
   if (VPR_EN==1) begin: VPR_en
  //---------------------------------------------------------------------------
  // VPR support module
  //---------------------------------------------------------------------------

   wire                        raq_in_vpr, raq_out_vpr;
   wire [RQOS_TW-1:0]          raq_vpr_timeout, rar_vpr_timeout;
   wire                        raq_vpr_exp, rar_vpr_exp;
   wire                        rqos_map_timeout_zero;
   wire [RQOS_TW-1:0]          ep_timeout;
   wire                        ep_vpr_exp;
   wire                        raq_vpt_pop;
   wire                        raq_push_sync_full;

   assign rqos_map_timeout_zero = ~|rqos_map_timeout;

   DWC_ddr_umctl2_xpi_vpt
   
   #(
      .CNT_WIDTH      (RQOS_TW),
      .CNT_DEPTH      (AXI_RAQD),
      .OCCAP_EN       (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)      
   )
   U_xpi_raq_vpr
   (
      // inputs
      .e_clk               (e_clk),
      .e_rst_n             (e_rst_n),
      .push                (raq_push_vpr),
      .pop                 (raq_vpt_pop),
      .input_timeout       (rqos_map_timeout),
      .input_timeout_zero  (rqos_map_timeout_zero),
      .reg_ddrc_occap_en   (reg_ddrc_occap_en),
      // outputs
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      .counters_empty      (raq_vpr_empty),
      .counters_full       (raq_vpr_full),      
//spyglass enable_block W528
      .output_timeout_zero (raq_vpr_exp),
      .output_timeout      (raq_vpr_timeout),
      .occap_xpi_vpt_par_err (occap_raq_vpr_err)

   );

   if (USE_RAR==1) begin: RAR_en

       DWC_ddr_umctl2_xpi_vpt
       
       #(
          .CNT_WIDTH      (RQOS_TW),
          .CNT_DEPTH      (RAR_DEPTH),
          .OCCAP_EN       (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
       )
       U_xpi_rar_vpr
       (
         // inputs
          .e_clk               (e_clk),
          .e_rst_n             (e_rst_n),
          .push                (rar_push),
          .pop                 (rar_pop),
          .input_timeout       (raq_vpr_timeout),
          .input_timeout_zero  (raq_vpr_exp),
          .reg_ddrc_occap_en   (reg_ddrc_occap_en),
          // outputs
          .counters_empty      (rar_vpr_empty_unused),
          .counters_full       (rar_vpr_full_unused),
          .output_timeout_zero (rar_vpr_exp),
          .output_timeout      (rar_vpr_timeout),
          .occap_xpi_vpt_par_err (occap_rar_vpr_err)
       );

       assign ep_vpr_exp = rar_vpr_exp | raq_vpr_exp;
       assign ep_timeout = rar_vpr_timeout;

   end
   else begin: RAR_nen
         
       assign rar_vpr_empty_unused   = 1'b0;
       assign rar_vpr_full_unused    = 1'b0;
       assign ep_vpr_exp      = raq_vpr_exp;
       assign ep_timeout      = raq_vpr_timeout;

       assign occap_rar_vpr_err = 1'b0;

   end

      assign ep_post_read_qos_priority = ep_read_qos_priority;
      assign e_rqos_timeout            = ep_timeout;
      assign e_vpr_expired             = ep_vpr_exp;
      assign raq_out_vpr               = (ep_read_qos_priority == VPRW) ? 1'b1 : 1'b0;
      assign raq_in_vpr                = (read_qos_priority == VPRW) ? 1'b1 : 1'b0;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      assign rar_in_vpr                = raq_out_vpr;
      assign rar_out_vpr               = (e_rqos_priority == VPRW) ? 1'b1 : 1'b0;   
      assign raq_push_aclk             = raq_wr & ~raq_full & raq_in_vpr;        
//spyglass enable_block W528
      assign raq_vpt_pop               = raq_rd & ~raq_empty & raq_out_vpr;

      assign vpr_gate_raq              = raq_vpr_empty & raq_out_vpr;
      assign vpr_gate_in_raq           = raq_push_sync_full;

      if (AXI_SYNC==0) begin: ASYNC_push

      //--------------------------------------------------------------------------------
      //  Push Synchronizer
      //--------------------------------------------------------------------------------

         wire raq_pop_eclk_n, pop_empty, push_empty_unused, push_full, pop_full_unused;
         wire raq_push_aclk_n;
         wire uc0_unused, uc1_unused, uc2_unused, uc3_unused, uc4_unused, uc5_unused, uc6_unused, uc7_unused, uc8_unused; // unconnected signals
         wire [VPRW_PUSH_SYNC_DEPTH_LG2+1-1:0]  uc9_unused, uc10_unused; // unconnected signals
         wire [VPRW_PUSH_SYNC_DEPTH_LG2-1:0]    uc11_unused, uc12_unused; // unconnected signals
         wire [7:0] data_out_unused;

         assign raq_pop_eclk_n   = raq_vpr_full;
         assign raq_push_aclk_n  = ~raq_push_aclk;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
         assign raq_push_vpr     = ~pop_empty;
//spyglass enable_block W528

      if (OCCAP_EN==1) begin: BCM66_ATV
        DWC_ddrctl_bcm66_wae_atv
         #(
          .DEPTH           (VPRW_PUSH_SYNC_DEPTH), 
          .ADDR_WIDTH      (VPRW_PUSH_SYNC_DEPTH_LG2), 
          .COUNT_WIDTH     (VPRW_PUSH_SYNC_DEPTH_LG2+1), 
          .PUSH_AE_LVL     (PUSH_AE_LVL),
          .PUSH_AF_LVL     (PUSH_AF_LVL), 
          .POP_AE_LVL      (POP_AE_LVL), 
          .POP_AF_LVL      (POP_AF_LVL), 
          .ERR_MODE        (ERR_MODE),
          .PUSH_SYNC       (ASYNC_FIFO_N_SYNC), 
          .POP_SYNC        (ASYNC_FIFO_N_SYNC),
          .MEM_MODE        (MEM_MODE),
          .VERIF_EN        (VERIF_EN),
          .TMR_CDC         (OCCAP_EN)
        ) 
        U_bcm66_wae_atv (
          .clk_push           (aclk),
          .rst_push_n         (aresetn),
          .init_push_n        (1'b1),
          .push_req_n         (raq_push_aclk_n),
          .data_in            ('0),
          .clk_pop            (e_clk),
          .rst_pop_n          (e_rst_n),
          .init_pop_n         (1'b1),
          .pop_req_n          (raq_pop_eclk_n),
          .data_out           (data_out_unused),
           
          .push_empty         (push_empty_unused),
          .push_ae            (uc0_unused),
          .push_hf            (uc1_unused),
          .push_af            (uc2_unused),
          .push_full          (push_full),
          .push_error         (uc3_unused),
          .push_word_count    (uc9_unused),
     //spyglass disable_block W528
     //SMD: A signal or variable is set but never read
     //SJ: Keeping as it was, needed in other instances
          .we_n               (uc4_unused),
          .wr_addr            (uc11_unused),
     //spyglass enable_block W528

          .pop_empty          (pop_empty),
          .pop_ae             (uc5_unused),
          .pop_hf             (uc6_unused), 
          .pop_af             (uc7_unused),
          .pop_full           (pop_full_unused),
          .pop_error          (uc8_unused),
          .pop_word_count     (uc10_unused)
        );

     end else begin: BCM66
       
       DWC_ddrctl_bcm66_wae
        #(
          .DEPTH           (VPRW_PUSH_SYNC_DEPTH), 
          .ADDR_WIDTH      (VPRW_PUSH_SYNC_DEPTH_LG2), 
          .COUNT_WIDTH     (VPRW_PUSH_SYNC_DEPTH_LG2+1), 
          .PUSH_AE_LVL     (PUSH_AE_LVL),
          .PUSH_AF_LVL     (PUSH_AF_LVL), 
          .POP_AE_LVL      (POP_AE_LVL), 
          .POP_AF_LVL      (POP_AF_LVL), 
          .ERR_MODE        (ERR_MODE),
          .PUSH_SYNC       (ASYNC_FIFO_N_SYNC), 
          .POP_SYNC        (ASYNC_FIFO_N_SYNC),
          .MEM_MODE        (MEM_MODE),
          .VERIF_EN        (VERIF_EN)
        ) 
        U_bcm66_wae (
          .clk_push           (aclk),
          .rst_push_n         (aresetn),
          .init_push_n        (1'b1),
          .push_req_n         (raq_push_aclk_n),
          .data_in            ('0),
          .clk_pop            (e_clk),
          .rst_pop_n          (e_rst_n),
          .init_pop_n         (1'b1),
          .pop_req_n          (raq_pop_eclk_n),
          .data_out           (data_out_unused),
       
          .push_empty         (push_empty_unused),
          .push_ae            (uc0_unused),
          .push_hf            (uc1_unused),
          .push_af            (uc2_unused),
          .push_full          (push_full),
          .push_error         (uc3_unused),
          .push_word_count    (uc9_unused),
     //spyglass disable_block W528
     //SMD: A signal or variable is set but never read
     //SJ: Keeping as it was, needed in other instances
          .we_n               (uc4_unused),
          .wr_addr            (uc11_unused),
     //spyglass enable_block W528
          .pop_empty          (pop_empty),
          .pop_ae             (uc5_unused),
          .pop_hf             (uc6_unused), 
          .pop_af             (uc7_unused),
          .pop_full           (pop_full_unused),
          .pop_error          (uc8_unused),
          .pop_word_count     (uc10_unused)
        );

      end

          assign raq_push_sync_full = push_full;

`ifdef SNPS_ASSERT_ON
  //---------------------------------------------------------------------------
  //  Assertion fifo checker instance
  //---------------------------------------------------------------------------

`ifndef SYNTHESIS

  property e_wr_when_fifo_full;
    @(posedge aclk)  (push_full) |-> (!raq_push_aclk);
  endproperty  

    a_wr_when_fifo_full : assert property (e_wr_when_fifo_full)   else $display("-> %0t ERROR: Writing when async fifo full", $realtime);

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
      end
      else begin: SYNC_push

         assign raq_push_sync_full  = raq_vpr_full;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
         assign raq_push_vpr        = raq_push_aclk;
//spyglass enable_block W528

      end

`ifdef SNPS_ASSERT_ON
  //---------------------------------------------------------------------------
  //  Assertion fifo checker instance
  //---------------------------------------------------------------------------

`ifndef SYNTHESIS

    cp_vpt_full_gate_arready : cover property (@(posedge aclk) disable iff(!aresetn) vpr_gate_in_raq==1'b1);

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

   end else begin: VPR_nen
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      assign rar_in_vpr                   = 1'b0;
      assign rar_out_vpr                  = 1'b0;  
      assign raq_push_aclk                = 1'b0; 
      assign raq_vpr_empty                = 1'b0; 
      assign raq_vpr_full                 = 1'b0;  
      assign raq_push_vpr                 = 1'b0;                       
//spyglass enable_block W528
      assign rar_vpr_empty_unused         = 1'b0;
      assign rar_vpr_full_unused          = 1'b0;
      assign vpr_gate_raq                 = 1'b0;
      assign vpr_gate_in_raq              = 1'b0;
      assign e_vpr_expired                = 1'b0;
      assign e_rqos_timeout               = {RQOS_TW{1'b0}};
      assign ep_post_read_qos_priority[0] = 1'b0;
      assign ep_post_read_qos_priority[1] = ep_read_qos_priority[1];

      assign occap_raq_vpr_err            = 1'b0;
      assign occap_rar_vpr_err            = 1'b0;

   end
   endgenerate 

  //---------------------------------------------------------------------------
  // Read Address Retime
  //---------------------------------------------------------------------------
  assign e_arvalid         = ~rar_empty;
 
  assign rar_d = {ep_id,
                  ep_beat_info,
                  ep_pre_arb_order_token,
                  ep_split,
                  ep_arpagematch,
                  ep_exa_pyld,
                  ep_exa_acc,
                  ep_exa_acc_instr,
                  ep_poison,
                  ep_ocpar_err,
                  ep_user,
                  ep_autopre,
                  ep_bypass_reorder,
                  ep_ch_num,
                  ep_alast,
                  ep_info,
                  ep_qos,
                  ep_addr,
                  rp_data_channel,
                  ep_post_read_qos_priority,
                  ep_bam_addr_offset,
                  ep_bam_lead_burst,
                  ep_sbam_tokens_allocated,
                  ep_sbam_second_burst,
                  ep_sbam_lead_burst };
  
  assign {e_arid,
          beat_info,
          xpi_read_order_token,
          e_split,
          e_arpagematch,
          e_exa_pyld,
          e_exa_acc,
          e_exa_acc_instr,
          e_poison,
          e_ocpar_err,
          e_user,
          e_autopre,
          xpi_read_bypass_reorder,
          xpi_read_ch_num,
          e_arlast,
          e_arinfo,
          e_arqos,
          e_araddr,
          e_dch,
          e_rqos_priority,
          bam_addr_offset,
          bam_lead_burst,
          sbam_tokens_allocated,
          sbam_second_burst,
          sbam_lead_burst }        = rar_q;

  generate
    if (USE_RAR==1) begin: rar_en
    
      wire        rar_wr, rar_rd;

      DWC_ddr_umctl2_retime
           
        #(
            .SIZE    (RARW),
            .OCCAP_EN   (OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)            
         ) U_rar
          (
           .clk         (e_clk),    
           .rst_n       (e_rst_n),    
           .d           (rar_d),
           .wr          (rar_wr),
           .rd          (rar_rd),
           .par_en      (reg_ddrc_occap_en),
           .q           (rar_q),
           .fe          (rar_empty),
           .ff          (rar_full),
           .par_err     (occap_rar_par_err)
           );

      assign rar_wr            = ~ep_empty ;
      assign rar_rd            = e_arready ;
      
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      assign rar_push          = rar_wr & ~rar_full & rar_in_vpr;
      assign rar_pop           = rar_rd & ~rar_empty & rar_out_vpr;
//spyglass enable_block W528
      
    end // block: war_en
    else begin: rar_nen
      
      assign rar_empty        = ep_empty;
      assign rar_full         = ~e_arready;
      assign rar_q            = rar_d;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      assign rar_push         = 1'b0;
      assign rar_pop          = 1'b0;
//spyglass enable_block W528
      assign occap_rar_par_err = 1'b0;
      
    end // else: !if(USE_RAR==1)
  endgenerate

   wire [M_ADDRW-1:0] ep_addr_prev_a_nxt, ep_addr_prev_b_nxt;
   wire [M_ADDRW-1:0] ep_addr_prev_a, ep_addr_prev_b;

   generate
   if (DUAL_CHANNEL_INTERLEAVE==1 || DUAL_CHANNEL_INTERLEAVE_LP==1) begin: DUAL_dch

      reg [M_ADDRW-1:0] ep_addr_prev_dca    , ep_addr_prev_dcb;
      reg [M_ADDRW-1:0] ep_addr_prev_dca_nxt, ep_addr_prev_dcb_nxt;
      wire [M_ADDRW-1:0] ep_addr_compare_dca, ep_addr_compare_dcb;
      wire pagematch_dca, pagematch_dcb;

      assign rp_data_channel  = |(data_channel_addrmap_mask & ep_addr);

      //------------------------------------------------------------------------
      // Page match calculation
      //------------------------------------------------------------------------
      // Store the previous address
      always @(*) begin: ep_addr_prev_COMB_PROC
            if (ep_rd & rp_data_channel)
               ep_addr_prev_dcb_nxt = ep_addr_int;
            else
               ep_addr_prev_dcb_nxt = ep_addr_prev_dcb;

            if (ep_rd & ~rp_data_channel)
               ep_addr_prev_dca_nxt = ep_addr_int;
            else
               ep_addr_prev_dca_nxt = ep_addr_prev_dca;
      end

      always @(posedge e_clk, negedge e_rst_n) begin: ep_addr_prev_SEQ_PROC
         if (!e_rst_n) begin
            ep_addr_prev_dcb <= {M_ADDRW{1'b0}};
            ep_addr_prev_dca <= {M_ADDRW{1'b0}};
         end
         else begin
            ep_addr_prev_dcb <= ep_addr_prev_dcb_nxt;
            ep_addr_prev_dca <= ep_addr_prev_dca_nxt;
         end
      end



      assign ep_addr_compare_dca = ~(ep_addr_int ^ ep_addr_prev_dca);
      assign ep_addr_compare_dcb = ~(ep_addr_int ^ ep_addr_prev_dcb);

      assign pagematch_dca = &(ep_addr_compare_dca | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dca;
      assign pagematch_dcb = &(ep_addr_compare_dcb | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dcb;

      assign ep_arpagematch = (pagematch_en) ? (rp_data_channel ? pagematch_dcb : pagematch_dca) :
                                                1'b0;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      // drive signals used for occap_en protection
      assign ep_addr_prev_a     = ep_addr_prev_dca;
      assign ep_addr_prev_b     = ep_addr_prev_dcb;
      assign ep_addr_prev_a_nxt = ep_addr_prev_dca_nxt;
      assign ep_addr_prev_b_nxt = ep_addr_prev_dcb_nxt;
//spyglass enable_block W528
   end
   else begin: SINGLE_dch

      reg [M_ADDRW-1:0] ep_addr_prev; 
      reg [M_ADDRW-1:0] ep_addr_prev_nxt;
      wire [M_ADDRW-1:0] ep_addr_compare;
      wire pagematch;

      assign rp_data_channel  = 1'b0;

      //------------------------------------------------------------------------
      // Page match calculation
      //------------------------------------------------------------------------
      // Store the previous address
      always @(*) begin: ep_addr_prev_COMB_PROC
            if (ep_rd)
               ep_addr_prev_nxt = ep_addr_int;
            else
               ep_addr_prev_nxt = ep_addr_prev;

      end

      always @(posedge e_clk, negedge e_rst_n) begin: ep_addr_prev_SEQ_PROC
         if (!e_rst_n)
            ep_addr_prev <= {M_ADDRW{1'b0}};
         else
            ep_addr_prev <= ep_addr_prev_nxt;
      end


      assign ep_addr_compare = ~(ep_addr_int ^ ep_addr_prev);

      assign pagematch        = &(ep_addr_compare | ~pagematch_addrmap_mask_int) & het_pagematch_en_dca;
      assign ep_arpagematch   = (pagematch_en) ? pagematch : 1'b0;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      // drive signals used for occap_en protection
      assign ep_addr_prev_a     = ep_addr_prev;
      assign ep_addr_prev_b     = {M_ADDRW{1'b0}};
      assign ep_addr_prev_a_nxt = ep_addr_prev_nxt;
      assign ep_addr_prev_b_nxt = {M_ADDRW{1'b0}};
//spyglass enable_block W528

   end
   endgenerate

  //---------------------------------------------------------------------------
  // OCCAP_EN process
  // for control related registers on e_clk
  //---------------------------------------------------------------------------

  generate
   if (OCCAP_EN==1) begin: OCCAP_en

     
     wire [OCCAP_CTRLW-1:0] pgen_in;  
     wire [OCCAP_CTRLW-1:0] pcheck_in;  

     // 
     // wiring of pgen_in/pcheck_in
     //


     assign pgen_in    = {ep_addr_prev_b_nxt,
                          ep_addr_prev_a_nxt,
                          raq_rd,
                          raq_wcount_i}; 

     assign pcheck_in  = {ep_addr_prev_b,
                          ep_addr_prev_a,
                          raq_pop,
                          raq_wcount};


     wire [PARW-1:0]        pgen_in_par;     
     reg  [PARW-1:0]        pgen_in_par_r;     
     wire [PARW-1:0]        pcheck_par_err; 
     wire [PARW-1:0]        pgen_parity_corr_unused, pcheck_parity_corr_unused;    
     
     wire                   parity_en;
     reg                    pcheck_en;
     wire [PARW-1:0]        parity_dummy,  mask_in;
     wire                   poison_en;

     assign parity_dummy  = {PARW{1'b1}};
     assign mask_in       = {PARW{1'b1}};
     assign poison_en     = 1'b0;

     assign parity_en = reg_ddrc_occap_en;
     always @(posedge e_clk or negedge e_rst_n) begin
           if (~e_rst_n) begin
              pcheck_en <= 0;
           end
           else begin
              pcheck_en <= parity_en;
           end
        end

           
     // 
     // parity checking logic itself
     //
         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_CTRLW), 
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (pgen_in),
            .parity_en     (parity_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (pgen_in_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         always @ (posedge e_clk or negedge e_rst_n)
           if (~e_rst_n) begin
             pgen_in_par_r <= {PARW{1'b0}};
           end
           else begin
             pgen_in_par_r <= pgen_in_par;
           end


         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_CTRLW),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (pcheck_in),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (pgen_in_par_r), // parity in
            .mask_in       (mask_in),
            .parity_out    (pcheck_par_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );     
      
         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg pcheck_par_err_r;
           always @ (posedge e_clk or negedge e_rst_n) begin : pcheck_par_err_r_PROC
             if (~e_rst_n) begin
               pcheck_par_err_r <= 1'b0;
             end else begin
               pcheck_par_err_r <= |pcheck_par_err;
             end
           end

           assign occap_rd_q_ctrl_par_err = pcheck_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign occap_rd_q_ctrl_par_err = |pcheck_par_err;

         end 

         
   end else begin: OCCAP_ne
      assign occap_rd_q_ctrl_par_err = 1'b0;
  end
  endgenerate




endmodule // DWC_ddr_umctl2_xpi_read
