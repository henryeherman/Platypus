`timescale 1ns/1ps
`define HI      1
`define LO       0

module daqrdclk
#(parameter     WAITHIGH=2,
                WAITLOW=3)

(input wire clk_i,
input wire reset_i,
output wire clk_en_o,
output wire clk_o,
input wire en_i
);

reg [2:0] clkcount;
reg clk_r;

// Generate pulses for read clock
// Expect 200MHz Clockin
always@(posedge clk_i, posedge reset_i) begin
        if(reset_i) begin
                clk_r <= `LO;
                clkcount <= 0;
        end else begin
                clkcount <= clkcount + 1;
                if (clkcount > WAITHIGH && clk_r==`HI) begin
                        clk_r <= `LO;
                        clkcount <= 0;
                end else if(clkcount >WAITLOW && clk_r ==`LO) begin
                        clk_r <= `HI;
                        clkcount <= 0;
                end
        end
end


assign clk_o = clk_r;
assign clk_en_o = (en_i) ? clk_r : `HI;

endmodule
