module execute(data1, data_mem_wb, data_ex_mem, data2, line_data, return_val,
pc_plus_4, pc_plus_imm, imm_in, pc_out, alu_out, spec_reg_data,
opcode, fwdA, fwdB, isBR, isI, isJ, isReturn, isMoveOrWriteShape, clk, rst, isShift, EX_branch_out,
alu_op
);

input [31:0] data1, data_mem_wb, data_ex_mem, data2,
pc_plus_4, pc_plus_imm, imm_in, line_data, return_val;
input [5:0] opcode;
input clk, rst;

// Control signals (from ID/EX)
input isI, isShift, isBR, isJ, isReturn, isMoveOrWriteShape;
input [3:0] alu_op;
input [1:0] fwdA, fwdB; // From forwarding unit

output [31:0] pc_out, alu_out, spec_reg_data;
output EX_branch_out;

wire [31:0] in1, in2, imm_or_in2, plus_imm_or_4, real_in1;
wire zeroF, negF, eqF, br_cond_met, br_good, br_or_j;

alu ALU0(.in1(real_in1), .in2(imm_or_in2), .result(alu_out), .alu_op(alu_op), .zeroF(zeroF), .negF(negF), .eqF(eqF));
br_logic_unit BR0(.zeroF(zeroF), .negF(negF), .eqF(eqF), .opcode(opcode), .br_cond_met(br_cond_met));

// forwarding muxes
assign in1 = (fwdA == 0) ? data_mem_wb : (fwdA == 1) ? data_ex_mem : (fwdA == 3) ? line_data : data1;
assign in2 = (fwdB == 0) ? data_mem_wb : (fwdB == 1) ? data_ex_mem : (fwdB == 3) ? line_data : data2;

// choosing between data from reg or immediate val
assign imm_or_in2 = (isI) ? imm_in : in2;

// choosing between data from regular reg or input reg
assign real_in1 = (isMoveOrWriteShape) ? data1 : (isShift) ? imm_in : in1;

// branch/jump/return logic
assign br_good = br_cond_met & isBR;
assign br_or_j = br_good | isJ;
assign plus_imm_or_4 = br_or_j ? pc_plus_imm : pc_plus_4;
assign pc_out = isReturn ? return_val : plus_imm_or_4;

// special register assignment
assign spec_reg_data = imm_or_in2;

assign EX_branch_out = br_good;

endmodule
