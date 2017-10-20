-- register_select.vhd
-- created by Felix Lorenz
-- project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all
    
entity register_select is
    port(   clk, reset   :   in  std_logic;
            DI           :   in  DATA_TYPE;
            rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE;
            OPA, OPB, DO :   out DATA_TYPE
    );--]port
end entity register_select;

architecture beh of register_select is



end architecture beh;