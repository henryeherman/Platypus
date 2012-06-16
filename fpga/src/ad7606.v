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
output reg [15:0] db_o;
input convstw_i;
input cs_i;
input rd_i;
output reg busy_o;
output reg frstdata_o;
input reset_i;
input os_i;

reg [31:0] conv_counter = 0;
reg [31:0] reset_counter = 0;


always @ (posedge reset_i, posedge convstw_i) begin
        if(reset_i == 1 ) begin
                busy_o= 0;
                db_o = 16'bz;
        end else if(convstw_i == 1) begin
                #45 busy_o = 1;
                #4000 busy_o = 0;
                db_o = 0;
        end
end

always @ (negedge rd_i) begin
        
end

always @ (negedge rd_i, posedge cs_i) begin
        if(cs_i == 0) begin
                if(db_o < 9) begin
                        db_o <= db_o + 1;
                end
                
                if(db_o == 1) begin
                        frstdata_o <= 1;
                end else if(db_o > 8) begin
                        frstdata_o <= 1'bz;
                end else begin
                        frstdata_o <=0;
                end

        end else begin
                db_o = 16'bz;
        end
        
end





endmodule

