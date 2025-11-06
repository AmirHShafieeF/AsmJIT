section .bss
    source_buffer resb 4096

section .text
    global _start
    extern parse
    extern codegen

; --- Define exit codes for debugging ---
EXIT_SUCCESS      equ 0
EXIT_BAD_ARGS     equ 1
EXIT_PARSE_ERROR  equ 2
EXIT_MMAP_ERROR   equ 3
EXIT_OPEN_ERROR   equ 4
EXIT_READ_ERROR   equ 5

_start:
    and rsp, -16

    ; Check argc
    mov rcx, [rsp]
    cmp rcx, 2
    jl .usage_error

    ; Open the file.
    mov rax, 2
    mov rdi, [rsp+16]
    mov rsi, 0
    mov rdx, 0
    syscall
    mov r15, rax
    cmp r15, 0
    jl .open_error

    ; Read from the file.
    mov rax, 0
    mov rdi, r15
    mov rsi, source_buffer
    mov rdx, 4096
    syscall
    mov r12, rax
    cmp r12, 0
    jl .read_error

    ; Null-terminate the buffer.
    mov byte [source_buffer+r12], 0

    ; Close the file.
    mov rax, 3
    mov rdi, r15
    syscall

    ; Allocate executable memory.
    mov rax, 9
    mov rdi, 0
    mov rsi, 4096
    mov rdx, 7
    mov r10, 0x22
    mov r8, -1
    mov r9, 0
    syscall
    mov r12, rax
    cmp r12, 0
    jl .mmap_error

    ; Parse the expression.
    mov rdi, source_buffer
    call parse
    cmp rax, -1
    je .parse_error
    mov r13, rax
    mov r14, rdx

    ; Generate code.
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14
    call codegen

    ; Execute the JIT'd code.
    call r12

    ; Exit with the result.
    mov rdi, rax
    mov rax, 60
    syscall

.usage_error:
    mov rdi, EXIT_BAD_ARGS
    jmp .exit_error
.parse_error:
    mov rdi, EXIT_PARSE_ERROR
    jmp .exit_error
.mmap_error:
    mov rdi, EXIT_MMAP_ERROR
    jmp .exit_error
.open_error:
    mov rdi, EXIT_OPEN_ERROR
    jmp .exit_error
.read_error:
    mov rdi, EXIT_READ_ERROR
    jmp .exit_error
.exit_error:
    mov rax, 60
    syscall
