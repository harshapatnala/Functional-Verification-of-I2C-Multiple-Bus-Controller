class i2cmb_environment extends ncsu_component;

 i2cmb_env_configuration configuration;
 wb_agent wishbone_agent;
 i2c_agent I2C_AGENT;
 i2cmb_predictor predictor;
 i2cmb_scoreboard scoreboard;
 i2cmb_coverage coverage;


 function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
 endfunction

 
 function void set_configuration(i2cmb_env_configuration cfg);
	configuration = cfg;
 endfunction


 virtual function void build();
	wishbone_agent = new("wishbone_agent", this);
	wishbone_agent.build();
	I2C_AGENT = new("I2C_AGENT", this);
	I2C_AGENT.build();
	coverage = new("coverage", this);
	coverage.set_configuration(configuration);
	coverage.build();
	predictor = new("predictor", this);
	predictor.build();
	scoreboard = new("scoreboard", this);
	scoreboard.build();
	I2C_AGENT.connect_subscriber(scoreboard);
	wishbone_agent.connect_subscriber(predictor);
	wishbone_agent.connect_subscriber(coverage);
	predictor.set_scoreboard(scoreboard);
	
 endfunction

 function wb_agent get_wishbone_agent();
	return wishbone_agent;
 endfunction

 function i2c_agent get_i2c_agent();
	return I2C_AGENT;
 endfunction

 virtual task run();
 	wishbone_agent.run();
	I2C_AGENT.run();
 endtask



endclass