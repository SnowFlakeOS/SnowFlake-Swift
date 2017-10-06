arch ?= x86_64
boot := build/boot-$(arch).bin
loader := build/loader-$(arch).elf
kernel := build/kernel-$(arch).bin
libswift := build/runtime/libswift.so
img := build/os-$(arch).img

linker_script := src/arch/$(arch)/linker.ld

swift_source_files := src/kernel/main.swift $(shell find src/kernel -name "*.swift" ! -name "main.swift")
swift_object_files := $(patsubst src/kernel/%.swift, \
    build/kernel/%.o, $(swift_source_files))

boot_source_file := src/arch/$(arch)/boot.asm
loader_source_file := src/arch/$(arch)/loader.asm

runtime_c_source_files := $(shell find src/runtime -name "*.c")
runtime_c_object_files := $(patsubst src/runtime/%.c, \
    build/runtime/%.o, $(runtime_c_source_files))
runtime_as_source_files := $(shell find src/runtime -name "*.S")
runtime_as_object_files := $(patsubst src/runtime/%.S, \
    build/runtime/%.o, $(runtime_as_source_files))

SWIFT = swiftc
SWIFTFLAGS = -emit-library -emit-bc

CC = clang
CFLAGS = -ffreestanding

AS = as

.PHONY: all clean run img

all: $(boot) $(kernel)

clean:
	@rm -r build

run: $(img)
	@qemu-system-x86_64 $(img)

img: $(img)

$(img): $(boot) $(kernel)
	@mkdir -p $(shell dirname $@)
	@dd if=/dev/zero of=$(img) bs=512 count=2880
	@dd if=$(boot) of=$(img) conv=notrunc
	@dd if=$(kernel) of=$(img) conv=notrunc bs=512 seek=1

$(boot):
	@mkdir -p $(shell dirname $@)
	@nasm -f bin $(boot_source_file) -o $(boot)

$(loader):
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 $(loader_source_file) -o $(loader)

$(libswift): $(runtime_c_object_files) $(runtime_as_object_files)
	@mkdir -p $(shell dirname $@)
	@$(CC) -shared $(runtime_as_object_files) $(runtime_c_object_files) -o $(libswift)

$(kernel): $(loader) $(libswift) $(swift_object_files) $(linker_script)
	@ld -T $(linker_script) -o $(kernel) $(loader) $(libswift) $(swift_object_files)

# compile swift files
build/kernel/%.o: src/kernel/%.swift
	@mkdir -p $(shell dirname $@)
	@$(SWIFT) $(SWIFTFLAGS) $< -o $@.bc
	@$(CC) $(CFLAGS) -c $@.bc -o $@

# compile runtime c files
build/runtime/%.o: src/runtime/%.c
	@mkdir -p $(shell dirname $@)
	@$(CC) $(CFLAGS) -c $< -o $@
	
# compile runtime as files
build/runtime/%.o: src/runtime/%.S
	@mkdir -p $(shell dirname $@)
	@$(AS) $< -o $@
