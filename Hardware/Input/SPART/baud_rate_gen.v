module baud_rate_gen(
	input clk,
	input rst,
	input [1:0] ioaddr,
	input [7:0] divisor_part,
	output reg rate_en
);	
	parameter LOAD_LOW=4'h0, LOAD_HI=4'h1, CNT=4'h2, EN=4'h3;
	parameter IO_XFER=2'b00, REG_RD=2'b01, LD_DIV_LO=2'b10, LD_DIV_HI=2'b11;
	reg [3:0] state;
	reg [3:0] nxt_state;
	reg [15:0] period_cnt;
	reg [15:0] divisor;
	reg rst_cnt;
	reg div_half_load;

	always @ (posedge clk) begin
		if (rst_cnt) begin
			period_cnt <= divisor;
		end else if (rate_en)
			period_cnt <= divisor;
	  	else
	    period_cnt <= period_cnt - 16'h1;
    end

	always @ (posedge clk or negedge rst) begin
		if(!rst)
			state = LOAD_LOW;
		else
			state = nxt_state;
	end

	always @ (*) begin
		nxt_state = state;
		rate_en = 1'b0;
		rst_cnt = 1'b0;
		case(state)
			/**LOAD: begin
				if(ioaddr == LD_DIV_LO) begin
					divisor[7:0] = divisor_part;
					if(div_half_load == 1'b1) begin
						nxt_state = CNT;
						rst_cnt = 1'b1;
						div_half_load = 1'b0;
					end
					div_half_load = 1'b1;
					nxt_state = LOAD;
				end else if (ioaddr == LD_DIV_HI) begin
					divisor[15:8] = divisor_part;
					if(div_half_load == 1'b1) begin
						nxt_state = CNT;
						div_half_load = 1'b0;
					end
					div_half_load = 1'b1;
					nxt_state = LOAD;
				end
			end**/
			LOAD_LOW: begin
				if(ioaddr == LD_DIV_LO) begin
					divisor[7:0] = divisor_part;
					nxt_state = LOAD_HI;
				end
			end
			LOAD_HI: begin
				if(ioaddr == LD_DIV_HI) begin
					divisor[15:8] = divisor_part;
					rst_cnt = 1'b1;
					nxt_state = CNT;
				end
			end
			CNT: begin
				if(period_cnt == 16'h00)
					nxt_state = EN;
				else	
				nxt_state = CNT;
			end
			EN: begin
				rate_en = 1'b1;
				rst_cnt = 1'b1;
				nxt_state = CNT;
			end
		endcase
	end

endmodule
