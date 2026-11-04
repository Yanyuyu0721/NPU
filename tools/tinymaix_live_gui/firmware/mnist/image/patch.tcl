open_checkpoint {D:/vexriscv_tinymaix_final_20261030/build/out/xc7a100t_20261102/routed_50mhz.dcp}
set changed 0
if {$changed != 0} {error {COUNT_MISMATCH}}
set f [open {D:/a7_finalize_20261102/fresh_mnist/image/updated_init.txt} w]
foreach c [get_cells -hier -filter {REF_NAME =~ RAMB*}] {
 if {[string match *itcm* $c]} {
  puts $f "CELL $c"
  foreach p [list_property $c] {if {[regexp {^INIT_[0-9A-F][0-9A-F]$} $p]} {puts $f "$p [get_property $p $c]"}}
 }
}
close $f
write_checkpoint -force {D:/a7_finalize_20261102/fresh_mnist/image/routed_50mhz.dcp}
write_bitstream -force {D:/a7_finalize_20261102/fresh_mnist/image/board_top.bit}
puts ITCM_PATCH_VERIFIED_BIT_READY
