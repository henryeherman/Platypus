`timescale 1ns/1ps
`define TESTRX
`define TESTTX

module ft2232h_tb;
wire clkout_w;
reg oe_r;
reg rd_r;

wire [7:0] data_r;
wire [7:0] data_r_out;
reg [7:0] data_r_in;

wire rxf_w;

wire txe_w;
reg wr_r;
reg [31:0] ii;

reg [7:0]  dataToFifo [7:0];

parameter EMPTY         = 2'b00;
parameter PREPAREREAD   = 2'b01;
parameter READ          = 2'b10;
parameter PAUSE         = 2'b11;

reg[1:0] rdstate, rdnextstate;
reg rdreset;

initial begin
        $dumpvars;
        $readmemh("testbench/toFifo.tv", dataToFifo);
        rdreset = 0;
        ii = 0;
        data_r_in = 0;
        wr_r = 1;
        oe_r = 1;        
        rd_r = 1;
        //rdstate = PAUSE; 
        #10;
        rdreset = 1;
        #10;
        rdreset = 0;
       
        #600;
        $finish;
end


`ifdef TESTRX
always @(negedge clkout_w, posedge rdreset) begin
        if(rdreset) begin
                rdstate <= EMPTY;
                rdnextstate <=EMPTY;
        end else begin 
                rdstate <= rdnextstate;
        end
end

always @(rxf_w, rdstate) begin
        //$display("RXF %d", rxf_w);        
        case (rdstate)
                EMPTY: begin
                        oe_r<=1; rd_r<=1;
                        if(rxf_w == 0) rdnextstate = PREPAREREAD;
                end                
                PREPAREREAD: begin
                        oe_r<=0; rd_r<=1;
                        if(rxf_w == 0) rdnextstate = READ;
                        else rdnextstate = EMPTY;                        
                end
                READ: begin
                        oe_r<=0; rd_r<=0;
                        if(rxf_w == 1) rdnextstate = EMPTY;
                end                       
                default: begin
                   rd_r<=1; oe_r<=1;
                end
        endcase
end
`endif

ft2232h uft2232h(
.data(data_r),
.rxf_o(rxf_w),
.clkout_o(clkout_w),
.oe_i(oe_r),
.txe_o(txe_w),
.rd_i(rd_r),
.wr_i(wr_r)
);


assign data_r = (!wr_r) ? data_r_in  : 8'bz ;
assign data_r_out = (wr_r) ? data_r  : 8'bz ;

endmodule


