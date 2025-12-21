.PHONY: all

all: assemble disk qemu

assemble:
	nasm -f bin loader.s -o loader.bin
	nasm -f bin kernel.s -o kernel.bin

disk:
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd if=loader.bin of=disk.img conv=notrunc bs=512 count=1 seek=0 
	dd if=kernel.bin of=disk.img conv=notrunc bs=512 count=1 seek=1

qemu:
	qemu-system-i386 -fda disk.img

