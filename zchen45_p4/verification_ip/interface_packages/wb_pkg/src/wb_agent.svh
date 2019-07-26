class wb_agent extends ncsu_component#(.T(wb_transaction));

	wb_monitor w_monitor;
	wb_driver w_driver;
	ncsu_component #(T) subscribers[$];

	wb_sequence_base w_seq;
	string seq_name;
	int bus_n;

	virtual wb_if#(.ADDR_WIDTH(2), .DATA_WIDTH(8)) wb_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
		if ( !(ncsu_config_db#(virtual wb_if#(.ADDR_WIDTH(2), .DATA_WIDTH(8)))::get(get_full_name(), this.wb_bus))) begin;
      			$display("w_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      			$finish;
    		end

		if ( !$value$plusargs("GEN_SEQ_TYPE=%s", seq_name)) begin
      			$display("FATAL: +GEN_SEQ_TYPE plusarg not found on command line");
      			$fatal;
    		end
    		$display("%m found +GEN_SEQ_TYPE=%s", seq_name);
	endfunction

	virtual function void build();
		w_driver = new("w_driver", this);
		w_driver.build();
		w_driver.wb_bus = this.wb_bus;

		$cast(w_seq, ncsu_object_factory::create(seq_name));
//		w_seq = new("w_seq");
		w_seq.build();
		w_seq.wb_bus = this.wb_bus;
		w_seq.set_driver(this.w_driver);
//		$cast(w_seq, ncsu_object_factory::create(seq_name));

		w_monitor = new("w_monitor", this);
		w_monitor.set_agent(this);
		w_monitor.build();
		w_monitor.wb_bus = this.wb_bus;
	endfunction

	virtual task run();
		fork
			w_monitor.run();
		join_none
	endtask

  	virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    		subscribers.push_back(subscriber);
  	endfunction

  	virtual function void nb_put(T trans);
		w_seq.get_busid(bus_n);
		trans.bus_id = bus_n;
    		foreach (subscribers[i]) subscribers[i].nb_put(trans);
  	endfunction
 
	virtual task seq_run();
		w_seq.run();
	endtask

	virtual task init();
		w_seq.init();
	endtask

	virtual task write_32();
		w_seq.write_32();
	endtask

	virtual task read_32();
		w_seq.read_32();
	endtask

	virtual task read();
		w_seq.read();
	endtask

	virtual task write(int temp);
		w_seq.write(temp);
	endtask

	virtual task rand_test();
		w_seq.rand_test();
	endtask

	virtual function void get_busid(output int bus_num);
		w_seq.get_busid(bus_n);
		bus_num = bus_n;
	endfunction

endclass




