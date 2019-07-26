class i2cmb_test_1 extends ncsu_component#(.T(wb_transaction));

	ncsu_component #(T) w_agent;
	wb_transaction transaction;

	int test_flag;
	bit temp;

	covergroup reg_test;
		option.name = "reg_test";
		option.per_instance = 1;
		
		test_flag: coverpoint test_flag{
			bins test1 = {1};
			bins test2 = {2};
		}

		value: coverpoint temp{
			bins zero = {1'b0};
			bins one = {1'b1}; 
		}

		trans: coverpoint temp{
			bins onetozero = (1 => 0);
			bins zerotoone = (0 => 1);
		}

		testcase: cross test_flag, trans{
			bins b1 = binsof(test_flag.test1) && binsof(trans.zerotoone);
			bins b2 = binsof(test_flag.test2) && binsof(trans.onetozero);
		}

	endgroup

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
		reg_test = new;
	endfunction	

	virtual task run();
		
		
		transaction = new("trans");
		test_flag = 0;

		//diable/reset csr
		transaction.set_arg(2'b00, 8'h00);
		w_agent.bl_put(transaction);

		//test 1
		//write 1 to csr[7]
		test_flag = 1;

		w_agent.bl_get_csr(transaction);
		temp = transaction.data[7];
		reg_test.sample();

		transaction.set_arg(2'b00, 8'h80);
		w_agent.bl_put(transaction);

		w_agent.bl_get_csr(transaction);
		temp = transaction.data[7];
		reg_test.sample();

		//test 2
		//write 0 to csr[7]
		test_flag = 2;
		
		w_agent.bl_get_csr(transaction);
		temp = transaction.data[7];
		reg_test.sample();

		transaction.set_arg(2'b00, 8'h00);
		w_agent.bl_put(transaction);

		w_agent.bl_get_csr(transaction);
		temp = transaction.data[7];
		reg_test.sample();

	endtask

	virtual function void set_agent(ncsu_component #(T) w_agent);
    		this.w_agent = w_agent;
  	endfunction

endclass
