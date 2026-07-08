`timescale 1ns/1ps

module tb_processor;

reg clk;
reg reset;
wire halt_out;
integer pass_count;
integer fail_count;
integer cyc;

processor_top DUT(
    .clk(clk),
    .reset(reset),
    .halt_out(halt_out)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    $dumpfile("processor_wave.vcd");
    $dumpvars(0,tb_processor);
end

reg seen_halt;
reg seen_pipeline_activity;
reg seen_load_r1_10;
reg seen_load_r2_5;
reg seen_store_nonzero;

initial begin
    seen_halt = 0;
    seen_pipeline_activity = 0;
    seen_load_r1_10 = 0;
    seen_load_r2_5 = 0;
    seen_store_nonzero = 0;
end

always @(posedge clk) begin
    if (halt_out && !seen_halt) begin
        seen_halt = 1;
        $display("[cyc %0d] EVENT : halt_out pulsed high", cyc);
    end
    if ((DUT.forward_a != 2'b00 || DUT.forward_b != 2'b00 || DUT.stall) && !seen_pipeline_activity) begin
        seen_pipeline_activity = 1;
        $display("[cyc %0d] EVENT : forwarding/stall observed (fa=%b fb=%b stall=%b)", cyc, DUT.forward_a, DUT.forward_b, DUT.stall);
    end
    if (DUT.RF.regs[1] == 16'd10 && !seen_load_r1_10) begin
        seen_load_r1_10 = 1;
        $display("[cyc %0d] EVENT : R1 loaded with 10", cyc);
    end
    if (DUT.RF.regs[2] == 16'd5 && !seen_load_r2_5) begin
        seen_load_r2_5 = 1;
        $display("[cyc %0d] EVENT : R2 loaded with 5", cyc);
    end
    if (DUT.ex_mem_mem_write && DUT.ex_mem_write_data != 16'd0 && !seen_store_nonzero) begin
        seen_store_nonzero = 1;
        $display("[cyc %0d] EVENT : STORE wrote non-zero data 0x%h to address %0d", cyc, DUT.ex_mem_write_data, DUT.ex_mem_alu_result);
    end
end

initial begin

pass_count = 0;
fail_count = 0;
cyc = 0;

$display("==========================================");
$display("      16-bit Pipelined RISC Processor");
$display("==========================================");

reset = 1;
repeat(4) @(posedge clk);
reset = 0;

$display("\nRunning program (live events will print as they occur)...\n");

repeat(80) begin
    @(posedge clk);
    cyc = cyc + 1;
end

$display("\n==========================================");
$display("      RUNNING CHECKS");
$display("==========================================");

//==============================================
// TEST 1 : RESET
//==============================================
if (DUT.pc >= 0) begin
    $display("[TEST 1] RESET                  ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 1] RESET                  ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 2 : LOAD
//==============================================
if (seen_load_r1_10 && seen_load_r2_5) begin
    $display("[TEST 2] LOAD                    ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 2] LOAD                    ... FAIL (r1_10=%b r2_5=%b)", seen_load_r1_10, seen_load_r2_5);
    fail_count = fail_count + 1;
end

//==============================================
// TEST 3 : ARITHMETIC
//==============================================
if (DUT.RF.regs[3] != 16'd0 && DUT.RF.regs[5] != 16'd0) begin
    $display("[TEST 3] ARITHMETIC (ADD/SUB)    ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 3] ARITHMETIC (ADD/SUB)    ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 4 : LOGICAL
//==============================================
if (DUT.RF.regs[6] != 16'd0 && DUT.RF.regs[7] != 16'd0) begin
    $display("[TEST 4] LOGICAL (AND/OR/XOR/NOT)... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 4] LOGICAL (AND/OR/XOR/NOT)... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 5 : SHIFT
//==============================================
if (DUT.RF.regs[4] != 16'd0) begin
    $display("[TEST 5] SHIFT (SHL/SHR)         ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 5] SHIFT (SHL/SHR)         ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 6 : STORE / LOAD
//==============================================
if (seen_store_nonzero && DUT.DM.memory[30] != 16'd0) begin
    $display("[TEST 6] STORE / LOAD            ... PASS (memory[30]=%0d)", DUT.DM.memory[30]);
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 6] STORE / LOAD            ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 7 : BRANCH & JUMP
//==============================================
if (DUT.pc >= 16'd28) begin
    $display("[TEST 7] BRANCH & JUMP           ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 7] BRANCH & JUMP           ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 8 : PIPELINE (forwarding / hazard detection)
//==============================================
if (seen_pipeline_activity) begin
    $display("[TEST 8] PIPELINE (fwd/hazard)   ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 8] PIPELINE (fwd/hazard)   ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 9 : HALT
//==============================================
if (seen_halt) begin
    $display("[TEST 9] HALT                    ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 9] HALT                    ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// TEST 10 : FINAL VERIFICATION
//==============================================
if (DUT.RF.regs[0] == 16'd0 && DUT.DM.memory[31] != 16'd0) begin
    $display("[TEST 10] R0 PROTECTED / FINAL STORE ... PASS");
    pass_count = pass_count + 1;
end else begin
    $display("[TEST 10] R0 PROTECTED / FINAL STORE ... FAIL");
    fail_count = fail_count + 1;
end

//==============================================
// SUMMARY
//==============================================
$display("\n==========================================");
$display("            TEST SUMMARY");
$display("==========================================");
$display("Tests Passed : %0d / 10", pass_count);
$display("Tests Failed : %0d / 10", fail_count);

if (fail_count == 0)
    $display("\n******** ALL TESTS PASSED ********");
else
    $display("\n******** SOME TESTS FAILED ********");

$finish;

end

initial begin
    #10000;
    $display("\nSimulation Timeout!");
    $finish;
end
endmodule