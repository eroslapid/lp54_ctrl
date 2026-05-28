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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_core_out_if.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module ih_core_out_if(
  co_ih_clk,
  core_ddrc_rstn,
  rxcmd_wdata_ptr,
  ih_te_rd_valid,
  ih_te_wr_valid,
  ih_te_wr_valid_addr_err,
  ih_te_hi_pri,
  te_ih_rd_retry,
  te_ih_wr_retry,
  wr_fifo_fill_level,
  lpr_fifo_fill_level,
  hpr_fifo_fill_level,
  dh_ih_dis_hif,
  dh_ih_lpr_num_entries,
  input_fifo_full_rd,
  input_fifo_full_wr,
  gsfsm_sr_co_if_stall,
  hif_rcmd_stall,
  hif_wcmd_stall,
  hif_wdata_ptr_valid,
  hif_wdata_ptr,
  hif_wdata_ptr_addr_err,
  hif_lpr_credit,
  hif_hpr_credit,
  hif_wr_credit,
  co_ih_lpr_num_entries_changed);

//------------------------------ PARAMETERS ------------------------------------

parameter       RDCMD_ENTRY_BITS= 5;    // bits to address all entries in read CAM
parameter       WRCMD_ENTRY_BITS= 5;    // bits to address all entries in write CAM
parameter       WRECCCMD_ENTRY_BITS = 0;// overridden 
parameter       RMW_TYPE_BITS   = 2;    // 2 bits for RMW type
                                        //  (partial write, atomic RMW, scrub, or none)
parameter       WDATA_PTR_BITS  = 8;

parameter       CMD_TYPE_BITS   = 2;    // any change will require RTL modifications in IC
localparam      WRDATA_ENTRY_BITS= WRCMD_ENTRY_BITS + 1;        // write data RAM entries
                                        // (only support 2 datas per command at the moment)

// 2-bit command type encodings
localparam CMD_TYPE_BLK_WR   = `MEMC_CMD_TYPE_BLK_WR;
localparam CMD_TYPE_BLK_RD   = `MEMC_CMD_TYPE_BLK_RD;
localparam CMD_TYPE_RMW      = `MEMC_CMD_TYPE_RMW;
localparam CMD_TYPE_RESERVED = `MEMC_CMD_TYPE_RESERVED;

// 2-bit RMW type encodings
localparam RMW_TYPE_PARTIAL_NBW = `MEMC_RMW_TYPE_PARTIAL_NBW;
localparam RMW_TYPE_RMW_CMD     = `MEMC_RMW_TYPE_RMW_CMD;
localparam RMW_TYPE_SCRUB       = `MEMC_RMW_TYPE_SCRUB;
localparam RMW_TYPE_NO_RMW      = `MEMC_RMW_TYPE_NO_RMW;


input                           co_ih_clk;              // clock
input                           core_ddrc_rstn;         // reset

input  [WDATA_PTR_BITS-1:0]     rxcmd_wdata_ptr;
input                           ih_te_rd_valid;
input                           ih_te_wr_valid;
input                           ih_te_wr_valid_addr_err;
input                           ih_te_hi_pri;

input                           te_ih_rd_retry;
input                           te_ih_wr_retry;

input  [WRCMD_ENTRY_BITS:0]     wr_fifo_fill_level;
input  [RDCMD_ENTRY_BITS:0]     lpr_fifo_fill_level;
input  [RDCMD_ENTRY_BITS:0]     hpr_fifo_fill_level;


input                           dh_ih_dis_hif;
input  [RDCMD_ENTRY_BITS-1:0]   dh_ih_lpr_num_entries;
input                           input_fifo_full_rd;    // indication that the input fifo is full
input                           input_fifo_full_wr;    // indication that the input fifo is full
input                           gsfsm_sr_co_if_stall;
output                          hif_rcmd_stall;
output                          hif_wcmd_stall;
output                          hif_wdata_ptr_valid;
output  [WDATA_PTR_BITS-1:0]    hif_wdata_ptr;
output                          hif_wdata_ptr_addr_err;
output                          hif_wr_credit;
output                          hif_lpr_credit;
output                          hif_hpr_credit;



input                           co_ih_lpr_num_entries_changed;

reg                             hif_wdata_ptr_valid;
reg  [WDATA_PTR_BITS-1:0]       hif_wdata_ptr;
reg                             hif_wdata_ptr_addr_err;
reg                             hif_wr_credit;
reg                             hif_lpr_credit;

wire                            rst_credit_cnt;

wire                            wdata_ptr_valid_int;
wire                            wr_addr_err_int;

wire  [WRCMD_ENTRY_BITS:0]      wr_credit_init_value;
wire                            wr_credit_int;

wire  [WRCMD_ENTRY_BITS:0]      wr_credit_cnt_w;
reg  [WRCMD_ENTRY_BITS:0]       wr_credit_cnt;
wire  [RDCMD_ENTRY_BITS:0]      wr_credit_inc;
wire  [RDCMD_ENTRY_BITS:0]      wr_credit_dec;



wire  [RDCMD_ENTRY_BITS:0]      lpr_credit_init_value;
wire                            lpr_credit_int;

wire  [RDCMD_ENTRY_BITS:0]      lpr_credit_cnt_w;
reg  [RDCMD_ENTRY_BITS:0]       lpr_credit_cnt;
wire  [RDCMD_ENTRY_BITS:0]      lpr_credit_inc;
wire  [RDCMD_ENTRY_BITS:0]      lpr_credit_dec;

wire                            wr_valid;
wire                            lpr_valid;

wire                            hpr_valid;  
wire  [RDCMD_ENTRY_BITS-1:0]    hpr_credit_init_value;
wire                            hpr_credit_int;
wire                            ih_te_hpr_valid;
wire  [RDCMD_ENTRY_BITS-1:0]    hpr_credit_cnt_w;
reg  [RDCMD_ENTRY_BITS-1:0]     hpr_credit_cnt;
wire  [RDCMD_ENTRY_BITS:0]      hpr_credit_inc;
wire  [RDCMD_ENTRY_BITS:0]      hpr_credit_dec;

// synch reset for credit counters (issued when lpr_num_entries register is changed)
assign rst_credit_cnt = co_ih_lpr_num_entries_changed;


// Issue wdata_ptr valid when internal valid is high and (write or rmw) and there is no retry
assign  wdata_ptr_valid_int  = ih_te_wr_valid & (~te_ih_wr_retry)
                              ;

// Synchronize wr_addr_err with wdata_ptr_valid
assign  wr_addr_err_int = wdata_ptr_valid_int & ih_te_wr_valid_addr_err;


// Output flops
always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
  hif_wdata_ptr_valid  <= 1'b0;
  hif_wdata_ptr    <= {WDATA_PTR_BITS{1'b0}};
        hif_wdata_ptr_addr_err       <= 1'b0;
   end
   else begin
  hif_wdata_ptr_valid  <= wdata_ptr_valid_int;
  hif_wdata_ptr    <= rxcmd_wdata_ptr;
        hif_wdata_ptr_addr_err       <= wr_addr_err_int;
   end
end

reg gsfsm_sr_co_if_stall_r;
always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
  gsfsm_sr_co_if_stall_r  <= 1'b0;
   end
   else begin
  gsfsm_sr_co_if_stall_r  <= gsfsm_sr_co_if_stall;
   end
end

// To avoid "DBGCAM.dbg_stall == 1" during reset, found in RAL test
reg dh_ih_dis_hif_r;
always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
  dh_ih_dis_hif_r  <= 1'b0;
   end
   else begin
  dh_ih_dis_hif_r  <= dh_ih_dis_hif;
   end
end




wire  hif_rcmd_stall;
assign  hif_rcmd_stall   = input_fifo_full_rd | gsfsm_sr_co_if_stall_r | dh_ih_dis_hif_r
;

wire  hif_wcmd_stall;
assign  hif_wcmd_stall   = input_fifo_full_wr | gsfsm_sr_co_if_stall_r | dh_ih_dis_hif_r
;


////////////////////////////
// Write Credit Generation
////////////////////////////


assign wr_valid = ih_te_wr_valid;

// Initial value for the WR credit counter
assign wr_credit_init_value =  {1'b1,{WRCMD_ENTRY_BITS{1'b0}}};

wire  [WRCMD_ENTRY_BITS:0]      wr_credit_aux_sig;
wire  [WRCMD_ENTRY_BITS+1:0]    wr_credit_aux_sig_wider;
//spyglass disable_block TA_09
//SMD: Net 'DWC_ddrctl.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ih.ih_core_out_if.wr_credit_aux_sig_wider[5]' [in 'ih_core_out_if'] is not controllable to 1 [affected by other input(s)]
//SJ: This is expected in MEMC_SIDEBAND_ECC_AND_MEMC_USE_RMW configs because 'wr_credit_cnt' is [WRCMD_ENTRY_BITS-1:0] bits wide in this config, while 'wr_credit_init_value' is [WRCMD_ENTRY_BITS:0] bits wide
assign wr_credit_aux_sig_wider = wr_credit_init_value  - wr_credit_cnt;
//spyglass enable_block TA_09
assign wr_credit_aux_sig = wr_credit_aux_sig_wider[WRCMD_ENTRY_BITS:0];

// credit signal is high when the fill_level is greater than credit counter
// when credit is high, this implies one credit every clock cycle
assign wr_credit_int = (wr_credit_aux_sig > wr_fifo_fill_level );

assign wr_credit_inc = wr_credit_cnt + 1;
assign wr_credit_dec = wr_credit_cnt - 1;

// if retry is present - only credit counter increment happens
// if retry is not present - credit counter can increment or decrement
// note: retry evaluated last to optimize this timing path
assign wr_credit_cnt_w = te_ih_wr_retry ? 
                             (wr_credit_int ? wr_credit_inc : wr_credit_cnt)  :
                             (( wr_credit_int && (!wr_valid)) ? wr_credit_inc :
                              (!wr_credit_int &&   wr_valid)  ? wr_credit_dec :
                              wr_credit_cnt                                   );

//      initialize credits to 0 and have the logic accumulate credits after reset is deasserted
//      wr_credit_int will be generated every clock after reset, until the maximum number of credits
//  are accumulated. in this case, the core doesn't need to know anything about what the initial
//  credit should be.

always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
  hif_wr_credit  <= 1'b0;
     wr_credit_cnt<= {(WRCMD_ENTRY_BITS+1){1'b0}};
   end
   else begin
      if (rst_credit_cnt) begin
        hif_wr_credit  <= 1'b0;
          wr_credit_cnt<= {(WRCMD_ENTRY_BITS+1){1'b0}};
      end
      else begin
         hif_wr_credit  <= wr_credit_int;
         wr_credit_cnt  <= wr_credit_cnt_w;
      end
   end
end

////////////////////////////
// LPR Credit Generation
////////////////////////////


      assign lpr_valid = ih_te_rd_valid && (~ih_te_hi_pri);


// Initial value for the LPR credit counter
assign lpr_credit_init_value = {1'b0, dh_ih_lpr_num_entries} + 1;

wire  [RDCMD_ENTRY_BITS:0]      lpr_credit_aux_sig;
wire  [RDCMD_ENTRY_BITS+1:0]    lpr_credit_aux_sig_wider;
assign lpr_credit_aux_sig_wider = lpr_credit_init_value  - lpr_credit_cnt;
assign lpr_credit_aux_sig       = lpr_credit_aux_sig_wider[RDCMD_ENTRY_BITS:0];

// credit signal is high when the fill_level is greater than credit counter
// when credit is high, this implies one credit every clock cycle
assign lpr_credit_int = (lpr_credit_aux_sig > lpr_fifo_fill_level );

assign lpr_credit_inc = lpr_credit_cnt + 1;
assign lpr_credit_dec = lpr_credit_cnt - 1;


// if retry is present - only credit counter increment happens
// if retry is not present - credit counter can increment or decrement
// note: retry evaluated last to optimize this timing path
assign lpr_credit_cnt_w = te_ih_rd_retry ? 
                             (lpr_credit_int ? lpr_credit_inc : lpr_credit_cnt)  :
                             (( lpr_credit_int && (!lpr_valid)) ? lpr_credit_inc :
                              (!lpr_credit_int &&   lpr_valid)  ? lpr_credit_dec :
                              lpr_credit_cnt                                     );

//      initialize credits to 0 and have the logic accumulate credits after reset is deasserted
//      wr_credit_int will be generated every clock after reset, until the maximum number of credits
//      are accumulated. in this case, the core doesn't need to know anything about what the initial
//      credit should be.

always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
  hif_lpr_credit  <= 1'b0;
  lpr_credit_cnt  <= {RDCMD_ENTRY_BITS+1{1'b0}};
   end
   else begin
      if (rst_credit_cnt) begin
        hif_lpr_credit  <= 1'b0;
        lpr_credit_cnt  <= {RDCMD_ENTRY_BITS+1{1'b0}};
      end
      else begin
        hif_lpr_credit  <= lpr_credit_int;
        lpr_credit_cnt  <= lpr_credit_cnt_w;
      end
   end
end




////////////////////////////
// HPR Credit Generation
////////////////////////////

// When bypass, CAM entry is not allocated. But still we want to issue a credit
// to the core when that happens. So don't look at bypass in the equation below
assign ih_te_hpr_valid = (ih_te_rd_valid) ? ih_te_hi_pri : 0;


assign hpr_valid = ih_te_hpr_valid;

// Initial value for the HPR credit counter
assign hpr_credit_init_value = {RDCMD_ENTRY_BITS{1'b1}} - dh_ih_lpr_num_entries;

wire  [RDCMD_ENTRY_BITS-1:0]      hpr_credit_aux_sig;
wire  [RDCMD_ENTRY_BITS:0]        hpr_credit_aux_sig_wider;
assign hpr_credit_aux_sig_wider = hpr_credit_init_value  - hpr_credit_cnt;
assign hpr_credit_aux_sig = hpr_credit_aux_sig_wider[RDCMD_ENTRY_BITS-1:0];

// credit signal is high when the fill_level is greater than credit counter
// when credit is high, this implies one credit every clock cycle
//assign hpr_credit_int = ((hpr_credit_init_value - hpr_fifo_fill_level) > hpr_credit_cnt);
assign hpr_credit_int = (hpr_credit_aux_sig > hpr_fifo_fill_level[RDCMD_ENTRY_BITS-1:0] );
assign hpr_credit_inc = {1'b0, hpr_credit_cnt} + 1;
assign hpr_credit_dec = {1'b0, hpr_credit_cnt} - 1;

// if retry is present - only credit counter increment happens
// if retry is not present - credit counter can increment or decrement
// note: retry evaluated last to optimize this timing path
assign hpr_credit_cnt_w = te_ih_rd_retry ? 
                             (hpr_credit_int ? hpr_credit_inc[RDCMD_ENTRY_BITS-1:0] : hpr_credit_cnt):
                             (( hpr_credit_int && (!hpr_valid)) ? hpr_credit_inc[RDCMD_ENTRY_BITS-1:0] :
                              (!hpr_credit_int &&   hpr_valid)  ? hpr_credit_dec[RDCMD_ENTRY_BITS-1:0] :
                              hpr_credit_cnt                                    );


//      initialize credits to 0 and have the logic accumulate credits after reset is deasserted
//      wr_credit_int will be generated every clock after reset, until the maximum number of credits
//      are accumulated. in this case, the core doesn't need to know anything about what the initial
//      credit should be.

reg hif_hpr_credit;
always @ (posedge co_ih_clk or negedge core_ddrc_rstn) begin
   if(!core_ddrc_rstn) begin
  hif_hpr_credit  <= 1'b0;
  hpr_credit_cnt  <= {RDCMD_ENTRY_BITS{1'b0}};
   end
   else begin
      if (rst_credit_cnt) begin
        hif_hpr_credit  <= 1'b0;
        hpr_credit_cnt  <= {RDCMD_ENTRY_BITS{1'b0}};
      end
      else begin
        hif_hpr_credit  <= hpr_credit_int;
        hpr_credit_cnt  <= hpr_credit_cnt_w;
      end
   end
end


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

  // wr_credit_aux_sig overflow
  assert_never #(0, 0, "wr_credit_aux_sig overflow", CATEGORY) a_wr_credit_aux_sig_overflow
    (co_ih_clk, core_ddrc_rstn, (wr_credit_aux_sig_wider[WRCMD_ENTRY_BITS+1]==1'b1));
  
  // lpr_credit_aux_sig overflow
  assert_never #(0, 0, "lpr_credit_aux_sig overflow", CATEGORY) a_lpr_credit_aux_sig_overflow
    (co_ih_clk, core_ddrc_rstn, (lpr_credit_aux_sig_wider[RDCMD_ENTRY_BITS+1]==1'b1));
    
  // hpr_credit_aux_sig overflow
  assert_never #(0, 0, "hpr_credit_aux_sig overflow", CATEGORY) a_hpr_credit_aux_sig_overflow
    (co_ih_clk, core_ddrc_rstn, (hpr_credit_aux_sig_wider[RDCMD_ENTRY_BITS]==1'b1));    

`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON 

endmodule
