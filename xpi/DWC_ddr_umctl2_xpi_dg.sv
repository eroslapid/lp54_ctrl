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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/xpi/DWC_ddr_umctl2_xpi_dg.sv#1 $
// -------------------------------------------------------------------------
// Description:
//         uMCTL XPI ENIF Dummy Generator
`include "DWC_ddrctl_all_defs.svh"
module DWC_ddr_umctl2_xpi_dg
  #(
    parameter NAB          = 2,
    parameter M_DW         = 32,            // SDRAM data width
    parameter PDBW_CASE     = 0, //Case1:1 ... Case5:5 
    parameter INFOW        = 4,
    parameter ENIF_DATAW   = 8,
    parameter ENIF_STRBW   = 1,  
    parameter ENIF_PARW    = 5,
    parameter ENIF_LENW    = 6,                   // AXI a*len width
    parameter ENIF_SIZEW   = 3,                   // AXI a*size width
    parameter MAXSIZE      = 2,
    parameter ENIF_MAXSIZE = 3,
    parameter NBEATS_LG2   = 1,
    parameter XPI_BRW      = 3,
    parameter MEMC_BURST_LENGTH = 8,
    parameter UMCTL2_PARTIAL_WR_EN = 0,
    parameter DUAL_CHANNEL_INTERLEAVE  = 0,
    parameter OCCAP_EN     = 0,
    parameter OCCAP_PIPELINE_EN = 0,
    parameter OCECC_EN     = 0
    )
  
                              (
   input                                clk,           // clock
   input                                rst_n,         // asynchronous reset
   input                                rst_dly,
   input [INFOW-1:0]                    info,
   input                                wr,           // write
   input                                rd,           // read
   input [ENIF_DATAW-1:0]               wdata_in,
   input [ENIF_STRBW-1:0]               wstrb_in,
   input [ENIF_STRBW-1:0]               wpar_err_in,
   input [ENIF_PARW-1:0]                wparity_in,
   input                                wparity_type,
   input [XPI_BRW-1:0]                  reg_burst_rdwr,
   input                                reg_ddrc_occap_en,
   input[1:0]                           reg_ddrc_data_bus_width,
//spyglass disable_block W240
//SMD: Inputs declared but not read
//SJ: Used in generate block.
   input                                reg_xpi_short_write_dis,
   input                                reg_xpi_short_write_dis_bl8_nab1,
   input                                reg_xpi_short_write_dis_bl8_nab1_1or3beats,
   input                                reg_xpi_short_write_dis_bl16_nab1,
   input                                reg_xpi_short_write_dis_bl16_nab2,
   input                                reg_xpi_short_write_dis_mbl16_bl8_nab2,
   input                                reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2,
   input                                reg_xpi_short_write_dis_mbl16_bl4_nab2,
   input                                reg_xpi_short_write_dis_bl16_qbw_nab1,
   input                                reg_xpi_short_write_dis_bl16_hbw,
   input                                reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1,
   input                                reg_xpi_short_write_dis_bl16_fbw_nab1,
   input                                reg_xpi_short_write_dis_mbl16_bl4_nab1,
   input                                reg_xpi_short_write_dis_mbl16_bl8_bc_fbw,
   input                                reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1,
//spyglass enable_block W240
   output                               empty,        // DG empty 
   output                               full,         // DG full
   output                               last_pkt,
   output [NBEATS_LG2-1:0]              wbeat_count,
   output [ENIF_DATAW-1:0]              wdata_out,
   output [ENIF_STRBW-1:0]              wstrb_out,
   output [ENIF_STRBW-1:0]              wpar_err_out,
   output [ENIF_PARW-1:0]               wparity_out,
   output                               short_write,
   output                               occap_xpi_dg_par_err
  );

  localparam COMM_SEQ_W = ENIF_LENW+ENIF_MAXSIZE;

  localparam OCCAP_CTRLW =  NBEATS_LG2 + // beat_count 
                            ENIF_STRBW + // wstrb_reg  
                            ENIF_STRBW;  // wpar_err_reg
   localparam SL_W = 8;
   localparam PARW = ((OCCAP_CTRLW%SL_W>0) ? OCCAP_CTRLW/SL_W+1 : OCCAP_CTRLW/SL_W);
   
   localparam BYTE_PARW = (OCECC_EN==1) ? 5 : 1;
   localparam FBW           = 2'b00;
   localparam HBW           = 2'b01;
   localparam QBW           = 2'b10;

  
  //---------------------------------------------------------------------------
  // Internal Signals
  //---------------------------------------------------------------------------
  reg [NBEATS_LG2-1:0]                  beat_count; 
  reg [NBEATS_LG2-1:0]                  beat_count_nxt; 
  wire                                  last_index;  
  wire [ENIF_LENW-1:0]                  alen;         // AXI first INCR burst length
  wire [ENIF_SIZEW-1:0]                 asize;         // AXI burst size
  wire                                  split_unused;
  wire [MAXSIZE-1:0]                    addr_offset;
  wire                                  last_beat_axi;
  wire                                  first_beat_axi;
  
  wire [ENIF_LENW-1:0]                  axi_beat_count_reg;
  reg [ENIF_LENW-1:0]                   axi_beat_count_next;

  wire [ENIF_MAXSIZE-1:0]               add_offset_cur;
  wire [ENIF_MAXSIZE-1:0]               add_offset_upd;
  
  wire [ENIF_MAXSIZE:0]                 size_byte;

  reg [ENIF_MAXSIZE-1:0]                addr_offset_align;
  wire [ENIF_MAXSIZE-1:0]               addr_offset_reg;
  wire [ENIF_MAXSIZE-1:0]               addr_offset_next;
  wire [NBEATS_LG2-1:0]                 beat_num_end;    

  reg [ENIF_DATAW-1:0]                  wdata_reg;
  reg [ENIF_STRBW-1:0]                  wstrb_reg; 
  reg [ENIF_PARW-1:0]                   wparity_reg;
  reg [ENIF_STRBW-1:0]                  wpar_err_reg; 
  wire [ENIF_STRBW-1:0]                 wstrb_reg_nxt;
  wire [ENIF_STRBW-1:0]                 wpar_err_reg_nxt;
  wire [ENIF_DATAW-1:0]                 wdata_next;
  wire [ENIF_DATAW-1:0]                 wdata_disp;
  wire [ENIF_STRBW-1:0]                 wstrb_next;
  wire [ENIF_STRBW-1:0]                 wstrb_disp;
  wire [ENIF_STRBW-1:0]                 wpar_err_next;
  wire [ENIF_PARW-1:0]                  wparity_next;
  wire [ENIF_PARW-1:0]                  wparity_disp;
  wire [XPI_BRW-1:0]                    bl_beat_num;

  wire                                  short_write_i;
  wire                                  short_write_dis;
  wire [3:0]                            e_addr_col;

  wire                                  common_r_par_err;
  wire                                  occap_xpi_dg_ctrl_par_err;
  wire                                  bypass_case2_case3;
  wire                                  dwsize_case2;

  generate
    if (UMCTL2_PARTIAL_WR_EN==1)  begin: partial_wr_en_1
      if (MEMC_BURST_LENGTH==16) begin: memc_bl16
         if (NAB==1) begin: bl16_nab1
            // if (MEMC_BURST_LENGTH==16) 1:1 (NAB=1)
            // disable RMW generation due to short_write
            // Disable if BL8 and QBW
            // Or
            // Disable if BL4 and QBW or HBW
            // Or
            // Disable if BL16 and QBW only if:
            //                                  * 2 beats and starting beat 0 or 2 or 4 or 6
            //                                  * 4 beats and starting beat 0 or 2 or 4
            //                                  * 6 beats and starting beat 0 or 2
            // Or
            // Disable if BL8 and HBW only if:
            //                                  * 2 beats and starting beat 0 or 2 or 4 or 6
            //                                  * 4 beats and starting beat 0 or 2 or 4
            //                                  * 6 beats and starting beat 0 or 2
            // Disable if BL16 and HBW only if 4 beats and starting beat 0 or 4
            // Or
            // Disable if BL8 or BL4 and FBW only if 4 beats and starting beat 0 or 4
            // Or
            // Disable if BL4 and FBW only if:
            //                                  * 2 beats and starting beat 0 or 2 or 4 or 6
            //                                  * 4 beats and starting beat 2 (other conditions covered above, beat 0 and 4)
            //                                  * 6 beats and starting beat 0 or 2
            // Or
            // Disable if BL8 and FBW and bc4 only if:
            //                                  * 2 beats and starting beat 4 or 6
            //                                  * 6 beats and starting beat 0
            // Or
            // Disalbe if BL8 and HBW and bc4 only if:
            //                                  * 1 beat and starting beat 6 or 7
            //                                  * 3 beats and starting beat 4
            //                                  * 5 beats and starting beat 2
            //                                  * 7 beats and starting beat 0
            if (DUAL_CHANNEL_INTERLEAVE==0) begin: DCH_intlv_dis

               assign short_write_dis  = (reg_xpi_short_write_dis) ? ((reg_xpi_short_write_dis_bl16_nab1) ? 1'b1 : 
                                                                   (reg_xpi_short_write_dis_bl16_qbw_nab1 && ((beat_count==1 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==3 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==5 && e_addr_col[1]==1'b0))) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1 && ((beat_count==1 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==3 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==5 && e_addr_col[1]==1'b0))) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_bl16_hbw && (beat_count==3 && e_addr_col[2:1]==2'b00)) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_bl16_fbw_nab1 && (beat_count==3 && e_addr_col[2:1]==2'b00)) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_mbl16_bl4_nab1 && ((beat_count==1 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==3 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==5 && e_addr_col[1]==1'b0))) ? 1'b1 : 
                                                                   (reg_xpi_short_write_dis_mbl16_bl8_bc_fbw && ((beat_count==1 && e_addr_col[1]==1'b0 && e_addr_col[3]==1'b1) ||
                                                                                                                      (beat_count==5 && e_addr_col[2:1]==2'b00))) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1 && ((beat_count==0 && e_addr_col[3:2]==2'b11) ||
                                                                                                                      (beat_count==2 && e_addr_col[3]==1'b1 && e_addr_col[1]==1'b0) ||
                                                                                                                      (beat_count==4 && e_addr_col[2:1]==2'b10) ||
                                                                                                                      (beat_count==6 && e_addr_col[1]==1'b0))) ? 1'b1 : 1'b0) : 1'b0;
            end
            else begin: DCH_intlv_en

               assign short_write_dis  = (reg_xpi_short_write_dis) ? ((reg_xpi_short_write_dis_bl16_nab1) ? 1'b1 : 
                                                                   (reg_xpi_short_write_dis_bl16_qbw_nab1 && ((beat_count==0 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==1 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==2 && e_addr_col[1]==1'b0))) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_mbl16_bl8_hbw_nab1 && ((beat_count==0 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==1 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==2 && e_addr_col[1]==1'b0))) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_bl16_hbw && (beat_count==1 && e_addr_col[2:1]==2'b00)) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_bl16_fbw_nab1 && (beat_count==1 && e_addr_col[2:1]==2'b00)) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_mbl16_bl4_nab1 && ((beat_count==0 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==1 && e_addr_col[1]==1'b0) ||
                                                                                                              (beat_count==2 && e_addr_col[1]==1'b0))) ? 1'b1 : 
                                                                   (reg_xpi_short_write_dis_mbl16_bl8_bc_fbw && ((beat_count==0 && e_addr_col[1]==1'b0 && e_addr_col[3]==1'b1) ||
                                                                                                                      (beat_count==2 && e_addr_col[2:1]==2'b00))) ? 1'b1 :
                                                                   (reg_xpi_short_write_dis_mbl16_bl8_bc_hbw_nab1 && ((beat_count==0 && e_addr_col[3:2]==2'b11) ||
                                                                                                                      (beat_count==1 && e_addr_col[3]==1'b1 && e_addr_col[1]==1'b0) ||
                                                                                                                      (beat_count==2 && e_addr_col[2:1]==2'b10) ||
                                                                                                                      (beat_count==3 && e_addr_col[1]==1'b0))) ? 1'b1 : 1'b0) : 1'b0;

            end

         end
         else if (NAB==2) begin: bl16_nab2
            // if (MEMC_BURST_LENGTH==16) 1:1 (NAB=2)
            // disable RMW generation due to short_write
            // Disabled if BL16 and QBW irrespective of number of beats
            // Or
            // Disable if BL8 and QBW or HBW irrespective of number of beats
            // Or
            // Disable if BL8 and FBW and if only 2 beats (of possible 4 beats) of HIF data and HIF addr[2:0]==0
            // assumes HIF address is always HIF-data aligned which is the case 
            // Or
            // Disable if BL8 and FBW and if only 1 beat and starting beat 2 or 3 (bc4) or 3 beats and starting beat 0
            // Or
            // Disable if BL16 and HBW and if only 2 beats and starting beat 0 and 2
            if (DUAL_CHANNEL_INTERLEAVE==0) begin: DCH_intlv_dis

               assign short_write_dis  = reg_xpi_short_write_dis ? ((reg_xpi_short_write_dis_mbl16_bl4_nab2) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_mbl16_bl8_nab2) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_bl16_nab2) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2 && beat_count==1 && e_addr_col[2:1]==2'b00) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_mbl16_bl8_bc_fbw && ((beat_count==0 && e_addr_col[3]==1'b1) ||
                                                                                                               (beat_count==2 && e_addr_col[3:1]==3'b000))) ? 1'b1 : 
                                                                 (reg_xpi_short_write_dis_bl16_hbw && beat_count==1 && e_addr_col[2]==1'b0) ? 1'b1 : 1'b0) : 1'b0;
            
            end
            else begin: DCH_intlv_en

               assign short_write_dis  = reg_xpi_short_write_dis ? ((reg_xpi_short_write_dis_mbl16_bl4_nab2) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_mbl16_bl8_nab2) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_bl16_nab2) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_mbl16_bl8_fbw_nbeats2_nab2 && beat_count==0 && e_addr_col[2:1]==2'b00) ? 1'b1 :
                                                                 (reg_xpi_short_write_dis_mbl16_bl8_bc_fbw && ((beat_count==0 && e_addr_col[3]==1'b1) ||
                                                                                                               (beat_count==1 && e_addr_col[3:1]==3'b000))) ? 1'b1 : 
                                                                 (reg_xpi_short_write_dis_bl16_hbw && beat_count==0 && e_addr_col[2]==1'b0) ? 1'b1 : 1'b0) : 1'b0;

            end
         
         end else begin //bl16_nab3
             //New HBW and QBW applicable in controller with NAB=3
             assign short_write_dis = (reg_xpi_short_write_dis && beat_count==0) ? 1'b1 : 1'b0;
         end

      // if (MEMC_BURST_LENGTH==8) 1:2 (NAB=2) 
      // disable RMW generation due to short_write 
      // if only 1 beat (of possible 2 beats) of HIF data
      // assumes HIF address is always HIF-data aligned which is the case 
      end else if (MEMC_BURST_LENGTH==8 && NAB==2) begin : memc_bl8_nab2
        assign short_write_dis = (reg_xpi_short_write_dis && beat_count==0) ? 1'b1 : 1'b0;

      // if (MEMC_BURST_LENGTH==8) 1:1 (NAB=1) 
      // disable RMW generation due to short_write 
      // if safe to disable irrespective of numner of HIF data beats 
      // i.e. if 1 HIF data beat corresponds one SDRAM Column
      // OR
      // if only 2 beats (of possible 4 beats) of HIF data and HIF addr[1]==0
      // i.e. COL=0, 4 
      // assumes HIF address is always HIF-data aligned which is the case 
      // OR
      // if only 3 beats (of possible 4 beats) of HIF data and HIF addr[2:0]==0
      // i.e. COL=0, not COL=2, 4, 6 etc
      // assumes HIF address is always HIF-data aligned which is the case 
      // OR
      // if only 1 beat (of possible 4beats ) of HIF data and HIF addr[2]==1
      // i.e COL=8, 12 
      end else if (MEMC_BURST_LENGTH==8 && NAB==1) begin : memc_bl8_nab1

         if (DUAL_CHANNEL_INTERLEAVE==0) begin: DCH_intlv_dis

            assign short_write_dis = (reg_xpi_short_write_dis_bl8_nab1)                               ? 1'b1 :
                                 (reg_xpi_short_write_dis && beat_count==1 && e_addr_col[1]==1'b0)    ? 1'b1 : 
                                 (reg_xpi_short_write_dis_bl8_nab1_1or3beats && beat_count==2 && e_addr_col[2:0]==3'b000) ? 1'b1 : 
                                 (reg_xpi_short_write_dis_bl8_nab1_1or3beats && beat_count==0 &&   e_addr_col[2]==1'b1 ) ? 1'b1 : 
                                                                                                                                  1'b0;
         
         end
         else begin: DCH_intlv_en

            assign short_write_dis = (reg_xpi_short_write_dis_bl8_nab1)                               ? 1'b1 :
                                 (reg_xpi_short_write_dis && beat_count==0 && e_addr_col[1]==1'b0)    ? 1'b1 : 
                                 (reg_xpi_short_write_dis_bl8_nab1_1or3beats && beat_count==1 && e_addr_col[2:0]==3'b000) ? 1'b1 : 
                                 (reg_xpi_short_write_dis_bl8_nab1_1or3beats && beat_count==0 &&   e_addr_col[2]==1'b1 ) ? 1'b1 : 
                                                                                                                                  1'b0;

         end

      // if (MEMC_BURST_LENGTH==4) 1:1 only
      // disable RMW generation due to short_write 
      // if only 1 beat (of possible 2 beats) of HIF data
      // assumes HIF address is always HIF-data aligned which is the case 
      end else if (MEMC_BURST_LENGTH==4) begin : memc_bl4
        assign short_write_dis = (reg_xpi_short_write_dis && beat_count==0) ? 1'b1 : 1'b0;

      end
    // if PARTIAL_WR ogic does not exist, disabling of short_write never
    // occurs
    end else if (UMCTL2_PARTIAL_WR_EN==0)  begin: partial_wr_en_0
      assign short_write_dis = 1'b0;
    end
  endgenerate

      
  assign short_write_i = last_pkt && (beat_count!=bl_beat_num[NBEATS_LG2-1:0]) ? 1'b1:1'b0;

  // combine with short_write_dis to mask RMW generation in cases where
  // Partial Writes will occur
  assign short_write   = ~short_write_dis & short_write_i;

 // generate
 //   if (NAB==2)  begin: x4_bl
 //     if (DUAL_CHANNEL_INTERLEAVE==0) begin: DCH_intlv_dis
 //        assign bl_beat_num = {1'b0,reg_burst_rdwr[XPI_BRW-1:1]}-1;
 //     end
 //     else begin: DCH_intlv_en
 //        assign bl_beat_num = {2'b00,reg_burst_rdwr[XPI_BRW-1:2]}-1;
 //     end
 //   end
 //   if (NAB==1)  begin: x2_bl
 //     if (DUAL_CHANNEL_INTERLEAVE==0) begin: DCH_intlv_dis
 //        assign bl_beat_num = reg_burst_rdwr[XPI_BRW-1:0]-1;
 //     end
 //     else begin: DCH_intlv_en
 //        assign bl_beat_num = {1'b0,reg_burst_rdwr[XPI_BRW-1:1]}-1;
 //     end
 //   end
 // endgenerate

//spyglass disable_block TA_09
//SMD: Net 'DWC_ddrctl.U_arb_top.\arb_port[6].U_xpi .U_xpi_write.U_dg.reg_burst_rdwr[3:2]' [in 'DWC_ddr_umctl2_xpi_dg'] is not observable[affected by other input(s)]
//SJ: Functionally correct as reg_burst_rdwr can only take fixed values (4'b0001, 4'b0010, 4'b0100, 4'b1000) depending on configuration.
  assign bl_beat_num = (reg_burst_rdwr[XPI_BRW-1:0] >> (NAB-1+DUAL_CHANNEL_INTERLEAVE)) - 1;
//spyglass enable_block TA_09

  assign empty      = ~(wr&last_index);
  assign full       = ~rd & last_index;


    always @ (*) begin: beat_count_COMB_PROC
      if (~empty & rd) begin
        if (last_pkt) 
          beat_count_nxt = {(NBEATS_LG2){1'b0}};
        else 
          beat_count_nxt = beat_count + 1;
      end else begin
        beat_count_nxt  = beat_count;

      end
    end // always @ (*)


  always @ (posedge clk or negedge rst_n) begin: beat_count_SEQ_PROC
    if (rst_n == 1'b0) begin
      beat_count <= {(NBEATS_LG2){1'b0}};
    end
    else  begin
      beat_count <= beat_count_nxt;
    end // else: !if(rst_n == 1'b0)
  end // always @ (posedge clk or negedge rst_n)

  assign wbeat_count       = beat_count;
  assign last_pkt          = (beat_num_end==beat_count) ? 1'b1:last_beat_axi;
  //spyglass disable_block W528
  //SMD: Variable e_addr_col is set but never read
  //SJ: Used in generate block
  assign {e_addr_col[3:0],split_unused,addr_offset,alen,asize,beat_num_end} = info;
  //spyglass enable_block W528
  assign last_beat_axi     = (axi_beat_count_reg== alen) ? 1'b1 : 1'b0;
  assign first_beat_axi    = (axi_beat_count_reg== {(ENIF_LENW){1'b0}}) ? 1'b1 : 1'b0; 
  
  generate
  if(PDBW_CASE==0) begin : no_pgdbw
     assign last_index =  (add_offset_upd == (1'b1<<ENIF_MAXSIZE)) ? 1'b1 : last_beat_axi;
     assign bypass_case2_case3 = 1'b0;
     assign dwsize_case2 = 1'b0;
  end else begin : prgdbw
     //ENIF_MAXSIZE in HBW =  ENIF_MAXSIZE-1 
     //ENIF_MAXSIZE in QBW =  ENIF_MAXSIZE-2 
     assign last_index   =  ( ((reg_ddrc_data_bus_width == HBW) && (add_offset_upd[ENIF_MAXSIZE-2:0] == (1'b1<<(ENIF_MAXSIZE-1))) ) ||
                              ((reg_ddrc_data_bus_width == QBW) && (add_offset_upd[ENIF_MAXSIZE-3:0] == (1'b1<<(ENIF_MAXSIZE-2))) ) ||
                              (add_offset_upd == (1'b1<<ENIF_MAXSIZE))
                            )  ? 1'b1 : last_beat_axi;

     assign bypass_case2_case3 = ((PDBW_CASE==2) & (reg_ddrc_data_bus_width == HBW)) ||
                                 ((PDBW_CASE==3) & (reg_ddrc_data_bus_width == QBW)) ; 

     assign dwsize_case2 =        ((PDBW_CASE==2) & (reg_ddrc_data_bus_width == QBW)) ; 
  end 
  endgenerate
  
  assign size_byte         = 1'b1 << asize;
  //spyglass disable_block W164a
  //SMD: LHS: 'add_offset_upd' width 5 is less than RHS: '(add_offset_cur + size_byte[(ENIF_MAXSIZE - 1):0] )' width 6 in assignment 
  //SJ: Overflow expected. See bug5632, comment #19.
  assign add_offset_upd    = add_offset_cur + size_byte[ENIF_MAXSIZE-1:0];
  //spyglass enable_block W164a
  assign add_offset_cur    = first_beat_axi ? addr_offset_align : addr_offset_reg;
  assign addr_offset_next  = (wr&~full) ? add_offset_upd : addr_offset_reg;  

  always @(*) begin: align_addr_to_size_COMB_PROC
    integer i;
    for (i=0; i<ENIF_MAXSIZE;i=i+1) begin
      if (i<asize)
        addr_offset_align[i]= 1'b0;
      else 
        addr_offset_align[i]= addr_offset[i];
      
    end
  end

  wire [COMM_SEQ_W-1:0] common_r_in, common_r_out;

  assign common_r_in = {axi_beat_count_next,addr_offset_next};
  assign {axi_beat_count_reg,addr_offset_reg} = common_r_out;

   DWC_ddr_umctl2_par_reg
   
   #(
      .DW      (COMM_SEQ_W),
      .OCCAP   (OCCAP_EN),
      .OCCAP_PIPELINE_EN (OCCAP_PIPELINE_EN)    
   )
   U_common_r
   (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_in    (common_r_in),
      .reg_set    (1'b0),
      .parity_en  (reg_ddrc_occap_en),
      .poison_en  (1'b0),
      .data_out   (common_r_out),
      .parity_err (common_r_par_err)
    );

  always @ (*) begin:axi_beat_count_COMB_PROC
    axi_beat_count_next =  axi_beat_count_reg;
    if (wr&~full) begin 
      if (last_beat_axi)
        axi_beat_count_next = {(ENIF_LENW){1'b0}};
      else 
        axi_beat_count_next = axi_beat_count_reg+1;
    end
    
  end // always @ begin

  // drive *_nxt of wstr_reg/wpar_err_reg
  assign wstrb_reg_nxt    = wr&rd&last_index ? {(ENIF_STRBW){1'b0}}:wstrb_next;
  assign wpar_err_reg_nxt = wr&rd&last_index ? {(ENIF_STRBW){1'b0}}:wpar_err_next;


  always @ (posedge clk or negedge rst_n) begin:common_SEQ_PROC
    if (rst_n == 1'b0) begin
      wdata_reg            <= {(ENIF_DATAW){1'b0}};
      wstrb_reg            <= {(ENIF_STRBW){1'b0}};   
      wpar_err_reg         <= {(ENIF_STRBW){1'b0}};
      wparity_reg          <= {(ENIF_PARW){1'b0}};
    end
    else  begin
      wdata_reg            <= wr&rd&last_index ? {(ENIF_DATAW){1'b0}}:wdata_next;
      wstrb_reg            <= wstrb_reg_nxt; 
      wpar_err_reg         <= wpar_err_reg_nxt;
      wparity_reg          <= ((wr&rd&last_index) | rst_dly) ? {(ENIF_PARW){wparity_type}}:wparity_next;
    end // else: !if(rst_n == 1'b0)
  end // always @ (posedge clk or negedge rst_n)

  //spyglass disable_block SelfDeterminedExpr-ML
  //SMD: Self determined expression '(gv * 8)' found in module 'DWC_ddr_umctl2_xpi_dg'
  //SJ: This coding style is acceptable and there is no plan to change it.
  genvar gv;
  generate
    for(gv=0;gv<ENIF_STRBW;gv=gv+1) begin:DATA_ACCU 
      assign wdata_next[gv*8+:8] = (wr&wstrb_in[gv]) ? (wdata_in[gv*8+:8] | wdata_reg[gv*8+:8]) : wdata_reg[gv*8+:8];
      assign wparity_next[gv*BYTE_PARW+:BYTE_PARW] = (wr&wstrb_in[gv]) ? wparity_in[gv*BYTE_PARW+:BYTE_PARW] : wparity_reg[gv*BYTE_PARW+:BYTE_PARW];
    end
  endgenerate
  //spyglass enable_block SelfDeterminedExpr-ML      

  assign occap_xpi_dg_par_err = common_r_par_err | occap_xpi_dg_ctrl_par_err;

  assign wstrb_next     = wr ? wstrb_reg | wstrb_in:wstrb_reg;
  //assign wparity_next   = wr ? wparity_reg | wparity_in:wparity_reg; // TODO
  assign wpar_err_next  = wr ? wpar_err_reg | wpar_err_in:wpar_err_reg;
  assign wdata_out      = wdata_disp;
  assign wstrb_out      = wstrb_disp;
  assign wparity_out    = wparity_disp;
  assign wpar_err_out   = wpar_err_next;

  generate
  if(PDBW_CASE == 0) begin : disp_dis
    assign wdata_disp = wdata_next;  
    assign wstrb_disp = wstrb_next;  
    assign wparity_disp = wparity_next;
  end else begin : disp_en   

    wire [1:0] disp_bus_seg;
    assign disp_bus_seg = bypass_case2_case3 ? 2'b00 :
                          dwsize_case2       ? {1'b0,add_offset_cur[ENIF_MAXSIZE-2]}
                                             : add_offset_cur[ENIF_MAXSIZE-1:ENIF_MAXSIZE-2];

    // Disperser inst for wdata  
    DWC_ddr_umctl2_xpi_disp
     #(
        .ENIF_DATAW  (ENIF_DATAW ), 
        .NAB         (NAB        ), 
        .XBW_CHK     (M_DW       ),
        .M_DW        (M_DW       )
        )
    U_disp_wdata (
        .in_data     (wdata_next    ), 
        .bus_width   (reg_ddrc_data_bus_width  ),
        .bus_seg     (disp_bus_seg),
        .fill        (1'b0          ), //Pad with 0 for invalid bytes
        .out_data    (wdata_disp   )
            );
    
    // Disperser inst for wstrb  
    DWC_ddr_umctl2_xpi_disp
     #(
            .ENIF_DATAW  (ENIF_STRBW ), 
            .NAB         (NAB        ),
            .XBW_CHK     (M_DW       ), //Check condition needs M_DW. 
            .M_DW        (M_DW/8     )  //MEMORY Mask is M_DW/8 wide
        )
     U_disp_wstrb (
            .in_data     (wstrb_next    ), 
            .bus_width   (reg_ddrc_data_bus_width  ),
            .bus_seg     (disp_bus_seg),
            .fill        (1'b1         ), //Pad with 1 for Mask
            .out_data    (wstrb_disp   )
        ); 

    // Disperser inst for wparity_in  
    DWC_ddr_umctl2_xpi_disp
     #(
            .ENIF_DATAW  (ENIF_PARW  ), 
            .NAB         (NAB        ),
            .XBW_CHK     (M_DW       ), //Check condition needs M_DW. 
            .M_DW        (M_DW/8     ),  //MEMORY Mask is M_DW/8 wide
            .BYTE_PARW   (BYTE_PARW  )  // in case of OCECC byte parity is 5 bits, 1 for all other cases
        )
     U_disp_wparity (
            .in_data     (wparity_next    ), 
            .bus_width   (reg_ddrc_data_bus_width  ),
            .bus_seg     (disp_bus_seg),
            .fill        (1'b0), 
            .out_data    (wparity_disp   )
        ); 


  end  
  endgenerate
 
  

    //---------------------------------------------------------------------------
  // OCCAP_EN process
  // for control related registers on clk
  //---------------------------------------------------------------------------


  generate
   if (OCCAP_EN==1) begin: OCCAP_en

     
     wire [OCCAP_CTRLW-1:0] pgen_in;  
     wire [OCCAP_CTRLW-1:0] pcheck_in;  

     // 
     // wiring of pgen_in/pcheck_in
     //
     assign pgen_in    = {beat_count_nxt,
                          wstrb_reg_nxt,
                          wpar_err_reg_nxt};

     assign pcheck_in  = {beat_count,
                          wstrb_reg,
                          wpar_err_reg};


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
            .DW      (OCCAP_CTRLW), 
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
            .DW      (OCCAP_CTRLW),
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

           assign occap_xpi_dg_ctrl_par_err = pcheck_par_err_r;          

         end else begin : OCCAP_PIPELINE_EN_0
         
           assign occap_xpi_dg_ctrl_par_err = |pcheck_par_err;

         end 

         
   end else begin: OCCAP_ne
      assign occap_xpi_dg_ctrl_par_err = 1'b0;
  end
  endgenerate

`ifdef SNPS_ASSERT_ON
`ifndef SYNTHESIS
  
  `assert_x_value(ERROR_XPI_DG_INFO_SIGNAL_VALUE_X,wr,info);
  
`endif // SYNTHESIS
`endif // SNPS_ASSERT_ON

  //-----------------------------------------------------------------------
endmodule // DWC_ddr_umctl2_xpi_dg
