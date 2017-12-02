.386
.MODEL FLAT

PUBLIC read_passwords_proc

INCLUDE io.h
INCLUDE debug.h

cr          EQU 0dh
Lf          EQU 0ah

.DATA
    temp            BYTE    40 DUP(?)
    password_input  BYTE    "Enter a password: ", 0
                    BYTE    cr, LF, 0

.CODE
    ;parameters
    term            EQU [ebp + 12]
    password_array  EQU [ebp + 8]

    read_passwords_proc PROC    NEAR32
        push ebp
        mov ebp, esp
        pushf
        ;make sure the ebx register is pointing to the beginning of the array
        mov ebx, password_array

        ;move the max_num value into cl register
        mov cl, dl

        input_loop:
            cmp cl, 0
            je done

            output password_input
            input temp, dh
            output temp
            output cr
            
            dec cl
            jmp input_loop
        done:
        popf
        mov esp, ebp
        pop ebp
        ret 8
    read_passwords_proc ENDP
END