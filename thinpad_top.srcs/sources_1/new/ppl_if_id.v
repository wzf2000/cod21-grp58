`timescale 1ns / 1ps

module ppl_if_id(
    input wire clk,
    input wire rst,

    input wire[31:0] if_pc,

    input wire [31:0] if_mepc,
    input wire [31:0] if_mcause,
    input wire [31:0] if_mstatus,
    input wire [1:0] if_priv,

    input wire if_mepc_we,
    input wire if_mcause_we,
    input wire if_mstatus_we,
    input wire if_priv_we,

    input wire stall,
    output reg excpreq_out,
    input wire[3:0] excp,

    input wire[31:0] ram_data,

    input wire if_bubble, // 1: busy, 0: not busy
    input wire branch_predict, // 1: jump, 0: not jump

    output reg [31:0] id_mepc,
    output reg [31:0] id_mcause,
    output reg [31:0] id_mstatus,
    output reg [1:0] id_priv,

    output reg id_mepc_we,
    output reg id_mcause_we,
    output reg id_mstatus_we,
    output reg id_priv_we,

    output reg[31:0] id_pc,
    output reg[31:0] id_instr
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        id_pc <= 32'b0;
        id_instr <= 32'b0;
        excpreq_out <= 0;

        id_mepc <= 32'b0;
        id_mcause <= 32'b0;
        id_mstatus <= 32'b0;
        id_priv <= 32'b0;
        id_mepc_we <= 0;
        id_mcause_we <= 0;
        id_mstatus_we <= 0;
        id_priv_we <= 0;
    end
    else begin
        if (stall) begin
            id_pc <= id_pc;
            id_instr <= id_instr;
            excpreq_out <= 0;

            id_mepc <= id_mepc;
            id_mcause <= id_mcause;
            id_mstatus <= id_mstatus;
            id_priv <= id_priv;
            id_mepc_we <= id_mepc_we;
            id_mcause_we <= id_mcause_we;
            id_mstatus_we <= id_mstatus_we;
            id_priv_we <= id_priv_we;
        end
        else if (excp[1]) begin
            id_pc <= 32'b0;
            id_instr <= 32'b0;
            excpreq_out <= 0;

            id_mepc <= 32'b0;
            id_mcause <= 32'b0;
            id_mstatus <= 32'b0;
            id_priv <= 2'b0;
            id_mepc_we <= 0;
            id_mcause_we <= 0;
            id_mstatus_we <= 0;
            id_priv_we <= 0;
        end
        else if (branch_predict | if_bubble) begin
            id_pc <= 32'b0;
            id_instr <= 32'b0;
            excpreq_out <= excp[0] & !excp[1];

            id_mepc <= 32'b0;
            id_mcause <= 32'b0;
            id_mstatus <= 32'b0;
            id_priv <= 2'b0;
            id_mepc_we <= 0;
            id_mcause_we <= 0;
            id_mstatus_we <= 0;
            id_priv_we <= 0;
        end
        else begin
            id_pc <= if_pc;
            id_instr <= ram_data;
            excpreq_out <= excp[0] & !excp[1];

            id_mepc <= if_mepc;
            id_mcause <= if_mcause;
            id_mstatus <= if_mstatus;
            id_priv <= if_priv;
            id_mepc_we <= if_mepc_we;
            id_mcause_we <= if_mcause_we;
            id_mstatus_we <= if_mstatus_we;
            id_priv_we <= if_priv_we;
        end
    end
end

endmodule
