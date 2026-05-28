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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ts/gs_dqsosc.sv#1 $
// -------------------------------------------------------------------------
// Description:
// Global DQS oscillator.  This block is responsible for periodically issuing the MPC 
// command to start the interval oscillator for LPDDR4/LPDDR5 and subsequently issue
// the MRR command to get the result of interval oscillator. It also generates the snooping 
// signal to distinguish the MRR command and enables the PHY to accordingly adjust the 
// drift
// ----------------------------------------------------------------------------

`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"
module gs_dqsosc 
import DWC_ddrctl_reg_pkg::*;
#(
  //------------------------------- PARAMETERS ---------------------------------- 
     parameter    MRS_TO_MRS_WIDTH            = 1
    ,parameter    RANK_BITS                   = `MEMC_RANK_BITS
    ,parameter    MRS_A_BITS                  = `MEMC_PAGE_BITS
    ,parameter    NUM_RANKS                   = 1 << RANK_BITS
    ,parameter    FSM_STATE_WIDTH             = 5
    ,parameter    GS_ST_SELFREF_EX1           = 5'b01110    // power up pads

) (
  //--------------------------- INPUTS AND OUTPUTS -------------------------------
     input logic                             co_yy_clk                           // 
    ,input logic                             core_ddrc_rstn                      //
  //--------------------------- REGISTER I/F----- -------------------------------
    ,input logic                             reg_ddrc_lpddr4
    ,input logic                             reg_ddrc_lpddr5
    ,input logic     [T_MR_WIDTH-1:0]        reg_ddrc_t_mrr                         // t_mrr within a rank
    ,input logic                             reg_ddrc_frequency_ratio               // 0 - 1:2 (1:1:2) freq ratio, 1 - 1:4(1:1:4) freq ratio
    ,input logic                             reg_ddrc_dqsosc_enable                 // DQSOSC enable
    ,input logic     [T_OSCO_WIDTH-1:0]      reg_ddrc_t_osco                        // t_osco timing
    ,input logic     [7:0]                   reg_ddrc_dqsosc_runtime                // Oscillator runtime
    ,input logic     [7:0]                   reg_ddrc_wck2dqo_runtime               // Oscillator runtime only for LPDDR5 
    ,input logic     [11:0]                  reg_ddrc_dqsosc_interval               // DQSOSC inverval
    ,input logic                             reg_ddrc_dqsosc_interval_unit          // DQSOSC interval unit
    ,input logic                             reg_ddrc_dis_dqsosc_srx
    ,output logic    [2:0]                   dqsosc_state
    ,output logic    [NUM_RANKS-1:0]         dqsosc_per_rank_stat    
    ,input  logic                            timer_pulse_x1024_p
  //--------------------------- gs_fsm-------- -------------------------------
    ,input logic                             normal_operating_mode
    ,input logic                             powerdown_operating_mode
    ,input logic     [FSM_STATE_WIDTH-1:0]   gs_dh_global_fsm_state                // state from global_fsm module
    ,output logic                            dqsosc_pd_forbidden
    ,output logic                            dqsosc_required
  //--------------------------- gs_load_mr-------- -------------------------------
    ,output logic                            dqsosc_loadmr_upd_req_p             //Active high pulse
    ,input  logic                            loadmr_dqsosc_upd_done_p
    ,output logic    [NUM_RANKS-1:0]         dqsosc_block_other_cmd 
    ,output logic    [MRS_A_BITS-1:0]        dqsosc_loadmr_a
    ,output logic                            dqsosc_loadmr_mpc
    ,output logic                            dqsosc_loadmr_mrr
    ,output logic    [3:0]                   dqsosc_loadmr_snoop_en
);

    localparam   STATE_DQSOSC_IDLE        = 7'h01,
                 STATE_DQSOSC_START       = 7'h02,
                 STATE_DQSOSC_RUNTIME     = 7'h04,
                 STATE_DQSOSC_GET_RESULT1 = 7'h08,
                 STATE_DQSOSC_WAIT1       = 7'h10,
                 STATE_DQSOSC_GET_RESULT2 = 7'h20,
                 STATE_DQSOSC_WAIT2       = 7'h40;

    localparam  [MRS_A_BITS-1:0] MPC_START_DQS_OSC        = {{(MRS_A_BITS-14){1'b0}},14'b1001011_0000000};
    localparam  [MRS_A_BITS-1:0] MPC_START_WCKDQI_OSC     = {{(MRS_A_BITS-14){1'b0}},14'b10000001_000000};
    localparam  [MRS_A_BITS-1:0] MPC_START_WCKDQO_OSC     = {{(MRS_A_BITS-14){1'b0}},14'b10000011_000000};

    localparam  [MRS_A_BITS-1:0] MR_READ_MRR18            = {{(MRS_A_BITS-16){1'b0}}, 16'h1200}; //LPDDR4 format - [7:0] - data, [15:8] - address
    localparam  [MRS_A_BITS-1:0] MR_READ_MRR19            = {{(MRS_A_BITS-16){1'b0}}, 16'h1300}; //LPDDR4 format - [7:0] - data, [15:8] - address

    localparam  [MRS_A_BITS-1:0] MR_READ_MRR35            = {{(MRS_A_BITS-16){1'b0}}, 16'h2300}; //LPDDR5 format - [7:0] - data, [15:8] - address
    localparam  [MRS_A_BITS-1:0] MR_READ_MRR36            = {{(MRS_A_BITS-16){1'b0}}, 16'h2400}; //LPDDR5 format - [7:0] - data, [15:8] - address
    localparam  [MRS_A_BITS-1:0] MR_READ_MRR38            = {{(MRS_A_BITS-16){1'b0}}, 16'h2600}; //LPDDR5 format - [7:0] - data, [15:8] - address
    localparam  [MRS_A_BITS-1:0] MR_READ_MRR39            = {{(MRS_A_BITS-16){1'b0}}, 16'h2700}; //LPDDR5 format - [7:0] - data, [15:8] - address

    logic                                        timer_pulse_x32k_p;
    logic                                        timer_pulse_x2k_p;
    logic                                        timer_pulse_x2k_or_x32k_p;
    logic [4:0]                                  timer_x32k;
    logic                                        dqsosc_interval_cnt_en; //DQSOSC interval count enable
    logic [$bits(reg_ddrc_dqsosc_interval)-1:0]  dqsosc_interval_cnt;    //DQSOSC interval counter
    logic                                        trig_dqsosc;
    logic                                        trig_dqsosc_srx;
    logic                                        state_dqsosc_is_idle;
    logic [6:0]                                  state_dqsosc,state_dqsosc_nxt;

    logic [13:0]                                 wait_cnt; // shared between runtime count and wait MRR count (8K + t_osco  for LPDDR4).
    logic [$bits(wait_cnt)-1:0]                  wait_cnt_val;   
    logic                                        wait_cnt_load_p;
    logic                                        runtime_expired;
    logic                                        num_mpc_cmd;
    logic                                        t_mrr_expired;
    logic                                        num_mrr_cmd_seq;
    logic [13:0]                                 dqsosc_runtime; 
    logic [13:0]                                 wck2dqo_runtime; 
    logic [$bits(wait_cnt)-1:0]                  reg_ddrc_dqsosc_runtime_sft;
    logic [$bits(         dqsosc_runtime)-1:0]   lpddr4_runtime;
    logic [$bits(         dqsosc_runtime)-1:0]   lpddr5_runtime;
    logic                                        mrr_in_prog;
    logic                                        global_fsm_state_is_sr_ex1;
    logic                                        global_fsm_state_is_sr_ex1_d1;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Converting the encoded runtime inot its binary equivalent    
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
   always_comb begin : dqsosc_runtime_in_binary
      case (reg_ddrc_dqsosc_runtime[7:6])
         2'b01  : dqsosc_runtime = 14'h0800;
         2'b10  : dqsosc_runtime = 14'h1000;
         2'b11  : dqsosc_runtime = 14'h2000;
         default: dqsosc_runtime = {4'h0,reg_ddrc_dqsosc_runtime[5:0],4'h0};
      endcase
   end
   always_comb begin : wck2dqo_runtime_in_binary
      case (reg_ddrc_wck2dqo_runtime[7:6])
         2'b01  : wck2dqo_runtime = 14'h0800;
         2'b10  : wck2dqo_runtime = 14'h1000;
         2'b11  : wck2dqo_runtime = 14'h2000;
         default: wck2dqo_runtime = {4'h0,reg_ddrc_wck2dqo_runtime[5:0],4'h0};
      endcase
   end    
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// DQSOSC interval starts only if
//  1. reg_ddrc_dqsosc_enable = 1 (set by software)
//  2. normal_operating_mode = 1 (gs_global_fsm is in normal operating mode)
//  3. DQSOSC state is IDLE
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    assign dqsosc_interval_cnt_en = reg_ddrc_dqsosc_enable && (normal_operating_mode || powerdown_operating_mode) && state_dqsosc_is_idle;
    assign state_dqsosc_is_idle   = state_dqsosc==STATE_DQSOSC_IDLE;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//This counter is used to internally count 2k or 32K core clock. The counter is resetted if dqsosc_interval_cnt_en=0
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : timer_x32k_PROC
       if (!core_ddrc_rstn) begin
          timer_x32k              <= {$bits(timer_x32k){1'b0}};
       end else begin
          if (dqsosc_interval_cnt_en)
            timer_x32k           <=  timer_pulse_x1024_p ? timer_x32k + {{($bits(timer_x32k)-1){1'b0}},1'b1} : timer_x32k;
         else 
             timer_x32k           <= {$bits(timer_x32k){1'b0}};       
       end
    end

    assign timer_pulse_x2k_p          = timer_pulse_x1024_p && timer_x32k[0];
    assign timer_pulse_x32k_p         = timer_pulse_x1024_p && (&timer_x32k);
    assign timer_pulse_x2k_or_x32k_p  = reg_ddrc_dqsosc_interval_unit ? timer_pulse_x2k_p : timer_pulse_x32k_p; 

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Count DQSOSC interval in unit of 2k or 32k core clock. Restart the count if dqsosc_interval_cnt_en=0 or when counter reached DQS interval time 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : dqsosc_interval_cnt_PROC
       if (!core_ddrc_rstn) begin
          dqsosc_interval_cnt    <= {$bits(dqsosc_interval_cnt){1'b0}};
       end else begin
          if (dqsosc_interval_cnt_en)// && (dqsosc_interval_cnt != reg_ddrc_dqsosc_interval))
            dqsosc_interval_cnt  <=  timer_pulse_x2k_or_x32k_p ? dqsosc_interval_cnt + {{($bits(dqsosc_interval_cnt)-1){1'b0}},1'b1} : dqsosc_interval_cnt;
         else 
             dqsosc_interval_cnt  <= {$bits(dqsosc_interval_cnt){1'b0}};       
       end
    end
    //ccx_cond: ; ;11011+11101+11110; Runtime and DQSOSC interval are not allowed to be '0' for triggering DQSOSC
    assign trig_dqsosc = ((dqsosc_interval_cnt==reg_ddrc_dqsosc_interval) || trig_dqsosc_srx) && dqsosc_interval_cnt_en &&  //non pseudo static
                         (|reg_ddrc_dqsosc_runtime) && ((|reg_ddrc_wck2dqo_runtime) || reg_ddrc_lpddr4) && (|reg_ddrc_dqsosc_interval); //pseudo static

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Current state generation
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : state_dqsosc_PROC
       if (!core_ddrc_rstn) begin
          state_dqsosc    <= STATE_DQSOSC_IDLE;
       end else begin
         state_dqsosc    <= state_dqsosc_nxt;
       end
    end
    assign dqsosc_pd_forbidden = state_dqsosc_nxt!=STATE_DQSOSC_IDLE;
//-------------------------------------------------------------------------------------------------------------------------------------------------------------    
//Next State generation
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always @ (*) begin : state_dqsosc_nxt_PROC
       state_dqsosc_nxt = state_dqsosc;
       case (state_dqsosc)
         STATE_DQSOSC_IDLE : begin
            if (trig_dqsosc)
               state_dqsosc_nxt = STATE_DQSOSC_START;
             else              
               state_dqsosc_nxt = STATE_DQSOSC_IDLE;
         end   

         STATE_DQSOSC_START : begin
            if (loadmr_dqsosc_upd_done_p)
               state_dqsosc_nxt = STATE_DQSOSC_RUNTIME;
            else
               state_dqsosc_nxt = STATE_DQSOSC_START;
         end  

          STATE_DQSOSC_RUNTIME : begin
            if (runtime_expired)
               state_dqsosc_nxt = (num_mpc_cmd) ? STATE_DQSOSC_START : STATE_DQSOSC_GET_RESULT1; //num_mpc_cmd=0 for LPDDR4
             else
                state_dqsosc_nxt = STATE_DQSOSC_RUNTIME;               
         end  

         STATE_DQSOSC_GET_RESULT1 : begin
            if (loadmr_dqsosc_upd_done_p)
               state_dqsosc_nxt = STATE_DQSOSC_WAIT1;
            else
               state_dqsosc_nxt = STATE_DQSOSC_GET_RESULT1;
         end

         STATE_DQSOSC_WAIT1 : begin
            if (t_mrr_expired)
               state_dqsosc_nxt = STATE_DQSOSC_GET_RESULT2;
            else
                state_dqsosc_nxt = STATE_DQSOSC_WAIT1;              
         end

         STATE_DQSOSC_GET_RESULT2 : begin
            if (loadmr_dqsosc_upd_done_p)
               state_dqsosc_nxt = STATE_DQSOSC_WAIT2;
            else
               state_dqsosc_nxt = STATE_DQSOSC_GET_RESULT2;
         end

         //STATE_DQSOSC_WAIT2 : begin
         default : begin
            if (t_mrr_expired)
               if (num_mrr_cmd_seq) //num_mrr_cmd_seq=0 for LPDDR4
                  state_dqsosc_nxt = STATE_DQSOSC_GET_RESULT1;
              else
                  state_dqsosc_nxt = STATE_DQSOSC_IDLE;         
            else
                state_dqsosc_nxt = STATE_DQSOSC_WAIT2;              
         end         
       
       endcase        

    end //state_dqsosc_nxt_PROC  

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    assign wait_cnt_load_p = loadmr_dqsosc_upd_done_p;

    //always multiple of 16 mem clock
    assign reg_ddrc_dqsosc_runtime_sft = reg_ddrc_frequency_ratio ? {2'b00,dqsosc_runtime[($bits(dqsosc_runtime)-1):2]}
                                                                  : {1'b0,dqsosc_runtime[($bits(dqsosc_runtime)-2):1]}; 

//spyglass disable_block W164a
//SMD: LHS: 'lpddr4_runtime' width 14 is less than RHS: '(reg_ddrc_dqsosc_runtime_sft + reg_ddrc_t_osco)' width 15 in assignment 
//SJ: Specification defined the max runtime of 8K dram clock cycles (0x2000). So the addition with t_osco max(40ns,8nck) should not exceed 14 bits
    //For LPDDR4 mem clock and DFI clock are dependent on frequency ratio
    assign lpddr4_runtime = reg_ddrc_dqsosc_runtime_sft + reg_ddrc_t_osco; 
//spyglass enable_block W164a
   
//spyglass disable_block W164a
//SMD: LHS: 'lpddr5_runtime' width 14 is less than RHS: '((num_mpc_cmd ? dqsosc_runtime : wck2dqo_runtime) + reg_ddrc_t_osco)' width 15 in assignment 
//SJ: Specification defined the max runtime of 8K dram clock cycles (0x2000). So the addition with t_osco max(40ns,8nck) should not exceed 14 bits
    //For LPDDR5 mem clock and DFI clock are equal
    assign lpddr5_runtime = (num_mpc_cmd? dqsosc_runtime : wck2dqo_runtime) + reg_ddrc_t_osco; 
//spyglass enable_block W164a

    always @ (*) begin : wait_cnt_val_PROC
       wait_cnt_val = {$bits(wait_cnt){1'b0}};
       case (state_dqsosc)
         STATE_DQSOSC_START : begin
             wait_cnt_val = reg_ddrc_lpddr5 ? lpddr5_runtime[0+:$bits(wait_cnt)] : lpddr4_runtime[0+:$bits(wait_cnt)]; 
         end
          STATE_DQSOSC_GET_RESULT1 : begin
             wait_cnt_val = {{($bits(wait_cnt_val)-$bits(reg_ddrc_t_mrr)){1'b0}},reg_ddrc_t_mrr};
         end
          STATE_DQSOSC_GET_RESULT2 : begin
                wait_cnt_val = {{($bits(wait_cnt_val)-$bits(reg_ddrc_t_mrr)){1'b0}},reg_ddrc_t_mrr};               
         end          
       endcase
    end  //wait_cnt_val_PROC 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// This counter monitors the count (runtime and t_mrr) so that next CMD can be issued
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : wait_cnt_PROC
       if (!core_ddrc_rstn) begin
          wait_cnt    <= {$bits(wait_cnt){1'b0}};
       end else begin
         if (wait_cnt_load_p)
            wait_cnt <= wait_cnt_val;
          else if (|wait_cnt)  
             wait_cnt <= wait_cnt - {{($bits(wait_cnt)-1){1'b0}},1'b1};
       end
    end

    assign runtime_expired = !(|wait_cnt) && (state_dqsosc==STATE_DQSOSC_RUNTIME);
    assign t_mrr_expired   = !(|wait_cnt) && ((state_dqsosc==STATE_DQSOSC_WAIT1) || (state_dqsosc==STATE_DQSOSC_WAIT2));

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//Applies for LPDDR5. This signal toggles when MPC command is sent out. Used for sending 2nd MPC command for LPDDR5 after the DQS Osc runtime of 1st MPC cmd 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : num_mpc_cmd_PROC
       if (!core_ddrc_rstn) begin
          num_mpc_cmd    <= 1'b0;
       end else begin
          if (state_dqsosc_nxt==STATE_DQSOSC_IDLE) begin
             num_mpc_cmd    <= 1'b0;
          end else if ((state_dqsosc_nxt==STATE_DQSOSC_START) && (state_dqsosc!=STATE_DQSOSC_START)) begin 
             num_mpc_cmd    <= num_mpc_cmd ^ reg_ddrc_lpddr5;
          end
       end
    end    

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//It applies for LPDDR5 and toggles after the 2nd MRR command is sent out. This flag is also used to distinguish MRR35/36 and MRR38/39. 0 indicates MRR35/36
//issuing interval, 1 for  MRR38/39
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : num_mrr_cmd_seq_PROC
       if (!core_ddrc_rstn) begin
          num_mrr_cmd_seq    <= 1'b0;
       end else begin
          if (state_dqsosc_nxt==STATE_DQSOSC_IDLE) begin
             num_mrr_cmd_seq    <= 1'b0;
          end else if ((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT2) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT2)) begin 
             num_mrr_cmd_seq    <=num_mrr_cmd_seq ^ reg_ddrc_lpddr5;
          end
       end
    end    

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//This is asserted from the acceptance of 1st MRR till the last MRR for the same rank. It is used to block any oher command between MRR to the same rank generated
//as a part DQSOSC sequence
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : mrr_in_prog_PROC
       if (!core_ddrc_rstn) begin
          mrr_in_prog    <= 1'b0;
       end else begin
          if (state_dqsosc_nxt==STATE_DQSOSC_IDLE) begin
             mrr_in_prog    <= 1'b0;
          end else if (dqsosc_loadmr_mrr && loadmr_dqsosc_upd_done_p && (!num_mrr_cmd_seq)) begin 
             mrr_in_prog    <= ~mrr_in_prog;
          end
       end
    end    

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : dqsosc_loadmr_upd_req_p_PROC
       if (!core_ddrc_rstn) begin
          dqsosc_loadmr_upd_req_p    <= 1'b0;
       end else begin
         if (((state_dqsosc_nxt==STATE_DQSOSC_START) && (state_dqsosc!=STATE_DQSOSC_START)) ||
             ((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT1) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT1)) ||
             ((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT2) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT2)) 
             )
            dqsosc_loadmr_upd_req_p    <= 1'b1;
         else
            dqsosc_loadmr_upd_req_p    <= 1'b0;
       end
    end

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : dqsosc_loadmr_mpc_mrr_PROC
       if (!core_ddrc_rstn) begin
          dqsosc_loadmr_mpc    <= 1'b0;
          dqsosc_loadmr_mrr    <= 1'b0;
       end else begin
          if (state_dqsosc_nxt==STATE_DQSOSC_IDLE) begin
             dqsosc_loadmr_mpc    <= 1'b0;
             dqsosc_loadmr_mrr    <= 1'b0;
          end else if ((state_dqsosc_nxt==STATE_DQSOSC_START) && (state_dqsosc!=STATE_DQSOSC_START)) begin 
             dqsosc_loadmr_mpc    <= 1'b1;
             dqsosc_loadmr_mrr    <= 1'b0;
         end else if (((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT1) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT1)) ||
                      ((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT2) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT2))) begin
             dqsosc_loadmr_mpc    <= 1'b0;
             dqsosc_loadmr_mrr    <= 1'b1;         
          end
       end
    end

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
    always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : dqsosc_loadmr_a_PROC
       if (!core_ddrc_rstn) begin
          dqsosc_loadmr_a        <= {$bits(dqsosc_loadmr_a){1'b0}};
         dqsosc_loadmr_snoop_en <= {$bits(dqsosc_loadmr_snoop_en){1'b0}};
       end else begin
          if (state_dqsosc_nxt==STATE_DQSOSC_IDLE) begin
             dqsosc_loadmr_a        <= {$bits(dqsosc_loadmr_a){1'b0}};
            dqsosc_loadmr_snoop_en <= {$bits(dqsosc_loadmr_snoop_en){1'b0}};
          end else if ((state_dqsosc_nxt==STATE_DQSOSC_START) && (state_dqsosc!=STATE_DQSOSC_START)) begin 
            dqsosc_loadmr_snoop_en <= {$bits(dqsosc_loadmr_snoop_en){1'b0}};
            if (reg_ddrc_lpddr5)
                dqsosc_loadmr_a    <= num_mpc_cmd ? MPC_START_WCKDQO_OSC : MPC_START_WCKDQI_OSC;
            else       
                dqsosc_loadmr_a    <= MPC_START_DQS_OSC;
         end else if ((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT1) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT1)) begin
            if (reg_ddrc_lpddr5) begin
                dqsosc_loadmr_a        <= num_mrr_cmd_seq ? MR_READ_MRR38 : MR_READ_MRR35;
                dqsosc_loadmr_snoop_en <= num_mrr_cmd_seq ? 4'b0100 : 4'b0001;
            end else begin
                dqsosc_loadmr_a        <= MR_READ_MRR18;
              dqsosc_loadmr_snoop_en <= 4'b0001;
            end
         end else if ((state_dqsosc_nxt==STATE_DQSOSC_GET_RESULT2) && (state_dqsosc!=STATE_DQSOSC_GET_RESULT2)) begin
           if (reg_ddrc_lpddr5) begin
                dqsosc_loadmr_a        <= num_mrr_cmd_seq ? MR_READ_MRR39 : MR_READ_MRR36;
                dqsosc_loadmr_snoop_en <= num_mrr_cmd_seq ? 4'b1000 : 4'b0010;
           end else begin
                dqsosc_loadmr_a        <= MR_READ_MRR19;
              dqsosc_loadmr_snoop_en <= 4'b0010;
           end
          end
       end
    end



  assign dqsosc_state =  (state_dqsosc==STATE_DQSOSC_START)       ? 3'b001 :
                         (state_dqsosc==STATE_DQSOSC_RUNTIME)     ? 3'b010 :
                         (state_dqsosc==STATE_DQSOSC_GET_RESULT1) ? 3'b011 :
                         (state_dqsosc==STATE_DQSOSC_WAIT1)       ? 3'b100 :
                         (state_dqsosc==STATE_DQSOSC_GET_RESULT2) ? 3'b101 :
                         (state_dqsosc==STATE_DQSOSC_WAIT2)       ? 3'b110 : 3'b000;
  assign dqsosc_per_rank_stat   = (state_dqsosc!=STATE_DQSOSC_IDLE);
  assign dqsosc_block_other_cmd = mrr_in_prog;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// Detecting the entry of MEMC_GS_ST_SELFREF_EX1 state. In case SR due to phymstr_req_req, it exits without entering MEMC_GS_ST_SELFREF_EX1 state 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
  assign global_fsm_state_is_sr_ex1 = (gs_dh_global_fsm_state == GS_ST_SELFREF_EX1);
  always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : global_fsm_state_is_sr_ex1_d1_PROC
     if (!core_ddrc_rstn) begin
        global_fsm_state_is_sr_ex1_d1  <= 1'b0;
     end else begin
        global_fsm_state_is_sr_ex1_d1  <= global_fsm_state_is_sr_ex1; 
     end
  end
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
// Latching the flag to indicate DQSOSC sequence is required on SR exit 
//-------------------------------------------------------------------------------------------------------------------------------------------------------------
  always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : trig_dqsosc_srx_PROC
     if (!core_ddrc_rstn) begin
        trig_dqsosc_srx  <= 1'b0;
     end else begin
        if (normal_operating_mode)
           trig_dqsosc_srx  <= 1'b0;
        else if (global_fsm_state_is_sr_ex1_d1 && (!global_fsm_state_is_sr_ex1) && (!reg_ddrc_dis_dqsosc_srx))
           trig_dqsosc_srx  <= 1'b1;
     end
  end  

  always_ff @(posedge co_yy_clk, negedge core_ddrc_rstn) begin : dqsosc_required_PROC
     if (!core_ddrc_rstn) begin
        dqsosc_required  <= 1'b0;
     end else begin
        if (trig_dqsosc & powerdown_operating_mode)
          dqsosc_required  <= 1'b1;
        else if (normal_operating_mode)
          dqsosc_required <= 1'b0;
     end
  end  


`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
//------------------------------------------------------------------------------
// Assertions
//------------------------------------------------------------------------------

  property p_dqsosc_interval;
    @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn) 
      (((dqsosc_interval_cnt==reg_ddrc_dqsosc_interval) || trig_dqsosc_srx) && dqsosc_interval_cnt_en)
      |-> |reg_ddrc_dqsosc_interval;
  endproperty

  a_dqsosc_interval: assert property (p_dqsosc_interval) 
  else $error ("%0t ERROR reg_ddrc_dqsosc_interval is not programmed to non zero before enabling DQSOSC", $time); 

  property p_trig_dqsosc_runtime;
    @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn) 
      (((dqsosc_interval_cnt==reg_ddrc_dqsosc_interval) || trig_dqsosc_srx) && dqsosc_interval_cnt_en)
      |-> |reg_ddrc_dqsosc_runtime;
  endproperty

  a_trig_dqsosc_runtime: assert property (p_trig_dqsosc_runtime) 
  else $error ("%0t ERROR reg_ddrc_dqsosc_runtime is not programmed to non zero before enabling DQSOSC", $time);

  property p_trig_dqsosc_runtime_lpddr5;
    @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn || reg_ddrc_lpddr4) 
      (((dqsosc_interval_cnt==reg_ddrc_dqsosc_interval) || trig_dqsosc_srx) && dqsosc_interval_cnt_en)
      |-> |reg_ddrc_wck2dqo_runtime;
  endproperty

  a_trig_dqsosc_runtime_lpddr5: assert property (p_trig_dqsosc_runtime_lpddr5) 
  else $error ("%0t ERROR reg_ddrc_wck2dqo_runtime is not programmed to non zero before enabling DQSOSC", $time);  

 property p_dqsosc_loadmr_upd_req_pulse;
    @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn) 
      (dqsosc_loadmr_upd_req_p)
      |=> !dqsosc_loadmr_upd_req_p;
 endproperty   

  a_dqsosc_loadmr_upd_req_pulse: assert property (p_dqsosc_loadmr_upd_req_pulse) 
  else $error ("%0t ERROR dqsosc_loadmr_upd_req_p is not a pulse signal", $time);

 property p_dqsosc_loadmr_mpc_mrr;
    @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn) 
      (dqsosc_loadmr_upd_req_p)
      |-> (dqsosc_loadmr_mpc || dqsosc_loadmr_mrr);
 endproperty   

  a_dqsosc_loadmr_mpc_mrr : assert property (p_dqsosc_loadmr_mpc_mrr) 
  else $error ("%0t ERROR dqsosc issued non MPC.MRR command", $time);  

 //property p_dqsosc_loadmr_mpc_stable;
 //   @ (posedge co_yy_clk) disable iff (~core_ddrc_rstn) 
 //     (dqsosc_loadmr_upd_req_p)
 //     |-> $stable(dqsosc_loadmr_mpc) until_with loadmr_dqsosc_upd_done_p;
 //endproperty   

 // a_dqsosc_loadmr_mpc_stable: assert property (p_dqsosc_loadmr_mpc_stable) 
//  else $error ("%0t ERROR dqsosc_loadmr_mpc changes between dqsosc_loadmr_upd_req_p and loadmr_dqsosc_upd_done_p event", $time); 



`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON
endmodule //gs_dqsosc
