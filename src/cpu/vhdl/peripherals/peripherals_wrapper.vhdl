--!@brief 	This file contains the peripherals
--!@author 	Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity peripherals_wrapper is
    port(
        clk, reset      : in    std_logic;
        
        ENABLE          : in    std_logic;
        ADDRESS         : in    ADDRESS_TYPE;
        
        -- memory connections
        PERIPH_WRITE_EN : out   IO_ENABLE_TYPE;
        PERIPH_to_MEM   : out   IO_BYTE_TYPE;
        MEM_to_PERIPH   : in    IO_BYTE_TYPE;
        
        -- top level connections
        PERIPH_BIT_IO   : inout PERIPH_IO_TYPE
    );
end entity peripherals_wrapper;

architecture beh of peripherals_wrapper is

    component uart is
        generic (
            baud                : positive;
            clock_frequency     : positive
        );
        port (  
            clock               :   in  std_logic;
            reset               :   in  std_logic;    
            data_stream_in      :   in  std_logic_vector(7 downto 0);
            data_stream_in_stb  :   in  std_logic;
            data_stream_in_ack  :   out std_logic;
            data_stream_out     :   out std_logic_vector(7 downto 0);
            data_stream_out_stb :   out std_logic;
            tx                  :   out std_logic;
            rx                  :   in  std_logic
        );
    end component uart;
    
    signal strobe_flag_s  : std_logic;
    signal strobe_flag_cs : std_logic := '0';
    signal strobe_flag_ns : std_logic;

begin
    GPIO:
    process(MEM_to_PERIPH(0 to 2*GPIO_WIDTH-1), PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0)) is
        variable MEM_to_PERIPH_CONF_v : GPIO_TYPE;
        variable MEM_to_PERIPH_GPIO_v : GPIO_TYPE;
        variable PERIPH_BIT_IO_v : std_logic_vector(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        variable PERIPH_BIT_IN_v : std_logic_vector(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        
        variable PERIPH_to_MEM_v   : GPIO_TYPE;
    begin
        for i in 0 to GPIO_WIDTH-1 loop
            MEM_to_PERIPH_CONF_v(i) := MEM_to_PERIPH(i);
        end loop;
        
        for i in 0 to GPIO_WIDTH-1 loop
            MEM_to_PERIPH_GPIO_v(i) := MEM_to_PERIPH(GPIO_WIDTH + i);
        end loop;
        
        PERIPH_BIT_IO_v := PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        PERIPH_BIT_IN_v := PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        
        for i in 0 to GPIO_WIDTH-1 loop
            for j in BYTE_WIDTH-1 downto 0 loop
                if MEM_to_PERIPH_CONF_v(i)(j) = '0' then
                    PERIPH_BIT_IO_v(i*BYTE_WIDTH + j) := MEM_to_PERIPH_GPIO_v(i)(j);
                    PERIPH_to_MEM_v(i)(j) := '0';
                else
                    PERIPH_BIT_IO_v(i*BYTE_WIDTH + j) := 'Z';
                    PERIPH_to_MEM_v(i)(j) := PERIPH_BIT_IN_v(i*BYTE_WIDTH + j);
                end if;
            end loop;
        end loop;
        
        PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0) <= PERIPH_BIT_IO_v;
        PERIPH_WRITE_EN(0 to GPIO_WIDTH-1) <= (others => (others => '0'));
        
        for i in GPIO_WIDTH to 2* GPIO_WIDTH-1 loop
            PERIPH_WRITE_EN(i) <= MEM_to_PERIPH_CONF_v(i - GPIO_WIDTH);
            PERIPH_to_MEM(i) <= PERIPH_to_MEM_v(i - GPIO_WIDTH);
        end loop;
        
        PERIPH_to_MEM(0 to GPIO_WIDTH-1)    <= (others => (others => '0'));
    end process GPIO;
    
    uart_i : uart
    generic map(
        9600,
        50000000
    )
    
    port map(
        clk,
        reset,
        ----
        MEM_to_PERIPH(2*GPIO_WIDTH),
        MEM_to_PERIPH(2*GPIO_WIDTH+1)(0),
        PERIPH_to_MEM(2*GPIO_WIDTH+1)(1),
        PERIPH_to_MEM(2*GPIO_WIDTH+2),
        strobe_flag_s,
        ----
        PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH),
        PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH+1)
    );
    
    PERIPH_WRITE_EN(2*GPIO_WIDTH) <= (others => '0');
    PERIPH_to_MEM(2*GPIO_WIDTH) <= (others => '0');
    PERIPH_WRITE_EN(2*GPIO_WIDTH+1)(0) <= '0';
    PERIPH_WRITE_EN(2*GPIO_WIDTH+1)(1) <= '1';
    PERIPH_WRITE_EN(2*GPIO_WIDTH+1)(BYTE_WIDTH-1 downto 2) <= (others => '1');
    PERIPH_to_MEM(2*GPIO_WIDTH+1)(BYTE_WIDTH-1 downto 2) <= (others => '0');
    PERIPH_WRITE_EN(2*GPIO_WIDTH+2) <= (others => '1');
    PERIPH_WRITE_EN(2*GPIO_WIDTH+3) <= (others => '1');
    
    strobe_proc:
    process(strobe_flag_s, strobe_flag_cs, ENABLE, ADDRESS) is
    begin 
        if ENABLE = '1' and ADDRESS = '1' & std_logic_vector(to_unsigned(2*GPIO_WIDTH+3, 31)) then
            strobe_flag_ns <= strobe_flag_s;
        else
            if strobe_flag_cs = '1' then
                strobe_flag_ns <= '1';
            else
                strobe_flag_ns <= strobe_flag_s;
            end if;
        end if;
        
        PERIPH_to_MEM(2*GPIO_WIDTH+3)(0) <= strobe_flag_cs;
        PERIPH_to_MEM(2*GPIO_WIDTH+3)(BYTE_WIDTH-1 downto 1) <= (others => '0');
    end process strobe_proc;
    
    sequlo:
    process(clk) is
    begin
        if clk='1' and clk'event then
            if reset = '1' then
                strobe_flag_cs <= '0';
            else
                strobe_flag_cs <= strobe_flag_ns;
            end if;
        end if;
    end process sequlo;
    
end architecture beh;
