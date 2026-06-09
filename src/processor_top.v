module processor_top(
    input clk,
    input reset,
    output halt_out
);
wire stall;
wire flush_if_id;
wire flush_id_ex;
wire pc_write;
wire [1:0] forward_a;
wire [1:0] forward_b;

// IF STAGE
wire [15:0] pc;
wire [15:0] pc_next;
wire pc_load;
wire [15:0] instruction;

program_counter PC (
    .clk (clk),
    .reset (reset),
    .enable (pc_write),
    .load (pc_load),
    .pc_next (pc_next),
    .pc (pc)
);

instruction_memory IM (
    .address (pc),
    .instruction(instruction)
);

wire [15:0] if_id_pc;
wire [15:0] if_id_instruction;

pipeline_if_id IF_ID (
    .clk (clk),
    .reset (reset),
    .stall (stall),
    .flush (flush_if_id),
    .pc_in (pc),
    .instruction_in (instruction),
    .pc_out (if_id_pc),
    .instruction_out (if_id_instruction)
);

wire [3:0] opcode = if_id_instruction[15:12];
wire [2:0] rd = if_id_instruction[11:9];
wire [2:0] rs1 = if_id_instruction[8:6];
wire [2:0] rs2 = if_id_instruction[5:3];
wire [8:0] immediate = if_id_instruction[8:0];
wire [3:0] alu_op;
wire alu_src;
wire reg_write, mem_read, mem_write, mem_to_reg;
wire [1:0] branch;
wire jump, halt;
wire invalid_op;

control_unit CU (
    .opcode (opcode),
    .alu_op (alu_op),
    .alu_src (alu_src),
    .reg_write (reg_write),
    .mem_read (mem_read),
    .mem_write (mem_write),
    .mem_to_reg (mem_to_reg),
    .branch (branch),
    .jump (jump),
    .halt (halt),
    .invalid_op (invalid_op)
);

wire [15:0] wb_write_data;
wire [2:0] wb_rd;
wire wb_reg_write;
wire [15:0] read_data1;
wire [15:0] read_data2;

register_file RF (
    .clk (clk),
    .reset (reset),
    .reg_write (wb_reg_write),
    .rs1 (rs1),
    .rs2 (rs2),
    .rd (wb_rd),
    .write_data (wb_write_data),
    .read_data1 (read_data1),
    .read_data2 (read_data2)
);

wire [15:0] id_ex_pc;
wire [15:0] id_ex_read_data1, id_ex_read_data2;
wire [2:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
wire [8:0] id_ex_immediate;
wire [3:0] id_ex_alu_op;
wire id_ex_alu_src;
wire id_ex_mem_to_reg, id_ex_reg_write;
wire id_ex_mem_read, id_ex_mem_write;
wire [1:0] id_ex_branch;
wire id_ex_jump, id_ex_halt;

pipeline_id_ex ID_EX (
    .clk (clk),
    .reset (reset),
    .stall (stall),
    .flush (flush_id_ex),
    .pc_in (if_id_pc),
    .read_data1_in (read_data1),
    .read_data2_in (read_data2),
    .rs1_in (rs1),
    .rs2_in (rs2),
    .rd_in (rd),
    .immediate_in (immediate),
    .alu_op_in (alu_op),
    .alu_src_in (alu_src),
    .mem_to_reg_in (mem_to_reg),
    .reg_write_in (reg_write),
    .mem_read_in (mem_read),
    .mem_write_in (mem_write),
    .branch_in (branch),
    .jump_in (jump),
    .halt_in (halt),
    .pc_out (id_ex_pc),
    .read_data1_out (id_ex_read_data1),
    .read_data2_out (id_ex_read_data2),
    .rs1_out (id_ex_rs1),
    .rs2_out (id_ex_rs2),
    .rd_out (id_ex_rd),
    .immediate_out (id_ex_immediate),
    .alu_op_out (id_ex_alu_op),
    .alu_src_out (id_ex_alu_src),
    .mem_to_reg_out (id_ex_mem_to_reg),
    .reg_write_out (id_ex_reg_write),
    .mem_read_out (id_ex_mem_read),
    .mem_write_out (id_ex_mem_write),
    .branch_out (id_ex_branch),
    .jump_out (id_ex_jump),
    .halt_out (id_ex_halt)
);

wire [15:0] mem_wb_memory_data;
wire [15:0] mem_wb_alu_result;
wire [2:0] mem_wb_rd;
wire mem_wb_reg_write;
wire mem_wb_mem_to_reg;
wire mem_wb_halt;

assign wb_write_data = mem_wb_mem_to_reg? mem_wb_memory_data : mem_wb_alu_result;
assign wb_rd = mem_wb_rd;
assign wb_reg_write = mem_wb_reg_write;

wire [15:0] imm_extended = {{7{id_ex_immediate[8]}}, id_ex_immediate};
wire [15:0] ex_mem_alu_result;
wire [15:0] alu_a =(forward_a == 2'b10) ? ex_mem_alu_result :
                   (forward_a == 2'b01) ? wb_write_data     :
                                           id_ex_read_data1;
wire [15:0] alu_b_reg =(forward_b == 2'b10) ? ex_mem_alu_result :
                       (forward_b == 2'b01) ? wb_write_data     :
                                            id_ex_read_data2;
wire [15:0] alu_b = id_ex_alu_src ? imm_extended : alu_b_reg;
wire [15:0] branch_target = id_ex_pc + imm_extended;

wire [15:0] alu_result;
wire zero_flag, carry_flag, negative_flag, overflow_flag;

alu ALU (
    .a (alu_a),
    .b (alu_b),
    .alu_op (id_ex_alu_op),
    .result (alu_result),
    .zero_flag (zero_flag),
    .carry_flag (carry_flag),
    .negative_flag (negative_flag),
    .overflow_flag (overflow_flag)
);

wire [15:0] ex_mem_pc_branch;
wire [15:0] ex_mem_write_data;
wire [2:0] ex_mem_rd;
wire ex_mem_zero_flag, ex_mem_carry_flag;
wire ex_mem_negative_flag, ex_mem_overflow_flag;
wire ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write;
wire ex_mem_mem_to_reg;
wire [1:0] ex_mem_branch;
wire ex_mem_jump, ex_mem_halt;

pipeline_ex_mem EX_MEM (
    .clk (clk),
    .reset (reset),
    .stall (stall),
    .flush (1'b0),
    .pc_branch_in (branch_target),
    .alu_result_in (alu_result),
    .write_data_in (alu_b_reg),
    .rd_in (id_ex_rd),
    .zero_flag_in (zero_flag),
    .carry_flag_in (carry_flag),
    .negative_flag_in (negative_flag),
    .overflow_flag_in (overflow_flag),
    .reg_write_in (id_ex_reg_write),
    .mem_read_in (id_ex_mem_read),
    .mem_write_in (id_ex_mem_write),
    .mem_to_reg_in (id_ex_mem_to_reg),
    .branch_in (id_ex_branch),
    .jump_in (id_ex_jump),
    .halt_in (id_ex_halt),
    .pc_branch_out (ex_mem_pc_branch),
    .alu_result_out (ex_mem_alu_result),
    .write_data_out (ex_mem_write_data),
    .rd_out (ex_mem_rd),
    .zero_flag_out (ex_mem_zero_flag),
    .carry_flag_out (ex_mem_carry_flag),
    .negative_flag_out (ex_mem_negative_flag),
    .overflow_flag_out (ex_mem_overflow_flag),
    .reg_write_out (ex_mem_reg_write),
    .mem_read_out (ex_mem_mem_read),
    .mem_write_out (ex_mem_mem_write),
    .mem_to_reg_out (ex_mem_mem_to_reg),
    .branch_out (ex_mem_branch),
    .jump_out (ex_mem_jump),
    .halt_out (ex_mem_halt)
);

wire branch_taken =((ex_mem_branch == 2'b01) &&  ex_mem_zero_flag) ||((ex_mem_branch == 2'b10) && !ex_mem_zero_flag);
assign pc_load = branch_taken || ex_mem_jump;
assign pc_next = ex_mem_pc_branch;

wire [15:0] memory_data;
data_memory DM (
    .clk (clk),
    .reset (reset),
    .mem_read (ex_mem_mem_read),
    .mem_write (ex_mem_mem_write),
    .address (ex_mem_alu_result),
    .write_data (ex_mem_write_data),
    .read_data (memory_data)
);

pipeline_mem_wb MEM_WB (
    .clk (clk),
    .reset (reset),
    .stall (stall),
    .flush (1'b0),
    .pc_in (ex_mem_pc_branch),
    .memory_data_in (memory_data),
    .alu_result_in (ex_mem_alu_result),
    .rd_in (ex_mem_rd),
    .reg_write_in (ex_mem_reg_write),
    .mem_to_reg_in (ex_mem_mem_to_reg),
    .halt_in (ex_mem_halt),
    .memory_data_out (mem_wb_memory_data),
    .alu_result_out (mem_wb_alu_result),
    .rd_out (mem_wb_rd),
    .reg_write_out (mem_wb_reg_write),
    .mem_to_reg_out (mem_wb_mem_to_reg),
    .halt_out (mem_wb_halt)
);

hazard_detection_unit HDU (
    .id_ex_mem_read (id_ex_mem_read),
    .id_ex_rd (id_ex_rd),
    .if_id_rs1 (rs1),
    .if_id_rs2 (rs2),
    .ex_mem_branch (ex_mem_branch),
    .ex_mem_jump (ex_mem_jump),
    .ex_mem_zero_flag (ex_mem_zero_flag),
    .stall (stall),
    .flush_if_id (flush_if_id),
    .flush_id_ex (flush_id_ex),
    .pc_write (pc_write)
);

forwarding_unit FU (
    .id_ex_rs1 (id_ex_rs1),
    .id_ex_rs2 (id_ex_rs2),
    .ex_mem_reg_write (ex_mem_reg_write),
    .ex_mem_rd (ex_mem_rd),
    .mem_wb_reg_write (mem_wb_reg_write),
    .mem_wb_rd (mem_wb_rd),
    .forward_a (forward_a),
    .forward_b (forward_b)
);
assign halt_out = mem_wb_halt;
endmodule