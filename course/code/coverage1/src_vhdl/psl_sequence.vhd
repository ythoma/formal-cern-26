library ieee;
use ieee.std_logic_1164.all;

entity psl_sequence is
    generic (
        EXPECT_FAIL : boolean := false
    );
    port (
        clk : in std_logic
    );
end entity psl_sequence;

architecture psl of psl_sequence is

    signal a, b, c: std_logic;

begin

    -- All is sensitive to rising edge of clk
    default clock is rising_edge(clk);


    --                                          012345678901
    seq_a : entity work.sequencer generic map ("_-___-__--__") port map (clk, a);
    seq_b : entity work.sequencer generic map ("_-_-_-__--__") port map (clk, b);
    seq_c : entity work.sequencer generic map ("__--_---_--_") port map (clk, c);

    assert_sequence_cover: assert always ({a;c} |=> {c});
    cover_success: cover {a and b};
    -- This type of assertion is not part of coverage, as it is not a sequence, but a simple implication
    assert_success1_nocover: assert always (a -> b);

    -- The same, but as a temporary sequence, so it is part of coverage
    assert_success2_cover: assert always (b |-> a);

    assert_success3_cover: assert always ({a} |-> {b});

    gen_fail : if EXPECT_FAIL generate
        assert_fail: assert always (b -> a);

        cover_fail: cover {a;a;b};
        assert_sequence_cover_fail: assert always ({a;a;b} |=> {c});
    end generate;

end architecture psl;
