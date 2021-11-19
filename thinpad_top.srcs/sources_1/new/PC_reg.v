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
reg count;
reg [1:0] mem_phase;
wire translation = (~priv[0]) & satp[31];
wire [31:0] next = pc + 4;

assign state = {count, pc_ram_addr[2:0]};

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h80000000;
        pc_ram_addr <= 32'h80000000;
        pc_ram_en <= 0;
        count <= 0;
        pre_stall <= 0;
        mem_phase <= 0;
        bubble <= 0;
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
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                bubble <= 1;
                pc_ram_addr <= {satp[19:0],branch_addr[31:22],2'b00}; //each PTE is 4bytes
                mem_phase <= 2'b01;
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                bubble <= 1;
                pc_ram_addr <= {mem_addr_retro[29:10],branch_addr[21:12],2'b00};
                mem_phase <= 2'b10;
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],branch_addr[11:0]};
                mem_phase <= 2'b00;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= branch_addr;
            end    
            count <= count;
        end
        else if (!count) begin
            pc <= pc;
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                bubble <= 1;
                pc_ram_addr <= {satp[19:0],pc[31:22],2'b00}; //each PTE is 4bytes
                mem_phase <= 2'b01;
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                bubble <= 1;
                pc_ram_addr <= {mem_addr_retro[29:10],pc[21:12],2'b00};
                mem_phase <= 2'b10;
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],pc[11:0]};
                mem_phase <= 2'b00;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= pc;
            end    
            count <= 1;
        end
        else if (pre_stall) begin
            pc <= pc;
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                bubble <= 1;
                pc_ram_addr <= {satp[19:0],pc[31:22],2'b00}; //each PTE is 4bytes
                mem_phase <= 2'b01;
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                bubble <= 1;
                pc_ram_addr <= {mem_addr_retro[29:10],pc[21:12],2'b00};
                mem_phase <= 2'b10;
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],pc[11:0]};
                mem_phase <= 2'b00;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= pc;
            end    
            count <= count;
        end
        else begin
            pc <= pc + 4;
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                bubble <= 1;
                pc_ram_addr <= {satp[19:0],next[31:22],2'b00}; //each PTE is 4bytes
                mem_phase <= 2'b01;
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                bubble <= 1;
                pc_ram_addr <= {mem_addr_retro[29:10],next[21:12],2'b00};
                mem_phase <= 2'b10;
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],next[11:0]};
                mem_phase <= 2'b00;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= pc + 4;
            end    
            count <= count;
        end
        pc_ram_en <= 1;
    end
end

endmodule
