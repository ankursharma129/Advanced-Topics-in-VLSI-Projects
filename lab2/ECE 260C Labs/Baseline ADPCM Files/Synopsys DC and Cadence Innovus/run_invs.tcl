set design Subsystem
setMultiCpuUsage -localCpu 8

setDesignMode -process 65

set libdir "/home/linux/ieng6/ee260csp22/public/data/libraries"

set netlist "./${design}.v"
set sdc "./${design}.sdc"

set lef "$libdir/lef/tcbn65gplus_m8T2.lef"

# default settings
set init_pwr_net "vdd"
set init_gnd_net "vss"
set init_assign_buffer {1}

# default settings
set init_verilog "$netlist"
set init_design_netlisttype "Verilog"
set init_design_settop 1
set init_top_cell "$design"
set init_lef_file "$lef"

# MCMM setup
create_library_set -name WC_LIB -timing [list $libdir/lib/tcbn65gplustc.lib]
create_library_set -name BC_LIB -timing [list $libdir/lib/tcbn65gplustc.lib] 

create_rc_corner -name Cmax -cap_table $libdir/techfiles/cln65g+_1p08m+alrdl_top2_cworst.captable
create_rc_corner -name Cmin -cap_table $libdir/techfiles/cln65g+_1p08m+alrdl_top2_cbest.captable

create_delay_corner -name WC -library_set WC_LIB -rc_corner Cmax
create_delay_corner -name BC -library_set BC_LIB -rc_corner Cmin

create_constraint_mode -name CON -sdc_file $sdc

create_analysis_view -name WC_VIEW -delay_corner WC -constraint_mode CON
create_analysis_view -name BC_VIEW -delay_corner BC -constraint_mode CON

init_design -setup {WC_VIEW} -hold {BC_VIEW}

set_interactive_constraint_modes {CON}

setAnalysisMode -analysisType onChipVariation -cppr both

# floorplan
floorPlan -site core -r 1.0 0.7 0 0 0 0

# pre-placement
timeDesign -preplace -prefix preplace
checkDesign -all
check_timing
setOptMode -powerEffort low -leakageToDynamicRatio 0.5

# placement
setPlaceMode -placeIoPins true
place_opt_design -prefix place

# CTS
set_ccopt_mode -integration "native" -ccopt_modify_clock_latency false 
create_ccopt_clock_tree_spec
ccopt_design -prefix cts
set_propagated_clock [all_clocks]
set_clock_propagation propagated
optDesign -postCTS -hold -expandedViews

# routing
setNanoRouteMode -routeWithViaInPin 1:1
setNanoRouteMode -routeConcurrentMinimizeViaCountEffort high
setNanoRouteMode -routeExpUseAutoVia false
routeDesign

setDelayCalMode -reset -siMode
optDesign -postRoute -setup -hold -prefix postRoute -expandedViews

#setDelayCalMode -SIAware true -engine aae
setExtractRCMode -engine postRoute 
extractRC
optDesign -postRoute -hold -prefix postRoute 
extractRC

# save design
summaryReport -noHtml -outfile sum.rpt
report_timing > timing.rpt
report_power -outfile power.rpt
rcOut -view WC_VIEW -spef routed.spef.gz
saveNetlist routed.v.gz
saveDesign routed.enc

exit
