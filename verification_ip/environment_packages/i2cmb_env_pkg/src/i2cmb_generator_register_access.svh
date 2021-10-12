class i2cmb_generator_register_access extends i2cmb_generator_base;
	`ncsu_register_object(i2cmb_generator_register_access);

wb_transaction wb_test;
int errors=0;

function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
endfunction

virtual task run();
	$cast(wb_test, ncsu_object_factory::create("wb_transaction"));
	$display("_________REGISTER ACCESS TEST_________");
	$display("**** CSR ACCESS TESTS****");
	wb_test.WB_ADDR=CSR; wb_test.WB_DATA=8'hff; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	
	if(wb_test.temp_data[5]) begin
		errors++;
		$error("TEST CASE FAILED: READ-ONLY BUS BUSY BIT SET THROUGH CSR");
		end
	else $display("TEST CASE PASSED: BUS BUSY BIT NOT WRITTEN");
	if(wb_test.temp_data[4]) begin
		errors++;
		$error("TEST CASE FAILED: READ-ONLY BUS CAPTURE BIT SET THROUGH CSR");
		end
	else $display("TEST CASE PASSED: BUS CAPTURE BIT NOT  WRITTEN");
	if(wb_test.temp_data[3:0]) begin
		errors++;
		$error("TEST CASE FAILED: BUS ID SET THROUGH CSR");
		end
	else $display("TEST CASE PASSED: BUS ID NOT WRITTEN THROUGH CSR");
	
	$display("**** FSM ACCESS TESTS *****");
	wb_test.WB_ADDR=FSM; wb_test.WB_DATA=8'hff; wb_test.R_W=WRITE;
	WB_agent.bl_put_ref(wb_test);
	wb_test.R_W=READ;
	WB_agent.bl_put_ref(wb_test);
	if(wb_test.temp_data) begin
		errors++;
		$display("Register Addr:%h, Register Data:%b", wb_test.WB_ADDR, wb_test.temp_data);
		$error("TEST CASE FAILED: READ-ONLY FSM REGISTER WRITTEN");
		end
	else $display("TEST CASE PASSED: FSM REGISTER NOT WRITTEN");
	
	if(errors) begin
		$display("%p test cases failed", errors);
		$display("_________REGISTER ACCESS TEST FAILED______");
		end
	else $display("________REGISTER ACCESS TEST SUCCESFUL________");
endtask
endclass
