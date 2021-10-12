class i2c_driver extends ncsu_component#(.T(i2c_transaction));

 i2c_configuration configuration;
 virtual i2c_if#(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH)) i2c_bus;
 T trans;
  

 function new(string name="", ncsu_component_base  parent=null); 
    super.new(name, parent);
 endfunction

 function void set_configuration(i2c_configuration cfg);
	configuration = cfg;
 endfunction

 virtual task bl_put(input T trans);
		forever begin
		i2c_bus.wait_for_i2c_transfer(trans.OP, trans.I2C_WRITE_DATA);
		if(trans.OP==READ) begin
			i2c_bus.provide_read_data(trans.I2C_DATA, trans.transfer_bit);
			if(trans.transfer_bit==0) $display("I2C Read Transfer Failed");
		end
	end
 endtask


endclass
  
