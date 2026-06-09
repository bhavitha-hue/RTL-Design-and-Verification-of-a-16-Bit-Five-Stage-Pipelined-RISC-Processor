module data_memory #(
    parameter MEM_DEPTH = 256,
    parameter MEM_FILE  = ""     
)(
    input clk,
    input reset,
    input mem_read,
    input mem_write,
    input [15:0] address,
    input [15:0] write_data,
    output [15:0] read_data
);
    reg [15:0] memory [0:MEM_DEPTH-1];
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1)
            memory[i] = 16'd0;
        if (MEM_FILE != "")
            $readmemh(MEM_FILE, memory);
        else begin
            memory[20] = 16'd10;
            memory[21] = 16'd5;
        end
    end

    always @(posedge clk) begin
        if (mem_write && !mem_read)          // no simultaneous R/W
            memory[address[7:0]] <= write_data;
    end

assign read_data = (reset)     ? 16'h0000 :
                   (mem_read)  ? memory[address[7:0]] :16'h0000;

endmodule