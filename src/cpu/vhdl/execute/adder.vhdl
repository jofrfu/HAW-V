--!@file    carry_ripple.vhdl
--!@brief   This file is part of the ach-ne projekt at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Jonas Fuhrmann
--!@author  Sebastian Brückner
--!@date    2017 - 2018

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

--!@brief Simple adder/subtractor
--!@details Adder capeable of adding or subtracting to operands, 
--!          has add/sub control bit and return flag bits
entity adder is
    port(
        OPA         : in  DATA_TYPE; --!First operand
        OPB         : in  DATA_TYPE; --!Second operand
        nadd_sub    : in  std_logic; --!0 = add, 1 = subtract
        
        RESULT      : out DATA_TYPE; --!Result of operation
        CARRY       : out std_logic; --!Carry Bit
        OVERFLOW    : out std_logic  --!Overflow Bit
    );
end entity adder;

--!@brief adder.carry_ripple Ripple Carry implementation
--!@details slowest implementation
architecture carry_ripple of adder is
begin

    add:
    process(OPA, OPB, nadd_sub) is
    
        variable OPA_v      : DATA_TYPE;
        variable OPB_v      : DATA_TYPE;
        variable nadd_sub_v : std_logic;
        
        variable RESULT_v   : DATA_TYPE;
        variable CARRY_v    : std_logic_vector(DATA_WIDTH downto 0);
        
        variable resu_temp_v    : DATA_TYPE;
        variable carr_temp_v    : DATA_TYPE;     
    begin
        OPA_v := OPA;
        OPB_v := OPB;
        nadd_sub_v := nadd_sub;
        
        -- for two's complement - invert
        for i in OPB_v'left downto 0 loop
            OPB_v(i) := OPB_v(i) xor nadd_sub_v;
        end loop;

        -- for two's complement - add one
        CARRY_v(0) := nadd_sub_v;
        
        -- adder        
        resu_temp_v := OPA_v xor OPB_v;
        carr_temp_v := OPA_v and OPB_v;
        
        for i in 0 to RESULT_v'left loop
            RESULT_v(i)    := resu_temp_v(i) xor CARRY_v(i);
            CARRY_v(i+1)   := carr_temp_v(i) or (resu_temp_v(i) and CARRY_v(i));
        end loop;
        --
        CARRY <= CARRY_v(CARRY_v'left);
        OVERFLOW <= CARRY_v(CARRY_v'left) xor CARRY_v(CARRY_v'left-1);
        RESULT <= RESULT_v;
    end process add;

end architecture carry_ripple;

--!@brief adder.carry_lookahead carry lookahead implementation
--!@details Faster then ripple carry
architecture carry_lookahead of adder is
begin

    add:
    process(OPA, OPB, nadd_sub) is
        variable OPA_v      : DATA_TYPE;
        variable OPB_v      : DATA_TYPE;
        variable nadd_sub_v : std_logic;
        
        variable RESULT_v   : DATA_TYPE;
        variable CARRY_v    : std_logic_vector(DATA_WIDTH downto 0);
        
        variable sum_v              : DATA_TYPE;
        variable carry_generate_v   : DATA_TYPE;
        variable carry_propagate_v  : DATA_TYPE;
    begin
        OPA_v := OPA;
        OPB_v := OPB;
        nadd_sub_v := nadd_sub;
        
        -- for two's complement - invert
        for i in OPB_v'left downto 0 loop
            OPB_v(i) := OPB_v(i) xor nadd_sub_v;
        end loop;

        -- for two's complement - add one
        CARRY_v(0) := nadd_sub_v;
        
        -- helper signals
        sum_v := OPA_v xor OPB_v;
        carry_generate_v := OPA_v and OPB_v;
        carry_propagate_v:= OPA_v or OPB_v;
                
        -- adder
        for i in 0 to RESULT_v'left loop
            CARRY_v(i+1) := carry_generate_v(i) or (carry_propagate_v(i) and CARRY_v(i));
        end loop;
        RESULT_v(0) := sum_v(0) xor CARRY_v(0);
        RESULT_v(RESULT_v'left downto 1) := sum_v(sum_v'left downto 1) xor CARRY_v(sum_v'left downto 1);
        
        CARRY <= CARRY_v(CARRY_v'left);
        OVERFLOW <= CARRY_v(CARRY_v'left) xor CARRY_v(CARRY_v'left-1);
        RESULT <= RESULT_v;
    end process add;

end architecture carry_lookahead;

--!@brief adder.numeric_adder using standard add
--!@details uses std_logic_vector add implementation
architecture numeric_adder of adder is
    
begin

    add:
    process(OPA, OPB, nadd_sub) is 
        variable OPA_v      : DATA_TYPE;
        variable OPB_v      : DATA_TYPE;
        variable nadd_sub_v : std_logic;
        
        variable RESULT_v   : std_logic_vector(DATA_WIDTH downto 0);
        variable OVERFLOW_v : std_logic;
    begin
        OPA_v := OPA;
        OPB_v := OPB;
        nadd_sub_v := nadd_sub;
            
        -- for two's complement - invert
        for i in OPB_v'left downto 0 loop
            OPB_v(i) := OPB_v(i) xor nadd_sub_v;
        end loop;
        
        -- add 33BIT for CARRY and add 1BIT as CARRY IN
        RESULT_v := std_logic_vector(unsigned('0' & OPA_v) + unsigned(OPB_v) + nadd_sub_v);
        
        -- check MSBs: (A=B=1 and R=0) or (A=B=0 and R=1)
        if (OPA_v(OPA_v'left) = '1' and OPB_v(OPB_v'left) = '1' and RESULT_v(RESULT_v'left-1) = '0') or
           (OPA_v(OPA_v'left) = '0' and OPB_v(OPB_v'left) = '0' and RESULT_v(RESULT_v'left-1) = '1') then
            OVERFLOW_v := '1';
        else
            OVERFLOW_v := '0';
        end if;
        
        CARRY <= RESULT_v(RESULT_v'left);
        OVERFLOW <= OVERFLOW_v;
        RESULT <= RESULT_v(RESULT_v'left-1 downto 0);
    end process add;
    
end architecture numeric_adder;
