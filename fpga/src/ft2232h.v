`timescale 1ns/1ps

`define LO     0
`define HI     1

module ft2232h(
data,
rfx_o,
txe_o,
rd_i,
wr_i,
clkout_o,
oe_i,
);



inout [7:0] data;
wire [7:0] data_out;
wire [7:0] data_in;

output reg rfx_o;
output reg txe_o;
input rd_i;
input wr_i;
output reg clkout_o;
input oe_i;
input sim_rxe_i;

integer outfile;

// Setup RX Process
initial begin
        outfile = $fopen("simulation/toPc.tv", "w");
        clkout_o = `LO;
        txe_o =`HI; #50;
        txe_o =`LO ; #10;
end

// USB Clock output
always begin
        clkout_o = !clkout_o; #16;
end
        
// RX Process
always @ (posedge clkout_o) begin
        if ((txe_o == `LO) && (wr_i == `LO)) begin
                $fwrite(outfile,"%x\n", data_in);
                $display("RECV %x", data_in); 
        end
end

assign data = (!oe_i) ? data_out : 8'bz;

assign data_in = (!wr_i) ? data : 8'bz;


endmodule
