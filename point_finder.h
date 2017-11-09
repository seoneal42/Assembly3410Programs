.NOLIST
.386

.DATA
    loc WORD ?

INCLUDE float.h

getXD MACRO array, index, stored_loc
    ;calculate position
    fld WORD PTR index
    fistp loc
    mov ax, loc
    mov cx, 8
    mul cx

    ;move location of array to new poistion
    mov ebx, array
    movzx ax
    add ebx, eax

    ;store x value into location requested
    mov stored_loc, DWORD PTR [ebx]

ENDM

getYD MACRO array, index, stored_loc
    ;compute position
    fld DWORD PTR index
    fistp loc
    mov ax, loc
    mov cx, 8
    mul cx
    mov cx, 4
    add ax, cx

    ;move pointer to array to new location
    mov ebx, array
    movzx ax
    add ebx, eax

    ;set value to user given location
    mov stored_loc, DWORD PTR [ebx]
ENDM

.NOLISTMACRO
.LIST