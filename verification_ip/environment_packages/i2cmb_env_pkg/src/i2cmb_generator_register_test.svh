class i2cmb_generator_register_test extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_register_test)

 wb_transaction wb_test;
 i2c_transaction i2c_test;
 int errors=0;

 function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
 endfunction

 virtual task run();
	$display("_______REGISTER DEFAULT VALUES TEST________");
	$cast(wb_test, ncsu_object_factory::create("wb_transaction"));
	wb_test.WB_ADDR=CSR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data==8'b00000000) begin
		$display("CSR REGISTER DEFAULT VALUE CORRECT BEFORE ENABLE"); 
		end
	else begin
		$display("CSR REGISTER DEFAULT VALUE ERROR");
		$display("TEST CASE FAILED");
		errors++;
		$error;
		end

	wb_test.WB_ADDR=CSR; wb_test.R_W=WRITE; wb_test.WB_DATA=ENABLE;
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W= READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data==8'b11000000) begin
		$display("CSR REGISTER BITS CORRECT AFTER ENABLE: %b", wb_test.temp_data); end
	else begin
		$display("CSR REGISTER BITS INCORRECT AFTER ENABLE:%b", wb_test.temp_data);
		$display("TEST CASE FAILED");
		errors++;
		$error;
		end

	wb_test.WB_ADDR=CMDR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data==8'b10000000) begin
		$display("CMDR REGISTER DEFAULT VALUES CHECKED :%b", wb_test.temp_data); end
	else begin
		$display("CMDR REGISTER DEFAULT VALUES INCORRECT :%b", wb_test.temp_data);
		$display("TEST CASE FAILED");
		errors++;
		$error;
		end

	wb_test.WB_ADDR=DPR; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data==8'h00) begin
		$display("DPR REGISTER DEFAULT VALUES CEHCKED :%b", wb_test.temp_data); end
	else begin
		$display("DPR REGISTER DEFAULT VALUES INCORRECT :%b", wb_test.temp_data);
		$display("TEST CASE FAILED");
		errors++;
		$error;
		end
	
	wb_test.WB_ADDR=FSM; wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data==8'h00) begin
		$display("FSM REGISTER DEFAULT VALUES CHECKED :%b", wb_test.temp_data); end
	else begin
		$display("FSM REGISTER DEFAULT VALUES INCORRECT :%b", wb_test.temp_data); 
		$display("TEST CASE FAILED");
		errors++;
		$error;
		end
	
	if(errors) begin
		$display("%p TEST CASES FAILED", errors);
		$display("TEST FAILED");
		$fatal; end
	else begin
		$display("All test cases passed");
		$display("________________REGISTER DEFAULT TEST SUCCESFUL________________");
		end

 endtask

endclass