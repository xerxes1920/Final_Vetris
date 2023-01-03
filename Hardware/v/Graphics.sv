module Graphics(
    clk,
    rst,
    iData,
    index,
    oData,
    dVal
);

input logic clk, rst, dVal;
input logic [29:0] iData;
input logic [4:0] index;
output logic [35:0] oData;

CustomGraphics customBlock(
    .clk(clk),
    .rst(rst),
    .iData(iData),
    .index(index),
    .oData(oData),
    .dVal(dVal)
);

endmodule
