.NOLIST
.386

;need reference to the procedure that will be called
EXTERN compute_b_proc : NEAR32

;line_array_name: The name of the array that holds the line
;degree: Is how far the b value is computed
;
;eax will hold the computed b

compute_b MACRO line_array_name, degree
    ;push ebx onto the stack
    push ebx

    ;move pointer for the line into ebx
    lea ebx, line_array_name
    ;push values onto the stack
    push ebx
    push degree
    ;call procedure
    call compute_b_proc
ENDM

.NOLISTMACRO
.LIST