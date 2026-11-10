library ieee;
use ieee.std_logic_1164.all;

entity engine_probe is
    port (
        clk : in std_logic;
        q   : out std_logic
    );
end entity engine_probe;

architecture rtl of engine_probe is
    signal state : std_logic := '0';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            state <= not state;
        end if;
    end process;

    q <= state;

    -- psl default clock is rising_edge(clk);
    -- psl assert_state_toggles: assert always (q -> next(not q));
    -- psl cover_state_high: cover {q};
end architecture rtl;
