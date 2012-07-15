`timescale 1ns/1ps
`define HI      1
`define LO      0
module daqpacketizer(
clk_i,
os_sel_i,
reset_i,
en_i
);

parameter ADCCOUNT = 8;

parameter BUSY = 3'b000;
parameter FIRST_DATA = 3'b001;
parameter COUNT_VALS = 3'b010;
parameter COMPLETE = 3'b100;

reg [2:0] read_state;
reg [2:0] read_nextstate;

reg [3:0] adc_count;


input wire clk_i; //Expect 200MHz clock
input wire [2:0] os_sel_i;
wire frstdata_w;
input wire reset_i;
input wire en_i;

//AD7606 Signals
wire conv_clk_o;
wire busy_w;
wire rd_w;
reg [3:0] cs_r;
wire [15:0] db_w;

reg rd_clk;
reg rd_en;

//Fifo Signals
wire wrfull;
reg wrreq;
reg wrclk;

reg [3:0] clkcount;
reg [9:0] count_til_trigger_on;
reg [9:0] count_til_trigger_off;

reg [1:0] trigger_state;
reg [1:0] trigger_nextstate;



// Generate 15ns pulses for read clock
always@(posedge clk_i, reset_i) begin
        if(reset_i) begin
                rd_clk <= 0;
                rd_en <= 1;
                clkcount <= 0;
        end else begin
                clkcount = clkcount + 1;
                if (clkcount > 2) begin
                        rd_clk <= !rd_clk;
                        clkcount <= 0;
                end
        end
end

assign rd_w = (rd_en) ? rd_clk : `HI;

always @(posedge reset_i) begin
        cs_r <= 4'b1;
end


always @(posedge clk_i, reset_i) begin

        if (reset_i) begin
                read_nextstate <= BUSY;
                read_state <= BUSY;
        end  begin
                read_state <= read_nextstate;
        end        
end

always @(negedge busy_w) begin
        read_nextstate <= FIRST_DATA;
end

always @(negedge rd_clk, read_state) begin
        case(read_state)
                BUSY: begin
                        rd_en <= 0;
                        cs_r[0] <= 1;                      
                        adc_count <= 0;
                end
                FIRST_DATA: begin
                        rd_en <= 1;
                        cs_r[0] <= 0;
                        if (adc_count > 7) 
                                read_nextstate = BUSY; 
                        adc_count = adc_count + 1; 
                end
                default: begin
                        read_nextstate = BUSY;
                end
        endcase
end 


daqtriggerctrl udaqtrig(
        .clk_i(clk_i),
        .busy_i(busy_w),
        .conv_clk_o(conv_clk_o),
        .reset_i(reset_i),
        .en_i(en_i)
);

ad7606 uad7606_1
        (.convstw_i(conv_clk_o),
        .reset_i(reset_i),
        .busy_o(busy_w),
        .rd_i(rd_w),
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
