`timescale 1ns / 1ps

module PC_reg(
    input wire clk,
    input wire rst,
    input wire stall,

    input wire branch_flag,
    input wire critical_flag,
    input wire[31:0] branch_addr,
    input wire[31:0] mem_addr_retro,

    input wire[31:0] satp,
    input wire[1:0] priv,

    input wire tlb_flush,

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

//TLB
reg tlb_valid;
reg [19:0] tlb_virtual;
reg [19:0] tlb_physical;

assign state = pc_ram_addr[3:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 32'h7ffffffc;
        pc_ram_addr <= 32'h7ffffffc;
        pc_ram_en <= 0;
        pre_stall <= 0;
        mem_phase <= 0;
        bubble <= 0;
        tlb_valid <= 0;
        tlb_virtual <= 20'b0;
        tlb_physical <= 20'b0;
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
        pc_ram_en <= 1;
        if (branch_flag) begin //branch flag should last only 1 cycle
            pc <= branch_addr;
            if (critical_flag) begin
                bubble <= 1;
                pc <= branch_addr;
                mem_phase <= 2'b00;
                pre_stall <= 1;
            end
            else begin
                if (translation) begin
                    if(tlb_valid && (tlb_virtual == branch_addr[31:12])) begin //TLB hit
                        bubble <= 0;
                        pc_ram_addr <= {tlb_physical,branch_addr[11:0]};
                        mem_phase <= 2'b00;
                    end
                    else begin //TLB miss
                        bubble <= 1;
                        pc_ram_addr <= {satp[19:0],branch_addr[31:22],2'b00};
                        mem_phase <= 2'b01;
                        pre_stall <= 1;
                    end
                end
                else begin
                    bubble <= 0;
                    pc_ram_addr <= branch_addr;
                    mem_phase <= 2'b00;
                end
            end
        end
        else if (pre_stall) begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                if(tlb_valid && (tlb_virtual == pc[31:12])) begin //TLB hit
                    bubble <= 0;
                    pc_ram_addr <= {tlb_physical,pc[11:0]};
                    mem_phase <= 2'b00;
                end
                else begin //TLB miss
                    bubble <= 1;
                    pre_stall <= 1;
                    pc_ram_addr <= {satp[19:0],pc[31:22],2'b00}; //each PTE is 4bytes
                    mem_phase <= 2'b01;
                end
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                if (mem_addr_retro[3]|mem_addr_retro[2]|mem_addr_retro[1]) begin
                    bubble <= 0;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc[11:0]};
                    tlb_virtual <= pc[31:12];
                    tlb_physical <= mem_addr_retro[29:10];
                    tlb_valid <= ~tlb_flush;
                    mem_phase <= 2'b00;
                end
                else begin
                    bubble <= 1;
                    pre_stall <= 1;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc[21:12],2'b00};
                    mem_phase <= 2'b10;
                end
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],pc[11:0]};
                tlb_virtual <= pc[31:12];
                tlb_physical <= mem_addr_retro[29:10];
                tlb_valid <= ~tlb_flush;
                mem_phase <= 2'b00;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= pc;
                mem_phase <= 2'b00;
            end    
        end
        else begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                if(tlb_valid && (tlb_virtual == pc[31:12])) begin //TLB hit
                    bubble <= 0;
                    pc_ram_addr <= {tlb_physical,pc_next[11:0]};
                    mem_phase <= 2'b00;
                    pc <= pc_next;
                end
                else begin //TLB miss
                    bubble <= 1;
                    pc_ram_addr <= {satp[19:0],pc_next[31:22],2'b00}; //each PTE is 4bytes
                    mem_phase <= 2'b01;
                end
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                if (mem_addr_retro[3]|mem_addr_retro[2]|mem_addr_retro[1]) begin
                    bubble <= 0;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc_next[11:0]};
                    tlb_virtual <= pc_next[31:12];
                    tlb_physical <= mem_addr_retro[29:10];
                    tlb_valid <= ~tlb_flush;
                    mem_phase <= 2'b00;
                    pc <= pc_next;
                end
                else begin
                    bubble <= 1;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc_next[21:12],2'b00};
                    mem_phase <= 2'b10;
                end
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],pc_next[11:0]};
                tlb_virtual <= pc_next[31:12];
                tlb_physical <= mem_addr_retro[29:10];
                tlb_valid <= ~tlb_flush;
                mem_phase <= 2'b00;
                pc <= pc_next;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= pc_next;
                mem_phase <= 2'b00;
                pc <= pc_next;
            end    
        end
    end
end

endmodule
