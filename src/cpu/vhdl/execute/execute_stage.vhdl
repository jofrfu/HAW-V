--!@file 	execute_stage.vhdl
--!@brief 	This file contains the execute stage entity of the CPU
--!@author 	Matthis Keppner
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;
--!@brief 	This is the execute stage of the CPU
--!@details This Stage contains the AlU, which calculates
--!@author 	Matthis Keppner
--!@date 	2017
entity execute is
    port(
    clk, reset : in std_logic;
    
    WB_CNTRL   : in WB_CNTRL_TYPE;  --! 
    MA_CNTRL   : in MA_CNTRL_TYPE;  --! 
    EX_CNTRL   : in EX_CNTRL_TYPE;  --! 
    Imm        : in DATA_TYPE;      --!
    OPB        : in DATA_TYPE;      --!
    OPA        : in DATA_TYPE;      --!
    Do         : in DATA_TYPE;      --!
    
    WB_CNTRL   : out WB_CNTRL_TYPE; --!
    MA_CNTRL   : out MA_CNTRL_TYPE; --!
    RESU_DAR   : out DATA_TYPE;     --!
    
    );
end entity execute;    