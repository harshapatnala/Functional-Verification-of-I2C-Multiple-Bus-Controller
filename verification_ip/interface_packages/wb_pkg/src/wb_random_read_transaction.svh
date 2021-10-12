class wb_random_read_transaction extends wb_transaction;
	`ncsu_register_object(wb_random_read_transaction)
	
rand bit[WB_DATA_WIDTH-1:0] wb_rand_data;

function new(string name="");
	super.new(name);
endfunction

constraint read_transfer_bit {wb_rand_data[0]==1;}


endclass