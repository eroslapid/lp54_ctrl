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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_read.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            XPI read                                                      *
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_read
import DWC_ddrctl_reg_pkg::*;
  #(
    parameter M_DW         = 32,  // SDRAM data width
    parameter M_DW_INT     = M_DW*2,
    parameter M_ADDRW      = 32,
    parameter PDBW_CASE    = 0,
    parameter NAB          = 2,
    parameter MEMC_BURST_LENGTH = 8,
    parameter NTOKENS      = 32,
    parameter NTOKENS_LG2  = `UMCTL_LOG2(NTOKENS),
    parameter NBEATS       = 4,
    parameter NBEATS_LG2   = 2,
    parameter BEAT_INFOW   = 4,
    parameter M_BLW        = 3,
    parameter XPI_BRW      = 3,    
    parameter UP_SIZE      = 0,
    parameter DOWN_SIZE    = 0,
    parameter AXI_ADDRW    = 32,  // AXI address width
    parameter AXI_DATAW    = 128, // AXI *data width
    parameter AXI_STRBW    = 16,  // AXI wstrb width
    parameter AXI_IDW      = 8,   // AXI ID width
    parameter AXI_LENW     = 6,   // AXI a*len width
    parameter AXI_SIZEW    = 3,   // AXI a*size width
    parameter AXI_MAXSIZE  = 4,   // AXI Maximum size
    parameter AXI_BURSTW   = 2,   // AXI a*burst width
    parameter AXI_LOCKW    = 2,   // AXI a*lock width
    parameter AXI_USERW    = 1,
    parameter AXI_CACHEW   = 4,   // AXI a*cache width
    parameter AXI_PROTW    = 3,   // AXI a*prot width
    parameter AXI_QOSW     = 4,   // AXI a*qos width
    parameter AXI_RESPW    = 2,   // AXI *resp width 
    parameter AXI_RAQD     = 4,
    parameter AXI_RAQD_LG2 = 2,
    parameter AXI_RDQD     = 8,
    parameter AXI_SYNC     = 0,   // AXI synchronous or asynchronous    
    parameter ACC_INFOW    = 2,
    parameter NUM_DATA_CHANNELS = 1,
    parameter ENIF_DATAW   = 32,
    parameter ENIF_STRBW   = 4,      
    parameter ENIF_MAXSIZE = 4,   // NIF Maximum siz
    parameter ENIF_SIZEW   = 4,
    parameter ENIF_LENW    = 4,   // NIF a*len width   
    parameter ENIF_HDATAW   = 32,
    parameter ENIF_HSTRBW   = 4,      
    parameter ENIF_HMAXSIZE = 4,   // NIF Maximum siz
    parameter ENIF_HSIZEW   = 4,
    parameter ENIF_HLENW    = 4,
    parameter ARINFOW      = 4,
    parameter RINFOW       = 5,       
    parameter RINFOW_NSA   = 5,
    parameter RPINFOW      = 4,
    parameter M_ECC        = 0,
    parameter M_SIDEBAND_ECC = 0,
    parameter M_INLINE_ECC = 0,
    parameter M_LPDDR3     = 0,
    parameter M_DDR5       = 0,
    parameter USE_RAR      = 0,
    parameter USE_INPUT_RAR     = 0,
    parameter AXI_SAR_BW   = 32,
    parameter AXI_SAR_SW   = 8,
    parameter USE_SAR      = 0,
    parameter NSAR         = 0,
    parameter MAXSIZE      = (UP_SIZE==1) ? ENIF_MAXSIZE : AXI_MAXSIZE,
    parameter SAR_MIN_ADDRW     = 26,
    parameter USE2RAQ      = 0,
    parameter RQOS_MLW     = 4,
    parameter RQOS_RW      = 2,
    parameter RQOS_TW      = 11,
    parameter VPR_EN       = 0,
    parameter VPRW_PUSH_SYNC_DEPTH        = 16,
    parameter VPRW                        = 1,
    parameter RAR_DEPTH                   = 2,
    parameter OCPAR_EN                    = 0,
    parameter OCPAR_ADDR_PAR_WIDTH        = 8,
    parameter OCPAR_NUM_BYTES             = 32,
    parameter OCPAR_NUM_BYTES_LG2         = 5,
    parameter OCPAR_SLICE_WIDTH           = 8,
    parameter OCCAP_EN                    = 0,
    parameter OCCAP_PIPELINE_EN           = 0,
    parameter OCCAP_CMP_CC                = 2,
    parameter OCCAP_CMP_AC                = 1,
    parameter USE_RPR                      = 0,
    parameter OCECC_EN                    = 0,
    parameter OCECC_GRANU                 = 64,
    parameter DUAL_CHANNEL_INTERLEAVE                   = 0,
    parameter DUAL_CHANNEL_INTERLEAVE_LP               = 0,
    parameter ASYNC_FIFO_N_SYNC           = 2,           // Number of synchronizers for async FIFOs
    parameter ASYNC_FIFO_EARLY_PUSH_STAT  = 0,
    parameter ASYNC_FIFO_EARLY_POP_STAT   = 1,   // Only applies to read data queue
    parameter EXA_ACC_SUPPORT             = 0, 
    parameter EXA_PYLD_W                  = 32,
    parameter EXA_MAX_LENW                = 12, // Worst Case Dowsnsizing is 256/8 with a AXI_LENW of 6
    parameter EXA_MAX_SIZEW               = 3,  // Maximum AXI Size is 3 bits
    parameter EXA_MAX_ADDRW               = 12,  // 12 bits for 4K Boundary
    parameter NUM_VIR_CH                  = 4,
    parameter NUM_VIR_CH_LG2              = 2, //width of channel identifier
    parameter NUM_CH                      = 4,
    parameter NUM_CH_LG2                  = 2, //width of channel identifier
    parameter STATIC_VIR_CH               = 0,
    parameter INTLVMODEW                  = 2,
    parameter ID_MAPW                     = 8,
    parameter AXI_ADDR_BOUNDARY           = 12, // Defines AXI address no crossing boundary ( default is 4k))    
    parameter ORDER_TOKENW                = 8,
    parameter READ_DATA_INTERLEAVE_EN     = 0,
    parameter DDRCTL_HET_INTERLEAVE       = 0,
    parameter DDRCTL_LUT_ADDRMAP_EN       = 0,
    parameter BCM_VERIF_EN                = 2,
    parameter RRB_LOCK_THRESHOLD_WIDTH    = 0,
    parameter RRB_THRESHOLD_EN                = 0,
    // internal bcm07 parameters
    parameter PUSH_AE_LVL                  =  2, 
    parameter PUSH_AF_LVL                  =  2,
    parameter POP_AE_LVL                   =  2,
    parameter POP_AF_LVL                   =  2,
    parameter ERR_MODE                     =  0
    )
  (
   input                      aclk,          // AXI clock
   input                      aresetn,       // AXI asynchronous reset
   input                      siu_bl4, 
   input                      siu_bl8, 
   input                      siu_bl16,
   input [XPI_BRW-1:0]        reg_burst_rdwr,
   input [1:0]                reg_ddrc_data_bus_width, //MSTR's DRAM bus width setting
   input [1:0]                reg_arba_data_bus_width, //MSTR's DRAM bus width setting
   // interface to AXI read address channel
   input [AXI_IDW-1:0]           arid,           // AXI read address ID
   input [AXI_ADDRW-1:0]         araddr,         // AXI read address
   input [AXI_LENW-1:0]          arlen,          // AXI read burst length
   input [AXI_SIZEW-1:0]         arsize,         // AXI read burst size
   input [AXI_BURSTW-1:0]        arburst,        // AXI read burst type
   input [AXI_LOCKW-1:0]         arlock,        // AXI read lock type
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Unused signal. Keeping it because it is part of the standard set of AXI signals.
   input [AXI_CACHEW-1:0]        arcache,        // AXI read cache type
   input [AXI_PROTW-1:0]         arprot,         // AXI read protection type
//spyglass enable_block W240
   input [AXI_USERW-1:0]         aruser,
   input [AXI_QOSW-1:0]          arqos,          // ENIF read address qos
   input                         arpoison,       // AXI read transaction poison
   input                         arvalid,        // AXI read address valid
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.   
   input [OCPAR_ADDR_PAR_WIDTH-1:0] arparity,
   input                         arautopre,      // AXI read auto precharge signal
//spyglass enable_block W240   
   output                        arready,        // AXI read address ready
   // interface to AXI read data channel
   output [AXI_IDW-1:0]       rid,            // AXI read ID
   output [AXI_DATAW-1:0]     rdata,          // AXI read data
   output [AXI_STRBW-1:0]     rparity, // read data parity
   output [AXI_RESPW-1:0]     rresp,          // AXI read response
   output [AXI_USERW-1:0]     ruser,
   output                     rlast,          // AXI read last
   output                     rvalid,         // AXI read valid
   input                      rready,         // AXI read ready
   // Extended Native Interface:
   input                      e_clk,          // ENIF clock
   input                      e_rst_n,        // ENIF asynchronous reset
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                      e_rst_dly,
//spyglass enable_block W240
   // ENIF Read Address channel
   output [M_ADDRW-1:0]       e_araddr_blue,  // ENIF read address
   output [AXI_IDW-1:0]       e_arid_blue,    // ENIF read address ID
   output [AXI_QOSW-1:0]      e_arqos_blue,   // ENIF read address qos
   output [RQOS_RW-1:0]       e_rqos_priority_blue,
   output [RQOS_TW-1:0]       e_rqos_timeout_blue,
   output                     e_vpr_expired_blue,
   output                     e_arpagematch_blue,  // ENIF read pagematch indication
   output                     e_arlast_blue,  // ENIF read address last
   output [ARINFOW-1:0]       e_arinfo_blue,  // ENIF read address info
   output                     e_arvalid_blue, // ENIF read address valid
   input                      e_arready_blue, // ENIF read address ready
   output                     e_split_blue,
   output                     e_poison_blue,
   output                     e_ocpar_err_blue,
   output                     e_dch_blue,
   output [AXI_USERW-1:0]     e_user_blue,
   output                     e_autopre_blue,

   output                     sbam_lead_burst_blue,
   output                     sbam_second_burst_blue,
   output [NTOKENS_LG2:0]     sbam_tokens_allocated_blue,

   output                     sbam_lead_burst_red,
   output                     sbam_second_burst_red,
   output [NTOKENS_LG2:0]     sbam_tokens_allocated_red,

   output                     bam_lead_burst_blue,
   output [AXI_MAXSIZE-1:0]   bam_addr_offset_blue,
   output                     bam_lead_burst_red,
   output [AXI_MAXSIZE-1:0]   bam_addr_offset_red,
   // ENIF Read Data Channel
   input [ENIF_DATAW-1:0]     e_rdata,        // ENIF read data
   input [ENIF_STRBW-1:0]     e_rdata_parity, // ENIF read data parity
   input [NUM_DATA_CHANNELS-1:0]                     e_rerror,       // ENIF read data error
   input [AXI_IDW-1:0]        e_rid,          // ENIF read data ID
   input [RINFOW-1:0]         e_rinfo,        // ENIF read data info
   input [AXI_USERW-1:0]      e_ruser,
   input                      e_rvalid,       // ENIF read data valid
   output                     e_rready,       // ENIF read data ready
   input                      e_rrb_rpoison,  // ENIF read transaction poison returned with read data
   input                      e_rrb_ocpar_err, // ENIF read transaction on-chip parity error returned with read data
   // ENIF Exclusive Access Info
   output                     e_exa_acc_blue,       // ENIF Exclusive Access, first packet
   output                     e_exa_acc_instr_blue, // ENIF Exclusive Access, all the packets
   output [EXA_PYLD_W-1:0]    e_exa_pyld_blue,      // ENIF Exclusive Access Payload
   input                      e_rrb_rexa_acc_instr, // ENIF Exclusive Access returned with read data (all packets)

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.

      // System Address Regions registers
   input [AXI_SAR_BW-1:0]     reg_arb_base_addr_0,
   input [AXI_SAR_SW-1:0]     reg_arb_nblocks_0,
   input [AXI_SAR_BW-1:0]     reg_arb_base_addr_1,
   input [AXI_SAR_SW-1:0]     reg_arb_nblocks_1,  
   input [AXI_SAR_BW-1:0]     reg_arb_base_addr_2,
   input [AXI_SAR_SW-1:0]     reg_arb_nblocks_2,    
   input [AXI_SAR_BW-1:0]     reg_arb_base_addr_3,

   // oc parity config
   input                            reg_arb_oc_parity_type, // @aclk select parity type: 0 even, 1 odd
   input                            reg_ddrc_oc_parity_type, // @core_clock
   input                            par_addr_slverr_en, // enable slverr response when address parity error
   input                            par_rdata_slverr_en, // enable slverr for read data parity errors
   input                            oc_addr_parity_en, // enable address parity check
   input                            oc_data_parity_en, // enable on-chip parity data check
   input [OCPAR_NUM_BYTES_LG2-1:0]  reg_ddrc_par_poison_byte_num,

   input                            reg_ddrc_ecc_type,

   // occap
   input                            reg_ddrc_occap_en,
   input                            reg_arb_occap_arb_raq_poison_en,
   input                            reg_ddrc_occap_arb_cmp_poison_seq,
   input                            reg_ddrc_occap_arb_cmp_poison_parallel,
   input                            reg_ddrc_occap_arb_cmp_poison_err_inj,
   input                            reg_arb_occap_arb_cmp_poison_seq,
   input                            reg_arb_occap_arb_cmp_poison_parallel,
   input                            reg_arb_occap_arb_cmp_poison_err_inj,

   // ocecc
   input                            ocecc_en,
   input                            ocecc_poison_en,
   input                            ocecc_poison_single,
   input                            ocecc_rdata_slverr_en,

   // axi transaction poison config
   input                            reg_ddrc_rd_poison_slverr_en,
   input                            reg_ddrc_rd_poison_intr_en,
   input                            reg_ddrc_rd_poison_intr_clr,
   output                           rd_poison_intr,
   
   // ocpar poison config
   input                            rd_poison_en,
   input                            par_rdata_err_intr_clr,
//spyglass enable_block W240


   output                           par_raddr_err_pulse,
   output                           par_rdata_err_pulse,

   output [AXI_ADDRW-1:0]           par_raddr_log, // last failing address 
   output [OCPAR_NUM_BYTES-1:0]     par_rdata_byte_log, // last failing byte

   output                           ocecc_uncorr_err,
   output                           ocecc_corr_err,

   // occap error
   output                           occap_xpi_read_a_par_err,
   output                           occap_xpi_read_c_par_err,
   output                           occap_aclk_cmp_err,
   output [OCCAP_CMP_AC-1:0]        occap_aclk_cmp_err_full,
   output [OCCAP_CMP_AC-1:0]        occap_aclk_cmp_err_seq,
   output [OCCAP_CMP_AC-1:0]        occap_aclk_cmp_poison_complete,
   output                           occap_cclk_cmp_err,
   output [OCCAP_CMP_CC-1:0]        occap_cclk_cmp_err_full,
   output [OCCAP_CMP_CC-1:0]        occap_cclk_cmp_err_seq,
   output [OCCAP_CMP_CC-1:0]        occap_cclk_cmp_poison_complete,

   input [RRB_LOCK_THRESHOLD_WIDTH-1:0] reg_arb_rrb_lock_threshold,

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   // Virtual channel mapping register 
   input                            reg_arb_bypass_reorder, // enable bypass reorder 
   input [NUM_VIR_CH*ID_MAPW-1:0]   reg_arb_id_mask,        // Virtual channels id mask 
   input [NUM_VIR_CH*ID_MAPW-1:0]   reg_arb_id_value,       // Virtual channels id value 
//spyglass enable_block W240

   // Reored buffer virtual channel 
   output [NUM_VIR_CH_LG2-1:0]      xpi_read_ch_num_blue,
   output                           xpi_read_bypass_reorder_blue,
   // Page match mask
   input [M_ADDRW-1:0]              pagematch_addrmap_mask,
   input                            pagematch_en,
   // data channel mask
   input [M_ADDRW-1:0]              data_channel_addrmap_mask,
   // bankgroup mask
   input [M_ADDRW-1:0]              bg_or_bank_addrmap_mask,  

   input [1:0]                      reg_arb_dch_density_ratio,
   input [5:0]                      dch_bit,
   input [5:0]                      e_addr_max_loc,
   input [5:0]                      e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]              e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]              e_addr_max_m1_loc_addrmap_mask,

   // QOS configuration
   input [RQOS_MLW-1:0]             rqos_map_level1,
   input [RQOS_MLW-1:0]             rqos_map_level2,
   input [RQOS_RW-1:0]              rqos_map_region0,
   input [RQOS_RW-1:0]              rqos_map_region1,
   input [RQOS_RW-1:0]              rqos_map_region2,
   input [RQOS_TW-1:0]              rqos_map_timeoutb,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [RQOS_TW-1:0]              rqos_map_timeoutr,
//spyglass enable_block W240

   // Read/write ordering
   input [ORDER_TOKENW-1:0]         pre_arb_order_token,
   output [ORDER_TOKENW-1:0]        xpi_read_order_token_blue,
   output [BEAT_INFOW-1:0]          beat_info_blue,
   input                            rrb_rd_last,
   input [NUM_CH_LG2-1:0]           rrb_ch_num,
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                            rrb_queue_type,
   input                            e_arready_red,  // ENIF read address ready   
//spyglass enable_block W240
   
   // Second channel Outputs
   output [BEAT_INFOW-1:0]      beat_info_red,
   output [ORDER_TOKENW-1:0]    xpi_read_order_token_red,
   output [NUM_VIR_CH_LG2-1:0]  xpi_read_ch_num_red,
   output                       xpi_read_bypass_reorder_red,
   output                       e_exa_acc_red,
   output                       e_exa_acc_instr_red,
   output                       e_poison_red,
   output                       e_ocpar_err_red,
   output [AXI_USERW-1:0]       e_user_red,
   output                       e_autopre_red,
   output [EXA_PYLD_W-1:0]      e_exa_pyld_red,
   output                       e_split_red,
   output [M_ADDRW-1:0]         e_araddr_red,
   output [AXI_IDW-1:0]         e_arid_red,
   output [AXI_QOSW-1:0]        e_arqos_red,
   output [RQOS_RW-1:0]         e_rqos_priority_red,
   output [RQOS_TW-1:0]         e_rqos_timeout_red,
   output                       e_vpr_expired_red,
   output                       e_arpagematch_red,
   output                       e_arlast_red,
   output [ARINFOW-1:0]         e_arinfo_red,
   output                       e_arvalid_red,
   output                       e_dch_red,
   
   output [AXI_RAQD_LG2:0]      raqb_wcount,
   output                       raqb_pop,
   output                       raqb_push,
   output [AXI_RAQD_LG2:0]      raqr_wcount,
   output                       raqr_pop,
   output                       raqr_push,
   output reg                   raq_split
   );  
  
  // configurable
  // -------------------

  localparam BYTE_POISON = ((M_INLINE_ECC == 0) || ((M_INLINE_ECC == 1) && (M_SIDEBAND_ECC == 1))); // enable per byte poison for non inline ECC configs only or for configs with INLINE_ECC and SIDEBAND_ECC
  localparam BYTE_POISON_SW = ((M_INLINE_ECC == 1) && (M_SIDEBAND_ECC == 1)); // enable software selection of per byte poison for configs with INLINE_ECC and SIDEBAND_ECC 
  localparam ENIF_IDW    = AXI_IDW;
  localparam AXI_RDQD_LG2 = `UMCTL_LOG2(AXI_RDQD); 

  localparam L_SIZEW = (UP_SIZE==1) ? ENIF_SIZEW : AXI_SIZEW;

  localparam AU_INFOW =  1+AXI_SIZEW+ENIF_MAXSIZE-AXI_MAXSIZE; // hold_first_beat + asize + addr_last
  localparam AU_INFOW_L = (UP_SIZE==1) ? AU_INFOW : 1;  

  localparam RDU_INFOW   = AXI_SIZEW+             // asize
                           1        +             // split 
                           MAXSIZE;               // addr_offset    

  localparam RDD_INFOW   = 1+  // hold_first_beat
                           ENIF_MAXSIZE-AXI_MAXSIZE +  // addr_last
                           AXI_SIZEW+                  // asize
                           1        +                  // split 
                           MAXSIZE;                    // addr_offset    

  localparam RDD_INFOW_L = (UP_SIZE==1) ? RDD_INFOW:1;
  // Read Address Queue params
  localparam RAQ_SIZEW  = L_SIZEW;
  localparam STATIC_CH_INFOW = 1+NUM_VIR_CH_LG2;
  localparam STATIC_CH_INFOW_L = (STATIC_VIR_CH==1) ? STATIC_CH_INFOW : 1;
  
  localparam AXI_MAXSIZE_EXA = (AXI_MAXSIZE == 0)?1:AXI_MAXSIZE;

  localparam RA2RW       = ((UP_SIZE==1) ? AU_INFOW : 0) +
                           ORDER_TOKENW +
                           ((STATIC_VIR_CH==1) ? STATIC_CH_INFOW : 0) + //  bypass_reorder ,ch_num
                
                           AXI_LOCKW +
                           1 + 1 + 1 + 1 + 1 + AXI_USERW + 1+
                           AXI_QOSW+
                           AXI_IDW + 
                           AXI_LENW +
                           RAQ_SIZEW +
                           AXI_ADDRW +
                           AXI_ADDRW +          // next_addr_wrap_autopre
                           AXI_LENW +            // next_alen_wrap_autopre
                           AXI_MAXSIZE_EXA +
                           AXI_LENW +
                           AXI_SIZEW;

  localparam RARW         = BEAT_INFOW +          // beat_info
                            RQOS_RW +
                            ORDER_TOKENW + 
                            1 +                  // split
                            1 +                  // pagematch
                            1 +                  // poison
                            1 +                  // ocpar_err
                            AXI_USERW +
                            1 + EXA_PYLD_W +
                            1 +                  // exa_acc_instr
                            (NUM_VIR_CH_LG2 + 1) + // ch_num, bypass_reorder 
                            1 +                  // ep_alast
                            1 +                  // data channel
                            ARINFOW +            // ep_pkt_info + size_info
                            AXI_QOSW+            // qos
                            ENIF_IDW +           // ep_aid
                            M_ADDRW +            // ep_araddr
                            1       +            // ep_autopre  
                            AXI_MAXSIZE +        // ep_bam_addr_offset
                            1 +                  // ep_bam_lead_burst
                            1 +                  // sbam_lead_burst
                            1 +                  // sbam_second_burst
                            NTOKENS_LG2 + 1;     // sbam_tokens_allocated

  localparam RDQ_DATAW = PDBW_CASE==2 ? ENIF_DATAW 
                                      : ((UP_SIZE==1) ? ENIF_DATAW: AXI_DATAW) ; //rest of the cases, including Case0
                         

  localparam RDQ_STRBW = PDBW_CASE==2 ? ENIF_STRBW
                                      : ((UP_SIZE==1) ? ENIF_STRBW: AXI_STRBW); //rest of the cases, including Case0
  
  localparam RDQW          = (RDD_INFOW_L) +                     // e_rsize_info 
                             1 +                                 // df_last
                             1 +                                 // rpoison
                             1 +                                 // ocpar_err
                             ((M_ECC>0 || M_LPDDR3==1 || M_DDR5==1) ? 1:0) + // e_rerror 
                             1 +                                 // exa_acc_instr (for all the packets)
                             AXI_IDW +                           // e_rid
                             RDQ_DATAW +                         // e_rdata
                             RDQ_STRBW +                          // e_rdata_parity
                             AXI_USERW ;                          // e_ruser

  localparam DF_NUM_CH     = (USE2RAQ==1) ? NUM_CH*2 : NUM_CH;
  localparam DF_NUM_CH_LG2 = (USE2RAQ==1) ? NUM_CH_LG2+1 : NUM_CH_LG2;
  localparam RPRW          = AXI_IDW+AXI_DATAW+AXI_STRBW+1+1+1+1+1+1+AXI_USERW; // rid,rdata,rparity,rerror,rpoison,on_chip_parity_error,ocpar_addr_err,rexa_acc,rlast,ruser


  localparam OCPAR_ADDR_SLICE_WIDTH = OCPAR_ADDR_PAR_WIDTH==1 ? AXI_ADDRW : OCPAR_SLICE_WIDTH;

  localparam SLVERR         = 2'b10;
  localparam EXOKAY         = 2'b01;
  localparam OKAY           = 2'b00;

  // use2raq collision
   localparam NO_COLLISION    = 2'b00;
   localparam WAIT_COLLISION  = 2'b01;
   localparam WAIT_FULL       = 2'b10;
   localparam SOLVE_COLLISION = 2'b11;

  // SBAM RRB enhancement
  localparam M_NB             = M_DW/8;
  localparam M_NB_LG2         = (M_NB<=1)   ? 0 :       // 8bits
                                (M_NB<=2)   ? 1 :       // 16bits
                                (M_NB<=4)   ? 2 :       // 32bits
                                (M_NB<=8)   ? 3 :       // 64bits
                                (M_NB<=16)  ? 4 : 5;    // 128bits
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire                        raq_full;      // RAQ handshake
  wire                        ws_wr,ws_rd,ws_full,ws_empty;          // WS handshake
  wire                        rd_ch_wr,rd_ch_wr_blue,rd_ch_wr_red,rd_ch_full,rd_ch_full_blue,rd_ch_full_red,rd_ch_empty_unused,rd_ch_empty_blue;    // EP/FIFO handshake   
  wire                        df_wr,df_rd,df_full,df_empty;          // DF handshake    

  wire                        du_wr,du_rd,du_full,du_empty;          // DU handshake     
  wire                        au_wr,au_rd,au_full_unused,au_empty_unused; // AU handshake
  wire                        dd_wr,dd_rd,dd_full,dd_empty;          // DD handshake  
  wire                        rdq_wr,rdq_rd,rdq_full,rdq_empty;      // RDQ handshake

  wire [RA2RW-1:0]             ra2r_d;
  wire [RA2RW-1:0]             ra2r_q;


  wire                        raq_mux_select; // select the address queue based on the QoS mapping
  wire [RQOS_RW-1:0]          read_qos_priority; // read transaction priority base on qos registers and rqos input value
  
  wire [AXI_ADDRW-1:0]        ra2r_addr;
  wire [RAQ_SIZEW-1:0]        ra2r_asize;
  wire [AXI_LENW-1:0]         ra2r_alen;
  wire [AXI_IDW-1:0]          ra2r_id;      // AXI read address ID
  wire [AXI_QOSW-1:0]         ra2r_qos;     // AXI read QOS
  wire                        ra2r_skip;
  wire                        ra2r_split;
  wire                        ra2r_short_burst;
  wire                        ra2r_poison;
  wire                        ra2r_ocpar_err;
  wire [AXI_LOCKW-1:0]        ra2r_lock;
  wire                        ra2r_bypass_reorder;
  wire [NUM_VIR_CH_LG2-1:0]   ra2r_ch_num;
  wire [ORDER_TOKENW-1:0]     ra2r_pre_arb_order_token;
  wire [AU_INFOW_L-1:0]       ra2r_info;
  wire [AXI_USERW-1:0]        ra2r_user;
  wire                        ra2r_autopre;
  wire [AXI_ADDRW-1:0]        ra2r_next_addr_wrap_autopre;
  wire [AXI_LENW-1:0]         ra2r_next_alen_wrap_autopre;

  wire [AXI_ADDRW-1:0]        addr_ra2r;    // AXI read address
  wire [AXI_ADDRW-1:0]        addr_sar;
  wire [AXI_ADDRW-1:0]        next_addr_wrap_autopre_sar;
  wire [RAQ_SIZEW-1:0]        asize_ra2r;   // AXI read burst size
  wire [AXI_LENW-1:0]         alen_ra2r;     // AXI read burst length
  wire [AXI_USERW-1:0]        user_ra2r; 
  wire                        autopre_ra2r; // AXI autopre
  wire [AXI_ADDRW-1:0]        next_addr_wrap_autopre_ra2r;
  wire [AXI_LENW-1:0]         next_alen_wrap_autopre_ra2r;
  wire [AXI_IDW-1:0]          id_ra2r;      // AXI read address ID
       
  wire [AXI_QOSW-1:0]         qos_ra2r;     // AXI read QOS      
 
  wire                        split_ra2r;
  wire                        skip_ra2r;
  wire                        poison_ra2r;
  wire                        ocpar_err_ra2r;
  wire [AXI_LOCKW-1:0]        lock_ra2r;
  wire [AU_INFOW_L-1:0]       info_ra2r;
  wire [ORDER_TOKENW-1:0]     order_token_ra2r;
  
  wire [AXI_ADDRW-1:0]        ws_addr;       // AXI first INCR burst address
  wire [AXI_LENW-1:0]         ws_alen;       // AXI first INCR burst length
  wire                        ws_skip;      // Single burst
  wire                        ws_hold_first_beat;
   
  wire                        ws_split;      // Single burst
  wire                        ws_poison;
  wire                        ws_ocpar_err;
  wire [AXI_IDW-1:0]          ws_id;
  wire [AXI_QOSW-1:0]         ws_qos;
  wire [AXI_SIZEW-1:0]        ws_asize;
  wire [AXI_LOCKW-1:0]        ws_lock;       
  wire [AXI_USERW-1:0]        ws_user;
  wire                        ws_autopre;
  wire [AXI_ADDRW-1:0]        ws_next_addr_wrap_autopre;
  wire [AXI_LENW-1:0]         ws_next_alen_wrap_autopre;
  
  wire [RDQW-1:0]             rdq_d;
  wire [RDQW-1:0]             rdq_q;
  wire [AXI_RDQD_LG2:0]       rdq_wcount_unused;   
  wire                        rdq_last;
  wire                        last_rdq;  
  wire                        rdq_rerror;
  wire [RDQ_DATAW-1:0]        rdq_rdata;
  wire [RDQ_DATAW-1:0]        data_rdq;  
  wire [RDQ_STRBW-1:0]        parity_rdq;
  wire [RDQ_STRBW-1:0]        rdq_parity;
  wire [RDD_INFOW_L-1:0]      rdq_info;
  wire [RDD_INFOW_L-1:0]      info_rdq;
  wire [AXI_IDW-1:0]          e_rid_rdq;
  wire [AXI_USERW-1:0]        e_ruser_rdq, rdq_ruser;
  wire                        e_rerror_rdq;
  wire                        e_rrb_rexa_acc_instr_rdq;
  wire                        e_rrb_rpoison_rdq;
  wire                        e_rrb_ocpar_err_rdq;

  wire [AXI_DATAW-1:0]        rdata_tmp;
  wire [AXI_STRBW-1:0]        parity_tmp;

  wire [AXI_ADDRW-1:0]        au_addr;
  wire [AXI_LENW-1:0]         au_alen;
  wire [ENIF_SIZEW-1:0]       au_asize;
  wire [AXI_LOCKW-1:0]        au_alock;     
  wire [AXI_ADDRW-1:0]        au_next_addr_wrap_autopre;
  wire [AXI_LENW-1:0]         au_next_alen_wrap_autopre;

  wire [AXI_DATAW-1:0]        du_data;
  wire [AXI_STRBW-1:0]        du_parity;
  wire                        du_last;
  wire                        du_rerror;
  wire                        df_rerror;
  wire                        du_rexa_acc_instr;
  wire                        du_rpoison;
  wire                        du_ocpar_err;
  
  wire [AXI_DATAW-1:0]        dd_data;
  wire [AXI_STRBW-1:0]        dd_parity;
  wire                        dd_error;
  wire                        dd_last;

  wire                        arwrap;        // burst type is WRAP
  wire                        rerror;

  wire [AU_INFOW_L-1:0]       au_info;
  wire                        df_last,df_last_pkt;
  wire [RDD_INFOW-1:0]        info_rdd;
  wire [RDU_INFOW-1:0]        info_rdu;
  wire [RPINFOW-1:0]          info_df;

  wire                        rdq_rexa_acc_instr;
  wire                        rexa_acc_w;

  wire                        rdq_rpoison;

  wire                        read_transaction_poison, rd_transaction_poison_slverr;
  reg                         rd_transaction_poison_intr; 


  wire                        rdq_ocpar_err;
  wire                        on_chip_parity_read_addr_error;
  wire                        on_chip_parity_read_data_error;
  wire                        on_chip_parity_error;
  wire                        on_chip_parity_error_i;

  wire [AXI_STRBW-1:0]        rparity_gen;
  wire [AXI_STRBW-1:0]        rparity_i;

  wire [ORDER_TOKENW-1:0]     ws_order_token;
  wire [MAXSIZE-1:0]          df_addr_offset;
  wire                        df_split;

  wire                        short_burst_ra2r;
 
  wire                        ws_short_burst;

  wire                        id_match_blue, id_match_red;
  wire [STATIC_CH_INFOW_L-1:0] static_ch_info;
  wire [STATIC_CH_INFOW_L-1:0] ra2r_static_ch_info; 
  wire [STATIC_CH_INFOW_L-1:0] static_ch_info_ra2r;

  wire [AXI_ADDRW-1:0]                  parity_addr;
  wire [AXI_DATAW-1:0]                  parity_data;
  wire                                  parity_addr_error;
  wire                                  parity_data_error_w;

  wire [DF_NUM_CH_LG2-1:0]             df_ch_num;

  wire                         poison_valid;

  wire                        reg_arb_poison_slverr_en;

  wire                        id_collision;

  wire [RPRW-1:0]            rpr_d, rpr_q;
  

  wire [AXI_IDW-1:0]       rid_i;
  wire [AXI_DATAW-1:0]     rdata_i;
  wire                     rerror_i;
  wire                     rpoison;
  wire                     rlast_i, rready_i, rvalid_i,ocpar_addr_err;

  wire                     occap_xpi_read_blue_err;
  wire                     occap_xpi_read_red_err;
  wire                     occap_xpi_rdq_err;
  wire                     occap_xpi_df_par_err;
  wire                     occap_xpi_ra2r_par_err, occap_xpi_rpr_par_err;
  wire                     occap_xpi_rdd_par_err;

  wire                     occap_red_cmp_error;
  wire                     occap_red_cmp_error_full, occap_red_cmp_error_seq, occap_red_cmp_poison_complete;
  wire                     occap_blue_cmp_error;
  wire                     occap_blue_cmp_error_full, occap_blue_cmp_error_seq, occap_blue_cmp_poison_complete;
  wire                     occap_rd_q_cmp_error;
  wire                     occap_rd_q_cmp_error_full, occap_rd_q_cmp_error_seq, occap_rd_q_cmp_poison_complete;

  wire                     ws_cmp_error, ws_cmp_error_full, ws_cmp_error_seq, ws_cmp_poison_complete;
  wire                     au_cmp_error, au_cmp_error_full, au_cmp_error_seq, au_cmp_poison_complete;
  
  wire [AXI_MAXSIZE_EXA-1:0]            ra2r_exa_addr;
  wire [AXI_LENW-1:0]                   ra2r_exa_alen;
  wire [AXI_SIZEW-1:0]                  ra2r_exa_asize;

  //---------------------------------------------------------------------------
  assign arwrap  = (arburst == 2'b10) ? 1'b1:1'b0;

  assign occap_xpi_read_c_par_err = occap_xpi_read_blue_err | occap_xpi_read_red_err | occap_xpi_df_par_err;

  assign occap_xpi_read_a_par_err = occap_xpi_ra2r_par_err | occap_xpi_rpr_par_err | occap_xpi_rdq_err | occap_xpi_rdd_par_err;

  //--------------------------------------------------------------------------------
  //  Virtual channel ID mapper
  //--------------------------------------------------------------------------------
  generate
    if (STATIC_VIR_CH==1) begin: static_ch_map
      wire [NUM_VIR_CH_LG2-1:0]   ch_map_ch_num;
      wire                        ch_map_bypass_reorder;

      DWC_ddr_umctl2_xpi_ch_map
      
        
        #(// Parameters
          .NCH                                (NUM_VIR_CH),
          .NCH_LG2                            (NUM_VIR_CH_LG2),
          .ID_MAPW                            (ID_MAPW),
          .IDW                                (AXI_IDW),
          .DOWN_SIZE                          (DOWN_SIZE)
          )
      U_ch_map
        (
         // Outputs
         .bypass_reorder                      (ch_map_bypass_reorder),
         .ch_num                              (ch_map_ch_num[NUM_VIR_CH_LG2-1:0]),
         // Inputs
         .id                                  (ws_id[AXI_IDW-1:0]),
         .reg_arb_bypass_reorder              (reg_arb_bypass_reorder),
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((NUM_VIR_CH * ID_MAPW) - 1)' found in module 'DWC_ddr_umctl2_xpi_read'
//SJ: This coding style is acceptable and there is no plan to change it.
         .reg_arb_id_mask                     (reg_arb_id_mask[NUM_VIR_CH*ID_MAPW-1:0]),
         .reg_arb_id_value                    (reg_arb_id_value[NUM_VIR_CH*ID_MAPW-1:0])
//spyglass enable_block SelfDeterminedExpr-ML
         );
 
     assign static_ch_info = {ch_map_bypass_reorder,ch_map_ch_num};
     assign {ra2r_bypass_reorder,ra2r_ch_num} = ra2r_static_ch_info;
  
   end // block: static_ch_map
    else begin: dynamic_ch_map
      assign static_ch_info = 1'b0;
      assign ra2r_bypass_reorder = 1'b0;
      assign ra2r_ch_num = {NUM_VIR_CH_LG2{1'b0}};
     end
  endgenerate
  
  //---------------------------------------------------------------------------
  // Read Address Retime
  //---------------------------------------------------------------------------

  generate
   if (USE_INPUT_RAR==1) begin: raq_retime
      wire raq_rd, raq_wr;
      wire raq_empty;
   
      DWC_ddr_umctl2_retime
      
      
        #(
        .SIZE     (RA2RW),
        .OCCAP_EN (OCCAP_EN),
        .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)
      )
       U_ra2r
          (
           .clk         (aclk),    
           .rst_n       (aresetn),    
           .d           (ra2r_d),
           .wr          (raq_wr),
           .rd          (raq_rd),
           .par_en      (reg_ddrc_occap_en),
           .q           (ra2r_q),
           .fe          (raq_empty),
           .ff          (raq_full),
           .par_err     (occap_xpi_ra2r_par_err)
          );

      assign raq_wr            = ~ws_empty & ~raq_full;
      assign raq_rd            = ~(rd_ch_full | id_collision);
      assign rd_ch_wr          = ~raq_empty;

   end 
   else begin: raq_nretime
      
      if (USE2RAQ==1) begin: Dual_q

         wire [RA2RW-1:0] ra2r_r;
         wire [1:0] collision_state; 
         reg  [1:0] collision_state_nxt;
         reg push_ra2r_reg;
         reg raq_full_r, rd_ch_wr_r;

         wire occap_par_poison_en = 1'b0; // poison always disabled for this register
         wire ra2r_reg_en;

         assign ra2r_reg_en = (rd_ch_wr & ~rd_ch_full & id_collision) | (rd_ch_wr & rd_ch_full);

         DWC_ddr_umctl2_par_reg
         
         #(
            .DW      (RA2RW),
            .OCCAP   (OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
            .REG_EN  (1),
            .SL_W    (8)
         )
         U_ra2r_r
         (
            .clk        (aclk),
            .rst_n      (aresetn),
            .data_in    (ra2r_d),
            .reg_set    (ra2r_reg_en),
            .parity_en  (reg_ddrc_occap_en),
            .poison_en  (occap_par_poison_en),
            .data_out   (ra2r_r),
            .parity_err (occap_xpi_ra2r_par_err)
         );


         // collision_state is replaced by TMR if OCCAP_EN=1
         DWC_ddrctl_bcm95_i
          #(
                             .TMR    (OCCAP_EN), // use of TMR is dependent on OCCAP_EN
                             .WIDTH  (2),        // width of collsion_state
                             .RSTVAL (NO_COLLISION)         // rst to 0
                           )
         U_tmr_collision_state (
                 .clk     (aclk),
                 .rst_n   (aresetn),
                 .init_n  (1'b1), // do not use INIT_N
                 .d_in    (collision_state_nxt),
                 .d_out   (collision_state)
                 );




         always @(*) begin: Comb_proc
            collision_state_nxt  = collision_state;
            push_ra2r_reg        = 1'b0;
            raq_full_r           = 1'b0;
            rd_ch_wr_r           = ~ws_empty;
            case (collision_state)
               NO_COLLISION: begin
                           if (rd_ch_wr & ~rd_ch_full & id_collision) collision_state_nxt = WAIT_COLLISION;
                           else if (rd_ch_wr & rd_ch_full) collision_state_nxt = WAIT_FULL;
                           end
               WAIT_COLLISION: begin
                           if (~id_collision) collision_state_nxt  = SOLVE_COLLISION;
                           raq_full_r     = 1'b1;
                           rd_ch_wr_r     = 1'b0;
                           push_ra2r_reg  = 1'b1;
                           end
               WAIT_FULL: begin
                           if (~rd_ch_full & ~id_collision) collision_state_nxt  = SOLVE_COLLISION;
                           raq_full_r     = 1'b1;
                           rd_ch_wr_r     = 1'b0;
                           push_ra2r_reg  = 1'b1;
                           end
               default: begin // SOLVE_COLLISION
                           push_ra2r_reg        = 1'b1;
                           raq_full_r           = 1'b1;
                           rd_ch_wr_r           = 1'b1;
                           collision_state_nxt  = NO_COLLISION;
                           end
            endcase
         end

         assign ra2r_q           = push_ra2r_reg ? ra2r_r : ra2r_d;
         assign raq_full         = raq_full_r;
         assign rd_ch_wr         = rd_ch_wr_r;

      end
      else begin: Single_q
      
         assign ra2r_q           = ra2r_d;
         assign raq_full         = rd_ch_full;
         assign rd_ch_wr         = ~ws_empty;
         assign occap_xpi_ra2r_par_err  = 1'b0;

      end

   end
  endgenerate

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((((((((1 + 1) + 1) + 1) + 1) + AXI_USERW) + 1) + AXI_ADDRW) + AXI_LENW)' found in module 'DWC_ddr_umctl2_xpi_read'
//SJ: This coding style is acceptable and there is no plan to change it.

  //---------------------------------------------------------------------------
  // Read Address 2 Retime
  //---------------------------------------------------------------------------
   field_packer13
   
    # (AXI_ADDRW,
       RAQ_SIZEW,
       AXI_LENW,
       AXI_IDW,
       AXI_QOSW,
       1+1+1+1+1+AXI_USERW+1+AXI_ADDRW+AXI_LENW,
       AXI_LOCKW,
       (STATIC_VIR_CH==1) ? STATIC_CH_INFOW : 0,
       ORDER_TOKENW, 
       (UP_SIZE==1) ? AU_INFOW : 0,
       AXI_MAXSIZE_EXA,
       AXI_LENW,
       AXI_SIZEW)
  ra2r_field_packer
    (// Outputs
     .out0                      (ra2r_addr),
     .out1                      (ra2r_asize),
     .out2                      (ra2r_alen),
     .out3                      (ra2r_id),
     .out4                      (ra2r_qos),
     .out5                      ({ra2r_skip,ra2r_split, ra2r_short_burst, ra2r_poison, ra2r_ocpar_err,ra2r_user,ra2r_autopre,ra2r_next_addr_wrap_autopre,ra2r_next_alen_wrap_autopre}), 
     .out6                      (ra2r_lock),
     //spyglass disable_block W528
     //SMD: A signal or variable is set but never read
     //SJ: Used in generate block
     .out7                      (ra2r_static_ch_info),
     //spyglass enable_block W528
     .out8                      (ra2r_pre_arb_order_token),
     .out9                      (ra2r_info),
     .out10                     (ra2r_exa_addr),
     .out11                     (ra2r_exa_alen),
     .out12                     (ra2r_exa_asize),
     .pack_out                  (ra2r_d),
     // Inputs
     .in0                       (addr_ra2r),
     .in1                       (asize_ra2r),
     .in2                       (alen_ra2r),
     .in3                       (id_ra2r),
     .in4                       (qos_ra2r),
     .in5                       ({skip_ra2r,split_ra2r,short_burst_ra2r, poison_ra2r, ocpar_err_ra2r,user_ra2r,autopre_ra2r,next_addr_wrap_autopre_ra2r,next_alen_wrap_autopre_ra2r}), 
     .in6                       (lock_ra2r),
     .in7                       (static_ch_info_ra2r),
     .in8                       (order_token_ra2r),
     .in9                       (info_ra2r),
     .in10                      (ws_addr[AXI_MAXSIZE_EXA-1:0]),
     .in11                      (ws_alen),
     .in12                      (ws_asize),
     .pack_in                   (ra2r_q));
//spyglass enable_block SelfDeterminedExpr-ML
  
  assign arready            = ~ws_full;
  assign id_ra2r            = ws_id;
  assign qos_ra2r           = ws_qos;
  assign poison_ra2r        = ws_poison;
  assign ocpar_err_ra2r     = ws_ocpar_err;
  assign split_ra2r         = ws_split;
  assign skip_ra2r          = ws_skip;
  assign short_burst_ra2r   = ws_short_burst;
  assign user_ra2r          = ws_user;
  assign autopre_ra2r       = ws_autopre;
  
  assign order_token_ra2r            = ws_order_token;
  assign static_ch_info_ra2r = static_ch_info;  
  
  generate 
    if (UP_SIZE==1) begin :raq_usize   
      assign addr_sar   = au_addr; // AXI_ADDRW
      assign next_addr_wrap_autopre_sar = au_next_addr_wrap_autopre;
      assign asize_ra2r = au_asize; // RAQ_SIZEW
      assign alen_ra2r  = au_alen; // AXI_LENW
      assign next_alen_wrap_autopre_ra2r = au_next_alen_wrap_autopre;
      assign lock_ra2r  = au_alock;    
      assign info_ra2r  = au_info;
    end
    else begin: waq_eqsize
      assign addr_sar   = ws_addr; //AXI_ADDRW
      assign next_addr_wrap_autopre_sar = ws_next_addr_wrap_autopre;
      assign asize_ra2r = ws_asize; //RAQ_SIZEW
      assign alen_ra2r  = ws_alen; // AXI_LENW
      assign next_alen_wrap_autopre_ra2r = ws_next_alen_wrap_autopre;
      assign lock_ra2r  = ws_lock;
      assign info_ra2r  = 1'b0;
    end
  endgenerate
  
  assign            info_df = e_rinfo[RPINFOW-1:0];

  generate
    
    if (DOWN_SIZE==1)  begin: down_size
 //spyglass disable_block W164a
 //SMD: 'info_rdu' width 9 is less than RHS: '{e_rinfo[(RINFOW_NSA - 1):RPINFOW]  ,df_split ,df_addr_offset[(AXI_MAXSIZE - 1):0] }' width 10 in assignment
 //SJ: Width mismatch happens as UPSIZE and DOWNSIZE can co-exist as part of bug 7175. Need to review this.
      assign info_rdu = {e_rinfo[RINFOW_NSA-1:RPINFOW],df_split,df_addr_offset[AXI_MAXSIZE-1:0]};
 //spyglass enable_block W164a

      //---------------------------------------------------------------------------
      // DATA DownSizer 
      //---------------------------------------------------------------------------
      
      DWC_ddr_umctl2_xpi_rdu
      
      
        #(
          .AXI_DATAW       (AXI_DATAW),
          .AXI_STRBW       (AXI_STRBW),
          .AXI_MAXSIZE     (AXI_MAXSIZE),
          .AXI_SIZEW       (RAQ_SIZEW),
          .PDBW_CASE       (PDBW_CASE),
          .M_DW            (M_DW),
          .ENIF_DATAW      (ENIF_DATAW),
          .ENIF_STRBW      (ENIF_STRBW),
          .ENIF_MAXSIZE    (ENIF_MAXSIZE),
          .ENIF_SIZEW      (ENIF_SIZEW),
          .INFOW           (RDU_INFOW)
          )
      U_rdu (
             // Outputs
             .data_up            (du_data), 
             .parity_up          (du_parity),
             .last_up            (du_last),     
             .empty              (du_empty),
             .full               (du_full),
             //spyglass disable_block W528
             //SMD: Variable set but not read
             //SJ: Used in generate block in only one branch of the 'if' condition
             .rerror_up          (du_rerror),     
             //spyglass enable_block W528
             .rexa_acc_instr_up  (du_rexa_acc_instr),
             .rpoison_up         (du_rpoison),
             .ocpar_err_up       (du_ocpar_err),
             // Inputs
             .clk             (e_clk),
             .rst_n           (e_rst_n), 
             .rst_dly         (e_rst_dly),
             .wr              (du_wr), 
             .rd              (du_rd),
             .data            (e_rdata),
             .parity          (e_rdata_parity),
             .parity_type     (reg_ddrc_oc_parity_type),
             .last            (df_last),
             .reg_ddrc_data_bus_width (reg_ddrc_data_bus_width),
             .last_pkt        (df_last_pkt),
             .rerror          (df_rerror),      
             .rexa_acc_instr  (e_rrb_rexa_acc_instr),
             .rpoison         (e_rrb_rpoison),
             .ocpar_err       (e_rrb_ocpar_err),
             .info            (info_rdu)
             );
      assign                        du_wr = ~df_empty;
      assign                        du_rd = ~rdq_full;
      
    end // block: down_size
    else begin: not_down_size
    end

    //---------------------------------------------------------------------------
    // Address UPSizer 
    //---------------------------------------------------------------------------
    if (UP_SIZE==1)  begin: up_size
      wire sq_wr_unused;
      assign info_rdd = {e_rinfo[RINFOW_NSA-1:RPINFOW],df_split,df_addr_offset};
      
      DWC_ddr_umctl2_xpi_au_wrapper
      
        #(
          .OCCAP_EN        (OCCAP_EN),
          .CMP_REG         (OCCAP_PIPELINE_EN), // registers on inputs in comparator for pipelining
          .WR              (0),
          .AXI_DATAW       (AXI_DATAW),
          .AXI_STRBW       (AXI_STRBW),
          .AXI_MAXSIZE     (AXI_MAXSIZE),
          .AXI_SIZEW       (AXI_SIZEW),
          .AXI_ADDRW       (AXI_ADDRW),
          .AXI_LENW        (AXI_LENW),
          .AXI_LOCKW       (AXI_LOCKW),
          .PDBW_CASE       (PDBW_CASE),

          .ENIF_DATAW      (ENIF_DATAW),
          .ENIF_STRBW      (ENIF_STRBW),
          .ENIF_MAXSIZE    (ENIF_MAXSIZE),
          .ENIF_SIZEW      (ENIF_SIZEW),
          .INFOW           (AU_INFOW_L)
          )
      U_au (
            // Outputs
            .empty      (au_empty_unused), 
            .full       (au_full_unused), 
            .addr_up    (au_addr), 
            .alen_up    (au_alen),  
            .asize_up   (au_asize),
            .alock_up   (au_alock),
            .info       (au_info),
            .sq_wr      (sq_wr_unused), 
            .next_addr_wrap_autopre_up(au_next_addr_wrap_autopre),
            .next_alen_wrap_autopre_up(au_next_alen_wrap_autopre),
            .au_cmp_error             (au_cmp_error),
            .au_cmp_error_full        (au_cmp_error_full),
            .au_cmp_error_seq         (au_cmp_error_seq),
            .au_cmp_poison_complete   (au_cmp_poison_complete),
            // Inputs
            .clk        (aclk),
            .rst_n      (aresetn),
            .wr         (au_wr),
            .skip       (1'b0),
            .split      (ws_split),
            .short_wrap (ws_short_burst),
            .reg_ddrc_data_bus_width  (reg_arba_data_bus_width),
            .hold_first_beat (ws_hold_first_beat),
            .next_addr_wrap_autopre(ws_next_addr_wrap_autopre),
            .next_alen_wrap_autopre(ws_next_alen_wrap_autopre),
            .rd         (au_rd), 
            .addr       (ws_addr), 
            .alen       (ws_alen),  
            .asize      (ws_asize), 
            .alock      (ws_lock), 
            .sq_full    (1'b0),
            .au_cmp_en          (reg_ddrc_occap_en),
            .au_cmp_poison      (reg_arb_occap_arb_cmp_poison_seq),
            .au_cmp_poison_full (reg_arb_occap_arb_cmp_poison_parallel),
            .au_cmp_poison_err_inj (reg_arb_occap_arb_cmp_poison_err_inj)
            );
      
      assign au_wr = ~ws_empty;
      assign au_rd = ~raq_full;
      DWC_ddr_umctl2_xpi_rdd
      
      
        #(
          .AXI_DATAW       (AXI_DATAW),
          .AXI_STRBW       (AXI_STRBW),
          .AXI_MAXSIZE     (AXI_MAXSIZE),
          .AXI_SIZEW       (AXI_SIZEW),
          .AXI_IDW         (AXI_IDW),
          .PDBW_CASE       (PDBW_CASE),
          .ENIF_DATAW      (ENIF_DATAW),
          .ENIF_STRBW      (ENIF_STRBW),
          .ENIF_MAXSIZE    (ENIF_MAXSIZE),
          .ENIF_SIZEW      (ENIF_SIZEW),
          .INFOW           (RDD_INFOW),
          .OCCAP_EN        (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
          )
      U_rdd (
             // Outputs
             .data_down    (dd_data), 
             .parity_down  (dd_parity),
             .error_down   (dd_error),
             .last_down    (dd_last),     
             .empty        (dd_empty),
             .full         (dd_full),
             .occap_xpi_rdd_par_err (occap_xpi_rdd_par_err),
             // Inputs
             .clk          (aclk),
             .rst_n        (aresetn), 
             .id           (rid_i),
             .wr           (dd_wr), 
             .rd           (dd_rd),
             .data         (rdq_rdata),
             .parity       (rdq_parity),
             .error        (rdq_rerror),
             .last         (rdq_last),
             .info         (rdq_info),
             .reg_ddrc_data_bus_width  (reg_arba_data_bus_width),
             .reg_ddrc_occap_en (reg_ddrc_occap_en)
             );
      assign dd_wr = ~rdq_empty;
      assign dd_rd = rready_i;

    end
    else begin: n_up_size
      
      assign au_cmp_error           = 1'b0;
      assign au_cmp_error_full      = 1'b0;
      assign au_cmp_error_seq       = 1'b0;
      assign au_cmp_poison_complete = 1'b1;

      assign occap_xpi_rdd_par_err  = 1'b0;

    end
   
  endgenerate


  //---------------------------------------------------------------------------
  // Address parity check
  //---------------------------------------------------------------------------
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
   assign parity_addr   = araddr; // check the input address
   assign poison_valid  = rready_i & rvalid_i;  
//spyglass enable_block W528
   assign parity_data   = rdata_tmp;

   assign rpr_d = {rid_i,parity_data,rparity_gen,rerror_i,rdq_rpoison,on_chip_parity_error_i,rdq_ocpar_err,rdq_ruser,rdq_rexa_acc_instr,rlast_i};
   assign {rid,rdata_i,rparity_i,rerror,rpoison,on_chip_parity_error,ocpar_addr_err,ruser,rexa_acc_w,rlast} = rpr_q;

   generate
      if (OCPAR_EN == 1 || OCECC_EN == 1) begin: PAR_OR_ECC_en
      
        reg [AXI_ADDRW-1:0]        last_addr_parity_err; // SNPS_TMR
        reg                        par_raddr_err_reg; 
        
        wire [OCPAR_ADDR_PAR_WIDTH-1:0] arparity_in; 
        wire                            enable_raddr_par_check; 
        wire [OCPAR_ADDR_PAR_WIDTH-1:0] addr_par_mask_in, parity_addr_error_vec; 
        wire [OCPAR_ADDR_PAR_WIDTH-1:0] radd_parity_corr_unused;
        
        assign arparity_in            = arparity;
        assign enable_raddr_par_check = oc_addr_parity_en & arready & arvalid;  
        assign addr_par_mask_in       = {OCPAR_ADDR_PAR_WIDTH{1'b1}};
        
        DWC_ddr_umctl2_ocpar_calc
        
         #(
            .DW      (AXI_ADDRW),
            .CALC    (0), // parity check
            .PAR_DW  (OCPAR_ADDR_PAR_WIDTH),
            .SL_W    (OCPAR_ADDR_SLICE_WIDTH)
         )
         U_radd_par_check
         (
            .data_in       (parity_addr),
            .parity_en     (enable_raddr_par_check),
            .parity_type   (reg_arb_oc_parity_type),
            .parity_in     (arparity_in), // parity in
            .mask_in       (addr_par_mask_in),
            .parity_out    (parity_addr_error_vec), // parity error
            .parity_corr   (radd_parity_corr_unused) // not used
         );

         assign parity_addr_error = |parity_addr_error_vec;
        
        // parity interrupt
        always @(posedge aclk or negedge aresetn) begin: OCPAR_intr
           if (~aresetn) begin
              par_raddr_err_reg    <= 1'b0;
              last_addr_parity_err <= {AXI_ADDRW{1'b0}};
           end
           else begin
              par_raddr_err_reg <= parity_addr_error;
              if (parity_addr_error) begin
                 last_addr_parity_err <= parity_addr;
              end
           end
        end
       
        assign on_chip_parity_read_addr_error   = rdq_ocpar_err & par_addr_slverr_en; 
        assign par_raddr_err_pulse    = par_raddr_err_reg;
        assign par_raddr_log          = last_addr_parity_err;
      
        assign on_chip_parity_error_i = on_chip_parity_read_addr_error | on_chip_parity_read_data_error;
        
      end // PAR_OR_ECC_en
   endgenerate

   generate
      if (OCPAR_EN == 1) begin: PAR_en

         reg [OCPAR_NUM_BYTES-1:0]  last_rdata_byte_error; // SNPS_TMR
         wire [OCPAR_NUM_BYTES-1:0] last_rdata_byte_error_w;
         reg                        par_rdata_err_reg;

         
         wire [AXI_STRBW-1:0]       rparity_in;
         wire [AXI_STRBW-1:0]       rparity_poisoned, rparity_poisoned_w_unused;

         wire                       enable_rdata_poison;
         wire                       enable_rdata_par_check;
         wire [AXI_STRBW-1:0]       data_par_mask_in;
         
         wire [AXI_STRBW-1:0]       parity_data_error;
         reg                        parity_data_error_r;
         wire [AXI_STRBW-1:0]       rdata_parity_corr_unused;

         reg [OCPAR_NUM_BYTES_LG2-1:0]  par_poison_byte_num; // SNPS_TMR

         assign rparity_in             = parity_tmp;
         assign enable_rdata_poison    = rd_poison_en & rvalid_i;
         assign enable_rdata_par_check = oc_data_parity_en & rvalid_i;
         
         assign data_par_mask_in       = {AXI_STRBW{1'b1}}; // all data coming from the dataRAM is valid

         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (AXI_DATAW),
            .CALC    (0), // parity check
            .PAR_DW  (AXI_STRBW),
            .SL_W    (OCPAR_SLICE_WIDTH)
         )
         U_rdata_par_check
         (
            .data_in       (parity_data),
            .parity_en     (enable_rdata_par_check),
            .parity_type   (reg_arb_oc_parity_type),
            .parity_in     (rparity_in), // parity in
            .mask_in       (data_par_mask_in),
            .parity_out    (parity_data_error), // parity error
            .parity_corr   (rdata_parity_corr_unused) // not used
         );

         ocpar_poison
         
         #(
            .DATA_WIDTH    (AXI_DATAW),
            .PAR_WIDTH     (AXI_STRBW),
            .DATA_PATH_POISON (0), // does not differ for INLINE_ECC case
            .DATA_PATH_POISON_SW (0), // does not differ for INLINE_ECC case
            .BYTE_WIDTH    (OCPAR_SLICE_WIDTH),
            .BYTE_POISON   (BYTE_POISON), 
            .BYTE_POISON_SW(BYTE_POISON_SW), 
            .NUM_BYTES     (OCPAR_NUM_BYTES),
            .NUM_BYTES_LG2 (OCPAR_NUM_BYTES_LG2))
         U_poison_rdata
         (
            .clk           (aclk),
            .rst_n         (aresetn),
            .corrupt_twice (1'b0), // this is used only for IECC write path
            .data_valid    (poison_valid),
            .data_valid_w  (1'b0),
            .parity_in     (rparity_in),
            .parity_in_w   (rparity_in),
            .byte_num      (par_poison_byte_num),
            .dpp_support_en(1'b0), // not used
            .pbp_support_en(~reg_ddrc_ecc_type), // per byte poisoning only if IE
            .poison_en     (enable_rdata_poison),
            .poison_ie_type(1'b0),
            .poison_ie_clr (par_rdata_err_intr_clr),
            .parity_out    (rparity_poisoned),
            .parity_out_w  (rparity_poisoned_w_unused));

         // sample config register (quasi-dynamic)
         always @(posedge aclk or negedge aresetn) begin
            if (~aresetn) begin
               par_poison_byte_num <= {OCPAR_NUM_BYTES_LG2{1'b0}};
            end
            else begin
               par_poison_byte_num <= reg_ddrc_par_poison_byte_num;
            end
         end

         // parity interrupt
         always @(posedge aclk or negedge aresetn) begin: OCPAR_intr
            if (~aresetn) begin
               par_rdata_err_reg    <= 1'b0;
               last_rdata_byte_error<= {OCPAR_NUM_BYTES{1'b0}};
            end
            else begin
               par_rdata_err_reg <= parity_data_error_w;
               if (parity_data_error_w) begin
                  last_rdata_byte_error   <= last_rdata_byte_error_w;
               end
            end
         end

         if (AXI_STRBW<OCPAR_NUM_BYTES) begin: AXI_strb_lt_reg
            // pad zeros
            assign last_rdata_byte_error_w[OCPAR_NUM_BYTES-1:0] = {{(OCPAR_NUM_BYTES-AXI_STRBW){1'b0}},parity_data_error[AXI_STRBW-1:0]};
         end
         else begin: AXI_strb_gt_reg
            // cut the log
            assign last_rdata_byte_error_w[OCPAR_NUM_BYTES-1:0] = parity_data_error[OCPAR_NUM_BYTES-1:0];
         end

         //spyglass disable_block W415a
         //SMD: Signal parity_data_error_r is being assigned multiple times in same always block. 
         //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
         always @(*) begin: ERR_gen
            integer j;
            parity_data_error_r = 0;
            for (j=0; j<AXI_STRBW; j=j+1) begin
               if (parity_data_error[j] == 1'b1) parity_data_error_r = 1'b1; // can't use or reduction, since data read can contain Xs. need to explicitly look for 1s in the error signal
            end
         end
         //spyglass enable_block W415a

         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in generate block
         assign on_chip_parity_read_data_error   = parity_data_error_w & par_rdata_slverr_en;
         assign parity_data_error_w    = parity_data_error_r;
         //spyglass enable_block W528        
         assign par_rdata_err_pulse    = par_rdata_err_reg;
         assign rparity_gen            = (rdq_ocpar_err) ? {AXI_STRBW{reg_arb_oc_parity_type}} : rparity_poisoned;
         assign par_rdata_byte_log     = last_rdata_byte_error;
         assign ocecc_corr_err         = 1'b0;
         assign ocecc_uncorr_err       = 1'b0;

      end
      else if (OCECC_EN==1) begin: ECC_en

         wire [AXI_STRBW-1:0] ecc_out;

         wire [AXI_DATAW-1:0]             parity_data_corr_unused;
         wire [AXI_DATAW/OCECC_GRANU-1:0] ocecc_dec_err_byte_unused;
         
         wire ocecc_corr_err_int;
         wire ocecc_uncorr_err_int;

         wire ocecc_data_valid;

         assign ocecc_data_valid = rvalid_i & ocecc_en;

         ocecc_dec
         
         #(
            .DW      (AXI_DATAW),
            .GRANU   (OCECC_GRANU),
            .EW      (AXI_STRBW)
         )
         echeck_xpi_rd_out
         (
            .data_in       (parity_data),
            .ecc_in        (parity_tmp),
            .data_valid    (ocecc_data_valid),
            .fec_en        (1'b0), // not used
            .corr_err      (ocecc_corr_err_int),
            .uncorr_err    (ocecc_uncorr_err_int),
            .err_byte      (ocecc_dec_err_byte_unused), // not used
            .corr_data     (parity_data_corr_unused) // not used
         );

         ocecc_enc
          
         #(
            .DW      (AXI_DATAW),
            .GRANU   (OCECC_GRANU),
            .EW      (AXI_STRBW)
         )
         egen_xpi_rd_out
         (
            .clk           (aclk),
            .rstn          (aresetn),
            .data_in       (parity_data),
            .data_valid    (ocecc_data_valid),
            .poison_en     (ocecc_poison_en),
            .poison_single (ocecc_poison_single),
            .poison_bnum   (5'd0),
            .ecc_out       (ecc_out)
         );

         assign rparity_gen                     = ecc_out;
         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in generate block
         assign parity_data_error_w             = 1'b0;
         assign on_chip_parity_read_data_error  = (ocecc_corr_err | ocecc_uncorr_err) & ocecc_rdata_slverr_en;         
         //spyglass enable_block W528
         assign par_rdata_err_pulse             = 1'b0;
         assign par_rdata_byte_log              = {OCPAR_NUM_BYTES{1'b0}};
         assign ocecc_corr_err                  = ocecc_corr_err_int & (~ocpar_addr_err);
         assign ocecc_uncorr_err                = ocecc_uncorr_err_int & (~ocpar_addr_err);

      end
      else begin: ECC_PAR_nen
   
         assign rparity_gen                     = {AXI_STRBW{1'b0}};
         assign on_chip_parity_error_i          = 1'b0;
         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in generate block
         assign parity_data_error_w             = 1'b0;
         assign on_chip_parity_read_addr_error  = 1'b0;
         assign on_chip_parity_read_data_error  = 1'b0;                  
         //spyglass enable_block W528
         assign parity_addr_error               = 1'b0;
         assign par_raddr_err_pulse             = 1'b0;
         assign par_rdata_err_pulse             = 1'b0; 
         assign par_raddr_log                   = {AXI_ADDRW{1'b0}};
         assign par_rdata_byte_log              = {OCPAR_NUM_BYTES{1'b0}};
         assign ocecc_corr_err                  = 1'b0;
         assign ocecc_uncorr_err                = 1'b0;

      end

      if (USE_RPR==1) begin: RPR_en

         wire rpr_empty, rpr_full, rpr_rd, rpr_wr;
         assign rpr_rd     = rready;
         assign rpr_wr     = rvalid_i;
         assign rvalid     = ~rpr_empty;
         assign rready_i   = ~rpr_full;
      

         DWC_ddr_umctl2_retime
               
         #(
            .SIZE    (RPRW),
            .OCCAP_EN   (OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)            
         ) U_rpr
         (
            .clk         (aclk),    
            .rst_n       (aresetn),    
            .d           (rpr_d),
            .wr          (rpr_wr),
            .rd          (rpr_rd),
            .par_en      (reg_ddrc_occap_en),
            .q           (rpr_q),
            .fe          (rpr_empty),
            .ff          (rpr_full),
            .par_err     (occap_xpi_rpr_par_err)
         );

         

      end
      else begin: RPR_nen

         assign rpr_q                  = rpr_d;
         assign rready_i               = rready;
         assign rvalid                 = rvalid_i;
         assign occap_xpi_rpr_par_err  = 1'b0;

      end
   endgenerate


  //---------------------------------------------------------------------------
  // QoS mapper
  //---------------------------------------------------------------------------

   DWC_ddr_umctl2_xpi_qos
   
    #(
      .USE2AQ     (USE2RAQ),
      .AXI_QOSW   (AXI_QOSW),
      .QOS_MLW    (RQOS_MLW),
      .QOS_RW     (RQOS_RW)
    )
    U_qos_map
    (
      // inputs
      .qos_map_level1                     (rqos_map_level1),
      .qos_map_level2                     (rqos_map_level2),
      .qos_map_region0                    (rqos_map_region0),
      .qos_map_region1                    (rqos_map_region1),
      .qos_map_region2                    (rqos_map_region2),
      .qos_value                          (ra2r_qos),
      // outputs
      .qos_priority                       (read_qos_priority),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      .aq_mux_select                      (raq_mux_select)
//spyglass enable_block W528
    );

  //---------------------------------------------------------------------------
  // BLUE Address Queue (packetizer, retime, pagematch calc)
  //---------------------------------------------------------------------------  

  DWC_ddr_umctl2_xpi_rd_q
  
   #(
      .M_DW                (M_DW),
      .M_DW_INT            (M_DW_INT),
      .M_ADDRW             (M_ADDRW),
      .NAB                 (NAB),
      .PDBW_CASE           (PDBW_CASE),
      .MEMC_BURST_LENGTH   (MEMC_BURST_LENGTH),
      .NBEATS              (NBEATS),
      .NBEATS_LG2          (NBEATS_LG2),
      .NTOKENS             (NTOKENS),  
      .NTOKENS_LG2         (NTOKENS_LG2),
      .BEAT_INFOW          (BEAT_INFOW),
      .XPI_BRW             (XPI_BRW),
      .AXI_ADDRW           (AXI_ADDRW),
      .ENIF_DATAW          (ENIF_DATAW),
      .ENIF_LENW           (ENIF_LENW),
      .ENIF_SIZEW          (ENIF_SIZEW),
      .ENIF_LOCKW          (AXI_LOCKW),
      .ENIF_STRBW          (ENIF_STRBW),
      .ENIF_MAXSIZE        (ENIF_MAXSIZE),  
      .ENIF_HDATAW         (ENIF_HDATAW),
      .ENIF_HLENW          (ENIF_HLENW),
      .ENIF_HSIZEW         (ENIF_HSIZEW),
      .ENIF_HSTRBW         (ENIF_HSTRBW),
      .ENIF_HMAXSIZE       (ENIF_HMAXSIZE),
      .MAXSIZE             (MAXSIZE),     
      .RPINFOW             (RPINFOW),  
      .ARINFOW             (ARINFOW),
      .UP_SIZE             (UP_SIZE),
      .DOWN_SIZE           (DOWN_SIZE),     
      .AXI_ADDR_BOUNDARY   (AXI_ADDR_BOUNDARY),
      .USE_RAR             (USE_RAR),
      .RARW                (RARW),
      .USE_RAQ             (USE2RAQ),
      .AXI_SIZEW           (AXI_SIZEW),
      .AU_INFOW_L          (AU_INFOW_L),
      .AXI_RAQD            (AXI_RAQD),
      .AXI_RAQD_LG2        (AXI_RAQD_LG2),
      .NUM_VIR_CH_LG2      (NUM_VIR_CH_LG2),
      .AXI_QOSW            (AXI_QOSW),
      .AXI_IDW             (AXI_IDW),
      .AXI_SYNC            (AXI_SYNC),
      .RAQ_SIZEW           (RAQ_SIZEW),
      .AU_INFOW            (AU_INFOW),
      .AXI_USERW           (AXI_USERW),
      .ASYNC_FIFO_N_SYNC   (ASYNC_FIFO_N_SYNC),
      .ORDER_TOKENW        (ORDER_TOKENW),
      .AXI_LOCKW           (AXI_LOCKW),
      .AXI_LENW            (AXI_LENW),
      .AXI_DATAW           (AXI_DATAW),
      .AXI_STRBW           (AXI_STRBW),
      .AXI_MAXSIZE         (AXI_MAXSIZE),
      .ACC_INFOW           (ACC_INFOW),
      .RQOS_RW             (RQOS_RW),
      .VPR_EN              (VPR_EN),
      .VPRW_PUSH_SYNC_DEPTH   (VPRW_PUSH_SYNC_DEPTH),
      .VPRW                (VPRW),
      .RRB_THRESHOLD_EN        (RRB_THRESHOLD_EN),
      .RRB_LOCK_THRESHOLD_WIDTH     (RRB_LOCK_THRESHOLD_WIDTH),
      .DUAL_CHANNEL_INTERLEAVE           (DUAL_CHANNEL_INTERLEAVE),
      .DUAL_CHANNEL_INTERLEAVE_LP       (DUAL_CHANNEL_INTERLEAVE_LP),
      .DDRCTL_HET_INTERLEAVE (DDRCTL_HET_INTERLEAVE),
      .DDRCTL_LUT_ADDRMAP_EN (DDRCTL_LUT_ADDRMAP_EN),
      .OCCAP_EN            (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .OCCAP_CMP_CC        (OCCAP_CMP_CC),
      .RAR_DEPTH           (RAR_DEPTH),
      .USE2RAQ             (USE2RAQ),
      .RQOS_TW             (RQOS_TW),
      .EXA_ACC_SUPPORT     (EXA_ACC_SUPPORT),
      .EXA_PYLD_W          (EXA_PYLD_W),  
      .INTLVMODEW          (INTLVMODEW),
      .EXA_MAX_LENW        (EXA_MAX_LENW),
      .EXA_MAX_SIZEW       (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW       (EXA_MAX_ADDRW),
      .BCM_VERIF_EN        (BCM_VERIF_EN),
      .ASYNC_FIFO_EARLY_PUSH_STAT(ASYNC_FIFO_EARLY_PUSH_STAT),
      .ASYNC_FIFO_EARLY_POP_STAT (ASYNC_FIFO_EARLY_POP_STAT),
      .PUSH_AE_LVL         (PUSH_AE_LVL),
      .PUSH_AF_LVL         (PUSH_AF_LVL),
      .POP_AE_LVL          (POP_AE_LVL),
      .POP_AF_LVL          (POP_AF_LVL),
      .ERR_MODE            (ERR_MODE),
      .AXI_MAXSIZE_EXA     (AXI_MAXSIZE_EXA))
     U_blue_rd_q
      (
       // inputs
       .aclk                      (aclk),
       .aresetn                   (aresetn),
       .e_clk                     (e_clk),
       .e_rst_n                   (e_rst_n),
       .siu_bl16                  (siu_bl16),
       .siu_bl8                   (siu_bl8),
       .siu_bl4                   (siu_bl4), 
       .reg_burst_rdwr            (reg_burst_rdwr),
       .reg_ddrc_data_bus_width   (reg_ddrc_data_bus_width),
       .addr                      (ra2r_addr),
       .alen                      (ra2r_alen),
       .asize                     (ra2r_asize),
       .split                     (ra2r_split),
       .short_burst               (ra2r_short_burst),
       .lock                      (ra2r_lock),
       .skip                      (ra2r_skip),
       .wr                        (rd_ch_wr_blue),
       .raq_pre_arb_order_token   (ra2r_pre_arb_order_token),
       .raq_bypass_reorder        (ra2r_bypass_reorder),
       .raq_ch_num                (ra2r_ch_num),
       .raq_qos                   (ra2r_qos),
       .raq_id                    (ra2r_id),
       .raq_poison                (ra2r_poison),
       .raq_ocpar_err             (ra2r_ocpar_err),
       .raq_info                  (ra2r_info),
       .raq_user                  (ra2r_user),
       .raq_autopre               (ra2r_autopre),
       .raq_next_addr_wrap_autopre(ra2r_next_addr_wrap_autopre),
       .raq_next_alen_wrap_autopre(ra2r_next_alen_wrap_autopre), 
       .read_qos_priority         (read_qos_priority),
       .rqos_map_timeout          (rqos_map_timeoutb),
       .pagematch_addrmap_mask    (pagematch_addrmap_mask),
       .pagematch_en              (pagematch_en),
       .data_channel_addrmap_mask (data_channel_addrmap_mask),
       .bg_or_bank_addrmap_mask   (bg_or_bank_addrmap_mask),

       .reg_arb_rrb_lock_threshold(reg_arb_rrb_lock_threshold),
       .reg_arb_dch_density_ratio (reg_arb_dch_density_ratio),
       .dch_bit                            (dch_bit),
       .e_addr_max_loc                     (e_addr_max_loc),
       .e_addr_max_m1_loc                  (e_addr_max_m1_loc),  
       .e_addr_max_loc_addrmap_mask        (e_addr_max_loc_addrmap_mask),
       .e_addr_max_m1_loc_addrmap_mask     (e_addr_max_m1_loc_addrmap_mask),

       .e_arready                 (e_arready_blue),
       .reg_ddrc_occap_en                       (reg_ddrc_occap_en),
       .reg_arb_occap_arb_raq_poison_en        (reg_arb_occap_arb_raq_poison_en),
       .reg_ddrc_occap_arb_cmp_poison_seq        (reg_ddrc_occap_arb_cmp_poison_seq),
       .reg_ddrc_occap_arb_cmp_poison_parallel   (reg_ddrc_occap_arb_cmp_poison_parallel),
       .reg_ddrc_occap_arb_cmp_poison_err_inj    (reg_ddrc_occap_arb_cmp_poison_err_inj),
       .exa_addr                                 (ra2r_exa_addr),
       .exa_alen                                 (ra2r_exa_alen),
       .exa_asize                                (ra2r_exa_asize),
       // outputs
       .full                      (rd_ch_full_blue), 
       .empty                     (rd_ch_empty_blue),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
       .id_match                  (id_match_blue),
//spyglass enable_block W528
       .beat_info                 (beat_info_blue),
       .xpi_read_order_token      (xpi_read_order_token_blue), 
       .xpi_read_ch_num           (xpi_read_ch_num_blue),
       .xpi_read_bypass_reorder   (xpi_read_bypass_reorder_blue),
       .e_exa_acc                 (e_exa_acc_blue),
       .e_exa_acc_instr           (e_exa_acc_instr_blue), 
       .e_poison                  (e_poison_blue),
       .e_ocpar_err               (e_ocpar_err_blue),
       .e_user                    (e_user_blue),
       .e_autopre                 (e_autopre_blue),
       .e_exa_pyld                (e_exa_pyld_blue), 
       .e_split                   (e_split_blue),
       .e_araddr                  (e_araddr_blue),
       .e_arid                    (e_arid_blue),
       .e_arqos                   (e_arqos_blue), 
       .e_rqos_priority           (e_rqos_priority_blue),
       .e_rqos_timeout            (e_rqos_timeout_blue),
       .e_vpr_expired             (e_vpr_expired_blue),
       .occap_xpi_read_par_err    (occap_xpi_read_blue_err),
       .e_arpagematch             (e_arpagematch_blue),
       .e_arlast                  (e_arlast_blue),
       .e_arinfo                  (e_arinfo_blue),
       .e_arvalid                 (e_arvalid_blue),
       .e_dch                     (e_dch_blue),
       .sbam_lead_burst           (sbam_lead_burst_blue),
       .sbam_second_burst         (sbam_second_burst_blue),
       .sbam_tokens_allocated     (sbam_tokens_allocated_blue),
       .bam_lead_burst            (bam_lead_burst_blue),
       .bam_addr_offset           (bam_addr_offset_blue),
       .raq_wcount                (raqb_wcount),
       .raq_pop                   (raqb_pop),
       .raq_push                  (raqb_push),
       .occap_cmp_error           (occap_blue_cmp_error),
       .occap_cmp_error_full      (occap_blue_cmp_error_full),
       .occap_cmp_error_seq       (occap_blue_cmp_error_seq),
       .occap_cmp_poison_complete (occap_blue_cmp_poison_complete)
       );

generate
   if (USE2RAQ==1) begin: dual_rd_q

   // specific red signals
   wire  rd_ch_empty_red;

   // collision signal
   wire rd_ch_wr_i;

   assign rd_ch_wr_i = (id_collision | rd_ch_full) ? 1'b0 : rd_ch_wr;

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block

   // outputs mux
   assign rd_ch_full       =  (raq_mux_select)  ? rd_ch_full_red : 
                                                  rd_ch_full_blue;

   assign rd_ch_empty_unused =  (raq_mux_select)  ? rd_ch_empty_red : 
                                                  rd_ch_empty_blue;

   // inputs demux
   assign rd_ch_wr_red     = (raq_mux_select) ? rd_ch_wr_i : 1'b0;
   assign rd_ch_wr_blue    = (raq_mux_select) ? 1'b0     : rd_ch_wr_i;
//spyglass enable_block W528

  //---------------------------------------------------------------------------
  // RED Address Queue (packetizer, retime, pagematch calc)
  //---------------------------------------------------------------------------  

  DWC_ddr_umctl2_xpi_rd_q
  
   #(
      .M_DW                (M_DW),
      .M_DW_INT            (M_DW_INT),
      .M_ADDRW             (M_ADDRW),
      .NAB                 (NAB),
      .PDBW_CASE           (PDBW_CASE),
      .MEMC_BURST_LENGTH   (MEMC_BURST_LENGTH),
      .NBEATS              (NBEATS),
      .NBEATS_LG2          (NBEATS_LG2),
      .NTOKENS             (NTOKENS),  
      .NTOKENS_LG2         (NTOKENS_LG2),
      .BEAT_INFOW          (BEAT_INFOW),
      .XPI_BRW             (XPI_BRW),
      .AXI_ADDRW           (AXI_ADDRW),
      .ENIF_DATAW          (ENIF_DATAW),
      .ENIF_LENW           (ENIF_LENW),
      .ENIF_SIZEW          (ENIF_SIZEW),
      .ENIF_LOCKW          (AXI_LOCKW),
      .ENIF_STRBW          (ENIF_STRBW),
      .ENIF_MAXSIZE        (ENIF_MAXSIZE),     
      .ENIF_HDATAW         (ENIF_HDATAW),
      .ENIF_HLENW          (ENIF_HLENW),
      .ENIF_HSIZEW         (ENIF_HSIZEW),
      .ENIF_HSTRBW         (ENIF_HSTRBW),
      .ENIF_HMAXSIZE       (ENIF_HMAXSIZE),
      .MAXSIZE             (MAXSIZE),     
      .RPINFOW             (RPINFOW),  
      .ARINFOW             (ARINFOW),
      .UP_SIZE             (UP_SIZE),
      .DOWN_SIZE           (DOWN_SIZE),     
      .AXI_ADDR_BOUNDARY   (AXI_ADDR_BOUNDARY),
      .USE_RAR             (USE_RAR),
      .RARW                (RARW),
      .USE_RAQ             (USE2RAQ),
      .AXI_SIZEW           (AXI_SIZEW),
      .AU_INFOW_L          (AU_INFOW_L),
      .AXI_RAQD            (AXI_RAQD),
      .AXI_RAQD_LG2        (AXI_RAQD_LG2),
      .NUM_VIR_CH_LG2      (NUM_VIR_CH_LG2),
      .AXI_QOSW            (AXI_QOSW),
      .AXI_IDW             (AXI_IDW),
      .AXI_SYNC            (AXI_SYNC),
      .RAQ_SIZEW           (RAQ_SIZEW),
      .AU_INFOW            (AU_INFOW),
      .AXI_USERW           (AXI_USERW),
      .ASYNC_FIFO_N_SYNC   (ASYNC_FIFO_N_SYNC),
      .ORDER_TOKENW        (ORDER_TOKENW),
      .AXI_LOCKW           (AXI_LOCKW),
      .AXI_LENW            (AXI_LENW),
      .AXI_DATAW           (AXI_DATAW),
      .AXI_STRBW           (AXI_STRBW),
      .AXI_MAXSIZE         (AXI_MAXSIZE),
      .ACC_INFOW           (ACC_INFOW),
      .RQOS_RW             (RQOS_RW),
      .USE2RAQ             (USE2RAQ),
      .RQOS_TW             (RQOS_TW),
      .DUAL_CHANNEL_INTERLEAVE           (DUAL_CHANNEL_INTERLEAVE),
      .DUAL_CHANNEL_INTERLEAVE_LP       (DUAL_CHANNEL_INTERLEAVE_LP),
      .DDRCTL_HET_INTERLEAVE (DDRCTL_HET_INTERLEAVE),
      .DDRCTL_LUT_ADDRMAP_EN (DDRCTL_LUT_ADDRMAP_EN),
      .OCCAP_EN            (OCCAP_EN),
      .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN),
      .OCCAP_CMP_CC        (OCCAP_CMP_CC),
      .VPR_EN              (VPR_EN),
      .VPRW_PUSH_SYNC_DEPTH   (VPRW_PUSH_SYNC_DEPTH),
      .VPRW                (VPRW),
      .RRB_THRESHOLD_EN    (RRB_THRESHOLD_EN),
      .RRB_LOCK_THRESHOLD_WIDTH (RRB_LOCK_THRESHOLD_WIDTH),
      .RAR_DEPTH           (RAR_DEPTH),
      .EXA_ACC_SUPPORT     (EXA_ACC_SUPPORT),
      .EXA_PYLD_W          (EXA_PYLD_W),  
      .EXA_MAX_LENW        (EXA_MAX_LENW),
      .EXA_MAX_SIZEW       (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW       (EXA_MAX_ADDRW),
      .INTLVMODEW          (INTLVMODEW),
      .BCM_VERIF_EN        (BCM_VERIF_EN),
      .ASYNC_FIFO_EARLY_PUSH_STAT(ASYNC_FIFO_EARLY_PUSH_STAT),
      .ASYNC_FIFO_EARLY_POP_STAT (ASYNC_FIFO_EARLY_POP_STAT),
      .PUSH_AE_LVL         (PUSH_AE_LVL),
      .PUSH_AF_LVL         (PUSH_AF_LVL),
      .POP_AE_LVL          (POP_AE_LVL),
      .POP_AF_LVL          (POP_AF_LVL),
      .ERR_MODE            (ERR_MODE),
      .AXI_MAXSIZE_EXA     (AXI_MAXSIZE_EXA))
    U_red_rd_q
       (
       // inputs
       .aclk                      (aclk),
       .aresetn                   (aresetn),
       .e_clk                     (e_clk),
       .e_rst_n                   (e_rst_n),
       .siu_bl16                  (siu_bl16),
       .siu_bl8                   (siu_bl8),
       .siu_bl4                   (siu_bl4), 
       .reg_burst_rdwr            (reg_burst_rdwr),
       .reg_ddrc_data_bus_width  (reg_ddrc_data_bus_width),  
       .addr                      (ra2r_addr),
       .alen                      (ra2r_alen),
       .asize                     (ra2r_asize),
       .split                     (ra2r_split),
       .short_burst               (ra2r_short_burst),
       .lock                      (ra2r_lock),
       .skip                      (ra2r_skip),
       .wr                        (rd_ch_wr_red),
       .raq_pre_arb_order_token   (ra2r_pre_arb_order_token),
       .raq_bypass_reorder        (ra2r_bypass_reorder),
       .raq_ch_num                (ra2r_ch_num),
       .raq_qos                   (ra2r_qos),
       .raq_poison                (ra2r_poison),
       .raq_ocpar_err             (ra2r_ocpar_err),
       .raq_id                    (ra2r_id),
       .raq_info                  (ra2r_info),
       .raq_user                  (ra2r_user),
       .raq_autopre               (ra2r_autopre),
       .raq_next_addr_wrap_autopre(ra2r_next_addr_wrap_autopre),
       .raq_next_alen_wrap_autopre(ra2r_next_alen_wrap_autopre), 
       .read_qos_priority         (read_qos_priority),
       .rqos_map_timeout          (rqos_map_timeoutr),
       .pagematch_addrmap_mask    (pagematch_addrmap_mask),
       .pagematch_en              (pagematch_en),
       .data_channel_addrmap_mask (data_channel_addrmap_mask),
       .bg_or_bank_addrmap_mask   (bg_or_bank_addrmap_mask),

       .reg_arb_rrb_lock_threshold(reg_arb_rrb_lock_threshold),
       .reg_arb_dch_density_ratio (reg_arb_dch_density_ratio),
       .dch_bit                            (dch_bit),
       .e_addr_max_loc                     (e_addr_max_loc),
       .e_addr_max_m1_loc                  (e_addr_max_m1_loc),  
       .e_addr_max_loc_addrmap_mask        (e_addr_max_loc_addrmap_mask),
       .e_addr_max_m1_loc_addrmap_mask     (e_addr_max_m1_loc_addrmap_mask),

       .e_arready                 (e_arready_red),
       .reg_ddrc_occap_en                       (reg_ddrc_occap_en),
       .reg_arb_occap_arb_raq_poison_en        (reg_arb_occap_arb_raq_poison_en),
       .reg_ddrc_occap_arb_cmp_poison_seq        (reg_ddrc_occap_arb_cmp_poison_seq),
       .reg_ddrc_occap_arb_cmp_poison_parallel   (reg_ddrc_occap_arb_cmp_poison_parallel),
       .reg_ddrc_occap_arb_cmp_poison_err_inj    (reg_ddrc_occap_arb_cmp_poison_err_inj),
       .exa_addr                                 (ra2r_exa_addr),
       .exa_alen                                 (ra2r_exa_alen),
       .exa_asize                                (ra2r_exa_asize),
       // outputs
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
       .full                      (rd_ch_full_red),
       .empty                     (rd_ch_empty_red),
       .id_match                  (id_match_red),
//spyglass enable_block W528
       .beat_info                 (beat_info_red),
       .xpi_read_order_token      (xpi_read_order_token_red),
       .xpi_read_ch_num           (xpi_read_ch_num_red),
       .xpi_read_bypass_reorder   (xpi_read_bypass_reorder_red),
       .e_exa_acc                 (e_exa_acc_red),
       .e_exa_acc_instr           (e_exa_acc_instr_red),
       .e_poison                  (e_poison_red),
       .e_ocpar_err               (e_ocpar_err_red),
       .e_user                    (e_user_red),
       .e_autopre                 (e_autopre_red),
       .e_exa_pyld                (e_exa_pyld_red),
       .e_split                   (e_split_red),
       .e_araddr                  (e_araddr_red),
       .e_arid                    (e_arid_red),
       .e_arqos                   (e_arqos_red),
       .e_rqos_priority           (e_rqos_priority_red),
       .e_rqos_timeout            (e_rqos_timeout_red),
       .e_vpr_expired             (e_vpr_expired_red),
       .occap_xpi_read_par_err    (occap_xpi_read_red_err),
       .e_arpagematch             (e_arpagematch_red),
       .e_arlast                  (e_arlast_red),
       .e_arinfo                  (e_arinfo_red),
       .e_arvalid                 (e_arvalid_red),
       .e_dch                     (e_dch_red),
       .sbam_lead_burst           (sbam_lead_burst_red),
       .sbam_second_burst         (sbam_second_burst_red),
       .sbam_tokens_allocated     (sbam_tokens_allocated_red),
       .bam_lead_burst            (bam_lead_burst_red),
       .bam_addr_offset           (bam_addr_offset_red),
       .raq_wcount                (raqr_wcount),
       .raq_pop                   (raqr_pop),
       .raq_push                  (raqr_push),
       .occap_cmp_error           (occap_red_cmp_error),
       .occap_cmp_error_full      (occap_red_cmp_error_full),
       .occap_cmp_error_seq       (occap_red_cmp_error_seq),
       .occap_cmp_poison_complete (occap_red_cmp_poison_complete)
       );

  //---------------------------------------------------------------------------
  // IDs collision detection
  //---------------------------------------------------------------------------
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      assign id_collision = (raq_mux_select) ? id_match_blue : id_match_red;
//spyglass enable_block W528

   end else begin: single_rd_q

       assign   beat_info_red                 = {(BEAT_INFOW){1'b0}};
       assign   xpi_read_order_token_red      = {(ORDER_TOKENW){1'b0}};
       assign   xpi_read_ch_num_red           = {(NUM_VIR_CH_LG2){1'b0}};
       assign   xpi_read_bypass_reorder_red   = 1'b0;
       assign   e_exa_acc_red                 = 1'b0;
       assign   e_exa_acc_instr_red           = 1'b0;
       assign   e_poison_red                  = 1'b0;
       assign   e_ocpar_err_red               = 1'b0;
       assign   e_user_red                    = {AXI_USERW{1'b0}};
       assign   e_autopre_red                 = 1'b0;
       assign   e_exa_pyld_red                = {(EXA_PYLD_W){1'b0}};
       assign   e_split_red                   = 1'b0;
       assign   e_araddr_red                  = {(M_ADDRW){1'b0}};
       assign   e_arid_red                    = {(AXI_IDW){1'b0}};
       assign   e_arqos_red                   = {(AXI_QOSW){1'b0}};
       assign   e_arpagematch_red             = 1'b0;
       assign   e_arlast_red                  = 1'b0;
       assign   e_arinfo_red                  = {(ARINFOW){1'b0}};
       assign   e_arvalid_red                 = 1'b0;
       assign   e_rqos_priority_red           = {(RQOS_RW){1'b0}};
       assign   e_rqos_timeout_red            = {(RQOS_TW){1'b0}};
       assign   e_vpr_expired_red             = 1'b0;
       assign   raqr_wcount                   = {(AXI_RAQD_LG2+1){1'b0}};
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
       assign   rd_ch_wr_red                  = 1'b0;
       assign   rd_ch_full_red                = 1'b0; 
       assign   id_match_red                  = 1'b0; 
       assign   id_collision                  = 1'b0;
//spyglass enable_block W528
       assign   e_dch_red                     = 1'b0;
       assign   raqr_pop                      = 1'b0;
       assign   raqr_push                     = 1'b0;
       assign   occap_xpi_read_red_err        = 1'b0;
       assign   occap_red_cmp_error           = 1'b0;
       assign   occap_red_cmp_error_full      = 1'b0;
       assign   occap_red_cmp_error_seq       = 1'b0;
       assign   occap_red_cmp_poison_complete = 1'b1;
       assign   sbam_lead_burst_red           = 1'b0;
       assign   sbam_second_burst_red         = 1'b0;
       assign   sbam_tokens_allocated_red     = {NTOKENS_LG2{1'b0}};
       assign   bam_lead_burst_red            = 1'b0;
       assign   bam_addr_offset_red           = {AXI_MAXSIZE{1'b0}};


       assign rd_ch_full    = rd_ch_full_blue;
       assign rd_ch_empty_unused   = rd_ch_empty_blue;
       assign rd_ch_wr_blue = rd_ch_wr;

   end
endgenerate


generate
  if (USE_SAR == 1) begin: sar_en
  //---------------------------------------------------------------------------
  // System Address Regions translator 
  //---------------------------------------------------------------------------

  DWC_ddr_umctl2_xpi_sar
  
    #(
      .AXI_ADDRW     (AXI_ADDRW),
      .AXI_SAR_BW    (AXI_SAR_BW),
      .AXI_SAR_SW    (AXI_SAR_SW),
      .NSAR          (NSAR),
      .SAR_MIN_ADDRW (SAR_MIN_ADDRW)
    )
    U_sar_rd
    (
      // outputs
      .addr_out                           (addr_ra2r),
      // inputs
      .clk                                (aclk),
      .rst_n                              (aresetn),
      .reg_arb_base_addr_0                (reg_arb_base_addr_0),
      .reg_arb_nblocks_0                  (reg_arb_nblocks_0),
      .reg_arb_base_addr_1                (reg_arb_base_addr_1),
      .reg_arb_nblocks_1                  (reg_arb_nblocks_1),
      .reg_arb_base_addr_2                (reg_arb_base_addr_2),
      .reg_arb_nblocks_2                  (reg_arb_nblocks_2),
      .reg_arb_base_addr_3                (reg_arb_base_addr_3),
      .addr_in                            (addr_sar)
    );

  DWC_ddr_umctl2_xpi_sar
  
    #(
      .AXI_ADDRW     (AXI_ADDRW),
      .AXI_SAR_BW    (AXI_SAR_BW),
      .AXI_SAR_SW    (AXI_SAR_SW),
      .NSAR          (NSAR),
      .SAR_MIN_ADDRW (SAR_MIN_ADDRW)
    )
    U_sar_rd_wrap_autopre
    (
      // outputs
      .addr_out                           (next_addr_wrap_autopre_ra2r),
      // inputs
      .clk                                (aclk),
      .rst_n                              (aresetn),
      .reg_arb_base_addr_0                (reg_arb_base_addr_0),
      .reg_arb_nblocks_0                  (reg_arb_nblocks_0),
      .reg_arb_base_addr_1                (reg_arb_base_addr_1),
      .reg_arb_nblocks_1                  (reg_arb_nblocks_1),
      .reg_arb_base_addr_2                (reg_arb_base_addr_2),
      .reg_arb_nblocks_2                  (reg_arb_nblocks_2),
      .reg_arb_base_addr_3                (reg_arb_base_addr_3),
      .addr_in                            (next_addr_wrap_autopre_sar)
    );
end else begin: sar_nen
   assign addr_ra2r = addr_sar;
   assign next_addr_wrap_autopre_ra2r = next_addr_wrap_autopre_sar;
end
endgenerate
  

  //---------------------------------------------------------------------------
  // Wrap Split 
  //---------------------------------------------------------------------------

  DWC_ddr_umctl2_xpi_ws_wrapper
  
    #(
      .OCCAP_EN            (OCCAP_EN),
      .CMP_REG             (OCCAP_PIPELINE_EN), // registers on inputs in comparator for pipelining 
      .WR                  (0),
      .AXI_ADDRW           (AXI_ADDRW),
      .M_DW                (M_DW),
      .NAB                 (NAB),
      .PDBW_CASE           (PDBW_CASE),
      .XPI_BRW             (XPI_BRW),
      .MEMC_BURST_LENGTH   (MEMC_BURST_LENGTH),
      .AXI_USERW           (AXI_USERW),
      .AXI_LENW            (AXI_LENW),
      .AXI_SIZEW           (AXI_SIZEW),
      .AXI_STRBW           (AXI_STRBW),
      .AXI_MAXSIZE         (AXI_MAXSIZE),     
      .AXI_IDW             (AXI_IDW),
      .AXI_QOSW            (AXI_QOSW),
      .AXI_LOCKW           (AXI_LOCKW),
      .ORDER_TOKENW        (ORDER_TOKENW),
      .UP_SIZE             (UP_SIZE),
      .DOWN_SIZE           (DOWN_SIZE),
      .DUAL_CHANNEL_INTERLEAVE           (DUAL_CHANNEL_INTERLEAVE))
  U_ws   
    (
     // Outputs
     .full                               (ws_full),
     .ws_addr                            (ws_addr[AXI_ADDRW-1:0]),
     .ws_alen                            (ws_alen[AXI_LENW-1:0]),
     .ws_id                              (ws_id[AXI_IDW-1:0]), 
     .ws_qos                             (ws_qos[AXI_QOSW-1:0]), 
     .ws_poison                          (ws_poison),
     .ws_ocpar_err                       (ws_ocpar_err),
     .ws_token                           (ws_order_token[ORDER_TOKENW-1:0]),
     .ws_asize                           (ws_asize[AXI_SIZEW-1:0]),
     .ws_lock                            (ws_lock),
     .ws_user                            (ws_user),
     .split                              (ws_split),
     .skip                               (ws_skip),
     .ws_autopre                         (ws_autopre),
     .ws_next_addr_wrap_autopre          (ws_next_addr_wrap_autopre[AXI_ADDRW-1:0]),
     .ws_next_alen_wrap_autopre          (ws_next_alen_wrap_autopre[AXI_LENW-1:0]),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .hold_first_beat                    (ws_hold_first_beat),
//spyglass enable_block W528
     .short_burst                        (ws_short_burst),     
     .empty                              (ws_empty),
     .ws_cmp_error                       (ws_cmp_error),
     .ws_cmp_error_full                  (ws_cmp_error_full),
     .ws_cmp_error_seq                   (ws_cmp_error_seq),
     .ws_cmp_poison_complete             (ws_cmp_poison_complete),
     // Inputs
     .clk                                (aclk),
     .rst_n                              (aresetn),
     .reg_burst_rdwr                     (reg_burst_rdwr),  
     .reg_ddrc_data_bus_width            (reg_arba_data_bus_width),
     .addr                               (araddr[AXI_ADDRW-1:0]),
     .alen                               (arlen[AXI_LENW-1:0]),
     .asize                              (arsize[AXI_SIZEW-1:0]),
     .alock                              (arlock[AXI_LOCKW-1:0]),
     .id                                 (arid[AXI_IDW-1:0]), 
     .user                               (aruser),
     .poison                             (arpoison),
     .autopre                            (arautopre),
     .ocpar_err                          (parity_addr_error),
     .qos                                (arqos[AXI_QOSW-1:0]), 
     .token                              (pre_arb_order_token[ORDER_TOKENW-1:0]),
     .awrap                              (arwrap),
     .wr                                 (ws_wr),
     .rd                                 (ws_rd),
     .ws_cmp_en                          (reg_ddrc_occap_en), 
     .ws_cmp_poison                      (reg_arb_occap_arb_cmp_poison_seq),
     .ws_cmp_poison_full                 (reg_arb_occap_arb_cmp_poison_parallel),
     .ws_cmp_poison_err_inj              (reg_arb_occap_arb_cmp_poison_err_inj)
   );

  assign ws_wr  = arvalid;
  assign ws_rd  = ~raq_full;    

  // output debug signals
  always @(posedge aclk, negedge aresetn) begin
   if (~aresetn) begin
      raq_split   <= 1'b0;
   end
   else begin
      raq_split   <= ws_split;
   end
  end

  //---------------------------------------------------------------------------
  // ENIF Dummy Filter 
  //---------------------------------------------------------------------------

  generate
   if (USE2RAQ==1) begin: DF_dual_q
      assign df_ch_num  = {rrb_queue_type,rrb_ch_num};
   end
   else begin: DF_single_q
      assign df_ch_num  = rrb_ch_num;
   end
  endgenerate
  
  DWC_ddr_umctl2_xpi_df
  
    #(
      .INFOW                     (RPINFOW),
      .ENIF_LENW                 (ENIF_LENW),
      .ENIF_SIZEW                (ENIF_SIZEW),
      .ENIF_MAXSIZE              (ENIF_MAXSIZE),
      .PDBW_CASE                 (PDBW_CASE),
      .MAXSIZE                   (MAXSIZE),
      .DOWN_SIZE                 (DOWN_SIZE),
      .UP_SIZE                   (UP_SIZE),
      .NUM_CH                    (DF_NUM_CH),
      .NUM_CH_LG2                (DF_NUM_CH_LG2),
      .READ_DATA_INTERLEAVE_EN   (READ_DATA_INTERLEAVE_EN),
      .USE2RAQ                   (USE2RAQ),
      .AXI_IDW                   (AXI_IDW),
      .NUM_DCH                   (NUM_DATA_CHANNELS),
      .DCH_INTERLEAVE            (DUAL_CHANNEL_INTERLEAVE),
      .OCCAP_EN                  (OCCAP_EN),
      .OCCAP_PIPELINE_EN         (OCCAP_PIPELINE_EN)      

      )
  U_df 
    (
     // Outputs
     .empty                               (df_empty),
     .full                                (df_full),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .addr_offset                         (df_addr_offset),
     .split                               (df_split), 
     .rerror_out                          (df_rerror),       
//spyglass enable_block W528
     .occap_xpi_df_par_err                (occap_xpi_df_par_err),                            
     // Inputs
     .clk                                 (e_clk),
     .rst_n                               (e_rst_n),
     .info                                (info_df[RPINFOW-1:0]),
     .rrb_rd_last                         (rrb_rd_last),
     .rrb_ch_num                          (df_ch_num),
     .rerror_in                           (e_rerror),
     .wr                                  (df_wr),
     .rd                                  (df_rd),
     .reg_ddrc_data_bus_width             (reg_ddrc_data_bus_width),
     .reg_ddrc_occap_en                   (reg_ddrc_occap_en),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .df_last_pkt                         (df_last_pkt),   
//spyglass enable_block W528
     .df_last                             (df_last));   

  assign df_wr = e_rvalid;

  assign e_rready  = ~df_full;
  
  //---------------------------------------------------------------------------
  // Read Data Queue
  //---------------------------------------------------------------------------

  generate
    // --
    // Synchronous FIFO
    // --
    if (AXI_SYNC==1)  begin: sync_rdq
      DWC_ddr_umctl2_gfifo
      
      
        #(
          .WIDTH           (RDQW),
          .DEPTH           (AXI_RDQD),
          .ADDR_WIDTH      (AXI_RDQD_LG2),
          .COUNT_WIDTH     (AXI_RDQD_LG2+1),
          .OCCAP_EN        (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
          ) 
      rdq (
           .clk             (e_clk),
           .rst_n           (e_rst_n),
           .wr              (rdq_wr),
           .d               (rdq_d),
           .rd              (rdq_rd),
           .par_en          (reg_ddrc_occap_en),
           .init_n          (1'b1),
           .ff              (rdq_full),
           .wcount          (rdq_wcount_unused),
           .q               (rdq_q),
           .fe              (rdq_empty),
           .par_err         (occap_xpi_rdq_err)
          `ifdef SNPS_ASSERT_ON
          `ifndef SYNTHESIS
          ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~rdq_empty
          ,.disable_sva_fifo_checker_wr (1'b0)
          `endif // SYNTHESIS
          `endif // SNPS_ASSERT_ON
           );
    end // block: sync_rdq
    // --
    // Asynchronous FIFO
    // --
    if (AXI_SYNC==0) begin: async_rdq
      wire [AXI_RDQD_LG2:0] pop_wcount_unused;
      wire                  push_fe_unused;
      DWC_ddr_umctl2_gafifo
      
      
        #(
          .WIDTH              (RDQW),
          .DEPTH              (AXI_RDQD),
          .ADDR_WIDTH         (AXI_RDQD_LG2),
          .COUNT_WIDTH        (AXI_RDQD_LG2+1),
          .PUSH_SYNC          (ASYNC_FIFO_N_SYNC),
          .POP_SYNC           (ASYNC_FIFO_N_SYNC),
          .EARLY_PUSH_STAT    (ASYNC_FIFO_EARLY_PUSH_STAT), // push side is all registered
          .EARLY_POP_STAT     (ASYNC_FIFO_EARLY_POP_STAT),
          .OCCAP_EN           (OCCAP_EN),
          .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN)          
          )
      rdq (
           .wclk               (e_clk),
           .wrst_n             (e_rst_n),
           .wr                 (rdq_wr),
           .d                  (rdq_d),
           .rclk               (aclk),
           .rrst_n             (aresetn),
           .rd                 (rdq_rd),
           .par_en             (reg_ddrc_occap_en),
           .ff                 (rdq_full),
           .push_wcount        (rdq_wcount_unused),
           .pop_wcount         (pop_wcount_unused),      
           .q                  (rdq_q),
           .push_fe            (push_fe_unused),
           .pop_fe             (rdq_empty),
           .par_err            (occap_xpi_rdq_err)
          `ifdef SNPS_ASSERT_ON
          `ifndef SYNTHESIS
          ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~rdq_empty
          ,.disable_sva_fifo_checker_wr (1'b0)
          `endif // SYNTHESIS
          `endif // SNPS_ASSERT_ON
           );


    end // block: async_rdq
  endgenerate


  assign e_rid_rdq   = e_rid;
  assign e_ruser_rdq = e_ruser;

  field_packer10
  
    # (RDQ_DATAW,RDQ_STRBW,AXI_IDW,1,(M_ECC>0 || M_LPDDR3==1 || M_DDR5==1)?1:0,1,RDD_INFOW_L,1,1,AXI_USERW)
  rdq_field_packer
    (// Outputs
     .out0                      (rdq_rdata),
     .out1                      (rdq_parity),
     .out2                      (rid_i),
     .out3                      (rdq_rexa_acc_instr),
     .out4                      (rdq_rerror),
     .out5                      (rdq_last),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
     .out6                      (rdq_info),
     .out7                      (rdq_rpoison),
     .out8                      (rdq_ocpar_err),
//spyglass enable_block W528     
     .out9                      (rdq_ruser),
     .pack_out                  (rdq_d),
     // Inputs
     .in0                       (data_rdq),
     .in1                       (parity_rdq),
     .in2                       (e_rid_rdq),
     .in3                       (e_rrb_rexa_acc_instr_rdq),
     .in4                       (e_rerror_rdq),
     .in5                       (last_rdq),
     .in6                       (info_rdq),
     .in7                       (e_rrb_rpoison_rdq),
     .in8                       (e_rrb_ocpar_err_rdq),
     .in9                       (e_ruser_rdq),
     .pack_in                   (rdq_q));


  generate 
    if (DOWN_SIZE==1) begin : rdq_dsize
      if(PDBW_CASE==2) begin : pdbw_case2
        // lower AXI_DATW bytes come from DU
        // In CASE2, FBW and HBW DU is in Bypass so its e_rdata itself
        // in Case2 QBW, this is the actual upsized data - rdu.data_up
        assign data_rdq[0+:AXI_DATAW] = du_data;
        assign parity_rdq[0+:AXI_STRBW]  = du_parity;
        // upper AXI_DATW bytes come directly from e_rdata
        // In CASE2, FBW and HBW where DU is in Bypass and its data_up out is limited to AXI_DATAW width
        //  - hence upper AXI_DATAW are directly tapped from e_rdata
        // in Case2 QBW, this is dont care as only lower AXIDATW are valid - rdu.data_up
        assign data_rdq[AXI_DATAW+:AXI_DATAW] = e_rdata[AXI_DATAW+:AXI_DATAW];
        assign parity_rdq[AXI_STRBW+:AXI_STRBW]  = e_rdata_parity[AXI_STRBW+:AXI_STRBW];
      end else begin : pgdbw_not_case2
        assign data_rdq                  = du_data;
        assign parity_rdq                = du_parity;
      end 
      assign e_rrb_rexa_acc_instr_rdq  = du_rexa_acc_instr;
      assign e_rrb_rpoison_rdq         = du_rpoison;
      assign e_rrb_ocpar_err_rdq       = du_ocpar_err;
      assign e_rerror_rdq              = (M_ECC>0 || M_LPDDR3==1 || M_DDR5==1) ? du_rerror : 1'b0;
      assign last_rdq                  = du_last;

      assign rdq_wr  = ~du_empty & ~rdq_full;      
      assign df_rd   = ~du_full;
    end
    else begin : rdq_ndsize
      assign data_rdq                  = e_rdata;
      assign parity_rdq                = e_rdata_parity;
      assign e_rrb_rexa_acc_instr_rdq  = e_rrb_rexa_acc_instr;
      assign e_rrb_rpoison_rdq         = e_rrb_rpoison;
      assign e_rrb_ocpar_err_rdq       = e_rrb_ocpar_err;
      assign e_rerror_rdq              = (M_ECC>0 || M_LPDDR3==1 || M_DDR5==1) ? df_rerror : 1'b0;
      assign last_rdq                  = df_last;

      assign rdq_wr  = ~df_empty & ~rdq_full;
      assign df_rd   = ~rdq_full;
    end
    if (UP_SIZE==1) begin : rdq_usize
      assign info_rdq   = info_rdd[RDD_INFOW_L-1:0];
      assign rdq_rd     = ~dd_full;
      assign rvalid_i   = ~dd_empty;
      assign rlast_i    =  dd_last;
      assign rdata_tmp  =  dd_data;
      assign rerror_i   =  dd_error;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      assign parity_tmp =  dd_parity;
//spyglass enable_block W528
    end
    else begin : rdq_nusize
      assign info_rdq   = 1'b0;
      assign rdq_rd     = rready_i;
      assign rvalid_i   = ~rdq_empty;
      assign rlast_i    = rdq_last;
      assign rdata_tmp  = rdq_rdata;
      assign rerror_i   = rdq_rerror;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
      assign parity_tmp = rdq_parity;
//spyglass enable_block W528
    end
    
      
  endgenerate

  // occap error packing
  assign occap_rd_q_cmp_error             = occap_red_cmp_error | occap_blue_cmp_error;
  assign occap_rd_q_cmp_error_full        = occap_red_cmp_error_full | occap_blue_cmp_error_full;
  assign occap_rd_q_cmp_error_seq         = occap_red_cmp_error_seq | occap_blue_cmp_error_seq;
  assign occap_rd_q_cmp_poison_complete   = occap_red_cmp_poison_complete | occap_blue_cmp_poison_complete;

  assign occap_aclk_cmp_err               = ws_cmp_error | au_cmp_error;
  assign occap_aclk_cmp_err_full          = {ws_cmp_error_full,au_cmp_error_full};
  assign occap_aclk_cmp_err_seq           = {ws_cmp_error_seq,au_cmp_error_seq};
  assign occap_aclk_cmp_poison_complete   = {ws_cmp_poison_complete,au_cmp_poison_complete};

  assign occap_cclk_cmp_err               = occap_rd_q_cmp_error;
  assign occap_cclk_cmp_err_full          = occap_rd_q_cmp_error_full;
  assign occap_cclk_cmp_err_seq           = occap_rd_q_cmp_error_seq;
  assign occap_cclk_cmp_poison_complete   = occap_rd_q_cmp_poison_complete;

  //****************************************************************
  // Read transaction is invalid if poison is high, generate slverr in case and put all data to '0'
  //
  //****************************************************************

  assign read_transaction_poison = rpoison;

  assign rd_transaction_poison_slverr  = read_transaction_poison & reg_arb_poison_slverr_en;

  generate
  if (AXI_SYNC==0) begin: slverr_en_async
   // slverr_en synchronizer

   DWC_ddr_umctl2_bitsync
   
   #( .BCM_SYNC_TYPE   (ASYNC_FIFO_N_SYNC),
      .BCM_VERIF_EN    (BCM_VERIF_EN))
   U_slverr_en_sync
   (  .clk_d          (aclk),
      .rst_d_n        (aresetn),
      .data_s         (reg_ddrc_rd_poison_slverr_en),
      .data_d         (reg_arb_poison_slverr_en));

  end
  else begin: slverr_en_sync

   assign reg_arb_poison_slverr_en = reg_ddrc_rd_poison_slverr_en;

  end
  endgenerate

  always @(posedge e_clk or negedge e_rst_n) begin
   if (~e_rst_n) begin
      rd_transaction_poison_intr <= 1'b0;
   end
   else begin
      if (reg_ddrc_rd_poison_intr_clr) rd_transaction_poison_intr <= 1'b0;
      else if (e_rrb_rpoison & reg_ddrc_rd_poison_intr_en & e_rvalid) rd_transaction_poison_intr <= 1'b1;
   end
  end

  assign rd_poison_intr = rd_transaction_poison_intr;

  // Decode Response Type - Error has highest priorty.
  assign rresp = (rerror | rd_transaction_poison_slverr | on_chip_parity_error) ? SLVERR  : rexa_acc_w ? EXOKAY : OKAY;


  assign rdata = (read_transaction_poison | ocpar_addr_err)  ? {AXI_DATAW{1'b0}} : rdata_i;
  
  assign rparity = ocpar_addr_err ? ((OCECC_EN==1) ? {AXI_STRBW{1'b1}} : {AXI_STRBW{reg_arb_oc_parity_type}}) : rparity_i;


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
endmodule // DWC_ddr_umctl2_xpi_read
