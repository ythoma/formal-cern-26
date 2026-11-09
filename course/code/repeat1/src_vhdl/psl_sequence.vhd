library ieee;
use ieee.std_logic_1164.all;

entity psl_sequence is
    port (
        clk : in std_logic
    );
end entity psl_sequence;


architecture psl of psl_sequence is

    signal a, b : std_logic;

begin

    -- All is sensitive to rising edge of clk
    default clock is rising_edge(clk);

    --                                          0123456789
    seq_a : entity work.sequencer generic map ("_-____-_____") port map (clk, a);
    seq_b : entity work.sequencer generic map ("___---__---_") port map (clk, b);

    assert_success1: assert always (a |-> {[*2];b});
    assert_success2: assert always (a |-> {[*2];b[*3]});

    -- {Sequence}(FL_property) is equivalent to Sequence |-> FL_Property
    assert_success3: assert always ({a}({[*2];b[*3]}));

end architecture psl;
