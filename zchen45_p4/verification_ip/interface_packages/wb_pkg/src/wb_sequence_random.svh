class wb_sequence_random extends wb_sequence_base;
	`ncsu_register_object(wb_sequence_random)

	ncsu_component #(T) agent;
	wb_driver w_driver;
	wb_transaction trans;
	wb_transaction transaction;
	string trans_name;
	int bus_n;

	virtual wb_if#(.ADDR_WIDTH(2), .DATA_WIDTH(8)) wb_bus;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);

		if ( !$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) begin
      			$display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      			$fatal;
    		end
    		$display("%m found +GEN_TRANS_TYPE=%s", trans_name);
	endfunction

	virtual function void build();
		$cast(trans, ncsu_object_factory::create(trans_name));
		transaction = new("transaction");
	endfunction

	virtual function void set_driver(wb_driver driver);
    		this.w_driver = driver;
  	endfunction

	virtual task init();
		$display("*****************************I     am     random    sequence****************************");
		transaction.set_arg(2'b00, 8'b11xxxxxx);
		w_driver.bl_put(transaction);

//		transaction.set_arg(2'b01, 8'h01);
		assert(trans.randomize());
		$display("~~~~~~~~~~set busID~~~~~~~~~~");
		$display("w_seq_random: rand bus: busID: %h", trans.data);
		bus_n = trans.data;
		$display("~~~~~~~~~~~~~~~~~~~~~~~~");
		w_driver.bl_put(trans);

		transaction.set_arg(2'b10, 8'bxxxxx110);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
	endtask

	virtual task write_32();
	endtask

	virtual task read_32();
	endtask

	virtual task read();
	endtask

	virtual task write(int temp);
	endtask

	virtual task rand_test();

		int i, s_index;

		// start
		$display("~~~~~~~~~~start~~~~~~~~~~");
		transaction.set_arg(2'b10, 8'bxxxxx100);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);	

		$display("~~~~~~~~~~addr~~~~~~~~~~");
		$display("randomly select read or write");
		assert(trans.randomize());

		if(trans.row == 1) begin
			$display("write: random slave_addr[7:1] %b", trans.data[7:1]);
			$display("~~~~~~~~~~~~~~~~~~~~~~~~");
			w_driver.bl_put(trans);

			transaction.set_arg(2'b10, 8'bxxxxx001);
			w_driver.bl_put(transaction);

			w_driver.wait_for_interrupt();
			w_driver.bl_get(transaction);

			// data
			assert(trans.randomize());
			s_index = trans.index;
			$display("~~~~~~~~~~data~~~~~~~~~~");
			$display("write random number(%d-d times) of random data", s_index);
			$display("~~~~~~~~~~~~~~~~~~~~~~~~");

			for(i = 0; i < s_index; i++) begin
				assert(trans.randomize());
				w_driver.bl_put(trans);

				transaction.set_arg(2'b10, 8'bxxxxx001);
				w_driver.bl_put(transaction);

				w_driver.wait_for_interrupt();
				w_driver.bl_get(transaction);
			end


		end
		else if(trans.row == 0) begin

			$display("read : random slave_addr[7:1] %b", trans.data[7:1]);
			$display("~~~~~~~~~~~~~~~~~~~~~~~~");
			w_driver.bl_put(trans);

			transaction.set_arg(2'b10, 8'bxxxxx001);
			w_driver.bl_put(transaction);

			w_driver.wait_for_interrupt();
			w_driver.bl_get(transaction);				

			// data
			assert(trans.randomize());
			s_index = trans.index;

			$display("~~~~~~~~~~data~~~~~~~~~~");
			$display("read random number(%d times 1-10) of data", s_index + 1);
			$display("~~~~~~~~~~~~~~~~~~~~~~~~");

			for(int i = 0; i < s_index; i++) begin
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

		end

		// stop
		$display("~~~~~~~~~~stop~~~~~~~~~~");
		transaction.set_arg(2'b10,8'bxxxxx101);
		w_driver.bl_put(transaction);

		w_driver.wait_for_interrupt();
		w_driver.bl_get(transaction);
		
	endtask

	virtual function void get_busid(output int bus_num);
		bus_num = this.bus_n;
	endfunction
	
endclass









