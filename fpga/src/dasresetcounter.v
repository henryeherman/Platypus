`timescale 1ns/1ps
`define HI      1
`define LO       0

module dasresetcounter
#(parameter     RESETLEN=65536)

(input wire clk_i,
output wire reset_o,
input wire reset_i,
input wire en_i
);

reg [32:0] clkcount = 0;

reg reset_r;

// Generate pulses for read clock
// Expect 200MHz Clockin

always@(posedge clk_i, posedge reset_i) begin
	if(reset_i) begin                
		clkcount = 0;
	end else begin
		clkcount = clkcount + 1;
	end	
end

assign reset_o = (en_i) ? (clkcount < RESETLEN): 0;

endmodule
