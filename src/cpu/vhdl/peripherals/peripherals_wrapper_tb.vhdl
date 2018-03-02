--!@brief 	This file contains peripheral_wrapper test bench code
--!@author 	Felix Lorenz
--!@date 	2017

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

use WORK.riscv_pack.all;

entity peripherals_wrapper_tb is
end entity peripherals_wrapper_tb;

architecture bench of peripherals_wrapper_tb is

  component peripherals_wrapper
      port(
          clk, reset      : in std_logic;
          PERIPH_WRITE_EN : out   IO_ENABLE_TYPE;
          PERIPH_to_MEM   : out   IO_BYTE_TYPE;
          MEM_to_PERIPH   : in    IO_BYTE_TYPE;
          PERIPH_BIT_IO   : inout PERIPH_IO_TYPE
      );
  end component;

  signal clk, reset: std_logic;
  signal PERIPH_WRITE_EN: IO_ENABLE_TYPE;
  signal PERIPH_to_MEM: IO_BYTE_TYPE;
  signal MEM_to_PERIPH: IO_BYTE_TYPE;
  signal PERIPH_BIT_IO: PERIPH_IO_TYPE ;

begin

  uut: peripherals_wrapper port map ( clk             => clk,
                                      reset           => reset,
                                      PERIPH_WRITE_EN => PERIPH_WRITE_EN,
                                      PERIPH_to_MEM   => PERIPH_to_MEM,
                                      MEM_to_PERIPH   => MEM_to_PERIPH,
                                      PERIPH_BIT_IO   => PERIPH_BIT_IO );

  stimulus: process
  begin
  
    -- Put initialisation code here
    

    -- Put test bench stimulus code here

    wait;
  end process;


end;