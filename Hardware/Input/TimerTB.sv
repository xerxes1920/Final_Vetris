module TimerTB();

logic clk, rst, rstTimer, moveDown;

Timer timerDUT(
    .clk(clk),
    .rst(rst),
    .timeVal(),
    .rstTimer(rstTimer),
    .moveDown(moveDown)
);

initial begin
    clk = 1'b0;
    rst = 1'b0;
    repeat(5) @(negedge clk);
    rst = 1'b1;
    @(posedge moveDown);
    $display("MOVE DOWN");
    repeat(100000) @(posedge clk);
    rstTimer = 1'b1;
    @(posedge clk);
    rstTimer = 1'b0;
    repeat(24999999) @(posedge clk);
    if(moveDown != 1'b1)
        $display("TEST FAILED");
    else
        $display("TEST PASSED");
    $stop();
end

always
    #5 clk = ~clk;

endmodule
