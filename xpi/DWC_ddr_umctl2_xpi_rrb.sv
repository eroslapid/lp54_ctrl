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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_rrb.sv#1 $
// -------------------------------------------------------------------------
// Description:
//        Read Reorder Buffer
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_rrb
  #(
    parameter RDATARAM_DW   = 32,
    parameter INFOW         = 32,
    parameter RINFO_ADROFFST_LSB = 10,   
    parameter NTOKENS       = 32,
    parameter NBEATS        = 4,
    parameter NBEATS_LG2    = 2,  
    parameter NTOKENS_LG2   = `UMCTL_LOG2(NTOKENS),
    parameter BEAT_INFOW    = 4,
    parameter RRB_EXTRAM    = 0,
    parameter RDATARAM_AW   = 6,
    parameter PDBW_CASE     = 0,
    parameter A_BLW         = 4,
    parameter OCCAP_EN      = 0,
    parameter OCCAP_PIPELINE_EN = 0,
    parameter NUM_VIR_CH    = 2,
    parameter NUM_VIR_CH_LG2 = 1,
    parameter NUM_CH    = 2,
    parameter NUM_CH_LG2 = 1,
    parameter USE2RAQ    = 0,
    parameter READ_DATA_INTERLEAVE_EN  = 0,
    parameter STATIC_VIR_CH            = 0,
    parameter IDW = 8,
    parameter RPINFOW = 8,
    parameter INTLVMODEW = 2,
    parameter RRB_THRESHOLD_EN = 1,
    parameter RRB_THRESHOLD_PPL = 0,
    parameter BAM_OFFSW = 2,
    parameter MAXSIZE = 6,
    parameter AXI_MAXSIZE = 6,
    parameter M_DW = 32,
    parameter USE_BAM = 0,
    parameter RDATARAM_DEPTH = 0,
    parameter MIN_M_BL = 16, // 8 if DDR4_EN=1, otherwise 16
    parameter BRW = 4)
  
                               (
   input                                clk,          // clock
   input                                rst_n,        // asynchronous reset
   input                                wr,           // write
   input                                rd,           // read
   input [INFOW-1:0]                    infod,
   input                                rerror_d,
   input [NTOKENS_LG2-1:0]              wr_addr,
   input                                gen_token,
   input [NTOKENS_LG2-1:0]              atoken,
   input                                abypass_reorder,
   input [BRW-1:0]                      reg_ddrc_burst_rdwr,

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   // Use SBAM (Simplified BAM) for RRB enhancement
   input                                sbam_lead_burst,
   input                                sbam_second_burst,
   input [NTOKENS_LG2:0]                sbam_tokens_allocated,
//spyglass enable_block W240

//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                                bam_lead_burst,
   input                                bam_arlast,
   input [AXI_MAXSIZE-1:0]              bam_addr_offset,
   input                                bam_red_token,
   input                                bam_is_active,
   input [1:0]                          reg_ddrc_data_bus_width,
   input [RDATARAM_DW-1:0]              d,
   input                                rbypass_reorder,
//spyglass enable_block W240
   input [NUM_VIR_CH_LG2-1:0]           ch_num,
   input [A_BLW-1:0]                    a_bl,

   input [NUM_VIR_CH-1:0]               valid_dcr,

   input                                reg_ddrc_occap_en,

   output [RDATARAM_DW-1:0]             q,
   output [INFOW-1:0]                   infoq,
   output                               rerror_q,
   output                               empty,        // empty 
   output                               full,         // full
   output                               release_token,
   output [NTOKENS_LG2-1:0]             rtoken,
   output                               rd_last,
   output [NUM_CH_LG2-1:0]              q_ch_num,
   output  [NUM_VIR_CH-1:0]             vtq_empty,
   output [NTOKENS_LG2-1:0]             dcr_token,

   output                               xpi_rrb_parity_err,
   // External read data RAM interface
   output [RDATARAM_AW-1:0]             rdataram_raddr,
   output [RDATARAM_AW-1:0]             rdataram_waddr,
   // Outputs to xpi_tm
   output                               locked_ch_raq_red,
   output                               rrb_is_locked,
   output [NUM_CH_LG2-1:0]              locked_ch
   );
  
 
  localparam RAM_DEPTH = RDATARAM_DEPTH;
  localparam RAM_ADDR_WIDTH = `UMCTL_LOG2(RAM_DEPTH); 
 
  localparam SEL_CH0  = {{NUM_VIR_CH{1'b0}},1'b1};

  // Lock arbiter state machine encodings
  // lock arbiter is used to prevent interleaving when down-sizing
  localparam LOCK_RRB_STATEW  = 1;
  localparam IDLE             = 1'b0;  
  localparam LOCK             = 1'b1;  

  localparam NTOKENS_M2    = NTOKENS-2;
  localparam NTOKENS_M2_LG2 = `UMCTL_LOG2(NTOKENS_M2);

  localparam MCH_VALID_W = NUM_CH_LG2+NUM_CH+LOCK_RRB_STATEW;

  localparam OCCAP_WIDTH = NBEATS_LG2 +         // wr_beat_count
                           NBEATS_LG2           // rd_beat_count
                           ;
   localparam SL_W = 8;
   localparam PARW = ((OCCAP_WIDTH%SL_W>0) ? OCCAP_WIDTH/SL_W+1 : OCCAP_WIDTH/SL_W);

   localparam integer M_DW_HBW =  (M_DW > 8)  ? M_DW/2  : M_DW;
   localparam integer M_DW_QBW =  (M_DW > 16) ? M_DW/4  : M_DW_HBW ;
   localparam integer M_CR_LG2_FBW = $clog2(M_DW/M_DW_QBW ); 
   localparam integer M_CR_LG2_HBW = $clog2(M_DW_HBW/M_DW_QBW); 
   localparam integer M_CR_LG2_QBW = 0; 

  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  wire [INFOW-1:0]                      info_mem [0 : NTOKENS-1];   
  wire [NTOKENS-1:0]                    info_wr, info_mem_parity_err;
  wire                                  xpi_rrb_info_mem_parity_err;
  wire                                  mch_valid_par_err, valid_beat_par_err, release_token_par_err;

  reg [NTOKENS*NBEATS-1:0]              valid_beat_next;
  wire [NTOKENS*NBEATS-1:0]             valid_beat_reg;
  
  reg [NBEATS_LG2-1:0]                  wr_beat_count; 
  reg [NBEATS_LG2-1:0]                  wr_beat_count_nxt; 
  reg [NBEATS_LG2-1:0]                  rd_beat_count;
  reg [NBEATS_LG2-1:0]                  rd_beat_count_nxt; 
 
  wire [NUM_VIR_CH-1:0]                 vtq_rd;
  wire                                  vtq_full_unused;

  
  wire                                  btq_full,btq_empty;  
  wire [NTOKENS_LG2-1:0]                rd_addr;  
  wire                                  wr_first;
  wire                                  wr_last;
  
  wire [NTOKENS_LG2-1:0]                vtq_token [NUM_VIR_CH-1:0];
  wire [NTOKENS_LG2-1:0]                btq_token;
  wire [NUM_VIR_CH-1:0]                 vtq_valid;
  wire [NUM_CH-1:0]                     valid_arb;      
  wire [NUM_VIR_CH-1:0]                 vtq_valid_arb;
  wire                                  btq_valid;
  wire                                  btq_valid_arb;   

  reg                                   lock_rrb;
  wire [NBEATS_LG2-1:0]                 rd_beat_addr;
  wire                                  rlast;
  wire [INTLVMODEW-1:0]                 rd_interleave_mode_unused;
  wire [INTLVMODEW-1:0]                 wr_interleave_mode;
  wire [NBEATS_LG2-1:0]                 rd_beat_start_unused;
  wire [NBEATS_LG2-1:0]                 rd_beat_end;  
  wire [NBEATS_LG2-1:0]                 wr_beat_start;
  wire [NBEATS_LG2-1:0]                 wr_beat_end_unused;
  // This is a shift register to delay the release token pulse to xpi_tm
  // until all beats are acccepted by RRB
  wire                                  release_token_l;
  wire [NTOKENS_LG2-1:0]                arb_token;
  wire [NTOKENS-1:0]                    valid_burst;
  wire [NUM_VIR_CH*NTOKENS_LG2-1:0]     vtq_token_table;
  wire [NUM_CH*NTOKENS_LG2-1:0]         token_table;
  wire [NUM_CH_LG2-1:0]                 arb_ch;

  wire                                  occap_xpi_rrb_btq_par_err;
  wire                                  xpi_rrb_vtq_par_err;
  wire                                  occap_xpi_rrb_ram_err;
  wire                                  occap_xpi_rrb_rerror_ram_err;
  wire                                  occap_xpi_rrb_par_err; // for internal registers unique o rrb
  reg  [LOCK_RRB_STATEW-1:0]            lock_rrb_state_next;
  wire [LOCK_RRB_STATEW-1:0]            lock_rrb_state_reg;
  wire                                  occap_par_poison_en = 1'b0; // poison always disabled for these registers
  wire                                  burst_rdwr_gt_min_bl;
  wire                                  ch_raq_table_par_err;

  //---------------------------------------------------------------------------
  // RAM 
  //---------------------------------------------------------------------------
  
  wire [RAM_ADDR_WIDTH-1:0]             ram_wr_addr;
  wire [RAM_ADDR_WIDTH-1:0]             ram_rd_addr;
  wire [NBEATS_LG2-1:0]                 wr_beat_addr;
  wire [BEAT_INFOW-1:0]                 rd_beat_info;
  wire [BEAT_INFOW-1:0]                 wr_beat_info;  
 
  integer i; // for loop index
  integer j; // for loop index

  typedef struct packed {
    reg [NTOKENS_LG2-1:0] start_token       ; // Indicate the start token for this token.
    reg [NTOKENS_LG2:0]   tokens_allocated  ; // Indicate how many tokens are led by this start token.
    reg [NTOKENS_LG2:0]   tokens_received   ; // Indicate how many bursts received belonging this RID transaction.
    reg                   entry_valid       ; //
  } sbam_t;

  sbam_t sbam[NTOKENS];

  typedef struct packed {
    reg [NTOKENS_LG2-1:0] start_token;
    reg [(2**BAM_OFFSW)-1:0] beat_seg_valid;
  } bam_t;
  
  bam_t bam[NTOKENS];

  genvar gv;

  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression '(gv * NBEATS)' found in module 'DWC_ddr_umctl2_xpi_rrb'
  //SJ: This coding style is acceptable and there is no plan to change it.
  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block
  generate
    for(gv=0;gv<NTOKENS;gv=gv+1)  begin:valid_burst_gen
       assign valid_burst[gv] = valid_beat_reg[gv*NBEATS];
    end
  endgenerate
  //spyglass enable_block W528 

logic                 lock_on_lead_bam;
logic                 bam_rrb_locked;
//spyglass disable_block W528
//SMD: Variable 'burst_rdwr_gt_min_bl' set but not read
//SJ: burst_rdwr_gt_min_bl will not be read if USE_BAM=0
assign burst_rdwr_gt_min_bl = (reg_ddrc_burst_rdwr > (MIN_M_BL>>1)) ? 1'b1 : 1'b0;
//spyglass enable_block W528 

generate
if (READ_DATA_INTERLEAVE_EN==0 & USE2RAQ==1) begin : DUAL_RAQ_NO_RDI
  logic [NUM_CH-1:0] ch_raq_table_nxt;
  logic [NUM_CH-1:0] ch_raq_table_reg;
  // ch_raq_table_reg stores the RAQ information of last written token to each VTQ
  // This logic is used only when Dual RAQ and no Read data interleaving is selected.
  // In this table index is channel number and entry is RAQ info. 0: Blue RAQ, 1: Red RAQ
  always @ (*) begin : ch_raq_table_nxt_gen_comb
    ch_raq_table_nxt = ch_raq_table_reg;
    for(int i=0;i<NUM_CH;i=i+1)  begin
// spyglass disable_block W415a
// SMD: Signal ch_raq_table_nxt[*] is being assigned multiple times ( previous assignment at line [CulpritLineNumber] ) in same always block
// SJ: This is accepted coding style. Signal is initialized first, and then updated inside if condition.
      if (gen_token & bam_red_token & (ch_num==i)) begin
        ch_raq_table_nxt[i] = 1'b1;
      end else if (gen_token & ~bam_red_token & (ch_num==i)) begin
        ch_raq_table_nxt[i] = 1'b0;
      end
// spyglass enable_block W415a
    end
  end
  
  DWC_ddr_umctl2_par_reg
  
  #(
     .DW      (NUM_CH),
     .OCCAP   (OCCAP_EN),
     .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)
  )
  U_ch_raq_table_reg
  (
     .clk        (clk),
     .rst_n      (rst_n),
     .data_in    (ch_raq_table_nxt),
     .reg_set    (1'b0),
     .parity_en  (reg_ddrc_occap_en),
     .poison_en  (1'b0),
     .data_out   (ch_raq_table_reg),
     .parity_err (ch_raq_table_par_err)
  );
  
  // The currently locked channel's RAQ information is given out to xpi_tm
  // xpi_tm uses this info only in Dual RAQ & no read data interleave configs.
  assign locked_ch_raq_red = ch_raq_table_reg[arb_ch];
end else begin : n_DUAL_RAQ_NO_RDI
  assign locked_ch_raq_red = 1'b0;
  assign ch_raq_table_par_err = 1'b0;
end
endgenerate

genvar tid;
 generate
 if (USE_BAM == 1) begin : USEBAM
  //BAM Data structure is needed   
    wire [MAXSIZE-1:0]   bam_wr1_addr_offset;
    wire [BAM_OFFSW-1:0] beat_seg_sel_wr0,beat_seg_sel_nxt_wr0,beat_seg_sel_wr1;
    wire [BAM_OFFSW-1:0] nxt_offst;
    wire [BAM_OFFSW-1:0] max_offst;
    wire [BAM_OFFSW:0]   shift;
    wire [NTOKENS_LG2-1:0] linked_lead_burst;

    assign shift = (reg_ddrc_data_bus_width==2'b10 ? M_CR_LG2_QBW : reg_ddrc_data_bus_width==2'b01 ? M_CR_LG2_HBW : M_CR_LG2_FBW) + burst_rdwr_gt_min_bl;
    assign beat_seg_sel_wr0 = bam_addr_offset[AXI_MAXSIZE-1 -: BAM_OFFSW] >> shift; 
    assign beat_seg_sel_nxt_wr0 = beat_seg_sel_wr0 + 1'b1;
    assign max_offst = {BAM_OFFSW{1'b1}} >> shift;
    assign bam_wr1_addr_offset = infod[RINFO_ADROFFST_LSB +: MAXSIZE];
    assign beat_seg_sel_wr1 = bam_wr1_addr_offset[AXI_MAXSIZE-1 -: BAM_OFFSW] >> shift;
    assign linked_lead_burst = bam[wr_addr].start_token;
    assign lock_on_lead_bam = bam_is_active & (bam[arb_token].start_token==arb_token); //FIXME - optimize by adding lead/non-lead BAM field
    logic [NTOKENS_LG2-1:0] curr_start_token,curr_start_token_blue,curr_start_token_red;

    always @ (posedge clk or negedge rst_n) begin : CURR_STRT_TOKEN_BLUE
       if(rst_n==1'b0) 
         curr_start_token_blue <= {NTOKENS_LG2{1'b1}};
       else if (bam_lead_burst && gen_token && (!bam_red_token))
//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop DWC_ddrctl.U_arb_top.\arb_port[4].U_xpi .\Dual_DCH_RRB.U_xpi_rrb .\USEBAM.curr_start_token_blue [0] (master RTL_FDPE) is  always disabled (tied low)
//SJ: BAM is not supported in DCH configs. 2nd RRB's bam related inputs are tied to fixed values.
         curr_start_token_blue <= atoken;
//spyglass enable_block FlopEConst
    end

   //Always block is needed only whe USE2RAQ is set to 1
   //optimized in other configurations since bam_red_token is always 0
    always @ (posedge clk or negedge rst_n) begin : CURR_STRT_TOKEN_RED
       if(rst_n==1'b0) 
         curr_start_token_red <= {NTOKENS_LG2{1'b1}};
       else if (bam_lead_burst & gen_token & bam_red_token)
//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop DWC_ddrctl.U_arb_top.\arb_port[4].U_xpi .\Dual_DCH_RRB.U_xpi_rrb .\USEBAM.curr_start_token_red [0] (master RTL_FDPE) is  always disabled (tied low)
//SJ: BAM is not supported in DCH configs. 2nd RRB's bam related inputs are tied to fixed values.
         curr_start_token_red <= atoken;
//spyglass enable_block FlopEConst
    end    

   //Used for Non-lead bursts
   //Used to link a Non-lead burst with its lead burst
   //In USE2RAQ a sense of red/blue is considered
    assign curr_start_token = bam_red_token ? curr_start_token_red : curr_start_token_blue; 

    always @ (posedge clk or negedge rst_n) begin : BAM_RRB_LOCKED 
       if(rst_n==1'b0) 
         bam_rrb_locked <= 1'b0;
       else if (lock_rrb_state_next == IDLE) 
         bam_rrb_locked <= 1'b0;
       else if (lock_on_lead_bam && (lock_rrb_state_next == LOCK) )
         bam_rrb_locked <=  1'b1 ;
    end
  
    for(tid=0;tid<NTOKENS;tid=tid+1)  begin:BAM_STRUCT
      always @ (posedge clk or negedge rst_n) begin : BAM_ENTRY_STARTID
        if(rst_n==1'b0) begin
          bam[tid].start_token <= {NTOKENS_LG2{1'b0}};
        end else if (gen_token && tid==atoken) begin
           if(bam_lead_burst) 
             bam[tid].start_token <= atoken;
           else   
             bam[tid].start_token <= curr_start_token;
        end
      end //BAM_ENTRY_STARTID

      always @ (posedge clk or negedge rst_n) begin : BAM_ENTRY_BEATSEG
         if(rst_n==1'b0) 
           bam[tid].beat_seg_valid <= {(2**BAM_OFFSW){1'b1}};
         else begin
            if (wr && tid==linked_lead_burst) // data arrvies for an entry, set its lead burst's seg as valid
              bam[tid].beat_seg_valid[beat_seg_sel_wr1] <= 1'b1;
            else if(gen_token && tid==atoken && bam_lead_burst) begin  // when lead burst arrives, lead burst seg entry set to 0
              bam[tid].beat_seg_valid[beat_seg_sel_wr0] <= 1'b0;
              if(beat_seg_sel_wr0!=max_offst && !bam_arlast && bam_is_active  ) //predict that there is atleaset 1 more related token
                bam[tid].beat_seg_valid[beat_seg_sel_nxt_wr0] <= 1'b0;
            end 
            else if(gen_token && tid==atoken && ~bam_lead_burst) // when non-lead burst arrives, non-lead entry set to 1  
              bam[tid].beat_seg_valid[beat_seg_sel_wr0] <= 1'b1;
            else if (gen_token && tid == curr_start_token && ~bam_lead_burst) begin      // when non-lead arrvives, lead burst seg entry set to 0
              bam[tid].beat_seg_valid[beat_seg_sel_wr0] <= 1'b0;  
              if(beat_seg_sel_wr0!=max_offst && !bam_arlast ) //predict that there is atleaset 1 more related token
                bam[tid].beat_seg_valid[beat_seg_sel_nxt_wr0] <= 1'b0;
            end
        end      
      end // BAM_ENTRY_BEATSEG
    end //for tid
 end else  begin : NOBAM
  //BAM Data structure is not needed 
  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block
   assign  lock_on_lead_bam = 1'b0;
   assign  bam_rrb_locked = 1'b0;
  //spyglass enable_block W528 
 end
 endgenerate

  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block
  logic                   lock_on_lead_sbam                       ;

  if (RRB_THRESHOLD_EN == 0) begin : NO_RRB_THRESHOLD_EN_GEN
    assign lock_on_lead_sbam = 1'b0;
  end // NO_RRB_THRESHOLD_EN_GEN
  //spyglass enable_block W528 

genvar token_index;
generate
  if (RRB_THRESHOLD_EN == 1) begin : RRB_THRESHOLD_EN_GEN
    logic [NTOKENS_LG2-1:0] curr_start_token                        ;
    logic [NTOKENS_LG2-1:0] curr_start_token_blue                   ;
    logic [NTOKENS_LG2-1:0] curr_start_token_red                    ;

    // curr_tokens_allocated width should be NTOKENS_LG2+1 rather than NTOKENS_LG2,
    // e.g. one WRAP converts to two INCR, each INCR consumes NTOKENS/2
    // overflow should be avoided
    logic [NTOKENS_LG2:0]   curr_tokens_allocated                   ; // values to be put in sbam_t
    logic [NTOKENS_LG2:0]   curr_tokens_allocated_blue              ; // values to be put in sbam_t
    logic [NTOKENS_LG2:0]   curr_tokens_allocated_red               ; // values to be put in sbam_t
    logic [NTOKENS_LG2:0]   curr_tokens_filled                      ; // count how many tokens are filled into sbam_t
    logic [NTOKENS_LG2:0]   curr_tokens_filled_blue                 ; // count how many tokens are filled into sbam_t
    logic [NTOKENS_LG2:0]   curr_tokens_filled_red                  ; // count how many tokens are filled into sbam_t

    //spyglass disable_block W528
    //SMD: A signal or variable is set but never read
    //SJ: Used in generate block, here for set in RRB_THRESHOLD_EN == 1 but NUM_CH==1 case.
    assign lock_on_lead_sbam = (sbam[arb_token].start_token == arb_token) && (sbam[arb_token].tokens_allocated == sbam[arb_token].tokens_received);
    //spyglass enable_block W528 

    always @ (posedge clk or negedge rst_n) begin : CURR_START_TOKEN_BLUE
      if(rst_n == 1'b0)
        curr_start_token_blue <= {NTOKENS_LG2{1'b1}};
      else if(sbam_lead_burst && gen_token && ~bam_red_token)
        curr_start_token_blue <= atoken;
    end // CURR_START_TOKEN_BLUE

    always @ (posedge clk or negedge rst_n) begin : CURR_START_TOKEN_RED
      if(rst_n == 1'b0)
        curr_start_token_red <= {NTOKENS_LG2{1'b1}};
      else if(sbam_lead_burst && gen_token && bam_red_token)
//spyglass disable_block FlopEConst
//SMD: Enable pin EN on Flop DWC_ddrctl.U_arb_top.\arb_port[0].U_xpi .U_xpi_rrb.\RRB_THRESHOLD_EN_GEN.curr_start_token_red [0] (master RTL_FDPE) is always disabled (tied low)(connected to DWC_ddrctl.U_arb_top.\arb_port[0].U_xpi .dcm_bam_red_token)
//SJ: bam_red_token is tied to 0 in single RAQ configs. This is expected
        curr_start_token_red <= atoken;
//spyglass enable_block FlopEConst
    end // CURR_START_TOKEN_RED

    assign curr_start_token = bam_red_token? curr_start_token_red : curr_start_token_blue; // to be developed with USE2RAQ and introduce curr_start_token_red

    always @ (posedge clk or negedge rst_n) begin : CURR_TOKENS_ALLOCATED
      if(rst_n == 1'b0)
        curr_tokens_allocated_blue <= {(NTOKENS_LG2+1){1'b0}};
      else if(sbam_lead_burst && gen_token && ~bam_red_token)
        // to be developed with USE2RAQ and introduce sbam_red_token, curr_tokens_allocated_blue, curr_tokens_allocated_red indicator
        curr_tokens_allocated_blue <= sbam_tokens_allocated;
      else if(sbam_second_burst && gen_token && ~bam_red_token)
        //spyglass disable_block W164a
        //SMD: LHS: 'curr_tokens_allocated_blue' width e.g. 7 is less than RHS: 'curr_tokens_allocated_blue + {1'b0,sbam_tokens_allocated}' width e.g. 8 in assignment
        //SJ: Overflow will never happen.
        curr_tokens_allocated_blue <= curr_tokens_allocated_blue + sbam_tokens_allocated;
        //spyglass enable_block W164a
    end // CURR_TOKENS_ALLOCATED

    always @ (posedge clk or negedge rst_n) begin : CURR_TOKENS_ALLOCATED_RED
      if(rst_n == 1'b0)
        curr_tokens_allocated_red <= {(NTOKENS_LG2+1){1'b0}};
      else if(sbam_lead_burst && gen_token && bam_red_token)
        // to be developed with USE2RAQ and introduce sbam_red_token, curr_tokens_allocated_blue, curr_tokens_allocated_red indicator
        curr_tokens_allocated_red <= sbam_tokens_allocated;
      else if(sbam_second_burst && gen_token && bam_red_token)
        //spyglass disable_block W164a
        //SMD: LHS: 'curr_tokens_allocated_red' width e.g. 7 is less than RHS: 'curr_tokens_allocated_red + {1'b0,sbam_tokens_allocated}' width e.g. 8 in assignment
        //SJ: Overflow will never happen.
        curr_tokens_allocated_red <= curr_tokens_allocated_red + sbam_tokens_allocated;
        //spyglass enable_block W164a
    end // CURR_TOKENS_ALLOCATED_RED

    assign curr_tokens_allocated = bam_red_token? curr_tokens_allocated_red : curr_tokens_allocated_blue;

    always @ (posedge clk or negedge rst_n) begin : CURR_TOKENS_FILLED
      if(rst_n == 1'b0)
        curr_tokens_filled_blue <= {(NTOKENS_LG2+1){1'b0}};
      else if(sbam_lead_burst && gen_token && ~bam_red_token)
        // to be developed with USE2RAQ and introduce sbam_red_token, curr_tokens_filled_blue, curr_tokens_filled_red indicator
        curr_tokens_filled_blue <= {{(NTOKENS_LG2){1'b0}},1'b1};
      else if(gen_token && (curr_tokens_filled_blue < curr_tokens_allocated_blue) && ~bam_red_token)
        curr_tokens_filled_blue <= curr_tokens_filled_blue + 1'b1;
    end // CURR_TOKENS_FILLED

    always @ (posedge clk or negedge rst_n) begin : CURR_TOKENS_FILLED_RED
      if(rst_n == 1'b0)
        curr_tokens_filled_red <= {(NTOKENS_LG2+1){1'b0}};
      else if(sbam_lead_burst && gen_token && bam_red_token)
        // to be developed with USE2RAQ and introduce sbam_red_token, curr_tokens_filled_blue, curr_tokens_filled_red indicator
        curr_tokens_filled_red <= {{(NTOKENS_LG2){1'b0}},1'b1};
      else if(gen_token && (curr_tokens_filled_red < curr_tokens_allocated_red) && bam_red_token)
        curr_tokens_filled_red <= curr_tokens_filled_red + 1'b1;
    end // CURR_TOKENS_FILLED_RED

    assign curr_tokens_filled = bam_red_token? curr_tokens_filled_red : curr_tokens_filled_blue;

    for(token_index = 0; token_index < NTOKENS; token_index = token_index + 1) begin : SBAM_STRUCT_START_TOKEN
      always @ (posedge clk or negedge rst_n) begin : SBAM_ENTRY_START_TOKEN
        if(rst_n == 1'b0) begin
          sbam[token_index].start_token <= {NTOKENS_LG2{1'b0}};
        end else if(gen_token && token_index == atoken) begin
          if(sbam_lead_burst)
            sbam[token_index].start_token <= atoken;
          else if(curr_tokens_filled < curr_tokens_allocated)
            // fill the header tokens with limited number (curr_tokens_allocated), to avoid overlap on start token
            // no need to take care of sbam_second_burst as they own the same start token.
            sbam[token_index].start_token <= curr_start_token;
        end
      end // SBAM_ENTRY_START_TOKEN

      always @ (posedge clk or negedge rst_n) begin : SBAM_ENTRY_TOKENS_ALLOCATED
        if(rst_n == 1'b0) begin
            sbam[token_index].tokens_allocated <= {(NTOKENS_LG2+1){1'b0}};
        end else begin
          if(gen_token && token_index == atoken) begin
            // lead token is generated, hence update its tokens_allocated field
            if(sbam_lead_burst) begin
              sbam[token_index].tokens_allocated <= sbam_tokens_allocated;
            end
          end else if(gen_token && (sbam[token_index].start_token == curr_start_token) && sbam_second_burst) begin
            // update existing allocated tokens due to the WRAP second burst
            //spyglass disable_block W164a
            //SMD: LHS: 'tokens_allocated' width e.g. 7 is less than RHS: 'curr_tokens_allocated + sbam_tokens_allocated' width e.g. 8 in assignment
            //SJ: Overflow will never happen.
            sbam[token_index].tokens_allocated <= curr_tokens_allocated + sbam_tokens_allocated;
            //spyglass enable_block W164a
          end
        end
      end // SBAM_ENTRY_TOKENS_ALLOCATED


      always @ (posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            sbam[token_index].entry_valid <= 1'b0;
        end else begin
          // entry_valid indicates that if that SBAM entry has valid data or not.
          // entry_valid will be set for the first curr_tokens_allocated number of tokens of an AXI read.
          // For the remaining tokens it is 0.
          if(gen_token && (token_index == atoken) && ((curr_tokens_allocated > curr_tokens_filled) || sbam_lead_burst)) begin
            sbam[token_index].entry_valid <= 1'b1;
          end else if (wr && token_index == wr_addr) begin
            // When a token is returned from DDRC, entry valid is cleared in the next cycle.
            sbam[token_index].entry_valid <= 1'b0;
          end
        end
      end

      always @ (posedge clk or negedge rst_n) begin : SBAM_ENTRY_TOKENS_RECEIVED
        if(rst_n == 1'b0) begin
            sbam[token_index].tokens_received <= {(NTOKENS_LG2+1){1'b0}};
        end else begin
          if(gen_token && token_index == atoken) begin
            // Set the tokens_received field to zero when a token is generated.
            sbam[token_index].tokens_received <= {NTOKENS_LG2{1'b0}};
          end else if(wr && (token_index == sbam[wr_addr].start_token) && (sbam[wr_addr].entry_valid == 1'b1) && (sbam[token_index].tokens_received < sbam[token_index].tokens_allocated)) begin
            // Whenever a token is returned from DDRC, and if that token entry is valid in SBAM, increment the tokens_received field of the lead burst entry in SBAM.
            // entry_valid is cleared after a token is returned. For the second wr in a burst tokens_received will not be incremented.
            sbam[token_index].tokens_received <= sbam[sbam[wr_addr].start_token].tokens_received + 1'b1;
          end
        end
      end // SBAM_ENTRY_TOKENS_RECEIVED

      `ifdef SNPS_ASSERT_ON
        `ifndef SYNTHESIS
        if(NUM_CH > 1) begin
          // assertions to check sbam_t for RRB SBAM enhancement

          // in a sbam cell, if its tokens_allocated changed from a non-zero value to zero value, the tokens_received must be zero then.
          // (Pop-out self-clear check)
          property p_sbam_self_check_0;
            @(posedge clk) disable iff(!rst_n)
              // {d,4,4} -> {d,0,0}, forbidden for {d,0,4}
              (sbam[token_index].tokens_allocated != 0) && (sbam[token_index].tokens_received != 0) ##1 (sbam[token_index].tokens_allocated == 0) |-> (sbam[token_index].tokens_received == 0);
          endproperty
           
          // in a sbam cell, if its tokens_allocated changed from a non-zero value to zero value, the tokens_allocated must be zero then.
          // (Pop-out self-clear check)
          property p_sbam_self_check_1;
            @(posedge clk) disable iff(!rst_n)
              // {d,4,4} -> {d,0,0}, forbidden for {d,4,0}
              (sbam[token_index].tokens_allocated != 0) && (sbam[token_index].tokens_received != 0) ##1 (sbam[token_index].tokens_received == 0) |-> (sbam[token_index].tokens_allocated == 0);
          endproperty

          // in a sbam cell, if tokens_allocated is zero, the tokens_received must be zero.
          // (tokens_allocated == 0, means sbam[token_index] is invalid.)
          property p_sbam_self_check_2;
            @(posedge clk) disable iff(!rst_n)
              // {d,0,4} forbidden
              (sbam[token_index].tokens_allocated == 0) |-> (sbam[token_index].tokens_received == 0);
          endproperty

          // in a sbam cell, the tokens_received will never exceed the value in tokens_allocated.
          property p_sbam_self_check_3;
            @(posedge clk) disable iff(!rst_n)
              // {d,4,6} forbidden
              (sbam[token_index].tokens_allocated != 0) |-> (sbam[token_index].tokens_received <= sbam[token_index].tokens_allocated);
          endproperty

          reg [NTOKENS_LG2:0] sva_reg_sbam_self_check_4;
          always @ (posedge clk or negedge rst_n)
            if(~rst_n)
              sva_reg_sbam_self_check_4 <= {(NTOKENS_LG2+1){1'b0}};
            else
              sva_reg_sbam_self_check_4 <= sbam[token_index].tokens_allocated;
  
          // if the tokens_allocated value changed from a non-zero value, it must be pop-out and tokens_allocated and tokens_received must be zero then.
          // no other case except sbam_second_burst to update the tokens_allocated 
          property p_sbam_self_check_4;
            @(posedge clk) disable iff(!rst_n)
              // {d,4,x} not allowed to change to {d,2,x}, only allowed to {d,0,0}
              ~sbam_second_burst ##1 (sva_reg_sbam_self_check_4 != 0) && (sbam[token_index].tokens_allocated != sva_reg_sbam_self_check_4) |-> ((sbam[token_index].tokens_received == 0) && (sbam[token_index].tokens_allocated == 0));
          endproperty

          // if it's not fully received, this sbam cell can not be popped out.
          property p_sbam_self_check_5;
            @(posedge clk) disable iff(!rst_n)
              // {d,3,1} not allowed to change to {d,0,x}
              (sbam[token_index].tokens_allocated != 0) && (sbam[token_index].tokens_received < sbam[token_index].tokens_allocated) |-> ##1 (sbam[token_index].tokens_allocated != 0);
          endproperty

          a_sbam_self_check_0: assert property (p_sbam_self_check_0);
          //a_sbam_self_check_1: assert property (p_sbam_self_check_1);
          a_sbam_self_check_2: assert property (p_sbam_self_check_2);
          a_sbam_self_check_3: assert property (p_sbam_self_check_3);
          //a_sbam_self_check_4: assert property (p_sbam_self_check_4);
          a_sbam_self_check_5: assert property (p_sbam_self_check_5);
        end

        `endif // SYNTHESIS
      `endif // SNPS_ASSERT_ON
    end

  end // RRB_THRESHOLD_EN_GEN
endgenerate

  wire [NUM_CH-1:0]  tq_valid;

  assign empty       = ~tq_valid[arb_ch];
  assign full        = &valid_beat_reg;
  assign infoq       = info_mem[rd_addr];
  assign rd_addr     = arb_token;
  assign dcr_token   = arb_token;

  //spyglass disable_block W528
  //SMD: A signal or variable is set but never read
  //SJ: Used in generate block
  assign wr_first    = (wr_beat_count == {NBEATS_LG2{1'b0}}) ? 1'b1:1'b0;
  //spyglass enable_block W528 
   
  assign rd_last           = (rd_beat_count == rd_beat_end)  ? 1'b1:1'b0;
  assign q_ch_num          = arb_ch;
  assign wr_last           = (wr_beat_count == a_bl-1) ? 1'b1:1'b0;  
  assign release_token_l   = rd & ~empty & rd_last;  

  //spyglass enable_block SelfDeterminedExpr-ML

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (NTOKENS_LG2+1),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN(OCCAP_PIPELINE_EN)
   )
   U_release_token
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    ({release_token_l,arb_token}),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   ({release_token,rtoken}),
      .parity_err (release_token_par_err)
   );
  
  //---------------------------------------------------------------------------
  // VTQ BTQ Arbitration  
  //---------------------------------------------------------------------------
   //select_net_lite can be instantiated with minimum of 8 input requests. 
   //Also only power of 2 inputs can be supported  
   localparam NUM_CH_P2= (NUM_CH>32) ? 64:
                         (NUM_CH>16) ? 32:
                         (NUM_CH>8) ? 16:
                         (NUM_CH>4) ? 8:
                         (NUM_CH>2) ? 4:
                         (NUM_CH>1) ? 4:NUM_CH;
   
   localparam NUM_CH_P2_LG2 = `UMCTL_LOG2(NUM_CH_P2);
   
   wire arb_selected_vld_unused;

   wire [NUM_CH_P2*NTOKENS_LG2-1:0] token_table_p2;
   wire [NUM_CH_P2-1:0]             valid_arb_p2;
   wire [NUM_CH-1:0]                valid_arb_next;

   generate 
      if (NUM_CH_P2>NUM_CH && NUM_CH!=1)begin: NUM_CH_IS_NP2 // number of channels is non power of 2, padding zeros
         assign  token_table_p2 = {{((NUM_CH_P2-NUM_CH)*NTOKENS_LG2){1'b0}},token_table};
         assign  valid_arb_p2 = {{(NUM_CH_P2-NUM_CH){1'b0}},valid_arb_next};
      end
      if (NUM_CH_P2==NUM_CH && NUM_CH!=1) begin:NUM_CH_IS_P2  // number of channels is power of 2
         assign  token_table_p2 = token_table;
         assign  valid_arb_p2 = valid_arb_next;
      end
   endgenerate

   generate 
   if (NUM_CH==1) begin: SINGLE_CH
      assign arb_token                = token_table[NTOKENS_LG2-1:0];
      assign arb_selected_vld_unused  = valid_arb[0];
      assign arb_ch                   = 1'b0;
      assign mch_valid_par_err        = 1'b0;
      assign rrb_is_locked            = 1'b1; // Just to supress Spy warnings
      assign locked_ch                = 1'b0; // Just to supress Spy warnings
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: This is not read if USE_BAM=0
      assign lock_rrb_state_next      = LOCK; // Just to supress Spy warnings
//spyglass enable_block W528
   end 
   else begin: MULTI_CH     
      wire [NUM_CH_P2_LG2-1:0]         arb_ch_p2;
      wire [NUM_CH_P2_LG2-1:0]         wall_next_p2;
      wire [NUM_CH_LG2-1:0]            wall_next;
      wire [NUM_CH_LG2-1:0]            wall_reg;   
      reg                              update_wall_next;     
      wire [NUM_CH-1:0]                valid_arb_reg;

      if (NUM_CH_P2_LG2==NUM_CH_LG2) begin: wall_next_p2_1
         assign wall_next_p2 = wall_next;
      end
      else begin: wall_next_p2_2
         assign wall_next_p2 = {{(NUM_CH_P2_LG2-NUM_CH_LG2){1'b0}},wall_next};
      end

      assign arb_ch           = arb_ch_p2[NUM_CH_LG2-1:0];
      // Currently locked channel info
      assign locked_ch        = arb_ch;
      assign valid_arb_next   = lock_rrb ? valid_arb_reg :valid_arb;
      assign wall_next        = update_wall_next ? wall_reg+1:wall_reg;
   
      select_net_lite
      
      #(
         .TAG_BITS(NTOKENS_LG2),
         .NUM_INPUTS (NUM_CH_P2))
      U_rrb_selnet 
      (
         .clk                   (clk),
         .resetb                (rst_n),
         .tags                  (token_table_p2),
         .vlds                  (valid_arb_p2),
         .wall_next             (wall_next_p2),
         .selected_vld          (arb_selected_vld_unused),
         .tag_selected          (arb_token),
         .selected              (arb_ch_p2)
      );

   //---------------------------------------------------------------------------
   // Lock arbiter to prevent interleaving 
   //---------------------------------------------------------------------------

   wire                       read_data_interleave_en;

   wire [MCH_VALID_W-1:0] valid_r_in, valid_r_out;

   assign valid_r_in = {wall_next,valid_arb_next,lock_rrb_state_next};
   assign {wall_reg,valid_arb_reg,lock_rrb_state_reg} = valid_r_out;

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (MCH_VALID_W),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)      
   )
   U_valid_fsm_r
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (valid_r_in),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (valid_r_out),
      .parity_err (mch_valid_par_err)
   );

   if(READ_DATA_INTERLEAVE_EN==1) begin: INTERLEAVE_EN
     //assign read_data_interleave_en = 1'b1;
     assign read_data_interleave_en = ~bam_is_active; //TODO : if USE_BAM && BAM_ACTIVE then 0 else 1
   end else begin: nINTERLEAVE_EN
     wire split;
     //spyglass disable_block SelfDeterminedExpr-ML
     //SMD: Self determined expression '((RPINFOW + IDW) - 1)' found in module 'DWC_ddr_umctl2_xpi_rrb'
     //SJ: This coding style is acceptable and there is no plan to change it.
     assign split= infoq[RPINFOW+IDW-1];
     //spyglass enable_block SelfDeterminedExpr-ML
     assign read_data_interleave_en = rlast&~split;
   end
   assign rrb_is_locked = lock_rrb;

   always @(*) begin: COMB_PROC_lock_rrb_state
      lock_rrb_state_next = lock_rrb_state_reg;
      lock_rrb = 1'b0;
      update_wall_next =1'b0;
      case (lock_rrb_state_reg)
        IDLE: begin
          if ((RRB_THRESHOLD_EN == 0) || (NUM_CH == 1)) begin
            if ( (~empty&(~(read_data_interleave_en&rd_last)|~rd)) || (!empty && lock_on_lead_bam))
              lock_rrb_state_next = LOCK;
          end else begin // USE_SBRAM == 1
            if (~empty&lock_on_lead_sbam&(~(read_data_interleave_en&rd_last)|~rd))
              lock_rrb_state_next = LOCK;
          end
        end
        default: begin
          lock_rrb = 1'b1;   
          if ((~empty&rd&(read_data_interleave_en&rd_last)) || (bam_rrb_locked && empty))begin 
             lock_rrb_state_next = IDLE;
             update_wall_next = 1'b1;
          end
        end
      endcase // case(packet_state_reg)
   end // always @ (*)

   end // block: MULTI_CH
   endgenerate

  //---------------------------------------------------------------------------
  // RAM 
  //---------------------------------------------------------------------------
  
  assign rd_beat_info = infoq[INFOW-1-:BEAT_INFOW];
  assign wr_beat_info = infod[INFOW-1-:BEAT_INFOW];

  //beat_info is generated  in xpi_rp
  assign {rd_interleave_mode_unused,rd_beat_end,rd_beat_start_unused} = rd_beat_info;
  assign {wr_interleave_mode,wr_beat_end_unused,wr_beat_start} = wr_beat_info;  

//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in generate block
  assign rlast = infoq[INFOW-BEAT_INFOW-1];
//spyglass enable_block W528

  wire [NBEATS_LG2-1:0]                 wr_beat_addr_int_0;
  wire [NBEATS_LG2-1:0]                 wr_beat_addr_int_1;
  wire [NBEATS_LG2-1:0]                 wr_beat_addr_seq;   

  generate
   if (NBEATS_LG2==3) begin: MBL16_fr1
      assign wr_beat_addr_int_1[NBEATS_LG2-1]   = wr_beat_count[NBEATS_LG2-1]^wr_beat_start[NBEATS_LG2-1];
      //spyglass disable_block W164a
      //SMD: LHS: 'wr_beat_addr_int_1[(NBEATS_LG2 - 2):0] ' width 2 is less than RHS: '(wr_beat_start[(NBEATS_LG2 - 2):0]  + wr_beat_count[(NBEATS_LG2 - 2):0] )' width 3 in assignment
      //SJ: Overflow expected. See bug5632, comment #19.
      assign wr_beat_addr_int_1[NBEATS_LG2-2:0] = wr_beat_start[NBEATS_LG2-2:0]+wr_beat_count[NBEATS_LG2-2:0];
      //spyglass enable_block W164a
   end
   else begin: nMBL16_fr1
      assign wr_beat_addr_int_1                 = {NBEATS_LG2{1'b0}};
   end
  endgenerate

  assign wr_beat_addr_int_0                  = (wr_beat_count^wr_beat_start);

//spyglass disable_block W164a
//SMD: LHS: 'wr_beat_addr_seq' width 2 is less than RHS: '(wr_beat_count + wr_beat_start)' width 3 in assignment
//SJ: Overflow expected. See bug5632, comment #19.
  assign wr_beat_addr_seq = (wr_beat_count+wr_beat_start);
//spyglass enable_block W164a

  assign wr_beat_addr= wr_interleave_mode[0] ? wr_beat_addr_int_0 :
                       wr_interleave_mode[1] ? wr_beat_addr_int_1 :
                                               wr_beat_addr_seq;

  assign rd_beat_addr= rd_beat_count;
  
  assign ram_wr_addr[RAM_ADDR_WIDTH-1:0] = {wr_addr,wr_beat_addr};
  assign ram_rd_addr[RAM_ADDR_WIDTH-1:0] = {rd_addr,rd_beat_addr};   

  generate
    if (RRB_EXTRAM==0) begin: GEN_rrb_internal_ram
      DWC_ddrctl_bcm_wrap_mem_array
      
      #(.DATA_WIDTH         (RDATARAM_DW),
        .DEPTH              (RAM_DEPTH),
        .MEM_MODE           (0), // no pre or post retiming
        .ADDR_WIDTH         (RAM_ADDR_WIDTH),
        .OCCAP_EN           (OCCAP_EN),
        .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)        
      )
      U_rrb_ram
      (
       // Outputs
       .data_out                            (q[RDATARAM_DW-1:0]),
       .par_err                             (occap_xpi_rrb_ram_err),
       // Inputs
       .clk                                 (clk),
       .rst_n                               (rst_n),
       .init_n                              (1'b1),            
       .wr_n                                (~wr),
       .data_in                             (d[RDATARAM_DW-1:0]),
       .wr_addr                             (ram_wr_addr[RAM_ADDR_WIDTH-1:0]),
       .rd_addr                             (ram_rd_addr[RAM_ADDR_WIDTH-1:0]),
       .par_en                              (reg_ddrc_occap_en)
      );
    end // block: GEN_rrb_internal_ram

    if (RRB_EXTRAM==1) begin: GEN_rrb_external_ram
      assign q = 0;
      assign occap_xpi_rrb_ram_err = 1'b0;
    end
  endgenerate

  // Storage for rerror internally
  DWC_ddrctl_bcm_wrap_mem_array
  
     #(.DATA_WIDTH         (1),
     .DEPTH              (RAM_DEPTH),
     .MEM_MODE           (0), // no pre or post retiming
     .ADDR_WIDTH         (RAM_ADDR_WIDTH),
     .OCCAP_EN           (OCCAP_EN),
     .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN))
  U_rerror_ram
     (
     // Outputs
     .data_out                            (rerror_q),
     .par_err                             (occap_xpi_rrb_rerror_ram_err),
     // Inputs
     .clk                                 (clk),
     .rst_n                               (rst_n),
     .init_n                              (1'b1),            
     .wr_n                                (~wr),
     .data_in                             (rerror_d),
     .wr_addr                             (ram_wr_addr[RAM_ADDR_WIDTH-1:0]),
     .rd_addr                             (ram_rd_addr[RAM_ADDR_WIDTH-1:0]),
     .par_en                              (reg_ddrc_occap_en)
    );
  //-------------------------------------
  // VIRTUAL CHANNEL TOKEN QUEUE
  //-------------------------------------
  wire [NTOKENS_M2_LG2:0] vtq_wcount_unused[0: NUM_VIR_CH-1];
  reg  [NUM_VIR_CH-1:0] vtq_sbam_reach;
  generate
   
    for(gv=0;gv<NUM_VIR_CH;gv=gv+1)  begin:VTQ_ARRAY  
      if(USE_BAM==1) begin : WITH_BAM
        assign vtq_valid_arb[gv] = (&bam[vtq_token[gv]].beat_seg_valid) & ~vtq_empty[gv] & valid_dcr[gv];
        //assign vtq_valid[gv] = (&bam[vtq_token[gv]].beat_seg_valid) & ~vtq_empty[gv] & valid_dcr[gv];
        //valid beat reg is better here as it reduces latency 
        assign vtq_valid[gv] = vtq_valid_arb[gv] & valid_beat_reg[{vtq_token[gv],rd_beat_addr}];
      end else if((RRB_THRESHOLD_EN == 0) || (NUM_CH == 1)) begin : NO_SBAM_NO_BAM
        assign vtq_valid_arb[gv] = valid_burst[vtq_token[gv]] & ~vtq_empty[gv] & valid_dcr[gv];
        assign vtq_valid[gv] = valid_beat_reg[{vtq_token[gv],rd_beat_addr}] & ~vtq_empty[gv] & valid_dcr[gv];
      end else begin : WITH_SBAM // RRB_THRESHOLD_EN == 1
        if(RRB_THRESHOLD_PPL == 1) begin : WITH_PPL
          always @ (posedge clk or negedge rst_n) begin : vtq_sbam_reach_PROC
            if(~rst_n)
              vtq_sbam_reach[gv] <= 1'b0;
            else
              vtq_sbam_reach[gv] <= (sbam[vtq_token[gv]].tokens_received == sbam[vtq_token[gv]].tokens_allocated) && ~vtq_rd[gv] && ~vtq_empty[gv] && valid_dcr[gv];
          end

          assign vtq_valid_arb[gv] = vtq_sbam_reach[gv];
          assign vtq_valid[gv] = (lock_rrb ? (valid_burst[vtq_token[gv]] & ~vtq_empty[gv] & valid_dcr[gv]) : vtq_sbam_reach[gv]) && valid_beat_reg[{vtq_token[gv],rd_beat_addr}];
        end else begin : NO_PPL
          assign vtq_valid_arb[gv] = (sbam[vtq_token[gv]].tokens_received == sbam[vtq_token[gv]].tokens_allocated) & ~vtq_empty[gv] & valid_dcr[gv];
          assign vtq_valid[gv] = ((lock_rrb ? valid_burst[vtq_token[gv]] : (sbam[vtq_token[gv]].tokens_received == sbam[vtq_token[gv]].tokens_allocated)) & ~vtq_empty[gv] & valid_dcr[gv]) && valid_beat_reg[{vtq_token[gv],rd_beat_addr}];
        end
      end

      assign vtq_rd[gv] = (arb_ch == (gv)) ? release_token_l : 1'b0;
      assign vtq_token_table[((gv+1)*(NTOKENS_LG2))-1:gv*(NTOKENS_LG2)] =vtq_token[gv];              
    end
  endgenerate

  logic data_out_unused [NUM_VIR_CH-1 :0];

  DWC_ddrctl_vqueue
  
  #(
    .NUM_LISTS          (NUM_VIR_CH),
    .NUM_LISTS_LG2      (NUM_VIR_CH_LG2),
    .NTOKENS            (NTOKENS),
    .DATAW              (1),
    .OCCAP_EN           (OCCAP_EN),
    .OCCAP_PIPELINE_EN  (OCCAP_PIPELINE_EN)
  )
  U_vtq (
    .core_clk          (clk),
    .core_resetn       (rst_n),
    .wr                (~abypass_reorder & gen_token),
    .list_indx         (ch_num),
    .token_in          (atoken),
    .data_in           (1'b0),
    .rd                (vtq_rd),
    .reg_ddrc_occap_en (reg_ddrc_occap_en),
    .empty             (vtq_empty),
    .full              (vtq_full_unused),
    .token_out         (vtq_token),
    .data_out          (data_out_unused),
    .vqueue_par_err    (xpi_rrb_vtq_par_err)
  );

  generate
    if (STATIC_VIR_CH==1) begin :STATIC_MAPPING
      wire btq_rd, btq_wr;

      assign token_table = {btq_token,vtq_token_table};
      assign valid_arb = {btq_valid_arb,vtq_valid_arb};
      assign tq_valid = {btq_valid,vtq_valid};
      
      //-------------------------------------
      // BYPASS CHANNEL TOKEN QUEUE
      //-------------------------------------

      assign btq_wr = rbypass_reorder & wr  & wr_first;
      //spyglass disable_block SelfDeterminedExpr-ML
      //SMD: Self determined expression '(arb_ch==(NUM_CH - 1))' found in module 'DWC_ddr_umctl2_xpi_rrb'
      //SJ: This coding style is acceptable and there is no plan to change it.
      assign btq_rd = (arb_ch == (NUM_CH-1)) ? release_token_l : 1'b0;
      //spyglass enable_block SelfDeterminedExpr-ML
      assign btq_valid_arb = valid_burst[btq_token] & ~btq_empty;
      assign btq_valid = valid_beat_reg[{btq_token,rd_beat_addr}] & ~btq_empty;       

      wire [NTOKENS_M2_LG2:0] btq_wcount_unused;
      
      DWC_ddr_umctl2_grfifo_s
      
        #(
          .WIDTH           (NTOKENS_LG2),
          .DEPTH           (NTOKENS_M2),
          .ADDR_WIDTH      (NTOKENS_M2_LG2),
          .COUNT_WIDTH     (NTOKENS_M2_LG2+1),
          .OCCAP_EN        (OCCAP_EN),
          .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)          
          ) 
      U_btq 
        (
         .clk             (clk),
         .rst_n           (rst_n),
         .wr              (btq_wr),  
         .d               (wr_addr),
         .rd              (btq_rd), 
         .par_en          (reg_ddrc_occap_en),
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in RTL assertion/coverpoint and/or generate block
         .ff              (btq_full),
         .wcount          (btq_wcount_unused), // not used
         .q               (btq_token),
         .fe              (btq_empty),         
//spyglass enable_block W528
         .par_err         (occap_xpi_rrb_btq_par_err)
         );

      
    end
    else begin : DYNAMIC_MAPPING
      assign token_table = vtq_token_table;
      assign valid_arb = vtq_valid_arb;
      assign tq_valid = vtq_valid;
//spyglass disable_block W528
//SMD: Variable set but not read
//SJ: Used in RTL assertion/coverpoint and/or generate block
      assign btq_valid = 1'b0;
      assign btq_valid_arb = 1'b0; 
      assign btq_full = 1'b0;
      assign btq_empty = 1'b0;
      assign btq_token = {NTOKENS_LG2{1'b0}};
//spyglass enable_block W528
      assign occap_xpi_rrb_btq_par_err = 1'b0;
    end
  endgenerate

   generate
      for (gv=0 ; gv < NTOKENS ; gv=gv+1) begin: INFO_par

         assign info_wr[gv] = (gv==wr_addr) ? wr : 1'b0;

         DWC_ddr_umctl2_par_reg
         
         #(
            .DW      (INFOW),
            .OCCAP   (OCCAP_EN),
            .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN),        
            .REG_EN  (1),
            .SL_W    (8)
         )
         U_info
         (
            .clk        (clk),
            .rst_n      (rst_n),
            .data_in    (infod),
            .reg_set    (info_wr[gv]),
            .parity_en  (reg_ddrc_occap_en),
            .poison_en  (occap_par_poison_en),
            .data_out   (info_mem[gv]),
            .parity_err (info_mem_parity_err[gv])
         );

      end
   endgenerate

   assign xpi_rrb_info_mem_parity_err = |info_mem_parity_err;
   assign xpi_rrb_parity_err          = xpi_rrb_info_mem_parity_err | occap_xpi_rrb_btq_par_err | xpi_rrb_vtq_par_err | occap_xpi_rrb_ram_err | 
                                        mch_valid_par_err | valid_beat_par_err | release_token_par_err | occap_xpi_rrb_par_err | occap_xpi_rrb_rerror_ram_err | ch_raq_table_par_err;

  //spyglass disable_block W415a
  //SMD: Signal  is being assigned multiple times in same always block. 
  //SJ: Using initialization in process to minimize code - sets the default for any hanging branches, avoids latches
  always @ (*) begin : COMB_PROC_valid
    valid_beat_next = valid_beat_reg;
    for (i=0 ; i < NTOKENS ; i=i+1) begin
      for (j=0 ; j < NBEATS ; j=j+1)   begin   
        if (rd &~empty && rd_addr==i && rd_last)// decision can be registred 
          valid_beat_next[i*NBEATS+:NBEATS] ={NBEATS{1'b0}}; // could be optimized instead of empty use valid[0]
        else if (wr && wr_addr==i && wr_beat_addr==j)
          valid_beat_next[i*NBEATS+j] = 1'b1;
      end
    end 
  end // block: COMB_PROC_valid
  //spyglass enable_block W415a
  
   //spyglass disable_block SelfDeterminedExpr-ML
   //SMD: Self determined expression '(NBEATS * NTOKENS)' found in module 'DWC_ddr_umctl2_xpi_rrb'
   //SJ: This coding style is acceptable and there is no plan to change it.
   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (NBEATS*NTOKENS),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)      
   )
   U_valid_beat
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (valid_beat_next),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (valid_beat_reg),
      .parity_err (valid_beat_par_err)
   );
   //spyglass enable_block SelfDeterminedExpr-ML

  always @ (*) begin : COMB_PROC_beat_count
    if (wr) begin
        wr_beat_count_nxt = wr_last ? {NBEATS_LG2{1'b0}}:wr_beat_count+1;
    end else begin
        wr_beat_count_nxt = wr_beat_count;
    end

    if (rd & ~empty) begin 
        rd_beat_count_nxt = rd_last ? {NBEATS_LG2{1'b0}}:rd_beat_count+1;
    end else begin
        rd_beat_count_nxt = rd_beat_count;
    end
  end

  always @ (posedge clk or negedge rst_n) begin : SEQ_PROC_beat_count
    if (rst_n == 1'b0) begin
      wr_beat_count <= {NBEATS_LG2{1'b0}};
      rd_beat_count <= {NBEATS_LG2{1'b0}};
    end 
    else begin
      wr_beat_count <= wr_beat_count_nxt;
      rd_beat_count <= rd_beat_count_nxt;
    end // else: !if(rst_n == 1'b0)
  end

   //---------------------------------------------------------------------------
   // External RAM Interface 
   //---------------------------------------------------------------------------
   assign rdataram_raddr = ram_rd_addr;
   assign rdataram_waddr = ram_wr_addr;


  //---------------------------------------------------------------------------
  // OCCAP_EN process
  //---------------------------------------------------------------------------

  generate
   if (OCCAP_EN==1) begin: OCCAP_en

     
     wire [OCCAP_WIDTH-1:0] pgen_in;  
     wire [OCCAP_WIDTH-1:0] pcheck_in;  

     // 
     // wiring of pgen_in/pcheck_in
     //

     assign pgen_in    = {wr_beat_count_nxt,
                          rd_beat_count_nxt};

     assign pcheck_in  = {wr_beat_count,
                          rd_beat_count};


     wire [PARW-1:0]        pgen_in_par;     
     reg  [PARW-1:0]        pgen_in_par_r;     
     wire [PARW-1:0]        pcheck_par_err;   
     wire [PARW-1:0]        pgen_parity_corr_unused, pcheck_parity_corr_unused;  
     
     wire                   parity_en;
     reg                    pcheck_en;
     wire [PARW-1:0]        parity_dummy,  mask_in;
     wire                   poison_en;

     assign parity_dummy  = {PARW{1'b1}};
     assign mask_in       = {PARW{1'b1}};
     assign poison_en     = 1'b0;

     assign parity_en = reg_ddrc_occap_en;
     always @(posedge clk or negedge rst_n) begin
           if (~rst_n) begin
              pcheck_en <= 0;
           end
           else begin
              pcheck_en <= parity_en;
           end
        end

           
     // 
     // parity checking logic itself
     //
         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_WIDTH), 
            .CALC    (1), // parity calc
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pgen
         (
            .data_in       (pgen_in),
            .parity_en     (parity_en),
            .parity_type   (poison_en),
            .parity_in     (parity_dummy),
            .mask_in       (mask_in),
            .parity_out    (pgen_in_par), // parity out
            .parity_corr   (pgen_parity_corr_unused) // not used
         );


         always @ (posedge clk or negedge rst_n)
           if (~rst_n) begin
             pgen_in_par_r <= {PARW{1'b0}};
           end
           else begin
             pgen_in_par_r <= pgen_in_par;
           end


         DWC_ddr_umctl2_ocpar_calc
         
         
         #(
            .DW      (OCCAP_WIDTH),
            .CALC    (0), // parity check
            .PAR_DW  (PARW),
            .SL_W    (SL_W)
         )
         U_pcheck
         (
            .data_in       (pcheck_in),
            .parity_en     (pcheck_en),
            .parity_type   (1'b0),
            .parity_in     (pgen_in_par_r), // parity in
            .mask_in       (mask_in),
            .parity_out    (pcheck_par_err), // parity error
            .parity_corr   (pcheck_parity_corr_unused) // not used
         );     
      
         if (OCCAP_PIPELINE_EN==1) begin : OCCAP_PIPELINE_EN_1

           reg pcheck_par_err_r;
           always @ (posedge clk or negedge rst_n) begin : pcheck_par_err_r_PROC
             if (~rst_n) begin
               pcheck_par_err_r <= 1'b0;
             end else begin
               pcheck_par_err_r <= |pcheck_par_err;
             end
           end

           assign occap_xpi_rrb_par_err = pcheck_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign occap_xpi_rrb_par_err = |pcheck_par_err;

         end 

         
   end else begin: OCCAP_ne
      assign occap_xpi_rrb_par_err = 1'b0;
    end

  endgenerate

  //---------------------------------------------------------------------------
  // End of OCCAP_EN process
  //---------------------------------------------------------------------------



`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS

  
  // Overwriting must never occur,
  // The token manager is responsible to prevent this situation
  property p_rrb_overwrite;
  @(posedge clk) disable iff(!rst_n) 
    (wr) |-> (~valid_beat_reg[{wr_addr,wr_beat_addr}]);
  endproperty 
  a_rrb_overwrite : assert property (p_rrb_overwrite) else 
    $display("-> %0t ERROR: [xpi_rrb] Read reorder buffer overwrite attemp wr_addr %0d wr_beat %0d", $realtime,wr_addr,wr_beat_addr);
  
  // Virtual Channel Token Queue must not overflow
      property p_vtq_overflow;
      @(posedge clk) disable iff(!rst_n) 
        (gen_token) |-> (~vtq_full_unused);
    endproperty 
      a_vtq_overflow : assert property (p_vtq_overflow) else 
        $display("-> %0t ERROR: Virtual Channel Token Queue overflow", $realtime);
  
  // Bypass Channel Token Queue must not overflow
  property p_btq_overflow;
    @(posedge clk) disable iff(!rst_n) 
      (gen_token) |-> (~btq_full);
  endproperty 
  a_btq_overflow : assert property (p_btq_overflow) else 
    $display("-> %0t ERROR: Bypass Channel Token Queue overflow", $realtime);
  
  // RRB overflow 
  property p_rrb_overflow;
    @(posedge clk) disable iff(!rst_n) 
      (wr) |-> (~full);
  endproperty 
  a_rrb_overflow : assert property (p_rrb_overflow) else 
    $display("-> %0t ERROR: Read data received while read reorder buffer full", $realtime);

  // Bypass Channel Token Queue must not overflow
  property p_simultaneous_ram_wr_rd;
    @(posedge clk) disable iff(!rst_n) 
      (~empty&wr) |-> (rdataram_raddr!=rdataram_waddr);
    
  endproperty 
  a_simultaneous_ram_wr_rd : assert property (p_simultaneous_ram_wr_rd) else 
    $display("-> %0t ERROR: RAM simultaneous read and write to the same address %0d", $realtime,rdataram_raddr);

  localparam CATEGORY = 5; // Allows groups of assertions to be enabled/disabled at the same time

  // RRB dead arbitration cycle  
 // property p_dead_arbitration_cycle;
   // @(posedge clk) disable iff(!rst_n) 
    //  (wr |-> ##1 ~empty);
//  endproperty 
 // a_dead_arbitration_cycle : assert property (p_dead_arbitration_cycle) else 
  //  $display("-> %0t ERROR: Dead arbitration cycle. RRB written and arbiter is not draining one cycle later.", $realtime);
  
  // BTQ gets full
  cp_rrb_btq_full: cover property (@(posedge clk) disable iff(!rst_n) btq_full==1'b1);

  // Data in RAM ready to be drained simultaneously from all VTQs and BTQ
  cp_rrb_rrb_simult_btq_avtq_ready: cover property (@(posedge clk) disable iff(!rst_n) (&vtq_valid & btq_valid));

  // Data in RAM ready to be drained simultaneously from one and more VTQ and BTQ
  cp_rrb_rrb_simult_btq_vtq_ready: cover property (@(posedge clk) disable iff(!rst_n) (|vtq_valid & btq_valid));

  // Data in RAM ready to be drained simultaneously from both VTQs and BTQ, arbitrating BTQ  
  cp_rrb_rrb_simult_btq_vtq_ready_arb_btq: cover property (@(posedge clk) disable iff(!rst_n) (|vtq_valid & btq_valid &&(arb_ch == NUM_CH-1)));

  // Data in RAM ready to be drained simultaneously from both VTQs and BTQ, arbitrating one VTQ  
  cp_rrb_rrb_simult_btq_vtq_ready_arb_vtq: cover property (@(posedge clk) disable iff(!rst_n) (|vtq_valid & btq_valid &&(arb_ch != NUM_CH-1)));
  
  // Data in RAM ready to be drained pressure applied from xpi_read  
  cp_rrb_rrb_pressure_xpi_read: cover property (@(posedge clk) disable iff(!rst_n) (empty&~rd));
 
`endif  // SYNTHESIS
`endif // SNPS_ASSERT_ON
endmodule // DWC_ddr_umctl2_xpi_rrb
