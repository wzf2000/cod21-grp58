`default_nettype none
`timescale 1ns / 1ps

module mtimer
(
    input wire clk,
    input wire rst,
    input wire mtime_we,
    input wire mtimecmp_we,
    input wire upper,
    input wire [31:0] wdata,
    output reg [63:0] mtime,
    output reg [63:0] mtimecmp,
    output reg interrupt
);

always @(*) begin
    if(mtime > mtimecmp) interrupt = 1'b1;
    else interrupt = 1'b0;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mtime <= 63'b0;
        mtimecmp <= {1'b1,63'b0};
    end
    else begin
        if(mtime_we) begin
            if(upper) mtime <= {wdata,mtime[31:0]};
            else mtime <= {mtime[63:32],wdata};
        end
        else mtime <= mtime + 1;
        if(mtimecmp_we) begin
            if(upper) mtimecmp <= {wdata,mtimecmp[31:0]};
            else mtimecmp <= {mtimecmp[63:32],wdata};
        end
        else mtimecmp <= mtimecmp;
    end
end

endmodule