--!@file 	instruction_fetch_arch.vhdl
--!@biref 	Contaons Standard architecture for instruction_fetch
--!@author 	Sebastian Brückner
--!@date 	2017

--!@biref 	Programm counter of the CPU
--!@details Contains the Programm counter logic
--!@author 	Sebastian Brückner
--!@date 	2017
architecture std_impl of instruction_fetch is 
	signal IFR_cs : ADRESS_TYPE := (others => '0');
begin

	

	reg : process(clk, reset) is
	begin
		if clk'event and clk = '1' then
	        if nres = '1' then
	            IFR_cs <= (others => '0');
	        else
	            IFR_cs <= ins;  --store data at rising edge
	        end if;
	    end if; 
	end process reg;
		
	
end architecture std_impl;
