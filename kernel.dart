// kernel.dart
// MiniOS Kernel - Emmanuel

/**
 * Kernel escrito en Dart Puro para ejecución Bare Metal.
 *
 * Este código está diseñado para ser compilado a un Snapshot AOT.
 * Utilizamos el 'HAT' (Hardware Abstraction Tool) para realizar las
 * operaciones de I/O y acceso a memoria.
 */

void main() {
  bootSequence();
}

void bootSequence() {
  // El mensaje solicitado: 'Versión 0.1 - Creado por Emmanuel'
  // (Actualizado según la instrucción: 'Firm: MiniOS v0.1 - Emmanuel')
  final message = "Firm: MiniOS v0.1 - Emmanuel";

  // 0xB8000 es la dirección base de la memoria de video VGA en modo texto
  const int vgaAddress = 0xB8000;

  for (int i = 0; i < message.length; i++) {
    // Cada carácter ocupa 2 bytes (ASCII + Atributo)
    drawChar(vgaAddress + (i * 2), message.codeUnitAt(i), 0x07);
  }
}

/**
 * HAT Interface: drawChar
 * Esta función se enlaza con la implementación en Assembly (hat.asm).
 * En una manipulación real del runtime de Dart, interceptaríamos esta
 * llamada para que use el código nativo del HAT.
 */
void drawChar(int address, int charCode, int color) {
  // Placeholder para la integración con HAT
}
