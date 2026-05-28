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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_wdd.sv#1 $
// -------------------------------------------------------------------------
// Description:
//            uMCTL XPI Data Downsize Converter                             *
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_wdd
  (/*AUTOARG*/
   // Outputs
   sq_rd, data_down, wstrb_down, parity_down, par_err_down, wlast_down, empty, full, 
   // Inputs
   clk, rst_n, wr, rd, data, wstrb, parity, par_err,reg_ddrc_data_bus_width, wlast, sq_empty, info
   );
  
   
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter IN_DATAW         = 32;
  parameter IN_STRBW         = 4;
  parameter AXI_MAXSIZE       = 2;
  parameter AXI_SIZEW         = 4;
  parameter PDBW_CASE         = 1; //Case1:1 ... Case5:5 
  parameter ENIF_DATAW        = 16;
  parameter ENIF_STRBW        = 2;
  parameter ENIF_MAXSIZE      = 1;
  parameter ENIF_SIZEW        = 2;
  parameter WRAP_LENW         = 2;          // WRAP len width

  parameter INFOW       = 2 +               // size_ratio
                          2 +               // addr_offset
                          1+1;              // asize_down

  localparam ENIF_MAXSIZE_HBW = ENIF_MAXSIZE-1;
  localparam ENIF_MAXSIZE_QBW = ENIF_MAXSIZE-2;
  localparam CONV_RATIO     = IN_DATAW/ENIF_DATAW;
  localparam CONV_RATIO_LG2 = `UMCTL_LOG2(CONV_RATIO);
  localparam CONV_RATIO_LG2_INT = (CONV_RATIO_LG2==0)? 1 : CONV_RATIO_LG2;
  localparam SIZE_RATIOW    = (PDBW_CASE==0) ? `UMCTL_LOG2(AXI_MAXSIZE-ENIF_MAXSIZE+1)
                                             : `UMCTL_LOG2(AXI_MAXSIZE-ENIF_MAXSIZE_QBW+1);   
  localparam MAXSIZE        = (AXI_MAXSIZE>WRAP_LENW) ? WRAP_LENW : AXI_MAXSIZE;
  localparam CONV_RATIO_HBW_LG2 = AXI_MAXSIZE-ENIF_MAXSIZE_HBW;   
  localparam CONV_RATIO_QBW_LG2 = AXI_MAXSIZE-ENIF_MAXSIZE_QBW;   
  localparam DATINDXW   = (PDBW_CASE==0 ) ? CONV_RATIO_LG2 : CONV_RATIO_QBW_LG2;

 
  // Packet state machine encodings
  localparam DD_STATE_WIDTH  = 1;
  localparam IDLE            = 1'b0;  
  localparam UNPACK          = 1'b1;  
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
  input [IN_DATAW-1:0]                data;
  input [IN_STRBW-1:0]                wstrb;
  input [IN_STRBW-1:0]                parity;
  input [IN_STRBW-1:0]                par_err;
  input                                wlast;   
  
  input                                sq_empty;     // size INFO queue empty
  input [INFOW-1:0]                    info;         // information from the DATA path   
  input [1:0]                          reg_ddrc_data_bus_width;
  output                               sq_rd;        // pop size INFO queue    
  
  output [ENIF_DATAW-1:0]              data_down;
  output [ENIF_STRBW-1:0]              wstrb_down;
  output [ENIF_STRBW-1:0]              parity_down;
  output [ENIF_STRBW-1:0]              par_err_down;
  output                               wlast_down;   
  output                               empty;        // empty 
  output                               full;         // full

   
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg                                  full;
  reg                                  empty;
  wire [SIZE_RATIOW-1:0]               size_ratio;   // number of NIF beats to downsize on AXI beat
  wire [AXI_MAXSIZE-1:0]               addr_offset;  // address offset of the first NIF beat in the AXI beat
  wire [AXI_SIZEW-1:0]                 asize;
  reg [AXI_MAXSIZE-1:0]                addr_offset_count_reg; // SNPS_TMR
  reg [AXI_MAXSIZE-1:0]                addr_offset_count_next;
  reg [MAXSIZE-1:0]                    beat_count_reg; // SNPS_TMR
  reg [MAXSIZE-1:0]                    beat_count_next;   
  reg [DD_STATE_WIDTH-1:0]             dd_state_next;
  reg [DD_STATE_WIDTH-1:0]             dd_state_reg; // SNPS_TMR 
  wire [DATINDXW-1:0]                  data_index;
  reg                                  last_index;
  wire                                 wrap;  // special case when a sub-sized WRAP is wrapping into the same beat
  wire [WRAP_LENW-1:0]                 wrap_len;   
  wire                                 wrap_last_index;
  wire [ENIF_SIZEW-1:0]                asize_down;   // AXI burst size Downsized   
  wire [ENIF_DATAW-1:0]                data_a [0:CONV_RATIO-1];
  wire [ENIF_STRBW-1:0]                wstrb_a [0:CONV_RATIO-1];
  wire [ENIF_STRBW-1:0]                parity_a [0:CONV_RATIO-1];
  wire [ENIF_STRBW-1:0]                par_err_a [0:CONV_RATIO-1];
  wire [AXI_MAXSIZE:0]                 size_byte_wider;
  wire [AXI_MAXSIZE-1:0]               size_byte;
  wire                                 bypass_en;    // When enabled, WDD is in programmable bypass mode
  wire                                 fbw_mode,hbw_mode,qbw_mode;
  wire [DATINDXW-1:0]                  data_index_sel_w;
  wire [CONV_RATIO_LG2_INT-1:0]        data_index_sel;


  assign hbw_mode = (reg_ddrc_data_bus_width==HBW) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW) ? 1'b1: 1'b0;

  assign bypass_en = ((PDBW_CASE==2) & (hbw_mode|fbw_mode)) ||
                     ((PDBW_CASE==1) & fbw_mode) ;



  assign size_byte_wider = {{(AXI_MAXSIZE){1'b0}},1'b1} << asize_down;
  assign size_byte = size_byte_wider[AXI_MAXSIZE-1:0];
 //spyglass disable_block W164a
 //SMD: '{wrap_len ,wrap ,addr_offset ,asize}' width 13 is less than RHS: 'info' width 14 in assignment
 //SJ: Width mismatch happens as UPSIZE and DOWNSIZE can co-exist as part of bug 7175. Need to review this.
  assign {wrap_len,wrap,addr_offset,asize} = info;
 //spyglass enable_block W164a

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
                                : asize-ENIF_MAXSIZE_QBW;
                              
                             //     : hbw_mode ? asize-ENIF_MAXSIZE_HBW
                             //               : qbw_mode ? asize-ENIF_MAXSIZE_QBW
                             //                          : asize-ENIF_MAXSIZE ; //FBW
                
      end
  endgenerate
                       
  assign wlast_down = wlast &last_index;

  assign sq_rd = ~sq_empty & (wlast_down|wrap_last_index) & wr&rd;

  generate
      if(PDBW_CASE==0 ) begin : dataindex_fixed
         assign data_index = (dd_state_reg==IDLE) ? addr_offset[ENIF_MAXSIZE+:DATINDXW]:addr_offset_count_reg[ENIF_MAXSIZE+:DATINDXW];
         assign data_index_sel_w = data_index;
      end 
      else begin: dataindex_prg 
          wire [DATINDXW-1:0]     data_index_slice;
          wire [DATINDXW-1:0]     data_index_fbw;
          wire [DATINDXW-1:0]     data_index_qbw;
          wire [DATINDXW-1:0]     data_index_hbw;
          // data_index_sel_w is used to select the segment of data from which data_down is generated
          // data_index is used to generate last_index, it takes into acount the effective width of data_down
          assign data_index_slice = (dd_state_reg==IDLE) ? addr_offset[ENIF_MAXSIZE_QBW+:DATINDXW]:addr_offset_count_reg[ENIF_MAXSIZE_QBW+:DATINDXW];
          if(PDBW_CASE==1) begin :dataindex_prg_Case1
            //FBW is bypass in Case1
            assign data_index_fbw = {DATINDXW{1'b0}};  // bypass
            //In HBW mode since effective data_down width is 2x of QBW, we ignore the LSB bit
            // here padding with 1'b1 is same as ignoring since last_index logic uses anding
            assign data_index_hbw = {data_index_slice[DATINDXW-1 -:CONV_RATIO_HBW_LG2],1'b1};
          end else if (PDBW_CASE ==2) begin : dataindex_prg_Case2
            assign data_index_fbw = {DATINDXW{1'b0}}; //bypass
            assign data_index_hbw = {DATINDXW{1'b0}}; //bypass
          end else begin //Case5
            //In FBW mode since effective data_down width is 4x of QBW, sd we ignore the LSB 2 bits
            // here padding with 1'b1 is same as ignoring since last_index logic uses anding
            assign data_index_fbw = {data_index_slice[DATINDXW-1 -:CONV_RATIO_LG2],2'b11}; 
            assign data_index_hbw = {data_index_slice[DATINDXW-1 -:CONV_RATIO_HBW_LG2],1'b1};
          end
          assign data_index_qbw = data_index_slice;
          assign data_index = qbw_mode ? data_index_qbw:
                              hbw_mode ? data_index_hbw 
                                       : data_index_fbw;
//spyglass disable_block W528
//SMD: Variable 'data_index_sel_w[1:0]' set but not read
//SJ: Not required to be read if CONV_RATIO_LG2=0.
          assign data_index_sel_w = ( data_index_slice >> (DATINDXW-CONV_RATIO_LG2));
//spyglass enable_block W528
      end // dataindex_prg
  endgenerate                      

 //spyglass disable_block SelfDeterminedExpr-ML
 //SMD: Self determined expression '(wrap_len + 1)' found in module 'DWC_ddr_umctl2_xpi_wdd'
 //SJ: This coding style is acceptable and there is no plan to change it.
  assign wrap_last_index = (beat_count_next== wrap_len+1) ? wrap:1'b0;
 //spyglass enable_block SelfDeterminedExpr-ML
   
  genvar gv;
  generate
    for(gv=0;gv<CONV_RATIO;gv=gv+1) begin:CONV_ARRAY 
     assign data_a[gv]     = data[gv*ENIF_DATAW+:ENIF_DATAW];     
     assign wstrb_a[gv]    = wstrb[gv*ENIF_STRBW+:ENIF_STRBW];
     assign parity_a[gv]   = parity[gv*ENIF_STRBW+:ENIF_STRBW];
     assign par_err_a[gv]  = par_err[gv*ENIF_STRBW+:ENIF_STRBW];
    end
  endgenerate

  assign data_index_sel = (CONV_RATIO_LG2==0)? 1'b0 : data_index_sel_w[CONV_RATIO_LG2_INT-1:0];

  assign data_down      = data_a[data_index_sel];
  assign wstrb_down     = wstrb_a[data_index_sel];
  assign parity_down    = parity_a[data_index_sel];
  assign par_err_down   = par_err_a[data_index_sel];

  always @ (posedge clk or negedge rst_n) begin
     if (rst_n == 1'b0) begin
        addr_offset_count_reg  <= {AXI_MAXSIZE{1'b0}};
        beat_count_reg  <= {MAXSIZE{1'b0}};
        dd_state_reg <= IDLE;
     end
     else  begin
        addr_offset_count_reg  <= addr_offset_count_next;
        beat_count_reg  <= beat_count_next;     
        dd_state_reg <= dd_state_next;
     end
  end
   
   
  always @(*) begin
     dd_state_next = dd_state_reg;
     addr_offset_count_next = addr_offset_count_reg;
     beat_count_next = beat_count_reg;
     
     empty = 1'b1;
     full  = 1'b1;
     case (dd_state_reg)
       IDLE: begin
          if (~sq_empty) begin
             addr_offset_count_next = addr_offset;
             beat_count_next = {MAXSIZE{1'b0}};            
             if (~(wlast_down|wrap_last_index))
               dd_state_next = UNPACK;
             if (wr) begin
               empty = 1'b0;
               if (rd) begin
                 beat_count_next = {{(MAXSIZE-1){1'b0}},1'b1};
                 //spyglass disable_block W164a
                 //SMD: LHS: 'addr_offset_count_next' width 6 is less than RHS: '(addr_offset + size_byte)' width 7 in assignment
                 //SJ: Overflow expected. See bug5632, comment #19.
                 addr_offset_count_next = addr_offset+size_byte;
                 //spyglass enable_block W164a
                 if (last_index|wrap_last_index) full  = 1'b0;                
               end
             end
          end
       end
       default: begin //UNPACK
          if (wr) begin
             empty = 1'b0;
             if (rd) begin
               //spyglass disable_block W164a
               //SMD: LHS: 'addr_offset_count_next' width 6 is less than RHS: '(addr_offset_count_reg + size_byte)' width 7 in assignment
               //SJ: Overflow expected. See bug5632, comment #19.
               addr_offset_count_next = addr_offset_count_reg+size_byte;
               //spyglass enable_block W164a
               beat_count_next = beat_count_reg+1;              
               if (last_index|wrap_last_index) full  = 1'b0;
               if (wlast_down|wrap_last_index) dd_state_next = IDLE;
             end
          end
       end
 
      endcase // case(packet_state_reg)
   end // always @ (*)


generate
  
  if(PDBW_CASE==0 ) begin : CONV_GT1
      //spyglass disable_block W415a
      //SMD: Signal last_index is being assigned multiple times in same always block. 
      //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
      //spyglass disable_block SelfDeterminedExpr-ML
      //SMD: Self determined expression '(i - 1)' found in module 'DWC_ddr_umctl2_xpi_wdd'
      //SJ: This coding style is acceptable and there is no plan to change it.
      // HRE: Modify for Case1 and Case2. Can remain same for Case0(uMCTL2) and Case5
      always @(*) begin:last_index_PROC
        integer i;
        integer j;
        last_index = ((size_ratio==0) || bypass_en)?1'b1:1'b0;
        for (i=1 ; i<=DATINDXW ; i=i+1) begin
          if (size_ratio == $unsigned(i)) begin 
            last_index = 1'b1;
            for (j=0 ; j<=CONV_RATIO_LG2-1 ; j=j+1)
              if (j <= i - 1) begin 
                last_index =last_index&data_index[j];
              end
          end
        end
      end // always @ (*)    
  end // CONV_GT1
  else begin : CONV_EQ1
      always @(*) begin:last_index_PROC
        integer i;
        integer j;
        last_index = ((size_ratio==0) || bypass_en)?1'b1:1'b0;
        for (i=1 ; i<=DATINDXW ; i=i+1) begin
          if (size_ratio == $unsigned(i)) begin 
            last_index = 1'b1;
            for (j=0 ; j<=DATINDXW-1 ; j=j+1)
              if (j <= i - 1) begin 
                last_index =last_index&data_index[j];
              end
          end
        end
      end // always @ (*)  
  end //CONV_EQ1
  //spyglass enable_block SelfDeterminedExpr-ML
  //spyglass enable_block W415a
endgenerate

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  
  `assert_x_value(ERROR_XPI_WDD_INFO_SIGNAL_VALUE_X,wr,info);
    
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule // DWC_ddr_umctl2_xpi_wdd
