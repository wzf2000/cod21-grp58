`timescale 1ns / 1ps

module SRAM(
    input wire rst,

    // TIMER
    input wire[63:0] mtime,
    input wire[63:0] mtimecmp,
    output reg mtime_we,
    output reg mtimecmp_we,
    output reg upper,
    output reg[31:0] timer_wdata,

    // CPLD
    output reg uart_rdn,
    output reg uart_wrn,
    input wire uart_dataready,
    input wire uart_tbre,
    input wire uart_tsre,

    // BaseRAM
    inout wire[31:0] base_ram_data,
    output reg[19:0] base_ram_addr,
    output reg[3:0] base_ram_be_n,
    output reg base_ram_ce_n,
    output reg base_ram_oe_n,
    output reg base_ram_we_n,

    // ExtRAM
    inout wire[31:0] ext_ram_data,
    output reg[19:0] ext_ram_addr,
    output reg[3:0] ext_ram_be_n,
    output reg ext_ram_ce_n,
    output reg ext_ram_oe_n,
    output reg ext_ram_we_n,

    // IF stage
    input wire if_en,
    input wire[31:0] if_addr,
    output reg[31:0] if_data,

    // MEM stage
    input wire mem_en,
    input wire[31:0] mem_addr,
    input wire[31:0] mem_data_in,
    input wire[3:0] mem_be_n,
    input wire mem_ce_n,
    input wire mem_oe_n,
    input wire mem_we_n,
    output reg[31:0] mem_data_out,
    output wire[7:0] state
);

reg base_data_z;
reg ext_data_z;

reg[31:0] base_ram_data_reg;
assign base_ram_data = base_data_z ? 32'bz : base_ram_data_reg;
reg[31:0] ext_ram_data_reg;
assign ext_ram_data = ext_data_z ? 32'bz : ext_ram_data_reg;

reg[19:0] mem_address;
reg[2:0] which;

assign state = mem_address[7:0];

`define EXT 3'b000
`define BASE 3'b001
`define UART_DATA 3'b010
`define UART_STATE 3'b011
`define MTIME_ 3'b110
`define MTIMECMP_ 3'b111

always @(*) begin
    if (if_en) begin
        upper = 1'b0;
        mem_address = if_addr[21:2];
        case (if_addr[31:22])
            10'h200: begin // ext ram
                which = `EXT;
            end
            10'h201: begin // base ram
                which = `BASE;
            end
            10'h040: begin // uart
                if (if_addr == 32'h10000000) begin // uart data
                    which = `UART_DATA;
                end
                else if (if_addr == 32'h10000005) begin // uart state
                    which = `UART_STATE;
                end
                else begin
                    which = 3'b100;
                end
            end
            default: begin
                which = 3'b100;
            end
        endcase
    end
    else if (mem_en) begin
        upper = 1'b0;
        mem_address = mem_addr[21:2];
        case (mem_addr[31:22])
            10'h200: begin // ext ram
                which = `EXT;
            end
            10'h201: begin // base ram
                which = `BASE;
            end
            10'h040: begin // uart
                if (mem_addr == 32'h10000000) begin // uart data
                    which = `UART_DATA;
                end
                else if (mem_addr == 32'h10000005) begin // uart state
                    which = `UART_STATE;
                end
                else begin
                    which = 3'b100;
                end
            end
            10'h008: begin // time
                case (mem_addr)
                    32'h0200bff8: begin
                        which = `MTIME_;
                        upper = 1'b0;
                    end
                    32'h0200bffc: begin
                        which = `MTIME_;
                        upper = 1'b1;
                    end
                    32'h02004000: begin
                        which = `MTIMECMP_;
                        upper = 1'b0;
                    end
                    32'h02004004: begin
                        which = `MTIMECMP_;
                        upper = 1'b1;
                    end
                    default: begin
                        which = 3'b100;
                        upper = 1'b0;
                    end
                endcase
            end
            default: begin
                which = 3'b100;
            end
        endcase
    end
    else begin
        upper = 1'b0;
        which = 3'b100;
        mem_address = 20'b0;
    end
end

always @(*) begin
    if_data = 32'b0;
    mem_data_out = 32'b0;
    if (if_en) begin
        case (which)
            `EXT: begin
                if_data = ext_ram_data;
            end
            `BASE: begin
                if_data = base_ram_data;
            end
            `UART_DATA: begin
                if_data = base_ram_data;
            end
            `UART_STATE: begin
                if_data = {18'b0, uart_tbre & uart_tsre, 4'b0, uart_dataready, 8'b0};
            end
            default: begin
                // unknown address, do nothing
            end
        endcase
    end
    else if (mem_en) begin
        case (which)
            `EXT: begin
                mem_data_out = ext_ram_data;
            end
            `BASE: begin
                mem_data_out = base_ram_data;
            end
            `UART_DATA: begin
                mem_data_out = base_ram_data;
            end
            `UART_STATE: begin
                mem_data_out = {18'b0, uart_tbre & uart_tsre, 4'b0, uart_dataready, 8'b0};
            end
            `MTIME_: begin
                if (upper) mem_data_out = mtime[63:32];
                else mem_data_out = mtime[31:0];
            end
            `MTIMECMP_: begin
                if (upper) mem_data_out = mtimecmp[63:32];
                else mem_data_out = mtimecmp[31:0];
            end
            default: begin
                // unknown address, do nothing
            end
        endcase
    end
end

always @(*) begin
    base_data_z = 1;
    base_ram_be_n = 4'b0000;
    base_ram_ce_n = 1;
    base_ram_oe_n = 1;
    base_ram_we_n = 1;
    base_ram_addr = 20'b0;
    base_ram_data_reg = 32'b0;

    ext_data_z = 1;
    ext_ram_be_n = 4'b0000;
    ext_ram_ce_n = 1;
    ext_ram_oe_n = 1;
    ext_ram_we_n = 1;
    ext_ram_addr = 20'b0;
    ext_ram_data_reg = 32'b0;

    uart_rdn = 1;
    uart_wrn = 1;
    
    mtime_we = 0;
    mtimecmp_we = 0;
    timer_wdata = 32'b0;
    if (if_en) begin
        case (which)
            `EXT: begin
                ext_ram_ce_n = 0;
                ext_ram_oe_n = 0;
                ext_ram_addr = mem_address;
            end
            `BASE: begin
                base_ram_ce_n = 0;
                base_ram_oe_n = 0;
                base_ram_addr = mem_address;
            end
            `UART_DATA: begin
                uart_rdn = 0;
            end
        endcase
    end
    else if (mem_en) begin
        if (!mem_ce_n && !mem_oe_n && mem_we_n) begin // read
            case (which)
                `EXT: begin
                    ext_ram_be_n = mem_be_n;
                    ext_ram_ce_n = 0;
                    ext_ram_oe_n = 0;
                    ext_ram_addr = mem_address;
                end
                `BASE: begin
                    base_ram_be_n = mem_be_n;
                    base_ram_ce_n = 0;
                    base_ram_oe_n = 0;
                    base_ram_addr = mem_address;
                end
                `UART_DATA: begin
                    uart_rdn = 0;
                end
            endcase
        end
        else if (!mem_ce_n && mem_oe_n && !mem_we_n) begin // write
            case (which)
                `EXT: begin
                    ext_data_z = 0;
                    ext_ram_be_n = mem_be_n;
                    ext_ram_ce_n = 0;
                    ext_ram_we_n = 0;
                    ext_ram_addr = mem_address;
                    ext_ram_data_reg = mem_data_in;
                end
                `BASE: begin
                    base_data_z = 0;
                    base_ram_be_n = mem_be_n;
                    base_ram_ce_n = 0;
                    base_ram_we_n = 0;
                    base_ram_addr = mem_address;
                    base_ram_data_reg = mem_data_in;
                end
                `UART_DATA: begin
                    base_data_z = 0;
                    uart_wrn = 0;
                    base_ram_data_reg = {24'b0, mem_data_in[7:0]};
                end
                `MTIME_: begin
                    mtime_we = 1;
                    timer_wdata = mem_data_in;
                end
                `MTIMECMP_: begin
                    mtimecmp_we = 1;
                    timer_wdata = mem_data_in;
                end
            endcase
        end
    end
end

endmodule
