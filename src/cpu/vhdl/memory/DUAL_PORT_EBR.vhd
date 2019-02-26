library IEEE;
    use IEEE.std_logic_1164.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;
    
entity DUAL_PORT_32K is
    port(
        -- READ PORT0
        READ0_CLK       : in  std_logic;
        READ0_ADDRESS   : in  std_logic_vector(9 downto 0);
        READ0_PORT      : out std_logic_vector(31 downto 0);
        READ0_EN        : in  std_logic;
        -- READ PORT1
        READ1_CLK       : in  std_logic;
        READ1_ADDRESS   : in  std_logic_vector(9 downto 0);
        READ1_PORT      : out std_logic_vector(31 downto 0);
        READ1_EN        : in  std_logic;
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
        -- READ PORT0
        READ0_CLK       : in  std_logic;
        READ0_ADDRESS   : in  std_logic_vector(8 downto 0);
        READ0_PORT      : out std_logic_vector(31 downto 0);
        READ0_EN        : in  std_logic;
        -- READ PORT1
        READ1_CLK       : in  std_logic;
        READ1_ADDRESS   : in  std_logic_vector(8 downto 0);
        READ1_PORT      : out std_logic_vector(31 downto 0);
        READ1_EN        : in  std_logic;
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
        -- READ PORT0
        READ0_CLK       : in  std_logic;
        READ0_ADDRESS   : in  std_logic_vector(7 downto 0);
        READ0_PORT      : out std_logic_vector(31 downto 0);
        READ0_EN        : in  std_logic;
        -- READ PORT1
        READ1_CLK       : in  std_logic;
        READ1_ADDRESS   : in  std_logic_vector(7 downto 0);
        READ1_PORT      : out std_logic_vector(31 downto 0);
        READ1_EN        : in  std_logic;
        -- WRITE PORT
        WRITE_CLK       : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(7 downto 0);
        WRITE_PORT      : in  std_logic_vector(31 downto 0);
        WRITE_EN        : in  std_logic;
        WRITE_MASK      : in  std_logic_vector(3 downto 0)
    );
end entity DUAL_PORT_8K;

architecture BEH of DUAL_PORT_32K is
    signal  EBRAM00_OUT_MAP,
            EBRAM01_OUT_MAP,
            EBRAM02_OUT_MAP,
            EBRAM03_OUT_MAP,
            EBRAM04_OUT_MAP,
            EBRAM05_OUT_MAP,
            EBRAM06_OUT_MAP,
            EBRAM07_OUT_MAP,
            EBRAM10_OUT_MAP,
            EBRAM11_OUT_MAP,
            EBRAM12_OUT_MAP,
            EBRAM13_OUT_MAP,
            EBRAM14_OUT_MAP,
            EBRAM15_OUT_MAP,
            EBRAM16_OUT_MAP,
            EBRAM17_OUT_MAP
            : std_logic_vector(15 downto 0);
begin

    

    READ0_PORT <= EBRAM07_OUT_MAP(13) & EBRAM07_OUT_MAP(9) & EBRAM07_OUT_MAP(5) & EBRAM07_OUT_MAP(1)
                & EBRAM06_OUT_MAP(13) & EBRAM06_OUT_MAP(9) & EBRAM06_OUT_MAP(5) & EBRAM06_OUT_MAP(1)
                & EBRAM05_OUT_MAP(13) & EBRAM05_OUT_MAP(9) & EBRAM05_OUT_MAP(5) & EBRAM05_OUT_MAP(1)
                & EBRAM04_OUT_MAP(13) & EBRAM04_OUT_MAP(9) & EBRAM04_OUT_MAP(5) & EBRAM04_OUT_MAP(1)
                & EBRAM03_OUT_MAP(13) & EBRAM03_OUT_MAP(9) & EBRAM03_OUT_MAP(5) & EBRAM03_OUT_MAP(1)
                & EBRAM02_OUT_MAP(13) & EBRAM02_OUT_MAP(9) & EBRAM02_OUT_MAP(5) & EBRAM02_OUT_MAP(1)
                & EBRAM01_OUT_MAP(13) & EBRAM01_OUT_MAP(9) & EBRAM01_OUT_MAP(5) & EBRAM01_OUT_MAP(1)
                & EBRAM00_OUT_MAP(13) & EBRAM00_OUT_MAP(9) & EBRAM00_OUT_MAP(5) & EBRAM00_OUT_MAP(1);
                
    READ1_PORT <= EBRAM17_OUT_MAP(13) & EBRAM17_OUT_MAP(9) & EBRAM17_OUT_MAP(5) & EBRAM17_OUT_MAP(1)
                & EBRAM16_OUT_MAP(13) & EBRAM16_OUT_MAP(9) & EBRAM16_OUT_MAP(5) & EBRAM16_OUT_MAP(1)
                & EBRAM15_OUT_MAP(13) & EBRAM15_OUT_MAP(9) & EBRAM15_OUT_MAP(5) & EBRAM15_OUT_MAP(1)
                & EBRAM14_OUT_MAP(13) & EBRAM14_OUT_MAP(9) & EBRAM14_OUT_MAP(5) & EBRAM14_OUT_MAP(1)
                & EBRAM13_OUT_MAP(13) & EBRAM13_OUT_MAP(9) & EBRAM13_OUT_MAP(5) & EBRAM13_OUT_MAP(1)
                & EBRAM12_OUT_MAP(13) & EBRAM12_OUT_MAP(9) & EBRAM12_OUT_MAP(5) & EBRAM12_OUT_MAP(1)
                & EBRAM11_OUT_MAP(13) & EBRAM11_OUT_MAP(9) & EBRAM11_OUT_MAP(5) & EBRAM11_OUT_MAP(1)
                & EBRAM10_OUT_MAP(13) & EBRAM10_OUT_MAP(9) & EBRAM10_OUT_MAP(5) & EBRAM10_OUT_MAP(1);

    EBR00 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(3), 9 => WRITE_PORT(2), 5 => WRITE_PORT(1), 1 => WRITE_PORT(0), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM00_OUT_MAP
    );
    
    EBR01 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(7), 9 => WRITE_PORT(6), 5 => WRITE_PORT(5), 1 => WRITE_PORT(4), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM01_OUT_MAP
    );
    
    EBR02 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(11), 9 => WRITE_PORT(10), 5 => WRITE_PORT(9), 1 => WRITE_PORT(8), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM02_OUT_MAP
    );
    
    EBR03 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(15), 9 => WRITE_PORT(14), 5 => WRITE_PORT(13), 1 => WRITE_PORT(12), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM03_OUT_MAP
    );
    
    EBR04 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(19), 9 => WRITE_PORT(18), 5 => WRITE_PORT(17), 1 => WRITE_PORT(16), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM04_OUT_MAP
    );
    
    EBR05 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(23), 9 => WRITE_PORT(22), 5 => WRITE_PORT(21), 1 => WRITE_PORT(20), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM05_OUT_MAP
    );
    
    EBR06 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(27), 9 => WRITE_PORT(26), 5 => WRITE_PORT(25), 1 => WRITE_PORT(24), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM06_OUT_MAP
    );
    
    EBR07 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(31), 9 => WRITE_PORT(30), 5 => WRITE_PORT(29), 1 => WRITE_PORT(28), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ0_EN,
        WE  => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM07_OUT_MAP
    );
    
    -------------------------
    
    EBR10 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(3), 9 => WRITE_PORT(2), 5 => WRITE_PORT(1), 1 => WRITE_PORT(0), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM10_OUT_MAP
    );
    
    EBR11 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(7), 9 => WRITE_PORT(6), 5 => WRITE_PORT(5), 1 => WRITE_PORT(4), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM11_OUT_MAP
    );
    
    EBR12 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(11), 9 => WRITE_PORT(10), 5 => WRITE_PORT(9), 1 => WRITE_PORT(8), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM12_OUT_MAP
    );
    
    EBR13 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(15), 9 => WRITE_PORT(14), 5 => WRITE_PORT(13), 1 => WRITE_PORT(12), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM13_OUT_MAP
    );
    
    EBR14 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(19), 9 => WRITE_PORT(18), 5 => WRITE_PORT(17), 1 => WRITE_PORT(16), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM14_OUT_MAP
    );
    
    EBR15 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(23), 9 => WRITE_PORT(22), 5 => WRITE_PORT(21), 1 => WRITE_PORT(20), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM15_OUT_MAP
    );
    
    EBR16 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(27), 9 => WRITE_PORT(26), 5 => WRITE_PORT(25), 1 => WRITE_PORT(24), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM16_OUT_MAP
    );
    
    EBR17 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => WRITE_PORT(31), 9 => WRITE_PORT(30), 5 => WRITE_PORT(29), 1 => WRITE_PORT(28), others => '0'),
        ADW => '0' & WRITE_ADDRESS,
        ADR => '0' & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE  => READ1_EN,
        WE  => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM17_OUT_MAP
    );
    
end architecture BEH;

architecture BEH of DUAL_PORT_16K is
    signal  EBRAM00_OUT_MAP,
            EBRAM01_OUT_MAP,
            EBRAM02_OUT_MAP,
            EBRAM03_OUT_MAP,
            EBRAM10_OUT_MAP,
            EBRAM11_OUT_MAP,
            EBRAM12_OUT_MAP,
            EBRAM13_OUT_MAP
            : std_logic_vector(15 downto 0);
begin
    
    READ0_PORT <= EBRAM03_OUT_MAP(14) & EBRAM03_OUT_MAP(12) & EBRAM03_OUT_MAP(10) & EBRAM03_OUT_MAP( 8)
                & EBRAM03_OUT_MAP( 6) & EBRAM03_OUT_MAP( 4) & EBRAM03_OUT_MAP( 2) & EBRAM03_OUT_MAP( 0)
                & EBRAM02_OUT_MAP(14) & EBRAM02_OUT_MAP(12) & EBRAM02_OUT_MAP(10) & EBRAM02_OUT_MAP( 8)
                & EBRAM02_OUT_MAP( 6) & EBRAM02_OUT_MAP( 4) & EBRAM02_OUT_MAP( 2) & EBRAM02_OUT_MAP( 0)
                & EBRAM01_OUT_MAP(14) & EBRAM01_OUT_MAP(12) & EBRAM01_OUT_MAP(10) & EBRAM01_OUT_MAP( 8)
                & EBRAM01_OUT_MAP( 6) & EBRAM01_OUT_MAP( 4) & EBRAM01_OUT_MAP( 2) & EBRAM01_OUT_MAP( 0)
                & EBRAM00_OUT_MAP(14) & EBRAM00_OUT_MAP(12) & EBRAM00_OUT_MAP(10) & EBRAM00_OUT_MAP( 8)
                & EBRAM00_OUT_MAP( 6) & EBRAM00_OUT_MAP( 4) & EBRAM00_OUT_MAP( 2) & EBRAM00_OUT_MAP( 0);
                
    READ1_PORT <= EBRAM13_OUT_MAP(14) & EBRAM13_OUT_MAP(12) & EBRAM13_OUT_MAP(10) & EBRAM13_OUT_MAP( 8)
                & EBRAM13_OUT_MAP( 6) & EBRAM13_OUT_MAP( 4) & EBRAM13_OUT_MAP( 2) & EBRAM13_OUT_MAP( 0)
                & EBRAM12_OUT_MAP(14) & EBRAM12_OUT_MAP(12) & EBRAM12_OUT_MAP(10) & EBRAM12_OUT_MAP( 8)
                & EBRAM12_OUT_MAP( 6) & EBRAM12_OUT_MAP( 4) & EBRAM12_OUT_MAP( 2) & EBRAM12_OUT_MAP( 0)
                & EBRAM11_OUT_MAP(14) & EBRAM11_OUT_MAP(12) & EBRAM11_OUT_MAP(10) & EBRAM11_OUT_MAP( 8)
                & EBRAM11_OUT_MAP( 6) & EBRAM11_OUT_MAP( 4) & EBRAM11_OUT_MAP( 2) & EBRAM11_OUT_MAP( 0)
                & EBRAM10_OUT_MAP(14) & EBRAM10_OUT_MAP(12) & EBRAM10_OUT_MAP(10) & EBRAM10_OUT_MAP( 8)
                & EBRAM10_OUT_MAP( 6) & EBRAM10_OUT_MAP( 4) & EBRAM10_OUT_MAP( 2) & EBRAM10_OUT_MAP( 0);
    
    EBR00 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(7), 12 => WRITE_PORT(6), 10 => WRITE_PORT(5),  8 => WRITE_PORT(4),
                6 => WRITE_PORT(3),  4 => WRITE_PORT(2),  2 => WRITE_PORT(1),  0 => WRITE_PORT(0),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE => READ0_EN,
        WE => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM00_OUT_MAP
    );
    
    EBR01 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(15), 12 => WRITE_PORT(14), 10 => WRITE_PORT(13),  8 => WRITE_PORT(12),
                6 => WRITE_PORT(11),  4 => WRITE_PORT(10),  2 => WRITE_PORT(9),  0 => WRITE_PORT(8),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE => READ0_EN,
        WE => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM01_OUT_MAP
    );
    
    EBR02 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(23), 12 => WRITE_PORT(22), 10 => WRITE_PORT(21),  8 => WRITE_PORT(20),
                6 => WRITE_PORT(19),  4 => WRITE_PORT(18),  2 => WRITE_PORT(17),  0 => WRITE_PORT(16),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE => READ0_EN,
        WE => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM02_OUT_MAP
    );
    
    EBR03 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(31), 12 => WRITE_PORT(30), 10 => WRITE_PORT(29),  8 => WRITE_PORT(28),
                6 => WRITE_PORT(27),  4 => WRITE_PORT(26),  2 => WRITE_PORT(25),  0 => WRITE_PORT(24),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE => READ0_EN,
        WE => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM03_OUT_MAP
    );
    
    -------------------------
    
    EBR10 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(7), 12 => WRITE_PORT(6), 10 => WRITE_PORT(5),  8 => WRITE_PORT(4),
                6 => WRITE_PORT(3),  4 => WRITE_PORT(2),  2 => WRITE_PORT(1),  0 => WRITE_PORT(0),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE => READ1_EN,
        WE => WRITE_EN and WRITE_MASK(0),
        MASK_N => x"0000",
        DO => EBRAM10_OUT_MAP
    );
    
    EBR11 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(15), 12 => WRITE_PORT(14), 10 => WRITE_PORT(13),  8 => WRITE_PORT(12),
                6 => WRITE_PORT(11),  4 => WRITE_PORT(10),  2 => WRITE_PORT(9),  0 => WRITE_PORT(8),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE => READ1_EN,
        WE => WRITE_EN and WRITE_MASK(1),
        MASK_N => x"0000",
        DO => EBRAM11_OUT_MAP
    );
    
    EBR12 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(23), 12 => WRITE_PORT(22), 10 => WRITE_PORT(21),  8 => WRITE_PORT(20),
                6 => WRITE_PORT(19),  4 => WRITE_PORT(18),  2 => WRITE_PORT(17),  0 => WRITE_PORT(16),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE => READ1_EN,
        WE => WRITE_EN and WRITE_MASK(2),
        MASK_N => x"0000",
        DO => EBRAM12_OUT_MAP
    );
    
    EBR13 : PDP4K
    generic map(
        DATA_WIDTH_W => "8",
        DATA_WIDTH_R => "8"
    )
    port map(
        DI => (14 => WRITE_PORT(31), 12 => WRITE_PORT(30), 10 => WRITE_PORT(29),  8 => WRITE_PORT(28),
                6 => WRITE_PORT(27),  4 => WRITE_PORT(26),  2 => WRITE_PORT(25),  0 => WRITE_PORT(24),
                others => '0'),
        ADW => "00" & WRITE_ADDRESS,
        ADR => "00" & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE => READ1_EN,
        WE => WRITE_EN and WRITE_MASK(3),
        MASK_N => x"0000",
        DO => EBRAM13_OUT_MAP
    );
    
end architecture BEH;

architecture BEH of DUAL_PORT_8K is
begin

    EBR00 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(15 downto 0),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE => READ0_EN,
        WE => WRITE_EN,
        MASK_N => (15 downto 8 => not WRITE_MASK(1), 7 downto 0 => not WRITE_MASK(0)),
        DO => READ0_PORT(15 downto 0)
    );
    
    EBR01 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(31 downto 16),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ0_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ0_CLK,
        CEW => '1',
        CER => '1',
        RE => READ0_EN,
        WE => WRITE_EN,
        MASK_N => (15 downto 8 => not WRITE_MASK(3), 7 downto 0 => not WRITE_MASK(2)),
        DO => READ0_PORT(31 downto 16)
    );
    
    ----------------------------------
    
    EBR10 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(15 downto 0),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE => READ1_EN,
        WE => WRITE_EN,
        MASK_N => (15 downto 8 => not WRITE_MASK(1), 7 downto 0 => not WRITE_MASK(0)),
        DO => READ1_PORT(15 downto 0)
    );
    
    EBR11 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(31 downto 16),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ1_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ1_CLK,
        CEW => '1',
        CER => '1',
        RE => READ1_EN,
        WE => WRITE_EN,
        MASK_N => (15 downto 8 => not WRITE_MASK(3), 7 downto 0 => not WRITE_MASK(2)),
        DO => READ1_PORT(31 downto 16)
    );

end architecture BEH;