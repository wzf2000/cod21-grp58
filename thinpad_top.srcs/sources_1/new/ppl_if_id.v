`timescale 1ns / 1ps

module ppl_if_id(
    input wire clk,
    input wire rst,

    input wire[31:0] if_pc,

    input wire stall,
    output reg excpreq_out,
    input wire[3:0] excp,

    input wire[31:0] ram_data,

    input wire if_bubble, // 1: busy, 0: not busy
    input wire branch_predict, // 1: jump, 0: not jump

    output reg[31:0] id_pc,
    output reg[31:0] id_instr
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        id_pc <= 32'b0;
        id_instr <= 32'b0;
        excpreq_out <= 0;
    end
    else begin
        if (stall) begin
            id_pc <= id_pc;
            id_instr <= id_instr;
            excpreq_out <= 0;
        end
        else if (excp[1]) begin
            id_pc <= 32'b0;
            id_instr <= 32'b0;
            excpreq_out <= 0;
        end
        else if (branch_predict | if_bubble) begin
            id_pc <= 32'b0;
            id_instr <= 32'b0;
            excpreq_out <= excp[0] & !excp[1];
        end
        else begin
            id_pc <= if_pc;
            id_instr <= ram_data;
            excpreq_out <= excp[0] & !excp[1];
        end
    end
end

endmodule
