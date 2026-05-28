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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_odt.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
// Global Scheduler sub-unit.  This block controls the ODT (on-die termination)
// signals based on DH unit programming and gs_next_xact outputs.
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_odt
import DWC_ddrctl_reg_pkg::*;
#(
// ---------------------------------------------------------------------------------
//  PARAMETERS
// ---------------------------------------------------------------------------------
     parameter  NUM_RANKS       = `MEMC_NUM_RANKS
    ,parameter  NUM_LANES       = 4 // Number of byte lanes in PHY - default is 4
)
(
// ---------------------------------------------------------------------------------
//  I/O SIGNALS
// ---------------------------------------------------------------------------------
     input                                              co_yy_clk                       // clock
    ,input                                              core_ddrc_rstn                  // async falling-edge reset
    ,input                                              dh_gs_frequency_ratio           // Freq ratio, 0 - 1:2 freq ratio, 1 - 1:1 freq ratio

    ,input  [NUM_RANKS-1:0]                             dh_gs_rank0_wr_odt              // ODT settings for each rank + controller when writing to rank 0
    ,input  [NUM_RANKS-1:0]                             dh_gs_rank0_rd_odt              // ODT settings for each rank + controller when reading from rank 0
    ,input                                              dh_gs_lpddr4                    // select LPDDR4
    ,input                                              reg_ddrc_lpddr5                 // select LPDDR5
    ,input                                              gs_op_is_rd                     // read command being issued
    ,input                                              gs_op_is_wr                     // write command being issued

    ,input                                              gs_pi_mrr                       // Indicates internal or external MR4 read
    ,input                                              gs_op_is_load_mode              // load mode register

    ,input                                              dh_gs_2t_mode                   // 1= 2T mode, 0 = regular mode
    ,input                                              gs_pi_mrr_ext                   // Indicates any external MRR operation
    ,output [`MEMC_FREQ_RATIO * NUM_RANKS-1:0]          gs_pi_odt                       // per-rank ODT controls
    ,output reg                                         gs_pi_odt_pending               // waiting for the ODT command to complete

    ,input  [DFI_TPHY_WRCSLAT_WIDTH-1:0]                reg_ddrc_dfi_tphy_wrcslat
    ,input  [6:0]                                       reg_ddrc_dfi_tphy_rdcslat
    ,input                                              reg_ddrc_dfi_data_cs_polarity
    ,output [`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES-1:0]  gs_pi_wrdata_cs_n
    ,output [`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES-1:0]  gs_pi_rddata_cs_n
    ,input                                              gs_odt_cg_en
);

    // ---------------------------------------------------------------------------------
    //  LOCAL PARAMETERS
    // ---------------------------------------------------------------------------------
    localparam ODT_SHIFT_REG_SIZE       = 48;
    localparam DATA_CS_N_SHIFT_REG_SIZE = 128;
    localparam FREQ_RATIO               = 2;

    // ---------------------------------------------------------------------------------
    //  WIRES and REGSTERS
    // ---------------------------------------------------------------------------------
    wire    [NUM_RANKS-1:0]     odt_for_this_cmd;           // per-rank ODT signals that will
                                                            // eventually be driven for data
                                                            // phases associated with the
                                                            // command currently being issued

    reg     [NUM_RANKS-1:0]     odt_shift_reg[ODT_SHIFT_REG_SIZE-1:0];    // Shift register to store ODT

    wire                        mrr;                        // ODT associated with mrr cmd
    wire                        mpr_rd;
    wire                        pda_wr;                     // MRS command issued to DRAM in PDA mode

    integer i;

    // ---------------------------------------------------------------------------------
    //  CIRCUIT
    // ---------------------------------------------------------------------------------
    assign mpr_rd       = 1'b0;
    assign pda_wr       = 1'b0;
    assign mrr          = gs_op_is_load_mode & (gs_pi_mrr_ext | gs_pi_mrr)
    ;



    // Calculate the value to be sent on dfi_odt for the command currently being sent.
    // This value will be put in the shift register and sent at a later time (depending on ODT delay/hold configuration registers)
    assign odt_for_this_cmd = 
                            (gs_op_is_wr | pda_wr)   ?   dh_gs_rank0_wr_odt :
                            (gs_op_is_rd | mpr_rd)   ?   dh_gs_rank0_rd_odt :
                            mrr                             ?   dh_gs_rank0_rd_odt :
                                                                      {NUM_RANKS{1'b0}}   ;

    // Calculate how many cycles after a write command we should switch ODT on and off
    wire [5:0] wr_odt_on;
    assign wr_odt_on   =
            ({5'b0, dh_gs_2t_mode}        // Delay by 1 cycle in 2T mode
        );
    
    wire [6:0] wr_odt_off_wider;
    assign wr_odt_off_wider = wr_odt_on
                   ; 
    wire [5:0] wr_odt_off;
    assign wr_odt_off       = wr_odt_off_wider[5:0];

    // Calculate how many cycles after a read command we should switch ODT on and off
    wire [5:0] rd_odt_on;
    assign rd_odt_on   =  
               ({5'b0, dh_gs_2t_mode}        // Delay by 1 cycle in 2T mode
                + {5'h0, (mrr & ~dh_gs_frequency_ratio)}                                                           // MRR on odd phase in FR 1:2, so delay by 1 only if FR 1:2
    );        // Delay by 1 cycle in 2T mode
    
    wire [6:0] rd_odt_off_wider;
    assign rd_odt_off_wider = rd_odt_on 
                    ; 
    wire [5:0] rd_odt_off;
    assign rd_odt_off       = rd_odt_off_wider[5:0];

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(i + 1)' found in module 'gs_odt'
//SJ: This coding style is acceptable and there is no plan to change it.

//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop DWC_ddr_umctl2.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ts.gs.gs_odt.odt_shift_reg[179:0] (master RTL_FDCE) is  always enabled (tied high)(connected to DWC_ddr_umctl2.U_ddrc.ddrc_ctrl_wrapper.\ddrc_ctrl_inst[0].ddrc_ctrl .ts.gs.VCC)
//SJ: ddrc_ctrl_inst[0] always enabled for single rank config

    // ODT shift register
    // This is loaded when a command is being sent.  The location and number of entries loaded depend on the wr/rd_odt_on/off signals.
    // The shift register is shifted down each cycle
    // The lowest entry (or two entries if MEMC_FREQ_RATIO=2) become gs_pi_odt, and are sent to the PI block
    always  @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            for (i=0; i<ODT_SHIFT_REG_SIZE; i=i+1)
                odt_shift_reg[i] <= {NUM_RANKS{1'b0}};
        end else if(gs_odt_cg_en)
        begin
            for (i=0; i<ODT_SHIFT_REG_SIZE; i=i+1) begin
                if (( $unsigned(i) >= wr_odt_on && $unsigned(i) < wr_odt_off) &&
                    (gs_op_is_wr || pda_wr
                    ))
                    odt_shift_reg[i] <= odt_for_this_cmd;
                else if (($unsigned(i) >= rd_odt_on && $unsigned(i) < rd_odt_off) &&
                    (gs_op_is_rd || mpr_rd
                        || mrr
                    ))
                    odt_shift_reg[i] <= odt_for_this_cmd;
                else if (i > ODT_SHIFT_REG_SIZE - 3)
                    // Fill the top entries of the shift register with 0s
                    odt_shift_reg[i] <= {NUM_RANKS{1'b0}};
                else if (i == ODT_SHIFT_REG_SIZE - 3) begin
                    if (!dh_gs_frequency_ratio)
                        odt_shift_reg[i] <= {NUM_RANKS{1'b0}};
                    else
                        odt_shift_reg[i] <= odt_shift_reg[i+1];
                end else
                    odt_shift_reg[i] <= 
                                       (dh_gs_frequency_ratio)
                                        ? odt_shift_reg[i+1] :
                                          odt_shift_reg[i+FREQ_RATIO];
            end
        end
    end
//spyglass enable_block FlopEConst

//spyglass enable_block SelfDeterminedExpr-ML

    // Output to PI block.  This is the lowest entry (or two entries if MEMC_FREQ_RATIO = 2) of the shift register
    assign gs_pi_odt[NUM_RANKS-1:0] = odt_shift_reg[0];
    assign gs_pi_odt[2*NUM_RANKS-1:NUM_RANKS] = odt_shift_reg[1];
    assign gs_pi_odt[3*NUM_RANKS-1:2*NUM_RANKS] = (~dh_gs_frequency_ratio) ? {NUM_RANKS{1'b0}} : odt_shift_reg[2];
    assign gs_pi_odt[4*NUM_RANKS-1:3*NUM_RANKS] = (~dh_gs_frequency_ratio) ? {NUM_RANKS{1'b0}} : odt_shift_reg[3];
   
//spyglass disable_block W415a
//SMD: Signal gs_pi_odt_pending is being assigned multiple times in same always block. 
//SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches

    // waiting for the ODT command to complete - used in PI block for ctrlupd/phyupd logic
    always @(*) begin
        gs_pi_odt_pending = 1'b0;
        for (i = 1; i < ODT_SHIFT_REG_SIZE; i = i+1) begin
            if (odt_shift_reg[i] != {NUM_RANKS{1'b0}}) begin
                gs_pi_odt_pending = 1'b1;
            end
        end
    end
//spyglass enable_block W415a

    `ifdef SNPS_ASSERT_ON
        // Assertions to check the ODT shift register does not overflow

    `endif


////////////////////////////////
// Logic for dfi_wrdata_cs/dfi_rddata_cs
///////////////////////////////


// convert rank infor (RANK_BITs into RANK_NUM)
wire [NUM_RANKS-1:0] i_nr_rank;

// 1 rank
  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Unused in single-rank configs. Kept for debugging purposes.
  assign i_nr_rank           = 1'b1;
  //spyglass enable_block W528
// > 1 rank
   
  

//
// for dfi_wrdata_cs
//

wire    [NUM_RANKS-1:0]     wrdata_cs_n_for_this_wr;
reg     [NUM_RANKS-1:0]     wrdata_cs_n_shift_reg[DATA_CS_N_SHIFT_REG_SIZE-1:0];    // Shift register to store wrdata_cs_n


    assign wrdata_cs_n_for_this_wr = {NUM_RANKS{1'b0}}; // set to 0 as only one rank


      // Calculate how many cycles after a write command we should switch wrdata_cs_n on
      wire [DFI_TPHY_WRCSLAT_WIDTH:0] wrdata_cs_n_on;
      assign wrdata_cs_n_on   = {1'b0, reg_ddrc_dfi_tphy_wrcslat} + ({{DFI_TPHY_WRCSLAT_WIDTH{1'b0}}, dh_gs_2t_mode} // Delay by 1 cycle in 2T mode
            + (dh_gs_lpddr4    ? {{($bits(wrdata_cs_n_on)-2){1'b0}},2'b11} :
               reg_ddrc_lpddr5 ? {{($bits(wrdata_cs_n_on)-2){1'b0}},2'b10} << dh_gs_frequency_ratio :
                                 {$bits(wrdata_cs_n_on){1'b0}})
        );

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(i - 1)' found in module 'gs_odt'
//SJ: This coding style is acceptable and there is no plan to change it.

    // wrdata_cs_n shift register
    // This is loaded when a command is being sent.  The location and number of entries loaded depend on the wrdata_cs_n_on signal.
    // The shift register is shifted down each cycle
    // The lowest entry (or two entries if MEMC_FREQ_RATIO=2) become gs_pi_wrdata_cs_n, and are sent to the PI block
    always  @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            for (i=0; i<DATA_CS_N_SHIFT_REG_SIZE; i=i+1)
                wrdata_cs_n_shift_reg[i] <= {NUM_RANKS{1'b1}};
        end else begin
            for (i=0; i<DATA_CS_N_SHIFT_REG_SIZE; i=i+1) begin
                if (( $unsigned(i) >= wrdata_cs_n_on) &&
                    (gs_op_is_wr || pda_wr
                    ))
                    wrdata_cs_n_shift_reg[i] <= wrdata_cs_n_for_this_wr; 
    // for last element(s) when shifting, load with existing value         
    else if (i > DATA_CS_N_SHIFT_REG_SIZE - 2 - `MEMC_FREQ_RATIO)
                    wrdata_cs_n_shift_reg[i] <= 
                                               (dh_gs_frequency_ratio)
                                               ? wrdata_cs_n_shift_reg[i-`MEMC_FREQ_RATIO] :
                                                wrdata_cs_n_shift_reg[i-2];
                else
                    wrdata_cs_n_shift_reg[i] <= 
                                               (dh_gs_frequency_ratio)
                                               ? wrdata_cs_n_shift_reg[i+`MEMC_FREQ_RATIO] :
                                                wrdata_cs_n_shift_reg[i+2];
            end
        end
    end
//spyglass enable_block SelfDeterminedExpr-ML

    // Output to PI block.  This is the lowest entry (or two entries if MEMC_FREQ_RATIO = 2) of the shift register
    assign gs_pi_wrdata_cs_n[(NUM_RANKS*NUM_LANES-1):0] = reg_ddrc_dfi_data_cs_polarity ? {NUM_LANES{~wrdata_cs_n_shift_reg[0]}} : {NUM_LANES{wrdata_cs_n_shift_reg[0]}};
        assign gs_pi_wrdata_cs_n[2*NUM_RANKS*NUM_LANES-1:NUM_RANKS*NUM_LANES] = ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~wrdata_cs_n_shift_reg[1]}} : {NUM_LANES{wrdata_cs_n_shift_reg[1]}});
        assign gs_pi_wrdata_cs_n[3*NUM_RANKS*NUM_LANES-1:2*NUM_RANKS*NUM_LANES] = (~dh_gs_frequency_ratio) ? ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_RANKS*NUM_LANES{1'b0}} : {NUM_RANKS*NUM_LANES{1'b1}})
                                                            : ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~wrdata_cs_n_shift_reg[2]}} : {NUM_LANES{wrdata_cs_n_shift_reg[2]}});
        assign gs_pi_wrdata_cs_n[4*NUM_RANKS*NUM_LANES-1:3*NUM_RANKS*NUM_LANES] = (~dh_gs_frequency_ratio) ? ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_RANKS*NUM_LANES{1'b0}} : {NUM_RANKS*NUM_LANES{1'b1}})
                                                            : ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~wrdata_cs_n_shift_reg[3]}} : {NUM_LANES{wrdata_cs_n_shift_reg[3]}});


//
// for dfi_rddata_cs
//

wire    [NUM_RANKS-1:0]     rddata_cs_n_for_this_rd;
reg     [NUM_RANKS-1:0]     rddata_cs_n_shift_reg[DATA_CS_N_SHIFT_REG_SIZE-1:0];    // Shift register to store rddata_cs_n

    assign rddata_cs_n_for_this_rd = {NUM_RANKS{1'b0}}; // set to 0 as only one rank

      // Calculate how many cycles after a read command we should switch rddata_cs_n on
      wire [7:0] rddata_cs_n_on_wider;
      assign rddata_cs_n_on_wider = reg_ddrc_dfi_tphy_rdcslat + ({6'b0, dh_gs_2t_mode}        // Delay by 1 cycle in 2T mode
                                    + (dh_gs_lpddr4    ? {{($bits(rddata_cs_n_on_wider)-2){1'b0}},2'b11} :
                                       reg_ddrc_lpddr5 ? {{($bits(rddata_cs_n_on_wider)-2){1'b0}},2'b10} << dh_gs_frequency_ratio :
                                                         {$bits(rddata_cs_n_on_wider){1'b0}})
                                    );
       wire [6:0] rddata_cs_n_on;
       assign rddata_cs_n_on = rddata_cs_n_on_wider[6:0];

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '(i - 1)' found in module 'gs_odt'
//SJ: This coding style is acceptable and there is no plan to change it.

    // rddata_cs_n shift register
    // This is loaded when a command is being sent.  The location and number of entries loaded depend on the rddata_cs_n_on signal.
    // The shift register is shifted down each cycle
    // The lowest entry (or two entries if MEMC_FREQ_RATIO=2) become gs_pi_rddata_cs_n, and are sent to the PI block
    always  @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            for (i=0; i<DATA_CS_N_SHIFT_REG_SIZE; i=i+1)
                rddata_cs_n_shift_reg[i] <= {NUM_RANKS{1'b1}};
        end else begin
            for (i=0; i<DATA_CS_N_SHIFT_REG_SIZE; i=i+1) begin
                if (( $unsigned(i) >= rddata_cs_n_on) &&
       (gs_op_is_rd || mpr_rd
                        || mrr
                    ))
                    rddata_cs_n_shift_reg[i] <= rddata_cs_n_for_this_rd;
    // for last element(s) when shifting, load with existing value 
    else if (i > DATA_CS_N_SHIFT_REG_SIZE - 2 - `MEMC_FREQ_RATIO)
                    rddata_cs_n_shift_reg[i] <= 
                                               (dh_gs_frequency_ratio)
                                               ? rddata_cs_n_shift_reg[i-`MEMC_FREQ_RATIO] :
                                                 rddata_cs_n_shift_reg[i-2];
                else
                    rddata_cs_n_shift_reg[i] <= 
                                               (dh_gs_frequency_ratio)
                                               ? rddata_cs_n_shift_reg[i+`MEMC_FREQ_RATIO] :
                                                rddata_cs_n_shift_reg[i+2];
            end
        end
    end
//spyglass enable_block SelfDeterminedExpr-ML

    // Output to PI block.  This is the lowest entry (or two entries if MEMC_FREQ_RATIO = 2) of the shift register
    assign gs_pi_rddata_cs_n[NUM_RANKS*NUM_LANES-1:0] = (reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~rddata_cs_n_shift_reg[0]}} : {NUM_LANES{rddata_cs_n_shift_reg[0]}};
        assign gs_pi_rddata_cs_n[2*NUM_RANKS*NUM_LANES-1:NUM_RANKS*NUM_LANES] = (reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~rddata_cs_n_shift_reg[1]}} : {NUM_LANES{rddata_cs_n_shift_reg[1]}};
        assign gs_pi_rddata_cs_n[3*NUM_RANKS*NUM_LANES-1:2*NUM_RANKS*NUM_LANES] = (~dh_gs_frequency_ratio) ? ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_RANKS*NUM_LANES{1'b0}} : {NUM_RANKS*NUM_LANES{1'b1}})
                                                            : ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~rddata_cs_n_shift_reg[2]}} : {NUM_LANES{rddata_cs_n_shift_reg[2]}});
        assign gs_pi_rddata_cs_n[4*NUM_RANKS*NUM_LANES-1:3*NUM_RANKS*NUM_LANES] = (~dh_gs_frequency_ratio) ? ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_RANKS*NUM_LANES{1'b0}} : {NUM_RANKS*NUM_LANES{1'b1}})
                                                            : ((reg_ddrc_dfi_data_cs_polarity) ? {NUM_LANES{~rddata_cs_n_shift_reg[3]}} : {NUM_LANES{rddata_cs_n_shift_reg[3]}});


   

//assign gs_pi_wrdata_cs_n = {`MEMC_FREQ_RATIO * NUM_RANKS{1'b1}};
//assign gs_pi_rddata_cs_n = {`MEMC_FREQ_RATIO * NUM_RANKS{1'b1}};

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

  // wr_odt_off overflow
  assert_never #(0, 0, "wr_odt_off overflow", CATEGORY) a_wr_odt_off_overflow
    (co_yy_clk, core_ddrc_rstn, (wr_odt_off_wider[6]==1'b1));

  // rd_odt_off overflow
  assert_never #(0, 0, "rd_odt_off overflow", CATEGORY) a_rd_odt_off_overflow
    (co_yy_clk, core_ddrc_rstn, (rd_odt_off_wider[6]==1'b1));    
    
    // rddata_cs_n_on overflow
    assert_never #(0, 0, "rddata_cs_n_on overflow", CATEGORY) a_rddata_cs_n_on_overflow
      (co_yy_clk, core_ddrc_rstn, (rddata_cs_n_on_wider[7]==1'b1)); 
  
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON  

endmodule  // gs_odt: On-die termination control
