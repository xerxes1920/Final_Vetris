module Rewrite(
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
output logic [11:0] oData;

logic [4:0] gameX, gameY;
logic [9:0] colCount, rowCount, colMod, rowMod;
logic [2:0] Gameboard [19:0][9:0];

/*
    Screen resolution is 640x480
    480 pixel rows, 640 pixel columns
    20 game rows, 10 game columns
    480/20 = 24, 640/10 = 64
    24-1 = 23, 64-1 = 63
*/
assign colMod = colCount % 64;
assign rowMod = rowCount % 24;
logic [2:0] testData;

always_ff @(posedge clk, negedge rst) begin
    if(!rst) begin
        for(int i = 0; i < 20; i++)
            for(int j = 0; j < 10; j++) begin
                Gameboard[i][j] <= {2'b00, j[0]};
            end
    end
    
    else if(dVal) begin
        if(colCount == 10'd639 && rowCount == 10'd479) begin
            colCount <= 10'd0;
            rowCount <= 10'd0;
            gameX <= 5'd0;
            gameY <= 5'd0;
        end
        else if(colCount == 10'd639) begin
            colCount <= 10'd0;
            rowCount <= rowCount + 1'b1;
        end
        else begin
            colCount <= colCount + 1'b1;
        end

        if(colMod == 10'd63)
            gameX <= gameX + 1'b1;
        if(rowMod == 10'd23)
            gameY <= gameY + 1'b1;
    end
end

logic [2:0] current;
assign current = Gameboard[gameX][gameY];
always_comb begin
    if(colMod == 5'd63 || rowMod == 5'd23)
        oData = 12'h0;
    else
        case(current)
            3'b001: oData = 12'h333;
            3'b010: oData = 12'h999;
            default: oData = 12'h0;
        endcase

end

endmodule
