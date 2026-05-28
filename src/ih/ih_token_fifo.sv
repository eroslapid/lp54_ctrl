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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_token_fifo.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module ih_token_fifo
#(
    parameter DEPTH      = 16
   ,parameter WIDTH      = (DEPTH<3)?1:(DEPTH<5)?2:(DEPTH<9)?3:(DEPTH<17)?4:(DEPTH<33)?5:(DEPTH<65)?6:7
   ,parameter CNT_WIDTH  = (DEPTH<2)?1:(DEPTH<4)?2:(DEPTH<8)?3:(DEPTH<16)?4:(DEPTH<32)?5:(DEPTH<64)?6:7
   ,parameter FL_WIDTH   =  CNT_WIDTH
)
(  
    input                    clk       
   ,input                    rstn      
   ,input                    no_token           // No token allocated
   ,input  [WIDTH-1:0]       token_offset       // Token start number
   ,input  [WIDTH-1:0]       token_max          // Token end number 
   ,input                    allocate_token     // allocate token. this must be 0 when token_empty == 1
   ,output [WIDTH-1:0]       allocate_token_num // #token to be allocated. valid only when token_empty == 0 
   ,input                    release_token      // release token
   ,input  [WIDTH-1:0]       release_token_num  // #token to be released. valid only when release_token == 1
   ,output reg               token_empty        // No token available to be allocated
   ,output reg               token_full         // All token available
   ,output [FL_WIDTH-1:0]    fill_level         // How many tokan is available
   ,output [CNT_WIDTH-1:0]   num_token_used     // How many tokan is available

);

//---------------
// Declarations
//---------------

// Token array implemented as a shift register
reg  [WIDTH-1:0]     token_array         [0:DEPTH-1];
reg  [WIDTH-1:0]     token_array_next    [0:DEPTH-1];

// Write pointer
wire [WIDTH-1:0]     wr_pt;

// Number of token available
reg  [CNT_WIDTH-1:0] num_tokens_avail; 
reg  [CNT_WIDTH-1:0] fill_level_reg; 
reg  [CNT_WIDTH-1:0] num_token_used_reg;

assign fill_level = fill_level_reg[FL_WIDTH-1:0];

reg                  init_token_pre;
reg                  init_token;
wire                 init_token_done;
reg  [WIDTH-1:0]     init_shift_cnt;
wire                 init_shift;

wire  [WIDTH  :0]    token_num;

assign token_num = (token_max - token_offset) + {{WIDTH{1'b0}},1'b1};

//-------
// Logic
//-------
assign num_token_used     = num_token_used_reg; 
assign wr_pt              = num_tokens_avail[WIDTH-1:0];
// CNT_WIDTH > WIDTH only when DEPTH is power of two.
// For wr_pt, only use [WIDTH-1:0] because of the followings
// e.g.) DEPTH=16, maximum value of num_tokens_avail=16 (1_0000b)
// For write (allocate_token), this can be valid only when num_tokens_avail < DEPTH
// So use only [WIDTH-1:0] 

assign allocate_token_num = token_array[0];

wire [WIDTH  :0]  wr_pt_m1;
assign wr_pt_m1 = wr_pt - {{(WIDTH-1){1'b0}},1'b1};

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(wr_pt==(DEPTH - 1))' found in module 'ih_token_fifo'
//SJ: This coding style is acceptable and there is no plan to change it.

// Shift register logic
integer i;
always @(*) begin

  // For token_array_next[DEPTH]
  token_array_next[DEPTH-1] = token_array[DEPTH-1]; // Initial value (hold previous)
  if ((wr_pt==(DEPTH-1)) & release_token & (~allocate_token)) begin
    token_array_next[DEPTH-1] = release_token_num;
  end


  // For token_array_next[DEPTH-2:0]
  for (i=0; i<DEPTH-1; i=i+1) begin
    token_array_next[i] = token_array[i]; // Initial value (hold previous)
  
    if (release_token & allocate_token & ($unsigned(i)==wr_pt_m1[WIDTH-1:0])) begin
      token_array_next[i] = release_token_num;
    end
    else if (release_token & (~allocate_token) & (i==wr_pt)) begin
      token_array_next[i] = release_token_num;
    end
    else if (allocate_token | init_shift) begin
      token_array_next[i] = token_array[i+1];
    end

  end

end 
//spyglass enable_block SelfDeterminedExpr-ML

integer j;
always @ (posedge clk or negedge rstn) begin
   if(!rstn) begin
      for (j=0; j<DEPTH; j=j+1) begin
         token_array[j] <= j;
      end
   end 
   else begin
      for (j=0; j<DEPTH; j=j+1) begin
         token_array[j] <= token_array_next[j];
      end
   end
end

wire [CNT_WIDTH  :0] num_tokens_avail_p1;
wire [CNT_WIDTH  :0] num_tokens_avail_m1;

assign num_tokens_avail_p1 = num_tokens_avail + {{(CNT_WIDTH-1){1'b0}},1'b1};
assign num_tokens_avail_m1 = num_tokens_avail - {{(CNT_WIDTH-1){1'b0}},1'b1};

// Full/empty/pointer
always @ (posedge clk or negedge rstn) begin
   if(!rstn) begin
       token_full       <= 1'b1;
       token_empty      <= 1'b1;
       num_tokens_avail <= {CNT_WIDTH{1'b0}};
   end
   else begin
      if (no_token) begin
         num_tokens_avail <= {CNT_WIDTH{1'b0}};
         token_empty      <= 1'b1;
         token_full       <= 1'b1;
      end
      else if (init_token_done) begin
         num_tokens_avail <= token_num;
         token_empty      <= ~(|(token_num));
         token_full       <= (|(token_num));
      end
      else if (release_token & (~(allocate_token))) begin
         num_tokens_avail <= num_tokens_avail_p1[CNT_WIDTH-1:0];
         token_empty      <= 1'b0;
         if (num_tokens_avail_p1[WIDTH:0] == token_num) begin
            token_full    <= 1'b1;
         end
      end
      else if ((~(release_token)) & allocate_token) begin
         num_tokens_avail <= num_tokens_avail_m1[CNT_WIDTH-1:0];
         token_full       <= 1'b0;
         if (num_tokens_avail == {{(CNT_WIDTH-1){1'b0}},1'b1}) begin // num_tokens_avail == 1
            token_empty   <= 1'b1;
         end
      end

   end
end

always @ (posedge clk or negedge rstn) begin
   if(!rstn) begin
       init_token_pre   <= 1'b1;
       init_token       <= 1'b1;
       init_shift_cnt   <= {WIDTH{1'b0}};
   end
   else begin
       init_token_pre   <= 1'b0;
       init_token       <= init_token_pre;
       if (init_token) begin
         init_shift_cnt <= token_offset;
       end
       else if (|init_shift_cnt) begin
         init_shift_cnt <= init_shift_cnt - 1'b1;
       end
   end
end

assign init_shift      = (~init_token & |init_shift_cnt);
assign init_token_done = (init_token & token_offset=={WIDTH{1'b0}}) | (init_shift_cnt=={{WIDTH-1{1'b0}},1'b1});

wire   [CNT_WIDTH  :0] num_token_used_reg_nxt;
assign num_token_used_reg_nxt = token_num - num_tokens_avail;

always @ (posedge clk or negedge rstn) begin
   if(!rstn) begin
       fill_level_reg     <= {CNT_WIDTH{1'b1}};
       num_token_used_reg <= {CNT_WIDTH{1'b0}}; 
   end
   else begin
       num_token_used_reg <= num_token_used_reg_nxt[CNT_WIDTH-1:0];
       if (init_token_done) begin
          fill_level_reg     <= {CNT_WIDTH{1'b0}};
       end  
       else if (allocate_token & (~release_token)) begin
          fill_level_reg <= fill_level_reg + {{CNT_WIDTH-1{1'b0}},1'b1};
       end
       else if ((~allocate_token) & release_token) begin
          fill_level_reg <= fill_level_reg - {{CNT_WIDTH-1{1'b0}},1'b1};
       end
   end
end

`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions, Checks, etc.
//------------------------------------------------------------------------------
`ifdef SNPS_ASSERT_ON


// disable coverage collection as this is a check in SVA only        
// VCS coverage off
// Logic to check all entrys are unique (for assertion)
integer entryX;
integer entryY;
reg     not_uniq;
always @(*) begin
    not_uniq=0;
    for (entryX=0; entryX < num_tokens_avail; entryX=entryX+1) begin
        for (entryY=0; entryY < num_tokens_avail; entryY=entryY+1) begin
            if (entryX!=entryY & token_array[entryX] == token_array[entryY]) begin
                not_uniq = 1;
            end
        end
    end
end

// VCS coverage on

//-------------
// Assertions 
//-------------
property p_cam_enh_token_fifo_no_underflow;
  @ (posedge clk) disable iff (~rstn)
  allocate_token |-> num_tokens_avail>0; 
endproperty

property p_cam_enh_token_fifo_no_overflow; 
  @ (posedge clk) disable iff (~rstn)
  release_token |-> num_tokens_avail<DEPTH;
endproperty

property p_cam_enh_token_fifo_full_check; 
  @ (posedge clk) disable iff (~rstn)
  (((num_tokens_avail==token_num) == token_full) || init_shift || init_token || no_token);
endproperty

property p_cam_enh_token_fifo_empty_check; 
  @ (posedge clk) disable iff (~rstn)
  ((num_tokens_avail==0) == token_empty || no_token);
endproperty

property p_cam_enh_token_fifo_must_be_uniq;
  @ (posedge clk) disable iff (~rstn)
  (not_uniq==0);
endproperty

property p_cam_enh_token_fifo_num_tokens_avail_check;
  @ (posedge clk) disable iff (~rstn)
  (num_tokens_avail<= DEPTH);
endproperty

// Check that FIFO is never overflow
a_cam_enh_token_fifo_no_underflow : assert property (p_cam_enh_token_fifo_no_underflow)
else $error("%m %t ih_token_fifo underflow. allocate_token==1 is not allowed when token_empty==1", $time);

// Check that FIFO is never underflow
a_cam_enh_token_fifo_no_overflow : assert property (p_cam_enh_token_fifo_no_overflow)
else $error("%m %t ih_token_fifo overflow. release_token==1 is not allowed when no token is allocated", $time);

// Check that token_full is correct  
a_cam_enh_token_fifo_full_check : assert property (p_cam_enh_token_fifo_full_check)
else $error("%m %t token_full is not correct", $time);

// Check that token_empty is correct
a_cam_enh_token_fifo_empty_check : assert property (p_cam_enh_token_fifo_empty_check)
else $error("%m %t token_empty is not correct", $time);

// Check that all valid entrys are unique 
a_cam_enh_token_fifo_must_be_uniq : assert property (p_cam_enh_token_fifo_must_be_uniq)
else $error("%m %t ih_token_fifo token is not uniq.", $time);

// Check that num_tokens_avail is never exceeded to DEPTH
a_cam_enh_token_fifo_num_tokens_avail_check : assert property (p_cam_enh_token_fifo_num_tokens_avail_check)
else $error("%m %t num_tokens_avail must be less than or equal to DEPTH parameter.", $time);

//-------------
// Coverpoints 
//-------------
covergroup cg_cam_enh_token_fifo @(posedge clk);

  // Observe FIFO's usage
  cp_cam_enh_token_fifo_usage : coverpoint (num_tokens_avail) iff(rstn) {
     bins        usage[] = {[0:DEPTH]};
     bins         full   = {DEPTH};
     bins    half_full   = {DEPTH/2};
     bins almost_empty   = {1};
     bins        empty   = {0};
  }
  
  // Observe allocate and release token                      
  cp_cam_enh_token_fifo_wr_rd : coverpoint ({allocate_token, release_token}) iff(rstn) {
     bins allocate_only        = {{1'b1,1'b0}};
     bins release_only         = {{1'b0,1'b1}};
     bins allocate_and_release = {{1'b1,1'b1}};
  }

endgroup : cg_cam_enh_token_fifo

cg_cam_enh_token_fifo cg_cam_enh_token_fifo_inst = new;

`endif // SNPS_ASSERT_ON
`endif  // SYNTHESIS

endmodule
