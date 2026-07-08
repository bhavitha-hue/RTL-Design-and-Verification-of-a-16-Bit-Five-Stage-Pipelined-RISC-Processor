`timescale 1ns/1ps
module tb_processor_gatelevel;

reg clk;
reg reset;
wire halt_out;

processor_top DUT(
    .clk(clk),
    .reset(reset),
    .halt_out(halt_out)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset = 1;
    repeat(4) @(posedge clk);
    reset = 0;
    
    wait(halt_out == 1);
    $display("[GATE-LEVEL] halt_out asserted at time %0t — design completed execution", $time);
    $finish;
end

initial begin
    #10000;
    $display("[GATE-LEVEL] TIMEOUT — halt_out never asserted!");
    $finish;
end

endmodule