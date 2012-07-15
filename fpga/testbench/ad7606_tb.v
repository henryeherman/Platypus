`timescale 1ns/1ps


module ad7606_tb;
wire busy_r;
reg reset_r;
reg convstw_r;
wire [15:0] db_r;
reg rd_r;
reg cs_r;
wire frstdata_w;
reg [2:0] os_r;

initial begin
        $dumpvars;
        rd_r = 1;
        cs_r = 1;
        os_r = 3'b000;       
        reset_r = 0; #1;
        convstw_r=1; 
        reset_r = 1; #50;
        reset_r = 0;
        #50;
        convstw_r = 0; #50;
        convstw_r = 1;
        #4500;
        convstw_r = 0; #50;
        convstw_r = 1;
        #4500;
        $finish;

end

always @(negedge busy_r) begin
        if(reset_r != 1) begin
          cs_r=0;
          repeat(8) begin
                rd_r=1; #15;
                rd_r=0; #21;
                rd_r=1;
          end
          cs_r= #10 1;
        end
end



ad7606 uad7606(
.convstw_i(convstw_r),
.reset_i(reset_r),
.busy_o(busy_r),
.rd_i(rd_r),
.cs_i(cs_r),
.db_o(db_r),
.frstdata_o(frstdata_w),
.os_i(os_r)
);


endmodule


