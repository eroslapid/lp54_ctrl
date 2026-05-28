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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_cnvg.sv#1 $
// -------------------------------------------------------------------------
// Description:
//   uMCTL XPI Converger
//   In HBW mode, this module packs the dispersed data into Lower Half
//   In QBW mode, this module packs the dispersed data into Lowerst Quarter
//   In FBW mode this is feed through
module DWC_ddr_umctl2_xpi_cnvg
 #(
        parameter ENIF_DATAW   = 512, // HIF interface data width
        parameter NAB          = 3,   // FREQ Ratio mode 
        parameter XBW_CHK      = 64, //Should be MEMC_DRAM_DATAW for all instances
        parameter M_DW         = 64   // DRAM Data width
        
 )
 ( 
   input [ENIF_DATAW-1:0]   in_data,
   input [1:0]              bus_width,
      
   output reg [ENIF_DATAW-1:0]  out_data   

  );

    localparam FBW           = 2'b00;
    localparam HBW           = 2'b01;
    localparam QBW           = 2'b10;
    localparam M_DW_HBW      = (XBW_CHK > 8)  ? M_DW/2 : M_DW;
    localparam M_DW_QBW      = (XBW_CHK > 16) ? M_DW/4 : M_DW_HBW;
    localparam M_SEG         = (1 << NAB);    
      
   
   int i;
   logic [$clog2(ENIF_DATAW)-1:0] base_hbw;
   logic [$clog2(ENIF_DATAW)-1:0] base_qbw;
   
   always@(*) begin : converger_block  
     if (bus_width==HBW) begin  
       out_data = {ENIF_DATAW{1'b0}};
       
       for (i=0; i<M_SEG;i++) begin
//spyglass disable_block W415a
//SMD: Signal base_hbw is being assigned multiple times ( assignment within same for-loop ) in same always block
//SJ: base_hbw is used as a variable. In each loop iteration it should have diff values.
         base_hbw = (i*M_DW);
//spyglass enable_block W415a

//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index '[base_hbw +:M_DW_HBW] ' of width '6' is larger than the width '5' required for the max value '31' of the signal 'in_data'
//SJ: The index will never overflow. Spyglass considers the carry bit as an extra bit.
         out_data[(i*M_DW_HBW) +: M_DW_HBW] = in_data[base_hbw +: M_DW_HBW] ;
//spyglass enable_block ImproperRangeIndex-ML
       end   
     end else if (bus_width == QBW) begin //QBW
       out_data = {ENIF_DATAW{1'b0}};
              
       for (i=0; i<M_SEG; i++) begin
//spyglass disable_block W415a
//SMD: Signal base_hbw is being assigned multiple times ( assignment within same for-loop ) in same always block
//SJ: base_hbw is used as a variable. In each loop iteration it should have diff values.
         base_qbw = (i*M_DW);
//spyglass enable_block W415a

//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index '[base_qbw +:M_DW_QBW] ' of width '8' is larger than the width '7' required for the max value '127' of the signal 'in_data'
//SJ: The index will never overflow. Spyglass considers the carry bit as an extra bit.
         out_data[(i*M_DW_QBW) +: M_DW_QBW] = in_data[base_qbw +: M_DW_QBW] ;
//spyglass enable_block ImproperRangeIndex-ML
       end    
     end else begin // (bus_width==FBW)
       out_data = in_data;  
     end  
   end //converger_block

        
endmodule
