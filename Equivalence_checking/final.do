set log file final_lec.log -replace
read library ./slow_vdd1v0_basicCells.v -verilog -both
read design ../synthesis/preopt_netlist.v -verilog -golden 
read design ../synthesis/final_netlist.v -verilog -revised
		//read design ../synthesis/counter_netlist_dft.v -verilog -revised
		//add pin constraints 0 SE  -revised
		//add ignored inputs scan_in -revised
		//add ignored outputs scan_out -revised
set system mode lec
add compare point -all
compare
report verification 
