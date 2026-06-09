module forwarding_unit(
    input [2:0] id_ex_rs1,        
    input [2:0] id_ex_rs2,        
    input ex_mem_reg_write, 
    input [2:0] ex_mem_rd,        
    input mem_wb_reg_write, 
    input [2:0] mem_wb_rd,

    output reg [1:0] forward_a,        
    output reg [1:0] forward_b     
);
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX/MEM forwarding (higher priority — more recent value)
        if (ex_mem_reg_write &&(ex_mem_rd != 3'b000) &&(ex_mem_rd == id_ex_rs1))
        begin
            forward_a = 2'b10;
        end
        // MEM/WB forwarding (lower priority — older value)
        else if (mem_wb_reg_write &&(mem_wb_rd != 3'b000) &&(mem_wb_rd == id_ex_rs1))
        begin
            forward_a = 2'b01;  
        end

        // EX/MEM forwarding (higher priority — more recent value)
        if (ex_mem_reg_write &&(ex_mem_rd != 3'b000) &&(ex_mem_rd == id_ex_rs2))
        begin
            forward_b = 2'b10;  
        end
        // MEM/WB forwarding (lower priority — older value)
        else if (mem_wb_reg_write &&(mem_wb_rd != 3'b000) &&(mem_wb_rd == id_ex_rs2))
        begin
            forward_b = 2'b01;   
        end
    end
endmodule