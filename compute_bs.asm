.386
.MODEL FLAT

PUBLIC compute_b_proc

.DATA
    zero        REAL4   0.0
    tolerance   REAL4   0.001
    right_temp  DWORD   ?
    left_temp   DWORD   ?
    temp_x_n    DWORD   ?
    temp_x_m    DWORD   ?
    numerator   DWORD   ?
    denominator DWORD   ?
    b_temp      DWORD   ?


INCLUDE compare_float.h
INCLUDE point_finder.h

.CODE
    ;parameters
    degree  EQU [ebp+12]
    points  EQU [ebp+8]

    compute_b_proc  PROC    NEAR32
        ;ready the stack
        push ebp        ;old ebp
        mov ebp, esp
        push eax        ;the value of computed a will be stored here
        pushfd

        ;push on the variables to prepare recursion
        push points
        push degree
        push zero

        ;start recursion
        compute_b_rec

        ;reset stack
        popfd
        pop eax
        mov esp, ebp
        pop ebp
        ret 8
    compute_b_proc  ENDP

    ;parameters
    m           EQU [ebp+16]
    n           EQU [ebp+12]
    line_array  EQU [ebp+8]
    ;local variables
    localM      EQU [ebp-4]
    localN      EQU [ebp-8]

    compute_b_rec   PROC    NEAR32
        ;prepare the stack
        push ebp
        mov ebp, esp
        pushd 0
        pushd 0

        ;check if n = m
        compare_floats n, m, tolerance
        cmp ax, 0
        je base_case ;if n = m then we are at the base case

        ;not equal so need to move until at the base case
        
        ;decrement N first
        fld DWORD PTR n
        fld1    ;need to push 1 onto the stack for decrementing n
        fsub    ;automatically takes 1st and 2nd positions on the stack, places the answer ontop of the stack will removing other two values
        ;store value in localN
        fstp DWORD PTR localN

        ;incremenet M
        fld DWORD PTR m
        fld1
        fadd
        fstp DWORD PTR localM

        ;the formula follows:
        ;f[Xn ... Xm+1] - [Xn-1 ... Xm]
        ;so now must recursively go back through n and m until base case is met
        ;start with f[Xn ... Xm+1]
        ;will use parameter n and local variable localM
        push line_array
        push n
        push localM
        call compute_b_rec
        ;grab value from eax and store into left_temp
        mov left_temp, eax
        ;store onto floating point stack
        fld DWORD PTR left_temp

        ;compute f[Xn ... Xm+1]
        ;will use local variable localN and parameter m
        push line_array
        push localM
        push m
        call compute_b_rec
        mov right_temp, eax
        fld DWORD PTR right_temp

        ;subtract the two sides
        fsub
        ;take the result and store into numerator
        fst DWORD PTR numerator

        ;compute the denominator which is Xn-Xm
        ;will need to grab X values from line array
        getXD line_array, n, ecx
        mov temp_x_n, ecx
        fld DWORD PTR temp_x_n

        getX line_array, m, ecx
        mov temp_x_m, ecx
        fld DWORD PTR temp_x_m

        ;subtract the two
        fsub
        fst DWORD PTR denominator

        ;divide the two numbers
        fdiv

        ;hold in b_temp variable
        fstp DWORD PTR b_temp

        ;store all temproary and final b's into eax register
        mov eax, b_temp

        jmp done
    base_case:
        ;we are now at the base case
        ;all we need to do is grab the y value
        getYD line_array, n, eax
    done:
        mov esp, ebp
        pop ebp
        ret 8
compute_b_rec   ENDP
END