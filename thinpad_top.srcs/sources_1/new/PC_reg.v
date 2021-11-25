`timescale 1ns / 1ps

module PC_reg(
    input wire clk,
    input wire rst,
    input wire stall,
    input wire[3:0] excp,
    output wire excpreq,

    input wire id_branch_flag,
    input wire id_critical_flag,
    input wire[31:0] id_branch_addr,
    input wire mem_branch_flag,
    input wire mem_critical_flag,
    input wire[31:0] mem_branch_addr,
    input wire[31:0] mem_addr_retro,
    input wire[31:0] last_branch_dest,
    input wire[31:0] last_branch_pc,
    input wire[1:0] bth_state_in,
    
    input wire [31:0] mepc_in,
    input wire [31:0] mcause_in,
    input wire [31:0] mstatus_in,
    input wire [1:0] priv_in,

    output reg [31:0] mepc_out,
    output reg [31:0] mcause_out,
    output reg [31:0] mstatus_out,
    output reg [1:0] priv_out,

    output reg mepc_we_out,
    output reg mcause_we_out,
    output reg mstatus_we_out,
    output reg priv_we_out,

    input wire[31:0] satp,
    input wire[1:0] priv,

    input wire tlb_flush,

    output reg[31:0] pc_ram_addr,
    output reg[31:0] pc,
    output reg pc_ram_en,
    output reg bubble,
    output wire[3:0] state
);

reg branch_flag_out;
reg critical_flag_out;
reg[31:0] branch_addr_out;
wire branch_flag;
wire critical_flag;
wire[31:0] branch_addr;

assign branch_flag = id_branch_flag | mem_branch_flag | branch_flag_out;
assign critical_flag = id_critical_flag | mem_critical_flag | critical_flag_out;
assign branch_addr = mem_branch_flag ? mem_branch_addr : (id_branch_flag ? id_branch_addr : branch_addr_out);

//! TODO
reg excpreq_reg;
assign excpreq = excpreq_reg;

reg pre_stall;
reg [1:0] mem_phase;
wire translation = (~priv[0]) & satp[31];
wire [31:0] pc_next = pc + 4;

//TLB
reg tlb_valid;
reg [19:0] tlb_virtual;
reg [31:0] tlb_physical;

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
        tlb_physical <= 32'b0;
        excpreq_reg <= 0;
        branch_flag_out <= 0;
        critical_flag_out <= 0;
        branch_addr_out <= 32'b0;
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
        excpreq_reg <= excpreq_reg;

        branch_flag_out <= 0;
        critical_flag_out <= 0;
        branch_addr_out <= 32'b0;
    end
    else if (excp[0]) begin
        if (branch_flag) begin
            pc <= branch_addr;
        end
        else begin
            pc <= pc;
        end
        pc_ram_addr <= 0;
        pc_ram_en <= 0;
        pre_stall <= 1;
        mem_phase <= 0;
        bubble <= 0;
        excpreq_reg <= 0;
        
        branch_flag_out <= 0;
        critical_flag_out <= 0;
        branch_addr_out <= 32'b0;
    end
    else begin
        excpreq_reg <= 0;
        pre_stall <= 0;
        pc_ram_en <= 1;
        if (branch_flag) begin //branch flag should last only 1 cycle
            pc <= branch_addr;
            if (critical_flag) begin
                bubble <= 1;
                pc <= branch_addr;
                mem_phase <= 2'b00;
                pre_stall <= 1;
                branch_flag_out <= 0;
                critical_flag_out <= 0;
                branch_addr_out <= 32'b0;
            end
            else begin
                if (translation) begin
                    if(tlb_valid && (tlb_virtual == branch_addr[31:12])) begin //TLB hit
                        // if (!tlb_physical[3] || (priv_in == 2'b00 && (!tlb_physical[4])) || (priv_in == 2'b01 && tlb_physical[4] && (!mstatus_in[18]))) begin
                        //     priv_we_out = 1;
                        //     mstatus_we_out = 1;
                        //     mepc_we_out = 1;
                        //     mcause_we_out = 1;

                        //     branch_flag_out = 1'b1;
                        //     critical_flag_out = 1'b1;
                        //     branch_addr_out = mtvec_in;
                        //     excpreq = 1;

                        //     priv_out = 2'b11;
                        //     mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        //     mepc_out = branch_addr;
                        //     mcause_out = {1'b0, 27'b0, 4'b1100};

                        //     ram_ce_n = 1;
                        //     ram_we_n = 1;
                        // end
                        // else begin
                            bubble <= 0;
                            pc_ram_addr <= {tlb_physical[29:10],branch_addr[11:0]};
                            mem_phase <= 2'b00;
                        // end
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
                    branch_flag_out <= 0;
                    critical_flag_out <= 0;
                    branch_addr_out <= 32'b0;
                end
            end
        end
        else if (pre_stall) begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                if(tlb_valid && (tlb_virtual == pc[31:12])) begin //TLB hit
                    bubble <= 0;
                    pc_ram_addr <= {tlb_physical[29:10],pc[11:0]};
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
                    tlb_physical <= mem_addr_retro;
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
                tlb_physical <= mem_addr_retro;
                tlb_valid <= ~tlb_flush;
                mem_phase <= 2'b00;
            end
            else begin // doesn't need translation
                bubble <= 0;
                pc_ram_addr <= pc;
                mem_phase <= 2'b00;
                branch_flag_out <= 0;
                critical_flag_out <= 0;
                branch_addr_out <= 32'b0;
            end    
        end
        else begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                if(tlb_valid && (tlb_virtual == pc[31:12])) begin //TLB hit
                    bubble <= 0;
                    mem_phase <= 2'b00;
                    if(pc!=last_branch_pc) begin
                        pc <= pc_next;
                        pc_ram_addr <= {tlb_physical[29:10],pc_next[11:0]};
                    end
                    else begin
                        pc <= bth_state_in[1] ? last_branch_dest : pc_next;
                        pc_ram_addr <= bth_state_in[1] ? {tlb_physical[29:10],last_branch_dest[11:0]} : {tlb_physical[29:10],pc_next[11:0]};
                    end
                end
                else begin //TLB miss
                    bubble <= 1;
                    if(pc!=last_branch_pc) begin
                        pc_ram_addr <= {satp[19:0],pc_next[31:22],2'b00};
                    end
                    else begin
                        pc_ram_addr <= bth_state_in[1] ? {satp[19:0],last_branch_dest[31:22],2'b00} : {satp[19:0],pc_next[31:22],2'b00};
                    end
                    mem_phase <= 2'b01;
                end
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                if (mem_addr_retro[3]|mem_addr_retro[2]|mem_addr_retro[1]) begin
                    bubble <= 0;
                    tlb_virtual <= pc_next[31:12];
                    tlb_physical <= mem_addr_retro;
                    tlb_valid <= ~tlb_flush;
                    mem_phase <= 2'b00;
                    if(pc!=last_branch_pc) begin
                        pc <= pc_next;
                        pc_ram_addr <= {mem_addr_retro[29:10],pc_next[11:0]};
                    end
                    else begin
                        pc <= bth_state_in[1] ? last_branch_dest : pc_next;
                        pc_ram_addr <= bth_state_in[1] ? {mem_addr_retro[29:10],last_branch_dest[11:0]} : {mem_addr_retro[29:10],pc_next[11:0]};
                    end
                end
                else begin
                    bubble <= 1;
                    if(pc!=last_branch_pc) begin
                        pc_ram_addr <= {mem_addr_retro[29:10],pc_next[21:12],2'b00};
                    end
                    else begin
                        pc_ram_addr <= bth_state_in[1] ? {mem_addr_retro[29:10],last_branch_dest[21:12],2'b00} : {mem_addr_retro[29:10],pc_next[21:12],2'b00};
                    end
                    mem_phase <= 2'b10;
                end
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                bubble <= 0;
                tlb_virtual <= pc_next[31:12];
                tlb_physical <= mem_addr_retro;
                tlb_valid <= ~tlb_flush;
                mem_phase <= 2'b00;
                if(pc!=last_branch_pc) begin
                    pc <= pc_next;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc_next[11:0]};
                end
                else begin
                    pc <= bth_state_in[1] ? last_branch_dest : pc_next;
                    pc_ram_addr <= bth_state_in[1] ? {mem_addr_retro[29:10],last_branch_dest[11:0]} : {mem_addr_retro[29:10],pc_next[11:0]};
                end
            end
            else begin // doesn't need translation
                bubble <= 0;
                mem_phase <= 2'b00;
                if(pc!=last_branch_pc) begin
                    pc <= pc_next;
                    pc_ram_addr <= pc_next;
                end
                else begin
                    pc <= bth_state_in[1] ? last_branch_dest : pc_next;
                    pc_ram_addr <= bth_state_in[1] ? last_branch_dest : pc_next;
                end
                branch_flag_out <= 0;
                critical_flag_out <= 0;
                branch_addr_out <= 32'b0;
            end    
        end
    end
end

endmodule

