module alu(in1, in2, result, alu_op, zeroF, negF, eqF);

localparam WIDTH = 32;
localparam MSB = WIDTH - 1;

input [31:0] in1, in2;
input [3:0] alu_op;

output reg [31:0] result;
output zeroF, negF, eqF;

wire lt;
wire [31:0] n_in2;

wire [3:0] x_pos, x_pos_1, x_pos_1_line, x_pos_1_square, x_pos_neg_1;
wire [5:0] y_pos, y_pos_1;
wire [31:0] shift_left, shift_right, alu_and, alu_or, alu_xor, alu_nor, exp, slt;

wire [WIDTH-1:0] sum;
wire sum_extra;
wire sum_overflow;
wire sum_underflow;

wire [WIDTH-1:0] diff;
wire diff_extra;
wire diff_overflow;
wire diff_underflow;

logic [31:0] move_left, move_down, move_right, write_shp;

always @ (alu_op or in1 or in2)
begin
	case (alu_op)
		4'b0000 : result <= shift_left;
		4'b0001 : result <= shift_right;
		4'b0010 : result <= sum;
		4'b0011 : result <= diff;
		4'b0100 : result <= alu_and;
		4'b0101 : result <= alu_or;
		4'b0110 : result <= alu_xor;
		4'b0111 : result <= alu_nor;
		4'b1000 : result <= slt;
		4'b1001 : result <= exp;
		4'b1010 : result <= move_right;
		4'b1011 : result <= move_left;
		4'b1100 : result <= move_down;
		4'b1101 : result <= write_shp;
		default : result <= 32'h0FFFFFFF;
	endcase
end

assign shift_left = in2 << in1;
assign shift_right = in2 >> in1;
assign alu_and = in1 & in2;
assign alu_or = in1 | in2;
assign alu_xor = in1 ^ in2;
assign alu_nor = ~alu_or;
assign exp = 2**in1;

// input register operations (until logic)
assign x_pos = in1[6:3];
assign y_pos = in1[12:7];

assign x_pos_1_line = (x_pos == 4'd9) ? 4'd9 : x_pos + 1 ;
assign x_pos_1_square = (x_pos == 4'd8) ? 4'd8 : x_pos + 1 ;
assign x_pos_1 = (in1[14:13] == 2'b01) ? x_pos_1_line : (in1[14:13] == 2'b10) ? x_pos_1_square : 4'b0;
assign x_pos_neg_1 = (x_pos == 4'd0) ? 4'b0 : x_pos - 1;
assign y_pos_1 = (y_pos == 6'b0) ? 6'b0 : y_pos - 1;

assign move_right = {in1[31:7], x_pos_1, 3'b000};
assign move_left = {in1[31:7], x_pos_neg_1, 3'b000};
assign move_down = (y_pos_1 == 6'b0) ? {in1[31:15], ~in1[14:13], 6'b010000, 4'b0101, 3'b000} : {in1[31:13], y_pos_1, in1[6:3], 3'b000};
assign write_shp = {in1[31:15], in2[1:0], 6'b010000, 4'b0101, 3'b000};

// taken from https://stackoverflow.com/questions/24586842/signed-multiplication-overflow-detection-in-verilog/24587824#24587824
//always @* begin
assign {sum_extra, sum} = {in1[MSB], in1} + {in2[MSB], in2};
assign sum_overflow = ({sum_extra, sum[MSB]} == 2'b01);
assign sum_underflow = ({sum_extra, sum[MSB]} == 2'b10);
//end

assign n_in2 = ~in2;

//always @* begin
assign {diff_extra, diff} = {in1[MSB], in1} - {in2[MSB], in2};
assign diff_overflow = ({diff_extra, diff[MSB]} == 2'b01);
assign diff_underflow = ({diff_extra, diff[MSB]} == 2'b10);
//end

assign lt = (((diff[31] == 1'b1) & (diff_overflow == 1'b0)) | ((diff[31] == 1'b0) & (diff_underflow == 1'b1)));
assign zero = (diff == 0);

assign slt = lt ? 1 : 0;
assign zeroF = (in1 == 0) ? 1 : 0;
assign negF = (in1[31] == 1'b1) ? 1 : 0;
assign eqF = (in1 == in2) ? 1 : 0;

endmodule
