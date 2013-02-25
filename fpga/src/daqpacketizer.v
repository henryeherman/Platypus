`timescale 1ns/1ps
//#===================================================
// File Name: daqpacketizer.v
// Description: Convert DAQ data to packets
// 					Stream packets to FIFO 
//                
//
// Author: Henry Herman
// Email: hherman@ucla.edu
// LAB: NESL @ UCLA <http://nesl.ee.ucla.edu/>  
//#===================================================

`define HI      1
`define LO      0
`define PREAMBLE_VAL		16'hAAAA

module daqpacketizer(
input wire clk_i, //Expects 200MHz clock
input wire en_i,

// AD7606 signals
output wire conv_clk_o,
input wire reset_i,
output wire rd_o,
output wire rd_en_o,
output wire [7:0] cs_o,
input wire [15:0] db_i,
input wire busy_i,
input wire frstdata_i,
input wire [2:0] os_sel_i,

//FIFO Signals
input wire fifo_wr_clk_o,
output wire [15:0] fifo_wr_data_o,
output wire fifo_wr_en_o,
input wire fifo_wr_full_i
);
/*

*/

parameter ADC_COUNT = 8;
parameter DAQ_COUNT = 8;

parameter WAIT_ON_TRIG = 3'b000;
parameter WAIT_ON_BUSY_HIGH = 3'b001;
parameter WAIT_ON_BUSY_LOW = 3'b010;
parameter PREAMBLE = 3'b011;
parameter PACKET_COUNT = 3'b100;
parameter READ_ADC = 3'b101;
parameter READ_DONE = 3'b110;

wire wr_en_o;

// DAQ Reading States
reg [2:0] read_state_r;
reg [2:0] read_nextstate_r;

// DAQ Counters
reg [4:0] adc_count_r;
reg [4:0] daq_count_r;

// Used to control preamble and header
reg header_en_r;
reg preamble_en_r;

// This counter tracks the number of packets in FIFO
reg[15:0] pkt_counter_r;

// Controls if we are selecting a DAQ for transmission
reg cs_en_r;
// Controls if we are reading data from DAQ
reg rd_en_r;

// When a packet is complete go high
wire read_done_w;


// Module divides clock for RD
daqrdclk udaqrdclk(
  .clk_i(clk_i),
  .reset_i(reset_i),
  .clk_en_o(rd_en_o),
  .clk_o(rd_o),
  .en_i(wr_en_o)
);

// Module creater trigger for conversion
daqtriggerctrl udaqtrig(
  .clk_i(clk_i),
  .busy_i(busy_i),
  .conv_clk_o(conv_clk_o),
  .reset_i(reset_i),
  .en_i(en_i)
);

// If we are selecting a DAQ then we write
assign wr_en_o = !(&cs_o);

// Select the proper DAQ
assign cs_o = cs_en_r ? (8'b11111111 & (~(1<<daq_count_r))) : 8'b11111111;


// Have we read every DAQ? If so done
assign read_done_w = (daq_count_r > (DAQ_COUNT-1));

// Are we writing the header or the data?
assign fifo_wr_data_o = header_en_r ? (preamble_en_r ? `PREAMBLE_VAL : pkt_counter_r) 
								  : db_i;

// Packet Construction State Machine
always@(negedge rd_o, posedge reset_i) begin
	if(reset_i) begin
		read_state_r = WAIT_ON_TRIG;
	end else begin
		read_state_r = read_nextstate_r;
	end	
end

// Select state of packet
always@(*) begin
	case(read_state_r)
	WAIT_ON_TRIG: begin		
		cs_en_r = 0;
		rd_en_r = 0;
		preamble_en_r = 0;
		header_en_r = 0;
		if(!conv_clk_o )		
			read_nextstate_r = WAIT_ON_BUSY_HIGH;		
	end
	WAIT_ON_BUSY_HIGH: begin
		preamble_en_r = 0;
		header_en_r = 0;
		cs_en_r = 0;
		rd_en_r = 0;
		if(busy_i)
			read_nextstate_r = WAIT_ON_BUSY_LOW;			
	end
	WAIT_ON_BUSY_LOW:
		if(!busy_i) begin		
			read_nextstate_r = PREAMBLE;
		end
	PREAMBLE: begin
			header_en_r = 1;
			preamble_en_r = 1;
			rd_en_r = 1;
		read_nextstate_r = PACKET_COUNT;	
	end
	PACKET_COUNT: begin
		preamble_en_r = 0;
		read_nextstate_r = READ_ADC;
		
	end
	READ_ADC: begin
			header_en_r = 0;
			cs_en_r = 1;						
			if(read_done_w) begin
				rd_en_r = 0;
				cs_en_r = 0;						
				read_nextstate_r = READ_DONE;			
			end
	end
	READ_DONE: begin	
		if(busy_i)
			read_nextstate_r = WAIT_ON_BUSY_HIGH;
		else
			read_nextstate_r = WAIT_ON_TRIG;						
	end
	default: 
		read_nextstate_r = WAIT_ON_TRIG;					
	endcase	
end


// Increment counters depending on state
always@(negedge rd_o, posedge reset_i) begin
	if(reset_i) begin
		pkt_counter_r = 0;
		adc_count_r = 0;
		daq_count_r = 0;
	end
	else begin
		case(read_state_r)
		READ_ADC: begin
			if(adc_count_r<ADC_COUNT)
				adc_count_r = adc_count_r + 1;
			else begin
				adc_count_r = 1;
				daq_count_r = daq_count_r + 1;			
			end
		end
		READ_DONE: begin
			pkt_counter_r = pkt_counter_r + 1;
			adc_count_r = 0;
			daq_count_r = 0;	
		end
		default: begin
			adc_count_r = 0;
			daq_count_r = 0;
		end
		endcase
	end
end


// Only write to FIFO if we are not full!
assign fifo_wr_en_o = rd_en_r & !fifo_wr_full_i;
assign fifo_wr_clk_o = rd_o;


endmodule

