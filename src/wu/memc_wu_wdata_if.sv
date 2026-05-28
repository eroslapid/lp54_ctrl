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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/wu/memc_wu_wdata_if.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
module memc_wu_wdata_if (  co_yy_clk, core_ddrc_rstn,
      ddrc_cg_en,
      reg_ddrc_occap_en,
      ddrc_occap_wufifo_parity_err,
      dh_wu_lpddr4,
      reg_ddrc_lpddr5,
      co_wu_wdata_valid, co_wu_wdata,
      co_wu_wdata_mask, 
         co_wu_wdata_par,
      ih_wu_wr_valid, 
      ih_wu_wr_valid_addr_err,
      ih_wu_rmw_type, ih_wu_wr_entry_num, ih_wu_critical_word,
      co_wu_data_end,
      te_wu_wr_retry,
      te_wu_wr_combine, te_wu_entry_num,
      reg_ddrc_burst_mode,
      waddr_in,
      wdata_in,
      wdatamask_in,
      wdatapar_in,
      wdata_valid_in,
      wdata_end_in,
      wu_ih_flow_cntrl_req,
      wu_fifo_empty,
      rmw_type_in,
      combine_vld_in,
      wdata_count_nxt,
      wdata_count
      );

//----------------------------- PARAMETERS --------------------------------------

parameter WRCAM_ADDR_WIDTH      = 4;      // bits to address into CAM
parameter WRDATA_RAM_ADDR_WIDTH = WRCAM_ADDR_WIDTH + 1;  // data width to RAM
parameter CORE_DATA_WIDTH       = `MEMC_DFI_DATA_WIDTH; // internal data width
parameter CORE_MASK_WIDTH       = `MEMC_DFI_DATA_WIDTH/8; // data mask width
parameter WDATA_PAR_WIDTH       = `UMCTL2_WDATARAM_PAR_DW;
parameter WRSRAM_DATA_WIDTH     = `MEMC_DFI_DATA_WIDTH;   // WR-SRAM data width
parameter WRSRAM_MASK_WIDTH     = `MEMC_DFI_DATA_WIDTH/8; // WR-SRAM data mask width

parameter CORE_DCERRBITS_PKG    = `MEMC_DCERRBITS*2;


parameter WORD_BITS    = 2;      // # of bits in critical word
parameter UMCTL2_SEQ_BURST_MODE   = 0;                    // Applies LPDDR4 like squential burst mode only  
parameter OCCAP_EN              = 0;
parameter OCCAP_PIPELINE_EN     = 0;

parameter PW_WORD_CNT_WD_MAX      = 2;
localparam FIFO_WIDTH   = WRCAM_ADDR_WIDTH+WORD_BITS+1+2
                                                 +1
                                   ;

localparam SL_W         = 8;
localparam PARW         = (OCCAP_EN==1) ? ((FIFO_WIDTH%SL_W>0) ? FIFO_WIDTH/SL_W+1 : FIFO_WIDTH/SL_W) : 0;

localparam FIFO_WIDTH_PAR = FIFO_WIDTH+PARW;


// VCS UNR CONSTRAINT declarations
`SNPS_UNR_CONSTANT("lower 2 hif address bits are always 0", 1, ih_wu_critical_word[1:0], 2'b00)


//------------------------- INPUTS AND OUTPUTS ---------------------------------

input                               co_yy_clk;              // system clock
input                               core_ddrc_rstn;         // asynchronous falling-edge reset
input                               ddrc_cg_en;             // clock gating enable signal
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block
input                               reg_ddrc_occap_en;
//spyglass enable_block W240
output                              ddrc_occap_wufifo_parity_err;
input                               dh_wu_lpddr4;           // 1: LPDDR4 mode, 0: non-LPDDR4 mode
input                               reg_ddrc_lpddr5;        // 1: LPDDR5 mode, 0: non-LPDDR5 mode

input                               co_wu_wdata_valid;      // valid write data from IH
                                                            //  valid when co_wu_wdata_valid=1
                                                            //  ~6 gate delays from inputs to flops
input  [CORE_DATA_WIDTH-1:0]        co_wu_wdata;            // write data from IH
                                                            //  valid when co_wu_wdata_valid=1
                                                            //  2 mux delays from this input before flopping
input  [CORE_MASK_WIDTH-1:0]        co_wu_wdata_mask;       // mask for data from IH
                                                            //  1=byte enabled
                                                            //  0=byte disabled
                                                            //  valid when co_wu_wdata_valid=1
                                                            //  2 mux delays from this input before flopping
input  [WDATA_PAR_WIDTH-1:0]        co_wu_wdata_par;        // write data parity

input                               ih_wu_wr_valid;    // new command issued to CAM
input                               ih_wu_wr_valid_addr_err;// if 1, ih_wu_wr_valid is associated with address error
input  [1:0]                        ih_wu_rmw_type;     // new command issued to CAM
input [WRCAM_ADDR_WIDTH-1:0]        ih_wu_wr_entry_num; // command is a read, valid when ih_wu_wr_valid=1
input [WORD_BITS-1:0]               ih_wu_critical_word;// critical word #, valid with ih_wu_wr_valid=1
input                               co_wu_data_end;     // for non-block writes, indicates last data phase
input                               te_wu_wr_retry;     // retry: stall from CAM when collisions occur
input                               te_wu_wr_combine;   // TE is providing an entry number to
                                                        //  be used for write combining
input  [WRCAM_ADDR_WIDTH-1:0]       te_wu_entry_num;    // entry number to be used
                                                        //  for write combining
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: LPDDR4 1:4 config does not use this signal But it always exists. If DDR4 1:4 config will not suppoert interleaved burst, this regsiter can be removed.
input                               reg_ddrc_burst_mode;  // 1 = interleaved burst, 0 = sequential burst
//spyglass enable_block W240




// outputs from this interface block; inputs to the WU core
output  [WRDATA_RAM_ADDR_WIDTH-1:0] waddr_in;
output  [CORE_DATA_WIDTH-1:0]       wdata_in;
output  [CORE_MASK_WIDTH-1:0]       wdatamask_in;
output  [WDATA_PAR_WIDTH-1:0]       wdatapar_in;
output                              wdata_valid_in;   // valid write data from core
output                              wdata_end_in;     // last data phase from core
output  [1:0]                       rmw_type_in;      // rmw_type coming from IH
output                              combine_vld_in;   // write combine indicator out of input FIFO

output                              wu_ih_flow_cntrl_req; // indicates that the wu_wdata_if fifo is full
output                              wu_fifo_empty;        // indicates that the wu_wdata_if fifo is empty

output  [2:0]                       wdata_count_nxt;      
output  [2:0]                       wdata_count;      

//------------------------- REGISTERS AND WIRES --------------------------------

// Count data phases.  For each entry use:
reg  [2:0]                      wdata_count;      

// outputs of FIFO: not really flops
wire  [WRCAM_ADDR_WIDTH-1:0]    wr_entry_num_ff;    // write entry # from IH
wire  [WORD_BITS-1:0]           critical_word_ff;   // critical word
wire  [1:0]                     rmw_type_in;        // rmw_type coming out from the fifo in this module
wire  [1:0]                     i_rmw_type_in;      // rmw_type coming out from the fifo in this module

// outputs from this interface block; inputs to the WU core
wire  [WRDATA_RAM_ADDR_WIDTH-1:0] i_waddr_in;
wire  [WRDATA_RAM_ADDR_WIDTH-1:0] waddr_in;
wire  [CORE_DATA_WIDTH-1:0]     wdata_in;
wire  [CORE_MASK_WIDTH-1:0]     wdatamask_in;
wire  [WDATA_PAR_WIDTH-1:0]     wdatapar_in;
wire                            wdata_valid_in;   // valid write data from core
wire                            wdata_end_in;     // last data phase from core
wire                            combine_vld_in;   // write combine indicator out of input FIFO
wire                            wr_valid_addr_err_in;   // if 1, write is associated with address error

wire                            co_wu_wdata_valid_mux;   
wire                            co_wu_data_end_mux;
wire [CORE_DATA_WIDTH-1:0]      co_wu_wdata_mux;        
wire [CORE_MASK_WIDTH-1:0]      co_wu_wdata_mask_mux;  
wire [WDATA_PAR_WIDTH-1:0]      co_wu_wdata_par_mux;  


// When doing write_combine, select the entry coming from TE. Else use the entry from IH
wire  [WRCAM_ADDR_WIDTH-1:0]    put_wr_entry_num = te_wu_wr_combine ? te_wu_entry_num : ih_wu_wr_entry_num;

wire                            wdata_reqd;
// expect data for partial writes or non-RMW transactions
// (don't expect data for ECC scrubs for RMW commands)
//ccx_cond_begin: ; ;00; ih_wu_rmw_type signal is always set to MEMC_RMW_TYPE_PARTIAL_NBW or MEMC_RMW_TYPE_NO_RMW when LP4/5 controller.
assign    wdata_reqd = (ih_wu_rmw_type == `MEMC_RMW_TYPE_PARTIAL_NBW) ||
                       (ih_wu_rmw_type == `MEMC_RMW_TYPE_NO_RMW     )   ;
//ccx_cond_end

// FIFO empty: used for SystemVerilog assertions, AND ddrc's ddrc_cg_en (MEMC_LPDDR3 or INLINE ECC).
// In case of writes with invalid address (MEMC_LPDDR3 or INLINE ECC), there is the posibility that ddrc_cg_en goes low 
// (because CAM thinks that does not expect any write data) and FIFO still contains entry with wr_valid_addr_err==1
// (so that it is discarded by the next co_wu_wdata_valid).
wire wu_fifo_empty;


//----------------------- LOGIC AND INSTANTIATIONS -----------------------------

wire [2:0]                      wdata_count_nxt;
wire [3:0]                      wdata_count_nxt_wider;

//assign wdata_count_nxt_wider = (wdata_end_in & wdata_valid_in) ? 3'b000 :
//                         (wdata_count + {2'b00,wdata_valid_in});
assign wdata_count_nxt_wider = ((co_wu_data_end & co_wu_wdata_valid) 
) ? 3'b000 :
                                (wdata_count + {2'b00,co_wu_wdata_valid 
});
assign wdata_count_nxt = wdata_count_nxt_wider[2:0];

// count words accepted (increment by 1 always)
// if non-block, reset the count to 0 when end is received
always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn)  wdata_count <= 3'b000;
  else if(ddrc_cg_en)   wdata_count <=  wdata_count_nxt;
  end // always flops



//---------cerr, rmw cerr opt begin

//---------cerr, rmw cerr opt end




assign co_wu_wdata_valid_mux  = co_wu_wdata_valid;
assign co_wu_data_end_mux     = co_wu_data_end;
assign co_wu_wdata_mux        = co_wu_wdata;
assign co_wu_wdata_mask_mux   = co_wu_wdata_mask;
assign co_wu_wdata_par_mux    = co_wu_wdata_par;




assign  wdata_end_in    = co_wu_data_end_mux;
assign  wdata_valid_in  = co_wu_wdata_valid_mux
                                & ~wr_valid_addr_err_in
                            ;
// ----------------------------------------------------------------------------
// FIFO - with parity
// ----------------------------------------------------------------------------

wire                      fifo_put;
wire                      fifo_get;
wire [FIFO_WIDTH_PAR-1:0] fifo_din_par; 
wire [FIFO_WIDTH_PAR-1:0] fifo_dout_par;
wire [FIFO_WIDTH-1:0]     fifo_din; 
wire [FIFO_WIDTH-1:0]     fifo_dout;
// put into the FIFO for write commands that
//  will have write data (this means all writes,
//  except read-mod-writes, and not when being retried
assign fifo_put = ih_wu_wr_valid & wdata_reqd & (~te_wu_wr_retry);
//assign fifo_get = co_wu_wdata_valid_mux & wdata_end_in;


assign fifo_get = (co_wu_wdata_valid & co_wu_data_end) 
 ;

// drive inputs to fifo
assign fifo_din = {put_wr_entry_num,ih_wu_critical_word,te_wu_wr_combine,ih_wu_rmw_type
                                          ,ih_wu_wr_valid_addr_err
                                         };
// drive output from fifo
assign {wr_entry_num_ff ,critical_word_ff,combine_vld_in,i_rmw_type_in
                                      ,wr_valid_addr_err_in
                                     } = fifo_dout;           


ingot_sync_fifo_flopout_rst
 #(.DEPTH_LOG2   (WRCAM_ADDR_WIDTH),
                              .WIDTH        (FIFO_WIDTH_PAR) 
                             )
    ingot_sync_fifo_flopout_rst (
    .clk          (co_yy_clk),
    .rstb         (core_ddrc_rstn),
    .clk_gate_en  (ddrc_cg_en),
    .din          (fifo_din_par),
          // put into the FIFO for write commands that
          //  will have write data (this means all writes,
          //  except read-mod-writes, and not when being retried
    .put          (fifo_put),
    //spyglass disable_block W528
    //SMD: A signal or variable is set but never read
    //SJ: Used in RTL assertion
    .empty        (wu_fifo_empty),
    //spyglass enable_block W528
    .dout         (fifo_dout_par),
    .get          (fifo_get),
    .full         (wu_ih_flow_cntrl_req)  );

    wire par_err;

    // drive output
    assign ddrc_occap_wufifo_parity_err = par_err;

     generate
    if (OCCAP_EN==1) begin: PAR_check

      wire [PARW-1:0] parity_dummy, mask_in;

      wire [PARW-1:0] din_par, dout_par, parity_err;
      wire [PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;

      wire pgen_en, pcheck_en;

      assign parity_dummy  = {PARW{1'b1}};
      assign mask_in       = {PARW{1'b1}};

      wire poison_en       = 1'b0;
      wire par_en          = reg_ddrc_occap_en;

      assign pgen_en    = fifo_put;
      assign pcheck_en  = par_en & fifo_get & ~wu_fifo_empty;


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (FIFO_WIDTH),
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (fifo_din),
            .parity_en     (pgen_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (din_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         DWC_ddr_umctl2_ocpar_calc
         
         #(
            .DW      (FIFO_WIDTH),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (fifo_dout),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (dout_par), // parity in
            .mask_in       (mask_in),
            .parity_out    (parity_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) //not used
         );

      assign fifo_din_par = {fifo_din,din_par};
      assign {fifo_dout,dout_par} = fifo_dout_par;


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
    else begin: OCCAP_dis
   
      assign par_err = 1'b0;
      assign fifo_din_par = fifo_din;
      assign fifo_dout    = fifo_dout_par;

    end // OCCAP_dis
   endgenerate


// ----------------------------------------------------------------------------
// end of FIFO with Parity
// ----------------------------------------------------------------------------
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used only if UMCTL2_SEQ_BURST_MODE is set

wire   lpddr_mode;
assign lpddr_mode =                        (dh_wu_lpddr4 | reg_ddrc_lpddr5) ? 1'b1 :
                                                           1'b0;
//spyglass enable_block W528


// Currently MEMC_BURST_LENGTH_16 is only used LPDDR4. And LPDDR4 dose not suppoert Interleaved order. So this logic does not support Interleaved order.
wire [0:0] critical_word_ff_sel;
assign critical_word_ff_sel = critical_word_ff[3];
wire          word_num;
assign        word_num = (wdata_count[0] ^ critical_word_ff_sel);


// Address consists of {entry_num,word_num}
//assign  i_waddr_in = {wr_entry_num_ff,word_num};
assign waddr_in = {wr_entry_num_ff,word_num};
assign rmw_type_in  = i_rmw_type_in;

// Set the input data.
// If there are 8 or 4 clocks of data for every CAM entry, then the incoming data is put directly into the RAM
// without caring to shift data based on the lower-bit of critical_word
// Both bits of critical word is used in deciding the address in the RAM
assign  wdata_in = co_wu_wdata_mux[CORE_DATA_WIDTH-1:0];

assign  wdatamask_in = co_wu_wdata_mask_mux[CORE_MASK_WIDTH-1:0];

assign  wdatapar_in = co_wu_wdata_par_mux[WDATA_PAR_WIDTH-1:0];






`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON
localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

wire sv_assert_full = wu_ih_flow_cntrl_req ;

wu_valid_data_in: //---------------------------------------------------
    assert property ( @ (posedge co_yy_clk)
                      disable iff (~core_ddrc_rstn)
                      (!(co_wu_wdata_valid & wu_fifo_empty)) )
    else $error("[%t] [%m] Unexpected data received by WU", $time);

wu_cmd_in_fifo_overflow: //--------------------------------------------
    assert property ( @ (posedge co_yy_clk)
                      disable iff (~core_ddrc_rstn)
                      (!(ih_wu_wr_valid & wdata_reqd & (~te_wu_wr_retry) & sv_assert_full)) )
    else $error("[%t] [%m] WU Write command FIFO overflowed", $time);
    
// wdata_count_nxt overflow
assert_never #(0, 0, "wdata_count_nxt overflow", CATEGORY) a_wdata_count_nxt_overflow
  (co_yy_clk, core_ddrc_rstn, (wdata_count_nxt_wider[3]==1'b1));

`endif // SNPS_ASSERT_ON 
`endif // SYNTHESIS

endmodule // memc_wu_wdata_if
