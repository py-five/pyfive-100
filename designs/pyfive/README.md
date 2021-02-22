#. To run Single Test with  verilator in AXI mode
     make run_verilator CFG=MAX BUS=AXI TRACE=0 TARGETS="hello"
#. To run Single Test with  verilator with waveform in AXI mode
     make run_verilator_wf CFG=MAX BUS=AXI TRACE=0 TARGETS="hello"
# vcd waveform dump in
    ./build/verilator_wf_AXI_MAX_imc_IPIC_1_TCM_1_VIRQ_1_TRACE_0/simx.vcd
# to open waveform viewer
    gtkwave
