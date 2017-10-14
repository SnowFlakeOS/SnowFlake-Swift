arch ?= x86_64
boot := build/boot-$(arch).bin
loader := build/loader-$(arch).elf
kernel := build/kernel-$(arch).bin
kernel_elf := build/kernel-$(arch).elf
img := build/os-$(arch).img
iso := build/os-$(arch).iso

linker_script := src/arch/$(arch)/linker.ld

boot_source_file := src/arch/$(arch)/boot.asm
loader_source_file := src/arch/$(arch)/loader.asm

stdlib_c_source_files := $(shell find src/stdlib -name "*.c")
stdlib_c_object_files := $(patsubst src/stdlib/%.c, \
    build/stdlib/%.o, $(stdlib_c_source_files))
stdlib_as_source_files := $(shell find src/stdlib -name "*.S")
stdlib_as_object_files := $(patsubst src/stdlib/%.S, \
    build/stdlib/%.o, $(stdlib_as_source_files))

cxx_source_files := $(shell find src -name "*.cpp")
cxx_object_files := $(patsubst src/%.cpp, \
    build/%.cpp, $(cxx_source_files))

swift_source_files := src/kernel/main.swift $(shell find src -name "*.swift" ! -name "main.swift")
swift_bc_files := $(patsubst src/%.swift, \
    build/%.bc, $(swift_source_files))
swift_object_files := $(patsubst src/%.swift, \
    build/%.o, $(swift_source_files))

libc_source_files := $(shell find src/libc -name "*.c")
libc_object_files := $(patsubst src/libc/%.c, \
    build/libc/%.o, $(libc_source_files))

SWIFT = swiftc
SWIFTFLAGS = -emit-library -emit-bc -static-stdlib -module-name SnowWhiteOS

CXX = clang++
CXXFLAGS = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -nostdlib -std=c++11 -Isrc/include

CC = clang
CFLAGS = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -nostdlib -Isrc/include/libc

AS = as

.PHONY: all clean run img

all: $(boot) $(kernel)

clean:
	@rm -r build

run: $(img)
	@qemu-system-x86_64 $(img)

img: $(img)

iso: $(iso)

$(img): $(boot) $(kernel)
	@mkdir -p $(shell dirname $@)
	@dd if=/dev/zero of=$(img) bs=512 count=2880
	@dd if=$(boot) of=$(img) conv=notrunc
	@dd if=$(kernel) of=$(img) conv=notrunc bs=512 seek=1

$(iso): $(img)
	@mkdir -p build/cdcontents
	@cp $(img) build/cdcontents
	@mkisofs -o $(iso) -V SnowWhiteOS -b $(img) build/cdcontents

$(boot):
	@mkdir -p $(shell dirname $@)
	@nasm -f bin $(boot_source_file) -o $(boot)

$(loader):
	@mkdir -p $(shell dirname $@)
	@nasm -f elf64 $(loader_source_file) -o $(loader)

$(kernel): $(loader) $(libc_object_files) $(stdlib_c_object_files) $(stdlib_as_object_files) $(cxx_object_files) $(swift_object_files) $(linker_script)
	@ld -T $(linker_script) -o $(kernel_elf) $(loader) $(libc_object_files) $(stdlib_c_object_files) $(stdlib_as_object_files) $(cxx_object_files) $(swift_object_files) 
	@objcopy $(kernel_elf) -O binary $(kernel)

# compile stdlib c files
build/stdlib/%.o: src/stdlib/%.c
	@mkdir -p $(shell dirname $@)
	@$(CC) $(CFLAGS) -c $< -o $@
	
# compile stdlib as files
build/stdlib/%.o: src/stdlib/%.S
	@mkdir -p $(shell dirname $@)
	@$(AS) $< -o $@

# compile swift files
$(swift_object_files):
	@$(foreach var,$(swift_bc_files),mkdir -p $(shell dirname $(var));)
	@$(SWIFT) $(SWIFTFLAGS) $(swift_source_files)
	@$(foreach var,$(swift_bc_files),mv $(shell basename $(var)) $(var);)
	@$(CC) $(CFLAGS) -c $(swift_bc_files)
	@$(foreach var,$(swift_object_files),mv $(shell basename $(var)) $(var);)

# compile cpp files
$(cxx_object_files):
	@mkdir -p $(shell dirname $@)
	$(foreach var,$(cxx_source_files),$(CXX) $(CXXFLAGS) -c $(var) -o $(patsubst %.cpp,%.o,$(var));)

# compile libc files
build/libc/%.o: src/libc/%.c
	@mkdir -p $(shell dirname $@)
	@$(CC) $(CFLAGS) -c $< -o $@
