class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

	ncsu_component#(T) scoreboard;
	T transport_trans;
	T trans_in;

	int t = 0;


	covergroup pred_state_trans;
		option.name = "pred_state_trans";
		option.per_instance = 1;

		state_pred: coverpoint t{
			bins idle = {0};
			bins addr = {1};
			bins data = {2};
		}

		state_pred_trans: coverpoint t{
			bins idle_to_addr = (0 => 1);
			bins addr_to_data = (1 => 2);
			bins data_to_idle = (2 => 0);

			illegal_bins idle_to_data = (0 => 2);
			illegal_bins addr_to_idle = (1 => 0);
			illegal_bins data_to_addr = (2 => 1); 
		}

	endgroup


	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
		trans_in = new("trans_in");
		pred_state_trans = new;
	endfunction

  	virtual function void nb_put(T trans);
		pred_state_trans.sample();

// ************************decode the input transaction**********************
		if(t == 2 && trans.addr == 2'b01) begin					//t = 2, data			
			this.trans_in.data_pred = {this.trans_in.data_pred, this.trans.data};
		end
		else if(t == 2 && trans.addr == 2'b10 && trans.data == 8'h05) begin

			t = 0;
			trans_in.bus_id = trans.bus_id;
			scoreboard.nb_transport(trans_in, transport_trans);

			trans_in = new("trans_in");
		end

		else if(t == 1 && trans.addr == 2'b01) begin				// t = 1, addr
			if(trans.data[0] == 1'b0) begin					// it's write
				this.trans_in.op_pred = 2;
				this.trans_in.addr_pred = trans.data;	
				t = 2;
			end
			else if(trans.data[0] == 1'b1) begin				// it's read
				this.trans_in.op_pred = 1;						
				this.trans_in.addr_pred = trans.data;
				t = 2;
			end
		end

		else if(t == 0 && trans.addr == 2'b10 && trans.data == 8'h04) begin		//t = 0, idle
			t = 1;
		end
		
		this.trans_in.addr = trans.addr;
		this.trans_in.data = trans.data;

  	endfunction

  	virtual function void set_scoreboard(ncsu_component #(T) scoreboard);
      		this.scoreboard = scoreboard;
  	endfunction

endclass
