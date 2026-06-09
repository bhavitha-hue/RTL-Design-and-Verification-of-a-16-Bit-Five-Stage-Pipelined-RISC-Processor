module pipeline_ex_mem(
    input clk,
    input reset,
    input stall,            
    input flush,             
    input [15:0] pc_branch_in,     
    input [15:0] alu_result_in,
    input [15:0] write_data_in,
    input [2:0]  rd_in,
    input zero_flag_in,       
    input negative_flag_in,   
    input carry_flag_in,      
    input overflow_flag_in,   
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input mem_to_reg_in,
    input [1:0] branch_in,        
    input jump_in,            
    input halt_in,            

    output reg [15:0] pc_branch_out,
    output reg [15:0] alu_result_out,
    output reg [15:0] write_data_out,
    output reg [2:0]  rd_out,
    output reg zero_flag_out,
    output reg negative_flag_out,
    output reg carry_flag_out,
    output reg overflow_flag_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg [1:0] branch_out,         
    output reg jump_out,
    output reg halt_out
);
always @(posedge clk) begin
    if (reset || flush) begin
        pc_branch_out <= 16'h0000;
        alu_result_out <= 16'h0000;
        write_data_out <= 16'h0000;
        rd_out <= 3'b000;
        zero_flag_out <= 1'b0;
        negative_flag_out <= 1'b0;
        carry_flag_out <= 1'b0;
        overflow_flag_out <= 1'b0;
        reg_write_out <= 1'b0; // no writeback
        mem_read_out <= 1'b0;
        mem_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
        branch_out <= 2'b00; // no branch
        jump_out <= 1'b0;
        halt_out <= 1'b0;
    end
    else if (stall) begin
        pc_branch_out <= pc_branch_out;
        alu_result_out <= alu_result_out;
        write_data_out <= write_data_out;
        rd_out <= rd_out;
        zero_flag_out <= zero_flag_out;
        negative_flag_out <= negative_flag_out;
        carry_flag_out <= carry_flag_out;
        overflow_flag_out <= overflow_flag_out;
        reg_write_out <= reg_write_out;
        mem_read_out <= mem_read_out;
        mem_write_out <= mem_write_out;
        mem_to_reg_out <= mem_to_reg_out;
        branch_out <= branch_out;
        jump_out <= jump_out;
        halt_out <= halt_out;
    end
    else begin
        pc_branch_out <= pc_branch_in;
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        rd_out <= rd_in;
        zero_flag_out <= zero_flag_in;
        negative_flag_out <= negative_flag_in;
        carry_flag_out <= carry_flag_in;
        overflow_flag_out <= overflow_flag_in;
        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        branch_out <= branch_in;
        jump_out <= jump_in;
        halt_out <= halt_in;
    end
end
endmodule