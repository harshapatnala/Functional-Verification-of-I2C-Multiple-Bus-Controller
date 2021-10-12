class i2cmb_coverage extends ncsu_component #(.T(wb_transaction));

 i2cmb_env_configuration configuration;

 bit [WB_ADDR_WIDTH-1:0] reg_addr;
 bit [2:0] reg_data;
 bit [WB_DATA_WIDTH-1:0] data_byte;

 covergroup env_coverage;
 register_addr: coverpoint reg_addr;
//	bins regs[] = {[0:$]};
//	}

 command_check: coverpoint reg_data {
	bins start_command = {4};
	bins stop_command = {5};
	bins write_command = {1};
	bins readAck_command = {2};
	bins readNack_command = {3};
	bins setbus_command = {6};
	bins wait_command = {0};
	}

 data_bytes: coverpoint data_byte iff(reg_addr == DPR) {
	bins low = {[0:50]};
	bins med = {[51:100]};
	bins high = {[101:$]};
	}

 endgroup
 

 function void set_configuration(i2cmb_env_configuration cfg);
	configuration = cfg;
 endfunction

 function new(string name= "", ncsu_component_base parent = null);
	super.new(name, parent);
	env_coverage = new;
 endfunction

 virtual function void nb_put(T trans);
	reg_addr = trans.WB_ADDR;
	if(trans.WB_ADDR == CMDR) begin
		reg_data = trans.WB_DATA[2:0];
 	end
	data_byte = trans.WB_DATA;
	//$display("ENV COVERAGE/ Addr:%p, Data:%p", reg_addr, reg_data);
	env_coverage.sample();
 endfunction

 
endclass