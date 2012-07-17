`timescale 1ns/1ps

`define LO      0
`define HI      1
`define NULL    0


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
output wire [15:0] db_o;
reg [15:0] db_r;
input convstw_i;
input cs_i;
input rd_i;
output reg busy_o;
output wire frstdata_o;
reg frstdata_r;

input reset_i;
input wire [2:0] os_i;

integer outfile;

reg [31:0] conv_counter = 0;
reg [31:0] reset_counter = 0;
reg  [3:0] chancount;

initial begin
        outfile = $fopenw("adcval.out");
        if (outfile == `NULL) begin
                $display("Could Not open file");
                $finish;
        end
        chancount = 0;
end


always @ (posedge reset_i, posedge convstw_i) begin
        if(reset_i == 1 ) begin
                busy_o= 0;
                frstdata_r = 0;
                db_r = #45 16'bz;
        end else if(convstw_i == 1) begin
                #45 busy_o = 1;

                if (os_i == 3'b000)
                  #4000; //200kHz NO OS
                else if(os_i == 3'b001)
                  #9100; //100kHz x2 OS
                else if(os_i == 3'b010)
                  #18800; //50kHz x4 OS
                else if(os_i == 3'b011)
                  #39000; //25kHz x8 OS
                else if(os_i == 3'b100)
                  #78000; //12.5kHz x16 OS
                else if(os_i == 3'b101)
                  #158000; //6.25kHz x32 OS
                else if(os_i == 3'b110)
                  #315000; //3.125kHz x64 OS
                else begin
                  $display("Invalid Oversampling selection");
                  $finish;
                end                  


                busy_o = 0;
                db_r = 0;
        end
end

always @ (negedge rd_i) begin
        
end

always @ (negedge rd_i, negedge cs_i) begin
        if(cs_i == 0) begin
                if (chancount <= 8)
                  db_r = #16 $random;
                $fwrite(outfile, "%04X\n", db_o);
                chancount = chancount  + 1;
                if(chancount > 8) 
                        chancount = 0;

        end
end


always @(chancount) begin  
  if (chancount==1) frstdata_r <= 1;
  else frstdata_r<=0;
end

assign frstdata_o = (cs_i) ? 1'bz : frstdata_r;
assign db_o = (cs_i) ? 16'bz : db_r;

endmodule

