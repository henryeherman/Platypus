`timescale 1ns/1ps
`define HI      1
`define LO      0


module daqtriggerctrl(
clk_i,
busy_i,
conv_clk_o,
reset_i,
en_i
);

parameter IDLE = 2'b00;
parameter WAIT_FOR_BUSY = 2'b01;
parameter TRIGGER = 2'b10;
parameter PAUSE = 2'b11;

//TODO: Calculate these in Hertz using macro
parameter CYCLES_TIL_TRIGGER_ON = 990;
parameter CYCLES_TIL_TRIGGER_OFF = 10;

input wire clk_i;
input wire  busy_i;
output reg conv_clk_o;
input wire reset_i;
input wire en_i;

reg [1:0] trigger_state = IDLE;
reg [1:0] trigger_nextstate = IDLE;

reg [11:0] count_til_trigger_on = 0;
reg [9:0] count_til_trigger_off = 0;


always @(posedge clk_i, posedge reset_i, negedge en_i) begin
        if (!en_i) begin
                trigger_state = PAUSE;
                count_til_trigger_on = 0;
                count_til_trigger_off = 0;                
        end else if (reset_i) begin
                trigger_state = IDLE;
                count_til_trigger_on = 0;
                count_til_trigger_off = 0;                
        end else begin
                case(trigger_state)
                        IDLE: begin
                                count_til_trigger_on=count_til_trigger_on+1;
                                if(count_til_trigger_on > CYCLES_TIL_TRIGGER_ON) begin
                                        count_til_trigger_on = 0;
                                        if(busy_i==`HI) trigger_state = WAIT_FOR_BUSY;
                                        else trigger_state = TRIGGER;
                                end
                        end
                        WAIT_FOR_BUSY: begin
                                if(busy_i==`LO) trigger_state = TRIGGER;
                        end
                        TRIGGER: begin
                                count_til_trigger_off=count_til_trigger_off+1;
                                if(count_til_trigger_off>CYCLES_TIL_TRIGGER_OFF) begin
                                        count_til_trigger_off=0;
                                        trigger_state = IDLE;
                                end
                                
                        end
                        PAUSE:
                                trigger_state = PAUSE;
                                // DO NOTHING
                        default: begin
                                count_til_trigger_on=0;
                                count_til_trigger_off=0;
                                trigger_state = IDLE;
                        end
                  endcase
          end
end

always @(trigger_state) begin
        case(trigger_state)
                IDLE: begin
                        conv_clk_o <= `HI;
                end
                WAIT_FOR_BUSY: begin
                        conv_clk_o <= `HI;
                end
                TRIGGER: begin
                        conv_clk_o <= `LO;
                end
                PAUSE:
                        conv_clk_o <=`HI;
                default: begin
                        conv_clk_o <= `HI;                       
                end
        endcase
end

endmodule
