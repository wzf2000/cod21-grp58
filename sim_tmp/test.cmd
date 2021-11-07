@echo off
set PATH=%cd%\..\..\python37-32;%cd%\..\..\msys\1.0\bin;%cd%\..\..\toolchain\bin;%cd%\..\..\qemu\bin;%PATH%\..\..
riscv64-unknown-elf-c++ -nostdlib -nostdinc -static -g -Ttext 0x0 %1.s -o %1.elf -march=rv32i -mabi=ilp32
riscv64-unknown-elf-objcopy -O binary %1.elf %1.bin
riscv64-unknown-elf-objdump -d %1.elf > %1-objdump.s