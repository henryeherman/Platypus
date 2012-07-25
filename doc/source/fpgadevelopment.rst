FPGA Development
================

Introduction
------------
I rarely see projects that document **all** the trials and tribulations of FPGA and digital design developement.  
Before I began I was always looking for tutorial on 'how a digital design project develops'.
How do you structure a project?
How do you write the testbenches?
What is the order the pieces get developed?
I have written a couple of software projects, nothing that took off, but atleast I had a concept of how to get started.
For hardware I was not sure.
I wanted a *build journal* of sorts for an FPGA project.
The closest thing I found was the `Ettus Reasearch USRP <https://github.com/EttusResearch/UHD-Mirror>`_ verilog source code.  
Staring at the USRP verilog source long enough you get a bit of a feel for how it evolved. 
So I plan to do a **really** good job here of documenting not only the project but also the *design process*.
It might be useful to someone someday.
It should be known that I am very new to digital design and hopefully other *noobs* will find this useful.

Additonal Resources
-------------------
The best resource I have is the textbook `Digital Design and Computer Architechture <http://textbooks.elsevier.com/9780123704979>`_ by David Money Harris & Sarah L. Harris.  
I *really* like this book.  
The style of text is very approachable.  
The examples are all done in *BOTH* Verilog and VHDL and therefore you can get a feel for both HDLs.

A close runner up and essential resource once you want to get your designs on to an FPGA is the free `textbook <http://www.xess.com/appnotes/FpgasNowWhatBook.pdf>`_ publised on the `XESS website <http://www.xess.com/index.php>`_.  Dave Vandenbout provides a tutorial of how to get your designs on to his XuLA board and through the process teaches you how to use the Xilinix tools.  If  you want to write a textbook on FPGAs this is how you do it!  One note is that all the code is written in VHDL and I plan to use Verilog.

Verilog vs VHDL
---------------
Let's be clear, I do **not** have enough experience to help you choose a hardware description language (HDL).  
I started working through tutorials in VHDL, but decided that I like the Verilog syntax better and switched. 
My labmate also *recommended* Verilog. These are the only reasons I chose Verilog.  From here on out I will use Verilog.

Choosing a Development Board
----------------------------
This is probably one of the hardest decisions to make.  
There are **ALOT** of development boards on the market.  
Some have periphreals up the wazoo.  
While some are fairly barebone with only enough supporting circuitry to run the FPGA.
Others have advanced FPGAs with MILLIONS of gates. I looked a along time.
Whatever board I choose I would need to be able to layout the FPGA chip later for my own device, so open source schematics were advantageous.
I began developing with microcontrollers on the Arduino, so I also wanted something with a community.  Documentation is a must!
Generally the more users the better the documentation and examples.
In the end I chose two boards, there is very little difference between them as they are both based upon Spartan-3 FPGAs.

XESS XuLA-200
~~~~~~~~~~~~~
The form factor of the `XuLA-200 <http://www.xess.com/prods/prod048.php>`_ is awesome.  
Those familiar with the 2 inch by 1 inch `mbed <http://mbed.org/>`_ will feel right at home. Its breadboard ready!
The other **BIG** advantage was the book `FPGSs!? Now What? <http://www.xess.com/appnotes/FpgasNowWhatBook.pdf>`_ because clearly Dave knows how to right a book on FPGAs.
With 200,000-gates it should not be hard for me to fit my fairly simple Platypus DAQ design onto the chip.  
The other nice selling point was the lack of a need for a programmer.  
A Microchip PIC microcontroller does all the hard work of getting the Xilinix tools generated bitstream from the host over USB to the Xilinix FPGA.
The drag and drop style of the XuLA tools GUI is also very nice (although I eventually moved to the commandline interface for efficiency reasons).

Gadget Factory Papilio One 500k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The `Papilio One <http://www.gadgetfactory.net/papilio/>`_ is another one of those *GeeWiz* cool products I was first introduced to on `Hackaday <http://hackaday.com/>`_.  
The Papilio One is a bigger FPGA with 500,000 logic gates meaning it can hold a much larger designs.
The `Wiki <http://www.gadgetfactory.net/papilio-wiki/>`_ includes examples of running entire SOC(system on a chip) designs on the Papilio.
The most notable SOC design is the AVR8 IP Core that allows you to run Arduino sketches (I Know! Awesome).
Other attractive features about this board are the fact that it looks like a community is *trying* to form.  
Programming this board does not require a programmer, as it uses the FT2232 IC.
I am familiar with the FTDI chip I plan to duplicate this topology in my own Platypus DAQ design for programming the FPGA.


