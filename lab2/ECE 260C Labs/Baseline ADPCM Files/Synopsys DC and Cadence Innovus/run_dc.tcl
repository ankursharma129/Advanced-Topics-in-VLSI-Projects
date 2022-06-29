set top_module Subsystem 
set libdir /home/linux/ieng6/ee260csp22/public/data/libraries/db

# Target library
set tl_list "$libdir/tcbn65gplustc.db"
set ll_list "$libdir/tcbn65gplustc.db"

set link_library $ll_list
set target_library $tl_list
set symbol_library {}
set wire_load_model ""
set wire_load_mode enclosed
set timing_use_enhanced_capacitance_modeling true

set search_path [concat $search_path ]
set dont_use_cells 1
set dont_use_cell_list ""

set synthetic_library {}
set link_path [concat  $link_library $synthetic_library]

remove_design -all
if {[file exists template]} {
	exec rm -rf template
}
exec mkdir template
if {![file exists gate]} {
	exec mkdir gate
}
if {![file exists log]} {
	exec mkdir log
}

set compile_effort   "high"
set compile_flatten_all 1
set compile_no_new_cells_at_top_level false
set hdlin_enable_vpp true
set hdlin_auto_save_templates false
define_design_lib WORK -path .template
set verilogout_single_bit false
set enforce_input_fanout_one     0

# read RTL
source ./for_dc.tcl
foreach rtl_file $rtl_all {
    analyze -format verilog -lib WORK $rtl_file
}
elaborate $top_module -lib WORK -update

current_design $top_module

# Link Design
set dc_shell_status [ link ]
if {$dc_shell_status == 0} {
	echo "****************************************************"
	echo "* ERROR!!!! Failed to Link...exiting prematurely.  *"
	echo "****************************************************"
	exit
}

# Default SDC Constraints
read_sdc ./$top_module\.sdc

# Sourcing false path sdc , specifically for this design 
#read_sdc ./aes1_gcd8_false_path.sdc

# Timing derates
set_timing_derate -early 0.900 -net_delay 
set_timing_derate -late 1.190 -net_delay
set_timing_derate -early 0.900 -cell_delay
set_timing_derate -late 1.050 -cell_delay
set_timing_derate -early -cell_check 1.100
set_timing_derate -late -cell_check 1.100
# Environment and compile options 
set_max_area 0
set_leakage_optimization true
set_cost_priority {max_transition max_fanout max_delay max_capacitance}
set_fix_multiple_port_nets -all -buffer_constants
foreach_in_collection p [all_inputs] {
	if {[get_attri $p full_name]=="clk"} {
		continue
	}
  set_driving_cell -lib_cell BUFFD8LVT -input_transition_rise 0.1 -input_transition_fall 0.1 $p
}
foreach_in_collection p [all_outputs] {
	set_load 0.05 $p
}

# Input Fanout Control
if {[info exists enforce_input_fanout_one] && ($enforce_input_fanout_one  == 1)} {
	set_max_fanout 1 $non_ideal_inputs
}

# More constraints and setup before compile
foreach_in_collection design [ get_designs "*" ] {
	current_design $design
	set_fix_multiple_port_nets -all
}
current_design $top_module

foreach_in_collection flop [all_registers] {
  set flopName [get_attri $flop full_name]
  set_register_merging $flopName FALSE
}

# Compile
if {[info exists compile_flatten_all] && ($compile_flatten_all  == 1)} {
	ungroup -flatten -all
}
set_fix_multiple_port_nets -all
set dc_shell_status [ compile_ultra -no_autoungroup -timing_high_effort_script  -exact_map ]

if {$dc_shell_status == 0} {
	echo "*******************************************************"
	echo "* ERROR!!!! Failed to compile...exiting prematurely.  *"
	echo "*******************************************************"
	exit
}
sh date

current_design $top_module
change_names -rules verilog -hierarchy

if {[info exists use_physopt] && ($use_physopt == 1)} {
	write -format verilog -hier -output [format "%s%s%s" gate/ $top_module _hier_fromdc.v]
} else {
	write -format verilog -hier -output [format "%s%s%s" gate/ $top_module .v]
}

current_design $top_module
write_sdc [format "%s%s%s" gate/ $top_module .sdc]

# Write Reports
redirect [format "%s%s%s" log/ $top_module _area.rep] { report_area }
redirect -append [format "%s%s%s" log/ $top_module _area.rep] { report_reference }
redirect [format "%s%s%s" log/ $top_module _cell.rep] { report_cell }
redirect [format "%s%s%s" log/ $top_module _design.rep] { report_design }
redirect [format "%s%s%s" log/ $top_module _power.rep] { report_power }
redirect [format "%s%s%s" log/ $top_module _timing.rep] \
  { report_timing -path full -max_paths 100 -nets -transition_time -capacitance -significant_digits 3}
redirect [format "%s%s%s" log/ $top_module _check_timing.rep] { check_timing }
redirect [format "%s%s%s" log/ $top_module _check_design.rep] { check_design }


set inFile  [open log/$top_module\_area.rep]
while { [gets $inFile line]>=0 } {
    if { [regexp {Total cell area:} $line] } {
        set AREA [lindex $line 3]
    }
}
close $inFile
set inFile  [open log/$top_module\_power.rep]
while { [gets $inFile line]>=0 } {
    if { [regexp {Total Dynamic Power} $line] } {
        set PWR [lindex $line 4]
    } elseif { [regexp {Cell Leakage Power} $line] } {  
        set LEAK [lindex $line 4] 
    }
}
close $inFile

set path    [get_timing_path -nworst 1]
set WNS     [get_attribute $path slack]

set outFile [open result_dc.rpt w]
puts $outFile "$AREA\t$WNS\t$PWR\t$LEAK"
close $outFile


# Check Design and Detect Unmapped Design
set unmapped_designs [get_designs -filter "is_unmapped == true" $top_module]
if {  [sizeof_collection $unmapped_designs] != 0 } {
	echo "****************************************************"
	echo "* ERROR!!!! Compile finished with unmapped logic.  *"
	echo "****************************************************"
	exit
}
echo "run.scr completed successfully"
#exit
