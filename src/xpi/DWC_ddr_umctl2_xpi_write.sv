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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_write.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            XPI Write
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_write
import DWC_ddrctl_reg_pkg::*;
  #(
    parameter M_DW                        = 32,            // SDRAM data width
    parameter M_DW_INT                    = M_DW*2,
    parameter M_ADDRW                     = 32,            // Memory address width (word aligned address)
    parameter NAB                         = 2,
    parameter MEMC_BURST_LENGTH           = 8,
    parameter NBEATS_LG2                  = 2,        
    parameter QOSW                        = 2,
    parameter M_USE_RMW                   = 0,
    parameter UP_SIZE                     = 0,
    parameter DOWN_SIZE                   = 0,
    parameter AXI_ADDRW                   = 32,            // AXI address width
    parameter AXI_DATAW                   = 128,           // AXI *data width
    parameter AXI_STRBW                   = 16,            // AXI wstrb width
    parameter AXI_IDW                     = 8,             // AXI ID width
    parameter AXI_LENW                    = 6,             // AXI a*len width
    parameter AXI_SIZEW                   = 3,             // AXI a*size width
    parameter AXI_MAXSIZE                 = 4,             // AXI Maximum size
    parameter AXI_BURSTW                  = 2,             // AXI a*burst width
    parameter AXI_LOCKW                   = 2,             // AXI a*lock width
    parameter AXI_USERW                   = 1,
    parameter AXI_CACHEW                  = 4,             // AXI a*cache width
    parameter AXI_PROTW                   = 3,             // AXI a*prot width
    parameter AXI_QOSW                    = 4,             // AXI a*qos width
    parameter AXI_RESPW                   = 2,             // AXI *resp width  
    parameter AXI_WAQD                    = 4,
    parameter AXI_WAQD_LG2                = 2,
    parameter AXI_WDQD                    = 8,
    parameter AXI_WRQD                    = 8,
    parameter WRQW                        = 10,
    parameter SQD                         = 32,
    parameter AXI_SYNC                    = 0,             // AXI synchronous or asynchronous  
    parameter ENIF_DATAW                  = 32,
    parameter ENIF_STRBW                  = 4,      
    parameter ENIF_PARW                   = 4,
    parameter ENIF_MAXSIZE                = 4,             // NIF Maximum size
    parameter ENIF_SIZEW                  = 4,
    parameter ENIF_LENW                   = 4,             // NIF a*len width   
    parameter ENIF_HDATAW                 = 32,
    parameter ENIF_HSTRBW                 = 4,      
    parameter ENIF_HMAXSIZE               = 4,   // NIF Maximum siz
    parameter ENIF_HSIZEW                 = 4,
    parameter ENIF_HLENW                  = 4,
    parameter INFOW                       = 5,
    parameter USE_WAR                     = 0,
    parameter AXI_SAR_BW                  = 32,
    parameter AXI_SAR_SW                  = 8,
    parameter USE_SAR                     = 0,
    parameter NSAR                        = 0,
    parameter SAR_MIN_ADDRW               = 26,
    parameter WAR_DEPTH                   = 2,
    parameter RMW_WARD                    = 2,
    parameter VPW_EN                      = 0,
    parameter M_INLINE_ECC                = 0,
    parameter VPRW_PUSH_SYNC_DEPTH        = 16,
    parameter VPRW                        = 1,
    parameter WQOS_MLW                    = 4,
    parameter WQOS_RW                     = 2,
    parameter WQOS_TW                     = 11,
    parameter OCPAR_EN                    = 0,
    parameter OCPAR_SLICE_WIDTH           = 8,
    parameter OCCAP_EN                    = 0,
    parameter OCCAP_PIPELINE_EN           = 0,
    parameter OCCAP_CMP_CC                = 2,
    parameter OCCAP_CMP_AC                = 1,
    parameter OCPAR_ADDR_PAR_WIDTH        = 8,
    parameter OCECC_EN                    = 0,
    parameter OCECC_XPI_WR_IN_GRANU       = 64,
    parameter OCECC_MR_RD_GRANU           = 8,
    parameter OCECC_MR_RD_ECCW            = 40,
    parameter OCECC_MR_BNUM_WIDTH         = 5,
    parameter DUAL_CHANNEL                = 0,
    parameter DUAL_CHANNEL_INTERLEAVE     = 0,
    parameter DUAL_CHANNEL_INTERLEAVE_LP  = 0,
    parameter DDRCTL_HET_INTERLEAVE       = 0,
    parameter PA_OPT_TYPE                 = 1,
    parameter ASYNC_FIFO_N_SYNC           = 2,         // Number of synchronizers for async FIFOs
    parameter ASYNC_FIFO_EARLY_PUSH_STAT  = 0,
    parameter ASYNC_FIFO_EARLY_POP_STAT   = 1, // Only applies to write response queue
    parameter EXA_ACC_SUPPORT             = 0,
    parameter EXA_PYLD_W                  = 32,
    parameter EXA_MAX_LENW                = 12,          // Worst Case Dowsnsizing is 256/8 with a AXI_LENW of 6
    parameter EXA_MAX_SIZEW               = 3,           // Maximum AXI Size is 3 bits
    parameter EXA_MAX_ADDRW               = 12,          // 12 bits for 4K Boundary
    parameter MEMC_NO_OF_ENTRY            = 32,
    parameter AXI_ADDR_BOUNDARY           = 12,        // Defines AXI address no crossing boundary ( default is 4k))
    parameter ORDER_TOKENW                = 8,
    parameter XPI_BRW                     = 3,
    parameter DDRCTL_LUT_ADDRMAP_EN       = 0,    
    parameter UMCTL2_HET_RANK_EN          = 0,
    parameter AMCSW                       = 5,
    parameter AMCOLW                      = 4,
    parameter AMCOLW_C3                   = 5,
    parameter UMCTL2_PARTIAL_WR_EN        = 0,
    parameter MEMC_DDR4_EN                = 0,
    parameter BCM_VERIF_EN                = 2,
    parameter DEACC_INFOW                 = 5,
    parameter PDBW_CASE                   = 0,   // Programmable DRAM data width cases - Case1:1 ... Case5:5 
    parameter DBW                         = 2,
    // internal bcm07 parameters
   parameter PUSH_AE_LVL                  =  2, 
   parameter PUSH_AF_LVL                  =  2,
   parameter POP_AE_LVL                   =  2,
   parameter POP_AF_LVL                   =  2,
   parameter ERR_MODE                     =  0,
   parameter OUTS_WRW                     =  6,

   parameter IH_TE_PIPELINE               =  0
     
    )
  (
   input                         aclk,          // AXI clock
   input                         aresetn,       // AXI asynchronous reset
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input                         a_rst_dly,
//spyglass enable_block W240
   input                         siu_bl4,
   input                         siu_bl8,  
   input                         siu_bl16,
   input [XPI_BRW-1:0]           reg_burst_rdwr,
   input                         reg_xpi_short_write_dis,
   input                         reg_xpi_short_write_dis_bl8_nab1,
   input                         reg_xpi_short_write_dis_bl8_nab1_1or3beats,
   input                         reg_ddrc_col_addr_shift,
   input [`MEMC_NUM_RANKS-1:0]   reg_ddrc_active_ranks,
   input                         reg_ddrc_alt_addrmap_en,                           
   input [AMCSW-1:0]             reg_ddrc_addrmap_cs_bit0,
   input [AMCSW-1:0]             reg_ddrc_addrmap_cs_bit1,
   input [AMCOLW-1:0]            reg_ddrc_addrmap_col_b2_alt,
   input [AMCOLW_C3-1:0]         reg_ddrc_addrmap_col_b3_alt,
   input [AMCOLW-1:0]            reg_ddrc_addrmap_col_b2,
   input [AMCOLW_C3-1:0]         reg_ddrc_addrmap_col_b3,
   input                         reg_xpi_short_write_dis_bl16_nab1,
   input                         reg_xpi_short_write_dis_bl16_nab2,
   input                         reg_xpi_short_write_dis_mbl16_bl8_nab2,
   input                         reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2,
   input                         reg_xpi_short_write_dis_mbl16_bl4_nab2,
   input                         reg_xpi_short_write_dis_bl16_qbw_nab1,
   input                         reg_xpi_short_write_dis_bl16_hbw,
   input                         reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1,
   input                         reg_xpi_short_write_dis_bl16_fbw_nab1,
   input                         reg_xpi_short_write_dis_mbl16_bl4_nab1,
   input                         reg_xpi_short_write_dis_mbl16_bl8_bc_fbw,
   input                         reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1,
   input [DBW-1:0]                  reg_ddrc_data_bus_width,
   input [DBW-1:0]                  reg_arba_data_bus_width,
   // interface to AXI write address channel
   input [AXI_IDW-1:0]           awid,          // AXI write address ID
   input [AXI_ADDRW-1:0]         awaddr,        // AXI write address
   input [AXI_LENW-1:0]          awlen,         // AXI write burst length
   input [AXI_SIZEW-1:0]         awsize,        // AXI write burst size
   input [AXI_BURSTW-1:0]        awburst,       // AXI write burst type
   input [AXI_LOCKW-1:0]         awlock,        // AXI write lock type
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Unused signals. Keeping them as they are part of the standard set of AXI signals
   input [AXI_CACHEW-1:0]        awcache,       // AXI write cache type
   input [AXI_PROTW-1:0]         awprot,        // AXI write protection type
   input [AXI_USERW-1:0]         awuser,
   input [AXI_QOSW-1:0]          awqos,         // AXI write address qos
   input                         awpoison,      // AXI write transaction poison
   input                         awvalid,       // AXI write address valid
   input [OCPAR_ADDR_PAR_WIDTH-1:0] awparity,
   input                         awautopre,     // AXI write address auto precharge
   output                        awready,       // AXI write address ready
   // interface to AXI write data channel
   input [AXI_IDW-1:0]           wid,           // AXI write ID
   input [AXI_USERW-1:0]         wuser,         // not used
   input [AXI_DATAW-1:0]         wdata,         // AXI write data
   input [AXI_STRBW-1:0]         wparity,       // AXI write data parity
//spyglass enable_block W240
   input [AXI_STRBW-1:0]         wstrb,         // AXI write strobes

   input                         wlast,         // AXI write last
   input                         wvalid,        // AXI write valid
   output                        wready,        // AXI write ready
   // interface to AXI write response channel
   output [AXI_IDW-1:0]          bid,           // AXI write response ID
   output [AXI_RESPW-1:0]        bresp,         // AXI write response
   output [AXI_USERW-1:0]        buser,
   output                        bvalid,        // AXI write response valid
   input                         bready,        // AXI write response ready
   // Extended Native Interface:
   input                         e_clk,         // ENIF clock
   input                         e_rst_n,       // ENIF asynchronous reset
   input                         e_rst_dly,
   // ENIF Write Address channel
   output [M_ADDRW-1:0]          e_awaddr,      // ENIF write address
   output                        e_awdata_channel,
   output                        e_awlast,      // ENIF write address last
   output [AXI_IDW-1:0]          e_awid,        // ENIF write address ID
   output [AXI_QOSW-1:0]         e_awqos,       // ENIF write address qos
   output                        e_awpagematch, // ENIF write pagematch indicator
   output                        e_awvalid,     // ENIF write address valid
   input                         e_awready,     // ENIF write address ready
   output                        e_ocpar_err,
   output [AXI_USERW-1:0]        e_awuser,
   output                        e_awautopre,     // ENIF write address auto precharge
   // ENIF Write Data Channel
   output [ENIF_DATAW-1:0]       e_wdata,       // ENIF write data
   output [ENIF_STRBW-1:0]       e_wstrb,       // ENIF write data strobe
   output                        e_wlast,       // ENIF write data last
   output                        e_wvalid,      // ENIF write data valid
   output [ENIF_STRBW-1:0]       e_wpar_err,
   output [ENIF_PARW-1:0]        e_wparity,
   output                        e_wdata_channel,
   input                         e_wready,      // ENIF write data ready
   output                        e_wlast_pkt,   // ENIF write last beat of the packet
   output                        e_poison,   
   output [NBEATS_LG2-1:0]       e_beat_count,
   // ENIF Write Response Channel
   input                         e_bvalid,       // ENIF write response valid
   output                        e_bready,       // ENIF write response ready
   input [WRQW-1:0]              e_bresp,

   output [WQOS_RW-1:0]          e_wqos_priority, // ENIF write priority
   output [WQOS_TW-1:0]          e_wqos_timeout,
   output                        wdq_empty_aclk, // to generate cactive_out
   // ENIF Exclusive Access Info
   output                        e_exa_acc,        // ENIF Exclusive Access (asserted for the first packet)
   output [EXA_PYLD_W-1:0]       e_exa_pyld,       // ENIF Exclusive Access Payload
   output                        e_exa_acc_lock,   // ENIF Exclusive Access lock (asserted for all packets)
   output                        e_split,
   output                        e_short_burst,
   
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.

   // System Address Regions registers
   input [AXI_SAR_BW-1:0]        reg_arb_base_addr_0,
   input [AXI_SAR_SW-1:0]        reg_arb_nblocks_0,
   input [AXI_SAR_BW-1:0]        reg_arb_base_addr_1,
   input [AXI_SAR_SW-1:0]        reg_arb_nblocks_1,  
   input [AXI_SAR_BW-1:0]        reg_arb_base_addr_2,
   input [AXI_SAR_SW-1:0]        reg_arb_nblocks_2,    
   input [AXI_SAR_BW-1:0]        reg_arb_base_addr_3,

   // oc parity config
   input                         reg_arb_oc_parity_type, // @aclk select parity type: 0 even, 1 odd
   input                         oc_addr_parity_en, // enable address parity check
   input                         oc_data_parity_en, // enable data parity check
//spyglass enable_block W240
   input                         reg_ddrc_oc_parity_type, // @core_clock
   
   // occap
   input                            reg_ddrc_occap_en,
   input                            reg_ddrc_occap_arb_cmp_poison_seq,
   input                            reg_ddrc_occap_arb_cmp_poison_parallel,
   input                            reg_ddrc_occap_arb_cmp_poison_err_inj,
   input                            reg_arb_occap_arb_cmp_poison_seq,
   input                            reg_arb_occap_arb_cmp_poison_parallel,
   input                            reg_arb_occap_arb_cmp_poison_err_inj,

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   // ocecc
   input                            ocecc_en,
   input                            ocecc_poison_en,
   input                            ocecc_poison_single,
   input [OCECC_MR_BNUM_WIDTH-1:0]  ocecc_poison_bnum,
   input                            ocecc_wdata_slverr_en,
//spyglass enable_block W240

   output                           occap_xpi_write_c_par_err,
   output                           occap_xpi_write_a_par_err,
   output                           occap_aclk_cmp_err,
   output [OCCAP_CMP_AC-1:0]        occap_aclk_cmp_err_full,
   output [OCCAP_CMP_AC-1:0]        occap_aclk_cmp_err_seq,
   output [OCCAP_CMP_AC-1:0]        occap_aclk_cmp_poison_complete,
   output                           occap_cclk_cmp_err,
   output [OCCAP_CMP_CC-1:0]        occap_cclk_cmp_err_full,
   output [OCCAP_CMP_CC-1:0]        occap_cclk_cmp_err_seq,
   output [OCCAP_CMP_CC-1:0]        occap_cclk_cmp_poison_complete,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   // poison config
   input                            wr_poison_en,
   input                            par_wdata_err_intr_clr,
   input                            par_wdata_axi_check_bypass_en,
//spyglass enable_block W240


   // poison output
   output                        par_waddr_err_pulse,
   output                        par_wdata_in_err_pulse,

   output [AXI_ADDRW-1:0]        par_waddr_log, // last failing address

   output                           ocecc_uncorr_err,
   output                           ocecc_corr_err,

   input [WQOS_MLW-1:0]          wqos_map_level1,
   input [WQOS_MLW-1:0]          wqos_map_level2,
   input [WQOS_RW-1:0]           wqos_map_region0,
   input [WQOS_RW-1:0]           wqos_map_region1,
   input [WQOS_RW-1:0]           wqos_map_region2,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input [WQOS_TW-1:0]           wqos_map_timeout1,
   input [WQOS_TW-1:0]           wqos_map_timeout2,
   // data channel mask
   input [M_ADDRW-1:0]           data_channel_addrmap_mask,
   // bankgroup mask
   input [M_ADDRW-1:0]           bg_or_bank_addrmap_mask,  
//spyglass enable_block W240

   input [1:0]                   reg_arb_dch_density_ratio,
   input [5:0]                   dch_bit,
   input [5:0]                   e_addr_max_loc,
   input [5:0]                   e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]           e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]           e_addr_max_m1_loc_addrmap_mask,

   output [DEACC_INFOW-1:0]      e_deacc_info,
   output                        e_vpw_expired,  // vpw read expired in the FIFO
   // Short Write Info
   output                        short_write, // short write less than one BL 
   // Page match mask
   input [M_ADDRW-1:0]           pagematch_addrmap_mask,
   input                         pagematch_en,
   // Read/write ordering
   input [ORDER_TOKENW-1:0]      pre_arb_order_token,
   output [ORDER_TOKENW-1:0]     xpi_write_order_token,
   output reg [AXI_WAQD_LG2:0]   waq_wcount,
   output reg                    waq_pop,
   output reg                    waq_push,
   output reg                    waq_split
   );
  
  
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------

  // configurable timing
  // -------------------

  localparam MAXSIZE = (UP_SIZE==1) ? ENIF_MAXSIZE : AXI_MAXSIZE; 

  localparam WAQ_SIZEW    = (UP_SIZE==1) ? ENIF_SIZEW:AXI_SIZEW;

  localparam WRAP_LENW = (AXI_MAXSIZE>ENIF_LENW) ? ENIF_LENW : MAXSIZE;
  
  localparam SIZEINFOW    = WRAP_LENW + // wrap_len
                            1 +         // wrap
                            MAXSIZE + // addr_offset
                            WAQ_SIZEW;  // asize_down;
  
  localparam SQW          = SIZEINFOW;  
  
  localparam AXI_WDQD_LG2 = `UMCTL_LOG2(AXI_WDQD);
  
  localparam AXI_WRQD_LG2 = `UMCTL_LOG2(AXI_WRQD); 
  
  localparam SQD_LG2      = `UMCTL_LOG2(SQD);
  
  // Write Address Queue params
  

  localparam AXI_MAXSIZE_EXA = (AXI_MAXSIZE==0)?1:AXI_MAXSIZE;
  
  localparam WAQW         = ORDER_TOKENW + 
                            WQOS_RW +
                             1 + 1 + 1 + 1 + 1 + 1 +
                             AXI_QOSW + 
                             AXI_IDW + 
                             AXI_LENW +  
                             WAQ_SIZEW +
                             AXI_LOCKW +
                             AXI_ADDRW +
                             AXI_USERW +
                             AXI_ADDRW +          // next_addr_wrap_autopre
                             AXI_LENW +           // next_alen_wrap_autopre
                             AXI_MAXSIZE_EXA +
                             AXI_LENW +
                             AXI_SIZEW;

  localparam M_NB         = M_DW/8;

  localparam M_NB_LG2     = (M_NB<=1)   ? 0 :       // 8bits
                            (M_NB<=2)   ? 1 :       // 16bits
                            (M_NB<=4)   ? 2 :       // 32bits
                            (M_NB<=8)   ? 3 :       // 64bits
                            (M_NB<=16)  ? 4 : 5;    // 128bits
  
  
  localparam WARW         = ORDER_TOKENW + 
                            WQOS_RW +
                            1 +                    // split
                            1 +                    // pagematch
                            1 + 1 + EXA_PYLD_W +   // Exclusive Access
                            1 +                    // ep_alast
                            1 +                    // wrap
                            1 +                    // poison
                            1 +                    // ocpar_err
                            1 +                    // data channel
                            1 +                    // auto precharege
                            AXI_QOSW + 
                            AXI_IDW +              // waq_aid
                            M_ADDRW +
                            AXI_USERW;

  localparam WDQ_STRBW = (UP_SIZE==1) ? ENIF_STRBW: AXI_STRBW; 
  localparam WDQ_DATAW = (UP_SIZE==1) ? ENIF_DATAW: AXI_DATAW; 
  localparam WDQ_PARW  = (OCECC_EN==1)? ENIF_PARW : WDQ_STRBW;
  
  
  localparam WDATAQW      = 1 +                 // e_wlast
                            WDQ_STRBW +         // wpar error
                            WDQ_STRBW +         // strobe
                            WDQ_PARW +         // parity
                            WDQ_DATAW;          // data
  
  localparam WDQW         = WDATAQW;
  

  localparam SLVERR       = 2'b10;
  localparam EXOKAY       = 2'b01;
  localparam OKAY         = 2'b00;
  
  localparam AXI_WDQ1D     =  AXI_WDQD;
  localparam AXI_WDQ1D_LG2 = `UMCTL_LOG2(AXI_WDQ1D);

  localparam INFOW_DCH     = (DUAL_CHANNEL_INTERLEAVE)   ? INFOW+1+DEACC_INFOW :
                             (DUAL_CHANNEL_INTERLEAVE_LP)? INFOW+1 : 
                                                           INFOW;
  localparam IQW           = INFOW_DCH;
  localparam DDRC_RESPD_PER_CH= (IH_TE_PIPELINE==1) ? 4 : 2;
  localparam DDRC_RESPD       = (DUAL_CHANNEL_INTERLEAVE==1 || DUAL_CHANNEL_INTERLEAVE_LP==1) ? DDRC_RESPD_PER_CH*2 : DDRC_RESPD_PER_CH;
  localparam TOTAL_CAM_DEPTH  = (DUAL_CHANNEL_INTERLEAVE==1 || DUAL_CHANNEL_INTERLEAVE_LP==1) ?  MEMC_NO_OF_ENTRY*2 : MEMC_NO_OF_ENTRY;
  localparam DCH_ARB_CMD_QUEUE_DEPTH = (PA_OPT_TYPE==1 && DUAL_CHANNEL_INTERLEAVE==1) ? 4 : 0; // queues inside dch_arb, buffering up to 4 commands
  // Maximum outstanding write addresses with data not propagated is 
  // when no ECC: CAM depth + 2 deep FIFO in DDRC 
  // when ECC: CAM depth + 2 deep FIFO in DDRC  + 2/4 deep FIFO in xpi_rmw + 2 deep FIFO in retime is used 
  localparam IQD           = TOTAL_CAM_DEPTH + DDRC_RESPD + (M_USE_RMW ? RMW_WARD :0) + (USE_WAR ? WAR_DEPTH : 0) + DCH_ARB_CMD_QUEUE_DEPTH;   
  localparam IQD_LG2       = `UMCTL_LOG2(IQD);

  localparam VPRW_PUSH_SYNC_DEPTH_LG2 = `UMCTL_LOG2(VPRW_PUSH_SYNC_DEPTH);

  localparam OCPAR_ADDR_SLICE_WIDTH = OCPAR_ADDR_PAR_WIDTH==1 ? AXI_ADDRW : OCPAR_SLICE_WIDTH;

  localparam IN_DATAW = (UP_SIZE==1) ? ENIF_DATAW : AXI_DATAW;
  localparam IN_STRBW = (UP_SIZE==1) ? ENIF_STRBW : AXI_STRBW;

  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------

  wire                                  waq_wr,waq_rd,waq_full,waq_empty;      // WAQ handshake    
  wire                                  wdq_wr,wdq_rd,wdq_full,wdq_empty;      // WDQ handshake    
  wire                                  war_full,war_empty;      // WAR handshake    
  wire                                  war_push, war_pop, war_in_vpw, war_out_vpw;
  wire                                  wrq_wr,wrq_rd,wrq_full,wrq_empty;      // WRQ handshake    
  wire                                  ws_wr,ws_rd,ws_full,ws_empty;          // WS handshake    
  wire                                  ep_wr,ep_rd,ep_full,ep_empty;          // EP handshake
  wire                                  dg_wr,dg_rd,dg_full,dg_empty;          // DG handshake        
  wire                                  au_wr,au_rd,au_full,au_empty;          // AU handshake       
  wire                                  dd_wr,dd_rd,dd_full,dd_empty;          // DD handshake         
  wire                                  du_wr,du_rd,du_full,du_empty;          // DU handshake    
  wire                                  sq_wr,sq_rd,sq_full,sq_empty;          // SQ handshake 
  wire [SQW -1:0]                       sq_d;
  wire [SQW -1:0]                       sq_q; 

  wire                                  up_sq_wr,up_sq_rd,up_sq_full,up_sq_empty;          // SQ handshake 
  wire [SQW -1:0]                       up_sq_d;
  wire [SQW -1:0]                       up_sq_q;
  
  wire                                  dw_sq_wr,dw_sq_rd,dw_sq_full,dw_sq_empty;          // SQ handshake 
  wire [SQW -1:0]                       dw_sq_d;
  wire [SQW -1:0]                       dw_sq_q; 

  wire                                  iq_wr,iq_rd,iq_full,iq_empty;          // IQ handshake          
  wire [WAQW-1:0]                       waq_d;
  wire [WAQW-1:0]                       waq_q;
  wire [WDQW-1:0]                       wdq_d;
  wire [WDQW-1:0]                       wdq_q;
  wire [WARW-1:0]                       war_d;
  wire [WARW-1:0]                       war_q;
  wire [WRQW-1:0]                       wrq_d;
  wire [WRQW-1:0]                       wrq_q;
  wire [AXI_WRQD_LG2:0]                 wrq_wcount_unused;
  wire                                  wdq_wlast;
  wire [WDQ_DATAW-1:0]                  wdq_wdata;      // AXI write data
  wire [WDQ_STRBW-1:0]                  wdq_wstrb;      // AXI write strobes
  wire [WDQ_PARW-1:0]                   wdq_wparity;
  wire [WDQ_STRBW-1:0]                  wdq_wpar_err;
  wire [AXI_WDQ1D_LG2:0]                wdq_wcount_unused;
  wire [WDATAQW-1:0]                    wdq_d_mux;
  wire [AXI_ADDRW-1:0]                  ws_addr;        // AXI INCR burst address
  wire [AXI_LENW-1:0]                   ws_alen;        // AXI first INCR burst length
  wire                                  ws_split;       // Single burst
  wire                                  ws_skip; 
  wire                                  ws_poison;
  wire                                  ws_ocpar_err;
  wire [AXI_IDW-1:0]                    ws_id;
  wire [AXI_USERW-1:0]                  ws_user;
  wire [AXI_QOSW-1:0]                   ws_qos;
  wire [AXI_SIZEW-1:0]                  ws_asize;
  wire [AXI_LOCKW-1:0]                  ws_lock;
  wire                                  ws_autopre;
  wire [AXI_ADDRW-1:0]                  ws_next_addr_wrap_autopre;
  wire [AXI_LENW-1:0]                   ws_next_alen_wrap_autopre;
  wire [M_ADDRW-1:0]                    ep_addr;
  wire [M_ADDRW-1:0]                    ep_addr_alt;
  wire [1:0]                            ep_cs;
  wire [M_ADDRW-1:0]                    ep_addr_int;
  wire                                  ep_addr_alt_addrmap_sel;
  wire [1:0]                            ep_cs_prev_dca;
  wire [1:0]                            ep_cs_prev_dcb;
  wire                                  reg_ep_cs_prev_dca_err;
  wire                                  reg_ep_cs_prev_dcb_err;
  wire                                  het_pagematch_en_dca;
  wire                                  het_pagematch_en_dcb;
  wire                                  ep_alast;       // ENIF Packetizer address last
  wire                                  ep_autopre;
  wire [INFOW-1:0]                      wp_info; 
  wire [INFOW-1:0]                      iq_info;
  wire [INFOW_DCH-1:0]                  wp_info_dch; 
  wire [INFOW_DCH-1:0]                  iq_info_dch;
  wire [DEACC_INFOW-1:0]                deacc_info, iq_deacc_info;
  wire                                  ep_exa_acc, ep_exa_acc_lock, ep_exa_acc_instr_unused;
  wire [EXA_PYLD_W-1:0]                 ep_exa_pyld;
  wire                                  ep_awpagematch;
  wire [WQOS_RW-1:0]                    ep_write_qos_priority;
  wire [WQOS_RW-1:0]                    waq_write_qos_priority;
  wire [WQOS_RW-1:0]                    write_qos_priority_waq;
  wire [WQOS_RW-1:0]                    ep_post_write_qos_priority;
  wire [AXI_ADDRW-1:0]                  addr_ep;
  wire [ENIF_LENW-1:0]                  alen_ep;
  wire [ENIF_SIZEW-1:0]                 asize_ep;
  wire [AXI_LOCKW-1:0]                  alock_ep;
  wire                                  autopre_ep;  
  wire [AXI_ADDRW-1:0]                  next_addr_wrap_autopre_ep;
  wire [ENIF_LENW-1:0]                  next_alen_wrap_autopre_ep;
  wire                                  dd_wlast;
  wire                                  awwrap;         // burst type is WRAP
  wire [ENIF_DATAW-1:0]                 wdata_dg;
  wire [ENIF_DATAW-1:0]                 dg_wdata;   
  wire [ENIF_STRBW-1:0]                 dg_wstrb;
  wire [ENIF_STRBW-1:0]                 wstrb_dg;
  wire [ENIF_PARW-1:0]                  dg_wparity;
  wire [ENIF_PARW-1:0]                  wparity_dg;
  wire [ENIF_STRBW-1:0]                 dg_wpar_err;
  wire [ENIF_STRBW-1:0]                 wpar_err_dg;
  wire [NBEATS_LG2-1:0]                 dg_beat_count;
  wire [AXI_IDW-1:0]                    wrq_id;       // AXI write address ID
  wire                                  wrq_exa_resp;
  wire                                  wrq_slverr;
  wire [AXI_USERW-1:0]                  wrq_user;
  wire [AXI_IDW-1:0]                    wrq_id_i;       // AXI write address ID
  wire                                  wrq_exa_resp_i;
  wire                                  wrq_slverr_i;
  wire [AXI_USERW-1:0]                  wrq_user_i;
  wire [ORDER_TOKENW-1:0]               ws_order_token;      
  wire [ENIF_DATAW-1:0]                 du_wdata;
  wire [ENIF_STRBW-1:0]                 du_wstrb;
  wire [ENIF_STRBW-1:0]                 du_wparity;
  wire [ENIF_STRBW-1:0]                 du_wpar_err;
  wire                                  du_wlast;  
  wire                                  dg_wlast;
  wire [AXI_ADDRW-1:0]                  au_addr;
  wire [AXI_LENW-1:0]                   au_alen;
  wire [ENIF_SIZEW-1:0]                 au_asize;
  wire [AXI_LOCKW-1:0]                  au_alock;
  wire [AXI_ADDRW-1:0]                  au_next_addr_wrap_autopre;
  wire [AXI_LENW-1:0]                   au_next_alen_wrap_autopre;
  
  // WAQ push/pop interface 
  wire [AXI_ADDRW-1:0]                  addr_waq;
  wire [AXI_ADDRW-1:0]                  addr_sar;
  wire [AXI_ADDRW-1:0]                  next_addr_wrap_autopre_sar;
  wire [AXI_ADDRW-1:0]                  waq_addr;
  wire [WAQ_SIZEW-1:0]                  asize_waq;
  wire [WAQ_SIZEW-1:0]                  waq_asize;
  wire [AXI_LENW-1:0]                   alen_waq;
  wire [AXI_LENW-1:0]                   waq_alen; 
  wire [AXI_IDW-1:0]                    id_waq;
  wire [AXI_IDW-1:0]                    waq_id;   
  wire [AXI_QOSW-1:0]                   qos_waq;
  wire [AXI_QOSW-1:0]                   waq_qos;
  wire [AXI_USERW-1:0]                  user_waq;
  wire [AXI_USERW-1:0]                  waq_user;
  wire                                  autopre_waq;
  wire                                  waq_autopre;
  wire [AXI_ADDRW-1:0]                  next_addr_wrap_autopre_waq;
  wire [AXI_ADDRW-1:0]                  waq_next_addr_wrap_autopre;
  wire [AXI_LENW-1:0]                   next_alen_wrap_autopre_waq;
  wire [AXI_LENW-1:0]                   waq_next_alen_wrap_autopre;
  wire                                  skip_waq;
  wire                                  waq_skip; 
  wire                                  split_waq;
  wire                                  waq_split_cc;
  wire                                  short_burst_waq;
  wire                                  waq_short_burst;
  wire                                  ws_short_burst;
  wire                                  hold_first_beat_unused;
  wire                                  poison_waq;
  wire                                  waq_poison;
  wire                                  ocpar_err_waq;
  wire                                  waq_ocpar_err;
  wire [WQOS_RW-1:0]                    write_qos_priority;
  wire                                  waq_mux_select, waq_mux_vpw_timeout;
  wire [AXI_LOCKW-1:0]                  lock_waq;
  wire [AXI_LOCKW-1:0]                  waq_lock;
  wire [ORDER_TOKENW-1:0]               order_token_waq;
  wire [ORDER_TOKENW-1:0]               waq_order_token;
  wire                                  waq_vpw_empty, waq_vpw_full, war_vpw_empty, war_vpw_full_unused;
  wire                                  vpw_gate_waq; // in case of vpw, we need to gate the wp -><- waq to prevent a counter value to be popped when nothing has been pushed yet
  wire                                  vpw_gate_in_waq;
  wire                                  waq_push_vpw, waq_push_aclk;
  wire [AXI_ADDRW-1:0]                  parity_addr;
  wire                                  parity_addr_error;
  wire [AXI_STRBW-1:0]                  wparity_i;
  wire [AXI_DATAW-1:0]                  parity_data;
  wire [AXI_STRBW-1:0]                  parity_data_error;
  wire [AXI_STRBW-1:0]                  wpar_err;
  reg                                   parity_data_intr;
  
  wire [AXI_DATAW-1:0]                  poison_wdata;
  wire                                  poison_valid;
  wire [AXI_WAQD_LG2:0]                 waq_wcount_i;
  wire                                  wp_data_channel, iq_data_channel; // 0: transaction goes to channel 0; 1: transaction goes to channel 1
  wire                                  e_bvalid_i;
  wire [WRQW-1:0]                       e_bresp_i;
  wire                                  ad_in_bypass_unused;

  wire [AXI_MAXSIZE_EXA-1:0]            waq_exa_addr;
  wire [AXI_LENW-1:0]                   waq_exa_alen;
  wire [AXI_SIZEW-1:0]                  waq_exa_asize;

  wire [M_ADDRW-1:0]                    pagematch_addrmap_mask_int;

  // write data last outstanding count
  reg  [OUTS_WRW-1:0]   owlast_cnt_nxt;
  wire [OUTS_WRW-1:0]   owlast_cnt;
  wire                owlast_cnt_nz;

  assign awwrap            = (awburst == 2'b10) ? 1'b1:1'b0;
  assign e_wdata           = dg_wdata;
  assign e_wpar_err        = dg_wpar_err;
  assign e_wparity         = dg_wparity;
  assign e_wdata_channel   = iq_data_channel; // TODO
  assign e_deacc_info      = iq_deacc_info;
  assign e_beat_count      = dg_beat_count;

  // occap errors
  wire ws_cmp_error, ws_cmp_error_full, ws_cmp_error_seq, ws_cmp_poison_complete;
  wire wp_cmp_error, wp_cmp_error_full, wp_cmp_error_seq, wp_cmp_poison_complete;
  wire au_cmp_error, au_cmp_error_full, au_cmp_error_seq, au_cmp_poison_complete;
  wire occap_xpi_waq_err, occap_xpi_up_sq_err, occap_xpi_dw_sq_err,occap_xpi_sq_err_c, occap_xpi_sq_err_a, occap_xpi_wdq_err, occap_xpi_iq_err, 
       occap_xpi_wrq_err, occap_xpi_war_err, occap_xpi_dg_par_err, occap_xpi_waq_vpw_err, occap_xpi_war_vpw_err, occap_xpi_wdu_par_err;
  wire occap_owlast_cnt_par_err;

  assign occap_xpi_write_c_par_err        = occap_xpi_waq_err | occap_xpi_sq_err_c | occap_xpi_wdq_err | occap_xpi_iq_err | occap_xpi_war_err | occap_xpi_dg_par_err | occap_xpi_waq_vpw_err | occap_xpi_war_vpw_err;
  assign occap_xpi_write_a_par_err        = occap_xpi_wrq_err | occap_xpi_sq_err_a | occap_xpi_wdu_par_err | occap_owlast_cnt_par_err | reg_ep_cs_prev_dca_err | reg_ep_cs_prev_dcb_err;

  generate
   if (AXI_SYNC==0) begin: sq_async 
      assign occap_xpi_sq_err_c = (DOWN_SIZE==1) ? occap_xpi_dw_sq_err : 1'b0;
      assign occap_xpi_sq_err_a = (UP_SIZE==1)   ? occap_xpi_up_sq_err : 1'b0;
   end
   else begin: sq_sync
      assign occap_xpi_sq_err_c = occap_xpi_dw_sq_err | occap_xpi_up_sq_err;
      assign occap_xpi_sq_err_a = 1'b0;
   end
  endgenerate


  assign occap_aclk_cmp_err               = ws_cmp_error | au_cmp_error;
  assign occap_aclk_cmp_err_full          = {ws_cmp_error_full,au_cmp_error_full};
  assign occap_aclk_cmp_err_seq           = {ws_cmp_error_seq,au_cmp_error_seq};
  assign occap_aclk_cmp_poison_complete   = {ws_cmp_poison_complete,au_cmp_poison_complete};

  assign occap_cclk_cmp_err               = wp_cmp_error;
  assign occap_cclk_cmp_err_full          = wp_cmp_error_full;
  assign occap_cclk_cmp_err_seq           = wp_cmp_error_seq;
  assign occap_cclk_cmp_poison_complete   = wp_cmp_poison_complete;

  //---------------------------------------------------------------------------
  // Write Address Queue
  //---------------------------------------------------------------------------

  generate
  // --
  // Synchronous FIFO
  // --
  if (AXI_SYNC==1)  begin: sync_waq

    DWC_ddr_umctl2_gfifo
            
        #(
          .WIDTH            (WAQW),
          .DEPTH            (AXI_WAQD),
          .ADDR_WIDTH       (AXI_WAQD_LG2),
          .COUNT_WIDTH      (AXI_WAQD_LG2+1),
          .OCCAP_EN         (OCCAP_EN),
          .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN)
          ) 
      waq (
           .clk             (aclk),
           .rst_n           (aresetn),
           .wr              (waq_wr),
           .d               (waq_d),
           .rd              (waq_rd),
           .par_en          (reg_ddrc_occap_en),
           .init_n          (1'b1),
           .ff              (waq_full),
           .wcount          (waq_wcount_i),
           .q               (waq_q),
           .fe              (waq_empty),
           .par_err         (occap_xpi_waq_err)
          `ifdef SNPS_ASSERT_ON
          `ifndef SYNTHESIS
          ,.disable_sva_fifo_checker_rd (1'b0)
          ,.disable_sva_fifo_checker_wr (1'b0)
          `endif // SYNTHESIS
          `endif // SNPS_ASSERT_ON
           );

  end // block: sync_waq
  // --
  // Asynchronous FIFO
  // --
  if (AXI_SYNC==0) begin: async_waq
    wire                   waq_push_fe_unused;
    wire [AXI_WAQD_LG2:0]  waq_push_wcount_unused;

    DWC_ddr_umctl2_gafifo
    
        #(
          .WIDTH              (WAQW),
          .DEPTH              (AXI_WAQD),
          .ADDR_WIDTH         (AXI_WAQD_LG2),
          .COUNT_WIDTH        (AXI_WAQD_LG2+1),
          .PUSH_SYNC          (ASYNC_FIFO_N_SYNC),
          .POP_SYNC           (ASYNC_FIFO_N_SYNC),
          .EARLY_PUSH_STAT    (ASYNC_FIFO_EARLY_PUSH_STAT),  // push side is all registered
          .EARLY_POP_STAT     (ASYNC_FIFO_EARLY_POP_STAT),   // registered /*unregistered pop_fe and pop_wcount*/ 
          .OCCAP_EN           (OCCAP_EN),
          .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)          
          )
      waq (
           .wclk               (aclk),
           .wrst_n             (aresetn),
           .wr                 (waq_wr),
           .d                  (waq_d),
           .rclk               (e_clk),
           .rrst_n             (e_rst_n),
           .rd                 (waq_rd),
           .par_en             (reg_ddrc_occap_en),
           .ff                 (waq_full),
           .push_wcount        (waq_push_wcount_unused),
           .pop_wcount         (waq_wcount_i), 
           .q                  (waq_q),
           .push_fe            (waq_push_fe_unused),
           .pop_fe             (waq_empty),
           .par_err            (occap_xpi_waq_err)
          `ifdef SNPS_ASSERT_ON
          `ifndef SYNTHESIS
          ,.disable_sva_fifo_checker_rd (1'b0)
          ,.disable_sva_fifo_checker_wr (1'b0)
          `endif // SYNTHESIS
          `endif // SNPS_ASSERT_ON
           );
    
  end // block: async_waq
  endgenerate


  //---------------------------------------------------------------------------
  // QoS mapper
  //---------------------------------------------------------------------------

   DWC_ddr_umctl2_xpi_qos
   
    #(
      .USE2AQ     (1),
      .AXI_QOSW   (AXI_QOSW),
      .QOS_MLW    (WQOS_MLW),
      .QOS_RW     (WQOS_RW)
    )
    U_qos_map
    (
      // inputs
      .qos_map_level1                     (wqos_map_level1),
      .qos_map_level2                     (wqos_map_level2),
      .qos_map_region0                    (wqos_map_region0),
      .qos_map_region1                    (wqos_map_region1),
      .qos_map_region2                    (wqos_map_region2),
      .qos_value                          (ws_qos),
      // outputs
      .qos_priority                       (write_qos_priority),
      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in different generate blocks
      .aq_mux_select                      (waq_mux_select)
      //spyglass enable_block W528
    );

  generate
    if (VPW_EN == 1) begin: VPW_en
  //---------------------------------------------------------------------------
  // VPW support module
  //---------------------------------------------------------------------------

   wire                 waq_in_vpw, waq_out_vpw, waq_vpw_pop;
   wire                 waq_vpw_exp, war_vpw_exp;
   wire [WQOS_TW-1:0]   waq_vpw_timeout, war_vpw_timeout;
   wire                 wqos_map_timeout_zero;
   wire [WQOS_TW-1:0]   ep_timeout;
   wire                 ep_vpw_exp;
   wire                 waq_push_sync_full;
   wire [WQOS_TW-1:0]   wqos_map_timeout_int;

   assign wqos_map_timeout_int = waq_mux_vpw_timeout ? wqos_map_timeout2 : wqos_map_timeout1;

   assign wqos_map_timeout_zero = ~|wqos_map_timeout_int;

       DWC_ddr_umctl2_xpi_vpt
       
       #(
          .CNT_WIDTH        (WQOS_TW),
          .CNT_DEPTH        (AXI_WAQD),
          .OCCAP_EN         (OCCAP_EN),
          .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN)          
       )
       U_xpi_waq_vpw
       (
         // inputs
          .e_clk               (e_clk),
          .e_rst_n             (e_rst_n),
          .push                (waq_push_vpw),
          .pop                 (waq_vpw_pop),
          .input_timeout       (wqos_map_timeout_int),
          .input_timeout_zero  (wqos_map_timeout_zero),
          .reg_ddrc_occap_en   (reg_ddrc_occap_en),
          
          // outputs
          
          //spyglass disable_block W528
          //SMD: Variable set but not read
          //SJ: Used in different generate blocks
          .counters_empty      (waq_vpw_empty),
          .counters_full       (waq_vpw_full),
          //spyglass enable_block W528
          .output_timeout_zero (waq_vpw_exp),
          .output_timeout      (waq_vpw_timeout),
          .occap_xpi_vpt_par_err (occap_xpi_waq_vpw_err)
       );

      if (USE_WAR==1) begin: WAR_en

         wire war_in_vpw_expired;

         assign war_in_vpw_expired = ~|waq_vpw_timeout;

         DWC_ddr_umctl2_xpi_vpt
         
         #(
          .CNT_WIDTH        (WQOS_TW),
          .CNT_DEPTH        (WAR_DEPTH),
          .OCCAP_EN         (OCCAP_EN),
          .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN)          
         )
         U_xpi_war_vpw
         (
            // inputs
            .e_clk               (e_clk),
            .e_rst_n             (e_rst_n),
            .push                (war_push),
            .pop                 (war_pop),
            .input_timeout       (waq_vpw_timeout),
            .input_timeout_zero  (war_in_vpw_expired),
            .reg_ddrc_occap_en   (reg_ddrc_occap_en),
            // outputs
            
            //spyglass disable_block W528
            //SMD: Variable set but not read
            //SJ: Used in different generate blocks
            .counters_empty      (war_vpw_empty),
            //spyglass enable_block W528
            .counters_full       (war_vpw_full_unused),
            .output_timeout_zero (war_vpw_exp),
            .output_timeout      (war_vpw_timeout),
            .occap_xpi_vpt_par_err (occap_xpi_war_vpw_err)
         );


         assign ep_vpw_exp = (war_vpw_exp | waq_vpw_exp) & e_awvalid;
         assign ep_timeout = war_vpw_timeout;

      end
      else begin: WAR_nen

         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in different generate blocks
         assign war_vpw_empty = 1'b0;
         //spyglass enable_block W528
         assign war_vpw_full_unused  = 1'b0;
         assign ep_vpw_exp    = waq_vpw_exp;
         assign ep_timeout    = waq_vpw_timeout;
         assign occap_xpi_war_vpw_err = 1'b0; 
      end

      assign ep_post_write_qos_priority = ep_write_qos_priority;
      assign e_wqos_timeout             = ep_timeout;
      assign e_vpw_expired              = ep_vpw_exp;
      assign waq_in_vpw                 = (write_qos_priority_waq == VPRW) ? 1'b1 : 1'b0;
      assign waq_out_vpw                = (waq_write_qos_priority == VPRW) ? 1'b1 : 1'b0;
      assign waq_vpw_pop                = waq_rd & ~waq_empty & waq_out_vpw;
      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in different generate blocks
      assign war_in_vpw                 = waq_out_vpw; 
      assign war_out_vpw                = (e_wqos_priority == VPRW) ? 1'b1 : 1'b0;          
      assign waq_push_aclk              = waq_wr & ~waq_full & waq_in_vpw;
      //spyglass enable_block W528
      assign vpw_gate_waq               = waq_vpw_empty & waq_out_vpw;
      assign vpw_gate_in_waq            = waq_push_sync_full; // gate when full regardless of the transaction type, otherwise loop awqos -> awready (full condition should never happen anyway)

      if (AXI_SYNC==0) begin:ASYNC_push      

      //--------------------------------------------------------------------------------
      //  Push Synchronizer
      //--------------------------------------------------------------------------------


         wire waq_pop_eclk, pop_empty, push_empty, push_full, pop_full;
         wire occap_xpi_vpw_fifo_err_unused;
         wire [AXI_WAQD_LG2:0]  vpw_push_wcount_unused, vpw_pop_wcount_unused;
         wire vpw_push_fe_unused;

         assign waq_pop_eclk     = ~waq_vpw_full;
         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in different generate blocks
         assign waq_push_vpw     = ~pop_empty;
         //spyglass enable_block W528

         DWC_ddr_umctl2_gafifo
         
         #(
          .WIDTH              (1),
          .DEPTH              (AXI_WAQD),
          .ADDR_WIDTH         (AXI_WAQD_LG2),
          .COUNT_WIDTH        (AXI_WAQD_LG2+1),
          .PUSH_SYNC          (ASYNC_FIFO_N_SYNC),
          .POP_SYNC           (ASYNC_FIFO_N_SYNC),
          .EARLY_PUSH_STAT    (ASYNC_FIFO_EARLY_PUSH_STAT),  // push side is all registered
          .EARLY_POP_STAT     (ASYNC_FIFO_EARLY_POP_STAT),   // registered /*unregistered pop_fe and pop_wcount*/ 
          .OCCAP_EN           (OCCAP_EN),
          .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)          
          )
         vpw_prio (
           .wclk               (aclk),
           .wrst_n             (aresetn),
           .wr                 (waq_push_aclk),
           .d                  (waq_mux_select),
           .rclk               (e_clk),
           .rrst_n             (e_rst_n),
           .rd                 (waq_pop_eclk),
           .par_en             (1'b0),
           .ff                 (push_full),
           .push_wcount        (vpw_push_wcount_unused),
           .pop_wcount         (vpw_pop_wcount_unused), 
           .q                  (waq_mux_vpw_timeout),
           .push_fe            (vpw_push_fe_unused),
           .pop_fe             (pop_empty),
           .par_err            (occap_xpi_vpw_fifo_err_unused)
          `ifdef SNPS_ASSERT_ON
          `ifndef SYNTHESIS
          ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~pop_empty
          ,.disable_sva_fifo_checker_wr (1'b0)
          `endif // SYNTHESIS
          `endif // SNPS_ASSERT_ON
           );

           assign waq_push_sync_full = push_full;

`ifdef SNPS_ASSERT_ON

  //---------------------------------------------------------------------------
  //  Assertion fifo checker instance
  //---------------------------------------------------------------------------

`ifndef SYNTHESIS

  property e_wr_when_fifo_full;
    @(posedge aclk)  (push_full) |-> (!waq_push_aclk);
  endproperty  

    a_wr_when_fifo_full : assert property (e_wr_when_fifo_full)   else $display("-> %0t ERROR: Writing when async fifo full", $realtime);
    

`endif // SYNTHESIS
`endif //SNPS_ASSERT_ON
      end
      else begin:SYNC_push

         assign waq_push_sync_full     = waq_vpw_full;
         //spyglass disable_block W528
         //SMD: Variable set but not read
         //SJ: Used in different generate blocks
         assign waq_push_vpw           = waq_push_aclk;
         //spyglass enable_block W528
         assign waq_mux_vpw_timeout    = waq_mux_select;

      end

`ifdef SNPS_ASSERT_ON
  //---------------------------------------------------------------------------
  //  Assertion fifo checker instance
  //---------------------------------------------------------------------------

`ifndef SYNTHESIS

    cp_vpt_full_gate_awready : cover property (@(posedge aclk) disable iff(!aresetn) vpw_gate_in_waq==1'b1);

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
    end else begin: VPW_nen

      assign war_vpw_full_unused           = 1'b0;
      //spyglass disable_block W528
      //SMD: Variable set but not read
      //SJ: Used in different generate blocks
      assign war_in_vpw                    = 1'b0; 
      assign war_out_vpw                   = 1'b0;           
      assign waq_vpw_empty                 = 1'b0;
      assign waq_vpw_full                  = 1'b0;
      assign war_vpw_empty                 = 1'b0; 
      assign waq_push_aclk                 = 1'b0; 
      assign waq_push_vpw                  = 1'b0;                
      //spyglass enable_block W528
      assign vpw_gate_waq                  = 1'b0;
      assign vpw_gate_in_waq               = 1'b0;
      assign e_vpw_expired                 = 1'b0;
      assign e_wqos_timeout                = {WQOS_TW{1'b0}};
      assign ep_post_write_qos_priority[0] = 1'b0;
      assign ep_post_write_qos_priority[1] = ep_write_qos_priority[1];

      assign occap_xpi_waq_vpw_err         = 1'b0;
      assign occap_xpi_war_vpw_err         = 1'b0;
    end
  endgenerate

  assign waq_rd            = ~ep_full & ~vpw_gate_waq;

  // output debug signals
  always @(posedge e_clk, negedge e_rst_n) begin
   if (~e_rst_n) begin
      waq_wcount  <= {(AXI_WAQD_LG2+1){1'b0}};
      waq_pop     <= 1'b0;
   end
   else begin
      waq_wcount  <= waq_wcount_i;
      waq_pop     <= waq_rd;
   end
  end

  always @(posedge aclk or negedge aresetn) begin
   if (~aresetn) begin
      waq_push    <= 1'b0;
      waq_split   <= 1'b0;
   end
   else begin
      waq_push    <= waq_wr;
      waq_split   <= ws_split;
   end
  end
   
  assign awready           = ~ws_full;

  generate 
    if (UP_SIZE==1) begin :usize_asize_waq   
      assign waq_wr     = ~au_empty & ~waq_full & ~vpw_gate_in_waq; //TBD-HRE : In AU bypass mode - empty = ~wr
      assign addr_sar   = au_addr; //TBD-HRE : In AU bypass mode - addr_up = addr
      assign next_addr_wrap_autopre_sar = au_next_addr_wrap_autopre; //TBD-HRE : In AU bypass mode - next_addr_wrap_autopre_up = next_addr_wrap_autopre
      assign asize_waq  = au_asize; //TBD-HRE : In AU bypass mode -asize_up = asize
      assign alen_waq   = au_alen; //TBD-HRE : In AU bypass mode -alen_up = alen
      assign next_alen_wrap_autopre_waq = au_next_alen_wrap_autopre; //TBD-HRE : In AU bypass mode -next_alen_wrap_autopre_up = next_alen_wrap_autopre
      assign lock_waq   = au_alock; //TBD-HRE : In AU bypass mode - alock_up = alock
      assign ws_rd      = ~au_full; //TBD-HRE : In bypass - full = ~rd     
    end
    else begin : eqsize_asize_waq
      assign waq_wr     = ~ws_empty & ~waq_full & ~vpw_gate_in_waq;
      assign addr_sar   = ws_addr;
      assign next_addr_wrap_autopre_sar = ws_next_addr_wrap_autopre;
      assign asize_waq  = ws_asize;
      assign alen_waq   = ws_alen;
      assign next_alen_wrap_autopre_waq = ws_next_alen_wrap_autopre;
      assign lock_waq   = ws_lock;
      assign ws_rd      = ~waq_full & ~vpw_gate_in_waq;     
    end
  endgenerate
 
  assign id_waq            = ws_id;
  assign user_waq          = ws_user;
  assign qos_waq           = ws_qos;
  assign skip_waq          = ws_skip;
  assign split_waq         = ws_split;
  assign short_burst_waq   = ws_short_burst;
  assign poison_waq        = ws_poison;
  assign ocpar_err_waq     = ws_ocpar_err;
  
  assign order_token_waq   = ws_order_token;
  assign autopre_waq       = ws_autopre;

  assign write_qos_priority_waq  = write_qos_priority;
  assign ep_write_qos_priority   = waq_write_qos_priority;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(((((1 + 1) + AXI_USERW) + 1) + AXI_ADDRW) + AXI_LENW)' found in module 'DWC_ddr_umctl2_xpi_write'
//SJ: This coding style is acceptable and there is no plan to change it.
  field_packer15
  
   # (AXI_ADDRW,WAQ_SIZEW,AXI_LENW,AXI_IDW,AXI_QOSW,1,1,1,AXI_LOCKW,ORDER_TOKENW,1+1+AXI_USERW+1+AXI_ADDRW+AXI_LENW,WQOS_RW,AXI_MAXSIZE_EXA,AXI_LENW,AXI_SIZEW)
  waq_field_packer
    (// Outputs
     .out0                      (waq_addr),
     .out1                      (waq_asize),
     .out2                      (waq_alen),
     .out3                      (waq_id),
     .out4                      (waq_qos),
     .out5                      (waq_short_burst), 
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in different generate blocks 
     .out6                      (waq_skip),
//spyglass enable_block W528
     .out7                      (waq_split_cc),
     .out8                      (waq_lock),
     .out9                      (waq_order_token),
     .out10                     ({waq_poison,waq_ocpar_err,waq_user,waq_autopre,waq_next_addr_wrap_autopre,waq_next_alen_wrap_autopre}),
     .out11                     (waq_write_qos_priority),
     .out12                     (waq_exa_addr),
     .out13                     (waq_exa_alen),
     .out14                     (waq_exa_asize),
     .pack_out                  (waq_d),
     // Inputs
     .in0                       (addr_waq),
     .in1                       (asize_waq),
     .in2                       (alen_waq),
     .in3                       (id_waq),
     .in4                       (qos_waq),
     .in5                       (short_burst_waq),  
     .in6                       (skip_waq),
     .in7                       (split_waq),
     .in8                       (lock_waq),
     .in9                       (order_token_waq),
     .in10                      ({poison_waq,ocpar_err_waq,user_waq,autopre_waq,next_addr_wrap_autopre_waq,next_alen_wrap_autopre_waq}),
     .in11                      (write_qos_priority_waq),
     .in12                      (ws_addr[AXI_MAXSIZE_EXA-1:0]),
     .in13                      (ws_alen),
     .in14                      (ws_asize),
     .pack_in                   (waq_q));
//spyglass enable_block SelfDeterminedExpr-ML
  //---------------------------------------------------------------------------
  // Address DownSizer 
  //---------------------------------------------------------------------------

  generate    
  if (DOWN_SIZE==1)  begin: down_size
 
  wire                  ad_wr,ad_rd,ad_full_unused,ad_empty;          // AD handshake 
  
  wire [AXI_ADDRW-1:0]  ad_addr;
  wire [ENIF_LENW-1:0]  ad_alen;
  wire [ENIF_SIZEW-1:0] ad_asize;
  wire [AXI_ADDRW-1:0]  ad_next_addr_wrap_autopre;
  wire [ENIF_LENW-1:0]  ad_next_alen_wrap_autopre;
  
  wire [ENIF_DATAW-1:0]  dd_wdata;
  wire [ENIF_STRBW-1:0]  dd_wstrb;
  wire [ENIF_STRBW-1:0]  dd_wparity;
  wire  [ENIF_STRBW-1:0] dd_wpar_err;
   
  DWC_ddr_umctl2_xpi_ad
  
  
  #(
   .WR              (1),
   .AXI_DATAW       (AXI_DATAW),
   .AXI_STRBW       (AXI_STRBW),
   .AXI_MAXSIZE     (AXI_MAXSIZE),
   .AXI_SIZEW       (WAQ_SIZEW),
   .AXI_ADDRW       (AXI_ADDRW),
   .AXI_LENW        (AXI_LENW),
   .PDBW_CASE       (PDBW_CASE),   

   .ENIF_DATAW      (ENIF_DATAW),
   .ENIF_STRBW      (ENIF_STRBW),
   .ENIF_MAXSIZE    (ENIF_MAXSIZE),
   .ENIF_SIZEW      (ENIF_SIZEW),
   .ENIF_LENW       (ENIF_LENW),
   .WRAP_LENW       (WRAP_LENW),
   .INFOW           (SIZEINFOW)
    )
   U_ad (
    // Outputs
    .empty      (ad_empty), 
    .full       (ad_full_unused), 
    .addr_down  (ad_addr), 
    .alen_down  (ad_alen),  
    .asize_down (ad_asize),
    .sq_wr      (dw_sq_wr), 
    .ad_in_bypass (ad_in_bypass_unused),
    .info       (dw_sq_d),
    .next_addr_wrap_autopre_down(ad_next_addr_wrap_autopre),
    .next_alen_wrap_autopre_down(ad_next_alen_wrap_autopre),
    // Inputs
    .clk        (e_clk), 
    .rst_n      (e_rst_n), 
    .wr         (ad_wr), 
    .skip       (waq_skip),
    .split      (waq_split_cc),
    .rd         (ad_rd), 
    .addr       (waq_addr), 
    .alen       (waq_alen),  
    .asize      (waq_asize), 
    .sq_full    (dw_sq_full),
    .reg_ddrc_data_bus_width (reg_ddrc_data_bus_width),
    .next_addr_wrap_autopre(waq_next_addr_wrap_autopre),
    .next_alen_wrap_autopre(waq_next_alen_wrap_autopre)
   );
      
  assign ad_wr = ~waq_empty & ~vpw_gate_waq;
  assign ad_rd = ~ep_full;

  //---------------------------------------------------------------------------
  // DATA DownSizer 
  //---------------------------------------------------------------------------
  DWC_ddr_umctl2_xpi_wdd
  
  
  #(
   .IN_DATAW        (IN_DATAW),
   .IN_STRBW        (IN_STRBW),
   .AXI_MAXSIZE     (AXI_MAXSIZE),
   .AXI_SIZEW       (WAQ_SIZEW),
   .ENIF_DATAW      (ENIF_DATAW),
   .ENIF_STRBW      (ENIF_STRBW),
   .ENIF_MAXSIZE    (ENIF_MAXSIZE),
   .ENIF_SIZEW      (ENIF_SIZEW),
   .WRAP_LENW       (WRAP_LENW),
   .PDBW_CASE       (PDBW_CASE),
   .INFOW           (SIZEINFOW)    
   )
   U_wdd (
   // Outputs
   .sq_rd        (dw_sq_rd), 
   .data_down    (dd_wdata), 
   .wstrb_down   (dd_wstrb),
   .parity_down  (dd_wparity),
   .par_err_down (dd_wpar_err),
   .wlast_down   (dd_wlast),     
   .empty        (dd_empty),
   .full         (dd_full), 
   // Inputs
   .clk          (e_clk),
   .rst_n        (e_rst_n), 
   .wr           (dd_wr), 
   .rd           (dd_rd),
   .data         (wdq_wdata),
   .reg_ddrc_data_bus_width (reg_ddrc_data_bus_width),
   .wstrb        (wdq_wstrb),
   .parity       (wdq_wparity),
   .par_err      (wdq_wpar_err),
   .wlast        (wdq_wlast),    
   .sq_empty     (dw_sq_empty),
   .info         (dw_sq_q)
   );
    assign dd_wr = ~wdq_empty;
    assign dd_rd = ~iq_empty & ~dg_full;
   
    assign wdata_dg     = dd_wdata;
    assign ep_wr        = ~ad_empty;
    assign addr_ep      = ad_addr;
    assign alen_ep      = ad_alen ;
    assign next_addr_wrap_autopre_ep = ad_next_addr_wrap_autopre;
    assign next_alen_wrap_autopre_ep = ad_next_alen_wrap_autopre;
    assign asize_ep     = ad_asize;
    assign wstrb_dg     = dd_wstrb;
    assign wpar_err_dg  = dd_wpar_err;
    assign wparity_dg   = dd_wparity;
  end // block: address_down_sizer
  else begin: down_size_n
    assign wdata_dg     = wdq_wdata;
    assign ep_wr        = ~waq_empty & ~vpw_gate_waq;
    assign addr_ep      = waq_addr;
    assign alen_ep      = waq_alen;
    assign next_addr_wrap_autopre_ep = waq_next_addr_wrap_autopre;
    assign next_alen_wrap_autopre_ep = waq_next_alen_wrap_autopre;
    assign asize_ep     = waq_asize;
    assign wstrb_dg     = wdq_wstrb;     
    assign wparity_dg   = wdq_wparity;
    assign wpar_err_dg  = wdq_wpar_err;
  end

  //---------------------------------------------------------------------------
  // Address UPSizer 
  //---------------------------------------------------------------------------
  if (UP_SIZE==1)  begin: up_size
  DWC_ddr_umctl2_xpi_au_wrapper
  
  #(
   .OCCAP_EN        (OCCAP_EN),
   .CMP_REG         (OCCAP_PIPELINE_EN), // registers on inputs in comparator for pipelining
   .WR              (1),
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
   .WRAP_LENW       (WRAP_LENW),
   .INFOW           (SIZEINFOW)
    )
   U_au (
    // Outputs
    .empty      (au_empty), 
    .full       (au_full), 
    .addr_up    (au_addr), 
    .alen_up    (au_alen),  
    .asize_up   (au_asize),
    .alock_up   (au_alock),
    .sq_wr      (up_sq_wr), 
    .next_addr_wrap_autopre_up(au_next_addr_wrap_autopre),
    .next_alen_wrap_autopre_up(au_next_alen_wrap_autopre),
    .info       (up_sq_d),
    .au_cmp_error             (au_cmp_error),
    .au_cmp_error_full        (au_cmp_error_full),
    .au_cmp_error_seq         (au_cmp_error_seq),
    .au_cmp_poison_complete   (au_cmp_poison_complete),
    // Inputs
    .clk        (aclk), 
    .rst_n      (aresetn), 
    .reg_ddrc_data_bus_width (reg_arba_data_bus_width),
    .wr         (au_wr), 
    .skip       (ws_skip),
    .split      (ws_split),
    .short_wrap (ws_short_burst),
    .hold_first_beat (1'b0), 
    .next_addr_wrap_autopre(ws_next_addr_wrap_autopre),
    .next_alen_wrap_autopre(ws_next_alen_wrap_autopre),
    .rd         (au_rd), 
    .addr       (ws_addr), 
    .alen       (ws_alen),  
    .asize      (ws_asize), 
    .alock      (ws_lock), 
    .sq_full    (up_sq_full),
    .au_cmp_en          (reg_ddrc_occap_en),
    .au_cmp_poison      (reg_arb_occap_arb_cmp_poison_seq),
    .au_cmp_poison_full (reg_arb_occap_arb_cmp_poison_parallel),
    .au_cmp_poison_err_inj (reg_arb_occap_arb_cmp_poison_err_inj)

   );
   
  assign au_wr = ~ws_empty;
  assign au_rd = ~waq_full & ~vpw_gate_in_waq;
  DWC_ddr_umctl2_xpi_wdu
  
  
  #(
   .AXI_DATAW           (AXI_DATAW),
   .AXI_STRBW           (AXI_STRBW),
   .AXI_MAXSIZE         (AXI_MAXSIZE),
   .AXI_SIZEW           (AXI_SIZEW),
   .ENIF_DATAW          (ENIF_DATAW),
   .ENIF_STRBW          (ENIF_STRBW),
   .ENIF_MAXSIZE        (ENIF_MAXSIZE),
   .ENIF_SIZEW          (ENIF_SIZEW),
   .WRAP_LENW           (WRAP_LENW),
   .INFOW               (SIZEINFOW), 
   .PDBW_CASE           (PDBW_CASE),
   .OCCAP_EN            (OCCAP_EN),
   .OCCAP_PIPELINE_EN   (OCCAP_PIPELINE_EN)
   )
   U_wdu (
   // Outputs
   .sq_rd        (up_sq_rd), 
   .data_up      (du_wdata), 
   .wstrb_up     (du_wstrb),
   .parity_up    (du_wparity),
   .par_err_up   (du_wpar_err),
   .last_up      (du_wlast),     
   .empty        (du_empty),
   .full         (du_full),
   .occap_xpi_wdu_par_err (occap_xpi_wdu_par_err),
   // Inputs
   .clk          (aclk),
   .rst_n        (aresetn),
   .reg_ddrc_data_bus_width (reg_arba_data_bus_width),
   .rst_dly      (a_rst_dly),
   .wr           (du_wr), 
   .rd           (du_rd),
   .data         (wdata),
   .wstrb        (wstrb),
   .parity       (wparity_i),
   .parity_type  (reg_arb_oc_parity_type),
   .par_err      (wpar_err),
   .last         (wlast),    
   .sq_empty     (up_sq_empty),
   .info         (up_sq_q),
   .reg_ddrc_occap_en (reg_ddrc_occap_en)
   );
  assign du_wr = wvalid;
  assign du_rd = ~wdq_full;

  end // block: up_size
  else begin: n_up_size

      assign au_cmp_error           = 1'b0;
      assign au_cmp_error_full      = 1'b0;
      assign au_cmp_error_seq       = 1'b0;
      assign au_cmp_poison_complete = 1'b1;

      assign occap_xpi_wdu_par_err  = 1'b0;

  end

  //IF M_DW is less than 32 in CASE2 then QBW cant be supported
  // So DWSIZER is not needed
  // This means Dual SQ is not needed 
  if (PDBW_CASE ==2 && !(M_DW<32) ) begin : dual_sq_inst


    wire [SQD_LG2:0] up_sq_wcount_unused;
    wire [SQD_LG2:0] dw_sq_wcount_unused;
 //---------------------------------------
 //  SQ for Upsizer pair
 //---------------------------------------
      DWC_ddr_umctl2_gfifo
      
      
      #(
        .WIDTH              (SQW),
        .DEPTH              (SQD),
        .ADDR_WIDTH         (SQD_LG2),
        .COUNT_WIDTH        (SQD_LG2+1),
        .OCCAP_EN           (OCCAP_EN),
        .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)
        ) 
    sq_upsize (
        .clk             (aclk),
        .rst_n           (aresetn),
        .wr              (up_sq_wr),  
        .d               (up_sq_d),
        .rd              (up_sq_rd), 
        .par_en          (reg_ddrc_occap_en),
        .init_n          (1'b1),
        .ff              (up_sq_full),
        .wcount          (up_sq_wcount_unused), // not used
        .q               (up_sq_q),
        .fe              (up_sq_empty),
       //spyglass disable_block W528
       //SMD: A signal or variable is set but never read
       //SJ: Used in generate block
        .par_err         (occap_xpi_up_sq_err)
       //spyglass enable_block W528  
        );

 //---------------------------------------
 //  SQ for Downsizer pair
 //---------------------------------------
      DWC_ddr_umctl2_gfifo
      
      
      #(
        .WIDTH              (SQW),
        .DEPTH              (SQD),
        .ADDR_WIDTH         (SQD_LG2),
        .COUNT_WIDTH        (SQD_LG2+1),
        .OCCAP_EN           (OCCAP_EN),
        .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)
        ) 
    sq_dwsize (
        .clk             (e_clk),
        .rst_n           (e_rst_n),
        .wr              (dw_sq_wr),  
        .d               (dw_sq_d),
        .rd              (dw_sq_rd), 
        .par_en          (reg_ddrc_occap_en),
        .init_n          (1'b1),
        .ff              (dw_sq_full),
        .wcount          (dw_sq_wcount_unused), // not used
        .q               (dw_sq_q),
        .fe              (dw_sq_empty),
       //spyglass disable_block W528
       //SMD: A signal or variable is set but never read
       //SJ: Used in generate block        
        .par_err         (occap_xpi_dw_sq_err)
       //spyglass enable_block W528          
        );

  end
  else if ((DOWN_SIZE==1 || UP_SIZE==1))  begin: single_sq_inst
    
    wire             sq_clk;
    wire             sq_rst_n;
    wire [SQD_LG2:0] sq_wcount_unused;
    wire             occap_xpi_sq_err;
    
    assign sq_clk   = (UP_SIZE==1)?aclk:e_clk;
    assign sq_rst_n = (UP_SIZE==1)?aresetn:e_rst_n;
    assign sq_wr    = (UP_SIZE==1)?up_sq_wr : dw_sq_wr; 
    assign sq_rd    = (UP_SIZE==1)?up_sq_rd : dw_sq_rd; 
    assign sq_d     = (UP_SIZE==1)?up_sq_d : dw_sq_d; 
    //spyglass disable_block W528
    //SMD: Variable set but not read
    //SJ: Used in different generate blocks
    assign up_sq_full = sq_full;
    assign dw_sq_full = sq_full;
    assign up_sq_empty = sq_empty;
    assign dw_sq_empty = sq_empty;
    assign up_sq_q = sq_q;
    assign dw_sq_q = sq_q;
    assign occap_xpi_up_sq_err = (UP_SIZE==1)  ? occap_xpi_sq_err : 1'b0;
    assign occap_xpi_dw_sq_err = (DOWN_SIZE==1)? occap_xpi_sq_err : 1'b0;
    //spyglass enable_block W528  
    //---------------------------------------------------------------------------
    // Size Queue
    //---------------------------------------------------------------------------
    DWC_ddr_umctl2_gfifo
    
      
      #(
        .WIDTH              (SQW),
        .DEPTH              (SQD),
        .ADDR_WIDTH         (SQD_LG2),
        .COUNT_WIDTH        (SQD_LG2+1),
        .OCCAP_EN           (OCCAP_EN),
        .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)        
        ) 
    sq (
        .clk             (sq_clk),
        .rst_n           (sq_rst_n),
        .wr              (sq_wr),  
        .d               (sq_d),
        .rd              (sq_rd), 
        .par_en          (reg_ddrc_occap_en),
        .init_n          (1'b1),
        .ff              (sq_full),
        .wcount          (sq_wcount_unused), // not used
        .q               (sq_q),
        .fe              (sq_empty),
        .par_err         (occap_xpi_sq_err)
        `ifdef SNPS_ASSERT_ON
        `ifndef SYNTHESIS
        ,.disable_sva_fifo_checker_rd (1'b0)
        ,.disable_sva_fifo_checker_wr (1'b0)
        `endif // SYNTHESIS
        `endif // SNPS_ASSERT_ON
        );
  end // block: single_sq_inst
  else begin: sq_ninst
    //spyglass disable_block W528
    //SMD: Variable set but not read
    //SJ: Used in different generate blocks
      assign occap_xpi_sq_err = 1'b0;
    //spyglass enable_block W528  
  end
    
  endgenerate
   
  //---------------------------------------------------------------------------
  // Write Data Queue
  //---------------------------------------------------------------------------

  generate
  // --
  // Synchronous FIFO
  // --
  if (AXI_SYNC==1)  begin: sync_wdata_fifo
  DWC_ddr_umctl2_gfifo
  
  
   #(
    .WIDTH              (WDQW),
    .DEPTH              (AXI_WDQ1D),
    .ADDR_WIDTH         (AXI_WDQ1D_LG2),
    .COUNT_WIDTH        (AXI_WDQ1D_LG2+1),
    .OCCAP_EN           (OCCAP_EN),
    .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)    
    ) 
    wdq (
    .clk             (aclk),
    .rst_n           (aresetn),
    .wr              (wdq_wr),
    .d               (wdq_d),
    .rd              (wdq_rd),
    .par_en          (reg_ddrc_occap_en), 
    .init_n          (1'b1),
    .ff              (wdq_full),
    .wcount          (wdq_wcount_unused),
    .q               (wdq_q),
    .fe              (wdq_empty),
    .par_err         (occap_xpi_wdq_err)
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~wdq_empty
    ,.disable_sva_fifo_checker_wr (1'b0)
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
    );
    assign wdq_empty_aclk = wdq_empty;
  end // block: sync_wdata_fifo
  // --
  // Asynchronous FIFO
  // --
  if (AXI_SYNC==0) begin: async_wdq
    wire [AXI_WDQ1D_LG2:0] wdq_push_wcount_unused;

    DWC_ddr_umctl2_gafifo
    
    
    #(
    .WIDTH              (WDQW),
    .DEPTH              (AXI_WDQ1D),
    .ADDR_WIDTH         (AXI_WDQ1D_LG2),
    .COUNT_WIDTH        (AXI_WDQ1D_LG2+1),
    .PUSH_SYNC          (ASYNC_FIFO_N_SYNC),
    .POP_SYNC           (ASYNC_FIFO_N_SYNC),
    .EARLY_PUSH_STAT    (ASYNC_FIFO_EARLY_PUSH_STAT),   // push side is all registered
    .EARLY_POP_STAT     (ASYNC_FIFO_EARLY_POP_STAT),   // registered /*unregistered pop_fe and pop_wcount*/
    .OCCAP_EN           (OCCAP_EN),
    .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)    
    )
    wdq (
    .wclk               (aclk),
    .wrst_n             (aresetn),
    .wr                 (wdq_wr),
    .d                  (wdq_d),
    .rclk               (e_clk),
    .rrst_n             (e_rst_n),
    .rd                 (wdq_rd),
    .par_en             (reg_ddrc_occap_en),
    .ff                 (wdq_full),
    .pop_wcount         (wdq_wcount_unused),
    .push_wcount        (wdq_push_wcount_unused),      
    .q                  (wdq_q),
    .push_fe            (wdq_empty_aclk),
    .pop_fe             (wdq_empty),
    .par_err            (occap_xpi_wdq_err)
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~wdq_empty
    ,.disable_sva_fifo_checker_wr (1'b0)
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
    );

  end // block: async_wdq
  endgenerate
  
  wire [ENIF_PARW-1:0] ecc_out;

  generate
    if (UP_SIZE==1) begin: wdq_up
      assign wdq_d_mux = {du_wlast,
                          du_wpar_err,
                          du_wstrb,
                          du_wparity,
                          du_wdata};
      assign wdq_wr = ~du_empty & ~wdq_full;
      assign wready = ~du_full;    
    end
    else begin:wdq_nup
      assign wdq_d_mux = {wlast,
                          wpar_err,
                          wstrb,
                          wparity_i,
                          wdata};
      assign wdq_wr = wvalid & ~wdq_full;
      assign wready = ~wdq_full;        
    end
    
    if (DOWN_SIZE==1) begin: wdq_down
      assign wdq_rd = ~dd_full;
    end
    else begin : wdq_ndown
      assign wdq_rd = ~iq_empty & ~dg_full;    
    end
    
  endgenerate 

  assign wdq_d        = wdq_d_mux;
  assign {wdq_wlast,
          wdq_wpar_err,
          wdq_wstrb,
          wdq_wparity,
          wdq_wdata}       = wdq_q;
   
  //---------------------------------------------------------------------------
  // Write Address Retime
  //---------------------------------------------------------------------------
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((((1 + 1) + 1) + AXI_USERW) + 1)' found in module 'DWC_ddr_umctl2_xpi_write'
//SJ: This coding style is acceptable and there is no plan to change it.
  field_packer13
  
   # (WQOS_RW,M_ADDRW,AXI_IDW,AXI_QOSW,1,EXA_PYLD_W,1,1,1,1,1,ORDER_TOKENW,1+1+1+AXI_USERW+1)
  war_field_packer
    (// Outputs
     .out0                      (e_wqos_priority),
     .out1                      (e_awaddr),
     .out2                      (e_awid),
     .out3                      (e_awqos),
     .out4                      (e_awlast),
     .out5                      (e_exa_pyld),
     .out6                      (e_exa_acc),
     .out7                      (e_exa_acc_lock),
     .out8                      (e_awpagematch),
     .out9                      (e_split),
     .out10                     (e_short_burst),
     .out11                     (xpi_write_order_token),
     .out12                     ({e_poison,e_ocpar_err,e_awdata_channel,e_awuser,e_awautopre}),
     .pack_out                  (war_d),
     // Inputs
     .in0                       (ep_post_write_qos_priority),
     .in1                       (ep_addr),
     .in2                       (waq_id),
     .in3                       (waq_qos),
     .in4                       (ep_alast),
     .in5                       (ep_exa_pyld),
     .in6                       (ep_exa_acc),
     .in7                       (ep_exa_acc_lock),
     .in8                       (ep_awpagematch),
     .in9                       (waq_split_cc),
     .in10                      (waq_short_burst),
     .in11                      (waq_order_token),     
     .in12                      ({waq_poison,waq_ocpar_err,wp_data_channel,waq_user,ep_autopre}),
     .pack_in                   (war_q)
     );
//spyglass enable_block SelfDeterminedExpr-ML
  
  assign e_awvalid         = ~war_empty;

  generate
  if (USE_WAR==1) begin: war_en
    wire war_rd, war_wr;
  
      DWC_ddr_umctl2_retime
            
        #(
            .SIZE               (WARW),
            .OCCAP_EN           (OCCAP_EN),
            .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)            
         ) U_war
          (
           .clk         (e_clk),    
           .rst_n       (e_rst_n),    
           .d           (war_d),
           .wr          (war_wr),
           .rd          (war_rd),
           .par_en      (reg_ddrc_occap_en),
           .q           (war_q),
           .fe          (war_empty),
           .ff          (war_full),
           .par_err     (occap_xpi_war_err)
           );

    assign war_wr            = ~ep_empty ;
    assign war_rd            = e_awready;
    //spyglass disable_block W528
    //SMD: Variable set but not read
    //SJ: Used in different generate blocks
    assign war_push          = war_wr & ~war_full & war_in_vpw;
    assign war_pop           = war_rd & ~war_empty & war_out_vpw;
    //spyglass enable_block W528
    
  end // block: war_en
  else begin :war_nen
    assign war_empty          = ep_empty;
    assign war_full           = ~e_awready;
    assign war_q              = war_d;
    //spyglass disable_block W528
    //SMD: Variable set but not read
    //SJ: Used in different generate blocks
    assign war_push           = 1'b0;
    assign war_pop            = 1'b0;    
    //spyglass enable_block W528
    assign occap_xpi_war_err  = 1'b0;
  end // else: !if(USE_WAR==1)
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
    U_sar_wr
    (
      // outputs
      .addr_out                           (addr_waq),
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
    U_sar_wr_wrap_autopre
    (
      // outputs
      .addr_out                           (next_addr_wrap_autopre_waq),
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
   assign addr_waq = addr_sar;
   assign next_addr_wrap_autopre_waq = next_addr_wrap_autopre_sar;
end
endgenerate

  //---------------------------------------------------------------------------
  // Address parity check
  //---------------------------------------------------------------------------
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in different generate blocks
   assign parity_addr   = awaddr; // check the input address
   assign poison_wdata  = wdata;
   assign poison_valid  = wvalid & wready;
   assign parity_data   = poison_wdata; // check the input data

   always @(posedge aclk or negedge aresetn) begin
      if (~aresetn) begin
         parity_data_intr <= 1'b0;
      end
      else begin
         parity_data_intr <= |parity_data_error;
      end
   end
//spyglass enable_block W528   

   assign wpar_err         = parity_data_error;

generate
  if (OCPAR_EN == 1 || OCECC_EN == 1) begin: PAR_OR_ECC_en
    reg [AXI_ADDRW-1:0]  last_addr_parity_err;
    reg                  par_waddr_err_reg;
      
    wire                            enable_waddr_par_check; 
    wire [OCPAR_ADDR_PAR_WIDTH-1:0] addr_par_mask_in, parity_addr_error_vec;  
    wire [OCPAR_ADDR_PAR_WIDTH-1:0] awparity_in;
    wire [OCPAR_ADDR_PAR_WIDTH-1:0] wadd_parity_corr_unused;
    
    assign awparity_in            = awparity;
    assign enable_waddr_par_check = oc_addr_parity_en & awready & awvalid;
    assign addr_par_mask_in       = {OCPAR_ADDR_PAR_WIDTH{1'b1}};
    
    // address parity check
      DWC_ddr_umctl2_ocpar_calc
      
      #(
       .DW      (AXI_ADDRW),
       .CALC    (0), // parity check
       .PAR_DW  (OCPAR_ADDR_PAR_WIDTH),
       .SL_W    (OCPAR_ADDR_SLICE_WIDTH)
      )
      U_wadd_par_check
      (
       .data_in       (parity_addr),
       .parity_en     (enable_waddr_par_check),
       .parity_type   (reg_arb_oc_parity_type),
       .parity_in     (awparity_in), // parity in
       .mask_in       (addr_par_mask_in),
       .parity_out    (parity_addr_error_vec), // parity error
       .parity_corr   (wadd_parity_corr_unused) // not used
      );

    assign parity_addr_error = |parity_addr_error_vec;

    // parity interrupt
    always @(posedge aclk or negedge aresetn) begin: OCPAR_addr_intr
       if (~aresetn) begin
          par_waddr_err_reg    <= 1'b0;
          last_addr_parity_err <= {AXI_ADDRW{1'b0}};
       end
       else begin
          par_waddr_err_reg <= parity_addr_error;
          if (parity_addr_error) begin
             last_addr_parity_err <= parity_addr;
          end
       end
    end
      
    assign par_waddr_err_pulse    = par_waddr_err_reg;
    assign par_waddr_log          = last_addr_parity_err; 
      
  end // PAR_OR_ECC_en
endgenerate

generate
   if (OCPAR_EN == 1) begin: PAR_en

      wire [AXI_STRBW-1:0] wparity_in_corr;

      wire                 enable_wdata_poison;
      wire                 enable_wdata_par_check;

      wire [AXI_STRBW-1:0] data_par_mask_in;
      wire [AXI_STRBW-1:0] wparity_poisoned_w_unused;
      wire [AXI_STRBW-1:0] wparity_in, wparity_poison;

      assign wparity_in             = wparity;
      assign enable_wdata_poison    = wr_poison_en & wready;
      assign enable_wdata_par_check = oc_data_parity_en & wready & wvalid & ~par_wdata_axi_check_bypass_en; // bypass check when par_wdata_axi_check_bypass_en is 1
      assign data_par_mask_in       = wstrb;

      assign wparity_i              = par_wdata_axi_check_bypass_en ? wparity_poison : wparity_in_corr;

      // data parity check
      DWC_ddr_umctl2_ocpar_calc
      
      #(
       .DW      (AXI_DATAW),
       .CALC    (0), // parity check
       .PAR_DW  (AXI_STRBW),
       .SL_W    (OCPAR_SLICE_WIDTH)
      )
      U_wdata_par_check
      (
       .data_in       (parity_data),
       .parity_en     (enable_wdata_par_check),
       .parity_type   (reg_arb_oc_parity_type),
       .parity_in     (wparity_poison), // parity in
       .mask_in       (data_par_mask_in),
       .parity_out    (parity_data_error), // parity error
       .parity_corr   (wparity_in_corr)
      );

      // poison data parity
      ocpar_poison
      
      #(
         .DATA_WIDTH    (AXI_DATAW),
         .PAR_WIDTH     (AXI_STRBW),
         .DATA_PATH_POISON (0), // does not differ for INLINE_ECC case
         .DATA_PATH_POISON_SW (0), // does not differ for INLINE_ECC case
         .BYTE_POISON   (0), // set per byte poison 0 always
         .BYTE_POISON_SW(0), // set per byte poison 0 always
         .BYTE_WIDTH    (OCPAR_SLICE_WIDTH))
      U_poison_wdata
      (
         .clk           (aclk),
         .rst_n         (aresetn),
         .corrupt_twice (1'b0), // this is used only for IECC write path
         .data_valid    (poison_valid),
         .data_valid_w  (1'b0),
         .parity_in     (wparity_in),
         .parity_in_w   (wparity_in),
         .byte_num      (1'b0), // not used
         .dpp_support_en(1'b0), // not used
         .pbp_support_en(1'b0), // not used
         .poison_en     (enable_wdata_poison),
         .poison_ie_type(1'b0),
         .poison_ie_clr (par_wdata_err_intr_clr),
         .parity_out    (wparity_poison),
         .parity_out_w  (wparity_poisoned_w_unused));
      
      assign par_wdata_in_err_pulse = parity_data_intr;

      assign ocecc_corr_err                  = 1'b0;
      assign ocecc_uncorr_err                = 1'b0;

   end // PAR_en
   else if (OCECC_EN==1) begin: ECC_en

      //wire [ENIF_PARW-1:0] ecc_out;

      wire [AXI_DATAW-1:0]                       poison_wdata_corr_unused;
      wire [AXI_DATAW/OCECC_XPI_WR_IN_GRANU-1:0] ocecc_dec_err_byte_unused;

      wire ocecc_data_valid;
      assign ocecc_data_valid = poison_valid & ocecc_en;

      ocecc_dec
      
      #(
         .DW      (AXI_DATAW),
         .GRANU   (OCECC_XPI_WR_IN_GRANU),
         .EW      (AXI_STRBW)
      )
      echeck_xpi_wr_in
      (
         .data_in       (poison_wdata),
         .ecc_in        (wparity),
         .data_valid    (ocecc_data_valid),
         .fec_en        (1'b0), // not used
         .corr_err      (ocecc_corr_err),
         .uncorr_err    (ocecc_uncorr_err),
         .err_byte      (ocecc_dec_err_byte_unused), // not used
         .corr_data     (poison_wdata_corr_unused) // not used
      );

      ocecc_enc
       
      #(
         .DW      (AXI_DATAW),
         .GRANU   (OCECC_MR_RD_GRANU),
         .EW      (ENIF_PARW)
      )
      egen_mr_rd_0 
      (
         .clk           (aclk),
         .rstn          (aresetn),
         .data_in       (poison_wdata),
         .data_valid    (ocecc_data_valid),
         .poison_en     (ocecc_poison_en),
         .poison_single (ocecc_poison_single),
         .poison_bnum   (ocecc_poison_bnum),
         .ecc_out       (ecc_out)
      );

      assign parity_data_error      = {AXI_STRBW{ocecc_wdata_slverr_en & (ocecc_uncorr_err|ocecc_corr_err)}};
      assign par_wdata_in_err_pulse = 1'b0;
      //assign wparity_in_corr        = ecc_out; // route ECC bytes inside existing parity bus

   end
   else begin: ECC_PAR_nen

      assign parity_addr_error      = 1'b0;
      assign par_waddr_err_pulse    = 1'b0;
      assign par_waddr_log          = {AXI_ADDRW{1'b0}};
      assign parity_data_error      = {AXI_STRBW{1'b0}};
      assign par_wdata_in_err_pulse = 1'b0;
      assign wparity_i              = {AXI_STRBW{1'b0}};
      assign ocecc_corr_err         = 1'b0;
      assign ocecc_uncorr_err       = 1'b0;

   end
endgenerate


  //---------------------------------------------------------------------------
  // Wrap Split 
  //---------------------------------------------------------------------------

  DWC_ddr_umctl2_xpi_ws_wrapper
  
  
    #(
      .OCCAP_EN            (OCCAP_EN),
      .CMP_REG             (OCCAP_PIPELINE_EN), // registers on inputs in comparator for pipelining
      .WR                  (1),
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
     .ws_user                            (ws_user),
     .ws_qos                             (ws_qos[AXI_QOSW-1:0]), 
     .ws_poison                          (ws_poison),
     .ws_ocpar_err                       (ws_ocpar_err),
     .ws_token                           (ws_order_token[ORDER_TOKENW-1:0]),
     .ws_asize                           (ws_asize[AXI_SIZEW-1:0]),
     .ws_lock                            (ws_lock),
     .ws_autopre                         (ws_autopre),
     .ws_next_addr_wrap_autopre          (ws_next_addr_wrap_autopre),
     .ws_next_alen_wrap_autopre          (ws_next_alen_wrap_autopre),
     .split                              (ws_split),
     .skip                               (ws_skip),
     .short_burst                        (ws_short_burst),
     .hold_first_beat                    (hold_first_beat_unused),     
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
     .addr                               (awaddr[AXI_ADDRW-1:0]),
     .alen                               (awlen[AXI_LENW-1:0]),
     .asize                              (awsize[AXI_SIZEW-1:0]),
     .alock                              (awlock),
     .id                                 (awid[AXI_IDW-1:0]), 
     .user                               (awuser),
     .qos                                (awqos[AXI_QOSW-1:0]), 
     .poison                             (awpoison),
     .ocpar_err                          (parity_addr_error),
     .autopre                            (awautopre),
     .token                              (pre_arb_order_token[ORDER_TOKENW-1:0]),
     .awrap                              (awwrap),
     .wr                                 (ws_wr),
     .rd                                 (ws_rd),
     .ws_cmp_en                          (reg_ddrc_occap_en),
     .ws_cmp_poison                      (reg_arb_occap_arb_cmp_poison_seq),
     .ws_cmp_poison_full                 (reg_arb_occap_arb_cmp_poison_parallel),
     .ws_cmp_poison_err_inj              (reg_arb_occap_arb_cmp_poison_err_inj)
   );
  
  assign ws_wr  = awvalid;
 
  //---------------------------------------------------------------------------
  // ENIF Packetizer 
  //---------------------------------------------------------------------------
  DWC_ddr_umctl2_xpi_wp_wrapper
  
    #(
      .OCCAP_EN                 (OCCAP_EN),
      .CMP_REG                  (OCCAP_PIPELINE_EN), // registers on inputs in comparator for pipelining
      .UP_SIZE                  (UP_SIZE),
      .DOWN_SIZE                (DOWN_SIZE),     
      .M_DW                     (M_DW),
      .M_ADDRW                  (M_ADDRW),
      .NAB                      (NAB),
      .PDBW_CASE                (PDBW_CASE),
      .MEMC_BURST_LENGTH        (MEMC_BURST_LENGTH),
      .XPI_BRW                  (XPI_BRW),
      .NBEATS_LG2               (NBEATS_LG2),
      .AXI_ADDRW                (AXI_ADDRW),
      .AXI_MAXSIZE              (AXI_MAXSIZE),
      .ENIF_LENW                (ENIF_LENW), 
      .ENIF_SIZEW               (ENIF_SIZEW),
      .ENIF_LOCKW               (AXI_LOCKW),
      .ENIF_STRBW               (ENIF_STRBW),
      .ENIF_MAXSIZE             (ENIF_MAXSIZE),
      .ENIF_HSIZEW              (ENIF_HSIZEW),
      .ENIF_HLENW               (ENIF_HLENW),
      .ENIF_HMAXSIZE            (ENIF_HMAXSIZE),
      .MAXSIZE                  (MAXSIZE),
      .INFOW                    (INFOW),
      .DDRCTL_LUT_ADDRMAP_EN    (DDRCTL_LUT_ADDRMAP_EN),        
      .UMCTL2_HET_RANK_EN       (UMCTL2_HET_RANK_EN),
      .AMCSW                    (AMCSW),
      .AMCOLW                   (AMCOLW),
      .AMCOLW_C3                (AMCOLW_C3),
      .AXI_ADDR_BOUNDARY        (AXI_ADDR_BOUNDARY),   
      .DUAL_CHANNEL_INTERLEAVE  (DUAL_CHANNEL_INTERLEAVE),
      .DDRCTL_HET_INTERLEAVE    (DDRCTL_HET_INTERLEAVE),
      .DEACC_INFOW              (DEACC_INFOW),
      .EXA_ACC_SUPPORT          (EXA_ACC_SUPPORT),
      .EXA_PYLD_W               (EXA_PYLD_W),
      .EXA_MAX_LENW             (EXA_MAX_LENW),
      .EXA_MAX_SIZEW            (EXA_MAX_SIZEW),
      .EXA_MAX_ADDRW            (EXA_MAX_ADDRW),
      .AXI_LENW                 (AXI_LENW),
      .AXI_SIZEW                (AXI_SIZEW),
      .AXI_MAXSIZE_EXA          (AXI_MAXSIZE_EXA)
      )
  U_wp 
    (
     // Outputs
     .full                               (ep_full),
     .e_addr                             (ep_addr[M_ADDRW-1:0]),
     .e_alast                            (ep_alast),
     .empty                              (ep_empty),
     .e_autopre                          (ep_autopre),
     .deacc_info                         (deacc_info),
     .info                               (wp_info[INFOW-1:0]),  
     .exa_acc                            (ep_exa_acc),
     .exa_acc_instr                      (ep_exa_acc_instr_unused), // this is left unconnected
     .exa_acc_pyld                       (ep_exa_pyld),
     .exa_acc_lock                       (ep_exa_acc_lock),
     .wp_cmp_error                       (wp_cmp_error),
     .wp_cmp_error_full                  (wp_cmp_error_full),
     .wp_cmp_error_seq                   (wp_cmp_error_seq),
     .wp_cmp_poison_complete             (wp_cmp_poison_complete),
     // Inputs
     .clk                                (e_clk),
     .rst_n                              (e_rst_n),
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
     .addr                               (addr_ep[AXI_ADDRW-1:0]),
     .alen                               (alen_ep[ENIF_LENW-1:0]),
     .split                              (waq_split_cc),
     .short_burst                        (waq_short_burst),
     .asize                              (asize_ep[ENIF_SIZEW-1:0]),
     .alock                              (alock_ep),
     .autopre                            (autopre_ep),
     .next_addr_wrap_autopre             (next_addr_wrap_autopre_ep[AXI_ADDRW-1:0]),
     .next_alen_wrap_autopre             (next_alen_wrap_autopre_ep[ENIF_LENW-1:0]),
     .wr                                 (ep_wr),
     .rd                                 (ep_rd),
     .wp_cmp_en                          (reg_ddrc_occap_en),
     .wp_cmp_poison                      (reg_ddrc_occap_arb_cmp_poison_seq),
     .wp_cmp_poison_full                 (reg_ddrc_occap_arb_cmp_poison_parallel),
     .wp_cmp_poison_err_inj              (reg_ddrc_occap_arb_cmp_poison_err_inj),
     .exa_addr                           (waq_exa_addr),
     .exa_alen                           (waq_exa_alen),
     .exa_asize                          (waq_exa_asize)
   );
   assign pagematch_addrmap_mask_int = pagematch_addrmap_mask;
   assign ep_addr_int = ep_addr;
   assign het_pagematch_en_dca = 1'b1;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used only in dual channel configs
   assign het_pagematch_en_dcb = 1'b1;
//spyglass enable_block W528
   assign reg_ep_cs_prev_dca_err = 1'b0;
   assign reg_ep_cs_prev_dcb_err = 1'b0;
  
  assign ep_rd = ~war_full;
  assign alock_ep = waq_lock;
  assign autopre_ep = waq_autopre;
  
  //---------------------------------------------------------------------------
  // Dummy Generator
  //---------------------------------------------------------------------------
  assign e_wstrb     = dg_wstrb;
  assign e_wlast     = dg_wlast;   

  DWC_ddr_umctl2_xpi_dg
  
    #(
      .NAB           (NAB),
      .M_DW          (M_DW),
      .INFOW         (INFOW),
      .PDBW_CASE     (PDBW_CASE),
      .ENIF_DATAW    (ENIF_DATAW),
      .ENIF_STRBW    (ENIF_STRBW),
      .ENIF_PARW     (ENIF_PARW),
      .ENIF_LENW     (ENIF_LENW),
      .ENIF_SIZEW    (ENIF_SIZEW),
      .MAXSIZE       (MAXSIZE),
      .ENIF_MAXSIZE  (ENIF_MAXSIZE),
      .NBEATS_LG2    (NBEATS_LG2),
      .XPI_BRW       (XPI_BRW),
      .MEMC_BURST_LENGTH    (MEMC_BURST_LENGTH),
      .UMCTL2_PARTIAL_WR_EN (UMCTL2_PARTIAL_WR_EN),
      .DUAL_CHANNEL_INTERLEAVE           (DUAL_CHANNEL_INTERLEAVE),
      .OCCAP_EN          (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),
      .OCECC_EN      (OCECC_EN)
      )
  U_dg
    (
     // Outputs
     .empty                              (dg_empty),
     .full                               (dg_full),
     .wdata_out                          (dg_wdata),
     .wstrb_out                          (dg_wstrb),
     .wparity_out                        (dg_wparity),
     .wpar_err_out                       (dg_wpar_err),
     .last_pkt                           (e_wlast_pkt),    
     .wbeat_count                        (dg_beat_count),
     .occap_xpi_dg_par_err               (occap_xpi_dg_par_err),
     // Inputs
     .clk                                                (e_clk),
     .rst_n                                              (e_rst_n),
     .rst_dly                                            (e_rst_dly),
     .info                                               (iq_info[INFOW-1:0]),
     .wr                                                 (dg_wr),
     .rd                                                 (dg_rd),
     .wdata_in                                           (wdata_dg),
     .wstrb_in                                           (wstrb_dg),
     .wparity_in                                         (wparity_dg),
     .wparity_type                                       (reg_ddrc_oc_parity_type),
     .wpar_err_in                                        (wpar_err_dg),
     .reg_burst_rdwr                                     (reg_burst_rdwr),
     .reg_ddrc_data_bus_width                            (reg_ddrc_data_bus_width),
     .reg_ddrc_occap_en                                  (reg_ddrc_occap_en),
     .reg_xpi_short_write_dis                            (reg_xpi_short_write_dis),
     .reg_xpi_short_write_dis_bl8_nab1                   (reg_xpi_short_write_dis_bl8_nab1),
     .reg_xpi_short_write_dis_bl8_nab1_1or3beats         (reg_xpi_short_write_dis_bl8_nab1_1or3beats),
     .reg_xpi_short_write_dis_bl16_nab1                  (reg_xpi_short_write_dis_bl16_nab1),
     .reg_xpi_short_write_dis_bl16_nab2                  (reg_xpi_short_write_dis_bl16_nab2),
     .reg_xpi_short_write_dis_mbl16_bl8_nab2             (reg_xpi_short_write_dis_mbl16_bl8_nab2),
     .reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2 (reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2),
     .reg_xpi_short_write_dis_mbl16_bl4_nab2             (reg_xpi_short_write_dis_mbl16_bl4_nab2),
     .reg_xpi_short_write_dis_bl16_qbw_nab1              (reg_xpi_short_write_dis_bl16_qbw_nab1),
     .reg_xpi_short_write_dis_bl16_hbw                   (reg_xpi_short_write_dis_bl16_hbw),
     .reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1         (reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1),
     .reg_xpi_short_write_dis_bl16_fbw_nab1              (reg_xpi_short_write_dis_bl16_fbw_nab1),
     .reg_xpi_short_write_dis_mbl16_bl4_nab1             (reg_xpi_short_write_dis_mbl16_bl4_nab1),
     .reg_xpi_short_write_dis_mbl16_bl8_bc_fbw           (reg_xpi_short_write_dis_mbl16_bl8_bc_fbw),
     .reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1      (reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1),
     .short_write                                        (short_write)
    );
  
  generate    
  if (DOWN_SIZE==1)  begin: dg_down
    assign dg_wlast   = dd_wlast;
    assign dg_wr      = ~iq_empty & ~dd_empty;
  end
  else begin: dg_eq
    assign dg_wlast   = wdq_wlast;
    assign dg_wr      = ~iq_empty & ~wdq_empty;
  end
  endgenerate
    
  assign dg_rd      =  e_wready;
  assign e_wvalid   =  ~dg_empty;   
  
  //---------------------------------------------------------------------------
  // Info Queue
  //---------------------------------------------------------------------------
  wire [IQD_LG2:0]   iq_wcount_unused;
  
  DWC_ddr_umctl2_gfifo
  
  
   #(
     .WIDTH             (IQW),
     .DEPTH             (IQD),  
     .ADDR_WIDTH        (IQD_LG2),
     .COUNT_WIDTH       (IQD_LG2+1),
     .OCCAP_EN          (OCCAP_EN),
     .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)     
     ) 
  iq 
    (
     .clk             (e_clk),
     .rst_n           (e_rst_n),
     .wr              (iq_wr),  
     .d               (wp_info_dch),
     .rd              (iq_rd), 
     .par_en          (reg_ddrc_occap_en),
     .init_n          (1'b1),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in RTL assertion.
     .ff              (iq_full),
//spyglass enable_block W528
     .wcount          (iq_wcount_unused), 
     .q               (iq_info_dch),
     .fe              (iq_empty),
     .par_err         (occap_xpi_iq_err)
    `ifdef SNPS_ASSERT_ON
    `ifndef SYNTHESIS
    ,.disable_sva_fifo_checker_rd (1'b0)
    ,.disable_sva_fifo_checker_wr (1'b0)
    `endif // SYNTHESIS
    `endif // SNPS_ASSERT_ON
     );
  
  assign iq_wr = ~ep_empty & ~war_full;
  
  assign iq_rd = e_wvalid & e_wready & e_wlast_pkt;

  // DDR4 is only supported in 1:2 frequency ratio and BL4 is not supported by DDR4,
  // thus only two lengths of a HIF writes are possible (single beat and two beats).
  // For single beat HIF writes, DDRC will complete the BL8 with masked data, this case
  // requires a RMW when data mask is disabled in DDR4. wp_short_write is the flag to mark 
  // these writes. the xpi_rmw will generate a RMW for write marked with wp_short_write high.
//  assign wp_short_write = (MEMC_DDR4_EN==1) ? siu_bl8 : 1'b0;

  //---------------------------------------------------------------------------
  // Write Response Queue
  //---------------------------------------------------------------------------
  
  generate
    // --
    // Synchronous FIFO
    // --
    if (AXI_SYNC==1)  begin: sync_wrq
      DWC_ddr_umctl2_gfifo
      
      
        #(
          .WIDTH            (WRQW),
          .DEPTH            (AXI_WRQD),
          .ADDR_WIDTH       (AXI_WRQD_LG2),
          .COUNT_WIDTH      (AXI_WRQD_LG2+1),
          .OCCAP_EN         (OCCAP_EN),
          .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN)          
          ) 
      wrq 
        (
         .clk             (e_clk),
         .rst_n           (e_rst_n),
         .wr              (wrq_wr),
         .d               (wrq_d),
         .rd              (wrq_rd),
         .par_en          (reg_ddrc_occap_en),
         .init_n          (1'b1),
         .ff              (wrq_full),
         .wcount          (wrq_wcount_unused),    
         .q               (wrq_q),
         .fe              (wrq_empty),
         .par_err         (occap_xpi_wrq_err)
        `ifdef SNPS_ASSERT_ON
        `ifndef SYNTHESIS
        ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~wrq_empty
        ,.disable_sva_fifo_checker_wr (1'b0)
        `endif // SYNTHESIS
        `endif // SNPS_ASSERT_ON
         );

    end // block: sync_wrq
    // --
    // Asynchronous FIFO
    // --
    if (AXI_SYNC==0) begin: async_wrq
      wire                  wrq_push_fe_unused;
      wire [AXI_WRQD_LG2:0] wrq_pop_wcount_unused;
      
      DWC_ddr_umctl2_gafifo
      
      
        #(
          .WIDTH              (WRQW),
          .DEPTH              (AXI_WRQD),
          .ADDR_WIDTH         (AXI_WRQD_LG2),
          .COUNT_WIDTH        (AXI_WRQD_LG2+1),
          .PUSH_SYNC          (ASYNC_FIFO_N_SYNC),
          .POP_SYNC           (ASYNC_FIFO_N_SYNC),
          .EARLY_PUSH_STAT    (ASYNC_FIFO_EARLY_PUSH_STAT),    // push side is all registered
          .EARLY_POP_STAT     (ASYNC_FIFO_EARLY_POP_STAT),
          .OCCAP_EN           (OCCAP_EN),
          .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)          
          )
      wrq 
        (
         .wclk               (e_clk),
         .wrst_n             (e_rst_n),
         .wr                 (wrq_wr),
         .d                  (wrq_d),
         .rclk               (aclk),
         .rrst_n             (aresetn),
         .rd                 (wrq_rd),
         .par_en             (reg_ddrc_occap_en),
         .ff                 (wrq_full),
         .push_wcount        (wrq_wcount_unused),
         .pop_wcount         (wrq_pop_wcount_unused),      
         .q                  (wrq_q),
         .push_fe            (wrq_push_fe_unused),
         .pop_fe             (wrq_empty),
         .par_err            (occap_xpi_wrq_err)
        `ifdef SNPS_ASSERT_ON
        `ifndef SYNTHESIS
        ,.disable_sva_fifo_checker_rd (1'b1) // read data is valid only when ~wrq_empty
        ,.disable_sva_fifo_checker_wr (1'b0)
        `endif // SYNTHESIS
        `endif // SNPS_ASSERT_ON
         );

    end // block: async_wrq  
  endgenerate

  assign e_bready    = ~wrq_full;
  assign wrq_wr      = e_bvalid & ~wrq_full;
  assign wrq_d       = e_bresp;
  assign bvalid      = ~wrq_empty & owlast_cnt_nz;
  assign wrq_rd      = bready & owlast_cnt_nz;
  
  // Response FIFO Output
  assign {wrq_id, wrq_exa_resp, wrq_slverr, wrq_user} = wrq_q;
  
  // AXI B Channel Output
  assign bid               = wrq_id;

  assign buser             = wrq_user;

  // if poison is high or on-chip parity error or LPDDR3 wr_addr_err, write is invalid, return ERROR response
  assign bresp             = (wrq_slverr) ? SLVERR : wrq_exa_resp? EXOKAY : OKAY;

  //------------------------------------------------------------------------
  // Data channel decoding
  //------------------------------------------------------------------------
   generate
   if (DUAL_CHANNEL_INTERLEAVE==1) begin: Dual_DCH

      wire paqematch_dca, pagematch_dcb;

      reg [M_ADDRW-1:0] ep_addr_prev_dca, ep_addr_prev_dcb;
      wire [M_ADDRW-1:0] ep_addr_compare_dca, ep_addr_compare_dcb;
  
      assign wp_data_channel  = |(data_channel_addrmap_mask & ep_addr);
      assign wp_info_dch      = {deacc_info,wp_data_channel,wp_info};
      assign {iq_deacc_info,iq_data_channel,iq_info} = iq_info_dch;

  //------------------------------------------------------------------------
  // Page match calculation
  //------------------------------------------------------------------------

  always @(posedge e_clk, negedge e_rst_n)
    begin: ep_addr_prev_SEQ_PROC
      if (!e_rst_n) begin
        ep_addr_prev_dca <= {M_ADDRW{1'b0}};
        ep_addr_prev_dcb <= {M_ADDRW{1'b0}};
      end
      else begin
        if (ep_rd & wp_data_channel)
          ep_addr_prev_dcb <= ep_addr_int;
        if (ep_rd & ~wp_data_channel)
          ep_addr_prev_dca <= ep_addr_int;
      end
    end

    assign ep_addr_compare_dca = ~(ep_addr_int ^ ep_addr_prev_dca);
    assign ep_addr_compare_dcb = ~(ep_addr_int ^ ep_addr_prev_dcb);

    assign pagematch_dca = &(ep_addr_compare_dca | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dca;
    assign pagematch_dcb = &(ep_addr_compare_dcb | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dcb;

    assign ep_awpagematch = (pagematch_en) ? (wp_data_channel ? pagematch_dcb : pagematch_dca) :
                                             1'b0;

   end
   else if (DUAL_CHANNEL_INTERLEAVE_LP==1) begin: INTLV_us
      wire paqematch_dca, pagematch_dcb;

      reg [M_ADDRW-1:0] ep_addr_prev_dca, ep_addr_prev_dcb;
      wire [M_ADDRW-1:0] ep_addr_compare_dca, ep_addr_compare_dcb;
  
      assign wp_data_channel  = |(data_channel_addrmap_mask & ep_addr);
      assign wp_info_dch      = {wp_data_channel,wp_info};
      assign {iq_data_channel,iq_info} = iq_info_dch;
      assign iq_deacc_info    = deacc_info;

  //------------------------------------------------------------------------
  // Page match calculation
  //------------------------------------------------------------------------

  always @(posedge e_clk, negedge e_rst_n)
    begin: ep_addr_prev_SEQ_PROC
      if (!e_rst_n) begin
        ep_addr_prev_dca <= {M_ADDRW{1'b0}};
        ep_addr_prev_dcb <= {M_ADDRW{1'b0}};
      end
      else begin
        if (ep_rd & wp_data_channel)
          ep_addr_prev_dcb <= ep_addr_int;
        if (ep_rd & ~wp_data_channel)
          ep_addr_prev_dca <= ep_addr_int;
      end
    end

    assign ep_addr_compare_dca = ~(ep_addr_int ^ ep_addr_prev_dca);
    assign ep_addr_compare_dcb = ~(ep_addr_int ^ ep_addr_prev_dcb);

    assign pagematch_dca = &(ep_addr_compare_dca | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dca;
    assign pagematch_dcb = &(ep_addr_compare_dcb | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dcb;

    assign ep_awpagematch = (pagematch_en) ? (wp_data_channel ? pagematch_dcb : pagematch_dca) :
                                             1'b0;
   end
   else begin: Single_DCH

      wire pagematch;

      reg [M_ADDRW-1:0]                     ep_addr_prev;
      wire [M_ADDRW-1:0]                    ep_addr_compare;

      assign wp_data_channel  = 1'b0;
      assign iq_deacc_info    = deacc_info;
      assign iq_data_channel  = wp_data_channel;
      assign wp_info_dch      = wp_info;
      assign iq_info          = iq_info_dch;

  //------------------------------------------------------------------------
  // Page match calculation
  //------------------------------------------------------------------------
  // Store the previous address
  always @(posedge e_clk, negedge e_rst_n)
    begin: ep_addr_prev_SEQ_PROC
      if (!e_rst_n)
        ep_addr_prev <= {M_ADDRW{1'b0}};
      else
        if (ep_rd)
          ep_addr_prev <= ep_addr_int;
    end
  assign ep_addr_compare = ~(ep_addr_int ^ ep_addr_prev);

  assign pagematch = &(ep_addr_compare | ~pagematch_addrmap_mask_int[M_ADDRW-1:0]) & het_pagematch_en_dca;
  assign ep_awpagematch = (pagematch_en) ? pagematch : 1'b0;

   end
   endgenerate

  // overflow or underflow cannot occur by design
  always@(*) begin : owlast_cnt_nxt_PROC
    case({(wlast & wvalid & wready), (bready & bvalid)})
      2'b01 : owlast_cnt_nxt = owlast_cnt - 1'b1;   
      2'b10 : owlast_cnt_nxt = owlast_cnt + 1'b1;   
      default : owlast_cnt_nxt = owlast_cnt;  //hold
    endcase 
  end
 

    DWC_ddr_umctl2_par_reg
    
   #(
      .DW               (OUTS_WRW),
      .OCCAP            (OCCAP_EN),
      .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN)      
   )
   U_owlast_cnt
   (
      .clk        (aclk),
      .rst_n      (aresetn),
      .data_in    (owlast_cnt_nxt),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (owlast_cnt),
      .parity_err (occap_owlast_cnt_par_err)
   );

  assign owlast_cnt_nz = (|owlast_cnt); 
  
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  
  //Info Queue oveflow   
  property p_iq_overflow;
  @(posedge e_clk) disable iff(!e_rst_n) 
    (iq_wr) |-> (~iq_full);
  endproperty 
  a_iq_overflow : assert property (p_iq_overflow) else 
    $display("-> %0t ERROR:[xpi_write] IQ oveflow!", $realtime);
  
  generate
  if(DOWN_SIZE==1) begin : DWSIZE_ASSRT
     property p_ad_in_bypass;
     @(posedge e_clk)  disable iff(!e_rst_n) 
      (ad_in_bypass_unused && !waq_empty) |-> (alen_ep == waq_alen && asize_ep == waq_asize && addr_ep==waq_addr);
     endproperty   

     a_ad_in_bypass  : assert property (p_ad_in_bypass) else
     $display("-> %0t ERROR: [xpi_write] AD should be in bypass ", $realtime);
  end
  endgenerate 

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
    
endmodule // DWC_ddr_umctl2_xpi_write
