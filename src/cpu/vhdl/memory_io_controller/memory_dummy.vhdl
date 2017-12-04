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