onbreak resume
onerror resume
vsim -voptargs=+acc work.adpcm_tb

add wave sim:/adpcm_tb/u_adpcm/clk
add wave sim:/adpcm_tb/u_adpcm/reset
add wave sim:/adpcm_tb/u_adpcm/clk_enable
add wave sim:/adpcm_tb/u_adpcm/in1
add wave sim:/adpcm_tb/u_adpcm/ce_out
add wave sim:/adpcm_tb/u_adpcm/Out1
add wave sim:/adpcm_tb/Out1_ref
run -all
