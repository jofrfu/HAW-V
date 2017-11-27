--!@file     write_back.vhdl
--!@brief    Contains eintity and standard architecture for write back stage
--!@author   Jonas Fuhrmann
--!@date     2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
	
entity 	write_back is
	port(
		WB_CNTRL_IN : in WB_CNTRL_TYPE;
		DATA_IN     : in DATA_TYPE;
		PC_IN       : in ADDRESS_TYPE;
		
		REG_ADDR    : out REGISTER_ADDRESS_TYPE;
		WRITE_BACK  : out DATA_TYPE
	);
end entity write_back;

architecture beh of write_back is
begin
	pc_mux:
	process(DATA_IN, PC_IN, WB_CNTRL_IN(WB_CNTRL_IN'left)) is
	begin
		if WB_CNTRL_IN(WB_CNTRL_IN'left) = '1' then
			WRITE_BACK <= PC_IN;
		else
			WRITE_BACK <= DATA_IN;
		end if;
	end process pc_mux;
	
	REG_ADDR <= WB_CNTRL_IN(4 downto 0);
	
end architecture beh;
		