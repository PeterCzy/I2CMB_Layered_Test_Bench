class i2cmb_environment extends ncsu_component#(.T(wb_transaction));

	i2c_agent i_agent;
	wb_agent w_agent;
	i2cmb_predictor pred;
	i2cmb_scoreboard scbd;
	i2cmb_coverage coverage;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build();
		w_agent = new("w_agent", this);
		w_agent.build();

		i_agent = new("i_agent", this);
		i_agent.build();

		pred = new("pred", this);
		pred.build();

		scbd = new("scbd", this);
		scbd.build();

		coverage = new("coverage", this);
		coverage.build();

		w_agent.connect_subscriber(coverage);
		w_agent.connect_subscriber(pred);
		i_agent.connect_subscriber(scbd);
		pred.set_scoreboard(scbd);
		
	endfunction

	virtual task run();
		w_agent.run();
		i_agent.run();
	endtask

  	function ncsu_component#(.T(wb_transaction)) get_w_agent();
    		return w_agent;
  	endfunction

  	function ncsu_component#(.T(i2c_transaction)) get_i_agent();
    		return i_agent;
  	endfunction

endclass
