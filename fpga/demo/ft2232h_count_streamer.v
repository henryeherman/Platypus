//==========================================
// File Name: ft2232h_count_streamer.v
// Function : Stream to FT2232H in FT245 Synchronous Mode 
// Coder    : Henry Herman
// Date     : July 25, 2012
// Location : Written at UCLA NESL < http://nesl.ee.ucla.edu/ >
// Notes    : This is a quick demo to show a Xilinix Spartan 3
//            FPGA streaming data continuously to the FT2232H USB UART/FIFO
//            IC.
//            It is a proof of concept showing how to correctly transmitt data
//            from the FPGA to the FT IC 
//            It is included in the platypus daq project to show
//            how it was developed. 
//=========================================

`timescale 1ns/1ps
`define HI  1
`define LO  0

module ft2232h_count_streamer
#(parameter  WAIT_TXE_LO = 3'b00,  // Wait for TXE to be LO
            WR_LO = 3'b01,  // Enable writing by taking WR LO
            WRITING = 3'b10) // Write till TXE is HI

(  input wire clk_i,  // CLKOUT - 60MHz synchronous clock from FT2232H
  inout wire [7:0] adbus_o, // ADBUS[7:0] - Bidirection data port to USB Fifo
  input wire txe_i, // TXE - TX enable bit, controls when data can be written
  output reg wr_o, // WR - controls when data is written in to TX Fifo, write on LOW
  output reg oe_o, // OE - controls when data can be driven on bus, LOW to drive data
  input wire rst_i,
  output wire blinker_o ); // Clock divided output, blink during transmit


reg [1:0] write_state, write_nextstate;

reg [22:0] cnt_r = 'b0;
reg [7:0] adbus_r = 'b0;
//reg [7:0] adbus_w; // Not Used

// Synchronous State Machine
always @(negedge clk_i) begin
    write_state <= write_nextstate;
    if (write_state == WRITING) begin
      cnt_r <= cnt_r + 1; // Blink LED
      adbus_r <= adbus_r + 1; // Increment TX Data byte
    end 
end


// Change state on TXE
always @(write_state, txe_i, rst_i) begin
  if(rst_i == `HI) begin
    write_nextstate <= WAIT_TXE_LO;
    wr_o <= 1;
    oe_o <= 0; // OK to RX
  end else begin
    case (write_state)
      WAIT_TXE_LO: begin
        wr_o <= 1;
        oe_o <= 0; // OK to RX
        if ( txe_i == `LO ) begin
          write_nextstate <= WR_LO;  // Next clock enable WRiting
        end else
		    write_nextstate <= WAIT_TXE_LO;
      end
      WR_LO: begin
        wr_o <= 0;  // Enable WRiting
        oe_o <= 1;  // OK to TX
        if( txe_i == `HI)  // Make sure WRiting is not disabled
          write_nextstate <= WAIT_TXE_LO;
        else
          write_nextstate <= WRITING; // Go to WRite state
      end
      WRITING: begin
		  wr_o <= 0;
		  oe_o <= 1;
        if( txe_i == `HI) // WRite until TXE goes high
          write_nextstate <= WAIT_TXE_LO;
		  else
		    write_nextstate <= WRITING;
      end 
		default: begin
			wr_o <= 1;
			oe_o <= 0;
			write_nextstate <=WAIT_TXE_LO;
		end
    endcase
  end
end

// Recieve or Transmit depending on OE
assign adbus_o = (oe_o) ? adbus_r : 8'bz; 
assign blinker_o = cnt_r[22];
endmodule
