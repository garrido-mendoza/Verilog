//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// 
// Module Name: UART_Rx
//
// Description: UART receiver module
//
// - The testbench includes:
//   * Instantiation of UART_Top module: The UART_Top module is instantiated with 
//     the defined parameters and connected to the declared signals.
//   * Clock Generation: The clock toggles every 5 time units to create a 10 time 
//     units period clock.
//   * Test Procedure:
//     - It initializes signals and resets the system.
//     - A loop runs 10 iterations to test UART transmission and reception.
//     - For each iteration:
//       - A random byte of data is generated and transmitted.
//       - The tx line is monitored for the start bit, and the transmitted bits 
//         are captured.
//       - The rx line is manipulated to simulate data reception, and the received 
//         bits are captured.
//       - Transmission and reception statuses are displayed in a table format.
// - Here's a quick summary of the test sequence:
//   * Initialize: Reset the system.
//   * Transmission Test Loop: Transmit and capture data bits.
//   * Reception Test: Simulate reception by manipulating the rx line and capture 
//     the received bits.
//   * Display Results: Print transmitted and received data in a table format.
//
//////////////////////////////////////////////////////////////////////////////////

module UART_Rx #(
    parameter clk_freq = 1E6,
    parameter baud = 9600
)(
    input clk,                  // Clock signal
    input rst_n,                // Reset signal (active low)
    input rx,                   // UART receive line (idle high)
    output reg done_rx,         // Reception done signal
    output reg [7:0] dout_rx    // Data received 
);

    //--------------------------------------------------------------------------------
    // Clock count calculation for baud rate generation
    //--------------------------------------------------------------------------------
    localparam integer clk_count = (clk_freq / baud);
    
    integer baud_count = 0; // Baud rate clock counter   
    integer bit_count = 0;  // Count of bits
    
    reg uart_clk = 0;

    //--------------------------------------------------------------------------------
    // FSM states
    //--------------------------------------------------------------------------------
    localparam [1:0] IDLE = 2'b00; 
    localparam [1:0] START = 2'b01;
    
    reg [1:0] state = IDLE;

    //--------------------------------------------------------------------------------
    // Baud rate clock generation
    //--------------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_count <= 0;
            uart_clk <= 0;
        end else if (baud_count < clk_count / 2) begin
            baud_count <= baud_count + 1;
        end else begin
            baud_count <= 0;
            uart_clk <= ~uart_clk;
        end
    end

    //--------------------------------------------------------------------------------
    // State machine for UART reception
    //--------------------------------------------------------------------------------
    always @(posedge uart_clk or negedge rst_n) begin
        if (!rst_n) begin 
            dout_rx <= 8'h00;
            bit_count <= 0;
            done_rx <= 1'b0;
        end else begin
            case (state) 
                //--------------------------------------------------------------------------------
                // State 0 (IDLE):
                // - The IDLE state is where the module waits for the start bit (rx line going low) 
                //   to indicate the beginning of data reception.
                // - Upon detecting the start bit, the module transitions to the START state.
                //--------------------------------------------------------------------------------
                IDLE: begin                 
                    dout_rx <= 8'h00;
                    bit_count <= 0;
                    done_rx <= 1'b0;
                    if (rx == 1'b0) begin  // Detect start bit
                        state <= START;
                    end else begin
                        state <= IDLE;
                    end
                end
                //--------------------------------------------------------------------------------
                // State 1 (START):
                // - The START state handles the reception of data bits.
                // - This state encompasses the entire process of receiving the start bit, data bits, 
                //   and stop bit, assuming the correct sampling and data capture logic is implemented 
                //   within this state.
                //--------------------------------------------------------------------------------
                START: begin                  
                    if (bit_count <= 7) begin
                        bit_count <= bit_count + 1;
                        dout_rx <= {rx, dout_rx[7:1]};
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
