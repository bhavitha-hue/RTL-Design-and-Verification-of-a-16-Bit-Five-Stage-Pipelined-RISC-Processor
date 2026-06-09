module pipeline_id_ex(
    input clk,
    input reset,
    input stall,
    input flush, // insert NOP bubble
    input [15:0] pc_in,          
    input [15:0] read_data1_in,
    input [15:0] read_data2_in,
    input [2:0]  rs1_in, // for forwarding unit
    input [2:0]  rs2_in, // for forwarding unit
    input [2:0]  rd_in,
    input [8:0]  immediate_in,
    input [3:0] alu_op_in,
    input alu_src_in, // selects rs2 or immediate
    input mem_to_reg_in,
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input [1:0] branch_in,// 2-bit for BEQ/BNE
    input jump_in,
    input halt_in,

    output reg [15:0] pc_out,
    output reg [15:0] read_data1_out,
    output reg [15:0] read_data2_out,
    output reg [2:0] rs1_out,         
    output reg [2:0] rs2_out,         
    output reg [2:0] rd_out,
    output reg [8:0] immediate_out,
    output reg [3:0] alu_op_out,
    output reg alu_src_out,    
    output reg mem_to_reg_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg [1:0] branch_out,     
    output reg jump_out,
    output reg halt_out
);

always @(posedge clk) begin
    if (reset || flush) begin
        pc_out <= 16'h0000;
        read_data1_out <= 16'h0000;
        read_data2_out <= 16'h0000;
        rs1_out <= 3'b000;
        rs2_out <= 3'b000;
        rd_out <= 3'b000;
        immediate_out <= 9'b0;
        alu_op_out <= 4'b0000;
        alu_src_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
        reg_write_out <= 1'b0; // no writeback
        mem_read_out <= 1'b0;
        mem_write_out <= 1'b0;
        branch_out <= 2'b00;   // no branch
        jump_out <= 1'b0;
        halt_out <= 1'b0;
    end
    else if (stall) begin
        pc_out <= pc_out;
        read_data1_out <= read_data1_out;
        read_data2_out <= read_data2_out;
        rs1_out <= rs1_out;
        rs2_out <= rs2_out;
        rd_out <= rd_out;
        immediate_out <= immediate_out;
        alu_op_out <= alu_op_out;
        alu_src_out <= alu_src_out;
        mem_to_reg_out <= mem_to_reg_out;
        reg_write_out <= reg_write_out;
        mem_read_out <= mem_read_out;
        mem_write_out <= mem_write_out;
        branch_out <= branch_out;
        jump_out <= jump_out;
        halt_out <= halt_out;
    end
    else begin
        pc_out <= pc_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        immediate_out <= immediate_in;
        alu_op_out <= alu_op_in;
        alu_src_out <= alu_src_in;
        mem_to_reg_out <= mem_to_reg_in;
        reg_write_out <= reg_write_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= mem_write_in;
        branch_out <= branch_in;
        jump_out <= jump_in;
        halt_out <= halt_in;
    end
end
endmodule