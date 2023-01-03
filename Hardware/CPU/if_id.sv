module if_id(instr_in, instr_out, PC_plus_four_in, PC_plus_four_out, clk, rst, IF_ID_Write, flush);

input reg [31:0] instr_in, PC_plus_four_in;
//input reg clk, rst;
input flush, clk, rst;
input IF_ID_Write;

output [31:0] instr_out, PC_plus_four_out;

reg [31:0] instr_intr, PC_plus_four_intr;

always_ff @(posedge clk, negedge rst) begin
	if(!rst) begin
		instr_intr <= 0;
		PC_plus_four_intr <= 0;
	end else if(IF_ID_Write) begin
		instr_intr <= instr_in;
		PC_plus_four_intr <= PC_plus_four_in;
	end
end

assign instr_out = (flush) ? 32'hFFFFFFFF : instr_intr;
assign PC_plus_four_out = (flush) ? 0 : PC_plus_four_intr;

endmodule
