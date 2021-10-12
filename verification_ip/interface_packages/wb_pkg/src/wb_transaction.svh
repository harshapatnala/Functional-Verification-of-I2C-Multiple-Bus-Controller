class wb_transaction extends ncsu_transaction;
	`ncsu_register_object(wb_transaction)
	
bit[WB_ADDR_WIDTH-1:0] WB_ADDR;
bit[WB_DATA_WIDTH-1:0] WB_DATA, temp_data;
bit[WB_DATA_WIDTH-1:0] WB_READ_DATA;
bit rw_bit;
i2c_op_t R_W;



function new(string name="");
	super.new(name);
endfunction

 virtual function string convert2string();
     return {super.convert2string(),$sformatf("Wishbone Addr:0x%x Wishbone Data:0x%x", WB_ADDR, WB_DATA)};
 endfunction

 function bit compare (wb_transaction wbtran);
	return ((this.WB_ADDR==wbtran.WB_ADDR) && (this.WB_DATA==wbtran.WB_DATA));
 endfunction


endclass

