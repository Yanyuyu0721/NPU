module board_top(input wire i_clk,input wire i_rst,input wire uart_rx,output wire uart_tx);
vex_bram_system #(.FIRMWARE_FILE("D:/vexriscv_tinymaix_final_20261030/board/platform/firmware_itcm.mem")) u_system(.i_clk(i_clk),.i_rst(i_rst),.uart_rx(uart_rx),.uart_tx(uart_tx));
endmodule
