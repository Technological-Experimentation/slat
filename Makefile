default: all

.PHONY: all clean

C_SOURCES = $(shell find . -type f -name '*.c' | grep -v "modules")
H_SOURCES = $(shell find . -type f -name '*.h' | grep -v "modules")
A_SOURCES = $(shell find . -type f -name '*.asm' | grep -v "modules")

OBJ = ${C_SOURCES:.c=.o} ${A_SOURCES:.asm=.o}

ARCH = x86_64

CC = clang
LD = gcc
AS = nasm

BUILD_DIR = build

KNL_TARGET = ${BUILD_DIR}/kslate.elf

CFLAGS =	-target ${ARCH}-unknown-none	\
			-ggdb							\
			-nostdlib						\
			-fno-stack-protector			\
			-nostartfiles					\
			-nodefaultlibs					\
			-Wall							\
			-Wextra							\
			-Wpedantic						\
			-ffreestanding					\
			-std=gnu11						\
			-mcmodel=kernel					\
			-I.								\
			-Ilib							\
			-fno-pic						\
			-mno-red-zone					\
			-mno-sse						\
			-mno-sse2						\
			#-fsanitize=undefined			\

QEMUFLAGS =	-m 3G			\
			-boot menu=on	\
			-hda slate.img	\
			-smp cpus=4		\
			-machine q35	\
			-name slate		\

O_LEVEL =	2

LDFLAGS =	-no-pie					\
			-ffreestanding			\
			-O${O_LEVEL}			\
			-nostdlib				\
			-z max-page-size=0x1000	\
			-T boot/linker.ld		\

./tmp/limine.efi:
	@echo "Downloading latest limine release!"
	@mkdir -p ./tmp/
	@curl -L https://github.com/limine-bootloader/limine/raw/latest-binary/BOOTX64.EFI -o ./tmp/limine.efi

./tmp/ovmf:
	@echo "Downloading OVMF!"
	@mkdir -p ./tmp/ovmf
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_CODE-pure-efi.fd -o ./tmp/ovmf/OVMF_CODE-pure-efi.fd
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_VARS-pure-efi.fd -o ./tmp/ovmf/OVMF_VARS-pure-efi.fd


all: clean
	mkdir ${BUILD_DIR}
	mkdir ${BUILD_DIR}/objects
	make ${KNL_TARGET}
	mv **/*.o ${BUILD_DIR}/objects

${KNL_TARGET}: ${OBJ} symlist
	${LD} ${LDFLAGS} ${OBJ} sys/symlist.o -o $@
	./gensyms.sh
	${CC} -x c ${CFLAGS} -c sys/symlist.gen -o sys/symlist.o
	${LD} ${LDFLAGS} ${OBJ} sys/symlist.o -o $@

symlist:
	echo '#include <sys/symlist.h>' > sys/symlist.gen
	echo 'struct symlist_t symlist[] = {{0xffffffffffffffff,""}};' >> sys/symlist.gen
	${CC} -x c ${CFLAGS} -c sys/symlist.gen -o sys/symlist.o

DISK = ./slate.img
QEMUFLAGS_RAW = -machine q35 -smp 4 -m 1G -cpu qemu64 -drive if=pflash,format=raw,unit=0,file="tmp/ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file="tmp/ovmf/OVMF_VARS-pure-efi.fd" -serial stdio
QEMUFLAGS = $(QEMUFLAGS_RAW) -drive file=$(DISK)

img: all ./tmp/limine.efi
	dd if=/dev/zero of=$(DISK) bs=512 count=93750
	mkfs.vfat -F 32 $(DISK)

	mcopy -i $(DISK) -s ./build/kslate.elf ::
	mcopy -i $(DISK) -s limine.cfg ::

	mmd -i $(DISK) ::/EFI
	mmd -i $(DISK) ::/EFI/BOOT
	mcopy -i $(DISK) -s ./tmp/limine.efi ::/EFI/BOOT/BOOTX64.EFI

	mcopy -i $(DISK) -s startup.nsh ::/startup.nsh

run: img ./tmp/ovmf
	qemu-system-x86_64 $(QEMUFLAGS)

%.o: %.c
	${CC} ${CFLAGS} -c $< -o $@

%.o: %.asm
	nasm -f elf64 -F dwarf -g -o $@ $<

clean:
	rm -rf ${BUILD_DIR}
