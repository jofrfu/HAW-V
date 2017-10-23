-- register_select.vhd
-- created by Jonas Fuhrmann + Felix Lorenz
-- project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity instruction_decode is
	port(
		clk, reset   :  in std_logic;
		branch		 :  in std_logic;
		IFR			 :  in INSTRUCTION_TYPE;
		DI	  		 :  in DATA_TYPE;
		rd			 :  in REGISTER_ADDRESS_TYPE;
		WB_CNTRL	 : out WB_CNTRL_TYPE;
		MA_CNTRL	 : out MA_CNTRL_TYPE;
		EX_CNTRL	 : out EX_CNTRL_TYPE;
		Imm			 : out DATA_TYPE;
		OPB			 : out DATA_TYPE;
		OPA			 : out DATA_TYPE;
		DO			 : out DATA_TYPE
	);
end entity instruction_decode;
