library ieee;
use ieee.std_logic_1164.all;

entity blackbox_sequencer is
    generic (
        ERRNO : positive := 1
    );
    port (
        clk : in  std_logic;
        a   : out std_logic;
        b   : out std_logic;
        c   : out std_logic;
        d   : out std_logic;
        e   : out std_logic
    );
end entity blackbox_sequencer;


architecture struct of blackbox_sequencer is

begin

gen0 : if ERRNO = 0 generate
    --                                          01234567890123
    seq_a : entity work.sequencer generic map ("__-____-______") port map (clk, a);
else
    --                                          01234567890123
    seq_a : entity work.sequencer generic map ("_-____-_______") port map (clk, a);
end generate;

    --                                          01234567890123
    seq_b : entity work.sequencer generic map ("____---__---__") port map (clk, b);
    seq_c : entity work.sequencer generic map ("__--___--_____") port map (clk, c);
    seq_d : entity work.sequencer generic map ("__-_-__-_-____") port map (clk, d);
    seq_e : entity work.sequencer generic map ("___-____-_____") port map (clk, e);


end architecture struct;
