--!@file    instruction_decode.vhd
--!@brief   This file is part of the ach-ne projekt at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Felix Lorenz
--!@date    2017 - 2018

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity instruction_decode is
	port(
		clk, reset   :  in std_logic;
		branch		 :  in std_logic;             --!Signal from branch checker
		IFR			 :  in INSTRUCTION_BIT_TYPE;  --!actual Instruction word to be decoded
		PC           :  in DATA_TYPE;             --!Program Counter from that instruction in IFR
		DI	  		 :  in DATA_TYPE;             --!Data In from Write Back stage
		rd			 :  in REGISTER_ADDRESS_TYPE; --!Register Destination from Write Back stage
        -------------------------------------------------
        DEST_REG_EX  :  in REGISTER_ADDRESS_TYPE; --!DESTination REGister in EXectute stage
        DEST_REG_MA  :  in REGISTER_ADDRESS_TYPE; --!DESTination REGister in Memory Access stage
        DEST_REG_WB  :  in REGISTER_ADDRESS_TYPE; --!DESTination REGister in Write Back stage
        STORE        :  in std_logic;             --!Checks if STORE bit is set in last instruction
        -------------------------------------------------
		IF_CNTRL	 : out IF_CNTRL_TYPE;         --!Controlbits for IF-Stage
		WB_CNTRL	 : out WB_CNTRL_TYPE;         --!Controlbits for WB-Stage
		MA_CNTRL	 : out MA_CNTRL_TYPE;         --!Controlbits for MA-Stage
		EX_CNTRL	 : out EX_CNTRL_TYPE;         --!Controlbits for EX-Stage
		Imm			 : out DATA_TYPE;             --!IMMediate for EX-Stage
		OPB			 : out DATA_TYPE;             --!OPerand B for EX-Stage
		OPA			 : out DATA_TYPE;             --!OPerand A for EX-Stage
		DO			 : out DATA_TYPE;             --!Data Out when register file is read
        PC_o         : out ADDRESS_TYPE           --!PC Out for Jump and Link
	);
end entity instruction_decode;

--!@brief   This is the instruction decode stage of the CPU
--!@details This stage hast two main components
--!         1. decode unit
--!         2. the register file, including x0 to x31
architecture beh of instruction_decode is

	-- immediate mux
	signal imm_sel_s		: std_logic;
	signal imm_s			: DATA_TYPE;
	-- pc signal
	signal pc_en_s          : std_logic;
	-- register addresses
	signal rs1_s			: REGISTER_ADDRESS_TYPE;
	signal rs2_s			: REGISTER_ADDRESS_TYPE;
	-- operand signals
    signal opa_s            : DATA_TYPE;
	signal opb_s			: DATA_TYPE;

	-- registers
	signal wb_cntrl_reg_cs 	: WB_CNTRL_TYPE := WB_CNTRL_NOP;
	signal wb_cntrl_reg_ns 	: WB_CNTRL_TYPE;
	signal ma_cntrl_reg_cs 	: MA_CNTRL_TYPE := MA_CNTRL_NOP;
	signal ma_cntrl_reg_ns 	: MA_CNTRL_TYPE;
	signal ex_cntrl_reg_cs 	: EX_CNTRL_TYPE := EX_CNTRL_NOP;
	signal ex_cntrl_reg_ns 	: EX_CNTRL_TYPE;
    signal imm_reg_cs       : DATA_TYPE   := (others => '0'); 
    signal imm_reg_ns       : DATA_TYPE; 
	signal opb_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal opb_reg_ns 		: DATA_TYPE;
	signal opa_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal opa_reg_ns 		: DATA_TYPE;
	signal do_reg_cs 		: DATA_TYPE 	:= (others => '0');
	signal do_reg_ns 		: DATA_TYPE;
    signal pc_reg_cs        : ADDRESS_TYPE  := (others => '0');
    signal pc_reg_ns        : ADDRESS_TYPE;
	
	-- decode unit
	component decode is
		port(
			branch		 :  in std_logic;
			IFR			 :  in INSTRUCTION_BIT_TYPE;
            DEST_REG_EX  :  in REGISTER_ADDRESS_TYPE;
            DEST_REG_MA  :  in REGISTER_ADDRESS_TYPE;
            DEST_REG_WB  :  in REGISTER_ADDRESS_TYPE;
            STORE        :  in std_logic;
            Imm_check    :  in DATA_TYPE;
			IF_CNTRL	 : out IF_CNTRL_TYPE;
			ID_CNTRL	 : out ID_CNTRL_TYPE;
			WB_CNTRL	 : out WB_CNTRL_TYPE;
			MA_CNTRL	 : out MA_CNTRL_TYPE;
			EX_CNTRL	 : out EX_CNTRL_TYPE;
			Imm			 : out DATA_TYPE
		);
	end component decode;
    for all : decode use entity work.decode(beh);
	
	-- register file
	component register_select is
	    port(   
	    	clk, reset   :   in  std_logic;
	        DI           :   in  DATA_TYPE;
	        rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE;
	        OPA, OPB, DO :   out DATA_TYPE;
            -------- PC ports
            PC           :   in  ADDRESS_TYPE;
            PC_en        :   in  std_logic
	    );--]port
	end component register_select;
    for all : register_select use entity work.register_select(beh);
	
begin
	
	decode_i : decode
	port map(
		branch => branch,
		IFR => IFR,
        DEST_REG_EX => DEST_REG_EX,
        DEST_REG_MA => DEST_REG_MA,
        DEST_REG_WB => DEST_REG_WB,
        STORE => STORE,
        Imm_check => imm_reg_cs,
		IF_CNTRL => IF_CNTRL,
		ID_CNTRL(11) => pc_en_s,
		ID_CNTRL(10) => imm_sel_s,
		ID_CNTRL(9 downto 5) => rs2_s,
		ID_CNTRL(4 downto 0) => rs1_s,
		WB_CNTRL => wb_cntrl_reg_ns,
		MA_CNTRL => ma_cntrl_reg_ns,
		EX_CNTRL => ex_cntrl_reg_ns,
		Imm	=> imm_s
	);
    
    imm_reg_ns <= imm_s;    
	
	reg_sel_i : register_select
	port map(
		clk, 
		reset,
	    DI,
        rs1_s, 
        rs2_s, 
        rd,
        opa_s, 
        opb_s, 
        do_reg_ns,
        pc,
        pc_en_s
	);
    
    opa_reg_ns <= opa_s;
	
	--! @brief multiplexer for immediate OR OPB selection
	imm_mux:
	process(opb_s, imm_s, imm_sel_s) is
	begin
		if imm_sel_s = '1' then
			opb_reg_ns <= imm_s;
		else
			opb_reg_ns <= opb_s;
		end if;
	end process imm_mux;

	sequ_log:
	process(clk) is
	begin
		if clk'event and clk = '1' then
            if reset = '1' then
                wb_cntrl_reg_cs <= (others => '0');
                ma_cntrl_reg_cs <= (others => '0');
                ex_cntrl_reg_cs <= (others => '0');
                imm_reg_cs      <= (others => '0');
                opb_reg_cs 		<= (others => '0');
                opa_reg_cs 		<= (others => '0');
                do_reg_cs 		<= (others => '0');
                pc_reg_cs       <= (others => '0');
            else
            	wb_cntrl_reg_cs <= wb_cntrl_reg_ns;
                ma_cntrl_reg_cs <= ma_cntrl_reg_ns;
                ex_cntrl_reg_cs <= ex_cntrl_reg_ns;
                imm_reg_cs      <= imm_reg_ns;
                opb_reg_cs 		<= opb_reg_ns;
                opa_reg_cs 		<= opa_reg_ns;
                do_reg_cs 		<= do_reg_ns;
                pc_reg_cs       <= pc_reg_ns;
            end if;
        end if; 
	end process sequ_log;
	
    pc_reg_ns <= pc;
    PC_o      <= pc_reg_cs;
    WB_CNTRL  <= wb_cntrl_reg_cs;
    MA_CNTRL  <= ma_cntrl_reg_cs;
    EX_CNTRL  <= ex_cntrl_reg_cs;
    Imm       <= imm_reg_cs   ;
    OPB       <= opb_reg_cs 	;
    OPA       <= opa_reg_cs 	;
    DO        <= do_reg_cs 	;
    

end architecture beh;
