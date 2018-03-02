LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.numeric_std.all;
    
use WORK.riscv_pack.all;

ENTITY blk_mem_gen_0_wrapper IS
  PORT (
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

END blk_mem_gen_0_wrapper;

architecture dummy of blk_mem_gen_0_wrapper is
        
    type memory is array (natural range 0 to 645120) of std_logic_vector(7 downto 0);
    constant instr_memory : memory := (
         x"93", x"05", x"F0", x"0F", 
         x"93", x"05", x"30", x"00",  
         x"13", x"07", x"F0", x"FF", 
         x"13", x"00", x"00", x"00", 
         x"93", x"07", x"40", x"00",         
         x"13", x"00", x"00", x"00",  
         x"13", x"00", x"00", x"00",  
         x"33", x"86", x"B5", x"00",  
         x"13", x"00", x"00", x"00",  
         x"13", x"00", x"00", x"00",  
         x"13", x"00", x"00", x"00",
         x"13", x"00", x"00", x"00",         
         x"23", x"A0", x"C7", x"00", 
         x"13", x"06", x"16", x"00", 
         x"13", x"00", x"00", x"00",  
         x"13", x"00", x"00", x"00",  
         x"13", x"00", x"00", x"00",  
         x"13", x"00", x"00", x"00",
         x"B3", x"06", x"E6", x"40", 
         x"17", x"07", x"00", x"00", 
         x"03", x"27", x"07", x"00",    
         x"6F", x"00", x"00", x"00",
        others => "00000000"
    );
    
begin
    test:
    process (ADDRA) is
        variable address : integer;
        variable instruction      : instruction_bit_type;
    begin
        address := to_integer(unsigned(ADDRA));
        
        instruction(7 downto 0)     := instr_memory(address + 0);
        instruction(15 downto 8)    := instr_memory(address + 1);
        instruction(23 downto 16)   := instr_memory(address + 2);
        instruction(31 downto 24)   := instr_memory(address + 3);
        
        DOUTA <= instruction;
            
    end process test;
        
    
    DOUTB <= std_logic_vector(to_unsigned(6, DATA_WIDTH));
end architecture dummy;