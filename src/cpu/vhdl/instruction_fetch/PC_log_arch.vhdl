--!@file 	PC_log.vhdl
--!@biref 	This file contains 
--!			Standard architecture for PC_log for synthesis
--!@author 	Sebastian Br�ckner
--!@date 	2017

--!@biref 	Standard architecture for PC_log for synthesis
--!@author 	Sebastian Br�ckner
--!@date 	2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

architecture std_impl of PC_log is 
	signal pc_cs : ADDRESS_TYPE := (others => '0');
	signal pc_ns : ADDRESS_TYPE;
	
begin
	pc_logic : process(cntrl, rel, abso, pc_cs) is
		variable cntrl_v : IF_CNTRL_TYPE;
		variable rel_v 	 : DATA_TYPE;
		variable abso_v  : DATA_TYPE;
		variable pc_v 	 : ADDRESS_TYPE;
		variable pc_ns_v : ADDRESS_TYPE;
		
		variable base_v     : ADDRESS_TYPE;
		variable increment_v: ADDRESS_TYPE;
	begin
		cntrl_v := cntrl;
		rel_v   := rel;
		abso_v  := abso;
		pc_v 	:= pc_cs;
		
		case cntrl_v(0) is  --choose a value to increment the PC
			when '0' => increment_v := STD_PC_ADD;
			when '1' => increment_v := rel_v;
			when others   => report "PC_log mux 0 has undefined signal" severity warning;
		end case ; 
		
		case cntrl_v(1) is  --choose absolute branch or normals pc
			when '0' => base_v := pc_v;
			when '1' => base_v := abso_v;
			when others   => report "PC_log mux 0 has undefined signal" severity warning;
		end case ; 
		
		pc_ns_v := base_v + increment_v; 
		pc_ns <= pc_ns_v;
	end process pc_logioc;
	
	
	
	reg : process(clk, reset) is
	begin
		if clk'event and clk = '1' then
            if reset = '1' then
                pc_cs <= (others => '0');
            else
                pc_cs <= pc_ns;  --store data at rising edge
            end if;
        end if; 
	end process reg;
	
	
end architecture std_impl;
