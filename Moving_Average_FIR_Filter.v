module Moving_Average_FIR_Filter #(
    parameter N = 16,         // Data width
    parameter WINDOW_SIZE = 4 // For a window size of 4, each coefficient is 1/4.
)(
    input clk,
    input reset,
    input signed [N-1:0] data_in,
    output reg signed [N-1:0] data_out
);

// ------------------------------------------------------------------------------------------------------------
// Coefficients definition - local parameters
// ------------------------------------------------------------------------------------------------------------
localparam COEFF_WIDTH = 7;
localparam COEFF_VALUE = 7'd32; // The coefficients are defined as 32 in decimal, representing 1/4. 

// Role of Coefficients in Filters:
// 1) Weighting Input Samples: Coefficients assign different weights to each input sample 
//    during multiplication, crucial for filtering operations and emphasizing specific frequencies.
// 2) Filter Response: Coefficients directly affect the filter's frequency response, determining 
//    how the filter attenuates or amplifies different frequency components of the input signal.
// 3) Impulse Response: In FIR filters, coefficients define the impulse response's shape and duration, 
//    dictating how the filter processes input signals.
// 4) Smoothing and Noise Reduction: In moving average filters, equal coefficients help smooth the input 
//    signal by averaging multiple samples, reducing noise and rapid fluctuations.

genvar i;
generate
    // Generate block to create multiple instances of the coefficient wires
    // This loop iterates WINDOW_SIZE times, creating instances of wire 'b'. Each wire 'b' 
    // is a temporary signal used to represent the coefficients of the moving average 
    // FIR filter, with a width of COEFF_WIDTH and a value of COEFF_VALUE.
    // The 'genvar' keyword is used to declare the variable 'i' for the generate loop.
    //
    // Using a generate block simplifies the code by eliminating repetitive 
    // declarations, making the code more modular and easier to maintain. This approach 
    // is recommended for creating multiple instances of similar structures within a 
    // design, ensuring consistency and reducing the risk of errors due to manual duplication.
    for (i = 0; i < WINDOW_SIZE; i = i + 1) begin : coeff_gen
        wire signed [COEFF_WIDTH-1:0] b = COEFF_VALUE;
    end
endgenerate

// ------------------------------------------------------------------------------------------------------------
// Delays
// ------------------------------------------------------------------------------------------------------------
// Array to hold delayed versions of the input signal
wire signed [N-1:0] delayed_signals [0:WINDOW_SIZE-2];

// Function of Delays:
// 1) Sequential Data Processing: The DFFs store the input data samples and create 
//    delayed versions of these samples. This ensures that the filter has access to the 
//    current and previous samples required for the moving average calculation.
// 2) Smooth Data Flow: By introducing these delays, the filter can continuously process 
//    input data in a smooth and orderly manner, similar to how a pipeline moves data through different stages.
// 3) Reduced Latency: Pipelining with delays helps reduce the latency in processing 
//    each input sample, as the filter can operate on the current and delayed samples simultaneously.
generate
    for (i = 0; i < WINDOW_SIZE-1; i = i + 1) begin : delay_gen
        if (i == 0) begin
            DFF #(.N(N)) DFF_inst(clk, reset, data_in, delayed_signals[i]);
        end else begin
            DFF #(.N(N)) DFF_inst(clk, reset, delayed_signals[i-1], delayed_signals[i]);
        end
    end
endgenerate

// ------------------------------------------------------------------------------------------------------------
// Multiplication
// ------------------------------------------------------------------------------------------------------------
// This section multiplies each delayed data sample (including the current 
// input data) by the corresponding coefficient. The result of each multiplication
// is stored in a separate wire (Mul).
// These multiplication operations are essential for weighting the input samples 
// according to the filter's coefficients, which in this case are all equal and 
// represent a simple averaging operation.
//wire [N-1:0] Mul [0:WINDOW_SIZE-1];
wire signed [N+COEFF_WIDTH-1:0] Mul [0:WINDOW_SIZE-1];
assign Mul[0] = data_in * coeff_gen[0].b;

generate
    for (i = 1; i < WINDOW_SIZE; i = i + 1) begin : mult_gen
        assign Mul[i] = delayed_signals[i-1] * coeff_gen[i].b;
    end
endgenerate

// ------------------------------------------------------------------------------------------------------------
// Addition
// ------------------------------------------------------------------------------------------------------------
// This section sums the results of the multiplication operations to compute 
// the final output of the moving average filter. The sum (Add_final) represents 
// the average value of the current input data and the previous input samples, 
// weighted by their coefficients.
// The addition operation is critical as it combines the weighted input samples 
// to produce the filtered output, which smooths out rapid fluctuations in the 
// input signal by averaging multiple samples.
reg signed [N+COEFF_WIDTH-1:0] Add_final;
integer j;
always @* begin
    Add_final = Mul[0];
    for (j = 1; j < WINDOW_SIZE; j = j + 1) begin
        Add_final = Add_final + Mul[j];
    end
end

// Final Calculation - Output
always @(posedge clk) begin
    if (reset) begin
        data_out <= 0;
    end else begin
        data_out <= Add_final >> COEFF_WIDTH;   // Scale down the result to match the expected coefficients 
    end
end

endmodule

// This DFF (D Flip-Flop) module is used to delay the input signal by one sample.
// Each instantiation of the DFF creates a pipeline stage, holding the current 
// input value and providing a delayed version of it at the output.
// 
// The delay created by the DFF is essential for implementing the moving average 
// calculation, as it allows the filter to access previous input samples required 
// for the averaging process. This sequential processing of input samples helps 
// in smoothing the signal and reducing noise.
//
// Ports:
// - clk: Clock input signal for synchronization.
// - reset: Reset input signal to initialize the output to zero.
// - data_in: Input data signal to be delayed.
// - data_delayed: Output data signal representing the delayed version of the input.

module DFF #(
    parameter N = 16  // Data width
)(
    input clk,
    input reset,
    input signed [N-1:0] data_in,
    output reg signed [N-1:0] data_delayed
);

always @(posedge clk or posedge reset) begin
    if (reset)
        data_delayed <= 0;
    else
        data_delayed <= data_in;
end

endmodule