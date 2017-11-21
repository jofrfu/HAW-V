--!@file   alu_TB.vhdl
--!@brief  Contains TB for the alu
--!@author Sebastian Brueckner
--!@date   2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity alu_TB is 
end entity alu_TB;

architecture TB of alu_TB is
    
    component dut is
    port(
        OPB         : in DATA_TYPE;
        OPA         : in DATA_TYPE;
        EX_CNTRL_IN : in EX_CNTRL_TYPE;
        
        Flags       : out FLAGS_TYPE;
        Resu        : out DATA_TYPE
    );
    end component dut;
    
    --Input
    signal OPB_s : DATA_TYPE => (others => '0');
    signal OPA_s : DATA_TYPE => (others => '0');
    signal EX_CNTRL_IN_s : EX_CNTRL_TYPE => (others => '0');
    --Output
    signal Falgs_s : FLAGS_TYPE;
    signal Resu : DATA_TYPE;
    
begin

end architecture TB;