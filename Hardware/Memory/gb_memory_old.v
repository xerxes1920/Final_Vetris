module gb_memory_old(
    input           clk,
    input           rst_n,
    input [31:0]    addr,
    input [31:0]    data_in,
    input           enable,
    input           wr,

    input  [31:0]   instr,
    input  [3:0]    x_pos,
    input  [5:0]    y_pos,
    input  [1:0]    shape,
    input  [4:0]    get_line_num,
    output [31:0]   data_out,
    output [31:0]   line_status_out,
    output [31:0]   row_status_out
);

parameter SQUARE_SHAPE = 2'b10;
parameter LINE_SHAPE = 2'b01;

integer j;
integer k;

reg     [2:0]       gb_mem [0:199];
wire                line_status [0:19];
wire    [31:0]      dout_gmem;
wire                remove_line;
wire                move_left;
wire                move_right;
wire                move_down;
wire				new_shape;
wire                getrow;
wire    [15:0]      rm_line_num;

assign dout_gmem = {29'b0, gb_mem[addr[7:0]] };

assign remove_line = instr[31:26] == 6'b011101; //to be changed
assign move_left = instr[31:26] == 6'b011010;
assign move_right = instr[31:26] == 6'b011011;
assign move_down = instr[31:26] == 6'b011100;
assign new_shape = instr[31:26] == 6'b011001;
assign getrow = instr[31:26] == 6'b011111;
assign rm_line_num = instr[15:0];

always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (j = 0; j < 20 ; j = j + 1) begin
                for(k = 0; k < 10 ; k = k + 1) begin
                    gb_mem[j*10 + k] = 3'b0;
                end
            end
        end else if(remove_line && (rm_line_num < 16'h14)) begin
            for (j = 0; j < 19 ; j = j + 1) begin
                if (j >= rm_line_num) begin
                    for(k = 0; k < 10 ; k = k + 1) begin
                        gb_mem[j*10 + k] = gb_mem[(j+1)*10 + k];
                    end
                end
            end
        end else if(move_left) begin
            if(shape == SQUARE_SHAPE) begin
                gb_mem[x_pos+y_pos*10 - 1] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos+1)*10 - 1] <= SQUARE_SHAPE;
                gb_mem[x_pos+y_pos*10 + 1] <= 3'b0;
                gb_mem[x_pos+(y_pos+1)*10 + 1] <= 3'b0;
            end
            if(shape == LINE_SHAPE) begin
                gb_mem[x_pos+y_pos*10 - 1] <= gb_mem[x_pos+y_pos*10];
                gb_mem[x_pos+(y_pos+1)*10 - 1] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+2)*10 - 1] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+3)*10 - 1] <= LINE_SHAPE;
                gb_mem[x_pos+y_pos*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+1)*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+2)*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+3)*10] <= 3'b0;
            end
        end else if(move_right) begin
            if(shape == SQUARE_SHAPE) begin
                gb_mem[x_pos+y_pos*10 + 2] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos+1)*10 + 2]<= SQUARE_SHAPE;
                gb_mem[x_pos+y_pos*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+1)*10] <= 3'b0;
            end
            if(shape == LINE_SHAPE) begin
                gb_mem[x_pos+y_pos*10 + 1] <= gb_mem[x_pos+y_pos*10];
                gb_mem[x_pos+(y_pos+1)*10 + 1] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+2)*10 + 1] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+3)*10 + 1] <= LINE_SHAPE;
                gb_mem[x_pos+y_pos*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+1)*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+2)*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+3)*10] <= 3'b0;
            end
        end else if(move_down) begin
            if(shape == SQUARE_SHAPE) begin
                gb_mem[x_pos+(y_pos-1)*10] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos-1)*10 + 1] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos+1)*10] <= 3'b0;
                gb_mem[x_pos+(y_pos+1)*10 + 1] <= 3'b0;
            end
            if(shape == LINE_SHAPE) begin
                gb_mem[x_pos+(y_pos-1)*10] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+3)*10] <= 3'b0;
            end
        end else if (new_shape) begin
             if(data_in[1:0] == SQUARE_SHAPE) begin
                gb_mem[x_pos+(y_pos)*10] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos)*10 + 1] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos+1)*10] <= SQUARE_SHAPE;
                gb_mem[x_pos+(y_pos+1)*10 + 1] <= SQUARE_SHAPE;
            end
            if(data_in[1:0] == LINE_SHAPE) begin
                gb_mem[x_pos+y_pos*10] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+1)*10] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+2)*10] <= LINE_SHAPE;
                gb_mem[x_pos+(y_pos+3)*10] <= LINE_SHAPE;
            end
        end else if (enable & wr & (addr < 32'hC9)) begin
	            gb_mem[addr] <= data_in[2:0];       // The actual write
    end
end

assign line_status_out = {12'b0, line_status[19], line_status[18], line_status[17], line_status[16], line_status[15], line_status[14], line_status[13], line_status[12], line_status[11], line_status[10], line_status[9], line_status[8], line_status[7], line_status[6], line_status[5], line_status[4], line_status[3], line_status[2], line_status[1], line_status[0]};
assign row_status_out = {22'b0, (|gb_mem[get_line_num*10+0]), (|gb_mem[get_line_num*10+1]), (|gb_mem[get_line_num*10+2]), (|gb_mem[get_line_num*10+3]), (|gb_mem[get_line_num*10+4]), (|gb_mem[get_line_num*10+5]), (|gb_mem[get_line_num*10+6]), (|gb_mem[get_line_num*10+7]), (|gb_mem[get_line_num*10+8]), (|gb_mem[get_line_num*10+9])};
assign data_out = {2'b0, gb_mem[get_line_num*10+0], gb_mem[get_line_num*10+1], gb_mem[get_line_num*10+2], gb_mem[get_line_num*10+3], gb_mem[get_line_num*10+4], gb_mem[get_line_num*10+5], gb_mem[get_line_num*10+6], gb_mem[get_line_num*10+7], gb_mem[get_line_num*10+8], gb_mem[get_line_num*10+9]};
genvar i;
generate
    for (i = 0; i < 20 ; i = i + 1 ) begin : line_status_gen
        assign line_status[i] = (|gb_mem[i*10+0]) & (|gb_mem[i*10+1]) & (|gb_mem[i*10+2]) & (|gb_mem[i*10+3]) & (|gb_mem[i*10+4]) & (|gb_mem[i*10+5]) & (|gb_mem[i*10+6]) & (|gb_mem[i*10+7]) & (|gb_mem[i*10+8]) & (|gb_mem[i*10+9]);
    end
endgenerate



//sdram control statemachine to be finished
endmodule
