
# Set library and HDL search paths
# Replace "../lib" and "../rtl" with the actual paths to your library and RTL directories
set_attr lib_search_path ../lib/
set_attr hdl_search_path ../rtl/

# Set the target technology library
set_attr library slow_vdd1v0_basicCells.lib

# Read the top-level Verilog file
read_hdl complete_nn.v

# Elaborate the design (builds the hierarchy)
elaborate

# Read the design constraints
read_sdc ../constraints/constraints_top.sdc

# Set generic synthesis effort to low/medium/high
set_attr syn_generic_effort high /

# Synthesize to generic gates (GTECH)
syn_generic

# Set technology mapping effort to low/medium/high
set_attr syn_map_effort high /

# Map to target technology library
syn_map

# Structural Verilog pre-opt netlist for Place & Route
write_hdl > preopt_netlist.v

# Pre-opt constraints file with propagated delays for Place & Route
write_sdc > preopt_sdc.sdc

# Set optimization effort to low/medium/high
set_attr syn_opt_effort high /

# Perform post-mapping optimization
syn_opt

# Write out the results
# Structural Verilog netlist for Place & Route
write_hdl > final_netlist.v

# Constraints file with propagated delays for Place & Route
write_sdc > final_sdc.sdc

# Standard Delay Format file for timing simulation
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge > top_delays.sdf

# Generate Quality of Results report
report qor

# Exit Genus
# exit
