[org 0x7c00]

start:
    ; Ensure CS is 0
    jmp 0:.clear_cs
.clear_cs:
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov si, welcome_msg
    call print_string

main_loop:
    mov si, prompt
    call print_string

    ; Read command
    mov di, buffer
    call read_line

    ; Compare command
    mov si, buffer
    mov di, cmd_ver
    call strcmp
    jc is_ver

    ; If buffer is not empty, it's an unknown command
    mov si, buffer
    cmp byte [si], 0
    je main_loop

    mov si, unknown_msg
    call print_string
    jmp main_loop

is_ver:
    mov si, ver_msg1
    call print_string
    mov si, ver_msg2
    call print_string
    jmp main_loop

; --- Functions ---

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp print_string
.done:
    ret

read_line:
    xor cl, cl
.loop:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D ; Enter
    je .done
    cmp al, 0x08 ; Backspace
    je .backspace

    cmp cl, 63 ; Buffer limit
    je .loop

    mov [di], al
    inc di
    inc cl
    mov ah, 0x0e
    int 0x10
    jmp .loop

.backspace:
    or cl, cl
    jz .loop
    dec di
    dec cl
    mov ah, 0x0e
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop

.done:
    mov byte [di], 0
    mov al, 0x0D
    mov ah, 0x0e
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

strcmp:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    or al, al
    jz .equal
    inc si
    inc di
    jmp .loop
.not_equal:
    clc
    ret
.equal:
    stc
    ret

; --- Data ---
welcome_msg db "Simple OS 16-bit", 13, 10, 0
prompt db "> ", 0
cmd_ver db "ver", 0
ver_msg1 db "OS 0.1", 13, 10, 0
ver_msg2 db "kernel v0", 13, 10, 0
unknown_msg db "Unknown command", 13, 10, 0
buffer times 64 db 0

times 510-($-$$) db 0
dw 0xaa55
