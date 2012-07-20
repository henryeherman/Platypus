`timescale 1ns/1ps
`define HI      1
`define LO      0


module daqpacketizer(
clk_i,
en_i,

//AD7606 signals
conv_clk_o,
reset_i,
rd_o,
cs_o,
db_i,
db_o,
busy_i,
frstdata_i,
os_sel_i,

//Fifo out signals
wrclk_o,
rdreq_o,
fifo_out_clk,
fifo_out_empty,
fifo_out_req,
fifo_out_data,
);

parameter ADCCOUNT = 8;
parameter DAQCOUNT = 8;

parameter WAIT_ON_TRIG = 3'b000;
parameter WAIT_ON_BUSY_HIGH = 3'b001;
parameter WAIT_ON_BUSY_LOW = 3'b010;
parameter PREAMBLE = 3'b011;
parameter PACKETCOUNT = 3'b100;
parameter READ = 3'b101;
parameter READ_END = 3'b110;

// State variables control 
reg [2:0] read_state;
reg [2:0] read_nextstate;

reg [3:0] adc_count;


input wire clk_i; //Expect 200MHz clock
input wire [2:0] os_sel_i;
input wire frstdata_i;
input wire reset_i;
input wire en_i;
output wire [15:0] db_o;
output wire rdreq_o;
output wire wrclk_o;

//  TEMPS
input wire fifo_out_clk;
output wire fifo_out_empty;
input wire fifo_out_req;
output wire [7:0] fifo_out_data;

//AD7606 Signals
output wire conv_clk_o;
input wire busy_i;
output wire rd_o;
output reg [8:0] cs_o;
input wire [15:0] db_i;
reg [15:0] header_r;


wire rdclk_w;
reg rd_en;

//Fifo Signals
wire wrfull;
wire wrclk_w;
reg wr_en; //used to control header

reg [3:0] clkcount;
reg [9:0] count_til_trigger_on;
reg [9:0] count_til_trigger_off;

reg [3:0] daqcount;

reg [15:0] packetcount_r;

always @(reset_i) begin
  cs_o<=9'b111111111;        
end


always @(negedge wrclk_w, reset_i) begin
  if (reset_i) begin
    read_nextstate <= WAIT_ON_TRIG;
    read_state <= WAIT_ON_TRIG;
    packetcount_r = 0;
  end  begin
    read_state <= read_nextstate;
  end        
end


always @(conv_clk_o, busy_i, read_state, adc_count) begin
  case(read_state)
    WAIT_ON_TRIG: begin
      cs_o<=9'b111111111;
      rd_en = 0;
      wr_en = 0;
      daqcount = 0;
      if(conv_clk_o == `LO)
        read_nextstate = WAIT_ON_BUSY_HIGH;
    end
    WAIT_ON_BUSY_HIGH: begin
      if (busy_i == `HI) begin
        read_nextstate = WAIT_ON_BUSY_LOW;
      end
    end
    WAIT_ON_BUSY_LOW: begin
      if (busy_i == `LO) begin
        read_nextstate = PREAMBLE;
        end
    end
    PREAMBLE: begin      
      packetcount_r = packetcount_r + 1;
      header_r = 16'hAAAA;
      read_nextstate = PACKETCOUNT;       
      wr_en = 1;
      daqcount = 0;      
    end
    PACKETCOUNT: begin
     header_r = packetcount_r;
     read_nextstate = READ; 
    end
    READ: begin
      wr_en = 0;
      cs_o = 9'b111111111 & (~(1 << daqcount));
      rd_en = 1;                              
      if (adc_count > 7) begin
        read_nextstate = READ_END;
        daqcount = daqcount + 1;
      end
    end
    READ_END: begin
      rd_en  <= 0;
      if (daqcount < DAQCOUNT) begin
        adc_count <= 0;
        read_nextstate <= READ;
      end else if (adc_count > 8) begin
        if(busy_i)
          read_nextstate = WAIT_ON_BUSY_LOW;
        else
          read_nextstate = WAIT_ON_TRIG;

        cs_o<=9'b111111111;
      end
    end
    default: begin
        read_nextstate = WAIT_ON_TRIG;
    end
  endcase
end 


always @(posedge wrclk_w) begin
  if (read_state == READ || read_state == READ_END) begin
    if (adc_count > 8) 
      adc_count = 0;
    else
      adc_count = adc_count +1;
  end else
    adc_count = 0;
                        
end


wire wrreq_w = rd_en | wr_en; 
assign db_o = wr_en ? header_r : db_i;
assign wrclk_o = wrclk_w;
assign rdreq_o = rd_en;

daqrdclk udaqrdclk(
  .clk_i(clk_i),
  .reset_i(reset_i),
  .clk_en_o(rd_o),
  .clk_o(wrclk_w),
  .en_i(rd_en)
);

daqtriggerctrl udaqtrig(
  .clk_i(clk_i),
  .busy_i(busy_i),
  .conv_clk_o(conv_clk_o),
  .reset_i(reset_i),
  .en_i(en_i)
);


daqFifo #(.ADDRESS_WIDTH(6)) ufifo (
  .clear(reset_i),
  .data(db_o),
  .wrreq(wrreq_w),
  .wrclk(wrclk_w),
  .q(fifo_out_data),
  .rdclk(fifo_out_clk),
  .rdreq(fifo_out_req),
  .rdempty(fifo_out_empty)
);


endmodule
