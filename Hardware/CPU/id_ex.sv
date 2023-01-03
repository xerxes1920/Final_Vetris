module id_ex(instr_in, instr_out, PC_plus_four_in, PC_plus_four_out, PC_plus_imm_in, PC_plus_imm_out,
PC_plus_8_in, PC_plus_8_out, imm_in, imm_out, data_out_1_in, data_out_1_out, data_out_2_in, data_out_2_out,
writeregsel_in, writeregsel_out, aluop_in, aluop_out, isJ_in, isBR_in, isReturn_in, isShift_in, ifGetRow_in, ifSendRow_in,
isMoveOrWriteShape_in, isSpecial_in, isJ_out, isBR_out, isReturn_out, isShift_out, ifGetRow_out, ifSendRow_out,
isMoveOrWriteShape_out, isSpecial_out, isI_in, isI_out, isJAL_in, isJAL_out,
regWrite_in, regWrite_out, clk, rst, flush);

input reg [31:0] instr_in, PC_plus_four_in, PC_plus_imm_in, PC_plus_8_in,
	imm_in, data_out_1_in, data_out_2_in;
input reg [4:0] writeregsel_in;
input reg [3:0] aluop_in;
input reg isJ_in, isBR_in, isReturn_in, isShift_in, ifGetRow_in, ifSendRow_in,
	isMoveOrWriteShape_in, isSpecial_in, clk, rst;
input isI_in, isJAL_in, flush;
input regWrite_in;

output [31:0] instr_out, PC_plus_four_out, PC_plus_imm_out, PC_plus_8_out,
	imm_out, data_out_1_out, data_out_2_out;
output [4:0] writeregsel_out;
output [3:0] aluop_out;
output isJ_out, isBR_out, isReturn_out, isShift_out, ifGetRow_out, ifSendRow_out,
	isMoveOrWriteShape_out, isSpecial_out;
output isI_out, isJAL_out;
output regWrite_out;

reg [31:0] instr_intr, PC_plus_four_intr, PC_plus_imm_intr, PC_plus_8_intr, imm_intr, data_out_1_intr, data_out_2_intr;
reg [4:0] writeregsel_intr;
reg [3:0] aluop_intr;
reg isJ_intr, isBR_intr, isReturn_intr, isShift_intr, ifGetRow_intr, ifSendRow_intr, isMoveOrWriteShape_intr, isSpecial_intr, isI_intr, isJAL_intr, regWrite_intr;

always_ff @(posedge clk, negedge rst) begin
	if(!rst) begin
		instr_intr <= 0;
		PC_plus_four_intr <= 0;
		PC_plus_imm_intr <= 0;
		PC_plus_8_intr <= 0;
		imm_intr <= 0;
		data_out_1_intr <= 0;
		data_out_2_intr <= 0;
		writeregsel_intr <= 0;
		isJ_intr <= 0;
		isBR_intr <= 0;
		isReturn_intr <= 0;
		isShift_intr <= 0;
		ifGetRow_intr <= 0;
		ifSendRow_intr <= 0;
		isMoveOrWriteShape_intr <= 0;
		isSpecial_intr <= 0;
		isI_intr <= 0;
		regWrite_intr <= 0;
		isJAL_intr <= 0;
		aluop_intr <= 0;
	end else begin
		instr_intr <= instr_in;
		PC_plus_four_intr <= PC_plus_four_in;
		PC_plus_imm_intr <= PC_plus_imm_in;
		PC_plus_8_intr <= PC_plus_8_in;
		imm_intr <= imm_in;
		data_out_1_intr <= data_out_1_in;
		data_out_2_intr <= data_out_2_in;
		writeregsel_intr <= writeregsel_in;
		isJ_intr <= isJ_in;
		isBR_intr <= isBR_in;
		isReturn_intr <= isReturn_in;
		isShift_intr <= isShift_in;
		ifGetRow_intr <= ifGetRow_in;
		ifSendRow_intr <= ifSendRow_in;
		isMoveOrWriteShape_intr <= isMoveOrWriteShape_in;
		isSpecial_intr <= isSpecial_in;
		isI_intr <= isI_in;
		regWrite_intr <= regWrite_in;
		isJAL_intr <= isJAL_in;
		aluop_intr <= aluop_in;
	end
end

assign instr_out = flush ? 0 : instr_intr;
assign PC_plus_four_out = flush ? 0 : PC_plus_four_intr;
assign PC_plus_imm_out = flush ? 0 : PC_plus_imm_intr;
assign PC_plus_8_out = flush ? 0 : PC_plus_8_intr;
assign imm_out = flush ? 0 : imm_intr;
assign data_out_1_out = flush ? 0 : data_out_1_intr;
assign data_out_2_out = flush ? 0 : data_out_2_intr;
assign writeregsel_out = flush ? 0 : writeregsel_intr;
assign isJ_out = flush ? 0 : isJ_intr;
assign isBR_out = flush ? 0 : isBR_intr;
assign isReturn_out = flush ? 0 : isReturn_intr;
assign isShift_out = flush ? 0 : isShift_intr;
assign ifGetRow_out = flush ? 0 : ifGetRow_intr;
assign ifSendRow_out = flush ? 0 : ifSendRow_intr;
assign isMoveOrWriteShape_out = flush ? 0 : isMoveOrWriteShape_intr;
assign isSpecial_out = flush ? 0 : isSpecial_intr;
assign isI_out = flush ? 0 : isI_intr;
assign regWrite_out = flush ? 0 : regWrite_intr;
assign isJAL_out = flush ? 0 : isJAL_intr;
assign aluop_out = flush ? 0 : aluop_intr;


endmodule
