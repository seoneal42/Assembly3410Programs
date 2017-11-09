;Newton's Interpolating Polynomials
;Author: Sam ONeal
;Date: 11/05/2017

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE input_values.h
INCLUDE interpolate.h

.STACK 4096

.DATA
    degree  DWORD   ?
    user_x  DWORD   ?
    line_array  DWORD   40 DUP(?)

    num_of_points   WORD    ?

.CODE
    _start:
        ;read the x value
        read_user_x user_x

        ;read the degree
        read_user_degree degree

        ;read the points
        create_line line_array, num_of_points

        ;sort and print points
        sort_and_read_line_points line_array, user_x, num_of_points

        INVOKE ExitProcess, 0

    PUBLIC _start
END
