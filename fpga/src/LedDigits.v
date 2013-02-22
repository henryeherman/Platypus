// Driving StickIt!

`timescale 1ns/1ps

`define HI      1
`define LO      0

module LedDigitsDisplay 
(
input wire clk_i,
input wire [6:0] ledDigit1_i,
input wire [6:0] ledDigit2_i,
input wire [6:0] ledDigit3_i,
input wire [6:0] ledDigit4_i,
input wire [6:0] ledDigit5_i,
input wire [6:0] ledDigit6_i,
input wire [6:0] ledDigit7_i,
input wire [6:0] ledDigit8_i,
input wire [55:0] ledDigitsAll_i,
output reg [7:0] ledDrivers_o,
output reg [7:0] tris_o,
output reg [7:0] digitShf_r = 8'b00000001,
output reg [7:0] segShf_r=8'b00010100
);

// Assume clock frequency 12MHz;
// Assume 1kHz led update frequency

parameter SEG_PERIOD_C = 215;

reg [6:0] ii = 0;
reg [6:0] jj = 0;

wire [55:0] segments_w = {ledDigit1_i,
                          ledDigit2_i,
                          ledDigit3_i,
                          ledDigit4_i,
                          ledDigit5_i,
                          ledDigit6_i,
                          ledDigit7_i,
                          ledDigit8_i} | ledDigitsAll_i;
reg [7:0] cathodes_r = 0;
integer segTimer_int = SEG_PERIOD_C;
integer segCntr_int = 8;

always @(posedge clk_i) begin
  if ( segTimer_int != 0) begin
    segTimer_int = segTimer_int - 1;
  end else begin
    segShf_r = {segShf_r[6:0], segShf_r[7]};
    segTimer_int = SEG_PERIOD_C;
    if (segCntr_int !=0) begin
        segCntr_int = segCntr_int - 1;
    end else begin
        digitShf_r = {digitShf_r[6:0],digitShf_r[7]};
        segCntr_int = 8;
    end
  end
end 

always @(digitShf_r, segments_w) begin
  case (digitShf_r)
    8'b00000001: cathodes_r = !segments_w[6:0];
    8'b00000010: cathodes_r = !segments_w[13:7];
    8'b00000100: cathodes_r = !segments_w[20:14];
    8'b00001000: cathodes_r = !segments_w[27:21];
    8'b00010000: cathodes_r = !segments_w[34:28];
    8'b00100000: cathodes_r = !segments_w[41:35];
    8'b01000000: cathodes_r = !segments_w[48:42];
    8'b10000000: cathodes_r = !segments_w[55:49];
    default: cathodes_r = 8'b11111111;
  endcase
end


always @(digitShf_r, segShf_r, cathodes_r) begin
    tris_o = 8'b11111111;
    jj = 0;
    for(ii = 0; ii < 8; ii=ii+1) begin
        if(digitShf_r[ii] == 0) begin
            if(segShf_r[ii] == 1 && cathodes_r[jj] == 0)
                tris_o[ii] = 0;
            jj = jj + 1;
        end        
    end
  
end

endmodule
