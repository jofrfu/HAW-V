--!@file    PC_log.vhdl
--!@biref   This file contains the programm counter entity of the CPU
--!@author  Sebastian Br�ckner
--!@date    2017

--!@biref   Programm counter of the CPU
--!@details Contains the Programm counter logic
--!@author  Sebastian Br�ckner
--!@date    2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity PC_log is
    port(
         clk, reset : in std_logic;
         
         cntrl  : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
         rel    : in DATA_TYPE;        --! relative branch adress
         abso    : in DATA_TYPE;        --! absolute branch adress, or base for relative jump
         
         pc : out ADDRESS_TYPE        --! programm counter output
    );
end entity PC_log;
