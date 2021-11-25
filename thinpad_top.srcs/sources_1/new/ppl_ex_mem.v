`default_nettype none
`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_ex_mem(
    input wire clk,
    input wire rst,

    input wire stall,
    output reg excpreq_out,
    input wire[3:0] excp,

    input wire[31:0] ex_pc,
    input wire[6:0] ex_alu_opcode,
    input wire[2:0] ex_alu_funct3,
    input wire ex_regd_en,
    input wire[4:0] ex_regd_addr,
    input wire[31:0] ex_data,
    input wire[31:0] ex_mem_addr,
    input wire ex_mem_en,
    input wire[3:0] ex_mem_be_n,
    input wire[31:0] ex_satp_rd, //satp (read only)
    input wire[1:0] ex_priv_rd,
    
    input wire ctrl, //ctrl=1, update according to mem; ctrl=0, update according to ex.
    input wire[1:0] mem_phase_retro, //retro signals are from ppl_mem.v (combinatorial)
    input wire[31:0] mem_addr_retro,
    input wire tlb_valid_update,
    input wire [19:0] tlb_virtual_update,
    input wire [31:0] tlb_physical_update,

    output reg[31:0] mem_pc,
    output reg[6:0] mem_alu_opcode,
    output reg[2:0] mem_alu_funct3,
    output reg mem_regd_en,
    output reg[4:0] mem_regd_addr,
    output reg[31:0] mem_data,
    output reg[31:0] mem_addr,
    output reg[31:0] virtual_addr,
    output reg mem_en,
    output reg[3:0] mem_be_n,
    output reg[31:0] satp_rd,
    output reg[1:0] priv_rd,
    output reg[1:0] mem_phase,
    //TLB
    output reg tlb_valid,
    output reg [19:0] tlb_virtual,
    output reg [31:0] tlb_physical,

    input wire ex_mtvec_we,
    input wire ex_mscratch_we,
    input wire ex_mepc_we,
    input wire ex_mcause_we,
    input wire ex_mstatus_we,
    input wire ex_mie_we,
    input wire ex_mip_we,
    input wire ex_priv_we,
    input wire ex_satp_we,
    input wire ex_mtval_we,
    input wire ex_mideleg_we,
    input wire ex_medeleg_we,
    input wire ex_sepc_we,
    input wire ex_scause_we,
    input wire ex_stval_we,
    input wire ex_stvec_we,
    input wire ex_sscratch_we,

    output reg mem_mtvec_we,
    output reg mem_mscratch_we,
    output reg mem_mepc_we,
    output reg mem_mcause_we,
    output reg mem_mstatus_we,
    output reg mem_mie_we,
    output reg mem_mip_we,
    output reg mem_priv_we,
    output reg mem_satp_we,
    output reg mem_mtval_we,
    output reg mem_mideleg_we,
    output reg mem_medeleg_we,
    output reg mem_sepc_we,
    output reg mem_scause_we,
    output reg mem_stval_we,
    output reg mem_stvec_we,
    output reg mem_sscratch_we,

    input wire[31:0] ex_mtvec_data,
    input wire[31:0] ex_mscratch_data,
    input wire[31:0] ex_mepc_data,
    input wire[31:0] ex_mcause_data,
    input wire[31:0] ex_mstatus_data,
    input wire[31:0] ex_mie_data,
    input wire[31:0] ex_mip_data,
    input wire[31:0] ex_satp_data,
    input wire[1:0] ex_priv_data,
    input wire[31:0] ex_mtval_data,
    input wire[31:0] ex_mideleg_data,
    input wire[31:0] ex_medeleg_data,
    input wire[31:0] ex_sepc_data,
    input wire[31:0] ex_scause_data,
    input wire[31:0] ex_stval_data,
    input wire[31:0] ex_stvec_data,
    input wire[31:0] ex_sscratch_data,

    output reg[31:0] mem_mtvec_data,
    output reg[31:0] mem_mscratch_data,
    output reg[31:0] mem_mepc_data,
    output reg[31:0] mem_mcause_data,
    output reg[31:0] mem_mstatus_data,
    output reg[31:0] mem_mie_data,
    output reg[31:0] mem_mip_data,
    output reg[31:0] mem_satp_data,
    output reg[1:0] mem_priv_data,
    output reg[31:0] mem_mtval_data,
    output reg[31:0] mem_mideleg_data,
    output reg[31:0] mem_medeleg_data,
    output reg[31:0] mem_sepc_data,
    output reg[31:0] mem_scause_data,
    output reg[31:0] mem_stval_data,
    output reg[31:0] mem_stvec_data,
    output reg[31:0] mem_sscratch_data
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_pc <= 32'b0;
        mem_alu_opcode <= `OP_NOP;
        mem_alu_funct3 <= `FUNCT3_NOP;
        mem_regd_en <= 0;
        mem_regd_addr <= 5'b0;
        mem_data <= 32'b0;
        mem_addr <= 32'b0;
        virtual_addr <= 32'b0;
        mem_en <= 0;
        mem_be_n <= 4'b0;
        satp_rd <= 32'b0;
        priv_rd <= 2'b0;
        mem_phase <= 2'b0;
        tlb_valid <= 0;
        tlb_virtual <= 20'b0;
        tlb_physical <= 32'b0;

        mem_mtvec_we <= 0;
        mem_mscratch_we <= 0;
        mem_mepc_we <= 0;
        mem_mcause_we <= 0;
        mem_mstatus_we <= 0;
        mem_mie_we <= 0;
        mem_mip_we <= 0;
        mem_priv_we <= 0;
        mem_satp_we <= 0;
        mem_mtval_we <= 0;
        mem_mideleg_we <= 0;
        mem_medeleg_we <= 0;
        mem_sepc_we <= 0;
        mem_scause_we <= 0;
        mem_stval_we <= 0;
        mem_stvec_we <= 0;
        mem_sscratch_we <= 0;

        mem_mtvec_data <= 32'b0;
        mem_mscratch_data <= 32'b0;
        mem_mepc_data <= 32'b0;
        mem_mcause_data <= 32'b0;
        mem_mstatus_data <= 32'b0;
        mem_mie_data <= 32'b0;
        mem_mip_data <= 32'b0;
        mem_satp_data <= 32'b0;
        mem_priv_data <= 2'b0;
        mem_mtval_data <= 32'b0;
        mem_mideleg_data <= 32'b0;
        mem_medeleg_data <= 32'b0;
        mem_sepc_data <= 32'b0;
        mem_scause_data <= 32'b0;
        mem_stval_data <= 32'b0;
        mem_stvec_data <= 32'b0;
        mem_sscratch_data <= 32'b0;

        excpreq_out <= 0;
    end
    else if (excp[3]) begin
        tlb_valid <= tlb_valid_update;
        tlb_virtual <= tlb_virtual_update;
        tlb_physical <= tlb_physical_update;
        if (ctrl) begin
            mem_pc <= mem_pc;
            mem_alu_opcode <= mem_alu_opcode;
            mem_alu_funct3 <= mem_alu_funct3;
            mem_regd_en <= mem_regd_en;
            mem_regd_addr <= mem_regd_addr;
            mem_data <= mem_data;
            mem_addr <= mem_addr_retro;
            virtual_addr <= virtual_addr;
            mem_en <= mem_en;
            mem_be_n <= mem_be_n;
            satp_rd <= satp_rd;
            priv_rd <= priv_rd;
            mem_phase <= mem_phase_retro;

            mem_mtvec_we <= mem_mtvec_we;
            mem_mscratch_we <= mem_mscratch_we;
            mem_mepc_we <= mem_mepc_we;
            mem_mcause_we <= mem_mcause_we;
            mem_mstatus_we <= mem_mstatus_we;
            mem_mie_we <= mem_mie_we;
            mem_mip_we <= mem_mip_we;
            mem_priv_we <= mem_priv_we;
            mem_satp_we <= mem_satp_we;

            mem_mtvec_data <= mem_mtvec_data;
            mem_mscratch_data <= mem_mscratch_data;
            mem_mepc_data <= mem_mepc_data;
            mem_mcause_data <= mem_mcause_data;
            mem_mstatus_data <= mem_mstatus_data;
            mem_mie_data <= mem_mie_data;
            mem_mip_data <= mem_mip_data;
            mem_satp_data <= mem_satp_data;
            mem_priv_data <= mem_priv_data;
            excpreq_out <= 1;
        end
        else begin
            mem_pc <= 32'b0;
            mem_alu_opcode <= `OP_NOP;
            mem_alu_funct3 <= `FUNCT3_NOP;
            mem_regd_en <= 0;
            mem_regd_addr <= 5'b0;
            mem_data <= 32'b0;
            mem_addr <= 32'b0;
            virtual_addr <= 32'b0;
            mem_en <= 0;
            mem_be_n <= 4'b0;
            satp_rd <= 32'b0;
            priv_rd <= 2'b0;
            mem_phase <= 2'b0;
            tlb_valid <= 0;
            tlb_virtual <= 20'b0;
            tlb_physical <= 32'b0;

            mem_mtvec_we <= 0;
            mem_mscratch_we <= 0;
            mem_mepc_we <= 0;
            mem_mcause_we <= 0;
            mem_mstatus_we <= 0;
            mem_mie_we <= 0;
            mem_mip_we <= 0;
            mem_priv_we <= 0;
            mem_satp_we <= 0;
            mem_mtval_we <= 0;
            mem_mideleg_we <= 0;
            mem_medeleg_we <= 0;
            mem_sepc_we <= 0;
            mem_scause_we <= 0;
            mem_stval_we <= 0;
            mem_stvec_we <= 0;
            mem_sscratch_we <= 0;

            mem_mtvec_data <= 32'b0;
            mem_mscratch_data <= 32'b0;
            mem_mepc_data <= 32'b0;
            mem_mcause_data <= 32'b0;
            mem_mstatus_data <= 32'b0;
            mem_mie_data <= 32'b0;
            mem_mip_data <= 32'b0;
            mem_satp_data <= 32'b0;
            mem_priv_data <= 2'b0;
            mem_mtval_data <= 32'b0;
            mem_mideleg_data <= 32'b0;
            mem_medeleg_data <= 32'b0;
            mem_sepc_data <= 32'b0;
            mem_scause_data <= 32'b0;
            mem_stval_data <= 32'b0;
            mem_stvec_data <= 32'b0;
            mem_sscratch_data <= 32'b0;

            excpreq_out <= 0;
        end
    end
    else begin
        tlb_valid <= tlb_valid_update;
        tlb_virtual <= tlb_virtual_update;
        tlb_physical <= tlb_physical_update;
        if (ctrl) begin
            mem_pc <= 32'b0;
            mem_alu_opcode <= mem_alu_opcode;
            mem_alu_funct3 <= mem_alu_funct3;
            mem_regd_en <= mem_regd_en;
            mem_regd_addr <= mem_regd_addr;
            mem_data <= mem_data;
            mem_addr <= mem_addr_retro;
            virtual_addr <= virtual_addr;
            mem_en <= mem_en;
            mem_be_n <= mem_be_n;
            satp_rd <= satp_rd;
            priv_rd <= priv_rd;
            mem_phase <= mem_phase_retro;

            mem_mtvec_we <= mem_mtvec_we;
            mem_mscratch_we <= mem_mscratch_we;
            mem_mepc_we <= mem_mepc_we;
            mem_mcause_we <= mem_mcause_we;
            mem_mstatus_we <= mem_mstatus_we;
            mem_mie_we <= mem_mie_we;
            mem_mip_we <= mem_mip_we;
            mem_priv_we <= mem_priv_we;
            mem_satp_we <= mem_satp_we;

            mem_mtvec_data <= mem_mtvec_data;
            mem_mscratch_data <= mem_mscratch_data;
            mem_mepc_data <= mem_mepc_data;
            mem_mcause_data <= mem_mcause_data;
            mem_mstatus_data <= mem_mstatus_data;
            mem_mie_data <= mem_mie_data;
            mem_mip_data <= mem_mip_data;
            mem_satp_data <= mem_satp_data;
            mem_priv_data <= mem_priv_data;
            excpreq_out <= 0;
        end
        else begin
            mem_pc <= ex_pc;
            mem_alu_opcode <= ex_alu_opcode;
            mem_alu_funct3 <= ex_alu_funct3;
            mem_regd_en <= ex_regd_en;
            mem_regd_addr <= ex_regd_addr;
            mem_data <= ex_data;
            mem_addr <= ex_mem_addr;
            virtual_addr <= ex_mem_addr;
            mem_en <= ex_mem_en;
            mem_be_n <= ex_mem_be_n;
            satp_rd <= ex_satp_rd;
            priv_rd <= ex_priv_rd;
            mem_phase <= 2'b00;
            
            mem_mtvec_we <= ex_mtvec_we;
            mem_mscratch_we <= ex_mscratch_we;
            mem_mepc_we <= ex_mepc_we;
            mem_mcause_we <= ex_mcause_we;
            mem_mstatus_we <= ex_mstatus_we;
            mem_mie_we <= ex_mie_we;
            mem_mip_we <= ex_mip_we;
            mem_priv_we <= ex_priv_we;
            mem_satp_we <= ex_satp_we;
            mem_mtval_we <= ex_mtval_we;
            mem_mideleg_we <= ex_mideleg_we;
            mem_medeleg_we <= ex_medeleg_we;
            mem_sepc_we <= ex_sepc_we;
            mem_scause_we <= ex_scause_we;
            mem_stval_we <= ex_stval_we;
            mem_stvec_we <= ex_stvec_we;
            mem_sscratch_we <= ex_sscratch_we;

            mem_mtvec_data <= ex_mtvec_data;
            mem_mscratch_data <= ex_mscratch_data;
            mem_mepc_data <= ex_mepc_data;
            mem_mcause_data <= ex_mcause_data;
            mem_mstatus_data <= ex_mstatus_data;
            mem_mie_data <= ex_mie_data;
            mem_mip_data <= ex_mip_data;
            mem_satp_data <= ex_satp_data;
            mem_priv_data <= ex_priv_data;
            mem_mtval_data <= ex_mtval_data;
            mem_mideleg_data <= ex_mideleg_data;
            mem_medeleg_data <= ex_medeleg_data;
            mem_sepc_data <= ex_sepc_data;
            mem_scause_data <= ex_scause_data;
            mem_stval_data <= ex_stval_data;
            mem_stvec_data <= ex_stvec_data;
            mem_sscratch_data <= ex_sscratch_data;

            excpreq_out <= excp[2] & !excp[3];
        end
    end
end

endmodule
