module Inputneo(
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
	output reg [31:0] sprOut;
	output [31:0] timerVal;

	parameter WAIT = 4'h0, MOV_L = 4'h1, MOV_R = 4'h2, MOV_D = 4'h3, 
              BLOCKED = 4'h4;

	reg right1, left1, down1, left, right, down;
	reg [3:0]   state;
	reg [3:0]   nxt_state;

	reg [31:0]  per_cnt;
    reg         clr_per_cnt;

	reg         set_mv_left;
    reg         set_mv_right;
    reg         set_mv_down;

	wire rst_n; //the reset is actually active low
	assign rst_n = rst;
	
	assign timerVal = per_cnt;
	
	
	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n)
			state = WAIT;
		else
			state = nxt_state;
	end

    always @(*) begin
			right1 <= !KEY[1];
			right <= right1;
			left1 <= !KEY[3];
			left <= left1;
			down1 <= !KEY[2];
			down <= down1;
	end

	always @ (posedge clk or negedge rst_n) begin
		  if (!rst_n) begin
				sprOut <= 32'b0;
		  end else if (set_mv_left) begin
            sprOut[1] <= 1'b1;
        end else if (set_mv_right) begin
            sprOut[2] <= 1'b1;
        end else if (set_mv_down) begin
            sprOut[0] <= 1'b1;
        end else begin
            sprOut[2:0] = 3'b0;
        end

	end  
	
    always @ (posedge clk or negedge rst_n) begin
		if(!rst_n)
            per_cnt = 32'b0;
        else if (clr_per_cnt)
            per_cnt = 32'b0;
        else
            per_cnt = per_cnt + 1'b1;
    end
	
	always @ (*) begin
		nxt_state = state;
		clr_per_cnt = 1'b0;
		set_mv_left = 1'b0;
		set_mv_right = 1'b0;
		set_mv_down = 1'b0;
		
		case(state)
            WAIT: begin
				if(per_cnt == 31'H5FFFFFF) begin
					clr_per_cnt = 1'b1;
					nxt_state = MOV_D;
				end else if (right) begin
					clr_per_cnt = 1'b1;
					nxt_state = MOV_R;
				end else if (left) begin
					clr_per_cnt = 1'b1;
					nxt_state = MOV_L;
				end else begin;
					nxt_state = WAIT;
				end			
			end
			MOV_L : begin
				set_mv_left = 1'b1;
				clr_per_cnt = 1'b1;
				nxt_state = BLOCKED;
			end
			MOV_R : begin
				set_mv_right = 1'b1;
				clr_per_cnt = 1'b1;
				nxt_state = BLOCKED;
			end
			MOV_D :	begin
				set_mv_down = 1'b1;
				clr_per_cnt = 1'b1;
				nxt_state = BLOCKED;
			end
			BLOCKED: begin
				if(per_cnt == 31'H0FFFFFF) begin
					clr_per_cnt = 1'b1;
					nxt_state = WAIT;
				end
			end
		endcase
	end	

	
endmodule
