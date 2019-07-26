class wb_monitor extends ncsu_component#(.T(wb_transaction));

	ncsu_component #(T) agent;
	T monitor_trans;
	virtual wb_if#(.ADDR_WIDTH(2), .DATA_WIDTH(8)) wb_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, this);
	endfunction

	virtual function void build();
//		$display("w_monitor build");
	endfunction

  	function void set_agent(ncsu_component #(T) agent);
    		this.agent = agent;
  	endfunction

	virtual task run();
		bit [1:0] addr;
		bit [7:0] data;
		bit we_temp;

		wb_bus.wait_for_reset();
		forever begin
			monitor_trans = new("monitor_trans");
			wb_bus.master_monitor(addr, data, we_temp);
			$display("wb monitor : we: %b, addr: %h; data: %h",we_temp, addr, data);
			monitor_trans.set_arg(addr, data);
			monitor_trans.we = we_temp;

			agent.nb_put(monitor_trans);
		end
	endtask

endclass
