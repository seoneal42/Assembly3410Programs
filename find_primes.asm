; compute and display the first MAXNBRS prime numbers
; author:  M. Boshart
; date:  revised 10/07/2007

.386
.MODEL FLAT

ExitProcess PROTO NEAR32 stdcall, dwExitCode:DWORD

; a decision was made to use ch and cl as byte counters
; obtain the first MAXNBRS prime numbers (cannot exceed 255 due to the cmp below)
MAXNBRS     EQU    255   

.STACK      4096

.DATA
primes_array             			WORD  MAXNBRS DUP (?)
candidate_prime_number   	WORD  ?

INCLUDE debug.h



printArray 	MACRO array_name, size_array

                   local print_loop                ; offset depends on where inserted into program

                   ; print out the first MAXNBRS prime numbers
                   mov ecx, size_array
                   lea ebx, array_name

print_loop:

                   outputW WORD PTR [ebx]         
                   add ebx, 2          
                   loop print_loop		;loop cache

				ENDM
				
.CODE
_start:

				; what about mov ebx, primes_array?
                lea ebx, primes_array		; loader changes the "immediate" to the absolute address    
                                                   
                mov WORD PTR [ebx], 2 ; WORD PTR required here (2 is ambiguous)

                mov cl, 1                          				; count of identified prime numbers (the first one is already done)
                mov candidate_prime_number, 3      	; the next prime candidate (odd integers only)

loop_for_primes:

                ; set up for the next prime (cx keeps track of the number of primes found so far)
                cmp cl, MAXNBRS ; MAXNBRS must be less than 256
                je end_loop_for_primes

                ; candidates will only be odd numbers (so ch can be 1 and not 0)
                mov ch, 1                  	   			; current index of primes array (reset to test 3 first)
				lea ebx, primes_array + 2			; skip to the index of 3 (not testing even numbers)						

                ; to detect a prime number, simply divide all of the previous primes into that number
                ; if the mod is never 0, then a new prime number has been detected
                ; really only have to check up to the sqrt of the candidate
                test_all_previous_primes:

                      ; cl contains the number of primes found so far
                      ; ch contains the index of the prime number under consideration
                      cmp ch, cl    ; continue while current prime index is less than or equal to prime count
                      je end_test_all_previous_primes

                      ; division to see if the remainder is zero (not a prime number)
        
                      mov ax, candidate_prime_number      	; the dividend is the candidate prime number
                      mov dx, 0                           				; unsigned dividend extension

                      div WORD PTR [ebx]            	; divide the candidate prime number by the current prime number
                      ; the remainder is in dx
                      cmp dx, 0

                      je not_prime                       		; the number is not prime, so exit the loop and test another candidate

                      inc ch                              		; the number still might be prime, so continue, testing the next already identified prime number
                      add ebx, 2                          	; address of next prime number
                      jmp test_all_previous_primes

			end_test_all_previous_primes:

                inc cl                                    				; a new prime number was found, so increment prime count

				; no memory to memory moves  
                mov ax, candidate_prime_number           ; put prime number into array
                mov [ebx], ax                             			; update the array with the new prime number
       
not_prime:

                ; whether a new prime number was found or not, increment candidate and continue
                add candidate_prime_number, 2             ; candidates are odd numbers (2 mem refs in this instruction!)
                jmp loop_for_primes

end_loop_for_primes:

                printArray primes_array, MAXNBRS

done:

            INVOKE ExitProcess, 0   ; exit with return code 0

PUBLIC _start
            END
