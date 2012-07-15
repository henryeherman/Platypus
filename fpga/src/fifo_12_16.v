

module fifo_12_16(
input   [15:0]  data,
input           wrreq,
input           wrclk,
output          wrfull,
output          wrempty,
output  [3:0]   wrusedw,

output  [15:0]  q,
input           rdreq,
input           rdclk,
output          rdfull,
output          rdempty,
output  [3:0]   rdusedw,

input           aclr );

fifo #(.width(16), .depth(12), .addr_bits(4)) fifo_12
        (data, wrreq, rdreq, rdclk, wrclk, aclr, q,
         rdfull, rdempty, rdusedw, wrfull, wrempty, wrusedw);

 endmodule

