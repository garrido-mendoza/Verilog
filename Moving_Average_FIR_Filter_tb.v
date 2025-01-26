`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// Module Name: Moving_Average_FIR_Filter_TB
// Examples of the content of the test input files:
// 1) sine.data.txt               2) direct_impulse.data.txt     3) random.data.txt
// 0000000000000010               0000000000000000               0000000000000000
// 0000000000011100               0000000000000000               0000000000000000
// 0000000000111100               0000000000000000               0000000000000000
// 0000000001001000               0000000000000000               0000000000000000
// 0000000001100111               0000000000000000               0000000000000000
// 0000000001110000               0000000000000000               0000000000000000
// 0000000010000001               0000000000000000               0000000000000000
// 0000000010001000               0000000000000000               0000000000000000
// 0000000010001000               0000000000000000               0000000000000001
// 0000000010000111               0000000000000000               0000000000000011
// 0000000001111011               0000000000000000               0000000000001001
// 0000000001101000               0000000000000000               0000000000010110
// 0000000001011110               0000000000000000               0000000000101011
// 0000000001000111               0000000000000000               0000000001000111
// 0000000000110000               0000000000000000               0000000001100101
// 0000000000010110               0000000010000000               0000000001111011
// 0000000000000000               0000000000000000               0000000001111111
// 1111111111100001               0000000000000000               0000000001110000
// 1111111111001000               0000000000000000               0000000001010100
// 1111111110110101               0000000000000000               0000000000110110
// 1111111110101000               0000000000000000               0000000000011101
// 1111111110010011               0000000000000000               0000000000001110
// 1111111110010001               0000000000000000               0000000000000101
// 1111111110000111               0000000000000000               0000000000000010
// 1111111110000101               0000000000000000               0000000000000001
// 1111111110001001               0000000000000000               0000000000000000
// 1111111110010117               0000000000000000               0000000000000000
// 1111111110100001               0000000000000000               0000000000000000
// 1111111110110001               0000000000000000               0000000000000000
// 1111111111010001               0000000000000000               0000000000000000
// 1111111111100111               0000000000000000               0000000000000000
// 1111111111110117               0000000000000000               0000000000000000
//////////////////////////////////////////////////////////////////////////////////
module Moving_Average_FIR_Filter_tb();

    parameter N = 16;
    
    reg clk;
    reg reset;
    reg signed [N-1:0] data_in;
    wire signed [N-1:0] data_out;   // For data_out, set analog waveform's y-range to 'fixed', min: -150, max: 150.
                                    // When running a sinewave, a gaussian pulse, set interpolation style to 'linear.' 
                                    // When running a direct pulse, set interpolation style to 'hold.' 
    Moving_Average_FIR_Filter #(
    ) inst0 (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Create the RAM
    reg [N-1:0] RAMM [31:0];
    
    // Input data
    initial
    $readmemb("/opt/Xilinx/Vivado/2023.1/Projects/FIR_Filter/Moving_Average_FIR_Filter/Moving_Average_FIR_Filter.srcs/sim_1/sine.data", RAMM);
//    $readmemb("/opt/Xilinx/Vivado/2023.1/Projects/FIR_Filter/Moving_Average_FIR_Filter/Moving_Average_FIR_Filter.srcs/sim_1/gaussian_impulse.data", RAMM);
//    $readmemb("/opt/Xilinx/Vivado/2023.1/Projects/FIR_Filter/Moving_Average_FIR_Filter/Moving_Average_FIR_Filter.srcs/sim_1/direct_impulse.data", RAMM);
    
    // Create a clock
    initial 
    clk = 1;
    always
    #10 clk = ~clk;
    
    // Reset sequence
    initial begin
        reset = 1;
        data_in = 0;
        // Initialize data_out to 0
        $monitor("data_in =%d", data_in, " | data_out =%d", data_out);
        #100;
        reset = 0;
    end
    
    // Address counter and data reading
    reg [4:0] Address;
    
    initial 
    begin
        Address = 0;
        data_in = 0;  // Initialize data_in to 0
    end
    
    always @(posedge clk or posedge reset)
    begin
        if (reset) begin
            Address <= 0;
            data_in <= 0;
        end else begin
            data_in <= RAMM[Address];
            if (Address == 31)
                Address <= 0;
            else
                Address <= Address + 1;
        end
    end

endmodule
