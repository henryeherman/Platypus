`timescale 1ns/1ps
//=============================================================================
//
// File Name: ft2232h_demo_rx_tb.v
// Function : Simulate TX Demo Stream to 
//            FT2232H in FT245 Synchronous Mode 
// Coder    : Henry Herman
// Date     : July 25, 2012
// Location : Written at UCLA NESL < http://nesl.ee.ucla.edu/ >
// Notes    : This is a quick demo to show a Xilinix Spartan 3
//            FPGA streaming data continuously from the FT2232H USB UART/FIFO
//            It is a proof of concept showing how to correctly receive data
//            from the FT IC to the FPGA
//            It is included in the platypus daq project to show
//            how it was developed. 
//==============================================================================

`define HI  1
`define LO  0

module ft2232h_demo_rx_tb;

wire clkout_w;
reg oe_r;
wire rd_w;
wire rxf_w;
wire [7:0] data_w;
wire txe_w;

wire [7:0] led_w;

reg reset_r;
wire reset_n;

initial begin
        $dumpvars;
        oe_r = `LO;
        reset_r = `LO;
        #10;
        reset_r = `LO;
        #10;
        reset_r = `LO;
        #1000;
        $finish;
end

assign reset_n = !reset_r;


always @(posedge clkout_w) begin
  if (rxf_w == `LO)
    oe_r = `LO;
  else
    oe_r = `HI;
end

// Simulated FT2232H

ft2232h uft2232h(
.data(data_w),
.clkout_o(clkout_w),
.oe_i(oe_r),
.rxf_o(rxf_w),
.rd_i(rd_w),
.wr_i(wr_w),
.reset_i(reset_n)
);

// Led Controller

ft2232h_led_controller ledctrl(
.clk_i(clkout_w),
.rxf_i(rxf_w),
.data_i(data_w),
.oe_i(oe_r),
.rd_o(rd_w),
.rst_i(reset_r),
.led_r(led_w)
);

endmodule


