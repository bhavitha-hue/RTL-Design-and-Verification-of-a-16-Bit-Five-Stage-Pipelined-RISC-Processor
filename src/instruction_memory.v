module instruction_memory #(
    parameter MEM_DEPTH = 256,
    parameter MEM_FILE  = ""       
)(
    input [15:0] address,
    output [15:0] instruction
);
    reg [15:0] memory [0:MEM_DEPTH-1];
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1)
            memory[i] = 16'h0000;
            if (MEM_FILE != "")
                $readmemh(MEM_FILE, memory);
            else begin
                memory[0]  = 16'b0100_001_000010100;   // LOAD  R1,20
                memory[1]  = 16'b0100_010_000010101;   // LOAD  R2,21 
                memory[2]  = 16'b0000_011_001_010_000; // ADD   R3,R1,R2            
                memory[3]  = 16'b0000_100_011_001_000; // ADD   R4,R3,R1
                memory[4]  = 16'b0001_101_100_010_000; // SUB   R5,R4,R2
                memory[5]  = 16'b0010_110_101_001_000; // AND   R6,R5,R1
                memory[6]  = 16'b0011_111_110_010_000; // OR    R7,R6,R2
                memory[7]  = 16'b1000_001_111_101_000; // XOR   R1,R7,R5
                memory[8]  = 16'b1001_010_001_000_000; // NOT   R2,R1
                memory[9]  = 16'b1010_011_010_001_000; // SHL   R3,R2,R1
                memory[10] = 16'b1011_100_011_010_000; // SHR   R4,R3,R2
                memory[11] = 16'b0101_100_000011110;   // STORE R4,30
                memory[12] = 16'b0100_101_000011110;   // LOAD  R5,30
                memory[13] = 16'b0000_110_101_001_000; // ADD   R6,R5,R1
                memory[14] = 16'b0001_111_110_010_000; // SUB   R7,R6,R2
                memory[15] = 16'b0110_111_001_000010;  // BEQ R7,R1,+2
                memory[16] = 16'b0000_001_111_110_000; // ADD R1,R7,R6
                memory[17] = 16'b0110_001_001_000010;  // BEQ R1,R1,+2
                memory[18] = 16'b0001_010_001_111_000; // SUB R2,R1,R7
                memory[19] = 16'b0010_011_001_010_000; // AND R3,R1,R2
                memory[20] = 16'b1101_011_001_000010;  // BNE R3,R1,+2
                memory[21] = 16'b0011_100_011_010_000; // OR R4,R3,R2
                memory[22] = 16'b1000_101_011_100_000; // XOR R5,R3,R4
                memory[23] = 16'b0111_000000000011;    // JMP +3 (PC 23 -> 26, hardware jump target is PC-relative)
                memory[24] = 16'b0000_110_101_001_000; // ADD R6,R5,R1
                memory[25] = 16'b0001_111_110_010_000; // SUB R7,R6,R2
                memory[26] = 16'b1100_001_000000001;   // ADDI R1,1
                memory[27] = 16'b0101_001_000011111;   // STORE R1,31
                memory[28] = 16'b1111_000000000000;    // HALT
                memory[29] = 16'h0000;
                memory[30] = 16'h0000;
                memory[31] = 16'h0000;
            end
    end
    assign instruction = memory[address[7:0]];
endmodule