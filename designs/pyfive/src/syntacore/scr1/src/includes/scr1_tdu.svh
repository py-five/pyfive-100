/// Copyright by Syntacore LLC © 2016-2020. See LICENSE for details
/// @file       <scr1_tdu.svh>
/// @brief      Trigger Debug Module header
///

`ifndef SCR1_INCLUDE_TDU_DEFS
`define SCR1_INCLUDE_TDU_DEFS

//`include "scr1_arch_description.svh"

`ifdef SCR1_TDU_EN
//`include "scr1_csr.svh"

`include "scr1_arch_description.svh"
//`include "scr1_arch_types.svh"
`include "scr1_csr.svh"

parameter bit [31:0] SCR1_TDU_MTRIG_NUM             = SCR1_TDU_TRIG_NUM; // cp.1
`ifdef SCR1_TDU_ICOUNT_EN
parameter bit [31:0] SCR1_TDU_ALLTRIG_NUM           = SCR1_TDU_MTRIG_NUM + 1'b1;// cp.1
`else
parameter bit [31:0] SCR1_TDU_ALLTRIG_NUM           = SCR1_TDU_MTRIG_NUM; // cp.1
`endif

parameter bit [31:0] SCR1_TDU_ADDR_W                = `SCR1_XLEN; // cp.1
parameter bit [31:0] SCR1_TDU_DATA_W                = `SCR1_XLEN; // cp.1

// Register map
parameter                                     SCR1_CSR_ADDR_TDU_OFFS_W        = 3;
parameter bit [SCR1_CSR_ADDR_TDU_OFFS_W-1:0]  SCR1_CSR_ADDR_TDU_OFFS_TSELECT  = 'h0;
parameter bit [SCR1_CSR_ADDR_TDU_OFFS_W-1:0]  SCR1_CSR_ADDR_TDU_OFFS_TDATA1   = 'h1;
parameter bit [SCR1_CSR_ADDR_TDU_OFFS_W-1:0]  SCR1_CSR_ADDR_TDU_OFFS_TDATA2   = 'h2;
parameter bit [SCR1_CSR_ADDR_TDU_OFFS_W-1:0]  SCR1_CSR_ADDR_TDU_OFFS_TINFO    = 'h4;


parameter bit [SCR1_CSR_ADDR_WIDTH-1:0] SCR1_CSR_ADDR_TDU_TSELECT       = SCR1_CSR_ADDR_TDU_MBASE + SCR1_CSR_ADDR_TDU_OFFS_TSELECT;
parameter bit [SCR1_CSR_ADDR_WIDTH-1:0] SCR1_CSR_ADDR_TDU_TDATA1        = SCR1_CSR_ADDR_TDU_MBASE + SCR1_CSR_ADDR_TDU_OFFS_TDATA1;
parameter bit [SCR1_CSR_ADDR_WIDTH-1:0] SCR1_CSR_ADDR_TDU_TDATA2        = SCR1_CSR_ADDR_TDU_MBASE + SCR1_CSR_ADDR_TDU_OFFS_TDATA2;
parameter bit [SCR1_CSR_ADDR_WIDTH-1:0] SCR1_CSR_ADDR_TDU_TINFO         = SCR1_CSR_ADDR_TDU_MBASE + SCR1_CSR_ADDR_TDU_OFFS_TINFO;

// TDATA1
parameter bit [31:0] SCR1_TDU_TDATA1_TYPE_HI        = `SCR1_XLEN-1; // cp.1
parameter bit [31:0] SCR1_TDU_TDATA1_TYPE_LO        = `SCR1_XLEN-4; // cp.1
parameter bit [31:0] SCR1_TDU_TDATA1_DMODE          = `SCR1_XLEN-5; // cp.1

// TDATA1: constant bits values
parameter bit           SCR1_TDU_TDATA1_DMODE_VAL      = 1'b0;

// MCONTROL: bits number
parameter bit [31:0] SCR1_TDU_MCONTROL_MASKMAX_HI   = `SCR1_XLEN-6; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_MASKMAX_LO   = `SCR1_XLEN-11; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_RESERVEDB_HI = `SCR1_XLEN-12; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_RESERVEDB_LO = 21; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_HIT          = 20; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_SELECT       = 19; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_TIMING       = 18; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_ACTION_HI    = 17; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_ACTION_LO    = 12; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_CHAIN        = 11; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_MATCH_HI     = 10; // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_MATCH_LO     = 7;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_M            = 6;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_RESERVEDA    = 5;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_S            = 4;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_U            = 3;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_EXECUTE      = 2;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_STORE        = 1;  // cp.1
parameter bit [31:0] SCR1_TDU_MCONTROL_LOAD         = 0;  // cp.1

// MCONTROL: constant bits values
parameter bit [SCR1_TDU_TDATA1_TYPE_HI-SCR1_TDU_TDATA1_TYPE_LO:0]
                        SCR1_TDU_MCONTROL_TYPE_VAL           = 2'd2;

parameter bit           SCR1_TDU_MCONTROL_SELECT_VAL         = 1'b0;
parameter bit           SCR1_TDU_MCONTROL_TIMING_VAL         = 1'b0;

parameter bit [SCR1_TDU_MCONTROL_MASKMAX_HI-SCR1_TDU_MCONTROL_MASKMAX_LO:0]
                        SCR1_TDU_MCONTROL_MASKMAX_VAL        = 1'b0;

parameter bit           SCR1_TDU_MCONTROL_RESERVEDA_VAL      = 1'b0;

// ICOUNT: bits number
parameter bit [31:0] SCR1_TDU_ICOUNT_DMODE          = `SCR1_XLEN-5; // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_RESERVEDB_HI   = `SCR1_XLEN-6; // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_RESERVEDB_LO   = 25; // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_HIT            = 24; // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_COUNT_HI       = 23; // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_COUNT_LO       = 10; // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_M              = 9;  // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_RESERVEDA      = 8;  // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_S              = 7;  // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_U              = 6;  // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_ACTION_HI      = 5;  // cp.1
parameter bit [31:0] SCR1_TDU_ICOUNT_ACTION_LO      = 0;  // cp.1

// ICOUNT: constant bits values
parameter bit [SCR1_TDU_TDATA1_TYPE_HI-SCR1_TDU_TDATA1_TYPE_LO:0]
                        SCR1_TDU_ICOUNT_TYPE_VAL             = 2'd3;

parameter bit [SCR1_TDU_ICOUNT_RESERVEDB_HI-SCR1_TDU_ICOUNT_RESERVEDB_LO:0]
                        SCR1_TDU_ICOUNT_RESERVEDB_VAL        = 1'b0;

parameter bit           SCR1_TDU_ICOUNT_RESERVEDA_VAL        = 1'b0;

// CPU pipeline monitors
typedef struct packed {
    logic                                           vd;
    logic                                           req;
    logic [`SCR1_XLEN-1:0]                          addr;
} type_scr1_brkm_instr_mon_s;

typedef struct packed {
    logic                                           vd;
    logic                                           load;
    logic                                           store;
    logic [`SCR1_XLEN-1:0]                          addr;
} type_scr1_brkm_lsu_mon_s;

`endif // SCR1_TDU_EN

`endif // SCR1_INCLUDE_TDU_DEFS
