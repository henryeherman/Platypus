`timescale 1ns/1ps
//`define TESTRX 1
//`define TESTTX 1
`define LO     0
`define HI     1

module ft2232h(
data,
rxf_o,
txe_o,
rd_i,
wr_i,
clkout_o,
oe_i,
reset_i
);



inout [7:0] data;
wire [7:0] data_out;
wire [7:0] data_in;

output wire rxf_o;
output reg txe_o;
input wire rd_i;
input wire wr_i;
output wire clkout_o;
input wire oe_i;

input reset_i;

reg clkout_r;

integer outfile;

//Setup RX Module

`ifdef TESTRX
// FROM PC!
ft2232h_rx rxmod(
        .data(data_out),
        .rxf_o(rxf_o),
        .rd_i(rd_i),
        .oe_i(oe_i),
        .clk_i(clkout_o)
);
`endif

`ifdef TESTTX
// TO PC!
ft2232h_tx txmod(
        .data(data_in),
        .wr_i(wr_i),
        .clkout_i(clkout_o),
        .txe_i(txe_o)
);
`endif

// Setup TX Process
initial begin
        clkout_r = `HI;
        txe_o = `LO; 
end

// USB Clock output
always begin
    txe_o = `LO;
    clkout_r = !clkout_r; #16;
end

always @(reset_i)
  if(reset_i==`LO)
    txe_o <= `HI;

assign clkout_o =  (reset_i) ? clkout_r : `HI;

assign data_in = data;

assign data = (!oe_i) ? data_out : 8'bz;

assign data_in = (!wr_i & oe_i) ? data : 8'bz;


endmodule
