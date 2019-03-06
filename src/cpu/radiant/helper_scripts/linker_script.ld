ENTRY(_start)

MEMORY
{
    INST_EBRAM (wx) : ORIGIN = 0, LENGTH = 8K
    DATA_EBRAM (w)  : ORIGIN = 8K, LENGTH = 6K
    DATA_SPRAM (w)  : ORIGIN = 64K, LENGTH = 128K
}

__stack_size = 32K;
__heap_size = 32K;


SECTIONS
{
    .text : 
    {
        . = ALIGN(4);
        _stext = .;
        *(.text)
        _etext = .;
    } >INST_EBRAM
    
    .rodata : 
    {
        . = ALIGN(4);
        _srodata = .;
        *(.rodata) 
        _erodata = .;
    } >DATA_EBRAM
    
    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data)
        _edata = .;
    } >DATA_EBRAM
    
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(COMMON)
        _ebss = .;
    } >DATA_SPRAM
    
    .stack :
    {
        . = ALIGN(4);
        _sstack = .;
        . += __stack_size;
        _estack = .;;
    } >DATA_SPRAM
    
    .heap :
    {
        . = ALIGN(4);
        _sheap = .;
        . += __heap_size;
        _estack = .;
    } >DATA_SPRAM
}
