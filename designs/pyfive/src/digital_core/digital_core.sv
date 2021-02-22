/***********************************************************************
*                  project     : pyfive
*                  file        : digital_core.v
*                  Author      : Dinesh A (dinesha@pyfive.org)
*                  git Repo    : https://github.com/py-five
*                  Description :
*                     This is digital core and integrate all the main block
*                     here.  Following block are integrated here
*                        1. Risc V Core
*                        2. SPI Master
*                        3. AXI Cross Bar
*                        4. 
*  Revision:
*       0.1 - 16th Feb 2021, Dinesh A
*             Initial integration with Risc-V core + AXI Cross Bar + SPI
*             Master
*
************************************************************************/

`include "scr1_arch_description.svh"
`ifdef SCR1_IPIC_EN
`include "scr1_ipic.svh"
`endif // SCR1_IPIC_EN

module digital_core (
    input   logic                      clk,              // System clock
    input   logic                      rtc_clk,          // Real-time clock
    input   logic                      pwrup_rst_n,      // Power-Up Reset
    input   logic                      cpu_rst_n,        // CPU Reset (Core Reset)
    input logic                        rst_n,            // Regular Reset signal

`ifdef SCR1_DBG_EN
    output  logic                      sys_rst_n_o,      // External System Reset output
                                                         //   (for the processor cluster's components or
                                                         //    external SOC (could be useful in small
                                                         //    SCR-core-centric SOCs))
    output  logic                      sys_rdc_qlfy_o,   // System-to-External SOC Reset Domain Crossing Qualifier
    // Fuses
    input   logic [`SCR1_XLEN-1:0]     fuse_mhartid,     // Hart ID
`endif // SCR1_DBG_EN
`ifdef SCR1_DBG_EN
    input   logic [31:0]                            fuse_idcode,            // TAPC IDCODE
`endif // SCR1_DBG_EN
    // IRQ
`ifdef SCR1_IPIC_EN
    input   logic [SCR1_IRQ_LINES_NUM-1:0]          irq_lines,              // IRQ lines to IPIC
`else // SCR1_IPIC_EN
    input   logic                                   ext_irq,                // External IRQ input
`endif // SCR1_IPIC_EN
    input   logic                                   soft_irq,               // Software IRQ input

`ifdef SCR1_DBG_EN
    // -- JTAG I/F
    input   logic                       trst_n,
    input   logic                       tck,
    input   logic                       tms,
    input   logic                       tdi,
    output  logic                       tdo,
    output  logic                       tdo_en,
`endif // SCR1_DBG_EN

    // SPI Master I/F
    output logic                        spim_clk,
    output logic                        spim_csn0,
    output logic                        spim_csn1,
    output logic                        spim_csn2,
    output logic                        spim_csn3,
    output logic       [1:0]            spim_mode,
    output logic       [3:0]            spmio  // SPI Master I/O
);

//---------------------------------------------------
// Local Parameter Declaration
// --------------------------------------------------
 
// Number of AXI Slave
localparam  AXI4_S_COUNT = 2;

// Number of AXI Slave
localparam  AXI4_M_COUNT = 2;

// Width of data bus in bits
localparam  AXI4_DATA_WIDTH = 32;

// Width of address bus in bits
localparam AXI4_ADDR_WIDTH = 32;

// Width of wstrb (width of data bus in words)
localparam AXI4_STRB_WIDTH = (AXI4_DATA_WIDTH/8);

// Input ID field width (from AXI masters)
localparam AXI4_S_ID_WIDTH = 8;

// Output ID field width (towards AXI slaves)
// Additional bits required for response routing
localparam AXI4_M_ID_WIDTH = AXI4_S_ID_WIDTH+$clog2(AXI4_S_COUNT);

// Width of ruser signal
localparam AXI4_USER_WIDTH = 1;


/*************************************************************************************************
* RISCV AXI  interface - Instruction Memory
*************************************************************************************************/
// Write address channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_imem_awid     ;  // Write address ID. This signal is the identification tag for the write address group of signals.
logic [AXI4_ADDR_WIDTH-1:0]    riscv_axi_imem_awaddr   ;  // Write address. The write address gives the address of the first transfer in a write burst transaction.
logic [7:0]                    riscv_axi_imem_awlen    ;  // Burst length. The burst length gives the exact number of transfers in a burst. 
                                                          // This information determines the number of data transfers associated with the address
logic [2:0]                    riscv_axi_imem_awsize   ;  // Burst size. This signal indicates the size of each transfer in the burst. 
logic [1:0]                    riscv_axi_imem_awburst  ;  // Burst type. The burst type and the size information, 
                                                          // determine how the address for each transfer within the burst is calculated. 
logic                          riscv_axi_imem_awlock   ;  // Lock type. Provides additional information about the atomic characteristics of the transfer
logic [3:0]                    riscv_axi_imem_awcache  ;  // Memory type. This signal indicates how transactions are required to progress through a system. 
logic [2:0]                    riscv_axi_imem_awprot   ;  // Protection type. This signal indicates the privilege and security level of the transaction, 
                                                          // and whether the transaction is a data access or an instruction access
logic [3:0]                    riscv_axi_imem_awqos    ;  // Quality of Service, QoS. The QoS identifier sent for each write transaction.
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_imem_awuser   ;  // User signal. Optional User-defined signal in the write address channel.
logic                          riscv_axi_imem_awvalid  ;  // Write address valid. This signal indicates that the channel is signaling valid 
                                                          // write address and control information. 
logic                          riscv_axi_imem_awready  ;  // Write address ready. This signal indicates that the slave is ready to accept 
                                                          // an address and associated control signals. 

// Write data channel
logic [AXI4_DATA_WIDTH-1:0]    riscv_axi_imem_wdata    ;  // Write data.
logic [AXI4_STRB_WIDTH-1:0]    riscv_axi_imem_wstrb    ;  // Write strobes. This signal indicates which byte lanes hold valid data. 
                                                          // There is one write strobe bit for each eight bits of the write data bus.
logic                          riscv_axi_imem_wlast    ;  // Write last. This signal indicates the last transfer in a write burst. 
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_imem_wuser    ;  // User signal. Optional User-defined signal in the write data channel
logic                          riscv_axi_imem_wvalid   ;  // Write valid. This signal indicates that valid write data and strobes are available.
logic                          riscv_axi_imem_wready   ;  // Write ready. This signal indicates that the slave can accept the write data. 


// Write response channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_imem_bid      ;  // Response ID tag. This signal is the ID tag of the write response. 
logic [1:0]                    riscv_axi_imem_bresp    ;  // Write response. This signal indicates the status of the write transaction.
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_imem_buser    ;  // User signal. Optional User-defined signal in the write response channel.
logic                          riscv_axi_imem_bvalid   ;  // Write response valid. This signal indicates that the channel is signaling a valid write response. 
logic                          riscv_axi_imem_bready   ;  // Response ready. This signal indicates that the master can accept a write response.

// Read address channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_imem_arid     ;  // Read address ID. This signal is the identification tag for the read address group of signals.
logic [AXI4_ADDR_WIDTH-1:0]    riscv_axi_imem_araddr   ;  // Read address. The read address gives the address of the first transfer in a read burst transaction. 
logic [7:0]                    riscv_axi_imem_arlen    ;  // Burst length. This signal indicates the exact number of transfers in a burst. 
logic [2:0]                    riscv_axi_imem_arsize   ;  // Burst size. This signal indicates the size of each transfer in the burst.
logic [1:0]                    riscv_axi_imem_arburst  ;  // Burst type. The burst type and the size information determine how the address 
                                                          // for each transfer within the burst is calculated.
logic                          riscv_axi_imem_arlock   ;  // Lock type. This signal provides additional information about the atomic characteristics of the transfer.
logic [3:0]                    riscv_axi_imem_arcache  ;  // Memory type. This signal indicates how transactions are required to progress through a system.
logic [2:0]                    riscv_axi_imem_arprot   ;  // Protection type. This signal indicates the privilege and security level of the transaction, 
                                                          // and whether the transaction is a data access or an instruction access.
logic [3:0]                    riscv_axi_imem_arqos    ;  // Quality of Service, QoS. QoS identifier sent for each read transaction. 
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_imem_aruser   ;  // User signal. Optional User-defined signal in the read address channel.
logic                          riscv_axi_imem_arvalid  ;  // Read address valid. This signal indicates that the channel is signaling 
                                                          // valid read address and control information. 
logic                          riscv_axi_imem_arready  ;  // Read address ready. This signal indicates that the slave is ready to accept an 
                                                          // address and associated control signals.

// Read data channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_imem_rid      ;  // Read ID tag. This signal is the identification tag for the read data group 
                                                          // of signals generated by the slave.
logic [AXI4_DATA_WIDTH-1:0]    riscv_axi_imem_rdata    ;  // Read data
logic [1:0]                    riscv_axi_imem_rresp    ;  // Read response. This signal indicates the status of the read transfer.
logic                          riscv_axi_imem_rlast    ;  // Read last. This signal indicates the last transfer in a read burst.
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_imem_ruser    ;  // User signal. Optional User-defined signal in the read data channel.
logic                          riscv_axi_imem_rvalid   ;  // Read valid. This signal indicates that the channel is signaling the required read data.
logic                          riscv_axi_imem_rready   ;  // Read ready. This signal indicates that the master can accept the read data and response information.

/****************************************************************************************************
* RISCV AXI interface - Data Memory
****************************************************************************************************/

// Write address channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_dmem_awid     ;  // Write address ID. This signal is the identification tag for the write address group of signals.
logic [AXI4_ADDR_WIDTH-1:0]    riscv_axi_dmem_awaddr   ;  // Write address. The write address gives the address of the first transfer in a write burst transaction.
logic [7:0]                    riscv_axi_dmem_awlen    ;  // Burst length. The burst length gives the exact number of transfers in a burst. 
                                                          // This information determines the number of data transfers associated with the address
logic [2:0]                    riscv_axi_dmem_awsize   ;  // Burst size. This signal indicates the size of each transfer in the burst. 
logic [1:0]                    riscv_axi_dmem_awburst  ;  // Burst type. The burst type and the size information, 
                                                          // determine how the address for each transfer within the burst is calculated. 
logic                          riscv_axi_dmem_awlock   ;  // Lock type. Provides additional information about the atomic characteristics of the transfer
logic [3:0]                    riscv_axi_dmem_awcache  ;  // Memory type. This signal indicates how transactions are required to progress through a system. 
logic [2:0]                    riscv_axi_dmem_awprot   ;  // Protection type. This signal indicates the privilege and security level of the transaction, 
                                                          // and whether the transaction is a data access or an instruction access
logic [3:0]                    riscv_axi_dmem_awqos    ;  // Quality of Service, QoS. The QoS identifier sent for each write transaction.
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_dmem_awuser   ;  // User signal. Optional User-defined signal in the write address channel.
logic                          riscv_axi_dmem_awvalid  ;  // Write address valid. This signal indicates that the channel is signaling valid 
                                                          // write address and control information. 
logic                          riscv_axi_dmem_awready  ;  // Write address ready. This signal indicates that the slave is ready to accept 
                                                          // an address and associated control signals. 



// Write data channel
logic [AXI4_DATA_WIDTH-1:0]    riscv_axi_dmem_wdata    ;  // Write data.
logic [AXI4_STRB_WIDTH-1:0]    riscv_axi_dmem_wstrb    ;  // Write strobes. This signal indicates which byte lanes hold valid data. 
                                                          // There is one write strobe bit for each eight bits of the write data bus.
logic                          riscv_axi_dmem_wlast    ;  // Write last. This signal indicates the last transfer in a write burst. 
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_dmem_wuser    ;  // User signal. Optional User-defined signal in the write data channel
logic                          riscv_axi_dmem_wvalid   ;  // Write valid. This signal indicates that valid write data and strobes are available.
logic                          riscv_axi_dmem_wready   ;  // Write ready. This signal indicates that the slave can accept the write data. 


// Write response channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_dmem_bid      ;  // Response ID tag. This signal is the ID tag of the write response. 
logic [1:0]                    riscv_axi_dmem_bresp    ;  // Write response. This signal indicates the status of the write transaction.
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_dmem_buser    ;  // User signal. Optional User-defined signal in the write response channel.
logic                          riscv_axi_dmem_bvalid   ;  // Write response valid. This signal indicates that the channel is signaling a valid write response. 
logic                          riscv_axi_dmem_bready   ;  // Response ready. This signal indicates that the master can accept a write response.

// Read address channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_dmem_arid     ;  // Read address ID. This signal is the identification tag for the read address group of signals.
logic [AXI4_ADDR_WIDTH-1:0]    riscv_axi_dmem_araddr   ;  // Read address. The read address gives the address of the first transfer in a read burst transaction. 
logic [7:0]                    riscv_axi_dmem_arlen    ;  // Burst length. This signal indicates the exact number of transfers in a burst. 
logic [2:0]                    riscv_axi_dmem_arsize   ;  // Burst size. This signal indicates the size of each transfer in the burst.
logic [1:0]                    riscv_axi_dmem_arburst  ;  // Burst type. The burst type and the size information determine how the address for each transfer 
                                                          // within the burst is calculated.
logic                          riscv_axi_dmem_arlock   ;  // Lock type. This signal provides additional information about the atomic characteristics of the transfer.
logic [3:0]                    riscv_axi_dmem_arcache  ;  // Memory type. This signal indicates how transactions are required to progress through a system.
logic [2:0]                    riscv_axi_dmem_arprot   ;  // Protection type. This signal indicates the privilege and security level of the transaction, 
                                                          // and whether the transaction is a data access or an instruction access.
logic [3:0]                    riscv_axi_dmem_arqos    ;  // Quality of Service, QoS. QoS identifier sent for each read transaction. 
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_dmem_aruser   ;  // User signal. Optional User-defined signal in the read address channel.
logic                          riscv_axi_dmem_arvalid  ;  // Read address valid. This signal indicates that the channel is signaling 
                                                          // valid read address and control information. 
logic                          riscv_axi_dmem_arready  ;  // Read address ready. This signal indicates that the slave is ready to accept an 
                                                          // address and associated control signals.


// Read data channel
logic [AXI4_S_ID_WIDTH-1:0]    riscv_axi_dmem_rid      ;  // Read ID tag. This signal is the identification tag for the read data group 
                                                          // of signals generated by the slave.
logic [AXI4_DATA_WIDTH-1:0]    riscv_axi_dmem_rdata    ;  // Read data
logic [1:0]                    riscv_axi_dmem_rresp    ;  // Read response. This signal indicates the status of the read transfer.
logic                          riscv_axi_dmem_rlast    ;  // Read last. This signal indicates the last transfer in a read burst.
logic [AXI4_USER_WIDTH-1:0]    riscv_axi_dmem_ruser    ;  // User signal. Optional User-defined signal in the read data channel.
logic                          riscv_axi_dmem_rvalid   ;  // Read valid. This signal indicates that the channel is signaling the required read data.
logic                          riscv_axi_dmem_rready   ;  // Read ready. This signal indicates that the master can accept the read data and response information.


/*************************************************************************************************
* SPI Master AXI  interface - 
*************************************************************************************************/
// Write address channel
logic [AXI4_S_ID_WIDTH-1:0]    spim_axi_awid           ;  // Write address ID. This signal is the identification tag for the write address group of signals.
logic [AXI4_ADDR_WIDTH-1:0]    spim_axi_awaddr         ;  // Write address. The write address gives the address of the first transfer in a write burst transaction.
logic [7:0]                    spim_axi_awlen          ;  // Burst length. The burst length gives the exact number of transfers in a burst. 
                                                          // This information determines the number of data transfers associated with the address
logic [2:0]                    spim_axi_awsize         ;  // Burst size. This signal indicates the size of each transfer in the burst. 
logic [AXI4_USER_WIDTH-1:0]    spim_axi_awuser         ;  // User signal. Optional User-defined signal in the write address channel.
logic                          spim_axi_awvalid        ;  // Write address valid. This signal indicates that the channel is signaling valid 
                                                          // write address and control information. 
logic                          spim_axi_awready        ;  // Write address ready. This signal indicates that the slave is ready to accept 
                                                          // an address and associated control signals. 

// Write data channel
logic [AXI4_DATA_WIDTH-1:0]    spim_axi_wdata          ;  // Write data.
logic [AXI4_STRB_WIDTH-1:0]    spim_axi_wstrb          ;  // Write strobes. This signal indicates which byte lanes hold valid data. 
                                                          // There is one write strobe bit for each eight bits of the write data bus.
logic                          spim_axi_wlast          ;  // Write last. This signal indicates the last transfer in a write burst. 
logic [AXI4_USER_WIDTH-1:0]    spim_axi_wuser          ;  // User signal. Optional User-defined signal in the write data channel
logic                          spim_axi_wvalid         ;  // Write valid. This signal indicates that valid write data and strobes are available.
logic                          spim_axi_wready         ;  // Write ready. This signal indicates that the slave can accept the write data. 


// Write response channel
logic [AXI4_S_ID_WIDTH-1:0]    spim_axi_bid            ;  // Response ID tag. This signal is the ID tag of the write response. 
logic [1:0]                    spim_axi_bresp          ;  // Write response. This signal indicates the status of the write transaction.
logic [AXI4_USER_WIDTH-1:0]    spim_axi_buser          ;  // User signal. Optional User-defined signal in the write response channel.
logic                          spim_axi_bvalid         ;  // Write response valid. This signal indicates that the channel is signaling a valid write response. 
logic                          spim_axi_bready         ;  // Response ready. This signal indicates that the master can accept a write response.

// Read address channel
logic [AXI4_S_ID_WIDTH-1:0]    spim_axi_arid           ;  // Read address ID. This signal is the identification tag for the read address group of signals.
logic [AXI4_ADDR_WIDTH-1:0]    spim_axi_araddr         ;  // Read address. The read address gives the address of the first transfer in a read burst transaction. 
logic [7:0]                    spim_axi_arlen          ;  // Burst length. This signal indicates the exact number of transfers in a burst. 
logic [2:0]                    spim_axi_arsize         ;  // Burst size. This signal indicates the size of each transfer in the burst.
logic [AXI4_USER_WIDTH-1:0]    spim_axi_aruser         ;  // User signal. Optional User-defined signal in the read address channel.
logic                          spim_axi_arvalid        ;  // Read address valid. This signal indicates that the channel is signaling 
                                                          // valid read address and control information. 
logic                          spim_axi_arready        ;  // Read address ready. This signal indicates that the slave is ready to accept an 
                                                          // address and associated control signals.

// Read data channel
logic [AXI4_S_ID_WIDTH-1:0]    spim_axi_rid            ;  // Read ID tag. This signal is the identification tag for the read data group 
                                                          // of signals generated by the slave.
logic [AXI4_DATA_WIDTH-1:0]    spim_axi_rdata          ;  // Read data
logic [1:0]                    spim_axi_rresp          ;  // Read response. This signal indicates the status of the read transfer.
logic                          spim_axi_rlast          ;  // Read last. This signal indicates the last transfer in a read burst.
logic [AXI4_USER_WIDTH-1:0]    spim_axi_ruser          ;  // User signal. Optional User-defined signal in the read data channel.
logic                          spim_axi_rvalid         ;  // Read valid. This signal indicates that the channel is signaling the required read data.
logic                          spim_axi_rready         ;  // Read ready. This signal indicates that the master can accept the read data and response information.

//-----------------------------------------------------------
logic                          spi_en_tx               ; // SPI Pad directional control
logic                          spim_sdo0               ; // SPI Master Data Out[0]
logic                          spim_sdo1               ; // SPI Master Data Out[1]
logic                          spim_sdo2               ; // SPI Master Data Out[2]
logic                          spim_sdo3               ; // SPI Master Data Out[3]
logic                          spim_sdi0               ; // SPI Master Data In[0]
logic                          spim_sdi1               ; // SPI Master Data In[1]
logic                          spim_sdi2               ; // SPI Master Data In[2]
logic                          spim_sdi3               ; // SPI Master Data In[3]

assign  spmio[0]  =  (spi_en_tx) ? spim_sdo0 : 1'bz;
assign  spmio[1]  =  (spi_en_tx) ? spim_sdo1 : 1'bz;
assign  spmio[2]  =  (spi_en_tx) ? spim_sdo2 : 1'bz;
assign  spmio[3]  =  (spi_en_tx) ? spim_sdo3 : 1'bz;

assign  spim_sdi0 =   spmio[0];
assign  spim_sdi1 =   spmio[1];
assign  spim_sdi2 =   spmio[2];
assign  spim_sdi3 =   spmio[3];

//------------------------------------------------------------------------------
// RISC V Core instance
//------------------------------------------------------------------------------
scr1_top_axi u_riscv_top (
    // Reset
    .pwrup_rst_n            (pwrup_rst_n               ),
    .rst_n                  (rst_n                     ),
    .cpu_rst_n              (cpu_rst_n                 ),
`ifdef SCR1_DBG_EN
    .sys_rst_n_o            (sys_rst_n_o               ),
    .sys_rdc_qlfy_o         (sys_rdc_qlfy_o            ),
`endif // SCR1_DBG_EN

    // Clock
    .clk                    (clk                       ),
    .rtc_clk                (rtc_clk                   ),

    // Fuses
    .fuse_mhartid           (fuse_mhartid              ),
`ifdef SCR1_DBG_EN
    .fuse_idcode            (`SCR1_TAP_IDCODE          ),
`endif // SCR1_DBG_EN

    // IRQ
`ifdef SCR1_IPIC_EN
    .irq_lines              ('0                        ), // TODO - Interrupts
`else // SCR1_IPIC_EN
    .ext_irq                ('0                        ), // TODO - Interrupts
`endif // SCR1_IPIC_EN
    .soft_irq               ('0                        ), // TODO - Interrupts

    // DFT
    .test_mode              (1'b0                      ),
    .test_rst_n             (1'b1                      ),

`ifdef SCR1_DBG_EN
    // JTAG
    .trst_n                 (trst_n                    ),
    .tck                    (tck                       ),
    .tms                    (tms                       ),
    .tdi                    (tdi                       ),
    .tdo                    (tdo                       ),
    .tdo_en                 (tdo_en                    ),
`endif // SCR1_DBG_EN

    // Instruction memory interface
    .io_axi_imem_awid       (riscv_axi_imem_awid       ),
    .io_axi_imem_awaddr     (riscv_axi_imem_awaddr     ),
    .io_axi_imem_awlen      (riscv_axi_imem_awlen      ),
    .io_axi_imem_awsize     (riscv_axi_imem_awsize     ),
    .io_axi_imem_awburst    (riscv_axi_imem_awburst    ),
    .io_axi_imem_awlock     (riscv_axi_imem_awlock     ),
    .io_axi_imem_awcache    (riscv_axi_imem_awcache    ),
    .io_axi_imem_awprot     (riscv_axi_imem_awprot     ),
    .io_axi_imem_awregion   (                          ), // TODO - Cross-check
    .io_axi_imem_awuser     (riscv_axi_imem_awuser     ),
    .io_axi_imem_awqos      (riscv_axi_imem_awqos      ),
    .io_axi_imem_awvalid    (riscv_axi_imem_awvalid    ),
    .io_axi_imem_awready    (riscv_axi_imem_awready    ),
    .io_axi_imem_wdata      (riscv_axi_imem_wdata      ),
    .io_axi_imem_wstrb      (riscv_axi_imem_wstrb      ),
    .io_axi_imem_wlast      (riscv_axi_imem_wlast      ),
    .io_axi_imem_wuser      (riscv_axi_imem_wuser      ),
    .io_axi_imem_wvalid     (riscv_axi_imem_wvalid     ),
    .io_axi_imem_wready     (riscv_axi_imem_wready     ),
    .io_axi_imem_bid        (riscv_axi_imem_bid        ),
    .io_axi_imem_bresp      (riscv_axi_imem_bresp      ),
    .io_axi_imem_bvalid     (riscv_axi_imem_bvalid     ),
    .io_axi_imem_buser      (riscv_axi_imem_buser      ),
    .io_axi_imem_bready     (riscv_axi_imem_bready     ),
    .io_axi_imem_arid       (riscv_axi_imem_arid       ),
    .io_axi_imem_araddr     (riscv_axi_imem_araddr     ),
    .io_axi_imem_arlen      (riscv_axi_imem_arlen      ),
    .io_axi_imem_arsize     (riscv_axi_imem_arsize     ),
    .io_axi_imem_arburst    (riscv_axi_imem_arburst    ),
    .io_axi_imem_arlock     (riscv_axi_imem_arlock     ),
    .io_axi_imem_arcache    (riscv_axi_imem_arcache    ),
    .io_axi_imem_arprot     (riscv_axi_imem_arprot     ),
    .io_axi_imem_arregion   (                          ), // TODO - Cross-check
    .io_axi_imem_aruser     (riscv_axi_imem_aruser     ),
    .io_axi_imem_arqos      (riscv_axi_imem_arqos),
    .io_axi_imem_arvalid    (riscv_axi_imem_arvalid    ),
    .io_axi_imem_arready    (riscv_axi_imem_arready    ),
    .io_axi_imem_rid        (riscv_axi_imem_rid        ),
    .io_axi_imem_rdata      (riscv_axi_imem_rdata      ),
    .io_axi_imem_rresp      (riscv_axi_imem_rresp      ),
    .io_axi_imem_rlast      (riscv_axi_imem_rlast      ),
    .io_axi_imem_ruser      (riscv_axi_imem_ruser      ),
    .io_axi_imem_rvalid     (riscv_axi_imem_rvalid     ),
    .io_axi_imem_rready     (riscv_axi_imem_rready     ),

    // Data memory interface
    .io_axi_dmem_awid       (riscv_axi_dmem_awid       ),
    .io_axi_dmem_awaddr     (riscv_axi_dmem_awaddr     ),
    .io_axi_dmem_awlen      (riscv_axi_dmem_awlen      ),
    .io_axi_dmem_awsize     (riscv_axi_dmem_awsize     ),
    .io_axi_dmem_awburst    (riscv_axi_dmem_awburst    ),
    .io_axi_dmem_awlock     (riscv_axi_dmem_awlock     ),
    .io_axi_dmem_awcache    (riscv_axi_dmem_awcache    ),
    .io_axi_dmem_awprot     (riscv_axi_dmem_awprot     ),
    .io_axi_dmem_awregion   (                          ), // TODO - Cross check
    .io_axi_dmem_awuser     (riscv_axi_dmem_awuser     ),
    .io_axi_dmem_awqos      (riscv_axi_dmem_awqos      ),
    .io_axi_dmem_awvalid    (riscv_axi_dmem_awvalid    ),
    .io_axi_dmem_awready    (riscv_axi_dmem_awready    ),
    .io_axi_dmem_wdata      (riscv_axi_dmem_wdata      ),
    .io_axi_dmem_wstrb      (riscv_axi_dmem_wstrb      ),
    .io_axi_dmem_wlast      (riscv_axi_dmem_wlast      ),
    .io_axi_dmem_wuser      (riscv_axi_dmem_wuser      ),
    .io_axi_dmem_wvalid     (riscv_axi_dmem_wvalid     ),
    .io_axi_dmem_wready     (riscv_axi_dmem_wready     ),
    .io_axi_dmem_bid        (riscv_axi_dmem_bid        ),
    .io_axi_dmem_bresp      (riscv_axi_dmem_bresp      ),
    .io_axi_dmem_bvalid     (riscv_axi_dmem_bvalid     ),
    .io_axi_dmem_buser      (riscv_axi_dmem_buser      ),
    .io_axi_dmem_bready     (riscv_axi_dmem_bready     ),
    .io_axi_dmem_arid       (riscv_axi_dmem_arid       ),
    .io_axi_dmem_araddr     (riscv_axi_dmem_araddr     ),
    .io_axi_dmem_arlen      (riscv_axi_dmem_arlen      ),
    .io_axi_dmem_arsize     (riscv_axi_dmem_arsize     ),
    .io_axi_dmem_arburst    (riscv_axi_dmem_arburst    ),
    .io_axi_dmem_arlock     (riscv_axi_dmem_arlock     ),
    .io_axi_dmem_arcache    (riscv_axi_dmem_arcache    ),
    .io_axi_dmem_arprot     (riscv_axi_dmem_arprot     ),
    .io_axi_dmem_arregion   (                          ), // TODO - Cross-check
    .io_axi_dmem_aruser     (riscv_axi_dmem_aruser     ),
    .io_axi_dmem_arqos      (riscv_axi_dmem_arqos      ),
    .io_axi_dmem_arvalid    (riscv_axi_dmem_arvalid    ),
    .io_axi_dmem_arready    (riscv_axi_dmem_arready    ),
    .io_axi_dmem_rid        (riscv_axi_dmem_rid        ),
    .io_axi_dmem_rdata      (riscv_axi_dmem_rdata      ),
    .io_axi_dmem_rresp      (riscv_axi_dmem_rresp      ),
    .io_axi_dmem_rlast      (riscv_axi_dmem_rlast      ),
    .io_axi_dmem_ruser      (riscv_axi_dmem_ruser      ),
    .io_axi_dmem_rvalid     (riscv_axi_dmem_rvalid     ),
    .io_axi_dmem_rready     (riscv_axi_dmem_rready     )
);

/*********************************************************
* SPI Master
* This is an implementation of an SPI master that is controlled via an AXI bus. 
* It has FIFOs for transmitting and receiving data. 
* It supports both the normal SPI mode and QPI mode with 4 data lines.
* *******************************************************/

axi_spi_master
#(
    .AXI4_ADDRESS_WIDTH  (AXI4_ADDR_WIDTH),
    .AXI4_RDATA_WIDTH    (AXI4_DATA_WIDTH),
    .AXI4_WDATA_WIDTH    (AXI4_DATA_WIDTH),
    .AXI4_USER_WIDTH     (AXI4_USER_WIDTH),
    .AXI4_ID_WIDTH       (AXI4_M_ID_WIDTH),
    .BUFFER_DEPTH        (32)
) u_axi_spi_master
(
    .s_axi_aclk             (clk                ),
    .s_axi_aresetn          (rst_n              ),

    .s_axi_awvalid          (spim_axi_awvalid   ),
    .s_axi_awid             (spim_axi_awid      ),
    .s_axi_awlen            (spim_axi_awlen     ),
    .s_axi_awaddr           (spim_axi_awaddr    ),
    .s_axi_awuser           (spim_axi_awuser    ),
    .s_axi_awready          (spim_axi_awready   ),
                           
    .s_axi_wvalid           (spim_axi_wvalid    ),
    .s_axi_wdata            (spim_axi_wdata     ),
    .s_axi_wstrb            (spim_axi_wstrb     ),
    .s_axi_wlast            (spim_axi_wlast     ),
    .s_axi_wuser            (spim_axi_wuser     ),
    .s_axi_wready           (spim_axi_wready    ),
                           
    .s_axi_bvalid           (spim_axi_bvalid    ),
    .s_axi_bid              (spim_axi_bid       ),
    .s_axi_bresp            (spim_axi_bresp     ),
    .s_axi_buser            (spim_axi_buser     ),
    .s_axi_bready           (spim_axi_bready    ),
                           
    .s_axi_arvalid          (spim_axi_arvalid   ),
    .s_axi_arid             (spim_axi_arid      ),
    .s_axi_arlen            (spim_axi_arlen     ),
    .s_axi_araddr           (spim_axi_araddr    ),
    .s_axi_aruser           (spim_axi_aruser    ),
    .s_axi_arready          (spim_axi_arready   ),
                           
    .s_axi_rvalid           (spim_axi_rvalid    ),
    .s_axi_rid              (spim_axi_rid       ),
    .s_axi_rdata            (spim_axi_rdata     ),
    .s_axi_rresp            (spim_axi_rresp     ),
    .s_axi_rlast            (spim_axi_rlast     ),
    .s_axi_ruser            (spim_axi_ruser     ),
    .s_axi_rready           (spim_axi_rready    ),

    .events_o               (                   ), // TODO - Need to connect to intr ?

    .spi_clk                (spim_clk           ),
    .spi_csn0               (spim_csn0          ),
    .spi_csn1               (spim_csn1          ),
    .spi_csn2               (spim_csn2          ),
    .spi_csn3               (spim_csn3          ),
    .spi_mode               (spim_mode          ),
    .spi_sdo0               (spim_sdo0          ),
    .spi_sdo1               (spim_sdo1          ),
    .spi_sdo2               (spim_sdo2          ),
    .spi_sdo3               (spim_sdo3          ),
    .spi_sdi0               (spim_sdi0          ),
    .spi_sdi1               (spim_sdi1          ),
    .spi_sdi2               (spim_sdi2          ),
    .spi_sdi3               (spim_sdi3          ),
    .spi_en_tx              (spi_en_tx          )
);

/*********************************************************
* AXI4 with 2 Slave and 4 Master Configration
*  Slave Connectivity
*      Port[0]   - RISCV Instruction Memory I/F
*      Port[1]   - RISCV Data Memory I/F
*  Master Connectiviy
*      Port[0]   - SPI Master I/F
*      Port[1]   - UART I/F
* *******************************************************/
pyfive_axi_crossbar #
(
    // Width of data bus in bits
    .DATA_WIDTH(AXI4_DATA_WIDTH),
    // Width of address bus in bits
    .ADDR_WIDTH(AXI4_DATA_WIDTH),
    // Width of wstrb (width of data bus in words)
    .STRB_WIDTH(AXI4_STRB_WIDTH),
    // Input ID field width (from AXI masters)
    .S_ID_WIDTH(AXI4_S_ID_WIDTH),
    // Output ID field width (towards AXI slaves)
    // Additional bits required for response routing
    .M_ID_WIDTH(AXI4_M_ID_WIDTH),
    // Width of awuser signal
    .AWUSER_WIDTH(AXI4_USER_WIDTH),
    // Width of buser signal
    .BUSER_WIDTH(AXI4_USER_WIDTH),
    // Width of aruser signal
    .ARUSER_WIDTH(AXI4_USER_WIDTH),
    // Width of ruser signal
    .RUSER_WIDTH(AXI4_USER_WIDTH)
)  u_axi_crossbar
(
    .clk                      (clk                       ),
    .rst                      (!rst_n                    ),

    /*
     * AXI Slave interface
     */
    // RISC V Instruction Memory I/F - Slave port 0 
    // Write address channel
    .s00_axi_awid            ( riscv_axi_imem_awid        ),
    .s00_axi_awaddr          ( riscv_axi_imem_awaddr      ),
    .s00_axi_awlen           ( riscv_axi_imem_awlen       ),
    .s00_axi_awsize          ( riscv_axi_imem_awsize      ),
    .s00_axi_awburst         ( riscv_axi_imem_awburst     ),
    .s00_axi_awlock          ( riscv_axi_imem_awlock      ),
    .s00_axi_awcache         ( riscv_axi_imem_awcache     ),
    .s00_axi_awprot          ( riscv_axi_imem_awprot      ),
    .s00_axi_awqos           ( riscv_axi_imem_awqos       ),
    .s00_axi_awuser          ( riscv_axi_imem_awuser      ),
    .s00_axi_awvalid         ( riscv_axi_imem_awvalid     ),
    .s00_axi_awready         ( riscv_axi_imem_awready     ),

    // Write data channel
    .s00_axi_wdata           ( riscv_axi_imem_wdata       ),
    .s00_axi_wstrb           ( riscv_axi_imem_wstrb       ),
    .s00_axi_wvalid          ( riscv_axi_imem_wvalid      ),
    .s00_axi_wready          ( riscv_axi_imem_wready      ),
    .s00_axi_wlast           ( riscv_axi_imem_wlast       ),
    .s00_axi_wuser           ( riscv_axi_imem_wuser       )  ,

    // Write response channel
    .s00_axi_bid             ( riscv_axi_imem_bid         ),
    .s00_axi_bvalid          ( riscv_axi_imem_bvalid      ),
    .s00_axi_buser           ( riscv_axi_imem_buser       ) ,
    .s00_axi_bready          ( riscv_axi_imem_bready      ),
    .s00_axi_bresp           ( riscv_axi_imem_bresp       ),

    // Read address channel
    .s00_axi_arid            ( riscv_axi_imem_arid        ),
    .s00_axi_araddr          ( riscv_axi_imem_araddr      ),
    .s00_axi_arlen           ( riscv_axi_imem_arlen       ),
    .s00_axi_arsize          ( riscv_axi_imem_arsize      ),
    .s00_axi_arburst         ( riscv_axi_imem_arburst     ),
    .s00_axi_arlock          ( riscv_axi_imem_arlock      ),
    .s00_axi_arcache         ( riscv_axi_imem_arcache     ),
    .s00_axi_arprot          ( riscv_axi_imem_arprot      ),
    .s00_axi_arqos           ( riscv_axi_imem_arqos       ),
    .s00_axi_aruser          ( riscv_axi_imem_aruser      ),
    .s00_axi_arvalid         ( riscv_axi_imem_arvalid     ),
    .s00_axi_arready         ( riscv_axi_imem_arready     ),


    // Read data channel
    .s00_axi_rid             ( riscv_axi_imem_rid         ),
    .s00_axi_rdata           ( riscv_axi_imem_rdata       ),
    .s00_axi_rresp           ( riscv_axi_imem_rresp       ),
    .s00_axi_ruser           ( riscv_axi_imem_ruser       ),
    .s00_axi_rvalid          ( riscv_axi_imem_rvalid      ),
    .s00_axi_rready          ( riscv_axi_imem_rready      ),
    .s00_axi_rlast           ( riscv_axi_imem_rlast       ),

    // Rsicv Data memory Memory I/F - Slave port 1 
    // Write address channel
    .s01_axi_awid            ( riscv_axi_dmem_awid        ),
    .s01_axi_awaddr          ( riscv_axi_dmem_awaddr      ),
    .s01_axi_awlen           ( riscv_axi_dmem_awlen       ),
    .s01_axi_awsize          ( riscv_axi_dmem_awsize      ),
    .s01_axi_awburst         ( riscv_axi_dmem_awburst     ),
    .s01_axi_awlock          ( riscv_axi_dmem_awlock      ),
    .s01_axi_awcache         ( riscv_axi_dmem_awcache     ),
    .s01_axi_awprot          ( riscv_axi_dmem_awprot      ),
    .s01_axi_awqos           ( riscv_axi_dmem_awqos       ),
    .s01_axi_awuser          ( riscv_axi_dmem_awuser      ),
    .s01_axi_awvalid         ( riscv_axi_dmem_awvalid     ),
    .s01_axi_awready         ( riscv_axi_dmem_awready     ),

    // Write data channel
    .s01_axi_wdata           ( riscv_axi_dmem_wdata       ),
    .s01_axi_wstrb           ( riscv_axi_dmem_wstrb       ),
    .s01_axi_wvalid          ( riscv_axi_dmem_wvalid      ),
    .s01_axi_wready          ( riscv_axi_dmem_wready      ),
    .s01_axi_wlast           ( riscv_axi_dmem_wlast       ),
    .s01_axi_wuser           ( riscv_axi_dmem_wuser       )  ,

    // Write response channel
    .s01_axi_bid             ( riscv_axi_dmem_bid         ),
    .s01_axi_bvalid          ( riscv_axi_dmem_bvalid      ),
    .s01_axi_buser           ( riscv_axi_dmem_buser       ) ,
    .s01_axi_bready          ( riscv_axi_dmem_bready      ),
    .s01_axi_bresp           ( riscv_axi_dmem_bresp       ),

    // Read address channel
    .s01_axi_arid            ( riscv_axi_dmem_arid        ),
    .s01_axi_araddr          ( riscv_axi_dmem_araddr      ),
    .s01_axi_arlen           ( riscv_axi_dmem_arlen       ),
    .s01_axi_arsize          ( riscv_axi_dmem_arsize      ),
    .s01_axi_arburst         ( riscv_axi_dmem_arburst     ),
    .s01_axi_arlock          ( riscv_axi_dmem_arlock      ),
    .s01_axi_arcache         ( riscv_axi_dmem_arcache     ),
    .s01_axi_arprot          ( riscv_axi_dmem_arprot      ),
    .s01_axi_arqos           ( riscv_axi_dmem_arqos       ),
    .s01_axi_aruser          ( riscv_axi_dmem_aruser      ),
    .s01_axi_arvalid         ( riscv_axi_dmem_arvalid     ),
    .s01_axi_arready         ( riscv_axi_dmem_arready     ),


    // Read data channel
    .s01_axi_rid             ( riscv_axi_dmem_rid         ),
    .s01_axi_rdata           ( riscv_axi_dmem_rdata       ),
    .s01_axi_rresp           ( riscv_axi_dmem_rresp       ),
    .s01_axi_ruser           ( riscv_axi_dmem_ruser       ),
    .s01_axi_rvalid          ( riscv_axi_dmem_rvalid      ),
    .s01_axi_rready          ( riscv_axi_dmem_rready      ),
    .s01_axi_rlast           ( riscv_axi_dmem_rlast       ),


    /*
     * AXI master interface
     */
    // Write address channel
    .m00_axi_awid            ( spim_axi_awid              ),
    .m00_axi_awaddr          ( spim_axi_awaddr            ),
    .m00_axi_awlen           ( spim_axi_awlen             ),
    .m00_axi_awsize          (                            ), // TODO - Cross Check
    .m00_axi_awburst         (                            ), // TODO - Cross Check
    .m00_axi_awlock          (                            ), // TODO - Cross Check
    .m00_axi_awcache         (                            ), // TODO - Cross Check
    .m00_axi_awprot          (                            ), // TODO - Cross Check
    .m00_axi_awqos           (                            ), // TODO - Cross Check
    .m00_axi_awregion        (                            ), // TODO - Cross Check
    .m00_axi_awuser          ( spim_axi_awuser            ),
    .m00_axi_awvalid         ( spim_axi_awvalid           ),
    .m00_axi_awready         ( spim_axi_awready           ),
                                                                                         
// Write data channel
    .m00_axi_wdata           ( spim_axi_wdata             ),
    .m00_axi_wstrb           ( spim_axi_wstrb             ),
    .m00_axi_wlast           ( spim_axi_wlast             ),
    .m00_axi_wuser           ( spim_axi_wuser             ),
    .m00_axi_wvalid          ( spim_axi_wvalid            ),
    .m00_axi_wready          ( spim_axi_wready            ),
                                                                                         
// Write response channel
    .m00_axi_bid             ( spim_axi_bid               ),
    .m00_axi_bresp           ( spim_axi_bresp             ),
    .m00_axi_buser           ( spim_axi_buser             ),
    .m00_axi_bvalid          ( spim_axi_bvalid            ),
    .m00_axi_bready          ( spim_axi_bready            ),
                                                                                         
// Read address channel
    .m00_axi_arid            ( spim_axi_arid              ),
    .m00_axi_araddr          ( spim_axi_araddr            ),
    .m00_axi_arlen           ( spim_axi_arlen             ),
    .m00_axi_arsize          (                            ), // TODO - Cross Check
    .m00_axi_arburst         (                            ), // TODO - Cross Check
    .m00_axi_arlock          (                            ), // TODO - Cross Check
    .m00_axi_arcache         (                            ), // TODO - Cross Check
    .m00_axi_arprot          (                            ), // TODO - Cross Check
    .m00_axi_arqos           (                            ), // TODO - Cross Check
    .m00_axi_arregion        (                            ), // TODO - Cross Check
    .m00_axi_aruser          ( spim_axi_aruser            ),
    .m00_axi_arvalid         ( spim_axi_arvalid           ),
    .m00_axi_arready         ( spim_axi_arready           ),

// Read data channel
    .m00_axi_rid             ( spim_axi_rid               ),
    .m00_axi_rdata           ( spim_axi_rdata             ),
    .m00_axi_rresp           ( spim_axi_rresp             ),
    .m00_axi_rlast           ( spim_axi_rlast             ),
    .m00_axi_ruser           ( spim_axi_ruser             ),
    .m00_axi_rvalid          ( spim_axi_rvalid            ),
    .m00_axi_rready          ( spim_axi_rready            )

);

endmodule : digital_core
