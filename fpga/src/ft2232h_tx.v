`timescale 1ns/1ps

`define LO     0
`define HI     1

module ft2232h_tx(
data,
wr_i,
clkout_i,
txe_i
);


input [7:0] data;
input wire wr_i;
input wire txe_i;
input wire clkout_i;


integer outfile;

// Setup TX Process
initial begin
        $timeformat(-9, 2, "ns", 6);
        outfile = $fopen("testbench/toPc.tv", "w");
end

// TX Process
always @ (clkout_i) begin
        if (!clkout_i &(txe_i == `LO) && (wr_i == `LO)) begin
                $fwrite(outfile,"%x\n", data);
                $display("  TX to PC:\t %t \t%H",$realtime, data); 
        end
end

endmodule
