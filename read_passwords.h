.NOLIST
.386

EXTERN read_passwords_proc: NEAR32

read_passwords  MACRO   password_array_name, max_num, max_length, term

    ;going to use ebx register for password array
    push ebx
    ;going to use eax for reading passwords from user
    push eax
    mov eax, 0
    ;going to use ecx for counter
    push ecx
    ;going to use edx for max length and max num
    push edx
    mov edx, 0
        ;store the array name into ebx
        lea ebx, password_array_name
        push ebx
        ;store the term on stack
        push term
        ;store max_num in dl register
        dl, BYTE PTR max_num
        ;store max_length in dh register
        dh, BYTE PTR max_length
        ;call procedure
        call read_passwords_proc
    ;clear stack
    pop eax
    pop ebx
    pop ecx
    pop edx
ENDM

.NOLISTMACRO
.LIST