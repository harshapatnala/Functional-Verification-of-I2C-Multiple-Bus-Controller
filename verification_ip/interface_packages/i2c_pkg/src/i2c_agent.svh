class i2c_agent extends ncsu_component#(.T(i2c_transaction));

 i2c_configuration			i2c_config;
 i2c_driver				I2C_driver;
 i2c_monitor				I2C_monitor;
 i2c_coverage				I2C_coverage;
 ncsu_component #(T) 			subscribers[$];
 
virtual i2c_if #(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH))	i2c_bus;

 function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
	if(!(ncsu_config_db#(virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH)))::get("I2C_INTERFACE", i2c_bus))) begin
		$display("Failed to get Handle to I2C interface"); end
 endfunction

 function void set_configuration(i2c_configuration cfg);
	i2c_config = cfg;
 endfunction

 virtual function void build();
	I2C_driver = new("I2C_driver", this);
	I2C_driver.set_configuration(i2c_config);
	I2C_driver.build();
	I2C_driver.i2c_bus = this.i2c_bus;

	I2C_coverage = new("I2C_coverage", this);
	I2C_coverage.set_configuration(i2c_config);
	I2C_coverage.build();
	connect_subscriber(I2C_coverage);

	I2C_monitor = new("I2C_monitor", this);
	I2C_monitor.set_configuration(i2c_config);
	I2C_monitor.build();
	I2C_monitor.set_agent(this);
	I2C_monitor.i2c_bus = this.i2c_bus;

endfunction

 virtual function void nb_put(T trans);
	foreach(subscribers[i]) subscribers[i].nb_put(trans);
 endfunction

virtual function void connect_subscriber(ncsu_component#(T) subscriber);
	subscribers.push_back(subscriber);
 endfunction

 virtual task bl_put(T trans);
	I2C_driver.bl_put(trans);
 endtask

 virtual task bl_get(output T trans);
	I2C_driver.bl_get(trans);
 endtask

 virtual task run();
	fork I2C_monitor.run(); join_none
 endtask
	

endclass