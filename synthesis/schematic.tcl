# Set the path to your technology library (CRITICAL STEP)
set_attr lib_search_path ../lib/
set_attr library slow_vdd1v0_basicCells.lib

# Read the netlist that was just created
read_hdl my_top_design_netlist.v

# Build the design hierarchy
elaborate

# Open the graphical schematic viewer
gui_show
