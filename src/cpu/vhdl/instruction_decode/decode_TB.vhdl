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
    
    constant WAIT_TIME   : time := 20 ns;
    constant NO_REG      : integer := 0;
    
    signal branch_s      : std_logic := '0';
    signal IFR_s	     : INSTRUCTION_BIT_TYPE := IFR_I_TYPE(0, 0, "000", 0, opimmo);
    ----------------------------------------
    signal IF_CNTRL_s    : IF_CNTRL_TYPE;
    signal ID_CNTRL_s    : ID_CNTRL_TYPE;
    signal WB_CNTRL_s    : WB_CNTRL_TYPE;
    signal MA_CNTRL_s    : MA_CNTRL_TYPE;
    signal EX_CNTRL_s    : EX_CNTRL_TYPE;
    signal Imm_s         : DATA_TYPE;
    
    --!@brief Check response of the decode stage
    --!@details If a register adress (rs1,rs2,rd) is unused in the instruction
    --!         the argument should be set to zero
    --!         Instructions that do not feature a funct7 are expected
    --!         to be handeled with an all Zero funct7
    impure function decode_response_check( --TODO 13.11.17 17:57 Sebastian Brueckner Unfinished, add other opcodes 
        Imm_wanted      : in integer;
        opcode          : in OP_CODE_TYPE;
        rs2, rs1, rd    : in integer range 0 to REGISTER_COUNT-1;
        funct3_wanted   : in FUNCT3_TYPE;
        funct7_wanted   : in FUNCT7_TYPE
    ) 
    return boolean is
    begin
            
        --pc_log check
        case opcode is  
            when luio | auipco | loado | storeo | opimmo | opo =>
                --pc must be pc+4
                if IF_CNTRL_s /= "00" then --pc+4
                    report "decode_TB.vhdl - pc_log check: pc update should have been 00 " severity error;
                    return false;
                end if;
            when jalo | brancho =>
                --pc must be pc+rel
                if IF_CNTRL_s /= "01" then --pc+4
                    report "decode_TB.vhdl - pc_log check: pc update should have been 01" severity error;
                    return false;
                end if;
            when jalro =>
                --pc must be abs+rel
                if IF_CNTRL_s /= "11" then --pc+4
                    report "decode_TB.vhdl - pc_log check: pc update should have been 11" severity error;
                    return false;
                end if;
            when others =>
                report "decode_TB.vhdl - pc_log check: opcode not supported" severity error;
                return false;
        end case;--] pc_log check
        
        --pc_en check
        case opcode is      
            when luio | jalo | jalro | brancho | loado | storeo | opimmo | opo =>
                if ID_CNTRL_s(11) /= '0' then
                    report "decode_TB.vhdl - pc_en check: pc_en was enabled" severity error;
                    return false;
                end if;
            when auipco =>
                if ID_CNTRL_s(11) /= '1' then
                    report "decode_TB.vhdl - pc_en check: pc_en was not enabled" severity error;
                    return false;
                end if;
            when others =>
                report "decode_TB.vhdl - pc_en check: opcode not supported" severity error;
                return false;
        end case; --]pc_en check
                
        --immediate_mux check
        case opcode is
            when opimmo | jalro | loado | luio | auipco | jalo | storeo =>
                if ID_CNTRL_s(10) /= '1' then
                    report "decode_TB.vhdl - immediate_mux check: Immediate was not enabled" severity error;
                    return false;
                end if;
            when opo | brancho =>
                if ID_CNTRL_s(10) /= '0' then
                    report "decode_TB.vhdl - immediate_mux check: Immediate was enabled" severity error;
                    return false;
                end if;
            when others =>
                report "decode_TB.vhdl - immediate_mux check: opcode not supported" severity error;
                return false;
        end case; --]immediate_mux check

        --rs2 check
        case opcode is
            when opo | brancho =>
                if ID_CNTRL_s(9 downto 5) /= std_logic_vector(to_unsigned(rs2, REGISTER_ADDRESS_WIDTH)) then
                    report "decode_TB.vhdl - rs2 check: wrong register select for rs2" severity error;
                    return false;
                end if;
            when opimmo | jalo | jalro | loado | luio | auipco | storeo =>
                null; --rs2 does not matter for the other opcodes
            when others =>
                report "decode_TB.vhdl - rs2 check: opcode not supported" severity error;
                return false;
        end case;--]rs2 check
        
        --rs1 check
        case opcode is
            when opimmo | jalro | loado | opo | brancho | storeo =>
                if ID_CNTRL_s(4 downto 0) /= std_logic_vector(to_unsigned(rs1, REGISTER_ADDRESS_WIDTH)) then
                    report "decode_TB.vhdl - rs1 check: wrong register select for rs1" severity error;
                    return false;
                end if;
            when luio | auipco | jalo =>
                null; --rs1 does not matter for the other opcodes
            when others =>
                report "decode_TB.vhdl - rs1 check: opcode not supported" severity error;
                return false;
        end case;--]rs1 check
               
        --funct3 check
        case opcode is
            when luio | auipco | jalo | jalro =>
                --no funct3 available
                null;
            when brancho | loado | storeo | opimmo | opo =>                
                if EX_CNTRL_s(9 downto 7) /= funct3_wanted then
                    report "decode_TB.vhdl - funct3 check: funct 3 mismatch" severity error;
                    return false;
                end if;
            when others =>
                report "decode_TB.vhdl - funct3 check: opcode not supported" severity error;
                return false;
        end case;
                
        --funct7 check
        case opcode is
            when opimmo =>
                case funct3_wanted is 
                    when SLLI_FUNCT3 | SRLI_SRAI_FUNCT3 =>
                        if EX_CNTRL_s(16 downto 10) /= funct7_wanted then
                            report "decode_TB.vhdl - funct7 check opimmo: SLLI/SRLI/SRAI funct7 mismatch" severity error;
                            return false;
                        end if;    
                    when others =>
                        null; --no funct7 for other funct3 in opimmo
                end case;
            when opo =>
                if EX_CNTRL_s(16 downto 10) /= funct7_wanted then
                    report "decode_TB.vhdl - funct7 check opo: funct7 mismatch" severity error;
                    return false;
                end if;  
            when luio | auipco | jalo | jalro | brancho | loado |  storeo =>
                null; --no funct7 supported
            when others =>
                report "decode_TB.vhdl - funct7 check: opcode not supported" severity error;
                return false;
        end case; --]funct7 check
                    
             
        --opcode should be passed directly to ex_cntrl
        if EX_CNTRL_s(6 downto 0) /=  OP_CODE_TYPE_TO_BITS(opcode) then
            report "decode_TB.vhdl - wrong opcode in EX_CNTRL" severity error;
            return false;
        end if;
           
        --store bit check
        if opcode = storeo then
            if MA_CNTRL_s(1) /= '1' then
                report "decode_TB.vhdl - store bit check: store bit was not set in MA_CNTRL(1)" severity error;
                return false;
            end if;
        else
            if MA_CNTRL_s(1) /= '0' then
                report "decode_TB.vhdl - store bit check: store bit was set in MA_CNTRL(1)" severity error;
                return false;
            end if;
        end if;
        
        --load bit check
        if opcode = loado then
            if MA_CNTRL_s(0) /= '1' then
                report "decode_TB.vhdl - load bit check: load bit was not set in MA_CNTRL(0)" severity error;
                return false;
            end if;
        else
            if MA_CNTRL_s(0) /= '0' then
                report "decode_TB.vhdl - load bit check: load bit was set in MA_CNTRL(0)" severity error;
                return false;
            end if;
        end if;
                
        --pc_mux check
        case opcode is
            when jalo | jalro =>
                if WB_CNTRL_s(5) /= '1' then
                    report "decode_TB.vhdl - pc_mux check: pc load in WB_CNTRL was not activated" severity error;
                    return false;
                end if;
            when luio | auipco | brancho | loado | storeo | opimmo | opo =>
                if WB_CNTRL_s(5) /= '0' then
                    report "decode_TB.vhdl - pc_mux check: pc load in WB_CNTRL was activated" severity error;
                    return false;
                end if;
            when others =>
                report "decode_TB.vhdl - pc_mux check: opcode not supported" severity error;
                return false;
        end case; --]pc_mux check
               
        --rd check
        case opcode is
            when opimmo | jalo | jalro | loado | luio | auipco | opo =>
                if WB_CNTRL_s(4 downto 0) /= std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) then
                    report "decode_TB.vhdl - opimmo: wrong target register address for writeback" severity error;
                    return false;
                end if;
            when brancho | storeo =>
                null; --no writeback, hence register does not matter
            when others => 
                report "decode_TB.vhdl - rd check: opcode not supported" severity error;
                return false;
        end case;--]rd check
      
        --immediate check
        case opcode is
            when jalo | jalro | loado | storeo | opimmo =>
                if Imm_s /= std_logic_vector(to_signed(Imm_wanted, DATA_WIDTH)) then
                    report "decode_TB.vhdl - Immediate mismatch" severity error;
                    return false;
                end if;
            when luio | auipco =>
                --immediate is shifted by 12 bits because the immediate will be loaded in the upper bits
                if Imm_s /= std_logic_vector(SHIFT_LEFT(to_signed(Imm_wanted, DATA_WIDTH), 12)) then
                    report "decode_TB.vhdl - Immediate mismatch" severity error;
                    return false;
                end if;
            when opo | brancho => 
                null; --no immediate needed, hence dont care
            when others =>
                report "decode_TB.vhdl - immediate check: opcode not supported" severity error;
                return false;
        end case;
        
        return true;
    end function decode_response_check;

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
        variable immediate      : integer;
        variable opcode         : OP_CODE_TYPE;
        variable rs2, rs1, rd   : integer range 0 to REGISTER_COUNT-1;
        variable funct3         : FUNCT3_TYPE;
        variable funct7         : FUNCT7_TYPE;
        variable shamt          : integer range 0 to REGISTER_COUNT-1;
    begin
        --everything without branching
        branch_s <= '0';
        wait for WAIT_TIME;
        
        -- addi x2, x1, -1              rs1, rd and immediate will stay the same, TODO: test all registers and immediates
        immediate    := -1;
        opcode       := opimmo;
        rs1          := 1;
        rd           := 2;
        funct3       := ADDI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "decode_reponse_check failed addi" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        --slti x2, x1, -1
        funct3       := SLTI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "decode_reponse_check failed slti" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        --sltiu x2, x1, -1
        funct3       := SLTIU_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "decode_reponse_check failed sltiu" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        --andi x2, x1, -1
        funct3       := ANDI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "decode_reponse_check failed andi" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        --ori x2, x1, -1
        funct3       := ORI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "decode_reponse_check failed ori" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        --xori x2, x1, -1
        funct3       := XORI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "decode_reponse_check failed xori" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        -- slli x2, x1, -1
        shamt        := 20;
        funct7       := SLLI_FUNCT7;
        immediate    := to_integer(unsigned(funct7) & to_unsigned(shamt, REGISTER_ADDRESS_WIDTH)); --this is the special immediate funct7 & shamt
        funct3       := SLLI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE_SHIFT(funct7, shamt, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;               
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, funct7) then
            report "decode_reponse_check failed slli" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        -- srli x2, x1, -1
        funct7       := SRLI_FUNCT7;
        immediate    := to_integer(unsigned(funct7) & to_unsigned(shamt, REGISTER_ADDRESS_WIDTH)); --this is the special immediate funct7 & shamt
        funct3       := SRLI_SRAI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE_SHIFT(funct7, shamt, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;               
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, funct7) then
            report "decode_reponse_check failed srli" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        -- srai x2, x1, -1
        funct7       := SRAI_FUNCT7;
        immediate    := to_integer(unsigned(funct7) & to_unsigned(shamt, REGISTER_ADDRESS_WIDTH)); --this is the special immediate funct7 & shamt
        funct3       := SRLI_SRAI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE_SHIFT(funct7, shamt, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;               
        if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, funct7) then
            report "decode_reponse_check failed srai" severity error;
            wait;
        end if;
        wait for WAIT_TIME;
        
        --lui x2, -1
        immediate   := -1;
        opcode      := luio;
        
        IFR_s <= IFR_U_TYPE(immediate, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, NO_REG, rd, NO_FUNCT3, NO_FUNCT7) then
            report "decode_reponse_check failed lui" severity error;
            wait;
        end if;
        
        --auipc x2, -1
        opcode      := auipco;
        
        IFR_s <= IFR_U_TYPE(immediate, rd, opcode);
        wait for WAIT_TIME;
        if not decode_response_check(immediate, opcode, NO_REG, NO_REG, rd, NO_FUNCT3, NO_FUNCT7) then
            report "decode_reponse_check failed auipc" severity error;
            wait;
        end if;
        
        report "decode test successful" severity note;
        wait;
        
    end process test;  
end architecture TB;