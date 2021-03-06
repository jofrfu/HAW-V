--!@file    instruction_decode.vhd
--!@brief   This file is part of the ach-ne projekt at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Felix Lorenz
--!@author  Jonas Fuhrmann
--!@author  Matthis Keppner
--!@date    2017 - 2018

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity decode is
	port(
		--clk, reset  :  in std_logic;  --maybe a state machine would have been more beneficial here...
		branch      :  in std_logic;             --!Signal from branch checker
		IFR	        :  in INSTRUCTION_BIT_TYPE;  --!actual Instruction word to be decoded
        DEST_REG_EX :  in REGISTER_ADDRESS_TYPE; --!DESTination REGister in EXectute stage
        DEST_REG_MA :  in REGISTER_ADDRESS_TYPE; --!DESTination REGister in Memory Access stage
        DEST_REG_WB :  in REGISTER_ADDRESS_TYPE; --!DESTination REGister in Write Back stage
        STORE       :  in std_logic;             --!Checks if STORE bit is set in last instruction
        Imm_check   :  in DATA_TYPE;             --!IMMediate CHECK is needed for the jump execution
		---------------------------------------- 
		IF_CNTRL    : out IF_CNTRL_TYPE;         --!Controlbits for IF-Stage
		ID_CNTRL    : out ID_CNTRL_TYPE;         --!Controlbits for ID-Stage
		WB_CNTRL    : out WB_CNTRL_TYPE;         --!Controlbits for WB-Stage
		MA_CNTRL    : out MA_CNTRL_TYPE;         --!Controlbits for MA-Stage
		EX_CNTRL    : out EX_CNTRL_TYPE;         --!Controlbits for EX-Stage
		Imm         : out DATA_TYPE              --!IMMediate for EX-Stage
	);
end entity decode;

architecture beh of decode is

    signal rs1_in_pipe_s : std_logic;    --if high, rs1 is in the writeback of the following stages
    signal rs2_in_pipe_s : std_logic;    --if high, rs2 is in the writeback of the following stages

    signal imm_ifr_s     : DATA_TYPE;
    
begin

    --!@brief  First helping process to detect necessity of bubble
    --!@details Compares if the bits in the IFR where rs1 could be, will be changed by one of the following pipeline stages
    rs1_check_1:
    process(IFR(19 downto 15), DEST_REG_EX, DEST_REG_MA, DEST_REG_WB) is
        variable rs1_v         : REGISTER_ADDRESS_TYPE;
        variable rs1_in_pipe_v : std_logic;
        variable DEST_REG_EX_v : REGISTER_ADDRESS_TYPE;
        variable DEST_REG_MA_v : REGISTER_ADDRESS_TYPE;
        variable DEST_REG_WB_v : REGISTER_ADDRESS_TYPE;   
    begin
        rs1_v         := IFR(19 downto 15);
        DEST_REG_EX_v := DEST_REG_EX;
        DEST_REG_MA_v := DEST_REG_MA;
        DEST_REG_WB_v := DEST_REG_WB;
        if rs1_v /= "00000" then
            if rs1_v = DEST_REG_EX_v or rs1_v = DEST_REG_MA_v or rs1_v = DEST_REG_WB_v then
                rs1_in_pipe_v := '1';
            else
                rs1_in_pipe_v := '0';
            end if;
        else 
            rs1_in_pipe_v := '0';
        end if;
        
        rs1_in_pipe_s <= rs1_in_pipe_v;
    end process rs1_check_1;
    
    --!@brief  First helping process to detect necessity of bubble
    --!@details See rs1_check_1
    rs2_check_2:
    process(IFR(24 downto 20), DEST_REG_EX, DEST_REG_MA, DEST_REG_WB) is
        variable rs2_v         : REGISTER_ADDRESS_TYPE;
        variable rs2_in_pipe_v : std_logic;
        variable DEST_REG_EX_v : REGISTER_ADDRESS_TYPE;
        variable DEST_REG_MA_v : REGISTER_ADDRESS_TYPE;
        variable DEST_REG_WB_v : REGISTER_ADDRESS_TYPE;
    begin
        rs2_v         := IFR(24 downto 20);
        DEST_REG_EX_v := DEST_REG_EX;
        DEST_REG_MA_v := DEST_REG_MA;
        DEST_REG_WB_v := DEST_REG_WB;
        if rs2_v /= "00000" then
            if ( rs2_v = DEST_REG_EX_v or rs2_v = DEST_REG_MA_v or rs2_v = DEST_REG_WB_v ) then
                rs2_in_pipe_v := '1';
            else
                rs2_in_pipe_v := '0';
            end if;
        else 
            rs2_in_pipe_v := '0';
        end if;
        
        rs2_in_pipe_s <= rs2_in_pipe_v;
    end process rs2_check_2;
    
    --! @brief decode unit for ID stage
    --! @details controls the PC flow in IF stage 
    --!         the operand selection for EX stage
    --!         data output from register file
    --!         and creates bubble for the pipeline if needed
    decode:
    process(branch, IFR, rs1_in_pipe_s, rs2_in_pipe_s, STORE, Imm_check, imm_ifr_s) is
    
        variable branch_v   : std_logic;
        variable op_bits_v  : OP_CODE_BIT_TYPE;
        variable op_code_v  : OP_CODE_TYPE;
        variable rd_v       : REGISTER_ADDRESS_TYPE;
        variable funct3_v   : FUNCT3_TYPE;
        variable rs1_v      : REGISTER_ADDRESS_TYPE;
        variable rs2_v      : REGISTER_ADDRESS_TYPE;
        variable funct7_v   : FUNCT7_TYPE;
        
        variable IF_CNTRL_v : IF_CNTRL_TYPE;
        variable ID_CNTRL_v : ID_CNTRL_TYPE;
        variable WB_CNTRL_v : WB_CNTRL_TYPE;
        variable MA_CNTRL_v : MA_CNTRL_TYPE;
        variable EX_CNTRL_v : EX_CNTRL_TYPE;
        
        variable Imm_check_v   : DATA_TYPE;
        variable imm_ifr_v     : DATA_TYPE;
        variable rs1_in_pipe_v : std_logic;
        variable rs2_in_pipe_v : std_logic;
        variable STORE_v       : std_logic;
       
    begin
        branch_v            := branch;
        op_bits_v           := IFR(OP_CODE_WIDTH-1 downto 0);
        op_code_v           := BITS_TO_OP_CODE_TYPE(op_bits_v);
        rd_v                := IFR(11 downto 7);
        funct3_v            := IFR(14 downto 12);
        rs1_v               := IFR(19 downto 15);
        rs2_v               := IFR(24 downto 20);
        funct7_v            := IFR(31 downto 25);
        Imm_check_v         := Imm_check;
        imm_ifr_v           := imm_ifr_s;
        rs1_in_pipe_v       := rs1_in_pipe_s;
        rs2_in_pipe_v       := rs2_in_pipe_s;
        STORE_v             := STORE;
        
        if branch_v = '1' then
            IF_CNTRL_v := "01";    --rel + PC
            ID_CNTRL_v := ID_CNTRL_NOP; --discard instruction in pipeline
            EX_CNTRL_v := EX_CNTRL_NOP;
            MA_CNTRL_v := MA_CNTRL_NOP;
            WB_CNTRL_v := WB_CNTRL_NOP;
        else
            --normal decoding 
            --always send this
            EX_CNTRL_v := funct7_v & funct3_v & op_bits_v;  --funct7 and funct3 might be nonsense when the opcode does not need them
                    
            --check for OP_CODE
            case op_code_v is
                when luio =>
                    IF_CNTRL_v := "00";    --PC + 4
                    ID_CNTRL_v := '0' & '1' & "00000" & "00000";    --load immediate for opb and r0 for opa (r0 in do)
                    MA_CNTRL_v := "00";   --no load nor store
                    WB_CNTRL_v := '0' & rd_v;   --write result to rd (no PC)
                when auipco =>
                    IF_CNTRL_v := "00";    --PC + 4
                    ID_CNTRL_v := '1' & '1' & "00000" & "00000";    --load pc in opa and immediate in opb (r0 in do)
                    MA_CNTRL_v := "00";   --no load nor store
                    WB_CNTRL_v := '0' & rd_v;   --write result to rd (no PC)
                when jalo =>
                    if Imm_check_v /= imm_ifr_v then  --imediate is not yet in register
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else 
                        IF_CNTRL_v := "01";    --PC + rel
                        ID_CNTRL_v := '0' & '1' & "00000" & "00000";    --load r0 in opa and r0 in opb (r0 in do)
                        MA_CNTRL_v := "00";   --no load nor store
                        WB_CNTRL_v := '1' & rd_v;   --jump, write back (PC)
                    end if;
                when jalro =>
                    if Imm_check_v /= imm_ifr_v then  --imediate is not yet in register
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else 
                        if  rs1_in_pipe_v = '1' then
                            IF_CNTRL_v := IF_CNTRL_BUB;
                            ID_CNTRL_v := ID_CNTRL_BUB;
                            EX_CNTRL_v := EX_CNTRL_BUB;
                            MA_CNTRL_v := MA_CNTRL_BUB;
                            WB_CNTRL_v := WB_CNTRL_BUB;
                        else                    
                            IF_CNTRL_v := "11";    --abs + rel
                            ID_CNTRL_v := '0' & '1' & "00000" & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                            MA_CNTRL_v := "00";    --no load nor store
                            WB_CNTRL_v := '1' & rd_v;   --jump, write back (PC)
                        end if;
                    end if;
                when brancho =>
                    if rs1_in_pipe_v = '1' or rs2_in_pipe_v = '1' then
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else
                        IF_CNTRL_v := "00";    --next instruction will be loaded if no branching
                        ID_CNTRL_v := '0' & '0' & rs2_v & rs1_v;    --load rs1 in opa and rs2 in opb
                        MA_CNTRL_v := "00";    --no load nor store
                        WB_CNTRL_v := '0' & "00000";   --branch, no write back (no PC)
                    end if;
                when loado =>
                    if  rs1_in_pipe_v = '1' or STORE_v = '1' then
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else    
                        IF_CNTRL_v := "00";    --PC + 4
                        ID_CNTRL_v := '0' & '1' & "00000" & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                        MA_CNTRL_v := "01";    --load
                        WB_CNTRL_v := '0' & rd_v;   --write loaded value to rd (no PC)
                    end if;
                when storeo =>
                    if rs1_in_pipe_v = '1' or rs2_in_pipe_v = '1' then
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else
                        IF_CNTRL_v := "00";    --PC + 4
                        ID_CNTRL_v := '0' & '1' & rs2_v & rs1_v;    --load rs1 in opa, immediate in opb and rs2 in do
                        MA_CNTRL_v := "10";    --store
                        WB_CNTRL_v := '0' & "00000";   --value will be stored, no write back (no PC)
                    end if;
                when opimmo =>
                    if  rs1_in_pipe_v = '1' then
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else   
                        IF_CNTRL_v := "00";    --PC + 4
                        ID_CNTRL_v := '0' & '1' & "00000" & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                        MA_CNTRL_v := "00";    --no load nor store
                        WB_CNTRL_v := '0' & rd_v;   --write result to rd (no PC)
                    end if;
                when opo =>
                    if rs1_in_pipe_v = '1' or rs2_in_pipe_v = '1' then
                        IF_CNTRL_v := IF_CNTRL_BUB;
                        ID_CNTRL_v := ID_CNTRL_BUB;
                        EX_CNTRL_v := EX_CNTRL_BUB;
                        MA_CNTRL_v := MA_CNTRL_BUB;
                        WB_CNTRL_v := WB_CNTRL_BUB;
                    else
                        IF_CNTRL_v := "00";    --PC + 4
                        ID_CNTRL_v := '0' & '0' & rs2_v & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                        MA_CNTRL_v := "00";    --no load nor store
                        WB_CNTRL_v := '0' & rd_v;   --write result to rd (no PC)
                    end if;
                when others =>
                    report "decode.vhd - decode: unknown OP_CODE" severity error;
                    IF_CNTRL_v := "00";    
                    ID_CNTRL_v := ID_CNTRL_NOP; --discard instruction in pipeline
                    EX_CNTRL_v := EX_CNTRL_NOP;
                    MA_CNTRL_v := MA_CNTRL_NOP;
                    WB_CNTRL_v := WB_CNTRL_NOP;
            end case;
        end if; --branch_v
        
        IF_CNTRL <= IF_CNTRL_v;
        ID_CNTRL <= ID_CNTRL_v;
        EX_CNTRL <= EX_CNTRL_v;
        MA_CNTRL <= MA_CNTRL_v;
        WB_CNTRL <= WB_CNTRL_v;
    end process decode;
    
    --! @brief  Immediate construction
    --! @details Extracts the immediate in the IFR and sign extends it
    imm_constr:
    process(IFR) is
        variable op_code_v   : OP_CODE_TYPE;
        variable imm_bits_v  : std_logic_vector( INSTRUCTION_WIDTH-1 downto OP_CODE_WIDTH );
        
        variable immediate_v : DATA_TYPE;
    begin
        op_code_v := BITS_TO_OP_CODE_TYPE(IFR(OP_CODE_WIDTH-1 downto 0));
        imm_bits_v := IFR(imm_bits_v'range);
        immediate_v := (others => imm_bits_v(imm_bits_v'left)); --MSB is always the sign bit if immediate is available
        
        case op_code_v is
            when opimmo | jalro | loado | opo => -- I-Type  / opo has R-Type, no immediate so it does not matter where it goes
                immediate_v(10 downto 0) := imm_bits_v(30 downto 20);
            
            when luio | auipco => -- U-Type
                immediate_v(30 downto 12) := imm_bits_v(30 downto 12);
                immediate_v(11 downto 0) := (others => '0');
            
            when jalo => -- J-Type
                immediate_v(19 downto 12) := imm_bits_v(19 downto 12);
                immediate_v(11) := imm_bits_v(20);
                immediate_v(10 downto 1) := imm_bits_v(30 downto 21);
                immediate_v(0) := '0';
            
            when brancho => -- B-Type
                immediate_v(11) := imm_bits_v(7);
                immediate_v(10 downto 5) := imm_bits_v(30 downto 25);
                immediate_v(4 downto 1) := imm_bits_v(11 downto 8);
                immediate_v(0) := '0';
            
            when storeo => -- S-Type
                immediate_v(10 downto 5) := imm_bits_v(30 downto 25);
                immediate_v(4 downto 1) := imm_bits_v(11 downto 8);
                immediate_v(0) := imm_bits_v(7);
                
            when others =>
                report "decode.vhd - imm_constr: unknown OP_CODE" severity error;
                immediate_v := (others => '0');
        end case;
        
        imm_ifr_s <= immediate_v;
        
    end process imm_constr;
    
    Imm <= imm_ifr_s;
    
    
end architecture beh;