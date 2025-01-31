`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// 
// Module Name: UART_Tx
//
// Description: UART transmitter module
// 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module UART_Tx #
(
    parameter clk_freq = 1E6,
    parameter baud = 9600
)
(
    input clk,
    input rst_n,
    input data_update,
    input [7:0] din_tx,
    output reg tx,
    output reg done_tx
);

    // Clock count calculation for baud rate generation
    localparam clk_count = (clk_freq / baud);
    
    integer baud_counter = 0;  // Counter for baud rate generation
    integer bit_count = 0;  // Counter for bits
    reg uart_clk = 0;

    // State machine states
    localparam [1:0] IDLE = 2'b00, 
                     START = 2'b01, 
                     TRANSFER = 2'b10, 
                     STOP = 2'b11; 
    
    reg [1:0] state = IDLE;
    
    reg [7:0] din;

    // Baud rate clock generation
    always @(posedge clk) begin
		if (baud_counter < clk_count / 2)
            baud_counter <= baud_counter + 1;
        else begin
            baud_counter <= 0;
            uart_clk <= ~uart_clk;
        end
    end

    // State machine for UART transmission
    always @(posedge uart_clk or negedge rst_n) begin
        if (!rst_n) begin 
            state <= IDLE;
        end else begin
            case (state) 
                IDLE: begin 
                    bit_count <= 0;
					tx <= 1'b1;
					done_tx <= 1'b0;
                    if (data_update) begin
                        state <= TRANSFER;
                        din <= din_tx;
                        tx <= 1'b0;
                    end else
						state <= IDLE;
                end

                TRANSFER: begin 
                    if (bit_count <= 7) begin
                        tx <= din[bit_count];
                        bit_count <= bit_count + 1;
						state <= TRANSFER;
                    end else begin
                        bit_count <= 0;
						tx <= 1'b1;
						state <= IDLE;
						done_tx <= 1'b1;
                    end
                end
                
                default: state <= IDLE;
            endcase                        
        end    
    end

endmodule
