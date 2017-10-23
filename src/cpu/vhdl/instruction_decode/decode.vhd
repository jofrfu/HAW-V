-- register_select.vhd
-- created by Jonas Fuhrmann + Felix Lorenz
-- project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity decode is
	port(
		clk, reset   :  in std_logic;
		branch		 :  in std_logic;
		IFR			 :  in INSTRUCTION_TYPE;
		IF_CNTRL	 : out IF_CNTRL_TYPE;
		ID_CNTRL	 : out ID_CNTRL_TYPE;
		WB_CNTRL	 : out WB_CNTRL_TYPE;
		MA_CNTRL	 : out MA_CNTRL_TYPE;
		EX_CNTRL	 : out EX_CNTRL_TYPE;
		Imm			 : out DATA_TYPE
	);
end entity decode;