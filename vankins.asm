;Vankins Mile Program  calculates the best possible moves to get the most points
;Author: Sam ONeal
;Date: 10/17/2017

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE io.h            ;header file for input/output
INCLUDE debug.h         ;header file for debugging program

cr      EQU     0dh     ;carriage return character
Lf      EQU     0ah     ;line feed

.STACK 4096

.DATA
    ;vankins mile
    vankin_mile_matrix      WORD    200     DUP(?)
    vankin_mile_height      WORD            ?
    vankin_mile_width       WORD            ?

    ;input
    input_height_prompt     BYTE    "Enter the height of the array: ", 0
    input_width_prompt      BYTE    "Enter the width of the array: ", 0
    input_element_prompt    BYTE    "Enter the element: ", 0

                            BYTE    cr, Lf, 0

;get input for the array specified
read_array_input    MACRO   array_name, width, height
    local done
    ;clear out ax,bx,and cx
    mov eax, 0
    mov ebx, 0
    mov ecx, 0

    ;the first two inputs will be the width and height
    inputW input_width_prompt, width
    inputW input_height_prompt, height

    ;multiply to figure out 1-D version of matrix
    mov ax, width
    mov bx, height
    mul bx ;width x height

    ;loop through width x height to collect array values
    mov cx, ax; counter
    lea ebx, array_name

    input_array:
        cmp cx, 0
        je done

        ;input each element
        inputW input_element_prompt, ax
        mov [ebx], ax
        add ebx, 2; mov index pointer

        dec cx
        jmp input_array
    done:

ENDM

;print out array given width and height
array_output    MACRO   array_name, width, height
    local done
    ;clear out ax,bx,cx
    mov eax, 0
    mov ebx, 0
    mov ecx, 0

    mov ax, width
    mov bx, height
    mul bx
    
    lea ebx, array_name
    mov cx, ax

    print_element:
        cmp cx, 0
        je done

        ;output element
        outputW WORD PTR [ebx]
        add ebx, 2

        dec cx
        jmp print_element
    done:

ENDM

.CODE
    _start:
        read_array_input vankin_mile_matrix, vankin_mile_width, vankin_mile_height

        array_output vankin_mile_matrix, vankin_mile_width, vankin_mile_height
        INVOKE ExitProcess, 0; exit with return code 0

    PUBLIC _start
END