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
// -- Revision: $Id: //dwh/ddr_iip/umctl5/DWC_ddrctl_lpddr54_MAIN_BR/DWC_ddr_umctl5/src/ih/ih_address_map_wrapper.sv#1 $
// -------------------------------------------------------------------------
// Description:
//       This module is a wrapper of ih_address_map
//
// ----------------------------------------------------------------------------
`include "DWC_ddrctl_all_defs.svh"
`include "apb/DWC_ddrctl_reg_pkg.svh"

module ih_address_map_wrapper 
import DWC_ddrctl_reg_pkg::*;
(
     am_block
    ,am_critical_dword
    ,am_row
    ,am_bg_bank
    ,am_cpu_address
    ,bg_b16_addr_mode
    ,am_bg_offset_bit0
    ,am_bg_offset_bit1
    ,am_bs_offset_bit0
    ,am_bs_offset_bit1
    ,am_bs_offset_bit2 
    ,am_column_offset_bit3
    ,am_column_offset_bit4
    ,am_column_offset_bit5
    ,am_column_offset_bit6
    ,am_column_offset_bit7
    ,am_column_offset_bit8
    ,am_column_offset_bit9
    ,am_column_offset_bit10
    ,am_row_offset_bit0
    ,am_row_offset_bit1
    ,am_row_offset_bit2
    ,am_row_offset_bit3
    ,am_row_offset_bit4
    ,am_row_offset_bit5
    ,am_row_offset_bit6
    ,am_row_offset_bit7
    ,am_row_offset_bit8
    ,am_row_offset_bit9
    ,am_row_offset_bit10
    ,am_row_offset_bit11
    ,am_row_offset_bit12
    ,am_row_offset_bit13
    ,am_row_offset_bit14
    ,am_row_offset_bit15
    ,am_row_offset_bit16
    ,am_row_offset_bit17

 //Inputs/outputs for het mapping
);


    parameter COL_BITS         = `MEMC_BLK_BITS + `MEMC_WORD_BITS;
    parameter CID_WIDTH        = `UMCTL2_CID_WIDTH;
    parameter LRANK_BITS       = `UMCTL2_LRANK_BITS;
    parameter AM_DCH_WIDTH     = 6;
    parameter AM_CS_WIDTH      = 6;
    parameter AM_CID_WIDTH     = 6;
    parameter AM_BANK_WIDTH    = 6;
    parameter AM_BG_WIDTH      = 6;
    parameter AM_ROW_WIDTH     = 5;
    parameter AM_COL_WIDTH_H   = 5;
    parameter AM_COL_WIDTH_L   = 4;



// IO DECLARATION
    output [`MEMC_BLK_BITS-1:0]         am_block;
    output [`MEMC_WORD_BITS-1:0]        am_critical_dword;
    output [`MEMC_PAGE_BITS-1:0]        am_row;
    output [`MEMC_BG_BANK_BITS-1:0]     am_bg_bank;
    input                               bg_b16_addr_mode;
    input  [`MEMC_HIF_ADDR_WIDTH-1:0]   am_cpu_address;


    input  [AM_BG_WIDTH-1:0]            am_bg_offset_bit0;
    input  [AM_BG_WIDTH-1:0]            am_bg_offset_bit1;

    input  [AM_BANK_WIDTH-1:0]          am_bs_offset_bit0;
    input  [AM_BANK_WIDTH-1:0]          am_bs_offset_bit1;
    input  [AM_BANK_WIDTH-1:0]          am_bs_offset_bit2;

    input  [AM_COL_WIDTH_L-1:0]         am_column_offset_bit3;
    input  [AM_COL_WIDTH_L-1:0]         am_column_offset_bit4;
    input  [AM_COL_WIDTH_L-1:0]         am_column_offset_bit5;
    input  [AM_COL_WIDTH_L-1:0]         am_column_offset_bit6;
    input  [AM_COL_WIDTH_H-1:0]         am_column_offset_bit7;
    input  [AM_COL_WIDTH_H-1:0]         am_column_offset_bit8;
    input  [AM_COL_WIDTH_H-1:0]         am_column_offset_bit9;
    input  [AM_COL_WIDTH_H-1:0]         am_column_offset_bit10;

    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit0;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit1;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit2;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit3;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit4;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit5;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit6;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit7;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit8;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit9;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit10;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit11;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit12;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit13;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit14;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit15;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit16;
    input  [AM_ROW_WIDTH-1:0]           am_row_offset_bit17;




// Intermediate wire
    // For map0
    wire    [`MEMC_BLK_BITS-1:0]        map0_am_block;
    wire    [`MEMC_WORD_BITS-1:0]       map0_am_critical_dword;
    wire    [`MEMC_PAGE_BITS-1:0]       map0_am_row;
    wire    [`MEMC_BG_BANK_BITS-1:0]    map0_am_bg_bank;



   assign am_block          = map0_am_block;
   assign am_critical_dword = map0_am_critical_dword;
   assign am_row            = map0_am_row;
   assign am_bg_bank        = map0_am_bg_bank;

// Instantiation

//-----------------------
// ih_address_map0 
//-----------------------
ih_address_map_pkt
  #(
         .COL_BITS                      (COL_BITS                     )
        ,.CID_WIDTH                     (CID_WIDTH                    )
        ,.LRANK_BITS                    (LRANK_BITS                   )
        ,.AM_DCH_WIDTH                  (AM_DCH_WIDTH                 )
        ,.AM_CS_WIDTH                   (AM_CS_WIDTH                  )
        ,.AM_CID_WIDTH                  (AM_CID_WIDTH                 )
        ,.AM_BANK_WIDTH                 (AM_BANK_WIDTH                )
        ,.AM_BG_WIDTH                   (AM_BG_WIDTH                  )
        ,.AM_ROW_WIDTH                  (AM_ROW_WIDTH                 )
        ,.AM_COL_WIDTH_H                (AM_COL_WIDTH_H               )
        ,.AM_COL_WIDTH_L                (AM_COL_WIDTH_L               )
) ih_address_map_pkt0 (
         .am_block                      (map0_am_block                )
        ,.am_critical_dword             (map0_am_critical_dword       )
        ,.am_row                        (map0_am_row                  )
        ,.am_bg_bank                    (map0_am_bg_bank              )
      


        ,.am_cpu_address                (am_cpu_address               )

        ,.bg_b16_addr_mode              (bg_b16_addr_mode             )

        ,.am_bs_offset_bit0             (am_bs_offset_bit0            )
        ,.am_bs_offset_bit1             (am_bs_offset_bit1            )
        ,.am_bs_offset_bit2             (am_bs_offset_bit2            )
        ,.am_bg_offset_bit0             (am_bg_offset_bit0            )
        ,.am_bg_offset_bit1             (am_bg_offset_bit1            )
        ,.am_row_offset_bit0            (am_row_offset_bit0           )
        ,.am_row_offset_bit1            (am_row_offset_bit1           )
        ,.am_row_offset_bit2            (am_row_offset_bit2           )
        ,.am_row_offset_bit3            (am_row_offset_bit3           )
        ,.am_row_offset_bit4            (am_row_offset_bit4           )
        ,.am_row_offset_bit5            (am_row_offset_bit5           )
        ,.am_row_offset_bit6            (am_row_offset_bit6           )
        ,.am_row_offset_bit7            (am_row_offset_bit7           )
        ,.am_row_offset_bit8            (am_row_offset_bit8           )
        ,.am_row_offset_bit9            (am_row_offset_bit9           )
        ,.am_row_offset_bit10           (am_row_offset_bit10          )
        ,.am_row_offset_bit11           (am_row_offset_bit11          )
        ,.am_row_offset_bit12           (am_row_offset_bit12          )
        ,.am_row_offset_bit13           (am_row_offset_bit13          )
        ,.am_row_offset_bit14           (am_row_offset_bit14          )
        ,.am_row_offset_bit15           (am_row_offset_bit15          )
        ,.am_row_offset_bit16           (am_row_offset_bit16          )
        ,.am_row_offset_bit17           (am_row_offset_bit17          )
        ,.am_column_offset_bit3         (am_column_offset_bit3        )
        ,.am_column_offset_bit4         (am_column_offset_bit4        )
        ,.am_column_offset_bit5         (am_column_offset_bit5        )
        ,.am_column_offset_bit6         (am_column_offset_bit6        )
        ,.am_column_offset_bit7         (am_column_offset_bit7        )
        ,.am_column_offset_bit8         (am_column_offset_bit8        )
        ,.am_column_offset_bit9         (am_column_offset_bit9        )
        ,.am_column_offset_bit10        (am_column_offset_bit10       )
);



endmodule // ih_address_map_wapper
