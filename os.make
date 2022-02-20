# $^ - all dependencies
# $< - the first dependency
# $@ - the target file

# making the disk image
tmp1.img: boot/bootsec.bin kernel/kernel.bin 1,44mb.img	
	cat $^ > tmp.img
	dd if=tmp.img of=OS.img bs=512 count=2880

# make the boot sector
boot/bootsec.bin: boot/bootsec.asm
	nasm $< -f bin -I 'boot/' -o $@

kernel/kernel.bin: kernel/kernel.s
	nasm $< -f bin -I 'kernel/' -o $@ 
