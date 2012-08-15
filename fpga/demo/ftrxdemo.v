//#===================================================
// File Name: ftrxdemo.v
// Description: This Demo shows how to stream data
//                To the FT2232H USB UART FIFO
//                in FT245 Synchronous Mode
//                using the a XULA 200 Spartan 3 FPGA
//
// Author: Henry Herman
// Email: hherman@ucla.edu
// LAB: NESL @ UCLA <http://nesl.ee.ucla.edu/>  
//#===================================================

`timescale 1ns / 1ps
`define HI  1
`define LO  0

module ftrxdemo(
    input wire clk_i, // 12MHz from MCU
    input wire uclk_i,  // 60MHz from FT2232H
    output wire [1:0] blinker_o,
    input wire rxf_i, 
    output reg oe_o,
    output reg rd_o,
    input wire pwren_i,   
    inout wire [7:0] byte_io
    output wire [7:0] data_rx;    
  );

    wire clk_fast;
    wire reset_w;
	reg [25:0] cnt_r = 'b0;

    reg [7:0] byte_tx = 8'b0;
	
	always @(posedge clk_fast) begin
		cnt_r = cnt_r+1;
	end
    	
	
   // DCM_SP: Digital Clock Manager Circuit
   //         Spartan-3A
   // Xilinx HDL Language Template, version 14.1
   // 12MHz * 32 /2 = 192MHz
   DCM_SP #(
      .CLKFX_DIVIDE(2),   // Can be any integer from 1 to 32
      .CLKFX_MULTIPLY(32) // Can be any integer from 2 to 32
   ) DCM_SP_inst (      
      .CLKFX(clk_fast),   // DCM CLK synthesis out (M/D)      
      .CLKIN(clk_i),   // Clock input (from IBUFG, BUFG or DCM)      
      .RST(0)        // DCM asynchronous reset input
   );
   // End of DCM_SP_inst instantiation


  //============================
  // Control OE# on posedge of
  // FT2232H clk if RXF# LO
  // Set OE# LO   
  //============================

  always @(posedge uclk_i) begin
    if(reset_w) begin
      oe_o = `HI;
    end else begin
      if(rxf_i = `LO) begin 
        oe_o = `LO;
      end else begin
        oe_o = `HI;
      end
    end
  end

  always @(negedge uclk_i) begin
    if(reset_w) begin
      rd_o = `HI;
    end else begin
      if(oe_o==`LO) begin
        rd_o = `LO;
      end else begin
        rd_o = `HI;
      end
    end
  end
  
  always @(uclk_i) begin
    if (uclk_i == `LO) begin
      data_tx <= 8'b0;
      data_rx = byte_io;
    end
  end

  assign byte_io = (oe_o) ? data_tx : 8'bz;
  
  assign reset_w = pwren_i;
	
  assign blinker_o[1] = cnt_r[25];
  assign blinker_o[0] = cnt_r[31];

endmodule
