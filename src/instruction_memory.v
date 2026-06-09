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
            memory[0] = 16'b0100_001_000010100;    // LOAD R1, 20
            memory[1] = 16'b0100_010_000010101;    // LOAD R2, 21
            memory[2] = 16'h0000;                  
            memory[3] = 16'b0000_011_001_010_000;  // ADD  R3, R1, R2
            memory[4] = 16'b0101_011_000011110;    // STORE R3, 30
            memory[5] = 16'b1111_000000000000;     // HALT
            memory[6] = 16'h0000;                
            memory[7] = 16'h0000;                  
            memory[8] = 16'h0000;                  
            memory[9] = 16'h0000;               
        end
    end
    assign instruction = memory[address[7:0]];
endmodule