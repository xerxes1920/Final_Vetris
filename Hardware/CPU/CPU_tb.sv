module CPU_tb ();

reg clk, rst;

logic [31:0] in_reg_data_stim;

logic final_isMoveOrWriteShape_mon;
logic [31:0] row_data_mon, input_reg_update_mon, PC_mon;
logic [4:0] index_data_out_mon;
logic move_down, move_left, move_right;

always_ff @(rst, final_isMoveOrWriteShape_mon, move_down) begin
    if (!rst)
        in_reg_data_stim = 0;
    else if (final_isMoveOrWriteShape_mon)
        in_reg_data_stim = input_reg_update_mon;
    else if (move_down)
        in_reg_data_stim = {in_reg_data_stim[31:1], 1'b1};
    else if (move_left)
        in_reg_data_stim = {in_reg_data_stim[31:2], 2'b10};
    else if (move_right)
        in_reg_data_stim = {in_reg_data_stim[31:3], 3'b100};
end

// DUT
CPU iDUT_CPU (
    // Inputs
    .clk(clk),
    .rst(rst),
    .in_reg_data(in_reg_data_stim),
    // Outputs
    .final_isMoveOrWriteShape(final_isMoveOrWriteShape_mon),
    .row_data(row_data_mon),
    .input_reg_update(input_reg_update_mon),
    .index_data_out(index_data_out_mon),
    .PC_out_test(PC_mon)
);

initial begin
    // Reset
    clk = 0;
    rst = 1;
    //in_reg_data_stim = {17'h0, 2'b01, 5'h5, 5'h5, 3'b000};
    repeat(10) @(negedge clk);
    rst = 0;
    repeat(10) @(negedge clk);
    rst = 1;

    // Let CPU run
    repeat(1000) @(negedge clk);
    move_down = 1'b1;
    repeat(1) @(negedge clk);
    move_down = 1'b0;
    repeat(1000) @(negedge clk);

    repeat(1000) @(negedge clk);
    move_left = 1'b1;
    repeat(1) @(negedge clk);
    move_left = 1'b0;
    repeat(1000) @(negedge clk);

    repeat(1000) @(negedge clk);
    move_down = 1'b1;
    repeat(1) @(negedge clk);
    move_down = 1'b0;
    repeat(1000) @(negedge clk);

    repeat(1000) @(negedge clk);
    move_right = 1'b1;
    repeat(1) @(negedge clk);
    move_right = 1'b0;
    repeat(1000) @(negedge clk);


    $display("CPU Test Finished Running");
    $stop;
end

always
    #5 clk <= ~clk;

endmodule
