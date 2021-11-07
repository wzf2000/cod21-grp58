`timescale 1ns / 1ps

module ppl_mem_wb(
    input wire clk,
    input wire rst,
    input wire stall,

    input wire[4:0] mem_regd_addr,
    input wire mem_regd_en,
    input wire[31:0] mem_data,

    output reg[4:0] wb_regd_addr,
    output reg wb_regd_en,
    output reg[31:0] wb_data
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        wb_regd_addr <= 5'b0;
        wb_regd_en <= 0;
        wb_data <= 32'b0;
    end
    // else if (stall) begin
    //     wb_regd_addr <= wb_regd_addr;
    //     wb_regd_en <= wb_regd_en;
    //     wb_data <= wb_data;
    // end
    else begin
        wb_regd_addr <= mem_regd_addr;
        wb_regd_en <= mem_regd_en;
        wb_data <= mem_data;
    end
end

endmodule
