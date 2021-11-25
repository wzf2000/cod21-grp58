`default_nettype none
`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_id(
    input wire rst,
    input wire[31:0] pc_in,
    input wire[31:0] instr,

    input wire[31:0] regs1_in,
    input wire[31:0] regs2_in,

    output reg[31:0] regs1_out,
    output reg[31:0] regs2_out,

    input wire [31:0] if_mepc,
    input wire [31:0] if_mcause,
    input wire [31:0] if_mstatus,
    input wire [1:0] if_priv,
    input wire [31:0] if_sepc,
    input wire [31:0] if_scause,

    input wire if_mepc_we,
    input wire if_mcause_we,
    input wire if_mstatus_we,
    input wire if_priv_we,
    input wire if_sepc_we,
    input wire if_scause_we,

    // EXE stage
    input wire[6:0] ex_alu_opcode_in,
    input wire ex_regd_en_in,
    input wire[4:0] ex_regd_addr_in,
    input wire[31:0] ex_data_in,

    input wire ex_mtvec_we,
    input wire ex_mscratch_we,
    input wire ex_mepc_we,
    input wire ex_mcause_we,
    input wire ex_mstatus_we,
    input wire ex_mie_we,
    input wire ex_mip_we,
    input wire ex_satp_we,
    input wire ex_privilege_we,
    input wire ex_mtval_we,
    input wire ex_mideleg_we,
    input wire ex_medeleg_we,
    input wire ex_sepc_we,
    input wire ex_scause_we,
    input wire ex_stval_we,
    input wire ex_stvec_we,
    input wire ex_sscratch_we,

    input wire [31:0] ex_mtvec_data_in,
    input wire [31:0] ex_mscratch_data_in,
    input wire [31:0] ex_mepc_data_in,
    input wire [31:0] ex_mcause_data_in,
    input wire [31:0] ex_mstatus_data_in,
    input wire [31:0] ex_mie_data_in,
    input wire [31:0] ex_mip_data_in,
    input wire [31:0] ex_satp_data_in,
    input wire [1:0] ex_privilege_data_in,
    input wire [31:0] ex_mtval_data_in,
    input wire [31:0] ex_mideleg_data_in,
    input wire [31:0] ex_medeleg_data_in,
    input wire [31:0] ex_sepc_data_in,
    input wire [31:0] ex_scause_data_in,
    input wire [31:0] ex_stval_data_in,
    input wire [31:0] ex_stvec_data_in,
    input wire [31:0] ex_sscratch_data_in,

    // MEM stage
    input wire mem_regd_en_in,
    input wire[4:0] mem_regd_addr_in,
    input wire[31:0] mem_data_in,

    output wire[4:0] regs1_addr,
    output wire[4:0] regs2_addr,

    output wire[4:0] regd_addr, // address of register d
    output reg reg_write, // whether to write register d

    output reg[31:0] pc_out,
    output reg[6:0] alu_opcode,
    output reg[2:0] alu_funct3,
    output reg[6:0] alu_funct7,
    output reg[11:0] alu_funct_csr,

    output reg mem_en,
    output reg[31:0] mem_addr,

    output reg[31:0] ret_addr,
    output reg branch_flag_out,
    output reg critical_flag_out,
    output reg[31:0] branch_addr_out,
    output reg tlb_flush,

    //get CSR value from CSR file
    input wire [31:0] mtvec_data_in,
    input wire [31:0] mscratch_data_in,
    input wire [31:0] mepc_data_in,
    input wire [31:0] mcause_data_in,
    input wire [31:0] mstatus_data_in,
    input wire [31:0] mie_data_in,
    input wire [31:0] mip_data_in,
    input wire [31:0] satp_data_in,
    input wire [1:0] privilege_data_in,
    input wire [31:0] mtval_data_in,
    input wire [31:0] mideleg_data_in,
    input wire [31:0] medeleg_data_in,
    input wire [31:0] sepc_data_in,
    input wire [31:0] scause_data_in,
    input wire [31:0] stval_data_in,
    input wire [31:0] stvec_data_in,
    input wire [31:0] sscratch_data_in,

    //output whether CSR is written to
    output reg mtvec_we,
    output reg mscratch_we,
    output reg mepc_we,
    output reg mcause_we,
    output reg mstatus_we,
    output reg mie_we,
    output reg mip_we,
    output reg satp_we,
    output reg privilege_we,
    output reg mtval_we,
    output reg mideleg_we,
    output reg medeleg_we,
    output reg sepc_we,
    output reg scause_we,
    output reg stval_we,
    output reg stvec_we,
    output reg sscratch_we,

    //pass on CSR value to next stage
    output reg [31:0] mtvec_data_out,
    output reg [31:0] mscratch_data_out,
    output reg [31:0] mepc_data_out,
    output reg [31:0] mcause_data_out,
    output reg [31:0] mstatus_data_out,
    output reg [31:0] mie_data_out,
    output reg [31:0] mip_data_out,
    output reg [31:0] satp_data_out,
    output reg [1:0] privilege_data_out,
    output reg [31:0] mtval_data_out,
    output reg [31:0] mideleg_data_out,
    output reg [31:0] medeleg_data_out,
    output reg [31:0] sepc_data_out,
    output reg [31:0] scause_data_out,
    output reg [31:0] stval_data_out,
    output reg [31:0] stvec_data_out,
    output reg [31:0] sscratch_data_out,

    output wire stallreq,
    input wire excpreq_in,
    output reg excpreq
);

reg regs1_en;
reg regs2_en;

assign regd_addr = instr[11:7];
assign regs1_addr = instr[19:15];
assign regs2_addr = instr[24:20];

wire[6:0] opcode;
assign opcode = instr[6:0];
wire[2:0] funct3;
assign funct3 = instr[14:12];
wire[4:0] rd_addr;
assign rd_addr = instr[11:7];
wire[6:0] funct7;
assign funct7 = instr[31:25];

reg[31:0] imm;

// Jal offset
wire [31:0] offset;
assign offset = {{12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21]};

reg stall_req_regs1;
reg stall_req_regs2;
reg stall_req_LSBJ;

always @(*) begin
    if (rst) begin
        pc_out = 32'b0;
        alu_opcode = `OP_NOP;
        alu_funct3 = `FUNCT3_NOP;
        alu_funct7 = `FUNCT7_NOP;
        alu_funct_csr = 0;
        reg_write = 0;
        regs1_en = 0;
        regs2_en = 0;
        imm = 32'b0;
        ret_addr = 32'b0;
        stall_req_LSBJ = 0;
        excpreq = 0;
        mem_en = 0;
        mem_addr = 32'b0;
        branch_flag_out = 0;
        critical_flag_out = 0;
        branch_addr_out = 32'b0;
        tlb_flush = 0;
        {mtvec_we, mscratch_we, mepc_we, mcause_we, mstatus_we, mie_we, mip_we, satp_we, privilege_we} = 9'b0;
        {mtval_we, mideleg_we, medeleg_we, sepc_we, scause_we, stval_we, stvec_we, sscratch_we} = 8'b0;
    end
    else begin
        pc_out = pc_in;
        alu_opcode = `OP_NOP;
        alu_funct3 = `FUNCT3_NOP;
        alu_funct7 = `FUNCT7_NOP;
        alu_funct_csr = 0;
        reg_write = 0;
        regs1_en = 0;
        regs2_en = 0;
        imm = 32'b0;
        ret_addr = 32'b0;
        stall_req_LSBJ = 0;
        excpreq = excpreq_in;
        mem_en = 0;
        mem_addr = 32'b0;
        branch_flag_out = 0;
        critical_flag_out = 0;
        branch_addr_out = 32'b0;
        tlb_flush = 0;

        // {mtvec_we, mscratch_we, mepc_we, mcause_we, mstatus_we, mie_we, mip_we, satp_we, privilege_we} = 9'b0;
        {mtvec_we, mscratch_we, mie_we, mip_we, satp_we} = 5'b0;
        mepc_we = if_mepc_we;
        mcause_we = if_mcause_we;
        mstatus_we = if_mstatus_we;
        privilege_we = if_priv_we;
        sepc_we = if_sepc_we;
        scause_we = if_scause_we;
        {mtval_we, mideleg_we, medeleg_we, stval_we, stvec_we, sscratch_we} = 6'b0;

        if (mip_data_out[7] & mie_data_out[7] & (mstatus_data_out[3] | ~privilege_data_out[0])) //MTIP && MTIE && (MIE || priv<M)
        begin //machine timer interrupt
            alu_opcode = `OP_CSR;
            alu_funct3 = `FUNCT3_EBREAK;  //similar to ebreak
            alu_funct_csr = 12'hfff; //self-defined code
            privilege_we = 1'b1;
            mstatus_we = 1'b1;
            mepc_we = 1'b1;
            mcause_we = 1'b1;
            branch_flag_out = 1'b1;
            critical_flag_out = 1'b1;
            branch_addr_out = mtvec_data_out;
            excpreq = 1;
        end
        else if (mip_data_out[5] && mie_data_out[5] && (((privilege_data_out==2'b01)&&mstatus_data_out[1])||(privilege_data_out==2'b00))) //supervisor timer interrupt
        begin //supervisor timer interrupt
            alu_opcode = `OP_CSR;
            alu_funct3 = `FUNCT3_EBREAK;
            alu_funct_csr = 12'hffe; //self-defined code
            privilege_we = 1'b1;
            mstatus_we = 1'b1;
            sepc_we = 1'b1;
            scause_we = 1'b1;
            branch_flag_out = 1'b1;
            critical_flag_out = 1'b1;
            branch_addr_out = stvec_data_out;
            excpreq = 1;
        end
        else begin
            case (opcode)
                `OP_R: begin
                    regs1_en = 1;
                    regs2_en = 1;
                    case (funct3)
                        `FUNCT3_AND, `FUNCT3_SLT, `FUNCT3_SLTU, `FUNCT3_SLL: begin
                            alu_opcode = opcode;
                            alu_funct3 = funct3;
                            alu_funct7 = funct7;
                            reg_write = 1;
                        end
                        `FUNCT3_SRL: begin
                            case (funct7)
                                `FUNCT7_SRL, `FUNCT7_SRA: begin
                                    alu_opcode = opcode;
                                    alu_funct3 = funct3;
                                    alu_funct7 = funct7;
                                    reg_write = 1;
                                end
                                default: begin
                                    regs1_en = 0;
                                    regs2_en = 0;
                                end
                            endcase
                        end
                        `FUNCT3_ADD: begin
                            case (funct7)
                                `FUNCT7_ADD, `FUNCT7_SUB: begin
                                    alu_opcode = opcode;
                                    alu_funct3 = funct3;
                                    alu_funct7 = funct7;
                                    reg_write = 1;
                                end
                                default: begin
                                    regs1_en = 0;
                                    regs2_en = 0;
                                end
                            endcase
                        end
                        `FUNCT3_XOR: begin
                            case (funct7)
                                `FUNCT7_XOR, `FUNCT7_PACK, `FUNCT7_XNOR: begin
                                    alu_opcode = opcode;
                                    alu_funct3 = funct3;
                                    alu_funct7 = funct7;
                                    reg_write = 1;
                                end
                                default: begin
                                    regs1_en = 0;
                                    regs2_en = 0;
                                end
                            endcase
                        end
                        `FUNCT3_OR: begin
                            case (funct7)
                                `FUNCT7_OR, `FUNCT7_MINU: begin
                                    alu_opcode = opcode;
                                    alu_funct3 = funct3;
                                    alu_funct7 = funct7;
                                    reg_write = 1;
                                end
                                default: begin
                                    regs1_en = 0;
                                    regs2_en = 0;
                                end
                            endcase
                        end
                        default: begin
                            regs1_en = 0;
                            regs2_en = 0;
                        end
                    endcase
                end
                `OP_I: begin
                    regs1_en = 1;
                    case (funct3)
                        `FUNCT3_ADDI, `FUNCT3_ANDI, `FUNCT3_ORI, `FUNCT3_SLTI, `FUNCT3_SLTIU, `FUNCT3_XORI: begin
                            alu_opcode = opcode;
                            alu_funct3 = funct3;
                            alu_funct7 = funct7;
                            reg_write = 1;
                            imm = {{20{instr[31]}}, instr[31:20]};
                        end
                        `FUNCT3_SLLI, `FUNCT3_SRLI: begin
                            alu_opcode = opcode;
                            alu_funct3 = funct3;
                            alu_funct7 = funct7;
                            reg_write = 1;
                            imm = {27'b0, instr[24:20]};
                        end
                        default: begin
                            regs1_en = 0;
                        end
                    endcase
                end
                `OP_S: begin
                    alu_opcode = opcode;
                    alu_funct3 = funct3;
                    regs1_en = 1;
                    regs2_en = 1;
                    imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                    mem_en = 1;
                    mem_addr = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                end
                `OP_L: begin
                    alu_opcode = opcode;
                    alu_funct3 = funct3;
                    reg_write = 1;
                    regs1_en = 1;
                    imm = {{20{instr[31]}}, instr[31:20]};
                    mem_en = 1;
                    mem_addr = {{20{instr[31]}}, instr[31:20]};
                end
                `OP_B: begin
                    alu_opcode = opcode;
                    alu_funct3 = funct3;
                    regs1_en = 1;
                    regs2_en = 1;
                    imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                    case (funct3)
                        `FUNCT3_BEQ, `FUNCT3_BNE, `FUNCT3_BLT, `FUNCT3_BGE, `FUNCT3_BLTU, `FUNCT3_BGEU: begin
                            if (ex_alu_opcode_in == `OP_S || ex_alu_opcode_in == `OP_L) begin
                                stall_req_LSBJ = 1;
                            end
                            else if (funct3 == `FUNCT3_BEQ && regs1_out == regs2_out
                                || funct3 == `FUNCT3_BNE && regs1_out != regs2_out
                                || funct3 == `FUNCT3_BLT && $signed(regs1_out) < $signed(regs2_out)
                                || funct3 == `FUNCT3_BGE && $signed(regs1_out) >= $signed(regs2_out)
                                || funct3 == `FUNCT3_BLTU && regs1_out < regs2_out
                                || funct3 == `FUNCT3_BGEU && regs1_out >= regs2_out) begin
                                branch_flag_out = 1;
                                branch_addr_out = pc_in + {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                            end
                        end
                    endcase
                end
                `OP_AUIPC: begin
                    alu_opcode = opcode;
                    reg_write = 1;
                    imm = pc_in + {instr[31:12], 12'b0};
                end
                `OP_LUI: begin
                    alu_opcode = opcode;
                    reg_write = 1;
                    imm = {instr[31:12], 12'b0};
                end
                `OP_JAL: begin
                    if (ex_alu_opcode_in == `OP_S || ex_alu_opcode_in == `OP_L) begin
                        stall_req_LSBJ = 1;
                    end
                    else begin
                        alu_opcode = opcode;
                        reg_write = 1;
                        regs1_en = 0;
                        regs2_en = 0;
                        imm = offset;
                        ret_addr = pc_in + 4;
                        branch_flag_out = 1;
                        branch_addr_out = (pc_in + (offset << 1));
                    end
                end
                `OP_JALR: begin
                    if (ex_alu_opcode_in == `OP_S || ex_alu_opcode_in == `OP_L) begin
                        stall_req_LSBJ = 1;
                    end
                    else begin
                        alu_opcode = opcode;
                        reg_write = 1;
                        regs1_en = 1;
                        regs2_en = 0;
                        imm = {{20{instr[31]}}, instr[31:20]};
                        ret_addr = pc_in + 4;
                        branch_flag_out = 1;
                        branch_addr_out = (regs1_out + {{19{instr[31]}}, instr[31:20], 1'b0}) & (~32'h00000001);
                    end
                end
                `OP_CSR: begin
                    // todo: CSR instruction
                    alu_opcode = opcode;
                    alu_funct3 = funct3;
                    alu_funct_csr = instr[31:20];
                    case (funct3)
                        `FUNCT3_CSRRC, `FUNCT3_CSRRS, `FUNCT3_CSRRW: begin
                            reg_write = 1;
                            regs1_en = 1;
                            regs2_en = 0;
                            if (regs1_addr == 0) begin
                            end
                            else begin
                                case (instr[31:20])
                                    12'h305: mtvec_we = 1'b1;
                                    12'h340: mscratch_we = 1'b1;
                                    12'h341: mepc_we = 1'b1;
                                    12'h342: mcause_we = 1'b1;
                                    12'h300: mstatus_we = 1'b1;
                                    12'h304: mie_we = 1'b1;
                                    12'h344: mip_we = 1'b1;
                                    12'h180: satp_we = 1'b1;
                                    12'h343: mtval_we = 1'b1;
                                    12'h303: mideleg_we = 1'b1;
                                    12'h302: medeleg_we = 1'b1;
                                    12'h141: sepc_we = 1'b1;
                                    12'h142: scause_we = 1'b1;
                                    12'h143: stval_we = 1'b1;
                                    12'h105: stvec_we = 1'b1;
                                    12'h140: sscratch_we = 1'b1;
                                    default: mtvec_we = 1'b0; //pseudo instruction rdtime, rdtimeh included
                                endcase
                            end
                            excpreq = 1;
                        end
                        `FUNCT3_CSRRCI, `FUNCT3_CSRRSI, `FUNCT3_CSRRWI: begin
                            reg_write = 1;
                            regs1_en = 0;
                            regs2_en = 0;
                            imm = {27'b0, regs1_addr};
                            case (instr[31:20])
                                12'h305: mtvec_we = 1'b1;
                                12'h340: mscratch_we = 1'b1;
                                12'h341: mepc_we = 1'b1;
                                12'h342: mcause_we = 1'b1;
                                12'h300: mstatus_we = 1'b1;
                                12'h304: mie_we = 1'b1;
                                12'h344: mip_we = 1'b1;
                                12'h180: satp_we = 1'b1;
                                12'h343: mtval_we = 1'b1;
                                12'h303: mideleg_we = 1'b1;
                                12'h302: medeleg_we = 1'b1;
                                12'h141: sepc_we = 1'b1;
                                12'h142: scause_we = 1'b1;
                                12'h143: stval_we = 1'b1;
                                12'h105: stvec_we = 1'b1;
                                12'h140: sscratch_we = 1'b1;
                                default: mtvec_we = 1'b0;
                            endcase
                            excpreq = 1;
                        end
                        `FUNCT3_EBREAK: begin
                            reg_write = 0;
                            regs1_en = 0;
                            regs2_en = 0;
                            case(instr[31:20])
                                12'h000: begin //ecall
                                    privilege_we = 1'b1;
                                    mstatus_we = 1'b1;
                                    if ((privilege_data_out<2) && medeleg_data_out[privilege_data_out+8]) begin
                                        sepc_we = 1'b1;
                                        scause_we = 1'b1;
                                        branch_addr_out = stvec_data_out;
                                    end
                                    else begin
                                        mepc_we = 1'b1;
                                        mcause_we = 1'b1;
                                        branch_addr_out = mtvec_data_out;
                                    end
                                    branch_flag_out = 1'b1;
                                    critical_flag_out = 1'b1;
                                    excpreq = 1;
                                end
                                12'h001: begin //ebreak
                                    privilege_we = 1'b1;
                                    mstatus_we = 1'b1;
                                    if ((privilege_data_out<2) && medeleg_data_out[3]) begin
                                        sepc_we = 1'b1;
                                        scause_we = 1'b1;
                                        branch_addr_out = stvec_data_out;
                                    end
                                    else begin
                                        mepc_we = 1'b1;
                                        mcause_we = 1'b1;
                                        branch_addr_out = mtvec_data_out;
                                    end
                                    branch_flag_out = 1'b1;
                                    critical_flag_out = 1'b1;
                                    excpreq = 1;
                                end
                                12'h302: begin //mret
                                    privilege_we = 1'b1;
                                    mstatus_we = 1'b1;
                                    branch_flag_out = 1'b1;
                                    critical_flag_out = 1'b1;
                                    branch_addr_out = mepc_data_out;
                                    excpreq = 1;
                                end
                                12'h102: begin //sret
                                    privilege_we = 1'b1;
                                    mstatus_we = 1'b1;
                                    branch_flag_out = 1'b1;
                                    critical_flag_out = 1'b1;
                                    branch_addr_out = sepc_data_out;
                                    excpreq = 1;
                                end
                                default: begin
                                    if(instr[31:25]==7'b0001001) begin // sfence.vma
                                        //flush TLB
                                        tlb_flush = 1'b1;
                                        alu_opcode = `OP_NOP;
                                        alu_funct3 = `FUNCT3_NOP;
                                        alu_funct7 = `FUNCT7_NOP;
                                    end
                                    else begin
                                        
                                    end
                                end
                            endcase
                        end
                        default: begin
                            reg_write = 0;
                            regs1_en = 0;
                            regs2_en = 0;
                        end
                    endcase
                end
                default: begin
                    // unknown instruction type, do nothing
                end
            endcase
        end
    end
end

always @(*) begin
    mtvec_data_out = mtvec_data_in;
    mscratch_data_out = mscratch_data_in;
    mepc_data_out = mepc_data_in;
    mcause_data_out = mcause_data_in;
    mstatus_data_out = mstatus_data_in;
    mie_data_out = mie_data_in;
    mip_data_out = mip_data_in;
    privilege_data_out = privilege_data_in;
    satp_data_out = satp_data_in;
    mtval_data_out = mtval_data_in;
    mideleg_data_out = mideleg_data_in;
    medeleg_data_out = medeleg_data_in;
    sepc_data_out = sepc_data_in;
    scause_data_out = scause_data_in;
    stval_data_out = stval_data_in;
    stvec_data_out = stvec_data_in;
    sscratch_data_out = sscratch_data_in;
    if (ex_mtvec_we)
        mtvec_data_out = ex_mtvec_data_in;
    if (ex_mscratch_we)
        mscratch_data_out = ex_mscratch_data_in;
    if (ex_mepc_we)
        mepc_data_out = ex_mepc_data_in;
    if (ex_mcause_we)
        mcause_data_out = ex_mcause_data_in;
    if (ex_mstatus_we)
        mstatus_data_out = ex_mstatus_data_in;
    if (ex_mie_we)
        mie_data_out = ex_mie_data_in;
    if (ex_mip_we)
        mip_data_out = ex_mip_data_in;
    if (ex_privilege_we)
        privilege_data_out = ex_privilege_data_in;
    if (ex_satp_we)
        satp_data_out = ex_satp_data_in;
    if (ex_mtval_we)
        mtval_data_out = ex_mtval_data_in;
    if (ex_mideleg_we)
        mideleg_data_out = ex_mideleg_data_in;
    if (ex_medeleg_we)
        medeleg_data_out = ex_medeleg_data_in;
    if (ex_sepc_we)
        sepc_data_out = ex_sepc_data_in;
    if (ex_scause_we)
        scause_data_out = ex_scause_data_in;
    if (ex_stval_we)
        stval_data_out = ex_stval_data_in;
    if (ex_stvec_we)
        stvec_data_out = ex_stvec_data_in;
    if (ex_sscratch_we)
        sscratch_data_out = ex_sscratch_data_in;
    if (if_mepc_we)
        mepc_data_out = if_mepc;
    if (if_mcause_we)
        mcause_data_out = if_mcause;
    if (if_mstatus_we)
        mstatus_data_out = if_mstatus;
    if (if_priv_we)
        privilege_data_out = if_priv;
    if (if_sepc_we)
        sepc_data_out = if_sepc;
    if (if_scause_we)
        scause_data_out = if_scause;
end

always @(*) begin
    stall_req_regs1 = 0;
    if (rst) begin
        regs1_out = 32'b0;
    end
    else if (regs1_en && regs1_addr == 5'b0) begin
        regs1_out = 32'b0;
    end
    else if (regs1_en && ex_alu_opcode_in == `OP_L && ex_regd_addr_in == regs1_addr) begin
        stall_req_regs1 = 1;
        regs1_out = 0;
    end
    else if (regs1_en && ex_regd_en_in && ex_regd_addr_in == regs1_addr) begin
        regs1_out = ex_data_in;
    end
    else if (regs1_en && mem_regd_en_in && mem_regd_addr_in == regs1_addr) begin
        regs1_out = mem_data_in;
    end
    else if (regs1_en) begin
        regs1_out = regs1_in;
    end
    else begin
        regs1_out = imm;
    end
end

always @(*) begin
    stall_req_regs2 = 0;
    if (rst) begin
        regs2_out = 32'b0;
    end
    else if (regs2_en && regs2_addr == 5'b0) begin
        regs2_out = 32'b0;
    end
    else if (regs2_en && ex_alu_opcode_in == `OP_L && ex_regd_addr_in == regs2_addr) begin
        stall_req_regs2 = 1;
        regs2_out = 0;
    end
    else if (regs2_en && ex_regd_en_in && ex_regd_addr_in == regs2_addr) begin
        regs2_out = ex_data_in;
    end
    else if (regs2_en && mem_regd_en_in && mem_regd_addr_in == regs2_addr) begin
        regs2_out = mem_data_in;
    end
    else if (regs2_en) begin
        regs2_out = regs2_in;
    end
    else begin
        regs2_out = imm;
    end
end

assign stallreq = stall_req_regs1 | stall_req_regs2 | stall_req_LSBJ;

endmodule
