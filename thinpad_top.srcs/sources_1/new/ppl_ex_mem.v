`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_ex_mem(
    input wire clk,
    input wire rst,
    input wire stall,

    input wire[6:0] ex_alu_opcode,
    input wire[2:0] ex_alu_funct3,
    input wire ex_regd_en,
    input wire[4:0] ex_regd_addr,
    input wire[31:0] ex_data,
    input wire[31:0] ex_mem_addr,
    input wire ex_mem_en,
    input wire[3:0] ex_mem_be_n,

    output reg[6:0] mem_alu_opcode,
    output reg[2:0] mem_alu_funct3,
    output reg mem_regd_en,
    output reg[4:0] mem_regd_addr,
    output reg[31:0] mem_data,
    output reg[31:0] mem_addr,
    output reg mem_en,
    output reg[3:0] mem_be_n
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_alu_opcode <= `OP_NOP;
        mem_alu_funct3 <= `FUNCT3_NOP;
        mem_regd_en <= 0;
        mem_regd_addr <= 5'b0;
        mem_data <= 32'b0;
        mem_addr <= 32'b0;
        mem_en <= 0;
        mem_be_n <= 4'b0;
    end
    // else if (stall) begin
    //     mem_alu_opcode <= mem_alu_opcode;
    //     mem_alu_funct3 <= mem_alu_funct3;
    //     mem_regd_en <= mem_regd_en;
    //     mem_regd_addr <= mem_regd_addr;
    //     mem_data <= mem_data;
    //     mem_addr <= mem_addr;
    //     mem_en <= mem_en;
    //     mem_be_n <= mem_be_n;
    // end
    else begin
        mem_alu_opcode <= ex_alu_opcode;
        mem_alu_funct3 <= ex_alu_funct3;
        mem_regd_en <= ex_regd_en;
        mem_regd_addr <= ex_regd_addr;
        mem_data <= ex_data;
        mem_addr <= ex_mem_addr;
        mem_en <= ex_mem_en;
        mem_be_n <= ex_mem_be_n;
    end
end

endmodule
