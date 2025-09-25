# Cadence Genus(TM) Synthesis Solution, Version 23.14-s090_1, built Feb 27 2025 10:49:50

# Date: Sun Sep 21 04:11:09 2025
# Host: pratik (x86_64 w/Linux 5.14.0-503.40.1.el9_5.x86_64) (24cores*96cpus*2physical cpus*AMD EPYC 9254 24-Core Processor 1024KB)
# OS:   AlmaLinux 9.5 (Teal Serval)

source rc_script.tcl
write_do_lec -revised_design final_netlist.v -logfile final_do.log > final_lec.do
gui_show
