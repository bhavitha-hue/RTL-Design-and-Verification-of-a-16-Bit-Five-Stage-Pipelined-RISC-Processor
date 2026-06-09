module register_file(
    input clk,
    input reset,
    input reg_write,
    input [2:0]  rs1,  //register sorce 1
    input [2:0]  rs2, //register source 2
    input [2:0]  rd, //register destination
    input [15:0] write_data,
    output [15:0] read_data1,  
    output [15:0] read_data2 
);
    reg [15:0] regs [0:7];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 16'd0;
        end
        else if (reg_write && (rd != 3'b000))
            regs[rd] <= write_data;
    end
    assign read_data1 = (reg_write && (rd == rs1) && (rd != 3'b000))? write_data : regs[rs1];
    assign read_data2 = (reg_write && (rd == rs2) && (rd != 3'b000))? write_data : regs[rs2];
endmodule