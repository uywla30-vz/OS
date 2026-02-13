#!/bin/bash
nasm -f bin os.asm -o os.img
echo "Build complete. Run with: qemu-system-x86_64 -drive format=raw,file=os.img"
