module forwarding_unit (
    // Inputs
    EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_Rd, MEM_WB_Rd, ID_EX_Rs, ID_EX_Rt,
    EX_MEM_isI, MEM_WB_isI, EX_MEM_Rt, MEM_WB_Rt,
    // Outputs
    fwdA_sel, fwdB_sel
);

// Inputs
input EX_MEM_RegWrite, MEM_WB_RegWrite;
input EX_MEM_isI, MEM_WB_isI;
input [4:0] EX_MEM_Rd, MEM_WB_Rd;
input [4:0] EX_MEM_Rt, MEM_WB_Rt;
input [4:0] ID_EX_Rs, ID_EX_Rt;

// Outputs
output [1:0] fwdA_sel, fwdB_sel;

// Wires
wire rs_is_nine, rt_is_nine;

// Forwarding Mux A select
/**assign fwdA_R = (EX_MEM_RegWrite & (EX_MEM_Rd == ID_EX_Rs)) ?
                2'b01 : (MEM_WB_RegWrite &
                (5'h9 == ID_EX_Rs)) ? 2'b11 : (MEM_WB_RegWrite &
                (MEM_WB_Rd == ID_EX_Rs)) ? 2'b00 : 2'b10;

assign fwdA_I = (EX_MEM_RegWrite & (EX_MEM_Rt == ID_EX_Rs)) ?
		2'b01 : (MEM_WB_RegWrite &
		(5'h9 == ID_EX_Rs)) ? 2'b11 : (MEM_WB_RegWrite &
		(MEM_WB_Rt == ID_EX_Rs)) ? 2'b00 : 2'b10;

// Forwarding Mux B select
assign fwdB_R = (EX_MEM_RegWrite & (EX_MEM_Rd == ID_EX_Rt)) ?
                2'b01 : (MEM_WB_RegWrite &
                (5'h9 == ID_EX_Rt)) ? 2'b11 : (MEM_WB_RegWrite &
                (MEM_WB_Rd == ID_EX_Rt)) ? 2'b00 : 2'b10;

assign fwdB_I = (EX_MEM_Regwrite & (EX_MEM_Rt == ID_EX_Rt)) ?
		2'b01 : (MEM_WB_RegWrite &
		(5'h9 == ID_EX_Rt)) ? 2'b11 : (MEM_WB_RegWrite &
		(MEM_WB_Rt == ID_EX_Rt)) ? 2'b00 : 2'b10;**/

assign rs_is_nine = (ID_EX_Rs == 5'h9);
assign rt_is_nine = (ID_EX_Rt == 5'h9);

assign fwdA_sel = rs_is_nine ? 2'b11 : 
		  (EX_MEM_RegWrite & EX_MEM_isI 
		  & (EX_MEM_Rt == ID_EX_Rs)) ? 2'b01 : 
		  (EX_MEM_RegWrite & ~EX_MEM_isI & (EX_MEM_Rd == ID_EX_Rs))
		  ? 2'b01 : (MEM_WB_RegWrite & MEM_WB_isI 
		  & (MEM_WB_Rt == ID_EX_Rs)) ? 2'b00 :
	 	  (MEM_WB_RegWrite & ~MEM_WB_isI & (MEM_WB_Rd == ID_EX_Rs))
		  ? 2'b00 : 2'b10;

assign fwdB_sel = rt_is_nine ? 2'b11 : 
                  (EX_MEM_RegWrite & EX_MEM_isI 
                  & (EX_MEM_Rt == ID_EX_Rt)) ? 2'b01 :
                  (EX_MEM_RegWrite & ~EX_MEM_isI & (EX_MEM_Rd == ID_EX_Rt))
                  ? 2'b01 : (MEM_WB_RegWrite & MEM_WB_isI 
                  & (MEM_WB_Rt == ID_EX_Rt)) ? 2'b00 :
                  (MEM_WB_RegWrite & ~MEM_WB_isI & (MEM_WB_Rd == ID_EX_Rt))
                  ? 2'b00 : 2'b10;

endmodule
