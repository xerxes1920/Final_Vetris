module CustomGraphics(
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

logic [29:0] Gameboard[19:0];
logic [8:0] rowCount;
logic [9:0] colCount;
logic [4:0] gameX, gameY;
logic [11:0] pixel;

assign oData = dVal ? pixel : 12'h999;

always_ff @(posedge clk, negedge rst) begin:
    if(!rst)
        for(int i = 0; i < 20; i++)
            Gameboard[i] <= 30'b0;
    else if(index != 5'b0)
        Gameboard[index] <= iData;

    if(!rst) begin
        rowCount <= 9'b0;
        colCount <= 10'b0;

        gameX <= 5'b0;
        gameY <= 5'b0;
    end
    else if(dVal) begin
        if(rowCount == 9'd479 && colCount == 10'd639) begin
            rowCount <= 9'b0;
            colCount <= 10'b0;
        end
        else if(colCount == 10'd639) begin
            rowCount <= rowCount + 1'b1;
            colCount <= 10'b0;
        end
        else
            colCount <= colCount + 1'b1;

        if(colCount % 64 == 10'd63) begin
            gameX <= gameX + 1'b1;
        end
        if(rowCount % 24 == 9'd23) begin
            gameY <= gameY + 1'b1;
        end
    end
end

always_comb begin
    pixel = 12'b0;
    if(Gameboard[gameX][gameY] == 3'b001)
        pixel = 12'hccc;
    else if(Gameboard[gameX][gameY] == 3'b010)
        pixel = 12'h333;
    else if(Gameboard[gameX][gameY] == 3'b011)
        pixel = 12'h777;
end

endmodule