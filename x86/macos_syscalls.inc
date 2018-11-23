%macro PRINTF 2
    ; syscalls params must have 4 bytes
    push dword %2
    push dword %1
    push dword 1  ; standard streams
    mov  eax, 4   ; syscall @write
    sub  esp, 4   ; why?
    int  0x80
    add  esp, 16  ; return to start of stack
    ; about error reporting CF (0 - success, 1 - error)
    ; in EAX will be code of error
%endmacro

%macro SYSEXIT 1
    push dword %1 ; result code: 1 - success
    mov  eax, 1   ; call _exit
    sub  esp, 12  ; why 12? I think to need 4 becouse one dword
    int  0x80
%endmacro