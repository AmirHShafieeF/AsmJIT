section .text
    global parse

; Simple lexer/parser for arithmetic expressions of the form "number + number".
; Input:
;   rdi: pointer to the null-terminated expression string
; Output:
;   rax: the first number
;   rdx: the second number
parse:
    ; state for our simple state machine parser
    %define PARSE_NUM1 0
    %define PARSE_OP   1
    %define PARSE_NUM2 2
    %define PARSE_DONE 3

    push rbx
    push r12
    push r13

    xor r12, r12        ; store num1
    xor r13, r13        ; store num2
    mov r8, PARSE_NUM1  ; initial state
    xor rcx, rcx        ; string index

.loop:
    call skip_whitespace
    movzx r10, byte [rdi + rcx]
    inc rcx
    cmp r10, 0
    je .done

    cmp r8, PARSE_NUM1
    je .state_num1

    cmp r8, PARSE_OP
    je .state_op

    cmp r8, PARSE_NUM2
    je .state_num2

.state_num1:
    cmp r10, '0'
    jl .op_check1
    cmp r10, '9'
    jg .op_check1

    ; It's a digit
    sub r10, '0'
    imul r12, r12, 10
    add r12, r10
    jmp .loop

.op_check1:
    mov r8, PARSE_OP ; next state
    ; fallthrough to state_op with the current char

.state_op:
    cmp r10, '+'
    jne .error ; only support + for now
    mov r8, PARSE_NUM2
    jmp .loop

.state_num2:
    cmp r10, '0'
    jl .error
    cmp r10, '9'
    jg .error

    sub r10, '0'
    imul r13, r13, 10
    add r13, r10
    jmp .loop


.done:
    mov rax, r12
    mov rdx, r13
    jmp .exit

.error:
    ; on error, return -1 in both
    mov rax, -1
    mov rdx, -1

.exit:
    pop r13
    pop r12
    pop rbx
    ret

skip_whitespace:
    .loop:
        movzx r11, byte [rdi + rcx]
        cmp r11, ' '
        je .next
        cmp r11, '\t'
        je .next
        cmp r11, 0ah
        je .next
        cmp r11, 0dh
        je .next
        ret
    .next:
        inc rcx
        jmp .loop
