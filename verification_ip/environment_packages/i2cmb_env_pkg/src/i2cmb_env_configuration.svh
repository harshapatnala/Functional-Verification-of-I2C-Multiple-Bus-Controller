class i2cmb_env_configuration extends ncsu_configuration;

 wb_configuration wb_cfg;
 i2c_configuration i2c_cfg;

 function new(string name="");
	super.new(name);
	wb_cfg = new("wb_cfg");
	i2c_cfg = new("i2c_cfg");
 endfunction

endclass