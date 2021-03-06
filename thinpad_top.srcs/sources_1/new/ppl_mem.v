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

    output reg[31:0] write_data,
    input wire[31:0] read_data,

    output reg[31:0] ram_addr,
    output reg[3:0] ram_be_n,
    output reg ram_ce_n,
    output reg ram_oe_n,
    output reg ram_we_n,

    output reg[4:0] regd_addr_out,
    output reg regd_en_out,
    output reg[31:0] data_out
);

always @(*) begin
    if (rst) begin
        regd_addr_out = 5'b0;
        regd_en_out = 0;
        data_out = 32'b0;
        write_data = 32'b0;
        ram_addr = 32'b0;
        ram_be_n = 4'b0;
        ram_ce_n = 0;
        ram_we_n = 0;
        ram_oe_n = 1;
    end
    else begin
        regd_addr_out = regd_addr_in;
        regd_en_out = regd_en_in;
        data_out = data_in;
        write_data = 32'b0;
        ram_addr = 32'b0;
        ram_be_n = 4'b0;
        ram_ce_n = 0;
        ram_we_n = 0;
        ram_oe_n = 1;
        if (mem_en_in) begin
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
        else begin
            ram_ce_n = 1;
            ram_we_n = 1;
        end
    end
end

endmodule
