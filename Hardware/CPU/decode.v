module decode(instr, pc_plus_4_in, writedata, in_reg_data, pc_plus_imm, imm,
data_out_1, data_out_2, line_status_in, writeregsel_in, writeregsel_out,
isSpecial, isBranch, isR, RegWrite, clk, rst, pc_plus_8, isReturn, isJAL, isMoveOrWriteShape);

input [31:0] instr, pc_plus_4_in, writedata, in_reg_data, line_status_in;
input [4:0] writeregsel_in;
input clk, rst, isSpecial, isBranch, isR, isMoveOrWriteShape, RegWrite;

// ADDED
input isReturn, isJAL;
output [31:0] pc_plus_8;

output [31:0] pc_plus_imm, imm, data_out_1, data_out_2;
output [4:0] writeregsel_out;

wire [31:0] r_se, i_se, b_se, j_se, b_or_j_se, read1data, read2data;
wire rt_is_8, rs_is_8, read1_ir, read2_ir;
wire [4:0] writeregsel, read1regsel;

// TODO reg module needs to be instantiated
rf REG0(.read1data(read1data), .read2data(read2data), .err(), .clk(clk), .rst(rst),
.read1regsel(read1regsel), .read2regsel(instr[20:16]), .writeregsel(writeregsel_in), .writedata(writedata),
	    .write(RegWrite), .line_status_in(line_status_in), .input_right(), .input_left(), .input_down());

// read1RegSel input mux
assign read1regsel =  isReturn ? 5'd31 : instr[25:21];

assign r_se = { {21{instr[10]}}, instr[10:6] }; // UPDATED FOR SHAMT
assign i_se = { {16{instr[15]}}, instr[15:0] };
assign b_se = { {16{instr[15]}}, instr[15:0] };
assign j_se = { pc_plus_4_in[31:28], 2'b00, instr[25:0] };

assign b_or_j_se = isBranch ? b_se : j_se;
assign imm = isR ? r_se : i_se;

assign pc_plus_imm = isBranch ? pc_plus_4_in + b_or_j_se : b_or_j_se;

assign read1_ir = ((instr[25:21] == 8) | (isSpecial == 1)) ? 1 : 0;
assign read2_ir = (instr[20:16] == 8) ? 1 : 0;

assign data_out_1 = read1_ir ? in_reg_data : (writeregsel_in == read1regsel) ? writedata : read1data;
assign data_out_2 = read2_ir ? in_reg_data : (writeregsel_in == instr[20:16]) ? writedata : read2data;

// First writeRegSel mux (UPDATED)
assign writeregsel = isR ? instr[15:11] : instr[20:16];

// Second writeRegSel mux for JAL and Move/write shape instrs (ADDED)
assign writeregsel_out = isMoveOrWriteShape ? 5'd8 : isJAL ? 5'd31 : writeregsel;

// isReturn adder (PC + 8)
assign pc_plus_8 = pc_plus_4_in;

endmodule
