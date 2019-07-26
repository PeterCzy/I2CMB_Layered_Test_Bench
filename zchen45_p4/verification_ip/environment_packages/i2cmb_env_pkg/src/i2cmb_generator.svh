class i2cmb_generator extends ncsu_component#(.T(wb_transaction));

	wb_transaction transaction;
	i2c_transaction i_transaction;
	i2c_transaction i_transaction_read;
	ncsu_component #(T) w_agent;
	ncsu_component #(i2c_transaction) i_agent;
	string trans_name;

	i2cmb_test_1 test_1;
	int bus_n;

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction

	virtual task run();
		reg [7:0] data;

		transaction = new("trans");
		i_transaction = new("i_trans");
		i_transaction_read = new("i_trans_read");

		fork 

		begin: wb

// *******************************************************************************
// initiation
			w_agent.init();
// *******************************************************************************
// write  32 values
			w_agent.write_32();

// ******************************************************************************
// read 32 values
// init read out data
			i_transaction_read.read_data = new [32];
			foreach(i_transaction_read.read_data[i]) begin
				i_transaction_read.read_data[i] = i + 100;
			end

			w_agent.read_32();

// ****************************************************************************
// alternate write & read

//			$display("***************************************alternate write & read***************************************");
			//init read out data
			i_transaction_read.read_data = new [1];


			for(int i = 0; i < 64; i++) begin
				w_agent.write(64+i);

				i_transaction_read.read_data[0] = 63 - i;
				w_agent.read();		
			end

// **************************************************************************************
// random test
			i_transaction_read.read_data = new [10];
			foreach(i_transaction_read.read_data[i]) begin
				i_transaction_read.read_data[i] = i + 10;
			end

			w_agent.rand_test();			
		
		end


		begin: i2c
		
			int op;

			forever begin
				i_agent.bl_get(i_transaction);
				if(i_transaction.op == 1) begin
					i_agent.bl_put(i_transaction_read);
				end
			end		

		end		

		join_any

		$finish;

	endtask

  	virtual function void set_agent(ncsu_component #(T) w_agent, ncsu_component #(i2c_transaction) i_agent);
    		this.w_agent = w_agent;
		this.i_agent = i_agent;
		$display("generator agent set!");
  	endfunction

endclass



