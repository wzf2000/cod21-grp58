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
    input wire satp_we,
    input wire privilege_we,
    input wire mtval_we,
    input wire mideleg_we,
    input wire medeleg_we,
    input wire sepc_we,
    input wire scause_we,
    input wire stval_we,
    input wire stvec_we,
    input wire sscratch_we,

    input wire [31:0] mtvec_wdata,
    input wire [31:0] mscratch_wdata,
    input wire [31:0] mepc_wdata,
    input wire [31:0] mcause_wdata,
    input wire [31:0] mstatus_wdata,
    input wire [31:0] mie_wdata,
    input wire [31:0] mip_wdata,
    input wire [31:0] satp_wdata,
    input wire [1:0] privilege_wdata,
    input wire [31:0] mtval_wdata,
    input wire [31:0] mideleg_wdata,
    input wire [31:0] medeleg_wdata,
    input wire [31:0] sepc_wdata,
    input wire [31:0] scause_wdata,
    input wire [31:0] stval_wdata,
    input wire [31:0] stvec_wdata,
    input wire [31:0] sscratch_wdata,

    output reg[31:0] mtvec_o, //base = mtvec[31:2]; mode = mtvec[1:0]
    output reg[31:0] mscratch_o,
    output reg[31:0] mepc_o,
    output reg[31:0] mcause_o, //is_interrupt=mcause[31], code=mcause[30:0]
    output reg[31:0] mstatus_o, //need to implement mpp [12:11]
    output reg[31:0] mie_o, //need to implement MTIE [7]
    output reg[31:0] mip_o, //need to implement MTIP [7]
    output reg[31:0] satp_o,
    output reg[1:0] privilege_o,
    output reg[31:0] mtval_o,
    output reg[31:0] mideleg_o,
    output reg[31:0] medeleg_o,
    output reg[31:0] sepc_o,
    output reg[31:0] scause_o,
    output reg[31:0] stval_o,
    output reg[31:0] stvec_o,
    output reg[31:0] sscratch_o
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
reg[31:0] satp;
reg[31:0] mtval;
reg[31:0] mideleg;
reg[31:0] medeleg;
reg[31:0] sepc;
reg[31:0] scause;
reg[31:0] stval;
reg[31:0] stvec;
reg[31:0] sscratch;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mtvec <= 32'b0;
        mscratch <= 32'b0;
        mepc <= 32'b0;
        mcause <= 32'b0;
        mstatus <= 32'b0;
        mie <= 32'b0;
        mip <= 32'b0;
        satp <= 32'b0;
        privilege <= 2'b11;
        mtval <= 32'b0;
        mideleg <= 32'b0;
        medeleg <= 32'b0;
        sepc <= 32'b0;
        scause <= 32'b0;
        stval <= 32'b0;
        stvec <= 32'b0;
        sscratch <= 32'b0;
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
        if(satp_we) satp <= satp_wdata;
        else satp <= satp;
        if(privilege_we) privilege <= privilege_wdata;
        else privilege <= privilege;
        // if(mtval_we) mtval <= mtval_wdata;
        // else mtval <= mtval;
        if(mideleg_we) mideleg <= mideleg_wdata;
        else mideleg <= mideleg;
        if(medeleg_we) medeleg <= medeleg_wdata;
        else medeleg <= medeleg;
        if(sepc_we) sepc <= sepc_wdata;
        else sepc <= sepc;
        if(scause_we) scause <= scause_wdata;
        else scause <= scause;
        // if(stval_we) stval <= stval_wdata;
        // else stval <= stval;
        if(stvec_we) stvec <= stvec_wdata;
        else stvec <= stvec;
        if(sscratch_we) sscratch <= sscratch_wdata;
        else sscratch <= sscratch;
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
    if(satp_we) satp_o = satp_wdata;
    else satp_o = satp;
    if(privilege_we) privilege_o = privilege_wdata;
    else privilege_o = privilege;
    if(mtval_we) mtval_o = mtval_wdata;
    else mtval_o = mtval;
    if(mideleg_we) mideleg_o = mideleg_wdata;
    else mideleg_o = mideleg;
    if(medeleg_we) medeleg_o = medeleg_wdata;
    else medeleg_o = medeleg;
    if(sepc_we) sepc_o = sepc_wdata;
    else sepc_o = sepc;
    if(scause_we) scause_o = scause_wdata;
    else scause_o = scause;
    if(stval_we) stval_o = stval_wdata;
    else stval_o = stval;
    if(stvec_we) stvec_o = stvec_wdata;
    else stvec_o = stvec;
    if(sscratch_we) sscratch_o = sscratch_wdata;
    else sscratch_o = sscratch;
end

endmodule
