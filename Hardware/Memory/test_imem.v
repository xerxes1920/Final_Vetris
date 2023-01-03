module test_imem(address, clock, data, rden, wren, q);

	input [10:0] address;
  input clock;
  input [31:0] data;
  input rden;
  input wren;
	output reg [31:0] q;

	reg [31:0] instructions [255:0];

	initial begin
		$readmemb("instruction.mem", instructions);
	end

	always @ (address) begin
		q = instructions[address];
	end

endmodule
