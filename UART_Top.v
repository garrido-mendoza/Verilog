//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// 
// Module Name: UART_Top
//
// Description: Top-level UART module that instantiates UART transmitter and receiver.
//
// - The UART_Top module is essentially the top-level module that combines both
//   a UART transmitter (Tx) and a UART receiver (Rx).
// - The UART_Tx sub-module handles the transmission of data, while the UART_Rx
//   sub-module deals with receiving data.
// - It has parameters for clock frequency (clk_freq) and baud rate (baud), which
//   are both crucial for serial communication.
// - Various input/output pins are used to connect this module with the rest of
//   the system, such as the clock signal (clk), reset signal (rst_n), receive
//   data (rx), transmit data (din_tx), and data update signal (data_update).
// - Finally, it also has output pins for the transmit signal (tx), received data
//   (dout_rx), and flags to indicate when data transmission (done_tx) and
//   reception (done_rx) are done.
//
//////////////////////////////////////////////////////////////////////////////////

module UART_Top #(
    parameter clk_freq = 1E6,
    parameter baud = 9600
)(
    input clk,              // Clock signal                 
    input rst_n,            // Reset signal (active low)                 
    input rx,               // UART receive line (idle high)
    input [7:0] din_tx,     // Data to transmit             
    input data_update,      // New data signal              
    output tx,              // UART transmit line      
    output [7:0] dout_rx,   // Data received           
    output done_tx,         // Transmission done signal
    output done_rx          // Reception done signal   
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
