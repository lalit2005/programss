bits 16

;--------------
; CODE SECTION
;--------------

start:
    ; set data segment to match code segment
    mov ax, cs
    mov ds, ax

    mov si, kernel_msg
print_loop:
    mov al, [si]
    cmp al, 0
    je halt

    mov ah, 0x0e
    int 0x10

    inc si
    jmp print_loop

halt:
    jmp $

;-------------
; PROGRAM DATA
;-------------
kernel_msg: db 13, 10, "Hello from kernel!", 0

