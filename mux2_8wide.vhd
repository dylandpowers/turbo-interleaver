library ieee;
use ieee.std_logic_1164.all;

entity mux2_8wide is
    port(
        sel: in std_logic;
        muxin: in std_logic_vector(7 downto 0);
        muxout0: out std_logic_vector(7 downto 0);
        muxout1: out std_logic_vector(7 downto 0)
    );
end mux2_8wide;

architecture mux2_8wide_arch of mux2_8wide is
begin

    process(muxin, sel)
    begin
        if (sel = '0') then
            muxout0(7 downto 0) <= muxin(7 downto 0);
            muxout1 <= (others=>'0');
        else
            muxout1(7 downto 0) <= muxin(7 downto 0);
            muxout0 <= (others=>'0');
        end if;
    end process;

end mux2_8wide_arch;