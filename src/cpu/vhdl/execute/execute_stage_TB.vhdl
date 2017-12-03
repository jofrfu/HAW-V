-- Testbench created online at:
--   www.doulos.com/knowhow/perl/testbench_creation/
-- Copyright Doulos Ltd
-- SD, 03 November 2002

--!@file 	execute_stage_TB.vhdl
--!@brief 	This file contains the test bench for execute stage
--!@author 	Felix Lorenz
--!@date 	2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.Std_logic_1164.all;
    use IEEE.Numeric_Std.all;

entity execute_stage_tb is
end entity execute_stage_tb;

architecture beh of execute_stage_tb is

  component execute_stage
      port(
          clk, reset    : in std_logic;
          WB_CNTRL_IN   : in WB_CNTRL_TYPE;
          MA_CNTRL_IN   : in MA_CNTRL_TYPE;
          EX_CNTRL_IN   : in EX_CNTRL_TYPE;
          Imm           : in DATA_TYPE;
          OPB           : in DATA_TYPE;
          OPA           : in DATA_TYPE;
          DO_IN         : in DATA_TYPE;
          PC_IN         : in ADDRESS_TYPE;
          WB_CNTRL_OUT          : out WB_CNTRL_TYPE;
          MA_CNTRL_OUT_SYNCH    : out MA_CNTRL_TYPE;
          MA_CNTRL_OUT_ASYNCH   : out MA_CNTRL_TYPE;
          WORD_CNTRL_OUT_SYNCH  : out WORD_CNTRL_TYPE;
          WORD_CNTRL_OUT_ASYNCH : out WORD_CNTRL_TYPE;
          SIGN_EN               : out std_logic;
          RESU_DAR_SYNCH        : out DATA_TYPE;
          RESU_DAR_ASYNCH       : out DATA_TYPE;
          Branch                : out std_logic;
          ABS_OUT               : out DATA_TYPE;
          REL_OUT               : out DATA_TYPE;
          DO_OUT                : out DATA_TYPE;
          PC_OUT                : out ADDRESS_TYPE
      );
  end component;

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
  signal MA_CNTRL_OUT_SYNCH: MA_CNTRL_TYPE;
  signal MA_CNTRL_OUT_ASYNCH: MA_CNTRL_TYPE;
  signal WORD_CNTRL_OUT_SYNCH: WORD_CNTRL_TYPE;
  signal WORD_CNTRL_OUT_ASYNCH: WORD_CNTRL_TYPE;
  signal SIGN_EN: std_logic;
  signal RESU_DAR_SYNCH: DATA_TYPE;
  signal RESU_DAR_ASYNCH: DATA_TYPE;
  signal Branch: std_logic;
  signal ABS_OUT: DATA_TYPE;
  signal REL_OUT: DATA_TYPE;
  signal DO_OUT: DATA_TYPE;
  signal PC_OUT: ADDRESS_TYPE ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

    uut: 
    execute_stage 
    port map 
        (   clk                   => clk,
            reset                 => reset,
            WB_CNTRL_IN           => WB_CNTRL_IN,
            MA_CNTRL_IN           => MA_CNTRL_IN,
            EX_CNTRL_IN           => EX_CNTRL_IN,
            Imm                   => Imm,
            OPB                   => OPB,
            OPA                   => OPA,
            DO_IN                 => DO_IN,
            PC_IN                 => PC_IN,
            WB_CNTRL_OUT          => WB_CNTRL_OUT,
            MA_CNTRL_OUT_SYNCH    => MA_CNTRL_OUT_SYNCH,
            MA_CNTRL_OUT_ASYNCH   => MA_CNTRL_OUT_ASYNCH,
            WORD_CNTRL_OUT_SYNCH  => WORD_CNTRL_OUT_SYNCH,
            WORD_CNTRL_OUT_ASYNCH => WORD_CNTRL_OUT_ASYNCH,
            SIGN_EN               => SIGN_EN,
            RESU_DAR_SYNCH        => RESU_DAR_SYNCH,
            RESU_DAR_ASYNCH       => RESU_DAR_ASYNCH,
            Branch                => Branch,
            ABS_OUT               => ABS_OUT,
            REL_OUT               => REL_OUT,
            DO_OUT                => DO_OUT,
            PC_OUT                => PC_OUT 
        )
    ;


    stimulus: 
    process
    begin

        -- Reset
        stop_the_clock <= false; --just for visibility
        reset <= '1'; wait until clk'event and clk = '1';
        wait until clk'event and clk = '1';

        -- Test starts here

        -- Test ends here
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