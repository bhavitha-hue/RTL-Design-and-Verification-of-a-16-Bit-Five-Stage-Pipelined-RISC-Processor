module pipeline_if_id(
    input clk,
    input reset,
    input stall, // 1 = freeze register 
    input flush, // 1 = insert NOP (branch/jump taken)
    input [15:0] pc_in,
    input [15:0] instruction_in,
    output reg [15:0] pc_out,
    output reg [15:0] instruction_out
);
always @(posedge clk) begin
    if (reset || flush) begin
        pc_out <= 16'h0000;
        instruction_out <= 16'h0000;  // NOP(no operation bubble)
    end
    else if (stall) begin
        pc_out <= pc_out;
        instruction_out <= instruction_out;
    end
    else begin
        pc_out <= pc_in;
        instruction_out <= instruction_in;
    end
end
endmodule