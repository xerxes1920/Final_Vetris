//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    //output iocs,
    //output reg iorw,
    input rda,
    //input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus
    );
	
	reg [7:0] rcv_data, databus_out, div_out;
	
	parameter SET_LBR = 4'h0, SET_HBR = 4'h1, RX_DATA = 4'h2, TX_DATA = 4'h3;
	
	reg [3:0] state;
	reg [3:0] nxt_state;
	
	reg drive_out;
	reg set_data;
	
	always @ (posedge clk or posedge rst) begin
		if(rst)
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
				if(br_cfg == 2'b00) begin
					div_out = 8'h8A;
					nxt_state = SET_HBR;
				end
				else if(br_cfg == 2'b01) begin
					div_out = 8'h45;
					nxt_state = SET_HBR;
				end
				else if(br_cfg == 2'b10) begin
					div_out = 8'hA2;
					nxt_state = SET_HBR;
				end
				else if(br_cfg == 2'b11) begin
					div_out = 8'h45;
					nxt_state = SET_HBR;
				end
			end
			SET_HBR: begin
				ioaddr = 2'b11;
				drive_out = 1'b1;
				if(br_cfg == 2'b00) begin
					div_out = 8'h02;
				end
				else if(br_cfg == 2'b01) begin
					div_out = 8'h01;
				end
				else if(br_cfg == 2'b10) begin
					div_out = 8'h00;
				end
				else if(br_cfg == 2'b11) begin
					div_out = 8'h01;
				end
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
			/*TX_DATA: begin
				ioaddr = 2'b00;
				iorw = 1'b0;
				set_data = 1'b1;
				drive_out = 1'b1;
				//if(tbr == 1'b1) begin
				nxt_state = RX_DATA;
					//iorw = 1'b1;
					//databus_out = 8'b0;
				//end
				//else begin
				//	nxt_state = state;
				//end
			end*/
		endcase
	end
	
	assign databus = (drive_out) ? ((ioaddr[1] == 1'b1) ? div_out : databus_out ): 8'bz;
	
endmodule
