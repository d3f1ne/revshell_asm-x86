# revshell_asm-x86


compile with:
nasm -felf32 shell.asm -o shell.o<br>
ld -m elf_i386 shell.o -o shell
