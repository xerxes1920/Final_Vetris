module inst_fetch (
    // Inputs
    clk, rst, BR_J_PC, ID_EX_isJump, EX_branch_out, ID_EX_isReturn,
    PCWrite, imem_enable, imem_wr,
    // Outputs
    instr, PC_plus_four, flush, PC_out
);

// Inputs
input clk, rst;
input [31:0] BR_J_PC;

input ID_EX_isJump; // used for PC_mux_sel and flushing
input EX_branch_out;
input ID_EX_isReturn;

// Outputs
output [31:0] instr, PC_plus_four, PC_out;
output flush;

// Control Signals
input PCWrite;
input imem_enable, imem_wr;

// Intermediate Signals
reg [31:0] PC;
wire [31:0] newPC;

// Instruction Memory Instantiation
// Just use the ip here
test_imem iINST_MEM (
                    // Inputs
                    .address(PC[10:0]),
                    .clock(clk),
                    .data(32'b0),
                    .rden(imem_enable),
                    .wren(1'b0),
                    // Outputs
                    .q(instr)
);

// PC Register
always_ff @(posedge clk, negedge rst) begin
    if(!rst)
        PC <= 32'h0;
    else if(PCWrite)
        PC <= newPC;
end

// PC writeback mux (UPDATED FOR RETURN INSTR)
assign PC_mux_sel = (ID_EX_isJump | ID_EX_isReturn) ? 1'b1 : (EX_branch_out ? 1'b1 : 1'b0);
assign newPC = PC_mux_sel ? BR_J_PC : PC_plus_four;

assign PC_plus_four = PC + 4;
assign flush = PC_mux_sel;
assign PC_out = PC;

endmodule
