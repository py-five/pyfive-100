// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define log2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : 25)
`define OKAY   2'b00
`define EXOKAY 2'b01
`define SLVERR 2'b10
`define DECERR 2'b11

//----------------------------
// Register Decoding
// Axi Address[28],[4:2]}
// ---------------------------
`define REG_STATUS 4'b1000
`define REG_CLKDIV 4'b1001
`define REG_SPICMD 4'b1010
`define REG_SPIADR 4'b1011
`define REG_SPILEN 4'b1100
`define REG_SPIDUM 4'b1101

module spi_master_axi_if #(
      parameter AXI4_ADDRESS_WIDTH = 32,
      parameter AXI4_RDATA_WIDTH   = 32,
      parameter AXI4_WDATA_WIDTH   = 32,
      parameter AXI4_USER_WIDTH    = 4,
      parameter AXI4_ID_WIDTH      = 16
  ) (
    input  logic                          s_axi_aclk,
    input  logic                          s_axi_aresetn,

    // Write address channel
    input  logic                          s_axi_awvalid, // Write address valid. This signal indicates that the channel is signaling valid 
                                                         // write address and control information.
    input  logic      [AXI4_ID_WIDTH-1:0] s_axi_awid,    // Write address ID. This signal is the identification tag for the write address group of signals.
    input  logic                    [7:0] s_axi_awlen,   // Burst length. The burst length gives the exact number of transfers in a burst. 
                                                         // This information determines the number of data transfers associated with the address
    input  logic [AXI4_ADDRESS_WIDTH-1:0] s_axi_awaddr,  // Write address. The write address gives the address of the first transfer in a write burst transaction.
    input  logic    [AXI4_USER_WIDTH-1:0] s_axi_awuser,  // User signal. Optional User-defined signal in the write address channel.
    output logic                          s_axi_awready, // Write address ready. This signal indicates that the slave is ready to accept 
                                                         // an address and associated control signals.

    // Write data channel
    input  logic                          s_axi_wvalid, // Write valid. This signal indicates that valid write data and strobes are available.
    input  logic   [AXI4_WDATA_WIDTH-1:0] s_axi_wdata,  // Write data.
    input  logic [AXI4_WDATA_WIDTH/8-1:0] s_axi_wstrb,  // Write strobes. This signal indicates which byte lanes hold valid data. 
                                                        // There is one write strobe bit for each eight bits of the write data bus.
    input  logic                          s_axi_wlast,  // Write last. This signal indicates the last transfer in a write burst.
    input  logic    [AXI4_USER_WIDTH-1:0] s_axi_wuser,  // User signal. Optional User-defined signal in the write data channel
    output logic                          s_axi_wready, // Write ready. This signal indicates that the slave can accept the write data.

   // Write response channel
    output logic                          s_axi_bvalid, // Write response valid. This signal indicates that the channel is signaling a valid write response.
    output logic      [AXI4_ID_WIDTH-1:0] s_axi_bid,    // Response ID tag. This signal is the ID tag of the write response.
    output logic                    [1:0] s_axi_bresp,  // Write response. This signal indicates the status of the write transaction.
    output logic    [AXI4_USER_WIDTH-1:0] s_axi_buser,  // User signal. Optional User-defined signal in the write response channel.
    input  logic                          s_axi_bready, // Response ready. This signal indicates that the master can accept a write response.

    // Read address channel
    input  logic                          s_axi_arvalid,// Read address valid. This signal indicates that the channel is signaling 
                                                        // valid read address and control information. 
    input  logic      [AXI4_ID_WIDTH-1:0] s_axi_arid,   // Read address ID. This signal is the identification tag for the read address group of signals.
    input  logic                    [7:0] s_axi_arlen,  // Burst length. This signal indicates the exact number of transfers in a burst.
    input  logic [AXI4_ADDRESS_WIDTH-1:0] s_axi_araddr, // Read address. The read address gives the address of the first transfer in a read burst transaction.
    input  logic    [AXI4_USER_WIDTH-1:0] s_axi_aruser, // User signal. Optional User-defined signal in the read address channel.
    output logic                          s_axi_arready,// Read address ready. This signal indicates that the slave is ready to accept an 
                                                        // address and associated control signals.

    // Read data channel
    output logic                          s_axi_rvalid, // Read valid. This signal indicates that the channel is signaling the required read data.
                                                        
    output logic      [AXI4_ID_WIDTH-1:0] s_axi_rid,    // Read ID tag. This signal is the identification tag for the read data group 
                                                        // of signals generated by the slave.
    output logic   [AXI4_RDATA_WIDTH-1:0] s_axi_rdata,  // Read data
    output logic                    [1:0] s_axi_rresp,  // Read response. This signal indicates the status of the read transfer.
    output logic                          s_axi_rlast,  // Read last. This signal indicates the last transfer in a read burst.
    output logic    [AXI4_USER_WIDTH-1:0] s_axi_ruser,  // User signal. Optional User-defined signal in the read data channel.
    input  logic                          s_axi_rready, // Read ready. This signal indicates that the master can accept the read data and response information.

    output logic                    [7:0] spi_clk_div,
    output logic                          spi_clk_div_valid,
    input  logic                   [31:0] spi_status,

    // Towards SPI TX/RX FSM

    output logic                          axi2spi_req,  
    input  logic                          spi2axi_ack,

    output logic                          reg2spi_req,  
    input  logic                          spi2reg_ack,

    output logic                   [31:0] spi_addr,
    output logic                    [5:0] spi_addr_len,
    output logic                   [31:0] spi_cmd,
    output logic                    [5:0] spi_cmd_len,
    output logic                    [3:0] spi_csreg,
    output logic                   [15:0] spi_data_len,
    output logic                   [15:0] spi_dummy_rd,
    output logic                   [15:0] spi_dummy_wr,
    output logic                          spi_swrst,
    output logic                          spi_rd,
    output logic                          spi_wr,
    output logic                          spi_qrd,
    output logic                          spi_qwr,

    output logic                   [31:0] spi_data_tx,
    output logic                          spi_data_tx_valid,
    input  logic                          spi_data_tx_ready,
    input  logic                   [31:0] spi_data_rx,
    input  logic                          spi_data_rx_valid,
    output logic                          spi_data_rx_ready
    );

  localparam WR_ADDR_CMP = `log2(AXI4_WDATA_WIDTH/8)-1;
  localparam RD_ADDR_CMP = `log2(AXI4_RDATA_WIDTH/8)-1;

  localparam OFFSET_BIT  =  ( `log2(AXI4_WDATA_WIDTH-1) - 3 );  // Address Offset: OFFSET IS 32bit--> 2bit; 64bit--> 3bit; 128bit--> 4bit and so on

  // Control Signal generated for Direct AXI to SPI Access
  logic              [31:0]   axi2spi_addr;
  logic              [15:0]   axi2spi_data_len;

  // Control Signal Generated from Reg to SPI Access
  logic               [31:0]  reg2spi_addr;
  logic                [5:0]  reg2spi_addr_len;
  logic               [31:0]  reg2spi_cmd;
  logic                [5:0]  reg2spi_cmd_len;
  logic                [3:0]  reg2spi_csreg;
  logic               [15:0]  reg2spi_data_len;
  logic               [15:0]  reg2spi_dummy_rd;
  logic               [15:0]  reg2spi_dummy_wr;
  logic                       reg2spi_swrst;
  logic                       reg2spi_rd;
  logic                       reg2spi_wr;
  logic                       reg2spi_qrd;
  logic                       reg2spi_qwr;

  logic                       is_tx_fifo_sel;
  logic                       is_rx_fifo_sel;
  logic                       is_tx_fifo_sel_q;
  logic                       is_rx_fifo_sel_q;

  logic                       read_req;
  logic                 [3:0] reg_raddr;
  logic                       sample_AR;
  logic                 [7:0] ARLEN_Q;
  logic                       decr_ARLEN;
  logic   [AXI4_ID_WIDTH-1:0] axi_arid_r; // registred axi_arid
  logic [AXI4_USER_WIDTH-1:0] axi_aruser_r; // registred axi_aruser


  logic                       write_req;
  logic                 [3:0] reg_waddr;
  logic                       sample_AW;
  logic [AXI4_ADDRESS_WIDTH-1:0] AWADDR_Q;
  logic                 [7:0] AWLEN_Q;
  logic                       decr_AWLEN;
  logic                 [7:0] CountBurst_AW_CS;
  logic                 [7:0] CountBurst_AW_NS;
  logic   [AXI4_ID_WIDTH-1:0] AWID_Q;
  logic [AXI4_USER_WIDTH-1:0] AWUSER_Q;

  logic   [3:0]               write_address;

  enum logic [2:0] { IDLE, SINGLE, BURST, WAIT_WDATA_BURST, WAIT_WDATA_SINGLE, BURST_RESP } AR_CS, AR_NS, AW_CS, AW_NS;

   // Priority given to axi2spi request over Reg2Spi

    assign  spi_addr      =  (axi2spi_req) ? axi2spi_addr      : reg2spi_addr;      
    assign  spi_addr_len  =  (axi2spi_req) ? 32                : reg2spi_addr_len;  
    assign  spi_cmd       =  (axi2spi_req) ? 32'hDA000000      : reg2spi_cmd;       
    assign  spi_cmd_len   =  (axi2spi_req) ? 8                 : reg2spi_cmd_len;   
    assign  spi_csreg     =  (axi2spi_req) ? '1                : reg2spi_csreg;     
    assign  spi_data_len  =  (axi2spi_req) ? axi2spi_data_len  : reg2spi_data_len;  
    assign  spi_dummy_rd  =  (axi2spi_req) ? 8                 : reg2spi_dummy_rd;  
    assign  spi_dummy_wr  =  (axi2spi_req) ? 0                 : reg2spi_dummy_wr;  
    assign  spi_swrst     =  (axi2spi_req) ? 0                 : reg2spi_swrst;     
    assign  spi_rd        =  (axi2spi_req) ? 0                 : reg2spi_rd;        
    assign  spi_wr        =  (axi2spi_req) ? 0                 : reg2spi_wr;        
    assign  spi_qrd       =  (axi2spi_req) ? 1                 : reg2spi_qrd;       
    assign  spi_qwr       =  (axi2spi_req) ? 0                 : reg2spi_qwr;       


  //------------------------------------------------------------------------------
  // All the AXI Write/Read Address range  0x0000_0000 to 0x0FFF_FFFC is
  // considered as crossponding External Write and Read Access
  // -------------------------------------------------------------------------------
  assign is_tx_fifo_sel = (s_axi_awaddr[31:28] == 4'b0000);
  assign is_rx_fifo_sel = (s_axi_araddr[31:28] == 4'b0000);

  assign spi_data_tx = s_axi_wdata[31:0];

  //read fsm
  always_ff @(posedge s_axi_aclk, negedge s_axi_aresetn)
  begin
    if(s_axi_aresetn == 1'b0)
    begin
      AR_CS        <= IDLE;
      reg_raddr   <= '0;
      axi_arid_r   <= '0;
      axi_aruser_r <= '0;
      ARLEN_Q      <= '0;
      is_tx_fifo_sel_q <= '0;
      is_rx_fifo_sel_q <= '0;
      axi2spi_addr     <= '0;
      axi2spi_data_len <= '0;
      axi2spi_req      <= 0;
    end
    else
    begin
      AR_CS <= AR_NS;

      is_tx_fifo_sel_q <= is_tx_fifo_sel;
      is_rx_fifo_sel_q <= is_rx_fifo_sel;

      if(sample_AR)
        ARLEN_Q  <=  s_axi_arlen;
      else
      if(decr_ARLEN)
        ARLEN_Q  <=  ARLEN_Q -1'b1;

      if(sample_AR)
      begin
	axi2spi_req <= 1;
        axi_aruser_r     <=  s_axi_aruser;
        axi_arid_r       <=  s_axi_arid;
        reg_raddr        <=  {s_axi_araddr[28],s_axi_araddr[4:2]};
	axi2spi_addr     <=  {4'b0,s_axi_araddr[27:0]};
	axi2spi_data_len <=  (s_axi_arlen+1) << 5; // Convert into Bit length 4 bytes means 4 * 8 = 32 
        end else begin 
	  if(spi2axi_ack == 1) axi2spi_req <= 0;
	end
    end
  end

  /*******************************
  *  AXI READ CHANNEL MONITORING 
  *******************************/
  always_comb
  begin
    s_axi_arready        =  1'b0;
    read_req             =  1'b0;
    sample_AR            =  1'b0;
    decr_ARLEN           =  1'b0;
    spi_data_rx_ready    =  1'b0;
    s_axi_rvalid         =  1'b0;
    s_axi_rresp          =  `OKAY;
    s_axi_ruser          =  '0;
    s_axi_rlast          =  1'b0;
    s_axi_rid            =  '0;
    AR_NS                =  AR_CS;

    case(AR_CS)
      IDLE:
      begin
        if(s_axi_arvalid)
        begin
           s_axi_arready  = 1'b1;
           sample_AR      = 1'b1;
           read_req       = 1'b1;
	   // Only Single Access supported for Register I/F
           if(s_axi_arlen == 0 || !is_rx_fifo_sel_q) begin
              AR_NS          = SINGLE;
           end else begin
              AR_NS          = BURST;
           end
        end
      end //~ IDLE
      SINGLE:
      begin
         s_axi_rresp  = `OKAY;
         s_axi_rid    = axi_arid_r;
         s_axi_ruser  = axi_aruser_r;
         s_axi_rlast  = 1'b1;
         // if RX FIFO selected rvalid if valid data in FIFO
         if (is_rx_fifo_sel_q)
           s_axi_rvalid = spi_data_rx_valid;
         else
           s_axi_rvalid = 1'b1;

         // we have a valid response here, waiting to be delivered
         // valid response is either no RX FIFO selected or RX FIFO selected and data available in FIFO
	 if(s_axi_rready && is_rx_fifo_sel_q && spi_data_rx_valid) begin
             spi_data_rx_ready = 1'b1;
             AR_NS = IDLE;
	 end
	 else if(s_axi_rready && !is_rx_fifo_sel_q && s_axi_rvalid)  // Reading Spi Register
         begin
            sample_AR      = 1'b1;
            read_req       = 1'b1;
             AR_NS = IDLE;
         end 
      end //~ SINGLE

      BURST: // Burst allowed only towards FIFO Interface
      begin
        s_axi_rresp  = `OKAY;
        s_axi_rid    = axi_arid_r;
        s_axi_ruser  = axi_aruser_r;

        if (is_rx_fifo_sel_q)
          s_axi_rvalid = spi_data_rx_valid;
        else
          s_axi_rvalid = 1'b1;

        if(s_axi_rready && is_rx_fifo_sel_q && spi_data_rx_valid)
        begin
            spi_data_rx_ready = 1'b1;

          if(ARLEN_Q > 0)
          begin
            AR_NS               = BURST;
            decr_ARLEN          = 1'b1;
            s_axi_rlast         = 1'b0;
            s_axi_arready       = 1'b0;
          end
          else //BURST_LAST
          begin
            s_axi_rlast         = 1'b1;
            s_axi_arready       = 1'b1;
            AR_NS = IDLE;
          end
        end

      end //~ BURST
      default : begin

      end //~default
    endcase
  end

  //Write FSM
  always_ff @(posedge s_axi_aclk, negedge s_axi_aresetn)
  begin
    if(s_axi_aresetn == 1'b0)
    begin
      AW_CS            <= IDLE;
      AWADDR_Q         <= '0;
      CountBurst_AW_CS <= '0;
      AWID_Q           <= '0;
      AWUSER_Q         <= '0;
    end
    else
    begin
      AW_CS <= AW_NS;
      CountBurst_AW_CS <= CountBurst_AW_NS;
      if(sample_AW)
      begin
        AWLEN_Q  <=  s_axi_awlen;
        AWADDR_Q <=  s_axi_awaddr;
        AWID_Q   <=  s_axi_awid;
        AWUSER_Q <=  s_axi_awuser;
      end
      else
      if(decr_AWLEN)
      begin
        AWLEN_Q  <=  AWLEN_Q -1'b1;
      end
    end
  end

  always_comb
  begin
    s_axi_awready        = 1'b0;
    s_axi_wready         = 1'b0;
    reg_waddr            = '0;
    write_req            = 1'b0;
    sample_AW            = 1'b0;
    decr_AWLEN           = 1'b0;
    CountBurst_AW_NS     = CountBurst_AW_CS;
    s_axi_bid   = '0;
    s_axi_bresp = `OKAY;
    s_axi_buser = '0;
    s_axi_bvalid = 1'b0;
    write_address   = '0;
    AW_NS = AW_CS;

    case(AW_CS)
      IDLE:
      begin
        s_axi_awready        = 1'b1;

        if(s_axi_awvalid)
        begin
          sample_AW       = 1'b1;

          if(s_axi_wvalid)
          begin
              s_axi_wready    = 1'b1;
              reg_waddr       = {s_axi_awaddr[28],s_axi_awaddr[4:2]};
              if(s_axi_awlen == 0)
              begin
                write_req       = 1'b1;
                AW_NS = SINGLE;
                CountBurst_AW_NS   = 0;
              end
              else
              begin
                AW_NS = BURST;
                CountBurst_AW_NS   = 1;
              end
          end
          else // GOT ADDRESS WRITE, not DATA
          begin
            s_axi_wready    = 1'b1;
            write_req       = 1'b0;
            write_address   = '0;

            if(s_axi_awlen == 0)
            begin
              AW_NS             =  WAIT_WDATA_SINGLE;
              CountBurst_AW_NS  = 0;
            end
            else
            begin
              AW_NS =  WAIT_WDATA_BURST;
              CountBurst_AW_NS    = 0;
            end
          end
        end
        else
        begin
          s_axi_wready         = 1'b1;
          AW_NS              = IDLE;
          CountBurst_AW_NS   = '0;
        end

      end //~ IDLE


      WAIT_WDATA_BURST :
      begin
        s_axi_awready        = 1'b0;

        if(s_axi_wvalid)
        begin
            s_axi_wready     = 1'b1;
            write_req        = 1'b1;
            write_address    = AWADDR_Q;
            AW_NS            = BURST;
            CountBurst_AW_NS = 1;
            decr_AWLEN       = 1'b1;
        end
        else
        begin
          s_axi_wready         = 1'b1;
          write_req              =  1'b0;
          AW_NS                  = WAIT_WDATA_BURST; // wait for data
          CountBurst_AW_NS       = '0;
        end

      end //~WAIT_WDATA_BURST

      WAIT_WDATA_SINGLE :
      begin
        s_axi_awready        = 1'b0;
        CountBurst_AW_NS = '0;

        if(s_axi_wvalid)
        begin
            s_axi_wready         = 1'b1;
            write_req        = 1'b1;
            write_address    = AWADDR_Q;
            AW_NS            = SINGLE;
        end
        else
        begin
          s_axi_wready         = 1'b1;
          write_req        = 1'b0;
          AW_NS = WAIT_WDATA_SINGLE; // wait for data
        end
      end

      SINGLE: begin
        s_axi_bid    = AWID_Q;
        s_axi_bresp  = `OKAY;
        s_axi_buser  = AWUSER_Q;
        s_axi_bvalid = 1'b1;

        // we have a valid response here, waiting to be delivered
        if(s_axi_bready)
        begin
          s_axi_awready = 1'b1;
          if(s_axi_awvalid)
          begin
            sample_AW       =   1'b1;
            write_req       =   1'b1;
            write_address   =   s_axi_awaddr;

            if(s_axi_awlen == 0)
            begin
              AW_NS          = SINGLE;
              CountBurst_AW_NS   = '0;
            end
            else
            begin
              AW_NS          = BURST;
              CountBurst_AW_NS   = CountBurst_AW_CS + 1'b1;
            end
          end
          else
          begin
            AW_NS = IDLE;
            CountBurst_AW_NS   = '0;
          end
        end
        else // NOt ready: stay here untile RR RADY is OK
        begin
          AW_NS            = SINGLE;
          CountBurst_AW_NS = '0;
          s_axi_awready          = 1'b0;
        end

      end //~ SINGLE

      BURST:
      begin

        CountBurst_AW_NS = CountBurst_AW_CS;
        s_axi_awready        = 1'b0;

        //write_address  =  AWADDR_Q + CountBurst_AW_CS ;
        write_address  =  AWADDR_Q; //TODO check burst type

        if(s_axi_wvalid)
        begin
            s_axi_wready = 1'b1;
            write_req      = 1'b1; // read the previous address
            decr_AWLEN     = 1'b1;
            CountBurst_AW_NS   = CountBurst_AW_CS + 1'b1;
        end
        else
        begin
          s_axi_wready = 1'b1;
          write_req      = 1'b0; // read the previous address
          decr_AWLEN     = 1'b0;

        end
        if(AWLEN_Q > 0)
        begin
          AW_NS          = BURST;
          //    AWREADY        = 1'b0;
        end
        else
        begin
          AW_NS          = BURST_RESP;
          //    AWREADY        = 1'b1;
        end
      end //~ BURST


      BURST_RESP :
      begin
        s_axi_bvalid  = 1'b1;
        s_axi_bid     = AWID_Q;
        s_axi_bresp   = `OKAY;
        s_axi_buser   = AWUSER_Q;
        if(s_axi_bready)
        begin
          s_axi_awready = 1'b1;
          // Check if there are any pending request
          if(s_axi_awvalid)
          begin
            sample_AW = 1'b1;
            if(s_axi_wvalid)
            begin
                s_axi_wready = 1'b1;
                write_req       = 1'b1;
                write_address   = s_axi_awaddr;
                if(s_axi_awlen == 0)
                begin
                  AW_NS            = SINGLE;
                  CountBurst_AW_NS = 0;
                end
                else
                begin
                  AW_NS = BURST;
                  CountBurst_AW_NS   = 1;
                end
            end
            else // GOT ADDRESS WRITE, not DATA
            begin
              s_axi_wready = 1'b1;
              write_req       = 1'b0;
              write_address   = '0;

              if(s_axi_awlen == 0)
              begin
                AW_NS             =  WAIT_WDATA_SINGLE;
                CountBurst_AW_NS  = 0;
              end
              else
              begin
                AW_NS            = WAIT_WDATA_BURST;
                CountBurst_AW_NS = 0;
              end
            end
          end
          else
          begin
            s_axi_wready = 1'b1;
            AW_NS            = IDLE;
            CountBurst_AW_NS = '0;
          end
        end
        else //~BREADY
        begin
          AW_NS         = BURST_RESP;
          s_axi_awready = 1'b0;
          s_axi_wready = 1'b0;
        end
      end
    endcase
  end

  integer byte_index;
  always @( posedge s_axi_aclk or negedge s_axi_aresetn )
  begin
    if ( s_axi_aresetn == 1'b0 )
    begin
      reg2spi_swrst         <= 1'b0;
      reg2spi_rd            <= 1'b0;
      reg2spi_wr            <= 1'b0;
      reg2spi_qrd           <= 1'b0;
      reg2spi_qwr           <= 1'b0;
      reg2spi_cmd           <=  'h0;
      reg2spi_addr          <=  'h0;
      reg2spi_cmd_len       <=  'h0;
      reg2spi_addr_len      <=  'h0;
      reg2spi_data_len      <=  'h0;
      reg2spi_dummy_rd      <=  'h0;
      reg2spi_dummy_wr      <=  'h0;
      reg2spi_csreg         <=  'h0;
      reg2spi_req           <=  'h0;
      spi_clk_div_valid     <= 1'b0;
      spi_clk_div           <=  'h0;
    end
    else if (write_req)
    begin
      case(reg_waddr)
        `REG_STATUS:
        begin
          if ( s_axi_wstrb[0] == 1 )
          begin
            reg2spi_rd    <= s_axi_wdata[0];
            reg2spi_wr    <= s_axi_wdata[1];
            reg2spi_qrd   <= s_axi_wdata[2];
            reg2spi_qwr   <= s_axi_wdata[3];
            reg2spi_swrst <= s_axi_wdata[4];
	    reg2spi_req   <= 1'b1;
          end
          if ( s_axi_wstrb[1] == 1 )
          begin
            reg2spi_csreg <= s_axi_wdata[11:8];
          end
        end
        `REG_CLKDIV:
          if ( s_axi_wstrb[0] == 1 )
          begin
            spi_clk_div <= s_axi_wdata[7:0];
            spi_clk_div_valid <= 1'b1;
          end
        `REG_SPICMD:
          for (byte_index = 0; byte_index < 4; byte_index = byte_index+1 )
            if ( s_axi_wstrb[byte_index] == 1 )
              reg2spi_cmd[byte_index*8 +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
        `REG_SPIADR:
          for (byte_index = 0; byte_index < 4; byte_index = byte_index+1 )
            if ( s_axi_wstrb[byte_index] == 1 )
              reg2spi_addr[byte_index*8 +: 8] <= s_axi_wdata[(byte_index*8) +: 8];
        `REG_SPILEN:
        begin
          if ( s_axi_wstrb[0] == 1 )
            reg2spi_cmd_len <= s_axi_wdata[7:0];
          if ( s_axi_wstrb[1] == 1 )
            reg2spi_addr_len <= s_axi_wdata[15:8];
          if ( s_axi_wstrb[2] == 1 )
            reg2spi_data_len[7:0] <= s_axi_wdata[23:16];
          if ( s_axi_wstrb[3] == 1 )
            reg2spi_data_len[15:8] <= s_axi_wdata[31:24];
        end
        `REG_SPIDUM:
        begin
          if ( s_axi_wstrb[0] == 1 )
            reg2spi_dummy_rd[7:0] <= s_axi_wdata[7:0];
          if ( s_axi_wstrb[1] == 1 )
            reg2spi_dummy_rd[15:8] <= s_axi_wdata[15:8];
          if ( s_axi_wstrb[2] == 1 )
            reg2spi_dummy_wr[7:0] <= s_axi_wdata[23:16];
          if ( s_axi_wstrb[3] == 1 )
            reg2spi_dummy_wr[15:8] <= s_axi_wdata[31:24];
        end
      endcase
    end
    else
    begin
      reg2spi_swrst     <= 1'b0;
      reg2spi_rd        <= 1'b0;
      reg2spi_wr        <= 1'b0;
      reg2spi_qrd       <= 1'b0;
      reg2spi_qwr       <= 1'b0;
      reg2spi_csreg     <= 'h0;
      spi_clk_div_valid <= 1'b0;
      if(spi2reg_ack)   
	 reg2spi_req <= 1'b0;
    end
  end // SLAVE_REG_WRITE_PROC


  // implement slave model register read mux
  always_comb
    begin
      s_axi_rdata = {spi_data_rx};
      case(reg_raddr)
        `REG_STATUS:
                s_axi_rdata[31:0] = spi_status;
        `REG_CLKDIV:
                s_axi_rdata[31:0] = {24'h0,spi_clk_div};
        `REG_SPICMD:
          s_axi_rdata[31:0] = spi_cmd;
        `REG_SPIADR:
          s_axi_rdata[31:0] = spi_addr;
        `REG_SPILEN:
          s_axi_rdata[31:0] = {spi_data_len,2'b00,spi_addr_len,2'b00,spi_cmd_len};
        `REG_SPIDUM:
                s_axi_rdata[31:0] = {spi_dummy_wr,spi_dummy_rd};
      endcase
    end // SLAVE_REG_READ_PROC

  assign spi_data_tx_valid = write_req & (write_address[3] == 1'b1);

endmodule
