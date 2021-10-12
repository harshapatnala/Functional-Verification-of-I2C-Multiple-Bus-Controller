class wb_random_write_transaction extends wb_transaction;
	`ncsu_register_object(wb_random_write_transaction)

rand bit[WB_DATA_WIDTH-1:0] write_address;
rand bit [WB_DATA_WIDTH-1:0] write_data;

function new(string name="");
	super.new(name);
endfunction


constraint write_conditions {
	write_address[0]==0;
	}
	
endclass