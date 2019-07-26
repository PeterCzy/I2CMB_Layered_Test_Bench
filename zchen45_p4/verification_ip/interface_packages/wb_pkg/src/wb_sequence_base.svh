class wb_sequence_base extends ncsu_component#(.T(wb_transaction));
	`ncsu_register_object(wb_sequence_base)

	ncsu_component #(T) agent;
	wb_driver w_driver;
	wb_transaction transaction;

	virtual wb_if#(.ADDR_WIDTH(2), .DATA_WIDTH(8)) wb_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction

	virtual function void build();
		transaction = new("trans");
	endfunction

	virtual function void set_driver(wb_driver driver);
    		this.w_driver = driver;
  	endfunction

	virtual task init();
		transaction.set_arg(2'b00, 8'b11xxxxxx);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b01, 8'h00);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b10, 8'bxxxxx110);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
	endtask

	virtual task write_32();
		$display("***************************************write 32 values***************************************");
		// start
		$display("~~~~~~~~~~start~~~~~~~~~~");
		transaction.set_arg(2'b10, 8'bxxxxx100);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);	

		// addr
		$display("~~~~~~~~~~addr~~~~~~~~~~");
		transaction.set_arg(2'b01, 8'h44);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b10, 8'bxxxxx001);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);

		// data
		$display("~~~~~~~~~~data~~~~~~~~~~");
		for(int i = 0; i < 32; i++) begin
			transaction.set_arg(2'b01, i);
			w_driver.bl_put(transaction);

			transaction.set_arg(2'b10, 8'bxxxxx001);
			w_driver.bl_put(transaction);

			w_driver.wait_for_interrupt();
			w_driver.bl_get(transaction);
		end

		// stop
		$display("~~~~~~~~~~stop~~~~~~~~~~");
		transaction.set_arg(2'b10,8'bxxxxx101);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
	endtask

	virtual task read_32();
		$display("***************************************read 32 values***************************************");

		//start
		$display("~~~~~~~~~~start~~~~~~~~~~");
		transaction.set_arg(2'b10, 8'bxxxxx100);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);

		// addr
		$display("~~~~~~~~~~addr~~~~~~~~~~");
		transaction.set_arg(2'b01, 8'h45);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b10, 8'bxxxxx001);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);				

		// data
		$display("~~~~~~~~~~data~~~~~~~~~~");
		for(int i = 0; i < 31; i++) begin
			transaction.set_arg(2'b10, 8'bxxxxx010);
			w_driver.bl_put(transaction);

			w_driver.wait_for_interrupt();

			w_driver.bl_get(transaction);
			w_driver.bl_get_dpr(transaction);  //dpr
		end

		transaction.set_arg(2'b10, 8'bxxxxx011);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
		w_driver.bl_get_dpr(transaction);  //dpr

		// stop
		$display("~~~~~~~~~~stop~~~~~~~~~~");
		transaction.set_arg(2'b10,8'bxxxxx101);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();		
		w_driver.bl_get(transaction);
	endtask

	virtual task read();
		//start
		transaction.set_arg(2'b10, 8'bxxxxx100);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);

		// addr
		transaction.set_arg(2'b01, 8'h45);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b10, 8'bxxxxx001);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);				

		// data
		transaction.set_arg(2'b10, 8'bxxxxx011);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
		w_driver.bl_get_dpr(transaction);  //dpr

		// stop
		transaction.set_arg(2'b10,8'bxxxxx101);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();		
		w_driver.bl_get(transaction);
	endtask

	virtual task write(int temp);
		transaction.set_arg(2'b10, 8'bxxxxx100);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);	

		// addr
		transaction.set_arg(2'b01, 8'h44);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b10, 8'bxxxxx001);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);

		// data

		transaction.set_arg(2'b01, temp);
		w_driver.bl_put(transaction);

		transaction.set_arg(2'b10, 8'bxxxxx001);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);


		// stop
		transaction.set_arg(2'b10,8'bxxxxx101);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
	endtask

//	virtual task rand_test();
//	endtask
endclass









