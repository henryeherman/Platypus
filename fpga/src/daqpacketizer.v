`timescale 1ns/1ps
`define HI      1
`define LO      0
module daqpacketizer(
clk_i,
os_sel_i,
reset_i
);


input wire clk_i;
input wire [2:0] os_sel_i;
wire frstdata_w;
input wire reset_i;

//AD7606 Signals
reg conv_clk_o;
wire busy_w;
reg rd_r;
reg [3:0] cs_r;
wire [15:0] db_w;


//Fifo Signals
wire wrfull;
reg wrreq;
reg wrclk;

reg [9:0] clkcount;

parameter IDLE = 2'b00;
parameter WAIT_FOR_BUSY = 2'b01;
parameter TRIGGER = 2'b10;
parameter ENDTRIFFER = 2'b11;

reg [1:0] trigger_state;
reg [1:0] trigger_nextstate;


//Generate Convrsion clock 
//TODO! Parameterize

always @(posedge clk_i) begin
        if (clkcount==500/2) begin
                conv_clk_o = 0;
        end else if (clkcount == 500/2+50) begin
                conv_clk_o = 1;
        end else if (clkcount == 500) begin
                clkcount = 0;
        end
        clkcount = clkcount + 1;
end






always @(posedge reset_i) begin
        clkcount <= 0;
        cs_r <= 4'b1;
        conv_clk_o <= `HI;
        rd_r <= `HI;
        trigger_state <= IDLE;
        trigger_nextstate <=IDLE;
 
end

ad7606 uad7606_1
        (.convstw_i(conv_clk_o),
        .reset_i(reset_i),
        .busy_o(busy_w),
        .rd_i(rd_r),
        .cs_i(cs_r[0]),
        .db_o(db_w),
        .frstdata_o(frstdata_w),
        .os_i(os_sel_i)
        );

aFifo #(.DATA_WIDTH(8), .ADDRESS_WIDTH(6)) ufifo 
        (//.q(fifo_data_out),
        //.rdempty(rdempty),
        //.rdreq(rdreq),
        //.rdclk(rdclk),
        //.data(data_in),
        .wrfull(wrfull),
        .wrreq(wrreq),
        .wrclk(wrclk),
        .clear(reset)
        );


endmodule
