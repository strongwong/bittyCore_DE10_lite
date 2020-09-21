transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {bitty_riscv_sopc.vo}

vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/tb {E:/work/Verimake/bitty_core_de10_lite/tb/bitty_riscv_sopc_tb.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L gate_work -L work -voptargs="+acc"  bitty_riscv_sopc_tb

add wave *
view structure
view signals
run -all
