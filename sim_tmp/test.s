    .org 0x0
    .global _start
    .text
_start:
    ori t0, zero, 0x100
    slli t0, t0, 20
    ori t1, zero, 100
    sw t1, 0(t0)
end:
    beq zero, zero, end
