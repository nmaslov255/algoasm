%include "../macos_syscalls.inc"
%include "../library.inc"
global _main

section .text
_main:
    CALLPROC sort, numbers, numbers.len
    CALLPROC to_ascii, numbers, numbers.len, outstr

    CALLPROC string_len, outstr, outlen
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
; [ebp+12] is length of nubmers array
; [ebp+16] is pointer to ascii array
; update numbers to ascii string
; so far only if num < 10
to_ascii:
    STACK_SAVE

    mov esi, [ebp+8]
    mov edi, [ebp+16]
    xor ecx, ecx
.loop:    
    mov eax, [esi+ecx]

    add eax, 48        ; to ascii
    mov [edi+ecx], eax ; save 

    add ecx, 2
    cmp ecx, [ebp+12]
    jl .loop

    mov [edi+ecx], byte 0 ; add end of string
    STACK_LOAD
    ret

; [ebp+8]  pointer to string array
; [ebp+12] pointer to save string length
string_len:
    STACK_SAVE
    
    mov esi, [ebp+8]
    mov edi, [ebp+12]
    mov ebx, 100 ; limit for infinity loop
    xor ecx, ecx
.counter:
    cmp [esi+ecx], byte 0 ; if char is \0 byte
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
outstr resb 1000
outlen resb 1

section .data
newline db 10 

; TODO: check length of numbers in array
numbers dw  6, 5, 3, 13, 1, 8, 7, 2, 4
.len    equ $-numbers
