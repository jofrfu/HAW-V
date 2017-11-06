-- register_select.vhd
-- created by Felix Lorenz
-- project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity register_select is
    port(   clk, reset   :   in  std_logic;
            DI           :   in  DATA_TYPE;
            rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE;
            OPA, OPB, DO :   out DATA_TYPE;
            -------- PC ports
            PC           :   in  ADDRESS_TYPE;
            PC_en        :   in  std_logic
    );--]port
end entity register_select;

architecture beh of register_select is
	
	signal reg_sel_s : REGISTER_COUNT_WIDTH;
	signal reg_out_s : reg_out_type;
	signal opb_s     : DATA_TYPE;

	component reg is
	    port(   clk, reset, csel : in std_logic;
	            reg_in           : in  DATA_TYPE;
	            reg_out          : out DATA_TYPE
	    );--]port
	end component reg;
	
begin

	register_generate:
	for i in 1 to REGISTER_COUNT-1 generate
		reg_i : reg
		port map(
			clk => clk,
			reset => reset,
			csel => reg_sel_s(i),
			reg_in => DI,
			reg_out => reg_out_s(i)
		);
	end generate;
	
	rd_demux:
	process(rd) is
	begin
		reg_sel_s <= (others => '0');
		reg_sel_s(to_integer(unsigned(rd))) <= '1';
	end process rd_demux;
	
	rs1_mux:
	process(rs1) is
	begin
        if PC_en = '1' then
            OPA <= std_logic_vector(unsigned(PC) + 4);  -- save next program count
		elsif rs1 = std_logic_vector(to_unsigned(0, REGISTER_ADDRESS_WIDTH)) then
			OPA <= (others => '0');
		else
			OPA <= reg_out_s(to_integer(unsigned(rs1)));
		end if;
	end process rs1_mux;
	
	rs2_mux:
	process(rs2) is
	begin
		if rs2 = std_logic_vector(to_unsigned(0, REGISTER_ADDRESS_WIDTH)) then
			opb_s <= (others => '0');
		else
			opb_s <= reg_out_s(to_integer(unsigned(rs2)));
		end if;
	end process rs2_mux;

    OPB <= opb_s;
	DO <= opb_s;
	
end architecture beh;