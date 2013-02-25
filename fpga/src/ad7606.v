`timescale 1ns/1ps

`define LO      0
`define HI      1
`define NULL    0


module ad7606(
	output wire [15:0] db_o,	
	input convstw_i,
	input cs_i,
	input rd_i,
	output reg busy_o,
	output wire frstdata_o,
	input reset_i,
	input wire [2:0] os_i
);

reg [2:0] rdstate, rdnextstate; 
reg [1:0] convstate, convnextstate;

reg [15:0] db_r;

reg frstdata_r;

integer outfile;

reg [31:0] conv_counter = 0;
reg [31:0] reset_counter = 0;
reg  [3:0] chancount;

initial begin
  outfile = $fopen("adcval.out","w");
  if (outfile == `NULL) begin
		$display("Could Not open file");
		$finish;
  end
  chancount = 0;
  busy_o=0;
end

reg temp=1;

always@(posedge reset_i or negedge convstw_i) begin
	if(reset_i) begin
		busy_o = 0;
		frstdata_r = 0;
		db_r = 16'bz;
	end else if(!convstw_i) begin
		#140 busy_o = 1;		
		if (os_i == 3'b000)
		#4000 busy_o = 0; //200kHz NO OS
		else if(os_i == 3'b001)
		#9100 busy_o = 0; //100kHz x2 OS
		else if(os_i == 3'b010)
		#18800 busy_o = 0; //50kHz x4 OS
		else if(os_i == 3'b011)
		#39000 busy_o = 0; //25kHz x8 OS
		else if(os_i == 3'b100)
		#78000 busy_o = 0; //12.5kHz x16 OS
		else if(os_i == 3'b101)
		#158000 busy_o = 0; //6.25kHz x32 OS
		else if(os_i == 3'b110)
		#315000 busy_o = 0; //3.125kHz x64 OS
		else begin
		$display("Invalid Oversampling selection");
		$finish;
		end                  		
		db_r = 0;
	end
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

assign frstdata_o = (cs_i) ? 1'b0 : frstdata_r;
assign db_o = (cs_i) ? 16'bz : db_r;

endmodule

