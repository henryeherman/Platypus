`timescale 1ns / 1ps
//#===================================================
// File Name: ft245writer.v
// Description: Async Fifo module 
//                
//                
//                
//
// Author: Henry Herman
// Email: hherman@ucla.edu
// LAB: NESL @ UCLA <http://nesl.ee.ucla.edu/>  
//#===================================================
module ft245writer(
		input wire reset_i,
		
		// FT2232H Signals		
		input wire ft_clk_i, // 60MHz clk from FT2232H
		input wire ft_txe_i,
		input wire ft_oe_i,
		output reg ft_wr_o,
		output wire [7:0] ft_data_o,
		
		// FIFO signals
		output wire fifo_rd_clk_o,
		input wire [7:0] fifo_rd_data_i,
		output reg fifo_rd_en_o,
		input wire fifo_rd_empty_i
 );
 
parameter WAIT_ON_TXE_LO = 3'b00;
parameter WR_LO = 3'b01;
parameter WRITING = 3'b11;
parameter DONE = 3'b10;

reg [1:0] write_state, write_nextstate;

//reg [7:0] ft_data_r;
reg ft_wr_r;
wire ok_to_wrtie_w;

always @(negedge ft_clk_i, posedge reset_i) begin
	if(reset_i) begin
		write_state <= WAIT_ON_TXE_LO;
	end else begin
		write_state <= write_nextstate;
	end
end

assign ok_to_write_w = !ft_txe_i & !fifo_rd_empty_i & ft_oe_i;

always @ (*) begin
	case(write_state)
		WAIT_ON_TXE_LO: begin
			ft_wr_r = 1;
			fifo_rd_en_o = 0;
			if(ok_to_write_w) begin	
				fifo_rd_en_o = 1;	
				write_nextstate=WR_LO;
			end
		end
		WR_LO: begin
				ft_wr_r = 0;
						
			if(!ok_to_write_w) begin
				ft_wr_r = 1;
				fifo_rd_en_o = 0;
				write_nextstate=WAIT_ON_TXE_LO;
			end			
		end
		default: begin
			ft_wr_r = 1;
			fifo_rd_en_o = 0;
			write_nextstate=WAIT_ON_TXE_LO;
		end
		endcase
end

assign ft_data_o = ft_oe_i ? fifo_rd_data_i : 8'bz;
assign fifo_rd_clk_o = ft_clk_i;

// Delay wr_o....
always@(posedge ft_clk_i)
	ft_wr_o <= ft_wr_r;
endmodule
