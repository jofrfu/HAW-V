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
    
    WB_CNTRL   : in WB_CNTRL_TYPE;  --!Controlbits for WB-Stage 
    MA_CNTRL   : in MA_CNTRL_TYPE;  --!Controlbits for MA-Stage 
    EX_CNTRL   : in EX_CNTRL_TYPE;  --!Controlbits for EX-Stage will be used here    
    Imm        : in DATA_TYPE;      --!Immediate
    OPB        : in DATA_TYPE;      --!Operand B
    OPA        : in DATA_TYPE;      --!Operand A
    Do         : in DATA_TYPE;      --!Data Output register
    
    WB_CNTRL   : out WB_CNTRL_TYPE; --!Controlbits for WB-Stage 
    MA_CNTRL   : out MA_CNTRL_TYPE; --!Controlbits for MB-Stage 
    RESU_DAR   : out DATA_TYPE;     --!Result of calulation
    Branch     : out std_logic;     --!For conditioned branching
    
    );
end entity execute;    