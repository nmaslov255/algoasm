%macro STACK_SAVE 0
    push ebp
    mov ebp, esp
    sub esp, 4
%endmacro

%macro STACK_LOAD 0
    mov esp, ebp
    pop ebp
%endmacro

%macro CALLPROC 1-*
    %assign count_arg %0 - 1
    %xdefine procedure %1

    %rep count_arg
        %rotate -1
        push %1
    %endrep

    call procedure
%endmacro