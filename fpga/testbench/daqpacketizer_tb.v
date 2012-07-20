`timescale 1ns/1ps
`define CLOCK_PERIOD_200MHZ 5 // ns
`define CLOCK_PERIOD_60MHZ 16 //ns
`define HI      1
`define LO      0

module daqpacketizer_tb;

reg clk_r;
reg [2:0] os_sel_r;
reg reset_r;
reg en_r;

wire wrclk_w;
wire rdreq_w;
wire [15:0] db_w;

reg fifo_out_clk;
wire fifo_out_empty;
reg fifo_out_req;

wire [7:0] fifo_out_data;

wire [7:0] t;

// Initialize Packetizer and Test
initial begin
  $dumpvars;
  clk_r = 1;
  fifo_out_clk = 0;
  fifo_out_req = 0;
  en_r = 1;
  os_sel_r = 3'b0;
  reset_r = 0;#5
  reset_r = 1; #10;
  reset_r = 0;
  #40000;
  $finish;
end

// Generate 200MHz clock
always begin
  clk_r = !clk_r; #(`CLOCK_PERIOD_200MHZ/2.0);
end


// Generate 60MHz clock
always begin
  fifo_out_clk = !fifo_out_clk; #(`CLOCK_PERIOD_60MHZ/2.0);
end

// Control Fifo RdReq
always @(fifo_out_clk) begin
  fifo_out_req = !fifo_out_empty;
end


// TODO: OUTPUT TO FILE!
always @(db_w) begin
  if(rdreq_w)
    $display("%x", db_w);
end

daqpacketizer udaqpkt(
  .clk_i(clk_r),
  .os_sel_i(os_sel_r),
  .reset_i(reset_r),
  .en_i(en_r),
  .db_o(db_w),
  .rdreq_o(rdreq_w),
  .wrclk_o(wrclk_w),
  .fifo_out_clk(fifo_out_clk),
  .fifo_out_empty(fifo_out_empty),
  .fifo_out_req(fifo_out_req),
  .fifo_out_data(fifo_out_data)
);

// Show that timing for fifo data out is correct!
assign t = (fifo_out_req & fifo_out_clk) ? fifo_out_data : 8'bz;

endmodule
