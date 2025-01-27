`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Diego Garrido-Mendoza
// Module Name: Mean_Filter
// Description:
// This Verilog module processes 10 input data values and calculates the mean
// of the middle eight values (excluding the maximum and minimum values).
// It effectively filters noise by excluding extreme values (outliers) from the
// average calculation, ensuring a more reliable mean.
// Breakdown:
//  1) Signal Definitions: Registers to store the maximum, minimum, sum, and
//     count of the input data.
//  2) Sum Operation: Accumulates the sum of the input data.
//  3) Finding Min and Max: Identifies the minimum and maximum input values.
//  4) Counting Inputs: Counts up to 10 input data values.
//  5) Calculating Output: Computes the mean of the eight middle values once
//     10 data points are received.
// Additional Comments:
//  sum = 01 + 02 + 03 + 04 + 05 + 06 + 07 + 08 + 09 + 10 = 55
//  sum - min + max = 55 - 1 - 10 = 44
//  sum / 8 = 44 / 8 = 5.5. From this result, we only detect the integer part
//  Thus, data_o = 5.
////////////////////////////////////////////////////////////////////////////////

module Mean_Filter(
    input clk,             // Clock signal for synchronous operations.
    input rst_n,           // Active low reset signal.
    input en_i,            // Enable signal.
    input [7:0] data_i,    // 8-bit input data.
    output reg [7:0] data_o,
    output reg done_o
);

//--------------------------------------------------------------------------------
// Signal declarations
//--------------------------------------------------------------------------------
reg [7:0] max;           // Holds the maximum value from the input data. 
reg [7:0] min;           // Holds the minimum value from the input data.
reg [11:0] sum;          // Accumulates the sum of the input data.
reg [3:0] num;           // Counts the number of input data values received.

//--------------------------------------------------------------------------------
// Sum calculation:
// Sums the input data values when enabled.
//--------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum <= 8'd0;
    end else if (en_i) begin
        sum <= sum + data_i;
    end else begin
        sum <= 8'd0;
    end
end

//--------------------------------------------------------------------------------
// Minimum value calculation:
// Tracks the minimum values from the input data.
//--------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        min <= 8'hff;
    end else if (en_i) begin
        if (data_i < min)
            min <= data_i;
    end else begin
        min <= 8'hff;
    end
end

//--------------------------------------------------------------------------------
// Maximum value calculation:
// Tracks the maximum values from the input data.
//--------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        max <= 8'd0;
    end else if (en_i) begin
        if (data_i > max)
            max <= data_i;
    end else begin
        max <= 8'd0;
    end
end

//--------------------------------------------------------------------------------
// Counting inputs:
// Keeps track of how many data points have been received.
//--------------------------------------------------------------------------------   
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        num <= 8'd0;    
    end else if (en_i) begin
        if (num == 4'd10) begin  // This 'num' register is to "remember" the 10 input data values.
            num <= 4'd0;
        end else begin
            num <= num + 4'd1;
        end
    end else begin
        num <= 4'd0;
    end
end

//--------------------------------------------------------------------------------
// Output calculation:
// Computes the mean of the eight middle values and sets the done_o flag once 
// 10 data points have been processed.
//--------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_o <= 8'd0;
        done_o <= 1'd0;
    end else if (en_i) begin
        if (num == 4'd10) begin
            data_o <= (sum - max - min) >> 3;   // This shift by three bits is to divide (sum - max - min) by 8
            done_o <= 1'd1;
        end else begin
            data_o <= 8'd0;
            done_o <= 1'd0;
        end
    end else begin
        data_o <= 8'd0;
        done_o <= 1'd0;
    end
end

endmodule
