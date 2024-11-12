global _main
extern  _GetStdHandle@4
extern  _ReadFile@20
extern  _WriteFile@20
extern  _ExitProcess@4

; Cheatsheet:
; eax: 32-bit accumulator register
; e: 32-bit
; ax: accumulator

; ecx: 32-bit counter register
; e: 32-bit
; cx: counter

; edx: 32-bit data register
; e: 32-bit
; dx: data

; ebx: 32-bit base register
; e: 32-bit
; bx: base

; ebp: 32-bit base pointer
; e: 32-bit
; bp: base pointer

; Note: e in this context should be "Extended"
; but extended simply means 32-bit, so



section .bss
    buffer resb 128  ; Reserve 128 bytes for the input buffer
    bytes  resd 1    ; Reserve 4 bytes for the number of bytes read

section .data
    prompt db 'Want some Ice Cream?: ', 0
    message db 'Heres your ice cream: ', 0
    true db 'yes', 0

section .text
_main:
    ; initial setup for base pointer for the stack frame
    mov     ebp, esp
    sub     esp, 4            ; Allocate 4 bytes on the stack for the variable 'bytes'

    ; set console to output mode (-11)
    push    -11               ; STD_OUTPUT_HANDLE
    call    _GetStdHandle@4
    mov     ebx, eax          ; Store the handle in EBX

    ; write prompt while in output mode
    push    0                 ; hFile (always 0 since the file is console)
    lea     eax, [ebp-4]      ; Address of 'bytes'
    push    eax               ; lpNumberOfBytesWritten
    push    22         ; nNumberOfBytesToWrite
    push    prompt            ; lpBuffer
    push    ebx               ; hFile
    call    _WriteFile@20

    ; set console to input mode (-10)
    push    -10               ; STD_INPUT_HANDLE
    call    _GetStdHandle@4
    mov     ebx, eax          ; Store the handle in EBX

    ; read user input, and save it into buffer
    push    0                 ; Overlapped parameter
    lea     eax, [ebp-4]      ; Address of 'bytes'
    push    eax
    push    128               ; Maximum number of bytes to read
    push    buffer            ; Address of the input buffer
    push    ebx               ; Handle to standard input
    call    _ReadFile@20

    ; compare buffer with true
    lea     esi, [buffer]
    lea     edi, [true]
    mov     ecx, 3            ; Length of the string "yes"
    repe cmpsb
    jne     NotEqual
    
    ; set console to output mode (-11)
    push    -11               ; STD_OUTPUT_HANDLE
    call    _GetStdHandle@4
    mov     ebx, eax          ; Store the handle in EBX

    ; write message while in output mode
    push    0                 ; Overlapped parameter
    lea     eax, [ebp-4]      ; Address of 'bytes'
    push    eax
    push    22        ; Maximum number of bytes to read
    push    message           ; Address of the input buffer
    push    ebx               ; Handle to standard output
    call    _WriteFile@20

NotEqual:
    ; Exit the process
    push    0                 ; Exit code 0
    call    _ExitProcess@4

    ; Never here
    hlt                      ; Halt the CPU (this instruction should never be reached)
