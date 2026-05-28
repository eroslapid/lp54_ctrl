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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_ws.sv#1 $
// -------------------------------------------------------------------------
// Description:
//          uMCTL XPI wrap split module. Splits AXI WRAP bursts into two INCR bursts
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_ws
#(
   //-------------------------------------------------------------------.--------
   // Parameters
   //---------------------------------------------------------------------------
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
   input [1:0]                         reg_ddrc_data_bus_width,  // DRAM Data bus width mode
 
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
   input                               autopre,       // AXI auto precharge
   
   output                              full,          // AXI address ready
   
   output [AXI_ADDRW-1:0]              ws_addr,       // AXI first INCR burst address
   output [AXI_LENW-1:0]               ws_alen,        // AXI first INCR burst length
   output [AXI_IDW-1:0]                ws_id,
   output [AXI_USERW-1:0]              ws_user,
   output [AXI_QOSW-1:0]               ws_qos,
   output                              ws_poison,
   output                              ws_ocpar_err,
   output [ORDER_TOKENW-1:0]           ws_token,   
   output                              ws_autopre,
   output [AXI_SIZEW-1:0]              ws_asize,
   output [AXI_LOCKW-1:0]              ws_lock,       // Lock
   output                              split,         // Single burst
   output                              skip,          // extra INCR burst
   output                              hold_first_beat, // first and last AXI beats are both in the first HIF beat (only for short_wrap in case of UP_SIZE)   
   output                              short_burst,
   output [AXI_ADDRW-1:0]              ws_next_addr_wrap_autopre, // Wrapping boundary address for autopre
   output [AXI_LENW-1:0]               ws_next_alen_wrap_autopre, // Length for autopre with wrap burst
  
   output                              empty,         // ENIF address valid
   input                               rd            // ENIF address ready
);

  //---------------------------------------------------------------------------
  // Local Parameters 
  //---------------------------------------------------------------------------
   
   localparam ADDR_MASKW   = 13;
   // Wrap state machine encodings
   localparam WRAP_STATE_WIDTH  = 1;
   localparam IDLE                = 1'b0;  
   localparam SPLIT               = 1'b1;  
   localparam ONE_AXI_LENW = {{(AXI_LENW-1){1'b0}},1'b1};
   localparam AXI_LEN_BYTEW = AXI_LENW+1+AXI_MAXSIZE;
   localparam M_NB_LG2      = `UMCTL_LOG2(M_DW/8);
   localparam A_NB_LG2      = M_NB_LG2+NAB;    
   localparam FBW           = 2'b00;
   localparam HBW           = 2'b01;
   localparam QBW           = 2'b10;
  // If the M_DW is such that HBW cannot be supported then use FBW setting 
   localparam M_NB_HBW_LG2  = (M_NB_LG2>=1) ? M_NB_LG2-1 : M_NB_LG2;
  // If the M_DW is such that QBW cannot be supported then use HBW setting 
   localparam M_NB_QBW_LG2  = (M_NB_LG2>=2) ? M_NB_LG2-2 : M_NB_HBW_LG2;

// Effective HIF Bus withds in HBW/QBW mode when PDBW mode
   localparam A_NB_HBW_LG2      = ( (M_NB_HBW_LG2+NAB) > AXI_MAXSIZE) ?  M_NB_HBW_LG2+NAB : M_NB_LG2+NAB;   
   localparam A_NB_QBW_LG2      = ( (M_NB_QBW_LG2+NAB) > AXI_MAXSIZE) ?  M_NB_QBW_LG2+NAB : A_NB_HBW_LG2;   
   
   //---------------------------------------------------------------------------
   // Internal Signals
   //---------------------------------------------------------------------------
   reg [AXI_LENW-1:0]                  beat_addr;
   
   reg [ADDR_MASKW-1:0]                addr2_mask;
   reg [AXI_ADDRW-1:0]                 addr2;
   reg [AXI_LENW-1:0]                  alen2;
   wire [AXI_LENW-1:0]                 alen1;
   wire                                aligned;
   wire                                short_burst_en;
  

   reg [WRAP_STATE_WIDTH-1:0]          wrap_state_next;
   reg [WRAP_STATE_WIDTH-1:0]          wrap_state_reg;
   wire                                second_burst;

   reg [AXI_LENW-1:0]                  alen1_l;
   reg [AXI_IDW-1:0]                   id_reg;
   reg [AXI_USERW-1:0]                 user_reg;
   reg [AXI_QOSW-1:0]                  qos_reg;
   reg                                 poison_reg;
   reg                                 ocpar_err_reg;
   reg [ORDER_TOKENW-1:0]              token_reg;
   reg [AXI_SIZEW-1:0]                 asize_reg;
   reg [AXI_LOCKW-1:0]                 alock_reg;
   reg                                 autopre_reg;
      
   wire                                sub_sized;
   reg [XPI_BRW-1:0]                   reg_burst_rdwr_reg;
   wire [AXI_LENW:0]                   len_p1;
   wire [AXI_LEN_BYTEW-1:0]            len_p1_byte;
   wire [XPI_BRW+M_NB_LG2+1-1:0]       mem_bl_byte;   

   wire                                ddrc_bl4, ddrc_bl8, ddrc_bl16;
   wire                                full_bytes, half_bytes, quarter_bytes;   
   wire                                fbw_mode,hbw_mode,qbw_mode;
   wire                                up_size_act;


//---------------------------------------------------------------------------
// Main Module
//---------------------------------------------------------------------------

 //spyglass disable_block W528
    //SMD: Variable set but not read
    //SJ: Used in different generate blocks 
  assign hbw_mode = (reg_ddrc_data_bus_width==HBW) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW) ? 1'b1: 1'b0;

 //Upsizers are active
  assign up_size_act = PDBW_CASE==0 ? (UP_SIZE==1) :
                       PDBW_CASE==2 ? fbw_mode     :
                       PDBW_CASE==3 ? (fbw_mode|hbw_mode) :
                       PDBW_CASE==4 ? 1'b1 
                                    : 1'b0; //case 5
//spyglass enable_block W528  

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in different generate blocks and/or RTL assertions.
   assign ddrc_bl4   = reg_burst_rdwr_reg==2;
   assign ddrc_bl8   = reg_burst_rdwr_reg==4;
   assign ddrc_bl16  = reg_burst_rdwr_reg==8;
   assign full_bytes    = {{(`UMCTL2_PORT_NBYTES_MAX+1-(XPI_BRW+M_NB_LG2+1)){1'b0}},mem_bl_byte} == {{(`UMCTL2_PORT_NBYTES_MAX+1-AXI_LEN_BYTEW){1'b0}},len_p1_byte}; //mem_bl_byte==len_p1_byte;
   assign half_bytes    = {{(`UMCTL2_PORT_NBYTES_MAX+1-(XPI_BRW+M_NB_LG2+1)+1){1'b0}},mem_bl_byte[XPI_BRW+M_NB_LG2:1]} == {{(`UMCTL2_PORT_NBYTES_MAX+1-AXI_LEN_BYTEW){1'b0}},len_p1_byte};//(mem_bl_byte>>1)== len_p1_byte;
   assign quarter_bytes = {{(`UMCTL2_PORT_NBYTES_MAX+1-(XPI_BRW+M_NB_LG2+1)+2){1'b0}},mem_bl_byte[XPI_BRW+M_NB_LG2:2]} == {{(`UMCTL2_PORT_NBYTES_MAX+1-AXI_LEN_BYTEW){1'b0}},len_p1_byte};//(mem_bl_byte>>2)== len_p1_byte;
//spyglass enable_block W528
   
  assign len_p1 = {1'b0,alen}+{1'b0,ONE_AXI_LENW};
  //spyglass disable_block W164b
  //SMD: LHS: 'len_p1_byte' width 10 is greater than RHS: '(len_p1 << $unsigned(AXI_MAXSIZE))' width 9 in assignment / LHS: 'mem_bl_byte' width 8 is greater than RHS: '(reg_burst_rdwr_reg << (M_NB_LG2 + 1))' width 4 in assignment
  //SJ: Final width of RHS depends on value of len_p1 and reg_burst_rdwr_reg. Previously waived in Leda with LJ: len_p1 shorter than len_p1_byte, reg_burst_rdwr_reg shorter than mem_bl_byte
  assign len_p1_byte = len_p1 << AXI_MAXSIZE;

  assign mem_bl_byte = (PDBW_CASE==0 ) ? reg_burst_rdwr_reg << (M_NB_LG2+1)
                                       : hbw_mode ?  reg_burst_rdwr_reg << (M_NB_HBW_LG2+1) :
                                         qbw_mode ? reg_burst_rdwr_reg << (M_NB_QBW_LG2+1)
                                                  : reg_burst_rdwr_reg << (M_NB_LG2+1);                                   
  //spyglass enable_block W164b
  
  generate        
    if (MEMC_BURST_LENGTH==16) begin: bl16
      if (WR==0) begin
         assign                        short_burst_en = (full_bytes & ddrc_bl16) | // full burst
                                                        (full_bytes & ddrc_bl8) | (half_bytes & ddrc_bl16) | // half burst
                                                        (full_bytes & ddrc_bl4) | (half_bytes & ddrc_bl8) | (quarter_bytes & ddrc_bl16) | // quarter
                                                        (half_bytes & ddrc_bl4) | (quarter_bytes & ddrc_bl8) | // eighth
                                                        (quarter_bytes & ddrc_bl4); // sixteenth
                                                        

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

   // full burst
   wire bl16_full = (full_bytes & ddrc_bl16);

   cp_xpi_rd_esw_mbl16_bl16_full :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl16_full & short_burst
    );

   
   cp_xpi_rd_esw_full :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl16_full & short_burst
    );

   // half burst
   wire bl16_half = (half_bytes & ddrc_bl16);
   wire bl8_full = (full_bytes & ddrc_bl8);

    cp_xpi_rd_esw_mbl16_bl16_half :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl16_half & short_burst
    );

    cp_xpi_rd_esw_mbl16_bl8_full :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl8_full & short_burst
    );

   cp_xpi_rd_esw_half :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        (bl16_half | bl8_full) & short_burst
    );

   // quarter burst
   wire bl16_quarter = (quarter_bytes & ddrc_bl16);
   wire bl8_half = (half_bytes & ddrc_bl8);
   wire bl4_full =  (full_bytes & ddrc_bl4);

    cp_xpi_rd_esw_quarter :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        ((bl16_quarter | bl8_half | bl4_full) & awrap) |-> short_burst
    );

    // eighth burst
   wire bl4_half = (half_bytes & ddrc_bl4);
   wire bl8_quarter = (quarter_bytes & ddrc_bl8);


    cp_xpi_rd_esw_eighth :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        ((bl4_half | bl8_quarter) & awrap) |-> short_burst
    );

    // sixteenth burst

    wire bl4_quarter = (quarter_bytes & ddrc_bl4);

    cp_xpi_rd_esw_sixteenth :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        (bl4_quarter & awrap) |-> short_burst
    );


`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
      end
      else begin
         assign                        short_burst_en = full_bytes & ddrc_bl16; // full burst only
      end
    end
    if (MEMC_BURST_LENGTH==8 && WR==1)  begin: bl8_wr
      assign                           short_burst_en = full_bytes & ddrc_bl8;
    end 
    if (MEMC_BURST_LENGTH==8 && WR==0)  begin: bl8_rd
      assign                           short_burst_en =  (full_bytes & ddrc_bl8) | (full_bytes & ddrc_bl4) | 
                                                         (half_bytes & ddrc_bl8);

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

   // full burst
   wire bl8_full = (full_bytes & ddrc_bl8);

   cp_xpi_rd_esw_mbl8_bl8_full :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl8_full & short_burst
    );

   
   cp_xpi_rd_esw_full :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl8_full & short_burst
    );

    // half burst
   wire bl8_half = (half_bytes & ddrc_bl8);
   wire bl4_full = (full_bytes & ddrc_bl4);

    cp_xpi_rd_esw_mbl8_bl8_half :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl8_half & short_burst
    );

    cp_xpi_rd_esw_mbl8_bl4_full :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        bl4_full & short_burst
    );

    cp_xpi_rd_esw_half :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        (bl8_half | bl4_full) & short_burst
    );

    // quarter burst

      wire bl4_half = (half_bytes & ddrc_bl4);
      wire bl8_quarter = (quarter_bytes & ddrc_bl8);

    cp_xpi_rd_esw_quarter :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        ((bl4_half | bl8_quarter) & awrap) |-> short_burst
    );


    // eighth burst

      wire bl4_quarter = (quarter_bytes & ddrc_bl4);

    cp_xpi_rd_esw_eighth :
    cover property (
        @(posedge clk) disable iff(!rst_n)
        (bl4_quarter & awrap) |-> short_burst
    );


`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
    end
    if ( MEMC_BURST_LENGTH==4)  begin: bl4
      assign                           short_burst_en = full_bytes & ddrc_bl4;
    end
  endgenerate

  wire hard_cfg_enable, soft_cfg_disable;
  wire aligned_up_size;
  wire aligned_address;

   generate
      if (UP_SIZE==1) begin: up_size
        if(PDBW_CASE==0) begin : no_PDBW
          assign  aligned_address       = ~(|addr[A_NB_LG2-1:AXI_MAXSIZE]);
          assign  hold_first_beat    = up_size_act & short_burst& (|addr[A_NB_LG2-1:AXI_MAXSIZE]);
        end else  begin : has_PDBW
          assign  aligned_address    = ~(| ( hbw_mode ? addr[A_NB_HBW_LG2-1:AXI_MAXSIZE] :
                                             qbw_mode ? addr[A_NB_QBW_LG2-1:AXI_MAXSIZE]  
                                                      : addr[A_NB_LG2-1:AXI_MAXSIZE]
                                            )  
                                        );
          assign  hold_first_beat    = up_size_act & short_burst &
                                            (| ( hbw_mode ? addr[A_NB_HBW_LG2-1:AXI_MAXSIZE] :
                                                  qbw_mode ? addr[A_NB_QBW_LG2-1:AXI_MAXSIZE]  
                                                           : addr[A_NB_LG2-1:AXI_MAXSIZE]
                                                 )  
                                             );
        end
         assign  aligned_up_size    = (WR==1 && up_size_act==1'b1) ? aligned_address:1'b1;
         if (NAB==3) begin : NAB3
           assign  soft_cfg_disable   = ((quarter_bytes & ddrc_bl8) | (half_bytes & ddrc_bl4) | (quarter_bytes & ddrc_bl4) | (half_bytes & ddrc_bl8) | (quarter_bytes & ddrc_bl16)) & ~aligned_address;
         end else begin : NAB1_2
           assign  soft_cfg_disable   = ((quarter_bytes & ddrc_bl8) | (half_bytes & ddrc_bl4) | (quarter_bytes & ddrc_bl4)) & ~aligned_address;
         end
      end
      else  begin: up_size_n
         assign  aligned_up_size    = 1'b1;
         assign  hold_first_beat    = 1'b0;
         assign  soft_cfg_disable   = 1'b0;
      end
   endgenerate
   
  
  assign                              hard_cfg_enable = 1'b1;
       
  assign                              short_burst =  hard_cfg_enable & ~soft_cfg_disable & aligned_up_size & awrap & short_burst_en & ~second_burst & ~sub_sized;
   
  assign                              sub_sized = (asize==$unsigned(AXI_MAXSIZE)) ? 1'b0:1'b1;
  
  assign                              full  = ~rd | second_burst;   
  assign                              empty = ~wr & ~second_burst;

  assign                              second_burst= ( wrap_state_reg == IDLE) ? 1'b0: 1'b1;
  assign                              skip = second_burst;
  
  assign                              aligned= (beat_addr == {(AXI_LENW){1'b0}}) ? 1'b1 : 1'b0;
  assign                              split = awrap & ~short_burst & ~aligned & ~second_burst;   
  assign                              alen1= awrap & ~short_burst & ~aligned ? alen1_l : alen;
  
  assign                              ws_addr      = second_burst ? addr2 : addr;
  assign                              ws_alen      = second_burst ? alen2 : alen1;
  assign                              ws_asize     = second_burst ? asize_reg : asize;
  assign                              ws_id        = second_burst ? id_reg : id;
  assign                              ws_user      = second_burst ? user_reg : user;
  assign                              ws_poison    = second_burst ? poison_reg : poison;
  assign                              ws_ocpar_err = second_burst ? ocpar_err_reg : ocpar_err;
  assign                              ws_qos       = second_burst ? qos_reg : qos;
  assign                              ws_lock      = second_burst ? alock_reg: alock;
  assign                              ws_token     = second_burst ? token_reg : token;
  assign                              ws_autopre   = second_burst ? autopre_reg : autopre;

  assign                              ws_next_addr_wrap_autopre = {addr[AXI_ADDRW-1:ADDR_MASKW],addr[ADDR_MASKW-1:0]&addr2_mask};
  assign                              ws_next_alen_wrap_autopre = beat_addr-1;
  
  always @(*) begin
    wrap_state_next = wrap_state_reg;
    case (wrap_state_reg)
      IDLE: begin
        if (wr & split & rd ) begin
          wrap_state_next = SPLIT;
        end
      end
      default: begin
        if (rd ) begin
          wrap_state_next = IDLE;
        end
      end
    endcase // case(wrap_state_reg)
  end // always @ (*)
  
  always @ (posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      addr2                <= {AXI_ADDRW{1'b0}};
      alen2                <= {(AXI_LENW){1'b0}};
      id_reg               <= {(AXI_IDW){1'b0}};
      user_reg             <= {(AXI_USERW){1'b0}};
      qos_reg              <= {(AXI_QOSW){1'b0}};
      poison_reg           <= 1'b0;
      ocpar_err_reg        <= 1'b0;
      token_reg            <= {(ORDER_TOKENW){1'b0}};
      autopre_reg          <= 1'b0;
      asize_reg            <= {(AXI_SIZEW){1'b0}}; 
      alock_reg            <= {(AXI_LOCKW){1'b0}}; 
      wrap_state_reg       <= IDLE; 
      reg_burst_rdwr_reg   <= {(XPI_BRW){1'b0}}; 
      
    end
    else  begin
      if (~second_burst) begin
        addr2        <= {addr[AXI_ADDRW-1:ADDR_MASKW],addr[ADDR_MASKW-1:0]&addr2_mask};
        alen2        <= beat_addr-1;
        id_reg       <= id;
        user_reg     <= user;
        poison_reg   <= poison;
        ocpar_err_reg<= ocpar_err;
        token_reg    <= token;
        autopre_reg  <= autopre;
        qos_reg      <= qos;
        asize_reg    <= asize; 
        alock_reg    <= alock;
      end
      wrap_state_reg       <= wrap_state_next;
      reg_burst_rdwr_reg   <= reg_burst_rdwr;       
    end // else: !if(rst_n == 1'b0)
  end // always @ (posedge clk or negedge rst_n)

//spyglass disable_block W415a
//SMD: Signal addr2_mask/addr_size/beat_addr/alen1_l is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((1'b1 << (i + 1)) - 1)' found in module 'DWC_ddr_umctl2_xpi_ws'
//SJ: This coding style is acceptable and there is no plan to change it.
  always @(*) begin : addr_mask_PROC
    integer i;
    integer j;
    addr2_mask = {{(ADDR_MASKW-1){1'b1}},{1'b0}};
    for (j=1; j<= AXI_MAXSIZE ;j=j+1)
      if (asize==j)
        addr2_mask = addr2_mask<<j;
    for (i=1 ; i <= AXI_LENW ; i=i+1) 
      if (alen==(1'b1<<(i+1))-1)
        addr2_mask=addr2_mask<<i;
  end
//spyglass enable_block SelfDeterminedExpr-ML

  always @(*) begin : beat_addr_PROC
    integer i;
    integer j;
    reg [AXI_LENW-1:0] addr_size;
    beat_addr = {AXI_LENW{1'b0}};
    alen1_l =  {AXI_LENW{1'b0}};
    addr_size = addr[AXI_LENW-1:0]; 
    for (j=1; j<= AXI_MAXSIZE ;j=j+1)
      if (asize==j)  
        addr_size = addr[j+:AXI_LENW];
    for (i=0 ; i < AXI_LENW ; i=i+1)
      if (alen[i]==1'b1) begin 
        beat_addr[i]=addr_size[i];
        alen1_l[i]=~addr_size[i]; 
      end
  end
//spyglass enable_block W415a    
endmodule // DWC_ddr_umctl2_xpi_ws
