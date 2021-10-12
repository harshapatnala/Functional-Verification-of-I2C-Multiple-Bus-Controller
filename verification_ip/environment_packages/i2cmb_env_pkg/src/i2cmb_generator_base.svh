class i2cmb_generator_base extends ncsu_component;
	`ncsu_register_object(i2cmb_generator_base)

 wb_transaction wishbone_transaction;
 i2c_transaction I2C_transaction;

 wb_agent WB_agent;
 i2c_agent I2C_agent;

 function new(string name="", ncsu_component_base parent = null);
	super.new(name, parent);
 endfunction

virtual function void set_agent(wb_agent WB_agent, i2c_agent I2C_agent);
	this.WB_agent = WB_agent;
	this.I2C_agent = I2C_agent;
 endfunction

 virtual task run();
	$display("GENERATOR BASE RUN TASK");
	
	$cast(wishbone_transaction, ncsu_object_factory::create("wb_transaction"));
	$cast(I2C_transaction, ncsu_object_factory::create("i2c_transaction"));
	$display("______I2CMB DUT TEST______");
	I2C_transaction.set_num_transfers(1,1);
	fork I2C_agent.bl_put(I2C_transaction); join_none
	

	wishbone_transaction.WB_ADDR=CSR; wishbone_transaction.WB_DATA=ENABLE; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put_ref(wishbone_transaction);
	
	wishbone_transaction.WB_ADDR=DPR; wishbone_transaction.WB_DATA=8'h00; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.WB_ADDR=CMDR; wishbone_transaction.WB_DATA=SET_BUS; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.R_W=READ;
	WB_agent.bl_put_ref(wishbone_transaction);
	
	wishbone_transaction.WB_ADDR=CMDR; wishbone_transaction.WB_DATA=START; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.R_W=READ;
	WB_agent.bl_put(wishbone_transaction);

	wishbone_transaction.WB_ADDR=DPR; wishbone_transaction.WB_DATA=8'hfe; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.WB_ADDR=CMDR; wishbone_transaction.WB_DATA=WRITE_CMD; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.R_W=READ;
	WB_agent.bl_put(wishbone_transaction);

	wishbone_transaction.WB_ADDR=DPR; wishbone_transaction.WB_DATA=200; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.WB_ADDR=CMDR; wishbone_transaction.WB_DATA=WRITE_CMD; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.R_W=READ;
	WB_agent.bl_put(wishbone_transaction);
	
	wishbone_transaction.WB_ADDR=CMDR; wishbone_transaction.WB_DATA=STOP; wishbone_transaction.R_W=WRITE;
	WB_agent.bl_put(wishbone_transaction);
	wishbone_transaction.R_W=READ;
	WB_agent.bl_put(wishbone_transaction);

	$display("I2CMB BASE TEST SUCCESFUL");
	$display("Generator base class. Run other generators for various tests using Make regress");

	

 endtask
 
 endclass