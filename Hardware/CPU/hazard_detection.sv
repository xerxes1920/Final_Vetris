module hazard_detection (
    // Inputs
    ID_EX_isSpecial, ID_EX_ifSendRow, ID_EX_ifGetRow,
    IF_ID_Rs, IF_ID_Rt, ID_EX_Rd,
    // Outputs
    PCWrite, IF_ID_Write, NOP
);

// Inputs
input ID_EX_isSpecial, ID_EX_ifSendRow, ID_EX_ifGetRow;
input [4:0] IF_ID_Rs, IF_ID_Rt, ID_EX_Rd;

// Outputs
output reg PCWrite, IF_ID_Write;
output reg NOP;

// Intermediate Signals
wire stall_get_row, stall_line_status;

// reading register 9 (line status) after special instr (not getRow or sendRow)
assign stall_line_status = ((ID_EX_isSpecial & !ID_EX_ifSendRow & !ID_EX_ifGetRow) 
                    & ((IF_ID_Rs == 5'h9) | (IF_ID_Rt == 5'h9))) ? 1'b1 : 1'b0;

// reading $rt after a getRow
assign stall_get_row = (ID_EX_ifGetRow & ((ID_EX_Rd == IF_ID_Rt) | (ID_EX_Rd == IF_ID_Rs)))
                    ? 1'b1 : 1'b0;

always @ (*) begin
    // Defaults
    PCWrite = 1;
    IF_ID_Write = 1;
    NOP = 0;

    case (stall_get_row | stall_line_status)
        1'b0: ;
        1'b1: begin
            PCWrite = 0;
            IF_ID_Write = 0;
            NOP = 1;
        end
    endcase
end
    
endmodule
