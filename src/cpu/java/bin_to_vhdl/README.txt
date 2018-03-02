1.  Compile with "javac BinToVhdl.java"
    if javac doesnt work: https://stackoverflow.com/questions/1678520/javac-not-working-in-windows-command-prompt
2.  start programm with "java -cp . BinToVhdl INPUT_FILE OUTPUT_FILE CONSTANT_NAME PACKAGE_NAME"
    INPUT_FILE:     binary file to be read
    OUTPUT_FILE:    text file to be put out (vhdl file)
    CONSTANT_NAME:  name of the constant vhdl byte array field generadted
    PACKAGE_NAME:   name of the package housing the constant byte field
    example "java -cp . BinToVhdl llcoolASM llcoolASM.vhdl TEST_FIELD testpkg"
    This will generate a vhdl file with a package testpkg and byte array named TEST_FIELD from the assembler programm contained in llcoolASM