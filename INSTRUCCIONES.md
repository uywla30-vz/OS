# Guía de Ejecución - MiniOS Dart

Este proyecto genera un sistema operativo mínimo (Bare Metal) que arranca en modo largo de 64 bits.

## Requisitos
- **QEMU** (qemu-system-x86_64)
- **NASM** (para compilar desde el código fuente)
- **Binutils** (ld, objcopy)

## Cómo ejecutar la imagen pre-compilada
Si ya tienes `os.img` en este directorio, simplemente ejecuta:
```bash
qemu-system-x86_64 -drive format=raw,file=os.img
```

## Cómo compilar desde cero
Hemos incluido un script automatizado `build.sh` que maneja las dependencias de NASM si no están en tu sistema:
```bash
./build.sh
```

## Estructura del Binario `os.img`
- **Sector 1 (512 bytes):** Bootloader (16-bit -> 64-bit).
- **Sector 2 en adelante:** Kernel (Punto de entrada en 0x8000).

## Nota sobre Dart
El código en `kernel.dart` es la base lógica. En este entorno experimental, el binario `os.img` utiliza la capa HAT para imprimir directamente en pantalla, simulando la ejecución del kernel que Dart controlará mediante la manipulación de su snapshot AOT.
