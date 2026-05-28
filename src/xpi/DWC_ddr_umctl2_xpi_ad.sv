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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_ad.sv#1 $
// -------------------------------------------------------------------------
// Description:
//           uMCTL XPI Address Down Size Convertor
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_ad
  (/*AUTOARG*/
   // Outputs
   empty, full, addr_down, alen_down, asize_down, sq_wr, info, next_addr_wrap_autopre_down, next_alen_wrap_autopre_down,
   // Inputs
   clk, rst_n, wr, rd, addr, alen, asize, sq_full, skip, split, reg_ddrc_data_bus_width, ad_in_bypass,next_addr_wrap_autopre, next_alen_wrap_autopre
   );
  
   
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter WR =0;
  
  parameter AXI_DATAW   = 32;                  // AXI data width
  parameter ENIF_DATAW  = 16;                  // Memory data width

  parameter AXI_STRBW   = 4;                   // AXI number bytes
  parameter ENIF_STRBW  = 2;                   // NIF number bytes   

  parameter AXI_MAXSIZE = 2;                   // AXI Maximum size
  parameter ENIF_MAXSIZE= 1;                   // NIF Maximum size

  parameter AXI_SIZEW   = 3;                   // AXI a*size width
  parameter ENIF_SIZEW  = 3;                   // AXI a*size width
   
  parameter AXI_ADDRW   = 32;                  // AXI address width
  parameter AXI_LENW    = 6;                   // AXI a*len width
  parameter ENIF_LENW   = 7;                   // NIF a*len width   
  parameter WRAP_LENW   = 2;                   // WRAP len width
  parameter PDBW_CASE   = 1;                   // Programmable DRAM data width cases - Case1:1 ... Case5:5 

  localparam ENIF_MAXSIZE_HBW = ENIF_MAXSIZE-1;
  localparam ENIF_MAXSIZE_QBW = ENIF_MAXSIZE-2;
  localparam SIZE_RATIOW    = (PDBW_CASE==0) ? 3
                                             : `UMCTL_LOG2(AXI_MAXSIZE-ENIF_MAXSIZE_QBW+1);  

  parameter INFOW       = (WR==1) ? 2 + 2+ 1 +1 
                                  : 3;
  // Address Down state machine encodings
  localparam AD_STATE_WIDTH  = 1;
  localparam IDLE            = 1'b0;  
  localparam WAIT_RD         = 1'b1;  
  localparam FBW           = 2'b00;
  localparam HBW           = 2'b01;
  localparam QBW           = 2'b10;
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------

  input                                clk;          // clock
  input                                rst_n;        // asynchronous reset

  input                                wr;           // write
  input                                rd;           // read 
  input [AXI_ADDRW-1:0]                addr;         // AXI address
  input [AXI_LENW-1:0]                 alen;         // AXI burst length   
  input [AXI_SIZEW-1:0]                asize;        // AXI burst size
  input                                sq_full;      // INFO Queue is full 
  input                                skip;         // second INCR when a WRAP is split into 2 INCRs
  input                                split;        // first INCR when a WRAP is split into 2 INCRs
  input [1:0]                          reg_ddrc_data_bus_width;
  input [AXI_ADDRW-1:0]                next_addr_wrap_autopre; //For AXI auto precharge with wrap burst
  input [AXI_LENW-1:0]                 next_alen_wrap_autopre; //For AXI auto precharge with wrap burst  
  output                               empty;        // empty 
  output                               full;         // full
  output [AXI_ADDRW-1:0]               addr_down;    // AXI address Downsized
  output [ENIF_LENW-1:0]               alen_down;    // AXI burst length Downsized  
  output [ENIF_SIZEW-1:0]              asize_down;   // AXI burst size Downsized
  output                               sq_wr;        // push INFO to size queue 
  output [INFOW-1:0]                   info;         // information sent to the DATA path 
  output [AXI_ADDRW-1:0]               next_addr_wrap_autopre_down; //For AXI auto precharge with wrap burst
  output [ENIF_LENW-1:0]               next_alen_wrap_autopre_down; //For AXI auto precharge with wrap burst  
  output                               ad_in_bypass;
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire [AXI_MAXSIZE-1:0]               addr_offset;  // address offset of the first NIF beat in the AXI beat
  wire [INFOW-1:0]                     info;         // information sent to the DATA downsizer 
  wire [ENIF_LENW-1:0]                 alen_down;    // AXI burst length Downsized
  reg [AXI_ADDRW-1:0]                  addr_down;
  wire [ENIF_LENW-1:0]                 next_alen_wrap_autopre_down; //For AXI auto precharge with wrap burst  
  reg [AXI_ADDRW-1:0]                  next_addr_wrap_autopre_down; //For AXI auto precharge with wrap burst
  wire                                 bypass_en;    // when enabled, AD is in programmable bypass mode
  wire                                 fbw_mode,hbw_mode,qbw_mode;
 
  reg                                  empty;
  reg                                  full;   
  reg                                  sq_wr;
  reg [AD_STATE_WIDTH-1:0]             ad_state_next;
  reg [AD_STATE_WIDTH-1:0]             ad_state_reg; // SNPS_TMR

  reg                                  wrap;
  wire [WRAP_LENW-1:0]                 wrap_len;
  reg                                  wrap_prev; // SNPS_TMR
  wire [SIZE_RATIOW-1:0]                           size_ratio;
  
  generate
  if (WR==1)  begin: ad_wr
    assign info = {wrap_len,wrap,addr_offset,asize};        
  end 
  else  begin: ad_rd
 //spyglass disable_block W164a
 //SMD: 'info' width 2 is less than RHS: 'asize' width 3 in assignment
 //SJ: Width mismatch happens as UPSIZE and DOWNSIZE can co-exist as part of bug 7175. Need to review this.
    assign info = asize;
 //spyglass enable_block W164a
  end 
  endgenerate

  assign hbw_mode = (reg_ddrc_data_bus_width==HBW) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW) ? 1'b1: 1'b0;

   assign bypass_en = ((PDBW_CASE==2) & (hbw_mode|fbw_mode)) ||
                      ((PDBW_CASE==1) & fbw_mode) ;

   assign ad_in_bypass = bypass_en;

  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block
  assign addr_offset = addr_down[AXI_MAXSIZE-1:0];
  assign wrap_len = alen_down[WRAP_LENW-1:0];  
  //spyglass enable_block W528
  
  // The downsized size is the NIF size if AXI size is greater or equal to NIF size,
  // else keep the original AXI size
 
  generate
      if(PDBW_CASE==0 ) begin : asize_fixed
          assign asize_down = (asize<ENIF_MAXSIZE) ? asize[ENIF_SIZEW-1:0]:ENIF_MAXSIZE;
          assign size_ratio = (asize>=ENIF_MAXSIZE) ? (asize-ENIF_MAXSIZE):{SIZE_RATIOW{1'b0}};
      end else begin  : asize_prg
          assign asize_down = ( bypass_en | 
                                (fbw_mode & (asize<ENIF_MAXSIZE)) |
                                (hbw_mode & (asize<ENIF_MAXSIZE_HBW))| 
                                (qbw_mode & (asize<ENIF_MAXSIZE_QBW))  ) ? asize[ENIF_SIZEW-1:0] 
                                                                         : hbw_mode ? ENIF_MAXSIZE_HBW 
                                                                         : qbw_mode ? ENIF_MAXSIZE_QBW 
                                                                         : ENIF_MAXSIZE; //FBW
        
          assign size_ratio = ( bypass_en | 
                                (fbw_mode & (asize<ENIF_MAXSIZE)) |
                                (hbw_mode & (asize<ENIF_MAXSIZE_HBW))| 
                                (qbw_mode & (asize<ENIF_MAXSIZE_QBW))  ) ? {SIZE_RATIOW{1'b0}} 
                                                                         : hbw_mode ? asize-ENIF_MAXSIZE_HBW
                                                                         : qbw_mode ? asize-ENIF_MAXSIZE_QBW
                                                                         : asize-ENIF_MAXSIZE ; //FBW
                
      end
  endgenerate  
  
  assign alen_down = ((alen+1) << size_ratio)-1;
  assign next_alen_wrap_autopre_down = ((next_alen_wrap_autopre+1) << size_ratio)-1;
  

  //spyglass disable_block W415a
  //SMD: Signal wrap/beat_wrap_len is being assigned multiple times in same always block. 
  //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
  always @(*) begin: detect_wrap_len
    integer i;
    reg [AXI_STRBW-1:0]  beat_wrap_len;
    reg [AXI_SIZEW-1:0]  ratio;
    wrap = 1'b0;
    beat_wrap_len = {{(AXI_STRBW-1){1'b0}},1'b1};

    ratio = AXI_MAXSIZE-asize;
    
    for (i=2; i<=AXI_MAXSIZE;i=i+1) begin 
      if (i==ratio && ({{(`UMCTL2_PORT_NBYTES_MAX+1-AXI_LENW){1'b0}},alen} < {{(`UMCTL2_PORT_NBYTES_MAX+1-AXI_STRBW){1'b0}},beat_wrap_len}))
        wrap = split;
      beat_wrap_len = {beat_wrap_len[AXI_STRBW-2:0],{1'b1}};
    end
  end
  //spyglass enable_block W415a
  
  always @(*) begin: conv_addr_down
    integer i;
    for (i=0; i<AXI_ADDRW;i=i+1) begin
       if (i<asize && (bypass_en==1'b0)) begin
         addr_down[i]= 1'b0;
         next_addr_wrap_autopre_down[i] = 1'b0;
       end 
       else begin
         addr_down[i]= addr[i];
         next_addr_wrap_autopre_down[i] = next_addr_wrap_autopre[i];
       end
    end
  end
   
  always @ (posedge clk or negedge rst_n) begin
     if (rst_n == 1'b0) begin
        ad_state_reg <= IDLE;
        wrap_prev <= 1'b0;
     end
     else  begin
        ad_state_reg <= ad_state_next;
        if (wr&rd)
          wrap_prev <= wrap;
     end
  end

  always @(*) begin
     ad_state_next = ad_state_reg;
     empty = 1'b1;
     sq_wr = 1'b0;
     full = sq_full;
     case (ad_state_reg)
       IDLE: begin
          if ((~sq_full|(skip&~wrap_prev))&wr) begin
             empty =1'b0;
             sq_wr = ~(skip&~wrap_prev);
             if (~rd) begin 
               ad_state_next = WAIT_RD;
             end
          end
       end
       default: begin //WAIT_RD
          full = 1'b1;
          empty =1'b0;    
          if (rd) begin
            ad_state_next = IDLE;
          end
       end
  
      endcase // case(packet_state_reg)
   end // always @ (*)
  
   
endmodule // DWC_ddr_umctl2_xpi_ad
