# From http://mbmn.net/uer/tutorials/verilog-using-icarus/

VERILOGEX = .v # Verilog File Extension

# testbech path passed from command line
TESTBENCHPATH = testbench/$(TESTBENCH)$(VERILOGEX)
SOURCEPATH = src

#iverlog CONFIG
VERILOG_CMD = iverilog
#VERILOG_FLAGS = 

# VVP (iverilog runtime engine)
VVP_CMD = vvp
#VVP_FLAGS = 

#Simulation Vars
SIMDIR = simulation
DUMPTYPE = vcd

#Viewer
WAVEFORM_VIEWER = gtkwave

all: compile run view

file_check:
ifeq ($(strip $(FILES)),)
		@echo "Files not set. Use FILES=value to set it. Multiple files in quote"
		@exit 2
endif

testbench_check:
ifeq ($(strip $(TESTBENCH)),)
		@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
		@exit 2
endif 

check: file_check
	$(VERILOG_CMD) -t null $(FILES)

new:
	echo "Setting up project ${PROJECT}"
	mkdir src testbench simulation

compile: testbench_check
	mkdir -p simulation
	$(VERILOG_CMD) -o $(SIMDIR)/$(TESTBENCH) $(TESTBENCHPATH) $(SOURCEPATH)/*


run: testbench_check
	$(VVP_CMD) $(SIMDIR)/$(TESTBENCH) -$(DUMPTYPE) $(VVP_FLAGS)
	mv dump.$(DUMPTYPE) $(SIMDIR)/$(TESTBENCH).$(DUMPTYPE)


view: testbench_check
	$(WAVEFORM_VIEWER)  $(SIMDIR)/$(TESTBENCH).$(DUMPTYPE)


clean: testbench_check
	rm $(SIMDIR)/$(TESTBENCH)*

