
# read design
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_top.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_core_top.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_dm.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_tapc_synchronizer.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_clk_ctrl.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_scu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_tapc.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_tapc_shift_reg.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/scr1_dmi.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/primitives/scr1_reset_cells.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_ifu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_idu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_exu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_mprf.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_csr.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_ialu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_lsu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/core/pipeline/scr1_pipe_hdu.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_dmem_router.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_imem_router.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_dp_memory.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_tcm.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_timer.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_dmem_ahb.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_imem_ahb.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_top_axi.sv 
#read_verilog -sv -I../src/includes -DSCR1_DBG_EN ../src/top/scr1_mem_axi.sv

read_verilog -sv -I../src/includes -DSCR1_DBG_EN -DSCR1_MPRF_RAM pyfive.sv


# elaborate design hierarchy
hierarchy -check -top scr1_top_axi

# mapping to internal cell library
techmap; opt

write_verilog map.gv

