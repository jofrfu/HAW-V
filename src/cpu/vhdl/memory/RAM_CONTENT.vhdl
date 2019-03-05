library IEEE;
    use IEEE.std_logic_1164.all;
    
package RAM_CONTENT is
    --! @brief Used for iCE40up5k Block RAM initialization 
    type MEMORY_TYPE is array(natural range <>) of std_logic_vector(7 downto 0);
    
    constant INSTRUCTION_EBRAM : MEMORY_TYPE(0 to 4*2**11-1) :=  (x"97", x"25", x"00", x"00",
                                                                x"93", x"85", x"05", x"00",
                                                                x"83", x"A5", x"05", x"00",
                                                                x"13", x"06", x"10", x"00",
                                                                x"13", x"16", x"F6", x"01",
                                                                x"93", x"06", x"16", x"00",
                                                                x"23", x"00", x"06", x"00",
                                                                x"13", x"07", x"10", x"00",
                                                                x"93", x"07", x"00", x"00",
                                                                x"13", x"08", x"80", x"00",
                                                                x"93", x"87", x"17", x"00",
                                                                x"63", x"F4", x"B7", x"00",
                                                                x"6F", x"F0", x"9F", x"FF",
                                                                x"23", x"80", x"E6", x"00",
                                                                x"13", x"17", x"17", x"00",
                                                                x"93", x"07", x"00", x"00",
                                                                x"63", x"44", x"E8", x"00",
                                                                x"6F", x"F0", x"5F", x"FE",
                                                                x"13", x"07", x"10", x"00",
                                                                x"6F", x"F0", x"DF", x"FD",
                                                                others => (others => '0'));
    constant DATA_EBRAM : MEMORY_TYPE(0 to 4*2**10-1) :=         (x"60", x"EA", x"00", x"00",
                                                                others => (others => '0'));
end package RAM_CONTENT;