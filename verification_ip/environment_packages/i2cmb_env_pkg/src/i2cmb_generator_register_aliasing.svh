class i2cmb_generator_register_aliasing extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_register_aliasing)

 wb_transaction wb_test;
 int errors=0;
 function new(string name="", ncsu_component_base parent=null);
	super.new(name,parent);
 endfunction


virtual task run();
	$display("___________REGISTER ALIASING TEST___________");
	$cast(wb_test, ncsu_object_factory::create("wb_transaction"));
	$display("**** CSR REGISTER ALIASING TESTS ****");
	wb_test.WB_ADDR=CSR; wb_test.WB_DATA=ENABLE; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	
	wb_test.WB_ADDR=DPR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);	//Reading DPR to check if writing to CSR has effected DPR
	$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: DPR UNCHANGED WHEN WRITING TO CSR");
	else begin
		$display("TEST CASE FAILED: DPR ALIASED WHEN WRITING TO CSR");
		errors++;
		$error;
		end
	wb_test.WB_ADDR=CMDR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);	//Reading CMDR to check if writing to CSR has effected CMDR
	$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h80) $display("TEST CASE PASSED: CMDR UNCHANGED WHEN WRITING TO CSR");
	else begin
		$display("TEST CASE FAILED: CMDR ALIASED WHEN WRITING TO CSR");
		errors++;
		$error;
		end

	wb_test.WB_ADDR=FSM;
	WB_agent.bl_put_ref(wb_test);
	$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: FSM UNCHANGED WHEN WRITING TO CSR");
	else begin
		$display("TEST CASE FAILED: FSM ALIASED WHEN WRITING TO CSR");
		errors++;
		$error;
		end

	$display("**** DPR REGISTER ALIASING TESTS ****");
	wb_test.WB_ADDR=DPR; wb_test.WB_DATA=8'h24; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	wb_test.WB_ADDR=CMDR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h80) $display("TEST CASE PASSED: CMDR UNCHANGED WHEN WRITING TO DPR");
	else begin
		$display("TEST CASE FAILED: CMDR ALIASED WHEN WRITING TO DPR");
		errors++;
		$error;
		end

	wb_test.WB_ADDR=CSR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'b11000000) $display("TEST CASE PASSED: CSR UNCHANGED WHEN WRITING TO DPR");
	else begin
		$display("TEST CASE FAILED: CSR ALIASED WHEN WRITING TO DPR");
		errors++;
		$error;
		end

	wb_test.WB_ADDR=FSM; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: FSM UNCHANGED WHEN WRITING TO DPR");
	else begin
		$display("TEST CASE FAILED: FSM ALIASED WHEN WRITING TO DPR");
		errors++;
		$error;
		end

	$display("**** CMDR REGISTER ALIASING TESTS ****");
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=WRITE_CMD; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	
	wb_test.WB_ADDR=CMDR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);	
	if(wb_test.temp_data[4]) begin
		$display("TEST CASE PASSED: ERROR GENERATED AS EXPECTED");
		wb_test.WB_ADDR=DPR; wb_test.R_W=READ;
		WB_agent.bl_put_ref(wb_test);
		$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
		if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: DPR UNCHANGED WHEN WRITING TO CMDR");
		else begin
			$display("TEST CASE FAILED: DPR ALIASED WHEN WRITING TO CMDR");
			errors++;
			$error;
			end
		wb_test.WB_ADDR=CSR; wb_test.R_W=READ;
		WB_agent.bl_put_ref(wb_test);	
		$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
		if(wb_test.temp_data==8'b11000000) $display("TEST CASE PASSED: CSR UNCHANGED WHEN WRITING TO CMDR");
		else begin
			$display("TEST CASE FAILED: CSR ALIASED WHEN WRITING TO CMDR");
			errors++;
			$error;
			end

		wb_test.WB_ADDR=FSM;
		WB_agent.bl_put_ref(wb_test);
		$display("Register Address:%h, Register Data:%h", wb_test.WB_ADDR, wb_test.temp_data);
		if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: FSM UNCHANGED WHEN WRITING TO CMDR");
		else begin
			$display("TEST CASE FAILED: FSM ALIASED WHEN WRITING TO CMDR");
			errors++;
			$error;
			end
		end
	else begin
		$display("TEST CASE FAILED: EXPECTED ERROR TO BE GENERATED (Issuing write command before start)");
		errors++;
		$error;
		end

	if(errors) begin
		$display("%p Test Cases Failed", errors);
		$display("_________REGISTER ALIASING TEST FAILED_________");
		$fatal;
		end
	else begin
		$display("All Test Cases Passed");
		$display("___________REGISTER ALIASING TEST SUCCESFUL_________");
		end

 endtask

endclass




