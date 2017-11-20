use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity instruction_decode_TB is
end entity instruction_decode_TB;

architecture TB of instruction_decode_TB is
    component dut is
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
    end component dut;
    for all : dut use entity work.instruction_decode(beh);
    
    signal clk_s                : std_logic := '0';
    signal reset_s              : std_logic := '0';
    signal simulation_running   : boolean   := false;
    
    signal branch_s	    : std_logic         := '0';
    signal IFR_s        : INSTRUCTION_BIT_TYPE  := "00000000000000000" & ADDI_FUNCT3 & "00000" & OP_CODE_TYPE_TO_BITS(opimmo);  --initialized with nop
    signal PC_s         : DATA_TYPE         := (others => '0');
    signal DI_s	        : DATA_TYPE         := (others => '0');
    signal rd_s         : REGISTER_ADDRESS_TYPE := (others => '0');
    
    signal IF_CNTRL_s	: IF_CNTRL_TYPE;
    signal WB_CNTRL_s	: WB_CNTRL_TYPE;
    signal MA_CNTRL_s	: MA_CNTRL_TYPE;
    signal EX_CNTRL_s	: EX_CNTRL_TYPE;
    signal Imm_s		: DATA_TYPE;
    signal OPB_s        : DATA_TYPE;
    signal OPA_s        : DATA_TYPE;
    signal DO_s	        : DATA_TYPE;
    signal PC_o_s       : ADDRESS_TYPE;
    
    
    
begin    

    dut_i : dut
    port map(
        clk_s,
        reset_s,
        branch_s,
        IFR_s,
        PC_s,
        DI_s,	  
        rd_s,  
        
        IF_CNTRL_s,
        WB_CNTRL_s,
        MA_CNTRL_s,
        EX_CNTRL_s,
        Imm_s,		
        OPB_s,     
        OPA_s,     
        DO_s,	  
        PC_o_s    
    );

    clk_gen:
    process is
        begin
        wait until simulation_running = true;
        clk_s <= '0';
        wait for 40 ns;
        while simulation_running loop
            clk_s <= '1';
            wait for 20 ns;
            clk_s <= '0';
            wait for 20 ns;
        end loop;
    end process clk_gen;

    test:
    process is
        variable immediate      : integer;
        variable opcode         : OP_CODE_TYPE;
        variable rs2, rs1, rd   : integer range 0 to REGISTER_COUNT-1;
        variable funct3         : FUNCT3_TYPE;
        variable funct7         : FUNCT7_TYPE;
    begin
        simulation_running <= true;
        reset_s <= '1';
        wait until '1'=clk_s and clk_s'event;
        reset_s <= '0';
        
        --setup
        --load x1 with 1 and x2 with 2
        DI_s <= std_logic_vector(to_signed(1, DATA_WIDTH));
        rd_s <= std_logic_vector(to_unsigned(1, REGISTER_ADDRESS_WIDTH));
        wait until '1'=clk_s and clk_s'event;
        DI_s <= std_logic_vector(to_signed(2, DATA_WIDTH));
        rd_s <= std_logic_vector(to_unsigned(2, REGISTER_ADDRESS_WIDTH));
        wait until '1'=clk_s and clk_s'event;
        
        --test1
        --add x3, x1, x2 
        report "add test";
        funct7  := ADD_FUNCT7;
        funct3  := ADD_FUNCT3;
        opcode  := opo;
        rs2     := 2;
        rs1     := 1;
        rd      := 3;

        IFR_s <= IFR_R_TYPE(funct7, rs2, rs1, funct3, rd, opcode);
        wait until '1'=clk_s and clk_s'event;        
        wait for 1 ns;
        if IF_CNTRL_s /= "00" then  --pc + 4
            report "failed in IF_CNTRL" severity error;
            wait;
        end if;
        
        if WB_CNTRL_s /= ('0' & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH))) then
            report "failed in WB_CNTRL" severity error;
            simulation_running <= false;
            wait;
        end if;
        
        if MA_CNTRL_s /= "00" then
            report "failed in MA_CNTRL" severity error;
            wait;
        end if;
        
        if EX_CNTRL_s /= funct7 & funct3 & OP_CODE_TYPE_TO_BITS(opcode) then
            report "failed in EX_CNTRL" severity error;
            wait;
        end if;        
        
        if OPB_s /= std_logic_vector(to_unsigned(rs2, DATA_WIDTH)) then
            report "failed in OPB" severity error;
            wait;
        end if;
        
        if OPA_s /= std_logic_vector(to_unsigned(rs1, DATA_WIDTH)) then
            report "failed in OPA" severity error;
            wait;
        end if; 
        
        --test2
        --addi
        report "addi test";
        immediate    := -1;
        opcode       := opimmo;
        rs1          := 1;
        rd           := 2;
        funct3       := ADDI_FUNCT3;
        
        IFR_s <= IFR_I_TYPE(immediate, rs1, funct3, rd, opcode);
        wait until '1'=clk_s and clk_s'event;   
        wait for 1 ns;
        if IF_CNTRL_s /= "00" then  --pc + 4
            report "failed in IF_CNTRL" severity error;
            wait;
        end if;
        
        if WB_CNTRL_s /= '0' & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) then
            report "failed in WB_CNTRL" severity error;
            wait;
        end if;
        
        if MA_CNTRL_s /= "00" then
            report "failed in MA_CNTRL" severity error;
            wait;
        end if;
        
        if EX_CNTRL_s(9 downto 0) /= funct3 & OP_CODE_TYPE_TO_BITS(opcode) then
            report "failed in EX_CNTRL" severity error;
            wait;
        end if;        
        
        if Imm_s /= std_logic_vector(to_signed(immediate, DATA_WIDTH)) then
            report "failed in immediate" severity error;
            wait;
        end if;
        
        if OPB_s /= std_logic_vector(to_signed(immediate, DATA_WIDTH)) then
            report "failed in OPB" severity error;
            wait;
        end if;
        
        if OPA_s /= std_logic_vector(to_unsigned(rs1, DATA_WIDTH)) then
            report "failed in OPA" severity error;
            wait;
        end if; 
        
        --test3        
        --sb x1, x2, -4
        report "store test";
        immediate   := -4;
        opcode      := storeo;
        rs2         := 2;
        rs1         := 1;
        funct3      := SB_FUNCT3;
        
        IFR_s <= IFR_S_TYPE(immediate, rs2, rs1, funct3, opcode);
        wait until '1'=clk_s and clk_s'event; 
        wait for 1 ns;
        if IF_CNTRL_s /= "00" then  --pc + 4
            report "failed in IF_CNTRL" severity error;
            wait;
        end if;
        
        if WB_CNTRL_s(5) /= '0' then
            report "failed in WB_CNTRL" severity error;
            wait;
        end if;
        
        if MA_CNTRL_s /= "10" then
            report "failed in MA_CNTRL" severity error;
            wait;
        end if;
        
        if EX_CNTRL_s(9 downto 0) /= funct3 & OP_CODE_TYPE_TO_BITS(opcode) then
            report "failed in EX_CNTRL" severity error;
            wait;
        end if;        
        
        if Imm_s /= std_logic_vector(to_signed(immediate, DATA_WIDTH)) then
            report "failed in immediate" severity error;
            wait;
        end if;
        
        if OPB_s /= std_logic_vector(to_signed(immediate, DATA_WIDTH)) then
            report "failed in OPB" severity error;
            wait;
        end if;
        
        if DO_s /= std_logic_vector(to_signed(rs2, DATA_WIDTH)) then
            report "failed in data out" severity error;
            wait;
        end if;
        
        if OPA_s /= std_logic_vector(to_unsigned(rs1, DATA_WIDTH)) then
            report "failed in OPA" severity error;
            wait;
        end if; 
        
        --test4
        --jal x2, -4
        report "jal test";
        opcode      := jalo;
        immediate   := -4; 
        rd          := 2;        
                
        IFR_s <= IFR_J_TYPE(immediate, rd, opcode);
        PC_s  <= std_logic_vector(to_signed(404, DATA_WIDTH));
        wait until '1'=clk_s and clk_s'event; 
        wait for 1 ns;
        if IF_CNTRL_s /= "01" then  --pc + 4
            report "failed in IF_CNTRL" severity error;
            wait;
        end if;
        
        if WB_CNTRL_s /= '1' & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) then
            report "failed in WB_CNTRL" severity error;
            wait;
        end if;
        
        if MA_CNTRL_s /= MA_CNTRL_NOP then
            report "failed in MA_CNTRL" severity error;
            wait;
        end if;       
        
        if Imm_s /= std_logic_vector(to_signed(immediate, DATA_WIDTH)) then
            report "failed in immediate" severity error;
            wait;
        end if;        
        
        if PC_o_s /= std_logic_vector(to_signed(404, DATA_WIDTH)) then
            report "failed in pc out" severity error;
            wait;
        end if;
        
    
    
        report "Test successful!";
        
        simulation_running <= false; 
        wait;
    end process test;
    
end architecture TB;
