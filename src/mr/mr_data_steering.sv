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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/mr/mr_data_steering.sv#1 $
// -------------------------------------------------------------------------
// Description:
//
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module mr_data_steering 
import DWC_ddrctl_reg_pkg::*;
(
        co_yy_clk, 
        core_ddrc_rstn,
        ddrc_cg_en,
        dh_mr_frequency_ratio,
        dh_mr_data_bus_width,
        me_mr_rdata,

        oc_parity_en,
        oc_parity_type,
        
        ocecc_en,

        wr_ecc_vld,
        wdata_par_err,
        wdata_par_err_vec,

        reg_ddrc_phy_dbi_mode,
        reg_ddrc_wr_dbi_en,
        reg_ddrc_dm_en,
        reg_ddrc_lpddr4,
        reg_ddrc_lpddr5,
        reg_ddrc_lp_optimized_write,
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
        me_mr_rdatamask,
        me_mr_rdatapar,
        mr_ph_wdatamask,
        mr_ph_wdatamask_retry,
        ram_data_vld,
        ram_data_vld_upper_lane,
//`ifdef MEMC_FREQ_RATIO_4
        wr_ph,
//`else  // MEMC_FREQ_RATIO_4
//        mr_t_wrdata_add_sdr,
//`endif // MEMC_FREQ_RATIO_4
        mr_ph_wdata, 
        dfi_wrdata_link_ecc,
        ddrc_reg_wr_linkecc_poison_complete,
        mr_ph_wdata_retry, 
        mr_ph_wdatavld_early,
        mr_ph_wdatavld_early_retry
      ,mr_ph_dbg_dfi_ecc_corrupt0
      ,mr_ph_dbg_dfi_ecc_corrupt1
      ,mr_ph_dbg_dfi_ecc_wdata_kbd 
    );

//---------------------------- PARAMETERS --------------------------------------
parameter  CORE_DATA_WIDTH     = `MEMC_DFI_DATA_WIDTH;      // width of data to the PHY
parameter  CORE_MASK_WIDTH     = `MEMC_DFI_DATA_WIDTH/8;    // width of data mask bits to the PHY
parameter  CORE_DCERRBITS      = `MEMC_DCERRBITS;


parameter  PHY_DATA_WIDTH          = `MEMC_DFI_TOTAL_DATA_WIDTH;    // width of data to the PHY (should be 2x the DDR DQ width)
parameter  PHY_MASK_WIDTH          = PHY_DATA_WIDTH/8;    // width of data mask bits to the PHY
                  // (note that if both ECC and DM are supported in a system:
                  // 1) Only one or the other allowed at any given time
                  // 2) ECC byte enable need not be maskable           )

parameter  OCPAR_EN        = 0; // enables on-chip parity
parameter  OCECC_EN        = 0; // enables on-chip ECC

parameter  ECC_POISON_REG_WIDTH= `ECC_POISON_REG_WIDTH;


parameter DRAM_BYTE_NUM        = `MEMC_DRAM_TOTAL_BYTE_NUM;
parameter DFI_KBD_WIDTH        = `DDRCTL_DFI_KBD_WIDTH;

// some math calculations based on the above

localparam  HALF_CORE_DATA_WIDTH       = CORE_DATA_WIDTH/2;
localparam  QUARTER_CORE_DATA_WIDTH    = CORE_DATA_WIDTH/4;
localparam  EIGHTH_CORE_DATA_WIDTH     = CORE_DATA_WIDTH/8;
localparam  SIXTEENTH_CORE_DATA_WIDTH  = CORE_DATA_WIDTH/16;
localparam  THREE_SIXTEENTH_CORE_DATA_WIDTH  = (CORE_DATA_WIDTH*3)/16;

localparam  HALF_CORE_MASK_WIDTH       = CORE_MASK_WIDTH/2;
localparam  QUARTER_CORE_MASK_WIDTH    = CORE_MASK_WIDTH/4;
localparam  EIGHTH_CORE_MASK_WIDTH     = CORE_MASK_WIDTH/8;
localparam  SIXTEENTH_CORE_MASK_WIDTH  = CORE_MASK_WIDTH/16;
localparam  THREE_SIXTEENTH_CORE_MASK_WIDTH  = (CORE_MASK_WIDTH*3)/16;



//------------------------ INPUTS AND OUTPUTS ----------------------------------

input            co_yy_clk;             // clock
input            core_ddrc_rstn;        // asynchronous negative-edge reset
input  [CORE_DATA_WIDTH-1:0]        me_mr_rdata;    // write data read from write data RAM
                                                    //  valid only when ram_data_vld=1
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate block and/or different `ifdefs and decided to keep current coding style
input                               dh_mr_frequency_ratio;  // 0 - 1:2 mode, 1 - 1:4 mode
input  [1:0]                        dh_mr_data_bus_width;
input                               oc_parity_en;   // enables on-chip parity
input                               ddrc_cg_en;
input                               oc_parity_type; // selects parity type. 0 even, 1 odd
input                               ocecc_en;       // enables on-chip ECC
input                               wr_ecc_vld;
//spyglass enable_block W240
output                              wdata_par_err;
output [CORE_MASK_WIDTH-1:0]        wdata_par_err_vec;


input                               reg_ddrc_phy_dbi_mode;  // DBI implemented in DDRC or PHY
input                               reg_ddrc_wr_dbi_en;     // write DBI enable
input                               reg_ddrc_dm_en;
input                               reg_ddrc_lpddr4;        // select LPDDR4 SDRAM
input                               reg_ddrc_lpddr5;        // select LPDDR5 SDRAM
input                               reg_ddrc_lp_optimized_write; // To save power consumption LPDDR4 write DQ is set to 8'hF8 if this is set to 1 (masked + DBI)
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
input                               ram_data_vld;             // me_mr_data is valid
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style
input                               ram_data_vld_upper_lane;  // 0 - lower lane, 1 - upper lane data valid for prog freq ratio 1:1 mode
//spyglass enable_block W240
//`ifdef MEMC_FREQ_RATIO_4
input   [1:0]                       wr_ph;
//`else  // MEMC_FREQ_RATIO_4
//input [1:0]                         mr_t_wrdata_add_sdr;
//`endif // MEMC_FREQ_RATIO_4

output  [PHY_DATA_WIDTH-1:0]        mr_ph_wdata;    // write data output to phy
output  [PHY_DATA_WIDTH-1:0]        mr_ph_wdata_retry;    // write data output to retry

input  [CORE_MASK_WIDTH-1:0]        me_mr_rdatamask;  // write data mask output to phy
output  [PHY_MASK_WIDTH-1:0]        mr_ph_wdatamask;  // write data output to phy
output  [PHY_MASK_WIDTH-1:0]        mr_ph_wdatamask_retry;  // write data output to retry

input  [CORE_MASK_WIDTH-1:0]        me_mr_rdatapar;

output                              mr_ph_wdatavld_early;  // write data valid to phy 
output                              mr_ph_wdatavld_early_retry;  // write data valid to retry

output [CORE_MASK_WIDTH-1:0]        dfi_wrdata_link_ecc;
output                              ddrc_reg_wr_linkecc_poison_complete;



output [CORE_DCERRBITS-1:0] mr_ph_dbg_dfi_ecc_corrupt0;
output [CORE_DCERRBITS-1:0] mr_ph_dbg_dfi_ecc_corrupt1;
output [DFI_KBD_WIDTH-1:0]  mr_ph_dbg_dfi_ecc_wdata_kbd;
//----------------------------  WIRES AND REGISTERS ----------------------------

wire                           i_ram_data_vld;
reg  [PHY_MASK_WIDTH-1:0]      r_wdatamask;

reg  [PHY_DATA_WIDTH-1:0]      r_wdata;
reg                            r_wdatavld;
wire                           mr_ph_wdatavld_early_w; // write data valid to phy 
//`ifdef MEMC_FREQ_RATIO_4
wire                           mr_ph_wdatavld_w;
reg                            mr_ph_wdatavld_r;
//`endif // MEMC_FREQ_RATIO_4


wire  [PHY_MASK_WIDTH-1:0]      wpar_out;

//wire  [PHY_MASK_WIDTH-1:0]      wmask_out;       // write data mask output to phy
wire  [PHY_MASK_WIDTH-1:0]      wmask_out_noecc;
wire  [PHY_MASK_WIDTH-1:0]      wmask_dbi;       // write data mask output to phy for DM or DBI
reg   [PHY_MASK_WIDTH-1:0]      r_wmask_dbi;       // write data mask output to phy for DM or DBI
wire  [PHY_MASK_WIDTH-1:0]      wmask_dm_dbi;    // write data mask output to phy for DM & DBI


wire  [PHY_MASK_WIDTH-1:0]      wmask_out_for_full_bus;  // write data mask output to phy for full bus width

wire  [PHY_MASK_WIDTH-1:0]      wpar_out_for_full_bus;  // write data parity output for full bus width

wire  [PHY_MASK_WIDTH-1:0]      wdatamask;          // write data mask for DM or DBI
//wire  [PHY_DATA_WIDTH-1:0]      wdata_out;          // DM write data output to phy
wire  [PHY_DATA_WIDTH-1:0]      wdata_out_noecc;
wire  [PHY_DATA_WIDTH-1:0]      wdata_out_dbi;      // write data output to phy
reg   [PHY_DATA_WIDTH-1:0]      r_wdata_out_dbi;      // write data output to phy

wire                            write_dbi_enable;       // write DBI enable
wire    [4*PHY_MASK_WIDTH-1:0]  wdata_out_eq1_bit_num;  // write data bit number with been equal 1
wire    [PHY_MASK_WIDTH-1:0]    wdata_dbi_n;            // wirte data DBI output to phy (low active)
wire    [PHY_DATA_WIDTH-1:0]    wdata_dbi;              // write data output for DBI
wire    [PHY_DATA_WIDTH-1:0]    wdata_dm_dbi;           // write data output to phy for DM & DBI

wire  [PHY_DATA_WIDTH-1:0]      wdata_out_for_full_bus;  // write data output to phy for full bus width

wire  [CORE_DATA_WIDTH/4-1:0]      first_quarter_wdata;
wire  [CORE_DATA_WIDTH/4-1:0]      second_quarter_wdata;
wire  [CORE_DATA_WIDTH/4-1:0]      third_quarter_wdata;
wire  [CORE_DATA_WIDTH/4-1:0]      fourth_quarter_wdata;

wire  [CORE_MASK_WIDTH/4 - 1:0]    first_quarter_wmask;
wire  [CORE_MASK_WIDTH/4 - 1:0]    second_quarter_wmask;
wire  [CORE_MASK_WIDTH/4 - 1:0]    third_quarter_wmask;
wire  [CORE_MASK_WIDTH/4 - 1:0]    fourth_quarter_wmask;

wire  [CORE_MASK_WIDTH/4 - 1:0]    first_quarter_wpar;
wire  [CORE_MASK_WIDTH/4 - 1:0]    second_quarter_wpar;
wire  [CORE_MASK_WIDTH/4 - 1:0]    third_quarter_wpar;
wire  [CORE_MASK_WIDTH/4 - 1:0]    fourth_quarter_wpar;



wire    [PHY_DATA_WIDTH-1:0]    i_mr_ph_wdata; // write data output to phy
wire    [PHY_DATA_WIDTH-1:0]    wdata_poison; // write data output to phy
wire    [PHY_DATA_WIDTH-1:0]    i_mr_ph_wdata_no_cerr; // pre-corrupted data output
wire    [PHY_MASK_WIDTH-1:0]    i_mr_ph_wdatamask;  // write data output to phy
wire    [PHY_MASK_WIDTH-1:0]    wdatamask_poison;  // write data output to phy after poison module
wire                            mr_ph_wdatavld_early_no_pda;   // write data valid (internal/ without PDA)
reg                             mr_ph_wdatavld_early_no_pda_r;   // write data valid (internal/ without PDA)

wire                            ocpar_blank_fill;



wire  [PHY_DATA_WIDTH-1:0]        mr_ph_wdata_w;    // write data output to phy
wire  [PHY_MASK_WIDTH-1:0]        mr_ph_wdatamask_w;  // write data output to phy

wire                                reg_ddrc_wr_crc_enable = 1'b0;

reg [1:0]      wr_ph_r;
//`ifdef MEMC_FREQ_RATIO_4
//`endif // MEMC_FREQ_RATIO_4
wire           lpddr_mode;
assign lpddr_mode = reg_ddrc_lpddr4 || reg_ddrc_lpddr5;

wire [PHY_DATA_WIDTH-1:0]   sel_mr_ph_wdata;
wire [PHY_MASK_WIDTH-1:0]   sel_mr_ph_wdatamask;
wire                        sel_mr_ph_wdatavld_early;
wire                        pre_mr_ph_wdatavld_early;
wire [1:0]                  sel_wr_ph;
//`ifdef MEMC_FREQ_RATIO_4
wire                        sel_mr_ph_wdatavld;
//`endif // MEMC_FREQ_RATIO_4



//------------------------- COMBINATORIAL LOGIC --------------------------------

assign i_ram_data_vld = 
                     //`ifdef MEMC_FREQ_RATIO_4
                     //`endif // MEMC_FREQ_RATIO_4
                        ram_data_vld;

  // Calculate each quarter of the write data
  assign first_quarter_wdata  = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? me_mr_rdata[3*CORE_DATA_WIDTH/4-1: CORE_DATA_WIDTH/2] : me_mr_rdata[CORE_DATA_WIDTH/4-1:0];
  assign second_quarter_wdata = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? me_mr_rdata[CORE_DATA_WIDTH-1    : 3*CORE_DATA_WIDTH/4] : me_mr_rdata[CORE_DATA_WIDTH/2-1  : CORE_DATA_WIDTH/4];
  assign third_quarter_wdata  = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? {QUARTER_CORE_DATA_WIDTH{1'b0}} : me_mr_rdata[3*CORE_DATA_WIDTH/4-1: CORE_DATA_WIDTH/2];
  assign fourth_quarter_wdata = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? {QUARTER_CORE_DATA_WIDTH{1'b0}} : me_mr_rdata[CORE_DATA_WIDTH-1    : 3*CORE_DATA_WIDTH/4];
  
  // Calculate each quarter of the write data mask
  assign first_quarter_wmask  = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? me_mr_rdatamask[QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH-1: HALF_CORE_MASK_WIDTH]:  me_mr_rdatamask[QUARTER_CORE_MASK_WIDTH - 1:0];
  assign second_quarter_wmask = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? me_mr_rdatamask[CORE_MASK_WIDTH-1: QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH] :  me_mr_rdatamask[HALF_CORE_MASK_WIDTH-1: QUARTER_CORE_MASK_WIDTH];
  assign third_quarter_wmask  = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? {QUARTER_CORE_MASK_WIDTH{1'b0}} :  me_mr_rdatamask[QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH-1: HALF_CORE_MASK_WIDTH];
  assign fourth_quarter_wmask = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? {QUARTER_CORE_MASK_WIDTH{1'b0}} :  me_mr_rdatamask[CORE_MASK_WIDTH-1: QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH];
  
  // Calculate each quarter of the write data parity
  assign first_quarter_wpar   = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? me_mr_rdatapar[QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH-1: HALF_CORE_MASK_WIDTH]:  me_mr_rdatapar[QUARTER_CORE_MASK_WIDTH - 1:0];
  assign second_quarter_wpar  = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? me_mr_rdatapar[CORE_MASK_WIDTH-1: QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH] :  me_mr_rdatapar[HALF_CORE_MASK_WIDTH-1: QUARTER_CORE_MASK_WIDTH];
  assign third_quarter_wpar   = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? {QUARTER_CORE_MASK_WIDTH{1'b0}} :  me_mr_rdatapar[QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH-1: HALF_CORE_MASK_WIDTH];
  assign fourth_quarter_wpar  = (!dh_mr_frequency_ratio & ram_data_vld_upper_lane) ? {QUARTER_CORE_MASK_WIDTH{1'b0}} :  me_mr_rdatapar[CORE_MASK_WIDTH-1: QUARTER_CORE_MASK_WIDTH+HALF_CORE_MASK_WIDTH];

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used under different `ifdefs. Decided to keep current implementation.
assign ocpar_blank_fill = oc_parity_type; // need to fill the unused bytes with the correct bit to avoid false errors in the parity check
//spyglass enable_block W528



//--------------------------------------- BEGIN FULL BUS WIDTH DATA AND MASK FOR HALF SPEED CONTROLLER  --------------------------//


assign wdata_out_for_full_bus = {
                                     fourth_quarter_wdata[2*QUARTER_CORE_DATA_WIDTH/2-1:1*QUARTER_CORE_DATA_WIDTH/2],
                                     fourth_quarter_wdata[1*QUARTER_CORE_DATA_WIDTH/2-1:0*QUARTER_CORE_DATA_WIDTH/2],
                                     third_quarter_wdata[2*QUARTER_CORE_DATA_WIDTH/2-1:1*QUARTER_CORE_DATA_WIDTH/2],
                                     third_quarter_wdata[1*QUARTER_CORE_DATA_WIDTH/2-1:0*QUARTER_CORE_DATA_WIDTH/2],
                                     second_quarter_wdata[2*QUARTER_CORE_DATA_WIDTH/2-1:1*QUARTER_CORE_DATA_WIDTH/2],
                                     second_quarter_wdata[1*QUARTER_CORE_DATA_WIDTH/2-1:0*QUARTER_CORE_DATA_WIDTH/2],
                                     first_quarter_wdata[2*QUARTER_CORE_DATA_WIDTH/2-1:1*QUARTER_CORE_DATA_WIDTH/2],
                                     first_quarter_wdata[1*QUARTER_CORE_DATA_WIDTH/2-1:0*QUARTER_CORE_DATA_WIDTH/2]};

assign wmask_out_for_full_bus = {
                                     fourth_quarter_wmask[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     fourth_quarter_wmask[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2],
                                     third_quarter_wmask[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     third_quarter_wmask[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2],
                                     second_quarter_wmask[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     second_quarter_wmask[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2],
                                     first_quarter_wmask[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     first_quarter_wmask[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2]};

assign wpar_out_for_full_bus = {
                                     fourth_quarter_wpar[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     fourth_quarter_wpar[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2],
                                     third_quarter_wpar[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     third_quarter_wpar[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2],
                                     second_quarter_wpar[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     second_quarter_wpar[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2],
                                     first_quarter_wpar[2*QUARTER_CORE_MASK_WIDTH/2-1:1*QUARTER_CORE_MASK_WIDTH/2],
                                     first_quarter_wpar[1*QUARTER_CORE_MASK_WIDTH/2-1:0*QUARTER_CORE_MASK_WIDTH/2]};

//--------------------------------------- END FULL BUS WIDTH DATA AND MASK FOR HALF SPEED CONTROLLER --------------------------//




assign wdata_poison       = wdata_out_noecc;
assign wdatamask_poison   = wmask_out_noecc;


// Mux that selects between full, half and quarter bus width data
assign   wdata_out_noecc[(PHY_DATA_WIDTH/2)-1:0]   = wdata_out_for_full_bus[(PHY_DATA_WIDTH/2)-1:0]    ;

assign   wdata_out_noecc[PHY_DATA_WIDTH-1:(PHY_DATA_WIDTH/2)]   = 
                           (!dh_mr_frequency_ratio) ? {(PHY_DATA_WIDTH/2){1'b0}} :
                            wdata_out_for_full_bus[PHY_DATA_WIDTH-1:(PHY_DATA_WIDTH/2)]    ;

//assign  wdata_out  =   `ifdef MEMC_SIDEBAND_ECC
//                           `ifdef UMCTL2_ECC_TEST_MODE_EN
//                            dh_mr_test_mode ? wdata_test_mode :
//                           `endif //UMCTL2_ECC_TEST_MODE_EN
//                            !no_ecc_mode ? wdata_w_ecc :
//                       `endif
//                            wdata_out_noecc;

// Mux that selects between full, half and quarter bus width mask
assign   wmask_out_noecc[(PHY_MASK_WIDTH/2)-1:0]   = 
                            wmask_out_for_full_bus[(PHY_MASK_WIDTH/2)-1:0]  ;

assign   wmask_out_noecc[PHY_MASK_WIDTH-1:(PHY_MASK_WIDTH/2)]   =  
                            (!dh_mr_frequency_ratio) ? {(PHY_MASK_WIDTH/2){1'b0}} :
                            wmask_out_for_full_bus[PHY_MASK_WIDTH-1:(PHY_MASK_WIDTH/2)]  ;

//assign  wmask_out  =   `ifdef MEMC_SIDEBAND_ECC
//                           `ifdef UMCTL2_ECC_TEST_MODE_EN
//                            dh_mr_test_mode ? wmask_test_mode :
//                           `endif //UMCTL2_ECC_TEST_MODE_EN
//                            !no_ecc_mode ? wmask_w_ecc :
//                        `endif
//                            wmask_out_noecc;

//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ: Used in generate block

// Mux that selects between full, half and quarter bus width parity
assign   wpar_out[(PHY_MASK_WIDTH/2)-1:0] =   
                     wpar_out_for_full_bus[(PHY_MASK_WIDTH/2)-1:0]  ;

assign   wpar_out[PHY_MASK_WIDTH-1:(PHY_MASK_WIDTH/2)] =  
                     (!dh_mr_frequency_ratio) ? {(PHY_MASK_WIDTH/2){1'b0}} :   
                     wpar_out_for_full_bus[PHY_MASK_WIDTH-1:(PHY_MASK_WIDTH/2)]  ;
//spyglass enable_block W528

//----------------------------------- FLOPS ------------------------------------

// resetable flops
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    r_wdatavld                 <= 1'b0;
  end
  else if(ddrc_cg_en) begin
    r_wdatavld                 <= mr_ph_wdatavld_early_w;
  end
// If data needs to be phase shift or crc is enabled, data valid signal need to be expanded 1 cycle.
//`ifdef MEMC_FREQ_RATIO_4
assign pre_mr_ph_wdatavld_early = mr_ph_wdatavld_early_w | (((|wr_ph_r) | reg_ddrc_wr_crc_enable) & r_wdatavld); 
assign mr_ph_wdatavld_w     =
                             (mr_ph_wdatavld_early_w | ((reg_ddrc_wr_crc_enable) & r_wdatavld));

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if (~core_ddrc_rstn) begin
    mr_ph_wdatavld_r <= 1'b0;
  end
  else if(ddrc_cg_en) begin
    mr_ph_wdatavld_r <= mr_ph_wdatavld_w;
  end
end

//`else  // MEMC_FREQ_RATIO_4
//assign pre_mr_ph_wdatavld_early = mr_ph_wdatavld_early_w | (((|mr_t_wrdata_add_sdr) | reg_ddrc_wr_crc_enable) & r_wdatavld); 
//`endif // MEMC_FREQ_RATIO_4
assign mr_ph_wdatavld_early = sel_mr_ph_wdatavld_early;



// non-resetable flops
always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
  if (~core_ddrc_rstn) begin
    r_wdata         <= {PHY_DATA_WIDTH{1'b0}};
    r_wdatamask     <= {PHY_MASK_WIDTH{1'b1}};
    r_wmask_dbi     <= {PHY_MASK_WIDTH{1'b1}};
    r_wdata_out_dbi <= {PHY_DATA_WIDTH{1'b0}};
  end
  else if(ddrc_cg_en) begin
    r_wdata       <= wdata_poison[PHY_DATA_WIDTH-1:0];
    r_wdatamask   <= wdatamask_poison[PHY_MASK_WIDTH-1:0]; 
    r_wmask_dbi     <= wmask_dbi;
    r_wdata_out_dbi <= wdata_out_dbi[PHY_DATA_WIDTH-1:0];
end // always: non-resetable flops

//spyglass disable_block SelfDeterminedExpr-ML
//SMD: Self determined expression '((8 * GEN_BYTES_DBI) + 0)' found in module 'mr_data_steering'
//SJ: This coding style is acceptable and there is no plan to change it.
genvar GEN_BYTES_DBI;
generate
  for (GEN_BYTES_DBI=0; GEN_BYTES_DBI<PHY_MASK_WIDTH; GEN_BYTES_DBI=GEN_BYTES_DBI+1) begin : gen_dbi_bytes
    assign wdata_out_eq1_bit_num[4*GEN_BYTES_DBI+3:4*GEN_BYTES_DBI] =
                {3'b0, r_wdata[8*GEN_BYTES_DBI+0]} + {3'b0, r_wdata[8*GEN_BYTES_DBI+1]} +
                {3'b0, r_wdata[8*GEN_BYTES_DBI+2]} + {3'b0, r_wdata[8*GEN_BYTES_DBI+3]} +
                {3'b0, r_wdata[8*GEN_BYTES_DBI+4]} + {3'b0, r_wdata[8*GEN_BYTES_DBI+5]} +
                {3'b0, r_wdata[8*GEN_BYTES_DBI+6]} + {3'b0, r_wdata[8*GEN_BYTES_DBI+7]};

    assign wdata_dbi_n[GEN_BYTES_DBI] = mr_ph_wdatavld_early_no_pda_r &
                                        lpddr_mode    ? (wdata_out_eq1_bit_num[4*GEN_BYTES_DBI+:4] >= 4'h5) :
                                                        1'b0;

    assign wdata_dbi[8*GEN_BYTES_DBI+:8] =
                            (lpddr_mode    &&  wdata_dbi_n[GEN_BYTES_DBI]) ? ~r_wdata[8*GEN_BYTES_DBI+:8] :
                                                                                r_wdata[8*GEN_BYTES_DBI+:8];

    assign wmask_dm_dbi[GEN_BYTES_DBI] = 
                            (lpddr_mode    && !r_wdatamask[GEN_BYTES_DBI]) ? 1'b0 :
                                                                             wdata_dbi_n[GEN_BYTES_DBI];

    assign wdata_dm_dbi[8*GEN_BYTES_DBI+:8] =
                            (lpddr_mode    && !r_wdatamask[GEN_BYTES_DBI]) ? ((reg_ddrc_lp_optimized_write) ? `UMCTL2_LPDDR4_DQ_WHEN_MASKED : 8'hff ) :
                                                                             wdata_dbi[8*GEN_BYTES_DBI+:8];

  end // gen_dbi_bytes
endgenerate
//spyglass enable_block SelfDeterminedExpr-ML

assign write_dbi_enable         = ~reg_ddrc_phy_dbi_mode & reg_ddrc_wr_dbi_en;
assign wmask_dbi                = (~mr_ph_wdatavld_early_no_pda_r)      ? r_wmask_dbi    :
                                  (write_dbi_enable && reg_ddrc_dm_en)  ? wmask_dm_dbi   :
                                  (write_dbi_enable)                    ? wdata_dbi_n    :
                                                                          ~r_wdatamask;


assign i_mr_ph_wdatamask        =
  //`ifdef MEMC_FREQ_RATIO_4
  //`endif // MEMC_FREQ_RATIO_4
                                  lpddr_mode ?
                                    ((reg_ddrc_dm_en || write_dbi_enable) ? wmask_dbi : {PHY_MASK_WIDTH{1'b0}}) :
                                    wmask_dbi;

assign wdatamask                = wmask_dbi & {PHY_MASK_WIDTH{~write_dbi_enable}};
assign wdata_out_dbi            = (~mr_ph_wdatavld_early_no_pda_r)      ? r_wdata_out_dbi :
                                  (write_dbi_enable && reg_ddrc_dm_en)  ? wdata_dm_dbi    :
                                  (write_dbi_enable)                    ? wdata_dbi       :
                                                                          r_wdata;
assign i_mr_ph_wdata            = i_mr_ph_wdata_no_cerr;

assign mr_ph_wdatavld_early_no_pda = i_ram_data_vld  ;


always@(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if(~core_ddrc_rstn) begin
    mr_ph_wdatavld_early_no_pda_r <= 1'b0;
  end
  else if(ddrc_cg_en) begin
    mr_ph_wdatavld_early_no_pda_r <= mr_ph_wdatavld_early_no_pda;
  end
end

//`ifdef MEMC_FREQ_RATIO_4
always@(posedge co_yy_clk or negedge core_ddrc_rstn) begin
  if(~core_ddrc_rstn) begin
    wr_ph_r <= 2'b00;
  end
  else if(ddrc_cg_en) begin
    wr_ph_r <= wr_ph;
  end
end
//`endif // MEMC_FREQ_RATIO_4

assign mr_ph_wdatavld_early_w = 
        mr_ph_wdatavld_early_no_pda;


assign mr_ph_wdatamask_w = i_mr_ph_wdatamask;

assign mr_ph_wdata_w = i_mr_ph_wdata;


//`ifdef MEMC_FREQ_RATIO_4
////`else  // MEMC_FREQ_RATIO_4
//  `ifdef MEMC_DDR5
//assign d5_crc_w = {(PHY_DATA_WIDTH/4/4){4'b0101}};
//  `endif // MEMC_DDR5
//`endif // MEMC_FREQ_RATIO_4


assign mr_ph_wdatamask_retry = mr_ph_wdatamask_w;
assign mr_ph_wdata_retry     = mr_ph_wdata_w;
assign mr_ph_wdatavld_early_retry = mr_ph_wdatavld_early_w;


// data phase shift logic
mr_data_phase_ctrl
 
normal_data_phase_ctrl (
    .core_ddrc_core_clk (co_yy_clk),
    .core_ddrc_rstn     (core_ddrc_rstn),
//`ifdef MEMC_FREQ_RATIO_4  
    .reg_ddrc_frequency_ratio (dh_mr_frequency_ratio),
    .wr_ph              (sel_wr_ph),
    .ram_data_vld       (sel_mr_ph_wdatavld),
//`else  // MEMC_FREQ_RATIO_4  
//  .data_latency       (mr_t_wrdata_add_sdr),
//`endif // MEMC_FREQ_RATIO_4
    .wdata              (sel_mr_ph_wdata),
    .wdata_mask         (sel_mr_ph_wdatamask),
    .wdata_next         (mr_ph_wdata),
    .wdata_mask_next    (mr_ph_wdatamask) 
                   );
  assign mr_ph_dbg_dfi_ecc_corrupt0  = {CORE_DCERRBITS{1'b0}};
  assign mr_ph_dbg_dfi_ecc_corrupt1  = {CORE_DCERRBITS{1'b0}};
  assign mr_ph_dbg_dfi_ecc_wdata_kbd = {DFI_KBD_WIDTH{1'b0}};

// Logic to prevent DQ toggling
// Note that wrdata_no_toggle is instantiated both here and in dfi.v
wrdata_no_toggle
   #(
    .PHY_DATA_WIDTH     (PHY_DATA_WIDTH),
    .PHY_MASK_WIDTH     (PHY_MASK_WIDTH) 
                    ) 
wrdata_no_toggle    (
    .core_ddrc_core_clk (co_yy_clk),
    .core_ddrc_rstn     (core_ddrc_rstn),
    .ddrc_cg_en         (ddrc_cg_en),
    .wrdata_in          (wdata_out_dbi),
    .wrdata_mask        (wdatamask),
    .wrdata_valid       (r_wdatavld),
    .wrdata_out         (i_mr_ph_wdata_no_cerr)
                    );

// on-chip parity section
generate
   if (OCPAR_EN==1 || OCECC_EN==1) begin: OC_PAR_OR_ECC_en
   
      wire ocpar_no_ecc_mode, ocpar_err;
      wire [CORE_MASK_WIDTH-1:0] ocpar_err_vec;
      
      assign ocpar_no_ecc_mode   = 1'b1;
     
      wire pcheck_data_valid;
      assign pcheck_data_valid = mr_ph_wdatavld_early_w;

      wire  [PHY_MASK_WIDTH-1:0]      wmask_oc;
      localparam CORE_MASK_TOTAL_WIDTH        = QUARTER_CORE_MASK_WIDTH/2;
      localparam HALF_CORE_MASK_VALID_WIDTH   = QUARTER_CORE_MASK_WIDTH/4;
      localparam HALF_CORE_MASK_INVALID_WIDTH = QUARTER_CORE_MASK_WIDTH/4;
      localparam QUARTER_CORE_MASK_VALID_WIDTH   = QUARTER_CORE_MASK_WIDTH/8;
      localparam QUARTER_CORE_MASK_INVALID_WIDTH = (3*QUARTER_CORE_MASK_WIDTH)/8;
      assign wmask_oc = 
                         // Quarter bus width mode
                         (dh_mr_data_bus_width == 2'b10) ? {{QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[7*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[6*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[5*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[4*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[3*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[2*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[1*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH],
                                                            {QUARTER_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[0*CORE_MASK_TOTAL_WIDTH +: QUARTER_CORE_MASK_VALID_WIDTH]} :
                         // Half bus width mode
                         (dh_mr_data_bus_width == 2'b01) ? {{HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[7*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[6*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[5*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[4*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[3*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[2*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[1*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH],
                                                            {HALF_CORE_MASK_INVALID_WIDTH{1'b0}},wmask_out_noecc[0*CORE_MASK_TOTAL_WIDTH +: HALF_CORE_MASK_VALID_WIDTH]} :
                         wmask_out_noecc;
      
      // parity check for data out
      ocpar_mr_unpack
      
      #(
         .ECC_EN           (`MEMC_ECC_SUPPORT),
         .INLINE_ECC       (`MEMC_INLINE_ECC_EN),
         .SIDEBAND_ECC     (`MEMC_SIDEBAND_ECC_EN),
         .CORE_DATA_WIDTH  (CORE_DATA_WIDTH),
         .CORE_MASK_WIDTH  (CORE_MASK_WIDTH),
         .PHY_DATA_WIDTH   (PHY_DATA_WIDTH),
         .PHY_MASK_WIDTH   (PHY_MASK_WIDTH),
         .CORE_DCERRBITS   (CORE_DCERRBITS))
      mr_data_par_check
      (
         // inputs
         .data_in             (wdata_out_noecc),
         .par_in              (wpar_out),
         .mask_in             (wmask_oc),
         .parity_en           (OCECC_EN==1 ? ocecc_en : oc_parity_en),
         .parity_type         (OCECC_EN==1 ? 1'b0 : oc_parity_type),
         .no_ecc              (ocpar_no_ecc_mode),
         .data_valid          (pcheck_data_valid),
         // outputs
        
         //spyglass disable_block W528
         //SMD: A signal or variable is set but never read
         //SJ: Used under different `ifdefs. Decided to keep the current implementation.
         .ecc_mask            (ocpar_ecc_corrupt),
         //spyglass enable_block W528
         .par_err_vec         (ocpar_err_vec),
         .par_err             (ocpar_err));

      // combine the ECC poisoning with the ocpar poisoning and RMW ECC corruption to avoid double flipping (this is why the ECC poisoning is done after the flops)

      assign wdata_par_err             = ocpar_err;
      assign wdata_par_err_vec         = ocpar_err_vec;

   end // OC_PAR_OR_ECC_en
   else begin: OC_PAR_OR_ECC_nen

      assign wdata_par_err             = 1'b0;
      assign wdata_par_err_vec         = {CORE_MASK_WIDTH{1'b0}};
   end
endgenerate


//------------------------------------------------------------
// No Link-ECC config: dfi_wrdata_xxxx signals are bypassed
//------------------------------------------------------------
assign sel_mr_ph_wdata = mr_ph_wdata_w;
assign sel_mr_ph_wdatamask = mr_ph_wdatamask_w;
assign sel_mr_ph_wdatavld_early = pre_mr_ph_wdatavld_early;
//`ifdef MEMC_FREQ_RATIO_4
assign sel_wr_ph = wr_ph_r;
assign sel_mr_ph_wdatavld = mr_ph_wdatavld_r;
//`endif // MEMC_FREQ_RATIO_4
assign dfi_wrdata_link_ecc = {CORE_MASK_WIDTH{1'b0}};
assign ddrc_reg_wr_linkecc_poison_complete = 1'b0;


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON


endmodule  // mr_data_steering: memory read engine data steering
