`default_nettype none
`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_id_ex(
    input wire clk,
    input wire rst,

    input wire stall,
    output reg excpreq_out,
    input wire[3:0] excp,

    input wire[31:0] id_pc,
    input wire [6:0] id_alu_opcode,
    input wire [2:0] id_alu_funct3,
    input wire [6:0] id_alu_funct7,
    input wire [11:0] id_alu_funct_csr,
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
    output reg[11:0] ex_alu_funct_csr,
    output reg[31:0] ex_regs1,
    output reg[31:0] ex_regs2,
    output reg[4:0] ex_regd_addr,
    output reg ex_regd_en,
    output reg[31:0] ex_ret_addr,
    output reg ex_mem_en,
    output reg[31:0] ex_mem_addr,

    input wire id_mtvec_we,
    input wire id_mscratch_we,
    input wire id_mepc_we,
    input wire id_mcause_we,
    input wire id_mstatus_we,
    input wire id_mie_we,
    input wire id_mip_we,
    input wire id_priv_we,
    input wire id_satp_we,
    input wire id_mtval_we,
    input wire id_mideleg_we,
    input wire id_medeleg_we,
    input wire id_sepc_we,
    input wire id_scause_we,
    input wire id_stval_we,
    input wire id_stvec_we,
    input wire id_sscratch_we,

    output reg ex_mtvec_we,
    output reg ex_mscratch_we,
    output reg ex_mepc_we,
    output reg ex_mcause_we,
    output reg ex_mstatus_we,
    output reg ex_mie_we,
    output reg ex_mip_we,
    output reg ex_priv_we,
    output reg ex_satp_we,
    output reg ex_mtval_we,
    output reg ex_mideleg_we,
    output reg ex_medeleg_we,
    output reg ex_sepc_we,
    output reg ex_scause_we,
    output reg ex_stval_we,
    output reg ex_stvec_we,
    output reg ex_sscratch_we,

    input wire [31:0] id_mtvec_data,
    input wire [31:0] id_mscratch_data,
    input wire [31:0] id_mepc_data,
    input wire [31:0] id_mcause_data,
    input wire [31:0] id_mstatus_data,
    input wire [31:0] id_mie_data,
    input wire [31:0] id_mip_data,
    input wire [31:0] id_satp_data,
    input wire [1:0] id_priv_data,
    input wire [31:0] id_mtval_data,
    input wire [31:0] id_mideleg_data,
    input wire [31:0] id_medeleg_data,
    input wire [31:0] id_sepc_data,
    input wire [31:0] id_scause_data,
    input wire [31:0] id_stval_data,
    input wire [31:0] id_stvec_data,
    input wire [31:0] id_sscratch_data,

    output reg [31:0] ex_mtvec_data,
    output reg [31:0] ex_mscratch_data,
    output reg [31:0] ex_mepc_data,
    output reg [31:0] ex_mcause_data,
    output reg [31:0] ex_mstatus_data,
    output reg [31:0] ex_mie_data,
    output reg [31:0] ex_mip_data,
    output reg [31:0] ex_satp_data,
    output reg [1:0] ex_priv_data,
    output reg [31:0] ex_mtval_data,
    output reg [31:0] ex_mideleg_data,
    output reg [31:0] ex_medeleg_data,
    output reg [31:0] ex_sepc_data,
    output reg [31:0] ex_scause_data,
    output reg [31:0] ex_stval_data,
    output reg [31:0] ex_stvec_data,
    output reg [31:0] ex_sscratch_data
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ex_pc <= 32'b0;
        ex_alu_opcode <= `OP_NOP;
        ex_alu_funct3 <= `FUNCT3_NOP;
        ex_alu_funct7 <= `FUNCT7_NOP;
        ex_alu_funct_csr <= 0;
        ex_regs1 <= 32'b0;
        ex_regs2 <= 32'b0;
        ex_regd_addr <= 5'b0;
        ex_regd_en <= 0;
        ex_ret_addr <= 32'b0;
        ex_mem_en <= 0;
        ex_mem_addr <= 32'b0;

        ex_mtvec_we <= 0;
        ex_mscratch_we <= 0;
        ex_mepc_we <= 0;
        ex_mcause_we <= 0;
        ex_mstatus_we <= 0;
        ex_mie_we <= 0;
        ex_mip_we <= 0;
        ex_priv_we <= 0;
        ex_satp_we <= 0;
        ex_mtval_we <= 0;
        ex_mideleg_we <= 0;
        ex_medeleg_we <= 0;
        ex_sepc_we <= 0;
        ex_scause_we <= 0;
        ex_stval_we <= 0;
        ex_stvec_we <= 0;
        ex_sscratch_we <= 0;

        ex_mtvec_data <= 32'b0;
        ex_mscratch_data <= 32'b0;
        ex_mepc_data <= 32'b0;
        ex_mcause_data <= 32'b0;
        ex_mstatus_data <= 32'b0;
        ex_mie_data <= 32'b0;
        ex_mip_data <= 32'b0;
        ex_satp_data <= 32'b0;
        ex_priv_data <= 2'b0;
        ex_mtval_data <= 32'b0;
        ex_mideleg_data <= 32'b0;
        ex_medeleg_data <= 32'b0;
        ex_sepc_data <= 32'b0;
        ex_scause_data <= 32'b0;
        ex_stval_data <= 32'b0;
        ex_stvec_data <= 32'b0;
        ex_sscratch_data <= 32'b0;

        excpreq_out <= 0;
    end
    else if (stall) begin
        ex_pc <= 32'b0;
        ex_alu_opcode <= `OP_NOP;
        ex_alu_funct3 <= `FUNCT3_NOP;
        ex_alu_funct7 <= `FUNCT7_NOP;
        ex_alu_funct_csr <= 0;
        ex_regs1 <= 32'b0;
        ex_regs2 <= 32'b0;
        ex_regd_addr <= 5'b0;
        ex_regd_en <= 0;
        ex_ret_addr <= 32'b0;
        ex_mem_en <= 0;
        ex_mem_addr <= 32'b0;

        ex_mtvec_we <= 0;
        ex_mscratch_we <= 0;
        ex_mepc_we <= 0;
        ex_mcause_we <= 0;
        ex_mstatus_we <= 0;
        ex_mie_we <= 0;
        ex_mip_we <= 0;
        ex_priv_we <= 0;
        ex_satp_we <= 0;
        ex_mtval_we <= 0;
        ex_mideleg_we <= 0;
        ex_medeleg_we <= 0;
        ex_sepc_we <= 0;
        ex_scause_we <= 0;
        ex_stval_we <= 0;
        ex_stvec_we <= 0;
        ex_sscratch_we <= 0;
        
        excpreq_out <= 0;
    end
    else if (excp[2]) begin
        ex_pc <= 32'b0;
        ex_alu_opcode <= `OP_NOP;
        ex_alu_funct3 <= `FUNCT3_NOP;
        ex_alu_funct7 <= `FUNCT7_NOP;
        ex_alu_funct_csr <= 0;
        ex_regs1 <= 32'b0;
        ex_regs2 <= 32'b0;
        ex_regd_addr <= 5'b0;
        ex_regd_en <= 0;
        ex_ret_addr <= 32'b0;
        ex_mem_en <= 0;
        ex_mem_addr <= 32'b0;

        ex_mtvec_we <= 0;
        ex_mscratch_we <= 0;
        ex_mepc_we <= 0;
        ex_mcause_we <= 0;
        ex_mstatus_we <= 0;
        ex_mie_we <= 0;
        ex_mip_we <= 0;
        ex_priv_we <= 0;
        ex_satp_we <= 0;
        ex_mtval_we <= 0;
        ex_mideleg_we <= 0;
        ex_medeleg_we <= 0;
        ex_sepc_we <= 0;
        ex_scause_we <= 0;
        ex_stval_we <= 0;
        ex_stvec_we <= 0;
        ex_sscratch_we <= 0;
        
        excpreq_out <= 0;
    end
    else begin
        ex_pc <= id_pc;
        ex_alu_opcode <= id_alu_opcode;
        ex_alu_funct3 <= id_alu_funct3;
        ex_alu_funct7 <= id_alu_funct7;
        ex_alu_funct_csr <= id_alu_funct_csr;
        ex_regs1 <= id_regs1;
        ex_regs2 <= id_regs2;
        ex_regd_addr <= id_regd_addr;
        ex_regd_en <= id_regd_en;
        ex_ret_addr <= id_ret_addr;
        ex_mem_en <= id_mem_en;
        ex_mem_addr <= id_mem_addr;
        
        ex_mtvec_data <= id_mtvec_data;
        ex_mscratch_data <= id_mscratch_data;
        ex_mepc_data <= id_mepc_data;
        ex_mcause_data <= id_mcause_data;
        ex_mstatus_data <= id_mstatus_data;
        ex_mie_data <= id_mie_data;
        ex_mip_data <= id_mip_data;
        ex_priv_data <= id_priv_data;
        ex_satp_data <= id_satp_data;
        ex_mtval_data <= id_mtval_data;
        ex_mideleg_data <= id_mideleg_data;
        ex_medeleg_data <= id_medeleg_data;
        ex_sepc_data <= id_sepc_data;
        ex_scause_data <= id_scause_data;
        ex_stval_data <= id_stval_data;
        ex_stvec_data <= id_stvec_data;
        ex_sscratch_data <= id_sscratch_data;

        ex_mtvec_we <= id_mtvec_we;
        ex_mscratch_we <= id_mscratch_we;
        ex_mepc_we <= id_mepc_we;
        ex_mcause_we <= id_mcause_we;
        ex_mstatus_we <= id_mstatus_we;
        ex_mie_we <= id_mie_we;
        ex_mip_we <= id_mip_we;
        ex_priv_we <= id_priv_we;
        ex_satp_we <= id_satp_we;
        ex_mtval_we <= id_mtval_we;
        ex_mideleg_we <= id_mideleg_we;
        ex_medeleg_we <= id_medeleg_we;
        ex_sepc_we <= id_sepc_we;
        ex_scause_we <= id_scause_we;
        ex_stval_we <= id_stval_we;
        ex_stvec_we <= id_stvec_we;
        ex_sscratch_we <= id_sscratch_we;
        
        excpreq_out <= excp[1] & !excp[2];
    end
end

endmodule
