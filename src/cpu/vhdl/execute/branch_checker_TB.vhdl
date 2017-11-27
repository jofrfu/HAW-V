--!@file 	branch_checker_TB.vhdl
--!@brief 	This file contains the branch checker
--!@author 	Matthis Keppner, Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity branch_checker_TB is
end entity branch_checker_TB;

architecture TB of branch_checker_TB is

component dut is
    port (
        FUNCT3      : in FUNCT3_TYPE;
        OP_CODE     : in OP_CODE_BIT_TYPE;
        FLAGS       : in FLAGS_TYPE;

        WORD_CNTRL  : out WORD_CNTRL_TYPE;
        SIGN_EN     : out std_logic;
        
        BRANCH      : out std_logic
    );
end component dut;

for all : dut use entity work.branch_checker(beh);

    signal FUNCT3_s     : FUNCT3_TYPE := (others => '0');
    signal OP_BITS_s    : OP_CODE_BIT_TYPE;
    signal OP_CODE_s    : OP_CODE_TYPE;
    signal FLAGS_s      : FLAGS_TYPE := (others => '0');
    signal WORD_CNTRL_s : WORD_CNTRL_TYPE;
    signal sign_en_s    : std_logic;
    signal BRANCH_s     : std_logic;

    signal simulation_running : boolean := false;
    
begin

    dut_i : dut
    port map(
        FUNCT3_s,
        OP_BITS_s,
        FLAGS_s,
        WORD_CNTRL_s,
        sign_en_s,
        BRANCH_s
        );
    
    test:
    process is
        begin
            simulation_running <= true;
            --##### TEST BRANCH RESULTS #####
            report "##### TEST BRANCH RESULTS #####";
            
            --test1  BEQ 
            --OP_CODE       : BRANCHO :  01100011
            --FUNCT3        : 000
            --FLAGS(V Z N C): 0100 z = 1
            --action: choose BEQ which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            wait for 1 ns;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "000";
            FLAGS_s <= "0100";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BEQ case should be 1 was 0!";
                wait;
            end if;
            
            --test2  BEQ  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 000
            --FLAGS(V Z N C): 0000 z = 0
            --action: choose BEQ which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "000";
            FLAGS_s <= "0000";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BEQ case should be 0 was 1!";
                wait;
            end if;
            
            --test3  BNE complies 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 001
            --FLAGS(V Z N C): 0000 z = 0
            --action: choose BNE which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "001";
            FLAGS_s <= "0000";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BNE case should be 1 was 0!";
                wait;
            end if;
            
            --test4  BNE  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 001
            --FLAGS(V Z N C): 0100 z = 1
            --action: choose BNE which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "001";
            FLAGS_s <= "0100";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BNE case should be 0 was 1!";
                wait;
            end if;
            
            --test5_1  BLT complies 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 100
            --FLAGS(V Z N C): 0010 v /= n
            --action: choose BLT which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "100";
            FLAGS_s <= "0010";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BLT case should be 1 was 0!";
                wait;
            end if;
            
            --test5_2  BLT complies 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 100
            --FLAGS(V Z N C): 1000 v /= n
            --action: choose BLT which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "100";
            FLAGS_s <= "1000";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BLT case should be 1 was 0!";
                wait;
            end if;
            
            --test6_1  BLT  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 100
            --FLAGS(V Z N C): 1010 v = n
            --action: choose BLT which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "100";
            FLAGS_s <= "1010";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BLT case should be 0 was 1!";
                wait;
            end if;
            
            --test6_2  BLT  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 100
            --FLAGS(V Z N C): 0000 v = n
            --action: choose BLT which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "100";
            FLAGS_s <= "0000";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BLT case should be 0 was 1!";
                wait;
            end if;
            
            --test7_1  BGE complies 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 101
            --FLAGS(V Z N C): 0000  v = n
            --action: choose BGE which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "101";
            FLAGS_s <= "0000";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BGE case should be 1 was 0!";
                wait;
            end if;
            
            --test7_2  BGE complies 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 100
            --FLAGS(V Z N C): 1010 v = n
            --action: choose BGE which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "101";
            FLAGS_s <= "1010";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BGE case should be 1 was 0!";
                wait;
            end if;
            
            --test8_1  BGE  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 101
            --FLAGS(V Z N C): 0010 v /= n
            --action: choose BGE which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "101";
            FLAGS_s <= "0010";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BGE case should be 0 was 1!";
                wait;
            end if;
            
            --test8_2  BGE  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 101
            --FLAGS(V Z N C): 1000 v /= n
            --action: choose BGE which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "101";
            FLAGS_s <= "1000";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BGE case should be 0 was 1!";
                wait;
            end if;
            
            --test9  BLTU 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 110
            --FLAGS(V Z N C): 0000 c = 0
            --action: choose BLTU which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "110";
            FLAGS_s <= "0000";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BLTU case should be 1 was 0!";
                wait;
            end if;
            
            --test10  BLTU  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 110
            --FLAGS(V Z N C): 0001 c = 1
            --action: choose BLTU which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "110";
            FLAGS_s <= "0001";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BLTU case should be 0 was 1!";
                wait;
            end if;
            
            --test11_1  BGEU 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 111
            --FLAGS(V Z N C): 0001 c = 1 (or  z = 1)
            --action: choose BLTU which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "111";
            FLAGS_s <= "0001";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BGEU case should be 1 was 0!";
                wait;
            end if;
            
            --test11_2  BGEU 
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 111
            --FLAGS(V Z N C): 0001 z = 1 (or  c = 1)
            --action: choose BLTU which complies the condition
            --result: BRANCH_s should be 1
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "111";
            FLAGS_s <= "0100";
            wait for 1 ns;
            if BRANCH_s /= '1' then
                report "Test failed! Error in BGEU case should be 1 was 0!";
                wait;
            end if;
                   
            --test12  BGEU  doesn't complies
            --OP_CODE       : BRANCHO :  1100011
            --FUNCT3        : 111
            --FLAGS(V Z N C): 0100 z = 0 and  c = 0
            --action: choose BLTU which doesn't complies the condition
            --result: BRANCH_s should be 0
            OP_CODE_s <= brancho;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "111";
            FLAGS_s <= "0000";
            wait for 1 ns;
            if BRANCH_s /= '0' then
                report "Test failed! Error in BGEU case should be 0 was 1!";
                wait;
            end if;
            
            --##### TEST LOAD #####
            report "##### TEST LOAD #####";
            
            --test13   LB
            --OP_CODE       : LOADO
            --FUNCT3        : 000
            --action: choose lb 
            --result: WORD_CNTRL should be BYTE
            --result: sign_en_s should be 1
            OP_CODE_s <= loado;
            wait for 1 ns;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "000";
            wait for 1 ns;
            if WORD_CNTRL_s /= BYTE and sign_en_s /= '1' then
                report "Test failed! Error loading signed byte!";
                wait;
            end if;
            
            --test14   LH
            --OP_CODE       : LOADO
            --FUNCT3        : 001
            --action: choose lb 
            --result: WORD_CNTRL should be HALF
            --result: sign_en_s should be 1
            OP_CODE_s <= loado;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "001";
            wait for 1 ns;
            if WORD_CNTRL_s /= HALF and sign_en_s /= '1' then
                report "Test failed! Error loading signed halfword!";
                wait;
            end if;
            
            --test15   LW
            --OP_CODE       : LOADO
            --FUNCT3        : 010
            --action: choose lb 
            --result: WORD_CNTRL should be WORD
            --result: sign_en_s should be 1
            OP_CODE_s <= loado;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "010";
            wait for 1 ns;
            if WORD_CNTRL_s /= WORD and sign_en_s /= '1' then
                report "Test failed! Error loading word!";
                wait;
            end if;
            
            --test16   LBU
            --OP_CODE       : LOADO
            --FUNCT3        : 100
            --action: choose lb 
            --result: WORD_CNTRL should be BYTE
            --result: sign_en_s should be 0
            OP_CODE_s <= loado;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "100";
            wait for 1 ns;
            if WORD_CNTRL_s /= BYTE and sign_en_s /= '0' then
                report "Test failed! Error loading unsigned byte!";
                wait;
            end if;
            
            --test17   LHU
            --OP_CODE       : LOADO
            --FUNCT3        : 101
            --action: choose lb 
            --result: WORD_CNTRL should be HALF
            --result: sign_en_s should be 0
            OP_CODE_s <= loado;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "101";
            wait for 1 ns;
            if WORD_CNTRL_s /= HALF and sign_en_s /= '1' then
                report "Test failed! Error loading unsigned halfword!";
                wait;
            end if;
            
            --##### TEST STORE ##### 
            report "##### TEST STORE #####";
            --test18   SB
            --OP_CODE       : STOREO
            --FUNCT3        : 000
            --action        : choose SB 
            --result        : WORD_CNTRL should be BYTE
            OP_CODE_s <= storeo;
            wait for 1 ns;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "000";
            wait for 1 ns;
            if WORD_CNTRL_s /= BYTE then
                report "Test failed! Error storing byte!";
                wait;
            end if;
            
            --test19   SH
            --OP_CODE       : STOREO
            --FUNCT3        : 000
            --action        : choose SH 
            --result        : WORD_CNTRL should be HALF
            OP_CODE_s <= storeo;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "001";
            wait for 1 ns;
            if WORD_CNTRL_s /= HALF then
                report "Test failed! Error storing halfword!";
                wait;
            end if;
            
            --test18   SB
            --OP_CODE       : STOREO
            --FUNCT3        : 000
            --action        : choose SB 
            --result        : WORD_CNTRL should be WORD
            OP_CODE_s <= storeo;
            OP_BITS_s <= OP_CODE_TYPE_TO_BITS(OP_CODE_s);
            FUNCT3_s <= "010";
            wait for 1 ns;
            if WORD_CNTRL_s /= WORD then
                report "Test failed! Error storing word!";
                wait;
            end if;
            
            
            simulation_running <= false;
            report "###########>TEST SUCCESSFUL!<###########";
            wait;
    end process test;
    
end architecture TB;
    