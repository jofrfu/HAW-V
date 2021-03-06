--!@file    PC_log.vhdl
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Sebastian Brückner
--!@author  Felix Lorenz
--!@author  Jonas Fuhrmann
--!@date    2017 - 2018

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@brief Program counter of the CPU
--!@details Computes the next address from witch the next instruction will be loaded.
--!         It has 5 operation modes:
--!         1. increase PC by 4
--!         2. add relative to PC
--!         3. set PC to absolute
--!         4. set PC to absolute + relative
--!         5. stop PC for bubbles (+0)
entity PC_log is
    port(
         clk, reset : in std_logic;
         
         branch    : in std_logic;
         cntrl     : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
         rel       : in DATA_TYPE;     --! relative branch address
         abso      : in DATA_TYPE;     --! absolute branch address, or base for relative jump
         
         pc_asynch : out ADDRESS_TYPE; --! program counter output
         pc_synch  : out ADDRESS_TYPE  --! program counter output
    );
end entity PC_log;

--!@brief pc.std_impl see entity documentation
architecture std_impl of PC_log is 
    signal pc_cs : ADDRESS_TYPE := std_logic_vector(to_signed(-4,DATA_WIDTH));
    signal pc_ns : ADDRESS_TYPE;
    
begin
    pc_logic : process(cntrl, rel, abso, pc_cs, branch) is
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
        pc_v    := pc_cs;
        
        --if cntrl_v = IF_CNTRL_BUB or branch = '1' then      --PC + 0 for bubbles
        if branch = '1' then
            base_v := pc_v;
            increment_v := std_logic_vector(signed(rel_v) + to_signed(-8,DATA_WIDTH));
        else
            if cntrl_v = IF_CNTRL_BUB then
                base_v := pc_v;
                increment_v := (others => '0');
            else
                case cntrl_v(0) is  --choose a value to increment the PC
                    when '0'    => increment_v := STD_PC_ADD;
                    when '1'    => increment_v := std_logic_vector(signed(rel_v) + to_signed(-4,DATA_WIDTH));
                    when others => report "PC_log mux 0 has undefined signal" severity warning;
                end case ; 
                
                case cntrl_v(1) is  --choose absolute branch or normals pc
                    when '0'    => base_v := pc_v;
                    when '1'    => base_v := abso_v;
                    when others => report "PC_log mux 1 has undefined signal" severity warning;
                end case ;             
            end if;
        end if;
        
        pc_ns_v := std_logic_vector(signed(base_v) + signed(increment_v)); 
        pc_ns <= pc_ns_v;
    end process pc_logic;
    
    pc_asynch <= pc_ns;     --program counter to memory for instruction fetch
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

