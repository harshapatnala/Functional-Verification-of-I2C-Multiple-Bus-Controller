class i2cmb_generator_random_write extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_random_write)

wb_transaction wb_trans;
i2c_transaction i2c_trans;

wb_random_write_transaction wb_random;
i2c_random_write_transaction i2c_random;

	
function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
endfunction

virtual task run();
	$display("_______ I2C RANDOM READS TEST ________");
	$cast(wb_trans, ncsu_object_factory::create("wb_transaction"));
	$cast(i2c_random, ncsu_object_factory::create("i2c_random_write_transaction"));
	$cast(wb_random, ncsu_object_factory::create("wb_random_write_transaction"));
	$cast(i2c_trans, ncsu_object_factory::create("i2c_transaction"));
	
	assert(i2c_random.randomize());
	i2c_trans.set_num_transfers(i2c_random.write_transfers, i2c_random.write_transfers);
				
	fork I2C_agent.bl_put(i2c_trans); join_none
	
	wb_trans.WB_ADDR=CSR; wb_trans.WB_DATA=ENABLE; wb_trans.R_W=WRITE; // Enable core
	WB_agent.bl_put(wb_trans);
	
	wb_trans.WB_ADDR=DPR; wb_trans.WB_DATA=8'h00; wb_trans.R_W=WRITE; //issue bus id
	WB_agent.bl_put(wb_trans);
	
	wb_trans.WB_ADDR=CMDR; wb_trans.WB_DATA=SET_BUS; wb_trans.R_W=WRITE; //set bus command
	WB_agent.bl_put(wb_trans);
	wb_trans.R_W=READ;
	WB_agent.bl_put(wb_trans);
	
	for(int i=0; i< i2c_random.write_transfers; i++) begin
	wb_trans.WB_ADDR=CMDR; wb_trans.WB_DATA=START; wb_trans.R_W=WRITE; //issue start
	WB_agent.bl_put(wb_trans);
	wb_trans.R_W=READ;
	WB_agent.bl_put(wb_trans);
	
	assert(wb_random.randomize());
	wb_trans.WB_ADDR=DPR; wb_trans.WB_DATA=wb_random.write_address; wb_trans.R_W=WRITE;	//Slave address
	WB_agent.bl_put(wb_trans);
	
	wb_trans.WB_ADDR=CMDR; wb_trans.WB_DATA=WRITE_CMD; wb_trans.R_W=WRITE;	//Write command
	WB_agent.bl_put(wb_trans);
	wb_trans.R_W=READ;
	WB_agent.bl_put(wb_trans);
	
	wb_trans.WB_ADDR=DPR; wb_trans.WB_DATA=wb_random.write_data; wb_trans.R_W=WRITE; //Data byte to be written
	WB_agent.bl_put(wb_trans);
	
	wb_trans.WB_ADDR=CMDR; wb_trans.WB_DATA=WRITE_CMD; wb_trans.R_W=WRITE;	//Write command
	WB_agent.bl_put(wb_trans);
	wb_trans.R_W=READ;
	WB_agent.bl_put(wb_trans);

		
	end

	wb_trans.WB_ADDR=CMDR; wb_trans.WB_DATA=STOP; wb_trans.R_W=WRITE;	//STOP
	WB_agent.bl_put(wb_trans);
	wb_trans.R_W=READ;
	WB_agent.bl_put(wb_trans);
	
	$display("TOTAL NO. OF WRITES:%p", i2c_random.write_transfers);

endtask

endclass