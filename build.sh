#!/bin/bash
set -e

echo "=== MiniOS Dart Builder (v0.2) ==="

# 1. Obtener herramientas si faltan
if [ ! -f "./nasm" ]; then
    echo "Descargando NASM..."
    mkdir -p .tmp
    curl -L http://archive.ubuntu.com/ubuntu/pool/universe/n/nasm/nasm_2.15.05-1_amd64.deb -o .tmp/nasm.deb
    cd .tmp && ar x nasm.deb && tar -xf data.tar.xz && cd ..
    cp .tmp/usr/bin/nasm ./nasm
fi

# 2. Verificar Dart SDK
if ! command -v dart &> /dev/null; then
    echo "ERROR: Dart SDK no encontrado."
    echo "Por favor, instala Dart siguiendo las instrucciones en INSTRUCCIONES.md"
    exit 1
fi

# 3. Compilar Dart (AOT) para análisis
echo "Compilando Dart a AOT..."
dart compile aot-snapshot kernel.dart

# 4. Ensamblar componentes
echo "Ensamblando Bootloader y HAT..."
./nasm -f bin boot.asm -o boot.bin
./nasm -f elf64 hat.asm -o hat.o

# 5. Enlazar Kernel
echo "Enlazando Kernel (HAT + Dart Stub)..."
# Usamos el HAT como punto de entrada principal en 0x8000
ld -m elf_x86_64 -Ttext 0x8000 hat.o -o kernel.elf
objcopy -O binary kernel.elf kernel.bin

# 6. Construir Imagen
echo "Generando os.img..."
cat boot.bin kernel.bin > os.img
truncate -s 1440k os.img

echo "=== Construcción Exitosa ==="
echo "Ejecutar con: qemu-system-x86_64 -drive format=raw,file=os.img"
