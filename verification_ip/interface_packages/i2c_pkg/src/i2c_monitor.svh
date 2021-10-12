class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

 i2c_configuration configuration;
 virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH)) i2c_bus;
 T i2c_monitor_trans;
 ncsu_component #(T) agent;

 function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
 endfunction

 function void set_configuration(i2c_configuration cfg);
	configuration = cfg;
 endfunction

 function void set_agent(ncsu_component#(T) agent);
	this.agent = agent;
 endfunction

 virtual task run();
	forever begin
		i2c_monitor_trans = new("i2c_monitor_trans");
		i2c_bus.monitor(i2c_monitor_trans.I2C_ADDR, i2c_monitor_trans.OP, i2c_monitor_trans.I2C_DATA_OUT);
		agent.nb_put(i2c_monitor_trans);
	end
 endtask

endclass