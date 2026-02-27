#!/bin/bash
set -e

echo "=== MiniOS Dart Builder v0.2.1 (The Real Integration) ==="

# 1. Herramientas
if [ ! -f "./nasm" ]; then
    echo "[1/5] Obteniendo NASM..."
    mkdir -p .tmp
    curl -L http://archive.ubuntu.com/ubuntu/pool/universe/n/nasm/nasm_2.15.05-1_amd64.deb -o .tmp/nasm.deb
    cd .tmp && ar x nasm.deb && tar -xf data.tar.xz && cd ..
    cp .tmp/usr/bin/nasm ./nasm
fi

# 2. Compilar Dart y extraer código máquina puro
echo "[2/5] Compilando Dart y extrayendo código máquina (AOT)..."
dart compile aot-snapshot kernel.dart
# Extraemos la sección .text que contiene las instrucciones ejecutables
objcopy -O binary --only-section=.text kernel.aot dart_code.bin

# 3. Ensamblar Sistema (HAT incluye dart_code.bin vía incbin)
echo "[3/5] Ensamblando Kernel (HAT + Inyección de Dart)..."
./nasm -f bin boot.asm -o boot.bin
./nasm -f bin hat.asm -o kernel.bin

# 4. Generar Imagen Final
echo "[4/5] Generando os.img..."
cat boot.bin kernel.bin > os.img
truncate -s 1440k os.img

# 5. Resumen
echo "[5/5] Construcción completada."
DART_SIZE=$(stat -c%s "dart_code.bin")
echo "-> Código Dart inyectado: $DART_SIZE bytes."
echo "-> Imagen lista: os.img"
echo ""
echo "Ejecución: qemu-system-x86_64 -drive format=raw,file=os.img"
