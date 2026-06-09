`timescale 1ns/1ps
module tb_processor;
    reg clk;
    reg reset;
    initial clk = 0;
    always #5 clk = ~clk;
    processor_top DUT (
        .clk (clk),
        .reset (reset),
        .halt_out(halt_out)
    );
    wire halt_out;
    reg halt_seen;
    initial halt_seen = 0;
    always @(posedge clk) begin
        if (halt_out) halt_seen <= 1;
    end
 
    wire [15:0] pc = DUT.pc;
    wire stall = DUT.stall;
    wire flush_if = DUT.flush_if_id;
    wire flush_id = DUT.flush_id_ex;
    wire [1:0] fwd_a = DUT.forward_a;
    wire [1:0] fwd_b = DUT.forward_b;
    wire wb_write = DUT.wb_reg_write;
    wire [2:0] wb_rd = DUT.wb_rd;
    wire [15:0] wb_data = DUT.wb_write_data;
    wire [15:0] R0 = DUT.RF.regs[0];
    wire [15:0] R1 = DUT.RF.regs[1];
    wire [15:0] R2 = DUT.RF.regs[2];
    wire [15:0] R3 = DUT.RF.regs[3];
    wire [15:0] R4 = DUT.RF.regs[4];
    wire [15:0] R5 = DUT.RF.regs[5];
    wire [15:0] R6 = DUT.RF.regs[6];
    wire [15:0] R7 = DUT.RF.regs[7];

    integer pass_count;
    integer fail_count;
    task wait_for_halt;
        input integer max_cycles;
        integer i;
        begin
            i = 0;
            while (!halt_out && i < max_cycles) begin
                @(posedge clk); #1;
                i = i + 1;
            end
            if (!halt_out) begin
                $display("  [WARN] HALT not seen after %0d cycles", max_cycles);
            end else begin
                $display("  [INFO] HALT reached after ~%0d cycles at t=%0t", i, $time);
            end
        end
    endtask

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
            #1;
        end
    endtask

    task check_reg;
        input [2:0] reg_num;
        input [15:0] expected;
        reg   [15:0] actual;
        begin
            case (reg_num)
                3'd0: actual = R0; 3'd1: actual = R1;
                3'd2: actual = R2; 3'd3: actual = R3;
                3'd4: actual = R4; 3'd5: actual = R5;
                3'd6: actual = R6; 3'd7: actual = R7;
            endcase
            if (actual === expected) begin
                $display("  [PASS] R%0d = 0x%04h (expected 0x%04h)",reg_num, actual, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] R%0d = 0x%04h  expected 0x%04h  <<",reg_num, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_mem;
        input [7:0] addr;
        input [15:0] expected;
        reg   [15:0] actual;
        begin
            actual = DUT.DM.memory[addr];
            if (actual === expected) begin
                $display("  [PASS] mem[%0d] = 0x%04h (expected 0x%04h)",addr, actual, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] mem[%0d] = 0x%04h  expected 0x%04h  <<",addr, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task monitor_cycle;
        begin
            $display("  t=%0t PC=%0d stall=%b flush=%b/%b fwdA=%b fwdB=%b | WB:R%0d<=0x%04h we=%b",
                $time, pc,stall, flush_if, flush_id,fwd_a, fwd_b,wb_rd, wb_data, wb_write);
        end
    endtask

    initial begin
        $dumpfile("processor_wave.vcd");
        $dumpvars(0, tb_processor);
        pass_count = 0;
        fail_count = 0;
        $display("  16-bit RISC Processor Testbench");

        reset = 1;
        wait_cycles(4);
        reset = 0;
        $display("\n[RESET released at t=%0t]\n", $time);

        $display("Pipeline monitor (first 5 cycles after reset) ");
        begin : mon
            integer k;
            for (k = 0; k < 5; k = k + 1) begin
                @(posedge clk); #1;
                monitor_cycle;
            end
        end

        $display("\nWaiting for HALT ");
        wait_for_halt(50);
        wait_cycles(15);
        // TEST 1: LOAD R1, 20  → R1 = mem[20] = 10
        // TEST 2: LOAD R2, 21  → R2 = mem[21] = 5

        $display("\nTEST 1 & 2: LOAD Instructions ");
        check_reg(3'd1, 16'd10);
        check_reg(3'd2, 16'd5);

        // TEST 3: ADD R3, R1, R2  → R3 = 10 + 5 = 15

        $display("\n TEST 3: ADD Instruction ");
        check_reg(3'd3, 16'd15);

        // TEST 4: STORE R3, 30  → mem[30] = 15
       
        $display("\n TEST 4: STORE Instruction ");
        check_mem(8'd30, 16'd15);

        // TEST 5: R0 is always zero

        $display("\n TEST 5: R0 Hardwired Zero");
        check_reg(3'd0, 16'd0);

        // TEST 6: HALT signal asserted
   
        $display("\n TEST 6: HALT Signal ");
        if (halt_seen) begin
            $display("  [PASS] halt_out asserted correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] halt_out not asserted");
            fail_count = fail_count + 1;
        end

        // TEST 7: Reset clears pipeline registers
       
        $display("\nTEST 7: Reset Clears Pipeline ");
        reset = 1;
        wait_cycles(2);
        if (DUT.IF_ID.instruction_out === 16'h0000 &&DUT.ID_EX.reg_write_out   === 1'b0 &&DUT.EX_MEM.reg_write_out  === 1'b0 &&DUT.MEM_WB.reg_write_out  === 1'b0) begin
            $display("  [PASS] All pipeline registers cleared on reset");
            pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] Pipeline registers not fully cleared");
            fail_count = fail_count + 1;
        end
        reset = 0;
        $display("  RESULTS: %0d passed, %0d failed", pass_count, fail_count);
        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  SOME TESTS FAILED — open processor_wave.vcd in GTKWave");
        $finish;
    end
    initial begin
        #10000;
        $display("[TIMEOUT] Simulation exceeded 10000ns");
        $finish;
    end
endmodule