`timescale 1ns/1ps
//==========================================
// File Name: ft2232h_demo_tx_tb.v
// Function : Simulate TX Demo Stream to FT2232H in FT245 Synchronous Mode 
// Coder    : Henry Herman
// Date     : July 25, 2012
// Location : Written at UCLA NESL < http://nesl.ee.ucla.edu/ >
// Notes    : This is a quick demo to show a Xilinix Spartan 3
//            FPGA streaming data continuously to the FT2232H USB UART/FIFO
//            IC.
//            It is a proof of concept showing how to correctly transmit data
//            from the FPGA to the FT IC 
//            It is included in the platypus daq project to show
//            how it was developed. 
//=========================================

`define HI  1
`define LO  0
`define TESTTX

module ft2232h_demo_tx_tb;

wire clkout_w;
wire oe_w;
wire wr_w;
wire txe_w;

wire [7:0] data_w;

wire blinker_o;

reg reset_r;
wire reset_n;

initial begin
        $dumpvars;
        reset_r = 0;
        #10;
        reset_r = 1;
        #10;
        reset_r = 0;
        #600;
        $finish;
end

assign reset_n = !reset_r;

// Simulated FT2232H
ft2232h uft2232h(
.data(data_w),
.rxf_o(),
.clkout_o(clkout_w),
.oe_i(oe_w),
.txe_o(txe_w),
.rd_i(),
.wr_i(wr_w),
.reset_i(reset_n)
);

// Module To Stream Counter to PC
ft2232h_count_streamer uFtCount(
.clk_i(clkout_w),
.adbus_o(data_w),
.txe_i(txe_w),
.wr_o(wr_w),
.oe_o(oe_w),
.rst_i(reset_r),
.blinker_o(blinker_o)
);

endmodule


