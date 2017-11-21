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
        OPB         : in DATA_TYPE;
        OPA         : in DATA_TYPE;
        EX_CNTRL_IN : in EX_CNTRL_TYPE;
        
        Flags       : out FLAGS_TYPE;
        Resu        : out DATA_TYPE
    );
end entity ALU;

architecture beh of ALU is

    component adder is
        port(
            OPA         : in  DATA_TYPE;
            OPB         : in  DATA_TYPE;
            nadd_sub    : in  std_logic;
            
            RESULT      : out DATA_TYPE;
            CARRY       : out std_logic;
            OVERFLOW    : out std_logic
        );
    end component adder;
    for all : adder use entity work.adder(carry_ripple);
    
    signal nadd_sub     : std_logic;

    signal and_resu     : DATA_TYPE;   
    signal or_resu      : DATA_TYPE; 
    signal xor_resu     : DATA_TYPE;   
    signal sll_resu     : DATA_TYPE;   
    signal srl_resu     : DATA_TYPE;    
    signal sra_resu     : DATA_TYPE;   
    signal slt_resu     : DATA_TYPE;
    signal sltu_resu    : DATA_TYPE;
    
    signal flags_s      : FLAGS_TYPE;
    
    -- adder signals
    signal add_result   : DATA_TYPE;
    signal add_carry    : std_logic;
    signal add_overflow : std_logic;

begin

    adder_i : adder
    port map(
        OPA,
        OPB,
        nadd_sub,
        
        add_result,
        add_carry,
        add_overflow
    );
    
    Flags <= flags_s;

    flag_proc:
    process (add_result, add_carry, add_overflow) is
    
        variable add_result_v   : DATA_TYPE := (others => '0');
        variable add_carry_v    : std_logic := '0';
        variable add_overflow_v : std_logic := '0';
        variable flags_v        : FLAGS_TYPE;
            
    begin
        add_result_v   := add_result;
        add_carry_v    := add_carry;
        add_overflow_v := add_overflow;
    
        -- carry flag
        flags_v(0) := add_carry_v;
        
        -- negative flag
        flags_v(1) := add_result_v(add_result_v'left);
        
        -- zero flag
        if add_result_v = std_logic_vector(to_unsigned(0, DATA_WIDTH)) then
            flags_v(2) := '1';
        else
            flags_v(2) := '0';
        end if;
        
        -- overflow flag
        flags_v(3) := add_overflow_v;
        
        flags_s <= flags_v;
    end process flag_proc;
    
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
        
        resu_v := std_logic_vector( shift_left(unsigned(OPA_v), to_integer(unsigned(OPB_v(4 downto 0)))));
    
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
        
        resu_v := std_logic_vector(shift_right(unsigned(OPA_v), to_integer(unsigned(OPB_v(4 downto 0)))));
    
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
        
        resu_v := std_logic_vector(shift_right(signed(OPA_v), to_integer(unsigned(OPB_v(4 downto 0)))));
    
        sra_resu <= resu_v;
    end process sra_proc;
    
    slt_proc:
    process(flags_s) is
        variable flags_v : FLAGS_TYPE;
        variable resu_v  : DATA_TYPE; 
    begin
        flags_v := flags_s;
        if flags_v(3) /= flags_v(1) then
            resu_v := std_logic_vector(to_unsigned(1, DATA_WIDTH));
        else
            resu_v := std_logic_vector(to_unsigned(0, DATA_WIDTH));
        end if;
        
        slt_resu <= resu_v;
    end process slt_proc;
    
    sltu_proc:
    process(flags_s) is
        variable flags_v : FLAGS_TYPE;
        variable resu_v  : DATA_TYPE; 
    begin
        flags_v := flags_s;
        if flags_v(0) = '0' then
            resu_v := std_logic_vector(to_unsigned(1, DATA_WIDTH));
        else
            resu_v := std_logic_vector(to_unsigned(0, DATA_WIDTH));
        end if;
        
        sltu_resu <= resu_v;
    end process sltu_proc;
    
    --! @brief ALU of the execute stage
    --! @detail calculates OPA (+) OPB;
    choose:
    process (EX_CNTRL_IN) is
        variable funct7_v  : FUNCT7_TYPE;
        variable funct3_v  : FUNCT3_TYPE;
        variable op_bits_v: OP_CODE_BIT_TYPE;
        variable op_code_v: OP_CODE_TYPE;
        variable resu_v   : DATA_TYPE;
        variable nadd_sub_v : std_logic;        
    begin

        op_bits_v           := EX_CNTRL_IN(OP_CODE_WIDTH-1 downto 0);
        op_code_v           := BITS_TO_OP_CODE_TYPE(op_bits_v);
        funct3_v            := EX_CNTRL_IN(9 downto 7);
        funct7_v            := EX_CNTRL_IN(16 downto 10);
        nadd_sub_v          := '0';
        resu_v              := (others => '0');
        
        case op_code_v is
            when opo =>
                case funct3_v is
                    when "000" => -- standard arithmetic
                        case funct7_v is
                            when "0000000" => -- add
                                nadd_sub_v := '0';
                                resu_v := add_result;
                            when "0100000" => -- sub
                                nadd_sub_v := '1';
                                resu_v := add_result;
                            when others =>
                                report "Unknown alu command!" severity warning;
                        end case;
                     
                    when "001" =>
                        case funct7_v is
                            when "0000000" => -- SLL
                                resu_v := sll_resu;
                            when others =>
                                report "Unknown left shift command!" severity warning;
                        end case;
                    
                    when "010" =>
                        case funct7_v is
                            when "0000000" => -- SLT
                                nadd_sub_v := '1';
                                resu_v := slt_resu;
                            when others =>
                                report "Unknown signed compare command!" severity warning;
                        end case;
                    
                    when "011" =>
                        case funct7_v is
                            when "0000000" => -- SLTU
                                nadd_sub_v := '1';
                                resu_v := sltu_resu;
                            when others =>
                                report "Unknown unsigned compare command!" severity warning;
                        end case;
                    
                    when "100" =>
                        case funct7_v is
                            when "0000000" => -- XOR
                                resu_v := xor_resu;
                            when others =>
                                report "Unknown xor command!" severity warning;
                        end case;
                    
                    when "101" =>
                        case funct7_v is
                            when "0000000" => -- SRL
                                resu_v := srl_resu;
                            when "0100000" => -- SRA
                                resu_v := sra_resu;
                            when others =>
                                report "Unknown right shift command!" severity warning;
                        end case;
                    
                    when "110" =>
                        case funct7_v is
                            when "0000000" => -- OR
                                resu_v := or_resu;
                            when others =>
                                report "Unknown or command!" severity warning;
                        end case;
                    
                    when "111" =>
                        case funct7_v is
                            when "0000000" => -- AND
                                resu_v := and_resu;
                            when others =>
                                report "Unknown and command!" severity warning;
                        end case;
                
                    when others =>
                        report "Unknown funct3!" severity warning;
                    
                    end case;
            
            when opimmo =>
                case funct3_v is
                    when "000" => -- imm arithmetic
                        case funct7_v is
                            when others => -- addi
                                nadd_sub_v := '0';
                                resu_v := add_result;
                        end case;
                    
                    when "010" =>
                        case funct7_v is
                            when others => -- SLTI
                                nadd_sub_v := '1';
                                resu_v := slt_resu;
                        end case;
                    
                    when "011" =>
                        case funct7_v is
                            when others => -- SLTIU
                                nadd_sub_v := '1';
                                resu_v := sltu_resu;
                        end case;
                    
                    when "100" =>
                        case funct7_v is
                            when others => -- XORI
                                resu_v := xor_resu;
                        end case;
                    
                    when "110" =>
                        case funct7_v is
                            when others => -- ORI
                                resu_v := or_resu;
                        end case;
                    
                    when "111" =>
                        case funct7_v is
                            when others => -- ANDI
                                resu_v := and_resu;
                        end case;
                    
                    when "001" =>
                        case funct7_v is
                            when "0000000" => -- SLLI
                                resu_v := sll_resu;
                            when others =>
                                report "Unknown left shift command!" severity warning;
                        end case;
                    
                    when "101" =>
                        case funct7_v is
                            when "0000000" => -- SRLI
                                resu_v := srl_resu;
                            when "0100000" => -- SRAI
                                resu_v := sra_resu;
                            when others =>
                                report "Unknown right shift command!" severity warning;
                        end case;
                
                    when others =>
                        report "Unknown funct3!" severity warning;
                end case;
                
            when brancho => -- flags
                nadd_sub_v := '1';
                resu_v := add_result;
            
            when others =>
                report "Maybe unknown opcode!" severity note;
                nadd_sub_v := '0';
                resu_v := add_result;
        end case;
       
       nadd_sub <= nadd_sub_v;
       Resu <= resu_v;
    end process choose;
    
    
end architecture beh;