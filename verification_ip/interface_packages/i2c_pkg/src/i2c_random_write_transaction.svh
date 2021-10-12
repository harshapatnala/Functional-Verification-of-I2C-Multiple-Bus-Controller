class i2c_random_write_transaction extends i2c_transaction;
	`ncsu_register_object(i2c_random_write_transaction)

rand int write_transfers;

function new(string name="");
	super.new(name);
endfunction

constraint num_transfer {
	write_transfers >0 && write_transfers <=200;
	}
	
	
endclass
