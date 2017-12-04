use WORK.riscv_pack.all;
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity risc_v_core_tb is
end;

architecture beh of risc_v_core_tb is

    component dut
        port(
            clk, reset    : in std_logic;
            pc_asynch     : out ADDRESS_TYPE;
            instruction   : in  INSTRUCTION_BIT_TYPE;
            EN            : out std_logic;
            WEN           : out std_logic;
            WORD_LENGTH   : out WORD_CNTRL_TYPE;
            ADDR          : out ADDRESS_TYPE;
            D_CORE_to_MEM : out DATA_TYPE;
            D_MEM_to_CORE : in  DATA_TYPE
        );
    end component;
    for all : dut use entity work.risc_v_core(beh);

    component memory
        port(
              --Inputs - Port A
            ENA            : IN STD_LOGIC;  --opt port
          
            WEA            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            ADDRA          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          
            DINA           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          
            DOUTA          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
          
            CLKA           : IN STD_LOGIC;

          
              --Inputs - Port B
            ENB            : IN STD_LOGIC;  --opt port
          
            WEB            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            ADDRB          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
          
            DINB           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DOUTB          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            CLKB           : IN STD_LOGIC
        );
    end component;
    for all : memory use entity work.blk_mem_gen_0_wrapper(dummy);
    
    constant cycles2execute : integer := 100;
    constant clock_period   : time    := 20 ns;
    
    signal clk, reset: std_logic;
    signal pc_asynch: ADDRESS_TYPE;
    signal instruction: INSTRUCTION_BIT_TYPE;
    signal EN: std_logic;
    signal WEN: std_logic;
    signal WORD_LENGTH: WORD_CNTRL_TYPE;
    signal ADDR: ADDRESS_TYPE;
    signal D_CORE_to_MEM: DATA_TYPE;
    signal D_MEM_to_CORE: DATA_TYPE ;
    
    signal BYTE_WRITE_EN_s      : std_logic_vector(3 downto 0);

begin

    dut_i : dut 
    port map ( 
        clk           => clk,
        reset         => reset,
        --Instruction Memory
        pc_asynch     => pc_asynch,
        instruction   => instruction,
        --Data Memory
        EN            => EN,
        WEN           => WEN,
        WORD_LENGTH   => WORD_LENGTH,
        ADDR          => ADDR,
        D_CORE_to_MEM => D_CORE_to_MEM,
        D_MEM_to_CORE => D_MEM_to_CORE      
    );
    
    mem_i : memory
    port map (
        ENA         => '1',             --always enable
        WEA         => "0000",          --never write => read only
        ADDRA       => pc_asynch,       --address is PC
        DINA        => (others => '0'), --READ ONLY, NO WRITE
        DOUTA       => instruction,     --write to instruction reg
        CLKA        => clk,
          --Inputs - Port B
        ENB         => EN,
        WEB         => BYTE_WRITE_EN_s,
        ADDRB       => ADDR,
        DINB        => D_CORE_to_MEM,
        DOUTB       => D_MEM_to_CORE,
        CLKB        =>  clk
    );
    
    write_en:
    process(WORD_LENGTH, WEN) is
        variable WORD_LENGTH_v   : WORD_CNTRL_TYPE;
        variable WRITE_EN_v      : std_logic;
        variable BYTE_WRITE_EN_v : WRITE_EN_TYPE;
    begin
        WORD_LENGTH_v := WORD_LENGTH;
        WRITE_EN_v    := WEN;
        
        if WRITE_EN_v = '1' then
            case WORD_LENGTH_v is
                when BYTE =>
                    BYTE_WRITE_EN_v := "0001";
                when HALF =>
                    BYTE_WRITE_EN_v := "0011";
                when WORD =>
                    BYTE_WRITE_EN_v := "1111";
                when others =>
                    BYTE_WRITE_EN_v := "0000";
                    report "Unknown word length in write_en conversion! Probable faulty implementation." severity warning;
            end case;
        else
            BYTE_WRITE_EN_v := "0000";
        end if;
        
        BYTE_WRITE_EN_s <= BYTE_WRITE_EN_v;
    end process write_en;
    
    reset_proc:
    process is
    begin
        reset <= '1';
        wait until '1'=clk and clk'event;
        wait until '1'=clk and clk'event;
        wait until '1'=clk and clk'event;
        reset <= '0';
        wait;
    end process reset_proc;
    
    clk_gen:
    process is
    begin
        while reset = '1' loop
            clk <= '0', '1' after clock_period / 2;
            wait for clock_period;
        end loop;
        for cycle in 1 to cycles2execute loop
            clk <= '0', '1' after clock_period / 2;
            wait for clock_period;   
        end loop;
        wait;
    end process clk_gen;

end beh;