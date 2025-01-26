`timescale 1ns / 1ps

module TB_Moving_Average_FIR_Filter();

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
//    $readmemb("/opt/Xilinx/Vivado/2023.1/Projects/FIR_Filter/Moving_Average_FIR_Filter/Moving_Average_FIR_Filter.srcs/sim_1/new/signal.data", RAMM);
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
