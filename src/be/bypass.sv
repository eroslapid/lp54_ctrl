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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/be/bypass.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This module maintains an open page table to provide
//   1. bypass permission of an incoming high priority read command
//   2. page status of an incoming read command
//   3. page status of a write command from write update engine
//   4. page address of a cam search
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module bypass #(
  //------------------------------ PARAMETERS ------------------------------------
     parameter    RANKBANK_BITS     = `MEMC_RANKBANK_BITS
    ,parameter    PAGE_BITS         = `MEMC_PAGE_BITS
    ,parameter    BSM_BITS          = `UMCTL2_BSM_BITS
    ,parameter    BANK_BITS         = `MEMC_BANK_BITS
    ,parameter    NUM_TOTAL_BANKS   = 1 << RANKBANK_BITS // max total banks in all ranks
    ,parameter    NUM_TOTAL_BSMS    = `UMCTL2_NUM_BSM
    ,parameter    LRANK_BITS        = 1
  )
  (
  //------------------------- INPUTS AND OUTPUTS ---------------------------------
     input                                      core_ddrc_rstn                      // reset
    ,input                                      co_be_clk                           // main clock
    ,input      [BSM_BITS-1:0]                  ih_be_bsm_num_rd                    // BSM number
//`ifdef  UMCTL2_DYN_BSM
    ,input                                      bm_be_rd_bsm_alloc                  // bsm alloc info  from bm
//`endif // UMCTL2_DYN_BSM
    ,input      [PAGE_BITS-1:0]                 ih_be_page_num                      // page number
    ,input      [PAGE_BITS-1:0]                 ih_wr_page_num                      // page number for write

//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in RTL assertion 
    ,input      [BSM_BITS-1:0]                  ih_be_bsm_num_wr                    // BSM number
//spyglass enable_block W240
//`ifdef  UMCTL2_DYN_BSM
    ,input                                      bm_be_wr_bsm_alloc                  // bsm alloc info  from bm
//`endif // UMCTL2_DYN_BSM
    ,input      [PAGE_BITS-1:0]                 te_be_page_addr                     // the page that is going to be opened
    ,input      [BSM_BITS-1:0]                  te_be_bsm_num                       // write command rank/bank/page address
    ,input      [PAGE_BITS-1:0]                 te_be_page_num                      // write command rank/bank/page address
    ,input                                      ts_te_autopre                       // auto-precharge indicator for reads & writes
    ,output                                     be_te_page_hit                      // incoming command has an open page hit
    ,output                                     be_te_wr_page_hit                   // current write command has an open page hit
    ,output                                     be_wr_page_hit                      // page hit for write arriving from ih, calculated during CAM loading

    ,output     [NUM_TOTAL_BSMS*PAGE_BITS-1:0]  be_os_page_table                    // outputs entire page table to TS
                                                                                    // TS will then do the page selection for reads/writes rather than BE
    ,input      [BSM_BITS-1:0]                  gs_be_rdwr_bsm_num                  // BSM number from GS - for rd/wr
    ,input      [BSM_BITS-1:0]                  gs_be_act_bsm_num                   // BSM number from GS - for act
    ,input      [BSM_BITS-1:0]                  gs_be_pre_bsm_num                   // BSM number from GS - for pre
    ,input                                      gs_be_op_is_activate                // current DRAM op is activation
    ,input                                      gs_be_op_is_precharge               // current DRAM op is precharge
    ,input                                      gs_be_op_is_rdwr                    // read or write command
  );

//----------------------------- REGS AND WIRES ---------------------------------


reg   [PAGE_BITS-1:0]       i_page_table_reg [NUM_TOTAL_BSMS-1:0];    // open page table
reg   [NUM_TOTAL_BSMS-1:0]  i_page_vld_reg; // the page in the table is valid

wire                        i_rd_page_vld;  // current page number
wire  [PAGE_BITS-1:0]       i_rd_page_num;  // current page number
wire                        i_wr_page_vld;  // current page number
wire  [PAGE_BITS-1:0]       i_wr_page_num;  // current page number
wire  [PAGE_BITS-1:0]       i_wr_page_num_wr_combine;  // current page number
wire                        i_close_page;                 // the bank that is same as the incoming read command is closing
wire                        i_close_wr_page;              // the bank that is same as the write command is closing

integer                     cnt;            // for loop dummy variable

wire [PAGE_BITS-1:0]   page_num_for_ih_wr_bsm;
wire                   page_vld_for_ih_wr_bsm;

//----------------------------- MAINLINE CODE ----------------------------------




genvar i;
generate
for (i=0; i<NUM_TOTAL_BSMS; i=i+1)
begin : page_table_out_gen
  assign be_os_page_table[((i+1)*PAGE_BITS)-1 : i*PAGE_BITS] = i_page_table_reg[i];
end
endgenerate

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in RTL assertion
assign i_rd_page_vld   = i_page_vld_reg   [ih_be_bsm_num_rd [BSM_BITS-1:0]] & bm_be_rd_bsm_alloc;
//spyglass enable_block W528


// checking bypass permission
assign i_rd_page_num  = i_page_table_reg [ih_be_bsm_num_rd [BSM_BITS-1:0]];
assign be_te_page_hit = i_rd_page_vld & (& (ih_be_page_num[PAGE_BITS-1:0] ~^ i_rd_page_num[PAGE_BITS-1:0])) & (~i_close_page) & bm_be_rd_bsm_alloc;

// page hit on the current incoming read command
assign i_close_page = ( gs_be_op_is_precharge              & (& (gs_be_pre_bsm_num    ~^ ih_be_bsm_num_rd)) & bm_be_rd_bsm_alloc) |
                      ( (gs_be_op_is_rdwr & ts_te_autopre) & (& (gs_be_rdwr_bsm_num   ~^ ih_be_bsm_num_rd)) & bm_be_rd_bsm_alloc)  
;

// page hit on the current write command
assign i_wr_page_vld                 = i_page_vld_reg   [te_be_bsm_num [BSM_BITS-1:0]];
assign i_wr_page_num [PAGE_BITS-1:0] = i_page_table_reg [te_be_bsm_num [BSM_BITS-1:0]];
assign i_close_wr_page = ( gs_be_op_is_precharge              & (& (gs_be_pre_bsm_num ~^ te_be_bsm_num)) ) |
       ( (gs_be_op_is_rdwr & ts_te_autopre) & (& (gs_be_rdwr_bsm_num ~^ te_be_bsm_num)) )  
;
                         // note: read bypass is never issued with auto-precharge
assign be_te_wr_page_hit = i_wr_page_vld & (~i_close_wr_page) & (& (te_be_page_num[PAGE_BITS-1:0] ~^ i_wr_page_num[PAGE_BITS-1:0]));
//wire [PAGE_BITS-1:0]   page_num_for_ih_wr_bsm;
//wire                   page_vld_for_ih_wr_bsm;
   
assign page_num_for_ih_wr_bsm [PAGE_BITS-1:0] = i_page_table_reg [ih_be_bsm_num_wr [BSM_BITS-1:0]];
assign page_vld_for_ih_wr_bsm                 = i_page_vld_reg   [ih_be_bsm_num_wr [BSM_BITS-1:0]];

assign be_wr_page_hit = page_vld_for_ih_wr_bsm  & (& (ih_wr_page_num[PAGE_BITS-1:0] ~^ page_num_for_ih_wr_bsm[PAGE_BITS-1:0])) & bm_be_wr_bsm_alloc;
   

// open page table
always @(posedge co_be_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1) begin
      i_page_table_reg [cnt] <= {PAGE_BITS{1'b0}};
      i_page_vld_reg   [cnt] <= 1'b0;
    end
  end
  else begin


// NOTE: 2X mode: Activate, Activate Bypass or Read/Write with Autoprecharge happens in one half of
//                the 2x clock AND precharge and precharge bypass happens in the other half
//                One priority encoder selects between act & act_bypass & rdwr_autopre
//      Another pri encoder selects between pre & pre_bypass 
//                These 2 events always happens to different banks
    if (gs_be_op_is_activate) begin
      i_page_table_reg [gs_be_act_bsm_num [BSM_BITS-1:0]] <= te_be_page_addr [PAGE_BITS-1:0];
    end

    for (cnt=0; cnt<NUM_TOTAL_BSMS; cnt=cnt+1) begin
      if (gs_be_op_is_activate & ($unsigned(cnt) == gs_be_act_bsm_num)) begin
        i_page_vld_reg[cnt] <= 1'b1;
      end
      else if (gs_be_op_is_rdwr & ts_te_autopre & ($unsigned(cnt) == gs_be_rdwr_bsm_num)) begin
        i_page_vld_reg[cnt] <= 1'b0;
      end
      else if (gs_be_op_is_precharge & ($unsigned(cnt) == gs_be_pre_bsm_num)) begin 
      // note: read bypass is never issued with auto-precharge
        i_page_vld_reg[cnt] <= 1'b0;
      end
    end

  end // else: not in reset
// end flops for page table

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON

// Check that the first half events (act/act_bypass/rdwr_autopre) and second half events (pre/pre_bypass) are NOT going to the same bank
wire  first_half_page_vld_op;
wire  second_half_page_vld_op;
wire  [BSM_BITS-1:0] first_half_bsm_bits;
wire  [BSM_BITS-1:0] second_half_bsm_bits;

assign first_half_page_vld_op = gs_be_op_is_activate || 
          (gs_be_op_is_rdwr & ts_te_autopre);

assign second_half_page_vld_op = gs_be_op_is_precharge 
          ;

assign first_half_bsm_bits = gs_be_op_is_activate ? gs_be_act_bsm_num [BSM_BITS-1:0] :
            (
              gs_be_rdwr_bsm_num [BSM_BITS-1:0]);

assign second_half_bsm_bits = 
          gs_be_pre_bsm_num [BSM_BITS-1:0];

BE_ActPre_diffBank :
   assert property (@ (posedge co_be_clk) disable iff (~core_ddrc_rstn)
      (first_half_page_vld_op && second_half_page_vld_op) |-> (first_half_bsm_bits != second_half_bsm_bits))
       else $error("[%t][%m] Act OR Bypass_act OR rdwr_autopre happened to the same bank as Precharge OR Precharge Bypass. This is not legal", $time);

// Output checks



`endif // SNPS_ASSERT_ON

`endif // SYNTHESIS
endmodule // bypass
