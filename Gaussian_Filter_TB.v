`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza
// Module Name: Gaussian_Filter_TB
//
// Description: 
// This testbench is intended to test the functionality of the Gaussian_Filter module.
// sets up the necessary signals to drive the Gaussian_Filter module, generates clock 
// signals, and verifies the output of the filtering process by providing specific 
// input data.
//
// Additional Comments:
// After providing the input data, the testbench waits for a few clock periods and 
// checks if the done_o signal is asserted. If it is, it prints the Gaussian output 
// value
// 
//////////////////////////////////////////////////////////////////////////////////

`define clk_period 20

module Gaussian_Filter_TB();

    reg clk;
    reg rst_n;
    reg en_i;
    reg [7:0] d1_i;
    reg [7:0] d2_i;
    reg [7:0] d3_i;
    
    wire done_o;
    wire [7:0] gaussian_o;

    Gaussian_Filter gaussian(
        .clk(clk),
        .rst_n(rst_n),
        .en_i(en_i),
        .d1_i(d1_i),
        .d2_i(d2_i),
        .d3_i(d3_i),
        .done_o(done_o),
        .gaussian_o(gaussian_o)
    );
    
    initial clk = 1'b1;
    always #(`clk_period/2) clk = ~clk;
    
    initial begin
        rst_n = 1'b0;   // System is reset.
        en_i = 1'b0;
        d1_i = 8'd0;
        d2_i = 8'd0;
        d3_i = 8'd0;
        
        #(`clk_period);
        rst_n = 1'b1;   // System comes back from reset.
    
        #(`clk_period);
        en_i = 1'b1;
        d1_i = 8'd1;
        d2_i = 8'd2;
        d3_i = 8'd3;
        
        #(`clk_period);
        en_i = 1'b0;
        d1_i = 8'd4;
        d2_i = 8'd5;
        d3_i = 8'd6;   
    
        #(`clk_period);
        d1_i = 8'd7;
        d2_i = 8'd8;
        d3_i = 8'd9;  
        
        #(`clk_period*4);
        if (done_o)
            $display("Test Case Passed: gaussian_o = %d", gaussian_o);
        else
            $display("Test Case Failed: done_o not asserted");
            
        #(`clk_period*5);
        $stop;
    end

endmodule
