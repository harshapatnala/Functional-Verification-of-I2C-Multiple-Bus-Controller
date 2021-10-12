class i2cmb_generator_reset_test extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_reset_test)

wb_transaction wb_test;

int errors=0;


 function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
 endfunction


 virtual task run();

	$display("___________I2CMB CORE RESET TEST__________");
	$cast(wb_test, ncsu_object_factory::create("wb_transaction"));
	$display("******REGISTER CHECKS BEFORE ENABLE*******");
	wb_test.WB_ADDR= DPR; wb_test.WB_DATA=8'h80; wb_test.R_W=WRITE; //Core is not enabled yet, checking if registers are accesible.
	WB_agent.bl_put_ref(wb_test);

	$display("REGISTER ADDRESS: %h, REGISTER DATA:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: DPR REGISTER CHECK BEFORE CORE ENABLE");
	else begin 
		$display("TEST CASE FAILED: DPR REGISTER CHECK BEFORE ENABLE");
		errors++;
		$error; end
	
	wb_test.WB_ADDR=CMDR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("REGISTER ADDRESS: %h, REGISTER DATA:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h80) $display("TEST CASE PASSED: CMDR REGISTER CHECK BEFORE CORE ENABLE");
	else begin
		$display("TEST CASE FAILED: CMDR REGISTER CHECK BEFORE CORE ENABLE");
		errors++;
		$error; end
	
	wb_test.WB_ADDR= CSR; wb_test.WB_DATA= ENABLE; wb_test.R_W=WRITE;//ENABLING THE CORE
	WB_agent.bl_put_ref(wb_test);
	$display("*******REGISTERS CHECK AFTER ENABLE*******");

	wb_test.WB_ADDR= DPR; wb_test.WB_DATA=8'h88; wb_test.R_W=WRITE; 
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("REGISTER ADDRESS: %h, REGISTER DATA:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: DPR REGISTER CHECK AFTER CORE ENABLE");
	else begin 
		$display("TEST CASE FAILED: DPR REGISTER CHECK AFTER CORE ENABLE");
		errors++;
		$error; end
	
	wb_test.WB_ADDR=CMDR; wb_test.WB_DATA=WRITE_CMD; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("REGISTER ADDRESS:%h, REGISTER DATA:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data[4]) $display("TEST CASE PASSED: ERROR GENERATED AS EXPECTED");
	else begin
		$display("TEST CASE FAILED: EXPECTED ERROR BUT NOT GENERATED");
		errors++;
		$error; end

	wb_test.WB_ADDR=CSR; wb_test.WB_DATA=8'h01; wb_test.R_W=WRITE; // DISABLING CORE
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("REGISTER ADDRESS:%h, REGISTER DATA:%b", wb_test.WB_ADDR, wb_test.temp_data);
	if(!(wb_test.temp_data[7])) $display("TEST CASE PASSED: CORE SUCCESFULLY DISABLED ON RESET");
	else begin
		$display("TEST CASE FAILED: EXPECTED CORE DISABLE ON RESET, BUT NOT DISABLED");
		errors++;
		$error; end
	
	wb_test.WB_ADDR= DPR; wb_test.WB_DATA=8'h80; wb_test.R_W=WRITE; //Core is not enabled yet, checking if registers are accesible.
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("REGISTER ADDRESS: %h, REGISTER DATA:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h00) $display("TEST CASE PASSED: DPR REGISTER CHECK AFTER CORE DISABLED");
	else begin 
		$display("TEST CASE FAILED: DPR REGISTER CHECK AFTER CORE DISABLED");
		errors++;
		$error; end
	
	wb_test.WB_ADDR=CMDR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	$display("REGISTER ADDRESS: %h, REGISTER DATA:%h", wb_test.WB_ADDR, wb_test.temp_data);
	if(wb_test.temp_data==8'h80) $display("TEST CASE PASSED: CMDR RESET AND CORE DISABLE");
	else begin
		$display("TEST CASE FAILED: EXPECTED CMDR RESET AFTER CORE DISABLE");
		errors++;
		$error; end

	if(errors) begin 
		$display("%p TEST CASES FAILED", errors);
		$display("_______________TEST FAILED____________");
		$fatal; end
	else begin
		$display("ALL TEST CASES PASSED");
		$display("_______________I2CM CORE RESET TEST SUCCESFUL_____________");
		end
	
	
	
 endtask

endclass