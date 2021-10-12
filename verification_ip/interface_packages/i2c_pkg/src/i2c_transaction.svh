class i2c_transaction extends ncsu_transaction;
	`ncsu_register_object(i2c_transaction)

bit[I2C_ADDR_WIDTH-1:0] I2C_ADDR;
bit[I2C_DATA_WIDTH-1:0] I2C_WRITE_DATA[];
bit[I2C_DATA_WIDTH-1:0] I2C_DATA[];
bit[I2C_DATA_WIDTH-1:0] I2C_DATA_OUT[];
bit transfer_bit;
i2c_op_t OP;
int num_read_transfers;
int num_write_transfers;

 function new(string name="");
	super.new(name);
 endfunction

 virtual function string convert2string();
	return {super.convert2string(), $sformatf("I2C_Data:%h", I2C_WRITE_DATA)};
 endfunction

 function bit compare(i2c_transaction i2ctran);
	return ((this.I2C_ADDR==i2ctran.I2C_ADDR) && (this.I2C_DATA_OUT==i2ctran.I2C_DATA_OUT) && (this.OP==i2ctran.OP));
 endfunction

 function void set_num_transfers(int num_read_transfers, int num_write_transfers);
	this.num_read_transfers = num_read_transfers;
	this.num_write_transfers = num_write_transfers;
	I2C_DATA = new[this.num_read_transfers];
	I2C_WRITE_DATA = new[this.num_write_transfers];
 endfunction

endclass