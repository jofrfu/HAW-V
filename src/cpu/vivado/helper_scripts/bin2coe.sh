#!/bin/bash
# 
# Jonas Fuhrmann
version="0.1 Do Dec 21 22:58 GMT 2017"
#
# -------------------------------------------------------------
usage()
{
cat <<HERE
Usage:
	$(basename $0) [-h | --help] This help text
	
	$(basename $0) BINARY COEFILE
	Converts a binary to a Xilinx COE file format aligned on 32Bit
	
	$(basename $0) [OPTIONS] COMPILER OBJCOPY SOURCE OUTPUT
	Uses a given compiler to compile a source file,
	uses a given objcopy to convert the compilers output file to a binary file
	
Options:
	-b --binary     outputs the binary of objcopy
	-c --convert    outputs a converted COE file
HERE
}
# -------------------------------------------------------------
version()
{
    echo "$(basename $0) Version $version running on [$(uname)]"
}
# -------------------------------------------------------------
convert()
{   
    coetext="memory_initialization_radix=16;\nmemory_initialization_vector=\n"
    # INFO: for some reason newline does not work with hexdump and string variables
    coetext=$coetext$(hexdump -v -e '4/1 "%02x" ", "' $infile)
    # remove all from last comma, concat a semicolon
    coetext=${coetext%,*}";"
    # replace all spaces with newline, work around for hexdump 'bug'
    coetext=${coetext// /"\n"}
    echo -e $coetext > $outfile
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
        "-b" | "--binary" )
            # expecting 5 arguments
            if [ $# -lt 5 ]; then
                echo "Too few arguments!"
                exit 1
            elif [ $# -gt 5 ]; then
                echo "Too many arguments!"
                exit 1
            fi
            
            # paths to executables
            compilerpath=$2
            objcopypath=$3
            
            # paths to files
            sourcefile=$4
            elffile="temp.elf"
            outfile=$5
            
            # compile source file
            $compilerpath -o $elffile $sourcefile
            
            # objcopy for .elf to .bin conversion
            $objcopypath -O binary $elffile $outfile
            
            # delete .elf file
            rm $elffile
            
            exit 0
        ;;
        "-c" | "--convert" )
        
            # expecting 5 arguments
            if [ $# -lt 5 ]; then
                echo "Too few arguments!"
                exit 1
            elif [ $# -gt 5 ]; then
                echo "Too many arguments!"
                exit 1
            fi
            
            # paths to executables
            compilerpath=$2
            objcopypath=$3
            
            # paths to files
            sourcefile=$4
            elffile="temp.elf"
            infile="temp.bin"
            outfile=$5
            
            # compile source file
            $compilerpath -o $elffile $sourcefile
            
            # objcopy for .elf to .bin conversion
            $objcopypath -O binary $elffile $infile
            
            # delete .elf file
            rm $elffile
            
            # convert binary to coe
            convert
            
            #delete .bin file
            rm $infile
            
            exit 0
        ;;
        * )
            if [ $# -eq 2 ]; then
                # set input and output files
                infile=$1
                outfile=$2
    
                # convert binary to coe
                convert
                exit 0
            else
                echo "Too many arguments!"
                exit 1
            fi
    esac
fi
exit 0;