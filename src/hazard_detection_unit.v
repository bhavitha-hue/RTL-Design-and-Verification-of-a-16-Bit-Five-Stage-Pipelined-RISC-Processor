module hazard_detection_unit(
    input id_ex_mem_read,   
    input [2:0] id_ex_rd,       
    input [2:0] if_id_rs1,        
    input [2:0] if_id_rs2,        
    input [1:0] ex_mem_branch,    
    input ex_mem_jump,     
    input ex_mem_zero_flag,

    output reg stall,            
    output reg flush_if_id,      
    output reg flush_id_ex,      
    output reg pc_write         
);
    wire load_use_hazard;
    wire branch_taken;
    assign load_use_hazard =id_ex_mem_read &&(id_ex_rd != 3'b000) &&((id_ex_rd == if_id_rs1) ||(id_ex_rd == if_id_rs2));
    assign branch_taken =((ex_mem_branch == 2'b01) &&  ex_mem_zero_flag) ||  // BEQ 
                         ((ex_mem_branch == 2'b10) && !ex_mem_zero_flag) ||  // BNE 
                           ex_mem_jump;   // JUMP 
    always @(*) begin
        stall = 1'b0;
        flush_if_id = 1'b0;
        flush_id_ex = 1'b0;
        pc_write = 1'b1;  
        if (load_use_hazard) begin
            stall = 1'b1;
            pc_write = 1'b0;   
            flush_id_ex = 1'b1;   
            flush_if_id = 1'b0;  
        end
        else if (branch_taken) begin
            flush_if_id = 1'b1;   
            flush_id_ex = 1'b1;  
            pc_write = 1'b1;  
        end
    end
endmodule