module writeback(reg_wb_data, ifGetRow_data_out, pc_plus_8, isJAL,
                 index_data_in, index_data_out, ifSendRow, clk, rst);

input [4:0] index_data_in;
input [31:0] ifGetRow_data_out, pc_plus_8;
input clk, rst, ifSendRow, isJAL;

output [31:0] reg_wb_data;
output [4:0] index_data_out;

// Send row index mux to graphics
assign index_data_out = ifSendRow ? index_data_in : 5'b11111;

// isJAL instruction mux (routes to decode's RF)
assign reg_wb_data = isJAL ? pc_plus_8 : ifGetRow_data_out;

endmodule
