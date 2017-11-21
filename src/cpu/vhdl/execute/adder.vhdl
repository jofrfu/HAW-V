--!@file 	carry_ripple.vhdl
--!@brief 	This file contains the ALU of the CPU
--!@author 	Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity adder is
    port(
        OPA         : in  DATA_TYPE;
        OPB         : in  DATA_TYPE;
        nadd_sub    : in  std_logic;
        
        RESULT      : out DATA_TYPE;
        CARRY       : out std_logic_vector(DATA_WIDTH downto 0)
    );
end entity adder;

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
        for i in 0 to RESULT_v'left loop
            resu_temp_v(i) := OPA_v(i) xor OPB_v(i);
            carr_temp_v(i) := OPA_v(i) and OPB_v(i);
            
            RESULT_v(i)    := resu_temp_v(i) xor CARRY_v(i);
            CARRY_v(i+1)   := carr_temp_v(i) or (resu_temp_v(i) and CARRY_v(i));
        end loop;
        
        CARRY <= CARRY_v;
        RESULT <= RESULT_v;
    end process add;

end architecture carry_ripple;

architecture carry_look_ahead of adder is
begin

    add:
    process(OPA, OPB, nadd_sub) is
        variable OPA_v      : std_logic_vector(DATA_WIDTH   downto 0);
        variable OPB_v      : std_logic_vector(DATA_WIDTH   downto 0);
        variable nadd_sub_v : std_logic;
        
        variable RESULT_v   : std_logic_vector(DATA_WIDTH   downto 0);
        variable CARRY_v    : std_logic_vector(DATA_WIDTH+1 downto 0);
    begin
        OPA_v := '0' & OPA;
        OPB_v := '0' & OPB;
        nadd_sub_v := nadd_sub;
        
    end process add;

end architecture carry_look_ahead;
