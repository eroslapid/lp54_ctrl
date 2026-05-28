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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/mr/mr_ram_rd_pipeline.sv#1 $
// -------------------------------------------------------------------------
// Description:
//                Memory Read Engine sub-unit: RAM read pipeline.  This
//                block tracks write requests and reads the associated data
//                from the write data RAM at the appropriate times.
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module mr_ram_rd_pipeline 
import DWC_ddrctl_reg_pkg::*;
#( 
   parameter       WRCAM_ADDR_WIDTH      = 4   // bits to address into CAM
  ,parameter       WRCAM_ADDR_WIDTH_IE   = 4   // bits to address into CAM
  ,parameter       WRDATA_RAM_ADDR_WIDTH = WRCAM_ADDR_WIDTH + 1 // data width to RAM
  ,parameter       PHY_DATA_WIDTH        = `MEMC_DFI_TOTAL_DATA_WIDTH   // width of data to the PHY (should be 2x the DDR DQ width)
  ,parameter       DRAM_DATA_WIDTH       = `MEMC_DRAM_TOTAL_DATA_WIDTH // width of DRAM(including ECC)
  ,parameter       MEMC_BURST_LENGTH     = `MEMC_BURST_LENGTH
  ,parameter       WRDATA_CYCLES         = 2
  ,parameter       CMD_LEN_BITS          = 1
  ,parameter       NUM_RANKS             = `MEMC_NUM_RANKS
  ,parameter       WDATARAM_RD_LATENCY   = `DDRCTL_WDATARAM_RD_LATENCY
  ,parameter       PARTIAL_WR_BITS       = `UMCTL2_PARTIAL_WR_BITS
  ,parameter       PARTIAL_WR_BITS_LOG2  = `log2(`UMCTL2_PARTIAL_WR_BITS)
  ,parameter       PW_WORD_CNT_WD_MAX    = 2
  ,parameter       CORE_DATA_WIDTH       = `MEMC_DFI_DATA_WIDTH       // internal data width
  ,parameter       CORE_MASK_WIDTH       = `MEMC_DFI_DATA_WIDTH/8     // data mask width
  ,parameter       WRSRAM_DATA_WIDTH     = `MEMC_DFI_DATA_WIDTH       // WR-SRAM data width
  ,parameter       WRSRAM_MASK_WIDTH     = `MEMC_DFI_DATA_WIDTH/8     // WR-SRAM data mask width
  ,parameter       CORE_DCERRBITS        = `MEMC_DCERRBITS
  ,parameter       OCECC_EN              = 0
  ,parameter       OCECC_MR_RD_GRANU     = 8
  ,parameter       WDATA_PAR_WIDTH       = `UMCTL2_WDATARAM_PAR_DW
  ,parameter       WDATA_PAR_WIDTH_EXT   = `UMCTL2_WDATARAM_PAR_DW_EXT
)
(

   input                           co_yy_clk              // clock
  ,input                           core_ddrc_rstn         // asynchronous negative-edge reset
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in RTL assertion 
  ,input                           ddrc_cg_en             // clock gating enable
//spyglass enable_block W240
  ,input   [DFI_TPHY_WRDATA_WIDTH-1:0] mr_t_wrdata
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep current coding style for now. 
  ,input                           dh_mr_frequency_ratio  // 0 - 1:2 mode, 1 - 1:1 mode
//spyglass enable_block W240   
  ,input                           reg_ddrc_lpddr4        // LPDDR4 mode
  ,input                           ts_pi_mwr              // Mask-Write indication from selection n/w
  ,input  [1:0]                    mr_t_wrdata_add_sdr      // indicates that write data phase
  ,output [1:0]                    wr_ph                    // indicates that write data phase

  ,input                           gs_mr_write            // write command issued 
  ,input   [WRCAM_ADDR_WIDTH_IE -1:0] te_mr_wr_ram_addr      // write RAM address
   
  ,input   [PARTIAL_WR_BITS-1:0]   te_pi_wr_word_valid
  ,input   [PARTIAL_WR_BITS_LOG2-1:0] te_mr_ram_raddr_lsb_first
  ,input   [PW_WORD_CNT_WD_MAX-1:0]   te_mr_pw_num_beats_m1

  ,output      [WRDATA_RAM_ADDR_WIDTH -1:0]    mr_me_raddr    // read address to write data RAM
  ,output  reg                                 mr_me_re       // read enable to write data RAM
  ,output      [WRDATA_RAM_ADDR_WIDTH -1:0]    mr_wu_raddr    // read address to wu module
  ,output                          ram_data_vld           // data from write data RAM is valid
  ,output                          ram_data_vld_early
  ,output                          ram_data_vld_upper_lane// data from write data RAM is valid for programmable freq ratio 1:1
   
  ,output reg  [WRCAM_ADDR_WIDTH_IE -1:0] mr_yy_free_wr_entry    // CAM entry number to free
  ,output reg                      mr_yy_free_wr_entry_valid// free the above entry number this cycle
   
  ,output reg                      mr_gs_empty            // MR is idle, OK to powerdown DQS
   
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used under different `ifdefs. Decided to keep current implementation.
  ,input   [3:0]                   reg_ddrc_burst_rdwr
//spyglass enable_block W240
   
  ,input [CORE_MASK_WIDTH-1:0]     me_mr_rdatamask// write data read from write data RAM
  ,input [WRSRAM_DATA_WIDTH-1:0]   me_mr_rdata    // write data read from write data RAM
  ,input [WDATA_PAR_WIDTH_EXT-1:0] me_mr_rdatapar

  ,output     [CORE_DATA_WIDTH-1:0]     mr_rdata    // write data read from write data RAM
  ,output     [CORE_MASK_WIDTH-1:0]     mr_rdatamask// write data read from write data RAM
  ,output     [CORE_MASK_WIDTH-1:0]     mr_rdatapar
//spyglass disable_block W240
//SMD: Input declared but not read
//SJ: Used in generate statement
  ,input                                          ocecc_en
//spyglass enable_block W240
  ,output                                         ocecc_mr_rd_corr_err
  ,output                                         ocecc_mr_rd_uncorr_err
  ,output [CORE_DATA_WIDTH/OCECC_MR_RD_GRANU-1:0] ocecc_mr_rd_byte_num
                );

//-------------------------- INPUTS AND OUTPUTS --------------------------------
localparam  TIMER_MAX_VALUE     = 64;
localparam  TIMER_WIDTH         = `log2(TIMER_MAX_VALUE);
localparam  NUM_OUTSTANDING_WR  = 16;
localparam  RAM_ADDR_MAX_CNT    = NUM_OUTSTANDING_WR-1;
localparam  RAM_ADDR_PTR_WIDTH  = `log2(RAM_ADDR_MAX_CNT);

localparam  WDATA_MR_LATENCY    = 1;
localparam  WDATA_PI_LATENCY    = 1;
localparam  WDATA_PATH_DELAY    = WDATARAM_RD_LATENCY
                                + WDATA_MR_LATENCY
                                + WDATA_PI_LATENCY
                                + `MEMC_REG_DFI_OUT_WR_DATA_VAL;


// The write latency timers count down from dfi_tphy_wrlat in the cycle the
//  write command is observed. The parameters below indicate the value of the
//  timer when the read command should be issued and when the data will be
//  valid respectively.
localparam [TIMER_WIDTH-1:0] MEMC_TIMER_RAM_RD_CMD_NO_ECC  = 1;

// When Controller is in LPDDR mode, regardless of ECC or non-ECC mode,
// start the wdataRAM read when the dfi_tphy_wrlat timer is at 1
// In LPDDR, dfi_tphy_wrlat is always at 1, so this means issuing the
// read command to wdataRAM along with the write command (gs_mr_write)

localparam [TIMER_WIDTH-1:0]  MEMC_TIMER_RAM_RD_CMD_LPDDR = 1;


// In ECC designs (non-LPDDR), the read has to happen earlier than non-ECC designs
// The reason for this is the extra flop that is present on the write data path (before
// the ECC encoder). The write data from the SRAM has to be read early, in order to 
// meet the write latency requirement, even with the presence of the extra flop
// In the case of ECC designs with data width less than 64, the read from SRAM has to
// be done one cycle earlier as it takes 2 cycles of data to build 64-bits of data before
// presenting to the ECC engine
// TODO: This was the case for multi-beat ECC. For single-beat ECC it is always 2
//`ifdef  MEMC_CORE_DATA_WIDTH_LT_64 // ECC supported: BW < 64, MB
// `define        MEMC_TIMER_RAM_RD_CMD_ECC       6'h03
//`else // ECC

localparam [TIMER_WIDTH-1:0] MEMC_TIMER_RAM_RD_CMD_ECC = 2;

// for posted write assert the wdata-required 3 cycles before the data read from the memory
localparam [TIMER_WIDTH-1:0] POSTED_WRITE_OFFSET = 3;

localparam WRDATA_CYCLES_LG2  = `log2(WRDATA_CYCLES);

//-------------------------- WIRES AND REGISTERS -------------------------------

    reg             mr_gs_empty_r;
    reg             ram_data_vld_r;
    wire dh_mr_ecc_en;
    
    wire            ram_rd_cmd;             // data valid out of write data RAM
    wire            new_ram_rd_cmd;         // data valid out of write data RAM
    
    wire    [4:0]   inc_word_count;         // word count incremented for next data xfer 
    reg     [4:0]   word_count;             // count the words transfered for each write
    wire    [4:0]   word_count_add;         // value to add to word_cnt each time
    wire            mwr_flag;               // LPDDR4 Masked Write flag
    wire    [1:0]                             wr_ph_w;      // write data phase
    reg     [2*(WDATARAM_RD_LATENCY+1)-1:0]   wr_ph_pipe;   // shift register for write data phase delay

    wire                                      int_wr_or_pda_w;
    wire    [WRCAM_ADDR_WIDTH_IE-1:0]         int_wr_ram_addr_w;
    wire    [PARTIAL_WR_BITS_LOG2-1:0]        int_ram_raddr_lsb_first_w;
    wire    [PW_WORD_CNT_WD_MAX-1:0]          int_pw_num_beats_m1_w;
    wire    [PARTIAL_WR_BITS-1:0]             int_wr_word_valid_w;

    reg [WRDATA_RAM_ADDR_WIDTH -1:0] mr_me_raddr_r;
    reg [WRDATA_RAM_ADDR_WIDTH -1:0] mr_me_raddr_d1;

    reg     [$bits(reg_ddrc_burst_rdwr)+1:0]   t_ccd_cnt;  // used for cases where the PI splits HIF commands into several DFI commands

    wire    [WRCAM_ADDR_WIDTH_IE -1:0] wr_ram_addr;    // address to read from write data RAM
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] wr_ram_addr_ff; // register version of the RAM address
                                                    //  from transaction evaluation
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr0;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr1;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr2;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr3;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr4;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr5;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr6;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr7;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr8;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr9;      // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr10;     // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr11;     // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr12;     // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr13;     // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr14;     // local ODT setting for write data
    reg     [WRCAM_ADDR_WIDTH_IE -1:0] ram_addr15;     // local ODT setting for write data

    // Masked write information from TE
    reg                             mwr_flag0;
    reg                             mwr_flag1;
    reg                             mwr_flag2;
    reg                             mwr_flag3;
    reg                             mwr_flag4;
    reg                             mwr_flag5;
    reg                             mwr_flag6;
    reg                             mwr_flag7;
    reg                             mwr_flag8;
    reg                             mwr_flag9;
    reg                             mwr_flag10;
    reg                             mwr_flag11;
    reg                             mwr_flag12;
    reg                             mwr_flag13;
    reg                             mwr_flag14;
    reg                             mwr_flag15;
    reg                             mwr_flag_ff;

    // write data phase
    reg     [1:0]                   wr_ph0;
    reg     [1:0]                   wr_ph1;
    reg     [1:0]                   wr_ph2;
    reg     [1:0]                   wr_ph3;
    reg     [1:0]                   wr_ph4;
    reg     [1:0]                   wr_ph5;
    reg     [1:0]                   wr_ph6;
    reg     [1:0]                   wr_ph7;
    reg     [1:0]                   wr_ph8;
    reg     [1:0]                   wr_ph9;
    reg     [1:0]                   wr_ph10;
    reg     [1:0]                   wr_ph11;
    reg     [1:0]                   wr_ph12;
    reg     [1:0]                   wr_ph13;
    reg     [1:0]                   wr_ph14;
    reg     [1:0]                   wr_ph15;
    reg     [1:0]                   wr_ph_ff;

    // from te_pi_wr_word_valid
    reg     [PARTIAL_WR_BITS-1:0]   word_valid0;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid1;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid2;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid3;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid4;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid5;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid6;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid7;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid8;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid9;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid10;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid11;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid12;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid13;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid14;
    reg     [PARTIAL_WR_BITS-1:0]   word_valid15;
    reg     [PARTIAL_WR_BITS-1:0]   wr_word_valid_ff; // register version of the wr_word_valid
    wire    [PARTIAL_WR_BITS-1:0]   wr_word_valid; 
    
    
    // from te_mr_ram_raddr_lsb_first
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first0;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first1;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first2;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first3;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first4;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first5;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first6;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first7;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first8;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first9;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first10;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first11;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first12;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first13;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first14;
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first15;
    
    reg     [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first_ff; // register version of the ram_raddr_lsb_first
    wire    [PARTIAL_WR_BITS_LOG2-1:0]   ram_raddr_lsb_first;
    
    // from te_mr_pw_num_beats_m1
    
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_0;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_1;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_2;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_3;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_4;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_5;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_6;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_7;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_8;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_9;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_10;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_11;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_12;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_13;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_14;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_15;
    
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_ff; // register version of the pw_num_beats_m1
    wire [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1;



/* Uncomment for Local ODT *
reg                             lodt0;          // local ODT setting for write data
reg                             lodt1;          // local ODT setting for write data
reg                             lodt2;          // local ODT setting for write data
reg                             lodt3;          // local ODT setting for write data
reg                             lodt_ff;        // flopped local ODT setting
 * Uncomment for Local ODT */

    reg     [TIMER_WIDTH-1:0]   latency_timer [NUM_OUTSTANDING_WR-1:0];         // write latency timer for each ram_addr

    reg     [RAM_ADDR_PTR_WIDTH-1:0]   ram_addr_wr_ptr;        // point to one of 11 saved addresses
                                        //  for reading data from the write
                                        //  data RAM

    wire        wr_or_pda_w; // WR or PDA command scheduled


//------------------------------------------------------------------------------
// For timing alignment
    reg  [WDATARAM_RD_LATENCY-1:0]  mr_me_re_pipe;
    reg                             i_mr_me_re;
    reg  [WDATARAM_RD_LATENCY+1:0]  upper_lane_pipe;
    reg                             free_wr_entry_valid_d1;
    reg  [WRCAM_ADDR_WIDTH_IE -1:0] free_wr_entry_d1;


//------------------------------------------------------------------------------
// For PDA mode,
//     Additional signal which has as the same timing as ram_data_vld will be
//     needed. However, we don't need to read any data from SRAM.
// 
//------------------------------------------------------------------------------
    assign  wr_or_pda_w     = gs_mr_write
                            ;


    // 1:1 MEMC_BL=16 FBW -> 4  (8 beats)
    // 1:2 MEMC_BL=16 FBW -> 8  (4 beats)
    // 1:1 MEMC_BL=8  FBW -> 8  (4 beats)
    // 1:2 MEMC_BL=8  FBW -> 16 (2 beats)
    // 1:1 MEMC_BL=4  FBW -> 16 (2 beats)
    localparam PW_NUM_DB = PARTIAL_WR_BITS;
    
    localparam PW_FACTOR_FBW = 1*`MEMC_FREQ_RATIO;
    
    localparam PW_WORD_VALID_WD_FBW = PW_NUM_DB*PW_FACTOR_FBW;
    
    localparam PW_WORD_VALID_WD_MAX = PW_WORD_VALID_WD_FBW;
    
    localparam PW_WORD_CNT_WD_FBW = `log2(PW_WORD_VALID_WD_FBW);
    //localparam PW_WORD_CNT_WD_MAX = `log2(PW_WORD_VALID_WD_MAX);
    localparam PW_NUM_DB_LOG2 = `log2(PW_NUM_DB);
    
    //localparam PW_WORD_CNT_WD_MAX_P1 = PW_WORD_CNT_WD_MAX + 1;
    
    
    localparam PW_NUM_BEATS_PDA_M1_FR2 = {{(PW_WORD_CNT_WD_MAX-1){1'b0}}, 1'b1}; // 2 core data beats equals BL8 for DDR4 PDA - set to 1 as minus 1 value
    localparam PW_NUM_BEATS_PDA_M1_FR1 = {{(PW_WORD_CNT_WD_MAX-2){1'b0}}, 2'b11}; // 4 core data beats equals BL8 for DDR4 PDA - set to 3 as minus 1 value
    
    
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_cnt;
    





//----------------- TRACK ADDRESSES AND TIME DATA OUT --------------------------
    genvar l;
    // counters logic
    // zero flag and comparators
    wire [NUM_OUTSTANDING_WR-1:0]   latency_timer_zero;
    wire [TIMER_WIDTH-1:0]          timer_cmp; // compare value for timers, depending on configuration
    wire [NUM_OUTSTANDING_WR-1:0]   latency_timer_sel; // comparators output, mux selector

    assign timer_cmp = MEMC_TIMER_RAM_RD_CMD_NO_ECC;

    //spyglass disable_block STARC05-2.11.3.1
    //SMD: Combinational and sequential parts of an FSM described in same always block
    //SJ: Reported for ram_addr_wr_ptr. Coding style used to prevent overflow. No re-coding required.

    // RAM read address buffers write pointer (resetable flops)
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn)
        // resetable flops
        if (~core_ddrc_rstn)
            ram_addr_wr_ptr     <= {RAM_ADDR_PTR_WIDTH{1'b0}};
        else if(ddrc_cg_en) begin
            if (int_wr_or_pda_w 
                  ) begin
                if (ram_addr_wr_ptr == RAM_ADDR_MAX_CNT)
                    ram_addr_wr_ptr <= {RAM_ADDR_PTR_WIDTH{1'b0}};
                else
                    ram_addr_wr_ptr     <= ram_addr_wr_ptr + 1;
            end
        end
    //spyglass enable_block STARC05-2.11.3.1



generate
    for (l=0; l<NUM_OUTSTANDING_WR; l=l+1) begin: latency_CALC
        // RAM read address buffers (resetable flops)
        always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
            if (~core_ddrc_rstn) begin
                latency_timer[l]     <= {TIMER_WIDTH{1'b0}};
            end
            else if(ddrc_cg_en) begin
            // Set the timer to the write latency and count down
            //  4 seperate timers allows tracking of up to 4 write commands with
            //  data pending. A 2-bit pointer tracks which timer to use next.
            // IMPORTANT: remember that gs_mr_write is 1 cycle ahead of the write
            //            to the PHY
                if (int_wr_or_pda_w && (ram_addr_wr_ptr == l)) begin
                    latency_timer[l]     <= mr_t_wrdata;
                end
                else begin
                    latency_timer[l]     <= latency_timer_zero[l] ? {TIMER_WIDTH{1'b0}} : latency_timer[l] - 1;
                end
            end
        end //  always @ (posedge co_yy_clk or negedge core_ddrc_rstn)

        // comparators
        assign latency_timer_zero[l]        = (latency_timer[l] == {TIMER_WIDTH{1'b0}}) ? 1'b1 : 1'b0;
        assign latency_timer_sel[l]         = (latency_timer[l] == timer_cmp) ? 1'b1 : 1'b0; // compare the timers against MEMC_TIMER_RAM_RD_CMD_* and use in muxes below

    end // for (l=0; l<NUM_OUTSTANDING_WR; l=l+1)
endgenerate


//-------------------------------------------------------------
// End: the write latency assignment logic
//-------------------------------------------------------------


// Track the RAM address to read from when the time comes to deliver write
// data.  One address associated with the each of the 4 counters above.
// Also, subtract 1 from the write latency programmed in GS
// non-resetable flops
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        ram_addr0  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr1  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr2  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr3  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr4  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr5  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr6  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr7  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr8  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr9  <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr10 <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr11 <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr12 <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr13 <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr14 <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        ram_addr15 <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        wr_ram_addr_ff <= {WRCAM_ADDR_WIDTH_IE{1'b0}};

        mwr_flag0   <= 1'b0;
        mwr_flag1   <= 1'b0;
        mwr_flag2   <= 1'b0;
        mwr_flag3   <= 1'b0;
        mwr_flag4   <= 1'b0;
        mwr_flag5   <= 1'b0;
        mwr_flag6   <= 1'b0;
        mwr_flag7   <= 1'b0;
        mwr_flag8   <= 1'b0;
        mwr_flag9   <= 1'b0;
        mwr_flag10  <= 1'b0;
        mwr_flag11  <= 1'b0;
        mwr_flag12  <= 1'b0;
        mwr_flag13  <= 1'b0;
        mwr_flag14  <= 1'b0;
        mwr_flag15  <= 1'b0;
        mwr_flag_ff <= 1'b0;

        wr_ph0   <= 2'b00;
        wr_ph1   <= 2'b00;
        wr_ph2   <= 2'b00;
        wr_ph3   <= 2'b00;
        wr_ph4   <= 2'b00;
        wr_ph5   <= 2'b00;
        wr_ph6   <= 2'b00;
        wr_ph7   <= 2'b00;
        wr_ph8   <= 2'b00;
        wr_ph9   <= 2'b00;
        wr_ph10  <= 2'b00;
        wr_ph11  <= 2'b00;
        wr_ph12  <= 2'b00;
        wr_ph13  <= 2'b00;
        wr_ph14  <= 2'b00;
        wr_ph15  <= 2'b00;
        wr_ph_ff <= 2'b00;

        word_valid0  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid1  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid2  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid3  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid4  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid5  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid6  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid7  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid8  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid9  <= {PARTIAL_WR_BITS{1'b0}};
        word_valid10 <= {PARTIAL_WR_BITS{1'b0}};
        word_valid11 <= {PARTIAL_WR_BITS{1'b0}};
        word_valid12 <= {PARTIAL_WR_BITS{1'b0}};
        word_valid13 <= {PARTIAL_WR_BITS{1'b0}};
        word_valid14 <= {PARTIAL_WR_BITS{1'b0}};
        word_valid15 <= {PARTIAL_WR_BITS{1'b0}};
        wr_word_valid_ff <= {PARTIAL_WR_BITS{1'b0}};
 

        ram_raddr_lsb_first0  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first1  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first2  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first3  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first4  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first5  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first6  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first7  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first8  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first9  <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first10 <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first11 <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first12 <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first13 <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first14 <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first15 <= {PARTIAL_WR_BITS_LOG2{1'b0}};
        ram_raddr_lsb_first_ff <= {PARTIAL_WR_BITS_LOG2{1'b0}};


        pw_num_beats_m1_0  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_1  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_2  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_3  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_4  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_5  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_6  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_7  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_8  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_9  <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_10 <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_11 <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_12 <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_13 <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_14 <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_15 <= {PW_WORD_CNT_WD_MAX{1'b0}};
        pw_num_beats_m1_ff <= {PW_WORD_CNT_WD_MAX{1'b0}};


        /* Uncomment for Local ODT *
              lodt0     <= 1'b0;
              lodt1     <= 1'b0;
              lodt2     <= 1'b0;
              lodt3     <= 1'b0;
              lodt_ff   <= 1'b0;
         * Uncomment for Local ODT */
        free_wr_entry_d1    <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
        mr_yy_free_wr_entry <= {WRCAM_ADDR_WIDTH_IE{1'b0}};
    end
    else if(ddrc_cg_en) begin
        if (wr_or_pda_w) begin
            case (ram_addr_wr_ptr [3:0])
                4'b0000: ram_addr0  <= te_mr_wr_ram_addr;
                4'b0001: ram_addr1  <= te_mr_wr_ram_addr;
                4'b0010: ram_addr2  <= te_mr_wr_ram_addr;
                4'b0011: ram_addr3  <= te_mr_wr_ram_addr;
                4'b0100: ram_addr4  <= te_mr_wr_ram_addr;
                4'b0101: ram_addr5  <= te_mr_wr_ram_addr;
                4'b0110: ram_addr6  <= te_mr_wr_ram_addr;
                4'b0111: ram_addr7  <= te_mr_wr_ram_addr;
                4'b1000: ram_addr8  <= te_mr_wr_ram_addr;
                4'b1001: ram_addr9  <= te_mr_wr_ram_addr;
                4'b1010: ram_addr10 <= te_mr_wr_ram_addr;
                4'b1011: ram_addr11 <= te_mr_wr_ram_addr;
                4'b1100: ram_addr12 <= te_mr_wr_ram_addr;
                4'b1101: ram_addr13 <= te_mr_wr_ram_addr;
                4'b1110: ram_addr14 <= te_mr_wr_ram_addr;
                default: ram_addr15 <= te_mr_wr_ram_addr;
            endcase
        
            case (ram_addr_wr_ptr [3:0])
                4'b0000: mwr_flag0  <= ts_pi_mwr;
                4'b0001: mwr_flag1  <= ts_pi_mwr;
                4'b0010: mwr_flag2  <= ts_pi_mwr;
                4'b0011: mwr_flag3  <= ts_pi_mwr;
                4'b0100: mwr_flag4  <= ts_pi_mwr;
                4'b0101: mwr_flag5  <= ts_pi_mwr;
                4'b0110: mwr_flag6  <= ts_pi_mwr;
                4'b0111: mwr_flag7  <= ts_pi_mwr;
                4'b1000: mwr_flag8  <= ts_pi_mwr;
                4'b1001: mwr_flag9  <= ts_pi_mwr;
                4'b1010: mwr_flag10 <= ts_pi_mwr;
                4'b1011: mwr_flag11 <= ts_pi_mwr;
                4'b1100: mwr_flag12 <= ts_pi_mwr;
                4'b1101: mwr_flag13 <= ts_pi_mwr;
                4'b1110: mwr_flag14 <= ts_pi_mwr;
                default: mwr_flag15 <= ts_pi_mwr;
            endcase
        
            case (ram_addr_wr_ptr [3:0])
                4'b0000: word_valid0  <= te_pi_wr_word_valid;
                4'b0001: word_valid1  <= te_pi_wr_word_valid;
                4'b0010: word_valid2  <= te_pi_wr_word_valid;
                4'b0011: word_valid3  <= te_pi_wr_word_valid;
                4'b0100: word_valid4  <= te_pi_wr_word_valid;
                4'b0101: word_valid5  <= te_pi_wr_word_valid;
                4'b0110: word_valid6  <= te_pi_wr_word_valid;
                4'b0111: word_valid7  <= te_pi_wr_word_valid;
                4'b1000: word_valid8  <= te_pi_wr_word_valid;
                4'b1001: word_valid9  <= te_pi_wr_word_valid;
                4'b1010: word_valid10 <= te_pi_wr_word_valid;
                4'b1011: word_valid11 <= te_pi_wr_word_valid;
                4'b1100: word_valid12 <= te_pi_wr_word_valid;
                4'b1101: word_valid13 <= te_pi_wr_word_valid;
                4'b1110: word_valid14 <= te_pi_wr_word_valid;
                default: word_valid15 <= te_pi_wr_word_valid;
            endcase
        
        
            case (ram_addr_wr_ptr [3:0])
                4'b0000: ram_raddr_lsb_first0  <= te_mr_ram_raddr_lsb_first;
                4'b0001: ram_raddr_lsb_first1  <= te_mr_ram_raddr_lsb_first;
                4'b0010: ram_raddr_lsb_first2  <= te_mr_ram_raddr_lsb_first;
                4'b0011: ram_raddr_lsb_first3  <= te_mr_ram_raddr_lsb_first;
                4'b0100: ram_raddr_lsb_first4  <= te_mr_ram_raddr_lsb_first;
                4'b0101: ram_raddr_lsb_first5  <= te_mr_ram_raddr_lsb_first;
                4'b0110: ram_raddr_lsb_first6  <= te_mr_ram_raddr_lsb_first;
                4'b0111: ram_raddr_lsb_first7  <= te_mr_ram_raddr_lsb_first;
                4'b1000: ram_raddr_lsb_first8  <= te_mr_ram_raddr_lsb_first;
                4'b1001: ram_raddr_lsb_first9  <= te_mr_ram_raddr_lsb_first;
                4'b1010: ram_raddr_lsb_first10 <= te_mr_ram_raddr_lsb_first;
                4'b1011: ram_raddr_lsb_first11 <= te_mr_ram_raddr_lsb_first;
                4'b1100: ram_raddr_lsb_first12 <= te_mr_ram_raddr_lsb_first;
                4'b1101: ram_raddr_lsb_first13 <= te_mr_ram_raddr_lsb_first;
                4'b1110: ram_raddr_lsb_first14 <= te_mr_ram_raddr_lsb_first;
                default: ram_raddr_lsb_first15 <= te_mr_ram_raddr_lsb_first;
            endcase
        
            case (ram_addr_wr_ptr [3:0])
                4'b0000: pw_num_beats_m1_0  <= te_mr_pw_num_beats_m1;
                4'b0001: pw_num_beats_m1_1  <= te_mr_pw_num_beats_m1;
                4'b0010: pw_num_beats_m1_2  <= te_mr_pw_num_beats_m1;
                4'b0011: pw_num_beats_m1_3  <= te_mr_pw_num_beats_m1;
                4'b0100: pw_num_beats_m1_4  <= te_mr_pw_num_beats_m1;
                4'b0101: pw_num_beats_m1_5  <= te_mr_pw_num_beats_m1;
                4'b0110: pw_num_beats_m1_6  <= te_mr_pw_num_beats_m1;
                4'b0111: pw_num_beats_m1_7  <= te_mr_pw_num_beats_m1;
                4'b1000: pw_num_beats_m1_8  <= te_mr_pw_num_beats_m1;
                4'b1001: pw_num_beats_m1_9  <= te_mr_pw_num_beats_m1;
                4'b1010: pw_num_beats_m1_10 <= te_mr_pw_num_beats_m1;
                4'b1011: pw_num_beats_m1_11 <= te_mr_pw_num_beats_m1;
                4'b1100: pw_num_beats_m1_12 <= te_mr_pw_num_beats_m1;
                4'b1101: pw_num_beats_m1_13 <= te_mr_pw_num_beats_m1;
                4'b1110: pw_num_beats_m1_14 <= te_mr_pw_num_beats_m1;
                default: pw_num_beats_m1_15 <= te_mr_pw_num_beats_m1;
            endcase
          
        
        end // if (wr_or_pda_w) begin

        if (int_wr_or_pda_w) begin
            case (ram_addr_wr_ptr [3:0])
                4'b0000: wr_ph0  <= mr_t_wrdata_add_sdr;
                4'b0001: wr_ph1  <= mr_t_wrdata_add_sdr;
                4'b0010: wr_ph2  <= mr_t_wrdata_add_sdr;
                4'b0011: wr_ph3  <= mr_t_wrdata_add_sdr;
                4'b0100: wr_ph4  <= mr_t_wrdata_add_sdr;
                4'b0101: wr_ph5  <= mr_t_wrdata_add_sdr;
                4'b0110: wr_ph6  <= mr_t_wrdata_add_sdr;
                4'b0111: wr_ph7  <= mr_t_wrdata_add_sdr;
                4'b1000: wr_ph8  <= mr_t_wrdata_add_sdr;
                4'b1001: wr_ph9  <= mr_t_wrdata_add_sdr;
                4'b1010: wr_ph10 <= mr_t_wrdata_add_sdr;
                4'b1011: wr_ph11 <= mr_t_wrdata_add_sdr;
                4'b1100: wr_ph12 <= mr_t_wrdata_add_sdr;
                4'b1101: wr_ph13 <= mr_t_wrdata_add_sdr;
                4'b1110: wr_ph14 <= mr_t_wrdata_add_sdr;
                default: wr_ph15 <= mr_t_wrdata_add_sdr;
            endcase
        end // if (int_wr_or_pda_w) begin

        wr_ram_addr_ff          <= wr_ram_addr;
        mwr_flag_ff             <= mwr_flag;
        wr_ph_ff                <= wr_ph_w;
        ram_raddr_lsb_first_ff  <= ram_raddr_lsb_first;
        pw_num_beats_m1_ff      <= pw_num_beats_m1;
        wr_word_valid_ff        <= wr_word_valid;
        // store entry to be freed 
        if (new_ram_rd_cmd) begin
            free_wr_entry_d1    <= wr_ram_addr;
        end 
        mr_yy_free_wr_entry     <= free_wr_entry_d1;

    end // always: non-resetable flops
end


//-----------------------------------------------------------------------------------------
    wire use_te_input_unregistered;
    assign use_te_input_unregistered  = (mr_t_wrdata == {$bits(mr_t_wrdata){1'b0}}) ? int_wr_or_pda_w : 1'b0;

    assign wr_ram_addr = (use_te_input_unregistered) ? int_wr_ram_addr_w :
                         (latency_timer_sel[0])      ? ram_addr0         :
                         (latency_timer_sel[1])      ? ram_addr1         :
                         (latency_timer_sel[2])      ? ram_addr2         :
                         (latency_timer_sel[3])      ? ram_addr3         :
                         (latency_timer_sel[4])      ? ram_addr4         :
                         (latency_timer_sel[5])      ? ram_addr5         :
                         (latency_timer_sel[6])      ? ram_addr6         :
                         (latency_timer_sel[7])      ? ram_addr7         :
                         (latency_timer_sel[8])      ? ram_addr8         :
                         (latency_timer_sel[9])      ? ram_addr9         :
                         (latency_timer_sel[10])     ? ram_addr10        :
                         (latency_timer_sel[11])     ? ram_addr11        :
                         (latency_timer_sel[12])     ? ram_addr12        :
                         (latency_timer_sel[13])     ? ram_addr13        :
                         (latency_timer_sel[14])     ? ram_addr14        :
                         (latency_timer_sel[15])     ? ram_addr15        :
                                                       wr_ram_addr_ff    ;
    
    //------------------------ LPDDR4 Masked Write related logic  -----------------------------
    assign mwr_flag = (use_te_input_unregistered)   ? ts_pi_mwr         :
                      (latency_timer_sel[0])        ? mwr_flag0         :
                      (latency_timer_sel[1])        ? mwr_flag1         :
                      (latency_timer_sel[2])        ? mwr_flag2         :
                      (latency_timer_sel[3])        ? mwr_flag3         :
                      (latency_timer_sel[4])        ? mwr_flag4         :
                      (latency_timer_sel[5])        ? mwr_flag5         :
                      (latency_timer_sel[6])        ? mwr_flag6         :
                      (latency_timer_sel[7])        ? mwr_flag7         :
                      (latency_timer_sel[8])        ? mwr_flag8         :
                      (latency_timer_sel[9])        ? mwr_flag9         :
                      (latency_timer_sel[10])       ? mwr_flag10        :
                      (latency_timer_sel[11])       ? mwr_flag11        :
                      (latency_timer_sel[12])       ? mwr_flag12        :
                      (latency_timer_sel[13])       ? mwr_flag13        :
                      (latency_timer_sel[14])       ? mwr_flag14        :
                      (latency_timer_sel[15])       ? mwr_flag15        :
                                                      mwr_flag_ff       ;
    

    //------------------------ Write Data Phase -----------------------------------------------
    assign wr_ph_w  = (use_te_input_unregistered)   ? mr_t_wrdata_add_sdr:
                      (latency_timer_sel[0])        ? wr_ph0            :
                      (latency_timer_sel[1])        ? wr_ph1            :
                      (latency_timer_sel[2])        ? wr_ph2            :
                      (latency_timer_sel[3])        ? wr_ph3            :
                      (latency_timer_sel[4])        ? wr_ph4            :
                      (latency_timer_sel[5])        ? wr_ph5            :
                      (latency_timer_sel[6])        ? wr_ph6            :
                      (latency_timer_sel[7])        ? wr_ph7            :
                      (latency_timer_sel[8])        ? wr_ph8            :
                      (latency_timer_sel[9])        ? wr_ph9            :
                      (latency_timer_sel[10])       ? wr_ph10           :
                      (latency_timer_sel[11])       ? wr_ph11           :
                      (latency_timer_sel[12])       ? wr_ph12           :
                      (latency_timer_sel[13])       ? wr_ph13           :
                      (latency_timer_sel[14])       ? wr_ph14           :
                      (latency_timer_sel[15])       ? wr_ph15           :
                                                      wr_ph_ff          ;


//-----------------------------------------------------------------------------------------
    //-------------------------- PARTIAL_WR related logic  ------------------------------------
    
    
    // ram_raddr_lsb_first
    assign ram_raddr_lsb_first       = (use_te_input_unregistered) ? int_ram_raddr_lsb_first_w    :
                                       (latency_timer_sel[0])      ? ram_raddr_lsb_first0         :
                                       (latency_timer_sel[1])      ? ram_raddr_lsb_first1         :
                                       (latency_timer_sel[2])      ? ram_raddr_lsb_first2         :
                                       (latency_timer_sel[3])      ? ram_raddr_lsb_first3         :
                                       (latency_timer_sel[4])      ? ram_raddr_lsb_first4         :
                                       (latency_timer_sel[5])      ? ram_raddr_lsb_first5         :
                                       (latency_timer_sel[6])      ? ram_raddr_lsb_first6         :
                                       (latency_timer_sel[7])      ? ram_raddr_lsb_first7         :
                                       (latency_timer_sel[8])      ? ram_raddr_lsb_first8         :
                                       (latency_timer_sel[9])      ? ram_raddr_lsb_first9         :
                                       (latency_timer_sel[10])     ? ram_raddr_lsb_first10        :
                                       (latency_timer_sel[11])     ? ram_raddr_lsb_first11        :
                                       (latency_timer_sel[12])     ? ram_raddr_lsb_first12        :
                                       (latency_timer_sel[13])     ? ram_raddr_lsb_first13        :
                                       (latency_timer_sel[14])     ? ram_raddr_lsb_first14        :
                                       (latency_timer_sel[15])     ? ram_raddr_lsb_first15        :
                                                                     ram_raddr_lsb_first_ff    ;
    
    
    //------- pw_num_beats_m1
    
    // te_mr_pw_num_beats_m1 -> latency version of these upto 13 of them
    assign pw_num_beats_m1       = (use_te_input_unregistered) ? int_pw_num_beats_m1_w     :
                                   (latency_timer_sel[0])      ? pw_num_beats_m1_0         :
                                   (latency_timer_sel[1])      ? pw_num_beats_m1_1         :
                                   (latency_timer_sel[2])      ? pw_num_beats_m1_2         :
                                   (latency_timer_sel[3])      ? pw_num_beats_m1_3         :
                                   (latency_timer_sel[4])      ? pw_num_beats_m1_4         :
                                   (latency_timer_sel[5])      ? pw_num_beats_m1_5         :
                                   (latency_timer_sel[6])      ? pw_num_beats_m1_6         :
                                   (latency_timer_sel[7])      ? pw_num_beats_m1_7         :
                                   (latency_timer_sel[8])      ? pw_num_beats_m1_8         :
                                   (latency_timer_sel[9])      ? pw_num_beats_m1_9         :
                                   (latency_timer_sel[10])     ? pw_num_beats_m1_10        :
                                   (latency_timer_sel[11])     ? pw_num_beats_m1_11        :
                                   (latency_timer_sel[12])     ? pw_num_beats_m1_12        :
                                   (latency_timer_sel[13])     ? pw_num_beats_m1_13        :
                                   (latency_timer_sel[14])     ? pw_num_beats_m1_14        :
                                   (latency_timer_sel[15])     ? pw_num_beats_m1_15        :
                                                                 pw_num_beats_m1_ff    ;
    
    //------- wr_word_valid
    
    // te_pi_wr_word_valid -> latency version of these upto 13 of them
    assign wr_word_valid       = (use_te_input_unregistered) ? int_wr_word_valid_w :
                                 (latency_timer_sel[0])      ? word_valid0         :
                                 (latency_timer_sel[1])      ? word_valid1         :
                                 (latency_timer_sel[2])      ? word_valid2         :
                                 (latency_timer_sel[3])      ? word_valid3         :
                                 (latency_timer_sel[4])      ? word_valid4         :
                                 (latency_timer_sel[5])      ? word_valid5         :
                                 (latency_timer_sel[6])      ? word_valid6         :
                                 (latency_timer_sel[7])      ? word_valid7         :
                                 (latency_timer_sel[8])      ? word_valid8         :
                                 (latency_timer_sel[9])      ? word_valid9         :
                                 (latency_timer_sel[10])     ? word_valid10        :
                                 (latency_timer_sel[11])     ? word_valid11        :
                                 (latency_timer_sel[12])     ? word_valid12        :
                                 (latency_timer_sel[13])     ? word_valid13        :
                                 (latency_timer_sel[14])     ? word_valid14        :
                                 (latency_timer_sel[15])     ? word_valid15        :
                                                               wr_word_valid_ff    ;
    
    
    reg [PARTIAL_WR_BITS-1:0] wr_word_valid_r;
    
    // registered version of wr_word_valid
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            wr_word_valid_r <= {PARTIAL_WR_BITS{1'b0}};
        end else begin
            wr_word_valid_r <= wr_word_valid;
        end
    end
    
    
    
    //wire pw_num_beats_eq1;
    //assign pw_num_beats_eq1 = 1'b0;
    
    // FBW
    // Convert te_pi_wr_word_valid_r with is PARTIAL_WR_BITS wide
    // into a vector thar is 1*PARTIAL_WR_BITS
    reg [PW_WORD_VALID_WD_FBW-1:0] pw_word_valid_fbw;
    reg [PW_WORD_VALID_WD_FBW-1:0] pw_word_valid_fbw_r;
    //spyglass disable_block W415a
    //SMD: Signal pw_word_valid_fbw is being assigned multiple times in same always block. 
    //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
    always @(*) begin : pw_word_valid_fbw_PROC
        integer i_cnt;
        integer x_cnt;
        pw_word_valid_fbw = pw_word_valid_fbw_r;
        for (i_cnt=0; i_cnt<PW_NUM_DB; i_cnt=i_cnt+1) begin
            for (x_cnt=0; x_cnt<PW_FACTOR_FBW; x_cnt=x_cnt+1) begin
                if (wr_word_valid_r[i_cnt]) begin
                    pw_word_valid_fbw[i_cnt*PW_FACTOR_FBW + x_cnt] = 1'b1;
                end else begin
                    pw_word_valid_fbw[i_cnt*PW_FACTOR_FBW + x_cnt] = 1'b0;
                end
            end
        end
    end
    //spyglass enable_block W415a
    
    // registered version of pw_word_valid_fbw
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
            pw_word_valid_fbw_r <= {PW_WORD_VALID_WD_FBW{1'b0}};
        end else begin
            pw_word_valid_fbw_r <= pw_word_valid_fbw;
        end
    end
    
    
    reg [PW_WORD_VALID_WD_MAX-1:0] pw_word_valid;
    assign pw_word_valid[PW_WORD_VALID_WD_FBW-1:0] = pw_word_valid_fbw;
    
    // as mr is wired to reg_ddrc_burst_rdwr_int at toplevel of ddrc.v
    // adjust for shift >>1 if FREQ_RATIO=2, but only if SW selected 1:2 mode
    // if FREQ_RATIO-2 and SW selected 1:1 mode, do not re-adjust as reg_ddrc_burst_rdwr=reg_ddrc_burst_rdwr_int
    // 
    wire [3:0] reg_ddrc_burst_rdwr_pw;
    assign reg_ddrc_burst_rdwr_pw = (dh_mr_frequency_ratio) ? reg_ddrc_burst_rdwr : {reg_ddrc_burst_rdwr[2:0], 1'b0};
    
    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '((PW_WORD_VALID_WD_MAX + 1) - 1)' found in module 'mr_ram_rd_pipeline'
    //SJ: This coding style is acceptable and there is no plan to change it.
    // BL8
    reg [PW_WORD_VALID_WD_MAX-1:0] pw_word_valid_bl8;
    always @(*) begin : pw_word_valid_bl8_PROC
        integer k_cnt;
        //for (k_cnt=0; k_cnt<PW_WORD_VALID_WD_MAX+1-4; k_cnt=k_cnt+4) begin
        for (k_cnt=PW_WORD_VALID_WD_MAX-4; k_cnt>=0; k_cnt=k_cnt-4) begin
                pw_word_valid_bl8[k_cnt+:4] = (|pw_word_valid[k_cnt+:4]) ? 4'b1111 : 4'b0000;
        end // for
    end

    // BL16
    reg [PW_WORD_VALID_WD_MAX-1:0] pw_word_valid_bl16;
    always @(*) begin : pw_word_valid_bl16_PROC
        integer k_cnt;
        pw_word_valid_bl16 = {PW_WORD_VALID_WD_MAX{1'b0}};
        for (k_cnt=0; k_cnt<PW_WORD_VALID_WD_MAX+1-8; k_cnt=k_cnt+8) begin
            pw_word_valid_bl16[k_cnt+:8] = (|pw_word_valid[k_cnt+:8]) ? 8'b1111_1111 : 8'b0000_0000;
        end // for
    end
    //spyglass enable_block SelfDeterminedExpr-ML
    
    wire [PW_WORD_VALID_WD_MAX-1:0] pw_word_valid_bl_sel;
    assign pw_word_valid_bl_sel = (reg_ddrc_burst_rdwr_pw[3]) ? pw_word_valid_bl16 : pw_word_valid_bl8;
    
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_num_beats_m1_r;
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_word_cnt;
    
    wire [PW_WORD_CNT_WD_MAX-1:0] pw_word_cnt_next_non_first;
    reg  [PW_WORD_CNT_WD_MAX-1:0] pw_word_cnt_next_non_first_x;
    
    //  finds first element in pw_word_valid_bl_sel 
    //  that is >=current pw_word_cnt + 2 -FREQ_RATIO=2
    //  that is >=current pw_word_cnt + 4 -FREQ_RATIO=4
    //  Used for current count value in pw_word_cnt
    //  Note use of pw_word_valid_bl_sel_r to improve synthesis
    
    //spyglass disable_block W216
    //SMD: Inappropriate range select for int_part_sel variable: "j_cnt[(PW_WORD_CNT_WD_MAX - 1):0] "
    //SJ: All occurences of W216 errors have been previously waived in Leda, as they were considered safe and because no suitable re-coding was found (see bug2455)
    //spyglass disable_block W415a
    //SMD: Signal pw_word_cnt_next_non_first_x is being assigned multiple times in same always block. 
    //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '(pw_word_cnt + 4)' found in module 'mr_ram_rd_pipeline'
    //SJ: This coding style is acceptable and there is no plan to change it.
    always @(*) begin : pw_word_cnt_next_non_first_x_PROC
        integer j_cnt;
        pw_word_cnt_next_non_first_x = {PW_WORD_CNT_WD_MAX{1'b0}};
        for (j_cnt=PW_WORD_VALID_WD_MAX-1; j_cnt>=0; j_cnt=j_cnt-1) begin
            if ((j_cnt>=pw_word_cnt+`MEMC_FREQ_RATIO) && (pw_word_valid_bl_sel[j_cnt])) begin
                pw_word_cnt_next_non_first_x = j_cnt[PW_WORD_CNT_WD_MAX-1:0];
            end
        end // for 
    end
    //spyglass enable_block SelfDeterminedExpr-ML
    //spyglass enable_block W415a
    
    reg [PW_WORD_CNT_WD_MAX-1:0] pw_word_cnt_next_non_first_sw_fr2;
    
    //  finds first element in pw_word_valid_bl_sel 
    //  that is >=current pw_word_cnt + 4 -FREQ_RATIO=4
    //  Used for current count value in pw_word_cnt
    //  Note use of pw_word_valid_bl_sel_r to improve synthesis
    
    //spyglass disable_block W528
    //SMD: A signal or variable is set but never read
    //SJ: Used in generate statement and therefore must always exist
    //spyglass disable_block W415a
    //SMD: Signal pw_word_cnt_next_non_first_sw_fr2 is being assigned multiple times in same always block. 
    //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
    //spyglass disable_block SelfDeterminedExpr-ML
    //SMD: Self determined expression '(pw_word_cnt + 2)' found in module 'mr_ram_rd_pipeline'
    //SJ: This coding style is acceptable and there is no plan to change it.
    always @(*) begin : pw_word_cnt_next_non_first_sw_fr2_PROC
        integer j_cnt;
        pw_word_cnt_next_non_first_sw_fr2 = {PW_WORD_CNT_WD_MAX{1'b0}};
        for (j_cnt=PW_WORD_VALID_WD_MAX-1; j_cnt>=0; j_cnt=j_cnt-1) begin
            // note use of Fixed value of pw_word_cnt+2,
            // instead of =pw_word_cnt+`MEMC_FREQ_RATIO, whch is used for pw_word_cnt_next_non_first_x
            if ((j_cnt>=pw_word_cnt+2) && (pw_word_valid_bl_sel[j_cnt])) begin
                pw_word_cnt_next_non_first_sw_fr2 = j_cnt[PW_WORD_CNT_WD_MAX-1:0];
            end
        end // for 
    end
    //spyglass enable_block SelfDeterminedExpr-ML
    //spyglass enable_block W415a
    //spyglass enable_block W528
    
    // select between  pw_word_cnt_next_non_first_x HW selected 1:1 or 1:2 ratio
    // or
    //pw_word_cnt_next_non_first_sw_fr2 if HW selected 1:2 version  and SW selected for 1:4

    // pw_word_cnt_next_non_first_sw_fr2 should be selected when SW Freq-Ratio does not match HW Freq-Ratio
    //   MEMC_FREQ_RATIO=4 && SW 1:4 mode (DDR5)     :  pw_word_cnt_next_non_first_x
    //   MEMC_FREQ_RATIO=4 && SW 1:2 mode (DDR4)     :  pw_word_cnt_next_non_first_sw_fr2
    //   MEMC_FREQ_RATIO=2 && SW 1:2 mode (DDR5,DDR4):  pw_word_cnt_next_non_first_x
    //   MEMC_FREQ_RATIO=2 && SW 1:1 mode            :  NA  Not support in uMCTL5
    //
    assign pw_word_cnt_next_non_first = (!dh_mr_frequency_ratio) ? pw_word_cnt_next_non_first_sw_fr2 : pw_word_cnt_next_non_first_x;
    //spyglass enable_block W216
    
    wire [PW_WORD_CNT_WD_MAX-1:0] pw_word_cnt_next_first;
    
    assign pw_word_cnt_next_first = { 1'b0, ram_raddr_lsb_first, 1'b0} ;   
    
    
    wire     reg_ddrc_ddr4_or_lpddr4;
    wire     pw_num_beats_cnt_dis_ddr4_lpddr4;
    
    assign reg_ddrc_ddr4_or_lpddr4 =
                reg_ddrc_lpddr4;
    
    // signal used to disable pw_num_beats_cnt when DDR4 is counting t_ccd_cnt time
    assign pw_num_beats_cnt_dis_ddr4_lpddr4 = ((t_ccd_cnt>={{($bits(t_ccd_cnt)-$bits(reg_ddrc_burst_rdwr)){1'b0}},reg_ddrc_burst_rdwr}) && (reg_ddrc_ddr4_or_lpddr4)) ? 1'b1 : 1'b0;
    
    
    wire pw_num_beats_eq1;
    assign pw_num_beats_eq1 = (~|pw_num_beats_m1);
    
    // resetable flops
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        if (~core_ddrc_rstn) begin
        
            pw_word_cnt      <= {PW_WORD_CNT_WD_MAX{1'b0}};
            pw_num_beats_cnt <= {PW_WORD_CNT_WD_MAX{1'b0}};
        end else if(ddrc_cg_en) begin
            if (new_ram_rd_cmd) begin
                pw_word_cnt      <= pw_word_cnt_next_first;
    
      // only add 1 if num_beats is 1 or more
      // pw_num_beats_eq1 comes from WR_CAM
      // OR
      // in DDR4, if PDA is occurring as requires it to count
      // pw_num_beats_cnt upto pw_num_beats_pda_m1_sel 
                if (!pw_num_beats_eq1
                    ) begin
                    pw_num_beats_cnt <= {{(PW_WORD_CNT_WD_MAX-1){1'b0}}, 1'b1}; // +1
                end else begin 
                    // ccx_line_begin: ; This line is related to data burst length. When BL16 (LP4/5), this line can not be reached. (This line will be covered at BL8 case). So this line is redundant for LP4/5 controller.
                    pw_num_beats_cnt <= {PW_WORD_CNT_WD_MAX{1'b0}};
                    // ccx_line_end
                end
            //ccx_cond: ; ; 11; If (|pw_num_beats_cnt) is true, pw_num_beats_cnt<pw_num_beats_m1_r never be true. pw_num_beats_cnt and pw_num_beats_m1_r are counted UP TO 1 in HW 1:4.
            end else if ((|pw_num_beats_cnt) && (pw_num_beats_cnt<pw_num_beats_m1_r)) begin
                // only increment if t_ccd_cnt is not active in DDR4
                // ccx_line_begin: ; Above if statement never be true and following lines can't be coverd.
                if ( !pw_num_beats_cnt_dis_ddr4_lpddr4 ) begin
                    pw_word_cnt      <= pw_word_cnt_next_non_first;
                    pw_num_beats_cnt <= pw_num_beats_cnt +  {{(PW_WORD_CNT_WD_MAX-1){1'b0}}, 1'b1}; // + 1
                end
                // ccx_line_end
            end else begin
                // only set to 0 if t_ccd_cnt is not active in DDR4
                if ( !pw_num_beats_cnt_dis_ddr4_lpddr4 ) begin
                    pw_num_beats_cnt <= {PW_WORD_CNT_WD_MAX{1'b0}};
                end
            end
        end
    end
    
    // signal generated and stored in WR_CAM itself
    wire [PW_NUM_DB_LOG2-1:0] ram_raddr_lsb_cnt_next;
    assign ram_raddr_lsb_cnt_next = ram_raddr_lsb_first;
    
    wire [PW_NUM_DB_LOG2-1:0] ram_raddr_lsb_cnt_next_r;
    
    assign ram_raddr_lsb_cnt_next_r = pw_word_cnt_next_non_first[PW_WORD_CNT_WD_FBW-1 -: PW_NUM_DB_LOG2] ;   
    
    wire [PW_NUM_DB_LOG2-1:0] ram_raddr_lsb_sel;
    // drive from stored value in WR_CAM ram_raddr_lsb_cnt_next (ram_raddr_lsb_first), if a new Write is occuring (new_ram_rd_cmd)
    // otherwise used generated value ram_raddr_lsb_cnt_next_r
    assign ram_raddr_lsb_sel = (new_ram_rd_cmd) ? ram_raddr_lsb_cnt_next : ram_raddr_lsb_cnt_next_r;
    //assign ram_raddr_lsb_sel = (~(|pw_num_beats_cnt)) ? ram_raddr_lsb_cnt_next : ram_raddr_lsb_cnt_next_r;

//-------------------------- ASSIGN OUTPUTS ------------------------------------
// full RAM read address
//=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+

assign mr_wu_raddr  =
                        mr_me_raddr_d1
                    ;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        mr_me_raddr_r   <= {WRDATA_RAM_ADDR_WIDTH{1'b0}};
        mr_me_raddr_d1  <= {WRDATA_RAM_ADDR_WIDTH{1'b0}};
    end
    else if(ddrc_cg_en) begin
        mr_me_raddr_r   <= {wr_ram_addr[WRCAM_ADDR_WIDTH-1:0], ram_raddr_lsb_sel };
        mr_me_raddr_d1  <= mr_me_raddr_r;
    end
end

    
    assign  word_count_add = 
               // Expecting LPDDR4 1:4 mode
                              5'b01000 << dh_mr_frequency_ratio;

//spyglass disable_block W164a
//SMD: LHS: 'inc_word_count' width 5 is less than RHS: '(word_count + word_count_add)' width 6 in assignment
//SJ: Overflow not possible
assign inc_word_count = word_count + word_count_add;
//spyglass enable_block W164a

//=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+


    // ram_rd_cmd
    assign new_ram_rd_cmd        = |(latency_timer_sel)  |
                                   use_te_input_unregistered;


    assign ram_rd_cmd = new_ram_rd_cmd 
                               || (((|pw_num_beats_cnt)) 
                                  && !pw_num_beats_cnt_dis_ddr4_lpddr4
                                  ); 
          



always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        mr_me_re        <= 1'b0;
        i_mr_me_re      <= 1'b0;
        mr_me_re_pipe   <= {WDATARAM_RD_LATENCY{1'b0}};
    end
    else if(ddrc_cg_en) begin
        mr_me_re        <= ram_rd_cmd
                        ;
        i_mr_me_re      <= ram_rd_cmd
                        ;
        mr_me_re_pipe[WDATARAM_RD_LATENCY-1]    <= i_mr_me_re;
    end
end

// resetable flops
always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
        word_count                  <= 5'b00000;
        ram_data_vld_r              <= 1'b0;
        upper_lane_pipe             <= '0;
        free_wr_entry_valid_d1      <= 1'b0;
        mr_yy_free_wr_entry_valid   <= 1'b0;
        pw_num_beats_m1_r           <= {PW_WORD_CNT_WD_MAX{1'b0}};
        mr_gs_empty_r               <= 1'b1;
        t_ccd_cnt                   <= {$bits(t_ccd_cnt){1'b0}};
    end
    else if(ddrc_cg_en) begin
        // increment at the start of a write; keep incrementing till
        //  word_count wraps back to zero
        word_count                  <= ram_rd_cmd ? inc_word_count : word_count;
        ram_data_vld_r              <= mr_me_re_pipe[0]; // WDATARAM_RD_LATENCY delayed
        upper_lane_pipe             <= {word_count[3], upper_lane_pipe[$bits(upper_lane_pipe)-1:1]};
        pw_num_beats_m1_r           <= (new_ram_rd_cmd) ? ( 
                                       pw_num_beats_m1) : pw_num_beats_m1_r;
                                   //ccx_cond_begin: ; ;10; pw_num_beats_eq1 signal is related to data burst length and this signal is always set to 0 when LP4/5 controller.
        free_wr_entry_valid_d1      <=
                                        ((new_ram_rd_cmd && (pw_num_beats_eq1)) ||
                                         (|pw_num_beats_m1_r && (pw_num_beats_cnt==pw_num_beats_m1_r)
                                         // do not free location as t_ccd_s is
                                         // being counted in DDR4
                                          && ( !pw_num_beats_cnt_dis_ddr4_lpddr4 )
                                         )
                                        )                    
                                   //ccx_cond_end
    
                                       ;
        mr_yy_free_wr_entry_valid   <= free_wr_entry_valid_d1;
               
        mr_gs_empty_r               <= &latency_timer_zero &
                                       (~(|pw_num_beats_cnt)) & 
                                       (~ram_rd_cmd) & (~int_wr_or_pda_w);
    
        if (new_ram_rd_cmd)
            t_ccd_cnt <= {{($bits(t_ccd_cnt)-1){1'b0}},1'b1};
        // FIXME: Evaluating new_ram_rd_cmd here is redundant as it's already evaluated.
        // ccx_cond: ; ; 01; This condition cannot be reached. new_ram_rd_cmd is already evaluated above. See bug 11948
        else if ((!new_ram_rd_cmd && !(|pw_num_beats_cnt)))
            t_ccd_cnt <= {$bits(t_ccd_cnt){1'b0}};
        else
            t_ccd_cnt <= t_ccd_cnt + {{($bits(t_ccd_cnt)-1){1'b0}},1'b1};
    end
end

assign mr_gs_empty = mr_gs_empty_r;



assign  ram_data_vld = ram_data_vld_r;
assign  ram_data_vld_early = mr_me_re_pipe[0]; // WDATARAM_RD_LATENCY delayed
// WDATARAM_RD_LATENCY+2 delayed
//   - command to WDATARAM read (1 cycle)
//   - WDATARAM_RD_LATENCY
//   - latch WDATARAM read data (1 cycle)
assign  ram_data_vld_upper_lane = upper_lane_pipe[0];




//-------------------------------------------------------------
// Latched SRAM read data
//-------------------------------------------------------------

reg [WDATA_PAR_WIDTH-1:0] mr_rdatapar_int;
//reg [CORE_DATA_WIDTH-1:0] mr_rdata_int;
reg [CORE_MASK_WIDTH-1:0] mr_rdatamask_int;
reg [WRSRAM_DATA_WIDTH-1:0] mr_rdata_int;
//reg [WRSRAM_MASK_WIDTH-1:0] mr_rdatamask_int;

always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
    // resetable flops
    if (~core_ddrc_rstn) begin
    //  mr_rdata_int          <= {CORE_DATA_WIDTH{1'b0}};
        mr_rdatamask_int      <= {CORE_MASK_WIDTH{1'b0}};
        mr_rdata_int          <= {WRSRAM_DATA_WIDTH{1'b0}};
    //  mr_rdatamask_int      <= {WRSRAM_MASK_WIDTH{1'b0}};
        mr_rdatapar_int       <= {WDATA_PAR_WIDTH{1'b0}};
    end
    else if(ddrc_cg_en) begin
        mr_rdata_int          <= me_mr_rdata;
        mr_rdatamask_int      <= me_mr_rdatamask;
        mr_rdatapar_int       <= me_mr_rdatapar;
    end
end

  // For LP4/5
  //
       assign mr_rdata     = mr_rdata_int;
       assign mr_rdatamask = mr_rdatamask_int;
      // Chopping ECC bits (1 bit for every byte)
      assign mr_rdatapar = mr_rdatapar_int[$bits(mr_rdatapar)-1:0];



assign mr_me_raddr = mr_me_raddr_r;



generate 
  if (OCECC_EN) begin: OCECC_en
  
  reg mr_me_re_r, ocecc_data_valid;
  
  always @(posedge co_yy_clk or negedge core_ddrc_rstn) begin
    if (~core_ddrc_rstn) begin
      mr_me_re_r <= 1'b0;
      ocecc_data_valid <= 1'b0;
    end
    else begin
      mr_me_re_r <= mr_me_re;
      ocecc_data_valid <= mr_me_re_r & ocecc_en;
    end
  end
  
  wire [CORE_DATA_WIDTH-1:0] ocecc_data_in;
  wire [WDATA_PAR_WIDTH-1:0] ocecc_ecc_in;
  
  wire [CORE_DATA_WIDTH-1:0] ocecc_corr_data_unused;
  
  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression '(gv * 5)' found in module 'mr_ram_rd_pipeline'
  //SJ: This coding style is acceptable and there is no plan to change it.
  genvar gv;
  for (gv=0; gv<CORE_MASK_WIDTH; gv=gv+1) begin: ecc_data_mask
    assign ocecc_data_in[gv*8+:8] = mr_rdatamask[gv] ? mr_rdata[gv*8+:8] : 8'h00;
    assign ocecc_ecc_in[gv*5+:5] = mr_rdatamask[gv] ? mr_rdatapar_int[gv*5+:5] : 5'h1F;
  end
  //spyglass enable_block SelfDeterminedExpr-ML
  
  ocecc_dec
  
    #(
       .DW      (CORE_DATA_WIDTH),
       .GRANU   (OCECC_MR_RD_GRANU),
       .EW      (WDATA_PAR_WIDTH)
    )
    echeck_mr_rd
    (
       .data_in       (ocecc_data_in),
       .ecc_in        (ocecc_ecc_in),
       .data_valid    (ocecc_data_valid),
       .fec_en        (1'b0), // not used
       .corr_err      (ocecc_mr_rd_corr_err),
       .uncorr_err    (ocecc_mr_rd_uncorr_err),
       .err_byte      (ocecc_mr_rd_byte_num),
       .corr_data     (ocecc_corr_data_unused) // not used
    );
    
  end
  else begin: OCECC_dis
    assign ocecc_mr_rd_corr_err = 0;
    assign ocecc_mr_rd_uncorr_err = 0;
    assign ocecc_mr_rd_byte_num = 0;
  end
endgenerate

// Write Data Phase info for PAS
    always @ (posedge co_yy_clk or negedge core_ddrc_rstn) begin
        // resetable flops
        if (~core_ddrc_rstn) begin
            wr_ph_pipe  <= '0;
        end else if(ddrc_cg_en) begin
            wr_ph_pipe  <= {wr_ph_ff, wr_ph_pipe[$bits(wr_ph_pipe)-1:2]}; // shift 2 bits
        end
    end
    // WDATARAM_RD_LATENCY+1 delayed
    //   - WDATARAM_RD_LATENCY
    //   - latch WDATARAM read data (1 cycle)
    assign wr_ph = wr_ph_pipe[1:0];

    assign int_wr_or_pda_w              = wr_or_pda_w;
    assign int_wr_ram_addr_w            = te_mr_wr_ram_addr;
    assign int_ram_raddr_lsb_first_w    = te_mr_ram_raddr_lsb_first;
    assign int_pw_num_beats_m1_w        = te_mr_pw_num_beats_m1;
    assign int_wr_word_valid_w          = te_pi_wr_word_valid;



endmodule  // mr_ram_rd_pipeline: RAM read pipeline
