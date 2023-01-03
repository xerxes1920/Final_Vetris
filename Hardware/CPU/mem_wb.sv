module mem_wb(data_in, data_out, line_status_in,
line_status_out, row_data_in, row_data_out, PC_plus_8_in, PC_plus_8_out, writeregsel_in, writeregsel_out,
index_data_in, index_data_out, ifSendRow_in, isMoveOrWriteShape_in,
ifSendRow_out, isMoveOrWriteShape_out,
regWrite_in, regWrite_out, instr_in, instr_out,
input_reg_update_in, input_reg_update_out, isJAL_in, isJAL_out, isI_in, isI_out, clk, rst);

input reg [31:0] data_in, line_status_in, row_data_in, PC_plus_8_in;
input reg [4:0] writeregsel_in, index_data_in;
input reg ifSendRow_in, isMoveOrWriteShape_in, clk, rst;
input regWrite_in, isJAL_in, isI_in;
input [31:0] instr_in, input_reg_update_in;

output reg [31:0] data_out, line_status_out, row_data_out, PC_plus_8_out;
output reg [4:0] writeregsel_out, index_data_out;
output reg ifSendRow_out, isMoveOrWriteShape_out;
output reg regWrite_out, isJAL_out, isI_out;
output reg [31:0] instr_out, input_reg_update_out;

always_ff @(posedge clk, negedge rst) begin
	if(!rst) begin
		data_out <= 0;
		line_status_out <= 0;
		row_data_out <= 0;
		PC_plus_8_out <= 0;
		writeregsel_out <= 0;
		index_data_out <= 0;
		ifSendRow_out <= 0;
		isMoveOrWriteShape_out <= 0;
		regWrite_out <= 0;
		instr_out <= 0;
		input_reg_update_out <= 0;
		isJAL_out <= 0;
		isI_out <= 0;
	end else begin
		data_out <= data_in;
		line_status_out <= line_status_in;
		row_data_out <= row_data_in;
		PC_plus_8_out <= PC_plus_8_in;
		writeregsel_out <= writeregsel_in;
		index_data_out <= index_data_in;
		ifSendRow_out <= ifSendRow_in;
		isMoveOrWriteShape_out <= isMoveOrWriteShape_in;
		regWrite_out <= regWrite_in;
		instr_out <= instr_in;
		input_reg_update_out <= input_reg_update_in;
		isJAL_out <= isJAL_in;
		isI_out <= isI_in;
	end
end


endmodule
