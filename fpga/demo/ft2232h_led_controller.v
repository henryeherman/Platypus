//==========================================
// File Name: ft2232h_led_controller.v
// Function : Take the Data from a PC and set
//            the LED output to match
// Coder    : Henry Herman
// Date     : Aug 13, 2012
// Location : Written at UCLA NESL < http://nesl.ee.ucla.edu/ >
// Notes    : This is a quick demo to show a Xilinix Spartan 3
//            FPGA streaming data continuously from the FT2232H USB UART/FIFO
//            IC.
//            It is a proof of concept showing how to correctly receive data
//            from the FT IC to the FPGA
//            It is included in the platypus daq project to show
//            how it was developed. 
//=========================================

`timescale 1ns/1ps
`define HI  1
`define LO  0

module ft2232h_led_controller
#( parameter WAIT_FOR_RDREQ = 1'b0,
             READING = 1'b1,

             PREAMBLE = 8'hAA)
(
  input wire clk_i,
  input wire rxf_i,
  input wire [7:0] data_i,
  input wire oe_i,  
  output reg rd_o, 
  input wire rst_i,
  output reg [7:0] led_r=8'b0

);

reg read_state = WAIT_FOR_RDREQ;
reg read_nextstate = WAIT_FOR_RDREQ;

reg cmd_state;

always@(posedge clk_i) begin
  read_state <= read_nextstate;  
end

always @(read_state, oe_i, rxf_i, rst_i) begin
  if(rst_i == `HI) begin
    read_nextstate <= WAIT_FOR_RDREQ;
  end else begin
    case (read_state)
      WAIT_FOR_RDREQ: begin
        rd_o = `HI;
        if(oe_i == `LO && rxf_i == `LO)
          read_nextstate = READING;          
      end
      READING: begin
        if(oe_i==`HI | rxf_i == `HI) begin
          rd_o = `HI;
          read_nextstate = WAIT_FOR_RDREQ;
        end else
          rd_o = `LO;
      end
      default:
        read_nextstate = WAIT_FOR_RDREQ;
    endcase
  end
end


// TODO: Turn this into a statemachine!
always @(negedge clk_i) begin
  if (clk_i == `LO && rd_o==`LO) begin
    led_r = data_i;
    $display("LED VALUE: \t %H", led_r);
  end
end


endmodule
