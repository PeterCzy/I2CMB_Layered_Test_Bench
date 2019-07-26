class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

	bit [1:0] addr;
	bit [7:0] data;
	bit we;
	bit [7:0] r_data;
	bit [3:0] mbyte_s;
	bit [3:0] mbit_s;
	bit [7:0] cmd;

	covergroup addr_data_cg;
		option.name = "addr_data_cg";
		option.per_instance = 1;

		addr: coverpoint addr{
			bins csr = {2'b00};
			bins dpr = {2'b01};
			bins cmdr = {2'b10};
		}

		w_data: coverpoint data{
			bins csr = {8'hc0};
			bins dpr = {8'h01, 8'h44, [0:31], 8'h45, [64:127]};
			bins cmdr = {8'h06, 8'h04, 8'h01, 8'h05, 8'h02, 8'h03};
		}

		r_data: coverpoint r_data{
			bins cmdr = {8'h16, 8'h81, 8'h85, 8'h84, 8'h82, 8'h83};
		}


		csr_addr_x_data: cross addr, w_data{
			ignore_bins ignore = 	binsof(addr.csr) && !binsof(w_data.csr) ||
						!binsof(addr.csr) && binsof(w_data.csr) ||
						!binsof(addr.csr) && !binsof(w_data.csr);
		}

		dpr_addr_x_data: cross addr, w_data{
			ignore_bins ignore = 	binsof(addr.dpr) && !binsof(w_data.dpr) ||
						!binsof(addr.dpr) && binsof(w_data.dpr) ||
						!binsof(addr.dpr) && !binsof(w_data.dpr);
		}

		w_cmdr_addr_x_data: cross addr, w_data{
			ignore_bins ignore = 	binsof(addr.cmdr) && !binsof(w_data.cmdr) ||
						!binsof(addr.cmdr) && binsof(w_data.cmdr) ||
						!binsof(addr.cmdr) && !binsof(w_data.cmdr);
		}

		r_cmdr_addr_x_data: cross addr, r_data{
			ignore_bins ignore = !binsof(addr.cmdr) && binsof(r_data.cmdr);
		}

	endgroup

	covergroup mbyte_fsm;
		option.name = "mbyte_fsm";
		option.per_instance = 1;

		mbyte_cmd: coverpoint cmd{
			bins start = {8'h04};
			bins stop = {8'h05};
			bins read_ack = {8'h02};
			bins read_nack = {8'h03};
			bins write = {8'h01};
			bins set_bus = {8'h06};
			bins cmd_wait = {8'h00};
		}

		mbyte_state: coverpoint mbyte_s{
			bins s_idle = {4'h0};
			bins s_bus_taken = {4'h1};
			bins s_start_pending = {4'h2};
			bins s_start = {4'h3};
			bins s_stop = {4'h4};
			bins s_write = {4'h5};
			bins s_read = {4'h6};
			bins s_wait = {4'h7};
		}

		mbyte_state_trans: coverpoint mbyte_s{

			bins idle_to_idle = (4'h0 => 4'h0);
			bins idle_to_wait = (4'h0 => 4'h7);
			bins idle_to_startpending = (4'h0 => 4'h2);
			bins startpending_to_start = (4'h2 => 4'h3);
			bins start_to_idle = (4'h3 => 4'h0);
			bins start_to_bustaken = (4'h3 => 4'h1);
			bins bustaken_to_start = (4'h1 => 4'h3);
			bins bustaken_to_write = (4'h1 => 4'h5);
			bins bustaken_to_stop = (4'h1 => 4'h4);
			bins bustaken_to_read = (4'h1 => 4'h6);
			bins bustaken_to_bustaken = (4'h1 => 4'h1);
			bins write_to_idle = (4'h5 => 4'h0);
			bins write_to_write = (4'h5 => 4'h5);
			bins wirte_to_bustaken = (4'h5 => 4'h1);
			bins stop_to_idle = (4'h4 => 4'h0);
			bins read_to_bustaken = (4'h6 => 4'h1);
			bins read_to_read = (4'h6 => 4'h6);
			bins read_to_idle = (4'h6 => 4'h0);
			bins wait_to_idle = (4'h7 => 4'h0);

			bins idle_to_start = (4'h0 => 4'h3);

		}
		
	endgroup

	covergroup mbit_fsm;
		option.name = "mbit_fsm";
		option.per_instance = 1;

		mbit_cmd: coverpoint cmd{
			bins start 	= {8'h04};
			bins write_0_1 	= {8'h01};
			bins read 	= {8'h02, 8'h03};
			bins stop 	= {8'h05};

		}

		mbit_state: coverpoint mbit_s{
      			bins s_idle      = {4'h0};
      			bins s_start_a   = {4'h1};
    			bins s_start_b   = {4'h2};
      			bins s_start_c   = {4'h3};
      			bins s_rw_a      = {4'h4};
      			bins s_rw_b      = {4'h5};
      			bins s_rw_c      = {4'h6};
      			bins s_rw_d      = {4'h7};
      			bins s_rw_e      = {4'h8};
      			bins s_stop_a    = {4'h9};
      			bins s_stop_b    = {4'ha};
      			bins s_stop_c    = {4'hb};
      			bins s_rstart_a  = {4'hc};
      			bins s_rstart_b  = {4'hd};
      			bins s_rstart_c  = {4'he};
		}
		
		mbit_state_trans: coverpoint mbit_s{
			bins idle_to_starta 	= (4'h0 => 4'h1);
			bins starta_to_startb 	= (4'h1 => 4'h2);
			bins startb_to_startc 	= (4'h2 => 4'h3);
			bins startc_to_startc 	= (4'h3 => 4'h3);
			bins startc_to_stopa 	= (4'h3 => 4'h9);
			bins startc_to_rwa 	= (4'h3 => 4'h4);
			bins stopa_to_stopb 	= (4'h9 => 4'ha);
			bins stopb_to_stopc 	= (4'ha => 4'hb);
			bins stopc_to_idle 	= (4'hb => 4'h0);
			bins rwa_to_rwb 	= (4'h4 => 4'h5);
			bins rwb_to_rwc 	= (4'h5 => 4'h6);
			bins rwc_to_rwd 	= (4'h6 => 4'h7);
			bins rwc_to_idle 	= (4'h6 => 4'h0);
			bins rwd_to_rwe 	= (4'h7 => 4'h8);
			bins rwe_to_rwa 	= (4'h8 => 4'h4);
			bins rwe_to_stopa 	= (4'h8 => 4'h9);
			bins rwe_to_rstarta 	= (4'h8 => 4'hc);
			bins rstarta_to_rstartb	= (4'hc => 4'hd);
			bins rstartb_to_rstartc	= (4'hd => 4'he);
			bins restartc_to_starta = (4'he => 4'h1);
			bins restartc_to_idle 	= (4'he => 4'h0);
		}

		mbit_state_jump_trans: coverpoint mbit_s{
			bins starta_to_startc 	= (4'h1 => 4'h3);
			bins rwa_to_rwe 	= (4'h4 => 4'h8);
			bins stopa_to_idle	= (4'h9 => 4'h0);

			bins rwa_to_idle	= (4'h4 => 4'h0);
			bins rwe_to_starta	= (4'h8 => 4'h1);
			bins rwe_to_idle	= (4'h8 => 4'h0);
		}
	
	endgroup

	function new(string name = "", ncsu_component #(T) parent = null); 
		super.new(name,parent);
		addr_data_cg = new;
		mbyte_fsm = new;
		mbit_fsm = new;
	endfunction	

	virtual function void nb_put(T trans);
		addr = trans.addr;
		data = trans.data;
		we = trans.we;

		if(we == 1'b0) begin
			r_data = trans.data;
		end

		if(addr == 2'b10) begin
			cmd = trans.data;
		end

		if(addr == 2'b11) begin
			mbyte_s = data[7:4];
			mbit_s = data[3:0];
		end

		addr_data_cg.sample();
		mbyte_fsm.sample();
		mbit_fsm.sample();
	endfunction

endclass
