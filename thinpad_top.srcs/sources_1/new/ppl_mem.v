`timescale 1ns / 1ps
`include "opcodes.vh"

module ppl_mem(
    input wire rst,

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

    output wire ctrl_back,
    output reg [1:0] mem_phase_back,
    output reg [31:0] mem_addr_back,

    output reg[31:0] write_data,
    input wire[31:0] read_data,

    output reg[31:0] ram_addr,
    output reg[3:0] ram_be_n,
    output reg ram_ce_n,
    output reg ram_oe_n,
    output reg ram_we_n,

    output reg[4:0] regd_addr_out,
    output reg regd_en_out,
    output reg[31:0] data_out,

    output wire stallreq // go to "thinpad_top"
);


wire rw = (alu_opcode_in == `OP_S)||(alu_opcode_in == `OP_L);
wire translation = rw & (~priv[0]) & satp[31];
assign stallreq = translation & (~mem_phase[1]); //00:level 1 table, 01:level 2 table, 10: physical addr
assign ctrl_back = translation & (~mem_phase[1]);

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
        if (mem_en_in) begin
            if(translation & (~mem_phase[1]) & (~mem_phase[0]))begin // 00: level 1 table
                regd_en_out = 0;
                ram_addr = {satp[19:0],virtual_addr[31:22],2'b00}; //each PTE is 4bytes
                ram_be_n = 4'b0;
                ram_ce_n = 1'b0;
                ram_we_n = 1'b1;
                ram_oe_n = 1'b0;
                if (read_data[3]|read_data[2]|read_data[1]) begin //r w x is not all zero, PTE is leaf
                    mem_addr_back = {read_data[29:10],virtual_addr[11:0]};
                    mem_phase_back = 2'b10;
                end
                else begin //r w is is all zero, need to get level 2 table
                    mem_addr_back = {read_data[29:10],virtual_addr[21:12],2'b00};
                    mem_phase_back = 2'b01;
                end
            end
            else if(translation & (~mem_phase[1]) & mem_phase[0])begin // 01: level 2 table
                regd_en_out = 0;
                ram_addr = mem_addr_in;
                ram_be_n = 4'b0;
                ram_ce_n = 1'b0;
                ram_we_n = 1'b1;
                ram_oe_n = 1'b0;
                mem_addr_back = {read_data[29:10],virtual_addr[11:0]};
                mem_phase_back = 2'b10;
            end
            else begin // doesn't need translation or translation done (phase=10)
                regd_en_out = regd_en_in;
                case (alu_opcode_in)
                    `OP_S: begin
                        ram_addr = mem_addr_in;
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
                        ram_addr = mem_addr_in;
                        ram_be_n = mem_be_n_in;
                        ram_ce_n = 1'b0;
                        ram_we_n = 1'b1;
                        ram_oe_n = 1'b0;
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
        else begin
            ram_ce_n = 1;
            ram_we_n = 1;
        end
    end
end

endmodule
