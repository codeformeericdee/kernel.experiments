OUTPUT_FORMAT(binary)

ENTRY(_start)

INPUT(Kernel.o OperatingSystem.o)

OUTPUT(OS24.bin)

SECTIONS
{
    . = 0x1000;

    .text :
    {
        *(.text*);
    }

    .bss :
    {
        *(.bss*);
    }

    .data :
    {
        *(.data*);
    }

    .rodata :
    {
        *(.rodata*);
    }
}