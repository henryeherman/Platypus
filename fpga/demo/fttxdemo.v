`timescale 1ns / 1ps
//#===================================================
// File Name: fttxdemo.v
// Description: This Demo shows how to stream data
//                From the FT2232H USB UART FIFO
//                in FT245 Synchronous Mode
//                using the a XULA 200 Spartan 3 FPGA
//
// Author: Henry Herman
// Email: hherman@ucla.edu
// LAB: NESL @ UCLA <http://nesl.ee.ucla.edu/>  
//#===================================================

module fttxdemo(
    input wire clk_i, // 12MHz from MCU
    input wire uclk_i,  // 60MHz from FT2232H
    output wire blinker_o,      
    input wire txen_i,
    output wire wr_o, 
    output wire oe_o,
    input wire pwren_i,   
    inout wire [7:0] byte_io    
  );

	reg [22:0] cnt_r = 23'b0;
	reg [7:0] byte_tx;
    wire [7:0] byte_rx;
    wire clk_fast;
    wire reset_w;
    	
	
   // DCM_SP: Digital Clock Manager Circuit
   //         Spartan-3A
   // Xilinx HDL Language Template, version 14.1
   // 12MHz * 32 /2 = 192MHz
   DCM_SP #(
      .CLKFX_DIVIDE(2),   // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(32) // Can be any integer from 2 to 32
   ) DCM_SP_inst (      
      .CLKFX(clk_fast),   // DCM CLK synthesis out (M/D)      
      .CLKIN(clk_i),   // Clock input (from IBUFG, BUFG or DCM)      
      .RST(0)        // DCM asynchronous reset input
   );
   // End of DCM_SP_inst instantiation

	//always @(posedge clk_fast)
	//	begin
	//		cnt_r = cnt_r + 1;
	//	end


	ft2232h_count_streamer uftcount(
      .clk_i(uclk_i),
      .adbus_o(byte_tx),
      .txe_i(txen_i),
      .wr_o(wr_o),
      .oe_o(oe_o),
      .rst_i(reset_w),
      .blinker_o(blinker_o)
    );

    assign byte_io = (oe_o) ? byte_tx : byte_rx;

	//assign blinker_o = cnt_r[22];

    assign reset_w = pwren_i;
	
endmodule
