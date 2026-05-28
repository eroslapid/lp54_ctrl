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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_rp.sv#1 $
// -------------------------------------------------------------------------
// Description:
//           uMCTL XPI Read Packetizer module
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module DWC_ddr_umctl2_xpi_rp
import DWC_ddrctl_reg_pkg::*;
  #(  
      parameter M_DW        = 32, // SDRAM data width
      parameter M_ADDRW     = 32, // Memory address width (word aligned address)
      parameter NAB         = 2,
      parameter PDBW_CASE   = 0,  // Programmable DRAM data width cases - Case1:1 ... Case5:5 
      parameter MEMC_BURST_LENGTH = 8,
      parameter NTOKENS     = 32,
      parameter NTOKENS_LG2 = `UMCTL_LOG2(NTOKENS),
      parameter NBEATS      = 2,
      parameter NBEATS_LG2  = 1,
      parameter BEAT_INFOW  = 4,      
      parameter XPI_BRW     = 3,  
      parameter AXI_ADDRW   = 32,                  // AXI address width
      parameter AXI_MAXSIZE = 2,
      parameter ACC_INFOW   = 2,
      parameter ENIF_LENW   = 6,                   // AXI a*len width
      parameter ENIF_SIZEW  = 3,                   // AXI a*size width
      parameter ENIF_LOCKW  = 2,
      parameter ENIF_STRBW  = 2,   
      parameter ENIF_MAXSIZE = 1,
      parameter ENIF_HSIZEW  = 3,
      parameter ENIF_HMAXSIZE = 1,
      parameter MAXSIZE = 2,
      parameter RPINFOW     = 4,
      parameter UP_SIZE   = 0,
      parameter DOWN_SIZE   = 0,   
      parameter AXI_ADDR_BOUNDARY = 12,          // Defines AXI address no crossing boundary ( default is 4k)
      parameter DUAL_CHANNEL_INTERLEAVE = 0,
      parameter DDRCTL_HET_INTERLEAVE = 0,
      parameter DDRCTL_LUT_ADDRMAP_EN = 0,
      parameter INTLVMODEW       = 2,
      // RRB enhancement with Simplified BAM
      parameter RRB_THRESHOLD_EN = 1,
      parameter RRB_LOCK_THRESHOLD_WIDTH = 0,
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
   
   //---------------------------------------------------------------------------
   // Interface Pins
   //---------------------------------------------------------------------------
   
   input                                clk,           // clock
   input                                rst_n,         // asynchronous reset

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                                siu_bl16,
   input                                siu_bl8,
   input                                siu_bl4, 
//spyglass enable_block W240
   input [XPI_BRW-1:0]                  reg_burst_rdwr,
   input [1:0]                          reg_ddrc_data_bus_width, //MSTR's DRAM bus width setting

   // bankgroup mask
   input [M_ADDRW-1:0]                  bg_or_bank_addrmap_mask,  
   
   // interface with WRAPP SPLIT 
   input [AXI_ADDRW-1:0]                addr,         // AXI first INCR burst address
   input [ENIF_LENW-1:0]                alen,         // AXI first INCR burst length
   input                                split,         // Single INCR burst 
   input                                short_burst,   // Short WRAP burst not crossing one BL

   // For EXA payload creation
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [AXI_MAXSIZE_EXA-1:0]          exa_addr,
   input [AXI_LENW-1:0]                 exa_alen,
   input [AXI_SIZEW-1:0]                exa_asize,
//spyglass enable_block W240
   
   // interface to AXI write/read  address channel interleave_mode  
   input [ENIF_SIZEW-1:0]               asize,         // AXI burst size
   input                                autopre,       // AXI auto precharge
   input [AXI_ADDRW-1:0]                next_addr_wrap_autopre, // For AXI auto precharge with wrap burst   
   input [ENIF_LENW-1:0]                next_alen_wrap_autopre, // For AXI auto precharge with wrap burst 
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [ENIF_LOCKW-1:0]               alock,         // AXI lock
//spyglass enable_block W240
   input                                wr,            // AXI address valid
   output reg                           full,          // AXI address ready
   
   // ENIF Address channel
   output [M_ADDRW-1:0]                 e_addr,
   
   output                               e_alast,       // ENIF address last
   output reg                           empty,         // ENIF address valid
   input                                rd,            // ENIF address ready
   output reg                           e_autopre,     // ENIF address auto precharge

   output [ACC_INFOW-1:0]               acc_info,

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   // RRB SBAM enhancement
   input [RRB_LOCK_THRESHOLD_WIDTH-1:0] reg_arb_rrb_lock_threshold,
//spyglass enable_block W240
   
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
   input [1:0]                          reg_arb_dch_density_ratio,
   input [5:0]                          dch_bit,
   input [5:0]                          e_addr_max_loc,
   input [5:0]                          e_addr_max_m1_loc, 
   input [M_ADDRW-1:0]                  e_addr_max_loc_addrmap_mask,
   input [M_ADDRW-1:0]                  e_addr_max_m1_loc_addrmap_mask,
//spyglass enable_block W240
  
   // Use SBAM (Simplified BAM) for RRB enhancement
   // RP module should indicate which is the lead token for the allocated tokens
   output                               sbam_lead_burst,
   output                               sbam_second_burst,
   // Due to the wrap mechanism, the WS module should incated how many tokens are allocated for the AXI read transaction
   // Rather than RP modules. (If RP module indicate how many tokens, it's late due to the second burst if WRAP)
   output [NTOKENS_LG2:0]               sbam_tokens_allocated,
 
   output                               bam_lead_burst,
   output [AXI_MAXSIZE-1:0]             bam_addr_offset,

   // POST_WAQ IF
   output [RPINFOW-1:0]                 info,      // Post write address queues data
   output                               exa_acc,       // asserted, if exclusive read/write, with the first packet
   output                               exa_acc_lock,  // asserted, if exclusive write, for all packets of an AXI burst
   output                               exa_acc_instr, // asserted, if exclusive read/write, with all the packets
   
   output [EXA_PYLD_W-1:0]              exa_acc_pyld,
   output [BEAT_INFOW-1:0]              beat_info
   );

  localparam M_NB             = M_DW/8;
  // M_DW
  localparam M_NB_LG2         = (M_NB<=1)   ? 0 :       // 8bits
                                (M_NB<=2)   ? 1 :       // 16bits
                                (M_NB<=4)   ? 2 :       // 32bits
                                (M_NB<=8)   ? 3 :       // 64bits
                                (M_NB<=16)  ? 4 : 5;    // 128bits
  
  localparam A_NB_LG2         = NAB+M_NB_LG2;
  localparam A_NB_HBW_LG2         = NAB+M_NB_LG2-1;
  localparam A_NB_QBW_LG2         = NAB+M_NB_LG2-2;
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
  
  
  localparam LEN_BYTEW = ENIF_LENW+ENIF_MAXSIZE+1;

  localparam ZERO_ENIF_LENW   = {ENIF_LENW{1'b0}};
  localparam ONE_ENIF_LENW    = {{(ENIF_LENW-1){1'b0}},1'b1};   
  localparam THREE_ENIF_LENW  = {{(ENIF_LENW-2){1'b0}},2'b11};
  localparam SIZEW_ALIGN      = (DUAL_CHANNEL_INTERLEAVE==1) ? ENIF_HSIZEW : ENIF_SIZEW;
  localparam ADDRW_ALIGN      = AXI_ADDRW;
  localparam AXI_ADDR_BOUND_ALIGN  = (AXI_ADDR_BOUNDARY_MIN<ADDRW_ALIGN) ? AXI_ADDR_BOUNDARY_MIN : ADDRW_ALIGN;

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [PACKET_STATE_WIDTH-1:0]         packet_state_next;
  reg [PACKET_STATE_WIDTH-1:0]         packet_state_reg; 
  reg                                  first_bl;   
                           
  wire [M_ADDRW-1:0]                   e_addr_l;
  wire [M_ADDRW-1:0]                   e_addr_l_wrap_autopre;
  wire [M_ADDRW:0]                     e_addr_wrap_autopre;
  wire [M_ADDRW-1:0]                   hif_addr_last_l;
  wire [M_ADDRW-1:0]                   hif_addr_last_l_wrap_autopre;

  wire [ADDRW_ALIGN-1:0]               addr_to_align;
  wire [ADDRW_ALIGN-1:0]               addr_to_align_wrap;
  wire [SIZEW_ALIGN-1:0]               asize_to_align;
  wire [ENIF_LENW-1:0]                 alen_to_align;

  wire [ACC_INFOW-1:0]                 acc_addr_offset;
  
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
  
  wire                                 last_bl;
  reg [2:0]                            bl_mask_align;
  reg [2:0]                            bl_mask_align_reg;
  
  wire [AXI_ADDR_BOUNDARY_MIN_P1-1:0]  bl_addr_cur;
  wire [MAXSIZE-1:0]                   addr_offset;
  wire [NBEATS_LG2-1:0]                beat_num_start;
  reg [NBEATS_LG2-1:0]                 beat_num_start_i;
  wire [NBEATS_LG2-1:0]                beat_num_end_i;
  wire [NBEATS_LG2-1:0]                beat_num_end;
  wire [NBEATS_LG2:0]                  beat_num_end_wider;
  reg [2:0]                            reg_burst_rdwr_m1;
  wire [INTLVMODEW-1:0]                interleave_mode;
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
  wire                                 up_size_act, dw_size_act;


//spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block 
  assign hbw_mode = (reg_ddrc_data_bus_width==HBW && PDBW_CASE!=0) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW && PDBW_CASE!=0) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW ) ? 1'b1: 1'b0;
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
                       PDBW_CASE==2 ? qbw_mode :
                       PDBW_CASE==5 ? 1'b1 
                                    : 1'b0; //case 4

  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block
  wire alen_zero  = (alen_to_align==ZERO_ENIF_LENW) ? 1'b1 : 1'b0;
  wire alen_one   = (alen_to_align==ONE_ENIF_LENW) ? 1'b1 : 1'b0;
  wire alen_three = (alen_to_align==THREE_ENIF_LENW) ? 1'b1 : 1'b0;
  //spyglass enable_block W528   
  
  assign beat_num_start = first_bl ? beat_num_start_i : {NBEATS_LG2{1'b0}};
  assign beat_info = {interleave_mode,beat_num_end,beat_num_start};
  assign acc_info = acc_addr_offset;
  
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
  end
  //spyglass enable_block W415a

  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression '(alen + 1)' found in module 'DWC_ddr_umctl2_xpi_rp'
  //SJ: This coding style is acceptable and there is no plan to change it.
  assign len_byte = ((alen+1) << asize)-1;
  assign len_byte_wrap_autopre = ((next_alen_wrap_autopre+1) << asize)-1;
  //spyglass enable_block SelfDeterminedExpr-ML
  
  //spyglass disable_block W484
  //SMD: Possible assignment overflow: lhs width 13 (Expr: 'addr_end') should be greater than rhs width 13 (Expr: '(addr_b4k + len_byte)') to accommodate carry/borrow bit
  //SJ: Width depends on configuration. Based on below SJs, this can be safely waived.
  //spyglass disable_block W164b
  //SMD: LHS: 'addr_end' width 17 is greater than RHS: '(addr_b4k + len_byte)' width 16 in assignment 
  //SJ: Assuming that we want to keep the carry. Previosly waived in Leda with LJ: len_byte is the increment and is shorter than addr_b4k; LJ: addr_end is one bit wider than addr_b4k
  //spyglass disable_block W164a
  //SMD: LHS: 'addr_end' width 13 is less than RHS: '(addr_b4k + len_byte)' width 14 in assignment
  //SJ: Previosly waived in Leda with LJ: len_byte is the increment and is shorter than addr_b4k; LJ: addr_end is one bit wider than addr_b4k
  //spyglass disable_block TA_09
  //SMD: Net 'DWC_ddrctl.U_xpi_0.U_xpi_read.U_blue_rd_q.U_rp.\RP_inst[0].U_rp .len_byte[13]' [in 'DWC_ddr_umctl2_xpi_rp'] is not observable[affected by other input(s)].
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

  if (RRB_THRESHOLD_EN == 1) begin : WITH_SBAM

    wire [LEN_BYTEW:0]                   tokens_allocated_tmp;
    wire [LEN_BYTEW-M_NB_LG2-1:0]        tokens_allocated_tmp2; // set its width to this rather than RRB_LOCK_THRESHOLD_WIDTH is helpful for debug
    wire [LEN_BYTEW-M_NB_LG2-1:0]        tokens_allocated_tmp3; // set its width to this rather than RRB_LOCK_THRESHOLD_WIDTH is helpful for debug
    wire [LEN_BYTEW-M_NB_LG2:0]          tokens_allocated_tmp4; // set its width to this rather than RRB_LOCK_THRESHOLD_WIDTH is helpful for debug

    wire [NTOKENS_LG2:0]                 tokens_allocated_lead;     // qualify tokens number limited to NTOKENS, hence extra 1 bit needed.
    wire [NTOKENS_LG2:0]                 tokens_allocated_second;   // qualify tokens number limited to NTOKENS

    reg  [NTOKENS_LG2:0]                 tokens_allocated_lead_reg; // qualify tokens number limited to NTOKENS

    wire [1:0]                           data_bus_width_int;
    // for synthesis advantage
    assign data_bus_width_int = (reg_ddrc_data_bus_width==HBW && PDBW_CASE!=0) ? HBW : (reg_ddrc_data_bus_width==QBW && PDBW_CASE!=0) ? QBW : FBW;

    wire [XPI_BRW-1:0] reg_burst_rdwr_log2;  
    assign reg_burst_rdwr_log2 = (reg_burst_rdwr == 8) ? 3 :
                                 (reg_burst_rdwr == 4) ? 2 :
                                 (reg_burst_rdwr == 2) ? 1 : 0;

    wire [NTOKENS_LG2:0]                 rrb_lock_threshold;
    assign rrb_lock_threshold  = reg_arb_rrb_lock_threshold + 1'b1;

    assign tokens_allocated_tmp   = addr_end - bl_addr_cur+ 1'b1; // aligned with HIF burst boundry

    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '(tokens_allocated_tmp>>(reg_burst_rdwr_log2 + M_NB_LG2 + 1)) + |(tokens_allocated_tmp - ((tokens_allocated_tmp>>(reg_burst_rdwr_log2 + M_NB_LG2 + 1))<<(reg_burst_rdwr_log2 + M_NB_LG2 + 1)))' found in module 'DWC_ddr_umctl2_xpi_rp'
    //SJ: This coding style is acceptable and there is no plan to change it.
    //spyglass disable_block W164a
    //SMD: LHS: 'tokens_allocated_tmp2' width e.g. 11 is less than RHS: '(tokens_allocated_tmp>>(reg_burst_rdwr_log2 + M_NB_LG2 + 1)) + |(tokens_allocated_tmp - ((tokens_allocated_tmp>>(reg_burst_rdwr_log2 + M_NB_LG2 + 1))<<(reg_burst_rdwr_log2 + M_NB_LG2 + 1)))' width e.g. 16 in assignment 
    //SJ: No suitable recoding found. And this contains bits right shift operation.
    // data amount for one HIF burst, is 2^(reg_burst_rdwr_log2 + M_NB_LG2 +1)
    // hence to get how many bursts needed, do the right bits shift operation
    // if there is 1s in the LSB bits within lower [reg_burst_rdwr_log2+M_NB_LG2:0] bits, another burst is needed.
    assign tokens_allocated_tmp2 = (tokens_allocated_tmp>>(reg_burst_rdwr_log2 + M_NB_LG2 + 1 - data_bus_width_int)) + 
                                   |(tokens_allocated_tmp - ((tokens_allocated_tmp>>(reg_burst_rdwr_log2 + M_NB_LG2 + 1 - data_bus_width_int))<<(reg_burst_rdwr_log2 + M_NB_LG2 + 1 - data_bus_width_int)));
    //spyglass enable_block SelfDeterminedExpr-ML
    //spyglass enable_block W164a

    assign tokens_allocated_tmp3 = short_burst ? 'h1 : tokens_allocated_tmp2;
    assign tokens_allocated_tmp4 = tokens_allocated_tmp3 + split;

    //spyglass disable_block W164a
    //SMD: LHS: 'tokens_allocated_lead' width may be less than RHS: 'rrb_lock_threshold' width in assignment 
    //SJ: No suitable recoding found. And this contains bits right shift operation.
    //spyglass disable_block W164b
    //SMD: LHS: 'tokens_allocated_lead' width may be greater than RHS: 'rrb_lock_threshold' width in assignment 
    //SJ: No suitable recoding found. And this contains bits right shift operation.
    // if split == 0, it means that this burst is an INCR burst, just compare the allocated number and the register threshold
    // if split == 1, it means that this burst is a WRAP burst, compare the allocated number + 1 and the register threshold during the first INCR
    assign tokens_allocated_lead = ({{(NTOKENS_LG2){1'b0}},tokens_allocated_tmp4} > {{(LEN_BYTEW-M_NB_LG2){1'b0}},rrb_lock_threshold})? rrb_lock_threshold : (tokens_allocated_tmp4);
    //spyglass enable_block W164b
    //spyglass enable_block W164a

    always @ (posedge clk or negedge rst_n) begin : tokens_allocated_reg_PROC
      if(rst_n == 1'b0)
        tokens_allocated_lead_reg <= {(NTOKENS_LG2+1){1'b0}};
      else if(sbam_lead_burst)
        tokens_allocated_lead_reg <= tokens_allocated_lead;
    end

    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '((tokens_allocated_tmp3 - 1'b1) > (rrb_lock_threshold - tokens_allocated_lead_reg))' found in module 'DWC_ddr_umctl2_xpi_rp'
    //SJ: This coding style is acceptable and there is no plan to change it.
    //spyglass disable_block W164a
    //SMD: LHS: 'tokens_allocated_second' width e.g. 7 is less than RHS: '(rrb_lock_threshold - tokens_allocated_lead_reg)' width e.g. 7 in assignment. Overflow will not happen actually.
    //SJ: No suitable recoding found. And this contains bits right shift operation.
    // if split == 1, it means that this burst is a WRAP burst, compare the allocated number + 1 and the remaining register threshold during the second INCR
    assign tokens_allocated_second = ((tokens_allocated_tmp3 - 1'b1) > (rrb_lock_threshold - tokens_allocated_lead_reg)) ? (rrb_lock_threshold - tokens_allocated_lead_reg) : (tokens_allocated_tmp3 - 1'b1);
    //spyglass enable_block W164a
    //spyglass enable_block SelfDeterminedExpr-ML
  
    wire                                 lead_burst;
    reg                                  split_burst;

    // the lead burst may indicate a real burst's header, may also indicate a split/derived burst's header which can be regarded as part the previous burst.
    // In this case, the split/derived burst's header should be ignored.
    // Meanwhile the two bursts allocated number should be added to consist of all the allocated numbers.
    assign lead_burst             = (packet_state_reg == IDLE) && wr && rd;

    always @ (posedge clk or negedge rst_n) begin : split_burst_PROC
      if(rst_n == 1'b0)
        split_burst <= 1'b0;
      else if(lead_burst && split)
        split_burst <= 1'b1;
      else if(lead_burst && ~split)
        split_burst <= 1'b0;
    end

    assign sbam_lead_burst = lead_burst && ~split_burst;
    assign sbam_second_burst = lead_burst && split_burst;
    assign sbam_tokens_allocated = (sbam_lead_burst ) ? tokens_allocated_lead :
                                   (sbam_second_burst) ? tokens_allocated_second : 0;

  end else begin : NO_SBAM // RRB_THRESHOLD_EN == 0
    assign sbam_lead_burst = 1'b0;
    assign sbam_second_burst = 1'b0;
    assign sbam_tokens_allocated = {(NTOKENS_LG2+1){1'b0}};
  end

  assign bam_lead_burst = (dw_size_act==1) ? (first_bl | (~(|addr_offset[AXI_MAXSIZE-1 : 0])) ) : 1'b1;
  assign bam_addr_offset = addr_offset[AXI_MAXSIZE-1:0];

  assign addr_offset = (up_size_act==1 && ~first_bl) ? {MAXSIZE {1'b0}}
                                                     : ( dw_size_act==1  && ~first_bl) ? {e_addr[MAXSIZE-1:0] << (hbw_mode ? M_NB_HBW_LG2 :
                                                                                                                  qbw_mode ? M_NB_QBW_LG2 : M_NB_LG2)}
                                                     :addr[MAXSIZE-1:0];
  assign info = {split,addr_offset,alen,asize};  
  assign e_alast = ((dw_size_act==1)||(up_size_act==1)||(DUAL_CHANNEL_INTERLEAVE==1)) ? last_bl:last_bl & ~split;

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
  wire [AXI_ADDR_BOUNDARY_MIN-1:0]  addr_b4k_tmp_wrap_autopre;
  wire [AXI_ADDR_BOUNDARY_MIN-1:0]  hif_addr_last_tmp;
  wire [AXI_ADDR_BOUNDARY_MIN-1:0]  hif_addr_last_tmp_wrap_autopre;
  assign addr_b4k_tmp = bl_addr_cur[AXI_ADDR_BOUNDARY_MIN-1:0];
  assign addr_b4k_tmp_wrap_autopre = addr_align_bl_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:0];
  assign hif_addr_last_tmp = addr_end[AXI_ADDR_BOUNDARY_MIN-1:0];
  assign hif_addr_last_tmp_wrap_autopre = addr_end_wrap_autopre[AXI_ADDR_BOUNDARY_MIN-1:0];
  //spyglass disable_block W164a
  //SMD: LHS: 'e_addr_l' width 33 is less than RHS: '{addr_a4k ,addr_b4k_tmp[(AXI_ADDR_BOUNDARY - 1):A_NB_LG2] }' width 44 in assignment 
  //SJ: No suitable recoding found. Previosly waived in Leda with LJ: AXI_ADDRW and M_ADDRW are different, addr_b4k_tmp can be truncated when assigned to e_addr_l
  generate
    if (AXI_ADDR_BOUNDARY<AXI_ADDRW) begin:axi_addr_boundary
      wire [AXI_ADDRW-AXI_ADDR_BOUNDARY-1:0] addr_a4k;   
      wire [AXI_ADDRW-AXI_ADDR_BOUNDARY-1:0] addr_a4k_wrap_autopre;
      assign addr_a4k = addr[AXI_ADDRW-1:AXI_ADDR_BOUNDARY];
      assign addr_a4k_wrap_autopre = next_addr_wrap_autopre[AXI_ADDRW-1:AXI_ADDR_BOUNDARY];
      if(PDBW_CASE==0) begin : no_pgdbw
        assign e_addr_l = {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
        assign e_addr_l_wrap_autopre = {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
        assign hif_addr_last_l = {addr_a4k,hif_addr_last_tmp[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
        assign hif_addr_last_l_wrap_autopre = {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
      end else begin
        assign e_addr_l = (reg_ddrc_data_bus_width==HBW) ? {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                          (reg_ddrc_data_bus_width==QBW) ? {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                         : {addr_a4k,addr_b4k_tmp[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};
  
        assign e_addr_l_wrap_autopre = (reg_ddrc_data_bus_width==HBW) ? {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                                       (reg_ddrc_data_bus_width==QBW) ? {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                                      : {addr_a4k_wrap_autopre,addr_b4k_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]} ;      
  
        assign hif_addr_last_l = (reg_ddrc_data_bus_width==HBW) ?  {addr_a4k,hif_addr_last_tmp[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                                 (reg_ddrc_data_bus_width==QBW) ?  {addr_a4k,hif_addr_last_tmp[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                                :  {addr_a4k,hif_addr_last_tmp[AXI_ADDR_BOUNDARY-1:A_NB_LG2]} ;
  
        assign hif_addr_last_l_wrap_autopre = (reg_ddrc_data_bus_width==HBW) ?  {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_HBW_LG2]} :
                                              (reg_ddrc_data_bus_width==QBW) ?  {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_QBW_LG2]} 
                                                                             : {addr_a4k_wrap_autopre,hif_addr_last_tmp_wrap_autopre[AXI_ADDR_BOUNDARY-1:A_NB_LG2]};       
      end  
    end
    if (AXI_ADDR_BOUNDARY>=AXI_ADDRW) begin:axi_addr_boundary_max
      assign e_addr_l = addr_b4k_tmp[AXI_ADDRW-1:A_NB_LG2];
      assign e_addr_l_wrap_autopre = {addr_b4k_tmp_wrap_autopre[AXI_ADDRW-1:A_NB_LG2]};
      assign hif_addr_last_l = hif_addr_last_tmp[AXI_ADDRW-1:A_NB_LG2];
      assign hif_addr_last_l_wrap_autopre = hif_addr_last_tmp_wrap_autopre[AXI_ADDRW-1:A_NB_LG2];
    end
  endgenerate
  //spyglass enable_block W164a

generate 
  if (DDRCTL_HET_INTERLEAVE == 1) begin: e_addr_rd_int_gen
    wire [M_ADDRW-1:0]      e_addr_int;
    wire [M_ADDRW-1:0]      e_addr_final;
    
    assign e_addr_int        = {e_addr_l[M_ADDRW-NAB-1:0],{NAB{1'b0}}};
    assign e_addr            = e_addr_final;
    
    //instance
    DWC_ddr_umctl2_xpi_xltr
     
    #(
      .M_ADDRW    (M_ADDRW))
    U_xpi_rd_xltr
    (.e_addr_in                      (e_addr_int),
     .e_addr_max_loc_addrmap_mask    (e_addr_max_loc_addrmap_mask),
     .e_addr_max_m1_loc_addrmap_mask (e_addr_max_m1_loc_addrmap_mask),
     .reg_arb_dch_density_ratio      (reg_arb_dch_density_ratio),
     .e_addr_max_loc                 (e_addr_max_loc),
     .e_addr_max_m1_loc              (e_addr_max_m1_loc),
     .dch_bit                        (dch_bit),
     .e_addr_out                     (e_addr_final) 
    );
  end else begin: e_addr_rd_gen
    assign e_addr    = {e_addr_l[M_ADDRW-NAB-1:0],{NAB{1'b0}}};
  end
endgenerate

  assign e_addr_wrap_autopre = {1'b0,e_addr_l_wrap_autopre[M_ADDRW-NAB-1:0],{NAB{1'b0}}};

  assign hif_addr_last = {hif_addr_last_l[M_ADDRW-NAB-1:0],{NAB{1'b0}}}; // Expected the last hif command address
  assign hif_addr_last_wrap_autopre = {1'b0,hif_addr_last_l_wrap_autopre[M_ADDRW-NAB-1:0],{NAB{1'b0}}}; // Expected the last hif command address after over the wrap burst boundary
  assign incr_hif_addr_bit = (reg_burst_rdwr << 1);
  assign mask_hif_addr_bit = incr_hif_addr_bit - 1'b1;

  // Logic to support HET Rank address mapper
  wire [M_ADDRW-1:0] bg_or_bank_addrmap_mask_int;

    assign bg_or_bank_addrmap_mask_int = bg_or_bank_addrmap_mask;
  
  //spyglass disable_block TA_09
  //SMD:Net 'DWC_ddrctl.bg_or_bank_addrmap_mask[0]' [in 'DWC_ddrctl'] is not observable[affected by other input(s)]. Adding a test-point [Obs = y]  will make 4 nets observable[Fault Improvement = '8'[%Increase 0.0]]
  //SJ:Functionally correct. if MEMC_DDR4 is not defined, bg_or_bank_addrmap_mask always keeps 0.
  // exp_next_same_bg_ba_addr signal indecats the next command of same bg or bank with current command.
  // exp_next_same_bg_ba_addr_wrap signal indecats the next command of same bg or bank with current command after over the wrap burst boundary.
  // Expaneded bit width to avoid Spyglass error
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
      if(split) begin // Wrap burst mode
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
   
  generate
   if (NAB==1) begin: x2_addr_gen
      if (MEMC_BURST_LENGTH==16) begin: mbl16_addr_gen
         wire wrap2_bl8,wrap2_bl4,wrap2_bl16;
         wire wrap4_bl8, wrap4_bl16;
         wire wrap1_bl4, wrap1_bl8;

         assign wrap1_bl4        = alen_zero & siu_bl4 & short_burst; // only in up-size
         assign wrap1_bl8        = alen_zero &  siu_bl8 & short_burst; // only in up-size
         assign wrap2_bl4        = alen_one & siu_bl4 & short_burst;
         assign wrap2_bl8        = alen_one & siu_bl8 & short_burst;
         assign wrap2_bl16       = alen_one & siu_bl16 & short_burst;
         assign wrap4_bl8        = alen_three & siu_bl8 & short_burst;
         assign wrap4_bl16       = alen_three &  siu_bl16 & short_burst;

         assign interleave_mode[1]  = wrap4_bl8|wrap4_bl16;
         assign interleave_mode[0]  = wrap2_bl8|wrap2_bl4|wrap2_bl16|wrap1_bl4|wrap1_bl8;
         
         always @(*) begin: Beat_num_start_CALC
            casez ({wrap4_bl16,wrap4_bl8,wrap2_bl16,wrap2_bl8,wrap2_bl4,wrap1_bl8,wrap1_bl4,siu_bl16,siu_bl8})
               9'b1000000??:  begin
                                 beat_num_start_i  = {addr_b4k[A_NB_LG2+2],addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                              end
               9'b0100000??:  begin
                                 beat_num_start_i  = {1'b0,addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                              end
               9'b0010000??:  begin
                                 beat_num_start_i  = {addr_b4k[A_NB_LG2+2],addr_b4k[A_NB_LG2+1],addr_b4k[A_NB_LG2]};
                              end
               9'b0001000??,
               9'b0000010??:  begin
                                 beat_num_start_i  = {1'b0,addr_b4k[A_NB_LG2+1],addr_b4k[A_NB_LG2]};
                              end
               9'b0000100??,
               9'b0000001??:  begin
                                 beat_num_start_i  = {2'b00,addr_b4k[A_NB_LG2]};
                              end
               9'b000000010:  begin // bl16 no short
                                 beat_num_start_i  = {addr_b4k[A_NB_LG2]&(~addr_b4k[A_NB_LG2+2]) | ((~addr_b4k[A_NB_LG2])&(addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2+2])),addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                              end
               9'b000000001:  begin // bl8 no short
                                 beat_num_start_i  = {addr_b4k[A_NB_LG2] | ((~addr_b4k[A_NB_LG2])&addr_b4k[A_NB_LG2+1]),addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                              end
               default:       begin // bl4/bl2 no short
                                 beat_num_start_i  = {addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                              end
            endcase
         end

         assign beat_num_end_i   = (siu_bl16==1'b1) ? addr_b4k[A_NB_LG2+2:A_NB_LG2] :
                                   (siu_bl8==1'b1) ?  {1'b0,addr_b4k[A_NB_LG2+1:A_NB_LG2]} :
                                                      {2'b00,addr_b4k[A_NB_LG2]};

         assign beat_num_end_wider =   wrap4_bl16|wrap2_bl16         ? 3'b111 :
                                       wrap4_bl8|wrap2_bl8|wrap1_bl8 ? 3'b011 :
                                       wrap2_bl4|wrap1_bl4           ? 3'b001 :
                                       (first_bl&~short_burst) ? reg_burst_rdwr_m1[2:0]-beat_num_end_i[2:0] : 
                                                                 reg_burst_rdwr_m1[2:0] ;
         assign beat_num_end = beat_num_end_wider[NBEATS_LG2-1:0];
         
      end
      else if (MEMC_BURST_LENGTH==8) begin: mbl8_addr_gen
   
         wire wrap2_bl8 ;// Optimize special case WRAP of ALEN 1 in BL8
         wire wrap2_bl4 ;// Optimize special case WRAP of ALEN 1 in BL4   

         assign wrap2_bl8 = alen_one & siu_bl8 & short_burst;
         assign wrap2_bl4 = alen_one & siu_bl4 & short_burst;    

         assign interleave_mode[1] = 1'b0;
         assign interleave_mode[0] = wrap2_bl8|wrap2_bl4;
   
         always @(*) begin: Beat_num_start_CALC
            casez ({wrap2_bl8,wrap2_bl4,siu_bl8,siu_bl4})
               4'b10??: begin
                           beat_num_start_i  = addr_b4k[A_NB_LG2+1:A_NB_LG2];
                        end
               4'b01??: begin
                           beat_num_start_i  = {1'b0,addr_b4k[A_NB_LG2]};
                        end
               4'b0010: begin
                           beat_num_start_i  = {addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                        end
               4'b0001: begin
                           beat_num_start_i  = {1'b0^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                        end
               default: begin
                           beat_num_start_i  = 2'b00;
                        end
            endcase
         end

         assign beat_num_end_i   = (siu_bl8==1'b1) ? addr_b4k[A_NB_LG2+1:A_NB_LG2]: 
                                   (siu_bl4==1'b1) ? {1'b0,addr_b4k[A_NB_LG2]} : 2'b0;

         assign beat_num_end_wider =   wrap2_bl8               ? 2'b11:
                                       wrap2_bl4               ? 2'b01:
                                       (first_bl&~short_burst) ?  reg_burst_rdwr_m1[1:0]-beat_num_end_i[1:0] : 
                                                               reg_burst_rdwr_m1[1:0] ;
                                                         
         assign beat_num_end = beat_num_end_wider[NBEATS_LG2-1:0];         
         
      end
      else if (MEMC_BURST_LENGTH==4) begin: mbl4_addr_gen
         assign interleave_mode = 2'b00;    
         
         always @(*) begin: Beat_num_start_CALC
            casez ({siu_bl8,siu_bl4})
               2'b00:   begin
                           beat_num_start_i  = 1'b0;
                        end
               default: begin
                           beat_num_start_i  = addr_b4k[A_NB_LG2];
                        end
            endcase
         end
                                
         assign beat_num_end_i   = (siu_bl8==1'b1) ? addr_b4k[A_NB_LG2]: 
                                (siu_bl4==1'b1) ? addr_b4k[A_NB_LG2]: 1'b0;      

         assign beat_num_end_wider = (first_bl&~short_burst) ? reg_burst_rdwr_m1[0]-beat_num_end_i[0] : 
                                                               reg_burst_rdwr_m1[0] ;

         assign beat_num_end = beat_num_end_wider[NBEATS_LG2-1:0];
                  
      end
   end
   else if (NAB==2) begin: x4_addr_gen
      if (MEMC_BURST_LENGTH==16) begin: mbl16_addr_gen
         wire wrap2_bl8, wrap2_bl16;
         wire wrap1_bl8, wrap1_bl16;

         assign wrap1_bl8       = alen_zero & siu_bl8 & short_burst; // only in up-size
         assign wrap1_bl16      = alen_zero & siu_bl16 & short_burst; // only in up-size
         assign wrap2_bl8       = alen_one & siu_bl8 & short_burst;
         assign wrap2_bl16      = alen_one & siu_bl16 & short_burst;

         assign interleave_mode[1] = 1'b0;
         assign interleave_mode[0] = wrap2_bl8|wrap2_bl16|wrap1_bl16|wrap1_bl8;
         

         always @(*) begin: Beat_num_start_CALC
            casez ({wrap2_bl16,wrap1_bl16,wrap2_bl8,wrap1_bl8,siu_bl16,siu_bl8})
               6'b1000??,
               6'b0100??:  begin
                              beat_num_start_i = {addr_b4k[A_NB_LG2+1:A_NB_LG2]};
                           end
               6'b0010??,
               6'b0001??:  begin
                              beat_num_start_i = {1'b0,addr_b4k[A_NB_LG2]};
                           end
               6'b000010:  begin
                              beat_num_start_i = {addr_b4k[A_NB_LG2+1]^addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                           end
               6'b000001:  begin
                              beat_num_start_i = {addr_b4k[A_NB_LG2],addr_b4k[A_NB_LG2]};
                           end
               default:    begin
                              beat_num_start_i = 2'b00;
                           end
            endcase
         end

         assign beat_num_end_i   =  (siu_bl16==1'b1) ? addr_b4k[A_NB_LG2+1:A_NB_LG2]: 
                                    (siu_bl8==1'b1) ? {1'b0,addr_b4k[A_NB_LG2]} : 2'b0;

         assign beat_num_end_wider     =  wrap2_bl16|wrap1_bl16   ? 2'b11 :
                                          wrap2_bl8|wrap1_bl8     ? 2'b01 : 
                                          (first_bl&~short_burst) ? reg_burst_rdwr_m1[2:1]-beat_num_end_i[1:0] : 
                                                                    reg_burst_rdwr_m1[2:1] ;

         assign beat_num_end = beat_num_end_wider[NBEATS_LG2-1:0];
         
      end
      else if (MEMC_BURST_LENGTH==8) begin: mbl8_addr_gen
         assign interleave_mode = 2'b00;  

         always @(*) begin: Beat_num_start_CALC
            casez ({siu_bl8})
               1'b1:    begin
                           beat_num_start_i  = addr_b4k[A_NB_LG2];
                        end
               default: begin
                           beat_num_start_i  = 1'b0;
                        end
            endcase
         end

         assign beat_num_end_i      = (siu_bl8==1'b1) ? addr_b4k[A_NB_LG2]:1'b0;

         assign beat_num_end_wider  = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[1]-beat_num_end_i[0] : 
                                                                  reg_burst_rdwr_m1[1] ;
                                                                  
         assign beat_num_end = beat_num_end_wider[NBEATS_LG2-1:0];
         
      end
      // MEMC_BURST_LENGTH 4 not supported in FR2
   end
   else begin: x8_addr_gen
       if (MEMC_BURST_LENGTH==16) begin: mbl16_addr_gen
           assign interleave_mode = 2'b00;  

           always @(*) begin: Beat_num_start_CALC
               casez (siu_bl16)
                   1'b1:    begin
                       beat_num_start_i  = (hbw_mode==1'b1 && PDBW_CASE!=0) ?  addr_b4k[A_NB_HBW_LG2] :
                                           (qbw_mode==1'b1 && PDBW_CASE!=0) ?  addr_b4k[A_NB_QBW_LG2] 
                                                                            :  addr_b4k[A_NB_LG2];
                   end
                   default: begin
                       beat_num_start_i  = 1'b0;
                   end
               endcase
           end

           assign beat_num_end_i      = (hbw_mode==1'b1 && PDBW_CASE!=0) ?  addr_b4k[A_NB_HBW_LG2] :
                                        (qbw_mode==1'b1 && PDBW_CASE!=0) ?  addr_b4k[A_NB_QBW_LG2] 
                                                                         :  addr_b4k[A_NB_LG2];

           assign beat_num_end_wider  = (first_bl&~short_burst) ?   reg_burst_rdwr_m1[1]-beat_num_end_i[0]
                                                                :   reg_burst_rdwr_m1[1] ;
                                                                  
           assign beat_num_end = siu_bl16 ? beat_num_end_wider[NBEATS_LG2-1:0] : 1'b0;
         
       end       
   end   
  endgenerate

 
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
    first_bl = 1'b1;      
    empty = 1'b1;   
    full = 1'b1;   
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
        if (rd&last_bl) begin 
          packet_state_next = IDLE;
          full = 1'b0;
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
      wire size_ratio;
      wire [ENIF_LENW-1:0] alen_down;

      assign size_down = (asize<ENIF_HMAXSIZE) ? asize[ENIF_HSIZEW-1:0] : ENIF_HMAXSIZE;
      assign size_ratio = (asize>=ENIF_HMAXSIZE) ? (asize-ENIF_HMAXSIZE):0;
      //spyglass disable_block SelfDeterminedExpr-ML
      //SMD: Self determined expression '(alen + 1)' found in module 'DWC_ddr_umctl2_xpi_rp'
      //SJ: This coding style is acceptable and there is no plan to change it.
      assign alen_down = ((alen+1) << size_ratio)-1;
      //spyglass enable_block SelfDeterminedExpr-ML

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
      assign alen_to_align    = alen_down;
      assign acc_addr_offset  = (~first_bl) ? {AXI_MAXSIZE{1'b0}} : addr_down[AXI_MAXSIZE-1:0];
   end
   else begin: SINGLE_dch
      assign addr_to_align    = addr;
      assign addr_to_align_wrap = next_addr_wrap_autopre;
      assign asize_to_align   = asize;
      assign alen_to_align    = alen;
      assign acc_addr_offset  = {ACC_INFOW{1'b0}};
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
      wire [EXA_MAX_ADDRW-1:0] exa_addr_i;
      wire [EXA_MAX_LENW-1:0]  exa_alen_i; 
      wire [EXA_MAX_SIZEW-1:0] exa_asize_i; 

      //In UPSIZE/DOWNSIZE configs addr is aligned to asize.
      //Aligned portion of addr is replaced with exa_addr.
      assign exa_addr_i   = {addr[EXA_MAX_ADDRW-1:AXI_MAXSIZE_EXA],exa_addr[AXI_MAXSIZE_EXA-1:0]};
      assign exa_alen_i   = exa_alen;
      assign exa_asize_i  = exa_asize;
      assign exa_acc       = first_bl & (alock[0]==1'b1);
      assign exa_acc_instr = (alock[0]==1'b1);
      assign exa_acc_pyld  = {exa_addr_i, exa_alen_i, exa_asize_i};
      assign exa_acc_lock = 1'b0;
      
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
    
  assert_never #(0, 0, "beat_num_end overflow", CATEGORY) a_beat_num_end_overflow
    (clk, rst_n, (beat_num_end_wider[NBEATS_LG2]==1'b1));
    
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
endmodule // DWC_ddr_umctl2_xpi_rp
