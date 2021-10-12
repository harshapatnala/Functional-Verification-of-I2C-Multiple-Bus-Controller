export ECE745_PROJECT_HOME ?= $(PWD)/../../..
GEN_TYPE ?= i2cmb_generator_base
TEST_SEED ?= random
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile

CLI_DO_COMMANDS = -do " \
			set NoQuitOnFinish 1; \
			run -all; \
			do save_coverage.do $(GEN_TYPE); \
			quit -f;" 

DEBUG_DO_COMMANDS = -do " \
			set NoQuitOnFinish 1; \
			do wave.do;\
			run -a;"\

#DEBUG_DO_COMMANDS = -do " \
#			set NoQuitOnFinish 1; \
#			do wave.do;"\

clean: 
	rm -rf work *.wlf transcript

comp_I2C_MB:
	vcom -cover bces ../rtl/iicmb_int_pkg.vhd
	vcom -cover bces ../rtl/iicmb_pkg.vhd
	vcom -cover bcesf ../rtl/mbyte.vhd
	vcom -cover bcesf ../rtl/mbit.vhd
	vcom -cover bces ../rtl/bus_state.vhd
	vcom -cover bces ../rtl/filter.vhd
	vcom -cover bces ../rtl/conditioner.vhd
	vcom -cover bces ../rtl/conditioner_mux.vhd
	vcom -cover bces ../rtl/iicmb_m.vhd
	vcom -cover bces ../rtl/regblock.vhd
	vcom -cover bces ../rtl/wishbone.vhd
	vcom -cover bces ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg 
	vlog -cover bcesf ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

run_cli:
	vsim -c -coverage -sv_seed $(TEST_SEED) $(CLI_DO_COMMANDS) +GEN_TYPE=$(GEN_TYPE) optimized_debug_top_tb

run_gui:
	vsim -coverage -sv_seed $(TEST_SEED) $(DEBUG_DO_COMMANDS) +GEN_TYPE=$(GEN_TYPE) optimized_debug_top_tb

merge_coverage:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	vcover merge -stats=none -strip 0 -totals i2cmb_testplan_merged.ucdb ./*.ucdb 

debug: clean compile run_gui 

cli: clean compile run_cli 

regress:
	./regress.sh

view_coverage:
	vsim -viewcov ./i2cmb_testplan_merged.ucdb
