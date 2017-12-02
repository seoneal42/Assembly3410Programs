;Fallout 3 Password Hacking
;Author: Sam ONeal
;Date: 11/28/2017

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

INCLUDE read_passwords.h

.STACK 4096

LEN EQU 13
MAX EQU 20

.DATA
    passwords   WORD   20   DUP(?)
    term        BYTE        78h
    size        BYTE        ?
    count       BYTE        ?

.CODE
    _start:
        mov al, LEN
        mov size, al
        mov al, MAX
        mov count, al

        read_passwords passwords, count, size, term

        INVOKE ExitProcess, 0
    PUBLIC _start
END