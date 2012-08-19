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
The drivers and software for the PlatypusDAQ are built upon libusb-1.0 and libftdi1.
I was kind enough to include both of these projects as submodules of the PlatypusDAQ.
To pull down the source code first checkout the PlatypusDAQ project.

.. code-block:: bash
        
        $ git checkout http://git.gauss.nesl.ucla.edu/platypusdaq/platypusdaq.git

This will pull down everything, including the Altium schematics, board layouts, development demonstrations, Verlilog source, etc.

Next you will need to pull down the submodules. 

.. code-block:: bash
        
        $ git submodule init
        $ git submodule update

The source code for libftdi1 and libusb-1.0 will now be in the ``lib`` directory.

Libusb
------
The libusb-1.0 source code is located in the ``lib\libusb``.
Quoting from their homepage,
"libusb is a C library that gives applications easy access to USB devices on many different operating systems."
This means it is perfect for our application allowing us to read and write data to usb devices like the ft2232h
without having to develop any kernel drivers.

Build the libusb and install: 

.. code-block:: bash
        
        $ cd lib\libusb
        $ ./autogen.sh
        $ ./configure
        $ make
        $ sudo make install

Libftdi
-------
The `libftdi <http://www.intra2net.com/en/developer/libftdi/>`_ is a cross platform open source driver 
that allows developers to write software to communicate with the many FTDI chip variants.
The Platypus DAQ uses the `FT2232H <http://www.ftdichip.com/Products/ICs/FT2232H.htm>`_ in 
FT245 synchronous mode to stream data at upto a blistering 60MBytes/s (480MBits/s)!  
This is alot of data!  The libftdi driver lets us focus on the application.

`libusb <http://www.libusb.org/>`_ is required to install libftdi.  

Build and install the libftdi1:

.. code-block:: bash
        
        $ cd lib\libftdi
        $ mkdir build
        $ cd build
        $ cmake ../
        $ make
        $ sudo make install

Installing scons
----------------
I had been using GnuMake for this projects, but a while back had taken notice of the build tool named scons.
I am big python *fanboi* so I thought I would give it ago...

Initial thoughts? Really pleasant.  
I always found makefiles a bit unintutive for everything but the simplest of progjects.
Will I continue to use `scons <http://www.scons.org/>`_? Maybe!

MacOSX
~~~~~~

.. code-block:: bash

        $ brew install scons

Debian and Ubuntu
~~~~~~~~~~~~~~~~~

.. code-block:: bash
        
        $ sudo apt-get install scons


Compiling the Demos
-------------------

.. code-block:: bash
        
        $ scons examples

Compiling the Utilities
-----------------------

.. code-block:: bash
        
        $ scons utils

.. todo:: Compile the Demos

.. todo:: How to install Xilinix Webpack
