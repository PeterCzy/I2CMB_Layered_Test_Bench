class wb_transaction extends ncsu_transaction;
	`ncsu_register_object(wb_transaction)

	bit [1:0] addr;
	bit [7:0] data;

	int op_pred;
	bit [7:0] addr_pred;
	bit [7:0] data_pred [];
	int bus_id;
// args below are not useful for wb's functionality
// used to transfer i2c_transaction to wb_transaction in i2c_agent nb_put
	int op_scbd;
	bit [7:0] addr_scbd;
	bit [7:0] data_scbd [];
	int bus_id_scbd;

	bit we;
	int index;
	int row;

	function new(string name = "");
		super.new(name);
	endfunction

	virtual function void set_arg(bit [1:0] addr_input, bit [7:0] data_input);
		this.addr = addr_input;
		this.data = data_input;
	endfunction

	virtual function bit compare(wb_transaction rhs);
		return(	(this.op_pred == rhs.op_scbd) &&
			(this.addr_pred == rhs.addr_scbd) &&
			(this.data_pred == rhs.data_scbd));		
	endfunction

endclass


















