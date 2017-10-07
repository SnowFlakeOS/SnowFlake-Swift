arch ?= x86_64
boot := build/boot-$(arch).bin
loader := build/loader-$(arch).elf
kernel := build/kernel-$(arch).bin
img := build/os-$(arch).img

linker_script := src/arch/$(arch)/linker.ld

swift_source_files := src/kernel/main.swift $(shell find src/kernel -name "*.swift" ! -name "main.swift")
swift_object_files := $(patsubst src/kernel/%.swift, \
    build/kernel/%.o, $(swift_source_files))

boot_source_file := src/arch/$(arch)/boot.asm
loader_source_file := src/arch/$(arch)/loader.asm

stdlib_c_source_files := $(shell find src/stdlib -name "*.c")
stdlib_c_object_files := $(patsubst src/stdlib/%.c, \
    build/stdlib/%.o, $(stdlib_c_source_files))
stdlib_as_source_files := $(shell find src/stdlib -name "*.S")
stdlib_as_object_files := $(patsubst src/stdlib/%.S, \
    build/stdlib/%.o, $(stdlib_as_source_files))
stdlib_swift_source_files := $(shell find src/stdlib -name "*.swift")
stdlib_swift_object_files := $(patsubst src/stdlib/%.swift, \
    build/stdlib/%.o, $(stdlib_swift_source_files))

SWIFT = swiftc
SWIFTFLAGS = -emit-ir -parse-as-library

CC = clang
CFLAGS = -ffreestanding -Wno-override-module

CXX = clang++
CXXFLAGS = -ffreestanding -Isrc/include

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

$(kernel): $(loader) $(stdlib_c_object_files) $(stdlib_as_object_files) $(stdlib_swift_object_files) $(swift_object_files) $(linker_script)
	@ld -T $(linker_script) -o $(kernel) $(loader) $(stdlib_c_object_files) $(stdlib_as_object_files) $(stdlib_swift_object_files) $(swift_object_files)

# compile swift files
build/kernel/%.o: src/kernel/%.swift
	@mkdir -p $(shell dirname $@)
	$(SWIFT) $(SWIFTFLAGS) $< -o ${@:.o=}.ll
	@$(CC) $(CFLAGS) -c ${@:.o=}.ll -o $@

# compile stdlib c files
build/stdlib/%.o: src/stdlib/%.c
	@mkdir -p $(shell dirname $@)
	@$(CC) $(CFLAGS) -c $< -o $@
	
# compile stdlib as files
build/stdlib/%.o: src/stdlib/%.S
	@mkdir -p $(shell dirname $@)
	@$(AS) $< -o $@

# compile stdlib swift files
build/stdlib/%.o: src/stdlib/%.swift
	@mkdir -p $(shell dirname $@)
	@$(SWIFT) $(SWIFTFLAGS) $< -o ${@:.o=}.ll
	@$(CC) $(CFLAGS) -c ${@:.o=}.ll -o $@
