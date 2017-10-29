--!@file     memory_access.vhdl
--!@brief    Contains eintity and standard architekrue for memeory access stage
--!@author   Sebastian Brückner
--!@date     2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@biref   This is the memory acess stage
--!@details Tasks:
--!         1. Write to RAM
--!         2. Control LOAD
--!@author  Sebastian Brückner
--!@date    2017
entity memmory_access is
    port(
        clk, reset : in std_logic;
        
        DO : in DATA_TYPE;
    );
end entity memory_access;
