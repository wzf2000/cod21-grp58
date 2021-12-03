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

    output reg mem_en,
    output reg[31:0] mem_addr,

    output reg[31:0] ret_addr,
    output reg branch_flag_out,
    output reg[31:0] branch_addr_out,

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
        reg_write = 0;
        regs1_en = 0;
        regs2_en = 0;
        imm = 32'b0;
        ret_addr = 32'b0;
        stall_req_LSBJ = 0;
        mem_en = 0;
        mem_addr = 32'b0;
        branch_flag_out = 0;
        branch_addr_out = 32'b0;
    end
    else begin
        pc_out = pc_in;
        alu_opcode = `OP_NOP;
        alu_funct3 = `FUNCT3_NOP;
        alu_funct7 = `FUNCT7_NOP;
        reg_write = 0;
        regs1_en = 0;
        regs2_en = 0;
        imm = 32'b0;
        ret_addr = 32'b0;
        stall_req_LSBJ = 0;
        mem_en = 0;
        mem_addr = 32'b0;
        branch_flag_out = 0;
        branch_addr_out = 32'b0;

        case (opcode)
            `OP_R: begin
                regs1_en = 1;
                regs2_en = 1;
                case (funct3)
                    `FUNCT3_ADD, `FUNCT3_AND: begin
                        alu_opcode = opcode;
                        alu_funct3 = funct3;
                        alu_funct7 = funct7;
                        reg_write = 1;
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
            `OP_R2: begin
                regs1_en = 1;
                regs2_en = 1;
                alu_opcode = opcode;
                alu_funct3 = funct3;
                alu_funct7 = funct7;
                reg_write = 1;
            end
            `OP_I: begin
                regs1_en = 1;
                case (funct3)
                    `FUNCT3_ADDI, `FUNCT3_ANDI, `FUNCT3_ORI: begin
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
                    `FUNCT3_BEQ, `FUNCT3_BNE: begin
                        if (ex_alu_opcode_in == `OP_S || ex_alu_opcode_in == `OP_L) begin
                            stall_req_LSBJ = 1;
                        end
                        else if (funct3 == `FUNCT3_BEQ && regs1_out == regs2_out
                              || funct3 == `FUNCT3_BNE && regs1_out != regs2_out) begin
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
                    branch_addr_out = (regs1_out + {{20{instr[31]}}, instr[31:20]}) & (~32'h00000001);
                end
            end
            `OP_CSR: begin
                // TODO: CSR instruction
            end
            default: begin
                // unknown instruction type, do nothing
            end
        endcase
    end
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
