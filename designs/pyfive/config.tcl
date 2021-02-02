# User config
set ::env(DESIGN_NAME) pyfive

# Change if needed
set ::env(VERILOG_FILES) [glob  \
            $::env(DESIGN_DIR)/src/core/scr1_core_top.sv \
            $::env(DESIGN_DIR)/src/core/scr1_dm.sv \
            $::env(DESIGN_DIR)/src/core/scr1_tapc_synchronizer.sv \
            $::env(DESIGN_DIR)/src/core/scr1_clk_ctrl.sv \
            $::env(DESIGN_DIR)/src/core/scr1_scu.sv \
            $::env(DESIGN_DIR)/src/core/scr1_tapc.sv \
            $::env(DESIGN_DIR)/src/core/scr1_tapc_shift_reg.sv \
            $::env(DESIGN_DIR)/src/core/scr1_dmi.sv \
            $::env(DESIGN_DIR)/src/core/primitives/scr1_reset_cells.sv \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_top.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_ifu.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_idu.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_exu.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_mprf.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_csr.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_ialu.sv  \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_lsu.sv \
            $::env(DESIGN_DIR)/src/core/pipeline/scr1_pipe_hdu.sv \
            $::env(DESIGN_DIR)/src/top/scr1_dmem_router.sv \
            $::env(DESIGN_DIR)/src/top/scr1_imem_router.sv \
            $::env(DESIGN_DIR)/src/top/scr1_dp_memory.sv \
            $::env(DESIGN_DIR)/src/top/scr1_tcm.sv \
            $::env(DESIGN_DIR)/src/top/scr1_timer.sv \
            $::env(DESIGN_DIR)/src/top/scr1_dmem_ahb.sv \
            $::env(DESIGN_DIR)/src/top/scr1_imem_ahb.sv \
            $::env(DESIGN_DIR)/src/top/scr1_mem_axi.sv \
            $::env(DESIGN_DIR)/src/top/scr1_top_axi.sv  ]


set ::env(VERILOG_INCLUDE_DIRS) [glob $::env(DESIGN_DIR)/src/includes]

# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

