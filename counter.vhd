library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port(
        clk:        in std_logic;
        en:         in std_logic;
        latched_cbs:    in std_logic;
        set:        in std_logic;
		reset:			in std_logic;
        is_zero:    out std_logic;
        count_val:      out std_logic_vector(9 downto 0)
    );
end counter;

architecture counter_arch of counter is
    -- define count
    signal count: unsigned(9 downto 0);
	 
begin

    process(clk, en, set, count, reset, latched_cbs)
    begin
		  if(reset = '1') then
			   count <= to_unsigned(0, 10);
        elsif (clk'event and clk='1') then -- rising edge of clock
            if (set='1') then -- preference to set
                count <= to_unsigned(0, 10); -- 1056
            elsif (en='1') then -- if enabled and not zero
                count <= count + 1; -- increment the count on clock
            end if;
        end if;

        -- assert is zero when the time's right
        if (latched_cbs='0') then
            if (count=131) then
                is_zero <= '1';
            else
                is_zero <= '0';
            end if;
        else
            if (count=767) then
                is_zero <= '1';
            else
                is_zero <= '0';
            end if;
        end if;
        -- put count up on the value bus all the time
        count_val <= std_logic_vector(count); -- removed downto here
    end process;
end counter_arch;