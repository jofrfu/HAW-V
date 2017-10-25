--! @brief instruction decode stage
--! @author Jonas Fuhrmann + Felix Lorenz
--! project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity instruction_decode is
	port(
		clk, reset   :  in std_logic;
		branch		 :  in std_logic;
		IFR			 :  in INSTRUCTION_TYPE;
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
		DO			 : out DATA_TYPE
	);
end entity instruction_decode;

--! @brief register selection and decode of instructions
architecture beh of instruction_decode is

	-- immediate mux
	signal imm_sel_s		: std_logic;
	signal imm_s			: DATA_TYPE;
	-- pc mux
	signal pc_sel_s         : std_logic;
	-- register addresses
	signal rs1_s			: REGISTER_ADDRESS_TYPE;
	signal rs2_s			: REGISTER_ADDRESS_TYPE;
	-- operand signals
    signal opa_s            : DATA_TYPE;
	signal opb_s			: DATA_TYPE;

	--! registers
	signal wb_cntrl_reg_cs 	: WB_CNTRL_TYPE := WB_CNTRL_NOP;
	signal wb_cntrl_reg_ns 	: WB_CNTRL_TYPE;
	signal ma_cntrl_reg_cs 	: MA_CNTRL_TYPE := MA_CNTRL_NOP;
	signal ma_cntrl_reg_ns 	: MA_CNTRL_TYPE;
	signal ex_cntrl_reg_cs 	: EX_CNTRL_TYPE := EX_CNTRL_NOP;
	signal ex_cntrl_reg_ns 	: EX_CNTRL_TYPE;
	signal imm_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal imm_reg_ns 		: DATA_TYPE;
	signal opb_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal opb_reg_ns 		: DATA_TYPE;
	signal opa_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal opa_reg_ns 		: DATA_TYPE;
	signal do_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal do_reg_ns 		: DATA_TYPE;
	
	--! @brief decode unit
	component decode is
		port(
			clk, reset   :  in std_logic;
			branch		 :  in std_logic;
			IFR			 :  in INSTRUCTION_TYPE;
			IF_CNTRL	 : out IF_CNTRL_TYPE;
			ID_CNTRL	 : out ID_CNTRL_TYPE;
			WB_CNTRL	 : out WB_CNTRL_TYPE;
			MA_CNTRL	 : out MA_CNTRL_TYPE;
			EX_CNTRL	 : out EX_CNTRL_TYPE;
			Imm			 : out DATA_TYPE
		);
	end component decode;
	
	--! @brief register file
	component register_select is
	    port(   
	    	clk, reset   :   in  std_logic;
	        DI           :   in  DATA_TYPE;
	        rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE;
	        OPA, OPB, DO :   out DATA_TYPE
	    );--]port
	end component register_select;
	
begin
	
	decode_i : decode
	port map(
		clk => clk,
		reset => reset,
		branch => branch,
		IFR => IFR,
		IF_CNTRL => IF_CNTRL,
		ID_CNTRL(11) => pc_sel_s,
		ID_CNTRL(10) => imm_sel_s,
		ID_CNTRL(9 downto 5) => rs2_s,
		ID_CNTRL(4 downto 0) => rs1_s,
		WB_CNTRL => wb_cntrl_reg_ns,
		MA_CNTRL => ma_cntrl_reg_ns,
		EX_CNTRL => ex_cntrl_reg_ns,
		Imm	=> imm_s
	);
	
	reg_sel_i : register_select
	port map(
		clk => clk, 
		reset => reset,
	    DI => DI,
        rs1 => rs1_s, 
        rs2 => rs2_s, 
        rd => rd,
        OPA => opa_s, 
        OPB => opb_s, 
        DO => do_reg_ns
	);
	
	--! @brief multiplexer for immediate and operand b selection
	imm_mux:
	process(opb_s, imm_s, imm_sel_s) is
	begin
		if imm_sel_s = '1' then
			opb_reg_ns <= imm_s;
		else
			opb_reg_ns <= opb_s;
		end if;
	end process imm_mux;
	
	--! @brief multiplexer for pc and operand a selection
    pc_mux:
    process(opa_s, PC, pc_sel_s) is
    begin
        if imm_sel_s = '1' then
            opa_reg_ns <= PC;
        else
            opa_reg_ns <= opa_s;
        end if;
    end process pc_mux;

	sequ_log:
	process(clk,reset) is
	begin
		if clk'event and clk = '1' then
            if reset = '1' then
                wb_cntrl_reg_cs <= (others => '0');
                ma_cntrl_reg_cs <= (others => '0');
                ex_cntrl_reg_cs <= (others => '0');
                imm_reg_cs 		<= (others => '0');
                opb_reg_cs 		<= (others => '0');
                opa_reg_cs 		<= (others => '0');
                do_reg_cs 		<= (others => '0');
            else
            	wb_cntrl_reg_cs <= wb_cntrl_reg_ns;
                ma_cntrl_reg_cs <= ma_cntrl_reg_ns;
                ex_cntrl_reg_cs <= ex_cntrl_reg_ns;
                imm_reg_cs 		<= imm_reg_ns;
                opb_reg_cs 		<= opb_reg_ns;
                opa_reg_cs 		<= opa_reg_ns;
                do_reg_cs 		<= do_reg_ns;
            end if;
        end if; 
	end process sequ_log;
	

end architecture beh;
