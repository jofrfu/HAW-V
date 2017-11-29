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
        SIGN_EN     : in std_logic;
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
	signal wb_cntrl_cs : WB_CNTRL_TYPE := WB_CNTRL_NOP;
	signal wb_cntrl_ns : WB_CNTRL_TYPE;
	signal di_cs       : DATA_TYPE     := (others => '0');
	signal di_ns       : DATA_TYPE;
	signal pc_cs       : ADDRESS_TYPE  := (others => '0');
	signal pc_ns       : ADDRESS_TYPE;

    signal DATA_IN_s : DATA_TYPE;
begin

	load_mux:
	process(RESU, DATA_IN_s, MA_CNTRL(1)) is
	begin
		if MA_CNTRL(1) = '1' then
			di_ns <= DATA_IN_s;
		else
			di_ns <= RESU;
		end if;
	end process load_mux;
    
    sign_ext:
    process(WORD_CNTRL, SIGN_EN, DATA_IN) is
        variable MIN_SIGN_v : natural;
        variable MSB_index_v: natural;
    begin
        if SIGN_EN = '0' then
            DATA_IN_s <= DATA_IN;
        else
            case WORD_CNTRL is
                when BYTE =>
                    MIN_SIGN_v := 8;
                    MSB_index_v:= 7;
                    
                when HALF =>
                    MIN_SIGN_v := 16;
                    MSB_index_v:= 15;
                when others =>
                    report "Unsupported sign extension format!";
                    MIN_SIGN_v := 32;
                    MSB_index_v:= 31;
            end case;
            -- sign extension
            for i in DATA_WIDTH-1 downto 0 loop
                if i >= MIN_SIGN_v then
                    DATA_IN_s(i) <= DATA_IN(MSB_index_v);
                else
                    DATA_IN_s(i) <= DATA_IN(i);
                end if;
            end loop;
        end if;
    end process sign_ext;
	
	sequ_log:
	process(clk) is
	begin
		if clk'event and clk = '1' then
            if reset = '1' then
        		wb_cntrl_cs <= WB_CNTRL_NOP;
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
