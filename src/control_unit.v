module control_unit(
    input [3:0] opcode,
    output reg [3:0] alu_op,
    output reg alu_src, // 0=rs2, 1=immediate
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg [1:0] branch, // 00=no branch, 01=BEQ, 10=BNE 
    output reg jump,
    output reg halt,
    output reg invalid_op  // shows unknown opcode
);
always @(*) begin
    alu_op = 4'b0000;
    alu_src = 1'b0; // default rs2
    reg_write = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_to_reg= 1'b0;
    branch = 2'b00; 
    jump = 1'b0;
    halt = 1'b0;
    invalid_op = 1'b0;

    case(opcode)

        4'b0000: begin // ADD
            alu_op = 4'b0000;
            reg_write = 1'b1;
        end
        4'b0001: begin // SUB
            alu_op = 4'b0001;
            reg_write = 1'b1;
        end
        4'b0010: begin // AND
            alu_op = 4'b0010;
            reg_write = 1'b1;
        end
        4'b0011: begin // OR
            alu_op = 4'b0011;
            reg_write = 1'b1;
        end
        4'b1000: begin // XOR
            alu_op = 4'b0100;
            reg_write = 1'b1;
        end
        4'b1001: begin // NOT
            alu_op = 4'b0101;
            reg_write = 1'b1;
        end
        4'b1010: begin // SHL (shift left)
            alu_op = 4'b0110;
            reg_write = 1'b1;
        end
        4'b1011: begin // SHR (shift right)
            alu_op = 4'b0111;
            reg_write = 1'b1;
        end
        4'b0100: begin // LOAD
            alu_op = 4'b0000;  
            alu_src = 1'b1; // use immediate
            mem_read = 1'b1;
            reg_write = 1'b1;
            mem_to_reg = 1'b1;
        end
        4'b0101: begin // STORE
            alu_op = 4'b0000;  
            alu_src = 1'b1; // use immediate 
            mem_write = 1'b1;
        end
        4'b1100: begin // ADDI(add intermediate)
            alu_op = 4'b0000;
            alu_src = 1'b1; // use immediate
            reg_write = 1'b1;
        end
        4'b0110: begin // BEQ(branch equal)
            alu_op = 4'b0001; // subtract to compare
            branch = 2'b01; // branch if zero flag set
        end

        4'b1101: begin // BNE(branch if not equal)
            alu_op = 4'b0001; // subtract to compare
            branch = 2'b10; // branch if zero flag NOT set
        end
        4'b0111: begin // JUMP
            jump = 1'b1;
        end
        4'b1111: begin // HALT
            halt = 1'b1;
        end
        default: begin
            invalid_op = 1'b1;
        end
    endcase
end
endmodule