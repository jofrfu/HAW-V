--!@file     memory_access.vhdl
--!@brief    Contains entity and standard architecture for memory access stage
--!@author   Sebastian Brückner
--!@author   Jonas Fuhrmann
--!@date     2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@brief   This is the memory acess stage
--!@details Tasks:
--!         1. Write to RAM
--!         2. Control LOAD
--!@author  Sebastian Brückner
--!@author  Jonas Fuhrmann
--!@date    2017
entity memory_access is
    port(
        clk, reset : in std_logic;
        
        --! @brief stage inputs
        WB_CNTRL_IN : in WB_CNTRL_TYPE;
        MA_CNTRL    : in MA_CNTRL_TYPE;
        WORD_CNTRL  : in WORD_CNTRL_TYPE;
        RESU        : in DATA_TYPE;
        DO          : in DATA_TYPE;
        PC_IN       : in ADDRESS_TYPE;
        
        --! @brief memory inputs
        DATA_IN     : in DATA_TYPE;
        
        --! @brief stage outputs
        WB_CNTRL_OUT: out WB_CNTRL_TYPE;
        DI          : out DATA_TYPE;
        PC_OUT      : out ADDRESS_TYPE;
        
        --! @brief memory outputs
        ENABLE      : out std_logic;
        WRITE_EN    : out std_logic;
        DATA_OUT    : out DATA_TYPE;
        ADDRESS     : out ADDRESS_TYPE;
  		WORD_LENGTH : out WORD_CNTRL_TYPE
    );
end entity memory_access;


architecture beh of memory_access is

	--! @brief registers
	signal wb_cntrl_cs : WB_CNTRL_TYPE := (others => '0');
	signal wb_cntrl_ns : WB_CNTRL_TYPE;
	signal di_cs       : DATA_TYPE     := (others => '0');
	signal di_ns       : DATA_TYPE;
	signal pc_cs       : ADDRESS_TYPE  := (others => '0');
	signal pc_ns       : ADDRESS_TYPE;

begin

	load_mux:
	process(RESU, DATA_IN, MA_CNTRL(1)) is
	begin
		if MA_CNTRL(1) = '1' then
			di_ns <= RESU;
		else
			di_ns <= DATA_IN;
		end if;
	end process load_mux;
	
	sequ_log:
	process(clk, reset) is
	begin
		if clk'event and clk = '1' then
            if reset = '1' then
        		wb_cntrl_cs <= (others => '0');
        		di_cs		<= (others => '0');
        		pc_cs       <= (others => '0');
        	else
        		wb_cntrl_cs <= wb_cntrl_ns;
        		di_cs       <= di_ns;
        		pc_cs       <= pc_ns;
        	end if;
        end if;
	end process sequ_log;

	--! @brief concurrent assignments
	ENABLE       <= MA_CNTRL(1) or MA_CNTRL(0);
	WRITE_EN     <= MA_CNTRL(0);
	DATA_OUT     <= DO;
	ADDRESS      <= RESU;
	WORD_LENGTH  <= WORD_CNTRL;
	
	pc_ns        <= PC_IN;
	PC_OUT       <= pc_cs;
	wb_cntrl_ns  <= WB_CNTRL_IN;
	WB_CNTRL_OUT <= wb_cntrl_cs;
	DI           <= di_cs;
	
end architecture beh;
