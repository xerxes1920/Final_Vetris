module testbench(

);

parameter WAIT = 1'b0, DONE = 1'b1;

wire txd_0, txd_1, iocs, rda_0, rda_1, tbr_0, tbr_1, rate_en, iorw_1;
wire [1:0] br_cfg, ioaddr_1;
wire [7:0] databus_0, databus_1, bus_control_data, bus2tx, databus_recv;

reg clk, rst, rxd_0, iorw;
reg [7:0] dataout;
reg [1:0] ioaddr_0;

reg state, nxt_state;


spart spart0(   .clk(clk),
				.rst(rst),
				.iocs(iocs),
				.iorw(iorw),
				.rda(rda_0),
				.tbr(tbr_0),
				.ioaddr(ioaddr_0),
				.databus(databus_0),
				.txd(txd_0),
				.rxd(txd_1)
			);
			
spart spart1(   .clk(clk),
				.rst(rst),
				.iocs(iocs),
				.iorw(iorw_1),
				.rda(rda_1),
				.tbr(tbr_1),
				.ioaddr(ioaddr_1),
				.databus(databus_1),
				.txd(txd_1),
				.rxd(txd_0)
			);
			
driver driver0( .clk(clk),
                .rst(rst),
                .br_cfg(2'b00),
                .iocs(iocs),
                .iorw(iorw_1),
                .rda(rda_1),
                .tbr(tbr_1),
                .ioaddr(ioaddr_1),
                .databus(databus_1)
            );
			
/**tx tx0(   .clk(clk),
		  .rst(rst),
		  .iocs(iocs),
		  .iorw(iorw),
		  .ioaddr(ioaddr),
		  .txd(txd),
		  .tbr(tbr),
		  .rate_en(rate_en),
		  .tx_ack(bus_control_data),
		  .bus2tx(bus2tx));**/
	
	//assign br_cfg = 2'b01;
	//assign iorw = (tbr_0 == 1'b1) ? 1'b1 : 1'b0;
	
	//TX SM
	
	always @ (posedge clk or posedge rst) begin
		if(rst)
			state = WAIT;
		else
			state = nxt_state;
	end
	
	always@(*) begin
		//Set defaults
		nxt_state = state;
		iorw = 1'b1;
		case (state)
		  WAIT: begin
		    if (tbr_0 == 1'b1)
			  nxt_state = DONE;
		    else
				iorw = 1'b0;
		  end
		  DONE : begin
		  //iorw = 1'b0;
		  end
		endcase
	end		
	
	
	//assign ioaddr = 2'b10;
	//assign bus2tx = 2h'80;
	//assign rate_en = 1'b1;
	
    initial begin 
		clk = 0;
		forever begin
		#5 clk = ~clk;
		end
	end
	
	initial begin 
		state = WAIT;
		rst = 1'b1;
		ioaddr_0 = 2'b10;
		//ioaddr_1 = 2'b10;
		dataout = 8'bz;
		#20 rst = 1'b0;
		dataout = 8'h8A;
		#10 ioaddr_0 = 2'b11;
		//ioaddr_1 = 2'b11;
		dataout = 8'h02;
		#10 ioaddr_0 = 2'b00;
		//ioaddr_1 = 2'b00;
		dataout = 8'h61;
		#100 dataout = 8'h50;
		
	end
	
	assign databus_0 = (iorw == 1'b0) ? dataout : 8'bz;
	//assign databus_1 = (ioaddr_1 == 2'b00) ? 8'bz : dataout;
	//assign databus_recv = databus;
	
	/**always @(*) begin
		dataout = databus;
	end**/
	
	/**initial begin
		rst = 1'b1;
		rxd = 1'b1;
		#30 rst = 1'b0;
		#30 rxd = 1'b0;
		#10 rxd = 1'b1;
		#30 rxd = 1'b0;
		#10 rxd = 1'b1;
		#20 rxd = 1'b0;
		#10 rxd = 1'b1;
		#10 rxd = 1'b0;
		#10 rxd = 1'b1;
		
	end**/


endmodule