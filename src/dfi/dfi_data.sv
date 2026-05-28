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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/dfi_data.sv#1 $
// -------------------------------------------------------------------------
// Description:
//           Generates the DFI signals for HS Controller - data.
//-----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module dfi_data 
import DWC_ddrctl_reg_pkg::*;
#(
     parameter      MEMC_ECC_SUPPORT    = 0
    ,parameter      PHY_DATA_WIDTH      = 32            // data width to PHY
    ,parameter      PHY_MASK_WIDTH      = 4             // data mask width to PHY
    ,parameter      NUM_RANKS           = 4             // max supported ranks (chip selects)
    ,parameter      MAX_CMD_DELAY       = `UMCTL2_MAX_CMD_DELAY
    ,parameter      CMD_DELAY_BITS      = `UMCTL2_CMD_DELAY_BITS
    ,parameter      OCCAP_EN            = 0
    ,parameter      OCCAP_PIPELINE_EN   = 0
  )
  (
    // Inputs
     input                          core_ddrc_core_clk
    ,input                          core_ddrc_rstn
//spyglass disable_block W240
//SMD: Input 'reg_ddrc_occap_en'/'reg_ddrc_occap_en_r' declared but not read
//SJ: Used in generate blocks
    ,input                          reg_ddrc_occap_en
    ,input                          reg_ddrc_occap_en_r
//spyglass enable_block W240
    ,output                         ddrc_occap_dfidata_parity_err

    ,input                          ddrc_cg_en              // clock gating enable input
                                                            // used in gating the clock on the write data/mask
                                                            // pipeline flops
    ,input                          reg_ddrc_frequency_ratio // 1 - 1:1 mode, 0 - 1:2 mode
    ,input                          ddrc_phy_wdata_vld_early
    ,input [`MEMC_FREQ_RATIO-1:0]   pi_ph_dfi_rddata_en
    ,input [`MEMC_FREQ_RATIO-1:0]   pi_ph_dfi_wrdata_en

    ,input [PHY_DATA_WIDTH-1:0]     ddrc_phy_wdata
    ,input [PHY_MASK_WIDTH-1:0]     ddrc_phy_dm

    ,input                          mr_dfi_empty            // Empty indication from MR module
                                                            // This is further delayed in DFI module to account
                                                            // for mr_t_wrdata and a dfi_wr_q_empty signal
                                                            // is generated
    ,output                         dfi_wr_q_empty

    ,input [1:0]                    mr_t_wrlat_add_sdr
    ,input [1:0]                    mr_t_rddata_en_add_sdr

  //`ifdef MEMC_FREQ_RATIO_4
  //`endif // MEMC_FREQ_RATIO_4
    ,input                          reg_ddrc_lpddr4
    ,input                          reg_ddrc_lpddr5
    ,input                          reg_ddrc_dm_en
    ,input                          reg_ddrc_phy_dbi_mode
    ,input                          reg_ddrc_wr_dbi_en


    // Outputs


    ,output  [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0]  dfi_wrdata_en
    ,output  [PHY_DATA_WIDTH-1:0]                dfi_wrdata
    ,output  [`MEMC_DFI_TOTAL_MASK_WIDTH-1:0]    dfi_wrdata_mask
    ,output  [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0]  dfi_rddata_en

    ,input  [3:0]                            pi_ph_snoop_en
    ,output [`MEMC_DFI_TOTAL_DATAEN_WIDTH*4-1:0] dwc_ddrphy_snoop_en
);

// no of values in shift_wdata/shift_dm shift registers
// one more for FREQ_RATIO=2 for add_sdr support

//------------------------------------------------------------------------------
// Initial handling of the signals
//   - DFI bus naming
//   - 2T mode handling in DFI 1:2 operation
//   - Expansion of signal widths of some signals
//   - Parity generation
//------------------------------------------------------------------------------


wire [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0] ddrc_dfi_wrdata_en_next;
wire [PHY_DATA_WIDTH-1:0]               ddrc_dfi_wrdata_next;
wire [PHY_MASK_WIDTH-1:0]               ddrc_dfi_wrdata_mask_next;
wire [PHY_MASK_WIDTH-1:0]               dfi_wrdata_mask_per_byte;
wire [`MEMC_DFI_TOTAL_DATAEN_WIDTH-1:0] ddrc_dfi_rddata_en_next;


wire [PHY_DATA_WIDTH/2-1:0]             ddrc_phy_wdata_r_lwr;
wire [PHY_MASK_WIDTH/2-1:0]             ddrc_phy_dm_r_lwr;
wire [PHY_DATA_WIDTH/2-1:0]             ddrc_phy_wdata_r_upr;
wire [PHY_MASK_WIDTH/2-1:0]             ddrc_phy_dm_r_upr;

wire                                    ddrc_phy_wdata_vld_early_i;
wire    [PHY_DATA_WIDTH-1:0]            ddrc_phy_wdata_i;
wire    [PHY_MASK_WIDTH-1:0]            ddrc_phy_dm_i;
wire                                    pi_ph_dfi_rddata_en_i;
wire    [`MEMC_FREQ_RATIO-1:0]          pi_ph_dfi_wrdata_en_i;


wire    [`MEMC_DFI_TOTAL_DATAEN_WIDTH*4-1:0] dwc_ddrphy_snoop_en_next;

wire                                    lpddr_mode;
assign lpddr_mode = reg_ddrc_lpddr4 | reg_ddrc_lpddr5;

//------------------------
    assign   ddrc_phy_wdata_vld_early_i = ddrc_phy_wdata_vld_early;
    assign   ddrc_phy_wdata_i           = ddrc_phy_wdata;
    assign   ddrc_phy_dm_i              = ddrc_phy_dm;
    assign   pi_ph_dfi_rddata_en_i      = pi_ph_dfi_rddata_en[0];
    assign   pi_ph_dfi_wrdata_en_i      = pi_ph_dfi_wrdata_en;



//-----------------------------
// Delay ddrc_cg_en
//-----------------------------
reg  ddrc_cg_en_r;      
reg  ddrc_cg_en_r2;   
wire ddrc_cg_en_dly;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read - ddrc_cg_en_r2
//SJ: Used in generate statement
always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    ddrc_cg_en_r  <= 1'b0;
    ddrc_cg_en_r2 <= 1'b0;
  end else begin
    ddrc_cg_en_r  <= ddrc_cg_en;
    ddrc_cg_en_r2 <= ddrc_cg_en_r;
end
//spyglass enable_block W528

assign ddrc_cg_en_dly = ddrc_cg_en | ddrc_cg_en_r | ddrc_cg_en_r2;

//-----------------------------
// Delay wrdata valid
//-----------------------------
reg                      ddrc_phy_wdata_vld_early_r;    
always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin :  wdata_vld_shift_PROC
    if (~core_ddrc_rstn) begin
        ddrc_phy_wdata_vld_early_r  <= 1'b0;
    end else if (ddrc_cg_en_dly) begin
        ddrc_phy_wdata_vld_early_r  <= ddrc_phy_wdata_vld_early_i;
    end
end

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate statement and `ifdef branch under different conditions and therefore must always exist.
reg                      ddrc_phy_wdata_vld_early_2r;   
always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin :  wdata_vld_shift2_PROC
    if (~core_ddrc_rstn) begin
        ddrc_phy_wdata_vld_early_2r <= 1'b0;
    end else if (ddrc_cg_en_dly) begin
        ddrc_phy_wdata_vld_early_2r <= ddrc_phy_wdata_vld_early_r;
    end
end
//spyglass enable_block W528
//-----------------------------
// Logic to prevent DQ toggling
//-----------------------------
wire [PHY_DATA_WIDTH-1:0]   ddrc_phy_wdata_notoggle;        // Data after "no toggling" logic
wire                        ddrc_phy_wdata_vld_notoggle;    // Valid signal for "no toggling" logic
wire [PHY_MASK_WIDTH-1:0]   ddrc_phy_dm_notoggle;           // Data mask signal for "no toggling" logic

// Data mask signal
assign ddrc_phy_dm_notoggle = 
                          //`ifdef MEMC_FREQ_RATIO_4
                          //`endif // MEMC_FREQ_RATIO_4
                                lpddr_mode    ? ( (reg_ddrc_dm_en & ~(reg_ddrc_wr_dbi_en & ~reg_ddrc_phy_dbi_mode)) ? ddrc_phy_dm_i : {PHY_MASK_WIDTH{1'b0}}) :
                                ddrc_phy_dm_i;

// Valid signal for "no toggling" logic
assign ddrc_phy_wdata_vld_notoggle = ddrc_phy_wdata_vld_early_r;

// Note that wrdata_no_toggle is instantiated both here and in mr_data_steering.v
wrdata_no_toggle
   #(
    .PHY_DATA_WIDTH     (PHY_DATA_WIDTH),
    .PHY_MASK_WIDTH     (PHY_MASK_WIDTH) 
                    ) 
wrdata_no_toggle    (
    .core_ddrc_core_clk (core_ddrc_core_clk),
    .core_ddrc_rstn     (core_ddrc_rstn),
    .ddrc_cg_en         (ddrc_cg_en_dly),
    .wrdata_in          (ddrc_phy_wdata_i),
    .wrdata_mask        (ddrc_phy_dm_notoggle),
    .wrdata_valid       (ddrc_phy_wdata_vld_notoggle),
    .wrdata_out         (ddrc_phy_wdata_notoggle)
                    );


//-----------------------------
// Delay rddata_en and wrdata_en 
//-----------------------------


    reg                      pi_ph_dfi_rddata_en_r;     
    reg [2:0]                pi_ph_dfi_wrdata_en_r;     
    reg [3:0]                pi_ph_snoop_en_r;

    always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin :  data_en_shift_PROC
        if (!core_ddrc_rstn) begin
            pi_ph_dfi_rddata_en_r       <= 1'b0;
            pi_ph_dfi_wrdata_en_r       <= 3'b0;
            pi_ph_snoop_en_r            <= 4'b0;
        end else begin
            pi_ph_dfi_rddata_en_r       <= pi_ph_dfi_rddata_en_i;
            pi_ph_dfi_wrdata_en_r       <= pi_ph_dfi_wrdata_en_i[2:0];
            pi_ph_snoop_en_r            <= pi_ph_snoop_en;
        end
    end


    assign ddrc_dfi_wrdata_en_next = 
                                    ((reg_ddrc_frequency_ratio) ? (
                                       (mr_t_wrlat_add_sdr == 2'b11) ?
                                                                       {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[0]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[2]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[1]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[0]}}} :
                                       (mr_t_wrlat_add_sdr == 2'b10) ?
                                                                       {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[1]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[0]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[2]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[1]}}} :
                                       (mr_t_wrlat_add_sdr == 2'b01) ?
                                                                       {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[2]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[1]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[0]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[2]}}} :
                                       // mr_t_wrlat_add_sdr == 2'b00
                                                                       {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[3]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[2]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[1]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[0]}}}
                                     ) : (
                                     //1to2 mode
                                       (mr_t_wrlat_add_sdr == 2'b01) ?
                                                                       {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{1'b0}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{1'b0}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[0]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_r[1]}}} :
                                       // mr_t_wrlat_add_sdr == 2'b00
                                                                       {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{1'b0}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{1'b0}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[1]}},
                                                                        {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{pi_ph_dfi_wrdata_en_i[0]}}}
                                     ));

    
    //-----------------------------------
    //-----------------------------------
    
    // Need to add 1 , 2 or 3sdr of delay 
    wire i_dfi_rddata_en_next_first  = (mr_t_rddata_en_add_sdr == 2'b00) ? pi_ph_dfi_rddata_en_i : pi_ph_dfi_rddata_en_r;
    wire i_dfi_rddata_en_next_second = (reg_ddrc_frequency_ratio) ? ((mr_t_rddata_en_add_sdr[1] == 1'b0) ? pi_ph_dfi_rddata_en_i : pi_ph_dfi_rddata_en_r) : 
                                                                    pi_ph_dfi_rddata_en_i;
    wire i_dfi_rddata_en_next_third  = (reg_ddrc_frequency_ratio) ? ((mr_t_rddata_en_add_sdr    == 2'b11) ? pi_ph_dfi_rddata_en_r : pi_ph_dfi_rddata_en_i) : 
                                                                    1'b0;
    wire i_dfi_rddata_en_next_fourth = (reg_ddrc_frequency_ratio) ? pi_ph_dfi_rddata_en_i : 
                                                                    1'b0;
    
    assign ddrc_dfi_rddata_en_next =
                                     {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{i_dfi_rddata_en_next_fourth}},
                                      {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{i_dfi_rddata_en_next_third}},
                                      {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{i_dfi_rddata_en_next_second}},
                                      {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{i_dfi_rddata_en_next_first}}};

    assign dwc_ddrphy_snoop_en_next = 
                                     {{`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{{4{i_dfi_rddata_en_next_fourth}} & (pi_ph_snoop_en | pi_ph_snoop_en_r)}},
                                      {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{{4{i_dfi_rddata_en_next_third}}  & (pi_ph_snoop_en | pi_ph_snoop_en_r)}},
                                      {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{{4{i_dfi_rddata_en_next_second}} & (pi_ph_snoop_en | pi_ph_snoop_en_r)}},
                                      {`MEMC_DFI_TOTAL_DATAEN_WIDTH/4{{4{i_dfi_rddata_en_next_first}}  & (pi_ph_snoop_en | pi_ph_snoop_en_r)}}};

    
    assign ddrc_dfi_wrdata_next      =
                                       (~reg_ddrc_frequency_ratio) ? {{(PHY_DATA_WIDTH/2){1'b0}},
                                                                      ddrc_phy_wdata_notoggle[PHY_DATA_WIDTH/2-1:0]} :
                                                                      ddrc_phy_wdata_notoggle;
    assign ddrc_dfi_wrdata_mask_next = ddrc_phy_dm_i;

//------------------------------------------------------------------------------
// End: Initial handling of signals
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Begin: Final signal assignments
//------------------------------------------------------------------------------
assign dfi_rddata_en                = ddrc_dfi_rddata_en_next;
assign dfi_wrdata_en                = ddrc_dfi_wrdata_en_next;
assign dfi_wrdata                   = ddrc_dfi_wrdata_next;
assign dfi_wrdata_mask_per_byte     = ddrc_dfi_wrdata_mask_next;
assign dwc_ddrphy_snoop_en          = dwc_ddrphy_snoop_en_next;
assign dfi_wrdata_mask              = dfi_wrdata_mask_per_byte;


//--------------------------------------------------
// End: Final assignment
//--------------------------------------------------

// Write Queue Empty generation from DFI module
// Take the empty from MR module, delay it MAX_CMD_DELAY+1 times
// and then generate dfi_wr_q_empty

reg [MAX_CMD_DELAY:0] mr_dfi_empty_r;

always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
  begin :  tphy_wrdata_wr_q_empty_shift_PROC
        if (~core_ddrc_rstn) begin
           mr_dfi_empty_r <= {(MAX_CMD_DELAY+1){1'b0}};
        end
        else begin
           mr_dfi_empty_r <= {mr_dfi_empty_r[MAX_CMD_DELAY-1:0], mr_dfi_empty};
        end
  end

assign dfi_wr_q_empty = mr_dfi_empty_r[MAX_CMD_DELAY];


  //
  // Control logic for dfi_data module 
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
  //

//ddrc_cg_en_r
//ddrc_cg_en_r2
//ddrc_phy_wdata_vld_early_r
//ddrc_phy_wdata_vld_early_2r
//pi_ph_dfi_rddata_en_r
//pi_ph_dfi_wrdata_en_r
//ddrc_phy_dm_r
//mr_dfi_empty_r

   localparam   SL_W             = 8;   
   localparam CTRL_W =
                       1 + // ddrc_cg_en_r
                       1 + // ddrc_cg_en_r2
                       1 + // ddrc_phy_wdata_vld_early_r
                       1 + // ddrc_phy_wdata_vld_early_2r
                       1 + // pi_ph_dfi_rddata_en_r
                       3 + // pi_ph_dfi_wrdata_en_r
                       PHY_MASK_WIDTH + // ddrc_phy_dm_r
                       4 + //pi_ph_snoop_en_r
                       MAX_CMD_DELAY + 1    // mr_dfi_empty_r
                       ;

  localparam   CTRL_PARW             = (OCCAP_EN==1) ? ((CTRL_W%SL_W>0) ? CTRL_W/SL_W+1 : CTRL_W/SL_W) : 0;

 wire ctrl_par_err;

 // drive output
 assign ddrc_occap_dfidata_parity_err = ctrl_par_err;


 generate
   if (OCCAP_EN==1) begin: OCCAP_en 
   
      wire par_en;
      assign par_en   = reg_ddrc_occap_en;
      wire par_en_r;
      assign par_en_r = reg_ddrc_occap_en_r;
      
      wire [CTRL_PARW-1:0] ctrl_parity_dummy, ctrl_mask_in;
      wire [CTRL_PARW-1:0] ctrl_pgen_in_par, ctrl_parity_err;
      wire [CTRL_PARW-1:0] pgen_parity_corr_unused, pcheck_parity_corr_unused;
      reg  [CTRL_PARW-1:0] ctrl_pgen_in_par_r;
      
      wire ctrl_pgen_en, ctrl_pcheck_en;

      assign ctrl_parity_dummy  = {CTRL_PARW{1'b1}};
      assign ctrl_mask_in       = {CTRL_PARW{1'b1}};

      wire   ctrl_poison_en;
      assign ctrl_poison_en     = 1'b0;

      assign ctrl_pgen_en    = par_en;

    
      // only check if par_en has been enabled for a cycle as pgen only
      // operates if par_en=1
      assign ctrl_pcheck_en  = par_en_r & par_en;

    reg [PHY_MASK_WIDTH-1:0] ddrc_phy_dm_r;
    always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin : wdata_mask_PROC
        if (!core_ddrc_rstn) begin
            ddrc_phy_dm_r               <= {PHY_MASK_WIDTH{1'b0}};
        end else begin
            ddrc_phy_dm_r               <= ddrc_phy_dm_i;
        end
    end



// 
// concat signals for pgen/pcheck
//
    
    wire [CTRL_W-1:0] ctrl_pgen_in;
    wire [CTRL_W-1:0] ctrl_pcheck_in;

    // generate concat bus of signals to pgen
    assign ctrl_pgen_in = {
                            ddrc_cg_en,
                            ddrc_cg_en_r,
                            ddrc_phy_wdata_vld_early_i,
                            ddrc_phy_wdata_vld_early_r,
                            pi_ph_dfi_rddata_en_i,
                            pi_ph_dfi_wrdata_en_i[2:0],
                            ddrc_phy_dm_i,
                           pi_ph_snoop_en,
                            {mr_dfi_empty_r[MAX_CMD_DELAY-1:0], mr_dfi_empty}
                           };

    // generate concat bus of signals to pcheck
  assign ctrl_pcheck_in = {
                            ddrc_cg_en_r,
                            ddrc_cg_en_r2,
                            ddrc_phy_wdata_vld_early_r,
                            ddrc_phy_wdata_vld_early_2r,
                            pi_ph_dfi_rddata_en_r,
                            pi_ph_dfi_wrdata_en_r,
                            ddrc_phy_dm_r,
                           pi_ph_snoop_en_r,
                            mr_dfi_empty_r
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
            .parity_corr   (pgen_parity_corr_unused) //not used
         );



         always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
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
            .parity_corr   (pcheck_parity_corr_unused) //not used
         );

              
         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg ctrl_par_err_r;
           always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin : ctrl_par_err_r_PROC
             if (~core_ddrc_rstn) begin
               ctrl_par_err_r <= 1'b0;
             end else begin
               ctrl_par_err_r <= |ctrl_parity_err;
             end
           end

           assign ctrl_par_err = ctrl_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign ctrl_par_err = |ctrl_parity_err; 

         end



    end // OCCAP_en 
    else begin: OCCAP_dis
   
      assign ctrl_par_err = 1'b0;
    end // OCCAP_dis 
   endgenerate


`ifndef SYNTHESIS
`ifdef SNPS_ASSERT_ON

`ifdef VCS

//-------------
// Don't want the assertions to run in Cadence regressions as it is firing for some unknown reason right at the end of the simulation
// Not root-caused yet. This behavior is not seen in VCS regressions.
//-------------

//-----------------------
// Assertions for checking that the DFI module delays all the output signals exactly according to the specification
//-----------------------

wire disable_check3, disable_check2, disable_check1, disable_check0;

assign disable_check3      = 1'b1;
assign disable_check2      = 1'b1;
assign disable_check1      = 1'b1;
assign disable_check0      = ~core_ddrc_rstn;

//-------------------------------------------
// Begin Assertions
//-------------------------------------------

//-------------------------------------------
// Notes about the following assertions
//-------------------------------------------
// bg and act_n checked only in DDR4 mode
//
// No check for dfi_wr* signals below. The timing of these signals are adjusted based on the t_dfi_wrlat and t_dfi_wrdata requirements - hence these are
// difficult to check. As long as the commands are delayed correctly the write data signals have to follow the correct timing, else there will be error in
// the write or read data and will be reported by the scoreboard

// Excluding parity check in DDR4 due to the logic surrounding reg_ddrc_dfi_t_parin_lat register
// Check becomes complicated due to that. The goal here is only to see if the overall latency behavior is correct and hence it is ok to exclude DDR4

// Note the use of internal dfi_lp*_out signals in the two dfi_lp* related assertions
// This is because the dfi_lp_* signals are forced to 0 at the end of the test from ddrc_env.sv. The assertion will fail due to this reason.
// The internal signal, which behaves exactly same as the RTL signal - without the force - is used in the assertion.
//-------------------------------------------


//------------------------------------------------------------
// 3-cycle delay in DFI module
//------------------------------------------------------------

assert_dfi_rddata_en_check_3        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)                     !$stable(pi_ph_dfi_rddata_en)      |->     
                                                                                                                 ##3 !$stable(dfi_rddata_en)
                                                                                                                     && dfi_rddata_en == (
                                                                                                                          // for SW 1:1 mode upper half of dfi_rddata_en is inactive
                                                                                                                          (reg_ddrc_frequency_ratio) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i, 3)}}} :
                                                                                                                               mr_t_rddata_en_add_sdr ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i, 3)}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i, 4)}}} :
                                                                                                                                 {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i, 3)}})
                                                                                                                 // when mr_t_rddata_en_add_sdr we need to check that the lower half of dfi_rddata_en will
                                                                                                                 // take the value of pi_ph_dfi_rddata_en as well; this doesn't need to be checked if pi_ph_dfi_rddata_en
                                                                                                                 // changes, because in this case the left-hend side of assertion is TRUE and the assertion is reevaluated
                                                                                                                 ##1 (~reg_ddrc_frequency_ratio & mr_t_rddata_en_add_sdr && $stable($past(pi_ph_dfi_rddata_en, 3))) ? 
                                                                                                                                 (dfi_rddata_en == {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i, 4)}}) :
                                                                                                                                 1'b1
                                                                                                                 );
                                                                                                                                 
//------------------------------------------------------------
// 2-cycle delay in DFI module
//------------------------------------------------------------


assert_dfi_rddata_en_check_2        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)                     !$stable(pi_ph_dfi_rddata_en)      |->     
                                                                                                                 ##2 !$stable(dfi_rddata_en)
                                                                                                                     && dfi_rddata_en == (
                                                                                                                          // for SW 1:1 mode upper half of dfi_rddata_en is inactive
                                                                                                                          (reg_ddrc_frequency_ratio) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i, 2)}}} :
                                                                                                                           mr_t_rddata_en_add_sdr ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i, 2)}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i, 3)}}} :
                                                                                                                                 {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i, 2)}})
                                                                                                                 // when mr_t_rddata_en_add_sdr we need to check that the lower half of dfi_rddata_en will
                                                                                                                 // take the value of pi_ph_dfi_rddata_en as well; this doesn't need to be checked if pi_ph_dfi_rddata_en
                                                                                                                 // changes, because in this case the left-hend side of assertion is TRUE and the assertion is reevaluated
                                                                                                                 ##1 (~reg_ddrc_frequency_ratio & mr_t_rddata_en_add_sdr && $stable($past(pi_ph_dfi_rddata_en, 2))) ? 
                                                                                                                                 (dfi_rddata_en == {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i, 3)}}) :
                                                                                                                                 1'b1
                                                                                                                 );

//------------------------------------------------------------
// 1-cycle delay in DFI module
//------------------------------------------------------------


assert_dfi_rddata_en_check_1        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)                     !$stable(pi_ph_dfi_rddata_en)      |->     
                                                                                                                 ##1 !$stable(dfi_rddata_en)
                                                                                                                     && dfi_rddata_en == (
                                                                                                                          (!reg_ddrc_frequency_ratio) ?
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b01) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i)}},
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i,2)}}} :
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i)}}} // mr_t_rddata_en_add_sdr == 2'b00
                                                                                                                              : // FR4
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b01) ? 
                                                                                                                                 {{(3*`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i)}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i,2)}}} :
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b10) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i)}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i,2)}}} :
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b11) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i)}}, 
                                                                                                                                  {(3*`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i,2)}}} :
                                                                                                                                 {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i)}}) // mr_t_rddata_en_add_sdr == 2'b00
                                                                                                                 ##1 ((mr_t_rddata_en_add_sdr != 2'b00) && $stable($past(pi_ph_dfi_rddata_en))) ? 
                                                                                                                        (!reg_ddrc_frequency_ratio) ?
                                                                                                                                 (dfi_rddata_en == {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}},
                                                                                                                                                   {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i,2)}}}) :
                                                                                                                                 (dfi_rddata_en == {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i,2)}})  //FR4
                                                                                                                        : 1'b1
                                                                                                                 );

//------------------------------------------------------------
// 0-cycle delay in DFI module
//------------------------------------------------------------

assert_dfi_rddata_en_check_0        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)                     !$stable(pi_ph_dfi_rddata_en)      |->     
                                                                                                                          // for SW 1:2 mode upper half of dfi_rddata_en is inactive
                                                                                                                     dfi_rddata_en == (
                                                                                                                          (!reg_ddrc_frequency_ratio) ?
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b01) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){(pi_ph_dfi_rddata_en_i)}},
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i)}}} :
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){(pi_ph_dfi_rddata_en_i)}}} // mr_t_rddata_en_add_sdr == 2'b00
                                                                                                                              : // FR4
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b01) ? 
                                                                                                                                 {{(3*`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){pi_ph_dfi_rddata_en_i}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i)}}} :
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b10) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){pi_ph_dfi_rddata_en_i}}, 
                                                                                                                                  {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i)}}} :
                                                                                                                              (mr_t_rddata_en_add_sdr == 2'b11) ? 
                                                                                                                                 {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){pi_ph_dfi_rddata_en_i}}, 
                                                                                                                                  {(3*`MEMC_DFI_TOTAL_DATAEN_WIDTH/4){$past(pi_ph_dfi_rddata_en_i)}}} :
                                                                                                                                 {`MEMC_DFI_TOTAL_DATAEN_WIDTH{pi_ph_dfi_rddata_en_i}}) // mr_t_rddata_en_add_sdr == 2'b00
                                                                                                                 ##1 ((mr_t_rddata_en_add_sdr != 2'b00) && $stable(pi_ph_dfi_rddata_en)) ? 
                                                                                                                        (!reg_ddrc_frequency_ratio) ?
                                                                                                                                 (dfi_rddata_en == {{(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){1'b0}},
                                                                                                                                                   {(`MEMC_DFI_TOTAL_DATAEN_WIDTH/2){$past(pi_ph_dfi_rddata_en_i)}}}) :
                                                                                                                                 (dfi_rddata_en == {`MEMC_DFI_TOTAL_DATAEN_WIDTH{$past(pi_ph_dfi_rddata_en_i)}})  //FR4
                                                                                                                        : 1'b1
                                                                                                                                 
                                                                                                                 );


`endif // VCS

`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS


endmodule //dfi_data.v
