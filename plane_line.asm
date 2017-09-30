;Plane Line Intersection program - calculates the point where two planes intersect
;Author: Sam ONeal
;Date: 9/30/2017

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE io.h            ;header file for input/output
INCLUDE debug.h         ;header file for debugging program

cr      EQU     0dh     ;carriage return character
Lf      EQU     0ah     ;line feed

.STACK 4096             ;reserve 4096-byte stack

.DATA
    ;Points on the plane
    point1_plane_x              WORD    ?
    point1_plane_y              WORD    ?
    point1_plane_z              WORD    ?

    point2_plane_x              WORD    ?
    point2_plane_y              WORD    ?
    point2_plane_z              WORD    ?
    
    point3_plane_x              WORD    ?
    point3_plane_y              WORD    ?
    point3_plane_z              WORD    ?

    ;Points on the line
    point1_line_x               WORD    ?
    point1_line_y               WORD    ?
    point1_line_z               WORD    ?

    point2_line_x               WORD    ?
    point2_line_y               WORD    ?
    point2_line_z               WORD    ?

    ;variables for point-point subtraction
    pps_x                       WORD    ?
    pps_y                       WORD    ?
    pps_z                       WORD    ?

    ;variables for cross-product
    cp_x                        WORD    ?
    cp_y                        WORD    ?
    cp_z                        WORD    ?

    ;variables for dot-product
    dp                          WORD    ?

    ;variables for normal
    n_x                         WORD    ?
    n_y                         WORD    ?
    n_z                         WORD    ?
    normal_temp_x               WORD    ?
    normal_temp_y               WORD    ?
    normal_temp_z               WORD    ?

    ;variables for a
    a_numerator                 WORD    ?
    a_denominator               WORD    ?

    ;variables for point of intersection
    poi_x_quotent               WORD    ?
    poi_x_remainder             WORD    ?
    poi_y_quotent               WORD    ?
    poi_y_remainder             WORD    ?
    poi_z_quotent               WORD    ?
    poi_z_remainder             WORD    ?

    poi_temp_x                  WORD    ?
    poi_temp_y                  WORD    ?
    poi_temp_z                  WORD    ?

    ;variables for input
    input_temp                  BYTE    40 DUP(?)
    input_line_prompt_x         BYTE    "Enter x-coordinate of the line: ", 0
    input_line_prompt_y         BYTE    "Enter y-coordinate of the line: ", 0
    input_line_prompt_z         BYTE    "Enter z-coordinate of the line: ", 0

    input_plane_prompt_x        BYTE    "Enter x-coordinate of the plane: ", 0
    input_plane_prompt_y        BYTE    "Enter y-coordniate of the plane: ", 0
    input_plane_prompt_z        BYTE    "Enter z-coordniate of the plane: ", 0

    ;utility variables
    formatted_output            BYTE    50 DUP(?)
                                BYTE    cr, Lf, 0
    
;ask user for x, y, z, storing into variables given
point_input MACRO input_prompt_x, input_prompt_y, input_prompt_z, x, y, z

    ;input x
    inputw input_prompt_x, x
    outputW x
    ;input y
    inputw input_prompt_y, y
    outputW y
    ;input z
    inputw input_prompt_z, z
    outputW z

    ENDM

;format the x, y, z values given with with () around them and commas separating
format_ouput MACRO x, y, z

    ;add first parathensis at beginning
    mov formatted_output, "("
    ;add x
    itoa formatted_output+1, x ;assume word so 6 spaces will fill
    ;add ','
    mov formatted_output+7, ","
    ;add y
    itoa formatted_output+8, y
    ;add ','
    mov formatted_output+14, ","
    ;add z
    itoa formatted_output+15, z
    ;add closing parathensis
    mov formatted_output+21, ")"

    ENDM

;format the x, y, z, values given with () around them and commas separating
;the values are decimal based
;intentionally leaving extra padding between whole number and decimal incase of a 3 digit number
format_output_decimal MACRO x_quotent, x_remainder, y_quotent, y_remainder, z_quotent, z_remainder

    ;add '(' to beginning
    mov formatted_output, "("
    ;add  x remainder
    itoa formatted_output+5, x_remainder ;assuming word size so 6 spaces
    ;add '.'
    mov formatted_output+7, "."
    ;add x quotent
    itoa formatted_output+1, x_quotent
    ;add ','
    mov formatted_output+11, ","
    ;add y remainder
    itoa formatted_output+16, y_remainder
    ;add '.'
    mov formatted_output+18, "."
    ;add y quotent
    itoa formatted_output+12, y_quotent
    ;add ','
    mov formatted_output+22, ","
    ;add z remainder
    itoa formatted_output+27, z_remainder
    ;add '.'
    mov formatted_output+29, "."
    ;add z quotent
    itoa formatted_output+23, z_quotent
    ;add ")"
    mov formatted_output+33, ")"

    ENDM

;deals with doing point to point subtraction
;automatically stores output into pps_x, pps_y, pps_z
point_point_subtraction MACRO point1_x, point1_y, point1_z, point2_x, point2_y, point2_z
    ;clear out eax and ebx registers before doing calculations
    mov eax, 0
    mov ebx, 0

    ;subtract x's
    mov ax, point1_x
    mov bx, point2_x
    sub ax, bx
    mov pps_x, ax

    ;subtract y's
    mov ax, point1_y
    mov bx, point2_y
    sub ax, bx
    mov pps_y, ax

    ;subtract z's
    mov ax, point1_z
    mov bx, point2_z
    sub ax, bx
    mov pps_z, ax

    ENDM

;calculates the cross product given two points
;automatically stores into cp_x, cp_y, cp_z
cross_product MACRO point1_x, point1_y, point1_z, point2_x, point2_y, point2_z
    ;clear eax and ebx
    mov eax, 0
    mov ebx, 0

    ;cross component x
    mov ax, point1_y
    mov bx, point2_z
    imul bx
    mov cp_x, ax
    mov ax, point1_z
    mov bx, point2_y
    imul bx
    mov bx, cp_x
    sub bx, ax
    mov cp_x, bx

    ;cross component y
    mov ax, point1_z
    mov bx, point2_x
    imul bx
    mov cp_y, ax
    mov ax, point1_x
    mov bx, point2_z
    imul bx
    mov bx, cp_y
    sub bx, ax
    mov cp_y, bx

    ;cross component z
    mov ax, point1_x
    mov bx, point2_y
    imul bx
    mov cp_z, ax
    mov ax, point1_y
    mov bx, point2_x
    imul bx
    mov bx, cp_z
    sub bx, ax
    mov cp_z, bx

    ENDM

;calculates the dot product given 2 points
;automatically stores in dp
dot_product MACRO point1_x, point1_y, point1_z, point2_x, point2_y, point2_z
    ;clear eax and ebx
    mov eax, 0
    mov ebx, 0

    ;multiplication of x
    mov ax, point1_x
    mov bx, point2_x
    imul bx
    mov dp, ax

    ;multiplication of y
    mov ax, point1_y
    mov bx, point2_y
    imul bx
    ;add x+y
    mov bx, dp
    add ax, bx
    mov dp, ax

    ;multiplication of z
    mov ax, point1_z
    mov bx, point2_z
    imul bx
    ;add (x+y)+z
    mov bx, dp
    add ax, bx
    mov dp, ax

    ENDM

;calculates the normal given 4 points
;automatically stores in n_x, n_y, n_z
normal MACRO point1_x, point1_y, point1_z, point2_x, point2_y, point2_z, point3_x, point3_y, point3_z
    ;clear eax, ebx
    mov eax, 0
    mov ebx, 0

    ;do point point subtraction for point 2 and point 1
    point_point_subtraction point2_x, point2_y, point2_z, point1_x, point1_y, point1_z

    ;mov all pps into normal_temps
    mov ax, pps_x
    mov normal_temp_x, ax
    mov ax, pps_y
    mov normal_temp_y, ax
    mov ax, pps_z
    mov normal_temp_z, ax

    ;do point point subtraction for point 3 and point 1
    point_point_subtraction point3_x, point3_y, point3_z, point1_x, point1_y, point1_z

    ;do cross product with normal_temps and pps
    cross_product normal_temp_x, normal_temp_y, normal_temp_z, pps_x, pps_y, pps_z

    ;mov values into n
    mov ax, cp_x
    mov n_x, ax
    mov ax, cp_y
    mov n_y, ax
    mov ax, cp_z
    mov n_z, ax

    ENDM

;caluclates scalar a that will be used to help with parametric equation
;automatically stores result in a
compute_a MACRO point1_x, point1_y, point1_z, point2_x, point2_y, point2_z, point3_x, point3_y, point3_z
    ;clear eax, ebx
    mov eax, 0
    mov ebx, 0

    ;compute numerator

    ;point point subtraction with point1 and point2
    point_point_subtraction point1_x, point1_y, point1_z, point2_x, point2_y, point2_z
    ;dot product with the normal
    dot_product n_x, n_y, n_z, pps_x, pps_y, pps_z

    ;store dot product into a_numerator
    mov ax, dp
    mov a_numerator, ax

    ;compute demoninator
    
    ;point point subtraction with point 3 and point 2
    point_point_subtraction point3_x, point3_y, point3_z, point2_x, point2_y, point2_z
    ;dot product with the normal
    dot_product n_x, n_y, n_z, pps_x, pps_y, pps_z

    ;store dot product into a_denominator
    mov ax, dp
    mov a_denominator, ax

    ENDM


point_of_intersection MACRO
    ;clear eax, ebx
    mov eax, 0
    mov ebx, 0

    ;uses a_denominator * P(a) = a_numerator(p2 - p1) + a_denominator * p1

    ;calculate point_point_subtraction
    point_point_subtraction point2_line_x, point2_line_y, point2_line_z, point1_line_x, point1_line_y, point1_line_z

    ;calculate a_denominator * x
    mov ax, a_numerator
    mov bx, pps_x
    imul bx
    mov poi_temp_x, ax
    mov ax, a_denominator
    mov bx, point1_line_x
    imul bx
    mov bx, poi_temp_x
    add ax, bx
    mov poi_temp_x, ax
    ;division
    mov ax, poi_temp_x
    cwd
    mov bx, a_denominator
    idiv bx
    mov poi_x_quotent, ax
    mov poi_x_remainder, dx
    ;clean up remainder
    cleanup_remainder poi_x_remainder, a_denominator

    ;calculate a_denominator * y
    mov ax, a_numerator
    mov bx, pps_y
    imul bx
    mov poi_temp_y, ax
    mov ax, a_denominator
    mov bx, point1_line_y
    imul bx
    mov bx, poi_temp_y
    add ax, bx
    mov poi_temp_y, ax
    ;division
    mov ax, poi_temp_y
    cwd
    mov bx, a_denominator
    idiv bx
    mov poi_y_quotent, ax
    mov poi_y_remainder, dx
    ;cleanup_remainder
    cleanup_remainder poi_y_remainder, a_denominator

    ;calculate a_denominator * z
    mov ax, a_numerator
    mov bx, pps_z
    imul bx
    mov poi_temp_z, ax
    mov ax, a_denominator
    mov bx, point1_line_z
    imul bx
    mov bx, poi_temp_z
    add ax, bx
    mov poi_temp_z, ax
    ;division
    mov ax, poi_temp_z
    cwd
    mov bx, a_denominator
    idiv bx
    mov poi_z_quotent, ax
    mov poi_z_remainder, dx
    ;cleanup_remainder
    cleanup_remainder poi_z_remainder, a_denominator

    ENDM

cleanup_remainder MACRO remainder, denominator
    local NEGATE_REMAINDER, CONTINUE

    ;clear eax, ebx
    mov eax, 0
    mov ebx, 0

    mov ax, remainder
    mov cx, ax ;for checking if remainder is negative
    mov bx, 100

    jge CONTINUE ;if its not, then don't worry about negating
NEGATE_REMAINDER:
    neg bx
CONTINUE:
    imul bx

    mov bx, denominator

    cwd

    idiv bx
    ;put quotient into remainder
    mov remainder, ax
    ENDM

.CODE
    _start:
        ;input 3 points for plane
        point_input input_plane_prompt_x, input_plane_prompt_y, input_plane_prompt_z, point1_plane_x, point1_plane_y, point1_plane_z
        format_ouput point1_plane_x, point1_plane_y, point1_plane_z
        output formatted_output
        output carriage

        point_input input_plane_prompt_x, input_plane_prompt_y, input_plane_prompt_z, point2_plane_x, point2_plane_y, point2_plane_z
        format_ouput point2_plane_x, point2_plane_y, point2_plane_z
        output formatted_output
        output carriage

        point_input input_plane_prompt_x, input_plane_prompt_y, input_plane_prompt_z, point3_plane_x, point3_plane_y, point3_plane_z
        format_ouput point3_plane_x, point3_plane_y, point3_plane_z
        output formatted_output
        output carriage

        ;input 2 points for line
        point_input input_line_prompt_x, input_line_prompt_y, input_line_prompt_z, point1_line_x, point1_line_y, point1_line_z
        format_ouput point1_line_x, point1_line_y, point1_line_z
        output formatted_output
        output carriage

        point_input input_line_prompt_x, input_line_prompt_y, input_line_prompt_z, point2_line_x, point2_line_y, point2_line_z
        format_ouput point2_line_x, point2_line_y, point2_line_z
        output formatted_output
        output carriage

        ;calculate normal with the three planes
        normal point1_plane_x, point1_plane_y, point1_plane_z, point2_plane_x, point2_plane_y, point2_plane_z, point3_plane_x, point3_plane_y, point3_plane_z

        ;calculate a with any plane and both point of line
        compute_a point3_plane_x, point3_plane_y, point3_plane_z, point1_line_x, point1_line_y, point1_line_z, point2_line_x, point2_line_y, point2_line_z

        ;calculate point of intersect
        point_of_intersection

        ;format poi values
        format_output_decimal poi_x_quotent, poi_x_remainder, poi_y_quotent, poi_y_remainder, poi_z_quotent, poi_z_remainder

        ;output results
        output carriage
        output formatted_output
        output carriage
        INVOKE ExitProcess, 0 ; exit with return code 0
    
    PUBLIC _start

END