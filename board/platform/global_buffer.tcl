# One 64-bit AXI beat = 8 bytes. 512 beats = 4096 bytes, matching SIZE=12.
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name global_buffer_top_tiny_npu
set_property -dict [list \
    CONFIG.Interface_Type {AXI4} CONFIG.AXI_Type {AXI4_Full} \
    CONFIG.AXI_Slave_Type {Memory_Slave} CONFIG.Use_AXI_ID {true} CONFIG.AXI_ID_Width {3} \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Use_Byte_Write_Enable {true} \
    CONFIG.Byte_Size {8} CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Write_Width_A {64} CONFIG.Write_Depth_A {512} CONFIG.Read_Width_A {64} \
    CONFIG.Write_Width_B {64} CONFIG.Read_Width_B {64} \
    CONFIG.Operating_Mode_A {READ_FIRST} CONFIG.Operating_Mode_B {READ_FIRST} \
    CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Use_RSTB_Pin {true} CONFIG.Reset_Type {ASYNC} CONFIG.Port_B_Clock {50} \
    CONFIG.Port_B_Enable_Rate {100} CONFIG.EN_SAFETY_CKT {false} \
] [get_ips global_buffer_top_tiny_npu]
set ip [get_ips global_buffer_top_tiny_npu]
foreach {property expected} {CONFIG.Write_Width_A 64 CONFIG.Read_Width_A 64 CONFIG.Write_Depth_A 512 CONFIG.AXI_ID_Width 3} {
    if {[get_property $property $ip] != $expected} {error "Global buffer mismatch: $property"}
}
set_property GENERATE_SYNTH_CHECKPOINT true [get_files -all *global_buffer_top_tiny_npu.xci]

