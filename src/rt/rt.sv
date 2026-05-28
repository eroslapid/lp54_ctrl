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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/rt/rt.sv#2 $
// -------------------------------------------------------------------------
// Description:
//
// Response Tracker:
// When a read is issued to DRAM, this unit tracks information associated
// with that read in a fifo-like pipeline until the read data is returned.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module rt (co_yy_clk, core_ddrc_rstn,
                ddrc_cg_en,
                reg_ddrc_occap_en,
                reg_ddrc_occap_en_r,
                ddrc_occap_rtfifo_parity_err,
                ddrc_occap_rtctrl_parity_err,
                dh_rt_burst_rdwr,
                dh_rt_data_bus_width,
                dh_rt_frequency_ratio,
                rt_rd_rd_mrr_sod,

                dh_rt_lpddr4,
                reg_ddrc_lpddr5,
                pi_rt_rd_vld, pi_rt_rd_tag,
                pi_rt_rd_partial,

                ph_rt_rdatavld,
                reg_ddrc_rd_dbi_en,
                ph_rt_rdbi_n,
                ph_rt_rdata,
                rt_rd_rdbi_n,
                rt_rd_rdata,
                rt_gs_empty,
                rt_gs_empty_delayed,
                rt_rd_rd_valid,
                rt_rd_eod,
                rt_rd_rd_partial,
                rt_rd_rd_tag
`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
                );

   //------------------------- INPUTS AND OUTPUTS ---------------------------------

   parameter    CMD_LEN_BITS    = 1;
   parameter    PHY_DATA_WIDTH  = `MEMC_DFI_TOTAL_DATA_WIDTH;   // data width from PHY
   parameter    PHY_DBI_WIDTH   = `MEMC_DFI_TOTAL_DATA_WIDTH/8;        // read data DBI width from PHY
   parameter    FREQ_RATIO      = 1;   // freq ratio
   parameter    CORE_TAG_WIDTH  = 11;  // width of tag
   parameter    RT_TAG_WIDTH    = 13;  // width of the RT FIFO before including
   parameter    MEMC_BURST_LENGTH = `MEMC_BURST_LENGTH;
   parameter    OCCAP_EN        = 0;
   parameter    OCCAP_PIPELINE_EN = 0;
   parameter    NUM_RANKS       = `MEMC_NUM_RANKS;
   parameter    RANK_BITS       = `MEMC_RANK_BITS;
   // "partial/non-block" indicator
   // put the tag in low-order FIFO bits and the non-block/partial indicator
   //  in the upper-most bit
   localparam   RT_TAGLSB    = 0;
   localparam   RT_TAGMSB    = RT_TAG_WIDTH-1;
   localparam   RT_NBLK_BIT_LSB  = RT_TAG_WIDTH;
   localparam   RT_NBLK_BIT_MSB  = RT_NBLK_BIT_LSB + CMD_LEN_BITS - 1;
   localparam   RT_FIFO_DW       = RT_NBLK_BIT_MSB + 1;
   localparam   SL_W             = 8;
   localparam   PARW             = (OCCAP_EN==1) ? ((RT_FIFO_DW%SL_W>0) ? RT_FIFO_DW/SL_W+1 : RT_FIFO_DW/SL_W) : 0;
   localparam   RT_FIFO_DW_PAR   = RT_FIFO_DW+PARW;
   localparam   RDDATA_PER_BYTE_FIFO_AW = 3; // FIFO is 8 deep
   localparam   RDDATA_PER_BYTE_DW = 16; 
   localparam   NBYTES       = PHY_DATA_WIDTH/(RDDATA_PER_BYTE_DW*FREQ_RATIO);
   localparam   RDDATA_PER_BYTE_DBIW = PHY_DBI_WIDTH/(NBYTES*FREQ_RATIO);           
   localparam   ADJ_DATA_WIDTH = 0;
   localparam   ADJ_DBI_WIDTH  = 0;
   localparam   HBW_INVALID_DATA_WIDTH =  (`MEMC_DRAM_DATA_WIDTH-ADJ_DATA_WIDTH)/2;
   localparam   HBW_VALID_DATA_WIDTH   =  (`MEMC_DRAM_DATA_WIDTH-ADJ_DATA_WIDTH)/2;
   localparam   QBW_INVALID_DATA_WIDTH = ((`MEMC_DRAM_DATA_WIDTH-ADJ_DATA_WIDTH)*3)/4;
   localparam   QBW_VALID_DATA_WIDTH   =  (`MEMC_DRAM_DATA_WIDTH-ADJ_DATA_WIDTH)/4;
   localparam   HBW_INVALID_DBI_WIDTH  = HBW_INVALID_DATA_WIDTH/8;
   localparam   HBW_VALID_DBI_WIDTH    = HBW_VALID_DATA_WIDTH/8;
   localparam   QBW_INVALID_DBI_WIDTH  = QBW_INVALID_DATA_WIDTH/8;
   localparam   QBW_VALID_DBI_WIDTH    = QBW_VALID_DATA_WIDTH/8;
   localparam   DATA_WIDTH             = `MEMC_DRAM_DATA_WIDTH;
   localparam   DATA_WIDTH_TOTAL       = `MEMC_DRAM_DATA_WIDTH + `MEMC_DRAM_ECC_WIDTH;
   localparam   ECC_DATA_WIDTH         = `MEMC_DRAM_ECC_WIDTH+ADJ_DATA_WIDTH;
   localparam   DBI_WIDTH              = DATA_WIDTH/8;
   localparam   DBI_WIDTH_TOTAL        = DATA_WIDTH_TOTAL/8;
   localparam   ECC_DBI_WIDTH          = ECC_DATA_WIDTH/8;
   localparam   RDATA_VLD_WIDTH        = (PHY_DATA_WIDTH/16)/4;
   localparam   HBW_INVALID_DATA_VLD_WIDTH = RDATA_VLD_WIDTH/2;
   localparam   HBW_VALID_DATA_VLD_WIDTH   = RDATA_VLD_WIDTH/2;
   localparam   QBW_INVALID_DATA_VLD_WIDTH = (3*RDATA_VLD_WIDTH)/4;
   localparam   QBW_VALID_DATA_VLD_WIDTH   = RDATA_VLD_WIDTH/4;

   input            co_yy_clk;              // clock
   input            core_ddrc_rstn;         // asynchronous negative-edge reset
   input            ddrc_cg_en;             // clock gating enable signal
   input            reg_ddrc_occap_en;
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
   input            reg_ddrc_occap_en_r;
//spyglass enable_block W240
   output           ddrc_occap_rtfifo_parity_err;
   output           ddrc_occap_rtctrl_parity_err;

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: LPDDR4 1:4 config only supports BL16. This register definition will be changed.
   input [3:0]      dh_rt_burst_rdwr;       // 4'h0010=burst of 4 data read/write
                                            // 4'h0100=burst of 8 data read/write
                                            // 4'h1000=burst of 16 data read/write
//spyglass enable_block W240
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in MEMC_FREQ_RATIO_4 config. uMCTL5 will support MEMC_FREQ_RATIO_4 only.
   input [1:0]      dh_rt_data_bus_width;   // 00=FULL; 01==HALF; 10==QUARTER;
//spyglass enable_block W240
   input            dh_rt_frequency_ratio;  // 1 - 1:4 mode, 0 - 1:2 mode

   output           rt_rd_rd_mrr_sod;

   input            dh_rt_lpddr4;
   input            reg_ddrc_lpddr5;
   input            pi_rt_rd_vld;         // read valid to response tracker
   // all other pi_rt_* signals are qualified by pi_rt_rd_vld
   input [CMD_LEN_BITS-1:0] pi_rt_rd_partial;  // nonblock read
   input [RT_TAG_WIDTH-1:0] pi_rt_rd_tag;      // PPW, token[7:0] & source[3:0]   
   input [PHY_DATA_WIDTH/16-1:0]      ph_rt_rdatavld;    // valid data indicator output from PHY
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
   input                       reg_ddrc_rd_dbi_en;
//spyglass enable_block W240
   input [PHY_DBI_WIDTH-1:0]   ph_rt_rdbi_n;   // valid dbi output from PHY
   input [PHY_DATA_WIDTH-1:0]  ph_rt_rdata;    // valid data output from PHY
   output [PHY_DBI_WIDTH-1:0]  rt_rd_rdbi_n;
   output [PHY_DATA_WIDTH-1:0] rt_rd_rdata;
   output                      rt_rd_rd_valid;    // valid output from read after tracker
   wire                        rt_rd_rd_valid;    // also used internally
   output                      rt_rd_eod;         // end-of-data (last data xfer for this read)
   wire                        rt_rd_eod;         // also used internally
   output [CMD_LEN_BITS-1:0]   rt_rd_rd_partial;  // read is a partial (single-word)
   output [RT_TAG_WIDTH-1:0]   rt_rd_rd_tag;      // read tag bits: PPW, token[7:0], source[3:0]
   output                      rt_gs_empty;       // RT FIFO is empty

   output                      rt_gs_empty_delayed;    // RT FIFO empty delayed version used in clock gating logic in ECC scrub case


`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS
   //------------------------- WIRES AND REGISTERS --------------------------------

   wire [RT_FIFO_DW-1:0]  fifo_inputs;        // entry to loaded into FIFO (includes "partial")
   wire [RT_FIFO_DW_PAR-1:0]  fifo_inputs_par;        // entry to loaded into FIFO (includes "partial")
   wire [RT_FIFO_DW-1:0]  fifo_output_stage;  // FIFO entry that will be output (includes "partial")
   wire [RT_FIFO_DW-1:0]  i_fifo_output_stage;  // FIFO entry that will be output (includes "partial")
   wire [RT_FIFO_DW_PAR-1:0]  fifo_output_stage_par;  // FIFO entry that will be output (includes "partial")
   wire [5:0]             load_ptr_inc;       // incremented load pointer
   wire [5:0]             load_ptr_nxt;       // next value of the load pointer
   wire [5:0]             unload_ptr_inc;     // incremented unload pointer
   wire [5:0]             unload_ptr_nxt;     // next value of the unload pointer
   wire                   rd_valid_out;       // valid FIFO output (for RA, WU)
   wire                   rd_eod;             // end-of-data at FIFO output (for RA, WU)

   integer    i;    // for loop index for pipeline and elsewhere

   reg  [5:0]  load_ptr;                // pointer to next available entry in
                                        //  FIFO (no wrap bit needed because the
                                        //  FIFO pop is self-timed, preventing
                                        //  it from over-filling)
   reg  [5:0]  unload_ptr;    // pointer to get output from FIFO 
   reg  [RT_FIFO_DW_PAR-1:0]  fifo_ram  [(`MEMC_RT_FIFO_DEPTH-1):0];

   // FIFO of read command info
   // Max word_count=32 
   wire [4:0] inc_word_count;    // word count incremented for next data xfer 
   reg  [4:0] word_count;        // count the words transfered for each write 
   reg  [4:0] inc_word_count_by; // amount to increment word by each time 

   reg  [2:0] drop_data;         // 1=extra data returned from PHY; to be ignored 

   reg  [7:0] fifo_reset_timer;  // timer gets initialized whenever a rd command is issued to the phy
                                        // it is decremented every clock there after
                                        // when the timer is at 0, both load_ptr and unload_ptr is reset to 0
                                        // this allows rt to recover in case PHY doesn't return data for all
                                        // the read commands that was presented to it
   wire       fifo_reset;        // timer expires and no new reads: reset the FIFO pointers

   reg  [2:0]   mrr_cycles;             // Count of MRR data cycles 
   wire         rd_mrr;                 // in LPDDR4 designs, indicates that the read is a MR Read
   wire         mrr_eod;                // goes high in the second cycle of rdatavld during MRR operation
   

   wire         mrr_sod;                // goes high for first rdatavld of MRR (sod=Start of data)
   wire         mrr_eod_lpddr4;
   wire         mrr_sod_lpddr4;
   wire         lpddr_mode;
   assign lpddr_mode = dh_rt_lpddr4 | reg_ddrc_lpddr5;

   reg                         rt_gs_empty_r;


   //------------------------ READ TIMING LOGIC -----------------------------------

   wire [NBYTES-1:0]          mux_rt_rdatavld;    // valid data indicator output from PHY
   wire [PHY_DBI_WIDTH-1:0]   mux_rt_rd_rdbi_n;   // valid dbi output from PHY
   wire [PHY_DATA_WIDTH-1:0]  mux_rt_rd_rdata;    // valid data output from PHY

wire                   rdatavld;

assign mux_rt_rdatavld = ph_rt_rdatavld[NBYTES-1:0];
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(2*DATA_WIDTH)' found in module 'rt'
//SJ: 7*DATA_WIDTH value is always smaller than ph_rt_rdata width.

   wire dbi_mask_value;
   assign dbi_mask_value = 1'b0;
 //`ifdef MEMC_SIDE
       assign mux_rt_rd_rdata = {
                                 (dh_rt_data_bus_width == 2'b10) ? { 
                                                                      {QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(7*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                     ,{QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(6*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                     ,{QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(5*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                     ,{QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(4*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH],
                                                                      {QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(3*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                     ,{QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(2*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                     ,{QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(1*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                     ,{QBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(0*DATA_WIDTH)+:QBW_VALID_DATA_WIDTH]
                                                                   } :// QBW
                                 (dh_rt_data_bus_width == 2'b01) ? { 
                                                                      {HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(7*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                     ,{HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(6*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                     ,{HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(5*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                     ,{HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(4*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH],
                                                                      {HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(3*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                     ,{HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(2*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                     ,{HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(1*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                     ,{HBW_INVALID_DATA_WIDTH{1'b0}},ph_rt_rdata[(0*DATA_WIDTH)+:HBW_VALID_DATA_WIDTH]
                                                                   } : // HBW
                                                                       ph_rt_rdata
                                                                   }; // FBW


       assign mux_rt_rd_rdbi_n = {
                                  (dh_rt_data_bus_width == 2'b10) ? { 
                                                                       {QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(7*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                      ,{QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(6*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                      ,{QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(5*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                      ,{QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(4*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH],
                                                                       {QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(3*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                      ,{QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(2*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                      ,{QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(1*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                      ,{QBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(0*DBI_WIDTH)+:QBW_VALID_DBI_WIDTH]
                                                                    } :// QBW
                                  (dh_rt_data_bus_width == 2'b01) ? { 
                                                                       {HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(7*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                      ,{HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(6*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                      ,{HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(5*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                      ,{HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(4*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH],
                                                                       {HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(3*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                      ,{HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(2*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                      ,{HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(1*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                      ,{HBW_INVALID_DBI_WIDTH{dbi_mask_value}},ph_rt_rdbi_n[(0*DBI_WIDTH)+:HBW_VALID_DBI_WIDTH]
                                                                    } : // HBW
                                                                        ph_rt_rdbi_n
                                                                    }; // FBW




//spyglass enable_block SelfDeterminedExpr-ML


  assign rdatavld    = mux_rt_rdatavld[0];
  assign rt_rd_rdata = mux_rt_rd_rdata;
  assign rt_rd_rdbi_n = mux_rt_rd_rdbi_n;



   //---------------------- END READ TIMING LOGIC ---------------------------------
   //
   //--------------------------- FIFO INPUTS --------------------------------------
   assign fifo_inputs  = {pi_rt_rd_partial, pi_rt_rd_tag};
//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index 'unload_ptr' of width '6' is larger than the width '5' required for the max value '31' of the signal 'fifo_ram'
//SJ: Index width is '6' to be able to cover all values of `MEMC_RT_FIFO_DEPTH which is what determines the width of 'fifo_ram'. Index never gets assigned value that is too big. Protected by code at line 714 (assignment of unload_ptr_inc).
   assign fifo_output_stage_par = fifo_ram[unload_ptr];
//spyglass enable_block ImproperRangeIndex-ML

   wire fifo_push;
   wire fifo_pop;

   assign fifo_push        = pi_rt_rd_vld ? 1'b1 : 1'b0;

   assign fifo_pop      = ((rd_eod & rd_valid_out) || (rd_mrr & mrr_eod)) ? 1'b1 : 1'b0;
   
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in different generate statements and therefore must always exist
   wire par_en = reg_ddrc_occap_en;
//spyglass enable_block W528   
   wire par_err;

   // drive output
   assign ddrc_occap_rtfifo_parity_err = par_err;

   generate
   if (OCCAP_EN==1) begin: PAR_check

      wire [PARW-1:0] parity_dummy, mask_in;

      wire [PARW-1:0] din_par, dout_par, parity_err;
      wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;
      wire pgen_en, pcheck_en;

      assign parity_dummy  = {PARW{1'b1}};
      assign mask_in       = {PARW{1'b1}};

      wire poison_en       = 1'b0;

      assign pgen_en    = fifo_push;
      assign pcheck_en  = par_en & fifo_pop;


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (RT_FIFO_DW),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (fifo_inputs),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (din_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (RT_FIFO_DW),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (i_fifo_output_stage),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (dout_par), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );

      assign fifo_inputs_par = {fifo_inputs,din_par};
      assign {i_fifo_output_stage,dout_par} = fifo_output_stage_par;

         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg par_err_r;
           always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin : par_err_r_PROC
             if (~core_ddrc_rstn) begin
               par_err_r <= 1'b0;
             end else begin
               par_err_r <= |parity_err;
             end
           end

           assign par_err = par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign par_err = |parity_err; 

         end

    end // PAR_check
    else begin: OCCAP_dis_par_check
   
      assign par_err = 1'b0;
      assign fifo_inputs_par = fifo_inputs;
      assign i_fifo_output_stage = fifo_output_stage_par;

    end // OCCAP_dis_par_check
   endgenerate



   //---------------- ASSIGN OUTPUTS (AND SUPPORTING LOGIC) -----------------------
   
   // inc_word_count_by is dependent on MEMC_WRDATA_*_CYCLES and dh_rt_data_bus_width
   // rd_eod_word_count_nomsb_last==1 if word_count[3:0] (i.e. no MSB) is
   // equal to value that denotes
   wire [3:0] rd_eod_word_count_m1_db = ~inc_word_count_by[3:0] + 4'b0001;
   wire       rd_eod_word_count_nomsb_last = (word_count[3:0]==rd_eod_word_count_m1_db) ? 1'b1 : 1'b0;
      wire       rd_eod_word_count_nomsb_last_quarter = 1'b0;

   assign rd_eod       = rdatavld & (~rd_mrr) & ((rd_eod_word_count_nomsb_last & (rt_rd_rd_partial[CMD_LEN_BITS-1] | word_count[4]))  
                                                               | (rd_eod_word_count_nomsb_last_quarter & (rt_rd_rd_partial[0]))
                                              );
   assign rd_valid_out = rdatavld & (~(|drop_data));

   assign rt_rd_rd_valid    = rd_valid_out;
   assign rt_rd_eod         = rd_eod;

   wire  word_count_neq0    = (|word_count); // word_count is !=0
   
   assign fifo_output_stage  = i_fifo_output_stage;
     

   assign rt_rd_rd_partial   = fifo_output_stage[RT_NBLK_BIT_MSB:RT_NBLK_BIT_LSB];
   
   assign rt_rd_rd_tag        = fifo_output_stage[RT_TAGMSB:RT_TAGLSB];

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(CORE_TAG_WIDTH + 1)' found in module 'rt'
//SJ: This coding style is acceptable and there is no plan to change it.
    
   // OR of the 2 mrr bits coming from PHY - rd_mrr and rd_mrr_ext
   // this indicates that the current read is MRR and not regular read
   // this is used in the drop_data logic - during MRR drop_data shouldn't get set
   assign rd_mrr             = |fifo_output_stage[CORE_TAG_WIDTH+1:CORE_TAG_WIDTH] ;
//spyglass enable_block SelfDeterminedExpr-ML

   //---------------------------- COMBINATORIAL LOGIC -----------------------------

   assign fifo_reset        = ((fifo_reset_timer == 8'b000_0000) & (~pi_rt_rd_vld)) ;


   assign load_ptr_inc        = (load_ptr == (`MEMC_RT_FIFO_DEPTH-1'b1)) ?
                                6'h0 : (load_ptr + 6'h01) ;
   assign load_ptr_nxt        = (fifo_push) ? load_ptr_inc : (fifo_reset ? 6'h0 : load_ptr);
   assign unload_ptr_inc      = (unload_ptr == (`MEMC_RT_FIFO_DEPTH-1'b1)) ?
                                6'h0 : (unload_ptr + 6'h01) ;
   assign unload_ptr_nxt      = (fifo_pop) ? unload_ptr_inc : (fifo_reset ? 6'h0 : unload_ptr);
   
   //spyglass disable_block W164a
   //SMD: LHS: 'inc_word_count' width 5 is less than RHS: '(word_count + inc_word_count_by)' width 6 in assignment
   //SJ: Overflow not possible
   assign inc_word_count      = word_count + inc_word_count_by;
   //spyglass enable_block W164a



  // Choose betweem LPDDR4 based on sw bit
  // rdatavld cycle for MPR read in DDR4 is same as MRR  
  assign mrr_eod = 
                   (lpddr_mode) ? mrr_eod_lpddr4 :
                                  1'b0;



// rdatavld is 4 cycle in HS or 8 cycles in FS for MRR in LPDDR4. this logic asserts the eod in the 2nd cycle
  assign mrr_eod_lpddr4 = (dh_rt_frequency_ratio)
                          ? rdatavld && (mrr_cycles[0]   == 1'b1) && (~(|drop_data))
                          : rdatavld && (mrr_cycles[1:0] == 2'b11) && (~(|drop_data));
  assign mrr_sod_lpddr4 = (dh_rt_frequency_ratio)
                          ? rdatavld && (mrr_cycles[0] == 1'b0) && (~(|drop_data))
                          : rdatavld && (mrr_cycles[1:0] == 2'b00) && (~(|drop_data));

  assign mrr_sod = (lpddr_mode) ? mrr_sod_lpddr4 : 1'b0;

  assign rt_rd_rd_mrr_sod = mrr_sod;


        // wait for entire read phase to complete, even if data interested
        // in has completed (eod) - hence wait for drop_data to go to 0.  This is necessary to avoid
        // ddrc_dfi_ctrlupd_req signals on DFI interface when phy_dfi_rddata_valid is still high
   wire rt_gs_empty_nxt;
  // FIXME: drop_data is always 0 - Required Data size on HIF is same as data size on DFI from PHY when RD, DDR4-MPR and DDR5-MRR
  //ccx_cond: ; 1; 10; drop_data is always 0 - Required Data size on HIF is same as data size on DFI from PHY when DDR5-MRR. See bug 11948
  assign rt_gs_empty_nxt   = (load_ptr_nxt == unload_ptr_nxt) ? ~rdatavld && (drop_data == 3'b000): 
                                   1'b0;

 // load the timer when a read command is received. decrement by 1 every clock afterwards and stop at 0.
  // when it is at zero, load_ptr and unload_ptr are reset. this is used for error recovery when the phy doesn't
  // return read data for every read command 
  wire [7:0] fifo_reset_timer_nxt;
  assign fifo_reset_timer_nxt  = (pi_rt_rd_vld) ?  8'hFF : ((fifo_reset_timer != 8'h0) ? (fifo_reset_timer - 8'h01) : fifo_reset_timer);

  
   //---------------------------------- FLOPS -------------------------------------


assign rt_gs_empty = rt_gs_empty_r;


// This set of registers are not clock gated
// The fifo reset timer is active for 128 clocks after the last read from the FIFO
// Then the fifo pointers are reset and that is used for setting the rt_gs_empty signal as well.
// So these signals have to be active long after the actual last read out of the FIFO and hence
// cannot be clock gated with the generic clock gating signal
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     if (~core_ddrc_rstn) begin
  load_ptr      <= 6'h0;
  unload_ptr    <= 6'h0;
  rt_gs_empty_r <= 1'b0;
  fifo_reset_timer  <= 8'h0;
     end 
     else begin
  load_ptr      <= load_ptr_nxt;
  unload_ptr    <= unload_ptr_nxt;
  
  rt_gs_empty_r <= rt_gs_empty_nxt;


  fifo_reset_timer  <= fifo_reset_timer_nxt;
     end


// 


      // word_count is 32 always
      wire [4:0] inc_word_count_by_nxt;
      assign inc_word_count_by_nxt = 5'b01000 << dh_rt_frequency_ratio ; 


      // increment at the start of a read; keep incrementing till
      //  word_count wraps back to zero
      //  or a new read comes along (which may happen after a non-block read)
      //  hold at zero when dropping data (for non-block reads in full bus width mode)
      wire [4:0] word_count_r_nxt;
      assign word_count_r_nxt   =
                                  ((rd_eod & rdatavld) | (|drop_data)) ? 5'b0           :
                                  (rdatavld & (~rd_mrr))               ? inc_word_count :
                                                                         word_count     ;

reg [2:0] mrr_cycles_nxt;
always @(*) begin : mrr_cycles_nxt_PROC
      if (rdatavld & (~rd_mrr))
          mrr_cycles_nxt = 3'b000;
      else if (rdatavld && (drop_data == 3'b000))
          mrr_cycles_nxt = mrr_cycles + 3'b001;
      else
          mrr_cycles_nxt = mrr_cycles;       
end

wire [2:0] drop_data_nxt;
      // Drop data logic looks complicated right now. It can be simplified as follows.
      // Summarized as related to any "Partial Read" that returns more data than
      // what is required on HIF
      // Depends on MEMC_BURST_LENGTH
      // Corresponds to Tables in Databook
      //
      // Note subtraction of 2 or 4, depending on FREQ_RATIO as each DFI beats is
      // 2 or 4 Columns respectively
assign drop_data_nxt = ((|drop_data) & rdatavld) ? (drop_data - (3'b010 << dh_rt_frequency_ratio) ) :
                                   // MEMC_BL=16, FBW, BL16, Quarter Read results in loss of bandwidth => drop BL12 worth of data received on DFI
           // drop when word_count!=0
                                   // 1:4 mode does not support Quarter Read
                                   // MEMC_BL=16, FBW, BL16, Partial Read results in loss of bandwidth => drop BL8 worth of data received on DFI
           // drop when word_count!=0
                                   (((dh_rt_frequency_ratio) ? (~word_count_neq0 & (word_count[4:3] == 2'b00)) : (word_count_neq0 & (word_count[4:3] == 2'b01)))
                                    & rdatavld & rd_eod & (~rd_mrr)) ? 3'b100 :


                                   // LPDDR4 1:4 mode does not support

                     drop_data           ;


// Flops that can be clock gated in this module
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     if (~core_ddrc_rstn) begin
       inc_word_count_by <= 5'b0000;
       word_count        <= 5'b0000;
       mrr_cycles        <= 3'b000;
       drop_data         <= 3'b000;
     end
     else if(ddrc_cg_en) begin
      
       inc_word_count_by <= inc_word_count_by_nxt;

       word_count        <= word_count_r_nxt;
        
       mrr_cycles        <= mrr_cycles_nxt;

       drop_data         <= drop_data_nxt;
       
       
     end // else: not in reset


// Delaying rt_gs_empty by 8 clocks
// This signal will be used in the clock gating enable logic to handle the ECC scrubs
// rt_gs_empty indicates that the read data has arrived for all the read requests
// if a single-bit ECC error happens and a ECC scrub is to be issued, there should be
// some signal to tell the clock gating logic to not gate the clock until the scrub 
// request has also gone through. If this isn't used, then the clock will be gated 
// before scrub request is issued from WU module and hence the scrub will be missed
// 8 cycle is more than enough to cover the number cycles after the RT FIFO goes empty
// to the time when the scrub request is issued from WU
reg [7:0] shift_rt_gs_empty; 
wire rt_gs_empty_delayed;

 always @(posedge co_yy_clk or negedge core_ddrc_rstn)
  begin :  rt_gs_empty_PROC
    if (!core_ddrc_rstn) begin
      shift_rt_gs_empty <= 8'b0;
    end else if(ddrc_cg_en) begin
      shift_rt_gs_empty[0]   <= rt_gs_empty;
      shift_rt_gs_empty[7:1] <= shift_rt_gs_empty[6:0];
    end
  end

assign rt_gs_empty_delayed = shift_rt_gs_empty[7];

   always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
     if (~core_ddrc_rstn) begin
  for (i=0; i<`MEMC_RT_FIFO_DEPTH; i=i+1) begin
     fifo_ram [i]  <= {(RT_FIFO_DW_PAR){1'b0}};
  end
     end
     else if(ddrc_cg_en) begin
//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index 'load_ptr' of width '6' is larger than the width '5' required for the max value '31' of the signal 'fifo_ram'
//SJ: Index width is '6' to be able to cover all values of `MEMC_RT_FIFO_DEPTH which is what determines the width of 'fifo_ram'. Index never gets assigned value that is too big. Protected by code at line 707 (assignment of load_ptr_inc)
     fifo_ram[load_ptr] <= fifo_inputs_par;
//spyglass enable_block ImproperRangeIndex-ML
  end // else: not in reset


  //
  // Control logic for rt module 
  // protect by following method:
  // - combining into one bus (nxt_bus) the nxt version of a number of unprotected
  //   control registers
  // - pgen on this combined bus
  // - register the parity information
  // - combine into one bus (curr_bus) the current version of number of unprotected
  //   control registers
  // - pcheck on this curr_bus with registered version of prevv generated
  //   parity info
  //
  // Certain signals are reordered to allow them to be used in concat:
  // - i_ph_rt_rdbi_n_lwr_stored -> i_ph_rt_rdbi_n_lwr_stored_w
  // - i_rt_ptr -> i_rt_ptr_w


  localparam CTRL_W =
                     NBYTES + //  i_rt_ptr
                     NBYTES*RDDATA_PER_BYTE_DBIW + // i_ph_rt_rdbi_n_lwr_stored
                     6 +   // load_ptr
                     6 +   // unload_ptr
                     1 +   // rt_gs_empty
                     8 +   // fifo_reset_timer
                     5 + // inc_word_count_by
                     5 + // word_count
                     3 + // drop_data
                     3 + // mrr_cycles
                     8 // shift_rt_gs_empty
                     ;

  localparam   CTRL_PARW             = (OCCAP_EN==1) ? ((CTRL_W%SL_W>0) ? CTRL_W/SL_W+1 : CTRL_W/SL_W) : 0;


 wire ctrl_par_err;

 // drive output
 assign ddrc_occap_rtctrl_parity_err = ctrl_par_err;

 generate
   if (OCCAP_EN==1) begin: OCCAP_en

      // 
      // control signals of pgen/pcheck
      //

      wire [CTRL_PARW-1:0] ctrl_parity_dummy, ctrl_mask_in;

      wire [CTRL_PARW-1:0] ctrl_pgen_in_par, ctrl_parity_err;
      wire [CTRL_PARW-1:0] ctrl_pgen_parity_corr_unused, ctrl_pcheck_parity_corr_unused;
      reg  [CTRL_PARW-1:0] ctrl_pgen_in_par_r;
      
      wire ctrl_pgen_en, ctrl_pcheck_en;

      assign ctrl_parity_dummy  = {CTRL_PARW{1'b1}};
      assign ctrl_mask_in       = {CTRL_PARW{1'b1}};

      wire   ctrl_poison_en     = 1'b0;

      assign ctrl_pgen_en    = par_en;

      wire par_en_r = reg_ddrc_occap_en_r;
      
      // only check if par_en has been enabled for a cycle as pgen only
      // operates if par_en=1
      assign ctrl_pcheck_en  = par_en_r & par_en;


//
// additional signal to re-order to allow use in concat for
// ctrl_pgen_in/ctrl_pcheck_in
//

  wire [PHY_DATA_WIDTH/16-1:0]      ph_rt_rdatavld_w;    // valid data indicator output from PHY
  wire [`MEMC_FREQ_RATIO-1:0] i_ph_rt_rdatavld[NBYTES-1:0];

  reg  i_rt_ptr[NBYTES-1:0];
  wire i_rt_ptr_nxt[NBYTES-1:0];
  

// internal signals used for generation of i_rt_ptr_nxt[]
  wire i_ph_rt_rdatavld_and[NBYTES-1:0];
  wire i_ph_rt_rdatavld_xor[NBYTES-1:0];
  
  
  wire [RDDATA_PER_BYTE_DBIW-1:0] i_ph_rt_rdbi_n_lwr[NBYTES-1:0];
  reg  [RDDATA_PER_BYTE_DBIW-1:0]  i_ph_rt_rdbi_n_lwr_stored[NBYTES-1:0];
  reg  [RDDATA_PER_BYTE_DBIW-1:0]  i_ph_rt_rdbi_n_lwr_stored_nxt[NBYTES-1:0];

//mask the unused data lane read data valid.
       assign ph_rt_rdatavld_w = {
                                  (dh_rt_data_bus_width == 2'b10) ? { 
                                                                       {QBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(3*RDATA_VLD_WIDTH)+:QBW_VALID_DATA_VLD_WIDTH]
                                                                      ,{QBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(2*RDATA_VLD_WIDTH)+:QBW_VALID_DATA_VLD_WIDTH]
                                                                      ,{QBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(1*RDATA_VLD_WIDTH)+:QBW_VALID_DATA_VLD_WIDTH]
                                                                      ,{QBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(0*RDATA_VLD_WIDTH)+:QBW_VALID_DATA_VLD_WIDTH]
                                                                    } :// QBW
                                  (dh_rt_data_bus_width == 2'b01) ? { 
                                                                       {HBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(3*RDATA_VLD_WIDTH)+:HBW_VALID_DATA_VLD_WIDTH]
                                                                      ,{HBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(2*RDATA_VLD_WIDTH)+:HBW_VALID_DATA_VLD_WIDTH]
                                                                      ,{HBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(1*RDATA_VLD_WIDTH)+:HBW_VALID_DATA_VLD_WIDTH]
                                                                      ,{HBW_INVALID_DATA_VLD_WIDTH{1'b0}},ph_rt_rdatavld[(0*RDATA_VLD_WIDTH)+:HBW_VALID_DATA_VLD_WIDTH]
                                                                    } : // HBW
                                                                    ph_rt_rdatavld
                                                                    }; // FBW

genvar gen_align_hdr;

for (gen_align_hdr=0; gen_align_hdr<NBYTES; gen_align_hdr=gen_align_hdr+1)
begin : align_hdr

   // reduced to 1 or 2 bits rddatavld
   // Original case used before MEMC_DFI_RDDATA_PER_BYTE_1 added
   // 

   assign i_ph_rt_rdatavld[gen_align_hdr][0] = ph_rt_rdatavld_w[gen_align_hdr+:1]; // bit n of lower lane
   assign i_ph_rt_rdatavld[gen_align_hdr][1] = ph_rt_rdatavld_w[NBYTES+gen_align_hdr+:1]; // corresponding bit of upper lane
   assign i_ph_rt_rdatavld[gen_align_hdr][2] = ph_rt_rdatavld_w[2*NBYTES+gen_align_hdr+:1]; // bit n of lower lane
   assign i_ph_rt_rdatavld[gen_align_hdr][3] = ph_rt_rdatavld_w[3*NBYTES+gen_align_hdr+:1]; // corresponding bit of upper lane


   // Laways output current value on upper lane
   // rdvalid[1:0] | i_rt_ptr | i_rt_ptr_nxt | i_ph_rt_rdata_lwr_stored | Output lwr | i_rdatavld
   //       11     |    0     |      0       |          0               | current    |     1
   //       01     |    0     |      1       |          1               |     X      |     0
   //       11     |    1     |      1       |          1               | stored     |     1
   //       10     |    1     |      0       |          0               | stored     |     1
   //       10     |    0     |    illegal
   //       01     |    1     |    illegal
   //


   // i_rt_ptr gotten from i_rt_ptr_nxt
   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
     if (~core_ddrc_rstn) begin
       i_rt_ptr[gen_align_hdr] <= 1'b0;
     end else begin
      i_rt_ptr[gen_align_hdr]  <= i_rt_ptr_nxt[gen_align_hdr];
     end
   end

   // internal signals used for generation of i_rt_ptr_nxt
   assign i_ph_rt_rdatavld_and[gen_align_hdr] = &i_ph_rt_rdatavld[gen_align_hdr];
   assign i_ph_rt_rdatavld_xor[gen_align_hdr]= ^i_ph_rt_rdatavld[gen_align_hdr];

   //  i_rt_ptr_nxt depends on current value of i_rt_ptr and ph_rt_rdatavld
   //  Use bitwise AND of ph_rt_rdatavld if i_rt_ptr=1
   //  Use bitwise XOR of ph_rt_rdatavld if i_rt_ptr=0
   assign i_rt_ptr_nxt[gen_align_hdr] = (i_rt_ptr[gen_align_hdr]) ? i_ph_rt_rdatavld_and[gen_align_hdr] : i_ph_rt_rdatavld_xor[gen_align_hdr];
   

   // output from SDR adjustment logic is value
   // only if i_ph_rt_rdatavld[x][1]=1

   assign i_ph_rt_rdbi_n_lwr[gen_align_hdr][0+:RDDATA_PER_BYTE_DBIW/2]                      = ph_rt_rdbi_n[gen_align_hdr*RDDATA_PER_BYTE_DBIW/2+:RDDATA_PER_BYTE_DBIW/2];
   assign i_ph_rt_rdbi_n_lwr[gen_align_hdr][RDDATA_PER_BYTE_DBIW/2+:RDDATA_PER_BYTE_DBIW/2] = ph_rt_rdbi_n[gen_align_hdr*RDDATA_PER_BYTE_DBIW/2 + NBYTES*RDDATA_PER_BYTE_DBIW/2+:RDDATA_PER_BYTE_DBIW/2];
    



   always @(*) begin : i_ph_rt_rdbi_n_lwr_stored_nxt_PROC
     if (i_rt_ptr_nxt[gen_align_hdr]) begin
       i_ph_rt_rdbi_n_lwr_stored_nxt[gen_align_hdr] = i_ph_rt_rdbi_n_lwr[gen_align_hdr];
     end else begin
       i_ph_rt_rdbi_n_lwr_stored_nxt[gen_align_hdr] = i_ph_rt_rdbi_n_lwr_stored[gen_align_hdr];

     end
   end
   

   always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
     if (~core_ddrc_rstn) begin
       i_ph_rt_rdbi_n_lwr_stored[gen_align_hdr] <= {RDDATA_PER_BYTE_DBIW{1'b0}};
     end else begin

       i_ph_rt_rdbi_n_lwr_stored[gen_align_hdr] <= i_ph_rt_rdbi_n_lwr_stored_nxt[gen_align_hdr];
     end
   end
   
end


  reg [NBYTES-1:0] i_rt_ptr_nxt_w;
  reg [NBYTES-1:0] i_rt_ptr_w;

  always @ (*) begin : i_rt_ptr_w_PROC
  integer nbytes_count;
   for (nbytes_count=0; nbytes_count<NBYTES; nbytes_count=nbytes_count+1) begin
      i_rt_ptr_nxt_w[nbytes_count] = i_rt_ptr_nxt[nbytes_count];
      i_rt_ptr_w[nbytes_count]     = i_rt_ptr[nbytes_count];
    end
  end



reg reg_ddrc_rd_dbi_en_r;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    reg_ddrc_rd_dbi_en_r <= 1'b0;
  end else begin
    reg_ddrc_rd_dbi_en_r <= reg_ddrc_rd_dbi_en;
  end
end

reg  [NBYTES*RDDATA_PER_BYTE_DBIW-1:0]  i_ph_rt_rdbi_n_lwr_stored_nxt_w;
reg  [NBYTES*RDDATA_PER_BYTE_DBIW-1:0]  i_ph_rt_rdbi_n_lwr_stored_w;

  always @ (*) begin : i_ph_rt_rdbi_n_lwr_stored_w_PROC
  integer nbytes_count;
    for (nbytes_count=0; nbytes_count<NBYTES; nbytes_count=nbytes_count+1) begin
      if (reg_ddrc_rd_dbi_en==1'b0) begin
        i_ph_rt_rdbi_n_lwr_stored_nxt_w[nbytes_count*RDDATA_PER_BYTE_DBIW+:RDDATA_PER_BYTE_DBIW] = {RDDATA_PER_BYTE_DBIW{1'b0}};
      end else begin
        i_ph_rt_rdbi_n_lwr_stored_nxt_w[nbytes_count*RDDATA_PER_BYTE_DBIW+:RDDATA_PER_BYTE_DBIW] = i_ph_rt_rdbi_n_lwr_stored_nxt[nbytes_count];
      end

      if (reg_ddrc_rd_dbi_en_r==1'b0) begin
        i_ph_rt_rdbi_n_lwr_stored_w[nbytes_count*RDDATA_PER_BYTE_DBIW+:RDDATA_PER_BYTE_DBIW]     = {RDDATA_PER_BYTE_DBIW{1'b0}};
      end else begin
        i_ph_rt_rdbi_n_lwr_stored_w[nbytes_count*RDDATA_PER_BYTE_DBIW+:RDDATA_PER_BYTE_DBIW]     = i_ph_rt_rdbi_n_lwr_stored[nbytes_count];
      end
    end
  end


// 
// concat signals for pgen/pcheck
//

      wire  [CTRL_W-1:0] ctrl_pgen_in;
      wire  [CTRL_W-1:0] ctrl_pcheck_in;

    // generate concat bus of signals to pgen
 assign ctrl_pgen_in = {
                       i_rt_ptr_nxt_w,
                       i_ph_rt_rdbi_n_lwr_stored_nxt_w,
                       load_ptr_nxt,
                       unload_ptr_nxt,
                       rt_gs_empty_nxt,
                       fifo_reset_timer_nxt,
                       inc_word_count_by_nxt,
                       word_count_r_nxt,
                       drop_data_nxt,
                       mrr_cycles_nxt,
                       shift_rt_gs_empty[6:0], rt_gs_empty
                     };
    // generate concat bus of signals to pcheck                   
 assign ctrl_pcheck_in = {
                       i_rt_ptr_w,
                       i_ph_rt_rdbi_n_lwr_stored_w,
                       load_ptr,
                       unload_ptr,
                       rt_gs_empty_r,
                       fifo_reset_timer,
                       inc_word_count_by,
                       word_count,
                       drop_data,
                       mrr_cycles,
                       shift_rt_gs_empty
                     };



         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (CTRL_W), 
            .CALC    (1), // parity calc
            .PAR_DW  (CTRL_PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (ctrl_pgen_in),
            .parity_en     (ctrl_pgen_en),
            .parity_type   (ctrl_poison_en),
            .parity_in     (ctrl_parity_dummy),
            .mask_in       (ctrl_mask_in),
            .parity_out    (ctrl_pgen_in_par), // parity out
            .parity_corr   (ctrl_pgen_parity_corr_unused) //not used
         );



         always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
           if (~core_ddrc_rstn) begin
             ctrl_pgen_in_par_r <= {CTRL_PARW{1'b0}};
           end else begin
             ctrl_pgen_in_par_r <= ctrl_pgen_in_par;
           end




         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (CTRL_W),
            .CALC    (0), // parity check
            .PAR_DW  (CTRL_PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (ctrl_pcheck_in),
            .parity_en     (ctrl_pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (ctrl_pgen_in_par_r), // parity in
            .mask_in       (ctrl_mask_in),
            .parity_out    (ctrl_parity_err), // parity error
            .parity_corr   (ctrl_pcheck_parity_corr_unused) //not used
         );

              
        if (OCCAP_PIPELINE_EN==1) begin : CTRL_OCCAP_PIPELINE_EN_1

           reg ctrl_par_err_r;
           always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin : ctrl_par_err_r_PROC
             if (~core_ddrc_rstn) begin
               ctrl_par_err_r <= 1'b0;
             end else begin
               ctrl_par_err_r <= |ctrl_parity_err;
             end
           end

           assign ctrl_par_err = ctrl_par_err_r;          

         end else begin : CTRL_OCCAP_PIPELINE_EN_0
         
           assign ctrl_par_err = |ctrl_parity_err; 

         end

    end // OCCAP_en 
    else begin: OCCAP_dis 
   
      assign ctrl_par_err = 1'b0;
    end // OCCAP_dis 
   endgenerate



`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON

reg i_fatl_err_detected;
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
        i_fatl_err_detected <= 1'b0;
//`ifdef DDRCTL_CAPAR_RETRY
//    else if (retry_rt_fatl_err_pulse) 
//          i_fatl_err_detected <= 1'b1;
//`endif
end

localparam RT_FIFO_MARGIN = //RT FIFO entries margin
                            `ifndef VIRL_DFI_RDDATA_UNALIGN
                            4
                            `elsif VIRL_DDR4
                            3
                            `elsif VIRL_DDR2
                            3
                            `else
                            4
                            `endif
                            ;
                                    
// Check that Response Tracker FIFO always has a margin of 3/4 FIFO entries
// After retry fatal error is detected, disable the assertion as the uMCTL2's behavior is unknown.
`assert_yyclk(ERROR_RT_FIFO_DEPTH_MARGIN_FIFO_IS_ALMOST_FULL, ((i_fatl_err_detected == 1'b0) ? ((load_ptr >= unload_ptr) ? ((load_ptr - unload_ptr) <= (`MEMC_RT_FIFO_DEPTH - RT_FIFO_MARGIN)) : (((load_ptr + `MEMC_RT_FIFO_DEPTH) - unload_ptr) <= (`MEMC_RT_FIFO_DEPTH - RT_FIFO_MARGIN))) : 1'b1));

`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON






    // VCS coverage on
`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS

endmodule  // rt unit: response tracker
