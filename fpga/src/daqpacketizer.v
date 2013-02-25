`timescale 1ns/1ps
`define HI      1
`define LO      0


module daqpacketizer(
input wire clk_i, //Expect 200MHz clock
input wire en_i,

//AD7606 signals
output wire conv_clk_o,
input wire reset_i,
output wire rd_o,
output wire rd_en_o,
output wire wr_en_o,
output wire [7:0] cs_o,
input wire [15:0] db_i,
output wire [7:0] db_o,
input wire busy_i,
input wire frstdata_i,
input wire [2:0] os_sel_i
);

parameter ADC_COUNT = 8;
parameter DAQ_COUNT = 8;

parameter WAIT_ON_TRIG = 3'b000;
parameter WAIT_ON_BUSY_HIGH = 3'b001;
parameter WAIT_ON_BUSY_LOW = 3'b010;
parameter PREAMBLE = 3'b011;
parameter PACKET_COUNT = 3'b100;
parameter READ_ADC = 3'b101;
parameter READ_DONE = 3'b110;



reg [2:0] read_state_r;
reg [2:0] read_nextstate_r;

reg [3:0] adc_count_r;
reg [3:0] daq_count_r;

reg[15:0] packetcount_r;

wire [15:0] db_w;

reg preamble_en_r;
reg cs_en_r;
reg rd_en_r;

wire read_done_w;

wire [7:0] cs_temp_w;

wire [1:0] a;

daqrdclk udaqrdclk(
  .clk_i(clk_i),
  .reset_i(reset_i),
  .clk_en_o(rd_en_o),
  .clk_o(rd_o),
  .en_i(rd_en_r)
);

daqtriggerctrl udaqtrig(
  .clk_i(clk_i),
  .busy_i(busy_i),
  .conv_clk_o(conv_clk_o),
  .reset_i(reset_i),
  .en_i(en_i)
);

assign cs_temp_w = 8'b11111111 & (~(1<<daq_count_r));
assign wr_en_o = (&cs_o) & !preamble_en_r;
assign cs_o = cs_en_r ? cs_temp_w : 8'b11111111;

always@(negedge rd_o, posedge reset_i) begin
	if(reset_i) begin
		read_state_r = WAIT_ON_TRIG;
	end else begin
		read_state_r = read_nextstate_r;
	end	
end

assign read_done_w = (daq_count_r > 7) & (adc_count_r > 7);


assign db_w = preamble_en_r ? 16'hAAAA : db_i;

always@(*) begin
	case(read_state_r)
	WAIT_ON_TRIG: begin		
		cs_en_r = 0;
		rd_en_r = 0;
		preamble_en_r=0;
		if(!conv_clk_o )		
			read_nextstate_r = WAIT_ON_BUSY_HIGH;		
	end
	WAIT_ON_BUSY_HIGH:
		if(busy_i)
			read_nextstate_r = WAIT_ON_BUSY_LOW;			
	WAIT_ON_BUSY_LOW:
		// One more cycle ... is this needed?
		if(!busy_i)	begin	
			preamble_en_r = 1;
			read_nextstate_r = PREAMBLE;
		end
	PREAMBLE: begin
		read_nextstate_r = READ_ADC;
	end
	READ_ADC: begin
			rd_en_r = 1;
			cs_en_r = 1;		
			preamble_en_r = 0;			
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


always@(negedge rd_o) begin
	case(read_state_r)
	READ_ADC: begin
		if(adc_count_r<8)
			adc_count_r = adc_count_r + 1;
		else begin
			adc_count_r = 1;
			daq_count_r = daq_count_r + 1;			
		end
	end
	READ_DONE: begin
		adc_count_r = 0;
		daq_count_r = 0;	
	end
	default: begin
		adc_count_r = 0;
		daq_count_r = 0;
	end
	endcase
end

wire full_w;
wire wr_en_full_w;

assign wr_en_full_w = !wr_en_o & !full_w;

async_fifo ufifo (
  .rst(reset_i), // input rst
  .wr_clk(rd_o), // input wr_clk
  .rd_clk(), // input rd_clk
  .din(db_w), // input [15 : 0] din
  .wr_en(wr_en_full_w), // input wr_en
  .rd_en(), // input rd_en
  .dout(), // output [7 : 0] dout
  .full(full_w), // output full
  .overflow(), // output overflow
  .empty(), // output empty
  .underflow() // output underflow
);



endmodule
