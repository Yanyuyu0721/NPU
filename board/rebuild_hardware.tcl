# 2018.2-compatible port of platform/build.tcl for the A7 DaVinci Pro board.
#
# Same RTL set, same IP parameters, same board_pins.xdc, same 50 MHz/100 MHz/
# 150 MHz STA sweep as the 2026.1 reference flow.  Only tool-version gates are
# relaxed so Vivado 2018.2 can produce a bring-up bitstream:
#   * Vivado version assertion -> informational PORT_VIVADO line
#   * set_property xpm_libraries (2018.3+) -> skipped
#   * GENERATE_SYNTH_CHECKPOINT -> written inside catch
#   * report_methodology -> written inside catch
#   * write_bitstream appended after route_design
#
# The packaged implementation uses Vivado 2018.2; board/program.tcl loads the
# resulting bitstream with Vivado 2026.1. Tool-version provenance is retained.
#
# Usage: vivado -mode batch -source board/rebuild_hardware.tcl -tclargs <out_dir> [part] [override_root]
#
# override_root is optional and works like a shadow copy of src/hardware: any
# file found at <override_root>/<rtl path> replaces the packaged original.
# The effective 2018.2-compatible BRAM implementation is already frozen in
# src/hardware/src/rtl/common_cells/ram/edge_bram_banked.sv.

proc port_build {root out part {override_root {}}} {
    set platform [file join $root platform]
    set rtl_root [file normalize [file join $root .. src hardware]]
    set jobs 8
    puts "PORT_VIVADO=[version -short]"
    puts "PORT_PART=$part"
    puts "PORT_OUT=$out"
    if {$override_root ne {}} {
        set override_root [file normalize $override_root]
        puts "PORT_OVERRIDE_ROOT=$override_root"
    }
    if {$part ni {xc7a100tfgg484-2 xc7z020clg484-1}} {error {Explicit supported target required}}
    if {[file exists [file join $out project]]} {error {Fresh project output required}}
    if {[llength [get_parts -quiet $part]] != 1} {error {Target device component missing}}
    file mkdir $out
    set_param general.maxThreads $jobs

    source [file join $platform config.tcl]
    create_project vex_npu_bram [file join $out project] -part $part
    set sources {}
    foreach name $rtl_sources {
        set f [file join $rtl_root $name]
        # Optional drop-in replacement of individual RTL files (keep the package tree
        # untouched).  Same relative path under override_root wins.
        if {$override_root ne {}} {
            set alt [file join $override_root $name]
            if {[file isfile $alt]} {
                set f $alt
                puts "PORT_OVERRIDE=$name"
            }
        }
        lappend sources $f
    }
    lappend sources [file join $platform vex_bram_system.v]
    foreach f $sources {if {![file isfile $f]} {error "Missing source: $f"}}
    add_files -norecurse $sources
    foreach f $sources {set_property FILE_TYPE SystemVerilog [get_files [list $f]]}
    set dirs {}
    foreach name $rtl_includes {lappend dirs [file join $rtl_root $name]}
    set_property include_dirs $dirs [get_filesets sources_1]
    set defines {FPGA_SOURCE EDGE_RISCV_SIM}
    if {[scan [version -short] %f tool_version] == 1 && $tool_version < 2019.2} {
        # XPM FIFO gained SIM_ASSERT_CHK/CASCADE_HEIGHT only in 2019.2+.
        lappend defines EDGE_XPM_LEGACY
        puts {PORT_NOTE=EDGE_XPM_LEGACY define added for pre-2019.2 XPM FIFO}
    }
    set_property verilog_define $defines [get_filesets sources_1]
    puts "PORT_DEFINES=$defines"
    puts "PORT_SOURCES=[llength $sources] PORT_INCLUDES=[llength $dirs]"
    if {[catch {set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]} xpm_err]} {
        puts "PORT_NOTE=xpm_libraries unsupported on this tool (${xpm_err})"
    }

    source [file join $platform global_buffer.tcl]
    if {[catch {set_property GENERATE_SYNTH_CHECKPOINT false [get_files -all *global_buffer_top_tiny_npu.xci]} ip_err]} {
        puts "PORT_NOTE=GENERATE_SYNTH_CHECKPOINT skipped (${ip_err})"
    }
    generate_target all [get_ips global_buffer_top_tiny_npu]
    report_property -all -file [file join $out ip_properties.rpt] [get_ips global_buffer_top_tiny_npu]

    set f [open [file join $out board_top.sv] w]
    puts $f {module board_top(input wire i_clk,input wire i_rst,input wire uart_rx,output wire uart_tx);}
    puts $f "vex_bram_system #(.FIRMWARE_FILE(\"[file join $platform firmware_itcm.mem]\")) u_system(.i_clk(i_clk),.i_rst(i_rst),.uart_rx(uart_rx),.uart_tx(uart_tx));"
    puts $f {endmodule}
    close $f
    add_files -norecurse [list [file join $out board_top.sv]]
    if {$part eq {xc7a100tfgg484-2}} {
        set xdc [file join $root board_pins.xdc]
        if {![file isfile $xdc]} {error {board_pins.xdc missing}}
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
    puts {PORT_PROJECT_READY}

    launch_runs synth_1 -jobs $jobs
    wait_on_run synth_1
    set f [open [file join $out runs_status.txt] w]
    puts $f "synth_1\t[get_property STATUS [get_runs synth_1]]\t[get_property PROGRESS [get_runs synth_1]]"
    close $f
    puts "PORT_SYNTH_STATUS=[get_property STATUS [get_runs synth_1]]"
    if {[get_property PROGRESS [get_runs synth_1]] ne {100%}} {error {Synthesis did not complete}}
    open_run synth_1
    report_utilization -hierarchical -file [file join $out utilization_synth.rpt]
    report_timing_summary -file [file join $out timing_synth.rpt]
    set blackboxes [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]
    puts "REFERENCE_BLACKBOXES=[llength $blackboxes]"
    if {[llength $blackboxes]} {error {Unresolved cells in synthesis}}
    close_design
    puts {PORT_SYNTH_CLEAN}

    launch_runs impl_1 -to_step route_design -jobs $jobs
    wait_on_run impl_1
    set f [open [file join $out runs_status.txt] a]
    puts $f "impl_1\t[get_property STATUS [get_runs impl_1]]\t[get_property PROGRESS [get_runs impl_1]]"
    close $f
    puts "PORT_IMPL_STATUS=[get_property STATUS [get_runs impl_1]]"
    if {![string match {*route_design Complete*} [get_property STATUS [get_runs impl_1]]]} {error {Routing did not complete}}
    open_run impl_1
    write_checkpoint -force [file join $out routed_50mhz.dcp]
    set f [open [file join $out initial_itcm.txt] w]
    foreach c [get_cells -hier -filter {REF_NAME =~ RAMB*}] {
        if {[string match *itcm* $c]} {
            puts $f "CELL $c"
            foreach p [list_property $c] {if {[regexp {^INIT_[0-9A-F][0-9A-F]$} $p]} {puts $f "$p [get_property $p $c]"}}
        }
    }
    close $f

    report_utilization -hierarchical -file [file join $out utilization_routed.rpt]
    report_drc -file [file join $out drc_routed.rpt]
    if {[catch {report_methodology -file [file join $out methodology_routed.rpt]} rpt_err]} {
        puts "PORT_NOTE=report_methodology skipped (${rpt_err})"
    }
    set metrics [open [file join $out timing_metrics.tsv] w]
    puts $metrics {profile_mhz period_ns setup_slack_ns hold_slack_ns}
    foreach {mhz period} {50 20.000 100 10.000 150 6.666667} {
        create_clock -period $period -name core_50mhz [get_ports i_clk]
        if {abs([get_property PERIOD [get_clocks core_50mhz]]-$period)>0.001} {error {Clock constraint readback mismatch}}
        report_timing_summary -file [file join $out timing_${mhz}mhz.rpt]
        set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
        set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
        puts "PORT_STA_${mhz}MHZ setup=$setup hold=$hold"
        puts $metrics "$mhz\t$period\t$setup\t$hold"
    }
    close $metrics
    create_clock -period 20.000 -name core_50mhz [get_ports i_clk]
    close_design

    launch_runs impl_1 -to_step write_bitstream -jobs $jobs
    wait_on_run impl_1
    puts "PORT_BITSTREAM_STATUS=[get_property STATUS [get_runs impl_1]]"
    if {![string match {*write_bitstream Complete*} [get_property STATUS [get_runs impl_1]]]} {error {write_bitstream did not complete}}
    set built [file join [get_property DIRECTORY [get_runs impl_1]] board_top.bit]
    if {![file isfile $built]} {error {Bitstream missing after write_bitstream}}
    file copy -force $built [file join $out board_top.bit]
    puts "PORT_BIT=[file join $out board_top.bit]"
    puts "PORT_BIT_BYTES=[file size [file join $out board_top.bit]]"
    close_project
    puts {PORT_BIT_READY}
}

set script_root [file normalize [file dirname [info script]]]
lassign $argv out part override_root
if {$out eq {}} {error {Usage: build_2018_2.tcl out_dir ?part? ?override_root?}}
if {$part eq {}} {set part xc7a100tfgg484-2}
if {[catch {port_build $script_root [file normalize $out] $part $override_root} err]} {
    puts "PORT_BUILD_FAILED=$err"
    exit 1
}
exit 0
