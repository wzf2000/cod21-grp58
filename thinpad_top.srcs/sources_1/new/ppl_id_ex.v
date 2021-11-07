`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_id_ex(
    input wire clk,
    input wire rst,

    input wire stall,

    input wire[31:0] id_pc,
    input wire [6:0] id_alu_opcode,
    input wire [2:0] id_alu_funct3,
    input wire [6:0] id_alu_funct7,
    input wire [31:0] id_regs1,
    input wire [31:0] id_regs2,
    input wire [4:0] id_regd_addr,
    input wire id_regd_en,
    input wire[31:0] id_ret_addr,
    input wire id_mem_en,
    input wire[31:0] id_mem_addr,

    output reg[31:0] ex_pc,
    output reg[6:0] ex_alu_opcode,
    output reg[2:0] ex_alu_funct3,
    output reg[6:0] ex_alu_funct7,
    output reg[31:0] ex_regs1,
    output reg[31:0] ex_regs2,
    output reg[4:0] ex_regd_addr,
    output reg ex_regd_en,
    output reg[31:0] ex_ret_addr,
    output reg ex_mem_en,
    output reg[31:0] ex_mem_addr
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ex_pc <= 32'b0;
        ex_alu_opcode <= `OP_NOP;
        ex_alu_funct3 <= `FUNCT3_NOP;
        ex_alu_funct7 <= `FUNCT7_NOP;
        ex_regs1 <= 32'b0;
        ex_regs2 <= 32'b0;
        ex_regd_addr <= 5'b0;
        ex_regd_en <= 0;
        ex_ret_addr <= 32'b0;
        ex_mem_en <= 0;
        ex_mem_addr <= 32'b0;
    end
    else if (stall) begin
        ex_pc <= 32'b0;
        ex_alu_opcode <= `OP_NOP;
        ex_alu_funct3 <= `FUNCT3_NOP;
        ex_alu_funct7 <= `FUNCT7_NOP;
        ex_regs1 <= 32'b0;
        ex_regs2 <= 32'b0;
        ex_regd_addr <= 5'b0;
        ex_regd_en <= 0;
        ex_ret_addr <= 32'b0;
        ex_mem_en <= 0;
        ex_mem_addr <= 32'b0;
    end
    else begin
        ex_pc <= id_pc;
        ex_alu_opcode <= id_alu_opcode;
        ex_alu_funct3 <= id_alu_funct3;
        ex_alu_funct7 <= id_alu_funct7;
        ex_regs1 <= id_regs1;
        ex_regs2 <= id_regs2;
        ex_regd_addr <= id_regd_addr;
        ex_regd_en <= id_regd_en;
        ex_ret_addr <= id_ret_addr;
        ex_mem_en <= id_mem_en;
        ex_mem_addr <= id_mem_addr;
    end
end

endmodule
