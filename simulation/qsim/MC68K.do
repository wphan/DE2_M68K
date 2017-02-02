onerror {quit -f}
vlib work
vlog -work work MC68K.vo
vlog -work work MC68K.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.MC68K_vlg_vec_tst
vcd file -direction MC68K.msim.vcd
vcd add -internal MC68K_vlg_vec_tst/*
vcd add -internal MC68K_vlg_vec_tst/i1/*
add wave /*
run -all
