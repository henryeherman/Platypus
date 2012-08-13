`timescale 1ns / 10 ps
`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000
`define HI   1
`define LO   0

module ft2232h_rx(
data,
rxf_o,
rd_i,
oe_i,
clk_i
);

parameter OE_EVENT       = 2'b00;
parameter RDI_EVENT      = 2'b01;
parameter READING        = 2'b10;


output wire [7:0] data;
output wire rxf_o;
input rd_i;
input oe_i;
input clk_i;



integer file, c, r;
reg [3:0] bin;
reg [31:0] dec, hex;
real real_time;
reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */


reg [7:0] fifo_data_in;
wire [7:0] fifo_data_out;
reg wrreq;
wire rdreq;
reg rdreq_r;
wire rdclk;
reg wrclk;
reg aclr;
wire rdempty;
wire wrempty;
wire wrfull;
wire rdfull;



always @(rdclk) begin
        if(rdclk == `LO && oe_i == `LO && rdreq_r==`LO) rdreq_r = `HI;
        else if(rdclk == `LO && rdreq_r == `LO) rdreq_r = `LO;
        else if(rd_i == `LO) rdreq_r = `HI;
        else if(rd_i == `HI || oe_i == `HI) rdreq_r = `LO;
end

// Asynchronous "aFifo" to allow data transmission between two clock domains
aFifo_negedge #(.DATA_WIDTH(8), .ADDRESS_WIDTH(4)) ufifo 
        (.q(fifo_data_out),
         .rdempty(rdempty),
         .rdreq(rdreq),
         .rdclk(rdclk),
         .data(fifo_data_in),
         .wrfull(wrfull),
         .wrreq(wrreq),
         .wrclk(wrclk),
         .clear(aclr)  );


// Initialize and read in data from file to mimic data from USB host
initial
    begin : file_block
    rdreq_r = 0;
    aclr = 0;#5;
    wrreq = 0; 
    wrclk = 0;
    //rdreq = 0;
    fifo_data_in = 0;
    aclr = 1; #16;
    aclr = 0; #8;

    $timeformat(-9, 2, "ns", 6);
    //$display("time bin decimal hex");
    file = $fopenr("testbench/fromPc.tv");
    if (file == `NULL) begin
       $display("Could not open file"); 
       $finish;
    end else $display("Opened File");
    c = $fgetc(file);
    while (c != `EOF)
        begin
        /* Check the first character for comment */
        if (c == "/")
            r = $fgets(line, file);
        else
            begin
            // Push the character back to the file then read the next time
            r = $ungetc(c, file);
            r = $fscanf(file," %f:\n", real_time);

            // Wait until the absolute time in the file, then read stimulus
            if ($realtime > real_time)
                $display("Error - absolute time in file is out of order - %t",
                        real_time);
                else begin
                    
                        r = $fscanf(file," %h\n",hex);
                        fifo_data_in = hex[7:0]; 
                        wrreq = #1 1;
                        wrclk = #1 0;
                        wrclk = 1;#16; 
                        wrclk = #1 0;
                        wrreq = #1 0;

                        #(real_time - $realtime);  //Delay
                end
                end // if c else
            c = $fgetc(file);
        end // while not EOF

    $fclose(file);
    
    end // initial


// Display changes to the signals
always @(*)
    $display("RX from PC:\t %t \t%H", $realtime, hex[7:0]);

assign data = fifo_data_out;
assign rdclk = clk_i;
assign rxf_o = rdempty;
assign rdreq = rdreq_r;

endmodule 

