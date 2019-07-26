class i2c_driver extends ncsu_component#(.T(i2c_transaction));

	i2c_transaction i_trans_read;
	virtual i2c_if#(.I2C_DATA_WIDTH(8), .I2C_ADDR_WIDTH(8)) i2c_bus;

	int op_t;
	int bus_n;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build();
		$display("i2c_driver build");
	endfunction

	virtual task bl_get(output T trans);
		i_trans_read = new("i_trans_read");
		i2c_bus.wait_for_i2c_transfer(op_t, i_trans_read.write_data);
		i_trans_read.op = op_t;
		trans = i_trans_read;
	endtask

	virtual task bl_put(T trans);
		i2c_bus.provide_read_data(trans.read_data);
	endtask

endclass
