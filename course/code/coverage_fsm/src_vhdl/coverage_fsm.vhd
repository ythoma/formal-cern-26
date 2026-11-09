library ieee;
use ieee.std_logic_1164.all;

entity coverage_fsm is
    port (
        clk : in  std_logic;
        d   : in  std_logic;
        y   : out std_logic
    );
end entity coverage_fsm;

architecture rtl of coverage_fsm is
    type state_t is (s1, s2, s3, s4);
    signal state : state_t := s1;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            case state is
                when s1 =>
                    if d = '1' then
                        state <= s1;
                    else
                        state <= s2;
                    end if;
                when s2 =>
                    if d = '1' then
                        state <= s3;
                    else
                        state <= s2;
                    end if;
                when s3 =>
                    if d = '1' then
                        state <= s4;
                    else
                        state <= s2;
                    end if;
                when s4 =>
                    state <= s1;
            end case;
        end if;
    end process;

    -- Moore output: only s4 asserts y.
    y <= '1' when state = s4 else '0';

    -- All transition coverage properties sample state on rising clock edges.
    default clock is rising_edge(clk);

    cover_s1_to_s1: cover {state = s1; state = s1};
    cover_s1_to_s2: cover {state = s1; state = s2};
    cover_s2_to_s2: cover {state = s2; state = s2};
    cover_s2_to_s3: cover {state = s2; state = s3};
    cover_s3_to_s2: cover {state = s3; state = s2};
    cover_s3_to_s4: cover {state = s3; state = s4};
    cover_s4_to_s1: cover {state = s4; state = s1};
end architecture rtl;
