`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮�?关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮�?关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时�?1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信�?
    output wire uart_rdn,         //读串口信号，低有�?
    output wire uart_wrn,         //写串口信号，低有�?
    input wire uart_dataready,    //串口数据准备�?
    input wire uart_tbre,         //发�?�数据标�?
    input wire uart_tsre,         //数据发�?�完毕标�?

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共�?
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire base_ram_ce_n,       //BaseRAM片�?�，低有�?
    output wire base_ram_oe_n,       //BaseRAM读使能，低有�?
    output wire base_ram_we_n,       //BaseRAM写使能，低有�?

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire ext_ram_ce_n,       //ExtRAM片�?�，低有�?
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有�?
    output wire ext_ram_we_n,       //ExtRAM写使能，低有�?

    //直连串口信号
    output wire txd,  //直连串口发�?�端
    input  wire rxd,  //直连串口接收�?

    //Flash存储器信号，参�?? JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效�?16bit模式无意�?
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧�?
    output wire flash_ce_n,         //Flash片�?�信号，低有�?
    output wire flash_oe_n,         //Flash读使能信号，低有�?
    output wire flash_we_n,         //Flash写使能信号，低有�?
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash�?16位模式时请设�?1

    //USB 控制器信号，参�?? SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参�?? DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素�?3�?
    output wire[2:0] video_green,  //绿色像素�?3�?
    output wire[1:0] video_blue,   //蓝色像素�?2�?
    output wire video_hsync,       //行同步（水平同步）信�?
    output wire video_vsync,       //场同步（垂直同步）信�?
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐�?
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen(
    // Clock in ports
    .clk_in1(clk_50M),  // 外部时钟输入
    // Clock out ports
    .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设�?
    .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设�?
    // Status and control signals
    .reset(reset_btn), // PLL复位输入
    .locked(locked)    // PLL锁定指示输出�?"1"表示时钟稳定�?
                        // 后级电路复位信号应当由它生成（见下）
 );

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number�?16进制显示在数码管上面
wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管

/* =========== Demo code end =========== */

//! use 20M clock for pipelines, continue to finetune
wire clk_global;
assign clk_global = clk_20M;

reg reset_global;
always @(posedge clk_global or negedge locked) begin
    if (~locked)
        reset_global <= 1'b1;
    else
        reset_global <= 1'b0;
end

//Timer
wire mtime_we;
wire mtimecmp_we;
wire timer_upper;
wire [31:0] timer_wdata;
wire [63:0] mtime;
wire [63:0] mtimecmp;
wire interrupt;

mtimer timer_inst (
    .clk(clk_global),
    .rst(reset_global),
    .mtime_we(mtime_we),
    .mtimecmp_we(mtimecmp_we),
    .upper(timer_upper),
    .wdata(timer_wdata),
    .mtime(mtime),
    .mtimecmp(mtimecmp),
    .interrupt(interrupt)
);

//CSR File
//input
wire mtvec_we;
wire mscratch_we;
wire mepc_we;
wire mcause_we;
wire mstatus_we;
wire mie_we;
wire mip_we;
wire privilege_we;
//input
wire [31:0] mtvec_wdata;
wire [31:0] mscratch_wdata;
wire [31:0] mepc_wdata;
wire [31:0] mcause_wdata;
wire [31:0] mstatus_wdata;
wire [31:0] mie_wdata;
wire [31:0] mip_wdata;
wire [1:0] privilege_wdata;
//output
wire[31:0] mtvec_o;
wire[31:0] mscratch_o;
wire[31:0] mepc_o;
wire[31:0] mcause_o;
wire[31:0] mstatus_o;
wire[31:0] mie_o;
wire[31:0] mip_o;
wire[1:0] privilege_o;

csr csr_inst (
    .clk(clk_global),
    .rst(reset_global),
    .int_time(interrupt),

    .mtvec_we(mtvec_we),
    .mscratch_we(mscratch_we),
    .mepc_we(mepc_we),
    .mcause_we(mcause_we),
    .mstatus_we(mstatus_we),
    .mie_we(mie_we),
    .mip_we(mip_we),
    .privilege_we(privilege_we),
    //input
    .mtvec_wdata(mtvec_wdata),
    .mscratch_wdata(mscratch_wdata),
    .mepc_wdata(mepc_wdata),
    .mcause_wdata(mcause_wdata),
    .mstatus_wdata(mstatus_wdata),
    .mie_wdata(mie_wdata),
    .mip_wdata(mip_wdata),
    .privilege_wdata(privilege_wdata),
    //output
    .mtvec_o(mtvec_o),
    .mscratch_o(mscratch_o),
    .mepc_o(mepc_o),
    .mcause_o(mcause_o),
    .mstatus_o(mstatus_o),
    .mie_o(mie_o),
    .mip_o(mip_o),
    .privilege_o(privilege_o)
);

// used to stop pipelines
wire stallreq_id;
wire stallreq_ex;
wire stall;

ppl_ctrl ctrl(
    .rst(reset_global),
    .stallreq_id(stallreq_id),
    .stallreq_ex(stallreq_ex),
    .stall(stall)
);

// IF stage output
wire if_en_out;
wire[31:0] if_addr_out;
wire[31:0] if_data_out;
wire[31:0] if_pc_out;

// ID stage input
wire[31:0] id_pc_in;
wire[31:0] id_instr_in;
wire[31:0] id_regs1_in;
wire[31:0] id_regs2_in;

// ID stage output
wire id_branch_flag_out;
wire[31:0] id_branch_addr_out;
wire[4:0] id_regs1_addr_out;
wire[4:0] id_regs2_addr_out;
wire[31:0] id_regs1_out;
wire[31:0] id_regs2_out;
wire[4:0] id_regd_addr_out;
wire id_regd_en_out;
wire[31:0] id_pc_out;
wire[6:0] id_alu_opcode_out;
wire[2:0] id_alu_funct3_out;
wire[6:0] id_alu_funct7_out;
wire[11:0] id_alu_funct_csr_out;
wire id_mem_en_out;
wire[31:0] id_mem_addr_out;
wire[31:0] id_ret_addr_out;

wire[31:0] id_mtvec_data;
wire[31:0] id_mscratch_data;
wire[31:0] id_mepc_data;
wire[31:0] id_mcause_data;
wire[31:0] id_mstatus_data;
wire[31:0] id_mie_data;
wire[31:0] id_mip_data;
wire[1:0] id_priv_data;

wire id_mtvec_we;
wire id_mscratch_we;
wire id_mepc_we;
wire id_mcause_we;
wire id_mstatus_we;
wire id_mie_we;
wire id_mip_we;
wire id_priv_we;

wire[31:0] ex_mtvec_data;
wire[31:0] ex_mscratch_data;
wire[31:0] ex_mepc_data;
wire[31:0] ex_mcause_data;
wire[31:0] ex_mstatus_data;
wire[31:0] ex_mie_data;
wire[31:0] ex_mip_data;
wire[1:0] ex_priv_data;

wire ex_mtvec_we;
wire ex_mscratch_we;
wire ex_mepc_we;
wire ex_mcause_we;
wire ex_mstatus_we;
wire ex_mie_we;
wire ex_mip_we;
wire ex_priv_we;

// EXE stage input
wire[31:0] ex_pc_in;
wire[6:0] ex_alu_opcode_in;
wire[2:0] ex_alu_funct3_in;
wire[6:0] ex_alu_funct7_in;
wire[11:0] ex_alu_funct_csr_in;
wire[31:0] ex_regs1_in;
wire[31:0] ex_regs2_in;
wire[4:0] ex_regd_addr_in;
wire ex_regd_en_in;
wire[31:0] ex_ret_addr_in;
wire ex_mem_en_in;
wire[31:0] ex_mem_addr_in;

// EXE stage output
wire[6:0] ex_alu_opcode_out;
wire[2:0] ex_alu_funct3_out;
wire[6:0] ex_alu_funct7_out;
wire ex_regd_en_out;
wire[4:0] ex_regd_addr_out;
wire[31:0] ex_data_out;
wire ex_mem_en_out;
wire[31:0] ex_mem_addr_out;
wire[3:0] ex_mem_be_n_out;

// MEM stage input
wire mem_en_in;
wire[6:0] mem_alu_opcode_in;
wire[2:0] mem_alu_funct3_in;
wire mem_regd_en_in;
wire[4:0] mem_regd_addr_in;
wire[31:0] mem_data_in;
wire[31:0] mem_addr_in;
wire[3:0] mem_be_n_in;

// SRAM controller
wire[31:0] mem_read_data_in;
wire[31:0] mem_write_data_out;

// MEM stage output
wire[31:0] mem_addr_out;
wire[3:0] mem_be_n_out;
wire mem_ce_n_out;
wire mem_oe_n_out;
wire mem_we_n_out;
wire mem_regd_en_out;
wire[4:0] mem_regd_addr_out;
wire[31:0] mem_data_out;

// WB stage input
wire wb_regd_en_in;
wire[4:0] wb_regd_addr_in;
wire[31:0] wb_data_in;

assign leds[7:4] = {id_branch_flag_out, id_branch_addr_out[2:0]};

// memory controller for base ram, ext ram and cpld uart
SRAM sram(
    .rst(reset_global),

    .mtime(mtime),
    .mtimecmp(mtimecmp),
    .mtime_we(mtime_we),
    .mtimecmp_we(mtimecmp_we),
    .upper(timer_upper),
    .timer_wdata(timer_wdata),

    // CPLD
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),
    .uart_dataready(uart_dataready),
    .uart_tbre(uart_tbre),
    .uart_tsre(uart_tsre),

    // BaseRAM
    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_be_n(base_ram_be_n),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),

    // ExtRAM
    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_be_n(ext_ram_be_n),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n),

    // IF stage
    .if_en(if_en_out),
    .if_addr(if_addr_out),
    .if_data(if_data_out),

    // MEM stage
    .mem_en(mem_en_in),
    .mem_addr(mem_addr_out),
    .mem_data_in(mem_write_data_out),
    .mem_be_n(mem_be_n_out),
    .mem_ce_n(mem_ce_n_out),
    .mem_oe_n(mem_oe_n_out),
    .mem_we_n(mem_we_n_out),
    .mem_data_out(mem_read_data_in),

    .state(leds[15:8])
);

PC_reg pc_reg(
    .clk(clk_global),
    .rst(reset_global),
    .stall(stall),

    .branch_flag(id_branch_flag_out),
    .branch_addr(id_branch_addr_out),

    .pc_ram_addr(if_addr_out),
    .pc(if_pc_out),
    .pc_ram_en(if_en_out),
    .state(leds[3:0])
);

// IF/ID stage
ppl_if_id if_id(
    .clk(clk_global),
    .rst(reset_global),

    .if_pc(if_pc_out),

    .stall(stall),

    .ram_data(if_data_out),
    
    .branch_predict(id_branch_flag_out), // 1: jump, 0: not jump

    .id_pc(id_pc_in),
    .id_instr(id_instr_in)
);

// register file
Regfile regfile(
    .clk(clk_global),
    .rst(reset_global),
    .we(wb_regd_en_in),
    .waddr(wb_regd_addr_in),
    .wdata(wb_data_in),
    
    .raddr1(id_regs1_addr_out),
    .rdata1(id_regs1_in),
    .raddr2(id_regs2_addr_out),
    .rdata2(id_regs2_in)
);

// ID stage
ppl_id id(
    .rst(reset_global),
    .pc_in(id_pc_in),
    .instr(id_instr_in),

    .regs1_in(id_regs1_in),
    .regs2_in(id_regs2_in),

    .regs1_out(id_regs1_out),
    .regs2_out(id_regs2_out),

    // EXE stage
    .ex_alu_opcode_in(ex_alu_opcode_out),
    .ex_regd_en_in(ex_regd_en_out),
    .ex_regd_addr_in(ex_regd_addr_out),
    .ex_data_in(ex_data_out),

    // MEM stage
    .mem_regd_en_in(mem_regd_en_out),
    .mem_regd_addr_in(mem_regd_addr_out),
    .mem_data_in(mem_data_out),

    .regs1_addr(id_regs1_addr_out),
    .regs2_addr(id_regs2_addr_out),

    .regd_addr(id_regd_addr_out), // address of register d
    .reg_write(id_regd_en_out), // whether to write register

    .pc_out(id_pc_out),
    .alu_opcode(id_alu_opcode_out),
    .alu_funct3(id_alu_funct3_out),
    .alu_funct7(id_alu_funct7_out),
    .alu_funct_csr(id_alu_funct_csr_out),

    .mem_en(id_mem_en_out),
    .mem_addr(id_mem_addr_out),

    .ret_addr(id_ret_addr_out),
    .branch_flag_out(id_branch_flag_out),
    .branch_addr_out(id_branch_addr_out),

    .mtvec_data_in(mtvec_o),
    .mscratch_data_in(mscratch_o),
    .mepc_data_in(mepc_o),
    .mcause_data_in(mcause_o),
    .mstatus_data_in(mstatus_o),
    .mie_data_in(mie_o),
    .mip_data_in(mip_o),
    .privilege_data_in(privilege_o),

    .mtvec_we(id_mtvec_we),
    .mscratch_we(id_mscratch_we),
    .mepc_we(id_mepc_we),
    .mcause_we(id_mcause_we),
    .mstatus_we(id_mstatus_we),
    .mie_we(id_mie_we),
    .mip_we(id_mip_we),
    .privilege_we(id_priv_we),

    .mtvec_data_out(id_mtvec_data),
    .mscratch_data_out(id_mscratch_data),
    .mepc_data_out(id_mepc_data),
    .mcause_data_out(id_mcause_data),
    .mstatus_data_out(id_mstatus_data),
    .mie_data_out(id_mie_data),
    .mip_data_out(id_mip_data),
    .privilege_data_out(id_priv_data),

    .stallreq(stallreq_id)
);

// ID/EXE stage
ppl_id_ex id_ex(
    .clk(clk_global),
    .rst(reset_global),

    .stall(stall),

    .id_pc(id_pc_out),
    .id_alu_opcode(id_alu_opcode_out),
    .id_alu_funct3(id_alu_funct3_out),
    .id_alu_funct7(id_alu_funct7_out),
    .id_alu_funct_csr(id_alu_funct_csr_out),
    .id_regs1(id_regs1_out),
    .id_regs2(id_regs2_out),
    .id_regd_addr(id_regd_addr_out),
    .id_regd_en(id_regd_en_out),
    .id_ret_addr(id_ret_addr_out),
    .id_mem_en(id_mem_en_out),
    .id_mem_addr(id_mem_addr_out),

    .ex_pc(ex_pc_in),
    .ex_alu_opcode(ex_alu_opcode_in),
    .ex_alu_funct3(ex_alu_funct3_in),
    .ex_alu_funct7(ex_alu_funct7_in),
    .ex_alu_funct_csr(ex_alu_funct_csr_in),
    .ex_regs1(ex_regs1_in),
    .ex_regs2(ex_regs2_in),
    .ex_regd_addr(ex_regd_addr_in),
    .ex_regd_en(ex_regd_en_in),
    .ex_ret_addr(ex_ret_addr_in),
    .ex_mem_en(ex_mem_en_in),
    .ex_mem_addr(ex_mem_addr_in),

    .id_mtvec_we(id_mtvec_we),
    .id_mscratch_we(id_mscratch_we),
    .id_mepc_we(id_mepc_we),
    .id_mcause_we(id_mcause_we),
    .id_mstatus_we(id_mstatus_we),
    .id_mie_we(id_mie_we),
    .id_mip_we(id_mip_we),
    .id_priv_we(id_priv_we),

    .ex_mtvec_we(ex_mtvec_we),
    .ex_mscratch_we(ex_mscratch_we),
    .ex_mepc_we(ex_mepc_we),
    .ex_mcause_we(ex_mcause_we),
    .ex_mstatus_we(ex_mstatus_we),
    .ex_mie_we(ex_mie_we),
    .ex_mip_we(ex_mip_we),
    .ex_priv_we(ex_priv_we),

    .id_mtvec_data(id_mtvec_data),
    .id_mscratch_data(id_mscratch_data),
    .id_mepc_data(id_mepc_data),
    .id_mcause_data(id_mcause_data),
    .id_mstatus_data(id_mstatus_data),
    .id_mie_data(id_mie_data),
    .id_mip_data(id_mip_data),
    .id_priv_data(id_priv_data),

    .ex_mtvec_data(ex_mtvec_data),
    .ex_mscratch_data(ex_mscratch_data),
    .ex_mepc_data(ex_mepc_data),
    .ex_mcause_data(ex_mcause_data),
    .ex_mstatus_data(ex_mstatus_data),
    .ex_mie_data(ex_mie_data),
    .ex_mip_data(ex_mip_data),
    .ex_priv_data(ex_priv_data)
);

// EXE stage
ppl_ex ex(
    .rst(reset_global),

    .pc_in(ex_pc_in),

    .alu_opcode_in(ex_alu_opcode_in),
    .alu_funct3_in(ex_alu_funct3_in),
    .alu_funct7_in(ex_alu_funct7_in),
    .alu_funct_csr_in(ex_alu_funct_csr_in),
    .regs1_in(ex_regs1_in),
    .regs2_in(ex_regs2_in),
    .regd_in(ex_regd_addr_in),
    .regd_en_in(ex_regd_en_in),
    .mem_en_in(ex_mem_en_in),
    .mem_addr_in(ex_mem_addr_in),
    .ret_addr_in(ex_ret_addr_in),
    
    .mtvec_in(ex_mtvec_data),
    .mscratch_in(ex_mscratch_data),
    .mepc_in(ex_mepc_data),
    .mcause_in(ex_mcause_data),
    .mstatus_in(ex_mstatus_data),
    .mie_in(ex_mie_data),
    .mip_in(ex_mip_data),
    .priv_in(ex_priv_data),

    .mtvec_out(mtvec_wdata),
    .mscratch_out(mscratch_wdata),
    .mepc_out(mepc_wdata),
    .mcause_out(mcause_wdata),
    .mstatus_out(mstatus_wdata),
    .mie_out(mie_wdata),
    .mip_out(mip_wdata),
    .priv_out(privilege_wdata),

    .mtvec_we_in(ex_mtvec_we),
    .mscratch_we_in(ex_mscratch_we),
    .mepc_we_in(ex_mepc_we),
    .mcause_we_in(ex_mcause_we),
    .mstatus_we_in(ex_mstatus_we),
    .mie_we_in(ex_mie_we),
    .mip_we_in(ex_mip_we),
    .priv_we_in(ex_priv_we),

    .mtvec_we_out(mtvec_we),
    .mscratch_we_out(mscratch_we),
    .mepc_we_out(mepc_we),
    .mcause_we_out(mcause_we),
    .mstatus_we_out(mstatus_we),
    .mie_we_out(mie_we),
    .mip_we_out(mip_we),
    .priv_we_out(privilege_we),

    .alu_opcode_out(ex_alu_opcode_out),
    .alu_funct3_out(ex_alu_funct3_out),
    .regd_out(ex_regd_addr_out),
    .regd_en_out(ex_regd_en_out),
    .mem_en_out(ex_mem_en_out),
    .mem_addr_out(ex_mem_addr_out),
    .mem_be_n_out(ex_mem_be_n_out),

    .data_out(ex_data_out),
    .stall_req(stallreq_ex)
);

// EXE/MEM stage
ppl_ex_mem ex_mem(
    .clk(clk_global),
    .rst(reset_global),
    .stall(stall),

    .ex_alu_opcode(ex_alu_opcode_out),
    .ex_alu_funct3(ex_alu_funct3_out),
    .ex_regd_en(ex_regd_en_out),
    .ex_regd_addr(ex_regd_addr_out),
    .ex_data(ex_data_out),
    .ex_mem_addr(ex_mem_addr_out),
    .ex_mem_en(ex_mem_en_out),
    .ex_mem_be_n(ex_mem_be_n_out),

    .mem_alu_opcode(mem_alu_opcode_in),
    .mem_alu_funct3(mem_alu_funct3_in),
    .mem_regd_en(mem_regd_en_in),
    .mem_regd_addr(mem_regd_addr_in),
    .mem_data(mem_data_in),
    .mem_addr(mem_addr_in),
    .mem_en(mem_en_in),
    .mem_be_n(mem_be_n_in)
);

// MEM stage
ppl_mem mem(
    .rst(reset_global),

    .alu_opcode_in(mem_alu_opcode_in),
    .alu_funct3_in(mem_alu_funct3_in),

    .regd_addr_in(mem_regd_addr_in),
    .regd_en_in(mem_regd_en_in),
    .data_in(mem_data_in),
    .mem_en_in(mem_en_in),
    .mem_addr_in(mem_addr_in),
    .mem_be_n_in(mem_be_n_in),

    .write_data(mem_write_data_out),
    .read_data(mem_read_data_in),

    .ram_addr(mem_addr_out),
    .ram_be_n(mem_be_n_out),
    .ram_ce_n(mem_ce_n_out),
    .ram_oe_n(mem_oe_n_out),
    .ram_we_n(mem_we_n_out),

    .regd_addr_out(mem_regd_addr_out),
    .regd_en_out(mem_regd_en_out),
    .data_out(mem_data_out)
);

// MEM/WB stage
ppl_mem_wb mem_wb(
    .clk(clk_global),
    .rst(reset_global),
    .stall(stall),

    .mem_regd_addr(mem_regd_addr_out),
    .mem_regd_en(mem_regd_en_out),
    .mem_data(mem_data_out),

    .wb_regd_addr(wb_regd_addr_in),
    .wb_regd_en(wb_regd_en_in),
    .wb_data(wb_data_in)
);

endmodule
