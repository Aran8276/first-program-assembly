@echo off
nasm -f win32 program.asm -o program.obj  
gcc -o program.exe program.obj -lkernel32
program.exe