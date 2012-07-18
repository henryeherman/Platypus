//==========================================
// Function : Asynchronous FIFO (w/ 2 asynchronous clocks).
// Coder    : Alex Claros F.
// Date     : 15/May/2005.
// Notes    : This implementation is based on the article 
//            'Asynchronous FIFO in Virtex-II FPGAs'
//            writen by Peter Alfke. This TechXclusive 
//            article can be downloaded from the
//            Xilinx website. It has some minor modifications.
//=========================================
// http://www.asic-world.com/examples/verilog/asyn_fifo.html

`timescale 1ns/1ps
`define DATA_RD_WIDTH  8
`define DATA_WR_WIDTH  16

module daqFifo
  #(parameter    ADDRESS_WIDTH = 6,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output wire  [`DATA_RD_WIDTH-1:0]        q, 
     output reg                          rdempty,
     input wire                          rdreq,
     input wire                          rdclk,        
     //Writing port.	 
     input wire  [`DATA_WR_WIDTH-1:0]        data,  
     output reg                          wrfull,
     input wire                          wrreq,
     input wire                          wrclk,
	 
     input wire                          clear);

    /////Internal connections & variables//////
    reg   [`DATA_WR_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    reg rdclk_slow;
    reg rdreq_delay; 
    reg [`DATA_WR_WIDTH-1:0] q_int;
    
    //initial begin
    //    $display("Address width: %d\t Data width: %d\n", ADDRESS_WIDTH, DATA_WIDTH);
    //end

    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'q' logic:
    reg clkcount;

    always @(posedge rdclk)
           rdclk_slow = !rdclk_slow;

    
    always @ (posedge rdclk)
        if (rdreq & !rdempty)
            q_int <= Mem[pNextWordToRead];

    assign q = (rdclk_slow) ? q_int[7:0] : q_int[15:8];
   
    always @ (posedge rdclk_slow) begin
        rdreq_delay = rdreq;
    end


    //'data' logic:
    always @ (posedge wrclk) //, clear)
        if (wrreq & !wrfull)
            Mem[pNextWordToWrite] <= data;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = wrreq & ~wrfull;
    assign NextReadAddressEn  = rdreq  & ~rdempty;
           
    //Addreses (Gray counters) logic:
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(clear),
        .Clk(wrclk)
       );
       
    GrayCounter #(.COUNTER_WIDTH(ADDRESS_WIDTH)) GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(clear),
        .Clk(rdclk_slow)
       );
     

    //'EqualAddresses' logic:
    assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    //'Quadrant selectors' logic:
    assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    //'Status' latch logic:
    always @ (Set_Status, Rst_Status, clear) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | clear) begin
            Status = 0;  //Going 'Empty'.
            rdclk_slow = 0;
        end else if (Set_Status)
            Status = 1;  //Going 'Full'.
            
    //'wrfull' logic for the writing port:
    assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    always @ (posedge wrclk, posedge PresetFull, negedge Status) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            wrfull <= 1;
        else
            wrfull <= 0;
            
    //'rdempty' logic for the reading port:
    assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
    always @ (posedge rdclk_slow, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            rdempty <= 1;
        else begin
            rdempty <= 0;
        end

endmodule
