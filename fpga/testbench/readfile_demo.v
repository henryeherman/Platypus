`timescale 1ns / 10 ps
`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000

module read_pattern;
integer file, c, r;
reg [3:0] bin;
reg [31:0] dec, hex;
real real_time;
reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */

initial
    begin : file_block
    $timeformat(-9, 3, "ns", 6);
    $display("time bin decimal hex");
    file = $fopenr("read_pattern.pat");
    if (file == `NULL) // If error opening file
        disable file_block; // Just quit

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
                else
                    #(real_time - $realtime)
                        r = $fscanf(file," %b %d %h\n",bin,dec,hex);
                end // if c else
            c = $fgetc(file);
        end // while not EOF

    $fclose(file);
    end // initial


// Display changes to the signals
always @(bin or dec or hex)
    $display("%t %b %d %h", $realtime, bin, dec, hex);

endmodule // read_pattern
