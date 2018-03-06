--!@file    risc_v_core.vhdl
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Jonas Fuhrmann
--!@date    2017 - 2018

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

--!@brief This device contains the core of the processor.
--!@details This includes all pipeline stages:
--!     1. Instruction Fetch
--!     2. Instruction Decode
--!     3. Execute
--!     4. Memory Access
--!     5. Write Back

entity risc_v_core is
    port(
        clk, reset    : in std_logic;
        
        -- memory
        pc_asynch     : out ADDRESS_TYPE;
        instruction   : in  INSTRUCTION_BIT_TYPE;
        
        EN            : out std_logic;
        WEN           : out std_logic;
        WORD_LENGTH   : out WORD_CNTRL_TYPE;
        ADDR          : out ADDRESS_TYPE;
        D_CORE_to_MEM : out DATA_TYPE;
        D_MEM_to_CORE : in  DATA_TYPE
    );
end entity risc_v_core;

architecture beh of risc_v_core is
    component instruction_fetch is
        port(
             clk, reset : in std_logic;
		 
             branch    : in std_logic;
             cntrl     : in IF_CNTRL_TYPE;  --! Control the operation mode of the PC logic
             rel	   : in DATA_TYPE;		--! relative branch address
             abso	   : in DATA_TYPE;		--! absolute branch address, or base for relative jump
             ins 	   : in DATA_TYPE;		--! the new instruction is loaded from here
             
             IFR	   : out DATA_TYPE;	    --! Instruction fetch register contents
             pc_asynch : out ADDRESS_TYPE;  --! clocked pc register for ID stage
             pc_synch  : out ADDRESS_TYPE   --! asynchronous PC for instruction memory
        );
    end component instruction_fetch;
    for all : instruction_fetch use entity work.instruction_fetch(std_impl);
    
    signal IFR_s : DATA_TYPE;
    signal pc_synch_s  : ADDRESS_TYPE;
    
    component instruction_decode is
        port(
            clk, reset   :  in std_logic;
            branch		 :  in std_logic;
            IFR			 :  in INSTRUCTION_BIT_TYPE;
            PC           :  in DATA_TYPE;
            DI	  		 :  in DATA_TYPE;
            rd			 :  in REGISTER_ADDRESS_TYPE;
            
            DEST_REG_EX  :  in REGISTER_ADDRESS_TYPE;
            DEST_REG_MA  :  in REGISTER_ADDRESS_TYPE;
            DEST_REG_WB  :  in REGISTER_ADDRESS_TYPE;
            STORE        :  in std_logic;
            
            IF_CNTRL	 : out IF_CNTRL_TYPE;
            WB_CNTRL	 : out WB_CNTRL_TYPE;
            MA_CNTRL	 : out MA_CNTRL_TYPE;
            EX_CNTRL	 : out EX_CNTRL_TYPE;
            Imm			 : out DATA_TYPE;
            OPB			 : out DATA_TYPE;
            OPA			 : out DATA_TYPE;
            DO			 : out DATA_TYPE;
            PC_o         : out ADDRESS_TYPE
        );
    end component instruction_decode;
    for all : instruction_decode use entity work.instruction_decode(beh);

    signal IF_CNTRL_s           : IF_CNTRL_TYPE;
    signal WB_CNTRL_ID_to_EX    : WB_CNTRL_TYPE;
    signal MA_CNTRL_ID_to_EX    : MA_CNTRL_TYPE;
    signal EX_CNTRL_ID_to_EX    : EX_CNTRL_TYPE;
    signal IMM_s                : DATA_TYPE;
    signal OPB_s                : DATA_TYPE;
    signal OPA_s                : DATA_TYPE;
    signal DO_ID_to_EX          : DATA_TYPE;
    signal PC_ID_to_EX          : DATA_TYPE;
    
    component execute_stage is
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
            ABS_OUT               : out DATA_TYPE;
            REL_OUT               : out DATA_TYPE;
            DO_OUT                : out DATA_TYPE;       --!Data-output-register is passed to next stage
            PC_OUT                : out ADDRESS_TYPE     --!PC Register
        );
    end component execute_stage;
    for all : execute_stage use entity work.execute_stage(beh);
    
    signal WB_CNTRL_EX_to_MA        : WB_CNTRL_TYPE;
    signal MA_CNTRL_SYNCH_EX_to_MA  : MA_CNTRL_TYPE;
    signal MA_CNTRL_ASYNCH_EX_to_MA : MA_CNTRL_TYPE;
    signal WORD_CNTRL_SYNCH_s       : WORD_CNTRL_TYPE;
    signal WORD_CNTRL_ASYNCH_s      : WORD_CNTRL_TYPE;
    signal SIGN_EN_s                : std_logic;
    signal RESU_DAR_SYNCH_s         : DATA_TYPE;
    signal RESU_DAR_ASYNCH_s        : DATA_TYPE;
    signal BRANCH_s                 : std_logic;
    signal ABS_OUT_s                : DATA_TYPE;
    signal REL_OUT_s                : DATA_TYPE;
    signal DO_EX_to_MA              : DATA_TYPE;
    signal PC_EX_to_MA              : ADDRESS_TYPE;
    
    component memory_access is
        port(
            clk, reset : in std_logic;
            
            --! @brief stage inputs
            WB_CNTRL_IN : in WB_CNTRL_TYPE;
            MA_CNTRL_SYNCH : in MA_CNTRL_TYPE;
            MA_CNTRL_ASYNCH: in MA_CNTRL_TYPE;
            WORD_CNTRL_SYNCH  : in WORD_CNTRL_TYPE;
            WORD_CNTRL_ASYNCH : in WORD_CNTRL_TYPE;
            SIGN_EN     : in std_logic;
            RESU_SYNCH  : in DATA_TYPE;
            RESU_ASYNCH : in ADDRESS_TYPE; -- asynchronous address for reading from mem
            DO          : in DATA_TYPE;
            PC_IN       : in ADDRESS_TYPE;
            
            --! @brief memory inputs
            DATA_IN     : in DATA_TYPE;
            
            --! @brief stage outputs
            WB_CNTRL_OUT: out WB_CNTRL_TYPE;
            DI          : out DATA_TYPE;
            PC_OUT      : out ADDRESS_TYPE;
            
            --! @brief memory outputs
            ENABLE      : out std_logic;
            WRITE_EN    : out std_logic;
            DATA_OUT    : out DATA_TYPE;
            ADDRESS     : out ADDRESS_TYPE;
            WORD_LENGTH : out WORD_CNTRL_TYPE
        );
    end component memory_access;
    for all : memory_access use entity work.memory_access(beh);
    
    signal WB_CNTRL_MA_to_WB    : WB_CNTRL_TYPE;
    signal DI_s                 : DATA_TYPE;
    signal PC_MA_to_WB          : ADDRESS_TYPE;    
    
    component write_back is
        port(
            WB_CNTRL_IN : in WB_CNTRL_TYPE;
            DATA_IN     : in DATA_TYPE;
            PC_IN       : in ADDRESS_TYPE;
            
            REG_ADDR    : out REGISTER_ADDRESS_TYPE;
            WRITE_BACK  : out DATA_TYPE
        );
    end component write_back;
    for all : write_back use entity work.write_back(beh);
    
    signal REG_ADDR_s   : REGISTER_ADDRESS_TYPE;
    signal WRITE_BACK_s : DATA_TYPE;
    
begin

    instruction_fetch_i : instruction_fetch
    port map(
        clk,
        reset,
        
        BRANCH_s,
        -- cntrl and pc adds
        IF_CNTRL_s,
        REL_OUT_s,
        ABS_OUT_s,
        
        -- instruction memory
        instruction,
        
        -- outputs
        IFR_s,
        pc_asynch,
        pc_synch_s
    );
    
    instruction_decode_i : instruction_decode
    port map(
        clk,
        reset,
        
        -- inputs
        BRANCH_s,
        IFR_s,
        pc_synch_s,
        WRITE_BACK_s,
        REG_ADDR_s,
        
        -- write back registers from stages
        WB_CNTRL_ID_to_EX(4 downto 0),
        WB_CNTRL_EX_to_MA(4 downto 0),
        WB_CNTRL_MA_to_WB(4 downto 0),
        MA_CNTRL_ID_to_EX(1),
        
        -- cntrl outs
        IF_CNTRL_s,
        WB_CNTRL_ID_to_EX,
        MA_CNTRL_ID_to_EX,
        EX_CNTRL_ID_to_EX,
        
        -- data outs
        IMM_s,
        OPB_s,
        OPA_s,
        
        DO_ID_to_EX,
        PC_ID_to_EX
    );
    
    execute_stage_i : execute_stage
    port map(
        clk,
        reset,
        
        -- cntrl ins
        WB_CNTRL_ID_to_EX,
        MA_CNTRL_ID_to_EX,
        EX_CNTRL_ID_to_EX,
        
        -- data ins
        IMM_s,
        OPB_s,
        OPA_s,
        
        DO_ID_to_EX,
        PC_ID_to_EX,
        
        -- cntrl outs
        WB_CNTRL_EX_to_MA,
        MA_CNTRL_SYNCH_EX_to_MA,
        MA_CNTRL_ASYNCH_EX_to_MA,
        WORD_CNTRL_SYNCH_s,
        WORD_CNTRL_ASYNCH_s,
        SIGN_EN_s,
        
        -- outs
        RESU_DAR_SYNCH_s,
        RESU_DAR_ASYNCH_s,
        BRANCH_s,
        ABS_OUT_s,
        REL_OUT_s,
        
        DO_EX_to_MA,
        PC_EX_to_MA
    );
    
    memory_access_i : memory_access
    port map(
        clk,
        reset,
        
        -- cntrl ins
        WB_CNTRL_EX_to_MA,
        MA_CNTRL_SYNCH_EX_to_MA,
        MA_CNTRL_ASYNCH_EX_to_MA,
        WORD_CNTRL_SYNCH_s,
        WORD_CNTRL_ASYNCH_s,
        SIGN_EN_s,
        
        -- ins
        RESU_DAR_SYNCH_s,
        RESU_DAR_ASYNCH_s,
        
        DO_EX_to_MA,
        PC_EX_to_MA,
        
        -- input from memory
        D_MEM_to_CORE,
        
        -- stage outs
        WB_CNTRL_MA_to_WB,
        DI_s,
        PC_MA_to_WB,
        
        -- output to memory
        EN,
        WEN,
        D_CORE_to_MEM,
        ADDR,
        WORD_LENGTH
    );
        
    write_back_i : write_back
    port map(
        WB_CNTRL_MA_to_WB,
        DI_s,
        PC_MA_to_WB,
        
        REG_ADDR_s,
        WRITE_BACK_s
    );

end architecture beh;
