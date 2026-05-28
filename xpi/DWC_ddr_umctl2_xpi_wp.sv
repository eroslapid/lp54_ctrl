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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_wp.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            uMCTL XPI Write Packetizer module 
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_wp
import DWC_ddrctl_reg_pkg::*;
  #(
    parameter UP_SIZE      = 0,
    parameter DOWN_SIZE    = 0, 
    parameter M_DW         = 32,                  // SDRAM data width
    parameter M_ADDRW      = 32,                  // Memory address width (word aligned address)
    parameter NAB          = 2,
    parameter PDBW_CASE    = 0,
    parameter MEMC_BURST_LENGTH = 8,
    parameter XPI_BRW      = 3,
    parameter NBEATS_LG2   = 1,
    parameter AXI_ADDRW    = 32,                  // AXI address width
    parameter AXI_MAXSIZE  = 2,
    parameter ENIF_LENW    = 6,                   // AXI a*len width
    parameter ENIF_SIZEW   = 3,                   // AXI a*size width
    parameter ENIF_LOCKW   = 2,
    parameter ENIF_STRBW   = 2,   
    parameter ENIF_MAXSIZE = 1,
    parameter ENIF_HSIZEW  = 3,
    parameter ENIF_HLENW   = 2,
    parameter ENIF_HMAXSIZE = 1,
    parameter MAXSIZE      = 2,
    parameter INFOW        = 4,
    parameter DDRCTL_LUT_ADDRMAP_EN = 0,
    parameter UMCTL2_HET_RANK_EN = 0,
    parameter AMCSW        = 5,
    parameter AMCOLW       = 4,
    parameter AMCOLW_C3    = 5,
    parameter AXI_ADDR_BOUNDARY = 12,          // Defines AXI address no crossing boundary ( default is 4k)         
    parameter DUAL_CHANNEL_INTERLEAVE           = 0,
    parameter DEACC_INFOW  = 5,
    parameter DDRCTL_HET_INTERLEAVE = 0,
    // Exclusive Access 
    parameter EXA_ACC_SUPPORT   = 0,
    parameter EXA_PYLD_W        = 2, 
    parameter EXA_MAX_LENW      = 12, // Worst Case Dowsnsizing is 256/8 with a AXI_LENW of 6
    parameter EXA_MAX_SIZEW     = 3,  // Maximum AXI Size is 3 bits
    parameter EXA_MAX_ADDRW     = 12,  // 12 bits for 4K Boundary
    parameter AXI_LENW          = 6,
    parameter AXI_SIZEW         = 2,
    parameter AXI_MAXSIZE_EXA   = 1
    )
  
                            (
   input                       clk,           // clock
   input                       rst_n,         // asynchronous reset
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                       siu_bl16,
   input                       siu_bl8,
   input                       siu_bl4,
   input [`MEMC_NUM_RANKS-1:0] reg_ddrc_active_ranks,
   input                       reg_ddrc_alt_addrmap_en, 
   input [AMCSW-1:0]           reg_ddrc_addrmap_cs_bit0,
   input [AMCSW-1:0]           reg_ddrc_addrmap_cs_bit1,
   input [AMCOLW-1:0]          reg_ddrc_addrmap_col_b2_alt,
   input [AMCOLW_C3-1:0]       reg_ddrc_addrmap_col_b3_alt,
   input [AMCOLW-1:0]          reg_ddrc_addrmap_col_b2,
   input [AMCOLW_C3-1:0]       reg_ddrc_addrmap_col_b3,     
//spyglass enable_block W240
   input [XPI_BRW-1:0]         reg_burst_rdwr,
   input                       reg_ddrc_col_addr_shift,                       
   // bankgroup mask
   input [M_ADDRW-1:0]         bg_or_bank_addrmap_mask,
   input [1:0]                 reg_ddrc_data_bus_width,  
   
   // interface with WRAPP SPLIT 
   input [AXI_ADDRW-1:0]   addr,         // AXI first INCR burst address
   input [ENIF_LENW-1:0]   alen,         // AXI first INCR burst length
   input                   split,         // Single INCR burst 
   input                   short_burst,
   
   // For EXA payload creation
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [AXI_MAXSIZE_EXA-1:0]    exa_addr,
   input [AXI_LENW-1:0]       exa_alen,
   input [AXI_SIZEW-1:0]      exa_asize,
//spyglass enable_block W240
  
   // interface to AXI write/read  address channel   
   input [ENIF_SIZEW-1:0]  asize,         // AXI burst size
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [ENIF_LOCKW-1:0]  alock,         // AXI lock
//spyglass enable_block W240
   input                   autopre,       // AXI address auto precharge
   input  [AXI_ADDRW-1:0]  next_addr_wrap_autopre, // For AXI autopre wrap burst
   input  [ENIF_LENW-1:0]   next_alen_wrap_autopre, // For AXI autopre wrap burst
   input                   wr,            // AXI address valid
   output reg              full,          // AXI address ready

   output [M_ADDRW-1:0]    e_addr,
   output                  e_alast,       // ENIF address last
   output reg              e_autopre,     // ENIF address auto precharge
   output reg              empty,         // ENIF address valid
   input                   rd,            // ENIF address ready

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [1:0]            reg_arb_dch_density_ratio,
   input [5:0]            dch_bit,
   input [5:0]            e_addr_max_loc,
   input [5:0]            e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]    e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]    e_addr_max_m1_loc_addrmap_mask,
//spyglass enable_block W240

   output [DEACC_INFOW-1:0]deacc_info,
   output [INFOW-1:0]      info,          // Post write address queues data  
   output                  exa_acc,       // asserted, if exclusive read/write, with the first packet
   output                  exa_acc_lock,  // asserted, if exclusive write, for all packets of an AXI burst
   output                  exa_acc_instr, // asserted, if exclusive read/write, with all the packets
   output [EXA_PYLD_W-1:0] exa_acc_pyld
   );
  
  
  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  localparam M_NB             = M_DW/8;
  localparam M_NB_LG2         = (M_NB<=1)   ? 0 :       // 8bits
                                (M_NB<=2)   ? 1 :       // 16bits
                                (M_NB<=4)   ? 2 :       // 32bits
                                (M_NB<=8)   ? 3 :       // 64bits
                                (M_NB<=16)  ? 4 : 5;    // 128bits

  localparam A_NB_LG2         = NAB+M_NB_LG2;
  localparam A_NB_HBW_LG2     = NAB+M_NB_LG2-1;
  localparam A_NB_QBW_LG2     = NAB+M_NB_LG2-2;
  localparam M_NB_HBW_LG2     = (M_NB>1)  ? M_NB_LG2-1 : M_NB_LG2; // DRAM DW needs to be atleast x16
  localparam M_NB_QBW_LG2     = (M_NB>=2) ? M_NB_LG2-2 : M_NB_LG2; // DRAM DW needs to be atleast x32
  localparam FBW           = 2'b00;
  localparam HBW           = 2'b01;
  localparam QBW           = 2'b10;

  // Packet state machine encodings
  localparam PACKET_STATE_WIDTH  = 1;
  localparam IDLE                = 1'b0;  
  localparam PACKET              = 1'b1;  
  localparam AXI_ADDR_BOUNDARY_MIN = (AXI_ADDR_BOUNDARY<AXI_ADDRW) ? AXI_ADDR_BOUNDARY : AXI_ADDRW;
  localparam AXI_ADDR_BOUNDARY_MIN_P1 = AXI_ADDR_BOUNDARY_MIN+1;
  
  localparam LEN_BYTEW = ENIF_LENW+1+ENIF_MAXSIZE;
  localparam ONE_LEN_BYTEW = {{(LEN_BYTEW-1){1'b0}},1'b1};
  localparam ONE_ENIF_LENW = {{(ENIF_LENW-1){1'b0}},1'b1};

  localparam SIZEW_ALIGN      = (DUAL_CHANNEL_INTERLEAVE==1) ? ENIF_HSIZEW : ENIF_SIZEW;
  localparam ADDRW_ALIGN      = AXI_ADDRW;
  localparam AXI_ADDR_BOUND_ALIGN  = (AXI_ADDR_BOUNDARY_MIN<ADDRW_ALIGN) ? AXI_ADDR_BOUNDARY_MIN : ADDRW_ALIGN;
  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [PACKET_STATE_WIDTH-1:0]         packet_state_next;
  reg [PACKET_STATE_WIDTH-1:0]         packet_state_reg;                            
  wire [M_ADDRW-1:0]                   e_addr_l;
  wire [M_ADDRW-1:0]                   e_addr_l_wrap_autopre;
  wire [M_ADDRW:0]                     e_addr_wrap_autopre;
  wire [M_ADDRW-1:0]                   hif_addr_last_l;
  wire [M_ADDRW-1:0]                   hif_addr_last_l_wrap_autopre;
  wire [3:0]                           e_addr_col; 
  wire [LEN_BYTEW-1:0]                 len_byte;
  wire [LEN_BYTEW-1:0]                 len_byte_wrap_autopre;
  reg [AXI_ADDR_BOUNDARY_MIN-1:0]      addr_b4k;
  reg [AXI_ADDR_BOUNDARY_MIN-1:0]      addr_b4k_wrap_autopre;
  wire [AXI_ADDR_BOUNDARY_MIN-1:0]     addr_align_bl;  
  wire [AXI_ADDR_BOUNDARY_MIN-1:0]     addr_align_bl_wrap_autopre;
  wire [AXI_ADDR_BOUNDARY_MIN_P1-1:0]  addr_end;
  wire [AXI_ADDR_BOUNDARY_MIN_P1-1:0]  addr_end_wrap_autopre;
  wire [AXI_ADDR_BOUNDARY_MIN_P1-1:0]  bl_addr_next;   
  reg [AXI_ADDR_BOUNDARY_MIN_P1-1:0]   bl_addr_reg;
  wire [AXI_ADDR_BOUNDARY_MIN_P1-1:0]  bl_addr_update;
  wire [AXI_ADDR_BOUNDARY_MIN_P1:0]    bl_addr_update_wider;
  wire [AXI_ADDR_BOUNDARY_MIN_P1-1:0]  bl_addr_cur;  
  
  reg                                  first_bl;
  wire                                 last_bl;
  reg [2:0]                            bl_mask_align;
  reg [2:0]                            bl_mask_align_reg;
  wire [MAXSIZE-1:0]                   addr_offset;

  wire [NBEATS_LG2-1:0]                beat_num_end_i;
  wire [NBEATS_LG2-1:0]                beat_num_end,beat_num_end_tmp;
  wire [NBEATS_LG2:0]                  beat_num_end_tmp_wider; 
  reg [2:0]                            reg_burst_rdwr_m1;
  wire [ENIF_LENW:0]                   len_p1;
  wire [LEN_BYTEW-1:0]                 len_p1_byte;

  wire [ADDRW_ALIGN-1:0]               addr_to_align;
  wire [ADDRW_ALIGN-1:0]               addr_to_align_wrap;
  wire [SIZEW_ALIGN-1:0]               asize_to_align;
  wire [DEACC_INFOW-1:0]               acc_addr_offset;

  wire [1:0]                           am_column_shift;
  wire [M_ADDRW-1:0]                   hif_addr_last;
  wire [M_ADDRW:0]                     hif_addr_last_wrap_autopre;
  wire [M_ADDRW-1:0]                   incr_hif_addr_bit;
  wire [M_ADDRW:0]                     mask_hif_addr_bit;
  wire [M_ADDRW:0]                     exp_next_same_bg_ba_addr;
  wire [M_ADDRW:0]                     exp_next_same_bg_ba_addr_wrap;
  wire [M_ADDRW:0]                     exp_next_same_bg_ba_addr_tmp;
  wire [M_ADDRW:0]                     bg_or_bank_addrmap_mask_ex;
  wire [M_ADDRW:0]                     e_addr_ex; 
  wire [M_ADDRW:0]                     e_addr_ex_wrap_autopre;
  wire                                 fbw_mode,hbw_mode,qbw_mode;
  wire                                 up_size_act,dw_size_act;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
  assign hbw_mode = (reg_ddrc_data_bus_width==HBW) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW) ? 1'b1: 1'b0;
//spyglass enable_block W528  

 //Upsizers are active
  assign up_size_act = PDBW_CASE==0 ? (UP_SIZE==1) :
                       PDBW_CASE==2 ? fbw_mode     :
                       PDBW_CASE==3 ? (fbw_mode|hbw_mode) :
                       PDBW_CASE==4 ? 1'b1 
                                    : 1'b0; //case 5

//downsizers are active
  assign dw_size_act = PDBW_CASE==0 ? (DOWN_SIZE==1) :
                       PDBW_CASE==1 ? (hbw_mode|qbw_mode) :
                       PDBW_CASE==3 ? qbw_mode :
                       PDBW_CASE==5 ? 1'b1 
                                    : 1'b0; //case 4

  assign deacc_info = {acc_addr_offset};
  
  //spyglass disable_block W415a
  //SMD: Signal addr_b4k is being assigned multiple times in same always block. 
  //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
  always @(*) begin: align_addr_to_size_COMB_PROC
    integer i;
    addr_b4k = {AXI_ADDR_BOUNDARY_MIN{1'b0}};
    addr_b4k_wrap_autopre = {AXI_ADDR_BOUNDARY_MIN{1'b0}};
    for (i=0; i<AXI_ADDR_BOUND_ALIGN;i=i+1) begin
      if (i<asize_to_align) begin
        addr_b4k[i]= 1'b0;
        addr_b4k_wrap_autopre[i]= 1'b0;
      end 
      else begin
        addr_b4k[i]= addr_to_align[i];
        addr_b4k_wrap_autopre[i]= addr_to_align_wrap[i];
      end
    end
  end // block: COMB_align_addr_to_size
  //spyglass enable_block W415a

  assign len_p1 = {1'b0,alen}+{1'b0,ONE_ENIF_LENW};
  
  //spyglass disable_block W164b
  //SMD: LHS: 'len_p1_byte' width 14 is greater than RHS: '(len_p1 << asize)' width 9 in assignment
  //SJ: Final width of RHS depends on value of len_p1. Previously waived in Leda with LJ: len_p1 shorter than len_p1_byte
  assign len_p1_byte = len_p1 << asize;
  //spyglass enable_block W164b
  
  assign len_byte = len_p1_byte-ONE_LEN_BYTEW;
  assign len_byte_wrap_autopre = ((next_alen_wrap_autopre+1) << asize)-1;
  
  //spyglass disable_block W484
  //SMD: Possible assignment overflow: lhs width 13 (Expr: 'addr_end') should be greater than rhs width 13 (Expr: '(addr_b4k + len_byte)') to accommodate carry/borrow bit
  //SJ: Width depends on configuration. Can be safely waived based on SJs below.
  //spyglass disable_block W164b
  //SMD: LHS: 'addr_end' width 28 is greater than RHS: '(addr_b4k + len_byte)' width 27 in assignment
  //SJ: Assuming that we want to keep the carry. Previously waived in Leda with LJ: len_byte is the increment and is shorter than addr_b4k; LJ: addr_end is one bit wider than addr_b4k
  //spyglass disable_block W164a
  //SMD: LHS: 'addr_end' width 13 is less than RHS: '(addr_b4k + len_byte)' width 14 in assignment
  //SJ: Previosly waived in Leda with LJ: len_byte is the increment and is shorter than addr_b4k; LJ: addr_end is one bit wider than addr_b4k
  //spyglass disable_block TA_09
  //SMD: Net 'DWC_ddrctl.U_xpi_2.U_xpi_write.U_wp.\WP_inst[0].U_wp .len_byte[13]' [in 'DWC_ddr_umctl2_xpi_wp'] is not observable[affected by other input(s)].
  //SJ: Same reasoning as for W164a/W164b rules
  assign addr_end = addr_b4k + len_byte;
  assign addr_end_wrap_autopre = addr_b4k_wrap_autopre + len_byte_wrap_autopre;
  //spyglass enable_block TA_09
  //spyglass enable_block W164a
  //spyglass enable_block W164b
  //spyglass enable_block W484

  //assign bl_addr_update_wider = bl_addr_cur + (reg_burst_rdwr <<(M_NB_LG2+1));
  assign bl_addr_update_wider = bl_addr_cur + ((reg_burst_rdwr <<(M_NB_LG2+1)) >> reg_ddrc_data_bus_width);
  assign bl_addr_update = bl_addr_update_wider[AXI_ADDR_BOUNDARY_MIN_P1-1:0];
  
  assign addr_align_bl = (hbw_mode & (PDBW_CASE!=0)) ? {addr_b4k[AXI_ADDR_BOUNDARY_MIN-1:M_NB_HBW_LG2+4],addr_b4k[M_NB_HBW_LG2+3:M_NB_HBW_LG2+1] & bl_mask_align_reg,{(M_NB_HBW_LG2+1){1'b0}}} :
                         (qbw_mode & (PDBW_CASE!=0)) ? {addr_b4k[AXI_ADDR_BOUNDARY_MIN-1:M_NB_QBW_LG2+4],addr_b4k[M_NB_QBW_LG2+3:M_NB_QBW_LG2+1] & bl_mask_align_reg,{(M_NB_QBW_LG2+1){1'b0}}} : 
                                                          {addr_b4k[AXI_ADDR_BOUNDARY_MIN-1:M_NB_LG2+4],addr_b4k[M_NB_LG2+3:M_NB_LG2+1] & bl_mask_align_reg,{(M_NB_LG2+1){1'b0}}}; //FBW

  
  assign addr_align_bl_wrap_autopre = (hbw_mode & (PDBW_CASE!=0)) ? {addr_b4k_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:M_NB_HBW_LG2+4],addr_b4k_wrap_autopre[M_NB_HBW_LG2+3:M_NB_HBW_LG2+1] & bl_mask_align_reg,{(M_NB_HBW_LG2+1){1'b0}}} :
                                      (qbw_mode & (PDBW_CASE!=0)) ? {addr_b4k_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:M_NB_QBW_LG2+4],addr_b4k_wrap_autopre[M_NB_QBW_LG2+3:M_NB_QBW_LG2+1] & bl_mask_align_reg,{(M_NB_QBW_LG2+1){1'b0}}} : 
                                                                       {addr_b4k_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:M_NB_LG2+4],addr_b4k_wrap_autopre[M_NB_LG2+3:M_NB_LG2+1] & bl_mask_align_reg,{(M_NB_LG2+1){1'b0}}}; //FBW
  
  assign bl_addr_cur = first_bl ? {{1'b0},addr_align_bl} : bl_addr_reg;
  assign bl_addr_next = (~empty & rd) ? bl_addr_update : bl_addr_reg;
  assign last_bl = (bl_addr_update> addr_end || short_burst) ? 1'b1:1'b0;
  assign info = {e_addr_col[3:0],split,addr_offset,alen,asize,beat_num_end};
  assign addr_offset = (up_size_act==1'b1 && ~first_bl) ? {MAXSIZE {1'b0}}:addr[MAXSIZE-1:0];  
  assign e_alast = (dw_size_act==1'b1 || DUAL_CHANNEL_INTERLEAVE==1) ? last_bl:last_bl & ~split;
  
  always @(*) begin: bl_mask_align_COMB_PROC
   case (reg_burst_rdwr)
      4'd4: bl_mask_align = 3'b100;
      4'd8: bl_mask_align = 3'b000;
      default: begin
         bl_mask_align = 3'b100; // BL8
      end
   endcase
  end

  wire [AXI_ADDR_BOUNDARY_MIN-1:0]  addr_b4k_tmp;
  assign addr_b4k_tmp = first_bl ? addr_b4k[AXI_ADDR_BOUNDARY_MIN-1:0]: 
                                   bl_addr_cur[AXI_ADDR_BOUNDARY_MIN-1:0];
  

  
  // 
  // Logic to choose between different ADDRMAP 
  // (ADDRMAP or ADDRMAP_ALT(MRAM) ) if enabled
  // 
                                     
  wire [AMCOLW-1:0] i_reg_ddrc_addrmap_col_b2_sel;
  wire [AMCOLW_C3-1:0] i_reg_ddrc_addrmap_col_b3_sel;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
  assign am_column_shift = {reg_ddrc_col_addr_shift,1'b0};
//spyglass enable_block W528

  generate
    if ((UMCTL2_HET_RANK_EN==1) && (DDRCTL_LUT_ADDRMAP_EN==0))  begin: addrmap_alt_1  
      // ADDRMAP_ALT logic is enabled
      // select depending on reg_ddrc_alt_addrmap_en and mapped rank

      wire              am_map_sel;
      
      //spyglass disable_block SelfDeterminedExpr-ML
      //SMD: Self determined expression '(6 + reg_ddrc_addrmap_cs_bit0)' found in module 'DWC_ddr_umctl2_xpi_wp'
      //SJ: This coding style is acceptable and there is no plan to change it.
      wire e_addr_cs_bit0 = (reg_ddrc_addrmap_cs_bit0=={AMCSW{1'b1}}) ? 1'b0 : e_addr[6+reg_ddrc_addrmap_cs_bit0];
      wire e_addr_cs_bit1 = (reg_ddrc_addrmap_cs_bit1=={AMCSW{1'b1}}) ? 1'b0 : e_addr[7+reg_ddrc_addrmap_cs_bit1];
      //spyglass enable_block SelfDeterminedExpr-ML

      // MRAM ranks are to the upper half of valid rank addresses
      //----------------------------------------------------------------------------------------
      // Activated Rank | am_map_sel      | Comment                                             
      //----------------+-----------------------------------------------------------------------
      //      1         | 0               | Always use map0                                     
      //      2         | map0_am_rank[0] | am_cs_offset_bit0 indicates Rank0 vs Rank1 selection   
      //      4         | map0_am_rank[1] | am_cs_offset_bit1 indicates Rank0/1 vs Rank2/3 selection 
      //----------------------------------------------------------------------------------------
 
      assign am_map_sel = (reg_ddrc_active_ranks==4'b0001) ? 1'b0 :
                          (reg_ddrc_active_ranks==4'b0011) ? e_addr_cs_bit0 :
                                                             e_addr_cs_bit1 ;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      // Mux to select between 2 ADDRMAPs: ADDRMAP or ADDRMAP_ALT  
      // Only selected ADDRMAP_ALT if enabmeld via SW (reg_ddrc_alt_addrmap_en=1)
      // and if mapped rank select is to MRAM ranks
      assign i_reg_ddrc_addrmap_col_b2_sel = (~reg_ddrc_alt_addrmap_en | ~am_map_sel) ? reg_ddrc_addrmap_col_b2 :
                                                                                        reg_ddrc_addrmap_col_b2_alt;
      assign i_reg_ddrc_addrmap_col_b3_sel = (~reg_ddrc_alt_addrmap_en | ~am_map_sel) ? reg_ddrc_addrmap_col_b3 :
                                                                                        reg_ddrc_addrmap_col_b3_alt;
//spyglass enable_block W528    
    end // generate  (UMCTL2_HET_RANK_EN==1)

    if ((UMCTL2_HET_RANK_EN==0) || ((UMCTL2_HET_RANK_EN==1) && (DDRCTL_LUT_ADDRMAP_EN==1)))  begin: addrmap_alt_0
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block
      // ADDRMAP_ALT logic is disabled
      assign i_reg_ddrc_addrmap_col_b2_sel = reg_ddrc_addrmap_col_b2;
      assign i_reg_ddrc_addrmap_col_b3_sel = reg_ddrc_addrmap_col_b3;
//spyglass enable_block W528      
    end // generate  (UMCTL2_HET_RANK_EN==0)

  endgenerate

  wire [AXI_ADDR_BOUNDARY_MIN-1:0]  addr_b4k_tmp_wrap_autopre;
  wire [AXI_ADDR_BOUNDARY_MIN-1:0]  hif_addr_last_tmp_wrap_autopre;
  assign addr_b4k_tmp_wrap_autopre = addr_align_bl_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:0];
  assign hif_addr_last_tmp_wrap_autopre = addr_end_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:0];
  //spyglass disable_block W164a
  //SMD: LHS: 'e_addr_l' width 34 is less than RHS: '{addr_a4k ,addr_b4k_tmp[(AXI_ADDR_BOUNDARY - 1):A_NB_LG2] }' width 36 in assignment
  //SJ: No suitable recoding found. Previosly waived in Leda with LJ: AXI_ADDRW and M_ADDRW are different, addr_b4k_tmp can be truncated when assigned to e_addr_l
  generate
    if (AXI_ADDR_BOUNDARY<AXI_ADDRW) begin:axi_addr_boundary
      wire [AXI_ADDRW-AXI_ADDR_BOUNDARY-1:0] addr_a4k;   
      wire [AXI_ADDRW-AXI_ADDR_BOUNDARY-1:0] addr_a4k_wrap_autopre;
      assign addr_a4k = addr[AXI_ADDRW-1:AXI_ADDR_BOUNDARY];
      assign addr_a4k_wrap_autopre = next_addr_wrap_autopre[AXI_ADDRW-1:AXI_ADDR_BOUNDARY];

      if (PDBW_CASE==0) begin : no_pgdbw
        assign e_addr_l = {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
        assign e_addr_l_wrap_autopre = {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
        assign hif_addr_last_l = {addr_a4k,addr_end[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
        assign hif_addr_last_l_wrap_autopre = {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
      end else begin : pgdbw  
  
        assign e_addr_l = (hbw_mode) ? {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                          (qbw_mode) ? {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                         : {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
  
        assign e_addr_l_wrap_autopre = (hbw_mode) ? {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                                       (qbw_mode) ? {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                                      : {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]} ;      
  
        assign hif_addr_last_l = (hbw_mode) ?  {addr_a4k,addr_end[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                                 (qbw_mode) ?  {addr_a4k,addr_end[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                                :  {addr_a4k,addr_end[AXI_ADDR_BOUNDARY-1:A_NB_LG2]} ;
  
        assign hif_addr_last_l_wrap_autopre = (hbw_mode) ?  {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                                              (qbw_mode) ?  {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                                             : {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]}; 
      end //pgdbw
    end //axi_addr_boundary
    if (AXI_ADDR_BOUNDARY>=AXI_ADDRW) begin:axi_addr_boundary_max
      assign e_addr_l = addr_b4k_tmp[AXI_ADDRW-1:A_NB_LG2];
      assign e_addr_l_wrap_autopre = {addr_b4k_tmp_wrap_autopre[AXI_ADDRW-1:A_NB_LG2]};
      assign hif_addr_last_l = addr_end[AXI_ADDRW-1:A_NB_LG2];
      assign hif_addr_last_l_wrap_autopre = hif_addr_last_tmp_wrap_autopre[AXI_ADDRW-1:A_NB_LG2];
    end //axi_addr_boundary_max
  endgenerate
  //spyglass enable_block W164a


generate 
  if (DDRCTL_HET_INTERLEAVE == 1) begin: e_addr_int_gen
    wire [M_ADDRW-1:0] e_addr_int;
    wire [M_ADDRW-1:0] e_addr_final;

    assign e_addr_int        = {e_addr_l[M_ADDRW-NAB-1:0],{NAB{1'b0}}};
    assign e_addr            = e_addr_final;

   //instance
    DWC_ddr_umctl2_xpi_xltr
     
    #(
      .M_ADDRW    (M_ADDRW))
    U_xpi_wr_xltr
    (.e_addr_in                       (e_addr_int),
     .e_addr_max_loc_addrmap_mask     (e_addr_max_loc_addrmap_mask),
     .e_addr_max_m1_loc_addrmap_mask  (e_addr_max_m1_loc_addrmap_mask),
     .reg_arb_dch_density_ratio       (reg_arb_dch_density_ratio),
     .e_addr_max_loc                  (e_addr_max_loc),
     .e_addr_max_m1_loc               (e_addr_max_m1_loc),
     .dch_bit                         (dch_bit),
     .e_addr_out                      (e_addr_final) 
    );
  end else begin: e_addr_gen
    assign e_addr    = {e_addr_l[M_ADDRW-NAB-1:0],{NAB{1'b0}}};
  end
endgenerate

  assign e_addr_wrap_autopre = {1'b0,e_addr_l_wrap_autopre[M_ADDRW-NAB-1:0],{NAB{1'b0}}};

  assign hif_addr_last = {hif_addr_last_l[M_ADDRW-NAB-1:0],{NAB{1'b0}}};
  assign hif_addr_last_wrap_autopre = {1'b0,hif_addr_last_l_wrap_autopre[M_ADDRW-NAB-1:0],{NAB{1'b0}}}; // Expected the last hif command address after over the wrap burst boundary
  assign incr_hif_addr_bit = (reg_burst_rdwr << 1);
  assign mask_hif_addr_bit = incr_hif_addr_bit - 1'b1;

  wire [M_ADDRW-1:0] bg_or_bank_addrmap_mask_int;

    assign bg_or_bank_addrmap_mask_int = bg_or_bank_addrmap_mask;
 
  //spyglass disable_block TA_09
  //SMD:Net 'DWC_ddrctl.bg_or_bank_addrmap_mask[0]' [in 'DWC_ddrctl'] is not observable[affected by other input(s)]. Adding a test-point [Obs = y]  will make 4 nets observable[Fault Improvement = '8'[%Increase 0.0]]
  //SJ:Functionally correct. if MEMC_DDR4 is not defined, bg_or_bank_addrmap_mask always keeps 0.
  // exp_next_same_bg_ba_addr signal indecats the next command of same bg or bank with current command.
  assign exp_next_same_bg_ba_addr_tmp = ({1'b0,(e_addr | bg_or_bank_addrmap_mask_int)} + incr_hif_addr_bit);

  assign bg_or_bank_addrmap_mask_ex = {1'b0,bg_or_bank_addrmap_mask_int};
  assign e_addr_ex = {1'b0,e_addr};
  genvar gv;
  generate 
    for(gv = 0; gv < M_ADDRW+1; gv = gv + 1) begin : same_bg_ba_addr
      assign exp_next_same_bg_ba_addr[gv] = (mask_hif_addr_bit[gv] == 1'b1)          ? 1'b0 : //This logic can avoid the unexpected autopre due to BC4
                                            (bg_or_bank_addrmap_mask_ex[gv] == 1'b1) ? e_addr_ex[gv] : exp_next_same_bg_ba_addr_tmp[gv];
      assign exp_next_same_bg_ba_addr_wrap[gv] = (mask_hif_addr_bit[gv] == 1'b1)          ? 1'b0 : //This logic can avoid the unexpected autopre due to BC4
                                                 (bg_or_bank_addrmap_mask_ex[gv] == 1'b1) ?  e_addr_ex[gv] : e_addr_wrap_autopre[gv];
    end
  endgenerate

//spyglass enable_block TA_09

  always@(*)begin
    if(autopre) begin
      if(split) begin // Wrap bourst mode
        if(exp_next_same_bg_ba_addr_wrap > hif_addr_last_wrap_autopre) begin
          if(exp_next_same_bg_ba_addr > {1'b0,hif_addr_last})begin // The same bg command is not issued after over the Wrap boundary
             e_autopre = 1'b1;
          end
          else begin // The same bg command is issued before over the same Wrap boundary
             e_autopre = 1'b0;
          end
        end 
        else begin // The same bg command is issued after over the Wrap boundary 
           e_autopre = 1'b0;
        end
      end 
      else if(last_bl) begin //The last command always should be asserted.
        e_autopre = 1'b1;
      end
      else if(exp_next_same_bg_ba_addr > {1'b0,hif_addr_last})begin 
      // If the next same bg or bank address command with current command is over the end address, current command should be last hif command.
      // Therefore, autopre is asserted.
          e_autopre = 1'b1;
      end
      else begin
          e_autopre = 1'b0;
      end
    end
    else begin // autopre == 1'b0
      e_autopre = 1'b0;
    end
  end

  assign e_addr_col[1:0] =  e_addr[1:0];
  
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((2 + i_reg_ddrc_addrmap_col_b2_sel) - am_column_shift)' found in module 'DWC_ddr_umctl2_xpi_wp'
//SJ: This coding style is acceptable and there is no plan to change it.
  generate
    if (MEMC_BURST_LENGTH>=8) begin: bl8_bl16_e_addr_col_b2_gen
      assign e_addr_col[2] = e_addr[2+i_reg_ddrc_addrmap_col_b2_sel-am_column_shift];
    end else begin: nbl8_bl16_e_addr_col_b2_gen
      assign e_addr_col[2] = 1'b0; 
    end
  endgenerate
//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index '((3 + i_reg_ddrc_addrmap_col_b3_sel) - am_column_shift)' of width '6' is larger than the width '5' required for the max value '30' of the signal 'e_addr'
//SJ: Index width can be exceeded only when using incorrect address map values for reg_ddrc_addrmap_col_b3 register field.
  generate
    if (MEMC_BURST_LENGTH==16) begin: bl16_e_addr_col_b3_gen
      assign e_addr_col[3] = e_addr[3+i_reg_ddrc_addrmap_col_b3_sel-am_column_shift];
    end else begin: nbl16_e_addr_col_b3_gen
      assign e_addr_col[3] = 1'b0; 
    end
  endgenerate
//spyglass enable_block ImproperRangeIndex-ML
//spyglass enable_block SelfDeterminedExpr-ML

//spyglass disable_block W528
//SMD: A signal or variable is set but never read - beat_num_end_tmp
//SJ: Unused in some of the branches of the generate block
  generate
   if (NAB==1) begin: x2_addr_gen
      if (MEMC_BURST_LENGTH==16) begin: bl16_addr_gen
         assign beat_num_end_i   = (siu_bl16==1'b1) ? addr_b4k[A_NB_LG2+2:A_NB_LG2] :
                                   (siu_bl8==1'b1) ?  {1'b0,addr_b4k[A_NB_LG2+1:A_NB_LG2]} :
                                                      {2'b00,addr_b4k[A_NB_LG2]};
         
         assign beat_num_end_tmp_wider = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[2:0]-beat_num_end_i[2:0] : 
                                                                     reg_burst_rdwr_m1[2:0] ;
         assign beat_num_end_tmp       = beat_num_end_tmp_wider[NBEATS_LG2-1:0];
                                                               
         if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch_NAB1_BL16
            assign beat_num_end  = {1'b0,beat_num_end_tmp[2:1]};
         end
         else begin: SINGLE_ch_x2_bl16
            assign beat_num_end  = beat_num_end_tmp;
         end
         
      end
      else if (MEMC_BURST_LENGTH==8) begin: bl8_addr_gen
         assign beat_num_end_i   =  (siu_bl8==1'b1) ? addr_b4k[A_NB_LG2+1:A_NB_LG2] : 
                                                      {1'b0,addr_b4k[A_NB_LG2]};

         assign beat_num_end_tmp_wider = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[1:0]-beat_num_end_i[1:0] : 
                                                                     reg_burst_rdwr_m1[1:0] ;
         assign beat_num_end_tmp       = beat_num_end_tmp_wider[NBEATS_LG2-1:0];
         
         if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch_NAB1_BL8
            assign beat_num_end  = {1'b0,beat_num_end_tmp[1]};
         end
         else begin: SINGLE_ch_x2_bl8
            assign beat_num_end  = beat_num_end_tmp;
         end
         
      end
      else if (MEMC_BURST_LENGTH==4) begin: bl4_addr_gen
         assign beat_num_end_i   =  (siu_bl4==1'b1) ? addr_b4k[A_NB_LG2]: 1'b0;      
      
         assign beat_num_end_tmp_wider = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[0]-beat_num_end_i[0] : 
                                                                     reg_burst_rdwr_m1[0] ;
         assign beat_num_end_tmp       = beat_num_end_tmp_wider[NBEATS_LG2-1:0];
         
         if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch_NAB1_BL4
            assign beat_num_end  = 1'b0;
         end
         else begin: SINGLE_ch_x2_bl4
            assign beat_num_end  = beat_num_end_tmp;
         end
         
      end
   end
   else if (NAB==2) begin: x4_addr_gen
      if (MEMC_BURST_LENGTH==16) begin: bl16_addr_gen
         assign beat_num_end_i   = (siu_bl16==1'b1) ? addr_b4k[A_NB_LG2+1:A_NB_LG2]: 
                                   (siu_bl8==1'b1) ? {1'b0,addr_b4k[A_NB_LG2]} : 2'b0;

         assign beat_num_end_tmp_wider = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[2:1]-beat_num_end_i[1:0] : 
                                                                     reg_burst_rdwr_m1[2:1] ;
         assign beat_num_end_tmp       = beat_num_end_tmp_wider[NBEATS_LG2-1:0];
         
         if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch_NAB2_BL16
            assign beat_num_end  = {1'b0,beat_num_end_tmp[1]};
         end
         else begin: SINGLE_ch_x4_bl16
            assign beat_num_end  = beat_num_end_tmp;
         end
         
      end
      else if (MEMC_BURST_LENGTH==8) begin: bl8_addr_gen

         assign beat_num_end_i   = (siu_bl8==1'b1) ? addr_b4k[A_NB_LG2]:1'b0;

         assign beat_num_end_tmp_wider = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[1]-beat_num_end_i[0] : 
                                                                     reg_burst_rdwr_m1[1] ;
         assign beat_num_end_tmp       = beat_num_end_tmp_wider[NBEATS_LG2-1:0];
         
         if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch_NAB2_BL8
            assign beat_num_end  = 1'b0;
         end
         else begin: SINGLE_ch_x4_bl8
            assign beat_num_end  = beat_num_end_tmp;
         end
         
      end
      // MEMC_BURST_LENGTH 4 not supported in FR2
   end //x4_addr_gen
   else begin : x8_addr_gen // Handle NAB==3 case
       
       assign beat_num_end_i   = (siu_bl8==1'b1) ? {NBEATS_LG2{ 1'b0}} :
                                 (hbw_mode) ? addr_b4k[A_NB_HBW_LG2] :
                                 (qbw_mode) ? addr_b4k[A_NB_QBW_LG2] :   
                                                                  addr_b4k[A_NB_LG2];  

       assign beat_num_end_tmp_wider = (first_bl&~short_burst) ? 
                                          (reg_burst_rdwr_m1[2]- beat_num_end_i) : 
                                          (reg_burst_rdwr_m1[2]);

       assign beat_num_end_tmp = beat_num_end_tmp_wider[NBEATS_LG2-1:0];
         
       if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch_NAB3
           assign beat_num_end  = 1'b0;
       end
       else begin: SINGLE_ch
           assign beat_num_end  = beat_num_end_tmp;
       end
       
   end // x8_addr_gen   
  endgenerate
//spyglass enable_block W528

  always @ (posedge clk or negedge rst_n) begin: common_SEQ_PROC
    if (rst_n == 1'b0) begin
      packet_state_reg  <= IDLE;
      bl_addr_reg    <= {AXI_ADDR_BOUNDARY_MIN_P1{1'b0}};
      reg_burst_rdwr_m1 <= 3'b000;
      bl_mask_align_reg  <= 3'b000;
      
    end
    else  begin
      bl_addr_reg    <= bl_addr_next;
      packet_state_reg  <= packet_state_next;
      reg_burst_rdwr_m1  <= reg_burst_rdwr-4'b0001;
      bl_mask_align_reg  <= bl_mask_align;
    end // else: !if(rst_n == 1'b0)
  end // always @ (posedge clk or negedge rst_n)

  always @(*) begin: packet_state_COMB_PROC
    packet_state_next = packet_state_reg;
    empty = 1'b1;   
    full = 1'b1;
    first_bl = 1'b1;      
    case (packet_state_reg)
      IDLE: begin
        if (wr) begin
          empty = 1'b0; 
          if ( rd) begin
            if (last_bl) begin
              full = 1'b0;                 
            end
            else begin
              packet_state_next = PACKET;
            end
          end              
        end
      end
      default: begin
        first_bl = 1'b0;        
        empty = 1'b0;            
        if (rd) begin
          if (last_bl) begin
            packet_state_next = IDLE;
            full = 1'b0;
          end
        end
      end
      
    endcase // case(packet_state_reg)
  end // always @ (*)
  
  // Shared-ac related logic
  generate
   if (DUAL_CHANNEL_INTERLEAVE==1) begin: DUAL_dch
      wire [ENIF_HSIZEW-1:0] size_down;
      reg [ADDRW_ALIGN-1:0] addr_down;
      reg [ADDRW_ALIGN-1:0] addr_down_wrap;
      assign size_down = (asize<ENIF_HMAXSIZE) ? asize[ENIF_HSIZEW-1:0] : ENIF_HMAXSIZE;
   
      always @(*) begin: align_addr_to_size_COMB_PROC
      integer i;
         for (i=0; i<ADDRW_ALIGN;i=i+1) begin
            if (i<asize) begin
               addr_down[i]= 1'b0;
               addr_down_wrap[i]= 1'b0;
            end
            else begin
               addr_down[i]= addr[i];
               addr_down_wrap[i]= next_addr_wrap_autopre[i];
            end
         end
      end 

      assign addr_to_align    = addr_down;
      assign addr_to_align_wrap = addr_down_wrap;
      assign asize_to_align   = size_down;
      assign acc_addr_offset  = (~first_bl) ? {DEACC_INFOW{1'b0}} : addr_down[DEACC_INFOW-1:0];
   end
   else begin: SINGLE_dch
      assign addr_to_align    = addr;
      assign addr_to_align_wrap = next_addr_wrap_autopre;
      assign asize_to_align   = asize;
      assign acc_addr_offset  = {DEACC_INFOW{1'b0}};
   end
  endgenerate
  

  //------------------------------------------------------------------------
  //Generate Exclusive Access Payload
  //
  //Exclusive Read Transactions:
  //- The AXI Transaction is sent with the first DDRC transaction. 
  //Exclusive Write Transactions
  //- The AXI Transaction is sent with all DDRC transactions.
  //- Not entirely necessary as only the first DDRC transactions is used to
  //  determined the response type. The PA ensures that all DDRC transactions 
  //  that are part of the AXI exclusive transaction are sent to the DDRC in
  //  without interleaving from other ports. 
  //Write Transactions:
  //- The AXI Transaction is sent with all DDRC transactions.
  //- this ensures that if the DDRC transaction is interleaved with other
  //  ports the exclusive monitor will still detect if an exclusive read is
  //  violated. 
  //- A scenario here may be that the first DDRC write transaction is sent when no
  //  address is been monitored. Some time later before the AXI write
  //  transaction completes, the exclusive monitor starts to monitor an
  //  address. Hence its possible that the remaining DDRC write transactions
  //  violates the monitored address range. Hence the need to send the
  //  orginal AXI transaction with every DDRC transaction. 
  //------------------------------------------------------------------------
  generate
    if (EXA_ACC_SUPPORT==1) begin:EXACC
      wire [EXA_MAX_LENW-1:0]  exa_alen_i;
      wire [EXA_MAX_SIZEW-1:0] exa_asize_i; 
      wire [EXA_MAX_ADDRW-1:0] exa_addr_i;

      //In UPSIZE/DOWNSIZE configs addr is aligned to asize.
      //Aligned portion of addr is replaced with exa_addr.
      assign exa_addr_i   = {addr[EXA_MAX_ADDRW-1:AXI_MAXSIZE_EXA],exa_addr[AXI_MAXSIZE_EXA-1:0]};
      assign exa_alen_i   = exa_alen;
      assign exa_asize_i  = exa_asize;
      
      // Exclusive Access Write 
      reg [EXA_PYLD_W-1:0]         exa_acc_pyld_r;
      always @ (posedge clk or negedge rst_n) begin: exa_SEQ_PROC
        if (rst_n == 1'b0) begin
          exa_acc_pyld_r <= {EXA_PYLD_W{1'b0}};
        end else begin
          exa_acc_pyld_r <= exa_acc_pyld;
        end
      end
      assign exa_acc       = first_bl & (alock[0]==1'b1);
      assign exa_acc_instr = 1'b0; // useful only for read commands
      //exa payload creation. During first_bl new values of addr,alen and asize are latched.
      assign exa_acc_pyld  = (first_bl)? {exa_addr_i, exa_alen_i, exa_asize_i} : exa_acc_pyld_r;
      assign exa_acc_lock = (alock[0]==1'b1);
    end else begin: NO_EXACC
      assign exa_acc      = 1'b0;
      assign exa_acc_instr = 1'b0;
      assign exa_acc_pyld = {EXA_PYLD_W{1'b0}};
      assign exa_acc_lock = 1'b0;
    end
  endgenerate

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
    
  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

  assert_never #(0, 0, "bl_addr_update overflow", CATEGORY) a_bl_addr_update_overflow
    (clk, rst_n, (bl_addr_update_wider[AXI_ADDR_BOUNDARY_MIN_P1]==1'b1));

  assert_never #(0, 0, "beat_num_end_tmp overflow", CATEGORY) a_beat_num_end_tmp_overflow
    (clk, rst_n, (beat_num_end_tmp_wider[NBEATS_LG2]==1'b1));
    
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule // DWC_ddr_umctl2_xpi_wp
