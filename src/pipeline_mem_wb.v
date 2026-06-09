module pipeline_mem_wb(
    input clk,
    input reset,
    input stall,            
    input flush,            
    input [15:0] pc_in,           
    input [15:0] memory_data_in,
    input [15:0] alu_result_in,
    input [2:0]  rd_in,
    input reg_write_in,
    input mem_to_reg_in,
    input halt_in,     

    output reg [15:0] pc_out,
    output reg [15:0] memory_data_out,
    output reg [15:0] alu_result_out,
    output reg [2:0] rd_out,
    output reg reg_write_out,
    output reg mem_to_reg_out,
    output reg halt_out          
);

always @(posedge clk) begin
    if (reset || flush) begin
        pc_out <= 16'h0000;
        memory_data_out <= 16'h0000;
        alu_result_out <= 16'h0000;
        rd_out <= 3'b000;
        reg_write_out <= 1'b0;      
        mem_to_reg_out <= 1'b0;
        halt_out <= 1'b0;
    end
    else if (stall) begin
        pc_out <= pc_out;
        memory_data_out <= memory_data_out;
        alu_result_out <= alu_result_out;
        rd_out <= rd_out;
        reg_write_out <= reg_write_out;
        mem_to_reg_out <= mem_to_reg_out;
        halt_out <= halt_out;
    end
    else begin
        pc_out <= pc_in;
        memory_data_out <= memory_data_in;
        alu_result_out <= alu_result_in;
        rd_out <= rd_in;
        reg_write_out <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        halt_out <= halt_in;
    end
end
endmodule