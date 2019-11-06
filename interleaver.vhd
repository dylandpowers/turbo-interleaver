library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interleaver is
    port(
        clk:            in std_logic;
        asyn_reset:     in std_logic;
        vld_crc:        in std_logic;
        rdy_out:        in std_logic;
        cbs:            in std_logic;
        data_in:        in std_logic_vector(7 downto 0);
        rdy_crc:        out std_logic;
        vld_out:        out std_logic;
        last_byte:      out std_logic;
        data_out:       out std_logic_vector(7 downto 0)
    );

end interleaver;

architecture interleaver_arch of interleaver is
    -- define signals
    signal count_zero_sig: std_logic;
    signal latched_cbs: std_logic;
    signal enable_rec_sig: std_logic;
    signal enable_send_sig: std_logic;
    signal latch_cbs_now: std_logic;
    signal set_counter_sig: std_logic;
    signal enable_rec_delay_sig: std_logic;
    signal muxout0_sig: std_logic_vector(7 downto 0);
    signal muxout1_sig: std_logic_vector(7 downto 0);
    signal u7, u6, u5, u4, u3, u2, u1, u0: std_logic;
    signal count_value_sig: std_logic_vector(9 downto 0);
	 signal count_enable: std_logic;
    signal adj_addr_sig: std_logic_vector(9 downto 0);
    signal inter_addr_sig0: std_logic_vector(9 downto 0);
    signal inter_addr_sig1: std_logic_vector(9 downto 0);
    signal inter_addr_sig2: std_logic_vector(9 downto 0);
    signal inter_addr_sig3: std_logic_vector(9 downto 0);
    signal inter_addr_sig4: std_logic_vector(9 downto 0);
    signal inter_addr_sig5: std_logic_vector(9 downto 0);
    signal inter_addr_sig6: std_logic_vector(9 downto 0);
    signal inter_addr_sig7: std_logic_vector(9 downto 0);
	 signal data_in_rev: std_logic_vector(7 downto 0);

    -- declare components
    ---- fsm
    component fsm
        port(
            clk:			in std_logic;
			reset:			in std_logic;
			vld_crc:		in std_logic;
			rdy_out:		in std_logic;
            cbs:			in std_logic;
            counter_zero:    in std_logic;
			rdy_crc:		out std_logic;
			vld_out:		out std_logic;
			enable_rec:		out std_logic;
            enable_send:	out std_logic;
            latch_cbs:      out std_logic;
            set_counter:    out std_logic
        );
    end component;
    ---- counter
    component counter
        port(
            clk:        in std_logic;
            en:         in std_logic;
            latched_cbs:    in std_logic;
            set:        in std_logic;
			reset:		in std_logic;
            is_zero:    out std_logic;
            count_val:      out std_logic_vector(9 downto 0)
        );
    end component;
    ---- Constant Adder
    component constant_add
        port(
            in_addr: in std_logic_vector(9 downto 0);
            cbs: in std_logic;
            out_addr: out std_logic_vector(9 downto 0)
        );
    end component;
    ---- 8 x ROM w/ precomputed bits
    component rom10bit0
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit1
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit2
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit3
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit4
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit5
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit6
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
	 
	 component rom10bit7
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		    clock		: IN STD_LOGIC  := '1';
		    q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;
    
    ---- 2-sel 8-wide mux (switch on cbs)
    component mux2_8wide
        port(
            sel: in std_logic;
            muxin: in std_logic_vector(7 downto 0);
            muxout0: out std_logic_vector(7 downto 0);
            muxout1: out std_logic_vector(7 downto 0)
        );
    end component;

    ---- 8 x adressable shiftreg
    component addressable_shiftreg
        port(
            clk: in std_logic;
            aclr: in std_logic;
            shift_en: in std_logic;
            write_en: in std_logic;
            address: in std_logic_vector(9 downto 0);
            u: in std_logic;
            shiftout: out std_logic
        );
    end component;

begin
    -- latched cbs process
    process(cbs, clk, asyn_reset)
    begin
        if (asyn_reset = '1') then
            latched_cbs <= '0';
        elsif (rising_edge(clk)) then
            if (latch_cbs_now='1') then -- should probably be a signal from the FSM
                latched_cbs <= cbs;
            end if;
        end if;
    end process;

    -- latch the receive_en signal to match latency
    process(clk, enable_rec_sig)
    begin
        if (asyn_reset = '1') then
            enable_rec_delay_sig <= '0';
        elsif (rising_edge(clk)) then
            enable_rec_delay_sig <= enable_rec_sig;
        end if;
    end process;

    process(count_zero_sig)
    begin
        last_byte <= count_zero_sig and enable_send_sig;
    end process;


    -- calculate the inputs to the addr_sregs
    process(clk) -- latched - account for delay of 1 from ROM access latch
    begin
        if (rising_edge(clk)) then
            u0 <= muxout0_sig(0) or muxout1_sig(0);
            u1 <= muxout0_sig(3) or muxout1_sig(7);
            u2 <= muxout0_sig(2) or muxout1_sig(6);
            u3 <= muxout0_sig(5) or muxout1_sig(5);
            u4 <= muxout0_sig(4) or muxout1_sig(4);
            u5 <= muxout0_sig(7) or muxout1_sig(3);
            u6 <= muxout0_sig(6) or muxout1_sig(2);
            u7 <= muxout0_sig(1) or muxout1_sig(1);
        end if;
    end process;

    fsm_unit: fsm
    port map(
        clk => clk,
        reset => asyn_reset,
        vld_crc => vld_crc,
        rdy_out => rdy_out,
        cbs => cbs,
        counter_zero => count_zero_sig,
        rdy_crc => rdy_crc,
        vld_out => vld_out,
        enable_rec => enable_rec_sig,
        enable_send => enable_send_sig,
        latch_cbs => latch_cbs_now,
        set_counter => set_counter_sig
    );
	 
	 process(data_in)
	 begin
		data_in_rev(0) <= data_in(7);
		data_in_rev(1) <= data_in(6);
		data_in_rev(2) <= data_in(5);
		data_in_rev(3) <= data_in(4);
		data_in_rev(4) <= data_in(3);
		data_in_rev(5) <= data_in(2);
		data_in_rev(6) <= data_in(1);
		data_in_rev(7) <= data_in(0);
	 end process;

    mux_unit: mux2_8wide
    port map(
        sel => latched_cbs,
        muxin => data_in_rev,
        muxout0 => muxout0_sig,
        muxout1 => muxout1_sig
    );
	 
	 process(enable_rec_sig, enable_send_sig)
	 begin
		count_enable <= enable_rec_sig or enable_send_sig;
	 end process;

    counter_unit: counter
    port map(
        clk => clk,
        en => count_enable, 
        latched_cbs => latched_cbs,
        set => set_counter_sig,
		  reset => asyn_reset,
        is_zero => count_zero_sig,
        count_val => count_value_sig
    );

    const_add_unit: constant_add
    port map(
        in_addr => count_value_sig,
        cbs => latched_cbs,
        out_addr => adj_addr_sig
    );

    -- do this for all 0 through 7
    rom10bit_unit0: rom10bit0
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig0
    );

    rom10bit_unit1: rom10bit1
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig1
    );

    rom10bit_unit2: rom10bit2
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig2
    );

    rom10bit_unit3: rom10bit3
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig3
    );

    rom10bit_unit4: rom10bit4
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig4
    );

    rom10bit_unit5: rom10bit5
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig5
    );

    rom10bit_unit6: rom10bit6
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig6
    );

    rom10bit_unit7: rom10bit7
    port map(
        address => adj_addr_sig,
        clock => clk,
        q => inter_addr_sig7
    );

    -- do this for all 0 through 7
    addr_sreg_unit0: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig0,
        u => u0,
        shiftout => data_out(7)
    );

    addr_sreg_unit1: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig1,
        u => u1, 
        shiftout => data_out(6)
    );

    addr_sreg_unit2: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig2,
        u => u2,
        shiftout => data_out(5)
    );

    addr_sreg_unit3: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig3,
        u => u3,
        shiftout => data_out(4)
    );

    addr_sreg_unit4: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig4,
        u => u4,
        shiftout => data_out(3)
    );

    addr_sreg_unit5: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig5,
        u => u5,
        shiftout => data_out(2)
    );

    addr_sreg_unit6: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig6,
        u => u6,
        shiftout => data_out(1)
    );

    addr_sreg_unit7: addressable_shiftreg
    port map(
        clk => clk,
        aclr => asyn_reset,
        shift_en => enable_send_sig,
        write_en => enable_rec_delay_sig,
        address => inter_addr_sig7,
        u => u7,
        shiftout => data_out(0)
    );

end interleaver_arch;