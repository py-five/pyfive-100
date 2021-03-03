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

