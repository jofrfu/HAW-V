use WORK.riscv_pack.all;
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity risc_v_core_tb is
end;

architecture bench of risc_v_core_tb is

  component risc_v_core
      port(
          clk, reset   : in std_logic;
          gpio_in      : in DATA_TYPE;
          gpio_out     : out DATA_TYPE
      );
  end component;

  signal clk, reset: std_logic;
  signal gpio_in: DATA_TYPE;
  signal gpio_out: DATA_TYPE ;

begin

  uut: risc_v_core port map ( clk      => clk,
                              reset    => reset,
                              gpio_in  => gpio_in,
                              gpio_out => gpio_out );

  stimulus: process
  begin
  
    -- Put initialisation code here


    -- Put test bench stimulus code here

    wait;
  end process;
    
    reset_proc:
    process is
    begin
        reset <= '1';
        wait until '1'=clk and clk'event;
        reset <= '0';
        wait;
    end process reset_proc;
    
    clk_gen:
    process is
    begin
        clk <= '1';
        wait for 20 ns;
        clk <= '0';
        wait for 20 ns;        
    end process clk_gen;

end;