--!@file    execute_stage.vhdl
--!@brief   This file is part of the ach-ne projekt at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Jonas Fuhrmann
--!@atuhor  Matthis Keppner
--!@author  Sebastian Brückner
--!@date    2017 - 2018

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

--!@brief   This is the execute stage of the CPU
--!@details This Stage has two main Components:
--!         1. ALU - responsible for calculation
--!         2. Branch Checker - check if a branch needs to be taken
entity execute_stage is
    port(
        clk, reset : in std_logic;
        
        WB_CNTRL_IN   : in WB_CNTRL_TYPE;    --!Controlbits for WB-Stage 
        MA_CNTRL_IN   : in MA_CNTRL_TYPE;    --!Controlbits for MA-Stage 
        EX_CNTRL_IN   : in EX_CNTRL_TYPE;    --!Controlbits for EX-Stage will be used here    
        Imm           : in DATA_TYPE;        --!Immediate
        OPB           : in DATA_TYPE;        --!Operand B
        OPA           : in DATA_TYPE;        --!Operand A
        DO_IN         : in DATA_TYPE;        --!Data-output-register
        PC_IN         : in ADDRESS_TYPE;     --!PC Register
        
        WB_CNTRL_OUT          : out WB_CNTRL_TYPE;   --!Controlbits for WB-Stage 
        MA_CNTRL_OUT_SYNCH    : out MA_CNTRL_TYPE;   --!Controlbits for MA-Stage
        MA_CNTRL_OUT_ASYNCH   : out MA_CNTRL_TYPE;   --!Controlbits for MA-Stage
        WORD_CNTRL_OUT_SYNCH  : out WORD_CNTRL_TYPE; --!Controlbits for MA-Stage (word length)
        WORD_CNTRL_OUT_ASYNCH : out WORD_CNTRL_TYPE; --!Controlbits for MA-Stage (word length)
        SIGN_EN               : out std_logic;       --!Enables sign extension in memory access
        RESU_DAR_SYNCH        : out DATA_TYPE;       --!Result of calulation
        RESU_DAR_ASYNCH       : out DATA_TYPE;       --!Result of calulation
        Branch                : out std_logic;       --!For conditioned branching
        ABS_OUT               : out DATA_TYPE;       --!Absolute value for branch/jump (just loop through)
        REL_OUT               : out DATA_TYPE;       --!Relative value for branch/jump (just loop through)
        DO_OUT                : out DATA_TYPE;       --!Data-output-register is passed to next stage
        PC_OUT                : out ADDRESS_TYPE     --!PC Register
    );
end entity execute_stage;   


architecture beh of execute_stage is

    signal WB_CNTRL_cs   : WB_CNTRL_TYPE := WB_CNTRL_NOP;
    signal WB_CNTRL_ns   : WB_CNTRL_TYPE;
    signal MA_CNTRL_cs   : MA_CNTRL_TYPE := MA_CNTRL_NOP;
    signal MA_CNTRL_ns   : MA_CNTRL_TYPE;
    signal WORD_CNTRL_cs : WORD_CNTRL_TYPE := (others => '0');
    signal WORD_CNTRL_ns : WORD_CNTRL_TYPE;
    signal SIGN_EN_cs    : std_logic := '0';
    signal SIGN_EN_ns    : std_logic;
    
    signal RESU_DAR_cs   : DATA_TYPE := (others => '0');
    signal RESU_DAR_ns   : DATA_TYPE;
    
    signal DO_cs         : DATA_TYPE := (others => '0');
    signal DO_ns         : DATA_TYPE;
    
    signal PC_cs         : ADDRESS_TYPE := (others => '0');
    signal PC_ns         : ADDRESS_TYPE;

    signal flags_s       : FLAGS_TYPE;
    
    component branch_checker is
        port(
            FUNCT3    : in FUNCT3_TYPE;
            OP_CODE  : in OP_CODE_BIT_TYPE;
            FLAGS    : in FLAGS_TYPE;

            WORD_CNTRL  : out WORD_CNTRL_TYPE;
            SIGN_EN     : out std_logic;
            
            BRANCH      : out std_logic
        );
    end component branch_checker;
    for all : branch_checker use entity work.branch_checker(beh);
    
    component ALU is 
        port(
            OPB         : in DATA_TYPE;
            OPA         : in DATA_TYPE;
            EX_CNTRL_IN : in EX_CNTRL_TYPE;
            
            Flags       : out FLAGS_TYPE;
            Resu        : out DATA_TYPE
        );
    end component ALU;
    for all : ALU use entity work.ALU(beh);
    
begin

    ABS_OUT <= OPA;
    REL_OUT <= Imm;
    
    branch_i : branch_checker
    port map(
        EX_CNTRL_IN((OP_CODE_WIDTH + FUNCT3_WIDTH - 1) downto OP_CODE_WIDTH),
        EX_CNTRL_IN(OP_CODE_WIDTH-1 downto 0),
        flags_s,
        WORD_CNTRL_ns,
        SIGN_EN_ns,
        Branch
    );

    alu_i : ALU
    port map(
        OPB,
        OPA,
        EX_CNTRL_IN,
        flags_s,
        RESU_DAR_ns
    );
    
    seq_log:
    process(clk) is
    
    begin
    
        if clk'event and clk = '1' then
            if reset = '1' then
                WB_CNTRL_cs <= WB_CNTRL_NOP;
                MA_CNTRL_cs <= MA_CNTRL_NOP;
                WORD_CNTRL_cs <= (others => '0');
                SIGN_EN_cs <= '0';
                RESU_DAR_cs <= (others => '0');
                DO_cs <= (others => '0');
                PC_cs <= (others => '0');
            else
                WB_CNTRL_cs <= WB_CNTRL_ns;
                MA_CNTRL_cs <= MA_CNTRL_ns;
                WORD_CNTRL_cs <= WORD_CNTRL_ns;
                SIGN_EN_cs <= SIGN_EN_ns;
                RESU_DAR_cs <= RESU_DAR_ns;
                DO_cs <= DO_ns;
                PC_cs <= PC_ns;
            end if;
        end if;
    
    end process seq_log;
    
    WB_CNTRL_ns <= WB_CNTRL_IN;
    MA_CNTRL_ns <= MA_CNTRL_IN;
    DO_ns <= DO_IN;
    PC_ns <= std_logic_vector(unsigned(PC_IN) + to_unsigned(4, DATA_WIDTH)); --TODO Explain this
    
    -- synchronous outputs
    WB_CNTRL_OUT <= WB_CNTRL_cs;
    MA_CNTRL_OUT_SYNCH <= MA_CNTRL_cs;
    WORD_CNTRL_OUT_SYNCH <= WORD_CNTRL_cs;
    SIGN_EN <= SIGN_EN_cs;
    RESU_DAR_SYNCH <= RESU_DAR_cs;
    DO_OUT <= DO_cs;
    PC_OUT <= PC_cs;
    
    -- asynchronous outputs
    MA_CNTRL_OUT_ASYNCH <= MA_CNTRL_ns;
    WORD_CNTRL_OUT_ASYNCH <= WORD_CNTRL_ns;
    RESU_DAR_ASYNCH <= RESU_DAR_ns;

end architecture beh;  