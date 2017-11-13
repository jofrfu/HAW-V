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
        
        --test1
        -- addi x2, x1, -1
        IFR_s <= IFR_I_TYPE(-1, 1, "000", 2, opimmo);
        wait for WAIT_TIME;
        
        --test2
        -- slli x4, x3, 20
        IFR_s <= IFR_I_TYPE_SHIFT("0000000", 20, 3, "001", 4, opimmo );
        wait for WAIT_TIME;
        
        wait;
        
    end process test;  
end architecture TB;