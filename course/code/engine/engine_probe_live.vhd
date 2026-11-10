library ieee;
use ieee.std_logic_1164.all;

entity engine_probe is
    port (
        clk : in std_logic
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

    -- This probes liveness-mode integration only, not a realistic progress
    -- guarantee or fairness assumption.
    -- psl default clock is rising_edge(clk);
    -- psl assert_live_engine_smoke: assert always eventually! (state = '1');
end architecture rtl;
