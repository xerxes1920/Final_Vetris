module CPU (
    // Inputs
    clk, rst, in_reg_data,
    // Outputs
    final_isMoveOrWriteShape, row_data, input_reg_update, index_data_out,
    PC_out_test
);

// Inputs
input clk, rst;
input [31:0] in_reg_data; // input register data (external)

// Outputs
output final_isMoveOrWriteShape; // to input module
output [31:0] row_data; // to graphics
output [31:0] input_reg_update; // to input module
output [4:0] index_data_out; // to graphics

output [31:0] PC_out_test;

// Intermediate Signals
// Fetch
wire flush;
wire [31:0] instr, PC_plus_four, PC_out;
// IF/ID
wire [31:0] IF_ID_instr, IF_ID_pc_plus_four;
// Decode
wire [31:0] pc_plus_8, pc_plus_imm, imm, data_out_1, data_out_2;
wire [4:0] writeregsel;
// ID/EX
wire [31:0] ID_EX_instr, ID_EX_pc_plus_four, ID_EX_pc_plus_imm,
    ID_EX_pc_plus_8, ID_EX_imm, ID_EX_data_out_1, ID_EX_data_out_2;
wire [4:0] ID_EX_writeregsel;
wire [3:0] ID_EX_aluop;
wire ID_EX_isJ, ID_EX_isBr, ID_EX_isReturn, ID_EX_isShift, ID_EX_ifGetRow,
    ID_EX_ifSendRow, ID_EX_isMoveOrWriteShape, ID_EX_isSpecial, ID_EX_isI,
    ID_EX_reg_write, ID_EX_isJAL;
// Execute
wire [31:0] BR_J_PC, alu_out, spec_reg_data;
wire EX_branch_out;
// EX/MEM
wire [31:0] EX_MEM_instr, EX_MEM_input_reg, EX_MEM_spec_reg_data,
    EX_MEM_alu_out, EX_MEM_pc_plus_8;
wire [4:0] EX_MEM_writeregsel;
wire EX_MEM_ifGetRow, EX_MEM_ifSendRow, EX_MEM_isSpecial,
    EX_MEM_isMoveOrWriteShape, EX_MEM_isJAL, EX_MEM_reg_write, EX_MEM_isI;
// Memory Access
wire [4:0] row_index;
wire [31:0] ifGetRow_data_out, line_status, row_data_out;
// MEM/WB
wire [31:0] MEM_WB_ifGetRow_data, MEM_WB_line_status, MEM_WB_row_data,
    MEM_WB_pc_plus_8, MEM_WB_instr;
wire [4:0] MEM_WB_writeregsel, MEM_WB_index_data;
wire MEM_WB_ifSendRow, MEM_WB_isJAL, MEM_WB_reg_write, MEM_WB_isI;
// Writeback
wire [31:0] reg_wb_data;
// Hazard Unit
wire NOP;
wire PCWrite, IF_ID_Write;
// Forwarding Unit
wire [1:0] fwdA, fwdB;


// Control Signals
wire [3:0] alu_op;
wire isJ, isI, isBr, isR, isSpecial, isMoveOrWriteShape, reg_write;
wire isReturn, ifSendRow, ifGetRow, isShift, isJAL;

// Instruction Fetch
inst_fetch iIF (
                // Inputs
                .clk(clk),
                .rst(rst),
                .BR_J_PC(BR_J_PC),
                .ID_EX_isJump(ID_EX_isJ),
                .EX_branch_out(EX_branch_out),
                .ID_EX_isReturn(ID_EX_isReturn),
                .PCWrite(PCWrite),
                .imem_enable(1'b1), // TODO may need to change?
                .imem_wr(1'b0),
                // Outputs
                .instr(instr),
                .PC_plus_four(PC_plus_four),
                .flush(flush),
                .PC_out(PC_out)
);
assign PC_out_test = PC_out;

// IF/ID
if_id iIF_ID (
                // Inputs
                .clk(clk),
                .rst(rst),
                .flush(flush),
                .instr_in(instr),
                .PC_plus_four_in(PC_plus_four),
                .IF_ID_Write(IF_ID_Write),
                // Outputs
                .instr_out(IF_ID_instr),
                .PC_plus_four_out(IF_ID_pc_plus_four)
);

// Decode
decode iID (
                // Inputs
                .clk(clk),
                .rst(rst),
                .instr(IF_ID_instr),
                .pc_plus_4_in(IF_ID_pc_plus_four),
                .writedata(reg_wb_data), // from writeback
                .in_reg_data(in_reg_data),
                .line_status_in(MEM_WB_line_status), // from MEM/WB
                .writeregsel_in(MEM_WB_writeregsel), // from MEM/WB
                .isSpecial(isSpecial),
                .isBranch(isBr),
                .isR(isR),
                .RegWrite(MEM_WB_reg_write), // from MEM/WB
                .isReturn(isReturn),
                .isJAL(isJAL),
		.isMoveOrWriteShape(isMoveOrWriteShape),
                // Outputs
                .pc_plus_8(pc_plus_8),
                .pc_plus_imm(pc_plus_imm),
                .imm(imm),
                .data_out_1(data_out_1),
                .data_out_2(data_out_2),
                .writeregsel_out(writeregsel)
);

// ID/EX
id_ex iID_EX (
                // Inputs
                .clk(clk),
                .rst(rst),
		.flush(flush),
                .instr_in(IF_ID_instr),
                .PC_plus_four_in(IF_ID_pc_plus_four),
                .PC_plus_imm_in(pc_plus_imm),
                .PC_plus_8_in(pc_plus_8),
                .imm_in(imm),
                .data_out_1_in(data_out_1),
                .data_out_2_in(data_out_2),
                .writeregsel_in(writeregsel),
                .aluop_in(alu_op),
                .isJ_in(isJ),
                .isBR_in(isBr),
                .isReturn_in(isReturn),
                .isShift_in(isShift),
                .ifGetRow_in(ifGetRow),
                .ifSendRow_in(ifSendRow),
                .isMoveOrWriteShape_in(isMoveOrWriteShape),
                .isSpecial_in(isSpecial),
                .isI_in(isI),
                .isJAL_in(isJAL),
                .regWrite_in(reg_write),
                // Outputs
                .instr_out(ID_EX_instr),
                .PC_plus_four_out(ID_EX_pc_plus_four),
                .PC_plus_imm_out(ID_EX_pc_plus_imm),
                .PC_plus_8_out(ID_EX_pc_plus_8),
                .imm_out(ID_EX_imm),
                .data_out_1_out(ID_EX_data_out_1), // could be in_reg_data
                .data_out_2_out(ID_EX_data_out_2),
                .writeregsel_out(ID_EX_writeregsel),
                .aluop_out(ID_EX_aluop),
                .isJ_out(ID_EX_isJ),
                .isBR_out(ID_EX_isBr),
                .isReturn_out(ID_EX_isReturn),
                .isShift_out(ID_EX_isShift),
                .ifGetRow_out(ID_EX_ifGetRow),
                .ifSendRow_out(ID_EX_ifSendRow),
                .isMoveOrWriteShape_out(ID_EX_isMoveOrWriteShape),
                .isSpecial_out(ID_EX_isSpecial),
                .isI_out(ID_EX_isI),
                .isJAL_out(ID_EX_isJAL),
                .regWrite_out(ID_EX_reg_write)
);

// Execute
execute iEX (
                // Inputs
                .clk(clk),
                .rst(rst),
                .data1(ID_EX_data_out_1),
                .data_mem_wb(MEM_WB_ifGetRow_data),
                .data_ex_mem(EX_MEM_alu_out),
                .data2(ID_EX_data_out_2),
                .pc_plus_4(ID_EX_pc_plus_four),
                .pc_plus_imm(ID_EX_pc_plus_imm),
                .imm_in(ID_EX_imm),
                .line_data(MEM_WB_line_status),
                .return_val(ID_EX_data_out_1), // I think this is hooked up correctly?
                .opcode(ID_EX_instr[31:26]),
                .isI(ID_EX_isI),
                .isShift(ID_EX_isShift),
                .isBR(ID_EX_isBr),
                .isJ(ID_EX_isJ),
                .isReturn(ID_EX_isReturn),
		.isMoveOrWriteShape(ID_EX_isMoveOrWriteShape),
                .alu_op(ID_EX_aluop),
                .fwdA(fwdA),
                .fwdB(fwdB),
                // Outputs
                .pc_out(BR_J_PC),
                .alu_out(alu_out),
                .spec_reg_data(spec_reg_data),
                .EX_branch_out(EX_branch_out)
);

// EX/MEM
ex_mem iEX_MEM (
                // Inputs
                .clk(clk),
                .rst(rst),
                .instr_in(ID_EX_instr),
                .input_reg_in(ID_EX_data_out_1), // I think this is hooked up correctly?
                .spec_reg_data_in(spec_reg_data),
                .alu_in(alu_out),
                .PC_plus_8_in(ID_EX_pc_plus_8),
                .writeregsel_in(ID_EX_writeregsel),
                .ifGetRow_in(ID_EX_ifGetRow),
                .ifSendRow_in(ID_EX_ifSendRow),
                .isSpecial_in(ID_EX_isSpecial),
                .isMoveOrWriteShape_in(ID_EX_isMoveOrWriteShape),
                .isJAL_in(ID_EX_isJAL),
		.isI_in(ID_EX_isI),
                .regWrite_in(ID_EX_reg_write),
                // Outputs
                .instr_out(EX_MEM_instr),
                .input_reg_out(EX_MEM_input_reg),
                .spec_reg_data_out(EX_MEM_spec_reg_data),
                .alu_out(EX_MEM_alu_out),
                .PC_plus_8_out(EX_MEM_pc_plus_8),
                .writeregsel_out(EX_MEM_writeregsel),
                .ifGetRow_out(EX_MEM_ifGetRow),
                .ifSendRow_out(EX_MEM_ifSendRow),
                .isSpecial_out(EX_MEM_isSpecial),
                .isMoveOrWriteShape_out(EX_MEM_isMoveOrWriteShape),
                .isJAL_out(EX_MEM_isJAL),
		.isI_out(EX_MEM_isI),
                .regWrite_out(EX_MEM_reg_write)
);

// Memory Access
mem_access iMEM_ACCESS (
                // Inputs
                .clk(clk),
                .rst(rst),
                .instr(EX_MEM_instr),
                .input_reg(EX_MEM_input_reg),
                .spec_reg_data(EX_MEM_spec_reg_data),
                .alu_out(EX_MEM_alu_out),
                .mem_enable(EX_MEM_isSpecial),
                .mem_wr(EX_MEM_isMoveOrWriteShape),
                .ifGetRow(EX_MEM_ifGetRow),
                // Outputs
                .row_index(row_index),
                .ifGetRow_data_out(ifGetRow_data_out),
                .line_status(line_status),
                .row_data_out(row_data_out)
);

// MEM/WB
mem_wb iMEM_WB (
                // Inputs
                .clk(clk),
                .rst(rst),
                .data_in(ifGetRow_data_out),
                .line_status_in(line_status),
                .row_data_in(row_data_out),
                .PC_plus_8_in(EX_MEM_pc_plus_8),
                .writeregsel_in(EX_MEM_writeregsel),
                .index_data_in(row_index),
                .ifSendRow_in(EX_MEM_ifSendRow),
                .isMoveOrWriteShape_in(EX_MEM_isMoveOrWriteShape),
                .isJAL_in(EX_MEM_isJAL),
		.isI_in(EX_MEM_isI),
                .regWrite_in(EX_MEM_reg_write),
                .instr_in(EX_MEM_instr),
                .input_reg_update_in(EX_MEM_alu_out),
                // Outputs
                .data_out(MEM_WB_ifGetRow_data),
                .line_status_out(MEM_WB_line_status),
                .row_data_out(row_data),
                .PC_plus_8_out(MEM_WB_pc_plus_8),
                .writeregsel_out(MEM_WB_writeregsel),
                .index_data_out(MEM_WB_index_data),
                .ifSendRow_out(MEM_WB_ifSendRow),
                .isMoveOrWriteShape_out(final_isMoveOrWriteShape),
                .isJAL_out(MEM_WB_isJAL),
		.isI_out(MEM_WB_isI),
                .regWrite_out(MEM_WB_reg_write),
                .instr_out(MEM_WB_instr),
                .input_reg_update_out(input_reg_update)
);

// Writeback
writeback iWB (
                // Inputs
                .clk(clk),
                .rst(rst),
                .index_data_in(MEM_WB_index_data),
                .ifGetRow_data_out(MEM_WB_ifGetRow_data),
                .pc_plus_8(MEM_WB_pc_plus_8),
                .ifSendRow(MEM_WB_ifSendRow),
                .isJAL(MEM_WB_isJAL),
                // Outputs
                .reg_wb_data(reg_wb_data),
                .index_data_out(index_data_out)
);

// Control Unit
ctrl_blk iCTRL (
                // Inputs
                .instr(IF_ID_instr),
                .NOP(NOP),
                // Outputs
                .alu_op(alu_op),
                .isJ(isJ),
                .isI(isI),
                .isBr(isBr),
                .isR(isR),
                .isSpecial(isSpecial),
                .isMoveOrWriteShape(isMoveOrWriteShape),
                .reg_write(reg_write),
                .isReturn(isReturn),
                .ifSendRow(ifSendRow),
                .ifGetRow(ifGetRow),
                .isShift(isShift),
                .isJAL(isJAL)
);

// Hazard Detection Unit
hazard_detection iHZRD (
                // Inputs
                .ID_EX_isSpecial(ID_EX_isSpecial),
                .ID_EX_ifSendRow(ID_EX_ifSendRow),
                .ID_EX_ifGetRow(ID_EX_ifGetRow),
                .IF_ID_Rs(IF_ID_instr[25:21]),
                .IF_ID_Rt(IF_ID_instr[20:16]),
                .ID_EX_Rd(ID_EX_instr[15:11]),
                // Outputs
                .PCWrite(PCWrite),
                .IF_ID_Write(IF_ID_Write),
                .NOP(NOP)
);

// Forwarding Unit
forwarding_unit iFWD (
                // Inputs
                .EX_MEM_RegWrite(EX_MEM_reg_write),
                .MEM_WB_RegWrite(MEM_WB_reg_write),
                .EX_MEM_Rd(EX_MEM_instr[15:11]),
                .MEM_WB_Rd(MEM_WB_instr[15:11]),
		.EX_MEM_Rt(EX_MEM_instr[20:16]),
		.MEM_WB_Rt(MEM_WB_instr[20:16]),
		.EX_MEM_isI(EX_MEM_isI),
		.MEM_WB_isI(MEM_WB_isI),
                .ID_EX_Rs(ID_EX_instr[25:21]),
                .ID_EX_Rt(ID_EX_instr[20:16]),
                // Outputs
                .fwdA_sel(fwdA),
                .fwdB_sel(fwdB)
);

endmodule
