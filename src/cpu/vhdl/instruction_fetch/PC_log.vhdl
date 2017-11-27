--!@file    PC_log.vhdl
--!@biref   This file contains the programm counter entity of the CPU
--!@author  Sebastian Br�ckner
--!@date    2017

--!@biref   Programm counter of the CPU
--!@details Contains the Programm counter logic
--!@author  Sebastian Br�ckner
--!@date    2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity PC_log is
    port(
         clk, reset : in std_logic;
         
         cntrl     : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
         rel       : in DATA_TYPE;     --! relative branch adress
         abso      : in DATA_TYPE;     --! absolute branch adress, or base for relative jump
         
         pc_asynch : out ADDRESS_TYPE; --! programm counter output
         pc_synch  : out ADDRESS_TYPE  --! programm counter output
    );
end entity PC_log;

architecture std_impl of PC_log is 
    signal pc_cs : ADDRESS_TYPE := std_logic_vector(to_signed(-4,DATA_WIDTH));
    signal pc_ns : ADDRESS_TYPE;
    
begin
    pc_logic : process(cntrl, rel, abso, pc_cs) is
        variable cntrl_v : IF_CNTRL_TYPE;
        variable rel_v   : DATA_TYPE;
        variable abso_v  : DATA_TYPE;
        variable pc_v    : ADDRESS_TYPE;
        variable pc_ns_v : ADDRESS_TYPE;
        
        variable base_v     : ADDRESS_TYPE;
        variable increment_v: ADDRESS_TYPE;
    begin
        cntrl_v := cntrl;
        rel_v   := rel;
        abso_v  := abso;
        pc_v     := pc_cs;
        
        case cntrl_v(0) is  --choose a value to increment the PC
            when '0'    => increment_v := STD_PC_ADD;
            when '1'    => increment_v := rel_v;
            when others => report "PC_log mux 0 has undefined signal" severity warning;
        end case ; 
        
        case cntrl_v(1) is  --choose absolute branch or normals pc
            when '0'    => base_v := pc_v;
            when '1'    => base_v := abso_v;
            when others => report "PC_log mux 1 has undefined signal" severity warning;
        end case ; 
        
        if cntrl_v = "10" then
            report "Wrong Control Bits in PC_log, 4 + abs does not make any sense!!!" severity warning;
        end if;
        
        pc_ns_v := std_logic_vector(unsigned(base_v) + unsigned(increment_v)); 
        pc_ns <= pc_ns_v;
    end process pc_logic;
    
    pc_asynch <= pc_ns;     --program counter to memory for intruction fetch
    pc_synch  <= pc_cs;     --clocked program counter for ID stage
    
    reg : process(clk) is
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                pc_cs <= std_logic_vector(to_signed(-4,DATA_WIDTH));
            else
                pc_cs <= pc_ns;  --store data at rising edge
            end if;
        end if; 
    end process reg;
    
    
end architecture std_impl;

