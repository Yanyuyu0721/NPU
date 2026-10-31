# Invoked by run_board.py after image/receipt verification and opening UART.
if {[llength $argv] != 5} {error {Usage: program.tcl image server exact_target_or_empty arm_file ack_file}}
lassign $argv image server target arm ack
if {[version -short] ne {2026.1}} {error {Vivado2026.1 required}}
if {![file isfile $image]} {error {Matching bitstream missing}}
open_hw_manager
connect_hw_server -url $server
set targets [get_hw_targets -quiet]
if {$target ne {}} {
 set selected {}
 foreach item $targets {if {[get_property NAME $item] eq $target} {lappend selected $item}}
 set targets $selected
}
if {[llength $targets] != 1} {error {Exactly one explicitly selected hardware target required}}
current_hw_target [lindex $targets 0]
open_hw_target
set matches [get_hw_devices -quiet -filter {PART =~ xc7a100t*}]
if {[llength $matches] != 1} {error {Exactly one XC7A100T required; no device fallback}}
set device [lindex $matches 0]
current_hw_device $device
puts "ACTUAL_HW_PART=[get_property PART $device]"
set_property PROGRAM.FILE [file normalize $image] $device
set f [open $arm w];puts $f {capture_arm};close $f
set deadline [expr {[clock milliseconds]+10000}]
while {![file exists $ack]} {
 if {[clock milliseconds]>$deadline} {error {UART capture acknowledgment timeout}}
 after 10
}
program_hw_devices $device
puts {MATCHING_A7_IMAGE_PROGRAMMED}
close_hw_manager
exit
