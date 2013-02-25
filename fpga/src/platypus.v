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
    output wire conv_clk_o,    
    output rd_o,
	 output rd_en_o,
	 output wr_en_o,
	 input [15:0] db_i,
	 output [7:0] cs_o,
	 input busy_i,
    input reset_i
  );

   wire clk_fast;
   //wire reset_w;
   reg [32:0] cnt_r = 'b0;

   wire [7:0] cs_w;
	
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
      .RST(reset_i)        // DCM asynchronous reset input
   );
   // End of DCM_SP_inst instantiation

/*
module daqpacketizer(
input wire clk_i, //Expect 200MHz clock
input wire en_i,

//AD7606 signals
output wire conv_clk_o,
input wire reset_i,
output wire rd_o,
output wire [7:0] cs_o,
input wire [15:0] db_i,
output wire [15:0] db_o,
input wire busy_i,
input wire frstdata_i,
input wire [2:0] os_sel_i
);
*/
   daqpacketizer udaqpkt (
     .clk_i(clk_i),
     .en_i(1),
	  .db_i(db_i),
     .conv_clk_o(conv_clk_o),     
	  .reset_i(reset_i),
	  .rd_o(rd_o),	  	  
	  .rd_en_o(rd_en_o),
	  .wr_en_o(wr_en_o),
	  .cs_o(cs_o),	  
	  .busy_i(busy_i)              
   );

endmodule
