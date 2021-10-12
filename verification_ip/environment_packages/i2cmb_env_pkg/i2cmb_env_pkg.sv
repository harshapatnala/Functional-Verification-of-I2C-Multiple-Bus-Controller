package i2cmb_env_pkg;

	import ncsu_pkg::*;
	import wb_pkg::*;
	import i2c_pkg::*;
	`include "../../ncsu_pkg/ncsu_macros.svh"

	`include "src/i2cmb_env_configuration.svh"
	`include "src/i2cmb_predictor.svh"
	`include "src/i2cmb_scoreboard.svh"
	`include "src/i2cmb_coverage.svh"
	`include "src/i2cmb_environment.svh"
	`include "src/i2cmb_generator.svh"
	`include "src/i2cmb_generator_base.svh"
	`include "src/i2cmb_generator_direct.svh"
	`include "src/i2cmb_generator_reset_test.svh"
	`include "src/i2cmb_generator_register_test.svh"
	`include "src/i2cmb_generator_register_aliasing.svh"
	`include "src/i2cmb_generator_register_access.svh"
	`include "src/i2cmb_generator_dut_test.svh"
	`include "src/i2cmb_generator_random_read.svh"
	`include "src/i2cmb_generator_random_write.svh"
	`include "src/i2cmb_test.svh"

endpackage