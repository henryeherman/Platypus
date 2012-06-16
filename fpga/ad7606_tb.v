`timescale 1ns/1ps

`define LO     0
`define HI     1

module ad7606(
db_o,
convstw_i,
cs_i,
rd_i,
busy_o,
frstdata_o,
reset_i,
os_i
);


reg [2:0] rdstate, rdnextstate; 
reg [1:0] convstate, convnextstate;
output [15:0] db_o;
input convstw_i;
input cs_i;
input rd_i;
output busy_o;
output frstdata_o;
input reset_i;
input os_i;

reg [31:0] conv_counter = 0;
reg [31:0] reset_counter = 0;

reg reset_r;
reg convstw_r;

initial begin
        $dumpvars;
        reset_r = LO;
        convstw_r=HI;
        #10 reset_r = HI;
        #10 reset_r = LO;
        
        #10 convstw_r = LO;
        #50 convstw_r = HI;
        convstw_r = LO;
        #20 $finish;
end

always @ (posedge reset_r, posedge convstw_r) begin
        if(reset_i==HI) begin
                busy_o = LO;
        end else if(convstate==LO) begin
                #100 busy_o = HI;
                busy_o = LO;
        end
end

assign reset_r = reset_i;
assign convstw_r = convstw_i;

endmodule

