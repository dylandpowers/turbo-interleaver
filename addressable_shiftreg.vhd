library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- module which defines an addressable shift register.
-- shiftreg should be asynchronously cleared before each block

entity addressable_shiftreg is
    port(
        clk: in std_logic;
        aclr: in std_logic;
        shift_en: in std_logic;
        write_en: in std_logic;
        address: in std_logic_vector(9 downto 0);
        u: in std_logic;
        shiftout: out std_logic
    );
end addressable_shiftreg;

architecture addressable_shiftreg_arch of addressable_shiftreg is
    -- declare signals
    signal reg: std_logic_vector(767 downto 0);
	 
begin

    -- adjust state of reg
    process(clk, aclr, shift_en, write_en, address, u, reg)
    begin
        if (aclr='1') then
            reg <= (others => '0'); -- set everyting to 0
        elsif (rising_edge(clk)) then -- take precedence with shift_en
            if (shift_en='1') then
                -- shift everything down, make the top 0
                reg(766 downto 0) <= reg(767 downto 1);
                reg(767) <= '0';
            elsif (write_en='1' and u='1') then
                reg(to_integer(unsigned(address))) <= '1'; -- is this legal?
            end if;
        end if;

        -- output
        shiftout <= reg(0); -- LSB
    end process;

end addressable_shiftreg_arch;