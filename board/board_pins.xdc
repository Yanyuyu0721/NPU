# ALIENTEK DaVinci Pro / A7-100T; manual V2.1 p610 pinout, p226 configuration.
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS15} [get_ports i_clk]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS15} [get_ports i_rst]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property -dict {PACKAGE_PIN E14 IOSTANDARD LVCMOS33} [get_ports uart_rx]
create_clock -period 20.000 -name core_50mhz [get_ports i_clk]
set_false_path -from [get_ports i_rst]
set_false_path -from [get_ports uart_rx]
set_false_path -to [get_ports uart_tx]
# Manufacturer manual V2.1 p226 and p1698; independent of UART IOSTANDARD.
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
