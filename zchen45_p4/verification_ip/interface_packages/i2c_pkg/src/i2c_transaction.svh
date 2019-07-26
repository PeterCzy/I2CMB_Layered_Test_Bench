class i2c_transaction extends ncsu_transaction;

	int op;
	bit [7:0] write_data [];
	bit [7:0] read_data [];

	int op_scbd;
	bit [7:0] addr_scbd;
	bit [7:0] data_scbd [];
	
	int bus_id;

	function new(string name = "");
		super.new(name);
	endfunction


endclass
