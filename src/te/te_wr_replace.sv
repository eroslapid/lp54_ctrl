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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_wr_replace.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_wr_replace #(
    //-------------------------------- PARAMETERS ----------------------------------
     parameter  WR_CAM_ADDR_BITS    = 0
    ,parameter  WR_ECC_CAM_ADDR_BITS = 0
    ,parameter  WR_CAM_ADDR_BITS_IE = 0
    ,parameter  WR_CAM_ENTRIES      = 0 
    ,parameter  WR_CAM_ENTRIES_IE   = 0
    ,parameter  WR_ECC_CAM_ENTRIES  = 0 
    ,parameter  PAGE_BITS           = `MEMC_PAGE_BITS 
    ,parameter  AUTOPRE_BITS        = 1 
    ,parameter   MWR_BITS            = 1 
    ,parameter   PW_WORD_CNT_WD_MAX  = 2
    ,parameter   PARTIAL_WR_BITS_LOG2  = 1 
    ,parameter  IE_TAG_BITS         = 0 // Overridden
    ,parameter  WRSEL_TAG_BITS      = PAGE_BITS
                                    + AUTOPRE_BITS
                                    + MWR_BITS
                                    + PW_WORD_CNT_WD_MAX
                                    + PW_WORD_CNT_WD_MAX
                                    + PARTIAL_WR_BITS_LOG2
                                    + IE_TAG_BITS
    ,parameter  WRECCSEL_TAG_BITS   = WRSEL_TAG_BITS + 2 // Inluding BTT/RE
    )
    (    
    //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                             core_ddrc_rstn 
    ,input                                             co_te_clk 
    ,input   [WR_CAM_ADDR_BITS-1:0]                    ih_te_wr_prefer 
    ,input   [WR_CAM_ENTRIES_IE -1:0]                  te_wr_entry_valid           // valid read entry matching bank from CAM search
    ,input                                             ddrc_cg_en
    ,input   [WR_CAM_ENTRIES_IE -1:0]                  te_wr_page_hit              // read entries matching bank and page from CAM search
    ,input                                             te_wr_flush_started         // indicates a collision causing read entries to be flushed
    ,input   [WR_CAM_ADDR_BITS_IE-1:0]                 te_wr_col_entry             // entry # to be flushed from read CAM
    ,output  [WR_CAM_ADDR_BITS_IE-1:0]                 te_wr_prefer                // low priority read prefer location
    ,output  [WR_CAM_ADDR_BITS_IE-1:0]                 te_sel_wr_entry             // entry # of selected CAM entry for replacement
    ,output  [PAGE_BITS-1:0]                           te_sel_wr_page              // Row address of selected CAM entry
    ,output  [AUTOPRE_BITS-1:0]                        te_sel_wr_cmd_autopre       // cmd_autopre of selected CAM entry
    ,output  [MWR_BITS-1:0]                            te_sel_mwr                  // masked write of selected CAM entry
    ,input   [WR_CAM_ENTRIES_IE*MWR_BITS-1:0]          te_mwr_table                // masked write of all CAM entries
    ,output  [PW_WORD_CNT_WD_MAX-1:0]                  te_sel_pw_num_cols_m1       // partial write of selected CAM entry
    ,input   [WR_CAM_ENTRIES_IE*PW_WORD_CNT_WD_MAX-1:0]te_pw_num_cols_m1_table     // partial write of all CAM entries
    ,output  [PARTIAL_WR_BITS_LOG2-1:0]                te_sel_wr_mr_ram_raddr_lsb
    ,output  [PW_WORD_CNT_WD_MAX-1:0]                  te_sel_wr_mr_pw_num_beats_m1
    ,output                                            te_sel_wr_valid             // selected read entry for replacement
    ,input   [WR_CAM_ENTRIES_IE*PAGE_BITS-1:0]         te_wr_page_table            // page addresses of all CAM entries
    ,input   [WR_CAM_ENTRIES_IE*AUTOPRE_BITS-1:0]      te_wr_cmd_autopre_table     // cmd_autopre of all CAM entries
    ,input   [WR_CAM_ENTRIES_IE*PARTIAL_WR_BITS_LOG2-1:0] te_wr_mr_ram_raddr_lsb_first_table
    ,input   [WR_CAM_ENTRIES_IE*PW_WORD_CNT_WD_MAX-1:0]   te_wr_mr_pw_num_beats_m1_table
    ,output  [WR_CAM_ENTRIES-1:0]                    hmx_mask
    ,input   [WR_CAM_ENTRIES-1:0]                    hmx_oldest_oh

);

//----------------------------- WIRES AND REGS ---------------------------------

reg     [WR_CAM_ENTRIES_IE-1:0]     r_wr_entry_valid;               // flopped version of all entries
wire    [WR_CAM_ENTRIES-1:0]        te_wr_entry_participate;
wire    [WR_CAM_ADDR_BITS-1:0]      i_sel_wr_entry;                 // entry # from selection network for CAM replacement
                                                                    //  (this may be over-ridden for collision cases)
wire                                i_sel_wr_valid;              // valid for the selected 
reg                                 i_sel_wr_valid_r;            // valid for the selected 
  `ifndef SYNTHESIS
    `ifdef SNPS_ASSERT_ON
wire                                i_sel_wr_valid_sva;
    `endif
  `endif
wire    [WRSEL_TAG_BITS-1:0]        i_sel_wr_tag;                   // Tag of selected CAM entry
wire    [PAGE_BITS-1:0]             i_sel_wr_page;
wire    [AUTOPRE_BITS-1:0]          i_sel_wr_cmd_autopre;
wire    [MWR_BITS-1:0]              i_sel_wr_mwr;
wire    [PW_WORD_CNT_WD_MAX-1:0]    i_sel_wr_pw_num_cols_m1;
wire    [PARTIAL_WR_BITS_LOG2-1:0]  i_sel_wr_mr_raddr_lsb_first;
wire    [PW_WORD_CNT_WD_MAX-1:0]    i_sel_wr_pw_num_beats_m1;




wire                            i_sel_colliding;
wire [WR_CAM_ADDR_BITS_IE-1:0]  i_te_wr_col_entry;
wire [PAGE_BITS-1:0]            i_wr_col_page;
wire [AUTOPRE_BITS-1:0]         i_wr_col_cmd_autopre;
wire [MWR_BITS-1:0]             i_wr_col_mwr;
wire [PARTIAL_WR_BITS_LOG2-1:0] i_wr_mr_raddr_lsb_first;
wire [PW_WORD_CNT_WD_MAX-1:0]   i_wr_mr_pw_num_beats_m1;
wire [PW_WORD_CNT_WD_MAX-1:0]   i_wr_col_pw_num_cols_m1;




//---------------------------------- LOGIC -------------------------------------


   wire    r_te_any_vpw_timed_out= 1'b0;


always @ (posedge co_te_clk or negedge core_ddrc_rstn) begin 
   if (~core_ddrc_rstn) begin 
      r_wr_entry_valid <= {WR_CAM_ENTRIES_IE{1'b0}};
   end
   else if(ddrc_cg_en) begin 
//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop (master RTL_FDCE) is always enabled
//SJ: ddrc_cg_en is fixed to 1 (always disable clock gating) because this module is reused in the block not supporting clock gating
      r_wr_entry_valid <= te_wr_entry_valid;
//spyglass enable_block FlopEConst
   end  
end
   
// override selection network choice with colliding entry if colliding entry is valid replacement
wire sel_colliding = te_wr_flush_started & r_wr_entry_valid[te_wr_col_entry] & ~r_te_any_vpw_timed_out
                     ;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(1024 * 8)' found in module 'te_wr_replace'
//SJ: This coding style is acceptable and there is no plan to change it. - refers to `UMCTL_LOG2

wire [PAGE_BITS-1:0] wr_col_page;
  te_mux
   #(
    .ADDRW      (`UMCTL_LOG2 (WR_CAM_ENTRIES_IE)),
    .NUM_INPUTS (WR_CAM_ENTRIES_IE),
    .DATAW      (PAGE_BITS)
  )
  rd_col_page_mux (
    .in_port   (te_wr_page_table),
    .sel       (te_wr_col_entry),
    .out_port  (wr_col_page)
  );   
   
wire [AUTOPRE_BITS-1:0] wr_col_cmd_autopre;
  te_mux
   #(
    .ADDRW      (`UMCTL_LOG2 (WR_CAM_ENTRIES_IE)),
    .NUM_INPUTS (WR_CAM_ENTRIES_IE),
    .DATAW      (AUTOPRE_BITS)
  )
  rd_col_cmd_autopre_mux (
    .in_port   (te_wr_cmd_autopre_table),
    .sel       (te_wr_col_entry),
    .out_port  (wr_col_cmd_autopre)
  );   

wire [MWR_BITS-1:0] wr_col_mwr;
  te_mux
   #(
    .ADDRW      (`UMCTL_LOG2 (WR_CAM_ENTRIES_IE)),
    .NUM_INPUTS (WR_CAM_ENTRIES_IE),
    .DATAW      (MWR_BITS)
  )
  rd_col_mwr_mux (
    .in_port    (te_mwr_table),
    .sel        (te_wr_col_entry),
    .out_port   (wr_col_mwr)
  );
wire [PARTIAL_WR_BITS_LOG2-1:0] wr_mr_raddr_lsb_first;
  te_mux
   #(
    .ADDRW      (`UMCTL_LOG2 (WR_CAM_ENTRIES_IE)),
    .NUM_INPUTS (WR_CAM_ENTRIES_IE),
    .DATAW      (PARTIAL_WR_BITS_LOG2)
  )
  wr_col_pi_wr_mr_raddr_mux (
    .in_port    (te_wr_mr_ram_raddr_lsb_first_table),
    .sel        (te_wr_col_entry),
    .out_port   (wr_mr_raddr_lsb_first)
  );

wire [PW_WORD_CNT_WD_MAX-1:0] wr_mr_pw_num_beats_m1;
  te_mux
   #(
    .ADDRW      (`UMCTL_LOG2 (WR_CAM_ENTRIES_IE)),
    .NUM_INPUTS (WR_CAM_ENTRIES_IE),
    .DATAW      (PW_WORD_CNT_WD_MAX)
  )
  wr_col_pi_wr_mr_pw_num_beats_mux (
    .in_port    (te_wr_mr_pw_num_beats_m1_table),
    .sel        (te_wr_col_entry),
    .out_port   (wr_mr_pw_num_beats_m1)
  );


wire [PW_WORD_CNT_WD_MAX-1:0] wr_col_pw_num_cols_m1;
  te_mux
   #(
    .ADDRW      (`UMCTL_LOG2 (WR_CAM_ENTRIES_IE)),
    .NUM_INPUTS (WR_CAM_ENTRIES_IE),
    .DATAW      (PW_WORD_CNT_WD_MAX)
  )
  rd_col_pw_num_cols_m1_mux (
    .in_port    (te_pw_num_cols_m1_table),
    .sel        (te_wr_col_entry),
    .out_port   (wr_col_pw_num_cols_m1)
  );

//spyglass enable_block SelfDeterminedExpr-ML



assign i_sel_colliding         = sel_colliding;
assign i_te_wr_col_entry       = te_wr_col_entry;
assign i_wr_col_page           = wr_col_page;
assign i_wr_col_cmd_autopre    = wr_col_cmd_autopre;
assign i_wr_col_mwr            = wr_col_mwr;
assign i_wr_mr_raddr_lsb_first = wr_mr_raddr_lsb_first;
assign i_wr_mr_pw_num_beats_m1 = wr_mr_pw_num_beats_m1;
assign i_wr_col_pw_num_cols_m1 = wr_col_pw_num_cols_m1;





assign te_sel_wr_entry[WR_CAM_ADDR_BITS-1:0]  = i_sel_colliding ? i_te_wr_col_entry[WR_CAM_ADDR_BITS-1:0] : 
                                                                i_sel_wr_entry;

assign te_sel_wr_page        = i_sel_colliding ? i_wr_col_page :
                                               i_sel_wr_page;

assign te_sel_wr_cmd_autopre = i_sel_colliding ? i_wr_col_cmd_autopre :
                                               i_sel_wr_cmd_autopre;

assign te_sel_mwr            = i_sel_colliding ? i_wr_col_mwr : 
                                               i_sel_wr_mwr;
assign te_sel_pw_num_cols_m1 = i_sel_colliding ? i_wr_col_pw_num_cols_m1 : 
                                               i_sel_wr_pw_num_cols_m1;

assign te_sel_wr_mr_ram_raddr_lsb = i_sel_colliding ? i_wr_mr_raddr_lsb_first : 
                                                   i_sel_wr_mr_raddr_lsb_first;

assign te_sel_wr_mr_pw_num_beats_m1 = i_sel_colliding ? i_wr_mr_pw_num_beats_m1 : 
                                                     i_sel_wr_pw_num_beats_m1;





// for bank preference, select the colliding bank during a collision
assign te_wr_prefer[WR_CAM_ADDR_BITS-1:0]  = 
                             te_wr_flush_started   ? te_wr_col_entry[WR_CAM_ADDR_BITS-1:0] : ih_te_wr_prefer;


//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(((i + 1) * PAGE_BITS) - 1)' found in module 'te_wr_replace'
//SJ: This coding style is acceptable and there is no plan to change it.

// putting the page, cmd_autopre and mwr from all the banks into a single bus
// the format is {page[bankN],cmd_autopre[bankN],mwr[bankN] ... , page[bank1],cmd_autopre[bank1],mwr[bank1],page[bank0],cmd_autopre[bank0],mwr[bank0]}
wire [WRSEL_TAG_BITS*WR_CAM_ENTRIES-1:0] wr_selnet_tags_in;
genvar i;
generate
    for (i=0; i<WR_CAM_ENTRIES; i=i+1) begin : wr_selnet_tags_in_gen
assign  wr_selnet_tags_in[((i+1)*WRSEL_TAG_BITS)-1:i*WRSEL_TAG_BITS] =
            {te_wr_page_table[((i+1)*PAGE_BITS)-1:i*PAGE_BITS]
            ,te_wr_cmd_autopre_table[((i+1)*AUTOPRE_BITS)-1:i*AUTOPRE_BITS]
            ,te_mwr_table[((i+1)*MWR_BITS)-1:i*MWR_BITS]
            ,te_pw_num_cols_m1_table[((i+1)*PW_WORD_CNT_WD_MAX)-1:i*PW_WORD_CNT_WD_MAX]
            ,te_wr_mr_ram_raddr_lsb_first_table[((i+1)*PARTIAL_WR_BITS_LOG2)-1:i*PARTIAL_WR_BITS_LOG2]
            ,te_wr_mr_pw_num_beats_m1_table[((i+1)*PW_WORD_CNT_WD_MAX)-1:i*PW_WORD_CNT_WD_MAX]
            };
    end
endgenerate
//spyglass enable_block SelfDeterminedExpr-ML


//------------------------------- INSTANTIATIONS -------------------------------


   
 te_filter
  #(      .CAM_ENTRIES           (WR_CAM_ENTRIES) )
  WRfilter (
                   .te_bank_hit           (te_wr_entry_valid [WR_CAM_ENTRIES -1:0]), 
                   .te_page_hit           (te_wr_page_hit [WR_CAM_ENTRIES -1:0]),
                   .te_entry_participate  (te_wr_entry_participate [WR_CAM_ENTRIES -1:0])
                  );

wire  [WR_CAM_ENTRIES-1:0]        i_hmx_oldest_oh;
assign i_hmx_oldest_oh = hmx_oldest_oh;


select_net_hmatrix
             #(
    .TAG_BITS               (WRSEL_TAG_BITS),
    .NUM_INPUTS             (WR_CAM_ENTRIES)
  )
  WRselnet (
    .tags                   (wr_selnet_tags_in),
    .vlds                   (te_wr_entry_participate [WR_CAM_ENTRIES -1:0]),
    .selected               (i_sel_wr_entry [WR_CAM_ADDR_BITS-1:0]),
  `ifndef SYNTHESIS
    `ifdef SNPS_ASSERT_ON
    .clk                    (co_te_clk),
    .resetb                 (core_ddrc_rstn),
    .selected_vld           (i_sel_wr_valid_sva),
    `endif
  `endif
    .mask                   (hmx_mask),
    .selected_in_oh         (i_hmx_oldest_oh),
    .tag_selected           (i_sel_wr_tag)
  );

assign {i_sel_wr_page
       ,i_sel_wr_cmd_autopre
       ,i_sel_wr_mwr
       ,i_sel_wr_pw_num_cols_m1
       ,i_sel_wr_mr_raddr_lsb_first
       ,i_sel_wr_pw_num_beats_m1
    } = i_sel_wr_tag;

always @ (posedge co_te_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn) begin
      i_sel_wr_valid_r   <= 1'b0;
   end
   else begin
      i_sel_wr_valid_r   <= |te_wr_entry_valid[WR_CAM_ENTRIES -1:0];
   end
end
assign i_sel_wr_valid = i_sel_wr_valid_r; 

//-----------------------------------
// Begin VPW section
//-----------------------------------
//--------------------------------------



// Output assignment 

assign te_sel_wr_valid = i_sel_wr_valid;

`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
  property p_values_always_same(a,b); 
    @(posedge co_te_clk) disable iff(!core_ddrc_rstn) 
    (a == b); 
  endproperty


  a_check_i_sel_wr_valid        : assert property (p_values_always_same(i_sel_wr_valid,i_sel_wr_valid_sva)); 

`endif
`endif



endmodule // te_wr_replace
