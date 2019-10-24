library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity constant_add is
    port(
        in_addr: std_logic_vector(9 downto 0);
        cbs: in std_logic;
        out_addr: out std_logic_vector(9 downto 0)
    );
end constant_add;

architecture constant_add_arch of constant_add is

begin

    process(in_addr, cbs)
    begin
        -- simple async logic (purely functional unit)
        if (cbs='1') then -- if larger block size, skip over small block size
            out_addr <= std_logic_vector(unsigned(in_addr) + 132); -- removed downto on in_addr here (Eric) 10/21
        else
            out_addr <= in_addr; -- default buffer size
        end if;
    end process;
end constant_add_arch;