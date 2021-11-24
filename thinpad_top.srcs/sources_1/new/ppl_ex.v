`default_nettype none
`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_ex(
    input wire rst,

    input wire[31:0] pc_in,

    input wire[6:0] alu_opcode_in,
    input wire[2:0] alu_funct3_in,
    input wire[6:0] alu_funct7_in,
    input wire[11:0] alu_funct_csr_in,
    input wire[31:0] regs1_in,
    input wire[31:0] regs2_in,
    input wire[4:0] regd_in,
    input wire regd_en_in,
    input wire mem_en_in,
    input wire[31:0] mem_addr_in,
    input wire[31:0] ret_addr_in,

    output reg[31:0] pc_out,
    
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

    input wire [63:0] mtime_in,

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
    
    output wire[6:0] alu_opcode_out,
    output wire[2:0] alu_funct3_out,
    output wire[4:0] regd_out,
    output wire regd_en_out,
    output reg mem_en_out,
    output reg[31:0] mem_addr_out,
    output reg[3:0] mem_be_n_out,

    output reg[31:0] data_out,
    output reg stall_req,
    input wire excpreq_in,
    output reg excpreq
);

assign alu_opcode_out = alu_opcode_in;
assign alu_funct3_out = alu_funct3_in;
assign regd_out = regd_in;
assign regd_en_out = regd_en_in;

always @(*) begin
    if (rst) begin
        pc_out = 32'b0;
        stall_req = 0;
        excpreq = 0;
        data_out = 32'b0;
        mem_en_out = 0;
        mem_addr_out = 32'b0;
        mem_be_n_out = 4'b0;

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
    end
    else begin
        pc_out = pc_in;
        stall_req = 0;
        excpreq = excpreq_in;
        data_out = 32'b0;
        mem_en_out = 0;
        mem_addr_out = 32'b0;
        mem_be_n_out = 4'b0;
        
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
        case (alu_opcode_in)
            `OP_R: begin
                case (alu_funct3_in)
                    `FUNCT3_ADD: begin
                        if (alu_funct7_in == `FUNCT7_ADD)
                            data_out = regs1_in + regs2_in;
                        else if (alu_funct7_in == `FUNCT7_SUB)
                            data_out = regs1_in - regs2_in;
                    end
                    `FUNCT3_AND: begin
                        data_out = regs1_in & regs2_in;
                    end
                    `FUNCT3_SLT: begin
                        if ($signed(regs1_in) < $signed(regs2_in)) data_out = 1;
                        else data_out = 0;
                    end
                    `FUNCT3_SLTU: begin
                        if (regs1_in < regs2_in) data_out = 1;
                        else data_out = 0;
                    end
                    `FUNCT3_SLL: begin
                        data_out = regs1_in << regs2_in;
                    end
                    `FUNCT3_SRL: begin
                        if (alu_funct7_in == `FUNCT7_SRL)
                            data_out = regs1_in >> regs2_in;
                        else if (alu_funct7_in == `FUNCT7_SRA)
                            data_out = $signed(regs1_in) >> regs2_in;
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
                        if (alu_funct7_in == `FUNCT7_SRLI)
                            data_out = regs1_in >> regs2_in;
                        else if (alu_funct7_in == `FUNCT7_SRAI)
                            data_out = $signed(regs1_in) >>> regs2_in;
                    end
                    `FUNCT3_SLTI: begin
                        data_out = $signed(regs1_in) < $signed(regs2_in);
                    end
                    `FUNCT3_SLTIU: begin
                        data_out = regs1_in < regs2_in;
                    end
                    `FUNCT3_XORI: begin
                        data_out = regs1_in ^ regs2_in;
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
                    `FUNCT3_SH: begin
                        case (regs1_in[1:0] + mem_addr_in[1:0])
                            2'b00:
                                mem_be_n_out = 4'b1100;
                            2'b01:
                                mem_be_n_out = 4'b1100;
                            2'b10:
                                mem_be_n_out = 4'b0011;
                            2'b11:
                                mem_be_n_out = 4'b0011;
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
                    `FUNCT3_LB, `FUNCT3_LBU: begin
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
                    `FUNCT3_LH, `FUNCT3_LHU: begin
                        case (regs1_in[1:0] + mem_addr_in[1:0])
                            2'b00:
                                mem_be_n_out = 4'b1100;
                            2'b01:
                                mem_be_n_out = 4'b1100;
                            2'b10:
                                mem_be_n_out = 4'b0011;
                            2'b11:
                                mem_be_n_out = 4'b0011;
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
                // todo: CSR instruction
                case (alu_funct3_in)
                    `FUNCT3_CSRRC, `FUNCT3_CSRRCI: begin
                        case (alu_funct_csr_in)
                            12'h305: begin
                                data_out = mtvec_in;
                                mtvec_out = mtvec_in & ~regs1_in;
                            end
                            12'h340: begin
                                data_out = mscratch_in;
                                mscratch_out = mscratch_in & ~regs1_in;
                            end
                            12'h341: begin
                                data_out = mepc_in;
                                mepc_out = mepc_in & ~regs1_in;
                            end
                            12'h342: begin
                                data_out = mcause_in;
                                mcause_out = mcause_in & ~regs1_in;
                            end
                            12'h300: begin
                                data_out = mstatus_in;
                                mstatus_out = mstatus_in & ~regs1_in;
                            end
                            12'h302: begin
                                data_out = medeleg_in;
                                medeleg_out = medeleg_in & ~regs1_in;
                            end
                            12'h303: begin
                                data_out = mideleg_in;
                                mideleg_out = mideleg_in & ~regs1_in;
                            end
                            12'h304: begin
                                data_out = mie_in;
                                mie_out = mie_in & ~regs1_in;
                            end
                            12'h343: begin
                                data_out = mtval_in;
                                mtval_out = mtval_in & ~regs1_in;
                            end
                            12'h344: begin
                                data_out = mip_in;
                                mip_out = mip_in & ~regs1_in;
                            end
                            12'h180: begin
                                data_out = satp_in;
                                satp_out = satp_in & ~regs1_in;
                            end
                            12'h105: begin
                                data_out = stvec_in;
                                stvec_out = stvec_in & ~regs1_in;
                            end
                            12'h140: begin
                                data_out = sscratch_in;
                                sscratch_out = sscratch_in & ~regs1_in;
                            end
                            12'h141: begin
                                data_out = sepc_in;
                                sepc_out = sepc_in & ~regs1_in;
                            end
                            12'h142: begin
                                data_out = scause_in;
                                scause_out = scause_in & ~regs1_in;
                            end
                            12'h143: begin
                                data_out = stval_in;
                                stval_out = stval_in & ~regs1_in;
                            end
                            default: begin
                            end
                        endcase
                    end
                    `FUNCT3_CSRRS, `FUNCT3_CSRRSI: begin
                        case (alu_funct_csr_in)
                            12'h305: begin
                                data_out = mtvec_in;
                                mtvec_out = mtvec_in | regs1_in;
                            end
                            12'h340: begin
                                data_out = mscratch_in;
                                mscratch_out = mscratch_in | regs1_in;
                            end
                            12'h341: begin
                                data_out = mepc_in;
                                mepc_out = mepc_in | regs1_in;
                            end
                            12'h342: begin
                                data_out = mcause_in;
                                mcause_out = mcause_in | regs1_in;
                            end
                            12'h300: begin
                                data_out = mstatus_in;
                                mstatus_out = mstatus_in | regs1_in;
                            end
                            12'h302: begin
                                data_out = medeleg_in;
                                medeleg_out = medeleg_in | regs1_in;
                            end
                            12'h303: begin
                                data_out = mideleg_in;
                                mideleg_out = mideleg_in | regs1_in;
                            end
                            12'h304: begin
                                data_out = mie_in;
                                mie_out = mie_in | regs1_in;
                            end
                            12'h343: begin
                                data_out = mtval_in;
                                mtval_out = mtval_in | regs1_in;
                            end
                            12'h344: begin
                                data_out = mip_in;
                                mip_out = mip_in | regs1_in;
                            end
                            12'h180: begin
                                data_out = satp_in;
                                satp_out = satp_in | regs1_in;
                            end
                            12'h105: begin
                                data_out = stvec_in;
                                stvec_out = stvec_in | regs1_in;
                            end
                            12'h140: begin
                                data_out = sscratch_in;
                                sscratch_out = sscratch_in | regs1_in;
                            end
                            12'h141: begin
                                data_out = sepc_in;
                                sepc_out = sepc_in | regs1_in;
                            end
                            12'h142: begin
                                data_out = scause_in;
                                scause_out = scause_in | regs1_in;
                            end
                            12'h143: begin
                                data_out = stval_in;
                                stval_out = stval_in | regs1_in;
                            end
                            default: begin
                            end
                        endcase
                    end
                    `FUNCT3_CSRRW, `FUNCT3_CSRRWI: begin
                        case (alu_funct_csr_in)
                            12'h305: begin
                                data_out = mtvec_in;
                                mtvec_out = regs1_in;
                            end
                            12'h340: begin
                                data_out = mscratch_in;
                                mscratch_out = regs1_in;
                            end
                            12'h341: begin
                                data_out = mepc_in;
                                mepc_out = regs1_in;
                            end
                            12'h342: begin
                                data_out = mcause_in;
                                mcause_out = regs1_in;
                            end
                            12'h300: begin
                                data_out = mstatus_in;
                                mstatus_out = regs1_in;
                            end
                            12'h302: begin
                                data_out = medeleg_in;
                                medeleg_out = regs1_in;
                            end
                            12'h303: begin
                                data_out = mideleg_in;
                                mideleg_out = regs1_in;
                            end
                            12'h304: begin
                                data_out = mie_in;
                                mie_out = regs1_in;
                            end
                            12'h343: begin
                                data_out = mtval_in;
                                mtval_out = regs1_in;
                            end
                            12'h344: begin
                                data_out = mip_in;
                                mip_out = regs1_in;
                            end
                            12'h180: begin
                                data_out = satp_in;
                                satp_out = regs1_in;
                            end
                            12'h105: begin
                                data_out = stvec_in;
                                stvec_out = regs1_in;
                            end
                            12'h140: begin
                                data_out = sscratch_in;
                                sscratch_out = regs1_in;
                            end
                            12'h141: begin
                                data_out = sepc_in;
                                sepc_out = regs1_in;
                            end
                            12'h142: begin
                                data_out = scause_in;
                                scause_out = regs1_in;
                            end
                            12'h143: begin
                                data_out = stval_in;
                                stval_out = regs1_in;
                            end
                            12'hc01: begin
                                data_out = mtime_in[31:0];
                            end
                            12'hc81: begin
                                data_out = mtime_in[63:32];
                            default: begin
                            end
                        endcase
                    end
                    `FUNCT3_EBREAK: begin
                        case (alu_funct_csr_in)
                            12'h000: begin //ecall
                                if ((priv_in<2) && medeleg_in[priv_in+8]) begin
                                    priv_out = 2'b01;
                                    mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                                    sepc_out = pc_in;
                                    scause_out = {1'b0, 27'b0, 4'b10, priv_in};
                                end
                                else begin
                                    priv_out = 2'b11;
                                    mstatus_out = {mstatus_in[31:13],priv_in,mstatus_in[10:8],mstatus_in[3],mstatus_in[6:4],1'b0,mstatus_in[2:0]};
                                    mepc_out = pc_in;
                                    mcause_out = {1'b0, 27'b0, 4'b10, priv_in}; //environment call from U-mode. From U mode?
                                end
                            end
                            12'h001: begin //ebreak
                                if ((priv_in<2) && medeleg_in[3]) begin
                                    priv_out = 2'b01;
                                    mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                                    sepc_out = pc_in;
                                    scause_out = {1'b0, 27'b0, 4'b0011};
                                end
                                else begin
                                    priv_out = 2'b11;
                                    mstatus_out = {mstatus_in[31:13],priv_in,mstatus_in[10:8],mstatus_in[3],mstatus_in[6:4],1'b0,mstatus_in[2:0]};
                                    mepc_out = pc_in;
                                    mcause_out = {1'b0, 27'b0, 4'b0011}; //breakpoint exception
                                end
                            end
                            12'h302: begin //mret, only available to M mode (so priv_in = 2'b11)
                                priv_out = mstatus_in[12:11];
                                mstatus_out = {mstatus_in[31:13],2'b11,mstatus_in[10:8],mstatus_in[3],mstatus_in[6:4],mstatus_in[7],mstatus_in[2:0]};
                            end
                            12'h102: begin //sret
                                priv_out = {1'b0,mstatus_in[8]};
                                mstatus_out = {mstatus_in[31:9],1'b1,mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],mstatus_in[5],mstatus_in[0]};
                            end
                            12'hffe: begin //supervisor timer interrupt
                                priv_out = 2'b01;
                                mstatus_out = {mstatus_in[31:9],priv_in[0],mstatus_in[7:6],mstatus_in[1],mstatus_in[4:2],1'b0,mstatus_in[0]};
                                sepc_out = pc_in;
                                scause_out = {1'b1, 27'b0, 4'b0111};
                            end
                            12'hfff: begin //timer interrupt
                                priv_out = 2'b11;
                                mstatus_out = {mstatus_in[31:13],priv_in,mstatus_in[10:8],mstatus_in[3],mstatus_in[6:4],1'b0,mstatus_in[2:0]};
                                mepc_out = pc_in;
                                mcause_out = {1'b1, 27'b0, 4'b0111};
                            end
                            default: begin
                            end
                        endcase
                    end
                    default:begin
                        
                    end
                endcase
            end
        endcase
    end
end

endmodule
