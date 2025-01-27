`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Diego Garrido-Mendoza
// Module Name: Mean_Filter_TB
// Additional Comments:
////////////////////////////////////////////////////////////////////////////////
`define clk_period 20   // This is 10ns. 

module Mean_Filter_tb();

// Testbench signals
reg clk;
reg rst_n;
reg en_i;
reg [7:0] data_i;
wire [7:0] data_o;
wire done_o;

// Instantiate the Unit Under Test (UUT)
Mean_Filter uut (
    .clk(clk),
    .rst_n(rst_n),
    .en_i(en_i),
    .data_i(data_i),
    .data_o(data_o),
    .done_o(done_o)
);

// Clock generation
initial clk = 1'b1;
always #(`clk_period/2) clk = ~clk;
//always #5 clk = ~clk;

integer i = 0;

// Test procedure
initial begin
    // Initialize signals
    clk     = 1'b0;
    rst_n   = 1'b0;
    en_i    = 1'b0;
    data_i  = 8'd0;
        
    // Reset UUT
    #(`clk_period);
    rst_n = 1'b1;
    
    // Enable UUT and provide input data
    en_i = 1'b1;
    
    for (i=0; i<10; i=i+1) begin
        data_i = data_i + 8'd1;
        #(`clk_period);
    end            
    
    data_i = 8'd0;
    #(`clk_period);
    
    // Wait for processing to complete
    en_i = 1'b0;
    
    // Check outputs
    $display("Data Output: %d", data_o);
    $display("Done Output: %d", done_o);
    
    // Validate the output
    if (data_o == 5) begin
        $display("Test Passed: data_o = 5 as expected.");
    end else begin
        $display("Test Failed: data_o = %d, expected 5.", data_o);
    end
    
    #(`clk_period*10);

    // Finish simulation
    $stop;
end

endmodule
