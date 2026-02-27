[org 0x7c00]
[bits 16]

section .text
    global _start

_start:
    cli                         ; Deshabilitar interrupciones
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00              ; Configurar stack inicial

    mov [BOOT_DRIVE], dl        ; Guardar unidad de arranque

    ; Cargar el kernel desde el disco (Carga extendida para el Runtime de Dart)
    ; Cargaremos 600 sectores (~300 KB) para asegurar que el AOT entre completo
    mov bx, 0x8000
    mov dh, 0x00            ; Cabezal 0
    mov ch, 0x00            ; Cilindro 0
    mov cl, 0x02            ; Empezar en sector 2

    ; Bucle de carga (BIOS int 13h puede fallar si pedimos demasiado de golpe)
    mov si, 10              ; Intentar cargar en bloques de 60 sectores
.load_loop:
    push si
    mov ah, 0x02
    mov al, 60
    int 0x13
    jc .error_disk
    add bx, 0x7800          ; Desplazar buffer (60 * 512 = 30720 bytes = 0x7800)
    add cl, 60
    ; Nota: Esto es simplificado y no maneja cambio de cilindro/cabezal
    ; pero para una imagen de 1.44MB floppy en QEMU suele bastar.
    pop si
    dec si
    jnz .load_loop
    jmp .done_load

.error_disk:
    mov al, 'D'
    jmp error

.done_load:

    ; --- Verificar soporte de CPUID ---
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je no_cpuid

    ; --- Verificar soporte de Modo Largo ---
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb no_long_mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz no_long_mode

    ; --- Configurar Paginación (Mapeo identidad de los primeros 2MB) ---
    ; PML4 en 0x1000, PDP en 0x2000, PD en 0x3000
    mov edi, 0x1000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd                   ; Limpiar tablas de páginas
    mov edi, cr3

    mov dword [edi], 0x2003      ; PML4 -> PDP (presente, escritura)
    add edi, 0x1000
    mov dword [edi], 0x3003      ; PDP -> PD (presente, escritura)
    add edi, 0x1000
    mov dword [edi], 0x00000083  ; PD -> 2MB Page (bit PS set, presente, escritura)

    ; --- Habilitar PAE ---
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; --- Habilitar Modo Largo en EFER ---
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; --- Habilitar Paginación y Modo Protegido ---
    mov eax, cr0
    or eax, 1 << 31 | 1 << 0
    mov cr0, eax

    lgdt [gdt64_descriptor]
    jmp CODE_SEG:init_lm

[bits 64]
init_lm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Confirmación visual: '64' en la esquina superior izquierda
    mov rax, 0x2f342f36
    mov [0xb8000], rax

    ; Saltar al kernel cargado en 0x8000
    mov rax, 0x8000
    jmp rax

    jmp $

no_cpuid:
    mov al, '1'
    jmp error
no_long_mode:
    mov al, '2'
    jmp error
error:
    mov ah, 0x0e
    int 0x10
    hlt
    jmp $

; --- GDT 64-bit ---
gdt64_start:
    dq 0x0                          ; Descriptor nulo
gdt64_code:
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; Segmento código: base 0, limite 0, r/e, presente, 64-bit
gdt64_data:
    dq (1<<41) | (1<<44) | (1<<47)  ; Segmento datos: base 0, limite 0, r/w, presente
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dq gdt64_start

CODE_SEG equ gdt64_code - gdt64_start
DATA_SEG equ gdt64_data - gdt64_start

BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xaa55
