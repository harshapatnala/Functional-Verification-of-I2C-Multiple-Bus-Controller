class i2c_coverage extends ncsu_component #(.T(i2c_transaction));

 i2c_configuration	 configuration;
 bit[I2C_ADDR_WIDTH-1:0] slave_addr;
 int num_bytes;
 i2c_op_t operation_type;

 covergroup i2c_cg;
	slave_addr: coverpoint slave_addr {
	bins set_1 = {[0:31]};
	bins set_2 = {[32:63]};
	bins set_3 = {[64:95]};
	bins set_4 = {[96:127]};
	}
	num_transfers: coverpoint num_bytes {
	bins one_transfer = {1};
	bins small_transfers = {[2:10]};
	bins large_transfers= {[11:$]};
	}
	operation_type: coverpoint operation_type {
		bins read_op = {READ};
		bins write_op = {WRITE};
		}
	slave_addr_x_operation: cross slave_addr, operation_type {
		bins adr_op_1 = binsof(slave_addr.set_1) && binsof(operation_type.read_op);
		bins adr_op_2 = binsof(slave_addr.set_1) && binsof(operation_type.write_op);
		bins adr_op_3 = binsof(slave_addr.set_2) && binsof(operation_type.read_op);
		bins adr_op_4 = binsof(slave_addr.set_2) && binsof(operation_type.write_op);
		bins adr_op_5 = binsof(slave_addr.set_3) && binsof(operation_type.read_op);
		bins adr_op_6 = binsof(slave_addr.set_3) && binsof(operation_type.write_op);
		bins adr_op_7 = binsof(slave_addr.set_4) && binsof(operation_type.read_op);
		bins adr_op_8 = binsof(slave_addr.set_4) && binsof(operation_type.write_op);
	}
	slave_addr_x_num_transfers: cross slave_addr, num_transfers {
		bins slave_set_1 = binsof(slave_addr.set_1) && binsof(num_transfers);
		bins slave_set_2 = binsof(slave_addr.set_2) && binsof(num_transfers);
		bins slave_set_3 = binsof(slave_addr.set_3) && binsof(num_transfers);
		bins slave_set_4 = binsof(slave_addr.set_4) && binsof(num_transfers);
	}

 endgroup

 function new(string name = "", ncsu_component#(T) parent = null);
	super.new(name, parent);
	i2c_cg = new;
 
endfunction

 function void set_configuration(i2c_configuration cfg);
	configuration = cfg;
 
endfunction

 virtual function void nb_put(T trans);
	slave_addr = trans.I2C_ADDR;
	num_bytes = trans.I2C_DATA_OUT.size();
	operation_type = trans.OP;
	//$display("I2C Coverage/ Type:%p, Addr:%h, Bytes Transferred:%p", operation_type, slave_addr, num_bytes);
	i2c_cg.sample();

 endfunction
endclass