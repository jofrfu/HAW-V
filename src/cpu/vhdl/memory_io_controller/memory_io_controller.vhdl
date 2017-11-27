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
        
        GPIO_IN        : IN DATA_TYPE;      --0x70000000 to 0x70000003
        GPIO_OUT       : OUT DATA_TYPE      --0xB0000000 to 0xB0000003
    );
end entity memory_io_controller;
    
architecture beh of memory_io_controller is

    signal BYTE_WRITE_EN_s      : std_logic_vector(3 downto 0);
    signal DO_s                 : DATA_TYPE;
    signal DOB_s                : DATA_TYPE;
    signal gpio_en_s            : std_logic;
    
    --GPIO Registers
    signal gpio_out_reg_cs  : DATA_TYPE := (others => '0');
    signal gpio_out_reg_ns  : DATA_TYPE;
    signal gpio_in_reg_cs   : DATA_TYPE := (others => '0');
    signal gpio_in_reg_ns   : DATA_TYPE;
    
    
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
    
    
begin
    mem : memory
    port map(
        '1',                --always enable
        "0000",             --never write => read only
        pc_asynch,          --address is PC
        (others => '0'),    --READ ONLY, NO WRITE
        instruction,        --write to instruction ou
        CLK,
        ----------------
        EN and not ADDR(ADDR'high),   --enable when enabled memory (when MSB is 1 is an IO access)
        BYTE_WRITE_EN_s,
        ADDR,
        DIN,
        DOB_s,
        CLK        
    );
    
    gpio:
    process(gpio_en_s, DIN, ADDR, BYTE_WRITE_EN_s, gpio_in_reg_cs, gpio_out_reg_cs) is
        variable gpio_en_v          : std_logic;
        variable DIN_v              : DATA_TYPE;
        variable ADDR_v             : ADDRESS_TYPE;
        variable BYTE_WRITE_EN_v    : WRITE_EN_TYPE;
        variable DOUT_v             : DATA_TYPE;
        variable gpio_out_v         : DATA_TYPE;
    begin
        gpio_en_v       := gpio_en_s;       
        DIN_v           := DIN;          
        ADDR_v          := ADDR;         
        BYTE_WRITE_EN_v := BYTE_WRITE_EN_s;
        DOUT_v          := (others => '0');
        gpio_out_v      := (others => '0');
        
        if gpio_en_v = '1' then
            if BYTE_WRITE_EN_v = "0000" then
                case ADDR_v is 
                    when x"70000000" => DOUT_v := gpio_in_reg_cs;
                    when x"B0000000" => DOUT_v := gpio_out_reg_cs;
                    when others => report "WRONG ADDRESS FOR GPIO" severity error;
                end case;
            else
                case BYTE_WRITE_EN_v is
                    when "0001" => 
                        gpio_out_v (7 downto 0)  := DIN_v(7 downto 0); 
                    when "0011" => 
                        gpio_out_v (15 downto 0) := DIN_v(15 downto 0); 
                    when "1111" => 
                        gpio_out_v (31 downto 0)  := DIN_v(31 downto 0); 
                    when others =>
                        report "failure in gpio: byte_write_en" severity error;
                end case;
                DOUT_v := gpio_out_v;
            end if;
            gpio_out_reg_ns <= gpio_out_v;
            DOUT <= DOUT_v;
        end if;
        
    end process gpio;
    
    --gpio enable
    gpio_en_s <= EN AND ADDR(ADDR'high);
    
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
    
    sequ_log:       --only for GPIOs
	process(clk) is
	begin
		if clk'event and clk = '1' then
            if reset = '1' then
                gpio_out_reg_cs <= (others => '0');
                gpio_in_reg_cs  <= (others => '0');
            else
            	gpio_out_reg_cs <= gpio_out_reg_ns;
                gpio_in_reg_cs  <= gpio_in_reg_ns ;
            end if;
        end if; 
	end process sequ_log;    
    
    gpio_in_reg_ns <= GPIO_IN;
    GPIO_OUT <= gpio_out_reg_cs;
    
end architecture beh;