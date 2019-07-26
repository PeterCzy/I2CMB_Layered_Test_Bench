class i2c_agent extends ncsu_component#(.T(i2c_transaction));

	i2c_driver i_driver;
	i2c_monitor i_monitor;
	ncsu_component #(wb_transaction) subscribers[$];
	wb_transaction wb_tr_t;
	int bus_n;

	virtual i2c_if#(.I2C_DATA_WIDTH(8), .I2C_ADDR_WIDTH(8)) i2c_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
		if ( !(ncsu_config_db#(virtual i2c_if#(.I2C_DATA_WIDTH(8), .I2C_ADDR_WIDTH(8)))::get(get_full_name(), this.i2c_bus))) begin;
      			$display("i_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      			$finish;
    		end
	endfunction

	virtual function void build();
		i_driver = new("i_driver", this);
		i_driver.build();
		i_driver.i2c_bus = this.i2c_bus;

		i_monitor = new("i_monitor", this);
		i_monitor.set_agent(this);
		i_monitor.build();
		i_monitor.i2c_bus = this.i2c_bus;
	endfunction

	virtual task bl_get(output T trans);
		i_driver.bl_get(trans);
	endtask

	virtual task bl_put(T trans);
		i_driver.bl_put(trans);
	endtask

	virtual task run();
		fork
			i_monitor.run();
		join_none
	endtask

  	virtual function void connect_subscriber(ncsu_component#(wb_transaction) subscriber);
    		subscribers.push_back(subscriber);
  	endfunction

  	virtual function void nb_put(T trans);
		wb_tr_t = new("wb_tr_t");
		wb_tr_t.op_scbd = trans.op_scbd;
		wb_tr_t.addr_scbd = trans.addr_scbd;
		wb_tr_t.data_scbd = trans.data_scbd;//new(trans.data_scbd);
		wb_tr_t.bus_id_scbd = trans.bus_id;

    		foreach (subscribers[i]) subscribers[i].nb_put(wb_tr_t);
  	endfunction

endclass



