--!@file    memory_access.vhdl
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Jonas Fuhrmann
--!@author  Sebastian Brückner
--!@date    2017 - 2018

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@brief   Memory Access Stage
--!@details Tasks:
--!         1. Write to RAM
--!         2. Control LOAD
--!         Note that reading from RAM needs the address before the next rising edge,
--!         so it can deliver the data on the next rising edge. 
--!         This makes asynchronous inputs for MA necessary.
entity memory_access is
    port(
        clk, reset        : in std_logic;
        
        WB_CNTRL_IN       : in WB_CNTRL_TYPE;
        MA_CNTRL_SYNCH    : in MA_CNTRL_TYPE;     --!see MA_CNTRL_TYPE doc, synchronous for write
        MA_CNTRL_ASYNCH   : in MA_CNTRL_TYPE;     --!see MA_CNTRL_TYPE doc, asynchronous for read
        WORD_CNTRL_SYNCH  : in WORD_CNTRL_TYPE;   --!see WORD_CNTRL_TYPE doc, synchronous for write
        WORD_CNTRL_ASYNCH : in WORD_CNTRL_TYPE;   --!see WORD_CNTRL_TYPE doc, asynchronous for read
        SIGN_EN           : in std_logic;         --!enable sign extension of data loaded from memory
        RESU_SYNCH        : in DATA_TYPE;         --!synchronous address for writing, or data to be simply piped through 
        RESU_ASYNCH       : in ADDRESS_TYPE;      --!asynchronous address for reading from mem
        DO                : in DATA_TYPE;         --!data to be stored
        PC_IN             : in ADDRESS_TYPE;      --!PC pipe through
        
        --input from memory
        DATA_IN           : in DATA_TYPE;         --!data that is read from memory
        
        --! @brief stage outputs
        WB_CNTRL_OUT      : out WB_CNTRL_TYPE;    --!write back control
        DI                : out DATA_TYPE;        --!contains either data read from memory or piped through data from RESU_SYNCH
        PC_OUT            : out ADDRESS_TYPE;     --!PC pipe through
        
        --output to memory
        ENABLE            : out std_logic;        --!memory enable
        WRITE_EN          : out std_logic;        --!write enable
        DATA_OUT          : out DATA_TYPE;        --!data to be written to memory
        ADDRESS           : out ADDRESS_TYPE;     --!address to read/write from/to memory
        WORD_LENGTH       : out WORD_CNTRL_TYPE   --!length of the data to be stored
    );
end entity memory_access;


architecture beh of memory_access is

    signal wb_cntrl_cs : WB_CNTRL_TYPE := WB_CNTRL_NOP;
    signal wb_cntrl_ns : WB_CNTRL_TYPE;
    signal di_cs       : DATA_TYPE     := (others => '0');
    signal di_ns       : DATA_TYPE;
    signal pc_cs       : ADDRESS_TYPE  := (others => '0');
    signal pc_ns       : ADDRESS_TYPE;

    signal DATA_IN_s : DATA_TYPE;
begin

    --!@brief load or just pipe data through
    load_mux:
    process(RESU_SYNCH, DATA_IN_s, MA_CNTRL_SYNCH(0)) is
    begin
        if MA_CNTRL_SYNCH(0) = '1' then
            di_ns <= DATA_IN_s;
        else
            di_ns <= RESU_SYNCH;
        end if;
    end process load_mux;
    
    --!@brief Sign extension for loading from memory
    sign_ext:
    process(WORD_CNTRL_SYNCH, SIGN_EN, DATA_IN) is
        variable MIN_SIGN_v : natural;
        variable MSB_index_v: natural;
    begin
        if SIGN_EN = '0' then
            DATA_IN_s <= DATA_IN;
        else
            case WORD_CNTRL_SYNCH is
                when BYTE =>
                    MIN_SIGN_v := 8;
                    MSB_index_v:= 7;
                    
                when HALF =>
                    MIN_SIGN_v := 16;
                    MSB_index_v:= 15;
                when others =>
                    report "Unsupported sign extension format!";
                    MIN_SIGN_v := 32;
                    MSB_index_v:= 31;
            end case;
            -- sign extension
            for i in DATA_WIDTH-1 downto 0 loop
                if i >= MIN_SIGN_v then
                    DATA_IN_s(i) <= DATA_IN(MSB_index_v);
                else
                    DATA_IN_s(i) <= DATA_IN(i);
                end if;
            end loop;
        end if;
    end process sign_ext;
    
    --!@brief manages control signals for memory
    MEM_MUX:
    process(MA_CNTRL_ASYNCH(0), MA_CNTRL_SYNCH(1), RESU_SYNCH, RESU_ASYNCH, WORD_CNTRL_SYNCH, WORD_CNTRL_ASYNCH) is
    
    begin
        if MA_CNTRL_ASYNCH(0) = '1' and MA_CNTRL_SYNCH(1) = '0' then -- load - priority
            ADDRESS  <= RESU_ASYNCH;
            ENABLE   <= '1';
            WRITE_EN <= '0';
            WORD_LENGTH <= WORD_CNTRL_ASYNCH;
        elsif MA_CNTRL_SYNCH(1) = '1' and MA_CNTRL_ASYNCH(0) = '0' then -- store
            ADDRESS  <= RESU_SYNCH;
            ENABLE   <= '1';
            WRITE_EN <= '1';
            WORD_LENGTH <= WORD_CNTRL_SYNCH;
        else -- nothing
            ADDRESS  <= (others => '0');
            ENABLE   <= '0';
            WRITE_EN <= '0';
            WORD_LENGTH <= WORD_CNTRL_SYNCH;
        end if;
    end process MEM_MUX;
    
    sequ_log:
    process(clk) is
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                wb_cntrl_cs <= WB_CNTRL_NOP;
                di_cs       <= (others => '0');
                pc_cs       <= (others => '0');
            else
                wb_cntrl_cs <= wb_cntrl_ns;
                di_cs       <= di_ns;
                pc_cs       <= pc_ns;
            end if;
        end if;
    end process sequ_log;

    DATA_OUT     <= DO;
    
    pc_ns        <= PC_IN;
    PC_OUT       <= pc_cs;
    wb_cntrl_ns  <= WB_CNTRL_IN;
    WB_CNTRL_OUT <= wb_cntrl_cs;
    DI           <= di_cs;
    
end architecture beh;
