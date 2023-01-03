module Timer(
    clk,
    rst,
    rstTimer,
    moveDown,
		currVal
);

input clk;
input rst;
input rstTimer;
output logic moveDown;
output logic [31:0] currVal;

logic [31:0] countDown;
logic [31:0] setValue;
assign currVal = countDown;
assign moveDown = countDown <= 32'b0 ? 1'b1 : 1'b0;
assign setValue = 32'd20_000_000;

always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
        countDown <= setValue;
    end
    else if(rstTimer) 
        countDown <= setValue;
    else begin
        if(countDown <= 32'b0)
            countDown <= setValue;
        else
            countDown <= countDown - 1'b1;
    end
end

endmodule
