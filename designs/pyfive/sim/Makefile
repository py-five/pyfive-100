# src_dir := $(dir $(lastword $(MAKEFILE_LIST)))
rtl_src_dir := $(root_dir)/src/
rtl_tb_dir := $(root_dir)/tb/
rtl_core_files ?= rtl_files.f
rtl_tb_files ?= tb_files.f
rtl_inc_dir ?= $(root_dir)/src/syntacore/scr1/src/includes
rtl_inc_tb_dir ?= $(root_dir)/tb/cpp
top_module ?= pyfive_tb_top

rtl_core_list := $(addprefix $(rtl_src_dir),$(shell cat $(rtl_src_dir)$(rtl_core_files)))
rtl_tb_list := $(addprefix $(rtl_tb_dir),$(shell cat $(rtl_tb_dir)$(rtl_tb_files)))
sv_list := $(rtl_tb_list) $(rtl_core_list)

ifeq ($(MAKECMDGOALS), $(filter $(MAKECMDGOALS),build_verilator build_verilator_wf))
export verilator_wrapper  := $(root_dir)/tb/verilator_wrap/pyfive_tb_wapper.cpp
export verilator_ver ?= $(shell  expr `verilator --version | cut -f2 -d' '`)
endif

.PHONY: build_modelsim build_vcs build_ncsim build_verilator build_verilator_wf

default: build_modelsim

build_modelsim: $(sv_list)
	cd $(bld_dir); \
	vlib work; \
	vmap work work; \
	vlog -work work -O1 -mfcu -sv \
	+incdir+$(rtl_inc_dir) \
	+incdir+$(rtl_inc_tb_dir) \
	+nowarnSVCHK  \
	+define+SCR1_TRGT_SIMULATION \
	+define+$(SIM_TRACE_DEF) \
	+define+$(SIM_CFG_DEF) \
	$(SIM_BUILD_OPTS) \
	$(sv_list)

build_vcs: $(sv_list)
	cd $(bld_dir); \
	vcs \
	-full64 \
	-lca \
	-sverilog \
	-notice \
	+lint=all,noVCDE \
	-timescale=1ns/1ps \
	+incdir+$(rtl_inc_dir) \
	+incdir+$(rtl_inc_tb_dir) \
	+define+SCR1_TRGT_SIMULATION \
	+define+$(SIM_TRACE_DEF) \
	+define+$(SIM_CFG_DEF) \
	-nc \
	-debug_all \
	$(SIM_BUILD_OPTS) \
	$(sv_list)

build_ncsim: $(sv_list)
	cd $(bld_dir); \
	irun \
	-elaborate \
	-64bit \
	-disable_sem2009 \
	-verbose \
	-timescale 1ns/1ps \
	-incdir $(rtl_inc_dir) \
	-incdir $(rtl_inc_tb_dir) \
	-debug \
	+define+SCR1_TRGT_SIMULATION \
	+define+$(SIM_TRACE_DEF) \
	+define+$(SIM_CFG_DEF) \
	$(SIM_BUILD_OPTS) \
	$(sv_list) \
	-top $(top_module)

build_verilator: $(sv_list)
	cd $(bld_dir); \
	verilator \
	-cc \
	-sv \
	+1800-2017ext+sv \
	-Wno-fatal \
	--top-module $(top_module) \
	-DSCR1_TRGT_SIMULATION \
	-D$(SIM_TRACE_DEF) \
	-D$(SIM_CFG_DEF) \
	-CFLAGS -I$(rtl_inc_tb_dir) \
	--debug  \
	--debug-check \
	--no-debug-leak \
	--clk clk \
	--exe $(verilator_wrapper) \
	--Mdir $(bld_dir)/verilator \
	-I$(rtl_inc_dir) \
	-I$(rtl_inc_tb_dir) \
	$(SIM_BUILD_OPTS) \
	$(sv_list); \
	cd verilator; \
	$(MAKE) -f V$(top_module).mk;

build_verilator_wf: $(sv_list)
	cd $(bld_dir); \
	verilator \
	-cc \
	-sv \
	+1800-2017ext+sv \
	-Wno-fatal \
	--top-module $(top_module) \
	-DSCR1_TRGT_SIMULATION \
	-D$(SIM_TRACE_DEF) \
	-D$(SIM_CFG_DEF) \
	--debug  \
	--debug-check \
	--no-debug-leak \
	--gdbbt \
	-CFLAGS -DVCD_TRACE -CFLAGS -DTRACE_LVLV=20 \
	-CFLAGS -DVCD_FNAME=simx.vcd \
	-CFLAGS -I$(rtl_inc_tb_dir) \
	--clk clk \
	--exe $(verilator_wrapper) \
	--trace \
	--trace-params \
    --trace-structs \
    --trace-underscore \
	--Mdir $(bld_dir)/verilator \
	-I$(rtl_inc_dir) \
	-I$(rtl_inc_tb_dir) \
	$(SIM_BUILD_OPTS) \
	$(sv_list); \
	cd verilator; \
	$(MAKE) -f V$(top_module).mk;


