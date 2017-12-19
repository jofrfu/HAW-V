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
    for all : memory use entity work.blk_mem_gen_0_wrapper(dummy_bmem);     --entity work.blk_mem_gen_0_wrapper(xilinx)
    
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
    instruction <= instruction_little_s( 7 downto  0) & instruction_little_s(15 downto  8) &
                   instruction_little_s(23 downto 16) & instruction_little_s(31 downto 24);
				   
    dout_conv:		--for LOAD
	process(ADDR(1 downto 0), DOB_LITTLE_s, WORD_LENGTH) is
		variable offset_v : std_logic_vector(1 downto 0);
		variable dob_little_v : DATA_TYPE;
		variable word_length_v : WORD_CNTRL_TYPE;
		variable dout_v : DATA_TYPE;
	begin
		offset_v := ADDR(1 downto 0);
		dob_little_v := DOB_LITTLE_s;
		word_length_v := WORD_LENGTH;
		dout_v := (others => '0');
		
		case offset_v is
			when "00" =>
				case word_length_v is
					when BYTE =>
						dout_v(7 downto 0) := dob_little_v (7 downto 0);
					when HALF =>
						dout_v(7 downto 0) := dob_little_v(15 downto 8);
						dout_v(15 downto 8) := dob_little_v(7 downto 0);
					when WORD =>
						dout_v(7 downto 0) := dob_little_v(31 downto 24);
						dout_v(15 downto 8) := dob_little_v(23 downto 16);
						dout_v(23 downto 16) := dob_little_v(15 downto 8);
						dout_v(31 downto 24) := dob_little_v(7 downto 0);
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(00) word_length" severity error;
				end case;
			when "01" =>
				case word_length_v is
					when BYTE =>
						dout_v(7 downto 0) := dob_little_v (15 downto 8);
					when HALF =>
						dout_v(7 downto 0) := dob_little_v(23 downto 16);
						dout_v(15 downto 8) := dob_little_v(15 downto 8);
					when WORD =>
						dout_v(15 downto 8) := dob_little_v(31 downto 24);
						dout_v(23 downto 16) := dob_little_v(23 downto 16);
						dout_v(31 downto 24) := dob_little_v(15 downto 8);
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(01) word_length" severity error;
				end case;
			when "10" =>
				case word_length_v is
					when BYTE =>
						dout_v(7 downto 0) := dob_little_v (23 downto 16);
					when HALF =>
						dout_v(7 downto 0) := dob_little_v(31 downto 24);
						dout_v(15 downto 8) := dob_little_v(23 downto 16);
					when WORD =>
						dout_v(23 downto 16) := dob_little_v(31 downto 24);
						dout_v(31 downto 24) := dob_little_v(23 downto 16);
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(10) word_length" severity error;
				end case;
			when "11" =>
				case word_length_v is
					when BYTE =>
						dout_v(7 downto 0) := dob_little_v (31 downto 24);
					when HALF =>
						dout_v(15 downto 8) := dob_little_v(31 downto 24);
					when WORD =>
						dout_v(31 downto 24) := dob_little_v(31 downto 24);						
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(11) word_length" severity error;
				end case;
			when others =>
				report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v" severity error;
		end case;
		
		DOB_s <= dout_v;
		
	end process dout_conv;
    
    -- big to little endian
    din_conv:		--for STORE
	process(ADDR(1 downto 0), DIN, WORD_LENGTH) is
		variable offset_v : std_logic_vector(1 downto 0);
		variable din_v : DATA_TYPE;
		variable word_length_v : WORD_CNTRL_TYPE;
		variable din_little_v : DATA_TYPE;
	begin
		offset_v := ADDR(1 downto 0);
		din_v := DIN;
		word_length_v := WORD_LENGTH;
		din_little_v := (others => '0');
		
		case offset_v is
			when "00" =>
				case word_length_v is
					when BYTE =>
						din_little_v(7 downto 0) := din_v(7 downto 0);
					when HALF =>
						din_little_v(7 downto 0) := din_v(15 downto 8);
						din_little_v(15 downto 8) := din_v(7 downto 0);
					when WORD =>
						din_little_v(7 downto 0) := din_v(31 downto 24);
						din_little_v(15 downto 8) := din_v(23 downto 16);
						din_little_v(23 downto 16) := din_v(15 downto 8);
						din_little_v(31 downto 24) := din_v(7 downto 0);
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(00) word_length" severity error;
				end case;
			when "01" =>
				case word_length_v is
					when BYTE =>
						din_little_v(7 downto 0) := din_v (15 downto 8);
					when HALF =>
						din_little_v(7 downto 0) := din_v(23 downto 16);
						din_little_v(15 downto 8) := din_v(15 downto 8);
					when WORD =>
						din_little_v(15 downto 8) := din_v(31 downto 24);
						din_little_v(23 downto 16) := din_v(23 downto 16);
						din_little_v(31 downto 24) := din_v(15 downto 8);
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(01) word_length" severity error;
				end case;
			when "10" =>
				case word_length_v is
					when BYTE =>
						din_little_v(7 downto 0) := din_v (23 downto 16);
					when HALF =>
						din_little_v(7 downto 0) := din_v(31 downto 24);
						din_little_v(15 downto 8) := din_v(23 downto 16);
					when WORD =>
						din_little_v(23 downto 16) := din_v(31 downto 24);
						din_little_v(31 downto 24) := din_v(23 downto 16);
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(10) word_length" severity error;
				end case;
			when "11" =>
				case word_length_v is
					when BYTE =>
						din_little_v(7 downto 0) := din_v (31 downto 24);
					when HALF =>
						din_little_v(15 downto 8) := din_v(31 downto 24);
					when WORD =>
						din_little_v(31 downto 24) := din_v(31 downto 24);						
					when others =>
						report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v(11) word_length" severity error;
				end case;
			when others =>
				report "memory_io_controller.vhdl: unsupported case in dout_conv offset_v" severity error;
		end case;
		
		DIN_LITTLE_s <= din_little_v;
		
	end process din_conv;
    
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