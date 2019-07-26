class i2cmb_scoreboard extends ncsu_component#(.T(wb_transaction));

	T trans_in;
	T trans_out;
	T i2c_trans_in;
	int t = 0;

  	function new(string name = "", ncsu_component_base  parent = null); 
   		super.new(name,parent);
		trans_in = new("trans_in");
  	endfunction

	virtual function void nb_transport(input T input_trans, output T output_trans);

		$display("wb  to scbd: wb_op : %d, wb_addr : %b, wb_data : %h, wb_bus : %d", 
			  input_trans.op_pred, input_trans.addr_pred, input_trans.data_pred, input_trans.bus_id);
		$display("i2c to scbd: i2c_op: %d, i2c_addr: %b, i2c_data: %h, i2c_bus: %d", 
			  i2c_trans_in.op_scbd, i2c_trans_in.addr_scbd, i2c_trans_in.data_scbd, (15 - i2c_trans_in.bus_id_scbd));

		if (this.input_trans.compare(this.i2c_trans_in)) 	$display({get_full_name()," transaction MATCH!"});
		else                                			$display({get_full_name()," transaction MISMATCH!"});

	endfunction


  	virtual function void nb_put(T trans);
//    		$display({get_full_name()," nb_put: actual transaction ",trans.convert2string()});
		this.i2c_trans_in = new();
		this.i2c_trans_in = trans;
  	endfunction

endclass
