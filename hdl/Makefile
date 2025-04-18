run_simulation:
	clear
	iverilog -o cpsd_tb.vvp stimulus.v cpsd.v
	vvp cpsd_tb.vvp
	gtkwave cpsd_results.vcd