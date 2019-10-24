transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/ddp19/turbo-interleaver/interleaver.vhd}
vcom -93 -work work {C:/Users/ddp19/turbo-interleaver/fsm.vhd}
vcom -93 -work work {C:/Users/ddp19/turbo-interleaver/counter.vhd}
vcom -93 -work work {C:/Users/ddp19/turbo-interleaver/constant_add.vhd}
vcom -93 -work work {C:/Users/ddp19/turbo-interleaver/addressable_shiftreg.vhd}
vcom -93 -work work {C:/Users/ddp19/turbo-interleaver/romserial.vhd}

vlog -sv -work work +incdir+C:/Users/ddp19/turbo-interleaver {C:/Users/ddp19/turbo-interleaver/turbo_test.sv}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  turbo_test

add wave *
view structure
view signals
run -all
