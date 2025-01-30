`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Diego Garrido-Mendoza 
// 
// Create Date: 01/20/2025 10:49:15 PM
// Design Name: 
// Module Name: BRAM
// Project Name: 
// Target Devices: 
// Tool Versions: Vivado 2018.3 
// Description: This module consists of a Verilog model for a BRAM with configurable 
//              size and depth, and explicit control over read and write operations.  
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Instead of letting the synthesizer to infer the BRAM from the
//                      syntax of the code, this design directly sets up the functional
//                      behavior of a BRAM. 
//
// This is how this model works:
//  1) Parameters: 
//      DATA_WIDTH: Defines the size of the BRAM. 
//                  Sets the width of the data bus. 
//                  It defines how many bits each memory location can hold.  
//      ADDR_WIDTH: Defines the depth of the BRAM.
//                  Sets the width of the address bus.  
//                  It defines how many unique memory locations the BRAM can address.
// 
//////////////////////////////////////////////////////////////////////////////////

module BRAM #
(
    parameter DATA_WIDTH = 8,   // It defines how many bits each memory location can hold. 
    parameter ADDR_WIDTH = 4    // It defines how many unique memory locations the BRAM can address.
)
(
    input wire clk,
    input wire rst,   
    input wire write_enable,
    input wire read_enable,
    input wire [ADDR_WIDTH-1:0] address,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out    
);

    // Initialize memory array during reset
    integer i;

    // Calculate the depth of the memory.
    localparam DEPTH = 1 << ADDR_WIDTH; // DEPTH calculates the BRAM depth based on the address width.
        // How this calculations works:
        // A) ADDR_WIDTH is the number of bits in the address bus. 
        // B) 1 << ADDR_WIDTH implements a bitwise left shift to calculate 2^ADDR_WIDTH.
        // C) Each shift to the left effectively multiplies the number by 2, thus 2^N.
        // C) If ADDR_WIDTH = 4, the BRAM depth = 2^4 = 16 memory locations. 
    
    // Memory declaration.
    // The line below generates a 'mem' array with a number of elements in it (DEPTH) , and each element
    // has a given data width (DATA_WIDTH)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];   // 'mem' is the internal memory array. 
    
    
    // Always block.
    // Manages the read and write operations based on the state of the respective enable signals.
    always@(posedge clk or posedge rst)
    begin
        if (rst) begin
            // Reset logic. 
            data_out <= {DATA_WIDTH{1'b0}}; // Non-blocking assignment
            
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            if (write_enable && !read_enable) begin // Mutual exclusion for write operation.
                // Write operation.
                mem[address] <= data_in;    // Non-blocking assignment
            end 
            if (read_enable && !write_enable) begin // Mutual exclusion for read operation.
                // Read operation.
                data_out <= mem[address];   // Non-blocking assignment
            end
        end
    end

endmodule
