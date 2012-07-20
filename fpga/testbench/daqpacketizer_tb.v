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

wire conv_clk_w;
wire rd_w;
wire [8:0] cs_w;
wire frstdata_w;
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
  // 200 MHz Clk
  .clk_i(clk_r),
  // Enable packetizer    
  .en_i(en_r),

  //AD7606 signals
  .conv_clk_o(conv_clk_w),
  .reset_i(reset_r),  
  .rd_o(rd_w),
  .cs_o(cs_w),
  .db_i(db_w),
  .busy_i(busy_w),
  //.db_o(daqdata),
  .frstdata_i(frstdata_w),
  .os_sel_i(os_sel_r),

  //.db_o(db_w),

  // Fifo data out!
  .rdreq_o(rdreq_w),
  .wrclk_o(wrclk_w),
  .fifo_out_clk(fifo_out_clk),
  .fifo_out_empty(fifo_out_empty),
  .fifo_out_req(fifo_out_req),
  .fifo_out_data(fifo_out_data)
);

// Show that timing for fifo data out is correct!
assign t = (fifo_out_req & fifo_out_clk) ? fifo_out_data : 8'bz;



ad7606 uad7606_0(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[0]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_1(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[1]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_2(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[2]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_3(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[3]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_4(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[4]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_5(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[5]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_6(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[6]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);

ad7606 uad7606_7(
  .convstw_i(conv_clk_w),
  .reset_i(reset_r),
  .busy_o(busy_w),
  .rd_i(rd_w),
  .cs_i(cs_w[7]),
  .db_o(db_w),
  .frstdata_o(frstdata_w),
  .os_i(os_sel_r)
);
endmodule

