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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_disp.sv#1 $
// -------------------------------------------------------------------------
// Description:
//          uMCTL XPI Disperser
module DWC_ddr_umctl2_xpi_disp
 #(
        parameter ENIF_DATAW   = 512, //Input Bus width, can be data, strobe or parity bus
       
        parameter BYTE_PARW    = 1, //Number of partity bits per byte of data, used for wparity inst, keep 1 for others  
        parameter NAB          = 3, // Frequency ratio mode
        parameter M_DW         = 64, // width of in_data equivalent at the memory interface
        parameter XBW_CHK      = M_DW // Used to check if HBW/QBW is possible, varies for data and strobe instances
 )
 ( 
   input [ENIF_DATAW-1:0]   in_data, // Input data that needs to be dispersed
   
   input [1:0]              bus_width, // Specifies FBW, HBW, QBW 
   input [1:0]              bus_seg,   // effective segment of input, used in HBW/QBW modes
   input                    fill,      // value to be padded
   
   output reg [ENIF_DATAW-1:0]  out_data   

  );

    localparam FBW           = 2'b00;
    localparam HBW           = 2'b01;
    localparam QBW           = 2'b10;
    localparam M_DW_FBW      = (BYTE_PARW * M_DW);
    localparam M_DW_HBW      = (BYTE_PARW * M_DW)/2;
    localparam M_DW_QBW      = (BYTE_PARW * M_DW)/4;
    localparam M_SEG         = (1 << NAB);    
    localparam ENIF_DATAW_HBW = ENIF_DATAW/2;
    localparam ENIF_DATAW_QBW = ENIF_DATAW/4;
     
  

    
   logic [ENIF_DATAW-1:0]  out_data_hbw;   
   logic [ENIF_DATAW-1:0]  out_data_qbw;   
   int i;
   //wire fill;
   //assign fill = FILL;


   generate
     if(XBW_CHK>=16) begin : HBW_en
       reg [(ENIF_DATAW/2)-1:0]  data_seg_hbw;   
  
       always@(*) begin : Disperser_block_hbw 
           out_data_hbw = {ENIF_DATAW{fill}};
           data_seg_hbw = (bus_seg[1]==1'b0) ? in_data[0 +: ENIF_DATAW_HBW ] : in_data[ENIF_DATAW_HBW +: ENIF_DATAW_HBW ];
           for (i=0; i<M_SEG;i++) begin
             // spyglass disable_block SelfDeterminedExpr-ML
             // SMD: Self determined expression, 'i*M_DW_HBW', found in module.
             // SJ: For loop variable M_SEG ensures extracted data slice never exceeds the range of data_seg_hbw.
             out_data_hbw[(i*M_DW_FBW) +: M_DW_HBW] = data_seg_hbw[i*M_DW_HBW +: M_DW_HBW] ;
             // spyglass enable_block SelfDeterminedExpr-ML
           end   
       end //Disperser_block_hbw
  
     end else begin : HBW_dis // treat as FBW
      assign out_data_hbw = in_data;
     end
     
     if(XBW_CHK>=32) begin : QBW_en
        reg [(ENIF_DATAW/4)-1:0]  data_seg_qbw;  
  
        always@(*) begin : Disperser_block_qbw 
            out_data_qbw = {ENIF_DATAW{fill}};
            case(bus_seg)
              2'b00 :  data_seg_qbw =  in_data[0 +: ENIF_DATAW_QBW]; 
              2'b01 :  data_seg_qbw =  in_data[1*ENIF_DATAW_QBW +: ENIF_DATAW_QBW]; 
              2'b10 :  data_seg_qbw =  in_data[2*ENIF_DATAW_QBW +: ENIF_DATAW_QBW]; 
              2'b11 :  data_seg_qbw =  in_data[3*ENIF_DATAW_QBW +: ENIF_DATAW_QBW]; 
            endcase
            for (i=0; i<M_SEG; i++) begin
             // spyglass disable_block SelfDeterminedExpr-ML
             // SMD: Self determined expression, 'i*M_DW_QBW', found in module.
             // SJ: For loop variable M_SEG ensures extracted data slice never exceeds the range of data_seg_qbw.
              out_data_qbw[(i*M_DW_FBW) +: M_DW_QBW] = data_seg_qbw[i*M_DW_QBW +: M_DW_QBW] ;
             // spyglass enable_block SelfDeterminedExpr-ML
            end    
        end //Disperser_block_qbw
  
     end else begin : QBW_dis // treat as FBW
       assign out_data_qbw = in_data;  
     end  
   endgenerate     

   always@(*) begin : Disperser_block
      case(bus_width)
        HBW     : out_data = out_data_hbw;
        QBW     : out_data = out_data_qbw;
        default : out_data = in_data; //FBW 
      endcase
   end //Disperser_block

endmodule
