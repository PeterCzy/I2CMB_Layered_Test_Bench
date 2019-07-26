export ECE745_PROJECT_HOME ?= $(PWD)/../../..
export ECE745_COMMON_HOME ?= $(ECE745_PROJECT_HOME)/verification_ip/interface_packages

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_COMMON_HOME)/ncsu_pkg/Makefile

GEN_SEQ_TYPE ?= wb_sequence_random
GEN_TRANS_TYPE ?= wb_transaction_random
TEST_SEED ?= 111

clean: 
	rm -rf work *.wlf transcript *.ucdb

comp_I2C_MB:
	vcom ../rtl/iicmb_int_pkg.vhd
	vcom ../rtl/iicmb_pkg.vhd
	vcom ../rtl/mbyte.vhd
	vcom ../rtl/mbit.vhd
	vcom ../rtl/bus_state.vhd
	vcom ../rtl/filter.vhd
	vcom ../rtl/conditioner.vhd
	vcom ../rtl/conditioner_mux.vhd
	vcom ../rtl/iicmb_m.vhd
	vcom ../rtl/regblock.vhd
	vcom ../rtl/wishbone.vhd
	vcom ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg  
	vlog ../testbench/top.sv
	vlog $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/ncsu_pkg/ncsu_pkg.sv
	vlog $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/src/i2cmb_env_pkg.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb
	
run_gui:
	vsim  -sv_seed $(TEST_SEED) -do "do wave.do;run -a" +GEN_SEQ_TYPE=$(GEN_SEQ_TYPE) +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

debug: clean compile optimize run_gui
