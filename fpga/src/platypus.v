`timescale 1ns / 1ps
//#===================================================
// File Name: platypus.v
// Description: This is the top-level Platypus module 
//                
//                
//                
//
// Author: Henry Herman
// Email: hherman@ucla.edu
// LAB: NESL @ UCLA <http://nesl.ee.ucla.edu/>  
//#===================================================

module platypus(
    input wire clk_i, // 12MHz from MCU
    output wire [2:0] blinker_o
  );

   wire clk_fast;
   //wire reset_w;
   reg [32:0] cnt_r = 'b0;

	
	always @(posedge clk_fast) begin
		cnt_r = cnt_r+1;
	end
    	
	
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

   daqtriggerctrl udaqtrig (
     .clk_i(cnt_r[10]),//clk_i),
     .busy_i(0),
     .conv_clk_o(blinker_o[1]),
     .reset_i(0),
     .en_i(1)
   );


   //assign blinker_o[1] = cnt_r[25];
   assign blinker_o[0] = cnt_r[25];
   //assign blinker_o[1] = 1;
endmodule
