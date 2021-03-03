#------------------------------------------------------------------------------
# Makefile for Synthesis
#------------------------------------------------------------------------------

# Paths
export ROOT_DIR := $(shell pwd)
export SYNTH_LOG    := $(ROOT_DIR)/synth.log
export REPORT_DIR  := $(ROOT_DIR)/reports
export NETLIST_DIR  := $(ROOT_DIR)/netlist
export TMP_DIR  := $(ROOT_DIR)/tmp

## Design Synth Directory
export CBAR_SYNDIR    := $(ROOT_DIR)/../src/axi_crossbar/synth
export SCR1_SYNDIR    := $(ROOT_DIR)/../src/syntacore/scr1/synth/
export SMASTER_SYNDIR := $(ROOT_DIR)/../src/axi_spi_master/synth

# Targets
.PHONY: clean create build synth

default: clean create build synth

synth: clean create build  
	yosys -g -c synth.tcl -l synth.log

create:
	mkdir -p ./tmp/synthesis; 
	mkdir -p ./reports; 
	mkdir -p ./netlist;

build: 
	$(MAKE) -C $(CBAR_SYNDIR) 
	$(MAKE) -C $(SCR1_SYNDIR) 
	$(MAKE) -C $(SMASTER_SYNDIR) 


clean:
	$(RM) $(SYNTH_LOG)
	$(RM) -R $(REPORT_DIR)
	$(RM) -R $(NETLIST_DIR)
	$(RM) -R $(TMP_DIR)
	$(MAKE) -C $(CBAR_SYNDIR) clean
	$(MAKE) -C $(SCR1_SYNDIR) clean
	$(MAKE) -C $(SMASTER_SYNDIR) clean
