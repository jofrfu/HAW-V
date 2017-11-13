--!@file 	ALU.vhdl
--!@brief 	This file contains the ALU of the CPU
--!@author 	Matthis Keppner, Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity ALU is 
    port(
        clk, reset : in std_logic;
        
        OPB         : in DATA_TYPE;
        OPA         : in DATA_TYPE;
        EX_CNTRL_IN : in EX_CNTRL_TYPE;
        
        Flags       : out FLAGS_TYPE;
        Resu        : out DATA_TYPE
    );
end entity ALU;

architecture beh of ALU is

    signal alu_OPA      : std_logic_vector(DATA_WIDTH downto 0)  := (others => '0');
    signal alu_OPB      : std_logic_vector(DATA_WIDTH downto 0)  := (others => '0');
    signal alu_resu     : DATA_TYPE;

    signal add_resu     : DATA_TYPE  := (others => '0');
    signal sub_resu     : DATA_TYPE  := (others => '0');
    signal and_resu     : DATA_TYPE  := (others => '0');   
    signal or_resu      : DATA_TYPE  := (others => '0'); 
    signal xor_resu     : DATA_TYPE  := (others => '0');   
    signal sll_resu     : DATA_TYPE  := (others => '0');   
    signal srl_resu     : DATA_TYPE  := (others => '0');    
    signal sra_resu     : DATA_TYPE  := (others => '0');   
    signal slt_resu     : DATA_TYPE  := (others => '0');
    signal sltu_resu    : DATA_TYPE  := (others => '0');
    
    signal flags_signed_s     : FLAGS_TYPE;
    signal flags_unsigned_s   : FLAGS_TYPE;

begin
    alu_proc:
    process (sub_OPA, sub_OPB) is
    
    variable OPA_v    : std_logic_vector(DATA_WIDTH downto 0); --extend to 33 for carry/borrow bit
    variable OPB_v    : std_logic_vector(DATA_WIDTH downto 0);
    
    variable resu_v   : std_logic_vector(DATA_WIDTH downto 0);
    variable flags_v  : FLAGS_TYPE;
    
    begin
    
        OPA_v := sub_OPA;
        OPB_v := sub_OPB;
        
        resu_v := std_logic_vector(to_signed(OPA_v) + to_signed(OPB_v), DATA_WIDTH);
        flags_v(0) := resu_v(resu_v'left);
        flags_v(1) := resu_v(resu_v'left - 1);
        if resu_v = std_logic_vector(to_unsigned(0), DATA_WIDTH+1) then
            flags_v(2) := '1';
        else
            flags_v(2) := '0';
        end if;
        flags_v(3) := 
        
            
        
        
        sub_resu <= resu_v;
    end process alu_proc;

    and_proc:
    process (OPA, OPB) is

    variable OPA_v    : DATA_TYPE;
    variable OPB_v    : DATA_TYPE;
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := OPA;
        OPB_v := OPB;
        
        resu_v := OPA_v and OPB_v;
    
        and_resu <= resu_v;
    end process and_proc;
    
    or_proc:
    process (OPA, OPB) is

    variable OPA_v    : DATA_TYPE;
    variable OPB_v    : DATA_TYPE;
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := OPA;
        OPB_v := OPB;
        
        resu_v := OPA_v or OPB_v;
    
        or_resu <= resu_v;
    end process or_proc;
    
    xor_proc:
    process (OPA, OPB) is

    variable OPA_v    : DATA_TYPE;
    variable OPB_v    : DATA_TYPE;
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := OPA;
        OPB_v := OPB;
        
        resu_v := OPA_v xor OPB_v;
    
        xor_resu <= resu_v;
    end process xor_proc;
    
    sll_proc:
    process (OPA, OPB) is

    variable OPA_v    : DATA_TYPE;
    variable OPB_v    : DATA_TYPE;
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := OPA;
        OPB_v := OPB;
        
        resu_v := std_logic_vector(shift_left(unsigned(OPA_v), OPB_v(4 downto 0)), DATA_WIDTH);
    
        sll_resu <= resu_v;
    end process sll_proc;
    
    srl_proc:
    process (OPA, OPB) is

    variable OPA_v    : DATA_TYPE;
    variable OPB_v    : DATA_TYPE;
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := OPA;
        OPB_v := OPB;
        
        resu_v := std_logic_vector(shift_right(unsigned(OPA_v), OPB_v(4 downto 0)), DATA_WIDTH);
    
        srl_resu <= resu_v;
    end process srl_proc;
    
    sra_proc:
    process (OPA, OPB) is

    variable OPA_v    : DATA_TYPE;
    variable OPB_v    : DATA_TYPE;
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := OPA;
        OPB_v := OPB;
        
        resu_v := std_logic_vector(shift_right(signed(OPA_v), OPB_v(4 downto 0)), DATA_WIDTH);
    
        sra_resu <= resu_v;
    end process sra_proc;
    
    slt_proc:
    process (OPA, OPB) is

    variable OPA_v    : signed(DATA_WIDTH-1 downto 0);
    variable OPB_v    : signed(DATA_WIDTH-1 downto 0);
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := to_signed(OPA);
        OPB_v := to_signed(OPB);
        
        if OPA_v < OPB_v then
            resu_v := std_logic_vector(to_signed(1), DATA_WIDTH);
        else
            resu_v := (others => '0');
        end if;
    
        slt_resu <= resu_v;
    end process slt_proc;
    
    sltu_proc:
    process (OPA, OPB) is

    variable OPA_v    : unsigned(DATA_WIDTH-1 downto 0);
    variable OPB_v    : unsigned(DATA_WIDTH-1 downto 0);
    variable resu_v   : DATA_TYPE;

    begin
        OPA_v := to_unsigned(OPA);
        OPB_v := to_unsigned(OPB);
        
        if OPA_v < OPB_v then
            resu_v := std_logic_vector(to_unsigned(1), DATA_WIDTH);
        else
            resu_v := (others => '0');
        end if;
    
        sltu_resu <= resu_v;
    end process sltu_proc;
    
    --!@brief ALU of the execute stage
    --! @detail calculates OPA (+) OPB;
    calc:
    process (EX_CNTRL_IN) is
    
        variable OPA_v    : DATA_TYPE     := (others => '0');
        variable OPB_v    : DATA_TYPE     := (others => '0');
        variable func7_v  : FUNC7_TYPE    := (others => '0');
        variable func3_v  : FUNC3_TYPE    := (others => '0');
        variable op_bits_v: OP_CODE_TYPE  := (others => '0');
        variable op_code_v: OP_CODE_TYPE  := (others => '0');
        variable Flags_v  : FLAGS_TYPE;
        variable Resu_v   : DATA_TYPE;    
    begin
        OPA_v               := OPA;
        OPB_v               := OPB;
        op_bits_v           := EX_CNTRL_IN(OP_CODE_WIDTH-1 downto 0);
        op_code_v           := BITS_TO_OP_CODE_TYPE(op_bits_v);
        funct3_v            := EX_CNTRL_IN(9 downto 7);
        funct7_v            := EX_CNTRL_IN(16 downto 10);
        
        case op_code_v is
            when  opo =>
                case func3_v is
                    when "000" => -- standard arithmetic
                        case func7_v is
                            when "0000000" =>
                                
             
       
       end case;
    end process calc;
    
    
end architecture beh;