vlib work
vlog REG_MUX.v DSP48A1.v tb_DSP48A1.v
vsim -voptargs=+acc work.tb_DSP48A1
add wave *
run -all
#quit -sim