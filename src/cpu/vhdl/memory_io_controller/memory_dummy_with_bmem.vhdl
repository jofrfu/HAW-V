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

architecture dummy_bmem of blk_mem_gen_0_wrapper is
    signal douta_ns : instruction_bit_type;
    signal douta_cs : instruction_bit_type := (others => '0');
    signal b_REG   : DATA_TYPE := (others => '0');
    signal dout_cs : DATA_TYPE := (others => '0');
    --type BMEM is array(10 downto 0) of DATA_TYPE;
    
    
    
begin
    test_portA:
    process (ADDRA) is
        variable address : integer;
        variable instruction      : instruction_bit_type;
    begin
        address := to_integer(unsigned(ADDRA));
        case address is
            when 0 =>
                instruction := (others => '0');
                --instruction := IFR_I_TYPE(-2, 0, ADDI_FUNCT3, 2, opimmo); -- addi x2, x0, -2
            when 4 =>
                instruction := (others => '1'); -- addi x1, x0, -1
            when 8 =>
                instruction := NOP_INSTRUCT;
            when 12 =>
                instruction := NOP_INSTRUCT;
            when 16 =>
                instruction := NOP_INSTRUCT;
            when 20 =>
                instruction := NOP_INSTRUCT;
            when 24 =>
                instruction := NOP_INSTRUCT;
            when 28 =>
                instruction := IFR_R_TYPE(ADD_FUNCT7, 2, 1, ADD_FUNCT3, 3, opo); --add x3, x1, x2
            when 32 =>
                instruction := NOP_INSTRUCT;
            when 36 =>
                instruction := NOP_INSTRUCT;
            when 40 =>
                instruction := NOP_INSTRUCT;
            when 44 =>
                instruction := NOP_INSTRUCT;
            when 48 =>
                instruction := NOP_INSTRUCT;
            when others =>
                report "end of instruction memory";
                instruction := NOP_INSTRUCT;
        end case;
        douta_ns <= instruction;
        
            
    end process test_portA;
    
        test_portB:
    process (ADDRB, ENB, WEB, DINB) is
        variable address : integer;
        variable instruction      : instruction_bit_type;
        --variable dout_array       : BMEM; --just for testing
        variable dout             : DATA_TYPE;
        variable din              : DATA_TYPE;
    begin
        address := to_integer(unsigned(ADDRB));
        din     := DINB;
        if ENB = '1' then
            case WEB is      --write into mem 
                when "0001" =>     
                   dout := DINB;
                when "0011" =>
                    dout := DINB;
                when "1111" =>
                    dout := DINB;
                when "0000" =>     --read from mem
                    dout := b_REG;
                when others =>  
                    dout := b_REG;
                    report "ERROR with WEB" severity ERROR;            
            end case;
        else 
            dout := b_REG;
        end if;
        b_REG <= dout;
            
        
         
    end process test_portB;
    
    reg :
    process(CLKB) is
    begin
        if CLKB'event and CLKB = '1' then
        douta_cs <= douta_ns;
        dout_cs <= b_REG;
        end if;
        DOUTB <= dout_cs;
        DOUTA <= douta_cs;
    end process reg;        
    
    
end architecture dummy_bmem;