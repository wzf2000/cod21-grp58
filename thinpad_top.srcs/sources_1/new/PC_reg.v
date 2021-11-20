`timescale 1ns / 1ps

module PC_reg(
    input wire clk,
    input wire rst,
    input wire stall,

    input wire branch_flag,
    input wire[31:0] branch_addr,

    output reg[31:0] pc_ram_addr,
    output reg[31:0] pc,
    output reg pc_ram_en,
    output wire[3:0] state
);

reg pre_stall;

assign state = pc_ram_addr[3:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h7ffffffc;
        pc_ram_addr <= 32'h7ffffffc;
        pc_ram_en <= 0;
        pre_stall <= 0;
    end
    else if (stall) begin
        pre_stall <= stall;
        if (branch_flag) begin
            pc <= branch_addr;
        end
        else begin
            pc <= pc;
        end
        pc_ram_addr <= 0;
        pc_ram_en <= 0;
    end
    else begin
        pre_stall <= 0;
        if (branch_flag) begin
            pc <= branch_addr;
            pc_ram_addr <= branch_addr;
        end
        else if (pre_stall) begin
            pc <= pc;
            pc_ram_addr <= pc;
        end
        else begin
            pc <= pc + 4;
            pc_ram_addr <= pc + 4;
        end
        pc_ram_en <= 1;
    end
end

endmodule
