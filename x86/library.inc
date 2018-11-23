%macro STACK_SAVE 0
    push ebp
    mov ebp, esp
    sub esp, 4
%endmacro

%macro STACK_LOAD 0
    mov esp, ebp
    pop ebp
%endmacro
