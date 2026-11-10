library ieee;
use ieee.std_logic_1164.all;

entity blackbox_sequencer is
    generic (
        ERRNO : integer := 0
    );
    port (
        clk : in  std_logic;
        a   : out std_logic;
        b   : out std_logic;
        c   : out std_logic;
        d   : out std_logic;
        e   : out std_logic;
        f   : out std_logic
    );
end entity blackbox_sequencer;


architecture struct of blackbox_sequencer is

begin

gennot2 : if ERRNO = 3 generate
    --                                          01234567890123
    seq_a : entity work.sequencer generic map ("_-____-_______") port map (clk, a);
end generate;

gen2 : if ERRNO = 0 or ERRNO = 1 or ERRNO = 2 generate
    --                                          01234567890123
    seq_a : entity work.sequencer generic map ("__-____-______") port map (clk, a);
end generate;

gen1 : if ERRNO = 1 generate
    --                                          01234567890123
    seq_f : entity work.sequencer generic map ("__-____-______") port map (clk, f);
end generate;

gennot1 : if ERRNO /= 1 generate
    --                                          01234567890123
    seq_f : entity work.sequencer generic map ("_--___--______") port map (clk, f);
end generate;

gen0 : if ERRNO = 0 or ERRNO = 1 generate
    --                                          01234567890123
    seq_b : entity work.sequencer generic map ("____-_-__-_-__") port map (clk, b);
end generate;

gennot0 : if ERRNO = 2 or ERRNO = 3 generate
    --                                          01234567890123
    seq_b : entity work.sequencer generic map ("____---__---__") port map (clk, b);
end generate;

    --                                          01234567890123
    seq_c : entity work.sequencer generic map ("__--___--_____") port map (clk, c);
    seq_d : entity work.sequencer generic map ("__-_-__-_-____") port map (clk, d);
    seq_e : entity work.sequencer generic map ("___-____-_____") port map (clk, e);


end architecture struct;
