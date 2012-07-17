// ======================================
// Function daqFifo 16bit -> 8bit
//
//=======================================

`timescale 1ns/1ps
`define WRITE_DATA_WIDTH      16   // Size of data point from DAQ
`define READ_DATA_WIDTH       8    // Size of data point expected by usb fifo
        

module daqFifo
  #(parameter    ADDRESS_WIDTH = 6,
                 FIFO_DEPTH = (1<<ADDRESS_WIDTH))
     //Reading port
    (output wire  [`READ_DATA_WIDTH-1:0]        q, 
     output wire                         rdempty,
     input  wire                         rdreq,
     input wire                          rdclk,        
     //Writing port.	 
     input wire  [`WRITE_DATA_WIDTH-1:0]        data,  
     output wire                          wrfull,
     input wire                          wrreq,
     input wire                          wrclk,
	 
     input wire                          clear);


wire [`WRITE_DATA_WIDTH-1:0] q_temp;
reg rdclk_temp;
reg [2:0] rdclk_count;
reg rdreq_temp;

aFifo #(.DATA_WIDTH(`WRITE_DATA_WIDTH), .ADDRESS_WIDTH(ADDRESS_WIDTH)) ufifo 
        (.q(q_temp),
        .rdempty(rdempty),
        .rdreq(rdreq),
        .rdclk(rdclk_temp),
        .data(data),
        .wrfull(wrfull),
        .wrreq(wrreq),
        .wrclk(wrclk),
        .clear(clear)
        );


parameter READ_FIRST_BYTE = 0'b0;
parameter READ_SECOND_BYTE = 0'b1;

reg read_state;

always @(posedge rdclk, clear) begin
        if (clear) begin
                rdclk_temp <= 0;
                rdclk_count <= 0;
        end else begin
                rdclk_count = rdclk_count + 1;
                if (rdclk_count > 0 && rdclk_temp == 1) begin                        
                        rdclk_temp <= 0;
                        rdclk_count <=0;
                end else if (rdclk > 0 && rdclk_temp == 0) begin
                        rdclk_temp <= 1;
                        rdclk_count <= 1;                        
                end
        end
end

always @(posedge rdclk_temp, clear) begin
        if (clear)
                rdreq_temp = 0;
        else rdreq_temp = rdreq;
end

/*
always @(posedge rdclk, clear) begin
        if (clear) begin
              read_state = READ_FIRST_BYTE;  
        end else if(rdreq) begin
                if (read_state == READ_FIRST_BYTE) begin
                        read_state = READ_SECOND_BYTE;
                end else if (read_state == READ_SECOND_BYTE) begin
                        read_state = READ_FIRST_BYTE;
                end
        end
end
*/
assign q = (rdreq_temp) ? (rdclk_temp ? q_temp[15:8] : q_temp[7:0]) : 8'b0;



endmodule
