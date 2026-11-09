library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.iop_pkg.all;

entity axis_upscaler is
    generic (
        DATA_IN_WIDTH  : integer := 32;
        DATA_OUT_WIDTH : integer := 128;
        -- ERRNO = 0: correct behavior. Values 1..6 inject the documented faults.
        ERRNO          : integer := 0
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        -- AXIS Input
        s_axis_tdata : in std_logic_vector(DATA_IN_WIDTH-1 downto 0);
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;
        s_axis_tlast : in std_logic;
        -- AXIS Output
        m_axis_tdata : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tready : in std_logic;
        m_axis_tlast : out std_logic
    ) ;
end axis_upscaler;

architecture rtl of axis_upscaler is

    type axis_state_t is (FILL, DELIVER);

    constant UPSCALE_FACTOR : integer := DATA_OUT_WIDTH/DATA_IN_WIDTH;

    type reg_t is record
        state : axis_state_t;
        wr_idx : unsigned(ilogup(UPSCALE_FACTOR) downto 0);
        tlast_mem : std_logic;
    end record;

    signal reg_sn, reg_sp: reg_t;

    constant reg_ZERO : reg_t := (
        FILL,
        to_unsigned(0, UPSCALE_FACTOR-1),
        '0'
    );
    
    type aggregator_t is array (0 to UPSCALE_FACTOR-1) of std_logic_vector(DATA_IN_WIDTH-1 downto 0);
    
    signal aggregator_s : aggregator_t;
    
    signal wr_s: std_logic;
    signal pad_s: std_logic;

begin

    assert (DATA_OUT_WIDTH mod DATA_IN_WIDTH) = 0
        report "Output data width must be an integer factor of Input data width"
        severity failure;

    process (all)
    variable reg_v : reg_t;
    begin
        reg_v := reg_sp;

        --default values
        wr_s <= '0';
        m_axis_tvalid <= '0';
        s_axis_tready <= '0';
        pad_s <= '0';

        case reg_v.state is
            when FILL => 
                s_axis_tready <= '1';
                if s_axis_tvalid = '1' then
                    wr_s <= '1';
                    reg_v.tlast_mem := s_axis_tlast;
                    -- ERRNO = 3: discard the input end-of-frame marker.
                    if ERRNO = 3 then
                        reg_v.tlast_mem := '0';
                    end if;
                    reg_v.wr_idx := reg_v.wr_idx + 1;
                    -- ERRNO = 1: emit a packed word one input transfer too early.
                    if ((ERRNO = 1) and (reg_v.wr_idx = UPSCALE_FACTOR - 1)) or
                       ((ERRNO /= 1) and (reg_v.wr_idx = UPSCALE_FACTOR)) then
                        reg_v.wr_idx := to_unsigned(0, reg_v.wr_idx'length);
                        reg_v.state := DELIVER;
                    elsif s_axis_tlast = '1' then
                        reg_v.wr_idx := to_unsigned(0, reg_v.wr_idx'length);
                        -- ERRNO = 2: omit zero-padding on a short final word.
                        if ERRNO /= 2 then
                            pad_s <= '1';
                        end if;
                        reg_v.state := DELIVER;                      
                    end if;
                end if;
                
            when DELIVER =>
                -- ERRNO = 4: valid incorrectly drops during output backpressure.
                if ERRNO = 4 then
                    m_axis_tvalid <= m_axis_tready;
                else
                    m_axis_tvalid <= '1';
                end if;
                -- ERRNO = 5: claim input readiness even when the output is blocked.
                if ERRNO = 5 then
                    s_axis_tready <= '1';
                else
                    s_axis_tready <= m_axis_tready;
                end if;
                if m_axis_tready = '1' then
                    if s_axis_tvalid = '1' then
                        reg_v.tlast_mem := s_axis_tlast;
                        -- ERRNO = 3: discard the input end-of-frame marker.
                        if ERRNO = 3 then
                            reg_v.tlast_mem := '0';
                        end if;
                        wr_s <= '1';
                        if s_axis_tlast = '1' then
                            -- ERRNO = 2: omit zero-padding on a short final word.
                            if ERRNO /= 2 then
                                pad_s <= '1';
                            end if;
                            reg_v.wr_idx := to_unsigned(0, reg_v.wr_idx'length);
                        else
                            reg_v.wr_idx := reg_v.wr_idx + 1;
                            reg_v.state := FILL;
                        end if;
                    else
                        reg_v.state := FILL;
                    end if;
                end if;
            when others =>
                null;
        end case;
        
        reg_sn <= reg_v;
    end process;

    process (clk, rst)
    begin
        if rst = '1' then
            reg_sp <= reg_ZERO;
            aggregator_s <= (others => (others => '0'));
        elsif rising_edge(clk) then
            reg_sp <= reg_sn;
            if wr_s = '1' then
                aggregator_s(to_integer(reg_sp.wr_idx)) <= s_axis_tdata;
            end if; 
            if pad_s = '1' then
                for i in 0 to UPSCALE_FACTOR-1 loop
                    if i > reg_sp.wr_idx then
                        aggregator_s(i) <= (others => '0');
                    end if;
                end loop;
            end if;
        end if;
    end process;

    output_aggregator : for i in 0 to UPSCALE_FACTOR-1 generate
        -- ERRNO = 6: reverse the order of the packed input words.
        m_axis_tdata(((i+1) * DATA_IN_WIDTH)-1 downto (i * DATA_IN_WIDTH)) <=
            aggregator_s(UPSCALE_FACTOR-1-i) when ERRNO = 6 else aggregator_s(i);
    end generate;

    m_axis_tlast <= reg_sp.tlast_mem;

end rtl ; -- rtl
