%include "../macos_syscalls.inc"
%include "../library.inc"
global _main

%define MAX_HEAP_LEN 500

section .text
_main:
    CALLPROC sort, numbers, numbers.len
    CALLPROC parse_numbers, numbers, numbers.len, outstr
    CALLPROC string_len, outstr, outlen
    CALLPROC to_ascii, outstr, outlen

    PRINTF outstr, [outlen]
    PRINTF newline, 1
    SYSEXIT 0


; [ebp+8] is pointer to numbers array
; [ebp+12] is length of nubmers array
sort:
    STACK_SAVE

    mov esi, [ebp+8]
    mov ecx, [ebp+12]
    dec ecx
    shl ecx, 7 ; set len of array in CH
               ; shl 7 (not 8) because hidden division (dw -> db)
    mov  cl, 0 ; loop counter
.lp_compare:
    cmp cl, ch
    jnl .loop

    xor eax, eax
    mov al, cl     ; mov eax, cl
    mov eax, [esi+eax*2]
    mov edi, eax   ; get n
    shr edi, 16    ; get n + 1

    cmp ax, di ; if n > n+1
    jg  .change_order
    inc cl     ; else
    jmp .lp_compare

.change_order:
    ; change order of numbers
    shl eax, 16
    add edi, eax

    ; save results
    xor eax, eax
    mov al, cl    ; mov eax, cl
    mov [esi+eax*2], edi

    inc cl
    jmp .lp_compare

.loop:
    cmp ch, 0  ; if counter = 0
    jz  .exit
    xor cl, cl
    dec ch
    jmp .lp_compare

.exit:
    STACK_LOAD
    ret


; [ebp+8]  is pointer to numbers array
; [ebp+12] is pointer to numbers length
; update numbers to ascii string
; so far only if num < 10
to_ascii:
    STACK_SAVE

    mov esi, [ebp+8]
    mov ebx, [ebp+12]
    xor ecx, ecx
.loop:    
    mov eax, [esi+ecx]

    ; WARNING: if eax > 2^16 - 48 i can change next number
    add eax, 48         ; to ascii
    mov [esi+ecx], eax  ; save 

    add ecx, 2          ; upd counter
    cmp ecx, [ebx]      ; is not end?
    jl .loop

.exit:
    mov [esi+ecx], word 0 ; add end of string
    STACK_LOAD
    ret


; [ebp+8]  is pointer to soure numbers
; [ebp+12] is pointer to soure length
; [ebp+16] is pointer to destination numbers
; parse numbers and save it as tens rank 
; TODO: I'm not sure that my above translate is right
parse_numbers:
    STACK_SAVE

    mov esi, [ebp+8]
    mov edi, [ebp+16]
    xor ecx, ecx ; counter
    xor ebx, ebx ; buffer counter
.lp:
    mov eax, [esi+ecx]
    shl eax, 16 ; clear Extended part of AX
    shr eax, 16 ; i'm worry that it's wrong pattern

    cmp eax, 10 ; if n < 10
    jl  .save

.while: ; while n > 10
    cmp eax, 10 ; if n < 10
    jl  .free_buffer

    xor edx, edx
    div dword [divisor] ; eax / 10

    mov [buffer+ebx], edx ; save quotient

    add ebx, 2
    jmp .while

.free_buffer:
    mov [buffer+ebx], eax ; save quotient

.free_buffer_lp:
    mov  eax, [buffer+ebx]
    mov [edi], eax ; save reversed buffer
    add edi, 2

    cmp ebx, 0
    je  .check_end

    sub ebx, 2
    jmp .free_buffer_lp

.save:
    mov [edi], eax
    add edi, 2

.check_end:
    add ecx, 2
    cmp ecx, [ebp+12]
    jl  .lp
    
.exit:
    mov [edi], word 0
    STACK_LOAD
    ret

; [ebp+8]  pointer to string array
; [ebp+12] pointer to save string length
string_len:
    STACK_SAVE
    
    mov esi, [ebp+8]
    mov edi, [ebp+12]
    mov ebx, MAX_HEAP_LEN ; limit for infinity loop
    xor ecx, ecx
.counter:
    cmp [esi+ecx], word 0 ; if char is \0 byte 
    je  .exit

    add ecx, 2
    cmp ecx, ebx
    jle .counter

.exit:
    mov [edi], ecx ; save length

    STACK_LOAD
    ret 

section .bss
; TODO: to add auto memory allocation
outstr resw MAX_HEAP_LEN
outlen resd 1
buffer resw 10

section .data
newline db 10

numbers dw  512, 6, 5, 3, 13, 1, 8, 7, 31, 2, 4
.len    equ $-numbers

divisor dd 10