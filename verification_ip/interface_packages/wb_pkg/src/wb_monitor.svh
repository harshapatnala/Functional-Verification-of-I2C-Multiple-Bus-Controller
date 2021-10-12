class wb_monitor extends ncsu_component#(.T(wb_transaction));

 wb_configuration configuration;
 virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wishbone_bus;
 T monitor_trans;
 ncsu_component #(T) agent;

 function new(string name ="", ncsu_component_base parent=null);
	super.new(name, parent);
 endfunction

 function void set_configuration(wb_configuration cfg);
	configuration = cfg;
 endfunction
 
 function void set_agent(ncsu_component#(T) agent);
	this.agent = agent;
 endfunction

 virtual task run();
	wishbone_bus.wait_for_reset();
	forever begin
		monitor_trans = new("monitor_trans");
		wishbone_bus.master_monitor(monitor_trans.WB_ADDR, monitor_trans.WB_DATA, monitor_trans.rw_bit);
		agent.nb_put(monitor_trans);
	end
 endtask

endclass