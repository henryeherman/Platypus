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
	// Global signals
	input wire clk_i, // 12MHz from MCU
	input wire reset_i, 
	input wire en_i, 

	// DAQ Signals
	output wire daq_conv_clk_o,
	output wire daq_rd_o,
	output wire [7:0] daq_cs_o,
	input wire [15:0] daq_db_i,
	input wire daq_busy_i,
	input wire daq_frstdata_i,
	output wire [2:0] daq_os_sel_o,

	// FT2232H Signals
	input wire ft_clk_i, // 60MHz clk from FT2232H
	input wire ft_txe_i,
	input wire ft_oe_i,
	output wire ft_wr_o,
	output wire [7:0] ft_data_o
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



	platypusfifo uplatfifo(
		.clk_i(clk_i), //Expect 200MHz clock
		.en_i(en_i),
		.reset_i(reset_i),
		// DAQ Signals
		.daq_conv_clk_o(daq_conv_clk_o),
		.daq_rd_o(),
		.daq_rd_en_o(daq_rd_o),
		.daq_cs_o(daq_cs_o),
		.daq_db_i(daq_db_i),
		.daq_busy_i(daq_busy_i),
		.daq_frstdata_i(daq_frstdata_i),
		.daq_os_sel_i(daq_os_sel_o),
		// FT245 Signals
		.ft_clk_i(ft_clk_i), // 60MHz clk from FT2232H
		.ft_txe_i(ft_txe_i),
		.ft_oe_i(ft_oe_i),
		.ft_wr_o(ft_wr_o),
		.ft_data_o(ft_data_o)
	);

endmodule
