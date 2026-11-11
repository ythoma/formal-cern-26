
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity locker is
generic(
    ERRNO : integer := 0
);
port(
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;
    keys_i   : in  std_logic_vector(9 downto 0);
    unlock_o : out std_logic
);
end locker;


architecture behave of locker is
    
    type state_type is (s1, s2, s2b, s3, s3b, s4, s4b, s5);
    signal state: state_type;

    constant NOKEY : std_logic_vector(9 downto 0) := "0000000000";
    constant KEY1 : std_logic_vector(9 downto 0) := "0000000001";
    constant KEY2 : std_logic_vector(9 downto 0) := "0000000010";
    constant KEY3 : std_logic_vector(9 downto 0) := "0000000100";
    constant KEY4 : std_logic_vector(9 downto 0) := "0000001000";
    constant KEY5 : std_logic_vector(9 downto 0) := "0000010000";
    constant STALL : std_logic_vector(9 downto 0) := "0000000000";

begin

    -- ERRNO fault injection (0 is the correct implementation):
    -- 1: unlock after the first key (KEY1 in s1).
    -- 2: unlock after the second key (KEY4 in s2).
    -- 3: unlock after the third key (KEY2 in s3).
    -- 4: unlock while waiting for the final key (NOKEY in s4).
    -- 5: unlock when an incorrect key is entered in s4.
    -- 6: keep asserting unlock while in s5, extending the unlock pulse.
    -- 7: does not unlock.

    process(clk_i, rst_i) is
    begin
        if rst_i = '1' then
            state <= s1;
            unlock_o <= '0';
        elsif rising_edge(clk_i) then
            unlock_o <= '0';
            case state is
            when s1=>
                if keys_i = KEY1 then
                    state <= s2;
                    if ERRNO = 1 then
                        unlock_o <= '1';
                    end if;
                elsif keys_i = NOKEY then
                    state <= s1;
                else
                    state <= s1;
                end if;
            when s2=>
                if keys_i = KEY4 then
                    state <= s3;
                    if ERRNO = 2 then
                        unlock_o <= '1';
                    end if;
                elsif keys_i = KEY1 then
                    state <= s2;
                elsif keys_i = STALL then
                    state <= s2b;
                else
                    state <= s1;
                end if;
            when s2b=>
                if keys_i = KEY4 then
                    state <= s3;
                    if ERRNO = 2 then
                        unlock_o <= '1';
                    end if;
                elsif keys_i = KEY1 then
                    state <= s2b;
                elsif keys_i = STALL then
                    state <= s2b;
                else
                    state <= s1;
                end if;
            when s3=>
                if keys_i = KEY2 then
                    state <= s4;
                    if ERRNO = 3 then
                        unlock_o <= '1';
                    end if;
                elsif keys_i = KEY4 then
                    state <= s3;
                elsif keys_i = KEY1 then
                    state <= s2;
                elsif keys_i = STALL then
                    state <= s3b;
                else
                    state <= s1;
                end if;

            when s3b=>
                if keys_i = KEY2 then
                    state <= s4;
                    if ERRNO = 3 then
                        unlock_o <= '1';
                    end if;
                elsif keys_i = KEY1 then
                    state <= s2;
                elsif keys_i = STALL then
                    state <= s3b;
                else
                    state <= s1;
                end if;

            when s4=>
                    if ERRNO = 4 then
                        unlock_o <= '1';
                    end if;
                if keys_i = KEY3 then
                    state <= s5;
                    if ERRNO /= 7 then
                        unlock_o <= '1';
                    end if;
                elsif keys_i = KEY2 then
                    state <= s4;
                elsif keys_i = KEY1 then
                    state <= s2;
                elsif keys_i = STALL then
                    state <= s4b;
                    if ERRNO = 4 then
                        unlock_o <= '1';
                    end if;
                else
                    state <= s1;
                    if ERRNO = 5 then
                        unlock_o <= '1';
                    end if;
                end if;

            when s4b=>
                if keys_i = KEY3 then
                    state <= s5;
                    if ERRNO /= 7 then
                        unlock_o <= '1';
                    end if;
                    unlock_o <= '1';
                elsif keys_i = KEY1 then
                    state <= s2;
                elsif keys_i = STALL then
                    state <= s4b;
                    if ERRNO = 4 then
                        unlock_o <= '1';
                    end if;
                else
                    state <= s1;
                    if ERRNO = 5 then
                        unlock_o <= '1';
                    end if;
                end if;
            when s5=>
                if ERRNO = 6 then
                    unlock_o <= '1';
                end if;
                if keys_i = KEY1 then
                    state <= s2;
                else
                    state <= s1;
                end if;
            end case;
        end if;
    end process;

end behave;
