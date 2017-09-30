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
    point1_plane_x          WORD    ?
    point1_plane_y          WORD    ?
    point1_plane_z          WORD    ?

    point2_plane_x          WORD    ?
    point2_plane_y          WORD    ?
    point2_plane_z          WORD    ?
    
    point3_plane_x          WORD    ?
    point3_plane_y          WORD    ?
    point3_plane_z          WORD    ?

    ;Points on the line
    point1_line_x           WORD    ?
    point1_line_y           WORD    ?
    point1_line_z           WORD    ?

    point2_line_x           WORD    ?
    point2_line_y           WORD    ?
    point2_line_z           WORD    ?

    ;variables for point-point subtraction
    pps_x                   WORD    ?
    pps_y                   WORD    ?
    pps_z                   WORD    ?

    ;variables for cross-product
    cp_x                    WORD    ?
    cp_y                    WORD    ?
    cp_z                    WORD    ?

    ;variables for dot-product
    dp                      WORD    ?

    ;variables for normal
    n_x                     WORD    ?
    n_y                     WORD    ?
    n_z                     WORD    ?
    normal_temp_x           WORD    ?
    normal_temp_y           WORD    ?
    normal_temp_z           WORD    ?

    ;variables for a
    a_quotent               WORD    ?
    a_remainder             WORD    ?
    compute_a_temp          WORD    ?

    ;variables for input
    input_temp              BYTE    40 DUP(?)
    input_line_prompt_x     BYTE    "Enter x-coordinate of the line: ", 0
    input_line_prompt_y     BYTE    "Enter y-coordinate of the line: ", 0
    input_line_prompt_z     BYTE    "Enter z-coordinate of the line: ", 0

    input_plane_prompt_x    BYTE    "Enter x-coordinate of the plane: ", 0
    input_plane_prompt_y    BYTE    "Enter y-coordniate of the plane: ", 0
    input_plane_prompt_z    BYTE    "Enter z-coordniate of the plane: ", 0

    ;utility variables
    formatted_output        BYTE    50 DUP(?)
                            BYTE    cr, Lf, 0
    
;ask user for x, y, z, storing into variables given
point_input MACRO input_prompt_x, input_prompt_y, input_prompt_z, x, y, z

    ;input x
    inputw input_prompt_x, x
    ;input y
    inputw input_prompt_y, y
    ;input z
    inputw input_prompt_z, z

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
    mov cp_z bx

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
normal MACRO point1_x, point1_y, point1_z, point2_x, point2_y, point2_z, point3_x, point3_y, point3_z, point4_x, point4_y, point4_z
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

    ;store dot product in temp variable
    mov ax, dp
    mov compute_a_temp, ax

    ;compute demoninator
    
    ;point point subtraction with point 3 and point 2
    point_point_subtraction point3_x, point3_y, point3_z, point2_x, point2_y, point2_z
    
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


        INVOKE ExitProcess, 0 ; exit with return code 0
    
    PUBLIC _start

END