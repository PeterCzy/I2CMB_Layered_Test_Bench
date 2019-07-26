`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int I2C_ADDR_WIDTH = 8;
parameter int I2C_DATA_WIDTH = 8;
parameter int NUM_I2C_SLAVES = 1;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
triand  [NUM_I2C_SLAVES-1:0] scl;
triand  [NUM_I2C_SLAVES-1:0] sda;

bit [I2C_DATA_WIDTH-1:0] write_data [];
bit [I2C_DATA_WIDTH-1:0] read_data [];

bit sda_o;
reg scl_o;

// ****************************************************************************
// Clock generator
initial
	begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end

// ****************************************************************************
// Reset generator
initial
	begin
		#113 rst = 1'b0;
	end

// ****************************************************************************
// moniter

initial
	begin
		bit [I2C_ADDR_WIDTH-1:0] addr;
		int op;
		bit [I2C_DATA_WIDTH-1:0] data_out[];
		bit [I2C_DATA_WIDTH-1:0] temp[];

		forever begin
			@(posedge clk) begin
				i2c_bus.monitor(addr, op, data_out);
				if(temp != data_out && data_out.size() != 0) begin
//					$display("time: %0t, addr: %8b, op: %d, data: %u", $time, addr, op, data);
					if(op == 1) begin
						$display("I2C_BUS READ TRANSFER: addr: %8b, data: %u", addr, data_out);
					end
					else if(op == 2) begin
						$display("I2C_BUS WRITE TRANSFER: addr: %8b, data: %u", addr, data_out);
					end
					temp = new [data_out.size()](data_out);
				end
			end
		end
	end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

initial
	begin
		reg [1:0] addr;
		reg [7:0] data;
		reg we_temp;

		@(posedge clk)
		forever begin
			wb_bus.master_monitor(addr, data, we_temp);
			$display("WB_bus: addr: 0x0%x; data: %h",addr, data);
		end
		
	end

// ****************************************************************************
// wait for i2c transfer

initial
	begin
		int op;

		forever begin
			@(posedge clk)	begin
				i2c_bus.wait_for_i2c_transfer(op, write_data);
				if(op == 1) begin
//					$display("time: %0t, READ", $time);
					i2c_bus.provide_read_data(read_data);
				end
			end
		end

	end

// ****************************************************************************
// Define the flow of the simulation
initial test_flow: begin

	reg [7:0] data;

	#500

	wb_bus.master_write(2'b0, 8'b11xxxxxx);			//enable the core
	wb_bus.master_write(2'b01, 8'h01);			//Write byte 0x05 to the DPR. This is the ID of desired I 2 C bus.
	wb_bus.master_write(2'b10, 8'bxxxxx110); 		//Write byte “xxxxx110” to the CMDR. This is Set Bus command.
	while(irq == 1'b0);					//Wait for interrupt or until DON bit of CMDR reads '1'.
	wb_bus.master_read(2'b10, data);	

// ------------------WRITE-------------------//
// START
	wb_bus.master_write(2'b10,8'bxxxxx100); 		//Write byte “xxxxx100” to the CMDR. This is Start command.
	while(irq == 1'b0) @(posedge clk);
	wb_bus.master_read(2'b10, data);
	
// ADDR
	wb_bus.master_write(2'b01, 8'h44); 			//Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b10, 8'bxxxxx001); 		//Write byte “xxxxx001” to the CMDR. This is Write command.
	while(irq == 1'b0) @(posedge clk); 			//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10, data);
	
// DATA
	for(int i = 0; i < 32; i++) begin
		wb_bus.master_write(2'b01, i); 			//Write byte 0x78 to the DPR. This is the byte to be written.
		wb_bus.master_write(2'b10, 8'bxxxxx001);	//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10, data);
	end

// STOP
	wb_bus.master_write(2'b10,8'bxxxxx101);			//Write byte “xxxxx101” to the CMDR. This is Stop command.
	while(irq == 1'b0) @(posedge clk);	
	wb_bus.master_read(2'b10, data);


// ------------------READ-------------------//
// initiate read data 100-131
	read_data = new [32];
	foreach(read_data[i]) begin
		read_data[i] = i + 100;
	end

// START
	wb_bus.master_write(2'b10,8'bxxxxx100); 		//Write byte “xxxxx100” to the CMDR. This is Start command.
	while(irq == 1'b0) @(posedge clk);
	wb_bus.master_read(2'b10, data);

// ADDR
	wb_bus.master_write(2'b01,8'h45); 			//Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b10, 8'bxxxxx001); 		//Write byte “xxxxx001” to the CMDR. This is Write command.
	while(irq == 1'b0) @(posedge clk); 			//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10, data);
// DATA
	for(int i = 0; i < 31; i++) begin
		wb_bus.master_write(2'b10,8'bxxxxx010); 	//Write byte “xxxxx010” to the CMDR. This is read with ACK command
		while(irq == 1'b0) @(posedge clk); 		//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10, data);
		wb_bus.master_read(2'b01, data);		// read dpr
	end
	
	wb_bus.master_write(2'b10, 8'bxxxxx011); 		//Write byte “xxxxx011” to the CMDR. This is read with NACK command
	while(irq == 1'b0) @(posedge clk); 			//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
	wb_bus.master_read(2'b10, data);
	wb_bus.master_read(2'b01, data);			// read dpr


// STOP
	wb_bus.master_write(2'b10, 8'bxxxxx101);		//Write byte “xxxxx101” to the CMDR. This is Stop command.
	while(irq == 1'b0) @(posedge clk);	
	wb_bus.master_read(2'b10, data);


// ------------------altenate write&read-------------------//
	read_data = new [1];

	for(int i = 0; i < 64; i++) begin

// ------------------WRITE-------------------//
// START

		wb_bus.master_write(2'b10, 8'bxxxxx100); 	//Write byte “xxxxx100” to the CMDR. This is Start command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10, data);

	
// ADDR
		wb_bus.master_write(2'b01, 8'h44); 		//Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
		wb_bus.master_write(2'b10, 8'bxxxxx001); 	//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk); 		//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10, data);

// DATA	
		wb_bus.master_write(2'b01, (64 + i)); 		//Write byte 0x78 to the DPR. This is the byte to be written.
		wb_bus.master_write(2'b10, 8'bxxxxx001);	//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10, data);

// STOP
		wb_bus.master_write(2'b10, 8'bxxxxx101);	//Write byte “xxxxx101” to the CMDR. This is Stop command.
		while(irq == 1'b0) @(posedge clk);	
		wb_bus.master_read(2'b10, data);

// ------------------READ-------------------//
// initiate read data 63->0
		read_data[0] = 63 - i;
// START

		wb_bus.master_write(2'b10, 8'bxxxxx100); 	//Write byte “xxxxx100” to the CMDR. This is Start command.
		while(irq == 1'b0) @(posedge clk);
		wb_bus.master_read(2'b10, data);

// ADDR
		wb_bus.master_write(2'b01, 8'h45); 		//Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +rightmost bit = '0', which means writing.
		wb_bus.master_write(2'b10, 8'bxxxxx001); 	//Write byte “xxxxx001” to the CMDR. This is Write command.
		while(irq == 1'b0) @(posedge clk); 		//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10, data);

// DATA
		wb_bus.master_write(2'b10, 8'bxxxxx011); 	//Write byte “xxxxx011” to the CMDR. This is read with nack command
		while(irq == 1'b0) @(posedge clk); 		//Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit is '1', then slave doesn't respond.
		wb_bus.master_read(2'b10, data);
		wb_bus.master_read(2'b01, data);		// read dpr

// STOP
		wb_bus.master_write(2'b10, 8'bxxxxx101);	//Write byte “xxxxx101” to the CMDR. This is Stop command.
		while(irq == 1'b0) @(posedge clk);	
		wb_bus.master_read(2'b10, data);
	end

	$finish;

end


// ****************************************************************************
// Define the flow of the simulation
/*
reg [7:0] dataout;

initial
	begin
		#1200	
//enable: write 1xxxxxxx to the CSR				
			wb_bus.master_write(2'b00, 8'hc0);
		
//write 0x05 to the DPR
		 	wb_bus.master_write(2'b01, 8'h05);

//write xxxxx110 to the CMDR	
			wb_bus.master_write(2'b10, 8'h06);

//wait for the interrupt or DON
			while(irq == 1'b0)@(posedge clk);

			do 
				begin
				wb_bus.master_read(2'b10, dataout);
				end
			while(dataout[7] == 1'b0 && irq == 1'b1);

//write xxxxx100 to the CMDR
			wb_bus.master_write(2'b10, 8'h04);

//wait for the interrupt or DON
			while(irq == 1'b0)@(posedge clk);

			do 
				begin
				wb_bus.master_read(2'b10, dataout);
				end
			while(dataout[7] == 1'b0 && irq == 1'b1);

//write 0x44 to the DPR
			wb_bus.master_write(2'b01, 8'h44);

//write xxxxx001 to the CMDR
			wb_bus.master_write(2'b10, 8'h01);


//wait for the interrupt or DON
			while(irq == 1'b0)@(posedge clk);

			do 
				begin
				wb_bus.master_read(2'b10, dataout);
				end
			while(dataout[7] == 1'b0 && irq == 1'b1);

//write 0x78 to the DPR
			wb_bus.master_write(2'b01, 8'h78);

//write xxxxx001 to the CMDR
			wb_bus.master_write(2'b10, 8'h01);

//wait for the  DON
			while(irq == 1'b0)@(posedge clk);

			do 
				begin
				wb_bus.master_read(2'b10, dataout);
				end
			while(dataout[7] == 1'b0 && irq == 1'b1);

//write byte xxxxx101 to the CMDR
			wb_bus.master_write(2'b10, 8'h05);

//wait for the DON
			while(irq == 1'b0)@(posedge clk);

			do 
				begin
				wb_bus.master_read(2'b10, dataout);
				end
			while(dataout[7] == 1'b0 && irq == 1'b1);

//			$finish;			
			 				
	end
*/
// ****************************************************************************
// test flow
/*
initial
	begin
		read_data = new [32];

		foreach(read_data[i]) begin
			read_data[i] = i + 100;
		end

//write 32 incrementing values from 0 to 31
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);

		start;
		sig_addr_gen(7'b0000000, 1'b0);
		for(int i = 0; i <= 31; i++) begin
			send_byte(i);
		end
		stop;

//read 32 values from 100 to 131
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);

		start;
		sig_addr_gen(7'b0000000, 1'b1);
		read_byte_ack(32);
		stop;

//alternate writes and reads
//writes from 64 to 127
//reads from 63 to 0
		read_data = new [1];		

		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);

		for(int i = 0; i <= 63; i++) begin
			start;
			sig_addr_gen(7'b0000000, 1'b0);
			send_byte(64 + i);
			stop;
			
			read_data[0] = 63 - i;

			start;
			sig_addr_gen(7'b0000000, 1'b1);
			read_byte_ack(1);
			stop;
			
		end

		$finish;
	end

// ****************************************************************************
// connect test flow to bus
//assign sda = sda_o?1'bz:1'b0;
//assign scl = scl_o;

// ****************************************************************************
// task to generate bus signal

// generate start signal
task start;
	@(posedge clk);
	sda_o = 1;
	scl_o = 1;
	@(posedge clk);
	sda_o = 0;
	@(posedge clk);
	scl_o = 0;		
endtask

// address generator
// generate address with 7-bit address and 1-bit r/w
// also combined with checking ack
task sig_addr_gen(
	input bit [6:0] slave_addr,
	input bit rw
);
	repeat(7) begin
		@(posedge clk);
		sda_o = slave_addr[6];
		slave_addr = {slave_addr[5:0], slave_addr[6]};
		@(posedge clk);
		scl_o = 1;
		@(posedge clk);
		@(posedge clk);
		scl_o = 0;
	end
	@(posedge clk);
	sda_o = rw;
	@(posedge clk);
	scl_o = 1;
	@(posedge clk);
	@(posedge clk);
	scl_o = 0;

	@(posedge clk);
	sda_o = 1;
	@(posedge clk);
	scl_o = 1;
	@(posedge clk);
	if(sda != 0) $display("time: %0t, ACK ERROR WITH ADDR", $time);
	@(posedge clk);
	scl_o = 0;
	@(posedge clk);
	sda_o = 0;
	@(posedge clk);	
endtask

// write byte
// send 8-bit to slave
// combined with checking ack
task send_byte(
	input bit [7:0] send_byte
);
	repeat(8) begin
		@(posedge clk);
		sda_o = send_byte[7];
		send_byte = {send_byte[6:0], send_byte[7]};
		@(posedge clk);
		scl_o = 1;
		@(posedge clk);
		@(posedge clk);
		scl_o = 0;
	end
	@(posedge clk);
	sda_o = 1;
	@(posedge clk);
	scl_o = 1;
	@(posedge clk);
	if(sda != 0) $display("time: %0t, ACK ERROR WITH DATA", $time);
	@(posedge clk);
	scl_o = 0;
	@(posedge clk)
	sda_o = 0;
	@(posedge clk);
	
endtask

// read i bytes
// generate desired bus signal to read i bytes from slave
// the last ack op will be nack
task read_byte_ack(
	input int i
);
	repeat(i - 1) begin
		repeat(8) begin
			@(posedge clk);
			sda_o = 1;
			@(posedge clk);
			scl_o = 1;
			@(posedge clk);
			@(posedge clk);
			scl_o = 0;
		end
		
		@(posedge clk);
		sda_o = 0;
		@(posedge clk);
		scl_o = 1;
		@(posedge clk);
		@(posedge clk);
		scl_o = 0;
		sda_o = 1;
		@(posedge clk);
	end

	repeat(8) begin
		@(posedge clk);
		sda_o = 1;
		@(posedge clk);
		scl_o = 1;
		@(posedge clk);
		@(posedge clk);
		scl_o = 0;
	end

	@(posedge clk);
	sda_o = 1;
	@(posedge clk);
	scl_o = 1;
	@(posedge clk);
	@(posedge clk);
	scl_o = 0;
	sda_o = 1;
	@(posedge clk);	
endtask

// read 1 byte
task read_byte;
	repeat(8) begin
		@(posedge clk);
		sda_o = 1;
		@(posedge clk);
		scl_o = 1;
		@(posedge clk);
		@(posedge clk);
		scl_o = 0;
	end
endtask

// ack signal followed read_1_byte
task read_ack(
	input bit ack
);
	@(posedge clk);
	sda_o = ack;
	@(posedge clk);
	scl_o = 1;
	@(posedge clk);
	@(posedge clk);
	scl_o = 0;
	sda_o = 1;
	@(posedge clk);
	
endtask

// generate stop signal
task stop;
	@(posedge clk);
	sda_o = 0;
	@(posedge clk);
	scl_o = 1;
	@(posedge clk);
	sda_o = 1;
	@(posedge clk);
	scl_o = 1;
endtask
*/


// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );
	
// ****************************************************************************
// Instantiate the I2C Model
i2c_if #(
	.I2C_DATA_WIDTH(8),
	.I2C_ADDR_WIDTH(8)
) i2c_bus
(
	.scl(scl),
	.sda(sda)
);

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:sim:/top/DUT/scl_i

    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule
