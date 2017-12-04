--!@brief 	This file contains the memory/IO controller
--!@author 	Jonas Fuhrmann + Felix Lorenz
--!@date 	2017

use WORK.riscv_pack.all;
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;   
   
entity memory_io_controller is
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
end entity memory_io_controller;
    
architecture beh of memory_io_controller is

    signal BYTE_WRITE_EN_s      : std_logic_vector(3 downto 0);
    signal DO_s                 : DATA_TYPE;
    signal DOB_s                : DATA_TYPE;    
    
    -- Little Endian signals
    signal DO_LITTLE_s             : DATA_TYPE;
    signal DOB_LITTLE_s            : DATA_TYPE;
    signal instruction_little_s    : INSTRUCTION_BIT_TYPE;
    signal DIN_LITTLE_s            : DATA_TYPE;
    
    component memory is
        Port ( 
            ena : in STD_LOGIC;
            wea : in WRITE_EN_TYPE;
            addra : in STD_LOGIC_VECTOR ( 31 downto 0 );
            dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
            douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
            clka : in STD_LOGIC;
            
            enb : in STD_LOGIC;
            web : in WRITE_EN_TYPE;
            addrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
            dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
            doutb : out STD_LOGIC_VECTOR ( 31 downto 0 );
            clkb : in STD_LOGIC
        );
    end component memory;
    for all : memory use entity work.blk_mem_gen_0_wrapper(dummy);     --entity work.blk_mem_gen_0_wrapper(xilinx)
    
    component peripherals is
        port(
            CLK            : IN  STD_LOGIC;
            RESET          : IN  STD_LOGIC;
            EN             : IN  STD_LOGIC;     -- enables access
            WEA            : IN  STD_LOGIC_vector(3 DOWNTO 0); -- enables write access
            ADDR           : IN  ADDRESS_TYPE;  -- selects peripheral
            DIN            : IN  DATA_TYPE;     -- input for selected peripheral
            DOUT           : OUT DATA_TYPE;     -- output of selected peripheral
            
            -- IO
            PERIPH_IN_EN   : IN  IO_ENABLE_TYPE;-- disables write access - register is written from peripheral
            PERIPH_IN      : IN  IO_BYTE_TYPE;  -- input for peripheral connections
            PERIPH_OUT     : OUT IO_BYTE_TYPE   -- output for peripheral connections 
        );
    end component peripherals;
    for all : peripherals use entity work.peripheral_io(beh);
    
    signal io_en : std_logic;
    signal mem_en: std_logic;
begin

    io_en <= EN and ADDR(ADDR'high);
    mem_en <= EN and not ADDR(ADDR'high);

    mem : memory
    port map(
        '1',                --always enable
        "0000",             --never write => read only
        pc_asynch,          --address is PC
        (others => '0'),    --READ ONLY, NO WRITE
        instruction_little_s,        --write to instruction ou
        CLK,
        ----------------
        mem_en,   --enable when enabled memory (when MSB is 1 is an IO access)
        BYTE_WRITE_EN_s,
        ADDR,
        DIN_LITTLE_s,
        DOB_LITTLE_s,
        CLK        
    );
    
    periph : peripherals
    port map(
        CLK,
        reset,
        io_en, -- peripheral enable
        BYTE_WRITE_EN_s,
        ADDR,
        DIN_LITTLE_s,
        DO_LITTLE_s,
        
        -- IO
        PERIPH_IN_EN,
        PERIPH_IN,
        PERIPH_OUT
    );
        
    -- little to big endian
    DOB_s <= DOB_LITTLE_s( 7 downto  0) & DOB_LITTLE_s(15 downto  8) &
             DOB_LITTLE_s(23 downto 16) & DOB_LITTLE_s(31 downto 24);
    
    DO_s  <= DO_LITTLE_s( 7 downto  0) & DO_LITTLE_s(15 downto  8) &
             DO_LITTLE_s(23 downto 16) & DO_LITTLE_s(31 downto 24);
    
    instruction <= instruction_little_s( 7 downto  0) & instruction_little_s(15 downto  8) &
                   instruction_little_s(23 downto 16) & instruction_little_s(31 downto 24);
    
    -- big to little endian
    DIN_LITTLE_s <= DIN( 7 downto  0) & DIN(15 downto  8) &
                    DIN(23 downto 16) & DIN(31 downto 24);
    
    dout_mux:
    process(DOB_s, DO_s, ADDR(ADDR'high)) is
        variable io_not_mem : std_logic;
        variable dout_v     : DATA_TYPE;
    begin
        io_not_mem  := ADDR(ADDR'high);
        if io_not_mem = '1' then
            dout_v := DO_s;
        else
            dout_v := DOB_s;
        end if;
        DOUT <= dout_v;
    end process dout_mux;
    
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
    
end architecture beh;