class i2cmb_generator_dut_test extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_dut_test)
	
wb_transaction wb_test;
i2c_transaction i2c_test;
int errors=0;

function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
endfunction

virtual task run();

	$cast(wb_test, ncsu_object_factory::create("wb_transaction"));
	$cast(i2c_test, ncsu_object_factory::create("i2c_transaction"));
	$display("______I2CMB DUT TEST______");
	i2c_test.set_num_transfers(1,1);
	fork I2C_agent.bl_put(i2c_test); join_none
	
	
	wb_test.WB_ADDR=CSR; wb_test.WB_DATA=ENABLE; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(!(wb_test.temp_data[5])) $display("TEST CASE PASSED: BUS BUSY BIT RESET BEFORE ISSUE OF START");
	else begin
		errors++;
		$error("TEST CASE FAILED: BUS BUSY BIT SET BEFORE ISSUE OF START");
		end
	if(wb_test.temp_data[4]) begin
		errors++;
		$error("TEST CASE FAILED: BUS CAPTURE BIT SET BEFORE SET BUS COMMAND");
		end
	else $display("TEST CASE PASSED: BUS CAPTURE BIT NOT SET BEFORE SET BUS COMMAND");
	
	$display("");

	wb_test.WB_ADDR=DPR; wb_test.WB_DATA=8'h00; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=SET_BUS; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data[7]) $display("TEST CASE PASSED: VALID BUS ID");
	else begin
		errors++;
		$error("TEST CASE FAILED: VALID BUS ID GENERATED ERROR");
		end
	
	
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=START; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put(wb_test);
	
	wb_test.WB_ADDR=DPR; wb_test.WB_DATA=8'h62; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=WRITE_CMD; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put(wb_test);
	
	#200	//Optional
	wb_test.WB_ADDR=DPR; wb_test.WB_DATA=200; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=WRITE_CMD; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put(wb_test);
	
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=STOP; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put(wb_test);
	
	
	wb_test.WB_ADDR=CSR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data[4]) begin
		errors++;
		$error("TEST CASE FAILED: BUS CAPTURE BIT SET AFTER STOP");
		end
	else $display("TEST CASE PASSED: BUS CAPTURE BIT RESET AFTER STOP");
	

	$display("****INVALID BUS ID RESPONSE TEST ****");
	wb_test.WB_ADDR=DPR; wb_test.WB_DATA=8'h02; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=SET_BUS; wb_test.R_W=WRITE;
	WB_agent.bl_put(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data[4]) $display("TEST CASE PASSED: ERROR GENERATED AS EXPECTED DUE TO INVALID BUS ID");
	else if(wb_test.temp_data[7] && !(wb_test.temp_data[4])) begin
		errors++;
		$error("TEST CASE FAILED: EXPECTED ERROR GENERATION DUE TO INVALID BUS ID, INSTEAD DONE IS SET");
		end

	if(errors) begin
		$display("%p test cases failed", errors);
		$display("_______ I2CMB DUT TESTS FAILED______");
		end
	else begin
		$display("All test cases passed");
		$display("________ I2CMB DUT TESTS SUCCESFUL________");
		end
	
endtask

endclass
	
	
