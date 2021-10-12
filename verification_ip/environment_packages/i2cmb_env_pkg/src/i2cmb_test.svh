class i2cmb_test extends ncsu_component;

 i2cmb_env_configuration cfg;
 i2cmb_environment env;
 i2cmb_generator_base gen;
 string gen_type;

 function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);
	if(!$value$plusargs("GEN_TYPE=%s", gen_type)) begin
		$display("FATAL: +GEN_TYPE plusarg not found on command line");
		$fatal;
	end
	$display("%m found +GEN_TYPE=%s", gen_type);
	cfg = new("cfg");
	env = new("env", this);
	env.set_configuration(cfg);
	env.build();
	$cast(gen, ncsu_object_factory::create(gen_type));
	//gen = new("gen", this);
	gen.set_agent(env.get_wishbone_agent(), env.get_i2c_agent());
 endfunction

 virtual task run();
	env.run();
	gen.run();
 endtask

endclass