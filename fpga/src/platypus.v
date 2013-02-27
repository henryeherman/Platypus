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
	output wire daq_stdby_o,
	
	input wire daq_busy_i,	
	

	
	output wire [7:0] daq_cs_o, 
	input wire [15:0] daq_db_i,
	input wire daq_frstdata_i,
	output wire [2:0] daq_os_sel_o,
	output wire daq_reset_o,
	
	// FT2232H Signals
	input wire ft_clk_i, // 60MHz clk from FT2232H
	input wire ft_txe_i,
	input wire ft_oe_i,
	output wire ft_wr_o,
	output wire [7:0] ft_data_o,
	
	
	// Testpoints
	output wire daq_busy_tp,
	output wire daq_conv_clk_tp,
	output wire daq_rd_tp,
	output wire daq_rd_en_tp,
	output wire daq_cs0_tp,
	output wire tp,
	
	// LED Signal
	output wire blink_o
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


dasresetcounter udasreset(
.clk_i(clk_i),
.reset_o(daq_reset_o),
.reset_i(0),
.en_i(1)
);


/*
// Module divides clock for RD
daqrdclk udaqrdclk(
  .clk_i(clk_i),
  .reset_i(0),
  .clk_en_o(daq_rd_o),
  .clk_o(),
  .en_i(1)
);



// Module creater trigger for conversion
daqtriggerctrl udaqtrig(
  .clk_i(clk_i),
  .busy_i(daq_busy_i),
  .conv_clk_o(daq_conv_clk_o),
  .reset_i(0),
  .en_i(1)
);
*/

	platypusfifo uplatfifo(
		.tp(tp),
		.clk_i(clk_i), //Expect 200MHz clock
		.en_i(1),
		.reset_i(daq_reset_o),
		// DAQ Signals
		.daq_conv_clk_o(daq_conv_clk_o),
		.daq_rd_o(daq_rd_tp),
		.daq_rd_en_o(daq_rd_o),
		.daq_cs_o(daq_cs_o),
		.daq_db_i(daq_db_i),
		.daq_busy_i(daq_busy_i),
		.daq_frstdata_i(daq_frstdata_i),
		.daq_os_sel_i(daq_os_sel_o)
		// FT245 Signals
		//.ft_clk_i(ft_clk_i), // 60MHz clk from FT2232H
		//.ft_txe_i(ft_txe_i),
		//.ft_oe_i(ft_oe_i),
		//.ft_wr_o(ft_wr_o),
		//.ft_data_o(ft_data_o)
	);



// We should be able to set this later!
// Enable DAS
assign daq_stdby_o = 1;

// Select full no over sample
assign daq_os_sel_o = 3'b000;

// Testpoints
assign daq_busy_tp = daq_busy_i;
assign daq_conv_clk_tp = daq_conv_clk_o;
assign daq_rd_en_tp = daq_rd_o;
assign daq_cs0_tp = daq_cs_o[0];

// Blink LED so we know we are alive;
assign blink_o = cnt_r[25];

endmodule
