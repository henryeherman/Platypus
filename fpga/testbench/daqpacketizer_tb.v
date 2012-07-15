`timescale 1ns/1ps
`define HI      1
`define LO      0

module daqpacketizer_tb;

reg clk_r;
reg [2:0] os_sel_r;
reg reset_r;

// Initialize Packetizer and Test
initial begin
        $dumpvars;
        clk_r = 1;
        os_sel_r = 3'b0;
        reset_r = 0;
        reset_r = 1; #10;
        reset_r = 0;
        #50000;
        $finish;
end


// Generate 200MHz clock
always begin
        clk_r = !clk_r; #5;
end


daqpacketizer udaqpkt(
.clk_i(clk_r),
.os_sel_i(os_sel_r),
.reset_i(reset_r)
);

endmodule
