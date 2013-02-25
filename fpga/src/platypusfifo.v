`timescale 1ns / 1ps
//#===================================================
// File Name: platypusfifo.v
// Description: Async Fifo module 
//                
//                
//                
//
// Author: Henry Herman
// Email: hherman@ucla.edu
// LAB: NESL @ UCLA <http://nesl.ee.ucla.edu/>  
//#===================================================

module platypusfifo(
	input wire clk_i, //Expect 200MHz clock
	input wire en_i,
	input wire reset_i,
	// DAQ Signals
	output wire daq_conv_clk_o,
	output wire daq_rd_o,
	output wire daq_rd_en_o,
	output wire [7:0] daq_cs_o,
	input wire [15:0] daq_db_i,
	input wire daq_busy_i,
	input wire daq_frstdata_i,
	input wire [2:0] daq_os_sel_i,
	
	// FT245 Signals
	input wire ft_clk_i, // 60MHz clk from FT2232H
	input ft_txe_i,
	input ft_oe_i,
	output ft_wr_o,
	output [7:0] ft_data_o
);


	// FIFO Write signals
	wire fifo_wr_clk_w;
	wire [15:0] fifo_wr_data_w;
	wire fifo_wr_en_w;
	wire fifo_wr_full_w;

	// FIFO Read Signals
	wire fifo_rd_clk_w;
	wire [7:0] fifo_rd_data_w;
	wire fifo_rd_en_w;
	wire fifo_rd_empty_w;
	

	ft245writer uft2232tx(
		.reset_i(reset_i),
		
		// FT2232H Signals		
		.ft_clk_i(ft_clk_i), // 60MHz clk from FT2232H
		.ft_txe_i(ft_txe_i),
		.ft_oe_i(ft_oe_i),
		.ft_wr_o(ft_wr_o),
		.ft_data_o(ft_data_o),
		
		// FIFO signals
		.fifo_rd_clk_o(fifo_rd_clk_w),
		.fifo_rd_data_i(fifo_rd_data_w),
		.fifo_rd_en_o(fifo_rd_en_w),
		.fifo_rd_empty_i(fifo_rd_empty_w)
	 );


	daqpacketizer upkt(
		.clk_i(clk_i), //Expect 200MHz clock
		.en_i(en_i),
		.reset_i(reset_i),

		// AD7606 signals
		.conv_clk_o(daq_conv_clk_o),
		.rd_o(daq_rd_o),
		.rd_en_o(daq_rd_en_o),
		.cs_o(daq_cs_o),
		.db_i(daq_db_i),
		.busy_i(daq_busy_i),
		.frstdata_i(daq_frstdata_i),
		.os_sel_i(daq_os_sel_i),

		//FIFO Signals
		.fifo_wr_clk_o(fifo_wr_clk_w),
		.fifo_wr_data_o(fifo_wr_data_w),
		.fifo_wr_en_o(fifo_wr_en_w),
		.fifo_wr_full_i(fifo_wr_full_w)  // Change when move fifo to new .v file
	);

	async_fifo ufifo (
	  .rst(reset_i), // input rst
	  .wr_clk(fifo_wr_clk_w), // input wr_clk
	  .rd_clk(fifo_rd_clk_w), // input rd_clk
	  .din(fifo_wr_data_w), // input [15 : 0] din
	  .wr_en(fifo_wr_en_w), // input wr_en
	  .rd_en(fifo_rd_en_w), // input rd_en
	  .dout(fifo_rd_data_w), // output [7 : 0] dout
	  .full(fifo_wr_full_w), // output full
	  .overflow(), // output overflow
	  .empty(fifo_rd_empty_w), // output empty
	  .underflow() // output underflow
	);


endmodule
