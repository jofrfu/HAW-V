--! @brief register_select.vhd
--! @author Jonas Fuhrmann + Felix Lorenz
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
    
        variable branc_v    : std_logic;
        variable op_code_v  : OP_CODE_TYPE;
        variable rd_v       : REGISTER_ADDRESS_TYPE;
        variable func3_v    : FUNC3_TYPE;
        variable rs1_v      : REGISTER_ADDRESS_TYPE;
        variable rs2_v      : REGISTER_ADDRESS_TYPE;
        variable func7_v    : FUNC7_TYPE;
        
        variable IF_CNTRL_v : IF_CNTRL_TYPE;
        variable ID_CNTRL_v : ID_CNTRL_TYPE;
        variable WB_CNTRL_v : WB_CNTRL_TYPE;
        variable MA_CNTRL_v : MA_CNTRL_TYPE;
        variable EX_CNTRL_v : EX_CNTRL_TYPE;
       
    begin
        
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
        
        variable immediate : DATA_TYPE;
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

        end case;
        
        Imm <= immediate_v;
        
    end process imm_constr;

    
    
end architecture beh;