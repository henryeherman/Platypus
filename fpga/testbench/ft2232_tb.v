`timescale 1ns/1ps


module ft2232h_tb;
wire clkout_w;
reg oe_r;

wire [7:0] data_r;
wire [7:0] data_r_out;
reg [7:0] data_r_in;

wire txe_w;
reg wr_r;
reg [31:0] ii;

reg [7:0]  dataToFifo [7:0];


initial begin
        ii = 0;
        data_r_in = 0;
        wr_r = 1;
        oe_r = 1;
        $readmemh("testbench/toFifo.tv",dataToFifo);
        $dumpvars;
        #1000;
        $finish;
end

always @(negedge clkout_w) begin
        if ((txe_w == 0) && (ii < 8)) begin
                wr_r = 0;
                data_r_in<= dataToFifo[ii];
                ii = ii + 1;
        end else begin
                wr_r = 1;
        end
end


ft2232h uft2232h(
.data(data_r),
.clkout_o(clkout_w),
.oe_i(oe_w),
.txe_o(txe_w),
.wr_i(wr_r)
);


assign data_r = (!wr_r) ? data_r_in  : 8'bz ;
assign data_r_out = (wr_r) ? data_r  : 8'bz ;

endmodule


