REAd IMplementation Information fv/mytop -golden fv_map -revised final_netlistv -use_rtl_names
SET PARAllel Option -threads 1,4 -norelease_license
SET COmpare Options -threads 1,4
SET MUltiplier Implementation boothrca -both
SET UNDEfined Cell black_box -noascend -both
ADD SEarch Path ../lib/ -library -both
REAd LIbrary -liberty -both /home/Group4/Desktop/AVS/Endterm_Project/projectv3/synthesis/../lib/slow_vdd1v0_basicCells.lib
REAd DEsign -verilog95 -golden -lastmod -noelab fv/mytop/fv_map.v.gz
ELAborate DEsign -golden -root mytop
REAd DEsign -verilog95 -revised -lastmod -noelab final_netlist.v
ELAborate DEsign -revised -root mytop
WRIte DEsign -golden fv_map_final_netlistv_db/elab.v -replace
REPort DEsign Data
REPort BLack Box
REPort MOdules
SET FLatten Model -seq_constant
SET FLatten Model -seq_constant_x_to 0
SET FLatten Model -hier_seq_merge
ANAlyze EXtended Mapping fv/mytop/fv_map.map.do fv/mytop/final_netlistv.map.do -output fv_map_final_netlistv_1.map.do\
   -input_specification rtl-n1 rtl-n2 -output_specification n1-n2 -replace -verbose
SET MApping Method -mapping_file_nopipo
SET MApping Method -search_in_mapping_file
SET ANalyze Option -mapping_file fv_map_final_netlistv_1.map.do
CHEck MApping Setup -mapping_file_quality -summary
CHEck VErification Information
SET ANalyze Option -auto -report_map
SET SYstem Mode lec
REPort UNmapped Points -summary
REPort UNmapped Points -notmapped
ADD COmpared Points -all
COMpare
REPort COmpare Data -class nonequivalent -class abort -class notcompared
REPort VErification -verbose
REPort STatistics
WRIte COmpared Points noneq.compared_points.mytop.fv_map.final_netlistv.tcl -class noneq -tclmode -replace
ANAlyze NOnequivalent -source_diagnosis
REPort NOnequivalent Analysis
REPort TEst Vector -noneq
REPort VErification
WRIte VErification Information
REPort VErification Information
REPort IMplementation Information
RESET
SET MApping Method -sensitive
SET VErification Information rtl_fv_map_db
REAd IMplementation Information fv/mytop -revised fv_map -use_rtl_names
SET PARAllel Option -threads 1,4 -norelease_license
SET COmpare Options -threads 1,4
SET MUltiplier Implementation boothrca -both
SET UNDEfined Cell black_box -noascend -both
ADD SEarch Path ../lib/ -library -both
REAd LIbrary -liberty -both /home/Group4/Desktop/AVS/Endterm_Project/projectv3/synthesis/../lib/slow_vdd1v0_basicCells.lib
SET UNDRiven Signal 0 -golden
SET NAming Style genus -golden
SET NAming Rule %s[%d] -instance_array -golden
SET NAming Rule %s_reg -register -golden
SET NAming Rule %L.%s %L[%d].%s %s -instance -golden
SET NAming Rule %L.%s %L[%d].%s %s -variable -golden
SET NAming Rule -ungroup_separator _ -golden
SET HDl Options -const_port_extend
SET HDl Options -unsigned_conversion_overflow on
SET HDl Options -v_to_vd on
SET HDl Options -extract_macro_constraint
SET HDl Options -VERILOG_INCLUDE_DIR sep:src
DELete SEarch Path -all -design -golden
ADD SEarch Path ../rtl/ -design -golden
REAd DEsign -define SYNTHESIS -merge bbox -golden -lastmod -noelab -verilog2k ../rtl/complete_nn.v
ELAborate DEsign -golden -root mytop -rootonly
REAd DEsign -verilog95 -revised -lastmod -noelab fv/mytop/fv_map.v.gz
ELAborate DEsign -revised -root mytop
WRIte DEsign -golden rtl_fv_map_db/elab.v -replace
UNIQuify -all -nolib -golden
REPort DEsign Data
REPort BLack Box
REPort MOdules
SET FLatten Model -seq_constant
SET FLatten Model -seq_constant_x_to 0
SET FLatten Model -hier_seq_merge
SET FLatten Model -balanced_modeling
SET MApping Method -mapping_file_nopipo
SET MApping Method -search_in_mapping_file
SET ANalyze Option -mapping_file fv/mytop/fv_map.map.do
CHEck MApping Setup -mapping_file_quality -summary
CHEck VErification Information
SET ANalyze Option -auto -report_map
WRIte HIer_compare Dofile hier_tmp2.lec.do -verbose -noexact_pin_match -replace -usage -balanced_extraction -constraint\
   -input_output_pin_equivalence -prepend_string "report_design_data; report_unmapped_points -summary; report_unmapped_points -notmapped; analyze_datapath -module -verbose; eval analyze_datapath -flowgraph -verbose"
RUN HIer_compare hier_tmp2.lec.do -dynamic_hierarchy
REPort HIer_compare Result -dynamicflattened
REPort VErification -hier -verbose
SET SYstem Mode lec
WRIte COmpared Points noneq.compared_points.mytop.rtl.fv_map.tcl -class noneq -tclmode -replace
ANAlyze NOnequivalent -source_diagnosis
REPort NOnequivalent Analysis
REPort TEst Vector -noneq
SET SYstem Mode setup
WRIte VErification Information
REPort VErification Information
REPort IMplementation Information
SET SYstem Mode lec
ANAlyze RESults -logfiles final_do.log
EXIt -f
