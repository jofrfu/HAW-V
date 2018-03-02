--!@brief 	This file contains memory/IO controller bench for checking memory
--!@author 	Felix Lorenz
--!@date 	21.12.2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity memory_io_controller_TB_mem is
end entity memory_io_controller_TB_mem;

architecture TB of memory_io_controller_TB_mem is

component dut is
    port(
        CLK            : IN STD_LOGIC;
        reset          : IN STD_LOGIC;
        pc_asynch      : IN ADDRESS_TYPE;
        instruction    : OUT INSTRUCTION_BIT_TYPE;
        
        EN             : IN STD_LOGIC;
        WEN            : IN STD_LOGIC;
        WORD_LENGTH    : IN WORD_CNTRL_TYPE;
        ADDR           : IN ADDRESS_TYPE;
        DIN            : IN DATA_TYPE;
        DOUT           : OUT DATA_TYPE;
        
        -- IO
        PERIPH_IN_EN   : IN  IO_ENABLE_TYPE;-- disables write access - register is written from peripheral
        PERIPH_IN      : IN  IO_BYTE_TYPE;  -- input for peripheral connections
        PERIPH_OUT     : OUT IO_BYTE_TYPE   -- output for peripheral connections 
    );
end component dut;
for all : dut use entity work.memory_io_controller(beh);
--use xilinx architecture in memory_io_controller for component blk_mem_gen_0_wrapper and load the test_memory.coe

    signal CLK: STD_LOGIC;
    signal reset: STD_LOGIC;
    signal pc_asynch: ADDRESS_TYPE := (others => '0'); 
    signal instruction: INSTRUCTION_BIT_TYPE;
    signal EN: STD_LOGIC;
    signal WEN: STD_LOGIC;
    signal WORD_LENGTH: WORD_CNTRL_TYPE;
    signal ADDR: ADDRESS_TYPE;
    signal DIN: DATA_TYPE;
    signal DOUT: DATA_TYPE;
    signal PERIPH_IN_EN: IO_ENABLE_TYPE;
    signal PERIPH_IN: IO_BYTE_TYPE;
    signal PERIPH_OUT: IO_BYTE_TYPE;
    signal simulation_running: boolean := false;
    
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
    
    clk_gen:
    process is
        begin
        wait until simulation_running = true;
        CLK <= '0';
        wait for 40 ns;
        while simulation_running loop
            CLK <= '1';
            wait for 20 ns;
            CLK <= '0';
            wait for 20 ns;
        end loop;
    end process clk_gen;
    
    test:
    process is
        procedure writeMemory(
            data        : in DATA_TYPE;
            wLength     : in WORD_CNTRL_TYPE;
            address     : in ADDRESS_TYPE
        ) is 
        begin
            EN          <= '1';
            WEN         <= '1';
            WORD_LENGTH <= wLength;
            ADDR        <= address;
            DIN         <= data;
            wait until '1'=CLK and CLK'event;
        end writeMemory;
        
        procedure readMemory(
            wLength  : in std_logic_vector(WORD_CNTRL_WIDTH-1 downto 0);
            address     : in ADDRESS_TYPE
        ) is
        begin
            EN          <= '1';
            WEN         <= '0';
            WORD_LENGTH <= wLength;
            ADDR        <= address;
            wait until '1'=CLK and CLK'event;
        end readMemory;
        
        procedure testWriteMemory(
            testWord : in DATA_TYPE;            
            wLength : in WORD_CNTRL_TYPE;
            address : in ADDRESS_TYPE;            
            errorMsg : in STRING
        ) is 
        begin
            writeMemory(testWord, wLength, address);
            readMemory(wLength, address);
            wait for 1 ns;
            if DOUT /= testWord then
                report errorMsg severity error;
                simulation_running <= false;
                wait;
            end if;
        end testWriteMemory;
        
        variable adrVal : integer range 0 to 256;
        
    begin
        simulation_running <= true;
        reset <= '1';
        wait until '1'=CLK and CLK'event;
        wait until '1'=CLK and CLK'event;
        reset <= '0';
        
        --READ Tests
        --note: the .coe-file contains data where every byte has the value of its address, defined from 0x0 to 0xFF
        --      when address is 0xAB, the value of the byte is 0xAB
        
        report "#################################################";
        report "##>>>>>>>>>>>>>>START MEMORY TEST<<<<<<<<<<<<<<##";
        report "#################################################";
        report "##>>>>>>>>>>>>>>>>>>READ TESTS<<<<<<<<<<<<<<<<<##";
        
        adrVal := 0;
        while adrVal < 256 loop --read all bytes
            readMemory(BYTE, std_logic_vector(to_unsigned(adrVal, ADDRESS_WIDTH)));
            wait for 1 ns;
            if DOUT /= std_logic_vector(to_unsigned(adrVal, ADDRESS_WIDTH)) then
                report "error while reading bytewise" severity error;
                simulation_running <= false;
                wait;
            end if;
            adrVal := adrVal + 1;
        end loop;
        
        adrVal := 0;
        while adrVal < 256 loop --loop through all words
            for offset in 0 to 2 loop --offset to distinguish between positions in words
                readMemory(HALF, std_logic_vector(to_unsigned(adrVal+offset, ADDRESS_WIDTH)));
                wait for 1 ns;
                if DOUT /= x"0000" & std_logic_vector(to_unsigned(adrVal+offset+1, BYTE_WIDTH)) & std_logic_vector(to_unsigned(adrVal+offset, BYTE_WIDTH)) then
                    case offset is
                        when 0 => report "error while reading halfbytes; offset = 0" severity error;
                        when 1 => report "error while reading halfbytes; offset = 1" severity error;
                        when 2 => report "error while reading halfbytes; offset = 2" severity error;
                    end case;                    
                    simulation_running <= false;
                    wait;
                end if;
            end loop;
            adrVal := adrVal + 4;
        end loop;
        
        adrVal := 0;
        while adrVal < 256 loop --loop through all words
            readMemory(WORD, std_logic_vector(to_unsigned(adrVal, ADDRESS_WIDTH)));
            wait for 1 ns;
            if DOUT /= std_logic_vector(to_unsigned(adrVal+3, BYTE_WIDTH)) 
                     & std_logic_vector(to_unsigned(adrVal+2, BYTE_WIDTH)) 
                     & std_logic_vector(to_unsigned(adrVal+1, BYTE_WIDTH)) 
                     & std_logic_vector(to_unsigned(adrVal, BYTE_WIDTH)) then
                report "error while reading words" severity error;
                simulation_running <= false;
                wait;
            end if;
            adrVal := adrVal + 4;
        end loop;
        
        report "#################################################";
        report "##>>>>>>>>>>>>>READ TEST SUCCESSFUL<<<<<<<<<<<<##";
        report "#################################################";
        report "##>>>>>>>>>>>>>>>>>WRITE TESTS<<<<<<<<<<<<<<<<<##";
        
        --WRITE Tests
        testWriteMemory(x"AFFEDEAD", WORD, x"00000A00", "error writing word");         
        testWriteMemory(x"0000ABBA", HALF, x"00000A00", "error writing halfword; offset = 0");  
        testWriteMemory(x"00000045", BYTE, x"00000A00", "error writing byte; offset = 0");   
        testWriteMemory(x"00001234", HALF, x"00000A01", "error writing halfword; offset = 1");
        testWriteMemory(x"0000D00D", HALF, x"00000A02", "error writing halfword; offset = 2");   
        testWriteMemory(x"00000029", BYTE, x"00000A01", "error writing byte; offset = 1");
        testWriteMemory(x"000000CE", BYTE, x"00000A02", "error writing byte; offset = 2"); 
        testWriteMemory(x"000000FA", BYTE, x"00000A03", "error writing byte; offset = 3");         
        
        
        wait until '1' = CLK and CLK'event;
        wait until '1' = CLK and CLK'event;
        wait until '1' = CLK and CLK'event;
        
        report "#################################################";
        report "##>>>>>>>>>>>>WRITE TEST SUCCESSFUL<<<<<<<<<<<<##";
        report "#################################################";
        report "##>>>>>>>>>>>>MEMORY TEST SUCCESSFUL<<<<<<<<<<<##";
        report "#################################################";
        report "";
        
        
        simulation_running <= false;
        wait;
        
    end process test;
    
end architecture TB;
