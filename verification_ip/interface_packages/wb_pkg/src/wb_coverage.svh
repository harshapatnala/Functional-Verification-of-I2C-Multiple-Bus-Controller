class wb_coverage extends ncsu_component #(.T(wb_transaction));

 wb_configuration configuration;
 bit[WB_ADDR_WIDTH-1:0] addr;
 bit[WB_DATA_WIDTH-1:0] data;


 covergroup wb_cg;
 wishbone_addr: coverpoint addr;
 wishbone_data: coverpoint data;
 endgroup

 function new(string name = "", ncsu_component#(T) parent = null);
	super.new(name, parent);
	wb_cg = new;
 endfunction

 function void set_configuration(wb_configuration cfg);
	configuration = cfg;
 endfunction

 
 function void nb_put(T trans);
	addr = trans.WB_ADDR;
	data = trans.WB_DATA;
	//$display("WB Coverage: %p, %p", addr, data);
	wb_cg.sample();
 endfunction
endclass