Building & Installing
=====================


Verilog Development Tools Installation
--------------------------------------

`Icarus verilog <http://iverilog.icarus.com/>`_ is an open source verilog simulator.  
When developing *hardware* using verilog, for example on an FPGA, simulation is essential.  
Many of the *free* tools distributed by FPGA manufacturers come with their own simulation environments.
I chose not to use them for this project to as not to alienate users who wish to do most of their coding on unsupported operatiing systems, I am looking at you Mac OSX.
Fortunately, Icarus Verilog gan be happily compiled for any of the major OSes and more important is supported by most of the major package managers.  
I will briefly discuss how to install them on a couple systems.  If I don't mention your favorite flavor, don't worry as I am failry confident you can figure out how to get it installed.


Ubuntu and Debian
~~~~~~~~~~~~~~~~~

Oh *apt-get* how easy you make our lives!  To install a simple verilog development environment run the following from your favorite terminal
::
        $ sudo apt-get install iverilog gtkwave

`GtkWave <http://gtkwave.sourceforge.net/>`_ is a nice program for viewing the output of the simulator.

Mac OSX
~~~~~~~
So you really want to develop on a Mac huh? Are you sure? 
Ok fine, fortunately their are a couple of fairly simple ways of getting both Icarus Verilog and gtkwave installed on a Mac.
First install a package manager.  Unlike the other *\*NIXs* out there MacOSX which is based upon the BSD kernel does not ship with a package manager.
Lucky for you there are a couple choices, and all of them are not that bad.  For some reason though they compile pretty much everything!
I personally recommend `Homebrew <http://mxcl.github.com/homebrew/>`_ it is my package manager of choice.  Should you want to *drink* give `MacPorts <http://www.macports.org/>`_ a chance.
Once you have installed run the following commands.

For Homebrew
^^^^^^^^^^^^

.. code-block:: bash

        $ brew install iverilog gtkwave

For Macports
^^^^^^^^^^^^

.. code-block:: bash

        $ sudo port install iverilog gtkwave

If you any difficulties then, I leave the solution up to you, try `here <http://lmgtfy.com/?q=installing+iverilog+on+mac+osx>`_.       


Software
--------

Libftdi
-------
The `libftdi <http://www.intra2net.com/en/developer/libftdi/>`_ is a cross platform open source driver that allows developers to write software to communicate with the many FTDI chip variants.
The Platypus DAQ uses the `FT2232H <http://www.ftdichip.com/Products/ICs/FT2232H.htm>`_ in FT245 synchronous mode to stream data at upto a blistering 60MB/s!  This is alot of data!  The libftdi driver lets us focus on the application.

Ubuntu and Debian
~~~~~~~~~~~~~~~~~
Install on Ubuntu and Debian is simple thanks to ``apt-get``. Run the following command from the terminal:
::
        $ sudo apt-get install libusb-dev libftdi-dev

Mac OSX
~~~~~~~

Assuming you are using `Homebrew <http://mxcl.github.com/homebrew/>`_:
::
        $ brew install libusb libftdi 


.. todo:: Compile the Demos

.. todo:: How to install Xilinix Webpack

