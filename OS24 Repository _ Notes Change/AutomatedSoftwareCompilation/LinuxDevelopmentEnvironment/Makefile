# Variables:
bootloader_directory = ../../CodeSources/AssemblyLanguage/16Bits/BIOS/MasterBootRecord/
bootloader_assembly_language_code_sources = 16Bits_Bootloader

kernel_directory = ../../CodeSources/Kernel/
kernel_assembly_language_code_sources = Kernel

operating_system_directory = ../../CodeSources/OperatingSystem/
operating_system_c_language_code_sources = OperatingSystem
operating_system_cross_compiler_flags = -std=c17 -m32 -march=i386 -ffreestanding -fno-builtin -nostdinc -O1

binary_outputs_directory = ../../Build/Outputs/BinaryFormat/
object_outputs_directory = ../../Build/Outputs/ObjectFormat/
floppy_outputs_directory = ../../Build/Outputs/FloppyFormat/



Clear_Build:
	@-cd $(floppy_outputs_directory) && rm *.flp
	@-cd $(object_outputs_directory) && rm *.o
	@-cd $(binary_outputs_directory) && rm *.bin
	
$(bootloader_assembly_language_code_sources):
	nasm -f bin $(bootloader_directory)$@.asm -o $@.bin

$(kernel_assembly_language_code_sources):
	nasm -f elf32 $(kernel_directory)$@.asm -o $@.o

$(operating_system_c_language_code_sources):
	clang -c $(operating_system_cross_compiler_flags) -o $@.o $(operating_system_directory)$@.c

# Instructions:
16Bits_OS24: Clear_Build $(bootloader_assembly_language_code_sources) $(kernel_assembly_language_code_sources) $(operating_system_c_language_code_sources)
	ld -m elf_i386 -T../LinkingInputFiles/KernelToOperatingSystem.ld
	cat 16Bits_Bootloader.bin OS24.bin > OS24.flp
	@-mv *.flp $(floppy_outputs_directory)
	@-mv *.o $(object_outputs_directory)
	@-mv *.bin $(binary_outputs_directory)