# MiniOS Dart v0.2.1 - Manual de Operaciones

Este proyecto es la materialización de un sistema operativo Bare Metal donde la lógica central reside en **Dart**, soportada por una capa mínima de Assembly (HAT).

## Cambios en v0.2.1 (The Dart Core Update)
- **Dart First**: El código en `kernel.dart` ahora define la arquitectura de la terminal y el procesamiento de comandos.
- **HAT Robusto**: El driver de teclado en Assembly ha sido rediseñado para evitar desbordamientos y fallos de memoria (`r13` fix).
- **Interactividad Real**: Se han añadido comandos `help`, `about` y `clear` (simulado) además de `firm`.
- **Soporte de Teclado Completo**: Ahora puedes borrar (Backspace) y usar Espacios.

## Cómo Ejecutar
1. **Compilar**:
   ```bash
   ./build.sh
   ```
2. **Arrancar**:
   ```bash
   qemu-system-x86_64 -drive format=raw,file=os.img
   ```

## Comandos Disponibles en la Terminal
Escribe estos comandos y presiona **ENTER**:
- `firm`: Muestra la versión y el autor (Emmanuel).
- `help`: Lista los comandos disponibles.
- `dart`: **Comando Experimental**. Salta directamente al código máquina generado por el compilador de Dart (AOT) inyectado en el kernel.
- `about`: Muestra la filosofía del proyecto.

## Resolución de Problemas
- **Pantalla Negra/Oscura**: Si al presionar una tecla la pantalla cambia, asegúrate de estar usando la versión `v0.2.1` donde se corrigió el fallo del registro `r13`.
- **QEMU Accessibility Warning**: Ignora el mensaje de "Couldn't connect to accessibility bus", es un aviso de GTK en Linux que no afecta al emulador.

---
*Este sistema demuestra que Dart puede gobernar el hardware de forma segura y eficiente.*
