#!/bin/bash
#
# Jonas Fuhrmann
version="0.1 Wed Mar 06 23:40 GMT 2019"
#
# -------------------------------------------------
usage()
{
    cat <<HERE
Usage:
    $(basename $0) [-h | --help] This help text
    
    $(basename $0) [--version] Version of this script
    
    $(basename $0) BINARY
    Converts a binary to a memory declaration in VHDL and creates a corresponding package file
    This can be used to load compiled programs
HERE
}
# -------------------------------------------------
version()
{
    echo "$(basename $0) Version $version running on [$(uname)]"
}
# -------------------------------------------------
convert()
{
    prefix="library IEEE;
    use IEEE.std_logic_1164.all;

package RAM_CONTENT is
    --! @brief Used for iCE40up5k Block RAM initialization
    type MEMORY_TYPE is array(natural range <>) of std_logic_vector(7 downto 0);
    
    constant EBRAM : MEMORY_TYPE(0 to 4*2**11 + 4*2**10 + 4*2**9 -1) := (\n"
    
    # INFO: for some reason newline does not work with hexdump and string variables
    vhdltext=$vhdltext$(hexdump -v -e '1/1 "x\\x22%02x\\x22" ", "' $infile)
    
    postfix="
    others => (others => '0'));
    
    --! @brief Some synthesis tools (e.g. Synplify Pro) don't support unconstrained arrays on generic assigments, constants are then needed as a workaround
    constant INSTRUCTION_EBRAM  : MEMORY_TYPE(0 to 4*2**11-1) := EBRAM(0 to 4*2**11-1);
    constant DATA_EBRAM0        : MEMORY_TYPE(0 to 4*2**10-1) := EBRAM(4*2**11 to 4*2**11 + 4*2**10-1);
    constant DATA_EBRAM1        : MEMORY_TYPE(0 to 4*2** 9-1) := EBRAM(4*2**11 + 4*2**10 to 4*2**11 + 4*2**10 + 4*2**9-1);
    
end package RAM_CONTENT;"
    
    
    echo -e "${prefix}    ${vhdltext}${postfix}" > $outfile
}
# #############################################################
# main
# check for options
##

if [ $# -lt 1 ]; then
    echo "Too few arguments!"
    exit 1
else
    case $1 in
        "-h" | "--help" )
            usage
            exit 0
        ;;
        "--version" )
            version
            exit 0
        ;;
        * )
            if [ $# -eq 1 ]; then
                # set input and outpu files
                infile=$1
                outfile="RAM_CONTENT.vhdl"
                
                # convert binary to vhdl
                convert
                exit 0
            else
                echo "Too many arguments!"
                exit 1
            fi
        esac
fi
