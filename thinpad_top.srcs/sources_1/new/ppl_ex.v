`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_ex(
    input wire rst,

    input wire[31:0] pc_in,

    input wire[6:0] alu_opcode_in,
    input wire[2:0] alu_funct3_in,
    input wire[6:0] alu_funct7_in,
    input wire[31:0] regs1_in,
    input wire[31:0] regs2_in,
    input wire[4:0] regd_in,
    input wire regd_en_in,
    input wire mem_en_in,
    input wire[31:0] mem_addr_in,
    input wire[31:0] ret_addr_in,
    
    output wire[6:0] alu_opcode_out,
    output wire[2:0] alu_funct3_out,
    output wire[4:0] regd_out,
    output wire regd_en_out,
    output reg mem_en_out,
    output reg[31:0] mem_addr_out,
    output reg[3:0] mem_be_n_out,

    output reg[31:0] data_out,
    output reg stall_req
);

assign alu_opcode_out = alu_opcode_in;
assign alu_funct3_out = alu_funct3_in;
assign regd_out = regd_in;
assign regd_en_out = regd_en_in;

always @(*) begin
    if (rst) begin
        stall_req = 0;
        data_out = 32'b0;
        mem_en_out = 0;
        mem_addr_out = 32'b0;
        mem_be_n_out = 4'b0;
    end
    else begin
        stall_req = 0;
        data_out = 32'b0;
        mem_en_out = 0;
        mem_addr_out = 32'b0;
        mem_be_n_out = 4'b0;
        case (alu_opcode_in)
            `OP_R: begin
                case (alu_funct3_in)
                    `FUNCT3_ADD: begin
                        data_out = regs1_in + regs2_in;
                    end
                    `FUNCT3_AND: begin
                        data_out = regs1_in & regs2_in;
                    end
                    `FUNCT3_XOR: begin
                        case (alu_funct7_in)
                            `FUNCT7_XOR: begin
                                data_out = regs1_in ^ regs2_in;
                            end
                            `FUNCT7_PACK: begin
                                data_out = {regs2_in[15:0], regs1_in[15:0]};
                            end
                            `FUNCT7_XNOR: begin
                                data_out = regs1_in ^ (~regs2_in);
                            end
                        endcase
                    end
                    `FUNCT3_OR: begin
                        case (alu_funct7_in)
                            `FUNCT7_OR: begin
                                data_out = regs1_in | regs2_in;
                            end
                            `FUNCT7_MINU: begin
                                if (regs1_in < regs2_in)
                                    data_out = regs1_in;
                                else
                                    data_out = regs2_in;
                            end
                        endcase
                    end
                endcase
            end
            `OP_I: begin
                case (alu_funct3_in)
                    `FUNCT3_ADDI: begin
                        data_out = regs1_in + regs2_in;
                    end
                    `FUNCT3_ANDI: begin
                        data_out = regs1_in & regs2_in;
                    end
                    `FUNCT3_ORI: begin
                        data_out = regs1_in | regs2_in;
                    end
                    `FUNCT3_SLLI: begin
                        data_out = regs1_in << regs2_in;
                    end
                    `FUNCT3_SRLI: begin
                        data_out = regs1_in >> regs2_in;
                    end
                endcase
            end
            `OP_LUI, `OP_AUIPC: begin
                data_out = regs1_in;
            end
            `OP_S: begin
                data_out = regs2_in;
                stall_req = 1;
                mem_addr_out = regs1_in + mem_addr_in;
                mem_en_out = mem_en_in;
                case (alu_funct3_in)
                    `FUNCT3_SW: begin
                        mem_be_n_out = 4'b0;
                    end
                    `FUNCT3_SB: begin
                        case (regs1_in[1:0] + mem_addr_in[1:0])
                            2'b00:
                                mem_be_n_out = 4'b1110;
                            2'b01:
                                mem_be_n_out = 4'b1101;
                            2'b10:
                                mem_be_n_out = 4'b1011;
                            2'b11:
                                mem_be_n_out = 4'b0111;
                        endcase
                    end
                endcase
            end
            `OP_L: begin
                data_out = 32'b0;
                stall_req = 1;
                mem_addr_out = regs1_in + mem_addr_in;
                mem_en_out = mem_en_in;
                case (alu_funct3_in)
                    `FUNCT3_LW: begin
                        mem_be_n_out = 4'b0;
                    end
                    `FUNCT3_LB: begin
                        case (regs1_in[1:0] + mem_addr_in[1:0])
                            2'b00:
                                mem_be_n_out = 4'b1110;
                            2'b01:
                                mem_be_n_out = 4'b1101;
                            2'b10:
                                mem_be_n_out = 4'b1011;
                            2'b11:
                                mem_be_n_out = 4'b0111;
                        endcase
                    end
                endcase
            end
            `OP_B: begin
                data_out = 0;
            end
            `OP_JAL, `OP_JALR: begin
                data_out = ret_addr_in;
            end
            `OP_CSR: begin
                // TODO: CSR instruction
            end
        endcase
    end
end

endmodule
