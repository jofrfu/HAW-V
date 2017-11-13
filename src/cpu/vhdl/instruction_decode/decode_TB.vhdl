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
    
    function CHECK_OPCODE( --TODO 13.11.17 17:57 Sebastian Brueckner Unfinished
        Imm_wanted      : in DATA_TYPE;
        opcode          : in OP_CODE_TYPE;
        rs1, rs2, rd    : in natural; --TODO 13.11.17 17:34 Sebastian Brueckner: There should be an integer subtype with rang 0 to 31
         
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
            report "decode_TB.vhdl - register select: mismatch rs1 OP_A" severity error;
            return false;
        end if;
        
        if rs2 /= to_integer(unsigned(ID_CNTRL(9 downto 5))) then
            report "decode_TB.vhdl - register select: mismatch rs2 OP_B" severity error;
            return false;
        end if;
        
        if rd /= to_integer(unsigned(WB_CNTRL(4 downto 0))) then
            report "decode_TB.vhdl - register select: mismatch rd WB" severity error;
            return false;
        end if;
        
        case opcode is
            when opimmo =>
                if Imm /= Imm_wanted then --check if imm contruction worked
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
            when others => 
                report "decode_TB.vhdl - opimmo: Immediate was disabled" severity error;
                return false;
        end case;
        
    end function CHECK_OPCODE;

    constant WAIT_TIME   : time := 1 ns;
    
    signal branch_s      : std_logic := '0';
    signal IFR_s	     : INSTRUCTION_BIT_TYPE := (others => '0');
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
        
        ---------------------------------------------------
        --  TEST Integer Register Immediate Instructions -- 
        ---------------------------------------------------
        
        --addi
        -- addi x2, x1, -1
        IFR_s <= IFR_I_TYPE(-1, 2, "000", 1, opimmo);
        wait for WAIT_TIME;
        
        --slti x3, x4, 5
        IFR_s <= IFR_I_TYPE(5, 3, "010", 4, opimmo);

        
        -- slli x4, x3, 20
        IFR_s <= IFR_I_TYPE_SHIFT("0000000", 20, 3, "001", 4, opimmo );
        wait for WAIT_TIME;
        
        wait;
        
    end process test;  
end architecture TB;