class wb_driver extends ncsu_component#(.T(wb_transaction));
 
  wb_configuration configuration;
  virtual wb_if#(.ADDR_WIDTH(WB_ADDR_WIDTH), .DATA_WIDTH(WB_DATA_WIDTH)) wishbone_bus;
  
  T trans;
 

  function new(string name="", ncsu_component_base  parent=null); 
    super.new(name, parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
	configuration = cfg;
 endfunction

 virtual task bl_put(input T trans);
			
  //$display({get_full_name(), " ", trans.convert2string()});
    if(trans.WB_ADDR==CSR || trans.WB_ADDR==DPR || trans.WB_ADDR==FSM) begin 
	if(trans.R_W==WRITE) wishbone_bus.master_write(trans.WB_ADDR, trans.WB_DATA);
	if(trans.R_W==READ) wishbone_bus.master_read(trans.WB_ADDR, trans.temp_data);
	end
    if(trans.WB_ADDR ==CMDR) begin 
	if(trans.R_W==WRITE) begin
		wishbone_bus.master_write(trans.WB_ADDR, trans.WB_DATA);
		wishbone_bus.wait_for_interrupt(); 
	end
	if(trans.R_W==READ) wishbone_bus.master_read(trans.WB_ADDR, trans.temp_data);
	end
 endtask

 virtual task bl_put_ref(ref T trans); //Task specific to Directed DUT register tests

    if(trans.WB_ADDR==CSR || trans.WB_ADDR==DPR || trans.WB_ADDR==FSM) begin 
	if(trans.R_W==WRITE) wishbone_bus.master_write(trans.WB_ADDR, trans.WB_DATA);
	if(trans.R_W==READ) begin 
		wishbone_bus.master_read(trans.WB_ADDR, trans.temp_data);
		//if(trans.WB_ADDR==DPR) $display("DPR DATA:%h", trans.temp_data);
		end
	end
    if(trans.WB_ADDR ==CMDR) begin 
	if(trans.R_W==WRITE) begin
		wishbone_bus.master_write(trans.WB_ADDR, trans.WB_DATA);
		wishbone_bus.wait_for_interrupt(); 
	end
	if(trans.R_W==READ) wishbone_bus.master_read(trans.WB_ADDR, trans.temp_data);
	end

endtask

endclass