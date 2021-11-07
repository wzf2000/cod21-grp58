`timescale 1ns / 1ps

module ppl_if_id(
    input wire clk,
    input wire rst,

    input wire[31:0] if_pc,

    input wire stall,

    input wire[31:0] ram_data,
    
    input wire branch_predict, // 1: jump, 0: not jump

    output reg[31:0] id_pc,
    output reg[31:0] id_instr
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        id_pc <= 32'b0;
        id_instr <= 32'b0;
    end
    else begin
        if (stall) begin
            id_pc <= id_pc;
            id_instr <= id_instr;
        end
        else if (branch_predict) begin
            id_pc <= 32'b0;
            id_instr <= 32'b0;
        end
        else begin
            id_pc <= if_pc;
            id_instr <= ram_data;
        end
    end
end

endmodule
