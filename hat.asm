[bits 64]

section .text
    global _start
    global drawChar
    global io_wait
    global outb
    global clearScreen
    global malloc_bump

_start:
    ; Configurar el stack para el Kernel
    mov rsp, 0x90000
    mov rbp, rsp

    ; Este es el punto de entrada del Kernel en 0x8000
    ; Primero limpiamos la pantalla
    mov rdi, 0x07 ; Gris sobre negro
    call clearScreen

    ; Imprimimos el mensaje de "Dart Kernel" para confirmar carga
    mov rdi, 0xB8000
    add rdi, 160 ; Segunda línea
    mov rsi, 'D'
    mov rdx, 0x0B ; Cyan
    call drawChar

    ; Intentamos llamar al código de Dart (simulado/extraído)
    ; En una implementación real, aquí buscaríamos el offset de kernelMain

    jmp $

; drawChar(int address, int charCode, int color)
; RDI: address (dirección de memoria)
; RSI: charCode (código ASCII)
; RDX: color (atributo de color)
drawChar:
    push rbp
    mov rbp, rsp

    ; Preparamos el valor de 16 bits para la memoria VGA: [Color][Carácter]
    mov rax, rdx
    and rax, 0xFF
    shl rax, 8
    mov rbx, rsi
    and rbx, 0xFF
    or rax, rbx

    ; Escribimos en la dirección especificada
    mov [rdi], ax

    pop rbp
    ret

; clearScreen(int color)
; RDI: color
clearScreen:
    push rbp
    mov rbp, rsp

    mov rax, rdi
    and rax, 0xFF
    shl rax, 8
    ; Espacio en blanco con el color de fondo
    or rax, 0x20

    mov rdi, 0xB8000
    mov ecx, 80 * 25
.loop:
    mov [rdi], ax
    add rdi, 2
    loop .loop

    pop rbp
    ret

; outb(uint16_t port, uint8_t val)
; RDI: port, RSI: val
outb:
    mov dx, di
    mov al, sil
    out dx, al
    ret

io_wait:
    mov al, 0
    out 0x80, al
    ret

; Runtime Mínimo: Bump Allocator
section .data
    heap_ptr dq 0x100000 ; El heap comienza en el 1MB

section .text
malloc_bump:
    ; RDI: tamaño solicitado
    mov rax, [heap_ptr]     ; Retornar la dirección actual
    add [heap_ptr], rdi     ; Avanzar el puntero
    ret
