`default_nettype none
`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_mem(
    input wire rst,

    input wire[31:0] pc_in,
    input wire[6:0] alu_opcode_in,
    input wire[2:0] alu_funct3_in,

    input wire[4:0] regd_addr_in,
    input wire regd_en_in,
    input wire[31:0] data_in,
    input wire mem_en_in,
    input wire[31:0] mem_addr_in,
    input wire[3:0] mem_be_n_in,
    input wire[31:0] virtual_addr,
    input wire[31:0] satp,
    input wire[1:0] priv,
    input wire[1:0] mem_phase,

    input wire tlb_valid_in,
    input wire [19:0] tlb_virtual_in,
    input wire [31:0] tlb_physical_in,
    input wire tlb_flush,

    output wire ctrl_back,
    output reg [1:0] mem_phase_back,
    output reg [31:0] mem_addr_back,

    output reg[31:0] write_data,
    input wire[31:0] read_data,

    input wire [31:0] mtvec_in,
    input wire [31:0] mscratch_in,
    input wire [31:0] mepc_in,
    input wire [31:0] mcause_in,
    input wire [31:0] mstatus_in,
    input wire [31:0] mie_in,
    input wire [31:0] mip_in,
    input wire [31:0] satp_in,
    input wire [1:0] priv_in,
    input wire [31:0] mtval_in,
    input wire [31:0] mideleg_in,
    input wire [31:0] medeleg_in,
    input wire [31:0] sepc_in,
    input wire [31:0] scause_in,
    input wire [31:0] stval_in,
    input wire [31:0] stvec_in,
    input wire [31:0] sscratch_in,

    output reg [31:0] mtvec_out,
    output reg [31:0] mscratch_out,
    output reg [31:0] mepc_out,
    output reg [31:0] mcause_out,
    output reg [31:0] mstatus_out,
    output reg [31:0] mie_out,
    output reg [31:0] mip_out,
    output reg [31:0] satp_out,
    output reg [1:0] priv_out,
    output reg[31:0] mtval_out,
    output reg[31:0] mideleg_out,
    output reg[31:0] medeleg_out,
    output reg[31:0] sepc_out,
    output reg[31:0] scause_out,
    output reg[31:0] stval_out,
    output reg[31:0] stvec_out,
    output reg[31:0] sscratch_out,

    input wire mtvec_we_in,
    input wire mscratch_we_in,
    input wire mepc_we_in,
    input wire mcause_we_in,
    input wire mstatus_we_in,
    input wire mie_we_in,
    input wire mip_we_in,
    input wire satp_we_in,
    input wire priv_we_in,
    input wire mtval_we_in,
    input wire mideleg_we_in,
    input wire medeleg_we_in,
    input wire sepc_we_in,
    input wire scause_we_in,
    input wire stval_we_in,
    input wire stvec_we_in,
    input wire sscratch_we_in,

    output reg mtvec_we_out,
    output reg mscratch_we_out,
    output reg mepc_we_out,
    output reg mcause_we_out,
    output reg mstatus_we_out,
    output reg mie_we_out,
    output reg mip_we_out,
    output reg satp_we_out,
    output reg priv_we_out,
    output reg mtval_we_out,
    output reg mideleg_we_out,
    output reg medeleg_we_out,
    output reg sepc_we_out,
    output reg scause_we_out,
    output reg stval_we_out,
    output reg stvec_we_out,
    output reg sscratch_we_out,

    output reg[31:0] ram_addr,
    output reg[3:0] ram_be_n,
    output reg ram_ce_n,
    output reg ram_oe_n,
    output reg ram_we_n,

    output reg[4:0] regd_addr_out,
    output reg regd_en_out,
    output reg[31:0] data_out,

    output reg branch_flag_out,
    output reg critical_flag_out,
    output reg[31:0] branch_addr_out,

    output wire stallreq, // go to "thinpad_top"
    input wire excpreq_in,
    output reg excpreq,
    output reg tlb_valid_update,
    output reg [19:0] tlb_virtual_update,
    output reg [31:0] tlb_physical_update
);


wire rw = (alu_opcode_in == `OP_S)||(alu_opcode_in == `OP_L);
wire translation = rw & (~priv[0]) & satp[31];
wire tlb_hit = tlb_valid_in && (tlb_virtual_in == virtual_addr[31:12]);
assign stallreq = translation & (~mem_phase[1]) & (~tlb_hit); //00:level 1 table, 01:level 2 table, 10: physical addr
assign ctrl_back = translation & (~mem_phase[1]) & (~tlb_hit) & (~excpreq);

always @(*) begin
    if (rst) begin
        regd_addr_out = 5'b0;
        regd_en_out = 0;
        data_out = 32'b0;
        write_data = 32'b0;
        ram_addr = 32'b0;
        ram_be_n = 4'b0;
        ram_ce_n = 0;
        ram_we_n = 1;
        ram_oe_n = 1;
        mem_phase_back = 2'b0;
        mem_addr_back = 32'b0;
        tlb_valid_update = 0;
        tlb_virtual_update = 20'b0;
        tlb_physical_update = 32'b0;
        excpreq = 0;

        mtvec_we_out = 0;
        mscratch_we_out = 0;
        mepc_we_out = 0;
        mcause_we_out = 0;
        mstatus_we_out = 0;
        mie_we_out = 0;
        mip_we_out = 0;
        satp_we_out = 0;
        priv_we_out = 0;
        mtval_we_out = 0;
        mideleg_we_out = 0;
        medeleg_we_out = 0;
        sepc_we_out = 0;
        scause_we_out = 0;
        stval_we_out = 0;
        stvec_we_out = 0;
        sscratch_we_out = 0;

        mtvec_out = 0;
        mscratch_out = 0;
        mepc_out = 0;
        mcause_out = 0;
        mstatus_out = 0;
        mie_out = 0;
        mip_out = 0;
        satp_out = 0;
        priv_out = 0;
        mtval_out = 0;
        mideleg_out = 0;
        medeleg_out = 0;
        sepc_out = 0;
        scause_out = 0;
        stval_out = 0;
        stvec_out = 0;
        sscratch_out = 0;
        branch_flag_out = 0;
        critical_flag_out = 0;
        branch_addr_out = 32'b0;
    end
    else begin
        regd_addr_out = regd_addr_in;
        data_out = data_in;
        write_data = 32'b0;
        ram_addr = 32'b0;
        ram_be_n = 4'b0;
        ram_ce_n = 0;
        ram_we_n = 1;
        ram_oe_n = 1;
        mem_phase_back = 2'b0;
        mem_addr_back = 32'b0;
        regd_en_out = regd_en_in;
        tlb_valid_update = tlb_valid_in;
        tlb_virtual_update = tlb_virtual_in;
        tlb_physical_update = tlb_physical_in;
        excpreq = excpreq_in;
        
        mtvec_we_out = mtvec_we_in;
        mscratch_we_out = mscratch_we_in;
        mepc_we_out = mepc_we_in;
        mcause_we_out = mcause_we_in;
        mstatus_we_out = mstatus_we_in;
        mie_we_out = mie_we_in;
        mip_we_out = mip_we_in;
        satp_we_out = satp_we_in;
        priv_we_out = priv_we_in;
        mtval_we_out = mtval_we_in;
        mideleg_we_out = mideleg_we_in;
        medeleg_we_out = medeleg_we_in;
        sepc_we_out = sepc_we_in;
        scause_we_out = scause_we_in;
        stval_we_out = stval_we_in;
        stvec_we_out = stvec_we_in;
        sscratch_we_out = sscratch_we_in;

        mtvec_out = mtvec_in;
        mscratch_out = mscratch_in;
        mepc_out = mepc_in;
        mcause_out = mcause_in;
        mstatus_out = mstatus_in;
        mie_out = mie_in;
        mip_out = mip_in;
        satp_out = satp_in;
        priv_out = priv_in;
        mtval_out = mtval_in;
        mideleg_out = mideleg_in;
        medeleg_out = medeleg_in;
        sepc_out = sepc_in;
        scause_out = scause_in;
        stval_out = stval_in;
        stvec_out = stvec_in;
        sscratch_out = sscratch_in;
        branch_flag_out = 0;
        critical_flag_out = 0;
        branch_addr_out = 32'b0;
        if (mem_en_in) begin
            if (translation & (~mem_phase[1]) & (~mem_phase[0]) & (~tlb_hit)) begin // 00: level 1 table
                regd_en_out = 0;
                ram_addr = {satp[19:0],virtual_addr[31:22],2'b00}; //each PTE is 4bytes
                ram_be_n = 4'b0;
                ram_ce_n = 1'b0;
                ram_we_n = 1'b1;
                ram_oe_n = 1'b0;
                // 7: D, 6: A, 4: U, 3: X, 2: W, 1: R, 0: V
                if (((~read_data[0]) | (read_data[2] & (~read_data[1]))) && (alu_opcode_in == `OP_S || alu_opcode_in == `OP_L)) begin
                    priv_we_out = 1;
                    mstatus_we_out = 1;

                    branch_flag_out = 1'b1;
                    critical_flag_out = 1'b1;
                    excpreq = 1;

                    if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                        priv_out = 2'b01;
                        mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out = pc_in;
                        sepc_we_out = 1;
                        scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        scause_we_out = 1;
                        branch_addr_out = stvec_in;
                    end
                    else begin
                        priv_out = 2'b11;
                        mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out = pc_in;
                        mepc_we_out = 1;
                        mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        mcause_we_out = 1;
                        branch_addr_out = mtvec_in;
                    end
                end
                // mstatus[19] = MXR, mstatus[18] = SUM
                else if (read_data[3] | read_data[2] | read_data[1]) begin //r w x is not all zero, PTE is leaf
                    tlb_virtual_update = virtual_addr[31:12];
                    tlb_physical_update = read_data;
                    tlb_valid_update = ~tlb_flush;
                    if ((alu_opcode_in == `OP_S && (!read_data[2])) || (alu_opcode_in == `OP_L && (!read_data[1]) && (!mstatus_in[19])) || (priv_in == 2'b00 && (!read_data[4])) || (priv_in == 2'b01 && read_data[4] && (!mstatus_in[18]))) begin
                        priv_we_out = 1;
                        mstatus_we_out = 1;

                        branch_flag_out = 1'b1;
                        critical_flag_out = 1'b1;
                        excpreq = 1;

                        if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                            priv_out = 2'b01;
                            mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out = pc_in;
                            sepc_we_out = 1;
                            scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                            scause_we_out = 1;
                            branch_addr_out = stvec_in;
                        end
                        else begin
                            priv_out = 2'b11;
                            mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out = pc_in;
                            mepc_we_out = 1;
                            mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                            mcause_we_out = 1;
                            branch_addr_out = mtvec_in;
                        end
                    end
                    // else if (read_data[10] != 0) begin
                    //     priv_we_out = 1;
                    //     mstatus_we_out = 1;

                    //     branch_flag_out = 1'b1;
                    //     critical_flag_out = 1'b1;
                    //     excpreq = 1;

                    //     if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                    //         priv_out = 2'b01;
                    //         mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                    //         sepc_out = pc_in;
                    //         sepc_we_out = 1;
                    //         scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                    //         scause_we_out = 1;
                    //         branch_addr_out = stvec_in;
                    //     end
                    //     else begin
                    //         priv_out = 2'b11;
                    //         mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                    //         mepc_out = pc_in;
                    //         mepc_we_out = 1;
                    //         mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                    //         mcause_we_out = 1;
                    //         branch_addr_out = mtvec_in;
                    //     end
                    // end
                    // else if ((~read_data[6]) || (alu_opcode_in == `OP_S && (~read_data[7]))) begin
                    //     priv_we_out = 1;
                    //     mstatus_we_out = 1;

                    //     branch_flag_out = 1'b1;
                    //     critical_flag_out = 1'b1;
                    //     excpreq = 1;

                    //     if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                    //         priv_out = 2'b01;
                    //         mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                    //         sepc_out = pc_in;
                    //         sepc_we_out = 1;
                    //         scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                    //         scause_we_out = 1;
                    //         branch_addr_out = stvec_in;
                    //     end
                    //     else begin
                    //         priv_out = 2'b11;
                    //         mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                    //         mepc_out = pc_in;
                    //         mepc_we_out = 1;
                    //         mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                    //         mcause_we_out = 1;
                    //         branch_addr_out = mtvec_in;
                    //     end
                    // end
                    else begin
                        mem_addr_back = {read_data[29:10],virtual_addr[11:0]};
                        mem_phase_back = 2'b10;
                    end
                end
                else begin //r w is is all zero, need to get level 2 table
                    mem_addr_back = {read_data[29:10],virtual_addr[21:12],2'b00};
                    mem_phase_back = 2'b01;
                end
            end
            else if (translation & (~mem_phase[1]) & mem_phase[0] & (~tlb_hit)) begin // 01: level 2 table
                regd_en_out = 0;
                ram_addr = mem_addr_in;
                ram_be_n = 4'b0;
                ram_ce_n = 1'b0;
                ram_we_n = 1'b1;
                ram_oe_n = 1'b0;

                if (((~read_data[0]) | (read_data[2] & (~read_data[1]))) && (alu_opcode_in == `OP_S || alu_opcode_in == `OP_L)) begin
                    priv_we_out = 1;
                    mstatus_we_out = 1;

                    branch_flag_out = 1'b1;
                    critical_flag_out = 1'b1;
                    excpreq = 1;

                    if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                        priv_out = 2'b01;
                        mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out = pc_in;
                        sepc_we_out = 1;
                        scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        scause_we_out = 1;
                        branch_addr_out = stvec_in;
                    end
                    else begin
                        priv_out = 2'b11;
                        mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out = pc_in;
                        mepc_we_out = 1;
                        mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        mcause_we_out = 1;
                        branch_addr_out = mtvec_in;
                    end
                end
                else if (read_data[3] | read_data[2] | read_data[1]) begin //r w x is not all zero, PTE is leaf
                    tlb_virtual_update = virtual_addr[31:12];
                    tlb_physical_update = read_data;
                    tlb_valid_update = ~tlb_flush;

                    if ((alu_opcode_in == `OP_S && (!read_data[2])) || (alu_opcode_in == `OP_L && (!read_data[1]) && (!mstatus_in[19])) || (priv_in == 2'b00 && (!read_data[4])) || (priv_in == 2'b01 && read_data[4] && (!mstatus_in[18]))) begin
                        priv_we_out = 1;
                        mstatus_we_out = 1;

                        branch_flag_out = 1'b1;
                        critical_flag_out = 1'b1;
                        excpreq = 1;

                        if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                            priv_out = 2'b01;
                            mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                            sepc_out = pc_in;
                            sepc_we_out = 1;
                            scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                            scause_we_out = 1;
                            branch_addr_out = stvec_in;
                        end
                        else begin
                            priv_out = 2'b11;
                            mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                            mepc_out = pc_in;
                            mepc_we_out = 1;
                            mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                            mcause_we_out = 1;
                            branch_addr_out = mtvec_in;
                        end
                    end
                    // else if ((~read_data[6]) || (alu_opcode_in == `OP_S && (~read_data[7]))) begin
                    //     priv_we_out = 1;
                    //     mstatus_we_out = 1;

                    //     branch_flag_out = 1'b1;
                    //     critical_flag_out = 1'b1;
                    //     excpreq = 1;

                    //     if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                    //         priv_out = 2'b01;
                    //         mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                    //         sepc_out = pc_in;
                    //         sepc_we_out = 1;
                    //         scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                    //         scause_we_out = 1;
                    //         branch_addr_out = stvec_in;
                    //     end
                    //     else begin
                    //         priv_out = 2'b11;
                    //         mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                    //         mepc_out = pc_in;
                    //         mepc_we_out = 1;
                    //         mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                    //         mcause_we_out = 1;
                    //         branch_addr_out = mtvec_in;
                    //     end
                    // end
                    else begin
                        mem_addr_back = {read_data[29:10],virtual_addr[11:0]};
                        mem_phase_back = 2'b10;
                    end
                end
                else begin //r w is is all zero, page fault
                    priv_we_out = 1;
                    mstatus_we_out = 1;

                    branch_flag_out = 1'b1;
                    critical_flag_out = 1'b1;
                    excpreq = 1;

                    if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                        priv_out = 2'b01;
                        mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out = pc_in;
                        sepc_we_out = 1;
                        scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        scause_we_out = 1;
                        branch_addr_out = stvec_in;
                    end
                    else begin
                        priv_out = 2'b11;
                        mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out = pc_in;
                        mepc_we_out = 1;
                        mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        mcause_we_out = 1;
                        branch_addr_out = mtvec_in;
                    end
                end
            end
            else begin // doesn't need translation or translation done (phase=10)
                if (translation && ((alu_opcode_in == `OP_S && (!tlb_physical_in[2])) || (alu_opcode_in == `OP_L && (!tlb_physical_in[1]) && (!mstatus_in[19])) || (priv_in == 2'b00 && (!tlb_physical_in[4])) || (priv_in == 2'b01 && tlb_physical_in[4] && (!mstatus_in[18])))) begin
                    priv_we_out = 1;
                    mstatus_we_out = 1;

                    branch_flag_out = 1'b1;
                    critical_flag_out = 1'b1;
                    excpreq = 1;

                    if ((priv_in<2) && ((alu_opcode_in==`OP_S&&medeleg_in[15])||(alu_opcode_in==`OP_L&&medeleg_in[13])) ) begin
                        priv_out = 2'b01;
                        mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                        sepc_out = pc_in;
                        sepc_we_out = 1;
                        scause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        scause_we_out = 1;
                        branch_addr_out = stvec_in;
                    end
                    else begin
                        priv_out = 2'b11;
                        mstatus_out = {mstatus_in[31:13], priv_in, mstatus_in[10:8], mstatus_in[3], mstatus_in[6:4], 1'b0, mstatus_in[2:0]};
                        mepc_out = pc_in;
                        mepc_we_out = 1;
                        mcause_out = {1'b0, 27'b0, (alu_opcode_in==`OP_S?4'b1111:4'b1101)};
                        mcause_we_out = 1;
                        branch_addr_out = mtvec_in;
                    end
                end
                else begin
                    regd_en_out = regd_en_in;
                    case (alu_opcode_in)
                        `OP_S: begin
                            if (translation) begin
                                ram_addr = {tlb_physical_in[29:10],virtual_addr[11:0]};
                            end
                            else begin
                                ram_addr = mem_addr_in;
                            end
                            ram_be_n = mem_be_n_in;
                            ram_ce_n = 1'b0;
                            ram_we_n = 1'b0;
                            ram_oe_n = 1'b1;
                            case (mem_be_n_in)
                                4'b0000: begin
                                    write_data = data_in;
                                end
                                4'b1110: begin
                                    write_data = {24'b0, data_in[7:0]};
                                end
                                4'b1101: begin
                                    write_data = {16'b0, data_in[7:0], 8'b0};
                                end
                                4'b1011: begin
                                    write_data = {8'b0, data_in[7:0], 16'b0};
                                end
                                4'b0111: begin
                                    write_data = {data_in[7:0], 24'b0};
                                end
                                4'b1100: begin
                                    write_data = {16'b0, data_in[15:0]};
                                end
                                4'b1001: begin
                                    write_data = {8'b0, data_in[15:0], 8'b0};
                                end
                                4'b0011: begin
                                    write_data = {data_in[15:0], 16'b0};
                                end
                            endcase
                        end
                        `OP_L: begin
                            if (translation) begin
                                ram_addr = {tlb_physical_in[29:10],virtual_addr[11:0]};
                            end
                            else begin
                                ram_addr = mem_addr_in;
                            end
                            ram_be_n = mem_be_n_in;
                            ram_ce_n = 1'b0;
                            ram_we_n = 1'b1;
                            ram_oe_n = 1'b0;
                            if (alu_funct3_in == `FUNCT3_LB || alu_funct3_in == `FUNCT3_LH || alu_funct3_in == `FUNCT3_LW)
                                case (mem_be_n_in)
                                    4'b0000: begin
                                        data_out = read_data;
                                    end
                                    4'b1110: begin
                                        data_out = {{24{read_data[7]}}, read_data[7:0]};
                                    end
                                    4'b1101: begin
                                        data_out = {{24{read_data[15]}}, read_data[15:8]};
                                    end
                                    4'b1011: begin
                                        data_out = {{24{read_data[23]}}, read_data[23:16]};
                                    end
                                    4'b0111: begin
                                        data_out = {{24{read_data[31]}}, read_data[31:24]};
                                    end
                                    4'b1100: begin
                                        data_out = {{16{read_data[15]}}, read_data[15:0]};
                                    end
                                    4'b1001: begin
                                        data_out = {{16{read_data[23]}}, read_data[23:8]};
                                    end
                                    4'b0011: begin
                                        data_out = {{16{read_data[31]}}, read_data[31:16]};
                                    end
                                endcase
                            else if (alu_funct3_in == `FUNCT3_LBU || alu_funct3_in == `FUNCT3_LHU)
                                case (mem_be_n_in)
                                    4'b1110: begin
                                        data_out = {24'b0, read_data[7:0]};
                                    end
                                    4'b1101: begin
                                        data_out = {24'b0, read_data[15:8]};
                                    end
                                    4'b1011: begin
                                        data_out = {24'b0, read_data[23:16]};
                                    end
                                    4'b0111: begin
                                        data_out = {24'b0, read_data[31:24]};
                                    end
                                    4'b1100: begin
                                        data_out = {16'b0, read_data[15:0]};
                                    end
                                    4'b1001: begin
                                        data_out = {16'b0, read_data[23:8]};
                                    end
                                    4'b0011: begin
                                        data_out = {16'b0, read_data[31:16]};
                                    end
                                endcase
                        end
                        default: begin
                            ram_addr = 32'b0;
                            ram_be_n = 4'b0;
                            ram_ce_n = 1'b1;
                            ram_we_n = 1'b1;
                            ram_oe_n = 1'b1;
                        end
                    endcase
                end
            end
        end
        else begin
            ram_ce_n = 1;
            ram_we_n = 1;
        end
    end
end

endmodule
