--!@file   alu_TB.vhdl
--!@brief  Contains TB for the alu
--!@author Felix Lorenz
--!@date   2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
   -- use ieee.std_logic_textio.all;
library STD;
    use STD.textio.all;

use WORK.riscv_pack.all;

entity alu_TB is 
end entity alu_TB;

architecture TB of alu_TB is
    
    component dut is
    port(
        OPB         : in DATA_TYPE;
        OPA         : in DATA_TYPE;
        EX_CNTRL_IN : in EX_CNTRL_TYPE;
        
        Flags       : out FLAGS_TYPE;
        Resu        : out DATA_TYPE
    );
    end component dut;
    for all : dut use entity work.ALU(beh);
    
    --Input
    signal OPB_s : DATA_TYPE := (others => '0');
    signal OPA_s : DATA_TYPE := (others => '0');
    signal ECI_s : EX_CNTRL_TYPE := EX_CNTRL_NOP;
    --Output
    signal FLG_s : FLAGS_TYPE;
    signal RES_s : DATA_TYPE;
    
    constant WAIT_TIME : time := 10 ns;
    
begin

    dut_i : dut
    port map(
        OPB_s,
        OPA_s,
        ECI_s,
        FLG_s,
        RES_s
    );
    
    test:
    process is
        variable test_id    : natural;
        variable test_state : boolean := true;
        variable wlb        : line;
        
        procedure alu_test(
            opa     : in integer; 
            opb     : in integer; 
            funct7  : in FUNCT7_TYPE;
            funct3  : in FUNCT3_TYPE;
            opcode  : in OP_CODE_TYPE;
            flg_exp : in FLAGS_TYPE;   --VZNC
            res_exp : in integer
        ) is
            variable areFlagsCorrect : boolean;
            variable isResultCorrect : boolean;
            variable wasTestSuccesful: boolean;
            variable wlb             : line;
        begin
            OPB_s <= std_logic_vector(to_signed(opb, DATA_WIDTH));
            OPA_s <= std_logic_vector(to_signed(opa, DATA_WIDTH));
            ECI_s <= funct7 & funct3 & OP_CODE_TYPE_TO_BITS(opcode);
            wait for WAIT_TIME;
            areFlagsCorrect := FLG_s = flg_exp;
            isResultCorrect := RES_s = std_logic_vector(to_signed(res_exp, DATA_WIDTH));
            wasTestSuccesful:= areFlagsCorrect and isResultCorrect;
            
            write(wlb, string'( "### " ));
            
            if test_id < 10 then
                write(wlb, string'( "000" ));
            elsif test_id < 100 then
                write(wlb, string'( "00" ));
            elsif test_id < 1000 then
                write(wlb, string'( "0" ));
            end if;      
            
            write(wlb, integer'image(test_id));
            write(wlb,         string'( " | " ) );
            
            if wasTestSuccesful then
                write(wlb,        string'( "success |  none  ###" ));
            else
                write(wlb,        string'( "failed  |" ));
                if not isResultCorrect then
                    write(wlb,             string'( " result ###" ));
                else
                    write(wlb,             string'( "  flag  ###" ));
                end if;
            end if;        
            
            writeline(output, wlb);
            
            test_state := test_state and wasTestSuccesful;
            test_id := test_id + 1;
        end alu_test;
    
    begin
        write(wlb,     string'( "###############################" ));  writeline(output, wlb);
        write(wlb,     string'( "##### TEST BRANCH RESULTS #####" ));  writeline(output, wlb);
        write(wlb,     string'( "###############################" ));  writeline(output, wlb);
        write(wlb,     string'( "###  ID  | result  | reason ###" ));  writeline(output, wlb);
        write(wlb,     string'( "###------|---------|--------###" ));  writeline(output, wlb);
        
        -- tests to determine the correct function of the arithmetic units in the alu
        -- flags   V Z N C
        -- test adder
        --test_id 0 to 4
        alu_test( 13,           17,         ADD_FUNCT7, ADD_FUNCT3, opo,    "0000", 30          );     -- normal       
        alu_test( 0,            0,          ADD_FUNCT7, ADD_FUNCT3, opo,    "0100", 0           );     -- zero
        alu_test( 127,          -507,       ADD_FUNCT7, ADD_FUNCT3, opo,    "0010", -380        );     -- negative
        alu_test( 2147483647,   1,          ADD_FUNCT7, ADD_FUNCT3, opo,    "1010", -2147483648 );     -- overflow
        alu_test( -1,           2,          ADD_FUNCT7, ADD_FUNCT3, opo,    "0001", 1           );     -- carry
         
        -- test sub, note: C=1 means no borrow, normal subtraction, 
        --test_id 5 to 9
        alu_test( 128,          65,         SUB_FUNCT7, SUB_FUNCT3, opo,    "0001", 63          );   -- normal
        alu_test( 654321,       654321,     SUB_FUNCT7, SUB_FUNCT3, opo,    "0101", 0           );   -- zero
        alu_test( -103,         881,        SUB_FUNCT7, SUB_FUNCT3, opo,    "0011", -984        );   -- negative
        alu_test( -2147483648,  1,          SUB_FUNCT7, SUB_FUNCT3, opo,    "1001", 2147483647  );   -- overflow
        alu_test( 0,            -1111,      SUB_FUNCT7, SUB_FUNCT3, opo,    "0000", 1111        );   -- carry (missing)
        
        
        write(wlb,     string'( "###############################" ));  writeline(output, wlb);
        write(wlb,     string'( "###############################" ));  writeline(output, wlb);        
        if test_state then
            write(wlb, string'( "#### ALU WORKS AS EXPECTED ####" ));  writeline(output, wlb);
            write(wlb, string'( "####       Good Job!       ####" ));  writeline(output, wlb);
        else
            write(wlb, string'( "####    ALU WON'T WORK     ####" ));  writeline(output, wlb);
            write(wlb, string'( "####     Back to work!     ####" ));  writeline(output, wlb);
        end if; 
            
        write(wlb,     string'( "###############################" ));  writeline(output, wlb);
        
        wait;
        
    end process test;

end architecture TB;