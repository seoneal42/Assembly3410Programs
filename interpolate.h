.NOLIST
.386

EXTERN compute_b_proc: NEAR32
EXTERN interpolate_proc: NEAR32

;user_x: the x value that is user is wanting its corresponding y
;line_array_name: the name of the line used to calculate new Y
;degree: iteration, refinement, factor used to approximate b
;
;eax will store computed y

interpolate MACRO user_x, line_array_name, degree
    ;use ebx line array
    ;save value of ebx
    push ebx
    lea ebx, line_array_name
    push user_x
    push degree
    push ebx
    call interpolate_proc
    ;grab old ebx
    pop ebx
ENDM

.NOLISTMACRO
.LIST