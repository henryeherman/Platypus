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

`timescale 1ns/1ps

module aFifo_negedge
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
     //Reading port
    (output wire  [DATA_WIDTH-1:0]        q, 
     output reg                          rdempty,
     input wire                          rdreq,
     input wire                          rdclk,        
     //Writing port.	 
     input wire  [DATA_WIDTH-1:0]        data,  
     output reg                          wrfull,
     input wire                          wrreq,
     input wire                          wrclk,
	 
     input wire                          clear);

    /////Internal connections & variables//////
    reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];
    wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    wire                                EqualAddresses;
    wire                                NextWriteAddressEn, NextReadAddressEn;
    wire                                Set_Status, Rst_Status;
    reg                                 Status;
    wire                                PresetFull, PresetEmpty;
    reg q_int; 
    //////////////Code///////////////
    //Data ports logic:
    //(Uses a dual-port RAM).
    //'q' logic:
    always @ (posedge rdclk, posedge rdclk)
        if (rdreq & !rdempty)
            q_int <= #5 Mem[pNextWordToRead];

    assign #5 q = Mem[pNextWordToRead];            
    //'data' logic:
    always @ (posedge wrclk)
        if (wrreq & !wrfull)
            Mem[pNextWordToWrite] <= data;

    //Fifo addresses support logic: 
    //'Next Addresses' enable logic:
    assign NextWriteAddressEn = wrreq & ~wrfull;
    assign NextReadAddressEn  = rdreq  & ~rdempty;
           
    //Addreses (Gray counters) logic:
    GrayCounter GrayCounter_pWr
       (.GrayCount_out(pNextWordToWrite),
       
        .Enable_in(NextWriteAddressEn),
        .Clear_in(clear),
        
        .Clk(wrclk)
       );
       
    GrayCounter GrayCounter_pRd
       (.GrayCount_out(pNextWordToRead),
        .Enable_in(NextReadAddressEn),
        .Clear_in(clear),
        .Clk(rdclk)
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
        if (Rst_Status | clear)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
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
    
    always @ (negedge rdclk, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            rdempty <= 1;
        else
            rdempty <= 0;
            
endmodule
