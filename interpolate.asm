.386
.MODEL FLAT

PUBLIC interpolate_proc

;grab access to compute_b_proc

EXTERN compute_b_proc: NEAR32

.DATA
    ;user global variables
    zero        REAL4   0.0
    one         REAL4   1.0
    tolerance   REAL4   0.001
    b_temp      DWORD   ?
    currentX    DWORD   ?
    temp        DWORD   ?

INCLUDE compare_float.h
INCLUDE point_finder.h

.CODE
    ;parameters
    line_array[ebp+16]
    degree[ebp+12]
    user_x[ebp+8]

    ;local variables
    computeXDegree [ebp-4]
    currentDegree   [ebp-8]

    interpolate_proc    PROC    NEAR32
        ;setup stack
        push ebp
        mov ebp, esp
        pushd 0
        pushd 0
        push ecx ;since getXD uses this register, make sure to store previous value
        pushfd

        ;move degree into currentDegree
        mov eax, degree
        mov currentDegree, eax

        ;automatically compute b0
        ;we know we will at least have that
        push zero
        push line_array
        call compute_b_proc
        mov b_temp, eax
        fld DWORD PTR b_temp

        ;loop through rest of our degree
        loop:
            ;check if at 0
            compare_floats currentDegree, zero, tolerance
            cmp ax, 0
            je done

            ;compute b for given degree
            push currentDegree
            push line_array
            call compute_b_proc
            mov b_temp, ax
            fld DWORD PTR b_temp

            ;decrement the degree by 1
            fld DWORD PTR currentDegree
            fld1 ;move 1 onto the stack
            fsub    ;subtract the two
            fstp DWORD PTR currentDegree

            ;calculate the (X - Xm), n = degree and m = n -1 ... 0
            mov eax, currentDegree
            mov computeXDegree, eax

            ;without duplicating work pass 1 unto the stack so that the first
            ;(X - Xi) has a value to multiply with
            fld1

            compute_x:
                ;check if computeXDegree is greater than 0
                compare_floats computeXDegree, zero, tolerance
                cmp ax, 0
                je compute_x_done

                ;compute X - Xn with n being currentXDegree
                fld DWORD PTR user_x
                getX line_array, currentXDegree, eax
                mov currentX, eax
                fld DWORD PTR currentX
                fsub

                ;compute (X - Xn)(X - Xn+1)
                ;on the first run since there i sno (X - Xn)
                ;it will use the 1 that was pushed prior to this
                ;loop
                fmul
                ;decrement computeXDegree
                fld DWORD PTR computeXDegree
                fld1
                fsub
                fstp DWORD PTR computeXDegree

                jmp compute_x
            compute_x_done:
                ;after multiplying all x's now we are at the last computed x and b
                ;now we just multiply the two
                fmul
                ;add this new value to the last Bn(X - Xn)
                fadd
                jmp loop
            done:
                ;we have value for x's y, store into eax
                fstp DWORD PTR temp
                mov eax, temp

                ;reset stack
                popfd
                pop ecx
                mov esp, ebp
                pop ebp
                ret 12
    interpolate_proc ENDP
END