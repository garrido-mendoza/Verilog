//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// 
// Module Name: UART_Tx
//
// Description: UART transmitter module
// 
// - The UART_Tx module is responsible for transmitting data via UART.
// - It has parameters for clock frequency (clk_freq) and baud rate (baud), which
//   are crucial for generating the correct timing for UART communication.
// - Inputs include the clock signal (clk), reset signal (rst_n), data update
//   signal (data_update), and the data to be transmitted (din_tx).
// - Outputs include the transmit signal (tx) and a flag to indicate when
//   transmission is done (done_tx).
// - The module has a state machine with the following states:
//   * IDLE: The default state where the transmitter is waiting for data.
//   * TRANSFER: The state where data bits are being sent one by one.
// - It also generates a UART clock (uart_clk) based on the desired baud rate.
//   The baud rate clock generation ensures that data is sent at the correct speed.
//
//////////////////////////////////////////////////////////////////////////////////

module UART_Tx #(
    parameter clk_freq = 1E6,
    parameter baud = 9600
)(
    input clk,          // Clock signal
    input rst_n,        // Reset signal (active low)
    input data_update,  // New data signal
    input [7:0] din_tx, // Data to transmit
    output reg tx,      // UART transmit line
    output reg done_tx  // Transmission done signal
);

    //--------------------------------------------------------------------------------
    // Clock count calculation for baud rate generation
    //--------------------------------------------------------------------------------
    localparam integer clk_count = (clk_freq / baud);
    
    integer baud_counter = 0;   // Baud rate clock counter
    integer bit_count = 0;      // Count of bits
    
    reg uart_clk = 0;   // UART clock

    //--------------------------------------------------------------------------------
    // State machine states
    //--------------------------------------------------------------------------------
    localparam [1:0] IDLE = 2'b00; 
    localparam [1:0] TRANSFER = 2'b10; 
    
    reg [1:0] state = IDLE;
    reg [7:0] din;

    //--------------------------------------------------------------------------------
    // Baud rate clock generation
    //--------------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_counter <= 0;
            uart_clk <= 0;
        end else if (baud_counter < clk_count / 2) begin
            baud_counter <= baud_counter + 1;
        end else begin
            baud_counter <= 0;
            uart_clk <= ~uart_clk;
        end
    end 

    //--------------------------------------------------------------------------------
    // State machine for UART transmission
    //--------------------------------------------------------------------------------
    always @(posedge uart_clk or negedge rst_n) begin
        if (!rst_n) begin 
            state <= IDLE;
            tx <= 1'b0;
            done_tx <= 1'b0;
            din <= 8'b0;
        end else begin
            case (state) 
                //--------------------------------------------------------------------------------
                // State 0 (IDLE):                                                             
                // - The IDLE state is where the module waits for the data_update signal       
                //   to indicate that new data is ready for transmission.                      
                // - When data_update is asserted, the module captures the data and transitions
                //   to the TRANSFER state.
                //--------------------------------------------------------------------------------                                                    
                IDLE: begin                         
                    bit_count <= 0;
                    tx <= 1'b1;
                    done_tx <= 1'b0;
                    // Start Bit: When the module detects a data_update signal, it transitions to  
                    // TRANSFER and immediately sets the tx line to '0', signaling the start bit.
                    if (data_update) begin  
                        state <= TRANSFER;
                        tx <= 1'b0;         // Start bit.
                        din <= din_tx;
                    end
                end
                //--------------------------------------------------------------------------------
                // State 2 (TRANSFER):                                                                               
                // - The TRANSFER state handles the entire process of sending the start bit, data bits, 
                //   and stop bit.
                // - Although traditionally, UART transmission would have separate states for START, 
                //   DATA, and STOP, combining them in a single state like TRANSFER works if the logic 
                //   for these steps is properly managed within the state.       
                // - By including the stop bit transmission within the TRANSFER state, the state machine 
                //   stays in TRANSFER long enough to ensure that the stop bit is transmitted before 
                //   transitioning back to IDLE. This ensures that the entire UART frame (start bit, 
                //   data bits, stop bit) is correctly transmitted.
                //--------------------------------------------------------------------------------                                                                
                TRANSFER: begin                                                   
                    if (bit_count < 8) begin    // The state machine stays in TRANSFER and iterates through each bit of the data.
                        bit_count <= bit_count + 1;
                        tx <= din[bit_count];   // The bits are sent sequentially on each positive edge of the uart_clk.
                        state <= TRANSFER;
                    end else begin
                        bit_count <= 0;
                        tx <= 1'b1;         // After all data bits are sent, the tx line is set to '1'.
                        done_tx <= 1'b1;    // Stop bit. The state machine ensures that the stop bit is transmitted 
                                            // before transitioning back to IDLE.
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase                        
        end    
    end

endmodule
