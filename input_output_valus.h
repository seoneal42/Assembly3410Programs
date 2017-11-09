.NOLIST
.386

TERMINATOR  EQU 71h
MAX_SIZE    EQU 40

cr          EQU 0dh
Lf          EQU 0ah
.DATA
    input_temp                      BYTE    10 DUP(' ')
    create_line_input_prompt        BYTE    "Enter up to 20 x and y values. Type q to exit.", 0
    read_user_x_input_prompt        BYTE    "Enter X to compute Y for: ", 0
    read_user_degree_input_prompt   BYTE    "Enter the degree: " , 0
    output_sorted_points_prompt     BYTE    "Sorted points:", 0
                                    BYTE    cr, LF, 0

INCLUDE io.h
INCLUDE debug.h
INCLUDE float.h
INCLUDE sort_points.h

create_line MACRO line_array_name, amount_of_points_entered
    ;clear registers
    mov eax, 0
    mov ebx, 0
    mov ecx, 0
    mov edx, 0

    ;mov max line size into cx
    mov cx, MAX_SIZE
    lea line_array_name

    output create_line_input_prompt
    loop:
        cmp cx, 0
        je done
        input input_temp, 8
        output input_temp
        output carriage

        cmp BYTE PTR input_temp, TERMINATOR
        je done

        ;move input_temp into ebx
        atof input_temp, eax
        mov [ebx], eax

        ;inc ebx by size of DWORD
        add ebx, 4
        ;decrement cx
        dec cx
        ;increment dx
        inc dx
        jmp loop
    done:
        ;take value of dx by 2
        ;this accounts for x and y values
        mov ax, dx
        cwd
        mov ebx, 2
        div bx
        mov amount_of_points_entered, ax
ENDM


read_user_x MACRO user_x
    ;clear register
    mov eax, 0
    ;ask user for desired x
    inputW read_user_x_input_prompt, input_temp
    output input_temp
    output carriage
    atof input_temp, eax
    mov user_x, eax
ENDM

read_user_degree MACRO  user_degree
    ;clear register
    mov eax, 0
    ;ask user for degree
    inputW read_user_degree_input_prompt, input_temp
    output input_temp
    output carriage
    atof input_temp, eax
    mov user_degree, eax
ENDM

sort_and_read_line_points   MACRO   line_array_name, user_x, num_of_points
    ;sort points
    sort_points line_array_name, user_x, num_of_points

    ;output points
    output output_sorted_points_prompt
    output carriage
    print_points line_array_name, num_of_points
ENDM