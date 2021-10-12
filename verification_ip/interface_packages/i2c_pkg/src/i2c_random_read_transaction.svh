class i2c_random_read_transaction extends i2c_transaction;
	`ncsu_register_object(i2c_random_read_transaction)
	
rand int number_transfers;
rand bit[I2C_DATA_WIDTH-1:0] i2c_random_read_data[];

function new(string name="");
	super.new(name);
endfunction

constraint transfers {
	number_transfers <= 200 && number_transfers >0;
	i2c_random_read_data.size()==number_transfers;
	}

endclass