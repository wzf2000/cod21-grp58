`default_nettype none
`timescale 1ns / 1ps

module csr(
    input wire clk,
    input wire rst,
    input wire int_time,

    input wire mtvec_we,
    input wire mscratch_we,
    input wire mepc_we,
    input wire mcause_we,
    input wire mstatus_we,
    input wire mie_we,
    input wire mip_we,
    input wire privilege_we,

    input wire [31:0] mtvec_wdata,
    input wire [31:0] mscratch_wdata,
    input wire [31:0] mepc_wdata,
    input wire [31:0] mcause_wdata,
    input wire [31:0] mstatus_wdata,
    input wire [31:0] mie_wdata,
    input wire [31:0] mip_wdata,
    input wire [1:0] privilege_wdata,

    output reg[31:0] mtvec_o, //base = mtvec[31:2]; mode = mtvec[1:0]
    output reg[31:0] mscratch_o,
    output reg[31:0] mepc_o,
    output reg[31:0] mcause_o, //is_interrupt=mcause[31], code=mcause[30:0]
    output reg[31:0] mstatus_o, //need to implement mpp [12:11]
    output reg[31:0] mie_o, //need to implement MTIE [7]
    output reg[31:0] mip_o, //need to implement MTIP [7]
    output reg[1:0] privilege_o
);
//all of the following are rw
reg[31:0] mtvec; //base = mtvec[31:2]; mode = mtvec[1:0]
reg[31:0] mscratch;
reg[31:0] mepc;
reg[31:0] mcause; //is_interrupt=mcause[31], code=mcause[30:0]
reg[31:0] mstatus; //need to implement mpp [12:11]
reg[31:0] mie; //need to implement MTIE [7]
reg[31:0] mip; //need to implement MTIP [7]
reg[1:0] privilege;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mtvec <= 32'b0;
        mscratch <= 32'b0;
        mepc <= 32'b0;
        mcause <= 32'b0;
        mstatus <= 32'b0;
        mie <= 32'b0;
        mip <= 32'b0;
        privilege <= 2'b11;
    end
    else begin
        if(mtvec_we) mtvec <= mtvec_wdata;
        else mtvec <= mtvec;
        if(mscratch_we) mscratch <= mscratch_wdata;
        else mscratch <= mscratch;
        if(mepc_we) mepc <= mepc_wdata;
        else mepc <= mepc;
        if(mcause_we) mcause <= mcause_wdata;
        else mcause <= mcause;
        if(mstatus_we) mstatus <= mstatus_wdata;
        else mstatus <= mstatus;
        if(mie_we) mie <= mie_wdata;
        else mie <= mie;
        if(mip_we) mip <= mip_wdata;
        else mip <= {24'b0,int_time,7'b0};
        if(privilege_we) privilege <= privilege_wdata;
        else privilege <= privilege;
    end
end

always @(*) begin
    if(mtvec_we) mtvec_o = mtvec_wdata;
    else mtvec_o = mtvec;
    if(mscratch_we) mscratch_o = mscratch_wdata;
    else mscratch_o = mscratch;
    if(mepc_we) mepc_o = mepc_wdata;
    else mepc_o = mepc;
    if(mcause_we) mcause_o = mcause_wdata;
    else mcause_o = mcause;
    if(mstatus_we) mstatus_o = mstatus_wdata;
    else mstatus_o = mstatus;
    if(mie_we) mie_o = mie_wdata;
    else mie_o = mie;
    if(mip_we) mip_o = mip_wdata;
    else mip_o = mip;
    if(privilege_we) privilege_o = privilege_wdata;
    else privilege_o = privilege;
end

endmodule
