# From http://mbmn.net/uer/tutorials/verilog-using-icarus/

VERILOGEX = .v # Verilog File Extension

# testbech path passed from command line

TBPATH = testbench
TESTBENCHPATH = $(TBPATH)/$(TESTBENCH)$(VERILOGEX)
SOURCEPATH = src


FT2232TBFILES = $(SOURCEPATH)/ft2232h.v \
		$(SOURCEPATH)/ft2232h_rx.v \
		$(SOURCEPATH)/ft2232h_tx.v \
		$(SOURCEPATH)/aFifo_negedge.v \
		$(SOURCEPATH)/GrayCounter.v \
		$(TBPATH)/ft2232h_tb.v

AD7606TBFILES = $(TBPATH)/ad7606_tb.v \
		$(SOURCEPATH)/ad7606.v
		
DAQPKTBFILES = $(TBPATH)/daqpacketizer_tb.v \
	       $(SOURCEPATH)/daqpacketizer.v \
	       $(SOURCEPATH)/daqFifo.v \
	       $(SOURCEPATH)/daqtriggerctrl.v \
	       $(SOURCEPATH)/aFifo.v \
	       $(SOURCEPATH)/GrayCounter.v \
	       $(SOURCEPATH)/ad7606.v


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

run: testbench_check runnochk
	@echo "Run and check"
	$(VVP_CMD) $(SIMDIR)/$(TESTBENCH) -$(DUMPTYPE) $(VVP_FLAGS)
	mv dump.$(DUMPTYPE) $(SIMDIR)/$(TESTBENCH).$(DUMPTYPE)


view: testbench_check
	$(WAVEFORM_VIEWER)  $(SIMDIR)/$(TESTBENCH).$(DUMPTYPE)


ft2232h_tb:  
	$(VERILOG_CMD) -o $(SIMDIR)/ft2232h_tb $(FT2232TBFILES)
	$(VVP_CMD) $(SIMDIR)/ft2232h_tb -$(DUMPTYPE) $(VVP_FLAGS)
	mv dump.$(DUMPTYPE) $(SIMDIR)/ft2232h_tb.$(DUMPTYPE)
	$(WAVEFORM_VIEWER) $(SIMDIR)/ft2232h_tb.$(DUMPTYPE)

ad7606_tb:
	$(VERILOG_CMD) -o $(SIMDIR)/ad7606_tb $(AD7606TBFILES)
	$(VVP_CMD) $(SIMDIR)/ad7606_tb -$(DUMPTYPE) $(VVP_FLAGS)
	mv dump.$(DUMPTYPE) $(SIMDIR)/ad7606_tb.$(DUMPTYPE)
	$(WAVEFORM_VIEWER) $(SIMDIR)/ad7606_tb.$(DUMPTYPE)

daqpkt_tb_nv:
	$(VERILOG_CMD) -o $(SIMDIR)/daqpacketizer_tb $(DAQPKTBFILES)
	$(VVP_CMD) $(SIMDIR)/daqpacketizer_tb -$(DUMPTYPE) $(VVP_FLAGS)
	mv dump.$(DUMPTYPE) $(SIMDIR)/daqpacketizer_tb.$(DUMPTYPE)

daqpkt_tb: daqpkt_tb_nv
	$(WAVEFORM_VIEWER) $(SIMDIR)/daqpacketizer_tb.$(DUMPTYPE)




clean: testbench_check
	rm $(SIMDIR)/$(TESTBENCH)*


