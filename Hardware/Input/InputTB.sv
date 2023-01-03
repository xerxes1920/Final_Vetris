module InputTB();
    Input dut(
        .clk(clk),
        .rst(),
        .KEY(),
        .moveDown(),
        .moveLeft(),
        .moveRight(),
        .rda(),
        .GPIO(),
        .rstTimer(),
        .ioaddr(),
        .sprOut(),
        .sprIn()
    );
endmodule