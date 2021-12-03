`define OP_R 7'b0110011

`define FUNCT3_ADD 3'b000

`define FUNCT3_XOR 3'b100
`define FUNCT7_XOR 7'b0000000
`define FUNCT7_PACK 7'b0000100
`define FUNCT7_XNOR 7'b0100000

`define FUNCT3_OR 3'b110
`define FUNCT7_OR 7'b0000000
`define FUNCT7_MINU 7'b0000101

`define FUNCT3_AND 3'b111 


`define OP_R2 7'b1110111


`define OP_I 7'b0010011

`define FUNCT3_ADDI 3'b000

`define FUNCT3_ANDI 3'b111

`define FUNCT3_ORI 3'b110

`define FUNCT3_SLLI 3'b001

`define FUNCT3_SRLI 3'b101


`define OP_S 7'b0100011

`define FUNCT3_SW 3'b010

`define FUNCT3_SB 3'b000


`define OP_L 7'b0000011

`define FUNCT3_LW 3'b010

`define FUNCT3_LB 3'b000


`define OP_B 7'b1100011

`define FUNCT3_BEQ 3'b000

`define FUNCT3_BNE 3'b001


`define OP_AUIPC 7'b0010111


`define OP_LUI 7'b0110111


`define OP_JAL 7'b1101111


`define OP_JALR 7'b1100111


`define OP_CSR 7'b1110011


`define OP_NOP 7'b0000000
`define FUNCT3_NOP 3'b000
`define FUNCT7_NOP 7'b0000000