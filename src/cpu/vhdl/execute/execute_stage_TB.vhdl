-- Testbench created online at:
--   www.doulos.com/knowhow/perl/testbench_creation/
-- Copyright Doulos Ltd
-- SD, 03 November 2002

--!@file 	execute_stage_TB.vhdl
--!@brief 	This file contains the test bench for execute stage
--!@author 	Felix Lorenz
--!@date 	2017


library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity execute_stage_tb is
end entity execute_stage_tb;

architecture beh of execute_stage_tb is

  component execute_stage
      port(
          clk, reset : in std_logic;
          WB_CNTRL_IN   : in WB_CNTRL_TYPE;
          MA_CNTRL_IN   : in MA_CNTRL_TYPE;
          EX_CNTRL_IN   : in EX_CNTRL_TYPE;
          Imm           : in DATA_TYPE;
          OPB           : in DATA_TYPE;
          OPA           : in DATA_TYPE;
          DO_IN         : in DATA_TYPE;
          PC_IN         : in ADDRESS_TYPE;
          WB_CNTRL_OUT  : out WB_CNTRL_TYPE;
          MA_CNTRL_OUT  : out MA_CNTRL_TYPE;
          WORD_CNTRL_OUT: out WORD_CNTRL_TYPE;
          SIGN_EN       : out std_logic;
          RESU_DAR      : out DATA_TYPE;
          Branch        : out std_logic;
          ABS_OUT       : out DATA_TYPE;
          REL_OUT       : out DATA_TYPE;
          DO_OUT        : out DATA_TYPE;
          PC_OUT        : out ADDRESS_TYPE
      );
  end component;
  for all : execute_stage use entity work.execute_stage(beh);

  signal clk, reset: std_logic;
  signal WB_CNTRL_IN: WB_CNTRL_TYPE;
  signal MA_CNTRL_IN: MA_CNTRL_TYPE;
  signal EX_CNTRL_IN: EX_CNTRL_TYPE;
  signal Imm: DATA_TYPE;
  signal OPB: DATA_TYPE;
  signal OPA: DATA_TYPE;
  signal DO_IN: DATA_TYPE;
  signal PC_IN: ADDRESS_TYPE;
  signal WB_CNTRL_OUT: WB_CNTRL_TYPE;
  signal MA_CNTRL_OUT: MA_CNTRL_TYPE;
  signal WORD_CNTRL_OUT: WORD_CNTRL_TYPE;
  signal SIGN_EN: std_logic;
  signal RESU_DAR: DATA_TYPE;
  signal Branch: std_logic;
  signal ABS_OUT: DATA_TYPE;
  signal REL_OUT: DATA_TYPE;
  signal DO_OUT: DATA_TYPE;
  signal PC_OUT: ADDRESS_TYPE ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

    dut : execute_stage 
    port map ( 
        clk            => clk,
        reset          => reset,
        WB_CNTRL_IN    => WB_CNTRL_IN,
        MA_CNTRL_IN    => MA_CNTRL_IN,
        EX_CNTRL_IN    => EX_CNTRL_IN,
        Imm            => Imm,
        OPB            => OPB,
        OPA            => OPA,
        DO_IN          => DO_IN,
        PC_IN          => PC_IN,
        WB_CNTRL_OUT   => WB_CNTRL_OUT,
        MA_CNTRL_OUT   => MA_CNTRL_OUT,
        WORD_CNTRL_OUT => WORD_CNTRL_OUT,
        SIGN_EN        => SIGN_EN,
        RESU_DAR       => RESU_DAR,
        Branch         => Branch,
        ABS_OUT        => ABS_OUT,
        REL_OUT        => REL_OUT,
        DO_OUT         => DO_OUT,
        PC_OUT         => PC_OUT 
    );

    stimulus: 
    process
    begin

        -- Reset
        stop_the_clock <= false; --just for visibility
        reset <= '1'; wait for clk'event and clk = '1';
        wait for clk'event and clk = '1';

        -- Test starts here

        stop_the_clock <= true;
        wait;
    end process;

    clocking: 
    process
    begin
        while not stop_the_clock loop
          clk <= '0', '1' after clock_period / 2;
          wait for clock_period;
        end loop;
        wait;
    end process;

end architecture beh;