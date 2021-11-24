`timescale 1ns / 1ps

module PC_reg(
    input wire clk,
    input wire rst,
    input wire stall,

    input wire branch_flag,
    input wire[31:0] branch_addr,
    input wire[31:0] mem_addr_retro,

    input wire[31:0] satp,
    input wire[1:0] priv,

    output reg[31:0] pc_ram_addr,
    output reg[31:0] pc,
    output reg pc_ram_en,
    output reg bubble,
    output wire[3:0] state
);

reg pre_stall;
reg [1:0] mem_phase;
wire translation = (~priv[0]) & satp[31];
wire [31:0] pc_next = pc + 4;

assign state = pc_ram_addr[3:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h7ffffffc;
        pc_ram_addr <= 32'h7fffffffc;
        pc_ram_en <= 0;
        pre_stall <= 0;
        mem_phase <= 0;
        bubble <= 0;
    end
    else if (stall) begin
        pre_stall <= 1;
        pc_ram_en <= 0;
        if (branch_flag) begin
            pc <= branch_addr;
        end
        else begin
            pc <= pc;
        end
        pc_ram_addr <= 0;
        mem_phase <= 0;
        bubble <= 0;
    end
    else if (pre_stall) begin // 1 cycle
        pre_stall <= 0;
        pc_ram_en <= 1;
    end
    else begin
        pre_stall <= 0;
        pc_ram_en <= 1;
        if (branch_flag)
    end
end

endmodule
