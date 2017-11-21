--!@brief 	This file contains the top level entity of the CPU
--!@author 	Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity risc_v_core is
    port(
        clk, reset   : in std_logic
    );
end entity risc_v_core;

architecture beh of risc_v_core is
    component instruction_fetch is
        port(
             clk, reset : in std_logic;
             
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
    signal pc_asynch_s : ADDRESS_TYPE;
    signal pc_synch_s  : ADDRESS_TYPE;
    
    component instruction_decode is
        port(
            clk, reset   :  in std_logic;
            branch		 :  in std_logic;
            IFR			 :  in INSTRUCTION_BIT_TYPE;
            PC           :  in DATA_TYPE;
            DI	  		 :  in DATA_TYPE;
            rd			 :  in REGISTER_ADDRESS_TYPE;
            
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
            
            WB_CNTRL_OUT  : out WB_CNTRL_TYPE;   --!Controlbits for WB-Stage 
            MA_CNTRL_OUT  : out MA_CNTRL_TYPE;   --!Controlbits for MA-Stage
            WORD_CNTRL_OUT: out WORD_CNTRL_TYPE; --!Controlbits for MA-Stage (word length)
            SIGN_EN       : out std_logic;       --!Enables sign extension in memory access
            RESU_DAR      : out DATA_TYPE;       --!Result of calulation
            Branch        : out std_logic;       --!For conditioned branching
            ABS_OUT       : out DATA_TYPE;
            REL_OUT       : out DATA_TYPE;
            DO_OUT        : out DATA_TYPE;       --!Data-output-register is passed to next stage
            PC_OUT        : out ADDRESS_TYPE     --!PC Register
        );
    end component execute_stage;
    for all : execute_stage use entity work.execute_stage(beh);
    
    signal WB_CNTRL_EX_to_MA : WB_CNTRL_TYPE;
    signal MA_CNTRL_EX_to_MA : MA_CNTRL_TYPE;
    signal WORD_CNTRL_s      : WORD_CNTRL_TYPE;
    signal SIGN_EN_s         : std_logic;
    signal RESU_DAR_s        : DATA_TYPE;
    signal BRANCH_s          : std_logic;
    signal ABS_OUT_s         : DATA_TYPE;
    signal REL_OUT_s         : DATA_TYPE;
    signal DO_EX_to_MA       : DATA_TYPE;
    signal PC_EX_to_MA       : ADDRESS_TYPE;
    
    component memory_access is
        port(
            clk, reset : in std_logic;
            
            --! @brief stage inputs
            WB_CNTRL_IN : in WB_CNTRL_TYPE;
            MA_CNTRL    : in MA_CNTRL_TYPE;
            WORD_CNTRL  : in WORD_CNTRL_TYPE;
            SIGN_EN     : in std_logic;
            RESU        : in DATA_TYPE;
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
    
    signal ENABLE_s     : std_logic;
    signal WRITE_EN_s   : std_logic;
    signal DATA_OUT_s   : DATA_TYPE;
    signal ADDRESS_s    : ADDRESS_TYPE;
    signal WORD_LENGTH_s: WORD_CNTRL_TYPE;
    
    -- WORD_CNTRL to BYTE_WRITE_EN
    signal BYTE_WRITE_EN_s : std_logic_vector(3 downto 0);
    
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
    
    component memory is
        Port ( 
            clka : in STD_LOGIC;
            ena : in STD_LOGIC;
            wea : in STD_LOGIC_VECTOR ( 3 downto 0 );
            addra : in STD_LOGIC_VECTOR ( 31 downto 0 );
            dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
            douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
            clkb : in STD_LOGIC;
            enb : in STD_LOGIC;
            web : in STD_LOGIC_VECTOR ( 3 downto 0 );
            addrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
            dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
            doutb : out STD_LOGIC_VECTOR ( 31 downto 0 )
        );
    end component memory;
    for all : memory use entity work.blk_mem_gen_0(stub);
    
    signal DOUT_A_s : DATA_TYPE;
    signal DOUT_B_s : DATA_TYPE;
    
begin

    instruction_fetch_i : instruction_fetch
    port map(
        clk,
        reset,
        
        -- cntrl and pc adds
        IF_CNTRL_s,
        REL_OUT_s,
        ABS_OUT_s,
        
        -- instruction memory
        DOUT_A_s,
        
        -- outputs
        IFR_s,
        pc_asynch_s,
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
        MA_CNTRL_EX_to_MA,
        WORD_CNTRL_s,
        SIGN_EN_s,
        
        -- outs
        RESU_DAR_s,
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
        MA_CNTRL_EX_to_MA,
        WORD_CNTRL_s,
        SIGN_EN_s,
        
        -- ins
        RESU_DAR_s,
        
        DO_EX_to_MA,
        PC_EX_to_MA,
        
        -- memory ins
        DOUT_B_s,
        
        -- stage outs
        WB_CNTRL_MA_to_WB,
        DI_s,
        PC_MA_to_WB,
        
        -- memory outs
        ENABLE_s,
        WRITE_EN_s,
        DATA_OUT_s,
        ADDRESS_s,
        WORD_LENGTH_s
    );
    
    write_en:
    process(WORD_LENGTH_s, WRITE_EN_s) is
        variable WORD_LENGTH_v   : WORD_CNTRL_TYPE;
        variable WRITE_EN_v      : std_logic;
        variable BYTE_WRITE_EN_v : std_logic_vector(3 downto 0);
    begin
        WORD_LENGTH_v := WORD_LENGTH_s;
        WRITE_EN_v    := WRITE_EN_s;
        
        if WRITE_EN_v = '1' then
            case WORD_LENGTH_v is
                when BYTE =>
                    BYTE_WRITE_EN_v := "0001";
                when HALF =>
                    BYTE_WRITE_EN_v := "0011";
                when WORD =>
                    BYTE_WRITE_EN_v := "1111";
                when others =>
                    BYTE_WRITE_EN_v := "0000";
                    report "Unknown word length in write_en conversion! Probable faulty implementation." severity warning;
            end case;
        else
            BYTE_WRITE_EN_v := "0000";
        end if;
        
        BYTE_WRITE_EN_s <= BYTE_WRITE_EN_v;
    end process write_en;
    
    write_back_i : write_back
    port map(
        WB_CNTRL_MA_to_WB,
        DI_s,
        PC_MA_to_WB,
        
        REG_ADDR_s,
        WRITE_BACK_s
    );
    
    memory_i : memory
    port map(
        -- port a: Intstructions
        clk,
        '1',            -- enable : always on instruction ram
        "0000",         -- wen    : no write on instruction ram
        pc_asynch_s,    -- address: pc on instruction ram
        (others => '0'),-- DIN    : no write on instruction ram
        DOUT_A_s,       -- DOUT   : instruction
        
        -- port b: Data
        clk,
        ENABLE_s,       -- enable : enable from MA
        BYTE_WRITE_EN_s,-- wen    : converted write enable from MA
        ADDRESS_s,      -- address: address from MA
        DATA_OUT_s,     -- DIN    : DATA_OUT from MA
        DOUT_B_s        -- DOUT   : DATA_IN on MA
    );

end architecture beh;
