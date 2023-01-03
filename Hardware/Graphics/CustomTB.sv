module CustomTB();

logic clk, rst, dVal;

logic [4:0] index;
logic [29:0] inData;
logic [11:0] outData;

CustomGraphics graphicsDUT(
    .clk(clk),
    .rst(rst),
    .iData(inData),
    .index(index),
    .oData(outData),
    .dVal(dVal)
);

assign inData = 30'b001_001_001_001_001_001_001_001_001_001;

initial begin
    // Initial reset and clock setup
	clk = 1'b0;
    rst = 1'b0;
    dVal = 1'b0;
    index = 5'b0;
    @(negedge clk);
    @(negedge clk);
    rst = 1'b1;

    // Load the game board memory with data
    for(int i = 1; i < 21; i++) begin
        @(posedge clk);
        index = i;
    end

    // Allow pixel output
    @(posedge clk);
    dVal = 1'b1;

    // Get the first X pixels
    repeat(10000) begin
        @(posedge clk);
        if(outData != 12'hcba && outData != 12'hfff) begin
            $display("TEST FAILED");
            $stop();
        end
    end
    $display("TEST PASSED");
    $stop;
end

always
    #5 clk = ~clk;
    
endmodule