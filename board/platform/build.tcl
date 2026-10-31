# Real project-mode implementation of the bounded BRAM hardware reference.
# It is NOT the 1MiB image simulation memory profile and has no board pin claim.
set root [file normalize [file dirname [info script]]]
lassign $argv out part
if {$part ni {xc7a100tfgg484-2 xc7z020clg484-1}} {error {Explicit supported target required}}
set out [file normalize $out]
if {[file exists [file join $out project]]} {error {Fresh project output required}}
if {[version -short] ne {2026.1}} {error {Vivado2026.1 required}}

if {[llength [get_parts -quiet $part]] != 1} {error {Target device component missing}}
set_param general.maxThreads 4
source [file join $root config.tcl]
create_project vex_npu_bram [file join $out project] -part $part
set sources {}
foreach name $rtl_sources {lappend sources [file join $root .. .. src hardware $name]}
lappend sources [file join $root vex_bram_system.v]
add_files -norecurse $sources
foreach f $sources {set_property FILE_TYPE SystemVerilog [get_files [list $f]]}
set dirs {}
foreach name $rtl_includes {lappend dirs [file join $root .. .. src hardware $name]}
set_property include_dirs $dirs [get_filesets sources_1]
set_property verilog_define {FPGA_SOURCE EDGE_RISCV_SIM} [get_filesets sources_1]
set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]
source [file join $root global_buffer.tcl]
set_property GENERATE_SYNTH_CHECKPOINT false [get_files -all *global_buffer_top_tiny_npu.xci]
generate_target all [get_ips global_buffer_top_tiny_npu]
report_property -all -file [file join $out ip_properties.rpt] [get_ips global_buffer_top_tiny_npu]
set f [open [file join $out board_top.sv] w]
puts $f {module board_top(input wire i_clk,input wire i_rst,input wire uart_rx,output wire uart_tx);}
puts $f "vex_bram_system #(.FIRMWARE_FILE(\"[file join $root firmware_itcm.mem]\")) u_system(.i_clk(i_clk),.i_rst(i_rst),.uart_rx(uart_rx),.uart_tx(uart_tx));"
puts $f {endmodule}
close $f
add_files -norecurse [list [file join $out board_top.sv]]
if {$part eq {xc7a100tfgg484-2}} {
 set xdc [file join $root .. board_pins.xdc]
} else {
set xdc [file join $out generic_7020.xdc]
set f [open $xdc w]
puts $f {create_clock -period 20.000 -name core_50mhz [get_ports i_clk]}
puts $f {set_property IOSTANDARD LVCMOS33 [get_ports {i_clk i_rst uart_rx uart_tx}]}
puts $f {set_false_path -from [get_ports {i_rst uart_rx}]}
puts $f {set_false_path -to [get_ports uart_tx]}
close $f
}
add_files -fileset constrs_1 -norecurse [list $xdc]
set_property top board_top [get_filesets sources_1]
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
set f [open [file join $out runs_status.txt] w]
puts $f "synth_1\t[get_property STATUS [get_runs synth_1]]\t[get_property PROGRESS [get_runs synth_1]]"
close $f
if {[get_property PROGRESS [get_runs synth_1]] ne {100%}} {error {Synthesis did not complete}}
open_run synth_1
report_utilization -hierarchical -file [file join $out utilization_synth.rpt]
report_timing_summary -file [file join $out timing_synth.rpt]
set blackboxes [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]
puts "REFERENCE_BLACKBOXES=[llength $blackboxes]"
if {[llength $blackboxes]} {error {Unresolved cells in synthesis}}
close_design
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1
set f [open [file join $out runs_status.txt] a]
puts $f "impl_1\t[get_property STATUS [get_runs impl_1]]\t[get_property PROGRESS [get_runs impl_1]]"
close $f
if {![string match {*route_design Complete*} [get_property STATUS [get_runs impl_1]]]} {error {Routing did not complete}}
open_run impl_1
write_checkpoint [file join $out routed_50mhz.dcp]
report_utilization -hierarchical -file [file join $out utilization_routed.rpt]
report_drc -file [file join $out drc_routed.rpt]
report_methodology -file [file join $out methodology_routed.rpt]
set metrics [open [file join $out timing_metrics.tsv] w]
puts $metrics {profile_mhz period_ns setup_slack_ns hold_slack_ns}
foreach {mhz period} {50 20.000 100 10.000 150 6.666667} {
    # Same real placement/routing, three STA constraints; no Fmax/board inference.
    create_clock -period $period -name core_50mhz [get_ports i_clk]
    if {abs([get_property PERIOD [get_clocks core_50mhz]]-$period)>0.001} {error {Clock constraint readback mismatch}}
    report_timing_summary -file [file join $out timing_${mhz}mhz.rpt]
    set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
    set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
    puts $metrics "$mhz\t$period\t$setup\t$hold"
}
close $metrics
create_clock -period 20.000 -name core_50mhz [get_ports i_clk]
close_project
puts {TARGET_ROUTE_AND_STA_COMPLETE_NOT_BOARD_MEASUREMENT}
exit
