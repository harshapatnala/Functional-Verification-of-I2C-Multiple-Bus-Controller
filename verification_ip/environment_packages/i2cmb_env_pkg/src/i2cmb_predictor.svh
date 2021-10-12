class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));
 
 ncsu_component#(i2c_transaction) scoreboard;
 i2cmb_env_configuration configuration;
 i2c_transaction predicted_i2c, transport_trans;

 bit[2:0] PS, PRS; //To indicate states. PS is to indicate present, PRS to indicate previous.
 parameter IDLE=3'b000, START_PENDING=3'b001, BUS_TAKEN=3'b010, WRITE_BYTE=3'b011, READ_BYTE=3'b100, STOP_BUS=3'b101; //Parameters to indicate states
 bit enable_bit, irq_bit;
 bit[2:0] bus_id;
 bit[I2C_ADDR_WIDTH-1:0] i2c_slave_addr;
 i2c_op_t transfer_type;
 bit[I2C_DATA_WIDTH-1:0] write_data[$];
 bit[I2C_DATA_WIDTH-1:0] read_data[$];


 function new(string name="", ncsu_component_base parent = null);
	super.new(name, parent);
 endfunction

 function void set_configuration(i2cmb_env_configuration cfg);
	configuration = cfg;
 endfunction

 virtual function void set_scoreboard(ncsu_component#(i2c_transaction) scoreboard);
	this.scoreboard = scoreboard;
 endfunction
 
 virtual function void nb_put(T trans);
	//$display("Wishbone transactions Initiated -----ADDR:%h, DATA:%p, RW:%p", trans.WB_ADDR, trans.WB_DATA, trans.rw_bit);
	case (PS)
	
	IDLE: begin //$display("IDLE STATE");
	      	if(trans.WB_ADDR==CSR && trans.rw_bit==1) begin//Writing to CSR to enable or disable
			enable_bit = trans.WB_DATA[7]; irq_bit=trans.WB_DATA[6];
			if(enable_bit) $display("***I2CMB CORE ENABLED***");
			else $display("***I2CMB CORE DISABLED***");
			if(irq_bit) $display("***INTERRUPT ENABLED***");
	     		PS <= IDLE;
			PRS <= IDLE;
	      	end
		if(trans.WB_ADDR==DPR && enable_bit) begin // Setting the Bus ID.
			bus_id = trans.WB_DATA[2:0];
			//$display("--------------I2C BUS ID:%p-----------------", bus_id);
			PS <= IDLE;
			PRS <= IDLE;
		end
		if(trans.WB_ADDR==CMDR && trans.WB_DATA==SET_BUS && trans.rw_bit) begin	//Set Bus Command
			PS <= IDLE;
			PRS <= IDLE;
		end
		if(trans.WB_ADDR==CMDR && !(trans.rw_bit)) begin //Clearing Irq and checking for command status
			if(trans.WB_DATA[7]) begin
				//$display("Command Succesful");
				PS<=IDLE;
				PRS<=IDLE;
			end
			if(trans.WB_DATA[4]) begin
				$display("Command Error");
				PS<=IDLE;
				PRS<=IDLE;
			end
		end
		if(trans.WB_ADDR==CMDR && trans.WB_DATA==START) begin
			//$display("Start issued");
			PS<= START_PENDING;
			PRS<= IDLE;
		end
	      end
		
	START_PENDING: begin //$display("START_PENDING STATE");
			if(trans.WB_ADDR==CMDR && !(trans.rw_bit)) begin //Clearing irq and checking for command status
				if(PRS==IDLE) begin
					if(trans.WB_DATA[7]) begin
						//$display("START COMMAND SUCCESFUL");
						PS<=BUS_TAKEN;
						PRS<=START_PENDING; end//NEED TO ADD EXTRA CODE TO DEAL WITH REPEATED START.
					if(trans.WB_DATA[5]) begin
						$display("START COMMAND ARBITRATION LOST");
						PS<=IDLE;
						PRS<=START_PENDING; end
					if(trans.WB_DATA[4]) begin
						$display("START COMMAND ERROR");
						PS<=IDLE;
						PRS<=START_PENDING; end
				end
				else if(PRS==BUS_TAKEN) begin
					if(trans.WB_DATA[7]) begin
						//$display("REPEATED START COMMAND SUCCESFUL");
						predicted_i2c = new("predicted_i2c");
						predicted_i2c.OP = transfer_type;
						predicted_i2c.I2C_ADDR = i2c_slave_addr;
						if(transfer_type==WRITE) begin predicted_i2c.I2C_DATA_OUT = write_data; end
						else begin predicted_i2c.I2C_DATA_OUT = read_data; end
						//$display("PREDICTED TRANSACTION: TRANSFER TYPE:%p, SLAVE ADDR:0x%h, DATA:%p", predicted_i2c.OP, predicted_i2c.I2C_ADDR, predicted_i2c.I2C_DATA_OUT);
						scoreboard.nb_transport(predicted_i2c, transport_trans); //SEND THE PREDICTED TRANSACTION TO SCOREBOARD.
						//$display("RETURNED FROM SCBD");
						PS<=BUS_TAKEN;
						PRS<=START_PENDING;
						read_data.delete();
						write_data.delete();
					end
					if(trans.WB_DATA[4]) begin
						//$display("REPEATED START COMMAND ERROR");
						PS<=IDLE;
						PRS<=START_PENDING; end
					if(trans.WB_DATA[5]) begin
						//$display("REPEATED START COMMAND ARBITRATION LOST");
						PS<=IDLE;
						PRS<=START_PENDING; end
				end
			    end
						
			end
	
	BUS_TAKEN: begin //$display("BUS_TAKEN STATE");
			if(trans.WB_ADDR==DPR) begin //Before read/write command, capture the slave address and data byte.
				if(PRS==START_PENDING && trans.rw_bit) begin
					i2c_slave_addr = trans.WB_DATA[WB_DATA_WIDTH-1:1];
					//$display("Captured Slave Addr:0x%h", i2c_slave_addr);
					if(trans.WB_DATA[0]) transfer_type = READ;
					else transfer_type = WRITE;
					//$display("Transfer Type:%p", transfer_type);
					PS<=BUS_TAKEN;
					PRS<=BUS_TAKEN; end
				if(PRS==WRITE_BYTE && trans.rw_bit) begin //$display("Previous state WB");
					write_data.push_back(trans.WB_DATA);
					PS<=BUS_TAKEN;
					PRS<=BUS_TAKEN; end
				if(PRS==READ_BYTE && !(trans.rw_bit))  begin //$display("Previous state RB");
					read_data.push_back(trans.WB_DATA);
					PS<=BUS_TAKEN;
					PRS<=BUS_TAKEN; end
				end
			if(trans.WB_ADDR==CMDR && trans.WB_DATA==WRITE_CMD && trans.rw_bit) begin //Go to WRITE BYTE state is write command is issued.
				//$display("Saw write command");
				PS<=WRITE_BYTE;
				PRS<=BUS_TAKEN; end
			if(trans.WB_ADDR==CMDR && (trans.WB_DATA==READ_ACK || trans.WB_DATA==READ_NACK) && trans.rw_bit) begin //Go to READ BYTE state if Read Ack/Nack command is issued.
				//$display("Saw readack/readnack command");
				PS<=READ_BYTE;
				PRS<=BUS_TAKEN; end
			if(trans.WB_ADDR==CMDR && trans.WB_DATA==START && trans.rw_bit) begin //Go to start oending state if start command is issued. This is case of repeated start.
				//$display("REPEATED START ISSUED");
				PS<=START_PENDING;
				PRS<=BUS_TAKEN; end
			if(trans.WB_ADDR==CMDR && trans.WB_DATA==STOP && trans.rw_bit) begin //Go to Stop state if stop command is issued.
				PS<=STOP_BUS;
				PRS<=BUS_TAKEN; end
			end
		

	WRITE_BYTE: begin //$display("WRITE_BYTE STATE");
			if(trans.WB_ADDR==CMDR && !(trans.rw_bit)) begin
				if(trans.WB_DATA[7]) begin
					//$display("WRITE COMMAND SUCCESFUL");
					PS<=BUS_TAKEN;
					PRS<=WRITE_BYTE; end
				if(trans.WB_DATA[6]) begin
					$display("WRITE COMMAND NOT ACKNOWLEDGED");
					PS<=BUS_TAKEN;
					PRS<=WRITE_BYTE; end
				if(trans.WB_DATA[4]) begin
					$display("WRITE COMMAND ERROR");
					void '(write_data.pop_back());
					PS<=IDLE;
					PRS<=WRITE_BYTE; end
				if(trans.WB_DATA[5]) begin
					$display("WRITE COMMAND ARBITRATION LOST");
					void '(write_data.pop_back());
					PS<=IDLE;
					PRS<=WRITE_BYTE; end
				end
		end

	READ_BYTE: begin //$display("READ_BYTE STATE");
			if(trans.WB_ADDR==CMDR && !(trans.rw_bit)) begin
				if(trans.WB_DATA[7]) begin
					//if(trans.WB_DATA[2:0]==READ_ACK) $display("READ ACK COMMAND SUCCESFUL");
					//if(trans.WB_DATA[2:0]==READ_NACK) $display("READ NACK COMMAND SUCCESFUL");
					PS<=BUS_TAKEN;
					PRS<=READ_BYTE; end
				if(trans.WB_DATA[4]) begin
					if(trans.WB_DATA[2:0]==READ_ACK) $display("READ ACK COMMAND ERROR");
					if(trans.WB_DATA[2:0]==READ_NACK) $display("READ NACK COMMAND ERROR");
					void '(read_data.pop_back());
					PS<=IDLE;
					PRS<=READ_BYTE; end
				if(trans.WB_DATA[5]) begin
					if(trans.WB_DATA[2:0]==READ_ACK) $display("READ ACK COMMAND ARBITRATION LOST");
					if(trans.WB_DATA[2:0]==READ_NACK) $display("READ NACK COMMAND ARBITRATION LOST");
					PS<=IDLE;
					PRS<=READ_BYTE; end
				end
			end

	STOP_BUS: begin //$display("STOP STATE");
			if(trans.WB_ADDR==CMDR && !(trans.rw_bit)) begin
				if(trans.WB_DATA[7]) begin
					//$display("STOP COMMAND SUCCESFUL");
					predicted_i2c = new;
					if(transfer_type==WRITE) begin predicted_i2c.I2C_DATA_OUT = write_data; end
					else begin predicted_i2c.I2C_DATA_OUT = read_data; end
					predicted_i2c.I2C_ADDR = i2c_slave_addr;
					predicted_i2c.OP = transfer_type;
					//$display("PREDICTED TRANSACTION: TRANSFER TYPE:%p, SLAVE ADDR:0x%p, DATA:%p", predicted_i2c.OP, predicted_i2c.I2C_ADDR, predicted_i2c.I2C_DATA_OUT);
					scoreboard.nb_transport(predicted_i2c, transport_trans); //SEND THE PREDICTED TRANSACTION TO SCOREBOARD.
					PS<=IDLE;
					PRS<=STOP_BUS;
					write_data.delete();
					read_data.delete();
					end
				end
			end
					
	default: PS<=IDLE;
     endcase
	
 endfunction

endclass