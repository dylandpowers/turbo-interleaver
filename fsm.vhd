library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
	port(		clk:			in std_logic;
				reset:			in std_logic;
				vld_crc:		in std_logic;
				rdy_out:		in std_logic;
				cbs:			in std_logic;
				counter_zero: 	in std_logic;
				rdy_crc:		out std_logic;
				vld_out:		out std_logic;
				enable_rec:		out std_logic;
				enable_send:		out std_logic;
				latch_cbs:		out std_logic;
				set_counter:	out std_logic);
end fsm;

architecture rtl of fsm is

--signals
type state_type is (ready, rec_size, rec, count_reset, send_wait, send); -- change to new fsm states
signal state, state_next : state_type;

begin

	--on clock edge
	process(clk, reset)
	begin
		if(reset = '1') then
			state <= ready;
		elsif(clk'event and clk = '1') then
			state <= state_next;
		end if;
	end process;

	--setting state next
	process(state, vld_crc, rdy_out, counter_zero)
	begin
		case state is
			when ready =>
				if(vld_crc = '1') then
					state_next <= rec_size;
				else
					state_next <= ready;
				end if;
			when rec_size =>
				state_next <= rec;	
			when rec =>
				if(counter_zero = '1') then
					state_next <= count_reset;
				else 
					state_next <= rec;
				end if;
			when count_reset =>
				-- we might have to modify this so it goes right to send 
				-- if rdy_out is already asserted when we first assert vld_out
				state_next <= send_wait;
			when send_wait =>
				if(rdy_out = '1') then
					state_next <= send;
				else 
					state_next <= send_wait;
				end if;
			when send =>
				if(counter_zero = '1') then
					state_next <= ready;
				else
					if (rdy_out = '1') then
						state_next <= send;
					else
						state_next <= send_wait;
					end if;
				end if;
		end case;
	end process;
	
	--setting outputs
	process(state)
	begin
		case state is
			when ready =>
				rdy_crc <= '0';
				vld_out <= '0';
				enable_rec <= '0';
				enable_send <= '0';
				latch_cbs <= '0';
				set_counter <= '0';
			when rec_size =>
				rdy_crc <= '0';
				vld_out <= '0';
				enable_rec <= '0';
				enable_send <= '0';
				latch_cbs <= '1';
				set_counter <= '1';
			when rec =>
				rdy_crc <= '1';
				vld_out <= '0';
				enable_rec <= '1';
				enable_send <= '0';
				latch_cbs <= '0';
				set_counter <= '0';
			when count_reset =>
				rdy_crc <= '0';
				vld_out <= '0';
				enable_rec <= '0';
				enable_send <= '0';
				latch_cbs <= '0';
				set_counter <= '1';
			when send_wait =>
				rdy_crc <= '0';
				vld_out <= '1';
				enable_rec <= '0';
				enable_send <= '0';
				latch_cbs <= '0';
				set_counter <= '0';
			when send =>
				rdy_crc <= '0';
				vld_out <= '1';
				enable_rec <= '0';
				enable_send <= '1';
				latch_cbs <= '0';
				set_counter <= '0';
		end case;
	end process;
end rtl;