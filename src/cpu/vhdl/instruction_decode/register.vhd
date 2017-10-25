use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity reg is
    port(   clk, reset, csel : in std_logic;
            reg_in           : in  DATA_TYPE;
            reg_out          : out DATA_TYPE
    );--]port
end entity reg;

architecture beh of reg is
begin

    store:
    process(clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                reg_out <= (others => '0');
            elsif csel = '1' then
                reg_out <= reg_in;  --store data at rising edge
            else
            	null;
            end if;
        end if; 
    end process store;

end architecture beh;
            