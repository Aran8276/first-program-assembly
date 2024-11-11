global _main
extern  _GetStdHandle@4
extern  _ReadFile@20
extern  _WriteFile@20
extern  _ExitProcess@4

; https://learn.microsoft.com/en-us/windows/console/getstdhandle
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-writefile
; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-readfile

section .bss
    buffer resb 128  ; Reserve 128 bytes for the input buffer
    bytes  resd 1    ; Reserve 4 bytes for the number of bytes read

section .data
    prompt db 'Enter some text: ', 0
    message db 'You entered: ', 0

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
    lea     eax, [ebp-4]      ; Address of 'bytes' (always this, based of the `bytes` variable, then subtract how many bytes allocated)
    push    eax               ; lpBuffer (always this)
    push    17                ; nNumberOfBytesToWrite
    push    prompt            ; lpNumberOfBytesWritten
    push    ebx               ; lpOverlapped (always this)
    call    _WriteFile@20     ; this is simply what method to call in usual programming language

    ; set console to input mode (-10)
    push    -10               ; STD_INPUT_HANDLE
    call    _GetStdHandle@4
    mov     ebx, eax          ; Store the handle in EBX

    ; read user input, and safe it into buffer
    push    0                 ; Overlapped parameter
    lea     eax, [ebp-4]      ; Address of 'bytes'
    push    eax
    push    128               ; Maximum number of bytes to read
    push    buffer            ; Address of the input buffer
    push    ebx               ; Handle to standard input
    call    _ReadFile@20

    ; set console to output mode (-11)
    push    -11               ; STD_OUTPUT_HANDLE
    call    _GetStdHandle@4
    mov     ebx, eax          ; store handle in ebx

    ; write message while in output mode
    push    0                 ; Overlapped parameter
    lea     eax, [ebp-4]      ; Address of 'bytes'
    push    eax
    push    14                ; Maximum number of bytes to read
    push    message          ; Address of the input buffer
    push    ebx               ; Handle to standard input
    call    _WriteFile@20

    ; write buffer (saved message from the input eralier) while in output mode
    push    0                 ; Overlapped parameter
    ; before pushing eax for length, complete this first
    lea     eax, [ebp-4]      ; Address of 'bytes'
    push    eax

    ; then we can push eax for length
    mov     eax, [ebp-4]      ; set eax to (4 bytes down from the base pointer).
    push    eax               ; Length of the input buffer
    push    buffer            ; Address of the input buffer
    push    ebx               ; Handle to standard output
    call    _WriteFile@20


    ; Exit the process
    push    0                 ; Exit code 0
    call    _ExitProcess@4

    ; Never here
    hlt                      ; Halt the CPU (this instruction should never be reached)
