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
reg count;

assign state = {count, pc_ram_addr[2:0]};

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h80000000;
        pc_ram_addr <= 32'h80000000;
        pc_ram_en <= 0;
        count <= 0;
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
        count <= count;
    end
    else begin
        pre_stall <= 0;
        if (branch_flag) begin
            pc <= branch_addr;
            pc_ram_addr <= branch_addr;
            count <= count;
        end
        else if (!count) begin
            pc <= pc;
            pc_ram_addr <= pc;
            count <= 1;
        end
        else if (pre_stall) begin
            pc <= pc;
            pc_ram_addr <= pc;
            count <= count;
        end
        else begin
            pc <= pc + 4;
            pc_ram_addr <= pc + 4;
            count <= count;
        end
        pc_ram_en <= 1;
    end
end

endmodule
