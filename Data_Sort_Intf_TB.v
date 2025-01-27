`timescale 1ns / 1ps

`define clk_period 20

module Data_Sort_Intf_TB();

reg clk;
reg rst_n;
reg [7:0] d1_i;
reg [7:0] d2_i;
reg [7:0] d3_i;
wire [7:0] max_o;
wire [7:0] med_o;
wire [7:0] min_o;

Data_Sort_Intf uut(
    .clk(clk),
    .rst_n(rst_n),
    .d1_i(d1_i),
    .d2_i(d2_i),
    .d3_i(d3_i),
    .max_o(max_o),
    .med_o(med_o),
    .min_o(min_o)
    );
    
initial clk = 1'b1;
always #(`clk_period/2) clk = ~clk;
    
initial begin
    rst_n = 1'b0;
    d1_i = 8'd0;
    d2_i = 8'd0;
    d3_i = 8'd0;
    
    #(`clk_period);
    rst_n = 1'b1;
    
    // Test Case 1
    #(`clk_period);
    d1_i = 8'd1;
    d2_i = 8'd2;
    d3_i = 8'd3;
    
    #(`clk_period);
    if (max_o != 8'd3 || med_o != 8'd2 || min_o != 8'd1) 
        $display("Test Case 1 Failed: max_o = %d, med_o = %d, min_o = %d", max_o, med_o, min_o);
    else 
        $display("Test Case 1 Passed: max_o = %d, med_o = %d, min_o = %d", max_o, med_o, min_o);
    
    // Test Case 2
    d1_i = 8'd4;
    d2_i = 8'd6;
    d3_i = 8'd8;
    
    #(`clk_period);
    if (max_o != 8'd8 || med_o != 8'd6 || min_o != 8'd4) 
        $display("Test Case 2 Failed: max_o = %d, med_o = %d, min_o = %d", max_o, med_o, min_o);
    else 
        $display("Test Case 2 Passed: max_o = %d, med_o = %d, min_o = %d", max_o, med_o, min_o);
    
    // Test Case 3
    d1_i = 8'd11;
    d2_i = 8'd13;
    d3_i = 8'd15;
    
    #(`clk_period);
    if (max_o != 8'd15 || med_o != 8'd13 || min_o != 8'd11) 
        $display("Test Case 3 Failed: max_o = %d, med_o = %d, min_o = %d", max_o, med_o, min_o);
    else 
        $display("Test Case 3 Passed: max_o = %d, med_o = %d, min_o = %d", max_o, med_o, min_o);
    
    #(`clk_period*5);
    
    $stop;
end
        
endmodule
