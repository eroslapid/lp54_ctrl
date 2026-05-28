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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/te/te_oldest_tracker.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// -------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
module te_oldest_tracker #(
    //-------------------------------- PARAMETERS ----------------------------------
     parameter  CAM_ENTRIES      = 32
    ,parameter  CAM_ADDR_BITS    = 5 
    )
    (    
    //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input                                             core_ddrc_rstn 
    ,input                                             core_ddrc_core_clk
    ,input                                             push
    ,input   [CAM_ADDR_BITS-1:0]                       push_entry
    ,input                                             pop
    ,input   [CAM_ADDR_BITS-1:0]                       pop_entry
    ,output  [CAM_ADDR_BITS-1:0]                       oldest_entry
);
   
reg                                  r_push;
reg  [CAM_ADDR_BITS-1:0]             r_push_entry;  
reg                                  r_pop;
reg  [CAM_ADDR_BITS-1:0]             r_pop_entry;  
reg  [CAM_ENTRIES-1:0]               age_fifo_vld;
wire [CAM_ENTRIES-1:0]               age_fifo_vld_next;
reg  [CAM_ADDR_BITS-1:0]             age_fifo     [CAM_ENTRIES-1:0];
wire [CAM_ADDR_BITS-1:0]             age_fifo_next[CAM_ENTRIES-1:0];
wire [CAM_ENTRIES-1:0]               age_fifo_shift;
reg  [CAM_ADDR_BITS  :0]             age_fifo_wp;
wire [CAM_ENTRIES-1:0]               age_fifo_cmp;
wire                                 age_fifo_cmp0_bp;
reg                                  age_fifo_cmp0_bp_r;


// Flops for history matrix
always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        r_push         <= 1'b0;
        r_push_entry   <= {CAM_ADDR_BITS{1'b0}};
        r_pop          <= 1'b0;
        r_pop_entry    <= {CAM_ADDR_BITS{1'b0}};
    end
    else begin
        r_push         <= push;
        r_push_entry   <= push_entry;    
        r_pop          <= pop;
        r_pop_entry    <= pop_entry;
    end
end

assign oldest_entry = age_fifo[0];

//------------------------
// Age FIFO
//------------------------

  
genvar idx1;
generate 
    assign age_fifo_cmp0_bp     = (age_fifo_vld[0] & pop & age_fifo[0] == pop_entry);
    assign age_fifo_shift[0]    = age_fifo_cmp0_bp | age_fifo_cmp0_bp_r; // Non Flopped version | Flopped version (shift twice)
    assign age_fifo_cmp[0]      = age_fifo_cmp0_bp_r; // Flopped version
    assign age_fifo_next[0]     = (r_push & (
                                    (r_pop & age_fifo_wp=={{CAM_ADDR_BITS{1'b0}},1'b1}) // Push & Pop
                                  | (~r_pop & age_fifo_wp=={CAM_ADDR_BITS+1{1'b0}})     // Push only
                                  | (age_fifo_cmp0_bp & (~age_fifo_vld[1])))            // Bypass path
                                                      ) ? r_push_entry : 
                                    (age_fifo_shift[0]) ? age_fifo[1]  : 
                                                          age_fifo[0];

    assign age_fifo_vld_next[0] = (r_push & (
                                    (r_pop & age_fifo_wp=={{CAM_ADDR_BITS{1'b0}},1'b1}) // Push & Pop
                                  | (~r_pop & age_fifo_wp=={CAM_ADDR_BITS+1{1'b0}})     // Push only
                                  | (age_fifo_cmp0_bp & (~age_fifo_vld[1])))            // Bypass path
                                                      ) ? 1'b1               : 
                                    (age_fifo_shift[0]) ? age_fifo_vld[1]  : 
                                                          age_fifo_vld[0];
//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(idx1 + 1'b1)' found in module 'te_oldest_tracker'
//SJ: This coding style is acceptable and there is no plan to change it.
    for (idx1=1;idx1<CAM_ENTRIES;idx1=idx1+1) begin :age_fifo_1_to_CAM_ENTRIES
        assign age_fifo_cmp[idx1]   = (age_fifo_vld[idx1] & r_pop & (age_fifo[idx1] == r_pop_entry));
        assign age_fifo_shift[idx1] = |age_fifo_cmp[idx1:0];
    end
    for (idx1=1;idx1<CAM_ENTRIES-1;idx1=idx1+1) begin :age_fifo_0_to_CAM_ENTRIESm1
        assign age_fifo_next[idx1]  = (r_push & ((r_pop & age_fifo_wp==idx1 + 1'b1) | (~r_pop & age_fifo_wp==idx1))) ? r_push_entry : 
                                                                                              (age_fifo_shift[idx1]) ? age_fifo[idx1+1] : 
                                                                                                                       age_fifo[idx1];
        assign age_fifo_vld_next[idx1]  = (r_push & ((r_pop & age_fifo_wp==idx1 + 1'b1) | (~r_pop & age_fifo_wp==idx1)))?  1'b1 :
                                              (age_fifo_shift[idx1]) ? age_fifo_vld[idx1+1] : 
                                                                       age_fifo_vld[idx1];
    end
//spyglass enable_block SelfDeterminedExpr-ML
    assign age_fifo_next[CAM_ENTRIES-1]     = (r_push & (~r_pop) & (&age_fifo_wp[CAM_ADDR_BITS-1:0])) ? r_push_entry : age_fifo[CAM_ENTRIES-1]; 
    assign age_fifo_vld_next[CAM_ENTRIES-1] = (r_push & (~r_pop) & (&age_fifo_wp[CAM_ADDR_BITS-1:0])) ? 1'b1 : 
                                              (age_fifo_shift[CAM_ENTRIES-1]) ? 1'b0 :
                                                                                age_fifo_vld[CAM_ENTRIES-1];
endgenerate

integer idx2;

always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        for (idx2=0;idx2<CAM_ENTRIES;idx2=idx2+1) begin
            age_fifo[idx2] <= {CAM_ADDR_BITS{1'b0}};
            age_fifo_vld[idx2] <= 1'b0;
        end
        age_fifo_wp <= {CAM_ADDR_BITS{1'b0}};
        age_fifo_cmp0_bp_r <= 1'b0;
   end
   else begin
       for (idx2=0;idx2<CAM_ENTRIES;idx2=idx2+1) begin
           age_fifo[idx2]     <= age_fifo_next[idx2];
           age_fifo_vld[idx2] <= age_fifo_vld_next[idx2];
       end
       age_fifo_cmp0_bp_r <= age_fifo_cmp0_bp;

       if (r_push & ~r_pop) begin
           age_fifo_wp <= age_fifo_wp + 1'b1;
       end
       else if (~r_push & r_pop) begin
           age_fifo_wp <= age_fifo_wp - 1'b1;
       end 
   end
end



`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

// age_fifo_vld should be 
// 00000000000000
// 00000000000001
// 00000000000011
// 00000000000111
// 00000000001111
// 00000000011111
// 00000000111111
property p_check_vld_seq;
  @ (posedge core_ddrc_core_clk) disable iff (~core_ddrc_rstn)
  ($onehot(age_fifo_vld[CAM_ADDR_BITS-1:0] + 65'd1)); 

endproperty

a_check_vld_seq: assert property (p_check_vld_seq);


`endif
`endif

endmodule 


