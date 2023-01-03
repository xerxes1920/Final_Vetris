module mem_access (
    // Inputs
    clk, rst, instr, input_reg, spec_reg_data, mem_enable, mem_wr, ifGetRow,
    alu_out,
    // Outputs
    row_index, ifGetRow_data_out, line_status, row_data_out
);

// Inputs
input clk, rst;
input [31:0] instr;
input [31:0] input_reg;
input [31:0] spec_reg_data; // $rt for special instructions
input [31:0] alu_out;

// Outputs
output [4:0] row_index;
output [31:0] line_status;
output [31:0] row_data_out; // row data to be sent to graphics
output [31:0] ifGetRow_data_out; // data to be written back to the register file

// Control Signals
input mem_enable, mem_wr;
input ifGetRow;

// Intermediate Signals
wire [31:0] row_status;
wire [31:0] data_in;
wire [3:0] real_x_pos;
wire [5:0] real_y_pos;
wire isWriteShape;

logic [31:0] final_instr, final_instr_line, final_instr_square;
logic [5:0] movRight, movLeft, movDown;
assign movRight = 6'b011011;
assign movLeft = 6'b011010;
assign movDown = 6'b011100;

assign isWriteShape = (instr[31:26] == 6'b011001) ? 1'b1 : 1'b0;
assign real_x_pos = isWriteShape ? 4'b0101 : input_reg[6:3];
assign real_y_pos = isWriteShape ? 6'b010000 : input_reg[12:7];
assign final_instr_line = (real_x_pos == 4'd9 && instr[31:26] == movRight) ? 32'hffffffff :
                     (real_x_pos == 4'd0 && instr[31:26] == movLeft) ? 32'hffffffff :
                     (real_y_pos == 4'd0 && instr[31:26] == movDown) ? 32'hffffffff : instr;

assign final_instr_square = (real_x_pos == 4'd8 && instr[31:26] == movRight) ? 32'hffffffff :
                     (real_x_pos == 4'd0 && instr[31:26] == movLeft) ? 32'hffffffff :
                     (real_y_pos == 4'd0 && instr[31:26] == movDown) ? 32'hffffffff : instr;

assign final_instr = (input_reg[14:13] == 2'b01) ? final_instr_line : (input_reg[14:13] == 2'b10) ? final_instr_square : 32'hffffffff;

// Memory Instantiation
gb_memory_old gbMEM (
                // Inputs
                .clk(clk),
                .rst_n(rst),
                .addr(32'b0),
                .data_in(data_in), // new shape to write (2 bits extended to 32)
                .enable(1'b0),
                .wr(1'b0),
                .instr(final_instr),
                .x_pos(real_x_pos),
                .y_pos(real_y_pos),
                .shape(input_reg[14:13]), // current shape from inputReg (2 bits)
                .get_line_num(spec_reg_data[4:0]),

                // Outputs
                .data_out(row_data_out),
                .line_status_out(line_status),
                .row_status_out(row_status)
);

// Mux to select between ALU_out and row_data_out
assign ifGetRow_data_out = ifGetRow ? row_status : alu_out;

assign row_index = spec_reg_data[4:0]; // row index is the first 5 bits from $rt
assign data_in = {30'hx , spec_reg_data[1:0]}; // new shape is from the first 3 bits of $rt

endmodule
