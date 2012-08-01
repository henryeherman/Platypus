`timescale 1ns/1ps
`define HI      1
`define LO      0


module daqcon(
clk_i,
en_o,
os_o,
data_i
);

input wire clk_i;
output reg en_o;
output reg [2:0] os_o;
input wire [7:0] data_i;






endmodule
