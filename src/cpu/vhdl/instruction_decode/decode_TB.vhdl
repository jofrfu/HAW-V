use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity decode_TB is
end entity decode_TB;

architecture TB of decode_TB is
    component dut is
        port(   
            branch      :  in std_logic;
            IFR	        :  in INSTRUCTION_BIT_TYPE;
            ----------------------------------------
            IF_CNTRL    : out IF_CNTRL_TYPE;
            ID_CNTRL    : out ID_CNTRL_TYPE;
            WB_CNTRL    : out WB_CNTRL_TYPE;
            MA_CNTRL    : out MA_CNTRL_TYPE;
            EX_CNTRL    : out EX_CNTRL_TYPE;
            Imm         : out DATA_TYPE
        );--]port
    end component dut;
    for all : dut use entity work.decode(beh);
    
    --!@brief Check response of the decode stage
    --!@details If a register adress (rs1,rs2,rd) is unused in the instruction
    --!         the argument should be set to zero
    --!         Instructions that do not feature a funct7 are expected
    --!         to be handeled with an all Zero funct7
    function decode_response_check( --TODO 13.11.17 17:57 Sebastian Brueckner Unfinished, add immediate check, add other opcodes 
        Imm_wanted      : in integer;
        opcode          : in OP_CODE_TYPE;
        rs1, rs2, rd    : in natural; --TODO 13.11.17 17:34 Sebastian Brueckner: There should be an integer subtype with rang 0 to 31
        funct3_wanted   : in FUNCT3_TYPE;
        ---
        IF_CNTRL    : in IF_CNTRL_TYPE;
        ID_CNTRL    : in ID_CNTRL_TYPE;
        WB_CNTRL    : in WB_CNTRL_TYPE;
        MA_CNTRL    : in MA_CNTRL_TYPE;
        EX_CNTRL    : in EX_CNTRL_TYPE;
        Imm         : in DATA_TYPE
    ) 
    return boolean is
    begin
    
    
        if (rs1 /= to_integer(unsigned(ID_CNTRL(4 downto 0)))) then
            report "decode_TB.vhdl - ID_CNTRL: register select: mismatch rs1 OP_A" severity error;
            return false;
        end if;
        
        if rs2 /= to_integer(unsigned(ID_CNTRL(9 downto 5))) then
            report "decode_TB.vhdl - ID_CNTRL: register select: mismatch rs2 OP_B" severity error;
            return false;
        end if;
        
        if rd /= to_integer(unsigned(WB_CNTRL(4 downto 0))) then
            report "decode_TB.vhdl - register select: mismatch rd WB" severity error;
            return false;
        end if;
        
        if EX_CNTRL(9 downto 7) /= funct3_wanted then
            report "decode_TB.vhdl - EX_CNTRL: funct  3 mismatch" severity error;
            return false;
        end if;
        
        case opcode is
            when opimmo =>
                if Imm /= std_logic_vector(to_signed(Imm_wanted, DATA_WIDTH)) then --check if imm contruction worked
                    report "decode_TB.vhdl - opimmo: Immediate mismatch" severity error;
                    return false;
                end if;
                
                if IF_CNTRL /= "00" then --pc+4
                    report "decode_TB.vhdl - opimmo: wrong PC update" severity error;
                    return false;
                end if;
                
                if ID_CNTRL(11) /= '0' then
                    report "decode_TB.vhdl - opimmo: pc_en was enabled" severity error;
                    return false;
                end if;
                
                if ID_CNTRL(10) /= '1' then
                    report "decode_TB.vhdl - opimmo: Immediate was disabled" severity error;
                    return false;
                end if;

                case EX_CNTRL(9 downto 7) is
                    when SLLI_FUNCT3 =>
                        if EX_CNTRL(16 downto 10) /= SLLI_FUNCT7 then
                            report "decode_TB.vhdl - opimmo: SLLI funct7 mismatch" severity error;
                            return false;
                        end if;
                    when SRLI_FUNCT3 => --TODO cant distinguish SRAI and SRLI
                        if  EX_CNTRL(16 downto 10) /= SRLI_FUNCT7 or
                            EX_CNTRL(16 downto 10) /= SRLI_FUNCT7 then
                                report "decode_TB.vhdl - opimmo: SLLI funct7 mismatch" severity error;
                                return false;
                        end if;
                    when others => 
                        null;
                end case;
                
            when others => 
                report "decode_TB.vhdl - unknown opcode" severity error;
                return false;
        end case;
        
        return true;
    end function decode_response_check;

    constant WAIT_TIME   : time := 20 ns;
    
    signal branch_s      : std_logic := '0';
    signal IFR_s	     : INSTRUCTION_BIT_TYPE := IFR_I_TYPE(0, 0, "000", 0, opimmo);
    ----------------------------------------
    signal IF_CNTRL_s    : IF_CNTRL_TYPE;
    signal ID_CNTRL_s    : ID_CNTRL_TYPE;
    signal WB_CNTRL_s    : WB_CNTRL_TYPE;
    signal MA_CNTRL_s    : MA_CNTRL_TYPE;
    signal EX_CNTRL_s    : EX_CNTRL_TYPE;
    signal Imm_s         : DATA_TYPE;
    
    begin

    dut_i : dut
    port map(
        branch => branch_s,
        IFR => IFR_s,
        IF_CNTRL => IF_CNTRL_s,
        ID_CNTRL => ID_CNTRL_s,
        EX_CNTRL => EX_CNTRL_s,        
        MA_CNTRL => MA_CNTRL_s,
        WB_CNTRL => WB_CNTRL_s,        
        Imm => Imm_s
    );

    
    test:
    process is
    begin
        --everything without branching
        branch_s <= '0';
        wait for WAIT_TIME;
        
        ---------------------------------------------------
        --  TEST Integer Register Immediate Instructions -- 
        ---------------------------------------------------
        
        --addi
        -- addi x2, x1, -1
        IFR_s <= IFR_I_TYPE(-1, 2, "000", 1, opimmo);
        wait for WAIT_TIME;
        if not decode_response_check(-1, opimmo, 2, 0, 1, "000", IF_CNTRL_s, ID_CNTRL_s, WB_CNTRL_s, MA_CNTRL_s, EX_CNTRL_s, Imm_s) then
            report "decode_reponse_check failed addi" severity error;
            wait;
        end if;
        
        --slti x3, x4, 5
        IFR_s <= IFR_I_TYPE(5, 3, "010", 4, opimmo);
        wait for WAIT_TIME;
        
        -- slli x4, x3, 20
        IFR_s <= IFR_I_TYPE_SHIFT("0000000", 20, 3, "001", 4, opimmo );
        wait for WAIT_TIME;
        
        wait;
        
    end process test;  
end architecture TB;