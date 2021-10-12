class i2cmb_generator extends ncsu_component;


 wb_transaction WB_trans, wb_write_trans[96];
 i2c_transaction i2c_trans;

 wb_agent WB_agent;
 i2c_agent I2C_agent;
 
 function new(string name="", ncsu_component_base parent=null);
	super.new(name,parent);
 endfunction

 function void set_agent(wb_agent WB_agent, i2c_agent I2C_agent);
  this.WB_agent = WB_agent;
  this.I2C_agent = I2C_agent;
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
			wb_write_trans[i].WB_ADDR=DPR; wb_write_trans[i].WB_DATA = i; end

		else begin
			//wb_write_trans[i] = new();
			$cast(wb_write_trans[i], ncsu_object_factory::create("wb_transaction"));
			wb_write_trans[i].WB_ADDR=DPR; wb_write_trans[i].WB_DATA = 32+i; end
	end

	fork I2C_agent.bl_put(i2c_trans); join_none
	
	WB_trans.WB_ADDR = CSR; WB_trans.WB_DATA = ENABLE;
	WB_agent.bl_put(WB_trans);				//Enable Core

	WB_trans.WB_ADDR = DPR; WB_trans.WB_DATA = 8'h00;
	WB_agent.bl_put(WB_trans);				//Select Bus ID

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=SET_BUS;
	WB_agent.bl_put(WB_trans);				//Set Bus

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START;
	WB_agent.bl_put(WB_trans);				//Start Command
	
	
	WB_trans.WB_ADDR=DPR; WB_trans.WB_DATA=8'h44;
	WB_agent.bl_put(WB_trans);				//Slave Address and RW bit
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD;
	WB_agent.bl_put(WB_trans);				//Write Command

	for(int i=0; i<32; i++) begin
								//Send 32 Data Bytes from Wishbone
		WB_agent.bl_put(wb_write_trans[i]);
		WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD; //Write Command
		WB_agent.bl_put(WB_trans);
	end
	
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START;
	WB_agent.bl_put(WB_trans);				//Start Command
	
	
	WB_trans.WB_ADDR=DPR; WB_trans.WB_DATA=8'h45;
	WB_agent.bl_put(WB_trans);				//Slave Address and RW bit
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD;
	WB_agent.bl_put(WB_trans);				//Write Command
	
	for(int i=0; i<32; i++) begin				//Send 32 bytes from I2C Slave
		if(i<31) begin
		WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=READ_ACK; //Read with Ack Command
		WB_agent.bl_put(WB_trans);
		end
		else begin
		WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=READ_NACK; //Read with Nack Command
		WB_agent.bl_put(WB_trans);
		end
	end
	
	//Alternate Transfers
	for(int i=32; i<96; i++) begin
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START;		//Repeated Start Command
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=DPR; WB_trans.WB_DATA=8'h44;		//Slave Address and R/W bit
	WB_agent.bl_put(WB_trans);
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD;	//Write Command
	WB_agent.bl_put(WB_trans);

	WB_agent.bl_put(wb_write_trans[i]);			//Send Data Byte
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD;	//Write Command
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=START;		//Repeated Start Command
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=DPR; WB_trans.WB_DATA=8'h45;		//Slave Address and R/W bit
	WB_agent.bl_put(WB_trans);
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=WRITE_CMD;	//Write Command
	WB_agent.bl_put(WB_trans);

	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=READ_NACK;	//Read with NACK COmmand
	WB_agent.bl_put(WB_trans);
	
	end
	
	WB_trans.WB_ADDR=CMDR; WB_trans.WB_DATA=STOP;		//Stop Command
	WB_agent.bl_put(WB_trans);
	
	
endtask

	
endclass