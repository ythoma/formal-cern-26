library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seq_detector is
port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    d        : in  std_logic;
    detected : out std_logic
);
end seq_detector;



architecture behave of seq_detector is
    type state_type is (s1, s2, s3, s4);
    signal state: state_type;
    signal n_state: state_type;
begin

    p_comb: process(all)
    begin
        n_state<=state;
        detected<='0';
        case state is
        when s1=>
            if d='1' then
                n_state <= s2;
            end if;
        when s2=>
            if d='1' then
                n_state <= s3;
            else
                n_state <= s1;
            end if;
        when s3=>
            if d='0' then
                n_state <= s4;
            else
                n_state <= s3;
            end if;
        when s4=>
            if d='0' then
                n_state <= s1;
                detected <= '1';
            else
                n_state <= s2;
            end if;
        end case;
    end process;
    
    p_reg: process(rst,clk)
    begin
        if rst = '1' then
            state <= s1;
        elsif rising_edge(clk) then
            state <= n_state;
        end if;
    end process;

end behave;
