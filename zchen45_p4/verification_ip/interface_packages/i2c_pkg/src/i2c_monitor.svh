class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

	ncsu_component #(T) agent;
	T i_monitor_trans;
	virtual i2c_if#(.I2C_DATA_WIDTH(8), .I2C_ADDR_WIDTH(8)) i2c_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, this);
	endfunction

	virtual function void build();
//		$display("i2c_monitor build");
	endfunction

  	function void set_agent(ncsu_component #(T) agent);
    		this.agent = agent;
  	endfunction

	virtual task run();
		bit [7:0] addr;
		bit [7:0] data_out[];
		bit [7:0] temp[];
		int op;
		int bus_n;

		forever begin
			i_monitor_trans = new("i2c_monitor_trans");

			i2c_bus.monitor(addr, op, data_out, bus_n);
			if(temp != data_out && data_out.size() != 0) begin
//			$display("time: %0t, addr: %8b, op: %d, data: %u", $time, addr, op, data);
				if(op == 1) begin
					$display("i2c monitor: I2C_BUS READ TRANSFER: addr: %8b, data: %u", addr, data_out);
					i_monitor_trans.op_scbd = op;
					i_monitor_trans.addr_scbd = addr;
					i_monitor_trans.data_scbd = data_out;
					i_monitor_trans.bus_id = bus_n;
					
				end
				else if(op == 2) begin
					$display("i2c monitor: I2C_BUS WRITE TRANSFER: addr: %8b, data: %u", addr, data_out);
					i_monitor_trans.op_scbd = op;
					i_monitor_trans.addr_scbd = addr;
					i_monitor_trans.data_scbd = data_out;
					i_monitor_trans.bus_id = bus_n;
				end
			temp = new [data_out.size()](data_out);

			agent.nb_put(i_monitor_trans);
			end
		end
	endtask

endclass
