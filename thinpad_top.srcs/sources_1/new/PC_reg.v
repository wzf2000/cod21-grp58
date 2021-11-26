`timescale 1ns / 1ps

module PC_reg(
    input wire clk,
    input wire rst,
    input wire stall,
    input wire[3:0] excp,
    output reg excpreq,

    input wire id_branch_flag,
    input wire id_critical_flag,
    input wire[31:0] id_branch_addr,
    input wire mem_branch_flag,
    input wire mem_critical_flag,
    input wire[31:0] mem_branch_addr,
    input wire[31:0] mem_addr_retro,
    
    input wire [31:0] mtvec_in,
    input wire [31:0] stvec_in,
    input wire [31:0] medeleg_in,
    input wire [31:0] mstatus_in,
    input wire [1:0] priv_in,

    output reg [31:0] mepc_out,
    output reg [31:0] mcause_out,
    output reg [31:0] mstatus_out,
    output reg [1:0] priv_out,
    output reg [31:0] sepc_out,
    output reg [31:0] scause_out,

    output reg mepc_we_out,
    output reg mcause_we_out,
    output reg mstatus_we_out,
    output reg priv_we_out,
    output reg sepc_we_out,
    output reg scause_we_out,

    input wire[31:0] satp,
    input wire[1:0] priv,

    input wire tlb_flush,

    output reg[31:0] pc_ram_addr,
    output reg[31:0] pc,
    output reg pc_ram_en,
    output reg bubble,
    output reg[4:0] state
);

reg if_branch_flag;
reg if_critical_flag;
reg[31:0] if_branch_addr;

wire branch_flag;
wire critical_flag;
wire[31:0] branch_addr;

assign branch_flag = id_branch_flag | mem_branch_flag | if_branch_flag;
assign critical_flag = id_critical_flag | mem_critical_flag | if_critical_flag;
assign branch_addr = mem_branch_flag ? mem_branch_addr : (id_branch_flag ? id_branch_addr : if_branch_addr);

reg pre_stall;
reg [1:0] mem_phase;
wire translation = (~priv[1]) & satp[31];
wire [31:0] pc_next = pc + 4;

//TLB
reg tlb_valid;
reg [19:0] tlb_virtual;
reg [31:0] tlb_physical;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 0;
        pc <= 32'h7ffffffc;
        pc_ram_addr <= 32'h7ffffffc;
        pre_stall <= 0;
        mem_phase <= 0;
        bubble <= 0;
        tlb_valid <= 0;
        tlb_virtual <= 20'b0;
        tlb_physical <= 32'b0;

        excpreq <= 0;
        pc_ram_en <= 0;
        if_branch_flag <= 0;
        if_critical_flag <= 0;
        if_branch_addr <= 32'b0;

        mepc_out <= 32'b0;
        mcause_out <= 32'b0;
        mstatus_out <= 32'b0;
        priv_out <= 2'b0;
        sepc_out <= 32'b0;
        scause_out <= 32'b0;

        mepc_we_out <= 0;
        mcause_we_out <= 0;
        mstatus_we_out <= 0;
        priv_we_out <= 0;
        sepc_we_out <= 0;
        scause_we_out <= 0;
    end
    else if (stall) begin
        state <= 1;
        pre_stall <= stall;
        if (branch_flag) begin
            pc <= branch_addr;
        end
        else begin
            pc <= pc;
        end
        pc_ram_addr <= 0;

        excpreq <= excpreq;
        pc_ram_en <= 0;
        if_branch_flag <= 0;
        if_critical_flag <= 0;
        if_branch_addr <= 32'b0;

        mepc_out <= 32'b0;
        mcause_out <= 32'b0;
        mstatus_out <= 32'b0;
        priv_out <= 2'b0;
        sepc_out <= 32'b0;
        scause_out <= 32'b0;

        mepc_we_out <= 0;
        mcause_we_out <= 0;
        mstatus_we_out <= 0;
        priv_we_out <= 0;
        sepc_we_out <= 0;
        scause_we_out <= 0;
    end
    else if (excp[0]) begin
        state <= 2;
        if (branch_flag) begin
            pc <= branch_addr;
        end
        else begin
            pc <= pc;
        end
        pc_ram_addr <= 0;
        pre_stall <= 1;
        mem_phase <= 0;
        bubble <= 0;

        excpreq <= 0;
        pc_ram_en <= 0;
        if_branch_flag <= 0;
        if_critical_flag <= 0;
        if_branch_addr <= 32'b0;

        mepc_out <= 32'b0;
        mcause_out <= 32'b0;
        mstatus_out <= 32'b0;
        priv_out <= 2'b0;
        sepc_out <= 32'b0;
        scause_out <= 32'b0;

        mepc_we_out <= 0;
        mcause_we_out <= 0;
        mstatus_we_out <= 0;
        priv_we_out <= 0;
        sepc_we_out <= 0;
        scause_we_out <= 0;
    end
    else begin
        pre_stall <= 0;
        if (branch_flag) begin //branch flag should last only 1 cycle
            pc <= branch_addr;
            if (critical_flag) begin
                state <= 3;
                bubble <= 1;
                pc <= branch_addr;
                mem_phase <= 2'b00;
                pre_stall <= 1;
        
                excpreq <= 0;
                pc_ram_en <= 0;
                if_branch_flag <= 0;
                if_critical_flag <= 0;
                if_branch_addr <= 32'b0;

                mepc_out <= 32'b0;
                mcause_out <= 32'b0;
                mstatus_out <= 32'b0;
                priv_out <= 2'b0;
                sepc_out <= 32'b0;
                scause_out <= 32'b0;

                mepc_we_out <= 0;
                mcause_we_out <= 0;
                mstatus_we_out <= 0;
                priv_we_out <= 0;
                sepc_we_out <= 0;
                scause_we_out <= 0;
            end
            else begin
                if (translation) begin
                    if(tlb_valid && (tlb_virtual == branch_addr[31:12])) begin //TLB hit
                        state <= 4;
                        bubble <= 0;
                        pc_ram_addr <= {tlb_physical[29:10],branch_addr[11:0]};
                        mem_phase <= 2'b00;

                        if (!tlb_physical[3] || (priv_in == 2'b00 && (!tlb_physical[4])) || (priv_in == 2'b01 && tlb_physical[4] && (!mstatus_in[18]))) begin
                            priv_we_out <= 1;
                            mstatus_we_out <= 1;

                            if_branch_flag <= 1'b1;
                            if_critical_flag <= 1'b1;
                            excpreq <= 1;
                            pc_ram_en <= 0;

                            if ((priv_in<2) && medeleg_in[12]) begin
                                priv_out <= 2'b01;
                                mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                                sepc_out <= branch_addr;
                                sepc_we_out <= 1;
                                scause_out <= {1'b0, 27'b0, 4'b1100};
                                scause_we_out <= 1;
                                if_branch_addr <= stvec_in;
                            end
                            else begin
                                priv_out <= 2'b11;
                                mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                                mepc_out <= branch_addr;
                                mepc_we_out <= 1;
                                mcause_out <= {1'b0, 27'b0, 4'b1100};
                                mcause_we_out <= 1;
                                if_branch_addr <= mtvec_in;
                            end
                        end
                        else begin
                            excpreq <= 0;
                            pc_ram_en <= 1;
                            if_branch_flag <= 0;
                            if_critical_flag <= 0;
                            if_branch_addr <= 32'b0;

                            mepc_out <= 32'b0;
                            mcause_out <= 32'b0;
                            mstatus_out <= 32'b0;
                            priv_out <= 2'b0;
                            sepc_out <= 32'b0;
                            scause_out <= 32'b0;

                            mepc_we_out <= 0;
                            mcause_we_out <= 0;
                            mstatus_we_out <= 0;
                            priv_we_out <= 0;
                            sepc_we_out <= 0;
                            scause_we_out <= 0;
                        end
                    end
                    else begin //TLB miss
                        state <= 5;
                        bubble <= 1;
                        pc_ram_addr <= {satp[19:0],branch_addr[31:22],2'b00};
                        mem_phase <= 2'b01;
                        pre_stall <= 1;

                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
                else begin
                    state <= 6;
                    bubble <= 0;
                    pc_ram_addr <= branch_addr;
                    mem_phase <= 2'b00;

                    excpreq <= 0;
                    pc_ram_en <= 1;
                    if_branch_flag <= 0;
                    if_critical_flag <= 0;
                    if_branch_addr <= 32'b0;

                    mepc_out <= 32'b0;
                    mcause_out <= 32'b0;
                    mstatus_out <= 32'b0;
                    priv_out <= 2'b0;
                    sepc_out <= 32'b0;
                    scause_out <= 32'b0;

                    mepc_we_out <= 0;
                    mcause_we_out <= 0;
                    mstatus_we_out <= 0;
                    priv_we_out <= 0;
                    sepc_we_out <= 0;
                    scause_we_out <= 0;
                end
            end
        end
        else if (pre_stall) begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                if(tlb_valid && (tlb_virtual == pc[31:12])) begin //TLB hit
                    state <= 7;
                    bubble <= 0;
                    pc_ram_addr <= {tlb_physical[29:10],pc[11:0]};
                    mem_phase <= 2'b00;

                    if (!tlb_physical[3] || (priv_in == 2'b00 && (!tlb_physical[4])) || (priv_in == 2'b01 && tlb_physical[4] && (!mstatus_in[18]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else begin
                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
                else begin //TLB miss
                    state <= 8;
                    bubble <= 1;
                    pre_stall <= 1;
                    pc_ram_addr <= {satp[19:0],pc[31:22],2'b00}; //each PTE is 4bytes
                    mem_phase <= 2'b01;

                    excpreq <= 0;
                    pc_ram_en <= 1;
                    if_branch_flag <= 0;
                    if_critical_flag <= 0;
                    if_branch_addr <= 32'b0;

                    mepc_out <= 32'b0;
                    mcause_out <= 32'b0;
                    mstatus_out <= 32'b0;
                    priv_out <= 2'b0;
                    sepc_out <= 32'b0;
                    scause_out <= 32'b0;

                    mepc_we_out <= 0;
                    mcause_we_out <= 0;
                    mstatus_we_out <= 0;
                    priv_we_out <= 0;
                    sepc_we_out <= 0;
                    scause_we_out <= 0;
                end
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                if (mem_addr_retro[3] | mem_addr_retro[2] | mem_addr_retro[1]) begin
                    state <= 9;
                    bubble <= 0;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc[11:0]};
                    tlb_virtual <= pc[31:12];
                    tlb_physical <= mem_addr_retro;
                    tlb_valid <= ~tlb_flush;
                    mem_phase <= 2'b00;

                    if ((~mem_addr_retro[0]) | (mem_addr_retro[2] & (~mem_addr_retro[1]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else if (!mem_addr_retro[3] || (priv_in == 2'b00 && (!mem_addr_retro[4])) || (priv_in == 2'b01 && mem_addr_retro[4] && (!mstatus_in[18]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else if (mem_addr_retro[10] != 0) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else begin
                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
                else begin
                    state <= 10;
                    bubble <= 1;
                    pre_stall <= 1;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc[21:12],2'b00};
                    mem_phase <= 2'b10;

                    if ((~mem_addr_retro[0]) | (mem_addr_retro[2] & (~mem_addr_retro[1]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else begin
                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                state <= 11;
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],pc[11:0]};
                tlb_virtual <= pc[31:12];
                tlb_physical <= mem_addr_retro;
                tlb_valid <= ~tlb_flush;
                mem_phase <= 2'b00;

                if ((~mem_addr_retro[0]) | (mem_addr_retro[2] & (~mem_addr_retro[1]))) begin
                    priv_we_out <= 1;
                    mstatus_we_out <= 1;

                    if_branch_flag <= 1'b1;
                    if_critical_flag <= 1'b1;
                    excpreq <= 1;
                    pc_ram_en <= 0;

                    if ((priv_in<2) && medeleg_in[12]) begin
                        priv_out <= 2'b01;
                        mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out <= pc;
                        sepc_we_out <= 1;
                        scause_out <= {1'b0, 27'b0, 4'b1100};
                        scause_we_out <= 1;
                        if_branch_addr <= stvec_in;
                    end
                    else begin
                        priv_out <= 2'b11;
                        mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out <= pc;
                        mepc_we_out <= 1;
                        mcause_out <= {1'b0, 27'b0, 4'b1100};
                        mcause_we_out <= 1;
                        if_branch_addr <= mtvec_in;
                    end
                end
                else if (!(mem_addr_retro[3] | mem_addr_retro[2] | mem_addr_retro[1])) begin
                    priv_we_out <= 1;
                    mstatus_we_out <= 1;

                    if_branch_flag <= 1'b1;
                    if_critical_flag <= 1'b1;
                    excpreq <= 1;
                    pc_ram_en <= 0;

                    if ((priv_in<2) && medeleg_in[12]) begin
                        priv_out <= 2'b01;
                        mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out <= pc;
                        sepc_we_out <= 1;
                        scause_out <= {1'b0, 27'b0, 4'b1100};
                        scause_we_out <= 1;
                        if_branch_addr <= stvec_in;
                    end
                    else begin
                        priv_out <= 2'b11;
                        mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out <= pc;
                        mepc_we_out <= 1;
                        mcause_out <= {1'b0, 27'b0, 4'b1100};
                        mcause_we_out <= 1;
                        if_branch_addr <= mtvec_in;
                    end
                end
                else if (!mem_addr_retro[3] || (priv_in == 2'b00 && (!mem_addr_retro[4])) || (priv_in == 2'b01 && mem_addr_retro[4] && (!mstatus_in[18]))) begin
                    priv_we_out <= 1;
                    mstatus_we_out <= 1;

                    if_branch_flag <= 1'b1;
                    if_critical_flag <= 1'b1;
                    excpreq <= 1;
                    pc_ram_en <= 0;

                    if ((priv_in<2) && medeleg_in[12]) begin
                        priv_out <= 2'b01;
                        mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out <= pc;
                        sepc_we_out <= 1;
                        scause_out <= {1'b0, 27'b0, 4'b1100};
                        scause_we_out <= 1;
                        if_branch_addr <= stvec_in;
                    end
                    else begin
                        priv_out <= 2'b11;
                        mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out <= pc;
                        mepc_we_out <= 1;
                        mcause_out <= {1'b0, 27'b0, 4'b1100};
                        mcause_we_out <= 1;
                        if_branch_addr <= mtvec_in;
                    end
                end
                else begin
                    excpreq <= 0;
                    pc_ram_en <= 1;
                    if_branch_flag <= 0;
                    if_critical_flag <= 0;
                    if_branch_addr <= 32'b0;

                    mepc_out <= 32'b0;
                    mcause_out <= 32'b0;
                    mstatus_out <= 32'b0;
                    priv_out <= 2'b0;
                    sepc_out <= 32'b0;
                    scause_out <= 32'b0;

                    mepc_we_out <= 0;
                    mcause_we_out <= 0;
                    mstatus_we_out <= 0;
                    priv_we_out <= 0;
                    sepc_we_out <= 0;
                    scause_we_out <= 0;
                end
            end
            else begin // doesn't need translation
                state <= 12;
                bubble <= 0;
                pc_ram_addr <= pc;
                mem_phase <= 2'b00;

                excpreq <= 0;
                pc_ram_en <= 1;
                if_branch_flag <= 0;
                if_critical_flag <= 0;
                if_branch_addr <= 32'b0;

                mepc_out <= 32'b0;
                mcause_out <= 32'b0;
                mstatus_out <= 32'b0;
                priv_out <= 2'b0;
                sepc_out <= 32'b0;
                scause_out <= 32'b0;

                mepc_we_out <= 0;
                mcause_we_out <= 0;
                mstatus_we_out <= 0;
                priv_we_out <= 0;
                sepc_we_out <= 0;
                scause_we_out <= 0;
            end
        end
        else begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0])) begin // 00: level 1 table
                if(tlb_valid && (tlb_virtual == pc[31:12])) begin //TLB hit
                    state <= 13;
                    bubble <= 0;
                    pc_ram_addr <= {tlb_physical[29:10],pc_next[11:0]};
                    mem_phase <= 2'b00;
                    pc <= pc_next;

                    if (!tlb_physical[3] || (priv_in == 2'b00 && (!tlb_physical[4])) || (priv_in == 2'b01 && tlb_physical[4] && (!mstatus_in[18]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else begin
                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
                else begin //TLB miss
                    state <= 14;
                    bubble <= 1;
                    pc_ram_addr <= {satp[19:0],pc_next[31:22],2'b00}; //each PTE is 4bytes
                    mem_phase <= 2'b01;

                    excpreq <= 0;
                    pc_ram_en <= 1;
                    if_branch_flag <= 0;
                    if_critical_flag <= 0;
                    if_branch_addr <= 32'b0;

                    mepc_out <= 32'b0;
                    mcause_out <= 32'b0;
                    mstatus_out <= 32'b0;
                    priv_out <= 2'b0;
                    sepc_out <= 32'b0;
                    scause_out <= 32'b0;

                    mepc_we_out <= 0;
                    mcause_we_out <= 0;
                    mstatus_we_out <= 0;
                    priv_we_out <= 0;
                    sepc_we_out <= 0;
                    scause_we_out <= 0;
                end
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0]) begin // 01: level 2 table
                if (mem_addr_retro[3]|mem_addr_retro[2]|mem_addr_retro[1]) begin
                    state <= 15;
                    bubble <= 0;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc_next[11:0]};
                    tlb_virtual <= pc_next[31:12];
                    tlb_physical <= mem_addr_retro;
                    tlb_valid <= ~tlb_flush;
                    mem_phase <= 2'b00;
                    pc <= pc_next;

                    if ((~mem_addr_retro[0]) | (mem_addr_retro[2] & (~mem_addr_retro[1]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else if (!mem_addr_retro[3] || (priv_in == 2'b00 && (!mem_addr_retro[4])) || (priv_in == 2'b01 && mem_addr_retro[4] && (!mstatus_in[18]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else if (mem_addr_retro[10] != 0) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else begin
                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
                else begin
                    state <= 16;
                    bubble <= 1;
                    pc_ram_addr <= {mem_addr_retro[29:10],pc_next[21:12],2'b00};
                    mem_phase <= 2'b10;

                    if ((~mem_addr_retro[0]) | (mem_addr_retro[2] & (~mem_addr_retro[1]))) begin
                        priv_we_out <= 1;
                        mstatus_we_out <= 1;

                        if_branch_flag <= 1'b1;
                        if_critical_flag <= 1'b1;
                        excpreq <= 1;
                        pc_ram_en <= 0;

                        if ((priv_in<2) && medeleg_in[12]) begin
                            priv_out <= 2'b01;
                            mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out <= pc;
                            sepc_we_out <= 1;
                            scause_out <= {1'b0, 27'b0, 4'b1100};
                            scause_we_out <= 1;
                            if_branch_addr <= stvec_in;
                        end
                        else begin
                            priv_out <= 2'b11;
                            mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out <= pc;
                            mepc_we_out <= 1;
                            mcause_out <= {1'b0, 27'b0, 4'b1100};
                            mcause_we_out <= 1;
                            if_branch_addr <= mtvec_in;
                        end
                    end
                    else begin
                        excpreq <= 0;
                        pc_ram_en <= 1;
                        if_branch_flag <= 0;
                        if_critical_flag <= 0;
                        if_branch_addr <= 32'b0;

                        mepc_out <= 32'b0;
                        mcause_out <= 32'b0;
                        mstatus_out <= 32'b0;
                        priv_out <= 2'b0;
                        sepc_out <= 32'b0;
                        scause_out <= 32'b0;

                        mepc_we_out <= 0;
                        mcause_we_out <= 0;
                        mstatus_we_out <= 0;
                        priv_we_out <= 0;
                        sepc_we_out <= 0;
                        scause_we_out <= 0;
                    end
                end
            end
            else if(translation & mem_phase[1] & (~mem_phase[0])) begin // 10: physical address
                state <= 17;
                bubble <= 0;
                pc_ram_addr <= {mem_addr_retro[29:10],pc_next[11:0]};
                tlb_virtual <= pc_next[31:12];
                tlb_physical <= mem_addr_retro;
                tlb_valid <= ~tlb_flush;
                mem_phase <= 2'b00;
                pc <= pc_next;

                if ((~mem_addr_retro[0]) | (mem_addr_retro[2] & (~mem_addr_retro[1]))) begin
                    priv_we_out <= 1;
                    mstatus_we_out <= 1;

                    if_branch_flag <= 1'b1;
                    if_critical_flag <= 1'b1;
                    excpreq <= 1;
                    pc_ram_en <= 0;

                    if ((priv_in<2) && medeleg_in[12]) begin
                        priv_out <= 2'b01;
                        mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out <= pc;
                        sepc_we_out <= 1;
                        scause_out <= {1'b0, 27'b0, 4'b1100};
                        scause_we_out <= 1;
                        if_branch_addr <= stvec_in;
                    end
                    else begin
                        priv_out <= 2'b11;
                        mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out <= pc;
                        mepc_we_out <= 1;
                        mcause_out <= {1'b0, 27'b0, 4'b1100};
                        mcause_we_out <= 1;
                        if_branch_addr <= mtvec_in;
                    end
                end
                else if (!(mem_addr_retro[3] | mem_addr_retro[2] | mem_addr_retro[1])) begin
                    priv_we_out <= 1;
                    mstatus_we_out <= 1;

                    if_branch_flag <= 1'b1;
                    if_critical_flag <= 1'b1;
                    excpreq <= 1;
                    pc_ram_en <= 0;

                    if ((priv_in<2) && medeleg_in[12]) begin
                        priv_out <= 2'b01;
                        mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out <= pc;
                        sepc_we_out <= 1;
                        scause_out <= {1'b0, 27'b0, 4'b1100};
                        scause_we_out <= 1;
                        if_branch_addr <= stvec_in;
                    end
                    else begin
                        priv_out <= 2'b11;
                        mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out <= pc;
                        mepc_we_out <= 1;
                        mcause_out <= {1'b0, 27'b0, 4'b1100};
                        mcause_we_out <= 1;
                        if_branch_addr <= mtvec_in;
                    end
                end
                else if (!mem_addr_retro[3] || (priv_in == 2'b00 && (!mem_addr_retro[4])) || (priv_in == 2'b01 && mem_addr_retro[4] && (!mstatus_in[18]))) begin
                    priv_we_out <= 1;
                    mstatus_we_out <= 1;

                    if_branch_flag <= 1'b1;
                    if_critical_flag <= 1'b1;
                    excpreq <= 1;
                    pc_ram_en <= 0;

                    if ((priv_in<2) && medeleg_in[12]) begin
                        priv_out <= 2'b01;
                        mstatus_out <= {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out <= pc;
                        sepc_we_out <= 1;
                        scause_out <= {1'b0, 27'b0, 4'b1100};
                        scause_we_out <= 1;
                        if_branch_addr <= stvec_in;
                    end
                    else begin
                        priv_out <= 2'b11;
                        mstatus_out <= {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out <= pc;
                        mepc_we_out <= 1;
                        mcause_out <= {1'b0, 27'b0, 4'b1100};
                        mcause_we_out <= 1;
                        if_branch_addr <= mtvec_in;
                    end
                end
                else begin
                    excpreq <= 0;
                    pc_ram_en <= 1;
                    if_branch_flag <= 0;
                    if_critical_flag <= 0;
                    if_branch_addr <= 32'b0;

                    mepc_out <= 32'b0;
                    mcause_out <= 32'b0;
                    mstatus_out <= 32'b0;
                    priv_out <= 2'b0;
                    sepc_out <= 32'b0;
                    scause_out <= 32'b0;

                    mepc_we_out <= 0;
                    mcause_we_out <= 0;
                    mstatus_we_out <= 0;
                    priv_we_out <= 0;
                    sepc_we_out <= 0;
                    scause_we_out <= 0;
                end
            end
            else begin // doesn't need translation
                state <= 18;
                bubble <= 0;
                pc_ram_addr <= pc_next;
                mem_phase <= 2'b00;
                pc <= pc_next;

                excpreq <= 0;
                pc_ram_en <= 1;
                if_branch_flag <= 0;
                if_critical_flag <= 0;
                if_branch_addr <= 32'b0;

                mepc_out <= 32'b0;
                mcause_out <= 32'b0;
                mstatus_out <= 32'b0;
                priv_out <= 2'b0;
                sepc_out <= 32'b0;
                scause_out <= 32'b0;

                mepc_we_out <= 0;
                mcause_we_out <= 0;
                mstatus_we_out <= 0;
                priv_we_out <= 0;
                sepc_we_out <= 0;
                scause_we_out <= 0;
            end
        end
    end
end

endmodule
