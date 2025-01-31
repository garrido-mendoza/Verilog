`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// 
// Module Name: UART_Rx
//
// Description: UART receiver module
// 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module UART_Rx #
(
    parameter clk_freq = 1E6,
    parameter baud = 9600
)
(
    input clk,
    input rst_n,
    input rx,
    output reg [7:0] dout_rx,
    output reg done_rx
);

    //-------------------------------------------------------------------------------- 
    // Clock count calculation for baud rate generation.
    //--------------------------------------------------------------------------------
    localparam clk_count = (clk_freq / baud);
    
    integer baud_count = 0;  // Counter for baud rate generation   
    integer bit_count = 0;  // Counter for bits
    
    reg uart_clk = 0;

    //-------------------------------------------------------------------------------- 
    // FSM states.
    //--------------------------------------------------------------------------------
    localparam [1:0] IDLE = 2'b00, 
                     START = 2'b01, 
                     RECEIVE = 2'b10, 
                     STOP = 2'b11;
    
    reg [1:0] state = IDLE;

    //-------------------------------------------------------------------------------- 
    // Baud rate clock generation.
    //-------------------------------------------------------------------------------- 
    always @(posedge clk) begin
        if (baud_count < clk_count / 2)
            baud_count <= baud_count + 1;
        else begin
            baud_count <= 0;
            uart_clk <= ~uart_clk;
        end
    end

    //-------------------------------------------------------------------------------- 
    // State machine (FSM) for UART reception.
    //--------------------------------------------------------------------------------
    always @(posedge uart_clk) begin
        if (!rst_n) begin 
            dout_rx <= 8'h00;
            bit_count <= 0;
            done_rx <= 1'b0;
        end else begin
            case (state) 
                IDLE: begin 
                    dout_rx <= 8'h00;
					bit_count <= 0;
					done_rx <= 1'b0;
                    if (rx == 1'b0)  // Detect start bit
                        state <= START;
                    else
						state <= IDLE;
                end

                START: begin
                    if (bit_count <= 7) begin
                        bit_count <= bit_count + 1;
						dout_rx <= {rx, dout_rx[7:1]};  // Shift in received data
                    end else begin
                        bit_count <= 0;
                    end
                end

                RECEIVE: begin 
                    if (bit_count < 8) begin
                        dout_rx <= {rx, dout_rx[7:1]};  // Shift in received data
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 0;
						done_rx <= 1'b1;
						state <= IDLE;   
                    end
                end
                
                default: state <= IDLE;
            endcase                        
        end    
    end

endmodule
