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
clk_i
);

output wire [7:0] data;
output rxf_o;
input rd_i;
input clk_i;



integer file, c, r;
reg [3:0] bin;
reg [31:0] dec, hex;
real real_time;
reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */


reg [7:0] fifo_data_in;
wire [7:0] fifo_data_out;
reg wrreq;
reg rdreq;
reg rdclk;
reg wrclk;
reg aclr;
wire rdempty;
wire wrempty;
wire wrfull;
wire rdfull;



// Asynchronous "aFifo" to allow data transmission between two clock domains
aFifo #(.DATA_WIDTH(8), .ADDRESS_WIDTH(4)) ufifo 
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
    $dumpvars;
    aclr = 0;#5;
    wrreq = 0; 
    wrclk = 0;
    rdclk = 0;
    rdreq = 0;
    fifo_data_in = 0;
    aclr = 1; #16;
    aclr = 0; #8;

    $timeformat(-9, 3, "ns", 6);
    $display("time bin decimal hex");
    file = $fopenr("fromPc.tv");
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
    #128;$finish;
    
    end // initial

always begin
        rdclk = !rdclk; #16;
end

always @ (negedge rdclk) begin
           
            if(!rdempty ) begin
                rdreq = #1 1;
            end else rdreq = #1 0;
end



// Display changes to the signals
always @(*)
    $display("HEX: %t %h", $realtime, hex);

always @(*)
    $display("FIFO OUT: %d", fifo_data_out);

assign data = fifo_data_out;
assign rxf_o = rdreq;

endmodule // read_pattern


