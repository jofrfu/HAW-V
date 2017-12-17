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
    signal dout_cs : DATA_TYPE;
    type BMEM is array(10 downto 0) of DATA_TYPE; 
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
                instruction := IFR_I_TYPE(-1, 0, ADDI_FUNCT3, 1, opimmo); -- addi x1, x0, -1
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
        
        DOUTA <= instruction;
            
    end process test_portA;
    
        test_portB:
    process (ADDRB, ENB, WEB, DINB) is
        variable address : integer;
        variable instruction      : instruction_bit_type;
        variable dout_array       : BMEM; --just for testing
        variable dout             : DATA_TYPE;
        variable din              : DATA_TYPE;
    begin
        address := to_integer(unsigned(ADDRB));
        din     := DINB;
        if address < 10 then
            if ENB = '1' then
                case WEB is      --write into mem 
                    when "0001" =>     
                        dout_array(address) := DINB;
                    when "0011" =>
                        dout_array(address) := DINB;
                    when "1111" =>
                        dout_array(address) := DINB;
                    when "0000" =>     --read from mem
                        dout := dout_array(address);
                    when others =>  
                        dout := dout_cs;
                        report "ERROR with WEB" severity ERROR;            
                end case;
            else 
                dout := dout_cs;
            end if;
        else
            report "address to big for mem stub, try smaller then 10!!!" severity ERROR;
        end if;
        dout_cs <= dout;
        DOUTB <= dout_cs;
            
    end process test_portB;
    
    
end architecture dummy_bmem;