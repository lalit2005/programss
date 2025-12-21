bits 16
org 0x7c00


;--------------
; CODE SECTION
;--------------

start:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    mov [boot_drive], dl
    
; clear screen
mov ah, 0x00
mov al, 0x03 ; 80x25 color text mode
int 0x10 ; bios video interrupt

; set cursor position
mov ah, 0x02
mov bh, 0x00
mov dh, 0x00
mov dl, 0x00
int 0x10

call set_cursor_centered
mov si, bootloader_name
call print_string

mov si, newline
call print_string

call set_cursor_centered
mov si, bootloader_name_underline
call print_string

mov si, newline
call print_string

; =====================================
; call print_fullwidth_line
call print_fullwidth_line

mov si, newline
call print_string

mov si, newline
call print_string

; call set_cursor_centered
mov si, booting_msg
call print_string

mov si, newline
call print_string

call print_fullwidth_line
; call print_fullwidth_line
; =====================================

load_kernel:
    mov ah, 0x02
    mov al, 1 ; number of secctors
    mov ch, 0 ; cylinder no.
    mov cl, 2 ; sector number
    mov dh, 0 ; head no.
    mov dl, [boot_drive]
    mov bx, 0x1000
    int 0x13
    jc read_error

    mov si, newline
    call print_string
    mov si, newline
    call print_string

    jmp 0x100:0x0000 ; jump to the loaded kernel (cs=0x100, ip=0x0000)

read_error:
    push ax ; save the error code in ah on the stack
    mov si, error_msg
    call print_string

halt:
    jmp $

print_string: ; usage: mov si, string_addr
  pusha
  print_loop:
    mov al, [si]
    cmp al, 0
    je print_loop_end
    mov ah, 0x0E
    int 0x10
    inc si
    jmp print_loop

  print_loop_end:
    popa
    ret

print_fullwidth_line:
  pusha
  mov ah, 0x0F
  mov bh, 2
  int 10h ; ah contains the number of columns
  mov si, corner
  call print_string
  line:
    cmp ah, 2 ; 2 chars for the corner
    je line_end
    mov si, dash
    call print_string
    dec ah
    jmp line
  line_end:
    mov si, corner
    call print_string
    popa
    ret


print_centered_text: ; usage: si contains ptr to string
  pusha
  mov bx, si

  mov si, pipe
  call print_string
  call set_cursor_centered

  mov si, bx
  call print_string

  call set_cursor_centered
  mov si, pipe
  call print_string

end_print_centered_text:


; si should contain ptr to string
set_cursor_centered:
  pusha
  mov bx, si
  mov cx, 0
  str_len_loop:
    cmp byte [si], 0
    je end_str_len_loop
    inc cx
    inc si
    jmp str_len_loop
  end_str_len_loop:
  sub cx, 2; for the first and last | chars
  ; cx contains length of input str
  ; req spaces = (total width - str len) / 2
  mov ah, 0x0F
  int 10h ; ah contains no. of cols
  mov al, ah
  mov ah, 0 ; ax contains no. of cols now
  sub ax, cx
  ; mov dx, ax;|
  ; shr dx, 2 ;| visual centering
  shr ax, 1
  sub ax, 15
  mov cx, ax
  ; cx now contains required spaces to be printed
  cursor_pos_loop:
    mov si, bx
    cmp cx, 0
    je end_cursor_pos_loop
    mov si, space
    call print_string
    dec cx
    jmp cursor_pos_loop
end_cursor_pos_loop:
  popa
  ret

;--------------
; PROGRAM DATA
;--------------
bootloader_name: db "GR3B - GROUP 33'S BOOTLOADER :)", 13, 10, 0
bootloader_name_underline: db "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^", 13, 10, 13, 10, 0
booting_msg: db "//                       Loading kernel & booting now...                      //", 13, 10, 13, 10, 0
boot_drive: db 0
error_msg: db 13, 10, "AN ERROR OCCURED WHILE COPYING DISK SECTOR TO MEMORY.", 0
dash: db "-", 0
corner: db "/", 0
pipe: db "|", 0
space: db " ", 0
newline: db 13, 10, 0

times 510 - ($ - $$) db 0

dw 0xAA55

