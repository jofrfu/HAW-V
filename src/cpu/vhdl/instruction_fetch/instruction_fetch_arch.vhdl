--!@file 	instruction_fetch_arch.vhdl
--!@brief 	Contains Standard architecture for instruction_fetch
--!@author 	Sebastian Brückner
--!@date 	2017

--!@brief 	Programm counter of the CPU
--!@details Contains the Programm counter logic
--!@author 	Sebastian Brückner
--!@date 	2017

--!@brief   added PC register to the stage
--!@details was needed to realize the AUIPC instruction
--!@author  Felix Lorenz
--!@date    2017

architecture std_impl of instruction_fetch is 
	signal IFR_cs : INSTRUCTION_BIT_TYPE := (others => '0');
	signal PC_cs  : ADDRESS_TYPE := (others => '0');
	signal PC_ns  : ADDRESS_TYPE;
	
	component PC_log is
    port(
         clk, reset : in std_logic;
         
         cntrl  : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
         rel    : in DATA_TYPE;     --! relative branch adress
         abso   : in DATA_TYPE;     --! absolute branch adress, or base for relative jump
         
         pc     : out ADDRESS_TYPE     --! programm counter output
    );
    end component PC_log;
	
begin

    PC_log_i : PC_log
    port map(
        clk => clk,
        reset => reset,
        cntrl => cntrl,
        rel => rel,
        abso => abso,
        pc => pc_ns
    );
    
	reg : 
	process(clk, reset) is
	begin
		if clk'event and clk = '1' then
	        if reset = '1' then
	            IFR_cs <= (others => '0');
	            PC_cs <= (others => '0');
	        else
	            IFR_cs <= ins;  --store data at rising edge
	            PC_cs <= PC_ns;    --store actual PC in pc register
	        end if;
	    end if; 
	end process reg;
		
	IFR <= IFR_cs;    
	pc_reg <= PC_cs;   --clocked signal to PC register output of IF stage to ID Stage
	pc <= pc_ns;       --unclocked signal to memory in IF stage
	
end architecture std_impl;
