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

    // EXE stage
    input wire[6:0] ex_alu_opcode_in,
    input wire ex_regd_en_in,
    input wire[4:0] ex_regd_addr_in,
    input wire[31:0] ex_data_in,

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

    //pass on CSR value to next stage
    output wire [31:0] mtvec_data_out,
    output wire [31:0] mscratch_data_out,
    output wire [31:0] mepc_data_out,
    output wire [31:0] mcause_data_out,
    output wire [31:0] mstatus_data_out,
    output wire [31:0] mie_data_out,
    output wire [31:0] mip_data_out,
    output wire [31:0] satp_data_out,
    output wire [1:0] privilege_data_out,

    output wire stallreq
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
        mem_en = 0;
        mem_addr = 32'b0;
        branch_flag_out = 0;
        critical_flag_out = 0;
        branch_addr_out = 32'b0;
        tlb_flush = 0;
        {mtvec_we, mscratch_we, mepc_we, mcause_we, mstatus_we, mie_we, mip_we, satp_we, privilege_we} = 9'b0;
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
        mem_en = 0;
        mem_addr = 32'b0;
        branch_flag_out = 0;
        critical_flag_out = 0;
        branch_addr_out = 32'b0;
        tlb_flush = 0;
        {mtvec_we, mscratch_we, mepc_we, mcause_we, mstatus_we, mie_we, mip_we, satp_we, privilege_we} = 9'b0;

        //timer interrupt
        if (mip_data_in[7] & mie_data_in[7] & (mstatus_data_in[3] | ~privilege_data_in[0])) //MTIP && MTIE && MIE
        begin
            alu_opcode = `OP_CSR;
            alu_funct3 = `FUNCT3_EBREAK;  //similar to ebreak
            alu_funct_csr = 12'hfff; //self-defined code
            privilege_we = 1'b1;
            mstatus_we = 1'b1;
            mepc_we = 1'b1;
            mcause_we = 1'b1;
            branch_flag_out = 1'b1;
            critical_flag_out = 1'b1;
            branch_addr_out = mtvec_data_in;
        end
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
                        case(instr[31:20])
                            12'h305: mtvec_we = 1'b1;
                            12'h340: mscratch_we = 1'b1;
                            12'h341: mepc_we = 1'b1;
                            12'h342: mcause_we = 1'b1;
                            12'h300: mstatus_we = 1'b1;
                            12'h304: mie_we = 1'b1;
                            12'h344: mip_we = 1'b1;
                            12'h180: satp_we = 1'b1;
                            default: mtvec_we = 1'b0;
                        endcase
                    end
                    `FUNCT3_EBREAK: begin
                        reg_write = 0;
                        regs1_en = 0;
                        regs2_en = 0;
                        case(instr[31:20])
                            12'h000, 12'h001: begin //ecall, ebreak
                                privilege_we = 1'b1;
                                mstatus_we = 1'b1;
                                mepc_we = 1'b1;
                                mcause_we = 1'b1;
                                branch_flag_out = 1'b1;
                                critical_flag_out = 1'b1;
                                branch_addr_out = mtvec_data_in;
                            end
                            12'h302: begin //mret
                                privilege_we = 1'b1;
                                mstatus_we = 1'b1;
                                branch_flag_out = 1'b1;
                                critical_flag_out = 1'b1;
                                branch_addr_out = mepc_data_in;
                            end
                            default: begin
                                if(instr[31:25]==7'b0001001) begin
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

//Forwarding is done inside csr.v
assign mtvec_data_out = mtvec_data_in;
assign mscratch_data_out = mscratch_data_in;
assign mepc_data_out = mepc_data_in;
assign mcause_data_out = mcause_data_in;
assign mstatus_data_out = mstatus_data_in;
assign mie_data_out = mie_data_in;
assign mip_data_out = mip_data_in;
assign privilege_data_out = privilege_data_in;
assign satp_data_out = satp_data_in;

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
