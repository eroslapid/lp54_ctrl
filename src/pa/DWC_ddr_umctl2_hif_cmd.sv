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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/pa/DWC_ddr_umctl2_hif_cmd.sv#1 $
// -------------------------------------------------------------------------
// Description:
//               Host Interface (HIF) command path
//               Implements the multiplexer for the command/address path
//               to interface from XPIs to DDRC HIF
//----------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_hif_cmd
  #(
    parameter NPORTS          = 1,
    parameter HIF_ADDR_WIDTH  = 1,
    parameter MEMC_TAGBITS    = 1,
    parameter WDATA_PTR_BITS  = 1,
    parameter AXI_LOCKW       = 2,
    parameter EXA_PYLD_W      = 32,
    parameter RQOS_TW         = 11,
    parameter RQOS_RW         = 2,
    parameter WQOS_TW         = 11,
    parameter WQOS_RW         = 2,
    parameter CMD_LEN_BITS    = 1,
    parameter WRDATA_CYCLES   = 4,
    parameter AXI_IDW         = 8,
    parameter A_NPORTS_LG2    = 1,
    parameter DUAL_PA         = 0
    )
   (
   //---------------------------------------------------------------------------
   // Interface Pins
   //---------------------------------------------------------------------------
    input [NPORTS-1:0]                  pa_wgrant,
    input [NPORTS-1:0]                  pa_rgrant,

    // Read application ports
    input [NPORTS-1:0]                  e_arvalid,
    input [NPORTS*HIF_ADDR_WIDTH-1:0]   e_araddr,
    input [NPORTS*RQOS_RW-1:0]          pa_rpri,
    input [NPORTS*RQOS_TW-1:0]          pa_r_timeout,
    input [NPORTS*WQOS_RW-1:0]          pa_wpri,
    input [NPORTS*WQOS_TW-1:0]          pa_w_timeout,
    input [NPORTS*CMD_LEN_BITS-1:0]     xa_rlength,
    input [NPORTS*MEMC_TAGBITS-1:0]     xa_rtoken,
    input [NPORTS-1:0]                  xa_rautopre,

    // Write application ports
    input [NPORTS-1:0]                  e_awvalid,
    input [NPORTS*HIF_ADDR_WIDTH-1:0]   e_awaddr,
    input [NPORTS*WDATA_PTR_BITS-1:0]   xa_wdata_ptr,
    input [NPORTS-1:0]                  xa_rmw_dynamic,
    input [NPORTS-1:0]                  xa_wautopre,
    input [NPORTS*WRDATA_CYCLES-1:0]    xa_wdata_mask_full,
    input [NPORTS*CMD_LEN_BITS-1:0]     xa_wlength,
    
    // HIF Command Interface
    output [RQOS_TW-1:0]                hif_hif_cmd_latency,
    output                              hif_hif_cmd_valid,
    output [1:0]                        hif_hif_cmd_type,
    output [HIF_ADDR_WIDTH-1:0]         hif_hif_cmd_addr,
    output [RQOS_RW-1:0]                hif_hif_cmd_pri,
    output [MEMC_TAGBITS-1:0]           hif_hif_cmd_token,
    output [CMD_LEN_BITS-1:0]           hif_hif_cmd_length,
    output [WDATA_PTR_BITS-1:0]         hif_hif_cmd_wdata_ptr,
    output                              hif_hif_cmd_autopre,
    output                              hif_hif_cmd_ecc_region,
    output [WRDATA_CYCLES-1:0]          hif_hif_cmd_wdata_mask_full_ie,

    // Exclusive Transaction Ports
    input  [NPORTS*EXA_PYLD_W-1:0]      e_wexa_pyld,
    input  [NPORTS*EXA_PYLD_W-1:0]      e_rexa_pyld,
    input  [NPORTS-1:0]                 xpi_awlast,  
    input  [NPORTS-1:0]                 xpi_short_burst,  
    output [EXA_PYLD_W-1:0]             hif_co_ih_exa_pyld_wr,
    output [EXA_PYLD_W-1:0]             hif_co_ih_exa_pyld_rd,
    output                              hif_hif_cmd_awlast,
    output                              hif_hif_cmd_short_burst
    );

   //---------------------------------------------------------------------------
   // Local parameters
   //---------------------------------------------------------------------------

   localparam READ_CMD  = 2'b01;
   localparam WRITE_CMD = 2'b00;
   localparam RMW_CMD   = 2'b10;

   localparam IECC_INFO          = 2; // 
   localparam WEXA_INFO          = 3;
   localparam AWLAST_INFO        = 1;
   localparam WPTR_REMAIN        = WDATA_PTR_BITS-(AWLAST_INFO+IECC_INFO+WEXA_INFO+1+1+A_NPORTS_LG2);
   localparam RPTR_IECC_LSB      = A_NPORTS_LG2+AXI_IDW+1;
   localparam RPTR_IECC_REMAIN   = MEMC_TAGBITS-IECC_INFO-RPTR_IECC_LSB;  


  //---------------------------------------------------------------------------
  // Internal signals 
  //---------------------------------------------------------------------------

   wire [NPORTS-1:0]          wgrant, rgrant;
   reg                        rvalid, wvalid;
   reg [HIF_ADDR_WIDTH-1:0]   raddr, waddr;
   reg [RQOS_RW-1:0]          rpri;
   reg [WQOS_RW-1:0]          wpri;
   reg [CMD_LEN_BITS-1:0]     rlength;
   reg [MEMC_TAGBITS-1:0]     rtoken;
   reg                        rautopre, wautopre;
   reg                        rmw;
   reg [WDATA_PTR_BITS-1:0]   wdata_ptr;
   reg [EXA_PYLD_W-1:0]       wex_pyldr, rex_pyldr;
   reg [RQOS_TW-1:0]          rlatency;
   reg [WQOS_TW-1:0]          wlatency;
   reg                        xpi_awlast_r, xpi_short_burst_r;
   reg [CMD_LEN_BITS-1:0]     wlength;

   reg [WRDATA_CYCLES-1:0]    wdata_mask_full_ie;
   wire [WRDATA_CYCLES-1:0]   wdata_mask_full_ie_i;
   wire                       rcmd_vld_ie;
   wire                       rcmd_end_ie_unused;
   

   
   wire [RPTR_IECC_REMAIN-1:0] rtoken_remain_unused;
   wire [RPTR_IECC_LSB-1:0]    rtoken_lsb_unused;

   // write pointer bits
   wire                       wcmd_vld_ie;
   wire                       wcmd_end_ie_unused;
   wire                       wptr_wexa_resp_unused;
   wire                       wptr_wexa_acc;
   wire                       wptr_wexa_acc_lock_unused;
   wire [WPTR_REMAIN-1:0]     wdata_ptr_remain_unused;
   wire                       wptr_ocpar_err; 
   wire                       wptr_poison;   
   wire [A_NPORTS_LG2-1:0]    wptr_wport_num_unused;

  //---------------------------------------------------------------------------
  // Main module
  //---------------------------------------------------------------------------

   // Write command mux
   always @*
   begin: write_command_mux_COMB_PROC
      integer width, sel;
//spyglass disable_block W415a
//SMD: Signals assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches  
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((sel * HIF_ADDR_WIDTH) + width)' found in module 'DWC_ddr_umctl2_hif_cmd'
//SJ: This coding style is acceptable and there is no plan to change it
      waddr = {HIF_ADDR_WIDTH{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<HIF_ADDR_WIDTH; width=width+1)
          waddr[width] = waddr[width] | (e_awaddr[sel*HIF_ADDR_WIDTH + width] & wgrant[sel]);

      wdata_ptr =  {WDATA_PTR_BITS{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<WDATA_PTR_BITS; width=width+1)
          wdata_ptr[width] = wdata_ptr[width] | (xa_wdata_ptr[sel*WDATA_PTR_BITS + width] & wgrant[sel]);

      wvalid = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        wvalid = wvalid | (e_awvalid[sel] & wgrant[sel]);      
      
      wautopre = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        wautopre = wautopre | (xa_wautopre[sel] & wgrant[sel]);

      rmw = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        rmw = rmw | (xa_rmw_dynamic[sel] & wgrant[sel]);

      wpri = {WQOS_RW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
         for (width=0; width<WQOS_RW; width=width+1)
            wpri[width] = wpri[width] | (pa_wpri[sel*WQOS_RW + width] & wgrant[sel]);
      
      wlatency = {WQOS_TW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<WQOS_TW; width=width+1)
          wlatency[width] = wlatency[width] | (pa_w_timeout[sel*WQOS_TW + width] & wgrant[sel]);

      // Multiplexer for Exclusive Write 
      wex_pyldr = {EXA_PYLD_W{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<EXA_PYLD_W; width=width+1)
          wex_pyldr[width] = wex_pyldr[width] | (e_wexa_pyld[sel*EXA_PYLD_W+ width] & wgrant[sel]);

      xpi_awlast_r = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
         xpi_awlast_r = xpi_awlast_r | (xpi_awlast[sel] & wgrant[sel]);

      xpi_short_burst_r = 1'b0;
      
      for (sel=0; sel<NPORTS; sel=sel+1)
         xpi_short_burst_r = xpi_short_burst_r | (xpi_short_burst[sel] & wgrant[sel]);

      wdata_mask_full_ie = {WRDATA_CYCLES{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
         for (width=0; width<WRDATA_CYCLES; width=width+1)
            wdata_mask_full_ie[width] = wdata_mask_full_ie[width] | (xa_wdata_mask_full[sel*WRDATA_CYCLES + width] & wgrant[sel]);

      wlength = {CMD_LEN_BITS{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
         for (width=0; width<CMD_LEN_BITS; width=width+1)
            wlength[width] = wlength[width] | (xa_wlength[sel*CMD_LEN_BITS + width] & wgrant[sel]);
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W415a
   end

   // Read command mux
   always @*
   begin: read_command_mux_COMB_PROC
      integer width, sel;
//spyglass disable_block W415a
//SMD: Signals assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches  
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((sel * HIF_ADDR_WIDTH) + width)' found in module 'DWC_ddr_umctl2_hif_cmd'
//SJ: This coding style is acceptable and there is no plan to change it
      raddr = {HIF_ADDR_WIDTH{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<HIF_ADDR_WIDTH; width=width+1)
          raddr[width] = raddr[width] | (e_araddr[sel*HIF_ADDR_WIDTH + width] & rgrant[sel]);

      rtoken = {MEMC_TAGBITS{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<MEMC_TAGBITS; width=width+1)
          rtoken[width] = rtoken[width] | (xa_rtoken[sel*MEMC_TAGBITS + width] & rgrant[sel]);

      rlatency = {RQOS_TW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<RQOS_TW; width=width+1)
          rlatency[width] = rlatency[width] | (pa_r_timeout[sel*RQOS_TW + width] & rgrant[sel]);

      rvalid = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        rvalid = rvalid | (e_arvalid[sel] & rgrant[sel]);
      
      rpri = {RQOS_RW{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
         for (width=0; width<RQOS_RW; width=width+1)
            rpri[width] = rpri[width] | (pa_rpri[sel*RQOS_RW + width] & rgrant[sel]);

      rlength = {CMD_LEN_BITS{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
         for (width=0; width<CMD_LEN_BITS; width=width+1)
            rlength[width] = rlength[width] | (xa_rlength[sel*CMD_LEN_BITS + width] & rgrant[sel]);

      rautopre = 1'b0;
      for (sel=0; sel<NPORTS; sel=sel+1)
        rautopre = rautopre | (xa_rautopre[sel] & rgrant[sel]);

      // Multiplexer for Exclusive Read 
      rex_pyldr = {EXA_PYLD_W{1'b0}};
      for (sel=0; sel<NPORTS; sel=sel+1)
        for (width=0; width<EXA_PYLD_W; width=width+1)
          rex_pyldr[width] = rex_pyldr[width] | (e_rexa_pyld[sel*EXA_PYLD_W+ width] & rgrant[sel]);
//spyglass enable_block SelfDeterminedExpr-ML
//spyglass enable_block W415a
   end

//spyglass disable_block W164a
//SMD: LHS: '{wcmd_vld_ie ,wcmd_end_ie_unused ,wptr_wexa_resp_unused ,wptr_wexa_acc ,wptr_wexa_acc_lock_unused ,wdata_ptr_remain_unused ,wptr_poison ,wptr_ocpar_err ,wptr_wport_num_unused}' width 18 is less than RHS: 'wdata_ptr' width 19 in assignment
//SJ: MSB of wdata_ptr (corresponding to xpi_exa_awlast_i) is intentionally ignored

   // IECC info
   assign {wcmd_vld_ie,wcmd_end_ie_unused,wptr_wexa_resp_unused,wptr_wexa_acc,wptr_wexa_acc_lock_unused,wdata_ptr_remain_unused,wptr_poison,wptr_ocpar_err,wptr_wport_num_unused}  = wdata_ptr;
   assign {rtoken_remain_unused,rcmd_vld_ie,rcmd_end_ie_unused,rtoken_lsb_unused} = rtoken;
//spyglass enable_block W164a

   // Grant input
   assign wgrant                       = pa_wgrant;
   assign rgrant                       = pa_rgrant;

   // mask_full reset for opcar/poison/exa
   assign wdata_mask_full_ie_i            = (wptr_poison | wptr_ocpar_err | wptr_wexa_acc) ? {WRDATA_CYCLES{1'b0}} : wdata_mask_full_ie;
   
   // HIF command output
   assign hif_hif_cmd_pri                 = (|wgrant) ? wpri : rpri; 
   assign hif_hif_cmd_token               = rtoken;
   assign hif_hif_cmd_length              = (|wgrant) ? wlength : rlength;
   assign hif_hif_cmd_latency             = (|wgrant) ? wlatency : rlatency;
   assign hif_hif_cmd_wdata_ptr           = wdata_ptr;
   assign hif_hif_cmd_type                = (|rgrant) ? READ_CMD : (rmw) ? RMW_CMD : WRITE_CMD;
   assign hif_hif_cmd_valid               = (|wgrant) ? wvalid : rvalid;
   assign hif_hif_cmd_addr                = (|wgrant) ? waddr : raddr;
   assign hif_hif_cmd_autopre             = (|rgrant) ? rautopre : wautopre;
   assign hif_hif_cmd_ecc_region          = (|wgrant) ? wcmd_vld_ie : rcmd_vld_ie;
   assign hif_hif_cmd_wdata_mask_full_ie  = wdata_mask_full_ie_i;

   // Exclusive Access payload
   assign hif_co_ih_exa_pyld_wr        = wex_pyldr;
   assign hif_co_ih_exa_pyld_rd        = rex_pyldr;
   assign hif_hif_cmd_awlast           = xpi_awlast_r;      
   assign hif_hif_cmd_short_burst      = xpi_short_burst_r; 
   
endmodule // DWC_ddr_umctl2_hif_cmd
