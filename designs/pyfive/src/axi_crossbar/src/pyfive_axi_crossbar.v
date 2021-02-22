/***********************************************************************
*                  project     : pyfive
*                  file        : pyfive_axi_crossbar.v
*                  Author      : Dinesh A (dinesha@pyfive.org)
*                  git Repo    : https://github.com/py-five
*                  File Name   :
*  revision:
*       0.1 - 15th Feb 2021, Dinesh A
*             Initial version Generated from https://github.com/alexforencich/verilog-axi
*             command : python3 axi_crossbar_wrap.py -p 2 4  -n pyfive_axi_crossbar -o pyfive_axi_crossbar.v
*             configuration: Slave Port - 2 & Master Port - 4
*
************************************************************************/
/*  Comment from Orginal Owner

Copyright (c) 2020 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4 2x4 crossbar (wrapper)
 */
module pyfive_axi_crossbar #
(
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Input ID field width (from AXI masters)
    parameter S_ID_WIDTH = 8,
    // Output ID field width (towards AXI slaves)
    // Additional bits required for response routing
    parameter M_ID_WIDTH = S_ID_WIDTH+$clog2(S_COUNT),
    // Propagate awuser signal
    parameter AWUSER_ENABLE = 0,
    // Width of awuser signal
    parameter AWUSER_WIDTH = 1,
    // Propagate wuser signal
    parameter WUSER_ENABLE = 0,
    // Width of wuser signal
    parameter WUSER_WIDTH = 1,
    // Propagate buser signal
    parameter BUSER_ENABLE = 0,
    // Width of buser signal
    parameter BUSER_WIDTH = 1,
    // Propagate aruser signal
    parameter ARUSER_ENABLE = 0,
    // Width of aruser signal
    parameter ARUSER_WIDTH = 1,
    // Propagate ruser signal
    parameter RUSER_ENABLE = 0,
    // Width of ruser signal
    parameter RUSER_WIDTH = 1,
    // Number of concurrent unique IDs
    parameter S00_THREADS = 2,
    // Number of concurrent operations
    parameter S00_ACCEPT = 16,
    // Number of concurrent unique IDs
    parameter S01_THREADS = 2,
    // Number of concurrent operations
    parameter S01_ACCEPT = 16,
    // Number of regions per master interface
    parameter M_REGIONS = 1,
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M00_BASE_ADDR = 0,
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M00_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M00_CONNECT_READ = 2'b11,
    // Write connections between interfaces
    // S_COUNT bits
    parameter M00_CONNECT_WRITE = 2'b11,
    // Number of concurrent operations for each master interface
    parameter M00_ISSUE = 4,
    // Secure master (fail operations based on awprot/arprot)
    parameter M00_SECURE = 0,
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M01_BASE_ADDR = 0,
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M01_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M01_CONNECT_READ = 2'b11,
    // Write connections between interfaces
    // S_COUNT bits
    parameter M01_CONNECT_WRITE = 2'b11,
    // Number of concurrent operations for each master interface
    parameter M01_ISSUE = 4,
    // Secure master (fail operations based on awprot/arprot)
    parameter M01_SECURE = 0,
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M02_BASE_ADDR = 0,
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M02_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M02_CONNECT_READ = 2'b11,
    // Write connections between interfaces
    // S_COUNT bits
    parameter M02_CONNECT_WRITE = 2'b11,
    // Number of concurrent operations for each master interface
    parameter M02_ISSUE = 4,
    // Secure master (fail operations based on awprot/arprot)
    parameter M02_SECURE = 0,
    // Master interface base addresses
    // M_REGIONS concatenated fields of ADDR_WIDTH bits
    parameter M03_BASE_ADDR = 0,
    // Master interface address widths
    // M_REGIONS concatenated fields of 32 bits
    parameter M03_ADDR_WIDTH = {M_REGIONS{32'd24}},
    // Read connections between interfaces
    // S_COUNT bits
    parameter M03_CONNECT_READ = 2'b11,
    // Write connections between interfaces
    // S_COUNT bits
    parameter M03_CONNECT_WRITE = 2'b11,
    // Number of concurrent operations for each master interface
    parameter M03_ISSUE = 4,
    // Secure master (fail operations based on awprot/arprot)
    parameter M03_SECURE = 0,
    // Slave interface AW channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_AW_REG_TYPE = 0,
    // Slave interface W channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_W_REG_TYPE = 0,
    // Slave interface B channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_B_REG_TYPE = 1,
    // Slave interface AR channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_AR_REG_TYPE = 0,
    // Slave interface R channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S00_R_REG_TYPE = 2,
    // Slave interface AW channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_AW_REG_TYPE = 0,
    // Slave interface W channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_W_REG_TYPE = 0,
    // Slave interface B channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_B_REG_TYPE = 1,
    // Slave interface AR channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_AR_REG_TYPE = 0,
    // Slave interface R channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter S01_R_REG_TYPE = 2,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M00_R_REG_TYPE = 0,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M01_R_REG_TYPE = 0,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M02_R_REG_TYPE = 0,
    // Master interface AW channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_AW_REG_TYPE = 1,
    // Master interface W channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_W_REG_TYPE = 2,
    // Master interface B channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_B_REG_TYPE = 0,
    // Master interface AR channel register type (output)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_AR_REG_TYPE = 1,
    // Master interface R channel register type (input)
    // 0 to bypass, 1 for simple buffer, 2 for skid buffer
    parameter M03_R_REG_TYPE = 0
)
(
    input  wire                     clk,
    input  wire                     rst,

    /*
     * AXI slave interface
     */
    input  wire [S_ID_WIDTH-1:0]    s00_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s00_axi_awaddr,
    input  wire [7:0]               s00_axi_awlen,
    input  wire [2:0]               s00_axi_awsize,
    input  wire [1:0]               s00_axi_awburst,
    input  wire                     s00_axi_awlock,
    input  wire [3:0]               s00_axi_awcache,
    input  wire [2:0]               s00_axi_awprot,
    input  wire [3:0]               s00_axi_awqos,
    input  wire [AWUSER_WIDTH-1:0]  s00_axi_awuser,
    input  wire                     s00_axi_awvalid,
    output wire                     s00_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s00_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s00_axi_wstrb,
    input  wire                     s00_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s00_axi_wuser,
    input  wire                     s00_axi_wvalid,
    output wire                     s00_axi_wready,
    output wire [S_ID_WIDTH-1:0]    s00_axi_bid,
    output wire [1:0]               s00_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s00_axi_buser,
    output wire                     s00_axi_bvalid,
    input  wire                     s00_axi_bready,
    input  wire [S_ID_WIDTH-1:0]    s00_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s00_axi_araddr,
    input  wire [7:0]               s00_axi_arlen,
    input  wire [2:0]               s00_axi_arsize,
    input  wire [1:0]               s00_axi_arburst,
    input  wire                     s00_axi_arlock,
    input  wire [3:0]               s00_axi_arcache,
    input  wire [2:0]               s00_axi_arprot,
    input  wire [3:0]               s00_axi_arqos,
    input  wire [ARUSER_WIDTH-1:0]  s00_axi_aruser,
    input  wire                     s00_axi_arvalid,
    output wire                     s00_axi_arready,
    output wire [S_ID_WIDTH-1:0]    s00_axi_rid,
    output wire [DATA_WIDTH-1:0]    s00_axi_rdata,
    output wire [1:0]               s00_axi_rresp,
    output wire                     s00_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s00_axi_ruser,
    output wire                     s00_axi_rvalid,
    input  wire                     s00_axi_rready,

    input  wire [S_ID_WIDTH-1:0]    s01_axi_awid,
    input  wire [ADDR_WIDTH-1:0]    s01_axi_awaddr,
    input  wire [7:0]               s01_axi_awlen,
    input  wire [2:0]               s01_axi_awsize,
    input  wire [1:0]               s01_axi_awburst,
    input  wire                     s01_axi_awlock,
    input  wire [3:0]               s01_axi_awcache,
    input  wire [2:0]               s01_axi_awprot,
    input  wire [3:0]               s01_axi_awqos,
    input  wire [AWUSER_WIDTH-1:0]  s01_axi_awuser,
    input  wire                     s01_axi_awvalid,
    output wire                     s01_axi_awready,
    input  wire [DATA_WIDTH-1:0]    s01_axi_wdata,
    input  wire [STRB_WIDTH-1:0]    s01_axi_wstrb,
    input  wire                     s01_axi_wlast,
    input  wire [WUSER_WIDTH-1:0]   s01_axi_wuser,
    input  wire                     s01_axi_wvalid,
    output wire                     s01_axi_wready,
    output wire [S_ID_WIDTH-1:0]    s01_axi_bid,
    output wire [1:0]               s01_axi_bresp,
    output wire [BUSER_WIDTH-1:0]   s01_axi_buser,
    output wire                     s01_axi_bvalid,
    input  wire                     s01_axi_bready,
    input  wire [S_ID_WIDTH-1:0]    s01_axi_arid,
    input  wire [ADDR_WIDTH-1:0]    s01_axi_araddr,
    input  wire [7:0]               s01_axi_arlen,
    input  wire [2:0]               s01_axi_arsize,
    input  wire [1:0]               s01_axi_arburst,
    input  wire                     s01_axi_arlock,
    input  wire [3:0]               s01_axi_arcache,
    input  wire [2:0]               s01_axi_arprot,
    input  wire [3:0]               s01_axi_arqos,
    input  wire [ARUSER_WIDTH-1:0]  s01_axi_aruser,
    input  wire                     s01_axi_arvalid,
    output wire                     s01_axi_arready,
    output wire [S_ID_WIDTH-1:0]    s01_axi_rid,
    output wire [DATA_WIDTH-1:0]    s01_axi_rdata,
    output wire [1:0]               s01_axi_rresp,
    output wire                     s01_axi_rlast,
    output wire [RUSER_WIDTH-1:0]   s01_axi_ruser,
    output wire                     s01_axi_rvalid,
    input  wire                     s01_axi_rready,

    /*
     * AXI master interface
     */
    output wire [M_ID_WIDTH-1:0]    m00_axi_awid,
    output wire [ADDR_WIDTH-1:0]    m00_axi_awaddr,
    output wire [7:0]               m00_axi_awlen,
    output wire [2:0]               m00_axi_awsize,
    output wire [1:0]               m00_axi_awburst,
    output wire                     m00_axi_awlock,
    output wire [3:0]               m00_axi_awcache,
    output wire [2:0]               m00_axi_awprot,
    output wire [3:0]               m00_axi_awqos,
    output wire [3:0]               m00_axi_awregion,
    output wire [AWUSER_WIDTH-1:0]  m00_axi_awuser,
    output wire                     m00_axi_awvalid,
    input  wire                     m00_axi_awready,
    output wire [DATA_WIDTH-1:0]    m00_axi_wdata,
    output wire [STRB_WIDTH-1:0]    m00_axi_wstrb,
    output wire                     m00_axi_wlast,
    output wire [WUSER_WIDTH-1:0]   m00_axi_wuser,
    output wire                     m00_axi_wvalid,
    input  wire                     m00_axi_wready,
    input  wire [M_ID_WIDTH-1:0]    m00_axi_bid,
    input  wire [1:0]               m00_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]   m00_axi_buser,
    input  wire                     m00_axi_bvalid,
    output wire                     m00_axi_bready,
    output wire [M_ID_WIDTH-1:0]    m00_axi_arid,
    output wire [ADDR_WIDTH-1:0]    m00_axi_araddr,
    output wire [7:0]               m00_axi_arlen,
    output wire [2:0]               m00_axi_arsize,
    output wire [1:0]               m00_axi_arburst,
    output wire                     m00_axi_arlock,
    output wire [3:0]               m00_axi_arcache,
    output wire [2:0]               m00_axi_arprot,
    output wire [3:0]               m00_axi_arqos,
    output wire [3:0]               m00_axi_arregion,
    output wire [ARUSER_WIDTH-1:0]  m00_axi_aruser,
    output wire                     m00_axi_arvalid,
    input  wire                     m00_axi_arready,
    input  wire [M_ID_WIDTH-1:0]    m00_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m00_axi_rdata,
    input  wire [1:0]               m00_axi_rresp,
    input  wire                     m00_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]   m00_axi_ruser,
    input  wire                     m00_axi_rvalid,
    output wire                     m00_axi_rready,

    output wire [M_ID_WIDTH-1:0]    m01_axi_awid,
    output wire [ADDR_WIDTH-1:0]    m01_axi_awaddr,
    output wire [7:0]               m01_axi_awlen,
    output wire [2:0]               m01_axi_awsize,
    output wire [1:0]               m01_axi_awburst,
    output wire                     m01_axi_awlock,
    output wire [3:0]               m01_axi_awcache,
    output wire [2:0]               m01_axi_awprot,
    output wire [3:0]               m01_axi_awqos,
    output wire [3:0]               m01_axi_awregion,
    output wire [AWUSER_WIDTH-1:0]  m01_axi_awuser,
    output wire                     m01_axi_awvalid,
    input  wire                     m01_axi_awready,
    output wire [DATA_WIDTH-1:0]    m01_axi_wdata,
    output wire [STRB_WIDTH-1:0]    m01_axi_wstrb,
    output wire                     m01_axi_wlast,
    output wire [WUSER_WIDTH-1:0]   m01_axi_wuser,
    output wire                     m01_axi_wvalid,
    input  wire                     m01_axi_wready,
    input  wire [M_ID_WIDTH-1:0]    m01_axi_bid,
    input  wire [1:0]               m01_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]   m01_axi_buser,
    input  wire                     m01_axi_bvalid,
    output wire                     m01_axi_bready,
    output wire [M_ID_WIDTH-1:0]    m01_axi_arid,
    output wire [ADDR_WIDTH-1:0]    m01_axi_araddr,
    output wire [7:0]               m01_axi_arlen,
    output wire [2:0]               m01_axi_arsize,
    output wire [1:0]               m01_axi_arburst,
    output wire                     m01_axi_arlock,
    output wire [3:0]               m01_axi_arcache,
    output wire [2:0]               m01_axi_arprot,
    output wire [3:0]               m01_axi_arqos,
    output wire [3:0]               m01_axi_arregion,
    output wire [ARUSER_WIDTH-1:0]  m01_axi_aruser,
    output wire                     m01_axi_arvalid,
    input  wire                     m01_axi_arready,
    input  wire [M_ID_WIDTH-1:0]    m01_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m01_axi_rdata,
    input  wire [1:0]               m01_axi_rresp,
    input  wire                     m01_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]   m01_axi_ruser,
    input  wire                     m01_axi_rvalid,
    output wire                     m01_axi_rready,

    output wire [M_ID_WIDTH-1:0]    m02_axi_awid,
    output wire [ADDR_WIDTH-1:0]    m02_axi_awaddr,
    output wire [7:0]               m02_axi_awlen,
    output wire [2:0]               m02_axi_awsize,
    output wire [1:0]               m02_axi_awburst,
    output wire                     m02_axi_awlock,
    output wire [3:0]               m02_axi_awcache,
    output wire [2:0]               m02_axi_awprot,
    output wire [3:0]               m02_axi_awqos,
    output wire [3:0]               m02_axi_awregion,
    output wire [AWUSER_WIDTH-1:0]  m02_axi_awuser,
    output wire                     m02_axi_awvalid,
    input  wire                     m02_axi_awready,
    output wire [DATA_WIDTH-1:0]    m02_axi_wdata,
    output wire [STRB_WIDTH-1:0]    m02_axi_wstrb,
    output wire                     m02_axi_wlast,
    output wire [WUSER_WIDTH-1:0]   m02_axi_wuser,
    output wire                     m02_axi_wvalid,
    input  wire                     m02_axi_wready,
    input  wire [M_ID_WIDTH-1:0]    m02_axi_bid,
    input  wire [1:0]               m02_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]   m02_axi_buser,
    input  wire                     m02_axi_bvalid,
    output wire                     m02_axi_bready,
    output wire [M_ID_WIDTH-1:0]    m02_axi_arid,
    output wire [ADDR_WIDTH-1:0]    m02_axi_araddr,
    output wire [7:0]               m02_axi_arlen,
    output wire [2:0]               m02_axi_arsize,
    output wire [1:0]               m02_axi_arburst,
    output wire                     m02_axi_arlock,
    output wire [3:0]               m02_axi_arcache,
    output wire [2:0]               m02_axi_arprot,
    output wire [3:0]               m02_axi_arqos,
    output wire [3:0]               m02_axi_arregion,
    output wire [ARUSER_WIDTH-1:0]  m02_axi_aruser,
    output wire                     m02_axi_arvalid,
    input  wire                     m02_axi_arready,
    input  wire [M_ID_WIDTH-1:0]    m02_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m02_axi_rdata,
    input  wire [1:0]               m02_axi_rresp,
    input  wire                     m02_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]   m02_axi_ruser,
    input  wire                     m02_axi_rvalid,
    output wire                     m02_axi_rready,

    output wire [M_ID_WIDTH-1:0]    m03_axi_awid,
    output wire [ADDR_WIDTH-1:0]    m03_axi_awaddr,
    output wire [7:0]               m03_axi_awlen,
    output wire [2:0]               m03_axi_awsize,
    output wire [1:0]               m03_axi_awburst,
    output wire                     m03_axi_awlock,
    output wire [3:0]               m03_axi_awcache,
    output wire [2:0]               m03_axi_awprot,
    output wire [3:0]               m03_axi_awqos,
    output wire [3:0]               m03_axi_awregion,
    output wire [AWUSER_WIDTH-1:0]  m03_axi_awuser,
    output wire                     m03_axi_awvalid,
    input  wire                     m03_axi_awready,
    output wire [DATA_WIDTH-1:0]    m03_axi_wdata,
    output wire [STRB_WIDTH-1:0]    m03_axi_wstrb,
    output wire                     m03_axi_wlast,
    output wire [WUSER_WIDTH-1:0]   m03_axi_wuser,
    output wire                     m03_axi_wvalid,
    input  wire                     m03_axi_wready,
    input  wire [M_ID_WIDTH-1:0]    m03_axi_bid,
    input  wire [1:0]               m03_axi_bresp,
    input  wire [BUSER_WIDTH-1:0]   m03_axi_buser,
    input  wire                     m03_axi_bvalid,
    output wire                     m03_axi_bready,
    output wire [M_ID_WIDTH-1:0]    m03_axi_arid,
    output wire [ADDR_WIDTH-1:0]    m03_axi_araddr,
    output wire [7:0]               m03_axi_arlen,
    output wire [2:0]               m03_axi_arsize,
    output wire [1:0]               m03_axi_arburst,
    output wire                     m03_axi_arlock,
    output wire [3:0]               m03_axi_arcache,
    output wire [2:0]               m03_axi_arprot,
    output wire [3:0]               m03_axi_arqos,
    output wire [3:0]               m03_axi_arregion,
    output wire [ARUSER_WIDTH-1:0]  m03_axi_aruser,
    output wire                     m03_axi_arvalid,
    input  wire                     m03_axi_arready,
    input  wire [M_ID_WIDTH-1:0]    m03_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m03_axi_rdata,
    input  wire [1:0]               m03_axi_rresp,
    input  wire                     m03_axi_rlast,
    input  wire [RUSER_WIDTH-1:0]   m03_axi_ruser,
    input  wire                     m03_axi_rvalid,
    output wire                     m03_axi_rready
);

localparam S_COUNT = 2;
localparam M_COUNT = 4;

// parameter sizing helpers
function [ADDR_WIDTH*M_REGIONS-1:0] w_a_r(input [ADDR_WIDTH*M_REGIONS-1:0] val);
    w_a_r = val;
endfunction

function [32*M_REGIONS-1:0] w_32_r(input [32*M_REGIONS-1:0] val);
    w_32_r = val;
endfunction

function [S_COUNT-1:0] w_s(input [S_COUNT-1:0] val);
    w_s = val;
endfunction

function [31:0] w_32(input [31:0] val);
    w_32 = val;
endfunction

function [1:0] w_2(input [1:0] val);
    w_2 = val;
endfunction

function w_1(input val);
    w_1 = val;
endfunction

axi_crossbar #(
    .S_COUNT(S_COUNT),
    .M_COUNT(M_COUNT),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .STRB_WIDTH(STRB_WIDTH),
    .S_ID_WIDTH(S_ID_WIDTH),
    .M_ID_WIDTH(M_ID_WIDTH),
    .AWUSER_ENABLE(AWUSER_ENABLE),
    .AWUSER_WIDTH(AWUSER_WIDTH),
    .WUSER_ENABLE(WUSER_ENABLE),
    .WUSER_WIDTH(WUSER_WIDTH),
    .BUSER_ENABLE(BUSER_ENABLE),
    .BUSER_WIDTH(BUSER_WIDTH),
    .ARUSER_ENABLE(ARUSER_ENABLE),
    .ARUSER_WIDTH(ARUSER_WIDTH),
    .RUSER_ENABLE(RUSER_ENABLE),
    .RUSER_WIDTH(RUSER_WIDTH),
    .S_THREADS({ w_32(S01_THREADS), w_32(S00_THREADS) }),
    .S_ACCEPT({ w_32(S01_ACCEPT), w_32(S00_ACCEPT) }),
    .M_REGIONS(M_REGIONS),
    .M_BASE_ADDR({ w_a_r(M03_BASE_ADDR), w_a_r(M02_BASE_ADDR), w_a_r(M01_BASE_ADDR), w_a_r(M00_BASE_ADDR) }),
    .M_ADDR_WIDTH({ w_32_r(M03_ADDR_WIDTH), w_32_r(M02_ADDR_WIDTH), w_32_r(M01_ADDR_WIDTH), w_32_r(M00_ADDR_WIDTH) }),
    .M_CONNECT_READ({ w_s(M03_CONNECT_READ), w_s(M02_CONNECT_READ), w_s(M01_CONNECT_READ), w_s(M00_CONNECT_READ) }),
    .M_CONNECT_WRITE({ w_s(M03_CONNECT_WRITE), w_s(M02_CONNECT_WRITE), w_s(M01_CONNECT_WRITE), w_s(M00_CONNECT_WRITE) }),
    .M_ISSUE({ w_32(M03_ISSUE), w_32(M02_ISSUE), w_32(M01_ISSUE), w_32(M00_ISSUE) }),
    .M_SECURE({ w_1(M03_SECURE), w_1(M02_SECURE), w_1(M01_SECURE), w_1(M00_SECURE) }),
    .S_AR_REG_TYPE({ w_2(S01_AR_REG_TYPE), w_2(S00_AR_REG_TYPE) }),
    .S_R_REG_TYPE({ w_2(S01_R_REG_TYPE), w_2(S00_R_REG_TYPE) }),
    .S_AW_REG_TYPE({ w_2(S01_AW_REG_TYPE), w_2(S00_AW_REG_TYPE) }),
    .S_W_REG_TYPE({ w_2(S01_W_REG_TYPE), w_2(S00_W_REG_TYPE) }),
    .S_B_REG_TYPE({ w_2(S01_B_REG_TYPE), w_2(S00_B_REG_TYPE) }),
    .M_AR_REG_TYPE({ w_2(M03_AR_REG_TYPE), w_2(M02_AR_REG_TYPE), w_2(M01_AR_REG_TYPE), w_2(M00_AR_REG_TYPE) }),
    .M_R_REG_TYPE({ w_2(M03_R_REG_TYPE), w_2(M02_R_REG_TYPE), w_2(M01_R_REG_TYPE), w_2(M00_R_REG_TYPE) }),
    .M_AW_REG_TYPE({ w_2(M03_AW_REG_TYPE), w_2(M02_AW_REG_TYPE), w_2(M01_AW_REG_TYPE), w_2(M00_AW_REG_TYPE) }),
    .M_W_REG_TYPE({ w_2(M03_W_REG_TYPE), w_2(M02_W_REG_TYPE), w_2(M01_W_REG_TYPE), w_2(M00_W_REG_TYPE) }),
    .M_B_REG_TYPE({ w_2(M03_B_REG_TYPE), w_2(M02_B_REG_TYPE), w_2(M01_B_REG_TYPE), w_2(M00_B_REG_TYPE) })
)
UUT (
    .clk(clk),
    .rst(rst),
    .s_axi_awid({ s01_axi_awid, s00_axi_awid }),
    .s_axi_awaddr({ s01_axi_awaddr, s00_axi_awaddr }),
    .s_axi_awlen({ s01_axi_awlen, s00_axi_awlen }),
    .s_axi_awsize({ s01_axi_awsize, s00_axi_awsize }),
    .s_axi_awburst({ s01_axi_awburst, s00_axi_awburst }),
    .s_axi_awlock({ s01_axi_awlock, s00_axi_awlock }),
    .s_axi_awcache({ s01_axi_awcache, s00_axi_awcache }),
    .s_axi_awprot({ s01_axi_awprot, s00_axi_awprot }),
    .s_axi_awqos({ s01_axi_awqos, s00_axi_awqos }),
    .s_axi_awuser({ s01_axi_awuser, s00_axi_awuser }),
    .s_axi_awvalid({ s01_axi_awvalid, s00_axi_awvalid }),
    .s_axi_awready({ s01_axi_awready, s00_axi_awready }),
    .s_axi_wdata({ s01_axi_wdata, s00_axi_wdata }),
    .s_axi_wstrb({ s01_axi_wstrb, s00_axi_wstrb }),
    .s_axi_wlast({ s01_axi_wlast, s00_axi_wlast }),
    .s_axi_wuser({ s01_axi_wuser, s00_axi_wuser }),
    .s_axi_wvalid({ s01_axi_wvalid, s00_axi_wvalid }),
    .s_axi_wready({ s01_axi_wready, s00_axi_wready }),
    .s_axi_bid({ s01_axi_bid, s00_axi_bid }),
    .s_axi_bresp({ s01_axi_bresp, s00_axi_bresp }),
    .s_axi_buser({ s01_axi_buser, s00_axi_buser }),
    .s_axi_bvalid({ s01_axi_bvalid, s00_axi_bvalid }),
    .s_axi_bready({ s01_axi_bready, s00_axi_bready }),
    .s_axi_arid({ s01_axi_arid, s00_axi_arid }),
    .s_axi_araddr({ s01_axi_araddr, s00_axi_araddr }),
    .s_axi_arlen({ s01_axi_arlen, s00_axi_arlen }),
    .s_axi_arsize({ s01_axi_arsize, s00_axi_arsize }),
    .s_axi_arburst({ s01_axi_arburst, s00_axi_arburst }),
    .s_axi_arlock({ s01_axi_arlock, s00_axi_arlock }),
    .s_axi_arcache({ s01_axi_arcache, s00_axi_arcache }),
    .s_axi_arprot({ s01_axi_arprot, s00_axi_arprot }),
    .s_axi_arqos({ s01_axi_arqos, s00_axi_arqos }),
    .s_axi_aruser({ s01_axi_aruser, s00_axi_aruser }),
    .s_axi_arvalid({ s01_axi_arvalid, s00_axi_arvalid }),
    .s_axi_arready({ s01_axi_arready, s00_axi_arready }),
    .s_axi_rid({ s01_axi_rid, s00_axi_rid }),
    .s_axi_rdata({ s01_axi_rdata, s00_axi_rdata }),
    .s_axi_rresp({ s01_axi_rresp, s00_axi_rresp }),
    .s_axi_rlast({ s01_axi_rlast, s00_axi_rlast }),
    .s_axi_ruser({ s01_axi_ruser, s00_axi_ruser }),
    .s_axi_rvalid({ s01_axi_rvalid, s00_axi_rvalid }),
    .s_axi_rready({ s01_axi_rready, s00_axi_rready }),
    .m_axi_awid({ m03_axi_awid, m02_axi_awid, m01_axi_awid, m00_axi_awid }),
    .m_axi_awaddr({ m03_axi_awaddr, m02_axi_awaddr, m01_axi_awaddr, m00_axi_awaddr }),
    .m_axi_awlen({ m03_axi_awlen, m02_axi_awlen, m01_axi_awlen, m00_axi_awlen }),
    .m_axi_awsize({ m03_axi_awsize, m02_axi_awsize, m01_axi_awsize, m00_axi_awsize }),
    .m_axi_awburst({ m03_axi_awburst, m02_axi_awburst, m01_axi_awburst, m00_axi_awburst }),
    .m_axi_awlock({ m03_axi_awlock, m02_axi_awlock, m01_axi_awlock, m00_axi_awlock }),
    .m_axi_awcache({ m03_axi_awcache, m02_axi_awcache, m01_axi_awcache, m00_axi_awcache }),
    .m_axi_awprot({ m03_axi_awprot, m02_axi_awprot, m01_axi_awprot, m00_axi_awprot }),
    .m_axi_awqos({ m03_axi_awqos, m02_axi_awqos, m01_axi_awqos, m00_axi_awqos }),
    .m_axi_awregion({ m03_axi_awregion, m02_axi_awregion, m01_axi_awregion, m00_axi_awregion }),
    .m_axi_awuser({ m03_axi_awuser, m02_axi_awuser, m01_axi_awuser, m00_axi_awuser }),
    .m_axi_awvalid({ m03_axi_awvalid, m02_axi_awvalid, m01_axi_awvalid, m00_axi_awvalid }),
    .m_axi_awready({ m03_axi_awready, m02_axi_awready, m01_axi_awready, m00_axi_awready }),
    .m_axi_wdata({ m03_axi_wdata, m02_axi_wdata, m01_axi_wdata, m00_axi_wdata }),
    .m_axi_wstrb({ m03_axi_wstrb, m02_axi_wstrb, m01_axi_wstrb, m00_axi_wstrb }),
    .m_axi_wlast({ m03_axi_wlast, m02_axi_wlast, m01_axi_wlast, m00_axi_wlast }),
    .m_axi_wuser({ m03_axi_wuser, m02_axi_wuser, m01_axi_wuser, m00_axi_wuser }),
    .m_axi_wvalid({ m03_axi_wvalid, m02_axi_wvalid, m01_axi_wvalid, m00_axi_wvalid }),
    .m_axi_wready({ m03_axi_wready, m02_axi_wready, m01_axi_wready, m00_axi_wready }),
    .m_axi_bid({ m03_axi_bid, m02_axi_bid, m01_axi_bid, m00_axi_bid }),
    .m_axi_bresp({ m03_axi_bresp, m02_axi_bresp, m01_axi_bresp, m00_axi_bresp }),
    .m_axi_buser({ m03_axi_buser, m02_axi_buser, m01_axi_buser, m00_axi_buser }),
    .m_axi_bvalid({ m03_axi_bvalid, m02_axi_bvalid, m01_axi_bvalid, m00_axi_bvalid }),
    .m_axi_bready({ m03_axi_bready, m02_axi_bready, m01_axi_bready, m00_axi_bready }),
    .m_axi_arid({ m03_axi_arid, m02_axi_arid, m01_axi_arid, m00_axi_arid }),
    .m_axi_araddr({ m03_axi_araddr, m02_axi_araddr, m01_axi_araddr, m00_axi_araddr }),
    .m_axi_arlen({ m03_axi_arlen, m02_axi_arlen, m01_axi_arlen, m00_axi_arlen }),
    .m_axi_arsize({ m03_axi_arsize, m02_axi_arsize, m01_axi_arsize, m00_axi_arsize }),
    .m_axi_arburst({ m03_axi_arburst, m02_axi_arburst, m01_axi_arburst, m00_axi_arburst }),
    .m_axi_arlock({ m03_axi_arlock, m02_axi_arlock, m01_axi_arlock, m00_axi_arlock }),
    .m_axi_arcache({ m03_axi_arcache, m02_axi_arcache, m01_axi_arcache, m00_axi_arcache }),
    .m_axi_arprot({ m03_axi_arprot, m02_axi_arprot, m01_axi_arprot, m00_axi_arprot }),
    .m_axi_arqos({ m03_axi_arqos, m02_axi_arqos, m01_axi_arqos, m00_axi_arqos }),
    .m_axi_arregion({ m03_axi_arregion, m02_axi_arregion, m01_axi_arregion, m00_axi_arregion }),
    .m_axi_aruser({ m03_axi_aruser, m02_axi_aruser, m01_axi_aruser, m00_axi_aruser }),
    .m_axi_arvalid({ m03_axi_arvalid, m02_axi_arvalid, m01_axi_arvalid, m00_axi_arvalid }),
    .m_axi_arready({ m03_axi_arready, m02_axi_arready, m01_axi_arready, m00_axi_arready }),
    .m_axi_rid({ m03_axi_rid, m02_axi_rid, m01_axi_rid, m00_axi_rid }),
    .m_axi_rdata({ m03_axi_rdata, m02_axi_rdata, m01_axi_rdata, m00_axi_rdata }),
    .m_axi_rresp({ m03_axi_rresp, m02_axi_rresp, m01_axi_rresp, m00_axi_rresp }),
    .m_axi_rlast({ m03_axi_rlast, m02_axi_rlast, m01_axi_rlast, m00_axi_rlast }),
    .m_axi_ruser({ m03_axi_ruser, m02_axi_ruser, m01_axi_ruser, m00_axi_ruser }),
    .m_axi_rvalid({ m03_axi_rvalid, m02_axi_rvalid, m01_axi_rvalid, m00_axi_rvalid }),
    .m_axi_rready({ m03_axi_rready, m02_axi_rready, m01_axi_rready, m00_axi_rready })
);

endmodule
