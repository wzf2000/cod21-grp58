`timescale 1ns / 1ps

module ppl_ctrl(
    input wire rst,
    // 1: stop 0: normal
    input wire stallreq_id, // ID stage req for stop
    input wire stallreq_ex, // EXE stage req for stop
    input wire stallreq_mem, // MEM stage req for stop
    input wire excpreq_if,
    input wire excpreq_id,
    input wire excpreq_ex,
    input wire excpreq_mem,
    output wire stall,
    output reg[3:0] excp // PC_reg | if/id | id/ex | ex/mem
);

reg stall_reg;
assign stall = stall_reg;

always @(*) begin
    if (rst) begin
        stall_reg = 0;
        excp = 4'b0;
    end
    else begin
        stall_reg = 0;
        excp = 4'b0;
        if (stallreq_id) begin
            stall_reg = 1;
        end
        if (stallreq_ex) begin
            stall_reg = 1;
        end
        if (stallreq_mem) begin
            stall_reg = 1;
        end
        if (excpreq_if) begin
            excp = 4'b0001;
        end
        if (excpreq_id) begin
            excp = 4'b0011;
        end
        if (excpreq_ex) begin
            excp = 4'b0111;
        end
        if (excpreq_mem) begin
            excp = 4'b1111;
        end
    end
end

endmodule
