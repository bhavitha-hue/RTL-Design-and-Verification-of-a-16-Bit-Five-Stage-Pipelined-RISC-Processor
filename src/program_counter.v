module program_counter(
    input clk,
    input reset,
    input enable,      
    input load, // 1 = for jumps/branches
    input [15:0] pc_next, // target address for jump/branch
    output reg [15:0] pc
);
always @(posedge clk) begin
    if (reset)
        pc <= 16'd0;
    else if (enable) begin
        if (load)
            pc <= pc_next; // jump / branch
        else
            pc <= pc + 16'd1;
    end
end
endmodule