`timescale 1ns/1ps

module leddigits_tb;

parameter FREQ_G = 25600;

integer cntr_int = FREQ_G;

`include "seven_segment_ascii_decoder.v"


initial begin
    $dumpvars;
    #512000;
    $finish;
end

reg [55:0] ascii_r = 56'b01000000100000010000001000000100000010000001000000100000;

reg clk_r = 0;
always begin
  clk_r = !clk_r;
  #5;
end


reg [7:0] asciiChar = 0'b00000000;

always @(posedge clk_r) begin
    if(cntr_int == 0) begin
        cntr_int = FREQ_G;
        ascii_r = {ascii_r[48:0], asciiChar[6:0]};
        if(asciiChar == 7'b1111111)
            asciiChar = 7'b0000000;
        else
            asciiChar = asciiChar + 1;
    end else begin
        cntr_int = cntr_int - 1;
    end    
end

LedDigitsDisplay uleddigits(
.clk_i(clk_r),
.ledDigit1_i(CharToLedDigit(ascii_r[6:0])),
.ledDigit2_i(CharToLedDigit(ascii_r[13:7])),
.ledDigit3_i(CharToLedDigit(ascii_r[20:14])),
.ledDigit4_i(CharToLedDigit(ascii_r[27:21])),
.ledDigit5_i(CharToLedDigit(ascii_r[34:28])),
.ledDigit6_i(CharToLedDigit(ascii_r[41:35])),
.ledDigit7_i(CharToLedDigit(ascii_r[48:42])),
.ledDigit8_i(CharToLedDigit(ascii_r[55:49])),
.ledDigitsAll_i(0)
);

endmodule


