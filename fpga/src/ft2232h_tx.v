`timescale 1ns/1ps

`define LO     0
`define HI     1

module ft2232h_tx(
input wire [7:0] data,
input wire wr_i,
input wire txe_i,
input wire clkout_i
);

integer outfile;

reg [32:0] count;

// Setup TX Process
initial begin
        $timeformat(-9, 2, "ns", 6);
        outfile = $fopen("toPc.tv", "w");
		  count = 0 ;
end

// TX Process
always @ (posedge clkout_i) begin
        if ((txe_i == `LO) && (wr_i == `LO)) begin
					count = count + 1;
                $fwrite(outfile,"%x\n", data);
                $display("%d: TX to PC:\t %t \t%H",count,$realtime, data); 
        end
end

endmodule
