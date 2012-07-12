`timescale 1ns/1ps


module ft2232h_tb;
wire clkout_w;
reg oe_r;
reg rd_r;

wire [7:0] data_r;
wire [7:0] data_r_out;
reg [7:0] data_r_in;

wire rxf_w;

wire txe_w;
reg wr_r;
reg [31:0] ii;

reg [7:0]  dataToFifo [7:0];

parameter EMPTY         = 2'b00;
parameter PREPAREREAD   = 2'b01;
parameter READ          = 2'b10;
parameter PAUSE         = 2'b11;

reg[1:0] rdstate, rdnextstate;
reg rdreset;

initial begin
        $dumpvars;
        rdreset = 0;
        ii = 0;
        data_r_in = 0;
        wr_r = 1;
        oe_r = 1;        
        rd_r = 1;
        rdstate = PAUSE; 
        #300;
        rdreset = 1;
        #1;
        rdreset = 0;
       
        //$readmemh("testbench/toFifo.tv", dataToFifo);
        #2000;
        $finish;
end

/*
always @(negedge clkout_w) begin
        if ((txe_w == 0 && rxf_w==1) && (ii < 8)) begin
                wr_r = 0;
                data_r_in<= dataToFifo[ii];
                ii = ii + 1;
        end else begin
                wr_r = 1;
        end
end
*/

always @(negedge clkout_w, posedge rdreset) begin
        if(rdreset) begin
                $display("Reset RD");
                rdstate <= EMPTY;
                rdnextstate <=EMPTY;
                        
        end else begin 
                rdstate <= rdnextstate;
        end
end

always @(rxf_w, rdstate) begin
        //$display("RXF %d", rxf_w);        
        case (rdstate)
                EMPTY: begin
                        oe_r<=1; rd_r<=1;
                        if(rxf_w == 0) begin
                                //oe_r<= 0;
                                //$display("Go PREPARE READ");
                                rdnextstate = PREPAREREAD;
                        end //else $display("Empty");
                end                
                PREPAREREAD: begin
                        //rd_r = 0;
                        oe_r<=0; rd_r<=1;
                        //$display("Prepare to Read");      
                        if(rxf_w == 0) begin 
                                //$display("Go READ");
                                rdnextstate = READ;
                        end else  begin
                        //$display("GO EMPTY");
                                rdnextstate = EMPTY;
                        end

                end
                READ: begin
                        oe_r<=0; rd_r<=0;
                        if(rxf_w == 1) begin
                                //$display("Go EMPTY");
                                rdnextstate = EMPTY;
                        end //else $display("Reading");

                end                       
                default: begin
                   rd_r<=1; oe_r<=1;
                end
        endcase
end

ft2232h uft2232h(
.data(data_r),
.rxf_o(rxf_w),
.clkout_o(clkout_w),
.oe_i(oe_r),
.txe_o(txe_w),
.rd_i(rd_r),
.wr_i(wr_r)
);


assign data_r = (!wr_r) ? data_r_in  : 8'bz ;
assign data_r_out = (wr_r) ? data_r  : 8'bz ;

endmodule


