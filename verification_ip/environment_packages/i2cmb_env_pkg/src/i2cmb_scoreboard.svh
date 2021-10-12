class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));

T predicted_trans;
T actual_trans;

 function new(string name="", ncsu_component_base parent=null);
	super.new(name,parent);
 endfunction


 virtual function void nb_put(T trans);
	this.actual_trans = trans;
	$display("******************************** ACTUAL I2C Transaction *********************************");
	$display("I2C Transfer Type: %p, Slave Address:0x%h", actual_trans.OP, actual_trans.I2C_ADDR);
	$display("Data Transferred:%p", actual_trans.I2C_DATA_OUT);
	$display("**********************************************************************************");
 endfunction

 virtual function void nb_transport(input T input_trans, output T output_trans);
	this.predicted_trans = input_trans;
	//$display("******************************* PREDICTED I2C Transaction ********************************");
	//$display("PREDICTED TRANSFER TYPE:%p, PREDICTED ADDR:0x%h", predicted_trans.OP, predicted_trans.I2C_ADDR);
	//$display("PREDICTED DATA:%p", predicted_trans.I2C_DATA_OUT);
	//$display("******************************************************************************************");
	if(this.predicted_trans.compare(actual_trans)) $display("_____________I2C TRANSACTION MATCH______________");
	else $display("______________I2C Transaction MISMATCH_____________");
 endfunction

endclass