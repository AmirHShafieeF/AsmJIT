section .text
    global codegen

; JIT-compiles a simple arithmetic expression into machine code.
; Input:
;   rdi: pointer to the executable memory buffer
;   rsi: the first number
;   rdx: the second number
; Output:
;   rax: the length of the generated machine code in bytes
codegen:
    push rbp
    mov rbp, rsp

    ; mov rax, <num1>
    ; Encoding: B8 + imm32
    mov byte [rdi], 0xb8
    mov [rdi+1], esi
    add rdi, 5

    ; add rax, <num2>
    ; Encoding: 05 + imm32
    mov byte [rdi], 0x05
    mov [rdi+1], edx
    add rdi, 5

    ; ret
    mov byte [rdi], 0xc3

    mov rax, 11
    mov rsp, rbp
    pop rbp
    ret
