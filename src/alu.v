module alu (
    input [15:0] a,  // always from rs1
    input [15:0] b,  // from mux: rs2 or immediate
    input [3:0] alu_op,
    output [15:0] result,
    output zero_flag,    // result == 0
    output carry_flag,   // unsigned overflow
    output negative_flag,// result is negative
    output overflow_flag // signed overflow
);
    reg [16:0] temp;  // 17-bit to capture carry
    always @(*) begin
        temp = 17'd0; 
        case(alu_op)
            4'b0000: temp = {1'b0, a} + {1'b0, b};  // ADD
            4'b0001: temp = {1'b0, a} - {1'b0, b};  // SUB
            4'b0010: temp = {1'b0, a  & b};   // AND
            4'b0011: temp = {1'b0, a  | b};   // OR
            4'b0100: temp = {1'b0, a  ^ b};   // XOR
            4'b0101: temp = {1'b0, ~a};       // NOT 
            4'b0110: temp = {1'b0, a  << b[3:0]};   // SHL
            4'b0111: temp = {1'b0, a  >> b[3:0]};   // SHR
            default: temp = 17'b0;
        endcase
    end

    assign result = temp[15:0];
    assign zero_flag = (result == 16'h0000);           
    assign carry_flag = temp[16];     // 17th bit = carry
    assign negative_flag = result[15];   // MSB = sign bit
    assign overflow_flag = (alu_op == 4'b0000) ? (~a[15] & ~b[15] &  result[15]) |  ( a[15] &  b[15] & ~result[15])   
                           : (alu_op == 4'b0001) ? (~a[15] &  b[15] &  result[15]) | ( a[15] & ~b[15] & ~result[15]) 
                           : 1'b0;                       
endmodule