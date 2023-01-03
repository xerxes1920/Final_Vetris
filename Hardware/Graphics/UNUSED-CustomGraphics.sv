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
logic [9:0] rowCount;
logic [8:0] colCount;
logic [4:0] gameX, gameY;
logic [11:0] pixel;

logic [9:0] rowMod;
logic [8:0] colMod;

assign rowMod = rowCount % 10'd24;
assign colMod = colCount % 9'd64;
assign oData = dVal ? pixel : 12'habc;

always_ff @(posedge clk, negedge rst) begin:
    if(!rst)
        for(int i = 0; i < 20; i++)
            Gameboard[i] <= 30'b0;
    else if(index != 5'b11111)
        Gameboard[index] <= iData;

    if(!rst) begin
        rowCount <= 10'b0;
        colCount <= 9'b0;
        gameX <= 5'b0;
        gameY <= 5'b0;
    end
    else if(dVal) begin
        // End of a frame, reset counts
        if(rowCount == 9'd479 && colCount == 10'd639) begin
            rowCount <= 9'b0;
            colCount <= 10'b0;
        end
        // End of a line, reset colCount and update rowCount
        else if(colCount == 10'd639) begin
            rowCount <= rowCount + 1'b1;
            colCount <= 10'b0;
        end
        // In the middle of a row, increment current column
        else
            colCount <= colCount + 1'b1;

        // Bottom of a game row reached
        if(rowMod == 10'd23)
            gameY <= gameY + 1'b1;
        // Right side of a game column reached
        if(colMod == 9'd63)
            gameX <= gameX + 1'b1;
    end
end

always_comb begin
    // Create the grid
    if(rowMod == 10'd1 || rowMod == 10'd2)
        pixel = 12'hfff;
    else if(colMod == 9'd1 || colMod == 9'd2)
        pixel = 12'hfff;
    // Draw game pieces
    else
        case(Gameboard[gameX][gameY])
            3'b001: pixel = 12'hcba;
            3'b010: pixel = 12'hdac;
            3'b011: pixel = 12'hf39;
            3'b100: pixel = 12'hcab;
            3'b101: pixel = 12'hdb2;
            3'b110: pixel = 12'h4a6;
            3'b111: pixel = 12'h999;
            default: pixel = 12'b0;
        endcase
end
endmodule
