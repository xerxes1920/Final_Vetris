module Graphics(
    clk,
    rst,
    iData,
    index,
    oDataRed,
    oDataGreen,
    oDataBlue,
    dVal
);
input logic clk, rst, dVal;
input logic [29:0] iData;
input logic [4:0] index;
output logic [11:0] oDataRed, oDataGreen, oDataBlue;

logic [4:0] gameX, gameY;
logic [9:0] colCount, rowCount, colMod, rowMod;
logic [2:0] Gameboard [19:0][9:0];
logic inGameBounds;

/*
    Screen resolution is 640x480
    480 pixel rows, 640 pixel columns
    20 game rows, 10 game columns
    480/20 = 24 (sets grid height), 24*10 = 240 (matches grid height to make squares)
    640 - 240 = 400 pixels to be black on left+right side, 200 per side
    24-1 = 23, 64-1 = 63
*/
assign colMod = (colCount - 10'd200) % 24;
assign rowMod = rowCount % 24;
assign inGameBounds = colCount < 10'd440 && colCount > 10'd200;

always_ff @(posedge clk, negedge rst) begin
    if(!rst) begin
        for(int i = 0; i < 20; i++) begin
            for(int j = 0; j < 10; j++) begin
                if(j == 0 && i == 0)
                    Gameboard[i][j] <= 3'b010;
                else if(i == 13)
                    Gameboard[i][j] <= 3'b001;
                else
                    Gameboard[i][j] <= 3'b000;
            end
        end
    end
    else if(index != 5'b11111) begin
        Gameboard[index][9] <= iData[(0*3)+2:0*3];
        Gameboard[index][8] <= iData[(1*3)+2:1*3];
        Gameboard[index][7] <= iData[(2*3)+2:2*3];
        Gameboard[index][6] <= iData[(3*3)+2:3*3];
        Gameboard[index][5] <= iData[(4*3)+2:4*3];
        Gameboard[index][4] <= iData[(5*3)+2:5*3];
        Gameboard[index][3] <= iData[(6*3)+2:6*3];
        Gameboard[index][2] <= iData[(7*3)+2:7*3];
        Gameboard[index][1] <= iData[(8*3)+2:8*3];
        Gameboard[index][0] <= iData[(9*3)+2:9*3];
    end
    if(!rst) begin
        gameX <= 5'b0;
        gameY <= 5'd19;
        colCount <= 10'b0;
        rowCount <= 10'b0;
    end
    else if(dVal && rst) begin
        // End of frame
        if(colCount == 10'd639 && rowCount == 10'd479) begin
            colCount <= 10'd0;
            rowCount <= 10'd0;
            gameX <= 5'd0;
            gameY <= 5'd19;
        end
        // Moving to the game spot to the right
        else if(colMod == 10'd23 && inGameBounds) begin
            gameX <= gameX + 1'b1;
            colCount <= colCount + 1'b1;
        end
        // Moving back to the left of the screen
        else if(colCount == 10'd639) begin
            colCount <= 10'd0;
            rowCount <= rowCount + 1'b1;
            gameX <= 5'd0;
            // Bottom of a game spot, move down
            if(rowMod == 10'd23)
                gameY <= gameY - 1'b1;
        end
        // In the middle of a game spot, move right
        else begin
            colCount <= colCount + 1'b1;
        end

    end
end

always_comb begin
    if(!inGameBounds) begin
        oDataRed = 12'hfff;
        oDataGreen = 12'hfff;
        oDataBlue = 12'hfff;
    end
    else if(colMod == 5'd23 || rowMod == 5'd23) begin
        oDataRed = 12'hfff;
        oDataGreen = 12'hfff;
        oDataBlue = 12'hfff;
    end
    else begin
        case(Gameboard[gameY][gameX])
            3'b001: begin
                oDataRed = 12'hfff;
                oDataGreen = 12'h0;
                oDataBlue = 12'h0;
            end
            3'b010: begin
                oDataRed = 12'h0;
                oDataGreen = 12'hfff;
                oDataBlue = 12'h0;
            end
            default: begin
                oDataRed = 12'h0;
                oDataGreen = 12'h0;
                oDataBlue = 12'h0;
            end
        endcase
    end
end

endmodule
