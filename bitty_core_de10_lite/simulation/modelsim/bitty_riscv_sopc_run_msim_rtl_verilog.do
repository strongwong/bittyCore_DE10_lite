transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/bitty_defs.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite {E:/work/Verimake/bitty_core_de10_lite/bitty_inst_rom.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite {E:/work/Verimake/bitty_core_de10_lite/bitty_inst_rom1.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite {E:/work/Verimake/bitty_core_de10_lite/bitty_inst_rom2.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite {E:/work/Verimake/bitty_core_de10_lite/bitty_inst_rom3.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/regsfile.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/pc_reg.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/mem_wb.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/mem.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/if_id.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/id_ex.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/id.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/ex_mem.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/ex.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/data_ram.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/ctrl.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/csr_reg.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/bitty_riscv_sopc.v}
vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/core {E:/work/Verimake/bitty_core_de10_lite/core/bitty_riscv.v}

vlog -vlog01compat -work work +incdir+E:/work/Verimake/bitty_core_de10_lite/tb {E:/work/Verimake/bitty_core_de10_lite/tb/bitty_riscv_sopc_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  bitty_riscv_sopc_tb

add wave *
view structure
view signals
run -all
