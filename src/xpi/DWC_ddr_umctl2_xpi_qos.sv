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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_qos.sv#1 $
// -------------------------------------------------------------------------
// Description:
//              DDR Controller QoS mapper                                  
//              Decode read/write transaction priorities based on qos input
//              and qos registers values.                                  
//              2 or 3 regions can be present depending on the hardware    
//              configuration. Levels separate these regions.              
//              QoS input is compared against the levels and mapped to a   
//              region, priority assigned based on region settings.        
`include "DWC_ddrctl_all_defs.svh"
 module DWC_ddr_umctl2_xpi_qos
  #(
    parameter USE2AQ            = 0, // dual queue
    parameter AXI_QOSW          = 4, // qos signal width
    parameter QOS_MLW           = 4, // map_level signal width
    parameter QOS_RW            = 2 // map_region signal width
  )
  (
   // QOS configuration
   input [QOS_MLW-1:0]             qos_map_level1, // level separation of region0 and region1
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input [QOS_MLW-1:0]             qos_map_level2, // level separation of region 1 and region2 (present only for reads when dual queue is enabled)
   input [QOS_RW-1:0]              qos_map_region0, // priority for region0
   input [QOS_RW-1:0]              qos_map_region1, // priority for region1
   input [QOS_RW-1:0]              qos_map_region2, // priority for region2 (present only for reads when dual queue is enabled)
//spyglass enable_block W240
   // QoS input
   input [AXI_QOSW-1:0]            qos_value,     // AXI read/write QOS
   // Output
   output [QOS_RW-1:0]             qos_priority, // output priority
   output                          aq_mux_select // mux selection for dual queue
  );



   //---------------------------------------------------------------------------
   // Local Parameters 
   //---------------------------------------------------------------------------


   localparam QOS_SIZE = 1 << QOS_MLW;


   //---------------------------------------------------------------------------
   // Internal Signals
   //---------------------------------------------------------------------------

   wire [QOS_MLW-1:0]   qos_input; // AXI QOS

   wire [QOS_SIZE-1:0]  qos_input_encode, qos_map_level1_encode, qos_1;

   wire [QOS_SIZE-1:0]  qos_level1_compare;

   wire [1:0]           qos_region; // 11 (region 0), 01 (region 1), 00 (region 2)

   wire                 mux_select;

   //---------------------------------------------------------------------------
   // Main Module
   //---------------------------------------------------------------------------


   // adapt the QoS input to the QoS register (they should be always the same, i.e. 4 bits width)

   generate
   if (QOS_MLW>AXI_QOSW) begin: m_gt_in
      assign qos_input = {{(QOS_MLW-AXI_QOSW){1'b0}},qos_value};
   end else begin: in_gt_m
      assign qos_input = qos_value[QOS_MLW-1:0];
   end
   endgenerate

   // vector 1 for shift
   assign qos_1         = {{(QOS_SIZE-1){1'b0}},1'b1};

   // mux select output
   assign aq_mux_select = ~mux_select;
   
   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression '(qos_map_level1 + 1)' found in module 'DWC_ddr_umctl2_xpi_qos'
   //SJ: This coding style is acceptable and there is no plan to change it.

   // Encode in 1 hot the input QoS value and level1
   assign qos_map_level1_encode = (qos_1 << (qos_map_level1+1)) - 1;
   assign qos_input_encode      = (qos_1 << qos_input);
   //spyglass enable_block SelfDeterminedExpr-ML

   // compare input and level1
   assign qos_level1_compare = qos_input_encode & qos_map_level1_encode;
   // generate control signal
   assign qos_region[1] = |qos_level1_compare;


   generate
   if (USE2AQ==1) begin: level2_en

      wire [QOS_SIZE-1:0] qos_map_level2_encode, qos_level2_compare;
      
      //spyglass disable_block SelfDeterminedExpr-ML
      //SMD: Self determined expression '(qos_map_level2 + 1)' found in module 'DWC_ddr_umctl2_xpi_qos'
      //SJ: This coding style is acceptable and there is no plan to change it.

      // level2 1 hot encode
      assign qos_map_level2_encode  = (qos_1 << (qos_map_level2+1)) - 1;
      //spyglass enable_block SelfDeterminedExpr-ML
      
      // compare input and level2
      assign qos_level2_compare     = qos_input_encode & qos_map_level2_encode;
      // generate control signal
      assign qos_region[0]          = |qos_level2_compare;

      // priority output, combination of both control signals gives the mapping

      assign qos_priority = (qos_region == 3) ? qos_map_region0 :
                            (qos_region == 1) ? qos_map_region1 :
                                                qos_map_region2;
      // mux select output

      assign mux_select = qos_region[0];

   end else begin: level2_dis

      // not used
      assign qos_region[0]          = 1'b0;

      // only 2 regions, assign priority
      assign qos_priority = (qos_region[1]==1) ? qos_map_region0 :  
                                                 qos_map_region1;

      // no mux when single queue
      assign mux_select = 1'b1;
   end
   endgenerate   



endmodule // DWC_ddr_umctl2_xpi
