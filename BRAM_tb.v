`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Skyworks (DEMO)  
// Engineer: Diego Garrido-Mendoza 
// 
// Create Date: 01/20/2025 11:49:54 PM
// Design Name: 
// Module Name: BRAM_tb
// Project Name: 
// Target Devices: 
// Tool Versions: Vivado 2018.3
// Description: This testbench reads data from a text file, writes it to the BRAM, 
//              and then reads it back to generate a report. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module BRAM_tb ();

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH = 1 << ADDR_WIDTH;
    
    reg clk;
    reg rst;
    reg write_enable;
    reg read_enable;
    reg [ADDR_WIDTH-1:0] address;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    
    // BRAM instantiation.
    BRAM #(DATA_WIDTH, ADDR_WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Memory array to store test data.
    reg [DATA_WIDTH-1:0] test_input_data [0:DEPTH-1];    
    
    // Loop variable declaration.
    integer i;
    
    // Clock generation.
    always #5 clk = ~clk;
    
    // Initial block to read data, write to BRAM, and read back.
    initial begin
        // Signals initialization.
        clk = 0;
        rst = 1;
        write_enable = 0;
        read_enable = 0;
        address = 0;
        data_in = 0;
        
        // Reset the BRAM.
        #10 rst = 0;
        
        // Read test data from the text file.
        $readmemb("/home/diego/Documents/FPGA/Sources/test_input_data.txt", test_input_data);

        // Write data to BRAM.
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clk);
            write_enable = 1;
            read_enable = 0;
            address = i;
            data_in = test_input_data[i];
        end
        write_enable = 0;
        
        // Read data from BRAM and generate report.
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clk);
            read_enable = 1;
            write_enable = 0;
            address = i;
            @(posedge clk); // Wait for the data to be read. 
            $display("Address: %0d, Data: %08b", address, data_out);
        end
        read_enable = 0;
        
        // End of simulation.
        #10 $finish;
    end        

endmodule
