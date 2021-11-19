`timescale 1ns / 1ps

module ppl_ctrl(
    input wire rst,
    // 1: stop 0: normal
    input wire stallreq_id, // ID stage req for stop
    input wire stallreq_ex, // EXE stage req for stop
    input wire stallreq_mem, // MEM stage req for stop
    output wire stall
);

reg stall_reg;
assign stall = stall_reg;

always @(*) begin
    if (rst) begin
        stall_reg = 0;
    end
    else begin
        stall_reg = 0;
        if (stallreq_id) begin
            stall_reg = 1;
        end
        if (stallreq_ex) begin
            stall_reg = 1;
        end
        if (stallreq_mem) begin
            stall_reg = 1;
        end
    end
end

endmodule
