library IEEE;
    use IEEE.std_logic_1164.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;
    
entity DUAL_PORT_32K is
    port(
        -- READ PORT
        READ_CLK        : in  std_logic;
        READ_ADDRESS    : in  std_logic_vector(9 downto 0);
        READ_PORT       : out std_logic_vector(31 downto 0);
        READ_EN         : in  std_logic;
        -- WRITE PORT
        WRITE_CLK       : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(9 downto 0);
        WRITE_PORT      : in  std_logic_vector(31 downto 0);
        WRITE_EN        : in  std_logic;
        WRITE_MASK      : in  std_logic_vector(3 downto 0)
    );
end entity DUAL_PORT_32K;

library IEEE;
    use IEEE.std_logic_1164.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;

entity DUAL_PORT_16K is
    port(
        -- READ PORT
        READ_CLK        : in  std_logic;
        READ_ADDRESS    : in  std_logic_vector(8 downto 0);
        READ_PORT       : out std_logic_vector(31 downto 0);
        READ_EN         : in  std_logic;
        -- WRITE PORT
        WRITE_CLK       : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(8 downto 0);
        WRITE_PORT      : in  std_logic_vector(31 downto 0);
        WRITE_EN        : in  std_logic;
        WRITE_MASK      : in  std_logic_vector(3 downto 0)
    );
end entity DUAL_PORT_16K;

library IEEE;
    use IEEE.std_logic_1164.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;

entity DUAL_PORT_8K is
    port(
        -- READ PORT
        READ_CLK        : in  std_logic;
        READ_ADDRESS    : in  std_logic_vector(7 downto 0);
        READ_PORT       : out std_logic_vector(31 downto 0);
        READ_EN         : in  std_logic;
        -- WRITE PORT
        WRITE_CLK       : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(7 downto 0);
        WRITE_PORT      : in  std_logic_vector(31 downto 0);
        WRITE_EN        : in  std_logic;
        WRITE_MASK      : in  std_logic_vector(3 downto 0)
    );
end entity DUAL_PORT_8K;

architecture BEH of DUAL_PORT_32K is
    signal  EBRAM0_OUT_MAP,
            EBRAM1_OUT_MAP,
            EBRAM2_OUT_MAP,
            EBRAM3_OUT_MAP,
            EBRAM4_OUT_MAP,
            EBRAM5_OUT_MAP,
            EBRAM6_OUT_MAP,
            EBRAM7_OUT_MAP
            : std_logic_vector(15 downto 0);
begin

    READ_PORT <= EBRAM7_OUT_MAP(13) & EBRAM7_OUT_MAP(9) & EBRAM7_OUT_MAP(5) & EBRAM7_OUT_MAP(1)
               & EBRAM6_OUT_MAP(13) & EBRAM6_OUT_MAP(9) & EBRAM6_OUT_MAP(5) & EBRAM6_OUT_MAP(1)
               & EBRAM5_OUT_MAP(13) & EBRAM5_OUT_MAP(9) & EBRAM5_OUT_MAP(5) & EBRAM5_OUT_MAP(1)
               & EBRAM4_OUT_MAP(13) & EBRAM4_OUT_MAP(9) & EBRAM4_OUT_MAP(5) & EBRAM4_OUT_MAP(1)
               & EBRAM3_OUT_MAP(13) & EBRAM3_OUT_MAP(9) & EBRAM3_OUT_MAP(5) & EBRAM3_OUT_MAP(1)
               & EBRAM2_OUT_MAP(13) & EBRAM2_OUT_MAP(9) & EBRAM2_OUT_MAP(5) & EBRAM2_OUT_MAP(1)
               & EBRAM1_OUT_MAP(13) & EBRAM1_OUT_MAP(9) & EBRAM1_OUT_MAP(5) & EBRAM1_OUT_MAP(1)
               & EBRAM0_OUT_MAP(13) & EBRAM0_OUT_MAP(9) & EBRAM0_OUT_MAP(5) & EBRAM0_OUT_MAP(1);

    EBR0 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(3), 9 => WRITE_PORT(2), 5 => WRITE_PORT(1), 1 => WRITE_PORT(0), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM0_OUT_MAP
    );
    
    EBR1 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(7), 9 => WRITE_PORT(6), 5 => WRITE_PORT(5), 1 => WRITE_PORT(4), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM1_OUT_MAP
    );
    
    EBR2 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(11), 9 => WRITE_PORT(10), 5 => WRITE_PORT(9), 1 => WRITE_PORT(8), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM2_OUT_MAP
    );
    
    EBR3 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(15), 9 => WRITE_PORT(14), 5 => WRITE_PORT(13), 1 => WRITE_PORT(12), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM3_OUT_MAP
    );
    
    EBR4 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(19), 9 => WRITE_PORT(18), 5 => WRITE_PORT(17), 1 => WRITE_PORT(16), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM4_OUT_MAP
    );
    
    EBR5 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(23), 9 => WRITE_PORT(22), 5 => WRITE_PORT(21), 1 => WRITE_PORT(20), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM5_OUT_MAP
    );
    
    EBR6 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(27), 9 => WRITE_PORT(26), 5 => WRITE_PORT(25), 1 => WRITE_PORT(24), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM6_OUT_MAP
    );
    
    EBR7 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(31), 9 => WRITE_PORT(30), 5 => WRITE_PORT(29), 1 => WRITE_PORT(28), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ_EN,
        WE  => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM7_OUT_MAP
    );
end architecture BEH;

architecture BEH of DUAL_PORT_16K is
    signal  EBRAM0_OUT_MAP,
            EBRAM1_OUT_MAP,
            EBRAM2_OUT_MAP,
            EBRAM3_OUT_MAP
            : std_logic_vector(15 downto 0);
begin
    
    READ_PORT <= EBRAM3_OUT_MAP(14) & EBRAM3_OUT_MAP(12) & EBRAM3_OUT_MAP(10) & EBRAM3_OUT_MAP( 8)
               & EBRAM3_OUT_MAP( 6) & EBRAM3_OUT_MAP( 4) & EBRAM3_OUT_MAP( 2) & EBRAM3_OUT_MAP( 0)
               & EBRAM2_OUT_MAP(14) & EBRAM2_OUT_MAP(12) & EBRAM2_OUT_MAP(10) & EBRAM2_OUT_MAP( 8)
               & EBRAM2_OUT_MAP( 6) & EBRAM2_OUT_MAP( 4) & EBRAM2_OUT_MAP( 2) & EBRAM2_OUT_MAP( 0)
               & EBRAM1_OUT_MAP(14) & EBRAM1_OUT_MAP(12) & EBRAM1_OUT_MAP(10) & EBRAM1_OUT_MAP( 8)
               & EBRAM1_OUT_MAP( 6) & EBRAM1_OUT_MAP( 4) & EBRAM1_OUT_MAP( 2) & EBRAM1_OUT_MAP( 0)
               & EBRAM0_OUT_MAP(14) & EBRAM0_OUT_MAP(12) & EBRAM0_OUT_MAP(10) & EBRAM0_OUT_MAP( 8)
               & EBRAM0_OUT_MAP( 6) & EBRAM0_OUT_MAP( 4) & EBRAM0_OUT_MAP( 2) & EBRAM0_OUT_MAP( 0);
    
    EBR0 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(7), 12 => WRITE_PORT(6), 10 => WRITE_PORT(5),  8 => WRITE_PORT(4),
                6 => WRITE_PORT(3),  4 => WRITE_PORT(2),  2 => WRITE_PORT(1),  0 => WRITE_PORT(0),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM0_OUT_MAP
    );
    
    EBR1 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(15), 12 => WRITE_PORT(14), 10 => WRITE_PORT(13),  8 => WRITE_PORT(12),
                6 => WRITE_PORT(11),  4 => WRITE_PORT(10),  2 => WRITE_PORT(9),  0 => WRITE_PORT(8),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM1_OUT_MAP
    );
    
    EBR2 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(23), 12 => WRITE_PORT(22), 10 => WRITE_PORT(21),  8 => WRITE_PORT(20),
                6 => WRITE_PORT(19),  4 => WRITE_PORT(18),  2 => WRITE_PORT(17),  0 => WRITE_PORT(16),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM2_OUT_MAP
    );
    
    EBR3 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(31), 12 => WRITE_PORT(30), 10 => WRITE_PORT(29),  8 => WRITE_PORT(28),
                6 => WRITE_PORT(27),  4 => WRITE_PORT(26),  2 => WRITE_PORT(25),  0 => WRITE_PORT(24),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM3_OUT_MAP
    );
end architecture BEH;

architecture BEH of DUAL_PORT_8K is
begin

    EBR0 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(15 downto 0),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and (WRITE_MASK(1) or WRITE_MASK(0)),
        MASK_N => (15 downto 8 => not WRITE_MASK(1), 7 downto 0 => not WRITE_MASK(0)),
        DO => READ_PORT(15 downto 0)
    );
    
    EBR1 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(31 downto 16),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and (WRITE_MASK(3) or WRITE_MASK(2)),
        MASK_N => (15 downto 8 => not WRITE_MASK(3), 7 downto 0 => not WRITE_MASK(2)),
        DO => READ_PORT(31 downto 16)
    );
end architecture BEH;