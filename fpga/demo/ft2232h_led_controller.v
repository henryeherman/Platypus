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

             CMD_EMPTY = 8'h00,
             CMD_PREAMBLE = 8'hAA,
             CMD_SETLED = 8'h01
)             
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

reg [7:0] cmdmsg_m[0:2];

reg [7:0] tmpcmd;

reg [1:0] cmdcount = 2'd0;
integer bytecount = 0;

reg [7:0] cmdmsg_m_0;
reg [7:0] cmdmsg_m_1;
reg [7:0] cmdmsg_m_2;


initial begin
  cmdmsg_m[0] = CMD_EMPTY;
  cmdmsg_m[1] = CMD_EMPTY;
  cmdmsg_m[3] = CMD_EMPTY;
  cmdmsg_m_0 = CMD_EMPTY;
  cmdmsg_m_1 = CMD_EMPTY;
  cmdmsg_m_2 = CMD_EMPTY;
end

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


always @(negedge clk_i, rst_i) begin
  if(rst_i == `HI) begin
    cmdmsg_m[0] = CMD_EMPTY;
    cmdmsg_m[1] = CMD_EMPTY;
    cmdmsg_m[2] = CMD_EMPTY;
    cmdmsg_m_0 = CMD_EMPTY;
    cmdmsg_m_1 = CMD_EMPTY;
    cmdmsg_m_2 = CMD_EMPTY;
    bytecount = 0;
  end else begin
    if(rd_o == `LO) begin
      cmdmsg_m[2] = cmdmsg_m[1];
      cmdmsg_m[1] = cmdmsg_m[0];
      cmdmsg_m[0] = data_i;
      
      cmdmsg_m_2 = cmdmsg_m_1;
      cmdmsg_m_1 = cmdmsg_m_0;
      cmdmsg_m_0 = data_i;
      bytecount = bytecount + 1;
    end
  end
end

always @(bytecount) begin
  if (cmdmsg_m[2] == CMD_PREAMBLE && cmdcount == 0) begin
    $display("REC:PREAMBLE");
    $display("CMD:%x%x%x",cmdmsg_m[2],cmdmsg_m[1],cmdmsg_m[0]);
    cmdcount = 2'd3;
    case (cmdmsg_m[1])
      CMD_SETLED:
        led_r = cmdmsg_m[0];
      default: begin
      end
    endcase
  end else if (cmdcount > 0) 
    cmdcount = cmdcount - 1;
end

always @(led_r)
  $display("LEDVAL:%x",led_r);

endmodule
