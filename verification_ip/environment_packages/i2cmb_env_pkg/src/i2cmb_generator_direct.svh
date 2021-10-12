class i2cmb_generator_direct extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_direct)

 wb_transaction WB_trans, wb_write_trans[96];
 i2c_transaction i2c_trans;
 bit[6:0] rand_addr;


 
 function new(string name="", ncsu_component_base parent=null);
	super.new(name,parent);
 endfunction

 virtual task run();
	//WB_trans = new("WB_trans");
	$cast(WB_trans, ncsu_object_factory::create("wb_transaction"));
	$cast(i2c_trans, ncsu_object_factory::create("i2c_transaction"));
	//i2c_trans = new("i2c_trans");
	i2c_trans.set_num_transfers(96, 96);
	for(int i=0; i<96; i++) begin
		if(i<32) i2c_trans.I2C_DATA[i] = 100+i;
		else i2c_trans.I2C_DATA[i] = 95-i;
	 	end
	
	foreach(wb_write_trans[i]) begin
		if(i<32) begin
			//wb_write_trans[i] = new();
			$cast(wb_write_trans[i], ncsu_object_factory::create("wb_transaction"));
			wb_write_trans[i].WB_ADDR=DPR; wb_write_trans[i].WB_DATA = i; wb_write_trans[i].R_W=WRITE; end

		else begin
			//wb_write_trans[i] = new();
			$cast(wb_write_trans[i], ncsu_object_factory::create("wb_transaction"));
			wb_write_trans[i].WB_ADDR=DPR; wb_write_trans[i].WB_DATA = 32+i; wb_write_trans[i].R_W=WRITE; end
	end

	fork I2C_agent.bl_put(i2c_trans); join_none
	
	WB_trans.WB_ADDR = CSR; WB_trans.WB_DATA = ENABLE; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Enable Core

	WB_trans.WB_ADDR = DPR; WB_trans.WB_DATA = 8'h00; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Select Bus ID

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=SET_BUS;
	WB_agent.bl_put(WB_trans);				//Set Bus
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Start Command
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	
	rand_addr = $urandom;
	WB_trans.WB_DATA[7:1]= rand_addr[6:0];
	WB_trans.WB_DATA[0]=0;
	
	WB_trans.WB_ADDR=DPR; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Slave Address and RW bit
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Write Command
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);

	for(int i=0; i<32; i++) begin
								//Send 32 Data Bytes from Wishbone
		WB_agent.bl_put(wb_write_trans[i]);
		WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; WB_trans.R_W=WRITE;//Write Command
		WB_agent.bl_put(WB_trans);
		WB_trans.R_W=READ;
		WB_agent.bl_put(WB_trans);
	end
	
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Start Command
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	
	rand_addr = $urandom;
	WB_trans.WB_DATA[7:1]= rand_addr[6:0];
	WB_trans.WB_DATA[0]=1;
	
	WB_trans.WB_ADDR=DPR; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Slave Address and RW bit
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; WB_trans.R_W=WRITE;
	WB_agent.bl_put(WB_trans);				//Write Command
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);

	for(int i=0; i<32; i++) begin				//Send 32 bytes from I2C Slave
		if(i<31) begin
		WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=READ_ACK; WB_trans.R_W=WRITE; //Read with Ack Command
		WB_agent.bl_put(WB_trans);
		WB_trans.R_W=READ;
		WB_agent.bl_put(WB_trans);
		WB_trans.WB_ADDR=DPR; WB_trans.R_W=READ;
		WB_agent.bl_put(WB_trans);
		end
		else begin
		WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=READ_NACK; WB_trans.R_W=WRITE; //Read with Nack Command
		WB_agent.bl_put(WB_trans);
		WB_trans.R_W=READ;
		WB_agent.bl_put(WB_trans);
		WB_trans.WB_ADDR=DPR; WB_trans.R_W=READ;
		WB_agent.bl_put(WB_trans);
		end
	end
	
	//Alternate Transfers
	for(int i=32; i<96; i++) begin
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START; WB_trans.R_W=WRITE;	//Repeated Start Command
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	
	rand_addr = $urandom;
	WB_trans.WB_DATA[7:1]= rand_addr[6:0];
	WB_trans.WB_DATA[0]=0;

	WB_trans.WB_ADDR=DPR; WB_trans.R_W=WRITE;		//Slave Address and R/W bit
	WB_agent.bl_put(WB_trans);
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; WB_trans.R_W=WRITE;	//Write Command
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);

	WB_agent.bl_put(wb_write_trans[i]);			//Send Data Byte
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; WB_trans.R_W=WRITE;	//Write Command
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START; WB_trans.R_W=WRITE;		//Repeated Start Command
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	
	rand_addr = $urandom;
	WB_trans.WB_DATA[7:1]= rand_addr[6:0];
	WB_trans.WB_DATA[0]=1;

	WB_trans.WB_ADDR=DPR; WB_trans.R_W=WRITE;		//Slave Address and R/W bit
	WB_agent.bl_put(WB_trans);
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; WB_trans.R_W=WRITE;	//Write Command
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=READ_NACK; WB_trans.R_W=WRITE;	//Read with NACK COmmand
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	WB_trans.WB_ADDR=DPR; WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	
	end
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=STOP; WB_trans.R_W=WRITE;		//Stop Command
	WB_agent.bl_put(WB_trans);
	WB_trans.R_W=READ;
	WB_agent.bl_put(WB_trans);
	
	
	WB_trans.WB_ADDR=CSR; WB_trans.R_W=READ;
	WB_agent.bl_put_ref(WB_trans);
	//$display("REGISTER ADDR:%h, REGISTER DATA:%b", WB_trans.WB_ADDR, WB_trans.temp_data);
	
	
endtask

	
endclass