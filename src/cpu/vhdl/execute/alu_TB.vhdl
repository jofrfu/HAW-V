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
        --dummy:                                        alu_test(             ,           , XXX_FUNCT7, XXX_FUNCT3, opcod,    "0000",             , true );   --
        procedure alu_test(
            opa     : in integer; 
            opb     : in integer; 
            funct7  : in FUNCT7_TYPE;
            funct3  : in FUNCT3_TYPE;
            opcode  : in OP_CODE_TYPE;
            flg_exp : in FLAGS_TYPE;   --VZNC
            res_exp : in integer;
            no_flag : in boolean
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
            areFlagsCorrect := (FLG_s = flg_exp) or no_flag;
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
        -- test adder   flags behaviour are also tested here
        --test_id 0 to 4
        alu_test( 13          , 17        , ADD_FUNCT7, ADD_FUNCT3, opo,    "0000", 30          , false);     -- normal       
        alu_test( 0           , 0         , ADD_FUNCT7, ADD_FUNCT3, opo,    "0100", 0           , false);     -- zero
        alu_test( 127         , -507      , ADD_FUNCT7, ADD_FUNCT3, opo,    "0010", -380        , false);     -- negative
        alu_test( 2147483647  , 1         , ADD_FUNCT7, ADD_FUNCT3, opo,    "1010", -2147483648 , false);     -- overflow
        alu_test( -1          , 2         , ADD_FUNCT7, ADD_FUNCT3, opo,    "0001", 1           , false);     -- carry
                                                                                                  
        -- test sub, note: C=1 means no borrow, normal subtraction,                               
        --test_id 5 to 9                                                                          
        alu_test( 128         , 65        , SUB_FUNCT7, SUB_FUNCT3, opo,    "0001", 63          , false);   -- normal
        alu_test( 654321      , 654321    , SUB_FUNCT7, SUB_FUNCT3, opo,    "0101", 0           , false);   -- zero
        alu_test( -103        , 881       , SUB_FUNCT7, SUB_FUNCT3, opo,    "0011", -984        , false);   -- negative
        alu_test( -2147483648 , 1         , SUB_FUNCT7, SUB_FUNCT3, opo,    "1001", 2147483647  , false);   -- overflow
        alu_test( 0           , -1111     , SUB_FUNCT7, SUB_FUNCT3, opo,    "0000", 1111        , false);   -- carry (missing)
        
        --test slt
        --test_id 10 to 13
        alu_test( -2147483648 , 2147483647, SLT_FUNCT7, SLT_FUNCT3, opo,    "0000", 1           , true );   
        alu_test( 0           , 0         , SLT_FUNCT7, SLT_FUNCT3, opo,    "0000", 0           , true );
        alu_test( -5          , -1        , SLT_FUNCT7, SLT_FUNCT3, opo,    "0000", 1           , true );
        alu_test( 32          , 31        , SLT_FUNCT7, SLT_FUNCT3, opo,    "0000", 0           , true );
        
        --test sltu
        --test_id 14 to 17
        alu_test( -2147483648 , 2147483647, SLTU_FUNCT7,SLTU_FUNCT3,opo,    "0000", 0           , true );   
        alu_test( 0           , 0         , SLTU_FUNCT7,SLTU_FUNCT3,opo,    "0000", 0           , true );
        alu_test( -5          , -1        , SLTU_FUNCT7,SLTU_FUNCT3,opo,    "0000", 1           , true );
        alu_test( 32          , 31        , SLTU_FUNCT7,SLTU_FUNCT3,opo,    "0000", 0           , true );
        
        --test and
        --test_id 18 to 21
        alu_test( -1          , 0         , AND_FUNCT7, AND_FUNCT3, opo,    "0000", 0           , true );   
        alu_test( 0           , -1        , AND_FUNCT7, AND_FUNCT3, opo,    "0000", 0           , true );  
        alu_test( -1          , -1        , AND_FUNCT7, AND_FUNCT3, opo,    "0000", -1          , true );  
        alu_test( 0           , 0         , AND_FUNCT7, AND_FUNCT3, opo,    "0000", 0           , true ); 
        
        --test or
        --test_id 22 to 25
        alu_test( -1          , 0         , OR_FUNCT7 , OR_FUNCT3 , opo,    "0000", -1          , true );   
        alu_test( 0           , -1        , OR_FUNCT7 , OR_FUNCT3 , opo,    "0000", -1          , true );  
        alu_test( -1          , -1        , OR_FUNCT7 , OR_FUNCT3 , opo,    "0000", -1          , true ); 
        alu_test( 0           , 0         , OR_FUNCT7 , OR_FUNCT3 , opo,    "0000", 0           , true ); 
        
        --test xor
        --test_id 26 to 29
        alu_test( -1          , 0         , XOR_FUNCT7, XOR_FUNCT3, opo,    "0000", -1          , true );   
        alu_test( 0           , -1        , XOR_FUNCT7, XOR_FUNCT3, opo,    "0000", -1          , true );  
        alu_test( -1          , -1        , XOR_FUNCT7, XOR_FUNCT3, opo,    "0000", 0           , true ); 
        alu_test( 0           , 0         , XOR_FUNCT7, XOR_FUNCT3, opo,    "0000", 0           , true ); 
        
        --test sll
        --test_id 30 to 33
        alu_test( 1           , 8         , SLL_FUNCT7, SLL_FUNCT3, opo,    "0000", 256         , true );
        alu_test( 1           , 31        , SLL_FUNCT7, SLL_FUNCT3, opo,    "0000", -2147483648 , true );
        alu_test( 123456      , 0         , SLL_FUNCT7, SLL_FUNCT3, opo,    "0000", 123456      , true );
        alu_test( 10930       , 17        , SLL_FUNCT7, SLL_FUNCT3, opo,    "0000", 1432616960  , true );        
        
        --test srl
        --test_id 34 to 37
        alu_test( -2147483648 , 19        , SRL_FUNCT7, SRL_FUNCT3, opo,    "0000", 4096        , true );
        alu_test( -2147483648 , 31        , SRL_FUNCT7, SRL_FUNCT3, opo,    "0000", 1           , true );
        alu_test( 71354785    , 0         , SRL_FUNCT7, SRL_FUNCT3, opo,    "0000", 71354785    , true );
        alu_test( 1432616960  , 17        , SRL_FUNCT7, SRL_FUNCT3, opo,    "0000", 10930       , true );   
        
        --test sra
        --test_id 38 to 41
        alu_test( -2147483648 , 19        , SRA_FUNCT7, SRA_FUNCT3, opo,    "0000", -4096       , true );
        alu_test( -2147483648 , 31        , SRA_FUNCT7, SRA_FUNCT3, opo,    "0000", -1          , true );
        alu_test( 71354785    , 0         , SRA_FUNCT7, SRA_FUNCT3, opo,    "0000", 71354785    , true );
        alu_test( 1432616960  , 17        , SRA_FUNCT7, SRA_FUNCT3, opo,    "0000", 10930       , true ); 
        
        --test lui and auipc
        --test_id 42 and 43
        alu_test( 0           , -4096     , NO_FUNCT7 , NO_FUNCT3 , luio,   "0000", -4096       , true );  -- it is "111...1000000000000" for immediate which must be added with zero
        alu_test( 8064        , -4096     , NO_FUNCT7 , NO_FUNCT3 , auipc,  "0000", 3968        , true );  -- it is "111...1000000000000" for immediate and 8064 is actual pc
        
        --jal and jalr must not be tested because it will be nopped
        
        
        
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