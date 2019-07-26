interface i2c_if       #(
    int I2C_DATA_WIDTH = 8,
    int I2C_ADDR_WIDTH = 8
      )
(// System sigals
    input logic [15:0] scl,
    inout logic [15:0] sda
);

//op
// 0 - wait
// 1 - read
// 2 - write

int state;
// states for slave task
// 0 - wait for start
// 1 - addr
// 3 - write data
int seq;
// states for monitor
// 0 - wait for start
// 1 - addr
// 3 - collect data

int addr_slave_low = 4, addr_slave_high = 9;

bit sda_o = 1;
int stop, check_stop;
int check_start = 1;
int nack;
int bus_n, bus_m;


	typedef enum bit [1:0] {idle, load_addr, load_data} state_t;
	state_t i2c_state;

	covergroup i2c_state_cg;
		option.name = "i2c_state_cg";
		option.per_instance = 1;
			
		i2c_state: coverpoint i2c_state{
			bins idle = {idle};
			bins load_addr = {load_addr};
			bins load_data = {load_data};
		}

		i2c_state_trans: coverpoint i2c_state{
			bins idle_to_addr = (idle => load_addr);
			bins addr_to_data = (load_addr => load_data);
			bins data_to_idle = (load_data => idle);

			illegal_bins idle_to_data = (idle => load_data);
			illegal_bins addr_to_idle = (load_addr => idle);
			illegal_bins data_to_addr = (load_data => load_addr);
		}

	endgroup

	i2c_state_cg i2c_state_ch = new();

	assign sda[0] = sda_o?1'bz:1'b0;
	assign sda[1] = sda_o?1'bz:1'b0;
	assign sda[2] = sda_o?1'bz:1'b0;
	assign sda[3] = sda_o?1'bz:1'b0;
	assign sda[4] = sda_o?1'bz:1'b0;
	assign sda[5] = sda_o?1'bz:1'b0;
	assign sda[6] = sda_o?1'bz:1'b0;
	assign sda[7] = sda_o?1'bz:1'b0;
	assign sda[8] = sda_o?1'bz:1'b0;
	assign sda[9] = sda_o?1'bz:1'b0;
	assign sda[10] = sda_o?1'bz:1'b0;
	assign sda[11] = sda_o?1'bz:1'b0;
	assign sda[12] = sda_o?1'bz:1'b0;
	assign sda[13] = sda_o?1'bz:1'b0;
	assign sda[14] = sda_o?1'bz:1'b0;
	assign sda[15] = sda_o?1'bz:1'b0;

	always@(posedge sda[bus_n]) begin
		if(scl[bus_n] == 1 && check_stop == 1) begin
			stop = 1;
			state = 0;
			check_stop = 0;
			check_start = 1;
			seq = 0;
		end
	end

// *****************************************************************************
	task set_bus(input int bus_num);
//		bus_n = bus_num;
//		bus_n = 15 - bus_n;
//		$display("*****************i2c_if setbus: %d *****************", bus_n);
	endtask

// *****************************************************************************
	task wait_for_i2c_transfer (
		output int op,
		output bit [I2C_DATA_WIDTH-1:0] write_data []
	);
				
		reg [I2C_DATA_WIDTH-1:0] addr_slave;
		int size;
		int count;
			
		if(state == 0 && check_start == 1) begin
			addr_slave = 0;
		
			fork
				begin: bus15
					@(negedge sda[0]) begin
						if(scl[0] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 0;
						end
					end
				end

				begin: bus14
					@(negedge sda[1]) begin
						if(scl[1] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 1;
						end
					end
				end

				begin: bus13
					@(negedge sda[2]) begin
						if(scl[2] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 2;
						end
					end
				end

				begin: bus12
					@(negedge sda[3]) begin
						if(scl[3] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 3;
						end
					end
				end

				begin: bus11
					@(negedge sda[4]) begin
						if(scl[4] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 4;
						end
					end
				end

				begin: bus10
					@(negedge sda[5]) begin
						if(scl[5] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 5;
						end
					end
				end

				begin: bus9
					@(negedge sda[6]) begin
						if(scl[6] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 6;
						end
					end
				end

				begin: bus8
					@(negedge sda[7]) begin
						if(scl[7] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 7;
						end
					end
				end

				begin: bus7
					@(negedge sda[8]) begin
						if(scl[8] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 8;
						end
					end
				end

				begin: bus6
					@(negedge sda[9]) begin
						if(scl[9] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 9;
						end
					end
				end

				begin: bus5
					@(negedge sda[10]) begin
						if(scl[10] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 10;
						end
					end
				end

				begin: bus4
					@(negedge sda[11]) begin
						if(scl[11] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 11;
						end
					end
				end

				begin: bus3
					@(negedge sda[12]) begin
						if(scl[12] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 12;
						end
					end
				end

				begin: bus2
					@(negedge sda[13]) begin
						if(scl[13] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 13;
						end
					end
				end

				begin: bus1
					@(negedge sda[14]) begin
						if(scl[14] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 14;
						end
					end
				end

				begin: bus0
					@(negedge sda[15]) begin
						if(scl[15] == 1) begin
							state = 1;
							stop = 0;
							nack = 0;
							check_start = 0;
							bus_n = 15;
						end
					end
				end

			join_any;
			disable fork;
		end

		else if(state == 1) begin
			sda_o = 1;

			for(int i = 0; i <= 7; i++) begin
				@(posedge scl[bus_n]) begin
					addr_slave[7 - i] = sda[bus_n];
				end
			end

			@(negedge scl[bus_n]) begin
				sda_o = 0;
			end

			state = 3;

		end

		if(addr_slave[0] == 1) begin
			op = 1;
			state = 0;
			return;
		end
		else begin
			op = 2;

		end

		if(state == 3 && op == 2 && stop == 0) begin
			@(negedge scl[bus_n]) begin	//ack second part
				sda_o = 1;
			end

			size = write_data.size();
			write_data = new [size + 1](write_data);

			for(int i = 0; i <= 7; i++) begin
				@(posedge scl[bus_n] or stop) begin
					write_data[size][7 - i] = sda[bus_n];
					if(stop == 1) begin
						write_data = new [size](write_data);
						return;
					end
				end
			end

			@(negedge scl[bus_n]) begin	//ack first part
				sda_o = 0;
			end

			check_stop = 1;
		end


	endtask

// *****************************************************************************
	task provide_read_data (
		input bit [I2C_DATA_WIDTH-1:0] read_data []
	);
		int size;
		bit [7:0] read_data_temp;

		size = read_data.size();

		if(stop == 0 && nack == 0) begin
			for(int i = 0; i < size ; i++) begin
				read_data_temp = read_data[i];

				for(int j = 0; j < 8; j++) begin
					@(negedge scl[bus_n]) begin
						sda_o = read_data_temp[7 - j];
					end
				end

				@(negedge scl[bus_n]) begin
					sda_o = 1;
				end

				@(posedge scl[bus_n]) begin
					if(sda[bus_n] == 1) begin
						nack = 1;

						@(posedge scl[bus_n]);
						check_start = 1;
					end
				end

				check_stop = 1;
			end
		end
		
	endtask

// *****************************************************************************
	task monitor (	
		output bit [I2C_ADDR_WIDTH-1:0] addr, 
		output int op,	
		output bit [I2C_DATA_WIDTH-1:0] data[],
		output int bus_m
	);

		int size;

		if(seq == 0) begin
			data = new [0];
			addr = 0;

			i2c_state = idle;
			i2c_state_ch.sample();

			fork 
				begin: m15
					@(negedge sda[0]) begin
						if(scl[0] == 1) begin
							seq = 1;
							bus_m = 0;
						end
					end
				end

				begin: m14
					@(negedge sda[1]) begin
						if(scl[1] == 1) begin
							seq = 1;
							bus_m = 1;
						end
					end
				end

				begin: m13
					@(negedge sda[2]) begin
						if(scl[2] == 1) begin
							seq = 1;
							bus_m = 2;
						end
					end
				end

				begin: m12
					@(negedge sda[3]) begin
						if(scl[3] == 1) begin
							seq = 1;
							bus_m = 3;
						end
					end
				end

				begin: m11
					@(negedge sda[4]) begin
						if(scl[4] == 1) begin
							seq = 1;
							bus_m = 4;
						end
					end
				end

				begin: m10
					@(negedge sda[5]) begin
						if(scl[5] == 1) begin
							seq = 1;
							bus_m = 5;
						end
					end
				end

				begin: m9
					@(negedge sda[6]) begin
						if(scl[6] == 1) begin
							seq = 1;
							bus_m = 6;
						end
					end
				end

				begin: m8
					@(negedge sda[7]) begin
						if(scl[7] == 1) begin
							seq = 1;
							bus_m = 7;
						end
					end
				end

				begin: m7
					@(negedge sda[8]) begin
						if(scl[8] == 1) begin
							seq = 1;
							bus_m = 8;
						end
					end
				end

				begin: m6
					@(negedge sda[9]) begin
						if(scl[9] == 1) begin
							seq = 1;
							bus_m = 9;
						end
					end
				end

				begin: m5
					@(negedge sda[10]) begin
						if(scl[10] == 1) begin
							seq = 1;
							bus_m = 10;
						end
					end
				end

				begin: m4
					@(negedge sda[11]) begin
						if(scl[11] == 1) begin
							seq = 1;
							bus_m = 11;
						end
					end
				end

				begin: m3
					@(negedge sda[12]) begin
						if(scl[12] == 1) begin
							seq = 1;
							bus_m = 12;
						end
					end
				end

				begin: m2
					@(negedge sda[13]) begin
						if(scl[13] == 1) begin
							seq = 1;
							bus_m = 3;
						end
					end
				end

				begin: m1
					@(negedge sda[14]) begin
						if(scl[14] == 1) begin
							seq = 1;
							bus_m = 14;
						end
					end
				end

				begin: m0
					@(negedge sda[15]) begin
						if(scl[15] == 1) begin
							seq = 1;
							bus_m = 15;
						end
					end
				end

			join_any;
			disable fork;
		end
		else if(seq == 1) begin

			i2c_state = load_addr;
			i2c_state_ch.sample();

			for(int i = 0; i <= 7; i++) begin
				@(posedge scl[bus_m]) begin
					addr[7 - i] = sda[bus_m];
				end
			end

			if(addr[0] == 1) begin
				op = 1;
			end
			else begin
				op = 2;
			end

			seq = 2;
			
		end
		else if(seq == 2) begin

			i2c_state = load_data;
			i2c_state_ch.sample();

			@(posedge scl[bus_m]);

			size = data.size();
			data = new [size + 1](data);

			for(int i = 0; i <= 7; i++) begin
				@(posedge scl[bus_m] or stop) begin
					data[size][7 - i] = sda[bus_m];
					if(stop == 1) begin
						data = new [size](data);
						return;
					end
				end
			end

		end

	endtask

endinterface


















