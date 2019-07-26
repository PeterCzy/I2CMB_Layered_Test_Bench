class wb_transaction_random extends wb_transaction;
	`ncsu_register_object(wb_transaction_random)

	rand bit [1:0] addr_temp;
	rand bit [7:0] data_bus_temp;
	rand bit [6:0] data_row_temp;
	rand bit [7:0] data_temp;
	rand int index_write_temp;
	rand int index_read_temp;
	int state = 0;

	function new(string name = "");
		super.new(name);
	endfunction

	constraint addr_c{
		addr_temp inside {2'b01};

//randomize busId: [0: 15]
		data_bus_temp inside {[0:15]};
		data_row_temp inside {[0:127]};

//randomize how many times to write: [5:10]
		index_write_temp inside {[5:10]};

//		index_read_temp inside {[0:9]};
//------------------------------
//you can only read the data on slave_addr at most 10 times because there are only 10 datas 
//this is set by variables read_data.new [10] in i2cmb_generator - line 61
//at here, there is a posibility to rise fatal erro
//-----------------------------
//randonmize how many time to read: [0:12]
		index_read_temp inside {[0:12]};
	}
	

	function void post_randomize();
		randsequence(main)
			main	: write_s | read_s;
			write_s	:{
					if(state == 0) begin
						addr = 2'b01; 
						data = data_bus_temp;
						state = 1;
					end 
					else if(state == 1) begin
						row = 1; 
						addr = 2'b01; 
						data = {data_row_temp[6:0], 1'b0};
						state = 2;
					end
					else if(state == 2) begin
						index = index_write_temp;
						state = 3;
					end
					else if(state == 3) begin
						addr = 2'b01;
						data = data_temp;
					end
				};
			read_s	:{
					if(state == 0) begin
						addr = 2'b01; 
						data = data_bus_temp;
						state = 1;
					end 
					else if(state == 1) begin
						row = 0; 
						addr = 2'b01; 
						data = {data_row_temp[6:0], 1'b1};
						state = 2;
					end
					else if(state == 2) begin
						index = index_read_temp;
						state = 3;
					end
				};
		endsequence
	endfunction

endclass


















