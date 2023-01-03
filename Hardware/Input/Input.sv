module Input(
    clk,
    rst,
    KEY,
    GPIO,
    updateInpReg,
    sprOut,
    sprIn,
		timerVal,
		moveChange
);
	input clk;
	input rst;
	input [3:0] KEY;
	input [31:0] sprIn;
	input [1:0] moveChange;
	inout [35:0] GPIO;
	input updateInpReg;
	output logic [31:0] sprOut;
	output logic [31:0] timerVal;

    reg [31:0] inputReg;
	//reg [2:0] inputReg_LO;
	wire [7:0] databus;
	logic [1:0] ioaddr;
	logic rda;
	logic rstTimer;
	
	logic [7:0] rcv_data, databus_out, div_out;
	
	parameter SET_LBR = 4'h0, SET_HBR = 4'h1, RX_DATA = 4'h2;
	
	logic moveDown;
	logic [3:0] state;
	logic [3:0] nxt_state;
	
	logic drive_out;
	logic set_data;
	logic rxd;

	assign rxd = GPIO[5];

	Timer downTimer(
		.clk(clk),
		.rst(rst),
		.rstTimer(rstTimer),
		.moveDown(moveDown),
		.currVal(timerVal)
	);
	
	spart spart0( 
		.clk(clk),
        .rst(rst),
        .rda(rda),
        .ioaddr(ioaddr),
        .databus(databus),
        .rxd(rxd)
	);

	always @(posedge clk, negedge rst) begin
		if(!rst)
			inputReg <= 32'b0;
		else if(updateInpReg == 1'b1) 
			inputReg <= sprIn;
		else if(moveDown) begin
			case(moveChange)
				2'b00: begin
					inputReg[0] <= 1'b1;
				end
				2'b01: begin
					inputReg[1] <= 1'b1;
				end
				default: begin
					inputReg[2] <= 1'b1;
				end
			endcase
		end
		else begin
				if (!KEY[3])
						inputReg[1] <= 1'b1;
				else if (!KEY[2])
						inputReg[0] <= 1'b1;
				else if (!KEY[1])
					inputReg[2] <= 1'b1;
		end
	end

	assign rstTimer = inputReg[0];
    
	
	always @ (posedge clk or negedge rst) begin
		if(!rst)
			state = SET_LBR;
		else
			state = nxt_state;
	end
	
	always @ (posedge clk) begin
		if(set_data)
			databus_out <= rcv_data;
	end
	
	
	always @ (*) begin
		nxt_state = state;
		set_data = 1'b0;
		case(state)
			SET_LBR: begin
				ioaddr = 2'b10;
				drive_out = 1'b1;
                div_out = 8'h8A;
                nxt_state = SET_HBR;
				// else if(br_cfg == 2'b01) begin
				// 	div_out = 8'h45;
				// 	nxt_state = SET_HBR;
				// end
				// else if(br_cfg == 2'b10) begin
				// 	div_out = 8'hA2;
				// 	nxt_state = SET_HBR;
				// end
				// else if(br_cfg == 2'b11) begin
				// 	div_out = 8'h45;
				// 	nxt_state = SET_HBR;
				// end
			end
			SET_HBR: begin
				ioaddr = 2'b11;
				drive_out = 1'b1;
            div_out = 8'h02;
				// else if(br_cfg == 2'b01) begin
				// 	div_out = 8'h01;
				// end
				// else if(br_cfg == 2'b10) begin
				// 	div_out = 8'h00;
				// end
				// else if(br_cfg == 2'b11) begin
				// 	div_out = 8'h01;
				// end
				nxt_state = RX_DATA;
			end
			RX_DATA: begin
				ioaddr = 2'b00;
				rcv_data = databus;
				drive_out = 1'b0;
				//if(rda == 1'b1) begin
					//nxt_state = TX_DATA;
				//end
				//else begin
				nxt_state = state;
				//end
			end
		endcase
	end
	
	assign databus = (drive_out) ? ((ioaddr[1] == 1'b1) ? div_out : databus_out ): 8'bz;
	assign sprOut = inputReg;
	
endmodule
