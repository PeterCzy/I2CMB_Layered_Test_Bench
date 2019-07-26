interface wb_if       #(
      int ADDR_WIDTH = 32,                                
      int DATA_WIDTH = 16                                
      )
(
  // System sigals
  input wire clk_i,
  input wire rst_i,
  input wire irq_i,
  // Master signals
  output reg cyc_o,
  output reg stb_o,
  input wire ack_i,
  output reg [ADDR_WIDTH-1:0] adr_o,
  output reg we_o,
  // Slave signals
  input wire cyc_i,
  input wire stb_i,
  output reg ack_o,
  input wire [ADDR_WIDTH-1:0] adr_i,
  input wire we_i,
  // Shred signals
  output reg [DATA_WIDTH-1:0] dat_o,
  input wire [DATA_WIDTH-1:0] dat_i
  );

//*****************************************************************************
//command and related mbyte state transition
	
//write 04 - start command to cmdr reg when idle or bustaken state 
//lead to mbyte state: startpending or start 
	property wrtie_cmdr_04start;
		@(posedge clk_i) 	
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h04 && we_o == 1) |=> 
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h3 && we_o == 0) ||  
			(adr_o == 2'b11 && dat_i[7:4] == 4'h2 && we_o == 0);
	endproperty

//write 06 - set_bus command to cmdr reg when idle or bustaken state
//lead to idle or bustaken state
	property write_cmdr_06setbus;
		@(posedge clk_i)
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h06 && we_o == 1) |=>
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h0 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[7:4] == 4'h1 && we_o == 0);
	endproperty

//write 01 - write command to cmdr reg when bustaken or idle state
//lead to write or idle state
	property write_cmdr_01write;
		@(posedge clk_i)
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h01 && we_o == 1) |=>
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h5 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[7:4] == 4'h0 && we_o == 0);
	endproperty

//write 02 - ack command to cmdr reg when bustaken or idle state  
//lead to read or idle state
	property write_cmdr_02ack;
		@(posedge clk_i)
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h02 && we_o == 1) |=>
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h6 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[7:4] == 4'h0 && we_o == 0);
	endproperty

//write 03 - nack command to cmdr reg when bustaken or idle state  
//lead to read or idle state
	property write_cmdr_03nack;
		@(posedge clk_i)
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h03 && we_o == 1) |=>
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h6 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[7:4] == 4'h0 && we_o == 0);
	endproperty

//write 05 - stop command to cmdr reg when bustaken or idle state  
//lead to stop or idle state
	property write_cmdr_05stop;
		@(posedge clk_i)
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h05 && we_o == 1) |=>
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h4 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[7:4] == 4'h0 && we_o == 0);
	endproperty

//write 00 - wait command to cmdr reg when idle or bustaken state  
//lead to wait or bustaken state
	property write_cmdr_00wait;
		@(posedge clk_i)
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h00 && we_o == 1) |=>
		##3 	(adr_o == 2'b11 && dat_i[7:4] == 4'h7 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[7:4] == 4'h1 && we_o == 0);
	endproperty


	assert property(wrtie_cmdr_04start) else $error("ERROR: wrtie_cmdr_04start");
	assert property(write_cmdr_06setbus) else $error("ERROR: write_cmdr_06setbus");
	assert property(write_cmdr_01write) else $error("ERROR: write_cmdr_01write");
	assert property(write_cmdr_02ack) else $error("ERROR: write_cmdr_02ack");
	assert property(write_cmdr_03nack) else $error("ERROR: write_cmdr_03nack");
	assert property(write_cmdr_05stop) else $error("ERROR: write_cmdr_05stop");
	assert property(write_cmdr_00wait) else $error("ERROR: write_cmdr_00wait");

	cover property(wrtie_cmdr_04start);
	cover property(write_cmdr_06setbus);
	cover property(write_cmdr_01write);
	cover property(write_cmdr_02ack);
	cover property(write_cmdr_03nack);
	cover property(write_cmdr_05stop);
	cover property(write_cmdr_00wait);


//*****************************************************************************
//command and related mbit state transition

//write 04 - start command to cmdr reg
//3 condition:
//rw_e -> rstarta; idle -> starta; startc->starc
//one other special case: idle -> idle, mbyte still in startpending and doesn't send start cmd to mbit 
	property wrtie_cmdr_04start_mbit;
		@(posedge clk_i) 	
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h04 && we_o == 1) |=> 
		##3 	(adr_o == 2'b11 && dat_i[3:0] == 4'h12 && we_o == 0) ||  
			(adr_o == 2'b11 && dat_i[3:0] == 4'h1 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[3:0] == 4'h3 && we_o == 0) ||
			(adr_o == 2'b11 && dat_i[3:0] == 4'h0 && we_o == 0);
	endproperty

//write 01 - write command to cmdr reg
//3 condition:
//rw_e -> rw_a; idle -> idle; startc -> rw_a 
	property wrtie_cmdr_01write_mbit;
		@(posedge clk_i) 	
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h01 && we_o == 1) |=> 
		##3 	(adr_o == 2'b11 && dat_i[3:0] == 4'h4 && we_o == 0) ||  
			(adr_o == 2'b11 && dat_i[3:0] == 4'h0 && we_o == 0);
	endproperty

//write 02 - ack command to cmdr reg
//3 condition:
//rw_e -> rw_a; idle -> idle; startc -> rw_a
	property wrtie_cmdr_02ack_mbit;
		@(posedge clk_i) 	
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h02 && we_o == 1) |=> 
		##3 	(adr_o == 2'b11 && dat_i[3:0] == 4'h4 && we_o == 0) ||  
			(adr_o == 2'b11 && dat_i[3:0] == 4'h0 && we_o == 0);
	endproperty

//write 03 - nack command to cmdr reg
//3 condition:
//rw_e -> rw_a; idle -> idle; startc -> rw_a
	property wrtie_cmdr_03nack_mbit;
		@(posedge clk_i) 	
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h03 && we_o == 1) |=> 
		##3 	(adr_o == 2'b11 && dat_i[3:0] == 4'h4 && we_o == 0) ||  
			(adr_o == 2'b11 && dat_i[3:0] == 4'h0 && we_o == 0);
	endproperty

//write 05 - stop command to cmdr reg
//3 condition:
//rw_e -> stopa; idle -> idle; startc -> stopa
	property wrtie_cmdr_05stop_mbit;
		@(posedge clk_i) 	
		($rose(ack_i) && adr_o == 2'b10 && dat_o == 8'h05 && we_o == 1) |=> 
		##3 	(adr_o == 2'b11 && dat_i[3:0] == 4'h9 && we_o == 0) ||  
			(adr_o == 2'b11 && dat_i[3:0] == 4'h0 && we_o == 0);
	endproperty


	assert property(wrtie_cmdr_04start_mbit) else $error("ERROR: wrtie_cmdr_04start_mbit");
	assert property(wrtie_cmdr_01write_mbit) else $error("ERROR: wrtie_cmdr_01write_mbit");
	assert property(wrtie_cmdr_02ack_mbit) else $error("ERROR: wrtie_cmdr_02ack_mbit");
	assert property(wrtie_cmdr_03nack_mbit) else $error("ERROR: wrtie_cmdr_03nack_mbit");
	assert property(wrtie_cmdr_05stop_mbit) else $error("ERROR: wrtie_cmdr_05stop_mbit");

	cover property(wrtie_cmdr_04start_mbit);
	cover property(wrtie_cmdr_01write_mbit);
	cover property(wrtie_cmdr_02ack_mbit);
	cover property(wrtie_cmdr_03nack_mbit);
	cover property(wrtie_cmdr_05stop_mbit);

//**********************************************************
//verify the correctness of writing to DPR and CMDR register



  initial reset_bus();
// **************************************
	task wait_for_pos_clk();
		wait(clk_i == 1'b1);
	endtask

// ****************************************************************************              
   task wait_for_reset();
       if (rst_i !== 0) @(negedge rst_i);
   endtask

// ****************************************************************************              
   task wait_for_num_clocks(int num_clocks);
       repeat (num_clocks) @(posedge clk_i);
   endtask

// ****************************************************************************              
   task wait_for_interrupt();
       wait(irq_i == 1'b1);
   endtask

// ****************************************************************************              
   task reset_bus();
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        we_o <= 1'b0;
        adr_o <= 'b0;
        dat_o <= 'b0;
   endtask

// ****************************************************************************              
  task master_write(
                   input bit [ADDR_WIDTH-1:0]  addr,
                   input bit [DATA_WIDTH-1:0]  data
                   );  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= data;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b1;
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        @(posedge clk_i);

endtask        

// ****************************************************************************              
task master_read(
                 input bit [ADDR_WIDTH-1:0]  addr,
                 output bit [DATA_WIDTH-1:0] data
                 );                                                  

        @(posedge clk_i);
        adr_o <= addr;
        dat_o <= 'bx;
        cyc_o <= 1'b1;
        stb_o <= 1'b1;
        we_o <= 1'b0;
        @(posedge clk_i);
        while (!ack_i) @(posedge clk_i);
        cyc_o <= 1'b0;
        stb_o <= 1'b0;
        adr_o <= 'bx;
        dat_o <= 'bx;
        we_o <= 1'b0;
        data = dat_i;

endtask        

// ****************************************************************************              
     task master_monitor(
                   output bit [ADDR_WIDTH-1:0] addr,
                   output bit [DATA_WIDTH-1:0] data,
                   output bit we                    
                  );
                         
          while (!cyc_o) @(posedge clk_i);                                                  
          while (!ack_i) @(posedge clk_i);
          addr = adr_o;
          we = we_o;
          if (we_o) begin
            data = dat_o;
          end else begin
            data = dat_i;
          end
          while (cyc_o) @(posedge clk_i);                                                  
     endtask
 

endinterface
