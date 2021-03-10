// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module spi_master_clkgen
(
    input  logic                        clk,
    input  logic                        rstn,
    input  logic                        en,
    input  logic          [7:0]         cfg_sck_period,
    output logic                        spi_clk,
    output logic                        spi_fall,
    output logic                        spi_rise
);

	logic [7:0] sck_half_period;
	logic [7:0] clk_cnt;

    assign sck_half_period = {1'b0, cfg_sck_period[7:1]};
   
    // Generated spi_fall and rise signal combinational to do pre-lanch
    assign spi_fall        = en & (clk_cnt == sck_half_period);
    assign spi_rise        = en & (clk_cnt == cfg_sck_period);
    // The first transition on the sck_toggle happens one SCK period
    // after op_en or boot_en is asserted
    always @(posedge clk or negedge rstn) begin
    	if(!rstn) begin
    		clk_cnt    <= 'h1;
    		spi_clk    <= 1'b1;
    	end // if (!reset_n)
    	else 
    	begin
    		if(en) 
    		begin
    			if(clk_cnt == sck_half_period) 
    			begin
    				spi_clk <= 1'b0;
    				clk_cnt <= clk_cnt + 1'b1;
    			end // if (clk_cnt == sck_half_period)
    			else 
    			begin
    				if(clk_cnt == cfg_sck_period) 
    				begin
    					spi_clk <= 1'b1;
    					clk_cnt <= 'h1;
    				end // if (clk_cnt == cfg_sck_period)
    				else 
    				begin
    					clk_cnt <= clk_cnt + 1'b1;
    				end // else: !if(clk_cnt == cfg_sck_period)
    			end // else: !if(clk_cnt == sck_half_period)
    		end // if (op_en)
    		else 
    		begin
    			clk_cnt    <= 'h1;
    		end // else: !if(op_en)
    	end // else: !if(!reset_n)
    end // always @ (posedge clk or negedge reset_n)

    
    

endmodule
