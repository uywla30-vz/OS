#!/bin/bash
set -e

echo "--- Iniciando construcción de MiniOS Dart ---"

# 1. Obtener NASM si no existe
if ! command -v nasm &> /dev/null; then
    echo "NASM no encontrado, descargando binario temporal..."
    mkdir -p .build_tools
    curl -L http://archive.ubuntu.com/ubuntu/pool/universe/n/nasm/nasm_2.15.05-1_amd64.deb -o .build_tools/nasm.deb
    cd .build_tools && ar x nasm.deb && tar -xf data.tar.xz && cd ..
    NASM=./.build_tools/usr/bin/nasm
else
    NASM=nasm
fi

# 2. Ensamblar Bootloader
echo "Ensamblando boot.asm..."
$NASM -f bin boot.asm -o boot.bin

# 3. Ensamblar HAT
echo "Ensamblando hat.asm..."
$NASM -f elf64 hat.asm -o hat.o

# 4. Enlazar Kernel
echo "Enlazando Kernel..."
ld -m elf_x86_64 -Ttext 0x8000 hat.o -o kernel.elf
objcopy -O binary kernel.elf kernel.bin

# 5. Generar Imagen Final
echo "Generando os.img..."
cat boot.bin kernel.bin > os.img
truncate -s 1440k os.img

echo "--- Construcción completada: os.img listo ---"
echo "Para ejecutar: qemu-system-x86_64 -drive format=raw,file=os.img"
