class i2cmb_test extends ncsu_component#(.T(wb_transaction));

	i2cmb_environment env;
	i2cmb_generator gen;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
		env = new("env", this);
		env.build();
		gen = new("gem", this);
		gen.set_agent(env.get_w_agent(), env.get_i_agent());
	endfunction

	virtual task run();
		env.run();
		gen.run();
	endtask

endclass
