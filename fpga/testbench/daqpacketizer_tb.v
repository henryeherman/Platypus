`timescale 1ns/1ps
`define CLOCK_PERIOD 5 // ns
`define HI      1
`define LO      0

module daqpacketizer_tb;

reg clk_r;
reg [2:0] os_sel_r;
reg reset_r;
reg en_r;

wire rdclk_w;
wire rdreq_w;
wire [15:0] db_w;

reg fifo_out_clk;
wire fifo_out_empty;
reg fifo_out_req;

// Initialize Packetizer and Test
initial begin
        $dumpvars;
        clk_r = 1;
        fifo_out_clk = 0;
        fifo_out_req = 0;
        en_r = 1;
        os_sel_r = 3'b0;
        reset_r = 0;#5
        reset_r = 1; #10;
        reset_r = 0;
        #50000;
        $finish;
end

// Generate 200MHz clock
always begin
        clk_r = !clk_r; #(`CLOCK_PERIOD/2.0);
end

always begin
        fifo_out_clk = !fifo_out_clk; #15;
end

always @(posedge fifo_out_clk) begin
        if(!fifo_out_empty)
                fifo_out_req = 1;
        else 
                fifo_out_req = 0;
end

// OUTPUT TO FILE!
always @(db_w) begin
        if(rdreq_w)
                $display("%x", db_w);
end

daqpacketizer udaqpkt(
.clk_i(clk_r),
.os_sel_i(os_sel_r),
.reset_i(reset_r),
.en_i(en_r),
.db_o(db_w),
.rdreq_o(rdreq_w),
.rdclk_o(rdclk_w),
.fifo_out_clk(fifo_out_clk),
.fifo_out_empty(fifo_out_empty),
.fifo_out_req(fifo_out_req)
);

endmodule
