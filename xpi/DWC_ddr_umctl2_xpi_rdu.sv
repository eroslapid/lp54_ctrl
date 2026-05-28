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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_rdu.sv#1 $
// -------------------------------------------------------------------------
// Description:
//          uMCTL XPI Data Upsize Converter
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_rdu
  (/*AUTOARG*/
  // Outputs
  data_up, parity_up, last_up, empty, full, rerror_up, rexa_acc_instr_up, rpoison_up, ocpar_err_up,
  // Inputs
  clk, rst_n, rst_dly, wr, rd, data, parity, parity_type, last,last_pkt, reg_ddrc_data_bus_width, info, rerror, rexa_acc_instr, rpoison, ocpar_err
  );
  
   
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter AXI_DATAW         = 32;
  parameter AXI_STRBW         = 4;
  parameter AXI_MAXSIZE       = 2;
  parameter AXI_SIZEW         = 2;
  parameter PDBW_CASE         = 0; //Programmabe Data bus width Case
  
  parameter M_DW              = 8;
  parameter ENIF_DATAW        = 16;
  parameter ENIF_STRBW        = 2;
  parameter ENIF_MAXSIZE      = 1;
  parameter ENIF_SIZEW        = 2;
  parameter INFOW       = 2 +               // size_ratio
                          2 +               // addr_offset
                          1+1;              // asize_down
  localparam ENIF_DATAW_HBW  = (M_DW>8) ? ENIF_DATAW/2 : ENIF_DATAW; 
  localparam ENIF_DATAW_QBW  = (M_DW>16) ? ENIF_DATAW/4 : ENIF_DATAW_HBW;  
  localparam ENIF_STRBW_HBW  = (M_DW>8) ? ENIF_STRBW/2 : ENIF_STRBW;                      
  localparam ENIF_STRBW_QBW  = (M_DW>16) ? ENIF_STRBW/4 : ENIF_STRBW_HBW;                        
  // In case2 AXI_DW is < ENIF_DW. RDU is needed only in QBW. ENIF_DATW > data_up 
  // (PDBW_CASE==2) condition is needed to avoid "out of declared bounds" errors
   localparam ENIF_DATAW_FBW  = (PDBW_CASE==2)  ? ENIF_DATAW_HBW : ENIF_DATAW; 
   localparam ENIF_STRBW_FBW  = (PDBW_CASE==2)  ? ENIF_STRBW_HBW : ENIF_STRBW;                      
  localparam integer CONV_RATIO = (PDBW_CASE==0) ? AXI_DATAW/ENIF_DATAW :  AXI_DATAW/ENIF_DATAW_QBW;
  // In case2 AXI_DW is < ENIF_DW. RDU is needed only in QBW. ENIF_DATW > data_up. 
  // (PDBW_CASE==2) condition is needed to avoid "out of declared bounds" errors.
  localparam integer CONV_RATIO_FBW = (PDBW_CASE==2)  ? AXI_DATAW/ENIF_DATAW_HBW  : AXI_DATAW/ENIF_DATAW;
  localparam integer CONV_RATIO_HBW = AXI_DATAW/ENIF_DATAW_HBW;
  localparam DATAW = (PDBW_CASE==0) ? ENIF_DATAW :  ENIF_DATAW_QBW;  
  localparam PARW =  (PDBW_CASE==0) ? ENIF_STRBW :  ENIF_STRBW_QBW;
  localparam CONV_RATIO_LG2 = `UMCTL_LOG2(CONV_RATIO);      
  localparam CONV_RATIO_FBW_LG2 = `UMCTL_LOG2(CONV_RATIO_FBW);      
  localparam CONV_RATIO_HBW_LG2 = `UMCTL_LOG2(CONV_RATIO_HBW);      

  // Packet state machine encodings
  localparam DU_STATE_WIDTH  = 1;
  localparam IDLE            = 1'b0;  
  localparam UNPACK          = 1'b1;  
   
  localparam ENIF_MAXSIZE_HBW = (M_DW>8) ? ENIF_MAXSIZE-1 : ENIF_MAXSIZE;
  localparam ENIF_MAXSIZE_QBW = (M_DW>16)? ENIF_MAXSIZE-2 : ENIF_MAXSIZE_HBW;
  localparam SIZE_RATIOW    = (PDBW_CASE==0) ? `UMCTL_LOG2(AXI_MAXSIZE-ENIF_MAXSIZE+1)
                                             : `UMCTL_LOG2(AXI_MAXSIZE-ENIF_MAXSIZE_QBW+1);   
 
  localparam DATINDXW       =  CONV_RATIO_LG2 ;
  //Avoid width becoming [-1:0] in Case2
  localparam DATINDXW_FBW   =  (PDBW_CASE==2) ? 1 : CONV_RATIO_FBW_LG2 ;
  localparam DATINDXW_HBW   =  (PDBW_CASE==2) ? 1 : CONV_RATIO_HBW_LG2 ;
    
  localparam FBW           = 2'b00;
  localparam HBW           = 2'b01;
  localparam QBW           = 2'b10;
  localparam MAXRATIO      = (PDBW_CASE==5) ? 4 : CONV_RATIO;
  localparam MAXRATIO_HBW  = (PDBW_CASE==5 || PDBW_CASE==1) ? 2 : CONV_RATIO;
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------

  input                                clk;          // clock
  input                                rst_n;        // asynchronous reset
  input                                rst_dly;
  input                                wr;           // write
  input                                rd;           // read 
  input [ENIF_DATAW-1:0]               data;
  input [ENIF_STRBW-1:0]               parity;
  input                                parity_type;
  input                                last;   
  input                                last_pkt;   
  input [1:0]                          reg_ddrc_data_bus_width;
   
  input [INFOW-1:0]                    info;         // information from the DATA path   
  input                                rerror;
  input                                rexa_acc_instr;
  input                                rpoison;
  input                                ocpar_err;
 
  output [AXI_DATAW-1:0]               data_up;
  output [AXI_STRBW-1:0]               parity_up;
  output                               last_up;   
  output                               empty;        // empty 
  output                               full;         // full
  output                               rerror_up;
  output                               rexa_acc_instr_up;
  output                               rpoison_up;
  output                               ocpar_err_up;
  
   
   
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire                                 full;
  wire                                 empty;
 // reg [DATAW-1:0]                      data_up_next_a [0:CONV_RATIO-1];
 // reg [DATAW-1:0]                      data_up_reg_a [0:CONV_RATIO-1];
  logic [AXI_DATAW-1:0]                data_up_next;
  logic [AXI_DATAW-1:0]                data_up_reg;

  //reg [PARW-1:0]                       parity_up_next_a [0:CONV_RATIO-1];
  //reg [PARW-1:0]                       parity_up_reg_a [0:CONV_RATIO-1];
  logic [AXI_STRBW-1:0]                 parity_up_next;
  logic [AXI_STRBW-1:0]                 parity_up_reg;

  wire                                 last_up;      
  wire [SIZE_RATIOW-1:0]               size_ratio;   // number of NIF beats to downsize on AXI beat
  wire [AXI_MAXSIZE-1:0]               addr_offset;  // address offset of the first NIF beat in the AXI beat
  wire [AXI_SIZEW-1:0]                 asize;
  reg [AXI_MAXSIZE-1:0]                addr_offset_count_reg;
  reg [AXI_MAXSIZE-1:0]                addr_offset_count_next;
  reg [DU_STATE_WIDTH-1:0]             du_state_next;
  reg [DU_STATE_WIDTH-1:0]             du_state_reg;  
  wire [DATINDXW-1:0]                  data_index;
  wire [CONV_RATIO_FBW_LG2-1:0]        data_index_fbw;
  wire [CONV_RATIO_HBW_LG2-1:0]        data_index_hbw;
  wire [DATINDXW-1:0]                  data_index_sel;
  reg                                  last_index;
  wire [ENIF_SIZEW-1:0]                asize_down;   // AXI burst size Downsized 
  reg                                  rerror_reg;
  wire                                 rerror_next;
  wire                                 split;
  wire [AXI_MAXSIZE-1:0]               size_byte;
  wire [AXI_MAXSIZE:0]                 size_byte_wider;
  wire                                 fbw_mode,qbw_mode,hbw_mode;
  reg                                  parity_type_r;
  wire                                 parity_type_edge_p;

  integer i; // for loop index
  integer j; // for loop index
  integer m; // for loop index

  assign hbw_mode = (reg_ddrc_data_bus_width==HBW && PDBW_CASE!=0) ? 1'b1: 1'b0;
  assign qbw_mode = (reg_ddrc_data_bus_width==QBW && PDBW_CASE!=0) ? 1'b1: 1'b0;
  assign fbw_mode = (reg_ddrc_data_bus_width==FBW || PDBW_CASE==0) ? 1'b1: 1'b0;

  assign bypass_en = ((PDBW_CASE==2) & (hbw_mode|fbw_mode)) ||
                     ((PDBW_CASE==1) & fbw_mode) ;
  
  assign size_byte_wider = {{AXI_MAXSIZE{1'b0}},1'b1} << asize_down;
  assign size_byte = size_byte_wider[AXI_MAXSIZE-1:0];
 //spyglass disable_block W164a
 //SMD: '{asize ,split ,addr_offset}' width 8 is less than RHS: 'info' width 9 in assignment
 //SJ: Width mismatch happens as UPSIZE and DOWNSIZE can co-exist as part of bug 7175. Need to review this.
  assign {asize,split,addr_offset} = info;
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
                                 //                                      : asize-ENIF_MAXSIZE_QBW;
                                 : hbw_mode ? asize-ENIF_MAXSIZE_HBW
                                            : qbw_mode ? asize-ENIF_MAXSIZE_QBW
                                                       : asize-ENIF_MAXSIZE ; //FBW
                
      end
  endgenerate

  assign last_up = last & ((last_index&~split)|bypass_en);
//  assign last_up = last &~split; // OM is last_index redundant ??
  assign data_up     = data_up_next;
  assign parity_up   = parity_up_next;

  assign rerror_up = (wr&rerror) | rerror_reg;
  assign rerror_next = rerror_up &~(wr & last_index);

  assign rexa_acc_instr_up = (wr&rexa_acc_instr);

  assign rpoison_up = (wr&rpoison);

  assign ocpar_err_up   = (wr&ocpar_err);
   
  assign empty =  ~(wr & last_index);

  generate
  if  (PDBW_CASE==0) begin : data_indx_no_pgdbw
    assign data_index =  addr_offset_count_next[ENIF_MAXSIZE+:CONV_RATIO_LG2];
    assign data_index_sel = data_index;
  end else begin : data_index_pgdbw

      assign data_index =  addr_offset_count_next[ENIF_MAXSIZE_QBW +:CONV_RATIO_LG2];

      //data_index_sel is used to select the segment of data_up where effective width of data is to be plugged.
      // - effective width of data depends on FBW/HBW/QBW mode
      // - Hence depending on the bus_Width mode data_index_sel needs to be adjusted
      if (PDBW_CASE==1)  begin : data_indx_case1
       // when in case1 FBW is invalid and RDU remains bypassed
       // Here HBW means effective data is 2x wider than QBW data
       // so in QBW there are 2x more data segments in data_up
        assign data_index_sel =  bypass_en ? 'h0 :
                                           qbw_mode ? addr_offset_count_next[ENIF_MAXSIZE_QBW +:CONV_RATIO_LG2] :
                                                      addr_offset_count_next[ENIF_MAXSIZE_HBW +:CONV_RATIO_HBW_LG2];
        //spyglass disable_block W528
        //SMD: Variable set but not read
        //SJ: Used in different generate blocks 
        assign data_index_fbw = 'h0; //bypass
        //spyglass enable_block W528  
        //Loss of MSB here is okay, 

        //spyglass disable_block W486
        //SMD: Rhs width '2' with shift (Expr: '(data_index >> (..._RATIO_HBW_LG2))') is more than lhs width '1' (Expr: 'data_index_hbw'), this may cause overflow
        //SJ: In RHS expression, a minimum right shift by 1 is guaranteed. So LS bit is always zero.

        //spyglass disable_block W164a
        //SMD: LHS: 'data_index_hbw' width 1 is less than RHS: '(data_index >> (CONV_RATIO_LG2 - CONV_RATIO_HBW_LG2))' width 2 in assignment
        //SJ: In RHS expression, a minimum right shift by 1 is guaranteed. So LS bit is always zero.
        assign data_index_hbw = data_index>>(CONV_RATIO_LG2-CONV_RATIO_HBW_LG2) ;
        //spyglass enable_block W164a
        //spyglass enable_block W486

      end else if (PDBW_CASE==2)  begin : data_indx_case2 
       //when in case2 FBW & HBW are invalid as RDU remains bypassed 
        assign data_index_sel =  bypass_en ? 'h0 : addr_offset_count_next[ENIF_MAXSIZE_QBW +:CONV_RATIO_LG2] ;
        //spyglass disable_block W528
        //SMD: Variable set but not read
        //SJ: Used in different generate blocks
        assign data_index_fbw = 'h0; //bypass
        assign data_index_hbw = 'h0; //bypass
        //spyglass enable_block W528     
      end else begin : data_indx_case5
       //when in case5 FBW ,HBW & QBW are all valid as RDU is never in bypass.
       //in this case ENIF_MAXSIZE < AXI_MAXSIZE.
       // Here HBW means effective data is 2x wider than QBW data and in FBW its 4x wider than QBW.
       // so in QBW there are 4x more data segments in data_up as compared to FBW.
       // and as compared to HBW, QBW has 2x more data segments in data_up. 
        assign data_index_sel =  bypass_en ? 'h0 :
                                           qbw_mode ? addr_offset_count_next[ENIF_MAXSIZE_QBW +:CONV_RATIO_LG2] :
                                           hbw_mode ? addr_offset_count_next[ENIF_MAXSIZE_HBW +:CONV_RATIO_HBW_LG2] :  
                                                      addr_offset_count_next[ENIF_MAXSIZE +:CONV_RATIO_FBW_LG2];
        //spyglass disable_block W486
        //SMD: Rhs width '2' with shift (Expr: '(data_index >> (..._RATIO_HBW_LG2))') is more than lhs width '1' (Expr: 'data_index_hbw'), this may cause overflow
        //SJ: In RHS expression, a minimum right shift by 1 is guaranteed. So LS bit is always zero.

        //Loss of MSB here is okay, 
        //spyglass disable_block W164a
        //SMD: LHS: 'data_index_fbw' width 1 is less than RHS: '(data_index >> (CONV_RATIO_LG2 - CONV_RATIO_FBW_LG2))' width 3 in assignment
        //SJ: In RHS expression, a minimum right shift by 2 is guaranteed. So LS 2 bits are always zero.
        assign data_index_fbw = data_index>>(CONV_RATIO_LG2-CONV_RATIO_FBW_LG2) ;
        //spyglass enable_block W164a
        
        //spyglass disable_block W164a
        //SMD: LHS: 'data_index_hbw' width 3 is less than RHS: '(data_index >> (CONV_RATIO_LG2 - CONV_RATIO_HBW_LG2))' width 4 in assignment
        //SJ: In RHS expression, a minimum right shift by 1 is guaranteed. So LS bit is always zero.
        assign data_index_hbw = data_index>>(CONV_RATIO_LG2-CONV_RATIO_HBW_LG2) ;
        //spyglass enable_block W164a
        //spyglass enable_block W486
      end 
  end //dat_index_pgdbw
  endgenerate

  genvar gv;
  generate
//------------------------------------------  
  if(PDBW_CASE==0) begin :no_pgdbw
//------------------------------------------  
  
    always @(*) begin:data_up_PROC
      for (i=0 ; i < CONV_RATIO ; i=i+1) begin 
     //   data_up_next_a[i]    = data_up_reg_a[i];
      //  parity_up_next_a[i]  = parity_up_reg_a[i];
          data_up_next    = data_up_reg;
          parity_up_next  = parity_up_reg;
        if (wr) begin
          if (data_index == i) begin
            //data_up_next_a[i]   = data;
            //parity_up_next_a[i] = parity;
            data_up_next[i*ENIF_DATAW+:ENIF_DATAW] = data;
            parity_up_next[i*ENIF_STRBW+:ENIF_STRBW] = parity;
          end
        end
      end
    end // block: data_up_PROC
    
//------------------------------------------  
  end else begin : pdbw 
//------------------------------------------  
    always @(*) begin:data_up_PROC
        data_up_next    = data_up_reg;
        parity_up_next  = parity_up_reg;
       //Number of segments in each of the bus mode
       // FBW - CONV_RATIO_FBW
       // HBW - CONV_RATIO_HBW
       // QBW - CONV_RATIO
        if (hbw_mode) begin //HBW mode
          for (i=0 ; i < CONV_RATIO_HBW ; i=i+1) begin 
            if (wr && (data_index_sel == i)) begin
                data_up_next[i*ENIF_DATAW_HBW +: ENIF_DATAW_HBW] = data[0+:ENIF_DATAW_HBW];
                parity_up_next[i*ENIF_STRBW_HBW +: ENIF_STRBW_HBW] = parity[0+: ENIF_STRBW_HBW];
            end //if WR
          end //for  0 ...CONV_RATIO_HBW
        end // HBW Mode
        else if (qbw_mode) begin //QBW mode
          for (i=0 ; i < CONV_RATIO ; i=i+1) begin 
            if (wr && (data_index_sel == i)) begin
                data_up_next[i*ENIF_DATAW_QBW +: ENIF_DATAW_QBW] = data[0+:ENIF_DATAW_QBW];
                parity_up_next[i*ENIF_STRBW_QBW +: ENIF_STRBW_QBW] = parity[0+: ENIF_STRBW_QBW];
            end //if WR
          end //for  0 ... CONV_RATIO_QBW
        end // QBW Mode
        else  begin //FBW Mode
          for (i=0 ; i < CONV_RATIO_FBW ; i=i+1) begin 
            if (wr && (data_index_sel == i)) begin
                data_up_next[i*ENIF_DATAW_FBW +: ENIF_DATAW_FBW] = data[0+:ENIF_DATAW_FBW];
                parity_up_next[i*ENIF_STRBW_FBW +: ENIF_STRBW_FBW] = parity[0+: ENIF_STRBW_FBW];
            end //if WR
          end //for
        end //FBW mode
    end //data_up_PROC
    
  end  //pdbw
  endgenerate

  always @ (posedge clk or negedge rst_n) begin:sync_PROC
    if (rst_n == 1'b0) begin
     // for (i=0; i<CONV_RATIO; i=i+1) begin
     //    data_up_reg_a[i]  <= {DATAW{1'b0}};
     //    parity_up_reg_a[i]<= {ENIF_STRBW{1'b0}};
     // end
      data_up_reg <= {AXI_DATAW{1'b0}};
      parity_up_reg <= {AXI_STRBW{1'b0}};
      addr_offset_count_reg  <= {AXI_MAXSIZE{1'b0}};
      du_state_reg <= IDLE;
      rerror_reg <= 1'b0;
      parity_type_r <= 1'b0;
       
    end
    else  begin
       // for (i=0; i<CONV_RATIO; i=i+1) begin
       //    if (du_state_next==IDLE && !last_pkt)   
       //       // Initialize every new burst to have clean values
       //       data_up_reg_a[i]  <= {DATAW{1'b0}};
       //    else
       //       data_up_reg_a[i]  <= data_up_next_a[i];
       //    if (rst_dly) 
       //       parity_up_reg_a[i]<= {ENIF_STRBW{parity_type}};
       //    else if (du_state_next==IDLE)
       //       // Initialize every new burst to have clean values
       //       parity_up_reg_a[i]<= {ENIF_STRBW{parity_type}};
       //    else 
       //       parity_up_reg_a[i]<= parity_up_next_a[i];
       // end
    //-------------------------------  
      if (du_state_next==IDLE && last)  
        data_up_reg <= {AXI_DATAW{1'b0}};
      else
        data_up_reg <= data_up_next;
      //ccx_cond: ; 0; 10; When rst_dly is asserted, du_state_next is always in IDLE and last=1.
      if (rst_dly || (du_state_next==IDLE && (last|parity_type_edge_p))) 
        parity_up_reg <= {AXI_STRBW{parity_type}};
      else 
        parity_up_reg <= parity_up_next;
    //-------------------------------  

      addr_offset_count_reg  <= addr_offset_count_next;
      du_state_reg <= du_state_next;
      rerror_reg <= rerror_next;
      parity_type_r <= parity_type;
    end
  end
  assign parity_type_edge_p = parity_type_r ^ parity_type;
  assign full = ~rd;
  
  wire wrap_same_beat;
//  wire max_index;

//  assign max_index = (data_index==(CONV_RATIO-1)) ? 1'b1:1'b0;
  
  assign wrap_same_beat = last & split;
  
  
  always @(*) begin
    du_state_next = du_state_reg;
    addr_offset_count_next = addr_offset_count_reg;
    case (du_state_reg)
    IDLE: begin
      if (wr &rd) begin
        addr_offset_count_next = addr_offset;
        if (~(last|wrap_same_beat|last_pkt))
          du_state_next = UNPACK;
        end
      end
      default: begin //UNPACK:
        if (wr &rd) begin  
          //spyglass disable_block W164a
          //SMD: LHS: 'addr_offset_count_next' width 6 is less than RHS: '(addr_offset_count_reg + size_byte)' width 7 in assignment
          //SJ: Overflow expected. See bug5632, comment #19.
          addr_offset_count_next = addr_offset_count_reg+size_byte;
          //spyglass enable_block W164a
          if (last|wrap_same_beat|last_pkt)  
            du_state_next = IDLE;
        end          
      end
    endcase // case(du_state_reg)
  end // always @ (*)
    
  //spyglass disable_block W415a
  //SMD: Signal last_index is being assigned multiple times in same always block. 
  //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression '(i - 1)' found in module 'DWC_ddr_umctl2_xpi_rdu'
  //SJ: This coding style is acceptable and there is no plan to change it.
  always @(*) begin:last_index_PORC
    last_index = (size_ratio==0)?1'b1:1'b0;
    for (i=1 ; i<=CONV_RATIO_LG2 ; i=i+1) begin
      if (size_ratio == $unsigned(i)) begin //check sizeratio
        last_index = 1'b1;
        if(qbw_mode) begin
          for (j=0 ; j<=CONV_RATIO_LG2-1 ; j=j+1) begin
             if(j <= i - 1 ) begin 
               last_index =last_index&data_index[j];
             end 
          end //for j
        end else if (hbw_mode) begin 
          for (j=0 ; j<=CONV_RATIO_HBW_LG2-1 ; j=j+1) begin
             if(j <= i - 1 ) begin 
               last_index =last_index&data_index_hbw[j];
             end 
          end //for j
        end else begin //FBW
          for (j=0 ; j<=CONV_RATIO_FBW_LG2-1 ; j=j+1) begin
             if(j <= i - 1 ) begin 
               last_index =last_index&data_index_fbw[j];
             end 
          end //for j
        end
      end // //check sizeratio
    end //for i
  end // always @ (*)  
  //spyglass enable_block SelfDeterminedExpr-ML   
  //spyglass enable_block W415a
             
`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  
  `assert_x_value(ERROR_XPI_RDU_INFO_SIGNAL_VALUE_X,wr,info);

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

endmodule // DWC_ddr_umctl2_xpi_rdu
