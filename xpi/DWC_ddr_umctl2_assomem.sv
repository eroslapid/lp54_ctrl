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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_assomem.sv#1 $
// -------------------------------------------------------------------------
// Description:
/******************************************************************************
 * DESCRIPTION: uMCTL2 Associative Memory                                      *
 *                                                                            *
 *****************************************************************************/

`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_assomem
  (/*AUTOARG*/
   // Outputs
   q, empty, full, par_err, 
   // Inputs
   clk, rst_n, wr, rd, d, wr_id, rd_id, par_en
   );
  
   
  //---------------------------------------------------------------------------
  // Parameters
  //---------------------------------------------------------------------------
  parameter         DATAW     = 32;
  parameter         IDW       = 4;
  parameter integer NUMID     = 8;
  parameter         OCCAP_EN  = 0;
  parameter         OCCAP_PIPELINE_EN  = 0;
 
  localparam NUMID_LG2    = `UMCTL_LOG2(NUMID);

  localparam SL_W         = DATAW<8 ? DATAW : 8;
  localparam PARW         = (OCCAP_EN==1) ? ((DATAW%SL_W>0) ? DATAW/SL_W+1 : DATAW/SL_W) : 0;
   
  //---------------------------------------------------------------------------
  // Interface Pins
  //---------------------------------------------------------------------------
  input                                clk;          // clock
  input                                rst_n;        // asynchronous reset
  input                                wr;           // write
  input                                rd;           // read 
  input [DATAW-1:0]                    d;
  input [IDW-1:0]                      wr_id;
  input [IDW-1:0]                      rd_id;   
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block.
  input                                par_en;
//spyglass enable_block W240
  output [DATAW-1:0]                   q;
  output                               empty;        // empty 
  output                               full;         // full
  output                               par_err;
   
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [DATAW-1:0]                      data_mem [0 : NUMID-1];
  reg [IDW-1:0]                        id_mem [0 :NUMID-1];
  reg [NUMID-1:0]                      valid;

  reg                                  wr_id_found;
  reg                                  rd_id_found;   
  reg [DATAW-1:0]                      q;
  reg [NUMID-1:0]                      wr_addr_oh;
  wire [NUMID-1:0]                     wr_addr_l_oh;
  reg [NUMID-1:0]                      rd_addr_oh;
  reg [NUMID-1:0]                      rewr_addr_oh;
  wire                                 same_id; 
  assign                               full = &valid;
  assign                               empty = ~(|valid);
    
  assign wr_addr_l_oh = wr_id_found ? rewr_addr_oh:wr_addr_oh;
  assign same_id = (wr_id==rd_id) ? 1'b1:1'b0;
  integer i; // for loop index
  
  always @ (posedge clk or negedge rst_n) begin : mem_PROC
    if (rst_n == 1'b0) begin
      for (i=0 ; i < NUMID ; i=i+1) begin 
        data_mem[i] <= {DATAW{1'b0}};
        id_mem[i] <= {IDW{1'b0}};
      end
    end else begin
       for (i=0 ; i < NUMID ; i=i+1)
         if (wr&wr_addr_l_oh[i]) begin
           data_mem[i] <= d;
           id_mem[i] <= wr_id;
         end
       
    end
  end
  always @ (posedge clk or negedge rst_n) begin : valid_PROC
    if (rst_n == 1'b0) begin
      valid <= {NUMID{1'b0}};
    end else begin   
      for (i=0 ; i < NUMID ; i=i+1) begin
         if (rd & rd_addr_oh[i])
           valid [i] <=1'b0;
         else if (wr & wr_addr_l_oh[i]&~(rd&same_id))
           valid [i] <= 1'b1;
      end
    end     
  end
  
//spyglass disable_block W415a
//SMD: Signal wr_addr_oh/rd_addr_oh/rd_id_found/q/wr_id_found/rewr_addr_oh is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
  always @(*) begin : wr_addr_PROC 
    wr_addr_oh= {NUMID{1'b0}};
    for (i=NUMID-1; i >=0 ; i=i-1) begin
      if (valid[i]==1'b0)
        wr_addr_oh = 1'b1<<i;
    end
  end
  
  //spyglass disable_block W528
  //SMD: Variable set but not read
  //SJ: Used in RTL assertion
  always @(*) begin : rd_addr_PROC
    rd_addr_oh= {NUMID{1'b0}};
    rd_id_found = 1'b0;
    q = {DATAW{1'b0}};
    for (i=0 ; i < NUMID ; i=i+1) begin
      if (id_mem[i]==rd_id&&valid[i]==1'b1) begin 
        rd_addr_oh = 1'b1<<i;
        rd_id_found = 1'b1;
        q = data_mem[i];         
      end
       
    end
  end
  //spyglass enable_block W528

  always @(*) begin : rewr_addr_PROC
    rewr_addr_oh= {NUMID{1'b0}};
    wr_id_found = 1'b0;
    for (i=0 ; i < NUMID ; i=i+1) begin
      if (id_mem[i]==wr_id&&valid[i]==1'b1) begin 
        rewr_addr_oh =  1'b1<<i;
        wr_id_found   = 1'b1;
      end
    end
  end
//spyglass enable_block W415a

  generate
    if (OCCAP_EN==1) begin: PAR_check

      reg [PARW-1:0] par_mem [0 : NUMID-1];

      wire [PARW-1:0] parity_dummy, mask_in;

      wire [PARW-1:0] d_par, parity_err;
      wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;

      reg [PARW-1:0] q_par;

      wire pgen_en, pcheck_en;

      wire poison_en = 1'b0;

      assign parity_dummy  = {PARW{1'b1}};
      assign mask_in       = {PARW{1'b1}};

      assign pgen_en    = wr;
      assign pcheck_en  = par_en & rd;


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (DATAW),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (d),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (d_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (DATAW),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (q),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (q_par), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );


         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg par_err_r;
           always @ (posedge clk or negedge rst_n) begin : par_err_r_PROC
             if (~rst_n) begin
               par_err_r <= 1'b0;
             end else begin
               par_err_r <= |parity_err;
             end
           end

           assign par_err = par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign par_err = |parity_err;

         end 

      
      always @ (posedge clk or negedge rst_n) begin : mem_PROC
         if (~rst_n) begin
            for (i=0 ; i < NUMID ; i=i+1) begin
               par_mem[i] <= {PARW{1'b0}};
            end
         end
         else begin
            for (i=0 ; i < NUMID ; i=i+1) begin
               if (wr&wr_addr_l_oh[i]) begin
                  par_mem[i] <= d_par;
               end
            end
         end
      end

      //spyglass disable_block W415a
      //SMD: Signal q_par is being assigned multiple times in same always block. 
      //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
      always @(*) begin : rd_addr_PROC
         q_par = {DATAW{1'b0}};
         for (i=0 ; i < NUMID ; i=i+1) begin
            if (id_mem[i]==rd_id&&valid[i]==1'b1) begin 
               q_par = par_mem[i];         
            end   
         end
      end
      //spyglass enable_block W415a
      
    end // PAR_check
    else begin: OCCAP_dis
   
      assign par_err = 1'b0;

    end // OCCAP_dis
  endgenerate

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  
  reg  [NUMID_LG2:0] id_count;
  always @ (posedge clk or negedge rst_n) begin : id_count_monitor
    if (rst_n == 1'b0) begin
      id_count <= {NUMID_LG2{1'b0}};
    end 
    else begin
      if (wr&~wr_id_found&~full&~(rd&same_id) & ~(rd&rd_id_found &~empty))
        id_count=id_count+1;
      else if ( rd&rd_id_found &~empty & ~(wr&~wr_id_found&~full&~(rd&same_id)))
        id_count=id_count-1;
    end
  end
  reg  [NUMID_LG2:0] num_valid_count;
  always @(*) begin : valid_count_monitor
    num_valid_count      = {NUMID_LG2{1'b0}};
    for (i=NUMID-1; i >=0 ; i=i-1) begin
      if (valid[i]==1'b1)
        num_valid_count = num_valid_count+1;
    end
  end
   
  // Check that the number of 1 in valid vector is consistent with the number of stored IDs
   property p_valid_consistent;
     @(posedge clk)  disable iff(!rst_n) 
     num_valid_count== id_count;
   endproperty
   a_valid_consistent : assert property (p_valid_consistent) else 
    $display("-> %0t ERROR: Valid vector inconsistent with number of stored IDs!!!", $realtime);

   // ASSOMEM is full and a new ID is needed
   property p_assomem_full_wr;
     @(posedge clk) disable iff(!rst_n) 
       (wr&~wr_id_found) |-> (~full);
   endproperty  
   a_assomem_full_wr : assert property (p_assomem_full_wr) else 
     $display("-> %0t ERROR: Associative memory full and new ID must be stored!!!", $realtime);


  // Coverge point for assomem usage
  cp_assomem_usage_1_id :
  cover property (
    @(posedge clk) id_count==1
  );
  cp_assomem_usage_2_id :
  cover property (
    @(posedge clk) id_count==2
  );
  cp_assomem_usage_3_id :
  cover property (
    @(posedge clk) id_count==3
  );
  cp_assomem_usage_4_id :
  cover property (
    @(posedge clk) id_count==4
  );
  cp_assomem_usage_5_id :
  cover property (
    @(posedge clk) id_count==5
  );
  cp_assomem_usage_6_id :
  cover property (
    @(posedge clk) id_count==6
  );
  cp_assomem_usage_7_id :
  cover property (
    @(posedge clk) id_count==7
  );
  cp_assomem_usage_8_id :
  cover property (
    @(posedge clk) id_count==8
  );
  cp_assomem_usage_25_pc :
  cover property (
    @(posedge clk) id_count==NUMID/4
  );
  cp_assomem_usage_50_pc :
  cover property (
    @(posedge clk) id_count==NUMID/2
  );
  cp_assomem_usage_75_pc :
  cover property (
    @(posedge clk) id_count==(NUMID/4)*3
  );
  cp_assomem_usage_90_pc :
  cover property (
    @(posedge clk) id_count==(NUMID/10)*9
  );
  cp_assomem_usage_100_pc :
  cover property (
    @(posedge clk) id_count==NUMID
  );
   
`endif  // SYNTHESIS
`endif // SNPS_ASSERT_ON
  
endmodule // DWC_ddr_umctl2_assomem
