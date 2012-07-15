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
wire conv_clk_o;
wire busy_w;
reg rd_r;
reg [3:0] cs_r;
wire [15:0] db_w;


//Fifo Signals
wire wrfull;
reg wrreq;
reg wrclk;

reg [9:0] clkcount;
reg [9:0] count_til_trigger_on;
reg [9:0] count_til_trigger_off;


parameter IDLE = 2'b00;
parameter WAIT_FOR_BUSY = 2'b01;
parameter TRIGGER = 2'b10;

reg [1:0] trigger_state;
reg [1:0] trigger_nextstate;

//Generate Convrsion clock 
//TODO! Parameterize

/*
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
*/
/*
always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
                trigger_state = IDLE;
                count_til_trigger_on = 0;
                count_til_trigger_off = 0;                
        end

        case(trigger_state)
                IDLE: begin
                        count_til_trigger_on=count_til_trigger_on+1;
                        if(count_til_trigger_on > 500) begin
                                count_til_trigger_on = 0;
                                if(busy_w==`HI) trigger_state = WAIT_FOR_BUSY;
                                else trigger_state = TRIGGER;
                        end
                end
                WAIT_FOR_BUSY: begin
                        if(busy_w==`LO) trigger_state = TRIGGER;
                end
                TRIGGER: begin
                        count_til_trigger_off=count_til_trigger_off+1;
                        if(count_til_trigger_off>50) begin
                                count_til_trigger_off=0;
                                trigger_state = IDLE;
                        end
                        
                end
                default:
                        trigger_state = IDLE;
          endcase
end

/*
always @(posedge clk_i, posedge reset_i) begin
        if(reset_i) begin
                trigger_state <= IDLE;
                trigger_nextstate <=IDLE;                
        end else begin
                trigger_state = trigger_nextstate;
        end
end
*/
/*
always @(trigger_state) begin
        case(trigger_state)
                IDLE: begin
                        conv_clk_o <= `HI;
                end
                WAIT_FOR_BUSY: begin
                        conv_clk_o <= `HI;
                end
                TRIGGER: begin
                        conv_clk_o <= `LO;
                end
                default: begin
                        conv_clk_o <= `HI;                       
                end
        endcase
end

*/


always @(posedge reset_i) begin
        //clkcount <= 0;
        cs_r <= 4'b1;
        rd_r <= `HI;
end

daqtriggerctrl udaqtrig(
        .clk_i(clk_i),
        .busy_i(busy_w),
        .conv_clk_o(conv_clk_o),
        .reset_i(reset_i)
);

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
