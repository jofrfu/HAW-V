use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity instruction_fetch_TB is
end entity instruction_fetch_TB;

architecture TB of instruction_fetch_TB is
    component dut is
        port(
             clk, reset : in std_logic;
             
             branch    : in std_logic;      --! when branch the IFR has to be resetted
             cntrl     : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
             rel	   : in DATA_TYPE;		--! relative branch address
             abso	   : in DATA_TYPE;		--! absolute branch address, or base for relative jump
             ins 	   : in DATA_TYPE;		--! the new instruction is loaded from here
             
             IFR	   : out DATA_TYPE;	--! Instruction fetch register contents
             pc_asynch : out DATA_TYPE;    --! clocked pc register for ID stage
             pc_synch  : out ADDRESS_TYPE  --! asynchronous PC for instruction memory
        );
    end component dut;
    for all : dut use entity work.instruction_fetch(std_impl);
    
    signal clk_s         : std_logic := '0';
    signal reset_s       : std_logic := '0';
    signal simulation_running : boolean := false;
    
    signal branch_s      : std_logic := '0';
    signal cntrl_s       : IF_CNTRL_TYPE := (others => '0');
    signal rel_s         : DATA_TYPE := (others => '0');
    signal abso_s        : DATA_TYPE := (others => '0');
    signal ins_s         : DATA_TYPE;
    
    signal pc_asynch_s   : ADDRESS_TYPE;
    signal pc_synch_s    : ADDRESS_TYPE;
    signal IFR_s         : DATA_TYPE;
    
    
    
begin    

    dut_i : dut
    port map(
        clk_s,
        reset_s,
        branch_s,
        cntrl_s,
        rel_s,
        abso_s,
        ins_s,
        IFR_s,
        pc_asynch_s,
        pc_synch_s
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
        begin
        simulation_running <= true;
        reset_s <= '1';
        wait until '1'=clk_s and clk_s'event;
        reset_s <= '0';
        
        -- test 1
        -- cntrl: 00
        -- ins: 42
        -- action: adds 4 to PC
        -- result: PC should be 0
        -- result: IFR should be 42
        branch_s <= '0';
        cntrl_s <= "00";
        ins_s <= std_logic_vector(to_unsigned(42, ADDRESS_WIDTH));
        wait for 1 ns;
        if pc_asynch_s /= std_logic_vector(to_unsigned(0, ADDRESS_WIDTH)) then
            report "Test failed! Error on PC_asynch connection!";
            wait;
        end if;

        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if pc_synch_s /= std_logic_vector(to_unsigned(0, ADDRESS_WIDTH)) then
            report "Test failed! Error on PC_synch connection!";
            wait;
        end if;
        
        if IFR_s /= std_logic_vector(to_unsigned(42, ADDRESS_WIDTH)) then
            report "Test failed! Error on ins-IFR connection!";
            wait;
        end if;
        
        -- test2
        -- cntrl: 11
        -- action: adds immediate (8 in this case) to a register (512 in this case)
        -- result: PC should be 520
        branch_s <= '0';
        cntrl_s <= "11";
        rel_s <= std_logic_vector(to_unsigned(8, ADDRESS_WIDTH));
        abso_s <= std_logic_vector(to_unsigned(512, ADDRESS_WIDTH));
        wait for 1 ns;
        if pc_asynch_s /= std_logic_vector(to_unsigned(520, ADDRESS_WIDTH)) then
            report "Test failed! Error on abso or rel connection!";
            wait; 
        end if;
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if pc_synch_s /= std_logic_vector(to_unsigned(520, ADDRESS_WIDTH)) then
            report "Test failed! Error on abso or rel connection!";
            wait; 
        end if;
    
        -- test3
        -- cntrl: 
        -- action: branch! IFR must be discarded and replaced with nop
        -- result: IFR is NOP_INRUCT
        branch_s <= '1';
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if IFR_s /= NOP_INSTRUCT then
            report "Test failed! Error on IFR reset when branching";
            wait;
        end if;
    
        report "Test successful!";
        
        simulation_running <= false; 
        wait;
    end process test;
    
end architecture TB;
