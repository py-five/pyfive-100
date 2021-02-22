#------------------------------------------------------------------------------
# Makefile for Synthesis
#------------------------------------------------------------------------------

# Paths
export ROOT_DIR := $(shell pwd)
export DESIGN_FILE  := $(ROOT_DIR)/pyfive_axi_crossbar.sv
export SYNTH_LOG    := $(ROOT_DIR)/synth.log
export REPORT_DIR  := $(ROOT_DIR)/reports
export NETLIST_DIR  := $(ROOT_DIR)/netlist
export TMP_DIR  := $(ROOT_DIR)/tmp


# Targets
.PHONY: clean create merge synth

default: clean create merge synth

synth: clean create merge 
	yosys -g -c synth.tcl -l synth.log

create:
	mkdir -p ./tmp/synthesis; 
	mkdir -p ./reports; 
	mkdir -p ./netlist;

merge: 
	################################################ 
	# yosys has issue in propgating the golbal parameter from one file to other file 
	# to fix this issue, we have concatinated all the rtl file into single file before starting synthesis 
	# only memory are exclded from this list 
	# ################################################
	cat ../src/axi_arbitor.v                >  pyfive_axi_crossbar.sv 
	cat ../src/axi_crossbar_addr.v          >> pyfive_axi_crossbar.sv 
	cat ../src/axi_crossbar_rd.v            >> pyfive_axi_crossbar.sv 
	cat ../src/axi_crossbar.v               >> pyfive_axi_crossbar.sv 
	cat ../src/axi_crossbar_wr.v            >> pyfive_axi_crossbar.sv 
	cat ../src/axi_priority_encoder.v       >> pyfive_axi_crossbar.sv 
	cat ../src/axi_register_rd.v            >> pyfive_axi_crossbar.sv 
	cat ../src/axi_register_wr.v            >> pyfive_axi_crossbar.sv 
	cat ../src/pyfive_axi_crossbar.v        >> pyfive_axi_crossbar.sv


clean:
	$(RM) $(DESIGN_FILE)
	$(RM) $(SYNTH_LOG)
	$(RM) -R $(REPORT_DIR)
	$(RM) -R $(NETLIST_DIR)
	$(RM) -R $(TMP_DIR)
