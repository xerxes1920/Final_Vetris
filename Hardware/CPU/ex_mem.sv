module ex_mem(instr_in, instr_out, input_reg_in, input_reg_out,
 spec_reg_data_in, spec_reg_data_out, alu_in, alu_out, PC_plus_8_in, PC_plus_8_out, writeregsel_in,
 writeregsel_out, ifGetRow_in, ifSendRow_in, isSpecial_in, isMoveOrWriteShape_in,
 ifGetRow_out, ifSendRow_out, isSpecial_out, isMoveOrWriteShape_out,
 regWrite_in, regWrite_out, isJAL_in, isJAL_out, isI_in, isI_out, clk, rst);

input reg [31:0] instr_in, input_reg_in, spec_reg_data_in, alu_in, PC_plus_8_in;
input reg [4:0] writeregsel_in;
input reg ifGetRow_in, ifSendRow_in, isSpecial_in, isMoveOrWriteShape_in, clk, rst;
input regWrite_in, isJAL_in, isI_in;

output reg [31:0] instr_out, input_reg_out, spec_reg_data_out, alu_out, PC_plus_8_out;
output reg [4:0] writeregsel_out;
output reg ifGetRow_out, ifSendRow_out, isSpecial_out, isMoveOrWriteShape_out;
output reg regWrite_out, isJAL_out, isI_out;


always_ff @(posedge clk, negedge rst) begin
	if(!rst) begin
		instr_out <= 0;
		input_reg_out <= 0;
		spec_reg_data_out <= 0;
		alu_out <= 0;
    PC_plus_8_out <= 0;
		writeregsel_out <= 0;
    ifGetRow_out <= 0;
    ifSendRow_out <= 0;
    isSpecial_out <= 0;
    isMoveOrWriteShape_out <= 0;
	  regWrite_out <= 0;
    isJAL_out <= 0;
    isI_out <= 0;
	end else begin
		instr_out <= instr_in;
		input_reg_out <= input_reg_in;
		spec_reg_data_out <= spec_reg_data_in;
		alu_out <= alu_in;
    PC_plus_8_out <= PC_plus_8_in;
		writeregsel_out <= writeregsel_in;
    ifGetRow_out <= ifGetRow_in;
    ifSendRow_out <= ifSendRow_in;
    isSpecial_out <= isSpecial_in;
    isMoveOrWriteShape_out <= isMoveOrWriteShape_in;
	  regWrite_out <= regWrite_in;
    isJAL_out <= isJAL_in;
    isI_out <= isI_in;
	end
end


endmodule
