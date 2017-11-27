--! @brief register_select.vhd
--! @author Jonas Fuhrmann + Felix Lorenz + Matthis Keppner
--! project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity decode is
	port(
		--clk, reset  :  in std_logic;  --neccessary?? TO DO: delete?
		branch      :  in std_logic;
		IFR	        :  in INSTRUCTION_BIT_TYPE;
		----------------------------------------
		IF_CNTRL    : out IF_CNTRL_TYPE;
		ID_CNTRL    : out ID_CNTRL_TYPE;
		WB_CNTRL    : out WB_CNTRL_TYPE;
		MA_CNTRL    : out MA_CNTRL_TYPE;
		EX_CNTRL    : out EX_CNTRL_TYPE;
		Imm         : out DATA_TYPE
	);
end entity decode;

architecture beh of decode is

begin
    
    --! @brief decode unit for ID stage
    --! @detail controls the PC flow IF stage and operand selection for EX stage
    decode:
    process(branch, IFR) is
    
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
       
    begin
        branch_v            := branch;
        op_bits_v           := IFR(OP_CODE_WIDTH-1 downto 0);
        op_code_v           := BITS_TO_OP_CODE_TYPE(op_bits_v);
        rd_v                := IFR(11 downto 7);
        funct3_v            := IFR(14 downto 12);
        rs1_v               := IFR(19 downto 15);
        rs2_v               := IFR(24 downto 20);
        funct7_v            := IFR(31 downto 25);
        
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
                    IF_CNTRL_v := "01";    --PC + rel
                    ID_CNTRL_v := '0' & '1' & "00000" & "00000";    --load r0 in opa and r0 in opb (r0 in do)
                    MA_CNTRL_v := "00";   --no load nor store
                    WB_CNTRL_v := '1' & rd_v;   --jump, write back (PC)
                when jalro =>
                    IF_CNTRL_v := "11";    --abs + rel
                    ID_CNTRL_v := '0' & '1' & "00000" & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                    MA_CNTRL_v := "00";    --no load nor store
                    WB_CNTRL_v := '1' & rd_v;   --jump, write back (PC)
                when brancho =>
                    IF_CNTRL_v := "00";    --next instruction will be loaded if no branching
                    ID_CNTRL_v := '0' & '0' & rs2_v & rs1_v;    --load rs1 in opa and rs2 in opb
                    MA_CNTRL_v := "00";    --no load nor store
                    WB_CNTRL_v := '0' & "00000";   --branch, no write back (no PC)
                when loado =>
                    IF_CNTRL_v := "00";    --PC + 4
                    ID_CNTRL_v := '0' & '1' & "00000" & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                    MA_CNTRL_v := "01";    --load
                    WB_CNTRL_v := '0' & rd_v;   --write loaded value to rd (no PC)
                when storeo =>
                    IF_CNTRL_v := "00";    --PC + 4
                    ID_CNTRL_v := '0' & '1' & rs2_v & rs1_v;    --load rs1 in opa, immediate in opb and rs2 in do
                    MA_CNTRL_v := "10";    --store
                    WB_CNTRL_v := '0' & "00000";   --value will be stored, no write back (no PC)
                when opimmo =>
                    IF_CNTRL_v := "00";    --PC + 4
                    ID_CNTRL_v := '0' & '1' & "00000" & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                    MA_CNTRL_v := "00";    --no load nor store
                    WB_CNTRL_v := '0' & rd_v;   --write result to rd (no PC)
                when opo =>
                    IF_CNTRL_v := "00";    --PC + 4
                    ID_CNTRL_v := '0' & '0' & rs2_v & rs1_v;    --load rs1 in opa and immediate in opb (r0 in do)
                    MA_CNTRL_v := "00";    --no load nor store
                    WB_CNTRL_v := '0' & rd_v;   --write result to rd (no PC)
                when others =>
                    report "decode.vhd - decode: unknown OP_CODE" severity error;
                    IF_CNTRL_v := "01";    --rel + PC
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
    
    --! @brief extracts the immediate in the IFR and sign extends it
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
        
        Imm <= immediate_v;
        
    end process imm_constr;

    
    
end architecture beh;