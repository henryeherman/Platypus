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
//`define TESTBENCH
`define HI  1
`define LO  0


module ft2232h_led_controller
#( parameter WAIT_FOR_RDREQ = 1'b0,
             READING = 1'b1,

             CMD_MSGLEN = 3,
             CMD_PARAMLEN = CMD_MSGLEN - 2,
            
             CMD_PREAMBLEPTR = CMD_MSGLEN - 1,
             CMD_CMDPTR = CMD_PREAMBLEPTR - 1,
             CMD_PARAMPTR = CMD_CMDPTR - 1,

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

reg [7:0] cmdmsg_m[0:CMD_MSGLEN-1];

reg [7:0] cmd_pre;

reg [7:0] tmpcmd;

integer cmdcount = 0;

integer bytecount = 0;

integer jj;

initial begin
  initialize_msg();
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
    initialize_msg();
    bytecount = 0;
  end else begin
    if(clk_i == `LO & rd_o == `LO) begin
      for(jj=CMD_MSGLEN-1;jj>0;jj=jj-1)
        cmdmsg_m[jj] = cmdmsg_m[jj-1];
      cmdmsg_m[0] = data_i;
`ifdef TESTBENCH
      $display("DATA:%x",data_i);
`endif
      bytecount = bytecount + 1;
    end
  end
end

always @(bytecount) begin
  if (cmdmsg_m[CMD_PREAMBLEPTR] == CMD_PREAMBLE && cmdcount == 0) begin
`ifdef TESTBENCH
    $display("CMD:%x%x%x",cmdmsg_m[CMD_PREAMBLEPTR],cmdmsg_m[CMD_CMDPTR],cmdmsg_m[CMD_PARAMPTR]);
`endif
    cmdcount = CMD_MSGLEN-1;
    case (cmdmsg_m[CMD_CMDPTR])
      CMD_SETLED:
        led_r = cmdmsg_m[CMD_PARAMPTR];
      default: begin
      end
    endcase
  end else if (cmdcount > 0) 
    cmdcount = cmdcount - 1;
end


`ifdef TESTBENCH
always @(led_r)
  $display("LEDVAL:%x",led_r);
`endif

task initialize_msg;
  integer ii;
  for(ii=0;ii<CMD_MSGLEN;ii=ii+1)      
    cmdmsg_m[ii] = 8'b0;      
endtask

endmodule
