module mem_reg_test();

    parameter NEW_SHAPE0 = 4'h0, MOV_L0 = 4'h1, DOWN0 = 4'h2, WAIT = 4'h3, 
              MOV_R0 = 4'h4, UPDATE=4'hF;
    
    parameter SQUARE_SHAPE = 2'b00;
    parameter LINE_SHAPE = 2'b01;

    parameter  REMOVE_LINE = 6'b011101, MOV_LEFT = 6'b011010, MOV_RIGHT = 6'b011011,
              MOV_DOWN = 6'b011100, NEW_SHAPE = 6'b011001, GET_ROW = 6'b011111;

	reg clk;
	reg rst;

	reg [3:0]   state;
	reg [3:0]   nxt_state;
    reg [3:0]   nxt_state_nxt;

    reg [3:0]   shape_cnt;
    reg [4:0]   row_cnt;
    reg [31:0]  per_cnt;

    reg         clr_shape_cnt;
    reg         clr_per_cnt;
    reg         clr_row_cnt;
    reg         inc_shape_cnt;
    reg         inc_row_cnt;

    reg         set_rm_line;
    reg         set_mv_left;
    reg         set_mv_right;
    reg         set_mv_down;
    reg         set_new_shape;
    reg         set_send_row;


    wire [31:0]  idata, line_status, row_status;
    reg [4:0]   index;
    reg [5:0]   instr_op;
    reg [1:0]   shape;
    reg [4:0]   x_pos, y_pos, x_pos_nxt, y_pos_nxt;
    reg [15:0]  rm_line_num;

    always @ (posedge clk or posedge rst) begin
		if(rst)
            shape_cnt = 4'b0;
        else if (inc_shape_cnt)
            shape_cnt = shape_cnt + 1;
        else if (clr_shape_cnt)
            shape_cnt = 4'b0;
    end

    always @ (posedge clk or posedge rst) begin
		if(rst)
            per_cnt = 32'b0;
        else if (clr_per_cnt)
            per_cnt = 32'b0;
        else
            per_cnt = per_cnt + 1;
    end

    always @ (posedge clk or posedge rst) begin
		if(rst)
            row_cnt = 5'b0;
        else if (inc_row_cnt)
            row_cnt = row_cnt + 1;
        else if (clr_row_cnt)
            row_cnt = 5'b0;
    end

	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			index = 5'b11111;
            instr_op = 6'b0;
            x_pos = 5'b0;
            x_pos_nxt = 5'b0;
            y_pos = 5'b0;
            y_pos_nxt = 5'b0;
            rm_line_num = 16'b0;
            shape = SQUARE_SHAPE;
        end
		else if (set_rm_line) begin
            instr_op = REMOVE_LINE; 
        end else if (set_mv_left) begin
            instr_op = MOV_LEFT;
            x_pos_nxt = x_pos_nxt - 1'b1;
            y_pos_nxt = y_pos_nxt;
        end else if (set_mv_right) begin
            instr_op = MOV_RIGHT;
            x_pos_nxt = x_pos_nxt + 1'b1;
            y_pos_nxt = y_pos_nxt;
        end else if (set_mv_down) begin
            instr_op = MOV_DOWN;
            x_pos_nxt = x_pos_nxt;
            y_pos_nxt = y_pos_nxt - 1'b1;
        end else if (set_new_shape) begin
            instr_op = NEW_SHAPE;
            x_pos = 5'h5;
            y_pos = 5'h10;
            x_pos_nxt = 5'h5;
            y_pos_nxt = 5'h10;
        end else if (set_send_row) begin 
            instr_op = GET_ROW;
            index = row_cnt;
        end else begin
            instr_op = 6'b0;
            index = 5'b11111;
            y_pos = y_pos_nxt;
            x_pos = x_pos_nxt;
        end

	end    

    always @ (posedge clk or posedge rst) begin
		if(rst)
			state = NEW_SHAPE0;
		else
			state = nxt_state;
	end    

	gb_memory memory_inst( .clk(clk),
                    .rst(rst),
                    .data_in(32'b0),
                    .addr(32'b0),
                    .enable(1'b0),
                    .wr(1'b0), 
                    .instr({instr_op, 10'b0, rm_line_num}),
                    .x_pos(x_pos),
                    .y_pos(y_pos),
                    .shape(shape),
                    .get_line_num(row_cnt),
                    .data_out(idata),
                    .line_status_out(line_status),
                    .row_status_out(row_status));
					  
	//mem_tb_clk clk_inst(
	//						.refclk(clock_ref),
	//						.rst(1'b0),
	//						.outclk_0(clk)
	//);
	
	
	always @ (*) begin
		nxt_state = state;
		set_new_shape = 1'b0;
        clr_shape_cnt = 1'b0;
        clr_per_cnt = 1'b0;
        clr_row_cnt = 1'b0;
        inc_shape_cnt = 1'b0;
        inc_row_cnt = 1'b0;

        set_rm_line = 1'b0;
        set_mv_left = 1'b0;
        set_mv_right = 1'b0;
        set_mv_down = 1'b0;
        set_new_shape = 1'b0;
        set_send_row = 1'b0;
		case(state)
			NEW_SHAPE0: begin
                set_new_shape = 1'b1;
                inc_shape_cnt = 1'b1;
                clr_row_cnt = 1'b1;
                nxt_state = UPDATE;
                nxt_state_nxt = MOV_L0;
			end
			MOV_L0: begin
                set_mv_left = 1'b1;
                nxt_state = UPDATE;
                nxt_state_nxt = DOWN0;
			end
			DOWN0: begin
                set_mv_down = 1'b1;
                nxt_state = UPDATE;
                nxt_state_nxt = WAIT;
			end
            WAIT: begin
                nxt_state = WAIT;
            end
			UPDATE: begin
                set_send_row = 1'b1;
                if (row_cnt != 5'h14) begin
                    inc_row_cnt = 1'b1;
                    clr_per_cnt = 1'b1;
                end else if(per_cnt == 31'h3)
                    nxt_state = nxt_state_nxt;
			end
		endcase
	end
	


initial begin
        clk = 0;
	   forever begin
	     #5 clk = ~clk;
	   end
end

initial begin 
		rst = 1'b0;
		#20 rst = 1'b1;
        #20 rst = 1'b0;
	end

endmodule 

