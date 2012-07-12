`timescale 1ns/1ps

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
);



inout [7:0] data;
wire [7:0] data_out;
wire [7:0] data_in;

output wire rxf_o;
output reg txe_o;
input rd_i;
input wr_i;
output reg clkout_o;
input oe_i;
input sim_rxe_i;

integer outfile;

//Setup RX Module
// FROM PC!
ft2232h_rx rxmod(
        .data(data_out),
        .rxf_o(rxf_o),
        .rd_i(rd_i),
        .oe_i(oe_i),
        .clk_i(clkout_o)
);

// TO PC!
ft2232h_tx txmod(
        .data(data_in),
        .wr_i(wr_i),
        .clkout_i(clkout_o),
        .txe_i(txe_o)
);

// Setup TX Process
initial begin
        clkout_o = `LO;
        txe_o = `LO; 
end

// USB Clock output
always begin
        clkout_o = !clkout_o; #16;
end
       

assign data_in = data;

assign data = (!oe_i) ? data_out : 8'bz;

assign data_in = (!wr_i & oe_i) ? data : 8'bz;


endmodule
