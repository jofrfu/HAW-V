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
            DEST_REG_EX :  in REGISTER_ADDRESS_TYPE;
            DEST_REG_MA :  in REGISTER_ADDRESS_TYPE;
            DEST_REG_WB :  in REGISTER_ADDRESS_TYPE;
            STORE       :  in std_logic;
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
    signal DEST_REG_EX_s : REGISTER_ADDRESS_TYPE := (others => '0');
    signal DEST_REG_MA_s : REGISTER_ADDRESS_TYPE := (others => '0');
    signal DEST_REG_WB_s : REGISTER_ADDRESS_TYPE := (others => '0');
    signal STORE_s       : std_logic := '0';
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
    impure function decode_response_check( 
        Imm_wanted      : in integer;
        opcode          : in OP_CODE_TYPE;
        rs2, rs1, rd    : in integer range 0 to REGISTER_COUNT-1;
        funct3_wanted   : in FUNCT3_TYPE;
        funct7_wanted   : in FUNCT7_TYPE
    ) 
    return boolean is
    begin
        --branch check -> check for nop when branch bit is set
        if branch_s = '1' then
            if IF_CNTRL_s /= "01" then
                report "decode_TB.vhdl - branch check: pc update should have been 01" severity error;
                return false;
            end if;
            if ID_CNTRL_s /= ID_CNTRL_NOP then
                report "decode_TB.vhdl - branch check: ID_CNTRL was not nop state" severity error;
                return false;
            end if;
            if EX_CNTRL_s /= EX_CNTRL_NOP then
                report "decode_TB.vhdl - branch check: EX_CNTRL was not nop state" severity error;
                return false;
            end if;
            if MA_CNTRL_s /= MA_CNTRL_NOP then 
                report "decode_TB.vhdl - branch check: MA_CNTRL was not nop state" severity error;
                return false;
            end if;
            if WB_CNTRL_s /= WB_CNTRL_NOP then
                report "decode_TB.vhdl - branch check: WB_CNTRL was not nop state" severity error;
                return false;
            end if;
            return true;
        end if;
             
        --pc_log check
        case opcode is  
            when luio | auipco | loado | storeo | opimmo | opo | brancho =>
                --pc must be pc+4
                if IF_CNTRL_s /= "00" then --pc+4
                    report "decode_TB.vhdl - pc_log check: pc update should have been 00 " severity error;
                    return false;
                end if;
            when jalo =>
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

    impure function bubble_check(
        shouldBubble    : in boolean;
        Imm_wanted      : in integer;
        opcode          : in OP_CODE_TYPE;
        rs2, rs1, rd    : in integer range 0 to REGISTER_COUNT-1;
        funct3_wanted   : in FUNCT3_TYPE;
        funct7_wanted   : in FUNCT7_TYPE    
    )
    return boolean is
    begin
        if shouldBubble then
            if IF_CNTRL_s /= IF_CNTRL_BUB then
                report "decode_TB.vhdl:bubble_check - IF_CNTRL check failed" severity error;
                return false;
            end if;
            if ID_CNTRL_s /= ID_CNTRL_BUB then
                report "decode_TB.vhdl:bubble_check - ID_CNTRL check failed" severity error;
                return false;
            end if;
            if EX_CNTRL_s /= EX_CNTRL_BUB then
                report "decode_TB.vhdl:bubble_check - EX_CNTRL check failed" severity error;
                return false;
            end if;
            if MA_CNTRL_s /= MA_CNTRL_BUB then
                report "decode_TB.vhdl:bubble_check - MA_CNTRL check failed" severity error;
                return false;
            end if;
            if WB_CNTRL_s /= WB_CNTRL_BUB then
                report "decode_TB.vhdl:bubble_check - WB_CNTRL check failed" severity error;
                return false;
            end if;
            if Imm_s /= std_logic_vector(to_signed(0, DATA_WIDTH)) then
                report "decode_TB.vhdl:bubble_check - immediate check failed" severity error;
                return false;
            end if;
            return true;
        else
            return decode_response_check(Imm_wanted, opcode, rs2, rs1, rd, funct3_wanted, funct7_wanted);
        end if;
    end function bubble_check;
    
    begin

    dut_i : dut
    port map(
        branch => branch_s,
        IFR => IFR_s,
        DEST_REG_EX => DEST_REG_EX_s,
        DEST_REG_MA => DEST_REG_MA_s,
        DEST_REG_WB => DEST_REG_WB_s,
        STORE => STORE_s,
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
        variable shouldBubble   : boolean;
    begin
        --first loop everything without branching, secound loop with branching
        for i in std_logic range '0' to '1' loop
        
            if i = '1' then
                report "branch activated here" severity note;
            end if;
            
            branch_s <= i;
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
           
            --add x2, x1, x3
            funct7  := ADD_FUNCT7;
            funct3  := ADD_FUNCT3;
            opcode  := opo;
            rs2     := 3;
            rs1     := 1;
            rd      := 2;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed add" severity error;
                wait;
            end if;
            
            --sub x2, x1, x3
            funct7  := SUB_FUNCT7;
            funct3  := SUB_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed sub" severity error;
                wait;
            end if;
            
            --sll x2, x1, x3
            funct7  := SLL_FUNCT7;
            funct3  := SLL_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed sll" severity error;
                wait;
            end if;
            
            --slt x2, x1, x3
            funct7  := SLT_FUNCT7;
            funct3  := SLT_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed slt" severity error;
                wait;
            end if;
            
            --sltu x2, x1, x3
            funct7  := SLTU_FUNCT7;
            funct3  := SLTU_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed sltu" severity error;
                wait;
            end if;
            
            --xor x2, x1, x3
            funct7  := XOR_FUNCT7;
            funct3  := XOR_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed xor" severity error;
                wait;
            end if;
            
            --srl x2, x1, x3
            funct7  := SRL_FUNCT7;
            funct3  := SRL_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed srl" severity error;
                wait;
            end if;
            
            --sra x2, x1, x3
            funct7  := SRA_FUNCT7;
            funct3  := SRA_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed sra" severity error;
                wait;
            end if;
            
            --or x2, x1, x3
            funct7  := OR_FUNCT7;
            funct3  := OR_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed or" severity error;
                wait;
            end if;
            
            --and x2, x1, x3
            funct7  := AND_FUNCT7;
            funct3  := AND_FUNCT3;

            IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, rd, funct3, funct7) then
                report "decode_reponse_check failed and" severity error;
                wait;
            end if;
            
            --jal x2, -4
            opcode      := jalo;
            immediate   := -4;      --only even numbers can be used with J-Type
            rd          := 2;
                    
            IFR_s <= IFR_J_TYPE(immediate, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, NO_REG, rd, NO_FUNCT3, NO_FUNCT7) then
                report "decode_reponse_check failed jal" severity error;
                wait;
            end if;      
            
            --jalr x2, x1, -1
            opcode      := jalro;
            immediate   := -1;
            rs1         := 1;
            funct3      := "000";
                    
            IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed jalr" severity error;
                wait;
            end if;      
            
            --beq x1, x3, -4
            opcode      := brancho;
            immediate    := -4;         --only even numbers can be used with B-Type
            rs1         := 1;
            rs2         := 3;
            funct3      := BEQ_FUNCT3;
                    
            IFR_s <= IFR_B_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed beq" severity error;
                wait;
            end if;   

            --bne x1, x3, -4
            funct3      := BNE_FUNCT3;
                    
            IFR_s <= IFR_B_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed bne" severity error;
                wait;
            end if;  
            
            --blt x1, x3, -4
            funct3      := BLT_FUNCT3;
                    
            IFR_s <= IFR_B_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed blt" severity error;
                wait;
            end if;  
            
            --bltu x1, x3, -4
            funct3      := BLTU_FUNCT3;
                    
            IFR_s <= IFR_B_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed bltu" severity error;
                wait;
            end if;  
            
            --bge x1, x3, -4
            funct3      := BGE_FUNCT3;
                    
            IFR_s <= IFR_B_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed bge" severity error;
                wait;
            end if;  
            
            --bgeu x1, x3, -4
            funct3      := BGEU_FUNCT3;
                    
            IFR_s <= IFR_B_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed bgeu" severity error;
                wait;
            end if;  
            
            --lb x2, x1, -4
            immediate    := -4;
            opcode       := loado;
            rs1          := 1;
            rd           := 2;
            funct3       := LB_FUNCT3;
            
            IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed lb" severity error;
                wait;
            end if;  
            
            --lh x2, x1, -4
            funct3       := LH_FUNCT3;
            
            IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed lh" severity error;
                wait;
            end if; 
            --lw x2, x1, -4
            funct3       := LW_FUNCT3;
            
            IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed lw" severity error;
                wait;
            end if; 
            
            --lbu x2, x1, -4
            funct3       := LBU_FUNCT3;
            
            IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed lbu" severity error;
                wait;
            end if; 
            
            --lhu x2, x1, -4
            funct3       := LHU_FUNCT3;
            
            IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed lhu" severity error;
                wait;
            end if; 
            
            --sb x1, x3, -4
            immediate   := -4;
            opcode      := storeo;
            rs2         := 3;
            rs1         := 1;
            funct3      := SB_FUNCT3;
            
            IFR_s <= IFR_S_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed sb" severity error;
                wait;
            end if; 
            
            --sh x1, x3, -4
            funct3      := SH_FUNCT3;
            
            IFR_s <= IFR_S_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed sh" severity error;
                wait;
            end if; 
            
            --sw x1, x3, -4
            funct3      := SW_FUNCT3;
            
            IFR_s <= IFR_S_TYPE(immediate, rs2, rs1, funct3, opcode);
            wait for WAIT_TIME;
            if not decode_response_check(immediate, opcode, rs2, rs1, NO_REG, funct3, NO_FUNCT7) then
                report "decode_reponse_check failed sw" severity error;
                wait;
            end if; 
            
        end loop;
        
        report "normal decode test successful" severity note;
        
        --bubble testing starts here
        --load stages with r1, r2 and r3
        DEST_REG_EX_s <= std_logic_vector(to_signed(1, REGISTER_ADDRESS_WIDTH));
        DEST_REG_MA_s <= std_logic_vector(to_signed(2, REGISTER_ADDRESS_WIDTH));
        DEST_REG_WB_s <= std_logic_vector(to_signed(3, REGISTER_ADDRESS_WIDTH));
        STORE_s       <= '0';
        branch_s      <= '0';
        
        -- addi x2, x1, -1              
        shouldBubble := true;
        immediate    := -1;
        opcode       := opimmo;
        rs1          := 1;
        rd           := 2;
        funct3       := ADDI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not bubble_check(shouldBubble, immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "bubble_check failed opimmo with rs1=1" severity error;
            wait;
        end if;
        
        shouldBubble := false;
        rs1          := 0;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not bubble_check(shouldBubble, immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "bubble_check failed opimmo with rs1=0" severity error;
            wait;
        end if;
        
        --jalr x2, x2, -1
        shouldBubble := true;
        opcode       := jalro;
        rs1          := 2;        
        funct3       := "000";
                
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not bubble_check(shouldBubble, immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "bubble_check failed jalro with rs1=2" severity error;
            wait;
        end if;  
        
        shouldBubble := false;
        rs1          := 0;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait for WAIT_TIME;
        if not bubble_check(shouldBubble, immediate, opcode, NO_REG, rs1, rd, funct3, NO_FUNCT7) then
            report "bubble_check failed jalro with rs1=0" severity error;
            wait;
        end if;    
        
        report "bubble decode test successful" severity note;
        wait;
        
        
        
    end process test;  
end architecture TB;