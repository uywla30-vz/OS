[bits 64]

section .text
    global _start
    global drawChar
    global clearScreen

_start:
    ; --- Inicialización de Entorno ---
    cli

    ; Vaciar buffer de teclado inicial
.clear_kbd:
    in al, 0x64
    test al, 1
    jz .kbd_ready
    in al, 0x60
    jmp .clear_kbd
.kbd_ready:

    mov rsp, 0x90000
    mov rbp, rsp
    xor r13, r13            ; Buffer index
    xor r12, r12            ; Cursor index

    ; Limpiar pantalla
    mov rdi, 0x1F ; Azul
    call clearScreen

    ; Bienvenida
    mov rdi, 0xB8000
    mov rsi, msg_welcome
    mov rdx, 0x1F
    call printString

    ; Prompt
    call next_line
    mov rsi, msg_prompt
    mov rdx, 0x1F
    call printString

    ; Guardar posición inicial del cursor para comandos
    mov r12, rdi

terminal_loop:
    call kbd_get_scancode
    test al, al
    jz terminal_loop

    test al, 0x80           ; Ignorar Release
    jnz terminal_loop

    movzx rdi, al
    call kbd_to_ascii
    test al, al
    jz terminal_loop

    cmp al, 10              ; ENTER
    je process_command

    cmp al, 8               ; BACKSPACE
    je handle_backspace

    ; Mostrar y Guardar
    cmp r13, 63
    jge terminal_loop

    mov [cmd_buffer + r13], al
    inc r13

    mov rdi, r12
    movzx rsi, al
    mov rdx, 0x1F
    call drawChar
    add r12, 2

    jmp terminal_loop

handle_backspace:
    test r13, r13
    jz terminal_loop
    dec r13
    sub r12, 2
    mov rdi, r12
    mov rsi, ' '
    mov rdx, 0x1F
    call drawChar
    jmp terminal_loop

process_command:
    mov byte [cmd_buffer + r13], 0
    call next_line

    ; Comandos
    mov rsi, cmd_buffer

    ; Comparar "firm"
    mov rdi, str_firm
    call strcmp
    jc .is_firm

    ; Comparar "dart"
    mov rdi, str_dart
    call strcmp
    jc .run_dart

    ; Desconocido
    mov rsi, msg_unknown
    mov rdx, 0x1C ; Rojo
    call printString
    jmp .done

.is_firm:
    mov rsi, msg_firm
    mov rdx, 0x1E ; Amarillo
    call printString
    jmp .done

.run_dart:
    mov rsi, msg_running_dart
    mov rdx, 0x1A ; Verde
    call printString

    ; --- SALTO AL CÓDIGO DART EXTRAÍDO ---
    ; El código de Dart está incluido al final del kernel.
    ; Saltamos a la dirección donde lo hayamos cargado/incluido.
    call next_line
    jmp dart_entry

.done:
    xor r13, r13
    call next_line
    mov rsi, msg_prompt
    mov rdx, 0x1F
    call printString
    mov r12, rdi
    jmp terminal_loop

; --- Funciones del HAT ---

strcmp:
    ; RSI: buffer, RDI: constant
    push rsi
    push rdi
.loop:
    mov al, [rsi]
    mov bl, [rdi]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc rsi
    inc rdi
    jmp .loop
.not_equal:
    clc
    jmp .fin
.equal:
    stc
.fin:
    pop rdi
    pop rsi
    ret

printString:
    mov rdi, r12
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
    mov r12, rdi
    ret

next_line:
    mov rax, r12
    sub rax, 0xB8000
    xor rdx, rdx
    mov rbx, 160
    div rbx
    inc rax
    mul rbx
    add rax, 0xB8000
    mov r12, rax
    ret

drawChar:
    mov rax, rdx
    shl rax, 8
    or rax, rsi
    mov [rdi], ax
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
    ; Mapeo simplificado
    cmp rdi, 0x1E ; A
    je .a
    cmp rdi, 0x30 ; B
    je .b
    cmp rdi, 0x2E ; C
    je .c
    cmp rdi, 0x20 ; D
    je .d
    cmp rdi, 0x12 ; E
    je .e
    cmp rdi, 0x21 ; F
    je .f
    cmp rdi, 0x22 ; G
    je .g
    cmp rdi, 0x23 ; H
    je .h
    cmp rdi, 0x17 ; I
    je .i
    cmp rdi, 0x24 ; J
    je .j
    cmp rdi, 0x25 ; K
    je .k
    cmp rdi, 0x26 ; L
    je .l
    cmp rdi, 0x32 ; M
    je .m
    cmp rdi, 0x31 ; N
    je .n
    cmp rdi, 0x18 ; O
    je .o
    cmp rdi, 0x19 ; P
    je .p
    cmp rdi, 0x10 ; Q
    je .q
    cmp rdi, 0x13 ; R
    je .r
    cmp rdi, 0x1F ; S
    je .s
    cmp rdi, 0x14 ; T
    je .t
    cmp rdi, 0x16 ; U
    je .u
    cmp rdi, 0x2F ; V
    je .v
    cmp rdi, 0x11 ; W
    je .w
    cmp rdi, 0x2D ; X
    je .x
    cmp rdi, 0x15 ; Y
    je .y
    cmp rdi, 0x2C ; Z
    je .z
    cmp rdi, 0x1C ; ENTER
    je .enter
    cmp rdi, 0x0E ; BACKSPACE
    je .backspace
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
.backspace: mov al, 8; ret

section .data
    msg_welcome db "MiniOS DART v0.2.1 - Interactive Shell", 0
    msg_prompt  db "> ", 0
    msg_firm    db "Version 0.1 - Creado por Emmanuel", 0
    msg_unknown db "Comando desconocido.", 0
    msg_running_dart db "Saltando al runtime de Dart...", 0

    str_firm    db "firm", 0
    str_dart    db "dart", 0

    cmd_buffer times 64 db 0

section .rodata
    ; Incluir físicamente el código de Dart extraído
    align 4096
dart_entry:
    incbin "dart_code.bin"
