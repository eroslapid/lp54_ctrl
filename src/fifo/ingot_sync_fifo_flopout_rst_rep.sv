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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/fifo/ingot_sync_fifo_flopout_rst_rep.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// This a generic synchronous FIFO design for power-of-2 FIFO depths.  All outputs are 
// flopped out.  Max of 3 gate delays from any input to a flop.  Latencies are the same
// as for the non-flop-out version of this FIFO, but this one is slightly larger in area, 
// due to some extra flops.
// 
// This has an additional feature to replicate the output flops on lower bits
// based on the value of the parameter FLOP_REPLICATE_WIDTH. This was created as a custom
// solution for IH module in order to reduce the loading on the the address bits going
// to different modules with in DDRC.
//
// All FIFO contents reset to 'b0.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ingot_sync_fifo_flopout_rst_rep (
    clk,
    rstb,
    put,
    din,
    get,
    dout,
    dup_dout,
    full,
    empty  );

//------------------------------- PARAMETERS -----------------------------------

parameter  WIDTH = 8;
parameter  FLOP_REPLICATE_WIDTH = 1;  // won't compile if 0
parameter  DEPTH_LOG2 = 3;

localparam  DEPTH = 1 << DEPTH_LOG2;

//--------------------------- INPUTS and OUTPUTS -------------------------------

input               clk;      // clock
input               rstb;     // active low async reset
input               put;      // 1=put data into FIFO (if !full)
input  [WIDTH-1:0]  din;      // data to put in FIFO, valid when put=1
input               get;      // 1=get data out of FIFO (if !empty)
output [WIDTH-1:0]  dout;     // data out from FIFO, valid when empty=0
output              full;     // 1=FIFO is full
output              empty;    // 1=FIFO is empty

output  [FLOP_REPLICATE_WIDTH-1:0] dup_dout;  // some bits of dout (address bits) is replicated on these bits
            // this is done to reduce the load on the flops

//---------------------------- WIRES and REGS ----------------------------------

reg  [WIDTH-1:0]  mem [0:DEPTH-1];  // memory for storing FIFO data
reg  [WIDTH-1:0]  dout;             // data flopped out of RAM
wire [WIDTH-1:0]  dout_wire;        // data flopped out of RAM

reg  [FLOP_REPLICATE_WIDTH-1:0] dup_dout;  // some bits of dout (address bits) is replicated on these bits
                                                // this is done to reduce the load on the flops

reg  [DEPTH_LOG2:0]  wptr;      // write pointer, with extra wrap bit
reg  [DEPTH_LOG2:0]  rptr;      // read pointer, with extra wrap bit

reg                  full;      // FIFO full indicator
reg                  empty;     // FIFO empty indicator

wire  [DEPTH_LOG2:0]  wptr_inc;    // write pointer incremented by 1
wire  [DEPTH_LOG2:0]  rptr_inc;    // read pointer incremented by 1
wire  [DEPTH_LOG2:0]  wptr_nxt;    // next write pointer, with extra wrap bit
wire  [DEPTH_LOG2:0]  rptr_nxt;    // next read pointer, with extra wrap bit
wire  [DEPTH_LOG2-1:0] ram_wptr;   // write pointer w/ extra bit removed
wire  [DEPTH_LOG2-1:0] ram_rptr_nxt;    // read pointer for the next cycle w/ extra bit removed
wire                    almost_full;    // only 1 entry available in FIFO
wire                    almost_empty;   // only 1 entry used in FIFO

integer  i;          // loop counter

//----------------------------- MAINLINE CODE ----------------------------------

assign wptr_inc     = wptr + 1;                      // automatically wraps
assign rptr_inc     = rptr + 1;                      // automatically wraps

assign wptr_nxt     = (put & ~full)  ? wptr_inc : wptr;
assign rptr_nxt     = (get & ~empty) ? rptr_inc : rptr;

assign ram_wptr     = wptr[DEPTH_LOG2-1:0];             // get rid of extra bit
assign ram_rptr_nxt = rptr_nxt[DEPTH_LOG2-1:0];         // get rid of extra bit

// almost_full if one more write will make this full
// full condition = read pointer same as write pointer w/ different wrap bit
assign almost_full  = (wptr_inc[DEPTH_LOG2]     != rptr[DEPTH_LOG2])    &&
        (wptr_inc[DEPTH_LOG2-1:0] == rptr[DEPTH_LOG2-1:0])  ;
// almost_empty if one more read will make the FIFO empty
// empty condition is read pointer same as write pointer
assign almost_empty  = (wptr[DEPTH_LOG2:0] == rptr_inc[DEPTH_LOG2:0]);

always @(posedge clk or negedge rstb)
    if (~rstb) begin
  full  <= 1'b0;
  empty  <= 1'b1;
  rptr  <= {DEPTH_LOG2+1{1'b0}};
  wptr  <= {DEPTH_LOG2+1{1'b0}};
    end
    else begin
  // NOTE: This implementation provides full & empty clean off
  //       a flop with no delay, and is optimized for timing from
  //       put and get: 3 gate delays from either signal to a flop
  full  <= (almost_full & put & ~get) | (full & ~get);
  empty <= (almost_empty & get & ~put) | (empty & ~put);
  rptr  <= rptr_nxt;
  wptr  <= wptr_nxt;
    end

// created a wire
assign dout_wire = mem[ram_rptr_nxt];

// assign data memory
always @(posedge clk or negedge rstb)
    if (~rstb) begin
  for (i=0; i<DEPTH; i=i+1) begin
      mem[i] <= {WIDTH{1'b0}};
  end
  dout  <= {WIDTH{1'b0}};
  dup_dout <= {FLOP_REPLICATE_WIDTH{1'b0}};
    end
    else
    begin

  if (put & !full)
      mem[ram_wptr] <= din;

  // flop data out; bypass data to output if empty or becoming empty
  dout  <= (put & !full & (empty | (almost_empty & get))) ? din : mem[ram_rptr_nxt];

  // only the flops meant for replication goes through the following flops
  dup_dout <= (put & !full & (empty | (almost_empty & get))) ? din[FLOP_REPLICATE_WIDTH-1:0] : dout_wire[FLOP_REPLICATE_WIDTH-1:0];

    end

endmodule // ingot_sync_fifo_flopout_rst_replicate
