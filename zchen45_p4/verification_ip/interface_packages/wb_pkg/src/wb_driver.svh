class wb_driver extends ncsu_component#(.T(wb_transaction));

	wb_transaction trans_read;

	reg [7:0] fsmr;

	virtual wb_if#(.ADDR_WIDTH(2), .DATA_WIDTH(8)) wb_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build();
		$display("w_driver build");
	endfunction

	virtual task bl_put(T trans);
		wb_bus.master_write(trans.addr, trans.data);			//enable the core
		
		wb_bus.master_read(2'b11, fsmr);
	endtask

	virtual task bl_get(output T trans);
		reg [7:0] data;

		wb_bus.master_read(2'b10, data);
		trans_read = new("trans_read");
		trans_read.set_arg(2'b10, data);
		trans = trans_read;

		wb_bus.master_read(2'b11, fsmr);
	endtask

	virtual task bl_get_dpr(output T trans);

		reg [7:0] data;

		wb_bus.master_read(2'b01, data);
		trans_read = new("trans_read");
		trans_read.set_arg(2'b01, data);
		trans = trans_read;

		wb_bus.master_read(2'b11, fsmr);
	endtask

	virtual task bl_get_csr(output T trans);

		reg [7:0] data;

		wb_bus.master_read(2'b00, data);
		trans_read = new("trans_read");
		trans_read.set_arg(2'b00, data);
		trans = trans_read;

		wb_bus.master_read(2'b11, fsmr);
	endtask

	virtual task wait_for_interrupt();
		wb_bus.wait_for_interrupt();
	endtask

	virtual task wait_for_pos_clk();;
		wb_bus.wait_for_pos_clk();
	endtask

endclass
