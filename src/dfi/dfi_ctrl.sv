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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/dfi/dfi_ctrl.sv#2 $
// -------------------------------------------------------------------------
// Description:
//            Generates the DFI signals for HS Controller - CTRL.
//-----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
`include "dfi/DWC_ddrctl_dfi_pkg.svh"
module dfi_ctrl
import DWC_ddrctl_reg_pkg::*;
import DWC_ddrctl_dfi_pkg::*;
#(
     parameter      CHANNEL_NUM     = 0
    ,parameter      SHARED_AC       = 0
    ,parameter      UMCTL2_PHY_SPECIAL_IDLE        = 0 // A specially encoded "IDLE" command over the DFI bus: {ACT_n,RAS_n,CAS_n,WE_n,BA0}
    ,parameter      MEMC_ECC_SUPPORT               = 0
    ,parameter      BG_BITS         = `MEMC_BG_BITS
    ,parameter      BANK_BITS       = 3
    ,parameter      NUM_RANKS       = 4             // max supported ranks (chip selects)
    ,parameter      PHY_DATA_WIDTH  = 32            // data width to PHY
    ,parameter      NUM_LANES       = 4             //Number of lanes in PHY - default is 4
    ,parameter      NUM_DRAM_CLKS   = 3

    ,parameter      ADDR_WIDTH      = `MEMC_DFI_ADDR_WIDTH
    ,parameter      MAX_CMD_DELAY   = `UMCTL2_MAX_CMD_DELAY
    ,parameter      CMD_DELAY_BITS  = `UMCTL2_CMD_DELAY_BITS
  )
  (
    // Inputs
     input                                      core_ddrc_core_clk
    ,input                                      core_ddrc_rstn
    ,input [CMD_DELAY_BITS-1:0]                 dfi_cmd_delay
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in RTL assertions
    ,input [DFI_TPHY_WRLAT_WIDTH-1:0]              mr_t_wrlat
    ,input [DFI_TPHY_WRDATA_WIDTH-1:0]             mr_t_wrdata
    ,input                                      reg_ddrc_frequency_ratio // 1 - 1:1 mode, 0 - 1:2 mode
//spyglass enable_block W240
    ,input                                      dfi_phyupd_req
    ,input                                      dfi_init_complete

    ,input   dfi_address_s                      ddrc_phy_addr

    ,input   [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0] ddrc_phy_ba
    ,input   [`MEMC_FREQ_RATIO-1:0]             ddrc_phy_casn
    ,input   [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] ddrc_phy_csn
    ,input   [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] ddrc_phy_cke
    ,input   [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] ddrc_phy_odt                       // ODT signal from PI block (generated in gs_odt)
    ,input   [`MEMC_FREQ_RATIO-1:0]             ddrc_phy_rasn
    ,input   [`MEMC_FREQ_RATIO-1:0]             ddrc_phy_wen

    ,input                                      ddrc_phy_dram_rst_n
    ,input   [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0]  ddrc_phy_wrdata_cs_n // wrdata_cs_n signal from PI block (generated in gs_odt)
    ,input   [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0]  ddrc_phy_rddata_cs_n // rddata_cs_n signal from PI block (generated in gs_odt)

    ,input                                      ddrc_phy_stop_clk
    ,input                                      ts_dfi_ctrlupd_req
    ,input                                      reg_ddrc_dfi_init_start


    ,input                                      dfi_phyupd_ack_int
    ,input                                      dfi_phymstr_ack_int
    ,input [DFI_LP_WAKEUP_PD_WIDTH-1:0]         dfi_lp_ctrl_wakeup_int
    ,input                                      dfi_lp_ctrl_req_int
    ,input [DFI_LP_WAKEUP_PD_WIDTH-1:0]         dfi_lp_data_wakeup_int
    ,input                                      dfi_lp_data_req_int

    ,input                                      reg_ddrc_lpddr4
    ,input                                      reg_ddrc_lpddr5
    ,input [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]     gs_dfi_wck_cs
    ,input [`MEMC_FREQ_RATIO-1:0]               gs_dfi_wck_en
    ,input [2*`MEMC_FREQ_RATIO-1:0]             gs_dfi_wck_toggle


    //Outputs
    ,output                                     phy_dfi_phyupd_req
    ,output  reg                                phy_dfi_init_complete
    ,output  dfi_address_s                      dfi_address
    ,output  [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0] dfi_bank
    ,output  [1:0]                              dfi_freq_ratio
    ,output  [`MEMC_FREQ_RATIO-1:0]             dfi_ras_n
    ,output  [`MEMC_FREQ_RATIO-1:0]             dfi_cas_n
    ,output  [`MEMC_FREQ_RATIO-1:0]             dfi_we_n
    ,output  [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] dfi_cke
    ,output  [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] dfi_cs
    ,output  [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] dfi_odt                             // DFI ODT signal
    ,output  [`UMCTL2_RESET_WIDTH-1:0]          dfi_reset_n
    ,output [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0] dfi_wrdata_cs
    ,output [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0] dfi_rddata_cs
    ,output                                     dfi_ctrlupd_req
    ,output                                     dfi_phyupd_ack
    ,output                                     dfi_phymstr_ack
    ,output [DFI_LP_WAKEUP_PD_WIDTH-1:0]        dfi_lp_ctrl_wakeup
    ,output                                     dfi_lp_ctrl_req
    ,output [DFI_LP_WAKEUP_PD_WIDTH-1:0]        dfi_lp_data_wakeup
    ,output                                     dfi_lp_data_req
    ,output  [NUM_DRAM_CLKS-1:0]                dfi_dram_clk_disable
    ,output [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    dfi_wck_cs
    ,output [`MEMC_FREQ_RATIO-1:0]              dfi_wck_en
    ,output [2*`MEMC_FREQ_RATIO-1:0]            dfi_wck_toggle

    ,output  [`MEMC_FREQ_RATIO-1:0]             dfi_parity_in


    ,output                                     dfi_init_start


    ,input logic  [DFI_T_CTRLMSG_RESP_WIDTH-1:0]  reg_ddrc_dfi_t_ctrlmsg_resp
    ,input logic                                  reg_ddrc_dfi0_ctrlmsg_req
    ,input logic                                  reg_ddrc_dfi0_ctrlmsg_tout_clr
    ,input logic [DFI_CTRLMSG_CMD_WIDTH-1:0]      reg_ddrc_dfi0_ctrlmsg_cmd
    ,input logic [DFI_CTRLMSG_DATA_WIDTH-1:0]     reg_ddrc_dfi0_ctrlmsg_data
    ,output logic                                 ddrc_reg_dfi0_ctrlmsg_resp_tout
    ,output logic                                 ddrc_reg_dfi0_ctrlmsg_req_busy
    ,input  logic                                 dfi0_ctrlmsg_ack
    ,output logic                                 dfi0_ctrlmsg_req
    ,output logic [7:0]                           dfi0_ctrlmsg
    ,output logic [15:0]                          dfi0_ctrlmsg_data
    ,input                                        gs_pi_ctrlupd_req
    ,input                                        dfilp_block_dfi_ctrlmsg
);


//------------------------------------------------------------------------------
// Initial handling of the signals
//   - DFI bus naming
//   - 2T mode handling in DFI 1:2 operation
//   - Expansion of signal widths of some signals
//   - Parity generation
//------------------------------------------------------------------------------


//Outputs

dfi_address_s                           ddrc_dfi_address_next;

wire [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0] ddrc_dfi_bank_next;
wire [1:0]                              ddrc_dfi_freq_ratio_next;
wire [`MEMC_FREQ_RATIO-1:0]             ddrc_dfi_ras_n_next;
wire [`MEMC_FREQ_RATIO-1:0]             ddrc_dfi_cas_n_next;
wire [`MEMC_FREQ_RATIO-1:0]             ddrc_dfi_we_n_next;
wire [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] ddrc_dfi_cke_next;
wire [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] ddrc_dfi_cs_next;
wire [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0] ddrc_dfi_odt_next;
wire [`UMCTL2_RESET_WIDTH-1:0]          ddrc_dfi_reset_n_next;
wire [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0] ddrc_dfi_wrdata_cs_next;
wire [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0] ddrc_dfi_rddata_cs_next;

wire                                ddrc_dfi_ctrlupd_req_next;
wire                                ddrc_dfi_phyupd_ack_next;
wire                                ddrc_dfi_phymstr_ack_next;
wire [$bits(dfi_lp_ctrl_wakeup_int)-1:0] ddrc_dfi_lp_ctrl_wakeup_next;
wire                                     ddrc_dfi_lp_ctrl_req_next;
wire [$bits(dfi_lp_data_wakeup_int)-1:0] ddrc_dfi_lp_data_wakeup_next;
wire                                     ddrc_dfi_lp_data_req_next;
wire [NUM_DRAM_CLKS-1:0]            ddrc_dfi_dram_clk_disable_next;
wire [`MEMC_FREQ_RATIO-1:0]         ddrc_dfi_parity_in_next;
wire [`MEMC_FREQ_RATIO-1:0]         ddrc_dfi_parity_in_ecc; // common signal with or without ECC delay

wire                                dfi_init_start_int;
wire                                ddrc_dfi_init_start_next;
wire [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    gs_dfi_wck_cs_next;
wire [`MEMC_FREQ_RATIO-1:0]              gs_dfi_wck_en_next;
wire [2*`MEMC_FREQ_RATIO-1:0]            gs_dfi_wck_toggle_next;

wire    [`MEMC_FREQ_RATIO-1:0]              align_phy_rasn;
wire    [`MEMC_FREQ_RATIO-1:0]              align_phy_casn;
wire    [`MEMC_FREQ_RATIO-1:0]              align_phy_wen;
wire    [`MEMC_FREQ_RATIO*BANK_BITS-1:0]    align_phy_ba;
dfi_address_s                               align_phy_addr;
dfi_address_s                               ddrc_phy_addr_i;

reg     [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0]  ddrc_phy_ba_i;
reg     [`MEMC_FREQ_RATIO-1:0]              ddrc_phy_casn_i;
reg     [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_phy_csn_i;
reg     [`MEMC_FREQ_RATIO-1:0]              ddrc_phy_rasn_i;
reg     [`MEMC_FREQ_RATIO-1:0]              ddrc_phy_wen_i;
wire    [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_phy_odt_i;

wire                                        lpddr_mode;
assign lpddr_mode = reg_ddrc_lpddr4 | reg_ddrc_lpddr5;

wire                                        block_dfi_ctrlmsg;

//------------------------
    always @(*) begin
        ddrc_phy_addr_i           = ddrc_phy_addr;
        ddrc_phy_ba_i             = ddrc_phy_ba;
        ddrc_phy_casn_i           = ddrc_phy_casn;
        ddrc_phy_csn_i            = ddrc_phy_csn;
        ddrc_phy_rasn_i           = ddrc_phy_rasn;
        ddrc_phy_wen_i            = ddrc_phy_wen;
    end

    assign   ddrc_phy_odt_i             = ddrc_phy_odt;


//---------------------------------------------------------------------------
//----------------------------C/A Parity Poisoning---------------------------
//---------------------------------------------------------------------------



    assign  align_phy_rasn          = ddrc_phy_rasn_i;
    assign  align_phy_casn          = ddrc_phy_casn_i;
    assign  align_phy_wen           = ddrc_phy_wen_i;
    assign  align_phy_ba            = ddrc_phy_ba_i;
    assign  align_phy_addr          = ddrc_phy_addr_i;


//-----------
// Assign the control signals
//-----------

assign ddrc_dfi_address_next          = align_phy_addr;


assign ddrc_dfi_freq_ratio_next       = (reg_ddrc_frequency_ratio) ? 2'b10 : 2'b01;

assign ddrc_dfi_bank_next             =
                                        (lpddr_mode) ? {`MEMC_FREQ_RATIO*BANK_BITS{1'b0}} :
                                        align_phy_ba;

assign ddrc_dfi_ras_n_next            =
                                        (lpddr_mode) ? {`MEMC_FREQ_RATIO{1'b1}} :
                                        align_phy_rasn;

assign ddrc_dfi_cas_n_next            =
                                        (lpddr_mode) ? {`MEMC_FREQ_RATIO{1'b1}} :
                                        align_phy_casn;

assign ddrc_dfi_we_n_next             =
                                        (lpddr_mode) ? {`MEMC_FREQ_RATIO{1'b1}} :
                                        align_phy_wen;


generate
   genvar n, r;
   if (SHARED_AC==1 && CHANNEL_NUM==0) begin: DUAL_ch
      for (r = 0; r < NUM_RANKS; r=r+1) begin: dfi_cs_next_gen
         for (n = 0; n < `MEMC_FREQ_RATIO/2; n=n+1) begin
         // if dual channel is enabled, move channel0's dfi_cs (command) from phase1/3 (ODD) to phase0/2 (EVEN),
         // that will cause every commands depend on CS early one SDR cycle for channel0
         assign {ddrc_dfi_cs_next[r+(2*n+1)*NUM_RANKS], ddrc_dfi_cs_next[r+2*n*NUM_RANKS]}  =
                                                                           {ddrc_phy_csn_i[r+2*n*NUM_RANKS], ddrc_phy_csn_i[r+(2*n+1)*NUM_RANKS]};

         // Channel0 commands are pushed early one SDR cycle, so the CKE should be pushed early one SDR cycle too. i.e
         // Moving the dfi_cke from 2'b10 to 2'b11 cause cke rise edge early one SDR cycle, then cause SRX or PDX command early one SDR clock.
         // Also moving dfi_cke from 2'b01 to 2'b00 cause cke fall edge early one SDR cycle, then cause SRE and PDE command early one SDR clock.
         assign {ddrc_dfi_cke_next[r+(2*n+1)*NUM_RANKS], ddrc_dfi_cke_next[r+2*n*NUM_RANKS]}  =
                                                                           {ddrc_phy_cke[r+(2*n+1)*NUM_RANKS], ddrc_phy_cke[r+2*n*NUM_RANKS]} == 2'b01 ? 2'b00 : //cke 1->0 in ODD command, push fall edge early one SDR cycle
                                                                           {ddrc_phy_cke[r+(2*n+1)*NUM_RANKS], ddrc_phy_cke[r+2*n*NUM_RANKS]} == 2'b10 ? 2'b11 : //cke 0->1 on ODD command, push rise edge early one SDR cycle
                                                                           {ddrc_phy_cke[r+(2*n+1)*NUM_RANKS], ddrc_phy_cke[r+2*n*NUM_RANKS]};
         end
      end
   end
   else begin: SINGLE_ch

      assign ddrc_dfi_cs_next             = ddrc_phy_csn_i;
      assign ddrc_dfi_cke_next            = ddrc_phy_cke;

   end
endgenerate


assign ddrc_dfi_odt_next              = ddrc_phy_odt_i;


//-------------------
// 2T mode flopping for wrdata_en and wrdata/mask and rddata_en i DFI 1:2 mode
//-------------------

assign ddrc_dfi_wrdata_cs_next      = ddrc_phy_wrdata_cs_n;
assign ddrc_dfi_rddata_cs_next      = ddrc_phy_rddata_cs_n;

assign gs_dfi_wck_cs_next           = gs_dfi_wck_cs;
assign gs_dfi_wck_en_next           = gs_dfi_wck_en;
assign gs_dfi_wck_toggle_next       = gs_dfi_wck_toggle;

//-----------------------------------
//-----------------------------------


assign ddrc_dfi_reset_n_next          =
                                       lpddr_mode    ? {`UMCTL2_RESET_WIDTH{ddrc_phy_dram_rst_n}} :
                                                       {`UMCTL2_RESET_WIDTH{1'b1}};

assign ddrc_dfi_ctrlupd_req_next      = ts_dfi_ctrlupd_req;

assign ddrc_dfi_lp_ctrl_wakeup_next  = dfi_lp_ctrl_wakeup_int;
assign ddrc_dfi_lp_ctrl_req_next     = dfi_lp_ctrl_req_int;
assign ddrc_dfi_lp_data_wakeup_next  = dfi_lp_data_wakeup_int;
assign ddrc_dfi_lp_data_req_next     = dfi_lp_data_req_int;

assign ddrc_dfi_dram_clk_disable_next = {NUM_DRAM_CLKS{ddrc_phy_stop_clk}};

genvar phase;

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((phase * ADDR_WIDTH) + 17)' found in module 'dfi_ctrl'
//SJ: This coding style is acceptable and there is no plan to change it

generate
for (phase = 0; phase < `MEMC_FREQ_RATIO; phase=phase+1)
  begin : dfi_parity_gen
    assign ddrc_dfi_parity_in_ecc[phase]      =
                                                    1'b0;
end
endgenerate
//spyglass enable_block SelfDeterminedExpr-ML

//------------------------------------------------------------------------------
//  Variable delay flops for parity (DDR4 or further use)
//   - Controlled by reg_ddrc_dfi_t_parin_lat
//   - Delayed for 0,1,2 and 3 clock cycle(s)
//------------------------------------------------------------------------------
    assign ddrc_dfi_parity_in_next = ddrc_dfi_parity_in_ecc;


    assign dfi_init_start_int = reg_ddrc_dfi_init_start;

//------------------------------------------------------------------------------
// End: Initial handling of signals
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Command pipeline
//------------------------------------------------------------------------------



dfi_address_s                               ddrc_dfi_address_r          [MAX_CMD_DELAY-1:0];
reg [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0]      ddrc_dfi_bank_r             [MAX_CMD_DELAY-1:0];
reg [1:0]                                   ddrc_dfi_freq_ratio_r       [MAX_CMD_DELAY-1:0];
reg [`MEMC_FREQ_RATIO-1:0]                  ddrc_dfi_ras_n_r            [MAX_CMD_DELAY-1:0];
reg [`MEMC_FREQ_RATIO-1:0]                  ddrc_dfi_cas_n_r            [MAX_CMD_DELAY-1:0];
reg [`MEMC_FREQ_RATIO-1:0]                  ddrc_dfi_we_n_r             [MAX_CMD_DELAY-1:0];
reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]      ddrc_dfi_cke_r              [MAX_CMD_DELAY-1:0];
reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]      ddrc_dfi_cs_r               [MAX_CMD_DELAY-1:0];
reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]      ddrc_dfi_odt_r              [MAX_CMD_DELAY-1:0];
reg [`UMCTL2_RESET_WIDTH-1:0]               ddrc_dfi_reset_n_r          [MAX_CMD_DELAY-1:0];


    reg [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0]    ddrc_dfi_wrdata_cs_r[MAX_CMD_DELAY-1:0];
    reg [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0]    ddrc_dfi_rddata_cs_r[MAX_CMD_DELAY-1:0];


reg                                         ddrc_dfi_ctrlupd_req_r      [MAX_CMD_DELAY-1:0];
reg [NUM_DRAM_CLKS-1:0]                     ddrc_dfi_dram_clk_disable_r [MAX_CMD_DELAY-1:0];
reg [`MEMC_FREQ_RATIO-1:0]                  ddrc_dfi_parity_in_r        [MAX_CMD_DELAY-1:0];
reg                                         ddrc_dfi_phyupd_ack_r       [MAX_CMD_DELAY-1:0];
reg                                         ddrc_dfi_phymstr_ack_r      [MAX_CMD_DELAY-1:0];
reg [DFI_LP_WAKEUP_PD_WIDTH-1:0]            ddrc_dfi_lp_ctrl_wakeup_r   [MAX_CMD_DELAY-1:0];
reg                                         ddrc_dfi_lp_ctrl_req_r      [MAX_CMD_DELAY-1:0];
//reg [DFI_LP_WAKEUP_PD_WIDTH-1:0]            ddrc_dfi_lp_data_wakeup_r   [MAX_CMD_DELAY-1:0];
//reg                                         ddrc_dfi_lp_data_req_r      [MAX_CMD_DELAY-1:0];

    reg                                     ddrc_dfi_init_start_r       [MAX_CMD_DELAY-1:0];

reg                                         init_flag;

always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        init_flag <= 1'b1;
    end
    else begin
        init_flag <= 1'b0;
    end
end


integer i;

always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        for (i=0; i<MAX_CMD_DELAY; i=i+1) begin
            ddrc_dfi_address_r[i]           <= {$bits(ddrc_dfi_address_r[i]){1'b0}};
            ddrc_dfi_bank_r[i]              <= {`MEMC_FREQ_RATIO*BANK_BITS{1'b0}};
            ddrc_dfi_freq_ratio_r[i]        <= 2'b0;
            ddrc_dfi_ras_n_r[i]             <= {`MEMC_FREQ_RATIO{1'b1}};
            ddrc_dfi_cas_n_r[i]             <= {`MEMC_FREQ_RATIO{1'b1}};
            ddrc_dfi_we_n_r[i]              <= {`MEMC_FREQ_RATIO{1'b1}};
            ddrc_dfi_cke_r[i]               <= {`MEMC_FREQ_RATIO*NUM_RANKS{1'b0}};
            ddrc_dfi_cs_r[i]                <= {`MEMC_FREQ_RATIO*NUM_RANKS{1'b1}};
            ddrc_dfi_odt_r[i]               <= {`MEMC_FREQ_RATIO*NUM_RANKS{1'b0}};
            ddrc_dfi_reset_n_r[i]           <= {`UMCTL2_RESET_WIDTH{1'b0}};
            ddrc_dfi_wrdata_cs_r[i]         <= {`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES{1'b1}};
            ddrc_dfi_rddata_cs_r[i]         <= {`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES{1'b1}};
            ddrc_dfi_ctrlupd_req_r[i]       <= 1'b0;
            ddrc_dfi_phyupd_ack_r[i]        <= 1'b0;
            ddrc_dfi_phymstr_ack_r[i]       <= 1'b0;
            ddrc_dfi_lp_ctrl_wakeup_r[i]    <= 5'b00000;
            ddrc_dfi_lp_ctrl_req_r[i]       <= 1'b0;
//            ddrc_dfi_lp_data_wakeup_r[i]    <= 5'b00000;
//            ddrc_dfi_lp_data_req_r[i]       <= 1'b0;
            ddrc_dfi_dram_clk_disable_r[i]  <= {NUM_DRAM_CLKS{1'b0}};
            ddrc_dfi_parity_in_r[i]         <= {`MEMC_FREQ_RATIO{1'b0}}; // dfi_act_n, which is negative logic, is added to exclusive-OR when DDR4 mode
            ddrc_dfi_init_start_r[i]        <= 1'b0;
        end
    end
    else if (init_flag) begin
        for (i=0; i<MAX_CMD_DELAY; i=i+1) begin
            ddrc_dfi_address_r[i]           <= ddrc_dfi_address_next;
            ddrc_dfi_bank_r[i]              <= ddrc_dfi_bank_next;
            ddrc_dfi_freq_ratio_r[i]        <= ddrc_dfi_freq_ratio_next;
            ddrc_dfi_ras_n_r[i]             <= ddrc_dfi_ras_n_next;
            ddrc_dfi_cas_n_r[i]             <= ddrc_dfi_cas_n_next;
            ddrc_dfi_we_n_r[i]              <= ddrc_dfi_we_n_next;
            ddrc_dfi_cke_r[i]               <= ddrc_dfi_cke_next;
            ddrc_dfi_cs_r[i]                <= ddrc_dfi_cs_next;
            ddrc_dfi_odt_r[i]               <= ddrc_dfi_odt_next;
            ddrc_dfi_reset_n_r[i]           <= ddrc_dfi_reset_n_next;
            ddrc_dfi_wrdata_cs_r[i]         <= ddrc_dfi_wrdata_cs_next;
            ddrc_dfi_rddata_cs_r[i]         <= ddrc_dfi_rddata_cs_next;
            ddrc_dfi_ctrlupd_req_r[i]       <= ddrc_dfi_ctrlupd_req_next;
            ddrc_dfi_phyupd_ack_r[i]        <= ddrc_dfi_phyupd_ack_next;
            ddrc_dfi_phymstr_ack_r[i]       <= ddrc_dfi_phymstr_ack_next;
            ddrc_dfi_lp_ctrl_wakeup_r[i]    <= ddrc_dfi_lp_ctrl_wakeup_next;
            ddrc_dfi_lp_ctrl_req_r[i]       <= ddrc_dfi_lp_ctrl_req_next;
//            ddrc_dfi_lp_data_wakeup_r[i]    <= ddrc_dfi_lp_data_wakeup_next;
//            ddrc_dfi_lp_data_req_r[i]       <= ddrc_dfi_lp_data_req_next;
            ddrc_dfi_dram_clk_disable_r[i]  <= ddrc_dfi_dram_clk_disable_next;
            ddrc_dfi_parity_in_r[i]         <= ddrc_dfi_parity_in_next;
            ddrc_dfi_init_start_r[i]        <= ddrc_dfi_init_start_next;
        end
    end
    else begin
            ddrc_dfi_address_r[0]           <= ddrc_dfi_address_next;
            ddrc_dfi_bank_r[0]              <= ddrc_dfi_bank_next;
            ddrc_dfi_freq_ratio_r[0]        <= ddrc_dfi_freq_ratio_next;
            ddrc_dfi_ras_n_r[0]             <= ddrc_dfi_ras_n_next;
            ddrc_dfi_cas_n_r[0]             <= ddrc_dfi_cas_n_next;
            ddrc_dfi_we_n_r[0]              <= ddrc_dfi_we_n_next;
            ddrc_dfi_cke_r[0]               <= ddrc_dfi_cke_next;
            ddrc_dfi_cs_r[0]                <= ddrc_dfi_cs_next;
            ddrc_dfi_odt_r[0]               <= ddrc_dfi_odt_next;
            ddrc_dfi_reset_n_r[0]           <= ddrc_dfi_reset_n_next;
            ddrc_dfi_wrdata_cs_r[0]         <= ddrc_dfi_wrdata_cs_next;
            ddrc_dfi_rddata_cs_r[0]         <= ddrc_dfi_rddata_cs_next;
            ddrc_dfi_ctrlupd_req_r[0]       <= ddrc_dfi_ctrlupd_req_next;
            ddrc_dfi_phyupd_ack_r[0]        <= ddrc_dfi_phyupd_ack_next;
            ddrc_dfi_phymstr_ack_r[0]       <= ddrc_dfi_phymstr_ack_next;
            ddrc_dfi_lp_ctrl_wakeup_r[0]    <= ddrc_dfi_lp_ctrl_wakeup_next;
            ddrc_dfi_lp_ctrl_req_r[0]       <= ddrc_dfi_lp_ctrl_req_next;
//            ddrc_dfi_lp_data_wakeup_r[0]    <= ddrc_dfi_lp_data_wakeup_next;
//            ddrc_dfi_lp_data_req_r[0]       <= ddrc_dfi_lp_data_req_next;
            ddrc_dfi_dram_clk_disable_r[0]  <= ddrc_dfi_dram_clk_disable_next;
            ddrc_dfi_parity_in_r[0]         <= ddrc_dfi_parity_in_next;
            ddrc_dfi_init_start_r[0]        <= ddrc_dfi_init_start_next;
        //spyglass disable_block SelfDeterminedExpr-ML
        //SMD: Self determined expression '(i - 1)' found in module 'dfi_ctrl'
        //SJ: This coding style is acceptable and there is no plan to change it
        for (i=1; i<MAX_CMD_DELAY; i=i+1) begin
            ddrc_dfi_address_r[i]           <= ddrc_dfi_address_r[i-1];
            ddrc_dfi_bank_r[i]              <= ddrc_dfi_bank_r[i-1];
            ddrc_dfi_freq_ratio_r[i]        <= ddrc_dfi_freq_ratio_r[i-1];
            ddrc_dfi_ras_n_r[i]             <= ddrc_dfi_ras_n_r[i-1];
            ddrc_dfi_cas_n_r[i]             <= ddrc_dfi_cas_n_r[i-1];
            ddrc_dfi_we_n_r[i]              <= ddrc_dfi_we_n_r[i-1];
            ddrc_dfi_cke_r[i]               <= ddrc_dfi_cke_r[i-1];
            ddrc_dfi_cs_r[i]                <= ddrc_dfi_cs_r[i-1];
            ddrc_dfi_odt_r[i]               <= ddrc_dfi_odt_r[i-1];
            ddrc_dfi_reset_n_r[i]           <= ddrc_dfi_reset_n_r[i-1];
            ddrc_dfi_wrdata_cs_r[i]         <= ddrc_dfi_wrdata_cs_r[i-1];
            ddrc_dfi_rddata_cs_r[i]         <= ddrc_dfi_rddata_cs_r[i-1];
            ddrc_dfi_ctrlupd_req_r[i]       <= ddrc_dfi_ctrlupd_req_r[i-1];
            ddrc_dfi_phyupd_ack_r[i]        <= ddrc_dfi_phyupd_ack_r[i-1];
            ddrc_dfi_phymstr_ack_r[i]       <= ddrc_dfi_phymstr_ack_r[i-1];
            ddrc_dfi_lp_ctrl_wakeup_r[i]    <= ddrc_dfi_lp_ctrl_wakeup_r[i-1];
            ddrc_dfi_lp_ctrl_req_r[i]       <= ddrc_dfi_lp_ctrl_req_r[i-1];
//            ddrc_dfi_lp_data_wakeup_r[i]    <= ddrc_dfi_lp_data_wakeup_r[i-1];
//            ddrc_dfi_lp_data_req_r[i]       <= ddrc_dfi_lp_data_req_r[i-1];
            ddrc_dfi_dram_clk_disable_r[i]  <= ddrc_dfi_dram_clk_disable_r[i-1];
            ddrc_dfi_parity_in_r[i]         <= ddrc_dfi_parity_in_r[i-1];
            ddrc_dfi_init_start_r[i]        <= ddrc_dfi_init_start_r[i-1];
        end
        //spyglass enable_block SelfDeterminedExpr-ML
    end
end

wire pipeline_empty;
assign pipeline_empty = (ddrc_dfi_phyupd_ack_r[0]  == 1'b0) &
                        (ddrc_dfi_phyupd_ack_r[1]  == 1'b0) &
                        (ddrc_dfi_phyupd_ack_r[2]  == 1'b0) &
                        (ddrc_dfi_phyupd_ack_next  == 1'b0) &

                        (ddrc_dfi_ctrlupd_req_r[0] == 1'b0) &
                        (ddrc_dfi_ctrlupd_req_r[1] == 1'b0) &
                        (ddrc_dfi_ctrlupd_req_r[2] == 1'b0) &
                        (ddrc_dfi_ctrlupd_req_next == 1'b0) &

                        (ddrc_dfi_phymstr_ack_r[0] == 1'b0) &
                        (ddrc_dfi_phymstr_ack_r[1] == 1'b0) &
                        (ddrc_dfi_phymstr_ack_r[2] == 1'b0) &
                        (ddrc_dfi_phymstr_ack_next == 1'b0);

reg [CMD_DELAY_BITS-1:0]  dfi_cmd_delay_r;
always @(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    dfi_cmd_delay_r <= {CMD_DELAY_BITS{1'b0}};
  end
  else if (pipeline_empty == 1'b1) begin
    dfi_cmd_delay_r <= dfi_cmd_delay;
  end
end

//------------------------------------------------------------------------------
// End: Command pipeline
//------------------------------------------------------------------------------

    dfi_address_s                           ddrc_dfi_address_preff;

    reg [(`MEMC_FREQ_RATIO*BANK_BITS)-1:0]  ddrc_dfi_bank_preff;
    reg [1:0]                               ddrc_dfi_freq_ratio_preff;
    reg [`MEMC_FREQ_RATIO-1:0]              ddrc_dfi_ras_n_preff;
    reg [`MEMC_FREQ_RATIO-1:0]              ddrc_dfi_cas_n_preff;
    reg [`MEMC_FREQ_RATIO-1:0]              ddrc_dfi_we_n_preff;
    reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_dfi_cke_preff;
    reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_dfi_cs_preff;
    reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_dfi_odt_preff;
    reg [`UMCTL2_RESET_WIDTH-1:0]           ddrc_dfi_reset_n_preff;
    reg [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0]    ddrc_dfi_wrdata_cs_preff;
    reg [(`MEMC_FREQ_RATIO*NUM_RANKS*NUM_LANES)-1:0]    ddrc_dfi_rddata_cs_preff;

    reg                                     ddrc_dfi_ctrlupd_req_preff;
    reg [NUM_DRAM_CLKS-1:0]                 ddrc_dfi_dram_clk_disable_preff;
    reg [`MEMC_FREQ_RATIO-1:0]              ddrc_dfi_parity_in_preff;
    reg                                     ddrc_dfi_phyupd_ack_preff;
    reg                                     ddrc_dfi_phymstr_ack_preff;
    reg [$bits(ddrc_dfi_lp_ctrl_wakeup_next)-1:0]ddrc_dfi_lp_ctrl_wakeup_preff;
    reg                                          ddrc_dfi_lp_ctrl_req_preff;

    reg [$bits(ddrc_dfi_lp_data_wakeup_next)-1:0]ddrc_dfi_lp_data_wakeup_preff;
    reg                                          ddrc_dfi_lp_data_req_preff;
    reg                                     ddrc_dfi_init_start_preff;
    reg [`MEMC_FREQ_RATIO*NUM_RANKS-1:0]    gs_dfi_wck_cs_preff;
    reg [`MEMC_FREQ_RATIO-1:0]              gs_dfi_wck_en_preff;
    reg [2*`MEMC_FREQ_RATIO-1:0]            gs_dfi_wck_toggle_preff;

wire [CMD_DELAY_BITS:0]    dfi_cmd_delay_r_m1_wider;
wire [CMD_DELAY_BITS-1:0]  dfi_cmd_delay_r_m1;
assign dfi_cmd_delay_r_m1_wider = dfi_cmd_delay_r-1;
assign dfi_cmd_delay_r_m1 = dfi_cmd_delay_r_m1_wider[CMD_DELAY_BITS-1:0];

always @(*) begin
    if (dfi_cmd_delay_r == 0) begin
        ddrc_dfi_ctrlupd_req_preff      = ddrc_dfi_ctrlupd_req_next ;
        ddrc_dfi_phyupd_ack_preff       = ddrc_dfi_phyupd_ack_next ;
        ddrc_dfi_phymstr_ack_preff      = ddrc_dfi_phymstr_ack_next ;
    end else begin
//spyglass disable_block ImproperRangeIndex-ML
//SMD: Index 'dfi_cmd_delay_r_m1' of width '3' is larger than the width '2' required for the max value '3' of the signal 'ddrc_dfi_xxxx_r'
//SJ:  This is because UMCTL2_MAX_CMD_DELAY is not specified as 2^n-1. The index cannot indicate improper range arithmetically.
        ddrc_dfi_ctrlupd_req_preff      = ddrc_dfi_ctrlupd_req_r        [dfi_cmd_delay_r_m1];
        ddrc_dfi_phyupd_ack_preff       = ddrc_dfi_phyupd_ack_r         [dfi_cmd_delay_r_m1];
        ddrc_dfi_phymstr_ack_preff      = ddrc_dfi_phymstr_ack_r        [dfi_cmd_delay_r_m1];
// spyglass enable_block ImproperRangeIndex-ML
    end
end

wire [CMD_DELAY_BITS-1:0]               dfi_cmd_delay_m1;
wire [CMD_DELAY_BITS:0]                 dfi_cmd_delay_m1_wider;
assign dfi_cmd_delay_m1_wider = dfi_cmd_delay-1;
assign dfi_cmd_delay_m1 = dfi_cmd_delay_m1_wider[CMD_DELAY_BITS-1:0];

always @(*) begin
    if (dfi_cmd_delay == 0) begin
        ddrc_dfi_address_preff          = ddrc_dfi_address_next ;
        ddrc_dfi_bank_preff             = ddrc_dfi_bank_next ;
        ddrc_dfi_freq_ratio_preff       = ddrc_dfi_freq_ratio_next ;
        ddrc_dfi_ras_n_preff            = ddrc_dfi_ras_n_next ;
        ddrc_dfi_cas_n_preff            = ddrc_dfi_cas_n_next ;
        ddrc_dfi_we_n_preff             = ddrc_dfi_we_n_next ;
        ddrc_dfi_cke_preff              = ddrc_dfi_cke_next ;
        ddrc_dfi_cs_preff               = ddrc_dfi_cs_next ;
        ddrc_dfi_odt_preff              = ddrc_dfi_odt_next ;
        ddrc_dfi_reset_n_preff          = ddrc_dfi_reset_n_next ;
        ddrc_dfi_wrdata_cs_preff        = ddrc_dfi_wrdata_cs_next ;
        ddrc_dfi_rddata_cs_preff        = ddrc_dfi_rddata_cs_next ;

        ddrc_dfi_lp_ctrl_wakeup_preff   = ddrc_dfi_lp_ctrl_wakeup_next ;
        ddrc_dfi_lp_ctrl_req_preff      = ddrc_dfi_lp_ctrl_req_next ;
//        ddrc_dfi_lp_data_wakeup_preff   = ddrc_dfi_lp_data_wakeup_next ;
//        ddrc_dfi_lp_data_req_preff      = ddrc_dfi_lp_data_req_next ;
        ddrc_dfi_dram_clk_disable_preff = ddrc_dfi_dram_clk_disable_next ;
        ddrc_dfi_parity_in_preff        = ddrc_dfi_parity_in_next ;
        ddrc_dfi_init_start_preff       = ddrc_dfi_init_start_next ;
    end
    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '(dfi_cmd_delay - 1)' found in module 'dfi_ctrl'
    //SJ: This coding style is acceptable and there is no plan to change it
    else begin
        //spyglass disable_block ImproperRangeIndex-ML
        //SMD: Index 'dfi_cmd_delay_m1' of width '3' is larger than the width '2' required for the max value '3' of the signal 'ddrc_dfi_xxxx_r'
        //SJ:  This is because UMCTL2_MAX_CMD_DELAY is not specified as 2^n-1. The index cannot indicate improper range arithmetically.
        ddrc_dfi_address_preff          = ddrc_dfi_address_r            [dfi_cmd_delay_m1];
        ddrc_dfi_bank_preff             = ddrc_dfi_bank_r               [dfi_cmd_delay_m1];
        ddrc_dfi_freq_ratio_preff       = ddrc_dfi_freq_ratio_r         [dfi_cmd_delay_m1];
        ddrc_dfi_ras_n_preff            = ddrc_dfi_ras_n_r              [dfi_cmd_delay_m1];
        ddrc_dfi_cas_n_preff            = ddrc_dfi_cas_n_r              [dfi_cmd_delay_m1];
        ddrc_dfi_we_n_preff             = ddrc_dfi_we_n_r               [dfi_cmd_delay_m1];
        ddrc_dfi_cke_preff              = ddrc_dfi_cke_r                [dfi_cmd_delay_m1];
        ddrc_dfi_cs_preff               = ddrc_dfi_cs_r                 [dfi_cmd_delay_m1];
        ddrc_dfi_odt_preff              = ddrc_dfi_odt_r                [dfi_cmd_delay_m1];
        ddrc_dfi_reset_n_preff          = ddrc_dfi_reset_n_r            [dfi_cmd_delay_m1];
        ddrc_dfi_wrdata_cs_preff        = ddrc_dfi_wrdata_cs_r          [dfi_cmd_delay_m1];
        ddrc_dfi_rddata_cs_preff        = ddrc_dfi_rddata_cs_r          [dfi_cmd_delay_m1];
        ddrc_dfi_lp_ctrl_wakeup_preff   = ddrc_dfi_lp_ctrl_wakeup_r     [dfi_cmd_delay_m1];
        ddrc_dfi_lp_ctrl_req_preff      = ddrc_dfi_lp_ctrl_req_r        [dfi_cmd_delay_m1];
//        ddrc_dfi_lp_data_wakeup_preff   = ddrc_dfi_lp_data_wakeup_r     [dfi_cmd_delay_m1];
//        ddrc_dfi_lp_data_req_preff      = ddrc_dfi_lp_data_req_r        [dfi_cmd_delay_m1];
        ddrc_dfi_dram_clk_disable_preff = ddrc_dfi_dram_clk_disable_r   [dfi_cmd_delay_m1];
        ddrc_dfi_parity_in_preff        = ddrc_dfi_parity_in_r          [dfi_cmd_delay_m1];
        ddrc_dfi_init_start_preff       = ddrc_dfi_init_start_r         [dfi_cmd_delay_m1];
    end
    ddrc_dfi_lp_data_wakeup_preff   = ddrc_dfi_lp_data_wakeup_next ;
    ddrc_dfi_lp_data_req_preff      = ddrc_dfi_lp_data_req_next ;
    gs_dfi_wck_cs_preff             = gs_dfi_wck_cs_next;
    gs_dfi_wck_en_preff             = gs_dfi_wck_en_next;
    gs_dfi_wck_toggle_preff         = gs_dfi_wck_toggle_next;
        // spyglass enable_block ImproperRangeIndex-ML
    //spyglass enable_block SelfDeterminedExpr-ML
end


//------------------------------------------------------------------------------
// End: Command pipeline
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Begin: Final signal assignments
//------------------------------------------------------------------------------

    assign dfi_address              = ddrc_dfi_address_preff;
    assign dfi_bank                 = ddrc_dfi_bank_preff;
    assign dfi_freq_ratio           = ddrc_dfi_freq_ratio_preff;
    assign dfi_ras_n                = ddrc_dfi_ras_n_preff;
    assign dfi_cas_n                = ddrc_dfi_cas_n_preff;
    assign dfi_we_n                 = ddrc_dfi_we_n_preff;
    assign dfi_parity_in            = ddrc_dfi_parity_in_preff;
    assign dfi_cke                  = ddrc_dfi_cke_preff;
    assign dfi_cs                   = ddrc_dfi_cs_preff;
    assign dfi_odt                  = ddrc_dfi_odt_preff;
    assign dfi_reset_n              = ddrc_dfi_reset_n_preff;
    assign dfi_wrdata_cs            = ddrc_dfi_wrdata_cs_preff;
    assign dfi_rddata_cs            = ddrc_dfi_rddata_cs_preff;
    assign dfi_ctrlupd_req          = ddrc_dfi_ctrlupd_req_preff;
    assign dfi_phyupd_ack           = ddrc_dfi_phyupd_ack_preff;
    assign dfi_phymstr_ack          = ddrc_dfi_phymstr_ack_preff;
    assign dfi_lp_ctrl_wakeup       = ddrc_dfi_lp_ctrl_wakeup_preff;
    assign dfi_lp_ctrl_req          = ddrc_dfi_lp_ctrl_req_preff;
    assign dfi_lp_data_wakeup       = ddrc_dfi_lp_data_wakeup_preff;
    assign dfi_lp_data_req          = ddrc_dfi_lp_data_req_preff;
    assign dfi_dram_clk_disable     = ddrc_dfi_dram_clk_disable_preff;
    assign dfi_init_start           = ddrc_dfi_init_start_preff;
    assign dfi_wck_cs               = gs_dfi_wck_cs_preff;
    assign dfi_wck_en               = gs_dfi_wck_en_preff;
    assign dfi_wck_toggle           = gs_dfi_wck_toggle_preff;


//--------------------------------------------------
// End: Final assignment
//--------------------------------------------------


//*********************************************************************************
// Make dfi_phyupd_req input registered
//*********************************************************************************
reg dfi_phyupd_req_r;

always@(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
   if (~core_ddrc_rstn)
      dfi_phyupd_req_r  <= 1'b0;
   else
      dfi_phyupd_req_r  <= dfi_phyupd_req;
end

assign phy_dfi_phyupd_req = dfi_phyupd_req_r;

//*********************************************************************************
// Make dfi_init_complete input registered
//*********************************************************************************
//reg phy_dfi_init_complete;
always@(posedge core_ddrc_core_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn)
        phy_dfi_init_complete <= 1'b0;
    else begin
        phy_dfi_init_complete <= dfi_init_complete;
    end
end

//*********************************************************************************
// dfi_init_start/dfi_phyupd_ack/dfi_phymstr_ack handling
//   1. The MC must never have both the dfi_init_start and the
//   dfi_phyupd_ack signals asserted together.
//   2. The MC must never have both dfi_phyupd_ack and
//   dfi_phymstr_ack asserted.
//*********************************************************************************
    localparam      DFI_FSM_SIZE        = 3;
    localparam      DFI_FSM_IDLE        = 3'b000;
    localparam      DFI_FSM_INIT_START  = 3'b001;
    localparam      DFI_FSM_PHYUPD      = 3'b010;
    localparam      DFI_FSM_PHYMSTR     = 3'b100;

    reg     [DFI_FSM_SIZE-1:0]          dfi_fsm_st_curr;
    reg     [DFI_FSM_SIZE-1:0]          dfi_fsm_st_next;

    always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
    begin
        if (~core_ddrc_rstn)    begin
            dfi_fsm_st_curr <= DFI_FSM_IDLE;
        end else begin
            dfi_fsm_st_curr <= dfi_fsm_st_next;
        end
    end

    always @(*) begin
        dfi_fsm_st_next = dfi_fsm_st_curr;
        case(dfi_fsm_st_curr)
            DFI_FSM_IDLE : begin
                if (dfi_init_start_int) begin
                    dfi_fsm_st_next = DFI_FSM_INIT_START;
                end else if (dfi_phyupd_ack_int) begin
                    dfi_fsm_st_next = DFI_FSM_PHYUPD;
                end else if (dfi_phymstr_ack_int) begin
                    dfi_fsm_st_next = DFI_FSM_PHYMSTR;
                end
            end
            DFI_FSM_INIT_START : begin
                if (~dfi_init_start_int) begin
                    dfi_fsm_st_next = DFI_FSM_IDLE;
                end
            end
            DFI_FSM_PHYUPD : begin
                if (~dfi_phyupd_ack_int) begin
                   dfi_fsm_st_next = DFI_FSM_IDLE;
                end
            end
            default : begin // DFI_FSM_PHYMSTR
                if (~dfi_phymstr_ack_int) begin
                   dfi_fsm_st_next = DFI_FSM_IDLE;
                end
            end
        endcase // case (dfi_fsm_st_curr)
    end

    assign   ddrc_dfi_init_start_next   = (dfi_fsm_st_next == DFI_FSM_INIT_START);
    assign   ddrc_dfi_phyupd_ack_next   = (dfi_fsm_st_next == DFI_FSM_PHYUPD);
    assign   ddrc_dfi_phymstr_ack_next  = (dfi_fsm_st_next == DFI_FSM_PHYMSTR);

assign block_dfi_ctrlmsg = (gs_pi_ctrlupd_req | dfi_phyupd_req_r | dfilp_block_dfi_ctrlmsg | dfi_ctrlupd_req | ddrc_dfi_lp_ctrl_req_preff);

dwc_ddrctl_dfi_ctrlmsg

 U_dfi_ctrlmsg(
     .core_ddrc_core_clk                (core_ddrc_core_clk),
     .core_ddrc_rstn                    (core_ddrc_rstn),
  //--------------------------- REGISTER I/F----- -------------------------------
     .reg_ddrc_dfi_t_ctrlmsg_resp       (reg_ddrc_dfi_t_ctrlmsg_resp),
     .reg_ddrc_dfi_ctrlmsg_req          (reg_ddrc_dfi0_ctrlmsg_req),
     .reg_ddrc_dfi_ctrlmsg_tout_clr     (reg_ddrc_dfi0_ctrlmsg_tout_clr),
     .reg_ddrc_dfi_ctrlmsg_cmd          (reg_ddrc_dfi0_ctrlmsg_cmd),
     .reg_ddrc_dfi_ctrlmsg_data         (reg_ddrc_dfi0_ctrlmsg_data),
     .ddrc_reg_dfi_ctrlmsg_resp_tout    (ddrc_reg_dfi0_ctrlmsg_resp_tout),
     .ddrc_reg_dfi_ctrlmsg_req_busy     (ddrc_reg_dfi0_ctrlmsg_req_busy),
     .dfi_init_complete                 (phy_dfi_init_complete),
     .dfi_init_start                    (dfi_init_start),
     .block_dfi_ctrlmsg                 (block_dfi_ctrlmsg),
  //--------------------------- DFI control message I/F----- ----------------------
     .dfi_ctrlmsg_req                   (dfi0_ctrlmsg_req),
     .dfi_ctrlmsg                       (dfi0_ctrlmsg),
     .dfi_ctrlmsg_data                  (dfi0_ctrlmsg_data),
     .dfi_ctrlmsg_ack                   (dfi0_ctrlmsg_ack)
);

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
wire disable_check3_r, disable_check2_r, disable_check1_r, disable_check0_r; //add for dfi_ctrlupd_req,dfi_phyupd_ack,dfi_phymstr_ack

wire [2:0] reg_ddrc_ecc_mode_int;
assign reg_ddrc_ecc_mode_int = 3'b000;

reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_phy_cke_r;
reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_phy_cke_r2;
reg [(`MEMC_FREQ_RATIO*NUM_RANKS)-1:0]  ddrc_phy_cke_r3;

assign disable_check3      = (dfi_cmd_delay != 3) | ~core_ddrc_rstn; // disable check3 when any of the other checks are high
assign disable_check2      = (dfi_cmd_delay != 2) | ~core_ddrc_rstn; // disable check2 when any of the other checks are high
assign disable_check1      = (dfi_cmd_delay != 1) | ~core_ddrc_rstn; // disable check1 when any of the other checks are high
assign disable_check0      = (dfi_cmd_delay != 0) | ~core_ddrc_rstn; // disable check0 when any of the other checks are high

assign disable_check3_r    = (dfi_cmd_delay_r != 3) | ~core_ddrc_rstn; // disable check3 when any of the other checks are high for dfi_ctrlupd_req,dfi_phyupd_ack,dfi_phymstr_ack
assign disable_check2_r    = (dfi_cmd_delay_r != 2) | ~core_ddrc_rstn; // disable check2 when any of the other checks are high for dfi_ctrlupd_req,dfi_phyupd_ack,dfi_phymstr_ack
assign disable_check1_r    = (dfi_cmd_delay_r != 1) | ~core_ddrc_rstn; // disable check1 when any of the other checks are high for dfi_ctrlupd_req,dfi_phyupd_ack,dfi_phymstr_ack
assign disable_check0_r    = (dfi_cmd_delay_r != 0) | ~core_ddrc_rstn; // disable check0 when any of the other checks are high for dfi_ctrlupd_req,dfi_phyupd_ack,dfi_phymstr_ack

//---------------------
// Generating the lpddr4, ddr4 mode signals to be used in the assertions
//---------------------

wire lpddr4, ddr4_mode;

assign lpddr4 =
                                 reg_ddrc_lpddr4 |
                                 1'b0;

assign ddr4_mode =                          1'b0;

//-------------------------
// replicating the dfi_lp_* assignment for the following set of assertions
// the actual dfi_lp_* signals are forced from the TB (ddrc_env.sv) at the end
// of some of the tests and hence cannot be used in the following assertions
//-------------------------

wire [$bits(ddrc_dfi_lp_ctrl_wakeup_preff)-1:0] dfi_lp_ctrl_wakeup_out;
wire dfi_lp_ctrl_req_out;
wire [$bits(ddrc_dfi_lp_data_wakeup_preff)-1:0] dfi_lp_data_wakeup_out;
wire dfi_lp_data_req_out;

assign dfi_lp_ctrl_wakeup_out= ddrc_dfi_lp_ctrl_wakeup_preff;
assign dfi_lp_ctrl_req_out   = ddrc_dfi_lp_ctrl_req_preff;
assign dfi_lp_data_wakeup_out= ddrc_dfi_lp_data_wakeup_preff;
assign dfi_lp_data_req_out   = ddrc_dfi_lp_data_req_preff;

always @ (posedge core_ddrc_core_clk or negedge core_ddrc_rstn)
   if (~core_ddrc_rstn) begin
      ddrc_phy_cke_r  <= {(`MEMC_FREQ_RATIO*NUM_RANKS){1'b0}};
      ddrc_phy_cke_r2 <= {(`MEMC_FREQ_RATIO*NUM_RANKS){1'b0}};
      ddrc_phy_cke_r3 <= {(`MEMC_FREQ_RATIO*NUM_RANKS){1'b0}};
   end else begin
      ddrc_phy_cke_r  <= ddrc_phy_cke;
      ddrc_phy_cke_r2 <= ddrc_phy_cke_r;
      ddrc_phy_cke_r3 <= ddrc_phy_cke_r2;
   end



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

assert_dfi_addr_check_3  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
    !$stable(align_phy_addr) |-> ##3 !$stable(dfi_address) && dfi_address == $past(align_phy_addr, 3));

assert_dfi_bank_check_3  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3 || lpddr4)
    !$stable(align_phy_ba)   |-> ##3 !$stable(dfi_bank) && dfi_bank == $past(align_phy_ba, 3));

assert_dfi_cas_n_check_3 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3 || lpddr4)
    !$stable(align_phy_casn) |-> ##3 !$stable(dfi_cas_n) && dfi_cas_n == $past(align_phy_casn, 3));

assert_dfi_ras_n_check_3 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3 || lpddr4)
    !$stable(align_phy_rasn) |-> ##3 !$stable(dfi_ras_n) && dfi_ras_n == $past(align_phy_rasn, 3));

assert_dfi_we_n_check_3  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3 || lpddr4)
    !$stable(align_phy_wen)  |-> ##3 !$stable(dfi_we_n) && dfi_we_n == $past(align_phy_wen, 3));

generate
   genvar i3;
   if (SHARED_AC==1 && CHANNEL_NUM==0) begin
       for (i3 = 0; i3 < NUM_RANKS; i3=i3+1) begin
            assert_dfi_cke_check_3     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
                !$stable({ddrc_phy_cke[i3+NUM_RANKS], ddrc_phy_cke[i3]}) |->
                ##3 {dfi_cke[i3+NUM_RANKS], dfi_cke[i3]} == (
                                                          (({$past(ddrc_phy_cke[i3+NUM_RANKS], 3), $past(ddrc_phy_cke[i3], 3)} == 3'b01) ? 3'b00 :
                                                           ({$past(ddrc_phy_cke[i3+NUM_RANKS], 3), $past(ddrc_phy_cke[i3], 3)} == 3'b10) ? 3'b11 :
                                                            {$past(ddrc_phy_cke[i3+NUM_RANKS], 3), $past(ddrc_phy_cke[i3], 3)})));

            assert_dfi_cs_check_3      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
                !$stable({ddrc_phy_csn_i[i3], ddrc_phy_csn_i[i3+NUM_RANKS]}) |->
                ##3 !$stable({dfi_cs[i3+NUM_RANKS], dfi_cs[i3]}) &&
                    {dfi_cs[i3+NUM_RANKS], dfi_cs[i3]} == (
                                                            {$past(ddrc_phy_csn_i[i3], 3), $past(ddrc_phy_csn_i[i3+NUM_RANKS], 3)}));



       end
   end else begin
   assert_dfi_cke_check_3  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
        !$stable(ddrc_phy_cke)     |-> ##3 !$stable(dfi_cke) && dfi_cke == $past(ddrc_phy_cke, 3));

   assert_dfi_cs_check_3   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
        !$stable(ddrc_phy_csn_i)   |-> ##3 !$stable(dfi_cs) && dfi_cs == $past(ddrc_phy_csn_i, 3));
   end
endgenerate

assert_dfi_odt_check_3         : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
    !$stable(ddrc_phy_odt)         |-> ##3 !$stable(dfi_odt) && dfi_odt == $past(ddrc_phy_odt, 3));





assert_dfi_dram_clk_disable_check_3 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
    !$stable(ddrc_phy_stop_clk)        |-> ##3 !$stable(dfi_dram_clk_disable) &&
                                                dfi_dram_clk_disable == {NUM_DRAM_CLKS{$past(ddrc_phy_stop_clk, 3)}});

assert_dfi_ctrlupd_req_check_3      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3_r)
    !$stable(ts_dfi_ctrlupd_req)       |-> ##3 !$stable(dfi_ctrlupd_req) && dfi_ctrlupd_req == $past(ts_dfi_ctrlupd_req, 3));

assert_dfi_phyupd_ack_check_3       : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3_r | dfi_init_start_int | dfi_phymstr_ack_int)
    !$stable(dfi_phyupd_ack_int)       |-> ##3 !$stable(dfi_phyupd_ack) && dfi_phyupd_ack == $past(dfi_phyupd_ack_int, 3));

assert_dfi_phymstr_ack_check_3      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3_r | dfi_init_start_int | dfi_phyupd_ack_int)
    !$stable(dfi_phymstr_ack_int)      |-> ##3 dfi_phymstr_ack == $past(dfi_phymstr_ack_int, 3));


assert_dfi_parity_in_check_3        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3 || ddr4_mode)
    !$stable(ddrc_dfi_parity_in_next)  |-> ##3 !$stable(dfi_parity_in) && dfi_parity_in == $past(ddrc_dfi_parity_in_next, 3));

assert_dfi_lp_ctrl_wakeup_check_3   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
    !$stable(dfi_lp_ctrl_wakeup_int)   |-> ##3 !$stable(dfi_lp_ctrl_wakeup_out) && dfi_lp_ctrl_wakeup_out == $past(dfi_lp_ctrl_wakeup_int, 3));

assert_dfi_lp_ctrl_req_check_3      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check3)
    !$stable(dfi_lp_ctrl_req_int)      |-> ##3 !$stable(dfi_lp_ctrl_req_out) && dfi_lp_ctrl_req_out == $past(dfi_lp_ctrl_req_int, 3));

//------------------------------------------------------------
// 2-cycle delay in DFI module
//------------------------------------------------------------

assert_dfi_addr_check_2  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
    !$stable(align_phy_addr) |-> ##2 !$stable(dfi_address) && dfi_address == $past(align_phy_addr, 2));

assert_dfi_bank_check_2  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2 || lpddr4)
    !$stable(align_phy_ba)   |-> ##2 !$stable(dfi_bank) && dfi_bank == $past(align_phy_ba, 2));

assert_dfi_cas_n_check_2 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2 || lpddr4)
    !$stable(align_phy_casn) |-> ##2 !$stable(dfi_cas_n) && dfi_cas_n == $past(align_phy_casn, 2));

assert_dfi_ras_n_check_2 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2 || lpddr4)
    !$stable(align_phy_rasn) |-> ##2 !$stable(dfi_ras_n) && dfi_ras_n == $past(align_phy_rasn, 2));

assert_dfi_we_n_check_2  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2 || lpddr4)
    !$stable(align_phy_wen)  |-> ##2 !$stable(dfi_we_n) && dfi_we_n == $past(align_phy_wen, 2));

generate
   genvar i2;
   if (SHARED_AC==1 && CHANNEL_NUM==0) begin
       for (i2 = 0; i2 < NUM_RANKS; i2=i2+1) begin

            assert_dfi_cke_check_2     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
                !$stable({ddrc_phy_cke[i2+NUM_RANKS], ddrc_phy_cke[i2]}) |->
                ##2 {dfi_cke[i2+NUM_RANKS], dfi_cke[i2]} == (
                                                          (({$past(ddrc_phy_cke[i2+NUM_RANKS], 2), $past(ddrc_phy_cke[i2], 2)} == 2'b01) ? 2'b00 :
                                                           ({$past(ddrc_phy_cke[i2+NUM_RANKS], 2), $past(ddrc_phy_cke[i2], 2)} == 2'b10) ? 2'b11 :
                                                            {$past(ddrc_phy_cke[i2+NUM_RANKS], 2), $past(ddrc_phy_cke[i2], 2)})));

            assert_dfi_cs_check_2      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
                !$stable({ddrc_phy_csn_i[i2], ddrc_phy_csn_i[i2+NUM_RANKS]}) |->
                ##2 !$stable({dfi_cs[i2+NUM_RANKS], dfi_cs[i2]}) &&
                    {dfi_cs[i2+NUM_RANKS], dfi_cs[i2]} == (
                                                            {$past(ddrc_phy_csn_i[i2], 2), $past(ddrc_phy_csn_i[i2+NUM_RANKS], 2)}));


       end
   end else begin
   assert_dfi_cke_check_2   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
        !$stable(ddrc_phy_cke)      |-> ##2 !$stable(dfi_cke) && dfi_cke == $past(ddrc_phy_cke, 2));
   assert_dfi_cs_check_2    : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
        !$stable(ddrc_phy_csn_i)    |-> ##2 !$stable(dfi_cs) && dfi_cs == $past(ddrc_phy_csn_i, 2));
   end
endgenerate

assert_dfi_odt_check_2         : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
    !$stable(ddrc_phy_odt)         |-> ##2 !$stable(dfi_odt) && dfi_odt == $past(ddrc_phy_odt, 2));




assert_dfi_dram_clk_disable_check_2 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
    !$stable(ddrc_phy_stop_clk)        |-> ##2 !$stable(dfi_dram_clk_disable) &&
                                               dfi_dram_clk_disable == {NUM_DRAM_CLKS{$past(ddrc_phy_stop_clk, 2)}});

assert_dfi_ctrlupd_req_check_2      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2_r)
    !$stable(ts_dfi_ctrlupd_req)       |-> ##2 !$stable(dfi_ctrlupd_req) && dfi_ctrlupd_req == $past(ts_dfi_ctrlupd_req, 2));

assert_dfi_phyupd_ack_check_2       : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2_r | dfi_init_start_int | dfi_phymstr_ack_int)
    !$stable(dfi_phyupd_ack_int)       |-> ##2 !$stable(dfi_phyupd_ack) && dfi_phyupd_ack == $past(dfi_phyupd_ack_int, 2));

assert_dfi_phymstr_ack_check_2      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2_r | dfi_init_start_int | dfi_phyupd_ack_int)
    !$stable(dfi_phymstr_ack_int)      |-> ##2 dfi_phymstr_ack == $past(dfi_phymstr_ack_int, 2));

assert_dfi_parity_in_check_2        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2 || ddr4_mode)
    !$stable(ddrc_dfi_parity_in_next)  |-> ##2 !$stable(dfi_parity_in) && dfi_parity_in == $past(ddrc_dfi_parity_in_next, 2));

assert_dfi_lp_ctrl_wakeup_check_2   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
    !$stable(dfi_lp_ctrl_wakeup_int)   |-> ##2 !$stable(dfi_lp_ctrl_wakeup_out) && dfi_lp_ctrl_wakeup_out == $past(dfi_lp_ctrl_wakeup_int, 2));

assert_dfi_lp_ctrl_req_check_2      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check2)
    !$stable(dfi_lp_ctrl_req_int)      |-> ##2 !$stable(dfi_lp_ctrl_req_out) && dfi_lp_ctrl_req_out == $past(dfi_lp_ctrl_req_int, 2));

//------------------------------------------------------------
// 1-cycle delay in DFI module
//------------------------------------------------------------

assert_dfi_addr_check_1   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
    !$stable(align_phy_addr) |-> ##1 !$stable(dfi_address) && dfi_address == $past(align_phy_addr));

assert_dfi_bank_check_1   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1 || lpddr4)
    !$stable(align_phy_ba)   |-> ##1 !$stable(dfi_bank) && dfi_bank == $past(align_phy_ba));

assert_dfi_cas_n_check_1  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1 || lpddr4)
    !$stable(align_phy_casn) |-> ##1 !$stable(dfi_cas_n) && dfi_cas_n == $past(align_phy_casn));

assert_dfi_ras_n_check_1  : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1 || lpddr4)
    !$stable(align_phy_rasn) |-> ##1 !$stable(dfi_ras_n) && dfi_ras_n == $past(align_phy_rasn));

assert_dfi_we_n_check_1   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1 || lpddr4)
    !$stable(align_phy_wen)  |-> ##1 !$stable(dfi_we_n) && dfi_we_n == $past(align_phy_wen));

generate
   genvar i1;
   if (SHARED_AC==1 && CHANNEL_NUM==0) begin
       for (i1 = 0; i1 < NUM_RANKS; i1=i1+1) begin

            assert_dfi_cke_check_1     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
                !$stable({ddrc_phy_cke[i1+NUM_RANKS], ddrc_phy_cke[i1]}) |->
                ##1 {dfi_cke[i1+NUM_RANKS], dfi_cke[i1]} == (
                        (({$past(ddrc_phy_cke[i1+NUM_RANKS], 1), $past(ddrc_phy_cke[i1], 1)} == 2'b01) ? 2'b00 :
                         ({$past(ddrc_phy_cke[i1+NUM_RANKS], 1), $past(ddrc_phy_cke[i1], 1)} == 2'b10) ? 2'b11 :
                                                            {$past(ddrc_phy_cke[i1+NUM_RANKS], 1), $past(ddrc_phy_cke[i1], 1)})));

            assert_dfi_cs_check_1      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
                !$stable({ddrc_phy_csn_i[i1], ddrc_phy_csn_i[i1+NUM_RANKS]}) |->
                ##1 !$stable({dfi_cs[i1+NUM_RANKS], dfi_cs[i1]}) &&
                    {dfi_cs[i1+NUM_RANKS], dfi_cs[i1]} == (
                                                            {$past(ddrc_phy_csn_i[i1]), $past(ddrc_phy_csn_i[i1+NUM_RANKS])}));

       end
   end else begin
   assert_dfi_cke_check_1   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
        !$stable(ddrc_phy_cke)      |-> ##1 !$stable(dfi_cke) && dfi_cke == $past(ddrc_phy_cke));

   assert_dfi_cs_check_1   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
        !$stable(ddrc_phy_csn_i)    |-> ##1 !$stable(dfi_cs) && dfi_cs == $past(ddrc_phy_csn_i));
   end
endgenerate

assert_dfi_odt_check_1          : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
    !$stable(ddrc_phy_odt)          |-> ##1 !$stable(dfi_odt) && dfi_odt == $past(ddrc_phy_odt));



assert_dfi_dram_clk_disable_check_1 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
    !$stable(ddrc_phy_stop_clk)     |-> ##1 !$stable(dfi_dram_clk_disable) && dfi_dram_clk_disable == {NUM_DRAM_CLKS{$past(ddrc_phy_stop_clk)}});

assert_dfi_ctrlupd_req_check_1      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1_r)
    !$stable(ts_dfi_ctrlupd_req)    |-> ##1 !$stable(dfi_ctrlupd_req) && dfi_ctrlupd_req == $past(ts_dfi_ctrlupd_req));

assert_dfi_phyupd_ack_check_1       : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1_r | dfi_init_start_int | dfi_phymstr_ack_int)
    !$stable(dfi_phyupd_ack_int)    |-> ##1 !$stable(dfi_phyupd_ack) && dfi_phyupd_ack == $past(dfi_phyupd_ack_int));

assert_dfi_phymstr_ack_check_1      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1_r | dfi_init_start_int | dfi_phyupd_ack_int)
    !$stable(dfi_phymstr_ack_int)   |-> ##1 dfi_phymstr_ack == $past(dfi_phymstr_ack_int));

assert_dfi_parity_in_check_1        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1 || ddr4_mode)
    !$stable(ddrc_dfi_parity_in_next)  |-> ##1 !$stable(dfi_parity_in) && dfi_parity_in == $past(ddrc_dfi_parity_in_next));

assert_dfi_lp_ctrl_wakeup_check_1   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
    !$stable(dfi_lp_ctrl_wakeup_int)   |-> ##1 !$stable(dfi_lp_ctrl_wakeup_out) && dfi_lp_ctrl_wakeup_out == $past(dfi_lp_ctrl_wakeup_int));

assert_dfi_lp_ctrl_req_check_1      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check1)
    !$stable(dfi_lp_ctrl_req_int)   |-> ##1 !$stable(dfi_lp_ctrl_req_out) && dfi_lp_ctrl_req_out == $past(dfi_lp_ctrl_req_int));


//------------------------------------------------------------
// 0-cycle delay in DFI module
//------------------------------------------------------------

assert_dfi_addr_check_0     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
    !$stable(align_phy_addr) |->     dfi_address == align_phy_addr);

assert_dfi_bank_check_0     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0 || lpddr4)
    !$stable(align_phy_ba)   |->     dfi_bank == align_phy_ba);

assert_dfi_cas_n_check_0    : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0 || lpddr4)
    !$stable(align_phy_casn) |->     dfi_cas_n == align_phy_casn);

assert_dfi_ras_n_check_0    : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0 || lpddr4)
    !$stable(align_phy_rasn) |->     dfi_ras_n == align_phy_rasn);

assert_dfi_we_n_check_0     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0 || lpddr4)
    !$stable(align_phy_wen)  |->     dfi_we_n == align_phy_wen);

generate
   genvar i0;
   if (SHARED_AC==1 && CHANNEL_NUM==0) begin
       for (i0 = 0; i0 < NUM_RANKS; i0=i0+1) begin

            assert_dfi_cke_check_0     : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
                !$stable({ddrc_phy_cke[i0+NUM_RANKS], ddrc_phy_cke[i0]}) |->
                {dfi_cke[i0+NUM_RANKS], dfi_cke[i0]} == (
                        (({ddrc_phy_cke[i0+NUM_RANKS], ddrc_phy_cke[i0]} == 2'b01) ? 2'b00 :
                         ({ddrc_phy_cke[i0+NUM_RANKS], ddrc_phy_cke[i0]} == 2'b10) ? 2'b11 :
                                                            {ddrc_phy_cke[i0+NUM_RANKS], ddrc_phy_cke[i0]})));

            assert_dfi_cs_check_0      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
                !$stable({ddrc_phy_csn_i[i0], ddrc_phy_csn_i[i0+NUM_RANKS]}) |->
                {dfi_cs[i0+NUM_RANKS], dfi_cs[i0]} == (
                                                            {ddrc_phy_csn_i[i0], ddrc_phy_csn_i[i0+NUM_RANKS]}));

       end
   end else begin
   assert_dfi_cke_check_0   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
        !$stable(ddrc_phy_cke)      |->     dfi_cke == ddrc_phy_cke);

   assert_dfi_cs_check_0    : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
        !$stable(ddrc_phy_csn_i)    |->     dfi_cs == ddrc_phy_csn_i);
   end
endgenerate

assert_dfi_odt_check_0          : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
    !$stable(ddrc_phy_odt)          |->     dfi_odt == ddrc_phy_odt);




assert_dfi_dram_clk_disable_check_0 : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
    !$stable(ddrc_phy_stop_clk)        |->     dfi_dram_clk_disable == {NUM_DRAM_CLKS{ddrc_phy_stop_clk}});

assert_dfi_ctrlupd_req_check_0      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0_r)
    !$stable(ts_dfi_ctrlupd_req)       |->     dfi_ctrlupd_req == ts_dfi_ctrlupd_req);

assert_dfi_phyupd_ack_check_0       : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0_r | dfi_init_start_int | dfi_phymstr_ack_int)
    !$stable(dfi_phyupd_ack_int)       |->     dfi_phyupd_ack == dfi_phyupd_ack_int);

assert_dfi_phymstr_ack_check_0      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0_r | dfi_init_start_int | dfi_phyupd_ack_int)
    !$stable(dfi_phymstr_ack_int)      |->     dfi_phymstr_ack == dfi_phymstr_ack_int);

assert_dfi_parity_in_check_0        : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0 || ddr4_mode)
    !$stable(ddrc_dfi_parity_in_next)  |->     dfi_parity_in == ddrc_dfi_parity_in_next);

assert_dfi_lp_ctrl_wakeup_check_0   : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
    !$stable(dfi_lp_ctrl_wakeup_int)   |->     dfi_lp_ctrl_wakeup_out == dfi_lp_ctrl_wakeup_int);

assert_dfi_lp_ctrl_req_check_0      : assert property (@(posedge core_ddrc_core_clk) disable iff (disable_check0)
    !$stable(dfi_lp_ctrl_req_int)      |->     dfi_lp_ctrl_req_out == dfi_lp_ctrl_req_int);




`endif // VCS

`endif // SNPS_ASSERT_ON
`endif // SYNTHESIS


endmodule //dfi_ctrl.v
