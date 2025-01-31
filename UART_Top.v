`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// 
// Module Name: UART_Top
//
// Description: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_Top #
(
    parameter clk_freq = 1E6,
    parameter baud = 9600
)
(
    input clk,
    input rst_n,
    input rx,
    input [7:0] din_tx,
    input data_update,
    output tx,
    output [7:0] dout_rx,
    output done_tx,
    output done_rx        
);

UART_Tx #(
    .clk_freq(clk_freq),
    .baud(baud)
) u_tx (
    .clk(clk), 
    .rst_n(rst_n), 
    .data_update(data_update),
    .din_tx(din_tx),
    .tx(tx),
    .done_tx(done_tx)
);

UART_Rx #(
    .clk_freq(clk_freq),
    .baud(baud)
) u_rx (
    .clk(clk), 
    .rst_n(rst_n),
    .rx(rx),
    .dout_rx(dout_rx),
    .done_rx(done_rx)
);

endmodule
