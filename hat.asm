[bits 64]

section .text
    global _start
    global drawChar
    global clearScreen
    global kbd_get_scancode
    global kbd_to_ascii

_start:
    ; Configurar el stack
    mov rsp, 0x90000
    mov rbp, rsp

    ; Limpiar pantalla (Azul)
    mov rdi, 0x1F
    call clearScreen

    ; Título
    mov rdi, 0xB8000
    mov rsi, msg_welcome
    mov rdx, 0x1F
    call printString

    ; Prompt inicial
    mov rdi, 0xB8000
    add rdi, 160 ; Segunda línea
    mov rsi, msg_prompt
    mov rdx, 0x1F
    call printString

    ; Dirección actual del cursor de escritura
    mov r12, 0xB8000
    add r12, 160 + 4 ; Justo después de '> '

terminal_loop:
    call kbd_get_scancode
    test al, al
    jz terminal_loop

    ; Si es una tecla presionada (no soltada, bit 7 es 0)
    test al, 0x80
    jnz terminal_loop

    ; Convertir a ASCII
    movzx rdi, al
    call kbd_to_ascii
    test al, al
    jz terminal_loop

    ; Si presionan ENTER (0x1C scancode, '\n' ASCII)
    cmp al, 10
    je process_command

    ; Mostrar carácter en pantalla
    mov rdi, r12
    movzx rsi, al
    mov rdx, 0x1F
    call drawChar
    add r12, 2

    ; Guardar en buffer (muy simple para demostración)
    mov [cmd_buffer + r13], al
    inc r13

    ; Evitar que el loop sea demasiado rápido
    mov rcx, 0xFFFF
    .delay: loop .delay

    jmp terminal_loop

process_command:
    ; Verificar si el comando es "firm"
    ; r13 tiene la longitud
    cmp r13, 4
    jne reset_terminal

    mov eax, [cmd_buffer]
    cmp eax, "firm"
    je show_firm

    jmp reset_terminal

show_firm:
    mov rdi, 0xB8000
    add rdi, 320 ; Tercera línea
    mov rsi, msg_firm
    mov rdx, 0x1E ; Amarillo
    call printString
    jmp reset_terminal

reset_terminal:
    ; Limpiar buffer y longitud
    xor r13, r13
    ; Bajar a la siguiente línea (simplificado)
    add r12, 160
    ; Mostrar prompt de nuevo
    mov rdi, r12
    mov rsi, msg_prompt
    mov rdx, 0x1F
    call printString
    add r12, 4
    jmp terminal_loop

; --- Funciones Auxiliares ---

drawChar:
    mov rax, rdx
    shl rax, 8
    or rax, rsi
    mov [rdi], ax
    ret

printString:
    ; RDI: base addr, RSI: string addr, RDX: color
.loop:
    movzx rax, byte [rsi]
    test al, al
    jz .done
    push rsi
    mov rsi, rax
    call drawChar
    pop rsi
    add rdi, 2
    inc rsi
    jmp .loop
.done:
    ret

clearScreen:
    mov rax, rdi
    shl rax, 8
    or rax, 0x20
    mov rdi, 0xB8000
    mov rcx, 80 * 25
.loop:
    mov [rdi], ax
    add rdi, 2
    loop .loop
    ret

kbd_get_scancode:
    in al, 0x64
    test al, 1
    jz .no_key
    in al, 0x60
    ret
.no_key:
    xor al, al
    ret

kbd_to_ascii:
    ; RDI: scancode
    cmp rdi, 0x1E ; 'A'
    je .a
    cmp rdi, 0x30 ; 'B'
    je .b
    cmp rdi, 0x2E ; 'C'
    je .c
    cmp rdi, 0x20 ; 'D'
    je .d
    cmp rdi, 0x12 ; 'E'
    je .e
    cmp rdi, 0x21 ; 'F'
    je .f
    cmp rdi, 0x22 ; 'G'
    je .g
    cmp rdi, 0x23 ; 'H'
    je .h
    cmp rdi, 0x17 ; 'I'
    je .i
    cmp rdi, 0x24 ; 'J'
    je .j
    cmp rdi, 0x25 ; 'K'
    je .k
    cmp rdi, 0x26 ; 'L'
    je .l
    cmp rdi, 0x32 ; 'M'
    je .m
    cmp rdi, 0x31 ; 'N'
    je .n
    cmp rdi, 0x18 ; 'O'
    je .o
    cmp rdi, 0x19 ; 'P'
    je .p
    cmp rdi, 0x10 ; 'Q'
    je .q
    cmp rdi, 0x13 ; 'R'
    je .r
    cmp rdi, 0x1F ; 'S'
    je .s
    cmp rdi, 0x14 ; 'T'
    je .t
    cmp rdi, 0x16 ; 'U'
    je .u
    cmp rdi, 0x2F ; 'V'
    je .v
    cmp rdi, 0x11 ; 'W'
    je .w
    cmp rdi, 0x2D ; 'X'
    je .x
    cmp rdi, 0x15 ; 'Y'
    je .y
    cmp rdi, 0x2C ; 'Z'
    je .z
    cmp rdi, 0x1C ; ENTER
    je .enter
    xor al, al
    ret
.a: mov al, 'a'; ret
.b: mov al, 'b'; ret
.c: mov al, 'c'; ret
.d: mov al, 'd'; ret
.e: mov al, 'e'; ret
.f: mov al, 'f'; ret
.g: mov al, 'g'; ret
.h: mov al, 'h'; ret
.i: mov al, 'i'; ret
.j: mov al, 'j'; ret
.k: mov al, 'k'; ret
.l: mov al, 'l'; ret
.m: mov al, 'm'; ret
.n: mov al, 'n'; ret
.o: mov al, 'o'; ret
.p: mov al, 'p'; ret
.q: mov al, 'q'; ret
.r: mov al, 'r'; ret
.s: mov al, 's'; ret
.t: mov al, 't'; ret
.u: mov al, 'u'; ret
.v: mov al, 'v'; ret
.w: mov al, 'w'; ret
.x: mov al, 'x'; ret
.y: mov al, 'y'; ret
.z: mov al, 'z'; ret
.enter: mov al, 10; ret

section .data
    msg_welcome db "MiniOS Dart v0.1 - Terminal Ready", 0
    msg_prompt  db "> ", 0
    msg_firm    db "Version 0.1 - Creado por Emmanuel", 0

    cmd_buffer times 64 db 0
