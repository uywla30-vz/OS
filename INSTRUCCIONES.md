# MiniOS Dart v0.2 - Guía de Usuario

Este sistema es un Kernel real ejecutándose en Modo Largo (64-bit) sin dependencias de Linux o C.

## Novedades en v0.2
- **Teclado Interactivo:** Se ha implementado un driver PS/2 en la capa HAT.
- **Terminal Funcional:** Ahora puedes escribir comandos directamente.
- **Comando `firm`:** Al escribir `firm` y presionar ENTER, el sistema muestra la versión y el autor.

## Requisitos del Sistema
Para compilar y ejecutar este proyecto necesitas:
- **QEMU** (`qemu-system-x86_64`)
- **NASM** (El script `build.sh` lo descarga automáticamente si no está instalado)
- **Dart SDK** (Para compilar la lógica del kernel)

### Instalación de Dart en Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart.list
sudo apt-get update
sudo apt-get install dart
export PATH="$PATH:/usr/lib/dart/bin"
```

## Cómo Probar la Interactividad
1. Ejecuta el sistema en QEMU:
   ```bash
   qemu-system-x86_64 -drive format=raw,file=os.img
   ```
2. Una vez que veas el prompt `> `, escribe (en minúsculas):
   `f` `i` `r` `m`
3. Presiona la tecla **ENTER**.
4. Verás aparecer en amarillo: `Version 0.1 - Creado por Emmanuel`.

## Estructura Técnica
- `boot.asm`: Paso de 16-bit a 64-bit y carga del kernel.
- `hat.asm`: Capa de Abstracción de Hardware (VGA, Keyboard, I/O). Contiene el bucle principal de la terminal.
- `kernel.dart`: Lógica de alto nivel (compilada a AOT para análisis e integración futura).

---
*Emmanuel, este es el desarrollo de alto impacto prometido. Dart + Assembly en su estado más puro.*
