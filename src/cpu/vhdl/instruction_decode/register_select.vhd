--!@file register_select.vhd
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author Felix Lorenz
--!@author Jonas Fuhrmann
--!@author Matthis Keppner
--!@author Sebastian Brückner

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@brief   Manages register read and write
--!@details Is capeable of reading two registers per clock and writing one


--!         Note that you can't read the old value and store a new one in the same register on the same rising edge.
--!         The value of DI is always stored to a register, if the value is not needed, store to r0
entity register_select is
    port(   clk, reset   :   in  std_logic;
            DI           :   in  DATA_TYPE;             --!data to write to rd
            rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE; --!rs1 and rs2 are the registers to read, rd is the register to write
            OPA, OPB, DO :   out DATA_TYPE;             --!OPA contains rs1 value or PC log, OPB and DO contain rs2 value
            -------- PC ports
            PC           :   in  ADDRESS_TYPE;          --!Programm Counter
            PC_en        :   in  std_logic              --!Enable loading Programm Counter
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
    
    reg_out_s(0) <= std_logic_vector(to_unsigned(0,DATA_WIDTH));
    
    rd_demux:
    process(rd) is
    begin
        reg_sel_s <= (others => '0');
        reg_sel_s(to_integer(unsigned(rd))) <= '1';
    end process rd_demux;
    
    rs1_mux:
    process(rs1, pc_en, PC, reg_out_s) is
    begin
        if PC_en = '1' then
            OPA <= std_logic_vector(unsigned(PC) - to_unsigned(4, DATA_WIDTH));
        else
            OPA <= reg_out_s(to_integer(unsigned(rs1)));
        end if;
    end process rs1_mux;
    
    rs2_mux:
    process(rs2, reg_out_s) is
    begin
        opb_s <= reg_out_s(to_integer(unsigned(rs2)));
    end process rs2_mux;

    OPB <= opb_s;
    DO <= opb_s;
    
end architecture beh;