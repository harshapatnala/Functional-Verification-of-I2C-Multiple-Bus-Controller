class wb_agent extends ncsu_component #(.T(wb_transaction));

 wb_configuration 	wishbone_config;
 wb_driver 		wishbone_driver;
 wb_monitor 		wishbone_monitor;
 wb_coverage		wishbone_coverage;
 ncsu_component #(T)	subscribers[$];
 virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wishbone_bus;

 function new(string name= "", ncsu_component_base parent=null);
	super.new(name, parent);
	if(!(ncsu_config_db#(virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)))::get("wb_driver.wb_if", this.wishbone_bus))) begin
		$display("Wishbone Agent failed to get Interface Handle"); end
 endfunction

 function void set_configuration(wb_configuration cfg);
	wishbone_config = cfg;
 endfunction

 virtual function void build();
	wishbone_driver = new("wishbone_driver", this);
	wishbone_driver.set_configuration(wishbone_config);
	wishbone_driver.build();
	wishbone_driver.wishbone_bus = this.wishbone_bus;

	wishbone_coverage = new("wishbone_coverage", this);
	wishbone_coverage.set_configuration(wishbone_config);
	wishbone_coverage.build();
	connect_subscriber(wishbone_coverage);

	wishbone_monitor = new("wishbone_monitor", this);
	wishbone_monitor.set_configuration(wishbone_config);
	wishbone_monitor.set_agent(this);
	wishbone_monitor.build();
	wishbone_monitor.wishbone_bus = this.wishbone_bus;
 endfunction

 virtual function void nb_put(T trans);
	foreach(subscribers[i]) subscribers[i].nb_put(trans);
 endfunction

 virtual function void connect_subscriber(ncsu_component#(T) subscriber);
	subscribers.push_back(subscriber);
 endfunction

 virtual task bl_put(T trans);
	wishbone_driver.bl_put(trans);
 endtask

 virtual task run();
	fork wishbone_monitor.run(); join_none
 endtask

 virtual task bl_put_ref(ref T trans); //TASK SPECIFIC TO DIRECTED REGISTER & DUT TESTS
	wishbone_driver.bl_put_ref(trans);
 endtask
	
endclass