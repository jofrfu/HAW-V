use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity memory_io_controller_TB is
end entity memory_io_controller_TB;

architecture TB of memory_io_controller_TB is

component dut is
    port(
        CLK            : IN STD_LOGIC;
        reset          : IN STD_LOGIC;
        pc_asynch      : IN ADDRESS_TYPE;
        instruction    : OUT INSTRUCTION_BIT_TYPE;
        
        EN             : IN STD_LOGIC;
        WEN            : IN STD_LOGIC;
        WORD_LENGTH    : in WORD_CNTRL_TYPE;
        ADDR           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DIN            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DOUT           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        -- IO
        PERIPH_IN_EN   : IN  IO_ENABLE_TYPE;-- disables write access - register is written from peripheral
        PERIPH_IN      : IN  IO_BYTE_TYPE;  -- input for peripheral connections
        PERIPH_OUT     : OUT IO_BYTE_TYPE   -- output for peripheral connections 
    );
end component dut;
for all : dut use entity work.memory_io_controller(beh);

    signal CLK: STD_LOGIC;
    signal reset: STD_LOGIC;
    signal pc_asynch: ADDRESS_TYPE;
    signal instruction: INSTRUCTION_BIT_TYPE;
    signal EN: STD_LOGIC;
    signal WEN: STD_LOGIC;
    signal WORD_LENGTH: WORD_CNTRL_TYPE;
    signal ADDR: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DIN: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DOUT: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PERIPH_IN_EN: IO_ENABLE_TYPE;
    signal PERIPH_IN: IO_BYTE_TYPE;
    signal PERIPH_OUT: IO_BYTE_TYPE ;

begin

  dut_i: dut port map(
    CLK          => CLK,
    reset        => reset,
    pc_asynch    => pc_asynch,
    instruction  => instruction,
    EN           => EN,
    WEN          => WEN,
    WORD_LENGTH  => WORD_LENGTH,
    ADDR         => ADDR,
    DIN          => DIN,
    DOUT         => DOUT,
    PERIPH_IN_EN => PERIPH_IN_EN,
    PERIPH_IN    => PERIPH_IN,
    PERIPH_OUT   => PERIPH_OUT 
    );
    